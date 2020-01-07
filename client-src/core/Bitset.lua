-- Bitset.lua
-- Created by chenyq Nov/27/2014
-- 位集合

local Bitset = class('Bitset')

local BV = {}
for i=1,32 do
    BV[i]=2^(i - 1)
end

-- 将整数转化为位集合
-- i32OrArray: 32 位的整数或者整数数组
function Bitset:ctor(i32OrArray)
    i32OrArray = i32OrArray or {}
    self.bit = {}
    self:set(i32OrArray)
end

-- 将 32 位的整数转化为位集合
-- i32: 32 位的整数
function Bitset:setI32(startPos, i32)
    i32 = i32 or 0
    for j = 1, 32 do
        local i = 33 - j
        if i32 >= BV[i] then
            self.bit[startPos + i] = true
            i32 = i32 - BV[i]
        else
            self.bit[startPos + i] = false
        end
    end
end

-- 将整数或者整数数组转化为位集合
-- i32OrArray: 32 位的整数或者整数数组
function Bitset:set(i32OrArray)
    if type(i32OrArray) ~= 'table' then
        i32OrArray = { tonumber(i32OrArray) }
    end

    local start = 0
    for i = 1, #i32OrArray do
        self:setI32(start, i32OrArray[i])
        start = start + 32
    end
end

-- 设置指定位的值
-- v: 取值范围 true or false
function Bitset:setBit(index, v)
    if not index or index <= 0 or index > #(self.bit) then
        return
    end

    if v then
        self.bit[index] = true
    else
        self.bit[index] = false
    end
end

-- index 对应的位是否被设置了
function Bitset:isSet(index)
    if not index or index <= 0 or index > #(self.bit) then
        return false
    end

    return self.bit[index]
end

-- 返回低 32 位对应的整数
function Bitset:getI32()
    local i32 = 0
    for i = 1, 32 do
        if self.bit[i] then
            i32 = i32 + BV[i]
        end
    end

    return i32
end

-- 判断是否相等
function Bitset:isEqual(bitset)
    if not bitset.bit or type(bitset.bit) ~= 'table' then
        return false
    end

    local lLen = #(self.bit)
    local rLen = #(bitset.bit)
    if lLen ~= rLen then
        return false
    end

    for i = 1, lLen do
        if self.bit[i] ~= bitset.bit[i] then
            return false
        end
    end

    return true
end

return Bitset