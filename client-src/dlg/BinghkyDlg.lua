-- BinghkyDlg.lua
-- Created by lixh Jan/17/2019
-- 2019暑假活动冰火考验界面

local BinghkyDlg = Singleton("BinghkyDlg", Dialog)
local Npc = require("obj/Npc")
local LIGHT_EFFECT = require("cfg/LightEffect")

-- 倒计时时间
local COUNT_DOWN_TIME = 5

-- 玩家活动范围
local GAME_AREA = {
    {x = 612, y = 0},
    {x = 450, y = 84},
    {x = 450, y = 335},
    {x = 630, y = 460},
    {x = 1050, y = 460},
    {x = 1250, y = 335},
    {x = 1236, y = 84},
    {x = 1068, y = 0},
}

-- 游戏中心范围直径
local GAME_AREA_LENTH = math.ceil(math.sqrt((1236 - 450) * (1236 - 450) + 460 * 460))

-- 神将信息配置
local MAP_NPC_CFG = {
    {id = 100, icon = 06223, x = 17, y = 31, dir = 3, effPos = GAME_AREA[2]},
    {id = 200, icon = 06223, x = 16, y = 19, dir = 5, effPos = GAME_AREA[3]},
    {id = 300, icon = 06223, x = 25, y = 13, dir = 5, effPos = GAME_AREA[4]},
    {id = 400, icon = 06223, x = 44, y = 13, dir = 7, effPos = GAME_AREA[5]},
    {id = 500, icon = 06223, x = 53, y = 19, dir = 7, effPos = GAME_AREA[6]},
    {id = 600, icon = 06223, x = 51, y = 31, dir = 1, effPos = GAME_AREA[7]},
}

-- 玩家被攻击半径 8 格
local TARGET_ATTACK_RADIUS = 8 * 24

-- 玩家被攻击状态
local ATTACKED_STATUS = {
    NONE = 0, -- 无
    FIRE = 1, -- 火攻
    ICE = 2,  -- 冰攻
}

-- 玩家被火球击中后的透明度
local FIRE_ATTACK_OPACITY = 50

-- 游戏开始玩家的位置
local GAME_SIGHT_POS = cc.p(35, 24)

-- 玩家被冰球名中后的减速
local ICE_ATTACK_SPEED = -50

function BinghkyDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel", nil, true)

    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("QuitButton", self.onQuitButton)

    self.infoPanel = self:getControl("InfoPanel")

    self.mapNpc = {}
    self.npcAttackEff = {}
    self.npcAttackEffTime = {}

    -- 地图上创建神将
    self:bornMapNpc()

    self:resetGame()

    self:hookMsg("MSG_ENTER_ROOM")
end

-- 设置服务器数据
function BinghkyDlg:setData(data)
    self.resultData = data
end

-- 重置游戏
function BinghkyDlg:resetGame()
    -- 先设置lastMapPos，防止限制加速器把me拉回去
    Me:setLastMapPos(GAME_SIGHT_POS.x, GAME_SIGHT_POS.y)

    -- 重置Me的位置
    Me:setPos(gf:convertToClientSpace(GAME_SIGHT_POS.x, GAME_SIGHT_POS.y))

    -- 隐藏结算信息
    self:setResultInfo(false)

    -- 初始化血条
    self.life = 3
    self:setLifePanel()

    -- 初始化行走速度
    Me:setSeepPrecentByClient(0)

    -- 游戏时间
    self.gameingTime = 0
    self:refreshGamingTime()

    -- 游戏开始倒计时
    self.infoPanel:setVisible(false)
    gf:startCountDowm(COUNT_DOWN_TIME + gf:getServerTime(), "start", function()
        local dlg = DlgMgr.dlgs["BinghkyDlg"]
        if dlg then
            self:startGame()
            self.infoPanel:setVisible(true)
        end
    end)

    -- 清空npc攻击效果
    self:clearNpcAttackEff()
end

-- 开始游戏
function BinghkyDlg:startGame()
    -- Me身上增加碰撞检测物体
    self:setMeCheckKnockItem()

    self:stopSchedule(self.timeScheduleId)
    self.timeScheduleId = self:startSchedule(function()
        self.gameingTime = self.gameingTime + 1
        self:refreshGamingTime()
    end, 1)

    self:playNpcCaseAction()

    self:stopSchedule(self.tickScheduleId)
    self.tickScheduleId = self:startSchedule(function()
        self:checkAttackEff()
    end, 0)
end

-- 结束游戏
function BinghkyDlg:endGame()
    -- 停止定时器
    self:stopSchedule(self.timeScheduleId)
    self.timeScheduleId = nil
    self:stopSchedule(self.tickScheduleId)
    self.tickScheduleId = nil

    -- 清除冰球火球攻击效果
    self:clearNpcAttackEff()

    -- 恢复神将动作
    self:playNpcCaseAction(true)

    -- 恢复Me行走速度
    Me:setSeepPrecentByClient(nil)

    -- 显示结算信息
    self:setResultInfo(true)
end

-- 检查攻击效果
function BinghkyDlg:checkAttackEff()
    for k, v in pairs(self.npcAttackEff) do
        if 'boolean' == type(v) then
            -- 就绪状态，创建攻击效果
            local curTick = gfGetTickCount()
            if not self.npcAttackEffTime[k] or curTick - self.npcAttackEffTime[k] > 1000 then
                self.npcAttackEff[k] = self:createAttackEff(k)
                self.npcAttackEffTime[k] = curTick

                -- 播放攻击效果时，npc播放施法动作
                self:doNpcCastMagic(k)
            end
        else
            if not v.bottomLayer then return end
            v:updatePos()

            -- 已经创建效果，检查是否攻击到玩家，检查是否达到边界
            local attackedMe = self:checkMeAttacked(v)
            local inGameArea = self:isInGameArea(cc.p(v.curX, v.curY))
            if attackedMe then
                if v.type == ATTACKED_STATUS.FIRE then
                    self:setMeFireStatus()
                elseif v.type == ATTACKED_STATUS.ICE then
                    self:setMeIceStatus()
                end

                -- 命中玩家，消失
                v:cleanup()
                self.npcAttackEff[k] = true
            else
                -- 未攻击到Me
                if inGameArea then
                    -- 在游戏区域内
                    v.inGameAreaEd = true
                elseif v.inGameAreaEd or not v.inMoveAction
                    or v.curX < 0 or v.curX > MapMgr.mapSize.width or v.curY < 0 or v.curY > MapMgr.mapSize.height then
                    -- 不在游戏区域了，且曾经在游戏区域内过，则析构该攻击效果
                    v:cleanup()
                    self.npcAttackEff[k] = true
                end
            end
        end
    end
end

-- 设置Me被火球击中后的表现
function BinghkyDlg:setMeFireStatus()
    if Me.bhkyStatus and Me.bhkyStatus == ATTACKED_STATUS.FIRE then
        -- 火球效果不叠加
        return
    end

    Me.bhkyStatus = ATTACKED_STATUS.FIRE

    Me:setOpacity(FIRE_ATTACK_OPACITY)

    performWithDelay(Me.middleLayer, function()
        Me:setOpacity(255)
    end, 0.2)

    performWithDelay(Me.middleLayer, function()
        Me:setOpacity(FIRE_ATTACK_OPACITY)
    end, 0.4)

    performWithDelay(Me.middleLayer, function()
        Me:setOpacity(255)
    end, 0.6)

    performWithDelay(Me.middleLayer, function()
        Me:setOpacity(FIRE_ATTACK_OPACITY)
    end, 0.8)

    performWithDelay(Me.middleLayer, function()
        Me:setOpacity(255)
        Me.bhkyStatus = ATTACKED_STATUS.NONE
    end, 1)

    -- 扣血
    self.life = self.life - 1
    self:setLifePanel()

    if self.life <= 0 then
        -- 游戏结束
        self:endGame()
    end
end

-- 设置Me被冰球击中后的表现
function BinghkyDlg:setMeIceStatus()
    Me:setSeepPrecentByClient(ICE_ATTACK_SPEED)

    local effectCfg = LIGHT_EFFECT[01357]

    -- 冰球效果会重复叠加，所以先停止之前的效果
    if Me.middleLayer.iceAction then
        Me.middleLayer:stopAction(Me.middleLayer.iceAction)
        Me:deleteMagic(effectCfg["icon"])
    end

    Me:addMagicOnWaist(effectCfg["icon"], effectCfg["behind"], effectCfg["icon"], effectCfg["armatureType"])

    Me.middleLayer.iceAction = performWithDelay(Me.middleLayer, function()
        Me:setSeepPrecentByClient(0)

        Me.bhkyStatus = ATTACKED_STATUS.NONE

        Me:deleteMagic(effectCfg["icon"])
    end, 3)

end

-- 判断两个角色是否相交
function BinghkyDlg:checkMeAttacked(char)
    if not char then return end
    if not Me or not Me.charAction or not Me.charAction.char then return end

    local meKnockItem = Me.topLayer:getChildByName("KnockLayer")
    if not meKnockItem then return end

    local itemSize = meKnockItem:getContentSize()
    local pos11 = meKnockItem:convertToWorldSpace(cc.p(0, 0))
    local pos21 = char.image:convertToWorldSpace(cc.p(0, 0))

    local pos12 = cc.p(pos11.x + itemSize.width, pos11.y + itemSize.height)
    local pos22 = cc.p(pos21.x + char.width, pos21.y + char.height)

    if Formula:getRectOvelLapArea(pos11.x, pos11.y, pos12.x, pos12.y, pos21.x, pos21.y, pos22.x, pos22.y) > 0 then
        return true
    end
end

-- 创建攻击效果
function BinghkyDlg:createAttackEff(id)
    local path, icon, type = self:getRandomEffect()
    local cfg = MAP_NPC_CFG[id / 100]
    local mapX, mapY = gf:convertToMapSpace(cfg.effPos.x, cfg.effPos.y)
    local effectObj = require("obj/EffectItem").new(mapX, mapY)
    local sprite = effectObj:addImage(path)
    if sprite then
        sprite:setVisible(false)
    end

    effectObj:addMagic(icon)

    -- 效果类型
    effectObj.type = type

    -- 速度
    effectObj:setSpeedPercent(self:getSpeedPercent())

    -- 目标位置与夹角
    local tarX, tarY, angle = self:getAttackTargetPos(cfg.effPos.x, cfg.effPos.y)
    if effectObj.magic then
        effectObj.magic:setRotation(angle)
    end

    effectObj:moveTo(tarX, tarY)

    return effectObj
end

-- 获取冰球火球的速度
function BinghkyDlg:getSpeedPercent()
    return 100 + self.gameingTime / 120 * 300
end

-- 获取攻击目标点
function BinghkyDlg:getAttackTargetPos(startX, startY)
    local x = math.random(Me.curX - TARGET_ATTACK_RADIUS, Me.curX + TARGET_ATTACK_RADIUS)
    local y = math.random(Me.curY - TARGET_ATTACK_RADIUS, Me.curY + TARGET_ATTACK_RADIUS)
    if not self:isInGameArea(cc.p(x, y)) then
        -- 不在游戏范围内，设置为Me当前位置
        x, y = Me.curX, Me.curY
    end

    -- 延长目标点的位置，保证点走出游戏范围之外
    -- 延长距离为游戏范围圆的直径，分别在x,y上加上对应分量
    local k = (y - startY) / (x - startX)
    local addX = math.sqrt(GAME_AREA_LENTH * GAME_AREA_LENTH / (1 + k * k))
    local addY = math.ceil(math.abs(k * addX))
    addX = math.ceil(addX)

    if x == startX then
        -- 处理斜率为0的情况
        addX = 0
        addY = GAME_AREA_LENTH
    end

    local tarX = (x > startX) and (x + addX) or (x - addX)
    local tarY = (y > startY) and (y + addY) or (y - addY)

    -- 与目标位置的夹角
    local vecX = tarX - startX
    local vecY = tarY - startY
    local angle = math.atan2(-vecY, vecX) * 180 / math.pi

    return tarX, tarY, angle
end

-- 检查坐标是否在游戏区域内
function BinghkyDlg:isInGameArea(pos)
    if Formula:ptInPolygon(pos, GAME_AREA) then
        return true
    end

    return false
end

-- 获取随机冰球、火球效果
function BinghkyDlg:getRandomEffect()
    if math.random(0, 1) == 0 then
        return ResMgr.ui.small_right_arrow, ResMgr.magic.bhky_fire_ball, ATTACKED_STATUS.FIRE
    else
        return ResMgr.ui.small_right_arrow, ResMgr.magic.bhky_ice_ball, ATTACKED_STATUS.ICE
    end
end

-- 地图上创建神将
function BinghkyDlg:bornMapNpc()
    for i = 1, #MAP_NPC_CFG do
        local cfg = MAP_NPC_CFG[i]
        local npc = Npc.new()
        npc:absorbBasicFields({
            id = cfg.id,
            icon = cfg.icon,
            dir = cfg.dir,
            name = '',
            sub_type = OBJECT_NPC_TYPE.CANNOT_TOUCH,
        })

        npc:setAct(Const.FA_STAND)
        npc:onEnterScene(cfg.x, cfg.y)

        self.mapNpc[cfg.id] = npc
    end
end

-- npc播放施法动作并停留在最后一帧
function BinghkyDlg:playNpcCaseAction(isRecover)
    for k, v in pairs(self.mapNpc) do
        if isRecover then
            v:setAct(Const.FA_STAND)
        else
            local npcId = v:getId()
            self.npcAttackEff[npcId] = true
            self:doNpcCastMagic(npcId)
        end
    end
end

-- npc播放施法动作
function BinghkyDlg:doNpcCastMagic(id)
    local function callback()
        self:doNpcCastMagicEnd(id)
    end

    local npc = self.mapNpc[id]
    if not npc then
        return
    end

    npc:setActAndCB(Const.FA_ACTION_CAST_MAGIC, callback)
end

-- npc播放施法动作结束
function BinghkyDlg:doNpcCastMagicEnd(id)
    local function callback()
        local npc = self.mapNpc[id]
        if not npc or npc.faAct ~= Const.FA_ACTION_CAST_MAGIC_END then
            return
        end

        npc:setAct(Const.FA_STAND)
    end

    local npc = self.mapNpc[id]
    if not npc then
        return
    end

    npc:setActAndCB(Const.FA_ACTION_CAST_MAGIC_END, callback)
end

-- 清除地图上的npc攻击特效
function BinghkyDlg:clearNpcAttackEff()
    for k, v in pairs(self.npcAttackEff) do
        if 'boolean' ~= type(v) then
            v:cleanup()
        end
    end

    self.npcAttackEff = {}
end

-- 清除地图上的npc
function BinghkyDlg:clearMapNpc()
    for k, v in pairs(self.mapNpc) do
        v:cleanup()
    end

    self.mapNpc = {}
end

-- Me检测碰撞的Layer
function BinghkyDlg:setMeCheckKnockItem()
    if Me.topLayer:getChildByName("KnockLayer") then return end

    local rect = Me.charAction.char.contentRect
    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))

    -- 由于模型有空白区域，但rect是长方形，所以稍微缩小一点rect的大小，让碰撞看起来更真实
    colorLayer:setContentSize(rect.width - 25, rect.height - 35)
    colorLayer:setPosition(cc.p(-rect.width / 2 + 13, 0))

    Me:addToTopLayer(colorLayer)
    colorLayer:setName("KnockLayer")
end

-- 移除Me检测碰撞的Layer
function BinghkyDlg:removeMeCheckKnockItem()
    local item = Me.charAction.char:getChildByName("KnockLayer")
    if item then
        item:removeFromParent()
        item = nil
    end
end

-- 刷新血条
function BinghkyDlg:setLifePanel()
    for i = 1, 3 do
        local panel = self:getControl("LifePanel_" .. i, nil, self.infoPanel)
        self:setCtrlVisible("Image_1", false, panel)
        self:setCtrlVisible("Image_2", false, panel)
        if i <= self.life then
            self:setCtrlVisible("Image_1", true, panel)
        else
            self:setCtrlVisible("Image_2", true, panel)
        end
    end
end

-- 刷新游戏坚持时间
function BinghkyDlg:refreshGamingTime()
    local minute = math.floor(self.gameingTime / 60)
    local second = self.gameingTime % 60
    local timeStr = string.format("%02d:%02d", minute, second)

    self:setLabelText("TimeLabel", timeStr, self.infoPanel)
end

-- 结算信息
function BinghkyDlg:setResultInfo(flag)
    local bkPanel = self:getControl("BKPanel")
    local resultPanel = self:getControl("ResultPanel")
    bkPanel:setVisible(flag)
    resultPanel:setVisible(flag)
    if flag then
        gf:CmdToServer("CMD_SUMMER_2019_BHKY_RESULT", {result = gfEncrypt(tostring(self.gameingTime), self.resultData.cookie)})

        self:setCtrlVisible("FailImage", false, resultPanel)
        self:setCtrlVisible("SuccessImage", false, resultPanel)
        self:setCtrlVisible("GoodNoticePanel")

        self:setLabelText("ReqPointLabel2", string.format(CHS[7120167], self.resultData.sucess_time))
        self:setLabelText("YourPointLabel2", string.format(CHS[7120167], self.gameingTime))

        local goodNoticePanel = self:getControl("GoodNoticePanel", nil, resultPanel)
        local normalNoticePanel = self:getControl("NormalNoticePanel", nil, resultPanel)
        local failNoticePanel = self:getControl("FailNoticePanel", nil, resultPanel)
        goodNoticePanel:setVisible(false)
        normalNoticePanel:setVisible(false)
        failNoticePanel:setVisible(false)
        if self.gameingTime >= self.resultData.sucess_time then
            -- 成功图标
            self:setCtrlVisible("SuccessImage", true, resultPanel)

            local maxTime = math.max(self.gameingTime, self.resultData.max_time)
            if maxTime < self.resultData.title_time then
                -- 当前最大时间未超过获得称谓的时间
                normalNoticePanel:setVisible(true)
                self:setLabelText("Label_1", string.format(CHS[7190504], maxTime), normalNoticePanel)
                self:setLabelText("Label_3", string.format(CHS[7190505], self.resultData.title_time), normalNoticePanel)
            else
                -- 当前最大时间超过获得称谓的时间
                goodNoticePanel:setVisible(true)
                self:setLabelText("Label_1", string.format(CHS[7190506], maxTime, self.resultData.title_time), goodNoticePanel)
            end
        else
            -- 失败
            self:setCtrlVisible("FailImage", true, resultPanel)
            failNoticePanel:setVisible(true)
        end
    end
end

function BinghkyDlg:cleanup()
    self:stopSchedule(self.timeScheduleId)
    self:stopSchedule(self.tickScheduleId)
    self:clearNpcAttackEff()
    self.npcAttackEffTime = {}
    self:clearMapNpc()
    self.resultData = nil
end

-- 重新开始
function BinghkyDlg:onRestartButton(sender, eventType)
    self:resetGame()
end

-- 退出游戏
function BinghkyDlg:onQuitButton(sender, eventType)
    gf:confirm(CHS[7190507], function()
        gf:CmdToServer("CMD_SUMMER_2019_BHKY_QUIT", {})
    end)
end

function BinghkyDlg:MSG_ENTER_ROOM()
    self:endGame()
    self:onCloseButton()

    local chatDlg = DlgMgr.dlgs["ChatDlg"]
    if chatDlg then chatDlg:setVisible(true) end
end

return BinghkyDlg
