-- LingyzmDlg.lua
-- Created by July/21/2018
-- 万圣节-灵音镇魔界面

local LingyzmDlg = Singleton("LingyzmDlg", Dialog)

local STATUS = {
    S1 = "1",  -- 点击
    S2 = "2",  -- 声音
}

local GAME_MODE = {
    VOICE = 2, -- 喊话
    ACC = 1,   -- 重力感应
}

local SHAKE_TYPE = {
    CLICK = 1,  -- 点击
    VOICE = 2,  -- 发声
}

local COUNT_DOWN = 3  -- 倒计时秒数

local SPEED_SHRESHOLD = 1 -- 摇晃的最低阀值

local MIN_VOLUME = 30  -- 震动铃铛的最小音量

local MAX_INDEX = 9   -- 最大关数

function LingyzmDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("BlackPanel", "LearnResultPanel")
    self:setCtrlFullClient("BlackPanel", "ResultPanel")
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ExitButton_1", self.onCloseButton, "ResultPanel")
    self:bindListener("ExitButton_2", self.onCloseButton, "ResultPanel")
    self:bindListener("ExitButton", self.onCloseButton, "LearnResultPanel")
    self:bindListener("ExitButton_1", self.onCloseButton, "LearnResultPanel")
    self:bindListener("ExitButton", self.onCloseButton, "MenuPanel")
    self:bindListener("ContinueButton", self.onLearnContinueButton, "LearnResultPanel")
    self:bindListener("ContinueButton", self.onContinueButton, "ResultPanel")
    self:bindListener("BellPanel", self.onBellPanel, nil, true)

    -- 加载背景图
    local winSize = cc.Director:getInstance():getWinSize()
    local dlgBack = ccui.ImageView:create(ResMgr.loadingPic.tianyong)
    dlgBack:setPosition(winSize.width / Const.UI_SCALE / 2, winSize.height / Const.UI_SCALE / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    dlgBack:setName("LoadingImage")
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)

    self.startGame = false     -- 游戏是否已开始
    self.hasCmdFinish = false  
    self.delayStudySucc = nil  -- 学习状态，铃铛震动 2 秒后直接判定成功
    self.isShake = true        -- 铃铛是否处于震动
    self.isClickBell = false
    self.lastVolume = 0
    self.startDelayTime = 0
    self:stopShakeBell()

    self.myInfo = {
        pos = {x = Me.curX, y = Me.curY},
        dir = Me:getDir()
    }

    Me:setSeepPrecentByClient(-25)

    self:createCountDown(COUNT_DOWN)

    DlgMgr:closeDlg("DramaDlg")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1})

    -- 隐藏地表光效
    gf:getMapEffectLayer():setVisible(false)

    if ATM_IS_DEBUG_VER and gf:isWindows() then
        -- 仅供 windows 上测试
        schedule(self.root, function() self:onVolumeChange(math.random(MIN_VOLUME, MIN_VOLUME + 100)) end, 0)
    end

    SoundMgr:stopMusicAndSound()-- 停止音乐

    EventDispatcher:addEventListener('ENTER_FOREGROUND', self.onCheckVoice, self)
end

function LingyzmDlg:setDialogType()
    self.isSwallow = false
    self.isClose = false
    self.isBlankLayerHide = true
end

-- 创建倒计时
function LingyzmDlg:createCountDown(time)
    self:setCtrlVisible("StartPanel", false)
    local numImg = Dialog.createCountDown(self, time, "NumPanel", "StartPanel")
end

-- 设置开局倒计时数字
function LingyzmDlg:startCountDown(time)
    if DlgMgr:isDlgOpened("LoadingDlg") then
        performWithDelay(self.root, function()
            self:startCountDown(time)
        end, 0)
    else
        self:setCtrlVisible("StartPanel", true)
        Dialog.startCountDown(self, time, "NumPanel", "StartPanel", function(numImg) 
            self:setCtrlVisible("StartPanel", false)

            -- 人物开始跑
            LingyzmMgr:setPlayerRun()
            self.startGame = true
        end)
    end
end

-- 取消语音
function LingyzmDlg:cancelVoice()
    LingyzmMgr:cancelRecord()
end

-- 取消语音
function LingyzmDlg:beginRecord()
    local panel = self:getControl("BellPanel")
    return ChatMgr:beginRecord(panel, self, 432000, true)
end

-- 音量
function LingyzmDlg:onVolumeChange(volume)
    self.lastVolume = volume
    if self.curStatus == STATUS.S1 or not self.startGame or self.isClickBell then
        return
    end

    if LingyzmMgr:getCurYmShakeType() == SHAKE_TYPE.CLICK then
        return
    end

    if volume >= MIN_VOLUME then
        self:doShakeBell(SHAKE_TYPE.VOICE)
    else
        self:stopShakeBell(SHAKE_TYPE.VOICE)
    end
end

-- 界面增加重力感应
function LingyzmDlg:initAccelerometer()
    local layer = cc.Layer:create()
    layer:setAccelerometerEnabled(true)

    -- 重力感应回调函数: x > 0：右， x < 0：左，y > 0：下， y < 0：上
    local lastX, lastY, lastZ = 0, 0, 0
    local lastTime = 0
    local cou = 0
    local function accelerometerListener(event, x, y, z, timestamp)
        if self.gameMode ~= GAME_MODE.ACC or not self.startGame then
            return
        end

        local dx = x - lastX
        local dy = y - lastY
        local dz = z - lastZ
        local curTime = gfGetTickCount()
        local timeInterval = curTime - lastTime

        if curTime == 0 then return end

        local speed = math.sqrt(dx * dx + dy * dy + dz * dz) / curTime * 10000000

        if speed < SPEED_SHRESHOLD then
            if cou >= 3 then
                self:stopShakeBell()
            else
               cou = cou + 1
            end
        else
            cou = 0
            self:doShakeBell()
        end

        lastTime = curTime
        lastX, lastY, lastZ = x, y, z
    end

    local listener = cc.EventListenerAcceleration:create(accelerometerListener)
    layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layer)
    self.root:addChild(layer)

    self.accLayer = layer
end

function LingyzmDlg:setData(data)
    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("PreparePanel", false)
    self:setCtrlVisible("LoadingImage", false, self.blank)
    self:setCtrlVisible("MainBodyPanel", true)
    self:setCtrlVisible("StageImage", false, "MainBodyPanel")
    self:setCtrlVisible("StagePanel", false, "MainBodyPanel")
    self:setCtrlVisible("LearnResultPanel", false)

    -- 隐藏坐骑及婚服
    if Me:queryBasicInt("notShowRidePet") == 0 then
        Me:setAct(Const.FA_STAND)
        Me:absorbBasicFields({
            notShowRidePet = 1,
            notShowHunfu = 1
        })
    end

    self.studyResult = "fail"
    if data.status == STATUS.S1 then
        -- 学习晃动
        -- self:setImage("NoteImage", ResMgr.ui.lingyzm_click_tip, "TitlePanel")
        local img = self:getControl("NoteImage", nil, "TitlePanel")
        img:loadTexture(ResMgr.ui.lingyzm_click_tip)
        img:setScale(1.5)
        local action = cc.ScaleTo:create(0.5, 1, 1)
        img:runAction(action)

        LingyzmMgr:initStudyChar(SHAKE_TYPE.CLICK)

        self:startCountDown(COUNT_DOWN)
    elseif data.status == STATUS.S2 then
        -- 学习发音
        -- self:setImage("NoteImage", ResMgr.ui.lingyzm_talk_tip, "TitlePanel")
        local img = self:getControl("NoteImage", nil, "TitlePanel")
        img:loadTexture(ResMgr.ui.lingyzm_talk_tip)
        img:setScale(1.5)
        local action = cc.ScaleTo:create(0.5, 1, 1)
        img:runAction(action)

        LingyzmMgr:initStudyChar(SHAKE_TYPE.VOICE)

        self:startCountDown(COUNT_DOWN)
    elseif data.isRunning then
        -- 开始游戏
        self:setImage("NoteImage", ResMgr.ui.lingyzm_choose_tip, "TitlePanel")

        LingyzmMgr:initLyzmGame()

        self:startCountDown(COUNT_DOWN)

        -- 显示关卡数
        local panel = self:getControl("StagePanel", nil, "BellPanel")
        self:setImagePlist("Image_2", string.format("lingyzmword%04d.png", data.game_index), panel)

        self:setCtrlVisible("StageImage", true, "MainBodyPanel")
        self:setCtrlVisible("StagePanel", true, "MainBodyPanel")
    else
        -- 设置游戏模式阶段
        self:setCtrlVisible("PreparePanel", true)

        self:setCtrlVisible("MenuPanel", true)

        self:setCtrlVisible("LoadingImage", true, self.blank)
        self:setCtrlVisible("MainBodyPanel", false)
    end

    self.gameIndex = data.game_index or 1 -- 关卡
    self.curStatus = data.status
    self.gameId = data.game_id

    -- 地图上增加黑幕背景
    FightMgr:addFightBgOnlyBlack()
end

-- 开始游戏
function LingyzmDlg:onStartButton(sender, eventType)
    if self.gameIndex > MAX_INDEX then
        gf:ShowSmallTips(CHS[5450318])
        return
    end

    LingyzmMgr:checkCanOpenRecord(function(result)
        if not DlgMgr:isDlgOpened(self.name) then return end
        if result then
            self:setCtrlVisible("PreparePanel", false)
            gf:CmdToServer("CMD_HALLOWMAX_2018_LYZM_GAME_CONTINUE", {})
        end
    end)
end

function LingyzmDlg:onLearnContinueButton(sender, eventType)
    LingyzmMgr:checkCanOpenRecord(function(result)
        if self.myInfo and self:isStudy() then
            Me:setAct(Const.FA_STAND)
            Me:setLastMapPos(gf:convertToMapSpace(self.myInfo.pos.x, self.myInfo.pos.y))
            Me:setPos(self.myInfo.pos.x, self.myInfo.pos.y)
            Me:setDir(self.myInfo.dir)
        end

        if GameMgr.scene and GameMgr.scene.map then
            GameMgr.scene.map:update(true)
        end

        self:setData({status = self.curStatus, game_id = self.gameId})
    end)
end

-- 继续游戏
function LingyzmDlg:onContinueButton(sender, eventType)
    if self.gameIndex > MAX_INDEX then
        gf:ShowSmallTips(CHS[5450318])
        return
    end

    self:setData({game_index = self.gameIndex, game_id = self.gameId})
end

-- 处理点击摇晃铃铛
function LingyzmDlg:onBellPanel(sender, eventType)
    if not self.startGame then
        self.isClickBell = false
        return
    end

    if eventType == ccui.TouchEventType.began then
        self.isClickBell = true
        if LingyzmMgr:getCurYmShakeType() == SHAKE_TYPE.VOICE then
            -- 当前怪物需要音量才可杀死，不能点击铃铛
            self:stopShakeBell()
            gf:ShowSmallTips(CHS[5400631])
        else
            self:doShakeBell(SHAKE_TYPE.CLICK)

            sender:stopAllActions()
            performWithDelay(sender, function()
                self:stopShakeBell(SHAKE_TYPE.CLICK)
            end, 0.2)
        end
    elseif eventType == ccui.TouchEventType.ended
        or eventType == ccui.TouchEventType.canceled then
        self.isClickBell = false
        self:onVolumeChange(self.lastVolume)
    end
end

-- 摇晃铃铛
function LingyzmDlg:doShakeBell(type)
    if LingyzmMgr:getShakeTime(type) == 0 then
        LingyzmMgr:setShakeTime(type, gfGetTickCount())
    end
    
    if LingyzmMgr:getCurYmShakeType() == SHAKE_TYPE.VOICE
        and type == SHAKE_TYPE.CLICK then
        return
    end

    if LingyzmMgr:getCurYmShakeType() == SHAKE_TYPE.CLICK
        and type == SHAKE_TYPE.VOICE then
        return
    end

    if self.isShake then
        return
    end

    self.isShake = true

    local action = cc.Sequence:create(
        cc.RotateTo:create(0.1, -30),
        cc.CallFunc:create(function() 
            self:setCtrlVisible("SoundPanel_1", true)
            self:setCtrlVisible("SoundPanel_2", false)
            self:setCtrlVisible("SoundPanel_3", false)
        end),

        cc.RotateTo:create(0.1, 0),
        cc.CallFunc:create(function() 
            self:setCtrlVisible("SoundPanel_2", true)
        end),

        cc.RotateTo:create(0.1, 30),
        cc.CallFunc:create(function() 
            self:setCtrlVisible("SoundPanel_3", true)
        end),

        cc.RotateTo:create(0.1, 0),
        cc.RotateTo:create(0.1, -30),
        cc.RotateTo:create(0.1, 0),
        cc.RotateTo:create(0.1, 30),
        cc.RotateTo:create(0.1, 0)
    )

    local bell = self:getControl("BellImage")
    bell:runAction(cc.RepeatForever:create(action))
end

-- 停止摇晃铃铛
function LingyzmDlg:stopShakeBell(type)
    if type then
        LingyzmMgr:setShakeTime(type, 0)
    else
        LingyzmMgr:setShakeTime(SHAKE_TYPE.VOICE, 0)
        LingyzmMgr:setShakeTime(SHAKE_TYPE.CLICK, 0)
    end

    if LingyzmMgr:getShakeTime(SHAKE_TYPE.VOICE) > 0 
        or LingyzmMgr:getShakeTime(SHAKE_TYPE.CLICK) > 0 then
        return
    end

    if not self.isShake then
        return
    end

    self.isShake = false
    self:setCtrlVisible("SoundPanel_1", false)
    self:setCtrlVisible("SoundPanel_2", false)
    self:setCtrlVisible("SoundPanel_3", false)

    local bell = self:getControl("BellImage")
    bell:stopAllActions()
    bell:setRotation(0)

    -- LingyzmMgr:setYMAttack()
end

function LingyzmDlg:changeShakeType()
    self:stopShakeBell()

    self:onVolumeChange(self.lastVolume)
    --[[if LingyzmMgr:curIsClickShakeType() then
        self:setImage("NoteImage", ResMgr.ui.lingyzm_click_tip, "TitlePanel")
    else
        self:setImage("NoteImage", ResMgr.ui.lingyzm_talk_tip, "TitlePanel")
    end]]
end

-- 显示游戏结果
function LingyzmDlg:showResult(result)
    if self:isStudy() then
        self:showStudyResult(result)
    else
        self:showGameResult(result)
    end

    LingyzmMgr:clearAllChar()

    self:setGameOver()
end

-- 显示闯关结果
function LingyzmDlg:showGameResult(result)
    self:setCtrlVisible("ResultPanel", true)
    self:setCtrlVisible("PreparePanel", false)

    local isEnd = (self.gameIndex == MAX_INDEX and result == "succ")
    self:setCtrlVisible("ExitButton_1", not isEnd, "ResultPanel")
    self:setCtrlVisible("ExitButton_2", isEnd, "ResultPanel")
    self:setCtrlVisible("ContinueButton", not isEnd, "ResultPanel")

    local panel = self:getControl("StagePanel", nil, "ResultPanel")
    self:setImagePlist("Image_2", string.format("lingyzmword%04d.png", self.gameIndex), panel)

    if result == "succ" then
        self:setCtrlVisible("LosePanel", false, "ResultPanel")
        self:setCtrlVisible("WinPanel", true, "ResultPanel")
        self.gameIndex = self.gameIndex + 1
    else
        self:setCtrlVisible("LosePanel", true, "ResultPanel")
        self:setCtrlVisible("WinPanel", false, "ResultPanel")
    end

    LingyzmMgr:cmdLYZMGameResult(result, self.gameId)
end

-- 显示学习结果
function LingyzmDlg:showStudyResult(result)
    self:setCtrlVisible("LearnResultPanel", true)
    self:setCtrlVisible("ExitButton_1", false, "LearnResultPanel")
    self:setCtrlVisible("ExitButton", false, "LearnResultPanel")
    self:setCtrlVisible("ContinueButton", false, "LearnResultPanel")
    self:setCtrlVisible("LosePanel", false, "LearnResultPanel")
    self:setCtrlVisible("WinPanel", false, "LearnResultPanel")

    local panel = self:getControl("StagePanel", nil, "LearnResultPanel")
    local index = self.curStatus == STATUS.S1 and 1 or 2
    self:setImagePlist("Image_2", string.format("lingyzmword%04d.png", index), panel)

    if result == "succ" then
        self:setCtrlVisible("WinPanel", true, "LearnResultPanel")
        self:setCtrlVisible("ExitButton_1", true, "LearnResultPanel")
    else
        self:setCtrlVisible("LosePanel", true, "LearnResultPanel")
        self:setCtrlVisible("ExitButton", true, "LearnResultPanel")
        self:setCtrlVisible("ContinueButton", true, "LearnResultPanel")
    end

    self.studyResult = result
end

function LingyzmDlg:setGameOver()
    self.startGame = false

    self:cancelVoice()

    self:stopShakeBell()
end

-- 出否学习状态
function LingyzmDlg:isStudy()
    if self.curStatus == STATUS.S2 or self.curStatus == STATUS.S1 then
        return true
    end
end

function LingyzmDlg:onCloseButton()
    if self:isStudy() then
        LingyzmMgr:cmdLYZMStudyResult(self.studyResult, self.gameId)
    else
        gf:CmdToServer("CMD_HALLOWMAX_2018_LYZM_GAME_FINISH", {})
    end

    self.hasCmdFinish = true
end

function LingyzmDlg:onCheckVoice()
    SoundMgr:stopMusicAndSound()-- 停止音乐
end

function LingyzmDlg:cleanup()
    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    LingyzmMgr:setLingyzmGameOver()

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    self:cancelVoice()

    Me:setAct(Const.FA_STAND)

    if self.myInfo and self:isStudy() then
        Me:setLastMapPos(gf:convertToMapSpace(self.myInfo.pos.x, self.myInfo.pos.y))
        Me:setPos(self.myInfo.pos.x, self.myInfo.pos.y)
        Me:setDir(self.myInfo.dir)
    end

    Me:absorbBasicFields({
        notShowRidePet = 0,
        notShowHunfu = 0
    })

    Me:setSeepPrecentByClient(nil)

    -- 移除地图黑幕
    FightMgr:removeFightBg()

    -- 显示地表光效
    gf:getMapEffectLayer():setVisible(true)

    if not self.hasCmdFinish then
        if self:isStudy() then
            LingyzmMgr:cmdLYZMStudyResult(self.studyResult, self.gameId)
        else
            gf:CmdToServer("CMD_HALLOWMAX_2018_LYZM_GAME_FINISH", {})
        end
    end

    SoundMgr:replayMusicAndSound()

    EventDispatcher:removeEventListener('ENTER_FOREGROUND', self.onCheckVoice, self)
end 

return LingyzmDlg
