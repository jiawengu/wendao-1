-- WenquanjhDlg.lua
-- Created by huangzz Jan/21/2019
-- 玉露仙池-温泉玉露精华使用界面

local WenquanjhDlg = Singleton("WenquanjhDlg", Dialog)

function WenquanjhDlg:init(para)
    self:bindListener("UseButton", self.onUseButton)

    self:setImage("PortraitImage", ResMgr:getIconPathByName(CHS[5450460]))

    self:setLabelText("NumLabel", para.coin, "SpendPanel")

    self.coin = para.coin

    if string.isNilOrEmpty(para.player) then
        self:setCtrlEnabled("UseButton", true)
    else
        self:setCtrlEnabled("UseButton", false)
    end
end

function WenquanjhDlg:onUseButton(sender, eventType)
    -- 安全锁判断
    if self:checkSafeLockRelease("onUseButton") then
        return
    end

    gf:confirm(string.format(CHS[5450476], self.coin), function()
        gf:CmdToServer("CMD_XCWQ_USE_YLJH", {})
        self:onCloseButton()
    end)
end

return WenquanjhDlg
