-- ChatMgr.lua
-- created by zhengjh Apr/14/2015
-- 福利系统管理器

GiftMgr = Singleton()

local OnlineGift = require("cfg/OnlineGift")

local CONFIG_DATA =
{
    ["WelfareButton0"] = "HolidayGiftDlg",      -- 节日礼包
    ["WelfareButton1"] = "OnlineGiftDlg",       -- 神秘大礼
    ["WelfareButton2"] = "DailySignDlg",        -- 每日签到
    ["WelfareButton3"] = "NoviceGiftDlg",       -- 新手礼包
    ["WelfareButton4"] = "FirstChargeGiftDlg",  -- 首充
	["WelfareButton5"] = "ChargeDrawGiftDlg",       -- 抽奖
    ["WelfareButton7"] = "SevenDaysRewardDlg",  -- 7天登入界面
    ["WelfareButton8"] = "ZaixqyDlg",  -- 再续前缘
    ["WelfareButton9"] = "ActiveDrawDlg",  -- 充值抽奖
    ["WelfareButton10"] = "BachelorDrawDlg",  -- 充值抽奖
    ["WelfareButton11"] = "ScratchRewardDlg", -- 寒假刮刮乐
    ["WelfareButton12"] = "ChunjieRedBagDlg", -- 春节幸运红包
    ["WelfareButton13"] = "ChargePointDlg", -- 充值积分
    ["WelfareButton14"] = "CallBackDlg", -- 召回老玩家
    ["WelfareButton15"] = "ActiveVIPDlg", -- 活跃送会员
    ["WelfareButton16"] = "ChargeGiftPerMonthDlg", -- 活跃送会员
    ["WelfareButton17"] = "SummerVacationDlg", -- 活跃送会员
    ["WelfareButton18"] = "RenameDiscountDlg", -- 5折改名卡
    ["WelfareButton19"] = "ZaoHuaDlg", -- 造化之池
    ["WelfareButton20"] = "ChargePointDlg", -- 消费积分
    ["WelfareButton21"] = "WelcomNewDlg", -- 迎新抽奖
    ["WelfareButton22"] = "ActiveLoginRewardDlg", -- 活跃登录礼包
    ["WelfareButton23"] = "MergeLoginGiftDlg", -- 合服登录礼包
    ["WelfareButton24"] = "CombinedServiceTaskDlg", -- 合服登录礼包
    ["WelfareButton25"] = "XunDaoCiFuDlg", -- 寻道赐福
    ["WelfareButton26"] = "ExpStoreHouseDlg", -- 经验仓库
    ["WelfareButton27"] = "NewServiceExpDlg", -- 新服助力
    ["WelfareButton28"] = "SeekFriendMemberDlg", -- 寻友福利
    ["WelfareButton29"] = "RegressionRechargeDlg", -- 回归累充
    ["WelfareButton30"] = "NewServiceCelebrationDlg", -- 新服盛典
}

local SHENGX_IMAGE_NAME = {
    [SHENGX.SHU]  = CHS[6200005],
    [SHENGX.NIU]  = CHS[6200006],
    [SHENGX.HU]   = CHS[6200007],
    [SHENGX.TU]   = CHS[6200008],
    [SHENGX.LONG] = CHS[6200009],
    [SHENGX.SHE]  = CHS[6200010],
    [SHENGX.MA]   = CHS[6200011],
    [SHENGX.YANG] = CHS[6200012],
    [SHENGX.HOU]  = CHS[6200013],
    [SHENGX.JI]   = CHS[6200014],
    [SHENGX.GOU]  = CHS[6200015],
    [SHENGX.ZHU]  = CHS[6200016],
}

local tabDlgInitTime = (60 * 2 + 30) * 1000
local cumulativeRewards = {}
local cumulativeRewardsData = nil
local sevenDaysRewardData = nil
local mergeLoginGiftData = nil
local mergeActiveData = nil
local hoidayGiftData = nil
local activeLoginGiftData = nil
local activeLoginGiftFlagData= nil
local notAddRedDot = {}  -- 部分活动换线不重新显示小红点

GiftMgr.scratchRText = nil
GiftMgr.erasers = nil

-- 每次登入第一次领取标记
local cumulativeFirstGet = true

GiftMgr.firstOpenWelfareDlg = true

local wuxGuessData = nil  -- 五行竞猜数据
local canStartWux = true
local wuxCash = 0
local WUXRESULT = {
    OPEN   = 0,
    RESULT = 1,
    REFRESH = 4,
}

-- 请求福利界面相关信息，isOpenGiftDlg 为 true 表示收到信息后，才打开福利界面
function GiftMgr:openGift(isOpenGiftDlg)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_WELFARE)
    self.isOpenGiftDlg = isOpenGiftDlg
end

function GiftMgr:getFirstGet()
    return cumulativeFirstGet
end

function GiftMgr:setFirstGet(isFirst)
    cumulativeFirstGet = isFirst
end

function GiftMgr:setLastTime()
    self.closeTime = gfGetTickCount()
end

function GiftMgr:MSG_OPEN_WELFARE(data)
    self.welfareData = data
    --[[
    self.welfareData["isCanSign"] = data["isCanSign"]
    self.welfareData["times"] = data["times"]
    self.welfareData["leftTimes"] = data["leftTimes"]
    self.welfareData["leftTime"] = data["leftTime"]
    self.welfareData["isCanGetNewPalyerGift"] = data["isCanGetNewPalyerGift"]
    self.welfareData["firstChargeState"] = data["firstChargeState"]
    self.welfareData["cumulativeReward"] = data["cumulativeReward"]
    self.welfareData["loginGiftState"] = data["loginGiftState"]
    self.welfareData["reentryCount"] = data["reentryCount"]
    self.welfareData["activeCount"] = data["activeCount"]
    self.welfareData["holidayCount"] = data["holidayCount"]
    -- self.welfareData["bachelorCount"] = data["bachelorCount"]
    self.welfareData["isCanReplenishSign"] = data["isCanReplenishSign"]
    self.welfareData["chargePointFlag"] = data["chargePointFlag"]
    --]]
    self.welfareData["lottery"] = {}
end

function GiftMgr:isActiveDrawOpen()
    if self.welfareData and
         self.welfareData["activeCount"] and
         self.welfareData["activeCount"] >= 0 then
        return true
    end

    return false
end

function GiftMgr:MSG_FESTIVAL_LOTTERY(data)
    if not data then return end
    if not self.welfareData then
        self.welfareData = {}
    end

    for name, value in pairs(data) do
        -- 红包抽完会刷新单条，不更新count
        if (name == "count" and not self.welfareData["lottery"].count)
            or name ~= "count" then
            self.welfareData["lottery"][name] = value
        end
    end

    -- 月首充的开启条件，服务器定在该消息中   name == "month_charge_gift"
    self.welfareData["isShowMonthCharge"] = 0

    self.month_charge_gift = nil -- 服务器确认，其他活动发该消息时，会带月充信息
    if data["month_charge_gift"] then
        self.month_charge_gift = data["month_charge_gift"]
        if gf:getServerTime() >= data["month_charge_gift"].startTime and gf:getServerTime() <= data["month_charge_gift"].endTime then
            self.welfareData["isShowMonthCharge"] = 1 -- 0不显示，1显示，2显示且已经领取
        end

        if data["month_charge_gift"].amount == 2 then
            -- 活动界面福利标签小红点
            local welfareAct = ActivityMgr:getWelfareActivity()
            if #welfareAct == 1 or not GameMgr.isFirstLoginToday then
                RedDotMgr:removeOneRedDot("ActivitiesDlg", "WelfareCheckBox", nil, "WelfareCheckBox")
            end
        end
    end

    -- 福利界面收到该消息才打开
    local welfDlg = DlgMgr:getDlgByName("WelfareDlg")
    if not welfDlg and self.isOpenGiftDlg then
        GiftMgr:openGiftDlg(nil, true)
    end

    self.isOpenGiftDlg = false
end

function GiftMgr:getWelfareData()
    return self.welfareData
end

-- 打开新手礼包
function GiftMgr:openNewPlayerGift()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_NEWBIE_GIFT, "", "")
end

-- 新手礼包
function GiftMgr:MSG_NEWBIE_GIFT(data)
    self.newPlayeGift = {}

    for i = 1, data.giftCount do
        table.insert(self.newPlayeGift, data.gifts[i])
    end
end

function GiftMgr:getNewPlayerGift()
    return self.newPlayeGift
end

-- 领取新手礼包
function GiftMgr:getGift(index)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_NEWBIE_GIFT, index)
end

-- 抽取再续前缘奖品         type：0抽奖    1领奖
function GiftMgr:drawReentryReward(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, type)
end

-- 抽取活跃度奖励
function GiftMgr:drawActiveReward(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_LIVENESS_LOTTERY, type)
end

-- 抽取单身节奖励   type  为0时抽奖；为1时领奖
function GiftMgr:drawBachelorReward(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_FESTIVAL_LOTTERY, "singles_day_2016", type)
end

-- 抽取寒假刮刮乐奖励   type  为0时抽奖；为1时领奖
function GiftMgr:drawScratchReward(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_FESTIVAL_LOTTERY, "winter_day_2017", type)
end

-- 春节幸运红包   type:为0时抽奖；大于0表示拆开的红包的对应编号
function GiftMgr:drawChunjieRedBag(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_FESTIVAL_LOTTERY, "spring_day_2017", type)
end

-- 月首充领取
function GiftMgr:getMonthReward()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_FESTIVAL_LOTTERY, "month_charge_gift")
end

-- 打开每日签到
function GiftMgr:openDailySign()
   gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_DAILY_SIGN, "", "")
end

-- 2017再续前缘，抽奖          为0时抽奖；为1时领奖
function GiftMgr:drawZaixqyReward(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "liveness_gift", type)
end

-- 请求 2017再续前缘数据
function GiftMgr:queryZaixqyDaya()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "activity_data")
end

-- 领取 再续前缘7日任务
function GiftMgr:getZaixqySeven(day)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "seven_task_reward", day)
end

-- 领取 再续前缘回归礼包
function GiftMgr:getZaixqyHuiGui()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "comeback_gift")
end

-- 请求回归积分商城数据
function GiftMgr:queryHuiGuiShop()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "open_shop")
end

function GiftMgr:buyHuiGuiShop(info)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "buy_item", info)
end

-- 请求召回的数据
function GiftMgr:queryCallBackData()
    gf:CmdToServer("CMD_RECALL_USER_ACTIVITY_OPER",{oper = "activity_data", para = ""})
end

-- 请求召回的玩家数据
function GiftMgr:queryCallBackPlayersData()
    gf:CmdToServer("CMD_RECALL_USER_ACTIVITY_OPER",{oper = "user_list", para = ""})
end

-- 请求召回某个玩家
function GiftMgr:callBackPlayerByGid(gid)
    self.lastOperTime = self.lastOperTime or 0 -- gfGetTickCount()
    if  gfGetTickCount() - self.lastOperTime <= 5000 then
        gf:ShowSmallTips(CHS[4300098])
        return
    end
    gf:CmdToServer("CMD_RECALL_USER_ACTIVITY_OPER",{oper = "recall_user", para = gid})
end

-- 请求召回某个玩家
function GiftMgr:queryCallBackShop()
    gf:CmdToServer("CMD_RECALL_USER_ACTIVITY_OPER",{oper = "open_shop", para = ""})
end

-- 购买召回商品
function GiftMgr:buyZhaoHuiShop(info)
    gf:CmdToServer("CMD_RECALL_USER_ACTIVITY_OPER",{oper = "buy_item", para = info})
end

-- 打开新服盛典
function GiftMgr:openNewServiceCelebration()
   gf:CmdToServer("CMD_NEW_DIST_CHONG_BANG_DATA", {})
end

-- 每日签到数据
function GiftMgr:MSG_DAILY_SIGN(data)
	self.dailyData = data
end

function GiftMgr:getDailySignData()
    return self.dailyData
end

function GiftMgr:dailySign()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DO_DAILY_SIGN)
end

function GiftMgr:replenishDailySign()
    gf:CmdToServer("CMD_DO_REPLENISH_SIGN", {})
end

-- 月首充为 "month_charge_gift"
function GiftMgr:festivalLottery(act_name)
    gf:CmdToServer("CMD_OPEN_FESTIVAL_LOTTERY", {name = act_name})
end

-- 打开神秘大礼
function GiftMgr:openOnlineGift()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_SHENMI_DALI)
end

-- 神秘大礼的数据
function GiftMgr:MSG_AWARD_OPEN(data)
	self.onlineData = {}
	self.onlineData["type"] = data["type"]
	self.onlineData["times"] = data["times"]
    self.onlineData["leftTimes"] = data["leftTimes"]
end

function GiftMgr:getonlineData()
    return self.onlineData
end

function GiftMgr:getReward(type, step)
    if not DistMgr:checkCrossDist() then return end

    local data = {}
    data["type"] = type
    data["step"] = step
    gf:CmdToServer("CMD_START_AWARD", data)
end

function GiftMgr:MSG_AWARD_INFO_EX(data)
	self.rewardName = nil
    self.rewardName = data["name"]
    self.rewardRate = data.rate
end

-- 请求节日活动信息
function GiftMgr:questHolidayData()
    gf:CmdToServer("CMD_REQUEST_FESTIVAL_GIFT_INFO", {})
end

-- 购买节日活动礼包
function GiftMgr:buyHolidayGift(name)
    gf:CmdToServer("CMD_BUY_FESTIVAL_GIFT", {name = name})
end

-- 领取节日活动宝箱
function GiftMgr:getRewardBox(boxId)
    gf:CmdToServer("CMD_OPEN_FESTIVAL_TREASURE", {boxId = boxId})
end

function GiftMgr:sendUserInfo(id, name, tel, qq, address)
    local data = {}
    data["id"] = id
    data["name"] = name
    data["tel"] = tel
    data["qq"] = qq
    data["address"] = address
    gf:CmdToServer("CMD_GATHER_USER_INFO", data)
end


function GiftMgr:getRewardName()
    return self.rewardName
end

function GiftMgr:getRewardRate()
    return self.rewardRate
end

-- 获取神秘大礼随机物品
function GiftMgr:getOnlineGift()
	return  OnlineGift
end

function GiftMgr:setLastIndex(index)
    self.closeTime = gfGetTickCount()
	self.lastIndex = index
end

function GiftMgr:getLastIndex()
    if not self.closeTime or gfGetTickCount() - self.closeTime > tabDlgInitTime or (GameMgr.initDataTime or 0) > self.closeTime then
        self.lastIndex = "WelfareButton2"
    end

    self.lastIndex = self.lastIndex or "WelfareButton2"
    return self.lastIndex
end

-- 获取已经冲值了多少钱
function GiftMgr:getAlreadyCumulated()
    return Me:queryInt("recharge")
end

-- 获取合服登录礼包
function GiftMgr:requestMergeLoginGiftData()
    gf:CmdToServer("CMD_MERGE_LOGIN_GIFT_LIST")
end

-- 获取7天礼包信息
function GiftMgr:getSevenDaysRewardData()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_LOGIN_GIFT)
end

-- 领取合服登录礼包
function GiftMgr:getMergeLoginGift(rank)
    gf:CmdToServer("CMD_MERGE_LOGIN_GIFT_FETCH", { day = rank })
end

-- 请求合服促活跃信息
function GiftMgr:requestMergerLoginActiveRewardData()
    gf:CmdToServer("CMD_OPEN_HUOYUE_JIANGLI")
end

-- 获取合服促活跃信息
function GiftMgr:getMergeLoginActiveRewardData()
    return mergeActiveData
end

-- 领取合服促活跃奖励
function GiftMgr:getMergeLoginActiveReward()
    gf:CmdToServer("CMD_RECV_HUOYUE_JIANGLI", {open_time = mergeActiveData.open_time } )
end

-- 领取7天礼包
function GiftMgr:getSevenDaysReward(rank)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_LOGIN_GIFT, rank)
end

-- 获取礼包
function GiftMgr:getAllCumulateReward()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_RECHARGE_GIFT, rank)
end

-- 领取礼包
function GiftMgr:getCumulateReward(rank)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_RECHARGE_GIFT, rank)
end

-- 获取奖励列表
function GiftMgr:getCumulateRewardList()
    return cumulativeRewards
end

-- 获取累充奖励原始数据
function GiftMgr:getCumulateData()
    return cumulativeRewardsData
end

-- 更新充值状态
function GiftMgr:updateStatus(data)
    cumulativeRewards = {}
    local count = data.count
    local alreadCost = self:getAlreadyCumulated()
    for i = 1, count do
        local reward = {}
        reward.money = data[i].price
        reward.list = data[i].desc
        reward.rank = data[i].index
        if alreadCost >= data[i].price then
            reward.status = data[i].flag + 2
        else
            reward.status = 1
        end

        table.insert(cumulativeRewards, reward)
    end
end

-- 累充奖励
function GiftMgr:MSG_RECHARGE_GIFT(data)
    cumulativeRewardsData = data
    self:updateStatus(data)

end

-- 获取累充奖励原始数据
function GiftMgr:getLoginGiftData()
    return sevenDaysRewardData
end

-- 获取合服奖励数据
function GiftMgr:getMergeLoginGiftData()
    return mergeLoginGiftData
end

-- 数据清空
function GiftMgr:cleanData(isLoginOrSwithLine)
    cumulativeRewards = {}
    cumulativeRewardsData = nil
    sevenDaysRewardData = nil
    activeLoginGiftData = nil
    activeLoginGiftFlagData = nil
    self.newPlayeGift = nil
    if not DistMgr:getIsSwichServer()  then
    wuxGuessData = nil
    end
    cumulativeFirstGet = true
    self.isOpenGiftDlg = false
    self.zaixqyEquip = nil
    self:clearGetItemInfo()

    if not isLoginOrSwithLine then
        self.lotteryResult = nil
        self:releaseEraser()
        GiftMgr:releaseScratchRText()

        notAddRedDot = {}
        self.chargePointInfo = nil
        self.consumePointInfo = nil
        self.activeVIPInfo = nil

        self.closeTime = nil
        self.xyflData = nil
    end

    self.callBackDlgScoreData = nil
    self.callBackDlgShopList = nil

    DlgMgr:sendMsg("ChunjieRedBagDlg", "resetClickStatus")
end

-- 获取累充奖励原始数据
function GiftMgr:getLoginGiftData()
    return sevenDaysRewardData
end

-- 首充抽奖相关
function GiftMgr:requestReward()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_LOTTERY_INFO)
end

function GiftMgr:MSG_LOTTERY_INFO(data)
    self.chargeDrawGiftDlgData = data
end

-- isNowOpen 为 true 时，直接打开福利界面，否则等收到信息后再打开
function GiftMgr:openGiftDlg(dlgName, isNowOpen)
    if self.isOpenNewLottery and dlgName == "ChargeDrawGiftDlg" then
        dlgName = "NewChargeDrawGiftDlg"
    end

    -- 判断福利界面标签页是否存在，不存在打开默认
    local function getRealDlg(dlg)
        -- isShowMonthCharge数据在其他消息中给的，所以做个容错，防止不存在
        if not self.welfareData["isShowMonthCharge"] then self.welfareData["isShowMonthCharge"] = 0 end


        if (dlg == "SevenDaysRewardDlg" and self.welfareData["loginGiftState"] == 2)
            or (dlg == "NoviceGiftDlg" and self.welfareData["isCanGetNewPalyerGift"] == 0 and Me:queryBasicInt("level") >= 80)
            or (dlg == "HolidayGiftDlg" and (self.welfareData["holidayCount"] < 0 or Me:queryBasicInt("level") < 30))
            or (dlg == "BachelorDrawDlg" and not self.welfareData["lottery"]["singles_day_2016"] )
            or (dlg == "ScratchRewardDlg" and not self.welfareData["lottery"]["winter_day_2017"] )
            or (dlg == "ChunjieRedBagDlg" and not self.welfareData["lottery"]["spring_day_2017"] )
            or (dlg == "FirstChargeGiftDlg" and self.welfareData["firstChargeState"] == 2)
            or (dlg == "ZaixqyDlg" and self.welfareData["isShowHuiGui"] <= 0)
            or (dlg == "ActiveDrawDlg" and self.welfareData["activeCount"] < 0)
            or (dlg == "ChargePointDlg" and self.welfareData["chargePointFlag"] < 0 and self.welfareData["consumePointFlag"] < 0)
            or (dlg == "CallBackDlg" and self.welfareData["isShowZhaohui"] <= 0)
            or (dlg == "ActiveVIPDlg" and self.welfareData["activeVIPFlag"] <= 0)
            or (dlg == "RenameDiscountDlg" and self.welfareData["rename_discount_time"] <= 0)
            or (dlg == "SummerVacationDlg" and self.welfareData["summerSF2017"] <= 0)
            or (dlg == "ChargeGiftPerMonthDlg" and self.welfareData["isShowMonthCharge"] <= 0)
            or (dlg == "WelcomNewDlg" and self.welfareData["welcomeDrawStatue"] < 0)
            or (dlg == "ActiveLoginRewardDlg" and self.welfareData["activeLoginStatue"] < 0)
            or (dlg == "MergeLoginGiftDlg" and self.welfareData["mergeLoginStatus"] < 0)
            or (dlg == "CombinedServiceTaskDlg" and self.welfareData["mergeLoginActiveStatus"] < 0)
            or (dlg == "ExpStoreHouseDlg" and self.welfareData["expStoreStatus"] <= 0)
            or (dlg == "NewServiceExpDlg" and self.welfareData["newServeAddNum"] <= 0)
            or (dlg == "SeekFriendMemberDlg" and self.welfareData["isShowXYFL"] <= 0)
            or (dlg == "RegressionRechargeDlg" and self.welfareData["reentryAsktaoRecharge"] <= 0)
            or (dlg == "NewServiceCelebrationDlg" and self.welfareData["isShowXFSD"] <= 0)
        then
            return "DailySignDlg"
        end

        return dlg
    end

    local dlg = DlgMgr:getDlgByName(dlgName)
    if dlg then
        dlg:reopen()
        DlgMgr:reopenRelativeDlg(dlgName)
        return
    end

    -- 福利界面改为收到 MSG_OPEN_WELFARE 和 MSG_FESTIVAL_LOTTERY 消息后才打开，不直接打开
    local welfDlg = DlgMgr:getDlgByName("WelfareDlg")
    if not welfDlg and not isNowOpen then
        if dlgName then
            for ctrlName, dlg in pairs(CONFIG_DATA) do
                if dlg == dlgName then
                    if dlgName == "ChargePointDlg" then
                        -- 充值积分、消费积分使用了同一个界面，需要根据类别选中对应按钮
                        if  self:getPointWelfareType() == "charge" then
                            ctrlName = "WelfareButton13"
                        else
                            ctrlName = "WelfareButton20"
                        end
                    end

                    GiftMgr:setLastIndex(ctrlName)
                end
            end
        end

        GiftMgr:setLastTime()
        self:openGift(true)
        return
    end

    if dlgName then
        dlgName = getRealDlg(dlgName)
        if welfDlg then
            welfDlg:selectBtnByDlg(dlgName)
        else
            GiftMgr:setLastTime()
            for ctrlName, dlg in pairs(CONFIG_DATA) do
                if dlg == dlgName then
                    if dlgName == "ChargePointDlg" then
                        -- 充值积分、消费积分使用了同一个界面，需要根据类别选中对应按钮
                        if  self:getPointWelfareType() == "charge" then
                            ctrlName = "WelfareButton13"
                        else
                            ctrlName = "WelfareButton20"
                        end
                    end

                    GiftMgr:setLastIndex(ctrlName)
                end
            end

            DlgMgr:openDlg(dlgName)
        end
    else
        if welfDlg then
            welfDlg:selectBtnByDlg(CONFIG_DATA[self:getLastIndex()])
        else
            local key = self:getLastIndex()
            local newDlgName = getRealDlg(CONFIG_DATA[key])
            DlgMgr:openDlg(newDlgName)
        end
    end
end

-- 活跃抽奖，活跃值
function GiftMgr:requestActiveDrawAct()
    gf:CmdToServer("CMD_OPEN_LIVENESS_LOTTERY", {})
end

-- 获取五行竞猜提款
function GiftMgr:requestGetWuxCash()
    gf:CmdToServer("CMD_FETCH_GUESS_SURPLUS", {})
end

-- 开始五行竞猜
function GiftMgr:startWuxGuess(amount, wuXChoice, shengxChoice)
    local data = {}
    data.amount = amount
    data.choice = shengxChoice * 10 + wuXChoice
    gf:CmdToServer("CMD_START_GUESS", data)
end

-- 获取五行配额
function GiftMgr:canStartWux()
    if canStartWux then
        canStartWux = false
        return true
    end

    return false
end

-- 释放配额
function GiftMgr:releaseStartWux()
    canStartWux = true
end

-- 获取五行竞猜数据
function GiftMgr:getWuxGuessData()
    return wuxGuessData
end

-- 获取五行的钱
function GiftMgr:getWuxGuessCash()
    return wuxCash
end

-- 设置五行的钱
function GiftMgr:setWuxGuessCash(cash)
    wuxCash = cash
end

-- 设置五行数据
function GiftMgr:setWuxGuessData(data)
    if not wuxGuessData
        or data.flag == WUXRESULT.RESULT then
        wuxGuessData = data
    end

    GiftMgr:setWuxGuessCash(data.surlus)
end

-- 清除五行竞猜数据
function GiftMgr:clearWuxGuessData()
    if not wuxGuessData then
        return
    end

    wuxGuessData.flag = WUXRESULT.OPEN
end

-- 是否是结果
function GiftMgr:hasWuxGuessResult()
    if not wuxGuessData then
        return false
    end

    return WUXRESULT.RESULT == wuxGuessData.flag
end

function GiftMgr:MSG_OPEN_GUESS_DIALOG(data)
    if WUXRESULT.REFRESH == data.flag then
        -- 仅仅是刷新数据
        if wuxGuessData then
            -- 刷新数据
            wuxGuessData.leftCount = data.leftCount
        end

        return
    end

    GiftMgr:releaseStartWux()
    DlgMgr:openDlg("WuXingGuessingDlg")
    self:setWuxGuessData(data)
end

function GiftMgr:MSG_OPEN_STORE_DIALOG(data)
    DlgMgr:openDlg("WuxingStoreMoneyDlg")
end

function GiftMgr:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_DRAW_LOTTERY == data.notify then
        self.chargeDrawGiftDlgReward = data.para
    end
end

function GiftMgr:MSG_LOGIN_GIFT(data)
    sevenDaysRewardData = data
end

function GiftMgr:MSG_MERGE_LOGIN_GIFT_LIST(data)
    mergeLoginGiftData = data
end

function GiftMgr:MSG_OPEN_HUOYUE_JIANGLI(data)
    mergeActiveData = data
end

-- 根据编号获取生肖名字
function GiftMgr:getShengXiaoName(shengxiao)
    return SHENGX_IMAGE_NAME[shengxiao] or ""
end

function GiftMgr:MSG_CHAR_CHANGE_SEX(data)
    self.newPlayeGift = nil
end

function GiftMgr:getHoidayGiftData()
    return hoidayGiftData
end

function GiftMgr:MSG_FESTIVAL_GIFT_INFO(data)
    hoidayGiftData = data
end

function GiftMgr:MSG_MY_FESTIVAL_GIFT_INFO(data)
    if not hoidayGiftData then return end
    hoidayGiftData.loginTime = data.loginTime
    hoidayGiftData.active = data.active
    for i = 1, data.giftCount do
        for j = 1, hoidayGiftData.giftCount do
            if hoidayGiftData.gifts[j].name == data.gifts[i].name then
                hoidayGiftData.gifts[j].buyTimeCur = data.gifts[i].buyTimeCur
            end
        end
    end

    for i = 1, hoidayGiftData.boxCount do
        if data.boxs[i] then
            hoidayGiftData.boxs[i].isGeted = 1
        else
            hoidayGiftData.boxs[i].isGeted = 0
        end
    end

    hoidayGiftData.getedBoxIndex = data.getedBoxIndex
end

-- 节日活动结束，关闭相关界面，给予提示
function GiftMgr:MSG_NOTIFY_END_FESTIVAL_GIFT(data)
    local dlg = DlgMgr:getDlgByName(data.dlgName)
    if dlg then
        dlg:onCloseButton()
        gf:ShowSmallTips(data.tips)
    end

    if data.dlgName == "HolidayGiftDlg" then
        if self.welfareData then self.welfareData.holidayCount = -1 end
    end

    if data.dlgName == "BachelorDrawDlg" then
        if self.welfareData then self.welfareData["lottery"]["singles_day_2016"] = nil end
    end

    if data.dlgName == "ScratchRewardDlg" then
        if self.welfareData then self.welfareData["lottery"]["winter_day_2017"] = nil end
    end

    if data.dlgName == "ChunjieRedBagDlg" then
        if self.welfareData then self.welfareData["lottery"]["spring_day_2017"] = nil end
    end
end

-- 获取刮图对象
function GiftMgr:getScratchRTextbByName(name)
    return self.scratchRText and self.scratchRText[name]
end

-- 存刮图对象
function GiftMgr:setScratchRText(name, rText)
    if not rText then return end
    if not self.scratchRText then self.scratchRText = {} end

    if self.scratchRText[name] then
        self.scratchRText[name]:release()
    end

    self.scratchRText[name] = rText
    self.scratchRText[name]:retain()
end

function GiftMgr:releaseScratchRText()
    if not self.scratchRText then return end

    for i, v in pairs(self.scratchRText) do
        if v then
            v:release()
        end
    end

    self.scratchRText = nil
end

-- 获取橡皮擦对象
-- n 刮图个数
-- num 橡皮擦个数
-- r   橡皮擦半径
function GiftMgr:getEraser(name, n, num, r)
    if not self.erasers then self.erasers = {} end

    if not self.erasers[name] then
        self.erasers[name] = {}
        for i = 1, n do
            self.erasers[name][i] = {}
            for j = 1, num do
                table.insert(self.erasers[name][i], self:createEraser(r))
                self.erasers[name][i][j]:retain()
            end
        end
    end

    return self.erasers[name]
end


function GiftMgr:releaseEraser()
    if not self.erasers then return end

    for _, n in pairs(self.erasers) do
        for _, e in pairs(n) do
            for _, v in pairs(e) do
                if v then
                    v:release()
                    v = nil
                end
            end
            e = nil
        end
        n = nil
    end

    self.erasers = nil
end

-- 创建橡皮擦
function GiftMgr:createEraser(radius)
    local eraser = cc.DrawNode:create()
    eraser:drawDot(cc.p(0, 0), radius, cc.c4b(0, 0, 0, 0))
    eraser:setAnchorPoint(0.5, 0.5)
    eraser:setBlendFunc(gl.ONE, gl.ZERO)
    eraser.radius = radius
    return eraser
end

-- 获取抽奖信息
function GiftMgr:getLotteryResult(name)
    if not self.lotteryResult then return end

    return self.lotteryResult[name]
end

function GiftMgr:MSG_FESTIVAL_LOTTERY_RESULT(data)
    if not self.lotteryResult then self.lotteryResult = {} end

    self.lotteryResult[data.activeName] = data

    if data and data.activeName == "winter_day_2017" and data.status == 0 then
        -- status为1表示抽奖开始，0表示结束
        GiftMgr:releaseScratchRText()
    end
end

function GiftMgr:resetFirstOpenWelfareDlgFlag()
    GiftMgr.firstOpenWelfareDlg = true
end

-- 玩家充值成功，且满足领取首充礼包条件
function GiftMgr:MSG_ACTIVE_FETCH_SHOUCHONG(data)
    -- 每次玩家充值成功，且满足领取首充礼包条件，需要在“福利界面”按钮上显示环绕光效
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        local btn = dlg:getControl("GiftsButton")
        local effect = btn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
        if not effect then
            -- lixh2 WDSY-21401 帧光效修改为粒子光效：主界面按钮环绕光效
            gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_btn, btn, Const.ARMATURE_MAGIC_TAG, 2, 0)
        end
    end

    -- 每次“登录成功”或者“玩家充值成功”，且满足领取首充礼包条件，都需要在“福利界面-首充标签”按钮上显示环绕光效
    -- 当前每次登录检测的逻辑为：第一次打开福利界面（GiftMgr.firstOpenWelfareDlg)，且满足领取礼包条件，则显示光效
    -- 那么如果玩家充值成功且满足领取条件，则重置GiftMgr.firstOpenWelfareDlg，使得下一次打开福利界面可以显示光效
    GiftMgr.firstOpenWelfareDlg = true
end


-- 充值积分相关
-- 请求充值积分活动信息
function GiftMgr:requestChargePointInfo()
    gf:CmdToServer("CMD_REQUEST_RECHARGE_SCORE_GOODS", {})
end

-- 兑换充值积分活动商品
function GiftMgr:buyChargePointGoods(no, num)
    gf:CmdToServer("CMD_BUY_RECHARGE_SCORE_GOODS", {no = no - 1, num = num})
end

-- 充值积分 begin
function GiftMgr:MSG_RECHARGE_SCORE_GOODS_LIST(data)
    -- 第一次刷新充值积分数据时更新主界面福利小红点
    local needToRefreshGiftButtonRedDot = false
    if not self.chargePointInfo then
        needToRefreshGiftButtonRedDot = true
    end

    self.chargePointInfo = data

    if needToRefreshGiftButtonRedDot and self:getWelfareData() then
        RedDotMgr:MSG_OPEN_WELFARE(self:getWelfareData())
    end
end

function GiftMgr:getChargePointInfo()
    return self.chargePointInfo
end

-- 当前处于充值积分活动开启中
function GiftMgr:isInRechargeScore()
    if not self.chargePointInfo then
        return
    end

    local data= self.chargePointInfo
    local time = gf:getServerTime()
    local startTime = data.startTime
    local endTime = data.endTime
    if time >= startTime and time <= endTime then
        return true
    end
end

-- 处于充值积分活动结束，但兑换尚未结束的时间内
function GiftMgr:isInRechargeScoreDeadline()
if not self.chargePointInfo then
    return
        end

    local data= self.chargePointInfo
    local time = gf:getServerTime()
    local endTime = data.endTime
    local deadline = data.deadline
    if time >= endTime and time <= deadline then
        return true
    end
end

-- 当前玩家当前的充值积分
function GiftMgr:getRechargeScore()
    if not self.chargePointInfo or not self.chargePointInfo.ownPoint then
        return 0
    end

    local data = self.chargePointInfo
    return data.ownPoint
end

-- 需要显示小红点的最小剩余积分（即将到兑换截止时间）
function GiftMgr:getMinPointInRechargeScoreDeadline()
    return 7
end

-- 充值积分单个商品信息
function GiftMgr:MSG_RECHARGE_SCORE_GOODS_INFO(data)
    if not self.chargePointInfo then
        return
    end

    self.chargePointInfo.ownPoint = data.ownPoint
    self.chargePointInfo[data.no]= data
end
-- 充值积分 end

-- 消费积分  begin
-- 请求消费积分活动信息
function GiftMgr:requestConsumePointInfo()
    gf:CmdToServer("CMD_REQUEST_CONSUME_SCORE_GOODS", {})
end

-- 兑换消费积分活动商品
function GiftMgr:buyConsumePointGoods(no, num)
    gf:CmdToServer("CMD_BUY_CONSUME_SCORE_GOODS", {no = no - 1, num = num})
end

function GiftMgr:MSG_CONSUME_SCORE_GOODS_LIST(data)
    -- 第一次刷新消费积分数据时更新主界面福利小红点
    local needToRefreshGiftButtonRedDot = false
    if not self.consumePointInfo then
        needToRefreshGiftButtonRedDot = true
    end

    self.consumePointInfo = data

    if needToRefreshGiftButtonRedDot and self:getWelfareData() then
        RedDotMgr:MSG_OPEN_WELFARE(self:getWelfareData())
    end
end

function GiftMgr:getConsumePointInfo()
    return self.consumePointInfo
end

-- 当前处于消费积分活动开启中
function GiftMgr:isInConsumeScore()
    if not self.consumePointInfo then
        return
    end

    local data= self.consumePointInfo
    local time = gf:getServerTime()
    local startTime = data.startTime
    local endTime = data.endTime
    if time >= startTime and time <= endTime then
        return true
    end
end

-- 处于充值积分活动结束，但兑换尚未结束的时间内
function GiftMgr:isInConsumeScoreDeadline()
    if not self.consumePointInfo then
        return
    end

    local data= self.consumePointInfo
    local time = gf:getServerTime()
    local endTime = data.endTime
    local deadline = data.deadline
    if time >= endTime and time <= deadline then
        return true
    end
end

-- 当前玩家当前的充值积分
function GiftMgr:getConsumeScore()
    if not self.consumePointInfo or not self.consumePointInfo.ownPoint then
        return 0
    end

    local data = self.consumePointInfo
    return data.ownPoint
end

-- 需要显示小红点的最小剩余积分（即将到兑换截止时间）
function GiftMgr:getMinPointInConsumeScoreDeadline()
    return 7
end

-- 充值积分单个商品信息
function GiftMgr:MSG_CONSUME_SCORE_GOODS_INFO(data)
    if not self.consumePointInfo then
        return
    end

    self.consumePointInfo.ownPoint = data.ownPoint
    self.consumePointInfo[data.no]= data
end
-- 消费积分 end

-- 当前正在进行的积分活动类型（充值积分/消费积分）
function GiftMgr:getPointWelfareType()
    if not self.welfareData then
        return
    end

    if self.welfareData.chargePointFlag > 0 then
        return "charge"
    elseif self.welfareData.consumePointFlag > 0 then
        return "consume"
    end
end

-- 设置对应活动不在重新显示添加小红点（如：积分活动只有上线时，显示小红点，换线不显示小红点）
function GiftMgr:setCanAddRedDot(key, isCanAddRedDot)
    notAddRedDot[key] = not isCanAddRedDot
end

-- 当前活动是否可以显示小红点
function GiftMgr:isCanAddRedDot(key)
    return not notAddRedDot[key]
end

function GiftMgr:MSG_ACTIVE_BONUS_INFO(data)
    -- 第一次刷新活跃送会员数据时更新主界面福利小红点
    local needToRefreshGiftButtonRedDot = false
    if not self.activeVIPInfo then
        needToRefreshGiftButtonRedDot = true
    end

    self.activeVIPInfo = data

    if needToRefreshGiftButtonRedDot and self:getWelfareData() then
        RedDotMgr:MSG_OPEN_WELFARE(self:getWelfareData())
    end
end

function GiftMgr:getActiveVIPInfo()
    return self.activeVIPInfo
end

-- 请求打折改名信息
function GiftMgr:requestRenameDiscountInfo()
    gf:CmdToServer("CMD_RENAME_DISCOUNT", {})
end

-- 请求打折改名信息
function GiftMgr:buyRenameDiscount()
    gf:CmdToServer("CMD_RENAME_DISCOUNT_BUY", {})
end

-- type 0表示抽奖，1表示领奖
function GiftMgr:fetchSummer2017(type)
    gf:CmdToServer("CMD_FETCH_SD_2017_LOTTERY", {type = type, curTime = gf:getServerTime()})
end

-- 请求暑假送福数据
function GiftMgr:questSD2017()
    gf:CmdToServer("CMD_REQUEST_SD_2017_LOTTERY_INFO", {})
end

-- 请求造化界面数据
function GiftMgr:requestZaohuaData()
    gf:CmdToServer("CMD_OPEN_ZAOHUA_ZHICHI", {})
end

-- 请求吸收造化之池
function GiftMgr:recvZaohua()
    gf:CmdToServer("CMD_RECV_ZAOHUA_ZHICHI", {})
end

function GiftMgr:MSG_OPEN_XUNDAO_CIFU(data)
    if self.welfareData then
        -- 将寻道赐福的剩余次数通知给GiftMgr和WelfareDlg
        self.welfareData.xundcf = data.count
        DlgMgr:sendMsg("WelfareDlg", "MSG_FESTIVAL_LOTTERY")
    end
end

function GiftMgr:MSG_OPEN_ZAOHUA_ZHICHI(data)
    if self.welfareData then
        -- 将造化之池的剩余次数通知给GiftMgr和WelfareDlg
        self.welfareData.zaohua = data.count
        DlgMgr:sendMsg("WelfareDlg", "MSG_FESTIVAL_LOTTERY")
    end
end

-- 迎新抽奖信息
function GiftMgr:MSG_WELCOME_DRAW_OPEN(data)
    self.welcomeDrawInfo = data
end

-- 查询回归特惠
function GiftMgr:queryHuiGuiBuy()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "th_open_shop")
end

-- 购买回归特惠
function GiftMgr:buyHuiGui(good_id)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "th_buy_item", good_id)
end

-- 领取7日登录
function GiftMgr:getSevenGift(para)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "7d_gift_fetch", para)
end

-- 查询7日回归礼包
function GiftMgr:querySevenGift()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "7d_gift_list")
end


-- 查询再续前缘，7日登录礼包装备  装备选择类型：phy、mag、speed、cskill
function GiftMgr:queryZaixqyEquip(equip_attrib)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_REENTRY_ASKTAO, "7d_gift_equip", equip_attrib)
end

function GiftMgr:getZaixqyEuipByAttrib(equip_attrib)
    if not equip_attrib then equip_attrib = "phy" end

    if self.zaixqyEquip and self.zaixqyEquip[equip_attrib] then
        return self.zaixqyEquip[equip_attrib]
    end
end

function GiftMgr:isOpenNewZaixqy()
    local timeTab = {year = 2017, month = 10, day = 26, hour = 5, min = 0, sec = 0}
    if DistMgr:curIsTestDist() then
        timeTab = {year = 2017, month = 10, day = 10, hour = 5, min = 0, sec = 0}
    end

    local timeFlag = os.time(timeTab)

    return gf:getServerTime() >= timeFlag
end

function GiftMgr:MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST(data)
    self.zaixqyEquip = self.zaixqyEquip or {}
    if not self.zaixqyEquip[data.equip_attrib] then self.zaixqyEquip[data.equip_attrib] = {} end
    self.zaixqyEquip[data.equip_attrib] = data

    -- 由于限时这里需要显示格式不一致，所以客户端增加一个字段,5s误差

    for i = 1, 4 do
        if InventoryMgr:isTimeLimitedItem(data[i]) then
            self.zaixqyEquip[data.equip_attrib][i].leftTime = data[i].deadline - gf:getServerTime() + 5
        end
    end
end

-- 是否开启新的充值抽奖信息
function GiftMgr:MSG_NEW_LOTTERY_OPEN()
    self.isOpenNewLottery = true

    CONFIG_DATA["WelfareButton5"] = "NewChargeDrawGiftDlg"
end

-- 新充值好礼界面数据
function GiftMgr:MSG_NEW_LOTTERY_INFO(data)
    self.newChargeDrawGiftDlgData = data
end

-- 请求神秘大礼数据 砸蛋版本
function GiftMgr:queryOnlineGiftEggData()
    gf:CmdToServer("CMD_SHENMI_DALI_OPEN")
end


-- 所有活跃登录礼包的数据
function GiftMgr:MSG_SEVENDAY_GIFT_LIST(data)
    activeLoginGiftData = data
end

-- 所有活跃登录礼包的领取状态数据
function GiftMgr:MSG_SEVENDAY_GIFT_FLAG(data)
    activeLoginGiftFlagData = data
end

-- 获取活跃登录礼包数据
function GiftMgr:getActiveLoginGiftData()
    return activeLoginGiftData
end

function GiftMgr:getActiveLoginGiftFlagData()
    return activeLoginGiftFlagData
end

-- 获取活跃登录礼包领取的限制等级
function GiftMgr:getActiveLoginGiftLimitLevel()
    if DistMgr:curIsTestDist() then
        return 75
    else
        return 35
    end
end

-- 合服登录奖励的限制等级
function GiftMgr:getMergerLoginGiftLimitLevel()
    return 70
end

function GiftMgr:pushOneGetItemInfo(data)
    if not self.getItemInfo then
        self.getItemInfo = {}
    end

    table.insert(self.getItemInfo, data)

    if not DlgMgr:isDlgOpened("GetElitePetDlg") then
        self:doShowGetItemAction()
    end
end

function GiftMgr:clearGetItemInfo()
    self.getItemInfo = nil
end

function GiftMgr:doShowGetItemAction()
    if not self.getItemInfo or #self.getItemInfo <= 0 then
        return
    end

    local data = table.remove(self.getItemInfo, 1)
    local dlg = DlgMgr:openDlg("GetElitePetDlg")
    dlg:setDlgInfo(data.para, data.notify)

    return true
end

-- type 1 为活动结束，依然可以兑换的世界， 2商品列表
function GiftMgr:getCallBackDlgData(type)
    if type == 1 then
        return self.callBackDlgScoreData
    elseif type == 2 then
        return self.callBackDlgShopList
    end
end

function GiftMgr:MSG_RECALL_USER_SCORE_DATA(data)
    self.callBackDlgScoreData = data
end

function GiftMgr:MSG_RECALL_SCORE_SHOP_ITEM_LIST(data)
    self.callBackDlgShopList = data
end

function GiftMgr:getXYFLData()
    return self.xyflData
end

function GiftMgr:MSG_BJTX_WELFARE(data)
    self.xyflData = data
end

function GiftMgr:MSG_REENTRY_ASKTAO_RECHARGE_DATA(data)
    self.backRechargeData = data
end

MessageMgr:regist("MSG_BJTX_WELFARE", GiftMgr)
MessageMgr:regist("MSG_REENTRY_ASKTAO_RECHARGE_DATA", GiftMgr)
MessageMgr:regist("MSG_RECALL_SCORE_SHOP_ITEM_LIST", GiftMgr)
MessageMgr:regist("MSG_RECALL_USER_SCORE_DATA", GiftMgr)
MessageMgr:regist("MSG_SEVENDAY_GIFT_LIST", GiftMgr)
MessageMgr:regist("MSG_SEVENDAY_GIFT_FLAG", GiftMgr)
MessageMgr:regist("MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST", GiftMgr)
MessageMgr:regist("MSG_NEW_LOTTERY_OPEN", GiftMgr)
MessageMgr:regist("MSG_NEW_LOTTERY_INFO", GiftMgr)
MessageMgr:regist("MSG_NOTIFY_END_FESTIVAL_GIFT", GiftMgr)
MessageMgr:regist("MSG_MY_FESTIVAL_GIFT_INFO", GiftMgr)
MessageMgr:regist("MSG_FESTIVAL_GIFT_INFO", GiftMgr)
MessageMgr:regist("MSG_LOTTERY_INFO", GiftMgr)
MessageMgr:regist("MSG_AWARD_OPEN", GiftMgr)
MessageMgr:regist("MSG_NEWBIE_GIFT", GiftMgr)
MessageMgr:regist("MSG_DAILY_SIGN", GiftMgr)
MessageMgr:regist("MSG_AWARD_INFO_EX", GiftMgr)
MessageMgr:regist("MSG_OPEN_WELFARE", GiftMgr)
MessageMgr:regist("MSG_RECHARGE_GIFT", GiftMgr)
MessageMgr:regist("MSG_LOGIN_GIFT", GiftMgr)
MessageMgr:hook("MSG_GENERAL_NOTIFY", GiftMgr, "GiftMgr")
MessageMgr:regist("MSG_OPEN_GUESS_DIALOG", GiftMgr)
MessageMgr:regist("MSG_OPEN_STORE_DIALOG", GiftMgr)
MessageMgr:hook("MSG_CHAR_CHANGE_SEX", GiftMgr, "GiftMgr")
MessageMgr:regist("MSG_FESTIVAL_LOTTERY", GiftMgr)
MessageMgr:regist("MSG_FESTIVAL_LOTTERY_RESULT", GiftMgr)
MessageMgr:regist("MSG_ACTIVE_FETCH_SHOUCHONG", GiftMgr)
MessageMgr:regist("MSG_RECHARGE_SCORE_GOODS_LIST", GiftMgr)
MessageMgr:regist("MSG_RECHARGE_SCORE_GOODS_INFO", GiftMgr)
MessageMgr:regist("MSG_CONSUME_SCORE_GOODS_LIST", GiftMgr)
MessageMgr:regist("MSG_CONSUME_SCORE_GOODS_INFO", GiftMgr)
MessageMgr:regist("MSG_ACTIVE_BONUS_INFO", GiftMgr)
MessageMgr:regist("MSG_OPEN_ZAOHUA_ZHICHI", GiftMgr)
MessageMgr:regist("MSG_OPEN_XUNDAO_CIFU", GiftMgr)
MessageMgr:regist("MSG_WELCOME_DRAW_OPEN", GiftMgr)
MessageMgr:regist("MSG_MERGE_LOGIN_GIFT_LIST", GiftMgr)
MessageMgr:regist("MSG_OPEN_HUOYUE_JIANGLI", GiftMgr)

return GiftMgr
