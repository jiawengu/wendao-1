-- NewYearGuardMgr.lua
-- Created by haungzz Aug/21/2018
-- 元旦宝物守卫战活动管理器

NewYearGuardMgr = Singleton()

NewYearGuardMgr.monsters = {}
NewYearGuardMgr.treasures = {}
NewYearGuardMgr.skillMagics = {}

-- 怪物信息
local MONSTER_INFO = {
    {icon = 6201, percent = 0.4, life = 1, name = CHS[5400620]}, -- 强盗
    {icon = 6202, percent = 0.4, life = 1, name = CHS[5400621]}, -- 土匪
    {icon = 6230, percent = 0.4, life = 1, name = CHS[5400622]}, -- 海盗
    {icon = 6152, percent = 0.1, life = 2, name = CHS[5400623]}, -- 巨人
    {icon = 6147, percent = 0.1, life = 2, name = CHS[5400624]}, -- 石牛妖
    {icon = 6153, percent = 0.1, life = 2, name = CHS[5400625]}, -- 炼魔
    {icon = 6213, percent = 0.7, life = 1, name = CHS[5400626]}, -- 女飞贼
    {icon = 6149, percent = 0.1, life = 3, name = CHS[5400627]}, -- 蓝毛巨兽
    {icon = 6203, percent = 0.1, life = 3, name = CHS[5400628]}, -- 熊怪
    {icon = 6142, percent = 0.1, life = 5, name = CHS[5400629]}, -- 石魔
    {icon = 6227, percent = 0.1, life = 7, name = CHS[5400630]}, -- 恶灵鬼王
}

-- 不同方向显示法术光效的位置
local SHOW_MAGIC_POS = {
    [1] = {cc.p(79,44), cc.p(75,42), cc.p(71,40)},
    [3] = {cc.p(87,44), cc.p(91,42), cc.p(95,40)},
    [5] = {cc.p(87,48), cc.p(91,50), cc.p(95,52)},
    [7] = {cc.p(79,48), cc.p(75,50), cc.p(71,52)},
}

local MAGIC_SPACE = 0.1  -- 法术播放间隔

-- 怪物不同方向的起始点及终点
local MONSTER_PATH = {
    [1] = {cc.p(71,40), cc.p(79,44)},
    [3] = {cc.p(95,40), cc.p(87,44)},
    [5] = {cc.p(95,52), cc.p(87,48)},
    [7] = {cc.p(71,52), cc.p(79,48)},
}

-- 宝物位置
local TREASURE_POS = {
    [1] = cc.p(81,45),
    [3] = cc.p(85,45),
    [5] = cc.p(85,47),
    [7] = cc.p(81,47)
}

local GAME_TIME = 120 -- 游戏时间

local GAME_STATE = {
    RUNING = 1, -- 
    PAUSE = 2,  -- 暂停
    STOP = 3,   -- 结束
    WAIT = 4,    -- 倒计时或播放结果动画
}

function NewYearGuardMgr:update()
    if self.gameState ~= GAME_STATE.RUNING then
        return
    end

    for i = 1, #self.monsters do
        self.monsters[i]:update()
    end
end

function NewYearGuardMgr:getTotalTime()
    return GAME_TIME
end

function NewYearGuardMgr:createAllTreasure()
    if not gf:getCharMiddleLayer() then
        return
    end

    self:clearAllTreasure()

    -- 加载宝物
    for dir, v in pairs(TREASURE_POS) do
        local img = ccui.ImageView:create(ResMgr:getBigPortrait(ResMgr.icon.baoxiang), ccui.TextureResType.localType)
        img:setPosition(gf:convertToClientSpace(v.x, v.y))
        self.treasures[dir] = img
        gf:getCharMiddleLayer():addChild(img)
    end
end

function NewYearGuardMgr:startGame()
    self.gameStartTime = gfGetTickCount()

    self.curPoint = 0

    self:setGameState(GAME_STATE.RUNING)

    self:clearAllMonster()

    if not gf:getUILayer() then
        return
    end

    if self.gameSch then
        gf:getUILayer():stopAction(self.gameSch)
    end

    local time = 1
    DlgMgr:sendMsg("NewYearGuardDlg", "updateTime", GAME_TIME)
    self.gameSch = schedule(gf:getUILayer(), function()
        local lastTime = GAME_TIME - time
        if lastTime <= 0 then
            -- 守卫成功
            if lastTime == 0 then
                -- 清除所有怪物
                self:attackMonsterByDir(1, true)
                self:attackMonsterByDir(3, true)
                self:attackMonsterByDir(5, true)
                self:attackMonsterByDir(7, true)

                gf:ShowSmallTips(CHS[5400636])

                if self.curPoint < 100 then self.curPoint = 100 end
                DlgMgr:sendMsg("NewYearGuardDlg", "updateScore", self.curPoint)

                self:setGameState(GAME_STATE.WAIT)

                -- 刷新界面显示时间
                DlgMgr:sendMsg("NewYearGuardDlg", "updateTime", lastTime)
            end

            if lastTime == -3 then
                -- 播放烟花特效
                local data = {name = ResMgr.ArmatureMagic.funny_magic.name, action = "Bottom06"}
                gf:createArmatureOnceMagic(data.name, data.action, gf:getTopLayer())
            end

            if lastTime <= -4 then
                -- 显示结算界面
                self:setGameState(GAME_STATE.STOP)
                DlgMgr:sendMsg("NewYearGuardDlg", "showResult", self.curPoint)
                gf:getUILayer():stopAction(self.gameSch)
                self.gameSch = nil
            end

            time = time + 1
            return
        end

        if self.gameState ~= GAME_STATE.RUNING then
            return
        end

        if time <= 30 then
            -- 每两秒加载一只怪
            if time % 2 == 0 then
                self:createChar(time)
            end
        elseif time <= 116 then
            -- 每秒加载一只怪
            self:createChar(time)
        end

        -- 刷新界面显示时间
        DlgMgr:sendMsg("NewYearGuardDlg", "updateTime", lastTime)

        time = time + 1
    end, 1)
end

function NewYearGuardMgr:endGame()
    if self.gameSch and gf:getUILayer() then
        gf:getUILayer():stopAction(self.gameSch)
        self.gameSch = nil
    end

    self:clearAllMonster()

    self:clearAllTreasure()

    self:clearSkillMagic()

    self:setGameState(GAME_STATE.STOP)
end

function NewYearGuardMgr:startCountDown()
    self:setGameState(GAME_STATE.WAIT)
end

function NewYearGuardMgr:gameIsStart()
    if self.gameState == GAME_STATE.WAIT
        or self.gameState == GAME_STATE.RUNING then
        return true
    end
end

function NewYearGuardMgr:setGamePause()
    if self.gameState == GAME_STATE.PAUSE then
        return
    end

    self.curRealState = self.gameState
    self:setGameState(GAME_STATE.PAUSE)
end

function NewYearGuardMgr:setGameResume()
    if not self.curRealState then return end
    self:setGameState(self.curRealState)
end

function NewYearGuardMgr:setGameState(state)
    self.gameState = state

    if state ~= GAME_STATE.PAUSE then
        self.curRealState = state
    end
end

function NewYearGuardMgr:createChar(time)
    local index
    if time == 20 or time == 24 or time == 28 then
        index = 7
    elseif time <= 30 then
        index = math.random(1, 3)
    elseif time == 50 then
        index = 10
    elseif time <= 63 then
        index = math.random(4, 6)
    elseif time == 100 then
        index = 11
    elseif time <= 116 then
        index = math.random(8, 9)
    end

    local dirIndex = math.random(1, 4)
    local dir = dirIndex * 2 - 1
    local path = MONSTER_PATH[dir]
    local info = MONSTER_INFO[index]

    if not info or not path then return end

    local char = require("obj/activityObj/BwswzNpc").new()

    char:absorbBasicFields({
        id = time,
        icon = info.icon,
        name = info.name,
        life = info.life,
        dir = (dir + 4) % 8,
    })

    char:setSeepPrecent((info.percent - 1) * 100)

    char:onEnterScene(path[1].x, path[1].y)

    -- char:setAct(Const.FA_STAND)

    char:setDestPos(path[2])
    char:setEndPos(path[2].x, path[2].y)

    char:addMagicOnWaist(ResMgr.magic.grey_fog, false)

    table.insert(self.monsters, char)
end

-- 怪物获得宝物，守卫失败
function NewYearGuardMgr:monsterGetTreasure(char)
    self:setGameState(GAME_STATE.WAIT)

    -- 停止所有怪物行走
    for _, v in pairs(self.monsters) do
        if v:getId() ~= char:getId() then
            v:setAct(Const.FA_STAND, nil, true)
        end
    end

    -- 停止角色的攻击动作
    Me:setAct(Const.FA_STAND, true)

    -- 宝物被夺，做变淡效果
    local dir = (char:getDir() + 4) % 8
    local treasure = self.treasures[dir]
    if treasure then
        local action = cc.Sequence:create(
            cc.DelayTime:create(1),
            cc.FadeOut:create(1),
            cc.CallFunc:create(function()
                -- 守卫失败
                self:setGameState(GAME_STATE.STOP)
                DlgMgr:sendMsg("NewYearGuardDlg", "showResult", self.curPoint)
            end)
        )

        treasure:runAction(action)
    end
end

function NewYearGuardMgr:gameIsPlaying()
    return self.gameState == GAME_STATE.RUNING
end

-- 攻击某个方向的所有怪物
function NewYearGuardMgr:attackMonsterByDir(dir, forceKill)
    if not dir then return end

    local monsterDir = (dir + 4) % 8  -- 怪物方向与玩家方向相反
    for i = #self.monsters, 1, -1 do
        local char = self.monsters[i]
        local life = char:queryBasicInt("life")
        if char:queryBasicInt("dir") == monsterDir and life > 0 then
            char:doBeAttacked(forceKill)
            if char:queryBasicInt("life") == 0 and not forceKill then
                -- 被打死
                char:showAddPoint(1)
                self.curPoint = self.curPoint + 1
                DlgMgr:sendMsg("NewYearGuardDlg", "updateScore", self.curPoint)
            end
        end
    end

    local polar = Me:queryBasicInt("polar")
    local combatData = BattleSimulatorMgr:getCurCombatData()
    local skillNo = SkillMgr:getSkillNoByPolarAndLadder(polar, SKILL.SUBCLASS_B, SKILL.LADDER_4)
    local skillAttr = SkillMgr:getskillAttrib(skillNo)

    local layer = gf:getCharTopLayer()

    if not skillAttr or not skillAttr.skill_effect or not layer then return end

    -- 在一条线上播放光效，每个光效间隔 0.03
    local index = 1
    local function func()
        local pos = SHOW_MAGIC_POS[dir][index]
        if not pos then
            return
        end
        
        local tag = dir * 10 + index
        if self.skillMagics[tag] then
            self.skillMagics[tag]:removeFromParent()
        end

        local magic = gf:createCallbackMagic(skillAttr.skill_effect.icon, function()
            self.skillMagics[tag]:removeFromParent()
            self.skillMagics[tag] = nil
        end)

        magic:setPosition(gf:convertToClientSpace(pos.x, pos.y))
        if polar == 4 then
            if dir == 3 or dir == 5 then
                magic:setFlipX(true)
            end
        end

        layer:addChild(magic)

        self.skillMagics[tag] = magic

        index = index + 1

        performWithDelay(layer, func, MAGIC_SPACE)
    end

    func()
end

function NewYearGuardMgr:deleteChar(id)
    for i = #self.monsters, 1, -1 do
        if self.monsters[i]:getId() == id then
            self.monsters[i]:cleanup()
            table.remove(self.monsters, i)
        end
    end
end

function NewYearGuardMgr:clearAllMonster()
    for k, v in pairs(self.monsters) do
        if v then
            v:cleanup()
        end
    end

    self.monsters = {}
end

function NewYearGuardMgr:clearAllTreasure()
    -- 移除宝物
    for k, v in pairs(self.treasures) do
        if v then
            v:removeFromParent()
        end
    end

    self.treasures = {}
end

function NewYearGuardMgr:clearSkillMagic()
    -- 移除技能光效
    for k, v in pairs(self.skillMagics) do
        if v then
            v:removeFromParent()
        end
    end

    self.skillMagics = {}
end

function NewYearGuardMgr:MSG_BWSWZ_START_GAME_2019(data)
    local dlg = DlgMgr:openDlg("NewYearGuardDlg")

    dlg:setData(data)
end

MessageMgr:regist("MSG_BWSWZ_START_GAME_2019", NewYearGuardMgr)