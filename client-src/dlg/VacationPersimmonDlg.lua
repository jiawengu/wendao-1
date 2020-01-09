-- VacationPersimmonDlg.lua
-- Created by lixh Nov/24 2017
-- 2018寒假冻柿子界面

local VacationPersimmonDlg = Singleton("VacationPersimmonDlg", Dialog)
local NumImg = require('ctrl/NumImg')

-- 屏幕中心点,此值会在init中被覆盖
local WIN_MID_X = 960 / 2
local WIN_MID_Y = 640 / 2

-- 柿子相对屏幕中心点的坐标
local PERSIMMON_POS = {
    {x = 40, y = 80},
    {x = -60, y = 28},
    {x = 140, y = 28},
    {x = 40, y = -24},
    {x = -60, y = -76},
    {x = 140, y = -76},
    {x = 40, y = -128},
}

-- 玩家倒计时相对屏幕中心偏移量
local COUNT_DOWN_ONE_POS = {x = 150, y = -40}
local COUNT_DOWN_TWO_POS = {x = -215, y = 150}

-- 结束操作按钮相对屏幕中心的偏移量
local FINISH_BUTTON_POS = {x = 240, y = -230}

-- 柿子数量
local PERSIMMON_COUNT = 7

-- 游戏开始倒计时时间
local MAX_COUNT_DOWN_TIME = 5

-- 吃按钮相对柿子向上的偏移量
local EAT_BUTTON_OFFSET = 70

-- 时钟水平方向偏移
local CLOCK_OFFSET_X = 4

-- 时钟相对于头顶基准点的偏移
local CLOCK_OFFESET_Y = 20

-- 每回合倒计时最大时间
local LEFT_TIME_MAX = 30

-- 进度条最大时间
local PROCESS_BAR_TIME_MAX = 1

function VacationPersimmonDlg:init()
    self:setFullScreen()
    local dlgSz = self.root:getContentSize()
    local panelList = self:getControl("PersimmonList")
    panelList:setContentSize(dlgSz)
    self.root:requestDoLayout()
    WIN_MID_X = dlgSz.width / 2
    WIN_MID_Y = dlgSz.height / 2

    self:setCtrlContentSize("BackPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100)
    self:setCtrlContentSize("BlackPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100, "ResultPanel_1")
    self:setCtrlContentSize("StarPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100, "MainPanel")

    self:bindListener("OutButton", self.onOutButton)
    self:bindListener("EatButton", self.onEatButton, "PersimmonList")
    self:bindListener("UpButton", self.onUpButton)
    self:bindListener("DownButton", self.onDownButton)
    self:bindListener("CloseImage", self.onOverButton, "GameResultPanel")
    self:bindListener("CloseImagePanel", self.onOverButton, "GameResultPanel")
    self:bindListener("ConfirmButton", self.onFinishButton)
    self:setCtrlVisible("ConfirmButton", false)
    

    self:setCtrlVisible("GameResultPanel", false)

    -- reorderChatDlg界面，让聊天可以点击
    -- 将自己的层级减低至ChatDlg一致
    local dlg = DlgMgr:getDlgByName("ChatDlg")
    self:setDlgZOrder(dlg:getDlgZOrder())
    DlgMgr:reorderDlgByName("ChatDlg")
    
    local finishButton = self:getControl("ConfirmButton")
    finishButton:setPosition(WIN_MID_X + FINISH_BUTTON_POS.x, WIN_MID_Y + FINISH_BUTTON_POS.y)
    
    self.eatButton = self:getControl("EatButton", nil, "PersimmonList")
    
    self.timePanel = self:getControl("TimePanel")
    self.timePanel:setVisible(false)
    
    -- 默认隐藏上方提示框
    self:setTipsByType(0)
    
    self.haveEaten = 0
    self.isRightOrder = nil
    self.isMyRound = nil
    self.selectPersimmon = nil
    self.startNumImg = nil
    self.roundCountDown = nil
    self.firstRound = nil
    self.startCountOver = nil
    
    -- 创建柿子模型，并隐藏，在收到回合开始的时候再显示
    local persimmonList = self:getControl("PersimmonList")
    self:setCtrlVisible("PersimmonList", false)
    self:creatPersimmon()
    
    self:hookMsg("MSG_DONGSZ_2018_ROUND")
    self:hookMsg("MSG_DONGSZ_2018_END")
    self:hookMsg("MSG_DONGSZ_2018_HIT")
    self:hookMsg("MSG_DONGSZ_2018_END_POS")
    self:hookMsg("MSG_DONGSZ_2018_SELECT")
    self:hookMsg("MSG_ENTER_ROOM")
end

-- 显示游戏上方小提示
function VacationPersimmonDlg:setTips(playerName)
    local str = string.format(CHS[7100100], playerName)
    self:setColorText(str, "TextPanel1", "RulePanel1", nil, nil, COLOR3.WHITE, 19, true)
    self:setColorText(CHS[7100101], "TextPanel2", "RulePanel1", nil, nil, COLOR3.WHITE, 17, true)
    self:setColorText(str, "TextPanel1", "RulePanel2", nil, nil, COLOR3.WHITE, 19, true)
end

-- 设置游戏上方小提示显示类型
-- type = 1 单行  type = 2 双行, 0 都隐藏
function VacationPersimmonDlg:setTipsByType(type)
    self:setCtrlVisible("RulePanel2", type == 1)
    self:setCtrlVisible("RulePanel1", type == 2)
end

function VacationPersimmonDlg:onOutButton(sender, eventType)
    if self.haveEaten and self.haveEaten > 0 then
        gf:confirmEx(CHS[7100114], CHS[7100110],function()
            -- 请求退出游戏，结算
            gf:CmdToServer("CMD_DONGSZ_2018_QUIT", {})
        end, CHS[7100103])
    else
        gf:confirmEx(CHS[7100115], CHS[7100110], function()
            -- 请求退出游戏，结算
            gf:CmdToServer("CMD_DONGSZ_2018_QUIT", {})
        end, CHS[7100103])
    end
end

function VacationPersimmonDlg:onOverButton(sender, eventType)
    -- 奖励请求结束游戏，请求退出场景
    gf:CmdToServer("CMD_DONGSZ_2018_REQUEST_END_POS", {})
end

function VacationPersimmonDlg:onEatButton(sender, eventType)
    if self.selectPersimmon then
        gf:CmdToServer("CMD_DONGSZ_2018_EAT", {gid = self.persimmonList[self.selectPersimmon].gid})
        sender:setVisible(false)
    end
end

function VacationPersimmonDlg:onUpButton(sender, eventType)
    self:setTipsByType(1)
end

function VacationPersimmonDlg:onDownButton(sender, eventType)
    self:setTipsByType(2)
end

function VacationPersimmonDlg:onFinishButton(sender, eventType)
    -- 请求结束当前回合
    gf:CmdToServer("CMD_DONGSZ_2018_DONE", {})
end

-- 创建倒计时
function VacationPersimmonDlg:createCountDown(panel)
    local timePanel = self:getControl("NumPanel", nil, panel)
    local numImge = nil
    if timePanel then
        local sz = timePanel:getContentSize()
        numImge = NumImg.new("bfight_num", 1, false, -5)
        numImge:setPosition(sz.width / 2, sz.height / 2)
        timePanel:addChild(numImge)
    end

    return numImge
end

-- 玩家开始倒计时
function VacationPersimmonDlg:playerCountDown(time)
    if not self.roundCountDown then
        self.roundCountDown = self:createCountDown(self.timePanel)
    end

    self.roundCountDown:setVisible(true)
    self.timePanel:setVisible(true)
    self.roundCountDown:setNum(time, false)
    self.roundCountDown:startCountDown(function()
        self.roundCountDown:setVisible(true)
    end)
end

-- 开始开局倒计时
function VacationPersimmonDlg:startCountDown(time)
    local starPanel = self:getControl("StarPanel")
    if not self.startNumImg then
        self.startNumImg = self:createCountDown(starPanel)
    end
    
    self:setCtrlVisible("StarImage", false, "StarPanel")
    self.startNumImg:setNum(time, false)
    self.startNumImg:setVisible(true)
    self:setCtrlVisible("StarPanel", true)
    self.startNumImg:startCountDown(function()
        -- 开局倒计时结束，显示开始，1s后隐藏
        self.startNumImg:setVisible(false)
        self:setCtrlVisible("StarImage", true, "StarPanel")
        performWithDelay(self.root, function()
            self:setCtrlVisible("StarPanel", false)
            self.startCountOver = true
            self:showDlgInfo(true)
        end, 1)
    end)
end

-- 创建柿子模型并添加到地图
function VacationPersimmonDlg:creatPersimmon()
    self.persimmon = self:retainCtrl("PersimmonImage", nil, "PersimmonList")
    local panel = self:getControl("PersimmonList")
    for i = 1, PERSIMMON_COUNT do
        local persimmon = self.persimmon:clone()
        local persimmonInCharLayer = self.persimmon:clone()
        panel:addChild(persimmon)
        persimmonInCharLayer:setVisible(true)
        persimmon:setTag(i)
        local x = WIN_MID_X + PERSIMMON_POS[i].x + 0
        local y = WIN_MID_Y + PERSIMMON_POS[i].y - 20
        local p = cc.p(x, y)
        persimmon:setPosition(p)
        local fullScreenPos = panel:convertToWorldSpace(p)
        local posInCharLayer = gf:getCharBottomLayer():convertToNodeSpace(fullScreenPos)
        persimmonInCharLayer:setPosition(posInCharLayer)
        gf:getCharBottomLayer():addChild(persimmonInCharLayer)
        persimmonInCharLayer:setTag(i)
        
        -- 隐藏界面上的柿子，玩家看到场景中的柿子
        persimmon:setOpacity(0)

        persimmon:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if not self.isMyRound then
                    -- 不是自己回合，点击给提示
                    gf:ShowSmallTips(CHS[7100109])
                    return
                end
                
                local posX, posY = sender:getPosition()
                self.eatButton:setPosition(cc.p(posX, posY + EAT_BUTTON_OFFSET))
                self.eatButton:setVisible(true)
                self.selectPersimmon = sender:getTag()
                self:addFocusMagicToPersimmon(self.selectPersimmon)
                gf:CmdToServer("CMD_DONGSZ_2018_SELECT", {gid = sender:getName()})
            end
        end)
    end
end

-- 柿子模型添加选中效果
function VacationPersimmonDlg:addFocusMagicToPersimmon(tag)
    for i = 1, PERSIMMON_COUNT do
        local persimmon = gf:getCharBottomLayer():getChildByTag(i)
        if i == tag then
            if persimmon:getChildByTag(ResMgr.magic.focus_target) then
                return
            end
            
            local magic = gf:createLoopMagic(ResMgr.magic.focus_target)
            local sz = persimmon:getContentSize()
            magic:setPosition(sz.width / 2, sz.height / 2)
            magic:setLocalZOrder(persimmon:getZOrder() - 1)
            persimmon:addChild(magic)
            magic:setTag(ResMgr.magic.focus_target)
        else
            persimmon:removeChildByTag(ResMgr.magic.focus_target)
        end
    end
end

-- 设置界面数据
function VacationPersimmonDlg:setData(data)
    self.playerOneInfo = data.playerOne
    self.playerTwoInfo = data.playerTwo
    
    -- 由于gf:getServerTime()延迟服务器时间1s，所以需要减1，策划要求倒计时结束后要显示开始图片1s，所以需要再减去1
    local leftTime = data.startTime - gf:getServerTime() - 1
    -- 游戏开始时间晚于当前服务器时间，需要倒计时
    if leftTime > 0 then
        self:startCountDown(leftTime)
    else
        self.startCountOver = true
    end

    self.isRightOrder = self.playerOneInfo.gid == Me:queryBasic("gid")
    self.firstRound = true

    -- 进入界面时隐藏已经打开的界面
    self.visibleDlg = {}
    for name, dlg in pairs(DlgMgr.dlgs) do
        if dlg and dlg:isVisible() and (dlg.name ~= self.name and dlg.name ~= "ChatDlg" and dlg.name ~= "LoadingDlg") then
            table.insert(self.visibleDlg, name)
            dlg:setVisible(false)
        end
    end
end

-- 设置场景内角色喊话
function VacationPersimmonDlg:setStringOnHead(data)
    local chatPlayer
    if data.gid == self.playerOneInfo.gid then
        chatPlayer = CharMgr:getChar(self.playerOneInfo.id)
    elseif data.gid == self.playerTwoInfo.gid then
        chatPlayer = CharMgr:getChar(self.playerTwoInfo.id)
    end
    
    if not chatPlayer then
        return
    end
    
    local gender = 0
    local members = TeamMgr.members
    for k, v in ipairs(members) do
        if v.gid == chatPlayer:queryBasic("gid") then
            gender = v.gender
        end
    end
    
    if chatPlayer then
        local tempData = gf:deepCopy(data)
        tempData.id = chatPlayer:getId()
        tempData.msg = BrowMgr:addGenderSign(tempData.msg, gender)
        ChatMgr:MSG_MESSAGE(tempData)
        return true
    end
    
    return false
end

-- 2018 冻柿子 回合数据更新
function VacationPersimmonDlg:MSG_DONGSZ_2018_ROUND(data)
    if not data or data.eatPlayerGid and data.eatPlayerGid == "" then
        -- 当前回合吃柿子的玩家id为空，表示已经有玩家吃到涩柿子，游戏结束
        return
    end
    
    -- 回合切换，隐藏吃柿子按钮，清空选中光效
    self.eatButton:setVisible(false)
    self:addFocusMagicToPersimmon()
    
    self.persimmonCount = data.persimmonCount
    self.persimmonList = data.persimmon
    
    -- 回合标记
    self.isMyRound = data.eatPlayerGid == Me:queryBasic("gid")
    
    -- 结束操作按钮，闹钟表现
    if self.isMyRound then
        self:setCtrlVisible("ConfirmButton", true)
    else
        self:setCtrlVisible("ConfirmButton", false)
    end
    
    self:doCharHeadEffect(data.eatPlayerGid)
    
    -- 当前回合已结束， gf:getServerTime()延迟服务器时间1s
    local leftTime = data.rountEndTime - (gf:getServerTime() + 1)
    if leftTime <= 0 then
        -- 已方回合已结束，直接更新柿子状态
        self:updatePersimmonStatus()
        return
    end
    
    -- 更新柿子状态，播放进度条
    self:updatePersimmonStatus()
    
    leftTime = math.min(leftTime, LEFT_TIME_MAX)
    
    -- 更新倒计时
    self:playerCountDown(leftTime)
    
    -- 更新游戏上方提示
    if self.playerOneInfo.gid == data.eatPlayerGid then
        self:setTips(self.playerOneInfo.name)
    else
        self:setTips(self.playerTwoInfo.name)
    end
    
    -- 显示柿子与提示
    if self.firstRound then
        self:setTipsByType(2)
        self.firstRound = false
    end
    
    if self.startCountOver then
        self:showDlgInfo(true)
    else
        self:showDlgInfo(false)
    end
end

-- 开始倒计时还未结束界面信息特殊处理
function VacationPersimmonDlg:showDlgInfo(flag)
    self:setCtrlVisible("PersimmonList", flag)
    self:setTipsByType(flag and 2 or 0)
    self.timePanel:setVisible(flag)
    
    if self.roundCountDown then
        self.roundCountDown:setVisible(flag)
    end
end

-- 更新柿子状态,播放进度条
function VacationPersimmonDlg:updatePersimmonStatus()
    -- 需要将柿子数据逆序
    if not self.isRightOrder then
        for i = 1, self.persimmonCount / 2 do
            local tmpData = self.persimmonList[i]
            self.persimmonList[i] = self.persimmonList[self.persimmonCount - i + 1]
            self.persimmonList[self.persimmonCount - i + 1] = tmpData
        end
    end
    
    self.haveEaten = 0
    local persimmonPanel = self:getControl("PersimmonList")
    for i = 1, self.persimmonCount do
        local perData = self.persimmonList[i]
        local persimmon = persimmonPanel:getChildByTag(i)
        persimmon:setName(perData.gid)

        if perData.status == 1 then
            -- 正在品尝 进度条， gf:getServerTime()延迟服务器时间1s
            local leftTime = perData.endEatTime - gf:getServerTime()
            if leftTime <= 0 then
                return
            end

            leftTime = math.min(leftTime, PROCESS_BAR_TIME_MAX)
            local str = self.isMyRound and CHS[7100112] or CHS[7100113]
            local barData = {icon = ResMgr.ui.hand_gather, word = str, start_time = gf:getServerTime(), end_time = perData.endEatTime}
            local dlg = DlgMgr:openDlg("UseBarDlg")
            dlg:setInfo(barData)
        elseif perData.status == 2 then
            -- 已品尝
            self:removePersimmon(i)
            self.haveEaten = self.haveEaten + 1
        end
    end
end

-- 隐藏index柿子
function VacationPersimmonDlg:removePersimmon(index)
    local persimmon = gf:getCharBottomLayer():getChildByTag(index)
    persimmon:setVisible(false)
    
    local panel = self:getControl("PersimmonList")
    local panelPersimmon = panel:getChildByTag(index)
    panelPersimmon:setVisible(false)
end

-- 清除地图上柿子模型
function VacationPersimmonDlg:cleanup()
    self:cleanMapPersimmon()

    Me.canShiftFlag = true
    Me:setFixedView(false)
    
    CharMgr:deleteChar(self.playerOneInfo.id)
    CharMgr:deleteChar(self.playerTwoInfo.id)
    
    -- 退出界面时显示已经打开的界面
    local visibleDlg = self.visibleDlg
    for i = 1, #visibleDlg do
        local dlg = DlgMgr.dlgs[visibleDlg[i]]
        if dlg then
            dlg:setVisible(true)
        end
    end
end

-- 清除地图上的柿子模型
function VacationPersimmonDlg:cleanMapPersimmon()
    for i = 1, PERSIMMON_COUNT do
        local persimmon = gf:getCharBottomLayer():getChildByTag(i)
        if persimmon then
            persimmon:removeFromParent()
        end
    end
end

-- 游戏结束的需要处理（吃到涩柿子、收到游戏结束消息、收到退出场景消息）
function VacationPersimmonDlg:doWithGameOver()
    -- 隐藏模型、提示
    self:showDlgInfo(false)
    
    -- 停止倒计时
    if self.roundCountDown then
        self.roundCountDown:stopCountDown()
        self.timePanel:setVisible(false)
    end

    -- 尝试关闭确认框
    DlgMgr:closeDlg("ConfirmDlg")
end

-- 人物头顶增加闹钟动画
function VacationPersimmonDlg:addHeadEffect(char)
    if char and char.charAction then
        if char.readyToFight then
            return
        end
        
        local headX, headY = char.charAction:getHeadOffset()
        char.readyToFight = gf:createLoopMagic(ResMgr.magic.ready_to_fight)
        char.readyToFight:setAnchorPoint(0.5, 0.5)
        char.readyToFight:setLocalZOrder(Const.CHARACTION_ZORDER)
        if char:queryBasic('gid') == Me:queryBasic('gid') then
            char.readyToFight:setPosition(CLOCK_OFFSET_X, headY + CLOCK_OFFESET_Y)
        else
            char.readyToFight:setPosition(-CLOCK_OFFSET_X, headY + CLOCK_OFFESET_Y)
        end
        
        char:addToMiddleLayer(char.readyToFight)
    end
end

-- 人物头顶移除闹钟动画
function VacationPersimmonDlg:removeHeadEffect(char)
    if char.readyToFight then
        char.readyToFight:removeFromParent()
        char.readyToFight = nil
    end
end

-- 人物头顶增加闹钟动画
function VacationPersimmonDlg:doCharHeadEffect(gid)
    local addPlayer = gid == self.playerOneInfo.gid and CharMgr:getChar(self.playerOneInfo.id) or CharMgr:getChar(self.playerTwoInfo.id)
    local removePlayer = gid == self.playerOneInfo.gid and CharMgr:getChar(self.playerTwoInfo.id) or CharMgr:getChar(self.playerOneInfo.id)
    self:addHeadEffect(addPlayer)
    self:removeHeadEffect(removePlayer)
end

-- 2018 冻柿子 通知吃到涩柿子
function VacationPersimmonDlg:MSG_DONGSZ_2018_HIT(data)
    local diedPlayer
    if data.failPlayerGid == self.playerOneInfo.gid then
        diedPlayer = CharMgr:getChar(self.playerOneInfo.id)
    else
        diedPlayer = CharMgr:getChar(self.playerTwoInfo.id)
    end

    self:doWithGameOver()
    diedPlayer.charAction:setLoopTimes(1)
    diedPlayer.charAction:setAction(Const.SA_DIE)
end

-- 2018 冻柿子 通知客户端游戏结束
function VacationPersimmonDlg:MSG_DONGSZ_2018_END(data)
    self:doWithGameOver()
    self:cleanMapPersimmon()
    
    self:setCtrlVisible("PersimmonList", false)
    self:setCtrlVisible("GameResultPanel", true)
    if data.gameResult == 1 then
        -- 胜利
        self:setCtrlVisible("Image_3_1", true, "GameResultPanel")
        self:setCtrlVisible("Image_3_2", false, "GameResultPanel")
    else
        self:setCtrlVisible("Image_3_1", false, "GameResultPanel")
        self:setCtrlVisible("Image_3_2", true, "GameResultPanel")
    end
    
    if data.reward > 0 then
        self:setCtrlVisible("TaoPanel1", true)
        self:setCtrlVisible("TaoPanel2", false)
        if data.rewardType == 1 then
            -- 道行
            self:setLabelText("NumLabel", string.format(CHS[7100116], gf:getTaoStr(data.reward, 0)), "TaoPanel1")
            self:setImagePlist("RewardImage", ResMgr.ui.small_daohang, "TaoPanel1")
        else
            -- 经验
            self:setLabelText("NumLabel", data.reward, "TaoPanel1")
            self:setImagePlist("RewardImage", ResMgr.ui.small_exp, "TaoPanel1")
        end
    else
        self:setCtrlVisible("TaoPanel1", false)
        self:setCtrlVisible("TaoPanel2", true)
        if data.rewardType == 1 then
            -- 道行
            self:setImagePlist("RewardImage", ResMgr.ui.small_daohang, "TaoPanel2")
        else
            -- 经验
            self:setImagePlist("RewardImage", ResMgr.ui.small_exp, "TaoPanel2")
        end
    end
end

-- 2018 冻柿子 通知当前地图位置
function VacationPersimmonDlg:MSG_DONGSZ_2018_END_POS(data)
    self:doWithGameOver()
    self:cleanMapPersimmon()
    self:onCloseButton()

    CharMgr:doCharHideStatus(Me)
end

-- 2018 通知客户端当前选中柿子
function VacationPersimmonDlg:MSG_DONGSZ_2018_SELECT(data)
    local panel = self:getControl("PersimmonList")
    for i = 1, PERSIMMON_COUNT do
        local persimmon = panel:getChildByTag(i)
        if persimmon:getName() == data.gid then
            self:addFocusMagicToPersimmon(i)
        end
    end
end

function VacationPersimmonDlg:MSG_ENTER_ROOM()
    self:doWithGameOver()
    self:cleanMapPersimmon()
    self:onCloseButton()
    if self.playerOneInfo then
        CharMgr:deleteChar(self.playerOneInfo.id)
    end
    
    if self.playerTwoInfo then
        CharMgr:deleteChar(self.playerTwoInfo.id)
    end

    CharMgr:doCharHideStatus(Me)
    
    -- 退出界面时显示已经打开的界面
    local visibleDlg = self.visibleDlg
    for i = 1, #visibleDlg do
        local dlg = DlgMgr.dlgs[visibleDlg[i]]
        if dlg then
            dlg:setVisible(true)
        end
    end
end

return VacationPersimmonDlg
