-- Singleton.lua
-- Created by chenyq Nov/10/2014
-- 单例对象
-- 所有的非函数成员均存储在  var 表中

function Singleton(name, super)
    local obj = { var = {} }
    if name then
        obj.var.name = name
        obj.__cls_type__ = name
    end

    local met = {}

    -- 查找  var 表，如果找到则返回（这样不书写 var 照样可以访问其中的数据）
    -- 否则如果有 super，则查找 super
    -- 都没找到，返回 nil
    met.__index = function (tbl, key)
        if tbl.var[key] ~= nil then
            return tbl.var[key]
        elseif super then
            return super[key]
        else
            return nil
        end
    end

    -- 非函数成员均存储在 var 表中
    met.__newindex = function (tbl, key, value)
        if type(value) ~= "function" then
            assert("name" ~= key)
            tbl.var[key] = value
        else
            rawset(tbl, key, value)
        end
    end

    setmetatable(obj, met)

    if cc.PLATFORM_OS_WINDOWS == cc.Application:getInstance():getTargetPlatform() then
        obj.__super = super
    end

    return obj
end