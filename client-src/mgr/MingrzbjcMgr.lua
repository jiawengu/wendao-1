-- MingrzbjcMgr.lua
-- Created by lixh Mar/05/2018
-- 名人争霸赛竞猜管理器

MingrzbjcMgr = Singleton()

-- 赛程大类列表
local SC_BIG_TYPE_LIST = {
    MINGRZB_JC_BIG_TYPE.FINAL,  -- 总决赛
    MINGRZB_JC_BIG_TYPE.JC4,    -- 4强淘汰赛,
    MINGRZB_JC_BIG_TYPE.JC8,    -- 8强淘汰赛,
    MINGRZB_JC_BIG_TYPE.JC16,   -- 16强淘汰赛,
    MINGRZB_JC_BIG_TYPE.JC32,   -- 32强淘汰赛,
    MINGRZB_JC_BIG_TYPE.JC64,   -- 64强淘汰赛,
    MINGRZB_JC_BIG_TYPE.JC128,  -- 128强淘汰赛,
}

-- 赛程小类列表
local SC_SMALL_TYPE_LIST = {
    MINGRZB_JC_BIG_TYPE.JC64 + 2,   -- 64强淘汰赛，第2天
    MINGRZB_JC_BIG_TYPE.JC64 + 1,   -- 64强淘汰赛，第1天
    MINGRZB_JC_BIG_TYPE.JC128 + 4,  -- 128强淘汰赛，第4天
    MINGRZB_JC_BIG_TYPE.JC128 + 3,  -- 128强淘汰赛，第3天
    MINGRZB_JC_BIG_TYPE.JC128 + 2,  -- 128强淘汰赛，第2天
    MINGRZB_JC_BIG_TYPE.JC128 + 1,  -- 128强淘汰赛，第1天
}

-- 赛程大类名称
local SC_BIG_TYPE_NAME = {
    [MINGRZB_JC_BIG_TYPE.FINAL] = CHS[7100176],  -- 总决赛
    [MINGRZB_JC_BIG_TYPE.JC4]   = CHS[7100177],  -- 半决赛,
    [MINGRZB_JC_BIG_TYPE.JC8]   = CHS[7100178],  -- 8强淘汰赛,
    [MINGRZB_JC_BIG_TYPE.JC16]  = CHS[7100179],  -- 16强淘汰赛,
    [MINGRZB_JC_BIG_TYPE.JC32]  = CHS[7100180],  -- 32强淘汰赛,
    [MINGRZB_JC_BIG_TYPE.JC64]  = CHS[7100181],  -- 64强淘汰赛,
    [MINGRZB_JC_BIG_TYPE.JC128] = CHS[7100182],  -- 128强淘汰赛,
}

-- 赛程大类
MingrzbjcMgr.SC_BIG_TYPE = {}

-- 赛程小类
MingrzbjcMgr.SC_SMALL_TYPE = {}

-- 比赛日到赛程类别的映射
MingrzbjcMgr.SC_DAY_TO_TYPE = {}

-- 比赛日竞猜数据
MingrzbjcMgr.SC_DAY_JC_DATA = {}

-- 我的竞猜数据
MingrzbjcMgr.SC_MY_JC_DATA = {}

-- 赛程表数据
MingrzbjcMgr.scScheduleData = {}

-- 赛程队伍编号
MingrzbjcMgr.scScheduleTeamIcon = {}

-- 128强淘汰赛最多天数
local JC_128_MAX_DAYS = 4

-- 64强淘汰赛最多天数
local JC_64_MAX_DAYS = 2

-- 名人争霸赛比赛信息listView分页加载数量
local SC_INFO_ADD_NUM_ONCE = 6

-- 名人争霸赛比赛日范围
local SC_DAY_MAX = 12
local SC_DAY_MIN = 2

-- 赛程表类别信息
MingrzbjcMgr.SC_SCHEDULE_TYPE = {
    [MINGRZB_JC_BIG_TYPE.JC8]   = {name = CHS[7120060], pageNum = 1, teamNum = 8,   -- 8强至总冠军
         secondType = MINGRZB_JC_BIG_TYPE.JC4, secondTeamNum = 4,
         thirdType = MINGRZB_JC_BIG_TYPE.FINAL, thirdTeamNum = 2},
    [MINGRZB_JC_BIG_TYPE.JC32]  = {name = CHS[7120059], pageNum = 1, teamNum = 16,  -- 32进8强
        secondType = MINGRZB_JC_BIG_TYPE.JC16, secondTeamNum = 8,
        thirdType = MINGRZB_JC_BIG_TYPE.JC8, thirdTeamNum = 4},
    [MINGRZB_JC_BIG_TYPE.JC128] = {name = CHS[7120058], pageNum = 8, teamNum = 16,  -- 128进32强
        secondType = MINGRZB_JC_BIG_TYPE.JC64, secondTeamNum = 8,
         thirdType = MINGRZB_JC_BIG_TYPE.JC32, thirdTeamNum = 4}, 
}

-- 获取名人争霸赛比赛信息listView分页加载数量
function MingrzbjcMgr:getScListViewAddNum()
    return SC_INFO_ADD_NUM_ONCE
end

-- 获取名人争霸赛赛程所有大类顺序列表
function MingrzbjcMgr:getScBigTypeOrder()
    return SC_BIG_TYPE_LIST
end

-- 获取名人争霸赛赛程所有小类顺序列表
function MingrzbjcMgr:getScSmallTypeOrder()
    return SC_SMALL_TYPE_LIST
end

-- 获取名人争霸赛赛程大类:需要显示的(key, value)
function MingrzbjcMgr:getScBigType()
    return self.SC_BIG_TYPE
end

-- 获取名人争霸赛赛程小类:需要显示的{bigType, {smallType, {key, value}}}
function MingrzbjcMgr:getScSmallType()
    return self.SC_SMALL_TYPE
end

-- 计算小类对应的大类
function MingrzbjcMgr:getBigType(smallType)
    return math.floor(smallType / 100) * 100
end

-- 获取名人争霸赛赛程控件名称
function MingrzbjcMgr:getScListItemName(type)
    if SC_BIG_TYPE_NAME[type] then
        -- 大类
        return SC_BIG_TYPE_NAME[type]
    else
        -- 小类
        local key = math.floor(type / 100) * 100
        if self.SC_SMALL_TYPE[key] then
            return gf:getServerDate(CHS[7100196], self.SC_SMALL_TYPE[key][type].date)
        end
    end
end

-- 获取名人争霸赛赛程控件类型
function MingrzbjcMgr:getScTypeByDay(day)
    local map = self.SC_DAY_TO_TYPE
    return map[day]
end

-- 判断名人争霸赛竞猜数据是否需要显示
function MingrzbjcMgr:isScNeedShowData(data)
    if data and data.aTeamId ~= "" and data.bTeamId ~= "" then
        -- 两队都不轮空则需要显示
        return true
    end

    return false
end

-- 判断名人争霸赛个人竞猜页签是否应该显示：策划要求有数据才显示
function MingrzbjcMgr:getScTypeCanAdd(type)
    local myJcData = MingrzbjcMgr:getMyJcData()
    if myJcData then
        local count = #myJcData
        for i = 1, count do
            local info = myJcData[i]
            if info then
                local sType = MingrzbjcMgr:getScTypeByDay(info.day)
                if sType == type or math.floor(sType / 100) * 100 == type then
                    -- 该数据是type对应的大类或者小类的数据，则type应该显示
                    return true
                end
            end
        end
    end

    return false
end

-- 获取某比赛日比赛时间
function MingrzbjcMgr:getDayScTime(day, type)
    local data = MingrzbjcMgr:getJcData()
    for i = 1, data.count do
        local info = data.list[i]
        if info and day and i == day - 1 then
            if type == "end" then
                return info.endDate
            else
                return info.date
            end
        end
    end
end

-- 竞猜listView需要分页加载
function MingrzbjcMgr:bindTouchPanel(obj, panelName, func)
    local panel = obj:getControl(panelName, Const.UIPanel)
    local function onTouchBegan(touch, event)
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        local percent = obj:getCurScrollPercent("RankingListView", true)
        if percent > 100 then
            obj:tryAddItemToListView()
        end

        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function MingrzbjcMgr:jumpToItem(listView, offsetY)
    local contentSize = listView:getContentSize()
    local innerContainer = listView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height;
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end

    local x,y = innerContainer:getPosition()
    local pos = cc.p(x, offsetY)
    innerContainer:setPosition(pos)
end

-- 刷新名人争霸赛竞猜类别数据（key = 类别， value = 对应类别比赛日数据）
-- key为大类时，若有小类，则大类没有数据，小类有数据
-- 暂时的规则是：128强、64强没有大类数据，只有小类数据，其他赛程没有小类，所以没有小类数据
function MingrzbjcMgr:refreshScTypeData()
    local jcData = MingrzbjcMgr:getJcData()
    if jcData then
        -- 清空大类、小类
        self.SC_BIG_TYPE = {}
        self.SC_SMALL_TYPE = {}
        self.SC_DAY_TO_TYPE = {}

        local dayCount = jcData.count
        if dayCount <= 0 then return end

        for i = 1, dayCount do
            if jcData.list[i] and jcData.list[i].day >= SC_DAY_MIN and jcData.list[i].day <= SC_DAY_MAX then
                if i <= JC_128_MAX_DAYS then
                    -- 128强淘汰赛数据
                    self.SC_BIG_TYPE[MINGRZB_JC_BIG_TYPE.JC128] = {}
                    self.SC_BIG_TYPE.defaultType = MINGRZB_JC_BIG_TYPE.JC128
    
                    if not self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC128] then
                        self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC128] = {}
                    end

                    self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC128][MINGRZB_JC_BIG_TYPE.JC128 + i] = jcData.list[i]
                    self.SC_SMALL_TYPE.defaultType = MINGRZB_JC_BIG_TYPE.JC128 + i
                    self.SC_DAY_TO_TYPE[jcData.list[i].day] = MINGRZB_JC_BIG_TYPE.JC128 + i
                elseif i > JC_128_MAX_DAYS and i <= JC_128_MAX_DAYS + JC_64_MAX_DAYS then
                    -- 64强淘汰赛数据
                    self.SC_BIG_TYPE[MINGRZB_JC_BIG_TYPE.JC64] = {}
                    self.SC_BIG_TYPE.defaultType = MINGRZB_JC_BIG_TYPE.JC64

                    if not self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC64] then
                        self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC64] = {}
                    end

                    local secondeIndex = MINGRZB_JC_BIG_TYPE.JC64 + i - JC_128_MAX_DAYS
                    self.SC_SMALL_TYPE[MINGRZB_JC_BIG_TYPE.JC64][secondeIndex] = jcData.list[i]
                    self.SC_SMALL_TYPE.defaultType = secondeIndex
                    self.SC_DAY_TO_TYPE[jcData.list[i].day] = MINGRZB_JC_BIG_TYPE.JC64 + i - JC_128_MAX_DAYS
                else
                    -- 其他赛程数据
                    local orderList = MingrzbjcMgr:getScBigTypeOrder()
    
                    -- 减去前6天，再加上2，表示从32强算起，再 表示取逆序下标
                    local key = #orderList + 1 - (i - JC_128_MAX_DAYS - JC_64_MAX_DAYS + 2)
                    self.SC_BIG_TYPE[orderList[key]] = jcData.list[i]
                    self.SC_BIG_TYPE.defaultType = orderList[key]
                    self.SC_SMALL_TYPE.defaultType = nil
                    self.SC_DAY_TO_TYPE[jcData.list[i].day] = orderList[key]
                end
            end
        end
    end
end

-- 请求比赛日信息
function MingrzbjcMgr:fetchScDayInfo(tag)
    gf:CmdToServer("CMD_CG_REQUEST_DAY_INFO", {day = tag})
end

-- 请求赛程队伍投票
function MingrzbjcMgr:fetchScSupportsTeam(name, id, supports)
    gf:CmdToServer("CMD_CG_SUPPORT_TEAM", {name = name, id = id, supports = supports})
end

-- 请求赛程队伍信息
function MingrzbjcMgr:fetchScTeamInfo(id)
    gf:CmdToServer("CMD_CG_REQUEST_TEAM_INFO", {id = id})
end

-- 请求赛程我的竞猜数据
function MingrzbjcMgr:fetchScMyInfo()
    gf:CmdToServer("CMD_CG_REQUEST_MY_GUESS", {})
end

-- 请求查看战斗录像
function MingrzbjcMgr:fetchScMv(competName, id)
    gf:CmdToServer("CMD_CG_LOOKON_GDDB_COMBAT", {competName = competName, id = id})
end

-- 获取竞猜主界面数据
function MingrzbjcMgr:getJcData()
    return self.jcData
end

-- 获取竞猜主界面比赛日数据
function MingrzbjcMgr:getJcDataByDay(day)
    return self.SC_DAY_JC_DATA[day]
end

-- 获取竞猜主界面打开默认应该显示的页签
-- 策划要求：显示最近一天有比赛的页签
function MingrzbjcMgr:getScDefaultType()
    local bigType = MingrzbjcMgr:getScBigType()
    local smallType = MingrzbjcMgr:getScSmallType()
    if bigType and smallType then
        return bigType.defaultType, smallType.defaultType
    end
end

-- 获取我的竞猜数据
-- day有值时返回指定天的数据，否则返回所有我的竞猜数据
function MingrzbjcMgr:getMyJcData(day)
    local data = self.SC_MY_JC_DATA
    if day then
        local list = {}
        for i = 1, data.count do
            local info = data.list[i]
            if day == info.day then
                table.insert(list, info)
            end
        end

        return list
    else
        return data.list
    end
end

-- 获取某个比赛日的比赛时间
function MingrzbjcMgr:getScStartDate(day)
    local data = MingrzbjcMgr:getJcData()
    if data then
        for i = 1, data.count do
            local info = data.list[i]
            if day and info and i == day - 1 then
                return info.date
            end
        end
    end
end

-- 获取某个比赛日的投票状态
function MingrzbjcMgr:getScSupportsStatus(day)
    local scStartTime = MingrzbjcMgr:getScStartDate(day)
    local serverTime = gf:getServerTime()
    if not scStartTime or not gf:isSameDay(scStartTime, serverTime) then
        -- WDSY-29360,比赛时间与当天不是同一天
        if scStartTime and scStartTime <= serverTime then
            -- 小于等于服务器时间，则比赛已结束(其实不可能等于服务器时间)
            return MINGRZB_JC_SUPPORTS_STATUS.OVER
        else
            -- 大于服务器时间，服务器已经刷出来了，可投票
            return MINGRZB_JC_SUPPORTS_STATUS.FUTURE
        end
    else
        -- 当日比赛
        local endTime = MingrzbjcMgr:getDayScTime(day, "start")
        if serverTime < endTime then
            return MINGRZB_JC_SUPPORTS_STATUS.CAN_GO
        else
            return MINGRZB_JC_SUPPORTS_STATUS.CAN_NOT_GO
        end
    end
end

-- 赛程表数据，根据队伍id获取队伍编号
function MingrzbjcMgr:getScheduleTeamIcon(id)
    return self.scScheduleTeamIcon[id]
end

-- 获取赛程表数据
function MingrzbjcMgr:getScheduleData()
    return self.scScheduleData
end

-- 获取赛程表冠军数据
function MingrzbjcMgr:getScheduleChampionData()
    return self.scScheduleData.champion
end

-- 获取赛程表显示的数据
function MingrzbjcMgr:getSchedulePageData(type, page)
    -- 默认显示类型
    if not type or not self.scScheduleData[type] or #self.scScheduleData[type] == 0 then
        local defaultBType, defaultSType = MingrzbjcMgr:getScDefaultType()
        if defaultBType < MINGRZB_JC_BIG_TYPE.JC8 + 50 then
            -- 8强赛数据
            type = MINGRZB_JC_BIG_TYPE.JC8
            if not page then
                -- 八强赛只有1页
                page = 1
            end
        elseif defaultBType < MINGRZB_JC_BIG_TYPE.JC32 + 50 then
            -- 32强赛数据
            type = MINGRZB_JC_BIG_TYPE.JC32
            if not page then
                -- 32强赛显示第1页
                page = 1
            end
        else
            -- 128强赛数据
            type = MINGRZB_JC_BIG_TYPE.JC128
            if not page then
                -- 128强赛，需要根据小类选择页数
                page = defaultSType % 100 * 2 - 1
                if defaultBType == MINGRZB_JC_BIG_TYPE.JC64 then
                    page = (defaultSType % 100 - 1) * 4 + 1
                end
            end
        end
    end

    if not page then
        page = 1
    end

    -- 获取配置
    local typeConfig = self.SC_SCHEDULE_TYPE[type]

    -- 第1阶段数据
    local firstData = {}
    local data = self.scScheduleData[type]
    local numPerPage = typeConfig.teamNum
    for i = (page - 1) * numPerPage + 1, page * numPerPage do
        if data[i] and data[i].isCanUse == 1 then
            table.insert(firstData, data[i])
        end
    end
    
    -- 第2阶段数据
    local secondData = {}
    if typeConfig.secondType then
        local data = self.scScheduleData[typeConfig.secondType]
        local numPerPage = typeConfig.secondTeamNum
        for i = (page - 1) * numPerPage + 1, page * numPerPage do
            if data[i] and data[i].isCanUse == 1 then
                table.insert(secondData, data[i])
            end
        end
    end

    -- 第3阶段数据
    local thirdData = {}
    if typeConfig.thirdType then
        local data = self.scScheduleData[typeConfig.thirdType]
        local numPerPage = typeConfig.thirdTeamNum
        for i = (page - 1) * numPerPage + 1, page * numPerPage do
            if data[i] and data[i].isCanUse == 1 then
                table.insert(thirdData, data[i])
            end
        end
    end

    return type, page, firstData, secondData, thirdData
end

-- 我的竞猜数据
function MingrzbjcMgr:MSG_CG_MY_GUESS(data)
    local jcData = MingrzbjcMgr:getJcData()
    if jcData then
        jcData.supportCardNum = data.supportCardNum
        jcData.jcPoints = data.jcPoints
    end

    self.SC_MY_JC_DATA = data

    DlgMgr:sendMsg("MingrzbjcDlg", "refreshPointsNum")
    DlgMgr:sendMsg("MingrzbgrDlg", "refreshPointsNum")
end

-- 竞猜队伍数据回来了，打开名人争霸队伍介绍界面
function MingrzbjcMgr:MSG_CG_TEAM_INFO(data)
    local dlg = DlgMgr:openDlg("MingrzbTeamInfoDlg")
    dlg:setData(data)
end

-- 投票成功后，刷新数据
function MingrzbjcMgr:MSG_CG_SUPPORT_RESULT(data)
    local jcData = MingrzbjcMgr:getJcData()
    if jcData then
        jcData.supportCardNum = data.supportCardNum
        jcData.jcPoints = data.jcPoints
    end

    DlgMgr:sendMsg("MingrzbjcDlg", "refreshSingleItem", data)
    DlgMgr:sendMsg("MingrzbjcDlg", "refreshPointsNum")
    DlgMgr:sendMsg("MingrzbgrDlg", "refreshSingleItem", data)
    DlgMgr:sendMsg("MingrzbgrDlg", "refreshPointsNum")
    DlgMgr:sendMsg("MingrzbtpDlg", "MSG_CG_SUPPORT_RESULT", data)
end

-- 更新竞猜主界面某比赛日数据
function MingrzbjcMgr:MSG_CG_DAY_INFO(data)
    self.SC_DAY_JC_DATA[data.day] = data
end

-- 竞猜主界面数据
function MingrzbjcMgr:MSG_CG_INFO(data)
    self.jcData = data

    -- 刷新数据时，同时刷新类别数据
    self:refreshScTypeData()
	if data.isOpen == 1 then
		DlgMgr:openDlg("MingrzbjcDlg")
	end
    DlgMgr:sendMsg("MingrzbjcDlg", "refreshPointsNum")
    DlgMgr:sendMsg("MingrzbgrDlg", "refreshPointsNum")
end

-- 名人争霸要进入录像观战了
function MingrzbjcMgr:MSG_CG_READY_TO_SEND_VIDEO()
    self.isReadyToVideo = true

    -- 背包内使用支持券，自动寻路到npc后进入观战，背包界面还是开着的，策划要求单独关一下背包界面
    DlgMgr:closeDlg("BagDlg")
end

-- 名人争霸赛程表数据
function MingrzbjcMgr:MSG_CG_SCHEDULE(data)
    -- 赛程表数据比赛类别为key
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC128] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC64] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC32] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC16] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC8] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC4] = {}
    self.scScheduleData[MINGRZB_JC_BIG_TYPE.FINAL] = {}
    self.scScheduleData["champion"] = {}

    -- 存储冠军数据
    if data.hasChampion == 1 then
        self.scScheduleData["champion"].teamId = data.championId
        self.scScheduleData["champion"].leaderName = data.championName
    end

    -- 数据有大类存储128,64,32,16,8,4,1
    local count = #data.list
    for i = 1, count do
        local info = data.list[i]
        if info then
            local type
            if i <= 128 then
                type = MINGRZB_JC_BIG_TYPE.JC128
            elseif i > 128 and i <= 192 then
                type = MINGRZB_JC_BIG_TYPE.JC64
            elseif i > 192 and i <= 224 then
                type = MINGRZB_JC_BIG_TYPE.JC32
            elseif i > 224 and i <= 240 then
                type = MINGRZB_JC_BIG_TYPE.JC16
            elseif i > 240 and i <= 248 then
                type = MINGRZB_JC_BIG_TYPE.JC8
            elseif i > 248 and i <= 252 then
                type = MINGRZB_JC_BIG_TYPE.JC4
            else
                type = MINGRZB_JC_BIG_TYPE.FINAL
            end

            table.insert(self.scScheduleData[type], info)
        end
    end

    -- 32进8第2页有数据时才显示第2页
    if #self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC32] == 32 and self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC32][32].isCanUse == 1 then
        MingrzbjcMgr.SC_SCHEDULE_TYPE[MINGRZB_JC_BIG_TYPE.JC32].pageNum = 2
    end

    -- 赛程队伍编号，客户端用来索引
    self.scScheduleTeamIcon = {}
    local typeData = self.scScheduleData[MINGRZB_JC_BIG_TYPE.JC128]
    local index = 1
    for i = 1, #typeData do
        local dayInfo = typeData[i]
        if dayInfo then
            if dayInfo.teamId ~= "" then
                self.scScheduleTeamIcon[dayInfo.teamId] = index
            end

            index = index + 1
        end
    end

    -- 菜单界面还是选定赛程界面的情况下，再打开赛程界面
    local tabDlg = DlgMgr:getDlgByName("MingrzbTabDlg")
    if tabDlg and tabDlg.lastSelectDlg == "MingrzbscDlg" and data.openDlgFlag == 0 then
        local dlg = DlgMgr:openDlg("MingrzbscDlg")
        dlg:refreshDlgInfo()
    end

    -- 菜单界面还是选定赛程界面的情况下，再打开赛程界面
    local tabDlg = DlgMgr:getDlgByName("MingrzbMatchTabDlg")
    if data.openDlgFlag == 1 then
        -- MingrzbscExDlg界面可能在菜单没打开的情况下，由服务器通知直接打开
        if not tabDlg or tabDlg.lastSelectDlg == "MingrzbscExDlg" then
            local dlg = DlgMgr:openDlg("MingrzbscExDlg")
            dlg:refreshDlgInfo()
        end
    end
end

-- 是否可以打开名人争霸赛赛程表
function MingrzbjcMgr:MSG_CG_CAN_OPEN_SECHEDULE(data)
    if data.canOpen == 0 then
        -- 只处理不能打开给提示，能打开时，服务器会发比赛数据走之前逻辑
        gf:ShowSmallTips(CHS[7150065])
    end
end

MessageMgr:regist("MSG_CG_INFO", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_DAY_INFO", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_SUPPORT_RESULT", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_MY_GUESS", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_TEAM_INFO", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_READY_TO_SEND_VIDEO", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_SCHEDULE", MingrzbjcMgr)
MessageMgr:regist("MSG_CG_CAN_OPEN_SECHEDULE", MingrzbjcMgr)

