-- TeamReserveDlg.lua
-- Created by sujl, Oct/17/2018
-- 队友补充储备界面

local TeamReserveDlg = Singleton("TeamReserveDlg", Dialog)

function TeamReserveDlg:init(param)
    self:bindListener("UseButton", self.onUseLifeButton, "ItemPanel1")
    self:bindListener("UseButton", self.onUseManaButton, "ItemPanel2")
    self:bindListener("UseButton", self.onUseLoyaltyButton, "ItemPanel3")
    self:bindListener("ItemPanel", self.onClickItem1, "ItemPanel1")
    self:bindListener("ItemPanel", self.onClickItem2, "ItemPanel2")
    self:bindListener("ItemPanel", self.onClickItem3, "ItemPanel3")

    self:setCharInfo(param)

    self:hookMsg("MSG_FIXED_TEAM_OPEN_SUPPLY_DLG")
end

function TeamReserveDlg:setCharInfo(info)
    self.charInfo = info

    self:setImage("BackImage2", ResMgr:getSmallPortrait(info.icon), self:getControl("PortraitPanel", nil, "MainPanel"))
    self:setLabelText("NameLabel", info.name, "MainPanel")
    self:setLabelText("ReserveLabel1", string.format(CHS[2100269], info.life), "MainPanel")
    self:setLabelText("ReserveLabel2", string.format(CHS[2100270], info.mana), "MainPanel")
    self:setLabelText("ReserveLabel3", string.format(CHS[2100271], info.loyalty), "MainPanel")

    local item

    -- 气血道具
    item = InventoryMgr:getItemInfoByName(info.life_item_name)
    self:setImage("IconImage", ResMgr:getItemIconPath(item.icon), self:getControl("ItemPanel1", nil, "MainPanel"))
    if info.life_item_num > 1 then
        self:setNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel1", nil, "MainPanel")), ART_FONT_COLOR.NORMAL_TEXT, info.life_item_num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        self:setCtrlEnabled("IconImage", true, self:getControl("ItemPanel1", nil, "MainPanel"))
    else
        self:removeNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel1", nil, "MainPanel")), LOCATE_POSITION.RIGHT_BOTTOM)
        self:setCtrlEnabled("IconImage", info.life_item_num > 0, self:getControl("ItemPanel1", nil, "MainPanel"))
    end

    -- 法力道具
    item = InventoryMgr:getItemInfoByName(info.mana_item_name)
    self:setImage("IconImage", ResMgr:getItemIconPath(item.icon), self:getControl("ItemPanel2", nil, "MainPanel"))
    if info.mana_item_num > 1 then
        self:setNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel2", nil, "MainPanel")), ART_FONT_COLOR.NORMAL_TEXT, info.mana_item_num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        self:setCtrlEnabled("IconImage", true, self:getControl("ItemPanel2", nil, "MainPanel"))
    else
        self:removeNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel2", nil, "MainPanel")), LOCATE_POSITION.RIGHT_BOTTOM)
        self:setCtrlEnabled("IconImage", info.mana_item_num > 0, self:getControl("ItemPanel2", nil, "MainPanel"))
    end

    -- 忠诚道具
    item = InventoryMgr:getItemInfoByName(info.loyalty_item_name)
    self:setImage("IconImage", ResMgr:getItemIconPath(item.icon), self:getControl("ItemPanel3", nil, "MainPanel"))
    if info.loyalty_item_num > 1 then
        self:setNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel3", nil, "MainPanel")), ART_FONT_COLOR.NORMAL_TEXT, info.loyalty_item_num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        self:setCtrlEnabled("IconImage", true, self:getControl("ItemPanel3", nil, "MainPanel"))
    else
        self:removeNumImgForPanel(self:getControl("ItemPanel", nil, self:getControl("ItemPanel3", nil, "MainPanel")), LOCATE_POSITION.RIGHT_BOTTOM)
        self:setCtrlEnabled("IconImage", info.loyalty_item_num > 0, self:getControl("ItemPanel3", nil, "MainPanel"))
    end
end

-- 显示道具名片
function TeamReserveDlg:showItemCard(sender, itemName)
    local rect = self:getBoundingBoxInWorldSpace(sender)

    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(itemName) or {})
    if not info then
        return
    end

    info.name = itemName
    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function TeamReserveDlg:onUseLifeButton(sender)
    if not self.charInfo then return end
    if self.charInfo.life_item_num <= 0 then
        gf:ShowSmallTips(string.format(CHS[2100272], self.charInfo.name))
        return
    end

    gf:CmdToServer("CMD_FIXED_TEAM_SUPPLY", { gid = self.charInfo.gid, item_name = self.charInfo.life_item_name })
end

function TeamReserveDlg:onUseManaButton(sender)
    if not self.charInfo then return end
    if self.charInfo.mana_item_num <= 0 then
        gf:ShowSmallTips(string.format(CHS[2100272], self.charInfo.name))
        return
    end

    gf:CmdToServer("CMD_FIXED_TEAM_SUPPLY", { gid = self.charInfo.gid, item_name = self.charInfo.mana_item_name })
end

function TeamReserveDlg:onUseLoyaltyButton(sender)
    if not self.charInfo then return end
    if self.charInfo.loyalty_item_num <= 0 then
        gf:ShowSmallTips(string.format(CHS[2100272], self.charInfo.name))
        return
    end

    gf:CmdToServer("CMD_FIXED_TEAM_SUPPLY", { gid = self.charInfo.gid, item_name = self.charInfo.loyalty_item_name })
end

function TeamReserveDlg:onClickItem1(sender)
    self:showItemCard(sender, self.charInfo.life_item_name)
end

function TeamReserveDlg:onClickItem2(sender)
    self:showItemCard(sender, self.charInfo.mana_item_name)
end

function TeamReserveDlg:onClickItem3(sender)
    self:showItemCard(sender, self.charInfo.loyalty_item_name)
end

function TeamReserveDlg:MSG_FIXED_TEAM_OPEN_SUPPLY_DLG(data)
    self:setCharInfo(data)
end

return TeamReserveDlg