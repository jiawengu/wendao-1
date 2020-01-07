-- SingleChatPanel.lua
-- Created by zhengjh Feb/12/2015
-- 聊天单个面板包括 键盘输入 表情输入

local WORD_COLOR = cc.c3b(86, 41, 2)
local ChatPanel = require("ctrl/ChatPanel")
local SPACE = 10 -- 内容背景和内容的间距

local SingleChatPanel = class("SingleChatPanel", function()
    return ccui.Layout:create()
end)

-- gid 聊天对象的 gid
function SingleChatPanel:ctor(data, iSCanChat, contantSize, channel, gid)
    local jsonName = ResMgr:getDlgCfg("SingleChatDlg")
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    self:addChild(self.root)
    self:setAnchorPoint(0,0)
    self.root:setContentSize(contantSize)
    self.root:setAnchorPoint(0,0)
    self.root:setPosition(0, 0)
    self:setContentSize(contantSize)
    self.channelName = channel
    self.chatGid = gid
    self:init(data, iSCanChat, channel)
end

function SingleChatPanel:init(data, iSCanChat, channel)
    self.inputPanel = self:setInputPanel(channel)

    self:bindListener("DelButton", self.onDelButton, self.inputPanel)
    self:bindListener("ExpressionButton", self.onExpressionButton, self.inputPanel)
    self:bindListener("InputBKImage", self.onInputBKImage, self.inputPanel)
    self:bindListener("MenuButton", self.onMenuButton, self.inputPanel)
    self:bindListener("MenuButton1", self.onMenuButton1, "HornMenuPanel")
    self:bindListener("MenuButton2", self.onMenuButton2, "HornMenuPanel")
    self:bindListener("MenuButton3", self.onMenuButton3, "HornMenuPanel")

    self:bindListener("KeyBoardButton", self.onKeyboardButton)
    self:bindListener("KeyboardButton_1", self.onKeyboardButton_1)
    self:bindListener("LinkButton", self.onLinkButton)
    self:bindListener("KeyboardButton_2", self.onKeyboardButton_2)

    self:bindListener("UnReadNotePanel", self.onUnReadNotePanel)
    self:bindListener("CallPromptPanel", self.onCallPromptPanel)
    self:bindListener("CloseImage", self.onCloseCallPrompt, "CallPromptPanel")



    local speakBtn = self:getControl("VoiceButton", nil, self.inputPanel)
    ChatMgr:blindSpeakBtn(speakBtn, self)

    self.textField = self:getControl("InputTextField", Const.UITextField)
    self.textField :setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.panel = self:getControl("ChatPanel",Const.UIPanel)

    local list =  self:getControl("MessageListView")
    --list:setEventNeedNotifyParent(true)
    self.chatTable = data
    self.lastChatNum = #data
    self.panel:setContentSize(self:getContentSize())

    local size = cc.size(list:getContentSize().width, self:getContentSize().height - self.inputPanel:getContentSize().height - SPACE - 3)
    local backImg = self:getControl("MessageBKImage")
    list:setContentSize(size)
    if iSCanChat then
        self.chatPanel = ChatPanel.new(self.chatTable, size, iSCanChat, self)
        list:addChild(self.chatPanel)
        self.deleteBtn = self:getControl("DelButton", Const.UIButton, self.inputPanel)
        self:setDelVisible(false)
        self.editBox = self:createEditBox("InputTextPanel", self.inputPanel, cc.KEYBOARD_RETURNTYPE_SEND, self.editBoxListner)
        self.editBox:setFontColor(COLOR3.TEXT_DEFAULT)
        self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
        self.editBox:setMaxLength(150)
        --self.editBox:setPlaceHolder("点击输入文字")
        --self.editBox:setPlaceholderFontColor(COLOR3.GRAY)
        --self.editBox:setFont("微软雅黑", 23)
        backImg:setContentSize(backImg:getContentSize().width, size.height +  SPACE + 3)
    else
       -- size = cc.size(list:getContentSize().width, self:getContentSize().height - SPACE * 2)
        self.chatPanel = ChatPanel.new(self.chatTable, size, iSCanChat, self)
        list:addChild(self.chatPanel)
        self.chatPanel:setPosition(0, 0)
        backImg:setContentSize(backImg:getContentSize().width, size.height +  SPACE + 3)

        self.inputPanel:removeFromParentAndCleanup(true)
    end


    local  function textFieldListener(sender, type)
        if type == ccui.TextFiledEventType.attach_with_ime then
            local len = string.len(self.textField:getStringValue())
        elseif type == ccui.TextFiledEventType.detach_with_ime then

        elseif type == ccui.TextFiledEventType.insert_text then
            local text = self.textField:getStringValue()
            local len = string.len(text)

            if len > self:getWorldLimit() then
                local newtext = string.sub(text, 0, self:getWorldLimit())
                local text =   self.textField:getInsertText()
                self:setInputText("InputTextField", newtext)
                gf:ShowSmallTips(CHS[6000133])
            end

            if len > 0 then
                self:setDelVisible(true)
            end

        end
    end

    self.textField:addEventListener(textFieldListener)
    self.textField:setFocused(true)
    self.textField:setColor(WORD_COLOR)

    local function keyBoardListner(keycode, envent)

        if keycode == cc.KEYBOARD_RETURNTYPE_GO then

        elseif keycode == cc.KeyCode.KEY_KP_ENTER or keycode == cc.KeyCode.KEY_RETURN then
            self:sendMessage()
        end
    end

    local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(keyBoardListner, cc.Handler.EVENT_KEYBOARD_PRESSED)

    -- 添加监听
    local dispatcher = self.textField:getEventDispatcher()
  --  dispatcher:addEventListenerWithSceneGraphPriority(listener, self.textField)

    self.unReadNotePanel = self:getControl("UnReadNotePanel", Const.UILabel)
    self.unReadNotePanel:setVisible(false)

    self.unReadNoteLabel = self:getControl("UnReadNoteLabel", Const.UILabel)

    -- 红包提示
    self:bindListener("RedBagPanel", self.onRedBagPanel)
    self:bindListener("CloseRedBagButton", self.onCloseRedBagButton)

    self.redBagPanel = self:getControl("RedBagPanel")
    self.closeRedBagButton = self:getControl("CloseRedBagButton")
    self.redBagPanel:setVisible(false)
    self.closeRedBagButton:setVisible(false)

    -- 呼叫好友提示
    self.callPromptPanel = self:getControl("CallPromptPanel")
    self.callPromptPanel:setVisible(false)
    self.hasOneCallMe = false

    -- 隐藏喇叭菜单
    self:setCtrlVisible("HornMenuPanel", false)

    -- 喇叭菜单中的聊天装饰按钮开关
    self:setDecorateBtnVisible(ChatDecorateMgr:isEntrenceOpend())

    local function refresh ()
        self:refreshChatPanel()
    end

    schedule(self, refresh, 0.1)
end

function SingleChatPanel:setInputPanel(channel)
    local input
    if channel == CHAT_CHANNEL.WORLD then
        self:setCtrlVisible("InputPanel", false)
        input = self:getControl("WorldInputPanel",Const.UIPanel)
        input:setVisible(true)

        self:bindMenuPanel()
    else
        self:setCtrlVisible("WorldInputPanel", false)
        input = self:getControl("InputPanel",Const.UIPanel)
        input:setVisible(true)
    end

    return input
end

function SingleChatPanel:getInputStr()
    return self.editBox:getText()
end

function SingleChatPanel:setInputStr(text)
    self.editBox:setText(text)
end

function SingleChatPanel:getWorldLimit()
    return 60
end

function SingleChatPanel:setDelVisible(visible)
    self.deleteBtn:setVisible(visible)
end

function SingleChatPanel:bindMenuPanel()
    local panel = self:getControl("HornMenuPanel")

    local function onTouchBegan(touch, event)
        self:setCtrlVisible("HornMenuPanel", false)
        return false
    end

    gf:bindTouchListener(panel, onTouchBegan, nil, true)
end

function SingleChatPanel:onRedBagPanel(sender, eventType)
    sender:setVisible(false)
    self.closeRedBagButton:setVisible(false)
    local num = self:findRedBaglastNum()
    if num > 0 then
        -- 找到红包
        self.lastChatNum = self:getTotalIndex()
        self.chatPanel:loadInitData(num, true)
    else
        -- 未找到红包
        gf:ShowSmallTips(CHS[5410031])
    end

    ChatMgr.hasRedBag = false
end

function SingleChatPanel:onCloseRedBagButton(sender, eventType)
    self.redBagPanel:setVisible(false)
    self.closeRedBagButton:setVisible(false)
    ChatMgr.hasRedBag = false
end

function SingleChatPanel:onCloseCallPrompt(sender, eventType)
    self.callPromptPanel:setVisible(false)

    self.chatTable[#self.chatTable]["perCallMeHasLose"] = true
end

function SingleChatPanel:findCallMeMsglastNum()
    local num = 0
    -- 要定位到最早的一条呼叫消息
    for i = #self.chatTable, 1, -1 do
        if self.chatTable[i]["perCallMeHasLose"] then
            break
        end

        if self.chatTable[i]["hasOneCallMe"] then
            num = i
            self.chatTable[i]["hasOneCallMe"] = nil
        end
    end

    return num
end

function SingleChatPanel:onCallPromptPanel(sender, eventType)
    self.callPromptPanel:setVisible(false)
    self.hasOneCallMe = false
    local num = self:findCallMeMsglastNum()
    if num > 0 then
        -- 找到呼叫信息
        self.lastChatNum = self:getTotalIndex()
        self.chatPanel:loadInitData(num, true)
    else
        -- 未找到呼叫信息
        gf:ShowSmallTips(CHS[5400305])
    end

    self.chatTable[#self.chatTable]["perCallMeHasLose"] = true
end

-- 找到最近的喇叭消息
function SingleChatPanel:findHornMsg()
    local num = 0
    for i = #self.chatTable, 1, -1 do
        if self.chatTable[i].channel == CHAT_CHANNEL.HORN then
            num = i
            break
        end
    end

    return num
end

-- 定位到喇叭消息附近
function SingleChatPanel:moveToHornMsg()
    local num = self:findHornMsg()
    if num > 0 then
        -- 找到喇叭消息
        self.lastChatNum = self:getTotalIndex()
        self.chatPanel:loadInitData(num, true)
    else
        -- 未找到喇叭消息
        -- gf:ShowSmallTips(CHS[5400305])
    end
end

function SingleChatPanel:setHasOneCallMe(flag)
    self.callPromptPanel:setVisible(flag)
    self.hasOneCallMe = flag
end

function SingleChatPanel:findRedBaglastNum()
    local index = 0
    for i = #self.chatTable, 1, -1 do
        if ChatMgr:isRedBagMsg(self.chatTable[i]["chatStr"]) then
            index = i
            break
        end
    end

    return index
end

function SingleChatPanel:editBoxListner(event, sender)
    if event == "return" then
        self:sendMessage()
    elseif event == "changed" then
        local text = self:getInputStr()
        local len = string.len(text)

        if not self:checkStringLength() then
            if string.match(text, "@$") then

                if gf:isIos() and self:readyToAddCallChar() then
                    -- 检测到 @ 且成功打开选择成员界面，要关闭键盘
                    self.editBox:closeKeyboard()
                end
            end
        end

        if len > 0 then
            self:setDelVisible(true)
        end
    elseif event == "ended" then
    end
end

function SingleChatPanel:checkStringLength()
    local text = self:getInputStr()
    local len = string.len(text)
    local leftString = text
    local filterStr = ""
    local index = 1

    if gf:getTextLength(text) > self:getWorldLimit() * 2 then
        gf:ShowSmallTips(CHS[4000224])
        text = gf:subString(text, self:getWorldLimit() * 2)
        self:setInputStr(tostring(text))
        return true
    end

   --[[ while  gf:getTextLength(filterStr) <= self:getWorldLimit() and index <= len do
        local byteValue = string.byte(text, index)
        if byteValue < 128 then

            filterStr = filterStr..string.sub(text, index, index)
            index = index + 1
        elseif byteValue >= 192 and byteValue < 224 then
            index = index + 2
        elseif  byteValue >= 224 and byteValue <= 239 then
            if gf:getTextLength(filterStr..string.sub(text, index, index + 2)) > self:getWorldLimit() then
                break
            else
                filterStr = filterStr..string.sub(text, index, index + 2)
                index = index + 3
            end
        else
            index = index + 1
        end
    end]]
end

-- 获取当前频道总的条数
function SingleChatPanel:getTotalIndex()
    if self.chatTable[#self.chatTable] then
        return self.chatTable[#self.chatTable]["index"] or 0
    else
        return 0
    end
end

function SingleChatPanel:onUnReadNotePanel()
    self.unReadNotePanel:setVisible(false)
    self.lastChatNum = self:getTotalIndex()
    self.chatPanel:newMessage()
end

function SingleChatPanel:onInputBKImage()
    self.editBox:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end

function SingleChatPanel:onMenuButton(sender)
    if not DistMgr:checkCrossDist() then return end

    local menuPanel = self:getControl("HornMenuPanel")
    menuPanel:setVisible(not menuPanel:isVisible())

    -- 尝试移除环绕光效
    if sender:getChildByTag(ResMgr.magic.world_chat_under_arrow) then
        sender:removeChildByTag(ResMgr.magic.world_chat_under_arrow)

        -- 策划要求该光效真正被点击后才算真正提示了玩家一次
        cc.UserDefault:getInstance():setIntegerForKey("worldDlgPlayGuideMagic"  .. gf:getShowId(Me:queryBasic("gid")), 1)
    end
end

-- 使用喇叭
function SingleChatPanel:onMenuButton1()
    if not DistMgr:checkCrossDist() then return end

    gf:CmdToServer("CMD_TRY_USE_LABA", {})

    self:setCtrlVisible("HornMenuPanel", false)
end

-- 查看喇叭信息
function SingleChatPanel:onMenuButton2()
    if not DlgMgr:getDlgByName("HornRecordDlg") then
        DlgMgr:openDlg("HornRecordDlg")
    else
        DlgMgr:reorderDlgByName("HornRecordDlg")
    end

    self:setCtrlVisible("HornMenuPanel", false)
end

function SingleChatPanel:onMenuButton3()
    DlgMgr:openDlg("ChatDecorateDlg")

    self:setCtrlVisible("HornMenuPanel", false)
end

-- 设置显示或隐藏聊天装饰按钮
function SingleChatPanel:setDecorateBtnVisible(flag)
    local panel = self:getControl("HornMenuPanel")
    local panelSz = panel:getContentSize()
    local decBtn = self:getControl("MenuButton3")
    local decBtnSz = decBtn:getContentSize()

    if flag then
        if not decBtn:isVisible() then
            panel:setContentSize(panelSz.width, panelSz.height + decBtnSz.height + 2)
        end
    else
        if decBtn:isVisible() then
            panel:setContentSize(panelSz.width, panelSz.height - decBtnSz.height - 2)
        end
    end

    self:setCtrlVisible("MenuButton3", flag)
end

-- 回调函数
function SingleChatPanel:setCallBack(obj, funcName, channelName)
    self.func = nil
    self.func = obj[funcName]
    self.obj = nil
    self.obj = obj
    self.channelName = channelName
end

function SingleChatPanel:getListData()
    return self.chatTable
end

function SingleChatPanel:onKeyboardButton(sender, eventType)
    self:getControl("VoicePanel"):setVisible(false)
    self:getControl("WordPanel"):setVisible(true)
end

function SingleChatPanel:clickSpeakBtn()
    self:getControl("VoicePanel"):setVisible(true)
    self:getControl("WordPanel"):setVisible(false)
end

function SingleChatPanel:onSpeakButton(sender, eventType)
    local speakBtn = self:getControl("VoiceButton")
    local voiceTime = 0
    local function upadate()
        voiceTime = voiceTime + 1
        if voiceTime > 15 then
            SingleChatPanel:removeVoiceImg()
            gf:ShowSmallTips(CHS[3002178])
            ChatMgr:stopRecord()
            --self:sendVoiceMsg()
            speakBtn:stopAllActions()
        end
    end


    if ccui.TouchEventType.ended == eventType then
        self:removeVoiceImg()
        speakBtn:stopAllActions()
        ChatMgr:stopRecord()

    elseif ccui.TouchEventType.moved == eventType then
        local rect = sender:getBoundingBox()
        local pt = sender:getParent():convertToWorldSpace(cc.p(rect.x, rect.y))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        if cc.rectContainsPoint(rect, GameMgr.curTouchPos) then
            self:removeVoiceImg()
            local onVoiceImg = ccui.ImageView:create(ResMgr.ui.onVoice_img)
            cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
            onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)
        else
            self:removeVoiceImg()
            local onVoiceImg = ccui.ImageView:create(ResMgr.ui.cancelVoice_img)
            cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
            onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)
        end
    elseif  ccui.TouchEventType.began == eventType and self:isCanSpeak() then
        schedule(speakBtn, upadate, 1)
        self:removeVoiceImg()
        local onVoiceImg = ccui.ImageView:create(ResMgr.ui.onVoice_img)
        cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
        onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)

        ChatMgr:startRecord()

    elseif ccui.TouchEventType.canceled  == eventType then
        self:removeVoiceImg()
        ChatMgr:setIsCancel(true)
        ChatMgr:stopRecord()
        speakBtn:stopAllActions()
    end
end

function SingleChatPanel:removeVoiceImg()
    local vioceImg = cc.Director:getInstance():getRunningScene():getChildByTag(10000)
    if vioceImg then
        vioceImg:removeFromParent()
    end
end

function SingleChatPanel:sendVoiceMsg()
    local voiceData = ChatMgr:getVoiceData()
    if voiceData then
        self.func(self.obj, voiceData.text, voiceData.voiceTime, voiceData.token, self.channelName)
    end
end

function SingleChatPanel:onDelButton(sender, eventType)
    self:setInputStr("")
    self:setDelVisible(false)
end

function SingleChatPanel:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, self.channelName, self.chatGid)
end


function SingleChatPanel:sendMessage()
	local txt = self:getInputStr()
    if txt == nil or string.len(txt) == 0 then
        self:setDelVisible(false)
        return
    end

    -- 如果剪切板中有保存数据的相关信息，需要转化下
    if gf.clipBoardPara and (not self.sendInfo or not string.match(txt, "{\29(..-)\29}")) then

        if gf:findStrByByte(txt, gf.clipBoardPara.copyInfo) then
            self.sendInfo = gf.clipBoardPara.sendInfo
            txt = gf:replaceStr(txt, gf.clipBoardPara.copyInfo, gf.clipBoardPara.showInfo)
        end
    end

    if not string.match(txt, "{\29(..-)\29}") then
        self.sendInfo = nil
    end

    -- 检查名片合法性，如果有多个名片，只保留第一个合法的名片
    txt = self:checkCardInfoLegal(txt)

    -- 由于换线或者其他操作会导致道具/宠物的id发生改变，所以道具/宠物的缓存中多记录iid信息
    -- 如果已经有iid信息，则不作操作
    if self.sendInfo and not string.match(self.sendInfo, "{\t..-=..-=..-=(.-)}")then
        local type, idStr = string.match(self.sendInfo, "{\t..-=(..-)=(..-)}")
        if type == CHS[3000015] or type == CHS[3001218] then
            local iid = nil
            if type == CHS[3001218] then  -- 宠物获取iid
                local pet = PetMgr:getPetById(tonumber(idStr))
                if pet then
                    iid = pet:queryBasic("iid_str")
                else
                    iid = ""
                end
            elseif type == CHS[3000015] then  -- 道具获取iid
                local item = InventoryMgr:getItemByIdFromAll(tonumber(idStr))
                if item then
                    iid = item.iid_str or ""
                else
                    iid = ""
                end
            end

            -- 在要缓存的sendInfo最后添加iid信息
            self.sendInfo = string.gsub(self.sendInfo, "}", "=" .. iid .. "}")
        end
    end

    -- 缓存发送的消息
    ChatMgr:setHistoryMsg({sendInfo =  self.sendInfo or txt, showInfo = txt })

    if self.sendInfo then
        if string.match(self.sendInfo, "{\t..-=..-=..-=(.-)}") then
            local name, type, idStr, iidStr = string.match(self.sendInfo, "{\t(..-)=(..-)=(..-)=(.-)}")
            if type == CHS[3000015] or type == CHS[3001218] then
                -- 利用宠物或者道具的iid获取正确的id
                local id = nil
                if type == CHS[3001218] then  -- 宠物根据iid获取id
                    local pet = PetMgr:getPetByIId(iidStr)
                    if not pet then
                        id = idStr
                    else
                        id = pet:queryBasicInt("id")
                    end
                elseif type == CHS[3000015] then  -- 道具根据iid获取id
                    local item = InventoryMgr:getItemByIIdFromAll(iidStr)
                    if not item then
                        id = idStr
                    else
                        id = item["item_unique"]
                    end
                end

                -- 还原sendInfo格式
                self.sendInfo = string.format("{\t%s=%s=%s}", name, type, id)
            end
        end


        if  string.match(txt, CHS[4200663]) and string.match(txt, ".*{\29(..-)\29}.*") then
            local cardtext = string.match(self.sendInfo, ".*({\t..-=(..-=..-)}).*")
            txt = string.gsub(txt,"{\29(..-)\29}", cardtext)
        elseif string.match(self.sendInfo, "{\t..-=(..-=..-)}") and string.match(txt, ".*{\29(..-)\29}.*") then
            local sendInfoFlag = string.match(self.sendInfo, "{\t(..-)=..-=..-}")
            local sendInfoFlag2 = string.match(self.sendInfo, "{\t..-=(..-)=..-}")
            local txtFlag = string.match(txt, ".*{\29(..-)\29}.*")

            -- 若属性链接内的文字被修改，则此链接失效


            -- 2018教师节
            if string.match(txtFlag, "(..-)=teacher_2018") == sendInfoFlag then
                txt = string.gsub(txt,"{\29", "{\9")
                txt = string.gsub(txt,"\29}", "}")
            end
            

            if self:hasLegalCardInfo(txtFlag, sendInfoFlag, sendInfoFlag2) then
                local cardtext = string.match(self.sendInfo, ".*({\t..-=(..-=..-)}).*")
                txt = string.gsub(txt,"{\29(..-)\29}", cardtext)
            end
        else
            -- 过滤\t
            txt = string.gsub(txt,"\t", "")
        end
    end

    -- 保证呼叫消息的合法性
    txt = ChatMgr:checkCallMsgLegal(txt)

    if self.func(self.obj, txt) then
        self:setInputStr("")
        self:setDelVisible(false)
        self.sendInfo = nil
        return true
    end
end

function SingleChatPanel:hasLegalCardInfo(txtFlag, sendInfoFlag, sendInfoFlag2)
    -- 角色名片推送
    if string.match(txtFlag, CHS[4101136]) == sendInfoFlag then
        return true
    end

    -- 今日统计格式与其他属性链接格式不同，需要区分
    if (sendInfoFlag2 == CHS[7000012] and txtFlag == CHS[7000012])
            or (sendInfoFlag == txtFlag) then
        return true
    end

    -- 居所
    if sendInfoFlag2 == CHS[2100146] and string.match(txtFlag, CHS[2100147]) then
        return true
    end

    -- 纪念册
    if sendInfoFlag2 == CHS[2100149] and string.match(txtFlag, CHS[2100150]) then
        return true
    end

    if sendInfoFlag2 == CHS[4100443] and txtFlag == CHS[4100443] then
        return true
    end

    -- 某些称谓比较特殊（例如结拜），称谓名会有前缀用于表明称谓类别，但实际显示内容不包含前缀，所以sendInfoFlg和txtFlag会不同
    if sendInfoFlag2 == CHS[6000165] then
        if CharMgr:getChengweiShowName(sendInfoFlag) == txtFlag then
            return true
        end
    end

    -- 货站货品
    if sendInfoFlag2 == CHS[7190483] and string.match(txtFlag, CHS[7190483]) then
        return true
    end

    -- 货站买入方案
    if sendInfoFlag2 == CHS[7190487] and string.match(txtFlag, CHS[7190487]) then
        return true
    end
end

-- 检查名片合法性，如果有多个名片，只保留第一个合法的名片
function SingleChatPanel:checkCardInfoLegal(text)
    if not self.sendInfo then return text end

    local oldText = text
    local sendInfoFlag = string.match(self.sendInfo, "{\t(..-)=..-=..-}")
    local sendInfoFlag2 = string.match(self.sendInfo, "{\t..-=(..-)=..-}")

    local legalCardInfo = nil
    for subStr in string.gfind(text, "{(\29..-\29)}") do
        local str = string.gsub(subStr, "\29", "")
        if not legalCardInfo and self:hasLegalCardInfo(str, sendInfoFlag, sendInfoFlag2) then
            -- 合法名片
            legalCardInfo = subStr
            text = gf:replaceStr(text, subStr, "\29\t\29")
        else
            -- 非法名片取消名片格式
            text = gf:replaceStr(text, subStr, str)
        end
    end

    if legalCardInfo then
        return gf:replaceStr(text, "\29\t\29", legalCardInfo)
    else
        return oldText
    end
end

function SingleChatPanel:isFriendDlg()
    if self.channelName == CHAT_CHANNEL.CHAT_GROUP
        or self.channelName == CHAT_CHANNEL.FRIEND then

        return true
    end
end

function SingleChatPanel:refreshChatPanel(needFresh)
    if ChatMgr.hasRedBag
        and self.chatTable
        and self.chatTable[1]
        and self.chatTable[1]["channel"] == CHAT_CHANNEL["PARTY"] then
        self.redBagPanel:setVisible(true)
        self.closeRedBagButton:setVisible(true)
    end

    if not self.unReadNotePanel then return end
    local unreadNumber = self:getTotalIndex() - self.lastChatNum
    if  self.chatPanel:scroviewllIsIntop() == true
        and (not ChatMgr:channelDlgIsOutsideWin() or self:isFriendDlg())
        and self:isVisible()
        and (unreadNumber ~= 0 or needFresh)
        and self.chatPanel:canRefenshChat() then
        self.unReadNotePanel:setVisible(false)
        self.chatPanel:newMessage()
        self.lastChatNum = self:getTotalIndex()
    else
        if unreadNumber ~= 0 then
            self.unReadNoteLabel:setString(string.format(CHS[6000209], unreadNumber))
            self.unReadNotePanel:setVisible(true)
            self.unReadNotePanel:requestDoLayout()
        else
            self.unReadNotePanel:setVisible(false)
        end
    end
end

function SingleChatPanel:deleteWord()
    local text  = self:getInputStr()
    -- utf8 编码规则
    --0000 - 007F 这部分是最初的ascii部分，按原始的存储方式，即0xxxxxxx。
    --0080 - 07FF 这部分存储为110xxxxx 10xxxxxx
    --0800 - FFFF 这部分存储为1110xxxx 10xxxxxx 10xxxxxx

    local len  = string.len(text)
    local deletNum = 0

    if len > 0 then
        if string.byte(text, len) < 128 then       -- 一个字符
            deletNum = 1
        elseif string.byte(text, len - 1) >= 128 and string.byte(text, len - 2) >= 224 then    -- 三个字符
            deletNum = 3
        elseif string.byte(text, len - 1) >= 192 then     -- 两个个字符
            deletNum = 2
        end

        local newtext = string.sub(text,0,len - deletNum)
        self:setInputStr(newtext)
        if string.len(newtext) == 0 then
            self:setDelVisible(false)
        end
    else
        self:setDelVisible(false)
    end

end

function SingleChatPanel:addSpace()
    local text = self:getInputStr()
    self:setInputStr(text.." ")
    self:checkStringLength()
end

function SingleChatPanel:swichWordInput()
    self.editBox:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
   -- self.textField:attachWithIME()
end


function SingleChatPanel:onKeyboardButton_1(sender, eventType)
end

function SingleChatPanel:onLinkButton(sender, eventType)
    local dlg = DlgMgr:openDlg("LinkDlg")
    dlg:setCallObj(self)
end

function SingleChatPanel:onKeyboardButton_2(sender, eventType)
end

function SingleChatPanel:onSelectMessageListView(sender, eventType)
end

function SingleChatPanel:addCardInfo(...)
    local sendInfo, showInfo, canNotBeReplaced = ...
    local text = self:getInputStr()
    if string.match(text, ".*{\29(..-)\29}.*") and string.match(showInfo, ".*{\29(..-)\29}.*") then
        -- situation1: 输入框中有链接，要键入一个链接
        if canNotBeReplaced  then
            -- 不可替换，给出提示
            gf:ShowSmallTips(CHS[3002179])
        else
            -- 可替换，用键入的链接替换当前输入框中已有的链接
            text = string.gsub(text, "{\29(..-)\29}", showInfo)
            self.sendInfo = sendInfo
            self:setInputStr(text)
            self:checkCardInfoLength()
            self:setDelVisible(true)
        end
    else
        -- situation2: 输入框中没有链接，要键入一个链接
        -- situation3: 输入框中有链接，要键入一个没有链接的信息
        -- situation4: 输入框中没有链接，要键入一个没有链接的信息（eg.历史信息）

        -- 如果当前的sendInfo是名片，才会覆盖之前的sendInfo
        if sendInfo and string.match(sendInfo, "{\t(..-)}") then
            self.sendInfo = sendInfo
        end

        self:setInputStr(text..showInfo)
        self:checkCardInfoLength()
        self:setDelVisible(true)

        if string.match(showInfo, "@$") then
            self:readyToAddCallChar()
        end
    end
end

function SingleChatPanel:checkCardInfoLength()
    if self:checkStringLength() then
        local text = self:getInputStr()
        if string.match(text, ".*{\29(..-)\29}.*")  then
            local cardtext = string.match(self.sendInfo, ".*({\t..-=(..-=..-)}).*")
            text = string.gsub(text,"{\29(..-)\29}", cardtext)
        end

        self.sendInfo = text
    end
end

function SingleChatPanel:addExpression(exrepssion)
    local text = self:getInputStr()

    local len = gf:getTextLength(text..exrepssion)
    if len >self:getWorldLimit() * 2 then
        gf:ShowSmallTips(CHS[6000133])
    else
        self:setInputStr(text..exrepssion)
    end

    self:setDelVisible(len > 0)
end

-- 添加 @ 符号
function SingleChatPanel:addCallSign()
    local text = self:getInputStr()

    if gf:getTextLength(text .. "@") >self:getWorldLimit() * 2 then
        gf:ShowSmallTips(CHS[6000133])
    else
        self:setInputStr(text .. "@")
        self:readyToAddCallChar()
    end

    self:setDelVisible(true)
end

-- @ 对象
function SingleChatPanel:readyToAddCallChar()
    if self.channelName ~= CHAT_CHANNEL.PARTY
        and self.channelName ~= CHAT_CHANNEL.CHAT_GROUP then
        -- 只有帮派频道和群组支持 @ 功能
        return
    end

    if self.channelName == CHAT_CHANNEL.PARTY
        and Me:queryBasic("party/name") == "" then
        -- 当前尚无帮派
        return
    end

    local dlg = DlgMgr:openDlg("CallMemberDlg")
    dlg:setCallObj(self, self.channelName)
    return true
end

-- @ 对象
-- str  = "@对象名"
function SingleChatPanel:addCallChar(name)
    local text = self:getInputStr()

    local callStr
    text = string.gsub(text, "@$", "")

    callStr = "\29@" .. name .. "\29 "
    if gf:getTextLength(text.. callStr) > self:getWorldLimit() * 2 then
        gf:ShowSmallTips(CHS[6000133])
    else
        ChatMgr:addHadCallOne(name)
        self:setInputStr(text .. callStr)
    end

    self:setDelVisible(true)
end

-- 获取控件
function SingleChatPanel:getControl(name, widgetType, root)
    local widget = nil
    if type(root) == "string" then
        root = self:getControl(root, "ccui.Widget")
        widget = ccui.Helper:seekWidgetByName(root, name)
    else
        root = root or self.root
        widget = ccui.Helper:seekWidgetByName(root, name)
    end

    return widget
end

-- 设置控件的可见性
function SingleChatPanel:setCtrlVisible(ctrlName, visible, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setVisible(visible)
    end

    return ctrl
end

function SingleChatPanel:bindListener(name, func, root)
    if nil == func then
        Log:W("Dialog:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name,nil,root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("Dialog:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    self:bindTouchEndEventListener(widget, func)
end

-- 为指定的控件对象绑定 TouchEnd 事件
function SingleChatPanel:bindTouchEndEventListener(ctrl, func)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    -- 事件监听
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            SoundMgr:playEffect("button")
            func(self, sender, eventType)
        end
    end

    ctrl:addTouchEventListener(listener)
end


function SingleChatPanel:createEditBox(name, root, returnType,func)
    local function editBoxListner(envent, sender)
        if func ~= nil then
            func(self, envent, sender)
        end
    end

    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName('TextField0011.png')
    backSprite:setOpacity(0)
    local panel = self:getControl(name, nil , root)
    local editBox = cc.EditBox:create(panel:getContentSize(), backSprite)
    editBox:registerScriptEditBoxHandler(editBoxListner)
    editBox:setReturnType(returnType or cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editBox:setAnchorPoint(0, 0.5)
    editBox:setPosition(5, panel:getContentSize().height / 2)
    panel:addChild(editBox)

    return editBox
end


function SingleChatPanel:getInputText(name, root)
    local textField = self:getControl(name, Const.UITextField, root)
    if textField == nil then
        return ""
    else
        return textField:getStringValue()
    end
end

function SingleChatPanel:setInputText(name, text, root)
    local ctl = self:getControl(name, Const.UITextField, root)
    if nil ~= ctl and text ~= nil then
        ctl:setText(tostring(text))
    end
end

-- 是否可以录音
function SingleChatPanel:isCanSpeak()
    if self:callBack("isCanSpeak") then
        return true
    else
        return false
    end
end

function SingleChatPanel:callBack(funcName, ...)
    local func = self.obj[funcName]
    if self.obj and func then
        return  func(self.obj, ...)
    end
end

-- cleanup 改名为 clear，避免覆盖父类的  cleanup 方法。
function SingleChatPanel:clear()
    -- WDSY-13519 中修改好友聊天面板移除好友界面时，不使用 cleanup() 清除动画和计时器
    -- 已移出好友界面的好友聊天面板在 release 释放时，不会自动调用 cleanup() 清除动画和计时器，会导致内存泄露
    self:cleanup()
    if self.chatPanel then
        self.chatPanel:clear()
        self.chatPanel = nil
    end

    if self.inputPanel then
        local arrowBtn = self:getControl("MenuButton", nil, self.inputPanel)
        if arrowBtn then
            arrowBtn:removeChildByTag(ResMgr.magic.world_chat_under_arrow)
        end
    end
end

return SingleChatPanel
