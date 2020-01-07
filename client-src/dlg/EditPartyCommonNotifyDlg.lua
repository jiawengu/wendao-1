-- EditPartyCommonNotifyDlg.lua
-- Created by songcw    Mar/11/2015
-- 编辑帮派公告界面

local EditPartyCommonNotifyDlg = Singleton("EditPartyCommonNotifyDlg", Dialog)

local titleLimit        = 10
local contentLimit      = 80

local SAVE_PATH = Const.WRITE_PATH .. "partyPhrase/"

function EditPartyCommonNotifyDlg:init()
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("CancelButton", self.onCancelButton)


    -- 标题textfield监听
    local titlePanel = self:getControl("NamePanel")
    local cleanButton = self:getControl("CleanName", nil, titlePanel)
    cleanButton:setVisible(false)
    self:bindListener("CleanName", self.onCleanButton, titlePanel)
    local ctrl = self:getControl("TextField", nil, titlePanel)
    self:bindEditField(ctrl, titleLimit, cleanButton)

    -- 内容textfield监听
    local contentPanel = self:getControl("ContentPanel")

    local cleanContentButton = self:getControl("CleanName", nil, contentPanel)
    cleanContentButton:setVisible(false)
    self:bindListener("CleanName", self.onCleanButton, contentPanel)
    local contentCtrl = self:getControl("TextField", nil, contentPanel)
    self:bindEditField(contentCtrl, contentLimit, cleanContentButton)

    self.index = nil
end

function EditPartyCommonNotifyDlg:bindEditField(textCtrl, lenLimit, cleanButton)
    local parentPanel = textCtrl:getParent()
    cleanButton:setVisible(false)
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            cleanButton:setVisible(true)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
                cleanButton:setVisible(false)
            end
        end
    end)
end

function EditPartyCommonNotifyDlg:setTitileAndContent(title, content, index)
    if index ~= nil then self.index = index end
    if content == nil then
        -- 是否有保存的编辑语
        local filePath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. index .. ".lua"
        if cc.FileUtils:getInstance():isFileExist(filePath) then
            local phrase = dofile(filePath)
            for keyName, contentTemp in pairs(phrase) do

                self:setContent(contentTemp,index)
            end
        else
            self:setContent(PartyMgr:getPartyNotifyDef(index).content or "", index)
        end
    else
        self:setContent(content,index)
    end
    self:setTitile(title, index)
end

function EditPartyCommonNotifyDlg:setTitile(title, content, index)
    if index ~= nil then self.index = index end
    local titilePanel = self:getControl("NamePanel")
    self:setInputText("TextField", title, titilePanel)

    if self:getInputText("TextField", titilePanel) == "" then
        self:setCtrlVisible("CleanName", false, titilePanel)
    else
        self:setCtrlVisible("CleanName", true, titilePanel)
    end
end

function EditPartyCommonNotifyDlg:setContent(content, index)
    local contentPanel = self:getControl("ContentPanel")
    if content == "" then content = PartyMgr:getPartyNotifyDef(index).content end
    self:setInputText("TextField", content, contentPanel)

    if self:getInputText("TextField", contentPanel) == "" then
        self:setCtrlVisible("CleanName", false, contentPanel)
    else
        self:setCtrlVisible("CleanName", true, contentPanel)
    end
end

function EditPartyCommonNotifyDlg:onDefaultButton(sender, eventType)
    if self.index == nil then return end
    self:setTitileAndContent(PartyMgr:getPartyNotifyDef(self.index).title, PartyMgr:getPartyNotifyDef(self.index).content, self.index)
end

function EditPartyCommonNotifyDlg:onSaveButton(sender, eventType)
    -- 标题非空判断
    local titilePanel = self:getControl("NamePanel")
    local title = self:getInputText("TextField", titilePanel)
    if title == "" then
        self:setTitile(PartyMgr:getPartyNotifyDef(self.index).title)
    end

    -- 敏感词判断
    local contentPanel = self:getControl("ContentPanel")
    local content = self:getInputText("TextField", contentPanel)

    local title, titleFilt = gf:filtText(title)
    local content, contentFilt = gf:filtText(content)
    if titleFilt or contentFilt then return end

    local saveData = ""
    saveData = saveData .. "return {\n"
    local str = "['%s'] = '%s'"
    local titilePanel = self:getControl("NamePanel")
    local title = self:getInputText("TextField", titilePanel)
    local contentPanel = self:getControl("ContentPanel")
    local content = self:getInputText("TextField", contentPanel)
    local phrase = string.format(str, title, content)
    saveData = saveData .. phrase
    saveData = saveData .. "}"

    gfSaveFile(saveData, SAVE_PATH .. self.index .. ".lua")

    -- 跟新发送公告信息
    DlgMgr:sendMsg("SendPartyNotifyPanel", "bindPanels", self.index)

    self:onCloseButton()
end

function EditPartyCommonNotifyDlg:onCleanButton(sender, eventType)
    local parentPanel = sender:getParent()
    self:setInputText("TextField", "", parentPanel)
    sender:setVisible(false)
end


function EditPartyCommonNotifyDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return EditPartyCommonNotifyDlg
