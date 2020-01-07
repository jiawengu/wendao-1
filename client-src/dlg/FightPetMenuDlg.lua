-- FightPetMenuDlg.lua
-- Created by cheny Dec/2/2014
-- 战斗中宠物操作菜单界面

local FightPetMenuDlg = Singleton("FightPetMenuDlg", Dialog)

function FightPetMenuDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("SkillButton", self.onSkillButton)
    self:bindListener("UseItemButton", self.onUseItemButton)
    self:bindListener("DefenseButton", self.onDefenseButton)
    self:bindListener("FastSkillButton", self.onFastSkillButton)
    self:updateFastSkillButton()
end

function FightPetMenuDlg:updateFastSkillButton()

    if Me:queryBasicInt("c_pet_finished_cmd") == 1 then
        self:setCtrlVisible("FastSkillButton", false)
        return
    end

    -- 重置顿悟标记
    SkillMgr:removeDunWuSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))

    -- 重置法宝技能标记
    SkillMgr:removeArtifactSpSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))

    local skill = tonumber(FightMgr.fastSkill.Pet)
    if not skill or skill == -1 then
        self:setCtrlVisible("FastSkillButton", false)
    else
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        local petSkill = SkillMgr:getSkill(pet:getId(), skill)
        if not petSkill then
            self:setCtrlVisible("FastSkillButton", false)
        elseif petSkill and petSkill.skill_disabled == 1 then
            -- 如果该技能被禁用，不显示该快捷技能
            self:setCtrlVisible("FastSkillButton", false)
        else
            self:setCtrlVisible("FastSkillButton", true)
            local path = SkillMgr:getSkillIconPath(skill)
            if petSkill then
                if pet:queryInt("mana") < petSkill.skill_mana_cost or not SkillMgr:isPetDunWuSkillCanUse(pet:getId(), petSkill) then
                    -- 普通技能缺少魔法，或者顿悟技能缺少怒气/魔法/灵气
                    self:blindLongPress("FastSkillButton",
                        function(dlg, sender, eventType)
                            self:OneSecondLater(sender, eventType, 2, skill)
                        end, function(dlg, sender, eventType)
                            self:onFastSkillButton(sender,eventType)
                        end)
                    self:setCtrlVisible("NoManaImage", true, "FastSkillButton")
                else
                    self:blindLongPress("FastSkillButton",
                        function(dlg, sender, eventType)
                            self:OneSecondLater(sender, eventType, nil, skill)
                        end, function(dlg, sender, eventType)
                            self:onFastSkillButton(sender,eventType)
                        end)
                    self:setCtrlVisible("NoManaImage", false, "FastSkillButton")
                end
            end

            if not SkillMgr:isArtifactSpSkillCanUse(petSkill.skill_name) then
                self:setCtrlVisible("NoManaImage", true, "FastSkillButton")
            end

            self:setImage("SkillImage", path, "FastSkillButton")
            self:setItemImageSize("SkillImage", "FastSkillButton")

            -- 如果是顿悟技能，要加上顿悟标记
            if SkillMgr:isPetDunWuSkill(pet:getId(), petSkill.skill_name) then
                SkillMgr:addDunWuSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))
            end

            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
            if SkillMgr:isArtifactSpSkill(petSkill.skill_name) then
                SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))
            end
        end
    end
end

function FightPetMenuDlg:OneSecondLater(sender, eventType, type, skillNo)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), pet:getId(), true, rect, type)
end

-- 返回
function FightPetMenuDlg:onReturnButton(sender, eventType)
    self:setVisible(false)

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet then
        Me:setBasic('c_attacking_id', -1)
        gf:sendFightCmd(pet:getId(), pet:getId(), FIGHT_ACTION.CANCEL, 0)
    end
    FightMgr.useFastSkill = false
end

-- 技能
function FightPetMenuDlg:onSkillButton(sender, eventType)
    if not SkillMgr:haveCombatSkill(Me:queryBasicInt('c_attacking_id')) then
        if HomeChildMgr:getFightKid() then
            gf:ShowSmallTips(CHS[7100438])
        else
            gf:ShowSmallTips(CHS[3002607])
        end

        return
    end

    self:setVisible(false)

    local dlg
    if HomeChildMgr:getFightKid() then
        dlg = DlgMgr:showDlg('FightChildSkillDlg', true)
    else
        dlg = DlgMgr:showDlg('FightPetSkillDlg', true)
    end

    if dlg then
        dlg:initSkill()
    end
    FightMgr.useFastSkill = false
end

-- 快速使用技能
function FightPetMenuDlg:onFastSkillButton(sender, eventType)
    local skill = tonumber(FightMgr.fastSkill.Pet)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

    local skillName = SkillMgr:getSkillName(skill)

    -- 选中了法宝特殊技能
    if SkillMgr:isArtifactSpSkill(skillName) then
        local nimbus = EquipmentMgr:getEquippedArtifactNimbus()
        if nimbus < SkillMgr:getArtifactSpSkillCostNimbus(skillName) then
            -- 法宝灵气是否充足
            gf:ShowSmallTips(CHS[7000314])
            return false
        end
    end

    if skillName == CHS[3001942] and Me:queryInt("diandqk_frozen_round") >= FightMgr:getCurRound() then
        -- 颠倒乾坤处于冷却中
        gf:ShowSmallTips(CHS[7003002])
        return
    end

    if not skill or skill ~= -1 then
        -- 选中只能对宠物自身释放的技能(法力护盾、移花接木、养精蓄锐)
        if not HomeChildMgr:getFightKid() and SkillMgr:canUseSkillOnlyToSelf(skill, "pet") then
            -- 娃娃没有只能对自身释放的技能
            local curRoundLeftTime = FightMgr:getRoundLeftTime()
            self.confirmDlg = gf:confirm(string.format(CHS[7150020], skillName), function()
                -- 玩家确认后直接选择宠物自身
                Me.op = ME_OP.FIGHT_SKILL
                Me:setBasic('sel_skill_no', skill)
                self:setVisible(false)

                FightMgr:getObjectById(pet:getId()):onSelectChar()
            end, function()
                if self.confirmDlg and self.confirmDlg.hourglassTime < 1 then
                    -- 倒计时确认框自动取消时，不需要重新显示技能选择界面
                    self:setVisible(false)
                    return
                end

                Me.op = ME_OP.FIGHT_ATTACK
                Me:setBasic('sel_skill_no', 0)
                self:setVisible(true)
            end, nil, curRoundLeftTime - 1)

            if self.confirmDlg then
                self.confirmDlg:setCombatOpenType()
            end

            return
        end

        self:setVisible(false)
        Me.op = ME_OP.FIGHT_SKILL
        Me:setBasic('sel_skill_no', skill)

        local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
        local cmdDesc = SkillMgr:getSkillCmdDesc(pet:getId(), skill)
        dlg:setTips(SkillMgr:getSkillName(skill), cmdDesc)
        FightMgr.useFastSkill = true
    end
end

-- 道具
function FightPetMenuDlg:onUseItemButton(sender, eventType)
    self:setVisible(false)
    local dlg = DlgMgr:showDlg("FightUseResDlg", true)
    dlg:getItemsInFight()
    FightMgr.useFastSkill = false
end

-- 防御
function FightPetMenuDlg:onDefenseButton(sender, eventType)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet then
        gf:sendFightCmd(pet:getId(), pet:getId(), FIGHT_ACTION.DEFENSE, 0)
    end

    FightMgr:changeMeActionFinished()
    self:setVisible(false)
    FightMgr.useFastSkill = false
end

return FightPetMenuDlg
