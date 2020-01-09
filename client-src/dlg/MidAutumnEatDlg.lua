-- MidAutumnEatDlg.lua
-- Created by lixh Jun/10/2018
-- 2018 中秋大胃王

local MidAutumnEatDlg = Singleton("MidAutumnEatDlg", Dialog)
local NumImg = require('ctrl/NumImg')
local CharActionNoLoop = require('animate/CharActionNoLoop')

-- 游戏状态
local GAME_STATUS = {
    RULE = 1,           -- 规则显示
    CHOOSE_NPC = 2,     -- 选择出战npc
    GAMING = 3,         -- 游戏进行中
    RESULT = 4,         -- 展示结果
}

-- npc配置 mhOffsetX, mhOffsetY 冒汗偏移配置
local NPC_CHOOSE_CFG = {
    {icon = 06018, name = CHS[7190306], mhOffsetX3 = 10, mhOffsetY3 = -40, mhOffsetX7 =   5, mhOffsetY7 = -30},  -- 调皮孩子王
    {icon = 06019, name = CHS[7190307], mhOffsetX3 =  6, mhOffsetY3 = -31, mhOffsetX7 =  -2, mhOffsetY7 = -27},  -- 安静小美人
    {icon = 06033, name = CHS[7190308], mhOffsetX3 =  5, mhOffsetY3 = -40, mhOffsetX7 =  -7, mhOffsetY7 = -30},  -- 人狠话不多
    {icon = 06035, name = CHS[7190309], mhOffsetX3 = 15, mhOffsetY3 = -30, mhOffsetX7 = -20, mhOffsetY7 = -38},  -- 硬朗董老头
    {icon = 06240, name = CHS[7190310], mhOffsetX3 = 13, mhOffsetY3 = -30, mhOffsetX7 = -13, mhOffsetY7 = -45},  -- 无名青年
}

-- 单次上传分数数据最大值
local PER_UP_MAX_SCORE = 9

-- 冯喜来id
local FXL_ID = 1100

-- 客栈地图 npc 配置
local DWW_NPC_CFG = {
    {name = "", icon = 06001, x = 22, y = 46, id = 100,  dir = 3},
    {name = "", icon = 06002, x = 25, y = 46, id = 200,  dir = 3},
    {name = "", icon = 06003, x = 26, y = 50, id = 300,  dir = 3},
    {name = "", icon = 06004, x = 29, y = 48, id = 400,  dir = 2},
    {name = "", icon = 06005, x = 34, y = 48, id = 500,  dir = 1},
    {name = "", icon = 07001, x = 37, y = 50, id = 600,  dir = 1},
    {name = "", icon = 07002, x = 38, y = 46, id = 700,  dir = 1},
    {name = "", icon = 07003, x = 42, y = 48, id = 800,  dir = 1},
    {name = "", icon = 07004, x = 39, y = 43, id = 900,  dir = 8},
    {name = "", icon = 07005, x = 41, y = 41, id = 1000, dir = 8},
    {name = CHS[7190311], icon = 06016, x = 26, y = 42, id = FXL_ID, dir = 5}, -- 冯喜来
}

-- npc函数
local DWW_NPC_PROPAGANDA = {
    CHS[7190315],
    CHS[7190316],
    CHS[7190317],
    CHS[7190318],
    CHS[7190319],
    CHS[7190320],
}

-- 结果展示时的喊话
local RESULT_PROPAGANDA = {
    CHS[7100376],
    CHS[7100377],
    CHS[7100378],
    CHS[7100379],
    CHS[7100380],
    CHS[7100381],
    CHS[7100382],
    CHS[7100383],
    CHS[7100384],
}

-- 游戏倒计时
local COUNT_DOWN = {START = 3, GAMING = 20}

-- 计分时间间隔
local SOCRE_SCHEDULE_TIMESTAMP = 0.5

-- 比赛玩家
local PLAYER_CFG = {
    {id = 2000, x = 30, y = 42, xx = 728, yy = 500, dir = 3},
    {id = 3000, x = 35, y = 40, xx = 840, yy = 545, dir = 7},
}

-- 桌子上的菜肴位置
local FOOD_POS = {X = 780, Y = 552}

-- 刷新最后一道菜的百分比
local FINAL_SCORE_PERCENT = 97

-- 比赛结果展示延迟时间
local RESULT_DELAY_TIME = 4

function MidAutumnEatDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKBlackPanelGP", "RulePanel")
    self:setCtrlFullClientEx("BKBlackPanelGP", "ChoicePanel")
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:bindListener("EatButton_1", self.onEatButton)
    self:bindListener("EatButton_2", self.onEatButton)
    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("QuitButton", self.onQuitButton)

    self:setDlgByStatus()
    self:bornMapNpc()

    self:setOtherDlgVisible(false)

    self.score = 0
    self.scoreTable = {}
    self.dragonBonus = {}

    self:hookMsg("MSG_AUTUMN_2018_DWW_PREPARE")
    self:hookMsg("MSG_AUTUMN_2018_DWW_START")
    self:hookMsg("MSG_AUTUMN_2018_DWW_PROGRESS")
    self:hookMsg("MSG_AUTUMN_2018_DWW_RESULT")
    self:hookMsg("MSG_ENTER_ROOM")
end

-- 设置其他界面的显示与隐藏
function MidAutumnEatDlg:setOtherDlgVisible(flag)
    if not flag then
        self.visibleDlg = {}
        for name, dlg in pairs(DlgMgr.dlgs) do
            if dlg and dlg:isVisible() and (name ~= self.name and name ~= "LoadingDlg") then
                table.insert(self.visibleDlg, name)
                dlg:setVisible(false)
            end
        end
    else
        for i = 1, #self.visibleDlg do
            if DlgMgr.dlgs[self.visibleDlg[i]] then
                DlgMgr.dlgs[self.visibleDlg[i]]:setVisible(true)
            end
        end
    end
end

-- 切换游戏阶段显示
function MidAutumnEatDlg:setDlgByStatus(status)
    self:setCtrlVisible("RulePanel", false)
    self:setCtrlVisible("ChoicePanel", false)
    self:setCtrlVisible("GamingPanel", false)
    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("EatButton_1", false)
    self:setCtrlVisible("EatButton_2", false)
    if status == GAME_STATUS.RULE then
        self:setCtrlVisible("RulePanel", true)

        -- 初始化进度
        self:refreshBarprogress(self.score)
    elseif status == GAME_STATUS.CHOOSE_NPC then
        self:setCtrlVisible("ChoicePanel", true)

        -- 初始化选择npc
        self:initChooseNpc()
    elseif status == GAME_STATUS.GAMING then
        self:setCtrlVisible("GamingPanel", true)
        self:setCtrlVisible("EatButton_1", true)
        self:setCtrlVisible("EatButton_2", true)

        -- 开始游戏
        self:startGame()
    elseif status == GAME_STATUS.RESULT then
        if self.resultData and self.resultData.result == 1 then
            -- 结果为成功时需要延迟展示，策划需要做一些效果:烟花、喊话
            performWithDelay(self.root, function()
                self:setCtrlVisible("ResultPanel", true)
                self:cleanGameOver()
                self:showResult()
            end, RESULT_DELAY_TIME)

            self:doResultPerformance()
        else
            self:setCtrlVisible("ResultPanel", true)
            self:cleanGameOver()
            self:showResult()
        end
    end
end

-- 生成地图上npc
function MidAutumnEatDlg:bornMapNpc()
    for i = 1, #DWW_NPC_CFG do
        local cfg = DWW_NPC_CFG[i]
        CharMgr:MSG_APPEAR({x = cfg.x, y = cfg.y, dir = cfg.dir, id = cfg.id, icon = cfg.icon,
            type = OBJECT_TYPE.NPC, name = cfg.name, opacity = 0,
            light_effect_count = 0, isNowLoad = true})

        InnMgr.dwwShowChar[cfg.id] = true
    end
end

-- 析构地图上npc
function MidAutumnEatDlg:releaseMapNpc()
    for i = 1, #DWW_NPC_CFG do
        local cfg = DWW_NPC_CFG[i]
        CharMgr:deleteChar(cfg.id)
    end
end

-- 选择npc时播放或停止npc龙骨动画
function MidAutumnEatDlg:refreshNpcDragonBones(index, type)
    local panel = self:getControl("DragonPanel", Const.UIPanel, "PersonPanel_" .. index)
    if not panel then return end
    local magic = panel:getChildByName("charPortrait")
    if not magic or not self.dragonBonus[index] then return end
    if type == "play" then
        if not self.isPlayingDragonIndex or self.isPlayingDragonIndex ~= index then
            -- 未被选择时，才需要重新播放
            DragonBonesMgr:toPlay(self.dragonBonus[index], "stand", 0)
            self.isPlayingDragonIndex = index
        end
    else
        DragonBonesMgr:stop(self.dragonBonus[index], "stand")
    end
end

-- 初始化选择npc
function MidAutumnEatDlg:initChooseNpc()
    local function onChooseNpc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if not self.canChooseNpc then return end
            for i = 1, #NPC_CHOOSE_CFG do
                if i == sender.index then
                    self:setCtrlVisible("ChoosePanel", true, "PersonPanel_" .. i)
                    self:refreshNpcDragonBones(i, "play")
                else
                    self:setCtrlVisible("ChoosePanel", false, "PersonPanel_" .. i)
                    self:refreshNpcDragonBones(i, "stop")
                end
            end
        end
    end

    local function onFightNpc(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local parent = sender:getParent()
            sender:setVisible(false)
            parent:getChildByName("ReadyLabel"):setVisible(true)
            gf:CmdToServer("CMD_AUTUMN_2018_DWW_SELECT_ICON", {index = sender.index})

            -- 已选npc，不能切换了
            self.canChooseNpc = false
        end
    end

    -- 创建npc对象前，先释放旧资源
    self:releaseCharDragonBones()

    -- 清空选择npc标记，正在播放龙骨动画对象标记
    self.canChooseNpc = true
    self.isPlayingDragonIndex = nil

    local root = self:getControl("ChoicePanel")
    for i = 1, #NPC_CHOOSE_CFG do
        local panel = self:getControl("PersonPanel_" .. i, Const.UIPanel, root)
        panel.index = i
        panel:addTouchEventListener(onChooseNpc)

        -- 龙骨动画
        self:creatCharDragonBones(NPC_CHOOSE_CFG[i].icon, self:getControl("DragonPanel", Const.UIPanel, panel))

        -- 头像
        self:setCtrlVisible("IconImage", false, "PersonPanel_" .. i)

        -- 出战信息
        local startButton = self:getControl("StartButton", Const.UIButton, panel)
        startButton:setVisible(true)
        startButton.index = i
        startButton:addTouchEventListener(onFightNpc)
        self:setCtrlVisible("ReadyLabel", false, panel)

        if i == 1 then
            -- 默认选择第1个npc
            onChooseNpc(panel, ccui.TouchEventType.ended)
        end
    end
end

-- 创建人物龙骨动画
function MidAutumnEatDlg:creatCharDragonBones(icon, panel)
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, 0)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)

    table.insert(self.dragonBonus, dbMagic)
end

-- 释放人物龙骨动画
function MidAutumnEatDlg:releaseCharDragonBones()
    for i = 1, #NPC_CHOOSE_CFG do
        local panel = self:getControl("DragonPanel", Const.UIPanel, "PersonPanel_" .. i)
        local magic = panel:getChildByName("charPortrait")

        if magic then
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end

        panel:removeAllChildren()
    end

    self.dragonBonus = {}
end

-- 设置开始游戏后的喊话
function MidAutumnEatDlg:setStartGamePropaganda()
    -- 冯喜来喊话
    self:setPropaganda(FXL_ID, CHS[7190314], 1)

    -- 延迟1s随机两个npc函数
    performWithDelay(self.root, function()
        -- 减1，因为最后一个npc是冯喜来
        local maxStep = #DWW_NPC_CFG - 1

        local npcOneIndex = math.random(1, maxStep)
        local npcTwoIndex = maxStep - npcOneIndex + 1

        local textNum = #DWW_NPC_PROPAGANDA
        self:setPropaganda(DWW_NPC_CFG[npcOneIndex].id, DWW_NPC_PROPAGANDA[math.random(1, textNum)])
        self:setPropaganda(DWW_NPC_CFG[npcTwoIndex].id, DWW_NPC_PROPAGANDA[math.random(1, textNum)])

        -- 冯喜来再次喊话
        local playerOneName = self.startData.playerOneName
        local playerTwoName = self.startData.playerTwoName
        local playerOneNpcName = NPC_CHOOSE_CFG[self.startData.playerOneIndex].name
        local playerTwoNpcName = NPC_CHOOSE_CFG[self.startData.playerTwoIndex].name
        local text = string.format(CHS[7190324], playerOneName, playerOneNpcName, playerTwoName, playerTwoNpcName)
        self:setPropaganda(FXL_ID, text, 1)
    end, 1)

    -- 延迟2s冯喜来再喊话
    performWithDelay(self.root, function()
        self:setPropaganda(FXL_ID, CHS[7190321])
    end, 2)
end

-- 进入游戏阶段
function MidAutumnEatDlg:startGame()
    -- 清空分数
    self.socre = 0

    -- 按钮不可点击
    self:setCtrlEnabled("EatButton_1", false)
    self:setCtrlEnabled("EatButton_2", false)

    -- 设置开始游戏后的喊话
    self:setStartGamePropaganda()

    -- 开始游戏倒计时
    local root = self:getControl("GamingPanel")
    self:setCtrlVisible("StartImage", false, root)
    local timePanel = self:getControl("TimePanel", Const.UIPanel, root)
    timePanel:setVisible(true)

    local numImage = self:createCountDown(timePanel)
    numImage:setNum(COUNT_DOWN.START, false)
    numImage:startCountDown(function()
        self:setCtrlVisible("StartImage", true, root)
        numImage:setVisible(false)

        performWithDelay(self.root, function()
            -- 开始显示完后，延迟1s，进入正式开始游戏状态，开始游戏倒计时
            self:setCtrlVisible("StartImage", false, root)

            -- 开始游戏计分定时器
            self:startScoreSchedule()

            -- 开启按钮点击事件
            self:setCtrlEnabled("EatButton_1", true)
            self:setCtrlEnabled("EatButton_2", true)

            numImage:setVisible(true)
            numImage:setNum(COUNT_DOWN.GAMING, false)
            numImage:startCountDown(function()
                -- 游戏结束
                self:setCtrlVisible("TimePanel", false, root)
            end)
        end, 1)
    end)
end

-- 计算百分比
function MidAutumnEatDlg:getPercent(score, maxScore)
    local percent = score * 100.0 / maxScore
    percent = math.min(math.floor(percent), 100)
    return percent
end

-- 创建倒计时
function MidAutumnEatDlg:createCountDown(panel)
    local timePanel = self:getControl("NumPanel", nil, panel)
    local numImage = timePanel:getChildByName("NumImg")
    if not numImage then
        local sz = timePanel:getContentSize()
        numImage = NumImg.new("bfight_num", 1, false, -5)
        numImage:setPosition(sz.width / 2, sz.height / 2)
        numImage:setName("NumImg")
        timePanel:addChild(numImage)
    end

    return numImage
end

-- 开启计分定时器
function MidAutumnEatDlg:startScoreSchedule()
    -- 先停止定时器
    self:stopScoreSchedule()

    local times = COUNT_DOWN.GAMING / SOCRE_SCHEDULE_TIMESTAMP
    local tick = 0
    self.scoreSchedule = self:startSchedule(function()
        tick = tick + 1
        if tick <= times then
            local desStr = gfEncrypt(string.format("%d #@#@# %d", tick,
                math.min(PER_UP_MAX_SCORE, self.socre)), tostring(Me:getId()))

            gf:CmdToServer("CMD_AUTUMN_2018_DWW_PROGRESS", {text = desStr})

            -- 总的点击次数由服务器统计并验证，客户端0.5s统计完就清空
            self.socre = 0
        else
            self:stopScoreSchedule()
        end
    end, SOCRE_SCHEDULE_TIMESTAMP)
end

-- 停止计分定时器
function MidAutumnEatDlg:stopScoreSchedule()
    if self.scoreSchedule then
        self:stopSchedule(self.scoreSchedule)
        self.scoreSchedule = nil
    end
end

-- 刷新计分进度条
function MidAutumnEatDlg:refreshBarprogress(curScore)
    local cfgData = self.prepareData
    if not cfgData then return end

    -- 设置进度
    local barprogress = self:getControl("ExpProgressBar", nil, "GamingPanel")
    local percent = self:getPercent(curScore, cfgData.maxScore)
    barprogress:setPercent(percent)

    -- 设置数字图片进度
    local nowPanel = self:getControl("Now%Panel", nil, "GamingPanel")
    local numImg = nowPanel:getChildByName("NumImg")
    if not numImg then
        numImg = NumImg.new('sfight_num', percent, false, -2)
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setName("NumImg")
        local sz = nowPanel:getContentSize()
        numImg:setPosition(sz.width / 2, sz.height / 2)
        nowPanel:addChild(numImg)
    end

    local newNum = percent .. "%"
    if numImg.num and numImg.num ~= newNum then
        numImg:setNumByString(newNum, true)
        numImg:stopAllActions()
        numImg:setScale(1.7)
        numImg:runAction(cc.ScaleTo:create(0.1, 1))
    end

    -- 设置目标是否达成
    self:setCtrlVisible("YesImage_1", curScore >= cfgData.successScore, "60%Panel")
    self:setCtrlVisible("YesImage_2", curScore >= cfgData.maxScore, "100%Panel")

    if not self.firstSuccessFlag and curScore >= cfgData.successScore then
        -- 首次达成及格分，冯喜来喊话
        self.firstSuccessFlag = true
        self:setPropaganda(FXL_ID, CHS[7190323])
    end

    if not self.firstLimitFlag and curScore * 2 >= cfgData.maxScore then
        -- 首次达成最大分的一半，冯喜来喊话
        self.firstLimitFlag = true
        self:setPropaganda(FXL_ID, CHS[7190322])
    end

    -- 刷新桌子上的食物图片
    self:refreshTableFood(curScore)
end

-- 显示结果
function MidAutumnEatDlg:showResult()
    local resultData = self.resultData
    if not resultData then return end

    local root = self:getControl("ResultPanel")

    -- 成功失败
    local isWin = resultData.result == 1
    self:setCtrlVisible("SuccessImage", isWin, root)
    self:setCtrlVisible("FailImage", not isWin, root)
    self:setCtrlVisible("NoticeLabel", isWin, root)

    -- 总分
    local sumPanel = self:getControl("SumPanel", Const.UIPanel, root)
    local percent = self:getPercent(resultData.resultOne + resultData.resultTwo, self.prepareData.maxScore)
    self:setLabelText("NumLabel", percent .. "%", sumPanel)

    -- 队员1得分
    local playerOnePanel = self:getControl("PlayerOnePanel", Const.UIPanel, root)
    local percentOne = self:getPercent(resultData.resultOne, self.prepareData.maxScore)
    self:setLabelText("NumLabel", percentOne .. "%", playerOnePanel)
    self:setLabelText("PlayerOneNameLabel", self.startData.playerOneName, playerOnePanel)

    -- 队员2得分
    local playerTwoPanel = self:getControl("PlayerTwoPanel", Const.UIPanel, root)
    local percentTwo = math.max(0, percent - percentOne)
    self:setLabelText("NumLabel", percentTwo .. "%", playerTwoPanel)
    self:setLabelText("PlayerTwoNameLabel", self.startData.playerTwoName, playerTwoPanel)
end

-- 比赛结束后，清除一些资源
function MidAutumnEatDlg:cleanGameOver()
    -- -- 清除比赛玩家模型
    CharMgr:deleteChar(PLAYER_CFG[1].id)
    CharMgr:deleteChar(PLAYER_CFG[2].id)

    -- 清空进度条
    self:refreshBarprogress(0)

    -- 首次成就，喊话标记
    self.firstSuccessFlag = false
    self.firstLimitFlag = false

    -- 重置选择npc标记
    self.canChooseNpc = true
end

function MidAutumnEatDlg:cleanup()
    DlgMgr:closeDlg("ConfirmDlg")
    self:cleanGameOver()
    self.startData = nil
    self.score = 0
    self.resultData = nil
    self.scoreTable ={}
    self.prepareData = nil
    self:releaseMapNpc()
    self:releaseCharDragonBones()

    self:setOtherDlgVisible(true)
end

function MidAutumnEatDlg:onEatButton(sender, eventType)
    self.socre = self.socre + 1

    sender:stopAllActions()
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.midautumn_eat_btn.name,
        ResMgr.ArmatureMagic.midautumn_eat_btn.action, sender)
end

-- 再次挑战
function MidAutumnEatDlg:onRestartButton(sender, eventType)
    gf:CmdToServer("CMD_AUTUMN_2018_DWW_AGAIN", {})
    self:onContinueButton()
end

-- 退出游戏
function MidAutumnEatDlg:onQuitButton(sender, eventType)
    self:onCloseButton(sender,eventType)
end

function MidAutumnEatDlg:onCloseButton(sender, eventType)
    gf:confirm(CHS[7190313], function()
        if DlgMgr.dlgs[self.name] then
            gf:CmdToServer("CMD_AUTUMN_2018_DWW_QUIT", {})
            Dialog.close(self)
        end
    end)
end

-- npc选择阶段
function MidAutumnEatDlg:onContinueButton(sender, eventType)
    self:setDlgByStatus(GAME_STATUS.CHOOSE_NPC)
end

-- 喊话, 喊话时间默认为3秒，只在头顶喊话
function MidAutumnEatDlg:setPropaganda(id, str, showTime)
    local char = CharMgr:getCharById(id)
    if not char then return end

    char:setChat({
        compress = 0,
        orgLength = string.len(str),
        id = char:getId(),
        gid = 0,
        icon = char:queryBasicInt("icon"),
        name = char:getName(),
        msg = BrowMgr:addGenderSign(str, tonumber(gf:getGenderByIcon(char:queryBasicInt("icon"))), Const.VIP_YEAR),
        show_time = showTime or 3,
        time = gf:getServerTime(),
        show_extra = false,
    }, nil, true)
end

-- 刷新地图桌子上的菜肴
function MidAutumnEatDlg:refreshTableFood(curScore)
    curScore = curScore or 0
    local iconPath = ResMgr.ui.inn_food_bubber_one
    if self.prepareData then
        local curPercent = self:getPercent(curScore, self.prepareData.maxScore)
        local midPercent = self:getPercent(self.prepareData.successScore, self.prepareData.maxScore)
        if curPercent >= FINAL_SCORE_PERCENT then
            iconPath = ResMgr.ui.dww_food_two
        elseif curPercent > midPercent then
            iconPath = ResMgr.ui.dww_food_one
        end
    end

    local image = gf:getMapObjLayer():getChildByName("DwwFood")
    if not image then
        image = ccui.ImageView:create(iconPath)
        image.iconPath = iconPath
        image:setAnchorPoint(0.5, 0.5)
        image:setPosition(cc.p(FOOD_POS.X, FOOD_POS.Y))
        image:setName("DwwFood")
        gf:getMapObjLayer():addChild(image, 1000)
    else
        if iconPath ~= image.iconPath then
            image:loadTexture(iconPath)
            image.iconPath = iconPath
        end
    end
end

-- 计算eat动作速度倍率, 最高正常速度5倍
function MidAutumnEatDlg:getEatActSpeed(score)
    return math.min(math.max(1, score / 1.5), 5)
end

-- 是否需要播放飘汗效果
function MidAutumnEatDlg:needPlayMagic(score)
    return score >= 6
end

-- 增加飘汗效果
function MidAutumnEatDlg:addPiaohanMagic(char)
    if not char then return end
    local headX, headY = char.charAction:getHeadOffset()
    local magic = gf:createSelfRemoveMagic(ResMgr.magic.dww_piaohan)
    magic:setAnchorPoint(0.5, 0.5)
    magic:setLocalZOrder(Const.CHARACTION_ZORDER)
    magic:setPosition(char.mhOffsetX, headY + char.mhOffsetY)
    char:addToMiddleLayer(magic)
end

-- 播放烟花特效
function MidAutumnEatDlg:playFunnyMagic()
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.funny_magic.name, "Bottom06", gf:getTopLayer())
end

-- 刷新地图上2位比赛的角色的分数
function MidAutumnEatDlg:refreshTablePlayerScore(addScoreOne, addScoreTwo)
    local playerOne = CharMgr:getCharById(PLAYER_CFG[1].id)
    if playerOne then
        playerOne.eatSpeed = self:getEatActSpeed(addScoreOne)
        if self:needPlayMagic(addScoreOne) then
            self:addPiaohanMagic(playerOne)
        end

        if playerOne.charAction.isPausePlay then
            -- 若角色动作被停止还应该开启
            playerOne.charAction:continuePlay()
        end
    end

    local playerTwo = CharMgr:getCharById(PLAYER_CFG[2].id)
    if playerTwo then
        playerTwo.eatSpeed = self:getEatActSpeed(addScoreTwo)
        if self:needPlayMagic(addScoreTwo) then
            self:addPiaohanMagic(playerTwo)
        end

        if playerTwo.charAction.isPausePlay then
            -- 若角色动作被停止还应该开启
            playerTwo.charAction:continuePlay()
        end
    end
end

-- 刷新角色eat动作速度
function MidAutumnEatDlg:refreshTablePlayer(char)
    if not char then return end

    char:setActSpeed(char.eatSpeed or 1)
end

-- 生成地图上2位比赛的角色
function MidAutumnEatDlg:bornTablePlayer()
    if not self.startData then return end

    InnMgr.dwwShowChar[PLAYER_CFG[1].id] = true
    CharMgr:MSG_APPEAR({x = PLAYER_CFG[1].x, y = PLAYER_CFG[1].y, dir = PLAYER_CFG[1].dir, id = PLAYER_CFG[1].id,
        icon = NPC_CHOOSE_CFG[self.startData.playerOneIndex].icon, type = OBJECT_TYPE.NPC, name = "", opacity = 0,
        light_effect_count = 0, isNowLoad = true, sub_type = OBJECT_NPC_TYPE.DWW_NPC})

    InnMgr.dwwShowChar[PLAYER_CFG[2].id] = true
    CharMgr:MSG_APPEAR({x = PLAYER_CFG[2].x, y = PLAYER_CFG[2].y, dir = PLAYER_CFG[2].dir, id = PLAYER_CFG[2].id,
        icon = NPC_CHOOSE_CFG[self.startData.playerTwoIndex].icon, type = OBJECT_TYPE.NPC, name = "", opacity = 0,
        light_effect_count = 0, isNowLoad = true, sub_type = OBJECT_NPC_TYPE.DWW_NPC})

    for i = 1, #PLAYER_CFG do
        local char = CharMgr:getCharById(PLAYER_CFG[i].id)
        if i == 1 then
            char.gid = self.startData.playerOneGid
            char:setPos(PLAYER_CFG[1].xx, PLAYER_CFG[1].yy)
            char.mhOffsetX = NPC_CHOOSE_CFG[self.startData.playerOneIndex]["mhOffsetX" .. PLAYER_CFG[1].dir]
            char.mhOffsetY = NPC_CHOOSE_CFG[self.startData.playerOneIndex]["mhOffsetY" .. PLAYER_CFG[1].dir]
        elseif i == 2 then
            char.gid = self.startData.playerTwoGid
            char:setPos(PLAYER_CFG[2].xx, PLAYER_CFG[2].yy)
            char.mhOffsetX = NPC_CHOOSE_CFG[self.startData.playerTwoIndex]["mhOffsetX" .. PLAYER_CFG[2].dir]
            char.mhOffsetY = NPC_CHOOSE_CFG[self.startData.playerTwoIndex]["mhOffsetY" .. PLAYER_CFG[2].dir]
        end

        -- 玩家自己选择的角色头顶增加向下箭头
        if char.gid == Me:queryBasic("gid") then
            local headX, headY = char.charAction:getHeadOffset()
            local magic = gf:createLoopMagic(ResMgr:getMagicDownIcon())
            magic:setAnchorPoint(0.5, 0.5)
            magic:setLocalZOrder(Const.CHARACTION_ZORDER)
            magic:setPosition(0, headY + 20)
            char:addToMiddleLayer(magic)
        end

        -- eat动作播放完回调
        local function endActCallBack()
            self:refreshTablePlayer(char)
        end

        char:setAct(Const.FA_EAT, endActCallBack)
    end
end

-- 展示成功结果前的表现
function MidAutumnEatDlg:doResultPerformance()
    -- 放烟花
    performWithDelay(self.root, function()
        self:playFunnyMagic()
    end, 1)

    -- 结果得分百分比
    local percent = self:getPercent(self.resultData.resultOne + self.resultData.resultTwo,
        self.prepareData.maxScore)

    -- npc喊话
    local maxPropagandaStep = #RESULT_PROPAGANDA
    if percent < 80 then
        -- 小于80时，在3个里面选
        maxPropagandaStep = 3
    elseif percent < 100 then
        -- 小于100时，在前5个里面选
        maxPropagandaStep = 5
    end

    local maxNpcStep = #DWW_NPC_CFG - 1
    local npcOneIndex = math.random(1, maxNpcStep)
    local npcTwoIndex = maxNpcStep - npcOneIndex + 1

    -- 第1个npc喊话
    self:setPropaganda(DWW_NPC_CFG[npcOneIndex].id, RESULT_PROPAGANDA[math.random(1, maxPropagandaStep)])

    -- 延迟1秒第2个npc喊话
    performWithDelay(self.root, function()
        self:setPropaganda(DWW_NPC_CFG[npcTwoIndex].id, RESULT_PROPAGANDA[math.random(1, maxPropagandaStep)])
    end, 1)

    -- 冯喜来喊话
    if percent >= 100 then
        self:setPropaganda(FXL_ID, CHS[7100385])
    else
        self:setPropaganda(FXL_ID, CHS[7100386])
    end
end

-- 准备阶段
function MidAutumnEatDlg:MSG_AUTUMN_2018_DWW_PREPARE(data)
    self.prepareData = data
    self:setDlgByStatus(GAME_STATUS.RULE)
end

-- 开始阶段
function MidAutumnEatDlg:MSG_AUTUMN_2018_DWW_START(data)
    self.startData = data

    -- 刷新桌子客栈桌子上的食物
    self:refreshTableFood()

    -- 生成地图上的角色
    self:bornTablePlayer()

    -- 清空计分
    self.scoreTable = {[1] = 0, [2] = 0}

    self:setDlgByStatus(GAME_STATUS.GAMING)
end

-- 分数进度
function MidAutumnEatDlg:MSG_AUTUMN_2018_DWW_PROGRESS(data)
    -- 根据分数变化值，刷新两个比赛模型状态
    self:refreshTablePlayerScore(data.scoreOne - self.scoreTable[1], data.scoreTwo - self.scoreTable[2])

    -- 更新分数
    self.scoreTable[1] = data.scoreOne
    self.scoreTable[2] = data.scoreTwo

    -- 更新进度条
    self:refreshBarprogress(data.scoreOne + data.scoreTwo)
end

-- 比赛结果
function MidAutumnEatDlg:MSG_AUTUMN_2018_DWW_RESULT(data)
    self.resultData = data
    self:setDlgByStatus(GAME_STATUS.RESULT)
end

-- 过图
function MidAutumnEatDlg:MSG_ENTER_ROOM(data)
    Dialog.close(self)
end

return MidAutumnEatDlg
