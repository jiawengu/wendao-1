-- CaseRunGameDlg.lua
-- Created by huangzz  May/25/2018
-- 摘桃子界面（探案）

local CaseRunGameDlg = Singleton("CaseRunGameDlg", Dialog)

-- 游戏状态
local STATE = {
    WAIT = 1,
    RUNING = 2,
    PAUSE = 3,
    STOP = 4
}

-- 道路方向
local DIR = {
    UP = 1,
    LEFT = 2,
    RIGHT = 3
}

local DIR_IMG_TAG = 100

local DIR_RADIUS = 50  -- 安全距离

local CAN_TURN_RADIUS = 150  -- 可以转弯或跳跃的距离

local INIT_SPEED = 240  -- 像素/s

local SKIP_BLOCK_SPACE = 50  -- 两块跳板间的间隔

local SKIP_DIS = 200  -- 猴子跳跃的距离

local ONE_PEACH_SCORE = 2 -- 一个桃子的分数

local MAX_SCORE = 2000

local PEACH_NUM_PER_BLOCK = 2 -- 每个跳板放 n 个桃子

-- 根据分数配置：
--- 转弯、跳跃出现的概率(总概率 100)
--- 直线连续最多、最少的块数
local LIMIT_CONFIG = {
    [1] = {
        ["score"] = 50,
        ["zhuanwan"] = 15,  -- 转弯概率
        ["tiaoyue"] = 10,   -- 跳跃概率
        ["min_block"] = 5,  -- 直线最小连续块
        ["max_block"] = 10, -- 直线最大连续块
    },
    [2] = {
        ["score"] = 80,
        ["zhuanwan"] = 25,
        ["tiaoyue"] = 15,
        ["min_block"] = 4,
        ["max_block"] = 8,
    },
    [3] = {
        ["score"] = 300,
        ["zhuanwan"] = 30,
        ["tiaoyue"] = 20,
        ["min_block"] = 3,
        ["max_block"] = 6,
    },
    [4] = {
        ["score"] = 400,
        ["zhuanwan"] = 40,
        ["tiaoyue"] = 30,
        ["min_block"] = 2,
        ["max_block"] = 3,
    },
    [5] = {
        ["score"] = 700,
        ["zhuanwan"] = 40,
        ["tiaoyue"] = 30,
        ["min_block"] = 2,
        ["max_block"] = 4,
    }
}

function CaseRunGameDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")
    self:setCtrlFullClientEx("BackPanel", "StarPanel")

    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ShowCharPanel", self.onShowCharPanel, nil, true)

    self.roadRectImg = self:retainCtrl("RectangleImage")
    self.roadCircleImg = self:retainCtrl("CircularImage")
    self.roadturnImg = self:retainCtrl("MiddleleImage")

    self.roadRectSize = self.roadRectImg:getContentSize()
    self.roadCicleSize = self.roadCircleImg:getContentSize()

    self.showCharPanel = self:getControl("ShowCharPanel")
    self.showRoadPanel = self:getControl("ShowRoadPanel")

    local size = self.showCharPanel:getContentSize()
    self.centerPos = {x = size.width / 2, y = size.height / 2}

    self.gameState = STATE.WAIT
    self.curDir = DIR.UP

    self.roadPartQue = {}     -- 路块
    self.dirImgQue = {}       -- 方向图标
    self.peachQue = {}        -- 桃子
    self.lastRoadPart = nil   -- 记载最后一次加载的路块对象
    self.continueDirNum = 0   -- 记录当前创建的连续相同方向的路块的数目
    self.totalPeachNum = 0
    self.walkDisToFaild = nil
    self.hasClick = false    -- 标记是否点击屏幕，用于转弯
    self.curScore = 0
    self.curSpeed = INIT_SPEED

    self:creatMonkey()

    self:initRoadPart()

    self:showScore(self.curScore)

    self:setCtrlVisible("StarPanel", true)

    if self.blank.colorLayer then
        -- 黑幕透明度
        self.blank.colorLayer:setOpacity(179)
    end

    DlgMgr:closeDlg("DramaDlg")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self:hookMsg("MSG_TWZM_START_PICK_PEACH")
    self:hookMsg("MSG_TWZM_QUIT_PICK_PEACH")
end

--
function CaseRunGameDlg:initRoadPart()
    for i = 1, 4 do
        self:creatOneRoad(DIR.UP, i <= 3)
    end

    for i = 1, 20 do
        self:creatOneRoad()
    end
end

function CaseRunGameDlg:onCloseButton()
    if self.gameState ~= STATE.RUNING then
        if self.gameState == STATE.PAUSE then return end

        DlgMgr:closeDlg(self.name)
    else
        self.gameState = STATE.PAUSE
        gf:CmdToServer("CMD_TWZM_PAUSE_PICK_PEACH", {})
        gf:confirm(CHS[5450242], function()
            self:gameOver(-1)
        end, function()
            -- 暂停恢复
            gf:CmdToServer("CMD_TWZM_START_PICK_PEACH", {flag = 0})
        end)
    end
end

function CaseRunGameDlg:onStartButton(sender)
    gf:CmdToServer("CMD_TWZM_START_PICK_PEACH", {flag = 1})
end

function CaseRunGameDlg:onShowCharPanel(sender, eventType)
    if eventType == ccui.TouchEventType.began then
        local time = gfGetTickCount()
        if sender.latsClickTime and time - sender.latsClickTime < 200  then
            return
        end

        sender.latsClickTime = time
        self.hasClick = true
    end
end

-- 根据方向获取木板的旋转度数
function CaseRunGameDlg:getRotationByDir(dir)
    if dir == DIR.UP then
        return 0
    elseif dir == DIR.RIGHT then
        return 90
    elseif dir == DIR.LEFT then
        return 270
    end
end

-- 随机生成下一路块的方向
-- 连续相同方向的路块最多不超过 CONTINUE_DIR_LIMIT_NUM 块
function CaseRunGameDlg:randomDir(dir)
    local info = self:getRandomLimit()
    local lastDir = self.lastRoadPart and  self.lastRoadPart.dir or DIR.UP
    local needSkip = false
    local curDir = DIR.UP
    local num = math.random(1, 100)

    if dir then
        curDir = dir
    elseif num <= info.zhuanwan and self.continueDirNum >= info.min_block then
        -- 转弯
        curDir = lastDir == DIR.UP and math.random(2, 3) or 1
    elseif num <= info.zhuanwan + info.tiaoyue and self.continueDirNum >= info.min_block then
        -- 跳跃
        curDir = lastDir
        needSkip = true
    else
        if self.continueDirNum >= info.max_block then
            local num = math.random(1, info.zhuanwan + info.tiaoyue)
            if num <= info.zhuanwan then
                -- 转弯
                curDir = lastDir == DIR.UP and math.random(2, 3) or 1
            else
                -- 跳跃
                curDir = lastDir
                needSkip = true
            end
        else
            -- 直线
            curDir = lastDir
        end
    end

    if not needSkip and lastDir == curDir then
        self.continueDirNum = self.continueDirNum + 1
    else
        self.continueDirNum = 1
    end

    return curDir, needSkip
end

function CaseRunGameDlg:getRandomLimit()
    local cou = #LIMIT_CONFIG
    for i = 1, cou do
        if LIMIT_CONFIG[i].score > self.curScore then
            return LIMIT_CONFIG[i]
        end
    end

    return LIMIT_CONFIG[cou]
end


function CaseRunGameDlg:creatOneRoad(fixDir, notCreatPeach)
    local dir, needSkip = self:randomDir(fixDir)

    local panel = self.showRoadPanel
    local img = self.roadRectImg:clone()
    local size = self.roadRectSize
    local cou = #self.roadPartQue

    img:setRotation(self:getRotationByDir(dir))
    img.dir = dir

    -- 计算路块的位置
    local x, y
    if self.lastRoadPart then
        local lastPart = self.lastRoadPart
        local lastX, lastY = lastPart:getPosition()
        if lastPart.dir == DIR.UP then
            if dir == DIR.UP then
                x = lastX
                y = lastY + size.height
            elseif dir == DIR.RIGHT then
                x = lastX + size.width / 2 + size.height / 2
                y = lastY + size.height / 2 + size.width / 2
            elseif dir == DIR.LEFT then
                x = lastX - size.width / 2 - size.height / 2
                y = lastY + size.height / 2 + size.width / 2
            end
        elseif lastPart.dir == DIR.RIGHT then
            if dir == DIR.UP then
                x = lastX + size.width / 2 + size.height / 2
                y = lastY + size.width / 2 + size.height / 2
            elseif dir == DIR.RIGHT then
                x = lastX + size.height
                y = lastY
            end
        elseif lastPart.dir == DIR.LEFT then
            if dir == DIR.UP then
                x = lastX - size.width / 2 - size.height / 2
                y = lastY + size.width / 2 + size.height / 2
            elseif dir == DIR.LEFT then
                x = lastX - size.height
                y = lastY
            end
        end
    else
        -- 第一块路块的位置
        x = self.centerPos.x
        y = 0 -- size.height / 2
    end

    if x and y then
        if needSkip then
            local cSize = self.roadCicleSize
            local space = cSize.height * 2 + SKIP_BLOCK_SPACE
            if dir == DIR.UP then
                y = y + space
            elseif dir == DIR.RIGHT then
                x = x + space
            else
                x = x - space
            end

            self:creatOneCircleRoad(dir, img, true)
            self:creatOneCircleRoad(dir, self.lastRoadPart, false)
        end

        img:setPosition(x, y)
        img:setTag(self.lastRoadPart and (self.lastRoadPart:getTag() + 1) or 1)
        panel:addChild(img)

        if self.lastRoadPart and self.lastRoadPart.dir ~= dir then
            -- 创建方向图标
            self:creatOneTurnRoad(dir, self.lastRoadPart)
        end

        if self.lastRoadPart and not notCreatPeach then
            -- 创建桃子
            self:creatOnePeach(self.lastRoadPart.dir, self.lastRoadPart, needSkip)
        end

        self.lastRoadPart = img
        table.insert(self.roadPartQue, img)
    end
end

-- 创建一块半圆的跳板
function CaseRunGameDlg:creatOneCircleRoad(dir, panel, isFlip)
    local cSize = self.roadCicleSize
    local rSize = self.roadRectSize
    local rotation = 0
    local x = rSize.width / 2
    local y = - cSize.height / 2
    if not isFlip then
        x = rSize.width / 2
        y = cSize.height / 2 + rSize.height
        rotation = 180
    end

    local cell = self.roadCircleImg:clone()

    cell:setPosition(x, y)
    cell:setRotation(rotation)
    panel:addChild(cell)

    local dirImg = cell:getChildByName("DirImage")
    if not isFlip then
        dirImg.dir = dir
        dirImg.isSkip = true
        table.insert(self.dirImgQue, dirImg)
    else
        dirImg:removeFromParent()
    end
end

-- 创建一块转弯的道路
function CaseRunGameDlg:creatOneTurnRoad(dir, panel)
    local rSize = self.roadRectSize
    local cell = self.roadturnImg:clone()
    local isFlip = false
    if (panel.dir == DIR.UP and dir == DIR.RIGHT)
            or (panel.dir == DIR.LEFT and dir == DIR.UP) then
        isFlip = true
    end

    cell:setFlippedX(isFlip)
    cell:setPosition(rSize.width / 2, rSize.height + rSize.width / 2)
    panel:addChild(cell)

    local dirImg = cell:getChildByName("DirImage")
    dirImg.dir = dir
    dirImg.isSkip = false
    dirImg:setFlippedY(isFlip)
    table.insert(self.dirImgQue, dirImg)
end

-- 创建桃子
function CaseRunGameDlg:creatOnePeach(dir, panel, needSkip)
    if self.totalPeachNum * ONE_PEACH_SCORE >= MAX_SCORE then
        return
    end

    local rotation = 0

    if dir == DIR.RIGHT then
        rotation = -90
    elseif dir == DIR.LEFT then
        rotation = 90
    end

    local cou = needSkip and 1 or PEACH_NUM_PER_BLOCK
    for i = 1, cou do
        local img = ccui.ImageView:create(ResMgr:getSmallPortrait(ResMgr.icon.peach))
        local size = self.roadRectSize
        local x = size.width / 2
        local y = size.height / (PEACH_NUM_PER_BLOCK * 2) * (i * 2 - 1)

        img:setPosition(x, y)
        img:setScale(0.5)
        img:setRotation(rotation)
        panel:addChild(img, 1)

        img.dir = dir
        table.insert(self.peachQue, img)

        self.totalPeachNum = self.totalPeachNum + 1
        if self.totalPeachNum * ONE_PEACH_SCORE >= MAX_SCORE then
            img:setScale(1)
            return
        end
    end
end

function CaseRunGameDlg:creatMonkey()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.zhaitaozi_monkey.name)
    magic:setAnchorPoint(0.5, 0.65)
    magic:setPosition(self.centerPos.x, 80)

    self.showCharPanel:addChild(magic, 10)
    magic:getAnimation():play("Animation1", -1, 1)

    self.monkey = magic
end

function CaseRunGameDlg:getCurRoadPart(wPos)
    local size = self.roadRectSize
    for i = 1, #self.roadPartQue do
        local pos = self.roadPartQue[i]:convertToNodeSpace(wPos)
        if pos.x > 0 and pos.x <= size.width
            and pos.y > 0 and pos.y <= size.height then
            return self.roadPartQue[i]
        end
    end
end

function CaseRunGameDlg:showScore(score)
    local numImg = self:setNumImgForPanel("NumPanel", "bfight_num", score, false, LOCATE_POSITION.MID, 12.5, "ScorePanel")
    local size = numImg:getContentSize()
    local x, y = numImg:getPosition()
    local iconImg = self:getControl("IconImage", nil, "ScorePanel")
    iconImg:setPositionX(x + size.width / 2 * numImg:getScaleX() + 38)
end

 -- 检查是是否可摘到到桃子
function CaseRunGameDlg:checkGetPeach()
    local mx, my = self.monkey:getPosition()
    repeat
        if not self.peachQue[1] or self.peachQue[1].dir ~= self.curDir then
            break
        end

        local peach = self.peachQue[1]
        local peachWPos = peach:getParent():convertToWorldSpace(cc.p(peach:getPosition()))
        local peachPos = self.showCharPanel:convertToNodeSpace(peachWPos)
        local size = peach:getContentSize()
        local hasGet = false
        if self.curDir == DIR.UP then
            if peachPos.y <= my + size.height / 2 then hasGet = true end
        elseif self.curDir == DIR.RIGHT then
            if peachPos.x <= mx + size.height / 2 then hasGet = true end
        else
            if peachPos.x >= mx - size.height / 2 then hasGet = true end
        end

        if hasGet then
            table.remove(self.peachQue, 1)
            peach:removeFromParent()
            self.curScore = self.curScore + ONE_PEACH_SCORE

            self:showScore(self.curScore)

            if self.curScore >= MAX_SCORE then
                self:gameOver(self.curScore)
            elseif self.curScore > 0 and self.curScore <= 50 then
                self.curSpeed = INIT_SPEED + self.curScore * 2
			elseif self.curScore > 50 and self.curScore <= 150 then
                self.curSpeed = INIT_SPEED + 100 + ( self.curScore - 50 )
			elseif self.curScore > 150 and self.curScore <= 250 then
                self.curSpeed = INIT_SPEED + 200 + ( self.curScore - 150) / 2
			elseif self.curScore > 250 and self.curScore <= 400 then
                self.curSpeed = INIT_SPEED + 250 + ( self.curScore - 250) / 3
			elseif self.curScore > 400 and self.curScore <= 800 then
                self.curSpeed = INIT_SPEED + 300 + ( self.curScore - 400) / 5
            end
        else
            break
        end
    until false
end

function CaseRunGameDlg:getNextPos(x, y, dis)
    if #self.dirImgQue > 0 then
        -- 根据猴子位置计算跑道 panel 的位置
        local mx, my = self.monkey:getPosition()
        local dirImg = self.dirImgQue[1]
        local size = self.roadRectSize
        local wPos = dirImg:getParent():convertToWorldSpace(cc.p(dirImg:getPosition()))
        local pos = self.showCharPanel:convertToNodeSpace(wPos)
        local checkDir = false
        local isFaild = false
        local walkDisToFaild = nil

        if self.walkDisToFaild then
            -- 提前转弯或跳跃，需要走到撞墙的位置
            if self.walkDisToFaild - dis > 0 then
                self.walkDisToFaild = self.walkDisToFaild - dis
            else
                isFaild = true
                dis = self.walkDisToFaild
            end
        end

        if self.curDir == DIR.UP then
            if pos.y - dis <= my + DIR_RADIUS
                and pos.y - dis >= my - DIR_RADIUS
                and self.hasClick then
                -- 转弯或跳跃
                checkDir = true

                y = y - dis -- math.min(dis, math.max(pos.y - my, 0))
            elseif pos.y - dis <= my + CAN_TURN_RADIUS
                and pos.y - dis >= my - DIR_RADIUS
                and self.hasClick then
                -- 提前转弯或跳跃
                checkDir = true
                y = y - dis

                -- 提前转弯或跳跃，需要走到撞墙的位置
                if dirImg.dir == DIR.RIGHT then
                    walkDisToFaild = pos.x + DIR_RADIUS - mx
                elseif dirImg.dir == DIR.LEFT then
                    walkDisToFaild = mx - (pos.x - DIR_RADIUS)
                else
                    walkDisToFaild = SKIP_DIS
                end
            elseif pos.y - dis >= my - DIR_RADIUS then
                -- 直走
                y = y - dis
            else
                -- 撞墙
                y = y - math.min(dis, (-my + pos.y + size.width / 3))
                isFaild = true
            end

        elseif self.curDir == DIR.RIGHT then
            if pos.x - dis <= mx + DIR_RADIUS
                and pos.x - dis >= mx - DIR_RADIUS
                and self.hasClick then
                checkDir = true

                x = x - dis-- math.min(dis, math.max(pos.x - mx, 0))
            elseif pos.x - dis <= mx + CAN_TURN_RADIUS
                and pos.x - dis >= mx - DIR_RADIUS
                and self.hasClick then
                checkDir = true
                x = x - dis

                -- 提前转弯或跳跃，需要走到撞墙的位置
                if dirImg.dir == DIR.UP then
                    walkDisToFaild = pos.y + DIR_RADIUS - my
                else
                    walkDisToFaild = SKIP_DIS
                end
            elseif pos.x - dis >= mx - DIR_RADIUS then
                x = x - dis
            else
                x = x - math.min(dis, (-mx + pos.x + size.width / 3))
                isFaild = true
            end
        elseif self.curDir == DIR.LEFT  then
            if pos.x + dis >= mx - DIR_RADIUS
                and pos.x + dis <= mx + DIR_RADIUS
                and self.hasClick then
                checkDir = true

                x = x + dis-- math.min(dis, math.max(mx - pos.x, 0))
            elseif pos.x + dis >= mx - CAN_TURN_RADIUS
                and pos.x + dis <= mx + DIR_RADIUS
                and self.hasClick then
                checkDir = true
                x = x + dis

                -- 提前转弯或跳跃，需要走到撞墙的位置
                if dirImg.dir == DIR.UP then
                    walkDisToFaild = pos.y + DIR_RADIUS - my
                else
                    walkDisToFaild = SKIP_DIS
                end
            elseif pos.x + dis <= mx + DIR_RADIUS then
                x = x + dis
            else
                x = x + math.min(dis, mx - pos.x + size.width / 3)
                isFaild = true
            end
        end

        self.walkDisToFaild = self.walkDisToFaild or walkDisToFaild

        -- 检查摘桃子
        self:checkGetPeach()

        if isFaild then
            -- 撞墙
            local action = cc.Sequence:create(
                cc.Repeat:create(cc.Sequence:create(
                    cc.FadeIn:create(0.07),
                    cc.FadeOut:create(0.07)
                ), 3),

                cc.FadeIn:create(0.07),
                cc.CallFunc:create(function()
                    self:gameOver(self.curScore)
                end)
            )

            self.monkey:getAnimation():gotoAndPause(1)
            self.monkey:runAction(action)
            self.gameState = STATE.PAUSE
            return x, y, self.curDir
        elseif checkDir then
            table.remove(self.dirImgQue, 1)
            dirImg:setColor(COLOR3.WHITE)

            if #self.dirImgQue > 0 then
                self.curDir = dirImg.dir or self.curDir
                self.monkey:setRotation(self:getRotationByDir(self.curDir))
            end

            if dirImg.isSkip then
                -- 播放跳跃动画
                local time = (SKIP_DIS / self.curSpeed) / 2
                local action = cc.Sequence:create(
                    cc.ScaleTo:create(time, 1.5, 1.5),
                    cc.ScaleTo:create(time, 1, 1)
                )

                performWithDelay(self.monkey, function()
                    self.monkey:getAnimation():play("Animation1", -1, 1)
                end, time * 2 - 0.1)

                self.monkey:getAnimation():gotoAndPause(0)
                self.monkey:runAction(action)
            end
        else
            -- 直走
            dirImg:setColor(COLOR3.RED)
        end

        local part = self:getCurRoadPart(self.showCharPanel:convertToWorldSpace(cc.p(mx, my)))
        if part then
            local tag = part:getTag()
            -- 移除已经左远的路块
            repeat
                if not self.roadPartQue[1] then
                    break
                end

                if self.roadPartQue[1]:getTag() < tag - 10 then
                    self.roadPartQue[1]:removeFromParent()
                    table.remove(self.roadPartQue, 1)
                else
                    break
                end
            until false

            -- 添加新的路块
            local maxTag = self.lastRoadPart:getTag()
            for i = maxTag, tag + 10 do
                self:creatOneRoad()
            end
        end

        self.hasClick = false
    end

    return x, y, self.curDir
end

function CaseRunGameDlg:setNextPosByDis(dis)
    local x, y = self.monkey:getPosition()
    if y < self.centerPos.y then
        -- 移动猴子
        y = y + dis
        self.monkey:setPositionY(y)

        if y > self.centerPos.y then
            self.monkey:setPositionY(self.centerPos.y)
            self:setNextPosByDis(y - self.centerPos.y)
        else
            self.monkey:setPositionY(y)

            -- 检查摘桃子
            self:checkGetPeach()
        end
    else
        -- 移动道路
        local rx, ry = self.showRoadPanel:getPosition()

        rx, ry = self:getNextPos(rx, ry, dis)
        self.showRoadPanel:setPosition(rx, ry)
    end
end

-- 中途退出传入 -1
function CaseRunGameDlg:gameOver(score)
    self.gameState = STATE.STOP
    gf:CmdToServer("CMD_TWZM_QUIT_PICK_PEACH", {score = score})
end

function CaseRunGameDlg:onUpdate(delayTime)
    if self.gameState ~= STATE.RUNING then
        return
    end

    local dis = self.curSpeed * delayTime
    self:setNextPosByDis(dis)
end

function CaseRunGameDlg:MSG_TWZM_START_PICK_PEACH(data)
    if data.flag == 1 then
        self.gameState = STATE.RUNING
        self:setCtrlVisible("StarPanel", false)
    end
end

function CaseRunGameDlg:MSG_TWZM_QUIT_PICK_PEACH(data)
    if data.flag == 1 then
        DlgMgr:closeDlg(self.name)
    end
end

function CaseRunGameDlg:cleanup(data)
    if self.gameState ~= STATE.STOP then
        self:gameOver(-1)
    end

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil
end

return CaseRunGameDlg
