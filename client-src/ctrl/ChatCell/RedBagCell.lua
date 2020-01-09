-- RedBagCell.lua
-- Created by sujl, Dec/8/2016
-- 红包聊天控件

local ChatCell = require("ctrl/ChatCell/ChatCell")
local RedBagCell = class("RedBagCell", ChatCell)

local WORD_COLOR = cc.c3b(86, 41, 2)

function RedBagCell:ctor(oneChatTable, width, lastTime)
    self.oneChatTable = oneChatTable
    self.width = width
    self.lastTime = lastTime
    self:create()
end

function RedBagCell:create()
    self:removeAllChildren()

    local width = self.width
    self:setPosition(0,0)

    -- 头像边框
    local iconImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    local function imgTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理弹出名片
            local dlg = DlgMgr:openDlg("CharMenuContentDlg")
            local porCtrl = dlg:getControl("PortraitPanel")
            local colseBtn = dlg:getControl("CloseButton")
            local dlgSize = dlg.root:getContentSize()
            local char = {}
            char.gid = self.oneChatTable["gid"]
            char.name = self.oneChatTable["name"]
            char.level = self.oneChatTable["level"]
            char.icon = self.oneChatTable["icon"]
            dlg:setting(self.oneChatTable["gid"])
            dlg:setInfo(char)
            dlg.root:setPositionX(dlg.root:getPositionX() + 100)
        end
    end
    iconImg:setTouchEnabled(true)
    iconImg:setAnchorPoint(0,1)
    self:addChild(iconImg)

    -- 头像
    local imgPath = ResMgr:getSmallPortrait(self.oneChatTable["icon"])
    local protriatIcon = ccui.ImageView:create(imgPath)
    protriatIcon:setAnchorPoint(0.5, 0.5)
    protriatIcon:setPosition(iconImg:getContentSize().width / 2  , iconImg:getContentSize().height / 2)
    gf:setItemImageSize(protriatIcon)
    iconImg:addChild(protriatIcon)
    self.protriatIcon = protriatIcon

    -- 等级
    if self.oneChatTable["level"]  then
        Dialog.setNumImgForPanel(nil, iconImg, ART_FONT_COLOR.NORMAL_TEXT, self.oneChatTable["level"], false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 名字
    local labelLayout = nil
    local lableHeight = 0
    if self.oneChatTable["gid"] ~= Me:queryBasic("gid") then
        labelLayout = ccui.Layout:create()
        labelLayout:setAnchorPoint(0,1)
        self:addChild(labelLayout)
        self.nameLabelLayout = labelLayout
        local labelText = CGAColorTextList:create()
        labelText:setFontSize(21)
        labelText:setString(gf:getRealName(self.oneChatTable["name"]))
        labelText:setContentSize(self.width - iconImg:getContentSize().width*2, 0)
        labelText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        labelText:updateNow()
        local labelW, labelH = labelText:getRealSize()
        labelText:setPosition(0, labelH)
        labelLayout:addChild(tolua.cast(labelText, "cc.LayerColor"))
        lableHeight = labelH
        labelLayout:setContentSize(labelW,labelH)
        self.nameLabel = labelText
    end
    self.forMe = self.oneChatTable["gid"] == Me:queryBasic("gid")

    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    self:addChild(chatLayout)

    -- 尖角
    local backSprite1 = ccui.ImageView:create(ResMgr.ui.chat_red_bag_back_groud1)
    backSprite1:setAnchorPoint(0, 1)
    backSprite1:setLocalZOrder(10)
    backSprite1:setPosition(2, chatLayout:getContentSize().height / 2)
    chatLayout:addChild(backSprite1)

    -- 内容包括图片和文字
    local contentLayout = ccui.Layout:create()
    contentLayout:setAnchorPoint(0, 1)

    -- 红包图片
    local redBag = ccui.ImageView:create(ResMgr.ui.red_bag_image)
    redBag:setAnchorPoint(0, 0)
    contentLayout:addChild(redBag)

    -- 文本
    local redbag = ChatMgr:getRedbagIdByMsg(self.oneChatTable["chatStr"])
    local text = gf:getTextByLenth(redbag.msg or "", 18)
    local textMaxWidth = self.width - iconImg:getContentSize().width  - backSprite1:getContentSize().width -  redBag:getContentSize().width - 30
    local textCtrl = CGAColorTextList:create(true)
    textCtrl:setFontSize(19)
    textCtrl:setString(text, self.oneChatTable["show_extra"])
    textCtrl:setContentSize(textMaxWidth, 0)
    textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    contentLayout:addChild(layer)
    self.textCtrl = textCtrl

    -- 红包状态
    local statuslabelText = CGAColorTextList:create(true)
    statuslabelText:setFontSize(19)
    statuslabelText:setString(CHS[2000199])
    statuslabelText:setContentSize(textMaxWidth, 0)
    statuslabelText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    statuslabelText:updateNow()
    local labelW, labelH = statuslabelText:getRealSize()
    statuslabelText:setPosition(redBag:getContentSize().width + 10, labelH + 5)
    contentLayout:addChild(tolua.cast(statuslabelText, "cc.LayerColor"))

    local contentWidth = textMaxWidth + redBag:getContentSize().width + 10  -- 10 是红包图片和文字的间距
    local contentHeight = redBag:getContentSize().height

    textCtrl:setPosition(redBag:getContentSize().width + 10, contentHeight - 1)
    contentLayout:setContentSize(contentWidth, contentHeight)

    local function openRedBag (sender, type)
        if ccui.TouchEventType.ended == type then
        	if Me:queryInt("level") < 50 then
                gf:ShowSmallTips(CHS[6000446])
                return
        	end

            if Me:queryBasic("party/name") == "" then
                gf:ShowSmallTips(CHS[6000461])
                return
            end

            local redbag = ChatMgr:getRedbagIdByMsg(self.oneChatTable["chatStr"])

            if redbag.gid then
                PartyMgr:openRedBag(redbag.gid)
            end
        end
    end

    -- 红包点击整句都响应
    chatLayout:addChild(contentLayout)
    chatLayout:setAnchorPoint(0,1)
    chatLayout:setTouchEnabled(true)
    chatLayout:addTouchEventListener(openRedBag)

    -- 气泡
    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_back_groud2)
    backSprite:setAnchorPoint(0, 0.5)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(contentWidth + 20 , contentHeight + 20)  -- 气泡里面的文字和气泡上下左右各10各像素
    chatLayout:setContentSize(contentWidth + 20 + backSprite1:getContentSize().width , contentHeight + 20)
    backSprite:setPosition(backSprite1:getContentSize().width, chatLayout:getContentSize().height / 2)
    chatLayout:addChild(backSprite)

    -- 时间
    local tiemLayout = nil
    local tiemHeight = 0
    if self.oneChatTable["time"] - self.lastTime  > 300 then
        tiemLayout = ccui.Layout:create()
        tiemLayout:setAnchorPoint(0.5,0)
        self:addChild(tiemLayout)
        local labelText = CGAColorTextList:create()
        labelText:setFontSize(19)
        labelText:setString(self:getTimeStr(self.oneChatTable["time"]))
        labelText:setContentSize(self.width - iconImg:getContentSize().width, 0)
        labelText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        labelText:updateNow()
        local timeW, tiemH = labelText:getRealSize()
        local timeColorLayer = tolua.cast(labelText, "cc.LayerColor")
        self.timeText = labelText

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
        iconImg:setPosition(self.width - iconImg:getContentSize().width, panelHeight)
        local posx, posy = iconImg:getPosition()
        backSprite1:setFlippedX(true)
        backSprite:setPosition(0, chatLayout:getContentSize().height / 2)
        chatLayout:setPosition(posx - chatLayout:getContentSize().width,posy)
        contentLayout:setPosition((chatLayout:getContentSize().width - contentWidth - backSprite1:getContentSize().width) / 2, contentHeight + (chatLayout:getContentSize().height - contentHeight) / 2 )

        if chatLayout:getContentSize().height < iconImg:getContentSize().height then
            backSprite1:setPosition(backSprite:getContentSize().width - 2,  chatLayout:getContentSize().height / 2 + backSprite1:getContentSize().height / 2)
        else
            backSprite1:setPosition(backSprite:getContentSize().width - 2 , chatLayout:getContentSize().height - iconImg:getContentSize().height / 2 + backSprite1:getContentSize().height / 2)
        end
    else
        labelLayout:setPosition(iconImg:getContentSize().width + backSprite1:getContentSize().width,panelHeight)
        backSprite1:setPositionY(chatLayout:getContentSize().height - 12)
        contentLayout:setPosition((chatLayout:getContentSize().width - contentWidth + backSprite1:getContentSize().width) / 2, contentHeight + (chatLayout:getContentSize().height - contentHeight) / 2 )
        iconImg:addTouchEventListener(imgTouch)
        iconImg:setPosition(0,panelHeight)
        chatLayout:setPosition(iconImg:getContentSize().width ,panelHeight - lableHeight)
    end

    if tiemLayout then
        tiemLayout:setPosition(self.width / 2, 20)
    end
end

function RedBagCell:refresh(oneChatTable, lastTime)
    self.oneChatTable = oneChatTable
    self.lastTime = lastTime
    self:create()
end

return RedBagCell