-- PartyAppointDlg.lua
-- Created by Chang_back Jun/18/2015
-- 任命界面

local PartyAppointDlg = Singleton("PartyAppointDlg", Dialog)

local BUTTON_CTRL =
    {
        [CHS[3003219]] = "SucceedButton", [CHS[3003220]] = "DeputyLeaderButton",
        [CHS[3003221]] = "XuanwButton", [CHS[3003222]] = "ZhuqButton", [CHS[3003223]] = "BaihButton",
        [CHS[3003224]] = "QinglButton", [CHS[3003225]] = "CanglButton", [CHS[3003226]] = "YuanlButton",
        [CHS[3003227]] = "JianfButton", [CHS[3003228]] = "YefButton", [CHS[3003229]] = "YunhButton",
        [CHS[3003230]] = "DexButton", [CHS[3003231]] = "SuxButton",
        [CHS[3003232]] = "HuwButton", [CHS[3003233]] = "AnlButton", [CHS[3003234]] = "ZiyButton",
        [CHS[3003235]] = "TingxButton", [CHS[3003236]] = "MengxButton", [CHS[3003237]] = "XuanfButton",
        [CHS[3003238]] = "MemberButton",
    }

function PartyAppointDlg:init()
    --[[
    self:bindListener("SucceedButton", self.onSucceedButton)
    self:bindListener("DeputyLeaderButton", self.onDeputyLeaderButton)
    self:bindListener("XuanwButton", self.onXuanwButton)
    self:bindListener("ZhuqButton", self.onZhuqButton)
    self:bindListener("BaihButton", self.onBaihButton)
    self:bindListener("QinglButton", self.onQinglButton)
    self:bindListener("CanglButton", self.onCanglButton)
    self:bindListener("YuanlButton", self.onYuanlButton)
    self:bindListener("JianfButton", self.onJianfButton)
    self:bindListener("YefButton", self.onYefButton)
    self:bindListener("YunhButton", self.onYunhButton)
    self:bindListener("DexButton", self.onDexButton)
    self:bindListener("SuxButton", self.onSuxButton)
    self:bindListener("AnlButton", self.onAnlButton)
    self:bindListener("HuwButton", self.onHuwButton)
    self:bindListener("ZiyButton", self.onZiyButton)
    self:bindListener("TingxButton", self.onTingxButton)
    self:bindListener("MengxButton", self.onMengxButton)
    self:bindListener("XuanfButton", self.onXuanfButton)

    --]]
    local partyInfo = PartyMgr:getPartyInfo()
    local levelInfo = PartyMgr:getCHSLevelAndPeopleMax(partyInfo.partyLevel)
    self:setTipByLevel(levelInfo)

    for k, v in pairs(BUTTON_CTRL) do
        local button = self:getControl(v, Const.UIButton)
        self:setCtrlVisible("Image", false, button)

        if levelInfo == CHS[3003239] then
            if k ~= CHS[3003220] and k ~= CHS[3003219] and k ~= CHS[3003238] then
                self:setCtrlEnabled(v, false)
            end
        end

        if levelInfo == CHS[3003240] then
            if gf:findStrByByte(k, CHS[3003241]) then
                self:setCtrlEnabled(v, true)
            elseif k ~= CHS[3003220] and k ~= CHS[3003219] and k ~= CHS[3003238] then
                self:setCtrlEnabled(v, false)
            end
        end

        if levelInfo == CHS[3003242] then
            if gf:findStrByByte(k, CHS[3003241]) or gf:findStrByByte(k, CHS[3003243]) then
                self:setCtrlEnabled(v, true)
            elseif k ~= CHS[3003220] and k ~= CHS[3003219] and k ~= CHS[3003238] then
                self:setCtrlEnabled(v, false)
            end
        end

        if levelInfo == CHS[3003244] then
            if gf:findStrByByte(k, CHS[3003241]) or gf:findStrByByte(k, CHS[3003243]) or gf:findStrByByte(k, CHS[3003245]) then
                self:setCtrlEnabled(v, true)
            elseif k ~= CHS[3003220] and k ~= CHS[3003219] and k ~= CHS[3003238] then
                self:setCtrlEnabled(v, false)
            end
        end

        self:bindListener(v, self.onOnderSelect)
    end

    self:bindListener("CancelSucceedButton", self.onOnderSelect)
end

function PartyAppointDlg:setTipByLevel(levelInfo)
    if levelInfo == CHS[3003239] then
        self:setLabelText("NoteLabel", CHS[3003246])
    elseif levelInfo == CHS[3003240] then
        self:setLabelText("NoteLabel", CHS[3003247])
    elseif levelInfo == CHS[3003242] then
        self:setLabelText("NoteLabel", CHS[3003248])
    elseif levelInfo == CHS[3003244] then
        self:setLabelText("NoteLabel", CHS[4300080])
    end
end

function PartyAppointDlg:setInfo(queryMember, heir)
    self.queryMember = queryMember
    self.heir = heir

    if PartyMgr:isPartyLeader() then
        if self.heir == nil or self.heir == "" then
            -- 帮派没有帮主继承人，第一个显示传位
            self:setCtrlVisible("SucceedButton", true)
            self:setCtrlVisible("CancelSucceedButton", false)
        else
            self:setCtrlEnabled("SucceedButton", false)
            self:setCtrlVisible("CancelSucceedButton", true)
        end
    else
        self:setCtrlEnabled("SucceedButton", false)
        self:setCtrlVisible("CancelSucceedButton", false)
        self:setCtrlVisible("SucceedButton", true)
    end


    local partyInfo = PartyMgr:getPartyInfo()  -- 通过帮派管理器获取帮派信息

    for k, v in pairs(partyInfo.leader) do
        for name, buttonName in pairs(BUTTON_CTRL) do
            if name == v.job and v.name ~= CHS[3003249] then
                self:setCtrlEnabled(buttonName, false)  -- 此职位已经有人了，就将该职位置灰
                local button = self:getControl(buttonName, Const.UIButton)
                self:setCtrlVisible("Image", true, button)
            end
            local jobName = PartyMgr:getJobName(queryMember.job)
            if jobName == name then
                self:setCtrlEnabled(buttonName, false)  -- 不能任命相同的职位，相同的职位置灰
            end
        end
    end
end

function PartyAppointDlg:getControlByChineseName(name)
    for k, v in pairs(BUTTON_CTRL) do
        local button = self:getControl(v, Const.UIButton)
        local btnName = button:getTitleText()

        if gf:findStrByByte(k, name) then
            return button, btnName
        end
    end
end

---- 事件处理 ----

function PartyAppointDlg:onOnderSelect(sender, eventType)
    local jobName = sender:getTitleText()
    local jobId = PartyMgr:getJobID(jobName)
    local ctrlName = sender:getName()

    if ctrlName == "SucceedButton" or ctrlName == "CancelSucceedButton" then
        if self.heir == "" then
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            end
            PartyMgr:demiseMember(self.queryMember.name, self.queryMember.gid)
        else
            PartyMgr:cancelDemiseMember()
        end
        self:onCloseButton()
        return
    end

    -- 任命
    local function sendApplyCmd()
        PartyMgr:applyMember(self.queryMember.name, self.queryMember.gid, jobId)
    end

    -- [4000155] = "你确认任命#Y%s#n为#R%s#n？",
    local tips = string.format(CHS[4000155], self.queryMember.name, jobName)
    gf:confirm(tips, sendApplyCmd)
    self:onCloseButton()
end

function PartyAppointDlg:getJobName(job)
    if job == nil or job == "" then return end
    local pos = gf:findStrByByte(job, ":")
    if pos == 0 then return end

    return string.sub(job, 0, pos - 1)
end

return PartyAppointDlg
