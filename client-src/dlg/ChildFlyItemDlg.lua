-- ChildFlyItemDlg.lua
-- Created by lixh, Apr/12/2019
-- 娃娃飞升界面

local ChildFlyItemDlg = Singleton("ChildFlyItemDlg", Dialog)

-- 飞升材料配置
local MATERIAL_CFG = {
    {name = CHS[8000019], count = 1}, -- 竹马（金色）
    {name = CHS[8000020], count = 1}, -- 毽子（金色）
    {name = CHS[8000021], count = 1}, -- 蹴球（金色）
    {name = CHS[8000022], count = 1}, -- 弹弓（金色）
    {name = CHS[8000023], count = 1}, -- 陀螺（金色）
    {name = CHS[8000024], count = 1}, -- 风筝（金色）
}

function ChildFlyItemDlg:init()
    self:bindListener("FlyButton", self.onFlyButton)
end

function ChildFlyItemDlg:setData(data)
    self.kidId = data.id

    local kid = HomeChildMgr:getKidByCid(data.id)
    if not kid then
        return
    end

    self:setLeftData(kid)
    self:setRightData(kid, data)
end

function ChildFlyItemDlg:setLeftData(kid)
    -- 头像
    local iconPanel = self:getControl("ChildIconPanel")
    self:setImage("PetImage", ResMgr:getSmallPortrait(kid:queryBasicInt("portrait")), iconPanel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, kid:getLevel(), false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 材料
    for i = 1, #MATERIAL_CFG do
        local itemPanel = self:getControl("ItemPanel" .. i)
        local itemName = MATERIAL_CFG[i].name
        local itemNeedNum = MATERIAL_CFG[i].count
        local itemNum = InventoryMgr:getAmountByName(itemName, true, CHS[7120206])
        local icon = InventoryMgr:getIconByName(itemName)

        -- 道具图标
        self:setImage("ItemImage",  ResMgr:getItemIconPath(icon), itemPanel)

        -- 道具数量（若数量小于所需数量，显示为红色）
        self:setNumImgForPanel("NumPanel2", ART_FONT_COLOR.NORMAL_TEXT, "/" .. itemNeedNum, false, LOCATE_POSITION.RIGHT_TOP, 17, itemPanel)
        local showItemNum = itemNum > 999 and "*" or itemNum
        if itemNum >= itemNeedNum then
            self:setNumImgForPanel("NumPanel1", ART_FONT_COLOR.NORMAL_TEXT, showItemNum, false, LOCATE_POSITION.RIGHT_TOP, 15, itemPanel)
        else
            self.notEnoughItem = true
            self:setNumImgForPanel("NumPanel1", ART_FONT_COLOR.RED, showItemNum, false, LOCATE_POSITION.RIGHT_TOP, 15, itemPanel)
        end

        local function func(sender, eventType)
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(itemName, rect)
        end

        itemPanel:addTouchEventListener(func)

        -- 道具名称
        self:setLabelText("NameLabel", itemName, itemPanel)
    end
end

function ChildFlyItemDlg:setRightData(kid, data)
    local panel = self:getControl("AttriPanel")

    local lifeShape = kid:queryInt("life_shape")
    local manaShape = kid:queryInt("mana_shape")
    local speedShape = kid:queryInt("speed_shape")
    local phyShape = kid:queryInt("phy_shape")
    local magShape = kid:queryInt("mag_shape")
    local allShape = lifeShape + manaShape + speedShape + phyShape + magShape

    local lifeShapeEx = lifeShape + data.life_shape
    local manaShapeEx = manaShape + data.mana_shape
    local speedShapeEx = speedShape + data.speed_shape
    local phyShapeEx = phyShape + data.phy_shape
    local magShapeEx = magShape + data.mag_shape
    local allShapeEx = lifeShapeEx + manaShapeEx + speedShapeEx + phyShapeEx + magShapeEx

    -- 名字
    self:setLabelText("PetNameLabel", kid:getName(), panel)

    -- 总资质
    self:setLabelText("TotalGrowValueLabel1", allShape, panel)
    self:setLabelText("TotalGrowValueLabel3", allShapeEx, panel)

    -- 气血资质
    self:setLabelText("LifeGrowValueLabel1", lifeShape, panel)
    self:setLabelText("LifeGrowValueLabel3", lifeShapeEx, panel)

    -- 法力资质
    self:setLabelText("ManaGrowValueLabel1", manaShape, panel)
    self:setLabelText("ManaGrowValueLabel3", manaShapeEx, panel)

    -- 速度资质
    self:setLabelText("SpeedGrowValueLabel1", speedShape, panel)
    self:setLabelText("SpeedGrowValueLabel3", speedShapeEx, panel)

    -- 物攻资质
    self:setLabelText("PhyGrowValueLabel1", phyShape, panel)
    self:setLabelText("PhyGrowValueLabel3", phyShapeEx, panel)

    -- 法攻资质
    self:setLabelText("MagGrowValueLabel1", magShape, panel)
    self:setLabelText("MagGrowValueLabel3", magShapeEx, panel)
end

function ChildFlyItemDlg:cleanup()
    self.notEnoughItem = nil
    self.kidId = nil
end

function ChildFlyItemDlg:onFlyButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    if self.notEnoughItem then
        gf:ShowSmallTips(CHS[7120199])
        return
    end

    if self:checkSafeLockRelease("onFlyButton") then
        return
    end

    local itemPosStr = ""
    for i = 1, #MATERIAL_CFG do
        local item = InventoryMgr:getItemByNameAndLevel(MATERIAL_CFG[i].name, nil, CHS[7120206])
        if not item or #item <= 0 then
            gf:ShowSmallTips(CHS[7120199])
            return
        else
            if itemPosStr == "" then
                itemPosStr = itemPosStr .. item[1].pos
            else
                itemPosStr = itemPosStr .. "|" .. item[1].pos
            end
        end
    end

    gf:CmdToServer("CMD_SUBMIT_CHILD_UPGRADE_ITEM", {itemPosStr = itemPosStr})
end

return ChildFlyItemDlg
