-- JewelryChangeDlg.lua
-- Created by songcw Apr/19/2018
-- 首饰转换

local JewelryChangeDlg = Singleton("JewelryChangeDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

--  CHS[4000090]:气血   CHS[4000110]:法力    CHS[4000032]:伤害
local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},

    [EQUIP.BACK_BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.BACK_NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.BACK_LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.BACK_RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

-- 精华消耗，最大10次，配置11个，因为最大值显示10次
local JINGHUA_COST = {
    60, 90, 150, 240, 360, 510, 710, 960, 1260, 1610, 1610
}

local NVWA_COST = 2

-- 第二天装备对应的第一条装备位置
local SECOND_TO_ONE_JEWELEY = {
    [EQUIP.BACK_BALDRIC] = EQUIP.BALDRIC,
    [EQUIP.BACK_NECKLACE] = EQUIP.NECKLACE,
    [EQUIP.BACK_LEFT_WRIST] = EQUIP.LEFT_WRIST,
    [EQUIP.BACK_RIGHT_WRIST] = EQUIP.RIGHT_WRIST,
}

function JewelryChangeDlg:init()
    --gf:ShowSmallTips(Me:queryBasicInt("transform_num"))

    self:bindListener("AttributeButton1", self.onAttributeButton)
    self:bindListener("AttributeButton2", self.onAttributeButton)
    self:bindListener("AttributeButton3", self.onAttributeButton)
    self:bindListener("AttributeButton4", self.onAttributeButton)
    self:bindListener("AttributeButton5", self.onAttributeButton)
    self:bindListener("ChangeButton", self.onChangeButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("JewelryImagePanel", self.onJewelryButton)
    self:bindListViewListener("JewelryListView", self.onSelectJewelryListView)

    self:bindListener("ItemImage1", self.onCostImage)
    self:bindListener("ItemImage2", self.onCostImage)
    self:bindListener("CostItemPanel", self.onCostImage)
    self:bindListener("OwnItemPanel", self.onCostImage)

    self:bindListener("OwnJinghuaPanel", self.onShowFloat)
    self:bindListener("CostJinghuaPanel", self.onShowFloat)
    self:bindListener("JinghuaImage", self.onShowFloat)
    self:bindListener("JinghuaImage2", self.onShowFloat)

    -- 左侧首饰列表
    self.unitJewelryPanel = self:retainCtrl("JewelryUnitPanel")
    self:bindTouchEndEventListener(self.unitJewelryPanel, self.onSelectJewelry)
    self.selectJewelryEffImage = self:retainCtrl("ChosenEffectImage", self.unitJewelryPanel)

    self.selectAtttibEffImage = self:retainCtrl("ChoosingEffect", "AttributeButton1")

    self.jewelry = nil
    self.transformInfo = nil

    self:initDlg()

    self:initJewelryListView()

    self:hookMsg("MSG_TRANSFORM_JEWELRY_COMPLETE")
end

function JewelryChangeDlg:onShowFloat(sender)
    RewardContainer:showCommonReward(sender, {CHS[5450185], CHS[5450185]})
end

function JewelryChangeDlg:initDlg()
    -- 超级女娲石消耗
        -- icon
    self:setImage("ItemImage1", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3000666])))

    self:setImage("ItemImage2", ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[3000666])))

    for i = 1, 5 do
        self:setLabelText("AttributeLabel1", "", "AttributeButton" .. i)
    end

        -- 转换次数
    local changeTimePanel = self:getControl("ChangeTimePanel", nil, "CostInfoPanel")
    self:setLabelText("ChangeTimeLabel", "", changeTimePanel)
    self:setLabelText("LimitLabel", "", changeTimePanel)

    -- 解除冷却
    self:setLabelText("Label1", "", "CDTimePanel")

    self:updateCost()

    local panel = self:getControl("JewelryAttributeInfoPanel")

    -- icon
    self:setImagePlist("EquipmentImage", ResMgr.ui.touming, panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
--    local color = InventoryMgr:getEquipmentNameColor(self.jewelry)
    self:setLabelText("JewelryNameLabel", "", panel, COLOR3.TEXT_DEFAULT)
end

function JewelryChangeDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[3000666], rect)
end

function JewelryChangeDlg:getJewelries()
    local jewelryRet = {}
    local inventory = InventoryMgr:getAllInventory()
    for _, v in pairs(inventory) do
        if EquipmentMgr:isJewelry(v) and v.req_level >= 110 and not InventoryMgr:isTimeLimitedItem(v) then
            table.insert(jewelryRet, v)
        end
    end

    return jewelryRet
end

function JewelryChangeDlg:initJewelryListView()
    local jewelryListView = self:resetListView("JewelryListView")
    local jewelries = self:getJewelries()
    for _, jewelry in pairs(jewelries) do
        local panel = self.unitJewelryPanel:clone()
        self:setUnitEquipPanel(jewelry, panel)
        jewelryListView:pushBackCustomItem(panel)
    end

    if not self.jewelry and #jewelries > 0 then
        self:onSelectJewelry(jewelryListView:getItems()[1])
    end

    self:setCtrlVisible("NoticePanel", #jewelries == 0)

    if #jewelries == 0 then
        self:setCtrlEnabled("ChangeButton", false)
    end

end

function JewelryChangeDlg:setUnitEquipPanel(equip, panel)
    panel.jewelry = equip

    -- 是否装备中
    if equip.pos <= 10 then
        if Me:queryBasicInt("equip_page") == 0 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    elseif equip.pos <= 20 then
        if Me:queryBasicInt("equip_page") == 1 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    else
        self:setImagePlist("TipImage", ResMgr.ui.touming, panel)
    end

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    --local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("JewelryNameLabel", equip.name, panel, COLOR3.TEXT_DEFAULT)

    -- lv
    self:setLabelText("JewelryLevelValueLabel", equip.req_level, panel)

    -- 部位
    if equip.equip_type == EQUIP.BALDRIC then
        self:setLabelText("JewelryTypeLabel", CHS[3002887], panel)
    elseif equip.equip_type == EQUIP.NECKLACE then
        self:setLabelText("JewelryTypeLabel", CHS[3002888], panel)
    elseif equip.equip_type == EQUIP.LEFT_WRIST or equip.equip_type == EQUIP.RIGHT_WRIST then
        self:setLabelText("JewelryTypeLabel", CHS[3002889], panel)
    end

    -- 冷却
    self:setCtrlVisible("CoolingTipImage", EquipmentMgr:isCoolTimed(equip), panel)

    panel:requestDoLayout()
end

-- 增加选择效果
function JewelryChangeDlg:addSelectEff(sender)
    self.selectJewelryEffImage:removeFromParent()
    sender:addChild(self.selectJewelryEffImage)
end


function JewelryChangeDlg:addSelectAttribEff(sender)
    self.selectAtttibEffImage:removeFromParent()
    sender:addChild(self.selectAtttibEffImage)
end


-- 点击某个装备
function JewelryChangeDlg:onSelectJewelry(sender, eventType)
    self.selectAtttibEffImage:removeFromParent()
    self:addSelectEff(sender)
    self.jewelry = sender.jewelry
    self:setJewelryInfo()
end

function JewelryChangeDlg:setJewelryInfo()
    self.transformInfo = nil
    if not self.jewelry then return end
    local panel = self:getControl("JewelryAttributeInfoPanel")

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(self.jewelry.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    local color = InventoryMgr:getEquipmentNameColor(self.jewelry)
    self:setLabelText("JewelryNameLabel", self.jewelry.name, panel, COLOR3.TEXT_DEFAULT)

    local totalAtt = {}

    local blueAtt, transformData = EquipmentMgr:getJewelryBule(self.jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})

    end
    --[[
    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(self.jewelry, self:getControl("ExChangeLabel"))
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end
    --]]

    for i = 1, 5 do
        local btn = self:getControl("AttributeButton" .. i)
        if totalAtt[i] then
            btn.transformInfo = {para = transformData[i], str = totalAtt[i].str}
            self:setLabelText("AttributeLabel1", totalAtt[i].str, btn, totalAtt[i].color)
        else
            self:setLabelText("AttributeLabel1", CHS[4010064], btn, COLOR3.GRAY) -- "首饰合成可获新属性"
            btn.transformInfo = nil
        end
    end

    -- 转换次数
    local changeTimePanel = self:getControl("ChangeTimePanel", nil, "CostInfoPanel")
    self:setCtrlVisible("ChangeTimeLabel", true, changeTimePanel)
    self:setCtrlVisible("LimitLabel", true, changeTimePanel)
    self.jewelry.transform_num = self.jewelry.transform_num or 0
    if self.jewelry.transform_num < Const.JEWELRY_TRANSFORM_MAX_COUNT then
        self:setLabelText("ChangeTimeLabel", string.format(CHS[4010065], self.jewelry.transform_num or 0), changeTimePanel)
        self:setLabelText("LimitLabel", "", changeTimePanel)
    else
        self:setLabelText("ChangeTimeLabel", "", changeTimePanel)
        self:setLabelText("LimitLabel", CHS[4101086], changeTimePanel)
    end

    -- 解除冷却
    if self.jewelry.transform_num < Const.JEWELRY_TRANSFORM_MAX_COUNT and self.jewelry.transform_cool_ti and self.jewelry.transform_cool_ti ~= 0 and self.jewelry.transform_cool_ti >= gf:getServerTime() then
        self:setLabelText("Label1", string.format(CHS[4010066], os.date("%Y-%m-%d %H:%M", self.jewelry.transform_cool_ti)), "CDTimePanel")
    else
        self:setLabelText("Label1", "", "CDTimePanel")
    end

    self:setCtrlEnabled("ChangeButton", not EquipmentMgr:isCoolTimed(self.jewelry))

    if self.jewelry.transform_num >= Const.JEWELRY_TRANSFORM_MAX_COUNT then
        self:setCtrlEnabled("ChangeButton", false)
    end

    self:setCtrlVisible("ChangeLabel1", not EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("ChangeLabel2", not EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("CDLabel1_0", EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("CDLabel2_0", EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")

    -- 消耗信息
    self:updateCost(self.jewelry)
end

function JewelryChangeDlg:updateCost(equip)
    -- 消耗女娲石
    local nvwaPanel = self:getControl("ItemNumberPanel")
    self:setNumImgForPanel("CostItemPanel", ART_FONT_COLOR.NORMAL_TEXT, NVWA_COST, false, LOCATE_POSITION.MID, 19, nvwaPanel)

    local havedCount = InventoryMgr:getAmountByName(CHS[3000666])
    if havedCount < NVWA_COST then
        self:setNumImgForPanel("OwnItemPanel", ART_FONT_COLOR.RED, havedCount, false, LOCATE_POSITION.MID, 19, nvwaPanel)
    else
        self:setNumImgForPanel("OwnItemPanel", ART_FONT_COLOR.NORMAL_TEXT, havedCount, false, LOCATE_POSITION.MID, 19, nvwaPanel)
    end


    -- 精华
    if not equip then
        self:setNumImgForPanel("OwnJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryBasicInt("jewelry_essence"), false, LOCATE_POSITION.MID, 19, jinghuaPanel)
        self:setNumImgForPanel("CostJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, 0, false, LOCATE_POSITION.MID, 19, jinghuaPanel)
        return
    end
    local jinghuaPanel = self:getControl("JinghuaNumberPanel")
    self:setNumImgForPanel("CostJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, JINGHUA_COST[equip.transform_num + 1], false, LOCATE_POSITION.MID, 19, jinghuaPanel)


    if Me:queryBasicInt("jewelry_essence") < JINGHUA_COST[equip.transform_num + 1] then
        self:setNumImgForPanel("OwnJinghuaPanel", ART_FONT_COLOR.RED, Me:queryBasicInt("jewelry_essence"), false, LOCATE_POSITION.MID, 19, jinghuaPanel)
    else
        self:setNumImgForPanel("OwnJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, Me:queryBasicInt("jewelry_essence"), false, LOCATE_POSITION.MID, 19, jinghuaPanel)
    end
end

function JewelryChangeDlg:onAttributeButton(sender, eventType)
    self:addSelectAttribEff(sender)
    self.transformInfo = sender.transformInfo

    if not self.transformInfo and self.jewelry then
        gf:confirm(CHS[4101087], function ()
            -- body
            local dlg = DlgMgr:openDlg("JewelryUpgradeDlg")
            dlg:setJewelry(self.jewelry)
        end)
    end
end

function JewelryChangeDlg:onChangeButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:queryBasicInt("level") < 110 then
        gf:ShowSmallTips(CHS[4100571])
        return
    end

    if not self.jewelry then
        gf:ShowSmallTips(CHS[4010067])
        return
    end

    local item = InventoryMgr:getItemByPos(self.jewelry.pos)
    if not item or not EquipmentMgr:isJewelry(item) then
        gf:ShowSmallTips(CHS[4200586])

        self.jewelry = nil
        self:initDlg()
        self:initJewelryListView()
        return
    end

    if self.jewelry.transform_num >= Const.JEWELRY_TRANSFORM_MAX_COUNT then
        gf:ShowSmallTips(CHS[4010073])
        return
    end

   -- 策划要求，第二套装备未生效时，也可以穿戴（第二装备对应的第一装备没有位置，也会生效！！！）
  if Me:isInCombat() and self.jewelry.pos < 41 then

        if self.jewelry.pos < 10 then
            -- 第一套肯定生效
            gf:ShowSmallTips(CHS[4010068]) -- 战斗中不可转换已穿戴首饰的属性
            return
        end

        -- 操作第二天装备，需要看看对应的第一套装备有没有，没有也是不可以炒作的
        local oneJewelryPos = SECOND_TO_ONE_JEWELEY[self.jewelry.pos]
        if oneJewelryPos and not InventoryMgr:getItemByPos(oneJewelryPos) then
            gf:ShowSmallTips(CHS[4010068]) -- 战斗中不可转换已穿戴首饰的属性


            return
        end
    end

    if EquipmentMgr:isCoolTimed(self.jewelry) then
        gf:ShowSmallTips(CHS[4010069]) -- 当前首饰处在转换冷却期间，无法进行属性转换。
        return
    end

    if not self.transformInfo then
        gf:ShowSmallTips(CHS[4010070]) -- 请先选择属性。
        return
    end

    if Me:queryBasicInt("jewelry_essence") < JINGHUA_COST[self.jewelry.transform_num + 1] then
        gf:ShowSmallTips(CHS[4010071])
        return
    end

    local havedCount = InventoryMgr:getAmountByName(CHS[3000666])
    if havedCount < NVWA_COST then
        gf:ShowSmallTips(CHS[4010072])
        return
    end

    local attStr = string.match(self.transformInfo.str, "(.+)/")
    local tis = string.format(CHS[4010074], attStr)
    local str, day = gf:converToLimitedTimeDay(self.jewelry.gift)
    if not InventoryMgr:isLimitedItemForever(self.jewelry) and day <= Const.LIMIT_TIPS_DAY then
        tis = tis .. CHS[4101088]
    end

    gf:confirm(tis, function()
            EquipmentMgr:jewelryTransform(self.jewelry.pos, self.transformInfo.para)
    end)


end

function JewelryChangeDlg:onJewelryButton(sender, eventType)
    if not self.jewelry then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showJewelryFloatDlg(self.jewelry, rect, true)
end

function JewelryChangeDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200604], isScrollToDef = true}
    DlgMgr:openDlgEx("JewerlyRuleNewDlg", data)
end

function JewelryChangeDlg:onSelectJewelryListView(sender, eventType)
end

function JewelryChangeDlg:MSG_TRANSFORM_JEWELRY_COMPLETE(data)
    local jewelryListView = self:getControl("JewelryListView")

    for _, panel in pairs(jewelryListView:getItems()) do
        if panel.jewelry.pos == data.pos then
            local newJewelry = InventoryMgr:getItemByPos(data.pos)

            DlgMgr:openDlgEx("JewelryShowDlg", {newJewelry, panel.jewelry})

            self:setUnitEquipPanel(newJewelry, panel)
            self:onSelectJewelry(panel)
        end
    end
end


return JewelryChangeDlg
