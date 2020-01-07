-- AppTreasureAcconutDlg.lua
-- Created by zhengjh Jun/26/2016
-- 运用宝账号中心界面

local AppTreasureAcconutDlg = Singleton("AppTreasureAcconutDlg", Dialog)

function AppTreasureAcconutDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

function AppTreasureAcconutDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

function AppTreasureAcconutDlg:setString(type)
    local str = ""
    if type == 1 then -- qq登录
        str = CHS[3002263]
    elseif type == 2 then -- wx登录
        str = CHS[3002264]
    end

    self:setLabelText("NoteLabel", str)
end

return AppTreasureAcconutDlg
