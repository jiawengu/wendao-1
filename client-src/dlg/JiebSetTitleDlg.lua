-- JiebSetTitleDlg.lua
-- Created by yangym Apr/7/2017
-- 结拜称谓设定界面

local JiebSetTitleDlg = Singleton("JiebSetTitleDlg", Dialog)

local PORTRAIT_NUM = 5
local PREFIX_LIMIT = 3 * 2
local SUFFIX_LIMIT = 2 * 2
local POP_LIMIT = 40 * 2

function JiebSetTitleDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    ChatMgr:blindSpeakBtn(self:getControl("TeamRecordButton"), self)
    
    -- 创建输入框
    self:createEditBoxes()
    
    -- 更新确认按钮状态
    self:refreshConfirmButtonState()
    
    -- 更新提示
    self:refreshTips()
end

function JiebSetTitleDlg:createEditBoxes()
    
        -- 前缀输入框
    self.prefixBox = self:createEditBox("QianzPanel", nil, nil, function(sender, type) 
        if type == "began" then
        elseif type == "changed" then
            if not Me:isTeamLeader() then
                gf:ShowSmallTips(CHS[7002248])
                return
            end
            local prefix = self.prefixBox:getText()
            if gf:getTextLength(prefix) > PREFIX_LIMIT then
                prefix = gf:subString(prefix, PREFIX_LIMIT)
                self.prefixBox:setText(prefix)
                gf:ShowSmallTips(CHS[4000224])
            end
            
            self:sendInput()
        elseif type == "end" then
        end
    end)
    
    self.prefixBox:setFont(CHS[3003597], 20)
    self.prefixBox:setFontColor(cc.c3b(139, 69, 19))
    self.prefixBox:setText("")
    
    -- 后缀输入框
    self.suffixBox = self:createEditBox("HouzPanel", nil, nil, function(sender, type) 
        if type == "began" then
        elseif type == "changed" then
            if not Me:isTeamLeader() then
                gf:ShowSmallTips(CHS[7002248])
                return
            end
            local suffix = self.suffixBox:getText()
            if gf:getTextLength(suffix) > SUFFIX_LIMIT then
                suffix = gf:subString(suffix, SUFFIX_LIMIT)
                self.suffixBox:setText(suffix)
                gf:ShowSmallTips(CHS[4000224])
            end
            
            self:sendInput()
        elseif type == "end" then
        end
    end)
    
    self.suffixBox:setFont(CHS[3003597], 20)
    self.suffixBox:setFontColor(cc.c3b(139, 69, 19))
    self.suffixBox:setText("")
    
    if Me:isTeamLeader() then
        -- 队长可以输入内容
        self.prefixBox:setEnabled(true)
        self.suffixBox:setEnabled(true)
    else
        -- 队员不可输入内容，并给予提示
        self.prefixBox:setEnabled(false)
        self.suffixBox:setEnabled(false)
        local function func()
            gf:ShowSmallTips(CHS[7002248])
        end
        
        self:bindListener("QianzPanel", func)
        self:bindListener("HouzPanel", func)
    end
    
    
end

function JiebSetTitleDlg:refreshConfirmButtonState()
    local btn = self:getControl("ConfirmButton")
    btn:setVisible(Me:isTeamLeader())
end

function JiebSetTitleDlg:refreshTips()
    if Me:isTeamLeader() then
        self:setLabelText("TipsLabel", CHS[7002246])
    else
        self:setLabelText("TipsLabel", CHS[7002247])
    end
end

function JiebSetTitleDlg:sendInput()
    if not self.suffixBox or not self.prefixBox then
        return
    end
    
    if not Me:isTeamLeader() then
        return
    end
    
    local prefix = self.prefixBox:getText()
    local suffix = self.suffixBox:getText()
    
    gf:CmdToServer("CMD_SET_BROTHER_APPELLATION", {prefix = prefix, suffix = suffix})
end

-- 根据结拜人数初始化头像位置
function JiebSetTitleDlg:initPortraitPos(num)
    if self.initPortraitPosFinished then
        return
    end

    -- 根据人数隐藏“空头像”
    for i = 1, PORTRAIT_NUM do
        if i <= num then
            self:setCtrlVisible("PortraitPanel_" .. i, true)
        else
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

    -- 移动显示状态的头像
    for i = 1, num  do
        local portraitPanel = self:getControl("PortraitPanel_" .. i)
        portraitPanel:setPositionX(portraitPanel:getPositionX() + offset)
    end

    self.initPortraitPosFinished = true
end

function JiebSetTitleDlg:setInfo(data)
    if not data then
        return
    end
    
    self.data = data
    
    self:initPortraitPos(#data)
    
    --  处理一下数据，获取称谓
    local data = JiebaiMgr:insertChengWeiByData(data)

    -- 设置每个角色信息
    for i = 1, PORTRAIT_NUM do
        local info = data[i]
        if info then
            local name = gf:getRealName(info.name)
            local iconPath = ResMgr:getCirclePortraitPathByIcon(info.icon)
            self:setImage("PortraitImage", iconPath, "PortraitPanel_" .. i)
            self:setLabelText("NameLabel", name, "PortraitPanel_" .. i)
            self:setLabelText("TitleLabel", info.chengWei, "PortraitPanel_" .. i)
        else
            -- self:setLabelText("NameLabel", CHS[7002236], "PortraitPanel_" .. i)
        end
    end
    
    -- 称谓中间汉字
    local midWord = JiebaiMgr:getChengWeiMidWord(#data)
    if midWord then
        self.midWord = midWord
        self:setLabelText("Label_2", midWord)
    end
    
    -- 填充一下称谓
    if self.prefixBox and self.suffixBox then
        self.prefixBox:setText(data.prefix)
        self.suffixBox:setText(data.suffix)
    end
end

function JiebSetTitleDlg:onConfirmButton()
    if not Me:isTeamLeader() then
        return
    end
    
    if not self.suffixBox or not self.prefixBox then
        return
    end
    
    if not self.midWord then
        return
    end
    
    local prefix = self.prefixBox:getText()
    local suffix = self.suffixBox:getText()
    if prefix == "" then
        gf:ShowSmallTips(CHS[7002249])
        return
    end
    
    if suffix == "" then
        gf:ShowSmallTips(CHS[7002250])
        return
    end
    
    local chengWei = prefix .. self.midWord .. suffix
    gf:confirm(string.format(CHS[7002251], chengWei), function()
        gf:CmdToServer("CMD_CONFIRM_BROTHER_APPELLATION")
    end)
end

function JiebSetTitleDlg:getIndexByGid(gid)
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

function JiebSetTitleDlg:chatPopUp(data)
    local gid = data.gid
    local msg = data.msg
    local index = self:getIndexByGid(gid)
    if index then
        local panel = self:getControl("PortraitFrameImage", nil, "PortraitPanel_" .. index)
        local panelSize = panel:getContentSize()
        msg = gf:subString(msg, POP_LIMIT)
        JiebaiMgr:chatPop(panel, msg, panelSize.width / 2, panelSize.height * 2 / 3 + 5, 5)
    end
end

function JiebSetTitleDlg:sendVoiceMsg()
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

function JiebSetTitleDlg:onCloseButton()
    local tip
    if JiebaiMgr:hasJiebaiRelation() then
        tip = CHS[7001051]
    else
        tip = CHS[7002238]
    end
    
    gf:confirm(tip, function()
        gf:CmdToServer("CMD_CANCEL_BROTHER")
    end)
end

function JiebSetTitleDlg:cleanup()
    self.initPortraitPosFinished = nil
end

return JiebSetTitleDlg