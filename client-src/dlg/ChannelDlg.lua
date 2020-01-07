-- ChannelDlg.lua
-- Created by zhengjh Feb/11/2015
-- 频道聊天


local CHANNEL_CONFIG =
{      CurrentCheckBox = {"currentChatData",  CHAT_CHANNEL["CURRENT"]},
       WorldCheckBox =  {"worldChatData", CHAT_CHANNEL["WORLD"]} ,
       PartyCheckBox = {"partyChatData", CHAT_CHANNEL["PARTY"]} ,
       TeamCheckBox = {"teamChatData", CHAT_CHANNEL["TEAM"]} ,
       SystemCheckBox = {"systemChatData", CHAT_CHANNEL["SYSTEM"]},
       RumorCheckBox = {"rumorChatData", CHAT_CHANNEL["RUMOR"]},
       MiscCheckBox = {"miscChatData", CHAT_CHANNEL["MISC"]},
       AdnoticeCheckBox = {"adnoticeChatData", CHAT_CHANNEL["ADNOTICE"]},
}

local LAST_SENDTIME =
{
        WorldCheckBox =  0,
        PartyCheckBox = 0,
        TeamCheckBox = 0,
        SystemCheckBox = 0,
}

-- 喇叭喊话提示显示时长
local HORN_POP_SHOW_TIME = 12


local SingleChatPanel = require("ctrl/SingleChatPanel")
local ChannelDlg = Singleton("ChannelDlg",Dialog)
local RadioGroup = require("ctrl/RadioGroup")
function ChannelDlg:init()
    self:setFullScreen()
    self:bindListener("CloseButton", self.onCloseButton_2)
    self:bindListViewListener("SystemListView", self.onSelectSystemListView)
    self:bindListener("FriendDlgButton", self.onFriedButton)

    self:bindListener("InfoPanel", self.onHornPanel, "HornPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"CurrentCheckBox","WorldCheckBox", "PartyCheckBox", "TeamCheckBox", "SystemCheckBox", "RumorCheckBox", "MiscCheckBox", "AdnoticeCheckBox"}, self.onChannelButton)

    -- 调整屏幕分辨率适配
    self.list =  self:getControl("SystemPanel")
    self.list:removeAllChildren()
    local btn = self:getControl("WorldCheckBox",Const.UICheckBox)
    local chatPanel = self:getControl("ChatPanel",Const.UIPanel)
    local winSize = self:getWinSize()
    local rootHeight = winSize.height / Const.UI_SCALE
    -- self.root:setContentSize(self.root:getContentSize().width, rootHeight)
    self.list:setContentSize(self.list:getContentSize().width, rootHeight - (chatPanel:getContentSize().height  - self.list:getContentSize().height) )
    chatPanel:setContentSize(chatPanel:getContentSize().width, rootHeight)
    self:moveToWinOutAtOnce()

   -- 绑定移动事件
   self:blinkMove()

    -- 添加小红点
    self:initRedDot()

    -- 频道对象表
    self.channelPanelTable = {}

    self.isShowDone = false

    -- 默认选中第一个
    self:setSingChannelData("CurrentCheckBox", ChatMgr:getChatData("currentChatData"))
    self.radioGroup:selectRadio(1)

    -- 喇叭提示
    self:setCtrlVisible("HornPanel", false)
    if ChatMgr.curShowHornMsg then
        self:doHornPopup(ChatMgr.curShowHornMsg)
    end

    self:hookMsg("MSG_MESSAGE_EX")
    self:hookMsg("MSG_MESSAGE")
    self:hookMsg("MSG_PARTY_ZHIDUOXING_QUESTION")
    self:hookMsg("MSG_ENTER_ROOM")

    -- 管理器数据被清除时响应
    EventDispatcher:addEventListener("EVENT_CLEAR_CHANNEL_CHAT_DATA", self.clearChatData, self)
end

function ChannelDlg:clearChatData()
    if self.channelPanelTable then
        for k, v in pairs(self.channelPanelTable) do
            if v then
                local visible = v:isVisible()
                v:removeFromParent()
                self.channelPanelTable[k] = nil
                self:setSingChannelData(k, ChatMgr:getChatData(CHANNEL_CONFIG[k][1]))
                if self.channelPanelTable[k] then
                    self.channelPanelTable[k]:setVisible(visible)
                end
            end
        end
    end
end

function ChannelDlg:blinkMove()
    local movePanel = self:getControl("MovePanel")
    local sartPos, rect, posx
    local winSize = self:getWinSize()

    gf:bindTouchListener(movePanel, function(touch, event)

        local toPos = touch:getLocation()
        local eventCode = event:getEventCode()
        if eventCode == cc.EventCode.BEGAN then
            local panelCtrl = self:getControl("FriendPanel")
            rect = self:getBoundingBoxInWorldSpace(movePanel)
            posx = self.root:getPositionX()
            if cc.rectContainsPoint(rect, toPos) then
                sartPos = toPos
                return true
            end
        elseif eventCode == cc.EventCode.MOVED then
            if toPos.x < sartPos.x then
                local dif = toPos.x - sartPos.x

                self.root:setPositionX(posx + dif)
            end
        elseif eventCode == cc.EventCode.ENDED then
            self.root:stopAllActions()
            if toPos.x < rect.x then
                self:moveToWinOut(0.5)
            else
                self:moveToWinIn(0.2)
            end

        end
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED
    }, false)
end

-- 设置有人呼叫标记，若聊天框还未创建，等创建在做标记（见 self:onChannelButton(sender, eventType)）
function ChannelDlg:setHasOneCallMe(channel)
    local name = self:getCheckBoxNameByChannel(tonumber(channel))
    if self.channelPanelTable[name] then
        self.channelPanelTable[name]:setHasOneCallMe(true)
        return true
    end
end

-- 判断是否添加小红点
function ChannelDlg:onCheckAddRedDot(ctrlName)
    local curChannel = self.radioGroup:getSelectedRadioName()
    if curChannel == ctrlName then
        return false
    end

    return true
end

function ChannelDlg:onChannelButton(sender, eventType)
    local name = sender:getName()
    for k,v in pairs(self.channelPanelTable) do
        if v then
            v:setVisible(false)
        end
    end

    if self.channelPanelTable[name] then
        self.channelPanelTable[name]:setVisible(true)

        -- 世界频道下拉菜单指引光效标记(大于等于30级玩家，首次打开世界聊天界面时播放)
        if name == "WorldCheckBox" and not GameMgr:IsCrossDist() then
            local userDefault = cc.UserDefault:getInstance()
            local flag = userDefault:getIntegerForKey("worldDlgPlayGuideMagic"  .. gf:getShowId(Me:queryBasic("gid")), 0) == 0
            if flag and Me:getLevel() >= 30 then
                local worldPanel = self.channelPanelTable[name]
                local arrowBtn = self:getControl("MenuButton", nil, worldPanel.inputPanel)
                local effect = arrowBtn:getChildByTag(ResMgr.magic.world_chat_under_arrow)
                if not effect then
                    local effect = gf:createLoopMagic(ResMgr.magic.world_chat_under_arrow)
                    local btnSize = arrowBtn:getContentSize()
                    effect:setPosition(btnSize.width / 2, btnSize.height / 2 + 4)
                    effect:setContentSize(arrowBtn:getContentSize())
                    arrowBtn:addChild(effect, 1, ResMgr.magic.world_chat_under_arrow)
                end
            end
        end
    else
        self:setSingChannelData(name, ChatMgr:getChatData(CHANNEL_CONFIG[name][1]))
    end

    -- 在聊天框中标记有人呼叫自己
    if ChatMgr.hasOneCallMe[CHANNEL_CONFIG[name][2]] then
        self.channelPanelTable[name]:setHasOneCallMe(true)
        ChatMgr.hasOneCallMe[CHANNEL_CONFIG[name][2]] = nil
    end

    self.channelPanelTable[name]:refreshChatPanel()

    if not self:isCanChat(name) then
        self:setCtrlVisible("SystemInfoPanel", true)
    else
        self:setCtrlVisible("SystemInfoPanel", false)
    end

    -- 如果有红包图标就移除红包图标
    if name == "PartyCheckBox" and DlgMgr:sendMsg("ChatDlg", "haveRedbagImage") then
        DlgMgr:sendMsg("ChatDlg", "removeRedbagImage")
    end

    -- 如果有红包图标就移除红包图标
    if name == "PartyCheckBox" and DlgMgr:sendMsg("ChatDlg", "haveRedbagImage") then
        DlgMgr:sendMsg("ChatDlg", "removeRedbagImage")
    end

    -- 如果时当前频道要显示智多星题目
    if name== "CurrentCheckBox" then
        self:MSG_PARTY_ZHIDUOXING_QUESTION(PartyMgr.partyZhidxQuestionInfo)
    else
        self:getControl("AnswerPanel"):setVisible(false)
    end

    self:doHornPopup({})
end

-- 设置指定频道的输入框的内容
function ChannelDlg:setChannelInputChat(channalNo , funcName, ...)
    for k, v in pairs(self.channelPanelTable) do
        if CHANNEL_CONFIG[k][2] == channalNo then
            local func = v[funcName]
            if func then
                func(v, ...)
            end

            break
        end
    end
end

function ChannelDlg:sendMessage(text, voiceTime, token, channelName)
    local selectName = self.radioGroup:getSelectedRadioName()

  --[[  if text ~= "" and token and string.len(token) > 0 then -- 语音的文本

    else
        if gfGetTickCount() - LAST_SENDTIME[selectName] < 2000 then
            gf:ShowSmallTips(CHS[6000032])
            return
        end
        LAST_SENDTIME[selectName] = gfGetTickCount()
    end]]

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end


    -- 过滤敏感词
  -- local filteText = gf:filtText(text)
    local filteText = text
    token = token or ""

    -- token 播放语音的url
    if  ChatMgr:textIsALlSpace(text) and string.len(token) == 0 then
        gf:ShowSmallTips(CHS[3002303])
        return
    end

    -- 发送聊天指令
    local channel = channelName or CHANNEL_CONFIG[selectName][2]
    local data = {}
    data["channel"] = channel
    data["compress"] = 0
    data["orgLength"] = string.len(filteText)
    data["msg"] = filteText
    data["voiceTime"] = voiceTime or 0
    data["token"] = token or ""

    -- 名片处理
    local param = string.match(filteText, "{\t..-=(..-=..-)}")
    if param then
        data["cardCount"] = 1
        data["cardParam"] = param
    end

    ChatMgr:sendMessage(data)

    return true
end


-- 是否为发言频道
function ChannelDlg:isCanChat(checkBoxName)
    if checkBoxName == "SystemCheckBox" or checkBoxName == "RumorCheckBox"
    or checkBoxName == "MiscCheckBox" or  checkBoxName == "AdnoticeCheckBox" then
        return false
    else
        return true
    end
end

-- 获取当前频道
function ChannelDlg:getCurChannel()
    local selectName = self.radioGroup:getSelectedRadioName()
    return CHANNEL_CONFIG[selectName][2]
end

-- 初值化频道数据
function ChannelDlg:setSingChannelData(name,data)
    local iSCanChat = true
    if not self:isCanChat(name) then
        iSCanChat = false
    end
    self.channelPanelTable[name] = SingleChatPanel.new(data, iSCanChat , self.list:getContentSize(), CHANNEL_CONFIG[name][2])
    self.channelPanelTable[name]:setCallBack(self, "sendMessage", CHANNEL_CONFIG[name][2])
    --self.channelPanelTable[name]:setAnchorPoint(0.5, 0.5)
    --self.channelPanelTable[name]:setPosition(self.list:getContentSize().width / 2, self.list:getContentSize().height / 2)

    self.list:addChild(self.channelPanelTable[name])
end

-- 滑出屏幕外
function ChannelDlg:onCloseButton_2(sender, eventType)
    self:moveToWinOut()
    self.isShowDone = false

    RedDotMgr:removeOneRedDot("ChatDlg", "ChatButton")
end

function ChannelDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("CharMenuContentDlg")
end

-- 是否在屏幕外
function ChannelDlg:isOutsideWin()
    local winSize = self:getWinSize()
    if self.root:getPositionX() <= (-self.root:getContentSize().width / 2 + winSize.x) then
        return true
    else
        return false
    end
end

function ChannelDlg:onSelectSystemListView(sender, eventType)
end

function ChannelDlg:MSG_MESSAGE(data)
    if ChatMgr:isVoiceTranslateText(data) then
        local selectName = self.radioGroup:getSelectedRadioName()
        self.channelPanelTable[selectName]:refreshChatPanel(true)
    end
end
function ChannelDlg:MSG_MESSAGE_EX(data)
    self:MSG_MESSAGE(data)
end

-- 显示喇叭喊话
function ChannelDlg:doHornPopup(data)
    local mainPanel = self:getControl("HornPanel")
    local size = mainPanel:getContentSize()
    mainPanel:stopAllActions()
    
    local lastData = mainPanel.data or {}
    local startTime = data.time or lastData.time or 0
    local message = data.msg or lastData.msg
    local icon = data.icon or lastData.icon
    local curChannel = self.radioGroup:getSelectedRadioName()
    local lastTime = HORN_POP_SHOW_TIME - (gf:getServerTime() - startTime)

    mainPanel.data = {msg = message, time = startTime, icon = icon}
    if lastTime > 0 and message and icon and curChannel == "WorldCheckBox" then
        mainPanel:setVisible(true)
    else 
        mainPanel:setVisible(false)
        return
    end
    
    mainPanel:setBackGroundImage(icon)
    mainPanel:setBackGroundImageCapInsets(Const.HORN_TIP_CAPINSECT_RECT)

    local height = self:setColorText(message, "InfoPanel", mainPanel, 10, 10, COLOR3.WHITE, nil, nil, true, true)
    mainPanel:setContentSize(size.width, height + 22)

    performWithDelay(mainPanel, function()
        mainPanel:setVisible(false)
    end, lastTime)
end

-- 是否可以录音
function ChannelDlg:isCanSpeak()
    local selectName = self.radioGroup:getSelectedRadioName()
    local isCanSpeak = true

    if CHANNEL_CONFIG[selectName][2] == CHAT_CHANNEL["PARTY"] then
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002304])
            isCanSpeak = false
        end
    elseif CHANNEL_CONFIG[selectName][2] == CHAT_CHANNEL["TEAM"] then
        if not TeamMgr:inTeamEx(Me:getId()) then
            gf:ShowSmallTips(CHS[3002305])
            isCanSpeak = false
        end
    end

    return isCanSpeak
end

-- 打开频道对话框，根据情况判断是否播放动画
function ChannelDlg:show(noOpenAction)
    local friDlg = DlgMgr:getDlgByName("FriendDlg")
    if friDlg then
        if not friDlg:isOutsideWin() then
            noOpenAction = true
        end
        friDlg:moveToWinOutAtOnce()
    end
    if not self:isOutsideWin() then noOpenAction = true end
    if noOpenAction then
        self:moveToWinInAtOnce()
    else
        self:moveToWinOutAtOnce()
        self:moveToWinIn()
    end
end

-- 立刻移入屏幕
function ChannelDlg:moveToWinInAtOnce()
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    -- 移入屏幕时，需要考虑安全区域或高比宽大于2/3的情况，因此使用的是WINSIZE
    self.root:setPosition(Const.WINSIZE.width / Const.UI_SCALE / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y)
end

-- 慢慢移入屏幕
function ChannelDlg:moveToWinIn(time)
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    -- 移入屏幕时，需要考虑安全区域或高比宽大于2/3的情况，因此使用的是WINSIZE
    local moveto = cc.MoveTo:create(time or 0.25, cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y))
    local callBack = cc.CallFunc:create(function()
        self:moveDown()
    end)

    self.root:runAction(cc.Sequence:create(moveto, callBack))
end

-- 立刻离开屏幕
function ChannelDlg:moveToWinOutAtOnce()
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    self.root:setPosition(-self.root:getContentSize().width / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2 + winSize.y)
end

-- 慢慢离开屏幕
function ChannelDlg:moveToWinOut(time)
    self.root:stopAllActions()
    local winSize = self:getWinSize()
    local moveto = cc.MoveTo:create(time or 0.25, cc.p(-self.root:getContentSize().width / 2 + winSize.x, Const.WINSIZE.height / Const.UI_SCALE / 2))
    self.root:runAction(moveto)
end


-- 切换到好友
function ChannelDlg:onFriedButton()
    self:moveToWinOutAtOnce()

    RedDotMgr:removeOneRedDot("ChannelDlg", "FriendDlgButton")
    FriendMgr:openFriendDlg(true)
end

-- 定位到喊话玩家位置
function ChannelDlg:onHornPanel()
    if self.channelPanelTable["WorldCheckBox"] then

        self.channelPanelTable["WorldCheckBox"]:moveToHornMsg()
    end
end

function ChannelDlg:cleanup()
    if self.channelPanelTable then
        for k,v in pairs(self.channelPanelTable) do
            if v then
                v:clear()
            end
        end

        self.channelPanelTable = nil
    end

    EventDispatcher:removeEventListener("EVENT_CLEAR_CHANNEL_CHAT_DATA", self.clearChatData, self)
end

function ChannelDlg:moveDown()
    self.isShowDone = true
    if self.guaidParam and self.guaidParam == "isShow63" then
        GuideMgr:youCanDoIt(self.name, self.guaidParam)
        self.guaidParam = false
    end
end

-- 如果需要使用指引通知类型，需要重载这个函数
function ChannelDlg:youMustGiveMeOneNotify(param)
    if "isShow63" == param then
        if self.isShowDone then
            GuideMgr:youCanDoIt(self.name, param)
        else
            self.guaidParam = param
        end
    end
end

function ChannelDlg:getSelectItemBox(clickItem)
    if "partyLink" == clickItem then
        local ctrl = self:getControl("ExpressionButton", nil, self.channelPanelTable["PartyCheckBox"])
        return self:getBoundingBoxInWorldSpace(ctrl)
    end
end

function ChannelDlg:getCheckBoxNameByChannel(channel)
    local name = "CurrentCheckBox"
    for k, v in pairs(CHANNEL_CONFIG) do
        if v[2] == channel then
            name = k
            break
        end
    end

	return name
end

function ChannelDlg:selectChannel(name)
    self.radioGroup:setSetlctByName(name)
end

function ChannelDlg:onDlgOpened(param)
	local channel = param[1]

    local name = self:getCheckBoxNameByChannel(tonumber(channel))
    self.radioGroup:setSetlctByName(name)


	if ChatMgr:channelDlgIsOutsideWin() then -- 如果聊天界面在外面把它移进来
        self:moveToWinInAtOnce()
	end

    local dlg = DlgMgr:getDlgByName("FriendDlg")
    if dlg then -- 把好友界面移除去
        dlg:moveToWinOutAtOnce()
	end

    if tonumber(channel) == CHAT_CHANNEL.FRIEND then
        self:onFriedButton()

        local dlg = DlgMgr:getDlgByName("FriendDlg")
        if dlg then
            dlg:onCheckBoxClick(dlg:getControl("FriendCheckBox"), 1)
        end
    else

    end
end

function ChannelDlg:initRedDot()
    if RedDotMgr:hasRedDotInfo("ChannelDlg", "FriendDlgButton") then
        RedDotMgr:insertOneRedDot("ChannelDlg", "FriendDlgButton")
    end
end

function ChannelDlg:MSG_PARTY_ZHIDUOXING_QUESTION(data)
    local answerPanel = self:getControl("AnswerPanel")
    if not data
        or data.message == ""
        or MapMgr:getCurrentMapName() ~= CHS[4000199]
        or self.radioGroup:getSelectedRadioName() ~= "CurrentCheckBox" then

        answerPanel:setVisible(false)
        return
    end

    local showTime = data.duration - (gf:getServerTime() - data.showStartTime)
    if showTime then
        answerPanel:setVisible(true)
        local questionPanelSize = self:getControl("QuestionPanel", nil, "AnswerPanel"):getContentSize()
        local height = self:setColorText(data.message, "QuestionPanel", answerPanel)
        local size = answerPanel:getContentSize()
        local toHeight = size.height + height - questionPanelSize.height
        answerPanel:setContentSize(size.width, toHeight)
        answerPanel:stopAllActions()
        performWithDelay(answerPanel, function()
            answerPanel:setVisible(false)
        end, showTime)
    else
        answerPanel:setVisible(false)
    end
end

function ChannelDlg:MSG_ENTER_ROOM(data)
    local answerPanel = self:getControl("AnswerPanel")
    answerPanel:setVisible(false)
end

return ChannelDlg
