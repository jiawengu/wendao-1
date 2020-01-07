-- GuideMgr.lua
-- Created by chenyq Apr/14/2015
-- 指引管理器

local Bitset = require("core/Bitset")
local List = require("core/List")
GuideMgr = Singleton()
local ALL_OPEN_ICON = {1, 2, 6, 7, 8, 9, 11, 10, 12, 13, 14, 15, 26, 27} -- 默认开启的图标及标签
--[[  对应
#图标                       序列    等级        指引
主界面图标-背包,            1,      0,          EMPTY_STRING
主界面图标-隐藏菜单,        2,      0,          EMPTY_STRING
主界面图标-帮派,            3,      25,         开启主界面图标-帮派
主界面图标-打造,            4,      35,         开启主界面图标-打造
主界面图标-守护,            5,      0,         开启主界面图标-守护
主界面图标-系统,            6,      0,          EMPTY_STRING
主界面图标-好友,            7,      0,          EMPTY_STRING
主界面图标-世界地图,        8,      0,          EMPTY_STRING
主界面图标-小地图,          9,      0,          EMPTY_STRING
主界面图标-排行榜,          10,     25,         开启主界面图标-排行榜
主界面图标-商城,            11,     0,          EMPTY_STRING
主界面图标-交易,            12,     0,          EMPTY_STRING
主界面图标-集市,            13,     0,          EMPTY_STRING
主界面图标-珍宝,            14,     0,          EMPTY_STRING
主界面图标-福利,            15,     0,          EMPTY_STRING
主界面图标-巡逻,            16,     20,         开启主界面图标-巡逻
主界面图标-刷道,            17,     45,         开启主界面图标-刷道
主界面图标-活动,            18,     -1,         开启主界面图标-活动
主界面图标-首饰,            19,     35,         EMPTY_STRING
主界面图标-装备,            20,     40,         EMPTY_STRING
主界面图标-法宝,            21,     70,         开启主界面图标-法宝
主界面图标-观战中心,        22,     50,         开启主界面图标-观战中心
主界面图标-周年庆,          23,     -1,         开启主界面图标-周年庆
主界面图标-QQ合作,          24,     -1,         开启主界面图标-QQ合作
主界面图标-居所,            25,     75,         开启主界面图标-居所
主界面图标-提升,            26,     0,          EMPTY_STRING
主界面图标-成就,            27,     0,          EMPTY_STRING
--]]


GuideMgr.visibleIcon = gf:deepCopy(ALL_OPEN_ICON)       -- 主界面显示图标
GuideMgr.tabIcon = {}
GuideMgr.guideEveryList = {}    -- 指引列表
GuideMgr.guideList = {}         -- 流程列表
GuideMgr.curGuide = ""
GuideMgr.iconList = {}
GuideMgr.equipList = {}
GuideMgr.curGuidListCtrl = {}

local EFFECT_TAG = 100

-- 光效图标列表
GuideMgr.effectIcon = {3, 4, 5, 10, 16, 17, 18, 21, 22, 25}

-- 文字偏移的位置
local directMapping = {
    ["right"]     = {0, 0.5, 1, 0.5},
    ["left"]      = {1, 0.5, 0, 0.5},
    ["up"]        = {0.5, 0, 0.5, 1},
    ["down"]      = {0.5, 1, 0.5, 0},
    ["leftUp"]    = {1, 0, 0, 1},
    ["leftDown"]  = {1, 1, 0, 0},
    ["rightUp"]   = {0, 0, 1, 1},
    ["rightDown"] = {0, 1, 1, 0},
}

-- 标签图标的编号及控件名
local ALL_TAB_ICON_LIST = {
    -- [33] = "UserDlgCheckBox",   -- 角色
    -- [34] = "UserAddPointDlgCheckBox",  -- 加点
    -- [35] = "PolarAddPointDlgCheckBox",  -- 相性
    [36] = "SkillDlgCheckBox",  -- 技能
    [37] = "PetAttribDlgCheckBox",  -- 宠物属性
    [38] = "PetSkillDlgCheckBox",  -- 宠物技能
    [39] = "PetGetAttribDlgCheckBox",  -- 宠物加点
    [40] = "PetHandbookDlgCheckBox",  -- 宠物图鉴
    [41] = "EquipmentSplitTabDlgCheckBox",  -- 装备拆分
    [42] = "EquipmentUpgradeDlgCheckBox",  -- 装备改造
    [43] = "EquipmentRefiningTabDlgCheckBox",  -- 装备炼化
    [44] = "EquipmentRefiningSuitDlgCheckBox",  -- 套装
    [45] = "EquipmentEvolveDlgCheckBox",  -- 装备进化
    [46] = "GuardAttribDlgCheckBox", -- 守护属性
    [47] = "ArtifactRefineTabDlgCheckBox",  -- 法宝洗炼
    [48] = "ArtifactSkillUpTabDlgCheckBox", -- 法宝特技

    -- ["UserDlgCheckBox"] = 33,   -- 角色
    -- ["UserAddPointDlgCheckBox"] = 34,  -- 加点
    -- ["PolarAddPointDlgCheckBox"] = 35,  -- 相性
    ["SkillDlgCheckBox"] = 36,  -- 技能
    ["PetAttribDlgCheckBox"] = 37,  -- 宠物属性
    ["PetSkillDlgCheckBox"] = 38,  -- 宠物技能
    ["PetGetAttribDlgCheckBox"] = 39,  -- 宠物加点
    ["PetHandbookDlgCheckBox"] = 40,  -- 宠物图鉴
    ["EquipmentSplitTabDlgCheckBox"] = 41,  -- 装备拆分
    ["EquipmentUpgradeDlgCheckBox"] = 42,  -- 装备改造
    ["EquipmentRefiningTabDlgCheckBox"] = 43,  -- 装备炼化
    ["EquipmentRefiningSuitDlgCheckBox"] = 44,  -- 套装
    ["EquipmentEvolveDlgCheckBox"] = 45,  -- 装备进化
    ["GuardAttribDlgCheckBox"] = 46, -- 守护属性
    ["ArtifactRefineTabDlgCheckBox"] = 47,  -- 法宝洗炼
    ["ArtifactSkillUpTabDlgCheckBox"] = 48, -- 法宝特技
}

-- 二级图标
local SECOND_ICON_LIST =
{
    [29] = "ArtifactButton"
}

-- 指引的当前状态
local GUIDE_STATE = {
    PLAYING = 1,
    WAITING = 2,
}

--类型说明
-- TOUCH       点击事件
-- DTOUCH      点击事件
-- LTOUCH      点击事件
-- TOUCHNPC    点击NPC事件
-- OPENDLG     打开对话框事件
-- TOUCHBTN    点击按钮事件
-- TOUCHBTNEX  特殊的点击按钮事件，如果需要点击列表中的item，需要对话框提供接口，返回item的Pos坐标及BoundingBox
--             统一接口Dialog:getLastSelectItem() 返回点击的BoundingBox,需要转换成窗口坐标
local GUIDE_TYPE = {
    TOUCH       = "Touch",
    DTOUCH      = "DTouch",
    LTOUCH      = "LTouch",
    TOUCHNPC    = "TouchNpc",
    OPENDLG     = "OpenDlg",
    OPENDLGEX   = "OpenDlgEx",
    TOUCHBTN    = "TouchBtn",
    TOUCHBTNEX  = "TouchBtnEx",
    ADDICON     = "addIcon",
    TOUCHOBJINFIGHT = "TouchObjInFight",
    CLIENT_NOTIFY   = "ClientNotify",
    TOUCH_LONG_CTRL = "TouchLongCtrl",
}

-- 子类型判断
local GUIDE_SUB_TYPE = {
    CLOSE_DLG   = "closeDlg",
    NEED_CALL_BACK = "TouchCallBack",
}

-- 初始化，加载列表
function GuideMgr:init()
    -- 加载指引列表
    GuideMgr.guideEveryList = require("cfg/GuideEveryInfo")
    GuideMgr.guideList = require("cfg/GuideInfo")
    GuideMgr.iconList = require("cfg/MainIconItemInfo")
    GuideMgr.thingsAfterGuide = require("cfg/GuideAfterThings")

    -- 获取上一次的指引
    local curGuide = cc.UserDefault:getInstance():getStringForKey("lastGuide", "")
    if "" ~= self.curGuide then
        -- 如果指引存在，获取数据，播放
        local guidId, everyId = string.match(curGuide, "(%d+):(%d+)")
        GuideMgr:playGuideById(guidId, everyId)
    end
end

-- 判断标签页是否已经开启，判断必定存在的标签页
function GuideMgr:hasThisTab(ctrlName)
    if ALL_TAB_ICON_LIST[ctrlName] then
        for i = 1, #GuideMgr.tabIcon do
            if GuideMgr.tabIcon[i] == ALL_TAB_ICON_LIST[ctrlName] then
                return true
            end
        end
    end

    return false
end

-- 判断是不是标签
function GuideMgr:isTabIcon(ctrlName)
    if ALL_TAB_ICON_LIST[ctrlName] then
        return true
    end

    return false
end

-- 判断当前标签是否开启，所有标签页都可以判断
function GuideMgr:isTabVisible(tabCtrlName)
    -- 如果标签不在需要开启列表中
    if not ALL_TAB_ICON_LIST[tabCtrlName] then
        -- 直接返回true
        return true
    end

    -- 如果在列表中
    -- 判断是否已经开启
    local tabIconNo = ALL_TAB_ICON_LIST[tabCtrlName]
    for _, value in pairs(GuideMgr.tabIcon) do
        if value == tabIconNo then
            -- 已经开启，return true
            return true
        end
    end

    return false
end

-- 判断当前标签是否需要播放光效
function GuideMgr:isEffectIcon(icon)
    for i = 1, #GuideMgr.effectIcon do
        if GuideMgr.effectIcon[i] == icon then
            return true
        end
    end

    return false
end

-- 判断界面图标是否存在
function GuideMgr:isIconExist(iconId)
    if 'table' == type(iconId) then
        for i = 1, #iconId do
            if self:isIconExist(iconId[i]) then return true end
        end
    else
        for i = 1, #GuideMgr.visibleIcon do
            if GuideMgr.visibleIcon[i] == iconId then
                return true
            end
        end
    end
    return false
end

-- 添加主界面图标
function GuideMgr:addMainIcon(iconId)
    if not GuideMgr:isIconExist(iconId) then
        table.insert(GuideMgr.visibleIcon, iconId)
    end
end

-- 设置排列界面图标
function GuideMgr:setMainIcon()
    for key, v in pairs(GuideMgr.iconList) do

        local dlg = DlgMgr:openDlg(v.dlgName)
        if self:isIconExist(key) then
            -- 将可见的主图标加入可见图标列表
            if dlg.addListIcon then
                dlg:addListIcon(v.ctrlName)
            end
        else
            -- 将不可见的主图标移出图标列表
            if dlg.removeListIcon then
                dlg:removeListIcon(v.ctrlName)
            end
        end
    end
end

-- 刷新排列界面图标
function GuideMgr:refreshMainIcon(isGuide, ctrlName)
    if not GameMgr or not GameMgr.scene or GameMgr.scene:getType() ~= "GameScene" then return end

    if GameMgr.curMainUIState ~= MAIN_UI_STATE.STATE_SHOW then
        GameMgr:showAllUI(0)
    end

    local gameVisible = DlgMgr:isVisible("GameFunctionDlg")
    local sysVisible = DlgMgr:isVisible("SystemFunctionDlg")
    local headVisible = DlgMgr:isVisible("HeadDlg")
    local chatVisible = DlgMgr:isVisible("ChatDlg")

    GameMgr.isMove = false
    GuideMgr:setMainIcon()

    local gameDlg = DlgMgr:openDlg("GameFunctionDlg")
    gameDlg:refreshIcon(isGuide, ctrlName)

    local sysDlg = DlgMgr:openDlg("SystemFunctionDlg")
    sysDlg:refreshIcon(isGuide, ctrlName)

    local headDlg = DlgMgr:openDlg("HeadDlg")
    headDlg:resetRootPos()
    local chatDlg = DlgMgr:openDlg("ChatDlg")
    chatDlg:resetRootPos()

    if not DlgMgr:isNeedShowAndHideMainDlg() then
        -- 不需要对主界面做隐藏和显示操作，按原状态显示
        DlgMgr:showDlg("GameFunctionDlg", gameVisible)
        DlgMgr:showDlg("SystemFunctionDlg", sysVisible)
        DlgMgr:showDlg("HeadDlg", headVisible)
        DlgMgr:showDlg("ChatDlg", chatVisible)
    end
end

-- 获取主界界面的Icon控件
function GuideMgr:getMainIconCtrl(iconId)
    local iconInfo = GuideMgr.iconList[iconId]
    if nil == iconInfo then
        gf:ShowSmallTips(CHS[3004053] .. iconId .. CHS[3004054])
        return
    end

    local dlg = DlgMgr:openDlg(iconInfo.dlgName)

    if nil ~= dlg["getIconCtrl"] and "function" == type(dlg["getIconCtrl"]) then
        local ctrl = dlg:getIconCtrl(iconInfo.ctrlName)
        if nil ~= ctrl then
            return ctrl
        end
    end

    return nil
end

-- 获取添加图标前准备
function GuideMgr:preAddMainIconCtrl(iconId)
    local iconInfo = GuideMgr.iconList[iconId]
    local dlg = DlgMgr:openDlg(iconInfo.dlgName)
    local pos = nil
    if nil ~= dlg["preAddIcon"] and "function" == type(dlg["preAddIcon"]) then
        pos = dlg:preAddIcon(iconInfo.ctrlName)
    end

    GuideMgr:addMainIcon(iconId)
    return pos
end

-- 获取指引缓存队列
function GuideMgr:getGuideCache()
    if nil == self.guideCache then
        self.guideCache = List.new()
    end

    return self.guideCache
end

-- 从缓存中获取指引，播放指引
function GuideMgr:playGuide()
    if GUIDE_STATE.PLAYING == GuideMgr.state or Me:isInCombat()then
        return
    end

    -- 清除listView
    GuideMgr:removeCurGuidListCtrl()

    if 0 < GuideMgr:getGuideCache():size() then
        local nexts = GuideMgr:getGuideCache():popFront()
        if nil ~= nexts then
            GuideMgr:playGuideById(nexts.guideId, nexts.everyId)
        end
    end
end

-- 关闭指引
function GuideMgr:closeData()
    -- 关闭守护线程
    GuideMgr:stopDaemon()

    -- 清空缓存
    self:clearGuideCache()

    -- 关闭定时器
    GuideMgr:stopSchedule()

    -- 状态设置为等待
    GuideMgr.state = GUIDE_STATE.WAITING
    Log:T("GuideMgr.state = GUIDE_STATE.WAITING 272")

    -- 移除显示层
    if self.guideLayer then
        gf:getUILayer():removeChild(self.guideLayer)
        self.guideLayer = nil
    end

    -- 移除事件响应层
    if self.guideEventLayer then
        gf:getUILayer():removeChild(self.guideEventLayer)
        self.guideEventLayer = nil
    end

    self.lastTime = nil

    -- 重置显示图标
    GuideMgr.visibleIcon = gf:deepCopy(ALL_OPEN_ICON)
    GuideMgr.tabIcon = {}
    self.hasScaleAni = nil

    local gameDlg = DlgMgr:getDlgByName("GameFunctionDlg")
    if gameDlg then
        gameDlg:cleanup()
    end

    local sysDlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if sysDlg then
        sysDlg:cleanup()
    end
end

-- 关闭当前指引
function GuideMgr:closeCurrentGuide()
    -- 关闭守护线程
    GuideMgr:stopDaemon()

    -- 清空缓存
    self:clearGuideCache()

    -- 关闭定时器
    GuideMgr:stopSchedule()

    -- 状态设置为等待
    GuideMgr.state = GUIDE_STATE.WAITING
    Log:T("GuideMgr.state = GUIDE_STATE.WAITING 310")
    -- 关闭显示层
    if nil ~= self.guideLayer then
        self.guideLayer:setVisible(false)
        GuideMgr:setClipNodeVisible(false)
        GuideMgr:setClipNodeContent(cc.rect(0, 0, 0, 0))
        self.guideLayer:removeAllChildren(true)
        GuideMgr:closeTipInfo()
    end
end

-- 清除指引缓存
function GuideMgr:clearGuideCache()
    -- WDSY-36811，清除缓存前，如果指引是新增图标，则尝试添加图标
    if self.guideCache then
        local count = self.guideCache:size()
        for i = 1, count do
            local guideInfo = self.guideCache:popFront()
            local guide = GuideMgr:getGuideItemById(guideInfo.guideId)
            if guide then
                for j = 1, #guide do
                    local everyItem = self.guideEveryList[guide[j]]
                    if everyItem and GUIDE_TYPE.ADDICON == everyItem.operType then
                        if ALL_TAB_ICON_LIST[everyItem.oper] then
                            -- 标签
                            table.insert(GuideMgr.tabIcon, everyItem.oper)
                        else
                            -- 图标
                            self:addMainIcon(everyItem.oper)
                        end
                    end
                end
            end
        end
    end

    self.guideCache = nil
end

-- 指引是否在运行
function GuideMgr:isRunning()
    if GUIDE_STATE.PLAYING == GuideMgr.state then
        return true
    end

    return false
end

-- 冻屏
function GuideMgr:frozenScreen(isClear)
    self:getGuideLayer():setVisible(true)
    if not isClear then
        GuideMgr:setClipNodeContent(cc.rect(0, 0, 0, 0))
    end

    self:getGuideLayer():removeAllChildren(true)
    Log:D(">>>> frozenScreen")
end

-- 解除冻屏
function GuideMgr:unFrozenScreen()
    self:getGuideLayer():setVisible(false)
    Log:D(">>>> unFrozenScreen")
end

-- 将置灰层隐藏
function GuideMgr:setClipNodeVisibleFalse()
    GuideMgr:setClipNodeVisible(false)
    GuideMgr:setClipNodeContent(cc.rect(0, 0, 0, 0))
end

-- 指引结束操作
function GuideMgr:doEndPlayGuide(guidId)
    -- 向服务端发送指引结束标志
    if not BattleSimulatorMgr:isRunning() then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTICE_OVER_INSTRUCTION, guidId)
    end

    self.curItem = nil
    self.guideId = nil
    self.everyId = nil

    GuideMgr.state = GUIDE_STATE.WAITING
    GuideMgr:setClipNodeVisible(false)
    GuideMgr:unFrozenScreen()
    GuideMgr:removeCurGuidListCtrl()
    GuideMgr:stopDaemon()
    GuideMgr:stopSchedule()
    GuideMgr:closeTipInfo()
    GuideMgr:doWhenEndGuide(guidId)
    Log:T("GuideMgr.state = GUIDE_STATE.WAITING 365")

    if 0 < GuideMgr:getGuideCache():size() then
        local nexts = GuideMgr:getGuideCache():popFront()
        if nil ~= nexts then
            GuideMgr:playGuideById(nexts.guideId, nexts.everyId)
        end
    else
        AutoWalkMgr:tryToContinueAutoWalk(true)
    end
end

function GuideMgr:doWhenEndGuide(guideId)
    -- 指引完毕后
    if GuideMgr.thingsAfterGuide[guideId] then
        local data = GuideMgr.thingsAfterGuide[guideId]
        DlgMgr:sendMsg(data.dlg, data.func)
    end
end

-- 开始播放指引
function GuideMgr:playGuideById(guideId, everyId)
    -- 当前正在播放指引
    local fightGuideId = FightMgr:getFightGuideId()
    if GUIDE_STATE.PLAYING == GuideMgr.state or ((Me:isInCombat() or Me:isLookOn()) and not fightGuideId[guideId]) then
        -- 正在播放，插入队列中
        GuideMgr:getGuideCache():pushBack({guideId = guideId, everyId = everyId})
        return
    end

    GuideMgr:unFrozenScreen()

    -- 获取指引条目
    local guide = GuideMgr:getGuideItemById(guideId)
    if nil == guide then
        gf:ShowSmallTips(CHS[3004055])  ---- todo 没配置直接返回
        self:doEndPlayGuide(guideId)
        return
    end

    -- 根据播放的位置进行重置
    local start = 1
    if nil ~= everyId then
        start = everyId
    end

    -- 回到主界面,且关闭其他无关窗口
    local id = guide[start]
    local everyItem = GuideMgr.guideEveryList[id]

    if #guide ~= 1 or everyItem.operType ~= GUIDE_TYPE.ADDICON or GuideMgr:isEffectIcon(everyItem.oper) then
        -- 不用播放光效的添加按钮指引不需要做回到主界面的逻辑
        if not (everyItem.operType == GUIDE_TYPE.ADDICON and self:isTabIcon(everyItem.oper))then
            DlgMgr:returnToMain()
        end
    end

    -- 站住
    Me:setAct(Const.SA_STAND)

    -- 标记开始播放指引
    GuideMgr.state = GUIDE_STATE.PLAYING

    -- 开始起定时器进行指引的容错
    GuideMgr:startDaemon()

    -- 开始播放第一幕
    GuideMgr:playEveryGuide(guideId, everyId)
end

local CHECK_TIME = 1
local OVER_TIME = 5000
local lastCheckTime = 0
local lastEffectTime = 0
local lastBoxTime = 0
local lastContainTime = 0
local lastOpenDlgTime = 0

-- 启动守护线程
function GuideMgr:startDaemon()
    if nil ~= GuideMgr.daemonId then
        gf:Unschedule(GuideMgr.daemonId)
        GuideMgr.daemonId = nil
    end

    GuideMgr.daemonId = gf:Schedule(function() GuideMgr:doDaemon() end, CHECK_TIME)
end

-- 关闭守护线程
function GuideMgr:stopDaemon()
    if nil ~= GuideMgr.daemonId then
        gf:Unschedule(GuideMgr.daemonId)
        GuideMgr.daemonId = nil
    end

    lastCheckTime = 0
    lastEffectTime = 0
    lastBoxTime = 0
    lastContainTime = 0

    Log:D(CHS[3004056])
end

-- 指引容错判断
function GuideMgr:doDaemon()
    -- 1秒检查一次

    local curTime = gf:getTickCount()
    local guideLayer = self:getGuideLayer()

    -- 检查是否存在指引的手指动画
    local effect = guideLayer:getChildByTag(EFFECT_TAG)
    if not effect and 0 ~= lastEffectTime then
        -- 如果lastEffectTime不等于0，并且与当前时间相比，超过5秒，那么结束指引
        if curTime - lastEffectTime >= OVER_TIME then
            GuideMgr:doEndPlayGuide(self.guideId)
            return
        end
    else
        -- 有光效，更新时间
        lastEffectTime = curTime
    end

    -- 检查是否存在box 区域
    if (not guideLayer.box
        or (0 == guideLayer.box.x and 0 == guideLayer.box.y)
        or (0 == guideLayer.box.width and 0 == guideLayer.box.height))
        and 0 ~= lastBoxTime then
        -- 不存在
        if curTime - lastBoxTime >= OVER_TIME then
            GuideMgr:doEndPlayGuide(self.guideId)
            return
        end
    else
        -- 有box 区域，更新时间
        lastBoxTime = curTime
    end

    -- 检查响应区域是否在屏幕内
    if  (not guideLayer.box
        or guideLayer.box.x <= - guideLayer.box.width
        or guideLayer.box.y <= - guideLayer.box.height
        or guideLayer.box.x >= Const.WINSIZE.width
        or guideLayer.box.y >= Const.WINSIZE.height)
        and 0 ~= lastContainTime then
        if curTime - lastContainTime >= OVER_TIME then
            GuideMgr:doEndPlayGuide(self.guideId)
            return
        end
    else
        -- 响应区域在屏幕内，更新时间
        lastContainTime = curTime
    end

    -- 需要增加当前需要操作的窗口如果未打开的时候的容错处理
    local guideItem = self.curItem
    if not guideItem
        and GUIDE_TYPE.TOUCHBTN == guideItem.operType
        and not DlgMgr:isDlgOpened(guideItem.relationDlg)
        and 0 ~= lastOpenDlgTime then
        if curTime - lastOpenDlgTime >= OVER_TIME then
            GuideMgr:doEndPlayGuide(self.guideId)
            return
        end
    else
        lastOpenDlgTime = curTime
    end
end

-- 播放单条指引
function GuideMgr:playEveryGuide(guideId, everyId)
    -- 保存正在播放指引信息
    cc.UserDefault:getInstance():setStringForKey("lastGuide", string.format("%s:%s", tostring(guideId), tostring(everyId)))
    Log:D(">>>> play guide : guideId = %d, everyId = %d", guideId, everyId)

    -- 获取指引条目
    local guide = GuideMgr:getGuideItemById(guideId)
    if nil == guide then
        -- 指引丢失
        return
    end

    if everyId > #guide then
        -- 已经结束了，结束处理
        self:doEndPlayGuide(guideId)
        return
    end

    -- 从every列表中获取播放条目
    local id = guide[everyId]
    local everyItem = GuideMgr.guideEveryList[id]

    -- 将标签放入缓存中
    self.curItem = everyItem
    self.guideId = guideId
    self.everyId = everyId
    GuideMgr:playGuideByObj(everyItem)
end

-- 播放下一个指引
function GuideMgr:playNextGuideStep()
    if nil == self.guideId or nil == self.everyId then
        self:doEndPlayGuide(self.guideId)
        return
    end

    GuideMgr:frozenScreen()
    Log:D(">>>> play guide : " .. self.guideId .. ", everyId : " .. self.everyId)
    self:playEveryGuide(self.guideId, self.everyId + 1)
end

-- 启动定时器
function GuideMgr:startSchedule()
    if nil ~= GuideMgr.scheduleId then
        gf:Unschedule(GuideMgr.scheduleId)
        GuideMgr.scheduleId = nil
    end

    GuideMgr.scheduleId = gf:Schedule(function(delta) GuideMgr:dealIsDoSomething(delta) end, 0)
end

-- 停止定时器
function GuideMgr:stopSchedule()
    if nil ~= GuideMgr.scheduleId then
        gf:Unschedule(GuideMgr.scheduleId)
        GuideMgr.scheduleId = nil
    end
end

-- 定时器处理逻辑
function GuideMgr:dealIsDoSomething(delta)
    if nil == self.curItem then return end
    local type = self.curItem.operType

    if GUIDE_TYPE.TOUCHNPC == type then
        if Me.lastSelectChar == self.curItem.oper then
            -- 停止定时器
            GuideMgr:stopSchedule()

            -- 播放下一条
            GuideMgr:playNextGuideStep()
        end
    elseif GUIDE_TYPE.OPENDLG == type then
        if DlgMgr:isDlgOpened(self.curItem.oper.dlgName) then
            -- 停止定时器
            GuideMgr:stopSchedule()

            -- 播放下一条
            GuideMgr:frozenScreen()
            local action = cc.CallFunc:create(function() GuideMgr:playNextGuideStep() end)
            self:getGuideLayer():runAction(action)
        end
    elseif GUIDE_TYPE.OPENDLGEX == type then
        if DlgMgr:isDlgOpened(self.curItem.oper.dlgName)
            and DlgMgr:getDlgByName(self.curItem.oper.dlgName):isVisible() then
            -- 停止定时器
            GuideMgr:stopSchedule()

            -- 播放下一条
            GuideMgr:frozenScreen()
            local action = cc.CallFunc:create(function() GuideMgr:playNextGuideStep() end)
            self:getGuideLayer():runAction(action)
        end
    elseif GUIDE_TYPE.TOUCHBTNEX == self.curItem.operType
        and GUIDE_SUB_TYPE.CLOSE_DLG == self.curItem.oper.subType then
        if not DlgMgr:isDlgOpened(self.curItem.relationDlg) then
            -- 停止定时器
            GuideMgr:stopSchedule()

            -- 播放下一条
            GuideMgr:frozenScreen()
            local action = cc.CallFunc:create(function() GuideMgr:playNextGuideStep() end)
            self:getGuideLayer():runAction(action)
        end
    end
end

-- 通过指引对象来播放指引
function GuideMgr:playGuideByObj(everyItem)
    local boxContentSize = cc.Director:getInstance():getWinSize()
    local pos = {x = 0, y = 0}

    if nil ~= everyItem then
        if GameMgr:isHideAllUI() then
            GuideMgr:refreshMainIcon()
        end

        -- 判断类别
        if  GUIDE_TYPE.TOUCH == everyItem.operType or
            GUIDE_TYPE.DTOUCH == everyItem.operType or
            GUIDE_TYPE.LTOUCH == everyItem.operType  then
            -- 获取区域
            pos = everyItem.oper
            boxContentSize.width = 30
            boxContentSize.height = 30
        elseif GUIDE_TYPE.TOUCHNPC == everyItem.operType then
            -- 获取NPC位置和NPC ContentSize
            -- 起一个定时器判断是否点击到了NPC
            GuideMgr:startSchedule()
            return
        elseif GUIDE_TYPE.OPENDLG == everyItem.operType then
            if DlgMgr:isDlgOpened(everyItem.oper.dlgName) then
                -- 窗口已经打开了，播放下一条
                GuideMgr:playNextGuideStep()
                return
            end

            -- 禁止listView移动
            GuideMgr:setCurGuidListCtrlUnEnable()

            if DlgMgr:isDlgOpened(everyItem.relationDlg) then
                -- 窗口开启，获取控件,并计算点击位置
                local dlg = DlgMgr:getDlgByName(everyItem.relationDlg)
                local ctrl = dlg:getControl(everyItem.oper.clickBtn)
                if everyItem.oper.getClickBtnFunc then
                    -- 如果有获取控件的函数，则优先使用此函数获取的控件
                    local func = everyItem.oper.getClickBtnFunc
                    ctrl = dlg:getControl(dlg[func](self))
                end

                if nil == ctrl then
                    GuideMgr:playNextGuideStep()
                    return
                end

                local ctrlContentSize = ctrl:getContentSize()
                local winPos = ctrl:convertToWorldSpace({x = ctrlContentSize.width / 2, y = ctrlContentSize.height / 2})
                pos.x = winPos.x - ctrlContentSize.width / 2
                pos.y = winPos.y - ctrlContentSize.height / 2
                boxContentSize = ctrlContentSize
            else
                -- 如果没有打开这个界面，跳过
                GuideMgr:playNextGuideStep()
                return
            end

            -- 启动定时器
            GuideMgr:startSchedule()
        elseif GUIDE_TYPE.OPENDLGEX == everyItem.operType then
            -- 一般用于卡界面
            GuideMgr:startSchedule()
            return
        elseif GUIDE_TYPE.TOUCHBTN == everyItem.operType
            or GUIDE_TYPE.TOUCH_LONG_CTRL == everyItem.operType then
            if DlgMgr:isDlgOpened(everyItem.relationDlg) then
                -- 窗口开启，获取控件,并计算点击位置
                local dlg = DlgMgr:getDlgByName(everyItem.relationDlg)
                local ctrl = dlg:getControl(everyItem.oper.clickBtn)
                if nil == ctrl then
                    GuideMgr:playNextGuideStep()
                    return
                end

                local ctrlContentSize = ctrl:getBoundingBox()
                local scaleX = ctrl:getScaleX()
                local scaleY = ctrl:getScaleY()
                local winPos = ctrl:convertToWorldSpace({x = ctrlContentSize.width / 2 / scaleX, y = ctrlContentSize.height / 2 / scaleY})
                pos.x = winPos.x - ctrlContentSize.width / 2
                pos.y = winPos.y - ctrlContentSize.height / 2
                boxContentSize = ctrlContentSize
            else
                -- 如果没有打开这个界面，跳过
                GuideMgr:playNextGuideStep()
                return
            end
        elseif GUIDE_TYPE.TOUCHBTNEX == everyItem.operType then
            if DlgMgr:isDlgOpened(everyItem.relationDlg) then
                local dlg = DlgMgr:openDlg(everyItem.relationDlg)
                local itemBox, tip = dlg:getSelectItemBox(everyItem.oper.clickItem)

                if nil == itemBox then
                    -- 如果没有这个Item，跳过
                    GuideMgr:playNextGuideStep()
                    return
                end

                -- 禁止listView移动
                GuideMgr:setCurGuidListCtrlUnEnable()
                if tip ~= nil then
                    everyItem.tip.content = tip
                end

                pos.x = itemBox.x
                pos.y = itemBox.y
                boxContentSize = {width = itemBox.width, height = itemBox.height}
            else
                GuideMgr:playNextGuideStep()
                return
            end
        elseif GUIDE_TYPE.ADDICON == everyItem.operType then
            if ALL_TAB_ICON_LIST[everyItem.oper] then
                -- 标签开启, 不需要表现，直接开启即可
                table.insert(GuideMgr.tabIcon, everyItem.oper)
                GuideMgr:playNextGuideStep()
                return
            end

            if not GuideMgr:isEffectIcon(everyItem.oper) then
                -- 不需要显示光效
                GuideMgr:addMainIcon(everyItem.oper)
                self:refreshMainIcon(true, GuideMgr.iconList[everyItem.oper].ctrlName)
                GuideMgr:playNextGuideStep()
                return
            end

            -- 处理主界面图标
            if not GuideMgr:isIconExist(everyItem.oper) then
                -- 如果不存在，播放动画
                -- 获取icon，并把它摆到屏幕中央
                local iconInfo = GuideMgr.iconList[everyItem.oper]

                self:refreshMainIcon(true, iconInfo.ctrlName)
                local iconCtrl = self:getMainIconCtrl(everyItem.oper)
                local iconCtrlContentSize = iconCtrl:getContentSize()
                local dlg = DlgMgr:openDlg(iconInfo.dlgName)

                if nil == iconCtrl then
                    -- 如果已经存在这个Icon,则丢弃这个操作
                    GuideMgr:playNextGuideStep()
                    return
                end

                -- 如果配置表中配置了函数func，则调用此函数
                if iconInfo.func then
                    -- 此函数目前用于二级图标（法宝）的指引动画，需要此函数开启相应（打造）界面，并先将对应图标（法宝）隐藏
                    dlg[iconInfo.func](dlg, false)
                end

                -- 播完新功能开启动画的前半部分后的回调函数
                local callBack = function(node)
                    -- 创建主界面动画的图标
                    local newCtrl = iconCtrl:clone()

                    if iconInfo.func then
                        -- func函数可能导致ctrl的ContentSize发生变化，还原ctrl的ContentSize
                        newCtrl:setContentSize(iconCtrlContentSize)
                    end

                    if nil ~= newCtrl:getParent() then
                        newCtrl:removeFromParentAndCleanup(false)
                    end

                    newCtrl:setPosition(Const.WINSIZE.width / 2 / Const.UI_SCALE, Const.WINSIZE.height / 2)
                    newCtrl:setVisible(true)
                    newCtrl:setLocalZOrder(Const.ZORDER_TOPMOST - 1)

                    gf:getUILayer():addChild(newCtrl)

                    -- 获取应该存在的位置
                    -- 存在位置，腾出空间动画
                    local pos = GuideMgr:preAddMainIconCtrl(everyItem.oper)

                    -- runAction
                    local action = nil
                    if nil ~= pos then
                        local func = cc.CallFunc:create(function()

                            -- 如果配置表中有函数，则调用此函数
                            if iconInfo.func then
                                -- 目前用于二级图标（法宝）的指引，需要此函数开启相应二级（打造）界面，并将对应图标（法宝）显示
                                dlg[iconInfo.func](dlg, true)
                            else
                                GuideMgr:refreshMainIcon(true, iconInfo.ctrlName)
                            end

                            newCtrl:removeFromParent()
                            self:getGuideLayer():setVisible(false)
                            GuideMgr:playNextGuideStep()
                        end)

                        local scale1 = cc.ScaleTo:create(0.3, 1.8)
                        local delay = cc.DelayTime:create(0.4)
                        local scale2 = cc.ScaleTo:create(0.2, 1)
                        action = cc.Sequence:create({scale1, scale2, delay, cc.MoveTo:create(0.6, pos), cc.DelayTime:create(0.1), func})
                    end

                    -- 结束刷新主界面
                    if nil ~= action then
                        newCtrl:runAction(action)
                        self:getGuideLayer():setVisible(true)
                        self:getGuideLayer().box = {x = 0, y = 0, width = 0, height = 0}
                        self:getGuideLayer():removeAllChildren(true)
                    end
                end

                local function func(sender, etype, id)
                    if etype == ccs.MovementEventType.complete then
                        if id == "Bottom01" then
                            if (Me:isInCombat() or Me:isLookOn()) then
                                -- WDSY-36551 播放完Bottom01后，Me可能已经在战斗中了，此时需要停止特效，并直接刷新主界面icon
                                sender:stopAllActions()
                                sender:removeFromParent(true)

                                GuideMgr:addMainIcon(everyItem.oper)
                                self:refreshMainIcon(true, GuideMgr.iconList[everyItem.oper].ctrlName)
                            else
                            sender:getAnimation():play("Bottom02")
                            callBack(sender)
                            end
                        else
                            sender:stopAllActions()
                            sender:removeFromParent(true)
                        end
                    end
                end

                -- 创建新功能骨骼动画
                local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.new_function_open.name)
                magic:setAnchorPoint(0.5, 0.5)
                magic:setPosition(Const.WINSIZE.width / 2 / Const.UI_SCALE, Const.WINSIZE.height / 2)
                magic:getAnimation():setMovementEventCallFunc(func)
                magic:getAnimation():play("Bottom01")
                magic:setLocalZOrder(Const.ZORDER_TOPMOST - 1)

                gf:getUILayer():addChild(magic)

                GuideMgr:setClipNodeVisible(true)
            else
                -- 如果已经存在这个Icon,则丢弃这个操作
                GuideMgr:playNextGuideStep()
                return
            end
            return
        elseif GUIDE_TYPE.TOUCHOBJINFIGHT == everyItem.operType then
            -- 点击战斗中的对象
            local itemBox = FightMgr:getFightPosRect(everyItem.oper.pos)
            if nil == itemBox then
                -- 如果没有这个Item，跳过
                GuideMgr:playNextGuideStep()
                return
            end

            pos.x = itemBox.x
            pos.y = itemBox.y
            boxContentSize = {width = itemBox.width, height = itemBox.height}
        elseif GUIDE_TYPE.CLIENT_NOTIFY == everyItem.operType then
            -- 通知对象，需要获取区域了
            -- 不管了，打开再说，不然就卡住了
            local dlg = DlgMgr:getDlgByName(everyItem.relationDlg)
            if dlg then
                self:getGuideLayer():setVisible(true)
                self:getGuideLayer().box = {x = 0, y = 0, width = 0, height = 0}
                self:getGuideLayer():removeAllChildren(true)

                -- 禁止listView移动
                GuideMgr:setCurGuidListCtrlUnEnable()

                -- 通知窗口需要给我一个提示
                dlg:youMustGiveMeOneNotifyEx(everyItem.oper.identify, everyItem.detail)
                return
            else
                -- 如果没有这个窗口，跳过
                GuideMgr:playNextGuideStep()
                return
            end
        end
    end

    -- 添加响应框
    local guideLayer = self:getGuideLayer()
    guideLayer.box = cc.rect(pos.x, pos.y, boxContentSize.width, boxContentSize.height)
    guideLayer:removeAllChildren(true)

    -- gf:showTipInfoByPos(everyItem.tip.content, guideLayer.box,pos)

    -- 添加提示
    self:showTipInfo(everyItem.tip.content, guideLayer.box, everyItem.tip)
    self.guideLayer:setVisible(true)
    GuideMgr:setClipNodeVisible(true)

    -- 添加光效
    local effect = gf:createLoopMagic(ResMgr.magic.guide_magic)
    effect:setPosition((pos.x + boxContentSize.width / 2) / Const.UI_SCALE, (pos.y + boxContentSize.height / 2) / Const.UI_SCALE)
    effect:setAnchorPoint(0.45, 0.55)
    effect:setContentSize(boxContentSize.width, boxContentSize.height)
    effect:setLocalZOrder(Const.ZORDER_TOPMOST)
    effect:setTag(EFFECT_TAG)
    guideLayer:addChild(effect)
    GuideMgr:setClipNodeContent(guideLayer.box)
end

-- 通知管理器,可以开始播放指引了
function GuideMgr:youCanDoIt(dlgName, identify)
    if not GuideMgr:isRunning() then
        Log:D(CHS[3004057])
        return
    end

    local guideItem = self.curItem
    if nil == guideItem then
        GuideMgr:doEndPlayGuide(self.guideId)
        return
    end

    if GUIDE_TYPE.CLIENT_NOTIFY ~= guideItem.operType then
        -- 当前指引不是通知指引
        return
    end

    if dlgName ~= guideItem.relationDlg or not identify or "" == identify then
        -- 如果不是当前窗口,表示为nil
        GuideMgr:playNextGuideStep()
        return
    end

    if not guideItem.detail then
        -- 当前指引配置错误，跳过！
        GuideMgr:playNextGuideStep()
        return
    end

    if guideItem.oper.identify ~= identify or guideItem.relationDlg ~= dlgName then
        -- 标示不对，返回，不播放
        GuideMgr:playNextGuideStep()
        return
    end

    Me:setAct(Const.SA_STAND)

    self.curItem = guideItem.detail
    GuideMgr:playGuideByObj(guideItem.detail)
end

-- 需要按钮回调的事件
function GuideMgr:needCallBack(identify)
    if not GuideMgr:isRunning() then
        return
    end

    if self.curItem and self.curItem.oper and self.curItem.oper.subTypeIdentify == identify then
        GuideMgr:playNextGuideStep()
    end
end

-- 长按事件的回调
function GuideMgr:touchLongCtrl(dlgName, ctrlName)
    -- 禁止listView移动
    if not GuideMgr:isRunning() then
        Log:D(CHS[3004057])
        return
    end

    local guideItem = self.curItem
    if nil == guideItem then
        GuideMgr:unFrozenScreen()
        GuideMgr:doEndPlayGuide(self.guideId)
        return
    end

    if GUIDE_TYPE.TOUCH_LONG_CTRL ~= guideItem.operType
        and (GUIDE_TYPE.CLIENT_NOTIFY ~= guideItem.operType or GUIDE_TYPE.TOUCH_LONG_CTRL ~= guideItem.detail.operType) then
        -- 当前指引不是通知指引
        Log:D(CHS[3004058])
        return
    end

    if GUIDE_TYPE.CLIENT_NOTIFY == guideItem.operType then
        guideItem = guideItem.detail
    end

    if dlgName == guideItem.relationDlg and ctrlName == guideItem.oper.clickBtn then
        GuideMgr:playNextGuideStep()
        Log:D(CHS[3004059])
        return
    end
end

-- 关闭tip
function GuideMgr:closeTipInfo()
    DlgMgr:closeDlg("FloatingFrameDlg")
end

-- 显示tip
function GuideMgr:showTipInfo(str, nodeBox, detail)
    local size = {width = nodeBox.width, height = nodeBox.height}
    local pt = {}
    pt.x, pt.y = nodeBox.x, nodeBox.y
    local parentAnchor = {x = 0, y = 0}
    local MARGIN = 10

    -- 生成背景
    local back = DlgMgr:openDlg("FloatingFrameDlg")
    back:setDialogType(true, false)
    back.blank:setLocalZOrder(Const.ZORDER_TOPMOST + 1)
    back:setText(str, 350)
    back.root:setAnchorPoint(0, 0)

    local direct = directMapping[detail.posType]
    if nil == direct then
        return
    end

    -- 计算需要偏移的量
    back.root:setAnchorPoint(direct[1], direct[2])
    local offAX = direct[3] - parentAnchor.x
    local offAY = direct[4] - parentAnchor.y
    pt.x = (size.width * offAX + pt.x)  / Const.UI_SCALE
    pt.y = (size.height * offAY + pt.y) / Const.UI_SCALE
    if offAX < 0 then
        pt.x = pt.x - MARGIN
    elseif offAX > 0 then
        pt.x = pt.x + MARGIN
    end

    if offAY < 0 then
        pt.y = pt.y - MARGIN
    elseif offAY > 0 then
        pt.y = pt.y + MARGIN
    end

    -- 超出边界时，调整其位置
    back.root:setPosition(pt)
    back.root:ignoreAnchorPointForPosition(false)

    return back
end

-- 播放缩小光效
function GuideMgr:showScaleAnimation(layer, centerX, centerY)
    if self.hasScaleAni then
        return
    end

    self.hasScaleAni = true
    local scaleAni = cc.Sprite:create(ResMgr.ui.guide_click_circle)
    scaleAni:setScale(2.5)
    if centerX == 0 and centerY == 0 then
        scaleAni:setVisible(false)
        self.hasScaleAni = false
    end

    local scaleAct = cc.ScaleTo:create(0.7, 1)
    local func = cc.CallFunc:create(function()
        scaleAni:removeFromParent(true)
        self.hasScaleAni = false
    end)

    local seqAct = cc.Sequence:create(scaleAct, func)
    scaleAni:runAction(seqAct)
    scaleAni:setPosition(centerX / Const.UI_SCALE, centerY / Const.UI_SCALE)

    layer:addChild(scaleAni)

    gf:ShowSmallTips(CHS[3004060])
    local dlg = DlgMgr:getDlgByName("SmallTipDlg")
    if dlg and dlg.root then
    dlg.root:setLocalZOrder(layer:getLocalZOrder() + 1)
    end
end

-- 获取指引层
function GuideMgr:getGuideLayer()
    if nil == self.guideLayer then
        -- 创建layer层
        self.guideLayer = cc.Layer:create()
        self.guideEventLayer = cc.Layer:create()

        -- 添加标签
        self.guideLayer:setTag(Const.TAG_GUIDE_LAYER)

        -- 添加回调函数
        local function onDealTouch(touch, event)
            local eventCode = event:getEventCode()
            local touchPos = touch:getLocation()
            if not self.guideLayer:isVisible() then
                return GuideMgr.state == GUIDE_STATE.PLAYING
            end

            local box = self.guideLayer.box
            if nil == box then
                return GuideMgr.state == GUIDE_STATE.PLAYING
            end

            Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
            if cc.rectContainsPoint(box, touchPos) then
                -- 在区域内，放行,有效区域点击增加时间间隔
                self.lastTime = self.lastTime or 0
                local nowTime = gfGetTickCount()
                if nowTime - self.lastTime > 300 then
                    self.lastTime = nowTime
                    return false
                end

                return true

            else
                GuideMgr:showScaleAnimation(self.guideLayer, box.x + box.width / 2, box.y + box.height / 2)
            end

            return true
        end

        -- 添加事件层的回调处理
        local function onDealEventTouch(touch, event)
            local eventCode = event:getEventCode()

            local touchPos = touch:getLocation()
            if not self.guideLayer then
                return false
            end

            if not self.guideLayer:isVisible() then
                return false
            end

            local box = self.guideLayer.box
            if nil == box then
                return false
            end

            Log:D("Event location : x = %d, y = %d", touchPos.x, touchPos.y)
            if cc.rectContainsPoint(box, touchPos) then
                if eventCode == cc.EventCode.BEGAN then

                    return true
                elseif eventCode == cc.EventCode.ENDED then

                    if GUIDE_TYPE.OPENDLG ~= self.curItem.operType
                       and GUIDE_TYPE.TOUCH_LONG_CTRL ~= self.curItem.operType
                        and GUIDE_TYPE.CLIENT_NOTIFY ~= self.curItem.operType then

                        if GUIDE_TYPE.TOUCHBTNEX == self.curItem.operType
                            and GUIDE_SUB_TYPE.CLOSE_DLG == self.curItem.oper.subType then
                            -- 起定时器判断窗口是否关闭
                            GuideMgr:startSchedule()
                        else
                            if GUIDE_TYPE.TOUCHOBJINFIGHT == self.curItem.operType then
                                -- 需要恢复战斗中的位置
                                FightMgr:reviveFightPosData(self.curItem.oper.pos)
                            end

                            -- 播放下一条
                            if GUIDE_SUB_TYPE.NEED_CALL_BACK ~= self.curItem.oper.subType and self.curItem.operType ~= GUIDE_TYPE.OPENDLGEX then
                                -- 特判点击listview中的item，因为listview是采用单击来判断是否选中，因此如果使用拖拽的方式将会跳过指引
                                if GUIDE_TYPE.TOUCHBTNEX == self.curItem.operType and self.curItem.oper.clickBtn == "" then
                                    local dlg = DlgMgr:getDlgByName(self.curItem.relationDlg)
                                    if dlg and dlg.getSelectItem then
                                        local item = dlg:getSelectItem()
                                        if dlg.selectPanel and cc.rectContainsPoint(dlg:getBoundingBoxInWorldSpace(item), touchPos) then
                                            -- 自动选中指引要求选中的项
                                            dlg:selectPanel(item)
                                        end
                                    end
                                end

                                GuideMgr:playNextGuideStep()
                            end
                        end
                    end

                end

                self.hasScaleAni = false
            else
                local curItem = self.curItem
                if nil == curItem or GUIDE_TYPE.TOUCH_LONG_CTRL ~= self.curItem.operType
                    and (GUIDE_TYPE.CLIENT_NOTIFY ~= curItem.operType
                        or nil == curItem.detail or GUIDE_TYPE.TOUCH_LONG_CTRL ~= curItem.detail.operType) then
                    GuideMgr:showScaleAnimation(self.guideLayer, box.x + box.width / 2, box.y + box.height / 2)
                end
            end
        end

        -- 设置指引层的层级
        self.guideLayer:setLocalZOrder(Const.ZORDER_TOPMOST)
        self.guideEventLayer:setLocalZOrder(Const.ZORDER_TOPMOST)
        self.guideLayer:setGlobalZOrder(Const.ZORDER_TOPMOST)
        self.guideEventLayer:setGlobalZOrder(Const.ZORDER_TOPMOST)

        gf:getUILayer():addChild(self.guideEventLayer)
        gf:getUILayer():addChild(self.guideLayer)

        self.guideLayer:setVisible(false)
        self.guideEventLayer:setVisible(false)

        -- 创建监听事件
        local listener = cc.EventListenerTouchOneByOne:create()

        -- 设置是否需要传递
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onDealTouch, cc.Handler.EVENT_TOUCH_BEGAN)

        local eventListener = cc.EventListenerTouchOneByOne:create()
        eventListener:setSwallowTouches(false)
        eventListener:registerScriptHandler(onDealEventTouch, cc.Handler.EVENT_TOUCH_BEGAN)
        eventListener:registerScriptHandler(onDealEventTouch, cc.Handler.EVENT_TOUCH_ENDED)

        -- 添加监听
        local dispatcher = self.guideLayer:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self.guideLayer)
        self.guideLayer:setAnchorPoint(0, 0)
        self.guideLayer:setPosition(0, 0)

        local eventDispatcher = self.guideEventLayer:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(eventListener, self.guideEventLayer)
        self.guideEventLayer:setAnchorPoint(0, 0)
        self.guideEventLayer:setPosition(0, 0)

        -- 添加灰层
        local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, Const.GUIDE_VISIBLE))
        colorLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
        self.clipNode = cc.ClippingNode:create()
        self.clipNode:setInverted(true)
        gf:getUILayer():addChild(self.clipNode)
        self.clipNode:addChild(colorLayer)
        self.clipNode:setLocalZOrder(Const.ZORDER_TOPMOST - 1)

        local stencil = cc.Sprite:create(ResMgr.ui.guide_light_circle)
        stencil:setScale(0.9)
        stencil:setOpacity(Const.GUIDE_VISIBLE)
        stencil:setLocalZOrder(Const.ZORDER_TOPMOST - 1)
        self.clipNode:setStencil(stencil)
        self.clipNode.stencil = stencil
        gf:getUILayer():addChild(stencil)
    end

    return self.guideLayer
end

-- 显示错误TIP
function GuideMgr:showErrorTip(box)
    gf:ShowSmallTips(string.format(CHS[3004061], box.x, box.y))
    local errorTip = cc.Label:create()
    errorTip:setPosition(Const.WINSIZE.width / 2, 300)
    errorTip:setString(string.format("GuideId : %d, GuideStep : %d, x = %d, y = %d, winsize.width = %d, winsize.height = %d",
                                    self.guideId or 0, self.everyId or 0, box.x, box.y, Const.WINSIZE.width, Const.WINSIZE.height))
    GuideMgr:getGuideLayer():addChild(errorTip)
end

-- 设置遮罩的显示范围
function GuideMgr:setClipNodeContent(box)
    if nil == self.clipNode and nil == self.clipNode.stencil then return end

    local stencil = self.clipNode.stencil
    if box.x < - box.width then
        GuideMgr:showErrorTip(box)
        box.x = box.width
    end
    if box.y < - box.height then
        GuideMgr:showErrorTip(box)
        box.y = box.height
    end
    if box.x > Const.WINSIZE.width then
        GuideMgr:showErrorTip(box)
        box.x = Const.WINSIZE.width - box.width
    end
    if box.y > Const.WINSIZE.height then
        GuideMgr:showErrorTip(box)
        box.x = Const.WINSIZE.height - box.height
    end

    if box.x == 0 and box.y == 0 then
        -- x = -200，这样在屏幕外
        stencil:setPosition(cc.p((box.x - box.width / 2) / Const.UI_SCALE - 200, (box.y - box.height / 2) / Const.UI_SCALE))
    else
        stencil:setPosition(cc.p((box.x + box.width / 2) / Const.UI_SCALE, (box.y + box.height / 2) / Const.UI_SCALE))
    end
end

-- 设置遮罩层是否可见
function GuideMgr:setClipNodeVisible(isVisible)
    if nil == self.clipNode then return end

    self.clipNode.stencil:setVisible(isVisible)
    self.clipNode:setVisible(isVisible)
end

function GuideMgr:getMainIconNo(name)
    for k, v in pairs(self.iconList) do
        if v.name == name then
            return k
        end
    end
end

-- 重新刷新主界面所有图标
function GuideMgr:updateMainIcon(data)
    -- 服务器发送的是十六进制字符串，例如"FFFFFFFFFFFFFFFF"
    -- 前8个字符代表非主界面图标状态的十六进制数
    -- 后8个字符代表主界面图标状态的十六进制数
    local mainIconPara = tonumber("0x" .. string.sub(data.para, 9, 16))
    local mainIconParaEx = tonumber("0x" .. string.sub(data.para, 17, 24))
    local otherIconPara = tonumber("0x" .. string.sub(data.para, 1, 8))

    -- 处理主界面图标
    local iconState = Bitset.new(mainIconPara)
    GuideMgr.visibleIcon = gf:deepCopy(ALL_OPEN_ICON)  -- 可见的系统图标
    for i = 1, 32 do
        if iconState:isSet(i) then
            table.insert(GuideMgr.visibleIcon, i)
        end
    end

    -- 处理主界面图标
    local iconState = Bitset.new(mainIconParaEx)
    for i = 1, 32 do
        if (i + 32) ~= GuideMgr:getMainIconNo(CHS[5200020]) then
            -- 原生客户端不显示 H5 下载图标
            if iconState:isSet(i) then
                table.insert(GuideMgr.visibleIcon, i + 32)
            end
        end
    end

    -- 处理标签页
    local otherIconState = Bitset.new(otherIconPara)
    for i = 1, 32 do
        if otherIconState:isSet(i) then
            if ALL_TAB_ICON_LIST[i + 32] then
                table.insert(GuideMgr.tabIcon, i + 32)
            end
        end
    end

    if GameMgr:IsCrossDist() and DistMgr:checkCrossDistOpenRank() then
        -- 跨服区组中，排行榜不受等级限制
        self:addMainIcon(10)
    end

    GuideMgr:refreshMainIcon()
end

-- 根据指印id获取指引条目
function GuideMgr:getGuideItemById(id)
    if nil == GuideMgr.guideList then
        GuideMgr.guideList = require("cfg/GuideInfo")
    end

    return GuideMgr.guideList[id]
end

-- 设置当前指引的listview
function GuideMgr:addCurGuidListCtrl(dlgName, ctrl)
    if nil == GuideMgr.curGuidListCtrl then
        GuideMgr.curGuidListCtrl = {}
    end

    if nil == GuideMgr.curGuidListCtrl[dlgName] then
        GuideMgr.curGuidListCtrl[dlgName] = {}
    end

    table.insert(GuideMgr.curGuidListCtrl[dlgName], ctrl)

    GuideMgr.listEnable = nil

    Log:D(CHS[3004062] .. tostring(ctrl))
end

-- 将当前指引的listView全部设置为不能移动
function GuideMgr:setCurGuidListCtrlUnEnable()
    if not GuideMgr.listEnable then
        if nil == GuideMgr.curGuidListCtrl then
            GuideMgr.curGuidListCtrl = {}
            return
        end

        for dlgName, ctrlList in pairs(GuideMgr.curGuidListCtrl) do
            for i = 1, #ctrlList do
                local ctrl = ctrlList[i]
                if nil == ctrl.direct then
                    ctrl.direct = ctrl:getDirection()
                end

                ctrl:setDirection(ccui.ListViewDirection.none)
                ctrl:requestDoLayout()
            end

            Log:D(CHS[3004063] .. dlgName .. ", size : " .. #ctrlList)
        end

        GuideMgr.listEnable = true
    end
end

-- 移除当前指引的listView
function GuideMgr:removeCurGuidListCtrl()
    if nil == GuideMgr.curGuidListCtrl then
        GuideMgr.curGuidListCtrl = {}
        return
    end

    for dlgName, _ in pairs(GuideMgr.curGuidListCtrl) do
        self:removeDlgGuidListCtrl(dlgName)
    end

    GuideMgr.listEnable = nil
end

-- 移除当前指引的listView
function GuideMgr:removeDlgGuidListCtrl(dlgName)
    if nil == GuideMgr.curGuidListCtrl
        or nil == dlgName then
        GuideMgr.curGuidListCtrl = {}
        return
    end

    local ctrlList = GuideMgr.curGuidListCtrl[dlgName]
    if nil == ctrlList then
        ctrlList = {}
    end

    for i = 1, #ctrlList do
        local ctrl = ctrlList[i]
        if nil ~= ctrl.direct then
            ctrl.direct = nil
        end
    end

    Log:D(CHS[3004064] .. dlgName .. ", size : " .. #GuideMgr.curGuidListCtrl[dlgName])

    GuideMgr.curGuidListCtrl[dlgName] = {}
end

-- 获取当前指引ID
function GuideMgr:getCurGuidId()
    return self.guideId
end

function GuideMgr:getNextGiftEquipByIndex(equipIndex)
    local equip = nil
    local next = equipIndex
    local times = 0
    while not equip and times < self.equipList.count do
        times = times + 1
        next = next + 1
        if next > self.equipList.count then next = 1 end
        equip = InventoryMgr:getItemById(self.equipList[next].equipId)
    end

    return equip.pos
end

-- 获取当前新手礼包装备ID
function GuideMgr:MSG_GIFT_EQUIP_LIST(data)
    DlgMgr:sendMsg("BagDlg", "setCleanGuideEquip", false)
    self.equipList = {}
    for i = 1, data.count do
        -- 通过ID获取武器
        local equip = InventoryMgr:getItemById(data.equipId[i])
        if equip.equip_type == EQUIP_TYPE.WEAPON then
            table.insert(self.equipList, {equipId = equip.item_unique, order = 1})
        elseif equip.equip_type == EQUIP_TYPE.HELMET then
            table.insert(self.equipList, {equipId = equip.item_unique, order = 2})
        elseif equip.equip_type == EQUIP_TYPE.ARMOR then
            table.insert(self.equipList, {equipId = equip.item_unique, order = 3})
        elseif equip.equip_type == EQUIP_TYPE.BOOT then
            table.insert(self.equipList, {equipId = equip.item_unique, order = 4})
        else
            table.insert(self.equipList, {equipId = equip.item_unique, order = 5})
        end
    end

    table.sort(self.equipList, function(l, r)
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    self.equipList.count = data.count
end

function GuideMgr:MSG_PLAY_INSTRUCTION(data)
    -- 一些特殊的小游戏进行中，若指引，则直接返回结束
    if DlgMgr:getDlgByName("VacationPersimmonDlg") then
        -- 如果冻柿子游戏进行中
        gf:CmdToServer("CMD_DONGSZ_2018_QUIT", {})
        gf:CmdToServer("CMD_DONGSZ_2018_REQUEST_END_POS", {})
    elseif DlgMgr:getDlgByName("VacationSnowDlg") then
        gf:CmdToServer("CMD_WINTER2018_DAXZ_QUIT_GAME")
    end

    -- 编号75指引指播放光效
    if data.guideId == 75 then
        DlgMgr:sendMsg("GameFunctionDlg", "onHomeManageButton")
        DlgMgr:sendMsg("GameFunctionDlg", "addEffectByButtonName", "FishButton")
        return
    elseif data.guideId == 76 then
        DlgMgr:sendMsg("GameFunctionDlg", "onHomeManageButton")
        DlgMgr:sendMsg("GameFunctionDlg", "addEffectByButtonName", "PlantButton")
        return
    elseif data.guideId == 80 then
        DlgMgr:sendMsg("GameFunctionDlg", "onHomeManageButton")
        DlgMgr:sendMsg("GameFunctionDlg", "addEffectByButtonName", "KidButton")
        DlgMgr:sendMsg("GameFunctionDlg", "setCtrlVisible", "ChildTipsPanel", true)
        return
    elseif data.guideId == 77 then
        if not CommunityMgr:needCommunityGuide() then return end

        -- 微社区指引
        DlgMgr:sendMsg("GameFunctionDlg", "doCommunityGuide")
        return
    end

    -- 播放指引的时候关闭部分便捷使用框
    local toCloseGuideId = {
        [30] = 1,[31] = 1,
    }

    if toCloseGuideId[data.guideId] then
        DlgMgr:closeFastUseDlg()
    end

    -- 指引完成界面存在，则关闭
    AchievementMgr:stopAutoComp()
    DlgMgr:closeDlg("AchievementCompleteDlg")

    -- 还是第二帧开始播放指引吧...
    local layer = gf:getUILayer()
    local func = cc.CallFunc:create(function()
        GuideMgr:removeCurGuidListCtrl()
        GuideMgr:playGuideById(data.guideId, 1)
    end)

    layer:runAction(func)
    gf:frozenScreen(0.6, 0)
end

-- 初始化
GuideMgr:init()

MessageMgr:regist("MSG_PLAY_INSTRUCTION", GuideMgr)
MessageMgr:regist("MSG_GIFT_EQUIP_LIST", GuideMgr)
