-- BookCommentDlg.lua
-- Created by huangzz Mar/31/2018
-- 图鉴评论界面

local BookCommentDlg = Singleton("BookCommentDlg", Dialog)


local LEVEL_LIMIT = 40 -- 评论限制等级

local WORD_LIMIT = 50

local MIN_LIKE_NUM = 10 -- 热门评论点赞数最小值

local REQUEST_SPACE = 1000 -- 请求数据的间隔

function BookCommentDlg:init()
    self:bindListener("CommentButton", self.onCommentButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("ThumbButton", self.onThumbButton)
    self:bindListener("TouchPanel", self.swichWordInput)
    self:bindListener("PlayerNameLabel", self.onPlayerNameLabel, "OneMessagePanel")
    self:blindLongPress("OneMessagePanel", self.onOneMessagePanel)

    self.oneMessagePanel = self:retainCtrl("OneMessagePanel")
    self.seperatePanel = self:retainCtrl("SeperatePanel")
    self.loadingPanel = self:retainCtrl("LoadingPanel")
    self.listView = self:resetListView("ListView", 1)

    self:initView()

    self.data = nil
    self.selectChar = nil
    self.isLoading = nil   -- 标记正在请求数据
    self.isLoadEnd = nil   -- 标记已加载完最后一页
    self.notCallListView = nil

    if not Me:isBindName() then
        -- 请求实名认证信息
        gf:CmdToServer('CMD_REQUEST_FUZZY_IDENTITY', {force_request = 0})
    end

    self:hookMsg("MSG_HANDBOOK_COMMENT_QUERY_LIST")
    self:hookMsg("MSG_HANDBOOK_COMMENT_PUBLISH")
    self:hookMsg("MSG_HANDBOOK_COMMENT_DELETE")
    self:hookMsg("MSG_HANDBOOK_COMMENT_LIKE")

    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_OFFLINE_CHAR_INFO")
end

function BookCommentDlg:setCommentObj(info, type)
    if type == "boss" then
        self:setCtrlVisible("PetTitlePanel", false)
        self:setCtrlVisible("BossTitlePanel", true)
        self:setCtrlVisible("QishaTitlePanel", false)

        self.petName = CHS[5400589] .. info.name
    elseif type == "jiutian" then
        self:setCtrlVisible("PetTitlePanel", false)
        self:setCtrlVisible("BossTitlePanel", true)
        self:setCtrlVisible("QishaTitlePanel", false)

        self.petName = CHS[5400589] .. info.name

        self:setLabelText("TitleLabel_1", info.name .. CHS[4010188], "BossTitlePanel")
        self:setLabelText("TitleLabel_2", info.name .. CHS[4010188], "BossTitlePanel")
    elseif type == "qisha_shilian" then
        self:setCtrlVisible("PetTitlePanel", false)
        self:setCtrlVisible("BossTitlePanel", false)
        self:setCtrlVisible("QishaTitlePanel", true)

        self.petName = CHS[5400589] .. info.name
    else
        self:setCtrlVisible("PetTitlePanel", true)
        self:setCtrlVisible("BossTitlePanel", false)
        self:setCtrlVisible("QishaTitlePanel", false)

        self.petName = CHS[5400588] .. info.name
    end

    self:setImage("PortraitImage", ResMgr:getSmallPortrait(info.icon), "PetTypePanel")
    self:setLabelText("PetNameLabel", info.name, "PetTypePanel")


    self:requestCommentList(0, "")
end

-- 请求图鉴评论查询列表
function BookCommentDlg:requestCommentList(time, id)
    self.lastRequestId = id
    self.lastRequestTime = gfGetTickCount()
    gf:CmdToServer("CMD_HANDBOOK_COMMENT_QUERY_LIST", {key_name = self.petName, last_time = time, last_id = id})
end

-- 发布评论
function BookCommentDlg:requestComment(comment)
    gf:CmdToServer("CMD_HANDBOOK_COMMENT_PUBLISH", {key_name = self.petName, comment = comment})
end

-- 删除评论
function BookCommentDlg:requestDeleteComment(id)
    gf:CmdToServer("CMD_HANDBOOK_COMMENT_DELETE", {key_name = self.petName, id = id})
end

-- 点赞
function BookCommentDlg:requestLikeComment(id)
    gf:CmdToServer("CMD_HANDBOOK_COMMENT_LIKE", {key_name = self.petName, id = id})
end

-- 初始化列表
function BookCommentDlg:initView()
    self:setCtrlVisible("NoticePanel", false)

    local function onScrollView(sender, eventType)
        if self.notCallListView or self.isLoadEnd or self.isLoading then
            return
        end

        if ccui.ScrollviewEventType.scrolling == eventType
            or ccui.ScrollviewEventType.scrollToTop == eventType
            or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件
            local listInnerContent = sender:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local scrollViewSize = sender:getContentSize()

            local lastData = self:getLoadedLastData()
            if not lastData then
                return
            end

            -- 计算滚动的百分比
            local innerPosY = listInnerContent:getPositionY() + 0.5
            if innerPosY > 10 then
                -- 向下加载
                self:setLoadingVisible(true)

                local curTime = gfGetTickCount()
                local cTime = REQUEST_SPACE - (curTime - self.lastRequestTime)
                cTime = math.max(cTime, 0)
                performWithDelay(sender, function()
                    self:requestCommentList(lastData.time, lastData.id)
                end, cTime / 1000)
            end
        end
    end

    self.listView:addScrollViewEventListener(onScrollView)

    -- 初始化编辑框
    self:setCtrlVisible("DelButton", false, "InputPanel")
    self.editBox = self:createEditBox("TextPanel", "InputPanel", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.editBox then return end
            local content = self.editBox:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT * 2 then
                content = gf:subString(content, WORD_LIMIT * 2)
                self.editBox:setText(content)
                gf:ShowSmallTips(string.format(CHS[5400591], WORD_LIMIT))
            end

            if len == 0 then
                self:setCtrlVisible("DelButton", false, "InputPanel")
            else
                self:setCtrlVisible("DelButton", true,  "InputPanel")
            end
        end
    end)

    self.editBox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editBox:setPlaceholderFont(CHS[3003794], 19)
    self.editBox:setFont(CHS[3003794], 19)
    self.editBox:setFontColor(COLOR3.ORANGE)
    self.editBox:setPlaceHolder(CHS[5400587])
    self.editBox:setPlaceholderFontSize(19)
    self.editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102))

    -- loading界面动起来
    local circleCtrl = self:getControl("LoadingImage", nil, self.loadingPanel)
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    circleCtrl:runAction(action)
end

-- 获取已经显示的最后一条数据
function BookCommentDlg:getLoadedLastData()
    local list = self.listView
    local items = list:getItems()

    local count = #items
    if count ~= 0 then
        return items[count].data
    end
end

-- 点赞
function BookCommentDlg:onThumbButton(sender, eventType)
    local data = sender:getParent().data
    -- 若当前玩家等级＜40级，则予以如下弹出提示
    if Me:queryBasicInt("level") < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[5400581], LEVEL_LIMIT))
        return
    end

    if not data then
        return
    end

    if data.has_like == 1 then
        gf:ShowSmallTips(CHS[5450119])
        return
    end

    -- 否则若当前状态点赞数≥9999（容错），则予以如下弹出提示
    if data.like_num >= 9999 then
        gf:ShowSmallTips(CHS[5400582])
        return
    end

    self:requestLikeComment(data.id)
end

-- 评论
function BookCommentDlg:onCommentButton(sender, eventType)
    self:sendMessage()
end

-- 清空输入框
function BookCommentDlg:onDelButton(sender, eventType)
    self.editBox:setText("")
    sender:setVisible(false)
end

function BookCommentDlg:onPlayerNameLabel(sender, eventType)
    local data = sender:getParent().data

    if not data then return end

    if data and data.gid ~= Me:queryBasic("gid") then
        self.selectChar = {gid = data.gid, sender = sender}
        FriendMgr:requestCharMenuInfo(data["gid"], nil, "BookCommentDlg", 1)
    end
end

-- 查看名片
function BookCommentDlg:MSG_CHAR_INFO_EX(data)
    if data.msg_type ~= "BookCommentDlg" or not self.selectChar or self.selectChar.gid ~= data.gid then
        return
    end

    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    dlg:setInfo(data)

    local rect = self:getBoundingBoxInWorldSpace(self.selectChar.sender)
    dlg:setFloatingFramePos(rect)
end

-- 查看离线玩家名片
function BookCommentDlg:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

function BookCommentDlg:onReportCommentForBlog(sender)
    local para = "@spcial@;" .. self.data.comment .. CHS[4300498] ..  GameMgr:getDistName() .. ":" .. self.data.id
    ChatMgr:questOpenReportDlg(self.data.gid, self.data.name, GameMgr:getDistName(), para)
end


-- 删除评论
function BookCommentDlg:onOneMessagePanel(sender, eventType)
    local data = sender.data
    if not data then return end

    if data.gid ~= Me:queryBasic("gid") then
        self.data = data
        BlogMgr:showButtonList(self, sender, "onReportComment", self.name)
        return
    end

    BlogMgr:showButtonList(self, sender, "petDelCommentOp", self.name)
end

-- 删除评论
function BookCommentDlg:onDelComment(sender, eventType)
    if not sender then return end

    local data = sender.data

    if data then
        self:requestDeleteComment(data.id)
    end
end

function BookCommentDlg:onExpressionButton(sender, eventType)
    if Me:queryBasicInt("level") < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[5400584], LEVEL_LIMIT))
        return
    end

    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "bookComment")

    -- 界面上推
    local height = dlg:getMainBodyHeight()
    DlgMgr:upDlg("BookCommentDlg", height - 50)
end


-- 插入表情
function BookCommentDlg:addExpression(expression)
    if not self.editBox then return end

    local content = self.editBox:getText()
    if gf:getTextLength(content .. expression) > WORD_LIMIT * 2 then
        -- 字符超出上限
        gf:ShowSmallTips(string.format(CHS[5400591], WORD_LIMIT))
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. expression
    self.editBox:setText(content)
    self:setCtrlVisible("DelButton", true, "InputPanel")
end

-- 增加空格
function BookCommentDlg:addSpace()
    if not self.editBox then return end

    local content = self.editBox:getText()
    if gf:getTextLength(content .. " ") > WORD_LIMIT * 2 then
        -- 字符超出上限
        gf:ShowSmallTips(string.format(CHS[5400591], WORD_LIMIT))
        return
    end

    self.editBox:setText(content .. " ")
    self:setCtrlVisible("DelButton", true, "InputPanel")
end

-- 删除字符
function BookCommentDlg:deleteWord()
    if not self.editBox then return end

    local text = self.editBox:getText()
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
        self.editBox:setText(newtext)

        if len - deletNum <= 0 then
            self:setCtrlVisible("DelButton", false, "InputPanel")
        end
    else
        self:setCtrlVisible("DelButton", false, "InputPanel")
    end
end

-- 发送消息
function BookCommentDlg:sendMessage()
    local content = self.editBox:getText()

    -- 若当前玩家等级＜40级，则予以如下弹出提示
    if Me:queryBasicInt("level") < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[5400584], LEVEL_LIMIT))
        return
    end

    -- 若玩家当前是第一次使用评论功能（以是否发布过评论为准），且当前账号尚未完成实名认证，则予以如下弹出提示
    if Me:getAdultStatus() == 2 then
        gf:ShowSmallTips(CHS[5400583])
        return
    end

    -- 若当前玩家并未输入任何内容，则给予如下弹出提示
    if content == "" then
        gf:ShowSmallTips(CHS[5400585])
        return
    end

    --  对当前输入内容进行敏感字检测[敏感词语表详细设计(design)]，若未通过，给予弹出提示：
    local filtTextStr, haveFilt = gf:filtText(content, nil, true)
    if haveFilt then
        gf:ShowSmallTips(CHS[5400586])
        self.editBox:setText(filtTextStr)
        return
    end

    self:requestComment(content)
end

-- 表情界面关闭时
function BookCommentDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("BookCommentDlg")
end

-- 切换输入
function BookCommentDlg:swichWordInput()
    if not self.editBox then return end

    -- 若当前玩家等级＜40级，则予以如下弹出提示
    if Me:queryBasicInt("level") < LEVEL_LIMIT then
        gf:ShowSmallTips(string.format(CHS[5400584], LEVEL_LIMIT))
        return
    end

    self.editBox:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end


-- 初始化一个条目
function BookCommentDlg:setOneMessagePanel(cell, data)
    -- 名字
    self:setLabelText("PlayerNameLabel", "[" .. data.name .. "]", cell)

    if data.isHot == 1 then
        self:setCtrlVisible("HotImage", true, cell)
    else
        self:setCtrlVisible("HotImage", false, cell)
    end

    -- 点赞
    if data.like_num > 9999 then
        self:setLabelText("ThumbNumberLabel", 9999, cell)
    else
        self:setLabelText("ThumbNumberLabel", data.like_num, cell)
    end

    self:setCtrlVisible("HotThumbedImage", false, cell)
    self:setCtrlVisible("OrdinaryThumbedImage", false, cell)
    self:setCtrlVisible("HotThumbImage", false, cell)
    self:setCtrlVisible("OrdinaryThumbImage", false, cell)
    if data.has_like == 1 then
        if data.isHot == 1 then
            self:setCtrlVisible("HotThumbedImage", true, cell)
        else
            self:setCtrlVisible("OrdinaryThumbedImage", true, cell)
        end
    else
        if data.isHot == 1 then
            self:setCtrlVisible("HotThumbImage", true, cell)
        else
            self:setCtrlVisible("OrdinaryThumbImage", true, cell)
        end
    end

    -- 时间
    local str = os.date("%Y-%m-%d", data.time)
    self:setLabelText("TimeLabel", str, cell)


    -- 内容
    local msg = data.comment
    local curHeight, oldHeight = self:setColorText(msg, "TextPanel", cell, nil, nil, nil, 19, nil, nil, data.sender_vip ~= 0)
    if curHeight > oldHeight then
        local size = cell:getContentSize()
        local height = size.height - oldHeight + curHeight
        cell:setContentSize(size.width, height)
        self:setCtrlContentSize("BKImage", size.width, height - 2, cell)
    end

    -- 设置条目的数据
    cell.data = data
end

-- 努力加载中
function BookCommentDlg:setLoadingVisible(visible)
    if self.isLoading == visible then
        return
    end

    local listView = self.listView
    self:setCtrlVisible("LoadingPanel", visible, "LoadPanel")
    self.isLoading = visible

    if visible then
        listView:pushBackCustomItem(self.loadingPanel)
    elseif self.loadingPanel:getParent() then
        listView:removeChild(self.loadingPanel, false)
    end

    self.notCallListView = true
    listView:refreshView()
    self.notCallListView = false
end

function BookCommentDlg:refreshList(data, isReset)
    if isReset then
        self.listView:removeAllItems()

        if #data == 0 then
            self:setCtrlVisible("NoticePanel", true)
            self.listView:setVisible(false)
            return
        else
            self:setCtrlVisible("NoticePanel", false)
            self.listView:setVisible(true)
        end
    end

    local lastHeight = self.listView:getInnerContainer():getContentSize().height
    for i = 1, #data do
        local panel = self.oneMessagePanel:clone()
        self:setOneMessagePanel(panel, data[i])
        panel:setName(data[i].id)
        self.listView:pushBackCustomItem(panel)
    end

    if isReset and self.hotNum > 0 then
        self.seperatePanel:removeFromParent()
        self.listView:insertCustomItem(self.seperatePanel, self.hotNum)
    end

    if not isReset and #data > 0 then
        self.notCallListView = true
        self.listView:requestRefreshView()
        self.listView:doLayout()
        performWithDelay(self.root, function()
            -- 拉得太快会导致直接划到下一页的底部，此处重新拉回原来的位置
            self:jumpToItem(lastHeight)
            self.notCallListView = false
        end, 0)
    end
end

function BookCommentDlg:jumpToItem(offsetY)
    local contentSize = self.listView:getContentSize()
    local innerContainer = self.listView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end

    innerContainer:setPositionY(offsetY)
end

function BookCommentDlg:MSG_HANDBOOK_COMMENT_QUERY_LIST(data)
    if data.key_name ~= self.petName then return end

    if self.lastRequestId ~= data.last_id then return end

    self.lastRequestId = ""

    self:setLoadingVisible(false)

    -- 请求数据失败
    if data.count == -1 then
        return
    end

    -- 已经是最后一页
    if data.count == 0 then
        self.isLoadEnd = true

        if data.last_id ~= "" then
            gf:ShowSmallTips(CHS[5450120])
        end
    end

    if data.last_id == "" then
        -- 前三条且点赞数大于等于 10 的评论一定是热评
        for i = 1, 3 do
            if data[i] and data[i].like_num >= MIN_LIKE_NUM then
                data[i].isHot = 1
                self.hotNum = i
            else
                self.hotNum = i - 1
                break
            end
        end

        self:refreshList(data, true)
    else
        self:refreshList(data)
    end
end

-- 通知发布评论成功
function BookCommentDlg:MSG_HANDBOOK_COMMENT_PUBLISH(data)
    if data.key_name ~= self.petName then return end

    -- 清除输入框内容
    self:onDelButton(self:getControl("DelButton"))

    --[[local items = self.listView:getItems()
    -- 移除旧的评论
    for i = 1, #items do
        local data = items[i].data
        if data and data.gid == Me:queryBasic("gid") then
            self.listView:removeChild(items[i], true)
            self:checkHot(data)
            break
        end
    end


    -- 插入新的评论
    data.gid = Me:queryBasic("gid")
    data.name = Me:getShowName()
    data.like_num = 0
    data.has_like = 0

    local cell = self.oneMessagePanel:clone()
    self:setOneMessagePanel(cell, data)
    cell:setName(data.id)
    if self.hotNum == 0 then
        self.listView:insertCustomItem(cell, self.hotNum)
    else
        self.listView:insertCustomItem(cell, self.hotNum + 1)
    end

    self:setCtrlVisible("NoticePanel", false)
    self.listView:setVisible(true)]]
end

-- 检查是否还有热评，没有时要移除"更多评论"条目
function BookCommentDlg:checkHot(data)
    if data and data.isHot then
        self.hotNum = self.hotNum - 1
    end

    if self.hotNum <= 0 then
        self.listView:removeChild(self.seperatePanel, true)
    end
end

-- 通知删除评论成功
function BookCommentDlg:MSG_HANDBOOK_COMMENT_DELETE(data)
    local cell = self.listView:getChildByName(data.id)
    if cell then
        self:checkHot(cell.data)

        self.listView:removeChild(cell, true)
        self.listView:requestRefreshView()

        local items = self.listView:getItems()
        if #items == 0 then
            self:setCtrlVisible("NoticePanel", true)
            self.listView:setVisible(false)
        end
    end
end

-- 通知点赞成功
function BookCommentDlg:MSG_HANDBOOK_COMMENT_LIKE(data)
    local cell = self.listView:getChildByName(data.id)
    if cell and cell.data then
        cell.data.like_num = cell.data.like_num + 1
        cell.data.has_like = 1
        self:setOneMessagePanel(cell, cell.data)
    end
end

-- 清理数据
function BookCommentDlg:cleanup()
    local circleCtrl = self:getControl("LoadingImage", nil, self.loadingPanel)
    circleCtrl:stopAllActions()
end

return BookCommentDlg
