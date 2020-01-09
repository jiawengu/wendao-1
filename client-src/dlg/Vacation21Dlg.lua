-- Vacation21Dlg.lua
-- Created by
--

local Vacation21Dlg = Singleton("Vacation21Dlg", Dialog)


local NPC_ICON = 20018

local MARGIN = 25
local MARGIN_EX = 66 -- 60 + 6

local POKER_RES = {
    [0] = ResMgr.ui.poker_back,
    [1] = ResMgr.ui.poker_1,
    [2] = ResMgr.ui.poker_2,
    [3] = ResMgr.ui.poker_3,
    [4] = ResMgr.ui.poker_4,
    [5] = ResMgr.ui.poker_5,
    [6] = ResMgr.ui.poker_6,
    [7] = ResMgr.ui.poker_7,
    [8] = ResMgr.ui.poker_8,
    [9] = ResMgr.ui.poker_9,
    [10] = ResMgr.ui.poker_10,
}

-- 头顶冒泡相关
local HEIGHT_MARGIN = 10
local WIDTH_MARGIN = 12
local BACK_WIDTH = 600
local GENERAL_WIDTH = 166

local GAME_STATUS = {
    PREPARE         = "prepare",            -- 准备阶段
    START           = "start",              -- 第一次发牌动画播放阶段
    RUNNING         = "running",            -- 玩家开始操作阶段
    GM_OPER         = "gm_oper",            -- 庄家操作动画阶段
    END             = "end",                -- 游戏结算并且结束阶段
}

function Vacation21Dlg:init()
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("PlusButton", self.onPlusButton)
    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ChatButton", self.onChatButton)

    self:setValidClickTime("StopButton", 700, "")
    self:setValidClickTime("PlusButton", 700, "")

    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_1")
    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_2")

    self:bindFloatPanelListener("RulePanel")

    self:setCtrlFullClientEx("BackPanel", "GameResultPanel")
    self:setCtrlFullClientEx("BKPanel", nil, true)

    -- 是否在发牌动画中
    self.isActioning = {}
    self.chatContent = {}
    self.totalCard = 0
    self.lastOpTime = 0

    self.msgList = {}

    self:initDisplay()

    self:hookMsg("MSG_MESSAGE_EX")
    self:hookMsg("MSG_WINTER_2019_BX21D_DATA")
    self:hookMsg("MSG_WINTER_2019_BX21D_BONUS")
end

function Vacation21Dlg:setIconAndName(data, panel)
    if data then
        -- 头像
        self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), panel)

        -- 名字
        self:setLabelText("NameLabel", data.name, panel)

        -- 玩家离队
        self:setCtrlEnabled("IconImage", data.is_online == 1, panel)

    else
        -- 头像
        self:setImage("IconImage", ResMgr.ui.fish_default_portrait, panel)

        -- 名字
        self:setLabelText("NameLabel", "", panel)
    end
end

--  初始化界面显示
function Vacation21Dlg:initDisplay(data)
    self.totalCard = 0

    for i = 1, 6 do
        -- 隐藏牌
        self:setCtrlVisible("PokerPanel" .. i, false)
        local pokerPanel = self:getControl("PokerPanel" .. i)
        if pokerPanel then
            pokerPanel.cardNum = 0
            pokerPanel.cardValue = {}
            local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
            cardPanel:removeAllChildren()

            self:setCtrlVisible("OutImage", false, pokerPanel)
        end

        self:setIconAndName(nil, playerPanel)

        -- 准备中
        self:setCtrlVisible("ReadyLabel", true, playerPanel)    -- 准备中
        self:setCtrlVisible("OKImage", false, playerPanel)    -- OK图片

        -- 倒计时
        self:setCtrlVisible("TimePanel" .. i, false)
    end

    -- 球球头像
    self:setImage("IconImage", ResMgr:getSmallPortrait(NPC_ICON), "PlayerPanel6")
    self:setCtrlVisible("OKImage", true, "PlayerPanel6")    -- OK图片

    -- 开始按钮
    if data and data.players_info[3].prepared == 1 then
        self:setCtrlVisible("StartButton", false)
    else
        self:setCtrlVisible("StartButton", true)
    end

    -- 停牌要牌
    self:setCtrlVisible("PlusButton", false)
    self:setCtrlVisible("StopButton", false)

    -- 自己、庄家说明
    self:setCtrlVisible("FunctionPanel", false)
    self:setCtrlVisible("BankerPanel", false)

    self:setLabelText("NumLabel", "", "FunctionPanel")
    self:setLabelText("NumLabel", "", "BankerPanel")
    self:setLabelText("NoticeLabel", "", "FunctionPanel")

    self:setCtrlVisible("GameResultPanel", false)
end


function Vacation21Dlg:setDate(data)

    self:setCtrlVisible("FunctionPanel", data.status ~= GAME_STATUS.PREPARE)
    self:setCtrlVisible("BankerPanel", data.status ~= GAME_STATUS.PREPARE)

    local myInfo = data.players_info[3]

    self:setCtrlVisible("OKImage", data.status == GAME_STATUS.PREPARE, "PlayerPanel6")    -- OK图片

    local curInfo = {}
    local oneNum = 0
    for i = 1, 5 do
        local playerPanel = self:getControl("PlayerPanel" .. i)
        local uData = data.players_info[i]

        playerPanel.playerData = uData
        if uData and uData.index == 1 then
            oneNum = i
        end

        -- 设置名字和头像
        self:setIconAndName(uData, playerPanel)

        -- 准备状态
        if not uData or data.status ~= GAME_STATUS.PREPARE or uData.is_online == 0 then
            self:setCtrlVisible("OKImage", false, playerPanel)
            self:setCtrlVisible("ReadyLabel", false, playerPanel)
        else
            self:setCtrlVisible("OKImage", uData.prepared == 1, playerPanel)
            self:setCtrlVisible("ReadyLabel", uData.prepared == 0, playerPanel)
        end
    end

    local index = 0
    for i = oneNum, oneNum + 4 do
        local num = i > 5 and  (i - 5) or i
        local playerPanel = self:getControl("PlayerPanel" .. num)
        -- 设置头像右上角的数字
        index = index + 1
        local numImage = self:getControl("NumImage", nil, playerPanel)
        self:setLabelText("NumLabel", index, numImage)
    end
end

-- 自己、庄家说明。这个用于没有牌变化时直接调用
function Vacation21Dlg:setFunction(data)
    if data.status ~= GAME_STATUS.PREPARE  then
        -- 获取当前操作的玩家
        local curInfo = {}
        for i = 1, 5 do
            local uData = data.players_info[i]
            if uData and uData.index == data.cur_index then
                curInfo = uData
            end
        end

        local myInfo = data.players_info[3]

        -- 设置右下角的功能
        self:setCtrlVisible("PlusButton", data.cur_index == myInfo.index)
        self:setCtrlVisible("StopButton", data.cur_index == myInfo.index)
        if data.cur_index == myInfo.index or not curInfo.name then
            self:setLabelText("NoticeLabel", "", "FunctionPanel")
        else
            self:setLabelText("NoticeLabel", string.format(CHS[4101186],  curInfo.name), "FunctionPanel")
        end

        local point = myInfo.final_total ~= 0 and myInfo.final_total or self:getPointStr(myInfo.cardValue)

        if myInfo.final_total ~= 0 then
            self:setLabelText("NumLabel", string.format(CHS[4101185],  point), "FunctionPanel")
        else
            self:setLabelText("NumLabel", string.format(CHS[4101179],  point), "FunctionPanel")
        end
    else
        self:setCtrlVisible("FunctionPanel", false)
        self:setCtrlVisible("BankerPanel", false)
    end

    local bossPoint = data.boss_final_total ~= 0 and data.boss_final_total or self:getPointStr(data.bossCardValue)
    if data.boss_final_total ~= 0 then
        self:setLabelText("NumLabel", string.format(CHS[4101184],  bossPoint), "BankerPanel")
    else
        if data.boss_card_num <= 2 then
            if self:getCardValue(data.boss_card_id[1]) == 1 then
                self:setLabelText("NumLabel", string.format(CHS[4101181],  CHS[4101183]), "BankerPanel")
            else
                self:setLabelText("NumLabel", string.format(CHS[4101181] .. " + ？",  bossPoint), "BankerPanel")
            end
        else
            self:setLabelText("NumLabel", string.format(CHS[4101182],  bossPoint), "BankerPanel")
        end
    end
end

-- 设置当前操作玩家光效
function Vacation21Dlg:setCutOperEff(data)
    if data.cur_index <= 0 then
        for i = 1, 6 do
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
    if data.status ~= GAME_STATUS.RUNNING or data.status ~= GAME_STATUS.GM_OPER then
        -- 增加光效
        local magic = {}
        if curPanelIndex == 6 then
            magic.name = ResMgr.ArmatureMagic.point_head_eff.name
            magic.action = "Bottom02"
        else
            magic.name = ResMgr.ArmatureMagic.point_head_eff.name
            magic.action = "Bottom01"
        end
        local isAdd = gf:createArmatureMagic(magic, panel, 999, 0, 0)
        -- 删除其他过期玩家光效
        for i = 1, 6 do
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

-- 获取点数
function Vacation21Dlg:getPointStr(pointVaue)
    if not pointVaue then return "" end

    local basic = 0 -- 固定值
    local spCount = 0 -- 特殊牌的个数

    for i = 1, #pointVaue do
        if pointVaue[i] ~= 1 then
            basic = basic + pointVaue[i]
        else
            spCount = spCount + 1
        end
    end

    if spCount == 2 then
        -- 爆了，不管
        if basic + 2 > 21 then
            return ""
        end

        if basic + 12 > 21 then
            return tostring(basic + 2)
        end

        return string.format( CHS[4101187], (basic + 12), (basic + 2) )
    elseif spCount == 3 then
        -- 爆了，不管
        if basic + 3 > 21 then
            return ""
        end

        if basic + 13 > 21 then
            return tostring(basic + 3)
        end
        return string.format( CHS[4101187], (basic + 13), (basic + 3) )
    elseif spCount == 4 then
        -- 爆了，不管
        if basic + 4 > 21 then
            return ""
        end

        if basic + 14 > 21 then
            return tostring(basic + 4)
        end

        return string.format( CHS[4101187], (basic + 14), (basic + 4) )
    elseif spCount <= 1 then
        if spCount == 0 then
            return tostring(basic)
        end

        if basic + 1 > 21 then
            return ""
        end

        if basic + 11 >= 21 and #pointVaue > 2 then
            -- 赢了，不用关
            return tostring(basic + 1)
        else
            return string.format( CHS[4101187], (basic + 11), (basic + 1) )
        end
    end

end

function Vacation21Dlg:getPlayerCount(data)
    local effCount = 0
    for i = 1, 6 do
        if data.players_info[i] and data.players_info[i].is_online == 1 then
            effCount = effCount + 1
        end
    end

    -- 加上球球
    return effCount + 1
end

-- 发牌动画
function Vacation21Dlg:fapaiAction(destNum, cardValue, data)
    -- 发牌动作正在进行，关闭界面
    if self.isActioning[destNum] then return end

    local mainPanel = self:getControl("MainPanel")

    -- 创建一张盖的牌
    local backImage = ccui.ImageView:create(ResMgr.ui.poker_back)
    local backCard = self:getControl("CardBackImage")

    local rect = self:getBoundingBoxInWorldSpace(backCard)
    local destCardPanel = self:getControl("PokerPanel" .. destNum)

    backImage:setPosition(mainPanel:getContentSize().width * 0.5, mainPanel:getContentSize().height * 0.5)
    mainPanel:addChild(backImage)

    -- 获取目标位置
    local destX, dextY = self:getDestPosByIndex(destNum)

    -- 动作效果
    local arrangeAct = cc.CallFunc:create(function()
        self:arrangeCard(destNum)
    end)

    local rotationAct = cc.RotateBy:create(0.5, 720)
    local moveAct = cc.MoveTo:create(0.5, cc.p(destX, dextY))
    local spawnAct = cc.Spawn:create(rotationAct, moveAct, arrangeAct)

    -- 动作效果结束了
    local callBack = cc.CallFunc:create(function()
        self.isActioning[destNum] = false
        backImage:removeFromParent()
        local haveCardNum = self:addCard(destNum, cardValue)

        self.totalCard = self.totalCard + 1
        if self.data and self.totalCard == self:getPlayerCount(self.data) * 2 then
            -- 基础牌发好了
            gf:CmdToServer("CMD_WINTER_2019_BX21D_ACTION_END", {status = GAME_STATUS.START})
            self:toDoNextMsg()
        end

        if not data then
            local point = self:getPointStr(destCardPanel.cardValue)
            self:setLabelText("NumLabel", string.format( CHS[4101179],  point), destCardPanel)

            if destNum == 3 then
                self:setLabelText("NumLabel", string.format(CHS[4101179],  point), "FunctionPanel")
            end
        end

        -- 正常发牌结束后，设置功能，和当前点数
        if data and data.players_info[destNum] and data.players_info[destNum].final_total == 0 then
            self:setFunction(data)
        end

        -- 爆牌,玩家
        if data and data.players_info[destNum] and data.players_info[destNum].final_total > 21 then
            self:setCtrlVisible("OutImage", true, destCardPanel)
        end

        if data and data.players_info[destNum] then
            local point = data.players_info[destNum].final_total ~= 0 and data.players_info[destNum].final_total or self:getPointStr(destCardPanel.cardValue)
            if data.players_info[destNum].final_total ~= 0 then
                self:setLabelText("NumLabel", string.format( CHS[4101185],  point), destCardPanel)
            else
                self:setLabelText("NumLabel", string.format( CHS[4101179],  point), destCardPanel)
            end
        end

        -- boss
       -- local bossPoint = data.boss_final_total ~= 0 and data.boss_final_total or self:getPointStr(data.bossCardValue)
        if destNum == 6 then
            local bossPoint = self:getPointStr(destCardPanel.cardValue)
            if data and haveCardNum == data.boss_card_num then
                if data.boss_final_total ~= 0 then
                    self:setLabelText("NumLabel", string.format(CHS[4101180], data.boss_final_total), "BankerPanel")
                else
                    self:setLabelText("NumLabel", string.format(CHS[4101180], bossPoint), "BankerPanel")
                end
            else

                if haveCardNum <= 2 then
                    if destCardPanel.cardValue[1] == 1 then
                        self:setLabelText("NumLabel", string.format(CHS[4101181],  CHS[4101183]), "BankerPanel")
                    else
                        self:setLabelText("NumLabel", string.format(CHS[4101181] .. " + ？",  bossPoint), "BankerPanel")
                    end
                else
                    self:setLabelText("NumLabel", string.format(CHS[4101182],  bossPoint), "BankerPanel")
                end
            end

            if data and data.boss_final_total > 21 and destNum == 6 and haveCardNum == data.boss_card_num then
                self:setCtrlVisible("OutImage", true, destCardPanel)
            end
        end

        -- 告诉服务器，GM的播放完了
        if data and destNum == 6 and haveCardNum == data.boss_card_num then
            gf:CmdToServer("CMD_WINTER_2019_BX21D_ACTION_END", {status = GAME_STATUS.GM_OPER})
        end

        -- 倒计时
        self:startLeftTime(data)

        if data then
            -- 该消息执行完，下一条
            self:toDoNextMsg()
        end
    end)

    self.isActioning[destNum] = true

    backImage:runAction(cc.Sequence:create(spawnAct, cc.DelayTime:create(0.2), callBack))
end

function Vacation21Dlg:startLeftTime(data)
    if data and data.status == GAME_STATUS.RUNNING then
        self.leftTime = math.min( data.remain_ti, gf:getServerTime() + 20)
        self.leftTimeOp = data.cur_index
    else
       self.leftTime = false
        self.leftTimeOp = false
       self:setLeftTime({})
    end
end

-- 整理牌面
function Vacation21Dlg:arrangeCard(destNum, newData)
    if destNum > 3 and destNum ~= 6 then
        -- 大于3的需要先移位置
        local pokerPanel = self:getControl("PokerPanel" .. destNum)
        local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
        local cardNum = pokerPanel.cardNum + 1
        for i = 1, cardNum do
            local image = cardPanel:getChildByTag(i)
            if image then
                local x = cardPanel:getContentSize().width - image:getContentSize().width * 0.5 - (cardNum - i) * MARGIN
                image:setPosition(x, image:getContentSize().height * 0.5)
            end
        end
    elseif destNum == 6 then
        local pokerPanel = self:getControl("PokerPanel" .. destNum)
        local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
        local cardNum = pokerPanel.cardNum + 1
        for i = 1, cardNum do
            local image = cardPanel:getChildByTag(i)
            if image then
                local data = newData or self.data
                local cardValue = data.bossCardValue[i] or pokerPanel.cardValue[i]
                image:loadTexture(POKER_RES[cardValue])
            end
        end
    end
end

-- 增加一张牌
function Vacation21Dlg:addCard(destNum, cardValue)
    local pokerPanel = self:getControl("PokerPanel" .. destNum)
    pokerPanel.cardNum = pokerPanel.cardNum + 1
    table.insert( pokerPanel.cardValue, cardValue )

    pokerPanel:setVisible(true)

    local cardPanel = self:getControl("CardPanel", nil, pokerPanel)
    local pokerCard = ccui.ImageView:create(POKER_RES[cardValue])

    pokerCard:setTag(pokerPanel.cardNum)
    cardPanel:addChild(pokerCard)

    -- 排序下，由于中间、右边对齐方式不一样，所以要调整
    if destNum < 3 then
        for i = 1, pokerPanel.cardNum do
            local image = cardPanel:getChildByTag(i)
            image:setPosition(image:getContentSize().width * 0.5 + (i - 1) * MARGIN, image:getContentSize().height * 0.5)
        end
    elseif destNum == 3 or destNum == 6 then
        if pokerPanel.cardNum <= 6 then
            for i = 1, pokerPanel.cardNum do
                local image = cardPanel:getChildByTag(i)
                image:setPosition(image:getContentSize().width * 0.5 + (i - 1) * MARGIN_EX + 1, image:getContentSize().height * 0.5)
            end
        else
            for i = 1, pokerPanel.cardNum do
                local image = cardPanel:getChildByTag(i)
                image:setPosition(image:getContentSize().width * 0.5 + (i - 1) * MARGIN, image:getContentSize().height * 0.5)
            end
        end

        -- 如果当前是第6张，集体靠前
        if pokerPanel.cardNum == 6 then
            for i = 1, pokerPanel.cardNum do
                local image = cardPanel:getChildByTag(i)
                local x = image:getContentSize().width * 0.5 + (i - 1) * MARGIN
                local y = image:getContentSize().height * 0.5
                local moveAct = cc.MoveTo:create(0.1, cc.p(x, y))
                image:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), moveAct))
            end
        end
    else
        for i = 1, pokerPanel.cardNum do
            local image = cardPanel:getChildByTag(i)
            local x = cardPanel:getContentSize().width - image:getContentSize().width * 0.5 - (pokerPanel.cardNum - i) * MARGIN
            image:setPosition(x, image:getContentSize().height * 0.5)
        end
    end

    return pokerPanel.cardNum
end

function Vacation21Dlg:getDestPosByIndex(index)
    local panel = self:getControl("PokerPanel" .. index)
    local cardNum = panel.cardNum       -- 已有的牌数

    local backImage = ccui.ImageView:create(ResMgr.ui.poker_back)

    local cardPanel = self:getControl("CardPanel", nil, panel)
    local rect = self:getBoundingBoxInWorldSpace(cardPanel)
    local x, y
    if index < 3 then
        -- 左边要靠左
        x = rect.x + backImage:getContentSize().width * 0.5 + cardNum * MARGIN
    elseif index == 3 or index == 6 then
        -- 中间超过 5 张要堆叠
        if cardNum >= 6 then
            x = rect.x + backImage:getContentSize().width * 0.5 + cardNum * MARGIN - 1
        else
            x = rect.x + backImage:getContentSize().width * 0.5 + cardNum * MARGIN_EX
        end
        x = x + 1
    else
        -- 右边要靠右
        x = rect.x + rect.width - backImage:getContentSize().width * 0.5
    end
    y = rect.y + backImage:getContentSize().height * 0.5

    local winsize = DeviceMgr:getUIScale() or { width = Const.WINSIZE.width / Const.UI_SCALE, height = Const.WINSIZE.height / Const.UI_SCALE, x = 0, y = 0, ox = 0, oy = 0 }

  --  x = x - 6
    x = x - winsize.ox - (winsize.width - self.root:getContentSize().width) * 0.5
    y = y - winsize.oy

    if winsize.oy and winsize.oy ~= 0 then y = y + 1 end
    return x, y
end

function Vacation21Dlg:onStopButton(sender, eventType)
    if gfGetTickCount() - self.lastOpTime < 800 then
        return
    end

    self.lastOpTime = gfGetTickCount()

    -- 停牌
    self:startLeftTime()
    gf:CmdToServer("CMD_WINTER_2019_BX21D_OPER", {oper = 2})
end

function Vacation21Dlg:onPlusButton(sender, eventType)
    if gfGetTickCount() - self.lastOpTime < 800 then
        return
    end

    self.lastOpTime = gfGetTickCount()

    -- 抽牌
    self:startLeftTime()
    gf:CmdToServer("CMD_WINTER_2019_BX21D_OPER", {oper = 1})
end

function Vacation21Dlg:onPauseButton(sender, eventType)

    if not self.data or self.data.status == GAME_STATUS.PREPARE then
        gf:confirmEx(CHS[4101188], CHS[4101190],   function ( )
            -- body
            self:onCloseButton()
            ActivityMgr:MSG_WINTER_2019_BX21D_ENTER()
        end, CHS[4101191])
        return
    end

    gf:confirmEx(CHS[4101189], CHS[4101190],   function ( )
        -- body
        self:onCloseButton()
        ActivityMgr:MSG_WINTER_2019_BX21D_ENTER()
    end, CHS[4101191])
end

function Vacation21Dlg:onInfoButton(sender, eventType)
	--self:setCtrlVisible("GameResultPanel", true)


    --self:fapaiAction(3, 0)
    self:setCtrlVisible("RulePanel", true)
end

function Vacation21Dlg:onStartButton(sender, eventType)
    gf:CmdToServer("CMD_WINTER_2019_BX21D_PREPARE")
    self:setCtrlVisible("StartButton", false)
end

function Vacation21Dlg:onChatButton(sender, eventType)
    DlgMgr:closeDlg("ChannelDlg")
    DlgMgr:sendMsg("ChatDlg", "onChatButton")
end

function Vacation21Dlg:MSG_MESSAGE_EX(data)
    if data["channel"] ~= CHAT_CHANNEL.CURRENT
        and data["channel"] ~= CHAT_CHANNEL.TEAM then
        -- 只有当前频道和队伍频道才弹冒泡
        return
    end

    for i = 1, 5 do
        local playerPanel = self:getControl("PlayerPanel" .. i)
        if playerPanel.playerData and playerPanel.playerData.is_online == 1 and playerPanel.playerData.gid == data.gid then
            self:showTips(data.msg, 3, playerPanel, data.show_extra, i)
        end
    end
end

-- 冒泡
function Vacation21Dlg:showTips(msg, time, fPanel, showExtra, pos)
    local panel = self:getControl("HeadPanel", nil, fPanel)
    local size = panel:getContentSize()

    local bg = self:generateTip(msg, showExtra, pos)

    if pos > 3 then
        bg:setPosition(size.width - bg:getContentSize().width * 0.5, size.height + 10)
    elseif pos == 3 then
        bg:setPosition(size.width * 0.5, size.height + 10)
    else
        bg:setPosition(bg:getContentSize().width * 0.5, size.height + 10)
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

function Vacation21Dlg:generateTip(str, showExtra, pos)
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

    if pos > 3 then
        local dis = math.min( 30, layer:getContentSize().width * 0.5 )
        arrow:setPosition(layer:getContentSize().width - dis, 0)
    elseif pos == 3 then
        arrow:setPosition(layer:getContentSize().width * 0.5, 0)
    else
        local dis = math.min( 30, layer:getContentSize().width * 0.5 )
        arrow:setPosition(dis, 0)
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

function Vacation21Dlg:cleanup()
    if not self.data then
        gf:CmdToServer("CMD_WINTER_2019_BX21D_QUIT", {status = GAME_STATUS.PREPARE})
        return
    end
    gf:CmdToServer("CMD_WINTER_2019_BX21D_QUIT", {status = self.data.status})
end

-- 通过id转换为对应的牌
function Vacation21Dlg:getCardValue(cardId)
    if cardId == 0 then
        return 0
    elseif cardId <= 36 then
        return math.floor((cardId - 1) / 4) + 1
    else
        return 10
    end
end

function Vacation21Dlg:changeData(data)
    local playersInfo = {}

    -- 找出我的位置
    local myIndex = 0
    for i = 1, data.player_count do
        if data.players_info[i].gid == Me:queryBasic("gid") then
            myIndex = data.players_info[i].index
            playersInfo[3] = data.players_info[i] -- 自己固定是3号位置
            playersInfo[3].cardValue = {}
            for i = 1, playersInfo[3].card_num do
                playersInfo[3].cardValue[i] = self:getCardValue(playersInfo[3].card_id[i])
            end
        end
    end

    -- 设置其他人位置
    for i = 1, data.player_count do
        if data.players_info[i].gid ~= Me:queryBasic("gid") then

            local dis = 3 - playersInfo[3].index
            local pos = data.players_info[i].index + dis
            if pos > 5 then pos = pos - 5 end
            if pos < 1 then pos = 5 - math.abs(pos) end
            playersInfo[pos] = data.players_info[i] -- 自己固定是3号位置

            playersInfo[pos].cardValue = {}
            for i = 1, playersInfo[pos].card_num do
                playersInfo[pos].cardValue[i] = self:getCardValue(playersInfo[pos].card_id[i])
            end

        end
    end

    -- boss
    data.bossCardValue = {}
    for i = 1, data.boss_card_num do
        data.bossCardValue[i] = self:getCardValue(data.boss_card_id[i])
    end

    data.players_info = playersInfo
    return data
end

-- 分发基础牌
function Vacation21Dlg:fapaiBasic(data)
    local order = 0
    for i = 1, 2 do
        for j = 1, 6 do
            local destNum = self:getPanelNumByIndex(j)
                -- body
                if destNum == 6 then
                    order = order + 1
                    performWithDelay(self.root, function ( )
                        self:fapaiAction(6, data.bossCardValue[i])
                    end, 1 * (order - 1))

                else

                    if data.players_info[destNum] and data.players_info[destNum].is_online == 1 then
                        order = order + 1
                        performWithDelay(self.root, function ( )
                            self:fapaiAction(destNum, data.players_info[destNum].cardValue[i])
                        end, 1 * (order - 1))
                    end
                end

        end

    end
end

-- 玩家要牌
function Vacation21Dlg:getCard(oldData, newData)
    local order = 0
    local curIndex = 0
    -- 与旧数据对比，发牌
    ---- 玩家
    for i = 1, 5 do
        if oldData.players_info[i] then
            if oldData.players_info[i].card_num ~= newData.players_info[i].card_num then
                for j = oldData.players_info[i].card_num + 1, newData.players_info[i].card_num do
                    order = order + 1
                    curIndex = i
                    performWithDelay(self.root, function ( )
                        -- body
                        self:fapaiAction(i, newData.players_info[i].cardValue[j], newData)
                    end, 1 * (order - 1))
                end
            end
        end
    end
    ---- 庄家
    if oldData.boss_card_num ~= newData.boss_card_num then
        for j = oldData.boss_card_num + 1, newData.boss_card_num do
            order = order + 1
            curIndex = 6
            performWithDelay(self.root, function ( )
                -- body
                self:fapaiAction(6, newData.bossCardValue[j], newData)
            end, 1.2 * (order - 1))
       --     self:setFunction(newData)
        end
    elseif newData.status == GAME_STATUS.GM_OPER then
        self:arrangeCard(6, newData)
        gf:CmdToServer("CMD_WINTER_2019_BX21D_ACTION_END", {status = GAME_STATUS.GM_OPER})
    end

    if curIndex == 0 then
        -- 牌面没有变化要直接刷新功能提示
        self:setFunction(newData)

        -- 倒计时
        self:startLeftTime(newData)

        self:toDoNextMsg()
    elseif curIndex ~= 6 and newData.players_info[curIndex].final_total ~= 0 then
        -- 爆了直接设置
        self:setFunction(newData)
    end
end

function Vacation21Dlg:removeFristMsg()
    table.remove(self.msgList, 1)
end

function Vacation21Dlg:toDoNextMsg()
    self:removeFristMsg()

    if next(self.msgList) then
        local msgInfo = self.msgList[1]
        self[msgInfo.name](self, msgInfo.data)
    end
end

function Vacation21Dlg:setFinalScore(data)
    for i = 1, 5 do
        if data.players_info[i] and data.players_info[i].final_total ~= 0 and data.cur_index > data.players_info[i].index then
            local panelNum = self:getPanelNumByIndex(data.players_info[i].index)
            local destCardPanel = self:getControl("PokerPanel" .. panelNum)
            self:setLabelText("NumLabel", string.format( CHS[4101185],  data.players_info[i].final_total), destCardPanel)
        end
    end


    local myInfo = data.players_info[3]


    -- 设置右下角的功能
    self:setCtrlVisible("PlusButton", data.cur_index == myInfo.index and data.status == GAME_STATUS.RUNNING)
    self:setCtrlVisible("StopButton", data.cur_index == myInfo.index and data.status == GAME_STATUS.RUNNING)

    if data.cur_index == 6 then
        self:setLabelText("NoticeLabel", "", "FunctionPanel")
    end
end

function Vacation21Dlg:MSG_WINTER_2019_BX21D_DATA_CLIENT(data, isFace)

    data = self:changeData(data)

    self:setFinalScore(data)

    -- 操作玩家光效
    self:setCutOperEff(data)

    -- 准备
    if data.status == GAME_STATUS.PREPARE then
        self.data = data
        self:initDisplay(data)
        self:setDate(data)
        self:toDoNextMsg()
        return
    end

    -- 结束
    if data.status == GAME_STATUS.END then
        self.data = data
        self:setDate(data)
        self:toDoNextMsg()
        return
    end

    self:setDate(data)

    -- 分发基础牌
    if self.data and self.data.status == GAME_STATUS.PREPARE and data.status == GAME_STATUS.START then
        self.data = data
        self:fapaiBasic(data)
        return
    end

    -- 与旧数据对比，要牌
    if self.data and data.status == GAME_STATUS.RUNNING or data.status == GAME_STATUS.GM_OPER then
        self:getCard(self.data, data)
        self.data = data
        return
    end

    self.data = data
end

function Vacation21Dlg:addMsg(data, msgName)
    table.insert(self.msgList, {name = msgName, data = data})

    if  #self.msgList == 1 then
        self[msgName](self, data)
    end
end

function Vacation21Dlg:MSG_WINTER_2019_BX21D_DATA(data, isFace)
    self:addMsg(data, "MSG_WINTER_2019_BX21D_DATA_CLIENT")
end

-- 设置倒计时
function Vacation21Dlg:onUpdate()
    if not self.leftTime then return end

    if self.data.status ~= GAME_STATUS.RUNNING then
        self:setLeftTime({})
        return
    end

    self:setLeftTime(self.data)
end


function Vacation21Dlg:getPanelNumByIndex(index)
    if not self.data then return end
    if index == 6 then
        return 6
    else
        for i = 1, 5 do
            if self.data.players_info[i] and self.data.players_info[i].index == index then
                return i
            end
        end
    end
end

-- 设置倒计时
function Vacation21Dlg:setLeftTime(data)
    for i = 1, 5 do
        local panel = self:getControl("TimePanel" .. i)
        local curPanelNum = self:getPanelNumByIndex(data.cur_index)
        if i ~= curPanelNum then
            panel:setVisible(false)
        else
            panel:setVisible(true)
            local lefeTime = self.leftTime - gf:getServerTime()
            lefeTime = math.max(0,  lefeTime)

            local numImg = self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.B_FIGHT, lefeTime, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
            numImg:setScale(0.25, 0.25)
            if lefeTime <= 0 and i == 3 and self:getPanelNumByIndex(self.leftTimeOp) == 3 then
                self:onStopButton()
            end

            if lefeTime <= 0 then
                lefeTime = nil
            end
        end
    end
end

-- 点击继续
function Vacation21Dlg:onCloseImage(sender, eventType)
    -- 抽牌
    gf:CmdToServer("CMD_WINTER_2019_BX21D_CONTINUE")
end

function Vacation21Dlg:MSG_WINTER_2019_BX21D_BONUS_CLIENT(data)

    if DlgMgr:getDlgByName("ConfirmDlg") then
        DlgMgr:closeDlg("ConfirmDlg")
    end

    self:setCtrlVisible("GameResultPanel", true)
    self:setCtrlVisible("ResultPanel_1", data.bonus_num ~= 0)
    self:setCtrlVisible("ResultPanel_2", data.bonus_num == 0)

    local function setResult(data, panel)
        -- body
        self:setCtrlVisible("Image_3_1", data.flag == 1, panel)
        self:setCtrlVisible("Image_3_2", data.flag == 0, panel)
        self:setCtrlVisible("Image_3_3_1", data.flag == 2, panel)
        self:setCtrlVisible("Image_3_3_2", data.flag == 2, panel)
    end

    if data.bonus_num ~= 0 then
        self:setCtrlVisible("ScorePanel", false)
        self:setCtrlVisible("ScorePanel2", true)

        local panel = self:getControl("TaoPanel", nil, "ScorePanel2")
        if data["tao"] then
            self:setImagePlist("RewardImage", ResMgr.ui.daohang, panel)
            self:setLabelText("NumLabel", gf:getTaoStr(tonumber(data["tao"])) .. CHS[5410102], panel)
        else
            self:setImagePlist("RewardImage", ResMgr.ui.experience, panel)
            self:setLabelText("NumLabel", data["exp"], panel)
        end


        local itemPanel = self:getControl("ItemPanel", nil, "ScorePanel2")
        if data["item"] then
            self:setLabelText("NumLabel", data["item"], itemPanel)
        else
            self:setLabelText("NumLabel", CHS[5000059], itemPanel)
        end

        setResult(data, "ResultPanel_1")
    else
        setResult(data, "ResultPanel_2")
    end

    self:toDoNextMsg()
end

function Vacation21Dlg:MSG_WINTER_2019_BX21D_BONUS(data, isFace)

    self:addMsg(data, "MSG_WINTER_2019_BX21D_BONUS_CLIENT")
end




return Vacation21Dlg
