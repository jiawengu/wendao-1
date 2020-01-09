-- FightPlayerMenuDlg.lua
-- Created by cheny Dec/2/2014
-- 战斗中 me 操作菜单界面

local FightPlayerMenuDlg = Singleton("FightPlayerMenuDlg", Dialog)

function FightPlayerMenuDlg:init()
    self:setFullScreen()
    self:bindListener("AutoFightButton", self.onAutoFightButton)
    self:bindListener("UseSkillButton", self.onUseSkillButton)
    self:bindListener("UseItemButton", self.onUseItemButton)
    self:bindListener("DefenseButton", self.onDefenseButton)
    self:bindListener("CatchButton", self.onCatchButton)
    self:bindListener("CallPetButton", self.onCallPetButton)
    self:bindListener("CallBackPetButton", self.onCallBackPetButton)
    self:bindListener("EscapeButton", self.onEscapeButton)
    self:bindListener("FastSkillButton", self.onFastSkillButton)
    self:updateFastSkillButton()
end

function FightPlayerMenuDlg:updateFastSkillButton()
    if Me:queryBasicInt("c_me_finished_cmd") == 1 then
        self:setCtrlVisible("FastSkillButton", false)
        return
    end

    -- 重置法宝特殊技能标记
    SkillMgr:removeArtifactSpSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))

    local skill = tonumber(FightMgr.fastSkill.Me.skillNo)
    local isQinMiWuJianCopySkill = FightMgr.fastSkill.Me.isQinMiWuJianCopySkill
    if not skill or skill == -1 then
        self:setCtrlVisible("FastSkillButton", false)
    else
        self:setCtrlVisible("FastSkillButton", true)
        local path = SkillMgr:getSkillIconPath(skill)
        local mySkill = SkillMgr:getSkill(Me:getId(), skill)
        local skillName = SkillMgr:getSkillName(skill)
        if not mySkill and (SkillMgr:isArtifactSpSkillByNo(skill) or isQinMiWuJianCopySkill) then
            -- 如果法宝特殊技能/亲密无间复制的宠物技能已经不存在了，则隐藏FastSkillButton
            self:setCtrlVisible("FastSkillButton", false)
        elseif mySkill and mySkill.skill_disabled == 1 then
            -- 如果该技能被禁用，不显示快捷技能
            self:setCtrlVisible("FastSkillButton", false)
        end

        if mySkill then
            local skillName = SkillMgr:getSkillName(skill)
            local isQinMiWuJianSkill = SkillMgr:isQinMiWuJianCopySkill(skillName, Me:getId())
            local hasEnoughNimbus = SkillMgr:isArtifactSpSkillCanUse(CHS[3001947])

            -- 法力不足/是亲密无间复制的技能但法宝灵气不足/法宝特殊技能法宝灵气不足
            if Me:queryInt("mana") < mySkill.skill_mana_cost
                    or (isQinMiWuJianSkill and not hasEnoughNimbus)
                    or not SkillMgr:isArtifactSpSkillCanUse(skillName)then
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
            -- 如果是法宝特殊技能，要加上法宝特殊技能标识
            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                SkillMgr:addArtifactSpSkillImage(self:getControl("SkillImage", nil, "FastSkillButton"))
            end
        end

        self:setImage("SkillImage", path, "FastSkillButton")
        self:setItemImageSize("SkillImage", "FastSkillButton")
    end
end

-- 自动战斗
function FightPlayerMenuDlg:onAutoFightButton(sender, eventType)
    self:AutoFightStatus()
    FightMgr.useFastSkill = false
end

function FightPlayerMenuDlg:OneSecondLater(sender, eventType, type, skillNo)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), Me:getId(), false, rect, type)
end

-- 自动战斗状态
function FightPlayerMenuDlg:AutoFightStatus()
    if Me:queryBasicInt('auto_fight') == 0  then
        Me:setBasic('auto_fight', 1)
        AutoFightMgr:autoFightSiwchStatus(1)

        if self.onEscapeBtn then
            -- 点击逃跑时，AutoFightMgr:autoFightSiwchStatus 请求自动战斗技能信息时，服务器不会回
            -- 所以需要通过 CMD_AUTO_FIGHT_INFO 再请求下  WDSY-33938
            gf:CmdToServer("CMD_AUTO_FIGHT_INFO")
        end

        -- 隐藏选中圈圈
        FightMgr:showSelectImg(false)

        DlgMgr:closeDlg('FightPlayerMenuDlg')
        DlgMgr:openDlg("AutoFightSettingDlg")
    end
end

-- 快速使用技能
function FightPlayerMenuDlg:onFastSkillButton(sender, eventType)
    local skill = tonumber(FightMgr.fastSkill.Me.skillNo)
    local skillName = SkillMgr:getSkillName(skill)

    if not skill or skill ~= -1 then

        -- 如果是亲密无间复制的宠物技能
        if SkillMgr:isQinMiWuJianCopySkill(skillName, Me:getId()) then
            local pet = PetMgr:getFightPet()
            if not pet or not SkillMgr:getSkill(pet:getId(), skill) then
                gf:ShowSmallTips(CHS[7000318])
                return
            end

            if EquipmentMgr:getEquippedArtifactNimbus() < SkillMgr:getArtifactSpSkillCostNimbus(CHS[3001947]) then
                gf:ShowSmallTips(CHS[7000317])
                return
            end
        end

        -- 选中了法宝特殊技能
        if SkillMgr:isArtifactSpSkill(skillName) then
            local nimbus = EquipmentMgr:getEquippedArtifactNimbus()
            if nimbus < SkillMgr:getArtifactSpSkillCostNimbus(skillName) then
                -- 法宝灵气是否充足
                gf:ShowSmallTips(CHS[7000314])
                return false
            end
        end

        Me.op = ME_OP.FIGHT_SKILL

        -- 选中只能对人物自身释放的技能(法力护盾、移花接木)
        if SkillMgr:canUseSkillOnlyToSelf(skill, "me") then
            local curRoundLeftTime = FightMgr:getRoundLeftTime()
            self.confirmDlg = gf:confirm(string.format(CHS[7150019], skillName), function()
                -- 玩家确认后直接选择角色自身
                Me:setBasic('sel_skill_no', skill)
                self:setVisible(false)

                FightMgr:getObjectById(Me:getId()):onSelectChar()
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
        Me:setBasic('sel_skill_no', skill)

        local dlg = DlgMgr:openDlg('FightTargetChoseDlg')
        local cmdDesc = SkillMgr:getSkillCmdDesc(Me:getId(), skill)
        dlg:setTips(SkillMgr:getSkillName(skill), cmdDesc)
        FightMgr.useFastSkill = true
    end
end

-- 技能
function FightPlayerMenuDlg:onUseSkillButton(sender, eventType)
    if not SkillMgr:haveCombatSkill(Me:getId()) then
        if not BattleSimulatorMgr:isRunning() then
            gf:ShowSmallTips(CHS[3002608])
            return
        end
    end

    self:setVisible(false)
    local dlg = DlgMgr:showDlg('FightPlayerSkillDlg', true)
    if dlg then
        dlg:initSkill()
    end
    FightMgr.useFastSkill = false

    GuideMgr:needCallBack("UseSkillButton")
end

-- 道具
function FightPlayerMenuDlg:onUseItemButton(sender, eventType)
    self:setVisible(false)
    local dlg = DlgMgr:showDlg("FightUseResDlg", true)
    dlg:getItemsInFight()
    FightMgr.useFastSkill = false
end

-- 防御
function FightPlayerMenuDlg:onDefenseButton(sender, eventType)
    gf:sendFightCmd(Me:getId(), Me:getId(), FIGHT_ACTION.DEFENSE, 0)
    FightMgr:changeMeActionFinished()
    FightMgr.useFastSkill = false
end

-- 捕捉
function FightPlayerMenuDlg:onCatchButton(sender, eventType)
    if not FightMgr.notCatchCondition and PetMgr:getFreePetCapcity() <= 0 then
        -- 携带宠物已达上限
        gf:ShowSmallTips(CHS[3000030])
        return
    end

    Me.op = ME_OP.FIGHT_CATCH
    self:setVisible(false)
    local dlg = DlgMgr:showDlg('FightTargetChoseDlg', true)
    dlg:setTips(CHS[3000001], CHS[3002609])
    FightMgr.useFastSkill = false
end

-- 召唤宠物
function FightPlayerMenuDlg:onCallPetButton(sender, eventType)
    -- 如果宠物处于虚无状态，不可召唤
    local pet = PetMgr:getFightPet()
    if pet and FightMgr:getObjectById(pet:getId()) and FightMgr:getObjectById(pet:getId()):isXuWu() then
        gf:ShowSmallTips(string.format(CHS[7000275], pet:getShowName()))
        return
    end

    local lst = PetMgr:getCanCallPets()
    if #lst <= 0 then
        gf:ShowSmallTips(CHS[3002610])
        return
    end

    self:setVisible(false)
    DlgMgr:showDlg('FightCallPetMenuDlg', true)
    FightMgr.useFastSkill = false
end

-- 召回宠物
function FightPlayerMenuDlg:onCallBackPetButton(sender, eventType)
    local pet = PetMgr:getFightPet()
    local kid = HomeChildMgr:getFightKid()
    local fightObj = pet
    local confirmTips = CHS[2000112]
    if Me:isInCombat() and kid then
        fightObj = kid
        confirmTips = CHS[7100439]
    end

    if not fightObj or not FightMgr:getObjectById(fightObj:getId()) then
        gf:ShowSmallTips(CHS[2000111])
        return
    end

    -- 如果宠物处于虚无状态，不可召回
    if FightMgr:getObjectById(fightObj:getId()):isXuWu() then
        gf:ShowSmallTips(string.format(CHS[7000275], fightObj:getShowName()))
        return
    end

    local dlg = gf:confirm(confirmTips, function()
        gf:sendFightCmd(Me:getId(), fightObj:getId(), FIGHT_ACTION.CALLBACK_PET, 0)
        FightMgr:changeMeActionFinished()
        FightMgr.useFastSkill = false
    end)

    if dlg then
        dlg:setCombatOpenType()
    end
end

-- 逃跑
function FightPlayerMenuDlg:onEscapeButton(sender, eventType)
    gf:sendFightCmd(Me:getId(), Me:getId(), FIGHT_ACTION.FLEE, 0)
    FightMgr:changeMeActionFinished()
    FightMgr.useFastSkill = false
    self.onEscapeBtn = true
end

-- 如果需要使用指引通知类型，需要重载这个函数
function FightPlayerMenuDlg:youMustGiveMeOneNotify(param)
    if "hasPet" == param then
        if PetMgr:getFightPet() then
            GuideMgr:youCanDoIt(self.name, param)
        else
            GuideMgr:youCanDoIt(self.name)
        end
    end
end

-- 2015 06/30 by liuyw
-- 在对话框中设置仅仅显示（自动）一个按钮
function FightPlayerMenuDlg:showOnlyAutoFightButton(isOnly)
    self:setCtrlVisible("UseSkillButton", not isOnly)   --不显示法术
    self:setCtrlVisible("UseItemButton", not isOnly)    --不显示道具
    self:setCtrlVisible("DefenseButton", not isOnly)    --不显示防御
    self:setCtrlVisible("CallPetButton", not isOnly)    --不显示召唤
    self:setCtrlVisible("CallBackPetButton", not isOnly)--不显示召回
    self:setCtrlVisible("CatchButton", not isOnly)      --不显示捕获
    self:setCtrlVisible("EscapeButton", not isOnly)     --不显示逃跑
    if not isOnly then
        self:updateFastSkillButton()
    else
        self:setCtrlVisible("FastSkillButton", false)
    end
end

function FightPlayerMenuDlg:cleanup()
    self.onEscapeBtn = nil
end

return FightPlayerMenuDlg
