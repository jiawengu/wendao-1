-- SafeLockSetDlg.lua
-- Created by 
-- 

local SafeLockSetDlg = Singleton("SafeLockSetDlg", Dialog)

function SafeLockSetDlg:init()
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "SetLockCodePanel")
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "SetLockCodeAgainPanel")
    self:bindListener("CancelButton", self.onCloseButton)
    self:bindListener("ConfirmlButton", self.onConfirmlButton)
    
    SafeLockMgr:bindInputToSafeLock(self.name, "SetLockCodePanel", 6)
    SafeLockMgr:bindInputToSafeLock(self.name, "SetLockCodeAgainPanel", 6)
end

function SafeLockSetDlg:onCleanFieldButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    self:setLabelText("PasswordLabel", "", parentPanel)
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function SafeLockSetDlg:onConfirmlButton(sender, eventType)
    if not SafeLockMgr.setLockInfo then return end 
    local code = self:getInputText("TextField", "SetLockCodePanel")
    if not SafeLockMgr:isMeetCondition(code) then return end
    local codeAgain = self:getInputText("TextField", "SetLockCodeAgainPanel")
    if code ~= codeAgain then
        gf:ShowSmallTips(CHS[4200027]) -- 两次输入的密码不一致，请重新输入。
        return
    end    
    
    SafeLockMgr:cmdSetSafeLockPwd(SafeLockMgr.setLockInfo.key, code)
    self:onCloseButton()
end

return SafeLockSetDlg
