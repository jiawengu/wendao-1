-- DeadRemindDlg.lua
-- Created by songcw Feb/16/2015
-- 死亡提示提升界面

local DeadRemindDlg = Singleton("DeadRemindDlg", Dialog)

function DeadRemindDlg:init()
    self:setCtrlFullClientEx("BKPanel")
    self:bindListener("SkillButton", self.onSkillButton)
    self:bindListener("PetButton", self.onPetButton)
    self:bindListener("TaoButton", self.onTaoButton)
    self:bindListener("EquipButton", self.onEquipButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("ConfrimPanel", self.onConfrimButton)
    self:bindListener("MainPanel", self.onCloseButton)

    self:setCtrlEnabled("Image_164", false)
    self:setCtrlEnabled("Image_162", false)
    self:setCtrlEnabled("Image_163", false)
    self:getControl("MainPanel"):setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:getControl("BlackImage"):setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
end

function DeadRemindDlg:onSkillButton(sender, eventType)
    if Me:queryBasic("family") == "" or not GuideMgr:hasThisTab("SkillDlgCheckBox") then
        gf:ShowSmallTips(CHS[3002379])
        return
    end
    DlgMgr:openDlg("SkillDlg")
end

function DeadRemindDlg:onPetButton(sender, eventType)
    DlgMgr:openDlg("PetAttribDlg")
end

function DeadRemindDlg:onTaoButton(sender, eventType)
    local limitLevel = 45
    if Me:queryBasicInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3002380], limitLevel))
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('GetTaoTabDlg') or 'GetTaoDlg'
    DlgMgr:openDlg(last)
end

function DeadRemindDlg:onEquipButton(sender, eventType)
    local limitLevel = 35
    if Me:queryBasicInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3002380], limitLevel))
        return
    end

    DlgMgr:openTabDlg("EquipmentTabDlg")
end

function DeadRemindDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

return DeadRemindDlg
