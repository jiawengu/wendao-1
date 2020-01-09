-- GMBlockMacDlg.lua
-- Created by songcw Sep/29/2016
-- 封闭Mac

local GMBlockMacDlg = Singleton("GMBlockMacDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

function GMBlockMacDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCloseButton)
    
    self.mac = nil
    
    
    self.radioGroup = RadioGroup.new()    
    local CHECKBOXS = {}
    for i = 1,8 do
        CHECKBOXS[i] = "CheckBox_" .. i
    end
    self.radioGroup:setItems(self, CHECKBOXS, self.onReasonCheckBox)
end

function GMBlockMacDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("NameLabel", user.mac)
end

function GMBlockMacDlg:onConfirmButton(sender, eventType)
    local reason = self:getReason()
    local time = self:getInputText("InputTextField", "BlockTimePanel")
    if time == "" then time = 1 end
    if not tonumber(time) then
        gf:ShowSmallTips(CHS[3002694])
        return
    end
    local ti = tonumber(time) * 3600 
    if time == -1 then ti = -1 end
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

    if not self.user.mac or self.user.mac == "" then
        gf:ShowSmallTips(CHS[4300115])
        return
    end

    if self:isCheck("CheckBox") then
        GMMgr:cmdBlockMac(self.user.mac, ti, reason)
    else
        GMMgr:cmdBlockMac(self.user.mac, ti, reason)
    end
    self:onCloseButton()
end

function GMBlockMacDlg:onCancelButton(sender, eventType)
end

function GMBlockMacDlg:getReason()
    local ctrl = self.radioGroup:getSelectedRadio()
    if not ctrl then return "" end
    if ctrl:getName() ~= "CheckBox_8" then
        return self:getLabelText("Label", ctrl) or ""
    else
        return self:getInputText("InputTextField", "BlockReasonPanel") or ""
    end
end

return GMBlockMacDlg
