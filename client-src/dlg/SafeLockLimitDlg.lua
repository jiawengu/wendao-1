-- SafeLockLimitDlg.lua
-- Created by songcw May/27/2016
-- 安全锁限制界面

local SafeLockLimitDlg = Singleton("SafeLockLimitDlg", Dialog)

function SafeLockLimitDlg:init()
    self:bindListener("ConfirmlButton", self.onCloseButton)
    self:setLabelText("TipsLabel_3", "")
    
    self:getControl("TipsLabel_1"):setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self:getControl("TipsLabel_1"):setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
end

function SafeLockLimitDlg:setHourglass(hourglassTime)
    if not hourglassTime then return end
    self.hourglassTime = hourglassTime - gf:getServerTime()
    self:setTime()
    schedule(self.root, function() self:updateHourglass() end, 1)
end

function SafeLockLimitDlg:updateHourglass()
    if self.hourglassTime > 0 then
        self.hourglassTime = self.hourglassTime - 1
        self:setTime()
    else
        self.root:stopAllActions()
        self.hourglassTime = 0
    end
end

function SafeLockLimitDlg:setTime()
    local min = math.floor(self.hourglassTime / 60)
    local sec = math.floor(self.hourglassTime % 60)
    self:setLabelText("TipsLabel_3", string.format(CHS[3002678], min, sec))
end

return SafeLockLimitDlg
