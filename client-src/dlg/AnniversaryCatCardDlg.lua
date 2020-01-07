-- AnniversaryCatCardDlg.lua
-- Created by lixh Feb/02/2018
-- 周年庆-灵猫翻牌

local AnniversaryCatCardDlg = Singleton("AnniversaryCatCardDlg", Dialog)

-- 界面游戏状态
local GAME_STATE = {
    NOT_START = 0,  -- 游戏未开始状态
    GAMING = 1,     -- 游戏进行中
    OVER = 2,       -- 游戏完成
}

-- 请求服务器操作类型
local GAME_OPER_TYPE = {
    ACTION_DATA   = 0, -- 请求游戏数据
    ACTION_START  = 1, -- 开始游戏
    ACTION_FINISH = 2, -- 结束游戏
    ACTION_RESET  = 3, -- 重置游戏
    ACTION_TURN   = 4, -- 翻牌
}

-- 特效播放
local MAGIC_AB = ResMgr.magic.anniversary_card_ab
local MAGIC_BC = ResMgr.magic.anniversary_card_bc
local MAGIC_CA = ResMgr.magic.anniversary_card_ca
local MAGIC_RULE = {
    AB = {isDouble = false, first = MAGIC_AB},
    AC = {isDouble = true, first = MAGIC_AB, second = MAGIC_BC, waitShow = "B"},
    BA = {isDouble = true, first = MAGIC_BC, second = MAGIC_CA, waitShow = "C"},
    BC = {isDouble = false, first = MAGIC_BC},
    CA = {isDouble = false, first = MAGIC_CA},
    CB = {isDouble = true, first = MAGIC_CA, second = MAGIC_AB, waitShow = "A"},
}

local MAGIC_TAG = 999

-- 游戏最低等级限制
local LEVEL_LIMIT = 30

-- 牌子数量
local CARD_NUM = 9

function AnniversaryCatCardDlg:init()
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("CommitButton", self.onCommitButton)

    -- 点击牌子
    local function onCardPanel(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:setCtrlVisible("TouchEffectImage", true, sender)
        else
            self:setCtrlVisible("TouchEffectImage", false, sender)

            if eventType == ccui.TouchEventType.ended then
                -- 先检测活动是否已结束
                if not ActivityMgr:isFestivalActivityBegin(CHS[7190158]) then
                    gf:ShowSmallTips(CHS[7100175])
                    return
                end

                -- 跨天，时间不合法
                if not self:checkIsValidTime() then
                    self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)

                    -- 重新开始游戏，刷新游戏开始时间
                    self.openDlgTime = gf:getServerTime()
                    return
                end

                local tag = sender:getTag()
                if self.dlgBtnEnabled then
                    self:sendToServer(GAME_OPER_TYPE.ACTION_TURN, tag)

                    -- 点了牌子，肯定会播翻牌动画，动画播完前，设置按钮不可以点击
                    self:setDlgBtnEnabled(false)
                end
            end
        end
    end

    for i = 1, CARD_NUM do
        local card = self:getControl("UnitPanel" .. i, nil, "OperatePanel")
        card:addTouchEventListener(onCardPanel)
        card:setTag(i)
    end

    self.statusList = {}
    self.firstNeedPlayMagic = false
    self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)
    self:setDlgByStatus(GAME_STATE.NOT_START)
    self.openDlgTime = gf:getServerTime()
    self.dlgBtnEnabled = true
    self.needStartGame = nil

    self:hookMsg("MSG_LINGMAO_FANPAI_DATA")
end

-- 请求服务器
function AnniversaryCatCardDlg:sendToServer(oper, para)
    gf:CmdToServer("CMD_LINGMAO_FANPAI_OPER", {oper = oper, para = para or 0})
end

function AnniversaryCatCardDlg:setDlgByStatus(state, notRefreshIcon)
    self.gameState = state
    self:setCtrlVisible("FinishedPanel", false)
    self:setCtrlVisible("UnstartedPanel", false)
    gf:grayImageView(self:getControl("ResetButton"))
    gf:grayImageView(self:getControl("CommitButton"))

    if state == GAME_STATE.NOT_START then
        -- 未开始
        self:setCtrlVisible("UnstartedPanel", true)
        self.statusList = {}
        -- 初始状态全为C
        for i = 1, CARD_NUM do
            table.insert(self.statusList, "C")
        end
    elseif state == GAME_STATE.GAMING then
        -- 进行中
        gf:resetImageView(self:getControl("ResetButton"))
        gf:resetImageView(self:getControl("CommitButton"))
    else
        -- 已完成
        self:setCtrlVisible("FinishedPanel", true)
    end

    if not notRefreshIcon then
        self:refreshIcon()
    end
end

-- 刷新牌子icon
-- list为空时，刷新所有牌子状态，否则刷新list中指定牌子状态
function AnniversaryCatCardDlg:refreshIcon(list)
    if not list or #list == 0 then
        list = {}
        for i = 1, CARD_NUM do
            list[i] = i
        end
    end

    for i = 1, #list do
        local unitPanel = self:getControl("UnitPanel" .. list[i], nil, "OperatePanel")    
        self:setCtrlVisible("CardTypeAPanel", false, unitPanel)
        self:setCtrlVisible("CardTypeBPanel", false, unitPanel)
        self:setCtrlVisible("CardTypeCPanel", false, unitPanel)
        self:setCtrlVisible("CardType" .. self.statusList[list[i]] .. "Panel", true, unitPanel)
    end
end

-- 计算当前状态宝箱数量
function AnniversaryCatCardDlg:getRightCount()
    local count = 0
    for i = 1, #self.statusList do
        if self.statusList[i] == "C" then
            count = count + 1
        end
    end

    return count
end

-- 检测时间是否合法，操作不能跨天
function AnniversaryCatCardDlg:checkIsValidTime(notShowTips)
    if self.openDlgTime and gf:isSameDay5(gf:getServerTime(), self.openDlgTime) then
        return true
    end

    if not notShowTips then
        gf:ShowSmallTips(CHS[7190167])
    end

    return false
end

-- 设置界面按钮状态(播动画时，牌子，重置，提交按钮点击无效)
function AnniversaryCatCardDlg:setDlgBtnEnabled(flag)
    for i = 1, CARD_NUM do
        self:setCtrlOnlyEnabled("UnitPanel" .. i, flag, "OperatePanel")
    end

    self:setCtrlOnlyEnabled("ResetButton", flag)
    self:setCtrlOnlyEnabled("CommitButton", flag)
    self.dlgBtnEnabled = flag
end

-- 播放翻牌子动画
function AnniversaryCatCardDlg:playCardChangeMagic(list)
    if not list or #list == 0 then return end

    for i = 1, #list do
        local panel = self:getControl("UnitPanel" .. i)
        -- self:setCtrlVisible("CardType" .. self.statusList[i] .. "Panel", false, panel)
        self:setCtrlVisible("CardTypeAPanel", false, panel)
        self:setCtrlVisible("CardTypeBPanel", false, panel)
        self:setCtrlVisible("CardTypeCPanel", false, panel)

        local key = self.statusList[i] .. list[i]
        local magicConfig = MAGIC_RULE[key]

        -- 上一翻牌动画未完成，需直接停止
        if panel.delayToPlay then
            self.root:stopAction(panel.delayToPlay)
            panel.delayToPlay = nil
        end
        
        local magic = panel:getChildByTag(MAGIC_TAG)
        if magic then
            magic:stopAllActions()
            magic:removeFromParent()
        end

        if magicConfig then
            local function func()
                panel:removeChildByTag(MAGIC_TAG)

                if magicConfig.isDouble then
                    -- 显示中间停下来的翻牌结果
                    self:setCtrlVisible("CardType" .. magicConfig.waitShow .."Panel", true, panel)

                    -- 策划要求第二段翻牌动画，延迟0.3秒进行
                    panel.delayToPlay = performWithDelay(self.root, function()
                        self:setCtrlVisible("CardTypeAPanel", false, panel)
                        self:setCtrlVisible("CardTypeBPanel", false, panel)
                        self:setCtrlVisible("CardTypeCPanel", false, panel)

                        panel.delayToPlay = nil
    
                        self:addMagicToCardPanel(panel, magicConfig.second, function()
                            panel:removeChildByTag(MAGIC_TAG)
                            self:setCtrlVisible("CardType" .. list[i] .. "Panel", true, panel)
                            self:setDlgBtnEnabled(true)
                        end)
                    end, 0.3)
                else
                    self:setCtrlVisible("CardType" .. list[i] .. "Panel", true, panel)
                    self:setDlgBtnEnabled(true)
                end
            end

            self:addMagicToCardPanel(panel, magicConfig.first, func)
        else
            self:setCtrlVisible("CardType" .. list[i] .. "Panel", true, panel)
        end
    end
end

-- 添加翻牌子动画
function AnniversaryCatCardDlg:addMagicToCardPanel(panel, icon, callBack)
    local magic = panel:getChildByTag(MAGIC_TAG)
    if not magic then
        magic = gf:createCallbackMagic(icon, callBack)
        magic:setPosition(50, 50)
        panel:addChild(magic)
        magic:setTag(MAGIC_TAG)
    end
end

function AnniversaryCatCardDlg:cleanup()
    self.statusList = {}
    self.openDlgTime = nil
    self.dlgBtnEnabled = nil
end

-- 开始游戏
function AnniversaryCatCardDlg:onStartButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:getLevel() < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[7190165], LEVEL_LIMIT))
        return
    end

    -- 先检测活动是否已结束
    if not ActivityMgr:isFestivalActivityBegin(CHS[7190158]) then
        gf:ShowSmallTips(CHS[7100175])
        return
    end

    -- 跨天，时间不合法
    if not self:checkIsValidTime(true) then
        self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)

        -- 重新开始游戏，刷新游戏开始时间
        self.openDlgTime = gf:getServerTime()
        self.needStartGame = true
        return
    end
    

    self:sendToServer(GAME_OPER_TYPE.ACTION_START)
    self.firstNeedPlayMagic = true
end

-- 重置游戏
function AnniversaryCatCardDlg:onResetButton(sender, eventType)
    if self.gameState == GAME_STATE.NOT_START then
        gf:ShowSmallTips(CHS[7190162])
    elseif self.gameState == GAME_STATE.GAMING then
        -- 先检测活动是否已结束
        if not ActivityMgr:isFestivalActivityBegin(CHS[7190158]) then
            gf:ShowSmallTips(CHS[7100175])
            return
        end

        -- 跨天，时间不合法
        if not self:checkIsValidTime() then
            self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)

            -- 重新开始游戏，刷新游戏开始时间
            self.openDlgTime = gf:getServerTime()
            return
        end

        self:sendToServer(GAME_OPER_TYPE.ACTION_RESET)
    elseif self.gameState == GAME_STATE.OVER then
        gf:ShowSmallTips(CHS[7190164])
    end
end

-- 提交游戏
function AnniversaryCatCardDlg:onCommitButton(sender, eventType)
    if self.gameState == GAME_STATE.NOT_START then
        gf:ShowSmallTips(CHS[7190162])
    elseif self.gameState == GAME_STATE.GAMING then
        local count = self:getRightCount()
        if count <= 3 then
            gf:ShowSmallTips(CHS[7190168])
            return
        end

        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if Me:getLevel() < LEVEL_LIMIT then
            gf:ShowSmallTips(string.format(CHS[7190165], LEVEL_LIMIT))
            return
        end

        if GameMgr.inCombat then
            gf:ShowSmallTips(CHS[7190166])
            return
        end

        -- 先检测活动是否已结束
        if not ActivityMgr:isFestivalActivityBegin(CHS[7190158]) then
            gf:ShowSmallTips(CHS[7100175])
            return
        end

        -- 跨天，时间不合法
        if not self:checkIsValidTime() then
            self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)

            -- 重新开始游戏，刷新游戏开始时间
            self.openDlgTime = gf:getServerTime()
            return
        end

        gf:confirm(string.format(CHS[7190163], count), function()
            -- 处于禁闭状态
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            end

            if Me:getLevel() < LEVEL_LIMIT then
                gf:ShowSmallTips(string.format(CHS[7190165], LEVEL_LIMIT))
                return
            end

            if GameMgr.inCombat then
                gf:ShowSmallTips(CHS[7190166])
                return
            end

            -- 先检测活动是否已结束
            if not ActivityMgr:isFestivalActivityBegin(CHS[7190158]) then
                gf:ShowSmallTips(CHS[7100175])
                return
            end

            -- 跨天，时间不合法
            if not self:checkIsValidTime() then
                self:sendToServer(GAME_OPER_TYPE.ACTION_DATA)

                -- 重新开始游戏，刷新游戏开始时间
                self.openDlgTime = gf:getServerTime()
                return
            end

            self:sendToServer(GAME_OPER_TYPE.ACTION_FINISH, self.gameDay)
        end)
    elseif self.gameState == GAME_STATE.OVER then
        gf:ShowSmallTips(CHS[7190164])
    end
end

-- 服务器翻牌数据回来
function AnniversaryCatCardDlg:MSG_LINGMAO_FANPAI_DATA(data)
    if not data then return end

    local notRefreshIcon = false
    if (self.firstNeedPlayMagic or self.gameState == GAME_STATE.GAMING) and data.status == GAME_STATE.GAMING then
        -- 策划要求首次点击开始按钮改变牌子状态、游戏中翻牌子导致牌子状态改变时，需要播放翻牌子动画
        -- 关闭界面，再重新打开游戏，直接显示上次的牌子状态，不需要播放动画
        self:playCardChangeMagic(data.list)
        notRefreshIcon = true
    end

    self.gameDay = data.gameDay
    self.statusList = data.list
    self:setDlgByStatus(data.status, notRefreshIcon)

    -- 策划要求，跨天点击开始按钮，直接开始游戏
    if self.needStartGame then
        self:onStartButton()
        self.needStartGame = false
    end
end

return AnniversaryCatCardDlg
