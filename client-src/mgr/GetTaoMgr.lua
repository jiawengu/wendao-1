-- GetTaoMgr.lua
-- Created by liuhb Jan/27/2016
-- 刷道数据管理

GetTaoMgr = Singleton()

local Bitset = require("core/Bitset")

local getTaoData = {}
local additional = {}
local trusteeship = {}
local bonusData = nil

-- 刷道积分界面默认选择标签页
local getTaoPointCheckBox = "QdzhlCheckBox"

local VIP_OFFLINE_TIME = {
    [0] = 120,  -- 没有VIP等级
    [1] = 360,  -- 月卡
    [2] = 480,  -- 季卡
    [3] = 600,  -- 年卡
}

local VIP_TRUSTEESHIP_TIME = {
    [0] = 20,  -- 没有VIP等级
    [1] = 120,  -- 月卡
    [2] = 240,  -- 季卡
    [3] = 360,  -- 年卡
}


local VIP_TRUSTEESHIP_TIME_IN_NIGHT = {
    [0] = 180,  -- 没有VIP等级
    [1] = 360,  -- 月卡
    [2] = 480,  -- 季卡
    [3] = 600,  -- 年卡
}

local MAX_OFF_TIME = 1500 -- 离线刷的最长时间为1500分钟
local MAX_PET_FENG_SAN_POINT = 12000 -- 最多宠风散点数
local MAX_ZIQI_HONGMENG_POINT = 12000 -- 最多紫气鸿蒙点数
local MAX_JIJI_POINT = 4000  -- -- 最多急急如律令点数

local REWARD_INFO = {
    [1] = {name = CHS[6400034], introduce = CHS[4300076], score = 300},
    [2] = {name = CHS[6400034], introduce = CHS[4300076], score = 600},
    [3] = {name = CHS[6400034], introduce = CHS[4300076], score = 1200},
    [4] = {name = CHS[6400034], introduce = CHS[4300076], score = 2100},
    [5] = {name = CHS[6400034], introduce = CHS[4300076], score = 3300},
    [6] = {name = CHS[6400034], introduce = CHS[4300076], score = 4800},
    [7] = {name = CHS[6400034], introduce = CHS[4300076], score = 6600},
    [8] = {name = CHS[6400034], introduce = CHS[4300076], score = 8700},
    [9] = {name = CHS[6400034], introduce = CHS[4300076], score = 11100},
    [10] = {name = CHS[6400034], introduce = CHS[4300076], score = 13800},
}

local ZIQI_HONGMENG_REWARD_INFO = {
    [1] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 300},
    [2] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 600},
    [3] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 1200},
    [4] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 2100},
    [5] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 3300},
    [6] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 4800},
    [7] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 6600},
    [8] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 8700},
    [9] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 11100},
    [10] = {name = CHS[7000284], show_tag = CHS[7000288], introduce = CHS[4300076], score = 13800},
}

GetTaoMgr.SHUADAO_SCORE_ITEM_TYPE = 1

GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL = 70
GetTaoMgr.ZIQI_HONGMENG_REWARD_MIN_LEVEL = 70
GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL = 45
GetTaoMgr.USE_JIJIRULVLING_MIN_LEVEL = 45
GetTaoMgr.USE_RUYISHUADAOLING_MIN_LEVEL = 45

-- 清理数据
function GetTaoMgr:cleanup()
    getTaoData = {}
    bonusData = nil
    additional = {}
end

-- 请求离线刷道的信息
function GetTaoMgr:getScoreReward()
    return REWARD_INFO
end

-- 请求离线刷道的信息
function GetTaoMgr:requestOfflineShuadao()
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_OPEN_INTERFACE)
end

-- 获取刷道离线奖励数据
function GetTaoMgr:getBonusData()
    return bonusData
end

-- 获取刷道数据
function GetTaoMgr:getData()
    return getTaoData
end

-- 获取附加物品   双倍、急急如律令等
function GetTaoMgr:getAdditional()
    return additional
end

-- 获取急急如律令状态
function GetTaoMgr:getJijiStatus()
    return getTaoData.jijiStatus or 0
end

-- 获取离线刷道的状态
function GetTaoMgr:getOfflineStatus()
    return getTaoData.offlineStatus or 0
end

-- 获取宠风散状态
function GetTaoMgr:getChongfengsanStatus()
    return getTaoData.chongfengsan_status or 0
end

-- 获取宠风散是否开启
function GetTaoMgr:isChongfsEnable()
    return 1 == GetTaoMgr:getChongfengsanStatus()
end

function GetTaoMgr:getZiQiHongMengStatus()
    return getTaoData.ziqihongmeng_status or 0
end

-- 获取离线刷道的刷道轮次
function GetTaoMgr:getMyOfflineTurn()
    return getTaoData.max_turn or 0
end

-- 获取离线刷道的当前任务
function GetTaoMgr:getMyLastTask()
    if "" == getTaoData.lastTaskName or nil == getTaoData.lastTaskName then
        return CHS[3004034]
    end

    return getTaoData.lastTaskName
end

-- 获取离线刷道的最大双倍点数
function GetTaoMgr:getMyDoublePoint()
    return getTaoData.max_double or 0
end

-- 获取离线刷道的最大急急如律令
function GetTaoMgr:getMyJiji()
    return getTaoData.max_jiji or 0
end

-- 离线刷道设置的宠风散点数
function GetTaoMgr:getMyChongFengSan()
    return getTaoData.max_chongfengsan or 0
end

function GetTaoMgr:getMyZiQiHongMeng()
    return getTaoData.max_ziqihongmeng or 0
end

-- 获取离线刷道时间上线
function GetTaoMgr:getMaxOfflineTime()
    return MAX_OFF_TIME
end

-- 获取拥有的离线刷道时间
function GetTaoMgr:getAllOfflineTime()
    return getTaoData.off_line_time or 0
end

-- 拥有的双倍点数
function GetTaoMgr:getAllDoublePoint()
    return Me:queryInt("double_points")
end

-- 获取拥有的急急如律令点数
function GetTaoMgr:getAllJijiPoint()
    return Me:queryInt("shuadao/jiji-rulvling")
end

-- 获取拥有宠风散点数
function GetTaoMgr:getPetFengSanPoint()
    return  Me:queryInt("shuadao/chongfeng-san")
end

-- 获取拥有的紫气鸿蒙点数
function GetTaoMgr:getAllZiQiHongMengPoint()
    return Me:queryInt("shuadao/ziqihongmeng")
end

-- 获取拥有的如意召唤令
function GetTaoMgr:getRuYiZHLPoint()
    return Me:queryInt("shuadao/ruyi_point")
end

-- 获取最大的宠风散点数
function GetTaoMgr:getMaxChongFengSanPoint()
    return MAX_PET_FENG_SAN_POINT
end

-- 获取最大的紫气鸿蒙点数
function GetTaoMgr:getMaxZiQiHongMengPoint()
    return MAX_ZIQI_HONGMENG_POINT
end

-- 获取最大的急急如律令地点数
function GetTaoMgr:getMaxJiJiPoint()
    return MAX_JIJI_POINT
end

-- 获取金钱已购买宠风散的次数
function GetTaoMgr:getCashHaveBuyChongFengSanTimes()
    return getTaoData.chongfengsan_time or 0
end

-- 获取金钱可以购买宠风散最多次数
function GetTaoMgr:GetMaxCanBuyTimes()
    return getTaoData.max_chongfengsan_time or 0
end

-- 获取金钱已购买紫气鸿蒙的次数
function GetTaoMgr:getCashHaveBuyZiQiHongMengTimes()
    return getTaoData.ziqihongmeng_time or 0
end

-- 获取金钱可以购买紫气鸿蒙最多次数
function GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes()
    return getTaoData.max_ziqihongmeng_time or 0
end


-- 获取刷道任务的最高效率
function GetTaoMgr:getSpeed(taskName)
    if taskName == CHS[3004034] then
        return getTaoData.xy_higest or 0
    elseif taskName == CHS[3004035] then
        return getTaoData.fm_higest or 0
    elseif taskName == CHS[4000444] then
        return getTaoData.fx_higest or 0
    end
end

-- 获取玩家任务能够完成的最大轮次
function GetTaoMgr:getCanMaxTurn(taskName)
    local sp = self:getSpeed(taskName)
    if nil == sp or 0 == sp then
        return 0
    end

    -- 玩家可进行的刷道轮次，计算方式为int（玩家拥有离线时间/（选定任务效率/10））
    local offLineTime = self:getAllOfflineTime()
    local turn = offLineTime / (sp / 10)
    return math.floor(turn)
end

-- 获取完成任务n轮需要消耗的离线时间
function GetTaoMgr:getCostTime(taskName, turn)
    local sp = self:getSpeed(taskName)
    if nil == sp or 0 == sp then
        return 0
    end

    return math.floor(turn * sp / 10)
end

-- 获取完成任务的双倍点数消耗
function GetTaoMgr:getCostDoublePoint(taskName, turn)
    if taskName == CHS[4000444] then
        return 4 * turn * 4
    else
        return 4 * turn
    end
end

-- 获取完成任务的急急如律令消耗
function GetTaoMgr:getCostJijiPoint(taskName, turn)

    if taskName == CHS[4000444] then
        return 4 * turn
    else
        return turn
    end
end

-- 获取完成任务的宠风散消耗
function GetTaoMgr:getCostChongFengSan(taskName, turn)
    if taskName == CHS[4000444] then
        return 4 * turn * 4
    else
        return 4 * turn
    end
end

-- 获取完成任务的紫气鸿蒙消耗
function GetTaoMgr:getCostZiQiHongMeng(taskName, turn)
    if taskName == CHS[4000444] then
        return 4 * turn * 4
    else
        return 4 * turn
    end
end

-- 根据会员等级获得离线刷道的时间
function GetTaoMgr:getLevelOfflineTimeByVip(vip)
    return VIP_OFFLINE_TIME[vip]
end

-- 根据类型等级获得在线托管刷道的时间
-- -- 1为白天，2为夜间
function GetTaoMgr:getLevelTrusteeshipTimeByType(truType, vip)
    if truType == 2 then
        -- 夜间
        return VIP_TRUSTEESHIP_TIME_IN_NIGHT[vip]
    else
        return VIP_TRUSTEESHIP_TIME[vip]
    end
end

-- 根据会员等级获得在线托管刷道的时间
function GetTaoMgr:getLevelTrusteeshipTimeByVip(vip)
    if GetTaoMgr:isNightTrusteeship() then
        -- 夜间
        return VIP_TRUSTEESHIP_TIME_IN_NIGHT[vip]
    else
        return VIP_TRUSTEESHIP_TIME[vip]
    end
end

-- limitTime限制
function GetTaoMgr:getLimitMaxTurn(taskName, vip)
    local sp = self:getSpeed(taskName)
    if nil == sp or 0 == sp then
        return 0
    end

    return math.floor(VIP_OFFLINE_TIME[vip] * 60 / (sp / 10))
end

-- 获取对应任务的显示字符串
function GetTaoMgr:getTaskSpeedStr(taskName)
    local speedStr = ""
    local taskSpeed = self:getSpeed(taskName)
    if nil == taskSpeed or 0 == taskSpeed then
        speedStr = CHS[3004036]
    else
        local min = math.floor(taskSpeed / 60)
        local sec = taskSpeed % 60
        if 0 >= min then
            speedStr = string.format(CHS[3004037], sec)
        elseif 0 < sec then
            speedStr = string.format(CHS[3004038], min, sec)
        else
            speedStr = string.format(CHS[3004039], min)
        end
    end

    return string.format("%s %s", taskName, speedStr)
end

-- 是否存在离线奖励
function GetTaoMgr:isHasOfflineBonus()
    if not getTaoData.hasBonus or 0 == getTaoData.hasBonus then
        return false
    else
        return true
    end
end

-- 是否有道法奖励
function GetTaoMgr:isHasDaofaBonus()
    if not getTaoData.hasDaofaBonus or 0 == getTaoData.hasDaofaBonus then
        return false
    else
        return true
    end
end

-- 是否存在离线奖励数据
function GetTaoMgr:isHasOfflineBonusInfo()
    if bonusData then
        return true
    else
        return false
    end
end

-- 获取购买时间
function GetTaoMgr:getBuyTime()
    return getTaoData.buy_time or 0
end

-- 获取购买一次时间
function GetTaoMgr:getBuyOne()
    return getTaoData.buy_one or 0
end

-- 获取购买五次时间
function GetTaoMgr:getBuyFive()
    return getTaoData.buy_five or 0
end

-- 检查设置的双倍点数是否足够
-- true 足够
-- false 不足够
function GetTaoMgr:checkDoubleWithOffline()
    if not getTaoData then
        return true
    end

    if self:getAllDoublePoint() < GetTaoMgr:getMyDoublePoint() then
        return false
    end

    return true
end

-- 检查设置的急急如律令是否足够
function GetTaoMgr:checkJijiWithOffline()
    if not getTaoData then
        return true
    end

    if self:getAllJijiPoint() < GetTaoMgr:getMyJiji() then
        return false
    end

    return true
end

-- 检查设置的宠风散是否足够
function GetTaoMgr:checkCfsWithOffline()
    if not getTaoData then
        return true
    end

    if self:getPetFengSanPoint() < GetTaoMgr:getMyChongFengSan() then
        return false
    end

    return true
end

-- 检查离线刷道是否已经开启
function GetTaoMgr:checkOfflineIsOn()
    if 1 == GetTaoMgr:getOfflineStatus() then
        return true
    end

    return false
end

-- 判断是否弹出确认框
function GetTaoMgr:checkHasGetTaoBonusDlg()
    if not GetTaoMgr:getData() then
        -- 没有数据
        return
    end

    if not GetTaoMgr:isHasOfflineBonus() then
        -- 不存在奖励
        return
    end

    gf:confirm(CHS[5300009], function()
        DlgMgr:openDlg("GetTaoOfflineDlg")
    end)
end

-- 附加道具状态
function GetTaoMgr:MSG_SHUADAO_USEPOINT_STATUS(data)
    additional = data
end

-- 托管数据
function GetTaoMgr:MSG_REFRESH_SHUAD_TRUSTEESHIP(data)
    trusteeship = data
    trusteeship.ti = math.ceil(data.ti / 60)
    if data.ti == 0 then
        trusteeship.state = TRUSTEESHIP_STATE.OFF
    else
        if data.state == 1 then
            trusteeship.state = TRUSTEESHIP_STATE.OPEN
        else
            trusteeship.state = TRUSTEESHIP_STATE.PAUSE
        end
    end
end

function GetTaoMgr:getTrusteeshipData()
    return trusteeship
end

-- 缓存数据
function GetTaoMgr:MSG_SHUADAO_REFRESH(data)
    getTaoData = data
end

function GetTaoMgr:MSG_SHUADAO_REFRESH_BONUS(data)
    bonusData = data
end

function GetTaoMgr:MSG_SHUADAO_REFRESH_BUY_TIME(data)
    getTaoData.buy_one = data.buy_one
    getTaoData.buy_five = data.buy_five
    getTaoData.off_line_time = data.off_line_time
    getTaoData.buy_time = data.buy_time
end

-- 设置只能托管状态， state == 0否， 1 是
function GetTaoMgr:setSmartState(state)
    gf:CmdToServer("CMD_SHUAD_SMART_TRUSTEESHIP", {is_smart = state})
end

function GetTaoMgr:setOffLineDouble(enble)
    gf:CmdToServer("CMD_SET_OFFLINE_DOUBLE_STATUS", {enble = enble})
end

function GetTaoMgr:buyTrusteeshipTime(ti)
    ti = ti * 60
    gf:CmdToServer("CMD_BUY_SHUAD_TRUSTEESHIP_TIME", {ti = ti})
end

function GetTaoMgr:setTrusteeshipTask(taskName)
    gf:CmdToServer("CMD_SET_SHUAD_TRUSTEESHIP_TASK", {taskName = taskName})
end

function GetTaoMgr:setOffLineJJRLL(enble)
    gf:CmdToServer("CMD_SET_OFFLINE_JIJI_STATUS", {enble = enble})
end

function GetTaoMgr:setOffLineCFS(enble)
    gf:CmdToServer("CMD_SET_OFFLINE_CHONGFS_STATUS", {enble = enble})
end

-- 紫气鸿蒙离线开关
function GetTaoMgr:setOffLineZQHM(enable)
    gf:CmdToServer("CMD_SET_OFFLINE_ZIQIHONGMENG_STATUS", {enble = enable})
end

function GetTaoMgr:fetchScoreItem(type, index)
    gf:CmdToServer("CMD_FETCH_SHUADAO_SCORE_ITEM", {type = type, index = index})
end

function GetTaoMgr:questTrusteeshData()
    gf:CmdToServer("CMD_REFRESH_SHUAD_TRUSTEESHIP", {})
end

-- 0 // 关闭                             1   // 开启                               2   // 暂停
function GetTaoMgr:setTrusteeshState(state)
    gf:CmdToServer("CMD_SET_SHUAD_TRUSTEESHIP_STATE", {state = state})
end

function GetTaoMgr:openTrusteeship(ti)
    ti = ti * 60
    gf:CmdToServer("CMD_OPEN_SHUAD_TRUSTEESHIP", {ti = ti})
end

-- type 1:双倍         2:急急如律令           3：宠风散  4.紫气鸿蒙
function GetTaoMgr:getOffLineCostStatus(type)
    if not additional or not next(additional) then return 0 end
    if type == 1 then
        return additional.doubleOffLineState
    elseif type == 2 then
        return additional.jjrllOffLineState
    elseif type == 3 then
        return additional.cfsOffLineState
    elseif type == 4 then
        return additional.zqhmOffLineState
    end
end

-- 检测主界面的小红点，当相应状态开启，但是消耗不足的时候给予主界面刷道按钮小红点
function GetTaoMgr:chechRedDot()
    if not additional or not next(additional) then return end   -- 相关数据没有
    if not getTaoData or not next(getTaoData) then return end   -- 相关数据没有

    if DistMgr:getIsSwichServer() then return end   -- 换线不进行检测
    if not GetTaoMgr:checkOfflineIsOn() then return end -- 离线刷道关闭不进行检测

    -- 如果双倍点数开启，设置消耗双倍点数大于拥有的双倍点数，给予小红点
    if additional.doubleOffLineState == 1 then
        if getTaoData.max_double > GetTaoMgr:getAllDoublePoint() then
            return true
        end
    end

    -- 如果急急如律令开启，设置的消耗点数大于拥有的消耗点数，给予小红点
    if additional.jjrllOffLineState == 1 then
        if getTaoData.max_jiji > GetTaoMgr:getAllJijiPoint() then
            return true
        end
    end

    -- 如果宠风散开启，设置的消耗点数大于拥有的消耗点数，给予小红点
    if additional.cfsOffLineState == 1 then
        if getTaoData.max_chongfengsan > GetTaoMgr:getPetFengSanPoint() then
            return true
        end
    end

    -- 如果紫气鸿蒙开启，设置的消耗点数大于拥有的消耗点数，给予小红点
    if additional.zqhmOffLineState == 1 then
        if getTaoData.max_ziqihongmeng > GetTaoMgr:getAllZiQiHongMengPoint() then
            return true
        end
    end
end

function GetTaoMgr:MSG_SHUADAO_SCORE_ITEMS(data)
    self.scoreData = data
    self:addOrRemoveRedDot()
end

function GetTaoMgr:addOrRemoveRedDot()
    local data = self.scoreData

    if not data then
        return
    end

    -- 刷道积分的小红点显示
    local stateBit = Bitset.new(data.fetchState)
    local hasRedDot = false

    for i = 1, 10 do
        if stateBit:isSet(i) then

        else
            if data.score >= REWARD_INFO[i].score and not DistMgr:getIsSwichServer() then
                RedDotMgr:insertOneRedDot("SystemFunctionDlg", "ShuadaoButton", nil, "red_for_QDZHL")
                RedDotMgr:insertOneRedDot("GetTaoTabDlg", "GetTaoPointTabDlgCheckBox", nil, "red_for_QDZHL")

                hasRedDot = true
            end
        end
    end

    -- 如果强盗领赏令和紫气鸿蒙都不可领取
    if not hasRedDot then
        RedDotMgr:removeOneRedDot("GetTaoTabDlg", "GetTaoPointTabDlgCheckBox")
    end
end

-- 请求刷道托管结算数据
function GetTaoMgr:queryTrusteeshipInfo()
    gf:CmdToServer("CMD_SHUADAO_TRUSTEESHIP_INFO", {})
end

-- 刷道数据结算
function GetTaoMgr:MSG_SHUADAO_TRUSTEESHIP_INFO(data)
    local dlg = DlgMgr:openDlg("GetTaoTrusteeshipResultDlg")
    dlg:setData(data)

    local dlg2 = DlgMgr:getDlgByName("GetTaoTrusteeshipDlg")
    if dlg2 then
        local rect = dlg2:getBoundingBoxInWorldSpace(dlg2:getControl("ResultButton"))
        dlg:setFloatingFramePos(rect)
    end
end

-- 离线刷道数据刷新回来
function GetTaoMgr:MSG_SHUADAO_REFRESH_BONUS(data)
    local dlg = DlgMgr:openDlg("GetTaoRewardDlg")
    dlg:setData(data)
end

function GetTaoMgr:getRuYiZHLState()
    return self.ruyiZHLState
end

function GetTaoMgr:getRuYiZHLAMTState()
    return self.ruyiZHLamtState
end

-- 如意召唤令开启状态
function GetTaoMgr:MSG_REFRESH_RUYI_INFO(data)
    self.ruyiZHLState = data.state == 1
    self.ruyiZHLamtState = data.amt_state == 1
end

-- 检查队伍状态
function GetTaoMgr:checkTaoTeamState(actName)
    if not self:getRuYiZHLState() then
        -- 不在如意刷道令状态
        return
    end

    if not GetTaoMgr:getRuYiZHLAMTState() then
        return
    end

    if Me:isTeamLeader() then
        local matchInfo = TeamMgr:getCurMatchInfo()
        if not matchInfo then return end    -- 没找到匹配信息
        if string.isNilOrEmpty(matchInfo.name) or matchInfo.name ~= actName then
            -- 没有指定活动的匹配信息
            matchInfo.name = actName
            matchInfo.minLevel, matchInfo.maxLevel = TeamMgr:getActiveRange(actName)
        else
            if MATCH_STATE.LEADER == matchInfo.state then
                -- 如果已经处于匹配状态
            return
        end
        end

        if Me:hasTitle(Const.TITLE_TEAM_LEADER_TEAM_FULL) then
            -- 队伍满了
            -- TeamMgr:requestTeamList(matchInfo.name)
        else
            -- 匹配队列
            TeamMgr:requestMatchMember(matchInfo.name, matchInfo.minLevel, matchInfo.maxLevel)
        end
    end
end

function GetTaoMgr:MSG_SHUADAO_FINAL_ROUND(data)
    self:checkTaoTeamState(data.task_name)
end

function GetTaoMgr:MSG_CHECK_SHUADAO_BONUS(data)
    self:checkHasGetTaoBonusDlg()
end

function GetTaoMgr:isNightTrusteeship()
    local h = tonumber(os.date("%H", gf:getServerTime()))
    if h >= 22 or h < 2 then
        return true
    else
        return false
    end
end

MessageMgr:regist("MSG_REFRESH_RUYI_INFO", GetTaoMgr)
MessageMgr:regist("MSG_REFRESH_SHUAD_TRUSTEESHIP", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_USEPOINT_STATUS", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_REFRESH", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_REFRESH_BONUS", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_REFRESH_BUY_TIME", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_SCORE_ITEMS", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_TRUSTEESHIP_INFO", GetTaoMgr)
MessageMgr:regist("MSG_SHUADAO_FINAL_ROUND", GetTaoMgr)
MessageMgr:regist("MSG_CHECK_SHUADAO_BONUS", GetTaoMgr)

return GetTaoMgr
