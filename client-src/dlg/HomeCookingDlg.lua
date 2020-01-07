-- HomeCookingDlg.lua
-- Created by sujl, Aug/12/2017
-- 烹饪界面

local HomeCookingDlg = Singleton("HomeCookingDlg", Dialog)
local HomeCookingFormula = require(ResMgr:getCfgPath("HomeCookingFormula"))

local NAME2BK = {
    [CHS[2000398]] = "BKImage1",
    [CHS[2000399]] = "BKImage2",
}

local NUM_PER_COOKING_ONE_TIMES = 10
local ART_FONT_SIZE = 19

function HomeCookingDlg:init(data)
    self:bindListener("CookButton", self.onCookButton)
    self:bindListener("AddButton", self.onAddDurButton, self:getControl("DurablePanel", nil, "HearthPanel"))
    self:bindListener("PlusButton", self.onPlusButton, "NumPanel")
    self:bindListener("MinusButton", self.onMinusButton, "NumPanel")
    self:bindListener("FoodIconPanel", self.onClickFood)
    self:bindListener("MaterialIconPanel1", self.onClickFoodMat)
    self:bindListener("MaterialIconPanel2", self.onClickFoodMat)
    self:bindListener("MaterialIconPanel3", self.onClickFoodMat)

    self:bindNumInput("NumPanel")

    self.furnitureId = data[1]
    self.furnitureX, self.furnitureY = data[2], data[3]
    self.curCookingNum = 1
    self.curCooking = nil

    self:MSG_HOUSE_DATA()

    self.selectImg = ccui.ImageView:create(ResMgr.ui.bag_item_select_img, ccui.TextureResType.plistType)
    self.selectImg:setAnchorPoint({0, 0})
    self.selectImg:setPosition(-3, -2)
    self.selectImg:retain()

    for i = 1, #HomeCookingFormula do
        self:initCookieTypes(i, true)
    end

    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_INVENTORY")
end

function HomeCookingDlg:cleanup()
    self:releaseCloneCtrl("selectImg")
end

-- 初始化大类型下的子类型
function HomeCookingDlg:initCookieTypes(index, bindEvent)
    local info = HomeCookingFormula[index]
    if not info or not info.types or #info.types <= 0 then return end
    local types = info.types
    local itemPanel = self:getControl(string.format("ItemPanel%d", index), nil, "ItemListView")
    self:setLabelText("NameLabel", info.name, itemPanel)

    local child
    for i = 1, #types do
        child = self:getControl(string.format("IconPanel%d", i), nil, itemPanel)
        self:initFormuala(child, types[i])
        child:setVisible(true)

        if bindEvent then
            self:bindListener(string.format("IconPanel%d", i), self.onItemSelected, itemPanel)
        end

        if 1 == index and 1 == i and not self.curCooking then
            self:onItemSelected(child)
        end
    end

    local childCount = info.max_count or #types
    for i = #types + 1, childCount do
        child = self:getControl(string.format("IconPanel%d", i), nil, ctrl)
        child:setVisible(false)

        if bindEvent then
            self:bindListener(string.format("IconPanel%d", i), self.onItemSelected, itemPanel)
        end
    end
end

function HomeCookingDlg:initFormuala(ctrl, sType)
    if not ctrl or not sType then return end
    ctrl.cooking = sType    -- 记录对应的烹饪类型
    local itemInfo = InventoryMgr:getItemInfoByName(sType.name)
    self:setImage("IconImage", ResMgr:getItemIconPath(itemInfo.icon), ctrl)
    self:setCtrlEnabled("IconImage", self:canCooking(sType.formula), ctrl)
    self:setNumImgForPanel(ctrl, ART_FONT_COLOR.NORMAL_TEXT, itemInfo.item_level,
                                 false, LOCATE_POSITION.LEFT_TOP, 21)
    if sType.binding then
        InventoryMgr:addLogoBinding(self:getControl("IconImage", nil, ctrl))
    end
end

function HomeCookingDlg:refreshAllFormula()
    for i = 1, #HomeCookingFormula do
        local info = HomeCookingFormula[i]
        if not info or not info.types or #info.types <= 0 then return end
        local types = info.types
        local itemPanel = self:getControl(string.format("ItemPanel%d", i), nil, "ItemListView")

        for j = 1, #types do
            child = self:getControl(string.format("IconPanel%d", j), nil, itemPanel)
            self:setCtrlEnabled("IconImage", self:canCooking(types[j].formula), child)
        end
    end
end

-- 配方是否可以使用
function HomeCookingDlg:canCooking(formulas)
    if not formulas then return false end

    local formula
    for i = 1, #formulas do
        formula = formulas[i]
        for k, v in pairs(formula) do
            if InventoryMgr:getAmountByName(k) < v then return false end
        end
    end

    return true
end

function HomeCookingDlg:comfireNumber(num)
    self:insertNumber(math.max(self.curCookingNum, 1))
end

function HomeCookingDlg:insertNumber(num)
    local maxCount = self:getCookingCount()
    if num > 1 then
        self.curCookingNum = math.max(math.min(num, maxCount), 1)

        if 0 == maxCount then
            gf:ShowSmallTips(CHS[2000400])
        elseif num > maxCount then
            local tips = num > NUM_PER_COOKING_ONE_TIMES and maxCount >= NUM_PER_COOKING_ONE_TIMES and CHS[2000405] or string.format(CHS[2000388], maxCount)
            gf:ShowSmallTips(tips)
        end
    else
        self.curCookingNum = num
    end
    self:setLabelText("NumLabel", self.curCookingNum, "NumPanel")

    if num > 0 then
        self:setNumImgForPanel("FoodIconPanel", ART_FONT_COLOR.NORMAL_TEXT, self.curCookingNum * self.curCooking.num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

        for i = 1, #self.curCooking.formula do
            local pairs = self.curCooking.formula[i]
            local k, v = next(pairs)
            local root = string.format("MaterialIconPanel%d", i)
            local amount = InventoryMgr:getAmountByName(k)
            local needCount = v * self.curCookingNum
            --self:setLabelText("NumLabel", amount, root, needCount > amount and COLOR3.RED or COLOR3.TEXT_DEFAULT)
            --self:setLabelText("NumLimitLabel", "/" .. tostring(needCount), root)
            self:setNumImgForPanel("MatNumPanel", needCount > amount and ART_FONT_COLOR.RED or ART_FONT_COLOR.NORMAL_TEXT, string.format("%d/%d", amount, needCount), false, LOCATE_POSITION.RIGHT_BOTTOM, ART_FONT_SIZE, root)
        end
        self:setLabelText("TextLabel", string.format(CHS[2000401], self:getCostDurability()), "ButtonPanel")
    end

    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.curCookingNum)
    end
end

-- 刷新当前烹饪数据
function HomeCookingDlg:refreshCurCooking()
    if not self.curCooking then return end

    local info = InventoryMgr:getItemInfoByName(self.curCooking.name)

    self:insertNumber(math.max(1, self:getCookingCount()))

    self:setImage("IconImage", ResMgr:getItemIconPath(info.icon), "FoodIconPanel")
    local image = self:getControl("IconImage", nil, "FoodIconPanel")
    -- self:setNumImgForPanel("FoodIconPanel", ART_FONT_COLOR.NORMAL_TEXT, info.item_level,
    --                              false, LOCATE_POSITION.LEFT_TOP, 21)

    self:setLabelText("LvTextLabel", self.curCooking.name, "FoodLvPanel")

    -- 绑定属性
    if self.curCooking.binding then
        InventoryMgr:addLogoBinding(image)
    else
        InventoryMgr:removeLogoBinding(image)
    end

    -- 烹饪的数量，单份产出数量 * 烹饪的份数
    self:setNumImgForPanel("FoodIconPanel", ART_FONT_COLOR.NORMAL_TEXT, self.curCookingNum * self.curCooking.num,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

    -- 材料
    for i = 1, #self.curCooking.formula do
        local pairs = self.curCooking.formula[i]
        local k, v = next(pairs)
        local root = string.format("MaterialIconPanel%d", i)
        self:setImage("IconImage", InventoryMgr:getIconFileByName(k), root)
        self:setCtrlVisible("IconImage", true, root)
        local amount = InventoryMgr:getAmountByName(k)
        local needCount = v * self.curCookingNum
        --self:setLabelText("NumLabel", amount, root, needCount > amount and COLOR3.RED or COLOR3.TEXT_DEFAULT)
        --self:setLabelText("NumLimitLabel", "/" .. tostring(needCount), root)
        self:setNumImgForPanel("MatNumPanel", needCount > amount and ART_FONT_COLOR.RED or ART_FONT_COLOR.NORMAL_TEXT, string.format("%d/%d", amount, needCount), false, LOCATE_POSITION.RIGHT_BOTTOM, ART_FONT_SIZE, root)
        self:setCtrlVisible("BackImg", false, root)
        self:getControl(root).matName = k
    end

    -- 将多出的控件隐藏
    for i = #self.curCooking.formula + 1, 3 do
        local root = string.format("MaterialIconPanel%d", i)
        self:setCtrlVisible("IconImage", false, root)
        --self:setLabelText("NumLabel", "", root)
        --self:setLabelText("NumLimitLabel", "", root)
        self:setNumImgForPanel("MatNumPanel", ART_FONT_COLOR.NORMAL_TEXT, "", false, LOCATE_POSITION.RIGHT_BOTTOM, ART_FONT_SIZE, root)
        self:setCtrlVisible("BackImg", true, root)
        self:getControl(root).matName = nil
    end
end

-- 获取可烹饪的数量
function HomeCookingDlg:getCookingCount()
    if not self.curCooking then return 0 end
    local limit = 0xFFFFFFFF
    for i = 1, #self.curCooking.formula do
        local pairs = self.curCooking.formula[i]
        local k, v = next(pairs)
        local amount = InventoryMgr:getAmountByName(k)
        limit = math.min(limit, amount / v)
    end

    return math.min(limit, NUM_PER_COOKING_ONE_TIMES)
end

-- 获取烹饪需要消耗的耐久度
function HomeCookingDlg:getCostDurability()
    return self.curCookingNum * 1
end

-- 获取家具耐久信息
function HomeCookingDlg:getDurInfo(item)
    local dur = item:queryBasicInt("durability")
    local maxDur = HomeMgr:getMaxDur(item:queryBasic("name"))
    return dur, maxDur
end

-- 获取恢复耐久所消耗的金钱
function HomeCookingDlg:getCostMoney(item)
    local nowDur, maxDur = self:getDurInfo(item)
    return HomeMgr:getFixCost(nowDur, maxDur)
end

function HomeCookingDlg:doCook()
    gf:CmdToServer("CMD_HOUSE_START_COOKING", { furniture_pos = self.furnitureId, cooking_name = self.curCooking.name, num = self.curCookingNum })
end

-- 菜单被选中
function HomeCookingDlg:onItemSelected(sender)
    self.selectImg:removeFromParent(false)
    sender:addChild(self.selectImg)

    self.curCooking = sender.cooking
    self:refreshCurCooking()
end

-- 烹饪按钮
function HomeCookingDlg:onCookButton()
    local furniture = HomeMgr:getFurnitureById(self.furnitureId)
    if not furniture then
        -- 家具不存在
        gf:ShowSmallTips(CHS[2000390])
        return
    end

    local curX, curY = gf:convertToMapSpace(furniture.curX, furniture.curY)
    if curX ~= self.furnitureX or curY ~= self.furnitureY then
        -- 家具位置移动
        gf:ShowSmallTips(CHS[2000391])
        return
    end

    if Me:isInJail() then
        -- 封闭
        gf:ShowSmallTips(CHS[2000280])
        return
    end

    local count = InventoryMgr:getCountCanAddToBag(self.curCooking.name, self.curCookingNum, self.curCooking.binding)
    if count < self.curCookingNum then
        -- 包裹位置不足
        gf:ShowSmallTips(CHS[2000392])
        return
    end

    if self:getCookingCount() < self.curCookingNum then
        -- 数量超出了
        gf:ShowSmallTips(CHS[2000393])
        return
    end

    if furniture:queryBasicInt("durability") < self:getCostDurability() then
        -- 耐久不足
        gf:ShowSmallTips(CHS[2000394])
        return
    end

    if HomeMgr:getClean() < 20 then
        -- 清洁度不足
        gf:ShowSmallTips(CHS[2000395])
        return
    end

    if self:checkSafeLockRelease("doCook") then
        -- 安全锁
        return
    end

    -- 开始烹饪
    self:doCook()
end

-- 补充耐久度
function HomeCookingDlg:onAddDurButton()
    local item = HomeMgr:getFurnitureById(self.furnitureId)
    if not item then
        return
    end

    local furniture_pos = item.id or item:queryBasicInt("id")

    -- 这件家具的耐久度已达上限，无需进行修理。
    local dur, maxDur =self:getDurInfo(item)
    if dur >= maxDur then
        gf:ShowSmallTips(CHS[7002350])
        return
    end

    local costMoney = self:getCostMoney(item)
    if costMoney then
        local name = item.name or item:queryBasic("name")
        local moneyStr = gf:getMoneyDesc(costMoney)
        local tip = string.format(CHS[7002351], moneyStr, name)
        gf:confirm(tip, function()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end
            
            gf:CmdToServer("CMD_HOUSE_REPAIR_FURNITURE", {furniture_pos = furniture_pos, cost = costMoney})
        end)
    end
end

-- 增加烹饪数量
function HomeCookingDlg:onPlusButton()
    local num = self.curCookingNum
    local maxNum = self:getCookingCount()

    if 0 == maxNum then
        gf:ShowSmallTips(CHS[2000402])
        return
    elseif num >= maxNum then
        local tips = num >= NUM_PER_COOKING_ONE_TIMES and CHS[2000405] or string.format(CHS[2000396], maxNum)
        gf:ShowSmallTips(tips)
        return
    end

    self:insertNumber(num + 1)
end

-- 减少烹饪数量
function HomeCookingDlg:onMinusButton()
    local num = self.curCookingNum
    if num <= 1 then
        gf:ShowSmallTips(CHS[2000397])
        return
    end

    self:insertNumber(num - 1)
end

function HomeCookingDlg:onClickFood(sender)
    if not self.curCooking then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(self.curCooking.name))
    info.name = self.curCooking.name
    info.item_type = ITEM_TYPE.DISH
    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function HomeCookingDlg:onClickFoodMat(sender)
    local matName = sender.matName
    if string.isNilOrEmpty(matName) then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(matName))
    info.name = matName
    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function HomeCookingDlg:MSG_HOUSE_FURNITURE_OPER(data)
    self:MSG_HOUSE_DATA()
end

function HomeCookingDlg:MSG_HOUSE_DATA(data)
    local furniture = HomeMgr:getFurnitureById(self.furnitureId)
    if furniture then
        local furnitureName = furniture:getName()

        -- 灶台名称
        self:setLabelText("NameLabel", furnitureName, self:getControl("NamePanel", nil, "HearthPanel"))

        -- 灶台耐久
        self:setLabelText("NumLabel", furniture:queryBasicInt("durability"), self:getControl("DurablePanel", nil, "HearthPanel"))
        self:setLabelText("LimitNumLabel", "/" .. tostring(HomeMgr:getMaxDur(furniture:getName())), self:getControl("DurablePanel", nil, "HearthPanel"))

        for k, v in pairs(NAME2BK) do
            self:setCtrlVisible(v, furnitureName == k)
        end
    end
end

function HomeCookingDlg:MSG_INVENTORY(data)
    for i = 1, #self.curCooking.formula do
        local pairs = self.curCooking.formula[i]
        local k, v = next(pairs)
        local root = string.format("MaterialIconPanel%d", i)
        local amount = InventoryMgr:getAmountByName(k)
        local needCount = v * self.curCookingNum
        --self:setLabelText("NumLabel", amount, root, needCount > amount and COLOR3.RED or COLOR3.TEXT_DEFAULT)
        --self:setLabelText("NumLimitLabel", "/" .. tostring(needCount), root)
        self:setNumImgForPanel("MatNumPanel", needCount > amount and ART_FONT_COLOR.RED or ART_FONT_COLOR.NORMAL_TEXT, string.format("%d/%d", amount, needCount), false, LOCATE_POSITION.RIGHT_BOTTOM, ART_FONT_SIZE, root)
    end
    self:refreshAllFormula()
    self:refreshCurCooking()
end

return HomeCookingDlg