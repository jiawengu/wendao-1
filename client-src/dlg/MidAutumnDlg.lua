-- MidAutumnDlg.lua
-- Created by huangzz Aug/03/2017
-- 中秋节接月饼界面

local MidAutumnDlg = Singleton("MidAutumnDlg", Dialog)
local NumImg = require('ctrl/NumImg')

-- 速度
local RABBIT_SPEED = 304 -- 兔子的行走速度
local BEGIN_SPEED = 95   -- 月饼初始下落速度
local TIME_CHANGE = 8      -- 每 10 秒改变生成月饼时间间隔和加快下落速度
local INTERVAL_CHANGE = 0.1 -- 生成月饼时间每TIME_CHANGE秒减少的间隔
local SPEED_CHANGE = 12    -- 月饼下落速度每TIME_CHANGE秒 + 8像素/秒
local TIP_SHOW_TIME = 1.5   -- 积分提示显示时间
local TIP_SHOW_DIS = 10    -- 积分提示飘动距离


local CAN_GET_RANGEY = 32 -- 可以接住月饼的有效范围
local CAN_GET_RANGEX = 65 -- 可以接住月饼的有效范围

local MAP_RABBIT_HEIGHT = 165 -- 相对于完整地图的兔子的高度
local MAP_STAGE_HEIGHT = 172 -- 相对于完整地图的台子的高度

local CREAT_DIS = 10 + 50          -- 生成月饼间距
local CREAT_HEIGHT = 10

-- 光效
local DIZZINESS_OFFECTY = 15 --  眩晕离头顶下调高度
local GET_OFFECTY = 0 -- 接月饼光效离兔子中心高度
local POINT_OFFECTY = 60 -- 接月饼积分光效离兔子中心高度
local WALK_BOOT_OFFECTY = 15 -- 兔子奔跑脚底光效下移高度

local DIZZINESS_MAGIC_TAG = 99
local WALK_MAGIC_TAG = 66

local userDefault
local userDefaultKey
local userDefaultTimeKey

function MidAutumnDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel", "MainPanel")
    self:setCtrlFullClientEx("BubblePanel", nil, true)
    self:setCtrlFullClientEx("BKPanel_1", self:getControl("ResultPanel1", nil, "GameResultPanle"))
    self:setCtrlFullClientEx("BKPanel_1", self:getControl("ResultPanel_2", nil, "GameResultPanle"))
    self:setCtrlFullClientEx("BKPanel_1", "ChosePanel")
    self:setCtrlFullClientEx("BKPanel_1", "StorePanel")

    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_2")
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel1")

    self:bindListener("CloseImagePanel", self.onResultPanel, "ResultPanel_2")
    self:bindListener("CloseImagePanel", self.onResultPanel, "ResultPanel1")

    -- 打开游戏首次弹出的模式选择
    self:bindListener("DianjiPanel", self.onDianJiPanel)
    self:bindListener("ZhongLiPanel", self.onZhongLiPanel)
    self:bindListener("SupplyButton", self.onSupplyButton)

    -- 暂停游戏的panel
    self:bindListener("MenuButton1", self.onResumeGameButton)
    self:bindListener("MenuButton2", self.onMoShiChooseButton)
    self:bindListener("MenuButton8", self.onStopGameButton)

    self:setCtrlVisible("GameResultPanel", true)
    self:setCtrlVisible("ResultPanel_2", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel1", false, "GameResultPanel")

    self.wuRenPanel = self:retainCtrl("WuRenPanel", "MainPanel")
    self.douShaPanel = self:retainCtrl("DouShaPanel", "MainPanel")
    self.xianGongPanel = self:retainCtrl("XianGongPanel", "MainPanel")
    self.stonePanel = self:retainCtrl("StonePanel", "MainPanel")
    self.mooncakePanel = self:getControl("BubblePanel")

    -- 获取屏幕尺寸
    local winSize = cc.Director:getInstance():getWinSize()
    self.rootHeight = winSize.height / Const.UI_SCALE
    self.rootWidth = winSize.width / Const.UI_SCALE

    -- 加载背景图
    local dlgBack = ccui.ImageView:create(ResMgr.loadingPic.tianyong)
    dlgBack:setPosition(self.rootWidth / 2, self.rootHeight / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    dlgBack:setColor(cc.c3b(66, 66, 66))
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)

    --[[local bKPanel = self:getControl("BlackPanel", nil, "StopPanel")
    bKPanel:setContentSize(self.rootWidth, self.rootHeight)
    bKPanel = self:getControl("BlackPanel", nil, "ChosePanel")
    bKPanel:setContentSize(self.rootWidth, self.rootHeight)
    bKPanel = self:getControl("BlackPanel", nil, "StartPanel")
    bKPanel:setContentSize(self.rootWidth, self.rootHeight)
    bKPanel = self:getControl("BlackPanel", nil, "ResultPanel_2")
    bKPanel:setContentSize(self.rootWidth, self.rootHeight)
    bKPanel = self:getControl("BlackPanel", nil, "ResultPanel1")
    bKPanel:setContentSize(self.rootWidth, self.rootHeight)]]

    self.stageImage = self:getControl("GroundImage")

    -- 穿件兔子对象
    self:createRabbit()
    self:createArmature(ResMgr.ArmatureMagic.midautumn_score_magic.name)
    self.canMove = true
    self.running = false
    self.speed = BEGIN_SPEED  -- 月饼下落速度
    self.costTime = 0         -- 记录每个10秒内的时间
    self.costTotalTime = 0    -- 记录游戏开始后运行的总时间
    self.rabbitStatus = nil     -- 1 站住，2 向左走， 3 向右走，4 眩晕
    self.isFinish = false
    self.isPause = false
    self.enterBackground = false
    self.lastTime = nil

    self.root:requestDoLayout()

    self.mooncakes = {}
    self.info = data or {}

    self.isAccelerometer = nil
    userDefault = cc.UserDefault:getInstance()
    userDefaultKey = "isAccelerometer" .. gf:getShowId(Me:queryBasic("gid"))
    userDefaultTimeKey = "accelerometerTime" .. gf:getShowId(Me:queryBasic("gid"))
    local accelerometerTime = userDefault:getIntegerForKey(userDefaultTimeKey)
    local value = userDefault:getIntegerForKey(userDefaultKey)
    if value == 1 then
        self.isAccelerometer = true
    else
        self.isAccelerometer = false
    end

    -- 倒计时
    if data then
        local readyId
        local readyTime = data.ready_time - 1
        self:createCountDown(readyTime)

        if gf:isSameDay5(accelerometerTime, gf:getServerTime()) then
            -- 同一天，直接开启倒计时
            self:startCountDown(readyTime, function()
                -- 开始计时
                if not self.isPause then
                    self:showGameTime(true, data.game_time)
                    self.running = true
                end
            end)

            self:setCtrlVisible("ChosePanel", false)
        else
            -- 默认触屏点击
            self:setCtrlVisible("ChosePanel", true)
            self:setCtrlVisible("SelectImage", not self.isAccelerometer, "DianjiPanel")
            self:setCtrlVisible("SelectImage", self.isAccelerometer, "ZhongLiPanel")
            self.isChooseMoShi = true
            self:requestQuit("pause")
        end

        self:setColorText(gf:getServerDate("%M:%S", data.game_time), "NumPanel", "TimePanel", 0, 0, COLOR3.WHITE, 31)
    end

    -- 积分
    local panel = self:getControl("TotalNumLabel", Const.UIAtlasLabel)
    panel:setString("0")

    -- 注册事件
    self:hookMsg("MSG_AUTUMN_2017_FINISH")
    self:hookMsg("MSG_AUTUMN_2017_QUIT")
    self:hookMsg("MSG_AUTUMN_2017_PLAY")

    EventDispatcher:addEventListener('ENTER_BACKGROUND', self.onPause, self)
    EventDispatcher:addEventListener('ENTER_FOREGROUND', self.onResume, self)

end

-- 打开游戏首次弹出的模式选择
function MidAutumnDlg:onDianJiPanel(sender, eventType)
    self:setCtrlVisible("SelectImage", true, "DianjiPanel")
    self:setCtrlVisible("SelectImage", false, "ZhongLiPanel")
    self.isAccelerometer = false
end

function MidAutumnDlg:onZhongLiPanel(sender, eventType)
    self:setCtrlVisible("SelectImage", false, "DianjiPanel")
    self:setCtrlVisible("SelectImage", true, "ZhongLiPanel")
    self.isAccelerometer = true
    self.lastTime = self.costTotalTime
end

function MidAutumnDlg:onSupplyButton(sender, eventType)
    local readyTime = self.info.ready_time - 1
    self:startCountDown(readyTime, function()
        -- 开始计时
        if not self.isPause then
            self:showGameTime(true, self.info.game_time)
            self.running = true
        end
    end)

    local str = string.format(CHS[5400134], self.isAccelerometer and CHS[5400132] or CHS[5400133])
    ChatMgr:sendMiscMsg(str)
    gf:ShowSmallTips(str)
    self.isChooseMoShi = false

    self:requestQuit("resume")

    self:setModelAndTimeToUserDefault()
end

-- 暂停游戏的panel
function MidAutumnDlg:onResumeGameButton(sender, eventType)
    self:requestQuit("resume")
end

function MidAutumnDlg:onMoShiChooseButton(sender, eventType)
    self.isAccelerometer = not self.isAccelerometer
    gf:ShowSmallTips(string.format(CHS[5400135], self.isAccelerometer and CHS[5400132] or CHS[5400133]))
    self:setShowMoShi()

    self:setModelAndTimeToUserDefault()
end

-- 将游戏模式与时间存入userDefault
function MidAutumnDlg:setModelAndTimeToUserDefault()
    if self.isAccelerometer then
        userDefault:setIntegerForKey(userDefaultKey, 1)
    else
        userDefault:setIntegerForKey(userDefaultKey, 2)
    end

    userDefault:setIntegerForKey(userDefaultTimeKey, gf:getServerTime())
    userDefault:flush()
end

function MidAutumnDlg:onStopGameButton(sender, eventType)
    self:requestQuit("stop")
end

function MidAutumnDlg:onUpdate(delayTime)
    if not self.rabbit then
        return
    end

    if not self.running then
        if self.rabbitStatus ~= 1 then
            DragonBonesMgr:play(self.rabbit, "stand", -1)
            self.rabbitStatus = 1
            self.lastStatus = 1
        end

        return
    end

    self.costTime = self.costTime + delayTime
    self.costTotalTime = self.costTotalTime + delayTime
    if self.costTime > TIME_CHANGE then
        self.costTime = self.costTime - TIME_CHANGE
        self.speed = self.speed + SPEED_CHANGE
    end

    self:updateMooncake(delayTime)

    if not self.isAccelerometer then
        self:resetRabbit(delayTime, self.clickPosX)
    end

    if DragonBonesMgr:isCompleted(self.rabbit) or self.lastStatus ~= self.rabbitStatus then
        if self.rabbitStatus == 1 then
            -- 站住
            DragonBonesMgr:play(self.rabbit, "stand", 1)
        elseif self.rabbitStatus == 4 then
            -- 眩晕
            DragonBonesMgr:play(self.rabbit, "stun", 1)

            local magic = self.rabbitPanel:getChildByTag(DIZZINESS_MAGIC_TAG)
            if not magic then
                magic = gf:createLoopMagic(ResMgr.magic.rabbit_dizziness, nil,{frameInterval = 50})
                local size = self.rabbitPanelSize
                magic:setPosition(size.width / 2, size.height - DIZZINESS_OFFECTY)
                magic:setAnchorPoint(0.5, 0.5)
                magic:setTag(DIZZINESS_MAGIC_TAG)
                self.rabbitPanel:addChild(magic)
            end
        elseif self.rabbitStatus == 5 then
            --[[ 被砸
            DragonBonesMgr:play(self.rabbit, "hit", 1)
            self.rabbitStatus = 4]]
        else
            -- 奔跑
            DragonBonesMgr:play(self.rabbit, "walk", 1)

            local size = self.rabbitPanelSize
            local scaleX = self.rabbitNode:getScaleX()
            local width = size.width - 30
            if scaleX == 1 then
                width = 30
            end

            local magic = self.rabbitPanel:getChildByTag(WALK_MAGIC_TAG)
            if not magic or self.lastStatus ~= self.rabbitStatus then
                if magic then
                    magic:removeFromParent()
                end

                -- 增加兔子跑步脚底光效
                magic = gf:createSelfRemoveMagic(ResMgr.magic.rabbit_boot_walk, {blendMode = "add", frameInterval = 100, scaleX = - scaleX})
                magic:setPosition(width, WALK_BOOT_OFFECTY)
                magic:setAnchorPoint(0.5, 0.5)
                magic:setTag(WALK_MAGIC_TAG)
                self.rabbitPanel:addChild(magic)
            end
        end

        self.lastStatus = self.rabbitStatus
    end

    if self.info[1] and self.costTotalTime * 1000 >= self.info[1].time then
        -- 创建月饼
        self.mooncakes[self.info[1].gid] = self:createMooncake(self.info[1].gid, self.info[1].type)
        table.remove(self.info, 1)
    end
end

function MidAutumnDlg:getMooncakeCtrl(type)
    local ctrl
    if type == "wuren" then
        ctrl = self.wuRenPanel:clone()
    elseif type == "dousha" then
        ctrl = self.douShaPanel:clone()
    elseif type == "xiangong" then
        ctrl = self.xianGongPanel:clone()
    elseif type == "shitou" then
        ctrl = self.stonePanel:clone()
    end

    return ctrl
end

-- 生成月饼
function MidAutumnDlg:createMooncake(gid, type)
    local mooncake = self:getMooncakeCtrl(type)
    mooncake.gid = tostring(gid)
    mooncake.type = type

    if type == "shitou" then
        mooncake.rotation = 0
    else
        mooncake.rotation = math.random(0, 180)
    end

    mooncake.speed = math.random(-30, 30)

    -- 计算月饼位置
    local x
    local y
    local cou = 10
    local fail
    local rect = mooncake:getBoundingBox()
    repeat
        fail = nil
        x = math.random(rect.width / 2, self.rootWidth - rect.width / 2)
        y = self.rootHeight
        for _, v in pairs(self.mooncakes) do
            local mx, my = v:getPosition()
            if (mx - x) * (mx - x) + (my - y) * (my - y) < CREAT_DIS * CREAT_DIS then
                fail = true
                break
            end
        end

        cou = cou - 1
    until fail == nil or cou <= 0

    mooncake:setPosition(x, y)
    self.mooncakePanel:addChild(mooncake)

    if type == "xiangong" then
        local magic = gf:createLoopMagic(ResMgr.magic.mooncake_surround, nil, {blendMode = "add", scaleX = self.rabbitNode:getScaleX(), frameInterval = 65})
        magic:setAnchorPoint(0.5, 0.5)
        magic:setPosition(x, y)
        mooncake.magic = magic
        self.mooncakePanel:addChild(magic)
    end

    return mooncake
end


-- 更新月饼位置
function MidAutumnDlg:updateMooncake(delayTime)
    local x
    local y
    local sz

    local dirOffectX = 15 * self.rabbitNode:getScaleX()
    for _, v in pairs(self.mooncakes) do
        sz = v:getContentSize()
        x, y = v:getPosition()
        local movey = (self.speed + v.speed) * delayTime
        y = y - movey
        local r = v:getRotation()
        v:setRotation((v.rotation * movey / self.totalHeight) + r)
        if y <= self.mookToPiecesHeight then
            -- 掉到地上
            self:solveNotGetMooncake(v, x, y)
            self:removeMooncake(v)
        elseif math.abs(y - self.canGetPosY) < CAN_GET_RANGEY and math.abs(self.rabbitLocationX + dirOffectX - x) < CAN_GET_RANGEX then
            -- 接到月饼
            self:solveGetMooncake(v)
            self:removeMooncake(v)
        else
            v:setPosition(x, y)
            if v.magic then
                v.magic:setPosition(x, y)
            end
        end
    end
end

-- 月饼掉地上
function MidAutumnDlg:solveNotGetMooncake(mooncake, x, y)
    local magic = gf:createSelfRemoveMagic(ResMgr.magic.smash_to_pieces,{blendMode = "add", frameInterval = 50})
    local size = self.rabbitPanelSize
    magic:setAnchorPoint(0.5, 0.5)
    local ctrl = self.stageImage
    local pos = ctrl:convertToNodeSpace(cc.p(x, y))
    magic:setPosition(pos.x, pos.y + 10)
    ctrl:addChild(magic)
end

-- 移除月饼
function MidAutumnDlg:removeMooncake(mooncake, pos)
    if mooncake.magic then
        mooncake.magic:removeFromParent()
    end

    self.mooncakes[mooncake.gid] = nil
    mooncake:removeFromParent()
end

-- 获取到月饼，播动画
function MidAutumnDlg:solveGetMooncake(mooncake)
    if mooncake.type == "shitou" then
        self.lastStatus = nil
        self.rabbitStatus = 4
        self.canMove = false
        self.root:stopAction(self.delay)

        if SystemSettingMgr:getSettingStatus("refuse_shock", 0) == 0 then
            VibrateMgr:vibrate()
        end

        self.delay = performWithDelay(self.root, function()
            self.canMove = true
            self.rabbitStatus = 1
            local magic = self.rabbitPanel:getChildByTag(DIZZINESS_MAGIC_TAG)
            if magic then
                magic:removeFromParent()
            end
        end, 1.5)
    end

    gf:CmdToServer('CMD_AUTUMN_2017_PLAY', { gid = mooncake.gid})
end

-- 播放骨骼动画
function MidAutumnDlg:createArmature(icon)
    local magic = ArmatureMgr:createArmature(icon)
    local showPanel = self.rabbitPanel
    magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2 + POINT_OFFECTY)
    magic:setVisible(false)
    showPanel:addChild(magic)

    self.curMagic = magic
end

-- 创建兔子对象
function MidAutumnDlg:createRabbit(icon, action)
    self.rabbit = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.jieyuebing_tuzi, "tuzi")

    -- 将 Armature 放到某个 node 上
    self.rabbitNode = tolua.cast(self.rabbit, "cc.Node")
    self.rabbitPanel = self:getControl("PeoplePanel")
    local size = self.rabbitPanel:getContentSize()
    -- self.rabbitNode:setAnchorPoint(0.5, 0.5)
    self.rabbitNode:setPosition(size.width / 2, 0)
    self.rabbitPanel:addChild(self.rabbitNode)

    -- 设置兔子位置
    --local y = MAP_RABBIT_HEIGHT - (769 - self.rootHeight) / 2
    --self.rabbitPanel:setPositionY(y)
    local y = self.rabbitPanel:getPositionY()

    self.rabbitPanelSize = size
    self.rabbitLocationX = self.rabbitPanel:getPosition() -- 兔子x轴上的位子
    self.clickPosX = self.rabbitLocationX
    self.canGetPosY = y -- 计算月饼到达某高度后可以接

    -- 台子位置
    --local stageY = MAP_STAGE_HEIGHT / 2 - (769 - self.rootHeight) / 2
    --local stage = self.stageImage
    --stage:setPositionY(stageY)
    local stage = self.stageImage
    local stageY = stage:getPositionY()

    self.mookToPiecesHeight = stageY + 20
    self.totalHeight = self.rootWidth - 25 - self.mookToPiecesHeight

    local winSize = self:getWinSize()
    local moonCakePanelSize = self.mooncakePanel:getContentSize()

    local function onTouch(touch, event)
        if not self.running then
            return
        end

        if event:getEventCode() == cc.EventCode.BEGAN then
            local pos = self.mooncakePanel:getParent():convertToNodeSpace(touch:getLocation())
            self.clickPosX = pos.x
            return true
        elseif event:getEventCode() == cc.EventCode.MOVED then
            local pos = self.mooncakePanel:getParent():convertToNodeSpace(touch:getLocation())
            self.clickPosX = pos.x
            if self.clickPosX < 0 then
                self.clickPosX = 0
            elseif self.clickPosX > moonCakePanelSize.width then
                self.clickPosX = moonCakePanelSize.width
            end

            return true
        elseif event:getEventCode() == cc.EventCode.ENDED then
            local pos = self.mooncakePanel:getParent():convertToNodeSpace(touch:getLocation())
            self.clickPosX = pos.x
            if self.clickPosX < 0 then
                self.clickPosX = 0
            elseif self.clickPosX > moonCakePanelSize.width then
                self.clickPosX = moonCakePanelSize.width
            end
        end
    end

    gf:bindTouchListener(self:getControl("PeoplePanel"), onTouch, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED
    }, false)

    self.layer = cc.Layer:create()
    self.layer:setAccelerometerEnabled(true)

    local function accelerometerListener(event, x, y, z, timestamp)
        -- 重力感应回调函数
        if not self.running then
            return
        end

        if y > 0 and gf:isAndroid() and not gf:gfIsFuncEnabled(FUNCTION_ID.ENABLE_ORIENTATION) then
            -- Android下没有修复y轴修正，需要手动修正一下
            x = -x
        end

        if self.isAccelerometer then
            local rx = self.rabbitLocationX
            local movex = x * 36
            if self.lastTime then
                local timec = math.max(self.costTotalTime - self.lastTime, 0)
                local canMovex = 380 * timec
                if timec > 0.01 then
                    if canMovex < math.abs(movex) then
                        if movex < 0 then
                            movex = -canMovex
                        else
                            movex = canMovex
                        end
                    end

                    self.lastTime = self.costTotalTime
                else
                    return
                end
            else
                self.lastTime = self.costTotalTime
            end

            rx = rx + movex
            if rx < 0 then
                rx = 0
            elseif rx > moonCakePanelSize.width then
                rx = moonCakePanelSize.width
            end

            self:resetRabbit(0, rx)
        end
    end

    local listener = cc.EventListenerAcceleration:create(accelerometerListener)
    self.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.layer)
    self.root:addChild(self.layer)
end

function MidAutumnDlg:compare(num1, num2)
    if math.abs(num1 - num2) < 0.001 then
        return 0
    elseif num1 < num2 then
        return -1
    elseif num1 > num2 then
        return 1
    end
end

-- 刷新兔子状态及位置
function MidAutumnDlg:resetRabbit(delayTime, clickPosX)
    if not self.rabbitPanel or not self.canMove then
        return
    end

    local x = self.rabbitLocationX
    if not clickPosX then
        return
    end

    if self:compare(x, clickPosX) > 0 then
        -- 向左走
        if self.isAccelerometer then
            x = clickPosX
        else
            x = x - RABBIT_SPEED * delayTime
            if x < clickPosX then
                x = clickPosX
            end
        end

        self.rabbitPanel:setPositionX(x)
        if self.rabbitStatus ~= 2 then
            self.rabbitNode:setScaleX(-1)
            self.rabbitStatus = 2
        end
    elseif self:compare(x, clickPosX) < 0 then
        -- 向右走
        if self.isAccelerometer then
            x = clickPosX
        else
            x = x + RABBIT_SPEED * delayTime
            if x > clickPosX then
                x = clickPosX
            end
        end

        self.rabbitPanel:setPositionX(x)
        if self.rabbitStatus ~= 3 then
            self.rabbitNode:setScaleX(1)
            self.rabbitStatus = 3
        end
    elseif self.rabbitStatus ~= 1 then
        -- 停住
        self.rabbitStatus = 1
    end

    self.rabbitLocationX = x
end

-- 设置暂停时显示的模式
function MidAutumnDlg:setShowMoShi()
    if self.isAccelerometer then
        self:setLabelText("TypeLabel", CHS[5400132], "MenuButton2")
    else
        self:setLabelText("TypeLabel", CHS[5400133], "MenuButton2")
    end
end

-- 暂停
function MidAutumnDlg:onPauseButton(sender, eventType)
    self:requestQuit("pause")
end

-- 切后台暂停
function MidAutumnDlg:onPause()
    if not self.isFinish then
        self:requestQuit("pause")
        self.isPause = true
        self.running = false
        self.enterBackground = true
    end
end

-- 切回前台恢复游戏
function MidAutumnDlg:onResume()
    if self.isFinish or not self.enterBackground then
        return
    end

    self.running = false
    self.enterBackground = false
    self.numImg:stopCountDown()
    if not self.isChooseMoShi then
        self:setCtrlVisible("StartPanel", false)
        self:setCtrlVisible("StopPanel", true)
        self:setShowMoShi()
    end
end

-- 继续游戏
function MidAutumnDlg:onResultPanel(sender, eventType)
    self:onCloseButton()
end

-- 游戏结束倒计时
function MidAutumnDlg:showGameTime(isShow, value)
    local panel = self:getControl("TimePanel", nil, "MainPanel")
    panel:stopAllActions()

    local numPanel
    if value then
        numPanel = self:getControl("NumPanel", nil, panel)
        self:setColorText(gf:getServerDate("%M:%S", value), "NumPanel", panel, 0, 0, COLOR3.WHITE, 31)
    end

    if isShow and value then
        local startTime = gf:getTickCount()
        local totalTime = value
        schedule(panel, function()
            local t = gf:getTickCount()
            value = math.max(totalTime - (t - startTime) / 1000, 0)
            if value <= 0 then
                panel:stopAllActions()
                gf:CmdToServer('CMD_AUTUMN_2017_PLAY', { gid = ""})
            end

            self:setColorText(gf:getServerDate("%M:%S", value), "NumPanel", panel, 0, 0, COLOR3.WHITE, 31)
        end, 1)
    end
end

-- 创建倒计时
function MidAutumnDlg:createCountDown(time)
    local timePanel = self:getControl('NumPanel', nil, 'StartPanel')
    if timePanel then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', time, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        timePanel:addChild(self.numImg)
        self:setCtrlVisible('StarImage', false, 'StartPanel')
    end
end

-- 设置开局倒计时数字
function MidAutumnDlg:startCountDown(time, callback)
    if not self.numImg then return end
    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("StartPanel", true)
    self.numImg:startCountDown(function()
        self:setCtrlVisible('StarImage', true, 'StartPanel')
        self.numImg:setVisible(false)
        self.countDownDelay = performWithDelay(self.root, function()
            -- 1s后隐藏开始
            self:setCtrlVisible("StartPanel", false)
            if callback then callback() end
        end, 1)
    end)
end

-- 设置奖励
function MidAutumnDlg:setBonus(data)
    self:setCtrlVisible("ResultPanel1", true, "GameResultPanel")
    gf:frozenScreen(300)

    local resultPanel = self:getControl("ResultPanel1", nil, "GameResultPanel")

    -- 设置星星
    for i = 1, 3 do
        if i <= data.star then
            self:setCtrlVisible(string.format("StarImage_%d", i), true, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        else
            self:setCtrlVisible(string.format("StarImage_%d", i), false, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        end
    end

    -- 历史最高分
    self:setLabelText("HighestNumLabel", string.format(CHS[2100077], data.highest_score), resultPanel)

    -- 当前分数
    local numPanel = self:getControl("NumPanel", nil, resultPanel)
    self:setNumImgForPanel(numPanel, "bfight_num", data.score, false, LOCATE_POSITION.MID, 25)

    -- 五仁月饼
    self:setLabelText("NumLabel_1", data.wuren_count, self:getControl("WuRenPanel", nil, resultPanel))


    -- 豆沙月饼
    self:setLabelText("NumLabel_1", data.dousha_count, self:getControl("DouShaPanel", nil, resultPanel))


    -- 仙宫月饼
    self:setLabelText("NumLabel_1", data.xiangong_count, self:getControl("XianGongPanel", nil, resultPanel))

    -- 石头
    self:setLabelText("NumLabel_1", data.shitou_count, self:getControl("StonePanel", nil, resultPanel))

    local getPanel =  self:getControl("GetPanel", nil, resultPanel)
    self:setLabelText("NumLabel_2", string.format("%s*1", data.bonus_item), getPanel)
    if data.bonus_type == "tao" then
        self:setImagePlist("BubbleImage", ResMgr.ui.small_daohang, getPanel)
        if data.bonus_tao > 0 then
            self:setLabelText("NumLabel_1", string.format(CHS[2100079], gf:getTaoStr(data.bonus_tao, 0)), getPanel)
        else
            self:setLabelText("NumLabel_1", CHS[7002255], getPanel)
        end
    else
        self:setImagePlist("BubbleImage", ResMgr.ui.small_exp, getPanel)
        if data.bonus_exp > 0 then
            self:setLabelText("NumLabel_1", data.bonus_exp, getPanel)
        else
            self:setLabelText("NumLabel_1", CHS[7002255], getPanel)
        end
    end

    self:setCtrlVisible("TextLabel", false, resultPanel)
    self:setCtrlVisible("GetPanel", true, resultPanel)
end

-- 设置奖励
function MidAutumnDlg:setBonus2(data)
    self:setCtrlVisible("ResultPanel_2", true, "GameResultPanel")
    gf:frozenScreen(300)

    local resultPanel = self:getControl("ResultPanel_2", nil, "GameResultPanel")

    -- 设置星星
    for i = 1, 3 do
        if i <= data.star then
            self:setCtrlVisible(string.format("StarImage_%d", i), true, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        else
            self:setCtrlVisible(string.format("StarImage_%d", i), false, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        end
    end

    -- 历史最高分
    self:setLabelText("HighestNumLabel", string.format(CHS[2100077], data.highest_score), resultPanel)

    -- 当前分数
    local numPanel = self:getControl("NumPanel", nil, resultPanel)
    self:setNumImgForPanel(numPanel, "bfight_num", data.score, false, LOCATE_POSITION.MID, 25)

    -- 五仁月饼
    self:setLabelText("NumLabel_1", data.wuren_count, self:getControl("WuRenPanel", nil, resultPanel))


    -- 豆沙月饼
    self:setLabelText("NumLabel_1", data.dousha_count, self:getControl("DouShaPanel", nil, resultPanel))


    -- 仙宫月饼
    self:setLabelText("NumLabel_1", data.xiangong_count, self:getControl("XianGongPanel", nil, resultPanel))

    -- 石头
    self:setLabelText("NumLabel_1", data.shitou_count, self:getControl("StonePanel", nil, resultPanel))

    if data.score == 0 then
        self:setCtrlVisible("TextLabel", false, resultPanel)
    else
        self:setCtrlVisible("TextLabel", true, resultPanel)
    end
end


function MidAutumnDlg:MSG_AUTUMN_2017_QUIT(data)
    local readyTime = 0
    local flag = data.type ~= "pause"
    local totalTime = self.info.game_time or 100
    if data.left_time > totalTime then
        -- 多于 self.totalTime 秒的是开局倒计时
        readyTime = data.left_time - totalTime
        data.left_time = totalTime
        flag = false
    end

    self.running = flag
    self.clickPosX = self.rabbitLocationX
    self:showGameTime(flag, data.left_time)

    if "pause" == data.type then
        self.isPause = true
        if not self.isChooseMoShi then
            self:setCtrlVisible("StopPanel", true)
            self:setShowMoShi()
        end
    else
        self.isPause = false
        self:setCtrlVisible("StopPanel", false)
        self:setCtrlVisible("ChosePanel", false)
        if readyTime > 0 then
            self:startCountDown(readyTime - 1, function()
                -- 开始计时
                if not self.isPause then
                    self:showGameTime(true, data.left_time)
                    self.running = true
                end
            end)
        end
    end
end

function MidAutumnDlg:MSG_AUTUMN_2017_FINISH(data)
    self.running = false
    self.canMove = false
    self:showGameTime(false)

    self:setCtrlVisible("StopPanel", false)
    self.isFinish = true
    if data.bonus_type == "none" then
        self:onCloseButton()
        return
    end

    if data.score == 0 then
        data.star = 0
    elseif data.score < 60 then
        data.star = 1
    elseif data.score < 120 then
        data.star = 2
    else
        data.star = 3
    end

    if data.bonus_item and "" ~= data.bonus_item then
        self:setBonus(data)
    else
        self:setBonus2(data)
    end

    self:setColorText(gf:getServerDate("%M:%S", 0), "NumPanel", "TimePanel", 0, 0, COLOR3.WHITE, 31)
end

function MidAutumnDlg:MSG_AUTUMN_2017_PLAY(data)
    -- 积分
    local panel = self:getControl("TotalNumLabel", Const.UIAtlasLabel)
    panel:setString(data.total_score)

    -- 接住月饼的光效
    if self.curMagic and data.score > 0 then
        if data.score == 1 then
            self.curMagic:getAnimation():play("Top01")
        elseif data.score == 2 then
            self.curMagic:getAnimation():play("Top02")
        elseif data.score == 3 then
            self.curMagic:getAnimation():play("Top03")
        end

        local scaleX = self.rabbitNode:getScaleX()
        local size = self.rabbitPanelSize
        local width = size.width / 2 + 10
        if scaleX == -1 then
            width = width - 20
        end

        local magic = gf:createSelfRemoveMagic(ResMgr.magic.get_mooncake, {blendMode = "add", scaleX = self.rabbitNode:getScaleX(), frameInterval = 50})
        magic:setAnchorPoint(0.5, 0.5)
        magic:setPosition(width, size.height / 2 + GET_OFFECTY)
        self.rabbitPanel:addChild(magic)

        self.curMagic:setVisible(true)
    end
end

function MidAutumnDlg:setGetPointTip(score, type)
    local color = COLOR3.GREEN
    if type == "dousha" then
        color = COLOR3.BLUE
    elseif type == "xiangong" then
        color = COLOR3.GRAY
    end

    local str = string.format(CHS[5400124], score)

    local tip = self:generateTip(str, color)

    tip:setPosition(self.rabbitPanelSize.width / 2, self.rabbitPanelSize.height)

    local moveAction = cc.MoveBy:create(TIP_SHOW_TIME, cc.p(0, TIP_SHOW_DIS))

    local action = cc.Sequence:create(
        cc.DelayTime:create(TIP_SHOW_TIME),
        cc.RemoveSelf:create()
    )

    self.rabbitPanel:addChild(tip)
    tip:runAction(action)
    tip:runAction(moveAction)
end

function MidAutumnDlg:generateTip(str, color)
    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(21)
    tip:setString(str)
    tip:setDefaultColor(color.r, color.g, color.b)
    tip:setContentSize(100, 0)
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip:setPosition(0, h)

    local layer = ccui.Layout:create()
    layer:setContentSize(cc.size(w, h))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setName("word")
    layer:addChild(colorLayer)
    return layer
end

function MidAutumnDlg:cleanup()
    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.jieyuebing_tuzi, "tuzi")

    EventDispatcher:removeEventListener('ENTER_BACKGROUND', self.onPause, self)
    EventDispatcher:removeEventListener('ENTER_FOREGROUND', self.onResume, self)
end

function MidAutumnDlg:requestQuit(type)
    gf:CmdToServer('CMD_AUTUMN_2017_QUIT', {type = type})
end

return MidAutumnDlg
