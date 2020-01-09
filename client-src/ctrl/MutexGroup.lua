-- MutexGroup.lua
-- created by cheny Dec/04/2014
-- 互斥组（元素包含setSelectedState方法）

local MutexGroup = class("MutexGroup")

function MutexGroup:ctor()
    self.group = {}
end

function MutexGroup:addItem(item)
    table.insert(self.group, item)
end

-- 选中某一项
function MutexGroup:select(item)
    for _, v in ipairs(self.group) do
        if nil ~= v.setSelectedState then
            v:setSelectedState(v == item)
        end
    end
end

function MutexGroup:clear()
    self.group = {}
end

return MutexGroup
