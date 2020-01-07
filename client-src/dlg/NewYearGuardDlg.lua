-- NewYearGuardDlg.lua
-- Created by huangzz Aug/21/2018
-- 宝物守卫战游戏界面

local NewYearGuardDlg = Singleton("NewYearGuardDlg", Dialog)

local TOTAL_TIME = 120

local DOWN_TIME = 3

local GAME_TIME = 120 -- 游戏时间

local ACT_SPEED_MULTIPLE = 3  -- 动作播放速度倍数

local PLAY_ATTACK_TIME = 550 -- 播放攻击动作间隔

local SUCCESS_POINT = 60
local CW_POINT = 100

function NewYearGuardDlg:init(param)
    self:setFullScreen()
    self:setCtrlFullClient("TouchPanel")
    self:setCtrlFullClientEx("BackPanel", "GuardRulePanel")
    self:setCtrlFullClientEx("BackPanel", "ResultPanel")

    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("QuitButton", self.onCloseButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("ReturnButton", self.onReturnButton)

    self:bindTouchPanel()

    self:createCountDown(DOWN_TIME, "NumPanel", "TimePanel")

    self.todayMaxPoint = 0
    self.succPoint = SUCCESS_POINT
    self.chengweiPoint = CW_POINT
    self.cookie = ""
    self.hasResult = false
    self.hasRequestExit = false
    self.downTime = -1

    self.isRulePause = false
    self.isConfirmPause = false

    self:setCtrlVisible("GuardRulePanel", true)
    self:setCtrlVisible("ResultPanel", false)

    FightMgr:addFightBgOnlyBlack()

    self:updateTime(NewYearGuardMgr:getTotalTime())
    self:updateScore(0)

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1})

    Me:setAct(Const.FA_STAND)
    Me:absorbBasicFields({
        notShowRidePet = 1,
        notShowHunfu = 1
    })

    self:hookMsg("MSG_ENTER_ROOM")
end

function NewYearGuardDlg:setDialogType()
    self.isSwallow = false
    self.isClose = false
    self.isBlankLayerHide = true
end

function NewYearGuardDlg:setData(data)
    self.todayMaxPoint = data.today_max_point or 0
    self.succPoint = data.succ_point or SUCCESS_POINT
    self.chengweiPoint = data.chengwei_point or CW_POINT
    self.cookie = data.cookie or ""
end

-- 绑定触摸事件,计算滑动屏幕方向
function NewYearGuardDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)
    panel:setTouchEnabled(false)

    self.lastAttackTime = 0
    local function onTouchBegan(touch, event)
        local touchPos = touch:getLocation()
        if not NewYearGuardMgr:gameIsPlaying() then
            return
        end

        local curTime = gfGetTickCount()
        if curTime - self.lastAttackTime < PLAY_ATTACK_TIME then
            return
        end

        local pos = gf:getCharMiddleLayer():convertToNodeSpace(touchPos)
        local dir = gf:defineDirForPet(cc.p(Me.curX, Me.curY), pos)

        if Me.faAct == Const.FA_ACTION_CAST_MAGIC then
            NewYearGuardMgr:attackMonsterByDir(Me:getDir())
            Me:setAct(Const.FA_STAND, true)
        end

        Me:setDir(dir)

        Me:setActAndCB(Const.FA_ACTION_CAST_MAGIC, function()
            if Me.faAct == Const.FA_ACTION_CAST_MAGIC then
                NewYearGuardMgr:attackMonsterByDir(dir)
                Me:setActAndCB(Const.FA_ACTION_CAST_MAGIC_END, function()
                     if Me.faAct ~= Const.FA_ACTION_CAST_MAGIC_END then
                        local kk = 5
                     end
                    Me:setAct(Const.FA_STAND, true)
                end)
            else
                Me:setAct(Const.FA_STAND, true)
            end
        end)

        self.lastAttackTime = curTime


        Me:setActSpeed(ACT_SPEED_MULTIPLE)

        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 创建倒计时
function NewYearGuardDlg:createCountDown(time)
    self:setCtrlVisible("TimePanel", false)
    local numImg = Dialog.createCountDown(self, time, "NumPanel", "TimePanel")
end

-- 设置开局倒计时数字
function NewYearGuardDlg:startCountDown(time)
    if time < 0 then
        return
    end

    NewYearGuardMgr:startCountDown()

    self:updateTime(NewYearGuardMgr:getTotalTime())
    self:updateScore(0)

    NewYearGuardMgr:createAllTreasure()
    NewYearGuardMgr:clearAllMonster()

    self.hasResult = false
    self.downTime = time

    if self.delayToStart then
        self.root:stopAction(self.delayToStart)
        self.delayToStart = nil
    end

    self:setCtrlVisible("TimePanel", true)
    self:setCtrlVisible("StartImage", false)
    local numImg = Dialog.startCountDown(self, time, "NumPanel", "TimePanel", function(numImg)
        numImg:setVisible(false)
        self:setCtrlVisible("StartImage", true)
        self.downTime = 0
        self.delayToStart = performWithDelay(self.root, function()
            -- 1s后隐藏开始
            self:setCtrlVisible("TimePanel", false)

            NewYearGuardMgr:startGame()

            self.downTime = -1
            self.delayToStart = nil
        end, 1)
    end)

    numImg:setVisible(true)
end

function NewYearGuardDlg:stopCountDown()
    if self.downTime < 0 then
        return
    end

    local numImg = Dialog.stopCountDown(self, "NumPanel", "TimePanel")
    self.downTime = numImg.num

    if self.delayToStart then
        self.root:stopAction(self.delayToStart)
        self.delayToStart = nil
    end
end

-- 显示游戏结果
function NewYearGuardDlg:showResult(point)
    self:setCtrlVisible("ResultPanel", true)
    self:setCtrlVisible("GuardRulePanel", false)
    self:setCtrlVisible("SuccessImage", false, "ResultPanel")
    self:setCtrlVisible("FailImage", false, "ResultPanel")
    self:setCtrlVisible("GoodNoticePanel", false, "ResultPanel")
    self:setCtrlVisible("NormalNoticePanel", false, "ResultPanel")
    self:setCtrlVisible("FailNoticePanel", false, "ResultPanel")

    self:setLabelText("ReqPointLabel2", self.succPoint, "ResultPanel")
    self:setLabelText("YourPointLabel2", point, "ResultPanel")

    self:cmdResult(point)

    self.hasResult = true
    self.isRulePause = false

    if point >= self.succPoint then
        self.todayMaxPoint = math.max(self.todayMaxPoint, point)
        self:setCtrlVisible("SuccessImage", true, "ResultPanel")
        if self.todayMaxPoint < self.chengweiPoint then
            self:setCtrlVisible("GoodNoticePanel", true, "ResultPanel")
            self:setLabelText("Label_1", string.format(CHS[5410275], self.todayMaxPoint), "GoodNoticePanel")
            self:setLabelText("Label_3", string.format(CHS[5410276], self.chengweiPoint), "GoodNoticePanel")
        else
            self:setCtrlVisible("NormalNoticePanel", true, "ResultPanel")
            self:setLabelText("Label_1", string.format(CHS[5410277], self.todayMaxPoint, self.chengweiPoint), "NormalNoticePanel")
        end
    else
        self:setCtrlVisible("FailImage", true, "ResultPanel")
        self:setCtrlVisible("FailNoticePanel", true, "ResultPanel")
    end
end

function NewYearGuardDlg:cmdResult(point)
    local str = gfEncrypt(tostring(point), self.cookie)
    gf:CmdToServer("CMD_BWSWZ_NOTIFY_RESULT_2019", {checksum = str})
end

-- 更新时间
function NewYearGuardDlg:updateTime(time)
    local m = math.floor(time / 60)
    local s = time % 60
    self:setLabelText("TimeLabel", string.format("%02d:%02d", m, s), "InfoPanel")
end

-- 更新分数
function NewYearGuardDlg:updateScore(point)
    self:setLabelText("PointLabel", point, "InfoPanel")
end

-- 继续游戏
function NewYearGuardDlg:onRestartButton(sender, eventType)
    self:setCtrlVisible("ResultPanel", false)
    self:startCountDown(DOWN_TIME)
end

-- 开始游戏
function NewYearGuardDlg:onStartButton(sender, eventType)
    self:setCtrlVisible("GuardRulePanel", false)
    self:startCountDown(DOWN_TIME)
end

-- 
function NewYearGuardDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("GuardRulePanel", true)
    self:setCtrlVisible("ReturnButton", true, "GuardRulePanel")
    self:setCtrlVisible("StartButton", false, "GuardRulePanel")
    self:stopCountDown()
    NewYearGuardMgr:setGamePause()

    self.isRulePause = true
end

-- 返回游戏
function NewYearGuardDlg:onReturnButton(sender, eventType)
    self:setCtrlVisible("GuardRulePanel", false)
    if not self.isConfirmPause then
        self:startCountDown(self.downTime)
        NewYearGuardMgr:setGameResume()
    end

    self.isRulePause = false
end

-- 退出游戏
function NewYearGuardDlg:onCloseButton(sender, eventType)
    local tip = CHS[5410271]
    if NewYearGuardMgr:gameIsStart() then
        tip = tip .. CHS[5410272]
    end

    self:stopCountDown()
    NewYearGuardMgr:setGamePause()

    self.isConfirmPause = true

    gf:confirm(tip, function()
        gf:CmdToServer("CMD_BWSWZ_LEAVE_GAME_2019", {})
        self.hasRequestExit = true
    end, function()
        if not self.isRulePause then
            self:startCountDown(self.downTime)
            NewYearGuardMgr:setGameResume()
        end

        self.isConfirmPause = false
    end)
end

function NewYearGuardDlg:MSG_ENTER_ROOM()
    DlgMgr:closeDlg("NewYearGuardDlg")
end

function NewYearGuardDlg:cleanup()
    if not self.hasRequestExit then
        gf:CmdToServer("CMD_BWSWZ_LEAVE_GAME_2019", {})
    end

    NewYearGuardMgr:endGame()

    Me:setAct(Const.FA_STAND)
    Me:absorbBasicFields({
        notShowRidePet = 0,
        notShowHunfu = 0
    })

    FightMgr:removeFightBg()

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil
end

return NewYearGuardDlg
