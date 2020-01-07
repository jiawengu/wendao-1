-- AutoFightMgr.lua
-- created by zhengjh Mar/30/2015
-- 自动战斗系统管理器

AutoFightMgr = Singleton()
local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166
local LIFE_NO   = 9169
local MANA_NO   = 9170

local petActionList = {}
local playerActionList = {}

-- 获取默认配置动作
function AutoFightMgr:getDefaultFigthAction(object)
    local con = object:queryBasicInt("con")             -- 体质
    local wiz = object:queryBasicInt("wiz")             -- 灵力
    local str = object:queryBasicInt("str")             -- 力量
    local dex = object:queryBasicInt("dex")             -- 敏捷

    local attackId = object:getId()
    local skillNo = 0

    if wiz >= str then              -- 法功
        local skills = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_B)
        if skills ~= nil and #skills ~= 0 then
            skillNo = self:getMaxladderSkill(skills)
        end
    end

    if skillNo == 0 then
        local skills = SkillMgr:getSkillNoAndLadder(attackId, SKILL.SUBCLASS_J)
        if skills ~= nil and #skills ~= 0 then
            -- 力破千钧
            skillNo = skills[1].no
        end
    end

    if object:getId() == Me:getId() then
        if skillNo == 0 then
            self:setMeAutoSkill(FIGHT_ACTION.PHYSICAL_ATTACK, FIGHT_ACTION.PHYSICAL_ATTACK)
            self:setLastMeAction(PHYATTACT_NO)
        else
            self:setMeAutoSkill(FIGHT_ACTION.CAST_MAGIC, skillNo)
            self:setLastMeAction(skillNo)
        end
    else
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

        if skillNo == 0 then
            self:setPetAutoSkill(FIGHT_ACTION.PHYSICAL_ATTACK, FIGHT_ACTION.PHYSICAL_ATTACK)
            self:setLastPetAction(PHYATTACT_NO)
        else
            self:setPetAutoSkill(FIGHT_ACTION.CAST_MAGIC, skillNo)
            self:setLastPetAction(skillNo)
        end
    end
end

function AutoFightMgr:autoFight()
    if Me:queryBasicInt('c_enable_input') == 1  then
         -- 先判断不抓宠物宝宝
         for i = 0, FightPosMgr.NUM_PER_LINE * 2 - 1 do
             if FightMgr.objs[i].isCreated and FightMgr.objs[i]:queryBasicInt("c_seq_died") == 0 then
                local name = FightMgr.objs[i]:getName()
                local len = string.len(name)
                if string.sub(name, len - 5, len) == CHS[3000024] and FightMgr.objs[i]:canProcessCatch() then
                    if PetMgr:getFreePetCapcity() > 0 then
                        gf:sendFightCmd(Me:getId(), FightMgr.objs[i]:getId(), FIGHT_ACTION.CATCH_PET, 0)
                        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

                        if pet  then
                            gf:sendFightCmd(pet:getId(), pet:getId(), FIGHT_ACTION.DEFENSE, 0)
                        end

                        Me:setBasic('c_enable_input', 0)
                        return
                    end

                end
             end
         end

        -- 玩家攻击
        if not self.meActionTag then
            self:getDefaultFigthAction(Me)
        end

        self:getMeAction()

        Me:setBasic('c_me_finished_cmd', 1)
        local obj
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

        if pet and FightMgr:getObjectById(pet:getId())then
            Me:setBasic('c_attacking_id', pet:getId())
            self:getPetAciotn()
            Me:setBasic('c_pet_finished_cmd', 1)
        else
            Me:setBasic('c_pet_finished_cmd', 1)
        end

        FightMgr:CleanAllAction()
        -- 不可输入命令
        Me:setBasic('c_enable_input', 0)
    end

end

function AutoFightMgr:getMaxladderSkill(skills)
    -- 移除4阶技能
    for k, v in pairs(skills) do
        if v.ladder == SKILL.LADDER_4 then
            table.remove(skills, k)
            break
        end
    end

    table.sort(skills, function (a, b)
        return a.ladder > b.ladder
    end)

    return skills[1].no

end

function AutoFightMgr:getMeAction()
    local attackId = Me:getId()  --queryBasicInt('c_attacking_id')

    if self.meAutoSkillType ~= nil and self.meAutoSkiillParam ~= nil then
        if self.meAutoSkillType == FIGHT_ACTION.DEFENSE then
            gf:sendFightCmd(attackId, attackId, self.meAutoSkillType, self.meAutoSkiillParam)
        else

            local attackedObj = self:getFightObjBySkill(attackId, self.meAutoSkillType, self.meAutoSkiillParam)
            if attackedObj then
                gf:sendFightCmd(attackId, attackedObj:getId(), self.meAutoSkillType, self.meAutoSkiillParam)
            end
        end
    end
end

function AutoFightMgr:setMeAutoSkill(actionType, param)
    self.meAutoSkillType = actionType
    self.meAutoSkiillParam = param
end

function AutoFightMgr:getPlayerAutoFightData()
    return playerActionList
end

function AutoFightMgr:getPetAutoFightData()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not pet then return end
    return petActionList[pet:getId()]
end

function AutoFightMgr:getPetAciotn()
    --local attackId = Me:queryBasicInt('c_attacking_id')
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    local attackId = pet:getId()
    if not self:getPetActionTag() then
        self:getDefaultFigthAction(pet)
    end

    local  petAction = petActionList[pet:getId()]
    if petAction and petAction["petAutoSkillType"] ~= nil and petAction["petAutoSkiillParam"]~= nil then
        if petAction["petAutoSkillType"] == FIGHT_ACTION.DEFENSE then
            gf:sendFightCmd(attackId, attackId, petAction["petAutoSkillType"], petAction["petAutoSkiillParam"])
        else
            local attackedObj = self:getFightObjBySkill(attackId, petAction["petAutoSkillType"], petAction["petAutoSkiillParam"])

            if attackedObj then
                gf:sendFightCmd(attackId, attackedObj:getId(), petAction["petAutoSkillType"], petAction["petAutoSkiillParam"])
            end
        end

        return true
    end

    return false
end

function AutoFightMgr:setPetAutoSkill(actionType, param)
    -- 宠物攻击
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet then
        if petActionList[pet:getId()] == nil then
            petActionList[pet:getId()] = {}
        end
        petActionList[pet:getId()]["petAutoSkillType"] = actionType
        petActionList[pet:getId()]["petAutoSkiillParam"] = param
    end
end

-- 获取被加动作的对象
function AutoFightMgr:getFightObjBySkill(attackId, skillType, skillParam)
    local attctFightObjList = {}
    for i = 0, FightPosMgr.NUM_PER_LINE * 2 - 1 do
        if FightMgr.objs[i].isCreated and FightMgr.objs[i]:queryBasicInt("c_seq_died") == 0 then
            table.insert(attctFightObjList, FightMgr.objs[i])
        end
    end

    local teamFightObjList = {}
    for i = FightPosMgr.NUM_PER_LINE * 2, FightPosMgr.NUM_PER_LINE * 4 - 1 do
        if FightMgr.objs[i].isCreated and FightMgr.objs[i]:queryBasicInt("c_seq_died") == 0 then
            table.insert(teamFightObjList, FightMgr.objs[i])
        end
    end

   -- local attackId = Me:queryBasicInt('c_attacking_id')
    local subClass, class
    if skillType ==  FIGHT_ACTION.CAST_MAGIC then
         subClass  = SkillMgr:getSkill(attackId, skillParam)["subclass"]
         class = SkillMgr:getSkill(attackId, skillParam)["class"]
    end

    local attactedObj

    if skillType == FIGHT_ACTION.PHYSICAL_ATTACK or subClass == SKILL.SUBCLASS_J then   -- 物理攻击
        attactedObj = self:getObjByPhyAttact(attctFightObjList)
    elseif skillType == FIGHT_ACTION.CAST_MAGIC then                               -- 所有技能攻击
        if subClass == SKILL.SUBCLASS_B then              -- 攻击技能
            attactedObj = self:getObjByActtactSkill(attctFightObjList)
        elseif subClass == SKILL.SUBCLASS_C then             -- 障碍技能
            attactedObj = self:getObjByBalkSkill(attctFightObjList)
        elseif subClass == SKILL.SUBCLASS_D and attackId == Me:getId() then              -- 辅助技能
            attactedObj = self:getObjByAuxiliary(teamFightObjList)
        elseif  subClass == SKILL.SUBCLASS_D or ( subClass == SKILL.SUBCLASS_E and  class == SKILL.CLASS_PUBLIC ) then  -- 天生技能
            attactedObj = self:getObjByRaw(skillParam, attctFightObjList, teamFightObjList)
        elseif  subClass == SKILL.SUBCLASS_E and  class == SKILL.CLASS_PET then         -- 研发技能
            attactedObj = self:getObjByDevelop(SkillMgr:getSkillName(skillParam), teamFightObjList)
        end
    end

    return attactedObj
end

-- 攻击技能的目标
function AutoFightMgr:getObjByActtactSkill(attctFightObjList)
    table.sort(attctFightObjList,function (a, b) return a:getSkillTargetWeight() > b:getSkillTargetWeight() end)
    return attctFightObjList[1]
end

-- 障碍技能
function AutoFightMgr:getObjByBalkSkill(attctFightObjList)
    local balkStatusList = {}

    for i = 1, #attctFightObjList do
        if not attctFightObjList[i]:isBalkStatus() then
            table.insert(balkStatusList, attctFightObjList[i])
        end
    end

    local randomNumber = math.random(#balkStatusList)

    return balkStatusList[randomNumber] or attctFightObjList[1]
end

-- 辅助技能
function AutoFightMgr:getObjByAuxiliary(teamFightObjList)
    local meObj = self:getMeFightObj()

    -- 优先判断木系加血(复活作用)
    if POLAR.WOOD == tonumber(Me:queryBasic("polar")) then
        local list = {}
        for i = FightPosMgr.NUM_PER_LINE * 2, FightPosMgr.NUM_PER_LINE * 4 - 1 do
            if FightMgr.objs[i].isCreated then
                table.insert(list, FightMgr.objs[i])
            end
        end

        teamFightObjList  = list -- 木系对所有队友有效
    end

    -- 优先对自己使用
    if not meObj:isHaveAuxiliaryStatus() then
        return meObj
    end

    local auxiliaryStatusList = {}

    for i = 1,#teamFightObjList do
        if not teamFightObjList[i]:isHaveAuxiliaryStatus() and teamFightObjList[i]:getId() ~= meObj:getId() then
            table.insert(auxiliaryStatusList, teamFightObjList[i])
        end
    end

    if #auxiliaryStatusList > 0 then
        local randomNumber = math.random(#auxiliaryStatusList)
        return auxiliaryStatusList[randomNumber]
    else
        return meObj
    end
end

-- 天生技能
function AutoFightMgr:getObjByRaw(skillNo, enemyList, TeamFightObjList)
    local pet = self:getPetFightObj()
    local meObj = self:getMeFightObj()
    local skill = SkillMgr:getSkill(pet:getId(), skillNo)
    local object = nil

    if not skill or (not pet:canProcessSkill(skill) and not meObj:canProcessSkill(skill))then
        -- 敌方技能
        local randomNumber = math.random(#enemyList)
        return enemyList[randomNumber]
    else
        if not meObj:isRawStatus(skillNo) then
            object = meObj
        elseif not pet:isRawStatus(skillNo) then
            object = pet
        else
            local statusList = {}

            for i = 1, #TeamFightObjList do
                if not TeamFightObjList[i]:isRawStatus(skillNo) then
                    table.insert(statusList, TeamFightObjList[i])
                end
            end

            if #statusList > 0 then
                local randomNumber = math.random(#statusList)
                object = statusList[randomNumber]
            else
                object = meObj
            end
        end

    end

    return object or meObj
end

-- 研发技能
function AutoFightMgr:getObjByDevelop(skillName, teamFightObjList)
    local pet = self:getPetFightObj()
    local meObj = self:getMeFightObj()
    local object = nil

    if pet.isCreated then
        if skillName == CHS[4000181] or skillName == CHS[4000182] then       -- 法力护盾和移花接木
            object = pet
        elseif  skillName == CHS[4000183] then                                   -- 五色光环
            if not meObj:isPassiveMagAttack() then
                object = meObj
            elseif not pet:isPassiveMagAttack() then
                object = pet
            else
                local statusList = {}
                for i = 1, #teamFightObjList do
                    if not teamFightObjList[i]:isPassiveMagAttack() then
                        table.insert(statusList, teamFightObjList[i])
                    end
                end

                if #statusList > 0 then
                    local randomNumber = math.random(#statusList)
                    object = statusList[randomNumber]
                else
                    object = meObj
                end
            end
        elseif skillName == CHS[4000184] then                                       -- 舍身取义
            local temeList = {}

            for i = 1, #teamFightObjList do
                if teamFightObjList[i]:getId() ~= pet:getId() then
                    table.insert(temeList, teamFightObjList[i])
                end
            end

            table.sort(temeList,function (a, b) return a:queryInt('life') < b:queryInt('life') end)
            object = temeList[1]
        end
    end

    return object or teamFightObjList[1]
end

-- 物理攻击和力破千钧
function AutoFightMgr:getObjByPhyAttact(attctFightObjList)
    table.sort(attctFightObjList,function (a, b) return a:getPhyAtacctWeight() > b:getPhyAtacctWeight() end)
    return attctFightObjList[1]
end

-- 获取自己战斗中的对象
function AutoFightMgr:getMeFightObj()
    local meObj
    for i = FightPosMgr.NUM_PER_LINE * 3, FightPosMgr.NUM_PER_LINE * 4 - 1 do
        if FightMgr.objs[i].isCreated and FightMgr.objs[i]:getId() == Me:getId()  then
            meObj = FightMgr.objs[i]
        end
    end

    return meObj
end

-- 获取战斗中自己宠物对象
function AutoFightMgr:getPetFightObj()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
	local petObj
    for i = FightPosMgr.NUM_PER_LINE * 2, FightPosMgr.NUM_PER_LINE * 3 - 1 do
        if pet and FightMgr.objs[i].isCreated and FightMgr.objs[i]:getId() == pet:getId()  then
            petObj = FightMgr.objs[i]
        end
    end

    return petObj
end

-- 设置最后选的操作
function AutoFightMgr:setLastMeAction(meActionTag)
    self.meActionTag = meActionTag
end

function AutoFightMgr:getMeActionTag()
    return self.meActionTag
end

function AutoFightMgr:getMeLastActionInfo()
    return  self.meAutoSkillType, self.meAutoSkiillParam
end

function AutoFightMgr:setLastPetAction(petActionTag)

    -- 宠物攻击
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet then
        if petActionList[pet:getId()] == nil then
            petActionList[pet:getId()] = {}
        end

        petActionList[pet:getId()]["petActionTag"] = petActionTag
    end
end

function AutoFightMgr:getPetActionTag()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and petActionList[pet:getId()]  then
        return petActionList[pet:getId()]["petActionTag"]
	end
end

function AutoFightMgr:getPetLastAction()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if petActionList[pet:getId()] and pet then
        return petActionList[pet:getId()]["petAutoSkillType"], petActionList[pet:getId()]["petAutoSkiillParam"]
    end
end

function AutoFightMgr:setDefaultAction(setType)
    if not setType then setType = "all" end


    if not self.meActionTag and (setType == "all" or setType == "Me") then
        self:getDefaultFigthAction(Me)
    end

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

    if (setType == "all" or setType == "Pet") and pet and (not petActionList[pet:getId()] or not petActionList[pet:getId()]["petActionTag"]) then
        self:getDefaultFigthAction(pet)
    end
end

function AutoFightMgr:setMeDefaultAction()
    self:getDefaultFigthAction(Me)
end

function AutoFightMgr:setPetDefualtAction()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

    if pet and not petActionList[pet:getId()]  then
        petActionList[pet:getId()]  = {}
    end

    if pet then
        self:getDefaultFigthAction(pet)
    end
end

-- 组合技能是否开启。注意，自动战斗可能没有开启
function AutoFightMgr:isOpenZuheSkill(obType)
    if obType == "Me" then
        local userAutoData = AutoFightMgr:getPlayerAutoFightData()
        if userAutoData and next(userAutoData)  and userAutoData.multi_index > 0 then
            return true
        end
    elseif obType == "Pet" then
        local petAutoData = AutoFightMgr:changePetDataToCmd()
        if petAutoData and next(petAutoData)  and petAutoData.multi_index > 0 then
            return true
        end
    end
end

-- 开启关闭自动战斗
function AutoFightMgr:autoFightSiwchStatus(param)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_START_AUTO_FIGHT, param)

    if param == 1 then
        -- 开启的时候，清空上一次，目的是为了界面不会从上一次技能闪跳到组合技能
        if AutoFightMgr:isOpenZuheSkill("Me") then
            AutoFightMgr:setLastMeAction()
        end

        if AutoFightMgr:isOpenZuheSkill("Pet") then
            AutoFightMgr:setLastPetAction()
        end
    end
end

function AutoFightMgr:getSkillNoByData(data)
    if data.action == FIGHT_ACTION.PHYSICAL_ATTACK then
        return PHYATTACT_NO
    elseif data.action == FIGHT_ACTION.DEFENSE then
        return DEFENCE_NO
    elseif data.action == FIGHT_ACTION.APPLY_ITEM then
        if data.para == 0 then
            return LIFE_NO
        elseif data.para == 1 then
            return MANA_NO
        end
    elseif data.action == FIGHT_ACTION.CAST_MAGIC  then
        return data.para
    else
        return data.para
    end
end

-- 断线重连自动战斗设置数据
function AutoFightMgr:MSG_FIGHT_CMD_INFO(data)
    self.autoSettingTable  = {}

    for i = 1, data.count do
        if data[i].id == Me:getId() then
            playerActionList = {}
            local lastAct = AutoFightMgr:getSkillNoByData(data[i])
            self:setLastMeAction(lastAct)
            self:setMeAutoSkill(data[i].action, data[i].para)
            self:setMeSelectManaIndex(data[i].auto_select)

            playerActionList = data[i]
        else
            petActionList[data[i].id] = data[i]

            if data[i].action == FIGHT_ACTION.PHYSICAL_ATTACK then
                petActionList[data[i].id]["petActionTag"] = PHYATTACT_NO
            elseif data[i].action == FIGHT_ACTION.DEFENSE then
                petActionList[data[i].id]["petActionTag"] = DEFENCE_NO
            elseif data[i].action == FIGHT_ACTION.APPLY_ITEM then
                if data[i].param == 0 then
                    petActionList[data[i].id]["petActionTag"] = LIFE_NO
                elseif data[i].param == 1 then
                    petActionList[data[i].id]["petActionTag"] = MANA_NO
                end
            elseif data[i].action == FIGHT_ACTION.CAST_MAGIC  then
                petActionList[data[i].id]["petActionTag"] = data[i].para
            end

            petActionList[data[i].id]["petAutoSkillType"] = data[i].action
            petActionList[data[i].id]["petAutoSkiillParam"] = data[i].para
            petActionList[data[i].id]["petSelectManaIndex"] = data[i].auto_select
            -- 由于后开发组合技能，所以没有没有直接全部赋值，早知道就一起改了
            petActionList[data[i].id].zhSkillsData = data[i].autoFightData
        end
    end
end

-- 将宠物消息转化成需要发送给服务器的格式
function AutoFightMgr:changePetDataToCmd()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not pet then return end

    local petAutoData = AutoFightMgr:getPetAutoFightData()
    if not petAutoData or not next(petAutoData) then
        petAutoData = {}
        petAutoData.action = 0
        petAutoData.para = 0
        petAutoData.multi_index = 0
        petAutoData.zhSkillsData = {}
    end
    local data = {}
    data.id = pet:getId()
    data.auto_select = AutoFightMgr:getPetSelectManaIndex()
    data.multi_index = petAutoData.multi_index or 0 -- 新宠物可能为nil
    data.action = petAutoData.petAutoSkillType
    data.para = petAutoData.petAutoSkiillParam
    data.multi_count = 0
    data.autoFightData = {}

    local fristSkill
    for i = 1, 3 do
        if petAutoData.zhSkillsData and petAutoData.zhSkillsData[i] then
            data.multi_count = data.multi_count + 1
            local temp = petAutoData.zhSkillsData[i]
            table.insert(data.autoFightData, {action = temp.action, para = temp.para, round = temp.round})
        end
    end

    return data
end

-- 将角色消息转化成需要发送给服务器的格式
function AutoFightMgr:changeMeDataToCmd()
    local petAutoData = AutoFightMgr:getPlayerAutoFightData()
    if not petAutoData or not next(petAutoData) then
        petAutoData = {}
        petAutoData.action = 0
        petAutoData.para = 0
        petAutoData.multi_index = 0
        petAutoData.autoFightData = {}
    end
    local data = {}
    data.id = Me:getId()
    data.auto_select = AutoFightMgr:getMeSelectManaIndex()
    data.multi_index = petAutoData.multi_index
    data.action = petAutoData.action
    data.para = petAutoData.para
    data.multi_count = 0
    data.autoFightData = {}

    local fristSkill
    for i = 1, 3 do
        if petAutoData.autoFightData[i] then
            data.multi_count = data.multi_count + 1
            local temp = petAutoData.autoFightData[i]
            table.insert(data.autoFightData, {action = temp.action, para = temp.para, round = temp.round})
        end
    end

    return data
end

-- 设置人物自动战斗
function AutoFightMgr:setMeAutoFightAction(action, param, zhData)

    local data
    if not zhData then
        data = AutoFightMgr:changeMeDataToCmd()
        data.action = action
        data.para = param
        data.multi_index = 0
    end

    gf:CmdToServer("CMD_AUTO_FIGHT_SET_DATA", zhData or data)

    -- 客户端需要先保存，原因是
    -- 没有保存的话，要是延迟未收到 MSG_FIGHT_CMD_INFO 消息时，再次操作，则会覆盖上一次的操作
    local retData = {}
    retData.count = 1
    retData[1] = gf:deepCopy(zhData or data)
    retData[1].para = retData[1].para
    for i = 1, retData[1].multi_count do
        retData[1].autoFightData.para = retData[1].autoFightData.para
    end
    if retData[1].multi_count == 0 then
        retData[1].multi_index = 0
    end

    self:MSG_FIGHT_CMD_INFO(retData)
    DlgMgr:sendMsg("PracticeDlg", "MSG_FIGHT_CMD_INFO", retData)
end

-- 设置宠物战斗   zhData 组合技能信息
function AutoFightMgr:setPetAutoFightAction(action, param, zhData)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not pet then return end

    local data
    if not zhData or not next(zhData) then
        data = AutoFightMgr:changePetDataToCmd()
        data.action = action
        data.para = param
        data.multi_index = 0
    end

    gf:CmdToServer("CMD_AUTO_FIGHT_SET_DATA", zhData or data)

    -- 客户端需要先保存，原因是
    -- 没有保存的话，要是延迟未收到 MSG_FIGHT_CMD_INFO 消息时，再次操作，则会覆盖上一次的操作
    local retData = {}
    retData.count = 1
    retData[1] = gf:deepCopy(zhData or data)
    retData[1].para = retData[1].para
    for i = 1, retData[1].multi_count do
        retData[1].autoFightData.para = retData[1].autoFightData.para
    end
    if retData[1].multi_count == 0 then
        retData[1].multi_index = 0
    end

    self:MSG_FIGHT_CMD_INFO(retData)
    DlgMgr:sendMsg("PracticeDlg", "MSG_FIGHT_CMD_INFO", retData)
end


-- 设置法力不足人物的策略
function AutoFightMgr:setMeSelectManaIndex(index)
    self.meSelectMannIndex = index
end

function AutoFightMgr:sendMeSelelctManaIndex(index)

    local data = gf:deepCopy(AutoFightMgr:getPlayerAutoFightData())
    if not next(data) then
        data.id = Me:getId()
        data.multi_index = 0
        data.action = 0
        data.para = 0
        data.multi_count = 0
    end

    data.auto_select = index

    gf:CmdToServer("CMD_AUTO_FIGHT_SET_DATA", data)

    self:setMeSelectManaIndex(index)
end

function AutoFightMgr:getMeSelectManaIndex()
    return self:getDefaultIndex(self.meSelectMannIndex)
end

function AutoFightMgr:getDefaultIndex(index)
    if not index or index == 0 then
        return 1
    else
        return index
    end
end

-- 设置法力不足宠物的策略
function AutoFightMgr:setPetSelectManaIndex(index)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()

    if not pet then return end

    if pet and not petActionList[pet:getId()] then
        petActionList[pet:getId()] = {}
    end

    petActionList[pet:getId()]["petSelectManaIndex"] = index
end

function AutoFightMgr:sendPetSelectManaIndex(index)
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if not pet then return end

    local data = AutoFightMgr:changePetDataToCmd()

    data.auto_select = index

    gf:CmdToServer("CMD_AUTO_FIGHT_SET_DATA", data)

    self:setPetSelectManaIndex(index)
end

function AutoFightMgr:getPetSelectManaIndex()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and petActionList[pet:getId()] then
        return  self:getDefaultIndex(petActionList[pet:getId()]["petSelectManaIndex"])
    else
        return 1
    end
end

function AutoFightMgr:clearData()
    petActionList = {}
    self.meActionTag = nil
    self.meAutoSkillType = nil
    self.meAutoSkiillParam = nil
    self.meSelectMannIndex  = nil
    self.petSelectMannIndex = nil
end

function AutoFightMgr:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_AUTO_FIGHT_SKILL == data.notify  then
        local paraList = gf:split(data.para, "_")
        if paraList[1] ~= "-1" then -- 人物操作动作
            local actionTag = DEFENCE_NO
            if tonumber(paraList[1]) == 0 then
                actionTag = DEFENCE_NO
            elseif tonumber(paraList[1]) == 2 then
                actionTag = PHYATTACT_NO
            else
                actionTag = tonumber(paraList[1])
            end

            AutoFightMgr:setLastMeAction(actionTag)
        else
            AutoFightMgr:setMeDefaultAction()
        end

        if paraList[2] ~= "-1" then -- 宠物操作动作
            local actionTag = DEFENCE_NO
            if tonumber(paraList[2]) == 0 then
                actionTag = DEFENCE_NO
            elseif tonumber(paraList[2]) == 2 then
                actionTag = PHYATTACT_NO
            else
                actionTag = tonumber(paraList[2])
            end

            AutoFightMgr:setLastPetAction(actionTag)
        else
            AutoFightMgr:setPetDefualtAction()
        end

        DlgMgr:sendMsg("PracticeDlg","refreshAllData")
    end
end

-- 返回true时，表示组合技能不需要选择目标
function AutoFightMgr:isNotTargetFightObj(data)
    local opTab = {}
    for i = 1, data.multi_count do
        local skillNo = AutoFightMgr:getSkillNoByData(data.autoFightData[i])
        local skillName = SkillMgr:getSkillName(skillNo)
        local skillInfo = SkillMgr:getSkillDesc(skillName)
        if skillInfo["op_obj"] then
            opTab[skillInfo["op_obj"]] = 1
        end
    end

    if not opTab.enemy and not opTab.friend then
        -- 组合技能，对应技能不需要选中目标
        return true
    end
end

-- 设置自动战斗目标
function AutoFightMgr:setAutoFightTarget(id, friend_id, enemy_id)
    gf:CmdToServer('CMD_AUTO_FIGHT_SET_VICTIM', { id = id, friend_id = friend_id, enemy_id = enemy_id})
--[[
    local para1 = string.format("%s;%s;%s", id, friend_id, enemy_id)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_ZUHE_SKILL_TARGET, para1)
--]]

    if id == Me:getId() then
        local playerAutoData = AutoFightMgr:getPlayerAutoFightData()
        if playerAutoData and next(playerAutoData)  and playerAutoData.multi_count > 0 then
            local data = AutoFightMgr:changeMeDataToCmd()
            data.multi_index = 1
            AutoFightMgr:setMeAutoFightAction(nil, nil, data)
        end
    else
        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        if not pet then return end

        local petAutoData = AutoFightMgr:changePetDataToCmd()
        if petAutoData and next(petAutoData)  and petAutoData.multi_count > 0 then
            local data = AutoFightMgr:changePetDataToCmd()
            data.multi_index = 1
            AutoFightMgr:setPetAutoFightAction(nil, nil, data)
        end
    end
end

MessageMgr:hook("MSG_GENERAL_NOTIFY", AutoFightMgr, "AutoFightMgr")
MessageMgr:regist("MSG_FIGHT_CMD_INFO", AutoFightMgr)

return AutoFightMgr
