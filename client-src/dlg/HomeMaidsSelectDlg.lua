-- HomeMaidsSelectDlg.lua
-- Created by sujl, Sept/7/2017
-- 丫鬟选择界面

local HomeMaidsSelectDlg = Singleton("HomeMaidsSelectDlg", Dialog)

local MAIDS = HomeMgr:getMaidCfg()

function HomeMaidsSelectDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)

    self.maidPanel1 = self:getControl("MaidPanel_1")
    self:bindListener("HireButton", self.onHireButton1, self.maidPanel1)

    self.maidPanel2 = self:getControl("MaidPanel_2")
    self:bindListener("HireButton", self.onHireButton2, self.maidPanel2)

    self:initMaids()
    self:refreshNum()

    self:bindTipPanelTouchEvent("InfoPanel")

    self:hookMsg("MSG_HOUSE_ALL_YH_INFO")
end

function HomeMaidsSelectDlg:refreshNum()
    local maidData = HomeMgr:getMaidData() or {}
    local maidCount = #(maidData.npcs)
    local maidNumLimit = HomeMgr:getHomeMaidNumLimit() or 1
    self:setLabelText("ValueLabel", maidNumLimit - maidCount, "RemainTimesPanel")
end

function HomeMaidsSelectDlg:initMaids()
    local panel, maid
    for i = 1, #MAIDS do
        maid = MAIDS[i]
        panel = self:getControl(string.format("MaidPanel_%d", i))
        local modelPanel = self:getControl("ModelPanel", nil, panel)
        self:setPortrait("ModelPanel", maid.icon, 0, panel, true, nil, function()
            local char = modelPanel:getChildByTag(Dialog.TAG_PORTRAIT)
            char:playActionOnce(nil, Const.SA_CLEAN)
        end)
        panel.maid_type = maid.type
        self:setCtrlVisible("HireButton", not HomeMgr:getMaidByType(maid.type), panel)
        self:setCtrlVisible("AfterHireImage", HomeMgr:getMaidByType(maid.type), panel)
    end
end

function HomeMaidsSelectDlg:hire(index)
    local panel = self:getControl(string.format("MaidPanel_%d", index))
    if not panel then return end

    local maidType = panel.maid_type
    gf:CmdToServer('CMD_HOUSE_ADD_YH_INFO', { yh_type = maidType })
end

function HomeMaidsSelectDlg:onHireButton1(sender, eventType)
    self:hire(1)
end

function HomeMaidsSelectDlg:onHireButton2(sender, eventType)
    self:hire(2)
end

function HomeMaidsSelectDlg:onNoteButton(sender, eventType)
    self:setCtrlVisible("InfoPanel", true)
end

function HomeMaidsSelectDlg:MSG_HOUSE_ALL_YH_INFO(data)
    self:refreshNum()

    local panel, maid
    for i = 1, #MAIDS do
        maid = MAIDS[i]
        panel = self:getControl(string.format("MaidPanel_%d", i))
        self:setCtrlVisible("HireButton", not HomeMgr:getMaidByType(maid.type), panel)
        self:setCtrlVisible("AfterHireImage", HomeMgr:getMaidByType(maid.type), panel)
    end
end

return HomeMaidsSelectDlg