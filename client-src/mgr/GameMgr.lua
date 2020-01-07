-- GameMgr.lua
-- Created by chenyq Nov/13/2014
-- 负责管理游戏相关逻辑

GameMgr = Singleton()

local CLIENT_ACTIVE   = 1  -- 激活状态
local CLIENT_SILENT   = 2  -- 激活了，但很长一段时间没输入了
local CLIENT_INACTIVE = 3  -- 未激活状态

-- 3 分钟内没有触屏则设置为 CLIENT_SILENT 状态
local SILENT_MAX_INTERVAL = 180 * 1000

-- 10分钟没进入游戏断开gs
local connect_gs_time = 10

-- 10分钟内没激活将设置成登录界面
local OFFLINE_MAX_INTERVAL = 5 * 60

-- MSG_OPEN_EXCHANGE_SHOP data.type对应打开类型
local EXCHANGE_SHOP_TYPE = {
    SKILL = 0,
    PET = 1,
    NICE = 2,
    WANG_ZHONG_WANG = 4,
    JUNGONG = 5,
}

local DISCONNECT_MAX_INTERVAL = 90 * 1000

-- 登录后继续寻路
local KEEP_AUTOWALK_WHEN_LOGINDONE = nil

-- 进入后台后自动断线重连的时间
local DISCONNECT_TIME_BACKGROUND = 30

local MARGIN_LEFT = 11
local MARGIN_RIGHT = 15

local NeedUpAndDownActionUI =
    {
        ["SystemFunctionDlg"] =
        {
            "SmallMapButton",
            "LiangongButton",
            "ShuadaoButton",
            "ActivityButton",
            "GoodVoiceButton",
            "QQButton",
            "AnniversaryButton",
            "PromoteButton",
            -- "DistPanel",
        }
    }

local NeedLeftAndRightActionUI =
    {
        ["SystemFunctionDlg"] =
        {
            "RankingListButton",
            "ShengSiButton",
            "MallButton",
            "TradeButton",
            "GiftsButton",
            "StatusButton1",
            "StatusButton2"
        }
    }

local AutoTouchButtonUI = {
    ["MissionDlg"] = {["Hide"] = "HideDialogButton", ["Show"] = "ShowDialogButton"},
    ["GameFunctionDlg"] = {["Hide"] = "HideButton", ["Show"] = "ShowButton"},
}

local ALL_LAYER_UI = {
    ["HeadDlg"] = cc.p(0, 84),
    ["ChatDlg"] = cc.p(0, -295 - 30 - 56 - 20), -- 聊天框高度 + 图标高度 + 喇叭文字纯数字时的高度 + 聊天框扩大时的高度 + 机型适配最大安全区高度
}

-- 存在适pei的滑动控件
local SUIT_LAYER_UI = {
    ["AnnouncementDlg"] = cc.p(0, 160),
}

local NeedRightAndLeftActionUI = {
    ["GameFunctionDlg"] = {"BagButton", "HomeManageButton"}
}

local NPC_SOUND_LIST = require('cfg/NpcList')

-- 至少滑动距离
local LIMIT_LESS_DISTANCE = 30
local ACTION_DURING_TIME = 0.2

-- 存储一些玩家点击的点，以便进行一些特殊的判断
-- 暂时存储 4 点用于判断是否显示 fps 信息
local SAVE_TOUCH_POS_MAX_NUM = 4

-- 长按时间
local LONG_PRESS_TIME = 0.3

GameMgr.initDataDone = false
GameMgr.isFirstLoginToday = false
GameMgr.LastEnterBackGroundTimeStamp = os.time()
GameMgr.isFirstMutiTouchMove = true
GameMgr.beforeCombatUIState = MAIN_UI_STATE.STATE_SHOW
GameMgr.isIOSReview = false
GameMgr.isEnterGameByLoginScene = false

local shidaoServerList ={} -- 试道专线线路
local curServerId = 0 -- 当前线路的信息

local checkServerCookie = 0

-- 性能统计相关开始
local tcost = {}

function GameMgr:addCost(name, t)
    if not tcost[name] then tcost[name] = {} end
    local tc = tcost[name].tc or 0
    local tt = tcost[name].tt or 0
    tc = tc + t
    tt = tt + 1
    local tmax = tcost[name].tmax or 0
    local tmin = tcost[name].tmin or 0xFFFFFF
    tcost[name] = {tc = tc, tt = tt, tn = t, tmax = math.max(t, tmax), tmin = math.min(t, tmin) }
end

function GameMgr:resetCost(name)
    if name then
        tcost[name] = nil
    else
        tcost = {}
    end
end

function GameMgr:showCost()
    local t = {}
    for k, v in pairs(tcost) do
        table.insert(t, string.format("%s:%.2f, %d, %d, %d, %d", k, v.tc / v.tt, v.tn, v.tmax, v.tmin, v.tt))
    end
    local label = self:getCostText()
    local str = table.concat(t, '\n')
    label:setString(str)
end

function GameMgr:getCostText()
    if not self.costLabel then
        self.costLabel = ccui.Text:create()
        self.costLabel:setFontSize(21)
        self.costLabel:setColor(cc.c3b(255, 0, 0))
        self.costLabel:setAnchorPoint(0, 0)
        self.costLabel:setTextAreaSize(self.scene:getContentSize())
        self.costLabel:setContentSize(self.scene:getContentSize())
        self.scene:addChild(self.costLabel)

        local NODE_EXIT = Const.NODE_EXIT
        local function onNodeEvent(event)
            if NODE_EXIT == event then
                self.costLabel = nil
            end
        end

        self.costLabel:registerScriptHandler(onNodeEvent)
    end

    return self.costLabel
end

-- 获取双手滑动的偏移
function GameMgr:getOffsetPos(dlgName)
    local pos = gf:deepCopy(SUIT_LAYER_UI[dlgName])
    if pos then
        pos.x = pos.x / Const.UI_SCALE
        pos.y = pos.y / Const.UI_SCALE
        return pos
    end

    return ALL_LAYER_UI[dlgName]
end

-- 更新最后一次点击时间
function GameMgr:updateLastTouchTime()
    self.lastTouchTime = gfGetTickCount()
end

function GameMgr:init()
    ---- todo 暂时从 UserDefault 中获取
    local userDefault = cc.UserDefault:getInstance()
   -- self.aaa = userDefault:getStringForKey("aaa", "117.121.4.183:7701")
    local lastInfo = userDefault:getStringForKey("lastLoginDist", "patch_pack_test")
    if lastInfo == "patch_pack_test" then
        -- DistMgr.defaultInfo中DistMgr还未加载
        local defDist = GameMgr:getDefDist()
        if defDist and defDist["default"] and defDist["default"]["dist"] then
            lastInfo = defDist["default"]["dist"]
        end
    end

    self.dist = gf:split(lastInfo, ",")[1]
    local isGm = userDefault:getIntegerForKey("gm", 0)
  --  GameMgr.normalLogin = ((string.len(self.aaa) > 0) and isGm == 0)

    -- 是否处于战斗中
    self:setInCombat(false)

    -- 是否处于老君查岗中
    self.isAntiCheat = false

    -- 记录最近一次的 touch 时间
    self:updateLastTouchTime()

    -- 客户端是否处于激活状态
    DebugMgr:checkClientStatus() -- WDSY-27195
    self.clientStatus = CLIENT_ACTIVE

    -- 有些对象会有往 uiLayer 添加子节点的需求
    -- 当 uiLayer 清除所有子节点时需要通知这些对象，让他有机会做一些清理的工作
    -- 将这些对象记录在这张表中，清除所有子节点时会调用这些对象的 doWhenUiLayerRemoveAllChild 方法
    self.uiLayerUsers = {}

    -- 存储一些玩家点击的点，以便进行一些特殊的判断
    self.touchPosList = {}
    self.touchPosIdx = 1

    -- 延迟检测连接的时间，默认不延迟
    self.delayCheckConnectionTime = 0

    -- 创建顶级层
    self:createTopLayers()
    self.updateId = gf:Schedule(function()
        GameMgr:update()
    end, 0)

    self.isMove = false
    self.curMainUIState = MAIN_UI_STATE.STATE_SHOW
    self.beforeCombatUIState = MAIN_UI_STATE.STATE_SHOW
    self.newDistance = 0
    self.oldDistance = 0
    self.missionDlgHide = false

    if not self.clientTimeZone then
        -- 初始化时区信息
        self.clientTimeZone = gf:getClientTimeZone()
        self.serverTimeZone = self.clientTimeZone
    end

    -- 加载敏感词
    if "table" == type(GFiltrateMgr)
        and "function" == type(GFiltrateMgr.Instance) then
        Log:I(">>>> now load ban words.")

        -- 如果存在这个函数，就进行设置加载
        GFiltrateMgr:Instance():ReadIgnoreWords("cfg/IgnoreBanWords.list")
        if "410001" == DeviceMgr:getChannelNO() then
            GFiltrateMgr:Instance():Init("cfg/ban_words_overseas.list")
        else
        GFiltrateMgr:Instance():Init("cfg/ban_words.list")
    end
    end
end

-- 获取区组配置信息
function GameMgr:getDefDist()
    if self.distCfg then
        return self.distCfg
    end

    local desc = nil
    local ok = pcall(function ()
        desc = dofile(cc.FileUtils:getInstance():getWritablePath() .. 'patch/dist.lua')
    end)

    self.distCfg = desc
    return desc
end

-- 根据 dist.lua 的 default 配置中 disable_yayaim 配置判断
function GameMgr:isYayaImEnabled()
    local distInfo = GameMgr:getDefDist()
    if distInfo and distInfo.default then
        return not distInfo.default["disable_yayaim"]
    end

    -- 默认开启
    return true
end


-- 根据 dist.lua 的 default 配置中 disable_custom_service 配置判断是否可联系客服
function GameMgr:isServiceEnabled()
    local distInfo = GameMgr:getDefDist()
    if distInfo and distInfo.default then
        return not distInfo.default["disable_custom_service"]
    end

    -- 默认可以联系客服
    return true
end

-- 取消Game的update
function GameMgr:stopUpdate()
    if self.updateId then
    gf:Unschedule(self.updateId)
    self.updateId = nil
    end
end

-- 设置登录后继续寻路
function GameMgr:keepAutoWalkWhenLoginDone(state)
    KEEP_AUTOWALK_WHEN_LOGINDONE = state
end

function GameMgr:isAutoWalkWhenLoginDone()
    return KEEP_AUTOWALK_WHEN_LOGINDONE
end

-- 设置游戏运行状态
function GameMgr:setGameState(state)
    if nil == state then return end

    GameMgr.runtimeState = state
end

-- 获取游戏运行状态
function GameMgr:getGameState()
    return GameMgr.runtimeState
end

function GameMgr:getLongPressTime()
    return LONG_PRESS_TIME
end

-- 创建多点触控响应层
function GameMgr:createMutiTouchLayer(layer)
    local touchPanel = layer

    if not touchPanel then
        return
    end

    local function onTouchesBegan(touches, eventType)
        return true
    end

    local function onTouchesMoved(touches, eventType)
        if not Me:isInCombat() and not GuideMgr:isRunning() then
        if #touches >= 2 then
            local pos1 = touches[1]:getLocation()
            local pos2 = touches[2]:getLocation()

            if self.isFirstMutiTouchMove then
                self.oldDistance = cc.pGetDistance(pos1, pos2)
                self.isFirstMutiTouchMove = false
            else
                self.newDistance = cc.pGetDistance(pos1, pos2)
            end

            Me.isMoved = false
        end
       end
    end

    local function onTouchesEnd(touches, eventType)
        if not Me:isInCombat() and not GuideMgr:isRunning() and not MapMgr:isInDragMap() then
            if self.newDistance ~= 0 and self.oldDistance ~= 0 then
                if self.newDistance - self.oldDistance > 0 then
                    -- 隐藏所有界面
                    if self.curMainUIState ~= MAIN_UI_STATE.STATE_HIDE then
                        if self:hideAllUI() then
                            local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
                            Me:setEndPos(mapX, mapY)
                    end
                    end
                else
                    -- 显示所有界面
                    if self.curMainUIState ~= MAIN_UI_STATE.STATE_SHOW then
                        if self:showAllUI() then
                            local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
                            Me:setEndPos(mapX, mapY)
                        end
                     end
                end
                Me.isMoved = false
            end
        end

        if not self.isFirstMutiTouchMove then
            self.newDistance = 0
            self.oldDistance = 0
            self.isFirstMutiTouchMove = true
        end
    end

    self.multiTouchListener = cc.EventListenerTouchAllAtOnce:create()
    self.multiTouchListener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN )
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_ENDED )
    self.multiTouchListener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = touchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.multiTouchListener, touchPanel)
end


-- 显示UI
function GameMgr:showAllUI(duringTime)
    if self.curMainUIState == MAIN_UI_STATE.STATE_SHOW or ActivityMgr:isChantingStauts() then return end
    if not duringTime then duringTime =  ACTION_DURING_TIME end
    if self.isMove and duringTime ~= 0 then return end

    self.isMove = true
    self.curMainUIState = MAIN_UI_STATE.STATE_SHOW

    local deviceCfg = DeviceMgr:getUIScale()
    if deviceCfg then
        DlgMgr:sendMsg(deviceCfg.fullback, "setVisible", true)
    end

    -- 显示任务和下方按钮
    for k, dlgName in pairs(AutoTouchButtonUI) do
        local buttonName = dlgName["Show"]
        local dlg = DlgMgr:getDlgByName(k)

        if dlg then
            if k == "MissionDlg" and dlg.lastState then
                if dlg.lastState == 1 then
                    dlg:onShowButton()
                else
                    dlg:onHideButton()
                end
            else
                dlg:onShowButton()
            end

        end
    end

    -- 上方按钮显示
    for k, buttons in pairs(NeedUpAndDownActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        for _, btnName in pairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            local size = button:getContentSize()
            if duringTime == 0 then
                local posX, posY = button:getPosition()
                button:setPosition(posX, posY - size.height * 1.5)
            else
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(0, -(size.height * 1.5))), cc.CallFunc:create(function()
                    end))
                button:runAction(action)
            end
        end
    end

    -- 显示左侧按钮
    for k, buttons in pairs(NeedLeftAndRightActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        for _, btnName in pairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            if button.lastVisible then
                button:setVisible(button.lastVisible)
            end
            local size = button:getContentSize()
            if duringTime == 0 then
                local posX, posY = button:getPosition()
                button:setPosition(posX + size.width + MARGIN_LEFT, posY)
            else
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(size.width + MARGIN_LEFT, 0)), cc.CallFunc:create(function()
                end))
                button:runAction(action)
            end
        end
    end

    -- 显示右侧按钮
    for k, buttons in pairs(NeedRightAndLeftActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        DlgMgr:sendMsg(k, "onShowAllUI")

        for i, btnName in ipairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            if button.lastVisible then
                button:setVisible(button.lastVisible)
            end
            local size = button:getContentSize()
            if duringTime == 0 then
                local posX, posY = button:getPosition()
                button:setPosition(posX - size.width * i - MARGIN_RIGHT * (i - 1), posY)
                local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
                dlg:setCtrlVisible("ShowAllUIButton", false)
            else
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(-size.width * i - MARGIN_RIGHT * (i - 1), 0)), cc.CallFunc:create(function()
                    local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
                    dlg:setCtrlVisible("ShowAllUIButton", false)
                end))
                button:runAction(action)
            end
        end
    end

    -- 头像和聊天
    for dlgName, pos in pairs(ALL_LAYER_UI) do
        local dlg = DlgMgr:getDlgByName(dlgName)

        if dlg then
            if duringTime == 0 then
                local posX, posY = dlg.root:getPosition()
                dlg.root:setPosition(posX + pos.x, posY - pos.y)
            else
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(pos.x, -pos.y)), cc.CallFunc:create(function()
                    end))
                dlg.root:runAction(action)
            end
        end
    end

    for dlgName, pos in pairs(SUIT_LAYER_UI) do
        local dlg = DlgMgr:getDlgByName(dlgName)

        if dlg then
            if duringTime == 0 then
                local posX, posY = dlg.root:getPosition()
                dlg.root:setPosition(posX + pos.x / Const.UI_SCALE, posY - pos.y / Const.UI_SCALE)
            else
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(pos.x / Const.UI_SCALE, -pos.y / Const.UI_SCALE)), cc.CallFunc:create(function()
                    end))
                dlg.root:runAction(action)
            end
        end
    end

    self.newDistance = 0
    self.oldDistance = 0
    self.isFirstMutiTouchMove = true

    local uiLayer = gf:getUILayer()
    if uiLayer then
        uiLayer:stopAction(self.OperAllUIAction)
    end

    if duringTime == 0 then
        self.isMove = false
    elseif uiLayer then
        self.OperAllUIAction = performWithDelay(uiLayer, function()
            self.isMove = false
        end, duringTime)
    end

    return true
end

function GameMgr:isHideAllUI()
    if self.curMainUIState == MAIN_UI_STATE.STATE_HIDE then
        return true
    end

    return false
end

function GameMgr:mainUIIsMoving()
    return self.isMove
end

function GameMgr:hideAllUI(duringTime)
    if self.curMainUIState == MAIN_UI_STATE.STATE_HIDE then return end
    if self.isMove and duringTime ~= 0 then return end
    if not duringTime then duringTime =  ACTION_DURING_TIME end

    self.isMove = true
    self.curMainUIState = MAIN_UI_STATE.STATE_HIDE

    local deviceCfg = DeviceMgr:getUIScale()
    if deviceCfg then
        DlgMgr:sendMsg(deviceCfg.fullback, "setVisible", false)
    end

    -- 隐藏任务和下方按钮
    for k, dlgName in pairs(AutoTouchButtonUI) do
        local buttonName = dlgName["Hide"]
        local dlg = DlgMgr:getDlgByName(k)

        if dlg then
            if k == "MissionDlg" then
                -- 任务界面隐藏时我们要保存下，当前状态
                self.missionDlgHide = dlg.isHide
            end

            dlg:onHideButton()
        end
    end

    -- 上方按钮隐藏
    for k, buttons in pairs(NeedUpAndDownActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        for _, btnName in pairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            local size = button:getContentSize()
            dlg:resetRootPos()
            local posX, posY = button:getPosition()
            self[k .. btnName .. "btnPos"] = self[k .. btnName .. "btnPos"] or {x = posX, y = posY}

            if duringTime == 0 then
                button:stopAllActions()
                button:setPosition(self[k .. btnName .. "btnPos"].x + 0, self[k .. btnName .. "btnPos"].y + size.height * 1.5)
            else
                self[k .. btnName .. "btnPos"] = {x = posX, y = posY}
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(0, size.height * 1.5)), cc.CallFunc:create(function()
                    end))
                button:runAction(action)
            end
        end
    end

    -- 隐藏左侧按钮
    for k, buttons in pairs(NeedLeftAndRightActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        for _, btnName in pairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            local size = button:getContentSize()
            dlg:resetRootPos()
            local posX, posY = button:getPosition()
            self[k .. btnName .. "btnPos"] = self[k .. btnName .. "btnPos"] or {x = posX, y = posY}
            if duringTime == 0 then
                button:stopAllActions()
                button:setPosition(self[k .. btnName .. "btnPos"].x + size.width * - 1 - MARGIN_LEFT, self[k .. btnName .. "btnPos"].y)
                button.lastVisible = button:isVisible()
                button:setVisible(false)
            else
                self[k .. btnName .. "btnPos"] = {x = posX, y = posY}
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(size.width * - 1 - MARGIN_LEFT, 0)), cc.CallFunc:create(function()
                    button.lastVisible = button:isVisible()
                    button:setVisible(false)
                    end))
                button:runAction(action)
            end
        end
    end

    -- 隐藏右侧按钮
    for k, buttons in pairs(NeedRightAndLeftActionUI) do
        local dlg = DlgMgr:getDlgByName(k)

        if not dlg then
            break
        end

        DlgMgr:sendMsg(k, "onHideAllUI")

        for i, btnName in ipairs(buttons) do
            local button = dlg:getControl(btnName, Const.UIButton)
            local size = button:getContentSize()
            dlg:resetRootPos()
            local posX, posY = button:getPosition()
            self[k .. btnName .. "btnPos"] = self[k .. btnName .. "btnPos"] or {x = posX, y = posY}
            if duringTime == 0 then
                button:stopAllActions()
                button:setPosition(self[k .. btnName .. "btnPos"].x + size.width * i + MARGIN_RIGHT * (i - 1), self[k .. btnName .. "btnPos"].y)
                button.lastVisible = button:isVisible()
                button:setVisible(false)
            else
                self[k .. btnName .. "btnPos"] = {x = posX, y = posY}
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(size.width * i + MARGIN_RIGHT * (i - 1), 0)), cc.CallFunc:create(function()
                    button.lastVisible = button:isVisible()
                    button:setVisible(false)
                    local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
                    dlg:setCtrlVisible("ShowAllUIButton", true)
                    local gameFuncDlg = DlgMgr:getDlgByName("GameFunctionDlg")
                    gameFuncDlg:setCtrlVisible("ShowButton", false)
                end))
                button:runAction(action)
            end
        end
    end

    -- 头像和聊天
    for dlgName, pos in pairs(ALL_LAYER_UI) do
        local dlg = DlgMgr:getDlgByName(dlgName)

        if dlg then
            dlg:resetRootPos()
            local posX, posY = dlg.root:getPosition()
            self[dlgName .. "dlgPos"] = self[dlgName .. "dlgPos"] or {x = posX, y = posY}
            if duringTime == 0 then
                dlg.root:stopAllActions()
                dlg.root:setPosition(self[dlgName .. "dlgPos"].x + pos.x, self[dlgName .. "dlgPos"].y + pos.y)
            else
                self[dlgName .. "dlgPos"] = {x = posX, y = posY}
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, pos), cc.CallFunc:create(function()
                    dlg.curState = MAIN_UI_STATE.STATE_HIDE
                end))
                dlg.root:runAction(action)
            end
        end
    end

    for dlgName, pos in pairs(SUIT_LAYER_UI) do
        local dlg = DlgMgr:getDlgByName(dlgName)

        if dlg then
            dlg:resetRootPos()
            local posX, posY = dlg.root:getPosition()
            self[dlgName .. "dlgPos"] = self[dlgName .. "dlgPos"] or {x = posX, y = posY}
            if duringTime == 0 then
                dlg.root:stopAllActions()
                dlg.root:setPosition(self[dlgName .. "dlgPos"].x + pos.x / Const.UI_SCALE, self[dlgName .. "dlgPos"].y + pos.y / Const.UI_SCALE)
            else
                self[dlgName .. "dlgPos"] = {x = posX, y = posY}
                local action = cc.Sequence:create(cc.MoveBy:create(duringTime, cc.p(pos.x / Const.UI_SCALE, pos.y / Const.UI_SCALE)), cc.CallFunc:create(function()
                    dlg.curState = MAIN_UI_STATE.STATE_HIDE
                end))
                dlg.root:runAction(action)
            end
        end
    end

    self.newDistance = 0
    self.oldDistance = 0
    self.isFirstMutiTouchMove = true

    local uiLayer = gf:getUILayer()
    if uiLayer then
        uiLayer:stopAction(self.OperAllUIAction)
    end

    if duringTime == 0 then
        self.isMove = false
        local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
        if dlg then
            dlg:setCtrlVisible("ShowAllUIButton", true)
            dlg:setCtrlVisible("ShowButton", false)
        end
    elseif uiLayer then
        self.OperAllUIAction = performWithDelay(uiLayer, function()
            self.isMove = false
        end, duringTime)
    end

    -- 关闭交易界面
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        if dlg:getOpenTradeStatus() then
            dlg:onTradeButton()
        end
    end

    return true
end

function GameMgr:getTouchDirection(beginPos, curPos)

    local isXDirection = false

    -- 先判断x,y哪个方向的偏移量更大,亦可求(curPos - beiginPos)向量的方向
    local xDistance = math.abs(curPos.x - beginPos.x)
    local yDistance = math.abs(curPos.y - beginPos.y)

    if xDistance >= yDistance then
        isXDirection = true
    else
        isXDirection = false
    end

    if isXDirection then
        if beginPos.x > curPos.x and xDistance >= LIMIT_LESS_DISTANCE then
            return MUTITOUCH_DIRECTION.RIGHT
        elseif beginPos.x < curPos.x and xDistance >= LIMIT_LESS_DISTANCE then
            return MUTITOUCH_DIRECTION.LEFT
        else
            return MUTITOUCH_DIRECTION.NO_DIRECTION
        end
    else
        if beginPos.y > curPos.y and yDistance >= LIMIT_LESS_DISTANCE then
            return MUTITOUCH_DIRECTION.DOWN
        elseif beginPos.y < curPos.y and yDistance >= LIMIT_LESS_DISTANCE then
            return MUTITOUCH_DIRECTION.UP
        else
            return MUTITOUCH_DIRECTION.NO_DIRECTION
        end
    end

end

-- 在 isRefreshUserData 为 true 时需要注意当前执行的消息是否需要清除 MessageMgr.recvEndCombatMark 标记
function GameMgr:clearData(isLoginOrSwithLine, isRefreshUserData)
    PracticeMgr:cleanData()
    AutoWalkMgr:cleanup()
    MapMgr:clearData(isRefreshUserData)
    PromoteMgr:clearData(isLoginOrSwithLine)
    PartyWarMgr:clear()
    if isRefreshUserData then
        -- 注意当前执行的消息是否需要清除 MessageMgr.recvEndCombatMark 标记
        GameMgr:onEndCombat()
    else
        FightMgr:cleanup()
    end

    TttSmfjMgr:cleanup()
    FightMgr:cleanupDataLogin()
    SkillMgr:clearData()
    PetMgr:clearData()
    GuardMgr:clearData()
    InventoryMgr:clearData()
    CharMgr:clearAllChar()
    PlayActionsMgr:clearAllAnimates()
    YuanXiaoMgr:clearData()
    HomeMgr:clearData()
    DroppedItemMgr:clearAllItems()
    FriendMgr:clearData(isLoginOrSwithLine)
    MasterMgr:clearData()

    WatchRecordMgr:cleanData()
    DlgMgr:cleanup(isLoginOrSwithLine)
    RankMgr:clearData(isLoginOrSwithLine)
    CommunityMgr:clearData()
    ShareMgr:clearData()
    HomeChildMgr:cleanData()

    if not isLoginOrSwithLine then
        RedDotMgr:cleanup()
        MarketMgr:cleanData()
        Me:clearData()
        ChatMgr:clearData()
        UsefulWordsMgr:clearData()
        RecordLogMgr:cleanup()
        GiftMgr:clearWuxGuessData()
        GiftMgr:releaseStartWux()
        GiftMgr:resetFirstOpenWelfareDlgFlag()
        ArenaMgr:cleanData()
        KuafjjMgr:clearData()
        FightMgr:clearFastSkillData()
        TradingMgr:clearData()
        ChatDecorateMgr:clearData()

        BlogMgr:cleanupCircle()
        PuttingItemMgr:clearData()
        PetExploreTeamMgr:clearData()
    end

    TaskMgr:cleanup(isLoginOrSwithLine)
    TeamMgr:clearData(isLoginOrSwithLine)
    GuideMgr:closeData()
    BattleSimulatorMgr:cleanup()
    AutoFightMgr:clearData()
    PartyMgr:clearData(isLoginOrSwithLine)
    MapMagicMgr:clearData()
    AnimationMgr:cleanup()
    FightMgr:clearData()
    StoreMgr:cleanup()
    ShaderMgr:releaseAllShader()
    GetTaoMgr:cleanup()
    Client:cleanData()
    SystemMessageMgr:clearData(isLoginOrSwithLine)
    OnlineMallMgr:clearData(isLoginOrSwithLine)
    MarryMgr:cleanData()
    PKDataMgr:clearData()
    SummerSncgMgr:clearData()
    CitySocialMgr:clearData(isLoginOrSwithLine)
    WeatherMgr:clearData()
    ActivityMgr:clearData()
    WeddingBookMgr:clearData()
    JiebaiMgr:clearData(isLoginOrSwithLine)
    InnMgr:clearData()
    WatchCenterMgr:clearData(isLoginOrSwithLine)
    TanAnMgr:clearData(isLoginOrSwithLine)
    LingyzmMgr:clearData()
    SpringFestivalAnimateMgr:clearData()
    FightCommanderCmdMgr:clearData()
    ActivityHelperMgr:clearData()

    MiGongMapMgr:clearData()

    WenQuanMgr:clearData()

    -- 清除数据事件
    EventDispatcher:dispatchEvent("clearGameData")

    self.beforeCombatUIState = MAIN_UI_STATE.STATE_SHOW
    self.distCfg = nil
    self.initDataDone = false
    self.isEnterGame = false
    self.isAntiCheat = false

    if self.checkServerAction and self.scene then
        self.scene:stopAction(self.checkServerAction)
    end
    self.checkServerAction = nil

    if self.delayProcessComm then
        MessageMgr.isInBackground = false
    end
    self.delayProcessComm = nil
    self.isRefreshUserData = nil
    self.canRefreshUserData = nil
    self.isYoungPersonLimit = nil
    DistMgr.notClearChat = false
    self:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)
    GiftMgr:cleanData(isLoginOrSwithLine)
    AnniversaryMgr:cleanData(isLoginOrSwithLine)

    -- 停止更新电池、wifi状态
    BatteryAndWifiMgr:stopUpdateBattery()
    BatteryAndWifiMgr:stopUpdateWifi()

    DataBaseMgr:close()
    GameMgr:clearServer()

    -- 清除安全锁的相关数据
    SafeLockMgr:clearLastRelaseEvent()

    -- 清除状态相关数据
    StateMgr:cleanup()
end

function GameMgr:start()
    local director = cc.Director:getInstance()

    -- 随机数种子
    math.randomseed(os.time())

    -- 设置相应常量
    Const.WINSIZE = director:getWinSize()
    Const.INTERVAL = director:getAnimationInterval()
    Log:D("Visible size : %d, %d", Const.WINSIZE.width, Const.WINSIZE.height)

    if Const.WINSIZE.width < Const.UI_DESIGN_WIDTH or Const.WINSIZE.height < Const.UI_DESIGN_HEIGHT then
        -- 为了保证 UI 能够显示下，需要进行放缩 UI 层
        -- 注意：此处一定要设置锚点为 (0, 0)，否则界面对其会发生错误
        local scaleW = 1
        if Const.WINSIZE.width < Const.UI_DESIGN_WIDTH then
            scaleW = Const.WINSIZE.width / Const.UI_DESIGN_WIDTH
        end

        local scaleH = 1
        if Const.WINSIZE.height < Const.UI_DESIGN_HEIGHT then
            scaleH = Const.WINSIZE.height / Const.UI_DESIGN_HEIGHT
        end

        if scaleW < scaleH then
            Const.UI_SCALE = scaleW
        else
            Const.UI_SCALE = scaleH
        end

        self.uiLayer:ignoreAnchorPointForPosition(false)
        self.uiLayer:setAnchorPoint(cc.p(0, 0))
        self.uiLayer:setPosition(cc.p(0, 0))
        self.uiLayer:setScale(Const.UI_SCALE, Const.UI_SCALE)
    end

    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile("ui/general.plist")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("ui/general.png")
    cc.Director:getInstance():getTextureCache():reloadTexture("ui/general.png")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/general.plist")
    cc.SpriteFrameCache:getInstance():addSpriteFrames("ui/bigrewardicon.plist")
    local Client = require "mgr/Client"
    self.scene = require("scene/LoginScene").new(true)
    if director:getRunningScene() then
        director:replaceScene(self.scene)
    else
        director:runWithScene(self.scene)
    end

    --Client:init()

    Client:pushDebugInfo('GameMgr:isYayaImEnabled() ' .. tostring(GameMgr:isYayaImEnabled()))
    if GameMgr:isYayaImEnabled() then
    -- 初始化录音管理器
    local mediaPath = ChatMgr:getMediaSavePath()
    local ret
    if gf:gfIsFuncEnabled(FUNCTION_ID.NEW_YAYA_INIT) then
        ret = YayaImMgr:init(mediaPath, false, LeitingSdkMgr:isOverseas())
    else
        ret = YayaImMgr:init(mediaPath, false)
    end
    if ret ~= 0 then
        Log:W('YayaImMgr:init failed, ret:' .. ret)
        else
            -- 设置录音相关参数
            YayaImMgr:setRecordInfo(Const.MAX_RECORD_TIME, 1)
    end
    end

    -- 切换游戏状态
    GameMgr:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)

    -- 开始获取网络状态
    BatteryAndWifiMgr:startUpdateNetWorkStatus()

    -- 记录 version.php 的内容，方便核查问题
    local versionPhp = cc.UserDefault:getInstance():getStringForKey("current-version-code", "")
    Client:pushDebugInfo('version.php: ' .. versionPhp)

    RecordLogMgr:initPlug()
end

-- 停止游戏
function GameMgr:stop()
    if gf:isWindows() then
        require("hotupdate"):cleanup()
    end

    EventDispatcher:dispatchEvent("EVENT_STOPGAME")
    CommThread:stop()
    ChatMgr:stop()
    PromoteMgr:stopSchedule()
    AutoWalkMgr:stop()

    if GameMgr:isYayaImEnabled() then
    YayaImMgr:release()
    end

    self:clearData()
    GameMgr:stopUpdate()
    DlgMgr:unHookMsg()
    FightMgr:clearWhenEndGame()
    GpsMgr:clearData()
    AnimationMgr:cleanup()
    DlgMgr:closeAllDlg()
    Me:cleanup()
    self:cleanupTopLayers()
    ccs.ArmatureDataManager:destroyInstance()
    cc.SpriteFrameCache:destroyInstance()
    TextureMgr:cleanup()
    AutoMsgMgr:stop()
    SpringFestivalAnimateMgr:stopUpdate()
    ChunjieNianyefanMgr:cleanup()
    ShaderMgr:releaseAllShader()
    self.isStop = true
    self.playNpcSoundId = nil
    BatteryAndWifiMgr:stopUpdateNetWorkStatus()
end

-- 发送客户端状态
function GameMgr:sendClientStatus()
    if Client._isConnectingGS then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLIENT_STATUS, self.clientStatus)
    end
end

-- 是否切换到了后台
function GameMgr:isInBackground()
    return self.clientStatus == CLIENT_INACTIVE
end

-- 设置当前客户端的状态
function GameMgr:setClientActiveStatus()
    DebugMgr:checkClientStatus() -- WDSY-27195
    self.clientStatus = CLIENT_ACTIVE
end

-- 是否处于静止状态
function GameMgr:isClientSilentStatus()
    return self.clientStatus == CLIENT_SILENT
end

-- 应用程序被切换到后台
function GameMgr:enterBackground()
    GameMgr.enterBackTime =  gfGetTickCount()
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() then
        -- 已经标记为退出了，直接退出，不用再切后台了
        -- 避免退出时切后台，导致程序没有马上退出，而是在返回前台时退出
        cc.Director:getInstance():endToLua()
        if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        cc.Director:getInstance():mainLoop()
        end
        return
    end

    DebugMgr:addClientStatusLog("GameMgr:enterBackground")-- WDSY-27195

    self.clientStatus = CLIENT_INACTIVE
    self:sendClientStatus()
    gf:resetLastFrameTick()

    -- 2018寒假活动打雪仗，如果游戏中切入后台，需要向服务器发送暂停
    DlgMgr:sendMsg("VacationSnowDlg", "pauseGame")
    DlgMgr:sendMsg("VacationWhiteDlg", "enterBackground")
    DlgMgr:sendMsg("ShengxdjDlg", "cleanupChar")
    DlgMgr:sendMsg("ShiswgDlg", "enterBackground")

    GameMgr:stopCurAllSound()
    if not gf:isIos() then
        SoundMgr:pauseMusic()
    end

    -- 停止语音播放
    ChatMgr:stopPlayRecord()
    -- 保存好友聊天记录
    FriendMgr:flushChatListToMem()

    -- 保存集市收藏记录
    MarketMgr:saveMarketCollectData()

    -- 开始推送
    LocalNotificationMgr:addAllNotification()

    if gf:isIos() then
    -- 发送自动断线,时间DISCONNECT_TIME_BACKGROUND
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_AUTO_DISCONNECT, DISCONNECT_TIME_BACKGROUND)
        self.LastEnterBackGroundTimeStamp = os.time()
    end

    EventDispatcher:dispatchEvent("ENTER_BACKGROUND")

    -- 关闭充值时打开的等待界面
    if LeitingSdkMgr.callingPayAction then
        DlgMgr:closeDlg("WaitDlg")
        gf:getUILayer():stopAction(LeitingSdkMgr.callingPayAction)
        LeitingSdkMgr.callingPayAction = nil
    end

    if Me:isRandomWalk() then
        -- 切后台时正在巡逻，记录巡逻信息
        self.randomWalkInfoBeforeEnterBackground = 
            {
                gid = Me:queryBasic("gid"),
                tag = Me:isRandomWalk(),
                curMapName = MapMgr:getCurrentMapName(),
                randBindTask = AutoWalkMgr.randBindTask,
                center = AutoWalkMgr.randCenter,
                randDestination = AutoWalkMgr.randDestination,
            }
    end
end

-- 应用程序被激活了
function GameMgr:enterForeground()
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() then
        return
    end

    DebugMgr:addClientStatusLog("GameMgr:enterForeground0:" .. tostring(MessageMgr.isInBackground))-- WDSY-27195

    -- 已经在前台了，直接返回
    -- 在Android下，EditBox输入完成时切换焦点时会触发，此处需要判断一下
    if self.clientStatus == CLIENT_ACTIVE and not MessageMgr.isInBackground then return end

    if self.clientStatus == CLIENT_ACTIVE and MessageMgr.isInBackground then
        DebugMgr:recordClientStatus(string.format("enterForeground, clientStatus:%s, MessageMgr.isInBackground:%s", tostring(self.clientStatus), tostring(MessageMgr.isInBackground)))  -- WDSY-27195
    end

    if self:isInBackground() or MessageMgr.isInBackground then
        DebugMgr:addClientStatusLog("GameMgr:enterForeground1:" .. tostring(MessageMgr.isInBackground))-- WDSY-27195

        if gf:isWindows() then
            CommThread:loop()
        end

        local isExecute = false
        self.delayProcessComm = function()
            if isExecute then return end
            isExecute = true
            DebugMgr:addClientStatusLog("GameMgr:enterForeground2:" .. tostring(MessageMgr.isInBackground))-- WDSY-27195
            performWithDelay(gf:getUILayer(), function()
                CommThread:loop(true)   -- 一次读取全部数据
                MessageMgr.isInBackground = false
                DebugMgr:clearClientStatus()-- WDSY-27195
                if self.canRefreshUserData then
                    MessageMgr.msgQueue = {}    -- 需要刷新用户数据，全部丢去
                    self.isRefreshUserData = true
                    DlgMgr:openDlg("WaitDlg")
                    gf:CmdToServer("CMD_REFRESH_USER_DATA")
                    EventDispatcher:dispatchEvent("REFRESH_USER_DATA")
                    MessageMgr.ignoreBeforeLoginDone = true
                    self.canRefreshUserData = nil
                else
                    RedDotMgr:checkAddChatRedDot()
                    RedDotMgr:checkAddRedDot()
                end

                MessageMgr:processUnDiscardMsg()    -- 处理不可丢弃的消息
                self.delayProcessComm = nil
            end, 0)
        end
    end

    self.clientStatus = CLIENT_ACTIVE
    DebugMgr:addClientStatusLog("GameMgr:enterForeground3:" .. tostring(MessageMgr.isInBackground))-- WDSY-27195
    self:sendClientStatus()
    SoundMgr:readCfg()

    local nowTime = os.time()
    if gf:isIos() and GameMgr.runtimeState == GAME_RUNTIME_STATE.MAIN_GAME then
        if nowTime - self.LastEnterBackGroundTimeStamp > DISCONNECT_TIME_BACKGROUND then
            -- 客户端不自动断开由服务器主动断开
            ShortcutMgr.delayOper = true
        else
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_AUTO_DISCONNECT, -1)
        end
    end

    -- 设置检测连接的延迟时间
    if gfGetTickCount() - Client:getLastRecvTime() > DISCONNECT_MAX_INTERVAL - 2000 then
        -- 检测时间已经小于 2s 了，设置一下推迟时间，使其在 2s 后检测
        self.delayCheckConnectionTime = gfGetTickCount() - Client:getLastRecvTime() - DISCONNECT_MAX_INTERVAL + 2000
    else
        self.delayCheckConnectionTime = 0
    end


    GameMgr.enterBackTime = GameMgr.enterBackTime or 0
    TttSmfjMgr:enterForeground(gfGetTickCount() - GameMgr.enterBackTime)

    -- 清除推送
    LocalNotificationMgr:clearAllNotification()

    -- 同步当前战斗动画
    FightMgr:refreshCurrentCombatAction()

    -- 自动处理
    ShortcutMgr:doWhenEnterForeground()

    -- 结拜相关
    if self.canRefreshUserData then
        JiebaiMgr:doWhenEnterForeground()
    end

    -- 清除自动播放语音队列
    ChatMgr:clearPlayVoiceList()

    -- 更新切后台时需要更新的好友或临时列表ui
    FriendMgr:refreshFriendListAfterBcakground()

    EventDispatcher:dispatchEvent("ENTER_FOREGROUND")

    -- 重置统计的当前时间
    StatisticsMgr:resetCurTick()

    -- 激活后，任务列表重置
    DlgMgr:sendMsg("MissionDlg", "initMissionList")

    DlgMgr:sendMsg("ShiswgDlg", "beActive")

    DlgMgr:sendMsg("LangmqgDlg", "removeAllMagic")

    -- 2018寒假活动打雪仗，如果游戏中被激活，需要向服务器发送继续
    DlgMgr:sendMsg("VacationSnowDlg", "continueGame")

    -- 2018暑假活动，如果触碰 噬仙虫，5秒冻屏回调处理
    if MapMgr:isInMapByName(CHS[4010025]) and TaskMgr:getTaskByName(CHS[4010021]) then
        -- 在无名仙境地图，且有粽料收集任务时再做相应处理
        GameMgr.enterBackTime = GameMgr.enterBackTime or 0
        if gfGetTickCount() - GameMgr.enterBackTime > 5000 then
            ActivityMgr:releaseForSXC()
        else
            ActivityMgr:setSXCTouchEff((5000 - (gfGetTickCount() - GameMgr.enterBackTime )) / 1000)
        end
    end

    -- 停止当前NPC语音
    local uiLayer = gf:getUILayer()
    if uiLayer then
        performWithDelay(uiLayer, function()
        GameMgr:stopCurAllSound()
    end, 0)
    end
end

-- 创建顶级层
-- 游戏分层，分别为地图层、角色层和 UI 层
-- 角色层再分三层：角色底层、角色中间层和角色上层
function GameMgr:createTopLayers()
    self.mapLayer       = cc.Layer:create() -- 地图层
    self.charLayer      = cc.Layer:create() -- 角色层
    self.uiLayer        = cc.Layer:create() -- UI 层
    self.weatherLayer   = cc.Layer:create() -- 天气层
    self.weatherAnimLayer   = cc.Layer:create() -- 天气动画层

    self.mapLayer:retain()
    self.charLayer:retain()
    self.uiLayer:retain()
    self.weatherLayer:retain()
    self.weatherAnimLayer:retain()

    self.mapBgLayer = cc.Layer:create() -- 地表背景层
    self.mapLayer:addChild(self.mapBgLayer)

    self.mapObjLayer = cc.Layer:create() -- 地表物件层
    self.mapLayer:addChild(self.mapObjLayer)

    self.mapEffectLayer = cc.Layer:create() -- 地表动画层
    self.mapLayer:addChild(self.mapEffectLayer)

    self.mapLayer:setTag(Const.TAG_MAP_LAYER)
    self.charLayer:setTag(Const.TAG_CHAR_LAYER)
    self.uiLayer:setTag(Const.TAG_UI_LAYER)
    self.weatherLayer:setTag(Const.TAG_WEATHER_LAYER)
    self.weatherAnimLayer:setTag(Const.TAG_WEATHER_ANIM_LAYER)

    self.charBottomLayer = cc.Layer:create()
    self.charMiddleLayer = cc.Layer:create()
    self.charTopLayer = cc.Layer:create()
    self.puttingObjLayer = cc.Layer:create() -- 地表摆放层

    self.charLayer:addChild(self.charBottomLayer)
    self.charLayer:addChild(self.puttingObjLayer) -- 道具摆件数量较多，故另创建一层
    self.charLayer:addChild(self.charMiddleLayer)
    self.charLayer:addChild(self.charTopLayer)

    -- ui 层上添加  topLayer 用于检测玩家是否有操作
    self.topLayer = cc.Layer:create()
    self.topLayer:retain()
    self.topLayer:setTouchEnabled(false)
    self.topLayer:setGlobalZOrder(Const.ZORDER_TOPMOST + 1)

    gf:bindTouchListener(self.topLayer, function(touch, event)
        if CLIENT_INACTIVE == self.clientStatus then
            return
        end

        -- 记录 touch 时间
        self:updateLastTouchTime()

        -- 记住当前点击的位置
        self.curTouchPos = touch:getLocation()

        if event:getEventCode() == cc.EventCode.ENDED then
            self:addTouchPos(self.curTouchPos)

            -- 记录点击点的位置，发送给位服务器，防外挂
            RecordLogMgr:addTouchAction("clickmouse")
        end

        -- 切换为激活状态
        if self.clientStatus ~= CLIENT_ACTIVE then
            DebugMgr:checkClientStatus() -- WDSY-27195
            self.clientStatus = CLIENT_ACTIVE
            self:sendClientStatus()
        end

        -- 记录连续点击
        if RecordLogMgr.isContinuing then
            local step = RecordLogMgr.completeStep
            performWithDelay(self.topLayer, function ()
            	if step == RecordLogMgr.completeStep then
                    RecordLogMgr:cleanContinueClick()
            	end
            end, 0.2)
        end

        if RecordLogMgr.isRecordingPosForPluginGM and event:getEventCode() == cc.EventCode.BEGAN then
            -- 若开启，并且是点击事件
            RecordLogMgr:addPosForPosRecord(self.curTouchPos)
        end


        EventDispatcher:dispatchEvent("EVENT_DO_DRAG", event:getEventCode())

        -- 需要往后传递
        return true
    end, {
            cc.Handler.EVENT_TOUCH_BEGAN,
            cc.Handler.EVENT_TOUCH_MOVED,
            cc.Handler.EVENT_TOUCH_ENDED
        }, true)

end

-- 往 uiLayer 层添加子节点
-- caller : 当 uiLayer 移除所有子节点时，会调用 caller["doWhenUiLayerRemoveAllChild"]
function GameMgr:addChildToUiLayer(node, zorder, caller)
    self.uiLayer:addChild(node, zorder)
    assert(caller, "GameMgr:addChildToUiLayer must set caller")
    assert(type(caller["doWhenUiLayerRemoveAllChild"]) == "function",
        "caller must have doWhenUiLayerRemoveAllChild function")
    self.uiLayerUsers[caller] = 1
end


-- 记录玩家的点击信息，进行一些特殊的处理，如显示 fps 信息
function GameMgr:addTouchPos(pos)
    -- 保存最近的 SAVE_TOUCH_POS_MAX_NUM 个点
    if self.touchPosIdx > SAVE_TOUCH_POS_MAX_NUM then
        for i = 1, SAVE_TOUCH_POS_MAX_NUM - 1 do
            self.touchPosList[i] = self.touchPosList[i + 1]
        end

        self.touchPosList[SAVE_TOUCH_POS_MAX_NUM] = pos
    else
        self.touchPosList[self.touchPosIdx] = pos
        self.touchPosIdx = self.touchPosIdx + 1
    end

    if self.touchPosIdx > SAVE_TOUCH_POS_MAX_NUM then
        local x1 = self.touchPosList[1].x
        local y1 = self.touchPosList[1].y
        local x2 = self.touchPosList[2].x
        local y2 = self.touchPosList[2].y
        local x3 = self.touchPosList[3].x
        local y3 = self.touchPosList[3].y
        local x4 = self.touchPosList[4].x
        local y4 = self.touchPosList[4].y
        local dit = 120
        local w = Const.WINSIZE.width
        local h = Const.WINSIZE.height
        if x1 < dit and y1 > h - dit and x2 > w - dit and y2 > h - dit and
            x3 > w - dit and y3 < dit and x4 < dit and y4 < dit then
            -- 顺时针点击四个角
            if DlgMgr:isDlgOpened("ConfirmDlg") then
                -- 显示 fps 信息
                cc.Director:getInstance():setDisplayStats(true)
                TextureMgr:dumpTextures()
                return
            else
                -- 获取 yaya 语音库的相关信息，该信息也一起显示在 GMDebugTipsDlg 上
                ChatMgr:fetchYayaIMInfo()

                -- 显示 debug 信息的最后 16 行内容
                local debugInfo = Client:getDebugInfo(16)
                if debugInfo then
                    local dlg = DlgMgr:openDlg("GMDebugTipsDlg")
                    if dlg ~= nil then
                        dlg:setTitle(CHS[3004014])
                        dlg:setErrStr(debugInfo)
                    end
                end

                -- 获取一些信息
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_MINFO)
            end
        elseif x1 < dit and y1 > h - dit and x4 > w - dit and y4 > h - dit and
            x3 > w - dit and y3 < dit and x2 < dit and y2 < dit then
            -- 逆时针点击四个角，则隐藏 fps 信息
            cc.Director:getInstance():setDisplayStats(false)
        end
    end
end

-- 清除顶级层
function GameMgr:cleanupTopLayers()
    if self.mapLayer then
        self.mapLayer:removeFromParent(true)
        self.mapLayer:release()
        self.mapLayer = nil
    end

    if self.charLayer then
        self.charLayer:removeFromParent(true)
        self.charLayer:release()
        self.charLayer = nil
    end

    if self.uiLayer then
        self.uiLayer:removeFromParent(true)
        self.uiLayer:release()

        self.uiLayer = nil
    end

    if self.weatherLayer then
        self.weatherLayer:removeFromParent(true)
        self.weatherLayer:release()
        self.weatherLayer = nil
    end

    if self.weatherAnimLayer then
        self.weatherAnimLayer:removeFromParent(true)
        self.weatherAnimLayer:release()
        self.weatherAnimLayer = nil
    end

    if self.topLayer then
        self.topLayer:removeFromParent(true)
        self.topLayer:release()
        self.topLayer = nil
    end

    __last_cleanup_top_layer = gfTraceback()
end

-- 设置场景中使用的顶级层
function GameMgr:setTopLayers(scene, uiOnly)
    self.mapLayer:removeFromParent(true)
    self.charLayer:removeFromParent(true)
    self.uiLayer:removeFromParent(true)
    self.weatherLayer:removeFromParent(true)
    self.weatherAnimLayer:removeFromParent(true)
    self.topLayer:removeFromParent(true)

    if self.multiTouchListener then
        local eventDispatcher = self.uiLayer:getEventDispatcher()
        if eventDispatcher then
            eventDispatcher:removeEventListener(self.multiTouchListener)
        end
        self.multiTouchListener = nil
    end

    -- uiLayer 移除了所有的子节点，需要通知相关对象
    for caller, i in pairs(self.uiLayerUsers) do
        if caller["doWhenUiLayerRemoveAllChild"] then
            caller["doWhenUiLayerRemoveAllChild"](caller)
        end
    end

    self.uiLayerUsers = {}

    if uiOnly then
        scene:addChild(self.uiLayer)
        self.uiLayer:setTouchEnabled(false)
    else
        scene:addChild(self.mapLayer)
        scene:addChild(self.charLayer)
        scene:addChild(self.weatherLayer)
        scene:addChild(self.weatherAnimLayer)
        scene:addChild(self.uiLayer)
        self:createMutiTouchLayer(self.uiLayer)
    end

    scene:addChild(self.topLayer)
end

-- 获取场景高度
function GameMgr:getSceneHeight()
    if self.scene then
        return self.scene:getHeight()
    end

    return 0
end

-- 切换场景
function GameMgr:changeScene(sceneName, uiOnly)
    if self.scene and self.scene:getType() == sceneName then
        -- 当前场景就是要创建的场景

        if type(self.scene.startSendMoveCmdsSch) == "function" then
            -- WDSY-28853 部分地图要修改发送角色步数的时间间隔
            self.scene:startSendMoveCmdsSch()
        end
        return
    end

    if self.toScene then
        self.toScene:cleanup()
        self.toScene:release()
        self.toScene = nil
    end

    self.scene = require("scene/" .. sceneName).new(uiOnly)
    self.toScene = self.scene

    -- 需要 retain 一下，否则该帧结束后该对象就会被释放
    self.scene:retain()
end

-- 获取场景类型
function GameMgr:getCurSceneType()
    return self.scene:getType() or ""
end

function GameMgr:tryToChangeScene()
    if not self.toScene then
        -- 没有场景需要切换
        return
    end

    cc.Director:getInstance():replaceScene(self.toScene)
    self.toScene:release()
    self.toScene = nil
end

function GameMgr:setInCombat(inCombat)
    self.inCombat = inCombat
end

-- 战斗开始了
function GameMgr:onStartCombat(data, isLookOn)
    -- 检查内存状况
    gf:CheckMemory()

    -- 标记
    MessageMgr:markRecvEndCombat()

    FightMgr:closeFightDlgs()
    FightMgr:cleanup()

    -- 更新地图位置
    if not BattleSimulatorMgr:isRunning() and self.scene and self.scene.map then
        self.scene.map:update(true, true)
    end

    -- 初始化战斗中宠物临时数据
    PetMgr:initCombatTempData()

    if isLookOn then Me:setLookFightState(true) end

    FightMgr:create(data.mode)
    Me.isMoved = false

    if self.scene and self.scene.map ~= nil then
        self.scene.map:resetDelayTime()
    end

    DlgMgr:sendMsg("ChatDlg", "resetRootPos")
    GameMgr.beforeCombatUIState = self.curMainUIState

    if GameMgr.isMove and GameMgr:isHideAllUI() then
        -- 如果正在移动，并且当前是状态隐藏，则说明正常  隐藏过程中，直接将主界面相关移动至屏幕外
        GameMgr:hideAllUI(0)
    end

    if not BattleSimulatorMgr:isRunning() then
        GuideMgr:refreshMainIcon()
    end

    -- 关闭所有悬浮框
    DlgMgr:closeAllFloatDlg()

    -- 关闭确认框
    local confirmDlg = DlgMgr:getDlgByName("ConfirmDlg")
    if confirmDlg and confirmDlg:needAutoCancelWhenEnterCombat() then
        confirmDlg:onCancelButton()
    end

    -- 隐藏防沉迷相关信息
    DlgMgr:sendMsg("HeadDlg", "setShowAntiaddictionInfo", false)

    -- 娃娃跟随状态进入战斗要刷新
    DlgMgr:sendMsg("HeadDlg", "updateChildPanelShow")

    -- 停止NPC说话音效
    self:stopCurNpcSound()

    -- 不使用如意刷道令长期刷道疑似外挂的行为
    RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock = {fum = false, xiangy = false, feix = false}   -- GetTaoDlg点击次数锁
end

-- 战斗结束了
-- ！！！ 注意当前执行的消息是否需要清除 MessageMgr.recvEndCombatMark 标记
function GameMgr:onEndCombat()

    self:setInCombat(false)
    Me:setLookFightState(false)

    -- 记录战斗数据结束
    DebugMgr:endFightMsg()

    -- 关闭战斗相关界面
    FightMgr:closeFightDlgs()
    FightMgr:cleanup()
    FightMgr:clearBattleType()

    -- 战斗记录增加回合结束
    FightCmdRecordMgr:doEndCombat()

    -- 重置一下当前的状态
    CharMgr:doCharHideStatus(Me)

    -- 由于hideAllUI会调用me:setEndPos, 若战斗前UI关闭，战斗后会中断自动寻路
    -- 所以此逻辑需放在自动寻路与自动遇怪之前
    if GameMgr.beforeCombatUIState ~= self.curMainUIState then
        if GameMgr.beforeCombatUIState == MAIN_UI_STATE.STATE_SHOW then
            GuideMgr:refreshMainIcon()
        else
            self:hideAllUI(0)
        end
    end

    -- 出战斗，执行战斗中收到的一些延迟非战斗消息
    MessageMgr:processAllCNMsgs()


    -- 如果是特殊技能战斗（通天塔北斗神将），需要快速使用技能
    if FightMgr:getCombatMode() == COMBAT_MODE.COMBAT_MODE_TONGTIANTADING then
        FightMgr:setFastSkill()
        local specialSkills = SkillMgr:getSkillsByCombatMode(COMBAT_MODE.COMBAT_MODE_TONGTIANTADING)
        for _, no in pairs(specialSkills) do   -- 通天塔顶-北斗战将特殊技能
            SkillMgr:deleteSkill(Me:getId(), no)
        end
    end

    -- 如果需要，则接着自动寻路
    AutoWalkMgr:continueAutoWalk()

    -- 需要执行任务的自动寻路
    TaskMgr:continueTaskAutoWalk()

    -- 如果正在执行的任务完成了，则清除自动遇敌信息
    if TaskMgr:checkCurTaskCanComplete() then
        AutoWalkMgr:endRandomWalk()
    end

    -- 尝试进行自动遇怪
    AutoWalkMgr:randomWalk()

    -- 更新 me 的遮挡信息
    local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
    Me:updateShelter(mapX, mapY)

    -- 战斗结束后继续行走
    Me:resumeGotoEndPos()

    -- 清除人物战斗中吸收数据
    Me:cleanComAbsorbData()

    -- 清除宠物战斗中吸收的数据
    PetMgr:cleanComAbsorbData()

    -- 继续播放指引
    GuideMgr:playGuide()

    -- 结束战斗后要恢复聊天窗的位置
    if self.curMainUIState == MAIN_UI_STATE.STATE_HIDE then
        local dlg = DlgMgr:getDlgByName("ChatDlg")

        if dlg then
            dlg.root:setPosition(dlg.originPos.x + ALL_LAYER_UI.ChatDlg.x, dlg.originPos.y + ALL_LAYER_UI.ChatDlg.y)
        end
    end

    -- 帮派巨兽信息界面存在，也要现实
    DlgMgr:sendMsg("PartyBeatMonsterMainInfoDlg", "setVisible", true)

    -- 如果存在公告则，显示
    if DlgMgr:isDlgOpened("AnnouncementDlg") then
        DlgMgr:setVisible("AnnouncementDlg", true)
    end

    if not DlgMgr:getDlgByName("DramaDlg") and not DlgMgr:getDlgByName("ArenaDlg") then
        -- 检测如果战斗有一般性界面存在，需要隐藏主界面ui
        DlgMgr:normalDlgOpenNeedColseMainDlg()
    end

    -- 如果有防沉迷信息需要显示，则进行显示
    DlgMgr:sendMsg("HeadDlg", "setShowAntiaddictionInfo", true)

	-- 通知主界面隐藏交易panel
    DlgMgr:sendMsg("SystemFunctionDlg", "setTradeVisible", false)

    -- 豪华婚礼弹幕，可能出现的时候，玩家在战斗（被隐藏），所以出战斗的时候，豪华婚礼弹幕界面存在需要可见
    DlgMgr:sendMsg("WeddingBarrageDlg", "setCtrlVisible", true)


    DlgMgr:sendMsg("HeadDlg", "updateFightPetWhenHasFightKid")
    DlgMgr:sendMsg("HeadDlg", "updateChildPanelShow")

    -- 标记
    MessageMgr:markRecvEndCombat()

    -- 分发停止战斗事件
    EventDispatcher:dispatchEvent(EVENT.EVENT_END_COMBAT)

    -- 检查内存状况
    gf:CheckMemory()
end

function GameMgr:isEnterGameOK()
    return self.isEnterGame
end

local ZORDER_DLGS = {
    "AutoFightChosenDlg",
    "FriendDlg",
    "UserDlg",
    "ChatDlg",
}

-- 切换到后台后，每隔一段时间会调用该函数
-- 注意：此处只能处理数据，不能处理与贴图相关的逻辑
function GameMgr:onBackgroundFrame()
    if not GameMgr:isInBackground() then return end -- 已经不再后台了

    -- 处理通讯模块的数据
    CommThread:loop()

    self:runFrameFunc()

    EventDispatcher:dispatchEvent("EVENT_BACKGROUND_FRAME")
end

-- 注册每帧需要执行的函数
function GameMgr:registFrameFunc(tag, func, obj, notInBackGround)
    if not func or "function" ~= type(func) then return end
    if not self.funcInFrame then self.funcInFrame = {} end
    if obj then obj.perframeFunc = func end
    self.funcInFrame[tag] = {func = func, obj = obj, notInBackGround = notInBackGround or false}
end

function GameMgr:unRegistFrameFunc(tag)
    if self.funcInFrame and self.funcInFrame[tag] then
        self.funcInFrame[tag] = nil
    end
end

-- 每帧执行的函数
function GameMgr:runFrameFunc()
    local isInBackGround = GameMgr:isInBackground()
    if self.funcInFrame then
        for tag, v in pairs(self.funcInFrame) do
            if not isInBackGround or not v.notInBackGround then
                -- 不在后台，或者后台可以执行
                if v.obj then
                    if v.obj.perframeFunc and type(v.obj.perframeFunc) == 'function' then
                    v.obj.perframeFunc(v.obj)
                    end
                else
                    v.func()
                end
            end
        end
    end
end

function GameMgr:update()
    -- self:showCost()

    gf:getTickCount(true)       -- 计算当前帧的时间
    self:tryToChangeScene()

    if not self.delayProcessComm then
        CommThread:loop()
        MessageMgr:process()
    else
        self.delayProcessComm()
    end

    -- 更新角色管理器
    CharMgr:update()

    -- 居所宠物管理器
    HomeMgr:update()

    DroppedItemMgr:update()

    -- 更新战斗管理器
    FightMgr:update()

    -- 更新动画管理器
    AnimationMgr:update()

    -- 观战定时器
    WatchRecordMgr:update()

    -- 监听点击事件
    RecordLogMgr:update()

    -- 更新声音管理器
    SoundMgr:update()

    -- 暑假-谁能吃瓜
    SummerSncgMgr:update()

    NewYearGuardMgr:update()

    TttSmfjMgr:update()

    self.lastUpdateTime = gf:getTickCount()

    if self.clientStatus == CLIENT_ACTIVE and self.lastUpdateTime - self.lastTouchTime >= SILENT_MAX_INTERVAL then
        -- 指定时间内没有触屏则设置为 CLIENT_SILENT 状态
        self.clientStatus = CLIENT_SILENT
        self:sendClientStatus()
    end

    SoundMgr:changingMusicValue()

    GameMgr:checkDisconnect()

    if self.loginGsTime then
        if gf:getTickCount() - self.loginGsTime > connect_gs_time * 60 * 1000 then
            gf:ShowSmallTips(CHS[3004015])
            DlgMgr:closeDlg("CreateCharDlg")
            DlgMgr:setVisible("UserLoginDlg", true)
            DlgMgr:closeDlg("LoginChangeDistDlg")
            self:clearLoginGsTime()
            CommThread:stop()

            if GameMgr:getCurSceneType() == "GameScene" then -- 在游戏场景得退回到登录大厅
                MessageMgr:pushMsg({ MSG = 0x1368, result = false })
            end
        end
    end

    self:runFrameFunc()

    DebugMgr:onFrame()

    -- 更新服务器时间
    self:refreshServerTime()

    -- 重置缓存释放策略
    -- self:resetCacheTime()

    StatisticsMgr:calcFrameRate()
end

-- 重置缓存释放策略
function GameMgr:resetCacheTime()
    local curTickCount = gf:getTickCount()
    if gf:isWindows() or (self.lastCheckCacheTime and curTickCount - self.lastCheckCacheTime < 5 * 1000) then return end    -- 每5s重置一次
    local isLowMemory = DeviceMgr:isLowMemory()
    AnimationMgr:resetCacheTime(isLowMemory)
    TextureMgr:resetCleanInterval(isLowMemory)
    self.lastCheckCacheTime = curTickCount
end

function GameMgr:calcFrameCostTime()
    self.deltaTime = os.clock() - self.frameStartTime
    -- Log:D("current frame cost:" .. tostring(self.deltaTime))
end

function GameMgr:setLoginGsTime()
    self.loginGsTime = gfGetTickCount()
end

function GameMgr:clearLoginGsTime()
    self.loginGsTime = nil
end

function GameMgr:checkDisconnect()
    self.disTime = self.disTime or gf:getTickCount()
    if gf:getTickCount() - self.disTime < 30 * 1000 then return end
    self.disTime = gf:getTickCount()
    if Client._isConnectingGS and Client._keepAlive then
        local lastTime = Client:getLastRecvTime()
        if lastTime > 0 then
            if gf:getTickCount() - lastTime > DISCONNECT_MAX_INTERVAL + self.delayCheckConnectionTime then
                -- 断开连接
                CommThread:stopAAA()
                CommThread:stop()
                MessageMgr:pushMsg({MSG = 0x1368})
            end
        end
    end
end

-- 获取区组名字
function GameMgr:getDistName()
    return self.dist
end

-- 设置区组名字
function GameMgr:setDistName(distName)
    self.dist = distName
end

-- 获取线
function GameMgr:getServerName()
    return self.serverName
end

function GameMgr:getTotalLieNum()
    return self.lineNum
end

-- 当前是否是跨服线路
function GameMgr:IsCrossDist()
    if 1 == self.corss_server_dist then
        return true
    end

    return false
end

function GameMgr:MSG_ENTER_GAME(map)
    DataBaseMgr:init()

    -- 清除调试信息
    Client:clearDebugInfo()

    -- 清除过期日志
    pcall(function() Log:CF(os.time() - 3 * 24 * 3600) end)

    -- 加载好友界面
    --local dlg = DlgMgr:openDlg("FriendDlg")
    --dlg:setVisible(false)

    -- 关闭登录界面
    if not self.isLoadInitData or GMMgr:isGM() then
        -- WDSY-27017 修改 等收到 NOTIFY_SEND_INIT_DATA_DONE 消息再关闭
        -- WDSY-30133 GM监听其他玩家时不会收到NOTIFY_SEND_INIT_DATA_DONE
    DlgMgr:closeDlg("WaitDlg")
    end

    DlgMgr:closeDlg("CreateCharDlg")

    EquipmentMgr:dataClean()
    self.login_time = map.time
    self.serverTimeZone= map.time_zone
    self.dist = map.dist
    self.serverName = map.name
    self.lineNum = map.lineNum -- 线总数
    self.corss_server_dist = map.corss_server_dist

    --[[ 这里不处理时间，因为服务器会 MSG_REPLY_SERVER_TIME 更新时间，这边处理，由于客户端登录处理消息多， clientTime 可能存在误差
    self.clientTime = map.clientTime
    self.serverTime = map.time
    --]]


    GuideMgr:refreshMainIcon()

    if GameMgr:isYayaImEnabled() and not YayaImMgr.loginIsCalled then
    -- 登录语音库
        -- 目前登录接口有概率会崩掉，所以加个标记来记录，以确保只调用一次
    local ret = YayaImMgr:login(Me:queryBasic("gid"), Me:getName(), Const.MAX_RECORD_TIME, 1)
        YayaImMgr.loginIsCalled = true

        Log:D("YayaImMgr:login")
    end

    if not string.isNilOrEmpty(Me:queryBasic("gid")) then
    -- 登录上报
    LeitingSdkMgr:loginReport({
        roleId = Me:queryBasic("gid"),
        roleName = Me:getName(),
        roleLevel = Me:queryBasic("level"),
        zoneId = Client:getWantLoginDistName(),
        roleCTime = Me:queryBasicInt("create_time"),
        zoneName = Client:getWantLoginDistName(),
    })
    end

    self.isEnterGame = true

    -- 设置登录角色信息
    DistMgr:setLoginInfo()

    -- 切换游戏状态
    GameMgr:setGameState(GAME_RUNTIME_STATE.MAIN_GAME)

    Client:getGsList()

    -- 清除推送
    LocalNotificationMgr:clearAllNotification()
    --LocalNotificationMgr:addAllNotification()

    -- 开始获取电池电量,wifi状态
    BatteryAndWifiMgr:startUpdateBattery()
    BatteryAndWifiMgr:startUpdateWifi()

    -- 设置客户端处于激活状态
    DebugMgr:checkClientStatus() -- WDSY-27195
    self.clientStatus = CLIENT_ACTIVE
    self:sendClientStatus()

    -- 如果换线的时候，驱魔香是处于开启状态，要重新请求服务器确认驱魔香状态
    --[[
    if PracticeMgr.isUseExorcism then
        local noTip = 1
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_EXORCISM, noTip)
    end
    --]]
    -- 清除gs登录没进入的空闲时间
    self:clearLoginGsTime()

    -- 自动发送
    AutoMsgMgr:doWhenEnterGame()

    -- 如果从界面进入游戏则弹出免责对话框
    if not DistMgr:getIsSwichServer() and DistMgr:isTestDist(map.dist) and self.isEnterGameByLoginScene then
        DlgMgr:openDlg("BiggerConfirmDlg")
    end

    -- 发送同意用户协议的版本给服务器
    NoticeMgr:sendAgreemnetVersionToServer()

    -- 发送deviceToken
    GetuiPushMgr:sendDeviceToken()

    -- 换线、登入，未收到任务时，刷新下任务界面
    DlgMgr:sendMsg("MissionDlg", "MSG_TASK_PROMPT")

    -- 初始化状态
    StateMgr:init()

    -- 检测是否合法的刘海屏
    if DeviceMgr:isUnknowNotch() then
        gf:CmdToServer("CMD_REPORT_DEVICE", { device_name = DeviceMgr:getDeviceString() })
    end
end

function GameMgr:MSG_MENU_LIST(data)
    AutoWalkMgr:setTalkToNpcIsEnd(true)
    local content = data.content
    if content == nil or string.len(content) == 0 then
        -- 没有菜单内容
        if not DlgMgr:isDlgOpened("NpcDlg") then
            Me:setTalkWithNpc(false)
        end

        return
    end

    Me:setTalkWithNpc(true)
    Me:setTalkId(data.id)

    local parseData = gf:parseMenu(content, data.name)
    local count = parseData.count
    if AutoWalkMgr:getMessageIndex() or AutoWalkMgr:getMessageautoClickKeys() then
        -- 如果存在多次点击
        if AutoWalkMgr:getMessageautoClickKeys() then
            for i = 1, count do
                local showText, action = gf:parseMenuText(parseData[i])
                for j = 1, #AutoWalkMgr:getMessageautoClickKeys() do
                    local list =  gf:split(AutoWalkMgr:getMessageautoClickKeys()[j], "::")
                    local messageIndex = list[1]

                    -- 设置自动寻路信息
                    if list[2] then
                        local paramList = gf:split(list[2], "=")
                        local dlgName = paramList[1]
                        local dlgParam = paramList[2]
                        local dlgParamList = gf:split(dlgParam, ":")
                        AutoWalkMgr:setOpenDlgParam(dlgName, dlgParamList)
                    end

                    if showText == messageIndex then
                        AutoWalkMgr:removeMessageautoClickKeysByKey(AutoWalkMgr:getMessageautoClickKeys()[j])

                        -- 发送自动点击消息
                        local cmd = "CMD_SELECT_MENU_ITEM"
                        gf:CmdToServer(cmd, {
                            id = data.id,
                            menu_item = action,
                            para = "1",
                        })

                        -- 移除选中对象脚底的光效
                        Me:removeSelectTargetFocusMagic()
                        return
                    end
                end
            end

            -- 没有找到，直接删除，打开NPC对话框界面
            AutoWalkMgr:clearMessageAutoClickKeys()
        end

        -- 只有一次点击
        if AutoWalkMgr:getMessageIndex() then
            for i = 1, count do
                local showText, action = gf:parseMenuText(parseData[i])
                local list =  gf:split(AutoWalkMgr:getMessageIndex(), "::")
                local messageIndex = list[1]

                -- 设置自动寻路信息
                if list[2] then
                    local paramList = gf:split(list[2], "=")
                    local dlgName = paramList[1]
                    local dlgParam = paramList[2]
                    local dlgParamList = gf:split(dlgParam, ":")
                    AutoWalkMgr:setOpenDlgParam(dlgName, dlgParamList)
                end

                if showText == messageIndex then
                    AutoWalkMgr:clearMessageIndex()

                    -- 发送自动点击消息
                    local cmd = "CMD_SELECT_MENU_ITEM"
                    gf:CmdToServer(cmd, {
                        id = data.id,
                        menu_item = action,
                        para = "1",
                    })

                    -- 移除选中对象脚底的光效
                    Me:removeSelectTargetFocusMagic()
                    return
                end
            end

            -- 没有找到，直接删除，打开NPC对话框界面
            AutoWalkMgr:clearMessageIndex()
        end
    end

    if GuideMgr:isRunning() then
        -- 如果处于指引过程中，不能响应相应操作
        if not DlgMgr:isDlgOpened("NpcDlg") then
            Me:setTalkWithNpc(false)
        end

        return
    end

    -- 是否可以播放NPC语音 , true可以播放， false不能
    local isCanPlayNpcSound = true
    if DlgMgr:isDlgOpened("NpcDlg") then
        local dlg = DlgMgr:getDlgByName("NpcDlg")
        if dlg.npc_id == data.id then
            isCanPlayNpcSound = false
        end
    end

    -- 解析菜单，打开对话
    local dlg = DlgMgr:openDlg("NpcDlg")
    -- 播放npc语音
    local npc = CharMgr:getChar(data.id)
    if npc then
        -- 当上一次关闭时间和本次打开时间间隔两秒内，且是同一个NPC，不能播放语音
        if gfGetTickCount() - dlg.lastCloseTime < 2000 and dlg.npc_id == data.id then
            isCanPlayNpcSound = false
        end

        if isCanPlayNpcSound then
            self:playNpcEffect(npc:getName())
        end
    end

    -- 设置NPC对话框
    if not TeamMgr:isTeamMeber(Me) then
        dlg:setVisible(true)
        dlg:setMenuNpcId(data.id, data.name)
        dlg:setPortrait(data.portrait)
        dlg:setSecretKey(data.secret_key)
        dlg:setMenu(content, data.name)
        dlg:setDlgAttrib(data.attrib)
    else
        dlg:updateDlg(data)
    end
end

function GameMgr:playNpcEffect(npcName)
    local soundList = NPC_SOUND_LIST[npcName]

    if not soundList then
        for tempName, data in pairs(NPC_SOUND_LIST) do
            local len = string.len(tempName)
            if string.match(npcName, tempName) then
                soundList = NPC_SOUND_LIST[tempName]
            end
        end
    end

    if soundList and soundList.talkEffectList and #soundList.talkEffectList > 0 then
        if self.playNpcSoundId then
            SoundMgr:stopEffectById(self.playNpcSoundId)
        end

        local index = math.random(1, #soundList.talkEffectList)
        local effectName = soundList.talkEffectList[index]

        self.playNpcSoundId = SoundMgr:playNpcEffect(effectName)

    end
end

function GameMgr:MSG_MENU_CLOSED(data)
    DlgMgr:closeDlg("NpcDlg", nil, true)

    Me:setTalkWithNpc(false)

    -- 需要执行任务的自动寻路
    TaskMgr:continueTaskAutoWalk()
end

function GameMgr:MSG_GOODS_LIST(data)

    table.sort(data.goods, function(l, r)
        if l.goods_no < r.goods_no then return true end
        if l.goods_no > r.goods_no then return false end
    end)

    -- 0为药店   1为杂货店
    if data.shopType == 0 then
        local dlg = DlgMgr:openDlg("PharmacyDlg")
        dlg:updateSell(data)
    else
        local dlg = DlgMgr:openDlg("GroceryStoreDlg")
        dlg:setClassify(data.goods[1] and data.goods[1].type > 0)
        dlg:updateSell(data)
    end
end

function GameMgr:MSG_ASK_BUY_ONLINE_ITEM(data)
        local buy = {}
        local pos = gf:findStrByByte(data.para, "#")
        local name, count
        while pos ~= nil do
            local countPos = gf:findStrByByte(data.para, "@")
            if not countPos then

                name = string.sub(data.para, 1, gf:findStrByByte(data.para, "#") - 1)
                count = 1
            else
                name = string.sub(data.para, 1, countPos - 1)
                count = string.sub(data.para, countPos + 1, pos - 1)
            end
            buy[name] = tonumber(count)
            data.para = string.sub(data.para, pos + 1, -1)
            pos = gf:findStrByByte(data.para, "#")
        end
        local countPos = gf:findStrByByte(data.para, "@")
        if not countPos then
            name = string.sub(data.para, 1, -1)
            count = 1
        else
            name = string.sub(data.para, 1, countPos - 1)
            count = string.sub(data.para, countPos + 1, -1)
        end
        buy[name] = tonumber(count)
        local cash = buy["cash"] or 0
        buy["cash"] = nil

    gf:askUserWhetherBuyItem(buy, nil, data.from)
end

function GameMgr:MSG_GENERAL_NOTIFY(data)
    local notify = data.notify
    if NOTIFY.WHETHER_BUY_ITEM == notify then
        self:MSG_ASK_BUY_ONLINE_ITEM(data)
    elseif NOTIFY.WHETHER_EXCHAGE_CASH == notify then
        local cash = math.max(math.floor(tonumber(data.para)), 0)
        gf:askUserWhetherBuyCash(cash)
    elseif NOTIFY.WHETHER_BUY_GOLD == notify then
        gf:askUserWhetherBuyCoin(data.para)
    elseif NOTIFY.NOTIFY_OPEN_DLG == notify then
        DlgMgr:openDlgWithParam(data.para)
       -- DlgMgr:openDlg(data.para)
    elseif NOTIFY.NOTIFY_CLOSE_DLG == notify then
        DlgMgr:closeDlgWithParam(data.para)
        -- DlgMgr:closeDlg(data.para)
    elseif NOTIFY.NOTICE_BUY_ELITE_PET == notify then
        DlgMgr:closeDlg("ElitePetShopDlg")

        GiftMgr:pushOneGetItemInfo(data)
    elseif NOTIFY.NOTICE_STOP_AUTO_WALK == notify then      -- -- 停止自动寻路 和自动遇敌
        AutoWalkMgr:stopAutoWalk()
        AutoWalkMgr:endAutoWalk()
        AutoWalkMgr:endRandomWalk()

    elseif NOTIFY.NOTICE_UPDATE_MAIN_ICON == data.notify then
        GuideMgr:updateMainIcon(data)
    elseif NOTIFY.NOTIFY_STALL_ITEM_PRICE == data.notify then
       --[[ if DlgMgr:isDlgOpened("MarketSellItemDlg") then
            local dlg = DlgMgr:openDlg("MarketSellItemDlg")
            dlg:setPrice(data.para)
        end]]
    elseif NOTIFY.EQUIP_IDENTIFY == data.notify then
        local dlg = DlgMgr:openDlg("IdentifyShowDlg")
        dlg:setReward(data.para)
    elseif NOTIFY.NOTICE_FETCH_BONUS == data.notify then
        local dlg = DlgMgr:openDlg("GetPetDlg")
        dlg:setInfo(data.para)
    elseif NOTIFY.NOTICE_GET_ITEM_SUCCESS == data.notify then
        GiftMgr:pushOneGetItemInfo(data)
    elseif NOTIFY.NOTIFY_ZONE_HAS_NO_TEAM_QUIT == data.notify then
        -- 不可组队场景提示是否退出队伍
        gf:confirm(CHS[3004016], function()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ZONE_HAS_NO_TEAM_CONFIRM, 1)
        end, function()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ZONE_HAS_NO_TEAM_CONFIRM, 0)
        end)
    elseif NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == data.notify then
        self.initDataDone = true
        Client.connectAgain = true
        Client:setCanTipDisconnect(false)

        self.isLoadInitData = false
        DlgMgr:closeDlg("WaitDlg")

        self:setFirstLoginToday()
		-- 首充光效
        local welfareData = GiftMgr:getWelfareData()
        if not DistMgr:getIsSwichServer() and welfareData and welfareData["firstChargeState"] == 1 then
            local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
            if dlg then
                local btn = dlg:getControl("GiftsButton")
                local effect = btn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
                if not effect then
                    -- lixh2 WDSY-21401 帧光效修改为粒子光效：主界面按钮环绕光效
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.main_ui_btn, btn, Const.ARMATURE_MAGIC_TAG, 2, 0)
                end
            end
        end

        self.initDataTime = gfGetTickCount()
        DlgMgr:sendMsg("MissionDlg", "taskTop")

        RedDotMgr:loadRedDot()

        -- 设置本地最近联系人信息
        local needRefresh = FriendMgr:setTempFriendbyMem()

        if GameMgr.isEnterGameByLoginScene or needRefresh then
            -- 从登录界面上线
            -- needFefresh = true 有本地最近联系人被移除（主要处理从跨服区组返回源区组）
            -- 删除已不存在的好友或最近联系人的小红点
            RedDotMgr:delFriendRedDotInfo()
        end

        -- 刷道界面小红点检测
        RedDotMgr:checkShuaDaoRedDotForFirstLogin()

        -- 更新提升小红点
        PromoteMgr:NOTIFY_SEND_INIT_DATA_DONE(data)

        -- 更新节日小红点
        RedDotMgr:updateFestivalActivities()

        -- 更新福利活动小红点
        RedDotMgr:updateWelfareActivities()

        -- 如果有匹配信息，换线后继续发送匹配信息
        local teamMatchData = DistMgr:getCurMatchInfo()
        if teamMatchData and teamMatchData.state ~= 0 then
            if teamMatchData.state == 1 then
                TeamMgr:requstMatchTeam(teamMatchData.name)
            else
                TeamMgr:requestMatchMember(teamMatchData.name, teamMatchData.minLevel, teamMatchData.maxLevel, teamMatchData.polars, teamMatchData.minTao, teamMatchData.maxTao)
            end
        end
        DistMgr:setMatchInit()

        -- 处理自动登录事宜
        ShortcutMgr:doWhenEnterWorld()

        -- 如果不是换线
        if not DistMgr:getIsSwichServer() then
            if self.isEnterGameByLoginScene then
                -- 开启定位
                CitySocialMgr:doLocateWhenLogin()
            end

            -- 非换线首次登入福利小红点检测
            RedDotMgr:firstLoginForWelfareDlgRedDot()
        end

        -- 所有的消息都刷新完了
        DistMgr:setIsSwichServer(false)

        -- 请求重新打开着界面的数据
        self:doOpenDlgRequestData()

        EventDispatcher:dispatchEvent('SightTip')

        -- 加载好友界面
        if not DlgMgr:getDlgByName("FriendDlg") and SystemMessageMgr:getMailIsLoad()  then
            local dlg = DlgMgr:openDlg("FriendDlg")
            dlg:setVisible(false)

            if dlg.systemMessageDlg then
                dlg.systemMessageDlg:logReport()
        end
        else
            local dlg = DlgMgr:getDlgByName("FriendDlg")
            if dlg and dlg.systemMessageDlg and SystemMessageMgr:getMailIsLoad() then
                dlg.systemMessageDlg:logReport()
            end
        end

        -- InitDataDone完成后，清除isEnterGameByLoginScene状态
        -- 需要使用isEnterGameByLoginScene状态的操作（目前包括免责声明和离线刷道奖励）必须在此之前完成
        self.isEnterGameByLoginScene = false

        AutoWalkMgr:restoreAutoWalk(self:isAutoWalkWhenLoginDone())
        self:keepAutoWalkWhenLoginDone()

        if self.randomWalkInfoBeforeEnterBackground and self.randomWalkInfoBeforeEnterBackground.gid == Me:queryBasic("gid") then
            -- 有巡逻信息则恢复巡逻状态
            AutoWalkMgr:resumeRandomWalk(self.randomWalkInfoBeforeEnterBackground)
        end

        self.randomWalkInfoBeforeEnterBackground = nil

        -- 界面一些光效
        DlgMgr:sendMsg("SystemFunctionDlg", "addMarginInButton", "AnniversaryButton")
        DlgMgr:sendMsg("KidCultureDlg", "onOpenDlgRequestData")

        DlgMgr:resetMainDlgVisible()

        GoodVoiceMgr:removeLoadVoice()

        HomeChildMgr:setMainDlgVisibleFalse()

        -- 检查服务器
        self:checkServer()
    elseif NOTIFY.NOTIFY_OPEN_CONFIRM_DLG == data.notify then
        if data.para == "ChoseAtkDlg" then
            DlgMgr:openDlg("ChoseAtkDlg")
        else
        -- 弹出确认框
        gf:confirm(
            data.para,
            function() gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1}) end,
            function() gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0}) end,
            nil,
            nil,
            CONFIRM_TYPE.FROM_SERVER
        )
        end
    elseif NOTIFY.NOTIFY_GUARD_NEXT_FIGHTSCORE == data.notify then
        local paraList = gf:split(data.para, ":")
        local dlg = DlgMgr.dlgs["GuardStrengthDlg"]

        if dlg then
            dlg:refreshGuardNetLevelScore(tonumber(paraList[1]), paraList[2])
        end

        GuardMgr:setNextLevelGuardScore(tonumber(paraList[1]), paraList[2])
    elseif NOTIFY.NOTIFY_GUARD_GROW_OK == data.notify then
        local dlg = DlgMgr:getDlgByName("GuardDevelopDlg")
        if dlg then
        dlg:playDevelopEffect(data.para)
        end
    elseif NOTIFY.NOTIFY_EXORCISM_STATUS == data.notify then        -- 开启驱魔香状态
        if tonumber(data.para) == 1 then
            PracticeMgr:setIsUseExorcism(true)
        else
            PracticeMgr:setIsUseExorcism(false)
        end
    elseif NOTIFY.NOTIFY_BAOZANG_READY_SEARCH == notify then
        -- 检查
        if not InventoryMgr:getFirstEmptyPos() then
            gf:ShowSmallTips(CHS[3004017])
            return
        end

        if data.para == "normal_goon" or data.para == "chaoji_goon" then
            local baoz = InventoryMgr:getAmountByName(CHS[3004018])
            local super = InventoryMgr:getAmountByName(CHS[3004019])

            -- 服务器告知上次使用的是藏宝图/超级藏宝图
            if data.para == "chaoji_goon" then
                -- 是否继续使用超级藏宝图
                if super > 0 then
                    local tip = string.format(CHS[7001007], super)
                    gf:confirm(tip, function()
                        local posSuper = InventoryMgr:getItemPosByName(CHS[3004019]) or 10000
                        InventoryMgr:applyItem(posSuper, 1)
                    end, nil, nil, nil, nil, nil, nil, "baozang")
            end
           else
                -- 是否继续使用藏宝图
                if baoz > 0 then
                    local tip = string.format(CHS[3004020], baoz)
                    gf:confirm(tip, function()
                        local posBaoz = InventoryMgr:getItemPosByName(CHS[3004018]) or 10000
                            InventoryMgr:applyItem(posBaoz, 1)
                    end, nil, nil, nil, nil, nil, nil, "baozang")
                end
            end
        elseif data.para == "normal_goon_ex" then
            local posSuper = InventoryMgr:getItemPosByName(CHS[3004018]) or 10000
            InventoryMgr:applyItem(posSuper, 1)
        elseif data.para == "chaoji_goon_ex" then
            local posSuper = InventoryMgr:getItemPosByName(CHS[3004019]) or 10000
            InventoryMgr:applyItem(posSuper, 1)
                end
    elseif NOTIFY.NOTIFY_IOS_REVIEW == notify then
        -- 如果处于ios评审阶段，屏蔽部分功能
        self.isIOSReview = (data.para == "1")
    elseif NOTIFY.NOTIFY_HIDE_NPC == notify then
        -- 渐隐NPC
        local id = tonumber(data.para)
        CharMgr:fadeOutChar(id, 0.3)
    end
end

function GameMgr:MSG_OPEN_ELITE_PET_SHOP(data)
    -- 变异商店
    local dlg = DlgMgr:openDlgEx("ElitePetShopDlg", data.type)
    if data.count ~= 65535 then
        dlg:setPetListFromSer(data)
    else
        dlg:setPetListFromLoc()
    end
end

function GameMgr:MSG_PLAY_SCENARIOD(data)
    -- 打开剧本界面
    if 1 ~= data.isComplete then
        -- 隐藏所有按钮
        if not Me:isInCombat() and not Me:isLookOn() then
            DlgMgr:setAllDlgVisible(false, {["ShenmdgDlg"] = true})
        end

        DlgMgr:openDlg("DramaDlg")

        -- 站着，不要动！
        Me:setAct(Const.SA_STAND, true)

        -- 停止自动寻路
        AutoWalkMgr:endAutoWalk()
    end
end

-- 冻屏
function GameMgr:MSG_PLAY_SCREEN_EFFECT(data)
    gf:frozenScreen(data.duration * 1000)
end

-- 冻屏，duration为毫秒
function GameMgr:MSG_FROZEN_SCREEN(data)
    gf:frozenScreen(data.duration, nil, data.duration)
end

-- 淡入淡出效果
function GameMgr:MSG_NOTIFY_SCREEN_FADE(data)
    if data.type == 1 then
        -- 淡入
        -- 淡入后需等服务端通知淡出，先处理将冻屏效果延长
        local colorLayer = gf:frozenScreen(data.duration * 10 , 0, data.duration * 10, true)
        colorLayer:runAction(cc.FadeIn:create(data.duration / 1000))
    else
        -- 淡出
        local colorLayer = gf:frozenScreen(data.duration, 255, data.duration, true)
        colorLayer:runAction(cc.FadeOut:create(data.duration / 1000))
    end
end

function GameMgr:MSG_AUTO_WALK(data)
    DebugMgr:debugLog(string.format("MSG_AUTO_WALK:%s, DramaDlg:%s", tostringex(data), tostring(DlgMgr:getDlgByName("DramaDlg"))), data)

    -- 有剧本播放不自动寻路
    if DlgMgr:getDlgByName("DramaDlg") then return end

    -- 自动寻路
    local dest = data.dest
    local posInfo = gf:findDest(dest)
    if not posInfo then return end
    posInfo.curTaskWalkPath = { task_type = data.task_type, task_prompt = dest, from_server = true }

    -- 关闭npc对话框
    DlgMgr:closeDlg("NpcDlg")

    -- Me的onEnterScene在没有寻路消息的时候会将状态置为false
    -- 此时就会导致后到的MSG_AUTO_WALK在加载完成时无法恢复
    -- 此处重新标记，确保本次寻路可以在加载时恢复
    Me:setIsEnterScene(true)

    -- 自动寻路
    AutoWalkMgr:setNextDest(posInfo)
end

function GameMgr:MSG_NOTIFICATION(data)
    if NOTIFICATION.PARTY_REQUEST == data.type then
        RedDotMgr:insertOneRedDot("GameFunctionDlg", "PartyButton")
        local lastDlg = DlgMgr:getLastDlgByTabDlg("PartyInfoTabDlg")
        if not lastDlg then
            RedDotMgr:insertOneRedDot("PartyInfoTabDlg", "MemberCheckBox")
        else
            if lastDlg ~= "PartyMemberDlg" then
                RedDotMgr:insertOneRedDot("PartyInfoTabDlg", "MemberCheckBox")
            end
        end
        RedDotMgr:insertOneRedDot("PartyMemberDlg", "PartyRecruitCheckBox")
    elseif NOTIFICATION.REMOVE_REQUES == data.type then
        RedDotMgr:removeOneRedDot("PartyMemberDlg", "PartyRecruitCheckBox")
        RedDotMgr:removeOneRedDot("PartyInfoTabDlg", "MemberCheckBox")
        RedDotMgr:removeOneRedDot("GameFunctionDlg", "PartyButton")
    end
end

function GameMgr:MSG_OPEN_EXCHANGE_SHOP(data)
    if data.type == EXCHANGE_SHOP_TYPE.SKILL then
        local dlg = DlgMgr:openDlg("RowSkillShopDlg")
        dlg:updateSell(data)
        dlg:onDlgOpened()
    elseif data.type == EXCHANGE_SHOP_TYPE.PET then
        local dlg = DlgMgr:openDlg("PetShopDlg")
        dlg:setInfo(data)
    elseif data.type == EXCHANGE_SHOP_TYPE.NICE then
		DlgMgr:openDlgEx("GoodValueDlg", data)
    elseif data.type == EXCHANGE_SHOP_TYPE.WANG_ZHONG_WANG then
        local dlg = DlgMgr:openDlg("WangZWStoreDlg")
        dlg:updateSell(data)
    elseif data.type == EXCHANGE_SHOP_TYPE.JUNGONG then
        local dlg = DlgMgr:openDlg("JungongShopDlg")
        dlg:setInfo(data)
    end
end

function GameMgr:MSG_SUBMIT_PET(data)
    local dlg = DlgMgr:openDlg("SubmitPetDlg")
    local type = data.type
    if type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEISHENG then
        local pets = PetMgr:getPetsCanFly()
        dlg:setSubmintPet(pets, type)
    elseif type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_NORMAL then
        local pets = {}
        for i = 1, data.petCount do
            local petName = PetMgr:trimPetRawName(data.petNameList[i])

            -- 根据名字和类型显示所有满足提交条件的宠物,petType默认设置为野生
            -- 名字为原始名字
            local localPets = PetMgr:getPetByNameAndType(petName, data.petState)
            for j = 1, #localPets do
                table.insert(pets, localPets[j])
            end
        end

        dlg:setSubmintPet(pets, type)
    elseif type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEED then
        -- 饲养宠物提交
        local pets = PetMgr:getPetsNotFeed()
        dlg:setSubmintPet(pets, type)
    elseif type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_INNER_ALLCHEMY then
        -- 内丹宠物提交
        local petInfo = string.split(data.petNameList[1], "=")
        local pets = PetMgr:getPetByType(Const.PET_RANK_WILD, tonumber(petInfo[2]), tonumber(petInfo[1]), true, true)
        dlg:setSubmintPet(pets, type)
    end
end

function GameMgr:MSG_LEVEL_UP(data)
    if Me:getId() == data.id and data.level % 10 == 0 then
        DlgMgr:openDlg("RookieGiftDlg")
    end

    if Me:getId() == data.id then
        if data.level == 19 and not gf:isWindows() then
            -- 升到19级后，预加载微社区，保证20级指引时能直接显示网页
            CommunityMgr:addCommunityUrlSuffix(CommunityMgr:getCommunityUrlGuideSuffix())
            CommunityMgr:setPreLoadCommunityType(PRELOAD_COMMUNITY_TYPE.GUIDE)
            CommunityMgr:askForOpenCommunityDlg()
        elseif data.level == 20 then
            local dlg = DlgMgr:getDlgByName("HeadDlg")
            local magic = gf:createLoopMagic(ResMgr.magic.headDlg_magic)
            magic:setName(ResMgr.magic.headDlg_magic)
            local ctrl = dlg:getControl("PlayerPanel")
            ctrl:addChild(magic)

            DlgMgr:openDlg("HeadTipsDlg")
        end
    end
end

function GameMgr:MSG_OPEN_AUTO_MATCH_TEAM(data)
    DlgMgr:openDlg("TeamDlg")
    if data.dlgType == 1 then
        local dlg = DlgMgr:openDlg("TeamQuickDlg")
        if data.keyName == CHS[3004028] then
            data.keyName = CHS[3004029]
            dlg:selectItemEx(data.keyName)
            dlg:scrollToItem(data.keyName)
            return
        end
        if data.keyName == CHS[3002192] then
            data.keyName = CHS[4000362]
        end
        local oneName = dlg:getOneName(data.keyName)
        dlg:selectItemEx(oneName, data.keyName)
        dlg:scrollToItem(oneName, data.keyName)
    else
        local dlg = DlgMgr:openDlg("TeamAdjustmentDlg")
        if data.keyName == CHS[3004028] then
            data.keyName = CHS[3004029]
            dlg:selectItemEx(data.keyName)
            dlg:scrollToItem(data.keyName)
            return
        end
        if data.keyName == CHS[3002192] then
            data.keyName = CHS[4000362]
        end
        local oneName = dlg:getOneName(data.keyName)
        dlg:selectItemEx(oneName, data.keyName)
        dlg:scrollToItem(oneName, data.keyName)
    end
end

-- 是否在帮战中
function GameMgr:isInPartyWar()
    if MapMgr.mapData and MapMgr.mapData.map_name == CHS[3004030] then
        return true
    end

    -- 新帮主地图
    if MapMgr.mapData and (MapMgr.mapData.map_name == CHS[4000414] or MapMgr.mapData.map_name == CHS[4000420] or MapMgr.mapData.map_name == CHS[4000421]) then
        return true
    end

    return false
end

-- 获取该玩家的存储入境
-- folderName 为自己子文件的名字
function GameMgr:getChatPath(folderName)
    local gid = Me:queryBasic("gid")

    if gid then
        if folderName then
            return Const.WRITE_PATH .. gid .. "/" .. folderName
        else
            return Const.WRITE_PATH .. gid .. "/"
        end
    end

    return ""
end

function GameMgr:MSG_TEAM_ASK_ASSURE(data)
    -- 服务器发过来的是时间戳，需要在此转换成倒计时毫秒数
    data.time = (data.time - gf:getServerTime()) * 1000

    if data.dlgName == "" then
        local dlg = DlgMgr:openDlg("DugeonVoteDlg")
        dlg:setTitle(data)
    else
        local dlg = DlgMgr:openDlg(data.dlgName)
        dlg:setTitle(data)
    end

    if TeamMgr:getLeaderId() ~= Me:getId() then
        FriendMgr:playMessageSound()
    end
end

function GameMgr:MSG_TEAM_ASK_CANCEL(data)

end

-- 打开八仙梦境
function GameMgr:MSG_BAXIAN_MENGJING_INFO(data)
    if data.isOpenDlg == 1 then
        local dlg = DlgMgr:openDlg("EightImmortalsDlg")
        dlg:setDataInfo(data)
    else
        local dlg = DlgMgr:getDlgByName("EightImmortalsDlg")
        if dlg then
            dlg:setDataInfo(data)
        end
    end
end

-- 刷新选择奖励的数据
function GameMgr:MSG_SELECT_BONUS_DATA(data)
    if 1 == data.dlg_type then
        local dlg = DlgMgr:openDlg("SelectDlg")
        local durTime = data.during_ti
        dlg:setData(data.tips, durTime, data.source)
    elseif 2 == data.dlg_type then
        gf:confirm(data.tips, function()
            gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = data.source, select = "ok" })
        end, function()
            gf:CmdToServer("CMD_SELECT_BONUS_RESULT", { source = data.source, select = "cancel" })
        end, nil, data.during_ti, nil, nil, nil, data.source)
    end
end

-- 关闭选择奖励界面
function GameMgr:MSG_SELECT_BONUS_CANCEL(data)
    local dlg = DlgMgr:getDlgByName("SelectDlg")
    if dlg then
        if dlg.source == data.source then
            DlgMgr:closeDlg("SelectDlg")
        end
    end

    gf:closeConfirmByType(data.source)
end

function GameMgr:MSG_LOGIN_DONE(data)
    -- WDSY-27017 修改
    self.isLoadInitData = true
    DlgMgr:openDlg("WaitDlg")

    if GMMgr:isStaticMode() then
        Me.realId = Me:getId()
    else
        Me.realId = nil
    end

    self:setLoginRole(data.gid)

    GameMgr:clearData(true, self.isRefreshUserData)

    -- 清空设置
    SystemSettingMgr:initServerSet()

    -- 将登入状态设置为，可顶号
    Client:setReplaceData(0)
end

-- 检查服务器
function GameMgr:checkServer()
    if 'function' ~= type(gfGenCheckText) then return end
    local buf = gfGenCheckText(Const.PUBLIC_KEY, 1)
    checkServerCookie = checkServerCookie + 1
    gf:CmdToServer("CMD_CHECK_SERVER", { buf = buf, cookie = checkServerCookie })
    if self.checkServerAction and self.scene then
        self.scene:stopAction(self.checkServerAction)
    end
    self.checkServerAction = nil
    self.checkServerAction = performWithDelay(self.scene, function()
        self:MSG_CHECK_SERVER()
    end, 100)
end

-- 设置当前登录的角色的 gid 和 name，并判断是否有更换角色
-- 只适用刚登录的判断，重连后 self.isChangeRoleLogin 必为 false
function GameMgr:setLoginRole(gid)
        if self.lastLoginRoleGid and  self.lastLoginRoleGid ~= gid then
            self.isChangeRoleLogin = true
        else
            self.isChangeRoleLogin = false
    end

    if self.isChangeRoleLogin then
        EventDispatcher:dispatchEvent("EVENT_CHANGE_ROLE_LOGIN")
    end

    self.lastLoginRoleGid = gid
end

-- 设置当天是否第一次登入，以05：00为准
-- 换线、重连属于重新登录，isFirstLoginToday 会为 false
function GameMgr:setFirstLoginToday()
    local lastTime = cc.UserDefault:getInstance():getIntegerForKey("isNewDay" .. gf:getShowId(Me:queryBasic("gid")))
    local serTime = gf:getServerTime()

    if lastTime == 0
        or tonumber(gf:getServerDate("%d", lastTime - 5 * 60 * 60)) ~= tonumber(gf:getServerDate("%d", serTime - 5 * 60 * 60)) then
        cc.UserDefault:getInstance():setIntegerForKey("isNewDay" .. gf:getShowId(Me:queryBasic("gid")), serTime)
        GameMgr.isFirstLoginToday = true
    else
        GameMgr.isFirstLoginToday = false
    end
end

-- 此功能暂未实现
function GameMgr:MSG_FLOAT_DIALOG(data)
end

function GameMgr:MSG_NOTIFY_SECURITY_CODE(data)
    self.isAntiCheat = true

    self.lastSecurityTime = self.lastSecurityTime or 0

    if Me:isInCombat() and FightMgr:hasRecvEndCombatMsg() then
        FightMgr:CleanAllAction()
    end

    if Me:isTeamLeader() then
        local dlg = DlgMgr:getDlgByName("LordLaoZiDlg")
        if dlg then
            dlg:refreshChoice(data)
        else
            dlg = DlgMgr:openDlg("LordLaoZiDlg")
            dlg:refreshChoice(data)
        end
    else
        local dlg = DlgMgr:getDlgByName("LordLaoZiMemberDlg")
        if not dlg then
            if data.triggerTime ~= self.lastSecurityTime then
                -- 如果本次没有弹出过，才显示
                local dlg = DlgMgr:openDlg("LordLaoZiMemberDlg")
                dlg:setData(data)
            end
        else
            dlg:setData(data)
        end
    end

    self.lastSecurityTime = data.triggerTime
    -- 停止自动寻路
    AutoWalkMgr:stopAutoWalk()
end

function GameMgr:MSG_FINISH_SECURITY_CODE(data)
    self.isAntiCheat = false
end

function GameMgr:isShiDaoServer()
    if 0 ~= curServerId then
        for k, v in pairs(shidaoServerList) do
            if curServerId == v then
                return true
            end
        end
    end

    return false
end

function GameMgr:clearServer()
    shidaoServerList = {}
    curServerId = 0
end

-- 检查网路状态
function GameMgr:checkNetworkState()
    if Client:hasNetworkStateChanged() then
        local msg = CHS[2200016]
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
        Client:markNetworkStateChanged(nil)
    end
end

function GameMgr:MSG_SPECIAL_SERVER(data)
    shidaoServerList = data.serverIdList
    curServerId = data.curLoginServerId
end

function GameMgr:MSG_PLAY_SOUND(data)
    SoundMgr:playEffect(data.sound)
end

function GameMgr:MSG_REPLY_SERVER_TIME(data)
    GameMgr.serverTime = data.server_time
    GameMgr.clientTime = data.client_time
    GameMgr.serverTimeZone= data.time_zone
end

-- 更新服务时间(2分钟更新一次)
function GameMgr:refreshServerTime()
    if self:isEnterGameOK() and (not self.lastRefreshServerTiem or gf:getTickCount() - self.lastRefreshServerTiem >= (2 * 60 * 1000)) then
        gf:CmdToServer("CMD_ASK_SERVER_TIME", {})
        self.lastRefreshServerTiem = gf:getTickCount()
    end
end

-- 处理换线后，界面还打开请求数据
function GameMgr:doOpenDlgRequestData()
    EventDispatcher:dispatchEvent("doOpenDlgRequestData")
end

function GameMgr:MSG_MOONCAKE_GAMEBLING_RESULT(data)
end

-- type 0： 物品提交， 1： 宠物提交
function GameMgr:MSG_SUBMIT_MULTI_ITEM(data)
    if data.type == 0 then
        local itemList = {}
        for i = 1, data.count do
            local item =  InventoryMgr:getItemById(data.list[i])
            if item then
                table.insert(itemList, item)
            end
        end

        local dlg = DlgMgr:openDlg("SubmitMultiItemDlg")
        dlg:setData(itemList, data.limitNum)
    elseif data.type == 1 then
        --[[
        local pets = {}
        for i = 1, data.count do
            local pet = PetMgr:getPetById(data.list[i])

            if pet then
                table.insert(pets, pet)
            end
        end

        local dlg = DlgMgr:openDlg("SubmitPetDlg")
        dlg:setSubmintPet(pets, "jingguai")
        --]]
    elseif data.type == 2 then
        local dlg = DlgMgr:openDlg("PetHorseTameDlg")
    end
end

function GameMgr:MSG_CONFIRM(data)

    -- 如果是弹出确认框，则停止新手指引
    if GuideMgr:isRunning() then
        GuideMgr:closeCurrentGuide()
    end

    if data.para_str ~= "" and data.para_str ~= "{}" then
        -- 当前只用于聚宝斋
        DlgMgr:openDlgEx("JuBaoSellConfirmDlg", data)
        return
    end


    local tips = data.tips
    local count = nil
    if data.down_count ~= 0 then
        count = data.down_count
    end

    if tips == "ChoseAtkDlg" then
        DlgMgr:openDlg("ChoseAtkDlg")
    elseif tips == "CoagulationChildDlg" then
        DlgMgr:openDlg("CoagulationChildDlg")
    elseif tips == "UserUpgradeDlg" then
        DlgMgr:openDlg("UserUpgradeDlg")
    elseif tips == "UserChangeUpgradeDlg" then
        DlgMgr:openDlg("UserChangeUpgradeDlg")
    elseif tips == "trading_spot_bid_one_plan" then
        DlgMgr:openDlg("TradingSpotShareBuyPlanDlg")
    elseif data.confirmText ~= "" and data.cancelText ~= "" then
        local onlyConfirm
        if data.only_confirm and data.only_confirm == 1 then
            onlyConfirm = true
        end

        local confirmText, cancelText = data.confirmText, data.cancelText
        gf:confirmEx(
            tips,
            confirmText,
            function() gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1}) end,
            cancelText,
            function(input, isCloseBtn)
                -- 点击取消
                if isCloseBtn then
                    -- 点击X按钮的取消
                    if data.confirm_type == "return_extra" then
                        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 2})
                    else
                        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
                    end
                else
                    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
                end
            end,
            nil,
            count,
            CONFIRM_TYPE.FROM_SERVER,
            nil,
            onlyConfirm,
            data.confirm_type,
            data.show_dlg_mode,
            data.countDownTips,
            data.no_close_btn == 1
        )
    else
        local onlyConfirm
        if data.only_confirm and data.only_confirm == 1 then
            onlyConfirm = true
        end

        gf:confirm(
            tips,
            function() gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 1}) end,
            function(input, isCloseBtn)
                -- 点击取消
                if isCloseBtn then
                    -- 点击X按钮的取消
                    if data.confirm_type == "return_extra" then
                        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 2})
                    else
                        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
                    end
                else
                    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
                end
            end,
            nil,
            count,
            CONFIRM_TYPE.FROM_SERVER,
            nil,
            onlyConfirm,
            data.confirm_type,
            data.show_dlg_mode,
            data.countDownTips,
            data.no_close_btn == 1
        )
    end
end

function GameMgr:MSG_OPEN_URL(data)
    if data.text == "" then
        DeviceMgr:openUrl(data.url)
        return
    end

    local dlg = gf:confirm(data.text,function ()
        DeviceMgr:openUrl(data.url)
    end)

    dlg:setCancleText(data.str_cancel)
    dlg:setConfirmText(data.str_confirm)
end

GameMgr:init()

-- 过图停止播放音效
function GameMgr:MSG_ENTER_ROOM()
    self:stopCurNpcSound()
end

function GameMgr:stopCurNpcSound()
    SoundMgr:stopEffectExById(self.playNpcSoundId)
    self.playNpcSoundId = nil
end

-- 停止播放当前全部音效
function GameMgr:stopCurAllSound()
    SoundMgr:stopCurAllSound()
    self.playNpcSoundId = nil
end

function GameMgr:MSG_OPEN_SMS_VERIFY_DLG(data)
    if not data then return end

    local dlg = DlgMgr:getDlgByName("AuthenticatePhoneDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("AuthenticatePhoneDlg")
    end

    dlg:setData(data)
end

function GameMgr:MSG_OPEN_FOOL_PLAYER_GIFT(data)
    local dlgName = data.type
    local dlg = DlgMgr:openDlg(dlgName)
    dlg:setData(data)
end

function GameMgr:MSG_OPEN_CHAT_DLG(data)
    if not FriendMgr:isBlackByGId(data.gid) then
        local dlg = FriendMgr:openFriendDlg()
        dlg:setChatInfo({name = data.name, gid = data.gid, level = data.level})
    end
end

function GameMgr:MSG_PET_UPGRADE_PRE_INFO(data)
    local dlg = DlgMgr:openDlg("PetFlyItemDlg")
    dlg:setPetInfo(data)
end

function GameMgr:MSG_PET_UPGRADE_SUCC(data)
    DlgMgr:closeDlg("PetFlyItemDlg")
    DlgMgr:openDlgEx("PetFlyDoneDlg", data)
end

function GameMgr:MSG_RARE_SHOP_ITEMS_INFO(data)
    local dlg = DlgMgr.dlgs["ValueShopDlg"]
    if dlg then return end

    DlgMgr:openDlg("ValueShopDlg")
end

function GameMgr:MSG_SINGLES_2017_GOODS_LIST(data)
    if not DlgMgr:getDlgByName("GuanggdbDlg") then
        local dlg = DlgMgr:openDlg("GuanggdbDlg")
        dlg:setData(data)
    end
end

function GameMgr:MSG_OPERATE_RESULT(data)
    gf:displaySuccessOrFaildMagic(data.flag == 1)
end

function GameMgr:MSG_CHECK_SERVER(data)
    if 'function' ~= type(gfCheckText) or (data and data.cookie ~= checkServerCookie) then return end
    if not data or not gfCheckText(data.buf, Const.PUBLIC_KEY, 1) then
        local msg = data and CHS[2000126] .. "(1)" or CHS[2000126] .. "(2)"
        if self.scene then
            performWithDelay(self.scene, function()
        MessageMgr:pushMsg({ MSG = 0xD09D, tip = msg })
        MessageMgr:pushMsg({ MSG = 0x1368, result = false })
            end, 3) -- 3s后自动断开
    end
        gf:CmdToServer("CMD_KICK_OFF_CLIENT", {reason = msg})    -- 通知服务器校验失败原因
    end

    if self.checkServerAction and self.scene then
        self.scene:stopAction(self.checkServerAction)
    end
        self.checkServerAction = nil
end

function GameMgr:MSG_EXCHANGE_EPIC_PET_SHOP(data)
    local dlg = DlgMgr:openDlgEx("ElitePetShopDlg", 3)
end

function GameMgr:MSG_EXCHANGE_EPIC_PET_CHECK_EXIT(data)
    if not DlgMgr:getDlgByName("ElitePetShopDlg") then
        gf:CmdToServer("CMD_EXCHANGE_EPIC_PET_EXIT")
    end
end

function GameMgr:MSG_EXCHANGE_EPIC_PET_SUBMIT_DLG(data)
    DlgMgr:openDlgEx("ExchangeByDlg", data.target_name)
end

function GameMgr:MSG_HTTP_TOKEN(data)
    WatchMgr:setHttpToken(data)
end

MessageMgr:regist("MSG_SINGLES_2017_GOODS_LIST", GameMgr)

MessageMgr:hook("MSG_ENTER_ROOM", GameMgr, "GameMgr")

MessageMgr:hook("MSG_LEVEL_UP", GameMgr, "GameMgr")
MessageMgr:regist("MSG_REPLY_SERVER_TIME", GameMgr)
MessageMgr:regist("MSG_OPEN_AUTO_MATCH_TEAM", GameMgr)
MessageMgr:regist("MSG_SUBMIT_PET", GameMgr)
MessageMgr:regist("MSG_ENTER_GAME", GameMgr)
MessageMgr:regist("MSG_MENU_LIST", GameMgr)
MessageMgr:regist("MSG_MENU_CLOSED", GameMgr)
MessageMgr:regist("MSG_GOODS_LIST", GameMgr)
MessageMgr:regist("MSG_ASK_BUY_ONLINE_ITEM", GameMgr)
MessageMgr:regist("MSG_GENERAL_NOTIFY", GameMgr)
MessageMgr:regist("MSG_PLAY_SCENARIOD", GameMgr)
MessageMgr:regist("MSG_AUTO_WALK", GameMgr)
MessageMgr:regist("MSG_OPEN_ELITE_PET_SHOP", GameMgr)
MessageMgr:regist("MSG_NOTIFICATION", GameMgr)
MessageMgr:regist("MSG_OPEN_EXCHANGE_SHOP", GameMgr)
MessageMgr:regist("MSG_TEAM_ASK_ASSURE", GameMgr)
MessageMgr:regist("MSG_TEAM_ASK_CANCEL", GameMgr)
MessageMgr:regist("MSG_BAXIAN_MENGJING_INFO", GameMgr, "GameMgr")
MessageMgr:regist("MSG_FLOAT_DIALOG", GameMgr)
MessageMgr:regist("MSG_LOGIN_DONE", GameMgr)
MessageMgr:regist("MSG_NOTIFY_SECURITY_CODE", GameMgr)
MessageMgr:regist("MSG_FINISH_SECURITY_CODE", GameMgr)
MessageMgr:regist("MSG_SPECIAL_SERVER", GameMgr)
MessageMgr:regist("MSG_PLAY_SOUND", GameMgr)
MessageMgr:regist("MSG_MOONCAKE_GAMEBLING_RESULT", GameMgr)
MessageMgr:regist("MSG_SUBMIT_MULTI_ITEM", GameMgr)
MessageMgr:regist("MSG_CONFIRM", GameMgr)
MessageMgr:regist("MSG_OPEN_URL", GameMgr)
MessageMgr:regist("MSG_OPEN_SMS_VERIFY_DLG", GameMgr)
MessageMgr:regist("MSG_OPEN_FOOL_PLAYER_GIFT", GameMgr)
MessageMgr:regist("MSG_OPEN_CHAT_DLG", GameMgr)
MessageMgr:regist("MSG_PET_UPGRADE_PRE_INFO", GameMgr)
MessageMgr:regist("MSG_PET_UPGRADE_SUCC", GameMgr)
MessageMgr:regist("MSG_RARE_SHOP_ITEMS_INFO", GameMgr)
MessageMgr:regist("MSG_PLAY_SCREEN_EFFECT", GameMgr)
MessageMgr:regist("MSG_SELECT_BONUS_CANCEL", GameMgr)
MessageMgr:regist("MSG_SELECT_BONUS_DATA", GameMgr)
MessageMgr:regist("MSG_OPERATE_RESULT", GameMgr)
MessageMgr:regist("MSG_FROZEN_SCREEN", GameMgr)
MessageMgr:regist("MSG_NOTIFY_SCREEN_FADE", GameMgr)
MessageMgr:regist("MSG_CHECK_SERVER", GameMgr)
MessageMgr:regist("MSG_EXCHANGE_EPIC_PET_SHOP", GameMgr)
MessageMgr:regist("MSG_EXCHANGE_EPIC_PET_CHECK_EXIT", GameMgr)
MessageMgr:regist("MSG_EXCHANGE_EPIC_PET_SUBMIT_DLG", GameMgr)
MessageMgr:regist("MSG_HTTP_TOKEN", GameMgr)
