-- MarriageSignDlg.lua
-- Created by huangzz Dec/30/2016
-- 姻缘签展示界面

local MarriageSignDlg = Singleton("MarriageSignDlg", Dialog)

local SCROLL_CHANGEPAGE = 50 -- 最大滑动多少换页

function MarriageSignDlg:init()
    self:setFullScreen()
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LikeButton", self.onLikeButton)
    self:bindListener("HateButton", self.onHateButton)

    self:hookMsg("MSG_YYQ_PAGE")
    self:hookMsg("MSG_REFRESH_YYQ_INFO")

    local bKPanel = self:getControl("BKPanel")
    local winSize = self:getWinSize()
    bKPanel:setContentSize(winSize.width / Const.UI_SCALE + winSize.ox * 2, winSize.height / Const.UI_SCALE + winSize.oy * 2)
end

function MarriageSignDlg:requestOnePage(page)
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_YYQ_PAGE", {page = page})
end

function MarriageSignDlg:setData(num, showType)
    self.showType = showType
    self.curNum = num
    if showType == 1 then
        -- 分页显示的姻缘签
        self.marriageSign = MarryMgr.marriageSign["allSign"]
        self.curPage = self.marriageSign.curPage
        if self.marriageSign.curPage == 1 and self.curNum <= 1 then
            self:setCtrlVisible("LeftButton", false)
        end

        if self.marriageSign.curPage == self.marriageSign.allPage and self.curNum == #self.marriageSign then
            self:setCtrlVisible("RightButton", false)
        end
    elseif showType == 2 then
        -- 我的姻缘签
        self.marriageSign = MarryMgr.marriageSign["mySign"]
        if num == 1 then
            self:setCtrlVisible("LeftButton", false)
        end

        if num == #self.marriageSign then
            self:setCtrlVisible("RightButton", false)
        end
    else
        -- 查找的姻缘签
        self.marriageSign = {}
        self.marriageSign = MarryMgr.marriageSign["searchSign"]
        self:setCtrlVisible("LeftButton", false)
        self:setCtrlVisible("RightButton", false)
    end

    self:initScrollViewPanel(self:getControl("ScrollView"), true)

    self:updateShowInfo(num)
end

function MarriageSignDlg:updateShowInfo(num)
    -- if not self.marriageSign[num] then return end

    -- 祈愿对象
    if self.marriageSign[num].to_name and string.len(self.marriageSign[num].to_name) > 0 then
        self:setLabelText("NameLabel", CHS[5420096] .. self.marriageSign[num].to_name, "InfoPanel")
    elseif self.name == "MarriageSignDlg" then
        self:setLabelText("NameLabel", "", "InfoPanel")
    end

    -- 祈愿内容，首行空两格
    self:setLabelText("TextLabel_1", "        " .. self.marriageSign[num].text, "InfoPanel")

    if self.marriageSign[num].is_show_name == 1 then
        self:setLabelText("TextLabel_2", "——  " .. self.marriageSign[num].from_name, "InfoPanel")
    else
        self:setLabelText("TextLabel_2", "", "InfoPanel")
    end

    -- 姻缘签编号
    self:setLabelText("NoLabel", self.marriageSign[num].yyq_no)

    -- 评论
    local praise = self.marriageSign[num].praise
    local tread = self.marriageSign[num].tread
    if praise > 99999 then
        praise = 99999
    end

    if tread > 99999 then
        tread = 99999
    end

    self:setLabelText("NumLabel", praise, "LikeButton")
    self:setLabelText("NumLabel", tread, "HateButton")

    if self.marriageSign[num].yyq_type == 1 then
        -- 纸签
        self:setCtrlVisible("BKPanel_1", true)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", false)
    elseif self.marriageSign[num].yyq_type == 2 then
        -- 竹签
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", true)
        self:setCtrlVisible("BKPanel_3", false)
    else
        -- 玉签
        self:setCtrlVisible("BKPanel_1", false)
        self:setCtrlVisible("BKPanel_2", false)
        self:setCtrlVisible("BKPanel_3", true)
    end
end


function MarriageSignDlg:onLeftButton(sender, eventType)
    if not sender:isVisible() then
        return false
    end

    self.curNum = self.curNum - 1

    if self.showType == 2 then
        if self.curNum == 1 then
            self:setCtrlVisible("LeftButton", false)
        end

        if self.curNum < #self.marriageSign then
            self:setCtrlVisible("RightButton", true)
        end
    end

    if self.showType == 1 then
        if self.marriageSign.curPage == 1 and self.curNum <= 1 then
            self:setCtrlVisible("LeftButton", false)
        end

        if self.marriageSign.curPage ~= self.marriageSign.allPage or self.curNum < #self.marriageSign then
            self:setCtrlVisible("RightButton", true)
        end

        if self.curNum < 1 then
            if self.marriageSign.curPage > 1 then
                self.curNum = 12
                self:requestOnePage(self.marriageSign.curPage - 1)
                self.canScroll = false
            else
                self.curNum = 1
            end

            return true
        end
    end

    self:updateShowInfo(self.curNum)

    return true
end

function MarriageSignDlg:onRightButton(sender, eventType)
    if not sender:isVisible() then
        return false
    end

    self.curNum = self.curNum + 1

    if self.showType == 2 then
        if self.curNum > 1 then
            self:setCtrlVisible("LeftButton", true)
        end

        if self.curNum == #self.marriageSign then
            self:setCtrlVisible("RightButton", false)
        end
    end

    if self.showType == 1 then
        if self.marriageSign.curPage == self.marriageSign.allPage and self.curNum == #self.marriageSign then
            self:setCtrlVisible("RightButton", false)
        end

        if self.marriageSign.curPage ~= 1 or self.curNum > 1 then
            self:setCtrlVisible("LeftButton", true)
        end

        if self.curNum > #self.marriageSign then
            if self.marriageSign.curPage < self.marriageSign.allPage then
                self.curNum = 1
                self:requestOnePage(self.marriageSign.curPage + 1)
                self.canScroll = false
            else
                self.curNum = #self.marriageSign
            end

            return true
        end
    end

    self:updateShowInfo(self.curNum)
    return true
end

function MarriageSignDlg:onLikeButton(sender, eventType)
    gf:CmdToServer("CMD_COMMENT_YYQ", {yyq_no = self.marriageSign[self.curNum].yyq_no, oper = 1})
end

function MarriageSignDlg:onHateButton(sender, eventType)
    gf:CmdToServer("CMD_COMMENT_YYQ", {yyq_no = self.marriageSign[self.curNum].yyq_no, oper = 2})
end

function MarriageSignDlg:MSG_YYQ_PAGE(data)
    if data.curPage < self.curPage then
        self:setData(12, 1)
    else
        self:setData(1, 1)
    end
end

-- 刷新单个姻缘签
function MarriageSignDlg:MSG_REFRESH_YYQ_INFO()
    -- 评论
    local praise = self.marriageSign[self.curNum].praise
    local tread = self.marriageSign[self.curNum].tread
    if praise > 99999 then
        praise = 99999
    end

    if tread > 99999 then
        tread = 99999
    end

    self:setLabelText("NumLabel", praise, "LikeButton")
    self:setLabelText("NumLabel", tread, "HateButton")
end

function MarriageSignDlg:initScrollViewPanel(scrollView, needScrollCallFuc)
    if not scrollView then return end
    scrollView:removeAllChildren()
    local contentLayer = ccui.Layout:create()

    contentLayer:setContentSize(scrollView:getContentSize().width, scrollView:getContentSize().height)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())
    scrollView:setTouchEnabled(true)
    scrollView:setClippingEnabled(true)
    scrollView:setBounceEnabled(true)

    scrollView:getInnerContainer():setPositionX(0)

    local notChangePageLeft = false
    local notChangePageRight = false
    self.canScroll = true
    if needScrollCallFuc then
        local leftButton = self:getControl("LeftButton")
        local rightButton = self:getControl("RightButton")
        local  function scrollListener(sender, eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                -- 向左向右滑动 offset 时，跳到另一页
                local offset = SCROLL_CHANGEPAGE
                local  x = scrollView:getInnerContainer():getPositionX()
                if not notChangePageLeft and x > offset and self.canScroll then
                    notChangePageLeft = self:onLeftButton(leftButton)
                end

                if not notChangePageRight and x < - offset and self.canScroll then
                    notChangePageRight = self:onRightButton(rightButton)
                end

                if math.abs(x) < 10 then
                    notChangePageLeft = false
                    notChangePageRight = false
                end
            end
        end

        scrollView:addEventListener(scrollListener)
    end

    scrollView:addChild(contentLayer)
end

return MarriageSignDlg
