-- PartyMgr.lua
-- Created by songcw Mar/4/2015
-- 帮派管理器

PartyMgr = Singleton()

local PARTYL_LEVEL_PRIMARY = 1      -- 初级帮派
local PARTYL_LEVEL_MIDDLE  = 2      -- 中级
local PARTYL_LEVEL_SENIOR  = 3      -- 高级
local PARTYL_LEVEL_TOP     = 4      -- 顶级

local REPUTATION_PRIMARY   = 100    -- 帮派人口上限
local REPUTATION_MIDDLE    = 150
local REPUTATION_SENIOR    = 200
local REPUTATION_TOP       = 300

local PARTY_LEVEL_MAX               = math.floor(Const.PLAYER_MAX_LEVEL * 1.6)                   -- 帮派技能等级上限

local REQUEST_JOIN_PARTY             = "party"             -- 申请加入帮派
local REQUEST_JOIN_PARTY_REMOTE      = "party_remote"      -- 远程申请加入帮派
local REFUSE_LOW_JOIN_PARTY          = "refuse_low_join_party"  -- 申请入帮最低等级
local HERO_LEVEL_MIT                 = 85                  -- 人物等级上限

local JOB_KICKOUT          = -2     -- 开除
local JOB_UNCHANGED        = -1     -- 职位没有变动

local limitJoinPartyLevel = 25      -- 最低入帮等级

local inviteJoinList = {}           -- 被他人邀请入帮列表

local nameMin = 2                   -- 帮派名称长度限制

local PARTY_REDBAG_NUM = 20         -- 发红包的至少人数

local JOB_NAME_ID =
    {
        [CHS[3004177]] = 700,
        [CHS[3004178]] = 200,
        [CHS[3004179]] = 600,
        [CHS[3004180]] = 501, [CHS[3004181]] = 502, [CHS[3004182]] = 503, [CHS[3004183]] = 504,
        [CHS[3004184]] = 405, [CHS[3004185]] = 404, [CHS[3004186]] = 403, [CHS[3004187]] = 402, [CHS[3004188]] = 401,
        [CHS[3004189]] = 308, [CHS[3004190]] = 307, [CHS[3004191]] = 306, [CHS[3004192]] = 305,
        [CHS[3004193]] = 304, [CHS[3004194]] = 303, [CHS[3004195]] = 302, [CHS[3004196]] = 301,
        [CHS[3004197]] = 100, -- "帮"与"众"之间加入一个空格，让索引值与PartyAppointDlg的MenberButton的text文本保持一致
        [CHS[3000212]] = 100, -- 无空格的帮众
        [CHS[3000211]] = 150, -- 帮派精英
    }

local JOB_NAME_ORDER =
    {
        [CHS[3004177]] = 700,
        [CHS[3004179]] = 600,
        [CHS[3004180]] = 504, [CHS[3004181]] = 503, [CHS[3004182]] = 502, [CHS[3004183]] = 501,
        [CHS[3004184]] = 405, [CHS[3004185]] = 404, [CHS[3004186]] = 403, [CHS[3004187]] = 402, [CHS[3004188]] = 401,
        [CHS[3004189]] = 308, [CHS[3004190]] = 307, [CHS[3004191]] = 306, [CHS[3004192]] = 305,
        [CHS[3004193]] = 304, [CHS[3004194]] = 303, [CHS[3004195]] = 302, [CHS[3004196]] = 301,
        [CHS[3000211]] = 200, -- 帮派精英
        [CHS[3000212]] = 100, -- 帮众
    }

-- 帮派公告默认
local partyNotifyDefault    = {
    [1] = {title = CHS[3004198], content = CHS[3004199]},   -- 帮派任务
    [2] = {title = CHS[5450002], content = CHS[5450005]},   -- 帮派智多星
    [3] = {title = CHS[5400231], content = CHS[5400249]},  -- 培育巨兽
    [4] = {title = CHS[4100784], content = CHS[4100785]},   -- 挑战圣兽
    [5] = {title = CHS[3004206], content = CHS[3004207]},   -- 帮战
    [6] = {title = CHS[3004208], content = CHS[3004209]},   -- 帮派攻城战
    [7] = {title = CHS[3004210], content = ""},             -- 自定义一
    [8] = {title = CHS[3004211], content = ""},             -- 自定义二
}

-- 帮派活动配表
local partyActives = {
    [1] = {
        name = CHS[3004198],
        icon = ResMgr.ui.reward_big_banggong,
        iconResType = ccui.TextureResType.plistType,
        time = CHS[3004212],
        introduce = CHS[3004213],
        limit = CHS[3004214],
        reward = CHS[3004215],
        level = 30,
        npc = CHS[3004216],
        task = {CHS[3004217], CHS[3004218], CHS[3004219], CHS[3004220]},
    },
    [2] = {
        name = CHS[3004221],
        icon = ResMgr.ui.big_banggong,
        iconResType = ccui.TextureResType.plistType,
        time = CHS[3004212],
        introduce = CHS[4000241],
        limit = CHS[3004223],
        level = 40,
        reward = CHS[3004224],
        npc = CHS[3004216],
    },
    [3] = {
        name = CHS[6400041],
        icon = ResMgr.ui.big_banggong,
        iconResType = ccui.TextureResType.plistType,
        time = CHS[3004212],
        introduce = CHS[6400042],
        limit = CHS[3004214],
        level = 70,
        reward = CHS[6400043],
        npc = CHS[6400044],
    },

    [4] = {
        name = CHS[5450002],
        icon = ResMgr.ui.reward_big_pot_money_dao,
        iconResType = ccui.TextureResType.plistType,
        time = CHS[5450001],
        level = 25,
        introduce = CHS[5450000],
        limit = CHS[5450004],
        reward = CHS[5450003],
    },

    [5] = {
        name = CHS[5400231],    -- 培育巨兽
        icon = ResMgr.ui.money,
        iconResType = 0,
        time = CHS[5400232],
        introduce = CHS[5400233],
        limit = CHS[5400234],
        reward = CHS[5400235],
        level = 25,
    },

    [6] = {
        name = CHS[4100784],    -- 挑战巨兽
        icon = ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4000103])), -- 超级灵石
        iconResType = 0,
        time = CHS[4100786],
        introduce = CHS[4100787],
        limit = CHS[4100788],
        reward = CHS[4100789],
        level = 25,
    },

    [7] = {
        name = CHS[3004206],    --
        icon = ResMgr.ui.item_common,
        iconResType = 1,
        time = CHS[3004231],
        introduce = CHS[4000256],
        limit = CHS[4000257],
        reward = CHS[3004232],
        level = 25,
    }
}


PartyMgr.partySkill = {
    CHS[3004233], CHS[3004234], CHS[3004235], CHS[3004236], CHS[3004237], CHS[3004238], CHS[3004239], CHS[3004240], CHS[3004241], CHS[3004242], CHS[3004243],
    CHS[3004244], CHS[3004245], CHS[3004246], CHS[3004247], CHS[3004248], CHS[3004249], CHS[3004250],
}

-- 帮派图标上传所需建设度
PartyMgr.constructionForUpload = {
    [1] = 10000,
    [2] = 110000,
    [3] = 510000,
    [4] = 1010000,
}

PartyMgr.partyInfo = nil
PartyMgr.partyListInfo = {}
PartyMgr.partyZdxInfo = {}
PartyMgr.partyZDXSkillInfo = {}

-- 帮派宗旨长度限制
PartyMgr.ANNOUNCE_LEN_LIMIT = 300

PartyMgr.log = {}
PartyMgr.log.dates = {}
PartyMgr.PER_PAGE_COUNT = 8


-- 产看红包结果的类型
local RECV_REDBAG_TYPE =
{
    PT_RB_RECV_NONE = 0 , -- 无
    PT_RB_RECV_SHOW = 1,  -- 不播动画，直接展示(查看红包)
    PT_RB_RECV_LATE = 2,  -- 播动画，但来晚了
    PT_RB_RECV_OK   = 3,  -- 播动画，成功了
}

-- 退出时清除一些数据
function PartyMgr:clearData(isLoginOrSwithLine)

    if not DistMgr:getIsSwichServer() then
        self.partyInfo = nil
    end
    self.log = nil
    inviteJoinList = {}
    PartyMgr:closePartyDlg()

    self.showRedBagData = {}
    self.sendRedbagRecord = nil
    self.recRedbagRecord = nil
    self.partyZhidxQuestionInfo = nil

    if not isLoginOrSwithLine then
        self.partyMemberDlgInfo = nil
    end
end

function PartyMgr:getPartyActiveInfo()
    return partyActives
end

function PartyMgr:getPartyNotifyDef(index)
    return partyNotifyDefault[index]
end

function PartyMgr:getMePartyFromParties()
    for _, party in pairs(self.partiesInfo) do
        if party.partyName == self.partyInfo.partyName then
            return party
        end
    end
end

-- 获取最小入帮等级
function PartyMgr:getJoinPartyLevelMin()
    return limitJoinPartyLevel
end

-- 获取帮派等级上限帮派信息
function PartyMgr:getPartyLevelMax()
    return PARTY_LEVEL_MAX
end

-- 设置me帮派信息
function PartyMgr:setPartyInfo(partyInfo)
    self.partyInfo = partyInfo
end

-- 获取帮派人数
function PartyMgr:getPartyPopulation()
    if self.partyInfo then
        return self.partyInfo.population
    end
end

-- 获取me帮派信息
function PartyMgr:getPartyInfo()
    return self.partyInfo
end

-- 获取me的帮派图标信息
function PartyMgr:getPartyIcon()
    if self.partyInfo then
        return self.partyInfo["icon_md5"]
    end
end

-- 获取帮派图标状态
function PartyMgr:getPartyReviewIcon()
    if self.partyInfo then
        return self.partyInfo["review_icon_md5"]
    end
end

-- 清除帮派图标
function PartyMgr:clearPartyIcon()
    gf:CmdToServer("CMD_DELETE_PARTY_ICON")
end

-- 获取指定职位的帮派领导
function PartyMgr:getPartyMemberByJob(job)
    if not self.partyInfo then
        return ""
    end

    local leaders = self.partyInfo.leader
    for i = 1, #leaders do
        if leaders[i].job == job then
            return leaders[i].name
        end
    end

    return ""
end

-- 销货me帮派信息
function PartyMgr:clearPartyInfo(partyInfo)
    self.partyInfo = nil
end

-- 创建帮派
function PartyMgr:createParty(name, announce)
    local party = {name = name, announce = announce}
    gf:CmdToServer("CMD_CREATE_PARTY", party)
end

-- 根据等级获得帮派级别，人口上限
function PartyMgr:getCHSLevelAndPeopleMax(level)
    if level == PARTYL_LEVEL_PRIMARY then
        return CHS[4000185], REPUTATION_PRIMARY
    elseif level == PARTYL_LEVEL_MIDDLE then
        return CHS[4000186], REPUTATION_MIDDLE
    elseif level == PARTYL_LEVEL_SENIOR then
        return CHS[4000187], REPUTATION_SENIOR
    elseif level == PARTYL_LEVEL_TOP then
        return CHS[4000188], REPUTATION_TOP
    elseif level == 0 then
        return CHS[5000059]
    else
        -- 传入帮派等级错误时候，返回初级帮派信息
        return CHS[4000185], REPUTATION_PRIMARY
    end
end

-- 获取人物等级上限
function PartyMgr:getHeroLevelMit()
    return HERO_LEVEL_MIT
end

-- 发送查询全部帮派列表
function PartyMgr:queryParties(page)
    if not self.queriedPages then self.queriedPages = {} end

    if page == 0 then
        self.partyListInfo = {}
        self.queriedPages = {} -- 清空已经请求过的页码
    end

    -- 当前页面已经请求过了，则不需要再次请求
    if self.queriedPages[page] then
        return
    end

    self.queriedPages[page] = true
    gf:CmdToServer("CMD_QUERY_PARTYS", {type = "order", para = tostring(page)})
end

-- 发送某帮派(模糊)  ps:精确查找 type = exact
function PartyMgr:queryPartyByNameOrId(searchType,content)
    gf:CmdToServer("CMD_QUERY_PARTYS", {type = searchType, para = tostring(content)})
end

-- 发送加入帮派命令
function PartyMgr:addParties(peer_name)
    local data = {peer_name = peer_name, ask_type = REQUEST_JOIN_PARTY_REMOTE}
    gf:CmdToServer("CMD_REQUEST_JOIN" , data);
end

-- 发送加入帮派命令,一键
function PartyMgr:addPartiesOneKey()
    local data = {peer_name = "", ask_type = "party_one_key"}
    gf:CmdToServer("CMD_REQUEST_JOIN" , data);
end

-- 发送查询帮派信息命令
function PartyMgr:queryPartyInfo()
    gf:CmdToServer("CMD_PARTY_INFO", {})
end

-- 发送获取帮派日志的命令
function PartyMgr:queryPartyLog(start, limit)
    start = start or 1
    limit = limit or 8
    gf:CmdToServer("CMD_GET_PARTY_LOG", {start = start - 1, limit = limit})
    --gf:CmdToServer("CMD_GET_PARTY_LOG", {})
end

-- 发送开除帮派成员信息命令
function PartyMgr:fireMember(name, gid)
    local data = {name = name, gid = gid, job = JOB_KICKOUT}
    self.fireName = name
    self.fireGid = gid
    self.agreePlayerName = ""
    -- 发送开除命令
    gf:CmdToServer("CMD_PARTY_MODIFY_MEMBER", data)
end

-- 发送传位命令
function PartyMgr:demiseMember(name, gid)
    gf:CmdToServer("CMD_PARTY_MODIFY_MEMBER", {name = name, gid = gid, changeBangZhu = 1})
end

-- 发送取消传位命令
function PartyMgr:cancelDemiseMember(name, gid)
    gf:CmdToServer("CMD_PARTY_MODIFY_MEMBER", {changeBangZhu = 2})
end

-- 发送任命命令
function PartyMgr:applyMember(name, gid, jobId)
    local data = {name = name, gid = gid, job = jobId}
    gf:CmdToServer("CMD_PARTY_MODIFY_MEMBER", data)
end

-- 发送查询帮派所有成员信息命令
function PartyMgr:queryPartyMembers()
    gf:CmdToServer("CMD_PARTY_MEMBERS", {page = 1})
end

-- 查询指定帮派成员信息
function PartyMgr:queryPartyMemberByNameAndGid(name, gid)
    gf:CmdToServer("CMD_PARTY_MEMBERS", {name = name, gid = gid})
end

-- 退出帮派
function PartyMgr:exitParty()
    gf:CmdToServer("CMD_PARTY_MODIFY_MEMBER", {})
end

-- 同意所有请求列表中的玩家
function PartyMgr:agreeAll()
    local data = {peer_name = "all\t", ask_type = REQUEST_JOIN_PARTY}
    gf:CmdToServer("CMD_ACCEPT", data)
end

-- 同意指定玩家入帮申请
function PartyMgr:agreePlayerParty(name)
    local data = {peer_name = name, ask_type = REQUEST_JOIN_PARTY}
    self.agreePlayerName = name
    self.fireName = ""
    self.fireGid = ""
    gf:CmdToServer("CMD_ACCEPT", data)
end

-- 拒绝指定玩家入帮申请
function PartyMgr:refusePlayerParty(name)
    local data = {peer_name = name, ask_type = REQUEST_JOIN_PARTY}
    gf:CmdToServer("CMD_REJECT", data)
end

-- 拒绝所有玩家入帮申请
function PartyMgr:refuseAllPlayerParty()
    local data = {peer_name = "all\t", ask_type = REQUEST_JOIN_PARTY}
    gf:CmdToServer("CMD_REJECT", data)
end

-- 发送获取入帮申请列表命令
function PartyMgr:requestList()
    gf:CmdToServer("CMD_PARTY_REQUEST_LIST", {})
end

-- 发送限制等级为level一下的玩家入帮      level == 0不限制等级
function PartyMgr:refuseByLevel(minLevel, maxLevel, isWork, isChange)
    gf:CmdToServer("CMD_PARTY_REJECT_LEVEL", {
        minLevel = minLevel,
        maxLevel = maxLevel,
        isWork = isWork,
        isChange = isChange,
    })

    self:queryPartyInfo()
end

-- 发送帮派技能学习  point == -1 连升5级
function PartyMgr:studyPartySkill(point, no)
    gf:CmdToServer("CMD_DEVELOP_SKILL", {
        point = point,
        skill_no = no,
    })
end

-- 获取自己帮派职位
function PartyMgr:getPartyJob()
    return Me:queryBasic("party/job")
end

-- 根据职位获取职位ID
function PartyMgr:getJobID(name)
    return JOB_NAME_ID[name]
end

-- 根据职位获取排序优先级
function PartyMgr:getJobOrder(name)
    return JOB_NAME_ORDER[name]
end

-- 帮派日耗建设度
function PartyMgr:getDayCastConstru()
    if self.partyInfo == nil then return 0 end

    if self.partyInfo.partyLevel == 1 then
        return 0
    elseif self.partyInfo.partyLevel == 2 then
        return math.floor(self.partyInfo.population * 13.5 + 1000)
    elseif self.partyInfo.partyLevel == 3 then
        return math.floor(self.partyInfo.population * 13.5 + 2000)
    elseif self.partyInfo.partyLevel == 4 then
        return math.floor(self.partyInfo.population * 13.5 + 4000)
    end
end

function PartyMgr:getContsructionColor()
    if self.partyInfo == nil then return COLOR3.WHITE end

    if self.partyInfo.partyLevel == 1 then
        return COLOR3.WHITE
    elseif self.partyInfo.partyLevel == 2 then
        if self.partyInfo.construct < (90000 + 10 * self:getDayCastConstru()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    elseif self.partyInfo.partyLevel == 3 then
        if self.partyInfo.construct < (450000 + 10 * self:getDayCastConstru()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    elseif self.partyInfo.partyLevel == 4 then
        if self.partyInfo.construct < (900000 + 10 * self:getDayCastConstru()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    end
end

-- 帮派日耗资金
function PartyMgr:getDayCastMoney()
    if self.partyInfo == nil then return 0 end

    if self.partyInfo.partyLevel == 1 then
        return 0
    elseif self.partyInfo.partyLevel == 2 then
        return 350000
    elseif self.partyInfo.partyLevel == 3 then
        return 750000
    elseif self.partyInfo.partyLevel == 4 then
        return 1500000
    end
end

-- 获取帮派资金颜色
function PartyMgr:getMoneyColor()
    if self.partyInfo == nil then return COLOR3.WHITE end

    if self.partyInfo.partyLevel == 1 then
        return COLOR3.WHITE
    elseif self.partyInfo.partyLevel == 2 then
        if self.partyInfo.money < (450000 + 10 * self:getDayCastMoney()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    elseif self.partyInfo.partyLevel == 3 then
        if self.partyInfo.money < (900000 + 10 * self:getDayCastMoney()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    elseif self.partyInfo.partyLevel == 4 then
        if self.partyInfo.money < (2900000 + 10 * self:getDayCastMoney()) then
            return COLOR3.RED
        else
            return COLOR3.WHITE
        end
    end
end

-- 发送领取帮派俸禄
function PartyMgr:getPartySalary()
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3004251])
        return
    end
    --gf:CmdToServer("CMD_PARTY_GET_BONUS", {type = 1})

    local destStr = CHS[3004252]
    AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
    DlgMgr:closeDlg("PartyWelfareDlg")
end

-- 发送领取帮派功臣
function PartyMgr:getPartyContributor()
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3004251])
        return
    end
    --gf:CmdToServer("CMD_PARTY_GET_BONUS", {type = 2})

    local destStr = CHS[3004253]
    AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
    DlgMgr:closeDlg("PartyWelfareDlg")
end

-- 回帮派总坛
function PartyMgr:flyToParty()

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000072])
        return
    end

    if Me:isInCombat()then
        gf:ShowSmallTips(CHS[3004254])
        return
    end

    if Me:isLookOn() then
        gf:ShowSmallTips(CHS[3004255])
        return
    end

    -- 26000帮派底图
    if MapMgr.mapData.map_id ~= 26000 then
        MapMgr:flyTo(CHS[4000199])
    end

end

-- 发送获取帮派log
function PartyMgr:getPartyLog(start, limit)
    if not next(self.log) or not self.log or not self.log.dates then return end

    return self.log

    --[[
    start = start or 1
    limit = limit or 8

    local total = start + limit - 1
    local oldStart = start
    local retValue = {}
    local i = 0

    for k, d in pairs(self.log.dates) do
        local v = self.log[d]
        local tempTable = {}
        for index, log in pairs(v) do
            i = i + 1
            if start > total then break end

            if i >= oldStart then
                table.insert(tempTable, log)
                start = start + 1
            end
        end

        if next(tempTable) ~= nil then
            retValue[d] = tempTable
        end

        if start > total then break end
    end

    if next(retValue) ~= nil then
        retValue["dates"] = self.log.dates
    end

    return retValue
    --]]
end

-- 发送禁言命令
function PartyMgr:prohibitSpeaking(menber, speakType, time)
    local data = {gid = menber.gid, name = menber.name, type = speakType, hours = time}
    gf:CmdToServer("CMD_CONTROL_PARTY_CHANNEL", data)
end

-- 获取禁言成员列表
function PartyMgr:getProhibitSpeakingList()
    gf:CmdToServer("CMD_GET_PARTY_CHANNEL_DENY_LIST", {})
end

-- 保存帮派自荐宣言
function PartyMgr:saveDeclaration(str)
    local data = {declaration = str}
    gf:CmdToServer("CMD_SET_LEADER_DECLARATION", data)
end

-- 刷新帮派商店
function PartyMgr:refreshPartyShop(type)
    if Me:queryBasic("party/name") == "" then
        if type == 0 then
            gf:ShowSmallTips(CHS[3003312])
        else
            gf:ShowSmallTips(CHS[3004256])
        end
        return
    end

    gf:CmdToServer("CMD_REFRESH_PARTY_SHOP", {type = type})
end

-- 购买帮派商店物品
function PartyMgr:buyPartyShop(name, num)
    local data = {name = name, num = num}

    gf:CmdToServer("CMD_BUY_FROM_PARTY_SHOP", data)
end

-- 设置要帮派商店要打开的物品
function PartyMgr:setPartyShopSelectItem(itemName)
    self.partyShopItem = itemName
end

-- 打开帮派商店
function PartyMgr:MSG_REFRESH_PARTY_SHOP()
    Client:pushDebugInfo("MSG_REFRESH_PARTY_SHOP")
    local dlg = DlgMgr.dlgs["PartyShopDlg"]
    if dlg then return end

    DlgMgr:openDlg("PartyShopDlg")
end

function PartyMgr:MSG_PARTY_BRIEF_INFO(data)
end

-- 判断me是不是帮主
function PartyMgr:isPartyLeader()
    if Me:queryBasic("party/job") == CHS[4000153] then  -- "帮主"
        return true
    end

    return false
end

-- 更新帮派名称
function PartyMgr:updataPartyName(newPartyName)
    if not self.partyInfo then return end
    local partyInfo = self.partyInfo
    if partyInfo.partyName ~= newPartyName then
        -- 帮派名称变更时，更新帮派界面
        partyInfo.partyName = newPartyName
        self:MSG_PARTY_INFO(partyInfo)
    end
end

function PartyMgr:MSG_PARTY_INFO(data)
    self.partyInfo = data

    EventDispatcher:dispatchEvent('MSG_PARTY_INFO')

    DlgMgr:sendMsg("PartyInfoDlg", "refreshPartyInfo", self.partyInfo)
    DlgMgr:sendMsg("PartySkillDlg", "refreshPartyInfo", self.partyInfo)
    DlgMgr:sendMsg("PartyManageDlg", "setPartyLevelupInfo")
end

-- text 的格式必须为 xxxx-xx-xx xx:xx，其中 x 为数字
-- 不是此格式的则认为是非法数据
function PartyMgr:parseLog(text)
    local len = string.len(text)
    if len < 17 then
        return
    end

    local s1 = string.sub(text, 1, 17)
    local _, _, dateStr, t = string.find(s1, "(%d%d%d%d[-]%d%d[-]%d%d) (%d%d:%d%d)")
    if not dateStr then
        return
    end

    local s2 = string.sub(text, 18)
    return dateStr, '[' .. t .. ']' .. s2
end

-- 帮派日志信息
function PartyMgr:MSG_SEND_PARTY_LOG(data)
    PartyMgr.log = {}
    PartyMgr.log.dates = {}
    local dlg = DlgMgr:getDlgByName("PartyInfoDlg")
    if not dlg then return end

    if dlg.start > data.start + 1 then
        dlg.start = dlg.start - PartyMgr.PER_PAGE_COUNT * 2
        return
    end

    local info = data.info
    for i = 1, #info do
        local dateStr, s = self:parseLog(info[i])
        if dateStr then
            local dateInfo = self.log[dateStr]
            if not dateInfo then
                -- 无该日期的信息，进行添加
                dateInfo = {}
                self.log[dateStr] = dateInfo
                table.insert(self.log.dates, dateStr)
            end
            table.insert(dateInfo, s)
        end
    end

    local dlg = DlgMgr:getDlgByName("PartyInfoDlg")
    if dlg then
        dlg:setPartyLog(dlg.start, PartyMgr.PER_PAGE_COUNT)
    end

    --[[
    if data.groupIndex + 1 >= data.groupCount then
        -- 接收完毕，通知相关对话框进行处理
        DlgMgr:sendMsg('PartyInfoDlg', 'setPartyLog')
    end
    --]]
end

-- 邀请入帮
function PartyMgr:inviteJionParty(name)
    gf:CmdToServer("CMD_REQUEST_JOIN", {peer_name = name,
        ask_type = Const.PARTY_INVITE,})
end

-- 被邀请入帮
function PartyMgr:MSG_DIALOG(data)
    if data.ask_type ~= Const.PARTY_INVITE then
        return
    end

    local dlg = DlgMgr:openDlg("InviteJoinParty")
    dlg:setInfo(data.peer_name, data[1]["party/name"], data.peer_name)

    -- 检查语音按钮
    ChatMgr:noticeVoiceBtn()
    if 1 then return end

    -- 后续任务需要用到一下部分
    if not self.partyInviteList then self.partyInviteList = {} end

    table.insert(self.partyInviteList, {name = data.peer_name, partyName = data[1]["party/name"]})
    RedDotMgr:insertOneRedDot("GameFunctionDlg", "PartyButton")

end

-- 同意或拒绝对方邀请入帮要求
function PartyMgr:responseInviteParty(isJoin, invitor)
    if isJoin then
        local data = {peer_name = invitor, ask_type = Const.PARTY_INVITE}
        gf:CmdToServer("CMD_ACCEPT", data)
    else
        local data = {peer_name = invitor, ask_type = Const.PARTY_INVITE}
        gf:CmdToServer("CMD_REJECT", data)

        for _, info in pairs(inviteJoinList) do
            if info.inviteName == invitor then
                table.remove(inviteJoinList, _)
            end
        end
    end
end

-- 设置帮派智多星开启方式
-- 0 打开帮派智多星界面
-- 1 开启自动启动
-- 2 取消自动开启
-- 3 立即开启
-- 4 保存选择开启服务器线路
-- 5 设置开启时间
    -- oper_para = 开启时间
-- 6 设置游戏难度
    -- oper_para = 1 表示“简单难度”；oper_para = 2 表示“普通难度”；oper_para = 3 表示“困难难度”。
-- 7 设置求助等级
    -- oper_para = 0 表示“不开放”；oper_para = 1 表示“低级求助”；oper_para = 2 表示“中级求助”；oper_para = 3 表示“高级求助”。
function PartyMgr:setZdxOpenType(type, oper_para)
    oper_para = oper_para or 0
    gf:CmdToServer("CMD_PARTY_ZHIDUOXING_SETUP", {oper_type = type, oper_para = tostring(oper_para)})
end

-- 设置智多星前往活动地图
function PartyMgr:setZdxGotoMap()
    gf:CmdToServer("CMD_PARTY_ZHIDUOXING_GOTO")
end

-- 查询帮派智多星信息
function PartyMgr:queryPartyZdxInfo()
    gf:CmdToServer("CMD_PARTY_ZHIDUOXING_QUERY", {})
end

-- 获取当前智多星开启方式    1自动开启
function PartyMgr:getZdxOpenType()
    return self.partyZdxInfo.auto
end

-- 获取当前智多星今天开启状态    1:开启过   2:开启中
function PartyMgr:getZdxOpenToday()
    return self.partyZdxInfo.openToday
end

-- 获取当前智多星自动开启时间
function PartyMgr:getZdxAutoStartTime()
    local time = gf:split(self.partyZdxInfo.start_time, ":") or {}
    return tonumber(time[1]), tonumber(time[2])
end

-- 获取当前智多星求助等级
function PartyMgr:getZdxAutoHelpLevel()
    return self.partyZdxInfo.help_level
end

-- 获取当前智多星难度
function PartyMgr:getZdxAutoHardLevel()
    return self.partyZdxInfo.hard_level
end

-- 获取当前智多星自动开启时间
function PartyMgr:getPartyZdxInfo()
    return self.partyZdxInfo or {}
end

-- 获取智多星开启线路
function PartyMgr:getPartyZdxOpenLine()
    return self.partyZdxInfo.select_id or 0
end

-- 获取智多星开启线路
function PartyMgr:usePartyZdxSkill(type)
    gf:CmdToServer("CMD_PARTY_ZHIDUOXING_SKILL", {skill_name = type})
end

-- 获取智多星使用技能
function PartyMgr:getPartyZdxSkillCount(type)
    return self.partyZDXSkillInfo[type] or 0
end

-- 判断自己是否有任命、禁言权限
function PartyMgr:canApplyAndPro()
    if Me:queryBasic("party/job") ~= CHS[4000153] and Me:queryBasic("party/job") ~= CHS[4000157] then
        return false
    end

    return true
end

-- 判断自己是否有接受或者拒绝的权限
function PartyMgr:checkAgreeOrDenyApply()
    local job = Me:queryBasic("party/job")
    if string.match(job, CHS[3004177]) or string.match(job, CHS[3003241]) or string.match(job, CHS[3003243]) or string.match(job, CHS[3003245]) then
        return true
    end

    return false
end

-- 获取帮派技能信息
function PartyMgr:getPartySkill(skillName)
    for index, skill in pairs(self.partyInfo.skill) do
        if skill.name == skillName then return skill end
    end
end

-- 根据技能名称获得是天生还是研发
function PartyMgr:getSkillTypeBySkillName(skillName)
    local studySkill = PartyMgr:getPartySkillByType(CHS[3004257])
    local boonSkill = PartyMgr:getPartySkillByType(CHS[3004258])
    for i = 1, #studySkill do
        if studySkill[i] == skillName then return CHS[3004257] end
    end
    for i = 1, #boonSkill do
        if boonSkill[i] == skillName then return CHS[3004258] end
    end
    return ""
end

-- 根据类型获取帮派技能
function PartyMgr:getPartySkillByType(skillType)
    local studySkill = {[1] = CHS[3004249], [2] = CHS[3004247], [3] = CHS[3004248],[4] = CHS[3004250]}
    local boonSkill = {[1] = CHS[3004233],   [2] = CHS[3004234],   [3] = CHS[3004235],  [4] = CHS[3004236], [5] = CHS[3004237], [6] = CHS[3004238],
                       [7] = CHS[3004239], [8] = CHS[3004240], [9] = CHS[3004241], [10] = CHS[3004242], [11] = CHS[3004243], [12] = CHS[3004244], [13] = CHS[3004245],[14] = CHS[3004246],}

    if skillType == CHS[3004258] then
        return boonSkill
    elseif skillType == CHS[3004257] then
        return studySkill
    else
        local skillTab = {}
        for i = 1,#boonSkill do
            table.insert(skillTab, boonSkill[i])
        end
        for i = 1,#studySkill do
            table.insert(skillTab, studySkill[i])
        end
        return skillTab
    end
end

-- 修改帮派宗旨
function PartyMgr:setAnnouce(str)
    gf:CmdToServer("CMD_PARTY_MODIFY_ANNOUNCE", {annouce = str})
end

-- 帮派列表信息
function PartyMgr:MSG_PARTY_LIST(data)
    if data.count == 0 then
        self.partyListInfo = {}
        return
    end

    self.partyListInfo = data.partiesInfo
    table.sort(self.partyListInfo, function(l, r)
        if l.partyLevel > r.partyLevel then return true end
        if l.partyLevel < r.partyLevel then return false end
        if l.construct > r.construct then return true end
        if l.construct < r.construct then return false end
        --       if l.money > r.money then return true end
        --      if l.money < r.money then return false end
        if l.population > r.population then return true end
        if l.population < r.population then return false end
        return false
    end)

    DlgMgr:sendMsg('JoinPartyDlg', 'MSG_PARTY_LIST')
end

function PartyMgr:MSG_PARTY_LIST_EX(data)
    if data.type == "exact" or data.type == "fuzzy" then
        -- 如果列表是模糊查找或者精确查找的结果
        DlgMgr:sendMsg('JoinPartyDlg', 'setSearch', data.partiesInfo)
        return
    end

    -- 帮派列表页数查询
    if #self.partyListInfo == 0 then
        -- 列表为空，重新请求列表数据
        for i = 1, data.count do
            table.insert(self.partyListInfo, data.partiesInfo[i])
        end
        DlgMgr:sendMsg('JoinPartyDlg', 'setPartyByPage', 1)
    else
        -- 请求分页
        -- 应服务器要求，下发的帮派有可能重复，必须和现有的对比（对比gid）
        if data.count == 0 then return end
        local partysTemp = {}
        for i = 1, data.count do
            local isExsit = false
            for j = 1, #self.partyListInfo do
                if self.partyListInfo[j].partyId == data.partiesInfo[i].partyId then
                    isExsit = true
                    break
                end
            end

            if not isExsit then
                table.insert(partysTemp, data.partiesInfo[i])
            end
        end

        for i = 1, #partysTemp do
            table.insert(self.partyListInfo, partysTemp[i])
        end
        DlgMgr:sendMsg('JoinPartyDlg', 'setPage')
        -- 通知帮派界面加载新增的帮派信息
 --       DlgMgr:sendMsg('JoinPartyDlg', 'pushData', partysTemp)
    end
end

function PartyMgr:getPartyList(start, limit)
    if not self.partyListInfo then
        return
    end

    local retValue = {}
    local count = 0

    for k, v in pairs(self.partyListInfo) do
        if k >= start and count < limit then
            table.insert(retValue, v)
            count = count + 1
        end
    end

    if next(retValue) then
        return retValue
    end
end

function PartyMgr:getPartyListByKeyword(keyWord, start, limit)
    if not self.partyListInfo then return end

    local retValue = {}
    keyWord = string.lower(keyWord)

    local count = 0

    for k, v in pairs(self.partyListInfo) do
        local name = string.lower(v.partyName)
        local id = string.lower(string.sub(v.partyId, 5, 14))

        if k >= start and count < limit then
            if gf:findStrByByte(name, keyWord) then
                table.insert(retValue, v)
                count = count + 1
            end

            if count >= limit then break end

            if gf:findStrByByte(id, keyWord) then
                table.insert(retValue, v)
                count = count + 1
            end
        end
    end

    if next(retValue) then
        return retValue
    end

end

function PartyMgr:getJobName(job)
    if job == nil or job == "" then return end
    local pos = string.find(job, ":")
    if pos == nil then
        return job
    end
    return string.sub(job, 0, pos - 1)
end

function PartyMgr:closePartyDlg()
    for dlgName,dlg in pairs(DlgMgr.dlgs) do
        if gf:findStrByByte(dlgName, "party") or gf:findStrByByte(dlgName, "Party") then
            DlgMgr:closeDlg(dlgName)
        end
    end

    DlgMgr:closeDlg("MemberOperateMenuDlg")
end

-- 计算最近一次周一凌晨5点
function PartyMgr:nextMondayFive(time)
    local oneDay = 60 * 60 * 24
    local disNextDay = 0
    local today = tonumber(gf:getServerDate("%w", time))
    local h = tonumber(gf:getServerDate("%H", time))
    local m = tonumber(gf:getServerDate("%M", time))
    local s = tonumber(gf:getServerDate("%S", time))
    if today == 1 then
        if h < 5 then
            -- 如果开始时间在5点前
            local days = time + 5 * 60 * 60 - (h * 60 * 60 + m * 60 + s)
            return days
        else
            disNextDay = 6 * oneDay  + (oneDay - (h * 60 * 60 + m * 60 + s)) + 5 * 60 * 60
        end

    elseif today == 0 then
        disNextDay = oneDay - (h * 60 * 60 + m * 60 + s) + 5 * 60 * 60
    else
        disNextDay = (7 - today) * oneDay +  (oneDay - (h * 60 * 60 + m * 60 + s)) + 5 * 60 * 60
    end

    local days = disNextDay + time
    return days
end

function PartyMgr:analysisActiviesByType(data)
    local isChange = false
    if NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI == data.notify then
        local shouweiOpen = nil
        if data.para == "" then
            shouweiOpen = 0
        else
            local nowTime = math.floor(gf:getServerTime())
            local pos = gf:findStrByByte(data.para, "start_time=")
            local oneEndPos = gf:findStrByByte(data.para, ";")
            local startTime = tonumber(string.sub(data.para, pos + 11, oneEndPos - 1))
            local pos2 = gf:findStrByByte(data.para, "end_time=")
            local endTime = tonumber(string.sub(data.para, pos2 + 9, -1))

            if nowTime < startTime then
                shouweiOpen = 0
            elseif nowTime >= startTime and nowTime < endTime then
                shouweiOpen = 1
            else
                if nowTime > PartyMgr:nextMondayFive(startTime) then
                    -- 现在时间大于开始时间的最近下一个周一
                    shouweiOpen = 0
                else
                    shouweiOpen = 2
                end
            end
        end

        if shouweiOpen ~= self.pyjsIsOpen then
            self.pyjsIsOpen = shouweiOpen
            isChange = true
        end
    elseif NOTIFY.NOTIFY_QUERY_PARTY_HANGBARUQIN == data.notify then
        local hangbaOpen = nil
        if data.para == "" then
            hangbaOpen = 0
        else
            local nowTime = math.floor(gf:getServerTime())
            local pos = gf:findStrByByte(data.para, "start_time=")
            local oneEndPos = gf:findStrByByte(data.para, ";")
            local startTime = tonumber(string.sub(data.para, pos + 11, oneEndPos - 1))
            local pos2 = gf:findStrByByte(data.para, "end_time=")
            local endTime = tonumber(string.sub(data.para, pos2 + 9, -1))

            if nowTime < startTime then
                hangbaOpen = 0
            elseif nowTime >= startTime and nowTime < endTime then
                hangbaOpen = 1
            else
                if nowTime > PartyMgr:nextMondayFive(startTime) then
                    -- 现在时间大于开始时间的最近下一个周一
                    hangbaOpen = 0
                else
                    hangbaOpen = 2
                end
            end
        end

        if hangbaOpen ~= self.hangbaOpen then
            self.hangbaOpen = hangbaOpen
            isChange = true
        end
    end

    return isChange
end

function PartyMgr:analysisNewActiviesByType(data)
    local isChange = false
    local nowTime = gf:getServerTime()
    local startTime = data.start_time
    local endTime = data.end_time

    local openStatus = 0
    if nowTime < startTime then
        openStatus = 0
    elseif nowTime >= startTime and nowTime < endTime then
        openStatus = 1
    else
        if nowTime > PartyMgr:nextMondayFive(startTime) then
            -- 现在时间大于开始时间的最近下一个周一
            openStatus = 0
        else
            openStatus = 2
        end
    end

    if NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI == data.notify then
        -- 强盗来袭或培育巨兽
        if openStatus ~= self.pyjsIsOpen then
            self.pyjsIsOpen = openStatus
            isChange = true
        end
    end

    return isChange
end

function PartyMgr:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_CLOSE_PARTY == data.notify then
        PartyMgr:closePartyDlg()
    elseif NOTIFY.NOTIFY_JOIN_PARTY == data.notify then
        LeitingSdkMgr:joinGroupReport({
            partyName = data.para,
            roleName = Me:getName(),
            roleId = Me:queryBasic("gid"),
            roleLevel = Me:queryBasic("level"),
            zoneId = Client:getWantLoginDistName() or "",
            zoneName = Client:getWantLoginDistName() or "",
        })
    end
end

function PartyMgr:queryPartyQdlxOrPyjs()
    self:requestPYJSInfo(0)
end

-- 查询帮派巨兽 // int8 type。（0：查询时间；1：查询并询路）
function PartyMgr:queryPartyJS(type)
    gf:CmdToServer("CMD_QUERY_TZJS", {
        type = type
    })
end

function PartyMgr:openPartyJS()
    gf:CmdToServer("CMD_PARTY_TZJS_SETUP", {})
end

function PartyMgr:queryPartyShouwei()
    gf:CmdToServer("CMD_GENERAL_NOTIFY", {
        type = NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI,
        para1 = 0,
    })
end

function PartyMgr:queryPartHangba()
    gf:CmdToServer("CMD_GENERAL_NOTIFY", {
        type = NOTIFY.NOTIFY_QUERY_PARTY_HANGBARUQIN,
        para1 = 0,
    })
end

function PartyMgr:partyZdxOpenCondition()
    if Me:queryBasic("party/name") == "" then
        gf:ShowSmallTips(CHS[3004259])
        return
    end

    if not self.partyInfo then return end

    local createdTime = gf:getServerDate("%Y%m%d", self.partyInfo.createTime)
    local nowTime = gf:getServerDate("%Y%m%d", math.floor(gf:getServerTime()))
    if createdTime == nowTime then
        gf:ShowSmallTips(CHS[3004260])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self:canApplyAndPro() then
        gf:ShowSmallTips(CHS[3004261])
        return
    end

    return true
end

function PartyMgr:getInviteList()
    return inviteJoinList
end

function PartyMgr:setInviteListClean()
    inviteJoinList = {}
end

function PartyMgr:cleanInviteJoinList()
    inviteJoinList = {}
    gf:CmdToServer("CMD_CLEAN_REQUEST", {
        type = "party_invite",
    })
end

function PartyMgr:partyRenameCheck(name)

    -- 服务器端判断内容：名字只能由英文字母、汉字、阿拉伯数字组成，
    --                  你输入的名字中缺少必含字符，
    --                  名字不能与NPC重复，
    --                  帮派名称已被使用等

    -- 未输入
    if gf:getTextLength(name) == 0 then
        return
    end

    -- 帮派名称过短
    local len = string.len(name)
    if len < nameMin * 2 then
        gf:ShowSmallTips(CHS[3002374])
        return
    end

    -- 名字长度需要在3-12个字符之间
    if gf:getTextLength(name) > 12 or gf:getTextLength(name) < 3 then
        name = gf:subString(name, 12)
        self.newNameEdit:setText(name)
        gf:ShowSmallTips(CHS[7000031])
        return
    end

    -- 不能由10位纯数字或字母组成
    if not gf:checkRename(name) then
        gf:ShowSmallTips(CHS[3003798])
        return
    end

    -- 过滤敏感词
    local name, fitStr = gf:filtText(name)
    if fitStr then
        return
    end

    return true
end

function PartyMgr:MSG_PARTY_INVITE(data)
    if Me:queryBasic("party/name") ~= "" then return end

    local isExsit = false
    for _, info in pairs(inviteJoinList) do
        if info.partyName == data.partyName then
            isExsit = true
            inviteJoinList[_] = data
        end
    end

    if not isExsit then
        table.insert(inviteJoinList, data)
        if not DlgMgr:getDlgByName("InviteJoinPartyDlg") then
            RedDotMgr:insertOneRedDot("GameFunctionDlg", "PartyButton")
            RedDotMgr:updateGFDShowBtnRedDot()
        end
        DlgMgr:sendMsg("InviteJoinPartyDlg", "setDlgInfo")
    else
        DlgMgr:sendMsg("InviteJoinPartyDlg", "setDlgInfo")
    end
end

-- 帮派邀请列表中删除某一个
function PartyMgr:MSG_PARTY_INVITE_CLEAN(data)
    local pos
    for _, info in pairs(inviteJoinList) do
        if info.partyName == data.partyName then
            pos = _
        end
    end

    table.remove(inviteJoinList,pos)
end

-- 请求帮派要发送红包信息
function PartyMgr:requestRedBgaInfo()
    gf:CmdToServer("CMD_PT_RB_SEND_INFO")
end

function PartyMgr:getPartyRedBagInfo()
    return self.partyRedBagInfo or {}
end

function PartyMgr:MSG_PT_RB_SEND_INFO(data)
	self.partyRedBagInfo = data
end

-- 发送红包
function PartyMgr:sendRedBag(data)
    data.format = "{\29redbag=%s|%s|%s|%s}" -- {\29redbag=%s|type=%s|party_gid=%s|msg=%s}
    gf:CmdToServer("CMD_PT_RB_SEND_REDBAG", data)
end

-- 抢红包或者查看红包
function PartyMgr:openRedBag(gid)
    gf:CmdToServer("CMD_PT_RB_RECV_REDBAG", {redbag_gid = gid})
end

-- 抢红包结果
function PartyMgr:MSG_PT_RB_RECV_REDBAG(data)
    if data.type == RECV_REDBAG_TYPE.PT_RB_RECV_SHOW or data.type == RECV_REDBAG_TYPE.PT_RB_RECV_LATE  then -- 查看红包
       self:setGetMaxMoney(data)
	   self:setShowRedBagData(data)
       local dlg = DlgMgr:openDlg("PartyRedBagMoneyInfoDlg")
       dlg:setData(data)
	elseif data.type == RECV_REDBAG_TYPE.PT_RB_RECV_OK then -- 播放抢红包结果
       local dlg = DlgMgr:openDlg("PartyRedBagRewardDlg")
       dlg:setData(data)
       local msg = string.format(CHS[6400094], data.senderName, data.coin)
       ChatMgr:sendMiscMsg(msg)
	end
end

-- 设置查看红包缓存
function PartyMgr:setShowRedBagData(data)
    if not self.showRedBagData then
        self.showRedBagData = {}
    end

    if data.state == 2 or data.state == 3 then -- 红包已经抢完
        self.showRedBagData[data.redbag_gid] = data
    end
end

-- 设置最佳手气
function PartyMgr:setGetMaxMoney(data)
    local maxMoney = 0
    local index = 1
    for i = 1, data.size do
        local info = data.list[i]
        info["isMax"] = false
        if info.coin > maxMoney then
            maxMoney = info.coin
            index = i
        end
    end

    if data.list[index] then

        data.list[index]["isMax"] = true
    end
end

-- 请求帮派红包列表
function PartyMgr:requestPartyRedbagList()
    gf:CmdToServer("CMD_PT_RB_LIST")
end

-- 帮派红包列表
function PartyMgr:MSG_PT_RB_LIST(data)
    self.redbagList = data.redbagList
end

-- 帮派红包列表
function PartyMgr:getRedbagLsit()
    return self.redbagList
end

function PartyMgr:getRedbagInfoByGid(redbag_gid)
    if self.redbagList then
        for i = 1, #self.redbagList do
            if self.redbagList[i].redbag_gid == redbag_gid then
                return self.redbagList[i]
            end
        end
    end
end

-- 帮派界面查看红包
function PartyMgr:lookupRedbag(redbag_gid)
    if self.showRedBagData and self.showRedBagData[redbag_gid] then -- 缓存有数据就不请求数据
        self:MSG_PT_RB_RECV_REDBAG(self.showRedBagData[redbag_gid])
    else
        gf:CmdToServer("CMD_PT_RB_SHOW_REDBAG", {redbag_gid = redbag_gid})
    end
end

-- 请求红包记录
function PartyMgr:getRedBagRecord()
    gf:CmdToServer("CMD_PT_RB_RECORD", {type = 1}) -- 发红包记录
    gf:CmdToServer("CMD_PT_RB_RECORD", {type = 0}) -- 抢红包记录
end

-- 红包记录
function PartyMgr:MSG_PT_RB_RECORD(data)
    if data.type == 1 then
        self.sendRedbagRecord = data
    elseif data.type == 0 then
        self.recRedbagRecord = data
    end
end

-- 发送红包记录
function PartyMgr:getSendRedbagRecord()
    return self.sendRedbagRecord
end

-- 抢红包记录
function PartyMgr:getRecvRedbagRecord()
    return self.recRedbagRecord
end

-- 发红包最少人数
function PartyMgr:getLastRedBagNum()
    return PARTY_REDBAG_NUM
end

-- 上传帮派图标所需建设度
function PartyMgr:getNeedConstructionForUpload()
    local level = self.partyInfo and self.partyInfo.partyLevel or 0
    return self.constructionForUpload[level]
end

-- 成功创建帮派
function PartyMgr:MSG_CREATE_PARTY_SUCC()
    gf:ShowSmallTips(CHS[4300267])
end

MessageMgr:regist("MSG_CREATE_PARTY_SUCC", PartyMgr)
-- 帮派智多星 - 技能信息
function PartyMgr:MSG_PARTY_ZHIDUOXING_SKILL(data)
    self.partyZDXSkillInfo = data

    if data.start_time then
        local dlg = DlgMgr:openDlg("ZhiDuoXingDlg")

        if dlg and Me:isInCombat() then
            dlg:setVisible(false)
        end
    else
        DlgMgr:closeDlg("ZhiDuoXingDlg")
    end
end

-- 帮派智多星 - 基本信息
function PartyMgr:MSG_PARTY_ZHIDUOXING_INFO(data)
    self.partyZdxInfo = data
end

-- 帮派智多星 - 显示题目信息
function PartyMgr:MSG_PARTY_ZHIDUOXING_QUESTION(data)
    data.showStartTime = gf:getServerTime()  -- 开始显示题目的时间
    self.partyZhidxQuestionInfo = data
end

-- 请求开启培育巨兽活动
function PartyMgr:requestStartPYJS()
    gf:CmdToServer("CMD_PARTY_PYJS_SETUP", {})
end

-- 选择培育属性
function PartyMgr:requestChoosePYJSAttrib(name)
    gf:CmdToServer("CMD_PARTY_PYJS_SELECT_ATTRIB", {name = name})
end

-- 领取培育巨兽任务
function PartyMgr:requestFetchPYJSTask(name)
    gf:CmdToServer("CMD_PARTY_PYJS_FETCH_TASK", {name = name})
end

-- 完成培育巨兽任务
function PartyMgr:requestFinishPYJSTask(name)
    gf:CmdToServer("CMD_PARTY_PYJS_FINISH_TASK", {name = name})
end

-- type 0：查询时间；1：查询并询路
function PartyMgr:requestPYJSInfo(type)
    gf:CmdToServer("CMD_QUERY_PYJS", {type = type})
end

-- 培育巨兽活动开启信息
function PartyMgr:MSG_PARTY_PYJS_SETUP(data)
    data.notify = NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI
    local isChange = self:analysisNewActiviesByType(data)
    if isChange then
        -- 如果旱魃入侵和帮派守卫信息变化，通知更新
        DlgMgr:sendMsg("PartyActiveDlg", "setActiviesOpen", data.notify)
    end
end

-- 选择属性
function PartyMgr:MSG_PARTY_PYJS_ATTRIBS(data)
    DlgMgr:openDlg("PartyFeedMonsterDlg")
end

-- 培育巨兽
function PartyMgr:MSG_PARTY_PYJS_STAGE_DATA(data)
    if data.isOpen == 1 then
        DlgMgr:openDlg("PartyFeedMonsterDlg")
    end
end

-- 运气测试
-- sysPoint -1：游戏终止；0：未出结果；大于0：已有结果
function PartyMgr:MSG_PARTY_YQCS_RESULT(data)
    if data.sysPoint ~= -1 then
        DlgMgr:openDlg("Game21PointDlg")
    end
end

-- 益智训练
function PartyMgr:MSG_PARTY_YZXL_START(data)
    DlgMgr:openDlg("PartyPokeBubbleDlg")
end

-- 通知挑战巨兽信息
function PartyMgr:MSG_PARTY_TZJS_INFO(data)
    if data.is_open == 1 then
        local dlg = DlgMgr:openDlg("PartyBeatMonsterDlg")
        dlg:MSG_PARTY_TZJS_INFO(data)
    end
end

-- 挑战帮派巨兽
function PartyMgr:changllengeNPJS()
    gf:CmdToServer("CMD_PARTY_TZJS_CHALLENGE", {})
end

function PartyMgr:refreashTZJS()
    gf:CmdToServer("CMD_REQUEST_PARTY_TZJS_INFO", {})
end

function PartyMgr:MSG_PARTY_TZJS_SETUP(data)

    local openStateTZJS = nil
    if data.start_time == 0 then
        openStateTZJS = 0
    else
        local nowTime = gf:getServerTime()
        local startTime = data.start_time
        local endTime = data.end_time

        if nowTime < startTime then
            openStateTZJS = 0
        elseif nowTime >= startTime and nowTime < endTime then
            openStateTZJS = 1
        else
            if nowTime < startTime then
                openStateTZJS = 0
            elseif nowTime >= startTime and nowTime < endTime then
                openStateTZJS = 1
            else
                if nowTime > PartyMgr:nextMondayFive(startTime) then
                    -- 现在时间大于开始时间的最近下一个周一
                    openStateTZJS = 0
                else
                    openStateTZJS = 2
                end
            end
        end
    end

    if openStateTZJS ~= self.openStateTZJS then
        self.openStateTZJS = openStateTZJS

        -- 如果挑战巨兽信息变化，通知更新
        DlgMgr:sendMsg("PartyActiveDlg", "setActiviesOpen", CHS[4100784])
    end
end

function PartyMgr:MSG_PARTY_TZJS_COMBAT_INFO(data)
    DlgMgr:openDlgEx("PartyBeatMonsterResultDlg", data)
end

-- 通知客户端排行信息（按名次先后排序）
function PartyMgr:MSG_PARTY_TZJS_RANK_INFO(data)
    if MapMgr:getCurrentMapName() ~= CHS[2000074] then return end

    if data.end_time <= gf:getServerTime() then return end

    local dlg = DlgMgr:openDlgEx("PartyBeatMonsterMainInfoDlg", data)

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        dlg:setVisible(false)
        return
    end
end

-- 请求刷新帮派挑战巨兽排行榜数据
function PartyMgr:queryTZJSInfo()
    gf:CmdToServer("CMD_REQUEST_PARTY_TZJS_RANK")
end

function PartyMgr:setPartyMemberDlgInfo(data)
    self.partyMemberDlgInfo = data
end

function PartyMgr:getPartyMemberDlgInfo()
    return self.partyMemberDlgInfo
end

function PartyMgr:MSG_NEW_PARTY_WAR(data)
    self.isNewParty = gf:getServerTime() >= data.ti -- WDSY-31770
    if self.isNewParty then
        partyActives[7].time = CHS[4000255]
        partyActives[7].limit = CHS[4101175]
    end
end

MessageMgr:regist("MSG_PARTY_TZJS_RANK_INFO", PartyMgr)
MessageMgr:regist("MSG_PARTY_TZJS_COMBAT_INFO", PartyMgr)
MessageMgr:regist("MSG_PARTY_TZJS_SETUP", PartyMgr)
MessageMgr:regist("MSG_NEW_PARTY_ACTIVITY", PartyMgr)
MessageMgr:regist("MSG_PARTY_TZJS_INFO", PartyMgr)
MessageMgr:regist("MSG_PARTY_INVITE_CLEAN", PartyMgr)
MessageMgr:regist("MSG_PARTY_INVITE", PartyMgr)
MessageMgr:hook("MSG_GENERAL_NOTIFY", PartyMgr, "PartyMgr")
--MessageMgr:hook("MSG_DIALOG", PartyMgr, "PartyMgr")
MessageMgr:regist("MSG_REFRESH_PARTY_SHOP", PartyMgr)
MessageMgr:regist("MSG_PARTY_INFO", PartyMgr)
MessageMgr:regist("MSG_SEND_PARTY_LOG", PartyMgr)
MessageMgr:regist("MSG_PARTY_LIST", PartyMgr)
MessageMgr:regist("MSG_PARTY_LIST_EX", PartyMgr)
MessageMgr:regist("MSG_PARTY_BRIEF_INFO", PartyMgr)
MessageMgr:regist("MSG_PT_RB_SEND_INFO", PartyMgr)
MessageMgr:regist("MSG_PT_RB_RECV_REDBAG", PartyMgr)
MessageMgr:regist("MSG_PT_RB_LIST", PartyMgr)
MessageMgr:regist("MSG_PT_RB_RECORD", PartyMgr)
MessageMgr:regist("MSG_PARTY_ZHIDUOXING_SKILL", PartyMgr)
MessageMgr:regist("MSG_PARTY_ZHIDUOXING_INFO", PartyMgr)
MessageMgr:regist("MSG_PARTY_ZHIDUOXING_QUESTION", PartyMgr)
MessageMgr:regist("MSG_PARTY_PYJS_SETUP", PartyMgr)
MessageMgr:regist("MSG_PARTY_PYJS_ATTRIBS", PartyMgr)
MessageMgr:regist("MSG_PARTY_PYJS_STAGE_DATA", PartyMgr)
MessageMgr:regist("MSG_PARTY_YZXL_START", PartyMgr)
MessageMgr:regist("MSG_PARTY_YQCS_RESULT", PartyMgr)
MessageMgr:regist("MSG_NEW_PARTY_WAR", PartyMgr)

