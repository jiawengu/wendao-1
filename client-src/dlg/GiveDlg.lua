-- GiveDlg.lua
-- Created by song Aug/10/2016
-- 赠送界面

local GiveDlg = Singleton("GiveDlg", Dialog)
local DataObject = require("core/DataObject")

GiveDlg.item = nil    -- 交易的物品

GiveDlg.isLock = nil  -- 是否是锁定状态

function GiveDlg:init()
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("GiveButton", self.onGiveButton)
    self:bindListener("ReceiveButton", self.onReceiveButton)
    self:bindListener("GetReadyButton", self.onGetReadyButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ItemPanel", self.onItemPanel)

    self.isLock = nil  -- 是否是锁定状态
    self.notSendFail = false    -- 关闭的时候需要发送取消消息
    self.giveItem = nil
    self.itemType = nil

    self:hookMsg("MSG_COMPLETE_GIVING")
    self:hookMsg("MSG_UPDATE_GIVING_ITEM")
end

function GiveDlg:cleanup()
    -- 需要向服务器发送消息
    if not self.notSendFail then
        GiveMgr:cancelGiving()
    end
end

function GiveDlg:setData(data)

    -- 设置赠送者信息
    self:setUserInfo(data.giver, "GiverShapePanel")

    -- 设置接受者信息
    self:setUserInfo(data.receiver, "ReceiverShapePanel")

    self.isGiver = (data.giver.name == Me:queryBasic("name"))

    -- 设置物品状态
    self:setItemInfo(nil, self.isGiver)

    -- 设置下方按钮状态
    self:setBtnDisplay(self.isGiver)
end

-- 设置玩家信息
function GiveDlg:setUserInfo(charInfo, panelName)
    local panel = self:getControl(panelName)
    self:setLabelText("NameLabel", gf:getRealName(charInfo.name), panel)
    self:setLabelText("LeftNumLabel", charInfo.leftTimes, panel)
    if "ReceiverShapePanel" == panelName then
        self:setPortrait("IconPanel", charInfo.icon, charInfo.weapon, panel, nil, nil, nil, nil, nil, nil,7)
    else
        self:setPortrait("IconPanel", charInfo.icon, charInfo.weapon, panel, nil, nil, nil, nil, nil, nil,5)
    end

    -- 仙魔光效
    if charInfo["upgrade/type"] then
        self:addUpgradeMagicToCtrl("IconPanel", charInfo["upgrade/type"], panelName, true)
    end

    panel:requestDoLayout()
end

-- 设置物品信息   itemType（背包：1，宠物：2，卡套：3）
function GiveDlg:setItemInfo(item, isGiver, itemType)
    local panel = self:getControl("GiveItemPanel")
    self:setCtrlVisible("IconImage", false, panel)
    self:setCtrlVisible("AddImage", false, panel)
    self:setCtrlVisible("ReadyImage", false, panel)
    self:setLabelText("GiveDescribeLabel", "", panel)

    local ctrl = self:getControl("IconImage", nil, panel)
    InventoryMgr:removeLogoUnidentified(ctrl)
    if item then
        self:setCtrlVisible("IconImage", true, panel)
        if itemType and itemType == 2 then
            self:setImage("IconImage", ResMgr:getSmallPortrait(item:queryBasicInt("icon")))
            self:setItemImageSize("IconImage")
            self:setLabelText("GiveDescribeLabel", item:queryBasic("name") .. " × 1", panel)
        else
            self:setImage("IconImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)), panel)
            self:setLabelText("GiveDescribeLabel", item.name .. " × 1", panel)
            self:setItemImageSize("IconImage", panel)
            if item.item_type == ITEM_TYPE.EQUIPMENT and item.req_level and item.req_level > 0 then
                self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            elseif item.item_type == ITEM_TYPE.ARTIFACT and item.level and item.level > 0 then
                self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            else
                self:removeNumImgForPanel("ItemPanel", LOCATE_POSITION.LEFT_TOP, panel)
            end

            if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
                InventoryMgr:addLogoUnidentified(ctrl)
            end

            -- 法宝相性
            if item.item_type == ITEM_TYPE.ARTIFACT and item.item_polar then
                InventoryMgr:addArtifactPolarImage(ctrl, item.item_polar)
            end
        end
    else
        if isGiver then
            self:setCtrlVisible("AddImage", true, panel)
            self:setLabelText("GiveDescribeLabel", CHS[4100306], panel) -- 选择增送物品
        else
            self:setCtrlVisible("ReadyImage", true, panel)
            self:setLabelText("GiveDescribeLabel", CHS[4100307], panel) -- 正在挑选物品
        end
    end

    panel:requestDoLayout()

    self.giveItem = item
    self.itemType = itemType
end

function GiveDlg:setBtnDisplay(isGiver)
    self:setCtrlVisible("CancleButton", false)
    self:setCtrlVisible("RefuseButton", false)
    self:setCtrlVisible("GiveButton", false)
    self:setCtrlVisible("ReceiveButton", false)

    if isGiver then
        self:setCtrlVisible("CancleButton", true)
        self:setCtrlVisible("GiveButton", true)
        if self.isLock then
            self:setCtrlEnabled("GiveButton", false)
            self:setLabelTextShadow("GiveButton", CHS[4100308]) --对方确认中...
        else
            self:setCtrlEnabled("GiveButton", true)
            self:setLabelTextShadow("GiveButton", CHS[4100299])
        end
    else
        self:setCtrlVisible("RefuseButton", true)
        self:setCtrlVisible("ReceiveButton", true)
        if self.isLock then
            self:setCtrlEnabled("ReceiveButton", true)
            self:setLabelTextShadow("ReceiveButton", CHS[4100309])
        else
            self:setCtrlEnabled("ReceiveButton", false)
            self:setLabelTextShadow("ReceiveButton", CHS[4100310])
        end
    end
end

function GiveDlg:setLabelTextShadow(btnName, content, root)
    local btn = self:getControl(btnName)
    self:setLabelText("Label_1", content, btn)
    self:setLabelText("Label_2", content, btn)
end

function GiveDlg:onCancleButton(sender, eventType)
    GiveMgr:cancelGiving()
    self:onCloseButton()
end

function GiveDlg:onRefuseButton(sender, eventType)
    GiveMgr:cancelGiving()
    self:onCloseButton()
end

function GiveDlg:onGiveButton(sender, eventType)
    if not self.giveItem then
        gf:ShowSmallTips(CHS[4100311]) --请选择增送的物品
        return
    end
    if self.itemType and self.itemType == 2 then
        GiveMgr:submitGiveingItem(self.itemType, self.giveItem:queryBasicInt("no"))
    else
        if not self.itemType or not self.giveItem.pos then
            -- 走到这正常情况不可能，返回。让玩家重新选择物品
            return
        end
        GiveMgr:submitGiveingItem(self.itemType, self.giveItem.pos)
    end
end

function GiveDlg:onReceiveButton(sender, eventType)
    GiveMgr:accecpGiving()
    self:onCloseButton()
end

function GiveDlg:onGetReadyButton(sender, eventType)
end

function GiveDlg:onItemPanel(sender, eventType)
    if self.isLock then
        if self.itemType and self.itemType == 2 then
            local dlg =  DlgMgr:openDlg("PetCardDlg")
            dlg:setPetInfo(self.giveItem)
            PetMgr:setIntimacyForCard(dlg, "isGive", self.giveItem)
        else
            local rect = self:getBoundingBoxInWorldSpace(sender)
            self.giveItem.isGiveType = true -- 用于法宝亲密显示
            InventoryMgr:showOnlyFloatCardDlgEx(self.giveItem, rect)
        end
    else
        if self.isGiver then
            local dlg = DlgMgr:openDlg("ChooseItemDlg")
            if self.giveItem then
                dlg:setInitSelect(self.giveItem, self.itemType)
            end
        else

        end
    end
end

function GiveDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("GiveRuleDlg")
end

function GiveDlg:MSG_COMPLETE_GIVING(data)
    self.notSendFail = true
    self:onCloseButton()
end

function GiveDlg:MSG_UPDATE_GIVING_ITEM(data)
    self.giveItem = data.item
    self.isLock = true
    if data.itemType == 1 then
        self.giveItem = DataObject.new()
        self.giveItem:absorbBasicFields(data.item)
        self.itemType = 2
        self:setItemInfo(self.giveItem, self.isGiver, 2)  -- 宠物
    else
        self:setItemInfo(data.item, self.isGiver)
        local panel = self:getControl("IconImage", nil, "GiveItemPanel")
        if data.item.item_type == ITEM_TYPE.EQUIPMENT and data.item.req_level and data.item.req_level > 0 then
            self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, data.item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        elseif data.item_type == ITEM_TYPE.ARTIFACT and data.level and data.level > 0 then
            self:setNumImgForPanel("ItemPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
        end

        if data.item.item_type == ITEM_TYPE.EQUIPMENT and data.item.unidentified == 1 then
            InventoryMgr:addLogoUnidentified(panel)
        end
    end
    self:setBtnDisplay(self.isGiver)
end

return GiveDlg
