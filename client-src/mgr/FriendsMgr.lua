-- FriendsMgr.lua
-- Created by liuhb Feb/25/2015
-- 好友管理器

local DataObject = require("core/DataObject")
local SingleChatPanel = require("ctrl/SingleChatPanel")
local Bitset = require("core/Bitset")
local json = require('json')
FriendMgr = Singleton()

FriendMgr.objs = {}
FriendMgr.friendList = {}
FriendMgr.tempList = {}
FriendMgr.blackList = {}
FriendMgr.chatList = {}
FriendMgr.chatData = {}
FriendMgr.tempCharMsg = {}
FriendMgr.chatGroupsInfo = {}
FriendMgr.recentFriends = {}
FriendMgr.hasOneCallMe = {}
FriendMgr.kuafObjDist = {}
FriendMgr.cfg = nil

FriendMgr.kuafuInfoByGid = {}
FriendMgr.npcMsgIds = {}

local refreshFriend = {}

local ONLINE = 1
local OFF_LINE = 2
local CHAT_GROUP_MAX_MEMBER = 50
local MAX_GROUP = 6
local MAX_CHAT_GROUP = 5

local charMenuInfo = {}

local FRIEND_GROUP = 1
local TEMP_GROUP = 6
local BLACK_GROUP = 5
local SAVE_LIST_COUNT = 120
local SAVE_PATH = Const.WRITE_PATH .. "chatData/" -- "chatData/"

local lastSaveTime = 0

local FRIEDN_GROUP_ID =
{
    [1] = "friendGroup1",
    [2] = "friendGroup2",
    [3] = "friendGroup3",
    [4] = "friendGroup4",
    [7] = "friendGroup7",
    [8] = "friendGroup8",
}

-- 打开好友系统对话框
function FriendMgr:openFriendDlg(noOpenAction)

    -- 不管其他，更新下邮箱再说（策划需求不要自动删除）
   --[[ if not FriendMgr.sysMsgScheduleId then
        FriendMgr.sysMsgScheduleId = gf:Schedule(function() SystemMessageMgr:updateAllMessage() end, 2)
    end]]

    local dlg = DlgMgr:openDlg("FriendDlg")
    dlg:show(noOpenAction)

    DlgMgr:reorderDlgByName("FriendDlg")

    dlg.isClose = false

    local idx;
    if nil == self.curVisibleDlg then
        idx = 1;
    else
        idx = self.curVisibleDlg
    end

    self.friendDlg = dlg
    FriendMgr:exchangeFriendDlg(idx)

    return dlg
end

-- upWithDlg,如果有该参数，则设置交流对话框为upWithDlg的zOrder之上
function FriendMgr:communicat(userName, gid, icon, level, canSpeakWithMe, distName)
    if not canSpeakWithMe and Me:queryBasic("gid") == gid then
        gf:ShowSmallTips(CHS[4100148])
        return
    end

    if not FriendMgr:isBlackByGId(gid) then

        local function openDlg()
        --  把频道界面设置屏幕外
        local channelDlg = DlgMgr:getDlgByName("ChannelDlg")
        if channelDlg then
            channelDlg:moveToWinOutAtOnce()
        end

        local dlg = FriendMgr:openFriendDlg(true)
        dlg:setChatInfo({name = userName, gid = gid, icon = icon, level = level})

        RedDotMgr:removeChatRedDot(gid)
        end

        if GameMgr:IsCrossDist() then
            -- 处于跨服，走原来逻辑
            openDlg()
    else
            if distName and distName ~= "" and distName ~= GameMgr:getDistName() then
                -- 如果区组不一样，则是跨服
                gf:CmdToServer("CMD_LBS_ADD_FRIEND_TO_TEMP", {user_gid = gid})
                FriendMgr.kuafuInfoByGid[gid] = {name = userName, icon = icon, level = level}
            else
                openDlg()
            end
        end


    else
        gf:ShowSmallTips(CHS[5000075])
    end
end

function FriendMgr:exchangeFriendDlg(idx)
    if nil == self.friendDlg then return end

    self.friendDlg:exchangeWinVisible(idx)
    self.curVisibleDlg = idx

    -- 如果是聊天界面,进行存储当前聊天对象
    if 8 == idx then
        self.chatObj = {}
        self.chatObj.chatName = self.friendDlg.chatName
        self.chatObj.chatGid = self.friendDlg.chatGid
        self.chatObj.chatIcon = self.friendDlg.chatIcon
    elseif 9 == idx then
        -- 切换到显示具体聊天内容时，检查是否需要通知服务器阅读临时npc信息
        self:checkNeedDoNpcMsgRead(self.friendDlg.chatGid)
    end
end

function FriendMgr:getCurFriendDlgIndex()
    return self.curVisibleDlg
end

-- 是否已收到MSG_CHAR_INFO
function FriendMgr:hasUpdateCharInfo(gid)
    return self.friendList[gid] and self.friendList[gid]:queryBasicInt("recv_charinfo_time") > 0
end

-- 是否已经存在这个好友
function FriendMgr:hasFriend(gid)
    if nil ~= self.friendList[gid] then
        return true
    end

    return false
end

-- 根据gid返回友好度
function FriendMgr:getFriendScore(gid)
    for k, v in pairs(self.friendList) do
        if v:queryBasic("gid") == gid then
            return v:queryInt("friend")
        end
    end
end

-- 获取黑名单的好友信息
function FriendMgr:getBlackByGid(gid)
    return self.blackList[gid]
end

function FriendMgr:isTempByGid(gid)
    if nil ~= self.tempList[gid] then
        return true
    end

    return false
end

-- 通过gid判断是否出于黑名单中
-- 是否存在于黑名单中
function FriendMgr:isBlackByGId(gid)
    if nil ~= self.blackList[gid] then
        return true
    end

    return false
end

-- 根据名字获取gid
function FriendMgr:getFriendByName(name)
    for k, v in pairs(self.friendList) do
        if name == v:queryBasic("char") then
            return v
        end
    end

    return nil
end

function FriendMgr:getObjsByGroup(group)
    if group == BLACK_GROUP then
        return self.blackList
    elseif group == TEMP_GROUP then
        return self.tempList
    else
        return self.friendList
    end
end

-- 按照组别获取好友信息
function FriendMgr:getFriendsByGroup(groupId)
    local friends = {}
    local objs = FriendMgr:getObjsByGroup(groupId)
    for _, v in pairs(objs) do
        local group = v:queryInt("group")
        -- 将好友筛选出来
        if groupId == group then
            local name = v:queryBasic("char")
            local icon = v:queryInt("icon")
            local faction = v:queryBasic("party/name")
            local level = v:queryInt("level")
            local isVip = v:queryInt("insider_level")
            local isOnline = v:queryInt("online")
            local friendShip = v:queryInt("friend")
            local gid = v:queryBasic("gid")
            local comeback_flag = v:queryInt("comeback_flag")
            if nil == faction or "" == faction or "N/A" == faction then
                faction = FriendMgr:getFriendsPartyByGid(gid)
            end
            local lastChatTime = v.lastChatTime or 0
            local hasRedDot = v.hasRedDot or 0

            table.insert(friends, {
                gid = gid,
                name = name,
                icon = icon,
                faction = faction,
                lev = level,
                isVip = isVip,
                isOnline = isOnline,
                friendShip = friendShip,
                lastChatTime = lastChatTime,
                hasRedDot = hasRedDot,
                comeback_flag = comeback_flag,
                group = group
                })
        end
    end

    return friends
end

-- 通过gid判断是否是npc
function FriendMgr:isNpcByGid(gid)
    if not string.isNilOrEmpty(gid) and string.match(gid, "npc_gid") then
        return true
    end

    return false
end

-- 将存储格式转换为使用的格式
function FriendMgr:convertToUserData(friend)
    if nil == friend then return end

    local group = friend:queryInt("group")
    local name = friend:queryBasic("char")
    local icon = friend:queryInt("icon")
    local faction = friend:queryBasic("party/name")
    local level = friend:queryInt("level")
    local isVip = friend:queryInt("insider_level")
    local isOnline = friend:queryInt("online")
    local friendShip = friend:queryInt("friend")
    local gid = friend:queryBasic("gid")
    local lastChatTime = friend.lastChatTime or 0
    local hasRedDot = friend.hasRedDot or 0
    local comeback_flag = friend:queryInt("comeback_flag")

    if nil == faction or "" == faction or "N/A" == faction then
        faction = FriendMgr:getFriendsPartyByGid(gid)
    end

    if FriendMgr:isNpcByGid(gid) then
        -- 现在好友可能是NPC，例如客栈（最近联系人），NPC默认一直在线
        isOnline = 1
        isVip = 0
    end

    local friend = {
        gid = gid,
        name = name,
        icon = icon,
        faction = faction,
        lev = level,
        isVip = isVip,
        isOnline = isOnline,
        friendShip = friendShip,
        group = group,
        lastChatTime = lastChatTime,
        hasRedDot = hasRedDot,
        comeback_flag = comeback_flag,
        }

    return friend
end

function FriendMgr:getFriendByList(list, limits)
    local friends = {}
    local function checkLimits(limits, data)
        if not limits then
            return true
        end

        if limits.minlevel and limits.minlevel > data.lev then
            return
        end

        return true
    end

    for _, v in pairs(list) do
        -- 将好友筛选出来
        local level = v:queryInt("level")
        local group = v:queryInt("group")
        local name = v:queryBasic("char")
        local icon = v:queryInt("icon")
        local faction = v:queryBasic("party/name")

        local isVip = v:queryInt("insider_level")
        local isOnline = v:queryInt("online")
        local friendShip = v:queryInt("friend")
        local gid = v:queryBasic("gid")
        local lastChatTime = v.lastChatTime or 0
        local hasRedDot = v.hasRedDot or 0
        if nil == faction or "" == faction or "N/A" == faction then
            faction = FriendMgr:getFriendsPartyByGid(gid)
        end

        local data = {group = group, gid = gid, name = name, icon = icon, faction = faction, lev = level, isVip = isVip, isOnline = isOnline, friendShip = friendShip, lastChatTime = lastChatTime, hasRedDot = hasRedDot}
        if checkLimits(limits, data) then
            table.insert(friends, data)
        end
    end

    return friends
end

-- 获取好友列表信息
-- 上限200
function FriendMgr:getFriends(limits)
    return FriendMgr:getFriendByList(self.friendList, limits)
end

-- 获取好友验证信息
function FriendMgr:getFriendCheck()
    local checkMsg = SystemMessageMgr:getSystemMessageListByType(SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK)
    local friendChecks = {}
    for i = 1, #checkMsg do
        -- 解析数据
        local lev, icon, party, isVip = string.match(checkMsg[i].attachment, "(%d+);(%d+);(.*);(%d+)")
        if not lev then
            lev, icon, party = string.match(checkMsg[i].attachment, "(%d+);(%d+);(.*)")
        end
        table.insert(friendChecks, {id = checkMsg[i].id, gid = checkMsg[i].name, name = checkMsg[i].sender or "", lev = tonumber(lev) or 0, icon = tonumber(icon) or 0, faction = party, isOnline = 1, isVip = isVip and tonumber(isVip)})

        -- 添加到最近联系人
        FriendMgr:addTempFriend(checkMsg[i].sender, checkMsg[i].name)
    end

    return friendChecks
end

-- 是否有系统消息
function FriendMgr:hasSysTemMsg()
    local hasMsg = SystemMessageMgr:getSystemMessageList()
    if 0 == #hasMsg then
        return false
    end

    return true
end

-- 是否有好友验证信息
function FriendMgr:hasFriendCheck()
    local hasMsg = SystemMessageMgr:getSystemMessageListByType(SystemMessageMgr.SYSMSG_TYPE.FRIEND_CHECK)
    if 0 == #hasMsg then
        return false
    end

    return true
end

-- 获取黑名单
-- 上限100
function FriendMgr:getBlackList()
    return FriendMgr:getFriendByList(self.blackList)
end

-- 获取最近联系人
function FriendMgr:getTempFriend()
    return FriendMgr:getFriendByList(self.tempList)
end

function FriendMgr:getTemFriendByGid(gid)
    return self.tempList[gid]
end

function FriendMgr:delAllTempFriend()
    local tempList = self.tempList
    if tempList and next(tempList) then
        local curChatPanel = DlgMgr:sendMsg("FriendDlg", "getCurChatPanel")
        for gid, v in pairs(tempList) do
            if not FriendMgr:hasFriend(gid) then
                -- 移除非好友的历史数据及聊天面板
                self.chatData[gid] = nil
                self.tempCharMsg[gid] = nil
                if self.chatList[gid] then
                    if curChatPanel ~= self.chatList[gid] then
                        self.chatList[gid]:clear()
                        self.chatList[gid]:release()
                        self.chatList[gid] = nil
                    end
                end

                DataBaseMgr:deleteItems("friendChatHistory", string.format("friendGid = '%s'", gid))
            else
                -- 移除好友小红点时，会刷新好友列表排序，此时若有最近联系人，也会排序最近联系人条目
                -- 故先将对应的最近联系人移除
                self.tempList[gid] = nil

                -- 移除好友的小红点
                RedDotMgr:removeFriendRedDot(gid)
            end
        end

        DataBaseMgr:deleteItems("tempFriendInfo")
        RedDotMgr:removeDlgRedDot("tempFriendChat")
        self.tempList = {}
    end
end

function FriendMgr:isOnlineByTemFriendName(name)
    for k, v in pairs(self.tempList) do
        if name == v:queryBasic("char") then
            return v:queryBasicInt("online") == 1
        end
    end
end


-- 搜索好友
function FriendMgr:searchFriend(name)
    if nil == name then return end

    local data = {}
    data.char = name

    gf:CmdToServer("CMD_FINGER", data);
end

-- 在本地搜索好友
function FriendMgr:localSearchFriend(idOrName, checkFunc)
    -- 先按id查找，在按名字查找
    local t = {}

    local function insertDataToTable(t, v)
        local group = v:queryInt("group")
        local name = v:queryBasic("char")
        local icon = v:queryInt("icon")
        local faction = v:queryBasic("party/name")
        local level = v:queryInt("level")
        local isVip = v:queryInt("insider_level")
        local isOnline = v:queryInt("online")
        local friendShip = v:queryInt("friend")
        local gid = v:queryBasic("gid")
        local lastChatTime = v.lastChatTime or 0
        local hasRedDot = v.hasRedDot or 0
        if nil == faction or "" == faction or "N/A" == faction then
            faction = FriendMgr:getFriendsPartyByGid(gid)
        end

        table.insert(t, {gid = gid, name = name, icon = icon, faction = faction, lev = level, isVip = isVip, isOnline = isOnline, friendShip = friendShip, lastChatTime = lastChatTime, hasRedDot = hasRedDot})
    end

    for k, v in pairs(self.friendList) do
        if gf:getShowId(k) == idOrName then
            t = {}
            insertDataToTable(t, v)
            break
        elseif v:queryBasic("char"):match(idOrName) and (not checkFunc or checkFunc(k, v)) then
            insertDataToTable(t, v)
        end
    end

    return t
end

-- 移除npc聊天小红点
function FriendMgr:removeNpcChatRedDot()
    for tempGid, v in pairs(self.tempList) do
        if self:isNpcByGid(tempGid) then
            RedDotMgr:removeChatRedDot(tempGid)
        end
    end
end

-- 清除数据
function FriendMgr:clearData(isMsgLoginDone)
    -- 不清除最近联系人
    if not isMsgLoginDone then
        -- 缓存数据
        self:flushChatListToMem()

        -- 移除npc聊天小红点
        self:removeNpcChatRedDot()

        self.tempList = {}
        self.chatData = {}
        self.recentFriends = {}

        RedDotMgr:removeOneRedDot("ChatDlg", "FriendButton")
        RedDotMgr:removeOneRedDot("ChannelDlg", "FriendDlgButton")

        self.inviteMemberList = {}

        self.curVisibleDlg = nil

        self.notRecommendfInThisLogin = nil

        self.kuafObjDist = {}

        self.npcMsgIds = {}

        -- 进入跨服区组前要清除该数据
        charMenuInfo = {}
    end

    -- 获取显示当前聊天信息的 Panel
    local curChatPanel = DlgMgr:sendMsg("FriendDlg", "getCurChatPanel")

    -- 清除缓存中的聊天面板
    -- 如果 curChatPanel 不为空，则表示该 Panel 正在被 FriendDlg 使用，不能执行 clear 操作
    for k, v in pairs(self.chatList) do
        if not curChatPanel or v ~= curChatPanel then
            v:clear()
        end

        v:release()
    end

    self:writeFriendsParty()
    self.friendMemos  = {}
    self.friendParty = nil
    self.friendList = {}
    self.blackList = {}
    self.chatList = {}
    self.friendsGroups = {}
    self.chatGroupsMember = {}
    self.chatGroupsInfo = {}
    self.friendsGroupsInfo = {}
    self.cfg = nil
    SystemMessageMgr:clearData(isMsgLoginDone)
    self.requestInfo = nil
    DlgMgr:sendMsg("FriendDlg", "clearData")
end

-- 尝试添加好友
function FriendMgr:tryToAddFriend(name, gid, settingFlag)
    if self:hasFriend(gid) then
        -- 如果已经是己方好友
        local str = string.format(CHS[5000060], name)
        gf:confirm(str, function()
            self:deleteFriend(name, gid)
        end)
    else
        -- 如果都没有设置，则直接添加好友
        self:addFriend(name)
    end
end

-- 添加好友
function FriendMgr:addFriend(name)
    if nil == name then return end

    local data = {}
    data.group = FRIEND_GROUP
    data.char = name
    gf:CmdToServer("CMD_ADD_FRIEND", data)
end

-- 添加最近联系人
function FriendMgr:addTempFriend(name, gid)
    if nil == name then return end

    if FriendMgr:isTempByGid(gid) then
        return
    end

    local data = {}
    data.group = TEMP_GROUP
    data.char = name
    gf:CmdToServer("CMD_ADD_FRIEND", data)
end

function FriendMgr:updateFriendByMsg(data)
    local name = data.name
    local icon = data.icon
    local level = data.level
    local gid = data.gid
    local time = data.time

    if level == 0 then level = nil end
    if name == "" then name = nil end
    if icon == 0 then icon = nil end

    local tempFriend = self:getTemFriendByGid(gid)
    if tempFriend and not self:hasFriend(gid) then
        -- 更新临时好友数据
        -- setFriendLastChatTime 会更新界面显示，这里只更新数据即可
        local updateTime = tempFriend:queryBasicInt("updateTime")
        if time >= updateTime then
            self:updateFriends({
                gid = gid,
                char = name,
                icon = icon,
                level = level,
                group = TEMP_GROUP,
            }, true)
        end
    end

    local cityFriend = CitySocialMgr:getCityFriend(gid)
    if cityFriend then
        -- 更新区域好友数据
        -- setCityFriendLastChatTime 会更新界面显示，这里只更新数据即可
        local updateTime = cityFriend:queryBasicInt("updateTime")
        if time >= updateTime then
            CitySocialMgr:updateCityFriends({
                gid = gid,
                char = name,
                icon = icon,
                level = level,
            }, true)
        end
    end
end

-- 通过接收到的聊天信息添加最近联系人
function FriendMgr:addTempFriendByMsg(data)
    if not data or not next(data) then
        return
    end

    if FriendMgr:getTemFriendByGid(data.gid) then
        return
    end

    local name = data.name
    local icon = data.icon
    local gid = data.gid
    if not name or not icon or not gid then
        local data = {}
        data.group = TEMP_GROUP
        data.char = name
        gf:CmdToServer("CMD_ADD_FRIEND", data)
    else
        -- 本地自己添加最近联系人后，再发消息请求服务端更新
        local friend = {}
        friend.group = TEMP_GROUP
        friend.char = name
        friend.icon = icon
        friend.gid = gid
        friend.level = data.level or 0
        friend["party/name"] = ""
        friend.insider_level = 0
        friend.online = 2
        friend.friend = 0
        friend.dist_name = data.dist_name

        -- 加入临时列表
        FriendMgr:updateFriends(friend)

        if not FriendMgr:isKuafDist(data.dist_name) then
            FriendMgr:requestCharMenuInfo(data.gid)
        else
            -- 跨服对象请求在线状态
            self:requestFriendOnlineState(gid, data.dist_name)
        end

        if not GameMgr:isInBackground() then
            -- 处于后台是，不刷新界面
            DlgMgr:sendMsg("FriendDlg", "refreshTempFriend", friend)
        end
    end
end


-- 删除好友
function FriendMgr:deleteFriend(name, gid)
    if nil == name then return end

    local friend = self:getFriendByGid(gid)
    if not friend then return end
    local data = {}
    data.group = friend:queryBasic("group")
    data.char = name
    gf:CmdToServer("CMD_REMOVE_FRIEND", data)
end

-- 发送好友验证消息
function FriendMgr:sendFriendCheck(name, gid, info)
    gf:CmdToServer("CMD_VERIFY_FRIEND", {char_name = name, char_gid = gid, message = info})
end

-- 从黑名单移除
function FriendMgr:deleteFromBlack(gid)
    if not gid then return end

    local char = self.blackList[gid]
    if char then
        local data = {}
        data.group = BLACK_GROUP
        data.char = char:queryBasic("char")
        gf:CmdToServer("CMD_REMOVE_FRIEND", data);
    end
end

-- 添加到黑名单
function FriendMgr:addBlack(name, icon, level, gid, distName)
    if nil == name then return end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addModuleContinueCb("FriendMgr", "addBlack", name, icon, level, gid)
        return
    end

    if self:hasFriend(gid) then
        self:deleteFriend(name, gid)
    end

    local data = {}
    data.group = BLACK_GROUP
    data.char = name
    data.icon = icon
    data.level = level
    data.gid= gid
    data.user_dist = distName

    if self:getKuafObjDist(gid) then
        gf:CmdToServer("CMD_LBS_ADD_BLACKLIST_FRIEND", data)
    else
        gf:CmdToServer("CMD_ADD_FRIEND", data)
    end
end

-- 更新好友信息
function FriendMgr:updateFriends(data, onlyUpdate)
    if not data or not data.gid then
        return
    end

    if not GameMgr:IsCrossDist() and not data.dist_name then
        -- 非跨服区组中需要判断对象是否跨服对象（最近联系人、黑名单可能有跨服对象）
        local name, dist = gf:getRealNameAndFlag(data.char)
        if dist then
            data.dist_name = dist
        end
    end

    local group = tonumber(data.group)

    -- 非好友的最近联系人会通过聊天数据更新数据，收到聊天的时间大于该时间才会更新
    data.updateTime = gf:getServerTime()

    data["family"] = data["family"] ~= "N/A" and data["family"] or nil
    data["party/name"] = data["party/name"] ~= "N/A" and data["party/name"] or nil
    data["title"] = data["title"] ~= "N/A" and data["title"] or nil

    if BLACK_GROUP == group then
        data.online = 2

        -- 该对象可能在最近联系人中
        if self.tempList[data.gid] then -- 如果存在最近联系人则删除好友
            local info = {group = tostring(TEMP_GROUP), char = data.char, gid = data.gid}
            self:MSG_FRIEND_REMOVE_CHAR(info)
            DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REMOVE_CHAR", info)
        end

        -- 加入黑名单
        local friend = self.blackList[data.gid]
        if not friend then
            if onlyUpdate then
                return
            end

            friend = DataObject.new()
            self.blackList[data.gid] = friend
        end

        friend:absorbBasicFields(data)
    elseif FRIEDN_GROUP_ID[group] then -- 好友
        if not self.friendsGroups then self.friendsGroups = {} end
        if not self.friendsGroups[group] then self.friendsGroups[group] = {} end

        -- 加入好友列表
        local friend = self.friendList[data.gid]
        if not friend then
            if onlyUpdate then
                return
            end

            friend = DataObject.new()
            friend:absorbBasicFields(data)
            self.friendList[data.gid] = friend
        else
            if nil == data.icon or data.icon == 0 then
                -- 过滤icon
                data.icon = nil
            end

            if nil == data.family or "" == data.family then
                -- 过滤门派
                data.family = nil
            end
        end

        if self.tempList[data.gid] then
            local temData = gf:deepCopy(data)
            temData.group = tostring(TEMP_GROUP)
            self.tempList[data.gid]:absorbBasicFields(temData)
        end

        friend:absorbBasicFields(data)

        self.friendsGroups[group][data.gid] = friend
    elseif TEMP_GROUP == group then
        -- 加入临时列表
        if self.friendList[data.gid] then
            data.online = self.friendList[data.gid]:queryInt("online")
        end

        local friend = self.tempList[data.gid]

        if not friend then
            if onlyUpdate then
                return
            end

            friend = DataObject.new()
            self.tempList[data.gid] = friend

            -- 临时好友可能先收到聊天信息，后加临时好友对象，会没有标记交互时间及小红点
            local chatData = self.tempCharMsg[data.gid] or self.chatData[data.gid]
            if chatData then
                local cou = #chatData
                if chatData[cou] then
                    self:setFriendLastChatTime(data.gid, chatData[cou].time, true)
                end
            end
        end

        friend:absorbBasicFields(data)
    end
end

function FriendMgr:getFriendByGid(gid)
    return self.friendList[gid]
end

-- 从本地获取好友聊天记录
function FriendMgr:getFriendChatHistory(gid)
    local data = DataBaseMgr:selectItems("friendChatHistory", string.format("friendGid = '%s' order by static_id limit %d", gid, SAVE_LIST_COUNT))

    --从列“level”的值中分出列“show_extra”的值
    local realData = {}
    for i, tab in pairs(data) do
        if type(tab) == "table" and tab["index"] and "" ~= tab["index"] then
            local str = tab["level"]
            if string.match(tab["level"], "{.+}") then
                local para = json.decode(tab["level"])
                for key, v in pairs(para) do
                    tab[key] = v
                end
            else
                if str and string.sub(str, string.len(str) - 1, -2) == '.' then
                    tab["show_extra"] = (tonumber(string.sub(str, -1)) == 1)
                    tab["level"] = string.sub(str, 1, -3)
                else
                    tab["show_extra"] = false
                end
            end

            tab["index"] = #realData + 1

            local para = gf:splitBydelims(tab.chatStr, {"@chatStr:", "@checksum:", "@channel:", "@recv_gid:"})
            if #para > 1 then
                -- 加入举报后的格式
                tab.chatStr = string.match(para[2], "@chatStr:(.+)") or ""
                tab.checksum = tonumber(string.match(para[3], "@checksum:(.+)"))
                tab.channel = tonumber(string.match(para[4], "@channel:(.+)"))
                tab.recv_gid = string.match(para[5], "@recv_gid:(.+)")
            else
                tab.chatStr = tab.chatStr
            end

            table.insert(realData, tab)
        end
    end

    realData.count = #realData
    return realData
end

-- 创建一个条目
function FriendMgr:buildOneInsertSql(data, friendGid, index)
    -- npc 消息没读过的，不保存，服务器会重新发
    if data.npcMsgHasRead == false then return end

    local values = {}
    values.friendGid = friendGid
    values.gid = data.gid
    values.icon = data.icon
    values.name = data.name
    values.time = data.time
    values.index = index or data.index

    values.level = json.encode({
        level = data["level"],
        show_extra = data["show_extra"],
        chat_head = data["chat_head"],   -- 聊天头像框
        chat_floor = data["chat_floor"],   -- 聊天气泡框
        sysTipType = data["sysTipType"],     -- 是否系统提示消息
        msg = data["msg"],
        channel_source = data.channel_source
    })

    -- 不用json的原因是，读取旧资源，不好判断是否是json格式字符串,单判断有没有 "{.+}"也不行
    -- data.channel旧数据没有该字段，默认一个10000
    values.chatStr = string.format("@chatStr:%s@checksum:%d@channel:%d@recv_gid:%s", data.chatStr, data.checksum or 0, data.channel or 10000, data.recv_gid or "")


    if not values.index or "" == values.index then
        local logMsg = {}
        table.insert(logMsg, "Invalid data at FriendMgr:buildOneInsertSql")
        table.insert(logMsg, gfTraceback())
        local sendMsg = table.concat(logMsg, '\n')
        gf:ftpUploadEx(sendMsg)
        Log:D(sendMsg)
        return false
    end

    DataBaseMgr:insertItem("friendChatHistory", values)
    return true
end

function FriendMgr:setChatByGid(gid, chatPanel)
    if not gid or not chatPanel or not self.chatList then return end

    self.chatList[gid] = chatPanel
    chatPanel:retain()
end

-- 获取好友聊天信息
function FriendMgr:getChatByGid(gid, contenSize, chatType)
    -- 先从本地获取消息
    -- 判断是否已经存在聊天面板，如果已经存在，则直接返回
    if nil == self.chatList[gid] then
        -- 若不存在聊天面板
        local data = {}
        -- 内存有数据优先获取内存中的数据（换线不清除数据）
        if self.chatData[gid] then
            data = self.chatData[gid]
        else
            -- 本地查找是否存在缓存文件，并获取文件及信息
            local chatDataPath = cc.FileUtils:getInstance():getWritablePath() .. GameMgr:getChatPath("chatData/")
            local filePath = chatDataPath .. gid .. ".lua"
            data = self:getFriendChatHistory(gid)
        end

        -- 初始化聊天面板，并将聊天面板添加到管理器中，并返回
        self.chatList[gid] = SingleChatPanel.new(data, true, contenSize, chatType, gid)
        self.chatList[gid]:retain()

        if self.hasOneCallMe[gid] then
            self.chatList[gid]:setHasOneCallMe(true)
            self.hasOneCallMe[gid] = nil
        end
    end

    -- 判断是否存在临时信息，如果存在，则插入
    if nil ~= self.tempCharMsg[gid] then
        for k, v in pairs(self.tempCharMsg[gid]) do
            local chatData = self.chatList[gid]:getListData()
            if chatData then
                v["index"] = #chatData + 1
                table.insert(chatData, v)
            end
        end

        -- 清空临时信息
        self.tempCharMsg[gid] = nil
    end

    -- 刷新控件
    -- self.chatList[gid]:refreshChatPanel()
    self.chatData[gid] = self.chatList[gid]:getListData()

    return self.chatList[gid]
end

-- 设置群组聊天
function FriendMgr:setGroupChatMsg(data)
    if CHAT_CHANNEL.CHAT_GROUP ~= data.channel then
        return
    end

    -- 如果gid不存在，则抛弃
    if "" == data.gid or nil == data.gid then
        return
    end

    -- 组织数据
    local chatTable = {}
    chatTable.gid = data.gid
    chatTable.icon = data.icon
    chatTable.chatStr = data.msg
    chatTable.name = data.name
    chatTable.time = data.time
    chatTable.voiceTime= data.voiceTime / 1000
    chatTable.token = data.token
    chatTable.level = data.level
    chatTable["show_extra"] = data["show_extra"]
    chatTable["comeback_flag"] = data["comeback_flag"]
    chatTable["chat_floor"] = data["chat_floor"]  -- 聊天气泡框
    chatTable["chat_head"] = data["chat_head"]    -- 聊天头像框
    chatTable["channel"] = data["channel"]
    chatTable["msg"] = data["originalMsg"] or data["msg"]  -- 消息原文，不能做处理，否则无法举报
    chatTable["checksum"] = data["checksum"] or 0
    chatTable["time"] = data["time"]
    chatTable["recv_gid"] = data["recv_gid"]
    chatTable["haveFilt"] = data["haveFilt"]
    chatTable["recvSyncMsgTime"] = data["recvSyncMsgTime"]
    chatTable["channel_source"] = data["channel_source"]

    local cur_gid = data.recv_gid
    if not cur_gid then return end

    local isBlink
    if ChatMgr:doSomeHasOneCallMe(chatTable) then
        self.hasOneCallMe[cur_gid] = true
        isBlink = true
    end

    -- 添加小红点提示
    local groupGid = DlgMgr:sendMsg("FriendDlg", "getCurChatGid")
    if data.gid ~= Me:queryBasic("gid") and groupGid ~= cur_gid and FriendMgr:isNeedMsgTipByGroupId(cur_gid) then --自己和当前聊天好友不插入小红点
        RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, isBlink)
        RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, isBlink)
        DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton", nil, nil, isBlink)

        RedDotMgr:insertOneRedDot("FriendDlg", "GroupCheckBox", nil, nil, isBlink)
        RedDotMgr:insertOneRedDot("FriendDlg", "GroupReturnButton", nil, nil, isBlink)
        RedDotMgr:insertOneRedDot("GroupChat", cur_gid, nil, nil, isBlink)
       -- DlgMgr:sendMsg("FriendDlg","MSG_CHAT_GROUP_PARTIAL" , {groupId = cur_gid})
    else
        -- 添加小红点提示
        if data.gid ~= Me:queryBasic("gid") and FriendMgr:isNeedMsgTipByGroupId(cur_gid) then
            RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, isBlink)
            RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, isBlink)
            DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton", nil, nil, isBlink)
        end
    end

    -- 设置群组聊天的时间
    local group = self.chatGroupsInfo[data.group_id]
    if group then
        group.lastChatTime = tonumber(data.time) or 0
        DlgMgr:sendMsg("FriendDlg", "sortGroupList")
    end

    -- 如果未打开聊天窗口，则将离线信息加到临时存储区中
    if  nil == self.chatList[cur_gid] then

        if nil == self.tempCharMsg[cur_gid] then
            self.tempCharMsg[cur_gid] = {}
        end

        -- 语音文本特殊处理（分为语音内容和文字内容）
        if chatTable["token"] ~= "" and data["msg"] ~= "" and chatTable["voiceTime"] ~= 0 then
            -- 语音翻译文本结束后发过来的文本内容
            for i = #self.tempCharMsg[cur_gid], 1 , -1 do
                if self.tempCharMsg[cur_gid][i].token ==  data["token"] then
                    self.tempCharMsg[cur_gid][i].chatStr = data["msg"]
                    self.tempCharMsg[cur_gid][i]["haveFilt"] = data["haveFilt"]
                    self.tempCharMsg[cur_gid][i].needFresh = true
                    break
                end
            end
        else
            self:insertChat(self.tempCharMsg[cur_gid], chatTable)
        end

        return
    end


    local chatData = self.chatList[cur_gid]:getListData()

    if self.hasOneCallMe[cur_gid] then
        self.chatList[cur_gid]:setHasOneCallMe(true)
        self.hasOneCallMe[cur_gid] = nil
    end

    -- 语音文本特殊处理（分为语音内容和文字内容）
    if chatTable["token"] ~= "" and data["msg"] ~= "" and chatTable["voiceTime"] ~= 0 then
        -- 语音翻译文本结束后发过来的文本内容
        for i = #chatData, 1 , -1 do
            if chatData[i].token ==  data["token"] then
                chatData[i].chatStr = data["msg"]
                chatData[i].msg = data["originalMsg"]
                chatData[i]["haveFilt"] = data["haveFilt"]
                chatData[i].needFresh = true
                break
            end
        end
    else
        self:insertChat(chatData, chatTable)
    end

    -- 如果游戏在后台不允许操作ui相关的操作，这样贴图会创建不成功，导致进前台时候，被创建过的贴图不显示了
    if not GameMgr:isInBackground() then
        self.chatList[cur_gid]:refreshChatPanel(ChatMgr:isVoiceTranslateText(data))
    end
end

-- 设置聊天信息
-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作，需要做判断，GameMgr:isInBackground() 为true不执行
function FriendMgr:setChatMsg(data)
    if CHAT_CHANNEL.FRIEND ~= data.channel then
        return
    end

    -- 如果gid不存在，则抛弃
    if "" == data.gid or nil == data.gid then
        return
    end

    self.hasNewMsgNotFlush = true

    local curChatGid = DlgMgr:sendMsg("FriendDlg", "getCurChatGid")
    if data.gid ~= Me:queryBasic("gid") and (curChatGid ~= data.gid or not DlgMgr:sendMsg("FriendDlg", "isShow")) then --自己和当前聊天好友不插入小红点
        if not self:isBlackByGId(data.gid) then
            -- 加为最近联系人
            self:addTempFriendByMsg(data)

            -- 添加小红点提示
            RedDotMgr:insertOneRedDot("FriendDlg", "TempCheckBox", nil, nil, true)
            if DlgMgr:isDlgOpened("FriendDlg") then
                RedDotMgr:insertOneRedDot("FriendDlg", "TempReturnButton")
            end

            RedDotMgr:insertOneRedDot("tempFriendChat", data.gid, nil, nil, true)
        end

        if self:hasFriend(data.gid) then
            RedDotMgr:insertOneRedDot("FriendChat", data.gid, nil, nil, true)
            local friend =  self:getFriendByGid(data.gid)
            local friendsGroup = FriendMgr:getFriendsGroupsInfoById(friend:queryBasic("group"))
            if not friendsGroup then return end

            DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = friendsGroup.groupId})
        end
    end

    if data.gid ~= Me:queryBasic("gid") then
        FriendMgr:updateFriendByMsg(data)
    end

    -- 如果游戏在后台不需要播放声音
    if data.name ~= Me:queryBasic("name") and not GameMgr:isInBackground() then
        -- 播放收到消息的音效
        self:playMessageSound()
    end

    -- 组织数据
    local chatTable = {}
    chatTable.gid = data.gid
    chatTable.icon = data.icon
    chatTable.chatStr = data.msg
    chatTable.name = data.name
    chatTable.time = data.time
    chatTable.voiceTime= data.voiceTime / 1000
    chatTable.token = data.token
    chatTable.level = data.level
    chatTable["show_extra"] = data["show_extra"]
    chatTable["comeback_flag"] = data["comeback_flag"]
    chatTable["chat_floor"] = data["chat_floor"]  -- 聊天气泡框
    chatTable["chat_head"] = data["chat_head"]    -- 聊天头像框
    chatTable["channel"] = data["channel"]
    chatTable["msg"] = data["originalMsg"] or data["msg"]  -- 消息原文，不能做处理，否则无法举报
    chatTable["checksum"] = data["checksum"] or 0
    chatTable["time"] = data["time"]
    chatTable["sysTipType"] = data["sysTipType"]
    chatTable["haveFilt"] = data["haveFilt"]
    chatTable["npcTellType"] = data["npcTellType"]
    chatTable["npcMsgId"] = data["npcMsgId"]
    chatTable["npcMsgHasRead"] = data["npcMsgHasRead"]
    chatTable["recvSyncMsgTime"] = data["recvSyncMsgTime"]
    chatTable["channel_source"] = data["channel_source"]

    local cur_gid
    if data.gid == Me:queryBasic("gid") then
        cur_gid = data.recv_gid

    else
        cur_gid = data.gid

        -- 添加小红点提示
        RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton", nil, nil, true)
        RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton", nil, nil, true)
        DlgMgr:sendMsg("HomeFishingDlg", "addRedDotOnFriendButton", true)
    end

    if self:hasFriend(cur_gid) then
        -- 登录期间联系过的好友
        self.recentFriends[cur_gid] = data.time
    end

    -- 设置聊天
    self:setFriendLastChatTime(cur_gid, data.time)

    CitySocialMgr:setCityFriendLastChatTime(cur_gid, data.time)

    -- 如果未打开聊天窗口，则将离线信息加到临时存储区中
    if nil == self.chatList[cur_gid] then

        if nil == self.tempCharMsg[cur_gid] then
            self.tempCharMsg[cur_gid] = {}
        end

        -- 语音文本特殊处理（分为语音内容和文字内容）
        if chatTable["token"] ~= "" and data["msg"] ~= "" and chatTable["voiceTime"] ~= 0 then
            -- 语音翻译文本结束后发过来的文本内容
            for i = #self.tempCharMsg[cur_gid], 1 , -1 do
                if self.tempCharMsg[cur_gid][i].token ==  data["token"] then
                    self.tempCharMsg[cur_gid][i].chatStr = data["msg"]
                    self.tempCharMsg[cur_gid][i]["haveFilt"] = data["haveFilt"]
                    self.tempCharMsg[cur_gid][i].needFresh = true
                    break
                end
            end
        else
            self:insertChat(self.tempCharMsg[cur_gid], chatTable)
        end

        return
    end

    -- 将数据添加到控件中，并刷新
    local chatData = self.chatList[cur_gid]:getListData()

    -- 语音文本特殊处理（分为语音内容和文字内容）
    if chatTable["token"] ~= "" and data["msg"] ~= "" and chatTable["voiceTime"] ~= 0 then
        -- 语音翻译文本结束后发过来的文本内容
        for i = #chatData, 1 , -1 do
            if chatData[i].token ==  data["token"] then
                chatData[i].chatStr = data["msg"]
                chatData[i].msg = data["originalMsg"]
                chatData[i]["haveFilt"] = data["haveFilt"]
                chatData[i].needFresh = true
                break
            end
        end
    else
        self:insertChat(chatData, chatTable)
    end

    -- 如果游戏在后台不允许操作ui相关的操作，这样贴图会创建不成功，导致进前台时候，被创建过的贴图不显示了
    if not GameMgr:isInBackground() then
        self.chatList[cur_gid]:refreshChatPanel(ChatMgr:isVoiceTranslateText(data))
    end
end

function FriendMgr:insertChat(chatData, chatTable)
    if chatTable["recvSyncMsgTime"] and chatTable["time"] then
        -- 同步消息的时间以显示的时间为准
        local lastData = chatData[#chatData]
        if lastData and lastData["time"] then
            chatTable["time"] = math.max(chatTable["time"] + math.floor((gfGetTickCount() - chatTable["recvSyncMsgTime"]) / 1000), lastData["time"])
        else
            chatTable["time"] = chatTable["time"] + math.floor((gfGetTickCount() - chatTable["recvSyncMsgTime"]) / 1000)
        end

        chatTable["recvSyncMsgTime"] = 0
    end

    chatTable["index"] = #chatData + 1
    table.insert(chatData, chatTable)
end

-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作，需要做判断，GameMgr:isInBackground() 为true不执行
function FriendMgr:setFriendLastChatTime(gid, time, notRefresh)
    if not refreshFriend then refreshFriend = {} end

    time = tonumber(time) or 0

    local friend = self:getFriendByGid(gid)
    repeat
        if not friend then
            break
        end

        friend.lastChatTime = 0
        -- 添加小红点字段
        friend.hasRedDot = 0
        if RedDotMgr:friendHasRedDot(friend:queryBasic("gid")) then
            friend.hasRedDot = 1
        end

        if notRefresh then
            break
        end

        local value = {group = friend:queryInt("group"), char = friend:queryBasic("char"), gid = gid}
        if GameMgr:isInBackground() then
            refreshFriend[gid] = value
            break
        end

        DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_UPDATE_PARTIAL", value)
    until true

    local tempFriend = self:getTemFriendByGid(gid)
    repeat
        if not tempFriend then
            break
        end

        if not tempFriend.lastChatTime or tempFriend.lastChatTime < time then
            tempFriend.lastChatTime = time
        end

        tempFriend.hasRedDot = 0
        if RedDotMgr:tempFriendHasRedDot(tempFriend:queryBasic("gid")) then
            tempFriend.hasRedDot = 1
        end

        if notRefresh then
            break
        end

        local value = {group = tempFriend:queryInt("group"), gid = tempFriend:queryBasic("gid")}
        if GameMgr:isInBackground() then
            if refreshFriend[gid] and refreshFriend[gid].group ~= TEMP_GROUP then
                -- 已经缓存了需要刷新的好友数据，会在 MSG_FRIEND_UPDATE_PARTIAL 中刷新最近联系人数据
                -- 所以此处不用再缓存需要刷新的最近联系人数据
                break
            end

            refreshFriend[gid] = value
            break
        end

        DlgMgr:sendMsg("FriendDlg", "refreshTempFriend", value)
    until true
end

-- 更新切后台时需要更新的好友或临时列表ui
function FriendMgr:refreshFriendListAfterBcakground()
    local dlg = DlgMgr:getDlgByName("FriendDlg")
    if not dlg or not refreshFriend then
        -- 重开后好友列表会自动刷新，不用再保存
        refreshFriend = {}
        return
    end

    for gid, tab in pairs(refreshFriend) do
        if self:hasFriend(gid) then
            dlg:MSG_FRIEND_UPDATE_PARTIAL(tab)
        elseif self:getTemFriendByGid(gid) then
            -- 有好友对象，会在 MSG_FRIEND_UPDATE_PARTIAL 中刷新最近联系人数据
            dlg:refreshTempFriend({group = TEMP_GROUP, gid = gid})
        end
        end

    refreshFriend = {}
end

-- 将内存中的聊天记录存到本地
function FriendMgr:flushChatListToMem()
    -- 判断是否还存在临时消息
    local tempGids = {}
    self.hasNewMsgNotFlush = false
    if nil ~= self.tempCharMsg then
        for k, v in pairs(self.tempCharMsg) do
            -- 获取聊天面板
            if nil == self.chatData[k] then
                self.chatData[k] = self:getFriendChatHistory(k)
            end

            for i = 1, #v do
                v[i].index = #self.chatData[k] + 1
                table.insert(self.chatData[k], v[i])
            end
        end
        self.tempCharMsg = {}
    end

    for friendGid, v in pairs(self.chatData) do
        -- 存储内容
        local data = v
        local index = 1
        local i = #data - SAVE_LIST_COUNT + 1
        if i <= 1 then
            i = 1
        end

        -- 值存储好友的聊天数据
        if self:hasFriend(friendGid)
                or self:getGroupByGroupId(friendGid)
                or self:getTemFriendByGid(friendGid)
                or CitySocialMgr:hasCityFriendByGid(friendGid)then
            DataBaseMgr:deleteItems("friendChatHistory", string.format("friendGid = '%s'", friendGid))
            while i <= #data do
                if nil ~= data[i] then
                    if self:buildOneInsertSql(data[i], friendGid, index) then
                    index = index + 1
                    end

                    i = i + 1
                end
            end
        else
            DataBaseMgr:deleteItems("friendChatHistory", string.format("friendGid = '%s'", friendGid))
        end
    end

    self:flushTempListToMem()
end

-- 将最近联系人信息记录存到本地
function FriendMgr:flushTempListToMem()
    if GameMgr:IsCrossDist() or not next(self.tempList) then
        -- 不保存跨服区组中的最近联系人
        return
    end

    -- 读取数据库中已有的临时好友，避免被移除
    local data = DataBaseMgr:selectItems("tempFriendInfo")
    local value = {}
    local tempDatas = {}
    for i = 1, data.count do
        local tempInfo = json.decode(data[i].str)

        if not self:getTemFriendByGid(tempInfo.gid) then
            tempDatas[tempInfo.gid] = data[i]
        end
    end

    local time = gf:getServerTime()
    DataBaseMgr:deleteItems("tempFriendInfo")

    for tempGid, v in pairs(self.tempList) do
        local tempInfo = {}
        tempInfo.group = v:queryInt("group")
        tempInfo.char = v:queryBasic("char")
        tempInfo.icon = v:queryInt("icon")
        tempInfo["party/name"] = v:queryBasic("party/name")
        tempInfo.level = v:queryInt("level")
        tempInfo.insider_level = v:queryInt("insider_level")
        tempInfo.online = v:queryInt("online")
        tempInfo.friend = v:queryInt("friend")
        tempInfo.gid = v:queryBasic("gid")
        tempInfo.dist_name = v:queryBasic("dist_name")
        tempInfo.comeback_flag = v:queryInt("comeback_flag")
        tempInfo.lastChatTime = v.lastChatTime or 0

        local value = {}
        value.str = json.encode(tempInfo)
        value.date = time

        DataBaseMgr:insertItem("tempFriendInfo", value)
    end

    for _, value in pairs(tempDatas) do
        value.date = time
        DataBaseMgr:insertItem("tempFriendInfo", value)
    end
end

-- 从本地获取最近联系人记录
function FriendMgr:getTempFriendbyMem()
    local data = DataBaseMgr:selectItems("tempFriendInfo")
    local value = {}
    local time = gf:getServerTime()
    local needRefresh = false

    for i = 1, data.count do
        if not string.isNilOrEmpty(data[i].date) then
        local ctime = (time - tonumber(data[i].date)) / 60.0
        local tempInfo = json.decode(data[i].str)
        local hasFriend = FriendMgr:hasFriend(tempInfo.gid)
        tempInfo.hasRedDot = RedDotMgr:tempFriendHasRedDot(tempInfo.gid) and 1 or 0
        if ctime <= 30 or (hasFriend and tempInfo.hasRedDot == 1) then  -- 玩家下线30分钟内不删除最近联系人
            table.insert(value, tempInfo)
        else
            needRefresh = true
            if not hasFriend then
                DataBaseMgr:deleteItems("friendChatHistory", string.format("friendGid = '%s'", tempInfo.gid))
            end
        end
    end
    end

    DataBaseMgr:deleteItems("tempFriendInfo")
    return value, needRefresh
end

-- 设置本地最近联系人记录
function FriendMgr:setTempFriendbyMem()
    if DistMgr:getIsSwichServer()
          or GameMgr:IsCrossDist() then
        -- 存跨服区组中不读取源区组的最近联系人数据
        return
    end

    local data, needRefresh = self:getTempFriendbyMem()
    for i, v in pairs(data) do

        if not FriendMgr:getTemFriendByGid(v.gid) then
            -- 加入临时列表
            FriendMgr:updateFriends(v)

            self:setTempFriendInfo(v)
        end
    end

    return needRefresh
end

-- 设置重新打开界面后的最近联系人的交互时间和是否有未读消息
function FriendMgr:setTempFriendInfo(friend)
    local tempFriend = FriendMgr:getTemFriendByGid(friend.gid)
    if tempFriend then
        tempFriend.hasRedDot = friend.hasRedDot

        if not tempFriend.lastChatTime or tempFriend.lastChatTime == 0 then
            tempFriend.lastChatTime = friend.lastChatTime or 0
        end
    end
end

-- 发送群组消息
function FriendMgr:sendMsgToChatGroup(name, text, gid, voiceTime, token)
	local data = {}
    data["flag"] = 0
    data["name"] = name
    data["msg"] = text
    data["compress"] = 0
    data["orgLength"] = string.len(text)
    data["item_count"] = 0
    data["id1"] = 0
    data["receive_gid"] = gid
    data["voiceTime"] = voiceTime or 0
    data["token"] = token or ""

    -- 不可发送空白消息
    if  ChatMgr:textIsALlSpace(text) and string.len(data["token"]) == 0 then
        gf:ShowSmallTips(CHS[3004013])
        return
    end

    if ActivityMgr:isChantingStauts() then
        gf:ShowSmallTips(CHS[2000368])
        return
    end

    -- 名片处理
    local param = string.match(text, "{\t..-=(..-=..-)}")
    if param then
        data["cardCount"] = 1
        data["cardParam"] = param
    end

    -- 语音
    local settingTable = SystemSettingMgr:getSettingStatus()
    if settingTable["forbidden_play_voice"] == 1 then
        data["voiceTime"] = 0
        data["token"] = ""
    end

    if ChatMgr:textIsALlSpace(text) and string.len(data["token"]) == 0 then
        return
    end

    --为性别表情添加性别符
    data["msg"] = BrowMgr:addGenderSign(text)

    -- 更新一下表情使用时间信息
    BrowMgr:updateBrowUseTime(data["msg"])

    -- 转义一下名片字符串
    data["msg"] = ChatMgr:filtCardStr(data["msg"])

    gf:CmdToServer("CMD_CHAT_GROUP_TELL", data)

    return true
end

-- 给好友发消息
function FriendMgr:sendMsgToFriend(name, text, gid, voiceTime, token)
    if FriendMgr:isNpcByGid(gid) then
        gf:ShowSmallTips(string.format(CHS[7120076], name))
        return
    end

    local data = {}
    data["flag"] = 0
    data["name"] = name
    data["msg"] = text
    data["compress"] = 0
    data["orgLength"] = string.len(text)
    data["item_count"] = 0
    data["id1"] = 0
    data["receive_gid"] = gid
    data["voiceTime"] = voiceTime or 0
    data["token"] = token or ""

    -- 不可发送空白消息
    if  ChatMgr:textIsALlSpace(text) and string.len(data["token"]) == 0 then
        gf:ShowSmallTips(CHS[3004013])
        return
    end

    if ActivityMgr:isChantingStauts() then
        gf:ShowSmallTips(CHS[2000368])
        return
    end

    --为性别表情添加性别符
    data["msg"] = BrowMgr:addGenderSign(text)

    -- 名片处理
    local param = string.match(text, "{\t..-=(..-=..-)}")
    if param then
        data["cardCount"] = 1
        data["cardParam"] = param
    end

    -- 语音
    local settingTable = SystemSettingMgr:getSettingStatus()
    if settingTable["forbidden_play_voice"] == 1 then
        data["voiceTime"] = 0
        data["token"] = ""
    end

    if ChatMgr:textIsALlSpace(text) and string.len(data["token"]) == 0 then
        return
    end

    if not self:hasFriend(gid) and SystemSettingMgr:getSettingStatus("refuse_stranger_msg", 0) == 1 then
        local level = DlgMgr:sendMsg("FriendDlg", "getCurChatLevel")
        local refuseLevel = Me:queryBasicInt("setting/refuse_stranger_level")
        if level < refuseLevel then
            gf:ShowSmallTips(CHS[5410210])
        end
    end

    -- 更新一下表情使用时间信息
    BrowMgr:updateBrowUseTime(data["msg"])

    -- 如果我在跨服，发正常的
    if GameMgr:IsCrossDist() then
        gf:CmdToServer("CMD_FRIEND_TELL_EX", data)
        return
    end

    if not BlogMgr:isSameDist(gid) or FriendMgr:getKuafObjDist(gid) then
        -- 跨服聊天
        gf:CmdToServer("CMD_LBS_FRIEND_TELL", data)
    else
        gf:CmdToServer("CMD_FRIEND_TELL_EX", data)
    end
end

-- 获取聊天列表
function FriendMgr:getChatList(gid)
    return self.chatList[gid]
end

-- 拒绝验证消息
function FriendMgr:refuseFriend(id)
    local sysMsg = SystemMessageMgr:getSystemMessageById(id)
    if not sysMsg then return end

    local data = {}
    data.verifyId = sysMsg.id
    data.charName = sysMsg.sender
    data.charGid = sysMsg.name
    data.result = 0
    gf:CmdToServer("CMD_FRIEND_VERIFY_RESULT", data)
end

-- 同意验证消息
function FriendMgr:agreeFriend(id)
    local sysMsg = SystemMessageMgr:getSystemMessageById(id)
    if not sysMsg then return end

    local data = {}
    data.verifyId = sysMsg.id
    data.charName = sysMsg.sender
    data.charGid = sysMsg.name
    data.result = 1
    gf:CmdToServer("CMD_FRIEND_VERIFY_RESULT", data)

    return sysMsg
end

-- 发送获取推荐列表命令
function FriendMgr:requetSuggestFriend()
    gf:sendGeneralNotifyCmd(NOTIFY.RECOMMEND_FRIEND)
end

-- 加载好友帮派数据
function FriendMgr:loadFriendsParty()
    if nil == self.friendParty then
        local data = DataBaseMgr:selectItems("friendParty")
        self.friendParty = {}
        for i = 1, data.count do
            self.friendParty[data[i].gid] = data[i].partyName
        end
    end
end

-- 写入好友帮派数据
function FriendMgr:writeFriendsParty()
    if nil == self.friendParty then
        self.friendParty = {}
    end

    DataBaseMgr:deleteItems("friendParty")
    for gid, partyName in pairs(self.friendParty) do
        local data = {}
        data.gid = gid
        data.partyName = partyName
        DataBaseMgr:insertItem("friendParty", data)
    end
end

-- 更新一个好友的帮派信息
function FriendMgr:updateFriendsParty(friend)
    if nil == self.friendParty then
        -- 加载好友帮派数据
        FriendMgr:loadFriendsParty()
    end

    local gid = friend:queryBasic("gid")
    local partyName = friend:queryBasic("party/name")

    -- 不在线，不对其进行更新
    if 2 == friend:queryInt("online") then
        return
    end

    -- 在线并且名字为空
    if nil == partyName or "" == partyName or "N/A" == partyName then
        partyName = ""
    end

    self.friendParty[gid] = partyName
end

-- 根据好友GID获取帮派名称没有则返回空字符串
function FriendMgr:getFriendsPartyByGid(friendGid)
    if nil == self.friendParty then
        -- 加载好友帮派数据
        FriendMgr:loadFriendsParty()
    end

    if nil == self.friendParty[friendGid] then
        return ""
    end

    return self.friendParty[friendGid]
end

-- 请求角色弹出菜单的数据
function FriendMgr:requestCharMenuInfo(gid, requestDlg, dlgType, offline, para, distName)
    if not distName then
        -- 部分逻辑是先打开界面，收到消息刷新，所以保留原逻辑
        -- 有传distName 的，目前用在个人空间中，跨服好友，收到数据再打开界面
        local dist = self:getKuafObjDist(gid)
        if dist then
            -- 跨服对象不用请求数据，请求不到，只请求是否在线
            self:requestFriendOnlineState(gid, dist)
            return
        end
    end

    distName = distName or GameMgr:getDistName()
    self.requestInfo = type(requestDlg) ~= "table" and { ["gid"] = gid, ["requestDlg"] = requestDlg } or requestDlg
    gf:CmdToServer("CMD_GET_CHAR_INFO", {char_gid = gid, dlg_type = dlgType or "", offline = offline or 0, para = para or "", user_dist = distName})
end

--
function FriendMgr:setRequestInfo(data)
    self.requestInfo = data
end

function FriendMgr:unrequestCharMenuInfo(requestDlg)
    if self.requestInfo and self.requestInfo.requestDlg == requestDlg then
        self.requestInfo = nil
    end
end

-- 获取角色弹出菜单的数据
function FriendMgr:getCharMenuInfoByGid(gid)
    return charMenuInfo[gid]
end

-- 加好友流程
function FriendMgr:addFriendCheck(data)
    if nil == data then return end

    -- 如果都没有设置，则直接添加好友
    FriendMgr:addFriend(data.name)
end

-- 服务端需要好友重新验证
function FriendMgr:MSG_ADD_FRIEND_VERIFY(data)
    if nil == data then return end

    -- 如果对方设置了不接受好友申请
    if data.settingFlag and data.settingFlag:isSet(SETTING_FLAG.REFUSE_BE_ADDED) then
        gf:ShowSmallTips(CHS[5000076])
        return
    end

    local dlg = DlgMgr:openDlg("AddFriendVerifyDlg")
    dlg:setInfo({name = data.name, id = gf:getShowId(data.gid), gid = data.gid})
end

function FriendMgr:MSG_FRIEND_UPDATE_LISTS(data)
    if data.char_count <= 0 then return end

    for i = 1, data.char_count do
        self:updateFriends(data[i])
    end
end

function FriendMgr:setFriendsRedDot()
    for gid, friend in pairs(self.friendList) do
        if friend then
            friend.hasRedDot = 0
            if RedDotMgr:friendHasRedDot(gid) then
                friend.hasRedDot = 1
            end
        end
    end
end

function FriendMgr:MSG_FRIEND_ADD_CHAR(data)
    if data.count <= 0 then return end

    for i = 1, data.count do
        self:updateFriends(data[i])
        local gid = data[i].gid
        if tonumber(data[i].group) == FRIEND_GROUP then
            self.recentFriends[gid] = gf:getServerTime()
            if RedDotMgr:hasRedDotInfo("tempFriendChat", gid) then
                RedDotMgr:insertOneRedDot("FriendChat", gid, nil, nil, true)
                if self.friendList[gid] then
                    self.friendList[gid].hasRedDot = 1
                end
            end
        elseif tonumber(data[i].group) == TEMP_GROUP then
            if RedDotMgr:hasRedDotInfo("FriendChat", gid) then
                RedDotMgr:insertOneRedDot("tempFriendChat", gid, nil, nil, true)
                if self.tempList[gid] then
                    self.tempList[gid].hasRedDot = 1
                end
            end
        end

        DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = data[i].group})
    end
end

-- 获取最近联系人（包含本次登录期间添加的好友及有消息往来的好友，目前用于邮寄）
function FriendMgr:getRecentFriends()
    return self.recentFriends
end

function FriendMgr:getRecentFriendsInfo()
    local rFriends = FriendMgr:getRecentFriends()
    local friendsInfo = {}
    for gid, time in pairs(rFriends) do
        local friend = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(gid))
        if friend then
            friend.group = 0
            friend.time = time
            table.insert(friendsInfo, friend)
        end
    end

    table.sort(friendsInfo, function(l, r)
        local lTime = rFriends[l.gid] or 0
        local rTime = rFriends[r.gid] or 0
        if lTime > rTime then return true end
        if lTime < rTime then return false end
    end)

    return friendsInfo
end

function FriendMgr:getRecentFriendObjs()
    local rFriends = FriendMgr:getRecentFriends()
    local friendObjs = {}
    for gid, time in pairs(rFriends) do
        local friend = FriendMgr:getFriendByGid(gid)
        if friend then
            table.insert(friendObjs, friend)
        end
    end

    return friendObjs
end

function FriendMgr:MSG_FRIEND_REMOVE_CHAR(data)
    -- 删除对应键的值
    local gid = data.gid
    local group = tonumber(data.group)
    local searchList = {}

    -- 找到对应的组别
    if FRIEDN_GROUP_ID[group]  then
        searchList = self.friendList
        if self.friendMemos and not CitySocialMgr:hasCityFriendByGid(gid) then
            self.friendMemos[gid] = nil
        end

        RedDotMgr:removeFriendRedDot(gid)
    elseif TEMP_GROUP == group then
        searchList = self.tempList

        RedDotMgr:removeChatRedDot(gid)
    elseif BLACK_GROUP == group then
        searchList = self.blackList
        if self.friendMemos then
            self.friendMemos[gid] = nil
        end
    end

    -- 遍历删除
    for k, v in pairs(searchList) do
        if gid == v:queryBasic("gid") then
            searchList[k] = nil
            break
        end
    end

    if self.friendsGroups[group] then
        self.friendsGroups[group][gid] = nil
    end

    DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = data.group})
end

function FriendMgr:MSG_FRIEND_NOTIFICATION(data)
    -- 获取friend
    local friend = self:getFriendByName(data.char)

    if nil == friend then return end

    local newData = { }
    newData.group = friend:queryBasic("group")
    newData.gid = friend:queryBasic("gid")
    newData.online = data.para
    newData.insider_level = data.insider_level

    self:updateFriends(newData)

    DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = friend:queryBasic("group")})
end

function FriendMgr:MSG_FRIEND_UPDATE_PARTIAL(data)
    if nil == data then return end

    self:updateFriends(data, data.update_type == 2)

    DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = data.group})
end

function FriendMgr:MSG_FINGER(data)

end

function FriendMgr:MSG_RECOMMEND_FRIEND(data)

end


function FriendMgr:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

function FriendMgr:MSG_CHAR_INFO_EX(data)
    if self.requestInfo and self.requestInfo.gid == data.gid then
        if self.requestInfo.requestDlg then
            if self.requestInfo.requestDlg == "isOpen" then
                if Me:queryBasic("gid") ~= data.gid then
                    local dlg = DlgMgr:openDlg("VisitingCardDlg")
                    dlg:MSG_CHAR_INFO(data)
                else
                    gf:ShowSmallTips(CHS[4101109]) -- 你无法查看自己的名片。
                end
            end
        end
        self.requestInfo = nil
    else

    end
end

function FriendMgr:MSG_CHAR_INFO(data)
    charMenuInfo[data.gid] = data

    -- 吸收最新数据
    local friend = self:getFriendByGid(data.gid)
    local tempFriend = self:getTemFriendByGid(data.gid)
    local freshData = {}
    freshData["party/name"] = data.party
    freshData["level"] = data.level
    freshData["insider_level"] = data.vip
    freshData["online"] = 1
    freshData["char"] = data.name
    freshData["icon"] = data.icon
    freshData["comeback_flag"] = data.comeback_flag
    freshData["recv_charinfo_time"] = gf:getServerTime()

    if nil ~= friend then
        friend:absorbBasicFields(freshData)
        DlgMgr:sendMsg("FriendDlg","updateSingleFriendData", FRIEND_GROUP, data.gid)
    end

    if nil ~= tempFriend then
        tempFriend:absorbBasicFields(freshData)
        DlgMgr:sendMsg("FriendDlg","updateSingleFriendData", TEMP_GROUP, data.gid)
    end

    if self.requestInfo and self.requestInfo.gid == data.gid then

        if self.requestInfo.requestDlg then
            if 'function' == type(self.requestInfo.requestDlg) then
                self.requestInfo.requestDlg(data.gid)
            else
                if self.requestInfo.requestDlg == "isOpen" then
                    if Me:queryBasic("gid") ~= data.gid then
                        local dlg = DlgMgr:openDlg("VisitingCardDlg")
                        dlg:MSG_CHAR_INFO(data)
                    else
                        gf:ShowSmallTips(CHS[4101109]) -- 你无法查看自己的名片。
                    end
                else
                    DlgMgr:sendMsg(self.requestInfo.requestDlg, "onCharInfo", data.gid)
                end
            end
        end
        self.requestInfo = nil
    end
end

-- 被添加为好友通知
function FriendMgr:MSG_BE_ADD_FRIEND(data)
    data.settingFlag = Bitset.new(data.setting_flag)
    if not FriendMgr:hasFriend(data.gid) then
        if GuideMgr:isRunning() then
            GuideMgr:closeCurrentGuide()
        end
        gf:confirm(string.format(CHS[2200024], data.name), function()
            FriendMgr:addFriendCheck(data)
        end, nil, nil, nil, nil, nil, nil, "be_add_friend")
    end
end

-- 播放消息声音
function FriendMgr:playMessageSound()
    SoundMgr:playHint("friend")
end

function FriendMgr:getFriendByGroupAndGid(group, gid)
    if group == TEMP_GROUP then
        return self.tempList[gid]
    elseif group == BLACK_GROUP then
        return self.blackList[gid]
    elseif FRIEDN_GROUP_ID[group] then
        return self.friendList[gid]
    end
end

function FriendMgr:isFriendGroup(group)
    if FRIEDN_GROUP_ID[group] then
        return true
    end
end

function FriendMgr:isTemFriendGroup(group)
    if group == TEMP_GROUP then
        return true
    end
end

function FriendMgr:isBlackGroup(group)
    if group == BLACK_GROUP then
        return true
    end
end

-- exceptGroupId排除的群组
function FriendMgr:getFriendGroupData(exceptGroupId)
    local data = {}

    if self.friendsGroupsInfo then
        for i = 1, #self.friendsGroupsInfo do
            local group = self:getFriendsGroupsInfoById(self.friendsGroupsInfo[i].groupId)

            if exceptGroupId then
                if group.groupId ~= exceptGroupId then
                    table.insert(data, group)
                end
            else
                table.insert(data, group)
            end
        end
    end

    return data
end

function FriendMgr:getFriendGroupsData()
    return self.friendsGroupsInfo
end

function FriendMgr:getFriendGroupByName(name)
    if self.friendsGroupsInfo then
        for i = 1, #self.friendsGroupsInfo do
            local group = self:getFriendsGroupsInfoById(self.friendsGroupsInfo[i].groupId)

            if group.name == name then
                return group
            end
        end
    end
end

function FriendMgr:getFriendGroupCount()
    if not self.friendsGroupsInfo then return 0 end
    return #self.friendsGroupsInfo
end

-- 获取创建好友分组的默认名字
function FriendMgr:getDefaultCreateGroupName()
    if not self.friendsGroupsInfo or #self.friendsGroupsInfo == 0 then return end
    for i = 1, 6 do
        local name = string.format(CHS[6000438], i)
        local isExist = false
        for i = 1, # self.friendsGroupsInfo do
            if self.friendsGroupsInfo[i].name == name then
                isExist = true
                break
            end
        end

        if not isExist then
            return name
        end
    end
end

function FriendMgr:getFriendsGroupsInfoById(groupId)
    if not self.friendsGroupsInfo then return end

    for i = 1, # self.friendsGroupsInfo do
        local groupInfo = self.friendsGroupsInfo[i]
        if groupInfo.groupId == groupId then
            local group = {}
            group.name = groupInfo.name
            group.groupId = groupInfo.groupId

            if not self.friendsGroups or not self.friendsGroups[tonumber(groupId)] then
                group.num, group.totalNum = 0, 0
            else
                group.num, group.totalNum = self:getOnlinAndTotaleCounts(self.friendsGroups[tonumber(groupId)])
            end

            return group
        end
    end
end

function FriendMgr:getOnlinAndTotaleCounts(list)
    local totalCounts = 0
    local onlineCounts = 0
    for _, v in pairs(list) do
        local online = v:queryBasicInt("online")
        if online == ONLINE then
            onlineCounts = onlineCounts + 1
        end

        totalCounts = totalCounts + 1
    end

    return onlineCounts, totalCounts
end

function FriendMgr:MSG_FRIEND_GROUP_LIST(data)
    self.friendsGroupsInfo = data.groups
end

function FriendMgr:MSG_FRIEND_MOVE_CHAR(data)
    if not self.friendsGroups[tonumber(data.fromId)] then self.friendsGroups[tonumber(data.fromId)] = {} end
    if not self.friendsGroups[tonumber(data.toId)] then self.friendsGroups[tonumber(data.toId)] = {} end
    local formFriendsGroup = self.friendsGroups[tonumber(data.fromId)]
    local toFriendsGroup = self.friendsGroups[tonumber(data.toId)]

    if formFriendsGroup and toFriendsGroup then
        for i = 1, #data.gidList do
            local gid = data.gidList[i]
            local friend = formFriendsGroup[gid]
            if friend then
                friend:setBasic("group", data.toId)
                toFriendsGroup[gid] = friend
                formFriendsGroup[gid] = nil
                    end
                end

        DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = data.fromId})
        DlgMgr:sendMsg("FriendDlg", "MSG_FRIEND_REFRESH_GROUP", {groupId = data.toId})
    end

end

function FriendMgr:MSG_FRIEND_ADD_GROUP(data)
    if self.friendsGroupsInfo then
        local group = {}
        group.groupId = data.groupId
        group.name = data.name
        table.insert(self.friendsGroupsInfo, group)
    end
end

function FriendMgr:MSG_FRINED_REMOVE_GROUP(data)
    if self.friendsGroups then
        local info = {}
        info.gidList = {}
        local group = self.friendsGroups[tonumber(data.groupId)]
        if group then
            for k, v in pairs(group) do
                table.insert(info.gidList, k)
            end

            info.fromId = data.groupId
            info.toId = "1"
            self:MSG_FRIEND_MOVE_CHAR(info)
            DlgMgr:sendMsg("FriendDlg","MSG_FRIEND_MOVE_CHAR", info)
            self.friendsGroups[tonumber(data.groupId)] = nil
        end
    end

    if self.friendsGroupsInfo then
        for i = 1, #self.friendsGroupsInfo do
            if self.friendsGroupsInfo[i] and  self.friendsGroupsInfo[i].groupId == data.groupId then
                table.remove(self.friendsGroupsInfo, i)
                break
            end
        end
    end
end

function FriendMgr:MSG_FRIEND_REFRESH_GROUP(data)
    if self.friendsGroupsInfo then
        for i = 1, #self.friendsGroupsInfo do
            if self.friendsGroupsInfo[i].groupId == data.groupId then
                self.friendsGroupsInfo[i].name = data.name
                break
            end
        end
    end
end

function FriendMgr:MSG_FRIEND_MEMO(data)
    if not self.friendMemos then
        self.friendMemos  = {}
    end

    for i = 1, data.count do
        local info = data.memos[i]
        self.friendMemos[info.gid] = info.memo
    end
end

function FriendMgr:getMemoByGid(gid)
    if not self.friendMemos then return "" end
    return self.friendMemos[gid] or ""
end

function FriendMgr:sortFunc(l, r)
    -- 排序逻辑
    l.lastChatTime = l.lastChatTime or 0
    r.lastChatTime = r.lastChatTime or 0
    l.hasRedDot = l.hasRedDot or 0
    r.hasRedDot = r.hasRedDot or 0
    l.index = l.index or 0
    r.index = r.index or 0

    if l.hasRedDot > r.hasRedDot then
        return true
    elseif l.hasRedDot < r.hasRedDot then
        return false
    end

    if l.lastChatTime > r.lastChatTime then
        return true
    elseif l.lastChatTime < r.lastChatTime then
        return false
    end

    if l.isOnline < r.isOnline then
        return true
    elseif l.isOnline > r.isOnline then
        return false
    end

    if l.isOnline ~= 2 then
        -- 离线不排vip
        if l.isVip > 0 and r.isVip <= 0 then
        return true
        elseif l.isVip <= 0 and r.isVip > 0 then
        return false
    end
    end

    if l.friendShip > r.friendShip then
        return true
    elseif l.friendShip < r.friendShip then
        return false
    end

    if l.index < r.index then
        return true
    elseif l.index > r.index then
        return false
    end

    return false
end

-- 群组信息
function FriendMgr:getChatGroupsData()
    --[[local data = {}
    data[1] = {}
    data[1].name = "园区"
    data[1].num = 60
    data[1].group_id = 3
    data[1].totalNum = 100
    data[2] = {}
    data[2].name = "霜吉格斯"
    data[2].num = 0
    data[2].totalNum = 100
    data[2].group_id = 3]]
    local data = {}

    for k, v in pairs(self.chatGroupsInfo) do
        table.insert(data, self:convertGroupInfo(v))
    end

    table.sort(data, function (l, r)
        return self:sortChatGroup(l,r)
    end)

    return data
end

-- 获取创建群组的默认名字
function FriendMgr:getDefaultCreateChatGroupName()
    for i = 1, 6 do
        local name = string.format(CHS[6400087], i)
        if not self:getGroupIdByName(name) then
            return name
        end
    end
end

function FriendMgr:getGroupIdByName(name)
    for k, v in pairs(self.chatGroupsInfo) do
        if v:queryBasic("group_name") == name then
            return v:queryBasic("group_id")
        end
    end
end

function FriendMgr:getChatGroupCount()
    local count = 0

    if self.chatGroupsInfo then
        for k, v in pairs(self.chatGroupsInfo) do
            if v:queryBasic("leader_gid") == Me:queryBasic("gid") then
                count = count + 1
            end
        end
    end

    return count
end

-- 从群组移除一个成员
function FriendMgr:removeMemberFromGroup(groupId, gid)
    gf:CmdToServer("CMD_REMOVE_MEMBER_TO_CHAT_GROUP", {groupId = groupId, gid = gid})
end

-- 修改群组的名字
function FriendMgr:reNameGroup(groupId, newName)
    gf:CmdToServer("CMD_MODIFY_CHAT_GROUP_NAME", {groupId = groupId, newName = newName})
end

-- 修改群公告
function FriendMgr:modifyGroupContent(groupId, content)
    gf:CmdToServer("CMD_MODIFY_CHAT_GROUP_ANNOUS", {groupId = groupId, content = content})
end

-- 群消息设置
function FriendMgr:setGroupSetting(groupId, setting)
    gf:CmdToServer("CMD_SET_CHAT_GROUP_SETTING", {groupId = groupId, setting = setting})
end

-- 解散群组
function FriendMgr:removeChatGroup(groupId)
    gf:CmdToServer("CMD_REMOVE_CHAT_GROUP", {groupId = groupId})
end

-- 邀请好友
function FriendMgr:inventeFriendToGroup(groupId, gidsListStr)
    gf:CmdToServer("CMD_INVENTE_CHAT_GROUP_MEMBER", {groupId = groupId, gidsListStr = gidsListStr})
end

-- 退出群组
function FriendMgr:quitChatGroup(groupId)
    gf:CmdToServer("CMD_QUIT_CHAT_GROUP", {groupId = groupId})
end

function FriendMgr:getMaxMemberNum()
    return CHAT_GROUP_MAX_MEMBER
end

-- 群组信息
function FriendMgr:MSG_CHAT_GROUP(data)
    -- 组成员数据
    for i = 1, data.count do
        self:updateGroupMember(data.members[i])
    end

    -- 群组基本信息
   -- table.insert(self.chatGroupsInfo, data.info)
    self:updateGroupInfo(data.info)
end

-- 刷新群组信息
function FriendMgr:MSG_CHAT_GROUP_PARTIAL(data)
    self:MSG_CHAT_GROUP(data)
end

function FriendMgr:updateGroupInfo(data)
    if not data or not data.group_id then
        return
    end

    if not self.chatGroupsInfo then self.chatGroupsInfo = {} end -- 所有组信息

    local group = self.chatGroupsInfo[data.group_id]

    if not group then
        group = DataObject.new()
        self.chatGroupsInfo[data.group_id] = group
    end

    group:absorbBasicFields(data)
end

-- 获取群主的基本信息
function FriendMgr:getChatGroupInfoById(groupId)
    if self.chatGroupsInfo then
        return self.chatGroupsInfo[groupId]
    end
end

-- 获取某个群上线人数和总的数量
function FriendMgr:getOnlinAndTotaleCountsByGroup(groupId)
    local group =  FriendMgr:getGroupByGroupId(groupId)
    local online, total = FriendMgr:getOnlinAndTotaleCounts(group)
    return online, total
end

-- 判断是否是群组
function FriendMgr:isGroupLeaderByGroupIdAndGid(groupId, gid)
    local group = self.chatGroupsInfo and self.chatGroupsInfo[groupId]
    if group then
        if group:queryBasic("leader_gid") == gid then
            return true
        end
    end
end

function FriendMgr:convertGroupInfo(data)
    if not data then return end
    local info = {}
    info.group_id = data:queryBasic("group_id")
    info.group_name = data:queryBasic("group_name")
    info.leader_gid = data:queryBasic("leader_gid")
    info.create_time = data:queryBasicInt("create_time")
    info.announcement = data:queryBasic("announcement")
    info.icon = data:queryInt("icon")
    info.lastChatTime = data.lastChatTime or 0

    return info
end

function FriendMgr:updateGroupMember(data)
    if not data or not data.member_gid then
        return
    end

    if not self.chatGroupsMember then self.chatGroupsMember = {} end -- 所有组成员
    if not self.chatGroupsMember[data.group_id] then  self.chatGroupsMember[data.group_id] = {} end -- 具体组的成员

    local list = self.chatGroupsMember[data.group_id]

    local  member = list[data.member_gid]
    if not member then
        member = DataObject.new()
        list[data.member_gid] = member
        DlgMgr:sendMsg("FriendDlg", "MSG_CHAT_GROUP_PARTIAL", {groupId = data.group_id}) -- 刷新组信息
    end

    member:absorbBasicFields(data)
end

function FriendMgr:MSG_CHAT_GROUP_MEMBERS(data)
    self:updateGroupMember(data)
end

function FriendMgr:getGroupByGroupId(groupId)
    if self.chatGroupsMember and self.chatGroupsMember[groupId] then
        return self.chatGroupsMember[groupId]
    end

    return {}
end

-- 群消息是否需要信息提示
function FriendMgr:isNeedMsgTipByGroupId(groupId)
    local member =  FriendMgr:getMyMeberInfoByGroupId(groupId)
    local isOn = false
    if member and member.setting == 1 then
        isOn = true
    end

    return isOn
end

function FriendMgr:getMyMeberInfoByGroupId(groupId)
    return FriendMgr:getMemberByGroupIdAndGid(groupId, Me:queryBasic("gid"))
end

-- 找群成员信息
function FriendMgr:getMemberByGroupIdAndGid(groupId, gid)
    local group = self:getGroupByGroupId(groupId)
    local members = {}
    local learder = nil
    for k, v in pairs(group) do
        if v:queryBasic("member_gid") == gid then
            return FriendMgr:convertToGroupMemberData(v)
        end
    end
end

function FriendMgr:getMembersByGroupId(groupId)
    local groupInfo = self:getChatGroupInfoById(groupId)
    local group = self:getGroupByGroupId(groupId)
    if not group then return end
    local members = {}
    local learder = nil
    for k, v in pairs(group) do
        if v:queryBasic("member_gid") ~= groupInfo:queryBasic("leader_gid") then -- 群主排在第一个
            table.insert(members, FriendMgr:convertToGroupMemberData(v))
        else
            learder = FriendMgr:convertToGroupMemberData(v)
        end
    end

    table.sort(members, function(l, r) return self:sortGroupMember(l, r) end)


    if learder then
        table.insert(members, 1, learder)
    end

    return members
end

function FriendMgr:sortGroupMember(l, r)
    if l.isOnline < r.isOnline then
        return true
    elseif  l.isOnline == r.isOnline and l.isVip > r.isVip then
        return true
    elseif l.isOnline == r.isOnline and l.isVip == r.isVip and l.friendShip > r.friendShip then
        return true
    else
        return false
    end

    return true
end

-- 将存储格式转换为使用的格式
function FriendMgr:convertToGroupMemberData(member)
    if nil == member then return end

    local groupId = member:queryBasic("group_id")
    local name = member:queryBasic("name")
    local icon = member:queryInt("icon")
    local party = member:queryBasic("party_name")
    local level = member:queryInt("level")
    local isVip = member:queryInt("insider_level")
    local isOnline = member:queryInt("online")
    local friendShip = member:queryInt("friend")
    local gid = member:queryBasic("member_gid")
    local setting = member:queryInt("setting")


    local member = {
        groupId = groupId,
        name = name,
        icon = icon,
        level = level,
        isVip = isVip,
        isOnline = isOnline,
        friendShip = friendShip,
        gid = gid,
        party = party,
        setting = setting,
    }

    return member
end


-- 删除群组
function FriendMgr:MSG_DELETE_CHAT_GROUP(data)
    if self.chatGroupsMember then
        self.chatGroupsMember[data.groupId] = nil
    end

    RedDotMgr:removeOneRedDot("GroupChat", data.groupId)

    if not self.chatGroupsInfo then  return end
    self.chatGroupsInfo[data.groupId] = nil
end

-- 删除群组成员
function FriendMgr:MSG_REMOVE_CHAT_GROUP_MEMBER(data)
    if self.chatGroupsMember and self.chatGroupsMember[data.groupId] then
        self.chatGroupsMember[data.groupId][data.memberId] = nil
        DlgMgr:sendMsg("FriendDlg", "MSG_CHAT_GROUP_PARTIAL", {groupId = data.groupId}) -- 刷新组信息
    end
end


-- 存储已邀请的群成员
function FriendMgr:setInviteMember(groupId, gidLsit)
    if not self.inviteMemberList then self.inviteMemberList = {} end
    if not self.inviteMemberList[groupId] then self.inviteMemberList[groupId] = {} end

    for k, v in pairs(gidLsit) do
        self.inviteMemberList[groupId][v] = v
    end
end

-- 删除已邀请成员
function FriendMgr:deleteInviteMember(groupId, gid)
	if self.inviteMemberList and  self.inviteMemberList[groupId] then
	   self.inviteMemberList[groupId][gid] = nil
	end
end

-- 是否已邀请
function FriendMgr:isInvited(groupId, memberId)
    if self.inviteMemberList and self.inviteMemberList[groupId]  and  self.inviteMemberList[groupId][memberId] then
        return true
    end
end

-- 是否是成员
function FriendMgr:isGroupMember(groupId, memberId)
    if self.chatGroupsMember and self.chatGroupsMember[groupId] and self.chatGroupsMember[groupId][memberId] then
        return true
    end
end

-- 好友分组上限
function FriendMgr:getMaxGroupCount()
    return MAX_GROUP
end

-- 群组上限
function FriendMgr:getMaxChatGroupCount()
    return MAX_CHAT_GROUP
end

function FriendMgr:sortChatGroup(l, r)
    if self:getGroupLeaderRight(l.leader_gid)> self:getGroupLeaderRight(r.leader_gid) then return true end
    if self:getGroupLeaderRight(l.leader_gid)< self:getGroupLeaderRight(r.leader_gid) then return false end
    if l.lastChatTime > r.lastChatTime  then return true end
    if l.lastChatTime < r.lastChatTime  then return false end

    return l.create_time > r.create_time
end

function FriendMgr:getGroupLeaderRight(learderGid)
    if Me:queryBasic("gid") == learderGid then
        return  1
    else
        return 0
    end
end

-- 玩家下线（需要更新最近联系人、好友的面板）
function FriendMgr:MSG_FIND_CHAR_MENU_FAIL(data)
    local friend = self:getFriendByGid(data.char_id)
    local tempFriend = self:getTemFriendByGid(data.char_id)
    local freshData = {}
    freshData["online"] = 2

    if nil ~= friend then
        friend:absorbBasicFields(freshData)
        local group = friend:queryBasicInt("group")
        if group == 0 then
            group = FRIEND_GROUP
    end

        DlgMgr:sendMsg("FriendDlg","updateSingleFriendData", group, data.char_id)
    end

    if nil ~= tempFriend then
        tempFriend:absorbBasicFields(freshData)
        DlgMgr:sendMsg("FriendDlg","updateSingleFriendData", TEMP_GROUP, data.char_id)
    end

    if self.requestInfo and self.requestInfo.gid == data.char_id then
        if self.requestInfo.requestDlg and self.requestInfo.needCallWhenFail then
            if 'function' == type(self.requestInfo.requestDlg) then
                self.requestInfo.requestDlg(data.char_id)
            else
                if self.requestInfo.requestDlg == "isOpen" then
                    --[[if Me:queryBasic("gid") ~= data.char_id then
                        local dlg = DlgMgr:openDlg("VisitingCardDlg")
                        dlg:MSG_CHAR_INFO(data)
                    else
                        gf:ShowSmallTips(CHS[4101109]) -- 你无法查看自己的名片。
                    end]]
                else
                    DlgMgr:sendMsg(self.requestInfo.requestDlg, "onCharInfo", data.char_id, true)
                end
            end
        end

        self.requestInfo = nil
    end
end

function FriendMgr:getVipWeight(vip)
    local weight = 0
    if vip >= 1 then
        weight = 1
    end

    return weight
end

function FriendMgr:MSG_ADD_FRIEND_OPER(data)
    local dlg = DlgMgr:openDlg("FriendOperationDlg")
    dlg:setCharInfo(data)
end

function FriendMgr:requestFriendOnlineState(gid, distName)
    gf:CmdToServer("CMD_REQUEST_TEMP_FRIEND_STATE", {gid = gid, dist_name = distName or ""})
end

function FriendMgr:MSG_TEMP_FRIEND_STATE(data)
    local temp = self:getTemFriendByGid(data.gid)
    local chatGid = DlgMgr:sendMsg("FriendDlg", "getCurChatGid")
    if temp and temp:queryBasicInt("online") ~= data.online then
        temp:setBasic("online", data.online)
        DlgMgr:sendMsg("FriendDlg","updateSingleFriendData", TEMP_GROUP, data.gid)
    elseif not self:hasFriend(data.gid) and chatGid == data.gid then
        -- 非最近联系人且非好友直接刷新聊天框在线状态
        DlgMgr:sendMsg("FriendDlg", "setFriendTips", data.online)
    end
end

function FriendMgr:saveChatInBackground()
    if gf:getServerTime() - lastSaveTime > 3 and self.hasNewMsgNotFlush then
        -- 切后台后，如果有新好友聊天消息，每隔 3 秒将好友聊天消息存入本地
        self:flushChatListToMem()
        lastSaveTime = gf:getServerTime()
    end
end

function FriendMgr:isKuafDist(distName)
    if GameMgr:IsCrossDist() then
        -- 跨服区组中不做跨服对象的判断
        return
    end

    if not string.isNilOrEmpty(distName) and distName ~= GameMgr:getDistName() then
        return true
    end
end

function FriendMgr:setKuafObj(gid, dist)
    if FriendMgr:isKuafDist(dist) then
        -- 跨服区组中不做跨服对象的判断
        self.kuafObjDist[gid] = dist
    end
end

function FriendMgr:getKuafObjDist(gid)
    if GameMgr:IsCrossDist() then
        -- 跨服区组中不做跨服对象的判断
        return
    end

    if self.kuafObjDist[gid] then
        return self.kuafObjDist[gid]
    end

    if BlogMgr:getDistByGid(gid) then
        if BlogMgr:getDistByGid(gid) and BlogMgr:getDistByGid(gid) ~= GameMgr:getDistName() then
            return BlogMgr:getDistByGid(gid)
        else
            return
        end
    end

    -- 最近联系人、黑名单中可能有跨服的对象
    local player = self:getPlayerObj(gid)
    if player then
        local dist = player:queryBasic("dist_name")
        if not string.isNilOrEmpty(dist) and dist ~= GameMgr:getDistName() then
            return dist
        end
    end
end

function FriendMgr:getPlayerObj(gid)
    if self.friendList[gid] then
        return self.friendList[gid]
    elseif self.tempList[gid] then
        return self.tempList[gid]
    else
        return self.blackList[gid]
    end
end

function FriendMgr:openCharMenu(data, type, rect, param)
    if data and data.gid ~= Me:queryBasic("gid") then
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")

        -- 设置为跨服对象
        FriendMgr:setKuafObj(data.gid, data.dist_name)

        FriendMgr:requestCharMenuInfo(data.gid)

        dlg:setMuneType(type, param)
        if FriendMgr:getCharMenuInfoByGid(data.gid) then
            dlg:setting(data.gid)
        else
            dlg:setInfo(data)
        end

        dlg:setFloatingFramePos(rect)
    end
end

function FriendMgr:MSG_LBS_ADD_FRIEND_TO_TEMP(data)
    if data.ret == 0 then
        gf:confirm(CHS[4300371],
        function ()
            -- body
            DlgMgr:sendMsg("ChatDlg", "onFriendButton")
            local dlg = DlgMgr:getDlgByName("FriendDlg")
            if dlg then dlg:addMagicForCity() end
        end)
        return
    end

    local charInfo = FriendMgr.kuafuInfoByGid[data.user_gid]
    if charInfo then
        --  把频道界面设置屏幕外
        local channelDlg = DlgMgr:getDlgByName("ChannelDlg")
        if channelDlg then
            channelDlg:moveToWinOutAtOnce()
        end

        local dlg = FriendMgr:openFriendDlg(true)
        dlg:setChatInfo({name = charInfo.name, gid = data.user_gid, icon = charInfo.icon, level = charInfo.level})

        RedDotMgr:removeChatRedDot(gid)
    end
end

-- 通知服务器已经阅读了 临时npc 发的信息
-- type 指定类型，为nil时认为通知阅读所有类型内容
-- npcGid 指定gid
function FriendMgr:doReadTempNpcMsg(type, npcGid)
    local sendInfo = {}
    local count = 0

    -- 聊天记录
    for k, v in pairs(self.chatData) do
        if k and FriendMgr:isNpcByGid(k) and (not npcGid or npcGid == k) then
            for i = 1, #v do
                if v[i].npcMsgId and not v[i].npcMsgHasRead and (not type or type == v[i].npcTellType) then
                    v[i].npcMsgHasRead = true
                    sendInfo[v[i].npcMsgId] = true
                    count = count + 1
                end
            end
        end
    end

    -- 临时好友聊天记录
    for k, v in pairs(self.tempCharMsg) do
        if k and FriendMgr:isNpcByGid(k) and (not npcGid or npcGid == k) then
            for i = 1, #v do
                if v[i].npcMsgId and not v[i].npcMsgHasRead and (not type or type == v[i].npcTellType) then
                    v[i].npcMsgHasRead = true
                    sendInfo[v[i].npcMsgId] = true
                    count = count + 1
                end
            end
        end
    end

    local ret = {}
    for k, v in pairs(sendInfo) do
        table.insert(ret, k)
    end

    ret.count = #ret

    if ret.count > 0 then
        gf:CmdToServer("CMD_REMOVE_NPC_TEMP_MSG", ret)
    end
end

-- 检查是否需要刷新 临时npc消息阅读情况
function FriendMgr:checkNeedDoNpcMsgRead(npcGid)
    if not self.friendDlg or not self.friendDlg.chatGid or self.friendDlg:isOutsideWin() then return end

    if npcGid and self:isNpcByGid(npcGid) and self.friendDlg.chatGid == npcGid then
        self:doReadTempNpcMsg(nil, npcGid)
    end
end

function FriendMgr:MSG_ADD_NPC_TEMP_MSG(data)
    -- 本地自己添加最近联系人后，再发消息请求服务端更新
    local friend = {}
    friend.group = TEMP_GROUP
    friend.char = data.name
    friend.icon = data.icon
    friend.gid = "npc_gid .. " .. tostring(data.icon) .. data.name

    if self.npcMsgIds[data.msgId] then return end
    self.npcMsgIds[data.msgId] = true

    -- 加入临时列表
    FriendMgr:updateFriends(friend)

    DlgMgr:sendMsg("FriendDlg", "refreshTempFriendForNpc", friend)

    local temp = {}
    temp.gid = "npc_gid .. " .. tostring(data.icon) .. data.name
    temp.id = Me:getId()
    temp.time = gf:getServerTime()

    if string.match(data.content, CHS[4010077]) then        -- "#G{ 前往客栈=innInfo=me}#n"
        temp.msg = string.gsub(data.content, CHS[4010077], CHS[4010078])    -- "#G{\9前往客栈=innInfo=me}#n"
    elseif string.match(data.content, CHS[7120171]) then    -- #G{9点击前往=petExplore=me}#n
        -- 宠物探险小队特殊处理消息发送时间
        temp.msg = string.gsub(data.content, CHS[7120171], CHS[7120172])    -- #G{\9点击前往=petExplore=me}#n
        temp.time = data.time
    elseif string.match(data.content, CHS[4200770]) then    -- #G{9点击前往=petExplore=me}#n
        temp.msg = string.gsub(data.content, CHS[4200770], CHS[4200771])    -- "#G{\9前往客栈=innInfo=me}#n"
    else
        temp.msg = data.content
    end

    temp.icon = data.icon
    temp.channel = CHAT_CHANNEL.FRIEND
    temp.name = data.name
    temp.orgLength = string.len(data.content)
    if data.type == NPC_TELL.INN then
        temp.cardCount = 1
        temp.cardList = {[1] = "innInfo=me"}
    end

    temp.voiceTime = 0
    temp.npcTellType = data.msgType
    temp.npcMsgId = data.msgId
    temp.npcMsgHasRead = false
    ChatMgr:MSG_MESSAGE_EX(temp)

    if data.type == NPC_TELL.INN then
        self:checkNeedDoNpcMsgRead(temp.gid)
    end
end


function FriendMgr:MSG_FRIEND_RECOMMEND_LIST(data)
    if self.notRecommendfInThisLogin and not DlgMgr:isDlgOpened("RecommendFriendDlg") then
        return
    end

    if data.count == 0 then
        return
    end

    local dlg = DlgMgr:openDlg("RecommendFriendDlg")
    dlg:setData(data)
end

EventDispatcher:addEventListener("EVENT_BACKGROUND_FRAME", FriendMgr.saveChatInBackground, FriendMgr)

MessageMgr:regist("MSG_FRIEND_RECOMMEND_LIST", FriendMgr)
MessageMgr:regist("MSG_LBS_ADD_FRIEND_TO_TEMP", FriendMgr)
MessageMgr:regist("MSG_ADD_NPC_TEMP_MSG", FriendMgr)
MessageMgr:regist("MSG_ADD_FRIEND_OPER", FriendMgr)
MessageMgr:regist("MSG_FRIEND_UPDATE_LISTS", FriendMgr)
MessageMgr:regist("MSG_FRIEND_ADD_CHAR", FriendMgr)
MessageMgr:regist("MSG_FRIEND_REMOVE_CHAR", FriendMgr)
MessageMgr:regist("MSG_FRIEND_NOTIFICATION", FriendMgr)
MessageMgr:regist("MSG_FRIEND_UPDATE_PARTIAL", FriendMgr)
MessageMgr:regist("MSG_FINGER", FriendMgr)
MessageMgr:regist("MSG_RECOMMEND_FRIEND", FriendMgr)
MessageMgr:regist("MSG_CHAR_INFO", FriendMgr)
MessageMgr:regist("MSG_CHAR_INFO_EX", FriendMgr)
MessageMgr:regist("MSG_OFFLINE_CHAR_INFO", FriendMgr)
MessageMgr:regist("MSG_ADD_FRIEND_VERIFY", FriendMgr)
MessageMgr:regist("MSG_BE_ADD_FRIEND", FriendMgr)
MessageMgr:regist("MSG_TEMP_FRIEND_STATE", FriendMgr)

-- 好友分组
MessageMgr:regist("MSG_FRIEND_GROUP_LIST", FriendMgr)
MessageMgr:regist("MSG_FRIEND_MOVE_CHAR", FriendMgr)
MessageMgr:regist("MSG_FRINED_REMOVE_GROUP", FriendMgr)
MessageMgr:regist("MSG_FRIEND_REFRESH_GROUP", FriendMgr)
MessageMgr:regist("MSG_FRIEND_ADD_GROUP", FriendMgr)
MessageMgr:regist("MSG_FRIEND_MEMO", FriendMgr)

-- 群组
MessageMgr:regist("MSG_CHAT_GROUP", FriendMgr)
MessageMgr:regist("MSG_CHAT_GROUP_MEMBERS", FriendMgr)
MessageMgr:regist("MSG_DELETE_CHAT_GROUP", FriendMgr)
MessageMgr:regist("MSG_REMOVE_CHAT_GROUP_MEMBER", FriendMgr)
MessageMgr:regist("MSG_CHAT_GROUP_PARTIAL", FriendMgr)
MessageMgr:regist("MSG_FIND_CHAR_MENU_FAIL", FriendMgr)

