-- GetItemDlg.lua
-- Created by songcw May/26/2015
-- 天技商店获得物品对话框

local GetItemDlg = Singleton("GetItemDlg", Dialog)

function GetItemDlg:init()
    self:bindListener("ConfrimButton", self.onConfrimButton)
end

function GetItemDlg:setItem(name)
    local icon = InventoryMgr:getIconByName(name)
    self:setImage("ShapeImage", ResMgr:getItemIconPath(icon))
    self:setItemImageSize("ShapeImage")
    self:setLabelText("NameLabel", name)
end

function GetItemDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

return GetItemDlg
