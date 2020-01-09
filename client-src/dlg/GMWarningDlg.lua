-- GMWarningDlg.lua
-- Created by songcw Feb/24/2016
-- GM 警告角色界面对话框

local GMWarningDlg = Singleton("GMWarningDlg", Dialog)

function GMWarningDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self:align(ccui.RelativeAlign.centerInParent)
end

function GMWarningDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("NameLabel", gf:getRealName(user.name), "UserNamePanel")
    self:setLabelText("GIDLabel", gf:getShowId(user.gid), "UserGIDPanel")
end

function GMWarningDlg:onConfirmButton(sender, eventType)
    local content = self:getInputText("InputTextField", "MailContentPanel")
    if content == "" then
        gf:ShowSmallTips(CHS[3002727])
        return
    end
    
    local title = self:getInputText("InputTextField", "MailTitlePanel")        
    local day = self:getInputText("InputTextField", "MailVaildTimePanel")
    if day == "" then day = 1 end
    if not tonumber(day) or tonumber(day) < 0 then
        gf:ShowSmallTips(CHS[3002728])
        return
    end
    day = tonumber(day)
    GMMgr:cmdWainingPlayer(self.user.name, self.user.gid, title, content, day)
    self:onCloseButton()
end

function GMWarningDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMWarningDlg
