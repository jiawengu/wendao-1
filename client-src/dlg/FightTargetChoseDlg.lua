-- FightTargetChoseDlg.lua
-- Created by cheny Dec/2/2014
-- 头像对话框

local FightTargetChoseDlg = Singleton("FightTargetChoseDlg", Dialog)

function FightTargetChoseDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
end

function FightTargetChoseDlg:onReturnButton()
    if FightMgr.useFastSkill then
        if Me:queryBasicInt('c_attacking_id') == Me:getId() then
            local dlg = DlgMgr:showDlg('FightPlayerMenuDlg', true)
            if dlg then
                dlg:updateFastSkillButton()
            end
        else
            local dlg = DlgMgr:showDlg('FightPetMenuDlg', true)
            if dlg then
                dlg:updateFastSkillButton()
            end
        end

        Me.op = ME_OP.FIGHT_ATTACK
        self:setVisible(false)
        FightMgr.useFastSkill = false
        return
    end

    if Me.op == ME_OP.FIGHT_CATCH then
        local dlg = DlgMgr:showDlg('FightPlayerMenuDlg', true)
        if dlg then
            dlg:updateFastSkillButton()
        end
    elseif Me.op == ME_OP.FIGHT_SKILL or Me.op == ME_OP.FIGHT_ATTACK then
        local skillDlg = 'FightPetSkillDlg'
        if Me:queryBasicInt('c_attacking_id') == Me:getId() then
            skillDlg = 'FightPlayerSkillDlg'
        elseif HomeChildMgr:getFightKid() then
            skillDlg = 'FightChildSkillDlg'
        end

        DlgMgr:showDlg(skillDlg, true)
    elseif Me.op == ME_OP.FIGHTING_PROPERTY_ME then
        -- 判断是否是对己方人员使用道具，如果是的话，则重新显示
        DlgMgr:showDlg("FightUseResDlg", true)
    else

    end

    FightMgr.useFastSkill = false
    self:setVisible(false)
    Me.op = ME_OP.FIGHT_ATTACK
end

function FightTargetChoseDlg:setTips(tips, cmdDesc)
    self:setLabelText('SkillNameLabel', tips, "MainPanel")
    self:setLabelText('TargetChoseLabel', cmdDesc, "MainPanel")

    self:setLabelText('SkillNameLabel', tips, "MainPanel2")
    self:setLabelText('TargetChoseLabel', cmdDesc, "MainPanel2")

    self:setLabelText('SkillNameLabel', tips, "MainPanel3")
    self:setLabelText('TargetChoseLabel', cmdDesc, "MainPanel3")

    local descLen = string.len(cmdDesc)
    self:setCtrlVisible("MainPanel", descLen < 30)
    self:setCtrlVisible("MainPanel2", descLen >= 30 and descLen < 90)
    self:setCtrlVisible("MainPanel3", descLen >= 90)
end

return FightTargetChoseDlg
