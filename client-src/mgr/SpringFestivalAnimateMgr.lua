-- SpringFestivalAnimateMgr.lua
-- created by lixh Aug/22/2018
-- 活动帮助管理器
-- 主要用于特殊节日、礼包等活动的数据管理、打开界面等操作

SpringFestivalAnimateMgr = Singleton()
local CharAction = require ("animate/CharAction")

-- 活动时间配置
local ACTIVITY_TIME = {
    START       = 20190203050000,
    END         = 20190212045959,
    TEST_START  = 20190125045959,
    TEST_END    = 20190212045959,
}

-- 春节宠物位置
local SPRING_FESTIVAL_PET_POS = {
    {x = 0,   y = 0  },
    {x = 35,  y = -60},
    {x = 80,  y =  30},
    {x = 120, y =  10},
    {x = 150, y = -40},
    {x = 190, y =  45},
    {x = 240, y =  5 },
    {x = 260, y = -55},
    {x = 330, y = -50},
    {x = 360, y =  15},
}

-- 春节特效配置
local SPRING_FESTIVAL_EFFECT_CFG = {
    TIME = 4,               -- 时间为4秒
    DISTANCE = 1680,        -- 播放距离为1680像素
    MARGIN_TIME = 3600 * 3, -- 动画重复触发时间间隔为3小时
}

function SpringFestivalAnimateMgr:init()
    self:startSchedule()
end

function SpringFestivalAnimateMgr:startSchedule()
    self:stopUpdate()
    self.updateId = gf:Schedule(function()
        SpringFestivalAnimateMgr:refreshActivity()
    end, 1)
end

function SpringFestivalAnimateMgr:stopUpdate()
    if self.updateId then
        gf:Unschedule(self.updateId)
        self.updateId = nil
    end
end

function SpringFestivalAnimateMgr:clearData()
    self.effectPlayedTime = nil
    self.tickCreateIcon = nil
    self.delayClearIconAction = nil

    self:clearSpringFectivalPetIcon()
    self:clearSpringFectivalPetRunEffect()

    EventDispatcher:removeEventListener(EVENT.TOUCH_MAP_BEGIN, self.performClearPetIcon, self)
end

-- 检查是否在活动时间内
function SpringFestivalAnimateMgr:checkInActivityTime()
    local serverTime = gf:getServerTime()
    local curTime = tonumber(gf:getServerDate("%Y%m%d%H%M%S", serverTime))
    if (DistMgr:curIsTestDist() and curTime >= ACTIVITY_TIME.TEST_START and curTime <= ACTIVITY_TIME.TEST_END)
        or (curTime >= ACTIVITY_TIME.START and curTime <= ACTIVITY_TIME.END) then
        return true
    end

    return false
end

-- 刷新活动状态
function SpringFestivalAnimateMgr:refreshActivity()
    if not GameMgr.initDataDone or GameMgr:isInBackground() then return end

    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if not dlg then return end

    if not self:checkInActivityTime() then return end

    if Me:isInCombat() or Me:isLookOn() then
        self.tickCreateIcon = nil
        return
    end

    -- 已经在主界面上创建过图标了
    if dlg.root:getChildByName("SpringFestivalPetLayer") then
        if not Me:isStandAction() then
            self:performClearPetIcon()
        end

        return
    end

    -- 获取Me当前触发效果的时间
    if not self.effectPlayedTime then
        local key = string.format("SpringFestivalAnimate_%s", Me:queryBasic("gid"))
        self.effectPlayedTime = cc.UserDefault:getInstance():getIntegerForKey(key, 0)
    end

    local serverTime = gf:getServerTime()

    -- 距离上一次触发时间在时间间隔限制范围内
    if self.effectPlayedTime > 0 and (serverTime - self.effectPlayedTime) < SPRING_FESTIVAL_EFFECT_CFG.MARGIN_TIME then return end

    if not self.tickCreateIcon then
        -- 计时玩家站立状态
        self.tickCreateIcon = gfGetTickCount()
    end

    if Me:isStandAction() then
        local curTick = gfGetTickCount()
        if curTick - self.tickCreateIcon >= 30000 then
            -- 站立30s，主界面创建图标
            self:createSpringFestivalPet()
            self.tickCreateIcon = nil
        end
    else
        -- 非站立状态，清除创建动画图标的tick
        self.tickCreateIcon = nil
    end
end

-- 主界面上创建福禄猪模型
function SpringFestivalAnimateMgr:createSpringFestivalPet()
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")

    if not dlg or GameMgr.curMainUIState == MAIN_UI_STATE.STATE_NOTHING then return end

    if dlg.root:getChildByName("SpringFestivalPetLayer") then return end

    local mallButton = dlg:getControl("MallButton")
    local sz = mallButton:getContentSize()
    local petLayer = ccui.Layout:create()
    petLayer:setContentSize(sz)
    petLayer:setName("SpringFestivalPetLayer")
    dlg.root:addChild(petLayer)

    local pos = dlg.root:convertToNodeSpace(cc.p(mallButton:convertToWorldSpace(cc.p(0, 0))))
    if GameMgr.curMainUIState == MAIN_UI_STATE.STATE_HIDE then
        petLayer:setPosition(pos.x + sz.width * 2 + 80 - sz.width / 2, pos.y - sz.height / 2)
    else
        petLayer:setPosition(pos.x + sz.width / 2 + 80 - sz.width / 2, pos.y - sz.height / 2)
    end

    -- 福禄猪模型
    local fuluzhu = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.fuluzhu, "02042")
    if not fuluzhu then return end

    DragonBonesMgr:toPlay(fuluzhu, "stand", 0)
    fuluzhu = tolua.cast(fuluzhu, "cc.Node")
    fuluzhu:setPosition(sz.width / 2, sz.height / 2)
    petLayer:addChild(fuluzhu)

    petLayer:setTouchEnabled(true)
    petLayer:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local pos = cc.p(sender:convertToWorldSpace(cc.p(0, 0)))
            pos.x = pos.x + sz.width / 2
            pos.y = pos.y + sz.height / 2
            self:startSpringFestivalPetRunEffect(pos)
            self:createClickPetEffect(fuluzhu:convertToWorldSpace(cc.p(0, 0)))
            self:clearSpringFectivalPetIcon()
            self:recordRemoveIconTime()
        end
    end)

    -- 主界面显示宠物图标后，开始监听点击地板事件
    EventDispatcher:addEventListener(EVENT.TOUCH_MAP_BEGIN, self.performClearPetIcon, self)
end

-- 创建福禄猪点击之后炸开特效
function SpringFestivalAnimateMgr:createClickPetEffect(pos)
    local magic = gf:createSelfRemoveMagic(ResMgr.magic.bainian_fuluzhu)
    magic:setPosition(pos)
    gf:getUILayer():addChild(magic)
end

-- 记录待机结束的时间
function SpringFestivalAnimateMgr:recordRemoveIconTime()
    local serverTime = gf:getServerTime()
    local key = string.format("SpringFestivalAnimate_%s", Me:queryBasic("gid"))
    cc.UserDefault:getInstance():setIntegerForKey(key, serverTime)
    self.effectPlayedTime = serverTime
end

-- 清除主界面宠物图标
function SpringFestivalAnimateMgr:clearSpringFectivalPetIcon()
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if not dlg then return end

    local iconLayer = dlg.root:getChildByName("SpringFestivalPetLayer")
    if iconLayer then
        iconLayer:removeFromParent()
        iconLayer = nil

        DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.fuluzhu, "02042")
    end

    EventDispatcher:removeEventListener(EVENT.TOUCH_MAP_BEGIN, self.performClearPetIcon, self)
end

-- 开始春节宠物奔跑特效
function SpringFestivalAnimateMgr:startSpringFestivalPetRunEffect(pos)
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if not dlg or GameMgr.curMainUIState == MAIN_UI_STATE.STATE_NOTHING then return end

    local root = gf:getTopLayer()
    local rootSize = root:getContentSize()
    local effectLayer = root:getChildByName("SpringFestivalLayer")
    if effectLayer then
        effectLayer:removeAllChildren()
    else
        effectLayer = cc.Layer:create()
        effectLayer:setContentSize(rootSize)
        effectLayer:setName("SpringFestivalLayer")
        root:addChild(effectLayer)
    end

    for i = 1, #SPRING_FESTIVAL_PET_POS do
        local char = CharAction.new()
        char:set(50209, nil, Const.SA_WALK, 4)

        -- 速度是正常walk的5倍
        char:setAnimationSpeed(5)

        effectLayer:addChild(char)
        local offsetCfg = SPRING_FESTIVAL_PET_POS[i]
        local charPos = cc.p(pos.x - offsetCfg.x, pos.y - offsetCfg.y)
        char:setPosition(charPos)

        local moveAction = cc.MoveTo:create(SPRING_FESTIVAL_EFFECT_CFG.TIME,
            cc.p(charPos.x + SPRING_FESTIVAL_EFFECT_CFG.DISTANCE + 360, charPos.y))
        char:runAction(cc.Sequence:create(moveAction, cc.RemoveSelf:create()))
    end

    -- 春节快乐
    performWithDelay(root, function()
        local effectLayer = gf:getTopLayer():getChildByName("SpringFestivalLayer")
        if effectLayer then
            local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.spring_festival_happy.name,
                "Top", effectLayer, nil, nil, nil, rootSize.width / 2, rootSize.height / 2 - 80, 999)
            magic:setScale(1.1)
        end
    end, 1)

    -- 烟花特效
    performWithDelay(root, function()
        local effectLayer = gf:getTopLayer():getChildByName("SpringFestivalLayer")
        if effectLayer then
            local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.funny_magic.name,
                "Top01", effectLayer, nil, nil, nil, SPRING_FESTIVAL_EFFECT_CFG.DISTANCE / 2 - 160, rootSize.height / 2, 998)
        end
    end, 0.3)

    performWithDelay(root, function()
        -- 移除动画层
        SpringFestivalAnimateMgr:clearSpringFectivalPetRunEffect()
    end, SPRING_FESTIVAL_EFFECT_CFG.TIME + 0.1)
end

-- 清除春节宠物奔跑特效
function SpringFestivalAnimateMgr:clearSpringFectivalPetRunEffect()
    local effectLayer = gf:getTopLayer():getChildByName("SpringFestivalLayer")
    if effectLayer then
        effectLayer:removeFromParent()
        effectLayer = nil

        gf:CmdToServer("CMD_SPRING_2019_BNDH", {})
    end
end

-- 延迟10s移除主界面宠物图标
function SpringFestivalAnimateMgr:performClearPetIcon()
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        local petLayer = dlg.root:getChildByName("SpringFestivalPetLayer")
        if petLayer and not self.delayClearIconAction then
            self.delayClearIconAction = performWithDelay(petLayer, function()
                self:clearSpringFectivalPetIcon()
                self.delayClearIconAction = nil
                self:recordRemoveIconTime()
            end, 10)
        end
    end
end

-- 过图
function SpringFestivalAnimateMgr:MSG_ENTER_ROOM()
    self:clearSpringFectivalPetRunEffect()
end

-- 进入战斗
function SpringFestivalAnimateMgr:onEnterCombat()
    self:MSG_ENTER_ROOM()
end

MessageMgr:hook("MSG_ENTER_ROOM", SpringFestivalAnimateMgr, "SpringFestivalAnimateMgr")
EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, SpringFestivalAnimateMgr.onEnterCombat, SpringFestivalAnimateMgr)
