-- SafeLockModifyDlg.lua
-- Created by 
-- 

local SafeLockModifyDlg = Singleton("SafeLockModifyDlg", Dialog)

function SafeLockModifyDlg:init()
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "OldLockCodePanel")    
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "NewLockCodePanel")
    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "NewLockCodeAgainPanel")
    self:bindListener("ForgetButton", self.onForgetButton)
    self:bindListener("CancelButton", self.onCloseButton)
    self:bindListener("ConfirmlButton", self.onConfirmlButton)
    
    SafeLockMgr:bindInputToSafeLock(self.name, "OldLockCodePanel", 6)
    SafeLockMgr:bindInputToSafeLock(self.name, "NewLockCodePanel", 6)
    SafeLockMgr:bindInputToSafeLock(self.name, "NewLockCodeAgainPanel", 6)
end

function SafeLockModifyDlg:onForgetButton(sender, eventType)
    DlgMgr:openDlg("SafeLockForceReleaseDlg")
    self:onCloseButton()
end

function SafeLockModifyDlg:onCleanFieldButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    self:setLabelText("PasswordLabel", "", parentPanel)
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function SafeLockModifyDlg:onCancelButton(sender, eventType)
end

function SafeLockModifyDlg:onConfirmlButton(sender, eventType)
    if not SafeLockMgr.changeLockInfo then return end
    local code = self:getInputText("TextField", "NewLockCodePanel")
    local oldPwd = self:getInputText("TextField", "OldLockCodePanel")
    
    if oldPwd == "" then
        gf:ShowSmallTips(CHS[4200031])
        return false
    end
    
    if gf:getTextLength(oldPwd) < 4 then
        gf:ShowSmallTips(CHS[4200032])
        return false
    end
    
    if not gf:isOnlyLetterDigital(oldPwd) then
        gf:ShowSmallTips(CHS[4200033])
        return false
    end
    
 --   if not SafeLockMgr:isMeetCondition(code) then return end
    if code == "" then
        gf:ShowSmallTips(CHS[4200034])
        return false
    end
    
    if gf:getTextLength(code) < 4 then
        gf:ShowSmallTips(CHS[4200035])
        return false
    end
    
    if not gf:isOnlyLetterDigital(code) then
        gf:ShowSmallTips(CHS[4200036])
        return false
    end
    
    local codeAgain = self:getInputText("TextField", "NewLockCodeAgainPanel")
    if code ~= codeAgain then
        gf:ShowSmallTips(CHS[4200027]) -- 两次输入的密码不一致，请重新输入。
        return
    end
    
    
    SafeLockMgr:cmdChangeSafeLockPwd(SafeLockMgr.changeLockInfo.key, oldPwd, code)
    self:onCloseButton()
end

return SafeLockModifyDlg
