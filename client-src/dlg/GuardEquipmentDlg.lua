-- GuardEquipmentDlg.lua
-- Created by liuhb Feb/02/2015
-- 守护装备改造

local RadioGroup = require("ctrl/RadioGroup")

local maxLevel = 12

-- TAB与装备的对应表
local TAB_LABEL_MAP = {
    [GuardMgr:getEquipType(1)] = "WeaponUpgradeLevelLabel",
    [GuardMgr:getEquipType(3)] = "ClothesUpgradeLevelLabel",
    [GuardMgr:getEquipType(2)] = "HatUpgradeLevelLabel",
    [GuardMgr:getEquipType(4)] = "ShoesUpgradeLevelLabel",
}

-- TAB与装备的对应表
local TAB_SELECT_MAP = {
    [GuardMgr:getEquipType(1)] = 1,
    [GuardMgr:getEquipType(3)] = 3,
    [GuardMgr:getEquipType(2)] = 2,
    [GuardMgr:getEquipType(4)] = 4,
}

-- 单选框与装备类型的对应表
local TAB_BTN_MAP = {
    ["WeaponCheckBox"] = GuardMgr:getEquipType(1),
    ["ClothesCheckBox"] = GuardMgr:getEquipType(3),
    ["HatCheckBox"] = GuardMgr:getEquipType(2),
    ["ShoesCheckBox"] = GuardMgr:getEquipType(4),
}

-- 当前装备的最高等级
local EQUIP_MAX_LEV = GuardMgr:getEquipMaxLev()

local GuardEquipmentDlg = Singleton("GuardEquipmentDlg", Dialog)

function GuardEquipmentDlg:init()
    self:bindListener("UpgradeButton", self.onEquipmentUpgradeButton)
    self:bindListener("WeaponCheckBox", self.onEquipSelector)
    self:bindListener("ClothesCheckBox", self.onEquipSelector)
    self:bindListener("HatCheckBox", self.onEquipSelector)
    self:bindListener("ShoesCheckBox", self.onEquipSelector)
   
    self:bindListener("Upgrade5Button", self.onEquipmentUpgrade5Button)
    self:bindListener("ReturnButton", self.OnSelectGuard)

    -- 初始化界面上的控件
    self:cleanAllControlUp()
    self.isOpened = false
    local guard = DlgMgr:sendMsg("GuardListChildDlg", "getCurrentGuard")
    if nil ~= guard then
        self.guardId = guard:queryBasicInt("id")
        self:setGuardEquipmentInfo(guard:queryBasicInt("id"))
    else
        local ctrl = self:getControl("UpgradeButton")
        ctrl:setTouchEnabled(false)
        gf:grayImageView(ctrl)   
        ctrl = self:getControl("Upgrade5Button")
        ctrl:setTouchEnabled(false)
        gf:grayImageView(ctrl)  
    end

    self:hookMsg("MSG_GUARD_UPDATE_EQUIP")

    -- 刷新道具数量
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_DIALOG_OK")
end

-- 初值化当前守护的装备  isBarAction:是否要有进度条动画
function GuardEquipmentDlg:initSelectGuardEquip(guard, isBarAction)
    
    for i = 1, 4 do
        local equipmentPanel = self:getControl(string.format("EquipPanel_%d", i))
        local equipType = GuardMgr:getEquipType(i)
        
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.selectImg  then
                    self.selectImg:setVisible(false)
                end
                                
                local selectImg = self:getControl("ChosenEffectImage", Const.UIImage, equipmentPanel)
                self.selectImg = selectImg
                selectImg:setVisible(true)            
                self:setGuardEquip(guard, equipType)
            end
        end
              
        local selectImg = self:getControl("ChosenEffectImage", Const.UIImage, equipmentPanel)      
        if i == TAB_SELECT_MAP[self.equipType] then  
            self.selectImg = selectImg
            selectImg:setVisible(true)
        else
            selectImg:setVisible(false)    
        end
        
        self:initEquipCell(guard, equipType, equipmentPanel)
        equipmentPanel:addTouchEventListener(listener)     
    end
    
    self:setGuardEquip(guard, self.equipType, isBarAction)  
end

function GuardEquipmentDlg:initSleectGuardInfo(guard)
    local guardPanel= self:getControl("GuardPanel")
    local imgPath = ResMgr:getSmallPortrait(guard:queryBasicInt("icon"))
    self:setImage("GuardImage", imgPath, guardPanel)
    self:setItemImageSize("GuardImage", guardPanel)
    
    -- 守护名称
    local name = guard:queryBasic("name")
    self:setLabelText("NameLabel", name, guardPanel)
    
    -- 添加守护等级
    local level ="LV." .. guard:queryBasicInt("level")
    self:setLabelText("LevelLabel", level, guardPanel)
    
    -- 相性
    local polar = guard:queryBasicInt("polar")
    self:setLabelText("LevelValueLabel", gf:getPolar(polar), guardPanel)
    
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           if  self.isOpened then
                self:OnSelectGuard()               
           end    
        end
    end
    
    guardPanel:addTouchEventListener(listener)
    
    -- 是否参战
    local combat_guard = guard:queryInt("combat_guard")
    
    if combat_guard == 1 then
        self:setCtrlVisible("StatusImage", true, guardPanel)
    else
        self:setCtrlVisible("StatusImage", false, guardPanel)    
    end
end

function GuardEquipmentDlg:initEquipCell(guard, equipType, cell)
    -- 获取守护的ID
    local guardId = guard:queryBasicInt("id")
    local equip = GuardMgr:getGuardEquipsById(guardId, equipType)
    if nil == equip then return end
    

    -- 获取当前装备的图标
    local equipIconPath = ResMgr:getItemIconPath(equip.icon)

    -- 设置装备的图片
    self:setImage("Image", equipIconPath, cell)
    self:setItemImageSize("Image", cell)

    -- 设置装备名称
    self:setLabelText("NameLabel", equip.name, cell)
    
    -- 星级
    local equipStr = string.format(CHS[5000045], equip.level, equip.star)
    self:setLabelText("LevelLabel", equipStr, cell)
    
end

function GuardEquipmentDlg:OnSelectGuard()
    self:getControl("GuardEquipListPanel", Const.UIPanel):setVisible(false)
    local dlg = DlgMgr.dlgs["GuardListChildDlg"]
    
    if dlg then
        dlg:setVisible(true)
    end 
    
    self.isOpened = false   
end

-- 初始化界面上的所有控件
function GuardEquipmentDlg:cleanAllControlUp()
    --self:setAllTabLabel()
    self:setLabelText("EquipmentNameLabel", "")
    self:getControl("EquipmentImage"):setVisible(false)
    local oldCtrl = self:getControl("OldEquipmentPanel")
    local equip = {name = "", icon = 0, level = 0, star = 0, attr = {},
        addition = {}, grade = 0, complete = 0, comCount = 0,
        stone_cost = 0, money_cost = 0}
    self:setEquipPanel(equip, oldCtrl)

    local newCtrl = self:getControl("NewEquipmentPanel")
    self:setEquipPanel(equip, newCtrl)

    -- 设置材料图标
    local itemName = CHS[5000046]
    self:setItem(itemName, 0)    
    --local meCashStr, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    --self:setNumImgForPanel("OwnCashPanel", fontColor, meCashStr, false, LOCATE_POSITION.CENTER, 23)
    --self:setNumImgForPanel("CostCashPanel", ART_FONT_COLOR.DEFAULT, "0", false, LOCATE_POSITION.CENTER, 23)
    self:getControl("OwnCashPanel", Const.UIPanel):removeAllChildren()
    self:getControl("CostCashPanel", Const.UIPanel):removeAllChildren()
    self:setLabelText("OneClickEvolveValueLabel", 0)
    
    self:getControl("CostItemLabel"):setString(itemName)
end

-- 改造按钮响应事件
function GuardEquipmentDlg:onEquipmentUpgradeButton(sender, eventType)
    if nil == self.guardId then return end
    if self.isUpgradeCD then 
        return
    end
    self.isUpgradeCD = true
    
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    if equip.level >= 12 then
        gf:ShowSmallTips(CHS[3002797])
        self.isUpgradeCD = false
        return
    end
    
    -- 获取守护的装备属性
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    if nil == equip then return end
    
     -- 普通改造
    if not GuardMgr:upEquip(self.guardId, self.equipType, false, equip.stone_cost) then
        self.isUpgradeCD = false
    end

end

-- 改造
function GuardEquipmentDlg:onEquipmentUpgrade5Button()
    if nil == self.guardId then return end
    if self.isUpgradeCD then 
        return
    end
    self.isUpgradeCD = true
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    if equip.level >= 12 then
        gf:ShowSmallTips(CHS[3002797])
        self.isUpgradeCD = false
        return
    end
    
    -- 获取守护的装备属性
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    if nil == equip then return end
    
    if not GuardMgr:upEquip(self.guardId, self.equipType, true, equip.stone_cost) then
        self.isUpgradeCD = false
    end
end

-- 刷新守护装备界面
function GuardEquipmentDlg:setEquipmentPanel(guardId, isBarAction)
    self:setGuardEquipmentInfo(guardId, isBarAction)
end

-- 设置装备界面的信息
function GuardEquipmentDlg:setGuardEquipmentInfo(guardId)
    self:getControl("GuardEquipListPanel"):setVisible(true)  
    local dlg = DlgMgr.dlgs["GuardListChildDlg"]

    if dlg then
        dlg:setVisible(false)
    end
   
    if nil == guardId then return end
    local ctrl = self:getControl("UpgradeButton")
    ctrl:setTouchEnabled(true)
    gf:resetImageView(ctrl)   
    ctrl = self:getControl("Upgrade5Button")
    ctrl:setTouchEnabled(true)
    gf:resetImageView(ctrl)   
    
    local guard = GuardMgr:getGuard(guardId)
    if nil == self.equipType then
        self.equipType = GuardMgr:getEquipType(1)
    end

    self:initSelectGuardEquip(guard)
    self:initSleectGuardInfo(guard)
    
    if self.isOpened == false then
        self:doAction()
    else
        if self.selectImg then
            self.selectImg:setVisible(false)    
        end    
    end
    
    self.isOpened = true
end

-- 打开守护动作
function GuardEquipmentDlg:doAction()
    local panel =  self:getControl("GuardPanel")
    
    for i = 1, 4 do
        local equipmentPanel = self:getControl(string.format("EquipPanel_%d", i))
        local x, y = equipmentPanel:getPosition()
        local moveto = cc.MoveTo:create(0.3, cc.p(x, y))
        equipmentPanel:setPositionY(panel:getPositionY() - panel:getContentSize().height)
        local line = self:getControl("ConnectImage", Const.UIImage)
        line:setOpacity(0)
        
        if i == 4 then
            local func = cc.CallFunc:create(function()  local fadeIn = cc.FadeIn:create(0.3)
                line:runAction(fadeIn) end)
                
            local action = cc.Sequence:create(moveto, func)
            equipmentPanel:runAction(action)
        else    
            equipmentPanel:runAction(moveto)
        end
    end   
       
end

-- 设置装备面板的信息
function GuardEquipmentDlg:setGuardEquip(guard, equipType, isBarAction)
    self:cleanAllControlUp()
    if nil == guard then return end
    
    -- 获取守护的ID
    local guardId = guard:queryBasicInt("id")

    -- 设置界面数据
    self.equipType = equipType
    self.guardId = guardId
    self:cleanAllControlUp()
    
    -- 获取守护的装备属性
    local equip = GuardMgr:getGuardEquipsById(guardId, equipType)
    if nil == equip then return end
    
    
    -- 获取当前装备的图标
    local equipIconPath = ResMgr:getItemIconPath(equip.icon)

    -- 设置装备的图片
    self:setImage("EquipmentImage", equipIconPath)
    self:setItemImageSize("EquipmentImage")
    self:getControl("EquipmentImage"):setVisible(true)

    -- 设置装备名称
    self:setLabelText("EquipmentNameLabel", equip.name)
    
    

    -- 设置标签的装备等级
   -- local equipStr = string.format(CHS[5000045], equip.level, equip.star)
    --self:setLabelText(TAB_LABEL_MAP[equipType], equipStr)

    -- 获取左边旧装备面板
    local oldCtrl = self:getControl("OldEquipmentPanel")
    self:setEquipPanel(equip, oldCtrl)

    -- 设置材料图标
    local itemName = ""
    if GuardMgr:getEquipType(1) == equipType then
        itemName = CHS[5000046]
    else
        itemName = CHS[5000049]
    end
    self:setItem(itemName, equip.stone_cost)

    -- 设置完成度
    self:setComPrecent(equip.complete, equip.comCount, isBarAction, equip.level)

    -- 设置金钱
    local meCashStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnCashPanel", meFontColor, meCashStr, false, LOCATE_POSITION.CENTER, 23)
    local costCashStr, costFontColor = gf:getArtFontMoneyDesc(equip.money_cost)
    self:setNumImgForPanel("CostCashPanel", costFontColor, costCashStr, false, LOCATE_POSITION.CENTER, 23)

    -- 设置改造次数
    local oneClickUpTime = math.max(equip.comCount - equip.complete, 0)
    self:setLabelText("OneClickEvolveValueLabel", oneClickUpTime)

    -- 获取下一等级的装备属性
    local nextEquip = GuardMgr:getNextGuardEquipsById(guardId, equipType)
    if nil == nextEquip then return end

    local newCtrl = self:getControl("NewEquipmentPanel")
    self:setEquipPanel(nextEquip, newCtrl, true)
end

-- 设置装备面板的信息
function GuardEquipmentDlg:setEquipPanel(equip, oldCtrl, isNext)
    if nil == equip then return end

    -- 设置装备的改造等级
    local level = math.min(equip.level, EQUIP_MAX_LEV)
    local equipStr = string.format(CHS[5000045], level, equip.star)
    if equip.level >= EQUIP_MAX_LEV and equip.star > 0 then
        equipStr = string.format(CHS[5000045], level, equip.star - 1)
        self:setLabelText("UpgradeLevelLabel", equipStr, oldCtrl)
    else
        self:setLabelText("UpgradeLevelLabel", equipStr, oldCtrl)
    end

    -- 设置改造属性
    if equip.level >= EQUIP_MAX_LEV and equip.star > 0 then
        -- 如果等级大于等于最高等级
        equip.star = 0 -- 超过最大等级 星星为0个
        local attr = equip.attr
        local attrStr = ""
        local extStr = ""
        for k, v in pairs(attr) do
            -- 获取显示名称
            local keyStr = GuardMgr:getNameByAttrKey(k)
            if "" == attrStr then
                attrStr = string.format("%s", keyStr)
            else
                attrStr = string.format("%s\n%s", attrStr, keyStr)
            end

            if "" == extStr then
                extStr = CHS[5000047]
            else
                extStr = string.format("%s\n%s", extStr, CHS[5000047])
            end
        end

        self:setLabelText("EquipmentAttributeNameLabel1", attrStr, oldCtrl)
        self:setLabelText("EquipmentAttributeValueLabel1", extStr, oldCtrl, COLOR3.RED)
        self:setLabelText("UpgradeRateLabel1", "", oldCtrl)
        
        -- 设置装备评分
        self:setLabelText("EquipmentAttributeValueLabel3", CHS[5000047], oldCtrl, COLOR3.RED)
    else
        -- 如果等级小于最高等级
        local attr = equip.attr
        local add = equip.addition
        local attrStr = ""
        local addStr = ""
        local extStr = ""
        for k, v in pairs(attr) do
            -- 获取显示名称
            -- 如果是下一级，则返回两个值，第一个返回值为
            local v1, v2 = self:getAttriStr(attr[k], add[k], isNext)
            local keyStr = GuardMgr:getNameByAttrKey(k)
            if "" == attrStr then
                attrStr = string.format("%s %s", keyStr, v1)
            else
                attrStr = string.format("%s\n%s %s", attrStr, keyStr, v1)
            end
            -- 拼接加成属性
            
            if nil ~= v2 then
                if "" == extStr then
                    extStr = v2
                else
                    extStr = string.format("%s\n%s", extStr, v2)
                end
            else
                extStr = extStr.."\n \n"
            end
        end

        self:setLabelText("EquipmentAttributeNameLabel1", attrStr, oldCtrl)
        self:setLabelText("UpgradeRateLabel1", extStr, oldCtrl, COLOR3.GREEN)
        self:setLabelText("EquipmentAttributeValueLabel1", "", oldCtrl)
        
        -- 设置装备评分
        self:setLabelText("EquipmentAttributeValueLabel3", equip.grade, oldCtrl, COLOR3.GREEN)
    end


    self:setEquipStartLev(equip.star, oldCtrl, isNext)    
    oldCtrl:requestDoLayout()
end

-- TAB标签的响应事件
function GuardEquipmentDlg:onEquipSelector(sender, eventType)
    if nil == self.guardId then return end

    local name = sender:getName()
    local guard = GuardMgr:getGuard(self.guardId)
    self:setGuardEquip(guard, TAB_BTN_MAP[name])
end

-- 获取描述信息字符串
function GuardEquipmentDlg:getAttriStr(basic, percent, isGreen)
    local attrStr = tostring(basic)
    if not (nil == percent or 0 == percent) then
        if nil == isGreen or (not isGreen) then
            attrStr = attrStr .. " +" .. percent .. "%"
        else
            return attrStr, "+" .. percent .. "%"
        end
    end

    return attrStr
end

-- 设置所有的TAB标签
function GuardEquipmentDlg:setAllTabLabel()
    for k, v in pairs(TAB_LABEL_MAP) do
        local equip = GuardMgr:getGuardEquipsById(self.guardId, k)
        local equipStr = ""
        if nil == equip then
            equipStr = string.format(CHS[5000045], 0, 0)
        else
            equipStr = string.format(CHS[5000045], equip.level, equip.star)
        end

        -- 设置标签的装备等级
        self:setLabelText(TAB_LABEL_MAP[k], equipStr)
    end
end

-- 设置装备的星级
function GuardEquipmentDlg:setEquipStartLev(equipStarLev, panelCtrl, isNext)
    local lev = equipStarLev
    if isNext then
        lev = lev - 1
    end

    for i = 1, 9 do
        local str = "StarImage" .. i
        local equipStr = nil
        if i <= lev then
            equipStr = ResMgr.ui.guard_equip_lev_star_1
        elseif i == lev + 1 and isNext then
            equipStr = ResMgr.ui.guard_equip_lev_star_1
        elseif i == lev + 1 and not isNext then
            equipStr = ResMgr.ui.guard_equip_lev_star_2
        elseif i > lev + 1 then
            equipStr = ResMgr.ui.guard_equip_lev_star_2
        end

        self:setImage(str, equipStr, panelCtrl)
    end
end

-- 设置消耗材料的信息
function GuardEquipmentDlg:setItem(itemName, stoneCost)
    local upItemIconPath = InventoryMgr:getIconFileByName(itemName)
    local upItemCount= InventoryMgr:getAmountByName(itemName)
    self:setImage("CostImage", upItemIconPath)
    self:setItemImageSize("CostImage", upItemIconPath)

    if upItemCount > 999 then upItemCount = "*" end
    
    local costTips = '/' .. stoneCost
    if tonumber(upItemCount) and stoneCost > upItemCount then
        self:setLabelText("CostNumberLabel",  costTips, nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("OwnNumberLabel", upItemCount , nil, COLOR3.RED)
    else
        self:setLabelText("CostNumberLabel",  costTips, nil, COLOR3.TEXT_DEFAULT)
        self:setLabelText("OwnNumberLabel", upItemCount , nil, COLOR3.TEXT_DEFAULT)
    end
    
    self:getControl("CostItemLabel"):setString(itemName)
end

-- 设置完成进度信息
function GuardEquipmentDlg:setComPrecent(complete, comCount, isAction, level)
    local pcStr = string.format("%d/%d", complete, comCount)
    
    if isAction then
        if complete == 0 then
            self:setLabelText("ProgressLabel", string.format("%d/%d", self.lastCount or comCount, self.lastCount or comCount), COLOR3.TEXT_DEFAULT)
        end
    end
    
    local function setBarLabel()
        if  level and level == maxLevel then
            self:setLabelText("ProgressLabel", CHS[3002798], nil, COLOR3.RED)
            self:setProgressBar("EquipmentProgressBar", 1, 1)
        else
            self:setLabelText("ProgressLabel", pcStr, nil, COLOR3.TEXT_DEFAULT)
            self:setProgressBar("EquipmentProgressBar", complete, comCount)
        end   
        
        self.isUpgradeCD = false
        if comCount ~= 0 then self.lastCount = comCount end
    end
    self:setProgressBar("EquipmentProgressBar", complete, comCount, nil, nil, isAction, setBarLabel)
end

function GuardEquipmentDlg:MSG_GUARD_UPDATE_EQUIP(data)
    if nil ~= self.guardId then
        local guard = GuardMgr:getGuard(self.guardId)
        self:initSelectGuardEquip(guard, self.isUpgradeCD)
        --self:setGuardEquip(guard, self.equipType)
    end
end

function GuardEquipmentDlg:MSG_INVENTORY(data)
    if not self.guardId or not self.equipType then
        return
    end
    
    -- 获取守护的装备属性
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    if nil == equip then return end

    -- 设置材料图标
    local itemName = ""
    if GuardMgr:getEquipType(1) == self.equipType then
        itemName = CHS[5000046]
    else
        itemName = CHS[5000049]
    end

    self:setItem(itemName, equip.stone_cost)
end

function GuardEquipmentDlg:MSG_UPDATE(data)
    -- 设置金钱     = equipType
    if not self.guardId and not self.equipType then return end
    local equip = GuardMgr:getGuardEquipsById(self.guardId, self.equipType)
    local meCashStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnCashPanel", meFontColor, meCashStr, false, LOCATE_POSITION.CENTER, 23)
    local costCashStr, costFontColor = gf:getArtFontMoneyDesc(equip.money_cost)
    self:setNumImgForPanel("CostCashPanel", costFontColor, costCashStr, false, LOCATE_POSITION.CENTER, 23)
end

function GuardEquipmentDlg:MSG_GENERAL_NOTIFY(data)
    if data.notify == NOTIFY.WHETHER_EXCHAGE_CASH then
        self.isUpgradeCD = false
    end
end

function GuardEquipmentDlg:MSG_DIALOG_OK()
    self.isUpgradeCD = false
end

function GuardEquipmentDlg:cleanup()
	self.selectImg = nil
	self.equipType = nil
end

return GuardEquipmentDlg
