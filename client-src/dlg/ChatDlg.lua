-- ChatDlg.lua
-- created by cheny Nov/28/2014
-- 所有聊天显示面板

local SChatPanel = require("ctrl/SChatPanel")

local ChatDlg = Singleton("ChatDlg", Dialog)

local CONST_DATA =
{
    initNumber = 100,-- 初值化聊天条目
    cellSpace = 2,
    containerTag = 999,
    expendHeight = 56, -- 聊天区域展开增加的高度
    CS_TYPE_STRING = 1,
    CS_TYPE_IMAGE = 2,
    CS_TYPE_BROW = 3,
    CS_TYPE_ANIMATE = 4,
    CS_TYPE_NPC = 5,
    CS_TYPE_ZOOM = 6,
    CS_TYPE_URL = 7,
    CS_TYPE_CARD = 8,
 }

local REDBAG_TAG = 6695

local BTN_MARGIN = 71

-- 好友气泡持续时间
local FRIEND_POP_LAST_TIME = 5

-- 好友气泡字数限制
local FRIEND_POP_WORD_LIMIT = 13 * 2

-- 喇叭喊话提示显示时长
local HORN_POP_SHOW_TIME = 12

-- 一帧加载的聊天数据数量，避免单帧卡住较长时间
local LOAD_PER_FRAME = 10

function ChatDlg:init()
    self:setFullScreen()
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("FriendButton", self.onFriendButton)
    self:bindListener("SpeedButton", self.onSpeedButton)
    self:bindListener("ChatPanel",self.onChannelOpen)
    self:bindListener("TouchPanel", self.onChatOne, "FriendPanel")
    self:bindListener("ChatButton",self.onChatButton)
    self:bindListener("ChannelSetButton",self.onChannelSetButton)
    self:bindListener("ExpendButton",self.onExpendButton)
    self:bindListener("ShrinkButton",self.onShrinkButton)

    --self:setCtrlVisible("FriendButton", not GameMgr.inCombat)
    self:setCtrlVisible("SpeedButton", GameMgr.inCombat)
    self:setCtrlVisible("TeamRecordButton", false)
    self:setCtrlVisible("PartyRecordButton", false)
    self.worldVoiceBtn = self:getControl("WorldRecordButton", Const.UIButton)
    self.partyVoiceBtn = self:getControl("PartyRecordButton", Const.UIButton)
    self.teamVoiceBtn = self:getControl("TeamRecordButton", Const.UIButton)
    self.teamOriPosX, self.teamOriPosY = self.teamVoiceBtn:getPosition()
    self.partyOriPosX, self.partyOriPosY = self.partyVoiceBtn:getPosition()

    -- 聊天数据表
    self.chatTabel = ChatMgr:getChatData("allChatData")
    self.lastIndex = self:getTotalIndex()

    -- index --> cellPanel
    self.index2Cell = {}    -- { index : cell }
    self.freeCells = {}     -- { cell1, cell2 }

    self.stopRefreshData = nil

    self.isExpend = false

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local chatPanel = self:getControl("ChatPanel",Const.UIPanel)
    self.scrollview = ccui.ScrollView:create()
    self.scrollview:setContentSize(chatPanel:getContentSize())
    self.scrollview:setDirection(ccui.ScrollViewDir.vertical)
    --self.scrollview:setTouchEnabled(true)
    self.scrollview:addChild(container, 0, CONST_DATA.containerTag)
    self:loadInitData()


    chatPanel:addChild(self.scrollview)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            self:onChannelOpen()
        end
    end

    container:addTouchEventListener(ctrlTouch)
    container:setTouchEnabled(true)
    container:setContentSize(self.scrollview:getContentSize())

    ChatMgr:blindSpeakBtn(self.worldVoiceBtn, self)
    ChatMgr:blindSpeakBtn(self.partyVoiceBtn, self)
    ChatMgr:blindSpeakBtn(self.teamVoiceBtn, self)

    self:setCtrlVisible("FriendPanel", false)

    self:setCtrlVisible("HornPanel", false)

    -- 消息变化会比较多，有可能一帧里面会收到多条，故统一在 onUpdate 中处理效率会高些
    -- self:hookMsg("MSG_MESSAGE_EX")
    -- self:hookMsg("MSG_MESSAGE")
    self:hookMsg("MSG_UPDATE_TEAM_LIST")

    self:setLastOpenChannelTime()

    self:checkVoiceBtnPos()

    -- 喇叭提示
    self:setCtrlVisible("HornPanel", false)

    -- 管理器数据被清除时响应
    EventDispatcher:addEventListener("EVENT_CLEAR_CHANNEL_CHAT_DATA", self.clearChatData, self)
end

function ChatDlg:clearChatData()
    FriendMgr:unrequestCharMenuInfo(self.name)
    self.index2Cell = {}
    self.freeCells = {}

    self.chatTabel = ChatMgr:getChatData("allChatData")
    self.lastIndex = self:getTotalIndex()
    local container = self.scrollview:getChildByTag(CONST_DATA.containerTag)
    container:removeAllChildren()
    container:setContentSize(self.scrollview:getContentSize())


    self:loadInitData()
end

function ChatDlg:cleanup()
    FriendMgr:unrequestCharMenuInfo(self.name)
    self.index2Cell = {}
    self.freeCells = {}

    EventDispatcher:removeEventListener("EVENT_CLEAR_CHANNEL_CHAT_DATA", self.clearChatData, self)
end

function ChatDlg:setStopRefreshData(isStop)
    self.stopRefreshData = isStop
end

function ChatDlg:addRedbagImage()
    local btn = self:getControl("ChatButton")
    local image = btn:getChildByTag(REDBAG_TAG)
    if image then return end

    image = ccui.ImageView:create(ResMgr.ui.small_red_bag_image)
    image:setAnchorPoint(1, 1)
    image:setPosition(btn:getContentSize().width * 0.92, btn:getContentSize().height * 0.95)
    btn:addChild(image, 0, REDBAG_TAG)

    -- 红包循环闪烁
    local action = cc.Sequence:create(
        cc.FadeIn:create(0.8),
        cc.DelayTime:create(0.7),
        cc.FadeOut:create(0.8)
    )
    local reAction = cc.RepeatForever:create(action)

    image:runAction(reAction)
end

function ChatDlg:removeRedbagImage()
    local btn = self:getControl("ChatButton")
    local image = btn:getChildByTag(REDBAG_TAG)
    if image then
        image:removeFromParent()
    end
end

function ChatDlg:haveRedbagImage()
    local btn = self:getControl("ChatButton")
    local image = btn:getChildByTag(REDBAG_TAG)
    if image then
        return true
    end

    return false
end

-- 加载聊天数据
function ChatDlg:loadInitData()
    if self.stopRefreshData then
        return self:getTotalIndex()
    end

    local container = self.scrollview:getChildByTag(CONST_DATA.containerTag)

    local sartIndex = 0

    if #self.chatTabel - CONST_DATA.initNumber + 1 < 1 then
        -- 聊天记录还未超过加载最大量
        sartIndex = 1
    else
        -- 聊天数据已经超过加载的最大量了
        sartIndex = #self.chatTabel - CONST_DATA.initNumber + 1
    end

    local count = math.min(#self.chatTabel, math.max(self.lastIndex + LOAD_PER_FRAME - self:getChatIndex(1) + 1, sartIndex + LOAD_PER_FRAME))

    -- 先移除不需要的聊天记录
    local fromIndex = self:getChatIndex(sartIndex)
    for k, v in pairs(self.index2Cell) do
        assert(v:getTag() == k)
        if k < fromIndex and v then
            v:setVisible(false)
            table.insert(self.freeCells, v)
            self.index2Cell[k] = nil
        end
    end

    -- 从startIndex加载到#self.chatTabel
    local innerSizeheight = 0
    local index
    for i = sartIndex, count do
        index = self.chatTabel[i]["index"]
        local cellPanel = self.index2Cell[index]
        if cellPanel then
            -- 聊天记录存在
            assert(cellPanel:getTag() == index, string.format("tag(%d) != index(%d)", cellPanel:getTag(), index))
            if self.chatTabel[i]["needFresh"] == true then
                -- 需要刷新语音文本
                cellPanel:refreshText(self.chatTabel[i])
                cellPanel:setPosition(0, innerSizeheight)
                innerSizeheight = innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
                self.chatTabel[i]["needFresh"]  = false
            else
                -- 调整位置
                cellPanel:setPosition(0,innerSizeheight)
                innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
            end
        else
            local cellPanel = table.remove(self.freeCells)

            -- WDSY-35531 报错分析if else 可能均执行，在此增加此变量用于观察
            local tempNum = 1

            if not cellPanel then
                tempNum = tempNum + 1

                local childCount = container:getChildrenCount()
                if childCount >= CONST_DATA.initNumber then
                    -- 已将创建 100 个了，不应该再创建了
                    local children = container:getChildren()
                    local strForLog = {}
                    for i = 1, #children do
                        table.insert(strForLog, "tag:" .. children[i]:getTag() .. ", name:" .. children[i]:getName() .. ", type:" .. tostring(children[i].__cname))
                    end

                    assert(false)
                end

                cellPanel = self:createOnechat(self.chatTabel[i])
                cellPanel:setTag(index)
                container:addChild(cellPanel)
            else
                tempNum = tempNum + 1

                cellPanel:setTag(index)
                cellPanel:setVisible(true)
                cellPanel:refresh(self.chatTabel[i])
            end

            cellPanel:setPosition(0,innerSizeheight)
            innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
            self.index2Cell[index] = cellPanel
        end
    end

    if innerSizeheight  < self.scrollview:getContentSize().height then
        container:setContentSize(self.scrollview:getContentSize())
        for  i = sartIndex, count do
            local index = self.chatTabel[i]["index"]
            local cell = container:getChildByTag(index)
            local posx, posy = cell:getPosition()
            cell:setPosition(posx, posy + self.scrollview:getContentSize().height - innerSizeheight)
        end
    else
        container:setContentSize(self.scrollview:getContentSize().width, innerSizeheight)
    end

    self.scrollview:setInnerContainerSize(container:getContentSize())

    return index or self:getTotalIndex()
end

function ChatDlg:getChatIndex(index)
    return (#self.chatTabel >= index and index > 0) and self.chatTabel[index]["index"] or 0
end

function ChatDlg:getTotalIndex()
    if self.chatTabel[#self.chatTabel] then
        return self.chatTabel[#self.chatTabel]["index"] or 0
    else
        return 0
    end
end

function ChatDlg:createOnechat(oneChatTable)
    local cellPanel = SChatPanel.new(oneChatTable, self.scrollview:getContentSize().width)
    cellPanel.onChannelOpen = function() self:onChannelOpen() end

    return cellPanel
end

function ChatDlg:MSG_MESSAGE()
    if not self.stopRefreshData then
        self:loadInitData()
        self.scrollview:scrollToTop(0.01, false)
    end
end

function ChatDlg:MSG_MESSAGE_EX()
    self:MSG_MESSAGE()
end

-- 喇叭喊话消息提示
function ChatDlg:doHornPopup(data)
    local mainPanel = self:getControl("HornPanel")
    local size = mainPanel:getContentSize()
    mainPanel:stopAllActions()
    mainPanel:setVisible(true)

    mainPanel:setBackGroundImage(data.icon)
    mainPanel:setBackGroundImageCapInsets(Const.HORN_TIP_CAPINSECT_RECT)

    local height = self:setColorText(data.msg, "ContentPanel", mainPanel, 10, 10, COLOR3.WHITE, nil, nil, true, true)
    mainPanel:setContentSize(size.width, height + 22)

    performWithDelay(mainPanel, function()
        mainPanel:setVisible(false)
    end, HORN_POP_SHOW_TIME)
end

function ChatDlg:doFriendPopup(data)
    -- 好友冒泡提示
    local settingTable = SystemSettingMgr:getSettingStatus()
    if settingTable["friend_msg_bubble"] == 0 then
        return
    end

    if data["channel"] ~= CHAT_CHANNEL["FRIEND"] then
        return
    end

    if data["gid"] == Me:queryBasic("gid") then
        return
    end

    if data["token"] and data["token"] ~= "" and data["msg"] ~= "" then
        -- 语音翻译完之后对应的文本信息，不需要处理
        return
    end

    local mainPanel = self:getControl("FriendPanel")
    mainPanel:stopAllActions()
    mainPanel:setVisible(true)
    mainPanel.gid = data.gid
    mainPanel.data = data
    local name = data.name
    local message = data.msg

    if data["token"] and data["token"] ~= "" and data["msg"] == "" then
        -- 语音信息
        message = "[" .. CHS[3004451] .. "]"
    else
        -- 处理一下名片
        if data["cardType"] then
            message = string.gsub(message, "{\t.+}", "[" .. data["cardType"] .. "]")
        end

        -- 处理震动提醒
        if data["sysTipType"] == CHANNEL_TIP_TYPE["SHOCK"] then
            message = "[" .. CHS[4101023] .. "]"
        end

        -- 处理一下表情
        message = BrowMgr:filterBrowStr(message, data.show_extra, CHS[7003075])
    end

    -- 加上名字
    message = "[" .. name .. "]" .. message

    -- 信息超过一定字数，则多出的部分用"..."代替
    local str = gf:getTextByLenth(message, FRIEND_POP_WORD_LIMIT)
    -- self:setColorText(str, "ChatPanel", "FriendPanel", nil, nil, COLOR3.WHITE, nil, nil)

    local panel = self:getControl("ChatOnePanel", Const.UIPanel, "FriendPanel")
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setDefaultColor(COLOR3.WHITE.r, COLOR3.WHITE.g, COLOR3.WHITE.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    if textH > size.height then
        -- 如果超出范围换行了，则缩减显示内容
        str = gf:getTextByLenth(message, FRIEND_POP_WORD_LIMIT - 3)
        textCtrl:setString(str)
        textCtrl:updateNow()
    end

    textCtrl:setPosition(0, size.height)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    performWithDelay(mainPanel, function()
        mainPanel:setVisible(false)
    end, FRIEND_POP_LAST_TIME)
end

-- 立即隐藏好友气泡提示
function ChatDlg:hideDoFriendPopup(gid)
    local mainPanel = self:getControl("FriendPanel")
    if gid == mainPanel.gid then
        mainPanel:setVisible(false)
    end
end

-- 当创建队伍的时候将队伍语音开启
function ChatDlg:MSG_UPDATE_TEAM_LIST(data)
    self:checkVoiceBtnPos()
end

function ChatDlg:onSendButton()
    local txt = self:getInputText("InputTextField")
    if txt == nil or string.len(txt) == 0 then return end

    local txt, haveFit = gf:filtText(txt)

    if haveFit then
        return
    end

    -- 转义一下名片字符串
    txt = ChatMgr:filtCardStr(txt)

    gf:CmdToServer("CMD_CHAT_EX", {
        channel = 1,
        compress = 0,
        orgLength = 0,
        msg = txt
    })
    self:setInputText("InputTextField", "")
end

function ChatDlg:onFriendButton()
    if BattleSimulatorMgr:isRunning() then
        if BattleSimulatorMgr:getCurCombatData().chatTip then
            gf:ShowSmallTips(BattleSimulatorMgr:getCurCombatData().chatTip)
        end

        return
    end

    FriendMgr:openFriendDlg()
end

function ChatDlg:onSpeedButton(sender, eventType)
    if GameMgr.inCombat then
        FightMgr:addSpeedFactor()
    end
end

function ChatDlg:onChatButton()
    self:onChannelOpen()
    if self:haveRedbagImage() then
        DlgMgr:sendMsg("ChannelDlg", "selectChannel", "PartyCheckBox")
    end
end

function ChatDlg:onChannelOpen()
    if BattleSimulatorMgr:isRunning() then
        if BattleSimulatorMgr:getCurCombatData().chatTip then
            gf:ShowSmallTips(BattleSimulatorMgr:getCurCombatData().chatTip)
        end
        return
    end

    local dlg = DlgMgr:openDlg("ChannelDlg")
    if dlg and self.lastOpenChannelTime and gfGetTickCount() - self.lastOpenChannelTime > 1000 then
        dlg:show()
        self:setLastOpenChannelTime()
    end
end

function ChatDlg:onChatOne(sender)
    if BattleSimulatorMgr:isRunning() then
        if BattleSimulatorMgr:getCurCombatData().chatTip then
            gf:ShowSmallTips(BattleSimulatorMgr:getCurCombatData().chatTip)
        end
        return
    end

    local data = sender:getParent().data
    if data then
        FriendMgr:communicat(data.name, data.gid, data.icon, data.level)

        self:setCtrlVisible("FriendPanel", false)
    end
end

function ChatDlg:setLastOpenChannelTime()
    self.lastOpenChannelTime = gfGetTickCount()
end

function ChatDlg:onChannelSetButton()
    if BattleSimulatorMgr:isRunning() then
        if BattleSimulatorMgr:getCurCombatData().chatTip then
            gf:ShowSmallTips(BattleSimulatorMgr:getCurCombatData().chatTip)
        end

        return
    end

    DlgMgr:openDlg("ChannelSetDlg")
end

-- 检查语音图标
function ChatDlg:checkVoiceBtnPos()

    -- 将所有按钮隐藏
    self:setCtrlVisible("TeamRecordButton", false)
    self:setCtrlVisible("PartyRecordButton", false)
    self:setCtrlVisible("WorldRecordButton", false)
    local posX = self:getControl("ChatButton"):getPositionX()

    if self.partyVoiceBtn == nil or self.teamVoiceBtn == nil then return end
    local userDefault = cc.UserDefault:getInstance()

    local isInTeam = true

    -- 判断是否在暂离队伍中,或者在队伍中
    if (not TeamMgr:inTeam(Me:queryBasicInt("id"))) and (not TeamMgr:inTeamEx(Me:queryBasicInt("id"))) then
        isInTeam = false
    end

    local isInParty = (Me:queryBasic("party/name") ~= "")

    local worldState = userDefault:getIntegerForKey("WorldVoiceCheckBox", 1) == 1
    if worldState then
        self:setCtrlVisible("WorldRecordButton", true)
        posX = posX + BTN_MARGIN
        local worldBtn = self:getControl("WorldRecordButton")
        worldBtn:setPositionX(posX)
    end

    local partyState = userDefault:getIntegerForKey("PartyVoiceCheckBox", 1) == 1
    if partyState and isInParty then
        self.partyVoiceBtn:setVisible(true)
        posX = posX + BTN_MARGIN
        self.partyVoiceBtn:setPositionX(posX)
    end

    local teamState = userDefault:getIntegerForKey("TeamVoiceCheckBox", 1) == 1
    if teamState and isInTeam then
        self.teamVoiceBtn:setVisible(true)
        posX = posX + BTN_MARGIN
        self.teamVoiceBtn:setPositionX(posX)
    end

    self:updateLayout("FunctionPanel")


end

function ChatDlg:onExpendButton(sender, eventType)
    if self.isExpend then
        return
    end

    local chatPanel = self:getControl("ChatPanel",Const.UIPanel)
    chatPanel:setContentSize(chatPanel:getContentSize().width, chatPanel:getContentSize().height + CONST_DATA.expendHeight)
    self.scrollview:setContentSize(chatPanel:getContentSize())
    local chatBKImage = self:getControl("ChatBKImage")
    chatBKImage:setContentSize(chatBKImage:getContentSize().width, chatBKImage:getContentSize().height + CONST_DATA.expendHeight)
    self:loadInitData()

    self:setCtrlVisible("ExpendButton", false)
    self:setCtrlVisible("ShrinkButton", true)
    self.root:requestDoLayout()

    self.isExpend = true
    DlgMgr:sendMsg("SystemFunctionDlg", "onStatusButton2")
    DlgMgr:sendMsg("InnMainDlg", "upManualButton", true)
end

function ChatDlg:onShrinkButton(sender, eventType)
    if not self.isExpend then
        return
    end

    local chatPanel = self:getControl("ChatPanel",Const.UIPanel)
    chatPanel:setContentSize(chatPanel:getContentSize().width, chatPanel:getContentSize().height - CONST_DATA.expendHeight)
    self.scrollview:setContentSize(chatPanel:getContentSize())
    local chatBKImage = self:getControl("ChatBKImage")
    chatBKImage:setContentSize(chatBKImage:getContentSize().width, chatBKImage:getContentSize().height - CONST_DATA.expendHeight)
    self:loadInitData()

    self:setCtrlVisible("ExpendButton", true)
    self:setCtrlVisible("ShrinkButton", false)
    self.root:requestDoLayout()

    self.isExpend = false
    DlgMgr:sendMsg("InnMainDlg", "upManualButton", false)
end

function ChatDlg:removeVoiceImg()
    local vioceImg = cc.Director:getInstance():getRunningScene():getChildByTag(10000)
    if vioceImg then
        vioceImg:removeFromParent()
    end
end

function ChatDlg:sendVoiceMsg()
    local name = ChatMgr:getSenderName()
    local voiceData = ChatMgr:getVoiceData()
    local data = {}

    if name == "PartyRecordButton" then
        data["channel"] = CHAT_CHANNEL["PARTY"]
    elseif name == "TeamRecordButton" then
        data["channel"] = CHAT_CHANNEL["TEAM"]
    elseif name == "WorldRecordButton" then
        data["channel"] = CHAT_CHANNEL["WORLD"]
    end

    if not voiceData or not data["channel"] then gf:ftpUploadEx("ChatDlg name is " .. name) return end

    local filteText = voiceData.text

    data["compress"] = 0
    data["orgLength"] = string.len(filteText)
    data["msg"] = filteText
    data["voiceTime"] = voiceData.voiceTime or 0
    data["token"] = voiceData.token or ""

    -- 名片处理
    local param = string.match(filteText, "{\t..-=(..-=..-)}")
    if param then
        data["cardCount"] = 1
        data["cardParam"] = param
    end

    if  string.len(data["msg"]) <= 0 and  string.len(data["token"]) <= 0 then
        return
    end

    ChatMgr:sendMessage(data)
end

function ChatDlg:onUpdate()
    -- 消息变化会比较多，有可能一帧里面会收到多条，故统一在 onUpdate 中处理效率会高些
    if self.lastIndex ~= self:getTotalIndex() and not self.stopRefreshData then
        -- 有变化，需要重新加载
        self.lastIndex = self:loadInitData()
        self.scrollview:scrollToTop(0.01, false)
    end
end

-- 如果需要使用指引通知类型，需要重载这个函数
function ChatDlg:youMustGiveMeOneNotify(param)
    if "hasPet" == param then
        if PetMgr:getFightPet() then
            GuideMgr:youCanDoIt(self.name, param)
        else
            GuideMgr:youCanDoIt(self.name)
        end
    end
end

-- 是否可以录音
function ChatDlg:isCanSpeak()
    if BattleSimulatorMgr:isRunning() then
        if BattleSimulatorMgr:getCurCombatData().chatTip then
            gf:ShowSmallTips(BattleSimulatorMgr:getCurCombatData().chatTip)
        end

        return false
    end

    return true
end

return ChatDlg
