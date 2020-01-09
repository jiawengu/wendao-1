-- GMBlockAccountDlg.lua
-- Created by songcw Feb/29/2016
-- 封闭账号界面

local GMBlockAccountDlg = Singleton("GMBlockAccountDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

function GMBlockAccountDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self.radioGroup = RadioGroup.new()    
    local CHECKBOXS = {}
    for i = 1,8 do
        CHECKBOXS[i] = "CheckBox_" .. i
    end
    self.radioGroup:setItems(self, CHECKBOXS, self.onReasonCheckBox)
end

function GMBlockAccountDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("AccountLabel", user.account, "AccountPanel")
end

function GMBlockAccountDlg:getReason()
    local ctrl = self.radioGroup:getSelectedRadio()
    if not ctrl then return "" end
    if ctrl:getName() ~= "CheckBox_8" then
        return self:getLabelText("Label", ctrl) or ""
    else
        return self:getInputText("InputTextField", "BlockReasonPanel") or ""
    end
end

function GMBlockAccountDlg:onConfirmButton(sender, eventType)
    local reason = self:getReason()
    
    
    local time = self:getInputText("InputTextField", "BlockTimePanel")
    if time == "" then time = 1 end
    if not tonumber(time) or tonumber(time) < 0 then
        gf:ShowSmallTips(CHS[3002694])
        return
    end
    local ti = tonumber(time) * 3600 
    if ti == 0 then
        if reason == "" then
            gf:ShowSmallTips(CHS[3002695])
            return
        end
    else
        if reason == "" then
            gf:ShowSmallTips(CHS[3002696])
            return
        end
    end

    if self:isCheck("CheckBox") then
        GMMgr:cmdBlockAccount(self.user.account, ti, reason, 1)
    else
        GMMgr:cmdBlockAccount(self.user.account, ti, reason, 0)
    end
    self:onCloseButton()
end

function GMBlockAccountDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMBlockAccountDlg
