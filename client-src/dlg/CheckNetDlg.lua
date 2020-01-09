-- CheckNetDlg.lua
-- Created by sujl, Aug/29/2017
-- 检测网络界面

require("mgr/CheckNetMgr")

local json = require("json")

-- 获取有效区域
local function getWinSize()
    local WINSIZE = cc.Director:getInstance():getWinSize()
    local winSize = DeviceMgr:getUIScale() or { width = WINSIZE.width, height = WINSIZE.height, x = 0, y = 0 }
    return winSize
end

local CheckNetDlg = class("CheckNetDlg", function()
    return ccui.Layout:create()
end)

-- 背景颜色
local BLANK_COLOR = cc.c4b(0, 0, 0, 153)
local DeviceMgr = require("mgr/DeviceMgr")

local CHECK_TYPE = {
    UPDATE = 1,
    GAME = 2,
    SEND = 3,
}

local CHECK_STATE = {
    NONE = 0,
    PREPARE = 1,        -- 准备就绪
    PROCESSING = 2,     -- 正在检测
    SUCC = 3,           -- 成功
    FAILED = 4,         -- 失败
}

-- 调用 java 函数
local callJavaFun = function(fun, sig, args)
    local luaj = require('luaj')
    local className = 'org/cocos2dx/lua/AppActivity'
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        gf:ShowSmallTips("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 调用 iOS SDK 函数
local callOCSdkFun = function (fun, args)
    local luaoc = require('luaoc')
    local ok, ret = luaoc.callStaticMethod('AppController', fun, args)
    if not ok then
        return "fail"
    end

    Log:I('callOCFun %s, ret: %s', fun, tostring(ret))
    return ret
end

-- 检测网络
local function checkNetwork(node, callback)
    local state = DeviceMgr:getNetWorkStatus()

    if 'function' == type(callback) then
        callback(0 ~= state and CHECK_STATE.SUCC or CHECK_STATE.FAILED)
    end
end

-- 检测配置服务器
local function checkCfgServer(node, callback)
    local host
    if gfIsDebug() and cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
        host = "10.2.51.97"
    else
        host = "update.leiting.com"
    end
    local addrInfo, _ = CheckNetMgr:getIpByHost(host)
    if addrInfo then
        local addr = addrInfo
        local r = {}
        CheckNetMgr:ping(function(s)
            table.insert(r, s)
        end, addr, 1, 5)

        s = table.concat(r, '\n')
        local begin = string.find(s, "receive from") or string.find(s, "bytes from") or string.find(s, CHSUP[2300004])
        if 'function' == type(callback) then
            if begin then
                callback(CHECK_STATE.SUCC)
            else
                callback(CHECK_STATE.FAILED)
            end
        end
    end
end

-- 检测补丁服务器
local function checkPatchServer(node, callback)
    local host
    if gfIsDebug() and cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
        host = "10.2.51.97"
    else
        host = "atmdl.leiting.com"
    end
    local addrInfo, _ = CheckNetMgr:getIpByHost(host)
    if addrInfo then
        local addr = addrInfo
        local r = {}
        CheckNetMgr:ping(function(s)
            table.insert(r, s)
        end, addr, 1, 5)

        s = table.concat(r, '\n')
        local begin = string.find(s, "receive from") or string.find(s, "bytes from") or string.find(s, CHSUP[2300004])
        if 'function' == type(callback) then
            if begin then
                callback(CHECK_STATE.SUCC)
            else
                callback(CHECK_STATE.FAILED)
            end
        end
    end
end

-- 检测游戏服务器
local function checkGameServer(node, callback)
    performWithDelay(node, function()
        if not Client._isConnectingGS then
            callback(CHECK_STATE.FAILED)
        else
            callback(CHECK_STATE.SUCC)
        end
    end, 1)
end

local function checkGameTip()
    local host
    if gfIsDebug() and cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
        host = "10.2.51.97"
    else
        host = "www.baidu.com"
    end
    local ip = CheckNetMgr:getIpByHost(host)
    local t1 = gfGetTickCount()
    local isSucc
    CheckNetMgr:ping(function(s)
        local start, _ = string.find(s, "receive from") or string.find(s, "bytes from") or string.find(s, CHSUP[2300004])
        if start then isSucc = true end
    end, ip, 1, 5)
    local t2 = gfGetTickCount()

    if isSucc then
        if t2 - t1 > 300 then
            return CHSUP[2300005]
        end
    end

    if Client:getLastDelayTime() > 300 then
        return CHSUP[2300008]
    end

    return CHSUP[2300023]
end

local function checkSendLog(self, callback)
    if not self.data then return end

    local runScene =  cc.Director:getInstance():getRunningScene()
    runScene:checkNetConnection(function(msg)
        local account = cc.UserDefault:getInstance():getStringForKey("user",  "a")
        self.data['account'] = account

        for k, v in pairs(msg) do
            self.data[k] = v
        end

        CheckNetMgr:logReportNetCheck(self.data, function(info)
            if not self.data then return end

            local item = self:getItemPanel(self.curIndex)

            if "success" == info.status then
                callback(CHECK_STATE.SUCC)
                self:setLabelText("Label", string.format(CHSUP[2200006], info.id), item)
            else
                callback(CHECK_STATE.FAILED)
            end
        end)
    end)
end

local function checkSendLogSucc()
    return CHSUP[2200005]
end

local UPDATE_CHECK = {
    {content = CHSUP[2300009], func = checkNetwork, succ_item_tip = CHSUP[2300010], fail_item_tip = CHSUP[2300011], fail_tip = CHSUP[2300012]},
    {content = CHSUP[2300013], func = checkCfgServer, succ_item_tip = CHSUP[2300014], fail_item_tip = CHSUP[2300015], fail_tip = CHSUP[2300007], fail_tip_emu = CHSUP[2300006] },
    {content = CHSUP[2300016], func = checkPatchServer, succ_item_tip = CHSUP[2300017], fail_item_tip = CHSUP[2300018], fail_tip = CHSUP[2300007], fail_tip_emu = CHSUP[2300006] },
}

local GAME_CHECK = {
    {content = CHSUP[2300009], func = checkNetwork, succ_item_tip = CHSUP[2300010], fail_item_tip = CHSUP[2300011], fail_tip = CHSUP[2300012]},
    {content = CHSUP[2300019], func = checkGameServer, succ_item_tip = CHSUP[2300020], fail_item_tip = CHSUP[2300021], fail_tip = CHSUP[2300007], func_tip = checkGameTip, fail_tip_emu = CHSUP[2300006]},
}

local SEND_CHECK = {
    {content = CHSUP[2200007], func = checkSendLog, func_tip = checkSendLogSucc, fail_item_tip = CHSUP[2200008], dontRefreshLine = true, fail_tip = CHSUP[2200009] },
}

function CheckNetDlg.create(type, callback, data)
    local dlg = CheckNetDlg.new(type, callback, data)
    return dlg
end

function CheckNetDlg:ctor(type, callback, data)
    local size = cc.Director:getInstance():getWinSize()
    self.callback = callback

    local uiScale = Const and Const.UI_SCALE or 1
    self.isEmulator = DeviceMgr:isEmulator()    -- 获取模拟器标志
    -- self.isEmulator = true -- for test
    self.data = data

    self.blank = ccui.Layout:create()
    self.blank:setContentSize(size.width / uiScale, size.height / uiScale)
    self:addChild(self.blank)

    -- 响应 函数
    local function onDealTouch(sender, event)
        return true
    end

    -- 添加监听
    if self.blank then
        -- 创建监听事件
        local listener = cc.EventListenerTouchOneByOne:create()

        -- 设置是否需要传递
        listener:setSwallowTouches(not isSwallow)
        listener:registerScriptHandler(onDealTouch, cc.Handler.EVENT_TOUCH_BEGAN)

        -- 添加监听
        local dispatcher = self.blank:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self.blank)
    end

    local colorLayer = cc.LayerColor:create(BLANK_COLOR)
    colorLayer:setContentSize(self.blank:getContentSize())
    self.blank:addChild(colorLayer)
    self.blank.colorLayer = colorLayer

    local jsonName =  "ui/CheckNetDlg.json"
    local winSize = getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    self.root:setAnchorPoint(0.5, 0.5)
    self.root:setPosition(size.width / 2 + winSize.x, size.height / 2 + winSize.y)
    self.blank:addChild(self.root)

    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("ReTryButton", self.onReTryButton)

    self:setCtrlVisible("SubmitButton", nil ~= self.data)
    self:setCtrlVisible("ReTryButton", nil == self.data)

    if type == CHECK_TYPE.UPDATE then
        self.checkData = UPDATE_CHECK
    elseif type == CHECK_TYPE.GAME then
        self.checkData = GAME_CHECK
    end

    self:setCtrlVisible("LineImage_1", true)
    self:setCtrlVisible("LineImage_2", true)
    self:setState(self:getControl("LineImage_1"), CHECK_STATE.PREPARE)
    self:setState(self:getControl("LineImage_2"), CHECK_STATE.PREPARE)
    self:initStepPanel()
    self.curState = {}
    for i = 1, #(self.checkData) do
        table.insert(self.curState, CHECK_STATE.NONE)
    end

    self:setCtrlVisible("NotePanel", false)
    self.lastCheckTime = nil
    self.curIndex = nil
    self.allState = nil
    performWithDelay(self, function() self:doCheckNet() end, 0)

    local function onNodeEvent(event)
        if "cleanup" == event then
            self:cleanup()
        end
    end

    self.root:registerScriptHandler(onNodeEvent)
end

function CheckNetDlg:cleanup()
    self.lastCheckTime = nil
    self.curIndex = nil
    self.data = nil
end

function CheckNetDlg:close()
    if 'function' == type(self.callback) then
        self.callback(self:isSucc())
        self.callback = nil
    end

    self:removeFromParent()
end

function CheckNetDlg:initStepPanel()
    self:setCtrlVisible("LoginStepPanel", self.checkData == UPDATE_CHECK, "StepPanel")
    self:setCtrlVisible("GameStepPanel", self.checkData == GAME_CHECK, "StepPanel")
    self:setCtrlVisible("SendStepPanel", self.checkData == SEND_CHECK, "StepPanel")

    local item
    for i = 1, #(self.checkData) do
        item = self:getItemPanel(i)
        self:setLabelText("Label", self.checkData[i].content, item)
        self:setState(item, CHECK_STATE.PREPARE)
    end
end

function CheckNetDlg:isSucc()
    local succ = true
    for i = 1, #self.curState do
        succ = succ and self.curState[i] == CHECK_STATE.SUCC
    end
    return succ
end

function CheckNetDlg:getItemPanel(index)
    local rootPanel
    if self.checkData == UPDATE_CHECK then
        rootPanel = self:getControl("LoginStepPanel", nil, "StepPanel")
    elseif self.checkData == GAME_CHECK then
        rootPanel = self:getControl("GameStepPanel", nil, "StepPanel")
    elseif self.checkData == SEND_CHECK then
        rootPanel = self:getControl("SendStepPanel", nil, "StepPanel")
    end

    if rootPanel then
        return self:getControl("StepPanel_" .. index, nil, rootPanel)
    end
end

-- 检测网络
function CheckNetDlg:doCheckNet()
    local cnt = #(self.checkData)
    self.curIndex = self.curIndex or 1
    self.allState = nil
    local item = self:getItemPanel(self.curIndex)
    if not item or self.curIndex > cnt then return end
    local itemData = self.checkData[self.curIndex]
    if not itemData then return end

    -- 进入测试状态
    self:setState(item, CHECK_STATE.PROCESSING)

    if not itemData.dontRefreshLine then
        if 1 == self.curIndex then
            self:setCtrlVisible("LineImage_1", true)
            self:setState(self:getControl("LineImage_1"), CHECK_STATE.PROCESSING)
        else
            self:setCtrlVisible("LineImage_2", true)
            self:setState(self:getControl("LineImage_2"), CHECK_STATE.PROCESSING)
        end
    end

    if 'function' == type(itemData.func) then
        -- 延时一下，给界面刷新的机会
        performWithDelay(self, function()
            self.lastCheckTime = gfGetTickCount()
            itemData.func(self, function(state)
                -- 做个延迟，避免由于速度过快导致显示体验不好
                local delayTime = self.lastCheckTime and math.max(1 - (gfGetTickCount() - self.lastCheckTime) / 1000, 0) or 0
                performWithDelay(self, function()
                    -- 测试完成
                    self.curState[self.curIndex] = state
                    self:setState(item, state)
                    local item_tip
                    if CHECK_STATE.SUCC == state then
                        item_tip = itemData.succ_item_tip
                    else
                        item_tip = itemData.fail_item_tip
                    end
                    if item_tip then
                        self:setLabelText("Label", item_tip, item)
                    end

                    if not itemData.dontRefreshLine then
                        if checkNetwork == itemData.func then
                            self:setCtrlVisible("LineImage_1", true)
                            self:setState(self:getControl("LineImage_1"), state)
                        else
                            self:setCtrlVisible("LineImage_2", self.curIndex > 1)
                            self:setState(self:getControl("LineImage_2"), self:isSucc() and CHECK_STATE.SUCC or CHECK_STATE.FAILED)
                        end
                    end

                    if CHECK_STATE.SUCC ~= state then
                        local fail_tip = self:getFailTip(itemData)
                        if fail_tip then
                            self:setLabelText("Label", fail_tip, "NotePanel")
                            self:setCtrlVisible("NotePanel", true)
                        end
                        self.allState = CHECK_STATE.FAILED
                        return
                    end

                    if self:moveNext() then
                        self:doCheckNet()
                    else
                        -- 所有都完成了
                        local tip = CHSUP[2300022]
                        if itemData.func_tip then
                            tip = itemData.func_tip() or tip
                        end

                        self:setLabelText("Label", tip, "NotePanel")
                        self:setCtrlVisible("NotePanel", true)
                        self.allState = CHECK_STATE.SUCC
                    end
                end, delayTime)
            end)
        end, 0)
    end
end

-- 获取提示
function CheckNetDlg:getFailTip(itemData)
    if not itemData then return end

    return self.isEmulator and itemData.fail_tip_emu or itemData.fail_tip
end

-- 设置状态
function CheckNetDlg:setState(item, state)
    self:setCtrlVisible("Stage4Image", CHECK_STATE.PREPARE == state, item)
    self:setCtrlVisible("Stage1Image", CHECK_STATE.PROCESSING == state, item)
    self:setCtrlVisible("Stage2Image", CHECK_STATE.SUCC == state, item)
    self:setCtrlVisible("Stage3Image", CHECK_STATE.FAILED == state, item)
end

function CheckNetDlg:moveNext()
    if self.curIndex >= #(self.checkData) then return end
    self.curIndex = self.curIndex + 1
    return true
end

-- 获取控件
function CheckNetDlg:getControl(name, widgetType, root)
    local widget = nil

    if type(root) == "string" then
        root = self:getControl(root, "ccui.Widget")
        widget = ccui.Helper:seekWidgetByName(root, name)
    else
        root = root or self.root
        widget = ccui.Helper:seekWidgetByName(root, name)
    end

    return widget
end

-- 为指定的控件对象绑定 TouchEnd 事件
function CheckNetDlg:bindTouchEndEventListener(ctrl, func)
    if not ctrl then
        Log:W("CheckNetDlg:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType)
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 控件绑定事件
function CheckNetDlg:bindListener(name, func, root)
    if nil == func then
        Log:W("CheckNetDlg:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name, nil, root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("CheckNetDlg:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

-- 设置控件的可见性
function CheckNetDlg:setCtrlVisible(ctrlName, visible, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setVisible(visible)
    end

    return ctrl
end

function CheckNetDlg:setLabelText(name, text, root, color3)
    local ctl = self:getControl(name, nil, root)

    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end

    -- 有些label控件为auto属性，刷新上级
    if ctl then
        local parentPanel = ctl:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end
    end
end

function CheckNetDlg:setNoteTip(tip)
    self:setLabelText("Label", tip, "NotePanel")
    self:setCtrlVisible("NotePanel", true)
end

function CheckNetDlg:onSubmitButton(sender, eventType)
    if not self.allState then
        if self.checkData ~= SEND_CHECK then
            self:setNoteTip(CHSUP[2200010])
        else
            self:setNoteTip(CHSUP[2200011])
        end
        return
    end

    if CHECK_STATE.SUCC == self.allState then
        if self.checkData ~= SEND_CHECK then
            self:setNoteTip(CHSUP[2200012])
        else
            self:setNoteTip(CHSUP[2200013])
        end
        return
    end

    self.checkData = SEND_CHECK
    self:initStepPanel()
    self.curState = {}
    for i = 1, #(self.checkData) do
        table.insert(self.curState, CHECK_STATE.NONE)
    end
    self:setCtrlVisible("NotePanel", false)
    self.lastCheckTime = nil
    self.curIndex = nil
    self.allState = nil
    performWithDelay(self, function() self:doCheckNet() end, 0)
end

function CheckNetDlg:onReTryButton(sender, eventType)
    if not self.allState then
        return
    end

    if type == CHECK_TYPE.UPDATE then
        self.checkData = UPDATE_CHECK
    elseif type == CHECK_TYPE.GAME then
        self.checkData = GAME_CHECK
    end

    self:setCtrlVisible("LineImage_1", true)
    self:setCtrlVisible("LineImage_2", true)
    self:setState(self:getControl("LineImage_1"), CHECK_STATE.PREPARE)
    self:setState(self:getControl("LineImage_2"), CHECK_STATE.PREPARE)
    self:initStepPanel()
    self.curState = {}
    for i = 1, #(self.checkData) do
        table.insert(self.curState, CHECK_STATE.NONE)
    end

    self:setCtrlVisible("NotePanel", false)
    self.lastCheckTime = nil
    self.curIndex = nil
    self.allState = nil
    performWithDelay(self, function() self:doCheckNet() end, 0)
end

function CheckNetDlg:onCloseButton(sender, eventType)
    self:close()
end

return CheckNetDlg