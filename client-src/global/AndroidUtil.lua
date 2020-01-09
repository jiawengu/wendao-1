-- AndroidUtil.lua
-- Created by sujl, Mar/15/2018
-- Android工具类

local platform = cc.Application:getInstance():getTargetPlatform()
if platform == cc.PLATFORM_OS_ANDROID then

AndroidUtil = {}

-- null -> object
-- 参数是以数组传递，无法直接传递nil
AndroidUtil.Null = LuaJavaBridge.ObjectNull()

-- 通过类型名称获取Class
function AndroidUtil:getClassTypeByName(className)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "getClassTypeByName", { className }, "(Ljava/lang/String;)Ljava/lang/Class;")
    if ok then return ret end
end

-- 新建数组
function AndroidUtil:newArray(clazz, len)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "newArray", {clazz, len}, "(Ljava/lang/Class;I)Ljava/lang/Object;")
    if ok then return ret end
end

-- 设置数组的值
function AndroidUtil:setArray(arr, index, value)
    LuaJavaBridge.callStaticMethod("java/lang/reflect/Array", "set", {arr, index, value}, "(Ljava/lang/Object;ILjava/lang/Object;)V")
end

-- 创建java对象
function AndroidUtil:newInstance(clsName, argClass, argValue)
    --argClass = argClass or self.Null
    --argValue = argValue or self.Null
    if not argClass then
        argClass = self.Null
        argValue = self.Null
    else
        assert(#argClass == #argValue)
        local clsA = self:newArray(self:class(), #argClass)
        for i = 1, #argClass do
            self:setArray(clsA, i - 1, self:getClassTypeByName(argClass[i]))
        end

        local valA = self:newArray(self:object(), #argValue)
        for i = 1, #argValue do
            self:setArray(valA, i - 1, argValue[i])
        end

        argClass = clsA
        argValue = valA
    end

    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "newInstance", { clsName, argClass, argValue }, "(Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;")
    if ok then return ret end
end

-- 实例调用
function AndroidUtil:callInst(className, funcName, inst, argClass, argValue)
    local ok, ret = LuaJavaBridge.callObjectMethod(className, funcName, inst, argValue, argClass)
    if ok then return ret end
end

-- 静态调用
function AndroidUtil:callStatic(className, funcName, argClass, argValue)
    local ok, ret = LuaJavaBridge.callStaticMethod(className, funcName, argValue, argClass)
    if ok then return ret end
end

-- 在UI线程执行函数
function AndroidUtil:runOnUiThread(clazz, funcName, funcSign, args, callback)
    callback = callback or self.Null
    if 'string' == type(clazz) then
        LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "runOnUiThread", { clazz, funcName, funcSign, args, callback}, "(Ljava/lang/String;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;Ljava/lang/String;)V")
    else
        LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "runOnUiThread", { clazz, funcName, funcSign, args, callback}, "(Ljava/lang/Object;Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;Ljava/lang/String;)V")
    end
end

-- Char -> Object
function AndroidUtil:charToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "charToObject", {v}, "(C)Ljava/lang/Object;")
    if ok then return ret end
end

-- Object -> Char
function AndroidUtil:objectToChar(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToChar", {o}, "(Ljava/lang/Object;)C")
    if ok then return ret end
end

function AndroidUtil:booleanToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "booleanToObject", {v}, "(Z)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToBoolean(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToBoolean", {o}, "(Ljava/lang/Object;)Z")
    if ok then return ret end
end

function AndroidUtil:shortToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "shortToObject", {v}, "(S)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToShort(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToShort", {o}, "(Ljava/lang/Object;)S")
    if ok then return ret end
end

function AndroidUtil:intToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "intToObject", {v}, "(I)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToInt(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToInt", {o}, "(Ljava/lang/Object;)I")
    if ok then return ret end
end

function AndroidUtil:longToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "longToObject", {v}, "(J)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToLong(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToLong", {o}, "(Ljava/lang/Object;)J")
    if ok then return ret end
end

function AndroidUtil:floatToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "floatToObject", {v}, "(F)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToFloat(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToFloat", {o}, "(Ljava/lang/Object;)F")
    if ok then return ret end
end

function AndroidUtil:doubleToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "doubleToObject", {v}, "(D)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToDouble(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToDouble", {o}, "(Ljava/lang/Object;)D")
    if ok then return ret end
end

function AndroidUtil:stringToObject(v)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "stringToObject", {v}, "(Ljava/lang/String;)Ljava/lang/Object;")
    if ok then return ret end
end

function AndroidUtil:objectToString(o)
    local ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToString", {o}, "(Ljava/lang/Object;)Ljava/lang/String;")
    if ok then return ret end
end

-- int.class
function AndroidUtil:int()
    return self:getClassTypeByName("Integer")
end

-- byte.class
function AndroidUtil:byte()
    return self:getClassTypeByName("Byte")
end

-- char.class
function AndroidUtil:char()
    return self:getClassTypeByName("Charactor")
end

-- short.class
function AndroidUtil:short()
    return self:getClassTypeByName("Short")
end

-- long.class
function AndroidUtil:long()
    return self:getClassTypeByName("Long")
end

-- float.class
function AndroidUtil:float()
    return self:getClassTypeByName("Float")
end

-- double.class
function AndroidUtil:double()
    return self:getClassTypeByName("Double")
end

-- boolean.class
function AndroidUtil:boolean()
    return self:getClassTypeByName("Boolean")
end

-- Class.class
function AndroidUtil:class()
    return self:getClassTypeByName("java.lang.Class")
end

-- Object.class
function AndroidUtil:object()
    return self:getClassTypeByName("java.lang.Object")
end

return  AndroidUtil
end