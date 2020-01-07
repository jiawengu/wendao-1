-- ChatDecorateDlg.lua
-- created by lixh Jan/06/2018
-- 聊天装饰界面

local ChatDecorateDlg = Singleton("ChatDecorateDlg", Dialog)

-- 左侧物品列的数量
local BAG_COL_NUM   = 4

-- 左侧物品水平间隔
local ROW_MAGIN = 6.4

-- 左侧物品垂直间隔
local COL_MAGIN = 6.4

-- 默认图标路径
local DEFAULT_ICON_PATH = ResMgr.ui.default_icon

-- 默认图标名称
local DEFAULT_ICON_NAME = ""

-- 默认聊天框图片路径
local DEFAULT_CHAT_PATH = ResMgr.ui.chat_def_back_groud

function ChatDecorateDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ChatButton", self.onChatButton)
    self:bindListener("IconButton", self.onIconButton)

    self:setCtrlVisible("ChosenEffectImage", false, "IconListPanel")
    self.itemPanel = self:retainCtrl("ItemPanel", nil, "IconListPanel")
    self:setCtrlVisible("ItemPanel", false, "IconListPanel")
    self:setCtrlVisible("ItemPanel", false, "ChatBKListPanel")

    self.curSelectIcon = ChatDecorateMgr:getIconDecorateUsed()
    self.curSelectChat = ChatDecorateMgr:getChatDecorateUsed()

    self:initDlgInfo()
end

-- 初始化界面信息
function ChatDecorateDlg:initDlgInfo()
    -- 头像框，聊天框列表
    self:initItemList(true)
    self:initItemList(false)

    -- 选择页签
    local iconList = ChatDecorateMgr:getIconDecorateList()
    local chatList = ChatDecorateMgr:getChatDecorateList()
    if #chatList > 0 and #iconList == 0 then
        self:onChatButton()
    else
        self:onIconButton()
    end

    -- 效果预览玩家信息(自已)
    self:setImage("IconImage", ResMgr:getUserSmallPortrait(Me:queryBasicInt("polar"), Me:queryBasicInt("gender")), "OtherPanel")
    self:setItemImageSize("IconImage")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:getLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, "OtherPanel")
    self:setLabelText("NameLabel", Me:getName(), "OtherPanel")

    -- 效果预览玩家信息(他人)
    self:setImage("IconImage", ResMgr:getUserSmallPortrait(Me:queryBasicInt("polar"), Me:queryBasicInt("gender")), "SelfPanel")
    self:setItemImageSize("IconImage")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:getLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, "SelfPanel")
end

-- 选中物品
function ChatDecorateDlg:onSelectItem(sender, eventType)
    local scrollView = sender:getParent()
    local isIcon
    if sender:getParent():getParent():getParent():getName() == "IconListPanel" then
        isIcon = true
    elseif sender:getParent():getParent():getParent():getName() == "ChatBKListPanel" then
        isIcon = false
    end

    -- 设置选中效果
    local listCtrl = scrollView:getChildren()
    for i = 1, #listCtrl do
        self:setCtrlVisible("ChosenEffectImage", false, listCtrl[i])
    end

    self:setCtrlVisible("ChosenEffectImage", true, sender)

    if isIcon then
        self.curSelectIcon = sender:getName()
    else
        self.curSelectChat = sender:getName()
    end

    -- 刷新预览
    self:refreshShowPanel(isIcon)
end

-- 刷新预览效果
-- isIcon true: 刷新头像框
-- isIcon false: 刷新聊天框
function ChatDecorateDlg:refreshShowPanel(isIcon)
    if isIcon then
        -- 头像框
        local iconSelect = self.curSelectIcon
        local iconPath
        if not iconSelect or iconSelect == "" or iconSelect == DEFAULT_ICON_NAME then
            self:setCtrlVisible("IconDecorateImage", false, "OtherPanel")
            self:setCtrlVisible("IconDecorateImage", false, "SelfPanel")
        else
            iconPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(iconSelect))
            self:setImage("IconDecorateImage", iconPath, "OtherPanel")
            self:setItemImageSize("IconDecorateImage", "OtherPanel")
            self:setImage("IconDecorateImage", iconPath, "SelfPanel")
            self:setItemImageSize("IconDecorateImage", "SelfPanel")

            self:setCtrlVisible("IconDecorateImage", true, "OtherPanel")
            self:setCtrlVisible("IconDecorateImage", true, "SelfPanel")
        end
    else
        -- 聊天框
        local chatSelect = self.curSelectChat
        local chatPath
        if not chatSelect or chatSelect == "" or chatSelect == DEFAULT_ICON_NAME then
            chatPath = DEFAULT_CHAT_PATH
            self:setImagePlist("TalkImage", chatPath, "OtherPanel")
            self:setImagePlist("TalkImage", chatPath, "SelfPanel")
        else
            chatPath = InventoryMgr:getItemInfoByName(chatSelect).chat_icon
            self:setImage("TalkImage", chatPath, "OtherPanel")
            self:setImage("TalkImage", chatPath, "SelfPanel")
        end
    end

    -- 名称与期限
    local name
    if isIcon then
        name = self.curSelectIcon == DEFAULT_ICON_NAME and CHS[7120044] or self.curSelectIcon
    else
        name = self.curSelectChat == DEFAULT_ICON_NAME and CHS[7120045] or self.curSelectChat
    end

    self:setLabelText("UseLable", name, "InfoPanel")
    self:setLabelText("TimeLable", ChatDecorateMgr:getDecorateLeftTime(name, isIcon), "InfoPanel")
end

-- 初始化物品列表
function ChatDecorateDlg:initItemList(isIcon)
    local listData
    local listCtrl
    if isIcon then
        listData = ChatDecorateMgr:getIconDecorateList()
        listCtrl = self:getControl("ItemsScrollView", nil, "IconListPanel")
    else
        listData = ChatDecorateMgr:getChatDecorateList()
        listCtrl = self:getControl("ItemsScrollView", nil, "ChatBKListPanel")
    end

    listCtrl:removeAllChildren()

    local count = #listData + 1
    local row = math.ceil(count / BAG_COL_NUM)
    local contentSize = self.itemPanel:getContentSize()
    local listContentSize = listCtrl:getContentSize()
    local innerHeight = math.max(row * (COL_MAGIN + contentSize.height) + COL_MAGIN, listContentSize.height)
    listCtrl:setInnerContainerSize({width = listContentSize.width, height = innerHeight})

    local defaultItem = self.itemPanel:clone()
    defaultItem:setPosition(ROW_MAGIN , innerHeight - contentSize.height - COL_MAGIN)
    listCtrl:addChild(defaultItem)
    defaultItem:setName(DEFAULT_ICON_NAME)
    self:setItemInfo(defaultItem, DEFAULT_ICON_NAME)
    self:bindListener(DEFAULT_ICON_NAME, self.onSelectItem, listCtrl)
    if (isIcon and (not self.curSelectIcon or self.curSelectIcon == "")) or (not isIcon and (not self.curSelectChat or self.curSelectChat == "")) then
        -- 当前选中默认框
        self:onSelectItem(defaultItem)
    end

    for i = 1, #listData do
        local item = self.itemPanel:clone()
        local newY = math.ceil((i + 1) / BAG_COL_NUM)
        local newX = (i + 1) % BAG_COL_NUM
        newX = newX == 0 and BAG_COL_NUM or newX
        item:setPosition(ROW_MAGIN + (newX - 1) * (contentSize.width + ROW_MAGIN), innerHeight - newY * (contentSize.height + COL_MAGIN))
        listCtrl:addChild(item)
        item:setName(listData[i].name)
        self:setItemInfo(item, listData[i].name)
        self:blindLongPress(item, self.onLongPressItem, self.onSelectItem, listCtrl)
        if self.curSelectChat == listData[i].name or self.curSelectIcon == listData[i].name then
            -- 当前选中已使用框
            self:onSelectItem(item)
        end
    end
end

-- 设置单个物品信息
function ChatDecorateDlg:setItemInfo(ctrl, itemName)
    local iconPath
    if itemName == DEFAULT_ICON_NAME then
        iconPath = DEFAULT_ICON_PATH
    else
        iconPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(itemName))
    end

    self:setImage("IconImage", iconPath, ctrl)
    self:setItemImageSize("IconImage", ctrl)
end

-- 物品长按，打开悬浮框
function ChatDecorateDlg:onLongPressItem(sender)
    if sender then
        local itemName = sender:getName()
        local itemInfo = InventoryMgr:getItemInfoByName(itemName)
        itemInfo.name = itemName
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showItemByItemData(itemInfo, rect)
    end
end

function ChatDecorateDlg:onIconButton(sender, eventType)
    self:setCtrlVisible("IconImage", true, "TabPanel")
    self:setCtrlVisible("ChatImage", false, "TabPanel")
    self:setCtrlVisible("IconListPanel", true)
    self:setCtrlVisible("ChatBKListPanel", false)
    self:refreshShowPanel(true)
end

function ChatDecorateDlg:onChatButton(sender, eventType)
    self:setCtrlVisible("IconImage", false, "TabPanel")
    self:setCtrlVisible("ChatImage", true, "TabPanel")
    self:setCtrlVisible("IconListPanel", false)
    self:setCtrlVisible("ChatBKListPanel", true)
    self:refreshShowPanel(false)
end

function ChatDecorateDlg:onConfirmButton(sender, eventType)
    if self.curSelectIcon == ChatDecorateMgr:getIconDecorateUsed() and self.curSelectChat == ChatDecorateMgr:getChatDecorateUsed() then
        self:onCloseButton()
        return
    end

    if ChatDecorateMgr:isIconTimeOver(self.curSelectIcon) then
        self:onIconButton()
        local listCtrl = self:getControl("ItemsScrollView", nil, "IconListPanel")
        local listItem = listCtrl:getChildren()
        if listItem and listItem[1] then
            -- 选中默认头像框
            self:onSelectItem(listItem[1])
        end

        gf:ShowSmallTips(CHS[7120042])
        ChatMgr:sendMiscMsg(CHS[7120042])
        return
    end

    if ChatDecorateMgr:isChatTimeOver(self.curSelectChat) then
        self:onIconButton()
        local listCtrl = self:getControl("ItemsScrollView", nil, "ChatBKListPanel")
        local listItem = listCtrl:getChildren()
        if listItem and listItem[1] then
            -- 选中默认聊天框
            self:onSelectItem(listItem[1])
        end

        gf:ShowSmallTips(CHS[7120043])
        ChatMgr:sendMiscMsg(CHS[7120043])
        return
    end

    gf:CmdToServer("CMD_DECORATION_APPLY", {count = 2, list = {{type = "chat_head", name = self.curSelectIcon}, {type = "chat_floor", name = self.curSelectChat}}})
    self:onCloseButton()
end

return ChatDecorateDlg
