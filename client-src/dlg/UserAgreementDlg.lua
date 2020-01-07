-- UserAgreementDlg.lua
-- Created by zhengjh Sep/2015/18
-- 用户协议

local UserAgreementDlg = Singleton("UserAgreementDlg", Dialog)

function UserAgreementDlg:init()
    self:bindListener("LastButton", self.onLastButton)
    self:bindListener("NextButton", self.onNextButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("CloseButton", self.onColseButton)

    self.agreementList = NoticeMgr:getAgreement()
    self.scrollView = self:getControl("ScrollView")
    self:showAndHideButton()
    self:initContent()

    DlgMgr:setVisible("UserLoginDlg", false)
end

function UserAgreementDlg:initContent()
    self.loadIndex = 1
    self.curPage = 1
    self.loadPages = 0
    self:refreshPageNumber()
    self:addOnePage()

    -- 总的页数
    self:setLabelText("TotalPageLabel", #self.agreementList)
end

function UserAgreementDlg:addOnePage()
    if self.loadPages >= #self.agreementList then return end
    self.loadPages = self.loadPages  + 1
    local page = ccui.Layout:create()
    local height = 0

    for i = #self.agreementList[self.loadPages], 1, -1  do
        local layout = self:createLabelLayout(self.agreementList[self.loadPages][i], height)
        height = height + layout:getContentSize().height
        page:addChild(layout)
    end

    page:setContentSize(self.scrollView:getContentSize().width, height)
    self:setContainerSize(page)
    self.scrollView:addChild(page, 0, self.loadPages)
end


function UserAgreementDlg:setContainerSize(page)

    self.scrollView:setInnerContainerSize(page:getContentSize())

    -- 内容小于显示区域往上移
    if page:getContentSize().height < self.scrollView:getContentSize().height then
        page:setPositionY(self.scrollView:getContentSize().height - page:getContentSize().height)
        --self.scrollView:getInnerContainer():setPositionY(self.scrollView:getContentSize().height - page:getContentSize().height)
    else
        self.scrollView:getInnerContainer():setPositionY(self.scrollView:getContentSize().height - page:getContentSize().height)
    end

end

function UserAgreementDlg:createLabelLayout(content, posy)
    local labelLayout = ccui.Layout:create()
    local lableText = CGAColorTextList:create()
    if lableText.setPunctTypesetting then
        lableText:setPunctTypesetting(true)
    end
    lableText:setFontSize(23)
    lableText:setString(content["C"])
    lableText:setContentSize(self.scrollView:getContentSize().width - 10, 0)
    lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    lableText:setPosition(0, labelH)
    labelLayout:addChild(tolua.cast(lableText, "cc.LayerColor"))
    labelLayout:setContentSize(labelW,labelH)

    local posInfo = NoticeMgr:getContentPosAndAnchor(posy, self.scrollView:getContentSize().width, content)
    labelLayout:setPosition(posInfo.position.x, posy)
    labelLayout:setAnchorPoint(posInfo.anchorPoint)

    return labelLayout
end


function UserAgreementDlg:showAndHideButton()
    local userDefault =  cc.UserDefault:getInstance()
    local clostBtn = self:getControl("CloseButton")
    local agreeBtn = self:getControl("AgreeButton")
    local refuseBtn = self:getControl("RefuseButton")
    if NoticeMgr:isNeedShowAgreement() then
        clostBtn:setVisible(false)
    else
        agreeBtn:setVisible(false)
        refuseBtn:setVisible(false)
    end
end

function UserAgreementDlg:onLastButton(sender, eventType)
    if self.curPage > 1 then
        self.curPage = self.curPage - 1
        local curPage = self.scrollView:getChildByTag(self.curPage)
        self:setContainerSize(curPage)
        curPage:setVisible(true)
        self.scrollView:getChildByTag(self.curPage + 1):setVisible(false)
        self:refreshPageNumber()
    end
end

function UserAgreementDlg:onNextButton(sender, eventType)
    if self.loadPages >= #self.agreementList  and  self.curPage == self.loadPages then return end
    if self.curPage == self.loadPages and self.loadPages < #self.agreementList then
        self:addOnePage()
        self.curPage = self.curPage + 1
        self.scrollView:getChildByTag(self.curPage):setVisible(true)
        self.scrollView:getChildByTag(self.curPage - 1):setVisible(false)
        self:refreshPageNumber()
    else
        self.curPage = self.curPage + 1
        local curPage = self.scrollView:getChildByTag(self.curPage)
        self:setContainerSize(curPage)
        curPage:setVisible(true)
        self.scrollView:getChildByTag(self.curPage - 1):setVisible(false)
        self:refreshPageNumber()
    end
end

function UserAgreementDlg:refreshPageNumber()
	local currentPageLabel = self:getControl("CurrentPageLabel")
    currentPageLabel:setString(self.curPage)
end

function UserAgreementDlg:onColseButton()
    DlgMgr:closeDlg(self.name)
    DlgMgr:setVisible("UserLoginDlg", true)
end

function UserAgreementDlg:onRefuseButton(sender, eventType)
    gf:confirm(CHS[7000040],function()
        performWithDelay(cc.Director:getInstance():getRunningScene(), function()
            cc.Director:getInstance():endToLua()
            if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                cc.Director:getInstance():mainLoop()
            end
        end, 0.1)
    end)
end

function UserAgreementDlg:onAgreeButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:setVisible("UserLoginDlg", true)
    cc.UserDefault:getInstance():setStringForKey("agreementVersion", NoticeMgr:getAgreementVersion() or "")
    cc.UserDefault:getInstance():setStringForKey("agreementTime", tostring(os.time()))

    local userDefault =  cc.UserDefault:getInstance()
    local isshowUpdateDesc = userDefault:getStringForKey("showUpdateDesc", "")

    if NoticeMgr:isShowUpdate() then
    elseif NoticeMgr:showLoginAnnouncement() then
    else
        LeitingSdkMgr:login()
    end
end


return UserAgreementDlg
