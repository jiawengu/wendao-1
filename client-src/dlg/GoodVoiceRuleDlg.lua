-- GoodVoiceRuleDlg.lua
-- Created by
--

local GoodVoiceRuleDlg = Singleton("GoodVoiceRuleDlg", Dialog)

function GoodVoiceRuleDlg:init()
    self:bindListViewListener("ListView_316", self.onSelectListView_316)

    local data = GoodVoiceMgr.seasonData

    -- 声音上传时间
    local time1 = gf:getServerDate("%m-%d %H:%M", data.upload_start)
    local time2 = gf:getServerDate("%m-%d %H:%M", data.upload_end)
    local str1 = string.format( CHS[4200682], time1, time2)
    self:setLabelText("ResourceLabel2", str1, "ResourcePanel3")

    -- 声援阶段
    local time1 = gf:getServerDate("%m-%d %H:%M", data.canvass_start)
    local time2 = gf:getServerDate("%m-%d %H:%M", data.canvass_end)
    local str1 = string.format( CHS[4200683], time1, time2)
    self:setLabelText("ResourceLabel6", str1, "ResourcePanel3")

    -- 初选阶段
    local time1 = gf:getServerDate("%m-%d %H:%M", data.primary_election_start)
    local time2 = gf:getServerDate("%m-%d %H:%M", data.primary_election_end)
    local str1 = string.format( CHS[4200684], time1, time2)
    self:setLabelText("ResourceLabel9", str1, "ResourcePanel3")

    -- 总选阶段
    local time1 = gf:getServerDate("%m-%d %H:%M", data.final_election_start)
    local time2 = gf:getServerDate("%m-%d %H:%M", data.final_election_end)
    local str1 = string.format( CHS[4200685], time1, time2)
    self:setLabelText("ResourceLabel12", str1, "ResourcePanel3")
end

function GoodVoiceRuleDlg:onSelectListView_316(sender, eventType)
end

return GoodVoiceRuleDlg
