-- VacationSnowDlg.lua
-- Created by
-- 2018寒假活动-打雪仗

local NumImg = require('ctrl/NumImg')
local VacationSnowDlg = Singleton("VacationSnowDlg", Dialog)
local CharActionEnd = require('animate/CharActionEnd')

local DEFAULT_TIME_MAX = 25

local SKILL_KEY = {
    --  集雪                  丢球                              防御                      大雪球
    CHS[4100891], CHS[4100892], CHS[4100893], CHS[4100894]
}

-- 操作对应的动作
local OPER_ACT = {
    [1] = Const.SA_CAST,    -- 积雪对应施法
    [2] = Const.SA_ATTACK,  -- 丢球对应攻击
    [3] = Const.SA_PARRY,  -- 防御
    [4] = Const.SA_ATTACK,
}

-- 时钟水平方向偏移
local CLOCK_OFFSET_X = 4

-- 时钟相对于头顶基准点的偏移
local CLOCK_OFFESET_Y = 20

--[[
Top01   UI火焰
Top02   小雪球 vs 积雪
Top03   积雪   vs 小雪球
Top04   小雪球 vs 小雪球
Top05   积雪   vs 积雪
Top06   积雪   vs 大雪球
Top07   大雪球 vs 积雪
Top08   大雪球 vs 小雪球
Top09   小雪球 vs 大雪球
Top10   防御   vs 积雪
Top11   积雪   vs 防御
Top12   防御   vs 小雪球
Top13   小雪球 vs 防御
Top14   防御   vs 大雪球
Top15   大雪球 vs 防御
Top16   防御   vs 防御
Top17   大雪球 vs 大雪球
1 集雪, 2小雪球, 3 防御, 4大雪球
--]]

local MAGIC_MAP = {
    -- npc积雪
    [1] = {[1] = "Top05", [2] = "Top03", [3] = "Top11", [4] = "Top06"},
    -- npc小雪球
    [2] = {[1] = "Top02", [2] = "Top04", [3] = "Top13", [4] = "Top09"},
    -- npc防御
    [3] = {[1] = "Top10", [2] = "Top12", [3] = "Top16", [4] = "Top14"},
    -- npc大雪球
    [4] = {[1] = "Top07", [2] = "Top08", [3] = "Top15", [4] = "Top17"},
}

-- 1 集雪, 2小雪球, 3 防御, 4大雪球
local TIPS_MAP = {
    -- npc积雪
    [1] = {[1] = CHS[4100903], [2] = CHS[4100904], [3] = CHS[4100905], [4] = CHS[4100906]},
    -- npc小雪球
    [2] = {[1] = CHS[4100907], [2] = CHS[4100908], [3] = CHS[4100909], [4] = CHS[4100910]},
    -- npc防御
    [3] = {[1] = CHS[4100911], [2] = CHS[4100912], [3] = CHS[4100913], [4] = CHS[4100914]},
    -- npc大雪球
    [4] = {[1] = CHS[4100915], [2] = CHS[4100916], [3] = CHS[4100917], [4] = CHS[4100918]},
}

-- gameType说明
-- gameType == nil， 2018打雪仗活动 PVE
-- gameType == "fuqi-dxz" 夫妻任务-打雪仗

function VacationSnowDlg:init(gameType)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_1")
    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_2")

    self:setFullScreen()
    self:setCtrlFullScreen("ResultPanel_1")
    self:setCtrlFullScreen("ResultPanel_2")

   -- self.root:setContentSize(self.blank:getContentSize().width, self.blank:getContentSize().height + 100)
    self:setCtrlVisible("Panel_23", true)
    self:setCtrlContentSize("WaitPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100)
    self:setCtrlContentSize("Panel_23",self.blank:getContentSize().width, self.blank:getContentSize().height + 100)
    self:setCtrlContentSize("BlackPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100, "ResultPanel_1")
    self:setCtrlContentSize("BlackPanel",self.blank:getContentSize().width, self.blank:getContentSize().height + 100, "ResultPanel_2")


    self.gameType = gameType

    -- reorderChatDlg界面，让聊天可以点击
    -- 将自己的层级减低至ChatDlg一致
    local dlg = DlgMgr:getDlgByName("ChatDlg")
    self:setDlgZOrder(dlg:getDlgZOrder())
    DlgMgr:reorderDlgByName("ChatDlg")

    -- 增加倒计时
    self:addTimeImage()

    -- 技能点击
    for i = 1, 4 do
        local panel = self:getControl("ItemButton", nil, "SkillPanel_" .. i)
        panel:setTag(i)
        self:blindLongPress(panel, self.onSkillButton, self.onRNSkill)
    end

    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.daxuzhang.name, "Top01", self:getControl("SkillPanel_4"))

    -- 规则悬浮框
    self:bindFloatPanelListener("RulePanel")

    self:setCtrlVisible("NoticeImage", false)
    self:setCtrlVisible("WaitPanel", false)

    -- 界面默认显示  回合、雪球 为0
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, 1, false, LOCATE_POSITION.MID, 23)
    self:setNumImgForPanel("BallNumPanel", ART_FONT_COLOR.S_FIGHT, 0, false, LOCATE_POSITION.MID, 23)

        --
    local mapLayer = gf:getCharLayer()
    if not mapLayer:getChildByName("VacationSnowDlg") then
        local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 51))
        colorLayer:setName("VacationSnowDlg")

        colorLayer:setLocalZOrder(-1)
        colorLayer:setContentSize(1500, 1500)
        local x, y = gf:convertToClientSpace(33,34)
        colorLayer:setPosition(x - 1500 * 0.5, y - 1500 * 0.5)
        mapLayer:addChild(colorLayer)
    end

    AutoWalkMgr:cleanup()

    self.data = {player_xq_num = 0}

    self:hookMsg("MSG_WINTER2018_DAXZ_OPER")
    self:hookMsg("MSG_WINTER2018_DAXZ_SHOW")
    self:hookMsg("MSG_WINTER2018_DAXZ_WAIT")
    self:hookMsg("MSG_WINTER2018_DAXZ_BONUS")

    self:hookMsg("MSG_DAXZ_OPER")
    self:hookMsg("MSG_DAXZ_SHOW")
    self:hookMsg("MSG_DAXZ_WAIT")
    self:hookMsg("MSG_DAXZ_BONUS")
    self:hookMsg("MSG_DAXZ_OPER_STATE")
end

function VacationSnowDlg:cleanup()
    local mapLayer = gf:getCharLayer()
    local colorLayer = mapLayer:getChildByName("VacationSnowDlg")
    if colorLayer then
        colorLayer:removeFromParent()
    end

    Me:setCanMove(true)
    Me:setFixedView(false)
    Me.canShiftFlag = true
end

function VacationSnowDlg:removeTimeImage()
    -- 将倒计时图片、等待图片添加到 TimePanel 中
    self.numImg:removeFromParent()
end

function VacationSnowDlg:addTimeImage()
    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('TimePanel')
    if timePanel and not timePanel:getChildByName("numImg") then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', DEFAULT_TIME_MAX, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        self.numImg:setScale(0.5, 0.5)
        self.numImg:setName("numImg")
        timePanel:addChild(self.numImg, 100, 10)

        self.numImg:setPosition(sz.width / 2, sz.height / 2)
    end
end

function VacationSnowDlg:skillCloseCallBack(isVisible)
    if self.gameState == 1 and self.isCanOper then
        -- 暂停游戏
        self:setCtrlVisible("NoticeImage", true)


        if self.gameType == "fuqi-dxz" then
            -- 夫妻任务打雪仗
            local char = CharMgr:getChar(1)
            if not char.readyToFight then
                self:setCtrlVisible("NoticeImage", false)
            end
        end

    end
end


-- 点击技能
function VacationSnowDlg:onRNSkill(sender, eventType)
    local cmdOp = sender:getTag() == 4 and 2 or sender:getTag()
    self:cmdOper(cmdOp)
end

-- 长按技能
function VacationSnowDlg:onSkillButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local tag = sender:getTag()
    local dlg = DlgMgr:openDlg("VacationSnowSkillDlg")
    dlg:setSkill(SKILL_KEY[tag], self)
    dlg:setFloatingFramePos(rect)

    -- 技能出来后，隐藏
    self:setCtrlVisible("NoticeImage", false)
end

-- 设置游戏状态
function VacationSnowDlg:setGameState(state)
    self.gameState = state

    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("GameResultPanel", false)
    self:setCtrlVisible("ResultPanel_1", false)
    self:setCtrlVisible("ResultPanel_2", false)

    if state == 0 then
        -- 未开始
        self:setCtrlVisible("StartButton", true)
        self:setCtrlEnabled("StartButton", true)

        for i = 1, 2 do
            local char = CharMgr:getChar(i)
            if char and char.charAction then

                char.charAction:setLoopTimes(0)
                char.charAction:setAction(Const.SA_STAND)
            end
        end
    elseif state == 1 then
        -- 游戏进行
        self:setCtrlVisible("StartButton", false)
    elseif state == 2 then
        -- 游戏结束
        self:setCtrlVisible("GameResultPanel", true)
    end
end

-- 开始计时
function VacationSnowDlg:startCountDown(time)
    if not self.numImg then
        return
    end

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("TimePanel", true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)
    end)
end

function VacationSnowDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function VacationSnowDlg:pauseGame()
    if self.gameState == 1 then
        -- 暂停游戏
        gf:CmdToServer("CMD_WINTER2018_DAXZ_PAUSE_GAME")
    end
end

function VacationSnowDlg:continueGame()
    local dlg = DlgMgr:getDlgByName("ConfirmDlg")
    if dlg and dlg.confirm_type == "VacationSnowDlg" then
        -- 退出窗口正在打开
        return
    end

    if self.gameState == 1 then
        -- 继续
        gf:CmdToServer("CMD_WINTER2018_DAXZ_CONTINUE_GAME")
    end
end

function VacationSnowDlg:onPauseButton(sender, eventType)
    if self.gameState == 0 then
        -- 游戏未开始
        gf:confirm(CHS[4100890], function ()
            if self.gameType == "fuqi-dxz" then
                -- 夫妻任务打雪仗
                gf:CmdToServer("CMD_DAXZ_QUIT_GAME")
            else
                gf:CmdToServer("CMD_WINTER2018_DAXZ_QUIT_GAME")
            end
        end)
    elseif self.gameState == 1 then

        if self.gameType == "fuqi-dxz" then
            -- 夫妻任务打雪仗

            gf:confirm(CHS[4100889], function ()
                -- 退出
                gf:CmdToServer("CMD_DAXZ_QUIT_GAME")
            end)
            return
        end

        -- 游戏已经开始，操作中才可以暂停
        if self.isCanOper then

            -- 停止倒计时
            self.numImg:stopCountDown()

            -- 暂停游戏
            gf:CmdToServer("CMD_WINTER2018_DAXZ_PAUSE_GAME")

            gf:confirm(CHS[4100889], function ()
                -- 退出
                gf:CmdToServer("CMD_WINTER2018_DAXZ_QUIT_GAME")
            end, function ()
                -- 继续游戏
                gf:CmdToServer("CMD_WINTER2018_DAXZ_CONTINUE_GAME")
            end, nil, nil, nil, nil, nil, "VacationSnowDlg")
        end
    else
        if self.gameType == "fuqi-dxz" then
            -- 夫妻任务打雪仗

            gf:confirm(CHS[4100889], function ()
                -- 退出
                gf:CmdToServer("CMD_DAXZ_QUIT_GAME")
            end)
            return
        end
    end
end

function VacationSnowDlg:onCloseImage(sender, eventType)
    if not self.bonusData then return end
    if self.bonusData.isExitGame == 1 then
        if self.gameType == "fuqi-dxz" then
            -- 夫妻任务打雪仗
            gf:CmdToServer("CMD_DAXZ_QUIT_GAME")
        else
            gf:CmdToServer("CMD_WINTER2018_DAXZ_QUIT_GAME")
        end

    else
        self:setGameState(0)
    end
end

-- 点击开始游戏
function VacationSnowDlg:onStartButton(sender, eventType)
    if self.gameType == "fuqi-dxz" then
        -- 夫妻任务打雪仗
        gf:CmdToServer("CMD_DAXZ_START")
    else
        gf:CmdToServer("CMD_WINTER2018_DAXZ_START")
    end

    if self.gameType == "fuqi-dxz" then
        self:setCtrlVisible("WaitPanel", true)
        local panel = self:getControl("WaitPanel")
        panel:stopAllActions()

        local loadImageKey = 1
        local function update()
            for i = 1, 3 do
                self:setCtrlVisible("IconImage" .. i, i <= loadImageKey, panel)
            end
            loadImageKey = loadImageKey + 1
            if loadImageKey > 3 then loadImageKey = 1 end
        end
        schedule(panel, update, 0.5)
        self:setCtrlVisible("StartButton", false)
    else
        self:setCtrlEnabled("StartButton", false)
    end


end

function VacationSnowDlg:MSG_WINTER2018_DAXZ_WAIT(sender, eventType)
    self:setCtrlVisible("WaitPanel", false)
    -- 界面默认显示  回合、雪球 为0
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, 1, false, LOCATE_POSITION.MID, 23)
    self:setNumImgForPanel("BallNumPanel", ART_FONT_COLOR.S_FIGHT, 0, false, LOCATE_POSITION.MID, 23)

    self:setCtrlVisible("SkillPanel_2", true)
    self:setCtrlVisible("SkillPanel_4", false)

    self.data = {player_xq_num = 0}
end

function VacationSnowDlg:MSG_WINTER2018_DAXZ_OPER(data)
    self:setCtrlVisible("WaitPanel", false)
    self:setGameState(1)
    self:startCountDown(data.leftTime)
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, data.rounds, false, LOCATE_POSITION.MID, 23)
    self.isCanOper = true
    self:setCtrlVisible("NoticeImage", true)
    self:setNumImgForPanel("BallNumPanel", ART_FONT_COLOR.S_FIGHT, data.player_xq_num, false, LOCATE_POSITION.MID, 23)
    if not self.data then
        self.data = {}
    end

    -- 刷新雪球数据
    self.data.player_xq_num = data.player_xq_num
    self:setCtrlVisible("SkillPanel_2", data.player_xq_num < 3)
    self:setCtrlVisible("SkillPanel_4", data.player_xq_num >= 3)
end

-- 获取NPC 动作  返回参数  第一个表示 动作，第二个表示是不是CHAR,false表示 char.charAction
function VacationSnowDlg:getNPCAction(data)
    if data.player_oper == 4 then
        -- 玩家丢大雪球
        if data.npc_oper ~= 4 then
            return Const.FA_DIE_NOW, true
        end
    elseif data.player_oper == 2 then
        if data.npc_oper == 1 then
            return Const.FA_DIE_NOW, true
        end
    end

    return OPER_ACT[data.npc_oper], false
end

function VacationSnowDlg:getPlayerAction(data)
    if data.npc_oper == 4 then
        -- 玩家丢大雪球
        if data.player_oper ~= 4 then
            return Const.FA_DIE_NOW, true
        end
    elseif data.npc_oper == 2 then
        if data.player_oper == 1 then
            return Const.FA_DIE_NOW, true
        end
    end

    return OPER_ACT[data.player_oper], false
end

function VacationSnowDlg:getMagicIcon(data)
    return MAGIC_MAP[data.npc_oper][data.player_oper]
end

function VacationSnowDlg:getOperTips(data)

    local retTips = TIPS_MAP[data.npc_oper][data.player_oper]
    if self.gameType == "fuqi-dxz" then
        retTips = string.gsub(retTips, CHS[4010019], CHS[4010020])
    end

    return retTips
end

function VacationSnowDlg:MSG_DAXZ_OPER(data)
    local char = CharMgr:getChar(1)
    if char then
        self:addHeadEffect(char)
    end

    local char = CharMgr:getChar(2)
    if char then
        self:addHeadEffect(char)
    end

    self:MSG_WINTER2018_DAXZ_OPER(data)
end

function VacationSnowDlg:MSG_DAXZ_SHOW(data)
    self:MSG_WINTER2018_DAXZ_SHOW(data)
end

function VacationSnowDlg:MSG_DAXZ_WAIT(data)
    self:MSG_WINTER2018_DAXZ_WAIT(data)
end

function VacationSnowDlg:MSG_WINTER2018_DAXZ_SHOW(data)
    self:setCtrlVisible("WaitPanel", false)
    self.isCanOper = false
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("NoticeImage", false)



    local icon = self:getMagicIcon(data)
    local effPanel = self:getControl("MainPanel")

    local magic = effPanel:getChildByName(tostring(icon))
    if magic then
        magic:stopAllActions()
        magic:removeFromParent()
    end

    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.daxuzhang.name, icon, effPanel, function ()

        if self.gameType == "fuqi-dxz" then
            -- 夫妻任务打雪仗
            gf:CmdToServer("CMD_DAXZ_SHOW_DONE")
        else
            gf:CmdToServer("CMD_WINTER2018_DAXZ_SHOW_DONE")
        end

        --     	isChar 表示是char上的
        local act, isChar = self:getPlayerAction(data)
        if isChar then
            local char = CharMgr:getChar(1)
            char:setAct(act)
        end
        local act, isChar2 = self:getNPCAction(data)
        if isChar2 then
            local npc = CharMgr:getChar(2)
            npc:setAct(act, function ()
            end)
        end

        if isChar2 or isChar then
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.daxuzhang.name, icon .. "_1", effPanel)
        end

        local tips = self:getOperTips(data)
        gf:ShowSmallTips(tips)
        ChatMgr:sendMiscMsg(tips)
    end)


    local char = CharMgr:getChar(1)
    if char.charAction then
        char.charAction:playActionOnce(function ()
            end, OPER_ACT[data.player_oper])
    end

    local npc = CharMgr:getChar(2)
    local act, isChar = self:getNPCAction(data)
    if npc.charAction then
        npc.charAction:playActionOnce(function ()
            end, OPER_ACT[data.npc_oper])
    end

    if self.data and self.data.player_xq_num ~= data.player_xq_num then
        local disAct = cc.CallFunc:create(function()
            self:setCtrlVisible("SkillPanel_2", data.player_xq_num < 3)
            self:setCtrlVisible("SkillPanel_4", data.player_xq_num >= 3)
        end)

        local act1 = cc.ScaleTo:create(0.2, 1.2)
        local act2 = cc.ScaleTo:create(0.2, 1)
        local panel = self:getControl("BallPanel")
        panel:runAction(cc.Sequence:create(act1, act2, disAct))
        self:setNumImgForPanel("BallNumPanel", ART_FONT_COLOR.S_FIGHT, data.player_xq_num, false, LOCATE_POSITION.MID, 23)
    else
        self:setCtrlVisible("SkillPanel_2", data.player_xq_num < 3)
        self:setCtrlVisible("SkillPanel_4", data.player_xq_num >= 3)
    end

    self.data = data
end

function VacationSnowDlg:cmdOper(oper)
    if self.gameState == 0 then
        gf:ShowSmallTips(CHS[4100888])
        ChatMgr:sendMiscMsg(CHS[4100888])
        return
    elseif self.gameState == 1 then
        if not self.isCanOper then
            gf:ShowSmallTips(CHS[4100887])
            ChatMgr:sendMiscMsg(CHS[4100887])
            return
        end
    end

    local myOpState = self:getMeOpState()
    if myOpState and myOpState >= 1 then return end

    if self.gameType == "fuqi-dxz" then
        -- 夫妻任务打雪仗
        gf:CmdToServer("CMD_DAXZ_OPER", {oper = oper})

        local char = CharMgr:getChar(1)
        if char then
            self:removeHeadEffect(char)
        end
    else
        gf:CmdToServer("CMD_WINTER2018_DAXZ_OPER", {oper = oper})
    end

    self:setCtrlVisible("NoticeImage", false)

    -- 已操作光效
    if not self.data or not self.data.player_xq_num then return end

    -- 是否
    if oper == 1 then
        -- 积雪
     --   if self.data.player_xq_num < 3 then
            local panel = self:getControl("ItemPanel", nil, "SkillPanel_" .. oper)
            self:setCtrlVisible("ChosenImage_1", true, panel)
     --   end
    elseif oper == 2 then
        -- 丢球
        if self.data.player_xq_num >= 3 then
            -- 造作2也可能是大雪球
            local panel = self:getControl("ItemPanel", nil, "SkillPanel_4")
            self:setCtrlVisible("ChosenImage_1", true, panel)
        elseif self.data.player_xq_num > 0 then
            local panel = self:getControl("ItemPanel", nil, "SkillPanel_" .. oper)
            self:setCtrlVisible("ChosenImage_1", true, panel)


        end
    elseif oper == 3 then
        local panel = self:getControl("ItemPanel", nil, "SkillPanel_" .. oper)
        self:setCtrlVisible("ChosenImage_1", true, panel)
    end
end

-- 人物头顶增加闹钟动画
function VacationSnowDlg:addHeadEffect(char)
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
function VacationSnowDlg:removeHeadEffect(char)
    if char.readyToFight then
        char.readyToFight:removeFromParent()
        char.readyToFight = nil
    end
end

function VacationSnowDlg:MSG_DAXZ_BONUS(data)
    self:MSG_WINTER2018_DAXZ_BONUS(data)
end

function VacationSnowDlg:MSG_WINTER2018_DAXZ_BONUS(data)
    self:setGameState(2)
    self:setCtrlVisible("ResultPanel_1", data.exp ~= 0)
    self:setCtrlVisible("ResultPanel_2", data.exp == 0)

    local fPanel = data.exp == 0 and self:getControl("ResultPanel_2") or self:getControl("ResultPanel_1")
    self:setCtrlVisible("ScorePanel", false, fPanel)
    self:setCtrlVisible("ScorePanel2", false, fPanel)
    local panel
    if self.gameType == "fuqi-dxz" then
        panel = self:getControl("ScorePanel2", nil, fPanel)
    else
        panel = self:getControl("ScorePanel", nil, fPanel)
    end
    panel:setVisible(true)

    if  data.exp ~= 0 then
        self:setLabelText("NumLabel", data.exp, self:getControl("EXPPanel", nil, panel))
        self:setLabelText("NumLabel", gf:getTaoStr(data.tao, 0) .. CHS[4100886], self:getControl("TaoPanel", nil, panel))
        if data.itemName ~= "" then
            self:setLabelText("NumLabel", data.itemName .. "* 1", self:getControl("ItemPanel", nil, panel))
        else
            self:setLabelText("NumLabel", CHS[5000059], self:getControl("ItemPanel", nil, panel))
        end
    else
        if self.gameType == "fuqi-dxz" then
            self:setLabelText("NumLabel", gf:getTaoStr(data.tao, 0) .. CHS[4100886], self:getControl("TaoPanel", nil, panel))
            if data.itemName ~= "" then
                self:setLabelText("NumLabel", data.itemName .. "* 1", self:getControl("ItemPanel", nil, panel))
            else
                self:setLabelText("NumLabel", CHS[5000059], self:getControl("ItemPanel", nil, panel))
            end
        end
    end

    self:setCtrlVisible("Image_3_1", data.ret == 1, fPanel)
    self:setCtrlVisible("Image_3_2", data.ret ~= 1, fPanel)
    self:setCtrlVisible("Image_4", data.ret == 1, fPanel)

    self.bonusData = data

    -- 隐藏选择光效
    for i = 1, 4 do
        local panel = self:getControl("ItemPanel", nil, "SkillPanel_" .. i)
        self:setCtrlVisible("ChosenImage_1", false, panel)
    end
end

function VacationSnowDlg:getMeOpState()
    if not self.opData then return end
    for i = 1, self.opData.count do
        local char
        if self.opData[i].id == Me:getId() then
            char = CharMgr:getChar(1)
        end

        if char then
            return self.opData[i].is_done
        end
    end
end

function VacationSnowDlg:MSG_DAXZ_OPER_STATE(data)
    local isRemoveEff = true

    for i = 1, data.count do
        local char
        if data[i].id == Me:getId() then
            char = CharMgr:getChar(1)
        else
            char = CharMgr:getChar(2)
        end

        if data[i].is_done > 0 then isRemoveEff = false end

        if char and data[i].is_done > 0 then
            self:removeHeadEffect(char)
        end
    end

    self.opData = data

    if isRemoveEff then
        for i = 1, 4 do
            local panel = self:getControl("ItemPanel", nil, "SkillPanel_" .. i)
            self:setCtrlVisible("ChosenImage_1", false, panel)
        end
    end
end

return VacationSnowDlg
