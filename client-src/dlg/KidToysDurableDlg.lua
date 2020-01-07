-- KidToysDurableDlg.lua
-- Created by songcw Apir/19/2019
-- 娃娃玩具界面 - 增加耐久

local KidToysDurableDlg = Singleton("KidToysDurableDlg", Dialog)

local ToyEffect =  require (ResMgr:getCfgPath("ToyEffect.lua"))

local FIELD_MAP = {
    [CHS[7120193]] = "max_life",
    [CHS[7120194]] = "def",
    [CHS[7120195]] = "speed",
    [CHS[7120196]] = "phy_power",
    [CHS[7120197]] = "mag_power",
    [CHS[7120198]] = "max_mana",
}

local QUALITY_COLOR = {
    [CHS[5450431]] = 1,     [CHS[5450434]] = 2,     [CHS[7002102]] = 3,
}


function KidToysDurableDlg:init(data)
    self:bindListener("DurableButton", self.onDurableButton)
    self:bindListener("IncreaseButton", self.onIncreaseButton)

    self:setImage("ItemImage", ResMgr:getIconPathByName(data.toy_name))
    self:setCtrlVisible("IncreaseButton", false)

    self.data = data
    local pos = gf:findStrByByte(data.toy_name, "（")
    local name = string.sub(data.toy_name, 0, pos - 1)

    local pos2 = gf:findStrByByte(data.toy_name, "）")
    local color = string.sub(data.toy_name, pos + 3, pos2 - 1)

    self:setLabelText("NameLabel", data.toy_name, nil, InventoryMgr:getItemColor({color = color}))
    self:setLabelText("DurableLabel", InventoryMgr:getAmountByName(data.toy_name) .. "/" .. 1)

    -- 当前耐久
    self:setLabelText("CurrentDurableNumLabel", data.naijiu .. "/" .. (HomeChildMgr:getNaijiuByColor(color) * 2))

    -- 本次补充
    self:setLabelText("SupplementNumLabel", HomeChildMgr:getNaijiuByColor(color))
end

function KidToysDurableDlg:getMaxDur(itemName)

    local pos = gf:findStrByByte(itemName, "（")
    local name = string.sub(itemName, 0, pos - 1)
    local field = FIELD_MAP[name]

    local pos2 = gf:findStrByByte(itemName, "）")
    local color = string.sub(itemName, pos + 3, pos2 - 1)
    local qua = QUALITY_COLOR[color]
    local cfg = ToyEffect[field]
    local lv = math.floor( Me:queryBasicInt("level") / 10 )
    return cfg[lv][qua]
end


function KidToysDurableDlg:onDurableButton(sender, eventType)
    local amount = InventoryMgr:getAmountByName(self.data.toy_name)
    if amount <= 0 then
        gf:ShowSmallTips(CHS[4200767])
        self:onCloseButton()
        return
    end

    local items = InventoryMgr:getItemsByName(self.data.toy_name)
    if not items or #items == 0 then
        self:onCloseButton()
        return
    end

    local item = self:getFirstItem(items)
    gf:CmdToServer("CMD_CHILD_SUPPLY_TOY_DURABILITY", {child_id = self.data.child_id, toy_name = self.data.toy_name, toy_id = item.item_unique})
    self:onCloseButton()
end

function KidToysDurableDlg:getFirstItem(items)
    for i, item in pairs(items) do
        if InventoryMgr:isTimeLimitedItem(item) then
            return item
        end
    end

    for i, item in pairs(items) do
        if InventoryMgr:isLimitedItemForever(item) then
            return item
        end
    end

    for i, item in pairs(items) do
        if InventoryMgr:isLimitedItem(item) then
            return item
        end
    end

    return items[1]
end


function KidToysDurableDlg:onIncreaseButton(sender, eventType)
end

return KidToysDurableDlg
