-- CitySocialMgr.lua
-- created by huangzz Feb/28/2018
-- 同城社交管理器

CitySocialMgr = Singleton()

local DataObject = require("core/DataObject")
local Json = require('json')
local Bitset = require("core/Bitset")

local LOCATE_SPACE_TIME = 600 -- 自动定位间隔至少 10 分钟定位

local LOCATION_LISTEN_MAX_TIME = 15 -- 定位有效时间 15s，超过停止定位

local LEVEL_LIMIT = 70
local LEVEL_LIMIT_TEST = 75

local LOCATION_LIMIT_WORD = 8 -- 地址最多显示 8个字

local locationStartTime = 0

CitySocialMgr.userInfo = {}
CitySocialMgr.friendList = {}
CitySocialMgr.verifyMsg = {}

-- 请求附近的人数据
function CitySocialMgr:requestOpenCity()
    self.userInfo = {}
    self.hasFriendList = false
    self.canOpenCityDlg = false

    gf:CmdToServer("CMD_LBS_REQUEST_OPEN_DLG", {})
end

-- 请求附近的人数据
function CitySocialMgr:requestNearbyInfo(sex)
    gf:CmdToServer("CMD_LBS_SEARCH_NEAR", {sex = sex})
end

-- 通知服务端玩家地理位置
function CitySocialMgr:cmdLocationInfo(location, lat, lng, type, result)
    local text = gfUTF8ToGBK(location) .. " #@#@# " .. string.format("%d", (lat * 1000000)) .. " #@#@# ".. string.format("%d", (lng * 1000000))
    local locationStr = gfEncrypt(text, tostring(Me:getId()))
    gf:CmdToServer("CMD_LBS_CHANGE_LOCATION", {location = locationStr, type = type, result = result})
end

-- 取消位置共享
function CitySocialMgr:requestDisShare()
    gf:CmdToServer("CMD_LBS_DISABLE_BE_SEARCH")
end

-- 请求区域排行榜数据
function CitySocialMgr:requestRankInfo(type)
    gf:CmdToServer("CMD_LBS_RANK_INFO", {type = type})
end

-- 发送好友验证消息
function CitySocialMgr:sendCityFriendCheck(name, gid, info)
    gf:CmdToServer("CMD_LBS_VERIFY_FRIEND", {name = name, gid = gid, message = info})
end

function CitySocialMgr:getUserData()
    return self.userInfo
end

-- 获取图像路径
function CitySocialMgr:getIcon(dlgName)
    local icon = self.userInfo.icon_img
    if string.isNilOrEmpty(icon) then
        return ResMgr:getBigPortrait(Me:queryBasicInt('icon'))
    else
        return icon
    end
end

-- 是否默认图标
function CitySocialMgr:isDefaultIcon()
    return string.isNilOrEmpty(self.userInfo.icon_img)
end

-- 获取审核标志
function CitySocialMgr:isReview(dlgName)
    return 1 == self.userInfo.under_review
end

-- 地理位置
function CitySocialMgr:getLocation()
    return self.userInfo.location
end

function CitySocialMgr:getLocationShowStr(str)
    if gf:getTextLength(str) > LOCATION_LIMIT_WORD * 2 then
        str = gf:subString(str, (LOCATION_LIMIT_WORD - 1) * 2) .. "..."
    end

    return str
end

function CitySocialMgr:hasLocation()
    if not string.isNilOrEmpty(CitySocialMgr:getLocation()) then
        return true
    end
end
-- 性别
function CitySocialMgr:getUserSex()
    return self.userInfo.sex
end

-- 年龄
function CitySocialMgr:getUserAge()
    return self.userInfo.age or -1
end

-- 获取共享位置失效时间
function CitySocialMgr:getShareEndTime()
    return self.userInfo.share_near_endtime or 0
end

-- 获取头像最后修改时间
function CitySocialMgr:getLastIconModifyTime()
    return self.userInfo.icon_img_ex_ti or 0
end

-- 获取某定位到我的定位的距离
function CitySocialMgr:getDistanceToMe(lat, lng)
    local myLat = self.userInfo.lat
    local myLng = self.userInfo.lng

    if not myLat or not myLng or not lat or not lng then
        return
    end

    return GpsMgr:getDistanceByLatLng(myLat, myLng, lat, lng)
end

-- 是否需要重新定位
function CitySocialMgr:needLocate()
    local userDefault = cc.UserDefault:getInstance()
    local userDefaultKey = "lastLoacteTimeCity" .. gf:getShowId(Me:queryBasic("gid"))
    local lastTime = userDefault:getIntegerForKey(userDefaultKey)
    local curTime = gf:getServerTime()
    if curTime - lastTime >= LOCATE_SPACE_TIME then
        userDefault:setIntegerForKey(userDefaultKey, curTime)
        return true
    end
end

function CitySocialMgr:setLocateTime()
    local userDefaultKey = "lastLoacteTimeCity" .. gf:getShowId(Me:queryBasic("gid"))
    cc.UserDefault:getInstance():setIntegerForKey(userDefaultKey, gf:getServerTime())
end

-- 上线时要自动定位
function CitySocialMgr:doLocateWhenLogin()
    local hasLocate = cc.UserDefault:getInstance():getBoolForKey("hasLoacte" .. gf:getShowId(Me:queryBasic("gid")), false)
    if hasLocate then
        self:startLocate(nil, nil, 1)
    end
end

function CitySocialMgr:stopLocate()
    GpsMgr:stopLocationListener()
    EventDispatcher:removeEventListener("updateLocation", self.updateLocationFunc)
    self.updateLocationFunc = nil

    if self.locateSch then
        gf:getUILayer():stopAction(self.locateSch)
    end

    self.locateSch = nil
    self.curLocateType = nil
end

-- 开启定位
-- type 1 登录时定位  2 打开界面/切换分页  3 手动定位
function CitySocialMgr:startLocate(func, dlg, type)
    self:stopLocate()

    self.updateLocationFunc = function()
        local latLng = GpsMgr:getLocation()
        if latLng and latLng.latitude and latLng.longitude then
            GpsMgr:getCityNameByLatAndLng(latLng.latitude, latLng.longitude, function(flag, info)
                self:stopLocate()
                if flag then
                    local cityInfo = GpsMgr:convertJsonInfoToCity(info)
                    if cityInfo and cityInfo ~= "" then
                        CitySocialMgr:cmdLocationInfo(cityInfo, latLng.latitude, latLng.longitude, type, 1)
                        self.userInfo.location = cityInfo
                        self.userInfo.lat = latLng.latitude
                        self.userInfo.lng = latLng.longitude

                        cc.UserDefault:getInstance():setBoolForKey("hasLoacte" .. gf:getShowId(Me:queryBasic("gid")), true)

                        if func then
                            -- 定位成功回调
                            func(dlg, 1, type)
                        end
                        return
                    end
                end

                CitySocialMgr:cmdLocationInfo("", 0, 0, type, 0)
                if func then
                    -- 定位失败回调
                    func(dlg, 0, type)
                end
            end)
        else
            self:stopLocate()

            if func then
                -- 定位失败回调
                func(dlg, 0, type)
            end
        end
    end

    if GpsMgr:tryOpenGpsLocation(self.updateLocationFunc, type == 1) or (gf:isWindows() and ATM_IS_DEBUG_VER) then
        self:startLocationCountDown(type)
        return true
    end

    return false
end

-- 是否正处于定位中
function CitySocialMgr:isLocating()
    if self.locateSch then
        return true
    end
end

function CitySocialMgr:getCurLocateType()
    return self.curLocateType
end

-- 开启定位文字效果
function CitySocialMgr:startLocationCountDown(type)
    local pointStr = {[0] = "   ", [1] = ".  ", [2] = ".. ", [3] = "..."}
    local startIndex = 1
    locationStartTime = gfGetTickCount()

    local time = LOCATION_LISTEN_MAX_TIME
    if type == 1 then
        -- 登录开启的定位
        time = time * 4
    end

    if not self.locateSch then
        self.curLocateType = type
        self.locateSch = schedule(gf:getUILayer(), function()
            local pointNum = startIndex % 4
            local dlg = DlgMgr:getDlgByName("CityInfoDlg")
            if dlg and type ~= 1 then
                dlg:setLabelText("AddressLabel", CHS[5400483] .. pointStr[pointNum], "AddressPanel", COLOR3.TEXT_DEFAULT)
            end

            startIndex = startIndex + 1

            if gfGetTickCount() - locationStartTime >= 1000 * time then
                -- 定位时间到上限，则认为定位失败
                self:stopLocate()

                CitySocialMgr:cmdLocationInfo("", 0, 0, type, 0)

                if type ~= 1 then
                    gf:ShowSmallTips(CHS[5400482])

                    if dlg then
                        dlg:doWhenLocationEnd()
                    end
                end
            end
        end, 0.2)
    end
end

function CitySocialMgr:getLevelLimit()
    return LEVEL_LIMIT, LEVEL_LIMIT_TEST
end

-- 检查是否可打开同城社交界面
function CitySocialMgr:checkOpenCityDlg()
    if GameMgr:IsCrossDist() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

    -- 若为公测区且当前角色等级<70级，则给予如下弹出提示
    if not DistMgr:curIsTestDist() and Me:getLevel() < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[5400497], LEVEL_LIMIT))
        return
    end

    -- 若为内测区且当前角色等级<75级，则给予如下弹出提示
    if DistMgr:curIsTestDist() and Me:getLevel() < LEVEL_LIMIT_TEST then
        gf:ShowSmallTips(string.format(CHS[5400497], LEVEL_LIMIT_TEST))
        return
    end

    -- 若当前账号尚未完成实名认证，则予以如下弹出提示
    if Me:getAdultStatus() == 2 then
        gf:ShowSmallTips(CHS[5400498])
        return
    end

    if gf:isWindows() and ATM_IS_DEBUG_VER then
        -- GPS 已开启
    else
        if not GpsMgr:tryOpenGpsLocation() then
            return
        end
    end

    return true
end

function CitySocialMgr:getLastSuccLocateTime()
    return self.lastSuccLocateTime or 0
end

-- 设置成功定位时间
function CitySocialMgr:setSuccLocateTime(time)
    self.lastSuccLocateTime = time
end

function CitySocialMgr:getLastRefreshNearbyTime()
    return self.lastRefreshNearbyTime or 0
end

-- 设置刷新附近的人数据时间
function CitySocialMgr:setRefreshNearbyTime(time)
    self.lastRefreshNearbyTime = time
end

-- 更新好友信息
-- 未打开过社交好友界面前，data 中只有 gid 信息。
function CitySocialMgr:updateCityFriends(data, onlyUpdate)
    if not data or not data.gid then
        return
    end

    -- 加入好友列表
    local friend = self.friendList[data.gid]

    data.updateTime = gf:getServerTime()
    if not friend then
        if onlyUpdate then
            return
        end

        friend = DataObject.new()
        self.friendList[data.gid] = friend
    else
        if nil == data.icon or data.icon == 0 then
            -- 过滤icon
            data.icon = nil
        end

        if nil == data.family or "N/A" == data.family or "" == data.family then
            -- 过滤帮派
            data.family = nil
        end
    end

    friend:absorbBasicFields(data)
end

function CitySocialMgr:getCityFriends()
    return CitySocialMgr:getFriendByList(self.friendList)
end

function CitySocialMgr:getCityFriendList()
    return self.friendList
end

function CitySocialMgr:getFriendByList(list)
    local friends = {}
    for _, v in pairs(list) do
        -- 将好友筛选出来
        local data = CitySocialMgr:convertToUserData(v)

        if data then
            table.insert(friends, data)
        end
    end

    return friends
end

-- 未打开过社交好友界面前，self.friendList[gid] 中只有 gid 信息。
function CitySocialMgr:getCityFriend(gid)
    return self.friendList[gid]
end

function CitySocialMgr:getCityFriendInfo(gid)
    return CitySocialMgr:convertToUserData(self.friendList[gid])
end

function CitySocialMgr:convertToUserData(friend)
    if nil == friend then return end

    local gid = friend:queryBasic("gid")
    local name = friend:queryBasic("char")
    local icon = friend:queryInt("icon")
    local dist_name = friend:queryBasic("dist_name")
    local level = friend:queryInt("level")
    local age = friend:queryInt("age")
    local sex = friend:queryInt("sex")
    local lastChatTime = friend.lastChatTime
    local location = friend:queryBasic("location")
    local icon_img = friend:queryBasic("icon_img")

    if string.isNilOrEmpty(name) then
        -- 刚上线时会刷新区域好友列表，但只刷了 gid 数据
        return
    end

    local friend = {
        gid = gid,
        name = name,
        icon = icon,
        dist_name = dist_name,
        level = level,
        lastChatTime = lastChatTime,
        age = age,
        sex = sex,
        location = location,
        icon_img = icon_img
    }

    return friend
end

-- 未打开过社交好友界面前，self.friendList[gid] 中只有 gid 信息
function CitySocialMgr:hasCityFriendByGid(gid)
    if self.friendList[gid] then
        return true
    end
end

function CitySocialMgr:deleteCityFriend(gid)
    if not self:hasCityFriendByGid(gid) then return end
    gf:CmdToServer("CMD_LBS_REMOVE_FRIEND", {gid = gid})
end

-- from_type 通过什么界面发起的操作 1: 区域排行榜 2:附近的人 0:其他
function CitySocialMgr:addCityFriend(gid, from)
    gf:CmdToServer("CMD_LBS_ADD_FRIEND", {gid = gid, from_type = from})
end

-- 尝试添加好友
function CitySocialMgr:tryToAddCityFriend(name, gid, online)
    local type = 0
    if DlgMgr:isDlgOpened("CityRankingDlg") then
        type = 1
    elseif DlgMgr:isDlgOpened("CityNearbyDlg") then
        type = 2
    end

    if CitySocialMgr:hasCityFriendByGid(gid) then
        -- 如果已经是己方好友
        gf:confirm(string.format(CHS[5400507], gf:getRealName(name)), function()
            CitySocialMgr:deleteCityFriend(gid)
        end)
    else
        CitySocialMgr:addCityFriend(gid, type)
    end
end

function CitySocialMgr:setCityFriendLastChatTime(gid, time)
    local friend = self.friendList[gid]
    if friend then
        if not friend.lastChatTime or friend.lastChatTime < time then
            friend.lastChatTime = time
        end

        DlgMgr:sendMsg("CityFriendDlg", "updaetOneFriend", gid)
    end
end

function CitySocialMgr:updateVerifyMessage(data)
    if SystemMessageMgr.SYSMSG_STATUS.DEL == data.status  then
        self.verifyMsg[data.id] = nil
    else
        self.verifyMsg[data.id] = data
    end

    if next(self.verifyMsg) then
        if not SystemMessageMgr:getIsSwichServer() then
            if not DlgMgr:isDlgOpened("CityTabDlg") then
                RedDotMgr:insertOneRedDot("ChatDlg", "FriendButton")
                RedDotMgr:insertOneRedDot("FriendDlg", "CityDlgButton")
            end

            if not DlgMgr:isDlgOpened("CityFriendVerifyOperateDlg") then
                RedDotMgr:insertOneRedDot("CityTabDlg", "CityFriendCheckBox")
                RedDotMgr:insertOneRedDot("CityFriendDlg", "CityFriendButton")
            end
        end
    else
        if RedDotMgr:hasRedDotInfoByOnlyDlgName("CityFriendDlg") then
            RedDotMgr:removeOneRedDot("CityTabDlg", "CityFriendCheckBox")
            RedDotMgr:removeOneRedDot("CityFriendDlg", "CityFriendButton")
            RedDotMgr:removeOneRedDot("FriendDlg", "CityDlgButton")
        end
    end
end

-- 验证信息是否存在
function CitySocialMgr:hasVerifyMsgById(id)
    if self.verifyMsg[id] then
        return true
    end
end

-- 获取所有的验证信息
function CitySocialMgr:getVerifyMsgList()
    local data = {}

    for id, _ in pairs(self.verifyMsg) do
        local info = self:getOneVerifyMessage(id)
        if info then
            table.insert(data, info)
        end
    end

    return data
end

-- 解析单条验证数据
function CitySocialMgr:getOneVerifyMessage(id)
    if not self.verifyMsg[id] then
        return
    end

    local sysMsg = self.verifyMsg[id]
    local args1 = gf:split(sysMsg.attachment, ";")
    local args2 = gf:split(sysMsg.title, "@")

    local data = {
        id = id,
        type = sysMsg.type,
        msg = sysMsg.msg,
        create_time = sysMsg.create_time,
        status = sysMsg.status,

        name = sysMsg.sender,
        gid = args2[1],
        dist_name = args2[2],
        level = tonumber(args1[1]),
        icon = tonumber(args1[2]),
        icon_img = args1[3],
        age = tonumber(args1[4]) or -1,
        sex = tonumber(args1[5]),
    }

    return data
end

-- 操作验证申请消息
-- result 1 同意、0 拒绝
function CitySocialMgr:operFriendVerify(id, result)
    local sysMsg = CitySocialMgr:getOneVerifyMessage(id)
    if not sysMsg then return end

    local data = {}
    data.id = sysMsg.id
    data.char_name = sysMsg.name
    data.char_gid = sysMsg.gid
    data.result = result
    gf:CmdToServer("CMD_LBS_FRIEND_VERIFY_RESULT", data)
end

-- 通知客户端打开区域好友验证
function CitySocialMgr:MSG_LBS_ADD_FRIEND_VERIFY(data)
    local dlg = DlgMgr:openDlg("CityFriendVerificationDlg")
    dlg:setInfo(data)
end

function CitySocialMgr:MSG_LBS_FRIEND_LIST(data)
    self.hasFriendList = true

    for i = 1, data.count do
        self:updateCityFriends(data[i])
    end

    self:setLastChatTimebyMem()

    self:tryToOpenCity()
end

-- 将区域好友的最近交互时间记录存到本地
function CitySocialMgr:flushLastChatTimeToMem()
    local time = gf:getServerTime()
    DataBaseMgr:deleteItems("cityFriendData")
    for gid, v in pairs(self.friendList) do
        if v.lastChatTime and v.lastChatTime > 0 then
            local info = {}
            info.gid = gid
            info.lastChatTime = v.lastChatTime

            local value = Json.encode(info)

            DataBaseMgr:insertItem("cityFriendData", {json_para = value})
        end
    end
end

-- 从本地获取区域好友相关数据
function CitySocialMgr:setLastChatTimebyMem()
    local data = DataBaseMgr:selectItems("cityFriendData")
    for i = 1, data.count do
        local info = json.decode(data[i].json_para)
        local friend = self:getCityFriend(info.gid)
        if friend and (not friend.lastChatTime or friend.lastChatTime < info.lastChatTime) then
            friend.lastChatTime = info.lastChatTime
        end
    end

    DataBaseMgr:deleteItems("cityFriendData")
end


function CitySocialMgr:clearData(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        self.lastRefreshNearbyTime = 0
        self.lastLocateTime = 0

        self:stopLocate()

        CitySocialMgr:flushLastChatTimeToMem()

        self.friendList = {}

        self.verifyMsg = {}

        self.userInfo = {}

        self.nearPlayersInfo = nil
    end
end

-- 被添加为好友通知
function CitySocialMgr:MSG_LBS_BE_ADD_FRIEND(data)
    gf:confirm(string.format(CHS[5400506], gf:getRealName(data.name)), function()
        CitySocialMgr:addCityFriend(data.gid, 0)
    end)
end

-- 通知客户端添加好友成功
function CitySocialMgr:MSG_LBS_ADD_FRIEND_OPER(data)
    local dlg = DlgMgr:openDlg("CityFriendOperationDlg")
    dlg:setCharInfo(data)

    -- 添加好友
    self:updateCityFriends(data)

    self:setCityFriendLastChatTime(data.gid, gf:getServerTime())
end

-- 移除区域好友
function CitySocialMgr:MSG_LBS_REMOVE_FRIEND(data)
    if self.friendList[data.gid] and not FriendMgr:isBlackByGId(data.gid) then
        local str = string.format(CHS[5400508], gf:getRealName(self.friendList[data.gid]:queryBasic("char")))
        gf:ShowSmallTips(str)
        ChatMgr:sendMiscMsg(str)
    end

    -- 删除区域好友时要添加最近联系人
    local info = CitySocialMgr:getCityFriendInfo(data.gid)
    FriendMgr:addTempFriendByMsg(info)

    -- 移除备注
    if FriendMgr.friendMemos and not FriendMgr:hasFriend(data.gid) then
        FriendMgr.friendMemos[data.gid] = nil
    end

    self.friendList[data.gid] = nil
end

-- 尝试开启同城社交界面
function CitySocialMgr:tryToOpenCity()
    if self.canOpenCityDlg and self.userInfo.sex and self.userInfo.icon_img and self.hasFriendList then
        if CitySocialMgr:checkOpenCityDlg() then
            DlgMgr:openDlg("CityFriendDlg")
        end

        self.hasFriendList = false
        self.canOpenCityDlg = false
    end
end

-- 社交个人信息
function CitySocialMgr:MSG_LBS_CHAR_INFO(data)
    self.userInfo.sex = data.sex
    self.userInfo.age = data.age
    self.userInfo.location = data.location
    self.userInfo.lat = data.lat
    self.userInfo.lng = data.lng
    self.userInfo.share_near_endtime = data.share_near_endtime

    self:tryToOpenCity()
end

-- 个人空间中的头像信息
function CitySocialMgr:MSG_LBS_BLOG_ICON_IMG(data)
    self.userInfo.icon_img = data.icon_img
    self.userInfo.under_review = data.under_review

    self:tryToOpenCity()
end

function CitySocialMgr:MSG_LBS_REQUEST_OPEN_DLG(data)
    self.canOpenCityDlg = true
    self:tryToOpenCity()
end

-- 上线时收到的区域好友 gid 列表
function CitySocialMgr:MSG_LBS_FRIEND_GID_LIST(data)
    for i = 1, data.count do
        self:updateCityFriends(data[i])
    end
end

-- 获取附近的玩家的数据
function CitySocialMgr:getNearPlayerInfo()
    return self.nearPlayersInfo
end

function CitySocialMgr:reportIcon(gid, icon_img, dist)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[2000443])
        return
    end

    if string.isNilOrEmpty(icon_img) then
        gf:ShowSmallTips(CHS[2000444])
        return
    end

    gf:CmdToServer('CMD_BLOG_REPORT', { user_dist = dist, user_gid = gid, op_type = BLOG_OP_TYPE.BLOG_OP_REPORT_ICON, text = icon_img})
end

function CitySocialMgr:MSG_LBS_SEARCH_NEAR(data)
    self.userInfo.share_near_endtime = data.share_near_endtime

    self.nearPlayersInfo = data

    for i = 1, #data do
        local dist = math.floor(self:getDistanceToMe(data[i].lat, data[i].lng) or 0)
        data[i].distance = dist
    end

    table.sort(data, function(l, r)
        if l.distance < r.distance then return true end
        if l.distance > r.distance then return false end
    end)
end

function CitySocialMgr:checkCanShowCity()
    return self.cityEnable == 1
end

-- 同城功能开关
function CitySocialMgr:MSG_LBS_ENABLE(data)
    self.cityEnable = data.enable
end

MessageMgr:regist("MSG_LBS_SEARCH_NEAR", CitySocialMgr)
MessageMgr:regist("MSG_LBS_ENABLE", CitySocialMgr)
MessageMgr:regist("MSG_LBS_FRIEND_GID_LIST", CitySocialMgr)
MessageMgr:regist("MSG_LBS_CHAR_INFO", CitySocialMgr)
MessageMgr:regist("MSG_LBS_BLOG_ICON_IMG", CitySocialMgr)
MessageMgr:regist("MSG_LBS_REQUEST_OPEN_DLG", CitySocialMgr)
MessageMgr:regist("MSG_LBS_BE_ADD_FRIEND", CitySocialMgr)
MessageMgr:regist("MSG_LBS_ADD_FRIEND_OPER", CitySocialMgr)
MessageMgr:regist("MSG_LBS_FRIEND_LIST", CitySocialMgr)
MessageMgr:regist("MSG_LBS_ADD_FRIEND_VERIFY", CitySocialMgr)
MessageMgr:regist("MSG_LBS_REMOVE_FRIEND", CitySocialMgr)
