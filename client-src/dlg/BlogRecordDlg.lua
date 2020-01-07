-- BlogRecordDlg.lua
-- Created by liuhb Seq/21/2017
-- 历史数据界面

local BlogRecordDlg = Singleton("BlogRecordDlg", Dialog)

local CONTENTLAYER_TAG = 9999

local SCROLL_COL = 2

local LOAD_NUM = 10  -- 以滑动框中心上限各加载 20 条

local FlowerInfo

function BlogRecordDlg:init(data)
    self:bindListener("BlogButton", self.onBlogButton)
    self:bindListener("PortraitPanel", self.onPortraitPanel, "MemberPanel")

    self.memberPanel = self:retainCtrl("MemberPanel")

    FlowerInfo = BlogMgr:getFlowerInfo()

    self.lastRequestNoteIId = nil  -- 标记请求过的信息，避免重复请求
    self.lastRequestNum = -1        -- 记录请求信息的数目，当收到的信息数少于请求数时表示数据已经全部获取
    self.isFinishLoad = false      -- 已请求到所有数据
    self.isLoading = false         -- 加载中
    self.notCallScrollView = false -- 用于禁止调用滑动框的回调
    self.notUsePanels = {}
    self.usingPanels = {}
    self.recordData = {}
    self.gid = data.gid

	self:initView(data)
	self:hookMsg("MSG_BLOG_FLOWER_LIST")
    self:hookMsg("MSG_BLOG_REQUEST_LIKE_LIST")
    self:hookMsg("MSG_BBS_REQUEST_LIKE_LIST")

end

-- 角色悬浮框
function BlogRecordDlg:onPortraitPanel(sender, eventType)
    local data  = sender:getParent().data
    if data and data.gid ~= Me:queryBasic("gid")  then
        local char = {}
        char.gid = data.gid
        char.name = data.name
        char.level = data.level
        char.icon = data.icon
        char.isOnline = 2
        local rect = self:getBoundingBoxInWorldSpace(sender)
        char.dist_name = data.dist
        if data.dist ~= GameMgr:getDistName() then
            FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.KUAFU_BLOG, rect)
        else
            FriendMgr:openCharMenu(char, nil, rect)
        end
    end
end

function BlogRecordDlg:onBlogButton(sender, eventType)
    local data = sender:getParent().data
    if data then
        BlogMgr:openBlog(data.gid, nil, nil, data.dist)
        self:onCloseButton()
    end
end

function BlogRecordDlg:initView(data)
    local type = data.type
    if type == "flower" then
        -- 赠花记录
        self:setLabelText("TitleLabel", CHS[5400260], "TitlePanel")

        -- 请求前 20 条鲜花记录
        BlogMgr:requestFlowerNotes({}, 20, data.gid)
        self.lastRequestNum = 20

        -- 请求空间人气和收到的鲜花数
        BlogMgr:requestPopularAndFlower( data.gid, data.dist)
    elseif type == "like" then
        -- 点赞
        self:setLabelText("TitleLabel", CHS[4100855], "TitlePanel")
        BlogMgr:queryStatusLikeList(data.para, data.dist)
    elseif type == "bbs_like" then
        -- 点赞
        self:setLabelText("TitleLabel", CHS[4100855], "TitlePanel")
        TradingSpotMgr:queryBBSStatusLikeList(data.para, data.dist)
    end

    local scrollView = self:getControl("MemberScrollView")
    scrollView:addEventListener(function(sender, eventType) self:onScrollView(sender, eventType) end)

    self:setCtrlVisible("NoticePanel", false)

    -- loading界面动起来
    local circleCtrl = self:getControl("LoadingImage", nil, "LoadingPanel")
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    circleCtrl:runAction(action)

    self:setCtrlVisible("LoadingPanel", false)

    self.dlgType = type
end

--
function BlogRecordDlg:onScrollView(sender, eventType)
    if self.notCallScrollView then
        return
    end

    if ccui.ScrollviewEventType.scrolling == eventType
            or ccui.ScrollviewEventType.scrollToTop == eventType
            or ccui.ScrollviewEventType.scrollToBottom == eventType then
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

        if math.abs(self.lastLoadContentY - innerPosY) > 270 then
            self:updateScrollViewPanel()
        end

        if innerPosY > 0 and not self.isLoading then
            if self.dlgType == "flower" then
                local cou = #self.recordData
                if not notRequest
                        and not self.isFinishLoad
                        and self.recordData[cou]
                        and self.lastRequestNoteIId ~= self.recordData[cou].iid then
                    -- 请求数据
                    local info = self.recordData[cou]
                    BlogMgr:requestFlowerNotes(info, 10, self.gid)

                    self.lastRequestNoteIId = self.recordData[cou].iid
                    self.lastRequestNum = 10

                    self:setLoadingVisible(true)
                end
            end
        end

        if self.isLoading then
            local panel = self:getControl("LoadingPanel")
            if innerPosY > 0 then
                panel:setPositionY(0)
            else
                panel:setPositionY(innerPosY)
            end
        end
    end
end

function BlogRecordDlg:showFlower(sender)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = FlowerInfo[sender.flower].icon,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = FlowerInfo[sender.flower].name
        },

        desc = FlowerInfo[sender.flower].desc
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function BlogRecordDlg:setMemberPanel(cell, data)
    -- 设置头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)

    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 跨服
    if data.dist and data.dist ~= GameMgr:getDistName() then
        gf:addKuafLogo(self:getControl("PortraitPanel", nil, cell))
    end

    -- 名字
    self:setLabelText("PlayerNameLabel", data.name or "", cell)

    if self.dlgType == "flower" then
        local imgPath = FlowerInfo[data.flower].icon
        local panel = self:getControl("FlowerPanel", nil, cell)
        self:setColorText(CHS[5400261], panel, nil, nil, nil, nil, 19)
        local size = panel:getContentSize()
        local img = ccui.ImageView:create(imgPath)
        -- img:ignoreContentAdaptWithSize(false)
        img:setScale(0.33)
        img:setPosition(size.width / 3 + 10, size.height / 2)
        img:setTouchEnabled(true)
        self:bindTouchEndEventListener(img, self.showFlower)
        img.flower = data.flower
        panel:addChild(img)
    end

    -- 点赞记录中，gid字段是uid
    if data.uid then
        data.gid = data.uid
    end

    cell.data = data
end

function BlogRecordDlg:updateScrollViewPanel()
    data = self.recordData or {}
    if #data == 0 then
        return
    end

    local lineSpace = 5
    local columnSpace = 5
    local startY = 5
    local startX = 5
    local column = SCROLL_COL
    local cellColne = self.memberPanel

    local totalCount = #data

    local line = math.floor(totalCount / column)
    local left = totalCount % column

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local cellSize = cellColne:getContentSize()
    local totalHeight = line * (cellSize.height + lineSpace) + startY
    local totalWidth = SCROLL_COL * (cellSize.width + columnSpace) + startX

    local loadHeight = LOAD_NUM * (cellSize.height + lineSpace)

    local scrollView = self:getControl("MemberScrollView")
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
        oldHeight = listInnerContent:getContentSize().height
    end

    local curLoadY = -contentY + scrollViewSize.height / 2

    -- 移除边缘不需要加载的条目
    for i = 1, totalCount do
        local l = math.ceil(i / 2)
        local y = totalHeight - (l - 1) * (cellSize.height + lineSpace) - startY
        if data[i] and self.usingPanels[data[i].iid] and (y > curLoadY + loadHeight or y < curLoadY - loadHeight) then
            self.usingPanels[data[i].iid]:setVisible(false)
            table.insert(self.notUsePanels, self.usingPanels[data[i].iid])
            self.usingPanels[data[i].iid] = nil
        end
    end

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = column
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * column
            local y = totalHeight - (i - 1) * (cellSize.height + lineSpace) - startY
            if data[tag] and (y < curLoadY + loadHeight and y > curLoadY - loadHeight) then
                local cell
                if not self.usingPanels[data[tag].iid] then
                    -- 新加载的
                    if #self.notUsePanels > 0 then
                        cell = table.remove(self.notUsePanels)
                        cell:setVisible(true)
                    else
                        cell = self.memberPanel:clone()
                        cell:setAnchorPoint(0,1)
                        contentLayer:addChild(cell)
                    end

                    self:setMemberPanel(cell, data[tag])
                    self.usingPanels[data[tag].iid] = cell
                else
                    -- 已创建过的
                    cell = self.usingPanels[data[tag].iid]
                end

                local x = (j - 1) * (cellSize.width + columnSpace) + startX
                cell:setPosition(x, y)
            end
        end
    end

    if totalHeight > oldHeight then
        -- setInnerContainerSize 中会调用回调函数，使用 self.notCallScrollView 标记不处理回调函数
        self.notCallScrollView = true
        contentLayer:setContentSize(scrollViewSize.width, totalHeight)
        scrollView:setInnerContainerSize(contentLayer:getContentSize())

        if totalHeight < scrollViewSize.height then
            contentLayer:setPositionY(scrollViewSize.height - totalHeight)
        elseif oldHeight > 0 then
            contentY = contentY + (oldHeight - totalHeight)
            scrollView:getInnerContainer():setPositionY(contentY)
        end

        self.notCallScrollView = false
    end

    self.lastLoadContentY = contentY
end

-- 设置加载的显示隐藏
function BlogRecordDlg:setLoadingVisible(visible)
    if self.isLoading == visible then
        return
    end


    local scrollView = self:getControl("MemberScrollView")
    local contentLayer = scrollView:getChildByTag(CONTENTLAYER_TAG)

    if not contentLayer then
        return
    end

    self:setCtrlVisible("LoadingPanel", visible)
    self.isLoading = visible

    local panel = self:getControl("LoadingPanel")
    local size = panel:getContentSize()
    local contentSize = contentLayer:getContentSize()
    self.notCallScrollView = true
    if visible then
        scrollView:setInnerContainerSize({width = contentSize.width, height = contentSize.height + size.height})
    else
        scrollView:setInnerContainerSize(contentSize)
    end

    self.notCallScrollView = false
end

-- 赠花记录信息
function BlogRecordDlg:MSG_BLOG_FLOWER_LIST(data)
    if self.dlgType ~= "flower"
        or self.gid ~= data.host_gid then
        return
    end

    if data.count == -1 then
        -- 服务器繁忙，请稍后再试。
        gf:ShowSmallTips(CHS[4300198])
        ChatMgr:sendMiscMsg(CHS[4300198])

        -- 取消标记，可以继续请求未请求新的数据
        self.lastRequestNoteIId = nil
        self.lastRequestNum = -1
    end

    -- 如果是第一页的数据且无留言，显示莲花姑凉
    if data.request_iid == "" and data.count < 1 then
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    if data.count < self.lastRequestNum then
        -- 已获取全部数据
        self.isFinishLoad = true
    end

    if data.request_iid == "" then
        self.recordData = {}
    end

    for i = 1, #data do
        table.insert(self.recordData, data[i])
    end

    if data.request_iid == "" or self.isLoading then
        self.lastRequestNoteIId = nil
        self:setLoadingVisible(false)
        self:updateScrollViewPanel()
    end
end


function BlogRecordDlg:MSG_BBS_REQUEST_LIKE_LIST(data)
    if self.dlgType ~= "bbs_like" then return end
    if data.count == 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    self.recordData = data
    self:setLoadingVisible(false)
    self:updateScrollViewPanel()
end

function BlogRecordDlg:MSG_BLOG_REQUEST_LIKE_LIST(data)
    if self.dlgType ~= "like" then return end
    if data.count == 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    self.recordData = data
    self:setLoadingVisible(false)
    self:updateScrollViewPanel()
end

return BlogRecordDlg
