-- JiebSortOrderDlg.lua
-- Created by yangym Apr/7/2017
-- 结拜调整顺序界面

local JiebSortOrderDlg = Singleton("JiebSortOrderDlg", Dialog)

local PORTRAIT_NUM = 5

local POP_LIMIT = 40 * 2

function JiebSortOrderDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    ChatMgr:blindSpeakBtn(self:getControl("TeamRecordButton"), self)

    -- 确认按钮显示与否
    self:refreshConfirmButtonState()

    -- 刷新提示内容
    self:refreshTips()
end

function JiebSortOrderDlg:refreshConfirmButtonState()
    local btn = self:getControl("ConfirmButton")
    btn:setVisible(Me:isTeamLeader())
end

function JiebSortOrderDlg:refreshTips()
    if Me:isTeamLeader() then
        self:setLabelText("TipsLabel", CHS[7002239])
    else
        self:setLabelText("TipsLabel", CHS[7002240])
    end
end

-- 根据结拜人数初始化头像位置
function JiebSortOrderDlg:initPortraitPos(num)
    if self.initPortraitPosFinished then
        return
    end

    -- 根据人数隐藏“空头像”
    for i = 1, PORTRAIT_NUM do
        if i <= num then
            self:setCtrlVisible("PortraitFrameImage_" .. i, true)
            self:setCtrlVisible("PortraitPanel_" .. i, true)
        else
            self:setCtrlVisible("PortraitFrameImage_" .. i, false)
            self:setCtrlVisible("PortraitPanel_" .. i, false)
        end
    end

    -- 将显示状态的头像整体居中

    -- 计算需要移动的距离
    local portraitPanelWidth = self:getControl("PortraitPanel_1"):getContentSize().width
    local firstPanelPosX = self:getControl("PortraitPanel_1"):getPositionX()
    local lastPanelPosX = self:getControl("PortraitPanel_" .. num):getPositionX()
    local mainPanel = self:getControl("PortraitPanel")
    local offset = mainPanel:getContentSize().width / 2 - ((firstPanelPosX + lastPanelPosX + portraitPanelWidth) / 2)

    -- 计算头像允许左右移动的最大位置
    self.minPortraitPos = firstPanelPosX + offset
    self.maxPortraitPos = lastPanelPosX + offset + portraitPanelWidth

    -- 移动显示状态的头像
    for i = 1, num  do
        local portraitPanel = self:getControl("PortraitPanel_" .. i)
        local portraitFramePanel = self:getControl("PortraitFrameImage_" .. i)
        portraitPanel:setPositionX(portraitPanel:getPositionX() + offset)
        portraitFramePanel:setPositionX(portraitFramePanel:getPositionX() + offset)
    end

    -- 记录一下头像的初始位置
    self:recordOriPos()

    self.initPortraitPosFinished = true
end

-- 记录头像的初始位置
function JiebSortOrderDlg:recordOriPos()
    if not self.oriPos then
        self.oriPos = {}
    end

    for i = 1, PORTRAIT_NUM do
        local ctrl = self:getControl("PortraitFrameImage_" .. i)
        if ctrl:isVisible() then
            local x, y = ctrl:getPosition()
            self.oriPos[i] = {x = x, y = y}
        end
    end
end

-- 绑定头像拖动事件
function JiebSortOrderDlg:bindPortrait(panel)
    if not self.data then
        return
    end

    if self.bindPortraitFinished then
        return
    end

    if not Me:isTeamLeader() then
        -- 非队长不绑定相关逻辑
        self.bindPortraitFinished = true
        return
    end

    local function onTouchBegan(touch, event)
        if self.curPortrait then
            -- 已经选中了某个头像
            return
        end

        for i = 1, #self.data do
            local ctrl = self:getControl("PortraitFrameImage_" .. i)
            local rect = self:getBoundingBoxInWorldSpace(ctrl)
            if cc.rectContainsPoint(rect, touch:getLocation()) and ctrl:isVisible() then
                ctrl:setLocalZOrder(ctrl:getLocalZOrder() + 1)
                self.curPortrait = ctrl
                self.curIndex = i
            end
        end

        return self.curPortrait ~= nil
    end

    local function onTouchMove(touch, event)
        if not self.curPortrait then
            -- 还没有选中某个头像
            return
        end
        local eventCode = event:getEventCode()
        local ctrlPos = panel:convertToNodeSpace(touch:getLocation())
        local posx = ctrlPos.x
        local width = panel:getContentSize().width
        if posx < (self.minPortraitPos or 0) then
            -- 限制移动到最左的位置
            posx = (self.minPortraitPos or 0)
        end
        if posx > (self.maxPortraitPos or width) then
            -- 限制移动到最右的位置
            posx = (self.maxPortraitPos or width)
        end
        self.curPortrait:setPosition(posx, self.curPortrait:getPositionY())
        return true
    end

    local function onTouchEnd(touch, event)
        if not self.curPortrait then
            return
        end

        for i = 1, PORTRAIT_NUM do
            local ctrl = self:getControl("PortraitFrameImage_" .. i)
            if self.curPortrait:getName() ~= ctrl:getName() and ctrl:isVisible() then
                local touchRect = self:getBoundingBoxInWorldSpace(ctrl)
                if cc.rectContainsPoint(touchRect, touch:getLocation()) then
                    self:changeOrder(self.curIndex, i)
                end
            end
        end

        self.curPortrait:setLocalZOrder(self.curPortrait:getLocalZOrder() - 1)
        self.curPortrait = nil
        self.curIndex = nil
        self:resetPortrait()
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

    self.bindPortraitFinished = true
end

-- 重置头像位置
function JiebSortOrderDlg:resetPortrait()
    if not self.oriPos then
        return
    end

    for i = 1, PORTRAIT_NUM do
        local ctrl = self:getControl("PortraitFrameImage_" .. i)
        if self.oriPos[i] then
            ctrl:setPosition(self.oriPos[i].x, self.oriPos[i].y)
        end
    end
end

-- 初始化/刷新角色相关信息
function JiebSortOrderDlg:setInfo(data)
    if not data then
        return
    end


    self.data = data

    local panel = self:getControl("PortraitPanel")

    self:initPortraitPos(#data)

    -- 重置头像位置
    self:resetPortrait()

    -- 绑定一下拖动事件
    self:bindPortrait(self:getControl("PortraitPanel"))

    --  处理一下数据，获取称谓
    local data = JiebaiMgr:insertChengWeiByData(data)

    -- 设置每个角色信息
    for i = 1, PORTRAIT_NUM do
        local info = data[i]
        if info then
            local name = gf:getRealName(info.name)
            local iconPath = ResMgr:getCirclePortraitPathByIcon(info.icon)
            self:setImage("PortraitImage", iconPath, "PortraitFrameImage_" .. i)
            self:setLabelText("NameLabel", name, "PortraitPanel_" .. i)
            self:setLabelText("TitleLabel", info.chengWei, "PortraitPanel_" .. i)
        else
            -- self:setLabelText("NameLabel", CHS[7002236], "PortraitPanel_" .. i)
        end
    end
end

-- 更改长幼顺序
function JiebSortOrderDlg:changeOrder(sourceIndex, targetIndex)
    if not self.data then
        return
    end

    local source = self.data[sourceIndex]
    local target = self.data[targetIndex]
    if source and target then
        gf:CmdToServer("CMD_ADJUST_BROTHER_ORDER",{
                gid = source.gid,
                target_gid = target.gid,}
        )
    end
end

function JiebSortOrderDlg:getIndexByGid(gid)
    if not self.data then
        return
    end

    local data = self.data
    for i = 1, #data do
        if data[i].gid == gid then
            return i
        end
    end
end

function JiebSortOrderDlg:chatPopUp(data)
    local gid = data.gid
    local msg = data.msg
    local index = self:getIndexByGid(gid)
    if index then
        local panel = self:getControl("PortraitFrameImage_" .. index)
        local panelSize = panel:getContentSize()
        msg = gf:subString(msg, POP_LIMIT)
        JiebaiMgr:chatPop(panel, msg, panelSize.width / 2, panelSize.height * 2 / 3 + 5, 5)
    end
end

function JiebSortOrderDlg:sendVoiceMsg()
    local name = ChatMgr:getSenderName()
    local voiceData = ChatMgr:getVoiceData()
    local data = {}
    data["channel"] = CHAT_CHANNEL["TEAM"]
    if not voiceData or not data["channel"] then gf:ftpUploadEx("ChatDlg name is " .. name) return end
    local filteText = voiceData.text
    data["compress"] = 0
    data["orgLength"] = string.len(filteText)
    data["msg"] = filteText
    data["voiceTime"] = voiceData.voiceTime or 0
    data["token"] = voiceData.token or ""
    if  string.len(data["msg"]) <= 0 and  string.len(data["token"]) <= 0 then
        return
    end

    ChatMgr:sendMessage(data)
end

-- 确认长幼顺序
function JiebSortOrderDlg:onConfirmButton()
    gf:confirm(CHS[7002241], function()
        gf:CmdToServer("CMD_CONFIRM_BROTHER_ORDER")
    end)
end

-- 关闭按钮响应
function JiebSortOrderDlg:onCloseButton()
    gf:confirm(CHS[7002238], function()
        gf:CmdToServer("CMD_CANCEL_BROTHER")
    end)
end

function JiebSortOrderDlg:cleanup()
    self.initPortraitPosFinished = nil
    self.bindPortraitFinished = nil
end

return JiebSortOrderDlg
