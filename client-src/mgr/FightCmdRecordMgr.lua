-- FightCmdRecordMgr.lua
-- created by lixh2 Aug/14/2018
-- 战斗指令记录管理器

FightCmdRecordMgr = Singleton()

-- 每回合记录的指令，使用完就清空
FightCmdRecordMgr.record = {}

-- 用于界面显示的容器
FightCmdRecordMgr.recordShowInfo = {}

-- 部分action结果需要服务器通知，需要做缓存
FightCmdRecordMgr.actionResult = {}

-- 需要记录的action类型
local RECORD_ACTION = {
    [FIGHT_ACTION.DEFENSE]         = CHS[7150091], -- 防御
    [FIGHT_ACTION.PHYSICAL_ATTACK] = CHS[7150092], -- 物理攻击
    [FIGHT_ACTION.CAST_MAGIC]      = CHS[7150093], -- 施展魔法
    [FIGHT_ACTION.APPLY_ITEM]      = CHS[7150094], -- 道具
    [FIGHT_ACTION.FLEE]            = CHS[7150095], -- 逃跑
    [FIGHT_ACTION.SELECT_PET]      = CHS[7150096], -- 选择宠物出战
    [FIGHT_ACTION.CATCH_PET]       = CHS[7150097], -- 捕捉
    [FIGHT_ACTION.CALLBACK_PET]    = CHS[7150098], -- 召回
    [FIGHT_ACTION.DIE]             = CHS[7150099], -- 死亡
    [FIGHT_ACTION.DOUBLE_MAGIC_HIT]= CHS[7150100], -- 法术连击
    [FIGHT_ACTION.DOUBLE_HIT]      = CHS[7150101], -- 连击
    [FIGHT_ACTION.JOINT_ATTACK]    = CHS[7150102], -- 合击
    [FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL]    = CHS[7150103], -- 使用法宝特殊技能
}
for k, v in pairs(RECORD_ACTION) do
    RECORD_ACTION[v] = k
end

-- 飘字需要记录的action类型
local FLY_WORLDS_RECORD = {
    [CHS[3000005]] = true, -- 捕捉
    [CHS[3000012]] = true, -- 防御
    [CHS[3000013]] = true, -- 召唤
    [CHS[3000014]] = true, -- 逃跑
    [CHS[3000015]] = true, -- 道具
    [CHS[3000008]] = true, -- 连击
    [CHS[7150102]] = true, -- 合击
}

-- 没有飘字的战斗动作
local NOT_FLY_WORDS_ACT = {
    [Const.FA_ACTION_PHYSICAL_ATTACK] = CHS[7190338], -- 物理攻击
    [Const.FA_DIED]                   = CHS[7190349], -- 死亡
}

-- 通过victim寻找战斗指令
local FIND_RECORD_BY_VICTIM = {
    [CHS[3000015]] = FIGHT_ACTION.APPLY_ITEM,
    [CHS[7190365]] = FIGHT_ACTION.CALLBACK_PET,
    [CHS[7150102]] = FIGHT_ACTION.JOINT_ATTACK,
}

-- 战斗记录显示类型
local SHOW_INFO_TYPE = {
    STR = 1,   -- 纯字符串
    SKILL = 2, -- 技能
    ITEM = 3,  -- 道具
}

-- 战斗动作技能图标
local FIGHT_ACTION_ICON = {
    [FIGHT_ACTION.DEFENSE]         = ResMgr:getSkillIconPath(09167), -- 防御
    [FIGHT_ACTION.PHYSICAL_ATTACK] = ResMgr:getSkillIconPath(09166), -- 物理攻击
    [FIGHT_ACTION.FLEE]            = ResMgr:getSkillIconPath(09308), -- 逃跑
    [FIGHT_ACTION.SELECT_PET]      = ResMgr:getSkillIconPath(09306), -- 选择宠物出战
    [FIGHT_ACTION.CATCH_PET]       = ResMgr:getSkillIconPath(09307), -- 捕捉宠物
    [FIGHT_ACTION.CALLBACK_PET]    = ResMgr:getSkillIconPath(09305), -- 召回宠物
}

-- 战斗技能位置配置
local FIGHT_ICON = {
    ATTACKER_START_Y = 50,
    ATTACKER_END_Y = 80,
    ARROW_START_Y = 50,
    ARROW_END_Y = 30,
}

-- 战斗动画宠物播放需要延迟
local FIGHT_PET_ACTION_MAGIC_DELAY = 0.5

-- 战斗中使用如下道具，客户端做效果时认为是对自己使用
local FIGHT_USE_TO_SELF = {
    [CHS[3001144]] = true, -- 火眼金睛
    [CHS[5410239]] = true, -- 火眼金睛 融合
    [09031] = true, -- icon 火眼金睛， 火眼金睛 融合
}

-- 战斗指令图标资源在charTopLayer中的tag
FightCmdRecordMgr.fightCmdSpriteTag = {}

-- 战斗指令动画标记
FightCmdRecordMgr.fightCmdMagic = nil

-- 战斗记录指引标记
FightCmdRecordMgr.recordGuideFlag = nil

-- 战斗记录与指令动画开启等级
local RECORD_OPEN_LEVEL = 30

-- 当前是否开启战斗指令与动画
function FightCmdRecordMgr:isRecordMagicOpen()
    if Me and Me:getLevel() >= RECORD_OPEN_LEVEL then
        return true
    end

    return false
end

function FightCmdRecordMgr:setRecordGuideFlag(flag)
    self.recordGuideFlag = flag

    local key = "fight_record_guide" ..  Me:queryBasic("gid")
    cc.UserDefault:getInstance():setBoolForKey(key, self.recordGuideFlag)
end

function FightCmdRecordMgr:getRecordGuideFlag()
    local guideKey = "fight_record_guide" ..  Me:queryBasic("gid")
    self.recordGuideFlag = cc.UserDefault:getInstance():getBoolForKey(guideKey, true)

    return self.recordGuideFlag
end

function FightCmdRecordMgr:setFightCmdMagicFlag(flag)
    self.fightCmdMagic = flag

    local key = "fight_cmd_magic" ..  Me:queryBasic("gid")
    cc.UserDefault:getInstance():setBoolForKey(key, self.fightCmdMagic)
end

function FightCmdRecordMgr:getFightCmdMagicFlag()
    local magicKey = "fight_cmd_magic" ..  Me:queryBasic("gid")
    self.fightCmdMagic = cc.UserDefault:getInstance():getBoolForKey(magicKey, true)

    return self.fightCmdMagic
end

function FightCmdRecordMgr:getShowInfoType()
    return SHOW_INFO_TYPE
end

-- 飘字子否需要记录
function FightCmdRecordMgr:checkFlgWorldRecord(isSkill, action)
    if isSkill or FLY_WORLDS_RECORD[action] then
        return true
    end
end

-- 动作是否需要记录
function FightCmdRecordMgr:getNotFlyWorldsAct(act)
    return NOT_FLY_WORDS_ACT[act]
end

-- 获取当前缓存指令
function FightCmdRecordMgr:getRecordShowInfo()
    return self.recordShowInfo
end

-- 清空当前缓存指令
function FightCmdRecordMgr:clearRecordShowInfo()
    self.recordShowInfo = {}
end

-- 插入回合记录
function FightCmdRecordMgr:insertRecord(data)
    if (data.attacker_id == 0 and data.victim_id == 0) or not RECORD_ACTION[data.action] then return end

    if not data.round then data.round = self.curRound end

    if self.curRound and self.curRound ~= data.round then
        -- 切换回合了，清空上一轮的数据
        self.record = {}
    end

    self.curRound = data.round

    if data.action == FIGHT_ACTION.SELECT_PET or data.action == FIGHT_ACTION.CALLBACK_PET then
        -- 召唤宠物，召回宠物，需要把宠物名称记下来
        local pet = FightMgr:getObjectById(data.victim_id)
        if pet then
            data.petName = pet:getName()

            if data.action == FIGHT_ACTION.CALLBACK_PET and 
                HomeChildMgr:getFightKid() and HomeChildMgr:getFightKid():getId() == data.victim_id then
                data.callBackType = "kid"
            end
        end
    end

    table.insert(self.record, data)
end

-- 移除回合记录
function FightCmdRecordMgr:removeRecord(record)
    for i = 1, #self.record do
        if self.record[i] == record then
            table.remove(self.record, i)
            return
        end
    end
end

-- 获取回合记录
function FightCmdRecordMgr:getRecordById(id, act)
    for i = 1, #self.record do
        if self.record[i].attacker_id == id and (not act or act == self.record[i].action) then
            return self.record[i]
        end
    end
end

-- 获取技能
function FightCmdRecordMgr:getSkillByNo(action, no)
    if action == FIGHT_ACTION.DEFENSE then
        return CHS[7190339]
    elseif action == FIGHT_ACTION.CAST_MAGIC or action == FIGHT_ACTION.DOUBLE_MAGIC_HIT
        or action == FIGHT_ACTION.ACTION_USE_ARTIFACT_EXTRA_SKILL or (no and tonumber(no) == 501) then
        -- 法术攻击，法术连击，法宝技能，力破千钧
        local skillInfo = SkillMgr:getskillAttrib(tonumber(no))
        if skillInfo then return skillInfo.name end
    elseif action == FIGHT_ACTION.PHYSICAL_ATTACK then
        return CHS[7190338]
    end
end

-- 保存记录到显示容器中
function FightCmdRecordMgr:updateRecordToShow(obj, actionName)
    if not obj then return end
    local objId = obj:getId()

    local cmdRecord = self:getRecordById(objId, RECORD_ACTION[actionName])
    if actionName and FIND_RECORD_BY_VICTIM[actionName] then
        -- 需要根据动作寻找指令， victimObj == obj
        for i = 1, #self.record do
            if self.record[i].action == FIND_RECORD_BY_VICTIM[actionName]
                and self.record[i].victim_id == objId then
                cmdRecord = self.record[i]
                break
            end
        end
    end

    if not cmdRecord then return end

    local record = self.record[1]

    while record and cmdRecord ~= record do
        -- 当前指令前面的指令默认认为已经执行
        self:saveRecord(record)

        local beforeRemoveLenth = #self.record

        self:removeRecord(record)
        record = self.record[1]

        -- 尝试移除指令后，数据长度没有变化，发生异常，直接跳出循环
        if beforeRemoveLenth <= #self.record then break end
    end

    self:saveRecord(cmdRecord)

    -- 每条指令记录后马上删除，防止类似"防御"这种会飘字多次
    self:removeRecord(cmdRecord)
end

-- 保存指令
function FightCmdRecordMgr:saveRecord(record)
    if not record then return end
    local attackObj = FightMgr:getObjectById(record.attacker_id)
    local victimObj = FightMgr:getObjectById(record.victim_id)

    -- 保存指令的对象不存在
    if not attackObj and not victimObj then return end

    local action = record.action
    if not RECORD_ACTION[record.action] then return end

    local showInfo = self:getShowInfo(record, attackObj, victimObj)
    if showInfo then
        self:insertShowInfo(showInfo)
    end
end

function FightCmdRecordMgr:insertShowInfo(info)
    table.insert(self.recordShowInfo, info)
    DlgMgr:sendMsg("FightRecordDlg", "addData", info)
end

-- 插入回合数
function FightCmdRecordMgr:insertRoundInfo(round)
    if round > 1 then
        -- 插入上一回合结束
        self:insertShowInfo({type = SHOW_INFO_TYPE.STR, str = string.format(CHS[7190356], round - 1), action = 0})
    elseif round == 1 then
        -- 第1回合，增加插入战斗开始
        self:insertShowInfo({type = SHOW_INFO_TYPE.STR, str = CHS[7190354], action = 0})
    end

    -- 插入新回合开始
    self:insertShowInfo({type = SHOW_INFO_TYPE.STR, str = string.format(CHS[7190355], round), action = 0})
end

-- 退出战斗，插入回合结束
function FightCmdRecordMgr:doEndCombat()
    if #self.recordShowInfo <= 0 then return end
    self:insertShowInfo({type = SHOW_INFO_TYPE.STR, str = string.format(CHS[7190356], FightMgr:getCurRound()), action = 0})
end

function FightCmdRecordMgr:getNameFormatStr(obj)
    if obj then
        if obj:isPet() or obj:isKid() then
            return string.format(CHS[7190360], obj:getName())
        elseif obj:isMonster() and COMBAT_MODE.COMABT_MODE_ARENA ~= FightMgr:getCombatMode() then
            return string.format(CHS[7190359], obj:getName())
        else
            return string.format(CHS[7190361], obj:getName())
        end
    end
end

function FightCmdRecordMgr:getShowInfo(record, attackObj, victimObj)
    local type
    local str
    local act = record.action
    if record.action == FIGHT_ACTION.DIE then
        -- 死亡
        type = SHOW_INFO_TYPE.STR
        if not attackObj then return end
        str = string.format(CHS[7190344], self:getObjShowName(attackObj))
    elseif record.action == FIGHT_ACTION.CATCH_PET then
        -- 捕捉宠物
        type = SHOW_INFO_TYPE.STR
        if not attackObj or not victimObj then return end
        local result, petId = self:getActionResult(FIGHT_ACTION.CATCH_PET, attackObj:getId())
        str = string.format(CHS[7190353], attackObj:getName(), victimObj:getName(), result and CHS[7190357] or CHS[7190358])
    elseif record.action == FIGHT_ACTION.CALLBACK_PET or record.action == FIGHT_ACTION.SELECT_PET then
        -- 召回宠物, 召唤宠物
        type = SHOW_INFO_TYPE.STR
        if not attackObj then return end
        local formatStr = record.action == FIGHT_ACTION.CALLBACK_PET and CHS[7190350] or CHS[7190351]
        local petName = victimObj and victimObj:getName()
        if string.isNilOrEmpty(petName) then
            petName = record.petName or ""
        end

        if record.callBackType and record.callBackType == "kid" then
            str = string.format(CHS[7100440], attackObj:getName(), petName)
        else
            str = string.format(formatStr, attackObj:getName(), petName)
        end
    elseif record.action == FIGHT_ACTION.FLEE then
        -- 逃跑
        type = SHOW_INFO_TYPE.STR
        if not attackObj then return end
        local result, _ = self:getActionResult(FIGHT_ACTION.FLEE, attackObj:getId())
        str = string.format(CHS[7190352], self:getNameFormatStr(attackObj), result and CHS[7190357] or CHS[7190358])
    elseif record.action == FIGHT_ACTION.DEFENSE then
        -- 防御 特殊显示
        type = SHOW_INFO_TYPE.STR
        if not victimObj then return end
        str = string.format(CHS[7190362], self:getObjShowName(victimObj))

        if victimObj:getName() == "" and attackObj then
            -- 九天真君中 怪物防御时，可能没有 victim，此时显示 attackObj 即可
            str = string.format(CHS[7190362], self:getNameFormatStr(attackObj))
        end
    elseif record.action == FIGHT_ACTION.JOINT_ATTACK then
        -- 合击
        type = SHOW_INFO_TYPE.STR
        str = self:getJointAttackDes(record)
        if not str then return end
    else
        if not attackObj or not victimObj then return end
        if record.action == FIGHT_ACTION.APPLY_ITEM then
            type = SHOW_INFO_TYPE.ITEM
            _, _, act = self:getActionResult(FIGHT_ACTION.APPLY_ITEM, attackObj:getId())
            if not act then return end
        else
            type = SHOW_INFO_TYPE.SKILL
            if record.action == FIGHT_ACTION.DOUBLE_HIT then
                act = CHS[3000008]
            else
                act = self:getSkillByNo(record.action, record.para)
            end
        end

        if attackObj == victimObj or self:isUseItemToSelf(act) then
            -- 对自己使用
            str = string.format(CHS[7190341], self:getObjShowName(attackObj))
        elseif attackObj and victimObj then
            -- xx 对 xx 使用了
            str = string.format(CHS[7190340], self:getObjShowName(attackObj), self:getObjShowName(victimObj))
        end

        if act == CHS[7190338] or act == CHS[7190339] then
            -- 物理攻击，防御，显示为字符串即可
            type = SHOW_INFO_TYPE.STR
        end

        if not str then return end

        local iconPath
        if record and record.action == FIGHT_ACTION.APPLY_ITEM then
            -- 道具图标
            iconPath = ResMgr:getIconPathByName(act)
        end

        if not iconPath and record and record.para then
            -- 技能图标
            local skillAttrib = SkillMgr:getskillAttrib(record.para)
            if skillAttrib then
                if string.isNilOrEmpty(skillAttrib.name) then
                    -- WDSY-34161增加了部分怪物使用空技能，策划希望这部分技能不显示在战斗指令中
                    return
                end

                if skillAttrib.skill_icon then
                iconPath = ResMgr:getSkillIconPath(skillAttrib.skill_icon)
            end
        end
        end

        -- 被动技能(夫妻技能,结拜技能,仙魔技能,新手战斗血煞魔君加血)
        if not act then return end

        if iconPath then
            -- 增加显示图标
            str = str .. string.format(CHS[7100389], iconPath, act)
        else
            str = str .. string.format(CHS[7190343], act)
        end
    end

        return {type = type, str = str, action = act}
end

-- 获取宠物主人名称
function FightCmdRecordMgr:getFightPetOwnerName(pet)
    if not pet:isPet() and not pet:isKid() then return "" end

    local ownerId = pet:queryBasicInt('owner_id')
    if ownerId == 0 then return "" end

    local owner = FightMgr:getObjectById(ownerId)
    if owner then
        return owner:getName()
    end

    return ""
end

-- 获取操作结果
function FightCmdRecordMgr:getActionResult(type, attackerId)
    for i = 1, #self.actionResult do
        local info = self.actionResult[i]
        if info.type == type and info.attacker_id == attackerId then
            table.remove(self.actionResult, i)
            return info.result == 1, info.victim_id, info.itemName
        end
    end

    return false
end

function FightCmdRecordMgr:onSetFightObjAct(data)
    if data and data.obj then
        if (data.type == "piaoZi" and self:checkFlgWorldRecord(data.para, data.actionName))
            or  (data.type == "setAct" and self:getNotFlyWorldsAct(data.para)) then
            -- 飘字，执行动作，两种类型需要更新动作显示
            self:updateRecordToShow(data.obj, data.actionName)
        end
    end
end

-- 增加战斗中对象(召唤宠物) 召唤宠物有飘字，不直接添加
function FightCmdRecordMgr:onAddFightObj(data)
    if data and data[1] then
        for i = 1, #self.record do
            if self.record[i].action == FIGHT_ACTION.SELECT_PET
                and data[1].actioner_id == self.record[i].attacker_id then
                self.record[i].petName = data[1].name
                break
            end
        end
    end
end

-- 战斗对象icon变化了，检查变身卡使用数据
function FightCmdRecordMgr:onFightObjIconChanged(objId)
    if objId then
        for i = 1, #self.record do
            if self.record[i].action == FIGHT_ACTION.APPLY_ITEM
                and objId == self.record[i].victim_id then
                self:updateRecordToShow(FightMgr:getObjectById(objId), CHS[3000015])
                break
            end
        end
    end
end

-- 战斗敌方显示血条
function FightCmdRecordMgr:onFightOpponentShowLife(flag)
    if not flag then return end
    for i = 1, #self.actionResult do
        local info = self.actionResult[i]
        if info.type == FIGHT_ACTION.APPLY_ITEM and (info.itemName == CHS[3001144] or info.itemName == CHS[5410239]) then
            self:updateRecordToShow(FightMgr:getObjectById(info.attacker_id), CHS[3000015])
            break
        end
    end
end

-- 每次进战斗，清空上一次记录
function FightCmdRecordMgr:onEnterCombat()
    self:clearRecordShowInfo()
end

-- 操作结果：逃跑，捕捉
function FightCmdRecordMgr:MSG_COMBAT_ACTION_RESULT(data)
    table.insert(self.actionResult, data)
end

-- 获取战斗对象名称
function FightCmdRecordMgr:getObjShowName(obj, otherName)
    if obj:isPet() or obj:isKid() then
        local ownerName = self:getFightPetOwnerName(obj)
        if string.isNilOrEmpty(ownerName) then
            -- 主人名称为空，宠物当怪物处理
            return string.format(CHS[7190359], obj:getName())
        else
            if otherName and otherName == ownerName then
                -- 另外一个对象的名字与主人名字相同，显示为自己的宠物
                if obj:isKid() then
                    -- 自己的娃娃
                    return CHS[7100441] .. self:getNameFormatStr(obj)
                else
                    return CHS[7100394] .. self:getNameFormatStr(obj)
                end
            else
                if obj:isKid() then
                    return string.format(CHS[7100442], ownerName) .. self:getNameFormatStr(obj)
                else
                    return string.format(CHS[7100392], ownerName) .. self:getNameFormatStr(obj)
                end
            end
        end
    else
        if COMBAT_MODE.COMABT_MODE_ARENA == FightMgr:getCombatMode() and obj == FightMgr.objs[7] then
            -- 竞技场中的 7 号位置固定为宠物，当前为怪物类型，特殊处理成宠物
            local petDes = string.format(CHS[7190360], obj:getName())
            if FightMgr.objs[2] and FightMgr.objs[2]:getName() ~= "" then
                -- 2 号对象固定为主人
                petDes = string.format(CHS[7100392], FightMgr.objs[2]:getName()) .. petDes
            end

            return petDes
        else
            return self:getNameFormatStr(obj)
        end
    end
end

-- 获取合击提示
function FightCmdRecordMgr:getJointAttackDes(record)
    local attackObj1 = FightMgr:getObjectById(record.attacker_id)
    local attackObj2 = FightMgr:getObjectById(record.para)
    local victimObj = FightMgr:getObjectById(record.victim_id)
    if not attackObj1 or not attackObj2 or not victimObj then
        return
            end

    local str1 = self:getObjShowName(attackObj1)
    local str2 = self:getObjShowName(attackObj2)
    local str3 = self:getObjShowName(victimObj)

    return string.format(CHS[7100393], str1, str2, str3) .. string.format(CHS[7190343], CHS[3000007])
end

-- 对自己使用技能,道具
function FightCmdRecordMgr:addFightSelfAction(attackerId, iconPath, headX, headY)
    local attacker = FightMgr:getObjectById(attackerId)
    if not attacker then return end

    local sprite = self:getCmdSprite(iconPath)
    local sz = sprite:getContentSize()
    sprite:setPosition(headX, headY + FIGHT_ICON.ATTACKER_START_Y)
    attacker:addToTopLayer(sprite)

    local pos = gf:getCharTopLayer():convertToNodeSpace(sprite:convertToWorldSpace(cc.p(0, 0)))
    sprite:removeFromParent()
    sprite = self:getCmdSprite(iconPath)
    local startX, startY = pos.x + sz.width * 0.5 * 0.65, pos.y + sz.height * 0.5 * 0.65
    sprite:setPosition(cc.p(startX, startY))
    gf:getCharTopLayer():addChild(sprite, -1, attackerId)
    self.fightCmdSpriteTag[attackerId] = true

    local callfunc = cc.CallFunc:create(function()
        sprite:removeFromParent()
    end)

    local fadeOut = cc.FadeOut:create(0.7)
    local moveUp = cc.MoveTo:create(0.3, cc.p(startX, startY + FIGHT_ICON.ATTACKER_END_Y))
    sprite:runAction(cc.Sequence:create(cc.Spawn:create(fadeOut, moveUp), callfunc))
end

-- 对他人使用技能,道具
function FightCmdRecordMgr:addFightOtherAction(iconPath, attackerId, victimId, headX, headY, victimHeadX, victimHeadY)
    local attacker = FightMgr:getObjectById(attackerId)
    local victimObj = FightMgr:getObjectById(victimId)
    if not attacker or not victimObj then return end

    local sprite = self:getCmdSprite(iconPath)
    local sz = sprite:getContentSize()
    sprite:setPosition(headX, headY + FIGHT_ICON.ATTACKER_START_Y)
    attacker:addToTopLayer(sprite)

    local attackTopPos = gf:getCharTopLayer():convertToNodeSpace(sprite:convertToWorldSpace(cc.p(0, 0)))
    sprite:removeFromParent()
    sprite = self:getCmdSprite(iconPath)
    local attackStartX, attackStartY = attackTopPos.x + sz.width * 0.5 * 0.65, attackTopPos.y + sz.height * 0.5 * 0.65

    sprite:setPosition(victimHeadX, victimHeadY + FIGHT_ICON.ATTACKER_START_Y)
    victimObj:addToTopLayer(sprite)
    local victimTopPos = gf:getCharTopLayer():convertToNodeSpace(sprite:convertToWorldSpace(cc.p(0, 0)))
    local endX, endY = victimTopPos.x + sz.width * 0.5 * 0.65, victimTopPos.y + sz.height * 0.5 * 0.65
    if victimObj.showLife then
        endY = endY + 20
    end

    sprite:removeFromParent()
    sprite = self:getCmdSprite(iconPath)
    sprite:setPosition(cc.p(attackStartX, attackStartY))
    gf:getCharTopLayer():addChild(sprite, -1, attackerId)
    self.fightCmdSpriteTag[attackerId] = true

    local callfunc = cc.CallFunc:create(function()
        -- 到达己方最高点后，飞往目标位置
        local startX, startY = sprite:getPosition()
        local ctrlX, ctrlY = startX + (endX - startX) / 2.0, startY + math.abs(endY - startY) * 1.5

        local bezierCb = cc.CallFunc:create(function()
            sprite:removeFromParent()

            -- 曲线运动完，播放箭头移动
            local arrow = cc.Sprite:create(ResMgr.ui.fight_obj_down_arrow)
            arrow:setAnchorPoint(0.5, 0.5)
            arrow:setPosition(endX, endY + FIGHT_ICON.ARROW_START_Y)

            local spriteId = self:getFightCmdArrowId(attackerId)
            gf:getCharTopLayer():addChild(arrow, -1, spriteId)
            self.fightCmdSpriteTag[spriteId] = true

            local fadeOut = cc.FadeOut:create(1.0)
            local moveDown = cc.MoveTo:create(0.5, cc.p(endX, endY + FIGHT_ICON.ARROW_END_Y))
            arrow:runAction(cc.Sequence:create(cc.Spawn:create(fadeOut, moveDown), cc.RemoveSelf:create()))
        end)

        local bezier = cc.BezierTo:create(0.5, {cc.p(startX, startY), cc.p(ctrlX, ctrlY), cc.p(endX, endY)})
        local fadeOut = cc.FadeOut:create(1.5)
        sprite:runAction(cc.Sequence:create(cc.Spawn:create(fadeOut, bezier), bezierCb))
    end)

    local moveUp = cc.MoveTo:create(0.5, cc.p(attackStartX, attackStartY + FIGHT_ICON.ATTACKER_END_Y))
    sprite:runAction(cc.Sequence:create(moveUp, callfunc))
end

-- 获取战斗指令图标
function FightCmdRecordMgr:getCmdSprite(iconPath)
    local sprite = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    local sz = sprite:getContentSize()
    local itemIcon = cc.Sprite:create(iconPath)
    if not itemIcon then return end
    itemIcon:setPosition(4, 4)
    itemIcon:setAnchorPoint(0, 0)
    itemIcon:setScale(0.69)
    sprite:addChild(itemIcon)
    sprite:setScale(0.65)
    return sprite
end

-- 清除战斗指令资源
function FightCmdRecordMgr:clearFightCmdSprite()
    for k, v in pairs(self.fightCmdSpriteTag) do
        local sprite = gf:getCharTopLayer():getChildByTag(k)
        if sprite then
            sprite:removeFromParent()
        end
    end

    self.fightCmdSpriteTag = {}
end

-- 获取战斗指令箭头id
function FightCmdRecordMgr:getFightCmdArrowId(attackerId)
    return attackerId * 100
end

-- 战斗指令效果：宠物使用部分道具需要被认为是对自己使用，当前服务器认为是Me使用
function FightCmdRecordMgr:isUseItemToSelf(para)
    return FIGHT_USE_TO_SELF[para]
end

-- 选择指令后，播效果
function FightCmdRecordMgr:MSG_SELECT_COMMAND(data)
    if not FightCmdRecordMgr:isRecordMagicOpen() then return end
    if not FightCmdRecordMgr:getFightCmdMagicFlag() then return end

    local attacker = FightMgr:getObjectById(data.attacker_id)
    if not attacker or not attacker.charAction then return end
    local headOffsetX, headOffsetY = attacker.charAction:getHeadOffset()

    if data.action == FIGHT_ACTION.DEFENSE or data.action == FIGHT_ACTION.FLEE
        or data.action == FIGHT_ACTION.SELECT_PET or data.action == FIGHT_ACTION.CALLBACK_PET then
        -- 防御，逃跑，召回宠物，召唤宠物，attacker 自己播效果
        if attacker:isPet() or attacker:isKid() then
            performWithDelay(gf:getUILayer(), function()
                self:addFightSelfAction(data.attacker_id, FIGHT_ACTION_ICON[data.action], headOffsetX, headOffsetY)
            end, FIGHT_PET_ACTION_MAGIC_DELAY)
        else
            self:addFightSelfAction(data.attacker_id, FIGHT_ACTION_ICON[data.action], headOffsetX, headOffsetY)
        end
    elseif data.victim_id == 1 or data.victim_id == 2 or data.victim_id == 3 then
        -- 群体技能，自己播效果
        local iconPath = SkillMgr:getSkillIconPath(data.no)
        if data.action == FIGHT_ACTION.APPLY_ITEM then
            iconPath = ResMgr:getItemIconPath(data.no)
        end
        if attacker:isPet() or attacker:isKid() then
            performWithDelay(gf:getUILayer(), function()
                self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
            end, FIGHT_PET_ACTION_MAGIC_DELAY)
        else
            self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
        end
    else
         -- 对他人使用
        local victim = FightMgr:getObjectById(data.victim_id)
        if not victim or not victim.charAction then return end
        local victimHeadOffsetX, victimHeadOffsetY = victim.charAction:getHeadOffset()

        local iconPath = SkillMgr:getSkillIconPath(data.no)
        if data.action == FIGHT_ACTION.PHYSICAL_ATTACK and data.no == 0 then
            -- 普通攻击
            iconPath = FIGHT_ACTION_ICON[FIGHT_ACTION.PHYSICAL_ATTACK]
        elseif data.action == FIGHT_ACTION.CATCH_PET then
            iconPath = FIGHT_ACTION_ICON[FIGHT_ACTION.CATCH_PET]
        end

        if data.action == FIGHT_ACTION.APPLY_ITEM then
            iconPath = ResMgr:getItemIconPath(data.no)
        end

        if victim == attacker or self:isUseItemToSelf(data.no) then
            -- 对自己使用
            if attacker:isPet() or attacker:isKid() then
                performWithDelay(gf:getUILayer(), function()
                    self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
                end, FIGHT_PET_ACTION_MAGIC_DELAY)
            else
                self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
            end
        else
            if attacker:isPet() or attacker:isKid() then
                performWithDelay(gf:getUILayer(), function()
                    local owner = FightMgr:getObjectById(attacker:queryBasicInt('owner_id'))
                    if owner and owner.auto_fight == 1 or (owner == Me and Me:queryBasicInt("auto_fight") == 1) then
                        -- 自动战斗时自己播放效果
                        self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
                    else
                        self:addFightOtherAction(iconPath, data.attacker_id, data.victim_id, headOffsetX,
                            headOffsetY, victimHeadOffsetX, victimHeadOffsetY)
                    end
                end, FIGHT_PET_ACTION_MAGIC_DELAY)
            else
                if attacker.auto_fight == 1 or (attacker == Me and Me:queryBasicInt("auto_fight") == 1) then
                    -- 自动战斗时自己播放效果
                    self:addFightSelfAction(data.attacker_id, iconPath, headOffsetX, headOffsetY)
                else
                    self:addFightOtherAction(iconPath, data.attacker_id, data.victim_id, headOffsetX,
                        headOffsetY, victimHeadOffsetX, victimHeadOffsetY)
                end
            end
        end
    end
end

-- 通知玩家队友自动战斗开关
function FightCmdRecordMgr:MSG_FRIEND_AUTO_FIGHT_CONFIG(data)
    for i = 1, data.count do
        local fightObj = FightMgr:getObjectById(data[i].id)
        if fightObj then
            fightObj.auto_fight = data[i].auto_fight
        end
    end
end

MessageMgr:regist("MSG_SELECT_COMMAND", FightCmdRecordMgr)
MessageMgr:regist("MSG_FRIEND_AUTO_FIGHT_CONFIG", FightCmdRecordMgr)
MessageMgr:regist("MSG_COMBAT_ACTION_RESULT", FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, FightCmdRecordMgr.onEnterCombat, FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.FIGHT_ADD_FRIEND, FightCmdRecordMgr.onAddFightObj, FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.FIGHT_ADD_OPPONENT, FightCmdRecordMgr.onAddFightObj, FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.SET_FLYWORDS_OR_ACT, FightCmdRecordMgr.onSetFightObjAct, FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.FIGHT_OBJ_ICON_CHANGED, FightCmdRecordMgr.onFightObjIconChanged, FightCmdRecordMgr)
EventDispatcher:addEventListener(EVENT.FIGHT_OPPONENT_SHOW_LIFE, FightCmdRecordMgr.onFightOpponentShowLife, FightCmdRecordMgr)
