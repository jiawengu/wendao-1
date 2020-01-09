-- ShiswgDlg.lua
-- Created by songcw Jan/09/2019
-- 谁是乌龟游戏界面

local ShiswgDlg = Singleton("ShiswgDlg", Dialog)

local PLAYER_MAX_COUNT = 3  -- 人数
local CARD_MAX_COUNT   = 7  -- 每个人最多拥有的牌数
local BASIC_CARD_COUNT = 5  -- 每个人基础牌数量
local BASIC_TOTAL_COUNT = 15    -- 基础牌的总数量
local CARD_WIDTH_HALF
local CARD_HEIGHT_HALF

local HEIGHT_MARGIN = 10
local WIDTH_MARGIN = 12
local GENERAL_WIDTH = 300

local GAME_STATUS = {
    PREPARE         = "prepare",            -- 准备阶段
    START           = "start",              -- 第一次发牌动画播放阶段
    RUNNING         = "running",            -- 玩家开始操作阶段
    GM_OPER         = "gm_oper",            -- 庄家操作动画阶段
    END             = "end",                -- 游戏结算并且结束阶段
}

local POKER_RES = {
    [10] = ResMgr.ui.wg_poker_back,
    [1] = ResMgr.ui.wg_poker_1,
    [2] = ResMgr.ui.wg_poker_2,
    [3] = ResMgr.ui.wg_poker_3,
    [4] = ResMgr.ui.wg_poker_4,
    [5] = ResMgr.ui.wg_poker_5,
    [6] = ResMgr.ui.wg_poker_6,
    [7] = ResMgr.ui.wg_poker_7,
    [8] = ResMgr.ui.wg_poker_8,
}

--[[
show_type 类型
#define GAME_SHOW_PREPARE       1   // 准备阶段，para 为空
#define GAME_SHOW_PREPARE_DONE  2   // 有人准备就绪，para 为操作玩家 index
#define GAME_SHOW_FAPAI         3   // 发牌
#define GAME_SHOW_OPER          4   // 有人操作，para 为操作玩家 index
#define GAME_SHOW_CHOUPAI       5   // 进行抽牌操作，para 为客户端参数
#define GAME_SHOW_BONUS         6   // 奖励阶段
#define GAME_SHOW_FLEE          7   // 有人逃跑，para 为操作玩家 index
#define GAME_SHOW_CONTINUE      8   // 继续
#define GAME_SHOW_END_ACTION    9   // 动画播放完毕
#define GAME_SHOW_RECONNECT     10  // 重连刷新数据
--]]

function ShiswgDlg:init()
    self:setFullScreen()
    local size = self.root:getContentSize()
    self.winSize = self:getWinSize()
    self:setCtrlFullClient("BKImage", "BKPanel", true)
    self:setCtrlFullClient("BackPanel", "BKPanel")

    self:setCtrlContentSize("FloatPanel",size.width, size.height)
  --  self:setCtrlContentSize("BKPanel",size.width, size.height)
 --   self:setCtrlContentSize("BackPanel",size.width + 500, size.height + 300, "BKPanel")
    self:setCtrlContentSize("WaitPanel",size.width, size.height)



    self:bindListener("ShrinkButton", self.onShrinkButton, "NotePanel_1")
    self:bindListener("ExpandButton", self.onExpandButton, "NotePanel_1")
    self:bindListener("ShrinkButton", self.onShrinkButton, "NotePanel_3")
    self:bindListener("ExpandButton", self.onExpandButton, "NotePanel_3")
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ChatButton", self.onChatButton)
    self:bindListener("CancelAutoButton", self.onCancelAutoButton)

    self:bindListener("CloseImage", self.onCloseImage)
    self:bindFloatingEvent("RulePanel")

    self.activingCards = {}             -- 客户端生成的牌，放这里面，cleanup时候清除，正常动作结束后会清，这个再次防止不会清
    self.activingCardCount = 0          -- 生成牌的数量
    self.touchId = 0
    self.totalCard = 0
    self.isPlayingAction = false
    self.chatContent = {}

    CARD_WIDTH_HALF = self:getControl("CardBackImage"):getContentSize().width * 0.5
    CARD_HEIGHT_HALF =  self:getControl("CardBackImage"):getContentSize().height * 0.5

    self.tipButtonState = self.tipButtonState or {["NotePanel_1"] = "ExpandButton", ["NotePanel_3"] = "ExpandButton"}

    self:initVisible()
    self:bindAllCards()

    self:hookMsg("MSG_SUMMER_2019_SSWG_DATA")
    self:hookMsg("MSG_SUMMER_2019_SSWG_BONUS")
    self:hookMsg("MSG_MESSAGE_EX")


    self.root:requestDoLayout()
end

-- 设置倒计时
function ShiswgDlg:onUpdate()
    if not self.data then return end
    if not self.leftTime then return end

    if self.data.status ~= GAME_STATUS.RUNNING then
        self:setLeftTime({})
        return
    end

    self:setLeftTime(self.data)
end

function ShiswgDlg:startLeftTime(data)
    if data and data.status == GAME_STATUS.RUNNING then
        self.leftTime = math.min( data.remain_ti, gf:getServerTime() + 20)
    else
       self.leftTime = false
       self:setLeftTime({})
    end
end

-- 设置倒计时
function ShiswgDlg:setLeftTime(data)
    for i = 1, 3 do
        local curPanelNum = self:getPanelNumByIndex(data.cur_index)
        local panel = self:getControl("TimePanel", nil, "PlayerPanel" .. i)
        if i ~= curPanelNum or data.show_type == 9 then
            panel:setVisible(false)
        else
            panel:setVisible(true)
            local lefeTime = self.leftTime - gf:getServerTime()
            lefeTime = math.max(0,  lefeTime)

            local numImg = self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.B_FIGHT, lefeTime, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
            numImg:setScale(0.25, 0.25)
        end
    end
end

function ShiswgDlg:onCloseImage(sender, eventType)
    self:initVisible()
    gf:CmdToServer("CMD_SUMMER_2019_SSWG_CONTINUE")
    self:MSG_SUMMER_2019_SSWG_DATA(self.data)
end

function ShiswgDlg:getNextIndex()
    local next_index = self.data.cur_index + 1
    if next_index == 4 then next_index = 1 end

    for i = 1, 3 do
        if self.data.playersInfo[i].index == next_index and self.data.playersInfo[i].card_num ~= 0 then
            return self.data.playersInfo[i].index
        end
    end

    next_index = next_index + 1
    if next_index == 4 then next_index = 1 end
    for i = 1, 3 do
        if self.data.playersInfo[i].index == next_index and self.data.playersInfo[i].card_num ~= 0 then
            return self.data.playersInfo[i].index
        end
    end

    return
end

function ShiswgDlg:pickUpCard(sender)
    if self.isPlayingAction then return end
    if not self.data then return end

    -- 是不是自己操作
    local curPanelIndex = self:getPanelNumByIndex(self.data.cur_index)
    if curPanelIndex ~= 2 then return end

    -- 操作的牌是不是下一个玩家的
    local next_index = self:getNextIndex()
    local retNum = self:getPanelNumByIndex(next_index)
    if not retNum then return end
    if ("PlayerPanel" .. retNum) ~= sender:getParent():getParent():getParent():getName() then return end


    self:getPanelNumByIndex(self.data.cur_index)

    sender:setVisible(false)
    local panel = sender:getParent()
    local idx = string.match(sender:getName(), "Image(%d+)")

    -- 复原其他选中的
    for i = 1, CARD_MAX_COUNT do --     6
        self:setCtrlVisible("UpImage" .. i, tonumber(idx) == i, panel)
        self:setCtrlVisible("Image" .. i, tonumber(idx) ~= i, panel)
    end
end

function ShiswgDlg:putDownCard(sender)
    if self.isPlayingAction then return end
    sender:setVisible(false)
    local panel = sender:getParent()
    local idx = string.match(sender:getName(), "Image(%d+)")
    self:setCtrlVisible("Image" .. idx, true, panel)
end

-- 绑定所有牌的点击事件
function ShiswgDlg:bindAllCards()
    -- 正常牌点击拖动事件
    local function normalCardLisener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            sender.beginPos = GameMgr.curTouchPos
        elseif eventType == ccui.TouchEventType.moved then
        --[[    WDSY-36089      修改为点击了
            if GameMgr.curTouchPos.y - sender.beginPos.y > 30 then
                self:pickUpCard(sender)
            end
            --]]
        elseif eventType == ccui.TouchEventType.ended then
            self:pickUpCard(sender)
        else
        end
    end

    local function pickCardLisener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            sender.beginPos = GameMgr.curTouchPos
        elseif eventType == ccui.TouchEventType.moved then
            --[[    WDSY-36089      修改为点击了
            if GameMgr.curTouchPos.y - sender.beginPos.y < -30 then
                self:putDownCard(sender)
            end
            --]]
        elseif eventType == ccui.TouchEventType.ended then
            if sender:isVisible() then
               local panel = sender:getParent():getParent():getParent()
               local beiChouGid = panel.gid
               local beiChouName = panel.pName

               local chouGid = Me:queryBasic("gid")
               local chouName = Me:queryBasic("name")
               local idx = string.match( sender:getName(), "Image(%d+)")
               local para = string.format( CHS[4010340], beiChouName, beiChouGid, chouName, chouGid, idx)
               gf:CmdToServer("CMD_SUMMER_2019_SSWG_OPER", {oper = 3, para = idx})
               self.isPlayingAction = true
            end
        else
        end
    end

    for i = 1, PLAYER_MAX_COUNT do  --  3
        if i == 2 then
        else
            local panel = self:getControl("PlayerPanel" .. i)
            for j = 1, CARD_MAX_COUNT do    -- 6
                local dImage = self:getControl("Image" .. j, nil, panel)
                dImage:addTouchEventListener(normalCardLisener)

                local uImage = self:getControl("UpImage" .. j, nil, panel)
                uImage:addTouchEventListener(pickCardLisener)
            end
        end
    end
end

function ShiswgDlg:getTableByPara(para)
    local ret = {}
    local tab = gf:split(para, ";")
    for _, keyStr in pairs(tab) do
        local pos = gf:findStrByByte(keyStr, ":")
        if pos then
            local key = string.sub( keyStr, 0, pos - 1 )
            local value = string.match(keyStr, ":(.+)")
            ret[key] = value
        end
    end
    return ret
end


function ShiswgDlg:paringSrcCardId(para, removeValye)
    local numStr = string.match(para, "{(.+)}")
    local tab = gf:split(numStr, ",")
    local ret = {}
    local flag = false
    for i = 1, #tab - 1 do
        if removeValye ~= self:getCardValue(tab[i]) then
            table.insert( ret, self:getCardValue(tab[i]) )
        else
            if flag then
                table.insert( ret, self:getCardValue(tab[i]) )
            end
            flag = true
        end
    end

    table.sort(ret, function(l, r)
        if l > r then return true end
        if l < r then return false end
     end)

    return ret
end

function ShiswgDlg:showGetCardAction(para)

    local ret = self:getTableByPara(para)
--[[
    [LUA-print] DEBUG : { 抽取后原始牌=({15,12,6,9,13,7,}), 被抽玩家=話賭神, 编号=3,
 抽取玩家=卜潮人, 抽取牌id=7, 抽取Gid=5C37F607000C8100C5F9, 被抽Gid=5C37F64E000C
8200C5F9,  }
]]

    local fromGid = ret[CHS[4010341]]--string.match(para, "被抽玩家:(.+);")
    local toGid = ret[CHS[4010342]]--string.match(para, "抽取玩家:(.+);")
    local idx = ret[CHS[4010343]]--string.match(para, "编号:(.+);")

    local toPlayerPanel = self:getPlayerPanelByGid(toGid)
    local fromPlayerPanel = self:getPlayerPanelByGid(fromGid)
    local sender = self:getControl("Image" .. idx, nil, fromPlayerPanel)
    local cardValue = self:getCardValue(ret[CHS[4010344]])   -- 抽取牌id

    if toGid == Me:queryBasic("gid") then
        -- 我抽别人的牌
        local cards = self:paringSrcCardId(ret[CHS[4010345]], cardValue)    -- 为了表现效果，排除 cardValue，动画后增加
        self:getCardFromPlayerAction(sender, cardValue, cards)
    elseif fromGid == Me:queryBasic("gid") then
        -- 别人抽我的牌
        local cards = self:paringSrcCardId(ret[CHS[4010345]])    -- 为了表现效果，排除 cardValue，动画后增加
        self:removeCardForPlayer(toGid, cardValue, cards)
    else
        -- 这回合和我没有关系，刷新就好
        local cards = self:paringSrcCardId(ret[CHS[4010345]])    -- 为了表现效果，排除 cardValue，动画后增加
        self:justSeeSee(fromPlayerPanel, toPlayerPanel, cards, cardValue)
    end
end


function ShiswgDlg:justSeeSee(fromPlayerPanel, toPlayerPanel, cards, cardValue)
    local sender
    for i = 1, CARD_MAX_COUNT do
        local crl = self:getControl("Image" .. i, nil, fromPlayerPanel)
        if crl.value == 10 then
            sender = crl--最后一个有值的
        end
    end

    local flyCard = self:createCard(nil, sender)
    flyCard:setPosition(self:getValidWorldPos(sender))
    sender:setVisible(false)
    local panel = toPlayerPanel
    local pos = self:getValidWorldPos(self:getControl("HeadPanel", nil, panel))
    local act = self:getMoveAction(0.8, pos, function ( )
        self:removeActiveCard(flyCard)

        local temp = self:changeToBackImage(cards)
        self:setOtherPlayerCards(nil, panel, temp)

        -- 检测对方是否有对子
        local otherCards = self:getCardsByGid(toPlayerPanel.gid)
        if #otherCards ~= #cards then
            performWithDelay(self.root, function ()
                self:checkOtherPlayerCards(temp, otherCards, panel)
            end, 1)
        else
            gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.RUNNING})
        end
    end)

    flyCard:runAction(act)
end

-- 初始化游戏界面控件可见性
function ShiswgDlg:initVisible()
    self.totalCard = 0

    for i = 1, PLAYER_MAX_COUNT do  --  3
        local panel = self:getControl("PlayerPanel" .. i)
        self:setCtrlVisible("TimePanel", false, panel)          -- 时间
        local pokerPanel = self:setCtrlVisible("PokerPanel", true, panel)
        local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
        cardPanel:setVisible(false)

        local notePanel = self:getControl("NotePanel_" .. i)
        if notePanel then
            notePanel:setVisible(true)
        end

        for j = 1, CARD_MAX_COUNT do    -- 6
            self:setCtrlVisible("Image" .. j, false, cardPanel)
            self:setCtrlVisible("UpImage" .. j, false, cardPanel)
        end

        self:setCtrlVisible("ReadyLabel", true, pokerPanel)     -- 准备中
        self:setCtrlVisible("OKImage", false, pokerPanel)        -- OK
        self:setCtrlVisible("OutImage", false, pokerPanel)       -- 已爆

        self:setCtrlVisible("NotePanel_" .. i, false)
    end

    for panelName, btnName in pairs(self.tipButtonState) do
        if btnName == "ShrinkButton" then
            self:onShrinkButton(self:getControl(btnName, nil, panelName))
        else
            self:onExpandButton(self:getControl(btnName, nil, panelName))
        end
    end

    self:setCtrlVisible("WaitPanel", false)
    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("CardBackImage", false)
    self:setCtrlVisible("StartButton", true)

    self:setCtrlVisible("FloatPanel", true)
end

function ShiswgDlg:setPlayerInfo(data)
    for i = 1, PLAYER_MAX_COUNT do
        local panel = self:getControl("PlayerPanel" .. i)
        self:setUnitPlayerInfo(data.playersInfo[i], panel, data.status)

        self:setLabelText("NumLabel", i, panel)
    end
end

function ShiswgDlg:setUnitPlayerInfo(data, panel, gameStatus)
    panel.playersInfo = data

    if data then
        -- 头像
        local iconPanel = self:getControl("PlayerImagePanel", nil, panel)
        self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), iconPanel)

        -- 名字
        self:setLabelText("NameLabel", data.name, panel)

        if data.gid == Me:queryBasic("gid") then
            self:setCtrlVisible("CancelAutoButton", data.trusteehip_flag == 1)

            self:setCtrlVisible("WaitPanel", data.prepared == 1)
            self:setCtrlVisible("StartButton", data.prepared == 0)
        end

        -- 玩家离队
        self:setCtrlEnabled("IconImage", data.is_online == 1, iconPanel)

        self:setCtrlVisible("ReadyLabel",data.prepared == 0, panel)     -- 准备中
        self:setCtrlVisible("OKImage", data.prepared == 1, panel)        -- OK



        if gameStatus ~= "prepare" then
            self:setCtrlVisible("ReadyLabel", false, panel)     -- 准备中
            self:setCtrlVisible("OKImage", false, panel)        -- OK

            self:setCtrlVisible("WaitPanel", false)
            self:setCtrlVisible("StartButton", false)
        else
            self:setCtrlVisible("CancelAutoButton", false)
        end

        panel.gid = data.gid
        panel.pName = data.name
    else
        -- 头像
        self:setImage("IconImage", ResMgr.ui.fish_default_portrait, iconPanel)

        -- 名字
        self:setLabelText("NameLabel", "", panel)
    end
end

function ShiswgDlg:onShrinkButton(sender, eventType)
    local panel = sender:getParent()
    sender:setVisible(false)
    self:setCtrlVisible("ExpandButton", true, panel)
    self:setCtrlVisible("BKImage", false, panel)
    self:setCtrlVisible("NoticeLabel", false, panel)

    self.tipButtonState[panel:getName()] = "ShrinkButton"
end

function ShiswgDlg:onExpandButton(sender, eventType)
    local panel = sender:getParent()
    sender:setVisible(false)
    self:setCtrlVisible("ShrinkButton", true, panel)
    self:setCtrlVisible("BKImage", true, panel)
    self:setCtrlVisible("NoticeLabel", true, panel)

    self.tipButtonState[panel:getName()] = "ExpandButton"
end

function ShiswgDlg:onStartButton(sender, eventType)
    sender:setVisible(false)
    self:setCtrlVisible("WaitPanel", true)
    gf:CmdToServer("CMD_SUMMER_2019_SSWG_PREPARE")
end

function ShiswgDlg:onExitButton(sender, eventType)

    if not self.data or self.data.status == GAME_STATUS.PREPARE then
        gf:confirmEx(CHS[4010338], CHS[4101190],   function ( )
            gf:CmdToServer("CMD_SUMMER_2019_SSWG_QUIT")
            self:onCloseButton()
        end, CHS[4101191], function ()

        end)
        return
    end

    gf:confirmEx(CHS[4010339], CHS[4101190],   function ( )
        self:onCloseButton()
        gf:CmdToServer("CMD_SUMMER_2019_SSWG_QUIT")
    end, CHS[4101191], function ()

    end)
end

function ShiswgDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end


function ShiswgDlg:onCancelAutoButton(sender, eventType)
    gf:CmdToServer("CMD_SUMMER_2019_SSWG_CANCEL_TRUSTEESHIP")
    sender:setVisible(false)
end

function ShiswgDlg:onChatButton(sender, eventType)
    DlgMgr:closeDlg("ChannelDlg")
    DlgMgr:sendMsg("ChatDlg", "onChatButton")
end

-- 分发基础牌
function ShiswgDlg:fapaiBasic()
    local order = 0
    self:setAllCardValue()
    for i = 1, BASIC_CARD_COUNT do -- 基础牌一人5张
        for j = 1, PLAYER_MAX_COUNT do  -- 3个人
            order = order + 1
            self:fapaiAction(j, i)
            --[[ 顺序一个一个发，策划干掉该效果
            performWithDelay(self.root, function ( )
                self:fapaiAction(j, i)
            end, 1 * (order - 1))
            --]]
        end
    end
end

function ShiswgDlg:setOtherPlayerCards(count, panel, cards)
    if cards then
        for i = 1, CARD_MAX_COUNT do
            if cards[i] then
                img = self:setImagePlist("Image" .. i, POKER_RES[cards[i]], panel)
            else
                img = self:setImagePlist("Image" .. i, ResMgr.ui.touming, panel)
            end
            img.value = cards[i]
            img:setVisible(true)
            self:setCtrlVisible("UpImage" .. i, false, panel)
        end

        return
    end

    for i = 1, CARD_MAX_COUNT do
        if i <= count then
            img = self:setImagePlist("Image" .. i, POKER_RES[10], panel)
        else
            img = self:setImagePlist("Image" .. i, ResMgr.ui.touming, panel)
        end
        img:setVisible(true)
        self:setCtrlVisible("UpImage" .. i, false, panel)
    end
end

function ShiswgDlg:setMyPlayerCards(cards)
    local panel = self:getMyCardPanel()
    local cards = cards or self:getCardsByGid(Me:queryBasic("gid"))
    local count = #cards
    for i = 1, CARD_MAX_COUNT do
        local img
        if i <= count then
            img = self:setImagePlist("Image" .. i, POKER_RES[cards[i]], panel)
            self:setImagePlist("UpImage" .. i, POKER_RES[cards[i]], panel)
        else
            img = self:setImagePlist("Image" .. i, ResMgr.ui.touming, panel)
            self:setImagePlist("UpImage" .. i, ResMgr.ui.touming, panel)
        end
        img:setVisible(true)
        self:setCtrlVisible("UpImage" .. i, false, panel)
    end
end

function ShiswgDlg:getCardsByGid(gid)
    if not self.data then return end
    local temp = gf:deepCopy(self.data.cards[gid])

    if not temp then return {} end

    table.sort(temp, function(l, r)
        if l > r then return true end
        if l < r then return false end
     end)

    return temp
end

function ShiswgDlg:getPlayerPanelByGid(gid)
    for i = 1, PLAYER_MAX_COUNT do
        local panel = self:getControl("PlayerPanel" .. i)
        if panel.gid == gid then
            return panel
        end
    end
end

function ShiswgDlg:setAllCardTouch(isEnble)
    for i = 1, PLAYER_MAX_COUNT do      -- 3
        if i == 2 then
            -- 自己牌面不管
        else
            local panel = self:getControl("PlayerPanel" .. i)
            for j = 1, CARD_MAX_COUNT do    -- 6
                self:setCtrlOnlyEnabled("Image" .. j, isEnble, panel)
                self:setCtrlOnlyEnabled("UpImage" .. j, isEnble, panel)
            end
        end
    end
end


function ShiswgDlg:setAllCardValue(isVisible)
    isVisible = isVisible or false
    for i = 1, PLAYER_MAX_COUNT do      -- 3
        local panel = self:getControl("PlayerPanel" .. i)
        for j = 1, CARD_MAX_COUNT do    -- 6
            local cards = self:getCardsByGid(panel.gid)
            local img
            if cards[j] then
                img = self:setImagePlist("Image" .. j, POKER_RES[cards[j]], panel)


                img.value = cards[j]
            else
                img = self:setImagePlist("Image" .. j, ResMgr.ui.touming, panel)

                img.value = nil
            end
            img:setVisible(isVisible)

            self:setCtrlVisible("UpImage" .. j, false, panel)
        end
    end
end

function ShiswgDlg:releaseAllCards()
    for _, img in pairs(self.activingCards) do
        img:removeFromParent()
    end

    self.activingCards = {}
end

function ShiswgDlg:cleanup()
    self:releaseAllCards()
end

-- 创建一张盖牌 cardValue 牌的数字
function ShiswgDlg:createCard(cardValue, image)
    self.activingCardCount = self.activingCardCount + 1

    local backImage
    if image then
        backImage = image:clone()
    else
        backImage = ccui.ImageView:create(POKER_RES[cardValue], ccui.TextureResType.plistType)
        backImage:setAnchorPoint(0.5, 0.5)
    end


    local ctrlName = "ShiswgDlgBackImage" .. self.activingCardCount
    backImage:setName(ctrlName)
    self.activingCards[ctrlName] = backImage
  --  gf:getUILayer():addChild(backImage)

    self:getControl("FloatPanel"):addChild(backImage)

    return backImage
end

-- 获取移动动作
function ShiswgDlg:getMoveAction(time, destPos, callBack)
    local moveAct = cc.MoveTo:create(time, destPos)
    local cb = cc.CallFunc:create(function()
        if callBack then
            callBack()
        end
    end)
    return cc.Sequence:create(moveAct, cc.DelayTime:create(1), cb)
end

-- 某个玩家被抽牌后，对齐那个玩家的牌
function ShiswgDlg:alignOtherPlayerCardsAction(sender)
    local playerPanel = sender:getParent():getParent():getParent()
    local playerIdx = string.match( playerPanel:getName(), "Panel(%d+)")
    local cardIdx = tonumber(string.match( sender:getName(), "Image(%d+)"))

    local cards = self:getCardsByGid(playerPanel.gid)

    local maxCount = math.min(CARD_MAX_COUNT, #cards + 1)

    for i = 1, CARD_MAX_COUNT do
        self:setCtrlVisible("UpImage" .. i, false, playerPanel)
    end

    for i = 1, maxCount do
        if i > cardIdx then
            local cardImage = self:createCard(10)
            local orgCard = self:getControl("Image" .. i, nil, playerPanel)
            orgCard:setVisible(false)
            local orgRect = self:getBoundingBoxInWorldSpace(orgCard)
            cardImage:setPosition(orgRect.x / Const.UI_SCALE + CARD_WIDTH_HALF - self.winSize.ox, orgRect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2)
            local destPanel = self:getControl("Image" .. (i - 1), nil, playerPanel)
            local destRect = self:getBoundingBoxInWorldSpace(destPanel)
            local act = self:getMoveAction(0.2, cc.p(destRect.x / Const.UI_SCALE + CARD_WIDTH_HALF - self.winSize.ox, destRect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2), function ()
                self:removeActiveCard(cardImage)

                self:setOtherPlayerCards(maxCount - 1, playerPanel)
            end)
            cardImage:runAction(act)
        end
    end
end

-- 通过卡牌值获取对应可插入位置
function ShiswgDlg:getAddCardIdx(value, cards)
    if value == 8 then return 1 end

    local idx
    cards = cards or self:getCardsByGid(Me:queryBasic("gid"))
    for i = 1, #cards do
        if value <= cards[i] then
            idx = i + 1

        end
    end
    if not idx then idx = 1 end
    return idx
    --if 1 then return end
    --[[
    value = value or 3
    local ret = value + 1
    local panel = self:getMyCardPanel()
    local cardImage = self:getControl("Image" .. ret, nil, panel)
    local rect = self:getBoundingBoxInWorldSpace(cardImage)
    return cc.p(rect.x + CARD_WIDTH_HALF, rect.y + CARD_HEIGHT_HALF)
    --]]
end


--==============================--
--desc:从我牌中拿掉、插入一张，  腾出，缩合动作
--time:2019-01-11 12:24:43
--@type: 1 拿掉           2 插入
--@idx: 目标位置所以
--@return
--==============================---
function ShiswgDlg:operMyCardsAction(type, idx, cards)
    local myCardPanel = self:getMyCardPanel()
    local cards = cards or self:getCardsByGid(myCardPanel:getParent():getParent().gid)

    local maxCount = math.min(CARD_MAX_COUNT, #cards)
    for i = 1, maxCount do
        if i >= idx then
            local cardImage = self:createCard(10)
            local orgCard = self:getControl("Image" .. i, nil, myCardPanel)
            if orgCard.value then
                cardImage:loadTexture(POKER_RES[orgCard.value], ccui.TextureResType.plistType)
            end
            orgCard:setVisible(false)
            local orgRect = self:getBoundingBoxInWorldSpace(orgCard)
            cardImage:setPosition(orgRect.x / Const.UI_SCALE + CARD_WIDTH_HALF  - self.winSize.ox, orgRect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2)
            local destPanel = self:getControl("Image" .. (i + 1), nil, myCardPanel)
            local destRect = self:getBoundingBoxInWorldSpace(destPanel)

            local act = self:getMoveAction(0.2, cc.p(destRect.x / Const.UI_SCALE + CARD_WIDTH_HALF - self.winSize.ox, destRect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2), function ()

            end)
            cardImage:runAction(act)
        end
    end
end

function ShiswgDlg:getValidWorldPos(sender)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    return cc.p(rect.x / Const.UI_SCALE + CARD_WIDTH_HALF - self.winSize.ox, rect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2)
end

-- 别的玩家抽走我的排
function ShiswgDlg:removeCardForPlayer(toGid, value, cards)
    local myCardPanel = self:getMyCardPanel()
    local sender
    for i = 1, CARD_MAX_COUNT do
        local image = self:getControl("Image" .. i, nil, myCardPanel)
        if image.value == value then
            sender = image
        end
    end

    local flyCard = self:createCard(nil, sender)
    flyCard:setPosition(self:getValidWorldPos(sender))
    sender:setVisible(false)

    local panel = self:getPlayerPanelByGid(toGid)
    local pos = self:getValidWorldPos(self:getControl("HeadPanel", nil, panel))
    local act = self:getMoveAction(0.8, pos, function ( )
        self:removeActiveCard(flyCard)
        local data = self:getCardsByGid(Me:queryBasic("gid"))
        self:setMyPlayerCards(data)
        local temp = self:changeToBackImage(cards)
        self:setOtherPlayerCards(nil, panel, temp)

        -- 检测对方是否有对子
        local otherCards = self:getCardsByGid(toGid)
        if #otherCards ~= #cards then
            performWithDelay(self.root, function ()
                self:checkOtherPlayerCards(temp, otherCards, panel)
            end, 1)
        else
            gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.RUNNING})
        end
    end)

    flyCard:runAction(act)
end

function ShiswgDlg:checkOtherPlayerCards(cards, srcCards, panel)
    local isGet = false

    for i = #cards, 1, -1 do
        if cards[i] == cards[i - 1] and not isGet and cards[i] ~= 10 then
            local image1 = self:setCtrlVisible("Image" .. i, true, panel)
            local image2 = self:setCtrlVisible("Image" .. (i - 1), true, panel)

            isGet = true

            performWithDelay(self.root, function ()
                local img1 = self:createCard(nil, image1)
                local pos = self:getValidWorldPos(image1)
                --img1:setPosition(pos.x / Const.UI_SCALE - CARD_WIDTH_HALF - self.winSize.ox, pos.y / Const.UI_SCALE - CARD_HEIGHT_HALF - self.winSize.oy * 2)
                img1:setPosition(pos.x - CARD_WIDTH_HALF, pos.y - CARD_HEIGHT_HALF)
                image1:setVisible(false)

                local img2 = self:createCard(nil, image2)
                local pos2 = self:getValidWorldPos(image2)
                --img2:setPosition(pos2.x / Const.UI_SCALE - CARD_WIDTH_HALF - self.winSize.ox, pos2.y / Const.UI_SCALE - CARD_HEIGHT_HALF - self.winSize.oy * 2)
                img2:setPosition(pos2.x - CARD_WIDTH_HALF, pos2.y - CARD_HEIGHT_HALF)
                image2:setVisible(false)

                local tempCards = gf:deepCopy(cards)
                local srcCards = self:getCardsByGid(panel.gid)
                table.remove( tempCards, i)
                table.remove( tempCards, i - 1 )
                self:loseDoubleCard(img1)
                self:loseDoubleCard(img2, function ()

                    if #tempCards ~= #srcCards then
                        self:checkOtherPlayerCards(tempCards, srcCards, panel)
                    else
                        -- 数量一致，说明没有对子，动画播放结束
                        gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.RUNNING})
                    end
                end)
            end, 1)
        end
    end
end


-- 将非重复的设置为暗牌
function ShiswgDlg:changeToBackImage(cards)
    local displayCards = {}
    local temTab = {}
    local validTab = {}
    for i = 1, #cards do
        if cards[i] == cards[i + 1] or cards[i] == cards[i - 1] then
        else
            cards[i] = 10
            table.insert( temTab, 10 )
        end

        if cards[i] == cards[i + 1] and cards[i] ~= 10 then
            table.insert( validTab, cards[i] )
            table.insert( validTab, cards[i] )
        end
    end

    for _, value in pairs(temTab) do
        table.insert( displayCards, value )
    end

    for _, value in pairs(validTab) do
        table.insert( displayCards, value )
    end
    return displayCards
end



-- 从玩家出抽牌动画
function ShiswgDlg:getCardFromPlayerAction(sender, cardValue, cards)

    -- 某个玩家被抽牌后，对齐那个玩家的牌
    self:alignOtherPlayerCardsAction(sender)

    -- 我的目标位置索引
    local destIdx = self:getAddCardIdx(cardValue, cards)

    -- 我的牌，移除一个位置来放新牌
    self:operMyCardsAction(2, destIdx, cards)

    -- 把移除的牌加进我的牌中
    table.insert(cards, cardValue)

    table.sort(cards, function(l, r)
        if l > r then return true end
        if l < r then return false end
     end)

    -- 创建一张牌移动到我的位置上
    local cardImage1 = self:createCard(10)
    local playerPanel = sender:getParent():getParent():getParent()
    local playerIdx = string.match( playerPanel:getName(), "Panel(%d+)")
    local cardIdx = tonumber(string.match( sender:getName(), "Image(%d+)"))
    local orgCard = self:getControl("Image" .. cardIdx, nil, playerPanel)

    if orgCard.value then
        cardImage1:loadTexture(POKER_RES[orgCard.value], ccui.TextureResType.plistType)
    end

    --local orgRect = self:getBoundingBoxInWorldSpace(orgCard)
    cardImage1:setPosition(self:getValidWorldPos(orgCard))
    local act = self:getMoveAction(0.5, self:getAddCardPosByValue(destIdx), function ()
        self:releaseAllCards()
        self:setMyPlayerCards(cards)

        -- 如果两个数据不一样，检测是不是有对子
        local cardData = self:getCardsByGid(Me:queryBasic("gid"))
        if #cardData ~= #cards then
            performWithDelay(self.root, function ()
                -- body
                self:checkCards(cards)
            end, 1)
        else
            -- 数量一致，说明没有对子，动画播放结束
            gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.RUNNING})
            gf:ShowSmallTips(CHS[4010346])
        end
    end)
    cardImage1:runAction(act)
end

-- 丢掉对子
function ShiswgDlg:loseDoubleCard(image, fun)
    local pCard = self:getControl("CardBackImage")
    local pos = self:getValidWorldPos(pCard)
    pos.x = pos.x - CARD_WIDTH_HALF
    pos.y = pos.y - CARD_HEIGHT_HALF
    local moveAct = cc.MoveTo:create(0.3, pos)
    -- 动作效果结束了
    local callBack = cc.CallFunc:create(function()
        self:removeActiveCard(image)

        if fun then
            fun()
        end
    end)

    image:runAction(cc.Sequence:create(moveAct, cc.DelayTime:create(0.2), callBack))
end

-- 后台切回来，激活
function ShiswgDlg:beActive()
    self.root:stopAllActions()
    self:getControl("FloatPanel"):removeAllChildren()
end

function ShiswgDlg:enterBackground()
    if self.data and self.data.status ~= GAME_STATUS.PREPARE then
        DlgMgr:closeDlg(self.name)
    end
end

-- 检测是否有对子
function ShiswgDlg:checkCards(cards)
    local panel = self:getMyCardPanel()
    local isGet = false
    for i = 1, #cards do
        if cards[i] == cards[i + 1] and not isGet then
            self:setCtrlVisible("Image" .. i, false, panel)
            self:setCtrlVisible("Image" .. (i + 1), false, panel)
            local image1 = self:setCtrlVisible("UpImage" .. i, true, panel)
            local image2 = self:setCtrlVisible("UpImage" .. (i + 1), true, panel)

            isGet = true

            performWithDelay(self.root, function ()
                -- body
                local img1 = self:createCard(nil, image1)
                local pos = self:getValidWorldPos(image1)
                img1:setPosition(pos.x - CARD_WIDTH_HALF, pos.y - CARD_HEIGHT_HALF)
                image1:setVisible(false)

                local img2 = self:createCard(nil, image2)
                local pos = self:getValidWorldPos(image2)
                img2:setPosition(pos.x - CARD_WIDTH_HALF, pos.y - CARD_HEIGHT_HALF)
                --img2:setPosition(self:getValidWorldPos(image2))
                image2:setVisible(false)

                local tempCards = gf:deepCopy(cards)
                table.remove( tempCards, i + 1 )
                table.remove( tempCards, i )
                self:loseDoubleCard(img1)
                self:loseDoubleCard(img2, function ()
                    local srcData = self:getCardsByGid(Me:queryBasic("gid"))
                    self:setMyPlayerCards(tempCards)
                    if #tempCards ~= #srcData then
                        self:checkCards(tempCards)
                    else
                        -- 数量一致，说明没有对子，动画播放结束
                        gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.RUNNING})
                    end
                end)
            end, 1)
        end
    end
end



-- 由于我的牌面要根据单双显示不同，所以通过该接口获取
function ShiswgDlg:getAddCardPosByValue(destIdx)
    local panel = self:getMyCardPanel()
    local image = self:getControl("Image" .. destIdx, nil, panel)
    return self:getValidWorldPos(image)
end



-- 由于我的牌面要根据单双显示不同，所以通过该接口获取
function ShiswgDlg:getMyCardPanel()
    return self:getControl("CardPanel", nil, "PlayerPanel2")
end

function ShiswgDlg:removeActiveCard(card)
    local ctlName = card:getName()
    card:removeFromParent()
    self.activingCards[ctlName] = nil
end

-- 发牌动画
function ShiswgDlg:fapaiAction(numPanel, pos, cardValue, data)
    local backImage = self:createCard(10)
    local winSize = self:getWinSize()
    -- 起始位置
    local backCard = self:getControl("CardBackImage")
    local rect = self:getBoundingBoxInWorldSpace(backCard)

    backImage:setPosition(rect.x / Const.UI_SCALE + CARD_WIDTH_HALF - winSize.ox, rect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - winSize.oy * 2)

    -- 目标位置
    local panel = self:getControl("PlayerPanel" .. numPanel)
    if numPanel == 2 then
        panel = self:getMyCardPanel()
    end
    local card = self:getControl("Image" .. pos, nil, panel)
    local destRect = self:getBoundingBoxInWorldSpace(card)
    local destX = destRect.x  / Const.UI_SCALE + CARD_WIDTH_HALF - winSize.ox
    local dextY = destRect.y  / Const.UI_SCALE + CARD_HEIGHT_HALF - winSize.oy * 2

    -- 动作
    local rotationAct = cc.RotateBy:create(0.5, 720)
    local moveAct = cc.MoveTo:create(0.5, cc.p(destX, dextY))
    local spawnAct = cc.Spawn:create(rotationAct, moveAct)

    -- 动作效果结束了
    local callBack = cc.CallFunc:create(function()
        self.totalCard = self.totalCard + 1


        -- 发的是基础牌
        if self.totalCard <= BASIC_TOTAL_COUNT then
            -- 对应的牌显示出来
            card:setVisible(true)

            if self.totalCard == BASIC_TOTAL_COUNT then
                gf:CmdToServer("CMD_SUMMER_2019_SSWG_END_ACTION", {status = GAME_STATUS.START})
            end
        else
            -- 将中间的盖牌隐藏
            self:setCtrlVisible("CardBackImage", false)
        end

        -- 删除
        self:removeActiveCard(backImage)
    end)

    backImage:runAction(cc.Sequence:create(spawnAct, cc.DelayTime:create(0.2), callBack))
end

-- 通过id转换为对应的牌
function ShiswgDlg:getCardValue(cardId)
    cardId = tonumber(cardId)
    if cardId == 0 then
        return 10
    elseif cardId <= 14 then
        return math.floor((cardId - 1) % 7) + 1
    else
        return 8
    end
end

function ShiswgDlg:changeData(data)
    local playersInfo = {}
    local cards = {}
    -- 找出我的位置
    local myIndex = 0
    for i = 1, data.player_count do
        cards[data.players[i].gid] = {}

        if data.players[i].gid == Me:queryBasic("gid") then
            myIndex = data.players[i].index
            playersInfo[2] = data.players[i] -- 自己固定是3号位置

            -- 把我的牌由id转换对应值
            for j = 1, data.players[i].card_num do
                table.insert( cards[data.players[i].gid], self:getCardValue(data.my_cards[j]) )
            end
        else
            for j = 1, data.players[i].card_num do
                table.insert( cards[data.players[i].gid], 10 )
            end
        end


    end

    -- 设置其他人位置
    for i = 1, data.player_count do
        if data.players[i].gid ~= Me:queryBasic("gid") then

            local dis = 2 - playersInfo[2].index
            local pos = data.players[i].index + dis
            if pos > 3 then pos = pos - 3 end
            if pos < 1 then pos = 3 - math.abs(pos) end
            playersInfo[pos] = data.players[i] -- 自己固定是3号位置
        end
    end

    data.playersInfo = playersInfo

    data.cards = cards


    return data
end

function ShiswgDlg:getPanelNumByIndex(index)
    if not self.data then return end
    for i = 1, PLAYER_MAX_COUNT do
        if self.data.playersInfo[i] and self.data.playersInfo[i].index == index then
            return i
        end
    end
end

-- 设置当前操作玩家光效
function ShiswgDlg:setCurOperEff(data)
    if data.cur_index <= 0 then
        for i = 1, PLAYER_MAX_COUNT do
            local playerPanel = self:getControl("PlayerPanel" .. i)
            local panel = self:getControl("HeadPanel", nil, playerPanel)
            local eff = panel:getChildByTag(999)
            if eff then eff:removeFromParent() end
        end
        return
    end

    local curPanelIndex = self:getPanelNumByIndex(data.cur_index)
    local playerPanel = self:getControl("PlayerPanel" .. curPanelIndex)
    local panel = self:getControl("HeadPanel", nil, playerPanel)
    if data.status == GAME_STATUS.RUNNING or data.status == GAME_STATUS.GM_OPER then
        -- 增加光效
        local magic = {}
        magic.name = ResMgr.ArmatureMagic.point_head_eff.name
        magic.action = "Bottom01"
        local isAdd = gf:createArmatureMagic(magic, panel, 999, 0, 0)
        -- 删除其他过期玩家光效
        for i = 1, PLAYER_MAX_COUNT do
            if i ~= curPanelIndex then
                local playerPanel = self:getControl("PlayerPanel" .. i)
                local panel = self:getControl("HeadPanel", nil, playerPanel)
                local eff = panel:getChildByTag(999)
                if eff then eff:removeFromParent() end
            end
        end
    else
        -- 删除光效
        for i = 1, 6 do
            local playerPanel = self:getControl("PlayerPanel" .. i)
            local panel = self:getControl("HeadPanel", nil, playerPanel)
            local eff = panel:getChildByTag(999)
            if eff then eff:removeFromParent() end
        end
    end
    --  point_head_eff      announcement_horn
end

function ShiswgDlg:isMyOpera()
    if not self.data then return false end
    return self:getPanelNumByIndex(self.data.cur_index) == 2
end

function ShiswgDlg:MSG_SUMMER_2019_SSWG_DATA(data)

    if GameMgr:isInBackground() then return end

    data = self:changeData(data)

    if data.show_type == 10 then
        self.data = data
    end

    -- 设置头像相关
    self:setPlayerInfo(data)
--[[
    -- 隐藏倒计时
    for i = 1, 3 do
        local curPanelNum = self:getPanelNumByIndex(data.cur_index)
        local panel = self:getControl("TimePanel", nil, "PlayerPanel" .. i)
  --      if i ~= curPanelNum then
            panel:setVisible(false)
    --    end
    end
--]]
    -- 操作玩家光效
    self:setCurOperEff(data)


    -- 由准备变为开始，分发基础牌
    if self.data and self.data.status == GAME_STATUS.PREPARE and data.status == GAME_STATUS.START then
        self:setCtrlVisible("WaitPanel", false)
        self.data = data

        for i = 1, 3 do
            local panel = self:getControl("PlayerPanel" .. i)
            local pokerPanel = self:setCtrlVisible("PokerPanel", true, panel)
            local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
            cardPanel:setVisible(true)
        end

        self:fapaiBasic()
        return
    end

    if data.status == GAME_STATUS.RUNNING then

        self:setCtrlVisible("StartButton", false)

        for i = 1, 3 do
            local panel = self:getControl("PlayerPanel" .. i)
            local pokerPanel = self:setCtrlVisible("PokerPanel", true, panel)
            local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
            cardPanel:setVisible(true)
        end

        self.data = data

        if data.show_type == 10 then
            -- 强制设置数据
            -- 设置
            self:setAllCardValue(true)

            -- 设置操作提示
            self:setNoteTips(data)

            self:startLeftTime(data)

            for i = 1, PLAYER_MAX_COUNT do
                local panel = self:getControl("PlayerPanel" .. i)
                self:setUnitPlayerInfo(data.playersInfo[i], panel, data.status)

                self:setCtrlVisible("OutImage", data.playersInfo[i].card_num == 0, panel)       -- 已爆
            end
            self.isPlayingAction = false
        elseif data.show_type == 5 and data.para ~= "" then -- 见前几排注释
            -- 演示抽排动画
            self.isPlayingAction = true

            self:showGetCardAction(data.para)
        else
            -- 设置
            self:setAllCardValue(true)

            -- 设置操作提示
            self:setNoteTips(data)

            self:startLeftTime(data)

            for i = 1, PLAYER_MAX_COUNT do
                local panel = self:getControl("PlayerPanel" .. i)
                --self:setUnitPlayerInfo(data.playersInfo[i], panel, data.status)

                self:setCtrlVisible("OutImage", data.playersInfo[i].card_num == 0, panel)       -- 已爆
            end

            self.isPlayingAction = false

        end
        return
    end

    self.data = data
end

function ShiswgDlg:MSG_SUMMER_2019_SSWG_BONUS(data)
    if DlgMgr:getDlgByName("ConfirmDlg") then
        DlgMgr:closeDlg("ConfirmDlg")
    end

    self:setCtrlVisible("ResultPanel", true)
    self:setCtrlVisible("CancelAutoButton", false)

    self:setCtrlVisible("EXPPanel", data.bonus_num ~= 0)
    self:setCtrlVisible("TaoPanel", data.bonus_num ~= 0)
    self:setCtrlVisible("TextLabel", data.bonus_num == 0)

    local panel = self:getControl("ResultPanel")

    self:setCtrlVisible("Image_3", data.result <= 2, panel)
    self:setCtrlVisible("Image_4", data.result <= 2, panel)

    self:setCtrlVisible("Image_5", data.result > 2, panel)
    self:setCtrlVisible("Image_6", data.result > 2, panel)

    if data["tao"] then
        self:setImagePlist("RewardImage", ResMgr.ui.daohang, "TaoPanel")
        self:setLabelText("NumLabel", gf:getTaoStr(tonumber(data["tao"])) .. CHS[5410102], "TaoPanel")
        self:setCtrlVisible("EXPPanel", false)
    end

    if data["exp"] then
        self:setImagePlist("RewardImage", ResMgr.ui.experience, "EXPPanel")
        self:setLabelText("NumLabel", data["exp"], "EXPPanel")
        self:setCtrlVisible("TaoPanel", false)
    end

    for i = 1, 3 do
        if data.rankInfo[i] then
            self:setLabelText("NameLabel", data.rankInfo[i], "IndexPanel_" .. i)
        else
            self:setLabelText("NameLabel", "", "IndexPanel_" .. i)
        end
    end
end

function ShiswgDlg:setNoteTips(data)
    local curPanelIndex = self:getPanelNumByIndex(data.cur_index)
    if curPanelIndex == 2 then
        local next_index = data.cur_index + 1
        if next_index == 4 then next_index = 1 end

        for i = 1, 3 do
            if data.players[i].index == next_index and data.players[i].card_num == 0 then
                next_index = next_index + 1
                if next_index == 4 then next_index = 1 end
            end
        end

        self:setCtrlVisible("NotePanel_1", false)
        self:setCtrlVisible("NotePanel_3", false)

        local nextNum = self:getPanelNumByIndex(next_index)
        self:setCtrlVisible("NotePanel_" .. nextNum, true)
    else
        self:setCtrlVisible("NotePanel_1", false)
        self:setCtrlVisible("NotePanel_3", false)
    end
end

function ShiswgDlg:MSG_MESSAGE_EX(data)
    if data["channel"] ~= CHAT_CHANNEL.CURRENT
        and data["channel"] ~= CHAT_CHANNEL.TEAM then
        -- 只有当前频道和队伍频道才弹冒泡
        return
    end

    for i = 1, 3 do
        local playerPanel = self:getControl("PlayerPanel" .. i)
        if playerPanel.playersInfo and playerPanel.playersInfo.is_online == 1 and playerPanel.gid == data.gid then
            self:showTips(data.msg, 3, playerPanel, data.show_extra, i)
        end
    end
end

function ShiswgDlg:generateTip(str, showExtra, pos)
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

    if pos > 2 then
        local dis = math.min( 30, layer:getContentSize().width * 0.5 )
        arrow:setPosition(layer:getContentSize().width, layer:getContentSize().height - 12)
        arrow:setRotation(-90)
    elseif pos == 2 then
        arrow:setPosition(layer:getContentSize().width * 0.5, 0)
    else
        local dis = math.min( 30, layer:getContentSize().width * 0.5 )
        arrow:setPosition(0, layer:getContentSize().height - 12)
        arrow:setRotation(90)
    end

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

-- 冒泡
function ShiswgDlg:showTips(msg, time, fPanel, showExtra, pos)
    local panel = self:getControl("HeadPanel", nil, fPanel)
    local size = panel:getContentSize()

    local bg = self:generateTip(msg, showExtra, pos)

    if pos > 2 then
  --      bg:setPosition(size.width - bg:getContentSize().width * 0.5, size.height + 10)
        bg:setPosition( -bg:getContentSize().width * 0.5 - 30, -bg:getContentSize().height + size.height)
    elseif pos == 2 then
        bg:setPosition(size.width * 0.5, size.height + 10)
    else
        bg:setPosition(bg:getContentSize().width * 0.5 + 30 + size.width, -bg:getContentSize().height + size.height)
    end

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

    local orgRect = self:getBoundingBoxInWorldSpace(panel)
    local x = orgRect.x
    local y = orgRect.y
    if pos > 2 then
  --      bg:setPosition(size.width - bg:getContentSize().width * 0.5, size.height + 10)
        bg:setPosition( x / Const.UI_SCALE - bg:getContentSize().width * 0.5 - 30, y / Const.UI_SCALE -bg:getContentSize().height + size.height)
    elseif pos == 2 then
        bg:setPosition(x / Const.UI_SCALE + size.width * 0.5, y / Const.UI_SCALE + size.height + 10)
    else
        bg:setPosition(x / Const.UI_SCALE + bg:getContentSize().width * 0.5 + 30 + size.width, y / Const.UI_SCALE - bg:getContentSize().height + size.height)
    end


    --cardImage:setPosition(orgRect.x / Const.UI_SCALE + CARD_WIDTH_HALF - self.winSize.ox, orgRect.y / Const.UI_SCALE + CARD_HEIGHT_HALF - self.winSize.oy * 2)
    self:getControl("FloatPanel"):addChild(bg, 2)

--    panel:addChild(bg)

    if #self.chatContent == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local node = self.chatContent[1]
        local newAction = cc.MoveBy:create(0.2, cc.p(0, node:getContentSize().height + 5))
        --local node = self.chatContent[1]
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

return ShiswgDlg
