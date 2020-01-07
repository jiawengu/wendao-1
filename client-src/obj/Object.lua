-- Object.lua
-- Created by chenyq Nov/12/2014
-- 场景中显示的对象的基类

local DataObject = require('core/DataObject')
local Object = class("Object", DataObject)

function Object:ctor(...)
    DataObject.ctor(self)

    -- 每个对象分 3 层，分别对应于角色层的 3 层
    self.bottomLayer = cc.Layer:create()
    self.middleLayer = cc.Layer:create()
    self.topLayer = cc.Layer:create()

    self.bottomLayer:retain()
    self.middleLayer:retain()
    self.topLayer:retain()

    self.visible = true
    self.curX, self.curY = 0, 0
    self.needBindClickEvent = true

    self:init(...)
end

-- 清除相应的数据
function Object:cleanup()
    self:onExitScene()

    if self.bottomLayer then
        self.bottomLayer:removeAllChildren()
        self.bottomLayer:release()
        self.bottomLayer = nil
    end

    if self.middleLayer then
        self.middleLayer:removeAllChildren()
        self.middleLayer:release()
        self.middleLayer = nil
    end

    if self.topLayer then
        self.topLayer:removeAllChildren()
        self.topLayer:release()
        self.topLayer = nil
    end

    self.visible = false
end

-- 获取类型
function Object:getType()
    return self.__cname
end

-- 对象进入场景
function Object:onEnterScene(mapX, mapY)
    -- 将对象的 3 层分别添加到角色层对应的子层中
    if self.bottomLayer:getParent() == nil then
        gf:getCharBottomLayer():addChild(self.bottomLayer)
    end

    if self.middleLayer:getParent() == nil then
        gf:getCharMiddleLayer():addChild(self.middleLayer)
    end

    if self.topLayer:getParent() == nil then
        gf:getCharTopLayer():addChild(self.topLayer)
    end

    local x, y = gf:convertToClientSpace(mapX, mapY)
    self:setPos(x, y)
end

-- 对象离开场景
function Object:onExitScene()
    if self.bottomLayer then
        self.bottomLayer:removeFromParent(true)
        self.bottomLayer:removeAllChildren()
    end

    if self.middleLayer then
        self.middleLayer:removeFromParent(true)
        self.middleLayer:removeAllChildren()
    end

    if self.topLayer then
        self.topLayer:removeFromParent(true)
        self.topLayer:removeAllChildren()
    end
end

-- 添加到底层
function Object:addToBottomLayer(node)
    self.bottomLayer:addChild(node)
end

-- 添加到中间层
function Object:addToMiddleLayer(node)
    self.middleLayer:addChild(node)
end

-- 添加到顶层
function Object:addToTopLayer(node)
    self.topLayer:addChild(node)
end

-- 设置 z-order
function Object:setZOrder(zOrder)
    self.bottomLayer:setLocalZOrder(zOrder)
    self.middleLayer:setLocalZOrder(zOrder)
    self.topLayer:setLocalZOrder(zOrder)
end

-- 设置位置
function Object:setPos(x, y)
    if self.curX == x and self.curY == y then return end

    self.bottomLayer:setPosition(x, y)
    self.middleLayer:setPosition(x, y)
    self.topLayer:setPosition(x, y)

    self:setZOrder(gf:getObjZorder(y))

    self.curX = x
    self.curY = y
end

function Object:setVisible(visible)
    if self.visible == visible then
        return
    end

    self.visible = visible
    self.bottomLayer:setVisible(visible)
    self.middleLayer:setVisible(visible)
    self.topLayer:setVisible(visible)
end

function Object:getVisible()
    return self.visible
end

function Object:fadeOut(time)
    self.bottomLayer:setCascadeOpacityEnabled(true)
    local fadeAction1 = cc.FadeOut:create(time)
    self.bottomLayer:runAction(fadeAction1)

    self.middleLayer:setCascadeOpacityEnabled(true)
    local fadeAction2 = cc.FadeOut:create(time)
    self.middleLayer:runAction(fadeAction2)

    self.topLayer:setCascadeOpacityEnabled(true)
    local fadeAction3 = cc.FadeOut:create(time)
    self.topLayer:runAction(fadeAction3)
end

function Object:fadeIn(time)
    self.bottomLayer:setCascadeOpacityEnabled(true)
    local fadeAction1 = cc.FadeIn:create(time)
    self.bottomLayer:runAction(fadeAction1)

    self.middleLayer:setCascadeOpacityEnabled(true)
    local fadeAction2 = cc.FadeIn:create(time)
    self.middleLayer:runAction(fadeAction2)

    self.topLayer:setCascadeOpacityEnabled(true)
    local fadeAction3 = cc.FadeIn:create(time)
    self.topLayer:runAction(fadeAction3)
end

function Object:setOpacity(opacity)
    self.bottomLayer:setCascadeOpacityEnabled(true)
    self.bottomLayer:setOpacity(opacity)

    self.middleLayer:setCascadeOpacityEnabled(true)
    self.middleLayer:setOpacity(opacity)

    self.topLayer:setCascadeOpacityEnabled(true)
    self.topLayer:setOpacity(opacity)
end

function Object:getId()
    return self:queryBasicInt('id')
end

function Object:getName()
    return self:queryBasic('name')
end

function Object:getTitle()
    return self:queryBasic('title')
end

function Object:update()
end

function Object:continueAllPlay(layer)
    self:continueAllPlayByLayer(self.bottomLayer)
    self:continueAllPlayByLayer(self.middleLayer)
    self:continueAllPlayByLayer(self.topLayer)
end

function Object:continueAllPlayByLayer(layer)
    if not layer then return end
    local children = layer:getChildren()
    if not children then return end

    for _, v in pairs(children) do
        if type(v.continuePlay) == "function" then
            v:continuePlay()
        elseif type(v.play) == "function" then
            v:play()
        elseif type(v.resume) == "function" then
            v:resume()
        end
    end
end

function Object:pauseAllPlay(layer)
    self:pauseAllPlayByLayer(self.bottomLayer)
    self:pauseAllPlayByLayer(self.middleLayer)
    self:pauseAllPlayByLayer(self.topLayer)
end

function Object:pauseAllPlayByLayer(layer)
    if not layer then return end
    local children = layer:getChildren()
    if not children then return end

    for _, v in pairs(children) do
        if type(v.pausePlay) == "function" then
            v:pausePlay()
        elseif type(v.pause) == "function" then
            v:pause()
        elseif type(v.stopAllActions) == "function" then
            v:stopAllActions()
        end
    end
end

return Object

