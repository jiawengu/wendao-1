-- GMBlockUserDlg.lua
-- Created by songcw Feb/29/2016
-- 封闭角色界面 

local GMBlockUserDlg = Singleton("GMBlockUserDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

function GMBlockUserDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self.radioGroup = RadioGroup.new()    
    local CHECKBOXS = {}
    for i = 1,8 do
        CHECKBOXS[i] = "CheckBox_" .. i
    end
    self.radioGroup:setItems(self, CHECKBOXS, self.onReasonCheckBox)
end

function GMBlockUserDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("NameLabel", gf:getRealName(user.name), "UserNamePanel")
    self:setLabelText("GIDLabel", gf:getShowId(user.gid), "UserGIDPanel")
end

function GMBlockUserDlg:getReason()
    local ctrl = self.radioGroup:getSelectedRadio()
    if not ctrl then return "" end
    if ctrl:getName() ~= "CheckBox_8" then
        return self:getLabelText("Label", ctrl) or ""
    else
        return self:getInputText("InputTextField", "BlockReasonPanel") or ""
    end
end

function GMBlockUserDlg:onConfirmButton(sender, eventType)
    local reason = self:getReason()
    local time = self:getInputText("InputTextField", "BlockTimePanel")
    if time == "" then time = 1 end
    if not tonumber(time) or tonumber(time) < 0 then
        gf:ShowSmallTips(CHS[3002697])
        return
    end
    
    local ti = tonumber(time) * 3600 
    if ti == 0 then
        if reason == "" then
            gf:ShowSmallTips(CHS[3002698])
            return
        end
    else
        if reason == "" then
            gf:ShowSmallTips(CHS[3002699])
            return
        end
    end
    if self:isCheck("CheckBox") then
        GMMgr:cmdBlockUser(self.user.name, self.user.gid, ti, reason, 1)
    else
        GMMgr:cmdBlockUser(self.user.name, self.user.gid, ti, reason, 0)
    end
    self:onCloseButton()
end

function GMBlockUserDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMBlockUserDlg
