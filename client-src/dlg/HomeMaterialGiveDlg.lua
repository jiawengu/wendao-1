-- HomeMaterialGiveDlg.lua
-- Created by  huangzz Aug/25/2017
-- 生活材料赠送界面

local HomeMaterialGiveDlg = Singleton("HomeMaterialGiveDlg", Dialog)

local CAN_GIVE_MAX_NUM = 5 -- 可以赠送好友材料的最大次数

function HomeMaterialGiveDlg:init()
    self:bindListener("GiveButton", self.onGiveButton, "ItemPanel1")
    self:bindListener("GiveButton", self.onGiveButton, "ItemPanel2")
    self:bindListener("GiveButton", self.onGiveButton, "ItemPanel3")
    self:bindListener("CallButton", self.onCallButton)
    self:bindListener("SingleFriendPanel", self.selectFriendPanel)

    self:bindListener("SingleGiftPanel1", self.onShowItemInfo)
    self:bindListener("SingleGiftPanel2", self.onShowItemInfo)
    self:bindListener("SingleGiftPanel3", self.onShowItemInfo)
    self:bindListener("ItemIconPanel", self.onShowItemInfo, "ItemPanel1")
    self:bindListener("ItemIconPanel", self.onShowItemInfo, "ItemPanel2")
    self:bindListener("ItemIconPanel", self.onShowItemInfo, "ItemPanel3")

    self.selectImage = self:retainCtrl("BChosenEffectImage", "SingleFriendPanel")

    self.friendPanel = self:retainCtrl("SingleFriendPanel")

    self.schedule = nil
    self.friends = {}
    self.materials = {}
    self.selectTag = nil

    self:setInitFriendView(false)

    if HomeMgr.exchangeMaterialInfo then
        self:MSG_EXCHANGE_MATERIAL_TARGETS(HomeMgr.exchangeMaterialInfo)
    end

    self:hookMsg("MSG_EXCHANGE_MATERIAL_TARGETS")
    self:hookMsg("MSG_FRIEND_EXCHANGE_MATERIAL_DATA")
end

-- 刚开界面的最初状态
function HomeMaterialGiveDlg:setInitFriendView(isShow)
    self:setLabelText("NameLabel", "", "NamePanel")
    self:setCtrlVisible("NoticeItemPanel", isShow)

    self:setCtrlVisible("ItemPanel1", isShow, "NeedPanel")
    self:setCtrlVisible("ItemPanel2", isShow, "NeedPanel")
    self:setCtrlVisible("ItemPanel3", isShow, "NeedPanel")
    self:setCtrlVisible("MNoneLabel", not isShow, "NeedPanel")

    self:setCtrlVisible("SingleGiftPanel1", isShow, "GiftPanel")
    self:setCtrlVisible("SingleGiftPanel2", isShow, "GiftPanel")
    self:setCtrlVisible("SingleGiftPanel3", isShow, "GiftPanel")
    self:setCtrlVisible("NoneLabel", isShow, "GiftPanel")
    self:setCtrlVisible("TextLabel", isShow, "GiftPanel")

    self:setCtrlVisible("CallButton", isShow, "MessagePanel")
    self:setCtrlVisible("TextLabel", isShow, "MessagePanel")
    self:setCtrlVisible("NoneLabel", isShow, "MessagePanel")
end

-- 赠送
function HomeMaterialGiveDlg:onGiveButton(sender, eventType)
    if not self.selectTag then
        return
    end

    local pos = sender.data.pos
    local items = InventoryMgr:getItemByName(sender.data.name) or {}

    if not next(items) then
        gf:ShowSmallTips(CHS[5400229])
        local cell = sender:getParent():getParent()
        self:setLabelText("HaveNumLabel", CHS[5400226] .. 0, cell)
        self:setCtrlEnabled("GiveButton", false, cell)
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onGiveButton", sender) then
        return
    end

    gf:CmdToServer('CMD_EXCHANGE_MATERIAL', {gid = self.friends[self.selectTag].gid, pos = pos, item_pos = items[1].pos})
end

-- 交流
function HomeMaterialGiveDlg:onCallButton(sender, eventType)
    if not self.selectTag then
        return
    end

    local friend = self.friends[self.selectTag]

    if friend then
        FriendMgr:communicat(friend.name, friend.gid, friend.icon, friend.lev)
    end
end

-- 显示道具名片
function HomeMaterialGiveDlg:onShowItemInfo(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(sender.name) or {})
    if not info then
        return
    end

    info.name = sender.name
    if info.item_class == ITEM_CLASS.FISH then
        info.item_type = ITEM_TYPE.FISH
    end

    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

-- 选择好友
function HomeMaterialGiveDlg:selectFriendPanel(sender, eventType)
    local tag = sender:getTag()
    if self.selectTag == tag then
        return
    end

    self.selectTag = tag
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)

    local gid = self.friends[tag].gid
    gf:CmdToServer('CMD_FRIEND_EXCHANGE_MATERIAL_DATA', {gid = self.friends[tag].gid})
end

-- 设置好友条目
function HomeMaterialGiveDlg:setOneFriendPanel(cell, data)
    local color
    local img = self:getControl("PortraitImage", nil, cell)

    if data.isOnline == 2 then
        color = COLOR3.BROWN
        gf:grayImageView(img)
    else
        color = COLOR3.GREEN
        gf:resetImageView(img)
    end

    self:setLabelText("NamePatyLabel", data.name, cell, color)

    self:setLabelText("GiveNumLabel", CHS[5400225] .. (CAN_GIVE_MAX_NUM - data.exchange_times), cell)

    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)

    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.lev, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
end

-- 创建好友列表
function HomeMaterialGiveDlg:setListView(data)
    local listView = self:getControl("FriendListView")
    self:stopSchedule(self.schedule)
    listView:removeAllItems()
    listView:setBounceEnabled(true)
    local loadcount = 0
    local count = #data
    if count == 0 then
        self:setCtrlVisible("NoticeFPanel", true, "FriendlistPanel")
        self:setCtrlVisible("FriendListView", false, "FriendlistPanel")
        return
    else
        self:setCtrlVisible("NoticeFPanel", false, "FriendlistPanel")
        self:setCtrlVisible("FriendListView", true, "FriendlistPanel")
        self:setCtrlVisible("TextLabel", true, "GiftPanel")
        self:setCtrlVisible("MNoneLabel", false, "NeedPanel")
        self:setCtrlVisible("CallButton", true, "MessagePanel")
    end

    local function func()
        if loadcount >= count  then
            self:stopSchedule(self.schedule)
            return
        end

        loadcount = loadcount + 1

         -- 创建分组标签
        local cell = self.friendPanel:clone()
        cell:setTag(loadcount)
        self:setOneFriendPanel(cell, data[loadcount])
        listView:pushBackCustomItem(cell)

        data[loadcount].cell = cell
        if loadcount == 1 then
            self:selectFriendPanel(cell)
        end
    end

    self.schedule = self:startSchedule(func, 0.02)
end

function HomeMaterialGiveDlg:MSG_EXCHANGE_MATERIAL_TARGETS(data)
    self.friends = {}
    for _, v in ipairs(data) do
        local friend = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(v.gid))
        if friend then
            friend.total_need = v.total_need
            friend.exchange_times = v.exchange_times
            table.insert(self.friends, friend)
        end
    end

    table.sort(self.friends, function(l, r)
        -- 是否在线
        if l.isOnline < r.isOnline then return true end
        if l.isOnline > r.isOnline then return false end

        -- 材料是否集齐
        if l.total_need > 0 and  r.total_need <= 0 then return true end
        if l.total_need <= 0 and  r.total_need > 0 then return false end

        -- 好友度
        if l.friendShip > r.friendShip then return true end
        if l.friendShip < r.friendShip then return false end

        return false
    end)

    self:setListView(self.friends)
end

-- 好友离线
function HomeMaterialGiveDlg:MSG_FRIEND_NOTIFICATION(data)
    local name =  data.char
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByName(name))

    if not newFriendInfo then
        return
    end

    local tag
    for key, v in ipairs(self.friends) do
        if v.gid == newFriendInfo.gid then
            v.isOnline = newFriendInfo.isOnline
            tag = key
            break
        end
    end

    local listView = self:getControl("FriendListView")
    local item = listView:getItem(tag - 1)
    if item then
        self:setOneFriendPanel(item,self.friends[tag])
    end
end

-- 设置材料单个条目
function HomeMaterialGiveDlg:setOneMaterialPanel(data, cell)
    self:setLabelText("NeedNumLabel", CHS[5400227] .. data.get_num .. "/" .. data.req_num, cell)
    self:setLabelText("NameLabel", data.name, cell)

    local amount = InventoryMgr:getAmountByName(data.name)
    self:setLabelText("HaveNumLabel", CHS[5400226] .. amount, cell)
    if amount <= 0 then
        self:setCtrlEnabled("GiveButton", false, cell)
    else
        self:setCtrlEnabled("GiveButton", true, cell)
    end

    if data.get_num >= data.req_num then
        self:setCtrlVisible("GiveButton", false, cell)
        self:setCtrlVisible("FinishImage", true, cell)
    else
        self:setCtrlVisible("GiveButton", true, cell)
        self:setCtrlVisible("FinishImage", false, cell)
    end

    local button = self:getControl("GiveButton", nil, cell)
    button.data = data

    local panel = self:getControl("ItemIconPanel", nil, cell)
    panel.name = data.name

    self:setImage("IconImage", ResMgr:getIconPathByName(data.name), cell)
end


function HomeMaterialGiveDlg:setNeedPanel(data, friend)
    -- 玩家名字
    self:setLabelText("NameLabel", friend.name, "NamePanel")

    if #data.needs == 0 then
        -- 玩家未发布求助信息
        self:setCtrlVisible("NoticeItemPanel", true)

        self:setCtrlVisible("NoneLabel", false, "MessagePanel")
        self:setCtrlVisible("TextLabel", false, "MessagePanel")

        self:setCtrlVisible("GiftPanel", false, "NeedPanel")
        self:setCtrlVisible("ItemPanel1", false, "NeedPanel")
        self:setCtrlVisible("ItemPanel2", false, "NeedPanel")
        self:setCtrlVisible("ItemPanel3", false, "NeedPanel")
        return
    else
        self:setCtrlVisible("NoticeItemPanel", false)
        self:setCtrlVisible("GiftPanel", true, "NeedPanel")
    end


    -- 需求的材料
    for i = 1, 3 do
        local need = data.needs[i]
        if need then
            local cell = self:getControl("ItemPanel" .. i, nil, "NeedPanel")
            cell:setVisible(true)
            self:setOneMaterialPanel(need, cell)
        else
            self:setCtrlVisible("ItemPanel" .. i, false, "NeedPanel")
        end
    end

    -- 附言
    if data.msg ~= "" then
        self:setLabelText("TextLabel", data.msg, "MessagePanel")
        self:setCtrlVisible("TextLabel", true, "MessagePanel")
        self:setCtrlVisible("NoneLabel", false, "MessagePanel")
    else
        self:setCtrlVisible("TextLabel", false, "MessagePanel")
        self:setCtrlVisible("NoneLabel", true, "MessagePanel")
    end

    -- 谢礼
    for i = 1, 3 do
        local gift = data.gifts[i]
        if gift then
            local cell = self:getControl("SingleGiftPanel" .. i, nil, "NeedPanel")
            cell:setVisible(true)
            self:setImage("ItemImage", ResMgr:getIconPathByName(gift.name), cell)
            self:setLabelText("NumLabel", "×" .. gift.num, cell)
            cell.name = gift.name
        else
            local cell = self:getControl("SingleGiftPanel" .. i, nil, "NeedPanel")
            cell:setVisible(false)
        end
    end

    if #data.gifts == 0 then
        self:setCtrlVisible("NoneLabel", true, "NeedPanel")
    else
        self:setCtrlVisible("NoneLabel", false, "NeedPanel")
    end
end

function HomeMaterialGiveDlg:MSG_FRIEND_EXCHANGE_MATERIAL_DATA(data)
    if not self.selectTag then
        return
    end

    local friend = self.friends[self.selectTag]
    if data.gid == friend.gid then
        self:setNeedPanel(data, friend)
    end

    -- 刷新好友条目剩余可赠送数量
    if friend.cell then
        self:setLabelText("GiveNumLabel", CHS[5400225] .. (CAN_GIVE_MAX_NUM - data.exchange_times), friend.cell)
    end
    -- self.materials[data.gid] = data
end

function HomeMaterialGiveDlg:cleanup()
    self.materials = {}
    self.friends = {}
end

return HomeMaterialGiveDlg
