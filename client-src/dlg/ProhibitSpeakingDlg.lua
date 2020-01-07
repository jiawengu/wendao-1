-- ProhibitSpeakingDlg.lua
-- Created by songcw Mar/21/2015
-- 禁言

local ProhibitSpeakingDlg = Singleton("ProhibitSpeakingDlg", Dialog)

function ProhibitSpeakingDlg:init()
    self:bindListener("TwelveHourButton", self.onTwelveHourButton)
    self:bindListener("CancelButton", self.onCancelButton)
    
    self.queryMember = nil
    self.root:setAnchorPoint(0, 0)
end

function ProhibitSpeakingDlg:speakCondition()    
    if Me:queryBasic("name") == self.queryMember.name then
        gf:ShowSmallTips(CHS[4000201])
        return false
    end

    local pos = gf:findStrByByte(self.queryMember.job, ":")
    if string.sub(self.queryMember.job, 1, pos - 1) == CHS[4000153] then
        gf:ShowSmallTips(CHS[4000202])
        return false
    end

    return true
end

function ProhibitSpeakingDlg:setQueryMember(member)
    self.queryMember = member
end

function ProhibitSpeakingDlg:onTwelveHourButton(sender, eventType)
    if self:speakCondition() == false then return end
    if self.queryMember == nil then return end
    PartyMgr:prohibitSpeaking(self.queryMember, 1, 12)
    self:onCloseButton()
end

function ProhibitSpeakingDlg:onCancelButton(sender, eventType)
    if self.queryMember == nil then return end
    PartyMgr:prohibitSpeaking(self.queryMember, 2, 0)
    self:onCloseButton()
end

return ProhibitSpeakingDlg
