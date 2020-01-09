-- MarketSellEquipmentDlg.lua
-- Created by Aug/20/2015
-- 装备摆摊

local MarketSellBasicDlg = require('dlg/MarketSellBasicDlg')
local MarketSellEquipmentDlg = Singleton("MarketSellEquipmentDlg", MarketSellBasicDlg)
local EquipmentAtt = require(ResMgr:getCfgPath("EquipmentAttribute.lua"))

-- 属性条之间间隔
local MARGIN = 1

-- 第一条属性上方间隔
local FIRST_MARGIN = 5

-- 属性条左边间隔
local LEFT_MARGIN = 8

function MarketSellEquipmentDlg:init()
    self:initBaisc()

    self.attribPanel = self:retainCtrl("BaseAttributePanel")
end

function MarketSellEquipmentDlg:setEquipInfo(equip, type, goodId) 
    self.goodId = goodId
    self:initPublicInfo(equip, type)
  
    -- 设置等级
    local iconPanel = self:getControl("IconPanel")
    if nil == equip.req_level or 0 == equip.req_level then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
    else
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end
    
    -- 设置图标
    local iconPath = ResMgr:getItemIconPath(equip.icon)
    self:setImage("IconImage", iconPath)
    self:setItemImageSize("IconImage")
    
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then 
            if self.VIEW_TYPE.PRE_SELL == type then
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                InventoryMgr:showItemByItemData(equip, rect)
            else
                local item = MarketMgr:getSelectGoodInfo()
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                self:requireMarketGoodCard(goodId.."|"..(item.endTime or ""), MARKET_CARD_TYPE.FLOAT_DLG, rect, false)    
            end
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)

    -- 设置物品名称
    self:setLabelText("NameLabel", equip.name)
    
    -- 设置属性界面    
    local allAttribTab = {}
    
    if equip.rebuild_level ~= 0 and equip["degree_32"] then
        local degree = math.floor(equip["degree_32"] / 100) *100 / 1000000

        local completionStr
        if degree == 0 then
            completionStr = ""
        else
            completionStr = string.format("(+%0.4f%%)", degree)
        end
        local str = string.format(CHS[3003084], equip.rebuild_level, completionStr)
        table.insert(allAttribTab, {str = str, color = COLOR3.EQUIP_BLUE})
    end
    
    local color, greenTab, yellowTab, pinkTab, blueTab = InventoryMgr:getEquipmentNameColor(equip)
    local blueAttTab = self:getColorAtt(blueTab, "blue", equip)
    local pinkAttTab = self:getColorAtt(pinkTab, "pink", equip)
    local yellowAttTab = self:getColorAtt(yellowTab, "yellow", equip)
    local greenAttTab = self:getColorAtt(greenTab, "green", equip)
    local gongmingTab = EquipmentMgr:getGongmingValueAndColor(equip)

    for _,v in pairs(blueAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(pinkAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(yellowAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(greenAttTab) do
        table.insert(allAttribTab, v)
    end

    for _,v in pairs(gongmingTab) do
        table.insert(allAttribTab, v)
    end

    local count = #allAttribTab
    local scrollView = self:getControl("ScrollView")
    local srcroViewSz = scrollView:getContentSize()
    scrollView:removeAllChildren()
    local itemHeight = self.attribPanel:getContentSize().height + MARGIN
    local innerHeight = FIRST_MARGIN + itemHeight * count
    scrollView:setInnerContainerSize({width = srcroViewSz.width, height = innerHeight})

    for i = count, 1, -1 do
        local desPanel = self.attribPanel:clone()
        self:setColorText(allAttribTab[i].str, desPanel, nil, nil, nil, allAttribTab[i].color, 17, true)
        scrollView:addChild(desPanel)
        desPanel:setPosition(LEFT_MARGIN, itemHeight * (count - i))
    end

    scrollView:getInnerContainer():setPositionY(srcroViewSz.height - innerHeight)
    self:setCtrlEnabled("ScrollView", srcroViewSz.height - innerHeight < 0)
end

-- 获取装备改造属性
function MarketSellEquipmentDlg:getColorAtt(attTab, colorStr, equip)
    local destTab = {}
    local color
    local maxValue
    local colorType = 0         -- 蓝、粉、金   需要显示强化完成度
    if colorStr == "blue" then
        color = COLOR3.EQUIP_BLUE
        colorType = 1
    elseif colorStr == "pink" then
        color = COLOR3.EQUIP_PINK
        colorType = 2
    elseif colorStr == "yellow" then
        color = COLOR3.YELLOW
        colorType = 3
    elseif colorStr == "green" then        
        color = COLOR3.EQUIP_GREEN
    end
    
    
    for i, att in pairs(attTab) do
        local bai = ""
        if EquipmentAtt[CHS[3003085]][att.field] then bai = "%" end

        if EquipmentAtt[att.field] ~= nil then
            local str = EquipmentAtt[att.field] .. " " .. att.value .. bai
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, att.field) or ""
            if colorStr == "green" and att.dark == 1 then
                -- 绿属性最大值和其他不一样
                local min , max = EquipmentMgr:getSuitMinAndMax(equip, att.field)
                maxValue = max or maxValue
                -- 绿属性未激活未灰色
                if equip.suit_enabled == 0 then
                    color = COLOR3.EQUIP_BLACK
                end                
            end            
            local completion = EquipmentMgr:getAttribCompletion(equip, att.field, colorType)
            if colorType ~= 0 and completion and completion ~= 0 then
                str = str .. "/" .. maxValue .. bai .. " #R(+" .. completion * 0.01 .. "%)#n"
                table.insert(destTab, {str = str, color = color, basic = 1})
            else
                str = str .. "/" .. maxValue .. bai            
                table.insert(destTab, {str = str, color = color})
            end
        end
    end

    return destTab
end


return MarketSellEquipmentDlg
