-- ServiceGiftDlg.lua
-- Created by songcw Apr/08/2018
-- 位列仙班礼包选择界面

local ServiceGiftDlg = Singleton("ServiceGiftDlg", Dialog)

local TITLE_MAP = {
    [CHS[7150014]] = CHS[4300348],         -- 月 卡 礼 包
    [CHS[7150015]] = CHS[4300349],         -- 季 卡 礼 包
    [CHS[7150016]] = CHS[4300350],            -- 年 卡 礼 包
}

local VIP_DAYS = {
    [CHS[7150014]] = CHS[4300351],         -- 30天
    [CHS[7150015]] = CHS[4300352],             -- 90天
    [CHS[7150016]] = CHS[4300353],         -- 360
}

local FASHION_DAYS = {
    [CHS[7150014]] = CHS[4300354],         -- 20天
    [CHS[7150015]] = CHS[4300355],         -- 40天
    [CHS[7150016]] = CHS[4300356],         -- 120
}


function ServiceGiftDlg:init(data)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    self.unitPanel = self:retainCtrl("OneRowPartyMemberPanel")
    self:bindListener("CheckBox", self.onCheckBox, self.unitPanel)
    self.notePanel = self:retainCtrl("NotePanel")


    self.fashion = nil
    self.data = data
    self:setData(data)
end

function ServiceGiftDlg:setData(data)
    local item = InventoryMgr:getItemByPos(data.pos)
    self:setLabelText("TitleLabel_1", TITLE_MAP[item.name])
    self:setLabelText("TitleLabel_2", TITLE_MAP[item.name])
    
    local list = self:resetListView("ListView")
    
    -- 会员
    local panel = self.unitPanel:clone()
    self:setImagePlist("Image", ResMgr.ui.big_vip_icon, panel)    
    
    local name = string.match(item.name, CHS[4300357])
    self:setLabelText("NameLabel", name .. VIP_DAYS[item.name], panel)    
    local goldText = gf:getArtFontMoneyDesc(tonumber(data.insider_price))
    self:setNumImgForPanel("CoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23, panel) 
    self:setCtrlVisible("CheckBox", false, panel)   
    list:pushBackCustomItem(panel)
    
    list:pushBackCustomItem(self.notePanel)
    
    -- 时装
    for i = 1, data.count do
        local panel = self.unitPanel:clone()
        self:setUnitPanel(data[i], item.name, data.fasion_price, panel, i)
        list:pushBackCustomItem(panel)
    end    
end

function ServiceGiftDlg:setUnitPanel(itemName, giftName, price, panel, i)
    self:setImage("Image", ResMgr:getIconPathByName(itemName), panel)    
    self:setImageSize("Image", {width = 70, height = 70}, panel)    
    self:setLabelText("NameLabel", itemName .. "·" .. FASHION_DAYS[giftName], panel) 
    local goldText = gf:getArtFontMoneyDesc(tonumber(price))
    self:setNumImgForPanel("CoinPanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
    
    self:setCtrlVisible("BackImage_2", i % 2 == 0, panel)    
    panel.fashion = itemName
    
end

function ServiceGiftDlg:onCheckBox(sender)
    local list = self:getControl("ListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        self:setCheck("CheckBox", false, panel)
    end
    
    self.fashion = sender:getParent().fashion
    sender:setSelectedState(true)
end


function ServiceGiftDlg:onGetButton(sender, eventType)

    if InventoryMgr:getEmptyPosCount() < 1 then
        -- 包裹格子不足
        gf:ShowSmallTips(CHS[7150009])
        return
    end

    if not self.fashion then
        gf:ShowSmallTips(CHS[4300358])
        return
    end

    gf:CmdToServer("CMD_APPLY_INSIDER_GIFT", {
        pos = self.data.pos,
        fasion_name = self.fashion,
    })
    
    self:onCloseButton()
end

function ServiceGiftDlg:onSelectListView(sender, eventType)
end

return ServiceGiftDlg
