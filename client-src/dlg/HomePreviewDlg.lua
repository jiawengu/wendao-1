-- HomePreviewDlg.lua
-- Created by sujl, Jan/20/2017
-- 预览界面

local HomePreviewDlg = Singleton("HomePreviewDlg", Dialog)
local FurniturePoint = require(ResMgr:getCfgPath("FurniturePoint.lua"))

local TAG_HOME          = 100           -- 小地图上的地表
local LAYER_HOME        = 10            -- 地表
local TAG_CARPET        = 200           -- 小地图上的家具
local LAYER_CARPET      = 20            -- 家具
local TAG_FURNITURE     = 300           -- 小地图上的家具
local LAYER_FURNITURE   = 30            -- 家具

local HOUSE_FURITURES = { CHS[2000320] }
local VESTIBULE_FURITURES = { CHS[2000324], CHS[2000325] }
local BACKYARD_FURITURES = { }

function HomePreviewDlg:init(args)
    self:bindListener("CostImage", self.onClickCost, "HavePanel")
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("CompareButton", self.onCompareButton)

    self.listView1 = self:getControl("ListScrollView_1", nil, "TypePanel_1")
    self:bindListener("ImagePanel_0_0", self.onItemClick1, self.listView1)
    self.imageItem1 = self:getControl("ImagePanel_0_0", nil, self.listView1)
    self.imageItem1:retain()
    self.imageItem1:setTouchEnabled(true)
    self.choseIImage1 = self:getControl("ChoseImage", nil, self.imageItem1)
    self.choseIImage1:retain()
    self.choseIImage1:removeFromParent()
    self.listView1:removeAllChildren()
    self.listView2 = self:getControl("ListScrollView_1", nil, "TypePanel_2")
    self:bindListener("ImagePanel_0_0", self.onItemClick2, self.listView2)
    self.imageItem2 = self:getControl("ImagePanel_0_0", nil, self.listView2)
    self.imageItem2:retain()
    self.imageItem2:setTouchEnabled(true)
    self.choseIImage2 = self:getControl("ChoseImage", nil, self.imageItem2)
    self.choseIImage2:retain()
    self.choseIImage2:removeFromParent()
    self.listView1:removeAllChildren()

    local tile_index = GameMgr.scene.map:getTileIndex()
    local wall_index = GameMgr.scene.map:getWallIndex()
    for i = 1, #args do
        if args[i].tile_index then
            tile_index = args[i].tile_index + 1
        elseif args[i].wall_index then
            wall_index = args[i].wall_index + 1
        end
    end

    self.selItem = {}

    self:bindScorllPanelEventListener("MapImage")

    -- 显示预览信息
    self.contentSize = self:getControl("MapImage", nil, "MapPanel"):getContentSize()

    -- 记录一下原始尺寸用于计算缩放
    self.oriW = self.contentSize.width
    self.oriH = self.contentSize.height

    self:showPreview(true)

    -- 初始化数据
    self:initAllList(tile_index, wall_index)

    self:MSG_UPDATE()
    self:refreshCost()
    self:refreshUseButton()

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_HOUSE_UPDATE_STYLE")
end

function HomePreviewDlg:cleanup()
    self:releaseCloneCtrl("imageItem1")
    self:releaseCloneCtrl("imageItem2")
    self:releaseCloneCtrl("choseIImage1")
    self:releaseCloneCtrl("choseIImage2")
    self.selItem = {}
    self.shelterLayer = nil
    self.obstacle = nil
    self.doUseCount = nil
end

function HomePreviewDlg:bindScorllPanelEventListener(ctrlName, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    local ctrlName = ctrl:getName()
    local startX, startY = ctrl:getPosition()

    -- 事件监听
    local lastTouchPos
    ctrl:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
        elseif eventType == ccui.TouchEventType.moved then
            if not lastTouchPos then return end
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y
            local x, y = ctrl:getPosition()
            ctrl:setPosition(self:adjustXY(ctrl, x + offsetX, y + offsetY))
            lastTouchPos = touchPos
        elseif eventType == ccui.TouchEventType.ended then
            lastTouchPos = nil
        end
    end)
end

function HomePreviewDlg:adjustXY(ctrl, x, y)
    local startX, startY = self.oriW/2, self.oriH / 2
    local ctrlSize = ctrl:getContentSize()
    local scaleX = ctrl:getScaleX()
    local scaleY = ctrl:getScaleY()
    x = math.min(math.max(-(ctrlSize.width * scaleX - self.oriW) / 2 + startX, x), (ctrlSize.width * scaleX - self.oriW) / 2 + startX)
    y = math.min(math.max(-(ctrlSize.height * scaleY - self.oriH) / 2 + startY, y), (ctrlSize.height * scaleY - self.oriH) / 2 + startY)
    return x, y
end

function HomePreviewDlg:refreshCost()
    local info
    local total = 0
    local allAmount
    local pCost
    for k, v in pairs(self.selItem) do
        allAmount = math.max(0, HomeMgr:getAllItemCountByName(v))
        if allAmount > 0 then
            pCost = 0
        else
            info = HomeMgr:getFurnitureInfo(v)
            pCost = info.purchase_cost
        end
        total = total + pCost * self:getUnit()
    end

    local priceStr, color = gf:getArtFontMoneyDesc(total)
    self:setNumImgForPanel("GoldValuePanel", color, priceStr, false, LOCATE_POSITION.CENTER, 21, "HavePanel")
end

function HomePreviewDlg:getUnit()
    return 10000
end

function HomePreviewDlg:getMeMoney()
    if 1 == self.costType then
        return Me:queryBasicInt("cash")
    else
        return Me:queryBasicInt("gold_coin")
    end
end

function HomePreviewDlg:initAllList(tile_index, wall_index)
    local types = self:getFurnitureTypes()
    for i = 1, #types do
        local itemPanel = self:getControl(string.format("TypePanel_%d", i))
        itemPanel:setVisible(true)
        self:setLabelText("NameLabel", string.format(CHS[2100104], types[i]), itemPanel)
        self:initList(i, types[i], tile_index, wall_index)
    end

    for i = #types + 1, 2 do
        self:getControl(string.format("TypePanel_%d", i)):setVisible(false)
    end
end

-- 初始化地砖类型
function HomePreviewDlg:initList(index, ftype, tile_index, wall_index)
    local mapName = MapMgr:getCurrentMapName()
    if not mapName then return end
    local mapPos = string.match(mapName, "[^-]*-(.*)")
    ftype = mapPos .. '-' .. ftype
    local list = HomeMgr:getFurnituresByType(ftype)
    HomeMgr:sortFurnitureList(list)
    local listView = self[string.format("listView%d", index)]
    if not listView then return end
    listView:removeAllChildren()

    local imageItem = self[string.format("imageItem%d", index)]
    if not imageItem then return end

    local item
    local posX, posY = imageItem:getPosition()
    local itemSize = imageItem:getContentSize()
    local curMap = GameMgr.scene.map
    tile_index = tile_index or curMap:getTileIndex()
    wall_index = wall_index or curMap:getWallIndex()
    for i = 1, #list do
        item = imageItem:clone()
        item.name = list[i].name
        self:setItemData(item, list[i])
        if list[i].tile_index and tile_index == list[i].tile_index + 1 then
            (self[string.format("onItemClick%d", index)])(self, item)
        elseif list[i].wall_index and wall_index == list[i].wall_index + 1 then
            (self[string.format("onItemClick%d", index)])(self, item)
        end
        listView:pushBackCustomItem(item)
    end
end

-- 获取地面类型
function HomePreviewDlg:getFurnitureTypes()
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

function HomePreviewDlg:setItemData(item, data)
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

function HomePreviewDlg:refreshUseButton()
    local same = true
    local item
    for k, v in pairs(self.selItem) do
        item = HomeMgr:getFurnitureInfo(v)
        if item.wall_index then
            same = same and (MapMgr:getWallIndex() - 1 == item.wall_index)
        elseif item.tile_index then
            same = same and (MapMgr:getTileIndex() - 1 == item.tile_index)
        end
    end
    self:setCtrlEnabled("UseButton", not same)
    self:setCtrlEnabled("CompareButton", not same)
end

function HomePreviewDlg:selectItem(index, itemName)
    self.isOff = nil
    self.selItem[index] = itemName
    self:refreshCost()
    self:refreshUseButton()
    self:refreshPreview()
    DlgMgr:sendMsg("HomePuttingDlg", "addPreview", HomeMgr:getFurnitureInfo(itemName))  -- 更新界面
    self:drawHomeMap(self.map_id, GameMgr.scene.map:getTileIndex(), GameMgr.scene.map:getWallIndex())
end

-- 刷新预览
function HomePreviewDlg:refreshPreview()
    for k, v in pairs(self.selItem) do
        local info = HomeMgr:getFurnitureInfo(v)
        if not info then return end

        if info.tile_index then
            GameMgr.scene.map:setTileIndex(info.tile_index + 1)
        elseif info.wall_index then
            GameMgr.scene.map:setWallIndex(info.wall_index + 1, true)
        end
    end
end

-- 购买道具
function HomePreviewDlg:doBuyGoods(toBuys)
    local info
    for i = 1, #toBuys do
        info = HomeMgr:getFurnitureInfo(toBuys[i])
        gf:CmdToServer('CMD_HOUSE_BUY_FURNITURE', { furniture_id = info.icon, num = 1, cost = info.purchase_cost * self:getUnit()})
    end

    self.toBuys = toBuys
end

-- 使用道具
function HomePreviewDlg:doUseGoods(toUses)
    if not toUses or #toUses <= 0 then return end

    local useInventory

    local strs = {}
    local posList = {}
    local itemName
    for i = 1, #toUses do
        itemName = toUses[i]
        local items = StoreMgr:getFurnitureByName(itemName)
        if not items or #items <= 0 then
            items = InventoryMgr:getItemByName(itemName)
            table.insert(strs, string.format("#R%s#n", itemName))
            table.insert(posList, items[1].pos)
        else
            table.insert(posList, items[1].pos)
        end
    end

    local function _doUseGoods()
        for i = 1, #posList do
            gf:CmdToServer('CMD_HOUSE_PLACE_FURNITURE', { furniture_pos = posList[i], x = 0, y = 0, flip = 0, bx = 0, by = 0, cookie = 0 })
        end

        self.doUseCount = #posList
    end

    if #strs > 0 then
        gf:confirm(string.format(CHS[2100105], table.concat(strs, CHS[2100106])), function()
            _doUseGoods()
        end)
    else
        _doUseGoods()
    end
end

function HomePreviewDlg:showPreview(resetPos)
    local mapId = MapMgr:getCurrentMapId()
    self.map_id = mapId
    self:drawHomeMap(mapId, GameMgr.scene.map:getTileIndex(), GameMgr.scene.map:getWallIndex(), resetPos)
    self:loadShelter()
    self:drawFurnitures(HomeMgr:getFurnitures())
end

function HomePreviewDlg:drawHomeMap(mapId, tileIndex, wallIndex, resetPos)
    local info = require(ResMgr:getMapInfoPath(mapId))
    if not info then return end
    local mapSprite = self:getControl("MapImage", nil, "MapPanel")
    -- mapSprite:removeAllChildren()
    mapSprite:removeChildByTag(TAG_HOME)
    local destLayer = cc.Layer:create()
    mapSprite:addChild(destLayer, LAYER_HOME, TAG_HOME)
    local width = info.source_width or 0
    local height = info.source_height or 0
    local scale = 1 / info.scale * 0.42
    mapSprite:setContentSize(cc.size(width * Const.MAP_SCALE * 0.42, height  * Const.MAP_SCALE * 0.42))
    self.contentSize = mapSprite:getContentSize()

    for k, v in pairs(info.blocks) do
        local path = ResMgr:getMapBlockPathByName(mapId, info.blocks[k], tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = string.match(k, "(-?%d+)_(-?%d+)")
        x = tonumber(x)
        y = tonumber(y)
        x, y = self:mapSpaceToSmallMap(x, height - y, mapId)
        sprite:setAnchorPoint(cc.p(0,1))
        sprite:setPosition(x, y)
        sprite:setScale(scale)
        sprite:setName(k)
        destLayer:addChild(sprite)
    end

    for i = #info.objs, 1, -1 do
        local obj = info.objs[i]
        local path = ResMgr:getMapBlockPathByName(mapId, obj.name, tileIndex, wallIndex)
        local texture = cc.Director:getInstance():getTextureCache():addImage(path)
        local sprite = cc.Sprite:createWithTexture(texture)
        local x, y = tonumber(obj.x), tonumber(obj.y)
        sprite:setAnchorPoint(cc.p(0,1))
        x, y = self:mapSpaceToSmallMap(x, height - y, mapId)
        sprite:setPosition(x, y)
        sprite:setScale(scale)
        if obj.flip then
            sprite:setFlippedX(true)
        end
        sprite:setName(k)
        destLayer:addChild(sprite)
    end

    if resetPos then
        mapSprite:setScaleX(1)
        mapSprite:setScaleY(1)
        mapSprite:setVisible(true)
        local panelSize = self:getControl("ScrollPanel"):getContentSize()
        mapSprite:setPosition(panelSize.width / 2, panelSize.height / 2)
    end
    self:checkButtonState(1)

    return mapSprite
end

function HomePreviewDlg:drawFurnitures(furnitures)
    local mapLayer = self:getControl("MapImage", nil, "MapPanel")
    mapLayer:removeChildByTag(TAG_FURNITURE)
    local furnitureLayer = cc.Layer:create()
    mapLayer:addChild(furnitureLayer, LAYER_FURNITURE, TAG_FURNITURE)
    mapLayer:removeChildByTag(TAG_CARPET)
    local carpetLayer = cc.Layer:create()
    mapLayer:addChild(carpetLayer, LAYER_CARPET, TAG_CARPET)

    local furnitures = HomeMgr:getFurnitures()
    local mapSize = GameMgr.scene.map:getContentSize()
    local scale = cc.p(self.contentSize.width / mapSize.width, self.contentSize.height / mapSize.height)
    for _, v in pairs(furnitures) do
        if HomeMgr:getPutLayerByFurniture(v) == "carpet" then
            local sp
            local name = v:queryBasic("name")
            local info = HomeMgr:getFurnitureInfo(name)
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, scale)
            else
                sp = self:createImageFurniture(v, scale)
            end

            carpetLayer:addChild(sp)
        end
    end
    for _, v in pairs(furnitures) do
        if HomeMgr:getPutLayerByFurniture(v) ~= "carpet" then
            local sp
            local name = v:queryBasic("name")
            local info = HomeMgr:getFurnitureInfo(name)
            if info.dirs and info.dirs > 1 then
                sp = self:createAnimateFurniture(v, scale)
            else
                sp = self:createImageFurniture(v, scale)
            end

            furnitureLayer:addChild(sp)
        end
    end
end

-- 创建骨骼动画家具
function HomePreviewDlg:createAnimateFurniture(v, scale)
    local x, y = self:mapSpaceToSmallMap(v.curX, v.curY, self.map_id)
    local icon = v:queryBasicInt("icon")
    local dir = v:queryBasicInt("dir")
    local furn = ArmatureMgr:createFurnitureArmature(icon)
    furn:setScale(scale.x, scale.y)
    furn:setPosition(x, y)
    furn:setLocalZOrder(v:getZOrder(-v.curY))
    furn:getAnimation():play(string.format("%5d_%d", icon, dir), -1, 0)
    return furn
end

-- 创建图片类型的家具
function HomePreviewDlg:createImageFurniture(v, scale)
    local x, y = self:mapSpaceToSmallMap(v.curX, v.curY, self.map_id)
    local icon = v:queryBasicInt("icon")
    local path = self:getSmallMapFurniture(icon)
    local sp = cc.Sprite:create(path)
    sp:setScale(scale.x, scale.y)
    sp:setFlippedX(v:isFlip())
    sp:setPosition(x, y)
    sp:setLocalZOrder(v:getZOrder(-v.curY))
    sp:setOpacity(v:isShelter(gf:convertToMapSpace(v.curX, v.curY)) and 0x7f or 0xff)
    return sp
end

function HomePreviewDlg:loadShelter()
    local path = ResMgr:getMapObstaclePath(self.map_id)
    local obstacle = ccexp.TMXTiledMap:create(path)
    if nil == obstacle then return end

    if self.obstacle then
        self.obstacle:removeFromParent()
    end
    self.obstacle = obstacle
    self.obstacle:setVisible(false)
    self.root:addChild(self.obstacle)
    local shelterLayer = obstacle:getLayer(string.format("shelter%d", GameMgr.scene.map:getWallIndex()))
    if not shelterLayer then
        shelterLayer = obstacle:getLayer("shelter")
    end

    self.shelterLayer = shelterLayer
    return shelterLayer
end

-- 是否遮挡点
function HomePreviewDlg:isShelter(mapX, mapY)
    if nil == self.shelterLayer then return end
    return self.shelterLayer:getTileGIDAt(cc.p(mapX, mapY)) ~= 0
end

-- 获取小地图家具文件
function HomePreviewDlg:getSmallMapFurniture(icon)
    return string.format("furniture/%05d.png", icon)
end

-- 大地图坐标转化成小地图坐标
function HomePreviewDlg:mapSpaceToSmallMap(x, y, mapId)
    local mapSize

    local info = require(ResMgr:getMapInfoPath(mapId))
    if nil == info then
        return 0, 0
    end

    local width = info.source_width or 0
    local height = info.source_height or 0

    local mapY = y / height
    local mapX = x / width

    return mapX * self.contentSize.width, mapY * self.contentSize.height
end

-- 获取小地图文件
function HomePreviewDlg:getSmallMapFile(map_id, floor_index, wall_index)
    return string.format("maps/smallMaps/%05d_%02d_%02d.jpg", map_id, floor_index + 1, wall_index + 1)
end

function HomePreviewDlg:setPreviewScale(scale)
    local ctrl = self:getControl("MapImage", nil, "MapPanel")
    ctrl:setScaleX(scale)
    ctrl:setScaleY(scale)
    local x, y = ctrl:getPosition()
    x, y = self:adjustXY(ctrl, x, y)
    ctrl:setPosition(x, y)
end

function HomePreviewDlg:checkButtonState(scale)
    self:setCtrlEnabled("AddButton", scale < 1.5)
    self:setCtrlEnabled("ReduceButton", scale > 1)
end

function HomePreviewDlg:onItemClick1(sender, eventType)
    self.choseIImage1:removeFromParent()
    sender:addChild(self.choseIImage1)
    self:selectItem(1, sender.name)
end

function HomePreviewDlg:onItemClick2(sender, eventType)
    self.choseIImage2:removeFromParent()
    sender:addChild(self.choseIImage2)
    self:selectItem(2, sender.name)
end

function HomePreviewDlg:onClickCost(sender, eventType)
    gf:showBuyCash()
end

function HomePreviewDlg:onUseButton(sender, eventType)
    -- 是否存在未拥有家具
    local toBuys = {}
    local toUses = {}
    local info
    for k, v in pairs(self.selItem) do
        info = HomeMgr:getFurnitureInfo(v)
        if (info.tile_index and info.tile_index + 1 ~= MapMgr:getTileIndex())
            or (info.wall_index and info.wall_index + 1 ~= MapMgr:getWallIndex()) then
            local amount = HomeMgr:getItemCountByName(v)
            if amount <= 0 then
                table.insert(toBuys, v)
            end

            table.insert(toUses, v)
        end
    end

    if #toUses <= 0 then return end

    if #toBuys > 0 then
        -- 需要购买
        local strs = {}
        local total = 0
        for i = 1, #toBuys do
            info = HomeMgr:getFurnitureInfo(toBuys[i])
            total = total + info.purchase_cost * self:getUnit()
            table.insert(strs, string.format("#R%s#n", toBuys[i]))
        end

        self.toUses = toUses
        local str = table.concat(strs, CHS[2100106])
        gf:confirm(string.format(CHS[2100107], str, gf:getMoneyDesc(total)), function()
            if not gf:checkEnough("cash", total) then return end

            -- 安全锁判断
            if self:checkSafeLockRelease("doBuyGoods", toBuys) then
                return
            end

            self:doBuyGoods(toBuys)
        end)
    else
        self:doUseGoods(toUses)
    end
end

function HomePreviewDlg:onAddButton(sender, eventType)
    local mapImage = self:getControl("MapImage", nil, "MapPanel")
    local size = mapImage:getContentSize()
    -- local scale  = size.width / self.contentSize.width
    local scale = math.floor(mapImage:getScaleX() * 10 + 0.5) / 10
    if scale < 1.5 then
        scale  = math.min(scale + 0.1, 1.5)
    end
    self:setPreviewScale(scale)
    self:checkButtonState(scale)
end

function HomePreviewDlg:onReduceButton(sender, eventType)
    local mapImage = self:getControl("MapImage", nil, "MapPanel")
    local size = mapImage:getContentSize()
    --local scale  = size.width / self.contentSize.width
    local scale = math.floor(mapImage:getScaleX() * 10 + 0.5) / 10
    if scale > 1 then
        scale  = math.max(scale - 0.1, 1)
    end
    self:setPreviewScale(scale)
    self:checkButtonState(scale)
end

function HomePreviewDlg:onCompareButton(sender, eventType)
    local tile_index, wall_index
    if not self.isOff then
        tile_index = MapMgr:getTileIndex()
        wall_index = MapMgr:getWallIndex()
    else
        -- self:refreshPreview()
        for k, v in pairs(self.selItem) do
            local info = HomeMgr:getFurnitureInfo(v)
            if not info then return end

            if info.tile_index then
                tile_index = info.tile_index + 1
            elseif info.wall_index then
                wall_index = info.wall_index + 1
            end
        end
    end

    self.isOff = not self.isOff
    self:drawHomeMap(self.map_id,tile_index, wall_index)
end

function HomePreviewDlg:MSG_STORE(data)
    if data.store_type == "furniture_store" then
        if self.toBuys and #self.toBuys > 0 then
            local itemName
            for i = 1, #self.toBuys do
                itemName = self.toBuys[i]
                local items = StoreMgr:getFurnitureByName(itemName)
                if not items or #items <= 0 then return end
            end

            self.toBuys = nil
            if self.toUses then
                self:doUseGoods(self.toUses)
                self.toUses = nil
            end
        end

        self:initAllList()
    end
end

function HomePreviewDlg:MSG_HOUSE_UPDATE_STYLE(data)
    -- WDSY 使用围墙成功后，需要重新绘制预览地图上的家具，刷一下半透明信息
    self:drawFurnitures(HomeMgr:getFurnitures())
    
    if self.doUseCount then
        self.doUseCount = self.doUseCount - 1
        if self.doUseCount <= 0 then
            gf:ShowSmallTips(CHS[2100108])
            self.doUseCount = nil
        end
    end

    -- 清除摆放界面的预览数据
    DlgMgr:sendMsg("HomePuttingDlg", "clearPreview")
    self:refreshUseButton()
end

function HomePreviewDlg:MSG_UPDATE(data)
    local priceStr, color = gf:getArtFontMoneyDesc(Me:queryBasicInt("cash"))
    self:setNumImgForPanel("GoldValuePanel", color, priceStr, false, LOCATE_POSITION.CENTER, 21, "CostPanel")
end

return HomePreviewDlg