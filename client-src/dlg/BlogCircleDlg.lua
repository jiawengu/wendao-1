-- BlogCircleDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间

local BlogCircleDlg = Singleton("BlogCircleDlg", Dialog)

function BlogCircleDlg:init(data)
    self:bindListener("WriteButton", self.onWriteButton)
    self:bindListener("CheckBoxPanel", self.onCheckBoxPanel)
    self:bindListener("UnReadNotePanel", self.onUnReadNotePanel)
    self:bindListener("BackButton", self.onBackButton, "OutPanel2")
    self:bindListViewListener("ListView", self.onSelectListView)

    -- 单个动态总panel
    self.unitStatePanel = self:retainCtrl("OneStatePanel")
    self:bindListener("DeleteButton", self.onDeleteButton, self.unitStatePanel)
    self:bindListener("ReportButton", self.onReportButton, self.unitStatePanel)
    self:bindListener("LikeButton", self.onLikeButton, self.unitStatePanel)
    self:bindListener("TalkButton", self.onTalkButton, self.unitStatePanel)
    self:bindListener("LikePanel", self.onLikeNamePanel, self.unitStatePanel)
    self:bindListener("ZanPanel4", self.onLikeNamePanel, self.unitStatePanel)
    self:bindListener("MoreButton", self.onMoreButton, self.unitStatePanel)
    self:bindListener("PortraitPanel", self.onCharInfoButton, self.unitStatePanel)
    self:bindListener("SheQuPanel", self.onSheQuPanel, self.unitStatePanel)
    for i = 1, 3 do
        self:bindListener("ZanPanel" .. i, self.onCharInfoButton, self.unitStatePanel)
    end
    self.unitTalkPanel = self:retainCtrl("UnitTalkPanel", self.unitStatePanel)
    self:bindTouchEndEventListenerBlog(self.unitTalkPanel, self.onReTalkButton)
    self:bindListener("UserNamePanel", self.onCharInfoButton, self.unitTalkPanel)
    self:bindListener("FirstNamePanel", self.onCharInfoButton, self.unitTalkPanel)
    self:bindListener("SecondNamePanel", self.onCharInfoButton, self.unitTalkPanel)

    -- 相片panel标记上tag
    for i = 1, 4 do
        local panel = self:getControl("PhotoPanel" .. i, nil, self.unitStatePanel)
        panel:setTag(i)
        panel:setVisible(false)
        self:bindTouchEndEventListener(panel, self.onPhotoPanel)
    end
    self:getControl("PhotoPanel3_2", nil, self.unitStatePanel):setTag(3)
    self:setCtrlVisible("PhotoPanel3_2", false, self.unitStatePanel)
    self:bindListener("PhotoPanel3_2", self.onPhotoPanel, self.unitStatePanel)

    self:setCtrlVisible("LoadingPanel", false)
    self:setCtrlVisible("UnReadNotePanel", false)

    if not Me:isBindName() then
        -- 请求实名认证信息
        gf:CmdToServer('CMD_REQUEST_FUZZY_IDENTITY', {force_request = 0})
    end

    self.curListViewName = "ListView"

    self:setCheck("MineCheckBox", false)
    self.lastCheckBoxState = false
    self.isNewquery = false
    self.isUnReadView = false
    self.lastQueryTime = 0
    self.openTime = gfGetTickCount()

    self.listOrgSize = self.listOrgSize or self:getCtrlContentSize("ListView")

    -- 设置界面数据
    self:setData(data)

    local function callback(dlg, percent)
        local list = self:getControl(self.curListViewName)
        if percent > 100 then
            -- 该请求数据了
            local viewType = self:isCheck("MineCheckBox") and 1 or 0
            local lastData = self:getLoadedLastData()
            if lastData and lastData.sid then
                if gfGetTickCount() - self.lastQueryTime > 1000 then
                    local isUnReadView = self.isUnReadView
                    self.root:stopAction(self.delayRequest)
                    self.delayRequest = performWithDelay(self.root, function ()
                        -- 延迟请求的原因是：如果在listView回滚时，数据来了，它会回滚至底部！！
                        if isUnReadView then
                            BlogMgr:queryUnReadStatusList(lastData.sid)
                        else
                            BlogMgr:queryBlogsList(BlogMgr:getUserGid(self.name), lastData.sid, viewType)
                        end
                    end, 0.5)
                    self.lastQueryTime = gfGetTickCount()
                    local lodingPanel = self:getControl("LoadingPanel"):clone()
                    lodingPanel:setVisible(true)
                    lodingPanel:setName("LoadingPanel")
                    lodingPanel.data = {}
                    list:pushBackCustomItem(lodingPanel)
                else
                    gf:ShowSmallTips(CHS[4200455])
                end
            end
        elseif percent == 0 and not self.isUnReadView then
            if list:getInnerContainerSize().height == list:getContentSize().height then
                if list:getInnerContainer():getPositionY() < -50 then
                    -- 拉动距离大于50
                    -- 判断是否在请求中
                    if not list:getChildByName("LoadingPanel") then
                        if gfGetTickCount() - self.lastQueryTime > 1000 then
                            self.root:stopAction(self.delayRequest)
                            self.delayRequest = performWithDelay(self.root, function ()
                                -- 延迟请求的原因是：好看一些
                                local viewType = self:isCheck("MineCheckBox") and 1 or 0
                                BlogMgr:queryBlogsList(BlogMgr:getUserGid(self.name), nil, viewType)
                            end, 0.5)

                            self.lastQueryTime = gfGetTickCount()

                            local lodingPanel = self:getControl("LoadingPanel"):clone()
                            lodingPanel:setVisible(true)
                            lodingPanel:setName("LoadingPanel")
                            lodingPanel.data = {}
                            list:insertCustomItem(lodingPanel, 0)

                            local viewType = self:isCheck("MineCheckBox") and 1 or 0

                            self.isNewquery = true
                        else
                            gf:ShowSmallTips(CHS[4200455])
                        end
                    end
                end
            end
        elseif percent < 0 and not self.isUnReadView then
            if math.abs(list:getInnerContainerSize().height * percent * 0.01) > 50 then
                -- 拉动距离大于50

                -- 判断是否在请求中
                if not list:getChildByName("LoadingPanel") then
                    if gfGetTickCount() - self.lastQueryTime > 1000 then
                        self.root:stopAction(self.delayRequest)
                        self.delayRequest = performWithDelay(self.root, function ()
                            -- 延迟请求的原因是：好看一些
                            local viewType = self:isCheck("MineCheckBox") and 1 or 0
                            BlogMgr:queryBlogsList(BlogMgr:getUserGid(self.name), nil, viewType)
                        end, 0.5)

                        self.lastQueryTime = gfGetTickCount()

                        local lodingPanel = self:getControl("LoadingPanel"):clone()
                        lodingPanel:setVisible(true)
                        lodingPanel:setName("LoadingPanel")
                        lodingPanel.data = {}
                        list:insertCustomItem(lodingPanel, 0)

                        local viewType = self:isCheck("MineCheckBox") and 1 or 0

                        self.isNewquery = true
                    else
                        gf:ShowSmallTips(CHS[4200455])
                    end
                end
            end
        end
    end

    -- 下拉请求数据
    self:bindListViewByPageLoad("ListView", "TouchPanel", callback)

    self:bindListViewByPageLoad("UnReadListView", "UnReadTouchPanel", callback)

    -- 优化listView显示规则
    self:setListViewItemVisible()

    performWithDelay(self.root, function()
        self:MSG_BLOG_STATUS_NUM_ABOUT_ME({count = BlogMgr.unReadStatueCount or 0})
    end, 0)

    self:hookMsg("MSG_BLOG_UPDATE_ONE_STATUS")
    self:hookMsg("MSG_BLOG_REQUEST_STATUS_LIST")
    self:hookMsg("MSG_BLOG_DELETE_ONE_STATUS")
    self:hookMsg("MSG_BLOG_ALL_COMMENT_LIST")
    self:hookMsg("MSG_BLOG_UPDATE_ONE_STATUS")
    self:hookMsg("MSG_BLOG_STATUS_NUM_ABOUT_ME")
    self:hookMsg("MSG_BLOG_STATUS_LIST_ABOUNT_ME")
    self:hookMsg("MSG_BLOG_LIKE_ONE_STATUS")

    self:hookMsg("MSG_OFFLINE_CHAR_INFO")
    self:hookMsg("MSG_CROSS_SERVER_CHAR_INFO")

    self:hookMsg("MSG_CHAR_INFO_EX")
end

-- 全部显示太卡，用于只显示显示区域中的
function BlogCircleDlg:setListViewItemVisible()
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            performWithDelay(self.root, function ()
                local items = sender:getItems()
                for _, panel in pairs(items) do
                    local curListY = sender:getInnerContainer():getPositionY()
                    local panelY = panel:getPositionY()
                    local panelSize = panel:getContentSize()

                    if sender:getContentSize().height >= sender:getInnerContainer():getContentSize().height then
                        panel:setVisible(true)
                    else
                        if curListY + panelY + panelSize.height > 0 and panelY + curListY < sender:getContentSize().height then
                            panel:setVisible(true)
                        else
                            panel:setVisible(false)
                        end
                    end
                end
            end, 0)
        end
    end
    self:getControl("ListView"):addScrollViewEventListener(onScrollView)
end

function BlogCircleDlg:cleanup()
    -- 由于Tab标签页切换，有时候只关闭该对话框，所以需要手动关闭 BlogInfoDlg
    DlgMgr:closeDlg("BlogInfoDlg")
end

function BlogCircleDlg:onCheckBoxPanel(sender, eventType)

    sender.lastTime = sender.lastTime or 0
    if gfGetTickCount() - sender.lastTime < 1000 then
        gf:ShowSmallTips(CHS[4300276]) -- 请勿频繁操作。
        return
    end

    sender.lastTime = gfGetTickCount()
    local check = self:getControl("MineCheckBox")
    if check:getSelectedState() then
        check:setSelectedState(false)
        BlogMgr:switchViewSetting(0)
    else
        check:setSelectedState(true)
        BlogMgr:switchViewSetting(1)
    end

    self:resetListView("ListView")
end

function BlogCircleDlg:setMyBlog(isMe)

    if not isMe then isMe = BlogMgr:isMySelf(self.name) end

    -- 是否是我的空间
    self:setCtrlVisible("OutPanel", isMe)

    if isMe then
        self:setCtrlContentSize("ListView", nil, self.listOrgSize.height)
        self:setCtrlContentSize("UnReadListView", nil, self.listOrgSize.height)
    else
        self:setCtrlContentSize("ListView", nil, self.listOrgSize.height + 63)
        self:setCtrlContentSize("UnReadListView", nil, self.listOrgSize.height)
    end

    if isMe then
        self:setLabelText("TitleLabel_2", CHS[4100856]) -- 我的空间
    else
        local userName = BlogMgr:getUserName(self.name)
        if not string.isNilOrEmpty(userName) then
            self:setLabelText("TitleLabel_2", string.format(CHS[4100857],  userName))   -- XXs的空间
        else
            self:setLabelText("TitleLabel_2", "")   -- XXs的空间
        end
    end

end

function BlogCircleDlg:setData(data)
    self.gid = data.uid

    -- 设置界面控件初始化显示,数据没有到的话，要重新刷新
    self:setMyBlog()

    -- 设置好友圈动态
    self:setFriendsDynamics(data)
end


-- 设置好友动态列表
function BlogCircleDlg:setFriendsDynamics(data)
    local list = self:resetListView(self.curListViewName)
    BlogMgr:cleanAutoLoad(self.name)
    if data.count <= 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    self:setCtrlVisible("NoticePanel", false)

    -- 加载进listView
    self:loadFriendsDynamics(data)
end

function BlogCircleDlg:loadFriendsDynamics(data)
    local list = self:getControl(self.curListViewName)

    local height = 0
    local items = list:getItems()
    for i = 1, #items do
        height = height + items[i]:getContentSize().height
    end

    for i = 1, data.count do
        local panel = self.unitStatePanel:clone()
        panel.data = data[i]
        list:pushBackCustomItem(panel)
        self:setUnitDynamics(data[i], panel)

        height = height + panel:getContentSize().height
        list:requestDoLayout()
        list:requestRefreshView()
        list:refreshView()
    end
end

function BlogCircleDlg:getCheckState()
    return self:isCheck("MineCheckBox") and 1 or 0
end

-- 获取时间显示
function BlogCircleDlg:getDisplayTime(time)
    local passTime = gf:getServerTime() - time
    if passTime < 60 * 60 then
        return string.format(CHS[4100700], math.max(math.ceil(passTime / 60), 1))
    elseif passTime < 60 * 60 * 24 then
        return string.format(CHS[4100775], math.floor(passTime / (60 * 60)))
    end

    return os.date("%Y-%m-%d", time)
end

-- 设置朋友圈照片
function BlogCircleDlg:setPhoto(path, para)
    local tab = gf:split(para, "|")
    if not tab then return end
    local sid = tab[1]
    local ctlName = tab[2]

    local list = self:getControl(self.curListViewName)
    local items = list:getItems()

    for _, panel in pairs(items) do
        if panel.data and sid == panel.data.sid then
            local ctlPanel = self:getControl(ctlName, nil, panel)
            if ctlPanel then
                if not path or path == "" then
                    self:setCtrlVisible("PhotoBKImage3", true, ctlPanel)
                else
                    self:setImage("PhotoImage", path, ctlPanel)
                    self:setSmallImageSize("PhotoImage", ctlPanel)
                end

                self:setCtrlVisible("PhotoBKImage1", false, ctlPanel)
            end
        end
    end

    list:requestRefreshView()
end

function BlogCircleDlg:setSmallImageSize(imageName, panel)
    local image = self:getControl(imageName, nil, panel)
    local orgSize = image:getContentSize()
    -- 144 * 96缩略图尺寸
    local w1 = orgSize.width
    local h1 = orgSize.height
    local w2 = 144
    local h2 = 96

    if w1 / h1 > w2 / h2 then
        self:setImageSize(imageName, cc.size(w1 * h2 / h1, h2), panel)
    else
        self:setImageSize(imageName, cc.size(w2, h1 * w2 / w1), panel)
    end

end

-- 设置单个朋友圈动态
function BlogCircleDlg:setUnitDynamics(data, panel)
    -- 不是我的空间，非好友，没有信息
    if not BlogMgr:isMySelf(self.name) then
        local info = BlogMgr:getUserDataByGid(self.gid)
        if not data.icon then
            local icon = ResMgr:getIconByPolarAndGender(info.polar, info.gender)
            data.icon = icon
        end

        if not data.level then
            data.level = info.level
        end

        if not data.name then
            data.name = info.name
        end
    end

    -- 时间
    self:setLabelText("TimeLabel", self:getDisplayTime(data.time), panel)

    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)

    -- 跨服
    if data.dist ~= GameMgr:getDistName() then
        gf:addKuafLogo(self:getControl("PortraitPanel", nil, panel))
    end

    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
    self:getControl("PortraitPanel", nil, panel).data = {uid = data.uid, dist = data.dist}

    -- 名字
    self:setLabelText("NameLabel", data.name, panel)

    panel.isExpand = self.isUnReadView and 1 or 0

    -- 举报按钮是否显示
    self:setCtrlVisible("ReportButton", data.uid ~= Me:queryBasic("gid"), panel)
    self:setCtrlVisible("ReportTextLabel", data.uid ~= Me:queryBasic("gid"), panel)

    -- 删除按钮是否显示
    self:setCtrlVisible("DeleteButton", data.uid == Me:queryBasic("gid"), panel)


    -- 设置动态文字信息
    if data.text == "" then
        self:setCtrlContentSize("TextPanel", nil, 0, panel)
    else
        -- self:setColorText(data.text, "TextPanel", panel, nil, nil, nil, 19, nil, nil, data.insider >= 1)
        self:setUnitText(panel, data)
    end

    -- 设置动态图片信息
    local pictureData = {}
    if data.img_str ~= "" then
        pictureData.path = gf:split(data.img_str, "|")
        pictureData.count = #pictureData.path
    else
        pictureData = {count = 0}
    end

    local photoPanel = self:getControl("PhotoPanel", nil, panel)
    photoPanel.img_str = data.img_str

    if pictureData.count > 3 then
        -- 大于3显示两行
        local op = {process = BlogMgr.PHOTO_SMALL_SIZE_STR}

        BlogMgr:assureFile("setPhoto", self.name, pictureData.path[1], op, data.sid .. "|PhotoPanel1")
        local panel1 = self:getControl("PhotoPanel1", nil, panel)
        panel1.path = pictureData.path[1]
        panel1.op = op
        panel1.para = data.sid .. "|PhotoPanel1"
        self:setCtrlVisible("PhotoPanel1", true, panel)

        BlogMgr:assureFile("setPhoto", self.name, pictureData.path[2], op, data.sid .. "|PhotoPanel2")
        local panel1 = self:getControl("PhotoPanel2", nil, panel)
        panel1.path = pictureData.path[2]
        panel1.op = op
        panel1.para = data.sid .. "|PhotoPanel2"
        self:setCtrlVisible("PhotoPanel2", true, panel)

        BlogMgr:assureFile("setPhoto", self.name, pictureData.path[3], op, data.sid .. "|PhotoPanel3_2")
        local panel1 = self:getControl("PhotoPanel3_2", nil, panel)
        panel1.path = pictureData.path[3]
        panel1.op = op
        panel1.para = data.sid .. "|PhotoPanel3"
        self:setCtrlVisible("PhotoPanel3_2", true, panel)

        BlogMgr:assureFile("setPhoto", self.name, pictureData.path[4], op, data.sid .. "|PhotoPanel4")
        local panel1 = self:getControl("PhotoPanel4", nil, panel)
        panel1.path = pictureData.path[4]
        panel1.op = op
        panel1.para = data.sid .. "|PhotoPanel4"
        self:setCtrlVisible("PhotoPanel4", true, panel)

    elseif pictureData.count >= 1 then
        -- 小于等于3显示一行
        for i = 1, 3 do
            if pictureData.path[i] then
                local op = {process = BlogMgr.PHOTO_SMALL_SIZE_STR}
                BlogMgr:assureFile("setPhoto", self.name, pictureData.path[i], op, data.sid .. "|PhotoPanel" .. i)
                local panel1 = self:getControl("PhotoPanel" .. i, nil, panel)
                panel1.path = pictureData.path[i]
                panel1.op = op
                panel1.para = data.sid .. "|PhotoPanel" .. i
                self:setCtrlVisible("PhotoPanel" .. i, true, photoPanel)
            end
        end

        local photoPanel = self:getControl("PhotoPanel", nil, panel)
        photoPanel:setContentSize(photoPanel:getContentSize().width, photoPanel:getContentSize().height * 0.5)
    else
        local photoPanel = self:getControl("PhotoPanel", nil, panel)

        if self:getCtrlVisible("SheQuPanel", panel) then
            local contentSize = self:getCtrlContentSize("SheQuPanel", panel)
            photoPanel:setContentSize(photoPanel:getContentSize().width, contentSize.height)
        else
            photoPanel:setContentSize(photoPanel:getContentSize().width, 0)
        end
    end

    -- 设置点赞者
    self:setUnitDynamicsForZanData(data, panel)

    -- 设置聊天互动
    self:setUnitDynamicsForTalk(data, panel)

    self:setAutoSize(panel)

    panel.data = data
end

-- 设置单个动态，朋友圈的互动
function BlogCircleDlg:setUnitDynamicsForTalk(data, panel)
    self:setLabelText("TalkNumLabel", data.comment_num, panel)

    local talkData = data.commentData
    local talkPanel = self:getControl("TalkTetPanel", nil, panel)
    talkPanel:removeAllChildren()
    talkPanel:setLayoutType(ccui.LayoutType.VERTICAL) -- 设置垂直布局
    local totalHeight = 0

    table.sort(talkData, function(l, r)
        if l.cid > r.cid then return true end
        if l.cid < r.cid then return false end
        return false
    end)


    for i = 1, data.comment_count do
        if talkData[i] then
            local unitTalkPanel = self.unitTalkPanel:clone()
            local height = self:setUnitDynamicsForUnitTalk(talkData[i], unitTalkPanel)
            local lp = ccui.LinearLayoutParameter:create()
            unitTalkPanel:setLayoutParameter(lp)
            lp:setGravity(ccui.LinearGravity.centerHorizontal)
            lp:setMargin({left = 0, top = 3, right = 0, bottom = 0})
            talkPanel:addChild(unitTalkPanel)
            totalHeight = totalHeight + height + 3
        end
    end

    if totalHeight ~= 0 then
        totalHeight = totalHeight + 10  -- 10的间隔，让界面好看一点
    end

    talkPanel:requestDoLayout()

    local root = self:getControl("TalkPanel", nil, panel)
    root:setContentSize(root:getContentSize().width, totalHeight + self:getCtrlContentSize("ZanListPanel", panel).height)
    self:setCtrlContentSize("BKImage", nil, root:getContentSize().height - 2, root)
    self:setCtrlVisible("BKImage", root:getContentSize().height ~= 0, root)

    root:requestDoLayout()

    self:setCtrlVisible("MoreButton", data.comment_num > 5 and (1 ~= panel.isExpand), panel)
end

-- 设置单个聊天
function BlogCircleDlg:setUnitDynamicsForUnitTalk(data, panel)
    local height = 0
    local nameStr = ""
    local talkPanel
    panel.data = data
    if data.reply_name ~= "" then
        self:setCtrlVisible("OneUserPanel", false, panel)
        talkPanel = self:getControl("TwoUserPanel", nil, panel)

        -- 如果有被回复者，则用两个玩家名的panel   例如  A回复B 回复内容
        -- 设置说话者
        local nameStr1 = string.format("#G[%s]#n", data.name)
        local namePanel1 = self:setColorTextAutoSetSize(nameStr1,"FirstNamePanel", panel)
        namePanel1.data = data
        namePanel1:removeAllChildren()

        -- 回复
        local huifuPanel = self:setColorTextAutoSetSize(CHS[4100858],"MidPanel", panel)
        huifuPanel:removeAllChildren()

        -- 被回复者
        local nameStr2 = string.format("#G[%s]#n", data.reply_name)
        local namePanel2 = self:setColorTextAutoSetSize(nameStr2,"SecondNamePanel", panel)
        namePanel2.data = {name = data.reply_name, uid = data.reply_uid, dist = data.reply_dist}
        namePanel2:removeAllChildren()

        nameStr = nameStr1 .. CHS[4100858] .. nameStr2


        local panel1 = self:getControl("FirstNamePanel", nil, panel)
        self:setCtrlOpacity("NameClick", 0, panel1)
        self:setCtrlVisible("NameClick", false, panel1)

        local panel1 = self:getControl("FirstNamePanel", nil, panel)
        self:setCtrlOpacity("MidPanel", 0, panel)
        self:setCtrlOpacity("SecondNamePanel", 0, panel)
    else
        self:setCtrlVisible("TwoUserPanel", false, panel)
        talkPanel = self:getControl("OneUserPanel", nil, panel)


        -- 设置玩家
        nameStr = string.format("#G[%s]#n", data.name)
        local namePanel = self:setColorTextAutoSetSize(nameStr, "UserNamePanel", panel)
        -- 由于该层只要响应点击事件，要是不把内容删除，有表情是，高度不一样，会错乱
        namePanel:removeAllChildren()

        self:getControl("UserNamePanel", nil, panel).data = data
    end

    panel.talkPanel = talkPanel
    local contentStr = nameStr .. "：" .. data.text
    local conPanel = self:getControl("ContentPanel", nil, talkPanel)

    local isInsider = (data.insider and data.insider >= 1) and true or false
    height = self:setColorText(contentStr, conPanel, nil, nil, nil, nil, 19, nil, nil, isInsider)

    local touchImage = self:getControl("TouchImage", nil, conPanel)
    touchImage:setContentSize(conPanel:getContentSize().width + 30, conPanel:getContentSize().height + 6)
    touchImage:setVisible(false)
 --   touchImage:setAnchorPoint(0.5, 0.5)
    touchImage:setPosition(conPanel:getContentSize().width * 0.5, conPanel:getContentSize().height * 0.5)
    conPanel:requestDoLayout()
    panel:setContentSize(conPanel:getContentSize())

    return height
end

-- 设置单个朋友圈动态           点赞数据设置
function BlogCircleDlg:setUnitDynamicsForZanData(data, panel)
    self:setLabelText("LikeNumLabel", data.like_num, panel)

    if data.isLike then
        self:setImage("LikeIconImage", ResMgr.ui.likeImage, panel)
    end

    local zanData = data.likeNameList
    for i = 1, 3 do
        if zanData[i] then
            local zanUnitPanel = self:getControl("ZanPanel" .. i, nil, panel)
            local nameStr = string.format("#G[%s]#n", zanData[i].name)
            self:setColorTextAutoSetSize(nameStr, zanUnitPanel, panel)
            zanUnitPanel.data = zanData[i]
        else
            self:setCtrlContentSize("ZanPanel" .. i, 0, nil, panel)
        end
    end

    if data.like_num > 3 then
        self:setCtrlVisible("ZanPanel4", true, panel)
        self:setColorText(" #G...#n", "ZanPanel4", panel, nil, nil, nil, 19)
    else
        self:setCtrlVisible("ZanPanel4", false, panel)
    end

    -- 点赞为0，需要自适应
    if data.like_count == 0 then
        self:setCtrlVisible("ZanListPanel", false, panel)
        self:setCtrlContentSize("ZanListPanel", nil, 0, panel)
    else
        self:setCtrlVisible("ZanListPanel", true, panel)
        local size = self:getCtrlContentSize("ZanListPanel", self.unitStatePanel)
        self:setCtrlContentSize("ZanListPanel", nil, size.height + 4, panel)
    end

    local zanListPanel = self:getControl("ZanListPanel", nil, panel)

    self:setCtrlVisible("LineImage", data.like_count ~= 0 and data.comment_num ~= 0, zanListPanel)
end

-- 显示字符串
function BlogCircleDlg:setColorTextAutoSetSize(str, panelName, root, marginX, marginY, defColor, fontSize, isPunct, insider)
    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 19
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, insider)
    textCtrl:setContentSize(400, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    local colorTLayer = tolua.cast(textCtrl, "cc.LayerColor")
    colorTLayer:setPosition(0,textH)
    colorTLayer:setName("NameClick")
    panel:addChild(colorTLayer)
    local panelHeight = textH + 2 * marginY
    panel:setContentSize(textW, panelHeight)

    return panel
end


function BlogCircleDlg:setAutoSize(panel)
    -- 动态文字内容panel
    local height1 = self:getCtrlContentSize("TextPanel", self.unitStatePanel).height - self:getCtrlContentSize("TextPanel", panel).height


    -- 照片
    local height2 = self:getCtrlContentSize("PhotoPanel", self.unitStatePanel).height - self:getCtrlContentSize("PhotoPanel", panel).height

    -- 回复
    local height3 = self:getCtrlContentSize("TalkPanel", panel).height
    -- 点赞者
    local height4 = self:getCtrlContentSize("ZanListPanel", panel).height
    local height5 = 8
    if height5 ~= 0 then height5 = height5 + 10 end

    panel:setContentSize(self.unitStatePanel:getContentSize().width, self.unitStatePanel:getContentSize().height - height1 - height2 + height3 + height5)
    panel:requestDoLayout()
end

-- 点击相片
function BlogCircleDlg:onPhotoPanel(sender, eventType)
    if self:getCtrlVisible("PhotoBKImage3", sender) then
        -- 加载失败的图片
        self:setCtrlVisible("PhotoBKImage3", false, sender)
        self:setCtrlVisible("PhotoBKImage1", true, sender)
        BlogMgr:assureFile("setPhoto", self.name, sender.path, sender.op, sender.para)
    else
        local img_str = sender:getParent().img_str
        local dlg = DlgMgr:openDlg("BlogPhotoDlg")
        dlg:setPicture(sender:getTag(), img_str)
    end
end

-- 点击玩家名字
function BlogCircleDlg:onCharInfoButton(sender, eventType)
    if not sender.data then return end
    if sender.data.uid == Me:queryBasic("gid") then return end

    self.selectCharGid = sender.data.uid

    FriendMgr:requestCharMenuInfo(sender.data.uid, nil, nil, 1, nil, sender.data.dist)
end

function BlogCircleDlg:onWriteButton(sender, eventType)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[4100859])
        return
    end

    -- 实名认证（防沉迷）
    if Me:getAdultStatus() == 2 then

        gf:ShowSmallTips(CHS[4100860])
        return
    end

    local userDefault = cc.UserDefault:getInstance()
    local isNeedAG = userDefault:getIntegerForKey("BlogAgreementDlg", 0)

    -- 是否需要弹协议
    if isNeedAG == 0 then
        DlgMgr:openDlgEx("BlogAgreementDlg", self.name)
        return
    end

    DlgMgr:openDlgEx("BlogStateDlg", self.name)
end

function BlogCircleDlg:onLikeButton(sender, eventType)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[4100861])
        return
    end

    -- 单条朋友圈的总panel
    local onePanel = sender:getParent():getParent()
    BlogMgr:likeStatusById(onePanel.data.sid, onePanel.data.dist, onePanel.data.uid)
end

-- 点击点赞人区域
function BlogCircleDlg:onLikeNamePanel(sender, eventType)
    local onePanel = sender:getParent():getParent():getParent()
    if sender:getName() == "ZanPanel4" then
        onePanel = sender:getParent():getParent():getParent():getParent()
    end

    local data = onePanel.data

    DlgMgr:openDlgEx("BlogRecordDlg", {type = "like", para = data.sid, gid = self.gid, dist = data.dist})
end

-- 删除评论
function BlogCircleDlg:onDelComment(sender, eventType)
    if not self.opComment then return end
    gf:confirm(CHS[4200464], function ()
        BlogMgr:deleteComment(self.opComment.sid, self.opComment.cid, self.opComment.isExpand, self.opComment.status_dist)
    end)
end

function BlogCircleDlg:onReComment(sender, eventType)
    if not self.opComment then return end
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    local ret = {name = self.opComment.name, uid = self.opComment.uid, sid = self.opComment.sid, reply_cid = self.opComment.cid, reply_dist = self.opComment.reply_dist, isExpand = self.opComment.isExpand, charGid = self.opComment.charGid, status_dist = self.opComment.status_dist}
    dlg:setData(ret)
end

function BlogCircleDlg:opTalkButton(sender)
    local data = sender.data
    local mainPanel = sender:getParent():getParent():getParent()
    local mainData = mainPanel.data

    -- 我是发布者
    if Me:queryBasic("gid") == mainData.uid then
        if Me:queryBasic("gid") ~= data.uid then
            -- 不是评论发布者，弹出回复、删除
            BlogMgr:showButtonList(self, sender, "blogCommentOp", self.name)
            self.opComment = {name = data.name, uid = mainData.uid, reply_dist = data.dist, sid = mainData.sid, cid = data.cid, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
        else
            -- 我是评论者，删除
            BlogMgr:showButtonList(self, sender, "blogDelCommentOp", self.name)
            self.opComment = {name = data.name, uid = mainData.uid, reply_dist = data.dist, sid = mainData.sid, cid = data.cid, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
        end
        return
    end

    -- 我不是动态发布者
    if Me:queryBasic("gid") ~= mainPanel.uid then
        if Me:queryBasic("gid") ~= data.uid then
            -- 不是评论发布者
            BlogMgr:showButtonList(self, sender, "blogCommentAndReport", self.name)
            self.opComment = {name = data.name, uid = mainData.uid, sid = mainData.sid, reply_cid = data.cid, reply_dist = data.dist, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist,
                text = data.text
            }
            --[[
            local dlg = DlgMgr:openDlg("BlogCommentDlg")
            local ret = {name = data.name, uid = mainData.uid, sid = mainData.sid, reply_cid = data.cid, reply_dist = data.dist, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
            dlg:setData(ret)
            --]]
        else
            -- 我是评论者，删除
            BlogMgr:showButtonList(self, sender, "blogDelCommentOp", self.name)
            self.opComment = {name = data.name, uid = mainData.uid, reply_dist = data.dist, sid = mainData.sid, cid = data.cid, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
        end
        return
    end
end

-- 举报评论
function BlogCircleDlg:onReportCommentForBlog(sender, eventType)
    if not self.opComment then return end

    local para = "@spcial@;" .. self.opComment.text .. CHS[4300500] ..  self.opComment.status_dist .. ":" .. self.opComment.sid .. "-" .. self.opComment.reply_cid
    ChatMgr:questOpenReportDlg(self.opComment.charGid, self.opComment.name, self.opComment.reply_dist, para)
end

-- 回复评论
function BlogCircleDlg:onReplyCommentForBlog(sender, eventType)
    if not self.opComment then return end
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    dlg:setData(self.opComment)
end

-- 点击具体某个评论
function BlogCircleDlg:onReTalkButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:opTalkButton(sender)
        self:setCtrlVisible("TouchImage", false, sender.talkPanel)
    elseif eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("TouchImage", true, sender.talkPanel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("TouchImage", false, sender.talkPanel)
    end
end

-- 点击评论按钮
function BlogCircleDlg:onTalkButton(sender, eventType)
    local onePanel = sender:getParent():getParent()
    local data = onePanel.data

    -- 打开评论界面
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    local ret = {uid = data.uid, sid = data.sid, reply_dist = data.dist, reply_cid = 0, isExpand = onePanel.isExpand, name = data.name, charGid = data.uid, status_dist = data.dist}
    dlg:setData(ret)
end

-- 点击举报
function BlogCircleDlg:onReportButton(sender, eventType)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[4100862])
        return
    end

    local data = sender:getParent():getParent().data
    BlogMgr:reportStatus(data.uid, data.sid, data.dist)
end

function BlogCircleDlg:onMoreButton(sender, eventType)
    local data = sender:getParent():getParent().data
    BlogMgr:queryAllComment(data.sid, data.dist)
    sender:setVisible(false)
end

function BlogCircleDlg:onDeleteButton(sender, eventType)
    gf:confirm(CHS[4100863], function ()
        local onePanel = sender:getParent():getParent()
        local data = onePanel.data
        BlogMgr:deleteStatus(data.sid)
    end)
end

function BlogCircleDlg:onSheQuPanel(sender, eventType)
    local articleId = sender.articleId
    if not articleId then return end
    CommunityMgr:openCommunityDlg(articleId)
end

function BlogCircleDlg:onSelectListView(sender, eventType)
end

function BlogCircleDlg:MSG_BLOG_UPDATE_ONE_STATUS(data)
    -- 正常显示的状态
    local list = self:getControl("ListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel.data and panel.data.sid == data.sid then
            -- 设置点赞者
            self:setUnitDynamicsForZanData(data, panel)

            -- 设置聊天互动
            self:setUnitDynamicsForTalk(data, panel)

            self:setAutoSize(panel)
        end
    end

    list:requestRefreshView()

    -- 同时刷新未读的状态
    if self.curListViewName ~= "UnReadListView" then
        -- 未读状态打开界面期间只显示一次，所以只要显示期间刷新就行
        return
end

    local list = self:getControl("UnReadListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel.data and panel.data.sid == data.sid then
            -- 设置点赞者
            self:setUnitDynamicsForZanData(data, panel)

            -- 设置聊天互动
            self:setUnitDynamicsForTalk(data, panel)

            self:setAutoSize(panel)
        end
    end

    list:requestRefreshView()
end

-- 获取已经显示的最后一条数据
function BlogCircleDlg:getLoadedLastData()
    local list = self:getControl(self.curListViewName)
    local items = list:getItems()

    local count = #items
    if count ~= 0 then
        return items[count].data
    end
end


function BlogCircleDlg:MSG_BLOG_REQUEST_STATUS_LIST(data)
    if data.uid ~= BlogMgr:getBlogGidByDlgName(self.name) then return end

    if self:isCheck("MineCheckBox") ~= (data.viewType ~= 0) then
        return
    end

    local listName = "ListView"

    local list = self:getControl(listName)
    local loadingPanel = list:getChildByName("LoadingPanel")
    list:removeChild(loadingPanel)
    list:refreshView()

    if gfGetTickCount() - self.openTime <= 1000 then
        return
    end

    local items = list:getItems()
    if #items == 0 then
        -- 直接重新设置界面
        self:setFriendsDynamics(data)
    else
        if data.count == 0 then
            -- 向下拉，没有了
            gf:ShowSmallTips(CHS[4200456])--当前已显示所有历史状态，没有更多内容了。
        else
            local lastData = items[#items].data
            if lastData.time and lastData.time > data[1].time then
                -- 下拉加载数据，直接push进去就好了
                self:loadFriendsDynamics(data)

            else
                if self.lastCheckBoxState == (data.viewType ~= 0) and self.isNewquery then
                    if items[1].data.time ~= data[1].time then
                        gf:ShowSmallTips(CHS[4200465])
                        ChatMgr:sendMiscMsg(CHS[4200465])
                    end
                end

                -- 这种情况正常为，重新刷新界面了
                self:setFriendsDynamics(data)
            end
        end
    end
    list:refreshView()
    self.isNewquery = false
    self.lastCheckBoxState = self:isCheck("MineCheckBox")
end

-- 点赞成功
function BlogCircleDlg:MSG_BLOG_LIKE_ONE_STATUS(data)
    local list = self:getControl("ListView")
    local items = list:getItems()
    for _, item in pairs(items) do
        if item.data and item.data.sid == data.sid then
            self:setImage("LikeIconImage", ResMgr.ui.likeImage, item)
            break
        end
    end

    -- 未读面板的点赞
    if self.curListViewName == "UnReadListView" then
        local list = self:getControl("UnReadListView")
        local items = list:getItems()
        for _, item in pairs(items) do
            if item.data and item.data.sid == data.sid then
                self:setImage("LikeIconImage", ResMgr.ui.likeImage, item)
                break
            end
        end
    end

    gf:showTipAndMisMsg(CHS[5420322])
end

--
function BlogCircleDlg:MSG_BLOG_STATUS_LIST_ABOUNT_ME(data)
    if data.uid ~= BlogMgr:getBlogGidByDlgName(self.name) then return end

    local listName = "UnReadListView"
    local list = self:getControl(listName)
    local loadingPanel = list:getChildByName("LoadingPanel")
    list:removeChild(loadingPanel)
    list:refreshView()

    local items = list:getItems()
    if #items == 0 then
        -- 直接重新设置界面
        self:setFriendsDynamics(data)
    else
        if data.count == 0 then
            -- 向下拉，没有了
            gf:ShowSmallTips(CHS[4200456])--当前已显示所有历史状态，没有更多内容了。
        else
            self:loadFriendsDynamics(data)
        end
    end

    list:refreshView()
    self.isNewquery = false
    self.lastCheckBoxState = self:isCheck("MineCheckBox")
end

function BlogCircleDlg:onUnReadNotePanel()
    self.isNewquery = false
    self:setCtrlVisible("ListView", false)
    self:setCtrlVisible("UnReadListView", true)
    self:setCtrlVisible("TouchPanel", false)
    self:setCtrlVisible("UnReadTouchPanel", true)
    self:resetListView("UnReadListView")
    self.curListViewName = "UnReadListView"

    self.root:stopAction(self.delayRequest)
    BlogMgr:queryUnReadStatusList()
    BlogMgr.unReadStatueCount = 0

    self:setCtrlVisible("NoticePanel", false)
    self:setLabelText("InfoLabel1", CHS[5420237], "NoticePanel")

    self.isUnReadView = true
    self:setCtrlVisible("OutPanel2", true)
    self:setCtrlVisible("OutPanel", false)
    self:setCtrlVisible("UnReadNotePanel", false)
end

function BlogCircleDlg:onBackButton()
    self:setCtrlVisible("ListView", true)
    self:setCtrlVisible("UnReadListView", false)
    self:setCtrlVisible("TouchPanel", true)
    self:setCtrlVisible("UnReadTouchPanel", false)
    self.curListViewName = "ListView"

    self.root:stopAction(self.delayRequest)

    local list = self:getControl("ListView")
    local items = list:getItems()
    if #items <= 0 then
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    self:setLabelText("InfoLabel1", CHS[5420238], "NoticePanel")

    self.isUnReadView = false
    self:setCtrlVisible("OutPanel2", false)
    self:setCtrlVisible("OutPanel", true)
end

function BlogCircleDlg:MSG_BLOG_STATUS_NUM_ABOUT_ME(data)
    if data.count > 0 and BlogMgr:isMySelf(self.name) then
        self:setLabelText("UnReadNoteLabel", string.format(CHS[5420233], data.count))
        self:setCtrlVisible("UnReadNotePanel", true)
        BlogMgr:setHasMailRedDotForCircle(nil)
    else
        self:setCtrlVisible("UnReadNotePanel", false)
    end
end

function BlogCircleDlg:MSG_BLOG_DELETE_ONE_STATUS(data)
    local list = self:getControl("ListView")
    local items = list:getItems()

    for _, panel in pairs(items) do
        if panel.data and data.sid == panel.data.sid then
            list:removeChild(panel)
        end
    end

    list:requestRefreshView()
    items = list:getItems()
    if #items <= 0 and self.curListViewName ~= "UnReadListView" then
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    -- 同时刷新未读的状态
    if self.curListViewName ~= "UnReadListView" then
        -- 未读状态打开界面期间只显示一次，所以只要显示期间刷新就行
        return
    end

    local list = self:getControl("UnReadListView")
    local items = list:getItems()

    for _, panel in pairs(items) do
        if panel.data and data.sid == panel.data.sid then
            list:removeChild(panel)
        end
    end

    list:requestRefreshView()
    items = list:getItems()
    if #items <= 0 and self.curListViewName ~= "ListView" then
        self:setCtrlVisible("NoticePanel", true)
    else
    self:setCtrlVisible("NoticePanel", false)
end
end

-- 通知所有评论数据
function BlogCircleDlg:MSG_BLOG_ALL_COMMENT_LIST(data)
    local list = self:getControl("ListView")
    local items = list:getItems()

    for _, panel in pairs(items) do
        if data.sid == panel.data.sid then
            panel.isExpand = 1
            -- 设置评论
            self:setUnitDynamicsForTalk(data, panel)
            -- 自适应
            self:setAutoSize(panel)
        end
    end

    list:requestRefreshView()
end

-- 查看名片
function BlogCircleDlg:MSG_CHAR_INFO_EX(data)
    if self.selectCharGid ~= data.gid then return end
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    if FriendMgr:isKuafDist(data.dist_name) then
        dlg:setMuneType(CHAR_MUNE_TYPE.KUAFU_BLOG)
    end

    dlg:setting(data.id)
    dlg:setInfo(data)
end

-- 查看离线玩家名片
function BlogCircleDlg:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

function BlogCircleDlg:MSG_CROSS_SERVER_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

-- 分享图片
function BlogCircleDlg:sharePic(data)
    self:onWriteButton()
    DlgMgr:sendMsg("BlogStateDlg", "onDlgOpened", {"shareImage", data.fileName})
end

--
-- 重写的原因是，Dialog中的只返回结束点击事件，这里需要点击
function BlogCircleDlg:bindTouchEndEventListenerBlog(ctrl, func, data)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListenerBlog no control ")
        return
    end

    local ctrlName = ctrl:getName()

    -- 事件监听
    local function listener(sender, eventType)
        -- 添加 log 以方便核查崩溃问题
        local str = self.name .. ':' .. tostring(ctrlName) .. ' receive event:' .. tostring(eventType)
        Log:I(str)

        func(self, sender, eventType, data)
    end

    ctrl:addTouchEventListener(listener)
end
--]]

function BlogCircleDlg:setUnitText(panel, data)
    local text = data.text
    if string.match(text, "{\t.*\t}") then
        local title, articleId, comment = string.match(text, "{\t(.*)\27(.*)\27(.*)\t}")
        text = gf:filtText(comment or "", nil, true)
        local shequPanel = self:getControl("SheQuPanel", nil, panel)
        shequPanel:setVisible(true)
        shequPanel.articleId = articleId

        if gf:getTextLength(title) > 88 then
            title = gf:subString(title, 86) .. "..."
        end

        Dialog.setColorText(self, title, "TitlePanel", shequPanel, nil, nil, nil, 17, nil, nil, data.insider >= 1)
    else
        self:setCtrlVisible("SheQuPanel", false, panel)
    end

    self:setColorText(text, "TextPanel", panel, nil, nil, nil, 19, nil, nil, data.insider >= 1)
end

-- 重写因为，不希望 removeAllChildren
function BlogCircleDlg:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, inCenter, isPunct, isVip)
    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    panel:removeChildByName("CGAColorTextList")

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, isVip)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    if inCenter then
        textCtrl:setPosition((size.width - textW) / 2, textH + marginY)
    else
    textCtrl:setPosition(marginX, textH + marginY)
    end

    local textPanel = tolua.cast(textCtrl, "cc.LayerColor")
    textPanel:setName("CGAColorTextList")
    panel:addChild(textPanel)
    local panelHeight = textH + 2 * marginY
    panel:setContentSize(size.width, panelHeight)
    return panelHeight, size.height
end

return BlogCircleDlg
