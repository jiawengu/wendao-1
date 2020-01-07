-- PracticeMapChooseDlg.lua
-- Created by zhengjh Mar/7/2015
-- 扫荡和挂机选择界面

local SWEEPTIMELIMIT = 10 -- 扫荡次数

local CONST_DATA = 
{
  [1] =  CHS[6000055],
  [2] =  CHS[6000056],
  [3] =  CHS[6000057],
  [4] =  CHS[6000058],
  [5] =  CHS[6000059],
  [6] =  CHS[6000060],
  [7] =  CHS[6000061],
  [8] =  CHS[6000062],
  [9] =  CHS[6000063],
  [10] = CHS[6000064],
  PracticeLimitTimes = 100,
}

local PracticeMapChooseDlg = Singleton("PracticeMapChooseDlg", Dialog)

function PracticeMapChooseDlg:init()
    self:bindListener("SweepButton", self.onSweepButton)
    self:bindListener("PatrolButton", self.onPatrolButton)
    
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_AUTO_PRACTICE_BONUS")
    self:MSG_UPDATE()
end

function PracticeMapChooseDlg:setMonster(monster)
    self.monster = monster
end

function PracticeMapChooseDlg:onSweepButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003500])
        return
    end
    PracticeMgr:sweep(self.timesStr, self.monster["mapName"])
end

function PracticeMapChooseDlg:MSG_AUTO_PRACTICE_BONUS()
    local dlg = DlgMgr:openDlg("PracticeRewardDlg")
    dlg:setMapName(self.monster["mapName"])
end

function PracticeMapChooseDlg:onPatrolButton(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003500])
        return
    end
    
    if Me:isTeamMember() == true then
        gf:ShowSmallTips(CHS[6000156])
        return
    end
    
    local x, y = self:flyPosition()
    if x ~= nil and y ~= nil then
        local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", self.monster["mapName"], self.monster["mapName"], x, y)
        AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
        PracticeMgr:closeDlgAndSendMisc()
    end
end

-- 刷新扫荡次数
function PracticeMapChooseDlg:MSG_UPDATE()
    local sweepBtn = self:getControl("SweepButton", Const.UIButton)
    local timesLeft = tonumber(Me:queryBasic("practice_times")) 
    
    if timesLeft > SWEEPTIMELIMIT  then  
        timesLeft = 10     
    elseif timesLeft == 0 or timesLeft<0 then
        timesLeft = 10
        sweepBtn:setTouchEnabled(false)
        gf:grayImageView(sweepBtn)
    end

    self.timesStr = tostring(timesLeft)
    sweepBtn:setTitleText(string.format(CHS[6000065], CONST_DATA[timesLeft]))
    
    -- 扫荡元宝数
    local goldlabel = self:getControl("GoldLabel", Const.UILabel)
    goldlabel:setString(timesLeft * PracticeMgr:getSweepGold())
    
    -- 练功剩余次数
    local timesLeftLabel = self:getControl("PracticeTimesLabel", Const.UILabel)
    timesLeftLabel:setString(string.format(CHS[3003501], Me:queryBasic("practice_times")))
end

-- 获取传送位置
function PracticeMapChooseDlg:flyPosition()
    local mapInfo =  MapMgr:getMapinfo()
    
    for k,v in pairs(mapInfo) do
        if v["map_name"] == self.monster["mapName"] then 
             return v["teleport_x"],v["teleport_y"]
        end
    end 
    
    gf:ShowSmallTips(CHS[6000073])
end
return PracticeMapChooseDlg
