-- ChildBirthDlg.lua
-- Created by songcw Mar/02/2019
-- 娃娃生成界面

local ChildBirthDlg = Singleton("ChildBirthDlg", Dialog)

local TIME_MAX_FOR_TE = 1200     -- 胎儿最大15分钟
local TIME_MAX_FOR_LS = 900    -- 灵石最大20分钟

local DIR_LEFT = 0
local DIR_RIGHT = 1
local MAX_LEN = nil

local LEVEL_1 = 3           -- 等级1的移动像素速度
local LEVEL_2 = 5           -- 等级2的移动像素速度
local PULL_SPEED = 7       -- 拖动速度

local FLOAT_TIME = 1       -- 每隔 x 帧，坐标浮动一下
local FLOAT_DIS = 3         -- 每隔 x 帧，坐标浮动一下 -+ N

local TURN_AROUND_MIX = 3   -- 间隔 n 到 m 秒随机一个时间，掉头。
local TURN_AROUND_MAX = 6   -- 间隔 n 到 m 秒随机一个时间，掉头。


local WIDTH_FOR_COLOR = 62

local LEVEL_IMAGE = {
    ResMgr.ui.ChildBirthDlgGreen,
    ResMgr.ui.ChildBirthDlgYellow,
    ResMgr.ui.ChildBirthDlgBrown,
    ResMgr.ui.ChildBirthDlgRed,
}


local STATISTICS_TIME = {
    [LEVEL_1 * 10 + HomeChildMgr.CHILD_TYPE.FETUS] = 8,
    [LEVEL_2 * 10 + HomeChildMgr.CHILD_TYPE.FETUS] = 5,
    [LEVEL_1 * 10 + HomeChildMgr.CHILD_TYPE.STONE] = 4,
    [LEVEL_2 * 10 + HomeChildMgr.CHILD_TYPE.STONE] = 3,
}

function ChildBirthDlg:init(data)
    self:bindListener("ChatButton", self.onChatButton)

    -- 绑定拉扯按钮
    local function onLeftButton(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.pullDir = DIR_LEFT
        elseif eventType == ccui.TouchEventType.ended then
            if self.pullDir == DIR_LEFT then self.pullDir = nil end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.pullDir == DIR_LEFT then self.pullDir = nil end
        end
    end

    local function onRightButton(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.pullDir = DIR_RIGHT
        elseif eventType == ccui.TouchEventType.ended then
            if self.pullDir == DIR_RIGHT then self.pullDir = nil end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.pullDir == DIR_RIGHT then self.pullDir = nil end
        end
    end

    self:getControl("LeftButton"):addTouchEventListener(onLeftButton)
    self:getControl("RightButton"):addTouchEventListener(onRightButton)

    self.floatPanel = self:retainCtrl("AddPanel")

    self.flagImage = self:getControl("Image_218")
    self.flagImage:setPositionX(0)

    MAX_LEN = self:getControl("ColorPanel"):getContentSize().width

    self.isRunning = false
    self.dir = nil
    self.endTime = 0
    self.pullDir = nil
    self.tickCount = 0
    self.lastChangeColorTime = nil
    self.data = data
    self.chatEffect = 0

    -- 初始化颜色
    self.dis = LEVEL_1

    self:setCtrlVisible("BabyTipsPanel", data.stage == HomeChildMgr.CHILD_TYPE.FETUS)
    self:setCtrlVisible("StoneTipsPanel", data.stage == HomeChildMgr.CHILD_TYPE.STONE)

    if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        if math.abs( data.endTime - gf:getServerTime() - TIME_MAX_FOR_TE) > 4 then
            self.curBestPos = self:randomColor(1, true)
        else
            self.curBestPos = self:randomColor(1)
        end
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        if math.abs( data.endTime - gf:getServerTime() -  TIME_MAX_FOR_LS) > 4 then
            self.curBestPos = self:randomColor(1, true)
        else
            self.curBestPos = self:randomColor(1)
        end
    end

    self:randomColor(1, true)

    self:setData(data)

    self:setCtrlVisible("ChatButton", data.isShowChatButton == 1)
   -- self:setCtrlVisible("ChatButton", true)

    self:resetRun()

    self:hookMsg("MSG_CHILD_BIRTH_INFO")
end

function ChildBirthDlg:onUpdate(delayTime)
    if not self.isRunning then return end
    if not self.dir then return end
    if not self.dis then return end

    local x = self.flagImage:getPositionX()

    local temp = 0
    local float = 0
    self.tickCount = self.tickCount + 1
    if self.tickCount % FLOAT_TIME == 0 then
        float = math.random( -FLOAT_DIS, FLOAT_DIS )
    end

    if self.dir == DIR_LEFT then
        if self.pullDir == DIR_RIGHT then
            temp = PULL_SPEED
        elseif self.pullDir == DIR_LEFT then
            temp = -PULL_SPEED
        end
        x = x - self.dis + temp + float
    elseif self.dir == DIR_RIGHT then
        if self.pullDir == DIR_LEFT then
             temp = PULL_SPEED
        elseif self.pullDir == DIR_RIGHT then
            temp = -PULL_SPEED
        end
        x = x + self.dis - temp + float
    end
    if x >= MAX_LEN then
        x = MAX_LEN
        self.dir = DIR_LEFT
    elseif x <= 0 then
        x = 0
        self.dir = DIR_RIGHT
    end

    self.flagImage:setPositionX(x)
end

function ChildBirthDlg:resetRun()
    self.dir = DIR_LEFT
    self.isRunning = true
end

function ChildBirthDlg:randomColor(dest, notTips)
    local ret = dest or math.random(2, 4)

    for i = 1, 4 do
        local idx = math.abs( i - ret ) + 1
        local image = self:setImage("Block_" .. i, LEVEL_IMAGE[idx], "ColorPanel")
        image.level = i - ret
        image:setFlippedX(image.level > 0)
    end

    if self.data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        if not notTips then
            gf:ShowSmallTips(CHS[4010419])  -- -- 你感受到灵胎的一阵灵气异动。
            gf:CmdToServer("CMD_CHILD_BIRTH_ADD_LOG", {birth_log = CHS[4010420]})       -- 感受到了胎动
        end

    else
        if self.dis == LEVEL_2 then
            if not notTips then
                gf:ShowSmallTips(CHS[4010419])  -- 你感受到灵胎的一阵灵气异动。
                gf:CmdToServer("CMD_CHILD_BIRTH_ADD_LOG", {birth_log = CHS[4010421]})   -- 灵气充盈，正适合雕琢
            end
        elseif self.dis == LEVEL_1 then
            if not notTips then
                gf:ShowSmallTips(CHS[4010422]) -- 你感受到灵胎的灵气波动似乎有所放缓。
                gf:CmdToServer("CMD_CHILD_BIRTH_ADD_LOG", {birth_log = CHS[4010423]})
            end
        end
    end

    return ret
end


function ChildBirthDlg:setData(data)
    self.data = data

    if data.endTime < gf:getServerTime() then return end    -- 不可能，容错下

    -- 标题
    self:setCtrlVisible("BabyTitleLabel", data.stage == HomeChildMgr.CHILD_TYPE.FETUS)
    self:setCtrlVisible("StoneTitleLabel", data.stage ~= HomeChildMgr.CHILD_TYPE.FETUS)

    -- 生产进度
    self:setLabelText("ExpvalueLabel", string.format( "%d/100", data.process))
    self:setLabelText("ExpvalueLabel2", string.format( "%d/100", data.process))
    self:setProgressBar("ProgressBar", data.process, 100)

    -- 界面倒计时
    self:setHourglass(data)

    -- 设置生产信息
    self:setInformation(data)

    -- 提示信息
    self:setCtrlVisible("BabyTipsLabel", data.stage == HomeChildMgr.CHILD_TYPE.FETUS)
    self:setCtrlVisible("StoneTipsLabel", data.stage == HomeChildMgr.CHILD_TYPE.STONE)
end

-- 设置生产信息
function ChildBirthDlg:setInformation(data)
    self:setCtrlVisible("BabyInformationPanel", data.stage == HomeChildMgr.CHILD_TYPE.FETUS)
    self:setCtrlVisible("StoneInformationPanel", data.stage == HomeChildMgr.CHILD_TYPE.STONE)

    local panel = data.stage == HomeChildMgr.CHILD_TYPE.STONE and self:getControl("StoneInformationPanel") or self:getControl("BabyInformationPanel")

    if data.count == 2 then
        local ret = {}
        for i = data.count, 1, -1 do
            table.insert( ret, data.productionInfo[i] )
        end

        data.productionInfo = ret
    end

    for i = 1, 2 do
        local contentPanel = self:getControl("Panel_" .. i, nil, panel)

        if data.productionInfo[i] then
            self:setColorText(data.productionInfo[i].content, contentPanel, nil, 0, 0, COLOR3.TEXT_DEFAULT, 17)
            self:setCtrlVisible("OneLabel" .. i, false, panel)
            --self:setLabelText("OneLabel" .. i, data.productionInfo[i].content, panel)

            -- 判断是否需要光效
            if data.productionInfo[i].isEffect == 1 and self.chatEffect == 0 then
                self.chatEffect = 1
                local btn = self:getControl("ChatButton")
                local effect = btn:getChildByTag(ResMgr.magic.world_chat_under_arrow)
                if not effect then
                    local effect = gf:createLoopMagic(ResMgr.magic.world_chat_under_arrow)
                    local btnSize = btn:getContentSize()
                    effect:setPosition(btnSize.width / 2, btnSize.height / 2 + 4)
                    effect:setContentSize(btn:getContentSize())
                    btn:addChild(effect, 1, ResMgr.magic.world_chat_under_arrow)
                end
            end
        else
            self:setColorText("", contentPanel, nil, 0, 0, COLOR3.TEXT_DEFAULT, 17)
            self:setCtrlVisible("OneLabel" .. i, false, panel)
        end
    end
end

-- 显示字符串
function ChildBirthDlg:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, locate, isPunct, isVip)
    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    if not panel then return end
    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, isVip)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    if locate == true or locate == LOCATE_POSITION.MID_BOTTOM then
        textCtrl:setPosition((size.width - textW) / 2, textH + marginY)
    elseif locate == LOCATE_POSITION.RIGHT_BOTTOM then
        textCtrl:setPosition(size.width - textW, textH + marginY)
    else
        textCtrl:setPosition(marginX, textH + marginY)
    end

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)
    local panelHeight = textH + 2 * marginY

    return panelHeight, size.height
end

function ChildBirthDlg:hourglassCallBack()
    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
        gf:CmdToServer("CMD_CHILD_BIRTH_FINISH")
    end
end

function ChildBirthDlg:setHourglass(data)
    -- 若已经开始定时器了，直接返回
    if self.timerId then return end


    local endTime = 0  -- 为了表现好，如果离最大结束时间误差在5s内，以客户端为准，否则以服务器为准
    if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        if math.abs( data.endTime - gf:getServerTime() - TIME_MAX_FOR_TE) > 5 then
            endTime = data.endTime
            self.lastChangeColorTime = nil
        else
            endTime = gf:getServerTime() + TIME_MAX_FOR_TE
            self.lastChangeColorTime = endTime - gf:getServerTime() - 3
        end
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        if math.abs( data.endTime - gf:getServerTime() -  TIME_MAX_FOR_LS) > 5 then
            endTime = data.endTime
            self.lastChangeColorTime = nil
        else
            endTime = gf:getServerTime() + TIME_MAX_FOR_LS
            self.lastChangeColorTime = endTime - gf:getServerTime() - 3
        end
    end

    self.endTime = endTime


    local function setTime(ti)
        ti = math.max(ti, 0)
        local m = math.floor( ti / 60 )
        local s = ti % 60
        self:setLabelText("TimeLabel", string.format( "%02d分%02d秒", m, s))
    end

    -- 开始180s倒计时
    local elapse = 0

    -- 设置倒计时
    setTime(endTime - gf:getServerTime())

    self.timerId = gf:Schedule(function()
        local leftTime = endTime - gf:getServerTime()
        setTime(leftTime)

        if leftTime <= 0 then
            self:hourglassCallBack()
        end

        -- 检测是否需要变色
        if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
            -- 胎儿
            if not self.lastChangeColorTime or math.floor( self.lastChangeColorTime / 60 ) ~= math.floor( leftTime / 60 ) then

                if math.floor( leftTime / 60 ) % 2 == 0 then
                    self.dis = LEVEL_2
                else
                    self.dis = LEVEL_1
                end

                if math.floor( leftTime / 60 ) % 2 == 0 then
                    self.curBestPos = self:randomColor()
                else
                    self.curBestPos = self:randomColor(1)
                end
                self.lastChangeColorTime = leftTime
            end
        elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
            -- 灵石
            if not self.lastChangeColorTime or math.floor( self.lastChangeColorTime / 30 ) ~= math.floor( leftTime / 30 ) then
                if math.floor( leftTime / 30 ) % 2 == 0 then
                    self.dis = LEVEL_2

                else
                    self.dis = LEVEL_1

                end

                if math.floor( leftTime / 30 ) % 2 == 0 then
                    self.curBestPos = self:randomColor()
                else
                    self.curBestPos = self:randomColor(1)
                end
                self.lastChangeColorTime = leftTime
            end
        end

        -- 定时统计
        local level = self.dis
        local marginTime = STATISTICS_TIME[level * 10 + data.stage]

        if leftTime % marginTime == 0 then
            local x = self.flagImage:getPositionX()
            if marginTime == 4 or marginTime == 8 then
                if x >= (self.curBestPos - 1) * WIDTH_FOR_COLOR and x < self.curBestPos * WIDTH_FOR_COLOR then
                    --gf:ShowSmallTips("生产进度+1")

                    self:creatFloatAdd(1, x)

                    gf:CmdToServer("CMD_CHILD_BIRTH_ADD_PROGRESS", {process = 1})
                end
            else
                if x >= (self.curBestPos - 1) * WIDTH_FOR_COLOR and x < self.curBestPos * WIDTH_FOR_COLOR then
                    --gf:ShowSmallTips("生产进度+2")
                    self:creatFloatAdd(2, x)
                    gf:CmdToServer("CMD_CHILD_BIRTH_ADD_PROGRESS", {process = 2})
                elseif math.abs( x - ((self.curBestPos - 1) * WIDTH_FOR_COLOR + WIDTH_FOR_COLOR * 0.5)) <= WIDTH_FOR_COLOR * 1.5  then
                    --gf:ShowSmallTips("生产进度+1")
                    self:creatFloatAdd(1, x)
                    gf:CmdToServer("CMD_CHILD_BIRTH_ADD_PROGRESS", {process = 1})
                end
            end
        end

        -- 策划要求，每隔 n 到 m秒反向一次
        if not self.nextTurnAround then
            self.nextTurnAround = gf:getServerTime() + math.random( TURN_AROUND_MIX, TURN_AROUND_MAX )
        end

        --
        -- 掉头
        if self.nextTurnAround <= gf:getServerTime() then
            self.nextTurnAround = gf:getServerTime() + math.random( TURN_AROUND_MIX, TURN_AROUND_MAX )
            self.dir = self.dir == DIR_LEFT and DIR_RIGHT or DIR_LEFT
            --gf:ShowSmallTips("掉头了")
        end
        --]]

    end, 1)
end

function ChildBirthDlg:creatFloatAdd(num, x)
    local panel = self.floatPanel:clone()
    local sp = cc.Sprite:create("ui/AtlasLabel0001.png", cc.rect(num * 22, 0, 22, 30))
  --  local panel = self:getControl("AddPanel")
    sp:setPosition(cc.p(34, 12))
    panel:setPositionX(x)
    panel:addChild(sp)
    self:getControl("ColorPanel"):addChild(panel)

    local move = cc.MoveBy:create(1, cc.p(0, 80))
    local func = cc.CallFunc:create(function()
        panel:removeFromParent()
    end)
    panel:runAction(cc.Sequence:create(move, func))
end

function ChildBirthDlg:getLevel()
    return LEVEL_2
end

function ChildBirthDlg:cleanup()
    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end

    Me:setVisible(true)
end

function ChildBirthDlg:onChatButton(sender, eventType)

    local effect = sender:getChildByTag(ResMgr.magic.world_chat_under_arrow)
    if effect then
        effect:removeFromParent()
    end

    local user = MarryMgr:getLoverInfo()
    FriendMgr:communicat(user.name, user.gid, user.icon)
end

function ChildBirthDlg:MSG_CHILD_BIRTH_INFO(data)
    self:setData(data)
end

return ChildBirthDlg
