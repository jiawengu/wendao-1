-- InnMgr.lua
-- Created by lixh Api/19/2018
-- 客栈管理器

InnMgr = Singleton()
local NumImg = require('ctrl/NumImg')
local Progress = require('ctrl/Progress')

-- 客栈家具类型
local INN_FURNITURE_TYPE = {
    TABLE = "table",
    ROOM = "room",
}

-- 桌子基本信息配置
local TABLE_CFG = {
    [0] = {imagePath = ResMgr:getFurniturePath(15000), name = CHS[7120074], upAddDeluxe = 0, buyPrice = 200}, -- 桌椅+1
    [1] = {imagePath = ResMgr:getFurniturePath(15000), name = CHS[7190196], upAddDeluxe = 3, upPrice = 400},  -- 粗木桌椅
    [2] = {imagePath = ResMgr:getFurniturePath(15000), name = CHS[7190196], upAddDeluxe = 3, upPrice = 600},  -- 粗木桌椅
    [3] = {imagePath = ResMgr:getFurniturePath(15001), name = CHS[7190197], upAddDeluxe = 4, upPrice = 1500}, -- 红木桌椅
    [4] = {imagePath = ResMgr:getFurniturePath(15001), name = CHS[7190197], upAddDeluxe = 4, upPrice = 2500}, -- 红木桌椅
    [5] = {imagePath = ResMgr:getFurniturePath(15002), name = CHS[7190198], upAddDeluxe = 0}, -- 鎏金桌椅
}

-- 房间基本信息配置
local ROOM_CFG = {
    [0] = {imagePath = ResMgr:getFurniturePath(15006), closeImagePath = ResMgr:getFurniturePath(15003), name = CHS[7190199], upAddDeluxe = 0, buyPrice = 400}, -- 房间+1
    [1] = {imagePath = ResMgr:getFurniturePath(15006), closeImagePath = ResMgr:getFurniturePath(15003), name = CHS[7190200], upAddDeluxe = 3, upPrice = 800},  -- 人字号房
    [2] = {imagePath = ResMgr:getFurniturePath(15006), closeImagePath = ResMgr:getFurniturePath(15003), name = CHS[7190200], upAddDeluxe = 4, upPrice = 1200}, -- 人字号房
    [3] = {imagePath = ResMgr:getFurniturePath(15007), closeImagePath = ResMgr:getFurniturePath(15004), name = CHS[7190201], upAddDeluxe = 4, upPrice = 2500}, -- 地字号房
    [4] = {imagePath = ResMgr:getFurniturePath(15007), closeImagePath = ResMgr:getFurniturePath(15004), name = CHS[7190201], upAddDeluxe = 5, upPrice = 3500}, -- 地字号房
    [5] = {imagePath = ResMgr:getFurniturePath(15008), closeImagePath = ResMgr:getFurniturePath(15005), name = CHS[7190202], upAddDeluxe = 0}, -- 天字号房
}

-- 客栈地图桌子,房门位置配置
local INN_FURNITURE_POS_CFG = {
    [INN_FURNITURE_TYPE.TABLE] = {{884, 536}, {1076, 440}, {643, 416}, {835, 320}, {1198, 693}, {1391, 597}},
    [INN_FURNITURE_TYPE.ROOM] = {{954, 1379}, {730, 1365}, {451, 1221}, {1221, 1238}, {166, 1068}, {1518, 1081}},
}

-- 客栈桌子基准点
local TABLE_CENTER_POS = {x = 175, y = 100}

-- 客栈npc寻路起点/终点配置
local AUTO_WALK_CFG = {
    ["start"] = {15, 51},
    ["end"] = {18, 49},
     -- 桌子暂时配了两个点
    [INN_FURNITURE_TYPE.TABLE] = {
        {{46, 44, 7}, {36, 46, 3}},
        {{54, 48, 7}, {44, 50, 3}},
        {{36, 49, 7}, {26, 51, 3}},
        {{44, 53, 7}, {34, 55, 3}},
        {{59, 37, 7}, {49, 39, 3}},
        {{67, 41, 7}, {57, 43, 3}},
    },
    -- 房间暂时只配了一个点
    [INN_FURNITURE_TYPE.ROOM] = {
        {{43, 15, 7}},
        {{34, 16, 5}},
        {{22, 22, 5}},
        {{54, 21, 7}},
        {{10, 28, 5}},
        {{66, 28, 7}},
    }
}

-- 客栈桌子播放坐的动作位置
local INN_SIT_ACTION_POS = {
    {{1049, 483}, {937, 435}},
    {{1235, 387}, {1123, 339}},
    {{808, 363}, {696, 315}},
    {{1000, 267}, {888, 219}},
    {{1364, 640}, {1252, 592}},
    {{1556, 547}, {1444, 499}},
}

-- 客栈桌子摆放菜肴的位置
local INN_TABLE_FOOD_POS = {
    {{984, 476}, {949, 461}},
    {{1170, 380}, {1135, 365}},
    {{743, 356}, {708, 341}},
    {{935, 260}, {900, 245}},
    {{1299, 633}, {1264, 618}},
    {{1491, 540}, {1456, 525}},
}

local INN_GUEST_CFG = {
    {name = CHS[5400719], icon = 6012}, -- "段铁心",
    {name = CHS[5400720], icon = 6012}, -- "大胡子",
    {name = CHS[5400721], icon = 6012}, -- "猎户",
    {name = CHS[5400722], icon = 6012}, -- "铁匠",
    {name = CHS[5400723], icon = 6012}, -- "莽夫",
    {name = CHS[5400724], icon = 6012}, -- "李壮汉",
    {name = CHS[5400725], icon = 6013}, -- "贾仁和",
    {name = CHS[5400726], icon = 6013}, -- "郝艾佳",
    {name = CHS[5400727], icon = 6013}, -- "布庄老板",
    {name = CHS[5400728], icon = 6013}, -- "卜姑娘",
    {name = CHS[5400729], icon = 6013}, -- "大龄未婚女",
    {name = CHS[5400730], icon = 6013}, -- "李裁缝",
    {name = CHS[5400731], icon = 6018}, -- "黄仨儿",
    {name = CHS[5400732], icon = 6018}, -- "掌门独子",
    {name = CHS[5400733], icon = 6018}, -- "熊孩子",
    {name = CHS[5400734], icon = 6018}, -- "小娃娃",
    {name = CHS[5400735], icon = 6018}, -- "有钱的小孩",
    {name = CHS[5400736], icon = 6018}, -- "小吃货",
    {name = CHS[5400737], icon = 6019}, -- "莲花姑娘",
    {name = CHS[5400738], icon = 6019}, -- "白素",
    {name = CHS[5400739], icon = 6019}, -- "窈窕淑女",
    {name = CHS[5400740], icon = 6019}, -- "揽仙镇镇花",
    {name = CHS[5400741], icon = 6019}, -- "卿本佳人",
    {name = CHS[5400742], icon = 6019}, -- "李嫣然",
    {name = CHS[5400743], icon = 6033}, -- "杨镖头",
    {name = CHS[5400744], icon = 6033}, -- "总教头",
    {name = CHS[5400745], icon = 6033}, -- "练武之人",
    {name = CHS[5400746], icon = 6033}, -- "用枪高手",
    {name = CHS[5400747], icon = 6033}, -- "英俊的大叔",
    {name = CHS[5400748], icon = 6033}, -- "李燕然",
    {name = CHS[5400749], icon = 6035}, -- "董老头",
    {name = CHS[5400750], icon = 6035}, -- "林老汉",
    {name = CHS[5400751], icon = 6035}, -- "王爷爷",
    {name = CHS[5400752], icon = 6035}, -- "赵大爷",
    {name = CHS[5400753], icon = 6035}, -- "怪老头",
    {name = CHS[5400754], icon = 6035}, -- "李爷爷",
    {name = CHS[5400755], icon = 6240}, -- "晶晶儿",
    {name = CHS[5400756], icon = 6240}, -- "牧童",
    {name = CHS[5400757], icon = 6240}, -- "帮派书童",
    {name = CHS[5400758], icon = 6240}, -- "放牛娃",
    {name = CHS[5400759], icon = 6240}, -- "善于采药的小孩儿"
    {name = CHS[5400760], icon = 6240}, -- "李晶",
}

-- 客栈房门进度条旋转角
local INN_ROOM_MAGIC_ROTATION = {left = 333, right = 27}

-- 候客区椅子资源配置
local DESK_IMAGE_PATH = ResMgr:getFurniturePath(10013)

-- 候客区升级花费
local WAIT_UPGRADE_COST = {
    50,
    150,
    300,
    600,
    1500,
    3000,
    5000,
    0,    -- 8级为最高等级，不会升级到下1等级
}

-- 客栈乞丐类型
local INN_BEGGAR_TYPE = {
    INN_BEGGAR_NONE = 0, -- 无
    INN_BEGGAR_BE = 1,   -- 报恩
    INN_BEGGAR_NS = 2,   -- 闹事
}

-- 客栈客人状态
local INN_GUEST_STATE = {
    NONE = 0,     -- 无
    GO_IN = 1,    -- 进入
    ARRIVE = 2,   -- 到达
    PAY = 3,      -- 买单
    GO_OUT = 4,   -- 离开
}

InnMgr.baseData = {}
InnMgr.waitData = {}
InnMgr.furnitures = {}
InnMgr.paths = {}
InnMgr.food = {}
InnMgr.manualData = nil
InnMgr.addTcoinMagicFlag = false

-- 客栈休息时间
local INN_SLEEP_TIME = {BEGIN = 0, END = 8}

-- 客栈家具总数量(table + room)
local MAX_FURNITURE_NUM = 12

-- 客栈内客人行走速度
local SPEED_PERCENT = 0.7

-- 采集图片资源
local INN_GATHER_RES = {
    [INN_FURNITURE_TYPE.TABLE] = {
        ResMgr.ui.inn_food_bubber_one,      -- 客栈菜肴气泡图片1
        ResMgr.ui.inn_food_bubber_two,      -- 客栈菜肴气泡图片2
        ResMgr.ui.inn_food_bubber_three,    -- 客栈菜肴气泡图片3
        ResMgr.ui.inn_food_bubber_four,     -- 客栈菜肴气泡图片4
        ResMgr.ui.inn_food_bubber_five,     -- 客栈菜肴气泡图片5
    },

    [INN_FURNITURE_TYPE.ROOM] = {
        ResMgr.ui.inn_room_bubber_one,     -- 客栈房间气泡图片1 1级
        ResMgr.ui.inn_room_bubber_one,     -- 客栈房间气泡图片1 2级
        ResMgr.ui.inn_room_bubber_two,     -- 客栈房间气泡图片2 3级
        ResMgr.ui.inn_room_bubber_two,     -- 客栈房间气泡图片2 4级
        ResMgr.ui.inn_room_bubber_three,   -- 客栈房间气泡图片3 5级
    },

    ["bg"] = ResMgr.ui.inn_gather_bubber,
    ["coin"] = ResMgr.ui.inn_coin_magic,
}

-- 采集进度条描述资源
local INN_GATHER_DES = {
    [INN_FURNITURE_TYPE.TABLE] = CHS[7190204],
    [INN_FURNITURE_TYPE.ROOM] = CHS[7190205],
}

-- 获取客栈地图家具位置配置
function InnMgr:getInnFurniturePosCfg()
    return INN_FURNITURE_POS_CFG
end

-- 爱心光效配置，需要两个座位上的npc名字都在下表中
local LOVE_EFFECT_CFG = {
    [CHS[7150075]] = CHS[7150076],  -- 杨镖头
    [CHS[7150076]] = CHS[7150075],  -- 莲花姑娘
}

-- 客栈客人喊话配置
local GUEST_PROPAGANDA = {
    [06012] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120084], CHS[7120085]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120095], CHS[7120096], CHS[7120097]},
    },
    [06013] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120086], CHS[7120087]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120098], CHS[7120099], CHS[7120101]},
    },
    [06018] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120088]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120102], CHS[7120103]},
    },
    [06019] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120089], CHS[7120090]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120104], CHS[7120105], CHS[7120106]},
    },
    [06033] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120091], CHS[7120092]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120107], CHS[7120108], CHS[7120109]},
    },
    [06035] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120093]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120110], CHS[7120111]},
    },
    [06240] = {
        [INN_FURNITURE_TYPE.TABLE] = {CHS[7120083], CHS[7120094]},
        [INN_FURNITURE_TYPE.ROOM]  = {CHS[7120112], CHS[7120113]},
    },
}

-- 客栈手册任务状态
local MANUAL_TASK_STATUS = {
    HAVE_NOT_GOT = 0,   -- 未领取
    HAVE_GOT = 1,       -- 已领取
}

-- 获取客栈手册任务状态配置
function InnMgr:getManualTaskStatus()
    return MANUAL_TASK_STATUS
end

-- 客人离开房间、桌子时需要喊话
function InnMgr:setGuestPropaganda(guestInfo)
    if not guestInfo then return end
    local guestId = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos, true)
    local char = CharMgr:getCharById(guestId)
    if not char then return end

    local strList = GUEST_PROPAGANDA[guestInfo.preIcon][guestInfo.type]
    local str = strList[math.random(1, #strList)]

    ChatMgr:sendCurChannelMsgOnlyClient({
        id = char:getId(),
        gid = 0,
        icon = char:queryBasicInt("icon"),
        name = char:getName(),
        msg =  str,
    })
end

-- 获取客栈采集图片资源
function InnMgr:getInnGatherByType(type, guestInfo)
    local pic = INN_GATHER_RES["coin"]
    if type ~= "coin" and guestInfo then
        if guestInfo.type == INN_FURNITURE_TYPE.ROOM then
            -- 房间需要取对应房间等级房门的图片
            local roomInfo = InnMgr:getFurnitureInfo(guestInfo.type, guestInfo.id)
            if not roomInfo then return end
            pic = INN_GATHER_RES[guestInfo.type][roomInfo.level]
        elseif guestInfo.type == INN_FURNITURE_TYPE.TABLE then
            -- 桌子需要取服务器随机到的bubberId
            pic = INN_GATHER_RES[guestInfo.type][guestInfo.bubbleId]
        end
    end

    return {bg = INN_GATHER_RES["bg"], pic = pic}
end

-- 获取客栈采集图片资源
function InnMgr:getInnGatherDesByType(type)
    return INN_GATHER_DES[type]
end

-- 获取客栈家具类型
function InnMgr:getInnFurnitureType()
    return INN_FURNITURE_TYPE
end

-- 获取客栈乞丐类型
function InnMgr:getInnBeggarType()
    return INN_BEGGAR_TYPE
end

-- 获取客栈客人类型
function InnMgr:getInnGuestType()
    return INN_GUEST_STATE
end

-- 桌子基本信息配置
function InnMgr:getInnTabelCfg()
    return TABLE_CFG
end

-- 房间基本信息配置
function InnMgr:getInnRoomCfg()
    return ROOM_CFG
end

-- 椅子基本信息配置
function InnMgr:getInnDeskImagePath()
    return DESK_IMAGE_PATH
end

-- 获取当前候客区升级花费
function InnMgr:getInnUpgradeCost()
    local waitData = InnMgr:getWaitData()
    return WAIT_UPGRADE_COST[waitData.level]
end


-- 是否处于客栈休息期
function InnMgr:isInnSleepTime()
    local hour = tonumber(os.date("%H", os.time()))
    if hour >= INN_SLEEP_TIME.BEGIN and hour < INN_SLEEP_TIME.END then
        return true
    end
end

-- 是否客满
function InnMgr:isInnFullGuest()
    local guestData = InnMgr:getGuestData()
    local count = 0
    for k, v in pairs(guestData) do
        if k then
            count = count + 1
        end
    end

    if count >= MAX_FURNITURE_NUM then
        return true
    end
end

-- 获取乞丐事件
function InnMgr:getInnBeggarEventType()
    local waitData = InnMgr:getWaitData()
    local serverTime = gf:getServerTime()
    if waitData and waitData.beggerEndTime and waitData.beggerEndTime > serverTime then
        return waitData.beggerType
    end

    return INN_BEGGAR_TYPE.INN_BEGGAR_NONE
end

-- 开始客栈定时器
function InnMgr:startSchedule()
    if not self.scheduleId then
        self.scheduleId = gf:Schedule(function()
            -- 观察npc是否到达终点
            InnMgr:checkGuestArriveEndPos()
        end, 0.5)
    end
end

-- 停止客栈定时器
function InnMgr:clearSchedule()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

-- 获取客栈寻路路径
function InnMgr:getAutoWalkPath(guestInfo)
    if not guestInfo then return end
    if not self.paths or not self.paths[guestInfo.type] or not self.paths[guestInfo.id] then
        -- 没有路径信息，先生成
        InnMgr:initAutoWalkPath()
    end

    return self.paths[guestInfo.type][guestInfo.id][guestInfo.pos]
end

-- 生成客栈寻路路径，与从起始点走到终点的时间(秒)，时间的计算参考Me走路的速度
function InnMgr:initAutoWalkPath()
    if self.paths and self.paths[INN_FURNITURE_TYPE.TABLE] and self.paths[INN_FURNITURE_TYPE.ROOM] then
        -- 已经初始化过了
        return
    end

    local cfg = AUTO_WALK_CFG
    local startX, startY = gf:convertToClientSpace(cfg["start"][1], cfg["start"][2])
    local sceneH = GameMgr:getSceneHeight()
    local speed = 0.2 * SPEED_PERCENT

    self.paths = {}
    self.paths[INN_FURNITURE_TYPE.TABLE] = {}
    local tableCfg = cfg[INN_FURNITURE_TYPE.TABLE]
    for i = 1, #tableCfg do
        self.paths[INN_FURNITURE_TYPE.TABLE][i] = {}

        local table = tableCfg[i]
        for j = 1, #table do
            local _, path = gf:findPath(nil, table[j][1], table[j][2], startX, startY)
            local paths = {}
            local count = path:QueryInt("count")
            local length = 0
            for k = 1, count do
                local x = path:QueryInt(string.format("x%d", k)) * Const.MAP_SCALE
                local y = sceneH - path:QueryInt(string.format("y%d", k)) * Const.MAP_SCALE
                if k == count then
                    length = path:QueryInt(string.format("len%d", k)) * Const.MAP_SCALE
                end
                local mapX, mapY = gf:convertToMapSpace(x, y)
                paths[k] = {mapX, mapY}
            end

            self.paths[INN_FURNITURE_TYPE.TABLE][i][j] = {path = paths, time = length / speed / 1000}
        end
    end

    self.paths[INN_FURNITURE_TYPE.ROOM] = {}
    local roomCfg = cfg[INN_FURNITURE_TYPE.ROOM]
    for i = 1, #roomCfg do
        self.paths[INN_FURNITURE_TYPE.ROOM][i] = {}

        local room =  roomCfg[i]
        for j = 1, #room do
            local _, path = gf:findPath(nil, room[j][1], room[j][2], startX, startY)
            local paths = {}
            local count = path:QueryInt("count")
            local length = 0
            for k = 1, count do
                local x = path:QueryInt(string.format("x%d", k)) * Const.MAP_SCALE
                local y = sceneH - path:QueryInt(string.format("y%d", k)) * Const.MAP_SCALE
                if k == count then
                    length = path:QueryInt(string.format("len%d", k)) * Const.MAP_SCALE
                end
                local mapX, mapY = gf:convertToMapSpace(x, y)
                paths[k] = {mapX, mapY}
            end

            self.paths[INN_FURNITURE_TYPE.ROOM][i][j] = {path = paths, time = length / speed / 1000}
        end
    end
end

-- 获取基本数据
function InnMgr:getBaseData()
    return self.baseData
end

-- 获取候客区数据
function InnMgr:getWaitData()
    return self.waitData
end

-- 获取客人数据
function InnMgr:getGuestData()
    return self.guestData
end

-- 根据客人信息获取家具
function InnMgr:getFurnitureByGuestInfo(guestInfo)
    if not guestInfo then return end

    if self.furnitures[guestInfo.type] and self.furnitures[guestInfo.type][guestInfo.id] then
        return self.furnitures[guestInfo.type][guestInfo.id]
    end
end

-- 获取客栈地图npc的id
function InnMgr:getNpcId(type, id, pos, isBack)
    local charId = id * 10 + pos
    if type == INN_FURNITURE_TYPE.TABLE then
        charId = charId + 200
    else
        charId = charId + 300
    end

    if isBack then
        -- 回程的客人id * 10
        charId = charId * 10
    end

    return charId
end

-- 判断地图上客人是否已经到终点
function InnMgr:checkGuestArriveEndPos()
    local guestData = InnMgr:getGuestData()
    if not guestData then return end
    for k, v in pairs(guestData) do
        local guestInfo = v
        if guestInfo then
            if guestInfo.state == INN_GUEST_STATE.GO_IN or guestInfo.state == INN_GUEST_STATE.GO_OUT
                or guestInfo.preState == INN_GUEST_STATE.GO_OUT then
                -- 客栈内，正在进入/正在退出的客人，需要检测是否到达目的地
                local id
                local endPos
                if guestInfo.preState == INN_GUEST_STATE.GO_OUT then
                    id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos, true)
                    endPos = AUTO_WALK_CFG["end"]
                else
                    id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
                    endPos = AUTO_WALK_CFG[guestInfo.type][guestInfo.id][guestInfo.pos]
                end

                local char = CharMgr:getCharById(id)
                if char then
                    local curX, curY = gf:convertToMapSpace(char.curX, char.curY)
                    if curX == endPos[1] and curY == endPos[2] then
                        -- 到达目的地，通知服务器切换状态
                        if guestInfo.preState == INN_GUEST_STATE.GO_OUT then
                            InnMgr:sendGuestStatusToServer(guestInfo, INN_GUEST_STATE.GO_OUT)
                        else
                            -- 策划要求客人到达桌子，房间时立即改变方向，回程不需要改变方向
                            if endPos[3] then
                                char:setDir(endPos[3])

                                performWithDelay(gf:getUILayer(), function()
                                    InnMgr:sendGuestStatusToServer(guestInfo, INN_GUEST_STATE.GO_IN)
                                end, 0.3)
                            else
                                InnMgr:sendGuestStatusToServer(guestInfo, INN_GUEST_STATE.GO_IN)
                            end
                        end
                    end
                end
            elseif guestInfo.state == INN_GUEST_STATE.ARRIVE then
                -- 防止服务器已经通知客户端客人已经到达了，客户端退出客栈再重新进入有时间误差，有可能让客人继续行走，所以
                -- 时时将ARRIVE状态的客人设置到终点同时设置动作
                local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
                local char = CharMgr:getCharById(id)
                if char then
                if guestInfo.type == INN_FURNITURE_TYPE.TABLE then
                    InnMgr:setGuestArriveTable(char, Const.SA_SIT, guestInfo)
                else
                    InnMgr:setGuestArriveRoom(char, guestInfo)
                end
            end
        end
    end
    end
end

-- 客人到达椅子上
function InnMgr:setGuestArriveTable(char, act, guestInfo)
    if char and char.charAction and (char.charAction.action == Const.SA_SIT
        or char.charAction.action == Const.SA_EAT) then
        -- 已经处于坐，吃饭的客人，不需要刷新到达椅子上
        return
    end

    InnMgr:setGuestBasicStatus(guestInfo.type, char, Const.SA_SIT, guestInfo.pos, guestInfo.id)

    performWithDelay(gf:getUILayer(), function()
        if not char.isInAction then
            char:setBubberAction(INN_FURNITURE_TYPE.TABLE)
        end
    end, 0.5)

    -- 客人到达椅子上后，检查是否播放特效
    if self:canAddLoveEffect(guestInfo) then
        self:addLoveEffect(guestInfo)
    end
end

-- 客人播放动作
function InnMgr:setGuestBasicStatus(type, char, act, pos, id)
    if act then
        char.charAction:setAction(act)
    end

    if type == INN_FURNITURE_TYPE.TABLE then
        -- 桌子客人固定两个方向，桌子pos有两个值：1右上，2左下
        if pos == 1 then
            char:setDir(7)
        else
            char:setDir(3)
        end

        if id and pos then
            local pos = INN_SIT_ACTION_POS[id][pos]
            char:setPos(pos[1], pos[2])
        end
    elseif type == INN_FURNITURE_TYPE.ROOM then
        -- 房间客人朝向与房间编号有关
        if id == 1 or id == 4 or id == 6 then
            char:setDir(7)
        else
            char:setDir(5)
        end

        if id and pos then
            local cfgPos = AUTO_WALK_CFG[type][id][1]
            local x, y = gf:convertToClientSpace(cfgPos[1], cfgPos[2])
            char:setPos(x, y)
        end
    end
end

-- 获取播放金币增加动画标记
function InnMgr:getPlayAddCoinFlag()
    return self.addTcoinMagicFlag
end

-- 设置播放金币增加动画标记
function InnMgr:setPlayAddCoinFlag(flag)
    self.addTcoinMagicFlag = flag
end

-- 当前获得金币播放动画的动作名
function InnMgr:getCoinMagicActionName()
    local coinNum = InnMgr:getMagicCoinNum()
    if coinNum < 10 then
        return "Top03"
    elseif coinNum < 20 then
        return "Top02"
    else
        return "Top01"
    end
end

-- 播放金币点击后的效果
function InnMgr:playCoinAction(coin, guestInfo)
    local magicLayer = gf:getUILayer():getChildByName("InnMagicLayer")
    if not magicLayer then return end

    local sz = coin:getContentSize()
    local pos = coin:convertToWorldSpace(cc.p(0, 0))
    local x = pos.x + sz.width / 2
    local y = pos.y + sz.height / 2

    -- 金币炸开效果
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.inn_bomb_coin.name,
        InnMgr:getCoinMagicActionName(), magicLayer, nil, nil, nil, x, y)

    -- + num 数字图片上移效果
    local numImg = NumImg.new('sfight_num', InnMgr:getMagicCoinNum(), true, 0, 0.8)
    numImg:setScale(1.4)
    numImg:setAnchorPoint(0.5, 0.5)
    numImg:setPosition(x, y)
    magicLayer:addChild(numImg)
    numImg:startMove(1, cc.p(x, y + 80))

    -- 策划要求点击金币后，0.5秒后再通知服务器，买单离开
    performWithDelay(gf:getUILayer(), function()
    -- 更新需要播放金币增加动画标记
    InnMgr:setPlayAddCoinFlag(true)

        InnMgr:sendGuestStatusToServer(guestInfo, INN_GUEST_STATE.PAY)
    end, 0.5)
end

-- 获取当前采集的金币的数量
function InnMgr:getMagicCoinNum()
    local baseData = InnMgr:getBaseData()
    if not baseData then return 0 end

    return math.floor(baseData.deluxe / 10)
end

-- 客人到达房门播放气泡动画
function InnMgr:setGuestArriveRoom(char, guestInfo)
    InnMgr:setGuestBasicStatus(guestInfo.type, char, Const.SA_STAND, guestInfo.pos, guestInfo.id)

    performWithDelay(gf:getUILayer(), function()
        if not char.isInAction then
            char:setBubberAction(INN_FURNITURE_TYPE.ROOM)
        end
    end, 0.5)
end

-- 刷新客人到达房门气泡动画(没有气泡不刷新)
function InnMgr:refreshRoomGuestBubber(id)
    local char = CharMgr:getCharById(InnMgr:getNpcId(INN_FURNITURE_TYPE.ROOM, id, 1))
    if char and not char.gatherBubber then
        -- 客人头顶没有气泡，不刷新(也许客人为行走状态)
        return
    end

    if char then
        char:setBubberAction(INN_FURNITURE_TYPE.ROOM)
    end
end

-- 创建休息中/用餐中动画
function InnMgr:createProgressTextMagic(type)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.inn_barprogress_des.name)
    if type == INN_FURNITURE_TYPE.TABLE then
        magic:getAnimation():play("Top01")
    else
        magic:getAnimation():play("Top02")
    end

    return magic
end

-- 客人进入房间后，关门，播进度条
function InnMgr:changeRoomStatus(char)
    local guestInfo = char.guestInfo
    local furniture = InnMgr:getFurnitureByGuestInfo(guestInfo)
    if not furniture then return end
    InnMgr:refreshInnFurniture(INN_FURNITURE_TYPE.ROOM, nil, guestInfo.id, true)
    char:setVisible(false)

    -- 关门后，门上要出现进度条
    furniture = InnMgr:getFurnitureByGuestInfo(guestInfo)
    InnMgr:addBarProgressToRoom(furniture, char)
end

-- 房门关上后，客人进入休息状态，房门添加进度条
function InnMgr:addBarProgressToRoom(furniture, char)
    local function callBack()
        char:clearSchedule()
        if furniture.gatherMagic then
            furniture.gatherMagic:removeFromParent()
            furniture.gatherMagic = nil
        end

        furniture.barProgress:setVisible(false)
        char:setVisible(true)

        -- 客人出来后，门打开
        local type = INN_FURNITURE_TYPE.ROOM
        local id = char.guestInfo.id
        local roomInfo = InnMgr:getFurnitureInfo(type, id)
        if not roomInfo then return end

        -- 房门等级以最新数据为准，也许客人休息过程中房间升级了
        local level = roomInfo.level or self.furnitures[type][id].level
        InnMgr:refreshInnFurniture(type, level, id, true)
        InnMgr:sendGuestStatusToServer(char.guestInfo, INN_GUEST_STATE.ARRIVE)
    end

    -- 进度条
    if not furniture.barProgress then
        furniture.barProgress = Progress.new(ResMgr.ui.inn_bar_bg, ResMgr.ui.inn_bar_content)
        furniture:addChild(furniture.barProgress)
    end

    local sz = furniture:getContentSize()
    furniture.barProgress:setVisible(true)
    furniture.barProgress:setPercent(0)

    -- 进度条上放动画表现
    if furniture.gatherMagic then
        furniture.gatherMagic:removeFromParent()
        furniture.gatherMagic = nil
    end

    furniture.gatherMagic = InnMgr:createProgressTextMagic(INN_FURNITURE_TYPE.ROOM)
    furniture:addChild(furniture.gatherMagic)

    -- 房门需要动画需要旋转一个角度，位置也要做一个便宜，因为左右房门不一样
    local posOffset = -20
    local angle = INN_ROOM_MAGIC_ROTATION.left
    if char.guestInfo.id == 1 or char.guestInfo.id == 4 or char.guestInfo.id == 6 then
        angle = INN_ROOM_MAGIC_ROTATION.right
        posOffset = -posOffset
    end

    furniture.gatherMagic:setRotation(angle)
    furniture.barProgress:setRotation(angle)
    furniture.barProgress:setPosition(sz.width / 2 + posOffset, sz.height / 2)
    furniture.gatherMagic:setPosition(sz.width / 2 + posOffset, sz.height / 2 + 20)

    local times = math.random(5, 8) / 0.2
    local tickTime = 0
    local curTime = gf:getServerTime()
    local leftTime = char.guestInfo.barStartTime + char.guestInfo.barDuaration - curTime
    char.guestInfo.barStartTime = math.min(char.guestInfo.barStartTime, curTime)

    if char.guestInfo.barStartTime > 0 and char.guestInfo.barDuaration > 0 then
        if leftTime > 0 then
            -- 进度条需要从中间位置开始读
            times = math.floor(char.guestInfo.barDuaration / 0.2)
            tickTime = (curTime - char.guestInfo.barStartTime) / 0.2
        else
            -- 时间已经到了，直接回调切换状态
            callBack()
            return
        end
    else
        char.guestInfo.barStartTime = curTime
        char.guestInfo.barDuaration = times / 5
        InnMgr:cmdStartBarprogressToServer(INN_FURNITURE_TYPE.ROOM, char.guestInfo.id,
            char.guestInfo.pos, curTime, char.guestInfo.barDuaration)
    end

    -- 播放进度条与文字表现
    if not char.scheduleId then

        local maxNotUpTimeTicks = 0
        local countNotUpTimeTicks = 0
        local lastServerTime = 0

        char.scheduleId = gf:Schedule(function()
            tickTime = tickTime + 1
            local percent = tickTime / times * 100
            furniture.barProgress:setPercent(percent)

            local curTime = gf:getServerTime()
            if curTime <= lastServerTime then
                -- schedule tick 之后 时间没有增长，累计时间没有增加时 tick 的次数
                countNotUpTimeTicks = countNotUpTimeTicks + 1
                maxNotUpTimeTicks = math.max(maxNotUpTimeTicks, countNotUpTimeTicks)
            else
                countNotUpTimeTicks = 0
            end

            lastServerTime = curTime

            if tickTime >= times then
                callBack()
            end
        end, 0.2)
    end
end

-- 通知服务器记录异常日志
function InnMgr:cmdLogException(type, log)
    gf:CmdToServer("CMD_LOG_INN_EXCEPTION", {type = type, log = log})
end

-- 通知服务器开始读条
function InnMgr:cmdStartBarprogressToServer(type, id, pos, startTime, duration)
    gf:CmdToServer("CMD_INN_ENTERTAIN_GUEST", {type = type, id = id, pos = pos, startTime = startTime, duration = duration})
end

-- 获取桌子菜肴编号
function InnMgr:getFoodIndex(guestInfo)
    if guestInfo then
        return guestInfo.id * 10 + guestInfo.pos
    end
end

-- 移除菜肴
function InnMgr:removeFood(index)
    if not InnMgr.food[index] then
        -- 该菜肴已移除
        return
    end

    InnMgr.food[index]:removeFromParent()
    InnMgr.food[index] = nil
end

-- 摆放菜肴
function InnMgr:addFood(type, guestInfo)
    if type ~= INN_FURNITURE_TYPE.TABLE or not guestInfo then return end

    local index = InnMgr:getFoodIndex(guestInfo)
    if InnMgr.food[index] then
        -- 已存在该菜肴，先移除
        InnMgr:removeFood(index)
    end

    -- 桌子上摆放的菜肴与客人头顶菜肴是相同资源
    local imageCfg = InnMgr:getInnGatherByType(type, guestInfo)
    if imageCfg and imageCfg.pic then
        local image = ccui.ImageView:create(imageCfg.pic)
        image:setAnchorPoint(0, 0)
        image:setScale(0.8)

        local pos = INN_TABLE_FOOD_POS[guestInfo.id][guestInfo.pos]
        image:setPosition(cc.p(pos[1], pos[2]))
        gf:getMapObjLayer():addChild(image, 1000)
        InnMgr.food[index] = image
    end
end

-- 获取生成客人的坐标x, y
function InnMgr:getBornGuestPos(guestInfo, isBack)
    local atStartPos = false
    local pathInfo = InnMgr:getAutoWalkPath(guestInfo)
    local path = pathInfo.path
    local lenth = #path
    local x, y = AUTO_WALK_CFG["start"][1], AUTO_WALK_CFG["start"][2]
    if isBack then
        x, y = path[lenth][1], path[lenth][2]
    end

    -- offsetVal为延迟出生时间，0.5为定时间检测开始走的时间间隔
    local startGoTime = guestInfo.startTime + guestInfo.offsetVal / 10 + 0.5
    if isBack then
        startGoTime = guestInfo.preStartTime + 0.5
    end

    local curTime = gf:getServerTime()
    if curTime - startGoTime > pathInfo.time then
        -- 时间已经过了，直接到终点
        if isBack then
            x, y = AUTO_WALK_CFG["end"][1], AUTO_WALK_CFG["end"][2]
        else
            x, y = path[lenth][1], path[lenth][2]
        end
    elseif curTime - startGoTime > pathInfo.time / 2 then
        -- 时间已经过了一半，则从中间开始走
        local index = math.ceil(lenth / 2)
        x, y = path[index][1], path[index][2]
    else
        atStartPos = true
    end

    return x, y, atStartPos
end

-- 客栈地图生成客人
function InnMgr:bornGuest(guestInfo, isBack)
    if guestInfo then
        if not isBack then
            if guestInfo.state ~= INN_GUEST_STATE.NONE then
                local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
                local char = CharMgr:getCharById(id)
                if not char then
                    local x, y = InnMgr:getBornGuestPos(guestInfo)
                    InnMgr:appearGuest(guestInfo, x, y, id, guestInfo.name, guestInfo.icon)
                end
            end
        else
            -- 回程的客人
            if guestInfo.preState ~= INN_GUEST_STATE.NONE and guestInfo.preName ~= "" then
                local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos, true)
                local char = CharMgr:getCharById(id)
                if not char then
                    local x, y = InnMgr:getBornGuestPos(guestInfo, true)
                    InnMgr:appearGuest(guestInfo, x, y, id, guestInfo.preName, guestInfo.preIcon)
                end
            end
        end
    end
end

-- 生成客人
function InnMgr:appearGuest(guestInfo, x, y, id, name, icon)
    CharMgr:MSG_APPEAR({x = x, y = y, dir = 1, id = id, icon = icon,
        type = OBJECT_TYPE.INN_GUEST, name = name, opacity = 0,
        light_effect_count = 0, isNowLoad = true})

    local char = CharMgr:getCharById(id)
    char:setVisible(true)
    char:setSeepPrecent((SPEED_PERCENT - 1) * 100)
    char.guestInfo = guestInfo
end

-- 设置客栈地图客人状态
function InnMgr:setGuestStatus(guestInfo, isBack)
    if not guestInfo then return end

    if not isBack then
        local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
        local char = CharMgr:getCharById(id)
        if not char then return end

        char.guestInfo = guestInfo
        if guestInfo.state == INN_GUEST_STATE.NONE then
            -- 析构客人
            InnMgr:releaseGuest(id)
        elseif guestInfo.state == INN_GUEST_STATE.GO_IN then
            -- 进入，计算开始走的位置，并走向终点
            if char.charAction and char.charAction.action == Const.SA_SIT then return end
            InnMgr:setGuestPos(guestInfo, char)
        elseif guestInfo.state == INN_GUEST_STATE.ARRIVE then
            -- 到达，桌子客人坐下，房间客人进门
            if guestInfo.type == INN_FURNITURE_TYPE.TABLE then
                InnMgr:setGuestArriveTable(char, Const.SA_SIT, guestInfo)
            else
                InnMgr:setGuestArriveRoom(char, guestInfo)
            end
        elseif guestInfo.state == INN_GUEST_STATE.PAY then
            -- 买单状态，先把客人放在终点
            if guestInfo.type == INN_FURNITURE_TYPE.TABLE then
                InnMgr:setGuestArriveTable(char, Const.SA_SIT, guestInfo)
            else
                InnMgr:setGuestArriveRoom(char, guestInfo)
            end

            -- 买单阶段，客人头顶增加金币气泡
            char:setBubberAction("coin")
        elseif guestInfo.state == INN_GUEST_STATE.GO_OUT then
            -- 离开，计算往回走的位置，并走向终点
            InnMgr:setGuestBack(guestInfo, char)
        end
    else
        -- 回去的客人
        local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos, true)
        if guestInfo.preState == INN_GUEST_STATE.NONE then
            -- 析构客人
            InnMgr:releaseGuest(id)
        elseif guestInfo.preState == INN_GUEST_STATE.GO_OUT then
            -- 正在往回走
            local char = CharMgr:getCharById(id)
            if char then
                InnMgr:setGuestBack(guestInfo, char)
            end
        end
    end
end

-- 设置npc走回起点
function InnMgr:setGuestBack(info, char)
    local pathInfo = InnMgr:getAutoWalkPath(info)
    local path = pathInfo.path
    local lenth = #path
    local endX, endY = AUTO_WALK_CFG["end"][1], AUTO_WALK_CFG["end"][2]
    char:setEndPos(endX, endY)

    -- 回程客人尝试移除特效
    InnMgr:removeLoveEffect(info)
end

-- 设置npc走向终点
function InnMgr:setGuestPos(info, char)
    local pathInfo = InnMgr:getAutoWalkPath(info)
    local path = pathInfo.path
    local lenth = #path
    local endX, endY = path[lenth][1], path[lenth][2]
    char:setEndPos(endX, endY)
end

-- 析构所有客人
function InnMgr:releaseAllGuest()
    local guestData = InnMgr:getGuestData()
    if not guestData then return end

    for k, v in pairs(guestData) do
        local guestInfo = v
        if guestInfo then
            local id = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
            CharMgr:deleteChar(id)
        end
    end
end

-- 析构客人npc
function InnMgr:releaseGuest(id)
    CharMgr:deleteChar(id)
end

-- 根据id获取家具信息
function InnMgr:getFurnitureInfo(type, id)
    local baseData = InnMgr:getBaseData()
    local data
    if type == INN_FURNITURE_TYPE.TABLE then
        data = baseData.tableInfo
    else
        data = baseData.roomInfo
    end

    if data then
        return data[id]
    end
end

-- 客栈地图添加家具
function InnMgr:addFurniture()
    local baseData = InnMgr:getBaseData()
    if not baseData then return end

    -- 添加桌子
    for i = 1, baseData.tableCount do
        local info = baseData.tableInfo[i]
        if info then
            InnMgr:refreshInnFurniture(INN_FURNITURE_TYPE.TABLE, info.level, info.id)
        end
    end

    -- 添加房间
    for i = 1, baseData.roomCount do
        local info = baseData.roomInfo[i]
        if info then
            InnMgr:refreshInnFurniture(INN_FURNITURE_TYPE.ROOM, info.level, info.id)
        end
    end
end

-- 刷新地图上tyep,id对应的家具
-- type: table, room
-- id : 1-6 对应策划文档中的编号
function InnMgr:refreshInnFurniture(type, level, id, isClose)
    if not self.furnitures[type] then self.furnitures[type] = {} end
    local imagePath
    if type == INN_FURNITURE_TYPE.ROOM then
        if level then
            imagePath = InnMgr:getInnRoomCfg()[level].imagePath
        end
    else
        imagePath = InnMgr:getInnTabelCfg()[level].imagePath
    end

    if not isClose and level and self.furnitures[type][id] and level == self.furnitures[type][id].level then
        -- 刷新房门为开门状态时，若当前已有家具与需要添加的相同，直接返回
        return
    end

    if not level then
        -- 房门替换资源
        level = self.furnitures[type][id].level
        imagePath = InnMgr:getInnRoomCfg()[level].closeImagePath
    end

    -- 已经创建了家具，且对于家具正在播放进度条动画(房门)，则刷新为对应等级的关门状态图片
    if self.furnitures[type][id] and self.furnitures[type][id].barProgress
        and self.furnitures[type][id].barProgress:isVisible() then
        imagePath = InnMgr:getInnRoomCfg()[level].closeImagePath
    end

    if self.furnitures[type][id] then
        -- 已经创建了家具，直接加载对应图片
        self.furnitures[type][id]:loadTexture(imagePath)
        self.furnitures[type][id].level = level
        return
    end

    local pos = INN_FURNITURE_POS_CFG[type][id]
    local image = ccui.ImageView:create(imagePath)
    image:setAnchorPoint(0, 1)

    if type == INN_FURNITURE_TYPE.ROOM and (id == 1 or id == 4 or id == 6) then
        image:setFlippedX(true)
    end

    image:setPosition(cc.p(pos[1], pos[2]))
    if type == INN_FURNITURE_TYPE.ROOM then
        gf:getMapObjLayer():addChild(image, 1000)
    else
        -- 桌椅与角色在同一层，实现互相遮挡
        gf:getMapObjLayer():addChild(image, 1000)
    end

    if not self.furnitures[type] then self.furnitures[type] = {} end
    self.furnitures[type][id] = image
    image.level = level
end

function InnMgr:clearData()
    InnMgr:clearSchedule()
    InnMgr:setPlayAddCoinFlag(false)
    InnMgr:cleanCoinMagicLayer()
    InnMgr:releaseAllGuest()
    InnMgr.furnitures = nil
    InnMgr.food = nil

    InnMgr.baseData = nil
    InnMgr.waitData = nil
    InnMgr.manualData = nil
    InnMgr.guestData = nil
    self.mapInfo = nil

    self.lastMePos = nil
    self.dwwShowChar = nil

    if self.yuanxDelay and gf:getUILayer() then
        gf:getUILayer():stopAction(self.yuanxDelay)
        self.yuanxDelay = nil
    end
end

-- 隐藏/显示客栈主界面
function InnMgr:hideOrShowInnMainDlg(flag)
    if not flag then flag = false end

    local mainDlg = DlgMgr:getDlgByName("InnMainDlg")
    if mainDlg then
        mainDlg:setVisible(flag)
    end
end

-- 通知服务器客人状态变化
function InnMgr:sendGuestStatusToServer(guestInfo, status)
    gf:CmdToServer("CMD_INN_CHANGE_GUEST_STATE", {
        type = guestInfo.type,
        id = guestInfo.id,
        pos = guestInfo.pos,
        state = status,
        curTime = gf:getServerTime(),
    })
end

-- 客栈内客人数据
function InnMgr:MSG_INN_GUEST_DATA(data)
    if not self.guestData then self.guestData = {} end

    -- 在客栈地图中，则刷新客人信息
    if MapMgr:isInMapByName(CHS[7190182]) then
        for k, v in pairs(data.guestInfo) do
            local needPropaganda = false
            if self.guestData[k] and self.guestData[k].preState ~= INN_GUEST_STATE.GO_OUT
                and v ~= INN_GUEST_STATE.GO_OUT then
                -- 首次切换为回程状态的客人需要播放喊话
                needPropaganda = true
            end

            self.guestData[k] = v

            -- 刷新行走、达到、买单、消失状态的客人
            local id = InnMgr:getNpcId(v.type, v.id, v.pos)
            local char = CharMgr:getCharById(id)
            local _, _, atStartPos = InnMgr:getBornGuestPos(v)
            if not char and v.state == INN_GUEST_STATE.GO_IN and atStartPos then
                -- 角色不存在时，若角色为行走状态, 且还在初始点的客人，需要延迟出生
                local offsetTime = v.offsetVal / 10
                performWithDelay(gf:getUILayer(), function()
                    if not MapMgr:isInMapByName(CHS[7190182]) then return end
                    InnMgr:bornGuest(v)
                    InnMgr:setGuestStatus(v)
                end, offsetTime)
            else
                -- 角色存在，直接更新状态
                InnMgr:bornGuest(v)
                InnMgr:setGuestStatus(v)
            end

            -- 刷新回程的客人
            InnMgr:bornGuest(v, true)
            InnMgr:setGuestStatus(v, true)
            if needPropaganda then
                InnMgr:setGuestPropaganda(v)
            end
        end
    end
end

-- 候客区数据
function InnMgr:MSG_INN_WAITING_DATA(data)
    -- 数据刷新前先检查是否需要播放特效
    if self.waitData then
        DlgMgr:sendMsg("InnElevateDlg", "setWaitUpMagic", self.waitData, data)
    end

    self.waitData = data
    DlgMgr:sendMsg("InnMainDlg", "refreshWaitInfo")
    DlgMgr:sendMsg("InnElevateDlg", "setWaitGuestInfo")
end

-- 获取当前客栈名称
function InnMgr:getCurrentInnName()
    local baseData = InnMgr:getBaseData()
    if baseData then
        return baseData.innName
    end

    return ""
end

-- 基本数据
function InnMgr:MSG_INN_BASE_DATA(data)
    -- 数据刷新前先检查是否需要播放特效
    if self.baseData then
        DlgMgr:sendMsg("InnElevateDlg", "checkMagic", self.baseData, data)

        if InnMgr:getPlayAddCoinFlag() then
            -- 如果需要播放金币增加动画，则通知客栈主界面
            DlgMgr:sendMsg("InnMainDlg", "addTcoinNumMagic", self.baseData.tongCoin, data.tongCoin)
        end
    end

    self.baseData = data
    DlgMgr:sendMsg("InnMainDlg", "refreshBaseInfo")
    DlgMgr:sendMsg("InnElevateDlg", "refreshBasicInfo")
    DlgMgr:sendMsg("InnElevateDlg", "setFurnitureInfo")

    -- 基本数据里刷新地图家具
    InnMgr:addFurniture()
end

-- 创建金币动画层
function InnMgr:createCoinMagicLayer()
    local uiLayer = gf:getUILayer()
    if not uiLayer then return end

    local magicLayer = cc.Layer:create()
    magicLayer:setContentSize(uiLayer:getContentSize())
    magicLayer:setName("InnMagicLayer")
    uiLayer:addChild(magicLayer)
end

-- 清除金币动画层
function InnMgr:cleanCoinMagicLayer()
    local uiLayer = gf:getUILayer()
    if not uiLayer then return end

    local magicLayer = uiLayer:getChildByName("InnMagicLayer")
    if magicLayer then
        magicLayer:removeFromParent()
        magicLayer = nil
    end
end

-- 客栈主界面是否可以显示手册按钮
function InnMgr:canShowManualBtn()
    local manualData = InnMgr:getManualData()
    if not manualData then return false end

    for i = 1, manualData.count do
        local tmpInfo = manualData.list[i]
        if tmpInfo and tmpInfo.state == MANUAL_TASK_STATUS.HAVE_NOT_GOT then
            -- 有未领取状态的任务，则显示手册按钮
            return true
        end
    end

    return false
end

-- 客栈主界面手册按钮是否显示红点
function InnMgr:canShowManualRedPoint()
    local manualData = InnMgr:getManualData()
    if not manualData then return false end

    for i = 1, manualData.count do
        local tmpInfo = manualData.list[i]
        if tmpInfo and tmpInfo.state == MANUAL_TASK_STATUS.HAVE_NOT_GOT
            and tmpInfo.process == tmpInfo.maxProcess then
            -- 有未领取状态的任务，且该任务已完成
            return true
        end
    end

    return false
end

-- 获取手册数据
function InnMgr:getManualData()
    return self.manualData
end

-- 获取相邻桌子客人信息
function InnMgr:getTableOtherGuestInfo(guestInfo)
    if not guestInfo then return end
    local guestData = self:getGuestData()
    if guestData then
        local curPos = guestInfo.pos
        local targetInfoKey = guestInfo.type .. "_" .. guestInfo.id .. "_"
        if curPos % 2 == 0 then
            -- 偶数位置，同桌客人位置 -1
            targetInfoKey = targetInfoKey .. tostring(curPos - 1)
        else
            -- 奇数位置，同桌客人位置 +1
            targetInfoKey = targetInfoKey .. tostring(curPos + 1)
        end

        return guestData[targetInfoKey]
    end
end

-- 是否可以添加爱心特效
function InnMgr:canAddLoveEffect(guestInfo)
    local otherGuestInfo = InnMgr:getTableOtherGuestInfo(guestInfo)

    -- 两个客人名字是一对
    if guestInfo and otherGuestInfo and LOVE_EFFECT_CFG[guestInfo.name] and
        otherGuestInfo.name == LOVE_EFFECT_CFG[guestInfo.name] then

        local guestId1 = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
        local guestId2 = InnMgr:getNpcId(otherGuestInfo.type, otherGuestInfo.id, otherGuestInfo.pos)
        if not guestId1 or not guestId2 then return end
        local guest1 = CharMgr:getCharById(guestId1)
        local guest2 = CharMgr:getCharById(guestId2)
        if not guest1 or not guest2 then return end

        if (guest1.charAction.action == Const.SA_SIT or guest1.charAction.action == Const.SA_EAT) and
            (guest2.charAction.action == Const.SA_SIT or guest2.charAction.action == Const.SA_EAT) then
            -- 两个客人都是坐着或吃饭动作
            return true
        end
    end

    return false
end

-- 客人增加爱心特效
function InnMgr:addLoveEffect(guestInfo)
    -- 当前客人
    if not guestInfo then return end
    local guestId = InnMgr:getNpcId(guestInfo.type, guestInfo.id, guestInfo.pos)
    local char = CharMgr:getCharById(guestId)
    if not char then return end
    char:addMagicOnFoot(ResMgr.magic.love_effect, false, ResMgr.magic.love_effect, nil, {loopInterval = 3000})

    -- 另外一个客人
    local otherInfo = self:getTableOtherGuestInfo(guestInfo)
    if not otherInfo then return end
    local otherGuestId = InnMgr:getNpcId(otherInfo.type, otherInfo.id, otherInfo.pos)
    local other = CharMgr:getCharById(otherGuestId)
    if not other then return end
    other:addMagicOnFoot(ResMgr.magic.love_effect, false, ResMgr.magic.love_effect, nil, {loopInterval = 3000})
end

-- 客人移除爱心特效
function InnMgr:removeLoveEffect(guestInfo)
    -- 当前客人直接被析构了，所以不需要移除特效，移除另外一个客人特效即可
    local otherInfo = self:getTableOtherGuestInfo(guestInfo)
    if not otherInfo then return end

    local otherGuestId = InnMgr:getNpcId(otherInfo.type, otherInfo.id, otherInfo.pos)
    local other = CharMgr:getCharById(otherGuestId)
    if not other then return end

    other:deleteMagic(ResMgr.magic.love_effect)
end

-- 手册数据
function InnMgr:MSG_INN_TASK_DATA(data)
    self.manualData = data

    DlgMgr:sendMsg("InnMainDlg", "refreshManualBtn")
end

function InnMgr:MSG_ENTER_ROOM(data)
    if data.map_name == CHS[7190312] then
        -- 进入 2018 中秋大胃王
        InnMgr:enter2018MidAutumn()
        return
    elseif MapMgr.lastMap and MapMgr.lastMap.map_name == CHS[7190312] then
        -- 退出 2018 中秋大胃王
        InnMgr:exit2018MidAutumn()
        return
    elseif MapMgr.lastMap and MapMgr.lastMap.map_name == CHS[5400718] and data.map_name ~= CHS[5400718] then
        -- 从相约元宵退出
        DlgMgr:setAllDlgVisible(true)
        DlgMgr:showDlgWhenNoramlDlgClose()
    elseif data.map_name == CHS[5450345] then
        -- 先移除地图上的所有物品
        gf:getMapObjLayer():removeAllChildren()

        -- 摆满桌椅
        self.furnitures = {}
        for i = 1, 6 do
            self:refreshInnFurniture(INN_FURNITURE_TYPE.TABLE, 5, i)
        end
        return
    end

    -- 如果在客栈中，又收到该消息，则不处理
    -- WDSY-36966
    if MapMgr:isInMapByName(CHS[7190182]) and self.mapInfo and self.mapInfo.map_name == data.map_name then
        return
    end

    -- 进入客栈，直接打开客栈主界面
    if MapMgr:isInMapByName(CHS[7190182]) then
        -- 先移除地图上的所有物品
        gf:getMapObjLayer():removeAllChildren()

        InnMgr.baseData = {}
        InnMgr.waitData = {}
        InnMgr.furnitures = {}
        InnMgr.paths = {}
        InnMgr.food = {}

        -- 进入客栈，默认显示主界面UI
        local innMainDlg = DlgMgr:getDlgByName("InnMainDlg")
        if innMainDlg then
            -- 已经打开，隐藏主界面，走婚礼的逻辑
            DlgMgr:closeDlgWhenNoramlDlgOpen(nil, true)
        else
            GameMgr:showAllUI(0)
            DlgMgr:openDlg("InnMainDlg")
        end

        -- 录屏按钮如果 已经打开，则显示出来
        DlgMgr:sendMsg("ScreenRecordingDlg", "setVisible", true)

        InnMgr:initAutoWalkPath()
        InnMgr:startSchedule()

        -- 创建金币动画层
        InnMgr:createCoinMagicLayer()

        -- 进入客栈，通知服务器已阅读npc聊天
        FriendMgr:doReadTempNpcMsg(NPC_TELL.INN)
    else
        -- 退出客栈清除客栈数据
        InnMgr:clearData()

        DlgMgr:closeDlg("InnMainDlg")
    end

    self.mapInfo = data
end

-- 客栈活动是否打开
function InnMgr:isInnActivityOpen()
    if self.openData and self.openData.enable == 1 then
        return true
    end

    return false
end

-- 是否已购买客栈
function InnMgr:hadBoughtInn()
    if self.openData and self.openData.level > 0 then
        return true
    end

    return false
end

function InnMgr:MSG_INN_ENTER_WORLD(data)
    self.openData = data
end

function InnMgr:MSG_ADD_NPC_TEMP_MSG(data)
    if MapMgr:isInMapByName(CHS[7190182]) and NPC_TELL.INN == data.msgType then
        -- 在客栈里面，收到客栈类型npc聊天信息，通知服务器已阅读
        FriendMgr:doReadTempNpcMsg(NPC_TELL.INN)
    end
end

-- 2018中秋大胃王 进入客栈
function InnMgr:enter2018MidAutumn()
    -- 初始化需要显示在客栈中的模型
    self.dwwShowChar = {}

    -- 创建桌子(过图后自动移除)
    local image = ccui.ImageView:create(ResMgr:getFurniturePath(15002))
    image:setAnchorPoint(0.5, 0.5)
    image:setPosition(cc.p(780, 516))
    image:setName("DwwTable")
    gf:getMapObjLayer():addChild(image, 1000)
end

-- 2018中秋大胃王 退出客栈
function InnMgr:exit2018MidAutumn()
    self.dwwShowChar = nil
end

-- 2018中秋大胃王 进入准备阶段
function InnMgr:MSG_AUTUMN_2018_DWW_PREPARE()
    DlgMgr:closeDlg("DramaDlg")
    DlgMgr:openDlg("MidAutumnEatDlg")
end

-- 2018中秋大胃王 是否需要隐藏角色
function InnMgr:isNeedHideChar(char)
    if self.dwwShowChar and not self.dwwShowChar[char:getId()] then
        return true
    end

    return false
end

function InnMgr:isNeedHideMainDlg()
    if MapMgr:isInMapByName(CHS[5400718]) then
        return true
    end

    return false
end

function InnMgr:getGuestCfgInfoByName(name)
    for i = 1, #INN_GUEST_CFG do
        if INN_GUEST_CFG[i].name == name then
            return INN_GUEST_CFG[i]
        end
    end
end

-- 创建相约元宵客人
function InnMgr:appearXYYXGuest(data)
    local posInfo = INN_SIT_ACTION_POS
    local flag = {}
    local npcs = {}
    local status
    for i = 1, #posInfo do
        for j = 1, #posInfo[i] do
            local info
            if i == 1 then
                --
                if j == 2 then
                    info = self:getGuestCfgInfoByName(CHS[5400743])
                else
                    info = self:getGuestCfgInfoByName(data.target_npc)
                end

                status = Const.NS_SIT_STATUS
            else
                repeat
                    info = INN_GUEST_CFG[math.random(1, #INN_GUEST_CFG)]
                    if not flag[info.name] and info.icon ~= 06012 and info.icon ~= 06019 and info.icon ~= 06033 then
                        break
                    end
                until false

                status = Const.NS_EAT_STATUS
            end

            local id = InnMgr:getNpcId(INN_FURNITURE_TYPE.TABLE, i, j)
            flag[info.name] = true
            local x, y = gf:convertToMapSpace(posInfo[i][j][1], posInfo[i][j][2])
            CharMgr:MSG_APPEAR({
                x = x,
                y = y,
                dir = j == 1 and 7 or 3,
                id = id,
                icon = info.icon,
                type = OBJECT_TYPE.INN_GUEST,
                name = info.name,
                opacity = 0,
                light_effect_count = 0,
                status = status,
                isNowLoad = true
            })

            local char = CharMgr:getCharById(id)
            char:setVisible(true)
            char:setPos(posInfo[i][j][1], posInfo[i][j][2])
        end
    end
end

function InnMgr:MSG_YUANXJ_2019_PREPARE_DATA(data)
    -- 摆满桌椅
    self.furnitures = {}
    for i = 1, 6 do
        self:refreshInnFurniture(INN_FURNITURE_TYPE.TABLE, 3, i)
    end

    -- 坐人
    self:appearXYYXGuest(data)

    if GameMgr.scene and GameMgr.scene.map and GameMgr.scene.map.setDrapEnabled then
        GameMgr.scene.map:setDrapEnabled(false)
    end

    local function func()
        DlgMgr:showAllOpenedDlg(false, {["LoadingDlg"] = 1})

        self.yuanxDelay = performWithDelay(gf:getUILayer(), function()
            -- 视野坐标缓慢向(42,48)移动，整个过程3秒完成
            self.yuanxDelay = nil
            if GameMgr.scene and GameMgr.scene.map and GameMgr.scene.map.moveTo then
                GameMgr.scene.map:moveTo(42, 41, 3000)
            end

            self.yuanxDelay = performWithDelay(gf:getUILayer(), function()
                gf:CmdToServer("CMD_YUANXJ_2019_PLAY_SCENARIO", {})
                self.yuanxDelay = nil
            end, 5)
        end, 2)
    end

    local loadingDlg = DlgMgr:getDlgByName("LoadingDlg")
    if loadingDlg then
        loadingDlg:registerExitCallBack(function()
            func()
        end)
    else
        if MapMgr:isInMapByName(CHS[5400718]) then
            func()
        end
    end
end

function InnMgr:MSG_YUANXJ_2019_PLAY_AIXIN_EFFECT(data)
    for i = 1, 2 do
        local id = InnMgr:getNpcId(INN_FURNITURE_TYPE.TABLE, 1, i)
        CharMgr:MSG_PLAY_LIGHT_EFFECT({
            charId = id,
            effectIcon = 07011,
            interval  = 0
        })
    end
end

MessageMgr:regist("MSG_AUTUMN_2018_DWW_PREPARE", InnMgr)
MessageMgr:regist("MSG_INN_GUEST_DATA", InnMgr)
MessageMgr:regist("MSG_INN_WAITING_DATA", InnMgr)
MessageMgr:regist("MSG_INN_BASE_DATA", InnMgr)
MessageMgr:regist("MSG_INN_ENTER_WORLD", InnMgr)
MessageMgr:regist("MSG_INN_TASK_DATA", InnMgr)
MessageMgr:regist("MSG_YUANXJ_2019_PREPARE_DATA", InnMgr)
MessageMgr:regist("MSG_YUANXJ_2019_PLAY_AIXIN_EFFECT", InnMgr)
MessageMgr:hook("MSG_ENTER_ROOM", InnMgr, "InnMgr")
MessageMgr:hook("MSG_ADD_NPC_TEMP_MSG", InnMgr, "InnMgr")
