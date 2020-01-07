-- AnniversaryPetCardDlg.lua
-- Created by songcw Nov/08/2018
-- 周年庆萌宠翻牌

local AnniversaryPetCardDlg = Singleton("AnniversaryPetCardDlg", Dialog)

local FIRST_CARD_POS = cc.p(39, 304)

--  单个card的宽高，初始化时赋值
local UNIT_PANEL_WIDTH
local UNIT_PANEL_HEIGHT

-- 倒计时2分钟即120秒
local COUNT_DOWN_TIME = 120000

-- update刷新时间间隔，每帧刷感觉浪费
local REFRESH_TIME = 5

local FlipCardTime = 1


local NormalPetList = require (ResMgr:getCfgPath("NormalPetList.lua"))
local VariationPetList = require (ResMgr:getCfgPath("VariationPetList.lua"))
local EpicPetList = require (ResMgr:getCfgPath("EpicPetList.lua"))
local OtherPetList = require (ResMgr:getCfgPath("OtherPetList.lua"))
local JingguaiPetList = require(ResMgr:getCfgPath('JingGuai.lua'))
local JinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local CARD_KEY

local CARD_STATE = {
    HIDE = 1,       -- 盖牌
    SHOW = 2,       -- 显示的牌
    OK = 3,         -- 成功配对
}

local CARD_RULES = {
    [1] = {cardType = 3, count = 4}, -- cardType 第一关 3个种类，每个种类保底4张
    [2] = {cardType = 4, count = 4}, -- cardType 第一关 3个种类，每个种类保底4张
    [3] = {cardType = 5, count = 2},
    [4] = {cardType = 6, count = 2},
}

function AnniversaryPetCardDlg:init()
    self:bindListener("ResetButton", self.onResetButton)

    self.unitPanel = self:retainCtrl("UnitPanel1")
    self:bindTouchEndEventListener(self.unitPanel, self.onClickCard)
    UNIT_PANEL_WIDTH = self.unitPanel:getContentSize().width - 4            -- -2的原因是，边框有一部分透明的
    UNIT_PANEL_HEIGHT = self.unitPanel:getContentSize().height - 4

    self.isRunning = false
    self.round = 1
    self.pauseTime = 0
    self.lastSender = nil
    self.score = 0
    self.isLock = false
    self.reseting = false
    self.isGameSatrtInServer = false

    self:loadCardKey()

    -- 初始化卡牌
    self:initCards()

    -- 初始化倒计时
    self:setCountDown(120)

    self:setGetCard(0)

    self:hookMsg("MSG_2019ZNQFP_START")
    self:hookMsg("MSG_2019ZNQFP_FINISH")
    self:hookMsg("MSG_2019ZNQFP_BONUS")
end

function AnniversaryPetCardDlg:loadCardKey()
    if not CARD_KEY then
        CARD_KEY = {}

        for _, pet in pairs(NormalPetList) do
            table.insert( CARD_KEY, pet.icon )
        end

        for _, pet in pairs(VariationPetList) do
            table.insert( CARD_KEY, pet.icon )
        end

        for _, pet in pairs(EpicPetList) do
            table.insert( CARD_KEY, pet.icon )
        end

        for _, pet in pairs(OtherPetList) do
            table.insert( CARD_KEY, pet.icon )
        end

        for _, pet in pairs(JingguaiPetList) do
            table.insert( CARD_KEY, pet.icon )
        end

        for _, pet in pairs(JinianPetList) do
            table.insert( CARD_KEY, pet.icon )
        end
    end
end


function AnniversaryPetCardDlg:cleanup()
    if self.panel then
        self.panel:removeFromParent()
        self.panel = nil
    end

    if self.isGameSatrtInServer  then
        --local key = gfEncrypt(self.score, self.gameData.encrypt_id)
        gf:CmdToServer('CMD_2019ZNQFP_COMMIT', {result = "", bonus_flag = 0})
    end
end

function AnniversaryPetCardDlg:onClickBlank()
    if self.isRunning then return true end
end

function AnniversaryPetCardDlg:onUpdate()
    if not self.isRunning then
        return
    end

    if self.reseting then return end

    self.refreshTime = self.refreshTime + 1

    if self.refreshTime % 10 == 0 then
        return
    end

    local leftTime = self.endTime - gfGetTickCount() + self.pauseTime

    if leftTime <= 0 then
        local key = gfEncrypt(self.score, self.gameData.encrypt_id)
        gf:CmdToServer('CMD_2019ZNQFP_COMMIT', {result = key, bonus_flag = 1})
        self.isRunning = false
        self.isGameSatrtInServer = false
        self:setAllCardBack()
    end

    leftTime = math.floor( leftTime / 1000 )
    self:setCountDown(leftTime)
end

-- 初始化卡牌
function AnniversaryPetCardDlg:initCards()
    self:setAllCardBack()

    local cards = self:getCardByRound(self.round)
    self:setCard(cards)
end

function AnniversaryPetCardDlg:setAllCardBack()
    local contentPanel = self:getControl("OperatePanel")
    contentPanel:removeAllChildren()
    local tag = 0
    for i = 1, 4 do
        local x, y
        for j = 1, 4 do
            x = FIRST_CARD_POS.x + (j - 1) * UNIT_PANEL_WIDTH
            y = FIRST_CARD_POS.y - (i - 1) * UNIT_PANEL_HEIGHT

            tag = tag + 1

            local panel = self.unitPanel:clone()
            panel:setTag(tag)
            panel.state = CARD_STATE.HIDE
            self:setUnitCard(panel)

            panel:setPosition(cc.p(x, y))
            contentPanel:addChild(panel)
        end
    end
end

function AnniversaryPetCardDlg:setUnitCard(panel)
    local iconPanel = self:getControl("ShapePanel_0", nil, panel)

 --   self:setImage("FrontImage", ResMgr:getSmallPortrait(0543), iconPanel)
  --  self:setImage("BackImage", ResMgr:getSmallPortrait(6002), iconPanel)
    self:setImage("FrontImage", ResMgr.ui.mcfp_back_iamge, iconPanel)

    self:setCtrlVisible("FrontImage", true, iconPanel)
    self:setCtrlVisible("BackImage", false, iconPanel)
end

-- 初始化倒计时
function AnniversaryPetCardDlg:setCountDown(time)

    local m = 0
    local s = 0
    if time <= 0 then

    else
        m = math.floor( time / 60 )
        s = time % 60
    end

    self:setLabelText("TimeLabel", string.format(CHS[4010238], m, s))
end

-- 设置翻牌数
function AnniversaryPetCardDlg:setGetCard(num)

    self:setLabelText("NumLabel", string.format(CHS[4010239], num))
end

function AnniversaryPetCardDlg:getRetAction(callBack)
    local rotate1 = cc.RotateBy:create(0.1, 10)
    local rotate2 = cc.RotateBy:create(0.1, -20)
    local rotate3 = cc.RotateBy:create(0.1, 20)
    local rotate4 = cc.RotateBy:create(0.1, -20)
    local rotate5 = cc.RotateBy:create(0.1, 10)

    -- 动作效果
    local lastAct = cc.CallFunc:create(function()
        if callBack then
            callBack()
        end
    end)

    return cc.Sequence:create(rotate1, rotate2, rotate3, rotate4, rotate5, lastAct)
end

-- 当前翻转回合结束，需要动画完了才可以继续
function AnniversaryPetCardDlg:checkHuiheMagic()

    local contentPanel = self:getControl("OperatePanel")
    for i = 1, 16 do
        local panel = contentPanel:getChildByTag(i)
        local magic = panel:getChildByName(ResMgr.magic.mcpf_open_card)
        if magic then return false end
    end

    return true
end

-- type : 1为翻牌， 2为复原
function AnniversaryPetCardDlg:flipCard(sender, type)
    local forntImage = self:getControl("FrontImage", nil, sender)
    local backImage = self:getControl("BackImage", nil, sender)

    local itemPanel = self:getControl("ShapePanel_0", nil, sender)


    if not itemPanel then
        return
    end

    if type == 1 then
        self:setCtrlVisible("ShapePanel_0", false, sender)
        local magic = sender:getChildByName(ResMgr.magic.mcpf_open_card)
        if magic then return end

        magic = gf:createCallbackMagic(ResMgr.magic.mcpf_open_card, function ( )
            -- body
            self:setCtrlVisible("ShapePanel_0", true, sender)
            self:setCtrlVisible("FrontImage", false, sender)
            self:setCtrlVisible("BackImage", true, sender)
            magic:removeFromParent()
        end, {blendMode = "normal", frameInterval = 30})

        magic:setName(ResMgr.magic.mcpf_open_card)
        magic:setPosition(sender:getContentSize().width * 0.5 + 16, sender:getContentSize().height * 0.5 - 18)
        sender:addChild(magic)

    else

        sender.isShake = true
        itemPanel:runAction(self:getRetAction(function ()
            -- body
            self:setCtrlVisible("FrontImage", true, sender)
            self:setCtrlVisible("BackImage", false, sender)
            sender.isShake = false
        end))
    end


end

function AnniversaryPetCardDlg:onClickCard(sender)
    if not self.isRunning then
        gf:ShowSmallTips(CHS[4010240]) -- 点击开始翻牌后才能进行游戏哦！
        return
    end

    if self.isLock then return end      -- 翻牌动画未结束
    if sender.isShake then return end   -- 摇换动画未结束

    if CARD_STATE.HIDE ~= sender.state then return end

    if not self.lastSender and not self:checkHuiheMagic() then
        return
    end

    self:flipCard(sender, 1)

    sender.state = CARD_STATE.SHOW

    if not self.lastSender then
        self.lastSender = sender
    else
        if sender.key == self.lastSender.key then
            -- 成功配对
            sender.state = CARD_STATE.OK
            self.lastSender.state = CARD_STATE.OK
            self.lastSender = nil

            self.score = self.score + 2
            self:setGetCard(self.score)

            if self.score % 16 == 0 then
                -- 需要新来一把
                local curTicket = gfGetTickCount()
                self.isLock = true
                self.reseting = true
                performWithDelay(self.root, function ( )
                    -- body
                    self.round = self.round + 1
                    self.pauseTime = self.pauseTime + gfGetTickCount() - curTicket
                    self.isLock = false
                    self.reseting = false
                    self:initCards()

                end, 2)
            end
        else
            self.isLock = true
            performWithDelay(self.root, function ( )
                -- body
                sender.state = CARD_STATE.HIDE
                self.lastSender.state = CARD_STATE.HIDE

                self:flipCard(sender, 2)
                self:flipCard(self.lastSender, 2)

                self.isLock = false
                self.lastSender = nil
            end, 0.5)
        end
    end


end

function AnniversaryPetCardDlg:onResetButton(sender, eventType)
    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(string.format(CHS[7190165], 30))
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

        -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    gf:CmdToServer('CMD_2019ZNQFP_START')
end

function AnniversaryPetCardDlg:getCardKey(cards, maxNum)
    local key = math.random(1, maxNum)
    if not cards[key] then
        return key
    end

    return self:getCardKey(cards, maxNum)
end


function AnniversaryPetCardDlg:getCardByRound(round)
    local cards = {}
    if round > 4 then round = 4 end

    local randomCard = 16 - CARD_RULES[round].cardType * CARD_RULES[round].count

    for i = 1, CARD_RULES[round].cardType do
        local key = self:getCardKey(cards, #CARD_KEY)
        local exCount = 0
        if randomCard > 0 then
            exCount = math.random( 0, randomCard * 0.5) * 2
            randomCard = randomCard - exCount
        end

        if i == CARD_RULES[round].cardType and randomCard > 0 then
            exCount = exCount + randomCard
        end

        cards[key] = CARD_RULES[round].count + exCount
    end

    return cards
end

function AnniversaryPetCardDlg:setCard(cards)
    local operatePanel = self:getControl("OperatePanel", nil, panel)
    local pos = {}
    for cardKey, count in pairs(cards) do
        for i = 1, count do
            local tag = self:getCardKey(pos, 16)
            pos[tag] = cardKey
            local panel = operatePanel:getChildByTag(tag)
            self:setImage("BackImage", ResMgr:getSmallPortrait(CARD_KEY[cardKey]), panel)
            panel.key = cardKey
        end
    end
end


function AnniversaryPetCardDlg:MSG_2019ZNQFP_FINISH(data)
    DlgMgr:closeDlg(self.name)
end

function AnniversaryPetCardDlg:MSG_2019ZNQFP_START(data)
    self.isRunning = true
    self.refreshTime = 0
    self.gameData = data
    self.lastSender = nil
    self.pauseTime = 0

    self.isGameSatrtInServer = true

    self.score = 0
    self:setGetCard(self.score)
    self.endTime = gfGetTickCount() + COUNT_DOWN_TIME
    self:initCards()

    self:setCtrlEnabled("ResetButton", false)
end

function AnniversaryPetCardDlg:onCloseButton()
    if self.isRunning then
        local tips = CHS[4010241]
        if self.gameData.num == 0 then
            tips = CHS[4010242]
        end

        local curTicket = gfGetTickCount()
        self.isRunning = false
        gf:confirm(tips, function ( )
            -- body
            gf:CmdToServer('CMD_2019ZNQFP_COMMIT', {result = "", bonus_flag = 0})
            DlgMgr:closeDlg(self.name)
        end, function ( )
            -- body
            self.isRunning = true
            self.pauseTime = self.pauseTime + gfGetTickCount() - curTicket
        end)
    else
        DlgMgr:closeDlg(self.name)
    end
end

function AnniversaryPetCardDlg:getGameisRunning()
    return self.isRunning
end

function AnniversaryPetCardDlg:MSG_2019ZNQFP_BONUS(data)
    DlgMgr:openDlgEx("AnniversaryPetCardrewDlg", data)

    self:setCtrlEnabled("ResetButton", true)
end


return AnniversaryPetCardDlg
