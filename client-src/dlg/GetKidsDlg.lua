-- GetKidsDlg.lua
-- Created by huangzz Feb/21/2019
-- 恭喜怀孕界面

local GetKidsDlg = Singleton("GetKidsDlg", Dialog)

function GetKidsDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")

    self:bindListener("ContinueButton", self.onCloseButton)

    self.angel = 0
    self.rotationImage = self:getControl("RotationImage")
end

function GetKidsDlg:onUpdate()
    self.angel = self.angel + 0.8
    self.rotationImage:setRotation(self.angel)
end

return GetKidsDlg
