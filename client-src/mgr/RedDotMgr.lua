-- RedDotMgr.lua
-- Created by liuhb Apr/25/2015
-- 负责游戏小红点管理

RedDotMgr = Singleton()
local redDotList = {
    -- for test by liuhb
    -- ["SystemFunctionDlg"] = {"MarketButton", "ExerciseButton", "WorldMapButton", "SmallMapButton", "ActivityButton"},
}

local blinkRedDotList= {}

local redDotListReason = {}

-- 系统功能按钮
local gameFunctionRedDotList = {
    "PartyButton",
    "EquipButton",
    "GuardButton",
    "SystemButton",
    "WatchCenterButton",
    "HomeButton",
    "AchievementButton",
    "CommunityButton",
    "MarryBookButton",
    "SocialButton",
}

local SAVE_PATH = Const.WRITE_PATH .. "redDot/"
local REASON_SAVE_PATH = Const.WRITE_PATH .. "reasonRedDot/"
local BLINK_SAVE_PATH = Const.WRITE_PATH .. "blinkRedDot/"

local redDot = {}

local ACTIVE_RESET_TIME = "05:00"       -- 每天重置时间
local REFRESH_DURING = 30               -- 刷新间隔

-- 红点信息不需要保存到本地的界面
local RED_DOT_NOT_SAVE_FILE_DLG = {
    ["GameFunctionDlg"] = true,
    ["FriendDlg"] = true,
    ["SystemFunctionDlg"] = true,
    ["OnlineMallTabDlg"] = true,
    ["WelfareDlg"] = true,
    ["PartyInfoTabDlg"] = true,
    ["PartyMemberDlg"] = true,
    ["SystemAccManageDlg"] = true,
    ["AnniversaryTabDlg"] = true,
}

-- 初始化
function RedDotMgr:init()
    self:loadRedDotCfg()
    self.activeHasAddRedDot = {}
end

function RedDotMgr:loadRedDotCfg()
    redDot = require("cfg/RedDot")

    self.accRedDot = {}
    for _, v in pairs(redDot) do
        if v and type(v[4]) == "boolean" then
            if not self.accRedDot[v[1]] then self.accRedDot[v[1]] = {} end
            self.accRedDot[v[1]][v[2]] = v[4]
        end
    end
end

function RedDotMgr:loadRedDot()
    local gid = Me:queryBasic("gid")
    local acc = Client:getAccount()
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. gid .. ".lua"
    local filePathReason = cc.FileUtils:getInstance():getWritablePath() .. REASON_SAVE_PATH .. gid .. ".lua"
    local filePathBlink = cc.FileUtils:getInstance():getWritablePath() .. BLINK_SAVE_PATH .. gid .. ".lua"
    local accFilePath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. acc .. ".lua"
    local accFilePathReason = cc.FileUtils:getInstance():getWritablePath() .. REASON_SAVE_PATH .. acc .. ".lua"
    local ret1 = self:loadRedDotFromFile(filePath, filePathReason, filePathBlink)
    local ret2 = self:loadRedDotFromFile(accFilePath, accFilePathReason)

    if ret1 or ret2 then
        -- 检查一下从“data/redDot”中获取的小红点是否仍然有效
        self:checkRedDot()

        self:checkAddChatRedDot(true)

        -- 清空本地小红点
        if not self:notLoadRedDotFromFile() then
            -- 非跨服区组中已取完本地的小红点，要做清空

            -- 存储内容
            local saveData = "return {\n"
            saveData = saveData .. "}"

            gfSaveFile(saveData, SAVE_PATH .. gid .. ".lua")
            gfSaveFile(saveData, REASON_SAVE_PATH .. gid .. ".lua")
            gfSaveFile(saveData, BLINK_SAVE_PATH .. gid .. ".lua")
            gfSaveFile(saveData, SAVE_PATH .. acc .. ".lua")
            gfSaveFile(saveData, REASON_SAVE_PATH .. acc .. ".lua")
        end
    end

    if nil ~= self.scheduleId then
        gf:Unschedule(self.scheduleId)
    end

    local function update(d)
        self:updateRedDot(d)
    end

    self.scheduleId = gf:Schedule(update, REFRESH_DURING)
    self:updateRedDot()
    self:setUpdateActiveRedDot()
end

function RedDotMgr:notLoadRedDotFromFile()
    if DistMgr:isInKFSDServer()
        or DistMgr:isInQMPKServer()
        or DistMgr:isInKFZCServer()
        or DistMgr:isInNSZBServer()
        or DistMgr:isInXMZBServer()
        or DistMgr:isInMRZBServer()
        or DistMgr:isInKFJJServer() then
        -- 跨服区组中不取本地的小红点
        return true
    end
end

-- 部分需要验证是否需要
function RedDotMgr:checkValidRedDot(dlgName, ctrlTab)
    if type(ctrlTab) == "table" then
        for _, ctrlName in pairs(ctrlTab) do
            if dlgName == "GetTaoOfflineDlg" and ctrlName == "RewardButton" then
                -- 离线刷道小红点
                if not GetTaoMgr:isHasOfflineBonus() then
                    ctrlTab[_] = nil
                end
            end

            if dlgName == "GetTaoTabDlg" and ctrlName == "OfflineGetTaoTabDlgCheckBox" then
                -- 离线刷道小红点
                if not GetTaoMgr:isHasOfflineBonus() then
                    ctrlTab[_] = nil
                end
            end
        end
    end

    return ctrlTab
end

function RedDotMgr:loadRedDotFromFile(filePath, filePathReason, filePathBlink)
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local temp = dofile(filePath)
        if nil == temp or type(temp) ~= "table" or RedDotMgr:notLoadRedDotFromFile() then
            temp = {}
        end

        for key, value in pairs(temp) do
            if not RED_DOT_NOT_SAVE_FILE_DLG[key] then
                -- 红点信息需要保存到本地的界面
            if redDotList[key] then
                for key2, v in pairs(value) do
                    redDotList[key][key2] = v
                end
            else
                value = RedDotMgr:checkValidRedDot(key, value)
                redDotList[key] = value
            end
        end
        end

        if cc.FileUtils:getInstance():isFileExist(filePathReason) then
            -- 获取本地小红点原因
            local temp = dofile(filePathReason)
            if nil == temp or type(temp) ~= "table" or RedDotMgr:notLoadRedDotFromFile() then
                temp = {}
            end

            for key, value in pairs(temp) do
                if redDotListReason[key] then
                    for key2, value2 in pairs(value) do
                        if redDotListReason[key][key2] then
                            for key3, v in pairs(value2) do
                                redDotListReason[key][key2][key3] = v
                            end
                        else
                            redDotListReason[key][key2] = value2
                        end
                    end
                else
                    redDotListReason[key] = value
                end
            end
        end

        if cc.FileUtils:getInstance():isFileExist(filePathBlink) then
            -- 获取本地小红点原因
            local temp = dofile(filePathBlink)
            if nil == temp or type(temp) ~= "table" or RedDotMgr:notLoadRedDotFromFile() then
                temp = {}
            end

            for key, value in pairs(temp) do
                if blinkRedDotList[key] then
                    for key2, v in pairs(value) do
                        blinkRedDotList[key][key2] = v
                    end
                else
                    blinkRedDotList[key] = value
                end
            end
        end
        return true
    end
end

function RedDotMgr:checkRedDot()
    if redDotList["OnlineMallTabDlg"] and redDotList["OnlineMallTabDlg"]["VIPCheckBox"] then
        if Me:isGetCoin() or Me:getVipType() == 0 then
            -- 如果已经领取过元宝，则会员标签页的小红点无效
            RedDotMgr:removeOneRedDot("OnlineMallTabDlg", "VIPCheckBox")

            if not self:hasRedDotInfoByDlgName("OnlineMallTabDlg", "ItemCheckBox") then
                RedDotMgr:removeOneRedDot("SystemFunctionDlg", "MallButton")
            end
        end
    end
end

-- 检查需不需要加聊天的小红点
function RedDotMgr:checkAddChatRedDot(isInit)
    local chatDot = redDotList["FriendChat"]
    local tempchatDot = redDotList["tempFriendChat"]
    local friend = redDotList["FriendDlg"] or {}

    if not SystemMessageMgr:getIsSwichServer() then
        if tempchatDot then
            for gid, v in pairs(tempchatDot) do
                if FriendMgr:getTemFriendByGid(gid) or isInit then
                    -- isInit = true 时临时好友可能还未宠数据库中读出，故不判断是否有该临时好友
                    -- 会另在 RedDotMgr:delFriendRedDotInfo() 中检测
            RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, true)
            RedDotMgr:insertOneRedDot("FriendDlg", "TempCheckBox", nil, nil, true)
            RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, true)
                    break
                else
                    tempchatDot[gid] = nil
        end
            end
        end

        local chatDot = redDotList["GroupChat"]
        if chatDot then
            for groupId, v in pairs(chatDot) do
               if FriendMgr:getGroupByGroupId(groupId) or isInit then
            local isBlink = blinkRedDotList["GroupChat"] and next(blinkRedDotList["GroupChat"]) ~= nil
            RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, isBlink)
            RedDotMgr:insertOneRedDot("FriendDlg", "GroupCheckBox", nil, nil, isBlink)
            RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, isBlink)
                    break
                else
                    chatDot[groupId] = nil
        end
            end
        end

        if redDotList["FriendDlg"] and redDotList["FriendDlg"]["NewFriendButton"] then
            RedDotMgr:insertOneRedDot("FriendDlg", "FriendCheckBox")
        end

        if redDotList["FriendDlg"] and redDotList["FriendDlg"]["GroupNewsButton"] then
            RedDotMgr:insertOneRedDot("FriendDlg", "GroupCheckBox")
        end
    end

    if redDotList["ChatDlg"] and redDotList["ChatDlg"]["FriendButton"] and not DistMgr:isInKFZC2019Server() then
        RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
    end

    if redDotList["ChannelDlg"] and redDotList["ChannelDlg"]["FriendDlgButton"] then
        RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton")
    end

    if friend["FriendReturnButton"] then
        RedDotMgr:insertOneRedDot("FriendDlg", "FriendReturnButton")
    end

    if friend["TempReturnButton"] then
        RedDotMgr:insertOneRedDot("FriendDlg", "TempReturnButton")
    end

    if friend["GroupReturnButton"] then
        RedDotMgr:insertOneRedDot("FriendDlg", "GroupReturnButton")
    end

    if redDotList["FriendDlg"] and redDotList["FriendDlg"]["TempCheckBox"] then
        RedDotMgr:insertOneRedDot("FriendDlg", "TempCheckBox")
    end

    if redDotList["ChannelDlg"] and redDotList["ChannelDlg"]["PartyCheckBox"] then
        local isBlink = blinkRedDotList["ChannelDlg"] and blinkRedDotList["ChannelDlg"]["PartyCheckBox"]
        RedDotMgr:insertOneRedDot("ChannelDlg", "PartyCheckBox", nil, nil, isBlink)
        RedDotMgr:insertOneRedDot("ChatDlg", "ChatButton", nil, nil, isBlink)
    end
end

-- 删除历史遗留的小红点信息
function RedDotMgr:delFriendRedDotInfo()
    local isBlank = nil
    if redDotList["FriendChat"] and next(redDotList["FriendChat"]) then
        for k, v in pairs(redDotList["FriendChat"]) do
            if not FriendMgr:getFriendByGid(v) then
                self:removeOneRedDot("FriendChat", k)
            end
        end
    end

    if redDotList["tempFriendChat"] and next(redDotList["tempFriendChat"]) then
        for k, v in pairs(redDotList["tempFriendChat"]) do
            if not FriendMgr:getTemFriendByGid(v) then
                self:removeOneRedDot("tempFriendChat", k)
            else
                isBlank = true
            end
        end
    end

    if redDotList["GroupChat"] then
        for k, v in pairs(redDotList["GroupChat"]) do
            if not FriendMgr:getGroupByGroupId(v)
                or not next(FriendMgr:getGroupByGroupId(v)) then
                self:removeOneRedDot("GroupChat", k)
            end
        end
    end

    if not self:hasRedDotInfoByOnlyDlgName("tempFriendChat") then
        -- 最近联系人所有的小红点若删完，应删除 TempCheckBox 的小红点
        self:removeOneRedDot("FriendDlg", "TempCheckBox")
    end

    if not self:hasRedDotInfoByOnlyDlgName("GroupChat")
        and not self:hasRedDotInfoByDlgName("FriendDlg", "GroupNewsButton") then
        -- 群组所有的小红点若删完，且群系统消息中没有，应删除 GroupCheckBox 的小红点
        self:removeOneRedDot("FriendDlg", "GroupCheckBox")
    end

    if self:hasRedDotInfoByOnlyDlgName("FriendDlg") then
        -- 由于删除 TempCheckBox 的小红点，会同时删除 FriendButton 的小红点，故需重新插入
        self:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, isBlank)
        self:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, isBlank)
    else
        self:removeOneRedDot("ChatDlg", "FriendButton")
        self:removeOneRedDot("ChannelDlg", "FriendDlgButton")
    end
end

-- 清除不加入本地的小红点
function RedDotMgr:someNotSaveToFile()
    for k, v in pairs(RED_DOT_NOT_SAVE_FILE_DLG) do
        redDotList[k] = nil
    end

    if redDotList["SystemConfigTabDlg"] then
        redDotList["SystemConfigTabDlg"]["SystemConfigTabDlg"] = nil
        redDotList["SystemConfigTabDlg"]["SystemAccManageDlgCheckBox"] = nil
    end

    if redDotList["ChannelDlg"] then
        redDotList["ChannelDlg"]["PartyCheckBox"] = nil
    end

    if redDotList["AnniversaryTabDlg"] then
        redDotList["AnniversaryTabDlg"]["LMFPCheckBox"] = nil

        if not next(redDotList["AnniversaryTabDlg"]) then
            if redDotList["SystemFunctionDlg"] then
                redDotList["SystemFunctionDlg"]["AnniversaryButton"] = nil
            end
        end
    end

    if blinkRedDotList["ChannelDlg"] then
        blinkRedDotList["ChannelDlg"]["PartyCheckBox"] = nil
    end

    if blinkRedDotList["GroupChat"] then
        blinkRedDotList["GroupChat"] = nil
    end
end

function RedDotMgr:cleanup()
    self.activeHasAddRedDot = {}

    if nil ~= self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end

    if (not next(redDotList)
        and not next(redDotListReason))
        or RedDotMgr:notLoadRedDotFromFile() then
        redDotList = {}
        redDotListReason = {}
        return
    end

    self.isOnce = nil

    local saveData = ""
    local reasonSaveData = ""
    local blinkSaveData = ""
    local accSaveData = ""
    local accReasonSaveData = ""

    self:someNotSaveToFile()

    -- 存储内容
    saveData = saveData .. "return {\n"
    reasonSaveData = reasonSaveData .. "return {\n"
    blinkSaveData = blinkSaveData .. "return {\n"
    accSaveData = accSaveData .. "return {\n"
    accReasonSaveData = accReasonSaveData .. "return {\n"

    local count = 0;

    for key1, v in pairs(redDotList) do
        if nil ~= v and nil ~= next(v) then
            local curData
            local curReasonData
            local curBlinkData

            local curGidData = ""
            local curGidReasonData = ""
            local curGidBlinkData = ""
            local curAccData = ""
            local curAccReasonData = ""

            for key2, v2 in pairs(v) do
                curData = ""
                curReasonData = ""
                curBlinkData = ""

                local sigleData = ""
                sigleData = string.format("['%s'] = '%s',", key2, key2)

                curData = curData .. sigleData

                if redDotListReason and redDotListReason[key1] and redDotListReason[key1][key2] and next(redDotListReason[key1][key2]) then
                    curReasonData = curReasonData .. string.format("['%s'] = {", key2)
                    for key3, reason in pairs(redDotListReason[key1][key2]) do
                        curReasonData = curReasonData .. string.format("['%s'] = '%s',", key3, reason)
                    end

                    curReasonData = curReasonData .. "},"
                end

                if blinkRedDotList[key1] and blinkRedDotList[key1][key2] then
                    curBlinkData = curBlinkData .. string.format("['%s'] = true,", key2)
                end

                if self.accRedDot[key1] and self.accRedDot[key1][key2] then
                    curAccData = curAccData .. curData
                    curAccReasonData = curAccReasonData .. curReasonData
                else
                    curGidData = curGidData .. curData
                    curGidReasonData = curGidReasonData .. curReasonData
                    curGidBlinkData = curGidBlinkData .. curBlinkData
                end
            end

            if curGidData and #curGidData > 0 then
                saveData = saveData .. string.format("['%s'] = {", key1)
                saveData = saveData .. curGidData
                saveData = saveData .. "},"
            end

            if curGidBlinkData and #curGidBlinkData > 0 then
                blinkSaveData = blinkSaveData .. string.format("['%s'] = {", key1)
                blinkSaveData = blinkSaveData .. curGidBlinkData
                blinkSaveData = blinkSaveData .. "},"
            end

            if curGidReasonData and #curGidReasonData > 0 then
                reasonSaveData = reasonSaveData .. string.format("['%s'] = {", key1)
                reasonSaveData = reasonSaveData .. curGidReasonData
                reasonSaveData = reasonSaveData .. "},"
            end

            if curAccData and #curAccData > 0 then
                accSaveData = accSaveData .. string.format("['%s'] = {", key1)
                accSaveData = accSaveData .. curAccData
                accSaveData = accSaveData .. "},"
            end

            if curAccReasonData and #curAccReasonData > 0 then
                accReasonSaveData = accReasonSaveData .. string.format("['%s'] = {", key1)
                accReasonSaveData = accReasonSaveData .. curAccReasonData
                accReasonSaveData = accReasonSaveData .. "},"
            end
        end
    end

    saveData = saveData .. "}"
    reasonSaveData = reasonSaveData .. "}"
    blinkSaveData = blinkSaveData .. "}"
    accSaveData = accSaveData .. "}"
    accReasonSaveData = accReasonSaveData .. "}"

    local gid = Me:queryBasic("gid")
    gfSaveFile(saveData, SAVE_PATH .. gid .. ".lua")
    gfSaveFile(reasonSaveData, REASON_SAVE_PATH .. gid .. ".lua")
    gfSaveFile(blinkSaveData, BLINK_SAVE_PATH .. gid .. ".lua")

    local acc = Client:getAccount()
    gfSaveFile(accSaveData, SAVE_PATH .. acc .. ".lua")
    gfSaveFile(accReasonSaveData, REASON_SAVE_PATH .. acc .. ".lua")

    redDotList = {}
    blinkRedDotList = {}
    redDotListReason = {}
end



-- 检测小红点信息
function RedDotMgr:updateRedDot(d)
	-- Log:D(">>>> update ALL Red Dot")

    self:updateLimitActivities()
    self:updateGFDShowBtnRedDot()
    self:updateSFDShowBtnRedDot()
end

-- 检查某些特殊的活动
function RedDotMgr:checkShuilanzyRedDot(level)
    -- 水岚之缘-剧情 某些任务状态不显示小红点
    local index = ActivityMgr:hasNewTaskShuilanzy(level)
    if index and not self.activeHasAddRedDot[index .. "slzy"] then
        self:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "FestivalCheckBox")
        self:insertOneRedDot("ActivitiesDlg", "FestivalCheckBox", nil, "FestivalCheckBox")
        self.activeHasAddRedDot[index .. "slzy"] = true
    end
end

-- 检查某些特殊的活动
function RedDotMgr:checkSpecialFestivalRedDot(ctrlName)
    if ctrlName == CHS[5410206] and not ActivityMgr:hasNewTaskShuilanzy() then
        -- 水岚之缘-剧情 某些任务状态不显示小红点
        return false
    end

    return true
end

-- 检查某些特殊的活动
function RedDotMgr:checkSpecialLimitRedDot(active)
    if active == CHS[3000728] then -- 试道会选拔赛
        if Me:queryBasicInt("shidao-dahui") == 1 or Me:queryBasicInt("shidao-dahui") == 2 then
            return false
        end
    elseif active == CHS[6400001] then -- 试道大会决赛
        if Me:queryBasicInt("shidao-dahui") ~= 2 then
            return false
        end
    elseif active == CHS[4200659] then -- 问道好声音
        return false
    end

    return true
end

-- 更新节日活动小红点
function RedDotMgr:updateFestivalActivities()
    local activitys = ActivityMgr:getFestivalActivity(true)
    local hasRedDot = false
    for i, activity in pairs(activitys) do
        local timeStr = activity["activityTime"][1][1]
        if not ActivityMgr:isFinishActivity(activity)
            and self:checkSpecialFestivalRedDot(activity.name) then
            hasRedDot = true
            if GameMgr.isFirstLoginToday
                  and not self.activeHasAddRedDot["Festival"] then
                -- 非首次登录不用添加小红点
                -- 正常的节日活动一天只添加一次小红点
                -- 水岚之缘-剧情的小红点特殊处理
                self:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "FestivalCheckBox")
                self:insertOneRedDot("ActivitiesDlg", "FestivalCheckBox", nil, "FestivalCheckBox")
                self.activeHasAddRedDot["Festival"] = true
                break
            end
        end
    end

    if not hasRedDot then
        -- 没有可做的节日活动，移除节日活动小红点
        self:removeOneRedDot("ActivitiesDlg", "FestivalCheckBox", nil, "FestivalCheckBox")
    end
end

-- 更新福利活动小红点,仅能用登入时刷新！！
function RedDotMgr:updateWelfareActivities()
    if ActivityMgr:isHaveWelfareStart() and GameMgr.isFirstLoginToday then
        local welfareAct = ActivityMgr:getWelfareActivity()
        local cou = 0
        for _, v in pairs(welfareAct) do
            if v.name == CHS[4300244] or v.name == CHS[4300236] then
                cou = cou + 1
            end
        end

        -- 判断福利活动是否除了 实名认证礼包 和 月首冲礼包外，没有其他礼包
        if #welfareAct == cou then
            -- 如果福利界面有实名认证，是否加小红点在 RedDotMgr:MSG_ACTIVITY_DATA_LIST(data) 判断
            -- 月首冲礼包，是否加小红点在 RedDotMgr:MSG_FESTIVAL_LOTTERY(data) 判断
        else
            self:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "WelfareCheckBox")
            self:insertOneRedDot("ActivitiesDlg", "WelfareCheckBox", nil, "WelfareCheckBox")
        end
    end
end

-- 更新活动小红点信息
function RedDotMgr:updateLimitActivities()
    local activitys = ActivityMgr:getLimitActivityEx()
    local hasActivity = false

    for i, activity in pairs(activitys) do
        local stateData = ActivityMgr:isCurActivity(activity)
        -- local isToday = ActivityMgr:isActivityToday(activity)
        local isCurTime, curTimeIndex = stateData[1], stateData[2]
        if not self.activeHasAddRedDot[activity.name] then
            self.activeHasAddRedDot[activity.name] = {}
        end

        if isCurTime and not ActivityMgr:isFinishActivity(activity) and self:checkSpecialLimitRedDot(activity.name) then
            -- 有活动未完成且正好开启
            hasActivity = true
            if not self.activeHasAddRedDot[activity.name][curTimeIndex] then
                -- 未标记过小红点
                self:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "LimitedCheckBox")
                self:insertOneRedDot("ActivitiesDlg", "LimitedCheckBox", nil, "LimitedCheckBox")

                -- 标记当前时间段已经加过小红点，不用再进行添加
                self.activeHasAddRedDot[activity.name][curTimeIndex] = true
            end
        else
            if activity["actitiveDate"] == "9" then
                -- 悬赏活动每过一个小时都会再开启一次，所以当前时间段的悬赏活动结束时，应移除标记，下一次才可以重新添加小红点
                self.activeHasAddRedDot[activity.name][curTimeIndex] = false
            end
        end
    end

    if not hasActivity then
        -- 没有限时活动，尝试移除限时活动小红点
        self:removeOneRedDot("ActivitiesDlg", "LimitedCheckBox", nil, "LimitedCheckBox")
    end

    -- 每天5点重置提醒
    local curTime = gf:getServerDate("%H:%M", gf:getServerTime())
    if curTime == ACTIVE_RESET_TIME then
        self.activeHasAddRedDot = {}
    end
end

-- 每天第一次登入，主界面福利按钮小红点，只可在登入时调用，其他时间不行
function RedDotMgr:firstLoginForWelfareDlgRedDot()

    if not GameMgr.isFirstLoginToday then return end

    local giftData = GiftMgr:getWelfareData()

    -- 如果再续前缘开启，每天第一次登入需要小红点
    DlgMgr:sendMsg("SystemFunctionDlg", "addRedDoForZaixqyFirstLogin")


    -- 月首冲添加小红点
    local canAddRedDot = 0
    local chargeGift = GiftMgr["month_charge_gift"] or {}
    if chargeGift.amount == 0 and GameMgr.isFirstLoginToday then
        -- 未充值，每周首次登录要显示小红点
        local lastLoginTime = cc.UserDefault:getInstance():getIntegerForKey("lastRedDotForMonthCharge" .. Me:queryBasic("gid")) or 0
        local time = tonumber(lastLoginTime) or 0
        local curMondayZeroTime = gf:getServerCurMonDayZeroTime()

        if time > curMondayZeroTime then
            -- 本周已经提示过了
            canAddRedDot = 1 -- 0 都不显示小红点， 1 活动界面显示福利界面不显示， 2 都显示
        else
            canAddRedDot = 2
            cc.UserDefault:getInstance():setIntegerForKey("lastRedDotForMonthCharge" .. Me:queryBasic("gid"), gf:getServerTime())
        end
    elseif chargeGift.amount == 1 and GameMgr.isFirstLoginToday then
        -- 已充值，每天首次登录要显示小红点
        canAddRedDot = 2
    else
        -- 已领取或非当天首次登录
        canAddRedDot = 0
    end

    if canAddRedDot > 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton16")
    end

    if canAddRedDot > 0 then
        -- 活动时间内，未领取过奖励，当天首次登录，活动福利显示小红点
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "WelfareCheckBox")
        RedDotMgr:insertOneRedDot("ActivitiesDlg", "WelfareCheckBox", nil, "WelfareCheckBox")
    end


    if giftData and giftData.rename_discount_time == 1 then
        -- rename_discount_time == 0不显示，1显示，2已购买
        -- 五折卡存在并且未购买，给予小红点
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton18")
    end

    -- 新充值好礼活动
    if Me:queryBasicInt("lottery_times") > 0 then   -- 充值好礼
        -- 每日首次登录才添加小红点
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        RedDotMgr:insertOneRedDot("WelfareDlg", "WelfareButton5")
    end
end

-- 更新升级小红点信息
function RedDotMgr:updateLevelUp(level)
    -- Log:D(">>>> update Levelup Red Dot")
    self:updateCallGuard(level)
end

-- 更新守护召唤小红点信息
function RedDotMgr:updateCallGuard(level)
    -- Log:D(">>>> update Guard Red Dot")
    if GuardMgr:hasNewGuard(level) then
        self:insertOneRedDot("GameFunctionDlg", "GuardButton")
        self:insertOneRedDot("GuardTabDlg", "GuardCallDlgCheckBox")
    end
end


function RedDotMgr:isNeedInsertOnlineMallDlgRedDot()
    local userDefault = cc.UserDefault:getInstance()
    local redDotStr = userDefault:getStringForKey("insertOnlineRedDot", "")
    local redDotStrList = gf:split(redDotStr, "|")
    local gid = gf:getShowId(Me:queryBasic("gid"))

    local timestr = ""
    for i = 1, #redDotStrList do
        local list = gf:split(redDotStrList[i],",")
        if gid == list[1] then
            timestr = list[2]
            break
        end
    end


    if timestr == "" then
        return true
    else
        local time = tonumber(timestr) or 0
        local curTimeList = gf:getServerDate("*t", gf:getServerTime())
        local curMondayZeroTime = gf:getServerCurMonDayZeroTime()
        if curTimeList["wday"] == 2 and curTimeList["hour"] < 5 then -- 今天是周一并且五点前
            curMondayZeroTime = curMondayZeroTime - 7 * 24 * 60* 60
        end

        if time > curMondayZeroTime then -- 本周已经提示过了
            return false
        else
            return true
        end
    end
end

function RedDotMgr:insertOneRedDotStr()
    local userDefault = cc.UserDefault:getInstance()
    local redDotStr = userDefault:getStringForKey("insertOnlineRedDot", "")
    local redDotStrList = gf:split(redDotStr, "|")
    local gid = gf:getShowId(Me:queryBasic("gid"))

    local strList = ""
    for i = 1, #redDotStrList do
        local list = gf:split(redDotStrList[i],",")
        if list[1] ~= "" and gid ~= list[1] then
            list = list[1] .. "," .. gf:getServerTime()
            strList = strList .. "|" .. list
        end
    end

    local list = gid .. "," .. gf:getServerTime()
    strList = strList .. "|" .. list

    userDefault:setStringForKey("insertOnlineRedDot", strList)
end

-- 更新邮箱小红点信息
function RedDotMgr:updateMailRedDot(data)
    -- 获取title
    local idStr = data.title
    if nil == idStr then
        return
    end

    if idStr == "59|60" and data.attachment ~= "remove" and not gf:isWindows() then
        -- 微社区按钮增加红点时，需要预加载界面，在界面加载完成后，再显示红点
        local dlg = DlgMgr:getDlgByName("CommunityDlg")
        local preLoadType = CommunityMgr:getPreLoadCommunityType()
        if not dlg and (not preLoadType or preLoadType == PRELOAD_COMMUNITY_TYPE.NONE) then
            -- 界面没有打开，预加载
            CommunityMgr:setPreLoadCommunityType(PRELOAD_COMMUNITY_TYPE.RED_POINT)
            CommunityMgr:setPreLoadRedDotData(data)
            CommunityMgr:askForOpenCommunityDlg()
            return
        end
    end

    -- 商品标签，小红一周提示一次
    if idStr == "6|21" then
        if not self:isNeedInsertOnlineMallDlgRedDot() then
            return
        else
            self:insertOneRedDotStr()
        end
    end

    local idList = gf:split(idStr, "|")

    for i = 1, #idList do
        local id = tonumber(idList[i])
        if nil ~= redDot[id] then
            if data.attachment == "remove" then
                -- 移除小红点
                self:removeOneRedDot(redDot[id][1], redDot[id][2], redDot[id][6], data.msg ~= "" and data.msg or nil)
            else
                if 4 == id then
                    -- 如果存在活跃值小红点
                    self:insertOneRedDot("active", "active", nil, "active")
                    self:insertOneRedDot(redDot[id][1], redDot[id][2], nil, "active")
                elseif id == 51 or id == 53 then
                    -- 个人空间有两套界面，所以只能把小红点保存起来等打开界面时再特殊处理
                    BlogMgr:setHasMailRedDotForBlog(id, data.msg)
                else

                    self:insertOneRedDot(redDot[id][1], redDot[id][2], redDot[id][6], data.msg ~= "" and data.msg or nil)
                end
            end
        end
    end
end

function RedDotMgr:removeChatRedDot(gid)
    if FriendMgr:hasFriend(gid) then
        -- 好友，尝试移除好友红点
        RedDotMgr:removeFriendRedDot(gid)
    end

    if FriendMgr:isTempByGid(gid) then
        -- 最近联系人，尝试移除最近联系人红点
        RedDotMgr:removeTempFriendRedDot(gid)
    end
end

-- 好友中某个好友是否要显示小红点
function RedDotMgr:friendHasRedDot(gid)
    return RedDotMgr:hasRedDotInfoByDlgName("FriendChat", gid)
end

-- 移除好友的小红点提示
function RedDotMgr:removeFriendRedDot(gid)
    self:removeOneRedDot("FriendChat", gid)
    -- 移除小红点后更新好友列表
    local friend = FriendMgr:getFriendByGid(gid)
    if friend then
        -- 刷新好友条目排序
        FriendMgr:setFriendLastChatTime(friend:queryBasic("gid"), nil)
    else
        return
    end

    local dlg = DlgMgr:getDlgByName("FriendDlg")
    if dlg then
        -- 获取好友列表
        local name = friend:queryBasic("char")
        local group = friend:queryBasic("group")
        local groupListName = (group or "") .. "listView"
        local friendList = dlg[groupListName]
        local hasRedDot = false
        for curGid, v in pairs(friendList) do
            if self:hasRedDotInfo("FriendChat", curGid) then
                hasRedDot = true
            end

            if curGid == gid then
                local portaitImg = Dialog.getControl(v.root, "PortraitImage", nil, v.root)
                gf:removeCtrlRedDot(portaitImg, true)
            end
        end
    end
end

-- 最近联系人中某个好友是否要显示小红点
function RedDotMgr:tempFriendHasRedDot(gid)
    return RedDotMgr:hasRedDotInfoByDlgName("tempFriendChat", gid)
end

-- 移除最近联系人中某个好友的小红点
function RedDotMgr:removeTempFriendRedDot(gid)
    self:removeOneRedDot("tempFriendChat", gid)
    -- 移除小红点后更新好友列表
    local temFriend = FriendMgr:getTemFriendByGid(gid)
    if temFriend then
        -- 刷新好友条目排序
        FriendMgr:setFriendLastChatTime(temFriend:queryBasic("gid"), nil)
    else
        return
    end

    local dlg = DlgMgr:getDlgByName("FriendDlg")
    if dlg then
        -- 获取好友列表
        local name = temFriend:queryBasic("char")
        local friendList = dlg["TempListView"]
        for curGid, v in pairs(friendList) do
            if curGid == gid then
                local portaitImg = Dialog.getControl(v.root, "PortraitImage", nil, v.root)
                    gf:removeCtrlRedDot(portaitImg, true)
                end
            end
        end

    -- 没有最近联系人小红点了移除临时标签小红点
    if not RedDotMgr:hasRedDotInfoByOnlyDlgName("tempFriendChat") then
        self:removeOneRedDot("FriendDlg", "TempCheckBox")
        self:removeOneRedDot("FriendDlg", "TempReturnButton")
    end
end

-- 好友验证中某个好友是否要显示小红点
function RedDotMgr:friendVerifyHasRedDot(id)
    return RedDotMgr:hasRedDotInfo("FriendVerify", id)
end

-- 移除好友验证的消息
function RedDotMgr:removeFriendVerifyRedDot(id)
    self:removeOneRedDot("FriendVerify", id)
end

-- 是否存在某条小红点信息
function RedDotMgr:hasRedDotInfo(dlgName, ctrlName)
    if not redDotList[dlgName] then
        return false
    end

    for k, v in pairs(redDotList[dlgName]) do
            if v == ctrlName then
                return true
            end
        end

    return false
end

function RedDotMgr:hasRedDotInfoByDlgName(dlgName, ctrlName)
    for value, key in pairs(redDotList) do
        for k, v in pairs(key) do
        if v == ctrlName and value == dlgName then
                return true
            end
        end
    end

    return false
end

function RedDotMgr:oneRedDotHasBlink(dlgName, ctrlName)
    if blinkRedDotList[dlgName] and blinkRedDotList[dlgName][ctrlName] then
        return true
    end
end

function RedDotMgr:hasRedDotInfoByOnlyDlgName(dlgName)
    if not redDotList or not redDotList[dlgName] then return false end
    if next(redDotList[dlgName]) then
        return true
    end

    return false
end

function RedDotMgr:isCanAddRedDot(dlgName, ctrlName)
    if self:notLoadRedDotFromFile() then
        if dlgName == "SystemFunctionDlg" and ctrlName ~= "PromoteButton" then
            -- SystemFunctionDlg 的按钮(除提升外)不能加入小红点
            return false
        end

        if dlgName == "GameFunctionDlg" and ctrlName ~= "BagButton" then
            -- GameFunctionDlg 中按钮(除背包外)不能加入小红点
            return false
        end

        if dlgName == "FriendDlg" and (ctrlName == "BlogDlgButton" or ctrlName == "CityDlgButton") then
            -- 好友界面个人空间不显示小红点
            return false
        end
    end

    return true
end

-- 设置小红点缩放比例
function RedDotMgr:setRedDotScale(dlg, ctrlName, parentCtrl, sc)
    local ctrl = dlg:getControl(ctrlName, nil, parentCtrl)
    gf:setRedDotScale(ctrl, sc)
end


-- 插入一条小红点信息
-- 如果游戏在后台不允许操作ui相关的操作，这样贴图会创建不成功，导致进前台时候，被创建过的贴图不显示了
-- 加小红点的原因，
-- isBlink 为true则需要闪烁
function RedDotMgr:insertOneRedDot(dlgName, ctrlName, root, reason, isBlink)

    if not self:isCanAddRedDot(dlgName, ctrlName) then
        return
    end

    if blinkRedDotList[dlgName] and blinkRedDotList[dlgName][ctrlName] then
        isBlink = true
    end

    local canAdd = true
    if DlgMgr:isDlgOpened(dlgName) then
        -- 已经打开了，添加小红点
        local dlg = DlgMgr:getDlgByName(dlgName)
        if nil ~= dlg then
            canAdd = DlgMgr:sendMsg(dlgName, "onCheckAddRedDot", ctrlName)
            canAdd = (nil == canAdd and true or canAdd) and (not (dlg:isTabDlg() and dlg:getCurSelectCtrlName() == ctrlName))
            if canAdd and not GameMgr:isInBackground() then
                dlg:addRedDot(ctrlName, root, isBlink)
            end
        end
    end

    if canAdd then
        if nil == redDotList[dlgName] then
            redDotList[dlgName] = {}
        end

        if nil == blinkRedDotList[dlgName] then
            blinkRedDotList[dlgName] = {}
        end

        if reason then
        -- 小红点原因标记
            if not redDotListReason[dlgName] then redDotListReason[dlgName] = {} end
            if not redDotListReason[dlgName][ctrlName] then redDotListReason[dlgName][ctrlName] = {} end

            redDotListReason[dlgName][ctrlName][reason] = 1
        end

        redDotList[dlgName][ctrlName] = ctrlName
        blinkRedDotList[dlgName][ctrlName] = isBlink
    end

    if dlgName == "GameFunctionDlg" and
          (ctrlName ~= "StatusButton1" and ctrlName ~= "StatusButton2" and ctrlName ~= "StatusButton3") and
          not GameMgr:isInBackground() then
        self:updateGFDShowBtnRedDot()
    end

    if dlgName == "SystemFunctionDlg" and ctrlName ~= "StatusButton1" and not GameMgr:isInBackground() then
        self:updateSFDShowBtnRedDot()
    end
end


-- 删除一条小红点信息
function RedDotMgr:removeOneRedDot(dlgName, ctrlName, root, reason)

    if reason then
        -- 如果预删除的小红点有起因， redDotListReason中，有该起因的小红点是否存在，不存在，则return
        if not redDotListReason[dlgName] or not redDotListReason[dlgName][ctrlName] or not redDotListReason[dlgName][ctrlName][reason] then
            return
        end

        redDotListReason[dlgName][ctrlName][reason] = nil

        -- 如果当前小红点除此原因之外还有其他原因，则不移除此小红点
        local redDotReason = redDotListReason[dlgName][ctrlName]
        for k, v in pairs(redDotReason) do
            if v then
                return
            end
        end
    end

    if DlgMgr:isDlgOpened(dlgName) then
        local dlg = DlgMgr:getDlgByName(dlgName)

        local ctrl = Dialog.getControl(dlg, ctrlName, nil, root)
        if ctrl then
            ctrl.hasRedDot = false
        end
        gf:removeCtrlRedDot(ctrl, true)

        if redDotListReason[dlgName] and redDotListReason[dlgName][ctrlName] then
            -- 按钮上的小红点已删除，直接清空原因
            redDotListReason[dlgName][ctrlName] = {}
        end
    end

    if redDotList[dlgName] then
        for k, _ in pairs(redDotList[dlgName]) do
            if redDotList[dlgName][k] == ctrlName then
                redDotList[dlgName][k] = nil

                if blinkRedDotList[dlgName] and blinkRedDotList[dlgName][k] then
                    blinkRedDotList[dlgName][k] = nil
                end
                -- Log:D(">>>>>>>>>>> remove One Red Dot : " .. dlgName .. ", " .. ctrlName)
            end
        end
    end

    for i = 1, #redDot do
        if dlgName == redDot[i][3] then
            -- 找到关联的按钮，清除小红点
            if redDot[i][1] ~= redDot[i][3] then
                if DlgMgr:isDlgOpened(redDot[i][1]) then
                    local dlg = DlgMgr:getDlgByName(redDot[i][1])
                    if nil ~= dlg then
                        if reason then
                            -- 关联的对话框是否有小红点起因
                            local rexDlgName = redDot[i][1]
                            local rexCtrl = redDot[i][2]
                            if not redDotListReason[rexDlgName] or not redDotListReason[rexDlgName][rexCtrl] or not redDotListReason[rexDlgName][rexCtrl][reason] then
                                return
                            end

                            redDotListReason[rexDlgName][rexCtrl][reason] = nil
                            if not next(redDotListReason[rexDlgName][rexCtrl]) then
                                dlg:removeRedDot(redDot[i][2])
                            end
                        else
                            dlg:removeRedDot(redDot[i][2])
                        end
                    end
                end
            end
        end
    end

    -- 如果是主界面活动界面图标，顺便清除活跃值小红点
    if dlgName == "SystemFunctionDlg" and ctrlName == "ActivityButton" then
        redDotList["active"] = nil
        if redDotListReason["active"] and redDotListReason["active"]["active"] then
            redDotListReason["active"]["active"] = {}
        end
    end

    -- self:checkGFDRedDot()
    if dlgName == "GameFunctionDlg" and
        (ctrlName ~= "StatusButton1" and ctrlName ~= "StatusButton2" and ctrlName ~= "StatusButton3") and
        not GameMgr:isInBackground() then
        self:updateGFDShowBtnRedDot()
    end

    if dlgName == "SystemFunctionDlg" and ctrlName ~= "StatusButton1" and not GameMgr:isInBackground() then
        self:updateSFDShowBtnRedDot()
    end
end

-- 清除关联窗口的小红点
function RedDotMgr:removeRelativeDlg(dlgName)
    for i = 1, #redDot do
        if dlgName == redDot[i][3] then
            -- 找到关联的按钮，清除小红点
            if redDot[i][1] ~= redDot[i][3] then
                if DlgMgr:isDlgOpened(redDot[i][1]) then
                    local dlg = DlgMgr:getDlgByName(redDot[i][1])
                    if nil ~= dlg then
                        dlg:removeRedDot(redDot[i][2])
                    end
                end
            end
        end
    end
end

-- 删除一个窗口的小红点信息
function RedDotMgr:removeDlgRedDot(dlgName)
    redDotList[dlgName] = nil
    blinkRedDotList[dlgName] = nil
end

function RedDotMgr:removeCtrRedDotData(dlgName, ctrlName)
    if redDotList[dlgName] then
        redDotList[dlgName][ctrlName] = nil
    end

    if blinkRedDotList[dlgName] then
        blinkRedDotList[dlgName][ctrlName] = nil
    end
end

-- 获取小红点列表，返回控件数组
function RedDotMgr:getRedDotList(dlgName)
    if nil == redDotList[dlgName] then
        return {}
    end

    return redDotList[dlgName]
end

function RedDotMgr:getBlinkRedDotList(dlgName)
    if not blinkRedDotList[dlgName] then
        return {}
    end

    return blinkRedDotList[dlgName]
end

function RedDotMgr:MSG_UPGRADE_LEVEL_UP(data)
    -- 若是Me升级则播放升级特效
    if data.id ~= nil then
        local levelUpChar = CharMgr:getChar(data.id)
        if levelUpChar then
            levelUpChar:addMagicOnFoot(ResMgr.magic.level_up, false)
        end
    end

    --  播放升级声音
    if data.id ==  Me:getId() then
        SoundMgr:playEffect("level_up")
    end
end

function RedDotMgr:MSG_LEVEL_UP(data)
    local meLevel = Me:getLevel()

    -- WDSY-3603去除守护小红点
 --   self:updateLevelUp(data.level)

    -- 若是Me升级则播放升级特效
    if data.id ~= nil then
        local levelUpChar = CharMgr:getChar(data.id)
        if levelUpChar then
            levelUpChar:addMagicOnFoot(ResMgr.magic.level_up, false)
        end
    end

    --  播放升级声音
    if data.id ==  Me:getId() then
        SoundMgr:playEffect("level_up")
        DistMgr:refreshHaveRoleLevel(GameMgr:getDistName(), data.level)
    end

    self:checkShuilanzyRedDot(data.level)
end
-- 设置更新公告活动小红点
function RedDotMgr:setUpdateActiveRedDot()
    if NoticeMgr:getIsNeddShowActivityRedDot() then
        local title = "30|31|32"
        self:updateMailRedDot({title = title})
        NoticeMgr:setIsNeddShowActivityRedDot(false)
    end
end

-- 设置每日签到小红点
function RedDotMgr:MSG_OPEN_WELFARE(data)
    local activeVIPInfo = GiftMgr:getActiveVIPInfo()
    if not activeVIPInfo then
        -- 如果没有活跃送会员信息，先请求一下
        gf:CmdToServer("CMD_GET_ACTIVE_BONUS_INFO")
    end

    if not GiftMgr:getConsumePointInfo() then
        -- 如果没有消费分相关信息，先请求一下消费积分相关信息
        GiftMgr:requestConsumePointInfo()
    end

    if not GiftMgr:getChargePointInfo() then
        -- 如果没有充值积分相关信息，先请求一下充值积分相关信息
        GiftMgr:requestChargePointInfo()
    end

    if DlgMgr:isDlgOpened("WelfareDlg") then
        return
    end

    local uiLayer = gf:getUILayer()
    if self.checkGiftBtnRedDotAction then
        uiLayer:stopAction(self.checkGiftBtnRedDotAction)
        self.checkGiftBtnRedDotAction = nil
    end

    self.checkGiftBtnRedDotAction = performWithDelay(uiLayer, function()
        self:checkGiftsBtnRedDot(data)
        self.checkGiftBtnRedDotAction = nil
    end, 0.1)
end

-- 检查主界面福利按钮红点
function RedDotMgr:checkGiftsBtnRedDot(data)
    if data["isShowHuiGui"] > 0 and
            (data["canGetZXQYSevenLogin"] > 0 or data["canGetZXQYHuoYue"] > 0) then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data.isCanSign == 1 or data.isCanGetNewPalyerGift == 1 or data.cumulativeReward == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data.times > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["firstChargeState"] == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["loginGiftState"] == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["activeCount"] > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["holidayCount"] > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["summerSF2017"] > 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if Me:queryBasicInt("lock_exp") == 0 and data["zaohua"] >= 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if Me:queryBasicInt("lock_exp") == 0 and data["xundcf"] >= 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["welcomeDrawStatue"] == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 活跃登录礼包
    if data["activeLoginStatue"] == 1 and Me:getLevel() >= GiftMgr:getActiveLoginGiftLimitLevel() then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 合服登录礼包
    if data["mergeLoginStatus"] == 1 and Me:getLevel() >= GiftMgr:getMergerLoginGiftLimitLevel() then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 合服促活跃
    if data["mergeLoginActiveStatus"] == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 经验仓库
    if data["expStoreStatus"] > 0
        and Me:queryBasicInt("exp_ware_data/exp_ware") > 0
        and Me:queryBasicInt("exp_ware_data/today_fetch_times") == 0
        and not Me:isLockExp() then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["isShowXYFL"] > 0  then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
		return
    end
    -- 回归累充
    if data["reentryAsktaoRecharge"] == 1 or
        (GameMgr.isFirstLoginToday and data["reentryAsktaoRecharge"] == 0) then
        -- 可以领奖，或者首次登陆活动是开启状态时
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 充值积分（活动期间首次登录/活动结束，但仍处于兑换时间，玩家当前积分>=7）
    if (GiftMgr:isInRechargeScore() and
       GiftMgr:isCanAddRedDot("WelfareButton13") and
       GameMgr.isFirstLoginToday) or
       (GiftMgr:isInRechargeScoreDeadline() and
       GiftMgr:getRechargeScore() >= GiftMgr:getMinPointInRechargeScoreDeadline())  then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 消费积分（活动期间首次登录/活动结束，但仍处于兑换时间，玩家当前积分>=7）
    if (GiftMgr:isInConsumeScore() and
        GiftMgr:isCanAddRedDot("WelfareButton20") and
        GameMgr.isFirstLoginToday) or
        (GiftMgr:isInConsumeScoreDeadline() and
        GiftMgr:getConsumeScore() >= GiftMgr:getMinPointInConsumeScoreDeadline())  then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 活跃送会员小红点（若已经领取过奖励则不显示红点）
    if (activeVIPInfo and activeVIPInfo.show_reddot and activeVIPInfo.show_reddot >= 1
          and activeVIPInfo.fetch_state and activeVIPInfo.fetch_state ~= 2
          and GiftMgr:isCanAddRedDot("WelfareButton15") and GameMgr.isFirstLoginToday) or
          (activeVIPInfo and activeVIPInfo.fetch_state and activeVIPInfo.fetch_state == 1) then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    local time = data.leftTime
    if time > 0 then
        local delay = cc.DelayTime:create(time)
        local func = cc.CallFunc:create(function()
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
            self.onlineGiftDelay = nil
        end)

        if self.onlineGiftDelay then
            gf:getUILayer():stopAction(self.onlineGiftDelay)
    end

        self.onlineGiftDelay = gf:getUILayer():runAction(cc.Sequence:create(delay, func))
    end
end

function RedDotMgr:MSG_FESTIVAL_LOTTERY(data)
    if DlgMgr:isDlgOpened("WelfareDlg") then
        return
    end

    if not data then return end

    if data["singles_day_2016"] and data["singles_day_2016"].amount > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if data["winter_day_2017"] and data["winter_day_2017"].amount > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    if Me:queryInt("level") >= 30 and data["spring_day_2017"] and data["spring_day_2017"].amount > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
        return
    end

    -- 月首充可领取，或首次充值成功后
    if GiftMgr["month_charge_gift"] and GiftMgr["month_charge_gift"].amount == 1 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
    end
end

-- 抽奖次数从背包物品获取时，可在这判断福利按钮是否添加小红点
function RedDotMgr:MSG_INVENTORY(data)
    local welfareData = GiftMgr:getWelfareData()
    if not welfareData or not welfareData["lottery"] then return end

    if welfareData["lottery"]["singles_day_2016"] then
        if InventoryMgr:getAmountByName(CHS[4300132]) > 0 then
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
            return
        end
    end

    if welfareData["lottery"]["winter_day_2017"] then
        if InventoryMgr:getAmountByName(CHS[5410008]) > 0 then
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", "GiftsButton")
            return
        end
    end
end

-- 给装备列表添加小红点
function RedDotMgr:insertEquipment(dlgName, equipType)
    RedDotMgr:insertOneRedDot(dlgName, equipType)
end

-- 移除小红点
function RedDotMgr:removeEquipment(dlgName, equipType)
    RedDotMgr:removeOneRedDot(dlgName, equipType)
end

-- 检测系统功能中展开按钮是否需要显示小红点(GameFunctionDlg)
function RedDotMgr:checkGFDRedDot()
    -- 为展开按钮添加小红点的各原因
    local needShowRedDotReasons = {}

    for _, v in pairs(gameFunctionRedDotList) do
        if self:hasRedDotInfo("GameFunctionDlg", v) then
            -- 如果是当前状态时隐藏状态
            local curStateNoShowRedDot
            if GFD_STATUS1_BTN[v] then
                curStateNoShowRedDot = 1
            elseif GFD_STATUS2_BTN[v] then
                curStateNoShowRedDot = 2
            end

            if DlgMgr.dlgs["GameFunctionDlg"] and curStateNoShowRedDot and
                  DlgMgr.dlgs["GameFunctionDlg"].curButtonState ~= curStateNoShowRedDot then
                for iconId, iconData in pairs(GuideMgr.iconList) do
                    -- 判断当前按钮的功能是否开启
                    if v == iconData.ctrlName and GuideMgr:isIconExist(iconId) then
                        table.insert(needShowRedDotReasons, v)
                    end
                end
            end
        end
    end

    return needShowRedDotReasons
end

-- 展开按钮添加小红点
function RedDotMgr:updateGFDShowBtnRedDot()
    local gfdRedDotReasons = self:checkGFDRedDot()

    for i = 1, #gameFunctionRedDotList do
        local isReasonInsertRedDot = false

        for j = 1, #gfdRedDotReasons do
            if gfdRedDotReasons[j] == gameFunctionRedDotList[i] then
                isReasonInsertRedDot = true
            end
        end

        -- 当前原因是否是要添加小红点;如果不是，还要移除对应原因的小红点
        if isReasonInsertRedDot then
            if GFD_STATUS1_BTN[gameFunctionRedDotList[i]] then
                self:insertOneRedDot("GameFunctionDlg", "StatusButton1", nil, gameFunctionRedDotList[i])
                self:insertOneRedDot("GameFunctionDlg", "StatusButton3", nil, gameFunctionRedDotList[i])

            elseif GFD_STATUS2_BTN[gameFunctionRedDotList[i]] then
                self:insertOneRedDot("GameFunctionDlg", "StatusButton1", nil, gameFunctionRedDotList[i])
                self:insertOneRedDot("GameFunctionDlg", "StatusButton2", nil, gameFunctionRedDotList[i])
            end
        else
            if GFD_STATUS1_BTN[gameFunctionRedDotList[i]] then
                self:removeOneRedDot("GameFunctionDlg", "StatusButton1", nil, gameFunctionRedDotList[i])
                self:removeOneRedDot("GameFunctionDlg", "StatusButton3", nil, gameFunctionRedDotList[i])
            elseif GFD_STATUS2_BTN[gameFunctionRedDotList[i]] then
                self:removeOneRedDot("GameFunctionDlg", "StatusButton1", nil, gameFunctionRedDotList[i])
                self:removeOneRedDot("GameFunctionDlg", "StatusButton2", nil, gameFunctionRedDotList[i])
            end
        end
    end
end

-- 检测 SystemFunctionDlg 中展开按钮是否需要显示小红点
function RedDotMgr:checkSFDRedDot()
    -- 为展开按钮添加小红点的各原因
    local needShowRedDotReasons = {}

    for i = 1, #SFD_STATUS_BTN do
        local v = SFD_STATUS_BTN[i]
        local showCtrlName = v
        if v == "TradeButton" then
            -- 该按钮的小红点在其子按钮 ShowTradeButton 上
            showCtrlName = "ShowTradeButton"
        end

        if self:hasRedDotInfo("SystemFunctionDlg", showCtrlName) then
            if DlgMgr.dlgs["SystemFunctionDlg"] then
                for iconId, iconData in pairs(GuideMgr.iconList) do
                    -- 判断当前按钮的功能是否开启
                    if v == iconData.ctrlName and GuideMgr:isIconExist(iconId) then
                        needShowRedDotReasons[v] = true
                        break
                    end
                end
            end
        end
    end

    return needShowRedDotReasons
end

-- 展开按钮添加小红点
function RedDotMgr:updateSFDShowBtnRedDot()
    local sfdRedDotReasons = self:checkSFDRedDot()
    local buttonList = SFD_STATUS_BTN
    for i = 1, #buttonList do
        local ctrlName = buttonList[i]

        -- 当前原因是否是要添加小红点;如果不是，还要移除对应原因的小红点
        if sfdRedDotReasons[ctrlName] then
            self:insertOneRedDot("SystemFunctionDlg", "StatusButton1", nil, ctrlName)
        else
            self:removeOneRedDot("SystemFunctionDlg", "StatusButton1", nil, ctrlName)
        end
    end
end

-- 检查需不需要加的小红点
-- 暂时只检查 SystemFunctionDlg 界面，有其他需求，请自行添加
function RedDotMgr:checkAddRedDot()
    if not redDotList then redDotList = {} end

    local systemFunctionDlgDot = redDotList["SystemFunctionDlg"]
    if systemFunctionDlgDot then
        for k, v in pairs(systemFunctionDlgDot) do
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", k)
        end
    end
end

-- 检查是否需要显示刷道的小红点
function RedDotMgr:checkShuaDaoRedDotForFirstLogin()
    -- 刷道界面小红点检测
    if GameMgr.isFirstLoginToday and GetTaoMgr:checkOfflineIsOn() and GetTaoMgr:chechRedDot() then
        RedDotMgr:addShuaDaoRedDot()
    end
end

-- 检查是否需要显示刷道的小红点
function RedDotMgr:addShuaDaoRedDot()

    -- 需要添加小红点
    local data = {}
    data.id = 0
    data.type = SystemMessageMgr.SYSMSG_TYPE.RED_DOT
    data.sender = Me:queryBasic("gid")
    data.title = "2|3"
    data.msg = ""
    data.attachment = ""
    data.create_time = gf:getServerTime()
    data.expired_time = gf:getServerTime()
    data.status = SystemMessageMgr.SYSMSG_STATUS.UNREAD
    self:updateMailRedDot(data)
end

function RedDotMgr:MSG_SHUADAO_REFRESH(data)
--	WDSY-26715 修改为只要当天首次登入刷新
end

function RedDotMgr:MSG_ACTIVITY_DATA_LIST(data)
    if data.activityList["realname_gift"] then
        -- for 活动-福利按钮-实名认证小红点
        if self.isOnce == nil then self.isOnce = true end -- 第一次收到消息才要小红点判断,初始化为true
        if self.isOnce then
            local isNewDay = false
            local lastLoginTime = cc.UserDefault:getInstance():getIntegerForKey("lastRedDotForHuodongfuli" .. Me:queryBasic("gid")) or 0
            if not gf:isSameDay5(lastLoginTime, gf:getServerTime()) then
                isNewDay = true
                cc.UserDefault:getInstance():setIntegerForKey("lastRedDotForHuodongfuli" .. Me:queryBasic("gid"), gf:getServerTime())
            end

            local welfareAct = ActivityMgr:getWelfareActivity()
            local condition1 = (#welfareAct == 1 and welfareAct[1].name == CHS[4300244])

            -- condition1 判断是否只有一个福利A并且福利A是 实名认证礼包
            if condition1 and isNewDay then
                local condition2 = (data and data.activityList["realname_gift"] and tonumber(data.activityList["realname_gift"].para) >= 1)
                -- condition2 实名认证已经领取过
                if condition2 then
                    -- 如果领取过，不给小红点
                else
                    -- 未领取要给小红点
                    RedDotMgr:insertOneRedDot("SystemFunctionDlg", "ActivityButton", nil, "WelfareCheckBox")
                    RedDotMgr:insertOneRedDot("ActivitiesDlg", "WelfareCheckBox", nil, "WelfareCheckBox")
                end
        end
        end
        self.isOnce = false
    end
end

RedDotMgr:init()
MessageMgr:hook("MSG_ACTIVITY_DATA_LIST", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_UPGRADE_LEVEL_UP", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_LEVEL_UP", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_OPEN_WELFARE", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_FESTIVAL_LOTTERY", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_INVENTORY", RedDotMgr, "RedDotMgr")
MessageMgr:hook("MSG_SHUADAO_REFRESH", RedDotMgr, "RedDotMgr")

return RedDotMgr
