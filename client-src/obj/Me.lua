-- Me.lua
-- Created by chenyq Nov/14/2014
-- 场景中的当前玩家对应的类

local Player = require("obj/Player")
local Magic = require ("animate.Magic")

Me = Singleton('me', Player.new())

Me.op = ME_OP.NULL
Me.lastMap = nil

local UPDATE_TYPE = {
    BASIC = 1,
    EXTRA = 2,
}

local UPDATE_TIP_ATTR = {
    "phy_power",
    "mag_power",
    "speed",
    "def",
    "max_life",
    "max_mana",
}

local UPDATE_ATTR_MAP = {
    ["phy_power"]   = CHS[3004401],
    ["mag_power"]   = CHS[3004402],
    ["speed"]       = CHS[3004403],
    ["def"]         = CHS[3004404],
    ["max_life"]        = CHS[3002422],
    ["max_mana"]        = CHS[3002423],

}

-- 移动检测间隔
local SHIFT_INTERVAL = 1000

-- 人物参与战斗前等级
Me.levelBeforeAbsorbField = 10000

-- 记录移动检测的时间
Me.lastShiftTime = nil

-- 当前选择玩家对象
Me.selectTarget = nil

-- 本次登录是否解绑过手机
Me.bindData = {}

Me.lastUpgradeTie = nil

-- Me作为队长时是否需要拉队友
Me.canShiftFlag = true

-- 是否锁定视野
Me.fixedView = false

-- 是否为被动模式
function Me:isPassiveMode()
    return self:queryBasicInt("passive_mode") ~= 0
end

-- 判断我是否在主动移动
-- 非队员、非被动模式才是主动移动
function Me:isControlMove()
    if GMMgr:isStaticMode() then return false end

    if Me.isLimitMoveByClient then return false end

    return not (self:isTeamMember() or self:isPassiveMode())
end

function Me:setTalkId(npcId)
    self.talkId = npcId
end

function Me:getTalkId()
    return self.talkId
end

function Me:isInTalkWithNpc()
    return self.isTalkWithNpc
end

function Me:setTalkWithNpc(flag)
    self.isTalkWithNpc = flag
end

-- 获取血池加血后的血量
function Me:getExtraRecoverLife()
    -- 如果存储量大于等于max_life - life，直接显示最大血量
    local maxLife = tonumber(self:query("max_life"))
    local curLife = tonumber(self:query("life"))
    local extraLife = tonumber(self:query("extra_life"))

    if GameMgr.inCombat then
        return curLife
    end

    if extraLife >= maxLife - curLife then
        return maxLife
    else
        return curLife + extraLife
    end
end

-- 获取补充灵池后的灵气
function Me:getExtraRecoverMana()
    local maxMana = tonumber(self:query("max_mana"))
    local curMana = tonumber(self:query("mana"))
    local extraMana = tonumber(self:query("extra_mana"))

    if GameMgr.inCombat then
        return curMana
    end

    if extraMana >= maxMana - curMana then
        return maxMana
    else
        return curMana + extraMana
    end
end
-- 记录是否已经发了切换地图的消息（如果发了则等待，如果没发，则可以发行走的消息）
function Me:setChangeRoom(v)
    self.changingRoom = v
end

-- 是否正在过图中
function Me:isChangingRoom()
    return self.changingRoom
end

-- 是否可以移动 todo
function Me:getCanMove()
    repeat
        if not self:isControlMove() then
            -- 人物不是主动控制
            break
        end
    until true

    return self.canMove
end

function Me:clearMoveCmds()
    self.moveCmds = (require "core/List").new()
end

-- 获取移动命令中间的坐标
function Me:getMiddlePosFromMoveCmd()
    local queue = self.moveCmds
    local count = queue:size()
    if count <= 0 then
        -- 无移动命令，返回当前位置
        return self.curX, self.curY
    end

    local pos = queue:get(math.floor((count + 1.5) / 2))
    return gf:convertToClientSpace(pos.x, pos.y)
end

function Me:canSend()
    if self:isChangingRoom() then
        return false
    end

    if not self:isControlMove() then
        return false
    end

    if not self:getCanMove() then
        return false
    end

    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
    if mapX == self.lastMapPosX and mapY == self.lastMapPosY then
        return false
    end

    return true
end

function Me:setEndPos(mapX, mapY, noClearAutoWalk)
    if self:isChangingRoom() or (self:isGather() and self:isShowRidePet()) then
        -- 正在切换场景，不移动
        return
    end

    -- 清除保存的任务信息
    AutoWalkMgr:clearStoredTask()

    -- 玩家中猎人陷阱，点击屏幕时，不可移动角色
    if Me.isInLieRenXianJing then
        local time = gf:getServerTime()
        if not self.lastTipsTime or time - self.lastTipsTime >= 3 then
            gf:ShowSmallTips(CHS[5400051])
            self.lastTipsTime = time
        end

        return
    end

    Player.setEndPos(self, mapX, mapY)

    self.walkDest = nil

    -- 改变整个队的队员目标位置
    self:changeTeamEndPos(mapX, mapY)

    if not noClearAutoWalk then
        -- 结束自动寻路
        AutoWalkMgr:endAutoWalk()
    end

    -- 结束随机走动
    AutoWalkMgr:endRandomWalk()
end

-- 更新
function Me:update()
    Player.update(self)

    self:shift()
end

-- 检测是否有对象需要拖动
function Me:shift()
    if self.lastShiftTime and GameMgr.lastUpdateTime - self.lastShiftTime < SHIFT_INTERVAL then
        return
    end

    -- me已经被设置不拉队友标记
    if not self.canShiftFlag then
        return
    end

    self.lastShiftTime = GameMgr.lastUpdateTime

    if self:isInCombat() then
        -- 战斗中无需处理
        return
    end

    local myId = self:getId()
    local x = self:queryBasic("x")
    local y = self:queryBasic("y")

    -- 队长，尝试拉一下队员
    if TeamMgr:getLeaderId() == myId then
        local members = TeamMgr.members
        for k, v in ipairs(members) do
            if v.id ~= myId then
                local char = CharMgr:getChar(v.id)
                if not char or not gf:inOffset(char.curX, char.curY, self.curX, self.curY, Const.SHIFT_LIMITED_DISTANCE) then
                    -- 队员不见了或者队员离队长太远了，拉一下
                    gf:CmdToServer('CMD_SHIFT', { id = v.id, x = x, y = y, dir = 0 })
                end
            end
        end
    end

    if not self:isInTeam() or TeamMgr:getLeaderId() == myId then
        repeat
            local visKidId = HomeChildMgr:getVisibleKidId()
            local visPetId = PetMgr:getVisiblePetId()

            if not visKidId and not visPetId then break end

            local shiftObjId = visKidId and visKidId or visPetId

            local shiftObj = CharMgr:getChar(shiftObjId)
            if not shiftObj or not gf:inOffset(shiftObj.curX, shiftObj.curY, self.curX, self.curY, Const.SHIFT_LIMITED_DISTANCE) then
                -- 需要shift的对象不见了，拉一下
                gf:CmdToServer('CMD_SHIFT', { id = shiftObjId, x = x, y = y, dir = 0 })
            end
        until true
    end
end

-- 若行走因为战斗中断，可调用函数继续行走
function Me:resumeGotoEndPos()
    if not self.lastPaths or not self.lastPosCount then
        return
    end

    if self:getCanMove() and (not self.isInRandWalk) and (not AutoWalkMgr:isAutoWalk()) then
        self.paths = self.lastPaths
        self.posCount = self.lastPosCount
        local newEndX, newEndY = self:getEndPos()
        self.paths = nil
        self.posCount = 0
        self:setEndPos(newEndX, newEndY)
    end
end


function Me:changeTeamEndPos(mapX, mapY)
    local myId = self:getId()
    if TeamMgr:getLeaderId() ~= myId then
        -- 队长不是 Me，不能改变队员的目标位置
        return
    end

    local members = TeamMgr.members
    for k, v in ipairs(members) do
        if v.id ~= myId then
            local char = CharMgr:getChar(v.id)
            if char ~= nil and char:canFollow() then
                -- 当前队员不是 me，重新设置其目标位置
                char:setEndPos(mapX, mapY)
            end
        end
    end
end

function Me:changeVisiblePetPos(mapX, mapY)
    local pet = CharMgr:getPet(self:getId())
    if pet ~= nil then
        pet:setEndPos(mapX, mapY)
    end
end

function Me:setAct(act, noCheckAutoWalk, callBack)
    if self.faAct == Const.FA_WALK and act ~= Const.FA_WALK then
        self:setLastWalkOrLoadMapTime(gfGetTickCount())
    end

    Player.setAct(self, act, callBack)

    if act == Const.SA_STAND and not noCheckAutoWalk then
        local mgr = AutoWalkMgr
        if mgr:isAutoWalkArrived() then
            -- 自动寻路到达目的地
            mgr:doAutoWalkEnd()
            mgr:tryToEndAutoWalk()
        end

        if mgr:isRandomWalkArrived() then
            mgr:randomWalk()
        end
    end
end

function Me:onEnterScene(mapX, mapY)
    Player.onEnterScene(self,mapX,mapY)
    self:setIsEnterScene(true)

    local mgr = AutoWalkMgr
    if Me.needContinueAutoWalk then
        -- 特殊处理，详见 CharMgr:MSG_REVISE_POS()
        if mgr.autoWalk then
            mgr.autoWalk.is_walking = nil
        end

        Me.needContinueAutoWalk = nil
    end

    if mgr:isWaitingAutoWalk() then
        -- 有自动寻路信息则自动寻路
        AutoWalkMgr:enterRoomContinueAutoWalk()
    else
        mgr:endAutoWalk()
        self:setIsEnterScene(false)
    end

    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:update()
    end
end

function Me:setIsEnterScene(isEnterScene)
    self.isEnterScene = isEnterScene
end

function Me:getIsEnterScene()
    return self.isEnterScene
end

-- 检测人物属性是否发生变化
function Me:checkAttriChange(dataOld, dataNew)
    if Me:isInCombat() then
        return
    end

    -- 先把人物身上的属性拿出来
    local attrBasic = Me.basic
    local attrExtra = Me.extra

    for i = 1, #UPDATE_TIP_ATTR do
        local attrStr = UPDATE_TIP_ATTR[i]
        local value = dataNew[attrStr] - dataOld[attrStr]
        if 0 ~= value then
            local data = { attrStr = UPDATE_ATTR_MAP[attrStr], value = value}
            gf:ShowAttrSmallTips(data)
        end
    end
end

-- 获取所有需要监听的属性
function Me:getAllListenAttr()
    local data = {}
    for i = 1, #UPDATE_TIP_ATTR do
        data[UPDATE_TIP_ATTR[i]] = Me:queryInt(UPDATE_TIP_ATTR[i])
    end

    return data
end

function Me:startWaitData()
    if self.attChangeTipsdelay or not GameMgr:isEnterGameOK() or self:isInCombat() then return end

    Log:D(CHS[3004405])
    local dataOld = Me:getAllListenAttr()
    self.attChangeTipsdelay = performWithDelay(gf:getUILayer(), function()
        local dataNew = Me:getAllListenAttr()
        Me:checkAttriChange(dataOld, dataNew)
        self.attChangeTipsdelay = nil
        Log:D(CHS[3004406])
    end, 0.2)
end

-- 自定义外观展示开关
function Me:isShowDress()
    return 0 == self:queryBasicInt("fasion_custom_disable")
end

-- 特效开关
function Me:isShowEffect()
    return 0 == self:queryBasicInt("fasion_effect_disable")
end

function Me:MSG_UPDATE_IMPROVEMENT(map)
    Me:startWaitData()
    if map.id == Me:getId() then
        self:cleanupExtra()
        self:absorbExtraFields(map)

        local obj = FightMgr:getObjectById(map.id)
        if obj then
            obj:setBasic('max_life', self:queryIntWithOutComAtt('max_life'))
            obj:setBasic('max_mana', self:queryIntWithOutComAtt('max_mana'))
        end
    else
        PetMgr:addExtraMapping(map)
    end
end

function Me:MSG_APPELLATION_LIST(data)
    self:absorbBasicFields(data)

    -- 如果收到2019端午节口味大战，需要刷新一下当前周边玩家
    for i = 1, data.title_num do
        if data[string.format("title%d", i)] == CHS[4010252] or data[string.format("title%d", i)] == CHS[4010251] then
            for _, v in pairs(CharMgr.chars) do
                if v:getType() == "Player" then
                    v:updateLeiTaiTitle()
                    v:updateName()
                end
            end
        end
    end
end

-- 重置me的位置
function Me:MSG_ENTER_ROOM(map)
    -- 清除上一地图中的行走路径
    self:resetGotoEndPos()

    self.isMoved = false
    -- 需要先设置正确的数据再对其他东西进行更新
    -- 不然以下函数可能会取位置信息进行处理,就导致了位置的脏数据
    self:setPos(gf:convertToClientSpace(map.x, map.y))
    self:setLastMapPos(map.x, map.y)
    self:setAct(Const.SA_STAND)
    self:clearMoveCmds()
    self:setDir(map.dir, true)
    self:setChangeRoom(false)
    self.bReadyMove = false
    self.readyMoveTick = 0

    -- 取消正与 npc 对话的标记
    self:setTalkWithNpc(false)

    -- 为了在切换地图的时候，不会被设置为其他的endX，和endY
    self.endX, self.endY = gf:convertToClientSpace(map.x, map.y)

    if map.notChangeMap and AutoWalkMgr:isAutoWalk() then
        -- 如果处于自动寻路中，则继续自动寻路
        AutoWalkMgr:continueAutoWalk()
    elseif self:isTeamLeader() and not AutoWalkMgr:isAutoWalk() then
        -- 需要再 setEndPos，以确保队员能够走到队长所在位置
        self:setEndPos(map.x, map.y)
    end
end

function Me:MSG_CHAR_CHANGE_SEX(data)
end

-- 战斗中
function Me:isInCombat()
    return GameMgr.inCombat
end

function Me:clearData()
    self.titleInfo = {}
    self:resetGotoEndPos()
    self:cleanupExtra()
    self:cleanupBasic()
    self:cleanComAbsorbData()
    self.lookFightState = false
    self.bindData = {}
    self:clearFollowSprites()

    self.lastUpgradeTie = nil
    self.lastShiftTime = nil
    self.lastSendMoveTime = nil

    self.isInLieRenXianJing = nil
    self.hasZuiXinWu = nil

    self.lastWalkOrLoadMapTime = nil

    self.antiaddictionData = nil

    Me.isLimitMoveByClient = nil -- 为了部分小游戏表现好一些，客户端当方面禁止移动

    local layer = gf:getUILayer()
    if self.attChangeTipsdelay and layer then
        layer:stopAction(self.attChangeTipsdelay)
        self.attChangeTipsdelay = nil
    end
end


-- 获取是否处于随机走动状态
function Me:isRandomWalk()
    if self.isInRandWalk then
        return true
    end

    return false
end

-- 设置Me是否处于随机移动状态
function Me:setIsInRandomWalk(state)
    self.isInRandWalk = state
end

-- vip信息
function Me:MSG_INSIDER_INFO(data)
    self.vipType = data["vipType"]
    self.endTime = data["endTime"]
    self.isGet   = data["isGet"]
    self.tempInsider = data["tempInsider"]
    self:updateName()

    if not Me:isGetCoin() and Me:getVipType() > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "MallButton")
        RedDotMgr:insertOneRedDot("OnlineMallTabDlg", "VIPCheckBox")
    elseif RedDotMgr:hasRedDotInfo("SystemFunctionDlg" , "MallButton") then
        RedDotMgr:removeOneRedDot("SystemFunctionDlg", "MallButton")
    end
end

-- 是否是临时会员
function Me:isTempInsider()
    return self.tempInsider == 1
end

-- 是否已经领取元宝
function Me:isGetCoin()
    if self.isGet == 1 then
        return true
    end

    return false
end

-- 根据gid判断玩家是否在Me身边
function Me:isNearByGid(gid)
    local chars = CharMgr.chars

    for _,char in pairs(chars) do
        if char:queryBasic("gid") == gid then
            return true
        end
    end

    return false
end

function Me:isNearById(id)
    local chars = CharMgr.chars

    for _,char in pairs(chars) do
        if _ == id then
            return true
        end
    end

    return false
end

-- 是否是vip
function Me:isVip()
	if self.endTime and gf:getServerTime() <= self.endTime then
	   return true
	else
	   return false
	end
end

-- vip 剩余天数
function Me:getVipLeftDays()
    -- gf:getSreverTime()可能与服务端实际的值会有些许不同可以加5s当做延迟补偿
    local lefeDays = math.ceil(self:getVipFloatDays())
    return lefeDays
end

-- 获取vip 剩余精确时间天数
function Me:getVipFloatDays()
    local lefeDays = (self.endTime - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)) / 86400
    return lefeDays
end

-- vip 类型
-- 0 表示没有
-- 1 月卡
-- 2 季卡
-- 3 年卡
function Me:getVipType()
    return self.vipType or 0
end

-- 自己是否处于观战
-- 重写是因为掉线时候，战斗是先刷过来
function Me:isLookOn()
    return self.lookFightState
end

function Me:setLookFightState(lookFightState)
    self.lookFightState = lookFightState
end

-- 获取显示的ID
function Me:getShowId()
    return gf:getShowId(Me:queryBasic("gid"))
end

-- 是否在禁闭
function Me:isInJail()
    return TaskMgr:isHaveJailTask()
end

-- 是否被关入监狱
function Me:isInPrison()
    return TaskMgr:isHavePrisonTask()
end

-- 是否显示骑乘效果
function Me:isShowRidePet()
    if CharMgr:getStatusActionIcon(self:getId(), self.faAct) then
        return false
    end

    if MapMgr:isInYuLuXianChi() then
        return false
    end

    if ActivityHelperMgr:isInBhkySummer2019() then
        return false
    end

    return self:queryBasicInt("notShowRidePet") == 0
end

-- 是否锁定视野
function Me:isFixedView()
    return self.fixedView
end

-- 设置锁定视野
function Me:setFixedView(flag)
    self.fixedView = flag
end

-- 获取总的元宝数量(负的当为0处理)
function Me:getTotalCoin()
    local goldCoin = Me:queryBasicInt('gold_coin')
    if goldCoin < 0 then
        goldCoin = 0
    end

    local silverCoin = Me:queryBasicInt('silver_coin')
    if silverCoin < 0 then
        silverCoin = 0
    end

    return goldCoin + silverCoin
end

-- 获取金元宝数量（负的当为0处理）
function Me:getGoldCoin()
    local goldCoin = Me:queryBasicInt('gold_coin')
    if goldCoin < 0 then
        goldCoin = 0
    end

    return goldCoin
end

-- 获取银元宝数量（负的当为0处理）
function Me:getSilverCoin()
    local silverCoin = Me:queryBasicInt('silver_coin')
    if silverCoin < 0 then
        silverCoin = 0
    end

    return silverCoin
end

-- 刷新头衔
function Me:refreshTitle(data)
    local isTeamLeaderLast = self:isTeamLeader()
    Player.refreshTitle(self, data)
    local isTeamLeaderCurrent = self:isTeamLeader()
    if isTeamLeaderLast and not isTeamLeaderCurrent then
        -- 清除当前队伍成员的寻路信息
        local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
        local members = TeamMgr.members
        for _, v in ipairs(members) do
            local char = CharMgr:getChar(v.id)
            if char ~= nil then
                -- 全队人员设置为站立
                char:setAct(Const.SA_STAND)
            end
        end

        AutoWalkMgr:endAutoWalk()
    end
end

-- 点击地板开始时间处理逻辑
function Me:touchMapBegin(toPos)
    -- 获取地图对象
    if not GameMgr.scene or not GameMgr.scene.map then
        return
    end

    local mapObj = GameMgr.scene.map

    -- isMoved 表示是否长按住了，长按住了，update中就会获取Me.toPos进行更新位置
    -- toPos 存储的是在屏幕上点击的位置，需要进行转换，首先转换为节点坐标，在转换为地图上面的坐标
    Me.isMoved = true
    Me.toPos = toPos

    mapObj:addClickMagicToMap(toPos)

    -- 清除自动寻路等标志信息
    AutoWalkMgr:stopAutoWalk(true)

    -- 点击地图时必须移除焦点人物的光效
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    -- 点击地面的时候需要显示主界面图标
    DlgMgr:preventDlg()

    local newToPos = mapObj:convertToNodeSpace(Me.toPos)
    Me:setEndPos(gf:convertToMapSpace(newToPos.x, newToPos.y))

    mapObj:resetDelayTime()

    -- 通知计步工具停止
    DlgMgr:sendMsg("PedometerDlg", "onDelButton")

    -- 分发点击地板的事件
    EventDispatcher:dispatchEvent(EVENT.TOUCH_MAP_BEGIN, { })
end

-- 点击地板移动
function Me:touchMapMoved(toPos)
    if DlgMgr:getDlgByName("NpcDlg") or DlgMgr:getDlgByName("DramaDlg") then
        local newEndX, newEndY = self:getEndPos()
        self.paths = nil
        self.posCount = 0
        self:setEndPos(newEndX, newEndY)
        Me:touchMapEnd(toPos)
        return
    end

    Me.isMoved = true
    Me.toPos = toPos
end

-- 点击地板结束时间逻辑
function Me:touchMapEnd(toPos)
    -- 获取地图对象
    if not GameMgr.scene or not GameMgr.scene.map then
        return
    end
    local mapObj = GameMgr.scene.map

    -- 设置移动的结束
    Me.isMoved = false
    Me.toPos = toPos

    -- 重新设置更新时间
    mapObj:resetDelayTime()
end

-- 移除选中对象脚底的光效
function Me:removeSelectTargetFocusMagic()
    -- 移除选中特效
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end
end

-- 是否属于公示期
function Me:isInTradingShowState()
    if TradingMgr.tradingData and TradingMgr.tradingData[1] and TradingMgr.tradingData[1].state == TRADING_STATE.SHOW then
        return true
    end


    return false
end

-- 是否开启了防沉迷
function Me:isAntiAddictionStartup()
    return self.antiaddictionData and (self.antiaddictionData["is_startup"] == 1 or self.antiaddictionData["second_enable"] == 1)
end

function Me:getAntiaddictionLimitTime()
    if not self:isAntiAddictionStartup() then
        return -1
    end

    if self.antiaddictionData["second_enable"] == 1 then
        -- 第二套监管
        if self.antiaddictionData["player_age"] >= self.antiaddictionData["small_age"] then
            -- 已满十三周岁
            return self.antiaddictionData["young_online"]
        else
            -- 未满十三周岁
            return self.antiaddictionData["small_age_online"]
        end
    else
        -- 第一套监管措施
        return Const.FIVE_HOURS
    end
end

-- 是否开启未成年限制开关5
function Me:isAntiAdditionSwith5()
    return Me:getAdultStatus() == 0 and self.antiaddictionData and self.antiaddictionData["switch5"] == 1
end

-- 获取防沉迷剩余时间，为 0 后参加一些系统活动将无奖励
function Me:getAntiaddictionLeftTime()
    if not self:isAntiAddictionStartup() then
        return -1
    end

    local loginTime = self.antiaddictionData["last_online"] - self.antiaddictionData["total_online"]
    local leftTime = self:getAntiaddictionLimitTime() - (gf:getServerTime() - loginTime)
    local showZeroTips = true
    if leftTime <= -5 then
        -- 超过 5 秒后就不要给提示了
        showZeroTips = false
    end

    if leftTime < 0 then
        leftTime = 0
    end

    return leftTime, showZeroTips
end

-- 获取认证信息
function Me:getAdultStatus()
    local defaultStatus = 2 -- 未认证
    if not self.antiaddictionData then
        -- 默认
        return defaultStatus
    end

    return self.antiaddictionData["adult_status"] or defaultStatus
end

-- 获取防沉迷相关数据
function Me:getAntiaddictionInfo()
    return self.antiaddictionData or {}
end

function Me:MSG_FUZZY_IDENTITY(data)
    self.bindData = {
        isBindName = (1 == data.isBindName),
        isBindPhone = (1 == data.isBindPhone),
        bindName = data.bindName,
        bindId = data.bindId,
        bindPhone = data.bindPhone
    }
end


-- 是否是真身
function Me:isRealBody()
    return Me:queryInt("upgrade/state") == 0
end


function Me:isChildForTest()
    if Me.ret == 0 then return false end
    return true
end

function Me:getChildIconPath()
    if Me:getChildType() == 0 then
        return
    elseif Me:getChildType() == 1 then
        return ResMgr.ui.yuanying
    elseif Me:getChildType() == 2 then
        return ResMgr.ui.xueying
    end

end

-- 获取元婴、血婴icon
function Me:getChildPortrait()
    if Me:getChildType() == 0 then
        return
    elseif Me:getChildType() == 1 then
        return 07008
    elseif Me:getChildType() == 2 then
        return 07009
    end
end

function Me:getChildName()
    return gf:getChildName(Me:getChildType())
end

-- 获取元婴类型    0 未获得                       1 元婴                         2血婴
-- 详见Const.lua CHILD_TYPE
function Me:getChildType()
    local childType = Me:queryInt("upgrade/type")
    if childType == CHILD_TYPE.UPGRADE_IMMORTAL then
        return CHILD_TYPE.YUANYING
    elseif childType == CHILD_TYPE.UPGRADE_MAGIC then
        return CHILD_TYPE.XUEYING
    end

    return childType
end

-- 是否完成仙魔难任务
function Me:isFlyToXianMo()
    return Me:queryInt("upgrade/type") > CHILD_TYPE.XUEYING
end

-- 是否未分配任何仙魔点
function Me:isNoAllotmentXianMo()
    return Me:queryInt("upgrade/total") == (Me:getLevel() - 119)
end

function Me:getDijieCompletedTimes()
	-- 完成一次地劫，相性上限+1，所以可以用此变量表示地劫完成次数
    return Me:queryBasicInt("upgrade/max_polar_extra")
end

-- 是否完成元神突破
function Me:hasBreakLevelLimit()
    return Me:queryBasicInt("has_break_lv_limit") == 1
end

-- 完成天劫次数
function Me:getTianjieCompletedTimes()
    -- 减去地劫添加的上限
    return Me:queryBasicInt("upgrade/max_polar_extra") - Const.DIJIE_TASK_MAX
end

-- 是否完成小飞。虽然凝结了元婴、血婴，但是任务还有一部也不行！！！！！！！
function Me:isCompletedXiaoFei()
    if Me:getChildType() > CHILD_TYPE.NO_CHILD and not TaskMgr:getTaskByName("飞升—引路人") then
        return true
    end

    return false
end

-- 获取元婴、血婴等级上限

function Me:getBabyLevelMax()
    local level = Me:getLevel()

    if Me:hasBreakLevelLimit() then
        -- 完成剑冢机缘任务，突破
        if Me:getDijieCompletedTimes() >= Const.DIJIE_TASK_MAX then
            -- 完成地劫，取天劫
            if Me:getTianjieCompletedTimes() >= Const.TIANJIE_TASK_MAX then
                level = TIANJIE_TASK_LEVEL[Const.TIANJIE_TASK_MAX].max
            else
                level = TIANJIE_TASK_LEVEL[Me:getTianjieCompletedTimes() + 1].max
            end
        else
            -- 未完成地劫，取地劫
            level = DIJIE_TASK_LEVEL[Me:getDijieCompletedTimes() + 1].max
        end
    else

        if Me:getDijieCompletedTimes() >= Const.DIJIE_TASK_MAX then
            -- 完成地劫，取天劫
            local tjLevel
            if Me:getTianjieCompletedTimes() >= Const.TIANJIE_TASK_MAX then
                tjLevel = TIANJIE_TASK_LEVEL[Const.TIANJIE_TASK_MAX].max
            else
                tjLevel = TIANJIE_TASK_LEVEL[Me:getTianjieCompletedTimes() + 1].max
            end

            level = math.min(tjLevel, level)
        else
            -- 未完成地劫，取地劫
            level = math.min(DIJIE_TASK_LEVEL[Me:getDijieCompletedTimes() + 1].max, level)
        end
    end
    return level
end

function Me:MSG_PHONE_VERIFY_CODE(data)
end

-- 更新防沉迷相关数据
function Me:MSG_UPDATE_ANTIADDICTION_STATUS(data)
    self.antiaddictionData = data
end

function Me:MSG_CHAR_UPGRADE_COAGULATION(data)
    self.lastUpgradeTie = gfGetTickCount()
end

function Me:isBindName()
    if Me.bindData and Me.bindData.isBindName then
        return true
    else
        return false
    end
end

function Me:setFightUseChangeCardPos(pos)
    self.useChangeCardPos = pos
end

function Me:getFightUseChangeCardPos()
    return self.useChangeCardPos
end

function Me:clearFightUseChangeCardPos()
    self.useChangeCardPos = nil
end

function Me:onBeforeAbsorbBasicFields(tbl)
    -- 判断人物吸收数据后是否升级，在Me:onAbsorbBasicFields中使用完置为false即可
    if tbl and tbl["level"] and tbl["level"] > self:getLevel() then
        self.isLevelUp = true

        -- 不和 self.isLevelUp 通用，是因为 刷新 polar_point和 attrib_point时，未刷新 upgrade/total，导致 self.isLevelUp = false
        self.isLevelUpForXianMo = true
    end
end

function Me:onAbsorbBasicFields(tbl)
    Player.onAbsorbBasicFields(self)

    -- 吸收数据后升级且有剩余加点数则检测提升界面的显示
    if tbl and (tbl["attrib_point"] or tbl["polar_point"]) and self.isLevelUp then
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_ATTRIB)
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_POLAR)
        self.isLevelUp = false
    else
        if tbl and tbl["attrib_point"] and self:queryBasicInt("attrib_point") == 0 then
            PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_ATTRIB)
        end

        if tbl and tbl["polar_point"] and self:queryBasicInt("polar_point") == 0 then
            PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_POLAR)
        end
    end

    if tbl and tbl["passive_mode"] and tbl["passive_mode"] == 1 then
        Me.toPos = nil
        Me.isMoved = false
    end

    if tbl and tbl["upgrade/total"] and self.isLevelUpForXianMo then
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_XIANMO_POINT)
        self.isLevelUpForXianMo = false
    end

    -- 需要刷新共乘数据
    if self:isGather() and not gf:isShowRidePet() then
        local driverId = self:queryBasicInt("share_mount_leader_id")
        local char = CharMgr:getCharById(driverId)
        if char then
            char:onAbsorbBasicFields()
        end
    end
end

-- 种植等级为 0 时，特判为 1
function Me:getPlantLevel()
    local level = Me:queryInt("plant_level")
    return level > 0 and level or 1
end

function Me:setLastWalkOrLoadMapTime(time)
    self.lastWalkOrLoadMapTime = time
end

-- 是否已锁定经验
function Me:isLockExp()
    return Me:queryBasicInt("lock_exp") == 1
end

MessageMgr:regist("MSG_CHAR_UPGRADE_COAGULATION", Me)

MessageMgr:regist("MSG_UPDATE_IMPROVEMENT", Me)
MessageMgr:regist("MSG_APPELLATION_LIST", Me)
MessageMgr:regist("MSG_INSIDER_INFO", Me)
MessageMgr:regist("MSG_CHAR_CHANGE_SEX", Me)
MessageMgr:regist("MSG_FUZZY_IDENTITY", Me)
MessageMgr:regist("MSG_UPDATE_ANTIADDICTION_STATUS", Me)
MessageMgr:regist("MSG_PHONE_VERIFY_CODE", Me)
MessageMgr:regist("MSG_CHECK_OLD_PHONENUM_SUCC")
MessageMgr:hook("MSG_ENTER_ROOM", Me, "Me")
