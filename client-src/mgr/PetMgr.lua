-- PetMgr.lua
-- Created by chenyq Nov/24/2014
-- 宠物管理器

local DataObject = require("core/DataObject")
local Pet = require('obj/Pet')
local Bitset = require("core/Bitset")
local NormalPetList = require (ResMgr:getCfgPath("NormalPetList.lua"))
local VariationPetList = require (ResMgr:getCfgPath("VariationPetList.lua"))
local EpicPetList = require (ResMgr:getCfgPath("EpicPetList.lua"))
local OtherPetList = require (ResMgr:getCfgPath("OtherPetList.lua"))
local JingguaiPetList = require(ResMgr:getCfgPath('JingGuai.lua'))
local JinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))
local CharRidePointOffset = require(ResMgr:getCfgPath('CharRidePointOffset.lua'))
local PetRideInfo = require(ResMgr:getCfgPath('PetRideInfo.lua'))
local PetRideIconInfo = require(ResMgr:getCfgPath("PetRideIconInfo.lua"))
local PetAttribList = require(ResMgr:getCfgPath('PetAttribList.lua'))
local PetAttribListTest = require(ResMgr:getCfgPath('PetAttribListTest.lua'))
local PetIntimacyEffctCfg = require(ResMgr:getCfgPath('PetIntimacyCfg.lua'))
local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))
local CONVERT_PRICE = 1000000

PetMgr = Singleton()

local MAX_PET_CAPCITY = 8  -- 最多可携带 8 只宠物
local MAX_PET_MORPH   = 3

PetMgr.pets = {}            -- 存放所有宠物对象 id --> pet
PetMgr.extraMaps = {}       -- 存放宠物额外信息 id --> extra
PetMgr.defaultSkill = {}    -- 存放默认攻击法术 no --> 法术
PetMgr.idNoMap = {}         -- 存放宠物 id 到宠物变化的信息

PetMgr.feedPets = {}        -- 饲养中的宠物

local petGrowGodSkill = {}

local MAX_PET_DEVELOP_LEVEL = 12 -- 宠物最高强化等级
local FENGLINGWAN_MAX_DAY   = 99 -- 风铃丸最长时间

local STONE_ATTRIB = {
    [CHS[3003357]] = {CHS[3003358], "max_life"},
    [CHS[3004454]] = {CHS[2000057], "max_mana"},
    [CHS[3003359]] = {CHS[3003360], "speed"},
    [CHS[3003361]] = {CHS[3003362], "def"},
    [CHS[3003363]] = {CHS[3003364], "phy_power"},
    [CHS[3003365]] = {CHS[3003366], "mag_power"},
}

local DEVELOP_SKILLS = {CHS[3003439], CHS[3003440], CHS[3003441], CHS[3003442]}

function PetMgr:getDevelopSkillList()
    return DEVELOP_SKILLS
end

function PetMgr:clearData()
    for k, v in pairs(self.pets) do
        self:deletePet(k)
        v:cleanComAbsorbData()
    end

    self.pets = {}
    self.extraMaps = {}
    self.defaultSkill = {}
    self.idNoMap = {}
    self.rideId = nil

    if not DistMgr:getIsSwichServer() then
        self.feedPets = {}
    end

    self.superBossInfo = nil
    self.qishaInfo = nil
end

function PetMgr:getMorphMaxTimes()
    return MAX_PET_MORPH
end

function PetMgr:cleanComAbsorbData()
    for k, v in pairs(self.pets) do
        v:cleanComAbsorbData()
    end
end

-- 获取宠物个数（身上）
function PetMgr:getPetCount()
    local total = 0
    for k, v in pairs(self.pets) do
        total = total + 1
    end

    return total
end

-- 获取所有宠物的最高强化等级
function PetMgr:getPetMaxDevelopLevel()
    return MAX_PET_DEVELOP_LEVEL
end

-- 获取宠物妖石开放等级
function PetMgr:getPetStoneOpenLevel()
    return Const.PET_STONE_OPEN_LEVEL
end

-- 根据 id 获取宠物
function PetMgr:getPetById(id)
    return self.pets[id]
end

-- 获取没有饲养的宠物
function PetMgr:getPetsNotFeed()
    local pets = {}
    for _, pet in pairs(self.pets) do
        if not self:isFeedStatus(pet) then
            table.insert(pets, pet)
        end
    end

    table.sort(pets, function(l,r) return PetMgr:comparePet(l,r) end)

    return pets
end

-- 根据no获取宠物
function PetMgr:getPetByNo(no)
    for _, pet in pairs(self.pets) do
        if pet:queryBasicInt('no') == no then
            return pet
        end
    end
end

-- 根据iid获取宠物
function PetMgr:getPetByIId(iid_str)
    if iid_str == nil or iid_str == "" then
        return
    end

    for _, pet in pairs(self.pets) do
        if pet:queryBasic("iid_str") == iid_str then
            return pet
        end
    end
end

-- 获取参战宠物
function PetMgr:getFightPet()
    for _, pet in pairs(self.pets) do
        if pet:queryBasicInt('pet_status') == 1 then
            return pet
        end
    end
end

-- 获取掠阵宠物
function PetMgr:getRobPet()
    for _, pet in pairs(self.pets) do
        if pet:queryBasicInt('pet_status') == 2 then
            return pet
        end
    end
end

-- 获取变异宠物
function PetMgr:getVariationPetList()
    return VariationPetList
end

-- 初始化战斗中宠物临时数据
function PetMgr:initCombatTempData()
    --[[
    for id, pet in pairs(self.pets) do
        -- 标记宠物可召唤
        local status = pet:queryBasicInt('pet_status')
        local canCall = 1
        if status == 1 then canCall = 0 end

        pet:setExtra('combat_temp_can_call', canCall)
    end]]
end

-- 获取可召唤的宠物列表
function PetMgr:getCanCallPets()
    local petList = {}
    for id, pet in pairs(self.pets) do
        --if pet:queryExtraInt('combat_temp_can_call') == 1 then
        if 1~= pet:queryBasicInt('pet_cannot_call') and not self:isRidePet(id) then
            -- 可召唤
            table.insert(petList, pet)
        end
    end

    if #petList == 0 then return {} end

    -- 按等级排序
    table.sort(petList, function(l, r) return PetMgr:comparePet(l,r) end)

    local lst = {}
    for i = 1, #petList do
        table.insert(lst, {
            id = petList[i]:getId(),
            level = petList[i]:queryBasicInt("level"),
            icon = petList[i]:queryBasicInt('icon'),
        })
    end

    return lst
end

function PetMgr:comparePet(left, right)
    -- 如果比较的是同一个对象，必须要返回false
    if left == right then
        return false
    end

    if left:queryInt("pet_status") == 1 then
        return true
    elseif right:queryInt("pet_status") == 1 then
        return false
    elseif left:queryInt("pet_status") == 2 and right:queryInt("pet_status") == 0 then
        return true
    elseif left:queryInt("pet_status") == 0 and right:queryInt("pet_status") == 2 then
        return false
    end

    -- 骑乘
    if self:isRidePet(left:getId()) then return true end
    if self:isRidePet(right:getId()) then return false end

    if left:queryInt("intimacy") > right:queryInt("intimacy") then return true
    elseif left:queryInt("intimacy") < right:queryInt("intimacy") then return false
    end

    if left:queryInt("level") > right:queryInt("level") then return true
    elseif left:queryInt("level") < right:queryInt("level") then return false
    end

    if left:queryInt("shape") > right:queryInt("shape") then return true
    elseif left:queryInt("shape") < right:queryInt("shape") then return false
    end

    if left:getName() < right:getName() then
        return true
    else
        return false
    end
end

-- 是否是精怪
function PetMgr:isMountPet(pet)
    -- 精怪 御灵
    local mount_type = pet:queryInt("mount_type")
    if mount_type ~= 0 then
        return true
    end

    return false
end

function PetMgr:compareMountPet(left, right)
    -- 如果比较的是同一个对象，必须要返回false
    if left == right then
        return false
    end

    if self:isMountPet(left) and not self:isMountPet(right) then return true end
    if self:isMountPet(right) and not self:isMountPet(left) then return false end

    -- 骑乘
    if self:isRidePet(left:getId()) then return true end
    if self:isRidePet(right:getId()) then return false end

    if left:queryInt("pet_status") == 1 then
        return true
    elseif right:queryInt("pet_status") == 1 then
        return false
    elseif left:queryInt("pet_status") == 2 and right:queryInt("pet_status") == 0 then
        return true
    elseif left:queryInt("pet_status") == 0 and right:queryInt("pet_status") == 2 then
        return false
    end

    if left:queryInt("capacity_level") > right:queryInt("capacity_level") then return true
    elseif left:queryInt("capacity_level") < right:queryInt("capacity_level") then return false
    end

    if left:queryInt("intimacy") > right:queryInt("intimacy") then return true
    elseif left:queryInt("intimacy") < right:queryInt("intimacy") then return false
    end

    local leftRawName = left:queryBasic("raw_name")
    local rightRawName = left:queryBasic("raw_name")
    local leftPetCft = self:getPetCfg(leftRawName)
    local rightPetCfg = self:getPetCfg(rightRawName)
    local leftOrder = leftPetCft.order or 0
    local rightOrder = rightPetCfg.order or 0
    if leftOrder < rightOrder then return true
    elseif leftOrder > rightOrder then return false
    end

    if left:queryInt("shape") > right:queryInt("shape") then return true
    elseif left:queryInt("shape") < right:queryInt("shape") then return false
    end

    if left:queryInt("level") > right:queryInt("level") then return true
    elseif left:queryInt("level") < right:queryInt("level") then return false
    end

    if left:getName() < right:getName() then
        return true
    else
        return false
    end
end

-- 更新参战宠物属性
function PetMgr:setFightPetAttri(data)
    local id = tonumber(data.id)
    local status = tonumber(data.pet_status)
    if id < 0 or status < 0 then
        return
    end

    for _, pet in pairs(self.pets) do
        if pet:getId() == id then
            --[[
            if status == 1 then
                -- 参战了，不允许召唤
                pet:setExtra('combat_temp_can_call', 0)
            end]]

            pet:setBasic('pet_status', status)
        elseif pet:queryBasicInt('pet_status') == status then
            pet:setBasic('pet_status', 0)
        end
    end

    DlgMgr:sendMsg("HeadDlg", "resetPetHeadImgAndUpdate")
    DlgMgr:sendMsg("AutoFightSettingDlg", "refreshMenu")
    DlgMgr:sendMsg("PracticeDlg", "refreshAllData")
end

-- 还可以携带几只宠物
function PetMgr:getFreePetCapcity()
    local count = 0
    for _, pet in pairs(self.pets) do
        count = count + 1
    end

    return MAX_PET_CAPCITY - count
end

-- 获取最大宠物个数
function PetMgr:getPetMaxCount()
    return MAX_PET_CAPCITY
end

-- 是否有宠物
function PetMgr:havePet()
    for _, pet in pairs(self.pets) do
        return true
    end

    return false
end

-- 是否存在非野生宠物
function PetMgr:haveNotWildPet()
    for _, pet in pairs(self.pets) do
        if pet:queryInt('rank') ~= Const.PET_RANK_WILD then
            -- 存在非野生的宠物
            return true
        end
    end

    return false
end

-- 仅有野生宠物
function PetMgr:haveOnlyWildPet()
    local isWild = true
    for _, pet in pairs(self.pets) do
        if pet:queryInt('rank') ~= Const.PET_RANK_WILD then
            -- 存在非野生的宠物
            isWild = false
        end
    end

    return isWild
end

-- 仅携带变异宠物
function PetMgr:haveOnlyElitePet()
    if not self:havePet() then return false end

    for _, pet in pairs(self.pets) do
        if pet:queryInt('rank') ~= Const.PET_RANK_ELITE then
            -- 存在非变异的宠物
            return false
        end
    end

    return true
end

-- 携带宝宝宠物
function PetMgr:haveBabyPet()
    for _, pet in pairs(self.pets) do
        if pet:queryInt('rank') == Const.PET_RANK_BABY then
            -- 存在宝宝宠物
            return true
        end
    end

    return false
end

-- 判断是否所有宠物都在set集合类别中
-- array{1,2,3} 表示检测野生，宝宝，变异，不检测神兽
-- 若self.pets包含[4]神兽，则返回nil，否则返回例如：{[1] = true, [2] = false, [3] = false}表示当前只有野生，没有宝宝与变异类型的宠物
function PetMgr:isAllPetsInRank(array)
    local arrayToMap = {}
    for i = 1, #array do
        arrayToMap[array[i]] = true
    end

    local retRank = {}
    for _, pet in pairs(self.pets) do
        local rank = pet:queryInt('rank')
        if not arrayToMap[rank] then
            -- 该宠物不在需要检测的类型里
            return
        end

        retRank[rank] = true
    end

    return retRank
end

-- 获取宠物可以学习的天生技能
function PetMgr:petHaveRawSkill(petRawName)
    local petCfg = self:getPetCfg(petRawName)
    local rawSkills = petCfg.skills

    if nil == rawSkills then return nil end
    return rawSkills
end

-- 宠物能否拥有指定的天生技能（野生的宠物需要洗成宝宝之后才可学习）
function PetMgr:mayPetHaveRawSkill(petRawName, skillName)
    local petCfg = self:getPetCfg(petRawName)
    local rawSkills = petCfg.skills
    if not rawSkills then
        return false
    end

    for i = 1, #rawSkills do
        if rawSkills[i] == skillName then
            return true
        end
    end

    return false
end

-- 是否存在非野生宠物可学习指定的天生技能
function PetMgr:haveNotWildPetCanLearnRawSkill(skillName)
    for _, pet in pairs(self.pets) do
        local mayHave = self:mayPetHaveRawSkill(pet:queryBasic('raw_name'), skillName)
        if pet:queryInt('rank') ~= Const.PET_RANK_WILD and mayHave then
            -- 存在非野生的宠物可以学习该技能
            local skillInfo = SkillMgr:getskillAttribByName(skillName)
            if not SkillMgr:getSkill(pet:getId(), skillInfo.skill_no) then
                -- 还未学习该技能
                return pet:getId()
            end
        end
    end

    return false
end

-- 是否存在野生宠物可学习指定的天生技能（野生的宠物需要洗成宝宝之后才可学习）
function PetMgr:haveWildPetCanLearnRawSkill(skillName)
    for _, pet in pairs(self.pets) do
        local mayHave = self:mayPetHaveRawSkill(pet:queryBasic('raw_name'), skillName)
        if pet:queryInt('rank') == Const.PET_RANK_WILD and mayHave then
            -- 存在野生的宠物可以学习该技能
            return true
        end
    end

    return false
end

-- 设置宠物状态    1参战， 2掠阵，0休息
function PetMgr:setPetStatus(petId, status)
    gf:CmdToServer("CMD_SELECT_CURRENT_PET", {
        id = petId,
        pet_status = status,
    })
end

-- 设置宠物的主人属性
function PetMgr:setPetOwner(data)
    local ownerId = data.owner_id
    if ownerId < 0 then
        return
    end

    local id = data.id
    if id < 0 then
        return
    end

    if 0 == ownerId or ownerId ~= Me:getId() then
        -- 宠物没有主人，删除宠物
        self:deletePet(id, true, true)
        return
    end

    local pet = self:getPetById(id)
    if pet then
        pet:setBasic('owner_id', ownerId)
    else
        self:add(data)
    end
end

-- 清空所有宠物的状态
function PetMgr:cleanAllPetStatus()
    for _, pet in pairs(self.pets) do
        pet:setBasic('pet_cannot_call', 0)
        pet:setBasic('pet_have_called', 0)
    end
end

function PetMgr:deletePet(id, saveExtra, delSkill)
    if delSkill then
        -- 删除此人的所有技能
        SkillMgr:deleteAllOnesSkills(id)
    end

    local pet = self:getPetById(id)
    if pet then
        pet:cleanup()
        self.defaultSkill[pet:queryBasicInt('no')] = nil
        self.pets[id] = nil
    end

    if not saveExtra then
        -- 删除额外信息
        self.extraMaps[id] = nil
    end
end

function PetMgr:add(data)
    local id = data.id
    if id < 0 then
        Log:W('Invalid pet id:' .. id)
        return
    end

    local pet = self.pets[id]
    if pet then
        -- 找到相应宠物
        if data.no == 0 then
            -- 删除宠物
            local saveExtra = false
            if data.c_save_extra and data.c_save_extra ~= 0 then
                saveExtra = true
            end

            local delSkill = false
            if data.c_del_skill and data.c_del_skill ~= 0 then
                delSkill = true
            end

            self:deletePet(id, saveExtra, delSkill)
            return
        end

        -- 先保存不需要更新的信息
        local noUpInfo = {}
        noUpInfo['pet_status'] = pet:queryBasicInt('pet_status')
        noUpInfo['appear'] = pet:queryBasicInt('appear')
        noUpInfo['pet_cannot_call'] = pet:queryBasicInt('pet_cannot_call')
        noUpInfo['pet_have_called'] = pet:queryBasicInt('pet_have_called')
        noUpInfo['c_seq_guarded'] = pet:queryBasicInt('c_seq_guarded')
        noUpInfo['c_seq_left_home'] = pet:queryBasicInt('c_seq_left_home')
        noUpInfo['c_seq_died'] = pet:queryBasicInt('c_seq_died')
        noUpInfo['ride'] = pet:queryBasicInt('ride')
        noUpInfo['def_pet_skill'] = pet:queryBasicInt('def_pet_skill')
        noUpInfo['def_sel_skill_no'] = pet:queryBasicInt('def_sel_skill_no')
        local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
        noUpInfo['god_book_skill_count'] = nGodBookCount

        for i = 1, nGodBookCount do
            -- 名字
            local key = 'god_book_skill_name_' .. i
            noUpInfo[key] = pet:queryBasic(key)

            -- 灵气
            key = 'god_book_skill_power_' .. i
            noUpInfo[key] = pet:queryBasic(key)

            -- 等级
            key = 'god_book_skill_level_' .. i
            noUpInfo[key] = pet:queryBasic(key)
        end

        -- pet:cleanupBasic()
        pet:absorbBasicFields(data)
        pet:absorbBasicFields(noUpInfo)
    else
        for myPetId, myPet in pairs(self.pets) do
            -- 避免在界面中显示两只或以上完全相同的宠物
            if myPet:queryBasic("iid_str") == data.iid_str then
                self:deletePet(myPetId)
                break
            end
        end
        local pet = Pet.new()
        PetMgr.pets[id] = pet
        pet:absorbBasicFields(data)

        -- 设置额外信息
        local extra = self.extraMaps[id]
        if extra then
            pet:absorbExtraFields(extra)
        end

        -- 设置默认法术
        local skill = self.defaultSkill[data.no]
        if skill then
            pet:setBasic('def_pet_skill', skill)
        end
    end

    self.idNoMap[id] = data.no
end

-- 设置骑宠
function PetMgr:setRidePet(data)
    for _, pet in pairs(self.pets) do
        if pet:getId() == data.id then
            pet:setBasic('ride', 1)
        else
            pet:setBasic('ride', 0)
        end
    end
end

-- 是否有天书技能
function PetMgr:haveGoodbookSkill(id)
    local pet = self:getPetById(id)

    if not pet then return end  -- 宠物可能已经不存在了

    local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
    return nGodBookCount > 0
end

-- 是否所有天书技能被禁用了
function PetMgr:isAllGodBookDisable(id)
    local pet = self:getPetById(id)
    if not pet then
        return
    end

    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    if godBookCount <= 0 then
        return
    end

    for i = 1, godBookCount do
        if pet:queryBasicInt('god_book_skill_disabled_' .. i) == 0 then
            return
        end
    end

    return true
end

-- 是否有有灵气的天书技能
function PetMgr:goodbookHaveNimbus(id)
    local pet = self:getPetById(id)

    if not pet then return end  -- 宠物可能已经不存在了

    local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
    if nGodBookCount == 0 then
        return false
    end

    for i = 1, nGodBookCount do
        -- 灵气
        local key = 'god_book_skill_power_' .. i
        local disableKey = 'god_book_skill_disabled_' .. i
        if pet:queryBasicInt(key) > 0 and pet:queryBasicInt(disableKey) == 0 then
            return true
        end
    end

    return false
end

-- 增加宠物的额外属性
function PetMgr:addExtraMapping(map)
    local id = map.id
    local pet = self:getPetById(id)
    if not pet then
        return
    end

    pet:cleanupExtra()
    pet:absorbExtraFields(map)

    self.extraMaps[id] = map
end

function PetMgr:setPetGodBookSkill(data)
    local pet = self:getPetById(data.id)
    if pet then
        pet:absorbBasicFields(data)
    end
end

-- 获取宠物的标准成长
function PetMgr:getPetStdValue(name, key)
    local cfg = self:getPetCfg(name)
    if cfg == nil then return 0 end

    local value = cfg[key]
    if value == nil then return 0 end

    return value + 40
end

-- 获取宠物配置信息
function PetMgr:getPetCfg(petRawName)
    if not petRawName then
        return {}
    end

    -- 服务器中有些名字是带地图名的，如"鹰<北海沙滩>"，故需要将其地图名信息去除
    local pos = gf:findStrByByte(petRawName, "<", 1, true)
    if pos then
        petRawName = string.sub(petRawName, 1, pos - 1)
    end

    return NormalPetList[petRawName] or
           VariationPetList[petRawName] or
           EpicPetList[petRawName] or
           OtherPetList[petRawName] or
           JingguaiPetList[petRawName] or
           JinianPetList[petRawName] or {}
end

function PetMgr:getJingGuaiCfg()
    return JingguaiPetList
end

function PetMgr:isJinianPet(pet)
    if not pet then
        return
    end

    local name = pet:queryBasic("raw_name")
    if JinianPetList[name] then
        return true
    end

    return
end

-- 获取宠物显示名字
function PetMgr:getShowNameByRawName(petRawName)
    -- 服务器中有些名字是带地图名的，如"鹰<北海沙滩>"，故需要将其地图名信息去除
    local pos = gf:findStrByByte(petRawName, "<", 1, true)
    if pos then
        petRawName = string.sub(petRawName, 1, pos - 1)
    end

    return petRawName
end

-- 获取宠物携带等级
function PetMgr:getPetLevelReq(petName)
    local levelReq = self:getPetCfg(petName).level_req
    if nil == levelReq then return end

    return levelReq
end

-- 是否为力宠
function PetMgr:isPhyPet(petRawName)
    local cfg = self:getPetCfg(petRawName)
    if not cfg.polar or cfg.polar == "" or cfg.polar == CHS[34048] then
        return true
    end

    return false
end

-- 获取显示在场景中的宠物 id
function PetMgr:getVisiblePetId()
    for _, pet in pairs(self.pets) do
        if pet:queryBasicInt('appear') == 1 then
            return pet:getId()
        end
    end
end

-- 宠物是否是永久限制交易
function PetMgr:isLimitedForeverPet(pet)
    local gift = pet:queryInt("gift")
    return gift == 2
end

-- 宠物是否是限制交易
function PetMgr:isLimitedPet(pet)
    if pet == nil then
        return false
    end

    local gift = pet:queryInt("gift")

    return PetMgr:isLimitedPetByGift(gift)
end

-- 宠物是否是限制交易（宠物信息无需用query获取）
function PetMgr:isLimitedPetWithoutQuery(pet)
    if pet == nil then
        return false
    end

    local gift = pet.gift
    if gift == nil then
        return false
    end

    return PetMgr:isLimitedPetByGift(gift)
end

function PetMgr:isLimitedPetByGift(gift)
    if gift == nil then
        return false
    end

    if gift < 0 then
        if gift + gf:getServerTime() < 0 then
            return true
        end

        gift = 0
    end

    return gift == 2
end

-- 宠物是否是限时宠物
function PetMgr:isTimeLimitedPet(pet)
    if pet:queryBasicInt("deadline") ~= 0 then
        return true
    else
        return false
    end
end

function PetMgr:isPetTimeOut(pet)
    local leftTime = pet:queryBasicInt("deadline") - gf:getServerTime()
    if PetMgr:isTimeLimitedPet(pet) and leftTime < 0 then
        return true
    else
        return false
    end
end

function PetMgr:convertLimitTimeToStr(deadline)
    local timeLimitStr = ""
    local leftTime = deadline - gf:getServerTime()

    if leftTime < 0 then
        timeLimitStr = CHS[7000092]  -- 已过期
        return timeLimitStr
    end

    local day = math.floor(leftTime / (24 * 3600))
    local hours = math.floor(leftTime % (24 * 3600) / 3600)
    local minutes = math.floor((leftTime % 3600) / 60)

    if day ~= 0 then
        timeLimitStr = timeLimitStr .. tostring(day) .. CHS[3002175]
    end

    if not (day == 0 and hours == 0) then
        timeLimitStr = timeLimitStr .. tostring(hours) .. CHS[3003115]
    end

    if day == 0 and hours == 0 and minutes == 0 then
        minutes = 1  -- 不足一分钟，显示为一分钟
    end

    timeLimitStr = timeLimitStr .. tostring(minutes) .. CHS[4200025]

    return string.format(CHS[7000084], timeLimitStr)  -- XX天XX小时XX分钟后回收
end

function PetMgr:MSG_UPDATE_PETS(data)
    for i = 1, data.count do
        self:add(data[i])

        if self.lastSelectPet and data[i].no == self.lastSelectPet:queryBasicInt("no") then
            self.lastSelectPet = PetMgr:getPetByNo(data[i].no)
    end
    end
end

function PetMgr:MSG_SET_VISIBLE_PET(data)
    for _, pet in pairs(self.pets) do
        if pet:getId() == data.id then
            pet:setBasic('appear', 1)
        else
            pet:setBasic('appear', 0)
        end
    end
end

function PetMgr:MSG_SET_CURRENT_PET(data)
    self:setFightPetAttri(data)
end

function PetMgr:MSG_SET_OWNER(data)
    self:setPetOwner(data)
end


-- 获取宠物头像
function PetMgr:getPetIcon(petName)
    local icon = self:getPetCfg(petName).icon
    if nil == icon then return end

    return icon
end

-- 去除宠物原始名字中 <> 中的内容
function PetMgr:trimPetRawName(petRawName)
    -- 服务器中有些名字是带地图名的，如"鹰<北海沙滩>"，故需要将其地图名信息去除
    local pos = gf:findStrByByte(petRawName, "<", 1, true)
    if pos then
        petRawName = string.sub(petRawName, 1, pos - 1)
    end

    return petRawName
end

-- 学习宠物技能
function PetMgr:studyInnateSkill(petId, skillNo, levelUpTimes)

    if not levelUpTimes then
        levelUpTimes = 1
    end

    local data = {id  = petId, skill_no = skillNo, up_level = levelUpTimes}
    gf:CmdToServer("CMD_LEARN_SKILL", data)
end

-- 学习宠物研发技能
function PetMgr:studyDevelopSkill(petId, skillNo, levelUpTimes)

    if not levelUpTimes then
        levelUpTimes = 1
    end
    local data = {id  = petId, skill_no = skillNo, up_level = levelUpTimes}

    gf:CmdToServer("CMD_LEARN_SKILL", data)
end

-- 显示宠物名片
function PetMgr:MSG_PET_CARD(data)
    local petRawName = self:trimPetRawName(data.raw_name)
    local cfg = self:getPetCfg(petRawName)
    if cfg then
        if not data.icon then data.icon = cfg.icon end
        if not data.polar then data.polar = gf:getIntPolar(cfg.polar) end
    end

    data.raw_name = petRawName
    if not data.req_level then
        data.req_level = cfg.level_req
    end

    local dlg =  DlgMgr:openDlg("PetCardDlg")
    local obj = DataObject.new()
    obj:absorbBasicFields(data)
    dlg:setPetInfo(obj)
end

-- 获取战斗力最强的宠物
function PetMgr:getFightKingPet(attrib)
    local fightKing
    local score = -1
    for _, pet in pairs(self.pets) do
        if pet:queryInt(attrib) > score then
            score = pet:queryInt(attrib)
            fightKing = pet
        end
    end

    return fightKing
end

function PetMgr:getOrderPets(petList)
    petList = petList or PetMgr.pets
    local pets = petList
    if pets == nil or table.maxn(pets) == 0 then
        return {}
    end

    local array = {}
    local selectId = 0
    local selectName = nil
    for k, v in pairs(pets) do
        table.insert(array,v)
    end

    table.sort(array, function(l,r) return PetMgr:comparePet(l,r) end)
    return array
end

-- 获取宠物列表，根据类型   类型为野生，宝宝等
function PetMgr:getPetByType(type, polar, level, noFight, noRob)
    local petList = {}
    for _, pet in pairs(self.pets) do
        local canInsert = true
        if type and tonumber(type) ~= pet:queryInt('rank') then
            canInsert = false
        end

        if polar and pet:queryBasicInt("polar") ~= tonumber(polar) then
            canInsert = false
        end

        if level and pet:queryBasicInt("level") < tonumber(level) then
            canInsert = false
        end

        if noFight and pet:queryBasicInt('pet_status') == 1 then
            canInsert = false
        end

        if noRob and pet:queryBasicInt('pet_status') == 2 then
            canInsert = false
        end

        if canInsert then
            table.insert(petList, pet)
        end
    end

    return petList
end

-- 获取宠物列表，根据宠物名和类型   类型为野生，宝宝等
function PetMgr:getPetByNameAndType(name, petState)
    local destPet = {}
    local settingFlag = Bitset.new(petState)
    local petType = nil

    if settingFlag:isSet(4) then
        petType = Const.PET_RANK_WILD
    elseif settingFlag:isSet(5) then
        petType = Const.PET_RANK_BABY
    elseif settingFlag:isSet(6) then
        petType = Const.PET_RANK_ELITE
    elseif settingFlag:isSet(7) then
        petType = Const.PET_RANK_EPIC
    elseif settingFlag:isSet(8) then
        petType = Const.PET_RANK_GUARD
    end

    if petType then
        for _, pet in pairs(self.pets) do
            if pet:queryBasic("raw_name") == name and petType == pet:queryInt('rank') then
                if settingFlag:isSet(1) then
                    if pet:queryInt('pet_status') == 0 then
                        table.insert(destPet, pet)
                    end
                end
                if settingFlag:isSet(2) then
                    if pet:queryInt('pet_status') == 1 then
                        table.insert(destPet, pet)
                    end
                end
                if settingFlag:isSet(3) then
                    if pet:queryInt('pet_status') == 2 then
                        table.insert(destPet, pet)
                    end
                end
            end
        end
    else
        for _, pet in pairs(self.pets) do
            if pet:queryBasic("raw_name") == name then
                if settingFlag:isSet(1) then
                    if pet:queryInt('pet_status') == 0 then
                        table.insert(destPet, pet)
                    end
                end

                if settingFlag:isSet(2) then
                    if pet:queryInt('pet_status') == 1 then
                        table.insert(destPet, pet)
                    end
                end
                if settingFlag:isSet(3) then
                    if pet:queryInt('pet_status') == 2 then
                        table.insert(destPet, pet)
                    end
                end
            end
        end
    end

    return destPet
end

-- 获取是否可以喂超级归元露权限
local canFeed = true
function PetMgr:getCanFeedSuperLuLimit()
    if not canFeed then
        return false
    end

    canFeed = false
    return true
end

-- 释放可喂养权限
function PetMgr:resetCanFeedLimit()
    canFeed = true
end

-- 请求天技
function PetMgr:requestPetGodSkill(petId, type)
    gf:CmdToServer("CMD_PET_SPECIAL_SKILL", {petId = petId, type = type})

    if "save" == type then
        local pet = PetMgr:getPetById(petId)
        if not pet then return end
        PetMgr:clearPetGodSkill(pet:queryBasicInt("no"))
    end
end

function PetMgr:MSG_PREVIEW_SPECIAL_SKILL(data)
    PetMgr:resetCanFeedLimit()
    local pet = PetMgr:getPetById(data.petId)
    if not pet then return end
    if data.count == -1 then

        petGrowGodSkill[pet:queryBasicInt("no")] = nil
        return
    end

    petGrowGodSkill[pet:queryBasicInt("no")] = data.skills
end

-- 清除宠物缓存
function PetMgr:clearPetGodSkill(no)
    petGrowGodSkill[no] = nil
end

-- 获取是否存在缓存
function PetMgr:isHasPetGodSkill(no)
    if petGrowGodSkill[no] then
        return true
    end

    return false
end

function PetMgr:getHuanProgressMax(pet)
    local rank = pet:queryBasicInt("rank")
    if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
        return 5
    end

    return 3
end

-- 宠物是否存在天技
function PetMgr:isHaveGodSkill(pet)
    if not pet then return end

    local skills = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}

    if 0 == #skills then
        return false
    else
        return true
    end
end

-- 是否幻化的宠物（次数大于0）
function PetMgr:isMorphed(pet)
    local field = {"life", "mana", "speed", "phy", "mag"}
    for _, att in pairs(field) do
        local fieldTimes = string.format("morph_%s_times", att)
        if pet:queryBasicInt(fieldTimes) > 0 then
            return true
        end
    end

    return false
end

-- 宠物幻化次数
function PetMgr:getMorphedCount(pet)
    local field = {"life", "mana", "speed", "phy", "mag"}
    local count = 0
    for _, att in pairs(field) do
        local fieldTimes = string.format("morph_%s_times", att)
        count = count + pet:queryBasicInt(fieldTimes)
    end

    return count
end

function PetMgr:isHuanhuaCompleted(pet)
    return PetMgr:getMorphedCount(pet) >= 15
end

-- 是否点化完成
function PetMgr:isDianhuaOK(pet)
    return pet:queryBasicInt("enchant") == 2
end

-- 是否羽化完成
function PetMgr:isYuhuaCompleted(pet)
    return pet:queryBasicInt("eclosion") == 2
end

-- 设置宠物logo，点化，贵重，相性
function PetMgr:setPetLogo(dlg, pet, ctrlParent)
    local petLogoPanel = dlg:getControl("PetLogoPanel", nil, ctrlParent)
    petLogoPanel:setVisible(true)
    petLogoPanel:setLayoutType(ccui.LayoutType.ABSOLUTE)
    dlg:setCtrlVisible("SingularPanel", false, petLogoPanel)
    dlg:setCtrlVisible("DoublePanel", false, petLogoPanel)
    petLogoPanel:setLayoutType(ccui.LayoutType.ABSOLUTE)
    petLogoPanel:requestDoLayout()

    local logoPath = {}
    -- 相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    table.insert(logoPath, {path = polarPath, pList = 1})

    -- 点化
    if PetMgr:isDianhuaOK(pet) then table.insert(logoPath, {path = ResMgr.ui.dianhua_logo, pList = 0}) end

    -- 羽化
    if PetMgr:isYuhuaCompleted(pet) then table.insert(logoPath, {path = ResMgr.ui.yuhua_logo, pList = 0}) end

    -- 幻化
    if PetMgr:isMorphed(pet) then table.insert(logoPath, {path = ResMgr.ui.huanhua_logo, pList = 0}) end

    -- 飞升
    if PetMgr:isFlyPet(pet) then table.insert(logoPath, {path = ResMgr.ui.fly_logo, pList = 0}) end

    -- 风化
    if self:isHaveFenghuaTime(pet) then table.insert(logoPath, {path = ResMgr.ui.fenghua_logo, pList = 0}) end

    -- 贵重
    if gf:isExpensive(pet, true) then table.insert(logoPath, {path = ResMgr.ui.expensive_logo, pList = 0}) end


    local count = #logoPath
    if count == 0 then return end
    petLogoPanel:removeAllChildren()

    local size = petLogoPanel:getContentSize()
    local imageSize = 20
    local logoMargin = 5

    local function getStartX(count, size)
        local temp = math.floor(count / 2)
    	if count % 2 == 0 then
            return (size.width * 0.5 - temp * (imageSize + logoMargin) - logoMargin * 0.5)
    	else
            return (size.width * 0.5 - temp * (imageSize + logoMargin) - imageSize * 0.5)
    	end
    end

    local startx = getStartX(count, size) + imageSize * 0.5
    for i = 1, count do
        local logo = logoPath[i]
        local image = ccui.ImageView:create(logo.path, logo.pList)
        image:setPosition(startx + (i - 1) * (imageSize + logoMargin),size.height * 0.5)
        petLogoPanel:addChild(image)
    end
end

-- 变异宠物才有基础数值附加值
function PetMgr:getPetAdditionalValue(pet, field)
    if field == "life_effect" then
        return pet:queryBasicInt("extra_life_effect")
    elseif field == "mana_effect" then
        return pet:queryBasicInt("extra_mana_effect")
    elseif field == "speed_effect" then
        return pet:queryBasicInt("extra_speed_effect")
    elseif field == "phy_effect" then
        return pet:queryBasicInt("extra_phy_effect")
    elseif field == "mag_effect" then
        return pet:queryBasicInt("extra_mag_effect")
    else
        return 0
    end
end

-- 获取宠物基础资质（不包括点化和强化）
function PetMgr:getPetBasicShape(pet, field)
    if not pet then return 0 end
    local add = PetMgr:getPetAdditionalValue(pet, field)
    if field == "life_effect" then
        return pet:queryBasicInt("life_effect") + 40 + add
    elseif field == "mana_effect" then
        return pet:queryBasicInt("mana_effect") + 40 + add
    elseif field == "speed_effect" then
        return pet:queryBasicInt("speed_effect") + 40 + add
    elseif field == "phy_effect" then
        return pet:queryBasicInt("phy_effect") + 40 + add
    elseif field == "mag_effect" then
        return pet:queryBasicInt("mag_effect") + 40 + add
    end
end

-- 获取宠物强化等级
function PetMgr:getPetDevelopLevel(pet)
    local petPolar = pet:queryBasicInt("polar")
    if petPolar > 0 then
        return pet:queryInt("mag_rebuild_level")
    else
        return pet:queryInt("phy_rebuild_level")
    end
end

-- 野生的有正负rank范围
function PetMgr:getPetGrowRanl(pet, field)
    local rank = 10
    if field == "speed" then rank = 5 end
    local petRank = pet:queryInt('rank')
    if petRank == Const.PET_RANK_ELITE or petRank == Const.PET_RANK_EPIC then
        rank = 0
    end
    return rank
end

-- 获取宠物基础资质最大值（不包括点化和强化）
function PetMgr:getPetBasicMax(pet, field)
    if not pet then return 0 end
    local raw_name = pet:queryBasic("evolve")
    if raw_name == "" then raw_name = pet:queryBasic("raw_name") end
    local add = 0
    local maxRank = PetMgr:getPetGrowRanl(pet, field)
    if field == "life" then
        add = PetMgr:getPetAdditionalValue(pet, "life_effect")
        return PetMgr:getPetStdValue(raw_name, "life") + maxRank + add
    elseif field == "mana" then
        add = PetMgr:getPetAdditionalValue(pet, "mana_effect")
        return PetMgr:getPetStdValue(raw_name, "mana") + maxRank + add
    elseif field == "speed" then
        add = PetMgr:getPetAdditionalValue(pet, "speed_effect")
        return PetMgr:getPetStdValue(raw_name, "speed") + maxRank + add
    elseif field == "phy_attack" then
        add = PetMgr:getPetAdditionalValue(pet, "phy_effect")
        return PetMgr:getPetStdValue(raw_name, "phy_attack") + maxRank + add
    elseif field == "mag_attack" then
        add = PetMgr:getPetAdditionalValue(pet, "mag_effect")
        return PetMgr:getPetStdValue(raw_name, "mag_attack") + maxRank + add
    end
end

function PetMgr:openDianhua(pet, isLimit)
    local item = InventoryMgr:getPriorityUseInventoryByName(CHS[4000383], isLimit)

    if not item then
        gf:askUserWhetherBuyItem({[CHS[4000383]] = 1})
        return
    end

    local str, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    if isLimit and InventoryMgr:isLimitedItemForever(item) and day <= Const.LIMIT_TIPS_DAY then
        gf:confirm(string.format(CHS[4000385], 10), function ()
            gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_open_enchant", no = pet:queryBasicInt("no"), pos = tostring(item.pos), other_pet = "", cost_type = "", ids = tostring(item.item_unique),})
        end)
    else
        gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_open_enchant", no = pet:queryBasicInt("no"), pos = tostring(item.pos), other_pet = "", cost_type = "", ids = tostring(item.item_unique),})
    end
end

function PetMgr:doPetFuse(petId, otherPets, items, itemIds, itemCount, isUseBind)
    local pet = self:getPetById(petId)
    if not pet then return end

    local name = CHS[2000128]
    local amount = InventoryMgr:getAmountByNameIsForeverBind(name, isUseBind)
    if amount < itemCount then
        gf:askUserWhetherBuyItem({[name] = itemCount - amount})
        return
    end

    local petNo = pet:queryBasicInt("no")
    local function doFuse()
        gf:CmdToServer("CMD_UPGRADE_PET", {
            type = "mount_merge",
            no = petNo,
            pos = table.concat(items, "|"),
            ids = table.concat(itemIds, "|"),
            other_pet = table.concat(otherPets, "|"),
            cost_type = string.format("%d|%d", isUseBind and 1 or 0, itemCount)
        })
    end

    local useBindPets = false
    local bindCount = 0
    local includeYuLing = false

    for i = 1, #otherPets do
        local p = self:getPetByNo(otherPets[i])
        local str, day = gf:converToLimitedTimeDay(p:queryInt("gift"))
        local isBindPet = (day >= 9999)
        useBindPets = useBindPets or isBindPet
        if isBindPet then bindCount = bindCount + 1 end

        -- 副宠中是否有御灵
        if p:queryInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_YULING then
            includeYuLing = true
        end
    end

    local useBindItems = false
    for i = 1, #items do
        local k = InventoryMgr:getItemByPos(items[i])
        local str, day = gf:converToLimitedTimeDay(k.gift)
        local isBindItem = (day >= 9999)
        useBindItems = useBindItems or isBindItem
        if isBindItem then bindCount = bindCount + 1 end
    end

    local bindAmount = InventoryMgr:getAmountByNameForeverBind(name)
    if isUseBind then
    bindCount = bindCount + math.min(bindAmount, itemCount)
    end



    local _, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    if includeYuLing then
        -- 副宠包含御灵
        gf:confirm(CHS[7001006], function()
            if (day <= 59) and ((isUseBind and bindAmount > 0) or useBindPets or useBindItems)  then
                gf:confirm(string.format(CHS[2000127], math.min(10 * bindCount, 60 - day)), function()
                    doFuse()
                end)
            else
                doFuse()
            end
        end)
    else
        -- 副宠不包含御灵
        if (day <= 59) and ((isUseBind and bindAmount > 0) or useBindPets or useBindItems)  then
            gf:confirm(string.format(CHS[2000127], math.min(10 * bindCount, 60 - day)), function()
                doFuse()
            end)
        else
            doFuse()
        end
    end
end

-- 幻化 attrib: 1幻化气血     2幻化法力       3幻化速度       4幻化物攻       5幻化法攻
function PetMgr:morphPet(pet, otherPet, attrib)
    gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_morph", no = pet:queryBasicInt("no"), pos = "", other_pet = otherPet:queryBasicInt("no"),cost_type = attrib})
end

-- 进化
function PetMgr:evolvePet(pet, otherPet, cost_type)
    gf:CmdToServer("CMD_UPGRADE_PET", {type = "pet_evolve", no = pet:queryBasicInt("no"), pos = "", other_pet = otherPet:queryBasicInt("no"),cost_type = cost_type})
end

function PetMgr:previewEvolvePet(pet, otherPet)
    gf:CmdToServer("CMD_PREVIEW_PET_EVOLVE", {mainPetNo = pet:queryBasicInt("no"), otherPetNo = otherPet:queryBasicInt("no")})
end

function PetMgr:upgradePet(pet, items, opType, costType)
    costType = costType or ""
    local limitCount = 0
    local posList = {}
    local idList = {}
    for pos, item in pairs(items) do
        if InventoryMgr:isLimitedItemForever(item) then
            limitCount = limitCount + 1
        end

        table.insert(posList, item.pos)
        table.insert(idList, item.item_unique)
        end
    local posStr = table.concat(posList, "|")
    local idStr = table.concat(idList, "|")

    local str, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    if limitCount > 0 and day <= Const.LIMIT_TIPS_DAY then
        gf:confirm(string.format(CHS[4000385], limitCount * 10), function ()
            gf:CmdToServer("CMD_UPGRADE_PET", {type = opType, no = pet:queryBasicInt("no"), pos = posStr, ids = idStr, cost_type = costType})
            return true
        end, nil, nil, nil, nil, nil, nil, "pet_oper")
    else
        gf:CmdToServer("CMD_UPGRADE_PET", {type = opType, no = pet:queryBasicInt("no"), pos = posStr, ids = idStr, cost_type = costType})
        return true
    end
end

-- 获取洗天技技能
function PetMgr:getGrowGodSkill(petId)
    local pet = PetMgr:getPetById(petId)
    local skills = petGrowGodSkill[pet:queryBasicInt("no")]
    if nil == skills then return end

    local newSkills = {}
    for _, skillName in pairs(skills) do
        local skillAttrib = SkillMgr:getskillAttribByName(skillName)
        if skillAttrib then
            table.insert(newSkills, {no = skillAttrib.skill_no, skillName = skillName})
        end
    end

    return newSkills
end

-- 判断该宠物是否点化过
function PetMgr:isEnchanted(pet)
    local enchant = pet:queryBasicInt("enchant")
    return enchant == 1 or enchant == 2
end

-- 判断该宠物是否进化过
function PetMgr:isEvolved(pet)
    if not pet then return end
    return pet:queryBasic('evolve') ~= ""
end

-- 判断该宠物是否成长值全满
function PetMgr:isGrowUpPerfect(pet)
    if not pet then return end
    if PetMgr:getPetBasicMax(pet, "life") ~= PetMgr:getPetBasicShape(pet, "life_effect") then return false end
    if PetMgr:getPetBasicMax(pet, "mana") ~= PetMgr:getPetBasicShape(pet, "mana_effect") then return false end
    if PetMgr:getPetBasicMax(pet, "speed") ~= PetMgr:getPetBasicShape(pet, "speed_effect") then return false end
    if PetMgr:getPetBasicMax(pet, "mag_attack") ~= PetMgr:getPetBasicShape(pet, "mag_effect") then return false end
    if PetMgr:getPetBasicMax(pet, "phy_attack") ~= PetMgr:getPetBasicShape(pet, "phy_effect") then return false end

    return true
end

-- 请求强化
function PetMgr:requestOneClickDevelop(petId, rebLevel, para, useType)
    gf:CmdToServer("CMD_REBUILD_PET", { petId = petId, rebLevel = rebLevel, para = para, useType = useType })
end

-- 获取某宠物的最大强化等级
function PetMgr:getMaxDevelopLevel(pet)
    if not pet then return 0 end

    local petPolar = pet:queryBasicInt("polar")
    local rebuildLevel = 0
    local key = "mag"
    if petPolar <= 0 then
        key = "phy"
    end

    local raw_name = pet:queryBasic("raw_name")
    local rebuildAdd = pet:queryInt(key .. "_rebuild_add")

    local max_level = 0
    if petPolar > 0 then
        max_level = pet:queryInt("mag_rebuild_level")
    else
        max_level = pet:queryInt("phy_rebuild_level")
    end

    local attr = 0
    local delta = 0
    if key == "mag" then
        local mag_std = PetMgr:getPetStdValue(raw_name, "mag_attack") - 40

        repeat
            delta = Formula:getMagRebuildDelta(mag_std, rebuildAdd + attr)
            if delta > 0 then
                max_level = max_level + 1
                attr = attr + delta
            end
        until delta <= 0
    else
        local phy_std = PetMgr:getPetStdValue(raw_name, "phy_attack") - 40

        repeat
            delta = Formula:getPhyRebuildDelta(phy_std, rebuildAdd + attr)
            if delta > 0 then
                max_level = max_level + 1
                attr = attr + delta
            end
        until delta <= 0
    end

    if max_level > MAX_PET_DEVELOP_LEVEL then
        max_level = MAX_PET_DEVELOP_LEVEL
    end

    return max_level
end

function PetMgr:MSG_REFINE_PET_RESULT(data)
    PetMgr:resetCanFeedLimit()
end

-- 获取精怪阶位信息
-- 如（8+1）目前只有原始阶位，后续需要加加成
function PetMgr:getMountRankStr(pet, capacity_level)
    local raw_capacity_level = PetMgr:getMountRawRank(pet)
    if not raw_capacity_level then return end
    local capacity_level = capacity_level or pet:queryInt("capacity_level")
    return PetMgr:getMountRankStrByCapLvAndRawCapLv(capacity_level, raw_capacity_level)
end

function PetMgr:getMountRankStrWithoutQuery(pet)
    local petInfo = self:getPetCfg(pet.raw_name)
    if not petInfo then
        return
    end

    local raw_capacity_level = petInfo.capacity_level
    local capacity_level = pet.capacity_level
    return PetMgr:getMountRankStrByCapLvAndRawCapLv(capacity_level, raw_capacity_level)
end

function PetMgr:getMountRankStrByCapLvAndRawCapLv(capacity_level, raw_capacity_level)
    local level
    if raw_capacity_level == capacity_level then
        level = tostring(capacity_level)
    elseif raw_capacity_level then
        level = string.format("%d+%d", raw_capacity_level, capacity_level - raw_capacity_level)
    end

    return level
end

function PetMgr:getMountRawRank(pet)
    local cfg = self:getPetCfg(pet:queryBasic('raw_name'))
    if not cfg then return end
    return cfg.capacity_level
end

-- 获取骑宠的最高可提升阶数
function PetMgr:getMountMaxRank(pet)
    local rawCapactiyLevel = PetMgr:getMountRawRank(pet)
    if rawCapactiyLevel >= 2 and rawCapactiyLevel <= 4 then
        return 5
    elseif rawCapactiyLevel >= 5 then
        return rawCapactiyLevel + 1
    end

    return 0
end

-- 获取原始阶位信息，目前用于鹰眼搜索确定宠物阶位（2阶/3阶/4阶/5阶/6阶及以上）
function PetMgr:getMountRawRankStrByName(rawName)
    local cfg = self:getPetCfg(rawName)
    if not cfg then return CHS[7000325] end
    local level = cfg.capacity_level
    if level >= 6 then
        return CHS[7000305]
    else
        return level .. CHS[3002813]
    end
end

-- 是否还有风化时间
function PetMgr:isHaveFenghuaTime(pet)
    if not pet then return end
    local endTime = pet:queryInt("mount_attrib/end_time")
    local leftTime = endTime - gf:getServerTime()

    if leftTime > 0 then
        return true
    else
        return false
    end
end

function PetMgr:getFenghuaDay(pet, endTime)
    if not pet then return end
    if not endTime then endTime = pet:queryInt("mount_attrib/end_time") end
    local leftTime = endTime - gf:getServerTime()

    if leftTime < 0 then leftTime = 0 end
    local day = math.ceil(leftTime /( 24 * 60 * 60))

    if day > FENGLINGWAN_MAX_DAY then
        day = FENGLINGWAN_MAX_DAY
    end

    return day
end

function PetMgr:isHaveFenghuaTimeById(petId)
    local pet = self:getPetById(petId)
    if pet then
        return self:isHaveFenghuaTime(pet)
    end
end

-- 通过"精怪的形象icon"获取对应的"御灵的形象icon"
function PetMgr:getYulingIcon(icon)
    return icon + 1000
end

-- 是不是坐骑
function PetMgr:isRidePet(petId)
    return petId == PetMgr:getRideId()
end

-- 获取骑乘id
function PetMgr:getRideId()
    return self.rideId
end

-- 是否有御灵
function PetMgr:haveYuling()
    for _, pet in pairs(self.pets) do
        if pet:queryInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_YULING then
            return true
        end
    end

    return false
end

-- 是否有骑宠
function PetMgr:haveMountPet()
    local mount_type
    for _, pet in pairs(self.pets) do
        mount_type = pet:queryInt("mount_type")
        if mount_type == MOUNT_TYPE.MOUNT_TYPE_YULING or mount_type == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then
            return true
        end
    end

    return false
end

function PetMgr:MSG_SET_CURRENT_MOUNT(data)
    self.rideId = data.ride_id
    self:setRidePet(data)
end

function PetMgr:getRideOffset(charIcon, rideIcon, dir, act, tag)
    if rideIcon and rideIcon == 0 then
        return 0, 0
    end

    local dir = dir or 0
    local suffix = tag and ":" .. tag or ""
    local key = (charIcon or 0) .. "&" .. (rideIcon or 0) .. suffix
    local info = CharRidePointOffset[key]
    if info then
        if act == Const.SA_WALK then
            -- walk 动作允许单独配置，如果没有配置则使用默认配置
            return info["walk_x" .. dir] or info["x" .. dir] or 0, info["walk_y" .. dir] or info["y" .. dir] or 0
        else
            return info["x" .. dir] or 0, info["y" .. dir] or 0
        end
    end

    return 0, 0
end

-- 获取头部基准点偏移，目前只支持 walk 动作
function PetMgr:getRideHeadOffset(charIcon, rideIcon, dir, act)
    if rideIcon and rideIcon == 0 then
        return 0, 0
    end

    local dir = dir or 0
    local key = (charIcon or 0) .. "&" .. (rideIcon or 0)
    local info = CharRidePointOffset[key]
    if info then
        if act == Const.SA_WALK then
            -- 目前只支持 walk 动作
            return info["walk_head_x" .. dir] or 0, info["walk_head_y" .. dir] or 0
        end
    end

    return 0, 0
end

-- 获取腰部基准点偏移，目前只支持 walk 动作
function PetMgr:getRideWaistOffset(charIcon, rideIcon, dir, act)
    if rideIcon and rideIcon == 0 then
        return 0, 0
    end

    local dir = dir or 0
    local key = (charIcon or 0) .. "&" .. (rideIcon or 0)
    local info = CharRidePointOffset[key]
    if info then
        if act == Const.SA_WALK then
            -- 目前只支持 walk 动作
            local headOffX, headOffY = self:getRideHeadOffset(charIcon, rideIcon, dir, act)
            return info["walk_waist_x" .. dir] or headOffX, info["walk_waist_y" .. dir] or headOffY
        end
    end

    return 0, 0
end

-- 获取骑宠乘骑信息
function PetMgr:getPetRideInfo(petIcon)
    return PetRideInfo[petIcon] or {}
end

-- 骑宠模型是否有上层动画
function PetMgr:petHasTopLayer(petIcon)
    return self:getPetRideInfo(petIcon)["have_top_layer"]
end

-- 乘骑时是否要显示人物影子
function PetMgr:needShowCharShadow(petIcon)
    return self:getPetRideInfo(petIcon)["show_char_shadow"]
end

-- 乘骑模型中有些角色的乘骑动作的方向需要做特殊转换，例如土男骑鹿的 2 方向
function PetMgr:tryToChangeCharResDirForRide(charIcon, rideIcon, dir)
    if not charIcon or not rideIcon or not dir or rideIcon == 0 then
        return
    end

    local key = charIcon .. "&" .. rideIcon
    local info = CharRidePointOffset[key]
    if info then
        return info["dir" .. dir]
    end
end

------------------------------------------------ 提供调整坐骑方法
-- 提供调试接口
function PetMgr:setOneRideOffset(dir, x, y)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    if not x or not y then
        gf:ShowSmallTips(CHS[3004442]) -- "坐标格式有错，必须是数字！"
        return
    end

    local act = (Me:isStandAction() and "" or "walk_")
    local charIcon = Me:getIcon()
    local rideIcon = Me:getRideIcon()
    local dir = dir or ""
    local key = (charIcon or "") .. "&" .. (rideIcon or "")
    local info = CharRidePointOffset[key]
    if info then
        info[act .. "x" .. dir] = x
        info[act .. "y" .. dir] = y
        local msg = string.format(CHS[3004443], dir, x, y) -- "设置方向 dir=%d 偏移置为 x=%d, y=%d 成功！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
        Me.charAction:updateNow()
    else
        local msg = string.format(CHS[3004444], charIcon, rideIcon) -- "没有配置骑乘角色icon =%d, 坐骑  = %d！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
    end
end

function PetMgr:setRideHeadOffset(dir, x, y)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    if not x or not y then
        gf:ShowSmallTips(CHS[3004442]) -- "坐标格式有错，必须是数字！"
        return
    end

    local act = "walk_head_"
    local charIcon = Me:getIcon()
    local rideIcon = Me:getRideIcon()
    local dir = dir or ""
    local key = (charIcon or "") .. "&" .. (rideIcon or "")
    local info = CharRidePointOffset[key]
    if info then
        info[act .. "x" .. dir] = x
        info[act .. "y" .. dir] = y
        local msg = string.format(CHS[3004449], dir, x, y) -- "设置方向 dir=%d 的头部偏移为 x=%d, y=%d 成功！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
        Me.charAction:updateNow()
    else
        local msg = string.format(CHS[3004444], charIcon, rideIcon) -- "没有配置骑乘角色icon =%d, 坐骑  = %d！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
    end
end

-- 获取元神共通宠物
function PetMgr:getChangePet()
    if SystemSettingMgr:getSettingStatus("award_supply_pet", 0) == 0 then
        return
    elseif SystemSettingMgr:getSettingStatus("award_supply_pet", 0) == 1 then
        return PetMgr:getRobPet()
    elseif SystemSettingMgr:getSettingStatus("award_supply_pet", 0) == 2 then
        return PetMgr:getPetById(PetMgr:getRideId())
    end
end

function PetMgr:setRideIcon(charIcon, petIcon, dir, act)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    dir = dir or 4
    act = act or Const.SA_STAND
    local msg = string.format(CHS[3004445], charIcon, petIcon, dir) -- "设置骑乘角色icon =%d, 坐骑  = %d, 方向 = %d 成功！"
    gf:ShowSmallTips(msg)
    ChatMgr:sendMiscMsg(msg)

    Me:setAct(act)
    MessageMgr:localPushMsg('MSG_UPDATE', {id = Me:getId(), mount_icon = charIcon, pet_icon = petIcon, dir=dir});
end

-- PetMgr:setCoupleRideIcon(760044, 770044, 31501, 1, 0)
function PetMgr:setCoupleRideIcon(charIcon1, charIcon2, petIcon, dir, act)
    if not gf:isWindows() then return end -- 仅供windows下调试

    dir = dir or 4
    act = act or Const.SA_STAND
    local msg = string.format(CHS[2500070], charIcon1, charIcon2, petIcon, dir) -- "设置夫妻骑乘角色icon1 =%d, icon2 = %d, 坐骑  = %d, 方向 = %d 成功！"
    gf:ShowSmallTips(msg)
    ChatMgr:sendMiscMsg(msg)

    Me:setAct(act)
    MessageMgr:localPushMsg('MSG_UPDATE', {id = Me:getId(), mount_icon = charIcon1, pet_icon = petIcon, dir=dir, gather_count = 1, gather_icons = { charIcon2 }});
end

-- PetMgr:setCoupleRideOffset(1, 15, -3, 15, -3)
function PetMgr:setCoupleRideOffset(dir, x1, y1, x2, y2)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    if not x1 or not y1 or not x2 or not y2 then
        gf:ShowSmallTips(CHS[3004442]) -- "坐标格式有错，必须是数字！"
        return
    end

    local act = (Me:isStandAction() and "" or "walk_")
    local charIcon1 = Me:getIcon()
    local gatherIcons = Me:getGatherIcons()
    local charIcon2
    if #gatherIcons > 0 then
        charIcon2 = gatherIcons[1]
    end

    local rideIcon = Me:getRideIcon()
    local dir = dir or ""
    local key, inof
    key = (charIcon1 or "") .. "&" .. (rideIcon or "") .. ":" .. (charIcon1 or "") .. ":" .. (charIcon2 or "")
    info = CharRidePointOffset[key]
    if not info then
        key = (charIcon1 or "") .. "&" .. (rideIcon or "")
        info = CharRidePointOffset[key]
    end
    if info then
        info[act .. "x" .. dir] = x1
        info[act .. "y" .. dir] = y1
        local msg = string.format(CHS[2500071], charIcon1, dir, x1, y1) -- "设置方向 icon=%d dir=%d 偏移置为 x=%d, y=%d 成功！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
        Me.charAction:updateNow()
    else
        local msg = string.format(CHS[3004444], charIcon1, rideIcon) -- "没有配置骑乘角色icon =%d, 坐骑  = %d！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
    end

    key = (charIcon2 or "") .. "&" .. (rideIcon or "") .. ":" .. (charIcon1 or "") .. ":" .. (charIcon2 or "")
    info = CharRidePointOffset[key]
    if info then
        info[act .. "x" .. dir] = x2
        info[act .. "y" .. dir] = y2
        local msg = string.format(CHS[2500072], charIcon2, dir, x2, y2) -- "设置方向 icon=%d dir=%d 偏移置为 x=%d, y=%d 成功！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
        Me.charAction:updateNow()
    else
        local msg = string.format(CHS[3004444], charIcon2, rideIcon) -- "没有配置骑乘角色icon =%d, 坐骑  = %d！"
        gf:ShowSmallTips(msg)
        ChatMgr:sendMiscMsg(msg)
    end
end

-- 设置坐骑某个方向的摆动信息，percent 表示如果整个动画要播放 100s 的话，摆动到 offsetX, offsetY 需要多长时间
function PetMgr:setSwingInfo(dir, offsetX, offsetY, percent)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    local rideIcon = Me:getRideIcon()
    local act = (Me:isStandAction() and "stand" or "walk")
    local swingInfo = { x = offsetX, y = offsetY, percent = percent }
    local info = PetRideInfo[rideIcon]
    if not info then
        PetRideInfo[rideIcon] = {}
        info = PetRideInfo[rideIcon]
    end

    info[act .. "_swing" .. dir] = swingInfo

    -- "设置摆动信息成功：坐骑=%d, 动作=%s, dir=%d, 摆动偏移 {x = %d, y = %d, percent = %d}",
    local msg = string.format(CHS[3004446], rideIcon, act, dir, offsetX, offsetY, percent)
    gf:ShowSmallTips(msg)
    ChatMgr:sendMiscMsg(msg)

    Me.charAction.petRideInfo = PetMgr:getPetRideInfo(rideIcon)
    Me.charAction:updateNow()
end

-- 设置遮挡偏移信息
function PetMgr:setShelterOffset(dir, x, y)
    if not gf:isWindows() then -- 仅提供window下调试
        return
    end

    local rideIcon = Me:getRideIcon()
    local shelterInfo = { x = x, y = y }
    local info = PetRideInfo[rideIcon]
    if not info then
        PetRideInfo[rideIcon] = {}
        info = PetRideInfo[rideIcon]
    end

    info["shelter_offset" .. dir] = shelterInfo

    -- "设置遮挡偏移信息成功：坐骑=%d, dir=%d, 遮挡偏移 {x = %d, y = %d}",
    local msg = string.format(CHS[3004448], rideIcon, dir, x, y)
    gf:ShowSmallTips(msg)
    ChatMgr:sendMiscMsg(msg)

    -- 清除缓存，让设置的点立即生效
    Me.charAction:clearBasicPointRange()
    Me.charAction.petRideInfo = PetMgr:getPetRideInfo(rideIcon)
    Me:updateShelter(gf:convertToMapSpace(Me.curX or 0, Me.curY or 0))
end

-- 用元宝购买天书灵气
function PetMgr:buyGodBooknimbusByCoin(pet_no, skill_name, coin_type)
    gf:CmdToServer("CMD_GODBOOK_BUY_NIMBUS", {
        pet_no = pet_no,
        skill_name = skill_name,
        coin_type = coin_type,
        nimbus = 3500,
    })
end

-- 重新加载宠物乘骑信息
function PetMgr:reloadPetRideInfo()
    package.loaded[ResMgr:getCfgPath('PetRideInfo.lua')] = nil
    PetRideInfo = require(ResMgr:getCfgPath('PetRideInfo.lua'))
end

-- 请求召唤精怪
function PetMgr:requestMount(flag)
    gf:CmdToServer('CMD_SUMMON_MOUNT_REQUEST', { ['flag'] = flag })
end

-- 转化精怪
function PetMgr:changeMount(pet)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not pet then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local mountLevel = pet:queryInt("capacity_level")
    if mountLevel >= 5 then
        gf:ShowSmallTips(CHS[2100002])
        return
    end

    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        gf:ShowSmallTips(CHS[2100003])
        return
    elseif pet_status == 2 then
        gf:ShowSmallTips(CHS[2100004])
        return
    elseif PetMgr:isRidePet(pet:getId()) then
        gf:ShowSmallTips(CHS[2100005])
        return
    elseif PetMgr:isFeedStatus(pet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end

    local nGodBookCount = pet:queryBasicInt('god_book_skill_count')
    if nGodBookCount and nGodBookCount >= 1 then
        gf:ShowSmallTips(CHS[2100006])
        return
    end

    if gf:isExpensive(pet, true) then
        gf:ShowSmallTips(CHS[2100007])
        return
    end

    if PetMgr:isTimeLimitedPet(pet) then  -- 限时宠物
        gf:ShowSmallTips(CHS[2100008])
        return
    end

    local mount_type = pet:queryInt("mount_type")

    if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI ~= mount_type and MOUNT_TYPE.MOUNT_TYPE_YULING ~= mount_type then
        gf:ShowSmallTips(CHS[2100009])
        return
    end

    local petType
    if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mount_type then
        petType = CHS[2100010]
    elseif MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then
        petType = CHS[2100011]
    end

    gf:confirm(string.format(CHS[2100012], gf:getMoneyDesc(CONVERT_PRICE), pet:queryBasic("raw_name"), petType, mountLevel),
    function()
        self:changeMountCb(pet)
    end)
end

function PetMgr:changeMountCb(pet)
    if not pet then return end

    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addModuleContinueCb("PetMgr", "changeMountCb", pet)
        return
    end

    -- 金钱不够
    if not gf:checkHasEnoughMoney(CONVERT_PRICE) then return end

    local isMorphed = PetMgr:isMorphed(pet)
    local isDevelop = PetMgr:getPetDevelopLevel(pet) > 0
    local isHaveGodSkill = PetMgr:isHaveGodSkill(pet)
    local enchant = pet:queryBasicInt("enchant")
    local isEnchant = 1 == enchant or 2 == enchant

    local strs = {}
    if isMorphed then
        table.insert(strs, CHS[2100013])
    end

    if isDevelop then
        table.insert(strs, CHS[2100014])
    end

    if isEnchant then
        table.insert(strs, CHS[2100015])
    end

    if isHaveGodSkill then
        table.insert(strs, CHS[2100016])
    end

    local function doConvertPet(pet)
        if PetMgr:isLimitedForeverPet(pet) then  -- 限制交易宠物
            gf:confirm(CHS[2100017],
                function()
                   gf:CmdToServer("CMD_MOUNT_CONVERT", { pet_no = pet:queryBasicInt("no") })
                end)
        elseif PetMgr:isLimitedPet(pet) then
            local _, day, hour, min = gf:converToLimitedTimeDay(pet:queryInt("gift"))
            local t = {}
            if day and day > 1 then
                table.insert(t, day)
                table.insert(t, CHS[3003845])
            elseif hour and hour > 1 then
                table.insert(t, hour)
                table.insert(t, CHS[3003846])
            elseif min and min > 0 then
                table.insert(t, min)
                table.insert(t, CHS[3003847])
            end

            gf:confirm(string.format(CHS[2200015], table.concat(t)), function()
                gf:CmdToServer("CMD_MOUNT_CONVERT", { pet_no = pet:queryBasicInt("no") })
            end)
        else
            gf:CmdToServer("CMD_MOUNT_CONVERT", { pet_no = pet:queryBasicInt("no") })
        end
    end

    if #strs > 0 then
        gf:confirm(string.format(CHS[2100018], table.concat(strs, CHS[2100019])),
        function()
            doConvertPet(pet)
        end)
    else
        doConvertPet(pet)
    end
end

-------------------------------------------- 提供调整坐骑方法

function PetMgr:MSG_QUERY_MOUNT_MERGE_RATE(data)
end

function PetMgr:MSG_PREVIEW_MOUNT_ATTRIB(data)
end

function PetMgr:MSG_SUMMON_MOUNT_RESULT(data)
end

function PetMgr:MSG_SUMMON_MOUNT_NOTIFY(data)
end

-- 交易类型的需要修改亲密
function PetMgr:setIntimacyForCard(dlg, showType, pet)
    if showType == "isMarket" or showType == "isJubao" then
        dlg:setLabelText("ValueLabel", CHS[4300225], "IntimacyPanel")
    elseif showType == "isGive" then
        dlg:setLabelText("ValueLabel", CHS[4300226], "IntimacyPanel")
    end


    -- 设置物伤 旧数据为0
    if pet:queryInt("phy_power_without_intimacy") ~= 0 then
        dlg:setLabelText("ValueLabel", pet:queryInt("phy_power_without_intimacy"), "PhyPowerPanel")
    else
        dlg:setLabelText("ValueLabel", pet:queryInt("phy_power"), "PhyPowerPanel")
    end

    -- 设置法伤
    if pet:queryInt("mag_power_without_intimacy") ~= 0 then
        dlg:setLabelText("ValueLabel", pet:queryInt("mag_power_without_intimacy"), "MagPowerPanel")
    else
        dlg:setLabelText("ValueLabel", pet:queryInt("mag_power"), "MagPowerPanel")
    end

    -- -- 设置防御
    if pet:queryInt("def_without_intimacy") ~= 0 then
        dlg:setLabelText("ValueLabel", pet:queryInt("def_without_intimacy"), "DefencePanel")
    else
        dlg:setLabelText("ValueLabel", pet:queryInt("def"), "DefencePanel")
    end


end

-- 设置基本信息Panel，用于宠物名片和寄售，Panel布局，空间名和 PetCardDlg一致才可用
function PetMgr:setBasicInfoForCard(pet, dlg, isJubao, isWithoutIntimacy)
    -- 精怪 御灵
    local mount_type = pet:queryInt("mount_type")
    local merge_rate = pet:queryBasicInt("merge_rate")

    -- 阶位
    if 0 ~= mount_type then
        dlg:setLabelText("ValueLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet)), "HorseLevelPanel")
    else
        dlg:setLabelText("ValueLabel", CHS[3001385], "HorseLevelPanel")
    end

    if MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then -- -- 御灵
        local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
        local speed = math.floor(pet:queryInt("mount_attrib/move_speed") / 5)
        if isJubao then
            ride_attrib = pet:queryBasic("mount_prop")
            speed = pet:queryInt("mount_move_speed")
        end

        if PetMgr:getFenghuaDay(pet) <= 0 then
            speed = 0
        end

        if not ride_attrib or  type(ride_attrib) ~= 'table' then
            ride_attrib = {phy_power = 0, mag_power = 0, def = 0, all_attribute = 0}
        end

        -- 主人攻击
        local phy_power = ride_attrib.phy_power
        dlg:setLabelText("ValueLabel", "+" .. phy_power, "AddPhyPowerPanel")

        -- 主人法攻
        local mag_power = ride_attrib.mag_power
        dlg:setLabelText("ValueLabel", "+" .. mag_power, "AddMagPowerPanel")

        -- 主人防御
        local def = ride_attrib.def
        dlg:setLabelText("ValueLabel", "+" .. def, "AddDefencePowerPanel")

        -- 主任所有属性
        local all_attribute = ride_attrib.all_attrib or ride_attrib.all_attribute or 0
        dlg:setLabelText("ValueLabel", "+" .. all_attribute, "AddAllPowerPanel")

        -- 主人仙魔点
        local xianPoint = ride_attrib.upgrade_immortal or 0
        dlg:setLabelText("ValueLabel", "+" .. xianPoint, "XianPanel")
        local moPoint = ride_attrib.upgrade_magic  or 0
        dlg:setLabelText("ValueLabel", "+" .. moPoint, "MoPanel")

        -- 移动速度
        -- 速度的级数和速度百分比是5倍关系
        dlg:setLabelText("ValueLabel", string.format(CHS[3003355], speed), "SpeefPanel")

    else
        dlg:setLabelText("ValueLabel", "+" .. 0, "AddPhyPowerPanel")
        dlg:setLabelText("ValueLabel", "+" .. 0, "AddMagPowerPanel")
        dlg:setLabelText("ValueLabel", "+" .. 0, "AddDefencePowerPanel")
        dlg:setLabelText("ValueLabel", "+" .. 0, "AddAllPowerPanel")
        dlg:setLabelText("ValueLabel", "+" .. 0, "XianPanel")
        dlg:setLabelText("ValueLabel", "+" .. 0, "MoPanel")
        dlg:setLabelText("ValueLabel", string.format(CHS[3003355], 0), "SpeefPanel")
    end

    if merge_rate <= 0 then
        dlg:setLabelText("ValueLabel", CHS[5000059], "HorseFusePanel")
        if MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then
            -- 风灵丸
            local day = PetMgr:getFenghuaDay(pet)
            if isJubao then
                day = PetMgr:getFenghuaDay(pet, pet:queryInt("mount_flw_time"))
            end
            dlg:setLabelText("ValueLabel", string.format(CHS[34050], day), "HorseFenglingPanel")
        else
            -- 风灵丸
            dlg:setLabelText("ValueLabel", CHS[3001385], "HorseFenglingPanel")
        end
    else
        -- 风灵丸
        dlg:setLabelText("ValueLabel", string.format(CHS[34050], 0), "HorseFenglingPanel")
        dlg:setCtrlVisible("HorseFusePanel", true, "InfoPanel")

        if MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type then
            -- 风灵丸
            local day = PetMgr:getFenghuaDay(pet)
            if isJubao then
                day = PetMgr:getFenghuaDay(pet, pet:queryInt("mount_flw_time"))
            end
            dlg:setLabelText("ValueLabel", string.format(CHS[34050], day), "HorseFenglingPanel")

            -- 融合度
            dlg:setLabelText("ValueLabel", string.format("%.2f%%", merge_rate / 10000), "HorseFusePanel")
        else
            -- 融合度
            dlg:setLabelText("ValueLabel", string.format("%.2f%%", merge_rate / 10000), "HorseFusePanel")
        end
    end

    -- 携带
    dlg:setLabelText("ValueLabel", pet:queryInt("req_level"), "CatchLevelPanel")

    -- 设置气血
    dlg:setLabelText("ValueLabel", pet:queryInt("max_life"), "LifePanel")

    -- 设置法力
    dlg:setLabelText("ValueLabel", pet:queryInt("max_mana"), "ManaPanel")

    -- 设置速度
    dlg:setLabelText("ValueLabel", pet:queryInt("speed"), "SpeedPanel")

    -- 设置物伤
    dlg:setLabelText("ValueLabel", pet:queryInt("phy_power"), "PhyPowerPanel")

    -- 设置法伤
    dlg:setLabelText("ValueLabel", pet:queryInt("mag_power"), "MagPowerPanel")

    -- 设置防御
    dlg:setLabelText("ValueLabel", pet:queryInt("def"), "DefencePanel")

    -- 设置亲密
    dlg:setLabelText("ValueLabel", pet:queryInt("intimacy"), "IntimacyPanel")

    if (isJubao or isWithoutIntimacy or dlg.name == "JuBaoPetSellDlg")
        and dlg.name ~= "JuBaoUserViewPetDlg" then


        dlg:setLabelText("ValueLabel", CHS[4300225], "IntimacyPanel")

    -- 设置物伤
        dlg:setLabelText("ValueLabel", pet:queryInt("phy_power_without_intimacy"), "PhyPowerPanel")

        -- 设置法伤
        dlg:setLabelText("ValueLabel", pet:queryInt("mag_power_without_intimacy"), "MagPowerPanel")

        -- 设置防御
        dlg:setLabelText("ValueLabel", pet:queryInt("def_without_intimacy"), "DefencePanel")
    end



    -- 设置武学
    dlg:setLabelText("PetMartialLabel", CHS[4200230] .. pet:queryInt("martial"))

    -- 体质
    dlg:setLabelText("ValueLabel", pet:queryInt("con"), "ConPanel")

    -- 力量
    dlg:setLabelText("ValueLabel", pet:queryInt("str"), "StrPanel")

    -- 灵力
    dlg:setLabelText("ValueLabel", pet:queryInt("wiz"), "WizPanel")

    -- 敏捷
    dlg:setLabelText("ValueLabel", pet:queryInt("dex"), "DexPanel")

    -- 剩余点数
    dlg:setLabelText("ValueLabel", pet:queryInt("attrib_point"), "UnAssginPanel")

    -- 抗金
    dlg:setLabelText("ValueLabel", pet:query("resist_metal"), "ResitMetalPanel")

    -- 抗水
    dlg:setLabelText("ValueLabel", pet:query("resist_water"), "ResitWaterPanel")

    -- 抗木
    dlg:setLabelText("ValueLabel", pet:query("resist_wood"), "ResitWoodPanel")

    -- 抗土
    dlg:setLabelText("ValueLabel", pet:query("resist_earth"), "ResitEarthPanel")

    -- 抗火
    dlg:setLabelText("ValueLabel", pet:query("resist_fire"), "ResitFirePanel")

    -- 抗遗忘
    dlg:setLabelText("ValueLabel", pet:query("resist_forgotten"), "ResitForgottenPanel")

    -- 抗中毒
    dlg:setLabelText("ValueLabel", pet:query("resist_poison"), "ResitPoisonPanel")

    -- 抗冰冻
    dlg:setLabelText("ValueLabel", pet:query("resist_frozen"), "ResitFrozenPanel")

    -- 抗昏睡
    dlg:setLabelText("ValueLabel", pet:query("resist_sleep"), "ResitSleepPanel")

    -- 抗混乱
    dlg:setLabelText("ValueLabel", pet:query("resist_confusion"), "ResitConfusionPanel")

    -- 抗性点数
    dlg:setLabelText("ValueLabel", pet:query("resist_point"), "ResitUnAssginPanel")

    -- 妖石
    PetMgr:setPetStoneForCard(pet, dlg, isJubao)
end

-- 获取妖石信息
function PetMgr:setPetStoneForCard(pet, dlg, isJubao)
    -- 隐藏
    local attribs = { num = 0 }
    if not pet then return end

    if not isJubao then
        local count = 1
        for i = GROUP_NO.STONE_START, GROUP_NO.STONE_END do
            local info = pet:queryBasic('group_' .. i)
            if info.no and info.no >= GROUP_NO.STONE_START and info.no <= GROUP_NO.STONE_END then
                attribs[count] = info
                count = count + 1
            end
        end

        attribs.num = pet:queryBasicInt("stone_num")
    else
        local yaoshiInfo = pet:queryBasic("yaoshi")
        if yaoshiInfo and type(yaoshiInfo) == "table" then
            local count = 0
            for i = 1, 3 do
                if yaoshiInfo["yaoshi_" .. i] then
                    attribs[i] = {}
                    attribs[i].name = yaoshiInfo["yaoshi_" .. i].name
                    attribs[i].level = yaoshiInfo["yaoshi_" .. i].level
                    attribs[i].nimbus = yaoshiInfo["yaoshi_" .. i].nimbus

                    for field, value in pairs(yaoshiInfo["yaoshi_" .. i].prop) do
                        attribs[i][field] = value
                    end
                    count = count + 1
                end
            end
            attribs.num = count
        end
    end


    dlg:setLabelText("ValueLabel", attribs.num .. "/3", "PetStoneCountPanel")

    for i = 1, 3 do
        if attribs.num >= i then
            local v = attribs[i]
            local panel = dlg:getControl("PetStonePanel_" .. i)
            local info = STONE_ATTRIB[v["name"]]
            dlg:setCtrlVisible("PetStonePanel_" .. i, true)
            dlg:setImage("StoneImage", InventoryMgr:getIconFileByName(v["name"]), panel)
            dlg:setItemImageSize("StoneImage", panel)
            dlg:setLabelText("TypeLabel", v["level"] .. CHS[3002651] .. v["name"] .. ":", panel)
            dlg:setLabelText("ValueLabel_2", info[1] .. " " .. v[info[2]], panel)
            dlg:setLabelText("ValueLabel_1", CHS[3003370] .. " " .. v["nimbus"], panel)
        else
            local panel = dlg:getControl("PetStonePanel_" .. i)
            dlg:setImagePlist("StoneImage", ResMgr.ui.ask_symbol, panel)
            dlg:setLabelText("TypeLabel", CHS[7000303], panel)
            dlg:setLabelText("ValueLabel_2", "", panel)
            dlg:setLabelText("ValueLabel_1", "", panel)
        end
    end


end

-- 设置成长信息Panel，用于宠物名片和寄售，Panel布局，控件名和 PetCardDlg一致才可用
function PetMgr:setAttribInfoForCard(pet, dlg, isJubao)
    -- 气血成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    if isJubao then basicLife = pet:queryInt("pet_life_effect") end
    local lifeShape = pet:queryInt("pet_life_shape")
    if lifeShape ~= basicLife then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", lifeShape, basicLife, lifeShape - basicLife), "LifeEffectPanel")
    else
        dlg:setLabelText("ValueLabel", lifeShape, "LifeEffectPanel")
    end

    -- 法力成长
    local manaShape = pet:queryInt("pet_mana_shape")
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    if isJubao then basicMana = pet:queryBasicInt("pet_mana_effect") end
    if manaShape ~= basicMana then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", manaShape, basicMana, manaShape - basicMana), "ManaEffectPanel")
    else
        dlg:setLabelText("ValueLabel", manaShape, "ManaEffectPanel")
    end

    -- 速度成长
    local speedShape = pet:queryInt("pet_speed_shape")
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    if isJubao then basicSpeed = pet:queryBasicInt("pet_speed_effect") end
    if speedShape ~= basicSpeed then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", speedShape, basicSpeed, speedShape - basicSpeed), "SpeedEffectPanel")
    else
        dlg:setLabelText("ValueLabel", speedShape, "SpeedEffectPanel")
    end

    -- 物攻成长
    local phyShape = pet:queryInt("pet_phy_shape")
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    if isJubao then basicPhy = pet:queryBasicInt("pet_phy_effect") end
    if phyShape ~= basicPhy then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", phyShape, basicPhy, phyShape - basicPhy), "PhyEffectPanel")
    else
        dlg:setLabelText("ValueLabel", phyShape, "PhyEffectPanel")
    end

    -- 法攻成长
    local magShape = pet:queryInt("pet_mag_shape")
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    if isJubao then basicMag = pet:queryBasicInt("pet_mag_effect") end
    if magShape ~= basicMag then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", magShape, basicMag, magShape - basicMag), "MagEffectPanel")
    else
        dlg:setLabelText("ValueLabel", magShape, "MagEffectPanel")
    end

    -- 总成长
    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape
    local totalBasic = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    if totalAll ~= totalBasic then
        dlg:setLabelText("ValueLabel", string.format("%d(%d + %d)", totalAll, totalBasic, totalAll - totalBasic), "TotalEffectPanel")
    else
        dlg:setLabelText("ValueLabel", totalAll, "TotalEffectPanel")
    end

    -- 强化相关
    local phyStrongTime = pet:queryInt("phy_rebuild_level")
    local magStrongTime = pet:queryInt("mag_rebuild_level")
    local phyStrongRate = pet:queryInt("phy_rebuild_rate")
    local magStrongRate = pet:queryInt("mag_rebuild_rate")

    -- 物攻强化
    if phyStrongRate == 0 then
        dlg:setLabelText("ValueLabel", phyStrongTime .. CHS[3003367], "PhyStrengthPanel")
    else
        dlg:setLabelText("ValueLabel", phyStrongTime .. CHS[3003368] .. phyStrongRate / 100 .. "%)", "PhyStrengthPanel")
    end

    -- 攻击强化
    if magStrongRate == 0 then
        dlg:setLabelText("ValueLabel", magStrongTime .. CHS[3003367], "MagStrengthPanel")
    else
        dlg:setLabelText("ValueLabel", magStrongTime .. CHS[3003368] .. magStrongRate / 100 .. "%)", "MagStrengthPanel")
    end

    -- 点化
    local now = pet:queryBasicInt("enchant_nimbus")
    local total = Formula:getPetDianhuaMaxNimbus(pet)
    local pers = math.floor(now / total * 100 * 100) * 0.01
    if pet:queryBasicInt("enchant") == 2 then
        dlg:setLabelText("ValueLabel", CHS[4300000], "DianHuaPanel")
    else
        dlg:setLabelText("ValueLabel", string.format("%d/%d (%0.2f", now, total, pers) .. "%)", "DianHuaPanel")
    end

    -- 羽化
    local total = Formula:getPetYuhuaMaxNimbus(pet)
    if PetMgr:isYuhuaCompleted(pet) then
        dlg:setLabelText("ValueLabel", string.format(CHS[4100987]), "YuHuaPanel")
    else
        local now = pet:queryBasicInt("eclosion_nimbus")
        dlg:setLabelText("ValueLabel", string.format("%s %d/%d(%0.2f%%)", PetMgr:getYuhuaStageChs(pet), now, total, PetMgr:getYuhuaPercent(pet)), "YuHuaPanel")
    end

    -- 魂魄
    local soul = pet:queryBasic("evolve")
    if soul == "" then soul = CHS[5000059] end
    dlg:setLabelText("ValueLabel", soul, "EvolveValuePanel")

    -- 飞升
    local isFlyPet = PetMgr:isFlyPet(pet)
    if isFlyPet then
        dlg:setLabelText("ValueLabel", CHS[7002287], "UpgradeValuePanel")
    else
        dlg:setLabelText("ValueLabel", CHS[7002286], "UpgradeValuePanel")
    end

    -- 幻化
    local infoMap = {
        [1] = {field = "life",  panel = "LifeEffectPanel"},
        [2] = {field = "mana",  panel = "ManaEffectPanel"},
        [3] = {field = "speed", panel = "SpeedEffectPanel"},
        [4] = {field = "phy",  panel = "PhyEffectPanel"},
        [5] = {field = "mag",  panel = "MagEffectPanel"},
    }
    local parentPanel = dlg:getControl("HuanHuaValuePanel")
    local hMax = PetMgr:getHuanProgressMax(pet)
    for i = 1, #infoMap do
        local panel = dlg:getControl(infoMap[i].panel, nil, parentPanel)
        local fieldTimes = string.format("morph_%s_times", infoMap[i].field)
        dlg:setLabelText("ValueLabel", string.format(CHS[4100358], pet:queryBasicInt(fieldTimes)), panel)
        local fieldPro = string.format("morph_%s_stat", infoMap[i].field)
        local feedTime = pet:queryBasicInt(fieldPro)
        if feedTime == 0 or pet:queryBasicInt(fieldTimes) == PetMgr:getMorphMaxTimes() then
            dlg:setLabelText("ValueLabel_1", "", panel)
        else
            dlg:setLabelText("ValueLabel_1", string.format(CHS[4100359], feedTime, hMax), panel)
        end
    end

    parentPanel:requestDoLayout()
end

-- 设置技能信息Panel，用于宠物名片和寄售，Panel布局，空间名和 PetCardDlg一致才可用
function PetMgr:setSkillInfoForCard(pet, dlg, isJubao)
    -- 天生技能
    PetMgr:setNaturalSkillForCard(pet, dlg, isJubao)

    -- 研发
    PetMgr:setStudySkillForCard(pet, dlg, isJubao)

    -- 顿悟
    PetMgr:setDunwuSkillForCard(pet, dlg, isJubao)

    -- 天书
    PetMgr:setGodBookSkillForCard(pet, dlg, isJubao)
end

-- 设置技能信息Panel，用于宠物名片和寄售，Panel布局，空间名和 PetCardDlg一致才可用   天生技能
function PetMgr:setNaturalSkillForCard(pet, dlg, isJubao)
    local skills = {}
    local naturalSkills = {}
    local inateSkill = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}

    if dlg.isMePet and (pet.getId and pet:getId() and PetMgr:getPetById(pet:getId())) then
        -- me 的宠物，从管理器中取技能

        skills = SkillMgr:getPetRawSkillNoAndLadder(pet:getId())
    else
        if isJubao then
            local totalSkill = pet:queryBasic("skills")
            if totalSkill and totalSkill["skill_tiansheng"] then
                local info = totalSkill["skill_tiansheng"]
                for n, skillInfo in pairs(info) do
                    local orderTab = SkillMgr:getNatureSkillOrder()
                    local skillCfg = SkillMgr:getskillAttribByName(skillInfo.name)
                    local data = {}
                    data.name = skillInfo.name
                    data.level = skillInfo.level
                    data.ladder = skillInfo.ladder
                    data.no = skillCfg.skill_no
                    data.order = orderTab[data.name] or 100
                    table.insert(skills, data)
                    --         retTab[data.no] = data
                end
            end
        else
        local retTab = {}
        for _, info in pairs(pet:queryBasic("skills")) do
                    local no = info.skill_no
                    local skillInfo = SkillMgr:getskillAttrib(info.skill_no)
                    info.subclass = skillInfo.skill_subclass
                    info.class = skillInfo.skill_class
                    info.ladder = skillInfo.skill_ladder
                    retTab[no] = info
                    end

            skills = SkillMgr:getPetRawSkillNoAndLadderBySkills( retTab, nil, pet:queryBasic("raw_name"))
                end
            end


    -- 转化表格式
    local hasSkill = {}
    for i = 1, #skills do
        local name = SkillMgr:getSkillName(skills[i].no)
        skills[i].name = name
        hasSkill[skills[i].name] = skills[i]
    end

    -- 天升级能排序的order
    local orders = SkillMgr:getNatureSkillOrder()
    local allNaturalSkill = {}
    for i = 1, #inateSkill do
        local skillTemp = SkillMgr:getskillAttribByName(inateSkill[i])
        skillTemp.order = orders[inateSkill[i]] or 100
        table.insert(allNaturalSkill, skillTemp)
    end
    table.sort(allNaturalSkill, function(l, r)
        return l.order < r.order
    end)

    if #allNaturalSkill == 0 then
        -- 天生技能为0
        for i = 1, 3 do
            local panel = dlg:getControl("InnateSkillPanel_" .. i)
            panel:setVisible(false)
            dlg:setCtrlVisible("NoneSkillImage", true)
        end
        return
    end

    dlg:setCtrlVisible("NoneSkillImage", false)
    -- 设置可以学的
    for i = 1, 3 do
        local panel = dlg:getControl("InnateSkillPanel_" .. i)
        panel:setVisible(true)
        if allNaturalSkill[i] then
            local skillIconPath = ResMgr:getSkillIconPath(allNaturalSkill[i].skill_icon)
            dlg:setImage("InnateSkillImage_1", skillIconPath, panel)
            dlg:setItemImageSize("InnateSkillImage_1", panel)
            panel.skillName = allNaturalSkill[i].name
            dlg:setLabelText("SkillNameLabel", allNaturalSkill[i].name, panel)
            dlg:setLabelText("SkillLevelLabel", "", panel)
            dlg:setCtrlEnabled("InnateSkillImage_1", false, panel)
        else
            -- 没有可学习的
            dlg:setImagePlist("InnateSkillImage_1", ResMgr.ui.pet_skill_none, panel)
            dlg:setLabelText("SkillNameLabel", CHS[4200233], panel)
            dlg:setCtrlEnabled("InnateSkillImage_1", true, panel)
            dlg:setLabelText("SkillLevelLabel", "", panel)
            panel.skillName = nil
        end
    end

    -- 设置已经有的
    for i = 1, 3 do
        local panel = dlg:getControl("InnateSkillPanel_" .. i)
        if panel.skillName and hasSkill[panel.skillName] then
            dlg:setCtrlEnabled("InnateSkillImage_1", true, panel)
            dlg:setLabelText("SkillLevelLabel", hasSkill[panel.skillName].level .. CHS[5300006], panel)

            dlg:bindTouchEndEventListener(panel, function(obj, sender, type)
                if panel.skillName then
                    if dlg.setSkillCard then
                        dlg:setSkillCard(pet, panel.skillName, sender)
                    else
                        local rect = dlg:getBoundingBoxInWorldSpace(panel)
                        local dlg1 = DlgMgr:openDlg("SkillFloatingFrameDlg")
                        dlg1:setSKillByName(panel.skillName , rect, true)
                    end
                end
            end)
        elseif panel.skillName then
            dlg:bindTouchEndEventListener(panel, function(obj, sender, type)
                if panel.skillName then
                    local rect = dlg:getBoundingBoxInWorldSpace(panel)
                    local dlg1 = DlgMgr:openDlg("SkillFloatingFrameDlg")
                    dlg1:setSKillByName(panel.skillName , rect, true)
                end
            end)
        end
    end
end

function PetMgr:setStudySkillForCard(pet, dlg, isJubao)
    -- 设置可以学习的技能
    -- 获取 研发技能
    local skillsName = {CHS[3003439], CHS[3003440], CHS[3003441], CHS[3003442]}
    local normalSkills = {}
    for i = 1, #skillsName do
        table.insert(normalSkills, SkillMgr:getskillAttribByName(skillsName[i]))
    end
    for i = 1, 4 do
        local panel = dlg:getControl("DevelopSkillPanel_" .. i, Const.UIPanel)
        local skillIconPath = ResMgr:getSkillIconPath(normalSkills[i].skill_icon)
        dlg:setImage("InnateSkillImage_1", skillIconPath, panel)
        dlg:setItemImageSize("InnateSkillImage_1", panel)
        panel.skillName = normalSkills[i].name
        dlg:setLabelText("SkillNameLabel", normalSkills[i].name, panel)
        dlg:setLabelText("SkillLevelLabel", "", panel)
        dlg:setCtrlEnabled("InnateSkillImage_1", false, panel)
    end

    -- 设置已学习的技能
    local skillsTab = {}
    if dlg.isMePet and (pet.getId and pet:getId() and PetMgr:getPetById(pet:getId())) then
        skillsTab = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_E, SKILL.CLASS_PET)
    else
        local skills = pet:queryBasic("skills")
        if type(skills) ~= "table" then skills = {} end

        if isJubao then
            if skills.skill_yanfa then
                for _, skillInfo in pairs(skills["skill_yanfa"]) do
                    local skillCfg = SkillMgr:getskillAttribByName(skillInfo.name)
                    local data = {}
                    data.name = skillInfo.name
                    data.level = skillInfo.level
                    data.no = skillCfg.skill_no
                    table.insert(skillsTab, data)
                end
            end

        else
            local idx = 0
            for no, v in pairs(skills) do
                if v.class == SKILL.CLASS_PET and v.subclass == SKILL.SUBCLASS_E then
                    idx = idx + 1
                    skillsTab[idx] = {no = v.skill_no, level = v.skill_level}
                end
            end
        end
    end

    -- 转化成目标表
    local studySkills = {}
    for i = 1, #skillsTab do
        local skillName = SkillMgr:getskillAttrib(skillsTab[i].no).name
        local temp = skillsTab[i]
        temp.name = skillName
        studySkills[skillName] = temp
    end

    for i = 1, 4 do
        local panel = dlg:getControl("DevelopSkillPanel_" .. i, Const.UIPanel)
        if panel.skillName and studySkills[panel.skillName] then
            dlg:setCtrlEnabled("InnateSkillImage_1", true, panel)
            dlg:setLabelText("SkillLevelLabel", studySkills[panel.skillName].level .. CHS[5300006], panel)

            dlg:bindTouchEndEventListener(panel, function(obj, sender, type)
                if dlg.setSkillCard then
                    dlg:setSkillCard(pet, panel.skillName, sender)
                else
                    local rect = dlg:getBoundingBoxInWorldSpace(panel)
                    local dlg1 = DlgMgr:openDlg("SkillFloatingFrameDlg")
                    dlg1:setSKillByName(panel.skillName , rect, true)
                end
            end)
        elseif panel.skillName then
            dlg:bindTouchEndEventListener(panel, function(obj, sender, type)
                local rect = dlg:getBoundingBoxInWorldSpace(panel)
                local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                dlg:setSKillByName(panel.skillName , rect, true)
            end)
        end
    end
end

-- 设置顿悟技能 by songcw
function PetMgr:setDunwuSkillForCard(pet, dlg, isJubao)
    -- 顿悟次数
    local dunwuTimes = pet:queryBasicInt("dunwu_times")
    dlg:setLabelText("DuwuTimesLabel", string.format(CHS[4200232], dunwuTimes), "DunWuSkillPanel")

    local skills = SkillMgr:getPetDunWuSkillsByPet(pet, isJubao)

    for i = 1, 2 do
        local panel = dlg:getControl("DunWuSkillPanel_" .. i)
        if skills[i] then
            panel.skillInfo = skills[i]
            local icon = SkillMgr:getskillAttrib(skills[i].skill_no or skills[i].no).skill_icon
            local skillIconPath = ResMgr:getSkillIconPath(icon)
            local skillName = skills[i].skill_name or skills[i].name
            dlg:setImage("InnateSkillImage_1", skillIconPath, panel)
            dlg:setItemImageSize("InnateSkillImage_1", panel)
            dlg:setLabelText("SkillNameLabel", skillName, panel)

            local level = skills[i].skill_level or skills[i].level
            dlg:setLabelText("SkillLevelLabel", level .. CHS[5300006], panel)

            dlg:setLabelText("NimbusLabel_1", CHS[4300204], panel)
            dlg:setLabelText("NimbusLabel_1_1", skills[i].skill_nimbus, panel)

            dlg:bindTouchEndEventListener(panel, function(obj, sender, type)
                if sender.skillInfo then
                    if dlg.setSkillCard then
                        dlg:setSkillCard(pet, skillName, sender)
                    else
                        local rect = dlg:getBoundingBoxInWorldSpace(panel)
                        local dlg1 = DlgMgr:openDlg("SkillFloatingFrameDlg")
                        dlg1:setSKillByName(skillName, rect, true)
                    end
                end
            end)
        else
            panel.skillInfo = nil
    --        dlg:setImagePlist("InnateSkillBKImage", ResMgr.ui.bag_no_item_bg_img, panel)
            dlg:setImagePlist("InnateSkillImage_1", ResMgr.ui.ask_symbol, panel)
            dlg:setLabelText("SkillLevelLabel", "", panel)
            dlg:setLabelText("NimbusLabel_1_1", "", panel)
            dlg:setLabelText("NimbusLabel_1", "", panel)
            dlg:setLabelText("SkillNameLabel", CHS[4200231], panel)
        end
    end

    local rank = pet:queryInt('rank')
    dlg:setCtrlVisible("DunWuSkillPanel_2", rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC)
end

function PetMgr:getGodBookByPet(pet)
    local tianshuSkill = {}
    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    for i = 1, 3 do
        if i <= godBookCount then
            local data = {}
            local skillCfg = SkillMgr:getskillAttribByName(pet:queryBasic('god_book_skill_name_' .. i))
            data.skill_name = pet:queryBasic('god_book_skill_name_' .. i)
            data.skill_level = pet:queryBasic('god_book_skill_level_' .. i)
            data.skill_nimbus = pet:queryBasicInt('god_book_skill_power_' .. i)
            data.skill_disabled = pet:queryBasicInt('god_book_skill_disabled_' .. i)
            data.skill_no = skillCfg.skill_no

            table.insert(tianshuSkill, data)
        end
    end

    return tianshuSkill
end

-- 宠物天书
function PetMgr:setGodBookSkillForCard(pet, dlg, isJubao)
    local tianshuSkill = {}

    if isJubao then
        -- 聚宝json格式
        local skills = pet:queryBasic("skills")
        if not skills or (type(skills) == "table" and not next(skills)) or skills == "" then return {} end
        if skills["skill_tianshu"] then
            for _, skillInfo in pairs(skills["skill_tianshu"]) do
                local skillCfg = SkillMgr:getskillAttribByName(skillInfo.name)
                local data = {}
                data.skill_name = skillInfo.name
                data.skill_level = skillInfo.level
                data.skill_nimbus = skillInfo.nimbus
                data.skill_no = skillCfg.skill_no
                data.disabled = skillInfo.disable
                table.insert(tianshuSkill, data)
            end
        end
    else
        local godBookCount = pet:queryBasicInt('god_book_skill_count')
        for i = 1, 3 do
            if i <= godBookCount then
                local data = {}
                local skillCfg = SkillMgr:getskillAttribByName(pet:queryBasic('god_book_skill_name_' .. i))
                data.skill_name = pet:queryBasic('god_book_skill_name_' .. i)
                data.skill_level = pet:queryBasic('god_book_skill_level_' .. i)
                data.skill_nimbus = pet:queryBasicInt('god_book_skill_power_' .. i)
                data.disabled = pet:queryBasicInt('god_book_skill_disabled_' .. i)

                data.skill_no = skillCfg.skill_no

                table.insert(tianshuSkill, data)
            end
        end
    end


    for i = 1, 3 do
        local panel = dlg:getControl("GodbookSkillPanel_" .. i, Const.UIPanel)
        dlg:setCtrlEnabled("InnateSkillImage_1", true, panel)
        if tianshuSkill[i] then
            panel:setVisible(true)
            local color = COLOR3.TEXT_DEFAULT
            if tianshuSkill[i].disabled then
                dlg:setCtrlEnabled("InnateSkillImage_1", (tianshuSkill[i].disabled and tianshuSkill[i].disabled == 0), panel)
                if tianshuSkill[i].disabled ~= 0 then
                    color = COLOR3.GRAY
                end
            else
                dlg:setCtrlEnabled("InnateSkillImage_1", true, panel)
            end

            -- 如果没有灵气
            if tianshuSkill[i].skill_nimbus == 0 then
                dlg:setCtrlEnabled("InnateSkillImage_1", false, panel)
                color = COLOR3.GRAY
            end

            local skillIconPath = SkillMgr:getSkillIconPath(tianshuSkill[i].skill_no)
            dlg:setImage("InnateSkillImage_1", skillIconPath, panel)
            dlg:setItemImageSize("InnateSkillImage_1", panel)
            dlg:setLabelText("SkillNameLabel", tianshuSkill[i].skill_name, panel, color)
            dlg:setLabelText("SkillLevelLabel", tianshuSkill[i].skill_level .. CHS[5300006], panel, color)
            dlg:setLabelText("NimbusLabel_1", CHS[4300204], panel, color)
            dlg:setLabelText("NimbusLabel_1_1", tianshuSkill[i].skill_nimbus, panel, color)



            panel.data = tianshuSkill[i]
            dlg:bindListener("GodbookSkillPanel_" .. i, function(obj, sender, type)
                if sender.data then
                    if dlg.setSkillCard then
                        dlg:setSkillCard(pet, sender.data.skill_name, sender)
                    else
                        local rect = dlg:getBoundingBoxInWorldSpace(panel)
                        local dlg1 = DlgMgr:openDlg("SkillFloatingFrameDlg")
                        dlg1:setSKillByName(sender.data.skill_name, rect, true)
                    end
                end
            end)
        else
            panel.data = nil
        --    dlg:setImagePlist("InnateSkillBKImage", ResMgr.ui.bag_no_item_bg_img, panel)
            dlg:setImagePlist("InnateSkillImage_1", ResMgr.ui.ask_symbol, panel)
            dlg:setLabelText("SkillNameLabel", CHS[4200231], panel, COLOR3.TEXT_DEFAULT)
            dlg:setLabelText("NimbusLabel_1_1", "", panel, COLOR3.TEXT_DEFAULT)
            dlg:setLabelText("NimbusLabel_1", "", panel, COLOR3.TEXT_DEFAULT)
            dlg:setLabelText("SkillLevelLabel", "", panel, COLOR3.TEXT_DEFAULT)
        end
    end
end

function PetMgr:getNormalPetPolar(rawName)
    if not NormalPetList[rawName] then
        return
    end

    return NormalPetList[rawName].polar
end

-- 获取某角色骑乘某骑宠所对应的“角色骑乘模型”
function PetMgr:getMountIcon(charIcon, petIcon)
    local polar, gender = ResMgr:getPolarAndGenerByIcon(charIcon)

    if not Me:isRealBody() then
        -- 如果处于元婴或者血婴状态，需要将polar赋值为配置表中元婴索引
        polar = 6
        gender = Me:getChildType()
    end

    if PetRideIconInfo[petIcon] and PetRideIconInfo[petIcon][gender] and PetRideIconInfo[petIcon][gender][polar] then
        return PetRideIconInfo[petIcon][gender][polar]
    end
end

function PetMgr:isFlyPet(pet)
    if pet:queryBasicInt("has_upgraded") > 0 then
        return true
    else
        return false
    end
end

function PetMgr:getPetsCanFly()
    local pets = {}
    for _, pet in pairs(self.pets) do
        if (pet:getLevel() >= Const.PET_FLY_LIMIT_LEVEL) and (not PetMgr:isFlyPet(pet)) then
            table.insert(pets, pet)
        end
    end

    return pets
end

function PetMgr:setLastSelectPet(pet)
    self.lastSelectPet = pet
end

function PetMgr:getLastSelectPet()
    return self.lastSelectPet
end

-- 获取饲养中的宠物的数量
function PetMgr:getFeedPetCount()
    return #self.feedPets
end

-- 该只宠物是否正处于饲养状态
function PetMgr:isFeedStatus(pet)
    local iid
    if 'string' == type(pet) then
        iid = pet
    else
        iid = pet:queryBasic("iid_str")
    end

    for _, v in ipairs(self.feedPets) do
        if iid == v.pet_iid then
            return true
        end
    end
    return false
end

-- 该只宠物是否处于已注入彩凤之魂状态
function PetMgr:isCFZHStatus(pet)
    local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
    return ride_attrib and 1 == ride_attrib.soul_state
end

function PetMgr:getFlyTaskPetId()
    return self.inFlyTaskPetId
end

-- 该只宠物是否正处于饲养状态
function PetMgr:MSG_HOUSE_FEEDING_LIST(data)
    self.feedPets = data
end

function PetMgr:MSG_UPGRADE_TASK_PET(data)
    if not data.id then
        return
    end

    self.inFlyTaskPetId = data.id
end

-- 获取骑宠仙魔点数加成
function PetMgr:getRidePetXianMoBuff()
    -- 骑宠
    local pet = PetMgr:getPetById(PetMgr:getRideId())
    local petPoint = 0
    if pet then

        -- 风灵丸时间
        local day = PetMgr:getFenghuaDay(pet)

        if day <= 0 then
            return petPoint
        end


        local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
        petPoint = ride_attrib.upgrade_immortal
    end

    return petPoint
end

function PetMgr:getIntimacyCfg()
    return PetIntimacyEffctCfg
end

function PetMgr:getYuhuaPercent(pet)
    local now = pet:queryBasicInt("eclosion_nimbus")
    local total = Formula:getPetYuhuaMaxNimbus(pet)
    local pers = math.floor(now / total * 100 * 100)

    return math.min(100, pers * 0.01)
end

function PetMgr:getYuhuaStageChs(pet)
    if pet:queryBasicInt("eclosion_stage") == 1 then
        return CHS[4200498]
    elseif pet:queryBasicInt("eclosion_stage") == 2 then
        return CHS[4200499] -- 高阶
    else
        return CHS[4200497]
    end
end

-- 获取宠物对应等级的最大经验
function PetMgr:getPetMaxExpForLevel(level)
    if DistMgr:curIsTestDist() then
        -- 内测
        return PetAttribListTest[level].exp
    else
        return PetAttribList[level].exp
    end
end

-- 获取宠物换色个数，只有价格大于0的才算
function PetMgr:getChangeColorIcons(orgIcon)
    local ret = {}
    for curIcon, info in pairs(IconColorScheme) do
        if orgIcon == info.org_icon and info.coin > 0 then
            table.insert(ret,  {icon = curIcon, coin = info.coin})
        end
    end

        table.sort(ret, function(l, r)
            if l.icon < r.icon then return true end
            if l.icon > r.icon then return false end
        end)

    return ret
end

MessageMgr:regist("MSG_UPDATE_PETS", PetMgr)
MessageMgr:regist("MSG_SET_VISIBLE_PET", PetMgr)
MessageMgr:regist("MSG_SET_CURRENT_PET", PetMgr)
MessageMgr:regist("MSG_SET_OWNER", PetMgr)
MessageMgr:regist("MSG_SET_CURRENT_MOUNT", PetMgr)
MessageMgr:regist("MSG_PET_CARD", PetMgr)
MessageMgr:regist("MSG_PREVIEW_SPECIAL_SKILL", PetMgr)
MessageMgr:regist("MSG_REFINE_PET_RESULT", PetMgr)
MessageMgr:regist("MSG_QUERY_MOUNT_MERGE_RATE", PetMgr)
MessageMgr:regist("MSG_PREVIEW_MOUNT_ATTRIB", PetMgr)
MessageMgr:regist("MSG_SUMMON_MOUNT_RESULT", PetMgr)
MessageMgr:regist("MSG_SUMMON_MOUNT_NOTIFY", PetMgr)
MessageMgr:regist("MSG_HOUSE_FEEDING_LIST", PetMgr)
MessageMgr:regist("MSG_UPGRADE_TASK_PET", PetMgr)
