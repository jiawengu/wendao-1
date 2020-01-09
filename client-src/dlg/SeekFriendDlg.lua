-- SeekFriendDlg.lua
-- Created by songcw Oct/22/2018
-- 寻找好友界面

local SeekFriendDlg = Singleton("SeekFriendDlg", Dialog)

-- 随机的头像图标
local ORG_ICON = {
    6001, 6002, 6003, 6004, 6005, 7001, 7002, 7003, 7004, 7005
}

local REFREASH_TIME = 0.5  -- 匹配时刷新的时间

function SeekFriendDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)

    self.curIdx = nil       -- 当前显示icon的索引
    self:setFriend()
    self:matching()
    self.schedulId = gf:Schedule(function()
        self:matching()
    end, REFREASH_TIME)
end

function SeekFriendDlg:setFriend(friend)
    if not friend then
        self:setLabelText("NameLabel", "？")
        self:setLabelText("LevelLabel", "")
        self:setImagePlist("OccupationImage", ResMgr.ui.touming)
        return
    end

    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end

    self:setCtrlEnabled("CancelButton", false)

    self:setImage("PortraitImage", ResMgr:getSmallPortrait(friend.icon))
    self:setImage("OccupationImage", self:getPolarImagePath(friend.polar))
    self:setLabelText("NameLabel", friend.name)
    self:setLabelText("LevelLabel", string.format( CHS[6000179], friend.level))
    self:setLabelText("InforLabel", CHS[4010229])

end

function SeekFriendDlg:getPolarImagePath(polar)
    if polar == CHS[3004297] or polar == 1 then
        return ResMgr.ui.combatStatusDlg_polar_metal
    elseif polar == CHS[3004298] or polar == 2 then
        return ResMgr.ui.combatStatusDlg_polar_wood
    elseif polar == CHS[3004299] or polar == 3 then
        return ResMgr.ui.combatStatusDlg_polar_water
    elseif polar == CHS[3004300] or polar == 4 then
        return ResMgr.ui.combatStatusDlg_polar_fire
    elseif polar == CHS[3004301] or polar == 5 then
        return ResMgr.ui.combatStatusDlg_polar_earth
    end
end

function SeekFriendDlg:getRandomIdx(curIdx)
    local idx = math.random( 1, #ORG_ICON )
    if idx == curIdx then
        return self:getRandomIdx(curIdx)
    end

    return idx
end

function SeekFriendDlg:matching()
    self.curIdx = self:getRandomIdx(self.curIdx)
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(ORG_ICON[self.curIdx]))
end

function SeekFriendDlg:cleanup()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function SeekFriendDlg:onCloseButton(sender, eventType)
    self:onCancelButton()
end

function SeekFriendDlg:onCancelButton(sender, eventType)
    gf:CmdToServer("CMD_BJTX_FIND_FRIEND")
end

return SeekFriendDlg
