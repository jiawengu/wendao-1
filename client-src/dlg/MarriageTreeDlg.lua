-- MarriageTreeDlg.lua
-- Created by huangzz Dec/30/20116
-- 姻缘树界面

local MarriageTreeDlg = Singleton("MarriageTreeDlg", Dialog)

local SIGN_TAG = 10 -- 姻缘签tag
local WORD_LIMIT = 20 -- 20个汉字
local SCROLL_CHANGEPAGE = 200 -- 最大滑动多少换页
local TOTALPAGE_MAX = 9999  -- 最大的页数

function MarriageTreeDlg:init()
    self:bindListener("MySignButton", self.onMySignButton)
    self:bindListener("BackToTreeButton", self.onBackToTreeButton)
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    
    self:setCtrlVisible("DelAllButton", false)
    
    self.paperSignPanel = self:getControl("PaperSignPanel", nil, "TreePanel")
    self.paperSignPanel:retain()
    self.paperSignPanel:removeFromParent()
    
    self.bamboosSignPanel = self:getControl("BamboosSignPanel", nil, "TreePanel")
    self.bamboosSignPanel:retain()
    self.bamboosSignPanel:removeFromParent()
    
    self.jadeSignPanel = self:getControl("JadeSignPanel", nil, "TreePanel")
    self.jadeSignPanel:retain()
    self.jadeSignPanel:removeFromParent()
    
    self.treePanel = self:getControl("TreePanel")
    self.treePanel:retain()
    self.treePanel:removeFromParent()
    
    -- 绑定数字键盘
    self:bindNumInput("PageInfoPanel", "PagePanel", self.limitCallBack, 1)
    
    self:bindNumInput("TextPanel", "InputPanel", nil, nil, 2)
    
    -- 界面上显示的页数
    self.showPage = 0
    -- 总页数
    self.allPage = 0   
    -- 1 分页姻缘签，2 我的姻缘签，3 查找姻缘签
    self.showType = 1 
    -- 界面数据对应的实际页数
    self.curPage = 0
    self.yyqNo = ""

    self:showNumImgPage(self.showPage, self.allPage)
    
    self:requestOnePage(MarryMgr:getLastPage())
    
    self:hookMsg("MSG_YYQ_PAGE")
    self:hookMsg("MSG_REQUEST_MY_YYQ_RESULT")
    self:hookMsg("MSG_SEARCH_YYQ_RESULT")
end

function MarriageTreeDlg:requestOnePage(page)
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_YYQ_PAGE", {page = page})
end

function MarriageTreeDlg:requestMySign()
    DlgMgr:openDlg("WaitDlg")
    gf:CmdToServer("CMD_REQUEST_MY_YYQ", {})
end

function MarriageTreeDlg:requestSearchOneSign(no)
    gf:CmdToServer("CMD_SEARCH_YYQ", {yyq_no = no})
end

function MarriageTreeDlg:onMySignButton(sender, eventType)
    self:requestMySign()
end

-- 返回姻缘树
function MarriageTreeDlg:onBackToTreeButton(sender, eventType)
    self:requestOnePage(self.showPage)
end

-- 查找
function MarriageTreeDlg:onSearchButton(sender, eventType)
    if not string.match(self.yyqNo, "%d+") then
        gf:ShowSmallTips(CHS[5420090])
        return
    end
    
    if self.allPage == 0 then
        gf:ShowSmallTips(CHS[5420094])
        return
    end
    
    self:requestSearchOneSign(self.yyqNo)
end

-- 删除查找内容
function MarriageTreeDlg:onDelAllButton(sender, eventType)
    self:setColorText("         ", "TextPanel")
    self.yyqNo = ""
    self:setCtrlVisible("DelAllButton", false)
    self:setCtrlVisible("TextField", true)
end

function MarriageTreeDlg:onLeftButton(sender, eventType)
    if self.allPage == 0 then
        return false
    end
    
    if self.showPage <= 1 then
        gf:ShowSmallTips(CHS[5420085])
        return true
    end
    
    self.showPage = self.showPage - 1
    self:requestOnePage(self.showPage)
    
    return true
end

function MarriageTreeDlg:onRightButton(sender, eventType)
    if self.allPage == 0 then
        return false
    end
    
    if self.showPage >= self.allPage then
        gf:ShowSmallTips(CHS[5420086])
        return true
    end
    
    self.showPage = self.showPage + 1
    self:requestOnePage(self.showPage)
    
    return true
end

function MarriageTreeDlg:showNumImgPage(showPage, allPage)
    local pageDesc = showPage .. "/" .. allPage
    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageDesc, false, LOCATE_POSITION.MID, 19)
end

function MarriageTreeDlg:showSignPanel(data, tag, panel)
    local signPanel
    if data.yyq_type == 1 then
        signPanel = self.paperSignPanel:clone()
    elseif data.yyq_type == 2 then
        signPanel = self.bamboosSignPanel:clone()
    else
        signPanel = self.jadeSignPanel:clone()
    end 
    
    signPanel:setAnchorPoint(0, 0)
    signPanel:setPosition(0, 0)
    signPanel:setTag(tag)
    panel:addChild(signPanel)
    
    local text = data.text
    if gf:getTextLength(text) > WORD_LIMIT * 2 then
        text = gf:subString(text, WORD_LIMIT * 2) .. "..."
    end
    
    self:setLabelText("InfoLabel", text, signPanel)
    self:setLabelText("NumLabel", data.yyq_no, signPanel)
    
    self:bindTouchEndEventListener(signPanel, self.onShowMarriageSign)
end

-- 展示姻缘签内容
function MarriageTreeDlg:onShowMarriageSign(sender, eventType)
    local tag = sender:getTag()
    local dlg = DlgMgr:openDlg("MarriageSignDlg")
    dlg:setData(tag, self.showType)
end

function MarriageTreeDlg:cleanup(sender, eventType)
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)
    self:releaseCloneCtrl("paperSignPanel")
    self:releaseCloneCtrl("bamboosSignPanel")
    self:releaseCloneCtrl("jadeSignPanel")
    self:releaseCloneCtrl("treePanel")
    
    if self.showPage > 0 then
        MarryMgr.lastCloseTreeDlgTime = gf:getServerTime()
        MarryMgr.lastTreeDlgPage = self.showPage
    end
end

-- 数字键盘插入数字
function MarriageTreeDlg:insertNumber(num, key)
   if key == 1 then
        if num < 0 then
            num = 0
        end
        
        if self.allPage > 0 then
            if num <= 0 then
                gf:ShowSmallTips(CHS[5420085])
                num = 1
            end
            
            if num > self.allPage then
                gf:ShowSmallTips(CHS[5420092])
                num = self.allPage
            end
        else
            num = 0
        end
        
        self.showPage = num
        
        self:showNumImgPage(self.showPage, self.allPage)
        
        self:requestOnePage(self.showPage)
    else
        
        if num > 1000000 then
            num = math.floor(num / 10)
            gf:ShowSmallTips(CHS[5420093])
        end
        
        self.yyqNo = num
        
        if num == 0 then
            self:setCtrlVisible("TextField", true)
            self:setCtrlVisible("DelAllButton", false)
            self:setColorText("          ", "TextPanel")
        else
            self:setCtrlVisible("TextField", false)
            self:setCtrlVisible("DelAllButton", true)
            self:setColorText(tostring(num), "TextPanel", nil, 3, 5)
        end
    end

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(num)
    end
end

-- 限制数字键盘的显示
function MarriageTreeDlg:limitCallBack()
    if self.allPage <= 3 then
        gf:ShowSmallTips(CHS[5420091])
        return true
    end

    return false
end

-- 搜索姻缘签结果
function MarriageTreeDlg:MSG_SEARCH_YYQ_RESULT(data)
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)
 
    local dlg = DlgMgr:openDlg("MarriageSignDlg")
    dlg:setData(1, 3)
end

-- 姻缘签分页数据
function MarriageTreeDlg:MSG_YYQ_PAGE(data)
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)
    
    self:setCtrlVisible("MySignPanel", false)
    self:setCtrlVisible("MySignButton", true)
    self:setCtrlVisible("BackToTreeButton", false)
    self:setCtrlVisible("PagePanel", true)
    self:setCtrlVisible("SearchPanel", true)
    
    if data.allPage == 0 then
        self:setCtrlVisible("TreeScrollView", false)
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("TreeScrollView", true)
        self:setCtrlVisible("NoticePanel", false)
    end
    
    self:initScrollViewPanel(self.treePanel, self:getControl("TreeScrollView"), true)
    
    for i = 1, 12 do
        local signPanel = self:getControl("SignPanel_" .. i, nil, "TreePanel")
        if signPanel:getChildByTag(i) then
            signPanel:removeChildByTag(i)
        end
    end
    
    for i = 1, #data do
        local signPanel = self:getControl("SignPanel_" .. i, nil, "TreePanel")
        self:showSignPanel(data[i], i, signPanel)
    end

    self.showPage = data.curPage
    self.curPage = data.curPage
    self.allPage = data.allPage
    if self.allPage > TOTALPAGE_MAX then
        self.allPage = TOTALPAGE_MAX
    end
    
    self:showNumImgPage(self.showPage, self.allPage)
    
    self.showType = 1
end

-- 我的姻缘签数据
function MarriageTreeDlg:MSG_REQUEST_MY_YYQ_RESULT(data)
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)
    
    if data.count == 0 then
        return
    end
    
    self:setCtrlVisible("TreeScrollView", false)
    self:setCtrlVisible("MySignPanel", true)
    self:setCtrlVisible("MySignButton", false)
    self:setCtrlVisible("BackToTreeButton", true)
    self:setCtrlVisible("PagePanel", false)
    self:setCtrlVisible("SearchPanel", false)
    
    for i = 1, 3 do
        local signPanel = self:getControl("SignPanel_" .. i, nil, "MySignPanel")
        if signPanel:getChildByTag(i) then
            signPanel:removeChildByTag(i)
        end
        
        if i == 2 then
            if signPanel:getChildByTag(1) then
                signPanel:removeChildByTag(1)
            end
        end
    end
    
    local cou = #data
    if cou == 1 then
        local signPanel = self:getControl("SignPanel_2", nil, "MySignPanel")
        self:showSignPanel(data[1], 1, signPanel)
    else
        if cou > 3 then
            cou = 3
        end
        
        for i = 1, cou do
            local signPanel = self:getControl("SignPanel_" .. i, nil, "MySignPanel")
            self:showSignPanel(data[i], i, signPanel)
        end
    end
    

    self.showType = 2
end

function MarriageTreeDlg:initScrollViewPanel(cellColne, scrollView, needScrollCallFuc)
    if not scrollView then return end
    scrollView:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    
    local cell = cellColne:clone()
    cell:setAnchorPoint(0, 0)
    cell:setPosition(0, 0)
    contentLayer:addChild(cell)

    contentLayer:setContentSize(scrollView:getContentSize().width, cellColne:getContentSize().height)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())
    scrollView:setTouchEnabled(true)
    scrollView:setClippingEnabled(true)
    scrollView:setBounceEnabled(true)

    scrollView:getInnerContainer():setPositionX(0)
    
    self.notChangePageLeft = false
    self.notChangePageRight = false
    if needScrollCallFuc then
        local  function scrollListener(sender , eventType)
            if eventType == ccui.ScrollviewEventType.scrolling then
                -- 向左向右滑动 offset 时，跳到另一页
                local offset = SCROLL_CHANGEPAGE
                local  x = scrollView:getInnerContainer():getPositionX()
                if not self.notChangePageLeft and x > offset then
                    self.notChangePageLeft = self:onLeftButton()
                end
                
                if not self.notChangePageRight and x < - offset then
                    self.notChangePageRight = self:onRightButton()
                end
            end
        end
        
        scrollView:addEventListener(scrollListener)
    end

    scrollView:addChild(contentLayer)
end

-- 换线流程会中断，需重新请求换线
function MarriageTreeDlg:resetWaitStatus()
    DlgMgr:closeDlg("WaitDlg", nil, nil, true)
    if self.showPage ~= self.curPage and self.showType == 1 then
        self:requestOnePage(self.showPage)  
    end
end

return MarriageTreeDlg
