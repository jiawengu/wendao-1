-- SendMailDlg.lua
-- Created by zhengjh Sep/19/2016
-- 邮寄

local SubmitFDIDlg = require('dlg/SubmitFDIDlg')
local SendMailDlg = Singleton("SendMailDlg", SubmitFDIDlg)

local COLUNM = 5
local SPACE = 0
local MAX_SEND_NUMBER = 6
local ONLINE = 1
local MAX_SEND_TIMES = 20

local load_complete_cb = nil

local groupStatus = {}

function SendMailDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("ClickPanel", self.onClickTag)
    self:bindListener("CleanFieldButton", self.onCleanFieldButton)
    self:bindListener("SearchButton", self.onSearchButton)
    
    self.tagCell = self:retainCtrl("TagsPanel")
    self.friendPanel = self:retainCtrl("SingleFriendPanel")
    
    -- 好友选中效果
    self.itemSelectImg = self:retainCtrl("ChosenImage", self.friendPanel)
    
    self.itemCell = self:retainCtrl("ItemPanel_1")
    
    -- 物品选中效果
    self.getImage = self:retainCtrl("GetImage", self.itemCell)
    
    self.listView = self:resetListView("FriendListView", 2)
    
    self.friendPanels = {}
    self.groupStatus = {}
    self.friendSch = {}
    
    self.listView = self:resetListView("FriendListView")
    self.listView:setBounceEnabled(false)
    self.searchListView = self.listView:clone()
    self.searchListView:setVisible(false)
    self.searchListView:setName("SearchListView")
    self.listView:getParent():addChild(self.searchListView)
    
    -- 初始化分组
    self:initGroups()
    
    -- 绑定搜索输入框
    self:bindEditBox()
    
    self.selectItem = nil
    self.mailNumber = 0
    self.itemname = nil
    
    -- 可邮寄次数
    self:MSG_UPDATE()

    -- 绑定
    self:bindTouchEvent()

    self:hookMsg("MSG_FRIEND_NOTIFICATION")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_MAILING_ITEM")
end

function SendMailDlg:selectFriend(friend)
    if not friend then  return end
    self.selectFriedGid = friend.gid
end

function SendMailDlg:unSelectFriend()
    self.selectFriedGid = nil
    self.itemSelectImg:removeFromParent()
end

function SendMailDlg:addItemSelcelImage(cell)
    self.itemSelectImg:removeFromParent()
    cell:addChild(self.itemSelectImg)
end

function SendMailDlg:initList(name)
    --self.mailNumber = self.mailNumber or 0
    self:refreshMailNumber(0)
    self.itemname = name
    local scroview = self:getControl("ScrollView")
    scroview:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local data = InventoryMgr:getItemByClass(InventoryMgr:getClassByName(name), true)
    if name == CHS[7100102] then
        local homework = InventoryMgr:getItemByName(name)
        for i = 1, #homework do
            table.insert(data, homework[i])
        end
    end

    if not data then return end
    local count = #data
    local cellColne = self.itemCell:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    if line < 3 then line = 3 end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)

    for i = 1, line do
        curColunm = COLUNM

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + SPACE)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag])
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(scroview:getContentSize().width, totalHeight)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end
end

function SendMailDlg:initAllItem()
    self.mailNumber = 0
    self:refreshMailNumber(self.mailNumber)
    self.isShowAll = true
    local scroview = self:getControl("ScrollView")
    scroview:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local data = InventoryMgr:getCanMailItems()
    if not data or not next(data) then return end
    local count = #data
    local cellColne = self.itemCell:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    if line < 3 then line = 3 end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)

    for i = 1, line do
        curColunm = COLUNM

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + SPACE)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + SPACE)
            cell:setPosition(x, y)
            self:setCellData(cell, data[tag])
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(scroview:getContentSize().width, totalHeight)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end
end


function SendMailDlg:setCellData(cell, item)
    if not item then
        self:setImagePlist("FrameImage", ResMgr.ui.bag_no_item_bg_img, cell)
        return
    end

    cell:setName(item.name)

    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(item.icon)
    self:setImage("ItemImage", iconPath, cell)
    self:setItemImageSize("ItemImage", cell)

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:seleceltItem(sender, item)
        end
    end

    if item.amount and item.amount > 1 then
        self:setNumImgForPanel("ItemImage", ART_FONT_COLOR.NORMAL_TEXT, item.amount,
            false, LOCATE_POSITION.RIGHT_BOTTOM, 21, cell)
    end

    cell:addTouchEventListener(touch)
end

function SendMailDlg:seleceltItem(cell, item)
    self.getImage:removeFromParent()
    cell:addChild(self.getImage)

    if InventoryMgr:itemIsCanDouble(item.name) then
        self:setCtrlVisible("SubmitNumPanel", true)
    else
        self:setCtrlVisible("SubmitNumPanel", false)
    end

    if self.selectItem and self.selectItem.pos ~= item.pos then
        self.mailNumber = 1
    else
        self.mailNumber = self.mailNumber or 1
        if self.mailNumber == 0 then
            self.mailNumber = 1
        end
        
        if self.mailNumber > item.amount then   
            self.mailNumber = item.amount
        end 
    end

    self.selectItem = item
    
    self:refreshMailNumber(self.mailNumber)
end


function SendMailDlg:onSubmitButton(sender, eventType)
    if not self.selectFriedGid then 
        gf:ShowSmallTips(CHS[5420157])
        return
    end

    local friend =  FriendMgr:convertToUserData(FriendMgr:getFriendByGid(self.selectFriedGid))
    if not friend then return end   -- 好友已经不存在

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    elseif GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4000223])
        return
    elseif Me:queryInt("mailing_item_times") <= 0 then
        gf:ShowSmallTips(string.format(CHS[6200090], MAX_SEND_TIMES))
        return
    elseif ONLINE ~= friend.isOnline then
        gf:ShowSmallTips(CHS[6200080])
        return
    elseif not self.selectItem then
        gf:ShowSmallTips(CHS[6200081])
        return
    end
    
    if self:checkSafeLockRelease("onSubmitButton") then
        return
    end

    local data = {}
    data.pos = self.selectItem.pos
    data.amount = self.mailNumber
    data.gid = self.selectFriedGid
    data.name = friend.name

    gf:CmdToServer("CMD_MAILING_ITEM", data)
end

function SendMailDlg:onAddButton(sender, eventType)
    if not self.selectItem then
        gf:ShowSmallTips(CHS[6200088])
        return
    end

    if self.mailNumber >= MAX_SEND_NUMBER then
        gf:ShowSmallTips(string.format(CHS[6200079], MAX_SEND_NUMBER))
        return
    end

    local amount = self.selectItem.amount
    if amount and self.mailNumber >= amount then
        gf:ShowSmallTips(string.format(CHS[6200089], amount, self.selectItem.name ))
        return
    end


    self.mailNumber = self.mailNumber + 1
    self:refreshMailNumber(self.mailNumber)
end

function SendMailDlg:onReduceButton(sender, eventType)
    if not self.selectItem then
        gf:ShowSmallTips(CHS[6200088])
        return
    end

    if self.mailNumber <= 1 then
        gf:ShowSmallTips(CHS[6200087])
        return
    end

    self.mailNumber = self.mailNumber - 1
    self:refreshMailNumber(self.mailNumber)
end

function SendMailDlg:onNoteButton(sender, eventType)
    self:setCtrlVisible("OfflineRulePanel", true)
end

function SendMailDlg:bindTouchEvent()
    local panel = self:getControl("OfflineRulePanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(self.root:getContentSize())
    layout:setPosition(self.root:getPosition())
    layout:setAnchorPoint(self.root:getAnchorPoint())
    panel:setVisible(false)

    local function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()
        local classRect = self:getBoundingBoxInWorldSpace(panel)

        if not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(classRect, toPos)
            and panel:isVisible() then
            panel:setVisible(false)
            return true
        end
    end

    self.root:addChild(layout, 10, 1)
    gf:bindTouchListener(layout, touch)
end

function SendMailDlg:refreshMailNumber(num)
    self:setLabelText("ValueLabel_1", num)
    self:setLabelText("ValueLabel_2", num)
end

-- 好友上线离线
function SendMailDlg:MSG_FRIEND_NOTIFICATION(data)
    local name =  data.char
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByName(name))
    self:refreshFriednPanel(newFriendInfo)
end

function SendMailDlg:MSG_UPDATE()
    local text = gf:getArtFontMoneyDesc(Me:queryInt("mailing_item_times"))
    self:setLabelText("LimitNumLabel_2", text)
end

-- 邮件成功
function SendMailDlg:MSG_MAILING_ITEM(data)
    if self.isShowAll then
        self:initAllItem()
        self.selectItem = nil
    else
        self:initList(self.itemname)
        self.selectItem = nil
        if string.match(self.itemname, CHS[4100631]) then
            self:initSelectItemClass(self.itemname)
        end
    end
end

function SendMailDlg:cleanup()
    self.selectFriedGid = nil
    self.isShowAll = nil
    
    for _, v in ipairs(self.friendPanels) do
        if v then
            v:release()
        end
    end
    
    self.friendPanels = nil
end

function SendMailDlg:initSelectItemClass(name, defNum)
    local scroview = self:getControl("ScrollView")
    local data = InventoryMgr:getItemByClass(InventoryMgr:getClassByName(name), true)
    if not data or not next(data) then return end
    local cell = self:getControl(data[1].name, nil, scroview)
    self:seleceltItem(cell, data[1])

    if defNum then
        if data[1].amount >= defNum then
            self.mailNumber = defNum
        else
            self.mailNumber = data[1].amount
        end
        
        self:refreshMailNumber(self.mailNumber)
    end
    
end

return SendMailDlg
