-- JigsawPuzzleDlg.lua
-- Created by lixh Api/04/2018
-- 2018暑假活动-拼图游戏界面

local JigsawPuzzleDlg = Singleton("JigsawPuzzleDlg", Dialog)

-- 地图分割数量
local MAP_X_COUNT = 5
local MAP_Y_COUNT = 5

-- 图片重合度大于50时，交换图片
local EXCHANGE_IMAGE_LIMIT = 0.5

-- 地图块名称
local MAP_BLOCK_NAME = "MapBlock"

-- 拼图背景配置
local BG_CONFIG = {
    CORNER = ResMgr.ui.jigsaw_puzzle_corner,
    RAW = ResMgr.ui.jigsaw_puzzle_raw_line,
    COL = ResMgr.ui.jigsaw_puzzle_col_line,
}

-- 拼图错误图片颜色
local WRONG_IMG_COLOR = cc.c3b(150, 150, 150)

function JigsawPuzzleDlg:init()
    self:bindListener("CloseButton", self.onCloseButton)
    self:bindListener("ConfirmButton", self.onSubmitButton)
end

function JigsawPuzzleDlg:setData(data)
    self.mapName = data.mapName
    self.order = data.order
    self:loadJigsawPuzzle()
    self:refreshPanelStatus()
end

-- 获取当前获取焦点的拼图块
function JigsawPuzzleDlg:getFocusedPanel(pos)
    for i = 1, MAP_X_COUNT * MAP_Y_COUNT do
        local panel = self:getControl("Panel" .. i, nil, "JigsawPanel")
        local touchPos = panel:getParent():convertToNodeSpace(pos)
        local box = panel:getBoundingBox()
        if box and cc.rectContainsPoint(box, touchPos) then
            return panel
        end
    end
end

-- 拼图绑定单点触摸事件
function JigsawPuzzleDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            -- 已经有选中的图片，不再响应后续事件
            if self.selectPic then return false end

            self.selectPic = self:getFocusedPanel(touch:getLocation())

            -- 没有点击到拼图，不再响应后续事件
            if not self.selectPic then return false end

            local index = string.sub(self.selectPic:getName(), string.len("Panel") + 1, -1)

            -- 点击拼图的在正确位置，不再响应后续事件
            if self:isIndexInRightPos(index) then
                self.selectPic = nil
                return false
            end

            self.selectPic:setLocalZOrder(100)
            self.originX, self.originY = self.selectPic:getPosition()
            self.lastTouchPos = touch:getLocation()
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        if not self.selectPic then return end
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

        local offsetX, offsetY = touchPos.x - self.lastTouchPos.x, touchPos.y - self.lastTouchPos.y
        local posX, posY = self.selectPic:getPosition()
        self.selectPic:setPosition(cc.p(posX + offsetX, posY + offsetY))
        self.lastTouchPos = touchPos
    end

    local function onTouchEnd(touch, event)
        if not self.selectPic then return end

        -- 检查是否符合交换图片
        self.selectPic:setLocalZOrder(1)
        local panelX, panelY = self.selectPic:getPosition()
        for i = 1, MAP_X_COUNT * MAP_Y_COUNT do
            local tmpPanel = self:getControl("Panel" .. i, nil, "JigsawPanel")
            local panelSz = tmpPanel:getContentSize()
            if tmpPanel.id ~= self.selectPic.id and not self:isIndexInRightPos(i) then
                local tmpX, tmpY = tmpPanel:getPosition()
                local ovelLapArea = Formula:getRectOvelLapArea(panelX, panelY, panelX + panelSz.width, panelY + panelSz.height,
                    tmpX, tmpY, tmpX + panelSz.width, tmpY + panelSz.height)
                if ovelLapArea / (panelSz.width * panelSz.height) > EXCHANGE_IMAGE_LIMIT then
                    -- 图片重合度大于50%时，交换图片位置
                    self.selectPic:setPosition(cc.p(tmpX, tmpY))
                    tmpPanel:setPosition(cc.p(self.originX, self.originY))

                    local id1 = self.selectPic.id
                    local id2 = tmpPanel.id
                    local changeIndex1
                    local changeIndex2
                    for i = 1, #self.order do
                        if self.order[i] == id1 then
                            changeIndex1 = i
                        end

                        if self.order[i] == id2 then
                            changeIndex2 = i
                        end
                    end

                    if changeIndex1 and changeIndex2 then
                        self.order[changeIndex1] = id2
                        self.order[changeIndex2] = id1
                    end

                    -- 图片交换后，刷新图片状态
                    self:refreshPanelStatus()

                    -- 保存数据到服务器
                    self:saveToServer(0)
                    self.selectPic = nil
                    return
                end
            end
        end

        -- 到了这里，说明没有重合度大于0.5的图片，交换失败
        self.selectPic:setPosition(cc.p(self.originX, self.originY))
        self.selectPic = nil
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 初始化界面地图图片
function JigsawPuzzleDlg:loadJigsawPuzzle()
    -- 绑定触摸层事件
    self:bindTouchPanel()

    local mapInfo = MapMgr:getMapInfoByName(self.mapName)
    if mapInfo then
        local mapFile = string.format("maps/smallMaps/%05d.jpg", mapInfo.map_id)
        local mapSprite = cc.Sprite:create(mapFile)
        mapSprite:setAnchorPoint(cc.p(0, 0))

        local sz = mapSprite:getContentSize()
        local width = sz.width / MAP_X_COUNT
        local height = sz.height / MAP_Y_COUNT
        local list = {}
        local imagePanel = self:getControl("Panel" .. 1, nil, "JigsawPanel")
        local panelSz = imagePanel:getContentSize()

        for i = 1, MAP_X_COUNT do
            for j = 1, MAP_Y_COUNT do
                local index = (i - 1) * MAP_X_COUNT + j
                local x = (j - 1) * width
                local y = (i - 1) * height
                local tmpSpirit = cc.Sprite:create(mapFile, cc.rect(x, y, width, height))
                tmpSpirit:setAnchorPoint(cc.p(0, 0))
                tmpSpirit:setScale(panelSz.width / width, panelSz.height / height)
                table.insert(list, tmpSpirit)
            end
        end

        for i = 1, #self.order do
            local index = self.order[i]
            local panel = self:getControl("Panel" .. i, nil, "JigsawPanel")
            panel:removeChildByName(MAP_BLOCK_NAME)
            panel:addChild(list[index])
            list[index]:setName(MAP_BLOCK_NAME)
            self:loadBgByIndex(panel, index)
            panel.id = index
        end
    end
end

-- 刷新游戏状态，完成时，通知服务器
function JigsawPuzzleDlg:refreshPanelStatus()
    for i = 1, MAP_X_COUNT * MAP_Y_COUNT do
        local panel = self:getControl("Panel" .. i, nil, "JigsawPanel")
        local image = panel:getChildByName(MAP_BLOCK_NAME)
        local bkImage = self:getControl("BKImage", nil, panel)

        if self:isIndexInRightPos(i) then
            image:setColor(COLOR3.WHITE)
            bkImage:setColor(COLOR3.WHITE)
        else
            image:setColor(WRONG_IMG_COLOR)
            bkImage:setColor(WRONG_IMG_COLOR)
        end
    end
end

-- 判断index位置图片是否正常
function JigsawPuzzleDlg:isIndexInRightPos(index)
    local panel = self:getControl("Panel" .. index, nil, "JigsawPanel")
    if panel.id == self.order[panel.id] then
        return true
    end

    return false
end

-- 获取拼图图片背景
function JigsawPuzzleDlg:loadBgByIndex(panel, index)
    local image = self:getControl("BKImage", Const.UIImage, panel)

    if index == 1 or index == 5 or index == 21 or index == 25 then
        -- 4个角
        image:loadTexture(BG_CONFIG.CORNER)
        image:setFlippedX(index == 1 or index == 21)
        image:setFlippedY(index == 1 or index == 5)
    elseif index >= 2 and index <= 4 or index >= 22 and index <= 24 then
        -- 水平边
        image:loadTexture(BG_CONFIG.RAW)
        image:setFlippedY(index >= 22 and index <= 24)
    elseif index == 6 or index == 11 or index == 16 or index == 10 or index == 15 or index == 20 then
        -- 垂直边
        image:loadTexture(BG_CONFIG.COL)
        image:setFlippedX(index == 6 or index == 11 or index == 16)
    else
        image:setVisible(false)
    end
end

-- 统计正确的拼图数量
function JigsawPuzzleDlg:getRightCount()
    local enableCount = 0
    for i = 1, MAP_X_COUNT * MAP_Y_COUNT do
        local panel = self:getControl("Panel" .. i, nil, "JigsawPanel")
        local image = panel:getChildByName(MAP_BLOCK_NAME)
        local bkImage = self:getControl("BKImage", nil, panel)

        if self:isIndexInRightPos(i) then
            enableCount = enableCount + 1
        end
    end

    return enableCount
end

function JigsawPuzzleDlg:onSubmitButton()
    if self:getRightCount() < 25 then
        gf:ShowSmallTips(CHS[7190181])
        return   
    end

    self:saveToServer(1)
    Dialog.close(self)
end

function JigsawPuzzleDlg:onCloseButton()
    Dialog.close(self)
end

-- 保存拼图状态到服务器
function JigsawPuzzleDlg:saveToServer(isSubmit)
    gf:CmdToServer("CMD_SUMMER_2018_PUZZLE", {isSubmit = isSubmit, mapName = self.mapName, count = MAP_X_COUNT * MAP_Y_COUNT, list = self.order})
end

function JigsawPuzzleDlg:cleanup()
    self.mapName = ""
    self.order = {}
    self.originX = nil
    self.originY = nil
    self.lastTouchPos = nil
    self.selectPic = nil
end

return JigsawPuzzleDlg
