-- PartyWarInstructionDlg.lua
-- Created by liuhb Apr/7/2015
-- 帮战介绍

local PartyWarInstructionDlg = Singleton("PartyWarInstructionDlg", Dialog)

function PartyWarInstructionDlg:init()
    if not PartyMgr.isNewParty then
		self:setLabelText("SignUpLabel_1", CHS[4101176], "NewListView")
        self:setLabelText("ScheduleLabel_1", CHS[4101177], "NewListView")
        self:setLabelText("RuleLabel_1", CHS[4101178], "NewListView")
        self:setLabelText("BonusWinLabel_8", CHS[4101197], "NewListView")
    end

    local list = self:getControl("ListView")
    if list then
        list:setVisible(false)
    end

    local nList = self:getControl("NewListView")
    nList:setClippingEnabled(true)
    nList:setBounceEnabled(true)
    nList:setVisible(true)

    local dlg = DlgMgr:getDlgByName("PartyWarInfoDlg")
    if dlg then
        local data = dlg:getData()
        self:setLabelText("GroupWinLabel_13", string.format( CHS[4300462], data.needActive), "NewListView")
        self:setLabelText("KnockoutWinLabel_14", string.format( CHS[4300462], data.needActive), "NewListView")
    end
end

function PartyWarInstructionDlg:onSelectListView(sender, eventType)
end

return PartyWarInstructionDlg
