-- FightLookOnDlg.lua
-- Created by zhengjh Jan/05/2016
-- 观战

local FightLookOnDlg = Singleton("FightLookOnDlg", Dialog)

function FightLookOnDlg:init()
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("SkipButton", self.onSkipButton)
    self:setFullScreen()

    self:setCtrlVisible("ExitButton", true)
    self:setCtrlVisible("SkipButton", false)
end

function FightLookOnDlg:swicthSkipModel()
    self:setCtrlVisible("ExitButton", false)
    self:setCtrlVisible("SkipButton", true)
end

function FightLookOnDlg:onExitButton(sender, eventType)
    FightMgr:cmdQuitLookOn()
end

function FightLookOnDlg:onSkipButton(sender, eventType)
    FightMgr:cmdSkipLookOn()
end

return FightLookOnDlg
