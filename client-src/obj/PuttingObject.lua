-- PuttingObject.lua
-- Created by chenyq Nov/12/2014
-- 场景中显示的对象的基类

local DataObject = require('core/DataObject')
local PuttingObject = class("PuttingObject", DataObject)

function PuttingObject:ctor(...)
    DataObject.ctor(self)

    -- 每个对象分 3 层，分别对应于角色层的 3 层
    self.layer = cc.Layer:create()

    self.layer:retain()

    self.visible = true
    self.curX, self.curY = 0, 0

    self:init(...)
end

-- 清除相应的数据
function PuttingObject:cleanup()
    self:onExitScene()

    if self.layer then
        self.layer:removeAllChildren()
        self.layer:cleanup()
        self.layer:release()
        self.layer = nil
    end

    self.visible = false
end

-- 获取类型
function PuttingObject:getType()
    return self.__cname
end

-- 对象进入场景
function PuttingObject:onEnterScene(mapX, mapY)
    -- 将对象的 3 层分别添加到角色层对应的子层中
    if self.layer:getParent() == nil then
        gf:getPuttingObjLayer():addChild(self.layer)
    end

    local x, y = gf:convertToClientSpace(mapX, mapY)
    self:setPos(x, y)
end

-- 对象离开场景
function PuttingObject:onExitScene()
    if self.layer then
        self.layer:removeFromParent(false)
    end
end

-- 添加到底层
function PuttingObject:addToLayer(node)
    self.layer:addChild(node)
end

-- 设置 z-order
function PuttingObject:setZOrder(zOrder)
    self.layer:setLocalZOrder(zOrder)
end

-- 设置位置
function PuttingObject:setPos(x, y)
    if self.curX == x and self.curY == y then return end

    self.layer:setPosition(x, y)

    self:setZOrder(gf:getObjZorder(y))

    self.curX = x
    self.curY = y
end

function PuttingObject:setVisible(visible)
    if self.visible == visible then
        return
    end

    self.visible = visible
    self.layer:setVisible(visible)
end

function PuttingObject:getVisible()
    return self.visible
end

function PuttingObject:getId()
    return self:queryBasicInt('id')
end

function PuttingObject:getName()
    return self:queryBasic('name')
end

function PuttingObject:getTitle()
    return self:queryBasic('title')
end

function PuttingObject:update()
end

return PuttingObject

