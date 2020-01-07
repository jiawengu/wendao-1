-- HomePuttingDlg.lua
-- Created by sujl, Jan/20/2017
-- 家具摆放界面

local HomePuttingDlg = Singleton("HomePuttingDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

local HOUSE_FURITURES = {  CHS[2000321], CHS[2000315], CHS[2000316], CHS[2000317], CHS[2000318], CHS[2000319], CHS[2000320] }
local VESTIBULE_FURITURES = { CHS[2000326], CHS[2000322], CHS[2000323], CHS[2000324], CHS[2000325] }
local BACKYARD_FURITURES = { CHS[5400254], CHS[2000327], CHS[2000328] }
local FURNITURE_TYPE_IMAGE = {
    [CHS[2000290]] = ResMgr.ui.furn_type_image1,    --前庭-桌凳
    [CHS[2000291]] = ResMgr.ui.furn_type_image2,    --前庭-摆设
    [CHS[2000292]] = ResMgr.ui.furn_type_image3,    --前庭-围墙
    [CHS[2000293]] = ResMgr.ui.furn_type_image4,    --前庭-地面
    [CHS[2000294]] = ResMgr.ui.furn_type_image5,    --前庭-功能
    [CHS[2000295]] = ResMgr.ui.furn_type_image6,    --房屋-床柜
    [CHS[2000296]] = ResMgr.ui.furn_type_image7,    --房屋-桌椅
    [CHS[2000297]] = ResMgr.ui.furn_type_image8,    --房屋-摆设
    [CHS[2000298]] = ResMgr.ui.furn_type_image9,    --房屋-墙饰
    [CHS[2000299]] = ResMgr.ui.furn_type_image10,    --房屋-地毯
    [CHS[2000300]] = ResMgr.ui.furn_type_image11,    --房屋-地砖
    [CHS[2000301]] = ResMgr.ui.furn_type_image12,    --房屋-功能
    [CHS[2000302]] = ResMgr.ui.furn_type_image13,    --后院-椅凳
    [CHS[2000303]] = ResMgr.ui.furn_type_image14,    --后院-摆设
    [CHS[5400253]] = ResMgr.ui.furn_type_image15,    --后院-功能
}

local BEGIN_OFFSET_X = 30
local BEGIN_OFFSET_Y = 5
local ITEM_INTERVAl = 10
local LAYER_TAG = 10

function HomePuttingDlg:init(args)
    self:bindListener("ClickPanel", self.onClickPanel)
    self:bindListener("ChoseButton_1", self.onAllButton, "ChosePanel")
    self:bindListener("ChoseButton_2", self.onOwnButton, "ChosePanel")
    self:bindListener("ImagePanel_0", self.onSelectItem, "ListScrollView")
    self:bindListener("ConfirmButton", self.onConfirmButtn, "ScenePanel")
    self:bindListener("CancelButton", self.onCancelButton, "ScenePanel")
    self:bindListener("ShowOffButton", self.onShowOffButton, "ScenePanel")
    self:bindListener("ShowOnButton", self.onShowOnButton, "ScenePanel")
    self:bindListener("SpreadButton", self.onSpreadButton, "ScenePanel")
    self:bindListener("DownButton", self.onDownButton)
    self:bindListener("UpButton", self.onUpButton)

    -- 设置适配
    self:setFullScreen()

    local panel = self:getControl("ListBKImageanel")
    local psize = panel:getContentSize()
    panel:setContentSize(cc.size(self:getWinSize().width / Const.UI_SCALE - 355, psize.height))

    self.chosePanel = self:getControl("ChosePanel")
    self.chosePanel:setVisible(false)
    self:setCtrlVisible("Image_55", not self.chosePanel:isVisible(), "ClickPanel")
    self:setCtrlVisible("Image_56", self.chosePanel:isVisible(), "ClickPanel")
    self.clickPanel = self:getControl("ClickPanel")
    self.noneImage = self:getControl("NoneImage", nil, "ListBKImageanel")
    self.listView = self:getControl("ListScrollView", nil, "ListBKImageanel")
    self.listItem = self:getControl("ImagePanel_0", nil, self.listView)
    self.listItem:retain()
    self.listView:removeAllChildren()
    self.listView:setVisible(false)
    self.choseView = self:getControl("ChoseListView")
    self.choseItem = self:getControl("Panel_1", nil, self.choseView)
    self.choseItem:retain()
    self.choseView:removeAllChildren()
    self.scenePanel = self:getControl("ScenePanel")
    self.scenePanel:setVisible(false)
    self.scenePanelSize = cc.size(280, 105)
    self.interimPanel = self:getControl("InterimPanel", nil, "ScenePanel")
    self.interimPanel:retain()
    self.interimPanel:removeFromParent()

    self.isHideMainPanel = false

    self.curMapIndex = MapMgr:getCurrentMapIndex()

    self.radioGroup = RadioGroup.new()

    self.previews = {}

    self:initFurnitureType()
    self:refreshComformt()

    DlgMgr:closeDlg("HomePlantDlg")
    DlgMgr:closeDlg("HomeFishingDlg")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_HOUSE_DATA")
end

function HomePuttingDlg:cleanup()
    self:releaseCloneCtrl("choseItem")
    self:releaseCloneCtrl("listItem")
    self:releaseCloneCtrl("interimPanel")

    -- 关闭该界面时，同时关闭对应子界面
    DlgMgr:closeDlg("FurnitureBuyDlg")

    self.isOwn = nil
    local mapIndex = MapMgr:getCurrentMapIndex()
    if mapIndex and self.curMapIndex == mapIndex then
        GameMgr.scene.map:setTileIndex(MapMgr:getTileIndex())
        GameMgr.scene.map:setWallIndex(MapMgr:getWallIndex())
    end
    self.curMapIndex = nil
    self.previews = {}

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil
    self.curOperCookie = nil

    gf:CmdToServer('CMD_HOUSE_QUIT_MANAGE')
end

function HomePuttingDlg:setCurOperCookie(cookie)
    self.curOperCookie = cookie
end

-- 刷新舒适度
function HomePuttingDlg:refreshComformt()
    local comfort = HomeMgr:getComfort()
    local maxComfort = HomeMgr:getMaxComfort()
    local str = string.format("%d/%d", comfort, maxComfort)
    self:setLabelText("ComfortLabel_1", str, "ComfortProgressPanel")
    self:setLabelText("ComfortLabel_2", str, "ComfortProgressPanel")
    self:setProgressBar("activityProgressBar", comfort, maxComfort, "ComfortProgressPanel")
end

function HomePuttingDlg:initFurnitureType()
    self.choseView:removeAllChildren()
    local furnitures = self:getFurnituresByHouse()
    local radios = {}
    local mapName = MapMgr:getCurrentMapName()
    if not mapName then return end
    local mapPos = string.match(mapName, "[^-]*-(.*)")
    for i = 1, #furnitures, 2 do
        local rItem = self.choseItem:clone()
        local item1 = self:getControl("CheckBox_1", nil, rItem)
        local imageKey = string.format("%s-%s", mapPos, furnitures[i])
        self:setImage("Image_36", FURNITURE_TYPE_IMAGE[imageKey], item1)
        item1.ftype = furnitures[i]
        table.insert(radios, item1)
        local item2 = self:getControl("CheckBox_2", nil, rItem)
        if i + 1 <= #furnitures then
            imageKey = string.format("%s-%s", mapPos, furnitures[i + 1])
            self:setImage("Image_36", FURNITURE_TYPE_IMAGE[imageKey], item2)
            item2.ftype = furnitures[i + 1]
            table.insert(radios, item2)
        else
            item2:setVisible(false)
        end

        self.choseView:pushBackCustomItem(rItem)
    end

    self.radioGroup:setItems(self, radios, self.onChoseItem)
    self.radioGroup:selectRadio(1)

    local isFirst = true
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            -- 获取控件
            local listViewCtrl = sender

            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local listViewSize = listViewCtrl:getContentSize()

            -- 计算滚动的百分比
            local totalHeight = innerSize.height - listViewSize.height

            local innerPosY = listInnerContent:getPositionY()
            local persent = 1 - (-innerPosY) / totalHeight

            if not isFirst then
                self:setCtrlVisible("UpImage", persent > 0, "FurniturePanel")
                self:setCtrlVisible("DownImage", persent < 1, "FurniturePanel")
            end
            isFirst = nil
        end
    end

    self:setCtrlVisible("UpImage", false, "FurniturePanel")
    self:setCtrlVisible("DownImage", #furnitures > 4, "FurniturePanel")

    self.choseView:addScrollViewEventListener(onScrollView)
end

-- 初始化家具列表
function HomePuttingDlg:initFurnitureList(ftype)
    local list = HomeMgr:getFurnituresByType(ftype)
end

function HomePuttingDlg:getFurnituresByHouse()
    local mapIndex = MapMgr:getCurrentMapId()
    if not mapIndex then return end
    if 28301 == mapIndex or 28201 == mapIndex or 28101 == mapIndex then
        return HOUSE_FURITURES
    elseif 28300 == mapIndex or 28200 == mapIndex or 28100 == mapIndex then
        return VESTIBULE_FURITURES
    else
        return BACKYARD_FURITURES
    end
end

function HomePuttingDlg:setItemData(item, data)
    if not data then return end
    local iconPath = ResMgr:getItemIconPath(data.icon)
    self:setImage("FurnitureImage", iconPath, item)
    self:setLabelText("LevelLabel", data.level, item)
    local amount = math.max(0, HomeMgr:getItemCountByName(item.name))
    item.amount = amount
    local allAmount = math.max(0, HomeMgr:getAllItemCountByName(item.name))
    if allAmount > 0 then
        self:setLabelText("LeftTimeValueLabel", string.format("%d/%d", amount, allAmount), item)
    else
        self:setLabelText("LeftTimeValueLabel", 0, item)
    end
end

function HomePuttingDlg:refreshItemData(reset)
    local mapName = MapMgr:getCurrentMapName()
    if not mapName then return end
    local mapPos = string.match(mapName, "[^-]*-(.*)")
    local ftype = mapPos .. '-' .. self.curType
    local list = HomeMgr:getFurnituresByType(ftype)
    HomeMgr:sortFurnitureList(list)
    if not list or #list <= 0 then
        self.listView:setVisible(false)
        self.noneImage:setVisible(true)
        local limit = HomeMgr:getLimitByType(ftype)
        self:setLabelText("ComfortLabel", string.format(CHS[2000329], 0, limit))
        return
    end

    self.listView:removeAllChildren()
    if reset then
        self.listView:setInnerContainerSize(cc.size(0, 0))
    end
    local contentLayer = ccui.Layout:create()

    local item
    local size = self.listItem:getContentSize()
    local itemWidth = BEGIN_OFFSET_X
    for i = 1, #list do
        if not self.isOwn or HomeMgr:getItemCountByName(list[i].name) > 0 then
            item = self.listItem:clone()
            item.name = list[i].name
            item:setTouchEnabled(true)
            self:setItemData(item, list[i])
            item:setPosition(itemWidth, BEGIN_OFFSET_Y)
            contentLayer:addChild(item)
            itemWidth = itemWidth + size.width + ITEM_INTERVAl
        end
    end

    contentLayer:setContentSize(cc.size(itemWidth, size.height))
    self.listView:addChild(contentLayer, 0, LAYER_TAG)
    self.listView:setInnerContainerSize(contentLayer:getContentSize())

    local itemCount = #contentLayer:getChildren()
    self.listView:setVisible(itemCount > 0)
    self.noneImage:setVisible(itemCount <= 0)

    -- 设置家具上限
    local amount = HomeMgr:getAllAmountByType(ftype)
    local limit = HomeMgr:getLimitByType(ftype)
    if limit > 0 then
        self:setLabelText("ComfortLabel", string.format(CHS[2000329], amount, limit))
    else
        self:setLabelText("ComfortLabel", CHS[2000330])
    end
end

-- 增加预览家具
function HomePuttingDlg:addPreview(_info)
    -- 检查该类型的家具是否处于预览中，如果处于预览中则直接替换
    local hasAdd
    local info = gf:deepCopy(_info)
    info.previewOn = true
    for i = 1, #self.previews do
        if self.previews[i].furniture_type == info.furniture_type then
            if not self:isInUsing(info) then
            self.previews[i] = info
            else
                table.remove(self.previews, i)
            end

            hasAdd = true
            break
        end
    end

    if not hasAdd and not self:isInUsing(info) then
        table.insert(self.previews, info)
    end

    self:refreshPreview()
end

function HomePuttingDlg:isInUsing(info)
    if HomeMgr:isFloor(info.name) and MapMgr:getTileIndex() == info.tile_index + 1 then
        -- 地面、地砖
        return true
    elseif HomeMgr:isWall(info.name) and MapMgr:getWallIndex() == info.wall_index + 1 then
        -- 围墙
        return true
    end
end

function HomePuttingDlg:refreshPreview()
    if not self.scenePanel:isVisible() then
        local tipsPanel = self:getControl("TipsPanel", nil, self.scenePanel)
        tipsPanel:stopAllActions()
        tipsPanel:setVisible(true)
        tipsPanel:setOpacity(255)
        local delay = cc.DelayTime:create(4.5)
        local fadeout = cc.FadeOut:create(0.5)
        local delayFunc  = cc.CallFunc:create(function ()
            tipsPanel:setVisible(false)
        end)
        local sq = cc.Sequence:create(delay, fadeout, delayFunc)
        tipsPanel:runAction(sq)
    end
    self.scenePanel:setVisible(#self.previews > 0)
    if not self.scenePanel:isVisible() then return end

    local viewPanel = self:getControl("ViewPanel", nil, self.scenePanel)
    viewPanel:removeAllChildren()

    local bx, by = 3, 0
    local x, y = bx, by
    local item
    local height
    for i = 1, #self.previews do
        item = self.interimPanel:clone()
        self:setLabelText("Label_42", self.previews[i].name, item)
        item:setPosition(x, y)
        item.name = self.previews[i].name
        viewPanel:addChild(item)
        y = y - item:getContentSize().height
        self:setCtrlVisible("ShowOnButton", self.previews[i].previewOn, item)
        self:setCtrlVisible("ShowOffButton", not self.previews[i].previewOn, item)
    end

    local viewSize = viewPanel:getContentSize()
    local itemSize = self.interimPanel:getContentSize()
    --viewPanel:setContentSize(cc.size(viewSize.width, (#self.previews) * itemSize.height))
    self:setImageSize("ScenePanelBack", cc.size(self.scenePanelSize.width, self.scenePanelSize.height + (#self.previews - 1) * itemSize.height), "ScenePanel")
end

function HomePuttingDlg:getPreviewItemCount(itemName)
    local amount = HomeMgr:getItemCountByName(itemName)
    for i = 1, #self.previews do
        if self.previews[i].name == itemName then
            amount = amount - 1
        end
    end

    return amount
end

function HomePuttingDlg:isInPreview(itemName)
    for i = 1, #self.previews do
        if self.previews[i].name == itemName then
            return true
        end
    end
end

function HomePuttingDlg:clearPreview()
    self.previews = {}
end

function HomePuttingDlg:doUsePreview(itemName)
    local useInventory
    local items = StoreMgr:getFurnitureByName(itemName)
    if not items or #items <= 0 then
        items = InventoryMgr:getItemByName(itemName)
        useInventory = true
    end

    local info = HomeMgr:getFurnitureInfo(itemName)
    if HomeMgr:isFloor(itemName) then
        -- 地面、地砖
        if MapMgr:getTileIndex() == info.tile_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end
    elseif HomeMgr:isWall(itemName) then
        -- 围墙
        if MapMgr:getWallIndex() == info.wall_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end
    end

    local function _doUseItem(item)
        for i = #self.previews, 1, -1 do
            if self.previews[i].name == item.name then
                table.remove(self.previews, i)
                break
            end
        end
        gf:CmdToServer('CMD_HOUSE_PLACE_FURNITURE', { furniture_pos = item.pos, x = 0, y = 0, flip = 0, bx = 0, by = 0, cookie = 0 })
    end

    if items and #items > 0 then
        items = HomeMgr:sortFurniture(items)
        local item = items[1]
        if useInventory then
            gf:confirm(string.format(CHS[7002379], itemName), function()
                _doUseItem(item)
            end)
        else
            _doUseItem(item)
        end
    else
        gf:confirm(string.format(CHS[7002380], itemName), function()
            self.curOperCookie = itemName
            DlgMgr:openDlgEx("FurnitureBuyDlg", itemName)
            --[[
            for i = #self.previews, 1, -1 do
                if self.previews[i].name == itemName then
                    table.remove(self.previews, i)
                    break
                end
            end
            ]]
        end)
    end
end

function HomePuttingDlg:markDirty()
    if self.dirtyAction then return end
    self.dirtyAction = performWithDelay(self.root, function()
        self.dirtyAction = nil
        self:refreshItemData()
        self:refreshPreview()
    end, 0)
end

function HomePuttingDlg:onClickPanel(sender, eventType)
    self.chosePanel:setVisible(not self.chosePanel:isVisible())
    self:setCtrlVisible("Image_55", not self.chosePanel:isVisible(), "ClickPanel")
    self:setCtrlVisible("Image_56", self.chosePanel:isVisible(), "ClickPanel")
end

function HomePuttingDlg:onAllButton(sender, eventType)
    self:setLabelText("NowLabel", CHS[2000331], self.clickPanel)
    self.isOwn = nil
    self:refreshItemData(true)
    self.chosePanel:setVisible(false)
    self:setCtrlVisible("Image_55", not self.chosePanel:isVisible(), "ClickPanel")
    self:setCtrlVisible("Image_56", self.chosePanel:isVisible(), "ClickPanel")
end

function HomePuttingDlg:onOwnButton(sender, eventType)
    self:setLabelText("NowLabel", CHS[2000332], self.clickPanel)
    self.isOwn = true
    self:refreshItemData(true)
    self.chosePanel:setVisible(false)
    self:setCtrlVisible("Image_55", not self.chosePanel:isVisible(), "ClickPanel")
    self:setCtrlVisible("Image_56", self.chosePanel:isVisible(), "ClickPanel")
end

function HomePuttingDlg:onChoseItem(sender, eventType)
    self.curType = sender.ftype
    self:refreshItemData(true)
end

function HomePuttingDlg:onSelectItem(sender, eventType)
    self.sender = sender
    local itemName = sender.name
    local amount = sender.amount
    local furnitures = HomeMgr:getFurnituresByName(itemName)

    -- 如果当前家具是没有耐久度/容量的家具，则将所有背包中的家具和所有家具列表中的家具视为一个家具（从名片角度）
    if (not HomeMgr:getMaxDur(itemName) and not HomeMgr:getFurnitureCapacity(itemName)) and #furnitures > 1 then
        furnitures = {furnitures[1]}
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("FurnitureInfoDlg")
    if amount > 0 then
        dlg:setBasicInfo(furnitures[1], false, {furnitures = furnitures, index = 1})
    else
        -- 还没有此家具，仅仅依靠家具名称来显示名片
        local furniture = {name = itemName}
        dlg:setBasicInfo(furniture, false, {furnitures = furnitures, index = 0})
    end

    dlg:setFloatingFramePos(rect)
end

-- 摆设
function HomePuttingDlg:doPutting(pos)
    if not self.sender then
        return
    end

    -- 获取道具
    local item = HomeMgr:getFurnitureByPos(pos)
    local itemName = HomeMgr:getFurnitureNameByPos(pos)
    local info = HomeMgr:getFurnitureInfo(itemName)
    local furniture_type = info.furniture_type
    local useInventory = InventoryMgr:isBagItemByPos(pos)
    local isForeverLimit = InventoryMgr:isLimitedItemForever(item)

    if HomeMgr:isFloor(itemName) then
        -- 地面、地砖
        if self:isInPreview(info.name) then
            gf:ShowSmallTips(CHS[7002376])
            return
        end

        if GameMgr.scene.map:getTileIndex() == info.tile_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end


        --[[
        if useInventory and (not isForeverLimit) then
            gf:confirm(string.format(CHS[7002379], itemName), function()
                GameMgr.scene.map:setTileIndex(info.tile_index + 1)
                self:addPreview(info)
            end)

            return
        end
        --]]

        GameMgr.scene.map:setTileIndex(info.tile_index + 1)
        self:addPreview(info)
    elseif HomeMgr:isWall(itemName) then
        -- 围墙
        if self:isInPreview(info.name) then
            gf:ShowSmallTips(CHS[7002376])
            return
        end

        if GameMgr.scene.map:getWallIndex() == info.wall_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end

        --[[
        if useInventory and (not isForeverLimit) then
            gf:confirm(string.format(CHS[7002379], itemName), function()
                GameMgr.scene.map:setWallIndex(info.wall_index + 1)
                self:addPreview(info)
            end)

            return
        end
        --]]
        GameMgr.scene.map:setWallIndex(info.wall_index + 1, true)
        self:addPreview(info)
    else
        HomeMgr:previewPut(itemName, pos)
        local amount = HomeMgr:getItemCountByName(itemName)
        self.sender.amount = amount
        local allAmount = math.max(0, HomeMgr:getAllItemCountByName(itemName))
        if allAmount > 0 then
            self:setLabelText("LeftTimeValueLabel", string.format("%d/%d", amount, allAmount), self.sender)
        else
            self:setLabelText("LeftTimeValueLabel", 0, self.sender)
        end
    end
end

-- 预览
function HomePuttingDlg:doPreview(itemName)
    local info = HomeMgr:getFurnitureInfo(itemName)
    local furniture_type = info.furniture_type
    if HomeMgr:isFloor(itemName) then
        -- 地面、地砖
        if self:isInPreview(info.name) then
            gf:ShowSmallTips(CHS[7002376])
            return
        end

        if GameMgr.scene.map:getTileIndex() == info.tile_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end

        GameMgr.scene.map:setTileIndex(info.tile_index + 1)
        self:addPreview(info)

        if MapMgr:getTileIndex() ~= info.tile_index + 1 then
        local tip
        local furniture_type = info.furniture_type
        if string.match(furniture_type, CHS[7002373]) then
            tip = string.format(CHS[7003099], CHS[7003100])
        elseif string.match(furniture_type, CHS[7002374]) then
            tip = string.format(CHS[7003099], CHS[7003101])
        end

        gf:ShowSmallTips(tip)
        end
    elseif HomeMgr:isWall(itemName) then
        -- 围墙
        if self:isInPreview(info.name) then
            gf:ShowSmallTips(CHS[7002376])
            return
        end

        if GameMgr.scene.map:getWallIndex() == info.wall_index + 1 then
            gf:ShowSmallTips(CHS[7002377])
            return
        end

        GameMgr.scene.map:setWallIndex(info.wall_index + 1, true)
        self:addPreview(info)

        if MapMgr:getWallIndex() ~= info.wall_index + 1 then
        gf:ShowSmallTips(string.format(CHS[7003099], CHS[7003102]))
        end
    else
        HomeMgr:previewPut(itemName)
    end
end

-- 购买
function HomePuttingDlg:doBuy(itemName)
    local info = HomeMgr:getFurnitureInfo(itemName)
    if not info then return end
    if 0 == info.purchase_type then
        -- 当前家具无法直接购买
        gf:ShowSmallTips(CHS[2100092])
        return
    elseif (HomeMgr:isWall(itemName) or HomeMgr:isFloor(itemName)) and HomeMgr:getAllItemCountByName(itemName) >= 1 then
        -- 你已经拥有该家具了，不可重复购买
        gf:ShowSmallTips(CHS[2100093])
        return
    end

    DlgMgr:openDlgEx("FurnitureBuyDlg", itemName)
end

function HomePuttingDlg:onCloseButton()
    Dialog.onCloseButton(self)
end

function HomePuttingDlg:onConfirmButtn(sender, eventType)
    local ctrl = sender:getParent()
    local itemName = ctrl.name

   self:doUsePreview(itemName)
end

function HomePuttingDlg:onCancelButton(sender, eventType)
    local item = sender:getParent()
    local itemName = item.name

    if HomeMgr:isFloor(itemName) then
        GameMgr.scene.map:setTileIndex(MapMgr:getTileIndex())
    elseif HomeMgr:isWall(itemName) then
        GameMgr.scene.map:setWallIndex(MapMgr:getWallIndex())
    end

    for i = #self.previews, 1, -1 do
        if self.previews[i].name == itemName then
            table.remove(self.previews, i)
            break
        end
    end

    local children = self.listView:getChildren()
    local panel = children[1]
    children = panel:getChildren()
    for i = 1, #children do
        local child = children[i]
        if child.name == itemName then
            local amount = self:getPreviewItemCount(itemName)
            -- self:setLabelText("LeftTimeValueLabel", amount, child)
            local allAmount = math.max(0, HomeMgr:getAllItemCountByName(itemName))
            if allAmount > 0 then
                self:setLabelText("LeftTimeValueLabel", string.format("%d/%d", amount, allAmount), child)
            else
                self:setLabelText("LeftTimeValueLabel", 0, child)
            end
            break
        end
    end

    self:refreshPreview()
end

function HomePuttingDlg:onShowOffButton(sender, eventType)
    local ctrl = sender:getParent()
    local itemName = ctrl.name
    self:setCtrlVisible("ShowOnButton", true, ctrl)
    self:setCtrlVisible("ShowOffButton", false, ctrl)

    local info = HomeMgr:getFurnitureInfo(itemName)
    if HomeMgr:isFloor(itemName) then
        GameMgr.scene.map:setTileIndex(info.tile_index + 1)
    elseif HomeMgr:isWall(itemName) then
        GameMgr.scene.map:setWallIndex(info.wall_index + 1, true)
    end
end

function HomePuttingDlg:onShowOnButton(sender, eventType)
    local ctrl = sender:getParent()
    local itemName = ctrl.name
    self:setCtrlVisible("ShowOnButton", false, ctrl)
    self:setCtrlVisible("ShowOffButton", true, ctrl)

    local info = HomeMgr:getFurnitureInfo(itemName)
    if HomeMgr:isFloor(itemName) then
        GameMgr.scene.map:setTileIndex(MapMgr:getTileIndex())
    elseif HomeMgr:isWall(itemName) then
        GameMgr.scene.map:setWallIndex(MapMgr:getWallIndex(), true)
    end
end

function HomePuttingDlg:onSpreadButton(sender, eventType)
    DlgMgr:openDlgEx("HomePreviewDlg", self.previews)
end

function HomePuttingDlg:onDownButton(sender, eventType)
    if self.isHideMainPanel then
        return
    end

    local changeHeight = self:getControl("FurniturePanel"):getContentSize().height
    local action = cc.Sequence:create(
        cc.MoveBy:create(0.5, {x = 0, y = -changeHeight - self:getWinSize().oy - self.getWinSize().y}),
        cc.CallFunc:create(function()
            self:setCtrlVisible("UpButton", true)
        end)
    )

    self:getControl("MainPanel"):runAction(action)
    self.isHideMainPanel = true
end

function HomePuttingDlg:onUpButton(sender, eventType)
    if not self.isHideMainPanel then
        return
    end

    local changeHeight = self:getControl("FurniturePanel"):getContentSize().height
    local action = cc.MoveBy:create(0.5, {x = 0, y = changeHeight + self:getWinSize().oy + self.getWinSize().y})
    self:getControl("MainPanel"):runAction(action)

    sender:setVisible(false)
    self.isHideMainPanel = false
end

-- 滑到某一家具并选中
function HomePuttingDlg:scrollToOneItemAndChoose(item, notChoose)
    if not item then
        return
    end

    local itemX = item:getPositionX()

    local listInnerContent = self.listView:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = self.listView:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.width - listViewSize.width

    if itemX > totalHeight then
        itemX = totalHeight
    end

    self.listView:getInnerContainer():setPositionX(-itemX)

    if not notChoose then
        performWithDelay(item, function()
            self:onSelectItem(item)
        end, 0)
    end
end

-- 根据家具名获取对应的家具控件
function HomePuttingDlg:getItemByName(fname)
    local mapName = MapMgr:getCurrentMapName()
    if not mapName then return end
    local mapPos = string.match(mapName, "[^-]*-(.*)")
    local ftype = mapPos .. '-' .. self.curType

    local flist = HomeMgr:getFurnituresByType(ftype)
    local contentLayer = self.listView:getChildByTag(LAYER_TAG)
    local items = contentLayer:getChildren()

    for i = 1, #items do
        if items[i].name == fname then
            return items[i]
        end
    end
end

-- 滑动某一分类到顶部
function HomePuttingDlg:scrollToOneType(radio, num)
    local item = radio:getParent()
    local itemY = item:getPositionY()
    self.choseView:doLayout()
    local listInnerContent = self.choseView:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = self.choseView:getContentSize()

    -- 计算滚动的百分比
    local itemSize = item:getContentSize()
    local totalHeight = innerSize.height - listViewSize.height
    local scrollHeight = itemSize.height * math.floor((num - 1) / 2)
    if scrollHeight > totalHeight then
        scrollHeight = totalHeight
    end

    local percent
    if totalHeight <= 0 then
        percent = 0
    else
        percent = scrollHeight / totalHeight * 100
    end

    self.choseView:scrollToPercentVertical(percent, 0.1, false)
end

function HomePuttingDlg:onDlgOpened(param)
    if param and param[1] then
        local toType = string.match(param[1], ".+-(.+)")
        if not toType then
            toType = param[1]
        end

        local furnitureTypes = self:getFurnituresByHouse()
        for i = 1, #furnitureTypes do
            if furnitureTypes[i] == toType then
                self.radioGroup:selectRadio(i)
                local radio = self.radioGroup:getSelectedRadio()
                self:scrollToOneType(radio, i)
                if param[2] then
                    local item = self:getItemByName(param[2])
                    self:scrollToOneItemAndChoose(item)
                end

                break
            end
        end
    end
end

function HomePuttingDlg:MSG_STORE(data)
    self:markDirty()
    if data.store_type == "furniture_store" and self.curOperCookie then
        if 'number' == type(self.curOperCookie) then
            -- 普通家具
            local furniture = HomeMgr:getOperFurniture(self.curOperCookie)
            if furniture then
                local itemName = furniture:queryBasic("name")
                local items = StoreMgr:getFurnitureByName(itemName)
                if items and #items > 0 then
                    HomeMgr:cmdPut(furniture)
                    self.curOperCookie = nil
                end
            end
        elseif 'string' == type(self.curOperCookie) then
            -- 板砖
            local itemName = self.curOperCookie
            local items = StoreMgr:getFurnitureByName(itemName)
            if items or #items > 0 then
                self:doUsePreview(itemName)
                self.curOperCookie = nil
            end
        end
    end
end

function HomePuttingDlg:MSG_INVENTORY(data)
    self:markDirty()
end

function HomePuttingDlg:MSG_HOUSE_FURNITURE_OPER(data)
    local action = data.action
    if 'place' == action or 'drag' == action then
        self:markDirty()
    end
end

function HomePuttingDlg:MSG_HOUSE_DATA(data)
    self:refreshComformt()
end

return HomePuttingDlg