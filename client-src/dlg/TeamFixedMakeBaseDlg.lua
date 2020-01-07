-- TeamFixedMakeBaseDlg.lua
-- Created by sujl, Oct/12/2018
-- 固定队结交流程基类界面

local TeamFixedMakeBaseDlg = Singleton("TeamFixedMakeBaseDlg", Dialog)

-- 人数上限
local PORTRAIT_NUM = 5

-- 气泡显示上限
local POP_LIMIT = 40 * 2

function TeamFixedMakeBaseDlg:init()
    ChatMgr:blindSpeakBtn(self:getControl("TeamRecordButton"), self)

    self:initTeamList()

    self:hookMsg("MSG_MESSAGE")
    self:hookMsg("MSG_MESSAGE_EX")
end

function TeamFixedMakeBaseDlg:cleanup()
    self.initPortraitPosFinished = nil
    self.chatContent = nil
end

-- 初始化界面列表
function TeamFixedMakeBaseDlg:initTeamList()
    local members = TeamMgr.members
    for i = 1, #members do
        self:setTeamMember(i, members[i])
    end

    self:initPortraitPos(#members)
end

function TeamFixedMakeBaseDlg:setTeamMember(index, data)
    local ctlName
    ctlName = self:getPortraitFrameImage(index)
    self:setImage("PortraitImage", ResMgr:getCirclePortraitPathByIcon(data.org_icon), ctlName)
    ctlName = string.format("PortraitPanel_%d", index)
    self:setLabelText("NameLabel", data.name, ctlName)
end

-- 根据结拜人数初始化头像位置
function TeamFixedMakeBaseDlg:initPortraitPos(num)
    if self.initPortraitPosFinished then
        return
    end

    -- 根据人数隐藏“空头像”
    for i = 1, PORTRAIT_NUM do
        if i <= num then
            self:getPortraitFrameImage(i):setVisible(true)
            self:setCtrlVisible("PortraitPanel_" .. i, true)
        else
            self:getPortraitFrameImage(i):setVisible(false)
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
        local portraitFramePanel = self:getPortraitFrameImage(i)
        portraitPanel:setPositionX(portraitPanel:getPositionX() + offset)
        portraitFramePanel:setPositionX(portraitFramePanel:getPositionX() + offset)
    end

    -- 记录一下头像的初始位置
    self:recordOriPos()

    self.initPortraitPosFinished = true
end

function TeamFixedMakeBaseDlg:getPortraitFrameImage(index)
    return self:getControl("PortraitFrameImage_" .. index)
end

-- 记录头像的初始位置
function TeamFixedMakeBaseDlg:recordOriPos()
    if not self.oriPos then
        self.oriPos = {}
    end

    for i = 1, PORTRAIT_NUM do
        local ctrl = self:getPortraitFrameImage(i)
        if ctrl:isVisible() then
            local x, y = ctrl:getPosition()
            self.oriPos[i] = {x = x, y = y}
        end
    end
end

function TeamFixedMakeBaseDlg:refreshConfirmButtonState()
    self:setCtrlVisible("ConfirmButton", Me:isTeamLeader())
end

function TeamFixedMakeBaseDlg:getIndexByGid(gid)
    if not TeamMgr.members then
        return
    end

    local data = TeamMgr.members
    for i = 1, #data do
        if data[i].gid == gid then
            return i
        end
    end
end

-- 聊天泡泡
function TeamFixedMakeBaseDlg:chatPop(panel, msg, offsetX, offsetY, showTime)
    if not self.chatContent then
        self.chatContent = {}
    end

    local name = panel:getName()
    if not self.chatContent[name] then
        self.chatContent[name] = {}
    end

    local dlg = DlgMgr:openDlg("PopUpDlg")
    local bg = dlg:addTip(msg)
    bg:setPosition(offsetX, offsetY)

    local cb = function()
        for k, v in pairs(self.chatContent[name]) do
            if v == bg then
                table.remove(self.chatContent[name], k)
            end
        end
    end

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(showTime),
        cc.CallFunc:create(cb),
        cc.RemoveSelf:create()
    )

    panel:addChild(bg)

    if #(self.chatContent[name]) == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        local node = self.chatContent[name][1]
        node:runAction(newAction)
    elseif #(self.chatContent[name]) > 1 then
        -- 消息到达2条时，移除对头消息, 并拿出新的队头继续向上移动
        local node = table.remove(self.chatContent[name], 1)
        node:stopAllActions()
        node:removeFromParent()
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        node = self.chatContent[name][1]
        node:runAction(newAction)
    end

    bg:runAction(action)
    table.insert(self.chatContent[name], bg)
end

function TeamFixedMakeBaseDlg:chatPopUp(data)
    local gid = data.gid
    local msg = data.msg
    local index = self:getIndexByGid(gid)
    if index then
        local panel = self:getPortraitFrameImage(index)
        local panelSize = panel:getContentSize()
        msg = gf:subString(msg, POP_LIMIT)
        self:chatPop(panel, msg, panelSize.width / 2, panelSize.height * 2 / 3 + 5, 5)
    end
end

function TeamFixedMakeBaseDlg:sendVoiceMsg()
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

function TeamFixedMakeBaseDlg:MSG_MESSAGE(data)
    if data["channel"] == CHAT_CHANNEL["TEAM"] or data["channel"] == CHAT_CHANNEL["TEAM_INFO"] then

        -- 结拜过程中，翻译得到的语音文本要显示在界面上（在后台则不作处理）
        if (not GameMgr:isInBackground()) and data["token"] and data["token"] ~= "" and data["msg"] ~= "" then
            self:chatPopUp(data)
        end
    end
end

function TeamFixedMakeBaseDlg:MSG_MESSAGE_EX(data)
    self:MSG_MESSAGE(data)
end

return TeamFixedMakeBaseDlg