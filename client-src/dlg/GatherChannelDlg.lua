-- GatherChannelDlg.lua
-- Created by songcw Dec/03/2018
-- 渠道更改信息提交界面

local GatherChannelDlg = Singleton("GatherChannelDlg", Dialog)

local CONTENR_MAX = 10 * 2

local GATHER_TYPE = {
    GATHER_ITEM = 1,
    GATHER_MAIL = 2,
}

function GatherChannelDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)


    -- 姓名
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

    self:setCtrlVisible("DefaultLabel", false, "NamePanel")
    self.nameEdit:setPlaceholderFont(CHS[3003794], 21)
    self.nameEdit:setFont(CHS[3003794], 21)
    self.nameEdit:setPlaceHolder(CHS[4400041])
    self.nameEdit:setPlaceholderFontSize(21)
    self.nameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.nameEdit:setFontColor(cc.c3b(102, 102, 102))

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

    self:setCtrlVisible("DefaultLabel", false, "PhonePanel")
    self.telEdit:setPlaceholderFont(CHS[3003794], 21)
    self.telEdit:setFont(CHS[3003794], 21)
    self.telEdit:setPlaceHolder(CHS[4400042])
    self.telEdit:setPlaceholderFontSize(21)
    self.telEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.telEdit:setFontColor(cc.c3b(102, 102, 102))

    -- 新建角色
    self.playerEdit = self:createEditBox("InputPanel", "CharPanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.playerEdit:getText()
            if gf:getTextLength(newName) > CONTENR_MAX then
                newName = gf:subString(newName, CONTENR_MAX)
                self.playerEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end
        end

        local newName = self.playerEdit:getText()
        self:setCtrlVisible("DefaultLabel", gf:getTextLength(newName) == 0, "CharPanel")
    end)

    self:setCtrlVisible("DefaultLabel", true, "CharPanel")
    self.playerEdit:setPlaceholderFont(CHS[3003794], 21)
    self.playerEdit:setFont(CHS[3003794], 21)
    self.playerEdit:setPlaceHolder("")
    self.playerEdit:setPlaceholderFontSize(21)
    self.playerEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.playerEdit:setFontColor(cc.c3b(102, 102, 102))


        -- id
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

    self:setCtrlVisible("DefaultLabel_3", false, "IDPanel")
    self.idEdit:setPlaceholderFont(CHS[3003794], 21)
    self.idEdit:setFont(CHS[3003794], 21)
    self.idEdit:setPlaceHolder(CHS[4400043])
    self.idEdit:setPlaceholderFontSize(21)
    self.idEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.idEdit:setFontColor(cc.c3b(102, 102, 102))
end

function GatherChannelDlg:onConfrimButton(sender, eventType)
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

    local char = self.playerEdit:getText()
    if gf:getTextLength(char) == 0 then
        if content ~= "" then
            content = content .. CHS[6000084] .. CHS[4400038]
        else
            content = CHS[4400038]
        end
    end

    local id = self.idEdit:getText()
    if gf:getTextLength(id) == 0 then
        if content ~= "" then
            content = content .. CHS[6000084] .. CHS[4400039]
        else
            content = CHS[4400039]
        end
    end

    if content ~= "" then
        gf:ShowSmallTips(content .. CHS[4300091])
        return
    end
    local mail_id = self.id
    local mailType = self.mailType
            gf:CmdToServer('CMD_MAILBOX_GATHER', {
                mail_type = mailType,
                mail_id = mail_id,
                mail_oper = 1,
                ["name"] = name,
                ["tel"] = tel,
                ["char_name"] = char,
                ["char_id"] = id,
            })
end


function GatherChannelDlg:setMailInfo(info)
    local id = info.id
    local ts = info.date
    local data = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local mailType = tonumber(info.type)
    self.id = id
    self.dataTime = data
    self.type = GATHER_TYPE.GATHER_MAIL
    self.mailType = mailType
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", string.format(CHS[4400040], timeStr))
end


return GatherChannelDlg
