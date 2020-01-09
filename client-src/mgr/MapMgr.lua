-- MapMgr.lua
-- created by cheny Nov/25/2014
-- 地图管理器

MapMgr = Singleton("MapMgr")
local MapInfo = require(ResMgr:getCfgPath('MapInfo.lua'))
local LoadingTips = require ("cfg/LoadingTips")
local MapNpc = require("obj/MapNpc")
MapMgr.mapSize = nil
MapMgr.isLoadEnd = true

-- 天墉城擂台坐标点
local LEITAI_PT = {[1] = {x = 186,y = 70}, [2] = {x = 212, y = 86}, [3] = {x = 185,y = 100}, [4] = {x = 159,y = 86}}

-- key : 地图id  value : 对应任务名称
local DUNGEON_MAP_ID = {
    -- 黑风洞地图
    [31100] = CHS[3004152],  -- 一层",
    [31200] = CHS[3004152],  -- 二层",
    [31300] = CHS[3004152],  -- 三层",

    -- 幻·黑风洞地图
    [31101] = CHS[5450304],  -- 一层",
    [31201] = CHS[5450304],  -- 二层",
    [31301] = CHS[5450304],  -- 三层",

    -- 兰若寺
    [32000] = CHS[3004153],
    [32100] = CHS[3004153],  -- 后山",
    [32200] = CHS[3004153],  -- "黑山老妖巢穴",

    -- 幻·兰若寺
    [32001] = CHS[5450305],
    [32101] = CHS[5450305],  -- 后山",
    [32201] = CHS[5450305],  -- "洞穴",

    --烈火涧
    [33000] = CHS[3004154],
    [33100] = CHS[3004154],  -- 西面",
    [33300] = CHS[3004154],  -- 东面",
    [33200] = CHS[3004154],  -- 北面",

    -- 植树节
    [10101] = CHS[7003006],  -- 地底通道
    [16104] = CHS[7003006],  -- 地底世界

    [16003] = CHS[3004155],
    [15002] = CHS[3004155],
    [9001] = CHS[3004155],
    [15003] = CHS[3004155],
    [12001] = CHS[3004155],
    [16102] = CHS[3004155],
    [24001] = CHS[3004155],
    [17301] = CHS[3004155],
    [9002] = CHS[3004155],
    [27004] = CHS[3004155],

    [3002] = CHS[3004155],
    [14007] = CHS[3004155],
    [16103] = CHS[3004155],
    [27003] = CHS[3004155],
    [16004] = CHS[3004155],
    [25010] = CHS[3004155],

    [11001] = CHS[3004155], --李家庄
    [24002] = CHS[3004155], --乡间小道
    [3001]  = CHS[3004155], --落魄崖

    [9003] = CHS[3004155], -- 东海之滨
    [27005] = CHS[3004155], -- 海底幽径
    [27006] = CHS[3004155], -- 龙宫宫殿

    -- 化妆舞会
    [38010] = CHS[7002107], -- 舞会场地

    -- 百兽之王
    [38011] = CHS[7002128], -- 百兽战场

    -- 须弥秘境
    [15004] = CHS[7002198],

    -- 矿石大战
    [38014] = CHS[7002226], -- 蓝毛巨兽巢穴
    [38015] = CHS[7002226], -- 聚宝矿洞
    [38016] = CHS[7002226], -- 赤焰炼魔巢穴

    -- 异族入侵
    [38012] = CHS[2000237],
    [38013] = CHS[2000237],

    -- 粽仙
    [37001] = CHS[7003052],
    [37002] = CHS[7003052],
    [37003] = CHS[7003052],

    -- 飘渺仙府
    [27007] = CHS[4100554], -- "飘渺仙府",
    [25005] = CHS[4100554], -- "飘渺仙府",
    [25006] = CHS[4100554], -- "飘渺仙府",

    -- 【七夕节】千里相会
    [15005] = CHS[5400077],  -- 王母寝宫

    -- 【七夕】漫步花丛
    [17201] = CHS[5450190],  -- 百花丛中

    -- 【圣诞】巧收雪精
    [18001] = CHS[5450063],  -- 雪精圣地

    [37004] = CHS[2000348],  -- 众仙塔
    [37005] = CHS[2000348],  -- 众仙塔

    [14008] = CHS[7100159],  -- 外冢一层
    [14009] = CHS[7100159],  -- 外冢二层
    [14010] = CHS[7100159],  -- 内冢

    [16005] = CHS[7190144],  -- 山贼营外
    [08101] = CHS[7190144],  -- 山贼老巢
    [29002] = CHS[4010027], -- 证道殿

    [17101] = CHS[7190256],  -- 【探案】江湖绿林
    [17202] = CHS[7190256],  -- 【探案】江湖绿林
    [17302] = CHS[7190256],  -- 【探案】江湖绿林
    [17401] = CHS[7190256],  -- 【探案】江湖绿林

    [01001] = CHS[7190287],  -- 【探案】迷仙镇案
    [28103] = CHS[7190287],  -- 【探案】迷仙镇案
    [28104] = CHS[7190287],  -- 【探案】迷仙镇案
    [28105] = CHS[7190287],  -- 【探案】迷仙镇案
    [28106] = CHS[7190287],  -- 【探案】迷仙镇案

    [27008] = CHS[4010164],    -- 幻境—飘渺仙府
    [25008] = CHS[4010164],    -- 幻境—飘渺仙府
    [25009] = CHS[4010164],    -- 幻境—飘渺仙府


    [33001] = CHS[4010178],    -- 幻境—飘渺仙府
    [33101] = CHS[4010178],    -- 幻境—飘渺仙府
    [33201] = CHS[4010178],    -- 幻境—飘渺仙府
    [33301] = CHS[4010178],    -- 幻境—飘渺仙府

    [05009] = CHS[5450341],    -- 千面酒会
}

-- key : 地图id  value : 对应地图名称
local FUBEN_MAP_ID =
{
    -- 黑风洞地图
    [31100] = CHS[3004152],  -- 一层",
    [31200] = CHS[3004152],  -- 二层",
    [31300] = CHS[3004152],  -- 三层",

    -- 幻·黑风洞地图
    [31101] = CHS[5450304],  -- 一层",
    [31201] = CHS[5450304],  -- 二层",
    [31301] = CHS[5450304],  -- 三层",

    -- 兰若寺
    [32000] = CHS[3004153],
    [32100] = CHS[3004153],  -- 后山",
    [32200] = CHS[3004153],  -- "黑山老妖巢穴",

        -- 幻·兰若寺
    [32001] = CHS[5450305],
    [32101] = CHS[5450305],  -- 后山",
    [32201] = CHS[5450305],  -- "洞穴",

    --烈火涧
    [33000] = CHS[3004154],
    [33100] = CHS[3004154],  -- 西面",
    [33300] = CHS[3004154],  -- 东面",
    [33200] = CHS[3004154],  -- 北面",

    -- 植树节
    [10101] = CHS[7003006],  -- 地底通道
    [16104] = CHS[7003006],  -- 地底世界

    -- 化妆舞会
    [38010] = CHS[7002107], -- 舞会场地

    -- 百兽之王
    [38011] = CHS[7002128], -- 百兽战场

    -- 须弥秘境
    [15004] = CHS[7002198], -- 须弥秘境

    -- 矿石大战
    [38014] = CHS[7002226], -- 蓝毛巨兽巢穴
    [38015] = CHS[7002226], -- 聚宝矿洞
    [38016] = CHS[7002226], -- 赤焰炼魔巢穴

    -- 万妖窟
    [10102] = CHS[2100052],
    [10202] = CHS[2100053],
    [10302] = CHS[2100054],
    [10402] = CHS[2100055],
    [10502] = CHS[2100056],

    -- 异族入侵
    [38012] = CHS[2000237],
    [38013] = CHS[2000237],

    -- 粽仙
    [37001] = CHS[7003052],
    [37002] = CHS[7003052],
    [37003] = CHS[7003052],

    -- 飘渺仙府
    [27007] = CHS[4100554], -- "飘渺仙府",
    [25005] = CHS[4100554], -- "飘渺仙府",
    [25006] = CHS[4100554], -- "飘渺仙府",

    -- 【七夕节】千里相会
    [15005] = CHS[5400077],  -- 王母寝宫

    -- 【七夕】漫步花丛
    [17201] = CHS[5450190],  -- 百花丛中

    -- 【圣诞】巧收雪精
    [18001] = CHS[5450063],  -- 雪精圣地

    [37004] = CHS[2000348],   -- 众仙塔
    [37005] = CHS[2000348],   -- 众仙塔

    [16005] = CHS[7190148],  -- 山贼营外
    [08101] = CHS[7190149],  -- 山贼老巢

    [17001] = CHS[4010025],

    [17101] = CHS[7190257],  -- 花谷幻境一
    [17202] = CHS[7190258],  -- 花谷幻境二
    [17302] = CHS[7190259],  -- 花谷幻境三
    [17401] = CHS[7190260],  -- 卧龙花谷

    [01001] = CHS[7190282],  -- 迷仙镇
    [28103] = CHS[7190283],  -- 小童父母家
    [28104] = CHS[7190284],  -- 小童叔叔家
    [28105] = CHS[7190285],  -- 常舌馥家
    [28106] = CHS[7190286],  -- 小童爷爷家

    [27008] = CHS[4010165], -- "幻·大殿",
    [25008] = CHS[4010166], -- "幻·秘境",
    [25009] = CHS[4010167], -- "幻·仙府",

    [33001] = CHS[4010179],    -- 幻·烈火涧
    [33101] = CHS[4010180],    -- 幻·烈火涧西
    [33201] = CHS[4010181],    -- 幻·烈火涧北
    [33301] = CHS[4010182],    -- 幻·烈火涧东

    [17102] = CHS[4101241],

    [05009] = CHS[5450345],    -- 千面酒会
}

local BAXIAN_MAP_ID =
{
    [16003] = CHS[3004155],
    [15002] = CHS[3004155],
    [9001] = CHS[3004155],
    [15003] = CHS[3004155],
    [12001] = CHS[3004155],
    [16102] = CHS[3004155],
    [24001] = CHS[3004155],
    [17301] = CHS[3004155],
    [9002] = CHS[3004155],
    [15007] = CHS[3004155],

    [3002] = CHS[3004155],
    [14007] = CHS[3004155],
    [16103] = CHS[3004155],
    [27003] = CHS[3004155],
    [27004] = CHS[3004155],
    [16004] = CHS[3004155],
    [25010] = CHS[3004155],
    [11001] = CHS[3004155], --李家庄
    [24002] = CHS[3004155], --乡间小道
    [3001]  = CHS[3004155], --落魄崖
    [9003] = CHS[3004155], -- 东海之滨
    [27005] = CHS[3004155], -- 海底幽径
    [27006] = CHS[3004155], -- 龙宫宫殿
}

local YZRQ_MAP_ID =
{
    -- 异族入侵
    [38012] = CHS[2000237],
    [38013] = CHS[2000237],
}

MapMgr.mapNpcs = {}

-- 用于隐藏加载界面需要忽略判断的对话框
local unCheckWhenHideLoadingDlg = {
    ["GameFunctionDlg"] = true,
    ["SystemFunctionDlg"] = true,
    ["MissionDlg"] = true,
    ["FriendDlg"] = true,
    ["ChannelDlg"] = true,
    ["ChatDlg"] = true,
    ["HeadDlg"] = true,
    ["DramaDlg"] = true,
    ["NpcDlg"] = true,
    ["JiebSortOrderDlg"] = true,
    ["JiebSetTitleDlg"] = true,
    ["JiebVoteDlg"] = true,
    ["SmallTipDlg"] = true,
    ["LoadingDlg"] = true,
    ["PopUpDlg"] = true,
    ["AnnouncementDlg"] = true,
    ["SystemSwitchLineDlg"] = true,
    ["ConfimrDlg"] = true,
    ["ItemInfoDlg"] = true,
    ["ItemRecourseDlg"] = true,
    ["EquipmentFloatingFrameDlg"] = true,
    ["EquipmentInfoCampareDlg"] = true,
    ["JewelryInfoCampareDlg"] = true,
    ["JewelryInfoDlg"] = true,
    ["ChangeCardInfoDlg"] = true,
    ["ArtifactInfoDlg"] = true,
    ["ArtifactInfoCampareDlg"] = true,
    ["FurnitureInfoDlg"] = true,
    ["RookieGiftDlg"] = true,
    ["ConvenientCallGuardDlg"] = true,
    ["FastUseItemDlg"] = true,
    ["AchievementCompleteDlg"] = true,
    ["BiggerConfirmDlg"] = true,
    ["ScreenRecordingDlg"] = true,
    ["LockScreenDlg"] = true,
}

-- 需要进行加载界面隐藏处理的任务
local checkTaskWhenLoading = {
    [CHS[2200085]] = true,
    [CHS[2200086]] = true,
    [CHS[2200087]] = true,
    [CHS[2200090]] = true,
    [CHS[2200088]] = true,
    [CHS[2200089]] = true,
}

function MapMgr:clearData(isRefreshUserData)
    if isRefreshUserData then return end

    -- 若要清空数据时小地图处于打开状态，则关闭小地图
    if DlgMgr:isDlgOpened("SmallMapDlg") then
        DlgMgr:closeDlg("SmallMapDlg")
    end

    self.mapSize = nil
    self.mapData = nil
    self.defaultMapLayer = nil
    self.exits = {}
    self:clearAllMapNpcs()
    self.loadMapTips = nil
end

function MapMgr:clearAllMapNpcs()
    for i = 1, #self.mapNpcs do
        self.mapNpcs[i]:cleanup()
    end
    self.mapNpcs = {}
end

function MapMgr:getAllMapNpcs()
    return self.mapNpcs
end

-- 判断是否是副本地图，如果是返回副本名称
function MapMgr:isDungeonMap(mapId)
    return DUNGEON_MAP_ID[mapId]
end

function MapMgr:getCurrentMapId()
    if self.mapData == nil then return 0 end
    return self.mapData.map_id or 0
end

function MapMgr:getCurrentMapIndex()
    if self.mapData == nil then return 0 end
    return self.mapData.map_index or 0
end

function MapMgr:getCurrentMapName()
    if self.mapData == nil then return end
    return self.mapData.map_name
end

function MapMgr:getTileIndex()
    if self.mapData == nil then return 1 end
    return self.mapData.floor_index + 1
end

function MapMgr:getWallIndex()
    if self.mapData == nil then return 1 end
    return self.mapData.wall_index + 1
end

function MapMgr:getNpcs(map_id)
    local info = MapInfo[map_id]
    if nil == info then return end

    -- 特殊处理，如果时间尚未到2019.04.22 05:00，那么小地图上不显示周华健(此段代码将在过期后删除)
    if map_id == 05000 and gf:getServerTime() < os.time({year = 2019, month = 04, day = 22, hour = 5, min = 0}) then
        local mapNpcs = {}
        for _,npc in pairs(info["npc"]) do
            if npc.name ~= CHS[7000079] then
                table.insert(mapNpcs, npc)
            end
        end

        return mapNpcs or {}
    end

    return info["npc"] or {}
end

-- 获取小地图中显示的npc     部分地图npc太多，显示部分npc
function MapMgr:getDisplayNpcs(map_id)
    local info = MapInfo[map_id]
    if nil == info then return end

    -- 特殊处理，如果时间尚未到2019.04.22 05:00，那么小地图上不显示周华健(此段代码将在过期后删除)
    if map_id == 05000 and gf:getServerTime() < os.time({year = 2019, month = 04, day = 22, hour = 5, min = 0}) then
        for _, npc in pairs(info["npc"]) do
            if npc.name == CHS[7000079] then
                npc.notInSmallMap = true
                break
            end
        end
    end

    local displayNPC = {}
    if info["npc"] then
        for _,npc in pairs(info["npc"]) do
            if not npc.notInSmallMap then
                table.insert(displayNPC, npc)
            end
        end
    end

    return displayNPC
end

-- 获取练功区推荐等级
function MapMgr:getExitLevel(map_id)
    local info = MapInfo[map_id]
    if nil == info then return end
    return info["exit_level"]
end

-- 检查当前地图是否合适练级
function MapMgr:checkMapMonsterLevel()
    local mapInfo = self:getMapinfo()
    local curMapID = self:getCurrentMapId()
    local info = MapInfo[curMapID]
    local mLevel = Me:queryBasicInt("level")

    if info ~= nil and not info.monster_level then
        if info.monster_level - mLevel >= 20 then
            --判断是否为师门地图
            local mPolar = Me:queryBasicInt("polar")
            local polarMapName = gf:getPolarMap(mPolar)

            if info.map_name ~= polarMapName then
                local strTips = string.format(CHS[6000212], info.monster_level)
                gf:ShowSmallTips(strTips)
            end
        end
    end
end

function MapMgr:getNpcByName(npc_name)
    if not npc_name then
        return
    end

    -- 优先匹配mapInfo中配置的 name
    for i,j in pairs(MapInfo) do
        local npcs = j["npc"]
        if npcs ~= nil  then
            for k, v in pairs(npcs) do
                if v.name == npc_name then
                    return v, j["map_name"]
                end
            end
        end
    end

    -- 如果 mapInfo 中的  name 没有匹配到，则寻找 alias
    local id = self:getCurrentMapId()
    if MapInfo[id] then
        -- 优先找本地图的
        local npcs = MapInfo[id]["npc"]
        if npcs ~= nil  then
            for k, v in pairs(npcs) do
                if v.alias == npc_name then
                    return v,  MapInfo[id]["map_name"]
                end
            end
        end
    end

    for i,j in pairs(MapInfo) do
        local npcs = j["npc"]
        if npcs ~= nil  then
            for k, v in pairs(npcs) do
                if v.alias == npc_name then
                    return v, j["map_name"]
                end
            end
        end
    end
end

function MapMgr:getCurMapNpcByName(npc_name)
    local npcs = self:getNpcs(self:getCurrentMapId())

    if not npcs or not npc_name then return end

    -- 优先匹配mapInfo中配置的 name
    for _,v in pairs(npcs) do
        if v.name == npc_name then
            return v
        end
    end

    -- 如果 mapInfo 中的  name 没有匹配到，则寻找 alias
    for _,v in pairs(npcs) do
        if v.alias == npc_name then
            return v
        end
    end
end
function MapMgr:getCurMapNpcByPosAndName(name, x, y)
    local npcs = self:getNpcs(self:getCurrentMapId())

    if not npcs or not name then return end

    -- 优先匹配mapInfo中配置的 name
    for _,v in pairs(npcs) do
        if (v.name == name)
            and v.x == x
            and v.y == y then
            return v
        end
    end

    -- 如果 mapInfo 中的  name 没有匹配到，则寻找 alias
    for _,v in pairs(npcs) do
        if (v.alias == name)
            and v.x == x
            and v.y == y then
            return v
        end
    end

end

-- 返回值标识是否向服务端请求
-- 服务端如果飞失败会返回 MSG_TELEPORT_FAILED 消息
function MapMgr:flyTo(map_name, callBack, autoWalk)
    if not self:checkCanFly() then
        if self:unFlyTip() then
            gf:ShowSmallTips(self:unFlyTip())
        end

        return false
    end

    local function func()
        autoWalk = autoWalk or AutoWalkMgr.autoWalk
        for id, v in pairs(MapInfo) do
            if v.map_name == map_name then
                local isTaskWalk
                if autoWalk and autoWalk.curTaskWalkPath then
                    isTaskWalk = self:tryCheckTaskForLoading(autoWalk.curTaskWalkPath.task_type)
                end
                gf:CmdToServer("CMD_TELEPORT", {
                    map_id = id, -- 此处不能使用map_id
                    x = v.teleport_x,
                    y = v.teleport_y,
                    isTaskWalk = isTaskWalk and 1 or 0,
                })

                -- 一些节目有寻路，如果快速点击两次，第一次发送该消息，关闭界面，第二次点击会点击到地板，导致停止自动寻路
                -- 例如，玩家不在天墉城，活动界面连续快速点击副本前往，第一次发送过图天墉城，第二次点击地板（过图界面尚未出现），停止寻路了！
                -- by songcw    WDSY-23482 帮派、师门任务无法自动寻路的问题
                gf:frozenScreen(0.2)
            end
        end

        if type(callBack) == "function" then
            self.callBackInfo = {}
            self.callBackInfo.mapName = map_name
            self.callBackInfo.callFun = callBack
        end

        EventDispatcher:dispatchEvent(EVENT.CMD_TELEPORT, { map_name = map_name })
    end

    local tips = MapMgr:getFlyConfirmTips()
    if tips then
        gf:confirm(tips, function()
            if autoWalk then AutoWalkMgr.autoWalk = autoWalk end

            func()
        end)
        return false
    else
        func()
    end

    return true
end

-- 是否在拖动类型地图中
function MapMgr:isInDragMap()
    if GameMgr.scene.map then
        return GameMgr.scene.map.mapType == MAP_TYPE.DRAG_MAP
    end

    return false
end

-- 是否在玉露仙池
function MapMgr:isInYuLuXianChi()
    if self:getCurrentMapId() == 37013 then
        return true
    end

    return false
end

-- 返回点的传送点位置
function MapMgr:flyPosition(mapName)
    for _, v in pairs(MapInfo) do
        if v.map_name == mapName then
            return v["teleport_x"],v["teleport_y"]
        end
    end
end

-- 是否可飞行
function MapMgr:checkCanFly()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and not MapInfo[mapId].unfly
end

-- 获取离开地图的确认提示
function MapMgr:getFlyConfirmTips()
    local mapId = self:getCurrentMapId()
    if not mapId or not MapInfo[mapId] then
        return
    end

    return MapInfo[mapId].fly_confirm_tips
end

-- 不可飞行的提示
function MapMgr:unFlyTip()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and MapInfo[mapId].unfly_tip
end

-- 是否可换线
function MapMgr:checkSwitchLine()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and not MapInfo[mapId].unswitch_line
end

-- 是否可换线
function MapMgr:checkDlgSwitchLine()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and not MapInfo[mapId].unswitch_line_dlg
end

-- 是否可自动匹配
function MapMgr:checkCanMatch()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and not MapInfo[mapId].unmatch_team
end

-- 是否可切磋
function MapMgr:checkCanFight()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and not MapInfo[mapId].unfight
end

-- 不可切磋提示
function MapMgr:unFightTip()
    local mapId = self:getCurrentMapId()
    return mapId and 0 ~= mapId and MapInfo[mapId] and MapInfo[mapId].unfight_tip
end

-- 判断是否在地图中
function MapMgr:isInMapByName(mapName)
    if MapMgr.mapData and MapMgr.mapData.map_name == mapName then
        return true
    end
end

function MapMgr:isInMapById(mapId)
    if MapMgr.mapData and MapMgr.mapData.map_id == mapId then
        return true
    end
end

function MapMgr:getMapByName(mapName)
    for k, v in pairs(MapInfo) do
        if v.map_name == mapName then
            return k
        end
    end
end

function MapMgr:getMapInfoByName(mapName)
    for k, v in pairs(MapInfo) do
        if v.map_name == mapName or (v.map_name .. CHS[4010236]) == mapName or (v.map_name .. CHS[4010237]) == mapName then
            return v
        end
    end
end

function MapMgr:getMapInfoById(mapId)
    return MapInfo[mapId]
end

function MapMgr:isMapMagicAlwaysShow(mapName)
    local mapInfo = self:getMapInfoByName(mapName or self:getCurrentMapName())
    if mapInfo and mapInfo.mapMagicAlwaysShow then
        return true
    end
end

function MapMgr:getExits()
    return self.exits
end

function MapMgr:MSG_EXITS(data)

    self.exits = data
end

-- 根据地图，打开或者关闭一些地图。  部分界面进入游戏后可能在战斗，战斗中再打开的话，节目会在战斗上，所以需要先打开
function MapMgr:openOrCloseDlgs(map)
    -- 试道
    if map.map_name ~= CHS[3004311] then
        DlgMgr:closeDlg("ShidaoInfoDlg")
    else
        DlgMgr:openDlg("ShidaoInfoDlg")
    end


    if KuafzcMgr:isInKuafzc2019() then
        DlgMgr:openDlg("NewKuafzcWarInfoDlg")
    else
        DlgMgr:closeDlg("NewKuafzcWarInfoDlg")
    end

    -- 跨服试道
    if map.map_name ~= CHS[5400028] and map.map_name ~= CHS[5450339] then
        DlgMgr:closeDlg("KuafsdInfoDlg")
    else
        DlgMgr:openDlg("KuafsdInfoDlg")
    end

    if not MapMgr:isInMapByName(CHS[4010293]) then
        DlgMgr:closeDlg("SpeclalRoomDanceDlg")
        DlgMgr:closeDlg("SpeclalRoomEatDlg")
        DlgMgr:closeDlg("SpeclalRoomStrollDlg")
        DlgMgr:closeDlg("SpeclalRoomVoteDlg")
        DlgMgr:closeDlg("NoneDlg")
    end

    -- 帮战
    if not GameMgr:isInPartyWar() then
        DlgMgr:closeDlg("PartyWarInfoDlg")
    else
        DlgMgr:openDlg("PartyWarInfoDlg")
    end

    -- 跨服竞技
    if not DistMgr:isInKFJJServer() then
        DlgMgr:closeDlg("KuafjjgnDlg")
    else
        DlgMgr:openDlg("KuafjjgnDlg")
    end

    -- 全民PK
    if QuanminPK2Mgr:isCanOpenInfoDlg() then
        DlgMgr:openDlg("QuanmPK2InfoDlg")
    else
        DlgMgr:closeDlg("QuanmPK2InfoDlg")
    end

    -- 世界BOSS地图的埋没之地
    if MapMgr:isInMaiMoZhiDi() then
        DlgMgr:openDlg("WorldBossLifeDlg")
    else
        DlgMgr:closeDlg("WorldBossLifeDlg")
    end


    DlgMgr:sendMsg("GameFunctionDlg", "removeMagicForKidButton")

    if MapMgr:isInHouse(map.map_name) then
        -- 进入居所
        if not MapMgr:isInHouseBackYard(map.map_name) then
            -- 不在居所后院
            DlgMgr:closeDlg("SeedBuyDlg")
            DlgMgr:closeDlg("CheekFarmDlg")
        end
    else
        -- 不在居所后，关闭部分对话框
        DlgMgr:closeDlg("HomeTakeCareDlg")
        DlgMgr:closeDlg("HomeBuyFeedDlg")
        DlgMgr:closeDlg("SeedBuyDlg")
        DlgMgr:closeDlg("CheekFarmDlg")
        DlgMgr:closeDlg("FastUseItemForWawaDlg")
    end

    DlgMgr:closeDlg("PetHouseDlg")
    DlgMgr:closeDlg("PetHouseBuyDlg")
    DlgMgr:closeDlg("HousePetStoreDlg")
    DlgMgr:closeDlg("MeiGuiTimeDlg")

    if map.map_id ~= 37102 then
        DlgMgr:closeDlg("ShengxdjDlg")
    end

    if not MapMgr:isInHouseVestibule(map.map_name) then
        DlgMgr:closeDlg("ChildDailyMission1Dlg")
    end


    if map.map_id ~= 37103 then
        DlgMgr:closeDlg("ChildDailyMission2Dlg")
    end

    if map.map_id ~= 17200 then
        DlgMgr:closeDlg("ChildDailyMission5Dlg")
    end

    if map.map_id ~= 17300 then
        DlgMgr:closeDlg("ChildDailyMission3Dlg")
    end

    if not YZRQ_MAP_ID[map.map_id] then
        DlgMgr:closeDlg("NPCRecruitDlg")
        DlgMgr:closeDlg("NPCSupplyDlg")
        DlgMgr:closeDlg("DugeonRuleDlg")
        DlgMgr:closeDlg("InvadeDlg")
        DlgMgr:closeDlg("InvadeRuleDlg")
        DlgMgr:closeDlg("JungongShopDlg")
    end

    if map.map_name ~= CHS[3000995] then
        -- 出地图后，龙虎界面没有关闭，该界面由服务器控制关闭的，做一个兼容
        DlgMgr:closeDlg("LonghzbInfoDlg")
    end

    if map.map_name ~= CHS[4101049] then
        DlgMgr:closeDlg("MingrzbInfoDlg")
    else
        if TaskMgr:isMRZBJournalist() or GMMgr:isGM() then
            -- 记者和GM不打开
        else
            DlgMgr:openDlg("MingrzbInfoDlg")
        end

    end

end

-- MSG_ENTER_ROOM消息早于MSG_ENTER_GAME
-- 2018寒假打雪战需要本地图过图，所以新增 isFuace
function MapMgr:MSG_ENTER_ROOM(map, isFuace)
    Log:I("MSG_ENTER_ROOM id:%d name:%s", map.map_id, map.map_name)

    Me.isMoved = false
    Me.isLimitMoveByClient = nil

    if not GameMgr.isLoadInitData or GMMgr:isGM() then
        -- WDSY-27017 修改 等收到 NOTIFY_SEND_INIT_DATA_DONE 消息再关闭
        -- WDSY-30133 GM监听其他玩家时不会收到NOTIFY_SEND_INIT_DATA_DONE
        DlgMgr:closeDlg("WaitDlg")
    end

    AutoWalkMgr:endRandomWalk()

    local notChangeMap = false
    if self.mapData ~= nil and self.mapData.map_id == map.map_id and
          (map.compact_map_index ~= 1 or self.mapData.map_index == map.map_index) then
        -- 如果compact_map_index == 1，不仅需要判断id是否相同，还要判断map_index是否相同；否则仅需判断id是否相同
        notChangeMap = true
    end

    if isFuace then
        -- 切换场景的显示范围
        Me:setPos(gf:convertToClientSpace(map.x, map.y))

        -- 希望还能播放过图界面，所以将如下标记设置为 false
        notChangeMap = false
    end

    if notChangeMap then
        self:openOrCloseDlgs(map)

        -- 没有更换地图
        -- 重置地图对象
        Me:setPos(gf:convertToClientSpace(map.x, map.y))
        Me:setLastMapPos(map.x, map.y)

        if GameMgr.scene and GameMgr.scene.map then
            GameMgr.scene.map:update(true)
        end

        -- 更新mapData 数据
        self.mapData.map_index = map.map_index

        -- 原本逻辑强调如果没有更换地图，不更新Me.lastMap
        -- 这样会导致同一地图被服务器重置位置时，不更新Me.lastMap，导致之后不移动的情况下进入战斗后脱离战斗会被拉回
        -- 暂时先作修改，等待探索原本逻辑的深层次原因
        if Me.lastMap then
            Me.lastMap = map
        end

        -- 标记本次不切换地图，hook逻辑中会使用到
        map.notChangeMap = true

        if self:getDefaultMapLayer() then
            -- GameMgr:clearData() 中会清除地图所有光效，即重连后地图光效也会被清除
            -- 角色若未换图，将导致地图光效不显示，故此处增加光效。
            self:getDefaultMapLayer():addMapMagic()
            self:getDefaultMapLayer():addMapStaticMagic()
        end

        if GameMgr:isInPartyWar() then
            DlgMgr:openDlg("PartyWarInfoDlg")
            DlgMgr:sendMsg("MissionDlg", "displayType")
        end

        return
    end

    local curMap = Me.lastMap

    -- 更新下服务器需要玩家重置的位置
    if Me.lastMap then
        Me.lastMap = map
    end

    -- 保存上一张地图的信息
    if self.mapData then
        self.lastMap = self.mapData
    else
        self.lastMap = map
    end

    self.mapData = map

    -- 从后台切换回来时有可能有很多条切换地图的消息，只有最近一条需要显示过图效果
    GameMgr:changeScene('GameScene')
    Log:I("MapMgr beginLoad")

    local loadTime = 1.4
    if map.enter_effect_index and map.enter_effect_index > 0 then
        -- 有特殊过图特效时，loading时间设置为0，防止特殊过图特效结束后，loading界面还存在1.4秒
        loadTime = 0
    end

    MapMgr:beginLoad(loadTime, map)

    self:openOrCloseDlgs(map)

    -- 清除地图上的所有子节点
    MapMagicMgr:clearData()
    HomeMgr:clearData(true)
    ActivityMgr:clearDataWhenEnterRoom()

    self:clearAllMapNpcs()

    PlayActionsMgr:clearAllAnimates()
    gf:getMapBgLayer():removeAllChildren()
    gf:getMapEffectLayer():removeAllChildren()
    gf:getMapObjLayer():removeAllChildren()

    local mapInfo = MapMgr:getMapinfo()
    self.defaultMapLayer = GameMgr.scene:initMap(map.map_id)

	-- 更新完地图后，更新Me在新地图上的位置
    Me:setPos(gf:convertToClientSpace(map.x, map.y))

    local dlg = DlgMgr:openDlg("SystemFunctionDlg")
    if string.isNilOrEmpty(map.map_show_name) then
        dlg:setMapName(map.map_name)
    else
        dlg:setMapName(map.map_show_name)
    end

    -- 播放地图背景音乐
    if MarryMgr:isWeddingStatus() and MarryMgr:isNeedPlayWeddingMusic() then -- 婚礼状态播放婚礼音乐
        SoundMgr:playMusic("marryMusic", true)
    else
        SoundMgr:playMusic(map.map_name)
    end
    -- 设置mission界面
    DlgMgr:sendMsg("MissionDlg", "displayType")
    DlgMgr:closeDlg("EightImmortalsDlg")


    local dlg = DlgMgr:getDlgByName("LoadingDlg")
    if dlg then
        dlg:registerExitCallBack(function()
            self:checkDungeonInfo()
            gf:resetFrameCost() -- 重置帧时间消耗及帧数
            GameMgr:checkNetworkState()
            if self.callBackInfo and self.callBackInfo.mapName == map.map_name then
                 self.callBackInfo.callFun()
            end
            self.callBackInfo = nil

            GameMgr.scene.map:destroyThumbnail()

            -- 检查内存状况
            gf:CheckMemory()
        end)

        if not dlg:isVisible() and map.enter_effect_index and map.enter_effect_index == 0 then
            if GameMgr.scene.map and not GameMgr.scene.map:createThumbnail(gf:convertToClientSpace(map.x, map.y)) then
                -- 缩略图创建失败，显示加载界面
                dlg:setVisible(true)
            end
        end
    end

    -- 矿石大战宝石使用界面
    if MapMgr:isInOreWars() then
        DlgMgr:openDlg("OreFunctionDlg")
    else
        DlgMgr:closeDlg("OreFunctionDlg")
    end

    -- 元旦罗盘寻踪：小罗盘界面在过图后需要判断是否需要打开
    if TaskMgr.souxlpData and map.map_name == TaskMgr.souxlpData[1] then
        DlgMgr:openDlgEx("SouxlpSmallDlg", {
            mapId = TaskMgr.souxlpData[2],
            x = TaskMgr.souxlpData[3],
            y = TaskMgr.souxlpData[4],
            needAction = TaskMgr.souxlpData[5],
        })
    else
        DlgMgr:closeDlg("SouxlpSmallDlg")
    end

    -- 跨服战场界面
    if map.map_name == CHS[4100704] then
        DlgMgr:openDlg("KuafzcInfoDlg")
    else
        DlgMgr:closeDlg("KuafzcInfoDlg")
    end

    -- 关闭智多星活动求助技能界面
    DlgMgr:closeDlg("ZhiDuoXingDlg")

    -- 关闭挑战巨兽
    DlgMgr:closeDlg("PartyBeatMonsterMainInfoDlg")

    -- 切换地图需要关闭的对话框
    MapMgr:changeMapCloseDlg()

    MapMgr:doShowWhenChangeMap()

    -- 家居处理
    HomeMgr:doWhenEnterRoom(map, self.lastMap)
    HomeChildMgr.birthAnimateData = nil
    HomeChildMgr.playSleepInHome = nil

    self:postEnterRoom()

    -- 若2018端午节，触碰 噬仙虫后，冻屏，换地图后需要解除
    ActivityMgr:releaseForSXC()

    EventDispatcher:dispatchEvent('SightTip')
end

function MapMgr:performPostEnterRoom(func)
    if 'table' ~= type(self.postEnterRoomList) then
        self.postEnterRoomList = {}
    end

    table.insert(self.postEnterRoomList, func)
end

function MapMgr:postEnterRoom()
    local funcList = self.postEnterRoomList
    self.postEnterRoomList = nil    -- 先清除数据，避免无限递归
    if 'table' == type(funcList) then
        for _, v in pairs(funcList) do
            if 'function' == type(v) then
                v()
            end
        end
    end
end

function MapMgr:changeMapCloseDlg()
    DlgMgr:closeDlg("RewardInquireDlg")
    DlgMgr:closeDlg("DijFinishDlg")
    DlgMgr:closeDlg("HomeStoreDlg")
    DlgMgr:closeDlg("HomeCookingDlg")
    DlgMgr:closeDlg("JiebVoteDlg")
end

function MapMgr:doShowWhenChangeMap()
    PracticeMgr:doShowWhenChangeMap()


    -- 2019情人节任务，如果玩家在S2状态不关闭界面，杀进程，再次登入，应服务器要求，客户端自己弹界面
    -- 处理正常进入
    if MapMgr:isInMapByName(CHS[4101241]) then
        local task = TaskMgr:getTaskByName(CHS[4101237])
        if task and task.task_extra_para == "2" then
            local dlg = DlgMgr:openDlg("DugeonRuleDlg")
            dlg:setType("valentine_2019_cjmg")
        end
    end
end

function MapMgr:checkSightScopeTip()
    if not GameMgr.initDataDone or not self.mapData then return end

    local userDefault = cc.UserDefault:getInstance()

    if self.mapData.map_id == 38004 and SystemSettingMgr:getSettingStatus("sight_scope", 0) == 0  then -- 试道场
        if userDefault:getIntegerForKey("MapTips:map_id:38004", 0) == 0 then
            gf:confirm(CHS[6600010], function ()
                local dlg = DlgMgr:openDlg("SystemConfigDlg")
                TaskMgr:markCloseDoubleTipTime(CHS[3004149])
                dlg:addMagic()
            end, function ()
                TaskMgr:markCloseDoubleTipTime(CHS[3004149])
            end)

            userDefault:setIntegerForKey("MapTips:map_id:38004", 1)
    end
    end

    if GameMgr:isInPartyWar() and SystemSettingMgr:getSettingStatus("sight_scope", 0) == 0 then -- 帮战地图
        if userDefault:getIntegerForKey("MapTips:map_id:38003", 0) == 0 then
            gf:confirm(CHS[6600010], function ()
                local dlg = DlgMgr:openDlg("SystemConfigDlg")
                TaskMgr:markCloseDoubleTipTime(CHS[3003208])
                dlg:addMagic()
            end, function ()
                TaskMgr:markCloseDoubleTipTime(CHS[3003208])
            end)
            userDefault:setIntegerForKey("MapTips:map_id:38003", 1)
        end
    end
end

-- 检查副本的状态
function MapMgr:checkDungeonInfo()
    local nextAutoWalkData = AutoWalkMgr.hasNext
    AutoWalkMgr.hasNext = nil

    -- 检查下是不是副本地图,如果是副本的话,进行自动寻路
    if TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
        -- 处于组队状态，并且是队员
        return
    end

    if nil == self.mapData then
        return
    end

    -- 从其他地图切换到副本地图
    local dungeonName = self:isDungeonMap(self.mapData.map_id)
    if dungeonName and nextAutoWalkData then

        if self.lastMap and not self:isDungeonMap(self.lastMap.map_id) then
            -- 上一张不是副本地图
            local taskInfo = TaskMgr:getDungeonTask(dungeonName)
            if taskInfo then
                AutoWalkMgr:beginAutoWalk(gf:findDest(taskInfo.task_prompt))
                return
            end
        end

        -- AutoWalkMgr.hasNext 标记为寻路信息，过图后，有继续，则继续寻路
        -- 当前用于证道殿-点击使用证道之魂，虽然不是副本地图，但是 isDungeonMap 接口都通用了
        AutoWalkMgr:beginAutoWalk(gf:findDest(nextAutoWalkData))
    end
end


-- 地图长宽块数 add by zhengjh
function MapMgr:setMapSize(widhtCell, heightCell)
    self.mapWidthCell= widhtCell
    self.mapHeightCell = heightCell
end

function MapMgr:getMapSize()
    return {width = self.mapWidthCell, height = self.mapHeightCell }
end

-- 矫正地图边界 add by zhengjh
function MapMgr:adjustPosition(x, y)
    local width = tonumber(x)
    local hegiht = tonumber(y)

    if width < 0 then
	   width = 0
	elseif width >= self.mapWidthCell then
        width = self.mapWidthCell - 1
	end

    if hegiht < 0 then
	   hegiht = 0
    elseif hegiht >= self.mapHeightCell then
        hegiht = self.mapHeightCell - 1
    end

	return width,hegiht
end

function MapMgr:getMapinfo()
    return MapInfo
end

function MapMgr:getCurrentMapInfo()
    return MapInfo[self:getCurrentMapId()]
end

function MapMgr:getDefaultMap()
    return self.defaultMapLayer
end

-- 显示加载动画，若已经在加载的话，返回false
function MapMgr:beginLoad(seconds, data)
    -- 判断载入对话是否已经在加载了，若在加载状态我们直接返回
    if DlgMgr:getDlgByName("LoadingDlg") ~= nil then
        return false
    end

    -- 如果还在战斗清除战斗动画
    if Me:isInCombat() or  Me:isLookOn() then
        FightMgr:cmdCEndAnimate()
    end

    DlgMgr:openDlg("LoadingDlg")
    local loadDlg = DlgMgr:getDlgByName("LoadingDlg")
    if loadDlg == nil then return false end

    MessageMgr.isBlockMsg = false
    loadDlg:showProgress(seconds)
    self.isLoadEnd = false
    loadDlg:setVisible(not self:canHideLoadingDlg(data))
    return true
end

function MapMgr:tryCheckTaskForLoading(task_type)
    if string.isNilOrEmpty(task_type) then return end
    local value = checkTaskWhenLoading[task_type]
    return true == value or ('function' == type(value) and value())
end

-- 是否隐藏过图界面
function MapMgr:canHideLoadingDlg(data)
    -- 需要播放特殊过图特效时，直接返回true
    if data and data.enter_effect_index and data.enter_effect_index > 0 then return true end

    if not self.enableHideLoading then return end

    local isTaskWalk
    if Me:isInTeam() and not Me:isTeamLeader() then
        -- 在队伍中且时队员，获取队伍的寻路信息
        if data then
            isTaskWalk = data.is_task_walk
        end
    else
        -- 主动寻路，获取当前的寻路信息
        if AutoWalkMgr.autoWalk and AutoWalkMgr.autoWalk.curTaskWalkPath then
            isTaskWalk = self:tryCheckTaskForLoading(AutoWalkMgr.autoWalk.curTaskWalkPath.task_type)
        end
    end

    if isTaskWalk then
        for k in pairs(DlgMgr.dlgs) do
            if not unCheckWhenHideLoadingDlg[k] and not DlgMgr:isFloatingDlg(k) and not string.match(k, "Home.*") and not string.match(k, "Furniture.*") and DlgMgr:sendMsg(k, "isVisible") then
                return true
            end
        end
    end
end

-- 保存当前地图的所有过图点
function MapMgr:setExitData(data)
    self.exitData = data
end

-- 获取过图点信息
function MapMgr:getExitData()
    return self.exitData
end

-- 获取过图的提示信息
function MapMgr:getLoadMapTips()
    if not self.loadMapTips then
        MapMgr:setLoadMapTips()
    end

    return self.loadMapTips
end

function MapMgr:isInShiDao()
    if self.mapData and self.mapData.map_id == 38004 then
        return true
    end

    return false
end

-- 是否在副本中
function MapMgr:isInDugeon()
    if MapMgr.mapData and FUBEN_MAP_ID[MapMgr.mapData.map_id] then
        return true
    end

    return false
end

-- 在八仙梦境中
function MapMgr:isInBaXian()
    if MapMgr.mapData and BAXIAN_MAP_ID[MapMgr.mapData.map_id] then
        return true
    end

    return false
end

-- 在异族入侵中
function MapMgr:isInYzrq()
    if MapMgr.mapData and YZRQ_MAP_ID[MapMgr.mapData.map_id] then
        return true
    end

    return false
end

-- 在植树节活动副本中
function MapMgr:isInZhiShuJieDugeon()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 10101 or MapMgr.mapData.map_id == 16104 then
            return true
        end
    end

    return false
end

-- 在化妆舞会场地中
function MapMgr:isInMasquerade()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38010 then
            return true
        end
    end

    return false
end

-- 在百兽战场
function MapMgr:isInBeastsKing()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38011 then
            return true
        end
    end

    return false
end

-- 在须弥秘境
function MapMgr:isInMiJing()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 15004 then
            return true
        end
    end

    return false
end

-- 在全民PK热身赛场
function MapMgr:isInQMReShen()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38007 then
            return true
        end
    end

    return false
end

-- 在全民楼兰城
function MapMgr:isInQMLoulan()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38008 then
            return true
        end
    end

    return false
end

-- 在全民赛场
function MapMgr:isInQMSaiChang()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38009 then
            return true
        end
    end

    return false
end

-- 在全民城市赛场
function MapMgr:isInQMCitySaiChang()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38022 then
            return true
        end
    end

    return false
end

function MapMgr:isInOreWars()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38014 or MapMgr.mapData.map_id == 38015 or MapMgr.mapData.map_id == 38016 then
            return true
        end
    end

    return false
end


-- 是否在【探案】江湖绿林副本中
function MapMgr:isInTanAnJhll()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 17101 or MapMgr.mapData.map_id == 17202
            or MapMgr.mapData.map_id == 17302 or MapMgr.mapData.map_id == 17401 then
            return true
        end
    end

    return false
end

-- 是否在【探案】迷仙镇案副本中
function MapMgr:isInTanAnMxza()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 01001 or MapMgr.mapData.map_id == 28103 or MapMgr.mapData.map_id == 28104
            or MapMgr.mapData.map_id == 28105 or MapMgr.mapData.map_id == 28106 then
            return true
        end
    end

    return false
end

-- 是否在元神突破任务地图:外冢一层
function MapMgr:isInWaiZhong()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 14008 then
            return true
        end
    end

    return false
end

-- 帮派总坛
function MapMgr:isInParty()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 26000 then
            return true
        end
    end

    return false
end


-- 在万妖窟
function MapMgr:isInWyk()
    if MapMgr.mapData then
        local mapId = MapMgr.mapData.map_id
        if mapId == 10102 or mapId == 10202 or mapId == 10302 or mapId == 10402 or mapId == 10502 then
            return true
        end
    end

    return false
end

function MapMgr:isInZongXianLou()
    -- 粽仙楼
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 37001 or MapMgr.mapData.map_id == 37002 or MapMgr.mapData.map_id == 37003 then
            return true
        end
    end

    return false
end

function MapMgr:isInZhongXian()
    -- 众仙塔
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 37004 or MapMgr.mapData.map_id == 37005 then
            return true
        end
    end

    return false
end

function MapMgr:isInWangMuQinGong()
    -- 王母寝宫
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 15005 then
            return true
        end
    end

    return false
end

function MapMgr:isInBaiHuaCongzhong()
    -- 百花丛中
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 17201 then
            return true
        end
    end

    return false
end

function MapMgr:isInXueJingShengdi()
    -- 雪精圣地
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 18001 then
            return true
        end
    end

    return false
end

function MapMgr:isInKuafjjzc()
    -- 跨服竞技战场
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38019 then
            return true
        end
    end

    return false
end

function MapMgr:isInShanZei()
    -- 山贼营外，山贼老巢
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 16005 or MapMgr.mapData.map_id == 08101 then
            return true
        end
    end

    return false
end

function MapMgr:isInShanZeiLaoChao()
    -- 山贼老巢
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 08101 then
            return true
        end
    end

    return false
end

-- 在世界BOSS地图埋没之地
function MapMgr:isInMaiMoZhiDi()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 20003 then
            return true
        end
    end

    return false
end

-- 千面酒会
function MapMgr:isInQMJH()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 05009 then
            return true
        end
    end

    return false
end

function MapMgr:isInKuafsdzc()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 38006 or MapMgr.mapData.map_id == 38025 then
            return true
        end
    end

    return false
end

function MapMgr:isInQingcld()
    if self.mapData and self.mapData.map_id == 05010 then
        return true
    end

    return false
end

function MapMgr:getZongXianLouFloor()
    if MapMgr.mapData then
        if MapMgr.mapData.map_id == 37001 then
            return 1
        elseif MapMgr.mapData.map_id == 37002 then
            return 2
        elseif MapMgr.mapData.map_id == 37003 then
            return 3
        end
    end
end

function MapMgr:setLoadMapTips()
    self.loadMapTips = {}
    local level = 1

    if Me then
        level =  Me:queryBasicInt("level")

        if level < 1 then
            level = 1
        end
    end

    for i = 1, #LoadingTips do
        if level < LoadingTips[i]["level"] then
            break
        else
            if LoadingTips[i]["distType"] then
                if LoadingTips[i]["distType"] == 1 and DistMgr:isOfficalDist() then
            table.insert(self.loadMapTips, LoadingTips[i] )
                elseif LoadingTips[i]["distType"] == 2 and not DistMgr:isOfficalDist() and not DistMgr:curIsTestDist() then
                    table.insert(self.loadMapTips, LoadingTips[i] )
        end
            else
                table.insert(self.loadMapTips, LoadingTips[i] )
    end
        end
    end
end

function MapMgr:setHaveGetExtits(isGetExtits)
    self.isGetExtits = isGetExtits
end

function MapMgr:getHaveGetExtits()
    return self.isGetExtits
end

function MapMgr:getDefaultMapLayer()
    return self.defaultMapLayer
end

-- 获取风月谷结婚的坐标点
function MapMgr:getWeddingActionPos()
    return cc.p(46, 18)
end

-- 获取风月谷的结婚区域
function MapMgr:getWeddingActionZone()
    local weddingActionPos = MapMgr:getWeddingActionPos()
    local roundSize = 3

    return cc.rect(weddingActionPos.x - roundSize, weddingActionPos.y - roundSize, roundSize * 2, roundSize * 2)
end

-- 是否在天墉城擂台
function MapMgr:isInTianyongLeiTai(pt)
    if MapMgr.mapData and MapMgr.mapData.map_name == CHS[2000075] then
        return Formula:ptInPolygon(pt, LEITAI_PT)
    end

    return false
end

-- 是否在居所
function MapMgr:isInHouse(mapName)
    if not mapName then return end
    local matchName = string.match(mapName, "^小舍*") or string.match(mapName, "^雅筑*") or string.match(mapName, "^豪宅*") or string.match(mapName, "^居所*")

    if string.isNilOrEmpty(matchName) then
        matchName = string.match(mapName, "居所")
    end

    return not string.isNilOrEmpty(matchName)
end

-- 是否在迷宫
function MapMgr:isInMiGong()
    if GameMgr.scene.map then
        return GameMgr.scene.map.mapType == MAP_TYPE.MIGONG_MAP
    end

    return false
end

-- 是否在居所前庭
function MapMgr:isInHouseVestibule(mapName)
    if not mapName then return end
    local matchName = string.match(mapName, CHS[2100215])
    return not string.isNilOrEmpty(matchName)
end

-- 是否在居所后院
function MapMgr:isInHouseBackYard(mapName)
    if not mapName then return end
    local matchName = string.match(mapName, CHS[2000284])
    return not string.isNilOrEmpty(matchName)
end

-- 是否在居所房屋
function MapMgr:isInHouseRoom(mapName)
    if not mapName then return end

    -- 2019劳动节npc地图不算居所地图
    if CHS[4010244] == mapName then return false end
    if CHS[4010245] == mapName then return false end
    if CHS[4010246] == mapName then return false end


    local matchName = string.match(mapName, CHS[2000283])
    return not string.isNilOrEmpty(matchName)
end

function MapMgr:onSystemSettingChanged(key, oldValue, newValue)
    if "sight_scope" ~= key or not self:getDefaultMapLayer() or oldValue == newValue then return end

    if 0 == newValue then
        self:getDefaultMapLayer():addMapMagic()
    else
        self:getDefaultMapLayer():removeMapMagic()
        self:getDefaultMapLayer():addMapStaticMagic()
    end
end

-- 设置地图npc的可见性
function MapMgr:setMapNpcVisible(visible)
    local count = self.mapNpcs and #(self.mapNpcs) or 0
    for i = 1, count do
        self.mapNpcs[i]:setVisible(visible)
    end
end

function MapMgr:MSG_TASK_PROMPT()
    -- 进入副本地图需要刷新一下任务面板
    if MapMgr:isInBaXian() then
        DlgMgr:sendMsg("MissionDlg", "refreshBaxianPanel")
    elseif MapMgr:isInDugeon() then
        DlgMgr:sendMsg("MissionDlg", "refreshFubenPanel")
    end
end

-- Debug 下检测所有地图的 NPC 中是否有同名的
function MapMgr:checkSameNameInMaps()
    if not ATM_IS_DEBUG_VER or not gf:isWindows() then
        return
    end

    local npcs = {}
    for key, map in pairs(MapInfo) do

        if map.npc and next(map.npc) then
            for _, v in pairs(map.npc) do
                if not npcs[v.name] then
                    npcs[v.name] = {}
                end

                table.insert(npcs[v.name], map.map_name)
            end
        end
    end

    local str = ""
    for name, v in pairs(npcs) do
        local cou = #v
        if cou > 1 then
            str = CHS[5410034] .. name .. "："
            for i = 1, cou do
                str = str .. v[i] .. "，"
            end

            str = str .. CHS[5410035]
            if name == CHS[4200440] then
                -- 联赛战场物资员,都是在本地图寻路，不需要检查
            else
            gf:ShowSmallTips(str)
            Log:D(str)
        end
    end
    end
end

function MapMgr:MSG_HOUSE_UPDATE_STYLE(data)
    if not self.mapData then return end

    if self.mapData.floor_index ~= data.floor_index then
    self.mapData.floor_index = data.floor_index
        GameMgr.scene.map:setTileIndex(MapMgr:getTileIndex())
    end

    if self.mapData.wall_index ~= data.wall_index then
    self.mapData.wall_index = data.wall_index
    GameMgr.scene.map:setWallIndex(MapMgr:getWallIndex())
    end
end

function MapMgr:Out2018HJHD(x, y)
    if not self.for2018HJHD then return end
    self.for2018HJHD.org_map.x = x
    self.for2018HJHD.org_map.y = y
    MapMgr:MSG_ENTER_ROOM(self.for2018HJHD.org_map, true)
    CharMgr:setVisible(true)

    -- CharMgr:setVisible(true)会将角色设置为可见，但是如果是共乘，需要特殊处理
    CharMgr:doCharHideStatus(Me)

    -- MSG_ENTER_ROOM会清掉场景中的过图点，所以出场景时需要再检测一下是否需要添加过图点
    if GameMgr.scene and "GameScene" == GameMgr.scene:getType() then
        GameMgr.scene:checkExits()
    end

end

function MapMgr:enter2018HJHD(pos)
    self.for2018HJHD = {}
    self.for2018HJHD.x = Me.curX
    self.for2018HJHD.y = Me.curY
    self.for2018HJHD.org_map = gf:deepCopy(self.mapData)
    self.for2018HJHD.map = gf:deepCopy(self.mapData)

    self.for2018HJHD.map.x = 33
    self.for2018HJHD.map.y = 34

    AutoWalkMgr:stopAutoWalk()


    if pos then
        self.for2018HJHD.map.x = pos.x
        self.for2018HJHD.map.y = pos.y
    end

    MapMgr:MSG_ENTER_ROOM(self.for2018HJHD.map, true)
    CharMgr:setVisible(false)

end

function MapMgr:MSG_MAP_NPC(data)
    local item
    item = MapNpc.new()
    item:absorbBasicFields({
        icon = data.icon,
        flip = data.flip,
    })

    item:setVisible(not Me:isInCombat() and not Me:isLookOn())
    item:action()
    item:onEnterScene(0, 0)

    local x, y = gf:convertToClientSpace(data.x, data.y)
    item:setPos(x + data.ox, y + data.oy)
    item:putNpc()

    table.insert(self.mapNpcs, item)
end


function MapMgr:MSG_WINTER2018_DAXZ_ENTER(data)
    local dlg
    if data and data.gameType then
        dlg = DlgMgr:openDlgEx("VacationSnowDlg", data.gameType)
    else
        dlg = DlgMgr:openDlg("VacationSnowDlg")
    end
    dlg:setGameState(0)

    MapMgr:enter2018HJHD()


    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:update(true)
    end

    Me:setFixedView(true)

end

function MapMgr:MSG_WINTER2018_DAXZ_END(data)
    DlgMgr:closeDlg("VacationSnowDlg")
    MapMgr:Out2018HJHD(data.x, data.y)
    Me:setFixedView(false)
    CharMgr:remove2018DXZ()
end

-- 冻柿子，收到此消息进入对应场景
function MapMgr:MSG_DONGSZ_2018_START(data)
    if not self.mapData then
        -- 地图数据还没准备好，可能在换线、重连或切后台了
        -- 待MSG_ENTER_ROOM之后再执行
        self:performPostEnterRoom(function()
            MapMgr:MSG_DONGSZ_2018_START(data)
        end)
        return
    end

    -- 组队进入场景，队友也要设置到指定位置，防止队长不断拉队友
    if TeamMgr:getLeaderId() == Me:getId() then
        Me.canShiftFlag = false
    end

    local pos = {x = 33, y = 34}
    MapMgr:enter2018HJHD(pos)

    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:update(true)
    end

    Me:setFixedView(true)

    local dlg = DlgMgr:openDlg("VacationPersimmonDlg")
    dlg:setData(data)

    data.playerOne.is2018HJ_DSZ = 1
    data.playerTwo.is2018HJ_DSZ = 1

    -- 隐藏称谓
    data.playerOne.title = ""
    data.playerTwo.title = ""

    -- 位置与光效
    if data.playerOne.gid == Me:queryBasic("gid") then
        data.playerOne.x = 43
        data.playerOne.y = 40
        data.playerOne.dir = 1
        data.playerTwo.x = 27
        data.playerTwo.y = 32
        data.playerTwo.dir = 5
        data.playerOne.light_effect_count = 1
        data.playerOne.light_effect = {ResMgr.magic.char_foot_eff1}
        data.playerTwo.light_effect_count = 1
        data.playerTwo.light_effect = {ResMgr.magic.char_foot_eff2}
    else
        data.playerOne.x = 27
        data.playerOne.y = 32
        data.playerOne.dir = 5
        data.playerTwo.x = 43
        data.playerTwo.y = 40
        data.playerTwo.dir = 1
        data.playerOne.light_effect_count = 1
        data.playerOne.light_effect = {ResMgr.magic.char_foot_eff2}
        data.playerTwo.light_effect_count = 1
        data.playerTwo.light_effect = {ResMgr.magic.char_foot_eff1}
    end

    CharMgr:MSG_APPEAR(data.playerOne)
    CharMgr:loadChar(data.playerOne)
    CharMgr:MSG_APPEAR(data.playerTwo)
    CharMgr:loadChar(data.playerTwo)
end


function MapMgr:MSG_DONGSZ_2018_END_POS(data)
    MapMgr:Out2018HJHD(data.x, data.y)
end

function MapMgr:MSG_CSB_MATCH_TIME_INFO(data)
end

function MapMgr:MSG_ENABLE_SPECIAL_AUTO_WALK(data)
    self.enableHideLoading = data.enable
end

-- 在名人争霸
function MapMgr:isInMRZB()
    if not MapMgr.mapData then return false end

    if  MapMgr.mapData.map_id == 38021 or MapMgr.mapData.map_id == 38020 then
        return true
    end
end

function MapMgr:MSG_DAXZ_ENTER(data)
    self:MSG_WINTER2018_DAXZ_ENTER({gameType = "fuqi-dxz"})
end

function MapMgr:MSG_DAXZ_END(data)
    self:MSG_WINTER2018_DAXZ_END(data)
end

-- 暑假元神归位 开始游戏
function MapMgr:MSG_YUANSGW_START_GAME(data)
    if not DlgMgr:isDlgOpened("VacationTempDlg") then
        DlgMgr:openDlgEx("VacationTempDlg", {type = 1})
    end

    if not self.mapData then
        -- 地图数据还没准备好，可能在换线、重连或切后台了
        -- 待MSG_ENTER_ROOM之后再执行
        self:performPostEnterRoom(function()
            MapMgr:MSG_YUANSGW_START_GAME(data)
        end)
        return
    end

    -- 组队进入场景，队友也要设置到指定位置，防止队长不断拉队友
    if TeamMgr:getLeaderId() == Me:getId() then
        Me.canShiftFlag = false
    end

    MapMgr:enter2018HJHD({x = data.x, y = data.y})

    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:update(true)
    end

    Me:setFixedView(true)

    -- 增加黑幕背景
    if FightMgr.bgImage then
        FightMgr.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
            Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())
        gf:getMapLayer():addChild(FightMgr.bgImage)
    end

    -- 播放战斗背景音乐
    -- SoundMgr:playFightingBackupMusic()
end

function MapMgr:MSG_YUANSGW_CHAR_INFO(data)
    data.player.is2018SJ_YSGW = 1
    data.player.isNowLoad = true

    if data.type < 3 then
        -- 升温者和降温者需要创建新的模型
        if Me:getId() == data.player.id then
            data.player.id = 1
        else
            data.player.id = 2
        end

        -- 隐藏称谓
        data.player.title = ""
    end

    if not self.ysgwCharInfo then
        self.ysgwCharInfo = {}
    end

    self.ysgwCharInfo[data.type] = data.player

    CharMgr:MSG_APPEAR(data.player)
end

-- 暑假元神归位  结束游戏
function MapMgr:MSG_YUANSGW_QUIT_GAME(data)
    gf:getMapLayer():removeChild(FightMgr.bgImage)
    DlgMgr:closeDlg("VacationTempDlg")

    if self.ysgwCharInfo then
        for _, v in pairs(self.ysgwCharInfo) do
            CharMgr:deleteChar(v.id)
        end
    end

    self.ysgwCharInfo = nil

    Me:setFixedView(false)
    MapMgr:Out2018HJHD(data.x, data.y)
end


MessageMgr:regist("MSG_DAXZ_ENTER", MapMgr)
MessageMgr:regist("MSG_DAXZ_END", MapMgr)
MessageMgr:regist("MSG_CSB_MATCH_TIME_INFO", MapMgr)
MessageMgr:regist("MSG_DONGSZ_2018_END_POS", MapMgr)
MessageMgr:regist("MSG_WINTER2018_DAXZ_END", MapMgr)
MessageMgr:regist("MSG_WINTER2018_DAXZ_ENTER", MapMgr)
MessageMgr:regist("MSG_YUANSGW_START_GAME", MapMgr)
MessageMgr:regist("MSG_YUANSGW_CHAR_INFO", MapMgr)
MessageMgr:regist("MSG_YUANSGW_QUIT_GAME", MapMgr)
MessageMgr:hook("MSG_TASK_PROMPT", MapMgr, "MapMgr")
MessageMgr:regist("MSG_ENTER_ROOM", MapMgr)
MessageMgr:regist("MSG_EXITS", MapMgr)
MessageMgr:regist("MSG_HOUSE_UPDATE_STYLE", MapMgr)
MessageMgr:regist("MSG_MAP_NPC", MapMgr)
MessageMgr:regist("MSG_DONGSZ_2018_START", MapMgr)
MessageMgr:regist("MSG_ENABLE_SPECIAL_AUTO_WALK", MapMgr)

EventDispatcher:addEventListener("SYSTEM_SETTING_CHANGE", MapMgr.onSystemSettingChanged, MapMgr)
EventDispatcher:addEventListener("SightTip", MapMgr.checkSightScopeTip, MapMgr)

return MapMgr
