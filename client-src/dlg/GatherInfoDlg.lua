-- GatherInfoDlg.lua
-- Created by songcw Aug/31/2016
-- 信息收集界面

local GatherInfoDlg = Singleton("GatherInfoDlg", Dialog)

local CONTENR_MAX = 12 * 2
local AD_CONTENT_MAX = 50 * 2

local GATHER_TYPE = {
    GATHER_ITEM = 1,
    GATHER_MAIL = 2,
}

function GatherInfoDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self.nameEdit = self:createEditBox("InputPanel", "NamePanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.nameEdit:getText()
            if gf:getTextLength(newName) > CONTENR_MAX then
                newName = gf:subString(newName, CONTENR_MAX)
                self.nameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)

    self.nameEdit:setPlaceholderFont(CHS[3003794], 21)
    self.nameEdit:setFont(CHS[3003794], 21)
    self.nameEdit:setPlaceHolder(CHS[4300083])
    self.nameEdit:setPlaceholderFontSize(21)
    self.nameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.nameEdit:setFontColor(cc.c3b(102, 102, 102))

    self.qqEdit = self:createEditBox("InputPanel", "QQPanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.qqEdit:getText()
            if gf:getTextLength(newName) > CONTENR_MAX then
                newName = gf:subString(newName, CONTENR_MAX)
                self.qqEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)

    self.qqEdit:setPlaceholderFont(CHS[3003794], 21)
    self.qqEdit:setFont(CHS[3003794], 21)
    self.qqEdit:setPlaceholderFontSize(21)
    self.qqEdit:setPlaceHolder(CHS[4300084])
    self.qqEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.qqEdit:setFontColor(cc.c3b(102, 102, 102))

    self.telEdit = self:createEditBox("InputPanel", "PhonePanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.telEdit:getText()
            if gf:getTextLength(newName) > CONTENR_MAX then
                newName = gf:subString(newName, CONTENR_MAX)
                self.telEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)
    self.telEdit:setPlaceholderFont(CHS[3003794], 21)
    self.telEdit:setFont(CHS[3003794], 21)
    self.telEdit:setPlaceHolder(CHS[4300085])
    self.telEdit:setPlaceholderFontSize(21)
    self.telEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.telEdit:setFontColor(cc.c3b(102, 102, 102))

    local fieldCtrl = self:getControl("TextField")
    fieldCtrl:setFontSize(21)
    self:bindEditField("InputPanel", AD_CONTENT_MAX, "", "AddressPanel")

    self.dataTime = 0
end

function GatherInfoDlg:bindEditField(parentPanelName, lenLimit, clenButtonName, root)

    local namePanel = self:getControl(parentPanelName, nil, root)
    local textCtrl = self:getControl("TextField", nil, namePanel)
    textCtrl:setColor(cc.c3b(102, 102, 102))
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible("DefaultLabel", false, namePanel)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit then
                local filterStr = gf:subString(str, lenLimit)
                textCtrl:setText(tostring(filterStr))
                gf:ShowSmallTips(CHS[5400041])
            end
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空,如果将来需要有清空输入按钮
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible("DefaultLabel", true, namePanel)
            end
        end
    end)
end

function GatherInfoDlg:onConfrimButton(sender, eventType)
    local content = ""

    local name = self.nameEdit:getText()
    if gf:getTextLength(name) == 0 then
        content = content .. CHS[4300086]
    end

    local tel = self.telEdit:getText()
    if gf:getTextLength(tel) == 0 then
        if content ~= "" then
            content = content .. CHS[4300088]
        else
            content = CHS[4300087]
        end
    end

    local addr = self:getInputText("TextField")
    if gf:getTextLength(addr) == 0 then
        if content ~= "" then
            content = content .. CHS[4300090]
        else
            content = CHS[4300089]
        end
    end

    if content ~= "" then
        gf:ShowSmallTips(content .. CHS[4300091])
        return
    end

    local qq = self.qqEdit:getText()
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", self.dataTime)
    if gf:getServerTime() > self.dataTime then
        gf:ShowSmallTips(string.format(CHS[4300092], timeStr))
        return
    end

    local id = self.id
    if self.type == GATHER_TYPE.GATHER_ITEM then
        gf:confirm(CHS[4300093], function ()
            GiftMgr:sendUserInfo(id, name, tel, qq, addr)
            DlgMgr:closeDlg("GatherInfoDlg")
        end)
    elseif self.type == GATHER_TYPE.GATHER_MAIL then
        local mailType = self.mailType
        gf:confirm(CHS[4300093], function ()
            gf:CmdToServer('CMD_MAILBOX_GATHER', {
                mail_type = mailType,
                mail_id = id,
                mail_oper = 1,
                ["qq"] = qq,
                ["tel"] = tel,
                ["addr"] = addr,
                ["name"] = name,
            })
            DlgMgr:closeDlg("GatherInfoDlg")
        end)
    end
end

function GatherInfoDlg:onDlgOpened(list)
    local id = tonumber(list[1])
    local data = tonumber(list[2])
    self.id = id
    self.dataTime = data
    self.type = GATHER_TYPE.GATHER_ITEM
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", string.format(CHS[4300094], timeStr))
end

function GatherInfoDlg:setMailInfo(info)
    local id = info.id
    local ts = info.date
    local data = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local mailType = tonumber(info.type)
    self.id = id
    self.dataTime = data
    self.type = GATHER_TYPE.GATHER_MAIL
    self.mailType = mailType
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", string.format(CHS[4300094], timeStr))
end

return GatherInfoDlg
