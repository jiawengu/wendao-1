-- LoginBackDlg.lua
-- Created by sujl, Mar/27/2017
-- 登录背景界面

local LoginBack = class("LoginBack", function()
    return cc.Layer:create()
end)

local UI_SCALE = 1

-- 移动速度
local MOVE_DURATION = 80

-- 动画渲染书讯
local ANI_REDNDER_ORDER = 100

-- 是否为 pad
local function isPad()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local sig = '()I'
        local args = {}
        local className = 'org/cocos2dx/lua/AppActivity'
        local methodName = 'getScreenSize'
        local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
        if ok and ret > 70 then
            -- 大于 7 寸则认为是 pad
            return true
        end
    elseif platform == cc.PLATFORM_OS_IPAD then
        return true
    end

    return false
end

function LoginBack:ctor()
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile("ui/LoginBackDlg.json")
    self:addChild(self.root)

    self.bg = {
        self:getControl("B1_Image", nil, "BKPanel"),
        self:getControl("B2_Image", nil, "BKPanel"),
        self:getControl("B3_Image", nil, "BKPanel"),
        self:getControl("B4_Image", nil, "BKPanel"),
    }

    self.birds = {
        self:getControl("01131_Panel_1", nil, "BKPanel"),
        self:getControl("01131_Panel_2", nil, "BKPanel"),
    }

    self.birds1 = {
        self:getControl("01132_Panel", nil, "BKPanel"),
    }

    self.zp1 = self:getControl("Z1_Image", nil, "Z_Panel_1")
    self.zp2 = self:getControl("Z2_Image", nil, "Z_Panel_2")
    self.qp = {
        self:getControl("Q1_Image", nil, "Q_Panel"),
        self:getControl("Q2_Image", nil, "Q_Panel"),
        self:getControl("Q3_Image", nil, "Q_Panel"),
    }

    self.yp1 = {
        self:getControl("Y1_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y2_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y3_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y4_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y7_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y8_Image_1", nil, "Y_Panel_1"),
        self:getControl("Y9_Image_1", nil, "Y_Panel_1"),
    }

    self.yp2 = {
        self:getControl("Y1_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y2_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y4_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y3_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y7_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y8_Image_1", nil, "Y_Panel_2"),
        self:getControl("Y9_Image_1", nil, "Y_Panel_2"),
    }

    self.yp4 = {
        self:getControl("Y5_Image_2", nil, "Y_Panel_4"),
        self:getControl("Y5_Image_3", nil, "Y_Panel_4"),
        self:getControl("Y6_Image_1", nil, "Y_Panel_4"),
    }

    self.yp5 = {
        self:getControl("Y6_Image_1", nil, "Y_Panel_5"),
    }

    self.yp6 = {
        self:getControl("Y5_Image_1", nil, "Y_Panel_6"),
    }

    local winSize = cc.Director:getInstance():getWinSize()
    local rootHeight = winSize.height / UI_SCALE
    local rootWidth = winSize.width / UI_SCALE
    local rootSize = self.root:getContentSize()
    --self:setContentSize(rootSize.width, rootSize.height)
    --self.root:setContentSize(rootWidth, rootHeight)
    local x, y = self.root:getPosition()
    self.root:setPosition(cc.p(x, y - (rootSize.height - rootHeight) / 2))

    self:setAnchorPoint(0, 0.5)

    if not isPad() then
        self:setScale(0.9, 0.9)
    end
end

function LoginBack:getMoveDelta(tw, duration, deltaTime)
    local speed = tw / duration
    local delta = speed * deltaTime
    return delta
end

function LoginBack:doAction()
    self.canAction = true
    local rootSize = self.root:getContentSize()
    self.magic = self:createArmature(ResMgr.ArmatureMagic.login_back_magic.name)
    self.magic:setAnchorPoint(0.5, 0.5)
    self.magic:setPosition(rootSize.width / 2, rootSize.height / 2)
    self.magic:setLocalZOrder(ANI_REDNDER_ORDER)

    local function onNodeEvent(event)
        if "enter" == event then
            if self.canAction then
                self:_doAction(self.magic)
            end
        end
    end

    self.magic:registerScriptHandler(onNodeEvent)
    self.magic:getAnimation():play("Bottom")
    self.root:addChild(self.magic)

    --[[
    local dot = cc.DrawNode:create()
    dot:drawDot(cc.p(0, 0), 3, cc.c4b(255, 0, 0, 255))
    dot:setBlendFunc(gl.ONE, gl.ZERO)
    dot:setAnchorPoint(0.5, 0.5)
    dot:setPosition(rootSize.width / 2, rootSize.height / 2)
    dot:setLocalZOrder(ANI_REDNDER_ORDER)
    self.root:addChild(dot)
    ]]

    local birdPanel
    local bpSize

    -- bird1
    birdPanel = self.birds[1]
    bpSize = birdPanel:getContentSize()
    self.bird1 = self:createArmature(ResMgr.ArmatureMagic.login_back_bird1.name)
    self.bird1:setPosition(bpSize.width / 2, bpSize.height / 2)
    self.bird1:getAnimation():play("Bottom01")
    birdPanel:addChild(self.bird1)

    -- bird2
    birdPanel = self.birds[2]
    bpSize = birdPanel:getContentSize()
    self.bird2 = self:createArmature(ResMgr.ArmatureMagic.login_back_bird1.name)
    self.bird2:setPosition(bpSize.width / 2, bpSize.height / 2)
    self.bird2:getAnimation():play("Bottom02")
    birdPanel:addChild(self.bird2)

    -- bird3
    birdPanel = self.birds1[1]
    bpSize = birdPanel:getContentSize()
    self.bird3 = self:createArmature(ResMgr.ArmatureMagic.login_back_bird2.name)
    self.bird3:setPosition(bpSize.width / 2, bpSize.height / 2)
    self.bird3:getAnimation():play("Bottom")
    birdPanel:addChild(self.bird3)

    cc.Director:getInstance():setAnimationInterval(1 / 60)

    local FPS = Const.FPS
    local function onNodeEvent(event)
        if "exit" == event then
            cc.Director:getInstance():setAnimationInterval(1 / FPS)
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

function LoginBack:_doAction(node)
    local duration = MOVE_DURATION
    local tw = self:calcWidth(self.bg) - 2 * #self.bg
    local tdelta = 0

    self.root:scheduleUpdateWithPriorityLua(function(deltaTime)
        local delta
        delta = self:getMoveDelta(tw, duration, deltaTime)

        for i = 1, #self.bg do
            self:moveCtrl(self.bg[i], tw, delta, 1)
        end

        self:moveCtrl(self.zp1, tw, delta, 1.5)

        self:moveCtrl(self.zp2, tw, delta, 1.2)

        for i = 1, #self.qp do
            self:moveCtrl(self.qp[i], tw, delta, 3)
        end

        for i = 1, #self.yp1 do
            self:moveCtrl(self.yp1[i], tw, delta, 1.5)
        end

        for i = 1, #self.yp2 do
            self:moveCtrl(self.yp2[i], tw , delta, 2)
        end

        for i = 1, #self.yp4 do
            self:moveCtrl(self.yp4[i], tw, delta, 1.8)
        end

        for i = 1, #self.yp5 do
            self:moveCtrl(self.yp5[i], tw, delta, 0.9)
        end

        for i = 1, #self.yp6 do
            self:moveCtrl(self.yp6[i], tw, delta, 2.3)
        end

        for i = 1, #self.birds do
            self:moveCtrl(self.birds[i], tw, delta, 1)
        end

        for i = 1, #self.birds1 do
            self:moveCtrl(self.birds1[i], tw, delta, MOVE_DURATION / 27)
        end

        -- 校正动画，避免误差越来越大
        tdelta = tdelta + deltaTime
        if tdelta > MOVE_DURATION then
            tdelta = tdelta - MOVE_DURATION
            self.magic:getAnimation():gotoAndPlay(0)
            self.magic:getAnimation():update(tdelta)
        end
    end, 0)
end

-- 获取控件
function LoginBack:getControl(name, widgetType, root)
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

function LoginBack:createArmature(icon)
    -- 先加载资源
    local path = string.format("animate/ui/%s.ExportJson", icon)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    return ccs.Armature:create(icon)
end

function LoginBack:calcWidth(imgs)
    local tw = 0
    for i = 1, #imgs do
        local w = imgs[i]:getContentSize().width
        tw = tw + w
    end

    return tw
end

function LoginBack:moveCtrl(ctl, tw, delta, rate, func)
    local x, y = ctl:getPosition()
    local width = ctl:getContentSize().width * ctl:getScaleX()
    tw = tw * rate
    delta = delta * rate
    x = x - delta
    if x <= -width then
        x = tw + x
        if func then func(x) end
    end
    ctl:setPosition(x, y)
end

return LoginBack