

-- DistMgr.lua
-- created by zhengjh Sep/09/2015
-- 区组管理器

local PLATFORM_CONFIG = require("PlatformConfig")
local Bitset = require('core/Bitset')
DistMgr = Singleton("DistMgr")
local json = require('json')

local state_image =
    {
        [1] = ResMgr.ui.dist_state1, -- 维护
        [2] = ResMgr.ui.dist_state2, -- 正常
        [3] = ResMgr.ui.dist_state3, -- 繁忙
        [4] = ResMgr.ui.dist_state4, -- 爆满
        [5] = ResMgr.ui.dist_state4, -- 满员
        [6] = ResMgr.ui.dist_state2, -- 空
    }

local full_state_extra_image =
    {
        [4] = ResMgr.ui.dist_state_word1, -- 爆满
        [5] = ResMgr.ui.dist_state_word2, -- 满员
        [6] = ResMgr.ui.dist_state_word3, -- 空
    }

-- 需要为 nil ，不能为 false，否则初次调用  useReviewDist(false) 时登录界面中有可能选择的是评审区组
DistMgr.forReview = nil

-- 设置是否只显示评审区组信息
function DistMgr:useReviewDist(forReview)
    if self.forReview == forReview then
        -- 没有变化
        return
    end

    self.forReview = forReview

    -- 重新初始化默认选中的区组信息
    local loginDlg = DlgMgr:getDlgByName('UserLoginDlg')
    if loginDlg then
        local curSelDist = loginDlg:getLabelText("DistNameLabel")
        if self.forReview and self.reviewDistName and curSelDist ~= self.reviewDistName or
            not self.forReview and self.reviewDistName and curSelDist == self.reviewDistName then
            -- 使用的是评审区组但当前登录界面中使用的区组不是评审区组
            -- 或者使用的是普通区组但当前界面中使用的区组是评审区组
            -- 需要先清空上次登录信息
            local userDefault = cc.UserDefault:getInstance()
            userDefault:setStringForKey("lastLoginDist", "")
            userDefault:flush()
        end

        loginDlg:initDistInfo()
    end
end

-- 获取默认区组
function DistMgr:getDefaultDist()
    if self.forReview then
        return PLATFORM_CONFIG.REVIEW_DIST
    else
        return self.defaultInfo.dist
    end
end

-- 设置当前使用的账号
function DistMgr:setCurAccount(account)
    if type(PLATFORM_CONFIG.REVIEW_ACCOUNT) ~= 'table' then
        return
    end

    -- 判断是否为评审使用的账号，如果是则只显示评审区组信息
    for i = 1, #PLATFORM_CONFIG.REVIEW_ACCOUNT do
        if PLATFORM_CONFIG.REVIEW_ACCOUNT[i] == account then
            self:useReviewDist(true)
            return
        end
    end

    return self:useReviewDist(false)
end

-- 加载区组列表
function DistMgr:setDistList(distInfo)
    if not distInfo then return end

    local reviewDist
    if PLATFORM_CONFIG.REVIEW_DIST and string.len(PLATFORM_CONFIG.REVIEW_DIST) > 0 then
        -- 设置了评审区组，该区组信息需要单独存储
        if distInfo[PLATFORM_CONFIG.REVIEW_DIST] then
            reviewDist = distInfo[PLATFORM_CONFIG.REVIEW_DIST]
            reviewDist.name = PLATFORM_CONFIG.REVIEW_DIST
            reviewDist.isNew = true -- 默认为推荐区组
            self.reviewDistList = {{name = reviewDist.group, dists = {reviewDist}}}
            self.reviewGroups = {reviewDist.group}
            self.nameKeyReviewDistList = {[reviewDist.group] = {reviewDist}}
            self.reviewDistName = PLATFORM_CONFIG.REVIEW_DIST
            distInfo[PLATFORM_CONFIG.REVIEW_DIST] = nil
        end
    end

    --local distInfo = UpdateScene:getAllDistInfo()
    self.allDistInfo = distInfo
    self.defaultInfo = distInfo["default"]
    self.groups = distInfo["groups"]
    self.distList = {} -- 所有区的列表(用在排列时候大区顺序)
    self.nameKeyDistList = {}
    local userDefault = cc.UserDefault:getInstance()

    local distNum = userDefault:getIntegerForKey("distNum", 0)
    self.accountHaveRoleInfo = {}
    --self.haveRoleDist = {}
    for i = 1, distNum do
        local distStr = userDefault:getStringForKey("dist"..i, "")
        if distStr ~= "" then
        local dist = {}
        local list = gf:split(distStr, ",")
        local account = list[1]
        dist.name = list[2]
        dist.roleNum = list[3]
        dist.roleName = list[4]
        dist.icon = list[5]
        dist.level = list[6]
        dist.index = i
        if not self.accountHaveRoleInfo[account] then
            self.accountHaveRoleInfo[account] = {}
        end
        self.accountHaveRoleInfo[account][dist.name]  = dist
        --self.haveRoleDist[dist.name] = dist
        end
    end

    for i = 1, #self.groups do
        local group = {}
        group.name = self.groups[i]
        group.dists = {}
        table.insert(self.distList, group)
    end

    for k, v in pairs(distInfo) do
        if k ~= "default" and k ~= "groups" then
            if not self.nameKeyDistList[v.group] then
                self.nameKeyDistList[v.group] = {}
            end

            local hasFound = false
            for i =1, #self.distList do
                if v.group == self.distList[i].name then
                    v.name =k
                    v.index = v.index --or i
                    table.insert(self.nameKeyDistList[v.group], v)
                    table.insert(self.distList[i]["dists"], v)
                    hasFound = true
                    break
                end
            end

            if not hasFound then
                v.name =k
                v.index = v.index --or i
                table.insert(self.nameKeyDistList[v.group], v)
            end
        end
    end

    if Client and not string.isNilOrEmpty(Client:getRawAccount()) then
        -- 已经登录账号了，需要排序一下
        self:setHaveRoleDist(Client:getRawAccount())
    end

    if reviewDist then
        -- 添加评审区组信息
        self.allDistInfo[self.reviewDistName] = reviewDist
    end
end

-- 获取大区列表
function DistMgr:getGroupList()
    if self.forReview then
        return self.reviewGroups or {}
    end

    return self.groups
end

-- 根据区组名获取所在的大区
function DistMgr:getBigGroupNameByDist(distName)
    -- 看看推荐中有没有
    local recommendInfo = DistMgr:getRecommendList()
    for _, data in pairs(recommendInfo) do
        if data.name == distName then
            return CHS[3002918]
        end
    end

    local data = DistMgr:getDistInfoByName(distName)
    if data then return data.group end
end

-- 获取区组列表
function DistMgr:getDistList()
    if self.forReview then
        return self.reviewDistList or {}
    end

    return self.distList or {}
end

-- 获取某个大区的列表
function DistMgr:getNameKeyList()
    if self.forReview then
        return self.nameKeyReviewDistList or {}
    end

    return self.nameKeyDistList
end

-- 获取已有角色区组列表
function DistMgr:getHasRoleDistList(data)
    if not data then return end
    local distList = {}
    if not self.accountHaveRoleInfo then
        self.accountHaveRoleInfo = {}
    end

    local userDefault = cc.UserDefault:getInstance()
    local distNum = userDefault:getIntegerForKey("distNum", 0)
    local index = distNum + 1
    local dists = {}
    local charOfDists = {}
    for i = 1, #data do
        local curData = data[i]
        local distName = curData["dist"]
        if not self.forReview or distName == PLATFORM_CONFIG.REVIEW_DIST then
            local account = curData["account"]
            local dist = self:getDistInfoByName(distName, true) -- 直接查询，不需要在不存在时返回默认区组
            if PLATFORM_CONFIG.REVIEW_DIST == distName and self.reviewDistList and #(self.reviewDistList) > 0 then
                dist = self.reviewDistList[1].dists[1]
            end

            -- 区组信息
            if dist then
                if not dists[distName] then
                    table.insert(distList, dist)
                    dists[distName] = 1
                else
                    dists[distName] = (dists[distName] or 1) + 1
                end

                -- 角色信息
                local level = curData["level"]
                if charOfDists then
                    if not charOfDists[distName] or charOfDists[distName].level < level then
                        charOfDists[distName] = curData
                    end

                    -- 更新角色数量
                    charOfDists[distName].roleNum = dists[distName]
                end
            end
        end
    end

    local function sortDist(a, b)
        if dists[a.name] > dists[b.name] then return true end
        if dists[a.name] < dists[b.name] then return false end

        if a.index and not b.index then return true end
        if not a.index and b.index then return false end
        if a.index and b.index then return a.index < b.index end

        return a.name < b.name
    end

    table.sort(distList, sortDist)

    return distList, charOfDists
end

-- 获取推荐列表
function DistMgr:getRecommendList()
    local recommendList = {}
    for i = 1, #self:getDistList() do
        local dists = self:getDistList()[i]["dists"]
        for j = 1, #dists do
            if (self:getDistRoleNum(dists[j].name)  > 0) or (dists[j].isNew and not dists[j].not_recommend )  then
                dists[j].index = dists[j].index --or i
                table.insert(recommendList, dists[j])
            end
        end
    end

    local function sortDist(a, b)
        if self:getDistRoleNum(a.name) > self:getDistRoleNum(b.name) then return true end
        if self:getDistRoleNum(a.name) < self:getDistRoleNum(b.name)then return false end

        if self:getIsNewOrder(a.isNew) > self:getIsNewOrder(b.isNew)  then return true end
        if self:getIsNewOrder(a.isNew) < self:getIsNewOrder(b.isNew)  then return false end

        if a.index and not b.index then return true end
        if not a.index and b.index then return false end
        if a.index and b.index then return a.index < b.index end

        return a.name < b.name
    end

    table.sort(recommendList, sortDist)


    return recommendList
end

function DistMgr:sortNormalDist(list)
    local function sortDist(a, b)
        if self:getDistRoleNum(a.name) > self:getDistRoleNum(b.name) then return true end
        if self:getDistRoleNum(a.name) < self:getDistRoleNum(b.name)then return false end

        if self:getIsNewOrder(a.isNew) > self:getIsNewOrder(b.isNew)  then return true end
        if self:getIsNewOrder(a.isNew) < self:getIsNewOrder(b.isNew)  then return false end

        if a.index and not b.index then return true end
        if not a.index and b.index then return false end
        if a.index and b.index then return a.index < b.index end

        return a.name < b.name
    end

    table.sort(list, sortDist)
end


-- 获取登录后的推荐列表
function DistMgr:getGameRecommonedList()
    local gameRecommendList = {}
    local loginDistInfo = nil
    for i = 1, #self:getDistList() do
        local dists = self:getDistList()[i]["dists"]
        for j = 1, #dists do
            if dists[j].name == GameMgr:getDistName() then
                loginDistInfo = dists[j]
            elseif  (self:getDistRoleNum(dists[j].name)  > 0 or dists[j].isNew) then
                -- dists[j].index = i
                table.insert(gameRecommendList, dists[j])
            end
        end
    end

    local function sortDist(a, b)
        if self:getDistRoleNum(a.name) > self:getDistRoleNum(b.name) then return true end
        if self:getDistRoleNum(a.name) < self:getDistRoleNum(b.name)then return false end

        if self:getIsNewOrder(a.isNew) > self:getIsNewOrder(b.isNew)  then return true end
        if self:getIsNewOrder(a.isNew) < self:getIsNewOrder(b.isNew)  then return false end

        if a.index and not b.index then return true end
        if not a.index and b.index then return false end
        if a.index and b.index then return a.index < b.index end

        return a.name < b.name
    end

    table.sort(gameRecommendList, sortDist)

    if loginDistInfo then
        table.insert(gameRecommendList, 1, loginDistInfo)
    end

    return gameRecommendList
end


-- 获取权重
function DistMgr:getIsNewOrder(isNew)
    if isNew then
        return 1
    else
        return 0
    end
end

-- 换账号重置角色缓存的信息
function DistMgr:setHaveRoleDist(account)
    if not self.accountHaveRoleInfo then
        self.accountHaveRoleInfo = {}
    end
    self.haveRoleDist = self.accountHaveRoleInfo[account] or {}

    -- 排序区组
    if not self.nameKeyDistList then  return end
    for k, v in pairs(self.nameKeyDistList) do
        self:sortNormalDist(v)
    end

end

-- 获取每个区的人数
function DistMgr:getDistRoleNum(disName)
    if self.haveRoleDist and self.haveRoleDist[disName] then
        return tonumber(self.haveRoleDist[disName].roleNum)
    else
        return 0
    end
end

-- 获取角色数据
function DistMgr:getHaveRoleInfo(distName)
    if not self.haveRoleDist then
        return
    end

    return self.haveRoleDist[distName] or (self.allDistChars and self.allDistChars[distName])
end

-- 设置登录角色信息
function DistMgr:setLoginInfo()
    DistMgr:clearDistRoleInfo()
    if not self.haveRoleDist then
        self.haveRoleDist = {}
    end
    local userDefault = cc.UserDefault:getInstance()
    local distName = GameMgr:getDistName()
    if self.haveRoleDist[distName] then
        -- 刷新信息
        if  self.haveRoleDist[distName].roleName == Me:queryBasic("name") then
            self.haveRoleDist[distName].level = Me:queryBasicInt("level")
            self.haveRoleDist[distName].icon = Me:queryBasicInt("icon")
        else
            self.haveRoleDist[distName].roleName = Me:queryBasic("name")
            self.haveRoleDist[distName].level =  Me:queryBasicInt("level")
            self.haveRoleDist[distName].icon = Me:queryBasicInt("icon")
            --self.haveRoleDist[distName].roleNum = self.haveRoleDist[distName].roleNum + 1
        end

        self:refreshUserDefalut(self.haveRoleDist[distName])
    else
        local distNum = userDefault:getIntegerForKey("distNum", 0)
        userDefault:setIntegerForKey("distNum", distNum+1)
        self.haveRoleDist[distName] = {}
        self.haveRoleDist[distName].name = GameMgr:getDistName()
        self.haveRoleDist[distName].roleNum = 1
        self.haveRoleDist[distName].roleName = Me:queryBasic("name")
        self.haveRoleDist[distName].icon = Me:queryBasicInt("icon")
        self.haveRoleDist[distName].level = Me:queryBasicInt("level")
        self.haveRoleDist[distName].index = distNum + 1
        -- local distStr = GameMgr:getDistName()..",".."1"..","..Me:queryBasic("name")..","..Me:queryBasicInt("icon")..","..Me:queryBasicInt("level")
        -- userDefault:setStringForKey("dist"..(distNum + 1), distStr)
        self:refreshUserDefalut(self.haveRoleDist[distName])
    end
end

-- 刷新当前登录区组本地区组信息
function DistMgr:refreshHaveRole(distName, count)
    if self.haveRoleDist and self.haveRoleDist[distName] then
        self.haveRoleDist[distName].roleNum = count
        self:refreshUserDefalut(self.haveRoleDist[distName])
    end
end

-- 更新本地存储人物等级
function DistMgr:refreshHaveRoleLevel(distName, level)
    if self.haveRoleDist and self.haveRoleDist[distName] then
        self.haveRoleDist[distName].level = level
        self:refreshUserDefalut(self.haveRoleDist[distName])
    end
end

-- 更新userDefault
function DistMgr:refreshUserDefalut(distRoleInfo)
    local userDefault = cc.UserDefault:getInstance()

    if distRoleInfo.name then
        local distStr = Client:getAccount() .. "," .. distRoleInfo.name ..","..distRoleInfo.roleNum..","..distRoleInfo.roleName..","..distRoleInfo.icon..","..distRoleInfo.level
        userDefault:setStringForKey("dist"..(distRoleInfo.index), distStr)

        local lastLoginDist = distRoleInfo.name..","..distRoleInfo.roleName
        userDefault:setStringForKey("lastLoginDist", lastLoginDist)
    else
        userDefault:setStringForKey("dist"..(distRoleInfo.index), "")
  --      userDefault:setStringForKey("lastLoginDist", "")
    end
end

function DistMgr:refreshLastLoginDist(distName, roleName)
    local userDefault = cc.UserDefault:getInstance()
    local lastLoginDist = distName..","..roleName
    userDefault:setStringForKey("lastLoginDist", lastLoginDist)
end

-- 获取被合并到区组名
function DistMgr:getMergeToDistName(distName)
    local distInfo = self.allDistInfo[distName]
    if distInfo and distInfo["mergeToDist"] then
        return distInfo["mergeToDist"]
    end
end

-- 请求链接aaa
function DistMgr:connetAAA(distName, isNeedLoginAAA, isNeedLoginGS)
    local distInfo = self.allDistInfo[distName]
    if distInfo and distInfo["aaa"] then
        local function connet(distName)
            if distName ~= Client:getWantLoginDistName() then
                Client:setWaitData()
            end

            if distName == Client:getWantLoginDistName() and  Client._isConnectingGS then
                return
            end

            local newDistInfo = self.allDistInfo[distName]
            Client:connetAAA(newDistInfo["aaa"], true, isNeedLoginGS )
            Client:clearCharListInfo()
            Client:setWantLoginDistName(distName)
        end

        local mergeName = self:getMergeToDistName(distName)
        if mergeName and not DlgMgr:sendMsg("LoginChangeDistDlg", "checkHideMergeTip", distName) then
            local tip = string.format(CHS[6400078], distName, mergeName, distName, mergeName)
            local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
            dlg:setTip(tip)
            dlg:setCallFunc(function()
                performWithDelay(gf:getUILayer(), function()
                    connet(mergeName)
                    DlgMgr:closeDlg("OnlyConfirmDlg")
                end, 0)
            end)
        else
            connet(mergeName or distName)
        end
    end
end

-- 区组刷新是否需要连接AAA
function DistMgr:isNeedConnectAAA(distName)
    Client:setWantLoginDistName(distName)
    if not self:getDistRoleInfo(distName) then
        return true
    else
        return false
    end
end

function DistMgr:getDistInfoByName(name, excludeDefault)
    if not self.allDistInfo then return end
    local dist = self.allDistInfo[name]
    if not dist and not excludeDefault then
         return self.allDistInfo[self.defaultInfo["dist"]]
    end
    return dist
end

-- 获取某区组角色信息
function DistMgr:requireDistRoleInfo()
    if not self:getDistRoleInfo(Client:getWantLoginDistName()) then

        gf:CmdToAAAServer("CMD_L_GET_ACCOUNT_CHARS",
            {
                account = Client:getAccount(),
                auth_key = Client._authKey,
                dist = Client:getWantLoginDistName()
            }
        )
    end
end

-- 区组角色信息
function DistMgr:MSG_L_ACCOUNT_CHARS(data)
    if not self.DistRoleInfo then
        self.DistRoleInfo = {}
    end

    self.DistRoleInfo[data.distName] = data.roleList
    self:refreshHaveRole(data.distName, data.count)
    CommThread:stopAAA()
end

-- 获取区组角色信息
function DistMgr:getDistRoleInfo(distName)
    if self.DistRoleInfo then
        return self.DistRoleInfo[distName]
    end
end

-- 清除所有缓存aaa请求的区组角色信息
function DistMgr:clearDistRoleInfo()
    self.DistRoleInfo = {}
end

-- 获取默认区组
function DistMgr:getServerStateImage(state)
    return state_image[state] or state_image[1]
end

function DistMgr:getServerShowName(serverName)
    if nil == serverName then
        return "", ""
    end

    -- 与策划确认，服务器的线名将配置为“梦回问道99”，中间固定阿拉伯数字表示线数
    -- 策划新增，纯数字区组，增加返回chsServerId（如：chsServerId = "一线"）
    local distName = GameMgr:getDistName()
    local serverIdStr, matchTimes = string.gsub(serverName, distName, "")
    local serverId = ""
    if matchTimes == 0 then
        -- 试道专线、居所专线，serverName与distName不匹配
        distName = serverName
    else
        serverId = string.match(serverIdStr, CHS[7150061])
        if gf:isOnlyDigital(distName) then
            -- 纯数字区组
            serverId = gf:chsToNumber(serverId)
        else
            if serverId == nil then
                serverId = ""
            else
                serverId = tonumber(serverId)
            end

        end
    end

    return distName, serverId
end

-- 返回     区组与线路名称  标准显示格式下的字符串
function DistMgr:getServerShowStr(serverName)
    local distName, serverId = DistMgr:getServerShowName(serverName)
    if nil == distName or nil == serverId then return "" end
    if gf:isOnlyDigital(distName) then
        -- 纯数字，多空2个空格，且线路要用中文
        return string.format(CHS[3003706], distName .. "  ", gf:numberToChs(serverId))
    elseif gf:getTextLength(distName) == 6 then
        -- 三个汉字要多空 2 个空格
        return string.format(CHS[3003706], distName .. "  ", tostring(serverId))
    else
        return string.format(CHS[3003706], distName, tostring(serverId))
    end
end

-- 判断id是否存在服务器列表中
function DistMgr:isServerIdExsit(id)
    local data = Client:getLineList()
    for k, v in pairs(data) do
        if v == id and string.match(k,"id(.+)") then
            return true
        end
    end

    return false
end

function DistMgr:getServerNameByServerId(id)
    local data = Client:getLineList()
    for k, v in pairs(data) do
        if v == id and string.match(k,"id(.+)") then
            local index = string.match(k,"id(.+)")
            return data["server" .. index]
        end
    end
end

function DistMgr:getIndexByServerId(id)
    local data = Client:getLineList()
    for k, v in pairs(data) do
        if v == id and string.match(k,"id(.+)") then
            local index = string.match(k,"id(.+)")
            return index
        end
    end
end

function DistMgr:getServerFullStateExtraImg(state)
    return full_state_extra_image[state]
end

function DistMgr:getCurMatchInfo()
    return self.teamMatchData
end

function DistMgr:setMatchInit()
    self.teamMatchData = nil
end

function DistMgr:setCurMatchInfo(data)
    self.teamMatchData = data
end

function DistMgr:swichLine(serverName)
    -- 换线
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3003712])
        return
    end

    -- 坐牢中
    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000072])
        return
    end

    if Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003713])
        return
    end

    if TeamMgr:inTeamEx(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[3003714])
        return
    end

    -- 有一般性界面存在
    if DlgMgr:isExsitGeneralDlg() then
        gf:ShowSmallTips(CHS[3003715])
        return
    end

    -- 是否在副本中
    if DugeonMgr:isInDugeon() and not MapMgr:getCurrentMapName() == CHS[4100734] then
        gf:ShowSmallTips(CHS[3003716])
        return
    end

    if (GameMgr:isShiDaoServer() or MapMgr:isInShiDao()) and not GMMgr:isGM() and not ShiDaoMgr:isSDJournalist() then
        gf:ShowSmallTips(CHS[5000237])
        return
    end

    if DistMgr:isInKFSDServer() then
        gf:ShowSmallTips(CHS[5400033])
        return
    end

    if not MapMgr:checkSwitchLine() then
        gf:ShowSmallTips(CHS[2100051])
        return
    end

    self.lastLineName = GameMgr:getServerName()
    self.enterLineName = serverName
    Client:pushDebugInfo('SEND CMD_SWITCH_SERVER serverName = ' .. serverName)
    gf:CmdToServer("CMD_SWITCH_SERVER", {serverName = serverName})
    Client:setLoginChar(Me:queryBasic("name"))
end

-- 线路切换的通用处理
-- 进入或出跨服试道专线时，不做换线标记，要清除全部的数据
function DistMgr:switchServer(data, notFlagSwitch)
    local map = self:splitSwichServerInfo(data)
    Client._authKey = map.auth_key
    Client._ssLoginChar = map.char

    -- 保存当前队伍匹配的数据
    DistMgr:setCurMatchInfo(TeamMgr:getCurMatchInfo())
    if data.result == 1 then
        if not GameMgr:isInBackground() then
            -- 在后台不能调用UI相关操作
            DlgMgr:openDlg("WaitDlg")
        end

        if GameMgr.runtimeState == GAME_RUNTIME_STATE.MAIN_GAME then
            self:setIsSwichServer(not notFlagSwitch)
            SystemMessageMgr:setIsSwichServer(not notFlagSwitch)
        end

        -- self:setSwitchServerData(map)
        Client:MSG_L_AGENT_RESULT(map, true)
        self:swichLineColseDlg()
        CharMgr:clearAllChar()

        self.notClearChat = not notFlagSwitch

        if notFlagSwitch then
            -- notFlagSwitch 为 true 时，GameMgr:clearData 会调用该方法，此处不用重复调用
            RedDotMgr:cleanup()
        end

        GameMgr:clearData(not notFlagSwitch, Me:isInCombat() or Me:isLookOn())
    else
        gf:ShowSmallTips(data.msg)
    end
end

function DistMgr:splitSwichServerInfo(data)
    local list = gf:split(data.msg, ",")
    local map = {}
    map.ip = list[1]
    map.port = list[2]
    map.auth_key = list[3]
    map.seed = list[4]
    map.char = list[5]
    map.privilege = Me:queryBasicInt("privilege")
    map.result = 1
    map.msg = ""
    map.serverName = nil    -- 这个地方不需要设置服务器的名字，MSG_L_AGENT_RESULT中会做处理
    map.serverStatus = nil  -- 这个地方不需要设置服务器的状态，MSG_L_AGENT_RESULT中会做处理

    return map
end

-- 设置换线数据
function DistMgr:setSwitchServerData(map)
    self.switchData = map
end

-- 取换线数据
function DistMgr:getSwitchServerData()
    return self.switchData
end

-- 清除换线数据
function DistMgr:clearSwitchServerData()
    self.switchData = nil
end

-- 设置是否换线
function DistMgr:setIsSwichServer(isSwichServer)
    self.isSwichServer = isSwichServer
end


function DistMgr:getIsSwichServer()
    return self.isSwichServer
end

-- 特殊换线操作
function DistMgr:MSG_SPECIAL_SWITCH_SERVER(data)
    Client:pushDebugInfo('RECV MSG_SPECIAL_SWITCH_SERVER result=' .. tostring(data.result or 0) .. ', msg=' .. (data.msg or ''))
    self:switchServer(data)
end

-- 跨服换线
function DistMgr:MSG_SPECIAL_SWITCH_SERVER_EX(data)
    Client:pushDebugInfo('RECV MSG_SPECIAL_SWITCH_SERVER_EX result=' .. tostring(data.result or 0) .. ', msg=' .. (data.msg or ''))

    DlgMgr:closeOtherDlgs({
        ["MissionDlg"] = true,
        ["WaitDlg"] = true,
        ["LoadingDlg"] = true
    })

    self:switchServer(data, true)
end

function DistMgr:MSG_SWITCH_SERVER(data)
    Client:pushDebugInfo('RECV MSG_SWITCH_SERVER result=' .. tostring(data.result or 0) .. ', msg=' .. (data.msg or ''))
    self:switchServer(data)
end

function DistMgr:MSG_SWITCH_SERVER_EX(data)
    Client:pushDebugInfo('RECV MSG_SWITCH_SERVER_EX result=' .. tostring(data.result or 0) .. ', msg=' .. (data.msg or ''))
    self:switchServer(data)
end

-- 换线需要关闭的对话框
function DistMgr:swichLineColseDlg()
    DlgMgr:closeDlg("SystemSwitchLineDlg")

    -- 此处不进行关闭WaitDlg操作，因为此操作会
    -- 导致，客户端没有数据，玩家点击了一些界面，导致报错
    -- DlgMgr:closeDlg("WaitDlg")

    -- 关闭试道界面
    DlgMgr:closeDlg("ShidaoInfoDlg")

    -- 关闭宠物相关的界面

    DlgMgr:closeDlg("PetChangeDlg")
    DlgMgr:closeDlg("PetOneClickDevelopDlg")
    DlgMgr:closeDlg("PetDunWuBuyDlg")
    DlgMgr:closeDlg("PetOneClickYuhuaDlg")
    DlgMgr:closeDlg("PetDunWuDlg")

    DlgMgr:closeDlg("PetDressDlg")
    DlgMgr:closeDlg("PetChangeColorDlg")
    gf:closeConfirmByType("PetDressTabDlg")

    -- 查询队伍悬赏次数界面
    DlgMgr:closeDlg("RewardInquireDlg")

    -- 地劫奖励界面
    DlgMgr:closeDlg("DijFinishDlg")

    -- 投票界面
    DlgMgr:closeDlg("DugeonVoteDlg")
    DlgMgr:closeDlg("WatermelonDlg")
    DlgMgr:closeDlg("JiebVoteDlg")

    -- 居所家具购买界面
    DlgMgr:closeDlg("FurnitureBuyDlg")

    DlgMgr:closeDlg("HomeCookingDlg")

    -- 居所鲁班打造界面
    DlgMgr:closeDlg("FurnitureMakeDlg")

    -- 白玉观音像，金丝鸟笼，七宝如意界面
    DlgMgr:closeDlg("EffectFurnitureDlg")
    DlgMgr:closeDlg("EffectFurnitureRuleDlg")

    -- 通知确认框做些事情
    DlgMgr:sendMsg("ConfirmDlg", "onSwitchServer")
end

-- 换角色需要关闭换线不要关闭
function DistMgr:swichRoleCloseDlg()
    DlgMgr:closeDlg("RookieGiftDlg")
    DlgMgr:closeDlg("FastUseItemDlg")
    DlgMgr:closeDlg("ConvenientCallGuardDlg")
    DlgMgr:closeDlg("ChannelDlg")
    DlgMgr:closeDlg("ChatDlg")
    DlgMgr:closeDlg("SystemChangeDistDlg")
end

-- 是否内测区组
function DistMgr:isTestDist(distName)
    if not self.checkTestDistMap then
        self.checkTestDistMap = {}
    end

    if nil == self.checkTestDistMap[distName] then
        self.checkTestDistMap[distName] = (nil ~= (string.match(distName, CHS[6000239]) or string.match(distName, CHS[6000240])))
    end

    return self.checkTestDistMap[distName]
end

function DistMgr:curIsTestDist()
	return DistMgr:isTestDist(GameMgr:getDistName())
end

function DistMgr:MSG_CHAR_CHANGE_SEX()
    if self.haveRoleDist and self.haveRoleDist[GameMgr:getDistName()] then
        if self.haveRoleDist[GameMgr:getDistName()].roleName == Me:queryBasic("name") then
            self.haveRoleDist[GameMgr:getDistName()].icon = Me:queryBasic("icon")
            self:refreshUserDefalut(self.haveRoleDist[GameMgr:getDistName()])
        end
    end
end

-- WDSY-28005 增加公测区4月26之前屏蔽共鸣
function DistMgr:needIgnoreGongming()
    if not self:curIsTestDist() and gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime()) < CHS[7120054] then
        return true
    else
        return false
    end
end

function DistMgr:MSG_CS_SERVER_TYPE(data)
    local lastServerType = self.curServerType
    self.curServerType = data.server_type
    EventDispatcher:dispatchEvent(EVENT.CHANGE_CROSS_SERVER, {lastServerType = lastServerType,
        newServer = data.server_type})
end

-- 获取当前服务器类型跨服试道或其他
function DistMgr:getCurServerType()
    return self.curServerType
end

function DistMgr:isInKFZCServer()
    if self.curServerType == Const.CSL_COMPETE then
        return true
    end

    return false
end

function DistMgr:isHomeServer()
    return GameMgr:getServerName() == CHS[4200410]
end

function DistMgr:isInQcldServer()
    if self.curServerType == Const.QCLD_COMPETE then
        return true
    end

    return false
end

function DistMgr:isInQMPKServer()
    if self.curServerType == Const.QMPK_SERVER_TYPE then
        return true
    end

    return false
end

function DistMgr:isInKFSDServer()
    if self.curServerType == Const.KFSDDH_SERVER_TYPE or DistMgr:isInMKFSDServer() then
        return true
    end

    return false
end

-- 月道行跨服试道区组
function DistMgr:isInMKFSDServer()
    if self.curServerType == Const.MKFSD_SERVER_TYPE then
        return true
    end

    return false
end

-- 争霸娱乐
function DistMgr:isInZBYLServer()
    if self.curServerType == Const.ZBYL_COMPETE then
        return true
    end

    return false
end

-- 跨服战场2019
function DistMgr:isInKFZC2019Server()
    if self.curServerType == Const.MKFZC_SERVER_TYPE then
        return true
    end

    return false
end


-- 跨服竞技
function DistMgr:isInKFJJServer()
    if self.curServerType == Const.KFJJDH_SERVER_TYPE then
        return true
    end

    return false
end

-- 名人争霸
function DistMgr:isInMRZBServer()
    if self.curServerType == Const.MRZF_SERVER_TYPE then
        return true
    end

    return false
end

function DistMgr:isInNSZBServer()
    return self.curServerType == Const.NSZB_COMPETE
end

function DistMgr:isInXMZBServer()
    return self.curServerType == Const.XMZB_COMPETE
end

-- 排行榜按钮有特殊需求
function DistMgr:checkCrossDistOpenRank()
    if GameMgr:IsCrossDist() and not GMMgr:isGM() then
        -- 跨服区组，并且不是GM
        if DistMgr:isInKFSDServer() and ShiDaoMgr:isKFSDJournalist() then  -- 跨服试道记者
            return true
        elseif DistMgr:isInKFZCServer() and KuafzcMgr:isKFZCJournalist() then -- 跨服战场记者
            return true
        elseif DistMgr:isInKFJJServer() and KuafjjMgr:isKFJJJournalist() then -- 跨服竞技记者
            return true
        elseif DistMgr:isInQMPKServer() and QuanminPKMgr:isQMJournalist() then -- 全名PK赛记者
            return true
        elseif MapMgr:isInMRZB() and (TaskMgr:isMRZBJournalist() or GMMgr:isWarAdmin(CHS[4300465])) then --名人争霸记者
            return true
        elseif DistMgr:isInZBYLServer() and TaskMgr:isMRZBJournalist() then --名人争霸记者
            return true
        elseif DistMgr:isInQcldServer() and TaskMgr:isQCLDJournalist() then --青城论道记者
            return true
        end

        return false
    else
        return true
    end
end

-- 需要检测是否跨服，不能操作时给提示
function DistMgr:checkCrossDist()
    if GameMgr:IsCrossDist() then
        gf:ShowSmallTips(CHS[5000267])
        return false
    end

    return true
end

function DistMgr:getDefaultInfo()
    return self.defaultInfo
end

-- 是否雷霆渠道
-- 雷霆渠道包含雷霆官方账号和从其他渠道转移过来的账号
function DistMgr:isOfficalDist()
    if not self.isOfficalDist then
        return LeitingSdkMgr:isLeiting()
    else
        return 1 == self.isOffical
    end
end

function DistMgr:MSG_OFFICIAL_DIST(data)
    self.isOffical = data.isOffical
end

MessageMgr:hook("MSG_CHAR_CHANGE_SEX", DistMgr, "DistMgr")

MessageMgr:regist("MSG_L_ACCOUNT_CHARS", DistMgr)
MessageMgr:regist("MSG_SWITCH_SERVER", DistMgr)
MessageMgr:regist("MSG_SWITCH_SERVER_EX", DistMgr)
MessageMgr:regist("MSG_SPECIAL_SWITCH_SERVER", DistMgr)
MessageMgr:regist("MSG_SPECIAL_SWITCH_SERVER_EX", DistMgr)
MessageMgr:regist("MSG_CS_SERVER_TYPE", DistMgr)
MessageMgr:regist("MSG_OFFICIAL_DIST", DistMgr)

return DistMgr
