-- TradingSpotDiscussDlg.lua
-- Created by
--

local TradingSpotDiscussDlg = Singleton("TradingSpotDiscussDlg", Dialog)

-- uid == "npc:钱大富"

local NPC_ICON = {
    [CHS[7190468]] = 6014,
}

-- 输入框字符限制
local WORD_LIMIT = 100

-- 聊天文字高度
local TEXT_LINE_HEIGHT = 25
local TEXT_LINE_MINES_HEIGHT = 1

function TradingSpotDiscussDlg:init(data)
    self:bindListener("TimeSelectButton", self.onTimeSelectButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("RankButton", self.onRankButton)
    self:bindListener("SummitButton", self.onSummitButton)
    self:bindListener("DelButton", self.onDelButton)

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

    self.unitSeasonPanel = self:retainCtrl("UnitPanel", "SelectPanel")
    self:bindTouchEndEventListener(self.unitSeasonPanel, self.onSeasonButton)

    self:bindFloatPanelListener("SelectPanel")

    self:setCtrlVisible("TimeSelectButton", true)
    self:setCtrlVisible("SelectPanel", false)
    self:setCtrlVisible("LoadingPanel", false)


    self:resetListView("DiscussListView")


    self.lastQueryTime = 0
    self.isFirst = true
  --  self:setDiscussListView()

    -- 设置界面数据
    --    self:setData(data)

    -- 请求列表
    self.selectCatalog = nil
    self.isNewquery = false
    --TradingSpotMgr:queryBBSList(self.selectCatalog)
    gf:CmdToServer('CMD_TRADING_SPOT_BBS_CATALOG_LIST')

    self:scrollLoad()

    self:initEditBox()

    self:hookMsg("MSG_BBS_REQUEST_STATUS_LIST")
    self:hookMsg("MSG_BBS_UPDATE_ONE_STATUS")
    self:hookMsg("MSG_BBS_DELETE_ONE_STATUS")
    self:hookMsg("MSG_BBS_ALL_COMMENT_LIST")
    self:hookMsg("MSG_TRADING_SPOT_BBS_CATALOG_LIST")
    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_BBS_LIKE_ONE_STATUS")
end


function TradingSpotDiscussDlg:initEditBox(sender, eventType)
    -- 初始化编辑框
    self.inputPanel = self:getControl("InputPanel")
    self.delButton = self:getControl("DelButton", nil, self.inputPanel)
    self.delButton:setVisible(false)
    self.inputCtrl = self:createEditBox("TextPanel", self.inputPanel, nil, function(sender, type)
        if "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local lenth = gf:getTextLength(content)
            if lenth > WORD_LIMIT then
                content = gf:subString(content, WORD_LIMIT)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400041])
            end

            self.delButton:setVisible(lenth ~= 0)
        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 23)
    self.inputCtrl:setFont(CHS[3003794], 23)
    self.inputCtrl:setPlaceHolder(CHS[4010337])
    self.inputCtrl:setPlaceholderFontSize(23)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
end

-- 获取已经显示的最后一条数据
function TradingSpotDiscussDlg:getLoadedLastData()
    local list = self:getControl("DiscussListView")
    local items = list:getItems()

    local count = #items
    if count ~= 0 then
        return items[count].data
    end
end


function TradingSpotDiscussDlg:scrollLoad()

    local function callback(dlg, percent)
        local list = self:getControl("DiscussListView")

        if percent > 100 then

            -- 该请求数据了
            local lastData = self:getLoadedLastData()
            if lastData and lastData.sid then
                if gfGetTickCount() - self.lastQueryTime > 1000 then
                    self.root:stopAction(self.delayRequest)
                    self.delayRequest = performWithDelay(self.root, function ()
                        -- 延迟请求的原因是：如果在listView回滚时，数据来了，它会回滚至底部！！
                        TradingSpotMgr:queryBBSList(self.selectCatalog, lastData.sid)
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
        elseif percent == 0 then
            if list:getInnerContainerSize().height == list:getContentSize().height then
                if list:getInnerContainer():getPositionY() < -50 then
                    -- 拉动距离大于50
                    -- 判断是否在请求中
                    if not list:getChildByName("LoadingPanel") then
                        if gfGetTickCount() - self.lastQueryTime > 1000 then
                            self.root:stopAction(self.delayRequest)
                            self.delayRequest = performWithDelay(self.root, function ()
                                -- 延迟请求的原因是：好看一些
                                TradingSpotMgr:queryBBSList(self.selectCatalog)
                                self.isNewquery = true
                            end, 0.5)

                            self.lastQueryTime = gfGetTickCount()

                            local lodingPanel = self:getControl("LoadingPanel"):clone()
                            lodingPanel:setVisible(true)
                            lodingPanel:setName("LoadingPanel")
                            lodingPanel.data = {}
                            list:insertCustomItem(lodingPanel, 0)
                        else
                            gf:ShowSmallTips(CHS[4200455])
                        end
                    end
                end
            end
        elseif percent < 0 then
            if math.abs(list:getInnerContainerSize().height * percent * 0.01) > 50 then
                -- 拉动距离大于50

                -- 判断是否在请求中
                if not list:getChildByName("LoadingPanel") then
                    if gfGetTickCount() - self.lastQueryTime > 1000 then
                        self.root:stopAction(self.delayRequest)
                        self.delayRequest = performWithDelay(self.root, function ()
                            -- 延迟请求的原因是：好看一些
                            TradingSpotMgr:queryBBSList(self.selectCatalog)
                            self.isNewquery = true
                        end, 0.5)

                        self.lastQueryTime = gfGetTickCount()

                        local lodingPanel = self:getControl("LoadingPanel"):clone()
                        lodingPanel:setVisible(true)
                        lodingPanel:setName("LoadingPanel")
                        lodingPanel.data = {}
                        list:insertCustomItem(lodingPanel, 0)
                    else
                        gf:ShowSmallTips(CHS[4200455])
                    end
                end
            end
        end
    end



    -- 下拉请求数据
    self:bindListViewByPageLoad("DiscussListView", "TouchPanel", callback)
end


function TradingSpotDiscussDlg:bindTouchEndEventListenerBlog(ctrl, func, data)
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

-- 删除评论
function TradingSpotDiscussDlg:onDelComment(sender, eventType)
    if not self.opComment then return end
    gf:confirm(CHS[4200464], function ()
        TradingSpotMgr:deleteBBSComment(self.opComment.sid, self.opComment.cid, self.opComment.isExpand, self.opComment.status_dist)
    end)
end

function TradingSpotDiscussDlg:onReComment(sender, eventType)
    if not self.opComment then return end
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    local ret = {name = self.opComment.name, uid = self.opComment.uid, sid = self.opComment.sid, reply_cid = self.opComment.cid, reply_dist = self.opComment.reply_dist, isExpand = self.opComment.isExpand, charGid = self.opComment.charGid, status_dist = self.opComment.status_dist}
    dlg:setData(ret)
end

-- 举报评论
function TradingSpotDiscussDlg:onReportCommentForBlog(sender, eventType)
    if not self.opComment then return end
    local para = "@spcial@;" .. self.opComment.message .. CHS[4300497] ..  GameMgr:getDistName() .. ":" .. self.opComment.sid .. "-" .. self.opComment.reply_cid
    ChatMgr:questOpenReportDlg(self.opComment.charGid, self.opComment.name, self.opComment.status_dist, para)
end

-- 回复评论
function TradingSpotDiscussDlg:onReplyCommentForBlog(sender, eventType)
    if not self.opComment then return end
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    dlg:setData(self.opComment)
end
function TradingSpotDiscussDlg:opTalkButton(sender)
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
            self.opComment = {message = data.text ,name = data.name, uid = mainData.uid, sid = mainData.sid, reply_cid = data.cid, reply_dist = data.dist, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
        else
            -- 我是评论者，删除
            BlogMgr:showButtonList(self, sender, "blogDelCommentOp", self.name)
            self.opComment = {name = data.name, uid = mainData.uid, reply_dist = data.dist, sid = mainData.sid, cid = data.cid, isExpand = mainPanel.isExpand, charGid = data.uid, status_dist = mainData.dist}
        end
        return
    end
end

-- 点击具体某个评论
function TradingSpotDiscussDlg:onReTalkButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:opTalkButton(sender)
        self:setCtrlVisible("TouchImage", false, sender.talkPanel)
    elseif eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("TouchImage", true, sender.talkPanel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("TouchImage", false, sender.talkPanel)
    end
end

function TradingSpotDiscussDlg:setData(data)


    -- 设置动态
    self:setFriendsDynamics(data)
end

-- 设置好友动态列表
function TradingSpotDiscussDlg:setFriendsDynamics(data)
    local list = self:resetListView("DiscussListView")

    if data.count <= 0 then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    self:setCtrlVisible("NoticePanel", false)

    -- 加载进listView
    self:loadFriendsDynamics(data)
end

function TradingSpotDiscussDlg:loadFriendsDynamics(data)
    local list = self:getControl("DiscussListView")

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

function TradingSpotDiscussDlg:setUnitDynamics(data, panel)
    -- 时间
    self:setLabelText("TimeLabel", os.date(CHS[5410193], data.time), panel)

        -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)


    -- 跨服
    if data.dist ~= GameMgr:getDistName() then
        gf:addKuafLogo(self:getControl("PortraitPanel", nil, panel))
    end

    -- 举报按钮是否显示
    self:setCtrlVisible("ReportButton", data.uid ~= Me:queryBasic("gid"), panel)
    self:setCtrlVisible("ReportTextLabel", data.uid ~= Me:queryBasic("gid"), panel)

    -- 名字
    local npcName = string.match(data.uid, "npc:(.+)")
    self:setCtrlVisible("NPCImage", false, panel)
    if npcName then
        self:setCtrlVisible("NPCImage", true, panel)
        self:setLabelText("NPCNameLabel", npcName, panel)
        self:setLabelText("NameLabel", "", panel)
        self:setImage("PortraitImage", ResMgr:getSmallPortrait(NPC_ICON[npcName]), panel)

        -- 举报按钮是否显示
        self:setCtrlVisible("ReportButton", false, panel)
        self:setCtrlVisible("ReportTextLabel", false, panel)

        -- NPC时间栏显示  置顶
        self:setLabelText("TimeLabel", CHS[4010367], panel)
    else
        self:setLabelText("NameLabel", data.name, panel)
        self:setLabelText("NPCNameLabel", "", panel)

            -- 等级
        self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
        self:getControl("PortraitPanel", nil, panel).data = {uid = data.uid, dist = data.dist}
    end


    panel.isExpand =  0

    -- 删除按钮是否显示
    self:setCtrlVisible("DeleteButton", data.uid == Me:queryBasic("gid"), panel)


    -- 设置动态文字信息
    if data.text == "" then
        self:setCtrlContentSize("TextPanel", nil, 0, panel)
        self:updateBKPanelSize(panel)
    else
        -- self:setColorText(data.text, "TextPanel", panel, nil, nil, nil, 19, nil, nil, data.insider >= 1)
        self:setUnitText(panel, data)
    end

    -- 设置点赞者
    self:setUnitDynamicsForZanData(data, panel)

    -- 设置聊天互动
    self:setUnitDynamicsForTalk(data, panel)

    self:setAutoSize(panel)

    panel.data = data
end

-- 更新文字背景的高度
function TradingSpotDiscussDlg:updateBKPanelSize(panel)
    local textPanel = self:getControl("TextPanel", nil, panel)
    if not textPanel then return end

    local bkPanel = self:getControl("StateTextPanel", nil, panel)
    if not bkPanel then return end
    local bkImage = self:getControl("BackImage", nil, bkPanel)
    if not bkImage then return end

    local textPanel = self:getControl("TextPanel", nil, panel)
    local sz = textPanel:getContentSize()
    local minusHeight = math.floor(sz.height / TEXT_LINE_HEIGHT * TEXT_LINE_MINES_HEIGHT)
    textPanel:setVisible(false)
    performWithDelay(self.root, function()
        textPanel:setPositionY(textPanel:getPositionY() - minusHeight)
        textPanel:setVisible(true)
    end, 0)

    local textHeight = textPanel:getContentSize().height
    if textHeight > 0 then
        self:setCtrlContentSize("StateTextPanel", nil, textHeight + 20, panel)
        self:setCtrlContentSize("BackImage", nil, textHeight + 50, bkPanel)
    else
        self:setCtrlContentSize("StateTextPanel", nil, 0, panel)
        self:setCtrlContentSize("BackImage", nil, 0, bkPanel)
    end
end

function TradingSpotDiscussDlg:setAutoSize(panel)
    -- 动态文字内容panel
    local height1 = self:getCtrlContentSize("TextPanel", self.unitStatePanel).height - self:getCtrlContentSize("TextPanel", panel).height


    -- 照片
    local height2 = 0

    -- 回复
    local height3 = self:getCtrlContentSize("TalkPanel", panel).height
    -- 点赞者
    local height4 = self:getCtrlContentSize("ZanListPanel", panel).height
    local height5 = 8
    if height5 ~= 0 then height5 = height5 + 10 end

    panel:setContentSize(self.unitStatePanel:getContentSize().width, self.unitStatePanel:getContentSize().height - height1 - height2 + height3 + height5)
    panel:requestDoLayout()
end

-- 设置单个聊天
function TradingSpotDiscussDlg:setUnitDynamicsForUnitTalk(data, panel)
    local height = 0
    local nameStr = ""
    local talkPanel
    panel.data = data
    if data.reply_name ~= "" then
        self:setCtrlVisible("OneUserPanel", false, panel)
        talkPanel = self:getControl("TwoUserPanel", nil, panel)
        talkPanel:setVisible(true)
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

-- 设置单个动态，朋友圈的互动
function TradingSpotDiscussDlg:setUnitDynamicsForTalk(data, panel)
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

function TradingSpotDiscussDlg:setUnitText(panel, data)
    local textPanel = self:getControl("TextPanel", nil, panel)
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
        local tradingSpotItem, tradingSpotType, iid = string.match(text, "{\t(.+)=(.+)=.+;.+=(.+)}")
        if tradingSpotItem and tradingSpotType and iid then
            -- 货站货品/买入方案名片
            local showText = string.format("{\t%s：%s=%s}", CHS[7190483], tradingSpotItem, iid)
            text = string.gsub(text, "{\t.+=.+=.+;.+=.+}", showText)
            textPanel.cardIId = iid
        else
            self:setCtrlVisible("SheQuPanel", false, panel)
        end
    end

    self:setColorText(text, "TextPanel", panel, nil, nil, nil, 19, nil, nil, data.insider >= 1)
    self:updateBKPanelSize(panel)

    local function touchText(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            if sender.cardIId then
                gf:sendGeneralNotifyCmd(NOTIFY.NOTICE_QUERY_CARD_INFO, sender.cardIId)
            end
        end
    end

    textPanel:addTouchEventListener(touchText)
end

-- 设置单个朋友圈动态           点赞数据设置
function TradingSpotDiscussDlg:setUnitDynamicsForZanData(data, panel)
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

-- 获取时间显示
function TradingSpotDiscussDlg:getDisplayTime(time)
    local passTime = gf:getServerTime() - time
    if passTime < 60 * 60 then
        return string.format(CHS[4100700], math.max(math.ceil(passTime / 60), 1))
    elseif passTime < 60 * 60 * 24 then
        return string.format(CHS[4100775], math.floor(passTime / (60 * 60)))
    end

    return os.date("%Y-%m-%d", time)
end


function TradingSpotDiscussDlg:setSeasonListView(data)
    local list = self:resetListView("SelectListView")
    for i = 1, data.count do
        local panel = self.unitSeasonPanel:clone()
        panel.catalog = data.orgKey[i]
        self:setLabelText("Label", data[i], panel)
        list:pushBackCustomItem(panel)
    end
end
--[[
function TradingSpotDiscussDlg:setDiscussListView()
    local list = self:resetListView("DiscussListView")
    for i = 1, 5 do
        local panel = self.unitStatePanel:clone()
        self:setUnitDynamics(data[i], panel)
        list:pushBackCustomItem(panel)
    end
end
--]]

-- 显示字符串
function TradingSpotDiscussDlg:setColorTextAutoSetSize(str, panelName, root, marginX, marginY, defColor, fontSize, isPunct, insider)
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

-- 重写因为，不希望 removeAllChildren
function TradingSpotDiscussDlg:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, inCenter, isPunct, isVip)
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

function TradingSpotDiscussDlg:onTimeSelectButton(sender, eventType)
end

function TradingSpotDiscussDlg:onTimeSelectButton(sender, eventType)
end

function TradingSpotDiscussDlg:onTimeSelectButton(sender, eventType)
    self:setCtrlVisible("SelectPanel", true)
end

function TradingSpotDiscussDlg:onLikeButton(sender, eventType)


    -- 单条朋友圈的总panel
    local onePanel = sender:getParent():getParent()
    TradingSpotMgr:likeBBSStatusById(onePanel.data.sid, onePanel.data.dist, onePanel.data.uid)
end

function TradingSpotDiscussDlg:onTalkButton(sender, eventType)
    local onePanel = sender:getParent():getParent()
    local data = onePanel.data

    -- 打开评论界面
    local dlg = DlgMgr:openDlg("BlogCommentDlg")
    local ret = {uid = data.uid, sid = data.sid, reply_dist = data.dist, reply_cid = 0, isExpand = onePanel.isExpand, name = data.name, charGid = data.uid, status_dist = data.dist}
    dlg:setData(ret)
end

function TradingSpotDiscussDlg:onReportButton(sender, eventType)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[4100862])
        return
    end

    local data = sender:getParent():getParent().data
    TradingSpotMgr:reportBBSStatus(data.uid, data.sid, data.dist)
end

function TradingSpotDiscussDlg:onDeleteButton(sender, eventType)
    gf:confirm(CHS[4010366], function ()
        local onePanel = sender:getParent():getParent()
        local data = onePanel.data
        TradingSpotMgr:deleteBBSStatus(data.sid)
    end)
end

function TradingSpotDiscussDlg:onMoreButton(sender, eventType)
    local data = sender:getParent():getParent().data
    TradingSpotMgr:queryBBSAllComment(data.sid, data.dist)
    sender:setVisible(false)
end


-- 点击点赞人区域
function TradingSpotDiscussDlg:onLikeNamePanel(sender, eventType)
    local onePanel = sender:getParent():getParent():getParent()
    if sender:getName() == "ZanPanel4" then
        onePanel = sender:getParent():getParent():getParent():getParent()
    end

    local data = onePanel.data

    DlgMgr:openDlgEx("BlogRecordDlg", {type = "bbs_like", para = data.sid, gid = self.gid, dist = data.dist})
end


function TradingSpotDiscussDlg:onRankButton(sender, eventType)
    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:showTipAndMisMsg(CHS[7190461])
        self:onCloseButton()
        return
    end

    TradingSpotMgr:requestRankingData()
end

function TradingSpotDiscussDlg:onSeasonButton(sender, eventType)
    self.selectCatalog = sender.catalog
    TradingSpotMgr:queryBBSList(self.selectCatalog)
    self:setCtrlVisible("SelectPanel", false)
    self:resetListView("DiscussListView")
end




function TradingSpotDiscussDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "TradingSpotDiscuss")

    -- 界面上推
    local height = dlg:getMainBodyHeight()
    DlgMgr:upDlg(self.name, height)
end

-- 表情界面关闭时，恢复上推
function TradingSpotDiscussDlg:LinkAndExpressionDlgcleanup()
    DlgMgr:resetUpDlg(self.name)
end

-- 删除编辑内容
function TradingSpotDiscussDlg:onDelButton(sender, eventType)
    self.inputCtrl:setText("")
    self.delButton:setVisible(false)
end

-- 插入表情
function TradingSpotDiscussDlg:addExpression(expression)
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
    self.delButton:setVisible(true)
end

-- 插入名片
function TradingSpotDiscussDlg:addCardInfo(sendInfo, showInfo)
    local text = self.inputCtrl:getText()
    if string.match(text, ".*{\29(..-)\29}.*") and string.match(showInfo, ".*{\29(..-)\29}.*") then
        -- 输入框中有链接，要键入一个链接，替换已有链接
        text = string.gsub(text, "{\29(..-)\29}", showInfo)
        self.sendInfo = sendInfo
        self.inputCtrl:setText(text)
    else
        -- 如果当前的sendInfo是名片，覆盖之前的sendInfo
        if sendInfo and string.match(sendInfo, "{\t(..-)}") then
            self.sendInfo = sendInfo
        end

        self.inputCtrl:setText(text..showInfo)
    end

    self.delButton:setVisible(true)
end

-- 发送信息
function TradingSpotDiscussDlg:sendMessage()
    local text = self.inputCtrl:getText()

    if text == "" then
        gf:ShowSmallTips(CHS[4010368])
        return
    end

    if not self.selectCatalog then
        return
    end

    text = self:dealWithCardInfo(text)

    local nameText, haveBadName = gf:filtText(text, nil, true)
    if haveBadName then
        gf:confirm(CHS[4100770], function ()
            --self:setLabelText("ContentLabel", nameText)
            self.inputCtrl:setText(nameText)
            gf:ShowSmallTips(CHS[4200454])
            ChatMgr:sendMiscMsg(CHS[4200454])
        end, nil, nil, nil, nil, nil, true)
        return
    end

    TradingSpotMgr:publishStatus(self.selectCatalog, text)

    DlgMgr:closeDlg("LinkAndExpressionDlg")
    self:onDelButton()
end

function TradingSpotDiscussDlg:dealWithCardInfo(text)
    if not string.match(text, "{\29(..-)\29}") or not self.sendInfo then
        return text
    end

    if string.match(self.sendInfo, "{\t..-=(..-=..-)}") and string.match(text, ".*{\29(..-)\29}.*") then
        local sendInfoFlag = string.match(self.sendInfo, "{\t(..-)=..-=..-}")
        local sendInfoFlag2 = string.match(self.sendInfo, "{\t..-=(..-)=..-}")
        local txtFlag = string.match(text, ".*{\29(..-)\29}.*")

        -- 货站货品/买入方案
        if (sendInfoFlag2 == CHS[7190483] and string.match(txtFlag, CHS[7190483]))
            or (sendInfoFlag2 == CHS[7190487] and string.match(txtFlag, CHS[7190487])) then
            local cardtext = string.match(self.sendInfo, ".*({\t..-=(..-=..-)}).*")
            text = string.gsub(text,"{\29(..-)\29}", cardtext)
        end
    end

    return text
end

function TradingSpotDiscussDlg:onSummitButton(sender, eventType)
    self:sendMessage()
end


function TradingSpotDiscussDlg:MSG_BBS_REQUEST_STATUS_LIST(data)
    --self:setData(data)
    self:setLabelText("TimeLabel", self:changeTime(data.catalog))

    if self.selectCatalog ~= data.catalog then
        self:resetListView("DiscussListView")
    end

    local retStr = self:changeTime(data.catalog)

    local listName = "DiscussListView"

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
            gf:ShowSmallTips(CHS[4010365])--当前已显示所有信息了，没有更多内容了。
        else
            local lastData = items[#items].data
            if lastData.time and lastData.time > data[1].time then
                -- 下拉加载数据，直接push进去就好了
                self:loadFriendsDynamics(data)

            else

                local firstTime1
                local firstTime2

                if items then
                    if items[1] and items[1].data and items[1].data.uid and string.match(items[1].data.uid, "npc:(.+)") and items[2] and items[2].data then
                        firstTime1 = items[2].data.time
                    else
                        firstTime1 = items[1].data.time
                    end
                end

                if data[1] and data[1].uid and string.match(data[1].uid, "npc:(.+)") and data[2] then
                    firstTime2 = data[2].time
                else
                    firstTime2 = data[1].time
                end

                if firstTime1 ~= firstTime2 and self.isNewquery then
                    gf:ShowSmallTips(CHS[4010372])
                    ChatMgr:sendMiscMsg(CHS[4010372])
                end

                -- 这种情况正常为，重新刷新界面了
                self:setFriendsDynamics(data)
            end
        end
    end
    list:refreshView()
    self.isNewquery = false
end

function TradingSpotDiscussDlg:MSG_BBS_UPDATE_ONE_STATUS(data)
        -- 正常显示的状态
    local list = self:getControl("DiscussListView")
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

function TradingSpotDiscussDlg:MSG_BBS_DELETE_ONE_STATUS(data)
    local list = self:getControl("DiscussListView")
    local items = list:getItems()

    for _, panel in pairs(items) do
        if panel.data and data.sid == panel.data.sid then
            list:removeChild(panel)
        end
    end

    list:requestRefreshView()
    items = list:getItems()
    if #items <= 0 then
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("NoticePanel", false)
    end
end

function TradingSpotDiscussDlg:MSG_BBS_ALL_COMMENT_LIST(data)
    local list = self:getControl("DiscussListView")
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

function TradingSpotDiscussDlg:cleanup()
    self.inputCtrl = nil
    self.inputPanel = nil
    self.delButton = nil
end

function TradingSpotDiscussDlg:changeTime(orgStr)
    local key = string.match(orgStr, "spot/(.+)")
    local year = string.sub(key, 1, 4)
    local m = string.sub(key, 5, 6)
    local d = string.sub(key, 7, 8)
    local season = string.sub(key, 10, -1)
    local retStr = string.format( "%s-%s-%s 第%s期", year, m, d, season)
    return retStr
end

function TradingSpotDiscussDlg:MSG_TRADING_SPOT_BBS_CATALOG_LIST(data)
    local count = math.min(10, data.count)
    local ret = {count = count}
    ret.orgKey = {}
    for i = 1, ret.count do
        local orgStr = data.catalogs[i]
        ret.orgKey[i] = orgStr
        local retStr = self:changeTime(orgStr)
        table.insert( ret, retStr)
    end

    self.selectCatalog = ret.orgKey[1]
    self:setLabelText("TimeLabel", ret[1])
    self:setSeasonListView(ret)
end

-- 点击玩家名字
function TradingSpotDiscussDlg:onCharInfoButton(sender, eventType)

    if not sender.data then return end

    if sender.data.uid == Me:queryBasic("gid") then return end
    if string.match( sender.data.uid, "npc:(.+)" ) then return end
    self.selectCharGid = sender.data.uid

    FriendMgr:requestCharMenuInfo(sender.data.uid, nil, nil, 1, nil, sender.data.dist)
end

-- 查看名片
function TradingSpotDiscussDlg:MSG_CHAR_INFO_EX(data)
    if self.selectCharGid ~= data.gid then return end
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    if FriendMgr:isKuafDist(data.dist_name) then
        dlg:setMuneType(CHAR_MUNE_TYPE.KUAFU_BLOG)
    end

    dlg:setting(data.id)
    dlg:setInfo(data)
end

-- 点赞成功
function TradingSpotDiscussDlg:MSG_BBS_LIKE_ONE_STATUS(data)
    local list = self:getControl("DiscussListView")
    local items = list:getItems()
    for _, item in pairs(items) do
        if item.data and item.data.sid == data.sid then
            self:setImage("LikeIconImage", ResMgr.ui.likeImage, item)
            break
        end
    end

    gf:showTipAndMisMsg(CHS[5420322])
end


return TradingSpotDiscussDlg
