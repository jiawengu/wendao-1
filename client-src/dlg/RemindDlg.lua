-- RemindDlg.lua
-- Created by zhengjh Aug/10/2015
-- 没开启录音提示框

local RemindDlg = Singleton("RemindDlg", Dialog)

function RemindDlg:init(data)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    if data then
        self:setLableString(data)
    end
end

function RemindDlg:setLableString(string)
    self:setLabelText("PromptLabel", string)
end

function RemindDlg:onConfirmButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return RemindDlg
