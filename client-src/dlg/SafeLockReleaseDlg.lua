-- SafeLockReleaseDlg.lua
-- Created by songcw May/27/2015
-- 安全锁验证(解锁)

local SafeLockReleaseDlg = Singleton("SafeLockReleaseDlg", Dialog)

function SafeLockReleaseDlg:init()
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("CancelButton", self.onCloseButton)
    self:bindListener("ConfirmlButton", self.onConfirmlButton)

    SafeLockMgr:bindInputToSafeLock(self.name, "InputLockCodePanel", 6)

    self:hookMsg("MSG_SAFE_LOCK_OPEN_UNLOCK")

    -- 设置弹出框的层级为确认框层级
    self.blank:setLocalZOrder(Const.ZORDER_DIALOG)

    -- 临时调整提示框层级，cleanup 中要调回
    SmallTipsMgr:setLocalZOrder(Const.ZORDER_LORDLAOZI_TIP, self.name)

    if SafeLockMgr.releaseLockInfo then
        self:setChanceCount(SafeLockMgr.releaseLockInfo.error_count_max - SafeLockMgr.releaseLockInfo.error_count)
    else
        self:setChanceCount("")
    end
end

function SafeLockReleaseDlg:cleanup()
    -- 调回提示框正常的层级
    SmallTipsMgr:setLocalZOrder(nil, self.name)
end

function SafeLockReleaseDlg:onCleanFieldButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    self:setLabelText("PasswordLabel", "", parentPanel)
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, parentPanel)
end

function SafeLockReleaseDlg:setChanceCount(count)
    self:setLabelText("TipsLabel_2", count)
end

function SafeLockReleaseDlg:onCloseButton()
    Dialog.onCloseButton(self)

    -- 清除安全锁的相关数据
    SafeLockMgr:clearLastRelaseEvent()
end

function SafeLockReleaseDlg:onConfirmlButton(sender, eventType)
    if not SafeLockMgr.releaseLockInfo then return end
    local code = self:getInputText("TextField", "InputLockCodePanel")

    if not SafeLockMgr:isMeetCondition(code) then return end
    SafeLockMgr:cmdUnLockSafeLock(SafeLockMgr.releaseLockInfo.key, code)
end

function SafeLockReleaseDlg:MSG_SAFE_LOCK_OPEN_UNLOCK(data)
    self:setChanceCount(SafeLockMgr.releaseLockInfo.error_count_max - SafeLockMgr.releaseLockInfo.error_count)
end

return SafeLockReleaseDlg