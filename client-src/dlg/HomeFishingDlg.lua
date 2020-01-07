-- HomeFishingDlg.lua
-- Created by huangzz Aug/19/2017
-- 钓鱼操作界面

local HomeFishingDlg = Singleton("HomeFishingDlg", Dialog)

local FUPIAO_ACTION_NUM = 10


local STATUS = {
    DAIJI = 1,
    WAITING = 2,
    FUPIAO = 3,
    LACHE = 4,
    SUCC = 5,
    FAIL = 6
}

local heightChange = {}

local LISTVIEW_TAG = 100
local CONTAINER_TAG = 101

local PEOPLES = {
    "me",
    "other"
}

local BOARD_INIT_SPEED_UP = 50  -- 绿色的滑块，控制时向上滑的初始速度

local BOARD_PLUA_SPEED_UP = 100   -- 绿色的滑块，控制时每0.03秒增加的速度

local BOARD_INIT_SPEED_DOWN = 50  -- 绿色的滑块，不控制时向下滑的初始速度（像素/0.03s）

local BOARD_PLUA_SPEED_DOWN = 5  -- 绿色的滑块，不控制时向下滑每0.03秒增加的速度（像素/0.03s）

local PROGRESSBAR_SPEED = 20    -- 进度条每秒减少或增加的百分比

local LAGAN_FRAME = 50  -- 拉杆动画的帧数

local MAX_LEVEL = 6    -- 钓鱼最大等级

local MY_POLE_POSX = 161    -- 鱼竿在屏宽960时的位置

local OTHER_POLE_POSX = 161

-- 不同等级鱼饵对应的鱼的速度
local FISH_SPEED_RANGE = {
    [1] = {30, 50},
    [2] = {40, 60},
    [3] = {60, 80},
    [4] = {80, 100},
    [5] = {90, 110},
    [6] = {100, 120},
}

-- 不同等级鱼饵对应的鱼的转向时间
local FISH_SWIM_RANGE = {
    [1] = {1, 2},
    [2] = {0.9, 1.8},
    [3] = {0.8, 1.7},
    [4] = {0.7, 1.6},
    [5] = {0.6, 1.5},
    [6] = {0.5, 1.5},
}

-- 浮漂动画每个动作的时间
local FUPIAO_TIME = {
    [1] = 1.25,
    [2] = 1,
    [3] = 1.33,
    [4] = 2,
    [5] = 2
}

local WAVE_MAGIC = {
    [1] = ResMgr.magic.fish_wave_water1,
    [2] = ResMgr.magic.fish_wave_water2,
    [3] = ResMgr.magic.fish_wave_water3,
    [4] = ResMgr.magic.fish_wave_water4,
    [5] = ResMgr.magic.fish_wave_water5,
}


local WAVE_TAG = 102

-- 头顶冒泡相关
local HEIGHT_MARGIN = 10
local WIDTH_MARGIN = 12
local BACK_WIDTH = 600
local GENERAL_WIDTH = 166

local last_invente_time = 0

function HomeFishingDlg:init()
    self:setFullScreen()

    self:bindListener("ToolButton", self.onToolButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("FriendButton", self.onFriendButton)
    self:bindListener("BagButton", self.onBagButton)
    self:bindListener("ChatButton", self.onChatButton)
    -- self:bindListener("ThrowButton", self.onThrowButton)
    -- self:bindListener("LiftButton", self.onLiftButton)
    self:bindListener("TouchPanel", self.onConfirmImage, "ResultPanel")
    self:bindListener("ExpendButton", self.onExpendButton1, "PersenPanel1")
    self:bindListener("ExpendButton", self.onExpendButton2, "PersenPanel2")
    self:bindListener("InvitationButton", self.onInvitationButton)
    self:bindListener("OutButton", self.onOutButton)

    -- 获取屏幕尺寸
    local winSize = cc.Director:getInstance():getWinSize()
    self.rootHeight = winSize.height / Const.UI_SCALE
    self.rootWidth = winSize.width / Const.UI_SCALE

    -- 调整鱼竿位置
    local widthC = (self.rootWidth - 960) / 2
    local pole1 = self:getControl("FishPolePanel", nil, "PersenPanel1")
    pole1:setPositionX(MY_POLE_POSX - widthC + self:getWinSize().ox)
    local pole1 = self:getControl("FishPolePanel", nil, "PersenPanel2")
    pole1:setPositionX(OTHER_POLE_POSX - widthC + self:getWinSize().ox)


    -- 设置黑幕大小
    self:setCtrlFullClient("BKPanel", "LiftPanel")
    self:setCtrlFullClient("BKPanel", "PullPanel")
    self:setCtrlFullClient("BKPanel", "ResultPanel")

    -- 加载背景图
    local dlgBack = ccui.ImageView:create(ResMgr.ui.fish_background)
    dlgBack:setPosition(self.rootWidth / 2, self.rootHeight / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)
    dlgBack:setTouchEnabled(true)

    -- 钓鱼历史记录相关
    self.historyCou = {}
    self.historyCells = {}
    self.isExpend = {}
    self.diaryPanel = self:retainCtrl("DiaryPanel", "PersenPanel1")
    local diaryPanel = self:getControl("DiaryPanel", "PersenPanel2")
    diaryPanel:removeFromParent()
    self:creatListView("PersenPanel1", "me")
    self:creatListView("PersenPanel2", "other")

    -- 河塘标题显示
    local homeType = string.match(MapMgr:getCurrentMapName(), "(.+)-.+")
    self:setLabelText("NameLabel_1", homeType .. CHS[5410118], "MapPanel")
    self:setLabelText("NameLabel_2", homeType .. CHS[5410118], "MapPanel")
    self.homeType = homeType

    -- 小红点
    self:checkRedDot()

    -- 游鱼
    self:createMapFish()

    -- 水波
    self.wave = {}
    self:creatWave("me", "PersenPanel1")
    self:creatWave("other", "PersenPanel2")
    self:creatWaveToFupiao()

    self:setLastOpenChannelTime()

    self.myGid = Me:queryBasic("gid")
    self.myInfo = nil
    self.selectPoleName = ""
    self.selectBaitName = ""
    self.pole = {}
    self.poleNode = {}
    self.fupiaoNode = nil
    self.fishNode = nil
    self.fish = nil

    self.firstEnter = true
    self.poleStatus = {}
    self.fishingStatus = {} -- 1 待机，2 垂钓等待，3 浮漂浮动，4 拉扯，5 成功捕鱼，6 失败
    self.totalTime = 0 -- 浮漂倒计时
    self.fupiaoStatus = 11

    self.fishSwimTime = 0
    self.fishDir = 0
    self.fishImage = self:getControl("FishImage", nil, "PullPanel")
    self.fishHeight = self.fishImage:getContentSize().height

    self.fishPanel = self:getControl("FishPanel", nil, "PullPanel")
    self.canFishHeight = self.fishPanel:getContentSize().height

    self.clickBoardTime = 0
    self.boardSpeed = 0
    self.boardDir = 0
    self.boardPosY = 0

    self.isFirstFishing = true  -- 非打开界面的首次钓鱼要显示不同的抛竿按钮

    self.stopTime = 0

    self.fupiaoDownTime = 11

    self.chatContent = {}

    self.polesInfo, self.baitsInfo = self:getFishToolInfo()

    self:creaFuPiao()

    -- 获奖旋转图片
    self.rotationImage = self:getControl("BKImage1", nil, "ResultPanel")
    self.angle = 0

    -- 绑定拉扯按钮
    local function onPullButton(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBoardTime = 0
            self.boardSpeed = BOARD_INIT_SPEED_UP
            self.boardDir = 1
        elseif eventType == ccui.TouchEventType.ended then
            self.clickBoardTime = 0
            self.boardSpeed = BOARD_INIT_SPEED_DOWN
            self.boardDir = 2
        elseif eventType == ccui.TouchEventType.canceled then
            self.clickBoardTime = 0
            self.boardSpeed = BOARD_INIT_SPEED_DOWN
            self.boardDir = 2
        end
    end

    self:getControl("PullButton"):addTouchEventListener(onPullButton)

    local liftButton = self:getControl("LiftButton")
    local liftPanel = self:getControl("LiftPanel")
    self:bindTouchListener(liftButton, function()
        if liftPanel:isVisible() and self:isVisible() then return true end
    end, self.onLiftButton)

    local throwButton = self:getControl("ThrowButton")
    self:bindTouchListener(throwButton, function()
        if throwButton:isVisible() and self:isVisible() then return true end
    end, self.onThrowButton)

    local throwButton = self:getControl("ThrowButton2")
    self:bindTouchListener(throwButton, function()
        if throwButton:isVisible() and self:isVisible() then return true end
    end, self.onThrowButton)

    local dlg = DlgMgr:getDlgByName("ChatDlg")
    if dlg then
        dlg:setStopRefreshData(true)
    end

    DlgMgr:closeDlg("HomePlantDlg")
    DlgMgr:closeDlg("HomePuttingDlg")

    self:setFishingStatus(STATUS.DAIJI, "me")

    gf:CmdToServer("CMD_HOSUE_FISH_ALL_TOOLS")

    local data = HomeMgr.playerFishingInfo
    -- 玩家自己信息
    local myInfo = data[self.myGid]
    self:MSG_HOUSE_FISH_BASIC(myInfo)
    if myInfo and myInfo.couple and myInfo.couple.gid then
        -- 伴侣信息
        self:MSG_HOUSE_FISH_BASIC(data[myInfo.couple.gid])
    end

    self:hookMsg("MSG_HOUSE_FISH_BASIC")
    self:hookMsg("MSG_HOSUE_QUIT_FISH")
    self:hookMsg("MSG_HOUSE_USE_FISH_TOOL")
    self:hookMsg("MSG_HOSUE_FISH_PAOGAN")
    self:hookMsg("MSG_HOSUE_FISH_FUBIAOPAODONG")
    self:hookMsg("MSG_HOSUE_FISH_FUBIAOPAODONG_FAIL")
    self:hookMsg("MSG_HOSUE_FISH_LACHE")
    self:hookMsg("MSG_HOSUE_FISH_LACHE_FAIL")
    self:hookMsg("MSG_HOSUE_FISH_SUCC")
    self:hookMsg("MSG_HOUSE_ALL_FISH_TOOL_INFO")
    self:hookMsg("MSG_HOUSE_FISH_TOOL_PART_INFO")
    self:hookMsg("MSG_HOUSE_FISH_CHANGE_NAME")
    self:hookMsg("MSG_MESSAGE_EX")

    EventDispatcher:addEventListener('ENTER_BACKGROUND', self.onPause, self)
    EventDispatcher:addEventListener('ENTER_FOREGROUND', self.onResume, self)

    -- 处理左上角的  wifi 与信号
    -- self:bindListener("SignalTouchPanel", self.onSignalButton)

    self.signalImages =  {
        self:getControl("SignalImage_1", nil, "SignalPanel_0"),
        self:getControl("SignalImage_2", nil, "SignalPanel"),
        self:getControl("SignalImage_3", nil, "SignalPanel"),
        self:getControl("SignalImage_4", nil, "SignalPanel"),
    }
    self:refreshSignalColor()

    self:onRefresh()
    schedule(self.root, function() self:onRefresh() end, 1)
end

function HomeFishingDlg:bindTouchListener(button, canShow, callback)
    button:setTouchEnabled(false)
    local clickThrow = false
    local function onButton(touche, event)
        local rect = self:getBoundingBoxInWorldSpace(button)
        if event:getEventCode() == cc.EventCode.BEGAN then
            if not canShow() then
                return false
            end

            if cc.rectContainsPoint(rect, touche:getLocation()) and not clickThrow then
                clickThrow = true
                button:setScale(1.1)
                return true
            end

            return false
        elseif event:getEventCode() == cc.EventCode.MOVED then
            if not cc.rectContainsPoint(rect, touche:getLocation()) then
                button:setScale(1)
            else
                button:setScale(1.1)
            end
        elseif event:getEventCode() == cc.EventCode.ENDED then
            if cc.rectContainsPoint(rect, touche:getLocation())
                and canShow() then
                if callback then
                    callback(self)
                end
            end

            button:setScale(1)
            clickThrow = false
        elseif event:getEventCode() == cc.EventCode.CANCELLED then
            button:setScale(1)
            clickThrow = false
        end
    end

    gf:bindTouchListener(button, onButton, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
end

function HomeFishingDlg:createMapFish()
    local swimFish = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.home_fish_swim_fish.name)
    swimFish:setAnchorPoint(0.5, 0.5)
    swimFish:setPosition(self.rootWidth / 2, self.rootHeight / 2)
    self.root:addChild(swimFish)
    swimFish:getAnimation():play("Bottom", -1, 1)
end

function HomeFishingDlg:getFishToolInfo()
    local itemInfo = InventoryMgr:getAllItemInfo()
    local baits = {}
    local poles = {}
    for name, v in pairs(itemInfo) do
        if string.match(name, CHS[5400182]) then
            local subName = string.match(name, CHS[5400177])
            if string.match(subName, CHS[5400179]) then
                poles[subName] = v
            else
                baits[subName] = v
            end
        end
    end

    return poles, baits
end

function HomeFishingDlg:creatListView(panelName, who)
    local cell = self.diaryPanel
    local panel = self:getControl(panelName)
    local listView = ccui.ListView:create()
    listView:setContentSize(cell:getContentSize())
    listView:setDirection(ccui.ListViewDirection.vertical)
    --listView:setPosition(cell:getPosition())
    listView:setAnchorPoint(0, 0)
    self:getControl("DiaryPanel_0", nil, panel):addChild(listView, 0, LISTVIEW_TAG)

    heightChange[who] = 100
    self.historyCou[who] = 0
    self.historyCells[who] = {}

    -- 默认显示"今日暂无钓鱼记录"
    local cell1 = cell:clone()
    self:setColorText(CHS[5400205], cell1, nil, nil, nil, COLOR3.WHITE)
    listView:pushBackCustomItem(cell1)
end

function HomeFishingDlg:onUpdate(delayTime)
    -- 鱼竿
    for i = 1, 2 do
        if self.pole and self.pole[PEOPLES[i]] then
            if DragonBonesMgr:isCompleted(self.pole[PEOPLES[i]]) then
                if self.poleStatus[PEOPLES[i]] == "shuaigan" then
                    DragonBonesMgr:toPlay(self.pole[PEOPLES[i]], "chuidiao", 0)
                    self.poleStatus[PEOPLES[i]] = "chuidiao"
                elseif self.poleStatus[PEOPLES[i]] == "shougan" then
                    DragonBonesMgr:toPlay(self.pole[PEOPLES[i]], "daiji", 0)
                    self.poleStatus[PEOPLES[i]] = "daiji"
                end
            end
        end
    end

    -- 浮漂
    if self.fupiaoStatus
            and self.fupiaoStatus < FUPIAO_ACTION_NUM
            and self.fupiao
            and (DragonBonesMgr:isCompleted(self.fupiao) or self.fupiaoStatus == 0) then

        self.fupiaoStatus = self.fupiaoStatus + 1
        local no = self.fupiaoInfo[self.fupiaoStatus]
        DragonBonesMgr:toPlay(self.fupiao, "dongzuo_" .. no, 1)

        self.fupiaoWave:getAnimation():play("Bottom0" .. (no + 1))
    end

    -- 拉扯
    if self.fishingStatus and self.fishingStatus["me"] == STATUS.LACHE and not self.isLacheFinish then
        self:updateBoardPos(delayTime)
        self:updateFishPos(delayTime)
        self:upadateBar(delayTime)
    end

    -- 捕获成功图片旋转效果
    if self.fishingStatus and self.fishingStatus["me"] == STATUS.SUCC then
        self.angle = self.angle + 0.8
        self.rotationImage:setRotation(self.angle)
    end
end

-- 刷新进度条及拉杆状态
function HomeFishingDlg:upadateBar(delayTime)
    -- 进度条
    local percent = self.bar:getPercent()
    if math.abs(self.fishPosY - self.boardPosY) <= self.rightDis then
        self:setCtrlVisible("RightImage", true, self.fishImage)
        percent = percent + PROGRESSBAR_SPEED * delayTime
        self.bar:setPercent(percent)
    else
        self:setCtrlVisible("RightImage", false, self.fishImage)
        percent = percent - PROGRESSBAR_SPEED * delayTime
        self.bar:setPercent(percent)
    end

    if percent >= 100 then
        local key = self.myInfo.key
        gf:CmdToServer("CMD_HOUSE_LACHE", {key = key, result = gfEncrypt("win", key)})
        self.isLacheFinish = true
    elseif percent <= 0 then
        local key = self.myInfo.key
        gf:CmdToServer("CMD_HOUSE_LACHE", {key = key, result = gfEncrypt("lose", key)})
        self.isLacheFinish = true
    end

    -- 拉杆
    if self.pole["me"] then
        local fram = math.floor((percent / 100) * LAGAN_FRAME + 0.5)
        DragonBonesMgr:gotoAndStopByFrame(self.pole["me"], "lagan", fram)

        self.wave["me"]:getAnimation():gotoAndPause(fram)
    end
end

-- 刷新木板位置
function HomeFishingDlg:updateBoardPos(delayTime)
    if self.clickBoardTime > 0.03 then
        self.clickBoardTime = self.clickBoardTime - 0.03
        if self.boardDir == 1 then
            self.boardSpeed = self.boardSpeed + BOARD_PLUA_SPEED_UP
        else
            self.boardSpeed = self.boardSpeed + BOARD_PLUA_SPEED_DOWN
        end
    end

    local heightMax = self.canFishHeight - 10 - self.boardHeight / 2
    local heightMin = self.boardHeight / 2 + 10
    if (self.boardDir == 1 and self.boardPosY >= heightMax)
        or (self.boardDir == 2 and self.boardPosY <= heightMin)then
        return
    end

    if self.boardDir == 1 then
        -- 向上游
        self.boardPosY = self.boardPosY + self.boardSpeed * delayTime
        if self.boardPosY >= heightMax then
            self.boardPosY = heightMax
        end
    else
        -- 向下游
        self.boardPosY = self.boardPosY - self.boardSpeed * delayTime
        if self.boardPosY <= heightMin then
            self.boardPosY = heightMin
        end
    end

    self.boardImage:setPositionY(self.boardPosY)
    self.clickBoardTime = self.clickBoardTime + delayTime
end

-- 刷新游鱼位置
function HomeFishingDlg:updateFishPos(delayTime)
    if self.fishSwimTime <= 0 then
        local bait = self.baitsInfo[self.selectBaitName]
        if not bait then
            return
        end

        local level = bait.level
        self.fishSwimTime = math.random(FISH_SWIM_RANGE[level][1], FISH_SWIM_RANGE[level][2])
        local lastDir = self.fishDir

        self.fishDir = math.random(1, 2)
        if lastDir ~= self.fishDir then
            self.stopTime = 0.2
        end

        self.fishSpeed = math.random(FISH_SPEED_RANGE[level][1], FISH_SPEED_RANGE[level][2])
    end

    self.stopTime = self.stopTime - delayTime
    if self.stopTime > 0 then
        return
    end

    local heightMax = self.canFishHeight - 10 - self.fishHeight / 2
    local heightMin = self.fishHeight / 2 + 10

    if self.fishDir == 1 then
        -- 向上游
        self.fishImage:setScaleY(1)
        self.fishPosY = self.fishPosY + self.fishSpeed * delayTime

        if self.fishPosY >= heightMax then
            self.fishPosY = heightMax
			self.fishSwimTime = 0
        end
    else
        -- 向下游
        self.fishImage:setScaleY(-1)
        self.fishPosY = self.fishPosY - self.fishSpeed * delayTime

        if self.fishPosY <= heightMin then
            self.fishPosY = heightMin
			self.fishSwimTime = 0
        end
    end

    self.fishImage:setPositionY(self.fishPosY)
    self.fishSwimTime = self.fishSwimTime - delayTime
end

function HomeFishingDlg:getYuGanTypeByName(name)
    if name == CHS[5400174] then
        return "diaogan_3"
    elseif name == CHS[5400175] then
        return "diaogan_2"
    else
        return "diaogan_1"
    end
end

function HomeFishingDlg:removePole(who)
    if self.poleNode[who] then
        self.poleNode[who]:removeFromParent()
        DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.home_fishing_yugan, self:getYuGanTypeByName(self.poleNode[who].name))
        self.poleNode[who] = nil
        self.pole[who] = nil
    end
end

function HomeFishingDlg:creatWaveToFupiao()
    self.fupiaoWave = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.home_fish_wave.name)
    self.effectPanel = self:getControl("EffectPanel", nil, "LiftPanel")
    local size = self.effectPanel:getContentSize()
    self.fupiaoWave:setAnchorPoint(0.5, 0.5)
    self.fupiaoWave:setPosition(size.width / 2, size.height / 2)
    self.fupiaoWave:setTag(WAVE_TAG)
    self.effectPanel:addChild(self.fupiaoWave)
end

function HomeFishingDlg:creatWave(who, panelName)
    self.wave[who] = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.home_fish_wave.name)
    local polePanel = self:getControl("FishPolePanel", nil, panelName)
    local size = polePanel:getContentSize()
    self.wave[who]:setAnchorPoint(0.5, 0.5)
    self.wave[who]:setPosition(size.width / 2, -15)
    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            if self.wave[who] then
                if self.poleStatus[who] ~= "lagan" then
                    self.wave[who]:getAnimation():play("Bottom07", -1, 1)
                    self.wave[who]:setVisible(true)
                end
            end
        end
    end

    self.wave[who]:getAnimation():setMovementEventCallFunc(func)

    polePanel:addChild(self.wave[who])
    self.wave[who]:setVisible(false)
end

function HomeFishingDlg:creatPole(name, who, panelName)
    if self.poleNode[who] then
        if self.poleNode[who].name ~= name then
            self:removePole(who)
        else
            return
        end
    end

    self.pole[who] = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.home_fishing_yugan, self:getYuGanTypeByName(name))

    -- 将 Armature 放到某个 node 上
    self.poleNode[who] = tolua.cast(self.pole[who], "cc.Node")
    self.poleNode[who].name = name
    local polePanel = self:getControl("FishPolePanel", nil, panelName)
    local size = polePanel:getContentSize()
    self.poleNode[who]:setPosition(size.width / 2, -15)
    polePanel:addChild(self.poleNode[who])

    DragonBonesMgr:toPlay(self.pole[who], "daiji", 0)
end

function HomeFishingDlg:getFishTypeByName(name)
    if CHS[5400185] == name then --"河虾",
        return "hexia_01"
    elseif CHS[5400186] == name then --"河蟹",
        return "hexie_01"
    elseif CHS[5400187] == name then --"小黄鱼",
        return "xiaohuangyu_01"
    elseif CHS[5400188] == name then --"草鱼",
        return "caoyu_01"
    elseif CHS[5400189] == name then --"鲶鱼",
        return "nianyu_01"
    elseif CHS[5400190] == name then --"泥鳅",
        return "niqiu_01"
    elseif CHS[5400191] == name then --"鲤鱼",
        return "liyu_01"
    elseif CHS[5400192] == name then --"多宝鱼",
        return "duobaoyu_01"
    elseif CHS[5400193] == name then --"石斑鱼",
        return "shibanyu_01"
    elseif CHS[5400194] == name then --"青龙鱼",
        return "qinlongyu_01"
    elseif CHS[5400195] == name then -- "鲨鱼",
        return "youshayu_01"
    elseif CHS[5400196] == name then --"河豚",
        return "hetun_01"
    end
end

function HomeFishingDlg:creaCatchFish(name)
    if self.fishNode then
        if self.fishNode.name ~= name then
            self.fishNode:removeFromParent()
            DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.catch_fish, self:getFishTypeByName(self.fishNode.name))
        else
            DragonBonesMgr:toPlay(self.fish, "shanggou", 0)
            return
        end
    end

    self.fish = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.catch_fish, self:getFishTypeByName(name))

    -- 将 Armature 放到某个 node 上
    self.fishNode = tolua.cast(self.fish, "cc.Node")
    self.fishNode.name = name
    local fishPanel = self:getControl("FishPanel", nil, "ResultPanel")
    local size = fishPanel:getContentSize()
    self.fishNode:setPosition(size.width / 2, size.height / 2)
    fishPanel:addChild(self.fishNode)

    DragonBonesMgr:toPlay(self.fish, "shanggou", 0)
end

function HomeFishingDlg:creaFuPiao()
    if self.fupiaoNode then
        self.fupiaoNode:removeFromParent()
        DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.fupiao_fudong, "yupiao_01")
    end

    self.fupiao = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.fupiao_fudong, "yupiao_01")

    -- 将 Armature 放到某个 node 上
    self.fupiaoNode = tolua.cast(self.fupiao, "cc.Node")
    local waterPanel = self:getControl("WaterImage1", nil, "LiftPanel")
    local size = waterPanel:getContentSize()
    self.fupiaoNode:setPosition(size.width / 2, 0)
    waterPanel:addChild(self.fupiaoNode)
end

function HomeFishingDlg:onToolButton(sender, eventType)
    if not self.myInfo then
        return
    end

    DlgMgr:openDlgEx("ChooseFishToolDlg", {poleName = self.selectPoleName, baitName = self.selectBaitName, level = self.myInfo.fish_level})
end

function HomeFishingDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("HomeFishingRuleDlg")
end

function HomeFishingDlg:onFriendButton(sender, eventType)
    FriendMgr:openFriendDlg()
end

function HomeFishingDlg:onBagButton(sender, eventType)
    local last = DlgMgr:getLastDlgByTabDlg('BagDlg') or 'BagDlg'
    DlgMgr:openDlg(last)

    RedDotMgr:removeOneRedDot("GameFunctionDlg", "BagButton")
end

function HomeFishingDlg:onChannelOpen()
    local dlg = DlgMgr:openDlg("ChannelDlg")
    if dlg and self.lastOpenChannelTime and gfGetTickCount() - self.lastOpenChannelTime > 1000 then
        dlg:show()
        self:setLastOpenChannelTime()
    end
end

function HomeFishingDlg:setLastOpenChannelTime()
    self.lastOpenChannelTime = gfGetTickCount()
end

function HomeFishingDlg:onChatButton(sender, eventType)
    self:onChannelOpen()
end

function HomeFishingDlg:onThrowButton(sender, eventType)
    if self.myInfo and self.myInfo.today_fishing_time >= 30 then
        if self.homeType == CHS[2000251] then
            gf:ShowSmallTips(CHS[5400206])
        else
            gf:ShowSmallTips(CHS[5410119])
        end

        return
    end

    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[5400207])
        return
    end

    if self.selectPoleName == "" or self.selectBaitName == "" then
        DlgMgr:openDlgEx("ChooseFishToolDlg", {poleName = self.selectPoleName, baitName = self.selectBaitName, level = self.myInfo.fish_level})
        gf:ShowSmallTips(CHS[5400208])
        return
    end

    gf:CmdToServer("CMD_HOUSE_START_FISH")
end


function HomeFishingDlg:onLiftButton(sender, eventType)

    gf:CmdToServer("CMD_HOUSE_TIGAN", {no = math.max(self.fupiaoStatus, 1)})
end

function HomeFishingDlg:onConfirmImage(sender, eventType)
    self:setFishingStatus(STATUS.DAIJI, "me")
    if self.fish then
        DragonBonesMgr:stop(self.fish, "shanggou")
    end
end

function HomeFishingDlg:onExpendButton1(sender, eventType)
    self:expendButton("PersenPanel1", "me", self.myInfo or {})
end

function HomeFishingDlg:expendButton(ctrlName, who, data)
    local panel = self:getControl(ctrlName)
    local height = heightChange[who]
    local listView = self:getControl("DiaryPanel_0", nil, panel):getChildByTag(LISTVIEW_TAG)
    local size = listView:getContentSize()
    listView:setContentSize(size.width, size.height + height)
    local infoPanel = self:getControl("PersenInfoPanel", nil, panel)
    infoPanel:setPositionY(infoPanel:getPositionY() + height)
    local expend = self:getControl("ExpendButton", nil, panel)
    expend:setPositionY(expend:getPositionY() + height)
    local bkImage = self:getControl("BKImage1", nil, panel)
    local size = bkImage:getContentSize()
    bkImage:setContentSize(size.width, size.height + height)

    if height > 0 then
        expend:setScaleY(-1)
        -- self.isExpend[who] = true
    else
        expend:setScaleY(1)
        -- self.isExpend[who] = false
    end

    heightChange[who] = -heightChange[who]

    -- self:setHistoryInfo(data, panel, who)
end

function HomeFishingDlg:onExpendButton2(sender, eventType)
    self:expendButton("PersenPanel2", "other", self.otherInfo or {})
end

-- 邀请伴侣
function HomeFishingDlg:onInvitationButton(sender, eventType)
    if self.myInfo and self.myInfo.couple then
        local friend = FriendMgr:getFriendByGid(self.myInfo.couple.gid)
        if friend and 2 == friend:queryInt("online") then
            gf:ShowSmallTips(CHS[5400223])
            return
        end

        if gf:getServerTime() - last_invente_time < 10 then
            gf:ShowSmallTips(CHS[5000297])
            return
        end

        last_invente_time = gf:getServerTime()

        local couple = self.myInfo.couple
        local gender = BrowMgr:getGenderSign()
        local msg = string.format(CHS[5400198], gender, "{\t" .. CHS[5400197] .. "=fishHomeInfo=me}")
        FriendMgr:sendMsgToFriend(couple.name, msg, couple.gid)
    end
end

function HomeFishingDlg:onOutButton(sender, eventType)
    gf:confirm(CHS[5400172], function()
        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
            gf:ShowSmallTips(CHS[5410117])
            return
        end

        DlgMgr:closeDlg("HomeFishingDlg")
    end)
end

-- 切后台暂停
function HomeFishingDlg:onPause()
    gf:CmdToServer("CMD_HOUSE_FISH_PAUSE", {})
end

-- 切回前台恢复游戏
function HomeFishingDlg:onResume()
    gf:CmdToServer("CMD_HOUSE_FISH_CONTINUE", {})
end

function HomeFishingDlg:setNotOtherPlayer(isMarried, isCoupleHome)
    local levelPanel = self:getControl("LevelPanel", nil, "PersenPanel2")
    levelPanel:removeChildByTag(LOCATE_POSITION.LEFT_TOP * 999)

    self:setLabelText("PlayerNameLabel", "", "PersenPanel2")

    self:setLabelText("FishingLvLabel", "", "PersenPanel2")

    local polePanel = self:getControl("PolePanel", nil, "PersenPanel2")
    self:setCtrlVisible("NumLabel", false, polePanel)
    self:setCtrlVisible("NoneLabel", true, polePanel)

    local baitPanel = self:getControl("BaitIPanel", nil, "PersenPanel2")
    self:setCtrlVisible("NumLabel", false, baitPanel)
    self:setCtrlVisible("NoneLabel", true, baitPanel)

    local FishPanel = self:getControl("FishPanel", nil, "PersenPanel2")
    self:setLabelText("NumLabel", 0, FishPanel)

    self:setImage("PoleImage", ResMgr.ui.not_pole_default, "PersenPanel2")
    self:setImage("BaitImage", ResMgr.ui.not_bait_default, "PersenPanel2")

    self:removePole("other")

    if isCoupleHome then
        self:setCtrlVisible("InvitationButton", true, "PersenPanel2")
        self:setCtrlVisible("NoticePanel", false, "PersenPanel2")
    else
        self:setCtrlVisible("InvitationButton", false, "PersenPanel2")
        self:setCtrlVisible("NoticePanel", true, "PersenPanel2")
        if isMarried then
            self:setCtrlVisible("TextLabel1", false, "PersenPanel2")
            self:setCtrlVisible("TextLabel2", true, "PersenPanel2")
        else
            self:setCtrlVisible("TextLabel1", true, "PersenPanel2")
            self:setCtrlVisible("TextLabel2", false, "PersenPanel2")
        end
    end

    self:setImage("ShapeImage", ResMgr.ui.fish_default_portrait, "PersenPanel2")
end

function HomeFishingDlg:setOneHisInfo(data, cell)
    local time = gf:getServerDate("%H:%M", data.time)
    local str = string.format(CHS[5400184], time, InventoryMgr:getUnit(data.fish_name) or "", data.fish_name, data.level)
    self:setColorText(str, cell, nil, nil, nil, COLOR3.WHITE)
end

function HomeFishingDlg:setHistoryInfo(data, cell, who)
    --local listView = cell:getChildByTag(LISTVIEW_TAG)
    local listView = self:getControl("DiaryPanel_0", nil, cell):getChildByTag(LISTVIEW_TAG)
    listView:removeAllChildren()
    self.historyCou[who] = 0
    local hisInfo = data.his_info or {}
    local cou = #hisInfo
    if cou == 0 then
        local cell = self:getHistoryCell(who)
        self:setColorText(CHS[5400205], cell, nil, nil, nil, COLOR3.WHITE)
        listView:pushBackCustomItem(cell)
        return
    end

    -- 历史记录框展开时全部加载，未展开时只加载一条
    local endIndex = 1
    --[[if not self.isExpend[who] then
        endIndex = cou
    end]]

    for i = cou, endIndex, -1 do
        local panel = self:getHistoryCell(who)
        self:setOneHisInfo(hisInfo[i], panel)
        listView:pushBackCustomItem(panel)
    end
end

function HomeFishingDlg:getHistoryCell(who)
    local cell
    local cou = self.historyCou[who] + 1
    if self.historyCells[who][cou] then
        cell = self.historyCells[who][cou]
    else
        cell = self.diaryPanel:clone()
        cell:retain()
        table.insert(self.historyCells[who], cell)
    end

    self.historyCou[who] = self.historyCou[who] + 1

    return cell
end

function HomeFishingDlg:setPlayerData(data, panelName, who)
    -- 人物头像及等级
    local cell = self:getControl(panelName)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    self:setImage("ShapeImage", ResMgr:getSmallPortrait(data.icon), cell)

    -- 名字
    self:setLabelText("PlayerNameLabel", data.name, cell)

    -- 钓鱼等级
    if data.fish_level < MAX_LEVEL then
        self:setLabelText("FishingLvLabel", string.format(CHS[5400173] .. " (%d/%d)", data.fish_level, data.proficiency, data.max_proficiency), cell)
    else
        self:setLabelText("FishingLvLabel", string.format(CHS[5400173], data.fish_level), cell)
    end

    -- 更新鱼竿数量及鱼竿对象
    self:updateFishToolsNum(data, panelName, who)

    -- 刷新历史钓鱼信息
    self:setHistoryInfo(data, cell, who)

    local FishPanel = self:getControl("FishPanel", nil, cell)
    self:setLabelText("NumLabel", data.today_fishing_time, FishPanel)

    if who == "other" then
        self:setCtrlEnabled("ShapeImage", true, "PersenPanel2")
        self:setCtrlVisible("InvitationButton", false, "PersenPanel2")
        self:setCtrlVisible("NoticePanel", false, "PersenPanel2")
    end
end

function HomeFishingDlg:MSG_HOUSE_FISH_BASIC(data)
    if not data then
        return
    end

    local players = HomeMgr.playerFishingInfo
    if data.gid == self.myGid then
        -- 自己
        self:setPlayerData(data, "PersenPanel1", "me")

        if data.is_married == 1 then
            if not players[data.couple.gid] then
                self:setNotOtherPlayer(true, HomeMgr:isCoupleStore())
            end
        else
            self:setNotOtherPlayer(false, false)
        end

        self.myInfo = data

        self.selectPoleName = data.pole_name
        self.selectBaitName = data.bait_name
    else
        -- 伴侣
        self:setPlayerData(data, "PersenPanel2", "other")
        self.otherInfo = data

        if self.poleNode["other"] and self.firstEnter then
            if data.cur_status == "paogan" then
                self:setFishingStatus(STATUS.WAITING, "other")
            elseif data.cur_status == "fubiaopaodong" then
                self:setFishingStatus(STATUS.FUPIAO, "other")
            elseif data.cur_status == "lache" then
                self:setFishingStatus(STATUS.LACHE, "other")
            end

            self.firstEnter = false
        end
    end
end

function HomeFishingDlg:MSG_HOSUE_QUIT_FISH(data)
    if data.gid ~= self.myGid and self.otherInfo then
        self:setNotOtherPlayer(true, HomeMgr:isCoupleStore(), self.otherInfo.icon)
        self.otherInfo = nil
        local cell = self:getControl("PersenPanel2")
        self:setHistoryInfo({}, cell, "other")
    elseif data.gid == self.myGid then
        DlgMgr:closeDlg("HomeFishingDlg")
        DlgMgr:closeDlg("ChooseFishToolDlg")
    end
end

-- 更新鱼具鱼饵数量
function HomeFishingDlg:updateFishToolsNum(data, panelName, who)
    local cell = self:getControl(panelName)
    local polePanel = self:getControl("PolePanel", nil, cell)
    if data.pole_name ~= "" then
        self:setLabelText("NumLabel", data.pole_count, polePanel)
        self:setCtrlVisible("NumLabel", true, polePanel)
        self:setCtrlVisible("NoneLabel", false, polePanel)
        self:creatPole(data.pole_name, who, panelName)

        if self.polesInfo[data.pole_name] then
            self:setImage("PoleImage", ResMgr:getItemIconPath(self.polesInfo[data.pole_name].icon), polePanel)
        end
    else
        self:setCtrlVisible("NumLabel", false, polePanel)
        self:setCtrlVisible("NoneLabel", true, polePanel)
        self:setImage("PoleImage", ResMgr.ui.not_pole_default, polePanel)
        self:removePole(who)
    end

    local baitPanel = self:getControl("BaitIPanel", nil, cell)
    if data.bait_name ~= "" then
        self:setLabelText("NumLabel", data.bait_count, baitPanel)
        self:setCtrlVisible("NumLabel", true, baitPanel)
        self:setCtrlVisible("NoneLabel", false, baitPanel)
        if self.baitsInfo[data.bait_name] then
            self:setImage("BaitImage", ResMgr:getItemIconPath(self.baitsInfo[data.bait_name].icon), baitPanel)
        end
    else
        self:setCtrlVisible("NumLabel", false, baitPanel)
        self:setCtrlVisible("NoneLabel", true, baitPanel)
        self:setImage("BaitImage", ResMgr.ui.not_bait_default, baitPanel)
    end
end

-- 当前使用的渔具
function HomeFishingDlg:MSG_HOUSE_USE_FISH_TOOL(data)
    if self.myGid == data.gid then
        self:updateFishToolsNum(data, "PersenPanel1", "me")

        self.selectPoleName = data.pole_name
        self.selectBaitName = data.bait_name
    else
        self:updateFishToolsNum(data, "PersenPanel2", "other")
    end
end

-- 抛竿状态
function HomeFishingDlg:MSG_HOSUE_FISH_PAOGAN(data)
    if self.myGid == data.gid then
        self:setFishingStatus(STATUS.WAITING, "me")
        self.isFirstFishing = false
    else
        self:setFishingStatus(STATUS.WAITING, "other")
    end
end

-- 浮漂浮动倒计时
function HomeFishingDlg:playCountDown(tag, time)
    local panel = self:getControl("LookPanel")

    panel:removeChildByTag(tag)
    panel:stopAllActions()

    -- 扇形倒计时
    local progressImage = self:getControl("ProgressImage")

    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.fish_progressTimer))
    progressTimer:setReverseDirection(true)
    progressTimer:setTag(tag)
    panel:addChild(progressTimer)

    progressTimer:setPosition(progressImage:getPosition())
    progressTimer:setLocalZOrder(15)
    progressTimer:setPercentage(100)
    local progressTo = cc.ProgressTo:create(time, 0)
    local endAction = cc.CallFunc:create(function()
        progressTimer:removeFromParent()
    end)

    progressTimer:runAction(cc.Sequence:create(progressTo, endAction))
end

-- 鱼和滑板的初始状态
function HomeFishingDlg:setLacheInitData()
    self.fishSwimTime = 0
    self.fishDir = 1
    self.fishPosY = self.canFishHeight / 2
    self.fishImage:setPositionY(self.fishPosY)

    self.clickBoardTime = 0
    self.boardSpeed = BOARD_INIT_SPEED_DOWN
    self.boardDir = 2
    self.boardPosY = self.canFishHeight / 2
    if self.selectPoleName == CHS[5400174] then
        self.boardImage = self:getControl("AreaImage3", nil, "PullPanel")

        self:setCtrlVisible("AreaImage1", fasle, "PullPanel")
        self:setCtrlVisible("AreaImage2", false, "PullPanel")
        self:setCtrlVisible("AreaImage3", true, "PullPanel")
    elseif self.selectPoleName == CHS[5400175] then
        self.boardImage = self:getControl("AreaImage2", nil, "PullPanel")

        self:setCtrlVisible("AreaImage1", false, "PullPanel")
        self:setCtrlVisible("AreaImage2", true, "PullPanel")
        self:setCtrlVisible("AreaImage3", false, "PullPanel")
    else
        self.boardImage = self:getControl("AreaImage1", nil, "PullPanel")

        self:setCtrlVisible("AreaImage1", true, "PullPanel")
        self:setCtrlVisible("AreaImage2", false, "PullPanel")
        self:setCtrlVisible("AreaImage3", fasle, "PullPanel")
    end

    self.boardHeight = self.boardImage:getContentSize().height
    self.boardImage:setPositionY(self.boardPosY)

    self.rightDis = (self.boardHeight - self.fishHeight) / 2

    -- 进度条
    self.bar = self:getControl("ProgressBar", nil, "PullPanel")
    self.bar:setPercent(50)
end

function HomeFishingDlg:getMyFishingStatus()
    return self.fishingStatus["me"]
end

function HomeFishingDlg:setFishingStatus(status, who)
    if who == "me" then
        if status == STATUS.DAIJI then
            -- 待机
            self:setCtrlVisible("ThrowButton", true and self.isFirstFishing)
            self:setCtrlVisible("ThrowButton2", true and not self.isFirstFishing)
            self:setCtrlVisible("LiftPanel", false)
            self:setCtrlVisible("PullPanel", false)
            self:setCtrlVisible("ResultPanel", false)
            self:setCtrlVisible("WaitNoticePanel", false)

            DragonBonesMgr:toPlay(self.pole[who], "daiji", 0)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "daiji"
        elseif status == STATUS.WAITING then
            -- 垂钓等待
            self:setCtrlVisible("ThrowButton", false)
            self:setCtrlVisible("ThrowButton2", false)
            self:setCtrlVisible("LiftPanel", false)
            self:setCtrlVisible("PullPanel", false)
            self:setCtrlVisible("ResultPanel", false)
            self:setCtrlVisible("WaitNoticePanel", true)

            DragonBonesMgr:toPlay(self.pole[who], "shuaigan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shuaigan"

            -- 浮漂入水
            self.wave[who]:getAnimation():play("Bottom09")
            self.wave[who]:setVisible(true)

            self.fupiaoDownTime = -1
            self:refreshTime()
        elseif status == STATUS.FUPIAO then
            -- 开始浮漂浮动
            self:setCtrlVisible("ThrowButton", false)
            self:setCtrlVisible("ThrowButton2", false)
            self:setCtrlVisible("LiftPanel", true)
            self:setCtrlVisible("PullPanel", false)
            self:setCtrlVisible("ResultPanel", false)
            self:setCtrlVisible("WaitNoticePanel", false)

            self:playCountDown(2, self.totalTime)

            DragonBonesMgr:toPlay(self.pole[who], "chuidiao", 0)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "chuidiao"

            self.fupiaoStatus = 0
        elseif status == STATUS.LACHE then
            -- 拉扯
            self:setCtrlVisible("ThrowButton", false)
            self:setCtrlVisible("ThrowButton2", false)
            self:setCtrlVisible("LiftPanel", false)
            self:setCtrlVisible("PullPanel", true)
            self:setCtrlVisible("ResultPanel", false)
            self:setCtrlVisible("WaitNoticePanel", false)

            DragonBonesMgr:toPlay(self.pole[who], "lagan", 0)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "lagan"

            self.wave[who]:getAnimation():play("Bottom08", -1, 0)

            self.isLacheFinish = false
            self:setLacheInitData()
        elseif status == STATUS.SUCC then
            -- 捕获成功
            self:setCtrlVisible("ThrowButton", false)
            self:setCtrlVisible("ThrowButton2", false)
            self:setCtrlVisible("LiftPanel", false)
            self:setCtrlVisible("PullPanel", false)
            self:setCtrlVisible("ResultPanel", true)
            self:setCtrlVisible("WaitNoticePanel", false)

            DragonBonesMgr:toPlay(self.pole[who], "shougan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shougan"

            self.wave[who]:setVisible(false)

            self.angle = 0
        elseif status == STATUS.FAIL then
            -- 失败
            self:setCtrlVisible("ThrowButton", true and self.isFirstFishing)
            self:setCtrlVisible("ThrowButton2", true and not self.isFirstFishing)
            self:setCtrlVisible("LiftPanel", false)
            self:setCtrlVisible("PullPanel", false)
            self:setCtrlVisible("ResultPanel", false)
            self:setCtrlVisible("WaitNoticePanel", false)

            DragonBonesMgr:toPlay(self.pole[who], "shougan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shougan"

            self.wave[who]:setVisible(false)
        end

        if status ~= STATUS.WAITING then
            self.fupiaoDownTime = 11
        end

    else
        if status == STATUS.DAIJI then
            -- 待机
            DragonBonesMgr:toPlay(self.pole[who], "daiji", 0)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "daiji"
        elseif status == STATUS.WAITING then
            -- 垂钓等待
            DragonBonesMgr:toPlay(self.pole[who], "shuaigan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shuaigan"

            self.wave[who]:getAnimation():play("Bottom09")
            self.wave[who]:setVisible(true)
        elseif status == STATUS.FUPIAO then
            -- 开始浮漂浮动
            DragonBonesMgr:toPlay(self.pole[who], "chuidiao", 0)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "chuidiao"
        elseif status == STATUS.LACHE then
            -- 拉扯（伴侣不做拉杆效果，拉杆时显示垂钓）
            if self.poleStatus[who] ~= "chuidiao" then
                DragonBonesMgr:toPlay(self.pole[who], "chuidiao", 0)

                self.wave[who]:getAnimation():play("Bottom09")
                self.wave[who]:setVisible(true)
            end

            self.fishingStatus[who] = status
            self.poleStatus[who] = "chuidiao"
        elseif status == STATUS.SUCC then
            -- 捕获成功
            DragonBonesMgr:toPlay(self.pole[who], "shougan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shougan"

            self.wave[who]:setVisible(false)
        elseif status == STATUS.FAIL then
            -- 失败
            DragonBonesMgr:toPlay(self.pole[who], "shougan", 1)
            self.fishingStatus[who] = status
            self.poleStatus[who] = "shougan"

            self.wave[who]:setVisible(false)
        end
    end
end

-- 浮标跑动状态
function HomeFishingDlg:MSG_HOSUE_FISH_FUBIAOPAODONG(data)
    if self.myGid == data.gid then
        self.fupiaoInfo = data
        self.totalTime = self:setTotalTime(data)
        self:setFishingStatus(STATUS.FUPIAO, "me")
    else
        self:setFishingStatus(STATUS.FUPIAO, "other")
    end
end

function HomeFishingDlg:setTotalTime(data)
    local time = 0
    for i = 1, #data do
        time = time + FUPIAO_TIME[data[i]]
    end

    return time
end

-- 浮标跑动失败状态
function HomeFishingDlg:MSG_HOSUE_FISH_FUBIAOPAODONG_FAIL(data)
    if self.myGid == data.gid then
        self:setFishingStatus(STATUS.FAIL, "me")
    else
        self:setFishingStatus(STATUS.FAIL, "other")
    end
end

-- 拉扯状态
function HomeFishingDlg:MSG_HOSUE_FISH_LACHE(data)
    if self.myGid == data.gid then
        self:setFishingStatus(STATUS.LACHE, "me")
    else
        self:setFishingStatus(STATUS.LACHE, "other")
    end
end

-- 拉扯失败状态
function HomeFishingDlg:MSG_HOSUE_FISH_LACHE_FAIL(data)
    if self.myGid == data.gid then
        self:setFishingStatus(STATUS.FAIL, "me")
    else
        self:setFishingStatus(STATUS.FAIL, "other")
    end
end

function HomeFishingDlg:getFishIconByName(name)
    if CHS[5400185] == name then --"河虾",
        return ResMgr.ui.hexia_word
    elseif CHS[5400186] == name then --"河蟹",
        return ResMgr.ui.hexie_word
    elseif CHS[5400187] == name then --"小黄鱼",
        return ResMgr.ui.xiaohuangyu_word
    elseif CHS[5400188] == name then --"草鱼",
        return ResMgr.ui.caoyu_word
    elseif CHS[5400189] == name then --"鲶鱼",
        return ResMgr.ui.nianyu_word
    elseif CHS[5400190] == name then --"泥鳅",
        return ResMgr.ui.niqiu_word
    elseif CHS[5400191] == name then --"鲤鱼",
        return ResMgr.ui.liyu_word
    elseif CHS[5400192] == name then --"多宝鱼",
        return ResMgr.ui.duobaoyu_word
    elseif CHS[5400193] == name then --"石斑鱼",
        return ResMgr.ui.shibanyu_word
    elseif CHS[5400194] == name then --"青龙鱼",
        return ResMgr.ui.qinglongyu_word
    elseif CHS[5400195] == name then -- "鲨鱼",
        return ResMgr.ui.shayu_word
    elseif CHS[5400196] == name then --"河豚",
        return ResMgr.ui.hetun_word
    end
end

-- 钓鱼成功状态
function HomeFishingDlg:MSG_HOSUE_FISH_SUCC(data)
    if self.myGid == data.gid then
        self:setFishingStatus(STATUS.SUCC, "me")
        self:creaCatchFish(data.fish_name)
        self:setImage("LevelImage", ResMgr.ui["fish_level_word" .. data.level], "ResultPanel")
        self:setImage("NameImage", self:getFishIconByName(data.fish_name), "ResultPanel")
    else
        self:setFishingStatus(STATUS.SUCC, "other")
    end
end

-- 所有渔具的数据
function HomeFishingDlg:MSG_HOUSE_ALL_FISH_TOOL_INFO(data)
end

-- 部分渔具的数据
function HomeFishingDlg:MSG_HOUSE_FISH_TOOL_PART_INFO(data)
    if data.gid == self.myGid then
        local info = HomeMgr.playerFishingInfo[data.gid]
        if info then
            info.pole_count = data.tools[info.pole_name] or info.pole_count
            info.bait_count = data.tools[info.bait_name] or info.bait_count

            self:updateFishToolsNum(info, "PersenPanel1", "me")
        end
    else
        local info = HomeMgr.playerFishingInfo[data.gid]
        if info then
            info.pole_count = data.tools[info.pole_name] or info.pole_count
            info.bait_count = data.tools[info.bait_name] or info.bait_count

            self:updateFishToolsNum(info, "PersenPanel2", "other")
        end
    end
end

function HomeFishingDlg:MSG_HOUSE_FISH_CHANGE_NAME(data)
    if not self.myInfo or not self.myInfo.couple then
        return
    end

    local other = HomeMgr.allFishToolsInfo[data.gid]
    if not other and data.gid == self.myInfo.couple.gid then
        self.myInfo.couple.name = data.new_name
    end
end

function HomeFishingDlg:MSG_MESSAGE_EX(data)
    if data["channel"] ~= CHAT_CHANNEL.CURRENT
        and data["channel"] ~= CHAT_CHANNEL.TEAM then
        -- 只有当前频道和队伍频道才弹冒泡
        return
    end

    local players = HomeMgr.playerFishingInfo or {}
    if self.myGid == data.gid then
        self:showTips(data.msg, 3, "PersenPanel1", data.show_extra)
    elseif self.myInfo and self.myInfo.couple then
        if self.myInfo.couple.gid == data.gid and players[data.gid] then
           self:showTips(data.msg, 3, "PersenPanel2", data.show_extra)
        end
    end
end


function HomeFishingDlg:cleanup()
    gf:CmdToServer("CMD_HOUSE_QUIT_FISH")

    local dlg = DlgMgr:getDlgByName("ChatDlg")
    if dlg then
        dlg:setStopRefreshData(false)
    end

    self.otherInfo = nil
    self.myInfo = nil

    if self.historyCells then
        for _, v in pairs(self.historyCells["me"]) do
            if v then
                v:release()
            end
        end

        for _, v in pairs(self.historyCells["other"]) do
            if v then
                v:release()
            end
        end
    end

    self.historyCells = nil

    -- 关闭该界面时，同时关闭对应子界面
    DlgMgr:closeDlg("HomeFishingRuleDlg")
    DlgMgr:closeDlg("ChooseFishToolDlg")

    local path = ResMgr:getUIArmatureFilePath("01222")
    ArmatureMgr:removeArmatureFileInfoByName(path)

    local path = ResMgr:getUIArmatureFilePath("01235")
    ArmatureMgr:removeArmatureFileInfoByName(path)

    EventDispatcher:removeEventListener('ENTER_BACKGROUND', self.onPause, self)
    EventDispatcher:removeEventListener('ENTER_FOREGROUND', self.onResume, self)

    self:removePole("me")
    self:removePole("other")

    if self.fishNode then
        DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.catch_fish, self:getFishTypeByName(self.fishNode.name))
    end

    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.fupiao_fudong,  "yupiao_01")
end

function HomeFishingDlg:refreshTime()
    if self.fupiaoDownTime == 11 then
        return
    end

    self.fupiaoDownTime = self.fupiaoDownTime + 1 -- gf:getServerTime() - self.startWaitTime
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.YELLOW, self.fupiaoDownTime, false, LOCATE_POSITION.MID, 25, "WaitNoticePanel")
end

function HomeFishingDlg:onRefresh()
    self:updateTime()

    -- 更新电池状态
    local batteryInfo = BatteryAndWifiMgr:getBatteryInfo()

    if batteryInfo then
        self:updateBattery(batteryInfo.rawlevel, batteryInfo.scale, batteryInfo.status, batteryInfo.health)
    end

    -- 更新网络状态
    local networkState = BatteryAndWifiMgr:getNetworkState()

    if networkState then
        self:updateNetwork(networkState)

        -- 是wifi,更新wifi强度
        local wifiInfo = BatteryAndWifiMgr:getWifiInfo()
        if NET_TYPE.WIFI == networkState and wifiInfo then
            self:updateWifiStatus(wifiInfo.wifiState, wifiInfo.level)
        end
    end

    self:refreshSignalColor()

    self:refreshTime()
end

-- 更新电池状态
function HomeFishingDlg:updateBattery(rawlevel, scale, status, health)
    local level;
    if rawlevel >= 0 and scale > 0 then
        level = (rawlevel * 100) / scale;
    end

    local batterProcessBar = self:getControl("ProgressBar")
    local chargeImage = self:getControl("ChargeImage")

    if BATTERY_STATE.OVERHEAT == health then
    -- gf:ShowSmallTips("电池过热！")
    else
        if BATTERY_STATE.UNKNOWN == status then
            -- gf:ShowSmallTips("这神器没有电池！")
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.CHARGING == status then
            -- 充电状态
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        elseif BATTERY_STATE.DISCHARGING == status
            or BATTERY_STATE.NOT_DISCHARGING == status then
            -- 更新电池状态即可
            batterProcessBar:setVisible(true)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.FULL == status then
            -- 充满了
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        end
    end

    -- 更新电池状态
    batterProcessBar:setPercent(level)
end

-- 更新网络状态
function HomeFishingDlg:updateNetwork(networkState)

    if not networkState then return end

    if NET_TYPE.WIFI ~= networkState then
        self:setCtrlVisible("SignalPanel", false)
        self:setCtrlVisible("SignalPanel_0", true)
        return
    end

    self:setCtrlVisible("SignalPanel", true)
    self:setCtrlVisible("SignalPanel_0", false)
end

-- 更新wifi状态
-- 0 - -50信号最好， -50 - -70信号差点， 小于 -70 的信号最差
function HomeFishingDlg:updateWifiStatus(wifiState, level)
    local levelStatus
    if level < -70 then
        levelStatus = 1
    elseif level < -50 then
        levelStatus = 2
    else
        levelStatus = 3
    end

    self:updateWifiUI(levelStatus)
end

function HomeFishingDlg:updateWifiUI(levelStatus)
    local wifiLevelImg = {
        [1] = "SignalImage_2",
        [2] = "SignalImage_3",
        [3] = "SignalImage_4",
    }

    for k, v in pairs(wifiLevelImg) do
        self:setCtrlVisible(v, false)
    end

    self:setCtrlVisible(wifiLevelImg[levelStatus], true)
end


function HomeFishingDlg:updateTime()
    local curTime = os.date("%H:%M")
    self:setLabelText("TimeLabel_1", curTime)
    self:setLabelText("TimeLabel_2", curTime)
end

function HomeFishingDlg:refreshSignalColor()
    if not self.signalImages or #self.signalImages <= 0 then return end

    local delay = Client:getLastDelayTime()
    local color
    if delay < 500 then
        color = SIGNAL_COLOR.WHITE
    else
        color = SIGNAL_COLOR.RED
    end

    local singleImage
    for i = 1, #self.signalImages do
        singleImage = self.signalImages[i]
        singleImage:setColor(color)
    end
end

-- 显示延时
function HomeFishingDlg:onSignalButton(sender, eventType)
    self:refreshSignalColor()
    local delay = Client:getLastDelayTime()
    if delay > 5000 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", "5000+"), sender)
    elseif delay < 200 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#c30E50B", tostring(delay)), sender)
    elseif delay >= 200 and delay <= 500 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF2DF0C", tostring(delay)), sender)
    else
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", tostring(delay)), sender)
    end
end

-- 冒泡
function HomeFishingDlg:showTips(msg, time, PanelName, showExtra)
    local panel = self:getControl("PersenInfoPanel", nil, PanelName)
    local size = panel:getContentSize()

    local bg = self:generateTip(msg, showExtra)

    bg:setPosition(57, size.height)

    local cb = function()
        for k, v in pairs(self.chatContent) do
            if v == bg then
                table.remove(self.chatContent, k)
            end
        end
    end

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(time),
        cc.CallFunc:create(cb),
        cc.RemoveSelf:create()
    )

    panel:addChild(bg)

    if #self.chatContent == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        local node = self.chatContent[1]
        node:runAction(newAction)
    elseif #self.chatContent > 1 then
        -- 消息到达2条时，移除对头消息, 并拿出新的队头继续向上移动
        local node = table.remove(self.chatContent, 1)
        node:stopAllActions()
        node:removeFromParent()
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        node = self.chatContent[1]
        node:runAction(newAction)
    end

    bg:runAction(action)
    table.insert(self.chatContent, bg)
end

function HomeFishingDlg:generateTip(str, showExtra)
    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(17)
    tip:setString(str, showExtra)

    tip:setContentSize(GENERAL_WIDTH - WIDTH_MARGIN * 2, 0)

    tip:updateNow()
    local w, h = tip:getRealSize()
    if w < 6 then
        w = 6
    end

    tip:setPosition(WIDTH_MARGIN, HEIGHT_MARGIN + h)
    local layer = ccui.Layout:create()
    local arrow = ccui.ImageView:create(ResMgr.ui.talk_bubbles_arrow)

    layer:setContentSize(cc.size(w + (WIDTH_MARGIN * 2), h + HEIGHT_MARGIN * 2))

    arrow:setPosition(layer:getContentSize().width * 0.5, 0)
    layer:setBackGroundImage(ResMgr.ui.talk_bubbles)
    layer:setBackGroundImageCapInsets(Const.BUBBLE_CAPINSECT_RECT)
    layer:setBackGroundImageScale9Enabled(true)

    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    colorLayer:setName("word")
    layer:addChild(colorLayer)
    layer:addChild(arrow)
    return layer
end

function HomeFishingDlg:addRedDotOnFriendButton(isBlink)
    self:addRedDot("FriendButton", nil, isBlink)
end

function HomeFishingDlg:addRedDotOnBagButton()
    self:addRedDot("BagButton")
end

function HomeFishingDlg:checkRedDot()
    if RedDotMgr:hasRedDotInfo("ChatDlg", "FriendButton") then
        self:addRedDot("FriendButton")
    else
        RedDotMgr:removeOneRedDot("HomeFishingDlg", "FriendButton")
    end

    if RedDotMgr:hasRedDotInfo("GameFunctionDlg", "BagButton") then
         self:addRedDot("BagButton")
    end
end

return HomeFishingDlg
