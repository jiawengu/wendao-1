-- BattleSimulatorMgr.lua
-- created by liuhb May/13/2015
-- 战斗模拟器
-- 目前功能满足新手开场,有其他需求,可自行拓展

BattleSimulatorMgr = Singleton()
BattleSimulatorMgr.COMBAT_STATE = {
    NONE                = 0,
    START               = 1,
    PREPARE             = 2,
    WAIT                = 3,
    ROUNDING            = 4,
    WAIT_ANIMATION_END  = 5,
    END                 = 6,
    PLAY_DRAMA          = 7,
    PLAY_DRAMA_DOING    = 8,
}

local COMBAT_MSG = {
    ["MSG_C_ACCEPTED_COMMAND"]   = 0x0203,
    ["MSG_C_FLEE"]               = 0x2207,
    ["MSG_C_CATCH_PET"]          = 0x3209,
    ["MSG_C_START_COMBAT"]       = 0x0DFF,
    ["MSG_C_END_COMBAT"]         = 0x0DFD,
    ["MSG_C_FRIENDS"]            = 0xFDFB,
    ["MSG_C_OPPONENTS"]          = 0xFDF9,
    ["MSG_C_ACTION"]             = 0x4DF7,
    ["MSG_C_CHAR_DIED"]          = 0x1DF5,
    ["MSG_C_CHAR_REVIVE"]        = 0x1DF3,
    ["MSG_C_LIFE_DELTA"]         = 0x3DF1,
    ["MSG_C_MANA_DELTA"]         = 0x3DEF,
    ["MSG_C_UPDATE_STATUS"]      = 0x2DED,
    ["MSG_C_WAIT_COMMAND"]       = 0x1DEB,
    ["MSG_C_ACCEPT_HIT"]         = 0x4DE9,
    ["MSG_C_END_ACTION"]         = 0x1DE7,
    ["MSG_C_QUIT_COMBAT"]        = 0x1DE5,
    ["MSG_C_ADD_FRIEND"]         = 0xFDE3,
    ["MSG_C_ADD_OPPONENT"]       = 0xFDE1,
    ["MSG_C_UPDATE_IMPROVEMENT"] = 0xFDDF,
    ["MSG_C_UPDATE_APPEARANCE"]  = 0xF0FF,
    ["MSG_C_ACCEPT_MAGIC_HIT"]   = 0xFDDD,
    ["MSG_C_LEAVE_AT_ONCE"]      = 0x1DDB,
    ["MSG_C_MESSAGE"]            = 0x3DD9,
    ["MSG_C_DIALOG_OK"]          = 0x1DD7,
    ["MSG_C_UPDATE"]             = 0xFDD5,
    ["MSG_C_COMMAND_ACCEPTED"]   = 0x2DD3,
    ["MSG_SYNC_MESSAGE"]         = 0xFDD1,
    ["MSG_C_MENU_LIST"]          = 0x3DCF,
    ["MSG_C_MENU_SELECTED"]      = 0x2DCD,
    ["MSG_C_REFRESH_PET_LIST"]   = 0xFDCB,
    ["MSG_C_DELAY"]              = 0x2DC9,
    ["MSG_C_LIGHT_EFFECT"]       = 0x2DC7,
    ["MSG_C_WAIT_ALL_END"]       = 0x0DC5,
    ["MSG_C_START_SEQUENCE"]     = 0x2DC3,
    ["MSG_C_SANDGLASS"]          = 0x2DC1,
    ["MSG_C_CHAR_OFFLINE"]       = 0x2DBF,
    ["MSG_C_OPPONENT_INFO"]      = 0xFDBD,
    ["MSG_C_BATTLE_ARRAY"]       = 0xFDBB,
    ["MSG_C_SET_FIGHT_PET"]      = 0xFDB1,
    ["MSG_C_SET_CUSTOM_MSG"]     = 0xFDB3,
    ["MSG_MESSAGE"]              = 0x2FFF,
    ["MSG_SYNC_MESSAGE"]         = 0xFDD1,
    ["MSG_PLAY_INSTRUCTION"]     = 0xA005,
    ["MSG_PLAY_SCENARIOD"]       = 0xB000,
    ["MSG_ATTACH_SKILL_LIGHT_EFFECT"] = 0x2EFC,
}

local SKILL_LIGHT_EFFECT_TYPE = {
    [8013] = 1,  -- 番天印
    [8015] = 0,  -- 定海珠
    [8016] = 0,  -- 混元金斗
}

-- 相性到技能 class 的映射表
local POLAR2CLASS = {
    [POLAR.METAL]   = SKILL.CLASS_METAL,
    [POLAR.WOOD]    = SKILL.CLASS_WOOD,
    [POLAR.WATER]   = SKILL.CLASS_WATER,
    [POLAR.FIRE]    = SKILL.CLASS_FIRE,
    [POLAR.EARTH]   = SKILL.CLASS_EARTH,
}

BattleSimulatorMgr.NEWCOMBAT_ME_ID = 13

local curState = BattleSimulatorMgr.COMBAT_STATE.NONE
local curCombat = {}
local curIndex = 0
local curStep = {}
local curBk = nil

-- 设置战斗背景
function BattleSimulatorMgr:setBattleMap(index)
    if not curCombat.mapInfo then return end

    local MapClass = require "obj/Map"
    local map = MapClass.new(curCombat.mapInfo[index].mapId, true)
    local mapContentSize = map:getContentSize()
    map:setCurMapPos(curCombat.mapInfo[index].x * Const.RAW_PANE_WIDTH, mapContentSize.height - curCombat.mapInfo[index].y * Const.RAW_PANE_HEIGHT, true)
    map:loadBlocksByPos(true, curCombat.mapInfo[index].x, curCombat.mapInfo[index].y)
    gf:getMapBgLayer():addChild(map)
end

-- 预加载资源
function BattleSimulatorMgr:loadMagic(effectArr)
    if nil == effectArr then return end

    for i = 1, #effectArr do
        local skillAttr = SkillMgr:getskillAttrib(effectArr[i])
        if skillAttr then
            if skillAttr.skill_effect.type ~= "armature" and skillAttr.skill_effect.type_ex ~= "armature" then -- 骨骼资源动画不先预加载
                local func = cc.CallFunc:create(function() self:loadOneMagic(skillAttr.skill_effect.icon) end)
                gf:getUILayer():runAction(cc.Sequence:create(cc.DelayTime:create(0.3 * i), func))
            end
        end
    end
end

-- 加载一个光效资源
function BattleSimulatorMgr:loadOneMagic(icon)
    if nil == icon or "number" ~= type(icon) then return end

    AnimationMgr:getMagicAnimation(icon, MAGIC_TYPE.NORMAL, SkillEffectMgr:getMagicScale(icon))
end

-- 获取所有的光效资源
function BattleSimulatorMgr:getAllMagicIcon(combat)
    if nil ~= combat then
        curCombat = combat
    end

    if nil == curCombat then
        return {}
    end

    local magicIconArr = {}
    for k, v in pairs(curCombat) do
        if "table" == type(v) and nil ~= v.effect then
            for i = 1, #v.effect do
                local skillAttr = SkillMgr:getskillAttrib(v.effect[i])
                if skillAttr and skillAttr.skill_effect.type ~= "armature" and skillAttr.skill_effect.type_ex ~= "armature" then
                    table.insert(magicIconArr, skillAttr.skill_effect.icon)
                end
            end
        end
    end

    return magicIconArr
end

-- 移除战斗背景
function BattleSimulatorMgr:removeBattleMap()
    if curBk ~= nil then
        curBk:removeFromParent(true)
    end

    curBk = nil
end

-- 开始一场模拟战斗
function BattleSimulatorMgr:startOneBattleSimulator(combat)
    if nil == combat then return end

    -- 缓存战斗模版
    curCombat = combat

    -- 初始化战斗背景
    self:setBattleMap(curCombat.mapIndex)
    self:sendBattleSimulatorMsgToClient("MSG_C_START_COMBAT", {flag = 1})

    -- 创建最顶层，指引未开始截获点击事件
    if not self.blank then
        self.blank = ccui.Layout:create()
    end

    self.blank:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    local listener = cc.EventListenerTouchOneByOne:create()

    gf:frozenScreen(0.6, 0)

    -- 起模拟器定时器
    if nil ~= BattleSimulatorMgr.scheduleId then
        gf:Unschedule(BattleSimulatorMgr.scheduleId)
        BattleSimulatorMgr.scheduleId = nil
    end

    BattleSimulatorMgr.scheduleId = gf:Schedule(function(dt) BattleSimulatorMgr:updateBattleSimulator(dt) end)
    curState = BattleSimulatorMgr.COMBAT_STATE.START
end

-- 结束一场战斗
function BattleSimulatorMgr:endOneBattleSimulator()
    self:sendBattleSimulatorMsgToClient("MSG_C_END_COMBAT", {flag = 1})
    BattleSimulatorMgr:beginOneAction(13, 99, 3, 0)
    BattleSimulatorMgr:endOneAction(13)

    if BattleSimulatorMgr.endBattleFunc and type(BattleSimulatorMgr.endBattleFunc) == "function" then
        BattleSimulatorMgr.endBattleFunc(curCombat)
    end
end

-- 清除所有数据
function BattleSimulatorMgr:cleanup()
    if self.blank then
        gf:getUILayer():removeChild(self.blank)
        self.blank = nil
    end

    if nil ~= BattleSimulatorMgr.scheduleId then
        gf:Unschedule(BattleSimulatorMgr.scheduleId)
        BattleSimulatorMgr.scheduleId = nil
    end

    curState = BattleSimulatorMgr.COMBAT_STATE.NONE
    curCombat = {}
    curIndex = 0
    curStep = {}
    BattleSimulatorMgr.endBattleFunc = nil

    BattleSimulatorMgr:removeBattleMap()
    if self.layer then
        gf:getUILayer():removeChild(self.layer)
        self.layer = nil
    end

    DlgMgr:closeDlg("DramaDlg")
    
    if Me:getLevel() <= 1 then
        FightMgr:clearFastSkillData()
    end
end

-- 设置出场人物及属性
function BattleSimulatorMgr:setBattleChar()
    BattleSimulatorMgr:setOpponents()
    BattleSimulatorMgr:setFriends()

    curState = BattleSimulatorMgr.COMBAT_STATE.WAIT
end

-- 设置敌方人物
function BattleSimulatorMgr:setOpponents()
    if not curCombat.opponents then
        curState = BattleSimulatorMgr.COMBAT_STATE.END
        return
    end

    local data = gf:deepCopy(curCombat.opponents)
    data.count = #curCombat.opponents

    self:sendBattleSimulatorMsgToClient("MSG_C_OPPONENTS", data)
end

-- 设置己方人物
function BattleSimulatorMgr:setFriends()
    if not curCombat.friends then
        curState = BattleSimulatorMgr.COMBAT_STATE.END
        return
    end

    local data = gf:deepCopy(curCombat.friends)
    data.count = #curCombat.friends

    self:sendBattleSimulatorMsgToClient("MSG_C_FRIENDS", data)
end

-- 状态检测
function BattleSimulatorMgr:updateBattleSimulator(dt)
    if curState == BattleSimulatorMgr.COMBAT_STATE.NONE then
        -- 空状态
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.START then
        -- 战斗开始，添加角色
        BattleSimulatorMgr:setBattleChar()
        curState = BattleSimulatorMgr.COMBAT_STATE.PREPARE
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.PREPARE then
        -- 获取当前播放的回合
        curIndex = curIndex + 1
        curStep = curCombat[curIndex]

        if nil == curStep then
            curState = BattleSimulatorMgr.COMBAT_STATE.END
            return
        end

        if 0 == curStep.round then
            -- 此处应该处理播放剧本
            curState = BattleSimulatorMgr.COMBAT_STATE.PLAY_DRAMA
            return
        end

        local data = {}
        data.menu = 0
        data.id = 13
        data.time = 99
        data.question = 0
        data.round = curStep.round
        data.curTime = gf:getServerTime()
        BattleSimulatorMgr:sendBattleSimulatorMsgToClient("MSG_C_WAIT_COMMAND", data)

        -- 看看有没有指引可以播放
        if nil ~= curStep.prepare then
            -- 直接发送指引即可,因为下面该输入了
            DlgMgr:closeDlg("DramaDlg")
            self:sendBattleSimulatorMsgToClient("MSG_PLAY_INSTRUCTION", {guideId = curStep.prepare.guideId})
        end

        curState = BattleSimulatorMgr.COMBAT_STATE.WAIT

        -- 加载光效
        BattleSimulatorMgr:loadMagic(curStep.effect)
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.WAIT then
        -- 等待命令输入
        -- 暂时为空，如果需要根据输入的命令进行处理，则需要处理此处

    elseif curState == BattleSimulatorMgr.COMBAT_STATE.ROUNDING then
        -- 开始播放下一回合既定的消息
        if 0 ~= BattleSimulatorMgr:playNextRound() then
            curState = BattleSimulatorMgr.COMBAT_STATE.WAIT_ANIMATION_END
            return
        end

        curState = BattleSimulatorMgr.COMBAT_STATE.END
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.END then
        -- 战斗结束
        local uiLayer = gf:getUILayer()
        self.layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
        self.layer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
        self.layer:setOpacity(0)
        self.layer:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), cc.CallFunc:create(function() BattleSimulatorMgr:endOneBattleSimulator() end)))
        uiLayer:addChild(self.layer)

        curState = BattleSimulatorMgr.COMBAT_STATE.NONE
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.WAIT_ANIMATION_END then
        -- 等待动画结束
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.PLAY_DRAMA then
        -- 此处应该开始播放剧本
        if BattleSimulatorMgr:playNextDrame() then
            curState = BattleSimulatorMgr.COMBAT_STATE.PLAY_DRAMA_DOING
            return
        end

        curState = BattleSimulatorMgr.COMBAT_STATE.PREPARE
    elseif curState == BattleSimulatorMgr.COMBAT_STATE.PLAY_DRAMA_DOING then
        -- 正在播放剧本
    end
end

-- 播放这一幕剧本
function BattleSimulatorMgr:playNextDrame()
    local sceneData = curStep[curStep.curIndex]
    curStep.curIndex = curStep.curIndex + 1
    if sceneData then
        local char = BattleSimulatorMgr:getObjById(sceneData.id)
        local data = {}
        data.id = char.id
        data.name = char.name
        data.portrait = char.icon
        data.pic_no = char.icon
        data.content = sceneData.content
        data.isComplete = 0
        data.isInCombat = Me:isInCombat() and 1 or 0

        self:sendBattleSimulatorMsgToClient("MSG_PLAY_SCENARIOD", data)
        return true
    else
        local data = {}
        data.id = 0
        data.name = ""
        data.portrait = 0
        data.pic_no = 0
        data.content = ""
        data.isComplete = 1
        data.isInCombat = Me:isInCombat() and 1 or 0

        self:sendBattleSimulatorMsgToClient("MSG_PLAY_SCENARIOD", data)
        return false
    end

    -- 没有剧本了，返回
    return nil
end

-- 播放下一回合
function BattleSimulatorMgr:playNextRound()
    for i = 1, #curStep.actions do
        local action = curStep.actions[i]
        if nil ~= action then

            if action.tip then
                local friend = BattleSimulatorMgr:getObjById(action.charId)
                if friend then
                    local syncMsg = {sync_msg = 0x2FFF, key = MessageMgr:addSyncMsg({MSG = 0x2FFF, channel = 1, id = friend.id, name = friend.name, icon = friend.icon, msg = self:parserMsg(friend.id, action.tip, action.para), time = os.time(), privilege = 0, server_name = "BattleSimulator", show_extra = 1})}
                    self:sendBattleSimulatorMsgToClient("MSG_SYNC_MESSAGE", syncMsg)

               --[[     if action.charId < 10 then
                        local msg = { sync_msg = 0x2FFF, key = MessageMgr:addSyncMsg({MSG = 0x2FFF, id = 0, show_extra = 1, msg = self:parserMsg(friend.id, action.tip, action.para), privilege = 0, channel = 2, time = os.time(), name = friend.name, server_name = "BattleSimulator"})}
                        self:sendBattleSimulatorMsgToClient("MSG_SYNC_MESSAGE", msg)
                    else
                        local msg = { sync_msg = 0x2FFF, key = MessageMgr:addSyncMsg({MSG = 0x2FFF, id = 0, show_extra = 1, msg = self:parserMsg(friend.id, action.tip, action.para), privilege = 0, channel = 4, time = os.time(), name = friend.name, server_name = "BattleSimulator"})}
                        self:sendBattleSimulatorMsgToClient("MSG_SYNC_MESSAGE", msg)
                    end]]
                end
            end

            BattleSimulatorMgr:beginOneAction(action.charId, action.op, action.opId, BattleSimulatorMgr:getSkillNo(action.charId, action.skill))
            for j = 1, #action do
                if nil ~= action[j] then
                    local msg = ""
                    if 2 == action[j].type then
                        -- 法术攻击
                        local hitData = {
                                id  = action[j][1].id,
                                damage_type = action[j][1].damage_type,
                                para = 0,
                                hitter_id = action[j][1].hitter_id,
                                missed = action[j][1].missed,
                                para_ex = 0,
                        }

                        if action.skill == CHS[3003926] then
                            hitData.damage_type = 1
                        end

                        self:sendBattleSimulatorMsgToClient("MSG_C_ACCEPT_HIT", hitData)
                        self:sendBattleSimulatorMsgToClient("MSG_C_ACCEPT_MAGIC_HIT", action[j])
                    elseif 3 == action[j].type then
                        -- 掉血
                        self:sendBattleSimulatorMsgToClient("MSG_C_LIFE_DELTA", action[j])

                        -- 更新状态
                        local friend = curCombat.friends[action[j].id - 10]
                        if friend then
                            -- 只更新己方的状态
                            friend.life = friend.life + action[j].point
                            local updateData = {id = action[j].id, life = friend.life,}
                            self:sendBattleSimulatorMsgToClient("MSG_C_UPDATE", updateData)
                        end
                    elseif 4 == action[j].type then
                        -- 死亡
                        self:sendBattleSimulatorMsgToClient("MSG_C_CHAR_DIED", action[j])
                    elseif 5 == action[j].type then
                        -- 补充气血
                        local effect = { id = action[j].id, no = 1002, owner_id = action[j].hitter_id }
                        self:sendBattleSimulatorMsgToClient("MSG_C_LIGHT_EFFECT", effect)
                        self:sendBattleSimulatorMsgToClient("MSG_C_LIFE_DELTA", action[j])

                        -- 更新状态
                        local friend = curCombat.friends[action[j].id - 10]
                        if friend then
                            -- 只更新己方的状态
                            friend.life = friend.life + action[j].point
                            local updateData = {id = action[j].id, life = friend.life,}
                            self:sendBattleSimulatorMsgToClient("MSG_C_UPDATE", updateData)
                        end
                    elseif 6 == action[j].type then
                        -- 更新角色

                    elseif 7 == action[j].type then
                        -- 更新法力
                        -- self:sendBattleSimulatorMsgToClient("MSG_C_MANA_DELTA", action[j])

                        -- 更新状态
                        local friend = curCombat.friends[action[j].id - 10]
                        if friend then
                            -- 只更新己方的状态
                            friend.mana = friend.mana + action[j].point
                            local updateData = {id = action[j].id, mana = friend.mana,}
                            self:sendBattleSimulatorMsgToClient("MSG_C_UPDATE", updateData)
                        end
                    elseif 8 == action[j].type then
                        -- 播放光效
                        self:sendBattleSimulatorMsgToClient("MSG_C_LIGHT_EFFECT", action[j])
                    elseif 9 == action[j].type then
                        -- 退出战斗
                        self:sendBattleSimulatorMsgToClient("MSG_C_QUIT_COMBAT", action[j])
                    elseif 10 == action[j].type then
                        -- 逃跑
                        self:sendBattleSimulatorMsgToClient("MSG_C_FLEE", action[j])
                    elseif 11 == action[j].type then
                        -- 复活
                        self:sendBattleSimulatorMsgToClient("MSG_C_CHAR_REVIVE", action[j])
                    elseif 12 == action[j].type then
                        -- 播放技能附加光效
                        action[j].type = SKILL_LIGHT_EFFECT_TYPE[action[j].effect_no]
                        self:sendBattleSimulatorMsgToClient("MSG_ATTACH_SKILL_LIGHT_EFFECT", action[j])
                    end
                end
            end

            BattleSimulatorMgr:endOneAction(action.charId)
        end
    end

    if curIndex >= #curCombat then
        return 0
    end

    return 1
end

-- 动作开始
function BattleSimulatorMgr:beginOneAction(attackerId, action, victimId, para)
    local data = {}
    data.round = 0
    data.attacker_id = attackerId
    data.action = action
    data.victim_id = victimId
    data.para = para

    BattleSimulatorMgr:sendBattleSimulatorMsgToClient("MSG_C_ACTION", data)
end

-- 动作结束
function BattleSimulatorMgr:endOneAction(attackerId)
    local data = {}
    data.id = attackerId

    BattleSimulatorMgr:sendBattleSimulatorMsgToClient("MSG_C_END_ACTION", data)
end

-- 模拟发送战斗消息给客户端
function BattleSimulatorMgr:sendBattleSimulatorMsgToClient(msg, data)
    local combatMsgNo = COMBAT_MSG[msg]
    if nil == combatMsgNo then
        Log:D("<<<<<<<BattleSimulatorMgr>>>>>>> No such msg in COMBAT_MSG!")
        return
    end

    local map = data
    map.MSG = combatMsgNo
    MessageMgr:pushMsg(map)
    gf:PrintMap(data)
    Log:D("<<<<<<<BattleSimulatorMgr>>>>>>> [Simulator]Push msg[" .. msg .. "] to Combat!")
end

-- 发送播放下一回合信号
function BattleSimulatorMgr:sendCombatDoActionToBattleSimulator(msg, data)
    if msg == "CMD_C_END_ANIMATE" then
        if BattleSimulatorMgr.COMBAT_STATE.NONE == curState then
            BattleSimulatorMgr:cleanup()
        else
            curState = BattleSimulatorMgr.COMBAT_STATE.PREPARE
        end
    elseif msg == "CMD_OPER_SCENARIOD" and data.type == 1 then
        curState = BattleSimulatorMgr.COMBAT_STATE.PLAY_DRAMA
    else
        curState = BattleSimulatorMgr.COMBAT_STATE.ROUNDING
    end
    gf:PrintMap(data)
    Log:D("<<<<<<<BattleSimulatorMgr>>>>>>> [Combat]Push msg[" .. msg .. "] to Simulator!")

end

function BattleSimulatorMgr:isRunning()
    return BattleSimulatorMgr.scheduleId
end

-- 解析技能
function BattleSimulatorMgr:getSkillNo(charId, skill)
    -- to do
    local friend = BattleSimulatorMgr:getObjById(charId)
    local polar = friend.polar
    local skillNo = nil

    if "B3" == skill then
        skillNo = SkillMgr:getSkillNoByClassAndLadder(POLAR2CLASS[polar], SKILL.SUBCLASS_B, SKILL.LADDER_3)
    elseif "B4" == skill then
        skillNo = SkillMgr:getSkillNoByClassAndLadder(POLAR2CLASS[polar], SKILL.SUBCLASS_B, SKILL.LADDER_4)
    elseif "B5" == skill then
        skillNo = SkillMgr:getSkillNoByClassAndLadder(POLAR2CLASS[polar], SKILL.SUBCLASS_B, SKILL.LADDER_5)    
    elseif CHS[3003926] == skill then
        local skillAttr = SkillMgr:getskillAttribByName(skill)
        skillNo = skillAttr.skill_no
    else
        return 0, ""
    end

    return skillNo, SkillMgr:getSkillName(skillNo)
end

function BattleSimulatorMgr:parserMsg(charId, tip, para)
    if para == nil or "" == para then
        return tip
    end

    local skill = string.match(para,"<(.*)>")
    if skill then
        local _, skillName = BattleSimulatorMgr:getSkillNo(charId, skill)
        return string.format(tip, skillName)
    end

    local char = string.match(para, "{(.+)}")
    if char then
        local charId = tonumber(char)
        local friend = BattleSimulatorMgr:getObjById(charId)
        return string.format(tip, friend.name)
    end

    return string.format(tip, para)
end

function BattleSimulatorMgr:getCurCombatData()
    return curCombat
end

function BattleSimulatorMgr:getSkillList(subclass)
    local skills = {}
    local polar = curCombat.polar -- Me:queryBasicInt("polar")
    local combatData = BattleSimulatorMgr:getCurCombatData()
    for i = 1, #combatData.skills do
        if "B1" == combatData.skills[i] then
            local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_1)
            local skillAttr = SkillMgr:getskillAttrib(skillNo)
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {no = skillNo, ladder = SKILL.LADDER_1, level = 80})
            end
        elseif "B2" == combatData.skills[i] then
            local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_2)
            local skillAttr = SkillMgr:getskillAttrib(skillNo)
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {no = skillNo, ladder = SKILL.LADDER_2, level = 80})
            end
        elseif "B3" == combatData.skills[i] then
            local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_3)
            local skillAttr = SkillMgr:getskillAttrib(skillNo)
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {no = skillNo, ladder = SKILL.LADDER_3, level = 80})
            end
        elseif "B4" == combatData.skills[i] then
            local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_4)
            local skillAttr = SkillMgr:getskillAttrib(skillNo)
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {no = skillNo, ladder = SKILL.LADDER_4, level = 80})
            end
        elseif "B5" == combatData.skills[i] then
            local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_5)
            local skillAttr = SkillMgr:getskillAttrib(skillNo)
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {no = skillNo, ladder = SKILL.LADDER_5, level = 100})
            end
        elseif CHS[3003926] == combatData.skills[i] then
            local skillAttr = SkillMgr:getskillAttribByName(CHS[3003926])
            if subclass == skillAttr.skill_subclass then
                table.insert(skills, {name = CHS[3003926], no = skillAttr.skill_no, ladder = skillAttr.skill_ladder, level = 80})
            end
        end
    end

    return skills
end

function BattleSimulatorMgr:getSkillCmdDesc(skillNo)
    local combatData = BattleSimulatorMgr:getCurCombatData()
    local skillInfo = SkillMgr:getskillAttrib(skillNo)
    local skillType = ""
    if skillInfo["skill_subclass"] == SKILL.SUBCLASS_B then
        skillType = "B"
    elseif skillInfo["skill_subclass"] == SKILL.SUBCLASS_C then
        skillType = "C"
    elseif skillInfo["skill_subclass"] == SKILL.SUBCLASS_C then
        skillType = "D"
    else
        return combatData.skillCmdDesc[skillInfo.name]
    end

    if skillInfo["skill_ladder"] == SKILL.LADDER_1 then
        skillType = skillType .. "1"
    elseif skillInfo["skill_ladder"] == SKILL.LADDER_2 then
        skillType = skillType .. "2"
    elseif skillInfo["skill_ladder"] == SKILL.LADDER_3 then
        skillType = skillType .. "3"
    elseif skillInfo["skill_ladder"] == SKILL.LADDER_4 then
        skillType = skillType .. "4"
    elseif skillInfo["skill_ladder"] == SKILL.LADDER_5 then
        skillType = skillType .. "5"
    end

    return combatData.skillCmdDesc[skillType]
end

function BattleSimulatorMgr:getObjById(objId)
    local obj = nil
    for k, v in pairs(curCombat.opponents) do
        if v.id == objId then
            return v
        end
    end

    for k, v in pairs(curCombat.friends) do
        if v.id == objId then
            return v
        end
    end
end

function BattleSimulatorMgr:registerEndBattleFunc(func)
    if "function" == type(func) then
        BattleSimulatorMgr.endBattleFunc = func
    end
end

-- 新手开场战斗
function BattleSimulatorMgr:newOneWelcome(polar, name, icon)
    local data = require("cfg/NewComerCombat")
    local deam = gf:deepCopy(data)
    -- local polar = Me:queryBasicInt("polar")
    -- local name = Me:queryBasic("name")

    -- 将主角摆到第三个位置上
    local temp = gf:deepCopy(deam.friends[polar])
    deam.friends[polar].icon = deam.friends[3].icon
    deam.friends[polar].org_icon = deam.friends[3].org_icon
    deam.friends[polar].polar = deam.friends[3].polar
    deam.friends[polar].name = deam.friends[3].name
    deam.friends[polar].weapon_icon = deam.friends[3].weapon_icon
    deam.friends[polar].suit_icon = deam.friends[3].suit_icon

    deam.friends[3].icon = icon
    deam.friends[3].org_icon = icon
    deam.friends[3].polar = temp.polar
    deam.friends[3].name = name
    deam.friends[3].weapon_icon = temp.weapon_icon
    deam.friends[3].suit_icon = temp.suit_icon

    deam.mapIndex = polar
    deam.polar = polar
    
    for i = 1, 5 do
        if i ~= 3 then -- 自己不随机性别
            local index = math.random(1, 2)
            local icon = deam.friends[i].icon[index]
            deam.friends[i].icon = icon
            deam.friends[i].org_icon = icon
        end
    end

    -- 在开始的时候进行清除之前的残余数据
    BattleSimulatorMgr:cleanup()
    BattleSimulatorMgr:startOneBattleSimulator(deam)
end

