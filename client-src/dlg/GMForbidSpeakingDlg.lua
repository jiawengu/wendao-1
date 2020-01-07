-- GMForbidSpeakingDlg.lua
-- Created by song Feb/27/2016
-- GM 禁言玩家对话框

local GMForbidSpeakingDlg = Singleton("GMForbidSpeakingDlg", Dialog)

function GMForbidSpeakingDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self:setCheck("CurrentCheckBox", true)
    self:setCheck("WorldCheckBox", true)
    self:setCheck("PartyCheckBox", true)
    self:setCheck("TeamCheckBox", true)
    self:setCheck("FriendCheckBox", true)
	self:setCheck("GroupCheckBox", true)
    self:setCheck("HornCheckBox", true)
end

function GMForbidSpeakingDlg:setDlgInfoByUser(user)
    self.user = user
    self:setLabelText("NameLabel", gf:getRealName(user.name), "UserNamePanel")
    self:setLabelText("GIDLabel", gf:getShowId(user.gid), "UserGIDPanel")
end

function GMForbidSpeakingDlg:onConfirmButton(sender, eventType)
    -- 原因
    local reason = self:getInputText("InputTextField", "ForbidReasonPanel") or ""
    
    -- 频道
    local channel = ""
    if self:isCheck("CurrentCheckBox") then
        channel = channel .. "current"
    end
    if self:isCheck("WorldCheckBox") then
        if channel == "" then
            channel = channel .. "world"
        else
            channel = channel .. "|world"
        end        
    end
    if self:isCheck("PartyCheckBox") then
        if channel == "" then
            channel = channel .. "party"
        else
            channel = channel .. "|party"
        end
    end
    if self:isCheck("TeamCheckBox") then
        if channel == "" then
            channel = channel .. "team"
        else
            channel = channel .. "|team"
        end
    end
    if self:isCheck("FriendCheckBox") then
        if channel == "" then
            channel = channel .. "friend"
        else
            channel = channel .. "|friend"
        end
    end
    -- 群组
    if self:isCheck("GroupCheckBox") then
        if channel == "" then
            channel = channel .. "chat_group"
        else
            channel = channel .. "|chat_group"
        end
    end
    
    -- 喇叭
    if self:isCheck("HornCheckBox") then
        if channel == "" then
            channel = channel .. "horn"
        else
            channel = channel .. "|horn"
        end
    end

    local time = self:getInputText("InputTextField", "ForbidTimePanel")
    if time == "" then time = 1 end
    if not tonumber(time) or tonumber(time) < 0 then
        gf:ShowSmallTips(CHS[3002706])
        return
    end
    -- 禁言时间按秒
    local ti = tonumber(time) * 3600 
    if ti == 0 then
        if reason == "" then
            gf:ShowSmallTips(CHS[3002707])
            return 
        end
        
        if channel == "" then
            gf:ShowSmallTips(CHS[3002708])
            return 
        end
    else
        if reason == "" then
            gf:ShowSmallTips(CHS[3002709])
            return 
        end

        if channel == "" then
            gf:ShowSmallTips(CHS[3002710])
            return 
        end
    end
    
    GMMgr:cmdShutChannelPlayer(self.user.name, self.user.gid, ti, channel, reason)
    self:onCloseButton()
end

function GMForbidSpeakingDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

return GMForbidSpeakingDlg
