-- PracticeMgr.lua
-- created by zhengjh Mar/10/2015
-- 练功管理器

PracticeMgr = Singleton()

local SWEEPGOLD = 1    -- 每次扫荡元宝数
local rewardList = {}
local DoublePointLimit = 12000 -- 购买双倍点数上限
local SHENMU_POINT_LIMIT = 8000 -- 购买神木点数上限

local MonsterList = require(ResMgr:getCfgPath('MonsterList.lua'))

-- 获取当前地图是不是练功区:1.默认的练功区配表返回true；2.是门派地图，但是不是本师门山头
function PracticeMgr:IsPracticePlace(mapName)
	for k, v in pairs(MonsterList) do
	   if v["mapName"] == mapName then
	       return true
	   end
	end

	-- 判断是门派地图而且不是师门地图
	local polarMap = gf:getPolarMap(tonumber(Me:queryBasic("polar")))
    if gf:isPolarMap(mapName) and polarMap ~= mapName then
        return true
	end

    -- 植树节活动副本
    if MapMgr:isInZhiShuJieDugeon() then
        return true
    end

    -- 异族入侵
    if MapMgr:isInYzrq() then
        return true
    end

    return false
end


-- 在当前地图巡逻
function PracticeMgr:autoWalkOnCurMap(isShowTip)
    local curMapName = MapMgr:getCurrentMapName()

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003498])
        return
    elseif Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003499])
        return
    elseif Me:isTeamMember() and not Me:isTeamLeader() then
       gf:ShowSmallTips(CHS[6000156])
       return
    end

    if self:IsPracticePlace(curMapName) == false
        and MapMgr:getCurrentMapName() ~= CHS[3000965] then
        gf:ShowSmallTips(CHS[6000071])  -- 非练功区提示无法自动巡逻
    else
        local function startAutoWalk()
            local x, y = gf:convertToMapSpace(Me.curX, Me.curY)
            local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", curMapName, curMapName, x, y)
            AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
            self:closeDlgAndSendMisc()

            -- 不是长按才显示
            if isShowTip then
                -- 如果是在练功区，则提示自动巡逻
                gf:ShowSmallTips(CHS[3004262])
            end

            DebugMgr:log("autoWalkOnCurMap", nil, nil, nil, autoWalkStr)
        end

        local info = self:getMonsterInfoByMapName(curMapName)
        if not self.hasDoubleTips and info and info["maxLevel"] < Me:getLevel() and Me:queryBasicInt("enable_double_points") == 1 and not PracticeMgr:getIsUseExorcism() then
            gf:confirm(CHS[5400607] .. "\n" ..  CHS[5400606], function()
                startAutoWalk()
            end)

            self.hasDoubleTips = true
        else
            startAutoWalk()
        end
    end
end

-- 巡逻关闭练功界面和发条杂项
function PracticeMgr:closeDlgAndSendMisc()

    if DlgMgr.dlgs["PracticeMapChooseDlg"] then
        DlgMgr.dlgs["PracticeMapChooseDlg"]:onCloseButton()
    end

    if DlgMgr.dlgs["PracticeDlg"] then
        DlgMgr.dlgs["PracticeDlg"]:onCloseButton()
    end

    local data = {}
    data["channel"] = CHAT_CHANNEL["MISC"]
    data["msg"] = CHS[6000155]
    data["time"] = gf:getServerTime()
    ChatMgr:localSendSystemMsg(data)
    Log:F("[%s]'%s':\n%s", tostring(os.date("%Y-%m-%d %H:%M:%S", data["time"])), tostring(data["msg"]), debug.traceback())
end

-- 扫荡
function PracticeMgr:sweep(times, mapName)
     if Me:isTeamMember() == true then
        gf:ShowSmallTips(CHS[6000154])
     end
    local coin = Me:queryBasicInt('gold_coin') + Me:queryBasicInt('silver_coin')
    if coin < times * SWEEPGOLD then
        gf:askUserWhetherBuyCoin()
     else
    	gf:CmdToServer('CMD_GENERAL_NOTIFY',
        {type = NOTIFY.NOTIFY_START_AUTO_PRACTICE, para1 = times, para2 = mapName})
     end
end

-- 每次扫荡的需要的元宝
function PracticeMgr:getSweepGold()
	return SWEEPGOLD
end

-- 扫荡数据
function PracticeMgr:MSG_AUTO_PRACTICE_BONUS(data)
    rewardList = {}

    if not data then return end
    for i = 1, data["count"] do
        rewardList[i] = data[i]
    end

    self["isPackFull"] = data["isPackFull"]
end

-- 扫荡完背包是否满
function PracticeMgr:packgeIsFull()
    return self["isPackFull"]
end

function PracticeMgr:getMonsterList()
	return MonsterList
end

function PracticeMgr:getMonsterInfoByMapName(mapName)
    for k, v in pairs(MonsterList) do
        if v["mapName"] == mapName then
            return v
        end
    end
end

function PracticeMgr:getRewardList()
    return rewardList
end

function PracticeMgr:getDoublePointLimit()
    return DoublePointLimit
end

function PracticeMgr:getShenmuPointLimit()
    return SHENMU_POINT_LIMIT
end

-- 弹出驱魔使用
function PracticeMgr:showUseExorcism()
	if self.isUseExorcism then
        gf:confirm(CHS[3004263], function()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
            self:setIsUseExorcism(false)
        end)
	end
end

-- 设置有没使用驱魔香的标志
function PracticeMgr:setIsUseExorcism(isUse)
    self.isUseExorcism = isUse
end

-- 获取有没使用驱魔香的标志
function PracticeMgr:getIsUseExorcism()
    return self.isUseExorcism or false
end

function PracticeMgr:cleanData()
    self.isUseExorcism = false
end

function PracticeMgr:doShowWhenChangeMap()
    self.hasDoubleTips = false
end

function PracticeMgr:MSG_GENERAL_NOTIFY(data)
    if data.notify == Const.NOTIFY_EXORCISM_STATUS then
        if data.para == 1 then
            self:setIsUseExorcism(true)
        else
            self:setIsUseExorcism(false)
        end
    end
end

MessageMgr:regist("MSG_AUTO_PRACTICE_BONUS", PracticeMgr)
MessageMgr:hook("MSG_GENERAL_NOTIFY", PracticeMgr, "PracticeMgr")

return PracticeMgr
