-- BlogPhotoDlg.lua
-- Created by songcw Oct/11/10
-- 个人空间查看原图

local BlogPhotoDlg = Singleton("BlogPhotoDlg", Dialog)

function BlogPhotoDlg:init()
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("MinusButton", self.onMinusButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("MainPanel", self.onReloadButton)

    self.curIndex = nil
    self.pathList = nil
    self.commentList = nil
    self.isOrgPicture = false
	self.isNotAutoLoad = false

    local mainPanel = self:getControl("MainPanel")
    self:setCtrlFullScreen("MainPanel")
    mainPanel:requestDoLayout()

    self.imageInitPos = self.imageInitPos or cc.p(mainPanel:getContentSize().width * 0.5, mainPanel:getContentSize().height * 0.5)
    self:setCtrlVisible("LoadingPhotoPanel", false)

    self.touchData = {}
    self.touchInit = {}
    self.touchTime = 0


    if   mainPanel:getChildByName("BlogPhotoDlgTouch") then return end

    self.touchsLayer = cc.Layer:create() -- UI 层
    self.touchsLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self.touchsLayer:setTouchEnabled(true)

    mainPanel:addChild(self.touchsLayer)
    self.touchsLayer:setName("BlogPhotoDlgTouch")
    self.touchsLayer:setGlobalZOrder(9999)
    gf:bindTouchListener(self.touchsLayer, function(touch, event)
        if not self.isOrgPicture then return end
        local pos = touch:getLocation()
        local eventCode = event:getEventCode()
        local image = self:getControl("PhotoImage")
        if eventCode == cc.EventCode.BEGAN then
            self.isWillClose = false
            self.touchTime = self.touchTime + 1
            local touchId = touch:getId()

            self.touchData[touchId] = pos
            self.touchInit[touchId] = pos

            self.curScale = self:getPercent()

            if self.touchTime == 2 then
                local otherPos = self:getOtherPos(touch, self.touchInit)
                local x, y = image:getPosition()
                self.iamgeCurRect = self:getBoundingBoxInWorldSpace(self:getControl("PhotoImage"))
                self.beginPos = cc.p(x, y)
                self.centerPoint = cc.p((otherPos.x + pos.x) * 0.5, (otherPos.y + pos.y) * 0.5)
            elseif self.touchTime == 1 then
                local x, y = image:getPosition()
                self.iamgeCurRect = self:getBoundingBoxInWorldSpace(self:getControl("PhotoImage"))
                self.beginPos = cc.p(x, y)

                if next(self.touchInit) and not cc.rectContainsPoint(self.iamgeCurRect, pos) then
                    self.isWillClose = true
                end
            end
        elseif eventCode == cc.EventCode.MOVED then

            self.touchData[touch:getId()] = pos
            -- 大于2个触控事件，不管
            if self.touchTime > 2 then
                return
            end
            -- 意外情况没有初始点击记录，不管
            if not next(self.touchInit) then return end

            if not self.touchInit[touch:getId()] then
                -- 拖动时，如果切换图片，touchInit会被清除，需要重新设置
                self.touchInit[touch:getId()] = pos
                self.touchTime = self.touchTime + 1
                return
            end

            if self.touchTime == 2 then
                local oldDistance
                local newDistance
                for id, initPos in pairs(self.touchInit) do
                    if id ~= touch:getId() then
                        oldDistance = cc.pGetDistance(initPos, self.touchInit[touch:getId()])
                    end
                end
                for id, curPos in pairs(self.touchData) do
                    if id ~= touch:getId() then
                        newDistance = cc.pGetDistance(curPos, pos)
                    end
                end

                local scale = (newDistance - oldDistance) / 4 * 0.01 + self.curScale
                scale = math.min(1.75, scale)
                scale = math.max(0.25, scale)

                if scale ~= self:getPercent() then
                    local otherPos = self:getOtherPos(touch, self.touchData)
                    local centerPoint = cc.p((otherPos.x + pos.x) * 0.5, (otherPos.y + pos.y) * 0.5)
                    local newX = (centerPoint.x - self.centerPoint.x) * 0.5
                    local newY = (centerPoint.y - self.centerPoint.y) * 0.5

                    local retX, retY = self:setImagePos(newX, newY)
                    image:setPosition(retX, retY)

                    local bkImage = self:getControl("BKImage")
                    bkImage:setPosition(retX, retY)
                end

                image:setContentSize(self.orgSize.width * scale, self.orgSize.height * scale)
                self:getControl("BKImage"):setContentSize(self.orgSize.width * scale + 8, self.orgSize.height * scale + 8)

                local parentPanel = image:getParent()
                if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
                    parentPanel:requestDoLayout()
                end
            else
                self:movePhoto(pos, touch:getId())
            end
        else
            self.touchTime = self.touchTime - 1

            self.touchData[touch:getId()] = nil
            self.touchInit[touch:getId()] = nil

            if self.touchTime <= 0 then
                self:resetTouch()
            elseif self.touchTime == 1 then
                for id, curPos in pairs(self.touchData) do
                    if id ~= touch:getId() then
                        local x, y = image:getPosition()
                        self.beginPos = cc.p(x, y)
                        self.touchInit[id] = curPos
                    end
                end
            end
        end
        return true
    end,
    {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED,
    }, true)
end

function BlogPhotoDlg:getOtherPos(touch, data)
    for id, curPos in pairs(data) do
        if id ~= touch:getId() then
            return curPos
        end
    end
end

function BlogPhotoDlg:movePhoto(pos, id)
    if self.touchInit and self.touchInit[id] and cc.rectContainsPoint(self.iamgeCurRect, self.touchInit[id]) then
        local x = pos.x - self.touchInit[id].x
        local y = pos.y - self.touchInit[id].y
        local image = self:getControl("PhotoImage")

        local retX, retY = self:setImagePos(x, y)
        image:setPosition(retX, retY)

        local bkImage = self:getControl("BKImage")
        bkImage:setPosition(retX, retY)
    end
end

function BlogPhotoDlg:setImagePos(x, y)
        local retX = self.beginPos.x + x
        local retY = self.beginPos.y + y

        local image = self:getControl("PhotoImage")

        if retX <= image:getContentSize().width * 0.5 then
            retX = image:getContentSize().width * 0.5
        end

        if retY + image:getContentSize().height * 0.5 >= self:getCtrlContentSize("MainPanel").height then
            retY = self:getCtrlContentSize("MainPanel").height - image:getContentSize().height * 0.5
        end

        if retY <= image:getContentSize().height * 0.5 then
            retY = image:getContentSize().height * 0.5
        end

        if retX + image:getContentSize().width * 0.5 >= self:getCtrlContentSize("MainPanel").width then
            retX = self:getCtrlContentSize("MainPanel").width - image:getContentSize().width * 0.5
        end

        return retX, retY
end

function BlogPhotoDlg:resetTouch()
    self.touchData = {}
    self.touchInit = {}
    self.touchTime = 0
end

function BlogPhotoDlg:updatePos(pos)

    local minDis = 2000
    local key
    for _, srcPos in pairs(self.touchData) do
        local dis = cc.pGetDistance(srcPos, pos)
            if minDis > dis then
                minDis = dis
                key = _
            end
    end

    if key then
        self.touchData[key] = pos
    end

    return key
end


function BlogPhotoDlg:onReloadButton()
    if self:getCtrlVisible("ReloadPanel") then
        self:setCtrlVisible("ReloadPanel", false)
        self:setCtrlVisible("PhotoShowPanel", true)
        self:setPicture(self.curIndex, self.pathList, self.commentList)
    else
        if self.isWillClose then
            self:onCloseButton()
        end
    end
end


--[[ 创建多点触控响应层
function BlogPhotoDlg:createMutiTouchLayer(touchPanel)
    if not touchPanel then
        return
    end

    if self.multiTouchListener then
        local eventDispatcher = touchPanel:getEventDispatcher()
        if eventDispatcher then
            eventDispatcher:removeEventListener(self.multiTouchListener)
        end
        self.multiTouchListener = nil
    end

    local function onTouchesBegan(touches, eventType)
        if self.isOrgPicture then
            if #touches >= 2 then
                self.pos1 = touches[1]:getLocation()
                self.pos2 = touches[2]:getLocation()
            else
                self.pos1 = touches[1]:getLocation()
                self.pos2 = nil
            end
        end

        gf:ShowSmallTips("self.pos1.x = " .. self.pos1.x .. " self.pos1.y = "  .. self.pos1.y)
        return false
    end

    local function onTouchesMoved(touches, eventType)
        if #touches >= 2 then
            local pos1 = touches[1]:getLocation()
            local pos2 = touches[2]:getLocation()

            local oldDistance = cc.pGetDistance(self.pos1, self.pos2)

            local newDistance = cc.pGetDistance(pos1, pos2)

            local scale = (newDistance - oldDistance) / 4 * 0.01 + 1
            scale = math.min(1.75, scale)
            scale = math.max(0.25, scale)

            local image = self:getControl("PhotoImage")
            image:setScale(scale)
            local parentPanel = image:getParent()
            if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
                parentPanel:requestDoLayout()
            end
        end
    end

    local function onTouchesEnd(touches, eventType)
    end

    self.multiTouchListener = cc.EventListenerTouchAllAtOnce:create()
      --  self.multiTouchListener:setSwallowTouches(false)
    self.multiTouchListener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCHES_BEGAN )
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_ENDED )
    self.multiTouchListener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCHES_MOVED)
    self.multiTouchListener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCHES_CANCELLED)
    local eventDispatcher = touchPanel:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(self.multiTouchListener, touchPanel)
end
--]]

function BlogPhotoDlg:autoLoadComplete(path, para)
    if para == self.curIndex then
        self:setOrgPicture(path,para)
    end
end

function BlogPhotoDlg:tobeAutoLoad(curIndex, pathList)
    if GameMgr.networkState ~= NET_TYPE.WIFI then return end
    local path = pathList
    for i = curIndex, #path do
        BlogMgr:assureFile("autoLoadComplete", self.name, path[i], nil, i)
    end

    for i = 1, curIndex do
        BlogMgr:assureFile("autoLoadComplete", self.name, path[i], nil, i)
    end
end

function BlogPhotoDlg:setPicture(curIndex, img_str, comments, isNotAutoLoad)
    self.curIndex = curIndex
    self.pathList = 'string' == type(img_str) and gf:split(img_str, "|") or img_str
    self.commentList = comments
	self.isNotAutoLoad = isNotAutoLoad

    local path = self.pathList
    if curIndex == 1 then
        self:setCtrlVisible("LeftButton", false)
    elseif curIndex == #path then
        self:setCtrlVisible("RightButton", false)
    end

    if #path == 1 then
        self:setCtrlVisible("LeftButton", false)
        self:setCtrlVisible("RightButton", false)
    end

    if not path[curIndex] then
        -- 异常情况，容错
        self:onCloseButton()
        return
    end

    -- 设置备注
    if self.commentList and self.commentList[curIndex] then
        self:setCtrlVisible("TextPanel", true)
        self:setLabelText("ContentLabel", self.commentList[curIndex], "TextPanel")
    else
        self:setCtrlVisible("TextPanel", false)
    end

    -- 是否有原图，有原图，则不管其他的了
    local filePath = ResMgr:getBlogPath(path[curIndex])
    local fullPath = cc.FileUtils:getInstance():getWritablePath() .. filePath
    if BlogMgr:checkFileValid(path[curIndex]) then
        -- 有原图
        self:setOrgPicture(fullPath)
    else
        -- 没有原图
        -- 不存在，缓存中是否有原图，有则设置原图
        local orgPath
        for i = 1, 4 do
            if BlogMgr.orgPicturePath[i] and BlogMgr.orgPicturePath[i].key == path[curIndex] then
                orgPath = BlogMgr.orgPicturePath[i].path
                self:setOrgPicture(orgPath)
            end
        end

        if isNotAutoLoad then return end

        -- 看看有没有缩略图，有可能缩略图都没有下载好
        local filePath = ResMgr:getBlogPath(path[curIndex], BlogMgr.PHOTO_SMALL_SIZE_STR)
        local fullPath = cc.FileUtils:getInstance():getWritablePath() .. filePath
        if BlogMgr:checkFileValid(path[curIndex], { process = BlogMgr.PHOTO_SMALL_SIZE_STR}) then
            -- 有缩略图
            self:setImage("PhotoImage", fullPath)

            -- 请求原图
            BlogMgr:assureFile("setOrgPicture", self.name, path[curIndex], nil, curIndex)
        else
            -- 这时候连缩略图也没有，如果要请求缩略图的话，todo

            -- 请求原图
            BlogMgr:assureFile("setOrgPicture", self.name, path[curIndex], nil, curIndex)
        end
    end

    self:tobeAutoLoad(curIndex, self.pathList)
end

function BlogPhotoDlg:setImage(name, path, root, noAuto)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:loadTexture(path)
    end

    self.isOrgPicture = false
    self:getControl("PhotoImage"):setScale(1)
    self:setSmallImageSize("PhotoImage")
    local size = self:getCtrlContentSize("PhotoImage")
    self:getControl("BKImage"):setScale(1)
    self:setCtrlContentSize("BKImage", size.width + 8, size.height + 6)

    local image = self:getControl("PhotoImage")
    local bkImage = self:getControl("BKImage")
    image:setPosition(self.imageInitPos)
    bkImage:setPosition(self.imageInitPos)

    -- 有些Image控件为auto属性，刷新上级
    if not noAuto and img then
        local parentPanel = img:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end
    end

   -- self.touchsLayer:setContentSize(size)
end

function BlogPhotoDlg:setSmallImageSize(imageName, panel)
    local image = self:getControl(imageName, nil, panel)
    local orgSize = image:getContentSize()
    -- 144 * 96缩略图尺寸
    local w1 = orgSize.width
    local h1 = orgSize.height
    local w2 = 144
    local h2 = 96

    if (w1 / w2) < (h1 / h2) then
        self:setImageSize(imageName, cc.size(w2, h1 / (w1 / w2)), panel)
    elseif (w1 / w2) > (h1 / h2) then
        self:setImageSize(imageName, cc.size(w1/(h1/h2), h2), panel)
    else
        self:setImageSize("PhotoImage", cc.size(144, 96), panel)
    end
end

function BlogPhotoDlg:creatHourglass(panel, path)


    -- 扇形倒计时
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(path))
    progressTimer:setReverseDirection(true)
    panel:setName(path)
    panel:addChild(progressTimer)

    local contentSize = panel:getContentSize()
    progressTimer:setPosition(contentSize.width / 2, contentSize.height / 2)

    progressTimer:setPercentage(100)
    local progressTo = cc.ProgressTo:create(10, 0)
    local endAction = cc.CallFunc:create(function()
        progressTimer:removeFromParent()

        -- 移除光圈
        --    self:setCtrlVisible("ChosenImage_1", false, panel)
    end)

    progressTimer:runAction(cc.Sequence:create(progressTo, endAction))
end

function BlogPhotoDlg:setOrgPicture(path, para)
    if not path or path == "" then
        -- 下载失败
        self:setCtrlVisible("ReloadPanel", true)
        self:setCtrlVisible("PhotoShowPanel", false)
        return
    end

    local img = self:getControl("PhotoImage", Const.UIImage)
    if img then
        img:loadTexture(path)
    end

    local size = img:getVirtualRendererSize()

    local w = size.width
    local h = size.height
    if w / h > 1.5 then
        self:setImageSize("PhotoImage", cc.size(756, 756 * h / w))
    elseif w / h < 1.5 then
        self:setImageSize("PhotoImage", cc.size(504 * w / h, 504))
    else
        self:setImageSize("PhotoImage", cc.size(756, 504))
    end

    self.orgSize = self:getCtrlContentSize("PhotoImage")
    self:setCtrlContentSize("BKImage", self.orgSize.width + 8, self.orgSize.height + 6)
    self.isOrgPicture = true
    self:resetTouch()

    local image = self:getControl("PhotoImage")
    local bkImage = self:getControl("BKImage")
    image:setPosition(self.imageInitPos)
    bkImage:setPosition(self.imageInitPos)
 --   self.touchsLayer:setContentSize(size)
end

function BlogPhotoDlg:getPercent()
    local image = self:getControl("PhotoImage")
    return image:getContentSize().width / self.orgSize.width
end

function BlogPhotoDlg:onAddButton(sender, eventType)
    if not self.isOrgPicture then return end
    local image = self:getControl("PhotoImage")
    local scale = self:getPercent() + 0.15
    scale = math.min(scale, 1.75)
    image:setContentSize(self.orgSize.width * scale, self.orgSize.height * scale)
    self:getControl("BKImage"):setContentSize(self.orgSize.width * scale + 8, self.orgSize.height * scale + 8)
end

function BlogPhotoDlg:onMinusButton(sender, eventType)
    if not self.isOrgPicture then return end
    local image = self:getControl("PhotoImage")
    local scale = self:getPercent() - 0.15
    scale = math.max(scale, 0.25)
    image:setContentSize(self.orgSize.width * scale, self.orgSize.height * scale)
    self:getControl("BKImage"):setContentSize(self.orgSize.width * scale + 8, self.orgSize.height * scale + 8)
end

function BlogPhotoDlg:onRightButton(sender, eventType)

    if not self.curIndex then return end

    local path = self.pathList
    if self.curIndex >= #path then return end

    self:setCtrlVisible("LeftButton", true)
    if #path == 1 then
        self:setCtrlVisible("LeftButton", false)
        self:setCtrlVisible("RightButton", false)
    end

    self.curIndex = self.curIndex + 1

    self:setPicture(self.curIndex, self.pathList, self.commentList, self.isNotAutoLoad)end

function BlogPhotoDlg:onLeftButton(sender, eventType)
    if not self.curIndex then return end

    if self.curIndex <= 1 then return end

    self:setCtrlVisible("RightButton", true)
    local path = self.pathList
    if #path == 1 then
        self:setCtrlVisible("LeftButton", false)
        self:setCtrlVisible("RightButton", false)
    end

    self.curIndex = self.curIndex - 1

	self:setPicture(self.curIndex, self.pathList, self.commentList, self.isNotAutoLoad)end

return BlogPhotoDlg
