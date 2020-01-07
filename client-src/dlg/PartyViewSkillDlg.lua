-- PartyViewSkillDlg.lua
-- Created by Chang_Back Oct/22/2015
-- 帮派技能查看界面

local PartyViewSkillDlg = Singleton("PartyViewSkillDlg", Dialog)

local checkBoxTab = {[CHS[3003289]] = "RawCheckBox", [CHS[3003290]] = "DevelopCheckBox"}

function PartyViewSkillDlg:init()
    self:bindListener("LastButton", self.onLastButton)
    self:bindListener("NextButton", self.onNextButton)

    self.showType = CHS[3003289]

    for k, v in pairs(checkBoxTab) do
        self:bindListener(v, self.onCheckbox)
    end

    self.listView = self:getControl("SkillListView", Const.UIListView)
    self.clonePanel = self:getControl("SkillPanel_1", Const.UIPanel)
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
    self.listView:removeAllItems()
    self:hookMsg("MSG_PARTY_BRIEF_INFO")
end

function PartyViewSkillDlg:setPartyTitle(party)
    if not party then return end
    self:setLabelText("IDLabel", gf:getShowId(party.partyId))
    self:setLabelText("NameLabel", party.partyName)
    local levelName, num = PartyMgr:getCHSLevelAndPeopleMax(party.partyLevel)
    self:setLabelText("LevelLabel", levelName)
    local constructStr = gf:getMoneyDesc(party.construct, true)
    self:setLabelText("ConstructionLabel", constructStr)
    self:setLabelText("MemberLabel", party.population .. "/" .. num)
end

function PartyViewSkillDlg:getPartyInfo(party, nextOrLast)
    if not next(PartyMgr.partyListInfo) then
        return
    end

    local tempParty = nil

    for k, v in pairs(PartyMgr.partyListInfo) do
        if v.partyId == party.partyId then
            if nextOrLast == "next" then
                tempParty = PartyMgr.partyListInfo[k + 1]
            else
                tempParty = PartyMgr.partyListInfo[k - 1]
            end
        end
    end

    if nextOrLast == "next" and tempParty then
        self:setCtrlVisible("NextButton", true)
    elseif nextOrLast == "next" and not tempParty then
        self:setCtrlVisible("NextButton", false)
    end

    if nextOrLast == "last" and tempParty then
        self:setCtrlVisible("LastButton", true)
    elseif nextOrLast == "last" and not tempParty then
        self:setCtrlVisible("LastButton", false)
    end

    return tempParty
end

function PartyViewSkillDlg:setPartyInfo(party, showType)
    -- 需要判断是否是空值
    -- 如果在
    if nil == party or nil == party.skill then return end

    self.curParty = party
    -- 天生技能

    if not showType then showType = self.showType end

    self:setLabelText("SkillDescLabel", "")
    self:setPartyTitle(party)
    local checkbox = self:getControl(checkBoxTab[showType], Const.UICheckBox)
    self.listView:removeAllItems()
    self:onCheckbox(checkbox, ccui.TouchEventType.ended)
end

function PartyViewSkillDlg:getPartySkillByType(showType)
    local studySkill = {[1] = CHS[3004249], [2] = CHS[3004247], [3] = CHS[3004248],[4] = CHS[3004250]}
    local boonSkill = {[1] = CHS[3004233],   [2] = CHS[3004234],   [3] = CHS[3004235],  [4] = CHS[3004236], [5] = CHS[3004237], [6] = CHS[3004238],
                       [7] = CHS[3004239], [8] = CHS[3004240], [9] = CHS[3004241], [10] = CHS[3004242], [11] = CHS[3004243], [12] = CHS[3004244], [13] = CHS[3004245],[14] = CHS[3004246],}

--                          五色光环                法力护盾            移花接木            舍身取义
    local studySkill = {[1] = CHS[3004249], [2] = CHS[3004247], [3] = CHS[3004248],[4] = CHS[3004250]}

    if skillType == CHS[3004258] then
        return boonSkill
    elseif skillType == CHS[3004257] then
        return studySkill
    else
        local skillTab = {}
        for i = 1,#boonSkill do
            table.insert(skillTab, boonSkill[i])
        end
        for i = 1,#studySkill do
            table.insert(skillTab, studySkill[i])
        end
        return skillTab
    end
end

function PartyViewSkillDlg:showSkillByType(showType)
    self.listView:removeAllItems()

    local party = self.curParty
    local innerSkills = PartyMgr:getPartySkillByType(showType)
    local i = 1

    for k = 1, #innerSkills do --in pairs(innerSkills) do
        local v = innerSkills[k]
        local skillName = v
        local panel = self.clonePanel:clone()
        if skillName then
            local skill = self:getSkillByName(skillName, party) or {no = 0, name = "", level = 0, currentScore = 0, levelupScore = 0}
            skill.icon = SkillMgr:getSkillIconPath(skill.no)

            if skill.level ~= 0 or skill.currentScore ~= 0 then
                self:setImage("Image", skill.icon, panel)
                self:setItemImageSize("Image", panel)
                self:setLabelText("NameLabel", skill.name, panel)
                self:setLabelText("LevelLabel", skill.level, panel)
                self:setLabelText("DevelopLabel_1", skill.currentScore, panel)
                self:setLabelText("DevelopLabel_3", skill.levelupScore, panel)
                self:setLabelText("DevelopLabel_4", math.floor(skill.currentScore * 100 / skill.levelupScore) .. "%", panel)
                self:setProgressBar("DevelopProgressBar", skill.currentScore, skill.levelupScore, panel)

                panel:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self.curSkillName = skillName
                        self:onItemTouch(sender,eventType)
                    end
                end)

                self.listView:pushBackCustomItem(panel)

                if i == 1 then
                    self.curSkillName = skillName
                    self:onItemTouch(panel, ccui.TouchEventType.ended)
                end

                if i % 2 == 0 then
                    self:setCtrlVisible("BackImage_1", false, panel)
                    self:setCtrlVisible("BackImage_2", true, panel)
                else
                    self:setCtrlVisible("BackImage_1", true, panel)
                    self:setCtrlVisible("BackImage_2", false, panel)
                end

                i = i + 1
            end

        end
    end

    local last = self:getPartyInfo(self.curParty, "last")
    local next = self:getPartyInfo(self.curParty, "next")

    if not last then
        self:setCtrlVisible("LastButton", false)
    else
        self:setCtrlVisible("LastButton", true)
    end

    if not next then
        self:setCtrlVisible("NextButton", false)
    else
        self:setCtrlVisible("NextButton", true)
    end

end

function PartyViewSkillDlg:onCheckbox(sender, eventType)
    for k, v in pairs(checkBoxTab) do
        self:setCheck(v, false)
    end
    sender:setSelectedState(true)

    self.showType = CHS[3003289]

    if sender:getName() ~= "RawCheckBox" then
        self.showType = CHS[3003290]
    end

    self:showSkillByType(self.showType)
end

function PartyViewSkillDlg:onItemTouch(sender, eventType)
    local skillDesc = SkillMgr:getSkillDesc(self.curSkillName)
    self:setLabelText("SkillDescLabel", skillDesc.pet_desc)

    local items = self.listView:getItems()
    for k, v in pairs(items) do
        self:setCtrlVisible("ChosenBackImage", false, v)
    end

    self:setCtrlVisible("ChosenBackImage", true, sender)
end

function PartyViewSkillDlg:getSkillByName(name, party)
    if not party or not next(party.skill) then return end
    for index, skill in pairs(party.skill) do
        if skill.name == name then return skill end
    end

    return nil
end

function PartyViewSkillDlg:onNextButton(sender, eventType)
    local party = self:getPartyInfo(self.curParty, "next")
    if not party then return end

    gf:CmdToServer("CMD_QUERY_PARTY", {id = party.partyId, name = party.partyName, type = "brief"})
end

function PartyViewSkillDlg:onLastButton(sender, eventType)
    local party = self:getPartyInfo(self.curParty, "last")
    if not party then return end

    gf:CmdToServer("CMD_QUERY_PARTY", {id = party.partyId, name = party.partyName, type = "brief"})
end

function PartyViewSkillDlg:MSG_PARTY_BRIEF_INFO(data)
    self:setPartyInfo(data, self.showType)
end

function PartyViewSkillDlg:cleanup()
    self:releaseCloneCtrl("clonePanel")
    if self.curParty then
        DlgMgr:sendMsg("JoinPartyDlg", "selectPartyById", self.curParty.partyId)
    end
end

return PartyViewSkillDlg
