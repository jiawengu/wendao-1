-- Confirm2Dlg.lua
-- Created by zhengjh Aug/05/2016
-- 教师节奖励对话框

local Confirm2Dlg = Singleton("Confirm2Dlg", Dialog)

function Confirm2Dlg:init()
    self:bindListener("ExpButton", self.onExpButton)
    self:bindListener("BonusButton", self.onBonusButton)
    self:bindListener("DealRecordButton_0", self.onDealRecordButton_0)
end

function Confirm2Dlg:setData(data)
    self.id = data.id
end

-- 选择经验
function Confirm2Dlg:onExpButton(sender, eventType)
    gf:CmdToServer("CMD_REPLY_SUBMIT_ZIKA", {id = self.id, operType = 1})
    DlgMgr:closeDlg(self.name)
end

-- 选择道行
function Confirm2Dlg:onBonusButton(sender, eventType)
    gf:CmdToServer("CMD_REPLY_SUBMIT_ZIKA", {id = self.id, operType = 2})
    DlgMgr:closeDlg(self.name)
end

-- 取消
function Confirm2Dlg:onDealRecordButton_0(sender, eventType)
    gf:CmdToServer("CMD_REPLY_SUBMIT_ZIKA", {id = self.id, operType = 0})
    DlgMgr:closeDlg(self.name)
end

return Confirm2Dlg
