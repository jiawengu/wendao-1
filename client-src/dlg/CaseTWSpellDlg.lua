-- CaseTWSpellDlg.lua
-- Created by huangzz Jun/06/2018
-- 探案天外之谜-传音符界面


local CaseTWSpellDlg = Singleton("CaseTWSpellDlg", Dialog)


local CONTENT_WIDTH = 248

local VOICE_ACTION_TAG = 999

local WORD_LIMIT = 12

function CaseTWSpellDlg:init(param)
    self:setFullScreen()

    -- self:bindListener("TalkButton", self.onTalkButton)
    ChatMgr:blindSpeakBtn(self:getControl("TalkButton"), self)
    self:bindListener("SendButton", self.onSendButton)

    self.selfPanel = self:retainCtrl("SelfPanel")
    self.otherPanel = self:retainCtrl("OtherPanel")

    self.inputNum = 0

    local data = TanAnMgr:getAllTWVoiceData()
    if data then
        for i = 1, #data do
            self:pushOneChat(data[i], nil, true)
        end

        local listView = self:getControl("ListView")
        listView:doLayout()
        listView:scrollToBottom(0.1, false)
    end

    self.inputType = (self.inputNum >= 10 or LeitingSdkMgr:isOverseas()) and 1 or 0
    self:setCtrlVisible("InputPanel", self.inputType == 1)
    self:setCtrlVisible("TalkButton", self.inputType == 0)

    self:intiInputPanel()

    local wifi = param and param.content or ""
    self.realPw = string.match(wifi, CHS[5450279])
    self.rightMsg = nil

    self.data = param

    self.curIndex = 1
end

function CaseTWSpellDlg:intiInputPanel()
    -- 初始化编辑框
    self.inputCtrl = self:createEditBox("InputTextPanel", nil, nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT * 2 then
                content = gf:subString(content, WORD_LIMIT * 2)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400297])
            end
        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setFont(CHS[3003794], 19)
    self.inputCtrl:setPlaceHolder(CHS[5420325])
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 19)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
end

function CaseTWSpellDlg:onTalkButton(sender, eventType)
end

function CaseTWSpellDlg:onSendButton(sender, eventType)
    local content = self.inputCtrl:getText()
    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[5420330])
        return
    end

    self.inputCtrl:setText("")

    self:doMessage({
        isMe = true,
        msg = content,
        name = Me:getShowName()
    })
end

function CaseTWSpellDlg:isCanSpeak()
    local button = self:getControl("TalkButton")
    if button:isEnabled() then
        return true
    end
end

function CaseTWSpellDlg:sendVoiceMsgError()
    self:doMessage({msg = CHS[5450274], name = CHS[5450278]})
    return true
end

function CaseTWSpellDlg:sendVoiceMsg()
    local voiceData = ChatMgr:getVoiceData()

    if not voiceData  then gf:ftpUploadEx("CaseTWSpellDlg not voiceData") return end

    local text = voiceData.text

    local data = {}
    data["isMe"] = true
    data["msg"] = voiceData.text
    data["voiceTime"] = (voiceData.voiceTime or 0) / 1000
    data["token"] = voiceData.token or ""
    data["name"] = Me:getShowName()

    if string.len(data["msg"]) <= 0 and  string.len(data["token"]) <= 0 then
        return
    end

    self:doMessage(data)
end

function CaseTWSpellDlg:doMessage(data)
    local realData
    local index
    if not string.isNilOrEmpty(data["token"]) and not string.isNilOrEmpty(data["msg"]) then
        -- 语音翻译文本
        if DlgMgr:isDlgOpened("CaseTWSpellDlg") then
            local listView = self:getControl("ListView")
            local items = listView:getItems()
            for i = 1, #items do
                if items[i].data["token"] == data["token"] then
                    realData = items[i].data
                    realData["msg"] = data["msg"]
                    index = i - 1
                    break
                end
            end
        else
            -- 界面已关闭直接丢弃
            local allData = TanAnMgr:getAllTWVoiceData() or {}
            for i = #allData, 1, -1 do
                if allData[i]["token"] == data["token"] then
                    table.remove(allData, i)
                    break
                end
            end
        end
    else
        realData = data

        TanAnMgr:addTWVoiceData(realData)
    end

    if DlgMgr:isDlgOpened("CaseTWSpellDlg") and realData then
        self:pushOneChat(realData, index)
    end
end

function CaseTWSpellDlg:doCallWhenStopRecord()
    if 'function' == type(self.callbackWhenStopRecord) then
        self.callbackWhenStopRecord()
    end
end

function CaseTWSpellDlg:setOnePanel(cell, data, index)
    local reduceHeight = 0
    local voiceWidth = 30
    if data["token"] and string.len(data["token"]) > 0 then
        -- 语音条

        -- 设置语音进度条长度
        local width = math.min(210, math.max(210 / 15 * tonumber(data["voiceTime"]), 46))  -- 根据秒数算出长度
        local vioceTimeImg = self:getControl("BKImage", nil, cell)
        vioceTimeImg:setContentSize(width, vioceTimeImg:getContentSize().height)
        voiceWidth = voiceWidth + width

        -- 显示语音时长
        local textLabel = self:getControl("TextLabel", nil, vioceTimeImg)
        textLabel:setString(string.format(CHS[4200423], data["voiceTime"]))
        textLabel:setPositionX(width / 2)

        local vioceSignImg = self:getControl("IconImage", nil, cell)
        local voicePanel = self:getControl("VoicePanel", nil, cell)
        vioceTimeImg.playTime = 0
        local function upadate()
            vioceTimeImg.playTime = vioceTimeImg.playTime + 0.1
            if vioceTimeImg.playTime > data["voiceTime"] then
                vioceTimeImg:stopAllActions()
                vioceSignImg:setVisible(true)
                local actionImg = voicePanel:getChildByTag(VOICE_ACTION_TAG)

                if actionImg then
                    actionImg:stopAllActions()
                    actionImg:removeFromParent()
                    ChatMgr:setIsPlayingVoice(false)
                    SoundMgr:replayMusicAndSound()
                end

                vioceTimeImg.playTime = 0
                return
            end
        end

        -- 播放语音
        local function palyVoice(sender, eventType)
            if ccui.TouchEventType.ended == eventType then

                -- 该语音正在播放(则停止)
                if self.lastPalyVoiceCellTag == index and vioceTimeImg.playTime > 0 then
                    self:stopPlayVoice()
                    vioceTimeImg:stopAllActions()
                    SoundMgr:replayMusicAndSound()
                    vioceTimeImg.playTime = 0
                    return
                end

                self:stopPlayVoice()
                vioceTimeImg:stopAllActions()
                ChatMgr:stopPlayRecord()
                vioceTimeImg.playTime = 0.01 -- 标记启动播放
                ChatMgr:setIsPlayingVoice(true) -- 标志在播放语音
                ChatMgr:clearPlayVoiceList() -- 点击播放语音时，清空缓存的语音队列

                schedule(vioceTimeImg, upadate, 0.1)
                local actionImg =  gf:createLoopMagic(ResMgr.magic.volume)
                local x, y = vioceSignImg:getPosition()
                local imgSize = vioceSignImg:getContentSize()
                actionImg:setPosition(x + imgSize.width / 2, y + imgSize.height / 2)
                vioceSignImg:setVisible(false)
                voicePanel:addChild(actionImg, 0, VOICE_ACTION_TAG)

                if data.isMe then
                    actionImg:setFlippedX(true)
                    actionImg:setAnchorPoint(1, 1)
                end

                self.callbackWhenStopRecord = function()
                    if vioceTimeImg and 'function' == type(vioceTimeImg.stopAllActions) then
                        self:stopPlayVoice()

                        if self.lastPlayVoiceLayout and self.lastPlayVoiceLayout == voicePanel then
                            vioceTimeImg:stopAllActions()
                        end
                    end
                end
                ChatMgr:playRecord(data["token"], 0, data["voiceTime"], true, function()
                    DlgMgr:sendMsg("CaseTWSpellDlg", "doCallWhenStopRecord")
                end)

                self.lastPlayVoiceLayout = voicePanel
                self.lastPalyVoiceCellTag = index
            end
        end

        -- 语音点击整句都响应
        vioceTimeImg:setTouchEnabled(true)
        vioceTimeImg:addTouchEventListener(palyVoice)
        vioceSignImg:setTouchEnabled(true)
        vioceSignImg:addTouchEventListener(palyVoice)

        if data["playTime"] and data["playTime"] > 0 then
            -- 收到翻译文本重新开启语音
            local playTime = data["playTime"]
            data["playTime"] = 0
            performWithDelay(vioceTimeImg, function()
                vioceTimeImg.playTime = 0.01 -- 未收到翻译文本前不能播放语音故重新播
                schedule(vioceTimeImg, upadate, 0.1)
                local actionImg =  gf:createLoopMagic(ResMgr.magic.volume)
                local x, y = vioceSignImg:getPosition()
                local imgSize = vioceSignImg:getContentSize()
                actionImg:setPosition(x + imgSize.width / 2, y + imgSize.height / 2)
                vioceSignImg:setVisible(false)
                voicePanel:addChild(actionImg, 0, VOICE_ACTION_TAG)

                if data.isMe then
                    actionImg:setFlippedX(true)
                    actionImg:setAnchorPoint(1, 1)
                end

                self.lastPlayVoiceLayout = voicePanel
                self.lastPalyVoiceCellTag = index
            end, 0)
        end
    else
        local panel = self:getControl("VoicePanel", nil, cell)
        panel:setVisible(false)
        reduceHeight = panel:getContentSize().height
        voiceWidth = 20
    end

    self:setLabelText("NameLabel", data["name"], cell)

    local oldSize, newSize = self:setColorTextEx(data["msg"], "TextPanel", cell)

    local talkImg = self:getControl("TalkImage", nil, cell)
    local size = talkImg:getContentSize()

    -- 调整宽高
    local reduceWidth = math.max(0, CONTENT_WIDTH - math.max(newSize.width, voiceWidth))

    reduceHeight = reduceHeight + oldSize.height - newSize.height
    talkImg:setContentSize(size.width - reduceWidth, size.height - reduceHeight)

    local size = cell:getContentSize()
    cell:setContentSize(size.width, size.height - reduceHeight)

    cell.data = data
end

-- 停止播放声音
function CaseTWSpellDlg:stopPlayVoice()
    SoundMgr:stopMusicAndSound()
    ChatMgr:setIsPlayingVoice(false)
    if self.lastPlayVoiceLayout == nil then
        return
    end

    local actionImg = self.lastPlayVoiceLayout:getChildByTag(VOICE_ACTION_TAG)
    local vioceSignImg = self:getControl("IconImage", nil, self.lastPlayVoiceLayout)
    if actionImg and vioceSignImg then
        actionImg:stopAllActions()
        actionImg:removeFromParent()
        vioceSignImg:setVisible(true)
        ChatMgr:stopPlayRecord()
    end

    self.lastPlayVoiceLayout = nil
    self.lastPalyVoiceCellTag = 0
end

function CaseTWSpellDlg:startRecord()
    if self.lastPlayVoiceLayout then
        local actionImg = self.lastPlayVoiceLayout:getChildByTag(VOICE_ACTION_TAG)
        local vioceSignImg = self:getControl("IconImage", nil, self.lastPlayVoiceLayout)
        if actionImg and vioceSignImg then
            actionImg:stopAllActions()
            actionImg:removeFromParent()
            vioceSignImg:setVisible(true)
        end
    end
end

function CaseTWSpellDlg:setColorTextEx(str, panelName, root)
    local fontSize = 20
    local defColor = COLOR3.TEXT_DEFAULT

    local panel = self:getControl(panelName, Const.UIPanel, root)

    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, true)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    panel:setContentSize(textW, textH)
    textCtrl:setPosition(0, textH)

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)

    return size, {width = textW, height = textH}
end

function CaseTWSpellDlg:pushOneChat(data, replaceIndex, isInit)
    local listView = self:getControl("ListView")
    if data.isMe then
        local cell = self.selfPanel:clone()
        if replaceIndex then
            -- 翻译文本过来了
            local item = listView:getItem(replaceIndex)
            if item then
                local tag = item:getTag()
                cell:setTag(tag)

                local playTime = self:getControl("BKImage", nil, item).playTime
                if self.lastPalyVoiceCellTag == tag and playTime and data["voiceTime"] and playTime > 0 and playTime < data["voiceTime"] then
                    data["playTime"] = playTime
                end

                if self.lastPalyVoiceCellTag == tag then
                    self.lastPlayVoiceLayout = nil
                    self.lastPalyVoiceCellTag = 0
                end

                self:setOnePanel(cell, data, tag, data.isMe)

                listView:removeItem(replaceIndex)
                listView:insertCustomItem(cell, replaceIndex)

                self:checkAnswer(data["msg"])
            end
        else
            cell:setTag(self.curIndex)
            self:setOnePanel(cell, data, self.curIndex, data.isMe)
            listView:pushBackCustomItem(cell)

            self.curIndex = self.curIndex + 1

            self.inputNum = self.inputNum + 1

            if not isInit and string.isNilOrEmpty(data["token"]) and not string.isNilOrEmpty(data["msg"]) then
                self:checkAnswer(data["msg"])
            end
        end
    else
        local cell = self.otherPanel:clone()
        cell:setTag(self.curIndex)
        self:setOnePanel(cell, data, self.curIndex)
        listView:pushBackCustomItem(cell)

        self.curIndex = self.curIndex + 1

        if self.inputNum == 10 and not LeitingSdkMgr:isOverseas() and not isInit and data.msg ~= CHS[5400604] and data.msg ~= CHS[5420329] then
            self:doMessage({msg = CHS[5420329], name = CHS[5450278]})
            self.inputType = 1
            self:setCtrlVisible("InputPanel", true)
            self:setCtrlVisible("TalkButton", false)
        end
    end

    if not isInit then
        listView:doLayout()
        listView:scrollToBottom(0.1, false)
    end
end

function CaseTWSpellDlg:changeMsg(msg)
    local len = string.len(msg)
    local index = 1
    local sstr = ""

    while index <= len do
        -- 将阿拉伯数字替换为中文数字
        local byteValue = string.byte(msg, index)
        local strLen = gf:getUTF8Bytes(byteValue)
        if strLen == 1 and byteValue >= 48 and byteValue <= 48 + 9 then
            sstr = sstr .. gf:changeNumber(string.sub(msg, index, index + strLen - 1))
        else
            sstr = sstr .. string.sub(msg, index, index + strLen - 1)
        end

        index = index + strLen
    end

    -- 将大写字母替换为小写字母
    sstr = string.lower(sstr)

    return sstr
end

function CaseTWSpellDlg:checkAnswer(msg)
    if not msg then
        return
    end

    local str = self:changeMsg(msg)
    if string.match(str, "ｗｉｆｉ") or string.match(str, "wifi") then
        if string.match(str, self.realPw or "") then
            self:doMessage({msg = CHS[5400604], name = CHS[5450277]})
            self.rightMsg = msg
            self:setCtrlEnabled("TalkButton", false)
            self:setCtrlEnabled("SendButton", false)
            self:setCtrlOnlyEnabled("CloseButton", false)
            performWithDelay(self.root, function()
                local md5 = gfGetMd5(self.data.gid .. "GSWEFD")
                gf:CmdToServer("CMD_TWZM_CHUANYINFU_ANSWER", {key = md5, type = self.inputType, num = self.inputNum})
                self:onCloseButton()
            end, 1)
        else
            self:doMessage({msg = CHS[5450273], name = CHS[5450277]})
        end
    else
        self:doMessage({msg = CHS[5450272], name = CHS[5450278]})
    end
end

function CaseTWSpellDlg:cleanup()
    self.lastPlayVoiceLayout = nil
    self.lastPalyVoiceCellTag = nil
    self.callbackWhenStopRecord = nil

    if self.rightMsg  then
        local allData = TanAnMgr:getAllTWVoiceData() or {}
        for i = #allData, 1, -1 do
            if allData[i]["msg"] == self.rightMsg then
                table.remove(allData, i)

                if allData[i] then
                    table.remove(allData, i)
                end

                break
            end
        end
    end
end


return CaseTWSpellDlg
