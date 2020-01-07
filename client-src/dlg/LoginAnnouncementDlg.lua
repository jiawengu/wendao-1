-- LoginAnnouncementDlg.lua
-- Created by lixh2 Jan/12/2018
-- 登录公告界面

local LoginAnnouncementDlg = Singleton("LoginAnnouncementDlg", Dialog)

local noLogin = false

function LoginAnnouncementDlg:init()
    self:bindListener("AgreeButton", self.onAgreeButton)

    self.scrollView = self:getControl("ScrollView")
    self.scrollView:removeAllChildren()

    self.showCoverImage = false

    DlgMgr:setVisible("UserLoginDlg", false)
end

-- 设置公告内容
function LoginAnnouncementDlg:setDescInfo(content)
    local content = NoticeMgr:getcontentList(content)
    local contentLayer = ccui.Layout:create()
    local contentHeight = 0

    for i = #content, 1, -1 do
        local layout = self:createLabelLayout(content[i], contentHeight)
        contentHeight = contentHeight + layout:getContentSize().height
        contentLayer:addChild(layout)
    end

    local scrollViewSz = self.scrollView:getContentSize()
    contentLayer:setContentSize(scrollViewSz.width, contentHeight)
    self.scrollView:setInnerContainerSize({width = scrollViewSz.width, height = contentHeight})
    self.scrollView:addChild(contentLayer)

    self.innerContainer = self.scrollView:getInnerContainer()
    _, self.innercontainerOriginPosY = self.innerContainer:getPosition()
end

-- 策划要求scrollView位置变化时，判断是否需要显示上面遮挡
function LoginAnnouncementDlg:onUpdate()
    if self.innercontainerOriginPosY then
        local _, posY = self.innerContainer:getPosition()
        if not self.showCoverImage and posY > self.innercontainerOriginPosY then
            self:setCtrlVisible("CoverImage_1", true, "MainPanel")
            self.showCoverImage = true
        elseif self.showCoverImage and posY <= self.innercontainerOriginPosY then
            self:setCtrlVisible("CoverImage_1", false, "MainPanel")
            self.showCoverImage = false
        end
    end
end

-- 创建单条内容
function LoginAnnouncementDlg:createLabelLayout(content, posy)
    local labelLayout = ccui.Layout:create()
    local lableText = CGAColorTextList:create()
    if lableText.setPunctTypesetting then
        lableText:setPunctTypesetting(true)
    end
    lableText:setFontSize(21)
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

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            if lableText:getCsType() == CONST_DATA.CS_TYPE_URL then
                gf:onCGAColorText(lableText, sender, nil, self.name)
            end
        end
    end

    labelLayout:setTouchEnabled(true)
    labelLayout:addTouchEventListener(ctrlTouch)

    return labelLayout
end

function LoginAnnouncementDlg:cleanup()
    noLogin = false
end

-- 设置是否需要打开登录过程
function LoginAnnouncementDlg:setNoLogin(flag)
    noLogin = flag
end

-- 关闭界面
function LoginAnnouncementDlg:onCloseButton(sender, eventType)
    if not noLogin then
        LeitingSdkMgr:login()
    end

    DlgMgr:setVisible("UserLoginDlg", true)
    DlgMgr:closeDlg(self.name)
end

-- 确认
function LoginAnnouncementDlg:onAgreeButton(sender, eventType)
    self:onCloseButton()
end

return LoginAnnouncementDlg
