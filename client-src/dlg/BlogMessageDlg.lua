-- BlogMessageDlg.lua
-- Created by liuhb  Sep/20/2017
-- 个人空间留言板

local BlogMessageDlg = Singleton("BlogMessageDlg", Dialog)

local LISTVIEW_MARGIN   = 2     -- 列表的间隔
local WORD_LIMIT        = 60    -- 发送文字限制

local INIT_LOAD_MESSAGE_NUM = 20 -- 初始请求 20条留言
local ONE_LOAD_MESSAGE_NUM = 10  -- 初始后，每单次请求 10条留言

local WRITE_MOVE_WIDTH = 600    -- 留言编辑区滑动宽度

BlogMessageDlg.relationLeftDlgName = "BlogInfoDlg"

function BlogMessageDlg:init(data)
    self:bindListener("WriteButton", self.onSwitchWriteButton, "OutPanel1")         -- 切换留言按钮
    self:bindListener("CloseWriteButton", self.onCloseWriteButton)                  -- 返回留言按钮
    self:bindListener("WriteButton", self.onPublishWriteButton, "OutPanel2")        -- 发布留言按钮
    self:bindListener("FriendButton", self.onFriendButton)                          -- 加好友按钮
    self:bindListener("FlowerButton", self.onFlowerButton)                          -- 送花按钮
    self:bindListener("ExpressionButton", self.onExpressionButton)                  -- 表情按钮
    self:bindListener("InfoButton", self.onPopularityInfoButton, "PopularityPanel") -- 空间人气按钮
    self:bindListener("InfoButton", self.onFlowerInfoButton, "FlowerPanel")          -- 收到花束按钮
    self:bindListener("DelButton", self.onDelButton, "OutPanel2")
    self:bindListener("OneMessagePanel", self.onOneMessagePanel)
    self:bindListener("DeleteButton", self.onDeleteButton, "OneMessagePanel")
    self:bindListener("PortraitPanel", self.onPortraitPanel, "OneMessagePanel")
    self:bindListener("UnReadNotePanel", self.onUnReadNotePanel)
    self:bindListener("BackButton", self.onBackButton, "OutPanel3")

    self:setCtrlVisible("OutPanel3", false)
    self:setCtrlVisible("UnReadNotePanel", false)

    -- 缓存留言列表
    self.oneMessagePanel = self:retainCtrl("OneMessagePanel")

    self.curListViewName = "ListView"

    self.loadingPanel = self:retainCtrl("LoadingPanel")-- self:getControl("LoadingPanel"):clone()

    self.isLoading = false            -- 加载中
    self.selectMsgData = nil          -- 选择的回复对象数据
    self.lastRequestMessageIId = nil  -- 标记请求过的信息，避免重复请求
    self.lastRequestNum = -1           -- 记录请求信息的数目，当收到的信息数少于请求数时表示数据已经全部获取
    self.curLoadIndex = 0             -- 当前读到缓存中的第几条
    self.isFinishLoad = false         -- 已请求到所有数据
    self.isFirstOpenDlg = true        -- 第一次打开界面
    self.notCallListView = false      -- 用于禁止调用滑动框的回调
    self.lastWriteStatus = false      -- 编辑框状态
    self.isUnReadView = false         -- true 表示当前显示的是未读留言面板
    self.blogMessageList = {}
    self.cacheData = {}               -- 切换到显示未读留言时，用于缓存自己空间留言的数据

    -- 博客主的数据
    self.blogHostData = data

    -- 请求留言板数据
    local me = BlogMgr.startRequestMessage or 0
    local gid = data.user_gid
    local distName = BlogMgr:getDistByGid(gid)
    if BlogMgr.startRequestMessage then
        BlogMgr:requestBlogMessageData(BlogMgr.startRequestMessage, INIT_LOAD_MESSAGE_NUM, gid, 2, distName)
        self.lastRequestMessageIId = BlogMgr.startRequestMessage.iid
    else
        BlogMgr:requestBlogMessageData({}, INIT_LOAD_MESSAGE_NUM, gid, 1, distName)
    end

    BlogMgr:setStartRequestMessage(nil)
    self.lastRequestNum = INIT_LOAD_MESSAGE_NUM

    BlogMgr:clearMessageList(gid)

     -- 初始化界面数据
    self:refreshInfo(self.blogHostData)
    self:initWritePanel(self.blogHostData)
    self:initView()

    self:setInfoPanel(BlogMgr.blogFlowerInfo or {})

    if data.user_gid == Me:queryBasic("gid") then
        self:MSG_BLOG_MESSAGE_NUM_ABOUT_ME({count = BlogMgr.unReadMessageCount or 0})
    end


    self.openTime = gf:getServerTime()

    self:hookMsg("MSG_BLOG_MESSAGE_LIST")
    self:hookMsg("MSG_BLOG_MESSAGE_WRITE")
    self:hookMsg("MSG_BLOG_MESSAGE_DELETE")
    self:hookMsg("MSG_FRIEND_ADD_CHAR")
    self:hookMsg("MSG_BLOG_CHAR_INFO")
    self:hookMsg("MSG_BLOG_FLOWER_UPDATE")
    self:hookMsg("MSG_BLOG_MESSAGE_NUM_ABOUT_ME")
    self:hookMsg("MSG_BLOG_MESSAGE_LIST_ABOUT_ME")
end

-- 清理数据
function BlogMessageDlg:cleanup()
    DlgMgr:closeDlg("BlogRecordDlg")
    DlgMgr:closeDlg("BlogFlowersDlg")

    -- 由于Tab标签页切换，有时候只关闭该对话框，所以需要手动关闭 BlogInfoDlg
    DlgMgr:closeDlg(self.relationLeftDlgName)

    local circleCtrl = self:getControl("LoadingImage", nil, self.loadingPanel)
    circleCtrl:stopAllActions()
end

-- 初始化信息
function BlogMessageDlg:refreshInfo(data)
    if not data then
        -- 没有数据，使用默认数据
        data = {}
    end

    -- 设置空间名字
    if data.user_gid == Me:queryBasic("gid") then
        self:setLabelText("TitleLabel_2", CHS[5400268] .. CHS[5400269], "TitlePanel")
    else
        self:setLabelText("TitleLabel_2", (data.name or "") .. CHS[5400269], "TitlePanel")
    end
end

function BlogMessageDlg:setInfoPanel(data)
    -- 设置空间人气
    self:setLabelText("NumLabel", math.min(9999999, data.popular or 0), "PopularityPanel")

    -- 设置收到的花束
    self:setLabelText("NumLabel", data.flower or 0, "FlowerPanel")
end

-- 初始化留言
function BlogMessageDlg:initWritePanel(data)
    if not data then
        -- 没有数据，使用默认数据
        data = {}
    end

    if data.user_gid == Me:queryBasic("gid") then
        -- 自己的空间
        self:setCtrlVisible("WriteButton", true, "OutPanel1")
        self:setCtrlVisible("FriendButton", false, "OutPanel1")
        self:setCtrlVisible("FlowerButton", false, "OutPanel1")
    else
        -- 别人的空间
        self:setCtrlVisible("WriteButton", true, "OutPanel1")
        self:setCtrlVisible("FlowerButton", true, "OutPanel1")

        if FriendMgr:hasFriend(data.user_gid) then
            self:setCtrlVisible("FriendButton", false, "OutPanel1")
        else
            self:setCtrlVisible("FriendButton", BlogMgr:isSameDist(data.user_gid), "OutPanel1")
        end
    end
end

-- 初始化列表
function BlogMessageDlg:initView()
    -- 重置列表数据
    self:resetListData()

    self:setCtrlVisible("NoticePanel", false)

    local function onScrollView(sender, eventType)
        if self.notCallListView then
            return
        end

        if ccui.ScrollviewEventType.scrolling == eventType
                or ccui.ScrollviewEventType.scrollToTop == eventType
                or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件
            local listViewCtrl = sender
            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local scrollViewSize = listViewCtrl:getContentSize()

            local items = listViewCtrl:getItems()
            if #items <= 0 then
                return
            end

            -- 计算滚动的百分比
            local innerPosY = math.floor(listInnerContent:getPositionY() + 0.5)
            local totalHeight = innerSize.height - scrollViewSize.height

            if innerPosY > 0 and not self.isLoading then
                -- 向下加载
                local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM)
                if 0 == #moreData and not self.isFinishLoad then
                    -- 没有数据了
                    self:setLoadingVisible(true)
                    return
                end

                self:refreshList(moreData)
            end

            if -innerPosY > totalHeight + 10 and not self.isLoading and not self.isUnReadView then
                -- 向上加载
                self.root:stopAction(self.requestDelay)
                -- 延时处理只是为了表现好看点
                self.requestDelay = performWithDelay(self.root, function()
                    local gid = BlogMgr:getBlogGidByDlgName(self.name)
                    local item = self:getFirstItem()
                    local msgData = item.msgData
                    BlogMgr:requestBlogMessageData(msgData, 10, gid, 0, BlogMgr:getDistByGid(gid))
                    self.lastRequestNum = 10
                end, 0.5)

                self:setLoadingVisible(true, "up")
            end
            --[[if self.isLoading then
                local panel = self:getControl("LoadingPanel", nil, "LoadPanel")
                if innerPosY > 0 then
                    panel:setPositionY(0)
                else
                    panel:setPositionY(innerPosY)
                end
            end]]
        end
    end


    self:getControl("ListView"):addScrollViewEventListener(onScrollView)
    self:getControl("UnReadListView"):addScrollViewEventListener(onScrollView)

    -- loading界面动起来
    local circleCtrl = self:getControl("LoadingImage", nil, self.loadingPanel)
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    circleCtrl:runAction(action)

    -- 初始化编辑框
    self:setCtrlVisible("DelButton", false, "OutPanel2")
    self.inputCtrl = self:createEditBox("TextPanel", "OutPanel2", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT then
                content = gf:subString(content, WORD_LIMIT)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400041])
            end

            if len == 0 then
                self:setCtrlVisible("DelButton", false, "OutPanel2")
            else
                self:setCtrlVisible("DelButton", true,  "OutPanel2")
            end

        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 21)
    self.inputCtrl:setFont(CHS[3003794], 21)
    self.inputCtrl:setPlaceHolder(CHS[5400257])
    self.inputCtrl:setPlaceholderFontSize(21)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)

    -- 将留言编辑控件左移到显示控件外
    self:setCtrlVisible("OutPanel1", true)
    self:setCtrlVisible("OutPanel2", true)
    local outPanel = self:getControl("OutPanel2")
    local posX = outPanel:getPositionX()
    outPanel:setPositionX(posX - WRITE_MOVE_WIDTH)
    -- self:moveOutPanel(-WRITE_MOVE_WIDTH, "OutPanel2", 0)
end

function BlogMessageDlg:moveOutPanel(moveX, ctrlName, time)
    local outPanel1 = self:getControl(ctrlName)
    local action = cc.MoveBy:create(time or 0.2, {x = moveX, y = 0})
    outPanel1:runAction(action)
end

function BlogMessageDlg:setLoadingVisible(visible, w)
    if self.isLoading == visible then
        return
    end

    local listView = self:getControl(self.curListViewName)
    -- self:setCtrlVisible("LoadingPanel", visible, "LoadPanel")
    self.isLoading = visible

    if visible then
        if w == "up" then
            listView:insertCustomItem(self.loadingPanel, 0)
        else
            listView:pushBackCustomItem(self.loadingPanel)
        end
    elseif self.loadingPanel:getParent() then
        listView:removeChild(self.loadingPanel, false)
    end

    self.notCallListView = true
    listView:refreshView()
    self.notCallListView = false
end

-- 初始化一个条目
function BlogMessageDlg:initMessagePanel(panel, data)
    -- 设置头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.sender_icon), panel)

    if data.sender_dist ~= GameMgr:getDistName() then
        gf:addKuafLogo(self:getControl("PortraitPanel", nil, panel))
    end

    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.sender_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 名字
    local nameStr = data.sender_name or ""
    if data.char_name and data.char_name ~= "" then
        nameStr = string.format(CHS[5420235], data.char_name)
    end

    self:setLabelText("PlayerNameLabel", nameStr, panel)

    -- 内容
    local msg = data.message
    if data.target_name ~= "" then
        local str = string.format(CHS[5400286], "#B" .. data.target_name .. "#n")
        if data.char_name and data.char_name ~= "" then
            str = string.format(CHS[5420236], data.sender_name)
        end

        msg = str .. data.message
    end

    local flower = string.match(msg, "{\29ICON=(.+)}")
    local msg = string.gsub(msg, "{\29(.+)}", "")
    local curHeight, oldHeight = self:setColorText(msg, "TextPanel", panel, nil, nil, nil, 19, nil, nil, data.sender_vip ~= 0)
    if curHeight > oldHeight then
        local size = panel:getContentSize()
        panel:setContentSize(size.width, size.height - oldHeight + curHeight)
    end

    -- 显示花束
    local flowerInfo = BlogMgr:getFlowerInfo()
    if flower and flowerInfo[flower] then
        local textPanel = self:getControl("TextPanel", nil, panel)
        local img = ccui.ImageView:create(flowerInfo[flower].icon)
        local colorLayer = textPanel:getChildByTag(Dialog.TAG_COLORTEXT_CTRL)
        local textCtrl = tolua.cast(colorLayer, "CGAColorTextList")
        local textW, textH = textCtrl:getRealSize()
        img:setScale(0.38)
        img:setPosition(textW + img:getContentSize().width / 2 * 0.38, img:getContentSize().height / 2 * 0.38)
        textPanel:addChild(img)
    end

    -- 时间
    local str = self:getTimeStr(data.time or 0)
    self:setLabelText("TimeLabel", str, panel)

    -- 删除按钮
    if (self.blogHostData.user_gid == Me:queryBasic("gid")
        or data.sender_gid == Me:queryBasic("gid")) and not data.char_name then
        -- 自己发的留言或自己的个人空间才可删除留言
        self:setCtrlVisible("DeleteButton", true, panel)
    else
        self:setCtrlVisible("DeleteButton", false, panel)
    end

    -- 设置条目的数据
    panel.msgData = data
end

function BlogMessageDlg:getTimeStr(time)
    local curTime = gf:getServerTime()
    local timeStr
    local timeC = math.abs(curTime - time) -- 时间误差可能为负
    if timeC <= 3600 then
        local min = math.floor(timeC / 60) + 1
        timeStr = string.format(CHS[6000088], min)
    elseif timeC < 3600 * 24 then
        local hour = math.floor(timeC / 3600)
        timeStr = string.format(CHS[6000087], hour)
    else
        timeStr = gf:getServerDate(CHS[4300233], time)
    end

    return timeStr
end

-- 重置列表
function BlogMessageDlg:resetListData()
    -- 默认显示莲花姑娘
    self:setCtrlVisible("NoticePanel", true)

    -- 重置列表
    self:resetListView(self.curListViewName, LISTVIEW_MARGIN)

    -- load条隐藏
    -- self:setCtrlVisible("LoadingPanel", false)
end

-- 刷新列表
function BlogMessageDlg:refreshList(data, isReset, upLoad)
    -- 隐藏莲花姑娘
    self:setCtrlVisible("NoticePanel", false)

    -- 隐藏加载
    self:setLoadingVisible(false)

    if #data == 0 then
        return
    end

    local listView
    if isReset then
        listView = self:resetListView(self.curListViewName, LISTVIEW_MARGIN)
    else
        listView = self:getControl(self.curListViewName)
    end

    if not upLoad then
        -- 向下加载
        for i = 1, #data do
            -- 创建一个Panel插入
            local panel = self.oneMessagePanel:clone()
            self:initMessagePanel(panel, data[i])
            listView:pushBackCustomItem(panel)
        end
    else
        -- 向上加载
        for i = 1, #data do
            -- 创建一个Panel插入
            local panel = self.oneMessagePanel:clone()
            self:initMessagePanel(panel, data[i])
            listView:insertCustomItem(panel, i - 1)
        end
    end

    -- doLayout 中会调用回调函数，使用 self.notCallListView 标记不处理回调函数
    self.notCallListView = true
    listView:doLayout()
    listView:refreshView()
    self.notCallListView = false
end

-- 删除一条留言并加入新的留言
function BlogMessageDlg:removeOneItem(index)
    local listView = self:getControl("ListView")
    local items = listView:getItems()
    if #items < index then
        return
    end

    -- 删除一个条目，并显示一个条目
    listView:removeItem(index - 1)
    local moreData = self:getMoreMessage(1)
    if #moreData > 0 then
        self:refreshList(moreData)
    end

    local data = self.blogMessageList or {}
    local cou = #data
    if index == cou and data[index - 1] then
        -- 删除的正好是最后一条，将标记后移一位，避免重复请求
        self.lastRequestMessageIId = data[index - 1].iid
    elseif cou == 1 then
        -- 删完最后一条数据，显示莲花姑娘
        self:resetListData()
    end

    self.curLoadIndex = self.curLoadIndex - 1
end

-- 获取更多的留言信息
function BlogMessageDlg:getMoreMessage(num, notRequest)
    local moreData = {}
    local data = self.blogMessageList or {}
    local cou = #data
    if self.curLoadIndex < cou then
        for i = self.curLoadIndex + 1, self.curLoadIndex + num do
            if data[i] then
                table.insert(moreData, data[i])
                self.curLoadIndex = self.curLoadIndex + 1
            else
                break
            end
        end
    end

    if not notRequest
            and not self.isFinishLoad
            and data[cou]
            and self.lastRequestMessageIId ~= data[cou].iid then
        -- 请求数据
        -- performWithDelay(self.root, function()
            local message = data[cou]
            if self.isUnReadView then
                BlogMgr:requestBlogUnReadMessageData(message, num)
            else
                local gid = BlogMgr:getBlogGidByDlgName(self.name)
                BlogMgr:requestBlogMessageData(message, num, gid, nil, BlogMgr:getDistByGid(gid))
            end
        -- end, 3)

        self.lastRequestNum = num
        self.lastRequestMessageIId = data[cou].iid
    end

    return moreData
end

-- 切换留言按钮
function BlogMessageDlg:switchWritePanel(isWrite)
    if self.lastWriteStatus == isWrite then
        return
    end

    self.lastWriteStatus = isWrite

    if isWrite then
        -- 显示填写区域
        self:moveOutPanel(WRITE_MOVE_WIDTH, "OutPanel2")
        self:moveOutPanel(WRITE_MOVE_WIDTH, "OutPanel1")
    else
        -- 显示按钮
        self:moveOutPanel(-WRITE_MOVE_WIDTH, "OutPanel1")
        self:moveOutPanel(-WRITE_MOVE_WIDTH, "OutPanel2")
    end
end

-- 取消选中回复对象并清除输入内容
function BlogMessageDlg:initInputCtrl()
    self.inputCtrl:setPlaceHolder(CHS[5400257])
    self.selectMsgData = nil
    self:onDelButton()
end

function BlogMessageDlg:isMeetLevel()
    local gid = BlogMgr:getBlogGidByDlgName(self.name)

    -- 若当前玩家等级＜40级，并且是自己的空间，则予以如下弹出提示
    if Me:queryBasicInt("level") < 40 and Me:queryBasic("gid") == gid then
        gf:ShowSmallTips(CHS[5400263])
        return
    end

    -- 等级达到70级才可在他人的留言板留言
    if Me:queryBasicInt("level") < 70 and Me:queryBasic("gid") ~= gid then
        gf:ShowSmallTips(CHS[4300291])
        return
    end

    return true
end

-- 切换留言按钮
function BlogMessageDlg:onSwitchWriteButton(sender, eventType)
    if not self:isMeetLevel() then return end

    self:switchWritePanel(true)

    self.selectMsgData = nil
end

-- 返回留言按钮
function BlogMessageDlg:onCloseWriteButton(sender, eventType)
    self:switchWritePanel(false)

    -- 取消选中回复对象并清除输入内容
    self:initInputCtrl()
end

-- 发送留言按钮
function BlogMessageDlg:onPublishWriteButton(sender, eventType)
    self:sendMessage()
end

-- 添加/删除好友
function BlogMessageDlg:onFriendButton(sender, eventType)
    if not self.blogHostData then return end

    FriendMgr:tryToAddFriend(self.blogHostData.name, self.blogHostData.user_gid)
end

-- 送花
function BlogMessageDlg:onFlowerButton(sender, eventType)
    if not self.blogHostData then return end

    if not BlogMgr:isSameDist(self.blogHostData.user_gid) then
        gf:ShowSmallTips(CHS[4300366])
        return
    end

    if Me:queryBasicInt("level") < BlogMgr:getMessageLimitLevel() then
        gf:ShowSmallTips(CHS[5400267])
        return
    end

    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    DlgMgr:openDlgEx("BlogFlowersDlg", gid)
end

-- 表情按钮
function BlogMessageDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "blog")

    -- 界面上推
    local height = dlg:getMainBodyHeight()
    DlgMgr:upDlg("BlogMessageDlg", height)
end

-- 插入表情
function BlogMessageDlg:addExpression(expression)
    if not self.inputCtrl then return end

    local content = self.inputCtrl:getText()
    if gf:getTextLength(content .. expression) > WORD_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. expression
    self.inputCtrl:setText(content)
    self:setCtrlVisible("DelButton", true, "OutPanel2")
end

-- 增加空格
function BlogMessageDlg:addSpace()
    if not self.inputCtrl then return end

    local content = self.inputCtrl:getText()
    if gf:getTextLength(content .. " ") > WORD_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    self.inputCtrl:setText(content .. " ")
    self:setCtrlVisible("DelButton", true, "OutPanel2")
end

-- 删除字符
function BlogMessageDlg:deleteWord()
    if not self.inputCtrl then return end

    local text = self.inputCtrl:getText()
    local len  = string.len(text)
    local deletNum = 0

    if len > 0 then
        if string.byte(text, len) < 128 then       -- 一个字符
            deletNum = 1
        elseif string.byte(text, len - 1) >= 128 and string.byte(text, len - 2) >= 224 then    -- 三个字符
            deletNum = 3
        elseif string.byte(text, len - 1) >= 192 then     -- 两个个字符
            deletNum = 2
        end

        local newtext = string.sub(text, 0, len - deletNum)
        self.inputCtrl:setText(newtext)

        if len - deletNum <= 0 then
            self:setCtrlVisible("DelButton", false, "OutPanel2")
        end
    else
        self:setCtrlVisible("DelButton", false, "OutPanel2")
    end
end

-- 发送消息
function BlogMessageDlg:sendMessage(content)
    if not self:isMeetLevel() then return end

    --[[ 若玩家当前是第一次使用留言功能（以是否发布过留言为准），且当前账号尚未完成实名认证，则予以如下弹出提示
    if not Me.bindData or not Me.bindData.isBindName then
    gf:ShowSmallTips(CHS[5400264])
    return
    end]]

    -- 若当前玩家并未输入任何内容，则给予如下弹出提示
    local content = self.inputCtrl:getText()
    if content == nil or string.len(content) == 0 then
        gf:ShowSmallTips(CHS[5400265])
        return
    end

    -- 否则若当前玩家今日在此空间的留言数量已≥100次，则给予如下弹出提示
    -- 你今日在此空间的留言数量已达上限。

    -- 否则若玩家当前输入字符包括敏感字符（详见[敏感词语表详细设计(design)]部分屏蔽字库），则弹出如下提示框
    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(content, nil, true)
    if haveFilt then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[5420088])
        dlg:setCallFunc(function()
            gf:ShowSmallTips(CHS[5400266])
            ChatMgr:sendMiscMsg(CHS[5400266])
            DlgMgr:closeDlg("OnlyConfirmDlg")
            self.inputCtrl:setText(filtTextStr)
        end, true)

        return
    end

    local msgData = self.selectMsgData or {}
    -- 如果性别的表情符添加表情符

    content = BrowMgr:addGenderSign(content)

    -- 更新一下表情使用时间信息
    BrowMgr:updateBrowUseTime(content)

    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    BlogMgr:requestAddBlogMessage(msgData.sender_gid, msgData.iid, content, gid, BlogMgr:getDistByGid(gid), msgData.sender_dist)
end

-- 切换输入
function BlogMessageDlg:swichWordInput()
    if not self.inputCtrl then return end

    self.inputCtrl:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end

-- 表情界面关闭时
function BlogMessageDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("BlogMessageDlg")
end

function BlogMessageDlg:onPopularityInfoButton(sender, eventType)
    -- 数值右侧显示查看按钮，点击后出现如下内容的规则说明悬浮框
    gf:showTipInfo(CHS[5400287], sender)
end

function BlogMessageDlg:onFlowerInfoButton(sender, eventType)


    local curGid = BlogMgr:getBlogGidByDlgName(self.name)
    if not BlogMgr:isSameDist(curGid) then
        gf:ShowSmallTips(CHS[4300368]) -- 跨服对象无法查看赠花。
        return
    end

    -- 打开送花界面
    DlgMgr:openDlgEx("BlogRecordDlg", {type = "flower", gid = curGid, dist = BlogMgr:getDistByGid(curGid)})
end

-- 举报评论
function BlogMessageDlg:onReportCommentForBlog(sender, eventType)
    if not self.selectMsgData then return end
    --gf:ShowSmallTips("=点击了留言板举报评论按钮")


    local para = "@spcial@;" .. self.selectMsgData.message .. CHS[4300499] ..  BlogMgr:getDistByGid(self.blogHostData.user_gid) .. ":" .. self.selectMsgData.iid
    ChatMgr:questOpenReportDlg(self.selectMsgData.sender_gid, self.selectMsgData.sender_name, self.selectMsgData.sender_dist, para)
    self.selectMsgData = nil
end

-- 回复评论
function BlogMessageDlg:onReplyCommentForBlog(sender, eventType)
    if not self.selectMsgData then return end

    -- 设置输入框默认文字
    local name = self.selectMsgData.sender_name



    if not self:isMeetLevel() then return end

    self:switchWritePanel(true)

    self.inputCtrl:setPlaceHolder(string.format(CHS[5400258], name))
end



-- 选择回复对象
function BlogMessageDlg:onOneMessagePanel(sender, eventType)
    local msgData = sender.msgData
    if not msgData or msgData.sender_gid == Me:queryBasic("gid") then
        -- 点击自己发的留言
        -- self:onCloseWriteButton()
        return
    end

    if self.isUnReadView then
        if msgData.char_gid == Me:queryBasic("gid") then
            return
        end

        BlogMgr:openBlog(msgData.char_gid, 2, nil, BlogMgr:getDistByGid(msgData.char_gid))
        BlogMgr:setStartRequestMessage(msgData)
    else
        --[[
        if self.selectMsgData and self.selectMsgData.sender_gid == msgData.sender_gid then
            return
        end
        --]]

        self:onCloseWriteButton()

        -- 取消选中回复对象并清除输入内容
        self:initInputCtrl()
        BlogMgr:showButtonList(self, sender, "blogCommentAndReportForMessage", self.name)

        -- 选中对象
        self.selectMsgData = msgData
    end
end

function BlogMessageDlg:checkIsExsit(iid)
    if not next(self.blogMessageList) then
        return false
    end

    for key, v in ipairs(self.blogMessageList) do
        if v.iid == iid then
            return true
        end
    end

    return false
end

-- 删除留言
function BlogMessageDlg:onDeleteButton(sender, eventType)
    local msgData  = sender:getParent().msgData
    if msgData then
		local dlgName = self.name
        gf:confirm(CHS[5400259], function()
            local gid = BlogMgr:getBlogGidByDlgName(dlgName)
            if gid then
                if self:checkIsExsit(msgData.iid) then
                    local distName = BlogMgr:getDistByGid(gid)
                    BlogMgr:requestDeleteBlogMessage(msgData.iid, gid, distName)
                else
                    gf:ShowSmallTips(CHS[4300293])
                end
            end
        end)

    end
end

-- 角色悬浮框
function BlogMessageDlg:onPortraitPanel(sender, eventType)
    local msgData  = sender:getParent().msgData
    if msgData and msgData.sender_gid ~= Me:queryBasic("gid") then
        local char = {}
        char.gid = msgData.sender_gid
        char.name = msgData.sender_name
        char.level = msgData.sender_level
        char.icon = msgData.sender_icon
        char.isOnline = 2
        local rect = self:getBoundingBoxInWorldSpace(sender)
        char.dist_name = msgData.sender_dist
        if msgData.sender_dist ~= GameMgr:getDistName() then
            FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.KUAFU_BLOG, rect)
        else
            FriendMgr:openCharMenu(char, nil, rect)
        end
    end
end

-- 删除编辑区域内容
function BlogMessageDlg:onDelButton(sender, eventType)
    self.inputCtrl:setText("")
    self:setCtrlVisible("DelButton", false, "OutPanel2")
end

-- 发布留言成功（新留言）
function BlogMessageDlg:MSG_BLOG_MESSAGE_WRITE(data)
    if data.host_gid == BlogMgr:getUserGid(self.name) then
        -- 取消选中回复对象并清除输入内容
        self:initInputCtrl()
    end
end

function BlogMessageDlg:MSG_BLOG_MESSAGE_LIST(data, isUnRead)
    if data.host_gid ~= BlogMgr:getUserGid(self.name) then
        return
    end

    if self.isUnReadView and isUnRead ~= true then
        return
    end

    self:addMessage(data)

    if data.count == -1 then
        -- 服务器繁忙，请稍后再试。
        gf:ShowSmallTips(CHS[4300198])
        ChatMgr:sendMiscMsg(CHS[4300198])

        -- 取消标记，可以继续请求未请求到的数据
        self.lastRequestMessageIId = nil
        self.lastRequestNum = -1
    end

    -- 如果是第一页的数据且无留言，显示莲花姑凉
    if data.request_iid == "" and data.count < 1 then
        self:resetListData()
        if data.count == 0 then
            self.isFirstOpenDlg = false

            if not self.isUnReadView and data.host_gid == Me:queryBasic("gid") then
                BlogMgr:setHasMailRedDotForMessage(nil)
            end
        end

        return
    end

    if data.count < self.lastRequestNum then
        -- 已获取全部数据
        self.isFinishLoad = true
    else
        self.isFinishLoad = false
    end

    self.lastRequestNum = -1
    if data.request_iid == "" or self.isFirstOpenDlg then
        -- 第一页数据
        self.curLoadIndex = 0
        self.lastRequestMessageIId = nil

        local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM, true)
        self:refreshList(moreData, true)

        -- 清除有新消息的小红点标记
        if not self.isUnReadView and data.host_gid == Me:queryBasic("gid") then
            BlogMgr:setHasMailRedDotForMessage(nil)
        end

        self.isFirstOpenDlg = false
    elseif self.isLoading then
        if not data.isUpLoad then
            local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM)
            self:refreshList(moreData)
        else
            self:refreshList(data, nil, true)
            self.curLoadIndex = self.curLoadIndex + #data

            if #data > 0 then
                -- 向上加载数据时，有加载到新数据则提示
                if data[1].time > self.openTime then
                    gf:ShowSmallTips(CHS[5420232])
                    ChatMgr:sendMiscMsg(CHS[5420232])
                end
            else
                -- 向上未加载到数据，表示数据已加载完，清除小红点
                if data.host_gid == Me:queryBasic("gid") then
                    BlogMgr:setHasMailRedDotForMessage(nil)
                end
            end
        end
    end
end

function BlogMessageDlg:getFirstItem()
    local listView = self:getControl("ListView")
    local items = listView:getItems()
    if items[1]:getName() == "LoadingPanel" then
        return items[2]
    else
        return items[1]
    end
end

function BlogMessageDlg:MSG_BLOG_MESSAGE_LIST_ABOUT_ME(data)
    if not self.isUnReadView then
        return
    end

    self:MSG_BLOG_MESSAGE_LIST(data, true)
end

function BlogMessageDlg:MSG_BLOG_MESSAGE_NUM_ABOUT_ME(data)
    if data.count > 0 and self.blogHostData.user_gid == Me:queryBasic("gid") then
        self:setLabelText("UnReadNoteLabel", string.format(CHS[5420234], data.count))
        self:setCtrlVisible("UnReadNotePanel", true)
        BlogMgr:setHasMailRedDotForMessage(nil, "unread")
    else
        self:setCtrlVisible("UnReadNotePanel", false)
    end
end

function BlogMessageDlg:onUnReadNotePanel()
    -- 取消努力加载中
    self:setLoadingVisible(false)

    -- 缓存留言数据
    self.cacheData = {
        blogMessageList = self.blogMessageList,
        selectMsgData = self.selectMsgData,
        isFinishLoad = self.isFinishLoad,
        lastWriteStatus = self.lastWriteStatus,
        curLoadIndex = self.curLoadIndex,
    }

    self:setCtrlVisible("ListView", false)
    self:setCtrlVisible("UnReadListView", true)
    self.curListViewName = "UnReadListView"

    local items = self:getControl("UnReadListView"):getItems()
    self:setCtrlVisible("NoticePanel", #items == 0)

    self.root:stopAction(self.requestDelay)
    BlogMgr:requestBlogUnReadMessageData({}, INIT_LOAD_MESSAGE_NUM)
    self.lastRequestNum = INIT_LOAD_MESSAGE_NUM
    BlogMgr.unReadMessageCount = 0

    self.isUnReadView = true
    self:setCtrlVisible("OutPanel3", true)
    self:setCtrlVisible("OutPanel1", false)
    self:setCtrlVisible("OutPanel2", false)
    self:setCtrlVisible("UnReadNotePanel", false)
end

function BlogMessageDlg:onBackButton()
    -- 取消努力加载中
    self:setLoadingVisible(false)

    -- 重新获取缓存的留言数据
    self.blogMessageList = self.cacheData.blogMessageList
    self.selectMsgData = self.cacheData.selectMsgData
    self.isFinishLoad = self.cacheData.isFinishLoad
    self.lastWriteStatus = self.cacheData.lastWriteStatus
    self.curLoadIndex = self.cacheData.curLoadIndex
    self.lastRequestMessageIId = nil
    self.lastRequestNum = -1

    self:setCtrlVisible("ListView", true)
    self:setCtrlVisible("UnReadListView", false)
    self.curListViewName = "ListView"

    local items = self:getControl("ListView"):getItems()
    self:setCtrlVisible("NoticePanel", #items == 0)

    self.root:stopAction(self.requestDelay)

    self.isUnReadView = false
    self:setCtrlVisible("OutPanel3", false)
    self:setCtrlVisible("OutPanel1", true)
    self:setCtrlVisible("OutPanel2", true)
end

function BlogMessageDlg:MSG_FRIEND_ADD_CHAR(data)
    local curGid = BlogMgr:getUserGid(self.name)
    if curGid ~= Me:queryBasic("gid") then
        if FriendMgr:hasFriend(curGid) then
            self:setCtrlVisible("FriendButton", false, "OutPanel1")
        else
            self:setCtrlVisible("FriendButton", BlogMgr:isSameDist(curGid), "OutPanel1")
        end
    end
end

function BlogMessageDlg:MSG_BLOG_CHAR_INFO(data)
    self.blogHostData = BlogMgr:getUserDataByDlgName(self.name)
    self:refreshInfo(self.blogHostData)
    self:initWritePanel(self.blogHostData)
end

function BlogMessageDlg:MSG_BLOG_FLOWER_UPDATE(data)
    if data.host_gid ~= BlogMgr:getUserGid(self.name) then
        return
    end

    self:setInfoPanel(data)
end

-- 留言列表
function BlogMessageDlg:addMessage(data)
    if data.request_iid == "" or not self.blogMessageList then
        self.blogMessageList = {}
    end

    local oldData = self.blogMessageList
    if #data > 0 then
        if not oldData[1]
            or oldData[1].time > data[1].time
            or (oldData[1].time == data[1].time and oldData[1].iid > data[1].iid) then
            -- 向下加载消息
            for i= 1, #data do
                table.insert(self.blogMessageList, data[i])
            end

            data.isUpLoad = false
        else
            -- 向上加载消息
            self.blogMessageList = {}
            for i = 1, #data do
                table.insert(self.blogMessageList, data[i])
            end

            for i = 1, #oldData do
                table.insert(self.blogMessageList, oldData[i])
            end

            data.isUpLoad = true
        end
    end
end

-- 删除一条留言
function BlogMessageDlg:MSG_BLOG_MESSAGE_DELETE(data)
    if data.host_gid ~= BlogMgr:getUserGid(self.name) then
        return
    end

    if self.isUnReadView then
        return
    end

    if not next(self.blogMessageList) then
        return
    end

    for key, v in ipairs(self.blogMessageList) do
        if v.iid == data.iid then
            -- 先处理 UI 相关再移除数据
            self:removeOneItem(key)
            table.remove(self.blogMessageList, key)
            break
        end
    end
end

return BlogMessageDlg
