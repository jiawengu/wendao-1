-- List.lua
-- created by cheny Oct/14/2014
-- 双端队列

local List = class("List")

function List:ctor()
    self.first = 1
    self.last = 0
end

-- 插入队头
function List:pushFront(value)
    local first = self.first - 1
    self.first = first
    self[first] = value
end

-- 插入队尾
function List:pushBack(value)
    local last = self.last + 1
    self.last = last
    self[last] = value
end

-- 取出第一个元素
function List:popFront()
    local first = self.first
    if first > self.last then
        error("List is empty")
    end
    local value = self[first]
    self[first] = nil
    self.first = first + 1
    
    if self:size() == 0 then
        self.first = 1
        self.last = 0
    end
    
    return value
end

-- 取出最后一个元素
function List:popBack()
    local last = self.last
    if self.first > last then
        error("List is empty")
    end
    local value = self[last]
    self[last] = nil
    self.last = last - 1

    if self:size() == 0 then
        self.first = 1
        self.last = 0
    end
    
    return value
end

-- 获取队列大小
function List:size()
    return self.last - self.first + 1
end

-- 获取元素，从1开始计算下标
function List:get(idx)
    if idx < 1 or idx > self:size() then
        return nil
    end

    return self[self.first + idx - 1]
end

function List:removeSomeBySubkey(subkey, value)
    if type(self[self.first]) ~= "table" or self.first > self.last then
        return
    end
    
    local cou = 0
    for i = self.first, self.last do
        self[i - cou] = self[i]
        if self[i] and self[i][subkey] == value then
            cou = cou + 1
        end
    end

    self.last = self.last - cou
end

return List
