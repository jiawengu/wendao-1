-- PetExploreTeamMgr.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队管理器

PetExploreTeamMgr = Singleton()

-- 技能升级
local SKILL_UP_EXP_LIST = require(ResMgr:getCfgPath("PetExploreSkillExpList.lua"))

-- 探索技能ID
local EXPLORE_SKILL_ID = {
    CAIJI    = 1,  -- 采集
    ZHANDOU  = 2,  -- 战斗
    SOUSUO   = 3,  -- 搜索
    CUIDIAO  = 4,  -- 垂钓
    WAJUE    = 5,  -- 挖掘
}

-- 探索技能配置
local EXPLORE_SKILL_CFG = {
    [EXPLORE_SKILL_ID.CAIJI]    = {name = CHS[7190515], descrip = CHS[7190510], iconPath = ResMgr.ui.pet_explore_skill_caiji,
        materialName = CHS[7190523], addExp = 120, materailDes = CHS[7190593], materailPath = ResMgr.ui.pet_explore_materail_caiji},  -- 采集
    [EXPLORE_SKILL_ID.ZHANDOU]  = {name = CHS[7190516], descrip = CHS[7190511], iconPath = ResMgr.ui.pet_explore_skill_zhandou,
        materialName = CHS[7190524], addExp = 120, materailDes = CHS[7190594], materailPath = ResMgr.ui.pet_explore_materail_zhandou},  -- 战斗
    [EXPLORE_SKILL_ID.SOUSUO]   = {name = CHS[7190517], descrip = CHS[7190512], iconPath = ResMgr.ui.pet_explore_skill_sousuo,
        materialName = CHS[7190525], addExp = 120, materailDes = CHS[7190595], materailPath = ResMgr.ui.pet_explore_materail_sousuo},  -- 搜索
    [EXPLORE_SKILL_ID.CUIDIAO]  = {name = CHS[7190518], descrip = CHS[7190513], iconPath = ResMgr.ui.pet_explore_skill_chuidiao,
        materialName = CHS[7190526], addExp = 120, materailDes = CHS[7190596], materailPath = ResMgr.ui.pet_explore_materail_chuidiao},  -- 垂钓
    [EXPLORE_SKILL_ID.WAJUE]    = {name = CHS[7190519], descrip = CHS[7190514], iconPath = ResMgr.ui.pet_explore_skill_wajue,
        materialName = CHS[7190527], addExp = 120, materailDes = CHS[7190597], materailPath = ResMgr.ui.pet_explore_materail_wajue},  -- 挖掘
}

-- 探索状态
local EXPLORE_STATUS = {
    NOT_START = 0,  -- 未探索
    IN_EXPLORE = 1, -- 探索中
    OVER = 2,       -- 已探索
}

-- 操作探索状态
local EXPLORE_STATUS_OPER = {
    REFRESH = 1,   -- 刷新
    STOP = 2,      -- 中断
    REWARD = 3,    -- 领奖
}

-- 难度中文
local DEGREE_CHS = {
    CHS[7190537], -- 简单
    CHS[7190538], -- 普通
    CHS[7190539], -- 困难
}

-- 小成功条件描述
local SUCCESS_RULE_DES = {
    CHS[7190554], -- 小队等级
    CHS[7190555], -- 小队力量点数
    CHS[7190556], -- 小队体力点数
    CHS[7190557], -- 小队灵力点数
    CHS[7190558], -- 小队敏捷点数
    CHS[7190560], -- 宠物最高亲密
    CHS[7190559], -- 小队总武学倍数
    CHS[7190561], -- 小队总寿命
    CHS[7190562], -- 小队顿悟技能数
    CHS[7190563], -- 宠物天生技能数
    CHS[7190564], -- 小队天书数量
    CHS[7190565], -- 金相性宠物
    CHS[7190566], -- 木相性宠物
    CHS[7190567], -- 水相性宠物
    CHS[7190568], -- 火相性宠物
    CHS[7190569], -- 土相性宠物
    CHS[7190570], -- 无相性宠物
    CHS[7190571], -- 完成宠物羽化阶段
    CHS[7190572], -- 宠物幻化次数
}

-- 大成功条件描述
local BIG_SUCCESS_RULE_DES = {
    CHS[7190573],  -- 宠物采集等级
    CHS[7190574],  -- 宠物战斗等级
    CHS[7190575],  -- 宠物搜索等级
    CHS[7190576],  -- 宠物垂钓等级
    CHS[7190577],  -- 宠物挖掘等级
    CHS[7190578],  -- 小队总采集等级
    CHS[7190579],  -- 小队总战斗等级
    CHS[7190580],  -- 小队总搜索等级
    CHS[7190581],  -- 小队总垂钓等级
    CHS[7190582],  -- 小队总挖掘等级
}

-- 地图数据
PetExploreTeamMgr.mapInfo = {}

-- 获取技能升级经验上限
function PetExploreTeamMgr:getSkillMaxNeedExp(skillLevel, skillExp)
    if not self.skillMaxExp then
        self.skillMaxExp = 0
        for k, v in ipairs(SKILL_UP_EXP_LIST) do
            self.skillMaxExp = self.skillMaxExp + v.exp
        end
    end

    local curExp = skillExp
    for i = 1, skillLevel - 1 do
        curExp = curExp + SKILL_UP_EXP_LIST[i].exp
    end

    return self.skillMaxExp - curExp
end

-- 模拟技能增加经验后，新等级与新经验
function PetExploreTeamMgr:getSimulateSkillLevelAndExp(oldLevel, oldExp, addExp)
    -- 计算当前总经验
    local allExp = oldExp + addExp
    for i = 1, oldLevel - 1 do
        allExp = allExp + SKILL_UP_EXP_LIST[i].exp
    end

    -- 计算新等级，新经验
    local levelExp = 0
    for i = 1, #SKILL_UP_EXP_LIST do
        levelExp = levelExp + SKILL_UP_EXP_LIST[i].exp
        if allExp < levelExp then
            return i, allExp - levelExp + SKILL_UP_EXP_LIST[i].exp
        end
    end

    -- 经验值上限
    return 50, 0
end

-- 获取当前升级需要的经验
function PetExploreTeamMgr:getUpSkillExp(level, exp)
    if SKILL_UP_EXP_LIST[level] then
        return SKILL_UP_EXP_LIST[level].exp - exp
    else
        return 0
    end
end

-- 获取材料图标配置
function PetExploreTeamMgr:getMaterialIconByName(name)
    for k, v in pairs(EXPLORE_SKILL_CFG) do
        if v.materialName == name then
            return v.materailPath
        end
    end
end

-- 获取探索操作状态配置
function PetExploreTeamMgr:getExploreDegreeCfg()
    return DEGREE_CHS
end

-- 获取探索操作状态配置
function PetExploreTeamMgr:getExploreOperCfg()
    return EXPLORE_STATUS_OPER
end

-- 获取探索状态配置
function PetExploreTeamMgr:getExploreStatusCfg()
    return EXPLORE_STATUS
end

-- 获取探索技能配置
function PetExploreTeamMgr:getExploreSkillCfg()
    return EXPLORE_SKILL_CFG
end

-- 获取成功条件描述
function PetExploreTeamMgr:getSuccessRuleDes(id)
    return SUCCESS_RULE_DES[id] or ""
end

-- 获取大成功条件描述
function PetExploreTeamMgr:getBigSuccessRuleDes(id)
    return BIG_SUCCESS_RULE_DES[id] or ""
end

-- 计算材料获取经验
function PetExploreTeamMgr:getAddExp(skillId, num)
    if EXPLORE_SKILL_CFG[skillId] then
        return EXPLORE_SKILL_CFG[skillId].addExp * num
    end

    return 0
end

-- 计算满级需要材料数量
function PetExploreTeamMgr:getFullExpForMaterialCount(skillId, exp)
    if EXPLORE_SKILL_CFG[skillId] then
        return math.ceil(exp / EXPLORE_SKILL_CFG[skillId].addExp)
    end

    return 0
end

-- 技能是否满级
function PetExploreTeamMgr:isSkillFullLevel(level)
    return level >= 50
end

-- 获取材料拥有数量
function PetExploreTeamMgr:getMaterailNum(skillId)
    return self.materialInfo[skillId] or 0
end

-- 是否可以参与探索
function PetExploreTeamMgr:isPetCanExplore(pet)
    if not pet then return end

    -- 小于75级
    if pet:getLevel() < 75 then return end

    -- 限时宠物
    if PetMgr:isTimeLimitedPet(pet) then return end

    if PetMgr:isDianhuaOK(pet) or pet:queryInt("mount_type") == MOUNT_TYPE.MOUNT_TYPE_YULING then
        -- 点化完成的宠物, 或御灵
        return true
    end
end

-- 获取可探索的宠物列表
function PetExploreTeamMgr:getPetsToExplore(expects)
    local pets = PetMgr.pets
    local normalList = {}
    local inExplorePetList = {}
    for k, v in pairs(pets) do
        if self:isPetCanExplore(v) then
            -- 可以探索的宠物加入列表
            if self:isPetInExplore(v:getId()) then
                -- 探索中的宠物
                table.insert(inExplorePetList, v)
            elseif not expects or not expects[v:getId()] then
                table.insert(normalList, v)
            end
        end
    end

    -- 宠物按通用规则排序
    table.sort(normalList, function(l,r) return PetMgr:comparePet(l, r) end)

    local ret = {}

    -- 先添加可用于探索的宠物
    for i = 1, #normalList do table.insert(ret, normalList[i]) end

    -- 再添加探索中的宠物
    for i = 1, #inExplorePetList do table.insert(ret, inExplorePetList[i]) end

    return ret
end

-- 获取宠物探险小队数据
function PetExploreTeamMgr:getPetTeamInfo(petId)
    local pet = PetMgr:getPetById(petId)
    if not pet then return {} end

    local info = {}
    info.key_name = pet:queryBasic("raw_name")
    info.name = pet:getName()
    info.level = pet:getLevel()
    info.martial = pet:queryBasicInt("martial")
    info.longevity = pet:queryBasicInt("longevity")
    info.intimacy = pet:queryBasicInt("origin_intimacy")
    info.skill_list = self:getPetSkillInfo(petId)
    info.skill_count = #info.skill_list
    info.pet_iid = pet:queryBasic("iid_str")

    return info
end

-- 根据宠物id获取iid
function PetExploreTeamMgr:getPetIIdById(petId)
    local pet = PetMgr:getPetById(petId)
    if not pet then return end

    return pet:queryBasic("iid_str")
end

-- 根据宠物iid获取id
function PetExploreTeamMgr:getPetIdByIId(iid)
    local pet = PetMgr:getPetByIId(iid)
    if not pet then return end

    return pet:getId("id")
end

-- 宠物是否在探索中
function PetExploreTeamMgr:isPetInExplore(petId)
    if self.allPetData then
        for i = 1, self.allPetData.count do
            if self.allPetData.list[i].pet_id == petId and self.allPetData.list[i].in_explore then
                return true
            end
        end
    end

    return false
end

-- 地图是否在未探索状态
function PetExploreTeamMgr:isMapInNotExplore(mapIndex)
    if self.mapInfo and self.mapInfo[mapIndex] and self.mapInfo[mapIndex].status == EXPLORE_STATUS.NOT_START then
        return true
    end
end

-- 获取宠物信息
function PetExploreTeamMgr:getPetInfo(petId)
    if self.allPetData then
        for i = 1, self.allPetData.count do
            if self.allPetData.list[i].pet_id == petId then
                return self.allPetData.list[i]
            end
        end
    end
end

-- 获取宠物技能信息
function PetExploreTeamMgr:getPetSkillInfo(petId)
    if self.allPetData then
        for i = 1, self.allPetData.count do
            if self.allPetData.list[i].pet_id == petId then
                return self.allPetData.list[i].skill_list
            end
        end
    end
end

-- 获取单张地图数据
function PetExploreTeamMgr:getMapInfo(mapIndex)
    if self.mapInfo and self.mapInfo[mapIndex] then
        return self.mapInfo[mapIndex]
    end
end

-- 获取基础数据
function PetExploreTeamMgr:getBasicData()
    return self.mapBasicData
end

-- 获取所有宠物数据
function PetExploreTeamMgr:getAllPetData()
    return self.allPetData
end

-- 获取地图数据
function PetExploreTeamMgr:getAllMapData()
    return self.mapInfo
end

function PetExploreTeamMgr:clearData()
    self.mapInfo = {}
    self.materialInfo = {}
    self.allPetData = nil
    self.mapBasicData = nil
end

-- 请求地图宠物数据
function PetExploreTeamMgr:requestMapPetData(cookie, mapIndex)
    gf:CmdToServer("CMD_PET_EXPLORE_MAP_PET_DATA", {cookie = cookie, map_index = mapIndex})
end

-- 请求操作探索状态
function PetExploreTeamMgr:requestExploreOper(cookie, type, mapIndex)
    gf:CmdToServer("CMD_PET_EXPLORE_OPER", {cookie = cookie, type = type, map_index = mapIndex})
end

-- 请求学习技能
function PetExploreTeamMgr:requestLearnSkill(petId, skillId)
    gf:CmdToServer("CMD_PET_EXPLORE_LEARN_SKILL", {pet_id = petId, skill_id = skillId})
end

-- 请求更换技能
function PetExploreTeamMgr:requestChangeSkill(petId, oldSkillId, newSkillId)
    gf:CmdToServer("CMD_PET_EXPLORE_REPLACE_SKILL", {pet_id = petId, old_skill_id = oldSkillId, new_skill_id = newSkillId})
end

-- 请求使用道具
function PetExploreTeamMgr:requestUseItem(petId, itemId, count)
    gf:CmdToServer("CMD_PET_EXPLORE_USE_ITEM", {pet_id = petId, item_id = itemId, count = count})
end

-- 请求宠物上阵
function PetExploreTeamMgr:requestPetInTeamData(cookie, mapIndex, petId1, petId2, petId3)
    gf:CmdToServer("CMD_PET_EXPLORE_MAP_CONDITION_DATA", {cookie = cookie, map_index = mapIndex,
        pet_id1 = petId1 or 0, pet_id2 = petId2 or 0, pet_id3 = petId3 or 0})
end

-- 请求开始探索
function PetExploreTeamMgr:requestStartExplore(cookie, mapIndex, petId1, petId2, petId3)
    gf:CmdToServer("CMD_PET_EXPLORE_START", {cookie = cookie, map_index = mapIndex,
        pet_id1 = petId1 or 0, pet_id2 = petId2 or 0, pet_id3 = petId3 or 0})
end

-- 打开界面
function PetExploreTeamMgr:MSG_PET_EXPLORE_OPEN_DLG()
    local dlgName = DlgMgr:getLastDlgByTabDlg('PetExploreTabDlg') or 'PetExploreDlg'
    DlgMgr:openDlg(dlgName)
end

-- 所有宠物数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_ALL_PET_DATA(data)
    -- 将探索的宠物与非探索的宠物分开
    local explorePets = {}
    local otherPets = {}
    local canNotExplorePet = {}
    for i = 1, data.count do
        local pet = PetMgr:getPetById(data.list[i].pet_id)
        if pet then
            data.list[i].pet = pet
            if not self:isPetCanExplore(pet) then
                table.insert(canNotExplorePet, data.list[i])
            else
                if data.list[i].in_explore then
                    table.insert(explorePets, data.list[i])
                else
                    table.insert(otherPets, data.list[i])
                end
            end
        end
    end

    -- 宠物按通用规则排序
    table.sort(explorePets, function(l,r) return PetMgr:comparePet(l.pet, r.pet) end)
    table.sort(otherPets, function(l,r) return PetMgr:comparePet(l.pet, r.pet) end)
    table.sort(canNotExplorePet, function(l,r) return PetMgr:comparePet(l.pet, r.pet) end)

    -- 合并数据，探索的宠物排在前面
    local allPets = {}
    for i = 1, #explorePets do
        table.insert(allPets, explorePets[i])
    end

    for i = 1, #otherPets do
        table.insert(allPets, otherPets[i])
    end

    for i = 1, #canNotExplorePet do
        table.insert(allPets, canNotExplorePet[i])
    end

    data.list = allPets

    DlgMgr:sendMsg("PetExploreSkillDlg", "setData", data)

    self.allPetData = data
end

-- 单只宠物数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_ONE_PET_DATA(data)
    if not self.allPetData then return end

    for i = 1, self.allPetData.count do
        if self.allPetData.list[i].pet_id == data.pet_id then
            self.allPetData.list[i] = data
            self.allPetData.list[i].pet = PetMgr:getPetById(data.pet_id)
        end
    end
end

-- 所有探险技能升级道具
function PetExploreTeamMgr:MSG_PET_EXPLORE_ALL_ITEM_DATA(data)
    self.materialInfo = {}
    for i = 1, data.count do
        self.materialInfo[data.list[i].item_id] = data.list[i].num
    end

    DlgMgr:sendMsg("PetExploreSkillDlg", "refreshOwnNum")
    DlgMgr:sendMsg("PetExploreSkillDlg", "setMaterialInfo")
end

-- 宠物探索小队 - 地图基础数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_MAP_BASIC_DATA(data)
    self.mapBasicData = data
    DlgMgr:sendMsg("PetExploreDlg", "refreshBasicData", data)
end

-- 单张地图数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_ONE_MAP_DATA(data)
    self.mapInfo[data.map_index] = data

    DlgMgr:sendMsg("PetExploreDlg", "refreshMapData", data)
end

-- 地图宠物数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_MAP_PET_DATA(data)
    local dlg = DlgMgr:getDlgByName("PetExploreTeamDlg")
    if not dlg then dlg = DlgMgr:openDlg("PetExploreTeamDlg") end
    dlg:refreshRightPanel(data)
end

-- 地图条件数据
function PetExploreTeamMgr:MSG_PET_EXPLORE_MAP_CONDITION_DATA(data)
    DlgMgr:sendMsg("PetExploreTeamDlg", "refreshLeftPanel", data)
end

-- 奖励信息
function PetExploreTeamMgr:MSG_PET_EXPLORE_BONUS(data)
    local dlg = DlgMgr:getDlgByName("PetExploreRewardDlg")
    if not dlg then dlg = DlgMgr:openDlg("PetExploreRewardDlg") end
    dlg:setData(data)
end

-- 开始探索，用于客户端播放开始动画
function PetExploreTeamMgr:MSG_PET_EXPLORE_START(data)
    DlgMgr:sendMsg("PetExploreTeamDlg", "doAnimate")
end

-- 过图，关闭探险小队相关界面
function PetExploreTeamMgr:MSG_ENTER_ROOM()
    DlgMgr:closeDlg("PetExploreChoseDlg")
    DlgMgr:closeDlg("PetExploreDlg")
    DlgMgr:closeDlg("PetExploreRewardDlg")
    DlgMgr:closeDlg("PetExploreSkillDlg")
    DlgMgr:closeDlg("PetExploreSkillLearnDlg")
    DlgMgr:closeDlg("PetExploreTabDlg")
    DlgMgr:closeDlg("PetExploreTeamDlg")
end

function PetExploreTeamMgr:MSG_SWITCH_SERVER()
    self:MSG_ENTER_ROOM()
end

function PetExploreTeamMgr:MSG_SWITCH_SERVER_EX()
    self:MSG_ENTER_ROOM()
end

function PetExploreTeamMgr:MSG_SPECIAL_SWITCH_SERVER()
    self:MSG_ENTER_ROOM()
end

function PetExploreTeamMgr:MSG_SPECIAL_SWITCH_SERVER_EX()
    self:MSG_ENTER_ROOM()
end

MessageMgr:hook("MSG_ENTER_ROOM", PetExploreTeamMgr, "PetExploreTeamMgr")
MessageMgr:hook("MSG_SWITCH_SERVER", PetExploreTeamMgr, "PetExploreTeamMgr")
MessageMgr:hook("MSG_SWITCH_SERVER_EX", PetExploreTeamMgr, "PetExploreTeamMgr")
MessageMgr:hook("MSG_SPECIAL_SWITCH_SERVER", PetExploreTeamMgr, "PetExploreTeamMgr")
MessageMgr:hook("MSG_SPECIAL_SWITCH_SERVER_EX", PetExploreTeamMgr, "PetExploreTeamMgr")
MessageMgr:regist("MSG_PET_EXPLORE_OPEN_DLG", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_ALL_PET_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_ONE_PET_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_ALL_ITEM_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_MAP_BASIC_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_ONE_MAP_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_MAP_PET_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_MAP_CONDITION_DATA", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_START", PetExploreTeamMgr)
MessageMgr:regist("MSG_PET_EXPLORE_BONUS", PetExploreTeamMgr)
