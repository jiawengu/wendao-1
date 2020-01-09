-- CaseEvidenceDlg.lua
-- Created by lixh Jul/04/2018
-- 【探案】迷仙镇案 使用线索界面

local CaseEvidenceDlg = Singleton("CaseEvidenceDlg", Dialog)

function CaseEvidenceDlg:init()
    self.itemPanel = self:retainCtrl("OneItemPanel")
    self:bindListViewListener("ItemListView", self.onSelectItemListView, self.onLongTouchListViewListener)

    self:initData()
end

-- 初始化界面内容
function CaseEvidenceDlg:initData()
    local items = TanAnMgr:getEvidenceItems()
    if #items == 0 then
        self:setCtrlVisible("NonePanel", true)
    else
        self:setCtrlVisible("NonePanel", false)
        local listView = self:resetListView("ItemListView")
        for i = 1, #items do
            local itemPanel = self.itemPanel:clone()
            self:setImage("ItemImage", ResMgr:getItemIconPath(items[i].icon), itemPanel)
            self:setLabelText("ItemNameLabel", items[i].name, itemPanel)
            itemPanel.itemName = items[i].name
            listView:pushBackCustomItem(itemPanel)
        end
    end
end

function CaseEvidenceDlg:onSelectItemListView(sender, eventType)
    local itemPanel = self:getListViewSelectedItem(sender)
    if not itemPanel then return end

    -- 道具图标框
    local iconImage = self:getControl("ItemBackImage", nil, itemPanel)
    local touchPos = iconImage:getParent():convertToNodeSpace(GameMgr.curTouchPos)
    if iconImage:getBoundingBox() and not cc.rectContainsPoint(iconImage:getBoundingBox(), touchPos) then
        return
    end

    if not Me:getTalkId() then return end

    -- 使用证物
    gf:CmdToServer('CMD_MXAZ_USE_EXHIBIT', { npcId = Me:getTalkId(), name = itemPanel.itemName})
end

function CaseEvidenceDlg:onLongTouchListViewListener(sender, eventType)
    local itemPanel = self:getListViewSelectedItem(sender)
    if not itemPanel then return end

    -- 道具图标框
    local iconImage = self:getControl("ItemBackImage", nil, itemPanel)
    local touchPos = iconImage:getParent():convertToNodeSpace(GameMgr.curTouchPos)
    if iconImage:getBoundingBox() and not cc.rectContainsPoint(iconImage:getBoundingBox(), touchPos) then
        return
    end

    -- 悬浮框
    local rect = self:getBoundingBoxInWorldSpace(itemPanel)
    InventoryMgr:showBasicMessageByItem(itemPanel.item, rect)
end

return CaseEvidenceDlg
