-- DataObject.lua
-- created by cheny Feb/12/2014
-- 数据对象

local Mapping = require('core/Mapping')
local DataObject = class("DataObject")

function DataObject:ctor()
    self.basic = Mapping.new()
    self.extra = Mapping.new()
end

function DataObject:setBasic(key, value)
	self.basic:set(key, value)
end

function DataObject:setExtra(key, value)
	self.extra:set(key, value)
end

function DataObject:query(key)
    return tostring(self:queryInt(key))
end

function DataObject:queryInt(key)
	return self:queryBasicInt(key) + self:queryExtraInt(key)
end

function DataObject:queryBasic(key)
    return self.basic:query(key)
end

function DataObject:queryExtra(key)
    return self.extra:query(key)
end

function DataObject:queryBasicInt(key)
    return self.basic:queryInt(key)
end

function DataObject:queryExtraInt(key)
    return self.extra:queryInt(key)
end

function DataObject:cleanupBasic()
    self.basic:cleanup()
end

function DataObject:cleanupExtra()
    self.extra:cleanup()
end

function DataObject:absorbBasicFields(tbl)
    if self.onBeforeAbsorbBasicFields and type(self.onBeforeAbsorbBasicFields) == "function" then
        -- 存在吸收基本数据之前的回调函数
        self:onBeforeAbsorbBasicFields(tbl)
    end
    
    self.basic:absorbFields(tbl)
    
	if self.onAbsorbBasicFields and type(self.onAbsorbBasicFields) == "function" then
	    -- 存在吸收基本数据的回调函数，调用之
	    self:onAbsorbBasicFields(tbl)
	end
end

function DataObject:absorbExtraFields(tbl)
    self.extra:absorbFields(tbl)

    if self.onAbsorbExtraFields and type(self.onAbsorbExtraFields) == "function" then
        -- 存在吸收额外数据的回调函数，调用之
        self:onAbsorbExtraFields()
    end
end

function DataObject:haveBasicKey(key)
    return self.basic:haveKey(key)
end

function DataObject:getType()
    return self.__cname
end

return DataObject
