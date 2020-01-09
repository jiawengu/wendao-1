-- GatherPhoneDlg.lua
-- Created by huangzz July/25/2017
-- 电话收集界面

local GatherPhoneDlg = Singleton("GatherPhoneDlg", Dialog)

local CONTENR_MAX = 8 * 2

function GatherPhoneDlg:init()
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
end

function GatherPhoneDlg:onConfrimButton(sender, eventType)
    local name = self.nameEdit:getText() or ""
    local tel = self.telEdit:getText() or ""
    local qq = self.qqEdit:getText() or ""
    
    -- 若姓名、电话两项任意一项为空，给予弹出提示
    if name == "" and tel == "" then
        gf:ShowSmallTips(CHS[5420172] .. CHS[6000084] .. CHS[5420173] .. CHS[5420171])
        return
    elseif name == "" then
        gf:ShowSmallTips(CHS[5420172] .. CHS[5420171])
        return
    elseif tel == "" then
        gf:ShowSmallTips(CHS[5420173] .. CHS[5420171])
        return
    end

    -- 若当前时间已超出界面提交的截止时间，给予弹出提示
    if gf:getServerTime() > self.endTime then
        gf:ShowSmallTips(gf:getServerDate(CHS[5420174], self.endTime))
        return
    end

    -- 否则弹出确认提示框
    gf:confirm(CHS[4300093], function ()
        gf:CmdToServer('CMD_MAILBOX_GATHER', {
            mail_type = self.mailType,
            mail_id = self.id,
            mail_oper = 1,
            ["qq"] = qq,
            ["tel"] = tel,
            ["addr"] = "",
            ["name"] = name,
        })
        DlgMgr:closeDlg("GatherPhoneDlg")
    end)
end

function GatherPhoneDlg:setMailInfo(info)
    local id = info.id
    local ts = info.date
    local data = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local mailType = tonumber(info.type)
    self.id = id
    self.endTime = data
    self.mailType = mailType
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", gf:getServerDate(CHS[5420175], self.endTime))
end

return GatherPhoneDlg
