-- CallMemberDlg.lua
-- Created by huangzz 
-- @ 成员选择界面

local CallMemberDlg = Singleton("CallMemberDlg", Dialog)

local WORD_LIMIT = 6

local SCROLL_CHANGEPAGE_Y = 60
local onePageHeight

function CallMemberDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("MemberPanel", self.onMemberPanel)
    self:bindListener("DefiniteButton", self.onDefiniteButton)
    
    self.memberPanel = self:retainCtrl("MemberPanel", "MemberScrollView")
    self.scrollView = self:getControl("MemberScrollView")
    
    self.selectImage = self:retainCtrl("BKImage2", self.memberPanel)

    local size = self.memberPanel:getContentSize()
    onePageHeight = size.height * 4
    
    self.curPage = 0
    self.allPage = 0
    self.selectCell = nil
    self.allMembers = {}
    self.delayAction = nil
    
    self:intiInputPanel()
    self:bindScrollView()
    
    self:hookMsg("MSG_CHAT_GROUP_AITE_INFO")
    self:hookMsg("MSG_PARTY_AITE_INFO")
end

local function onScrollView(sender, eventType)
    if CallMemberDlg.allPage < 2 then
        return
    end
    
    if eventType == ccui.ScrollviewEventType.scrolling
        or eventType == ccui.ScrollviewEventType.Bottom
        or eventType == ccui.ScrollviewEventType.scrollToBottom then
        -- 获取控件
        local innerContent = sender:getInnerContainer()
        local innerSize = innerContent:getContentSize()
        local scrollViewSize = sender:getContentSize()

        -- 计算滚动的百分比
        local innerPosY = math.floor(innerContent:getPositionY() + 0.5)
        local totalHeight = innerSize.height - scrollViewSize.height

        local scrollHeight = totalHeight + innerPosY

        local toPage = math.floor(scrollHeight / onePageHeight) + 1

        if toPage == 0 then
            toPage = 1
        elseif toPage > CallMemberDlg.allPage then
            toPage = CallMemberDlg.allPage
        end

        if toPage ~= CallMemberDlg.curPage then
            CallMemberDlg.curPage = toPage
            CallMemberDlg:setPageView(true)
        end
    end
end

-- 初始化列表
function CallMemberDlg:bindScrollView()
    self.scrollView:addEventListener(onScrollView)
end

function CallMemberDlg:onSearchButton(sender, eventType)
    local content = self.inputCtrl:getText()
    if not content or content == "" then
        gf:ShowSmallTips(CHS[5400296])
        self:initScrollViewPanel(self.allMembers)
    elseif gf:getTextLength(content) < 4 then
        gf:ShowSmallTips(CHS[5400298])
    else
        local members = self:getSearchMembers(content)
        if not members or #members <= 0 then
            gf:ShowSmallTips(CHS[5400302])
        end
        
        self:initScrollViewPanel(members)
    end
end

function CallMemberDlg:onDelAllButton(sender, eventType)
    self:setCtrlVisible("DelAllButton", false, "SearchPanel")
    self.inputCtrl:setText("")
    self:initScrollViewPanel(self.allMembers)
end

function CallMemberDlg:onLeftButton(sender, eventType)
    if self.curPage <= 1 then
        gf:ShowSmallTips(CHS[5400300])
    else
        self.curPage = self.curPage - 1
    end
     
    self:setPageView()
end

function CallMemberDlg:onRightButton(sender, eventType)
    if self.curPage >= self.allPage then
        gf:ShowSmallTips(CHS[5400301])
    else
        self.curPage = self.curPage + 1
    end

    self:setPageView()
end

function CallMemberDlg:onMemberPanel(sender, eventType)
    if self.selectCell == sender then
        return
    end
    
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
    self.selectCell = sender
end

function CallMemberDlg:onDefiniteButton(sender, eventType)
    if not self.selectCell then
        gf:ShowSmallTips(CHS[5400303])
        return
    end
    
    local member = self.selectCell.member 
    if not member then
        return
    end
    
    if member.isOnline == 2 then
        gf:ShowSmallTips(CHS[5400304])
        return
    end

    local realName =  gf:getRealName(member.name)
    if self.obj and self.obj["addCallChar"] then
        self.obj["addCallChar"](self.obj, realName)
    end

    self:onCloseButton()
end

function CallMemberDlg:setPageView(notScroll)
    local pageDesc = self.curPage .. "/" .. self.allPage
    self:setNumImgForPanel("PageInfoPanel", ART_FONT_COLOR.DEFAULT, pageDesc, false, LOCATE_POSITION.MID, 19)
    if not notScroll then
        local persent, time = self:getPercentAndTimeByPage(self.curPage)
        self.scrollView:scrollToPercentVertical(persent, time, false)
        self.scrollView:addEventListener(function() end)
        
        if self.delayAction then
            self.scrollView:stopAction(self.delayAction)
        end
        
        self.delayAction = performWithDelay(self.scrollView, function() 
            self.scrollView:addEventListener(onScrollView)
            self.delayAction = nil
        end, time + 0.01)
    end
end

function CallMemberDlg:getCurPagePosY()
    return (self.curPage - 1) * onePageHeight
end

function CallMemberDlg:getPercentAndTimeByPage(page)
    local scrollView = self.scrollView
    local innerContent = scrollView:getInnerContainer()
    local innerSize = innerContent:getContentSize()
    local scrollViewSize = scrollView:getContentSize()

    -- 计算滚动的百分比
    local innerPosY = math.floor(innerContent:getPositionY() + 0.5)
    local toPosY = self:getCurPagePosY()
    local totalHeight = innerSize.height - scrollViewSize.height
    local time = math.max(0.05, math.abs(toPosY - (innerPosY + totalHeight)) / onePageHeight * 0.3)
    
    local persent = toPosY / totalHeight * 100
    return persent, time
end

function CallMemberDlg:intiInputPanel()
    -- 初始化编辑框
    self:setCtrlVisible("DelAllButton", false, "SearchPanel")
    self.inputCtrl = self:createEditBox("InputPanel", "SearchPanel", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT * 2 then
                content = gf:subString(content, WORD_LIMIT * 2)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400297])
            end

            if len == 0 then
                self:setCtrlVisible("DelAllButton", false, "SearchPanel")
                gf:ShowSmallTips(CHS[5400296])
                self:initScrollViewPanel(self.allMembers)
            else
                self:setCtrlVisible("DelAllButton", true,  "SearchPanel")
            end
        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 21)
    self.inputCtrl:setFont(CHS[3003794], 21)
    self.inputCtrl:setPlaceHolder(CHS[5400296])
    self.inputCtrl:setPlaceholderFontSize(21)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
end

function CallMemberDlg:initAllMembers(data)
    local allMembers = data
    
    table.sort(allMembers, function(l, r)
        if l.isOnline < r.isOnline then
            return true
        elseif l.isOnline > r.isOnline then
            return false
        end

        if self.groupGid then
            if FriendMgr:isGroupLeaderByGroupIdAndGid(self.groupGid, l.gid) then
                return true
            end
            
            if FriendMgr:isGroupLeaderByGroupIdAndGid(self.groupGid, r.gid) then
                return false
            end
        else 
            local lJobId = PartyMgr:getJobOrder(l.party_job)
            local rJobId = PartyMgr:getJobOrder(r.party_job)
            if lJobId > rJobId then return true end
            if lJobId < rJobId then return false end
        end
        
        if l.insider_level > 0 and r.insider_level <= 0 then
            return true
        elseif l.insider_level <= 0 and r.insider_level > 0 then
            return false
        end
        
        if l.name < r.name then
            return true
        elseif l.name > r.name then
            return false
        end
        
        return false
    end)
    
    self.allMembers = allMembers
end

function CallMemberDlg:getSearchMembers(pattern)
    local members
    local matchId = false
    if gf:isMeetSearchByGid(pattern) then
        matchId = true
        pattern = string.upper(pattern) -- 全部转化为大写字母，方便匹配
    end
    
    if pattern and pattern ~= "" then
        members = {}
        for i = 1, #self.allMembers do
            local subGid = gf:getShowId(self.allMembers[i].gid)
            if matchId then
                -- 精确匹配 id
                if subGid == pattern then
                    table.insert(members, self.allMembers[i])
                end
            elseif string.match(self.allMembers[i].name, pattern) then
                -- 模糊匹配名字
                table.insert(members, self.allMembers[i])
            end
        end
    else
        members = self.allMembers
    end
    
    return members
end

function CallMemberDlg:setFriendPanel(cell, member)
    -- 显示图标
    local iconPath = ResMgr:getSmallPortrait(member.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
    if 1 ~= member.isOnline then
        gf:grayImageView(imgCtrl)
    else
        gf:resetImageView(imgCtrl)
    end
    
    -- 群主图标
    if self.groupGid and FriendMgr:isGroupLeaderByGroupIdAndGid(self.groupGid, member.gid) then
        self:setCtrlVisible("MsterImage", true, cell)
    else
        self:setCtrlVisible("MsterImage", false, cell)
    end

    -- 显示等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        member.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 显示名字
    local realName =  gf:getRealName(member.name)
    if 2 == member.isOnline then
        self:setLabelText("PlayerNameLabel", realName, cell, COLOR3.BROWN)
    elseif 0 == member.insider_level then
        self:setLabelText("PlayerNameLabel", realName, cell, COLOR3.GREEN)
    elseif 0 ~= member.insider_level then
        self:setLabelText("PlayerNameLabel", realName, cell, COLOR3.CHAR_VIP_BLUE_EX)
    end
    
    -- 帮派名或职位
    if self.groupGid then
        self:setLabelText("PartyPositionLabel", member.party_name or "", cell)
    else
        self:setLabelText("PartyPositionLabel", member.party_job or "", cell)
    end
    
    cell.member = member
end

function CallMemberDlg:setCallObj(obj, type)
    self.obj = obj
    self.groupGid = nil
    if type == CHAT_CHANNEL.PARTY then
        gf:CmdToServer("CMD_PARTY_AITE_INFO", {})
    else
        self.groupGid = DlgMgr:sendMsg("FriendDlg", "getCurChatGid")
        if not self.groupGid then
            return
        end
        
        gf:CmdToServer("CMD_CHAT_GROUP_AITE_INFO", {group_id = self.groupGid})
    end
end

function CallMemberDlg:initScrollViewPanel(data)
    local column = 3
    local scrollView = self.scrollView
    scrollView:removeAllChildren()
    scrollView:setBounceEnabled(true)
    
    if self.schedule then
        self:stopSchedule(self.schedule)
    end
    
    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data / column)
    local left = #data % column

    if left ~= 0 then
        line = line + 1
    end
    
    self.selectCell = nil
    self.allPage = math.ceil(line / 4)

    local curColunm = 0
    local cellSize = self.memberPanel:getContentSize()
    local totalHeight = self.allPage * cellSize.height * 4
    
    local curLine = 1
    local oneLoadLine = 4
    local function func()
        for i = curLine, curLine + oneLoadLine - 1 do
            if i == line and left ~= 0 then
                curColunm = left
            elseif i <= line then
                curColunm = column
            else
                self:stopSchedule(self.schedule)
                self.schedule = nil
                return
            end

            for j = 1, curColunm do
                local tag = j + (i - 1) * column
                local cell = self.memberPanel:clone()
                cell:setAnchorPoint(0,1)
                local x = (j - 1) * (cellSize.width)
                local y = totalHeight - (i - 1) * (cellSize.height)
                cell:setPosition(x, y)
                cell:setTag(tag)
                self:setFriendPanel(cell , data[tag])
                contentLayer:addChild(cell)
            end
        end
        
        curLine = curLine + oneLoadLine
    end
    
    self.schedule = self:startSchedule(func, 0.03)
    
    func()
    
    contentLayer:setContentSize(scrollView:getContentSize().width, totalHeight)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())

    if totalHeight < scrollView:getContentSize().height then
        contentLayer:setPositionY(scrollView:getContentSize().height  - totalHeight)
    end
    
    scrollView:addChild(contentLayer, 0, 99)
    
    self.curPage = line == 0 and 0 or 1
    self:setPageView(true)
    scrollView:jumpToTop()
end

function CallMemberDlg:initMembersView(members)
    self:initScrollViewPanel(members)
end

function CallMemberDlg:cleanup()
    self.groupGid = nil
end

function CallMemberDlg:MSG_PARTY_AITE_INFO(data)
    self:initAllMembers(data)
    self:initScrollViewPanel(self.allMembers)
end

function CallMemberDlg:MSG_CHAT_GROUP_AITE_INFO(data)
    self:initAllMembers(data)
    self:initScrollViewPanel(self.allMembers)
end

return CallMemberDlg
