-- ChatPanel.lua
-- Created by zhengjh Feb/11/2015
-- 显示聊天内容


local ChatPanel = class("ChatPanel", function()
    return ccui.Layout:create()
end)

local WORD_COLOR = cc.c3b(86, 41, 2)
local NumImg = require('ctrl/NumImg')

local TEXT_HEIGHT_MARGIN = 31  -- 气泡上下边距
local TEXT_WIDTH_MARGIN = 31  -- 气泡左右两边边距

-- 气泡背景最小尺寸
local BUBBLE_HEIGHT_MIN = 82
local BUBBLE_WIDTH_MIN = 82

local CHAT_UP_OFFSET_HEIGHT = 15  -- 聊天内容（包括气泡）上移高度

local CHAT_DOWN_SHRINK_HEIGHT = 15 -- 聊天内容所占高度缩小高度

local SHOW_TIME_SPACE = 300

local CONST_DATA =
{
    loadNumber = 10,-- 每次滚动加载的条目
    initCanChatNumber = 15,-- 初值化聊天条目 （可以交互聊天）
    initCannotChatNumber = 22,-- 初值化聊天条目 （不可以交互聊天）
    cellSpace = 8,
    containerTag = 999,
    CS_TYPE_STRING = 1,
    CS_TYPE_IMAGE = 2,
    CS_TYPE_BROW = 3,
    CS_TYPE_ANIMATE = 4,
    CS_TYPE_NPC = 5,
    CS_TYPE_ZOOM = 6,
    CS_TYPE_URL = 7,
    CS_TYPE_CARD = 8,
    CS_TYPE_CALL = 11,
}

local CONST_WDAY =
    {
        [1] = CHS[4000160], -- 天
        [2] = CHS[6000055], -- 一
        [3] = CHS[6000056], -- 二
        [4] = CHS[6000057], -- 三
        [5] = CHS[6000058], -- 四
        [6] = CHS[6000059], -- 五
        [7] = CHS[6000060], -- 六
    }

local curPlayRecord = {}

-- iSCanChat = true  chatTabel要有[gid 表示玩家唯一id] [icon 玩家头像] [chatStr 聊天单句内容] [name 玩家名字] [time 聊天时间] [show_extra vip] [token 获取录音的key] [voiceTime 语音时长] [needFresh]
-- iSCanChat = false  chatTabel要有 [channel 表示频道] [chatStr 聊天单句内容] [show_extra vip] [token 获取录音的key] [voiceTime 语音时长]
function ChatPanel:ctor(chatTabel, contentSize, iSCanChat, singleChatPanel, param)
    self:setContentSize(contentSize)
    self.scroview = ccui.ScrollView:create()
    self.chatTabel = chatTabel
    self.lastChatNum = #chatTabel
    self.lastLoadIndex = 1 -- 初值化加载索引
    self.lastUpLoadIndex = nil
    self.iSCanChat = iSCanChat
    self.singleChatPanel = singleChatPanel

    self:setParam(param)

    if self.iSCanChat then
        self.initNumber = CONST_DATA.initCanChatNumber
    else
        self.initNumber = CONST_DATA.initCannotChatNumber
    end

    local innerSizeheight = 0
    local container = ccui.Layout:create()
    self.loadCount = 0
    container:setPosition(0,0)
    self.scroview:setContentSize(contentSize)
    self.scroview:setDirection(ccui.ScrollViewDir.vertical)
    self.scroview:addChild(container, 0, CONST_DATA.containerTag)
    self:loadInitData()

  --self.scroview:setEventNeedNotifyParent(true)

    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
            self:loadMoreCell()
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            --print("ccui.ScrollviewEventType.bounceTop")
            if not self.canRefreshByOther and not self.notCallScrollTop then
                self:upLoadMoreCell()
            end
        elseif eventType == ccui.ScrollviewEventType.scrolling then
        end
    end

    self.scroview:addEventListener(scrollListener)
    self:addChild(self.scroview)

    self.scroview:setPositionY(-2)
end

function ChatPanel:setParam(param)
    self.portraitScale = 1
    self.charFloatOffectX = 100
    if not param then
        return
    end

    if param.portraitScale then
        self.portraitScale = param.portraitScale
    end

    if param.charFloatOffectX then
        self.charFloatOffectX = param.charFloatOffectX
    end
end

function ChatPanel:canRefenshChat()
    return self.canRefreshByOther
end

function ChatPanel:loadInitData(endIndex, notRefreshNewChat)
    local innerSizeheight = 0
    local container = self.scroview:getChildByTag(CONST_DATA.containerTag)

    if not endIndex then
        endIndex = #self.chatTabel
        self.canRefreshByOther = true
    else
        -- 定位到已有消息中间，此时不让外部控制将消息初始化到顶部，
        -- 而是 ChatPanel 内部自己一边向上滑动一边加载缓存的旧数据显示
        -- 直到加载到缓存的旧数据加载完毕，才将 self.canRefreshByOther = true
        self.canRefreshByOther = false
    end

    -- 加载超过初值化的数量全部移除
    local index = self.chatTabel[endIndex] and self.chatTabel[endIndex]["index"] or 0
    if self.lastLoadData
        and (endIndex  - #self.lastLoadData >= self.initNumber
            or self.lastLoadIndex > index) then

        container:removeAllChildren()

        -- 所有的内容都被清除了，需要清空上一次语音播放信息
        self.lastPlayVoiceLayout = nil
        self.lastPalyVoiceCellTag = 0
    end

    -- 复制一份数据，用来储存当前加载的数据，用于向下滑动加载数据
    self.lastLoadData = {}
    for i = 1, endIndex do
        table.insert(self.lastLoadData, self.chatTabel[i])
    end

   -- container:removeAllChildren()
    self.loadCount = 0
    local sartIndex = 0
    if  endIndex - self.initNumber + 1 < 1 then
        sartIndex = 1
    else
        sartIndex = endIndex - self.initNumber + 1
    end


    local locationH -- 定位的高度
    local i = sartIndex
    while i <= endIndex do
        local lastTime = 0
        local index = self.chatTabel[i]["index"]
        if  self.chatTabel[i - 1] then
            lastTime = self.chatTabel[i - 1]["time"]
        end

        local cellPanel = container:getChildByTag(index)

        if cellPanel then
            if self.chatTabel[i]["needFresh"] == true then
                local playTime = cellPanel.voiceLayout.playTime
                if cellPanel.voiceLayout == self.lastPlayVoiceLayout and playTime and playTime > 0 and playTime < self.chatTabel[i]["voiceTime"] then
                    -- 有屏蔽字不继续播语音
                    if self.chatTabel[i]["haveFilt"] then
                        self.chatTabel[i]["playTime"] = 0
                        self:stopPlayVoice()
                        SoundMgr:replayMusicAndSound()
                    else
                        self.chatTabel[i]["playTime"] = playTime
                    end
                end

                cellPanel:removeFromParent()
                local cellPanel = self:createOnechat(self.chatTabel[i], lastTime, index)
                cellPanel:setPosition(0,innerSizeheight)
                innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
                container:addChild(cellPanel, 0 , index)
                self.chatTabel[i]["needFresh"]  = false
                if self.lastPalyVoiceCellTag == index then
                    self.lastPlayVoiceLayout = nil
                    self.lastPalyVoiceCellTag = 0
                end
            else
                cellPanel:setPosition(0,innerSizeheight)
                innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
            end
        else
            local cellPanel = self:createOnechat(self.chatTabel[i], lastTime, index)
            cellPanel:setPosition(0,innerSizeheight)
            innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA.cellSpace
            container:addChild(cellPanel, 0 , index)
        end

        if i == endIndex
            and notRefreshNewChat
            and endIndex < #self.chatTabel
            and innerSizeheight < self.scroview:getContentSize().height + 5 then
            -- 建完预定数据高度不够，无法使滑动框不置顶，在向上多加载几条数据
            endIndex = endIndex + 1

            if not locationH then
                locationH = innerSizeheight
            end
        end

        i = i + 1
    end

    -- 加载中间部分时，上下都要搜，用于清除语音及聊天控件
    local index = self.chatTabel[endIndex] and self.chatTabel[endIndex]["index"] or 0
    if self.lastUpLoadIndex and self.lastUpLoadIndex > index then
        for j = self.lastUpLoadIndex, index + 1, -1 do
            -- 搜上部分
            local cellPanel = container:getChildByTag(j)

            if cellPanel then
                cellPanel:removeFromParent()
            end

            if self.lastPalyVoiceCellTag == j then
                -- 上一次语音播放对应的节点被清除了，需要清理一下相关变量
                self.lastPlayVoiceLayout = nil
                self.lastPalyVoiceCellTag = 0
            end
        end
    end

    local loadNum = endIndex - sartIndex
    for j = index - loadNum - 1, self.lastLoadIndex, -1 do
        -- 搜下部分
        local cellPanel = container:getChildByTag(j)

        if cellPanel then
            cellPanel:removeFromParent()
        end

        if self.lastPalyVoiceCellTag == j then
            -- 上一次语音播放对应的节点被清除了，需要清理一下相关变量
            self.lastPlayVoiceLayout = nil
            self.lastPalyVoiceCellTag = 0
        end
    end

    -- 标志被加载过的最小的索引
    if self.chatTabel[sartIndex] then
        self.lastLoadIndex = self.chatTabel[sartIndex]["index"]
    end

    -- 标志被加载过的最大的索引
    if index then
        self.lastUpLoadIndex = index
    end

    -- 复制一份数据，用来储存当前加载的数据，用于向上滑动加载数据
    self.upLoadCount = 0
    self.lastUpLoadData = {}
    for i = endIndex + 1, #self.chatTabel do
        table.insert(self.lastUpLoadData, self.chatTabel[i])
    end

    container:setContentSize(self:getContentSize().width, innerSizeheight)

    -- 内容小于显示区域往上移
    if container:getContentSize().height < self.scroview:getContentSize().height then
        for  i = sartIndex, endIndex do
            local index = self.chatTabel[i]["index"]
            local cell = container:getChildByTag(index)
            if cell then
                local posx, posy = cell:getPosition()
                cell:setPosition(posx, posy + self.scroview:getContentSize().height - innerSizeheight)
            end
        end
    end

    self.notCallScrollTop = true
    -- setInnerContainerSize 接口在设置 Inner 大小前会调用滑动的回调函数，将滑动框滚到顶部，导致提前调用了 self:upLoadMoreCell()
    -- 此时设置 self.notCallScrollTop 不让调用 self:upLoadMoreCell()
    self.scroview:setInnerContainerSize(container:getContentSize())
    self.notCallScrollTop = false

    if notRefreshNewChat and container:getContentSize().height - self.scroview:getContentSize().height > 5 then
        -- 定位后，滑动滚动框，否则滑动框置顶时，会立即在调用 loadInitData 加载数据
        if not locationH then
            self.scroview:getInnerContainer():setPositionY(- (container:getContentSize().height - self.scroview:getContentSize().height - 5))
        else
            self.scroview:getInnerContainer():setPositionY(0)
        end
    end
end

-- 创建头像装饰边框（该边框要显示在 等级下）
function ChatPanel:creatHeadFrame(cell, chatData)
    local itemInfo = InventoryMgr:getItemInfoByName(chatData["chat_head"])
    if itemInfo and itemInfo["chat_icon"] then
        local framIcon = ccui.ImageView:create(itemInfo["chat_icon"])
        local size = cell:getContentSize()
        framIcon:setAnchorPoint(0.5, 0.5)
        framIcon:setPosition(size.width / 2, size.height / 2)
        framIcon:ignoreContentAdaptWithSize(false)
        framIcon:setContentSize(90, 90)
        cell:addChild(framIcon)
    end
end

function ChatPanel:getChatBubbleBack(chatData, isRedBag)
    local itemInfo = InventoryMgr:getItemInfoByName(chatData["chat_floor"])
    local capRect = cc.rect(48, 40, 2, 2)
    if chatData["channel"] == CHAT_CHANNEL.HORN then
        -- 喇叭背景气泡
        local itemInfo = InventoryMgr:getItemInfoByName(chatData["horn_name"])
        if itemInfo and itemInfo["chat_icon"] then
            -- 大 R 背景气泡
            return itemInfo["chat_icon"], ccui.TextureResType.localType, capRect
        else
            return ResMgr.ui.chat_horn_back_groud, ccui.TextureResType.localType, capRect
        end
    elseif isRedBag then
        -- 红包背景气泡
        return ResMgr.ui.chat_red_bag_back_groud, ccui.TextureResType.plistType, capRect
    elseif itemInfo and itemInfo["chat_icon"] then
        -- 大 R 背景气泡
        return itemInfo["chat_icon"], ccui.TextureResType.localType, capRect
    else
        -- 默认
        return ResMgr.ui.chat_def_back_groud, ccui.TextureResType.plistType, capRect
    end
end

-- 创建聊天气泡背景
function ChatPanel:createChatBubble(oneChatTable, isRedBag)
    local imgPath, resType, capRect = self:getChatBubbleBack(oneChatTable, isRedBag)
    local backSprite = ccui.ImageView:create(imgPath, resType)

    backSprite:setCapInsets(capRect)
    backSprite:ignoreContentAdaptWithSize(false)
    backSprite:setScale9Enabled(true)

    return backSprite
end

function ChatPanel:creatTimePanel(oneChatTable)
    local tiemLayout = nil
    local tiemHeight = 0
    tiemLayout = ccui.Layout:create()
    tiemLayout:setAnchorPoint(0.5,0)
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(19)
    lableText:setString(self:getTiemStr(oneChatTable["time"]))
    lableText:setContentSize(self:getContentSize().width, 0)
    lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    lableText:updateNow()
    local timeW, tiemH = lableText:getRealSize()
    local timeColorLayer = tolua.cast(lableText, "cc.LayerColor")

    -- 时间底图
    local tiemBackSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_time_back_groud)
    tiemBackSprite:setLocalZOrder(-1)
    tiemBackSprite:setContentSize(timeW + 10 , tiemBackSprite:getContentSize().height)
    tiemLayout:addChild(tiemBackSprite)

    local tiemSize = tiemBackSprite:getContentSize()
    tiemLayout:setContentSize(tiemSize)  -- 底图的高度比时间高     　
    tiemBackSprite:setPosition(tiemSize.width / 2, tiemSize.height / 2)
    timeColorLayer:setPosition((tiemSize.width - timeW) / 2 , (tiemSize.height + tiemH )/ 2)
    tiemLayout:addChild(timeColorLayer)
    tiemLayout:setPosition(self:getContentSize().width / 2, 20)
    tiemHeight = tiemLayout:getContentSize().height + 30 -- 消息和时间之间有30像素间隔

    return tiemLayout, tiemHeight
end

function ChatPanel:createOnechat(oneChatTable, lastTime, i)
    local cellPanel = nil
    if self.iSCanChat then
        if ChatMgr:isRedBagMsg(oneChatTable["chatStr"]) then -- 红包
            cellPanel = self:createRedBagCell(oneChatTable, lastTime, i)
        elseif oneChatTable["sysTipType"] then  -- 系统提示语
            cellPanel = self:createSysTipCell(oneChatTable, lastTime, i)
        else
            cellPanel = self:createCanChatCell(oneChatTable, lastTime, i)
        end
    else
        cellPanel = self:createCanNotChatCell(oneChatTable)
    end
    return cellPanel
end

function ChatPanel:createSysTipCell(oneChatTable, lastTime, i)
    local chatCellPanel = ccui.Layout:create()
    chatCellPanel:setPosition(0,0)

    -- 提示内容
    local chatLayout = ccui.Layout:create()
    chatLayout:setAnchorPoint(0.5, 0)
    chatCellPanel:addChild(chatLayout)

    local lableText = CGAColorTextList:create()
    lableText:setFontSize(19)
    lableText:setString(oneChatTable["chatStr"], true)
    lableText:setContentSize(self:getContentSize().width, 0)
    lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    lableText:updateNow()
    local timeW, timeH = lableText:getRealSize()
    local colorLayer = tolua.cast(lableText, "cc.LayerColor")

    -- 底图
    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_time_back_groud)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(timeW + 20, timeH + 10)
    chatLayout:addChild(backSprite)

    local chatSize = backSprite:getContentSize()
    chatLayout:setContentSize(chatSize)  -- 底图的高度比时间高     　
    backSprite:setPosition(chatSize.width / 2, chatSize.height / 2)
    colorLayer:setPosition((chatSize.width - timeW) / 2 , (chatSize.height + timeH )/ 2)
    chatLayout:addChild(colorLayer)

    -- 时间
    local tiemLayout = nil
    local tiemHeight = 0
    if oneChatTable["time"] - lastTime  > SHOW_TIME_SPACE then
        tiemLayout, tiemHeight = self:creatTimePanel(oneChatTable)
        chatCellPanel:addChild(tiemLayout)
    end

    local panelHeight = chatSize.height + tiemHeight
    chatCellPanel:setContentSize(self:getContentSize().width, panelHeight)
    chatLayout:setPosition(self:getContentSize().width / 2, tiemHeight)

    return chatCellPanel
end

-- 可以聊天交互面板
function ChatPanel:createCanChatCell(oneChatTable, lastTime, i)
    -- 除了系统频道以外非 NPC 发言的 系统消息
    if oneChatTable["gid"] == 0
        and (not oneChatTable["icon"] or oneChatTable["icon"] == 0 or not oneChatTable["name"] or oneChatTable["name"] == "") then
        return  self:createCanNotChatCell(oneChatTable)
    end

    local width = self:getContentSize().width
    local chatCellPanel = ccui.Layout:create()
    chatCellPanel:setPosition(0,0)

    -- 头像边框
    local iconImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    local function imgTouch(sender, eventType)
        if oneChatTable["gid"] == 0 then
            return
        end

        local canCall = false
        if self.singleChatPanel
            and (self.singleChatPanel.channelName == CHAT_CHANNEL["PARTY"]
            or self.singleChatPanel.channelName == CHAT_CHANNEL["CHAT_GROUP"]) then
            canCall = true
        end

        if ccui.TouchEventType.began == eventType then
            if canCall then
                sender.delayAction = performWithDelay(sender, function()
                    if GuideMgr:isRunning() then
                        return
                    end

                    sender.delayAction = nil

                    if sender:isHighlighted() then
                        -- 会响应 canceled 事件，不处理长按回调
                        -- 过滤掉左下角角色职称
                        local name = string.match(oneChatTable["name"], "(.*) .*")
                        if not name then
                            name = oneChatTable["name"]
                        end

                        self.singleChatPanel:addCallChar(gf:getRealName(name))
                    end
                end, GameMgr:getLongPressTime())
            end
        elseif ccui.TouchEventType.ended == eventType then
            if sender.delayAction or not canCall then
                sender:stopAction(sender.delayAction)
                sender.delayAction = nil

                -- WDSY-28586设定npc无需弹出菜单
                if FriendMgr:isNpcByGid(oneChatTable["gid"]) then
                    return
                end

                -- 处理弹出名片
                FriendMgr:requestCharMenuInfo(oneChatTable["gid"])
                ChatMgr:setTipData(oneChatTable)

                -- 过滤掉左下角角色职称
                local name = string.match(oneChatTable["name"], "(.*) .*")
                if not name then
                    name = oneChatTable["name"]
                end

                local char = {}
                char.gid = oneChatTable["gid"]
                char.name = name
                char.level = oneChatTable["level"]
                char.icon = oneChatTable["icon"]
                self:onCharInfo(char.gid, char)
            end
        elseif ccui.TouchEventType.canceled == eventType then
            sender:stopAction(sender.delayAction)
            sender.delayAction = nil
        end
    end
    iconImg:setTouchEnabled(true)
    iconImg:setScale(self.portraitScale)
    iconImg:setAnchorPoint(0,1)
    chatCellPanel:addChild(iconImg)

    -- 头像
    local imgPath = ResMgr:getSmallPortrait(tonumber(oneChatTable["npc_icon"] or oneChatTable["icon"]))
    local protriatIcon = ccui.ImageView:create(imgPath)
    protriatIcon:setAnchorPoint(0.5, 0.5)
    protriatIcon:setPosition(iconImg:getContentSize().width / 2  , iconImg:getContentSize().height / 2)
    gf:setItemImageSize(protriatIcon)
    iconImg:addChild(protriatIcon)

    -- 手表图标
    local channelSource = oneChatTable["channel_source"]
    if channelSource == CHANNEL_SOURCE.CHANNEL_SOURCE_APPLE_WATCH then
        local watchIcon = ccui.ImageView:create(ResMgr.ui.watch_image)
        watchIcon:setAnchorPoint(1, 0)
        watchIcon:setPosition(iconImg:getContentSize().width, 0)
        iconImg:addChild(watchIcon)
    end

    if FriendMgr:getKuafObjDist(oneChatTable["gid"]) then
        gf:addKuafLogo(iconImg)
    end

    -- 创建头像装饰边框（该边框要显示在 等级下）
    self:creatHeadFrame(protriatIcon, oneChatTable)

    if oneChatTable["gid"] ~= 0 and not oneChatTable["npc_icon"] then
        -- 等级，NPC 头像不显示等级
        if oneChatTable["level"] and tonumber(oneChatTable["level"]) and tonumber(oneChatTable["level"]) > 0 then
            self:setNumImgForPanel(iconImg, ART_FONT_COLOR.NORMAL_TEXT, oneChatTable["level"], false, LOCATE_POSITION.LEFT_TOP, 19)
        end
    end


    -- 名字
    local labelLayout = nil
    local lableHeight = 0
    if not self:isMeMsg(oneChatTable) then
        local showName = gf:getRealName(oneChatTable["npc_name"] or oneChatTable["name"])
        if oneChatTable["gid"] == 0 or oneChatTable["npc_name"] then
            showName = string.format("#i%s#i %s", ResMgr.ui.npc_word_chat, showName)
        end

        local patryJob = string.match(showName, " #B(.+)#n")
        if patryJob then
            showName = string.gsub(showName, " #B.+#n", "")
            local icon = ResMgr:getPartyJobWordImagePath(patryJob)
            if icon then
                showName = string.format("%s #i%s#i", showName, icon)
            end
        end

        labelLayout = ccui.Layout:create()
        labelLayout:setAnchorPoint(0, 1)
        chatCellPanel:addChild(labelLayout)
        local lableText = CGAColorTextList:create()
        lableText:setFontSize(21)
        lableText:setString(showName)
        lableText:setContentSize(self:getContentSize().width-iconImg:getContentSize().width, 0)
        lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        lableText:updateNow()
        local labelW, labelH = lableText:getRealSize()
        lableText:setPosition(0, labelH)
        labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
        lableHeight = labelH
        labelLayout:setContentSize(labelW,labelH)

        if oneChatTable.comeback_flag == 1 then
            local image = ccui.ImageView:create(ResMgr.ui.comeback_flag)
            image:setPosition(labelW + image:getContentSize().width * 0.5 + 3, image:getContentSize().height * 0.5)
            labelLayout:addChild(image)
        end
    end

    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    chatCellPanel:addChild(chatLayout)

    -- 文本
    local chatStr = oneChatTable["chatStr"]
    local articleId, articleTitle, comment
    if string.match(chatStr, "{\t.*\t}") then
        articleTitle, articleId, comment = string.match(chatStr, "{\t(.*)\27(.*)\27(.*)\t}")
        chatStr = ""
    end

    local textMaxWidth = self:getContentSize().width- iconImg:getContentSize().width - TEXT_WIDTH_MARGIN * 2
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(chatStr, oneChatTable["show_extra"])
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

    local sqPanel = ccui.Layout:create()
    local sqSignImg, sqTitle, sendLabel
    sqPanel:setContentSize(cc.size(0, 0))
    if not string.isNilOrEmpty(articleId) and not string.isNilOrEmpty(articleTitle) then
        -- 链接
        sqPanel:setAnchorPoint(0, 1)

        -- 标志
        sqSignImg = ccui.ImageView:create("ui/Icon1630.png")
        sqSignImg:setAnchorPoint(0, 1)
        sqPanel:addChild(sqSignImg, 0, 996)

        -- 标题
        sqTitle = CGAColorTextList:create()
        sqTitle:setFontSize(19)
        if gf:getTextLength(articleTitle) <= 40 then
            sqTitle:setString(articleTitle)
        else
            sqTitle:setString(gf:subString(articleTitle, 38) .. "...")
        end
        sqTitle:setContentSize(200, 0)
        sqTitle:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        sqTitle:updateNow()
        sqPanel:addChild(tolua.cast(sqTitle, "cc.LayerColor"))
        local textW, textH = sqTitle:getRealSize()

        -- 线框
        local lineImg = ccui.ImageView:create("Frame0020.png", ccui.TextureResType.plistType)
        lineImg:setAnchorPoint(0, 0.5)
        sqPanel:addChild(lineImg)

        sendLabel = ccui.Text:create()
        sendLabel:setAnchorPoint(0, 1)
        sendLabel:setString(CHS[2200081])
        sendLabel:setFontSize(15)
        sendLabel:setColor(cc.c3b(148, 122, 101))
        sqPanel:addChild(sendLabel)

        -- 显示网页
        local function showMsg(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                if not articleId then return end
                CommunityMgr:openCommunityDlg(articleId)
            end
        end

        -- 点击整句都响应
        chatLayout:setTouchEnabled(true)
        chatLayout:addTouchEventListener(showMsg)

        sqPanel:setContentSize(cc.size(math.max(sqSignImg:getContentSize().width + 11 + 33 + 19 + textW, 210), 92))
        sqSignImg:setPosition(0, sqPanel:getContentSize().height - 19)
        sqTitle:setPosition(sqSignImg:getContentSize().width + 11, sqPanel:getContentSize().height - 23)
        lineImg:ignoreContentAdaptWithSize(false)
        lineImg:setContentSize(cc.size(sqPanel:getContentSize().width - TEXT_WIDTH_MARGIN * 2, 2))
        lineImg:setPosition(0, sqPanel:getContentSize().height - 19 - sqSignImg:getContentSize().height - 5)
        sendLabel:setPosition(0, sqPanel:getContentSize().height - 19 - sqSignImg:getContentSize().height - 10)
        chatLayout:addChild(sqPanel)
    end

    -- 语音
    local voiceLayout = ccui.Layout:create()
    voiceLayout:setContentSize(0, 0)
    local vioceSignImg, vioceTimeLayout = nil
    local voiceMoreWidth = 0            -- 语音条比文本多出的长度
    if oneChatTable["token"] and string.len(oneChatTable["token"]) > 0 then
        voiceLayout:setAnchorPoint(0, 1)

        -- 语音标志
        vioceSignImg = ccui.ImageView:create(ResMgr.ui.vioce_sign)
        vioceSignImg:setAnchorPoint(0, 1)
        voiceLayout:addChild(vioceSignImg, 0, 996)

        -- 语音条
        vioceTimeLayout = ccui.Layout:create()
        vioceTimeLayout:setAnchorPoint(0, 1)
        local width = 46 + (224- 46) / 14 * (tonumber(string.format("%d", oneChatTable["voiceTime"]))- 1)  -- 根据秒数算出长度
        local vioceTimeImg =  cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.vioce_time_back)
        vioceTimeImg:setContentSize(width, vioceTimeImg:getContentSize().height)
        vioceTimeImg:setAnchorPoint(0, 0)
        vioceTimeLayout:addChild(vioceTimeImg)

        vioceTimeLayout:setContentSize(vioceTimeImg:getContentSize())
        --vioceTimeLayout:setTouchEnabled(true)
        voiceLayout:addChild(vioceTimeLayout)
        chatCellPanel.voiceLayout = voiceLayout

        voiceLayout.playTime = 0
        local function upadate()
            voiceLayout.playTime = voiceLayout.playTime + 0.1
            if voiceLayout.playTime > oneChatTable["voiceTime"] then
                vioceTimeLayout:stopAllActions()
                vioceSignImg:setVisible(true)
                local actionImg = voiceLayout:getChildByTag(997)

                if actionImg then
                    actionImg:stopAllActions()
                    actionImg:removeFromParent()
                    ChatMgr:setIsPlayingVoice(false)
                    SoundMgr:replayMusicAndSound()
                end

                voiceLayout.playTime = 0
                return
            end
        end

        -- 停止语音
        local function doStopPlayRecord()
            if not curPlayRecord or #curPlayRecord <= 0 then return end
            if tostring(chatCellPanel) == curPlayRecord[1] and 'function' == type(curPlayRecord[2]) then
                curPlayRecord[2]()
            end

            curPlayRecord = {}
        end

        -- 播放语音
        local function palyVoice(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                local notPlay = false
                if oneChatTable["haveFilt"] then
                    -- 有屏蔽字不播语音
                    gf:ShowSmallTips(CHS[5410263])
                    notPlay = true
                end

                -- 该语音正在播放(则停止)
                if (self.lastPalyVoiceCellTag == i and voiceLayout.playTime > 0) or notPlay then
                    self:stopPlayVoice()
                    vioceTimeLayout:stopAllActions()
                    SoundMgr:replayMusicAndSound()
                    voiceLayout.playTime = 0
                    return
                end

                self:stopPlayVoice()
                vioceTimeLayout:stopAllActions()
                ChatMgr:stopPlayRecord()
                voiceLayout.playTime = 0.01 -- 标记启动播放
                ChatMgr:setIsPlayingVoice(true) -- 标志在播放语音
                ChatMgr:clearPlayVoiceList() -- 点击播放语音时，清空缓存的语音队列

                schedule(vioceTimeLayout, upadate, 0.1)
                local actionImg =  gf:createLoopMagic(ResMgr.magic.volume)
                actionImg:setPosition(vioceSignImg:getPosition())
                vioceSignImg:setVisible(false)
                voiceLayout:addChild(actionImg, 0, 997)

                if oneChatTable["gid"] == Me:queryBasic("gid") then
                    actionImg:setFlippedX(true)
                    actionImg:setAnchorPoint(1, 1)
                end

                ChatMgr:playRecord(oneChatTable["token"], 0, oneChatTable["voiceTime"], true, doStopPlayRecord)

                self.lastPlayVoiceLayout = voiceLayout
                self.lastPalyVoiceCellTag = i
            end
        end

        self:setStopPlayRecordCallback(chatCellPanel, function()
            self:stopPlayVoice()
            vioceTimeLayout:stopAllActions()
        end)

        -- 语音点击整句都响应
        chatLayout:setTouchEnabled(true)
        chatLayout:addTouchEventListener(palyVoice)

        local secondLabel = ccui.Text:create()
        secondLabel:setAnchorPoint(0.5,0.5)
        secondLabel:setPosition(vioceTimeImg:getContentSize().width / 2 , vioceTimeImg:getContentSize().height / 2 )
        secondLabel:setString(string.format(CHS[3002134], oneChatTable["voiceTime"]))
        secondLabel:setFontSize(19)
        secondLabel:setColor(COLOR3.TEXT_DEFAULT)

        vioceTimeLayout:addChild(secondLabel)


        voiceLayout:setContentSize(textW, vioceSignImg:getContentSize().height + 8) -- 语音和文字之间间隔为8
        vioceSignImg:setPosition(0, voiceLayout:getContentSize().height)
        vioceTimeLayout:setPosition(6 + vioceSignImg:getContentSize().width + vioceSignImg:getPositionX(), voiceLayout:getContentSize().height) -- 语音条和语音之间的间隔为6
        chatLayout:addChild(voiceLayout)

        -- 语音条大于文本的
        if width + vioceSignImg:getContentSize().width + 6 > textW then
            voiceMoreWidth = width + vioceSignImg:getContentSize().width + 6 - textW
        end

        if oneChatTable["playTime"] and oneChatTable["playTime"] > 0 then
            performWithDelay(vioceTimeLayout, function()
                voiceLayout.playTime = oneChatTable["playTime"]
                oneChatTable["playTime"] = 0
                schedule(vioceTimeLayout, upadate, 0.1)
                local actionImg =  gf:createLoopMagic(ResMgr.magic.volume)
                actionImg:setPosition(vioceSignImg:getPosition())
                vioceSignImg:setVisible(false)
                voiceLayout:addChild(actionImg, 0, 997)

                if oneChatTable["gid"] == Me:queryBasic("gid") then
                    actionImg:setFlippedX(true)
                    actionImg:setAnchorPoint(1, 1)
                end

                self.lastPlayVoiceLayout = voiceLayout
                self.lastPalyVoiceCellTag = i
            end, 0)
        end
    end


    -- 气泡
    local backSprite = self:createChatBubble(oneChatTable)
    local backSpriteW = math.max(BUBBLE_WIDTH_MIN, math.max(sqPanel:getContentSize().width, textW + voiceMoreWidth + TEXT_HEIGHT_MARGIN * 2)) -- 气泡宽度不能小于 102
    local backSpriteH = math.max(BUBBLE_HEIGHT_MIN, textH + sqPanel:getContentSize().height + voiceLayout:getContentSize().height + TEXT_HEIGHT_MARGIN * 2) -- 气泡高度不能小于82
    backSprite:setAnchorPoint(0, 0.5)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(backSpriteW, backSpriteH)
    chatLayout:setContentSize(backSpriteW, backSpriteH - CHAT_DOWN_SHRINK_HEIGHT)
    backSprite:setPosition(0, (chatLayout:getContentSize().height - CHAT_DOWN_SHRINK_HEIGHT) / 2)
    voiceLayout:setPosition(TEXT_WIDTH_MARGIN, chatLayout:getContentSize().height - TEXT_HEIGHT_MARGIN)
    sqPanel:setPosition(TEXT_WIDTH_MARGIN, backSpriteH - TEXT_HEIGHT_MARGIN)
    textCtrl:setPosition((chatLayout:getContentSize().width - textW) / 2, textH + (chatLayout:getContentSize().height - CHAT_DOWN_SHRINK_HEIGHT - textH) / 2 - voiceLayout:getContentSize().height/2)
    chatLayout:addChild(backSprite)

    -- 时间
    local tiemLayout = nil
    local tiemHeight = 0
    if oneChatTable["time"] - lastTime  > SHOW_TIME_SPACE then
        tiemLayout, tiemHeight = self:creatTimePanel(oneChatTable)
        chatCellPanel:addChild(tiemLayout)
    end

    local panelHeight = 0
    if iconImg:getContentSize().height > chatLayout:getContentSize().height + lableHeight - CHAT_UP_OFFSET_HEIGHT then
        panelHeight = iconImg:getContentSize().height
    else
        panelHeight = chatLayout:getContentSize().height + lableHeight - CHAT_UP_OFFSET_HEIGHT
    end

    panelHeight = panelHeight + tiemHeight
    chatCellPanel:setContentSize(self:getContentSize().width, panelHeight)

    if self:isMeMsg(oneChatTable) then
        iconImg:setPosition(self:getContentSize().width - iconImg:getContentSize().width, panelHeight)
        local posx, posy = iconImg:getPosition()
        chatLayout:setPosition(posx - chatLayout:getContentSize().width, posy + CHAT_UP_OFFSET_HEIGHT)

        if vioceSignImg then
            vioceSignImg:setFlippedX(true)
            vioceSignImg:setAnchorPoint(1, 1)
            vioceSignImg:setPositionX(textW + voiceMoreWidth)
            vioceTimeLayout:setAnchorPoint(1, 1)
            vioceTimeLayout:setPositionX(textW + voiceMoreWidth - vioceSignImg:getContentSize().width - 6)
        end
    else
        backSprite:setFlippedX(true)
        labelLayout:setPosition(iconImg:getContentSize().width + TEXT_HEIGHT_MARGIN / 2,panelHeight)
        iconImg:addTouchEventListener(imgTouch)
        iconImg:setPosition(0, panelHeight)
        chatLayout:setPosition(iconImg:getContentSize().width ,panelHeight - lableHeight + CHAT_UP_OFFSET_HEIGHT)
    end

    if tiemLayout then
        tiemLayout:setPosition(self:getContentSize().width/2, 20)
    end
    return chatCellPanel
end

-- 是否是Me发出的消息
function ChatPanel:isMeMsg(data)
    if data["gid"] == Me:queryBasic("gid") then
        return true
    end

    if data["gid"] and data["gid"] == 0 and data["id"] and data["id"] == BattleSimulatorMgr.NEWCOMBAT_ME_ID then
        -- 新手战斗中的Me对象
        return true
    end

    return false
end

-- 创建红包单元格
function ChatPanel:createRedBagCell(oneChatTable, lastTime, i)
    local width = self:getContentSize().width
    local chatCellPanel = ccui.Layout:create()
    chatCellPanel:setPosition(0,0)

    -- 头像边框
    local iconImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    local function imgTouch(sender, eventType)
        local canCall = false
        if self.singleChatPanel
            and (self.singleChatPanel.channelName == CHAT_CHANNEL["PARTY"]
            or self.singleChatPanel.channelName == CHAT_CHANNEL["CHAT_GROUP"]) then
            canCall = true
        end

        if ccui.TouchEventType.began == eventType then
            if canCall then
                sender.delayAction = performWithDelay(sender, function()
                    -- 长按头像呼叫好友
                    if GuideMgr:isRunning() then
                        return
                    end

                    sender.delayAction = nil
                    if sender:isHighlighted() then
                        -- -- 会响应 canceled 事件，不处理长按回调
                        -- 过滤掉左下角角色职称
                        local name = string.match(oneChatTable["name"], "#<(.*)#> .*")
                        if not name then
                            name = oneChatTable["name"]
                        end

                        self.singleChatPanel:addCallChar(gf:getRealName(name))
                    end
                end, GameMgr:getLongPressTime())
            end
        elseif ccui.TouchEventType.ended == eventType then
            if sender.delayAction or not canCall then
                sender:stopAction(sender.delayAction)
                sender.delayAction = nil

                -- 请求数据
                FriendMgr:requestCharMenuInfo(oneChatTable["gid"])

                -- 处理弹出名片
                local dlg = DlgMgr:openDlg("CharMenuContentDlg")
                if FriendMgr:getCharMenuInfoByGid(oneChatTable["gid"]) then
                    dlg:setting(oneChatTable["gid"])
                else
                    local char = {}
                    char.gid = oneChatTable["gid"]
                    char.name = string.match(oneChatTable["name"], "#<(.*)#> .*") or oneChatTable["name"]
                    char.level = oneChatTable["level"]
                    char.icon = oneChatTable["icon"]
                    dlg:setInfo(char)
                end

                dlg.root:setPositionX(dlg.root:getPositionX() + self.charFloatOffectX)
            end
        elseif ccui.TouchEventType.canceled == eventType then
            sender:stopAction(sender.delayAction)
            sender.delayAction = nil
        end
    end
    iconImg:setTouchEnabled(true)
    iconImg:setScale(self.portraitScale)
    iconImg:setAnchorPoint(0,1)
    chatCellPanel:addChild(iconImg)

    -- 头像
    local imgPath = ResMgr:getSmallPortrait(oneChatTable["icon"])
    local protriatIcon = ccui.ImageView:create(imgPath)
    protriatIcon:setAnchorPoint(0.5, 0.5)
    protriatIcon:setPosition(iconImg:getContentSize().width / 2  , iconImg:getContentSize().height / 2)
    gf:setItemImageSize(protriatIcon)
    iconImg:addChild(protriatIcon)

    ChatPanel:creatHeadFrame(protriatIcon, oneChatTable)

    -- 等级
    if  oneChatTable["level"]  then
        self:setNumImgForPanel(iconImg, ART_FONT_COLOR.NORMAL_TEXT, oneChatTable["level"], false, LOCATE_POSITION.LEFT_TOP, 19)
    end


    -- 名字
    local labelLayout = nil
    local lableHeight = 0
    if oneChatTable["gid"] ~= Me:queryBasic("gid") then
        local showName = gf:getRealName(oneChatTable["name"])
        local patryJob = string.match(showName, " #B(.+)#n")
        if patryJob then
            showName = string.gsub(showName, " #B.+#n", "")
            local icon = ResMgr:getPartyJobWordImagePath(patryJob)
            if icon then
                showName = string.format("%s #i%s#i", showName, icon)
            end
        end

        labelLayout = ccui.Layout:create()
        labelLayout:setAnchorPoint(0,1)
        chatCellPanel:addChild(labelLayout)
        local lableText = CGAColorTextList:create()
        lableText:setFontSize(21)
        lableText:setString(showName)
        lableText:setContentSize(self:getContentSize().width-iconImg:getContentSize().width*2, 0)
        lableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
        lableText:updateNow()
        local labelW, labelH = lableText:getRealSize()
        lableText:setPosition(0, labelH)
        labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
        lableHeight = labelH
        labelLayout:setContentSize(labelW,labelH)
    end

    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    chatCellPanel:addChild(chatLayout)

    -- 内容包括图片和文字
    local contentLayout = ccui.Layout:create()
    contentLayout:setAnchorPoint(0, 1)

    -- 红包图片
    local redBag = ccui.ImageView:create(ResMgr.ui.red_bag_image)
    redBag:setAnchorPoint(0, 0)
    contentLayout:addChild(redBag)


    -- 文本
    local redbag = ChatMgr:getRedbagIdByMsg(oneChatTable["chatStr"])
    local text = gf:getTextByLenth(redbag.msg or "", 18)
    local textMaxWidth = self:getContentSize().width- iconImg:getContentSize().width -  redBag:getContentSize().width - TEXT_WIDTH_MARGIN * 2
    local textCtrl = CGAColorTextList:create(true)
    textCtrl:setFontSize(19)
    textCtrl:setString(text, oneChatTable["show_extra"])
    textCtrl:setContentSize(textMaxWidth, 0)
    textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    contentLayout:addChild(layer)


    -- 红包状态
    local statuslableText = CGAColorTextList:create(true)
    statuslableText:setFontSize(19)
    statuslableText:setString("#G[查看红包]#n")
    statuslableText:setContentSize(textMaxWidth, 0)
    statuslableText:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    statuslableText:updateNow()
    local labelW, labelH = statuslableText:getRealSize()
    statuslableText:setPosition(redBag:getContentSize().width + 10, labelH + 5)
    contentLayout:addChild(tolua.cast(statuslableText, "cc.LayerColor"))

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

            local redbag = ChatMgr:getRedbagIdByMsg(oneChatTable["chatStr"])

            if redbag.gid then
                PartyMgr:openRedBag(redbag.gid)
            end
        end
    end

    -- 红包点击整句都响应
    chatLayout:addChild(contentLayout)
    chatLayout:setAnchorPoint(0, 1)
    chatLayout:setTouchEnabled(true)
    chatLayout:addTouchEventListener(openRedBag)


    -- 气泡
    local backSprite = self:createChatBubble(oneChatTable, true)
    backSprite:setAnchorPoint(0, 0.5)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(contentWidth + TEXT_WIDTH_MARGIN * 2, contentHeight + TEXT_HEIGHT_MARGIN * 2)  -- 气泡里面的文字和气泡上下左右各10各像素
    chatLayout:setContentSize(contentWidth + TEXT_WIDTH_MARGIN * 2, contentHeight + TEXT_HEIGHT_MARGIN * 2 - CHAT_DOWN_SHRINK_HEIGHT)
    backSprite:setPosition(0, (chatLayout:getContentSize().height - CHAT_DOWN_SHRINK_HEIGHT) / 2)
    contentLayout:setPosition((chatLayout:getContentSize().width - contentWidth) / 2, contentHeight + (chatLayout:getContentSize().height - CHAT_DOWN_SHRINK_HEIGHT - contentHeight) / 2 )
    chatLayout:addChild(backSprite)


    -- 时间
    local tiemLayout = nil
    local tiemHeight = 0
    if oneChatTable["time"] - lastTime  > SHOW_TIME_SPACE then
        tiemLayout, tiemHeight = self:creatTimePanel(oneChatTable)
        chatCellPanel:addChild(tiemLayout)
    end

    local panelHeight = 0
    if iconImg:getContentSize().height > chatLayout:getContentSize().height + lableHeight - CHAT_UP_OFFSET_HEIGHT  then
        panelHeight = iconImg:getContentSize().height
    else
        panelHeight = chatLayout:getContentSize().height + lableHeight - CHAT_UP_OFFSET_HEIGHT
    end

    panelHeight = panelHeight + tiemHeight
    chatCellPanel:setContentSize(self:getContentSize().width, panelHeight)

    if oneChatTable["gid"] == Me:queryBasic("gid") then
        iconImg:setPosition(self:getContentSize().width - iconImg:getContentSize().width, panelHeight)
        local posx, posy = iconImg:getPosition()
        chatLayout:setPosition(posx - chatLayout:getContentSize().width, posy + CHAT_UP_OFFSET_HEIGHT)
    else
        backSprite:setFlippedX(true)
        labelLayout:setPosition(iconImg:getContentSize().width + TEXT_WIDTH_MARGIN / 2, panelHeight)
        iconImg:addTouchEventListener(imgTouch)
        iconImg:setPosition(0,panelHeight)
        chatLayout:setPosition(iconImg:getContentSize().width ,panelHeight - lableHeight + CHAT_UP_OFFSET_HEIGHT)
    end

    if tiemLayout then
        tiemLayout:setPosition(self:getContentSize().width/2, 20)
    end
    return chatCellPanel
end


-- 不可以聊天交互
function ChatPanel:createCanNotChatCell(oneChatTable)
    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    chatLayout:setPosition(0,0)
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(21)
    textCtrl:setString(self:getSystemTimeStr(oneChatTable["time"]).." "..(oneChatTable["chatStr"]),  oneChatTable["show_extra"])
    textCtrl:setContentSize(self:getContentSize().width , 0)
    textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            gf:onCGAColorText(textCtrl, sender)
        end
    end

    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    chatLayout:setContentSize(textW,textH)
    chatLayout:addChild(layer)
    chatLayout:setAnchorPoint(0,0)
    chatLayout:setTouchEnabled(true)
    chatLayout:addTouchEventListener(ctrlTouch)

    return chatLayout

end

function ChatPanel:createOnechatCell(oneChatTable)
    -- 单句聊天内容
    local chatLayout = ccui.Layout:create()
    chatLayout:setPosition(0,0)
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(21)
    textCtrl:setString(oneChatTable["chatStr"],  oneChatTable["show_extra"])
    textCtrl:setContentSize(self:getContentSize().width, 0)
    textCtrl:setDefaultColor(WORD_COLOR.r, WORD_COLOR.g, WORD_COLOR.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, textH)
    local layer = tolua.cast(textCtrl, "cc.LayerColor")
    chatLayout:setContentSize(textW, textH)
    chatLayout:addChild(layer)
    chatLayout:setAnchorPoint(0,0)
    chatLayout:setTouchEnabled(true)

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            gf:onCGAColorText(textCtrl, sender)
        end
    end

    chatLayout:addTouchEventListener(ctrlTouch)
    return chatLayout
end

-- 向下加载更多的消息
function ChatPanel:loadMoreCell()
    if (#self.lastLoadData - self.initNumber)/CONST_DATA.loadNumber < self.loadCount then
        return
    end

    local container = self.scroview:getChildByTag(CONST_DATA.containerTag)
    local innerSizeheight = 0
    local leftChatNum = #self.lastLoadData - self.initNumber  - CONST_DATA.loadNumber * self.loadCount -- 还没加载的数据
    local endIndex = leftChatNum
    local starIndex = 1

    if leftChatNum > CONST_DATA.loadNumber then -- 足够加载一次
        starIndex = leftChatNum - CONST_DATA.loadNumber + 1
    end

    for i = starIndex, endIndex do
        local lastTime = 0
        if  self.lastLoadData[i - 1] then
            lastTime = self.lastLoadData[i - 1]["time"]
        end

        local index = self.lastLoadData[i]["index"]
        local cellPanel = self:createOnechat(self.lastLoadData[i], lastTime, index)
        cellPanel:setPosition(0,innerSizeheight)
        innerSizeheight =innerSizeheight + cellPanel:getContentSize().height + CONST_DATA .cellSpace
        container:addChild(cellPanel, 0, index)
    end

    self.lastLoadIndex = self.lastLoadData[starIndex]["index"]-- 用来标志当前加载到哪个，方便后面删除
    self.loadCount = self.loadCount + 1

    -- 之前加载 往上移
    for i = #self.lastLoadData, endIndex + 1, -1 do
        if self.lastLoadData[i] then
            local index = self.lastLoadData[i]["index"]
            local cell = container:getChildByTag(index)
            if cell then
                local posx, posy = cell:getPosition()
                cell:setPosition(posx, posy + innerSizeheight)
            end
        end
    end

    -- upLoadMoreCell() 中加载的也要往上移
    for i = 1, #self.lastUpLoadData do
        if self.lastUpLoadData[i] then
            local index = self.lastUpLoadData[i]["index"]
            local cell = container:getChildByTag(index)
            if cell then
                local posx, posy = cell:getPosition()
                cell:setPosition(posx, posy + innerSizeheight)
            end

            if index >= self.lastUpLoadIndex then
                break
            end
        end
    end

    container:setContentSize(self:getContentSize().width, container:getContentSize().height + innerSizeheight)
    self.scroview:setInnerContainerSize(container:getContentSize())

end

-- 向上加载更多的消息
function ChatPanel:upLoadMoreCell()
    if #self.lastUpLoadData <= self.upLoadCount then
        self.canRefreshByOther = true
        return
    end

    local container = self.scroview:getChildByTag(CONST_DATA.containerTag)
    local innerSizeheight = 0
    local allCou = #self.lastUpLoadData
    local hasLoadCou = self.upLoadCount
    local leftChatNum = allCou - hasLoadCou -- 还没加载的数据
    local endIndex = allCou
    local starIndex = hasLoadCou + 1

    if leftChatNum > CONST_DATA.loadNumber then -- 足够加载一次
        endIndex = hasLoadCou + CONST_DATA.loadNumber
        self.upLoadCount = self.upLoadCount + CONST_DATA.loadNumber
    else
        self.upLoadCount = self.upLoadCount + leftChatNum
    end

    local containerSize = container:getContentSize()
    innerSizeheight = innerSizeheight + containerSize.height

    for i = starIndex, endIndex do
        local lastTime = 0
        if self.lastUpLoadData[i - 1] then
            lastTime = self.lastUpLoadData[i - 1]["time"]
        elseif i == 1 and next(self.lastLoadData) then
            lastTime = self.lastLoadData[#self.lastLoadData]["time"] or 0
        end

        innerSizeheight = innerSizeheight + CONST_DATA .cellSpace

        local index = self.lastUpLoadData[i]["index"]
        local cellPanel = self:createOnechat(self.lastUpLoadData[i], lastTime, index)
        cellPanel:setPosition(0, innerSizeheight)
        innerSizeheight = innerSizeheight + cellPanel:getContentSize().height
        container:addChild(cellPanel, 0, index)
    end

    self.lastUpLoadIndex = self.lastUpLoadData[endIndex]["index"]-- 用来标志当前向上加载到哪个，方便后面删除

    self.notCallScrollTop = true
    local posY = self.scroview:getInnerContainer():getPositionY()
    container:setContentSize(self:getContentSize().width, innerSizeheight)
    self.scroview:setInnerContainerSize(container:getContentSize())
    self.scroview:getInnerContainer():setPositionY(posY)
    self.notCallScrollTop = false
end

-- 获取当前频道总的条数
function ChatPanel:getTotalIndex(dataTable)
    if dataTable[#dataTable] then
        return dataTable[#dataTable]["index"] or 0
    else
        return 0
    end
end


function ChatPanel:newMessage()
    self:loadInitData()
	self.scroview:scrollToTop(0.01,false)
end

function ChatPanel:createChatTimeCell()
    local labelLayout = ccui.Layout:create()
    labelLayout:setAnchorPoint(0,1)
    local lableText = CGAColorTextList:create()
    lableText:setFontSize(21)
    lableText:setString(oneChatTable["name"])
    lableText:setContentSize(self:getContentSize().width , 0)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    lableText:setPosition(0, labelH)
    labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
    labelLayout:setContentSize(labelW,labelH)
end

function ChatPanel:getTiemStr(time)
    local timeStr = ""
    local timeTabel = os.date("*t",time)
    local curtime = gf:getServerTime()
    local difDay = math.floor((curtime + 8 * 60 * 60) / (60 * 60 * 24)) -  math.floor((time + 8 * 60 * 60) / (60 * 60 * 24))

    if difDay == 0 then
        timeStr = string.format("%02d:%02d", timeTabel["hour"], timeTabel["min"])
    else
        if difDay == 1 then
            timeStr = string.format("%s  %02d:%02d", CHS[6000134], timeTabel["hour"], timeTabel["min"])
        elseif difDay <= 7 and difDay >1 then
            timeStr = string.format("%s%s  %02d:%02d", CHS[6000135], CONST_WDAY[timeTabel["wday"]], timeTabel["hour"], timeTabel["min"])
        elseif difDay > 7 then
            timeStr = string.format("%d-%02d-%02d  %02d:%02d", timeTabel["year"], timeTabel["month"], timeTabel["day"], timeTabel["hour"], timeTabel["min"])
        end
    end

    return timeStr
end

function ChatPanel:getSystemTimeStr(time)
    local tiemStr = ""
    local timeTabel = os.date("*t",time)
    tiemStr = string.format("%02d:%02d:%02d", timeTabel["hour"], timeTabel["min"], timeTabel["sec"])
    return tiemStr
end

-- 停止播放声音
function ChatPanel:stopPlayVoice()
    SoundMgr:stopMusicAndSound()
    ChatMgr:setIsPlayingVoice(false)
    if self.lastPlayVoiceLayout == nil then
        return
    end

    local actionImg = self.lastPlayVoiceLayout:getChildByTag(997)
    local vioceSignImg = self.lastPlayVoiceLayout:getChildByTag(996)
    if actionImg and vioceSignImg then
        actionImg:stopAllActions()
        actionImg:removeFromParent()
        vioceSignImg:setVisible(true)
        ChatMgr:stopPlayRecord()
    end

    self.lastPlayVoiceLayout = nil
    self.lastPalyVoiceCellTag = 0
end

-- 获取指定 node 在屏幕坐标系中的区域
function ChatPanel:getBoundingBoxInWorldSpace(node)
    if not node then
        return
    end

    local rect = node:getBoundingBox()
    local pt = node:convertToWorldSpace(cc.p(0, 0))
    rect.x = pt.x
    rect.y = pt.y
    rect.width = rect.width * Const.UI_SCALE
    rect.height = rect.height * Const.UI_SCALE

    return rect
end


function ChatPanel:setNumImgForPanel(panelNameOrPanel, imgName, amount, showSign, locate, fontSize, root)
    local panel = panelNameOrPanel
    if type(panelNameOrPanel) == 'string' then
        root = root or self.root
        panel = self:getControl(panelNameOrPanel, nil, root)
    end

    if nil == panel then return end

    local tag = locate * 999
    local numImg = panel:getChildByTag(tag)

    -- 数字图片单例
    if numImg then
        numImg:removeFromParent()
    end
    numImg = NumImg.new(imgName, amount, showSign, -1)
    numImg:setTag(tag)
    panel:addChild(numImg)

    --设置锚点和方位
    local panelSize = panel:getContentSize()
    if locate == LOCATE_POSITION.RIGHT_BOTTOM then     --右下
        numImg:setAnchorPoint(1, 0)
        numImg:setPosition(panelSize.width - 5, 5)
    elseif locate == LOCATE_POSITION.LEFT_BOTTOM then  --左下
        numImg:setAnchorPoint(0, 0)
        numImg:setPosition(5, 5)
    elseif locate == LOCATE_POSITION.RIGHT_TOP then    --右上
        numImg:setAnchorPoint(1, 1)
        numImg:setPosition(panelSize.width - 5, panelSize.height - 5)
    elseif locate == LOCATE_POSITION.LEFT_TOP then     --左上
        numImg:setAnchorPoint(0, 1)
        numImg:setPosition(5, panelSize.height - 5)
    elseif locate == LOCATE_POSITION.CENTER then
        numImg:setAnchorPoint(0, 0.5)
        numImg:setPosition(0, panelSize.height / 2)
    elseif locate == LOCATE_POSITION.MID then          --中间
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2, panelSize.height / 2)
    elseif locate == LOCATE_POSITION.MID_TOP then      --中上
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2, panelSize.height - 5)
    elseif locate == LOCATE_POSITION.MID_BOTTOM then   --中下
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2, 5)
    else
        Log:W("Location not expected!")
        return
    end

    --设置字体大小
    if fontSize == 25 then
        numImg:setScale(1, 1)
    elseif fontSize == 23 then
        numImg:setScale(14 / 15, 20 / 22)
    elseif fontSize == 21 then
        numImg:setScale(13 / 15, 18 / 22)
    elseif fontSize == 19 then
        numImg:setScale(12 / 15, 16 / 22)
    elseif fontSize == 17 then
        numImg:setScale(11 / 15, 14 / 22)
    elseif fontSize == 15 then
        numImg:setScale(10 / 15, 12 / 22)
    elseif fontSize == 12.5 then
        numImg:setScale(0.5, 0.5)
    else
        Log:W("Font Size not expected!")
        return
    end
    return numImg
end

function ChatPanel:scroviewllIsIntop()
    local container = self.scroview:getChildByTag(CONST_DATA.containerTag)
    local x, y = self.scroview:getInnerContainer():getPosition()
    local offset = self.scroview:getContentSize().height - container:getContentSize().height

    if y == offset or offset > 0 then
        return true
    end

    return false
end

function ChatPanel:clear()
    self.lastLoadData = nil
    FriendMgr:unrequestCharMenuInfo(self.name)
end

function ChatPanel:setStopPlayRecordCallback(ctl, callback)
    curPlayRecord = { tostring(ctl), callback }

    local function onNodeEvent(event)
        if "cleanup" == event then
            if #curPlayRecord > 0 and curPlayRecord[1] == tostring(ctl) then
                curPlayRecord = {}
            end
        end
    end

    ctl:registerScriptHandler(onNodeEvent)
end

function ChatPanel:onCharInfo(gid, char)
    -- 处理弹出名片
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")

    local distName = FriendMgr:getKuafObjDist(gid)
    if FriendMgr:isKuafDist(distName) then
        dlg:setMuneType(CHAR_MUNE_TYPE.KUAFU_BLOG)
    end

    if dlg then
        char.dist_name = distName
        if FriendMgr:getCharMenuInfoByGid(gid) then
            dlg:setting(gid)
        else
            if char then
                dlg:setInfo(char)
            end
        end

        dlg.root:setPositionX(dlg.root:getPositionX() + self.charFloatOffectX)
    end
end

return ChatPanel
