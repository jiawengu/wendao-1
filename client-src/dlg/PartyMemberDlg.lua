-- PartyMemberDlg.lua
-- Created by Chang_back Jun/17/2015
-- 帮派成员功能界面

local PartyMemberDlg = Singleton("PartyMemberDlg", Dialog)

local INIT_PANEL_TYPE = {
    INIT_PARTY_MEMBER = 1,
    INIT_PARTY_RECRUIT = 2
}

local ONE_WEEK = 60 * 60 * 24 * 7

PartyMemberDlg.applyMembers = {}
PartyMemberDlg.partyMembers = {}
local PER_PAGE_COUNT = 6
local INIT_COUNT = PER_PAGE_COUNT * 2
local PANEL_HEIGHT = 48

local ONE_PAGE_NUM = 8

local REQUEST_SPACE_TIME = 30  -- 翻页请求数据 30s 间隔

local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_KIND = {
    "LevelPanel",       "PolarPanel",           "TaoPanel",
    "WarTimesPanel",    "LoginOutTimePanel",    "JoinPartyTimePanel",
    "JobPanel",         "ActivePanel",          "ThisWeekActivePanel",
    "LastWeekActivePanel", "ThisSessionWarTimesPanel"
}

-- 成员列表排序类型，以表 DISPLAY_KIND中数据，def为默认
PartyMemberDlg.curSortKind = "def"

-- 是否是升序排列
PartyMemberDlg.isIncrease = false

-- 申请列表按钮的小红点是否正在被移除
PartyMemberDlg.isRecruitRedDotRemoved = false

function PartyMemberDlg:init()
    self:bindListener("NextPageButton", self.onNextPageButton)
    self:bindListener("LastPageButton", self.onLastPageButton)
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("PartyListButton", self.onPartyListButton)
    self:bindListener("SendNotifyButton", self.onSendNotifyButton)
    self:bindListener("AgreeAllButton", self.onAgreeAllButton)
    self:bindListener("EmptyButton", self.onEmptyButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("CheckBox", self.onCheckBox)
    self:bindListener("AutoAcceptPanel", self.onAutoAcceptPanel)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("MoreButton", self.onMoreButton, "OperatePanel_1")    -- 更多操作
    self:bindListener("ChangeButton", self.onChangeButton, "OperatePanel_2")    -- 返回翻页区
    self:bindListener("LastButton", self.onLastButton, "OperatePanel_1")    -- 上一页
    self:bindListener("NextButton", self.onNextButton, "OperatePanel_1")    -- 下一页

    self:setCtrlVisible("DefaultLabel", false, "SearchPanel")
    self:setCtrlVisible("CleanFieldButton", false)
    self.limit = 12
    self.newEdit = self:createEditBox("InputPanel", "SearchPanel", nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = self.newEdit:getText()
            if gf:getTextLength(newName) > self.limit then
                newName = gf:subString(newName, self.limit)
                self.newEdit:setText(newName)
                gf:ShowSmallTips(CHS[4000224])
            end

            if gf:getTextLength(newName) == 0 then
                self:onCleanFieldButton(self:getControl("CleanFieldButton", "SearchPanel"))
            else
                self:setCtrlVisible("CleanFieldButton", true)
            end
        end
    end)

    self.newEdit:setPlaceHolder(CHS[7001014])
    self.newEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newEdit:setPlaceholderFont(CHS[3003597], 21)
    self.newEdit:setFont(CHS[3003597], 21)
    self.newEdit:setFontColor(COLOR3.WHITE)
    self.newEdit:setText("")

    self:bindListener("CleanFieldButton", self.onCleanFieldButton, "SearchPanel")
    self:bindListener("SearchButton", self.onSearchButton, "SearchPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItemsCanReClick(self, {"PartyMemberCheckBox", "PartyRecruitCheckBox"}, self.onPartyTypeCheckBox)
    self.radioGroup:selectRadio(1)

    -- 帮派成员listview
    local memberPanel1 = self:getControl("PartyMemberListPanel_1", Const.UIPanel)
    local memberPanel2 = self:getControl("PartyMemberListPanel_2", Const.UIPanel)

    for _, name in pairs(DISPLAY_KIND) do
        self:bindListener(name, self.onSortKind, memberPanel1)
        self:bindListener(name, self.onSortKind, memberPanel2)
    end

    self.partyMemberListView1 = self:getControl("PartyMemberListView", Const.UIListView, memberPanel1)
    self.tempOneRawMemberPanel1 = self:retainCtrl("OneRowPartyMemberPanel", memberPanel1)
    self.chosenImg = self:retainCtrl("ChosenEffectImage", self.tempOneRawMemberPanel1)
    self.partyMemberListView1:removeAllItems()

    self.partyMemberListView2 = self:getControl("PartyMemberListView", Const.UIListView, memberPanel2)
    self.tempOneRawMemberPanel2 = self:retainCtrl("OneRowPartyMemberPanel", memberPanel2)
    self.tempOneRawMemberPanel2:removeChildByName("ChosenEffectImage", true)
    self.partyMemberListView2:removeAllItems()

    -- 成员招收
    local partyRecruitListPanel = self:getControl("PartyRecruitListPanel", Const.UIPanel)
    self.partyRecruitListView = self:getControl("PartyRecruitListView", Const.UIListView)
    self.tempOneRowPartyRecruitPanel = self:retainCtrl("OneRowPartyRecruitPanel")

    -- 等级Panel
    self.levelPanel = self:retainCtrl("SingelPanel")


    -- 滚动加载
    local function func(dlg, percent, list)
        local y = list:getInnerContainer():getPositionY()
        local h = list:getInnerContainer():getContentSize().height - list:getContentSize().height
        h = math.min(0, h)
        if y > 15 then
            -- 加载
            self:onNextButton()
        elseif y < -(15 + h) then
            self:onLastButton()
        end
    end

    self:bindListViewByPageLoad("PartyMemberListView", "TouchPanel", func, "PartyMemberListPanel_1")
    self:bindListViewByPageLoad("PartyMemberListView", "TouchPanel", func, "PartyMemberListPanel_2")

    self:bindListViewByPageLoad("PartyRecruitListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            local memberList = self:getApplyMemberList(self.applyStart, PER_PAGE_COUNT)
            self:setPartyRecruitInfo(memberList)
        end
    end, "PartyRecruitListPanel")

    local hisInfo = PartyMgr:getPartyMemberDlgInfo()
    local curTime = gf:getServerTime()
    if hisInfo and curTime - hisInfo.lastTime < 150 then
        -- 有上次打开界面的历史数据，2分30秒内按照历史数据显示
        self.curSortKind = hisInfo.curSortKind
        self.curPage = hisInfo.curPage
        self.isIncrease = hisInfo.isIncrease
        self:showArrowsImg(self.curSortKind)
    else
        self.curPage = 1
        self.curSortKind = "def"
    end

    self.denyList = {}
    self.curSearchStr = nil
    self.curIdx = 1
    self.isChangeList = false
    self.applyStart = 1
    self.lastRequestTime = 0
    self.applyMembers = {}
    self.curInitType = INIT_PANEL_TYPE.INIT_PARTY_MEMBER
    self:setPartyTitle()

    -- 初始化等级轮
    self:initLevelList()
    self:setCtrlVisible("LevelSettingPanel", false)

    -- 右移更多操作框
    local oPanel1 = self:getControl("OperatePanel_1", nil, "PartyMemberPanel")
    local oPanel2 = self:getControl("OperatePanel_2", nil, "PartyMemberPanel")
    oPanel1:setVisible(true)
    oPanel2:setVisible(true)
    oPanel2:setPositionX(oPanel1:getContentSize().width)
    self.newEdit:setEnabled(false)

    -- 分页绑定数字键盘
    self:bindNumInput("PageNumPanel", "OperatePanel_1", self.onLimitNum)

    self:hookMsg("MSG_PARTY_MEMBERS")
    self:hookMsg("MSG_PARTY_QUERY_MEMBER")
    self:hookMsg("MSG_PARTY_CHANNEL_DENY_LIST")
    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_DIALOG")
    self:hookMsg("MSG_CLEAN_REQUEST")
    self:hookMsg("MSG_CLEAN_ALL_REQUEST")
    self:hookMsg("MSG_MEMBER_NOT_IN_PARTY")
    self:hookMsg("MSG_PARTY_INFO")

    self:initCheckBox()

    self:setCtrlVisible("PartyMemberListPanel_2", false)
    self:setCtrlVisible("PartyMemberListPanel_1", false)

    if PartyMgr:checkAgreeOrDenyApply() then
    else
        self:setCtrlEnabled("EmptyButton", false)
        self:setCtrlEnabled("AgreeAllButton", false)
        self:setCtrlEnabled("RefreshButton", false)
        self:setCtrlVisible("RefuseConfigPanel", false)
    end

    local partyInfo = PartyMgr:getPartyInfo()
    if not partyInfo then
        PartyMgr:queryPartyInfo()
    end
	-- 获取禁言成员列表
    PartyMgr:getProhibitSpeakingList()
    PartyMgr:queryPartyMembers()
    self:checkSenderPartyNotify()

    self:bindHideLevelBtn()
end

function PartyMemberDlg:onLimitNum()
    return self.isMoving
end

-- 数字键盘插入数字
function PartyMemberDlg:insertNumber(num)
    if not self.allPage then
        return
    end

    if num < 0 then
        num = 0
    end

    if self.allPage > 0 then
        if num <= 0 then
            gf:ShowSmallTips(CHS[5410236])
            num = 1
        end

        if num > self.allPage then
            gf:ShowSmallTips(CHS[5410237])
            num = self.allPage
        end
    else
        num = 0
    end

    self.curPage = num

    self:showCurPageData()

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(num)
    end
end

function PartyMemberDlg:moveOutPanel(dirX, time)
    if self.isMoving then return end

    local oPanel1 = self:getControl("OperatePanel_1", nil, "PartyMemberPanel")
    local oPanel2 = self:getControl("OperatePanel_2", nil, "PartyMemberPanel")
    local moveX = oPanel1:getContentSize().width * dirX
    local action = cc.MoveBy:create(time or 0.2, {x = moveX, y = 0})
    oPanel1:runAction(action)
    self.newEdit:setEnabled(false)
    self:setCtrlTouchEnabled("ExitButton", false)
    self:setCtrlTouchEnabled("SearchButton", false)
    self:setCtrlTouchEnabled("SendNotifyButton", false)
    self:setCtrlTouchEnabled("PartyListButton", false)
    self:setCtrlTouchEnabled("LastButton", false)
    self:setCtrlTouchEnabled("NextButton", false)

    local action2 = cc.MoveBy:create(time or 0.2, {x = moveX, y = 0})
    oPanel2:runAction(cc.Sequence:create(
        action2,
        cc.CallFunc:create(function()
            self.isMoving = false
            DlgMgr:closeDlg("SmallNumInputDlg")
            if dirX < 0 then
                self.newEdit:setEnabled(true)
                self:setCtrlTouchEnabled("SearchButton", true)
                self:setCtrlTouchEnabled("SendNotifyButton", true)
                self:setCtrlTouchEnabled("PartyListButton", true)
            else
                self:setCtrlTouchEnabled("ExitButton", true)
                self:setCtrlTouchEnabled("LastButton", true)
                self:setCtrlTouchEnabled("NextButton", true)
            end
        end)
    ))

    self.isMoving = true
end

-- 更多操作
function PartyMemberDlg:onMoreButton(sender, eventType)
    self:moveOutPanel(-1)
end

-- 返回翻页
function PartyMemberDlg:onChangeButton(sender, eventType)
    self:moveOutPanel(1)
end

function PartyMemberDlg:refreshMembersData()
    local curTime = gf:getServerTime()
    if curTime - self.lastRequestTime >= REQUEST_SPACE_TIME then
        PartyMgr:queryPartyMembers()
        PartyMgr:getProhibitSpeakingList()
        self.lastRequestTime = curTime
    end
end

function PartyMemberDlg:onNextButton()
    if not self.showMembers then
        return
    end

    local allPage = math.ceil(#self.showMembers / ONE_PAGE_NUM)

    if self.curPage >= allPage then
        self:refreshMembersData()
        gf:ShowSmallTips(string.format(CHS[5410235], allPage))
        return
    end

    self.curPage = self.curPage + 1
    self:showCurPageData()
end

function PartyMemberDlg:onLastButton()
    if not self.showMembers then
        return
    end

    if self.curPage == 1 then
        gf:ShowSmallTips(string.format(CHS[5410235], 1))
        self:refreshMembersData()
        return
    end

    self.curPage = self.curPage - 1
    self:showCurPageData()
end

function PartyMemberDlg:showCurPageData()
    local data = self:getCurPageData()
    self:setMembersList(data)

    self.chosenImg:removeFromParent()
end

-- 获取当前页数据
function PartyMemberDlg:getCurPageData()
    local data = self.showMembers or {}
    local cou = #data
    local allPage = math.ceil(cou / ONE_PAGE_NUM)

    if self.curPage > allPage then
        self.curPage = allPage
    end

    if self.curPage < 1 then
        self.curPage = 1
    end

    local startIndex = (self.curPage - 1) * ONE_PAGE_NUM
    local curPageData = {}
    for i = startIndex + 1, startIndex + ONE_PAGE_NUM do
        table.insert(curPageData, data[i])
    end

    -- 显示页数
    self.allPage = allPage
    self:showNumImgPage(self.curPage, self.allPage)

    return curPageData
end

function PartyMemberDlg:showNumImgPage(showPage, allPage)
    local pageDesc = showPage .. "/" .. allPage
    self:setNumImgForPanel("PageNumPanel", ART_FONT_COLOR.DEFAULT, pageDesc, false, LOCATE_POSITION.MID, 19, "OperatePanel_1")
end

function PartyMemberDlg:searchMembers(code)
    local isIdSearch = gf:isMeetSearchByGid(code)
    local ret = {}
    if isIdSearch then
        for i = 1, self.partyMembers.count do
            if code == gf:getShowId(self.partyMembers.members[i].gid) then
                table.insert(ret, self.partyMembers.members[i])
            end
        end
    else
        for i = 1, self.partyMembers.count do
            if string.match(self.partyMembers.members[i].name, code) then
                table.insert(ret, self.partyMembers.members[i])
            end
        end
    end
    return ret
end

-- 查询
function PartyMemberDlg:onSearchButton(sender, eventType)
    if not self.partyMembers or not next(self.partyMembers) then return end
    local code = self.newEdit:getText()

    if code == "" then
        gf:ShowSmallTips(CHS[4300140])
        return
    end

    local data = self:searchMembers(code)
    if not next(data) then
        gf:ShowSmallTips(CHS[4300141])
        return
    end

    self.curSearchStr = code
    self.showMembers = data
    self.curPage = 1
    self:showCurPageData()
end

-- 清空
function PartyMemberDlg:onCleanFieldButton(sender, eventType)
    self.newEdit:setText("")
    sender:setVisible(false)
    if self.curSearchStr then
        self.curSearchStr = nil
        self.curPage = 1
        self.showMembers = self.partyMembers.members

        -- 加载
        self:showCurPageData()
    end
end

function PartyMemberDlg:bindHideLevelBtn()
    self:bindListener("BkPanel", function (parameters)
        self:setCtrlVisible("LevelSettingPanel", false)
    end)

    self.topLayer = ccui.Layout:create()
    self.topLayer:setLocalZOrder(100)
    self.topLayer:setContentSize(self.root:getContentSize())

    -- 添加监听
    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(function (touch, event)
            if event:getEventCode() == cc.EventCode.BEGAN then
                local locationPos = touch:getLocation()
                local pos = self:getControl("MainBodyPanel"):convertTouchToNodeSpace(touch)
                local ctrl = self:getControl("LevelSettingPanel")
                local rect = ctrl:getBoundingBox()

                if not cc.rectContainsPoint(rect, pos) then
                    self:setCtrlVisible("LevelSettingPanel", false)
                end

            end
        end, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加监听
    local dispatcher = self.topLayer:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self.topLayer)
    self.root:addChild(self.topLayer)
end

-- 初始化等级轮选项
function PartyMemberDlg:initLevelList()
    local listMin = self:getControl("MinListView")
    local listMax = self:getControl("MaxListView")
    local count = Const.PLAYER_MAX_LEVEL - PartyMgr:getJoinPartyLevelMin() + 4 + 1
    local star = PartyMgr:getJoinPartyLevelMin()
    for i = 1,count  do
        local levelPanel1 = self.levelPanel:clone()
        local levelPanel2 = self.levelPanel:clone()
        if i <= 2 then
            self:setLabelText("LevelLabel", "", levelPanel1)
            self:setLabelText("LevelLabel", "", levelPanel2)
        elseif i >= count - 1 then
            self:setLabelText("LevelLabel", "", levelPanel1)
            self:setLabelText("LevelLabel", "", levelPanel2)
        else
            self:setLabelText("LevelLabel", star, levelPanel1)
            self:setLabelText("LevelLabel", star, levelPanel2)
            star = star + 1
        end

        levelPanel1:requestDoLayout()
        levelPanel2:requestDoLayout()
        listMin:pushBackCustomItem(levelPanel1)
        listMax:pushBackCustomItem(levelPanel2)
    end

    local function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.15)
            local func = cc.CallFunc:create(function()
                local _, offY = sender:getInnerContainer():getPosition()
                local befPercent = offY / (listMin:getInnerContainer():getContentSize().height - listMin:getContentSize().height) * 100 + 100
                local labelSize = self.levelPanel:getContentSize()
                local absOff = math.abs(offY)
                local num = Const.PLAYER_MAX_LEVEL - math.floor(absOff / labelSize.height)
                if absOff % labelSize.height > labelSize.height * 0.5 then num = num - 1 end
                local percent = ((num - PartyMgr:getJoinPartyLevelMin()) * labelSize.height)/ (listMin:getInnerContainer():getContentSize().height - listMin:getContentSize().height) * 100

                local lastNum = 0
                if sender:getName() == "MinListView" then lastNum = self.minLevel end
                if sender:getName() == "MaxListView" then lastNum = self.maxLevel end
                if math.abs(befPercent - percent) > 0.05 or num ~= lastNum then
                    sender:scrollToPercentVertical(percent, 0.5, false)
                    if sender:getName() == "MinListView" then self.minLevel = num end
                    if sender:getName() == "MaxListView" then self.maxLevel = num end
                    performWithDelay(self.root, function ()
                        self:setAutoAcceptLevel(self.minLevel, self.maxLevel)
                    end,0.5)
                end
            end)
            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end

    listMin:addScrollViewEventListener(scrollListener)
    listMax:addScrollViewEventListener(scrollListener)
end

function PartyMemberDlg:setAutoAcceptLevel(min, max)
    if not min or min == 0 then min = PartyMgr:getJoinPartyLevelMin() end
    if not max or max == 0 then min = Const.PLAYER_MAX_LEVEL end
    self:setLabelText("Label_1", string.format("(%d-%d)级", min, max), "AutoAcceptPanel")
end

-- 清理资源
function PartyMemberDlg:cleanup()
    self.isMoving = false
    PartyMgr.agreePlayerName = ""
    PartyMgr.fireName = ""
    PartyMgr.fireGid = ""

    PartyMgr:setPartyMemberDlgInfo({
        curSortKind = self.curSortKind,
        curPage = self.curPage,
        isIncrease = self.isIncrease,
        lastTime = gf:getServerTime()
    })
end

-- 设置是否置灰发送公告    自动接受等级
function PartyMemberDlg:initCheckBox()
    local partyInfo = PartyMgr:getPartyInfo()
    if partyInfo == nil then return end

    if not PartyMgr:checkAgreeOrDenyApply() then
        self:setCtrlEnabled("CheckBox", false)
    end

    self.minLevel = partyInfo.autoMinLevel
    self.maxLevel = partyInfo.autoMaxLevel
    self:setAutoAcceptLevel(partyInfo.autoMinLevel, partyInfo.autoMaxLevel)

    if partyInfo.reject_switch == 0 then
        self:setCheck("CheckBox", false)
    else
        self:setCheck("CheckBox", true)
    end
end

function PartyMemberDlg:setPartyTitle()
    local partyInfo = PartyMgr:getPartyInfo()
    if partyInfo == nil then return end
    self:setLabelText("TitleLabel_1", partyInfo.partyName)
    self:setLabelText("TitleLabel_2", partyInfo.partyName)
end

-- 显示成员列表
function PartyMemberDlg:setMembersList(memberList)
    if not memberList or not next(memberList) then
        self:onCleanFieldButton(self:getControl("CleanFieldButton", "SearchPanel"))
        return
    end

    if not self.partyMembers then
        self.partyMembers = {}
    end

    local memberPanel2 = self:getControl("PartyMemberListPanel_2", Const.UIPanel)
    local memberPanel1 = self:getControl("PartyMemberListPanel_1", Const.UIPanel)
    memberPanel1:setVisible(self.curIdx == 1)
    memberPanel2:setVisible(self.curIdx == 2)

    self:setPartyMemberLeftInfo(memberList)
    self:setPartyMemberRightInfo(memberList)
end

function PartyMemberDlg:creatLeftMemberPanels()
    for i = 1, 8 do
        local tempPanel = self.tempOneRawMemberPanel1:clone()
        tempPanel:setTag(i)
        tempPanel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onSelectMember(sender, eventType)
            end
        end)

        self.partyMemberListView1:pushBackCustomItem(tempPanel)
    end
end

function PartyMemberDlg:creatRightMemberPanels()
    for i = 1, 8 do
        local tempPanel = self.tempOneRawMemberPanel2:clone()
        tempPanel:setTag(i)
        tempPanel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:onSelectMember(sender, eventType)
            end
        end)

        self.partyMemberListView2:pushBackCustomItem(tempPanel)
    end
end

function PartyMemberDlg:setPartyMemberLeftInfo(memberList)
    local partyInfo = PartyMgr:getPartyInfo()
    local items = self.partyMemberListView1:getItems()
    if #items == 0 then
        self:creatLeftMemberPanels()
        items = self.partyMemberListView1:getItems()
    end

    if #items < 8 then return end

    for i = 1, 8 do
        if memberList[i] then
            local v = memberList[i]
            local tempPanel = items[i]
            tempPanel:setVisible(true)
            tempPanel:setName(v.gid)

            local color = COLOR3.GRAY
            if v.online == 1 then
                color = COLOR3.TEXT_DEFAULT
            end

            if i  % 2 ~= 0 then
                self:setCtrlVisible("BackImage_1", true, tempPanel)
                self:setCtrlVisible("BackImage_2", false, tempPanel)
            else
                self:setCtrlVisible("BackImage_2", true, tempPanel)
                self:setCtrlVisible("BackImage_1", false, tempPanel)
            end

            self:setLabelText("NameLabel", gf:getRealName(v.name), tempPanel, color)
            self:setLabelText("LevelLabel", v.level, tempPanel, color)
            local family = gf:getPolar(v.polor)
            self:setLabelText("FamilyLabel", family, tempPanel, color)

            -- 获取职位名称
            local job = PartyMgr:getJobName(v.job)
            if not job then
                job = v.job
            end

            if partyInfo.heir and v.name == partyInfo.heir then
                job = CHS[3003258]
            end

            -- 是否被禁言
            if self.denyList[v.gid] then
                self:setCtrlVisible("NoSpeaking", (self.denyList[v.gid].endTime and gf:getServerTime() <= self.denyList[v.gid].endTime), tempPanel)
            else
                self:setCtrlVisible("NoSpeaking", false, tempPanel)
            end

            -- 道行
            self:setLabelText("TaoLabel", gf:getTaoStr(v.tao, 0), tempPanel, color)

            -- 帮战次数
            self:setLabelText("WarTimesLabel", v.warTimes, tempPanel, color)
            self:setLabelText("ThisSessionWarTimesLabel", v.curWarTimes, tempPanel, color)

            self:setLabelText("JobLabel", job, tempPanel, color)
        else
            items[i]:setVisible(false)
        end
    end
end

function PartyMemberDlg:setPartyMemberRightInfo(memberList)
    local items = self.partyMemberListView2:getItems()
    if #items == 0 then
        self:creatRightMemberPanels()
        items = self.partyMemberListView2:getItems()
    end

    if #items < 8 then return end

    for i = 1, 8 do
        local v = memberList[i]
        if v then
            local tempPanel = items[i]
            tempPanel:setName(v.gid)
            tempPanel:setVisible(true)

            local color = COLOR3.GRAY
            if v.online == 1 then
                color = COLOR3.TEXT_DEFAULT
            end

            if i  % 2 ~= 0 then
                self:setCtrlVisible("BackImage_1", true, tempPanel)
                self:setCtrlVisible("BackImage_2", false, tempPanel)
            else
                self:setCtrlVisible("BackImage_2", true, tempPanel)
                self:setCtrlVisible("BackImage_1", false, tempPanel)
            end

            self:setLabelText("NameLabel", gf:getRealName(v.name), tempPanel, color)
            self:setLabelText("LevelLabel", v.level, tempPanel, color)

            if self.denyList[v.gid] then
                self:setCtrlVisible("NoSpeaking", (self.denyList[v.gid].hours ~= 0), tempPanel)
            else
                self:setCtrlVisible("NoSpeaking", false, tempPanel)
            end

            -- 相性
            local family = gf:getPolar(v.polor)
            self:setLabelText("PolarLabel", family, tempPanel, color)

            -- 发送数据请求
            self:setLabelText("TaoLabel", gf:getTaoStr(v.tao, 0), tempPanel, color)
            self:setLabelText("WarTimesLabel", v.warTimes, tempPanel, color)


            -- 加入帮派时间
            local jionTimeColor = COLOR3.GRAY
            if gf:getServerTime() - v.joinTime < ONE_WEEK then
                jionTimeColor = COLOR3.PURPLE
            else
                if v.online == 1 then
                    jionTimeColor = COLOR3.TEXT_DEFAULT
                end
            end

            if v.joinTime > 0 then
                local year = gf:getServerDate("%Y",v.joinTime)
                local month = gf:getServerDate("%m",v.joinTime)
                local date = gf:getServerDate("%d",v.joinTime)
                self:setLabelText("JoinPartyTimeLabel", year .. "-" .. month .. "-"  .. date, tempPanel, jionTimeColor)
            else
                self:setLabelText("JoinPartyTimeLabel", "-", tempPanel, jionTimeColor)
            end

            -- 离线时间
            local outTimeStr
            if v.logoutTime and v.logoutTime ~= 0 then
                local year = gf:getServerDate("%Y",v.logoutTime)
                local month = gf:getServerDate("%m",v.logoutTime)
                local date = gf:getServerDate("%d",v.logoutTime)
                outTimeStr = year .. "-" .. month .. "-"  .. date
            else
                outTimeStr = "-"
            end

            self:setLabelText("LoginOutLabel", outTimeStr, tempPanel, color)

            -- 活力
            self:setLabelText("ActiveLabel", v.active, tempPanel, color)
            self:setLabelText("ThisWeekActiveLabel", v.thisWeekActive, tempPanel, color)
            self:setLabelText("LastWeekActiveLabel", v.lastWeekActive, tempPanel, color)
        else
            items[i]:setVisible(false)
        end
    end
end

-- 设置是否置灰发送公告
function PartyMemberDlg:checkSenderPartyNotify()
    local meJob = Me:queryBasic("party/job")

    if meJob ~= CHS[3003259] and meJob ~= CHS[3003260] then
        self:setCtrlEnabled("SendNotifyButton", false)
    end

end

-- 设置招收成员列表
function PartyMemberDlg:setPartyRecruitInfo(applyMembers)

    if not applyMembers then
        return
    end

    if #applyMembers == 0 and self.isRecruitRedDotRemoved then
        gf:ShowSmallTips(CHS[7000015])
    end
    self.isRecruitRedDotRemoved = false

    self.applyStart = self.applyStart + #applyMembers

    for k, v in pairs(applyMembers) do
        local tempPanel = self.tempOneRowPartyRecruitPanel:clone()
        tempPanel:setName(v.gid)
        tempPanel:setTag(k)
        tempPanel.memberName = v.name
        tempPanel.level = v.level

        if k % 2 ~= 0 then
            self:setCtrlVisible("BackImage_1", true, tempPanel)
            self:setCtrlVisible("BackImage_2", false, tempPanel)
        else
            self:setCtrlVisible("BackImage_2", true, tempPanel)
            self:setCtrlVisible("BackImage_1", false, tempPanel)
        end

        self:setLabelText("NameLabel", gf:getRealName(v.name), tempPanel)
        self:setLabelText("LevelLabel", v.level, tempPanel)
        local polar = gf:getPolar(v.polar)
        self:setLabelText("PolarLabel", polar, tempPanel)
        self:setLabelText("FightScoreLabel", gf:getTaoStr(v.tao, 0), tempPanel)

        if PartyMgr:checkAgreeOrDenyApply() then
            -- 绑定同意 事件
            self:bindListener("AgreeButton", self.onAgreeButton, tempPanel)

            -- 绑定拒绝请求
            self:bindListener("RefuseButton", self.onRefuseButton, tempPanel)
        else
            self:setCtrlEnabled("AgreeButton", false, tempPanel)
            self:setCtrlEnabled("RefuseButton", false, tempPanel)
        end

        -- 绑定对话
        self:bindListener("CommunicationButton", self.onCommunicationButton, tempPanel)

        -- 保存数据一些数据
        local iconText = ccui.Text:create()
        iconText:setName("icon")
        local icon = gf:getHeadImgByPolar(v.polor, v.gender)
        iconText:setString(icon)
        iconText:setVisible(false)
        tempPanel:addChild(iconText)

        self.partyRecruitListView:pushBackCustomItem(tempPanel)
    end
end

function PartyMemberDlg:MSG_DIALOG(data)
    if data.ask_type ~= Const.REQUEST_JOIN_PARTY and data.ask_type ~= Const.REQUEST_JOIN_PARTY_REMOTE then
        return
    end

    if data.count > 0 then
        local isInsert = true
        for k, v in pairs(self.applyMembers) do
            if v.gid == data[1].gid then
                isInsert = false
                self.applyMembers[k] = data[1]
            end
        end

        data[1].name = data.peer_name
        if isInsert then
            table.insert(self.applyMembers, data[1])
        end
    else
        self.partyRecruitListView:removeAllItems()
        self.applyStart = 1
        self:setPartyRecruitInfo(self:getApplyMemberList(self.applyStart, 2 * PER_PAGE_COUNT))
    end
end

function PartyMemberDlg:MSG_CHAR_INFO(data)
end

function PartyMemberDlg:MSG_PARTY_QUERY_MEMBER(data)

    if self.isChangeList then
        local tempPanel = self:getControl(data.gid, Const.UIPanel, self.partyMemberListView2)
        local member = data
        local outTimeStr
        if member.logoutTime ~= 0 then
            local year = gf:getServerDate("%Y",member.logoutTime)
            local month = gf:getServerDate("%m",member.logoutTime)
            local date = gf:getServerDate("%d",member.logoutTime)
            outTimeStr = year .. "-" .. month .. "-"  .. date
        else
            outTimeStr = "-"
        end
        self:setLabelText("LoginOutLabel", outTimeStr, tempPanel)
    else
        -- 更新单条数据
        self:updateSingleData(data)
        for i = 1, self.partyMembers.count do
            if self.partyMembers.members[i].gid == data.gid then
                self.partyMembers.members[i].job = data.newJob
            end
        end
    end
end

function PartyMemberDlg:updateSingleData(data)
    local items = self.partyMemberListView1:getItems()
    local item
    local index = -1

    for k, v in pairs(items) do
        if v:getName() == data.gid then
            item = v
            break
        end
    end

    if item then
        index = self.partyMemberListView1:getIndex(item)
    end

    local v = data
    local tempPanel = item
    local partyInfo = PartyMgr:getPartyInfo()

    if index >= 0 then
        -- 更新左边
        local color = COLOR3.GRAY
        if v.online == 1 then
                color = COLOR3.TEXT_DEFAULT
        end

        self:setLabelText("NameLabel", gf:getRealName(v.name), tempPanel, color)
        self:setLabelText("LevelLabel", v.level, tempPanel, color)
        local family = gf:getPolar(v.polor)
        self:setLabelText("FamilyLabel", family, tempPanel, color)

        -- 获取职位名称
        local job = PartyMgr:getJobName(v.job)
        if not job then
            job = v.job
        end

        if partyInfo.heir and v.name == partyInfo.heir then
            job = CHS[3003258]
        end

        -- 是否被禁言
        if self.denyList[v.gid] then
            --self:setCtrlVisible("NoSpeaking", (self.denyList[v.name].hours ~= 0), tempPanel)
            self:setCtrlVisible("NoSpeaking", (self.denyList[v.gid].endTime and gf:getServerTime() <= self.denyList[v.gid].endTime), tempPanel)
        else
            self:setCtrlVisible("NoSpeaking", false, tempPanel)
        end

        -- 帮战次数
        self:setCtrlColor("WarTimesLabel", color, tempPanel)
        self:setCtrlColor("ThisSessionWarTimesLabel", color, tempPanel)

        self:setCtrlColor("TaoLabel", color, tempPanel)

        self:setLabelText("JobLabel", job, tempPanel, color)

        -- 右边
        tempPanel = self.partyMemberListView2:getItem(index)
        if tempPanel then
            local color = COLOR3.GRAY
            if v.online == 1 then
                color = COLOR3.TEXT_DEFAULT
            end

            self:setLabelText("NameLabel", gf:getRealName(v.name), tempPanel, color)
            self:setLabelText("LevelLabel", v.level, tempPanel, color)

            self:setCtrlColor("LoginOutLabel", color, tempPanel)

            -- 加入帮派时间
            local jionTimeColor = COLOR3.GRAY
            if gf:getServerTime() - v.joinTime < ONE_WEEK then
                jionTimeColor = COLOR3.PURPLE
            else
                if v.online == 1 then
                    jionTimeColor = COLOR3.TEXT_DEFAULT
                end
            end

            self:setCtrlColor("JoinPartyTimeLabel", jionTimeColor, tempPanel)

            -- 活力
            self:setCtrlColor("ActiveLabel", color, tempPanel)
            self:setCtrlColor("ThisWeekActiveLabel", color, tempPanel)
            self:setCtrlColor("LastWeekActiveLabel", color, tempPanel)
        end
    end
end

function PartyMemberDlg:MSG_PARTY_CHANNEL_DENY_LIST(data)
    if data.flag == 3 then
        self.denyList = data.speakList
    else
        for gid, v in pairs(data.speakList) do
            self.denyList[gid] = v
        end
    end

    local items = self.partyMemberListView1:getItems()
    for i, item in pairs(items) do
        if item:isVisible() then
            local gid = item:getName()
            local memberData = self:getPartyMemberInfoByGid(gid)
            if not memberData then return end

            local name = memberData.name
            local denyInfo = self.denyList[gid]
            local item2 = self.partyMemberListView2:getItem(i - 1)
            if denyInfo and denyInfo.endTime ~= 0 and gf:getServerTime() <= denyInfo.endTime then
                self:setCtrlVisible("NoSpeaking", true, item)
                self:setCtrlVisible("NoSpeaking", true, item2)
            else
                self:setCtrlVisible("NoSpeaking", false, item)
                self:setCtrlVisible("NoSpeaking", false, item2)
            end
        end
    end
end

function PartyMemberDlg:deepCopy(data1, data2)
    for key, v in pairs(data2) do
        data1[key] = v
    end
end

function PartyMemberDlg:updateSomeMembers(data)
    if not next(self.partyMembers) then return end
    for i = 1, data.count do
        -- 更新本地信息
        local hasNewMember = true
        for j = 1, self.partyMembers.count do
            if data.members[i].gid == self.partyMembers.members[j].gid then
                self:deepCopy(self.partyMembers.members[j], data.members[i])
                hasNewMember = false
            end
        end

        if hasNewMember then
            -- 有新成员
            table.insert(self.partyMembers.members, data.members[i])
            self.partyMembers.count = self.partyMembers.count + 1
        end
    end

    -- 更新在线成员数量
    data.online = 0
    for i = 1, self.partyMembers.count do
        if self.partyMembers.members[i].online == 1 then
            data.online = data.online + 1
        end
    end
end

function PartyMemberDlg:getSortFun(sortType, isCrease)
    -- 默认排序
    local function defaultSort(members)
        table.sort(members, function(l, r)
            if l.name == Me:getName() then return true end
            if r.name == Me:getName() then return false end
            if l.online > r.online then return true end
            if l.online < r.online then return false end
            if self:getJobId(l.job) > self:getJobId(r.job) then return true end
            if self:getJobId(l.job) < self:getJobId(r.job) then return false end
            if l.active > r.active then return true end
            if l.active < r.active then return false end
            if l.level > r.level then return true end
            if l.level < r.level then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 等级降序
    local function levelReduceSort(members)
        table.sort(members, function(l, r)
            if l.level > r.level then return true end
            if l.level < r.level then return false end

            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 等级升序
    local function levelIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.level < r.level then return true end
            if l.level > r.level then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 相性降序
    local function polarReduceSort(members)
        table.sort(members, function(l, r)
            if l.polor > r.polor then return true end
            if l.polor < r.polor then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 相性升序
    local function polarIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.polor < r.polor then return true end
            if l.polor > r.polor then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 职位降序
    local function jobReduceSort(members)
        table.sort(members, function(l, r)
            if self:getJobId(l.job) > self:getJobId(r.job) then return true end
            if self:getJobId(l.job) < self:getJobId(r.job) then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 职位升序
    local function jobIncreaseSort(members)
        table.sort(members, function(l, r)
            if self:getJobId(l.job) < self:getJobId(r.job) then return true end
            if self:getJobId(l.job) > self:getJobId(r.job) then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 活力降序
    local function activeReduceSort(members)
        table.sort(members, function(l, r)
            if l.active > r.active then return true end
            if l.active < r.active then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 活力升序
    local function activeIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.active < r.active then return true end
            if l.active > r.active then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 本周活力降序
    local function thisWeekActiveReduceSort(members)
        table.sort(members, function(l, r)
            if l.thisWeekActive > r.thisWeekActive then return true end
            if l.thisWeekActive < r.thisWeekActive then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 本周活力升序
    local function thisWeekActiveIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.thisWeekActive < r.thisWeekActive then return true end
            if l.thisWeekActive > r.thisWeekActive then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 上周活力降序
    local function lastWeekActiveReduceSort(members)
        table.sort(members, function(l, r)
            if l.lastWeekActive > r.lastWeekActive then return true end
            if l.lastWeekActive < r.lastWeekActive then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 上周活力升序
    local function lastWeekActiveIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.lastWeekActive < r.lastWeekActive then return true end
            if l.lastWeekActive > r.lastWeekActive then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- tao降序
    local function taoReduceSort(members)
        table.sort(members, function(l, r)
            if l.tao > r.tao then return true end
            if l.tao < r.tao then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- tao升序
    local function taoIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.tao < r.tao then return true end
            if l.tao > r.tao then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 帮战次数降序
    local function warTimesReduceSort(members)
        table.sort(members, function(l, r)
            if l.warTimes > r.warTimes then return true end
            if l.warTimes < r.warTimes then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 帮战次数升序
    local function warTimesIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.warTimes < r.warTimes then return true end
            if l.warTimes > r.warTimes then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 本届帮战次数降序
    local function curWarTimesReduceSort(members)
        table.sort(members, function(l, r)
            if l.curWarTimes > r.curWarTimes then return true end
            if l.curWarTimes < r.curWarTimes then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 本届帮战次数升序
    local function curWarTimesIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.curWarTimes < r.curWarTimes then return true end
            if l.curWarTimes > r.curWarTimes then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 离线时间降序
    local function outTimeReduceSort(members)
        table.sort(members, function(l, r)
            if l.logoutTime > r.logoutTime then return true end
            if l.logoutTime < r.logoutTime then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 离线时间升序
    local function outTimeIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.logoutTime < r.logoutTime then return true end
            if l.logoutTime > r.logoutTime then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 入帮时间降序
    local function joinTimeReduceSort(members)
        table.sort(members, function(l, r)
            if l.joinTime > r.joinTime then return true end
            if l.joinTime < r.joinTime then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    -- 入帮时间升序
    local function joinTimeIncreaseSort(members)
        table.sort(members, function(l, r)
            if l.joinTime < r.joinTime then return true end
            if l.joinTime > r.joinTime then return false end
            if l.name < r.name then return true end
            if l.name > r.name then return false end
            return false
        end)
    end

    if sortType == "def" then
        return defaultSort
    elseif sortType == "PolarPanel" then
        if isCrease then
            return polarIncreaseSort
        else
            return polarReduceSort
        end
    elseif sortType == "LevelPanel" then
        if isCrease then
            return levelIncreaseSort
        else
            return levelReduceSort
        end
    elseif sortType == "JobPanel" then
        if isCrease then
            return jobIncreaseSort
        else
            return jobReduceSort
        end
    elseif sortType == "ActivePanel" then
        if isCrease then
            return activeIncreaseSort
        else
            return activeReduceSort
        end
    elseif sortType == "ThisWeekActivePanel" then
        if isCrease then
            return thisWeekActiveIncreaseSort
        else
            return thisWeekActiveReduceSort
        end
    elseif sortType == "LastWeekActivePanel" then
        if isCrease then
            return lastWeekActiveIncreaseSort
        else
            return lastWeekActiveReduceSort
        end
    elseif sortType == "TaoPanel" then
        if isCrease then
            return taoIncreaseSort
        else
            return taoReduceSort
        end
    elseif sortType == "WarTimesPanel" then
        if isCrease then
            return warTimesIncreaseSort
        else
            return warTimesReduceSort
        end
    elseif sortType == "ThisSessionWarTimesPanel" then
        if isCrease then
            return curWarTimesIncreaseSort
        else
            return curWarTimesReduceSort
        end
    elseif sortType == "LoginOutTimePanel" then
        if isCrease then
            return outTimeIncreaseSort
        else
            return outTimeReduceSort
        end
    elseif sortType == "JoinPartyTimePanel" then
        if isCrease then
            return joinTimeIncreaseSort
        else
            return joinTimeReduceSort
        end
    end
    return defaultSort
end

-- 显示箭头
function PartyMemberDlg:showArrowsImg(name)
    -- 显示箭头
    local panel = self:getControl(self.curSortKind, Const.UIPanel, "PartyMemberListPanel_1")
    if panel then
        self:setCtrlVisible("UpImage", self.isIncrease, panel)
        self:setCtrlVisible("DownImage", not self.isIncrease, panel)
    end

    local panel2 = self:getControl(self.curSortKind, Const.UIPanel, "PartyMemberListPanel_2")
    if panel2 then
        self:setCtrlVisible("UpImage", self.isIncrease, panel2)
        self:setCtrlVisible("DownImage", not self.isIncrease, panel2)
    end
end

-- 点击排序
function PartyMemberDlg:onSortKind(sender, eventType)
    if not self.partyMembers then return end
    self.isChangeList = false
    -- 排序类型
    if self.curSortKind == sender:getName() then
        self.isIncrease = not self.isIncrease
    else
        -- 切换排序类型，默认降序
        self.isIncrease = false
    end

    self.curSortKind = sender:getName()

    -- 箭头隐藏
    local memberPanel1 = self:getControl("PartyMemberListPanel_1", Const.UIPanel)
    local memberPanel2 = self:getControl("PartyMemberListPanel_2", Const.UIPanel)
    for _, name in pairs(DISPLAY_KIND) do
        local panel = self:getControl(name, Const.UIPanel, memberPanel1)
        if panel then
            self:setCtrlVisible("UpImage", false, panel)
            self:setCtrlVisible("DownImage", false, panel)
        end

        local panel2 = self:getControl(name, Const.UIPanel, memberPanel2)
        if panel2 then
            self:setCtrlVisible("UpImage", false, panel2)
            self:setCtrlVisible("DownImage", false, panel2)
        end
    end

    -- 显示箭头
    self:showArrowsImg(self.curSortKind)

    -- 重置为第一页
    self.curPage = 1

    local sortFun = self:getSortFun(self.curSortKind, self.isIncrease)
    sortFun(self.showMembers)
    self:showCurPageData()
end

function PartyMemberDlg:MSG_PARTY_MEMBERS(data)
    Client:pushDebugInfo(string.format("%s%s", "MSG_PARTY_MEMBERS-:", inspect(data)))
    if data.tail == 1 then
        if not next(self.partyMembers) then
            return
        end

        -- 更新成员或添加成员
        self:updateSomeMembers(data)
    else
        self.partyMembers = data
    end

    self.curSortKind = self.curSortKind or "def"
    local sortFun = self:getSortFun(self.curSortKind, self.isIncrease)
    sortFun(self.partyMembers.members)

    if self.curSearchStr then
        self.showMembers = self:searchMembers(self.curSearchStr)
    else
        self.showMembers = self.partyMembers.members
    end

    self:showCurPageData()

    self:setLabelText("OnlineValueLabel", data.online, nil, COLOR3.GREEN)
end

function PartyMemberDlg:getApplyMemberList(start, limit)
    if not self.applyMembers then
        return nil
    end

    local retValue = {}
    local count = 1
    for i = start, math.min(start + limit - 1, #(self.applyMembers)) do
        local v = self.applyMembers[i]
        table.insert(retValue, v)
    end

    return retValue
end


function PartyMemberDlg:MSG_CLEAN_ALL_REQUEST(data)
    if data.ask_type ~= Const.REQUEST_JOIN_PARTY and data.ask_type ~= Const.REQUEST_JOIN_PARTY_REMOTE then
        return
    end
    
    self.applyMembers = {}
    self.partyRecruitListView:removeAllItems()
    self.applyStart = 1
    self:setPartyRecruitInfo(self:getApplyMemberList(self.applyStart, 2 * PER_PAGE_COUNT))
end

function PartyMemberDlg:MSG_CLEAN_REQUEST(data)
    if data.ask_type ~= Const.REQUEST_JOIN_PARTY and data.ask_type ~= Const.REQUEST_JOIN_PARTY_REMOTE then
        return
    end

    for i = 1, data.count do
        for pos, member in pairs(self.applyMembers) do
            if member.name == data[i] then
                table.remove(self.applyMembers, pos)
            end
        end
    end

    self.partyRecruitListView:removeAllItems()
    self.applyStart = 1
    self:setPartyRecruitInfo(self:getApplyMemberList(self.applyStart, 2 * PER_PAGE_COUNT))
end

--- 事件处理 ---

function PartyMemberDlg:onSelectMember(sender, eventType)
    local listView = nil
    self.isChangeList = false

    self.chosenImg:removeFromParent()
    sender:addChild(self.chosenImg)

    -- 设置选中数据
    if sender:getName() == Me:queryBasic("gid") then
        return
    end

    local memberData = self:getPartyMemberInfoByGid(sender:getName())
    if not memberData then
        self:showCurPageData()
        return
    end

    local name = memberData.name
    local level = memberData.level
    local icon = gf:getHeadImgByPolar(memberData.polor, memberData.gender)
    local job = memberData.job
    local gid = memberData.gid
    local charData = {name = name, level = level, icon = icon, job = job, gid = gid, online = memberData.online}
    local menu = DlgMgr:openDlg("MemberOperateMenuDlg")
    menu:setInfo(charData)
end

function PartyMemberDlg:getPartyMemberInfoByGid(gid)
    for i = 1, #self.partyMembers.members do
        if self.partyMembers.members[i].gid == gid then
            return self.partyMembers.members[i]
        end
    end
end

function PartyMemberDlg:getJobId(job)
    if job == nil or job == "" then return end
    local pos = gf:findStrByByte(job, ":")
    if pos == 0 then return end
    if not pos then
        local sss
    end

    return tonumber(string.sub(job, pos + 1, -1))
end

function PartyMemberDlg:onPartyTypeCheckBox(sender, eventType, isHasRemovedRed)
    local name = sender:getName()
    if name == "PartyMemberCheckBox" then
        self:onPartyMemberButton(sender, eventType, isHasRemovedRed)
    elseif name == "PartyRecruitCheckBox" then
        self:onPartyRecruitButton(sender, eventType, isHasRemovedRed)
    end
end

function PartyMemberDlg:onPartyMemberButton(sender, eventType)
    self:setCtrlVisible("PartyRecruitPanel", false)
    self:setCtrlVisible("PartyMemberPanel", true)
    self.curInitType = INIT_PANEL_TYPE.INIT_PARTY_MEMBER
end

function PartyMemberDlg:onPartyRecruitButton(sender, eventType, isRedDotRemoved)
    self:setCtrlVisible("PartyRecruitPanel", true)
    self:setCtrlVisible("PartyMemberPanel", false)
    self.curInitType = INIT_PANEL_TYPE.INIT_PARTY_RECRUIT
    PartyMgr:requestList()
    self.isRecruitRedDotRemoved = isRedDotRemoved
end

function PartyMemberDlg:onNextPageButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.isChangeList = true
        local memberPanel1 = self:getControl("PartyMemberListPanel_1", Const.UIPanel)
        local lastPercent = self:getCurScrollPercent("PartyMemberListView", true, memberPanel1)
        self.curIdx = 2

        self:setCtrlVisible("PartyMemberListPanel_2", true)
        self:setCtrlVisible("PartyMemberListPanel_1", false)

        lastPercent = math.min(100, lastPercent)
        lastPercent = math.max(0, lastPercent)

        self.partyMemberListView2:jumpToPercentVertical(lastPercent)
        if self.chosenImg then
            local curNode = self.chosenImg:getParent()
            if curNode then
                local index = curNode:getTag()
                local item = self.partyMemberListView2:getItem(index - 1)
                self.chosenImg:removeFromParent()
                item:addChild(self.chosenImg)
            end
        end
    end
end

function PartyMemberDlg:onLastPageButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self.isChangeList = true
        local memberPanel2 = self:getControl("PartyMemberListPanel_2", Const.UIPanel)

        local lastPercent = self:getCurScrollPercent("PartyMemberListView", true, memberPanel2)
        self.curIdx = 1

        self:setCtrlVisible("PartyMemberListPanel_2", false)
        self:setCtrlVisible("PartyMemberListPanel_1", true)

        lastPercent = math.min(100, lastPercent)
        lastPercent = math.max(0, lastPercent)
        self.partyMemberListView1:jumpToPercentVertical(lastPercent)

        if self.chosenImg then
            local curNode = self.chosenImg:getParent()
            if curNode then
                local index = curNode:getTag()
                local item = self.partyMemberListView1:getItem(index - 1)
                self.chosenImg:removeFromParent()
                item:addChild(self.chosenImg)
            end
        end
    end
end

function PartyMemberDlg:onExitButton(sender, eventType)
    local function exirParty()
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if Me:queryBasic("party/job") == CHS[4000153] then
            gf:ShowSmallTips(CHS[4200042])
            return
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[4200041])
            return
        end

        -- 安全锁判断
        if self:checkSafeLockRelease("onExitButton", sender, eventType) then
            return
        end

        PartyMgr:exitParty()
        self:onCloseButton()
    end

    local tips = string.format(CHS[4000156])
    gf:confirm(tips, exirParty)
end

-- 一键同意事件
function PartyMemberDlg:onAgreeAllButton(sender, eventType)
    PartyMgr:agreeAll()
end

-- 同意
function PartyMemberDlg:onAgreeButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        local tempPanel = sender:getParent()
        local name = tempPanel.memberName
        PartyMgr:agreePlayerParty(name)
    end
end

-- 拒绝
function PartyMemberDlg:onRefuseButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        local tempPanel = sender:getParent()
        local name = tempPanel.memberName
        PartyMgr:refusePlayerParty(name)
    end
end

-- 对话
function PartyMemberDlg:onCommunicationButton(sender, eventType)
    local dlg = FriendMgr:openFriendDlg()
    local tempPanel = sender:getParent()
    local name = tempPanel.memberName -- self:getLabelText("NameLabel", sender:getParent())
    local level = tempPanel.level
    local gid = sender:getParent():getName()
    local icon = self:getLabelText("icon", sender:getParent())
    FriendMgr:communicat(name, gid, icon, level)
    DlgMgr:closeDlg(self.name)
end

function PartyMemberDlg:onConfirmButton(sender, eventType)
    local partyInfo = PartyMgr:getPartyInfo()
    if not partyInfo then return end

    if self.minLevel > self.maxLevel then
        self.minLevel, self.maxLevel = self.maxLevel, self.minLevel
    end

    PartyMgr:refuseByLevel(self.minLevel, self.maxLevel, partyInfo.reject_switch, 0)
    self:setCtrlVisible("LevelSettingPanel", false)
    self:setAutoAcceptLevel(self.minLevel, self.maxLevel)
end

function PartyMemberDlg:onAutoAcceptPanel(sender, eventType)
    local isVisible = self:getCtrlVisible("LevelSettingPanel")
    self:setCtrlVisible("LevelSettingPanel", not isVisible)

    if not isVisible then
        performWithDelay(self.root,function ()
            if not self.minLevel then self.minLevel = PartyMgr:getJoinPartyLevelMin() end
            if not self.maxLevel then self.maxLevel = Const.PLAYER_MAX_LEVEL end
            self:setPositionByIndex("MinListView", self.minLevel - PartyMgr:getJoinPartyLevelMin())
            self:setPositionByIndex("MaxListView", self.maxLevel - PartyMgr:getJoinPartyLevelMin())
        end, 0)
    end
end

function PartyMemberDlg:setPositionByIndex(name, index)
    local list = self:getControl(name)
    local items = list:getItems()
    local realInnerSizeHeight = #items * self.levelPanel:getContentSize().height
    local height = list:getContentSize().height - realInnerSizeHeight
    local y = height + index * self.levelPanel:getContentSize().height
    if y >= 0 then y = 0 end
    list:getInnerContainer():setPositionY(y)
end

-- 接收checkbox
function PartyMemberDlg:onCheckBox(sender, eventType)
    if not self.minLevel or not self.maxLevel then return end

    local limitJoinPartyLevel = PartyMgr:getJoinPartyLevelMin()
    local value = 40
    if value == nil then
        gf:ShowSmallTips(CHS[4000277])
        sender:setSelectedState(false)
        return
    end

    if value < limitJoinPartyLevel then
        value = limitJoinPartyLevel
    elseif value > PartyMgr:getHeroLevelMit() then
        value = PartyMgr:getHeroLevelMit()
    end

    local isWork = 0
    if sender:getSelectedState() then isWork = 1 end

    performWithDelay(self.root, function()
        if self:isCheck("CheckBox") then
            PartyMgr:refuseByLevel(self.minLevel, self.maxLevel, isWork, 1)
        else
            PartyMgr:refuseByLevel(self.minLevel, self.maxLevel, isWork, 1)
        end
    end, 0)
end

function PartyMemberDlg:onPartyListButton(sender, eventType)
    DlgMgr:openDlg("JoinPartyDlg")
end

function PartyMemberDlg:onSendNotifyButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    DlgMgr:openDlg("SendPartyNotifyDlg")
end

-- 清空申请列表
function PartyMemberDlg:onEmptyButton(sender, eventType)
    PartyMgr:refuseAllPlayerParty()
end

-- 刷新按钮
function PartyMemberDlg:onRefreshButton(sender, eventType)
    self.curInitType = INIT_PANEL_TYPE.INIT_PARTY_RECRUIT
    PartyMgr:requestList()
end

function PartyMemberDlg:MSG_MEMBER_NOT_IN_PARTY(data)
    self:showCurPageData()
end

function PartyMemberDlg:MSG_PARTY_INFO(data)
    self:setPartyTitle()
end

return PartyMemberDlg
