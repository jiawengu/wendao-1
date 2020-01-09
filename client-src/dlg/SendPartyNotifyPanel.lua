-- SendPartyNotifyPanel.lua
-- Created by songcw Mar/10/2015
-- 发送公告

local SendPartyNotifyPanel = Singleton("SendPartyNotifyPanel", Dialog)

local TYPE_EDITING = 1
local TYPE_EDIT_CANCE = 0

local notifyLimit       = 80

local SAVE_PATH = Const.WRITE_PATH .. "partyPhrase/"

local default_color = cc.c3b(86, 41, 2)

local notifyCount = 8

function SendPartyNotifyPanel:init()
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("ModifyButton", self.onModifyButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("CancelSendButton", self.onCancelSendButton)

    self:bindPanels()
    self.editType = TYPE_EDIT_CANCE

    self:setCtrlVisible("TextField", true)

    self:setInputText("TextField", "")
    self:setDesc("")
    self.pick = 0

    -- 输入框
    self:setCtrlVisible("CleanFieldButton", false)
    local textCtrl = self:getControl("TextField")
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible("CleanFieldButton", true)
            local str = textCtrl:getStringValue()
            local len = string.len(str)
            local leftString = len
            local filterStr = ""
            local index = 1
            if gf:getTextLength(str) > notifyLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            while  gf:getTextLength(filterStr) < notifyLimit * 2 and index <= len do
                local byteValue = string.byte(str, index)
                if byteValue < 128 then
                    filterStr = filterStr..string.sub(str, index, index)
                    index = index + 1
                elseif byteValue >= 192 and byteValue < 224 then
                    index = index + 2
                elseif  byteValue >= 224 and byteValue <= 239 then
                    if gf:getTextLength(filterStr..string.sub(str, index, index + 2)) > notifyLimit * 2 then
                        break
                    else
                        filterStr = filterStr..string.sub(str, index, index + 2)
                        index = index + 3
                    end
                end
            end
            textCtrl:setText(tostring(filterStr))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible("CleanFieldButton", false)
            end
        end
    end)
end

function SendPartyNotifyPanel:cleanup()
    self:releaseCloneCtrl("selectEff")
end

-- 获取一级二菜单选中光效
function SendPartyNotifyPanel:getSelectEff()
    if nil == self.selectEff then
        -- 创建选择框
        local img = self:getControl("Image", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectEff = img
    end

    self.selectEff:removeFromParent(false)

    return self.selectEff
end

function SendPartyNotifyPanel:bindPanels(pick)
    for i = 1, notifyCount do
        local commonPanel = self:getControl("CommonLanguePanel_" .. i)
        commonPanel:setTag(i)
        -- 是否有保存的编辑语
        local filePath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. i .. ".lua"
        if cc.FileUtils:getInstance():isFileExist(filePath) then
            local phrase = dofile(filePath)
            for keyName, content in pairs(phrase) do
                self:setLabelText("Label", keyName, commonPanel)
            end
        end

        self:bindListener("CommonLanguePanel_" .. i, self.pickPanel)

        if pick and pick == i then
            self:pickPanel(commonPanel)
        end
        commonPanel:requestDoLayout()
    end

    self:bindListener("InformationPanel", self.editCurInfo)
end

function SendPartyNotifyPanel:editCurInfo(sender, eventType)
    self:setCtrlVisible("TextField", true)

    self:setCtrlVisible("InformationPanel", false)
end

function SendPartyNotifyPanel:pickPanel(sender, eventType)
    local index = sender:getTag()
    self.title = self:getLabelText("Label", sender)
--    local textCtrl = self:getControl("TextField")
--    textCtrl:setFocused(false)
    sender:addChild(self:getSelectEff())

    -- 是否有保存的编辑语
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. index .. ".lua"
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local phrase = dofile(filePath)
        for keyName, content in pairs(phrase) do
            self:setInputText("TextField", content)
            self:setDesc(content)
        end
    else
        self:setInputText("TextField", PartyMgr:getPartyNotifyDef(index).content or "")
        self:setDesc(PartyMgr:getPartyNotifyDef(index).content)
    end

    if self.editType == TYPE_EDITING then
        local dlg = DlgMgr:openDlg("EditPartyCommonNotifyDlg")
        dlg:setTitileAndContent(self:getLabelText("Label", sender), nil, index)
        return
    end



    self:setCtrlVisible("TextField", false)
    self:setCtrlVisible("InformationPanel", true)
end

function SendPartyNotifyPanel:setDesc(descript)
    local panel = self:getControl("InformationPanel")
    panel:removeAllChildren()
    local size = self:getControl("InputPanel"):getContentSize()
    local size2 = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setDefaultColor(default_color["r"], default_color["g"], default_color["b"])
    textCtrl:setString(descript)
    textCtrl:setContentSize(size.width, size.height)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size2.width - size.width) * 0.5,size.height + (size2.height - size.height) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end

function SendPartyNotifyPanel:onCleanFieldButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("CleanFieldButton", false)
end

function SendPartyNotifyPanel:onModifyButton(sender, eventType)
    if self.editType == TYPE_EDIT_CANCE then
        self:setLabelText("Label_1", CHS[4000205], sender)
        self:setLabelText("Label_2", CHS[4000205], sender)
        self.editType = TYPE_EDITING
    else
        self:setLabelText("Label_1", CHS[4000204], sender)
        self:setLabelText("Label_2", CHS[4000204], sender)
        self.editType = TYPE_EDIT_CANCE
    end

    self:setDesc(self:getInputText("TextField"))
    self:setCtrlVisible("TextField", false)
    self:setCtrlVisible("InformationPanel", true)
end

function SendPartyNotifyPanel:onSendButton(sender, eventType)
    local text = self:getInputText("TextField")
    if text == nil or text == "" then return end

    gf:CmdToServer("CMD_PARTY_SEND_MESSAGE", {
        title = self.title or "",
        msg = text
    })
end

function SendPartyNotifyPanel:onCancelSendButton(sender, eventType)
    self:onCloseButton()
end

return SendPartyNotifyPanel
