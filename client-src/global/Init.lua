-- Init.lua
-- Created by chenyq Nov/10/2014
-- 执行初始化相关的操作

-- 重置载入的模块
-- 用于更新生效
local function resetLoadedPackage(modules)
    for i in ipairs(modules) do
        package.loaded[modules[i]] = nil
    end

    -- 清除路径缓存
    cc.FileUtils:getInstance():purgeCachedEntries()
end

-- 修复路径重复问题
local function fixDuplicatePath()
    if 'function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(14) then
        return
    end

    local paths = cc.FileUtils:getInstance():getSearchPaths()
    local hPaths = {}
    local nPaths = {}

    -- 从后往前找
    for i = #paths, 1, -1 do
        if not hPaths[paths[i]] then
            table.insert(nPaths, 1, paths[i])
            hPaths[paths[i]] = paths[i]
        end
    end

    cc.FileUtils:getInstance():setSearchPaths(nPaths)
end

cc.FileUtils:getInstance():addSearchPath(cc.FileUtils:getInstance():getWritablePath() .. "atmu", true)

-- 修复路径重复问题
fixDuplicatePath()

-- 记录到目前为止载入的模块
if not initModules then
    initModules = {}
    for k, v in pairs(package.loaded) do
        if "global/Init" ~= k and "global/Init.lua" ~= k then
            initModules[k] = v
        end
    end
end

-- 记录到目前为止的全局变量
if not __globalVars__ then
    __globalVars__ = {}
    for k, _ in pairs(_G) do
        __globalVars__[k] = 1
    end
end

-- 处理需要重新生效的模块
local reloadModules = {
    "comm/CommThread",
    "comm/Connection",
    "comm/global_send",
    "comm/CmdParser",
    "comm/MsgParser",
    "comm/Builders",
    "comm/Fields",
    "global/CHSUpdate",
    "cfg/UIScaleForDevices",
    "mgr/DeviceMgr",
    "cfg/LoadingTips",
    'global/GetColor',
    "dlg/LoginBack2018Dlg",
    "dlg/LoginBack2019Dlg",
    "dlg/CheckNetDlg",
    "mgr/CheckNetMgr",
    'global/GameEvent',
    'mgr/DragonBonesMgr',
    'mgr/WatchMgr',
    'json'
}

cc.UserDefault:getInstance():setStringForKey("start-update-version", "")
cc.UserDefault:getInstance():flush()

resetLoadedPackage(reloadModules)

-- 设置标点符号
if gfSetPunct and cc.FileUtils:getInstance():isFileExist("cfg/Punctuation.txt") then
    local fileData = cc.FileUtils:getInstance():getStringFromFile("cfg/Punctuation.txt")
    gfSetPunct(fileData)
end

-- 装载游戏模块
require('global/CHS')
require('global/CHSUpdate')
require('global/Const')
require('core/Log')
require('core/Singleton')
require('mgr/WatchMgr')
require('mgr/DeviceMgr')
require('global/GameEvent')
require('global/AndroidUtil')
require('global/GlobalFunc')
require('global/GetColor')
-- require('global/PerfUtil')
require("comm/CommThread")
require('mgr/EventDispatcher')
require('mgr/SmallTipsMgr')
require('mgr/Client')
require('mgr/MessageMgr')
require('mgr/DebugMgr')
require('mgr/ResMgr')
require('mgr/MapMgr')
require('dlg/Dialog')
require('scene/Scene')
require('mgr/DlgMgr')
require('mgr/CharMgr')
require('mgr/TeamMgr')
require('mgr/FightPosMgr')
require('mgr/FightMgr')
require('mgr/PetMgr')
require('mgr/SkillMgr')
require('obj/Me')
require('mgr/TextureMgr')
require('mgr/SkillEffectMgr')
require('mgr/GameMgr')
require('mgr/ChatMgr')
require('mgr/TaskMgr')
require('mgr/GuardMgr')
require('global/Formula')
require('mgr/InventoryMgr')
require("mgr/AutoWalkMgr")
require('mgr/RankMgr')
require("mgr/ShaderMgr")
require("mgr/OnlineMallMgr")
require("mgr/PartyMgr")
require('mgr/FriendsMgr')
require('mgr/SystemMessageMgr')
require('mgr/PracticeMgr')
require('mgr/DugeonMgr')
require('mgr/ArenaMgr')
require('mgr/ActivityMgr')
require('mgr/AutoFightMgr')
require('mgr/SoundMgr')
require("mgr/PartyWarMgr")
require("mgr/GiftMgr")
require("mgr/GMMgr")
require("mgr/GuideMgr")
require("mgr/EquipmentMgr")
require("mgr/ShiDaoMgr")
require('mgr/DroppedItemMgr')
require('mgr/AlchemyMgr')
require("mgr/MarketMgr")
require("mgr/MasterMgr")
require("mgr/RedDotMgr")
require("mgr/SystemSettingMgr")
require("mgr/BattleSimulatorMgr")
require("mgr/PromoteMgr")
require("mgr/StoreMgr")
require("mgr/LeitingSdkMgr")
require("mgr/AnimationMgr")
require("mgr/DistMgr")
require("mgr/MapMagicMgr")
require("mgr/LocalNotificationMgr")
require("mgr/BatteryAndWifiMgr")
require("mgr/NoticeMgr")
require("mgr/ChallengeLeaderMgr")
require("mgr/BrowMgr")
require("mgr/GetTaoMgr")
require("mgr/RebuyMgr")
require("mgr/ShareMgr")
require("mgr/ShortcutMgr")
require("mgr/ScreenRecordMgr")
require("mgr/SafeLockMgr")
require("mgr/DataBaseMgr")
require("mgr/AutoMsgMgr")
require("mgr/RecordLogMgr")
require("mgr/MarryMgr")
require("mgr/PlayActionsMgr")
require("mgr/ArmatureMgr")
require("mgr/QuestionMgr")
require('mgr/GiveMgr')
--require('mgr/GetuiPushMgr')
require('mgr/VibrateMgr')
require('mgr/GetuiPushMgr')
require('mgr/RingMgr')
require('mgr/PKDataMgr')
require('mgr/PrisonMgr')
require('mgr/TradingMgr')
require('mgr/LongZHDMgr')
require('mgr/ChunjieNianyefanMgr')
require('mgr/StatisticsMgr')
require('mgr/WatchCenterMgr')
require('mgr/WatchRecordMgr')
require('mgr/BarrageTalkMgr')
require('mgr/AnniversaryMgr')
require('mgr/QuanminPKMgr')
require('mgr/DragonBonesMgr')
require('mgr/JiebaiMgr')
require('mgr/YiShiMgr')
require('mgr/HomeMgr')
require('mgr/StateShudMgr')
require('mgr/StateMgr')
require("mgr/KuafzcMgr")
require("mgr/KuafjjMgr")
require("mgr/AchievementMgr")
require("mgr/BlogMgr")
require("mgr/CommunityMgr")
require("mgr/YuanXiaoMgr")
require("mgr/SummerSncgMgr")
require("mgr/GpsMgr")
require("mgr/ChatDecorateMgr")
require("mgr/InnerAlchemyMgr")
require("mgr/WorldBossMgr")
require("mgr/ChuqiangfuruoMgr")
require("mgr/MingrzbjcMgr")
require("mgr/CitySocialMgr")
require("mgr/UsefulWordsMgr")
require("mgr/WeatherMgr")
require("mgr/WeddingBookMgr")
require("mgr/LingChongHuanJingMgr")
require("mgr/InnMgr")
require("mgr/DressMgr")
require("mgr/TanAnMgr")
require("mgr/QuanminPK2Mgr")
require("mgr/ActivityHelperMgr")
require("mgr/EnterRoomEffectMgr")
require("mgr/LingyzmMgr")
require("mgr/TttSmfjMgr")
require("mgr/NewYearGuardMgr")
require("mgr/FightCmdRecordMgr")
require("mgr/MatchMakingMgr")
require("mgr/SpringFestivalAnimateMgr")
require("mgr/PuttingItemMgr")
require("mgr/ChildDayHsxgMgr")
require("mgr/FightCommanderCmdMgr")
require("mgr/TradingSpotMgr")
require("mgr/MiGongMapMgr")
require("mgr/PetExploreTeamMgr")
require("mgr/WenQuanMgr")
require("mgr/HomeChildMgr")
require("mgr/GoodVoiceMgr")
