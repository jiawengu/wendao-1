-- ControlDlg.lua
-- Created by huangzz Apr/10/2018
-- 暑假-寒气之脉 控制方向界面

local ControlDlg = Singleton("ControlDlg", Dialog)

local LAST_POS_NO = {
    [CHS[4100249]] = 18,
    [CHS[7002263]] = 36,
}

-- 配表起始点
local START_POS = {
    x = 38,
    y = 22,
}

local NO_TO_POS = {
    [1]  = {x = 36, y = 25},
    [2]  = {x = 38, y = 24},
    [3]  = {x = 40, y = 23},
    [4]  = {x = 42, y = 22},
    [5]  = {x = 44, y = 21},
    [6]  = {x = 38, y = 26},
    [7]  = {x = 40, y = 25},
    [8]  = {x = 42, y = 24},
    [9]  = {x = 44, y = 23},
    [10] = {x = 46, y = 22},
    [11] = {x = 40, y = 27},
    [12] = {x = 42, y = 26},
    [13] = {x = 44, y = 25},
    [14] = {x = 46, y = 24},
    [15] = {x = 48, y = 23},
    [16] = {x = 42, y = 28},
    [17] = {x = 44, y = 27},
    [18] = {x = 46, y = 26},
    [19] = {x = 48, y = 25},
    [20] = {x = 50, y = 24},
    [21] = {x = 44, y = 29},
    [22] = {x = 46, y = 28},
    [23] = {x = 48, y = 27},
    [24] = {x = 50, y = 26},
    [25] = {x = 52, y = 25},
}

local WALL_NO = {
    1, 2, 3, 4, 5, 5, 10, 15, 20, 25, 25, 24, 23, 22, 21, 21, 16, 11, 6, 1}

local lastPosNo
local pos2No = {}

local MAX_ROW = 6   -- 寒气之脉轨迹列数

function ControlDlg:init(para)
    self:setFullScreen()

    self:bindListener("UpButton", self.onRightUpButton)
    self:bindListener("DownButton", self.onLeftDownButton)
    self:bindListener("LeftButton", self.onLeftUpButton)
    self:bindListener("RightButton", self.onRightDownButton)
    self:bindListener("TouchPanel", self.onTouchPanel)

    -- 设置点击层的大小
    local winSize = cc.Director:getInstance():getWinSize()
    self:getControl("TouchPanel"):setContentSize(winSize.width / Const.UI_SCALE, winSize.width / Const.UI_SCALE + self:getWinSize().oy * 2)

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self.grids = {}
    self.walls = {}
    self.isDuringDemo = true   -- 是否处于演示阶段
    self.canMove = true        -- 是否可移动
    self.curStep = 0           -- 当前走在轨迹中的第几步
    self.pathHasNo = {}        -- 编号是否在轨迹上
    self.path = para.path

    self.curPos = gf:deepCopy(START_POS)  -- 玩家初始位置

    -- 创建坐标点到轨迹编号的映射
    pos2No = {}
    for i = 1, #NO_TO_POS do
        if not pos2No[NO_TO_POS[i].x] then
            pos2No[NO_TO_POS[i].x] = {}
        end

        pos2No[NO_TO_POS[i].x][NO_TO_POS[i].y] = i
    end

    self:startDemo(para)

    Me:absorbBasicFields({
        notShowRidePet = 1,
        notShowHunfu = 1
    })

    self:hookMsg("MSG_SUMMER_2018_HQZM_END")
end

function ControlDlg:getNoMap()
    return NO_TO_POS
end

function ControlDlg:setNoMap(map)
    NO_TO_POS = map
end

function ControlDlg:onUpdate()
    if self.gotoNo and Me:isStandAction() then
        local no = self.gotoNo
        if self.grids[no] then
            -- 踩在格子上
            self.curStep = self.curStep + 1
            if self.pathHasNo[no] == self.curStep then
                -- 踩对了,播放寒气光效并移除格子
                self.pathHasNo[no] = nil
                self:createArmature(no, "Top01")
                self:createArmature(no, "Bottom01", function()
                    if self.grids and self.grids[no] then
                        self.grids[no]:removeFromParent()
                        self.grids[no] = nil
                    end
                end)

                self.canMove = true
            else
                -- 踩错了 MSG_SUMMER_2018_HQZM_END 中处理
            end

            gf:CmdToServer("CMD_SUMMER_2018_HQZM_INDEX", {no = no})
        else
            -- self.canMove = true
            gf:CmdToServer("CMD_SUMMER_2018_HQZM_INDEX", {no = 0})
        end

        self.gotoNo = nil
    end
end

function ControlDlg:createArmature(no, action, callback)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.summer_hqzm.name)
    local pos = NO_TO_POS[no]
    local x, y = gf:convertToClientSpace(pos.x, pos.y)
    magic:setPosition(x, y)
    magic:setAnchorPoint(0.5, 0.5)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent()

            if callback then
                callback()
            end
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(action, -1, 0)

    if action == "Top01" then
        local charLayer = gf:getCharTopLayer()
        if charLayer then
            charLayer:addChild(magic)
        end
    else
        local mapLayer = gf:getMapEffectLayer()
        if mapLayer then
            mapLayer:addChild(magic)
        end
    end

    return magic
end

-- 创建格子
function ControlDlg:creatGrid(no, hasAction)
    if self.grids[no] then
        return
    end

    local pos = NO_TO_POS[no]
    local x, y = gf:convertToClientSpace(pos.x, pos.y)

    local icon = ResMgr.ui.hqzm_grid_white
    if no % 2 == 0 then
        -- 深色格子
        icon = ResMgr.ui.hqzm_grid_dark
    end

    local img = ccui.ImageView:create(icon)
    img:setPosition(x, y)

    -- 0.3s 淡入效果
    if hasAction then
        img:setOpacity(0)
        local action = cc.FadeIn:create(0.3)
        img:runAction(action)
    end

    local mapLayer = gf:getMapEffectLayer()
    if mapLayer then
        mapLayer:addChild(img)
        self.grids[no] = img
    end
end

-- 创建寒气之脉光效
function ControlDlg:creatMagic(no)
    self:createArmature(no, "Top01")
    self:createArmature(no, "Bottom01")
end

-- 创建围墙
function ControlDlg:creatWalls()
    for i = 1, #WALL_NO do
        local img
        if i  <= 5 then
            img = ccui.ImageView:create(ResMgr.ui.hqzm_wall1)
            img:setFlippedX(true)
        elseif i <= 10 then
            img = ccui.ImageView:create(ResMgr.ui.hqzm_wall1)
        elseif i <= 15 then
            img = ccui.ImageView:create(ResMgr.ui.hqzm_wall2)
        else
            img = ccui.ImageView:create(ResMgr.ui.hqzm_wall2)
            img:setFlippedX(true)
        end

        local pos = NO_TO_POS[WALL_NO[i]]
        local x, y = gf:convertToClientSpace(pos.x, pos.y)
        img:setPosition(x, y)
        local mapLayer = gf:getMapEffectLayer()
        if mapLayer then
            mapLayer:addChild(img)
            self.walls[i] = img
        end
    end
end

-- 开始演示寒气之脉的轨迹
function ControlDlg:startDemo()
    if not self.path then
        return
    end

    local cou = 1
    self.scheduleId = self:startSchedule(function()
        if not self.path[cou] then
            self:stopSchedule(self.scheduleId)
            self.scheduleId = nil
            self:showAllMagic()
            return
        end

        self:creatMagic(self.path[cou])
        self:creatGrid(self.path[cou])
        self.pathHasNo[self.path[cou]] = cou

        cou = cou + 1
    end, 0.3)
end

-- 显示所有的寒气之脉光效
function ControlDlg:showAllMagic()
    -- 40s 后游戏结束
    performWithDelay(self.root, function()
        gf:CmdToServer("CMD_SUMMER_2018_HQZM_GAME_END", {type = 1})
    end, 40)

    -- 创建围墙
    self:creatWalls()

    self.isDuringDemo = false

    for i = 1, #NO_TO_POS do
        self:creatGrid(i, true)
    end
end

function ControlDlg:cleanup()
    if self.grids then
        for _, v in pairs(self.grids) do
            v:removeFromParent()
        end
    end

    self.grids = nil

    if self.walls then
        for _, v in pairs(self.walls) do
            v:removeFromParent()
        end
    end

    self.walls = nil

    self:stopSchedule(self.scheduleId)
    self.scheduleId = nil


    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    Me:absorbBasicFields({
        notShowRidePet = 0,
        notShowHunfu = 0
    })
end

function ControlDlg:checkPos(pos)
    self.canMove = false
    if not pos2No[pos.x] or not pos2No[pos.x][pos.y] then
        self.gotoNo = 0
    else
        self.gotoNo = pos2No[pos.x][pos.y]
    end
end

function ControlDlg:checkCanMove(x, y)
    if not self.canMove then
       return
    end

    if GObstacle:Instance():IsObstacle(x, y) then
        return
    end

    if self.isDuringDemo then
        gf:ShowSmallTips(CHS[5450140])
        return
    end

    return true
end

function ControlDlg:onTouchPanel(sender, eventType)
    if self.isDuringDemo then
        gf:ShowSmallTips(CHS[5450140])
    end
end

function ControlDlg:onRightUpButton(sender, eventType)
    if not self:checkCanMove(self.curPos.x + 2, self.curPos.y - 1) then
        return
    end

    self.curPos.x = self.curPos.x + 2
    self.curPos.y = self.curPos.y - 1

    Me:setEndPos(self.curPos.x, self.curPos.y)
    self:checkPos(self.curPos)
end

function ControlDlg:onLeftDownButton(sender, eventType)
    if not self:checkCanMove(self.curPos.x - 2, self.curPos.y + 1) then
        return
    end

    self.curPos.x = self.curPos.x - 2
    self.curPos.y = self.curPos.y + 1

    Me:setEndPos(self.curPos.x, self.curPos.y)
    self:checkPos(self.curPos)
end

function ControlDlg:onLeftUpButton(sender, eventType)
    if not self:checkCanMove(self.curPos.x - 2, self.curPos.y - 1) then
        return
    end

    self.curPos.x = self.curPos.x - 2
    self.curPos.y = self.curPos.y - 1

    Me:setEndPos(self.curPos.x, self.curPos.y)
    self:checkPos(self.curPos)
end

function ControlDlg:onRightDownButton(sender, eventType)
    if not self:checkCanMove(self.curPos.x + 2, self.curPos.y + 1) then
        return
    end

    self.curPos.x = self.curPos.x + 2
    self.curPos.y = self.curPos.y + 1

    Me:setEndPos(self.curPos.x, self.curPos.y)
    self:checkPos(self.curPos)
end

function ControlDlg:onCloseButton(sender, eventType)
    gf:confirm(CHS[5450159], function()
        gf:CmdToServer("CMD_SUMMER_2018_HQZM_GAME_END", {type = 2})
    end)
end

function ControlDlg:MSG_SUMMER_2018_HQZM_END(data)
    if data.flag == 1 then
        -- 踩错
        CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.tj_han_bing, charId = Me:getId()})
        Me:setAct(Const.FA_PARRY_START, true, function()
            performWithDelay(self.root, function()
                Me:setAct(Const.FA_STAND)
            end, 0.2)

            performWithDelay(self.root, function()
                DlgMgr:closeDlg("ControlDlg")
            end, 1)
        end)
    else
        DlgMgr:closeDlg("ControlDlg")
    end
end

return ControlDlg
