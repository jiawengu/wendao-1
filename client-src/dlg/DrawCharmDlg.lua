-- DrawCharmDlg.lua
-- Created by sujl, Jul/21/2017
-- 金光神咒界面

local DrawCharmDlg = Singleton("DrawCharmDlg", Dialog)
local CHECK_POINT_COUNT = 4
local SPEC_CHECK_POINT = { 5, 6, 7 }

function DrawCharmDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("RepateButton", self.onRepateButton)

    self:bindImage("FramePanel_2", "CharmPanel")

    self:hookMsg("MSG_ENTER_ROOM")
    self:hookMsg("MSG_SWITCH_SERVER")
    self:hookMsg("MSG_SWITCH_SERVER_EX")
    self:hookMsg("MSG_SPECIAL_SWITCH_SERVER")
    self:hookMsg("MSG_SPECIAL_SWITCH_SERVER_EX")
    self:hookMsg("MSG_UPDATE_TEAM_LIST")

    self:setFullScreen()

    local char = CharMgr:getNpcByName(CHS[2100115])
    if char then
        self.npc_id = char:getId()
    end

    local magicPanel = self:getControl("MagicPanel", nil, "CharmPanel")
    self:setCtrlVisible("FramePanel_2", false, "CharmPanel")
    self:creatMagic(magicPanel, ResMgr.ArmatureMagic.jinguangfu.name, "Top01", function()
        self:setCtrlVisible("FramePanel_2", true, "CharmPanel")
        self:creatMagic(magicPanel, ResMgr.ArmatureMagic.jinguangfu.name, "Top02")
        self:startIdleShow(0)
    end)

    self:setButtonVisble(false)
    self:checkDramaDlgVisible()
end

function DrawCharmDlg:cleanup()
    self.drawIndex = nil
    self.npc_id = nil

    DlgMgr:setAllDlgVisible(true)
    ChatMgr:hideAdnotice(false)
end

function DrawCharmDlg:checkDramaDlgVisible()
    if DlgMgr:isDlgOpened("DramaDlg") then
        self:setVisible(false)
        performWithDelay(self.root, function()
            self:checkDramaDlgVisible()
        end, 0)
    else
        DlgMgr:setAllDlgVisible(false)
        self:setVisible(true)
        ChatMgr:hideAdnotice(true)
    end
end

-- 开始循环动画
function DrawCharmDlg:startIdleShow(delay)
    self:stopIdleShow()
    local magicPanel = self:getControl("MagicPanel", nil, "CharmPanel")
    local magic  = magicPanel:getChildByName("Top03")
    if magic then
        magic:removeFromParent()
    end

    self.idleShowAction = performWithDelay(self.root, function()
        self:creatMagic(magicPanel, ResMgr.ArmatureMagic.jinguangfu.name, "Top03", function()
            self:startIdleShow()
        end)
    end, delay or 5)
end

-- 停止循环动画
function DrawCharmDlg:stopIdleShow()
    local magicPanel = self:getControl("MagicPanel", nil, "CharmPanel")
    local magic  = magicPanel:getChildByName("Top03")
    if magic then
        magic:removeFromParent()
    end

    if self.idleShowAction then
        self.root:stopAction(self.idleShowAction)
        self.idleShowAction = nil
    end
end

-- 更新
function DrawCharmDlg:onUpdate()
    if not CharMgr:getChar(self.npc_id) then
        -- 远离NPC了
        self:onCloseButton()
    end
end

function DrawCharmDlg:isPad()
    return DeviceMgr:isAndroidPad() or cc.PLATFORM_OS_IPAD == cc.Application:getInstance():getTargetPlatform()
end

-- 绑定绘制时间
function DrawCharmDlg:bindImage(name, root)
    local widget = self:getControl(name, nil, root)
    if not widget then
        Log:W("DrawCharmDlg:bindImage no control " .. name)
        return
    end

    local size = widget:getContentSize()

    if self:isPad() then
        widget:setContentSize(size.width, 650)
    else
        widget:setContentSize(size.width, 522)
    end

    -- 检查点是否在有效范围内
    local function containsTouchPos(point)
        local pos = widget:getParent():convertToNodeSpace(point)
        local rect = widget:getBoundingBox()
        return cc.rectContainsPoint(rect, pos)
    end

    local lastPos, curPos
    local isOper
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if not self.drawIndex or 0 == self.drawIndex then
                -- 满足开始画的条件, self.drawIndex > 0 说明已经绘制完成唠嗑
                self.drawIndex = 1
                isOper = true
                self.isInvalid = false
                self.checkSpecPoint = nil
                lastPos = widget:convertToNodeSpace(GameMgr.curTouchPos)
            end

            self:stopIdleShow()
        elseif eventType == ccui.TouchEventType.moved then
            if not isOper then
                return
            end
            if not containsTouchPos(GameMgr.curTouchPos) then
                self.drawIndex = 0
                return
            end

            curPos = widget:convertToNodeSpace(GameMgr.curTouchPos)
            widget:addChild(gf:drawLine(6, cc.c4f(117 / 255, 31 / 255, 1 / 255, 1), lastPos, curPos))
            lastPos = curPos
            local state = self:checkDrawIndex(self.drawIndex, GameMgr.curTouchPos)
            if 1 == state and self.drawIndex > 0 then
                self.drawIndex = self.drawIndex + 1
            elseif 2 == state then
                self.drawIndex = 0
            end
        else
            if self.drawIndex <= CHECK_POINT_COUNT then
                self:resetPaint()
                gf:ShowSmallTips(CHS[2000364])
                self:startIdleShow()
            else
                self:setButtonVisble(true)
            end
            isOper = nil
        end
    end

    widget:addTouchEventListener(listener)
end

-- 设置操作按钮可见性
function DrawCharmDlg:setButtonVisble(visible)
    self:setCtrlVisible("RepateButton", visible, "MainBodyPanel")
    self:setCtrlVisible("SubmitButton", visible, "MainBodyPanel")
end

-- 创建动画
function DrawCharmDlg:creatMagic(root, icon, action, callback)
    if 'string' == type(root) then
        root = self:getControl(root)
    end

    -- 创建动画
    local magic = ArmatureMgr:createArmature(icon)
    root:addChild(magic)
    local size = root:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width * 0.5, size.height * 0.5)
    magic:setName(action)

    -- 设置回调
    if callback then
        local function func(sender, etype, id)
            if etype == ccs.MovementEventType.complete then
                magic:stopAllActions()
                magic:removeFromParent(true)

                if callback and "function" == type(callback) then callback() end
            end
        end
        magic:getAnimation():setMovementEventCallFunc(func)
    end

    -- 播放动作
    magic:getAnimation():play(action)
end

-- 检查数据是否合法
function DrawCharmDlg:checkDrawIndex(index, wPos)
    local rect, image, pos
    image = self:getControl("FramePanel_1", nil, "CharmPanel")
    pos = image:getParent():convertToNodeSpace(wPos)
    rect  = image:getBoundingBox()
    self.isInvalid = self.isInvalid or not cc.rectContainsPoint(rect, pos)
    if index <= 0 or index > CHECK_POINT_COUNT then return 0 end
    for i = 1, CHECK_POINT_COUNT do
        image = self:getControl(string.format("PointPanel_%d", i), nil, "CharmPanel")
        pos = image:getParent():convertToNodeSpace(wPos)
        rect = image:getBoundingBox()
        if cc.rectContainsPoint(rect, pos) then
            if index == i  then
                image:setColor(cc.c3b(255, 0, 0))
                return 1
            elseif index > i then
                return 0
            else
                return 2
            end
        end
    end

    if not self.checkSpecPoint then
        self.checkSpecPoint = {}
    end
    for _, v in ipairs(SPEC_CHECK_POINT) do
        image = self:getControl(string.format("PointPanel_%d", v), nil, "CharmPanel")
        pos = image:getParent():convertToNodeSpace(wPos)
        rect = image:getBoundingBox()
        if cc.rectContainsPoint(rect, pos) and not self.checkSpecPoint[v] then
            self.checkSpecPoint[v] = true
        end
    end

    return 0
end

-- 重画
function DrawCharmDlg:resetPaint()
    local ctrl = self:getControl("FramePanel_2", nil, "CharmPanel")
    ctrl:removeAllChildren()
    self:resetPoint()
    self.drawIndex = 0
end

-- 重置所有已画点
function DrawCharmDlg:resetPoint()
    local image
    for i = 1, CHECK_POINT_COUNT do
        image = self:getControl(string.format("PointPanel_%d", i), nil, "CharmPanel")
        image:setColor(cc.c3b(0x96, 0xc8, 0xff))
    end
end

-- 提交按钮
function DrawCharmDlg:onSubmitButton(sender, eventType)
    if not self.drawIndex or self.drawIndex <= CHECK_POINT_COUNT or self.isInvalid then
        gf:ShowSmallTips(CHS[2000365])
        self:resetPaint()
        self:startIdleShow()
        self:setButtonVisble(false)
        return
    end

    local specCount = 0
    if self.checkSpecPoint then
        for _, v in pairs(self.checkSpecPoint) do
            specCount = specCount + 1
        end
    end

    gf:CmdToServer('CMD_FINISH_JINGUANGFU', { perfect = specCount >= 2 and 1 or 0 })
end

-- 重画按钮
function DrawCharmDlg:onRepateButton(sender, eventType)
    gf:confirm(CHS[2000366], function()
        local ctrl = self:getControl("FramePanel_2", nil, "CharmPanel")
        self:resetPaint()
        self:startIdleShow()
        self:setButtonVisble(false)
    end)
end

-- 过图
function DrawCharmDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

-- 换线
function DrawCharmDlg:MSG_SWITCH_SERVER(data)
    self:onCloseButton()
end

-- 换线
function DrawCharmDlg:MSG_SWITCH_SERVER_EX(data)
    self:onCloseButton()
end

-- 换线
function DrawCharmDlg:MSG_SPECIAL_SWITCH_SERVER(data)
    self:onCloseButton()
end

-- 换线
function DrawCharmDlg:MSG_SPECIAL_SWITCH_SERVER_EX(data)
    self:onCloseButton()
end

-- 归队
function DrawCharmDlg:MSG_UPDATE_TEAM_LIST(data)
    if TeamMgr:inTeam(Me:getId()) then
        self:onCloseButton()
    end
end

return DrawCharmDlg