-- AlchemyMgr.lua
-- created by zhengjh Apr/21/2015
-- 炼丹管理器

local AlchemyItem = require("cfg/AlchemyItem")
AlchemyMgr = Singleton()

local ALL_ITEM_LIST =       -- 所有大类别
{
    [CHS[5410245]] = {
        CHS[3002249], -- 凝香幻彩
        CHS[3002250], -- 炫影霜星
        CHS[3002251], -- 风寂云清
        CHS[3002252], -- 枯月流魂
        CHS[3002253], -- 雷极弧光
        CHS[3004454], -- 冰落残阳

    },

    [CHS[4200733]] = {
        --"竹马", "毽子", "蹴球", "弹弓", "陀螺", "风筝"
        CHS[4200735], CHS[4200736], CHS[4200737], CHS[4200738], CHS[4200739], CHS[4200740],
    },

    [CHS[5410246]] = {
        CHS[4100422], -- 芙蓉石
        CHS[4100423], -- 红宝石
    CHS[4100424], -- 蓝宝石
    },
    [CHS[5410247]] = {
        CHS[5410239], -- 火眼金睛
        CHS[5410240], -- 通天令牌
        CHS[5410241], -- 血玲珑
        CHS[5410242], -- 法玲珑
        CHS[5410243], -- 中级血玲珑
        CHS[5410244], -- 中级法玲珑
    },
}

function AlchemyMgr:init()
    self.name2Type = {}
    for type, itemList in pairs(ALL_ITEM_LIST) do
        for i = 1, #itemList do
            self.name2Type[ALL_ITEM_LIST[type][i]] = ALL_ITEM_LIST[type][i]
        end
    end
end

-- 获取合成类别
function AlchemyMgr:getAllItemType()
    return ALL_ITEM_LIST
end

-- 材料充足队列
function AlchemyMgr:getFullItem()
    return self.fullItemList
end

-- 获取可合成耐久道具的所有方案
-- 优先选择合成的耐久度最大的方案，耐久度相同的道具再优先选择限时->限制->非限制
function AlchemyMgr:getNaijiuAlchemyMethods(items, itemInfo)
    local maxValue = itemInfo["max_value"]
    local mult = (maxValue / 10000)
    if maxValue > 10000 then
        -- 玲珑类道具耐久度值过大，导致运算复杂度过高，故将数值压低到 10000 再进行计算
        maxValue = maxValue / mult
    end

    local allCout = #items
    for i = allCout, 1, -1 do
        if string.match(items[i]["name"], CHS[5410249]) then
            -- 取出描述中的血量或法力数值
            local num = string.gsub(items[i]["extra_desc"], "%D", "")
            items[i]["durability"] = tonumber(num) or 0
        end

        if items[i]["durability"] > 10000 then
            items[i]["value"] = math.ceil(items[i]["durability"] / mult)
        else
            items[i]["value"] = items[i]["durability"]
        end
    end

    local function func(l, r)
        -- 耐久
        if l.value > r.value then return true end
        if l.value < r.value then return false end

        -- 限时道具排序
        local lt = InventoryMgr:getItemTimeLimitedOrder(l)
        local rt = InventoryMgr:getItemTimeLimitedOrder(r)
        if lt < rt then return true end
        if lt > rt then return false end

        -- 限制道具排序
        local lt = InventoryMgr:getItemLimitedOrder(l)
        local rt = InventoryMgr:getItemLimitedOrder(r)
        if lt < rt then return true end
        if lt > rt then return false end
    end

    table.sort(items, func)

    -- 与最小的耐久度都无法合成，直接排除，不加入方案的计算
    if allCout > 0 then
        local minValue = items[allCout]["value"]
        for i = allCout - 1, 1, -1 do
            if items[i]["value"] + minValue > maxValue then
                table.remove(items, i)
            end
        end

        allCout = #items
    end

    local methods = {}
    local hasFind = false

    if allCout <= 1 then
        return methods, 0
    end

    local canAlchemyCou = 0
    repeat
        -- 找出可合成最大耐久的方案
        local dp = {}
        local sumQue = {0}

        -- 计算可合成的最大耐久度，并记录路径
        local count = #items
        local maxSum = 0
        for i = 1, count do
            local value = items[i].value
            for j = 1, #sumQue do
                local v = value + sumQue[j]
                if v <= maxValue and not dp[v] then
                    dp[v] = i
                    maxSum = math.max(maxSum, v)
                    table.insert(sumQue, v)
                end
            end
        end

        -- 将找出的可合成最大耐久的的方案取出
        local hasFind = false
        local bindAmount = 0
        local method = {}
        repeat
            if not dp[maxSum] then
                break
            end

            local index = dp[maxSum]
            table.insert(method, items[index].iid_str)
            maxSum = maxSum - items[index].value

            if InventoryMgr:isLimitedItemForever(items[index]) then
                -- 方案中绑定道具的个数
                bindAmount = bindAmount + 1
            end

            table.remove(items, index)  -- 已用于此方案的合成，移除，不参与下一方案的计算
            hasFind = true
        until false

        local cou = #method
        if cou > 1 then
            -- 合成个数至少两个才可参与合成
            table.insert(methods, method)
            method.bindAmount = bindAmount
            canAlchemyCou = canAlchemyCou + cou
        end
    until not hasFind

    return methods, canAlchemyCou
end

function AlchemyMgr:getOneItemList(oneTypeItem, type, limted, naijiuLimited)
    local ontItemInfo = {}
    ontItemInfo["index"] = oneTypeItem["index"]
    local itemList = oneTypeItem["needItems"]    -- 合成需要的材料
    ontItemInfo["itemsList"] = {}
    local count = 0
    ontItemInfo["targetItem"] = {}
    ontItemInfo["targetItem"]["name"] = oneTypeItem["name"]
    ontItemInfo["targetItem"]["level"] = oneTypeItem["level"]
    ontItemInfo["targetItem"]["bind"] = oneTypeItem["bind"]  -- 是否永久限制交易

    for j = 1, #itemList do
        local amount = 0  -- 材料 等级几的个数
        local bindAmount = 0
        local itemInfo = itemList[j]

        local realItemInfo = {}   -- 合成材料真实所拥有的材料
        if type == CHS[5410247] then
            -- 耐久道具不限数量合成，根据耐久值 max_value 计算数量
            local items = InventoryMgr:getItemsByName(itemInfo["names"], naijiuLimited)
            local methods
            methods, amount = AlchemyMgr:getNaijiuAlchemyMethods(items, itemInfo)
            realItemInfo["max_value"] = itemInfo["max_value"]  -- 合成后属性的最大上限
            realItemInfo["methods"] = methods    -- 可合成的方案
            count = #methods  -- 可合成数量
        elseif type == CHS[4200733] then
            amount, bindAmount = InventoryMgr:getAmountByNameIsForeverBindLevel(itemInfo["name"], limted)

            if j == 1 then
                count = math.floor(amount / itemInfo["num"])
            elseif count > math.floor(amount / itemInfo["num"]) then
                count = math.floor(amount / itemInfo["num"])
            end
        else
            amount, bindAmount = InventoryMgr:getAmountByNameIsForeverBindLevel(itemInfo["name"], limted, itemInfo["level"])

            if j == 1 then
                count = math.floor(amount / itemInfo["num"])
            elseif count > math.floor(amount / itemInfo["num"]) then
                count = math.floor(amount / itemInfo["num"])
            end
        end

        realItemInfo["name"] = itemInfo["name"]
        realItemInfo["oneItemNeedNum"] = itemInfo["num"] -- 合成一份材料所需要的改料数量
        realItemInfo["level"] = itemInfo["level"]
        realItemInfo["bindAmount"] = bindAmount   -- 限制道具数量
        realItemInfo["num"] = amount         -- 该材料总共数量
        realItemInfo["type"] = type

        ontItemInfo["itemsList"][j] = realItemInfo
    end

    ontItemInfo["count"] = count

    return ontItemInfo
end

function AlchemyMgr:updateOneItemList(name, limted, naijiuLimited)
    local updateType
    local oneItemList = nil
    local ontFullItemList = nil
    local nameEx = ""
    for type, oneTypeItems in pairs(AlchemyItem) do
        for i = 1, #oneTypeItems do
            if self.name2Type[oneTypeItems[i]["name"]] and name == oneTypeItems[i]["name"]
                or (self.name2Type[oneTypeItems[i]["showName"]] and string.match(name, oneTypeItems[i]["showName"]))  then
                local ontItemInfo = self:getOneItemList(oneTypeItems[i], type, limted, naijiuLimited)

                -- 所有道具
                if not oneItemList then
                    oneItemList = {}
                end

                table.insert(oneItemList, ontItemInfo)

                -- 材料充足的道具
                if ontItemInfo["count"] > 0 then
                    if not ontFullItemList then
                        ontFullItemList = {}
                    end

                    table.insert(ontFullItemList, ontItemInfo)
                end

                updateType = type
                if updateType == CHS[4200733] then
                    nameEx = oneTypeItems[i]["showName"]
                end
            end
        end
    end

    if updateType then
        if nameEx ~= "" then
            self.allItemList[updateType][nameEx] = oneItemList
            self.fullItemList[updateType][nameEx] = ontFullItemList
        else
            self.allItemList[updateType][name] = oneItemList
            self.fullItemList[updateType][name] = ontFullItemList
        end
    end
end

-- 所有材料队列
function AlchemyMgr:getItemList(limted, naijiuLimited)
	local allItemList = {}     -- 所有材料队列
    local fullItemList = {}    -- 材料充足队列

    for type, oneTypeItems in pairs(AlchemyItem) do
        local oneTypeItemList = {}
        local ontTypeFullItemList = {}
        if naijiuLimited == nil and type == CHS[5410247] and self.allItemList and self.allItemList[type] then
            -- 不重新生成耐久度合成方案
            fullItemList[type] = self.fullItemList[type]
            allItemList[type] = self.allItemList[type]
        elseif type == CHS[4200733] then
            for i = 1, #oneTypeItems do
                if self.name2Type[oneTypeItems[i]["showName"]] then
                    local ontItemInfo = self:getOneItemList(oneTypeItems[i], type, limted, naijiuLimited)

                    -- 所有道具
                    if oneTypeItemList[oneTypeItems[i]["showName"]] == nil then
                        oneTypeItemList[oneTypeItems[i]["showName"]] = {}
                    end
                    table.insert(oneTypeItemList[oneTypeItems[i]["showName"]], ontItemInfo)

                    -- 材料充足的道具
                    if ontItemInfo["count"] > 0 then
                        if ontTypeFullItemList[oneTypeItems[i]["showName"]] == nil then
                            ontTypeFullItemList[oneTypeItems[i]["showName"]] = {}
                        end
                        table.insert(ontTypeFullItemList[oneTypeItems[i]["showName"]], ontItemInfo)
                    end
                end
            end

            allItemList[type] = oneTypeItemList
            fullItemList[type] = ontTypeFullItemList
        else
            for i = 1, #oneTypeItems do
                if self.name2Type[oneTypeItems[i]["name"]] then
                    local ontItemInfo = self:getOneItemList(oneTypeItems[i], type, limted, naijiuLimited)

                    -- 所有道具
                    if oneTypeItemList[oneTypeItems[i]["name"]] == nil then
                        oneTypeItemList[oneTypeItems[i]["name"]] = {}
                    end
                    table.insert(oneTypeItemList[oneTypeItems[i]["name"]], ontItemInfo)

                    -- 材料充足的道具
                    if ontItemInfo["count"] > 0 then
                        if ontTypeFullItemList[oneTypeItems[i]["name"]] == nil then
                            ontTypeFullItemList[oneTypeItems[i]["name"]] = {}
                        end
                        table.insert(ontTypeFullItemList[oneTypeItems[i]["name"]], ontItemInfo)
                    end
                end
            end

            allItemList[type] = oneTypeItemList
            fullItemList[type] = ontTypeFullItemList
        end
    end

    self.allItemList = allItemList
    self.fullItemList = fullItemList
    return allItemList
end

function AlchemyMgr:alchemy(index, type)
    local data = {}
    data["index"] = index
    data["type"] = type
    gf:CmdToServer("CMD_MAKE_PILL", data)
end

function AlchemyMgr:alchemyNaijiu(data, type)
    gf:CmdToServer("CMD_MERGE_DURABLE_ITEM", data)
end


AlchemyMgr:init()

return AlchemyMgr
