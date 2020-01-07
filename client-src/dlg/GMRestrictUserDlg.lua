-- GMRestrictUserDlg.lua
-- Created by songcw Feb/29/2016
-- 禁闭角色界面

local GMRestrictUserDlg = Singleton("GMRestrictUserDlg", Dialog)

function GMRestrictUserDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
end

function GMRestrictUserDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("NameLabel", gf:getRealName(user.name), "UserNamePanel")
    self:setLabelText("GIDLabel", gf:getShowId(user.gid), "UserGIDPanel")
end

function GMRestrictUserDlg:onConfirmButton(sender, eventType)
    -- 原因
    local reason = self:getInputText("InputTextField", "RestrictReasonPanel") or ""
    
    local time = self:getInputText("InputTextField", "RestrictTimePanel")
    if time == "" then time = 1 end
    if not tonumber(time) or tonumber(time) < 0 then
        gf:ShowSmallTips(CHS[3002716])
        return
    end
    local ti = (tonumber(time) or 0) * 3600 
    if ti == 0 then
        if reason == "" then
            gf:ShowSmallTips(CHS[3002717])
            return
        end
    else
        if reason == "" then
            gf:ShowSmallTips(CHS[3002718])
            return
        end
    end
    
    GMMgr:cmdThrowInJail(self.user.name, self.user.gid, ti, reason)
    self:onCloseButton()
end

function GMRestrictUserDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMRestrictUserDlg
