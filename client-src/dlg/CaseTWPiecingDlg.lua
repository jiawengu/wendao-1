-- CaseTWPiecingDlg.lua
-- Created by huangzz Jun/01/2018
-- 探案 拼图界面

local CaseTWPiecingDlg = Singleton("CaseTWPiecingDlg", Dialog)

local Json = require('json')

local MAP_X_COUNT = 6
local MAP_Y_COUNT = 5

local MAP_BLOCK_WIDTH = 100
local MAP_BLOCK_HEIGHT = 100

local EXCHANGE_IMAGE_LIMIT = 0.55

local BLOCK_SPRITE_TAG = 100

-- 拼图错误图片颜色
local WRONG_IMG_COLOR = cc.c3b(150, 150, 150)

function CaseTWPiecingDlg:init(param)
    self:setFullScreen()

    self:bindListener("ShowButton", self.onShowButton)  -- 撒显影粉
    self:bindListener("HalfShowButton", self.onShowButton)
    self:bindListener("PageButton", self.onPageButton)  -- 翻页
    -- self:bindListener("ConfirmButton", self.onConfirmButton)

    for i = 1, 30 do
        local panel = self:getControl("Panel" .. i, nil, "JigsawPanel")
        panel:setTag(i)
        panel:setLayoutType(ccui.LayoutType.ABSOLUTE)  -- 绝对布局
    end

    self.typePanel1 = self:retainCtrl("FragmentTypePanel1")
    self.typePanel3 = self:retainCtrl("FragmentTypePanel3")
    self.typePanel4 = self:retainCtrl("FragmentTypePanel4")
    self.typePanel2 = self:retainCtrl("FragmentTypePanel2")

    self.listView = self:getControl("ListView")
    self.touchPanel = self:getControl("TouchPanel")

    self.selectPic = nil     -- 存储当前拿起的拼图块
    self.connectBlocks = {}  -- 存储与当前拿起的拼图块相连的拼图块
    self.isComplete = false  -- 拼图是否完成

    -- 解析数据
    param = param or {}
    self.data = param
    self.npcPos = cc.p(param.npc_x or 0, param.npc_y or 0)
    self.mapName = param.map_name-- "风月谷"
    if string.match(param.gameStatus, "{.+}") then
        local gameStatus = Json.decode(param.gameStatus)
        self.blocksPlace = gameStatus.blocks_place or {}
        self.frontUse = gameStatus.front_use or 0
        self.backUse = gameStatus.back_use or 0
    else
        self.frontUse = 0
        self.backUse = 0
        self.blocksPlace = {}
    end

    for i = 1, 30 do
        if not self.blocksPlace[i] then
            self.blocksPlace[i] = 0
        end
    end

    -- 设置信封内容的透明度
    self:getControl("TitelLabel", nil, "MailPanel"):setOpacity(self.backUse == 1 and 255 or 12.75)
    for i = 1, 8 do
        local label = self:getControl("TextLabel" .. i, nil, "MailPanel")
        label:setOpacity(self.backUse == 1 and 255 or 12.75)
    end

    self:setShowButtonVisible()
    
    self:initJigsawPuzzle()

    if not self:checkIsComplete(true) or not self.lastCloseTime then
        self.isInFront = true
        self.lastCloseTime = 0
    end

    -- 设置显示页面
    if gf:getServerTime() - self.lastCloseTime < 150 then
        self:setShowPage(self.isInFront)
    else
        -- 默认显示正面
        self:setShowPage(true)
    end

    self:setArrows()

    self:drawNPCPoint()
end

function CaseTWPiecingDlg:cmdCurGameStatus()
    local status = {}
    status.blocks_place = self.blocksPlace
    status.front_use = self.frontUse
    status.back_use = self.backUse
    gf:CmdToServer("CMD_TWZM_JIGSAW_STATE", {status = Json.encode(status)})
end

-- 提示
function CaseTWPiecingDlg:setArrows()
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType 
                or ccui.ScrollviewEventType.scrollToTop == eventType 
                or ccui.ScrollviewEventType.scrollToBottom == eventType then

            self:updateArrows()
        end
    end

    self.listView:addScrollViewEventListener(onScrollView)
    self:updateArrows()
end

-- 更新上下箭头的显隐
function CaseTWPiecingDlg:updateArrows()
    local scrollViewCtrl = self.listView
    local listInnerContent = scrollViewCtrl:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local scrollViewSize = scrollViewCtrl:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.height - scrollViewSize.height
    local innerPosY = listInnerContent:getPositionY()

    local name = scrollViewCtrl:getParent():getName()
    if totalHeight > 0 and innerPosY >  - totalHeight + 10 then
        self:setCtrlVisible("UpButton", true, name)
    else
        self:setCtrlVisible("UpButton", false, name)
    end

    if totalHeight > 0 and innerPosY < -10 then
        self:setCtrlVisible("DownButton", true, name)
    else
        self:setCtrlVisible("DownButton", false, name)
    end
end

-- 撒显影粉
function CaseTWPiecingDlg:onShowButton(sender, eventType)
    if not self:checkIsComplete() then
        gf:ShowSmallTips(CHS[5450263])
        return
    end
    
    if self.isInFront then
        if self.frontUse == 1 then
            gf:ShowSmallTips(CHS[5450264])
            return
        end

        if self.backUse == 0 then
            gf:showTipAndMisMsg(CHS[5450265])
        elseif self.backUse == 1 then
            gf:showTipAndMisMsg(CHS[5450266])
        end

        self.frontUse = 1
        self.npcSprite:setVisible(true)

        self:cmdCurGameStatus()
    else
        if self.backUse == 1 then
            gf:ShowSmallTips(CHS[5450264])
            return
        end

        if self.frontUse == 0 then
            gf:showTipAndMisMsg(CHS[5450267])
        elseif self.frontUse == 1 then
            gf:showTipAndMisMsg(CHS[5450268])
        end

        self.backUse = 1
        self:showMailContent()

        self:cmdCurGameStatus()
    end

    self:setShowButtonVisible()

    if self.frontUse == 1 and self.backUse == 1 then
        local md5 = gfGetMd5(self.data.gid .. "JOGEDT")
        gf:CmdToServer("CMD_TWZM_FINISH_JIGSAW", {key = md5})
    end
end

function CaseTWPiecingDlg:setShowButtonVisible()
    if self.frontUse == 1 and self.backUse == 1 then
        self:setCtrlVisible("ShowButton", false)
        self:setCtrlEnabled("HalfShowButton", false)
    elseif self.frontUse == 0 and self.backUse == 0 then
        self:setCtrlVisible("ShowButton", true)
        self:setCtrlVisible("HalfShowButton", false)
    else
        self:setCtrlVisible("ShowButton", false)
        self:setCtrlVisible("HalfShowButton", true)
    end
end

function CaseTWPiecingDlg:showMailContent()
    local label = self:getControl("TitelLabel", nil, "MailPanel")
    label:runAction(cc.FadeIn:create(1.5))

    for i = 1, 8 do
        local label = self:getControl("TextLabel" .. i, nil, "MailPanel")
        local action = cc.Sequence:create(
            cc.DelayTime:create(i * 1), 
            cc.FadeIn:create(1.5)
        )

        label:runAction(action)
    end
end

-- 翻面
function CaseTWPiecingDlg:onPageButton(sender, eventType)
    if not self:checkIsComplete() then
        gf:ShowSmallTips(CHS[5450262])
        return
    end

    self:setShowPage(not self.isInFront)
end

function CaseTWPiecingDlg:setShowPage(showOnePage)
    self:setCtrlVisible("JigsawPanel", showOnePage)
    self:setCtrlVisible("MailPanel", not showOnePage)

    self.isInFront = showOnePage
end

function CaseTWPiecingDlg:onConfirmButton(sender, eventType)

end

-- 将地图坐标(mapX, mapY)转换为客户端显示时使用的坐标
function CaseTWPiecingDlg:convertToClientSpace(mapX, mapY, height)
    return mapX * Const.PANE_WIDTH + Const.PANE_WIDTH / 2, height - mapY * Const.PANE_HEIGHT - Const.PANE_HEIGHT / 2
end

-- 左上角坐标转化成小地图
function CaseTWPiecingDlg:leftXYToSmallMap(x, y)
    local mapInfo = MapMgr:getMapInfoByName(self.mapName)
    if mapInfo then
        local info = require (ResMgr:getMapInfoPath(mapInfo.map_id))
        if nil == info then
            return 0, 0
        end

        x, y = self:convertToClientSpace(x, y, info.source_height)

        local width = info.source_width or 0
        local height = info.source_height or 0

        local mapY = y / height
        local mapX = x / width
         
        local size = self:getControl("JigsawPanel"):getContentSize()
        return mapX * size.width, mapY * size.height
    else
        return  100, 60
   end
end

-- 小地图绘制NPC点
function CaseTWPiecingDlg:drawNPCPoint()
    -- 创建NPC绿点
    local npcSprite = cc.Sprite:create(string.format("maps/smallMaps/NPC.png"))
    local smallX, smallY = self:leftXYToSmallMap(self.npcPos.x, self.npcPos.y)
    npcSprite:setPosition(smallX, smallY)
    npcSprite:setVisible(self.frontUse == 1 and self:checkIsComplete())
    self:getControl("JigsawPanel"):addChild(npcSprite, 10, 100)
    self.npcSprite = npcSprite
end

function CaseTWPiecingDlg:isInRightPos(ctrl)
    local tag = ctrl:getTag()
    local parent = ctrl:getParent()
    local pTag = parent:getTag()
    if pTag == tag and parent:getParent():getName() ~= "ListView"  then
        return true
    end
end

function CaseTWPiecingDlg:getFocusedPanel(pos)
    for i = 1, #self.allMapBlocks do
        local block = self.allMapBlocks[i]
        local touchPos = block:getParent():convertToNodeSpace(pos)
        local box = block:getBoundingBox()
        if box and cc.rectContainsPoint(box, touchPos) then
            return block
        end
    end
end

-- 检查是否可以放下
function CaseTWPiecingDlg:checkCanPutDown(moveIndex)
    for i = 1, #self.connectBlocks do
        local cIndex = self.connectBlocks[i]:getTag()
        local lastIndex = self.connectBlocks[i].lastIndex
        local nextIndex = lastIndex + moveIndex
        if nextIndex > 30 or nextIndex < 1 then
            return false
        end

        if (cIndex < 25 and nextIndex >= 25)
            or (cIndex >= 25 and nextIndex < 25)
            or (cIndex % 6 == 0 and nextIndex % 6 ~= 0)
            or (cIndex % 6 ~= 0 and nextIndex % 6 == 0)
            or (nextIndex == 30 and cIndex ~= 30) then
            return false
        end

        local panel = self:getControl("Panel" .. nextIndex, nil)
        local block = panel:getChildByName("block")
        if block and self:isInRightPos(block) then
            return false
        end
    end

    return true
end

-- 拿起某一地图块周围相连的地图块
function CaseTWPiecingDlg:takeUpConnectBlocks(block)
    self.connectBlocks = {}
    
    local flag = {}
    local function func(block)
        local index = block:getTag()
        local parentIndex = block:getParent():getTag()
        local arround = {1, -1, 6, -6}
        
        flag[index] = true
        for i = 1, #self.allMapBlocks do
            local mIndex = self.allMapBlocks[i]:getTag()
            local pIndex = self.allMapBlocks[i]:getParent():getTag()
            if not flag[mIndex] and (string.match(self.allMapBlocks[i]:getParent():getName() or "", "Panel.+")) then
                for j = 1, 4 do
                    if mIndex + arround[j] == index
                            and (math.abs(arround[j]) ~= 1 or math.ceil((mIndex + arround[j]) / 6) == math.ceil(mIndex / 6))
                            and pIndex + arround[j] == parentIndex
                            and (math.abs(arround[j]) ~= 1 or math.ceil((pIndex + arround[j]) / 6) == math.ceil(pIndex / 6)) then
                        self.allMapBlocks[i].lastIndex = pIndex

                        func(self.allMapBlocks[i])

                        table.insert(self.connectBlocks, self.allMapBlocks[i])
                        self:takeUpBlock(self.allMapBlocks[i])
                        break
                    end
                end
            end
        end
    end

    func(block)
end

-- 放下拿起的地图块周围相连的地图块
function CaseTWPiecingDlg:putDownConnectBlocks(moveIndex, gotoListView)
    for i = 1, #self.connectBlocks do
        if moveIndex then
            local lastIndex = self.connectBlocks[i].lastIndex
            local nextIndex = lastIndex + moveIndex

            local block = self:getControl("Panel" .. nextIndex, nil, "JigsawPanel"):getChildByName("block")
            if block then
                -- 多块一起移动时，覆盖的地图块直接仍入滑动框
                block.lastIndex = nil
                self:putDownBlock(block, nil)
            end

            self:putDownBlock(self.connectBlocks[i], nextIndex)
        else
            if gotoListView then
                self.connectBlocks[i].lastIndex = nil
            end

            self:putDownBlock(self.connectBlocks[i], nil)
        end
    end

    self.connectBlocks = {}
end

function CaseTWPiecingDlg:moveConnectBlocks(offsetX, offsetY)
    for i = 1, #self.connectBlocks do
        local posX, posY = self.connectBlocks[i]:getPosition()
        self.connectBlocks[i]:setPosition(posX + offsetX, posY + offsetY)
    end
end

-- 将地图块拿起
function CaseTWPiecingDlg:takeUpBlock(block, isListView)
    block:retain()
    local parent = block:getParent()
    local wPos = parent:convertToWorldSpace(cc.p(block:getPosition()))
    local pos = self.touchPanel:convertToNodeSpace(wPos)
    if isListView then
        self.listView:removeChild(block)
        block.lastIndex = nil
        
        self.listView:requestRefreshView()
        self.listView:doLayout()
        self:updateArrows()
    else
        block:removeFromParent()
        block.lastIndex = parent:getTag()
    end
    
    block:getChildByTag(BLOCK_SPRITE_TAG):setScale(1)
    block:setPosition(pos.x, pos.y)
    self.touchPanel:addChild(block)
    
    self:setBlockColor(block)
    block:release()
end

-- 将地图块放下
function CaseTWPiecingDlg:putDownBlock(block, index)
    block:retain()
    block:removeFromParent()

    if index then
        -- 移到拼图面板中的固定的位置
        block:getChildByTag(BLOCK_SPRITE_TAG):setScale(1)
        local panel = self:getControl("Panel" .. index, nil, "JigsawPanel")
        block:setPosition(0, 0)
        panel:addChild(block)

        self.blocksPlace[block:getTag()] = index
    else
        -- 移回原来的位置
        if block.lastIndex then
            -- 移到拼图面板内
            block:getChildByTag(BLOCK_SPRITE_TAG):setScale(1)
            local panel = self:getControl("Panel" .. block.lastIndex, nil, "JigsawPanel")
            block:setPosition(0, 0)
            panel:addChild(block)

            self.blocksPlace[block:getTag()] = block.lastIndex
        else
            -- 移到滑动框内
            block:getChildByTag(BLOCK_SPRITE_TAG):setScale(0.8)
            local items = self.listView:getItems()
            for i = 1, #items do
                if items[i].order < block.order then
                    self.listView:insertCustomItem(block, i - 1)
                    break
                end
            end

            if not block:getParent() then
                self.listView:pushBackCustomItem(block)
            end
            
            performWithDelay(self.root, function() 
                self.listView:requestRefreshView()
                self.listView:doLayout()
                self:updateArrows()
            end, 0)

            self.blocksPlace[block:getTag()] = 0
        end
    end
    
    block.lastIndex = nil

    self:setBlockColor(block)
    block:release()
end

function CaseTWPiecingDlg:checkIsComplete(now)
    if self.isComplete then return true end

    for i = 1, #self.allMapBlocks do
        if not self:isInRightPos(self.allMapBlocks[i]) then
            return
        end
    end

    self.isComplete = true
    
    if not now then
        local panel = self:getControl("FragmentPanel")
        local action = cc.MoveBy:create(0.3, cc.p(300, 0))
        panel:runAction(action)
    else
        self:setCtrlVisible("FragmentPanel", false)
    end

    return true
end

-- 设置地图块的颜色
function CaseTWPiecingDlg:setBlockColor(block)
    local parent = block:getParent()
    local tag = block:getTag()
    local pTag = parent:getTag()
    if pTag == tag or pTag > 30 or parent:getParent():getName() == "ListView" then
        block:setColor(COLOR3.WHITE)
    else
        block:setColor(WRONG_IMG_COLOR)
    end
end

-- 判断地图块是否已拿起
function CaseTWPiecingDlg:hasTakeUp(block)
    if block and block:getParent():getName() == "TouchPanel" then
        return true
    end
end

-- 拼图绑定单点触摸事件
function CaseTWPiecingDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)

    local listBox = self.listView:getBoundingBox()
    local jigsawPanel = self:getControl("JigsawPanel")
    local blockBox = jigsawPanel:getBoundingBox()
    local delayScroll
    local isListView = false
    local canClick = true
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

        if not canClick then return false end

        -- 已经有选中的图片，不再响应后续事件
        if self.selectPic then return false end

        if cc.rectContainsPoint(listBox, self.listView:getParent():convertToNodeSpace(touchPos)) then
            -- 点击滑动框内的地图块
            isListView = true
        elseif cc.rectContainsPoint(blockBox, jigsawPanel:getParent():convertToNodeSpace(touchPos)) and jigsawPanel:isVisible() then
            -- 点击拼图面板内的地图块
            isListView = false
        else
            return
        end
        
        self.selectPic = self:getFocusedPanel(touchPos)
        if not self.selectPic then
            return
        elseif self:checkIsComplete() then
            self.selectPic = nil
            
            local curTime = gfGetTickCount()
            if not panel.lastTime or curTime - panel.lastTime >= 120000 then
                gf:ShowSmallTips(CHS[5450261])
                panel.lastTime = curTime
            end

            return
        end

        -- 点击的地图块在正确位置，不再响应后续事件
        if not isListView and self:isInRightPos(self.selectPic) then
            self.selectPic = nil
            return false
        end

        self.lastTouchPos = touch:getLocation()
        canClick = false
        return true
    end

    local function onTouchMove(touch, event)
        if not self.selectPic then return end
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        if not self:hasTakeUp(self.selectPic) then
            -- 还未拿起

            if not cc.rectContainsPoint(self.selectPic:getBoundingBox(), self.selectPic:getParent():convertToNodeSpace(touchPos)) then
                -- 触点已不在点击图片上
                return
            end

            if isListView then
                if not cc.rectContainsPoint(listBox, self.listView:getParent():convertToNodeSpace(touchPos)) then
                    -- 触点已滑动框范围内
                    return
                end

                -- 判断是否可拿起
                local cx = touchPos.x - self.lastTouchPos.x
                local cy = touchPos.y - self.lastTouchPos.y
                if cx == 0 or math.abs(cy / cx) > 1.7 then
                    -- 不拿起
                    --self.selectPic = nil
                    self.lastTouchPos = touchPos
                    return
                end
            end

            -- 拿起相邻的地图块
            self.connectBlocks = {}
            if not isListView then
                self:takeUpConnectBlocks(self.selectPic)
            end

            self:takeUpBlock(self.selectPic, isListView)

            self.listView:setDirection(ccui.ScrollViewDir.none)

            self.lastTouchPos = touchPos
        end

        local offsetX, offsetY = touchPos.x - self.lastTouchPos.x, touchPos.y - self.lastTouchPos.y
        local posX, posY = self.selectPic:getPosition()
        self.selectPic:setPosition(cc.p(posX + offsetX, posY + offsetY))
        self:moveConnectBlocks(offsetX, offsetY)

        self.lastTouchPos = touchPos
    end

    local function onTouchEnd(touch, event)
        if delayScroll then
            panel:stopAction(delayScroll)
            delayScroll = nil
        end

        delayScroll = performWithDelay(panel, function() 
            self.listView:setDirection(ccui.ScrollViewDir.vertical)
        end, 0)
        
        canClick = true
        if not self.selectPic or not self:hasTakeUp(self.selectPic) then
            self.selectPic = nil
            return
        end

        -- 检查是否符合交换图片
        self.selectPic:setLocalZOrder(1)
        local panelX, panelY = self.selectPic:getPosition()
        
        local wPos = self.selectPic:getParent():convertToWorldSpace(cc.p(self.selectPic:getPosition()))
        local pos = self:getControl("JigsawPanel"):convertToNodeSpace(wPos)
        local size = self.selectPic:getContentSize()
        for i = 1, MAP_X_COUNT * MAP_Y_COUNT do
            local tmpPanel = self:getControl("Panel" .. i, nil, "JigsawPanel")
            local panelSz = tmpPanel:getContentSize()
            local block = tmpPanel:getChildByName("block")
            if (not block or not self:isInRightPos(block)) and size.width == panelSz.width and size.height == panelSz.height then
                
                local tmpX, tmpY = tmpPanel:getPosition()
                local ovelLapArea = Formula:getRectOvelLapArea(pos.x, pos.y, pos.x + size.width, pos.y + size.height,
                    tmpX, tmpY, tmpX + panelSz.width, tmpY + panelSz.height)
                if ovelLapArea / (panelSz.width * panelSz.height) > EXCHANGE_IMAGE_LIMIT then
                    -- 图片重合度大于70%时，交换图片位置
                    
                    if self.selectPic.lastIndex and not self:checkCanPutDown(i - self.selectPic.lastIndex) then
                        break
                    end

                    if block then
                        block.lastIndex = nil

                        if #self.connectBlocks > 0 then
                            -- 多块一起移动时，覆盖的地图块直接仍入滑动框
                            self:putDownBlock(block, nil)
                        else
                            -- 单块移动则互换位置
                            self:putDownBlock(block, self.selectPic.lastIndex)
                        end
                    end
                    
                    if self.selectPic.lastIndex then
                        self:putDownConnectBlocks(i - self.selectPic.lastIndex)
                    end
                    
                    self:putDownBlock(self.selectPic, i)

                    self.selectPic = nil

                    if self:checkIsComplete() then
                        gf:ShowSmallTips(CHS[5450260])
                    end
                    
                    self:cmdCurGameStatus()
                    return
                end
            end
        end

        if cc.rectContainsPoint(listBox, self.listView:getParent():convertToNodeSpace(touch:getLocation())) then
            -- 放入滑动框
            self.selectPic.lastIndex = nil
            self:putDownBlock(self.selectPic)
            self:putDownConnectBlocks(nil, true)

            self:cmdCurGameStatus()
        else
            -- 放回原位
            self:putDownBlock(self.selectPic)
            self:putDownConnectBlocks()
        end

        self.selectPic = nil
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 根据行列获取不同大小的地图块
function CaseTWPiecingDlg:getBlockPanel(row, col)
    if row < 5 and col < 6 then
        return self.typePanel1:clone()
    elseif row == 5 and col < 6 then
        return self.typePanel3:clone()
    elseif row == 5 and col == 6 then
        return self.typePanel4:clone()
    else
        return self.typePanel2:clone()
    end
end

-- 初始化界面地图图片
function CaseTWPiecingDlg:initJigsawPuzzle()
    -- 绑定触摸层事件
    self:bindTouchPanel()

    local mapInfo = MapMgr:getMapInfoByName(self.mapName)
    if mapInfo then
        local mapFile = string.format("maps/smallMaps/%05d.jpg", mapInfo.map_id)
        local mapSprite = cc.Sprite:create(mapFile)
        mapSprite:setAnchorPoint(cc.p(0, 0))

        local sz = mapSprite:getContentSize()
        local items = {}
        local orderFlag = {}
        for i = 1, MAP_Y_COUNT do
            for j = 1, MAP_X_COUNT do
                local index = (i - 1) * MAP_X_COUNT + j
                local x = (j - 1) * MAP_BLOCK_WIDTH
                local y = (i - 1) * MAP_BLOCK_WIDTH
                local width = MAP_BLOCK_WIDTH
                local height = MAP_BLOCK_HEIGHT
                if x + width > sz.width then
                    width = sz.width - x
                end

                if y + height > sz.height then
                    height = sz.height - y
                end

                local tmpSpirit = cc.Sprite:create(mapFile, cc.rect(x, y, width, height))
                local order = math.random(1, 30000)
                repeat
                    -- 确保没有相同的优先级
                    if orderFlag[order] then
                        order = order + 1
                    else
                        orderFlag[order] = true
                        break
                    end
                until false

                tmpSpirit.order = order
               
                local panel = self:getBlockPanel(i, j)
                tmpSpirit:setPosition(panel:getContentSize().width / 2, panel:getContentSize().height / 2)
                panel:setTag(index)
                panel:setName("block")
                panel:setAnchorPoint(0, 0)
                panel:addChild(tmpSpirit, 0, 100) 
                panel.order = order
                table.insert(items, panel)
            end
        end

       table.sort(items, function(l, r) 
            if l.order > r.order then return true end
        end)

        for i = 1, #items do
            local tag = items[i]:getTag()
            if not self.blocksPlace[tag] or self.blocksPlace[tag] == 0 then
                items[i]:getChildByTag(BLOCK_SPRITE_TAG):setScale(0.8)
                self.listView:pushBackCustomItem(items[i])
            else
                -- 已放在拼图面板上了
                local panel = self:getControl("Panel" .. self.blocksPlace[tag], nil, "JigsawPanel")
                items[i]:setPosition(0, 0)
                panel:addChild(items[i])

                self:setBlockColor(items[i])
            end
        end

        self.allMapBlocks = items
    end

    self.listView:requestRefreshView()
    self.listView:doLayout()
end

function CaseTWPiecingDlg:cleanup()
    self.lastCloseTime = gf:getServerTime()
end

return CaseTWPiecingDlg
