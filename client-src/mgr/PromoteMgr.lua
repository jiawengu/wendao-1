-- PromoteMgr.lua
-- Created by songcw Mar/4/2015
-- 提升管理器

PromoteMgr = Singleton()

local TAG_ATTRIB = PROMOTE_TYPE.TAG_ATTRIB
local TAG_POLAR = PROMOTE_TYPE.TAG_POLAR
local TAG_SKILL = PROMOTE_TYPE.TAG_SKILL
local TAG_GET_GUARD = PROMOTE_TYPE.TAG_GET_GUARD       --　可获得守护
local TAG_GUARD_EXP = PROMOTE_TYPE.TAG_GUARD_EXP      --　守护历练
local TAG_EQUIP  = PROMOTE_TYPE.TAG_EQUIP
local TAG_PET_ADD_POINT = PROMOTE_TYPE.TAG_PET_ADD_POINT
local TAG_PET_RESIST_POINT = PROMOTE_TYPE.TAG_PET_RESIST_POINT
local TAG_PET_FENGLING = PROMOTE_TYPE.TAG_PET_FENGLING
local TAG_PET_FLY = PROMOTE_TYPE.TAG_PET_FLY
local TAG_INNER_ALCHEMY = PROMOTE_TYPE.TAG_INNER_ALCHEMY
local TAG_KID_FLY = PROMOTE_TYPE.TAG_KID_FLY

-- 在跨服中不显示的类型
local NOT_SHOW_IN_CROSS_SERVER = {
    [TAG_INNER_ALCHEMY] = true, -- 内丹
    [TAG_SKILL] = true,         -- 技能升级
    [TAG_GET_GUARD] = true,     -- 获得守护
    [TAG_GUARD_EXP] = true,     -- 守护历练
    [TAG_PET_FLY] = true,       -- 宠物飞升
    [TAG_KID_FLY] = true,       -- 娃娃飞升
}

-- 进入跨服需要移除所有提升提示
local REMOVE_ALL_PROMOTE_SERVER = {
    [Const.QMPK_SERVER_TYPE] = true, -- 全民PK
    [Const.QCLD_COMPETE]     = true, -- 青城论道
}

local promoteInfo = {
    [TAG_ATTRIB] = {trigger = 0, content = CHS[3004264], tag = TAG_ATTRIB, openDlg = "UserAddPointDlg"},
    [TAG_POLAR] = {trigger = 0, content = CHS[3004265], tag = TAG_POLAR, openDlg = "PolarAddPointDlg"},
    [TAG_SKILL] = {trigger = 0, content = CHS[3004266], tag = TAG_SKILL, openDlg = "SkillDlg"},
    [TAG_GET_GUARD] = {trigger = 0, content = CHS[3004267], tag = TAG_GET_GUARD, openDlg = "GuardAttribDlg"},
    [TAG_GUARD_EXP] = {trigger = 0, content = CHS[3004268], tag = TAG_GUARD_EXP, openDlg = "GuardAttribDlg"},
    [TAG_EQUIP] = {trigger = 0, content = CHS[3004269], tag = TAG_EQUIP, openDlg = "BagDlg"},
    [TAG_PET_ADD_POINT] = {trigger = 0, content = CHS[3004270], tag = TAG_PET_ADD_POINT, openDlg = "PetGetAttribDlg"},
    [TAG_PET_RESIST_POINT] = {trigger = 0, content = CHS[4300059], tag = TAG_PET_RESIST_POINT},
    [TAG_PET_FENGLING] = {trigger = 0, content = CHS[6000553], tag = TAG_PET_FENGLING, openDlg = "PetHorseDlg"},
    [TAG_PET_FLY] = {trigger = 0, content = CHS[7002281], tag = TAG_PET_FLY},
    [PROMOTE_TYPE.TAG_XIANMO_POINT] = {trigger = 0, content = CHS[4100883], tag = PROMOTE_TYPE.TAG_XIANMO_POINT},
    [TAG_INNER_ALCHEMY] = {trigger = 0, content = CHS[7100150], tag = TAG_INNER_ALCHEMY},
    [TAG_KID_FLY] = {trigger = 0, content = CHS[7120201], tag = TAG_KID_FLY},
}

PromoteMgr.recordPte = {}

-- 抗性点，40<=level<70只出现一次提升，需记录是否显示过
PromoteMgr.resistPet = {}
-- 点击抗性提升按钮，响应的宠物
PromoteMgr.resistOperPet = nil

-- 检查可提升数据并决定是否显示“提升按钮”
function PromoteMgr:checkPromote(tag, data, meLevel, notRemove)
    -- 如果在换线登入过程中,不检测提升
    if DistMgr:getIsSwichServer() then
        return
    end

    if REMOVE_ALL_PROMOTE_SERVER[DistMgr:getCurServerType()] or (NOT_SHOW_IN_CROSS_SERVER[tag] and GameMgr:IsCrossDist()) then
        -- 跨服线路不显示的提升提示，直接移除
        self:removeByTag(tag)
        return
    end

    local isUpdate = false
    if tag == TAG_ATTRIB then
        local attrib_point = Me:queryInt("attrib_point")                     -- 获取剩余属性点数
        if attrib_point > 0 then isUpdate = true end
    elseif tag == TAG_POLAR then
        local polar_point = Me:queryInt("polar_point")                       -- 获取剩余相性点数
        if polar_point > 0 then isUpdate = true end
    elseif tag == TAG_SKILL then
        if not meLevel then meLevel = Me:getLevel() end
        if (meLevel >= 20 and meLevel % 5 == 0)
           or meLevel >= 70  then
            local promotable_skillLevel_sum = SkillMgr:getMePromotableSkillSum() -- 获取可提升技能等级数
            if promotable_skillLevel_sum > 0 then isUpdate = true end
        end
    elseif tag == TAG_GET_GUARD then
        if GuideMgr:isIconExist(5) then
            if not meLevel then meLevel = Me:getLevel() end
            GuardMgr:notifyShowFastUserGuard(meLevel)
            local guardCfg = GuardMgr:getGuardCfg()
            for i = 1, #guardCfg do
                if guardCfg[i][1] == meLevel then
                    isUpdate = true

                    -- 主界面守护增加小红点
                    RedDotMgr:insertOneRedDot("GameFunctionDlg", "GuardButton")
                end
            end
        end
    elseif tag == TAG_GUARD_EXP then
        local guardCanBeExp = GuardMgr:getGuardCanBeExp()
        if guardCanBeExp and not TaskMgr:isExistTaskByName(CHS[3004268]) then isUpdate = true end
    elseif tag == TAG_EQUIP then
        data = InventoryMgr:getBagAllEquip()
        meLevel = meLevel or Me:queryBasicInt("level")
        local count = data.count
        for i = 1,count do
            if data[i].pos > 10 then
                -- InventoryMgr:getBagAllEquip()获取的不是整个装备～～
                local equip = InventoryMgr:getItemByPos(data[i].pos)
                if equip and EquipmentMgr:isCanWearEquip(equip, meLevel) and meLevel <= 40 then
                    local wearPos = equip.equip_type or 0
                    local wearEquip = InventoryMgr:getItemByPos(wearPos)
                    if not wearEquip or wearEquip.req_level < equip.req_level then
                        isUpdate = true
                    end
                end
            end
        end
    elseif tag == TAG_PET_ADD_POINT then
        if self:getAddPointPetId(data) then
            isUpdate = true
        end
    elseif tag == TAG_PET_RESIST_POINT then
        if self:checkPetResistLogic(data.id) then
            PromoteMgr.resistOperPet = PetMgr:getPetById(data.id)
            isUpdate = true
        end
    elseif tag == TAG_PET_FENGLING then
        if self:checkFenglingwan() then
            isUpdate = true
        end
    elseif tag == TAG_PET_FLY then
        if self:checkPetFly() then
            isUpdate = true
        end
    elseif tag == PROMOTE_TYPE.TAG_XIANMO_POINT then
        if Me:queryInt("upgrade/total") > 0 then
            isUpdate = true
        end
    elseif tag == TAG_INNER_ALCHEMY then
        local curDanExp = Me:queryInt("dan_data/exp")
        local maxDanExp = Me:queryInt("dan_data/exp_to_next_level")

        if maxDanExp > 0 and curDanExp > 0 and curDanExp >= maxDanExp and
            InnerAlchemyMgr:getBreakTaskType() == INNER_ALCHEMY_BREAK_STATUS.NOT_IN_BREAK and
            not ( Me:queryBasicInt("dan_data/state") == INNER_ALCHEMY_STATE.FIVE and
                Me:queryBasicInt("dan_data/stage") == INNER_ALCHEMY_STAGE.FIVE ) then
            -- 精气值满足条件，内丹任务为未领取状态，且为非最后阶段
            isUpdate = true
        end
    elseif tag == TAG_KID_FLY then
        if self:checkKidFly() then
            isUpdate = true
        end
    end

    if isUpdate then
        if promoteInfo[tag] then promoteInfo[tag].trigger = 1 end
        DlgMgr:sendMsg("SystemFunctionDlg", "setPromoteButtonVisible", true)
        DlgMgr:sendMsg("PromoteDlg", "setPromoteList")

        if not DistMgr:getIsSwichServer() then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "PromoteButton")
        end
    else
        local canRemove = true
        if notRemove then
            canRemove = false
        elseif tag == TAG_SKILL then
            -- 技能升级只有玩家点击才能被移除
            canRemove = false
        elseif tag == TAG_GET_GUARD then
            -- 获得守护只有60级以下金钱可召唤守护都召唤完毕后才可被移除
            if GuardMgr:isHaveCanGetGuard(1, 60) then
               canRemove = false
            end
        end

        if canRemove then
            PromoteMgr:removeByTag(tag)
        end
    end
end

-- 检查宠物抗性逻辑
function PromoteMgr:checkPetResistLogic(petId)
    local pet = PetMgr:getPetById(petId)
    if not pet then return end
    if pet:queryBasicInt("resist_point") > 0 then
        return true
    end
    return false
end

-- 获取有未分配抗性的宠物，只有参战和掠阵，只用于换线后重新获取宠物
function PromoteMgr:getResistPet()
    local pet = PetMgr:getFightPet()
    if pet then
        if pet:queryBasicInt("resist_point") > 0 and pet:queryBasicInt("level") >= 70 then return pet end
    end

    pet = PetMgr:getRobPet()
    if pet then
        if pet:queryBasicInt("resist_point") > 0 and pet:queryBasicInt("level") >= 70 then return pet end
    end

    return nil
end

-- 获取全部列表
function PromoteMgr:setRecordPet(name)
    self.recordPte = {isRecord = true, name = name}
    self.scheduleId = gf:Schedule(function() PromoteMgr:stopSchedule() end, 3)
end

-- 停止定时器
function PromoteMgr:stopSchedule()
    if nil ~= PromoteMgr.scheduleId then
        gf:Unschedule(PromoteMgr.scheduleId)
        PromoteMgr.scheduleId = nil
        self.recordPte = {}
    end
end

function PromoteMgr:clickPromote(tag)
    if promoteInfo[tag].openDlg then
        DlgMgr:openDlg(promoteInfo[tag].openDlg)
    end

    if tag == TAG_SKILL then
        self:removeByTag(tag)
    elseif tag == TAG_ATTRIB then
        self:removeByTag(tag)
    elseif tag == TAG_POLAR then
        self:removeByTag(tag)
    elseif tag == TAG_EQUIP then
        local data = InventoryMgr:getBagAllEquip()
        local meLevel = Me:queryBasicInt("level")
        local count = data.count
        local equipName = nil
        for i = 1,count do
            if data[i].pos > 10 then
                -- InventoryMgr:getBagAllEquip()获取的不是整个装备～～
                local equip = InventoryMgr:getItemByPos(data[i].pos)
                if equip and EquipmentMgr:isCanWearEquip(equip, meLevel) and meLevel <= 40 then
                    local wearPos = equip.equip_type or 0
                    local wearEquip = InventoryMgr:getItemByPos(wearPos)
                    if not wearEquip or wearEquip.req_level < equip.req_level then
                        if not equipName then equipName = equip.name end
                    end
                end
            end
        end
        if not equipName then return end
        local para = {[1] = equipName}
        DlgMgr:sendMsg("BagDlg", "onDlgOpened", para)
        self:removeByTag(tag)
    elseif tag == TAG_GET_GUARD then
        DlgMgr:sendMsg("GuardListChildDlg", "scrollToCall")
        self:removeByTag(tag)
    elseif tag == TAG_GUARD_EXP then
        DlgMgr:sendMsg("GuardListChildDlg", "scrollToAnvenced")
        self:removeByTag(tag)
    elseif tag == TAG_PET_ADD_POINT then
        local petId = self:getAddPointPetId()

        if petId then
            DlgMgr:sendMsg("PetListChildDlg", "onDlgOpened", petId)
        end
        self:removeByTag(tag)
    elseif tag == TAG_PET_FENGLING then
        self:removeByTag(tag)
    elseif tag == TAG_PET_RESIST_POINT then
        if PromoteMgr.resistOperPet then
            local dlg = DlgMgr:openDlg("PetGetResisDlg")
            dlg:resetInfo(PromoteMgr.resistOperPet)
            PromoteMgr.resistPet[PromoteMgr.resistOperPet:getId()] = 1
            PromoteMgr.resistOperPet = nil
        end
        self:removeByTag(tag)
    elseif tag == TAG_PET_FLY then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002291]))
        self:removeByTag(tag)
    elseif tag == PROMOTE_TYPE.TAG_XIANMO_POINT then
        DlgMgr:openDlg("XianMoAddPointDlg")
        self:removeByTag(tag)
    elseif tag == PROMOTE_TYPE.TAG_INNER_ALCHEMY then
        DlgMgr:openDlg("InnerAlchemyDlg")
        self:removeByTag(tag)
    elseif tag == TAG_KID_FLY then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7120202]))
        self:removeByTag(tag)
    end
end

-- data.id == nil时，检测参战、掠阵宠物加点
-- data.id 非空时，只检测对应宠物加点(必须为参战或掠阵状态)
function PromoteMgr:getAddPointPetId(data)
    if data and data.id then
        -- 指定宠物id,则只检测对应宠物
        local petId = nil
        local pet = PetMgr:getPetById(data.id)
        if pet and (pet:queryBasicInt('pet_status') == 1 or pet:queryBasicInt('pet_status') == 2) and
            pet:queryInt("attrib_point") > 0  then
            petId = data.id
        end

        return petId
    else
        local petId = nil
        local fightPet = PetMgr:getFightPet()
        local robPet = PetMgr:getRobPet()

        if fightPet and fightPet:queryInt("attrib_point") > 0  then
            petId = fightPet:getId()
        elseif robPet and robPet:queryInt("attrib_point") > 0 then
            petId = robPet:getId()
        end

        return petId
    end
end

function PromoteMgr:removeByTag(tag)
    if promoteInfo[tag] then promoteInfo[tag].trigger = 0 end
    DlgMgr:sendMsg("PromoteDlg", "removeByTag", tag)

    if not PromoteMgr:promoteBtnDisplay() then
        DlgMgr:sendMsg("SystemFunctionDlg", "setPromoteButtonVisible", false)
    end

end

-- 获取全部列表
function PromoteMgr:getPromoteList()
    return promoteInfo
end

-- 提升按钮是否能显示
function PromoteMgr:promoteBtnDisplay()
    for i = 1, #promoteInfo  do
        if promoteInfo[i].trigger == 1 then
            return true
        end
    end

    return false
end

-- 设置触发器  flag == 1 开启　　　0关闭
function PromoteMgr:setPromoteTriggerByTag(tag, flag)
    promoteInfo[tag].trigger = flag
end

-- 获取已触发的列表
function PromoteMgr:getDisplayList()
    local listInfos = {}
    for i = 1, #promoteInfo  do
        if promoteInfo[i].trigger == 1 then
            table.insert(listInfos, promoteInfo[i])
        end
    end

    return listInfos
end

--
function PromoteMgr:MSG_LEVEL_UP(data)
    if data.id ~=  Me:getId() then return end
    self:checkPromote(TAG_SKILL, nil, data.level)
    self:checkPromote(TAG_GET_GUARD, nil, data.level)
    self:checkPromote(TAG_GUARD_EXP)

    if data.level < 40 then
        self:checkPromote(TAG_EQUIP, nil, data.level)
    end
end

--
function PromoteMgr:MSG_GUARDS_REFRESH(data)
 --   self:checkPromote(TAG_GET_GUARD)
end

function PromoteMgr:MSG_TASK_PROMPT(data)
    if data[1].task_type == CHS[3004268] and data[1].task_prompt ~= "" then
        -- 守护历练完成时，会收到两次MSG_TASK_PROMPT和一次MSG_GUARDS_REFRESH，不同童子、长老MSG_GUARDS_REFRESH可能在
        -- 第2条MSG_TASK_PROMPT之前，也可能在该消息之后，如果MSG_GUARDS_REFRESH在两条MSG_TASK_PROMPT之后，此处刷新守护历练提示就不对(见WDSY-29385)
        -- 所以此处只处理task_prompt ~= ""，即领取守护历练任务的情况，任务移除在MSG_GUARD_EXPERIENCE_SUCC中处理
        self:checkPromote(TAG_GUARD_EXP)
    end

    for i = 1, data.count do
        if data[i].task_type == CHS[7002297] then
            -- 宠物飞升
            if TaskMgr:getTaskByName(CHS[7002297]) then
                self:removeByTag(TAG_PET_FLY)
            else
                self:checkPromote(TAG_PET_FLY)
            end
        elseif data[i].task_type == CHS[7120201] then
            -- 娃娃飞升
            if TaskMgr:getTaskByName(CHS[7120201]) then
                self:removeByTag(TAG_KID_FLY)
            else
                self:checkPromote(TAG_KID_FLY)
            end
        end
    end
end

-- 守护历练成功
function PromoteMgr:MSG_GUARD_EXPERIENCE_SUCC(data)
    self:checkPromote(TAG_GUARD_EXP)
end

function PromoteMgr:MSG_INVENTORY(data)
    if Me:queryBasicInt("level") > 40 then
        self:removeByTag(TAG_EQUIP)
        return
    end
    self:checkPromote(TAG_EQUIP, data)
end

-- 不在 MSG_GENERAL_NOTIFY 中处理，因为换线后也会受到该消息
function PromoteMgr:NOTIFY_SEND_INIT_DATA_DONE(data)
    -- 如果是登入完成，检查一下提升状态
    -- 装备替换检查
    if Me:queryBasicInt("level") <= 40 then
        self:checkPromote(TAG_EQUIP, data)
    else
        self:removeByTag(TAG_EQUIP)
    end

    -- 守护历练
    self:checkPromote(TAG_GUARD_EXP)

    if GameMgr.isFirstLoginToday then
        -- 风化时间
        self:checkPromote(TAG_PET_FENGLING)

        -- 宠物飞升
        self:checkPromote(TAG_PET_FLY, nil, nil, true)

        -- 娃娃飞升
        self:checkPromote(TAG_KID_FLY)
    end

    -- 如果换线,记录抗性的宠物id变了，如果 PromoteMgr.resistOperPet ~= nil，则手动再次赋值
    if PromoteMgr.resistOperPet then
        PromoteMgr.resistOperPet = PromoteMgr:getResistPet()
    end

    -- 数据加载完成后，由于有多只宠物重复触发抗性检测的情况，所以只取优先级高的一只
    local petData = {["id"] = 0}
    local pet = self:getResistPet()--PetMgr:getPetById(data.id)
    if pet then
        petData = {["id"] = pet:getId()}
    end

    self:checkPromote(TAG_PET_RESIST_POINT, petData)

    self:checkPromote(PROMOTE_TYPE.TAG_XIANMO_POINT)
end

function PromoteMgr:MSG_GENERAL_NOTIFY(data)
	-- 由GameMgr通知调用

    local notify = data.notify
    if NOTIFY.NOTIFY_SEND_INIT_DATA_DONE == notify then

    else
        if NOTIFY.NOTIFY_ASSIGN_XMD == notify then
            if Me:queryInt("upgrade/total") <= 0 then
                self:removeByTag(PROMOTE_TYPE.TAG_XIANMO_POINT)
            end
        end
    end

end

-- 参战和掠阵宠物的状态变化
function PromoteMgr:MSG_SET_CURRENT_PET(data)
    self:checkPetAddPoint()

    -- 检查抗性点
    local petData = {["id"] = 0}
    local pet = self:getResistPet()--PetMgr:getPetById(data.id)
    if pet then
        petData = {["id"] = pet:getId()}
    end

    self:checkPromote(TAG_PET_RESIST_POINT, petData)

    --切换参战，掠阵宠物时，检查飞升宠物提升信息
    self:checkPromote(TAG_PET_FLY, nil, nil, true)
end

-- 宠物的状态变化
function PromoteMgr:MSG_SET_OWNER(data)
    self:checkPromote(TAG_PET_FLY, nil, nil, true)
end

-- 宠物的状态变化
function PromoteMgr:MSG_UPDATE_PETS(data)
    -- 策划要求实时检查宠物飞升状态，所以必须监听MSG_PET_UPDATE消息，但是
    -- 该消息在短时间内可能收到多次，后续消息可能移除飞升提示，所以增加第4个参数，表示此消息不移除飞升提示
    self:checkPromote(TAG_PET_FLY, nil, nil, true)
end

--
function PromoteMgr:clearData(isLoginOrSwithLine)
    DlgMgr:closeDlg("PromoteDlg")
    if not isLoginOrSwithLine then
        self.petHasFlyPromote = {}
        self.kidHasFlyPromote = {}
    end
end

-- 目前换角色登录时会被调用，清除提示标记
function PromoteMgr:clearPromoteInfoData()
    for _, v in pairs(promoteInfo) do
        v.trigger = 0
    end
end

function PromoteMgr:checkFenglingwan()
    local rideId = PetMgr:getRideId()

    if rideId and rideId > 0 then
        local pet = PetMgr:getPetById(rideId)

        if pet and not PetMgr:isTimeLimitedPet(pet) and PetMgr:getFenghuaDay(pet) < 5 then
            -- 非限时坐骑风灵丸时间小于5天时返回true
            return true
        end
    end

    return false
end

function PromoteMgr:checkPetAddPoint()
    self:checkPromote(TAG_PET_ADD_POINT)
end

function PromoteMgr:checkPetFly()
    if TaskMgr:getTaskByName(CHS[7002297]) then
        return false
    end

    local pets = {}
    local fightPet = PetMgr:getFightPet()
    if fightPet then table.insert(pets, fightPet) end
    local robPet = PetMgr:getRobPet()
    if robPet then table.insert(pets, robPet) end

    local curServerTime = gf:getServerTime()
    local showTipFlag = false
    for i = 1, #pets do
        local pet = pets[i]
        local iid = pet:queryBasic("iid_str")
        if pet:getLevel() >= Const.PET_FLY_LIMIT_LEVEL
            and not PetMgr:isFlyPet(pet)
            and pet:queryInt("rank") ~= Const.PET_RANK_WILD
            and (not PetMgr:isTimeLimitedPet(pet))
            and pet:queryInt("origin_intimacy") >= 30000
            and pet:queryInt("req_level") <= Me:getLevel()
            and pet:getLevel() <= Me:getLevel() + Const.PLAYER_PET_MAX_DIF
            and not (self.petHasFlyPromote and self.petHasFlyPromote[iid]) then
            -- 满足基本提示条件，且此次登录该宠物未提示过飞升

            if not self.petHasFlyPromote then self.petHasFlyPromote = {} end
            self.petHasFlyPromote[iid] = true

            showTipFlag = true
        end
    end

    return showTipFlag
end

-- 检查娃娃飞升
function PromoteMgr:checkKidFly()
    if not DistMgr:curIsTestDist() then
        -- 公测区暂时屏蔽娃娃飞升
        return
    end

    local kid = HomeChildMgr:getFightKid()
    if kid and Me:getLevel() >= 100 and kid:queryInt("origin_intimacy") > 6000
        and kid:queryBasicInt("has_upgraded") <= 0
        and not TaskMgr:getTaskByName(CHS[7120201])
        and (not self.kidHasFlyPromote or not self.kidHasFlyPromote[kid:queryBasic("cid")])
        and string.isNilOrEmpty(kid:queryBasic("upgrade_gid")) then
        -- 娃娃飞升条件：Me等级大于等于100，亲密度大于6000，娃娃没有飞升，当前没有领娃娃飞升任务
        -- 当前娃娃没有被提示过飞升，娃娃飞升任务没有被配偶领取(upgrade_gid为空)
        if not self.kidHasFlyPromote then
            self.kidHasFlyPromote = {}
        end

        self.kidHasFlyPromote[kid:queryBasic("cid")] = true
        return true
    end
end

function PromoteMgr:changeCrossServer(data)
    self.crossServerData = data
end

function PromoteMgr:MSG_ENTER_GAME()
    if not self.crossServerData then
        return
    end

    local data = self.crossServerData
    if (data.newServer and REMOVE_ALL_PROMOTE_SERVER[data.newServer])
        or (data.lastServerType and REMOVE_ALL_PROMOTE_SERVER[data.lastServerType]) then
        -- 进入/退出全民PK跨服区组、青城论道，将提升标记都清除
        for k, _ in pairs(promoteInfo) do
            self:removeByTag(k)
        end
    end

    if data.newServer and data.newServer > 0 then
        -- 进入跨服区组，刷新一些跨服不需要显示的提示
        for k, v in pairs(NOT_SHOW_IN_CROSS_SERVER) do
            if promoteInfo[k].trigger == 1 then
                -- 进入跨服之前，若存在标记，先缓存
                if not self.tagBeforeEnterCrossServer then
                    self.tagBeforeEnterCrossServer = {}
                    self.tagBeforeEnterCrossServer.gid = Me:queryBasic("gid")
                end

                self.tagBeforeEnterCrossServer[k] = true
            end

            self:checkPromote(k)
        end
    elseif data.lastServerType and data.lastServerType > 0 then
        -- 退出跨服时
        if self.tagBeforeEnterCrossServer and self.tagBeforeEnterCrossServer.gid == Me:queryBasic("gid") then
            for k, v in pairs(self.tagBeforeEnterCrossServer) do
                if promoteInfo[k] then promoteInfo[k].trigger = 1 end
                DlgMgr:sendMsg("SystemFunctionDlg", "setPromoteButtonVisible", true)
                DlgMgr:sendMsg("PromoteDlg", "setPromoteList")
            end
        end

        self.tagBeforeEnterCrossServer = nil
    end

    self.crossServerData = nil
end

MessageMgr:hook("MSG_UPDATE_PETS", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_INVENTORY", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_TASK_PROMPT", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_GUARDS_REFRESH", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_LEVEL_UP", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_GENERAL_NOTIFY", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_SET_CURRENT_PET", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_SET_OWNER", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_GUARD_EXPERIENCE_SUCC", PromoteMgr, "PromoteMgr")
MessageMgr:hook("MSG_ENTER_GAME", PromoteMgr, "PromoteMgr")

-- 换角色登录时响应
EventDispatcher:addEventListener("EVENT_CHANGE_ROLE_LOGIN", PromoteMgr.clearPromoteInfoData, PromoteMgr)
EventDispatcher:addEventListener(EVENT.CHANGE_CROSS_SERVER, PromoteMgr.changeCrossServer, PromoteMgr)
