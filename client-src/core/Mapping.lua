-- Mapping.lua
-- Created by chenyq Nov/22/2014
-- map，提供 query、queryInt、set、absorbFields 等操作

local Mapping = class("Mapping")

function Mapping:ctor()
    self.data = {}
end

function Mapping:set(key, value)
    self.data[key] = value
end

function Mapping:query(key)
    local v = self.data[key]
    if v then
        if type(v) ~= 'table' then
            return tostring(v)
        else
            return v
        end
    else
        return ""
    end
end

function Mapping:queryInt(key)
    local v = self.data[key]
    if v then
        return tonumber(v)
    else
        return 0
    end
end

function Mapping:absorbFields(tbl)
    for k, v in pairs(tbl) do
        self.data[k] = v
    end
end

function Mapping:cleanup()
    self.data = {}
end

function Mapping:haveKey(key)
    return self.data[key] ~= nil
end

return Mapping