-- LoginBack2018Dlg.lua
-- Created by sujl, Jan/10/2018
-- 登录背景界面
-- cc.Director:getInstance():getRunningScene():moveLoginBack(-1, 1)

require('mgr/DragonBonesMgr')

local LoginBack2018Dlg = class("LoginBack2018Dlg", function()
    return cc.Layer:create()
end)

local UI_SCALE = 1
local B_MOVE_X
local B_MOVE_Y
local BACK_SIZE = { width = 1656, height = 862 }
local SENSOR_TYPE
local NS2S = 1 / 1000000000

function LoginBack2018Dlg:ctor(param)
    self:UnloadPatchRes()
    local winSize = cc.Director:getInstance():getWinSize()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/LoginBackDlg_2018.json")
    self:addChild(self.root)
    local size = self.root:getContentSize()
    local csize
    self.root:setPosition(cc.p(-(size.width - winSize.width) / 2, -(size.height - winSize.height) / 2))

    B_MOVE_X = math.min(winSize.width * 0.4 , BACK_SIZE.width - winSize.width) / 2
    B_MOVE_Y = math.min(winSize.height * 0.4, BACK_SIZE.height - winSize.height) / 2

    -- 龙骨动画

    -- 云朵
    local cloud = DragonBonesMgr:createUIDragonBones(1280, "01280")
    local cloudNode = tolua.cast(cloud, "cc.Node")
    self:getControl("Panel_01280", nil, "Y_Panel_01"):addChild(cloudNode)
    DragonBonesMgr:play(cloud, "stand", 0)
    csize = self:getControl("Panel_01280"):getContentSize()
    cloudNode:setPosition(csize.width / 2, csize.height / 2)
    cloudNode:unscheduleUpdate()

    -- 树
    local tree = DragonBonesMgr:createUIDragonBones(1283, "01283")
    local treeNode = tolua.cast(tree, "cc.Node")
    csize = self:getControl("Panel_01283", nil, "Q_Panel_01"):getContentSize()
    treeNode:setPosition(csize.width / 2, csize.height / 2)
    self:getControl("Panel_01283", nil, "Q_Panel_01"):addChild(treeNode)
    DragonBonesMgr:play(tree, "stand", 0)
    treeNode:unscheduleUpdate()

    -- 凤凰
    local phonixPanel = self:getControl("Panel_01281", nil, "Z_Panel_02")
    local phonix = DragonBonesMgr:createUIDragonBones(1281, "01281")
    local phonixNode = tolua.cast(phonix, "cc.Node")
    csize = phonixPanel:getContentSize()
    phonixNode:setPosition(csize.width / 2, csize.height / 2)
    phonixPanel:addChild(phonixNode)
    DragonBonesMgr:play(phonix, "stand", 0)
    self.curPhonixAction = "stand"
    --self:bindListener("Panel_01281", self.onClickPanel1, "Z_Panel_02")
    self.phonix = phonix
    phonixNode:unscheduleUpdate()
    self.phonixPlayRate = 1

    -- 黑龙
    local dragonPanel = self:getControl("Panel_01282", nil, "Q_Panel_02")
    local dragon = DragonBonesMgr:createUIDragonBones(1282, "01282")
    local dragonNode = tolua.cast(dragon, "cc.Node")
    dragonPanel:addChild(dragonNode)
    csize = dragonPanel:getContentSize()
    dragonNode:setPosition(csize.width / 2, csize.height / 2)
    -- DragonBonesMgr:play(dragon, "stand", 0)
    DragonBonesMgr:play(dragon, "stand", 5)
    self.curDragonAction = "stand"
    --self:bindListener("Panel_01282", self.onClickPanel2, "Q_Panel_02")
    self.dragon = dragon
    dragonNode:unscheduleUpdate()
    self.dragonPlayRate = 1

    if param and param.doAction then
        -- 光效播放
        local psize, epanel

        epanel = self:getControl("Panel_01281_effect", nil, "Z_Panel_02")
        psize = epanel:getContentSize()
        self.phonixEffect = self:createArmature("01303")
        self.phonixEffect:getAnimation():play("Top01")
        self.phonixEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(self.phonixEffect)

        epanel = self:getControl("Panel_01282_effect", nil, "Q_Panel_02")
        psize = epanel:getContentSize()
        self.dragonEffect = self:createArmature("01305")
        self.dragonEffect:getAnimation():play("Top01")
        self.dragonEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(self.dragonEffect)

        -- 树叶
        epanel = self:getControl("Panel_01283", nil, "Q_Panel_01")
        psize = epanel:getContentSize()
        local treeEffect = self:createArmature("01303")
        treeEffect:getAnimation():play("Top03")
        treeEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(treeEffect)

        -- 云
        epanel = self:getControl("Panel_yun_effect", nil, "Q_Panel_03")
        psize = epanel:getContentSize()
        local cloudEffect = self:createArmature("01303")
        cloudEffect:getAnimation():play("Top04")
        cloudEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(cloudEffect)

        -- 光芒
        epanel = self:getControl("Panel_Light_effect", nil, "Z_Panel_03")
        psize = epanel:getContentSize()
        local cloudEffect = self:createArmature("01303")
        cloudEffect:getAnimation():play("Top05")
        cloudEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(cloudEffect)

        -- 八卦
        epanel = self:getControl("Panel_01280", nil, "Y_Panel_01")
        psize = epanel:getContentSize()
        local cloudEffect = self:createArmature("01303")
        cloudEffect:getAnimation():play("Top06")
        cloudEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(cloudEffect)

        -- 云雾
        epanel = self:getControl("Cloud_Panel_effect", nil, "Q_Panel_01")
        psize = epanel:getContentSize()
        local cloudEffect = self:createArmature("01303")
        cloudEffect:getAnimation():play("Top07")
        cloudEffect:setPosition(cc.p(psize.width / 2, psize.height / 2))
        epanel:addChild(cloudEffect)

        -- 点击及播放时间
        --[[
        DragonBonesMgr:bindEventListener(phonix, "loopComplete", function(eventType)
            if 'table' == type(self.phonixNextAction) then
                performWithDelay(phonixNode, function()
                    DragonBonesMgr:play(phonix, self.phonixNextAction[1], self.phonixNextAction[2])
                    self.phonixEffect:getAnimation():play("Top02")
                    self.phonixPlayRate = 1
                    if "walk" == self.phonixNextAction[1] then
                        self.phonixNextAction = "stand"
                    else
                        self.phonixNextAction = nil
                    end
                end, 0)
            end
        end)

        DragonBonesMgr:bindEventListener(phonix, "complete", function(eventType)
            if 'string' == type(self.phonixNextAction) then
                 performWithDelay(phonixNode, function()
                    DragonBonesMgr:play(phonix, self.phonixNextAction, 0)
                    self.phonixEffect:getAnimation():play("Top01")
                    self.phonixPlayRate = 1
                    self.phonixNextAction = nil
                end, 0)
            end
        end)

        DragonBonesMgr:bindEventListener(dragon, "loopComplete", function(eventType)
            if 'table' == type(self.dragonNextAction) then
                performWithDelay(dragonNode, function()
                    DragonBonesMgr:play(dragon, self.dragonNextAction[1], self.dragonNextAction[2])
                    self.dragonEffect:getAnimation():play("Top02")
                    self.dragonPlayRate = 1
                    if "walk" == self.dragonNextAction[1] then
                        self.dragonNextAction = "stand"
                    else
                        self.dragonNextAction = nil
                    end
                end, 0)
            end
        end)

        DragonBonesMgr:bindEventListener(dragon, "complete", function(eventType)
            if 'string' == type(self.dragonNextAction) then
                 performWithDelay(dragonNode, function()
                    DragonBonesMgr:play(dragon, self.dragonNextAction, 0)
                    self.dragonEffect:getAnimation():play("Top01")
                    self.dragonPlayRate = 1
                    self.dragonNextAction = nil
                end, 0)
            end
        end)
        ]]

        DragonBonesMgr:bindEventListener(dragon, "complete", function(eventType)
            if 'stand' == self.curDragonAction then
                 performWithDelay(dragonNode, function()
                    DragonBonesMgr:play(dragon, "walk", 1)
                    self.dragonEffect:getAnimation():play("Top02")
                    self.curDragonAction = "walk"
                end, 0)
            elseif "walk" == self.curDragonAction then
                performWithDelay(dragonNode, function()
                    DragonBonesMgr:play(dragon, "stand", 5)
                    self.dragonEffect:getAnimation():play("Top01")
                    self.curDragonAction = "stand"
                end, 0)
            end
        end)

        self.scheduleId = self:Schedule(function(deltaTime)
            if dragonNode then
                dragonNode:update(deltaTime * self.dragonPlayRate)
            end

            if phonixNode then
                phonixNode:update(deltaTime * self.phonixPlayRate)
            end

            if treeNode then
                treeNode:update(deltaTime)
            end

            if cloudNode then
                cloudNode:update(deltaTime)
            end
        end, 0)

        cc.Director:getInstance():setAnimationInterval(1 / 60)

        self:doAction()
    end
end

function LoginBack2018Dlg:cleanup()
    if EventDispatcher then
        EventDispatcher:removeEventListener("ENTER_FOREGROUND", self.onEnterForeground, self)
        EventDispatcher:removeEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
        EventDispatcher:removeEventListener("EVENT_STOPGAME", self.onStopGame, self)
    end

    if self.scheduleId then
        self:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end

    if self:isIos() then
        self:setSensorEnabled(SENSOR_TYPE, false)
    else
        gfCloseSensor()
    end

    local FPS = 30
    if Const then
        FPS = Const.FPS
    end
    cc.Director:getInstance():setAnimationInterval(1 / FPS)
end

function LoginBack2018Dlg:doAction()
    local function getAngle(x, y)
        x = x * 180 / math.pi
        x = x > 0 and x or 360 + x

        y = y * 180 / math.pi
        y = y > 0 and y or 360 + y

        return x, y
    end

    local lastUpdateTime = 0
    local androidTryTimes = 5   -- Android传感器数据前几次不准确，忽略掉
    local lx, ly
    local curOrientation = DeviceMgr:getOrientation()
    local function sorListener(event, values, timestamp, orientation, naturealOrientation)
        local x, y, ax, ay
        if self:isIos() then
            if #values < 3 then return end

            local orientation = DeviceMgr:getOrientation()
            if curOrientation ~= orientation then
                -- 设备转向了
                self.initX, self.initY = nil, nil
                curOrientation = orientation
            end

            if 90 == orientation then
                ax, ay = getAngle(values[3], values[2])
            elseif 270 == orientation then
                ax, ay = getAngle(-values[3], -values[2])
            end

        elseif self:isAndroid() then
            if androidTryTimes > 0 then
                androidTryTimes = androidTryTimes - 1
                return
            end
            if #values < 3 then return end

            if (timestamp - lastUpdateTime) * NS2S < 0.2 then
                return
            end

            lastUpdateTime = timestamp
            local orientation = DeviceMgr:getOrientation()
            if curOrientation ~= orientation then
                -- 设备转向了
                self.initX, self.initY = nil, nil
                curOrientation = orientation
            end

            if 1 == orientation then
                ax, ay = getAngle(-values[2], values[3])
            elseif 3 == orientation then
                ax, ay = getAngle(values[2], -values[3])
            end
        end

        if not self.initX or not self.initY then
            self.initX = ax
            self.initY = ay
            return
        end

        -- 校正角度
        if self.initX > 180 and ax < 180 then
            ax = ax + 360
        end

        if self.initY > 180 and ay < 180 then
            ay = ay + 360
        end

        if self:isAndroid() then
            local LIMIT_MOVE = 3 -- Android下传感器数据变化比较大，需要进行过滤
            if lx and ly and math.abs(ax - lx) < LIMIT_MOVE and math.abs(ay - ly) < LIMIT_MOVE then
                return
            end

            lx, ly = ax, ay
        end

        x = (ax - self.initX)
        y = (ay - self.initY)

        if x > 180 then
            x = x - 360
        end

        if y > 180 then
            y = y - 360
        end

        local MAX_ANGEL = 30
        --x = math.max(-MAX_ANGEL, math.min(MAX_ANGEL, x)) / MAX_ANGEL
        --y = math.max(-MAX_ANGEL, math.min(MAX_ANGEL, y)) / MAX_ANGEL
        -- self:move(x, y)
        self:move(x / MAX_ANGEL, y / MAX_ANGEL)
    end

    local listener = cc.EventListenerSensor:create(sorListener)
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self)

    if self:isIos() then
        SENSOR_TYPE = 4
        self:setSensorEnabled(SENSOR_TYPE, true)
        self:setSensorInterval(0.1)
    elseif self:isAndroid() then
        gfOpenSensor()
    end

    local function onNodeEvent(event)
        if "cleanup" == event then
            self:cleanup()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    EventDispatcher:addEventListener("ENTER_FOREGROUND", self.onEnterForeground, self)
    EventDispatcher:addEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
    EventDispatcher:addEventListener("EVENT_STOPGAME", self.onStopGame, self)
end

function LoginBack2018Dlg:checkMoveDis(dis, maxValue)
    local checkValue = 8
    if dis > 0 then
        return math.min(maxValue, math.max(0, dis - checkValue))
    else
        return -math.min(maxValue, math.max(0, math.abs(dis) - checkValue))
    end
end

function LoginBack2018Dlg:move(rateX, rateY)
    -- 确保比例在[-1, 1]
    --rateX = math.max(-1, math.min(rateX, 1))
    --rateY = math.max(-1, math.min(rateY, 1))

    -- 移动背景层
    local curX, curY = self:getControl("BKPanel"):getPosition()
    local sx, sy = self:checkMoveDis(B_MOVE_X * rateX, B_MOVE_X), self:checkMoveDis(B_MOVE_Y * rateY, B_MOVE_Y)

    local dx, dy = sx - curX, sy - curY
    local dis = math.sqrt(dx * dx + dy * dy)
    local time = math.max(1, dis / 10 * 0.1)

    self:moveObj("BKPanel", sx, sy, time)
    self:moveObj("Y_Panel_01", sx, sy, time)
    self:moveObj("Y_Panel_02", sx, sy, time)
    self:moveObj("Y_Panel_03", 0.95 * sx, 0.9 * sy, time)    --环绕云，稍微有一点点速度就好

    -- 移动中景
    self:moveObj("Z_Panel_01", 0.9 * sx, 0.9 * sy, time)    --山、云，比较后面
    self:moveObj("Z_Panel_02", 0.85 * sx, 0.85 * sy, time)    -- 凤凰
    self:moveObj("Z_Panel_03", sx, sy, time)    --光，最后决定先不移动了

    -- 移动近景
    self:moveObj("Q_Panel_01", 0.35 * sx, 0.35 * sy, time)  --树
    self:moveObj("Q_Panel_02", 0.6 * sx, 0.6 * sy, time)  --龙
end

-- 移动
function LoginBack2018Dlg:moveObj(name, disX, disY, time)
    local ctrl = self:getControl(name)
    if not ctrl then return end

    -- 移动
    local moveAction
    moveAction = cc.Sequence:create(cc.EaseSineOut:create(cc.MoveTo:create(time, cc.p(disX, disY))))

    ctrl:stopAllActions()
    ctrl:runAction(moveAction)
end

function LoginBack2018Dlg:onClickPanel1()
    if self.phonixNextAction then return end
    self.phonixNextAction = { "walk", 1}
    self.phonixPlayRate = 1.8
end


function LoginBack2018Dlg:onClickPanel2()
    if self.dragonNextAction then return end
    self.dragonNextAction = { "walk", 1}
    self.dragonPlayRate = 1.6
end

function LoginBack2018Dlg:onEnterForeground(sender, eventType)
    if self:isIos() then
        self:setSensorEnabled(SENSOR_TYPE, true)
    end
end

function LoginBack2018Dlg:onEnterBackground(sender, eventType)
    if self:isIos() then
        self:setSensorEnabled(SENSOR_TYPE, false)
    end
end

function LoginBack2018Dlg:onStopGame(sender, eventType)
    if self.scheduleId then
        self:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

-- 获取控件
function LoginBack2018Dlg:getControl(name, widgetType, root)
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

-- 控件绑定事件
function LoginBack2018Dlg:bindListener(name, func, root)
    if nil == func then
        Log:W("Dialog:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name,nil,root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("Dialog:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

-- 为指定的控件对象绑定 TouchEnd 事件
function LoginBack2018Dlg:bindTouchEndEventListener(ctrl, func, data)
    if not ctrl then
        return
    end

    local ctrlName = ctrl:getName()

    -- 事件监听
    local function listener(sender, eventType)
        -- 添加 log 以方便核查崩溃问题
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.ended then
            func(self, sender, eventType, data, isRedDotRemoved)
        end
    end

    ctrl:addTouchEventListener(listener)
end

function LoginBack2018Dlg:Schedule(func, interval)
    interval = interval or 0
    local scheduler = cc.Director:getInstance():getScheduler()
    return scheduler:scheduleScriptFunc(func, interval, false)
end

function LoginBack2018Dlg:Unschedule(entryId)
    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:unscheduleScriptEntry(entryId)
end

-- 是否是 ios
function LoginBack2018Dlg:isIos()
    local platform = cc.Application:getInstance():getTargetPlatform()
    return platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE
end

-- 是否是 android
function LoginBack2018Dlg:isAndroid()
    return cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID
end

function LoginBack2018Dlg:createArmature(icon)
    -- 先加载资源
    local path = string.format("animate/ui/%s.ExportJson", icon)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    return ccs.Armature:create(icon)
end

-- 释放补丁更新的文件
function LoginBack2018Dlg:UnloadPatchRes()
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("animate/ui/01303.ExportJson")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("animate/ui/013030.png")

    local bonesPath, texturePath = DragonBonesMgr:getBonesUIFilePath(1283)
    DragonBonesMgr:removeBonesFileData(bonesPath, texturePath)
    cc.Director:getInstance():getTextureCache():removeTextureForKey("bones/ui/01283/texture.png")
end

return LoginBack2018Dlg