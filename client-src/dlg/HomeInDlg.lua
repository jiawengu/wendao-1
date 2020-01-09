-- HomeInDlg.lua
-- Created by sujl, Jan/23/2017
-- 返回居所

local HomeInDlg =  Singleton("HomeInDlg", Dialog)

local HOUSE_NAME = { CHS[2000277], CHS[2000278], CHS[2000279] }

function HomeInDlg:init()
    self:bindListener("HomeInButton", self.onHomeInButton)
    self:bindListener("HomeOutButton", self.onHomeOutButton)

    local isInMyHome = MapMgr:isInHouse(MapMgr:getCurrentMapName()) and HomeMgr:getHouseId() == Me:queryBasic("house/id")
    self:setCtrlVisible("HomeInButton", not isInMyHome)
    self:setCtrlVisible("HomeOutButton", isInMyHome)

    -- 居所名称
    local myData = HomeMgr:getMyHomeData()
    local homeType = myData.houseType
    self:setLabelText("NameLabel", HomeMgr:getMyHomePrefix() .. HOUSE_NAME[homeType], "HomePanel")
    self:setCtrlVisible("HomeImage_1", HOME_TYPE.xiaoshe == homeType, "HomePanel")
    self:setCtrlVisible("HomeImage_2", HOME_TYPE.yazhu == homeType, "HomePanel")
    self:setCtrlVisible("HomeImage_3", HOME_TYPE.haozhai == homeType, "HomePanel")

    -- 舒适度
    self:setLabelText("TimeLabel_1", string.format("%d/%d", myData.comfort, HomeMgr:getMaxComfort()), "ComfortPanel")
    self:setProgressBar("ProgressBar", myData.comfort, HomeMgr:getMaxComfort(homeType), "ComfortPanel")

    -- 清洁值
    self:setLabelText("TimeLabel_1", string.format("%d/%d", HomeMgr:getClean(), HomeMgr:getMaxClean()), "CleanPanel")
    self:setProgressBar("ProgressBar", myData.cleanliness , HomeMgr:getMaxClean(), "CleanPanel")
end

function HomeInDlg:onHomeInButton(sender, eventType)
    if not HomeMgr:checkFly(true) then return end

    if HomeMgr:checkRedName(true) then
        self:onCloseButton()
        return
    end

    gf:CmdToServer('CMD_HOUSE_GO_HOME')
    self:onCloseButton()
end

function HomeInDlg:onHomeOutButton(sender, eventType)
    if GameMgr.inCombat then
        -- 战斗中不可进行此操作。
        gf:ShowSmallTips(CHS[4000223])
        return
    end

    if Me:isLookOn() then
        -- 观战中不可进行此操作。
        gf:ShowSmallTips(CHS[3002640])
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        -- 在队伍中但不是队长
        if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
            gf:ShowSmallTips(CHS[5000078])
            return
        end

        gf:CmdToServer("CMD_CACHE_AUTO_WALK_MSG", {autoWalkStr = CHS[2200063]})
    end

    self:onCloseButton()
end

return HomeInDlg
