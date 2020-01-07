-- FaBaoChangeDlg.lua
-- Created by songcw Aug/13/2018
-- 法宝元神共通界面

local FaBaoChangeDlg = Singleton("FaBaoChangeDlg", Dialog)

local EQUIP_ING = 9
local EQUIP_BACK = 19

function FaBaoChangeDlg:init()
    self:bindListener("ItemShapePanel", self.onArtifact, "MaterialPanel1")
    self:bindListener("ItemShapePanel", self.onArtifact, "MaterialPanel2")

    -- 初始化参战宠物
    self.artifact1 = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
    self:setAtfInfo(self.artifact1, "MaterialPanel1")

    self.artifact2 = InventoryMgr:getItemByPos(EQUIP.BACK_ARTIFACT)
    self:setAtfInfo(self.artifact2, "MaterialPanel2")

    local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_artifact", 0)
    local changeStatePanel = self:getControl("OpenStatePanel")
    self:createSwichButton(changeStatePanel, changeOn, self.onAtfChange, nil, self.limitCondition)

    self:hookMsg("MSG_INVENTORY")
end

function FaBaoChangeDlg:limitCondition()
    if not self.artifact1 or not self.artifact2 then return true end

    if InventoryMgr:isTimeLimitedItem(self.artifact1) or InventoryMgr:isTimeLimitedItem(self.artifact2) then
        gf:ShowSmallTips(CHS[4101206])
        return true
    end

    return false
end

function FaBaoChangeDlg:onAtfChange(isOn, key)
    if not self.artifact1 or not self.artifact2 then return end

    if isOn then
        SystemSettingMgr:sendSeting("award_supply_artifact", 1)
    else
        SystemSettingMgr:sendSeting("award_supply_artifact", 0)
    end

end

function FaBaoChangeDlg:onArtifact(sender, eventType)
    local artifact = sender.artifact
    if not artifact then return end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    -- 显示法宝
    InventoryMgr:showArtifact(artifact, rect, true)
end

function FaBaoChangeDlg:setAtfInfo(artifact, panelName)
    local img = self:getControl("ItemImage", Const.UIImage, panelName)
    img:setVisible(true)
    if not artifact then

        local notImage = InventoryMgr:getEquipment_Backimage()[EQUIP.ARTIFACT]
        img:loadTexture(notImage)
        return
    end



    -- 设置图标
    path = InventoryMgr:getIconFileByName(artifact.name)
    img:loadTexture(path)
    gf:setItemImageSize(img)

    -- 图标左上角等级
    local ctl = self:getControl("ItemShapePanel", nil, panelName)
    ctl.artifact = artifact
    self:setNumImgForPanel(ctl, ART_FONT_COLOR.NORMAL_TEXT,artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21)

        -- 图标左下角限制交易/限时标记
    if artifact and InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:addLogoTimeLimit(img)
    elseif artifact and InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:addLogoBinding(img)
    end

    -- 图标右下角相性标志
    if artifact.item_polar and artifact.item_polar >= 1 and artifact.item_polar <= 5 then
        InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
    end
end

function FaBaoChangeDlg:MSG_INVENTORY(data)
    if data.count <= 0 then return end
    for i = 1, data.count do
        if data[i].pos == EQUIP.ARTIFACT or data[i].pos == EQUIP.BACK_ARTIFACT then
            if not data[i].name then
                self:onCloseButton()
            end
        end
    end
end

return FaBaoChangeDlg
