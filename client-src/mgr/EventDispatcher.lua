-- EventDispatcher.lua
-- Created by sujl, May/10/2016
-- 事件分发器

EventDispatcher = Singleton()

function EventDispatcher:init()
    self:cleanup()
end

function EventDispatcher:cleanup()
    self.listeners = {}
end

-- 增加监听器
function EventDispatcher:addEventListener(type, listener, cls)
    if not type or not listener then return end

    local list = self.listeners[type]
    if not list then
        list = {}
        self.listeners[type] = list
    end

    local idKey = tostring(cls) .. "/" .. tostring(listener)
    if not list[idKey] then
        list[idKey] = cls and function(...) listener(cls, ...) end or listener
        return list[idKey]
    end
end

-- 移除监听器
function EventDispatcher:removeEventListener(type, listener, cls)
    if not type or not listener then return end

    local list = self.listeners[type]
    local idKey = tostring(cls) .. "/" .. tostring(listener)
    if list and list[idKey] then
        list[idKey] = nil
    end
end

-- 分发事件
function EventDispatcher:dispatchEvent(type, ...)
    if not type then return end

    local list = self.listeners[type]
    if list then
        for _, v in pairs(list) do
            if v then v(...) end
        end
    end
end

-- 是否存在监听器
function EventDispatcher:hasEventListener(type)
    if not type then return false end

    return nil ~= self.listeners[type]
end

EventDispatcher:init()