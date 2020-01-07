-- DossierTipsDlg.lua
-- Created by lixh May/25/2018
-- 探案-探案卷宗备注界面

local DossierTipsDlg = Singleton("DossierTipsDlg", Dialog)

function DossierTipsDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindEditFieldForSafe("RemarksPanel", 50, "DelButton", cc.TEXT_ALIGNMENT_LEFT, nil, true)
end

function DossierTipsDlg:setData(data)
    if data then
        self.taskName = data.taskName
        self.state = data.state
        self.index = data.index
        self.lastRemarks = data.remarks or ""

        self:setLabelText("TitleLabel", string.format(CHS[7190238], gf:numberToChs(data.index)))

        if not string.isNilOrEmpty(data.remarks) then
            local panel = self:getControl("RemarksPanel")
            self:setInputText("TextField", data.remarks, panel)
            self:setCtrlVisible("DelButton", true, panel)
            self:setCtrlVisible("DefaultLabel", false, panel) 
        end
    end
end

function DossierTipsDlg:onDelButton(sender, eventType)
    local panel = self:getControl("RemarksPanel")
    self:setInputText("TextField", "", panel)
    self:getControl("DelButton"):setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

function DossierTipsDlg:onCloseButton(sender, eventType)
    if self.index then
        local text = self:getInputText("TextField", "RemarksPanel")
        if text ~= self.lastRemarks then
            gf:CmdToServer("CMD_DETECTIVE_TASK_CLUE_MEMO", {taskName = self.taskName, state = self.state, remarks = text})

            -- 备注保存到服务器后，客户端自己刷新一下，卷轴界面对应备注数据
            DlgMgr:sendMsg("DossierDlg", "refreshRemarks", self.index, text)
        end
    end

    DlgMgr:closeDlg(self.name)
end

function DossierTipsDlg:cleanup()
    self.index = nil
    self.lastRemarks = ""
    self.taskName = ""
    self.state = ""
end

return DossierTipsDlg
