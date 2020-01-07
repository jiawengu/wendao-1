-- BrowMgr.lua
-- Created by zhengjh Jan/19/2016
-- 表情管理器

BrowMgr = Singleton()

local Json = require('json')
local MALE = "1"
local FEMALE = "2"
local normalBrowMax = Const.NORMALBROW_ENDINDEX
local vipBrowStartIndex = Const.VIPBROW_STARTINDEX
local vipBrowEndIndex = Const.VIPBROW_ENDINDEX

-- 聊天表情使用时间
local NORMARL_BROW_TIME = {}
local VIP_BROW_TIME = {}

-- 聊天表情使用时间数据存储路径
local BROW_TIME_SAVE_PATH = Const.WRITE_PATH .. "brow/browUseTime.lua"

-- 没分性别的表情
local EXPRESSION_CONFIG =
{
    [5] = 5,
    [6] = 6,
    [9] = 9,
    [10] = 10,
    [11] = 11,
    [12] = 12,
    [13] = 13,
    [16] = 16,
    [18] = 18,
    [19] = 19,
    [20] = 20,
    [22] = 22,
    [26] = 26,
    [27] = 27,
    [30] = 30,
    [31] = 31,
    [33] = 33,
    [37] = 37,
    [39] = 39,
    [40] = 40,
    [48] = 48,
    [51] = 51,
    [57] = 57,
    [65] = 65,
    [67] = 67,
    [70] = 70,
    [77] = 77,
    [82] = 82,
    [84] = 84,
    [85] = 85,
    [90] = 90,
}

-- vip 开始编号
function BrowMgr:getVipSartIndex()
    return vipBrowStartIndex
end

-- vip 结束编号
function BrowMgr:getVipEndIndex()
    return vipBrowEndIndex
end

-- 普通表情总数
function BrowMgr:getNormalBrowMax()
    return normalBrowMax
end

-- 是否是性别表情
function BrowMgr:isGenderBrow(fileName)
    if EXPRESSION_CONFIG[fileName] or fileName > normalBrowMax  then -- 在表里面并且非vip
	   return false
	else
        return true
	end
end

-- 获取性别表情符
function BrowMgr:getGenderSign(gender)
    if not gender then
        if Me:queryBasic("gender") == FEMALE then
            return "f"
        else
            return "m"
        end
    else
        if gender == 2 then
            return "f"
        else
            return "m"
        end
    end
end

-- 获取VIP等级
function BrowMgr:getVipType(vipType)
    if not vipType then
        return Me:getVipType()
    else
        return vipType
    end
end

-- 如果是性别表情添加性别
function BrowMgr:addGenderSign(text, gender, vipType)
    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)
    local singNum = 0
    local borwText = ""

    while len >= index do
        local charValue = string.sub(text, index, index)
        local byteValue = string.byte(charValue, 1)

        if byteValue < 128 then
            if string.match(charValue,"(%d)")and singNum % 2 == 1  then -- 数字 -- 连续“#”个数为奇数个
                local numStr = charValue
                for i = 1, len do
                    if tonumber(numStr) == 0 and i == 1 then -- 数值第一位为0的情况
                        borwText = borwText .. numStr
                        local nextCharValue = string.sub(text, index + 1, index + 1)
                        if self:isGenderBrow(tonumber(numStr)) and nextCharValue ~= self:getGenderSign(gender) then -- 是否是表情符
                            borwText = borwText .. self:getGenderSign(gender)
                        end
                        index = index + 1
                        break
                    end
                    if tonumber(numStr) > vipBrowEndIndex then -- 超过表情范围
                        local numChars = string.sub(numStr, 1, string.len(numStr) - 1) -- 取上for一轮前面的数字

                        if (tonumber(numChars) > vipBrowStartIndex and BrowMgr:getVipType(vipType) == 0)
                            or (tonumber(numChars) < vipBrowStartIndex and tonumber(numChars) > normalBrowMax) then
                            -- 如果是vip表情符且玩家不是vip或无效表情符，去掉最后一位
                            numChars = string.sub(numChars, 1, string.len(numChars) - 1)
                            index = index - 1
                        end

                        borwText = borwText .. numChars

                        if self:isGenderBrow(tonumber(numChars)) then -- 是否是表情符
                            borwText = borwText .. self:getGenderSign(gender)
                        end

                        numStr = ""
                        index = index + i - 1  -- 因为上一轮已经超过所以要减1
                        break
                    else
                        local netCharValue =  string.sub(text, index + i, index + i)
                        if not string.match(netCharValue,"(%d)") then  -- 非数字
                            local numChars = string.sub(text, index, index + i - 1) -- 取前面的数字

                            if (tonumber(numChars) > vipBrowStartIndex and BrowMgr:getVipType(vipType) == 0)
                                or (tonumber(numChars) < vipBrowStartIndex and tonumber(numChars) > normalBrowMax) then
                                -- 如果是vip表情符且玩家不是vip或无效表情符，去掉最后一位
                                numChars = string.sub(numChars, 1, string.len(numChars) - 1)
                                index = index - 1
                            end

                            borwText = borwText .. numChars

                            if self:isGenderBrow(tonumber(numChars)) and netCharValue ~= self:getGenderSign(gender) then -- 是否是表情符
                                borwText = borwText .. self:getGenderSign(gender)
                            end

                            numStr = ""
                            index = index + i
                            break
                        else
                            numStr = numStr .. netCharValue
                        end
                    end
                end

                singNum = 0
            else
                if charValue == "#" then
                    singNum = singNum + 1
                else
                    singNum = 0
                end

                borwText = borwText .. charValue
                index = index + 1
            end


        elseif byteValue >= 192 and byteValue < 224 then
            borwText = borwText .. string.sub(text, index, index + 1)
            index = index + 2
        elseif  byteValue >= 224 and byteValue <= 239 then
            borwText = borwText .. string.sub(text, index, index + 2)
            index = index + 3
        else
            Log:W("Invalid code")
            break
        end
    end

    return borwText
end

function BrowMgr:filterBrowStr(text, isVip, replaceStr)
    local index = 1
    local len = string.len(text)
    local browStr = {}
    while len >= index do
        local char = string.sub(text, index, index)
        if char == "#" then
            local three = string.sub(text, index + 1, index + 3)
            local two = string.sub(text, index + 1, index + 2)
            local one = string.sub(text, index + 1, index + 1)
            local threeNum = tonumber(three)
            local twoNum = tonumber(two)
            local oneNum = tonumber(one)
            local hasFinished = false

            if threeNum and isVip then
                -- VIP表情， 201 - 280
                if threeNum >= Const.VIPBROW_STARTINDEX and threeNum <= Const.VIPBROW_ENDINDEX then
                    table.insert(browStr, string.sub(text, index, index + 3))
                    index = index + 3
                    hasFinished = true
                end
            end

            if twoNum and (not hasFinished) then
                if twoNum >= Const.NORMALBROW_STARTINDEX and twoNum <= Const.NORMALBROW_ENDINDEX then
                    local genderStr = string.sub(text, index + 3, index + 3)
                    if (genderStr == "m" or genderStr == "f") and (not EXPRESSION_CONFIG[twoNum]) then
                        -- 带性别的表情
                        table.insert(browStr, string.sub(text, index, index + 3))
                        index = index + 3
                    else
                        -- 不带性别的表情
                        table.insert(browStr, string.sub(text, index, index + 2))
                        index = index + 2
                    end

                    hasFinished = true
                end
            end

            if oneNum and (not hasFinished) then
                local genderStr = string.sub(text, index + 2, index + 2)
                if (genderStr == "m" or genderStr == "f") and (not EXPRESSION_CONFIG[twoNum]) then
                    -- 带性别的表情
                    table.insert(browStr, string.sub(text, index, index + 2))
                    index = index + 2
                else
                    -- 不带性别的表情
                    table.insert(browStr, string.sub(text, index, index + 1))
                    index = index + 1
                end
            end
        end

        index = index + 1
    end

    for i = 1, #browStr do
        text = string.gsub(text, browStr[i], replaceStr)
    end

    return text
end

-- 获取text中的表情编号列表
function BrowMgr:getBrowListFromStr(text)
    local list = {}
    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)
    local singNum = 0

    while len >= index do
        local charValue = string.sub(text, index, index)
        local byteValue = string.byte(charValue, 1)
        if byteValue < 128 then
            if string.match(charValue,"(%d)")and singNum % 2 == 1  then -- 数字且连续“#”个数为奇数个，往后找表情编号
                local numStr = charValue
                for i = 1, len do
                    if tonumber(numStr) == 0 and i == 1 then -- 第一位为0的情况，直接插入
                        table.insert(list, tonumber(numStr))
                        index = index + 1
                        break
                    end

                    if tonumber(numStr) > vipBrowEndIndex then -- 超过表情范围，回退一位
                        local numChars = string.sub(numStr, 1, string.len(numStr) - 1)
                        if (tonumber(numChars) > vipBrowStartIndex and BrowMgr:getVipType() == 0)
                            or (tonumber(numChars) < vipBrowStartIndex and tonumber(numChars) > normalBrowMax) then
                            -- 如果是vip表情符且玩家不是vip或无效表情符，去掉最后一位
                            numChars = string.sub(numChars, 1, string.len(numChars) - 1)
                            index = index - 1
                        end

                        table.insert(list, tonumber(numChars))

                        numStr = ""
                        index = index + i - 1
                        break
                    else
                        local netCharValue =  string.sub(text, index + i, index + i)
                        if not string.match(netCharValue,"(%d)") then  -- 非数字，回退一位
                            local numChars = string.sub(text, index, index + i - 1)
                            if (tonumber(numChars) > vipBrowStartIndex and BrowMgr:getVipType() == 0)
                                or (tonumber(numChars) < vipBrowStartIndex and tonumber(numChars) > normalBrowMax) then
                                -- 如果是vip表情符且玩家不是vip或无效表情符，去掉最后一位
                                numChars = string.sub(numChars, 1, string.len(numChars) - 1)
                                index = index - 1
                            end

                            table.insert(list, tonumber(numChars))

                            numStr = ""
                            index = index + i
                            break
                        else
                            numStr = numStr .. netCharValue
                        end
                    end
                end

                singNum = 0
            else
                if charValue == "#" then
                    singNum = singNum + 1
                else
                    singNum = 0
                end

                index = index + 1
            end
        elseif byteValue >= 192 and byteValue < 224 then
            index = index + 2
        elseif  byteValue >= 224 and byteValue <= 239 then
            index = index + 3
        else
            Log:W("Invalid code")
            break
        end
    end

    return list
end

-- 发送表情时，需要更新表情使用时间
function BrowMgr:updateBrowUseTime(text)
    local useTime = gf:getServerTime()
    local browList = BrowMgr:getBrowListFromStr(text)
    local count = #browList
    for i = 1, count do
        BrowMgr:setBrowUseTimeInfo(browList[i], useTime)
    end

    if count > 0 then
        BrowMgr:saveBrowUseTime()
    end
end

-- 获取聊天表情根据表情排序从高到低的表
function BrowMgr:getBrowUseTimeOrderList(type)
    if #NORMARL_BROW_TIME == 0 then
        -- 使用时间表情数据未初始化
        BrowMgr:initBrowUseTime()
    end

    local list = {}
    local timeMap
    local starIndex
    local endIndex
    if type == "isVip" then
        timeMap = VIP_BROW_TIME
        starIndex = Const.VIPBROW_STARTINDEX
        endIndex = Const.VIPBROW_ENDINDEX
    else
        timeMap = NORMARL_BROW_TIME
        starIndex = Const.NORMALBROW_STARTINDEX
        endIndex = Const.NORMALBROW_ENDINDEX
    end

    local count = endIndex - starIndex + 1
    for i = 1 , count do
        table.insert(list, i + starIndex - 1)
    end

    table.sort(list, function(l, r)
        if timeMap[l] > timeMap[r] then return true end
        if timeMap[l] < timeMap[r] then return false end
        if l < r then return true end
        if l > r then return false end
    end)

    return list
end

-- 设置表情时间数据
function BrowMgr:setBrowUseTimeInfo(key, value)
    if NORMARL_BROW_TIME[key] then
        NORMARL_BROW_TIME[key] = value
    elseif VIP_BROW_TIME[key] then
        VIP_BROW_TIME[key] = value
    end
end

-- 保存聊天表情时间数据
function BrowMgr:saveBrowUseTime()
    local saveData = "return {\n"

    for k, v in pairs(NORMARL_BROW_TIME) do
        saveData = saveData .. string.format("[%d] = %d,\n", k, v)
    end

    for k, v in pairs(VIP_BROW_TIME) do
        saveData = saveData .. string.format("[%d] = %d,\n", k, v)
    end

    saveData = saveData .. "}"

    gfSaveFile(saveData, BROW_TIME_SAVE_PATH)
end

-- 初始化聊天表情时间数据
function BrowMgr:initBrowUseTime()
    -- 先初始化时间默认值，都为0
    NORMARL_BROW_TIME = {}
    VIP_BROW_TIME = {}
    for i = Const.NORMALBROW_STARTINDEX, Const.NORMALBROW_ENDINDEX do
        NORMARL_BROW_TIME[i] = 0
    end

    for i = Const.VIPBROW_STARTINDEX, Const.VIPBROW_ENDINDEX do
        VIP_BROW_TIME[i] = 0
    end

    -- 尝试使用文件更新数据
    local data = {}
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. BROW_TIME_SAVE_PATH
    local ok = pcall(function ()
        data = dofile(filePath)
    end)

    if data then
        for k, v in pairs(data) do
            k = tonumber(k)
            v = tonumber(v)
            if k >= Const.NORMALBROW_STARTINDEX and k <= Const.NORMALBROW_ENDINDEX then
                NORMARL_BROW_TIME[k] = v
            end

            if k >= Const.VIPBROW_STARTINDEX and k <= Const.VIPBROW_ENDINDEX then
                VIP_BROW_TIME[k] = v
            end 
        end
    end
end
