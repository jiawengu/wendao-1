-- CanChatCell.lua
-- Created by sujl, Dec/8/2016
-- 聊天交互控件

local ChatCell = require("ctrl/ChatCell/ChatCell")
local CanChatCell = class("CanChatCell", ChatCell)

local WORD_COLOR = cc.c3b(86, 41, 2)

function CanChatCell:ctor(oneChatTable, width, lastTime)
    self.width = width
    self.lastTime = lastTime
    self.oneChatTable = oneChatTable
    self:create()
end

function CanChatCell:create()
    self:removeAllChildren()

    local width = self.width
    self:setPosition(0,0)

    -- 头像边框
    local iconImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    local function imgTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理弹出名片
            FriendMgr:requestCharMenuInfo(self.oneChatTable["gid"])

            -- 过滤掉左下角角色职称
            local name = string.match(self.oneChatTable["name"], "(.*) .*")
            if not name then
                name = self.oneChatTable["name"]
            end

            local char = {}
            char.gid = self.oneChatTable["gid"]
            char.name = name
            char.level = self.oneChatTable["level"]
            char.icon = self.oneChatTable["icon"]
            self:onCharInfo(char.gid, char)
        end
    end
    iconImg:setTouchEnabled(true)
    iconImg:setAnchorPoint(0,1)
    self:addChild(iconImg)

    -- 头像
    local imgPath = ResMgr:getSmallPortrait(self.oneChatTable["icon"])
    self.protriatIcon = ccui.ImageView:create(imgPath)
    self.protriatIcon:setAnchorPoint(0.5, 0.5)
    self.protriatIcon:setPosition(iconImg:getContentSize().width / 2  , iconImg:getContentSize().height / 2)
    gf:setItemImageSize(self.protriatIcon)
    iconImg:addChild(self.protriatIcon)

    -- 等级
    if  self.oneChatTable["level"]  then
        Dialog.setNumImgForPanel(nil, iconImg, ART_FONT_COLOR.NORMAL_TEXT, self.oneChatTable["level"], false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 名字
    local labelLayout = nil
    local lableHeight = 0
    if self.oneChatTable["gid"] ~= Me:queryBasic("gid") then
        labelLayout = ccui.Layout:create()
        labelLayout:setAnchorPoint(0,1)
        self:addChild(labelLayout)
        local lableText = CGAColorTextList:create()
        lableText:setFontSize(21)
        lableText:setString(gf:getRealName(self.oneChatTable["name"]))
        lableText:setContentSize(self.width-iconImg:getContentSize().width, 0)
        lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        lableText:updateNow()
        local labelW, labelH = lableText:getRealSize()
        lableText:setPosition(0, labelH)
        labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
        lableHeight = labelH
        labelLayout:setContentSize(labelW,labelH)
    end
    self.forMe = self.oneChatTable["gid"] == Me:queryBasic("gid")
    self.labelLayout = labelLayout

    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    self:addChild(chatLayout)
    self.chatLayout = chatLayout

    -- 尖角
    local backSprite1 = ccui.ImageView:create(ResMgr.ui.chat_back_groud1, ccui.TextureResType.plistType)
    backSprite1:setAnchorPoint(0, 1)
    backSprite1:setLocalZOrder(10)
    backSprite1:setPosition(2, chatLayout:getContentSize().height / 2)
    chatLayout:addChild(backSprite1)

    -- 文本
    local textMaxWidth = self.width- iconImg:getContentSize().width  - backSprite1:getContentSize().width - 30
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(21)
    textCtrl:setString(self.oneChatTable["chatStr"], self.oneChatTable["show_extra"])
    textCtrl:setContentSize(textMaxWidth, 0)
    textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            if textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_ZOOM and
               textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_NPC and
               textCtrl:getCsType() ~= CONST_DATA.CS_TYPE_CALL then
                gf:onCGAColorText(textCtrl, sender)
            end
        end
    end

    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    --textCtrl:setPosition((chatLayout:getContentSize().width - textW) / 2, textH + (chatLayout:getContentSize().height - textH) / 2)
    chatLayout:addChild(layer)
    chatLayout:setAnchorPoint(0,1)
    chatLayout:setTouchEnabled(true)
    chatLayout:addTouchEventListener(ctrlTouch)

    -- 语音
    local voiceLayout = ccui.Layout:create()
    voiceLayout:setContentSize(0, 0)
    local vioceSignImg,vioceTimeLayout = nil
    local voiceMoreWidth = 0            -- 语音条比文本多出的长度
    if self.oneChatTable["token"] and string.len(self.oneChatTable["token"]) > 0 then
        voiceLayout:setAnchorPoint(0, 1)

        -- 语音标志
        vioceSignImg = ccui.ImageView:create(ResMgr.ui.vioce_sign)
        vioceSignImg:setAnchorPoint(0, 1)
        voiceLayout:addChild(vioceSignImg, 0, 996)

        -- 语音条
        vioceTimeLayout = ccui.Layout:create()
        vioceTimeLayout:setAnchorPoint(0, 1)
        local width = 46 + (224- 46) / 14 * (tonumber(string.format("%d", self.oneChatTable["voiceTime"]))- 1)  -- 根据秒数算出长度
        local vioceTimeImg =  cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.vioce_time_back)
        vioceTimeImg:setContentSize(width, vioceTimeImg:getContentSize().height)
        vioceTimeImg:setAnchorPoint(0, 0)
        vioceTimeLayout:addChild(vioceTimeImg)

        vioceTimeLayout:setContentSize(vioceTimeImg:getContentSize())
        --vioceTimeLayout:setTouchEnabled(true)
        voiceLayout:addChild(vioceTimeLayout)

        local palyeTime = 0
        local function upadate()
            palyeTime = palyeTime + 0.1
            if palyeTime > self.oneChatTable["voiceTime"] then
                vioceTimeLayout:stopAllActions()
                vioceSignImg:setVisible(true)
                local actionImg = voiceLayout:getChildByTag(997)

                if actionImg then
                    actionImg:stopAllActions()
                    actionImg:removeFromParent()
                    SoundMgr:replayMusicAndSound()
                    ChatMgr:setIsPlayingVoice(false)
                end

                palyeTime = 0
                return
            end
        end

        -- 播放语音
        local function palyVoice(sender, eventType)
            if ccui.TouchEventType.ended == eventType then

                -- 该语音正在播放(则停止)
                if self.lastPalyVoiceCellTag == i and palyeTime > 0 then
                    self:stopPlayVoice()
                    vioceTimeLayout:stopAllActions()
                    SoundMgr:replayMusicAndSound()
                    palyeTime = 0
                    return
                end

                self:stopPlayVoice()
                vioceTimeLayout:stopAllActions()
                ChatMgr:stopPlayRecord()
                palyeTime = 0
                ChatMgr:setIsPlayingVoice(true) -- 标志在播放语音
                ChatMgr:clearPlayVoiceList() -- 点击播放语音时，清空缓存的语音队列

                schedule(vioceTimeLayout, upadate, 0.1)
                local actionImg =  gf:createLoopMagic(ResMgr.magic.volume)
                actionImg:setPosition(vioceSignImg:getPosition())
                vioceSignImg:setVisible(false)
                voiceLayout:addChild(actionImg, 0, 997)

                if self.oneChatTable["gid"] == Me:queryBasic("gid") then
                    actionImg:setFlippedX(true)
                    actionImg:setAnchorPoint(1, 1)
                end

                ChatMgr:playRecord(self.oneChatTable["token"], 0, self.oneChatTable["voiceTime"], true, function()
                    if vioceTimeLayout and 'function' == type(vioceTimeLayout.stopAllActions) then
                        self:stopPlayVoice()
                        vioceTimeLayout:stopAllActions()
                    end
                end)

                self.lastPlayVoiceLayout = voiceLayout
                self.lastPalyVoiceCellTag = i
            end
        end

        -- 语音点击整句都响应
        chatLayout:setTouchEnabled(true)
        chatLayout:addTouchEventListener(palyVoice)


        local secondLabel = ccui.Text:create()
        secondLabel:setAnchorPoint(0.5,0.5)
        secondLabel:setPosition(vioceTimeImg:getContentSize().width / 2 , vioceTimeImg:getContentSize().height / 2 )
        secondLabel:setString(string.format(CHS[3002134], self.oneChatTable["voiceTime"]))
        secondLabel:setFontSize(19)
        secondLabel:setColor(COLOR3.TEXT_DEFAULT)

        vioceTimeLayout:addChild(secondLabel)


        voiceLayout:setContentSize(textW, vioceSignImg:getContentSize().height + 8) -- 语音和文字之间间隔为8
        vioceSignImg:setPosition(1 + backSprite1:getContentSize().width , voiceLayout:getContentSize().height)
        vioceTimeLayout:setPosition(6 + vioceSignImg:getContentSize().width + vioceSignImg:getPositionX(), voiceLayout:getContentSize().height) -- 语音条和语音之间的间隔为6
        chatLayout:addChild(voiceLayout)

        -- 语音条大于文本的
        if width + vioceSignImg:getContentSize().width + 6 > textW then
            voiceMoreWidth = width + vioceSignImg:getContentSize().width + 6 - textW
        end
    end

    -- 气泡
    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_back_groud2)
    backSprite:setAnchorPoint(0, 0.5)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(textW + 20 + voiceMoreWidth, textH + 20 + voiceLayout:getContentSize().height)  -- 气泡里面的文字和气泡上下左右各10各像素
    chatLayout:setContentSize(textW + 20 + backSprite1:getContentSize().width + voiceMoreWidth, textH + 20 + voiceLayout:getContentSize().height)
    backSprite:setPosition(backSprite1:getContentSize().width, chatLayout:getContentSize().height / 2)
    voiceLayout:setPosition(10, chatLayout:getContentSize().height - 10)
    chatLayout:addChild(backSprite)

    -- 时间
    local tiemLayout = nil
    local tiemHeight = 0
    if self.oneChatTable["time"] - self.lastTime  > 300 then
        tiemLayout = ccui.Layout:create()
        tiemLayout:setAnchorPoint(0.5,0)
        self:addChild(tiemLayout)
        local lableText = CGAColorTextList:create()
        lableText:setFontSize(19)
        lableText:setString(self:getTimeStr(self.oneChatTable["time"]))
        lableText:setContentSize(self.width - iconImg:getContentSize().width, 0)
        lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        lableText:updateNow()
        local timeW, tiemH = lableText:getRealSize()
        local timeColorLayer = tolua.cast(lableText, "cc.LayerColor")
       -- timeColorLayer:setContentSize(timeW, tiemH)
       -- timeColorLayer:setAnchorPoint(0.5, 0.5)

        -- 时间底图
        local tiemBackSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_time_back_groud)
        tiemBackSprite:setLocalZOrder(-1)
        tiemBackSprite:setContentSize(timeW + 10 , tiemBackSprite:getContentSize().height)
        tiemLayout:addChild(tiemBackSprite)


        tiemLayout:setContentSize(tiemBackSprite:getContentSize())  -- 底图的高度比时间高     　
        tiemBackSprite:setPosition(tiemLayout:getContentSize().width / 2, tiemLayout:getContentSize().height / 2)
        timeColorLayer:setPosition((tiemLayout:getContentSize().width - timeW) / 2 , (tiemLayout:getContentSize().height + tiemH )/ 2)
        tiemLayout:addChild(timeColorLayer)
        tiemHeight = tiemLayout:getContentSize().height + 30 -- 消息和时间之间有30像素间隔
    end

    local panelHeight = 0
    if iconImg:getContentSize().height > chatLayout:getContentSize().height + lableHeight  then
        panelHeight = iconImg:getContentSize().height
    else
        panelHeight = chatLayout:getContentSize().height + lableHeight
    end

    panelHeight = panelHeight + tiemHeight
    self:setContentSize(self.width, panelHeight)

    if self.oneChatTable["gid"] == Me:queryBasic("gid") then
        iconImg:setPosition(self.width-iconImg:getContentSize().width, panelHeight)
        local posx, posy = iconImg:getPosition()
        backSprite1:setFlippedX(true)
        backSprite:setPosition(0, chatLayout:getContentSize().height / 2)
        chatLayout:setPosition(posx - chatLayout:getContentSize().width,posy)
        textCtrl:setPosition((chatLayout:getContentSize().width - textW - backSprite1:getContentSize().width) / 2, textH + (chatLayout:getContentSize().height - textH) / 2 - voiceLayout:getContentSize().height/2)

        if vioceSignImg then
            vioceSignImg:setFlippedX(true)
            vioceSignImg:setAnchorPoint(1, 1)
            vioceSignImg:setPositionX(textW + voiceMoreWidth)
            vioceTimeLayout:setAnchorPoint(1, 1)
            vioceTimeLayout:setPositionX(textW + voiceMoreWidth - vioceSignImg:getContentSize().width - 6)
        end

        if chatLayout:getContentSize().height < iconImg:getContentSize().height then
            backSprite1:setPosition(backSprite:getContentSize().width - 2,  chatLayout:getContentSize().height / 2 + backSprite1:getContentSize().height / 2)
        else
            backSprite1:setPosition(backSprite:getContentSize().width - 2 , chatLayout:getContentSize().height - iconImg:getContentSize().height / 2 + backSprite1:getContentSize().height / 2)
        end
    else
        labelLayout:setPosition(iconImg:getContentSize().width + backSprite1:getContentSize().width,panelHeight)
        backSprite1:setPositionY(chatLayout:getContentSize().height - 12)
        textCtrl:setPosition((chatLayout:getContentSize().width - textW + backSprite1:getContentSize().width) / 2, textH + (chatLayout:getContentSize().height - textH) / 2 - voiceLayout:getContentSize().height/2)
        iconImg:addTouchEventListener(imgTouch)
        iconImg:setPosition(0,panelHeight)
        chatLayout:setPosition(iconImg:getContentSize().width ,panelHeight - lableHeight)
    end

    if tiemLayout then
        tiemLayout:setPosition(self.width/2, 20)
    end
end

function CanChatCell:refresh(oneChatTable, lastTime)
    self.oneChatTable = oneChatTable
    self.lastTime = lastTime
    self:create()
end

function CanChatCell:setChatPanel(chatPanel)
    self.chatPanel = chatPanel
end

function CanChatCell:stopPlayVoice()
    if self.chatPanel and self.chatPanel.stopPlayVoice then
        self.chatPanel:stopPlayVoice()
    end
end

function CanChatCell:onCharInfo(gid, char)
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    if dlg then
        local colseBtn = dlg:getControl("CloseButton")
        local dlgSize = dlg.root:getContentSize()

        dlg.root:setPositionX(dlg.root:getPositionX() + 100)
        if FriendMgr:getCharMenuInfoByGid(gid) then
            dlg:setting(gid)
        else
            if char then
                dlg:setInfo(char)
            end
        end
    end
end

return CanChatCell