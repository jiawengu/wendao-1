-- ShenmdgDlg.lua
-- Created by huangzz Nov/07/2018
-- 迷宫游戏界面

local ShenmdgDlg = Singleton("ShenmdgDlg", Dialog)

local MiGongsCfg = require("cfg/MiGongsCfg")

local json = require('json')

local row, col
local miGongCfg
local BLOCK_SIZE = {width = 32, height = 32}

local NOT_SHOW_BLACK = false
local SHOW_REAL_PATH = false
local NOT_SHOW_EDG = false

local hasWalkMap = {}

function ShenmdgDlg:init()
    self:setCtrlFullClientEx("BKPanel")
    self:setCtrlFullClientEx("BKPanel_2")
    self:setFullScreen()

    self:bindListener("ExitButton_1", self.onExitButton_1)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:bindListener("ExitButton_2", self.onExitButton_2)
    self:bindListener("HomeButton", self.onHomeButton)
    -- self:bindListener("MainPanel", self.onMainPanel, nil, true)

    self:bindListener("LeftButton", self.onMovePanel, nil, true)
    self:bindListener("RightButton", self.onMovePanel, nil, true)
    self:bindListener("UpButton", self.onMovePanel, nil, true)
    self:bindListener("DownButton", self.onMovePanel, nil, true)
    self:bindListener("LockCheckBox", self.onMovePanel, nil, true)

    self.wallImg = self:retainCtrl("WallImage")
    self.MiGongPanel = self:getControl("MiGongPanel")
    self.userPanel = self:getControl("UserPanel")

    self.winSize = self:getWinSize()

    local icon = ResMgr:getCirclePortraitPathByIcon(gf:getIconByGenderAndPolar(Me:queryBasicInt("gender"), Me:queryBasicInt("polar")))
    self:setImage("Image", icon, self.userPanel)

    self.cloneCtrls = {}

    hasWalkMap = nil
    self.walkInfo = nil
    self.needWaitServerMsg = false
    self.longPress = nil
    self.lastClickPos = nil -- 
    self.isDragging = nil   -- 是否正处于拖动方向盘状态
    self.isStartMove = nil  -- 是否处于长按控制角色移动

    self:hookMsg("MSG_SMDG_START_GAME")
    self:hookMsg("MSG_SMDG_TRIGGER_EVENT")
    self:hookMsg("MSG_SMDG_FINISH_GAME")

    EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, self.onEnterCombat, self)
    EventDispatcher:addEventListener(EVENT.EVENT_END_COMBAT, self.onEndCombat, self)
end

function ShenmdgDlg:onEnterCombat()
    self:setVisible(false)

    if self.fightBackImg  then
        self.fightBackImg:removeFromParent()
        self.fightBackImg = nil
    end

    local backImg = cc.Sprite:create(ResMgr.ui.smdg_back_img)
    backImg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
    backImg:setTextureRect(cc.rect(0, 0, Const.WINSIZE.width, Const.WINSIZE.height))
    backImg:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
    Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())
    gf:getMapLayer():addChild(backImg)

    local order = FightMgr.bgImage:getOrderOfArrival()
    FightMgr.bgImage:setOrderOfArrival(backImg:getOrderOfArrival())
    backImg:setOrderOfArrival(order)

    self.fightBackImg = backImg
end

function ShenmdgDlg:onEndCombat()
    self:setVisible(true)

    self:reopen()

    if self.fightBackImg  then
        self.fightBackImg:removeFromParent()
        self.fightBackImg = nil
    end
end

function ShenmdgDlg:onContinueButton(sender, eventType)
    hasWalkMap = nil
    self.needWaitServerMsg = false
    gf:CmdToServer("CMD_SMDG_START_GAME", {})
end

function ShenmdgDlg:getPos(index)
    return math.floor(index / 100), index % 100
end

function ShenmdgDlg:getIndex(x, y)
    return x * 100 + y
end

function ShenmdgDlg:getBlockPos(x, y)
    return math.floor(x / BLOCK_SIZE.width) + 1, math.floor(y / BLOCK_SIZE.height) + 1
end

function ShenmdgDlg:getCenterPos(bx, by)
    return (bx - 1) * BLOCK_SIZE.width + BLOCK_SIZE.width / 2, (by - 1) * BLOCK_SIZE.height + BLOCK_SIZE.height / 2
end

function ShenmdgDlg:updateHasWalk(x, y)
    if not hasWalkMap[x] then hasWalkMap[x] = {} end

    local hasWalked = hasWalkMap[x][y] == 1
    hasWalkMap[x][y] = 1
    local index = self:getIndex(x, y)


    self.checkMeetCount = self.checkMeetCount + 1
    if self.checkMeetCount > math.floor(miGongCfg.real_path_count / 2) and self.hasTriggerEvent == 1 then
        self.checkMeetCount = 1
        self.hasTriggerEvent = nil
    end

    self:cmdMove(index, hasWalked)

    if not hasWalked then
        -- 刷新黑幕边界
        for i = 1, 3 do
            for j = 1, 3 do
                local x2 = x + (i - 2)
                local y2 = y + (j - 2)
                img = self.cloneCtrls[self:getIndex(x2, y2)]
                if img then
                    self:doShowImg(img, x2, y2)
                end
            end
        end
    end

    if x == col and y == 1 then
        -- 到达终点
        local md5 = string.lower(gfGetMd5(Me:queryBasic("gid") .. self.iid .. "succ"))
        gf:CmdToServer("CMD_SMDG_PASS_GAME", {
            level = self.curLevel,
            result = md5
        })
        self.needWaitServerMsg = true
        return
    end

    -- 起点、终点不触发事件
    if (x == 1 and y == row) or (x == col and y == 1) then
        return
    end

    -- 获取宝物
    if self.treasurePos and self.treasurePos.x == x and self.treasurePos.y == y then
        local tempPos = self.treasurePos
        self.treasurePos = nil
        self:cmdTriggerEvent(4, nil, nil, nil, index)
        self.treasurePos = tempPos
    end

    -- 遇宝
    if not hasWalked then
        self:checkMeetTreasure(index, x, y)
    end

    -- 指路
    if not hasWalked then
        self:checkShowWay(index)
    end

    -- 遇敌
    self:checkMeetEnermy(index)
end

function ShenmdgDlg:cmdMove(index, hasWalked)
    if not index then
        local x, y = self.userPanel:getPosition()
        local bx, by = self:getBlockPos(x, y)
        index = self:getIndex(bx, by)
    end

    gf:CmdToServer("CMD_SMDG_MOVE", {
        level = self.curLevel,
        pos = index,
        has_walk_str = self:getWalkInfoStr(hasWalked)
    })
end

-- 通知触发事件
function ShenmdgDlg:cmdTriggerEvent(type, right_dir, err_dir, trea_dir, index)
    gf:CmdToServer("CMD_SMDG_TRIGGER_EVENT", {
        level = self.curLevel,
        type = type,            -- 事件类型（1表示指路，2表示遇敌，3表示遇宝）
        right_dir = right_dir or "",
        err_dir = err_dir or "",
        trea_dir = trea_dir or "",
        pos = index,
        has_walk_str = self:getWalkInfoStr()
    })

    self.needWaitServerMsg = true
end

function ShenmdgDlg:getNotWalkDir(index)
    local dirs = {}
    local x, y = self:getPos(index)
    if self:hasDownRoad(index) and not self:hasWalk(x, y - 1) then
        table.insert(dirs, "d")
    end

    if self:hasRightRoad(index) and not self:hasWalk(x + 1, y) then
        table.insert(dirs, "r")
    end

    if self:hasDownRoad(index + 1) and not self:hasWalk(x, y + 1) then
        table.insert(dirs, "u")
    end

    if self:hasRightRoad(index - 100) and not self:hasWalk(x - 1, y) then
        table.insert(dirs, "l")
    end

    return dirs
end

-- 获取指路的方向
function ShenmdgDlg:getShowWayDir(index)
    local num = math.random(1, 3)
    local nextIndex = miGongCfg.real_path[index]
    local rightDir, showDir
    if math.abs(nextIndex - index) == 100 then
        rightDir = nextIndex - index > 0 and "r" or "l"
    else
        rightDir = nextIndex - index > 0 and "u" or "d"
    end

    if num == 1 then
        -- 错误的方向
        local nextIndex = miGongCfg.real_path[index]
        local dirs = self:getNotWalkDir(index)
        for i = #dirs, 1, -1 do
            if dirs[i] == rightDir then
                table.remove(dirs, i)
            end
        end

        showDir = dirs[math.random(1, #dirs)]
    else
        -- 正确的方向
        showDir = rightDir
    end

    local nextIndex = miGongCfg.real_path[index]
    if showDir == "r" then
        return CHS[5450351], num ~= 1
    elseif showDir == "l" then
        return CHS[5450350], num ~= 1
    elseif showDir == "u" then
        return CHS[5450348], num ~= 1
    elseif showDir == "d" then
        return CHS[5450349], num ~= 1
    end
end

-- 触发指路
function ShenmdgDlg:checkShowWay(index)
    if self.needWaitServerMsg then return end

    if self.showWayCou >= 1 then
        return
    end

    if miGongCfg.three_block[index] then
        -- 在正确的路上
        -- 至少三向连通
        local maxNum = math.floor(miGongCfg.three_block_count / 2)
        local num = math.random(1, maxNum)
        if num == 1 or miGongCfg.three_block[index] >= maxNum then
            -- 触发事件
            local dir, isRight = self:getShowWayDir(index)
            if dir then
                if isRight then
                    self:cmdTriggerEvent(1, dir, nil, nil, index)
                    self.rightDir = dir and dir .. "_" .. index or nil
                    self:showWay(self.rightDir, "RightDirectionImage")
                else
                    self:cmdTriggerEvent(1, nil, dir, nil, index)
                    self.errDir = dir and dir .. "_" .. index or nil
                    self:showWay(self.errDir, "WrongDirectionImage")
                end

                return true
            end
        end
    end
end

-- 触发遇敌
function ShenmdgDlg:checkMeetEnermy(index)
    if self.needWaitServerMsg then return end

    if self.meetEnermyCou >= 1 then
        return
    end

    if self.hasTriggerEvent == 1 then
        return
    end

    local maxNum = math.floor(miGongCfg.real_path_count / 2)
    local num = math.random(1, maxNum)
    if num == 1 or self.checkMeetCount >= maxNum then
        -- 触发事件
        self.hasTriggerEvent = 1
        self:cmdTriggerEvent(2, nil, nil, nil, index)
        return true
    end
end

-- 获取宝物距玩家当前位置的方向及位置
function ShenmdgDlg:getTreasureDirAndPos(index, x, y)
    local maxDis = 0
    local dx, dy
    local dir
    for i = col, 1, -1 do
        for j = 1, row do
            if not self:hasWalk(i, j)
                and not self:hasWalk(i, j + 1)
                and not self:hasWalk(i, j - 1)
                and not self:hasWalk(i + 1, j)
                and not self:hasWalk(i - 1, j)
                and not self:hasWalk(i - 1, j - 1)
                and not self:hasWalk(i - 1, j + 1)
                and not self:hasWalk(i + 1, j - 1)
                and not self:hasWalk(i + 1, j + 1) then
                local dis2 = math.abs(i - col) + math.abs(j - 1)
                if dis2 > 10 then
                    local dis = math.abs(i - x) + math.abs(j - y)
                    if (dis > maxDis) or (dis == maxDis and math.random(1, 2) == 1) then
                        dx = i
                        dy = j
                        maxDis = dis
                    end
                end
            end
        end
    end

    if dx then
        local dir
        if x == dx then
            dir = y > dy and 6 or 2
        elseif y == dy then
            dir = x > dx and 0 or 4
        else
            dir = gf:defineDirForPet({x = x, y = y}, {x = dx, y = dy})
        end

        return gf:getDirStr(dir), {x = dx, y = dy}
    end
end

-- 触发遇宝
function ShenmdgDlg:checkMeetTreasure(index, x, y)
    if self.needWaitServerMsg then return end

    if self.meetTreasureCou >= 1 then
        return
    end

    if self.hasTriggerEvent == 1 then
        return
    end

    local maxNum = math.floor(miGongCfg.real_path_count / 2)
    local num = math.random(1, maxNum)
    if num == 1 or self.checkMeetCount >= maxNum then
        -- 触发事件
        local dir, pos = self:getTreasureDirAndPos(index, x, y)
        if dir then
            self:showTreasure(pos)
            self.treasurePos = pos
            self.hasTriggerEvent = 1
            self:cmdTriggerEvent(3, nil, nil, dir, index)
            return true
        end
    end
end

function ShenmdgDlg:updateUserPos(dir)
    local x, y = self.userPanel:getPosition()
    local bx, by = self:getBlockPos(x, y)
    local cx, cy = self:getCenterPos(bx, by)
    local index = bx * 100 + by

    if dir == 1 and self:hasDownRoad(index + 1) then
        -- 向上
        x = cx
        y = cy + BLOCK_SIZE.width
        self:updateHasWalk(bx, by + 1)
    elseif dir == 2 and self:hasRightRoad(index) then
        -- 向右
        x = cx + BLOCK_SIZE.width
        y = cy
        self:updateHasWalk(bx + 1, by)
    elseif dir == 3 and self:hasDownRoad(index) then
        -- 向下
        x = cx
        y = cy - BLOCK_SIZE.width
        self:updateHasWalk(bx, by - 1)
    elseif dir == 0 and self:hasRightRoad(index - 100) then
        -- 向左
        x = cx - BLOCK_SIZE.width
        y = cy
        self:updateHasWalk(bx - 1, by)
    else
        return false
    end

    self.userPanel:setPosition(x, y)
    return true
end

function ShenmdgDlg:updateMovePanelPos(lastPos, curPos)
    local cx = curPos.x - lastPos.x
    local cy = curPos.y - lastPos.y

    local panel = self:getControl("MovePanel")
    local size = panel:getContentSize()
    local x, y = panel:getPosition()
    x = math.max(0, math.min(self.winSize.width / Const.UI_SCALE - size.width, x + cx))
    y = math.max(0, math.min(self.winSize.height / Const.UI_SCALE - size.height, y + cy))
    panel:setPosition(x, y)
end

function ShenmdgDlg:onMovePanel(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        if self.longPress then return end
        -- if self.delayToLong then return end
        if self.isDragging then return end
        if not hasWalkMap or self.needWaitServerMsg then return end

        local name = sender:getName()
        self.lastClickPos = GameMgr.curTouchPos

        self.isCanDrag = self:isCheck("LockCheckBox")
        local tag = sender:getTag()
        if tag < 4 and not self.isCanDrag then
            -- self.delayToLong = performWithDelay(self.root, function()
                -- self.delayToLong = nil
                self.longPress = self:startSchedule(function()
                    if not hasWalkMap or self.needWaitServerMsg then return end
                    self.isStartMove = true
                    self:updateUserPos(tag)
                end, 0.1)
            -- end, 0.1)
        end
    elseif eventType == ccui.TouchEventType.moved then
        if not self.lastClickPos then return end
        if not hasWalkMap or self.needWaitServerMsg then return end

        local pos = GameMgr.curTouchPos

        if not self.isDragging then
            if self.isCanDrag and gf:distance(self.lastClickPos.x, self.lastClickPos.y, pos.x, pos.y) > 10 then
                self:stopSchedule(self.longPress)
                self.longPress = nil
                -- self.root:stopAction(self.delayToLong)
                -- self.delayToLong = nil

                self.isDragging = true

                self:updateMovePanelPos(self.lastClickPos, pos)
                self.lastClickPos = pos
            end
        else
            self:updateMovePanelPos(self.lastClickPos, pos)
            self.lastClickPos = pos
        end
    else
        self:stopSchedule(self.longPress)
        self.longPress = nil
        -- self.root:stopAction(self.delayToLong)
        -- self.delayToLong = nil

        if hasWalkMap and not self.needWaitServerMsg then
            local tag = sender:getTag()
            if not self.isCanDrag and not self.isStartMove and tag < 4 then
                self:updateUserPos(tag)
            end
        end

        if sender:getName() == "LockCheckBox" and eventType == ccui.TouchEventType.ended then
            if self.isDragging then
                self:setCheck("LockCheckBox", true)
            else
                if self:isCheck("LockCheckBox") then
                    gf:ShowSmallTips(CHS[5410326])
                else
                    gf:ShowSmallTips(CHS[5410327])
                end
            end
        end

        self.isDragging = nil
        self.isStartMove = nil
    end
end

function ShenmdgDlg:hasRightRoad(index)
    return miGongCfg[index] == 2 or miGongCfg[index] == 3
end

function ShenmdgDlg:hasDownRoad(index)
    return miGongCfg[index] == 1 or miGongCfg[index] == 3
end

function ShenmdgDlg:generalMiGong()
    -- 上边界
    local img = self.cloneCtrls[-1]
    local wallSize = self.wallImg:getContentSize()
    if not img then
        img = self.wallImg:clone()
        local size = BLOCK_SIZE
        img:setPosition(col * size.width / 2, (row - 1) * size.height + size.height / 2 + 2)
        img:setContentSize(size.width * col + 4, wallSize.height)
        self.MiGongPanel:addChild(img, 1, 9999998)

        self.cloneCtrls[-1] = img
    end

    -- 左边界
    local img = self.cloneCtrls[-2]
    if not img then
        img = self.wallImg:clone()
        local size = BLOCK_SIZE
        img:setPosition(size.width / 2 - 2, (row - 1) * size.height / 2)
        img:setRotation(270)
        img:setContentSize(size.height * (row - 1) + 4, wallSize.height)
        self.MiGongPanel:addChild(img, 1, 9999999)

        self.cloneCtrls[-2] = img
    end

    for y = 0, row + 1 do
        for x = 0, col + 1 do
            local tag = self:getIndex(x, y)
            local img = self.cloneCtrls[tag]
            if not img then
                img = cc.Sprite:create() -- self.wallImg:clone()
                img:setPosition(self:getCenterPos(x, y))
                self.MiGongPanel:addChild(img, 1, tag)

                self.cloneCtrls[tag] = img
            end

            self:doShowImg(img, x, y)

            if SHOW_REAL_PATH then
                local layer = self.cloneCtrls[tag + 10000000]
                if miGongCfg.real_path[tag] then
                    if not layer then
                        layer = cc.LayerColor:create(cc.c4b(255, 0, 0, 100))
                        layer:setContentSize(wallSize.width, wallSize.height)
                        layer:setAnchorPoint(0, 0.5)
                        layer:setPosition(self:getCenterPos(x - 0.5, y - 0.5))
                        self.MiGongPanel:addChild(layer, 2, tag + 10000000)

                        self.cloneCtrls[tag + 10000000] = layer
                    end

                    layer:setVisible(true)
                else
                    if layer then layer:setVisible(false) end
                end

                local layer = self.cloneCtrls[tag + 20000000]
                if miGongCfg.three_block[tag] then
                    if not layer then
                        layer = cc.LayerColor:create(cc.c4b(255, 255, 0, 100))
                        layer:setContentSize(wallSize.width, wallSize.height)
                        layer:setAnchorPoint(0, 0.5)
                        layer:setPosition(self:getCenterPos(x - 0.5, y - 0.5))
                        self.MiGongPanel:addChild(layer, 2, tag + 20000000)

                        self.cloneCtrls[tag + 20000000] = layer
                    end

                    layer:setVisible(true)
                else
                    if layer then layer:setVisible(false) end
                end
            end
        end
    end

    -- 背景平铺
    local panel = self:getControl("MainPanel")
    local backImg = self.cloneCtrls[-3]
    if not backImg then
        backImg = cc.Sprite:create(ResMgr.ui.smdg_back_img)
        backImg:getTexture():setTexParameters(gl.LINEAR, gl.LINEAR, gl.REPEAT, gl.REPEAT)
        local size = panel:getContentSize()
        backImg:setTextureRect(cc.rect(0, 0, size.width, size.height))
        backImg:setPosition(size.width / 2, size.height / 2)
        panel:addChild(backImg, 0, 9999997)

        self.cloneCtrls[-3] = backImg
    end
end

-- 显示指路
function ShenmdgDlg:showWay(str, imgName)
    local img = self:getControl(imgName)
    if not str then
        img:setVisible(false)
        return
    end

    img:setVisible(true)

    local arg = gf:split(str, "_")
    local dir = arg[1]
    local index = tonumber(arg[2])
    if dir and index then
        local x, y = self:getCenterPos(self:getPos(index))
        img:setPosition(x, y)
        if dir == CHS[5450351] then
            img:setRotation(0)
        elseif dir == CHS[5450350] then 
            img:setRotation(180)
        elseif dir == CHS[5450348] then
            img:setRotation(-90)
        elseif dir == CHS[5450349] then
            img:setRotation(90)
        end
    end
end

function ShenmdgDlg:showTreasure(pos)
    local boxImage = self:getControl("BoxImage")
    if pos then
        boxImage:setPosition(self:getCenterPos(pos.x, pos.y))
        boxImage:setVisible(true)
    else
        boxImage:setVisible(false)
    end
end

function ShenmdgDlg:loadWallImage(img, x, y)
    local index = self:getIndex(x, y)
    img:setOpacity(255)
    img:setScale(1.125)
    if miGongCfg[index] == 3 or x <= 0 or x > col or y <= 0 or y > row then
        -- 可连通右、下边
        img:setOpacity(0)
    elseif miGongCfg[index] == 1 then
        -- 可连通下边
        img:setRotation(90)
        img:setTexture(ResMgr.ui.smdg_one_wall_img)
    elseif miGongCfg[index] == 2 then
        -- 可连通右边
        img:setRotation(180)
        img:setTexture(ResMgr.ui.smdg_one_wall_img)
    elseif miGongCfg[index] == 0 then
        -- 不可连通右、下边
        img:setRotation(180)
        img:setTexture(ResMgr.ui.smdg_two_wall_img)
    end
end

function ShenmdgDlg:addWalkEdgeBlack(img, icon, x, y, flipX, flipY)
    if NOT_SHOW_EDG then
        return
    end

    local tag = x * 100 + y + 100000
    local black = self.cloneCtrls[tag]
    if not black then
        black = cc.Sprite:create(icon)
        black:setPosition(self:getCenterPos(x, y))
        self.MiGongPanel:addChild(black, 100, tag)

        self.cloneCtrls[tag] = black
    else
        black:setTexture(icon)
    end

    black:setFlippedX(flipX)
    black:setFlippedY(flipY)
    black:setVisible(true)
end

function ShenmdgDlg:hasWalk(x, y)
    return hasWalkMap[x] and hasWalkMap[x][y] == 1
end

function ShenmdgDlg:doShowImg(img, x, y)
    local needAddWall = true
    local blackTag = x * 100 + y + 100000
    if self:hasWalk(x, y) then
        local black = self.cloneCtrls[blackTag]
        if black then black:setVisible(false) end
    else
        local hasBlack = {true, true, true, true} -- 标记一个块四个角黑了几个
        if self:hasWalk(x - 1, y + 1) or self:hasWalk(x - 1, y) or self:hasWalk(x, y + 1) then
            -- 左上角移除黑块
            hasBlack[1] = false
        end

        if self:hasWalk(x + 1, y + 1) or self:hasWalk(x + 1, y) or self:hasWalk(x, y + 1) then
            -- 右上角移除黑块
            hasBlack[2] = false
        end

        if self:hasWalk(x - 1, y - 1) or self:hasWalk(x - 1, y) or self:hasWalk(x, y - 1) then
            -- 左下角移除黑块
            hasBlack[3] = false
        end

        if self:hasWalk(x + 1, y -1) or self:hasWalk(x + 1, y) or self:hasWalk(x, y - 1) then
            -- 右下角移除黑块
            hasBlack[4] = false
        end

        local cou = 0
        for i = 1, 4 do
            if hasBlack[i] then cou = cou + 1 end
        end

        if cou == 4 and not NOT_SHOW_BLACK then
            -- 四个角全黑
            img:setScale(1)
            img:setOpacity(255)
            img:setTexture(ResMgr.ui.smdg_all_black_img)
            needAddWall = false
        elseif cou == 3 then
            self:addWalkEdgeBlack(img, ResMgr.ui.smdg_part_black_img1, x, y, not hasBlack[1] or not hasBlack[3], not hasBlack[1] or not hasBlack[2])
        elseif cou == 2 then
            if hasBlack[1] == hasBlack[2] or hasBlack[3] == hasBlack[4] then
                self:addWalkEdgeBlack(img, ResMgr.ui.smdg_part_black_img3, x, y, false, hasBlack[3])
            elseif hasBlack[2] == hasBlack[4] or hasBlack[1] == hasBlack[3] then
                self:addWalkEdgeBlack(img, ResMgr.ui.smdg_part_black_img4, x, y, hasBlack[2], false)
            else
                -- 两个对角有黑块
                self:addWalkEdgeBlack(img, ResMgr.ui.smdg_part_black_img5, x, y, hasBlack[2], false)
            end
        elseif cou == 1 then
            -- 一个角没黑块
            self:addWalkEdgeBlack(img, ResMgr.ui.smdg_part_black_img2, x, y, hasBlack[4] or hasBlack[2], hasBlack[4] or hasBlack[3])
        else
            local black = self.cloneCtrls[blackTag]
            if black then black:setVisible(false) end
        end
    end

    if needAddWall then
        self:loadWallImage(img, x, y)
    end
end

function ShenmdgDlg:getWalkInfoStr(hasWalked)
    local walkInfo
    if not self.walkInfo or not hasWalked then
        walkInfo = {}
        for i = 1, row do
            local num = 0
            for j = 1, col do
                if hasWalkMap[j] and hasWalkMap[j][i] == 1 then
                    num = num * 2 + 1
                else
                    num = num * 2
                end
            end

            table.insert(walkInfo, num)
        end

        self.walkInfo = walkInfo
    else
        walkInfo = self.walkInfo
    end

    local str = json.encode({walkInfo = walkInfo, tPos = self.treasurePos, mCout = self.checkMeetCount or 0, hasMeet = self.hasTriggerEvent, rd = self.rightDir, ed = self.errDir})

    return str
end

function ShenmdgDlg:initWalkInfo(str, isNew)
    if str == "" then
        hasWalkMap = {}
        hasWalkMap[1] = {}
        hasWalkMap[1][row] = 1
        hasWalkMap[col] = {}
        hasWalkMap[col][1] = 1

        self.treasurePos = nil
        self.hasTriggerEvent = nil
        self.rightDir = nil
        self.errDir = nil
        self.checkMeetCount = 0
    else
        local info = json.decode(str)
        if isNew then
            -- 只有首次加载迷宫需要处理，走动的过程中不处理，防止服务端主动刷新了旧的数据
            local walkInfo = info.walkInfo
            hasWalkMap = {}
            for i = 1, row do
                local num = tonumber(walkInfo[i])
                for j = 1, col do
                    local c = num % 2
                    if c == 1 then
                        if not hasWalkMap[col - j + 1] then hasWalkMap[col - j + 1] = {} end
                        hasWalkMap[col - j + 1][i] = c
                    end

                    num = math.floor(num / 2)
                end
            end

                -- 
            self.checkMeetCount = info.mCout

            self.hasTriggerEvent = info.hasMeet

            self.rightDir = info.rd
            self.errDir = info.ed
        end

        -- 遇宝、踩宝箱时都会刷，不会有旧数据的情况
        self.treasurePos = info.tPos
    end
end

-- 显示游戏时间
function ShenmdgDlg:setHasTime(time)
    self.hasTime = time
    function func()
        if Me:isInCombat() then return end

        self.hasTime = math.min(self.hasTime, 5999)
        local m = math.floor(self.hasTime / 60)
        local s = self.hasTime % 60

        self:setLabelText("Label", string.format("%02d:%02d", m, s), "TimePanel")

        self.hasTime = self.hasTime + 1
    end

    func()

    if self.scheduleId then
        return
    end

    self.scheduleId = self:startSchedule(func, 1)
end

function ShenmdgDlg:MSG_SMDG_START_GAME(data)
    self:setCtrlVisible("ResultPanel", false)

    self.meetEnermyCou = data.meet_enermy_count     -- 遇敌次数
    self.meetTreasureCou = data.meet_treasure_count -- 遇宝次数
    self.showWayCou = data.show_way_count           -- 指路次数
    self.curLevel = data.level                      -- 关卡
    self.iid = data.iid

    miGongCfg = MiGongsCfg[data.no]
    row = miGongCfg.row
    col = miGongCfg.col

    -- 耗时
    self:setHasTime(data.has_time)

    -- 关卡
    self:setImagePlist("Image_2", string.format("lingyzmword%04d.png", self.curLevel), "StagePanel")

    local isNew = not hasWalkMap
    self:initWalkInfo(data.has_walk_str, isNew)

        -- 创建迷宫
    if isNew then
        self:generalMiGong()
        data.pos = data.pos == -1 and 117 or data.pos
        self.userPanel:setPosition(self:getCenterPos(self:getPos(data.pos)))
    end

    -- 显示宝箱
    self:showTreasure(self.treasurePos)

    self:showWay(self.rightDir, "RightDirectionImage")

    self:showWay(self.errDir, "WrongDirectionImage")
end

function ShenmdgDlg:MSG_SMDG_TRIGGER_EVENT(data)
    self.needWaitServerMsg = false
    if data.result == 1 then
        -- 事件响应成功
        -- 事件响应成功先将次数加上去，战斗后会另刷新次数
        if data.type == 1 then
            self.showWayCou = self.showWayCou + 1
        elseif data.type == 2 then
            self.meetEnermyCou = self.meetEnermyCou + 1
        elseif data.type == 3 then
            self.meetTreasureCou = self.meetTreasureCou + 1
        elseif data.type == 4 then
        end
    elseif data.result == 0 then
        -- 事件响应失败
        if data.type == 2 then
            self.hasTriggerEvent = 0
            self.rightDir = nil
            self.errDir = nil
            self:showWay(self.rightDir, "RightDirectionImage")
            self:showWay(self.errDir, "WrongDirectionImage")
            self.treasurePos = nil
            self:showTreasure()
            self.hasTriggerEvent = 0
        elseif data.type == 4 then
        end
    end
end

-- 结算界面
function ShenmdgDlg:MSG_SMDG_FINISH_GAME(data)
    self:setCtrlVisible("ResultPanel", true)
    if self.curLevel >= 2 and data.result == 1 then
        self:setCtrlVisible("ExitButton_1", false, "ResultPanel")
        self:setCtrlVisible("ExitButton_2", true, "ResultPanel")
        self:setCtrlVisible("ContinueButton", false, "ResultPanel")
    else
        self:setCtrlVisible("ExitButton_1", true, "ResultPanel")
        self:setCtrlVisible("ExitButton_2", false, "ResultPanel")
        self:setCtrlVisible("ContinueButton", true, "ResultPanel")
    end

    self:setCtrlVisible("NotePanel_1", self.curLevel == 2 and data.result == 1)

    if data.result == 1 then
        self:setCtrlVisible("WinPanel", true, "ResultPanel")
        self:setCtrlVisible("LosePanel", false, "ResultPanel")
    else
        self:setCtrlVisible("WinPanel", false, "ResultPanel")
        self:setCtrlVisible("LosePanel", true, "ResultPanel")
    end

    local time = math.min(data.has_time, 5999)
    local m = math.floor(time / 60)
    local s = time % 60
    local str = string.format("%02d:%02d", m, s)
    self:setLabelText("Label", str, "TimePanel")
    self:setLabelText("Label", str, "ResultTimePanel")
    if self.scheduleId then
        self:stopSchedule(self.scheduleId)
        self.scheduleId = nil
    end

    -- 关卡
    self:setImagePlist("Image_2", string.format("lingyzmword%04d.png", data.level), "ResultStagePanel")
end

function ShenmdgDlg:onCloseButton()
    gf:confirm(CHS[5450344], function()
        DlgMgr:closeDlg("ShenmdgDlg")
    end)
end

function ShenmdgDlg:onExitButton_2()
    DlgMgr:closeDlg("ShenmdgDlg")

    if self.curLevel == 2 then
        gf:ShowSmallTips(CHS[5450364])
    end
end

function ShenmdgDlg:onExitButton_1()
    DlgMgr:closeDlg("ShenmdgDlg")
end

function ShenmdgDlg:onHomeButton()
    gf:confirm(CHS[5400790], function()
        local cx, cy = self:getCenterPos(1, row)
        self.userPanel:setPosition(cx, cy)
        self:cmdMove(self:getIndex(1, row), true)
    end)
end

function ShenmdgDlg:cleanup()
    gf:CmdToServer("CMD_SMDG_QUIT_GAME", {})

    EventDispatcher:removeEventListener(EVENT.ENTER_COMBAT, self.onEnterCombat, self)
    EventDispatcher:removeEventListener(EVENT.EVENT_END_COMBAT, self.onEndCombat, self)

    self.scheduleId = nil
    self.showWayCou = nil
    self.meetEnermyCou = nil
    self.meetTreasureCou = nil
    self.checkMeetCount = nil
    self.hasTriggerEvent = nil
    self.rightDir = nil
    self.errDir = nil

    hasWalkMap = nil

    self.cloneCtrls = nil

    if self.fightBackImg  then
        self.fightBackImg:removeFromParent()
        self.fightBackImg = nil
    end
end


return ShenmdgDlg
