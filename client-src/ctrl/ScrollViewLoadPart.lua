-- ScrollViewLoadPart.lua
-- Created by huangzz, Jan/30/2019
-- 滑动框扩展
-- 实时刷新，只加载视口范围内的条目，超出一定范围不加载

local ScrollViewLP = class('ScrollViewLoadPart')

local CONTENTLAYER_TAG = 9999

function ScrollViewLP:ctor(dlg, scrollView, cloneCtrl, func, col, lineSpace, columnSpace, startX, startY)
    self.dlg = dlg
    self.cloneCtrl = cloneCtrl
    self.col = col
    self.lineSpace = lineSpace or 0
    self.columnSpace = columnSpace or 0
    self.startX = startX or 0
    self.startY = startY or 0
    self.cellViewCallback = func

    if type(scrollView) == "string" then
        scrollView = dlg:getControl(scrollView)
    end

    self.scrollView = scrollView
    self.usingCells = {}
    self.notUseCells = {}

    local size = scrollView:getContentSize()
    self.loadLine = math.ceil((size.height / 2) / (cloneCtrl:getContentSize().height + lineSpace)) + 1

    self.scrollView:addEventListener(function(sender, eventType) self:onScrollView(sender, eventType) end)
end

function ScrollViewLP:setCellViewCallBack(callback)
    self.cellViewCallback = callback
end

-- 设置滑动事件回调
function ScrollViewLP:setEventCallback(callback)
    self.eventCallback = callback
end

-- 设置是否停止处理滑动回调
function ScrollViewLP:setNotCallScrollView(flag)
    self.notCallScrollView = flag
end

function ScrollViewLP:onScrollView(sender, eventType)
    if self.notCallScrollView then
        return
    end

    local scrollViewCtrl = sender
    local listInnerContent = scrollViewCtrl:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local scrollViewSize = scrollViewCtrl:getContentSize()

    local contentLayer = scrollViewCtrl:getChildByTag(CONTENTLAYER_TAG)
    if not contentLayer then
        return
    end

    -- 计算滚动的百分比
    local innerPosY = math.floor(listInnerContent:getPositionY() + 0.5)
    local totalHeight = innerSize.height - scrollViewSize.height

    if self.data and #self.data > 0 and math.abs(self.lastLoadContentY - innerPosY) > 1 then
        self:updateList(self.data)
    end

    if self.eventCallback then
        self.eventCallback(self.dlg, sender, eventType)
    end
end

-- 外部调用
function ScrollViewLP:initList(data)
    for key, v in pairs(self.usingCells) do
        v:setVisible(false)
        table.insert(self.notUseCells, v)
        self.usingCells[key] = nil
    end

   --[[self:setNotCallScrollView(true)
    local scrollViewSize = self.scrollView:getContentSize()
    scrollView:setInnerContainerSize(scrollViewSize.width, 0)
    self:setNotCallScrollView(false)]]

    self:updateList(data)
end

-- 内部自己调用
function ScrollViewLP:updateList(data)
    if not data then
        return
    end

    self.data = data

    local lineSpace = self.lineSpace
    local columnSpace = self.columnSpace
    local startY = self.startY
    local startX = self.startX
    local loadLine = self.loadLine
    local column = self.col
    local cellColne = self.cloneCtrl

    local totalCount = #data

    local line = math.floor(totalCount / column)
    local left = totalCount % column

    if left ~= 0 then
        line = line + 1
    end

    local cellSize = cellColne:getContentSize()
    local totalHeight = line * (cellSize.height + lineSpace) + startY
    local totalWidth = column * (cellSize.width + columnSpace) + startX

    local scrollView = self.scrollView
    local scrollViewSize = scrollView:getContentSize()
    local contentLayer = scrollView:getChildByTag(CONTENTLAYER_TAG)
    local contentY = math.min(0, scrollViewSize.height - totalHeight)
    local oldHeight = 0
    if not contentLayer then
        contentLayer = ccui.Layout:create()
        scrollView:addChild(contentLayer, 0, CONTENTLAYER_TAG)
    else
        local listInnerContent = scrollView:getInnerContainer()
        contentY = listInnerContent:getPositionY()
        oldHeight = contentLayer:getContentSize().height
    end

    -- 移除边缘不需要加载的条目
    local curLoadY = -contentY + scrollViewSize.height / 2
    local curLine = math.min(math.max(line - math.floor(curLoadY / (cellSize.height + lineSpace)), loadLine + 1), math.max(line - loadLine, 1))

    for key, v in pairs(self.usingCells) do
        local l = math.ceil(key / column) - 1  -- 行
        if l > curLine + loadLine or l < curLine - loadLine then
            v:setVisible(false)
            table.insert(self.notUseCells, v)
            self.usingCells[key] = nil
        end
    end

    local curColunm = 0
    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = column
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * column
            local y = totalHeight - (i - 1) * (cellSize.height + lineSpace) - startY
            if data[tag] and (i <= curLine + loadLine and i >= curLine - loadLine) then
                local cell
                if not self.usingCells[tag] then
                    -- 新加载的
                    if #self.notUseCells > 0 then
                        -- 复用
                        cell = table.remove(self.notUseCells)
                        cell:setVisible(true)
                    else
                        -- 新创建
                        cell = cellColne:clone()
                        cell:setAnchorPoint(0,1)
                        contentLayer:addChild(cell)
                    end

                    if self.cellViewCallback then
                        self.cellViewCallback(self.dlg, cell, data[tag], tag)
                    end

                    self.usingCells[tag] = cell
                else
                    -- 已创建过的
                    cell = self.usingCells[tag]
                end

                local x = (j - 1) * (cellSize.width + columnSpace) + startX
                cell:setPosition(x, y)
                cell:setTag(tag)
            end
        end
    end

    if totalHeight ~= oldHeight then
        -- setInnerContainerSize 中会调用回调函数，使用 self.notCallScrollView 标记不处理回调函数
        self:setNotCallScrollView(true)
        contentLayer:setContentSize(scrollViewSize.width, totalHeight)
        scrollView:setInnerContainerSize(contentLayer:getContentSize())

        if totalHeight < scrollViewSize.height then
            contentLayer:setPositionY(scrollViewSize.height - totalHeight)
        end

        self:setNotCallScrollView(false)
    end

    self.lastLoadContentY = contentY
end

return ScrollViewLP