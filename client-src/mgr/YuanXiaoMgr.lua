-- YuanXiaoMgr.lua
-- Created by haungzz Dec/07/2017
-- 元宵节活动管理器


YuanXiaoMgr = Singleton()
YuanXiaoMgr.yxDragonChars = {}

function YuanXiaoMgr:clearData()
    self.yxDragonChars = {}
end

function YuanXiaoMgr:isNeedHideChar(char)
    local charId = char:getId()
    if next(self.yxDragonChars)
        and char 
        and (char:getType() == "Player" or (char.owner and char.owner ~= Me))
        and  charId ~= Me:getId()
        and not (TeamMgr:inTeamEx(charId) or (char.owner and TeamMgr:inTeamEx(char.owner:getId()))) then
        local x, y = gf:convertToMapSpace(char.curX, char.curY)
        for k, info in pairs(self.yxDragonChars) do
            local dragonChar = CharMgr:getChar(info.id)
            if dragonChar then
                local charPos = cc.p(gf:convertToMapSpace(dragonChar.curX, dragonChar.curY))
                if charId ~= dragonChar:getId() and math.abs(x - charPos.x) < 4 and math.abs(y - charPos.y) < 4 then
                    return true
                end
            end
        end
    end
end

function YuanXiaoMgr:MSG_APPEAR(map)
    if map.status == Const.NS_YX_STATUS then
        -- 元宵舞龙对象要隐藏旁边的形象
        self.yxDragonChars[map.id] = map
    end
end

function YuanXiaoMgr:MSG_DISAPPEAR(map)
    self.yxDragonChars[map.id] = nil
end

function YuanXiaoMgr:MSG_LANTERN_2018_ACTION(data)
    local char = CharMgr:getChar(data.npc_id)
    if not char then
        return
    end 
    
    if char.middleLayer then
        char.middleLayer:stopAction(char.yxDragonStandDelay)
        char.middleLayer:stopAction(char.yxDragonParryDelay)
        char.yxDragonStandDelay = nil
        char.yxDragonParryDelay = nil
    end
    
    char:setBasic("isFixDir", 1)
    if data.action == "attack" then
        -- 物理攻击
        char:setAct(Const.FA_ACTION_PHYSICAL_ATTACK, function() 
            char:setAct(Const.FA_ACTION_ATTACK_FINISH, function()
                -- 魔法攻击
                char:setAct(Const.FA_ACTION_CAST_MAGIC, function()
                    char:setAct(Const.FA_ACTION_CAST_MAGIC_END, function() 
                        char:setAct(Const.FA_STAND)
                    end)
                end)
            end)
        end)
    elseif data.action == "walk" then
        char:setAct(Const.FA_WALK)
    elseif data.action == "die" then
        if char.faAct ~= Const.FA_DIE_NOW then
            char:setAct(Const.FA_DIE_NOW)
        end
    elseif data.action == "stand" then
        char:setAct(Const.FA_STAND)
    elseif data.action == "defense" then
        char:setAct(Const.FA_ACTION_DEFENSE, function() 
            char:setAct(Const.FA_STAND)
        end)
    elseif data.action == "parry" then
        local function callback()
            -- 循环播放受击动作
            if char.faAct == Const.FA_PARRY_START and char.middleLayer then
                char.yxDragonStandDelay = performWithDelay(char.middleLayer, function() 
                    char:setAct(Const.FA_STAND, callback)
                    char.yxDragonStandDelay = nil
                    char.yxDragonParryDelay = performWithDelay(char.middleLayer, function() 
                        char:setAct(Const.FA_PARRY_START, callback)
                        char.yxDragonParryDelay = nil
                    end , 0.3)
                end , 0.1)
            end
        end

        char:setAct(Const.FA_PARRY_START, callback)
    end
end

MessageMgr:regist("MSG_LANTERN_2018_ACTION", YuanXiaoMgr)

MessageMgr:hook("MSG_APPEAR", YuanXiaoMgr, "YuanXiaoMgr")
MessageMgr:hook("MSG_DISAPPEAR", YuanXiaoMgr, "YuanXiaoMgr")