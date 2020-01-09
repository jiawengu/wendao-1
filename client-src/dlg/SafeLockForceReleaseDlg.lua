-- SafeLockForceReleaseDlg.lua
-- Created by songcw May/27/2015
-- 

local SafeLockForceReleaseDlg = Singleton("SafeLockForceReleaseDlg", Dialog)

function SafeLockForceReleaseDlg:init()
    self:bindListener("ConfirmlButton", self.onConfirmlButton)
end

function SafeLockForceReleaseDlg:onConfirmlButton(sender, eventType)
    SafeLockMgr:cmdResetSafeLock(1)
    self:onCloseButton()
end

return SafeLockForceReleaseDlg
