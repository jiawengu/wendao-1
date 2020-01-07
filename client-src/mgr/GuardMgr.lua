-- GuardMgr.lua
-- Created by chenyq Dec/4/2014
-- 守护管理器

local DataObject = require('core/DataObject')
GuardMgr = Singleton()

GuardMgr.objs = {}
GuardMgr.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))


-- 守护装备的类型
local GUARD_EQUIP_TYPE = { "weapon", "helmet", "armor", "boot"}

-- 守护装备属性对应的键值
local GUARD_ATTR_MAP = {
    def         = CHS[3000012],
    max_life    = CHS[3000103],
    power       = CHS[4000032],
    speed       = CHS[4000092]
}

-- 守护强化所需完成度系数
local GUARD_STRENGTH_COM_MAP = {
    7, 6, 5,
}

-- 守护亲密度加成数值
local GUARD_INTIMACY_EFFECT = {
    -- 亲密度                              物理连击率                                   物理连击数                              物理必杀率                    法术必杀率
    {intimacy =      0, double_hit_rate =  0, double_hit_time = 0, stunt_rate =  0, mstunt_rate =  0},
    {intimacy =  10000, double_hit_rate =  5, double_hit_time = 4, stunt_rate =  5, mstunt_rate =  3},
    {intimacy = 100000, double_hit_rate = 10, double_hit_time = 4, stunt_rate = 10, mstunt_rate =  7},
    {intimacy = 300000, double_hit_rate = 15, double_hit_time = 4, stunt_rate = 15, mstunt_rate = 10},
    {intimacy = 500000, double_hit_rate = 20, double_hit_time = 4, stunt_rate = 20, mstunt_rate = 13},
}

-- 守护品质图片
local GUARD_RANK_IMAGE =
    {
        [GUARD_RANK.TONGZI] = ResMgr.ui.guard_attr_rank1,
        [GUARD_RANK.ZHANGLAO] = ResMgr.ui.guard_attr_rank2,
        [GUARD_RANK.SHENLING] = ResMgr.ui.guard_attr_rank3,
    }


-- 守护品质头像边框图片
local GUARD_RANK_PORTRAIT_IMAGE =
    {
        [GUARD_RANK.TONGZI] = ResMgr.ui.guard_rank1,
        [GUARD_RANK.ZHANGLAO] = ResMgr.ui.guard_rank2,
        [GUARD_RANK.SHENLING] = ResMgr.ui.guard_rank3,
    }

-- 培养最高等级
local MAX_DEVELOP_LEVEL = 16

-- 守护装备改造的最高等级
local EQUIP_MAX_LEV = 12

local GUARD_GET_NUM = 15

-- 获取可携带的最大守护数量
function GuardMgr:getMaxGuardNum()
    return GUARD_GET_NUM
end

-- 获取守护配置表
function GuardMgr:getGuardCfg()
    return self.cfg
end

-- 获取守护亲密度加成配置
function GuardMgr:getGuardIntimacyEffectCfg()
    return GUARD_INTIMACY_EFFECT
end

-- 更新守护数据
function GuardMgr:updateGuard(data)
    if not data or not data.id then
        return
    end

    local guard = self.objs[data.id]
    if not guard then
        guard = DataObject.new()
        self.objs[data.id] = guard
    end

    guard:absorbBasicFields(data)

end

function GuardMgr:clearData()
    self.objs = {}
end

function GuardMgr:getGuard(id)
    return self.objs[id]
end

function GuardMgr:getGuardPolar(guardName)
    if nil == self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    for _,guardInfo in pairs(self.cfg) do
        if guardName == guardInfo[4] then
            return guardInfo[3]
        end
    end

    return ""
end

-- 通知界面弹出快捷使用守护界面
function GuardMgr:notifyShowFastUserGuard(level)
    if not level then
        level = Me:queryBasicInt("level")
    end
    local num = self:getCurCallGuardNum()
    if num >= 1 and num < 4 then
        local guardData = self:getMinLevelGuard(level)

        if guardData then
            local fastGuard = DlgMgr:openDlg("ConvenientCallGuardDlg")
            if fastGuard then
                fastGuard:setInfo(guardData)
            end
        end
    end
end

function GuardMgr:MSG_CALL_GUARD_SUCC(data)
    self:notifyShowFastUserGuard()
end

-- 

function GuardMgr:getGuardbriefIntro(guardName)
    if nil == self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    for _,guardInfo in pairs(self.cfg) do
        if guardName == guardInfo[4] then
            return guardInfo[10]
        end
    end

    return ""
end
-- 获取所有守护，不管召唤未召唤
function GuardMgr:getAllGuard(level)
    if nil == self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    if nil == self.cfg then return end

    local guardArr = {}
    local meLevel = Me:getLevel()
    local maxLevel = 100000
    for i = 1, #self.cfg do
        local guardLevel = self.cfg[i][1]
        -- 可召唤，下一级可召唤，已拥有
        if guardLevel <= self:getNextCallLevel()
            or guardLevel == maxLevel 
            or GuardMgr:isGuardExist(self.cfg[i][4]) then
            local guardInfo = {
                callLevel = self.cfg[i][1],
                icon      = self.cfg[i][2],
                polarStr  = self.cfg[i][3],
                raw_name  = self.cfg[i][4],
                callCoin  = self.cfg[i][7],
                rank      = self.cfg[i][8],
                briefIntro= self.cfg[i][10],
                name      = self.cfg[i][4],
                desc1     = self.cfg[i][5],
                desc2     = self.cfg[i][11],
                desc3     = self.cfg[i][12],
            }

            local guard = GuardMgr:getGuardByRawName(self.cfg[i][4])
            if nil ~= guard then
                guardInfo.rank            = guard:queryBasicInt("rank")
                guardInfo.polarStr        = gf:getPolar(guard:queryBasicInt("polar"))
                guardInfo.id              = guard:queryBasicInt("id")
                guardInfo.combat_guard    = guard:queryBasicInt("combat_guard")
                guardInfo.use_skill_d     = guard:queryBasicInt("use_skill_d")
                guardInfo.combat_index    = guard:queryBasicInt("combat_guard_index")
                guardInfo.name            = guard:queryBasic("name")
                guardInfo.level           = guard:queryBasic("level")
                guardInfo.has             = 1
            else
                guardInfo.id              = 0
                guardInfo.combat_guard    = 0
                guardInfo.use_skill_d     = 0
                guardInfo.combat_index    = 5
                guardInfo.has             = 0
            end

            guardInfo.polar = gf:getIntPolar(guardInfo.polarStr)

            table.insert(guardArr, guardInfo)
            maxLevel = guardLevel
        end
    end

    return guardArr
end

-- 获取守护装备信息
-- equipType 可取值的值为："weapon"、"helmet"、"armor" 和 "boot"
-- 各部件均具有如下字段：
--      icon
--      name            名称
--      rebuild_level   改造等级
--      degree          当前完成度
--      max_degree      最大完成度
--      cash            达到下一完成度需要消耗的金钱
--      cost_num        达到下一完成度需要消耗的道具数量
-- 武器特有字段：power   基础伤害
-- 帽子特有字段：max_life、def 气血和防御
-- 衣服特有字段：max_life、def 气血和防御
-- 鞋子特有字段：speed、        def 速度和防御
function GuardMgr:getEquip(guardId, equipType)
    local guard = self:getGuard(guardId)
    if not guard then
        return
    end

    local found = false
    for i = 1, #GUARD_EQUIP_TYPE do
        if equipType == GUARD_EQUIP_TYPE[i] then
            found = true
        end
    end

    if not found then
        Log:W('GuardMgr:getEquip: equipType:%s is invalid!', equipType)
        return
    end

    return guard:queryBasic(equipType)
end

-- 获取守护培养属性信息
-- 返回的信息包含如下字段：
-- power:基础攻击
-- def:基础防御
-- rebuild_level:培养等级
-- degree：进度
function GuardMgr:getGrowAttrib(guardId)
    local guard = self:getGuard(guardId)
    local growAttrib
    if guard then
        growAttrib = guard:queryBasic('grow_attrib')
    end

    if type(growAttrib) ~= "table" then
        -- 数据不存在，均设置为 0
        growAttrib = {
            rebuild_level = 1,
            degree_32     = 0,
            power         = 0,
            def           = 0,
        }
    end

    return growAttrib
end

-- 守护下一级培养信息
function GuardMgr:getNextLevGrowAttrib(guardId)
    local growAttrib = self:getGrowAttrib(guardId)
    local nextLevGrowAtrrib = {}
    nextLevGrowAtrrib["power"] = growAttrib["power"]
    nextLevGrowAtrrib["def"] = growAttrib["def"]
    nextLevGrowAtrrib["rebuild_level"] = growAttrib["rebuild_level"] + 1
    nextLevGrowAtrrib["degree_32"] = 0

    return nextLevGrowAtrrib
end

-- 获取可召唤的守护列表
-- 返回两个数组，第一个为当前可召唤的守护列表，第二个为不可召唤中等级最小的守护列表
function GuardMgr:getCallGuardList()
    if not self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    local callList = {}      -- 当前可召唤守护列表
    local nextCalllist = {}  -- 当前不可召唤守护列表
    local meLevel = Me:getLevel()
    local maxLevel = 100000
    for i = 1, #self.cfg do
        local guardLevel = self.cfg[i][1]
        if guardLevel <= self:getNextCallLevel() then
            -- 当前可召唤的守护
            table.insert(callList, self.cfg[i])
            --[[  elseif guardLevel < maxLevel then
            -- 当前不可召唤的守护
            nextCalllist = {}
            maxLevel = guardLevel
            table.insert(nextCalllist, self.cfg[i])
            elseif guardLevel == maxLevel then
            table.insert(nextCalllist, self.cfg[i])
            end]]
        end
    end

    return callList
end


function GuardMgr:getNextCallLevel()
    local meLevel = Me:getLevel()
    local nextCallLevel = 100000

    for i = 1, #self.cfg do
        local guardLevel = self.cfg[i][1]
        if guardLevel < nextCallLevel and guardLevel > meLevel then
            nextCallLevel =  guardLevel
        end
    end

    return nextCallLevel
end

function GuardMgr:getGuardCalledInfoByRawName(rawName)
    if not self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    for i = 1, #self.cfg do
        if self.cfg[i][4] == rawName then
            return self.cfg[i]
        end
    end
end

function GuardMgr:getGuardDescByRawName(rawName)
    local guardInfo = GuardMgr:getGuardCalledInfoByRawName(rawName)
    local desc = {
        desc1     = guardInfo[5],
        desc2     = guardInfo[11],
        desc3     = guardInfo[12],
    }

    return desc
end

function GuardMgr:getGarudDescirbe()
    return require(ResMgr:getCfgPath('GuardDescribe.lua'))
end

function GuardMgr:getGuardDescByPolarAndRank(polar, rank)
    if not rank or not polar then  return end
    local desc = self:getGarudDescirbe()
    return desc[polar][rank] 
end

-- 获取守护上限
function GuardMgr:getGuardMaxCount()
    return #self.cfg
end

-- 根据等级获取守护列表
function GuardMgr:getCallGuardListByLevel(level)
    if not self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    local callList = {}
    local nextCalllist = {}
    local meLevel = level
    local maxLevel = 100000
    for i = 1, #self.cfg do
        local guardLevel = self.cfg[i][1]
        if guardLevel <= meLevel then
            -- 当前可召唤的守护
            table.insert(callList, self.cfg[i])
        elseif guardLevel < maxLevel then
            nextCalllist = {}
            maxLevel = guardLevel
            table.insert(nextCalllist, self.cfg[i])   -- 下一次可召唤的守护列表
        elseif guardLevel == maxLevel then
            table.insert(nextCalllist, self.cfg[i])
        end
    end

    return callList, nextCalllist
end

-- 当前等级是否有新的可召唤守护
function GuardMgr:hasNewGuard(level)
    if not self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    for i = 1, #self.cfg do
        local guardLevel = self.cfg[i][1]
        if guardLevel == level then
            return true
        end
    end

    return false
end

-- 是否有当前等级可召唤的守护　　guardType   1金钱，２为元宝，3通用
function GuardMgr:isHaveCanGetGuard(guardType, meLevel)
    if not self.cfg then
        self.cfg = require(ResMgr:getCfgPath('GuardInfo.lua'))
    end

    local isExsitGuard, guardNameTab
    guardNameTab = {}
    for i = 1, #self.cfg do

        local guardLevel = self.cfg[i][1]
        local rawName = self.cfg[i][4]
        local costType = self.cfg[i][6]
        if guardLevel <= meLevel and not self:isGuardExist(rawName) then
            if costType == 1 and guardType == 1 then
                isExsitGuard = true
                table.insert(guardNameTab, rawName)
            elseif costType == 0 and guardType == 2 then
                isExsitGuard = true
                table.insert(guardNameTab, rawName)
            elseif guardType == 3 then
                isExsitGuard = true
                table.insert(guardNameTab, rawName)
            end
        end
    end

    return isExsitGuard, guardNameTab
end

function GuardMgr:isGuardExist(raw_name)
    for id, guard in pairs(self.objs) do
        if guard:queryBasic('raw_name') == raw_name then
            return true
        end
    end

    return false
end

function GuardMgr:getGuardByRawName(rawName)
    for id, guard in pairs(self.objs) do
        if guard:queryBasic('raw_name') == rawName then
            return guard
        end
    end
end

-- 获取可历练的守护
function GuardMgr:getGuardCanBeExp()
    local myLevel = Me:queryBasicInt("level")
    for id, guard in pairs(self.objs) do
        local rank_now = guard:queryBasicInt("rank")
        if rank_now == GUARD_RANK.TONGZI and myLevel >= 30 then
            return guard
        elseif rank_now == GUARD_RANK.ZHANGLAO and myLevel >= 65 then
            return guard
        end
    end

    return nil
end

function GuardMgr:MSG_GUARDS_REFRESH(data)
    for i = 1, data.count do
        self:updateGuard(data[i])
    end
end

function GuardMgr:MSG_GUARD_UPDATE_EQUIP(data)
    -- 装备信息直接存储在守护数据中
    self:updateGuard(data)
end

function GuardMgr:MSG_GUARD_UPDATE_GROW_ATTRIB(data)
    -- 属性培养信息直接存储在守护数据中
    self:updateGuard(data)
end

-- 获取是否有存在守护
function GuardMgr:haveGuard()
    for _, pet in pairs(self.objs) do
        return true
    end

    return false
end

-- 获取现在拥有的守护个数
function GuardMgr:haveGuardNum()
    local num = 0
    for _, pet in pairs(self.objs) do
        num = num + 1
    end

    return num
end


-- 获取守护装备的信息
-- name         装备名称
-- icon         装备图标
-- level        装备等级
-- star         装备星级
-- attr         属性信息 （气血、伤害、法力、防御、速度等）
-- addition     加成信息
-- grade        装备评分
-- complete、comCount装备改造进度(已完成、总共需要完成)
-- stone_cost   需要消耗的晶石
-- money_cost   需要消耗的金钱
function GuardMgr:getGuardEquipsById(guardId, equipType)
    if nil == guardId then return end

    local guard = self:getGuard(guardId)
    local equip = self:getEquip(guardId, equipType)
    local equipName = equip.name
    local equipIcon = equip.icon
    local equipLevel, equipStar = Formula:getGuardLevAndStar(equip.rebuild_level)
    local equipGrade = equip.fight_score
    -- 设置装备的属性
    local equipAttr = {}
    for k, v in pairs(equip) do
        for ik, iv in pairs(GUARD_ATTR_MAP) do
            -- 如果相等，则表示有这个字段，需要在表中进行添加字段
            if k == ik then
                equipAttr[k] = v
            end
        end
    end

    -- 设置装备的加成属性
    local equipAdd = {}
    for k, v in pairs(equipAttr) do
        if (GuardMgr:getEquipType(1) == equipType and "power" == k) or ("def" == k) then
            equipAdd[k] = Formula:getGuardEquip(k, equip.rebuild_level)
        end
    end

    local equipMoneyCost = equip.cash
    local equipComplete = equip.degree
    local equipComCount = equip.max_degree
    local equipStoneCost = equip.cost_num
    return {name = equipName, icon = equipIcon, level = equipLevel, star = equipStar, attr = equipAttr, addition = equipAdd, money_cost = equipMoneyCost, grade = equipGrade, complete = equipComplete, comCount = equipComCount, stone_cost = equipStoneCost}
end

-- 获取下一等级守护装备的信息
-- equipName    装备名称
-- equipIcon    装备图标
-- equipLevel   装备等级
-- equipStar    装备星级
-- attr         属性信息 （气血、伤害、法力、防御、速度等）
-- addition     加成信息
-- grade        装备评分
function GuardMgr:getNextGuardEquipsById(guardId, equipType)
    if nil == guardId then return end

    local equip = self:getEquip(guardId, equipType)
    local equipName = equip.name
    local equipIcon = equip.icon
    local equipLevel, equipStar = Formula:getGuardLevAndStar(equip.rebuild_level + 1)

    -- 设置装备的属性
    local equipAttr = {}
    for k, v in pairs(equip) do
        for ik, iv in pairs(GUARD_ATTR_MAP) do
            -- 如果相等，则表示有这个字段，需要在表中进行添加字段
            if k == ik then
                equipAttr[k] = v
            end
        end
    end

    -- 设置装备的加成属性
    local equipAdd = {}
    for k, v in pairs(equipAttr) do
        if (GuardMgr:getEquipType(1) == equipType and "power" == k) or ("def" == k) then
            equipAdd[k] = Formula:getGuardEquip(k, equip.rebuild_level + 1)
        end
    end

    local equipGrade =  self:getFightScore(equip, 1, equipType)

    return {name = equipName, icon = equipIcon, level = equipLevel, star = equipStar, attr = equipAttr, addition = equipAdd, grade = equipGrade}
end

-- 获取属性相应的中文名称
function GuardMgr:getNameByAttrKey(attrKey)
    if nil == attrKey then return nil end

    return GUARD_ATTR_MAP[attrKey]
end

-- 守护装备一键改造
function GuardMgr:upEquipToTop(guardId, equipType)
    if nil == guardId then return end

    return true
end

-- 守护装备普通改造
function GuardMgr:upEquip(guardId, equipType, isToTop, costNum)
    if nil == guardId then return end

    -- 拼接para字符串
    local isTop = 0
    if isToTop then
        isTop = 1
    end

    local para = tostring(isTop) .. equipType

    -- 如果是武器，则喂养五色灵石，否则喂养五色晶石
    local num = 0
    local itemPos = 0
    if GUARD_EQUIP_TYPE[1] == equipType then
        num = InventoryMgr:getAmountByName(CHS[5000046])
        itemPos = InventoryMgr:getItemPosByName(CHS[5000046])
        if num < costNum then
            gf:askUserWhetherBuyItem({ [CHS[5000046]] = costNum  - num})
            return false
        end
    else
        num = InventoryMgr:getAmountByName(CHS[5000049])
        itemPos = InventoryMgr:getItemPosByName(CHS[5000049])
        if num < costNum then
            gf:askUserWhetherBuyItem({ [CHS[5000049]] = costNum  - num })
            return false
        end
    end

    InventoryMgr:feedGuard(guardId, itemPos, para)
    return true
end

function GuardMgr:getEquipType(equipId)
    if nil == equipId then return nil end

    return GUARD_EQUIP_TYPE[equipId]
end

function GuardMgr:getEquipMaxLev()
    return EQUIP_MAX_LEV
end

-- 获取强化信息
-- name         守护名称
-- icon         守护图标
-- level        守护等级
-- strengthlev  强化等级
-- polarNum     所有相性
-- power        伤害
-- complete     本等级已经完成次数
-- comCount     本等级需要完成次数
-- grade        评分
function GuardMgr:getStrengthById(guardId)
    if nil == guardId then return end

    local guard = self:getGuard(guardId)
    local guardName = guard:queryBasic("name")
    local guardIcon = guard:queryBasicInt("icon")
    local guardLevel = guard:queryBasicInt("level")
    local guardStrenLev = guard:queryBasicInt("rebuild_level")
    local guardPolarNum = math.floor(guardStrenLev / 10)
    local guardPower = 0
    if 0 == guardStrenLev then
        guardPower = 0
    else
        guardPower = Formula:getGuardStrengthPower(guardStrenLev, guard:queryBasicInt("rank"))
    end

    local guardCom = guard:queryBasicInt("degree")
    local guardComCount = self:getComCount(guardStrenLev, guard:queryBasicInt("rank"))
    local guardGrade = guard:queryBasic("fight_score")
    return {name = guardName, icon = guardIcon, level = guardLevel, strengthlev = guardStrenLev, polarNum = guardPolarNum, power = guardPower, complete = guardCom, comCount = guardComCount, grade = guardGrade}
end

-- 本等级需要完成次数
function GuardMgr:getComCount(guardStrenLev, rank)
    return  math.floor(guardStrenLev / GUARD_STRENGTH_COM_MAP[rank]) + 1
end

-- 获取下一等级强化信息
-- name         守护名称
-- icon         守护图标
-- level        守护等级
-- guardStrenLev强化等级
-- polarNum     所有相性
-- power        伤害
-- grade        评分
function GuardMgr:getNextStrengthById(guardId)
    if nil == guardId then return end

    local guard = self:getGuard(guardId)
    local guardName = guard:queryBasic("name")
    local guardIcon = guard:queryBasicInt("icon")
    local guardLevel = guard:queryBasicInt("level")
    local guardStrenLev = guard:queryBasicInt("rebuild_level") + 1
    local guardPolarNum = math.floor(guardStrenLev / 10)
    local guardPower = 0
    if 0 == guardStrenLev then
        guardPower = 0
    else
        guardPower = Formula:getGuardStrengthPower(guardStrenLev, guard:queryBasicInt("rank"))
    end
    local guardGrade = self:getNextLevelGuardScore(guardId) or 0 -- 评分，未实现
    return {name = guardName, icon = guardIcon, level = guardLevel, strengthlev = guardStrenLev, polarNum = guardPolarNum, power = guardPower, grade = guardGrade}
end

-- 守护强化
function GuardMgr:upStrengthNormal(guardId)
    if nil == guardId then return end

    local itemPos = InventoryMgr:getItemPosByName(CHS[5000048])
    InventoryMgr:feedGuard(guardId, itemPos, nil)
    return true
end

-- 显示守护名片
function GuardMgr:showGuardCardInfo(guard)
    if guard ~= nil then
        local dlg = DlgMgr:openDlg('GuardCardDlg')
        dlg:setGuardCardInfo(guard)
    end
end

function GuardMgr:getFightScore(equip, addLevel, type)
    local score = 0
    if type == "weapon" then
        score = Formula:calGuardWeaponFightscore(equip.power, equip.rebuild_level + addLevel)
    elseif type == "helmet" or type == "armor" then
        score = Formula:calGuardHelmetOrArmorFightscore(equip.max_life, equip.def, equip.rebuild_level + addLevel)
    elseif type == "boot" then
        score = Formula:calGuardBootFightscore(equip.speed, equip.def, equip.rebuild_level + addLevel)
    end

    return score
end

function GuardMgr:setNextLevelGuardScore(id, score)
    if self.guardsNextLevScore == nil then
        self.guardsNextLevScore = {}
    end

    self.guardsNextLevScore[id] = score
end

function GuardMgr:getNextLevelGuardScore(id)
    if self.guardsNextLevScore ~= nil and self.guardsNextLevScore[id] ~= nil then
        return self.guardsNextLevScore[id]
    else
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_GUARD_NEXT_FIGHTSCORE, id)
    end
end

-- 获取当前召唤的守护数量
function GuardMgr:getCurCallGuardNum()
    local num = 0

    for _, v in pairs(GuardMgr.objs) do
        num = num + 1
    end

    return num
end

-- 获取当前等级最低的守护
function GuardMgr:getMinLevelGuard(level)
    local guardList = self:getCallGuardListByLevel(level)  -- 获取当前可召唤守护列表
    local newList = {}

    local index = 1

    for _, v in pairs(guardList) do
        if not self:isGuardExist(v[4]) and v[6] == 1 then
            table.insert(newList, index, v)
            index = index + 1
        end
    end


    local function sortFunc(l, r)
        -- 排序逻辑
        if l[1] <= r[1] then
            return true
        end

        return false
    end

    table.sort(newList, sortFunc)

    if #newList > 0 then
        return newList[1]
    end

    return nil
end

--
function GuardMgr:getOrderGuardList()
    -- 获取守护列表
    local guards = GuardMgr.objs
    if nil == guards then
        return
    end

    -- 进行守护列表的提取，封装
    local guardArr = {}
    local sepcialGuardId = 0
    for k, v in pairs(guards) do
        table.insert(guardArr, {id = v:queryBasicInt("id"), combat_guard = v:queryBasicInt("combat_guard"), name = v:queryBasic("name"), level = v:queryBasicInt("level"),
            icon = v:queryBasic("icon"), rank = v:queryBasicInt("rank"), polar = v:queryBasic("polar"), use_skill_d = v:queryBasicInt("use_skill_d"),
            combat_index = v:queryBasicInt("combat_guard_index")
        })
    end

    -- 排序规则
    local function sort(l, r)
        return self:sortFunc(l, r)
    end

    -- 分别对参战与休息状态的守护进行排序
    table.sort(guardArr, sort)

    return guardArr
end


-- 获取参战中的守护
function GuardMgr:getFightGuard()
    local guards = GuardMgr.objs
    local fightArr = {}
    for k, v in pairs(guards) do
        if v:queryBasicInt("combat_guard") == 1 then
            table.insert(fightArr, {id = v:queryBasicInt("id"), combat_guard = v:queryBasicInt("combat_guard"), name = v:queryBasic("name"), level = v:queryBasicInt("level"),
                icon = v:queryBasic("icon"), rank = v:queryBasicInt("rank"), polar = v:queryBasic("polar"), use_skill_d = v:queryBasicInt("use_skill_d")})
        end
    end

    return fightArr
end

function GuardMgr:getGuardListByFight(isFight)
    local guard = self:getOrderGuardList()
    local descGuards = {}
    if isFight then
        for i,v in pairs(guard) do
            if v.combat_guard == 1 then
                table.insert(descGuards, v)
            end
        end
    else
        for i,v in pairs(guard) do
            if v.combat_guard == 0 then
                table.insert(descGuards, v)
            end
        end
    end

    return descGuards
end

function GuardMgr:sortFunc(l, r)
    -- 排序逻辑
    if l.combat_guard > r.combat_guard then return true
    elseif l.combat_guard < r.combat_guard then return false
    end

    if l.combat_index < r.combat_index then return true
    elseif l.combat_index > r.combat_index then return false
    end

    if l.use_skill_d > r.use_skill_d then return true
    elseif l.use_skill_d < r.use_skill_d then return false
    end

    if l.rank > r.rank then return true
    elseif l.rank < r.rank then return false
    end

    if l.polar < r.polar then return true
    else return false
    end
end

-- 获取战斗力最强的宠物
function GuardMgr:getFightKingPet(attrib)
    local fightKing
    local score = -1
    for _, pet in pairs(self.objs) do
        if pet:queryBasicInt(attrib) > score then
            score = pet:queryBasicInt(attrib)
            fightKing = pet
        end
    end

    return fightKing
end

function GuardMgr:getGuardInfoByKey(guardName, key)

    local guard = GuardMgr:getGuardCalledInfoByRawName(guardName)
    
    if key == "polar" then
        return guard[3]
    elseif key == "icon" then
        return guard[2]
    elseif key == "rank" then
        return guard[8]
    end
end

function GuardMgr:MSG_GUARD_CARD(data)
    local cardInfo = data["cardInfo"]
    if not cardInfo.icon then
        cardInfo.icon = self:getGuardInfoByKey(cardInfo.raw_name, "icon")
    end
    cardInfo.rank = self:getGuardInfoByKey(cardInfo.raw_name, "rank")
    cardInfo.polar = self:getGuardInfoByKey(cardInfo.raw_name, "polar")
    if not cardInfo.icon then return end
    local dlg = DlgMgr:openDlg("GuardCardDlg")
    dlg:setGuardCardInfo(cardInfo)
end

-- 获取守护防御加成和法伤加成
function GuardMgr:getDevelopBasciAttrib(level)
    local add_attrib = {}
    add_attrib["add_attack"] = 0.15 * (level - 1) + 1.35 -- GUARD_DEVELOP_RATIO["attack"] * level
    add_attrib["add_defense"] = 0.2033 * (level - 1) + 1.83 -- GUARD_DEVELOP_RATIO["defense"] * level

    return add_attrib
end

-- 获取培养的最高等级
function GuardMgr:getMaxDevelopLevel()
    return MAX_DEVELOP_LEVEL
end

-- 历练成功
function GuardMgr:MSG_GUARD_EXPERIENCE_SUCC(data)
    local dlg = DlgMgr:openDlg("AdvancedDlg")
    dlg:setData(data)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_REQUEST_GUARD_ID)
end

-- 获取守护品质图片
function GuardMgr:getGuardRankImage(rank)
    return GUARD_RANK_IMAGE[rank]
end

-- 获取守护品质头像边框
function GuardMgr:getGuardPortraitIamge(rank)
    return GUARD_RANK_PORTRAIT_IMAGE[rank] or GUARD_RANK_PORTRAIT_IMAGE[GUARD_RANK.SHENLING]
end

-- 战斗位置发生变化
function GuardMgr:MSG_LEADER_COMBAT_GUARD(data)
    for i = 1, #data.guardList do
        local guard = GuardMgr.objs[data.guardList[i].guardId]
        if guard then
            guard:setBasic("combat_guard_index", data.guardList[i].guardOrder)
        end
    end
end

MessageMgr:regist("MSG_GUARDS_REFRESH", GuardMgr)
MessageMgr:regist("MSG_GUARD_UPDATE_EQUIP", GuardMgr)
MessageMgr:regist("MSG_GUARD_UPDATE_GROW_ATTRIB", GuardMgr)
MessageMgr:regist("MSG_GUARD_CARD", GuardMgr)
MessageMgr:regist("MSG_GUARD_EXPERIENCE_SUCC", GuardMgr)
MessageMgr:regist("MSG_CALL_GUARD_SUCC", GuardMgr)
MessageMgr:hook("MSG_LEADER_COMBAT_GUARD", GuardMgr, "GuardMgr")

