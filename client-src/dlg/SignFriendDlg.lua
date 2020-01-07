-- SignFriendDlg.lua
-- Created by huangzz Dec/30/2016
-- 好友选择界面（姻缘签界面打开）

local SignFriendDlg = Singleton("SignFriendDlg", Dialog)

local MOVE_DISTANCE = 60

function SignFriendDlg:init()
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    
    self.friendScrollView = self:getControl("FriendScrollView")
    self.friendPanel = self:getControl("FriendButton")
    self.friendPanel:retain()
    self.friendPanel:removeFromParent()
    
    self.friends = FriendMgr:getFriends()
    
    table.sort(self.friends, function(l, r) return self:sortFunc(l, r) end)
    
    self:initData()
end

function SignFriendDlg:cleanup(sender, eventType)
    self:releaseCloneCtrl("friendPanel")
end

function SignFriendDlg:initData()
    self.curPage = 1
    
    self.allPage = math.floor((#self.friends + 11) / 12)

    self:showPage(self.curPage)
    
    self:createPages(self.friendPanel, self.friends, self.setFriendPanel, 5, 8)
end

function SignFriendDlg:setFriendPanel(cell, friend)
    -- 显示图标
    local iconPath = ResMgr:getSmallPortrait(friend.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
    if 1 ~= friend.isOnline then
        gf:grayImageView(imgCtrl)
    else
        gf:resetImageView(imgCtrl)
    end
    
    -- 显示等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        friend.lev, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    
    -- 显示名字
    local name =  gf:getRealName(friend.name)
    if 2 == friend.isOnline then
        self:setLabelText("PlayerNameLabel", name, cell, COLOR3.BROWN)
    elseif 0 == friend.isVip then
        self:setLabelText("PlayerNameLabel", name, cell, COLOR3.GREEN)
    elseif 0 ~= friend.isVip then
        self:setLabelText("PlayerNameLabel", name, cell, COLOR3.CHAR_VIP_BLUE_EX)
    end
    
    -- 显示友好度
    self:setLabelText("FriendNumLabel", CHS[3002321] .. friend.friendShip, cell)

    self:bindTouchEndEventListener(cell, function ()
        DlgMgr:sendMsg("MarriageSignWriteDlg", "setWishObject", friend.name, friend.gid)
        self:close()
    end)
end

function SignFriendDlg:onLeftButton(sender, eventType)
    if self.curPage == 1 then
        gf:ShowSmallTips(CHS[5420085])
        return
    end

    self.curPage = self.curPage - 1
    local pageView = self:getControl("FriendPageView", Const.UIPageView)
    pageView:scrollToPage(self.curPage - 1)
    self:showPage(self.curPage)
end

function SignFriendDlg:onRightButton(sender, eventType)
    if self.curPage == self.allPage then
        gf:ShowSmallTips(CHS[5420086])
        return
    end

    self.curPage = self.curPage + 1
    local pageView = self:getControl("FriendPageView", Const.UIPageView)
    pageView:scrollToPage(self.curPage - 1)
    self:showPage(self.curPage)
end

function SignFriendDlg:showPage(curPage)
    local pageDesc = curPage .. "/" .. self.allPage
    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageDesc, false, LOCATE_POSITION.MID, 23)
end

function SignFriendDlg:sortFunc(l, r)
    if l.isOnline < r.isOnline then
        return true
    elseif l.isOnline > r.isOnline then
        return false
    end
    
    if l.friendShip > r.friendShip then
        return true
    elseif l.friendShip < r.friendShip then
        return false
    end

    return false
end

-- 创建页面
function SignFriendDlg:createPages(clonePanel, dataTable, func, leftSpace, topSpace)
   
    local pageView = self:getControl("FriendPageView", Const.UIPageView)
    pageView:setMoveDistanceToChangePage(MOVE_DISTANCE)
    pageView:setTouchEnabled(true)
    pageView:stopAllActions()
    pageView:removeAllPages()
    local friendsNumber = #dataTable
    local lineNumber = 4
    local columnNumber = 3
    local pageNumber = math.floor(friendsNumber / (columnNumber * lineNumber))
    local pageLeft = friendsNumber % (columnNumber * lineNumber)
    local curPageContainNumber = 0

    if pageLeft ~= 0 then
        pageNumber = pageNumber + 1
    end
    
    local z = 1
    local function createPage()
        if  z > pageNumber then
            pageView:stopAllActions()
            --pageView:scrollToPage(0)
            return
        end

        if pageNumber  == z and pageLeft ~= 0 then
            curPageContainNumber = pageLeft
        else
            curPageContainNumber = columnNumber * lineNumber
        end


        local page = ccui.Layout:create()
        page:setContentSize(pageView:getContentSize())
        local line = math.floor( curPageContainNumber / columnNumber) + 1
        local left = curPageContainNumber % columnNumber
        local lineCount = 0

        for i = 1, line do
            if i == line then
                lineCount = left
            else
                lineCount = columnNumber
            end

            for j = 1, lineCount do
                local tag = columnNumber * (i - 1) + j + (z - 1) * columnNumber * lineNumber
                local data = dataTable[tag]
                if nil ~= data then
                    local cell = clonePanel:clone()
                    func(self, cell, dataTable[tag])

                    local posx = (j - 1) * (cell:getContentSize().width) + leftSpace
                    local posy = page:getContentSize().height - (i - 1)*(cell:getContentSize().height) - topSpace
                    cell:setPosition(posx, posy)
                    cell:setAnchorPoint(0,1)
                    page:addChild(cell)
                end
            end
        end
        z = z + 1
        pageView:addPage(page)
        if z == 2 then
            -- 由于第一页改为了立即创建，此处需要延时一帧，因为还没有doLayout过，
            -- 直接scollToPage的话，由于PageView中的数据还未更新，引起异常
            performWithDelay(pageView, function() pageView:scrollToPage(0) end, 0)
        end

    end

    createPage()
    if pageNumber > 1 then
        schedule(pageView , createPage, 0.05)
    end

    -- 绑定分页控件和分页标签
    pageView:addEventListener(function(sender, eventType)
        local index = pageView:getCurPageIndex()
        self.curPage = index + 1
        self:showPage(self.curPage)
    end)
end


return SignFriendDlg
