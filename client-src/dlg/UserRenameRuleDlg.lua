-- UserRenameRuleDlg.lua
-- Created by sujl June/15/2016

local UserRenameRuleDlg = Singleton("UserRenameRuleDlg", Dialog)

local PANEL_NAME = {
    "UserRenameRulePanel",
    "UserResexRulePanel",
    "UserFactionRulePanel",
}

function UserRenameRuleDlg:init(type)
    self:setCtrlVisible("UserRenameRulePanel", false)
    self:setCtrlVisible("UserResexRulePanel", false)
    self:setCtrlVisible("UserFactionRulePanel", false)
    self:setCtrlVisible("ChannelUserRenameRulePanel", false)
    
    if PANEL_NAME[type] then
        self:setCtrlVisible(PANEL_NAME[type], true)
    end
    
    if type == 1 then
        self:setCtrlVisible("UserRenameRulePanel", LeitingSdkMgr:isLeiting())
        self:setCtrlVisible("ChannelUserRenameRulePanel", not LeitingSdkMgr:isLeiting())
    end
end

return UserRenameRuleDlg
