-- ArenaMgr.lua
-- created by zhengjh Mar/13/2015
-- 竞技场管理器


ArenaMgr = Singleton()

local MAX_RECORD = 30

local RecordData = {}

-- 更新竞技场邮件信息
function ArenaMgr:updateMailMsg(data)
    local message = {}
    local type = string.match(data["title"], "(.+)_.*")

    message["record_time"] = data["create_time"]
    message["gid"] = data["title"]
    message["player_name"] = data["sender"]
    message["id"] = data["id"]
    message["status"] = data["status"]

    local _, __, challengeStaus, vectoryStatus, lastRanking, curRanking, icon, level
    if type == "znq_2018_xylm" then
        _, __, challengeStaus, vectoryStatus, icon, level = string.find(data["msg"], "(%d+);(%d+);(%d+);(%d+)")
    else
        _, __, challengeStaus, vectoryStatus, lastRanking, curRanking, icon, level = string.find(data["msg"], "(%d+);(%d+);(%d+);(%d+);*(%d*);*(%d*)")
    end

    message["challenge_staus"] = tonumber(challengeStaus)
    message["vectory_status"] = tonumber(vectoryStatus)
    message["last_ranking"] = tonumber(lastRanking)
    message["cur_ranking"]  = tonumber(curRanking)
    message["player_icon"]  = tonumber(icon)
    message["player_level"]  = tonumber(level)

    if string.isNilOrEmpty(type) then
        type = "area"
    end

    if not RecordData[type] then
        RecordData[type] = {}
    end

    self:insterOneRecord(message, type)

    if type == "pet" then
        message["gid"] = string.match(data["title"], ".+_(.*)")
        -- 通知斗宠大会更新战报信息
        DlgMgr:sendMsg('PetStruggleCombatResultDlg', 'setRecordList', RecordData[type])
    elseif type == "znq_2018_xylm" then
        -- 周年庆-驯养灵猫
        message["gid"] = string.match(data["title"], ".+_(.*)")
        DlgMgr:sendMsg('AnniversaryLingMaoCombatDlg', 'setRecordList', RecordData[type])
    else
        -- 通知竞技场更新战报信息
        DlgMgr:sendMsg('ArenaDlg', 'newMessage')
    end

    -- 回复邮件已读
    if data["status"] == 0 then
        ArenaMgr:markMsgRead(data["id"])
    end
end

function ArenaMgr:markMsgRead(id)
    if nil == id then return end

    local data = {}
    data.type = 2
    data.id = id
    data.operate = 0
    gf:CmdToServer("CMD_MAILBOX_OPERATE", data)
end

function ArenaMgr:MSG_CHALLENGE_MSG(data)
    local message = {}
    message["record_time"] = data["record_time"]
    message["challenge_staus"] = data["challenge_staus"]
    message["gid"] = data["gid"]
    message["player_name"] = data["player_name"]
    message["vectory_status"] = data["vectory_status"]
    message["last_ranking"] = data["last_ranking"]
    message["cur_ranking"]  = data["cur_ranking"]
    message["status"] = 0   -- 标记为未读
    self:insterOneRecord(message, "area")
end

function ArenaMgr:getRecordData(type)
    return RecordData[type or "area"] or {}
end

-- record_time 战报时间（离现在多久）
-- challenge_staus 0表示挑战    1表示被挑战
-- gid
-- player_name
-- vectory_status 0表示胜利   1表示失败
-- last_ranking  上次排名
-- cur_ranking  本次排名
function ArenaMgr:insterOneRecord(data, type)
    if not RecordData[type] then
        RecordData[type] = {}
    end

    local recordData = RecordData[type]
    local idx = 0
    for i = 1, #recordData do
        if data["record_time"] == recordData[i]["record_time"] then
            if data["id"] == recordData[i]["id"] then
                -- 相同的信息
                return
            end

            idx = i + 1
            break
        end

        if data["record_time"] < recordData[i]["record_time"] then
            idx = i
            break
        end
    end

    if idx == 0 then
        idx = #recordData + 1
    end

    table.insert(recordData, idx, data)

    if #recordData > MAX_RECORD then
        table.remove(recordData, 1)
    end
end

-- 打开竞技场
function ArenaMgr:openArena()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_ARENA, "", "")
end

-- 竞技场基本信息
function ArenaMgr:MSG_ARENA_INFO(data)
    self.arenaInfo = {}
    self.arenaInfo["rank"] = data.rank
    self.arenaInfo["rewardNumber"] = data.rewardNumber
    self.arenaInfo["totalReward"] = data.totalReward
    self.arenaInfo["challengLeftTimes"] = data.challengLeftTimes
    self.arenaInfo["buyLeftTimes"] = data.buyLeftTimes
end

-- 挑战任务队列
function ArenaMgr:MSG_ARENA_OPPONENT_LIST(data)
	self.challengerList = {}
	self.tongziList = {}

	for i = 1,data["count"] do
	   if data[i]["key"] == 0 then
	       table.insert(self.tongziList, data[i])
	   else
	       table.insert(self.challengerList, data[i])
	   end
	end
end

function ArenaMgr:getChallengrList()
    return self.challengerList, self.tongziList
end


-- 挑战
function ArenaMgr:challenge(key)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_CHALLENGE, key)
end

-- 购买挑战次数
function ArenaMgr:buyChallengeTimes()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_BUY_TIMES)
end

-- 刷新对手信息
function ArenaMgr:refreshChallenger()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_REFRESH_OPPONENTS)
end

-- 发送获取历史最高奖励的指令
function ArenaMgr:getTopRewardList()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_TOP_BONUS_LIST)
end

-- 历史最高排名奖励
function ArenaMgr:MSG_ARENA_TOP_BONUS_LIST(data)
	self.rewardList = {}

	for i = 1, data["count"] do
        table.insert(self.rewardList,data[i])
	end

    table.sort(self.rewardList, function (a, b) return a["rank"] > b["rank"] end)

    self.rewardList["highestRank"] = data["highestRank"]
end

function ArenaMgr:getHighestRewardList()
    return self.rewardList
end

-- 领取竞技场最高排名奖励
function ArenaMgr:getReward(rank)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_ARENA_RANK_BONUS, rank)
end

-- 领取竞技场累计奖励
function ArenaMgr:getTimeCountReward()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_ARENA_TIME_BONUS)
end

-- 打开竞技场商店
function ArenaMgr:openArenaStore()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_ARENA_SHOP)
end

function ArenaMgr:getArenaInfo()
    return self.arenaInfo
end


function ArenaMgr:MSG_ARENA_SHOP_ITEM_LIST(data)
    self.itemList = {}

    for i = 1, data["count"] do
        self.itemList[i] = data[i]
    end

    DlgMgr:openDlg("ArenaStoreDlg")
end

-- 获取商品队列
function ArenaMgr:getShopList()
    return self.itemList
end

-- 刷新声望商店
function ArenaMgr:refreshShopInfo()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_REFRESH_SHOP)
end

-- 购买声望商店的物品
function ArenaMgr:buyItems(key)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ARENA_BUY_ITEM, key)
end

function ArenaMgr:MSG_START_CHALLENGE(data)
    -- Me.challenge = true
end

-- 挑战
function ArenaMgr:ChallengeByPet(no)
    gf:CmdToServer("CMD_DC_CHALLENGE_OPPONENT", {no = no})
end

-- 观战
function ArenaMgr:requestLookonPet()
    gf:CmdToServer("CMD_DC_LOOKON", {})
end

-- 刷新对手信息
function ArenaMgr:refreshOpponentsByPet()
    gf:CmdToServer("CMD_DC_REFRESH_OPPONENTS", {})
end

-- 斗宠界面对手数据
function ArenaMgr:MSG_DC_OPPONENT_LIST(data)
    self.opponentListByPet = data
end

-- 斗宠界面玩家数据
function ArenaMgr:MSG_DC_INFO(data)
    if data.isOpen == 1 then
        DlgMgr:openDlg("PetStruggleDlg")
    end
end

-- 宠物布阵
function ArenaMgr:MSG_DC_PETS(data)
    self.combatPetsOrder = data
end

-- 获得称谓奖励
function ArenaMgr:MSG_DC_WIN_PETS(data)
    DlgMgr:openDlgEx("PetStruggleBonusDlg", data)
end

function ArenaMgr:cleanData()
    RecordData = {}
end

-- 获取时间
function ArenaMgr:getRecordTimestr(servTime)
    local time = gf:getServerTime() - servTime
    local timeStr = ""
    local days = math.floor(time / (3600 * 24))

    if days >= 30 then
        timeStr =  CHS[6000085]
    elseif days >= 1 then
        timeStr =  string.format(CHS[6000086], days)
    else
        local hours = math.floor(time / 3600)

        if hours >= 1 then
            timeStr = string.format(CHS[6000087], hours)
        else
            local minutes = math.floor(time / 60)

            if minutes <= 0 then
                timeStr = string.format(CHS[6000088], 1)
            else
                timeStr = string.format(CHS[6000088], minutes)
            end
        end
    end

    return timeStr
end

MessageMgr:regist("MSG_CHALLENGE_MSG", ArenaMgr)
MessageMgr:regist("MSG_ARENA_INFO", ArenaMgr)
MessageMgr:regist("MSG_ARENA_OPPONENT_LIST", ArenaMgr)
MessageMgr:regist("MSG_ARENA_TOP_BONUS_LIST", ArenaMgr)
MessageMgr:regist("MSG_ARENA_SHOP_ITEM_LIST", ArenaMgr)
MessageMgr:regist("MSG_START_CHALLENGE", ArenaMgr)
MessageMgr:regist("MSG_DC_WIN_PETS", ArenaMgr)
MessageMgr:regist("MSG_DC_PETS", ArenaMgr)
MessageMgr:regist("MSG_DC_INFO", ArenaMgr)
MessageMgr:regist("MSG_DC_OPPONENT_LIST", ArenaMgr)
return ArenaMgr
