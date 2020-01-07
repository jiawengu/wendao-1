-- XunBaoBagDlg.lua
-- Created by huangzz Oct/10/2018
-- 寻宝宝箱界面

local XunBaoBagDlg = Singleton("XunBaoBagDlg", Dialog)

function XunBaoBagDlg:init()
    self:bindListener("ItemPanel", self.onItemImage)
    self.itemPanel = self:retainCtrl("ItemPanel")
end

function XunBaoBagDlg:onItemImage(sender)
    local data = sender.data
    if data then
        if string.match(data.item_name, CHS[6000583]) then
            -- 道行
            local dlg = DlgMgr:openDlg("BonusInfoDlg")
            local rect = self:getBoundingBoxInWorldSpace(sender)
            dlg:setRewardInfo({
                imagePath = ResMgr.ui.daohang,
                resType = ccui.TextureResType.plistType,
                basicInfo = {
                    [1] = data.item_name
                },

                desc = CHS[3002148]
            })
            dlg.root:setAnchorPoint(0, 0)
            dlg:setFloatingFramePos(rect)
        else
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(data.item_name, rect)
        end
    end
end

function XunBaoBagDlg:setCellData(cell, data)
    if not next(data) then
        cell:setBackGroundImage(ResMgr.ui.bag_no_item_bg_img, ccui.TextureResType.plistType)
        return
    end

    local img = self:getControl("ItemImage", nil, cell)
    if string.match(data.item_name, CHS[6000583]) then
        -- 道行
        img:loadTexture(ResMgr.ui.daohang, ccui.TextureResType.plistType)
    else
        img:loadTexture(ResMgr:getIconPathByName(data.item_name))
    end

    self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, data.num, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

    cell.data = data
end

function XunBaoBagDlg:setData(data)
    local scrollView = self:getControl("ScrollView")
    for i = #data + 1, 20 do
        data[i] = {}
    end

    self:initScrollViewPanel(data, self.itemPanel, self.setCellData, scrollView, 5, 6, 6, 11, 8)
end

return XunBaoBagDlg
