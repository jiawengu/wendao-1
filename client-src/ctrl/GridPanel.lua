-- GridPanel.lua
-- Created by chenyq Jan/05/2015
-- 格子控件

local GridPanel = class('GridPanel', function()
    return ccui.Layout:create()
end)

local NORMAL_COLOR = cc.c4b(0, 0, 0, 0)
local SELECT_COLOR = cc.c4b(255, 255, 0, 128)
local TEXT_MARGIN = 2
local Level_FONT_SIZE = 19                --等级字体大小19
local NUM_FONT_SIZE = 21                  --数量字体大小21
local OUTLINE_SIZE = 4
local TEXT_OUNTLINE_COLOR = cc.c4b(102, 77, 46, 255)
local NumImg = require('ctrl/NumImg')     --引入NumImg控件(Sprite)

GridPanel.TAG_NUM_IMG_LEVEL = 19          --NUmImg的标签(tag):保持NUmImg_level控件最多只有一个
GridPanel.TAG_NUM_IMG_NUM = 21            --NUmImg的标签(tag):保持NUmImg_num控件最多只有一个

local Grid = class('Grid', function()
    return ccui.Layout:create()
end)

-- data.imgFile     要显示的图片
-- data.grayImg     如果为 true，则表示要置灰图片
-- data.text        图片右下角要显示的文本
-- data.textColor   文本颜色，默认为白色
-- data.level       等级信息
-- data.pos         只有 me 包裹的物品才可设置该信息
-- tMarginRight     额外设置文本的Margin
-- tMarginBottom
-- lMarginLeft      等级显示的margin
-- lMarginTop
-- nFontSize        数量文本的字体大小，默认字体21号
-- lFontSize        等级文本的字体大小，默认字体19号
function Grid:ctor(w, h, data, xMargin, yMargin, tMarginRight, tMarginBottom, lMarginLeft, lMarginTop, nFontSize, lFontSize, isGray, imgSize)

    if tMarginRight == nil then tMarginRight = 0 end
    if tMarginBottom == nil then tMarginBottom = 0 end
    if lMarginLeft == nil then lMarginLeft = 0 end
    if lMarginTop == nil then lMarginTop = 0 end
    if nFontSize == nil then nFontSize = 21 end
    if lFontSize == nil then lFontSize = 19 end

    self:setContentSize(w, h)
    self.w = w
    self.h = h
    self.data = data
    self.xMargin = xMargin
    self.yMargin = yMargin
    self.tMarginRight = tMarginRight
    self.tMarginBottom = tMarginBottom
    self.lMarginLeft = lMarginLeft
    self.lMarginTop = lMarginTop
    self.nFontSize = nFontSize
    self.lFontSize = lFontSize

    self:setTouchEnabled(true)

    -- 设置底色
    self.bg = cc.LayerColor:create(NORMAL_COLOR)
    self.bg:setContentSize(w, h)
    self:addChild(self.bg)

    -- 如果没有数据，则直进行显示，不进行数据的设置
    if nil == data then
        return
    end

    -- 显示底板图片
    local backImg = nil

    if data.imgFile and not data.noItemImg  then
        backImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
    else
        if not isGray then
            backImg = ccui.ImageView:create(ResMgr.ui.bag_no_item_bg_img, ccui.TextureResType.plistType)
        else
            backImg = ccui.ImageView:create(ResMgr.ui.bag_can_not_use_item_img, ccui.TextureResType.plistType)
        end
    end

    --[[
    if isGray then
        gf:grayImageView(backImg)
    end
    --]]

    if not data.imgFile then
        local shadowImg = ccui.ImageView:create(ResMgr.ui.bag_no_item_shadow_img, ccui.TextureResType.plistType)
        shadowImg:setAnchorPoint(0, 0)
        shadowImg:setPosition(4, -10)
        self:addChild(shadowImg)
        shadowImg:setName("shadowImg")
        gf:resetImageView(shadowImg)
        self:cleanFrontImg()
    else
        local shadowImg = self:getChildByName("shadowImg")
        if shadowImg then
            shadowImg:removeFromParent()
        end
    end

    if backImg then
        backImg:setAnchorPoint({0, 0})
        local imgContentSize = backImg:getContentSize()
        backImg:setScale(w / imgContentSize.width, h / imgContentSize.height)
        backImg:setName("backImg")
        self:addChild(backImg)
    end

    if data.imgFile then
        local img = ccui.ImageView:create(data.imgFile, ccui.TextureResType.localType)
        img:setName("gridImg")
        img:setPosition(w / 2, h / 2)
        if imgSize then
            img:ignoreContentAdaptWithSize(false)
            img:setContentSize(imgSize)
        else
            gf:setItemImageSize(img)
        end

        self:addChild(img)

        if data.pos then
            self:updateBagGrid()
        end

        if data.item_polar then
            InventoryMgr:addArtifactPolarImage(img, data.item_polar)
                        -- 法宝共通
            local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_artifact", 0)
            if changeOn and data.pos < 10 then
                InventoryMgr:addArtifactGongtongLogo(img:getParent())
            else
                InventoryMgr:removeArtifactGongtongLogo(img:getParent())
            end
        else
            InventoryMgr:removeArtifactPolarImage(img)
            InventoryMgr:removeArtifactGongtongLogo(img)
        end

        if data.grayImg then
            gf:grayImageView(img)
        end

        if isGray then
            gf:grayImageView(img)
        end

        if data.isBack then
            gf:addEffectForBackEquip(img)
        else
            gf:removeEffectForBackEquip(img)
        end

        if data.isNimbusExhaust then
            gf:addRedEffect(img)
        else
            gf:removeRedEffect(img)
        end
    end

    -- 获取背景图片的ZOrder
    local backImg = self:getChildByName("backImg")
    local layerZOrder = backImg:getLocalZOrder()
    local num = tonumber(data.text)
    if num and num > 1 then
        --在Grid中设置数量为数字图片numImg_num控件的方位和字体的大小
        local numImg = Dialog.setNumImgForPanel(nil, self, ART_FONT_COLOR.NORMAL_TEXT, data.text,
                                 false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        numImg:setLocalZOrder(layerZOrder + 1)
    end

    if data.req_level then
        local numImg = Dialog.setNumImgForPanel(nil, self, ART_FONT_COLOR.NORMAL_TEXT, data.req_level,
            false, LOCATE_POSITION.LEFT_TOP, 19)
        numImg:setLocalZOrder(layerZOrder + 1)
    end

    if data.level then
        local item = InventoryMgr:getItemByPos(data.pos)
        if item and item.item_type == ITEM_TYPE.EQUIPMENT then return end  -- 如果道具类型是装备或未鉴定

        -- 在Grid中设置等级为数字图片numImg控件的方位和字体的大小
        -- 对等级是否达到要求进行设置
        local numGroup = ART_FONT_COLOR.NORMAL_TEXT
        if data.textColor and COLOR3.RED == data.textColor then
            numGroup = ART_FONT_COLOR.RED          --选择是否使用红色
        end
        local numImg = Dialog.setNumImgForPanel(nil, self, numGroup, data.level,
                                                false, LOCATE_POSITION.LEFT_TOP, 19)
        numImg:setLocalZOrder(layerZOrder + 1)
    end

    if data.pos and data.pos <= 10 then
        local magicPath = InventoryMgr:getEquipEffectByPos(data.pos)
        local lastMagic = self:getChildByName("magic")

        if lastMagic then
            lastMagic:removeFromParent()
        end

        if magicPath then
            local magic = ccui.ImageView:create(magicPath, ccui.TextureResType.plistType)
            --local magic = gf:createLoopMagic(magicPath)
            self:addChild(magic)
            local size = self:getContentSize()
            magic:setPosition(size.width / 2, size.height / 2)
            magic:setName("magic")
        end
    end
end

-- 更新背包格子显示数据
function Grid:updateBagGrid()
    local img = self:getChildByName("gridImg")
    if nil == img then return end
    img:removeAllChildren()
    local data = self.data
    local item = InventoryMgr:getItemByPos(data.pos)
    if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        InventoryMgr:addLogoUnidentified(img)
    end

    -- 变身卡相性标记
    if item and item.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
        InventoryMgr:addPolarChangeCard(img, item.name)
    end

    -- 法宝相性标记
    if item and item.item_type == ITEM_TYPE.ARTIFACT then
        if item.item_polar and item.item_polar >= 1 and item.item_polar <= 5 then
            InventoryMgr:addArtifactPolarImage(img, item.item_polar)
        end

        -- 法宝共通
        local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_artifact", 0)
        if changeOn and item.pos < 10 then
            InventoryMgr:addArtifactGongtongLogo(img:getParent())
        else
            InventoryMgr:removeArtifactGongtongLogo(img:getParent())
        end
    end

    -- 融合标识
    if item and InventoryMgr:isFuseItem(item.name) then
        InventoryMgr:addLogoFuse(img)
    else
        InventoryMgr:removeLogoFuse(img)
    end

    if item and InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:removeLogoBinding(img)
        InventoryMgr:addLogoTimeLimit(img)
    elseif item and InventoryMgr:isLimitedItem(item) then
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:addLogoBinding(img)
    else
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:removeLogoBinding(img)
    end

    self:setGridAround(data.isItemAround)
end

-- 设置Grid的背景图片
function Grid:setGridBgImg(bgImgPath)
    local backImg = ccui.ImageView:create(bgImgPath, ccui.TextureResType.plistType)
    local oldImg = self:getChildByName("backImg")

    if oldImg ~= nil then
        oldImg:removeFromParent()
    end

    if backImg then
        backImg:setAnchorPoint({0, 0})
        local imgContentSize = backImg:getContentSize()
        backImg:setScale(self.w / imgContentSize.width, self.h / imgContentSize.height)
        backImg:setName("backImg")
        self:addChild(backImg)
    end

end

-- 设置环绕效果
function Grid:setGridAround(enabled)
    if enabled then
        gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, self, Const.ARMATURE_MAGIC_TAG)
    else
        local ctrl = self:getChildByTag(Const.ARMATURE_MAGIC_TAG)
        if ctrl then
            ctrl:removeFromParent()
        end
    end
end

-- 设置数量文本的字体大小,默认是21
function Grid:setGridNumFontSize(size)
    self.nFontSize = size
end

-- 设置等级文本的字体大小,默认是19
function Grid:setGridLevelFontSize(size)
    self.lFontSize = size
end

function Grid:setBgColor(color)
    if self.bg then
        self.bg:setColor(color)
    end
end

function Grid:setFrontImg()                          -- 设置选中框
    if self.frontImg then return end

    self.frontImg = ccui.ImageView:create(ResMgr.ui.bag_item_select_img, ccui.TextureResType.plistType)
    self.frontImg:setAnchorPoint({0, 0})
    self:addChild(self.frontImg)

    -- 调整选中框显示层级
    local backImg = self:getChildByName("backImg")
    local layerZOrder = backImg:getLocalZOrder()
    self.frontImg:setLocalZOrder(layerZOrder + 3)

    -- 选中框位置微调
    self.frontImg:setPosition(-3, -2)
end

function Grid:cleanFrontImg()
    if nil == self.frontImg then return end

    self.frontImg:removeFromParent(true)
    self.frontImg = nil
end

-- w, h     控件宽高
-- rowNum   行数
-- colNum   列数
-- gridW    格子宽
-- gridH    格子高
-- rowSpace   格子行间隔
-- colunmSpace 列间隔（没传值默认和行间隔相等）
function GridPanel:ctor(w, h, rowNum, colNum, gridW, gridH, rowSpace, colunmSpace, imgSize)
    self:setTouchEnabled(true)
    self:setContentSize(w, h)
    self.rowNum = rowNum
    self.colNum = colNum
    self.gridW = gridW
    self.gridH = gridH
    self.rowSpace = rowSpace
    self.imgSize = imgSize

    if colunmSpace == nil then
        self.colunmSpace = rowSpace
    else
        self.colunmSpace = colunmSpace
    end


    -- 所需宽高
    local needW = (gridW + self.colunmSpace) * colNum - self.colunmSpace
    local needH = (gridH + self.rowSpace) * rowNum - self.rowSpace

    self.offsetX = 0
    self.offsetY = 0

    if needW < w then
        self.offsetX = (w - needW) / 2
    end

    if needH < h then
        self.offsetY = (h - needH) / 2
    end
end

-- data.count        数据个数
-- data[i].imgFile   第 i 个数据对应的图片
-- data[i].grayImg   如果为 true，则表示要置灰图片
-- data[i].text      第 i 个数据在图片右下角要显示的文本
-- data[i].textColor 文本颜色，默认为白色
-- data[i].level     等级信息
-- data[i].pos       只有 me 包裹的物品才可设置该信息
-- clickCallback     点击格子的回调函数，参数为数据索引和对应的对象sender
function GridPanel:setData(data, startIndex, clickCallback, isGray)
    self.grids = {}
    self.clickCallback = clickCallback
    local contentSize = self:getContentSize()
    local x, y = self.offsetX, contentSize.height - self.offsetY
    local idx = startIndex
    for i = 1, self.rowNum do
        local left = x
        local top = y
        for j = 1, self.colNum do
            local isGrayByIdx
            if isGray and type(isGray) == "table" then
                -- isGray单位为格子，而非整页
                -- 允许传入的isGray是布尔数组，代表各grid的isGray属性
                isGrayByIdx = isGray[idx]
            else
                isGrayByIdx = isGray
            end

            local grid = Grid.new(
                                  self.gridW, self.gridH, data[idx],
                                  self.colunmSpace, self.rowSpace,
                                  self.textMarginRight, self.textMarginBottom, self.levelMarginLeft,
                                  self.levelMarginTop, self.nFontSize, self.lFontSize, isGrayByIdx, self.imgSize
                                  )
            grid:setAnchorPoint(0, 1)

            -- 设置于上边框的距离
            if self.top == nil then self.top = 0 end
            top = y - self.top
            grid:setPosition(left, top - 1.5)
            self:addChild(grid)
            left = left + self.gridW + self.colunmSpace
            self.grids[(i - 1) * self.colNum + j] = grid

            if idx <= data.count then
                -- 此处需要用局部变量 dataIdx 缓存 idx 的值，否则回调函数中 dataIdx 会始终为循环结束后 idx 的值
                local dataIdx = idx
                grid:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:onClicked((i - 1) * self.colNum + j, dataIdx, sender)
                    end
                end)

                idx = idx + 1
            end
        end

        y = y - self.gridH - self.rowSpace
    end
end

-- 与GridPanel:setData()差别增加了长按。仅在战斗中选择道具对话框需要长按
function GridPanel:setDataLongClick(data, startIndex, clickCallback, isGray, longClickCallBack)
    self.grids = {}
    self.clickCallback = clickCallback
    self.longClickCallback = longClickCallBack
    local contentSize = self:getContentSize()
    local x, y = self.offsetX, contentSize.height - self.offsetY
    local idx = startIndex
    for i = 1, self.rowNum do
        local left = x
        local top = y
        for j = 1, self.colNum do
            local grid = Grid.new(
                self.gridW, self.gridH, data[idx],
                self.colunmSpace, self.rowSpace,
                self.textMarginRight, self.textMarginBottom, self.levelMarginLeft,
                self.levelMarginTop, self.nFontSize, self.lFontSize, isGray
            )
            grid:setAnchorPoint(0, 1)

            -- 设置于上边框的距离
            if self.top == nil then self.top = 0 end
            top = y - self.top
            grid:setPosition(left, top - 1.5)
            self:addChild(grid)
            left = left + self.gridW + self.colunmSpace
            self.grids[(i - 1) * self.colNum + j] = grid

            if idx <= data.count then
                -- 此处需要用局部变量 dataIdx 缓存 idx 的值，否则回调函数中 dataIdx 会始终为循环结束后 idx 的值
                local dataIdx = idx

                gf:bindLongTouchListener(grid,
                    function()
                        longClickCallBack(dataIdx, grid)
                        -- huangwx不需要选中光效
                 --       self:setSelectedGridByIndex((i - 1) * self.colNum + j)
                    end,
                    function()
                        clickCallback( dataIdx, grid)
                  --      self:setSelectedGridByIndex((i - 1) * self.colNum + j)
                    end)
                idx = idx + 1
            end
        end

        y = y - self.gridH - self.rowSpace
    end
end

-- 设置更新单个grid的数据
function GridPanel:setGridData(data, pos, w, h, isGray)

    if w ~= nil then
        self.w = w
    end

    if h ~= nil then
        self.h = h
    end

    if self.tMarginRight == nil then self.tMarginRight = 0 end
    if self.tMarginBottom == nil then self.tMarginBottom = 0 end
    if self.xMargin == nil then self.xMargin = 0 end
    if self.yMargin == nil then self.yMargin = 0 end
    if self.lMarginLeft == nil then self.lMarginLeft = 0 end
    if self.lMarginTop == nil then self.lMarginTop = 0 end

    if data == nil then
        self.grids[pos]:removeFromParent()
        self.grids[pos] = nil
    end

    if self.grids[pos] ~= nil then
        self.grids[pos].data = data

        -- 显示底板图片
        local backImg = nil

        local oldBackImg = self.grids[pos]:getChildByName("backImg")
        local layerZOrder = oldBackImg:getLocalZOrder()

        if data.imgFile and not data.noItemImg then
            backImg = ccui.ImageView:create(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
        else
            if not isGray then
                backImg = ccui.ImageView:create(ResMgr.ui.bag_no_item_bg_img, ccui.TextureResType.plistType)
            else
                backImg = ccui.ImageView:create(ResMgr.ui.bag_can_not_use_item_img, ccui.TextureResType.plistType)
            end
        end

        --[[
        if isGray then
            gf:grayImageView(backImg)
        end
        --]]
        if not data.imgFile then
            local shadowImg = self.grids[pos]:getChildByName("shadowImg")
            if not shadowImg then
                shadowImg = ccui.ImageView:create(ResMgr.ui.bag_no_item_shadow_img, ccui.TextureResType.plistType)
                shadowImg:setAnchorPoint({0, 0})
                shadowImg:setPosition(4, -10)
                shadowImg:setName("shadowImg")
                self.grids[pos]:addChild(shadowImg)
                gf:resetImageView(shadowImg)
                self.grids[pos]:cleanFrontImg()
            end
        else
            local shadowImg = self.grids[pos]:getChildByName("shadowImg")
            if shadowImg then
                shadowImg:removeFromParent()
            end
        end

        backImg:setAnchorPoint({0, 0})
        backImg:setLocalZOrder(layerZOrder)
        self.grids[pos]:addChild(backImg)
        oldBackImg:removeFromParent()
        backImg:setName("backImg")

        local img = self.grids[pos]:getChildByName("gridImg")

        if data.imgFile then
            if img ~= nil then
                img:removeAllChildren()
                img:loadTexture(data.imgFile, ccui.TextureResType.localType)
                gf:setItemImageSize(img)

                if data.pos then
                    self.grids[pos]:updateBagGrid()
                end

                if data.grayImg then
                    gf:grayImageView(img)
                end
                if isGray then
                    gf:grayImageView(img)
                end

                layerZOrder = layerZOrder + 1
                img:setLocalZOrder(layerZOrder)
            else
                local img = ccui.ImageView:create(data.imgFile, ccui.TextureResType.localType)
                img:setName("gridImg")
                gf:setItemImageSize(img)

                img:setPosition(self.w / 2, self.h / 2)
                self.grids[pos]:addChild(img)

                if data.pos then
                    self.grids[pos]:updateBagGrid()
                end

                if data.grayImg then
                    gf:grayImageView(img)
                end
                if isGray then
                    gf:grayImageView(img)
                end
            end
        else
            if img ~= nil then
                img:removeFromParent()
            end
        end
        --在Grid中更新数量为数字图片numImg控件的方位和字体的大小
        local num = tonumber(data.text)
        if num and num > 1 then
            --在Grid中更新数量为数字图片numImg_num控件的方位和字体的大小
            local numImg = Dialog.setNumImgForPanel(nil, self.grids[pos], ART_FONT_COLOR.NORMAL_TEXT,
                                                    num, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
            numImg:setVisible(true)
            numImg:setLocalZOrder(layerZOrder + 1)
        else
            -- data.text取不到1，这里设置1，并隐藏
            local numImg = Dialog.setNumImgForPanel(nil, self.grids[pos], ART_FONT_COLOR.NORMAL_TEXT,
                                                    1, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
            numImg:setVisible(false)
        end

        --在Grid中更新等级为数字图片numImg控件的方位和字体的大小
        --对等级是否达到要求进行设置
        if data.req_level then
            local numImg = Dialog.setNumImgForPanel(nil, self.grids[pos], ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
            numImg:setLocalZOrder(layerZOrder + 1)
        elseif data.level then
            local item = InventoryMgr:getItemByPos(data.pos)
            if item and item.item_type == ITEM_TYPE.EQUIPMENT then return end
            local numGroup = ART_FONT_COLOR.NORMAL_TEXT
            if data.textColor and COLOR3.RED == data.textColor then
                numGroup = ART_FONT_COLOR.RED                    -- 选择是否使用红色
            end
            local numImg = Dialog.setNumImgForPanel(nil, self.grids[pos], numGroup, data.level,
                                                    false, LOCATE_POSITION.LEFT_TOP, 19)
            numImg:setLocalZOrder(layerZOrder + 1)
        else
            -- data.level取不到1，这里设置1，并隐藏
            local numImg = Dialog.setNumImgForPanel(nil, self.grids[pos], ART_FONT_COLOR.NORMAL_TEXT, 1,
                                                    false, LOCATE_POSITION.LEFT_TOP, 19)
            numImg:setVisible(false)
        end
    end
end

-- 设置与上边框的距离 By Chang_back
function GridPanel:setGridTop(top)
    self.top = top
end

-- 设置grid中文本的margin
function GridPanel:setTextMargin(right, bottom)
    self.textMarginRight = right
    self.textMarginBottom = bottom
end

-- 设置grid中等级的margin
function GridPanel:setLevelMargin(left, top)
    self.levelMarginLeft = left
    self.levelMarginTop = top
end

-- 设置Grid中数量文本的字体大小
function GridPanel:setGridNumFontSize(size)
    self.nFontSize = size
end

-- 设置Grid中等级文本的字体大小
function GridPanel:setGridLevelFontSize(size)
    self.lFontSize = size
end

function GridPanel:onClicked(gridIdx, dataIdx, sender)
    self.clickCallback(dataIdx, sender)
    self:setSelectedGridByIndex(gridIdx)

end

-- 设置选中的格子
function GridPanel:setSelectedGrid(row, col)
    return self:setSelectedGridByIndex((row - 1) * self.colNum + col)
end

-- 设置选中的格子
function GridPanel:setSelectedGridByIndex(gridIdx)
    self:clearSelected()
    local grid = self.grids[gridIdx]
    if not self.unShowGridSeleted then
        grid:setFrontImg()
    end
    return grid
end

-- 环绕光效
function GridPanel:setItemAround(gridIdx, enable)
    local grid = self:getGridByIndex(gridIdx)
    if not grid then return end
    grid:setGridAround(enable)
end

-- 获取格子
function GridPanel:getGridByIndex(gridIdx)
    return self.grids[gridIdx]
end

-- 清除选中标记
function GridPanel:clearSelected()
    for _, grid in pairs(self.grids) do
        grid:cleanFrontImg()
    end
end

function GridPanel:setSelectAbled(abled)
    self.unShowGridSeleted = not abled
end

return GridPanel

