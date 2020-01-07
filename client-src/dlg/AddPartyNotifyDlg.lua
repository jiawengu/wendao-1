-- AddPartyNotifyDlg.lua
-- Created by songcw    Mar/11/2015
-- 编辑帮派公告界面

local AddPartyNotifyDlg = Singleton("AddPartyNotifyDlg", Dialog)

local titleLimit        = 8
local contentLimit      = 80

local SAVE_PATH = Const.WRITE_PATH .. "partyPhrase/"

function AddPartyNotifyDlg:init()
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("CancelButton", self.onCancelButton)


    -- 标题textfield监听
    local titlePanel = self:getControl("NamePanel")
    local cleanButton = self:getControl("CleanFieldButton", nil, titlePanel)
    cleanButton:setVisible(false)
    self:bindListener("CleanFieldButton", self.onCleanButton, titlePanel)
    local ctrl = self:getControl("TextField", Const.UITextField)
    ctrl:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
--    ccui.TextField:setTextVerticalAlignment(alignment)
    self:bindEditField(ctrl, titleLimit, cleanButton)

    -- 内容textfield监听
    local contentPanel = self:getControl("ContentPanel")

    local cleanContentButton = self:getControl("CleanFieldButton", nil, contentPanel)
    cleanContentButton:setVisible(false)
    self:bindListener("CleanFieldButton", self.onCleanButton, titleLimit)
    local contentCtrl = self:getControl("TextField", nil, contentPanel)



    self.index = nil
end

function AddPartyNotifyDlg:bindEditField(textCtrl, lenLimit, cleanButton)
    local parentPanel = textCtrl:getParent()
    cleanButton:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            cleanButton:setVisible(true)
            self:setCtrlVisible("DefaultLabel", false)
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
                self:setCtrlVisible("DefaultLabel", true)
            end
        end
    end)
end

function AddPartyNotifyDlg:setTitileAndContent(title, content, index)
    if index ~= nil then self.index = index end
end

function AddPartyNotifyDlg:setTitile(title, content, index)
    if index ~= nil then self.index = index end
    local titilePanel = self:getControl("NamePanel")
    self:setInputText("TextField", title, titilePanel)

    if self:getInputText("TextField", titilePanel) == "" then
        self:setCtrlVisible("CleanName", false, titilePanel)
    else
        self:setCtrlVisible("CleanName", true, titilePanel)
    end
end

function AddPartyNotifyDlg:setContent(content, index)
    local contentPanel = self:getControl("ContentPanel")
    if content == "" then content = PartyMgr:getPartyNotifyDef(index).content end
    self:setInputText("TextField", content, contentPanel)

    if self:getInputText("TextField", contentPanel) == "" then
        self:setCtrlVisible("CleanName", false, contentPanel)
    else
        self:setCtrlVisible("CleanName", true, contentPanel)
    end
end

function AddPartyNotifyDlg:onDefaultButton(sender, eventType)
    if self.index == nil then return end
    self:setTitileAndContent(PartyMgr:getPartyNotifyDef(self.index).title, PartyMgr:getPartyNotifyDef(self.index).content, self.index)
end

function AddPartyNotifyDlg:onSaveButton(sender, eventType)
    -- 标题非空判断
    local titilePanel = self:getControl("NamePanel")
    local title = self:getInputText("TextField", titilePanel)
    if title == "" then
        gf:ShowSmallTips(CHS[3002248])
        return
    end

    -- 敏感词判断
    local contentPanel = self:getControl("ContentPanel")
    local content = self:getInputText("TextField", contentPanel)

    local title, titleFilt = gf:filtText(title)
    if titleFilt then return end

    local content, contentFilt = gf:filtText(content)
    if contentFilt then return end

    DataBaseMgr:deleteItems("partyNotify", string.format("`index`=%d", self.index))
    local data = {}
    data.index = self.index
    data.title = title
    data.context = ""
    DataBaseMgr:insertItem("partyNotify", data)

    -- 跟新发送公告信息
    DlgMgr:sendMsg("SendPartyNotifyDlg", "bindPanels", self.index)

    self:onCloseButton()
end

function AddPartyNotifyDlg:onCleanButton(sender, eventType)
    local parentPanel = sender:getParent()
    self:setInputText("TextField", "", parentPanel)
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end


function AddPartyNotifyDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return AddPartyNotifyDlg
