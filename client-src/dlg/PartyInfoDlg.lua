-- PartyInfoDlg.lua
-- Created by songcw Feb/26/2015
-- 帮派信息界面

local PartyInfoDlg = Singleton("PartyInfoDlg", Dialog)
local TextView = require("ctrl/TextView")

-- 日志项中文本的缩进
local LOG_ITEM_MARGIN_X = 8
local LOG_ITEM_MARGIN_Y = 8

function PartyInfoDlg:init()
    self:bindListener("PartyInfoCheckBox", self.onPartyInfoButton)
    self:bindListener("ConstructionInfoCheckBox", self.onConstructionInfoButton)
    self:bindListener("ModifyButton", self.onModifyButton)
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("GotoButton", self.onGotoButton)
    self:bindListener("LogButton", self.onLogButton)
    self:bindListener("TenetButton", self.onTenetButton)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("EditButton", function(dlg, sender, eventType)
        self:showEditPanel(true)
    end)

    self:blindLongPress("ShowScrollView", self.jubaoZhongzhi)


    self:hookMsg("MSG_UPDATE_APPEARANCE")

    self:bindFloatingEvent("MainInfoPanel")
    self:bindFloatingEvent("BangzhuInfoPanel")
    PartyMgr.log = {}
    PartyMgr.log.dates = {}
    self.start = 1
    self:bindTouchPanel()
    self.lastOffsetY = 0
    -- 显示帮派基本信息
    self:onPartyInfoButton()

    -- 设置帮派宗旨编辑框不可见
    -- self:bindEditField("TenetTextField", PartyMgr.ANNOUNCE_LEN_LIMIT)
    self.tenetTextField = TextView.new(self, "TenetTextFieldPanel", "EditPanel", 21, "ShowScrollView")
    self.tenetTextField:bindListener(function(dlg, sender, event)
        if 'changed' == event then
            local str = self.tenetTextField:getText()
            if gf:getTextLength(str) > PartyMgr.ANNOUNCE_LEN_LIMIT * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            self:setCtrlVisible("DefaultLabel", str == "")
            self.tenetTextField:setText(tostring(gf:subString(str, PartyMgr.ANNOUNCE_LEN_LIMIT * 2) or ""))
        end
    end)

    -- 只有帮主才可以编辑帮派宗旨
    self:setCtrlVisible("ModifyButton", PartyMgr:isPartyLeader())

    -- 帮派信息
    self:setPartyInfo()

    -- 显示帮派宗旨
    self:showEditPanel(false)

    -- 克隆
    local logListView = self:getControl("LogListView", Const.UIListView)
    self.logListView = logListView

    self.timePanel = self:getControl("TimePanel", Const.UIPanel, logListView)
    self.timePanel:retain()
    self.contentPanel = self:getControl("ContentPanel", Const.UIPanel, logListView)
    self.contentPanel:retain()
    self.contentPanel:removeAllChildren()
    self.logListView:removeAllItems()
    local size = self.logListView:getInnerContainerSize()
    size.height = 800
    self.logListView:setInnerContainerSize(size)

    self:getControl("Label_1", nil, "UpgradeButton"):setString(CHS[7000034])
    self:getControl("Label_2", nil, "UpgradeButton"):setString(CHS[7000034])

    if not PartyMgr:getPartyInfo() then
        PartyMgr:queryPartyInfo()
    end
end

function PartyInfoDlg:showEditPanel(isShow)
    if isShow then
        self:setCtrlVisible("ShowPanel", false)
        self:setCtrlVisible("SelectButton", true)
        self:setCtrlVisible("EditPanel", true)
        self:setCtrlVisible("EditButton", false)
--        local fieldCtrl = self:getControl("TenetTextField")
--        fieldCtrl:setEnabled(true)
--        fieldCtrl:attachWithIME()
        self:setCtrlVisible("DefaultLabel", self.tenetTextField:getText() == "" and Me:queryBasic("party/job") == CHS[3003250])
        self.tenetTextField:openKeyboard()
    else
        self:setCtrlVisible("ShowPanel", true)
        self:setCtrlVisible("SelectButton", false)
        self:setCtrlVisible("EditPanel", false)
--        local fieldCtrl = self:getControl("TenetTextField")
        self:setCtrlVisible("DefaultLabel", self.tenetTextField:getText() == "" and Me:queryBasic("party/job") == CHS[3003250])
        if Me:queryBasic("party/job") == CHS[3003250] then
            self:setCtrlVisible("EditButton", true)
        else
            self:setCtrlVisible("EditButton", false)

        end
    end
end

function PartyInfoDlg:cleanup()
    self:releaseCloneCtrl("timePanel")
    self:releaseCloneCtrl("contentPanel")

    PartyMgr.log = {}
    PartyMgr.log.dates = {}
end

-- 更新滚动条
function PartyInfoDlg:updateSlider(sender, eventType)
end

-- 设置帮派信息
function PartyInfoDlg:setPartyInfo()
    self.partyInfo = PartyMgr:getPartyInfo()

    local partyName = ""
    local partyLeader = ""
    local partyLevel = ""
    local memberNum = ""
    local creator = ""
    local createTime = ""
    local inheritor = ""
    local partyMoney = ""
    local partyMoneyColor = COLOR3.WHITE
    local partyMoneyDayCost = ""
    local construct = ""
    local constructColor = COLOR3.WHITE
    local constructDayCost = ""
    local partySalary = ""
    local populationMax = ""
    local partyAnnounce = ""
    local partyID = ""
    local onlineCount = ""
    local populationCount = ""
    if self.partyInfo then
        local info = self.partyInfo
        partyName = info.partyName
        partyLeader = PartyMgr:getPartyMemberByJob(CHS[3003250])
        partyLevel, populationMax = self:getLevelCHS(info.partyLevel)
        populationCount = info.population
        onlineCount = info.onLineCount or ""
        creator = info.creator

        local year = gf:getServerDate("%Y",info.createTime)
        local month = gf:getServerDate("%m",info.createTime)
        local date = gf:getServerDate("%d",info.createTime)
        createTime = year .. "-" .. month .. "-"  .. date

        inheritor = info.heir

        partyMoney = gf:getMoneyDesc(info.money, true)
        partyMoneyColor = PartyMgr:getMoneyColor()
        partyMoneyDayCost = gf:getMoneyDesc(PartyMgr:getDayCastMoney(), true)

        construct = gf:getMoneyDesc(info.construct, true)
        constructColor = PartyMgr:getContsructionColor()
        constructDayCost = gf:getMoneyDesc(PartyMgr:getDayCastConstru(), true)

        partySalary = gf:getMoneyDesc(info.salary, true)

        partyAnnounce = info.partyAnnounce
        partyID = self.partyInfo.partyId
    end

    self:setLabelText("TitleLabel1", partyName)
    self:setLabelText("TitleLabel2", partyName)

    local partyInfoPanel = self:getControl("PartyInfoPanel")

    -- 帮派名称
    self:setLabelByNamePanel("ContentLabel", partyName, "NamePanel", partyInfoPanel)

    -- 帮派GID

    -- 帮主
    self:setLabelByNamePanel("ContentLabel", partyLeader, "LeaderPanel", partyInfoPanel)

    -- 级别
    self:setLabelByNamePanel("ContentLabel", partyLevel, "LevelPanel", partyInfoPanel)

    -- id
    self:setLabelText("IDLabel", CHS[3003251] .. gf:getShowId(partyID))

    -- 人数
  --  self:setLabelByNamePanel("ContentLabel", memberNum, "MemberNumPanel", partyInfoPanel)
    self:setLabelText("OnlineLabel", onlineCount, "MemberNumPanel", COLOR3.GREEN)
    self:setLabelText("TotalLabel", populationCount, "MemberNumPanel", COLOR3.WHITE)
    self:setLabelText("PMaxLabel", populationMax, "MemberNumPanel", COLOR3.GRAY)

    -- 创建者
    self:setLabelByNamePanel("ContentLabel", creator, "CreaterPanel", partyInfoPanel)

    -- 创建时间
    self:setLabelByNamePanel("ContentLabel", createTime, "CreateTimePanel", partyInfoPanel)

    -- 继承人
    self:setLabelByNamePanel("ContentLabel", inheritor, "HeirPanel", partyInfoPanel)
    self:setCtrlVisible("HeirPanel", inheritor ~= "")

    -- 建设信息
    local constructionInfoPanel = self:getControl("ConstructionInfoPanel")

    -- 帮派资金
    self:setLabelByNamePanel("ContentLabel", partyMoney, "MoneyPanel", constructionInfoPanel, partyMoneyColor)

    -- 日耗资金
    self:setLabelByNamePanel("ContentLabel", partyMoneyDayCost, "DailyCostMoneyPanel", constructionInfoPanel)

    -- 建设度
    self:setLabelByNamePanel("ContentLabel", construct, "ConstructionPanel", constructionInfoPanel, constructColor)

    -- 日耗建设度
    self:setLabelByNamePanel("ContentLabel", constructDayCost, "DailyCostConstructionPanel", constructionInfoPanel)

    -- 帮派俸禄
    self:setLabelByNamePanel("ContentLabel", partySalary, "SalaryPanel", constructionInfoPanel)

    -- 帮派宣言
    -- self:setInputText("TenetTextField", partyAnnounce)
    self.tenetTextField:setText(partyAnnounce)
    self:showPartyAnnounce(partyAnnounce)

    self:updateLayout("MemberNumPanel", partyInfoPanel)
end

function PartyInfoDlg:showPartyAnnounce(str)
    local showPanel = self:getControl("ShowPanel")
    Dialog.setColorText(self, str, "TenetShowPanel", nil, nil, nil, self.fontColor, fontSize)
    local scrollView = self:getControl("ShowScrollView", nil, showPanel)
    if scrollView then
        local panel = self:getControl("TenetShowPanel", nil, showPanel)
        local panelSize = panel:getContentSize()
        scrollView:setInnerContainerSize(panelSize)
        if panelSize.height < scrollView:getContentSize().height then
            panel:setPositionY(scrollView:getContentSize().height - panelSize.height)
        else
            panel:setPositionY(0)
        end
    end
end

function PartyInfoDlg:setLabelByNamePanel(name, str, panelName, root, color)
    local panel = self:getControl(panelName, nil, root)
    if panel == nil then return end

    self:setLabelText(name, str, panel, color)
end

function PartyInfoDlg:getLevelCHS(level)
    return PartyMgr:getCHSLevelAndPeopleMax(level)
end

-- 显示基础信息
function PartyInfoDlg:onPartyInfoButton(sender, eventType)
    self:setCheck("ConstructionInfoCheckBox", false)
    if not self:isCheck("PartyInfoCheckBox") then
        self:setCheck("PartyInfoCheckBox", true)
    end

    self:setCtrlVisible("PartyInfoPanel", true)
    self:setCtrlVisible("ConstructionInfoPanel", false)
end

-- 显示建设信息
function PartyInfoDlg:onConstructionInfoButton(sender, eventType)
    self:setCheck("PartyInfoCheckBox", false)
    if not self:isCheck("ConstructionInfoCheckBox") then
        self:setCheck("ConstructionInfoCheckBox", true)
    end

    self:setCtrlVisible("PartyInfoPanel", false)
    self:setCtrlVisible("ConstructionInfoPanel", true)
end

function PartyInfoDlg:onModifyButton(sender, eventType)
    self:setCtrlVisible("EditPanel", true)
    self:setCtrlVisible("ShowPanel", false)
--    local fieldCtrl = self:getControl("TenetTextField")
--    fieldCtrl:setEnabled(true)
--    fieldCtrl:attachWithIME()
end

function PartyInfoDlg:onSelectButton(sender, eventType)
    local textField = self:getControl("TenetTextField")
    local str = self.tenetTextField:getText()
    local showPanel = self:getControl('ShowPanel')
    -- local rawStr = self:getLabelText('TenetLabel', showPanel)
    local rawStr = Dialog.getColorText(self, "TenetShowPanel", showPanel)

    if str ~= rawStr then
        -- 有变化时才修改
        str = gf:filtText(str)
        -- self:setLabelText('TenetLabel', str, showPanel)
        self:showPartyAnnounce(str)
        PartyMgr:setAnnouce(str)
    end

    textField:setEnabled(false)
    self:showEditPanel(false)
end

-- 回到总坛
function PartyInfoDlg:onGotoButton(sender, eventType)
    PartyMgr:flyToParty()
    self:onCloseButton()
end

-- 长按宗旨
function PartyInfoDlg:jubaoZhongzhi(sender, eventType)

    sender.partyInfo = self.partyInfo
    BlogMgr:showButtonList(self, sender, "partyAnnouce", self.name)

end


-- 帮派日志
function PartyInfoDlg:onLogButton(sender, eventType)

    self:setCtrlVisible("TenetPanel", false)
    self:setCtrlVisible("LogPanel", true)
    self:setCtrlVisible("TenetButton", true)
    self:setCtrlVisible("LogButton", false)


    self:setCtrlVisible("DefaultLabel", false)

    PartyMgr:queryPartyLog(self.start, PartyMgr.PER_PAGE_COUNT * 2)
end

-- 帮派宗旨
function PartyInfoDlg:onTenetButton(sender, eventType)
    --[[
    self:setCtrlVisible("TenetPanel", true)
    self:setCtrlVisible("LogPanel", false)
    self:setCtrlVisible("TenetButton", false)
    self:setCtrlVisible("SelectButton", true)
    self:setCtrlVisible("LogButton", true)
    self:setCtrlVisible("EditPanel", true)
    self:setCtrlVisible("showPanel", false)
    --]]
    self:setCtrlVisible("TenetPanel", true)
    self:setCtrlVisible("LogPanel", false)
    self:setCtrlVisible("LogButton", true)
    self:setCtrlVisible("TenetButton", false)

--    local fieldCtrl = self:getControl("TenetTextField")
    self:setCtrlVisible("DefaultLabel", self.tenetTextField:getText() == "" and Me:queryBasic("party/job") == CHS[3003250])
end

-- 帮派升级按钮
function PartyInfoDlg:onUpgradeButton(sender, eventType)
    -- gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LEVEL_UP_PARTY)
    DlgMgr:openDlg("PartyManageDlg")
end

-- 帮派升级提示按钮
function PartyInfoDlg:onNoteButton(sender, eventType)
    --[[
    local tips = CHS[3003252] .. gf:getMoneyDesc(100000)
            .. CHS[3003253]
            .. gf:getMoneyDesc(350000) .. CHS[3003254]
    tips = tips .. CHS[3003252] .. gf:getMoneyDesc(500000)
            .. CHS[3003255]
            .. gf:getMoneyDesc(750000) .. CHS[3003254]
    tips = tips .. CHS[3003252] .. gf:getMoneyDesc(1000000)
        .. CHS[3003256]
        .. gf:getMoneyDesc(1500000) .. CHS[3003257]

    gf:showTipInfo(tips, sender)
    --]]
    if PartyMgr:isPartyLeader() then
        self:setCtrlVisible("BangzhuInfoPanel", true)
    else
        self:setCtrlVisible("MainInfoPanel", true)
    end
end

function PartyInfoDlg:refreshPartyInfo(partyInfo)
    self.partyInfo = partyInfo

    -- 帮派信息
    self:setPartyInfo()
end

-- 设置帮派信息
function PartyInfoDlg:setPartyLog(start, limit, isClear)

    if isClear then
        self.logListView:removeAllItems()
        self.start = 1
    end

    start = start or 1
    limit = limit or PartyMgr.PER_PAGE_COUNT * 2

    if self.start > start then return end
    self.logListView:removeAllItems()

    self.log = PartyMgr:getPartyLog(start, limit)
    if not self.log or not next(self.log) then
        return
    end

    if not self.timePanel or not self.contentPanel then
        return
    end

    local lastIndex = 0

    if self.start > 1 then
        lastIndex = self.start
    end

    local innerContainer = self.logListView:getInnerContainerSize()
    innerContainer.height = self.start * 60
    self.logListView:setInnerContainerSize(innerContainer)
    for i = 1, #self.log.dates do
        local k = self.log.dates[i]
        local v = self.log[k]

        if v then
            if not self:getItemByText(k) then
                local item = self.timePanel:clone()
                self:setLabelText('TimeLabel', k, item)
                self.logListView:pushBackCustomItem(item)
            end

            for index, log in pairs(v) do
                local item = self.contentPanel:clone()
                self:setColorText(log, item)
                self.logListView:pushBackCustomItem(item)
            end
        end
    end

    self:setListViewTop("LogListView")


 end

function PartyInfoDlg:getNextOffsetY(start)
    local items = self.logListView:getItems()
    local timePanelCount = 0
    local normalPanelCount = 0
    local index = 0
    local offsetY = 0

    for k, v in pairs(items) do
        --[[
        if v:getName() == "TimePanel" then
            timePanelCount = timePanelCount + 1
        elseif v:getName() == "ContentPanel" then
            normalPanelCount = normalPanelCount + 1
        end
        --]]
        if v:getName() ~= "TimePanel" then
            index = index + 1
        end
        if index > start then break end
        offsetY = offsetY + v:getContentSize().height
    end

    return offsetY
end

function PartyInfoDlg:jumpToItem(offsetY)
    local contentSize = self.logListView:getContentSize()
    local innerContainer = self.logListView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height;
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end
    local x,y = innerContainer:getPosition()
    local pos = cc.p(x, offsetY)
    innerContainer:setPosition(pos)
end

function PartyInfoDlg:getLogCount(log)
    local i = 0
    for k, v in pairs(log) do
        if k ~= "dates" then
            for index, value in pairs(v) do
                i = i + 1
            end
        end
    end

    return i
end

function PartyInfoDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        local percent = self:getCurScrollPercent("LogListView", true)
        Log:D("The percent is %d%%", percent)

        if percent > 100 then
            -- 加载下一页
            self.start = self.start + PartyMgr.PER_PAGE_COUNT * 2
            PartyMgr:queryPartyLog(self.start, PartyMgr.PER_PAGE_COUNT * 2)
        elseif percent <= 0 and self.start > 1 and self.logListView:getInnerContainer():getPositionY() < 0 then
            -- 加载上一页
            self.start = self.start - PartyMgr.PER_PAGE_COUNT * 2
            if self.start < 1 then self.start = 1 end
            PartyMgr:queryPartyLog(self.start, PartyMgr.PER_PAGE_COUNT * 2)
        end

        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

end

function PartyInfoDlg:getItemByText(str)
    local items = self.logListView:getItems()

    for k, v in pairs(items) do
        local text = self:getLabelText("TimeLabel", v)
        if str == text then
            return v
        end
    end

    return
end

-- 显示字符串
function PartyInfoDlg:setColorText(str, panel)
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width - 2 * LOG_ITEM_MARGIN_X, 0)
    textCtrl:setDefaultColor(86, 41, 2)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(LOG_ITEM_MARGIN_X, textH + LOG_ITEM_MARGIN_Y)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    local panelHeight = textH + 2 * LOG_ITEM_MARGIN_Y
    panel:setContentSize(size.width, panelHeight)
    return panelHeight
end

-- 更新帮派名称
function PartyInfoDlg:MSG_UPDATE_APPEARANCE(data)
    if data.id == Me:getId() and data["party/name"] then
        PartyMgr:updataPartyName(data["party/name"])
    end
end

return PartyInfoDlg
