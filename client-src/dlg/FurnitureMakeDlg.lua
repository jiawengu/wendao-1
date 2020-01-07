-- FurnitureMakeDlg.lua
-- Created by lixh Aug/15/2017
-- 居所鲁班台打造界面

local FurnitureMakeDlg = Singleton("FurnitureMakeDlg", Dialog)

-- 家具打造配置：材料信息，是否功能型家具，家具描述
local FURNITURE_MAKE_CONFIG = require(ResMgr:getCfgPath("FurnitureMakeConfig.lua"))

-- 单次打造家具所需耐久度
local MAKE_ONEC_COST_DURABLE = 10

-- 是否使用限制交易物品
FurnitureMakeDlg.isUseLimitSelected = nil

-- 打造列表家具名称   与HomeMgr鲁班台的LuBanFur表一致，由于用到地方少、两个表结构不一致，所以没有独立出文件
-- 打造列表家具名称，下表为鲁班打造列表排序列表，且要保证以下道具在FurnitureMakeConfig均有配置
local furnitureList = {
    CHS[5400255],
    CHS[5400256],
    CHS[2500061], -- 演武木桩
    CHS[7100003],
    CHS[7100004],
    CHS[7100005],
    CHS[7100006],
    CHS[7100007],
    CHS[7100008],
    CHS[7100009],
    CHS[7100010],
    CHS[7100011],
    CHS[7100012],
    CHS[7100013],
    CHS[7100014],
    CHS[7100015],
    CHS[7100016],
    CHS[7190000],
    CHS[7190001],
    CHS[7190002],
    CHS[7100017],
    CHS[7100018],
    CHS[7100019],
    CHS[7100020],
    CHS[7100021],
    CHS[7100022],
}

function FurnitureMakeDlg:init(data)
    self:bindListener("AddButton1", self.onAddCleanButton)
    self:bindListener("AddButton2", self.onAddDurableButton)
    self:bindListener("AllButton1", self.onAllButton1)
    self:bindListener("FullButton5", self.onFullButton5)
    self:bindListener("MaterialPanel_1", self.onClickMakePanelIcon)
    self:bindListener("MaterialPanel_2", self.onClickMakePanelIcon)
    self:bindListener("MaterialPanel_3", self.onClickMakePanelIcon)
    self:bindListener("MaterialPanel_4", self.onClickMakePanelIcon)
    self:bindListener("ShapePanel", self.onClickMakePanelIcon)
    self:bindListener("LimitedCheckBox", self.onSelectLimitCheckBox)
    self:bindListener("FunCheckBox", self.onSelectFuncCheckBox)
    self:bindListener("ConfirmButton", self.onMakeButton)

    self.furnitureId = data[1]
    self.furnitureList = furnitureList

    self.listView = self:getControl("FurnitureListView", nil, "ChosePanel")
    self.listItem = self:retainCtrl("FurniturePanel_1", nil, self.listView)
    self.listView:removeAllChildren()

    -- 根据上次客户端记忆赋值使用永久限制交易标记
    local key = string.format("furniture_make_with_limit_%s", Me:queryBasic("gid"))
    local isLastUseLimit = cc.UserDefault:getInstance():getIntegerForKey(key, 1)
    self.isUseLimitSelected = (isLastUseLimit == 1)

    local node = self:getControl("LimitedCheckBox", Const.UICheckBox)
    if self.isUseLimitSelected then
        self:setCheck("LimitedCheckBox", true)
    else
        self:setCheck("LimitedCheckBox", false)
    end

    -- 当前选择的制作装备名称
    self.curMakeFurnitureName = nil

    -- 选择所有物品或材料充足标记
    self.allItemTag = true

    -- 清洁度
    self:setCleanLable()

    -- 耐久度
    self:setDurableLable()

    -- 默认选择所有物品
    self:selectAllItems()
    self.allItemTag = true

    -- 检测 【指引】居所生产 任务是否完成
    if not TaskMgr:isCompleteJSSCTask() then
        gf:CmdToServer("CMD_REQUEST_TASK_STATUS", {taskName = CHS[4200442]})
    end



    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_TASK_STATUS_INFO")

end

function FurnitureMakeDlg:setDurableLable()
    local item = HomeMgr:getFurnitureById(self.furnitureId)
    if not item then
        return
    end

    local dur, maxDur =self:getDurInfo(item)
    local durabletStr = dur  .. "/" .. maxDur
    self:setLabelText("TimeLabel2", durabletStr)
end

function FurnitureMakeDlg:setCleanLable(data)
    local nowClean = HomeMgr:getClean()
    local maxClean = HomeMgr:getMaxClean()
    if data then
        nowClean = data.nowClean
        maxClean = data.maxClean
    end

    local cleanStr = nowClean  .. "/" .. maxClean
    self:setLabelText("TimeLabel1", cleanStr)
end

-- 补充清洁值
function FurnitureMakeDlg:onAddCleanButton()
    local nowClean = HomeMgr:getClean()
    local maxClean = HomeMgr:getMaxClean()

    if nowClean == maxClean then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end

    HomeMgr:requestData("HomeCleanDlg")
    --DlgMgr:openDlg("HomeCleanDlg")
end

-- 补充耐久度
function FurnitureMakeDlg:onAddDurableButton()
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

-- 获取家具耐久信息
function FurnitureMakeDlg:getDurInfo(item)
    local dur = item:queryBasicInt("durability")
    local maxDur = HomeMgr:getMaxDur(item:queryBasic("name"))
    return dur, maxDur
end

-- 获取恢复耐久所消耗的金钱
function FurnitureMakeDlg:getCostMoney(item)
    local nowDur, maxDur = self:getDurInfo(item)
    return HomeMgr:getFixCost(nowDur, maxDur)
end

-- 制作家具
function FurnitureMakeDlg:onMakeButton(sender, eventType)
    if self.isUseLimitSelected then
        gf:CmdToServer("CMD_HOUSE_START_MAKE_FURNITURE", { furniture_pos = self.furnitureId, furniture_name = self.curMakeFurnitureName, is_use_limit = 1})
    else
        gf:CmdToServer("CMD_HOUSE_START_MAKE_FURNITURE", { furniture_pos = self.furnitureId, furniture_name = self.curMakeFurnitureName, is_use_limit = 0})
    end
end

function FurnitureMakeDlg:onAllButton1(sender, eventType)
    self:selectAllItems()
    self.allItemTag = true
end

function FurnitureMakeDlg:onFullButton5(sender, eventType)
    self:selectEnoughMaterials()
    self.allItemTag = false
end

-- 选择所有物品
function FurnitureMakeDlg:selectAllItems()
    self:setCtrlVisible("FullButton6", false)
    self:setCtrlVisible("AllButton2", true)
    self:getFurnitureListByTag(true)
    self:selectFirstItem()
end

-- 选择材料充足
function FurnitureMakeDlg:selectEnoughMaterials()
    self:setCtrlVisible("AllButton2", false)
    self:setCtrlVisible("FullButton6", true)
    self:getFurnitureListByTag(false)
    self:selectFirstItem()
end

-- 根据isFullItem选择家具列表内容，ture:所有物品，false:材料充足
function FurnitureMakeDlg:getFurnitureListByTag(isFullItem)
    self.listView:removeAllChildren()
    local item = nil
    local furnitureInfo = nil
    local list = self.furnitureList

    for i = 1, #list do
        furnitureInfo = HomeMgr:getFurnitureInfo(list[i])
        local materialEnough = true

        -- 选择材料充足页签时需要判断材料是否充足
        if not isFullItem then
            materialEnough = self:isMaterialEnough(list[i])
        end

        -- 五彩孔雀摆饰 需要 "【指引】居所生产" 指引完成才行，目前只有这一个
        local isMeetCondition = true
        if list[i] == CHS[7100022] and not TaskMgr:isCompleteJSSCTask() then
            isMeetCondition = false
        end

        if furnitureInfo and materialEnough and isMeetCondition then
            item = self.listItem:clone()
            item.name = list[i]
            item:setTouchEnabled(true)
            self:setItemData(item, furnitureInfo, list[i])
            item:setTag(i)
            item:setName(list[i])

            local function touch(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local tag = sender:getTag()
                    local furnitureClick = HomeMgr:getFurnitureInfo(list[tag])
                    if furnitureClick then
                        -- 回调函数处理家具制作界面信息
                        self:setSelectStatusByName(list[tag])
                        self:initMakePanelWithFurnitureName(list[tag])
                        self.curMakeFurnitureName = list[tag]
                    end
                end
            end

            item:addTouchEventListener(touch)
            self.listView:pushBackCustomItem(item)
        end
    end

    self:setCtrlVisible("FurnitureListView", true, "ChosePanel")
    local itemCount = #self.listView:getChildren()
    self.listView:setVisible(itemCount > 0)

    self.listView:refreshView()
    performWithDelay(self.root, function ()
        local setHeight = self.listView:getInnerContainerSize().height
        if setHeight > self.listView:getContentSize().height then
            self.listView:getInnerContainer():setPositionY(self.listView:getContentSize().height - setHeight)
        end
    end, 0.01)

    self:setCtrlVisible("TipsLabel", itemCount <= 0, "ChosePanel")
    self:setCtrlVisible("TipsImage", itemCount <= 0, "ChosePanel")
    if itemCount <= 0 then
        self:clearShowPanel()
    end
end

function FurnitureMakeDlg:setItemData(item, data, name)
    if not data and name then
        return
    end

    local iconPath = ResMgr:getItemIconPath(data.icon)
    self:setLabelText("NameLabel", name, item)
    self:setImage("GuardImage", iconPath, item)
    self:setLabelText("LevelLabel", HomeMgr:furnitureLevelToChs()[data.level], item)
end

function FurnitureMakeDlg:clearShowPanel()
    self.curMakeFurnitureName = nil
    self:setCtrlVisible("GuardImage", false, "ShapePanel")
    self:getControl("ShapePanel").matName = nil
    self:setCtrlVisible("FunctionLabel", false, "ShowPanel")

    local materialIconMap = {"MaterialPanel_1", "MaterialPanel_2", "MaterialPanel_3", "MaterialPanel_4"}
    for ind = 1, #materialIconMap do
        local root = materialIconMap[ind]
        self:setCtrlVisible("GuardImage", false, root)
        self:setCtrlVisible("BackImg", false, root)
        self:setCtrlVisible("NumPanel", false, root)
        self:getControl(root).matName = nil
    end
end

-- 判断制作name家具的材料谁否足够
function FurnitureMakeDlg:isMaterialEnough(name)
    local needMaterial = FURNITURE_MAKE_CONFIG[name].material
    if not needMaterial then
        return false
    end

    for k,v in pairs(needMaterial) do
        local haveMaterialNum = self:getFurnitureCountByName(k)
        if haveMaterialNum < v then
            return false
        end
    end

    return true
end

-- 根据家具名与是否使用永久限制交易标记，获取可使用家具数量
function FurnitureMakeDlg:getFurnitureCountByName(itemName)
    return InventoryMgr:getAmountByNameIsForeverBind(itemName, self.isUseLimitSelected)
end

-- 根据家具名设置选中效果
function FurnitureMakeDlg:setSelectStatusByName(name)
    local furnitureInfo = HomeMgr:getFurnitureInfo(name)
    if not name or not furnitureInfo then
        return
    end

    local itemList = self.listView:getChildren()
    for i = 1, #itemList do
        local nameLabel = self:getControl("NameLabel", nil, itemList[i]):getString()
        if nameLabel == name then
            self:setCtrlVisible("ChosenEffectImage", true, itemList[i])
        else
            self:setCtrlVisible("ChosenEffectImage", false, itemList[i])
        end
    end
end

-- 进入界面默认选择第一个家具
function FurnitureMakeDlg:selectFirstItem()
    local itemList = self.listView:getChildren()
    if itemList and #itemList > 0 then
        -- 由于添加的时候是倒叙添加的，所以选择最后一件家具
        local nameLabel = self:getControl("NameLabel", nil, itemList[i]):getString()
        self.curMakeFurnitureName = nameLabel
        self:initMakePanelWithFurnitureName(nameLabel)
        self:setCtrlVisible("ChosenEffectImage", true, itemList[i])
    end
end

-- 根据家具名称初始化家具制作界面
function FurnitureMakeDlg:initMakePanelWithFurnitureName(name)
    local furnitureInfo = HomeMgr:getFurnitureInfo(name)
    if not name or not furnitureInfo then
        return
    end

    -- 家具icon
    local iconPath = ResMgr:getItemIconPath(furnitureInfo.icon)
    self:setImage("GuardImage", iconPath, self:getControl("ShapePanel"))
    self:setCtrlVisible("GuardImage", true, "ShapePanel")
    self:getControl("ShapePanel").matName = name

    -- 家具功能
    self:setCtrlVisible("FunctionLabel", true, "ShowPanel")
    self:setLabelText("FunctionLabel", FURNITURE_MAKE_CONFIG[name].funcDes, "ShowPanel")

    -- 材料icon
    local needMaterial = FURNITURE_MAKE_CONFIG[name].material
    if not needMaterial then
        -- 不存在当前家具
        return false
    end

    local materialIconMap = {"MaterialPanel_1", "MaterialPanel_2", "MaterialPanel_3", "MaterialPanel_4"}
    local needInd = 1
    for k,v in pairs(needMaterial) do
        local root = materialIconMap[needInd]
        local materialInfo = HomeMgr:getFurnitureInfo(k)
        local iconPath = ResMgr:getItemIconPath(materialInfo.icon)
        self:setImage("GuardImage", iconPath, root)
        self:setCtrlVisible("GuardImage", true, root)
        self:setCtrlVisible("BackImg", false, root)

        -- 材料数量
        local haveMaterialNum = self:getFurnitureCountByName(k)
        local needMaterialNum = v

        if haveMaterialNum > CONST_DATA.containerTag then
            haveMaterialNum = "*"
        end

        local setStr = haveMaterialNum  .. "/" .. needMaterialNum
        if haveMaterialNum ~= "*" and haveMaterialNum < needMaterialNum then
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.RED, setStr, false, LOCATE_POSITION.RIGHT_BOTTOM, 15, root)
        else
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, setStr, false, LOCATE_POSITION.RIGHT_BOTTOM, 15, root)
        end

        self:setCtrlVisible("NumPanel", true, root)

        -- 标记当前材料框，用来显示悬浮框
        self:getControl(root).matName = k

        needInd = needInd + 1
        if needInd > #materialIconMap then
            break
        end
    end

    -- 隐藏材料不足4个时，额外的icon与材料数量信息
    for ind = needInd, #materialIconMap do
        local root = materialIconMap[ind]
        self:setCtrlVisible("GuardImage", false, root)
        self:setCtrlVisible("BackImg", true, root)
        self:setCtrlVisible("NumPanel", false, root)
        self:getControl(root).matName = nil
    end
end

-- 悬浮框
function FurnitureMakeDlg:onClickMakePanelIcon(sender)
    if sender and sender.matName then
        local item = HomeMgr:getFurnitureInfo(sender.matName)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        if item.furniture_type == CHS[5400137] then
            -- 材料显示普通物品悬浮框
            InventoryMgr:showItemByItemData(item, rect)
        else
            -- 应策划需求，鲁班打造家具名片需要隐藏价格
            InventoryMgr:showFurniture(item, rect, true, true)
        end
    end
end

-- 选择永久限制交易道具
function FurnitureMakeDlg:onSelectLimitCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        FurnitureMakeDlg.isUseLimitSelected = true
        self:initMakePanelWithFurnitureName(self.curMakeFurnitureName)
    else
        FurnitureMakeDlg.isUseLimitSelected = false
        self:initMakePanelWithFurnitureName(self.curMakeFurnitureName)
    end

    local key = string.format("furniture_make_with_limit_%s", Me:queryBasic("gid"))
    cc.UserDefault:getInstance():setIntegerForKey(key, self.isUseLimitSelected and 1 or 0)
    cc.UserDefault:getInstance():flush()
end

-- 选择仅显示功能型家具
function FurnitureMakeDlg:onSelectFuncCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        self.furnitureList = self:getFuncFurniture()
    else
        self.furnitureList = furnitureList
    end

    self:getFurnitureListByTag(self.allItemTag)
    if #self.listView:getItems() > 0 then
        self:selectFirstItem()
    end
end

function FurnitureMakeDlg:getFuncFurniture()
    local list = {}
    local count = 1
    for i = 1, #furnitureList do
        local furnitureFunc = FURNITURE_MAKE_CONFIG[furnitureList[i]]
        if furnitureFunc and furnitureFunc.isFunc == 1 then
            list[count] = furnitureList[i]
            count = count + 1
        end
    end

    return list
end

function FurnitureMakeDlg:MSG_HOUSE_FURNITURE_OPER(data)
    self:MSG_HOUSE_DATA()
end

function FurnitureMakeDlg:MSG_HOUSE_DATA(data)
    local furniture = HomeMgr:getFurnitureById(self.furnitureId)
    if furniture then
        self:setDurableLable()
        self:setCleanLable()
    end
end

function FurnitureMakeDlg:MSG_TASK_STATUS_INFO(data)
    if data.taskName == CHS[4200442] and data.status == 1 and not self.listView:getChildByName(CHS[7100022]) then
        local furnitureInfo = HomeMgr:getFurnitureInfo(CHS[7100022])
        local materialEnough = true

        -- 选择材料充足页签时需要判断材料是否充足
        if not self.allItemTag then
            materialEnough = self:isMaterialEnough(CHS[7100022])
        end

        if furnitureInfo and materialEnough then
            local item = nil
            item = self.listItem:clone()
            item.name = CHS[7100022]
            item:setTouchEnabled(true)
            self:setItemData(item, furnitureInfo, CHS[7100022])
            item:setTag(#self.listView:getItems() + 1)

            local function touch(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local tag = sender:getTag()
                    local furnitureClick = HomeMgr:getFurnitureInfo(self.furnitureList[tag])
                    if furnitureClick then
                        -- 回调函数处理家具制作界面信息
                        self:setSelectStatusByName(self.furnitureList[tag])
                        self:initMakePanelWithFurnitureName(self.furnitureList[tag])
                        self.curMakeFurnitureName = self.furnitureList[tag]
                    end
                end
            end

            item:addTouchEventListener(touch)
            self.listView:pushBackCustomItem(item)
        end
    end
end

function FurnitureMakeDlg:MSG_INVENTORY(data)
    self:initMakePanelWithFurnitureName(self.curMakeFurnitureName)
    if not self.allItemTag then
        -- 制作完若选择材料充足界面，则需刷新该界面
        self:refreshMaterialEnoughPanel()
    end
end

-- 制作成功后刷新材料充足面板
function FurnitureMakeDlg:refreshMaterialEnoughPanel()
    local removeSelected = false
    for i = 1, #self.furnitureList do
        local item = self.listView:getChildByTag(i)
        if item then
            local nameLabel = self:getControl("NameLabel", nil, item):getString()
            if not self:isMaterialEnough(nameLabel) then
                self.listView:removeChildByTag(i)
                if nameLabel == self.curMakeFurnitureName then
                    removeSelected = true
                end
            end
        end
    end

    if removeSelected then
        self:selectFirstItem()
    end

    self.listView:refreshView()

    local itemCount = #self.listView:getChildren()
    self.listView:setVisible(itemCount > 0)
    self:setCtrlVisible("TipsLabel", itemCount <= 0, "ChosePanel")
    self:setCtrlVisible("TipsImage", itemCount <= 0, "ChosePanel")
    if itemCount <= 0 then
        self:clearShowPanel()
    end
end

return FurnitureMakeDlg
