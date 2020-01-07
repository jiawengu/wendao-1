-- NumerologyDlg.lua
-- Created by lixh Mar/24 2018
-- 神算子占卜界面

local NumerologyDlg = Singleton("NumerologyDlg", Dialog)

-- 占卜阶段
local ZHANBU_STEP = {
    XUANQIAN = 1,  -- 选签
    YAOQIAN = 2,   -- 摇签
    CHUQIAN = 3,   -- 出签
}

-- 签筒类型
local CONTAINER_TYPE = {
    [NUMEROLOGY_TYPE.RUYI] = {name = CHS[7100220], effect = CHS[7100225]},   -- 如意签
    [NUMEROLOGY_TYPE.XINGYU] = {name = CHS[7100221], effect = CHS[7100226]}, -- 幸运签
    [NUMEROLOGY_TYPE.WANFU] = {name = CHS[7100222], effect = CHS[7100227]},  -- 万福签
}

-- 占卜类型
local COST_TYPE = {
    SUISHOU = 1,    -- 随手一算
    QIANCHENG = 2,  -- 虔诚求运
}

-- 金钱消耗
local CASH_COST = 2000000
local GOLD_COST = 100

-- 签筒名称
local CONTAINER_NAME = "PotPanel"

-- 签筒移动规则
local CONTAINER_RULE = {
    {1, 2, 3},
    {2, 3, 1},
    {3, 1, 2},
}

-- 第1个签筒下标左右移动后的值
local CONTAINER_FIRST_INDEX = {
    {left = 2, right = 3},
    {left = 3, right = 1},
    {left = 1, right = 2},
}

-- 出签Panel一列最多显示串长
local MAX_STR_LEN = 13
local THREE_LABEL_NUM = 39
local MAX_LABLE_NUM = 65

-- 签筒缩小的scale
local CONTAINER_MIN_SCALE = 0.7

-- 签筒颜色
local CONTAIER_COLOR = {mid = COLOR3.WHITE, otherSide = cc.c3b(179, 179, 179)}

-- 签筒动画配置，3种签筒，每种签筒2种签
local MAGIC_CONFIG = {
    [NUMEROLOGY_TYPE.RUYI] = {{shake = "Bottom09", chuqian = "Bottom10", floor = "Bottom11", static = "Bottom12"},  -- 如意签 普通
        {shake = "Bottom13", chuqian = "Bottom14", floor = "Bottom15", static = "Bottom16"}},                       -- 如意签 付费
    [NUMEROLOGY_TYPE.XINGYU] = {{shake = "Bottom01", chuqian = "Bottom02", floor = "Bottom03", static = "Bottom04"},-- 幸运签 普通
        {shake = "Bottom05", chuqian = "Bottom06", floor = "Bottom07", static = "Bottom08"}},                       -- 幸运签 付费
    [NUMEROLOGY_TYPE.WANFU] = {{shake = "Bottom17", chuqian = "Bottom18", floor = "Bottom19", static = "Bottom20"}, -- 万福签 普通
        {shake = "Bottom21", chuqian = "Bottom22", floor = "Bottom23", static = "Bottom24"}},                       -- 万福签 付费
}

-- 签筒动画时间
local CONTAINER_ACTION_TIME = 0.5

-- 左右签筒移动消失的距离
local CONTAINER_DISAPPEAR_LENGTH = 50

-- 签筒触摸区域触发事件需要滑动的距离
local CONTAINER_ACTION_DIS = 25

-- 占卜等级要求
local LEVEL_REQUEST = 70

-- 摇签重力值检测时间间隔
local CHECK_ACC_TIME = 1

-- 重新检测摇签动画播放时间间隔
local CHECK_SHAKE_MAGIC_TIME = 0.2

-- 摇签重力变化值达到条件播动画
local FILL_ACC_VALUE = 0.8

-- 摇签动画最大播放次数
local MAX_SHAKE_TIME = 1

-- 签文显示的总时间
local STICK_TEXT_TIME = 0.1

-- 签文颜色
local STICK_TEXT_COLOR1 = cc.c3b(128, 75, 38)
local STICK_TEXT_COLOR2 = cc.c3b(183, 134, 127)

-- 重力Y值返回
local ACC_Y = {MAX = 0.5, MIN = -1}

-- 动画标记
local STATIC_MAGIC_TAG = 999
local SHAKE_MAGIC_TAG = 9999
local CHUQIAN_MAGIC_TAG = 9998
local SHANKE_GUIDE_TAG = 9997

function NumerologyDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("BKImage2", "BKPanel", true)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindFloatPanelListener("RulePanel")
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("ReturnPanel", self.onCloseButton)
    self:bindListener("PotPanel1", self.onPotButton)
    self:bindListener("PotPanel2", self.onPotButton)
    self:bindListener("PotPanel3", self.onPotButton)
    self:bindListener("Button", self.onCostMoneyButton, "BaitButtonPanel1")
    self:bindListener("Button", self.onCostMoneyButton, "BaitButtonPanel2")
    self:bindListener("CloseImagePanel", self.onCloseStick, "ResultPanel")

    -- 初始化签筒位置信息
    self.firstIndex = 1
    self.leftPosX, self.leftPosY = self:getControl(CONTAINER_NAME .. 1):getPosition()
    self.leftDisappearX = self.leftPosX - CONTAINER_DISAPPEAR_LENGTH
    self.leftDisappearY = self.leftPosY
    self.midPosX, self.midPosY = self:getControl(CONTAINER_NAME .. 2):getPosition()
    self.rightPosX, self.rightPosY = self:getControl(CONTAINER_NAME .. 3):getPosition()
    self.rightDisappearX = self.rightPosX + CONTAINER_DISAPPEAR_LENGTH
    self.rightDisappearY = self.rightPosY
    self.doingAction = false

    self.touchPanelBeginPos = nil
    self:bindLotPotTouchEvent()

    self:setDlgByStep(ZHANBU_STEP.XUANQIAN)

    self:setLabelText("TypeLabel", CONTAINER_TYPE[self:getContainerChoose()].effect, "TypeTextPanel")

    self:hookMsg("MSG_DIVINE_START_GAME")
    self:hookMsg("MSG_DIVINE_END_GAME")
    self:hookMsg("MSG_DIVINE_GAME_RESULT")
    self:hookMsg("MSG_UPDATE")

    EventDispatcher:addEventListener('ENTER_FOREGROUND', self.restartAcceleration, self)
end

-- 添加摇签状态静止特效
function NumerologyDlg:addShakeStaticMagic()
    self:removeShakeStaticMagic()
    local panel = self:getControl("ShakePanel")
    local action = MAGIC_CONFIG[self:getContainerChoose()][self.costType].static
    gf:createArmatureMagic({name = ResMgr.ArmatureMagic.zhanbu_yaoqian.name, action = action}, panel, STATIC_MAGIC_TAG)
end

-- 移除摇签状态静止特效
function NumerologyDlg:removeShakeStaticMagic()
    local panel = self:getControl("ShakePanel")
    if panel:getChildByTag(STATIC_MAGIC_TAG) then
        panel:removeChildByTag(STATIC_MAGIC_TAG)
    end
end

-- 播放摇签动画
function NumerologyDlg:playShakeMagic()
    local panel = self:getControl("ShakePanel")
    if panel:getChildByTag(SHAKE_MAGIC_TAG) then
        panel:removeChildByTag(SHAKE_MAGIC_TAG)
    end

    self:removeShakeStaticMagic()
    self.isPlayingMagic = true
    if self.shakeTimes == MAX_SHAKE_TIME then
        -- 摇签次数达到摇签，请求出签
        self:playChuQianMagic()
    else
        SoundMgr:playEffect("yaoqian")
        local action = MAGIC_CONFIG[self:getContainerChoose()][self.costType].shake
        local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.zhanbu_yaoqian.name, action, panel, function()
            self:addShakeStaticMagic()
            self.isPlayingMagic = false
            self.lastTime = gfGetTickCount()
            self.termAccMin = ACC_Y.MAX
            self.tearmAccMax = ACC_Y.MIN

            self.shakeTimes = self.shakeTimes + 1
        end)

        magic:setTag(SHAKE_MAGIC_TAG)
    end
end

-- 播放出签动画
function NumerologyDlg:playChuQianMagic()
    local panel = self:getControl("ShakePanel")
    if panel:getChildByTag(CHUQIAN_MAGIC_TAG) then
        panel:removeChildByTag(CHUQIAN_MAGIC_TAG)
    end

    self:removeShakeStaticMagic()
    SoundMgr:playEffect("diaoqian")
    local action = MAGIC_CONFIG[self:getContainerChoose()][self.costType].chuqian
    local magic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.zhanbu_yaoqian.name, action, panel, function()
        self.getStickSucc = true
        self:askForEndShakeStick()
        local action = MAGIC_CONFIG[self:getContainerChoose()][self.costType].floor
        gf:createArmatureMagic({name = ResMgr.ArmatureMagic.zhanbu_yaoqian.name, action = action}, panel)
    end)

    magic:setTag(CHUQIAN_MAGIC_TAG)
end

-- 设置界面状态
function NumerologyDlg:setDlgByStep(step)
    self.zhanbuStep = step
    self:setCtrlVisible("MainPanel", step == ZHANBU_STEP.XUANQIAN)
    self:setCtrlVisible("ShakePanel", step == ZHANBU_STEP.YAOQIAN)
    self:setCtrlVisible("ResultPanel", step == ZHANBU_STEP.CHUQIAN)

    if step == ZHANBU_STEP.XUANQIAN then
        self:setCostInfo()
        self:setMoneyPanel()
        local panel = self:getControl("ShakePanel")
        if panel:getChildByTag(SHAKE_MAGIC_TAG) then
            panel:removeChildByTag(SHAKE_MAGIC_TAG)
        end

        if panel:getChildByTag(CHUQIAN_MAGIC_TAG) then
            panel:removeChildByTag(CHUQIAN_MAGIC_TAG)
        end
    elseif step == ZHANBU_STEP.YAOQIAN then
        -- 进入摇签阶段，界面增加重力，监听变化值，播放抽签动画
        self:addShakeStaticMagic()
        self:addAccToDlg()

        -- 摇签界面需要播放指引特效
        local panel = self:getControl("ShakePanel")
        local magicPanel = self:getControl("TypeTextPanel", nil, panel)
        if not magicPanel:getChildByTag(SHANKE_GUIDE_TAG) then
            local sz = magicPanel:getContentSize()
            local offsetX = -sz.width / 2 + 50
            gf:createArmatureMagic(ResMgr.ArmatureMagic.zhanbu_yaoqian_guide, magicPanel, SHANKE_GUIDE_TAG, offsetX)
        end
    end
end

-- 签筒移动完毕后，刷新签筒颜色，当前选中的签筒奖励提示
function NumerologyDlg:refreshContainerAndTips()
    local order = CONTAINER_RULE[self.firstIndex]
    for i = 1, #order do
        local image = self:getControl("PotImage", Const.UIImage, CONTAINER_NAME .. order[i])
        if i == 2 then
            image:setColor(CONTAIER_COLOR.mid)
        else
            image:setColor(CONTAIER_COLOR.otherSide)
        end
    end

    self:setLabelText("TypeLabel", CONTAINER_TYPE[self:getContainerChoose()].effect, "TypeTextPanel")
end

-- 播放右移/左移的动作
function NumerologyDlg:doAction(type)
    local order = CONTAINER_RULE[self.firstIndex]
    local container1 = self:getControl(CONTAINER_NAME .. order[1])
    local container2 = self:getControl(CONTAINER_NAME .. order[2])
    local container3 = self:getControl(CONTAINER_NAME .. order[3])
    self:doContainerOneAction(container1, type)
    self:doContainerTwoAction(container2, type)
    self:doContainerThrAction(container3, type)

    self.firstIndex = CONTAINER_FIRST_INDEX[self.firstIndex][type]
end

-- 播第1个签筒的action
function NumerologyDlg:doContainerOneAction(panel, type)
    if type == "right" then
        -- 第1个筒向右：移动，变大
        local moveAction = cc.MoveTo:create(CONTAINER_ACTION_TIME, cc.p(self.midPosX, self.midPosY))
        local scaleAction = cc.ScaleTo:create(CONTAINER_ACTION_TIME, 1)
        panel:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction)))
    else
        -- 第1个筒向左：先淡出，再淡入
        local callfunc = cc.CallFunc:create(function()
            panel:setPosition(cc.p(self.rightPosX + CONTAINER_DISAPPEAR_LENGTH, self.rightPosY))
            local fadeInAction = cc.FadeIn:create(CONTAINER_ACTION_TIME / 2)
            local moveTwoAction = cc.MoveTo:create(CONTAINER_ACTION_TIME / 2, cc.p(self.rightPosX, self.rightPosY))
            panel:runAction(cc.Sequence:create(cc.Spawn:create(fadeInAction, moveTwoAction)))
        end)

        local fadeOutAction = cc.FadeOut:create(CONTAINER_ACTION_TIME / 2)
        local moveOneAction = cc.MoveTo:create(CONTAINER_ACTION_TIME / 2, cc.p(self.leftPosX - CONTAINER_DISAPPEAR_LENGTH, self.leftPosY))
        panel:runAction(cc.Sequence:create(cc.Spawn:create(fadeOutAction, moveOneAction), callfunc))
    end
end

-- 播第2个签筒的action
function NumerologyDlg:doContainerTwoAction(panel, type)
    local targetX = type == "right" and self.rightPosX or self.leftPosX
    local targetY = type == "right" and self.rightPosY or self.leftPosY

    -- 第2个筒向右或向左：移动，变小
    local moveAction = cc.MoveTo:create(CONTAINER_ACTION_TIME, cc.p(targetX, targetY))
    local scaleAction = cc.ScaleTo:create(CONTAINER_ACTION_TIME, CONTAINER_MIN_SCALE)
    panel:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction)))
end

-- 播第3个签筒的action
function NumerologyDlg:doContainerThrAction(panel, type)
    if type == "right" then
        -- 第3个筒向右：先淡出，再淡入
        local callfunc = cc.CallFunc:create(function()
            panel:setPosition(cc.p(self.leftPosX - CONTAINER_DISAPPEAR_LENGTH, self.leftPosY))
            local fadeInAction = cc.FadeIn:create(CONTAINER_ACTION_TIME / 2)
            local moveTwoAction = cc.MoveTo:create(CONTAINER_ACTION_TIME / 2, cc.p(self.leftPosX, self.leftPosY))
            panel:runAction(cc.Sequence:create(cc.Spawn:create(fadeInAction, moveTwoAction), cc.CallFunc:create(function()
                self.doingAction = false
                self:refreshContainerAndTips()
            end)))
        end)

        local fadeOutAction = cc.FadeOut:create(CONTAINER_ACTION_TIME / 2)
        local moveOneAction = cc.MoveTo:create(CONTAINER_ACTION_TIME / 2, cc.p(self.rightPosX + CONTAINER_DISAPPEAR_LENGTH, self.rightPosY))
        panel:runAction(cc.Sequence:create(cc.Spawn:create(fadeOutAction, moveOneAction), callfunc))
    else
        -- 第3个筒向左：移动，变大
        local moveAction = cc.MoveTo:create(CONTAINER_ACTION_TIME, cc.p(self.midPosX, self.midPosY))
        local scaleAction = cc.ScaleTo:create(CONTAINER_ACTION_TIME, 1)
        panel:runAction(cc.Sequence:create(cc.Spawn:create(moveAction, scaleAction), cc.CallFunc:create(function()
            self.doingAction = false
            self:refreshContainerAndTips()
        end)))
    end
end

-- 界面增加重力感应
function NumerologyDlg:addAccToDlg()
    self.layer = cc.Layer:create()
    self.layer:setAccelerometerEnabled(true)

    -- 初始化动画播放次数
    self.shakeTimes = 0

    -- 重力感应回调函数: x > 0：右， x < 0：左，y > 0：下， y < 0：上
    self.lastTime = gfGetTickCount()
    self.termAccMin = ACC_Y.MAX
    self.tearmAccMax = ACC_Y.MIN
    local function accelerometerListener(event, x, y, z, timestamp)
        -- 非摇签阶段不需要重力回调响应
        if self.zhanbuStep ~= ZHANBU_STEP.YAOQIAN then
            return
        end

        -- 当前正在摇签，不更新数据
        -- 策划增加，正在摇签时，若播放动画已经过了0.2秒，则可以重新检测摇签动画播放条件
        if self.isPlayingMagic and self.playMagicTime - gfGetTickCount() < CHECK_SHAKE_MAGIC_TIME * 1000 then
            return
        end

        if gfGetTickCount() - self.lastTime > CHECK_ACC_TIME * 1000 then
            -- 时间到达检测的上限，清空之前记录的值
            self.termAccMin = ACC_Y.MAX
            self.tearmAccMax = ACC_Y.MIN
            self.lastTime = gfGetTickCount()
        else
            -- 尝试判断区间的返回是否大于 播放动画的条件
            self.termAccMin = math.min(self.termAccMin, ACC_Y.MAX, y)
            self.tearmAccMax = math.max(self.tearmAccMax, ACC_Y.MIN, y)
            if self.tearmAccMax - self.termAccMin > FILL_ACC_VALUE then
                self.playMagicTime = gfGetTickCount()
                self:playShakeMagic()
            end
        end
    end

    local listener = cc.EventListenerAcceleration:create(accelerometerListener)
    self.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.layer)
    self.root:addChild(self.layer)
end

-- 设置金钱数量
function NumerologyDlg:setMoneyPanel()
    local cash = Me:queryBasicInt('cash')
    local cashText, cashColor = gf:getMoneyDesc(cash, true)
    if cash < 100000 then cashColor = COLOR3.WHITE end
    self:setLabelText("MoneyValueLabel", cashText, "BaitPanel", cashColor)

    local silverCoin = Me:queryBasicInt("silver_coin")
    local silverText, silvalColor = gf:getMoneyDesc(silverCoin, true)
    if silverCoin < 100000 then silvalColor = COLOR3.WHITE end
    self:setLabelText("SilverCoinValueLabel", silverText, "MoneyPanel1", silvalColor)

    local goldCoin = Me:queryBasicInt("gold_coin")
    local goldText, goldColor = gf:getMoneyDesc(Me:queryBasicInt("gold_coin"), true)
    if goldCoin < 100000 then goldColor = COLOR3.WHITE end
    self:setLabelText("GoldCoinValueLabel", goldText, "MoneyPanel2", goldColor)
end

-- 设置占卜消耗
function NumerologyDlg:setCostInfo()
    local cashText, fontColor = gf:getMoneyDesc(CASH_COST, true)
    if CASH_COST < 100000 then fontColor = COLOR3.WHITE end
    self:setLabelText("NumLabel", cashText, "BaitButtonPanel1", fontColor)
    local goldText, goldColor = gf:getMoneyDesc(GOLD_COST, true)
    if GOLD_COST < 100000 then goldColor = COLOR3.WHITE end
    self:setLabelText("NumLabel", goldText, "BaitButtonPanel2", goldColor)
end

-- 设置签文内容
function NumerologyDlg:setStickDesPanel(data)
    local panel = self:getControl("PotTextPanel", nil, "ResultPanel")
    self:setCtrlVisible("SignImage1", data.type == 1, "ResultPanel")
    self:setCtrlVisible("SignImage2", data.type == 2, "ResultPanel")
    self:setCtrlVisible("TypePanel1", data.type == 2, "ResultPanel")
    self:setCtrlVisible("TypePanel2", data.type == 1, "ResultPanel")

    -- 先清除所有文字
    for i = 1, MAX_LABLE_NUM do
        self:setLabelText("TextLabel" .. i, "", panel)
        self:setCtrlVisible("TextLabel" .. i, false, panel)
    end

    local startIndex = 1
    local textList = self:getTextListAndColor(data.des)
    local textIndex = 1
    local len = #textList
    if len <= MAX_STR_LEN then
        -- 只有1列文字，在第2列居中显示
        local startIndex = math.floor((MAX_STR_LEN - len) / 2) + 1
        for i = startIndex + THREE_LABEL_NUM / 3, THREE_LABEL_NUM / 3 * 2 do
            if textList[textIndex] then
                self:setLabelText("TextLabel" .. i, textList[textIndex].str, panel, textList[textIndex].color)
                textIndex = textIndex + 1
            end
        end
    elseif len <= MAX_STR_LEN * 2 then
        -- 2列文字，策划用了新控件显示
        startIndex = 40
        for i = startIndex, startIndex + MAX_STR_LEN * 2 do
            if textList[textIndex] then
                self:setLabelText("TextLabel" .. i, textList[textIndex].str, panel, textList[textIndex].color)
                textIndex = textIndex + 1
            end
        end
    else
        -- 3列文字
        startIndex = 1
        for i = 1, THREE_LABEL_NUM do
            if textList[textIndex] then
                self:setLabelText("TextLabel" .. i, textList[textIndex].str, panel, textList[textIndex].color)
                textIndex = textIndex + 1
            end
        end
    end

    -- 文字表现效果
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            self:setCtrlVisible("TextLabel" .. startIndex, true, panel)
            local ctrl = self:getControl("TextLabel" .. startIndex, nil, panel)
            ctrl:setOpacity(0)
            ctrl:runAction(cc.FadeIn:create(STICK_TEXT_TIME))

            startIndex = startIndex + 1
            if startIndex == MAX_LABLE_NUM then
                self:clearSchedule()
            end
        end, STICK_TEXT_TIME)
    end
end

-- 签文逐个字显示，有些字需要显示颜色
function NumerologyDlg:getTextListAndColor(text)
    local textList = {}
    local colorStr = string.match(text, "#R(.+)#n")
    if colorStr then
        local normalColorStr1 = string.match(text, "(.+)#R" .. colorStr)
        local normalColorStr2 = string.match(text, colorStr .. "#n(.+)")
        textList = self:convertTextToListWithColor(normalColorStr1, COLOR3.TEXT_DEFAULT, textList)
        textList = self:convertTextToListWithColor(colorStr, COLOR3.RED, textList)
        textList = self:convertTextToListWithColor(normalColorStr2, COLOR3.TEXT_DEFAULT, textList)
    else
        textList = self:convertTextToListWithColor(text, COLOR3.TEXT_DEFAULT, textList)
    end

    return textList
end

function NumerologyDlg:convertTextToListWithColor(text, color, list)
    if text then
        local textList = gf:convertTextToCharList(text)
        for i = 1, #textList do
            table.insert(list, {str = textList[i], color = color})
        end
    end

    return list
end

-- 停止倒计时
function NumerologyDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end
end

-- 获取当前选中的签筒下标
function NumerologyDlg:getContainerChoose()
    return CONTAINER_RULE[self.firstIndex][2]
end

function NumerologyDlg:cleanup()
    self.firstIndex = 1
    self.doingAction = false
    self.touchPanelBeginPos = nil
    self.costType = nil
    self.getStickSucc = nil
    self.shakeTimes = 0
    self.isPlayingMagic = false
    self.playMagicTime = nil
    self.termAccMin = ACC_Y.MIN
    self.tearmAccMax = ACC_Y.MAX
    self:clearSchedule()

    self.layer = nil
    EventDispatcher:removeEventListener('ENTER_FOREGROUND', self.restartAcceleration, self)
end

-- 部分手机系统(如小米，华为部分系统)会有智能省电模式，在切后台时会为了省电会关闭传感器
-- 导致重力加速度计无法接受到重力变化值，所以切回前台时需要重新请求开启重力加速度计
function NumerologyDlg:restartAcceleration()
    if self.layer then
        self.layer:setAccelerometerEnabled(true)
    end
end

-- 签筒触摸区域
function NumerologyDlg:bindLotPotTouchEvent()
    local panel = self:getControl("TouchPanel", Const.UIPanel, "MainPanel")
    local function onTouchBegan(touch, event)
        self.touchPanelBeginPos = nil
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        local rulePanel = self:getControl("RulePanel", Const.UIPanel)
        if rulePanel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            self.touchPanelBeginPos = touchPos
            return true
        end

        return false
    end

    local function onTouchEnd(touch, event)
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if box and cc.rectContainsPoint(box, touchPos) then
            if not self.touchPanelBeginPos then return end
            if self.touchPanelBeginPos.x > touchPos.x + CONTAINER_ACTION_DIS then
                self:onLeftButton()
            elseif self.touchPanelBeginPos.x < touchPos.x - CONTAINER_ACTION_DIS then
                self:onRightButton()
            end
        end

        self.touchPanelBeginPos = nil
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 关闭界面
function NumerologyDlg:onCloseButton(sender, eventType)
    if self.zhanbuStep == ZHANBU_STEP.YAOQIAN then
        self:askForEndShakeStick()
    else
        Dialog.onCloseButton(self)
    end
end

-- 点击签筒
function NumerologyDlg:onPotButton(sender, eventType)
    if self.doingAction then return end
    local posX, posY = sender:getPosition()
    if posX == self.leftPosX and posY == self.leftPosY then
        self:onRightButton()
    elseif posX == self.rightPosX and posY == self.rightPosY then
        self:onLeftButton()
    end
end

function NumerologyDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function NumerologyDlg:onLeftButton(sender, eventType)
    if not self.doingAction then
        self.doingAction = true
        self:doAction("left")
    end
end

function NumerologyDlg:onRightButton(sender, eventType)
    if not self.doingAction then
        self.doingAction = true
        self:doAction("right")
    end
end

-- 随手一算，虔诚求运
function NumerologyDlg:onCostMoneyButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    if Me:getLevel() < 70 then
        gf:ShowSmallTips(CHS[7100215])
        return
    end

    if self:checkSafeLockRelease("onCostMoneyButton", sender) then
        return
    end

    local parentName = sender:getParent():getName()
    if parentName == "BaitButtonPanel1" then
        -- 消耗金钱
        self.costType = COST_TYPE.SUISHOU
        self:askForShakeStick()
    else
        -- 消耗元宝
        self.costType = COST_TYPE.QIANCHENG
        self:askForShakeStick()
    end
end

-- 请求开始摇签
function NumerologyDlg:askForShakeStick()
    gf:CmdToServer("CMD_DIVINE_START_GAME", {stick = self:getContainerChoose(), type = self.costType})
end

-- 请求结束摇签
function NumerologyDlg:askForEndShakeStick()
    if self.zhanbuStep == ZHANBU_STEP.YAOQIAN then
        gf:CmdToServer("CMD_DIVINE_END_GAME", {stick = self:getContainerChoose(), type = self.costType, isOk = self.getStickSucc and 1 or 0})
    end
end

-- 关闭签文界面
function NumerologyDlg:onCloseStick()
    self:onCloseButton()
end

-- 开始摇签
function NumerologyDlg:MSG_DIVINE_START_GAME(data)
    self:setDlgByStep(ZHANBU_STEP.YAOQIAN)
end

-- 结束摇签
function NumerologyDlg:MSG_DIVINE_END_GAME(data)
    if data.isOk == 0 then
        self:setDlgByStep(ZHANBU_STEP.XUANQIAN)
    elseif data.isOk == -1 then
        Dialog.onCloseButton(self)
    end
end

-- 通知摇签结果
function NumerologyDlg:MSG_DIVINE_GAME_RESULT(data)
    self:setDlgByStep(ZHANBU_STEP.CHUQIAN)
    self:setStickDesPanel(data)
end

-- 尝试刷新金钱
function NumerologyDlg:MSG_UPDATE()
    self:setMoneyPanel()
end

return NumerologyDlg
