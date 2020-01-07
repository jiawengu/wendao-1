-- NewPartyWarInstructionDlg.lua
-- Created by songcw
-- 新帮主规则说明界面

local NewPartyWarInstructionDlg = Singleton("NewPartyWarInstructionDlg", Dialog)

function NewPartyWarInstructionDlg:init()
    self:bindListViewListener("ListView1", self.onSelectListView1)
    self:bindListViewListener("ListView2", self.onSelectListView2)

    local data = PartyWarMgr:getNewPartyWarData()
    if data then
        self:setCtrlVisible("ListView1", data.stage == tonumber(COMP_STAGE.GROUP_STAGE))
        self:setCtrlVisible("ListView2", data.stage ~= tonumber(COMP_STAGE.GROUP_STAGE))
    end

    local dlg = DlgMgr:getDlgByName("PartyWarInfoDlg")
    if dlg then
        local data = dlg:getData()

        local panel = self:getControl("InfoPanel1", nil, "ListView1")
        self:setLabelText("ResourceLabel_6", string.format( CHS[4300463], data.needActive), panel)

        local panel = self:getControl("InfoPanel1", nil, "ListView2")
        self:setLabelText("ResourceLabel_6", string.format( CHS[4300463], data.needActive), panel)
    end
end

function NewPartyWarInstructionDlg:onSelectListView1(sender, eventType)
end

function NewPartyWarInstructionDlg:onSelectListView2(sender, eventType)
end

return NewPartyWarInstructionDlg
