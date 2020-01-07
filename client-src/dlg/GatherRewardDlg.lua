-- GatherRewardDlg.lua
-- Created by sujl, Apr/27/2018
-- 奖励信息收集

local GatherRewardDlg = Singleton("GatherRewardDlg", Dialog)

local CONTENR_MAX = 12 * 2

function GatherRewardDlg:init()
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
    self.nameEdit:setPlaceHolder(CHS[2200115])
    self.nameEdit:setPlaceholderFontSize(21)
    self.nameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.nameEdit:setFontColor(cc.c3b(86, 41, 2))

    self.idEdit = self:createEditBox("InputPanel", "IDPanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.idEdit:getText()
            if gf:getTextLength(newName) > CONTENR_MAX then
                newName = gf:subString(newName, CONTENR_MAX)
                self.idEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)

    self.idEdit:setFont(CHS[3003794], 21)
    self.idEdit:setPlaceholderFont(CHS[3003794], 21)
    self.idEdit:setPlaceholderFontSize(21)
    self.idEdit:setPlaceHolder(CHS[2200116])
    self.idEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.idEdit:setFontColor(cc.c3b(86, 41, 2))

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
    self.qqEdit:setPlaceHolder(CHS[2200117])
    self.qqEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.qqEdit:setFontColor(cc.c3b(86, 41, 2))

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
    self.telEdit:setPlaceHolder(CHS[2200118])
    self.telEdit:setPlaceholderFontSize(21)
    self.telEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.telEdit:setFontColor(cc.c3b(86, 41, 2))
end

function GatherRewardDlg:setMailInfo(info)
    local id = info.id
    local ts = info.date
    local data = os.time {year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local mailType = tonumber(info.type)
    self.id = id
    self.dataTime = data
    self.mailType = mailType
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", string.format(CHS[2200119], timeStr))
end

function GatherRewardDlg:onConfrimButton(sender, event)
    local items = {}

    local name = self.nameEdit:getText()
    if gf:getTextLength(name) == 0 then
        table.insert(items, CHS[2200120])
    end

    local idText = self.idEdit:getText()
    if gf:getTextLength(idText) == 0 then
        table.insert(items, CHS[2200121])
    end

    local tel = self.telEdit:getText()
    if gf:getTextLength(tel) == 0 then
        table.insert(items, CHS[2200122])
    end

    if #items > 0 then
        gf:ShowSmallTips(table.concat(items, CHS[2200123]) .. CHS[4300091])
        return
    end

    if not gf:chechCard(idText) then
        return
    end

    if not gf:checkPhoneNum(tel) then
        return
    end

    local qq = self.qqEdit:getText()
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", self.dataTime)
    if gf:getServerTime() > self.dataTime then
        gf:ShowSmallTips(string.format(CHS[2200124], timeStr))
        return
    end

    local id = self.id
    local mailType = self.mailType
    gf:confirm(CHS[2200125], function()
        gf:CmdToServer('CMD_MAILBOX_GATHER', {
            mail_type = mailType,
            mail_id = id,
            mail_oper = 1,
            ["qq"] = qq,
            ["tel"] = tel,
            ["id"] = idText,
            ["name"] = name,
        })
        DlgMgr:closeDlg("GatherRewardDlg")
    end)
end

return GatherRewardDlg