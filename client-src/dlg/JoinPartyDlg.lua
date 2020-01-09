-- JoinPartyDlg.lua
-- Created by songcw Mar
-- 加入帮派界面

local JoinPartyDlg = Singleton("JoinPartyDlg", Dialog)

local SELECT_TAG                     = 766                 -- ListView选择TAG
local PER_PAGE_COUNT                 = 12
local PANEL_HEIGHT                   = 50

local PARTY_MAX_COUNT                = 250

local function openPartyInfoDlg()
    DlgMgr:closeDlg("JoinPartyDlg")
    DlgMgr:openDlg('PartyInfoDlg')
end

function JoinPartyDlg:init()
    self:bindEditField("InputPanel", 12, "", "ShowPanel")
    self:bindEditField("InputPanel", 12, "", "OperatePanel")
    self:bindListener("PartyInfoCheckBox", self.onPartyInfoButton)
    self:bindListener("SkillInfoCheckBox", self.onSkillInfoButton)
    self:bindListener("CreatePartyButton", self.onCreatePartyButton)
    self:bindListener("ApplyButton", self.onApplyButton)
    self:bindListener("ApplyAllButton", self.onApplyAllButton)
    self:bindListViewListener("PartyListView", self.onSelectPartyListView)
    self:bindListener("ViewSkillButton", self.onViewSkill, "OperatePanel")
    self:bindListener("ViewSkillButton", self.onViewSkill, "ShowPanel")
    self:bindListener("SearchButton", self.onSearch, "OperatePanel")
    self:bindListener("SearchButton", self.onSearch, "ShowPanel")
    self:bindListener("CleanButton", self.onClean, "OperatePanel")
    self:bindListener("CleanButton", self.onClean, "ShowPanel")

    self:blindLongPress("ScrollView", self.jubaoZhongzhi)

    self.partiesInfo = {}
    self.start = 1
    self.isSearch = false
    self.curParty = nil
    self.lastApplyTimeOfParty = {}

    self.listView = self:getControl("PartyListView", Const.UIListView)
    local size = self.listView:getInnerContainerSize()
    size.height = 1000
    self.listView:setInnerContainerSize(size)

    local infoPanel = self:getControl("InfoPanel")
    self:setCtrlVisible("PartyInfoPanel", true, infoPanel)
    self:setCtrlVisible("SkillInfoPanel", false, infoPanel)
    self:setCtrlVisible("DefaultLabel", false, "OperatePanel")
    self:setCtrlVisible("DefaultLabel", false, "ShowPanel")

    local announcePanel = self:getControl("TenetPanel")
    self:setLabelText("Label", "", announcePanel)

    -- 克隆帮派信息panel
    local partyPanel = self:getControl("OneRowPartyPanel", Const.UIPanel)
    self:setCtrlVisible("ChosenEffectImage", false, partyPanel)
    self:setCtrlVisible("ApplyEffectImage", false, partyPanel)
    self.partyPanel = partyPanel:clone()
    self.partyPanel:retain()
    self:getControl("OneRowPartyPanel"):removeFromParent()

    -- 判断自己有没有帮派，有帮派显示莲花姑娘
    self:checkMyParty()
    self.curPartyPage = 0
    PartyMgr:queryParties(self.curPartyPage)

    self:bindListViewByPageLoad("PartyListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 下拉获取下一页
            local partyList = PartyMgr:getPartyList(self.start, PER_PAGE_COUNT)
            if not partyList then return end
            self:pushData(partyList)
        end
    end)

    -- 置灰
    self:setCtrlEnabled("ApplyButton", false)
    self:setCtrlEnabled("ApplyAllButton", false)
    self:setCtrlEnabled("ViewSkillButton", false, "OperatePanel")
    self:setCtrlEnabled("ViewSkillButton", false, "ShowPanel")
    self:setCtrlEnabled("CreatePartyButton", true)

    self:hookMsg("MSG_CREATE_PARTY_SUCC")
    self:hookMsg("MSG_PARTY_BRIEF_INFO")
    self:hookMsg("MSG_SEND_ICON")
end

function JoinPartyDlg:setSearch(partyList)
    if Me:queryBasic("party/name") ~= "" then
        self:setCtrlVisible("CleanButton", true, "ShowPanel")
        self:setCtrlVisible("SeachButton", false, "ShowPanel")
    else
        self:setCtrlVisible("CleanButton", true, "OperatePanel")
        self:setCtrlVisible("SeachButton", false, "OperatePanel")
    end

    if #partyList == 0 then
        gf:ShowSmallTips(CHS[3002895])
        self:resetListView("PartyListView")
        return
    end

    self.partiesInfo = {}
    self.start = 1
    self:setPartiesList(partyList)
end

-- 长按宗旨
function JoinPartyDlg:jubaoZhongzhi(sender, eventType)
    if not self.curParty then
        return
    end
    sender.partyInfo = self.curParty
    local dlg = BlogMgr:showButtonList(self, sender, "partyAnnouce", self.name)
  --  dlg:setGid(data.gid)
end

function JoinPartyDlg:onSearch(sender, eventType)
    if (not self.newEdits["OperatePanel"]) or (not self.newEdits["ShowPanel"]) then
        return
    end

    local value = self.newEdits["OperatePanel"]:getText()
    if value == "" then
        value = self.newEdits["ShowPanel"]:getText()
    end
    if gf:getTextLength(value) == 0 then
        gf:ShowSmallTips(CHS[3002896])
        return
    end

    if gf:getTextLength(value) > 6 * 2 then
        gf:ShowSmallTips(CHS[4000224])
        return
    end

    if gf:isMeetSearchByGid(value) then
        -- 满足id搜索条件用id搜索
        PartyMgr:queryPartyByNameOrId("fuzzy_by_id", value)
    else
        -- 帮派名称搜索
        PartyMgr:queryPartyByNameOrId("fuzzy_by_name", value)
    end


end

function JoinPartyDlg:onClean(sender, evetType)
    if (not self.newEdits["OperatePanel"]) or (not self.newEdits["ShowPanel"]) then
        return
    end

    self.newEdits["ShowPanel"]:setText("")
    self.newEdits["OperatePanel"]:setText("")

    local parent = sender:getParent()
    self:setCtrlVisible("CleanButton", false, parent)
    self:setCtrlVisible("SeachButton", true, parent)
    self.start = 1
    self.partiesInfo = {}
    self:setPartiesList()
end

function JoinPartyDlg:bindEditField(textFieldName, lenLimit, clenButtonName, root)
    if not self.newEdits then
        self.newEdits = {}
    end

    self.newEdits[root] = self:createEditBox(textFieldName, root, nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newEditString = self.newEdits[root]:getText()
            if gf:getTextLength(newEditString) > lenLimit then
                newEditString = gf:subString(newEditString, lenLimit)
                self.newEdits[root]:setText(newEditString)
                gf:ShowSmallTips(CHS[4000224])
            end
        end
    end)

    self.newEdits[root]:setPlaceHolder(CHS[7001015])
    self.newEdits[root]:setPlaceholderFontColor(COLOR3.GRAY)
    self.newEdits[root]:setPlaceholderFont(CHS[3003597], 21)
    self.newEdits[root]:setFont(CHS[3003597], 21)
    self.newEdits[root]:setFontColor(COLOR3.WHITE)
    self.newEdits[root]:setText("")
end

-- 将json文件默认文字清空
function JoinPartyDlg:dlgCleanup()

    local bangzhuPanel = self:getControl("LeaderPanel")
    self:setLabelText("ContentLabel", "", bangzhuPanel)

    local fubangzhuPanel = self:getControl("DeputyLeaderPanel")
    self:setLabelText("ContentLabel", "", fubangzhuPanel)

    local createrPanel = self:getControl("CreaterPanel")
    self:setLabelText("ContentLabel", "", createrPanel)

    local createTimePanel = self:getControl("CreateTimePanel")
    self:setLabelText("ContentLabel", "", createTimePanel)
end

function JoinPartyDlg:onViewSkill(sender, eventType)
    if self.curParty and self.curParty.skill then
    local dlg = DlgMgr:openDlg("PartyViewSkillDlg")
    dlg:setPartyInfo(self.curParty)
    end
end

function JoinPartyDlg:cleanup()
    self.lastApplyTimeOfParty = {}

    if self.partyPanel then
        self.partyPanel:release()
        self.partyPanel = nil
    end

    EventDispatcher:removeEventListener('MSG_PARTY_INFO', openPartyInfoDlg)
end

-- 更新滚动条
function JoinPartyDlg:updateSlider(sender, eventType, panel)
    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender
        local sliderCtrl = self:getControl(listViewCtrl.sliderName, Const.UISlider, panel)

        -- 获取ListView内部的Layout，及其ContentSize
        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height
        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)
        sliderCtrl:setPercent(persent)

        -- 设置显示状态，如果滚动的话，就让他显示，在滚动1s之后消失
        local fadeOut = cc.FadeOut:create(1)
        local func = cc.CallFunc:create(function() sliderCtrl:setVisible(false) end)
        local action = cc.Sequence:create(fadeOut, func)
        sliderCtrl:setVisible(true)
        sliderCtrl:setOpacity(100)
        sliderCtrl:stopAllActions()
        sliderCtrl:runAction(action)
    end
end

function JoinPartyDlg:setPartiesList(partyList)
    local PartyListView = self:resetListView("PartyListView")
    PartyListView:removeAllItems()

    if not partyList then
        partyList = PartyMgr:getPartyList(1, PER_PAGE_COUNT)
    end

    if not partyList then return end
    self:pushData(partyList)
end

function JoinPartyDlg:chooseParty(sender, eventType)
    Log:D("JoinPartyDlg:chooseParty")
    local partyListView = self:getControl("PartyListView")
    -- 找上一个选择项，取消选择效果
    local lastPanel = partyListView:getChildByTag(SELECT_TAG)
    if lastPanel ~= nil then
        lastPanel:setTag(0)
        self:setCtrlVisible("ChosenEffectImage", false, lastPanel)
    end

    -- 设置当前选择项的选择效果

    local panel = sender
    if not panel then
        panel = partyListView:getItem(0)
    end
    panel:setTag(SELECT_TAG)
    self:setCtrlVisible("ChosenEffectImage", true, panel)

    -- 申请和一键亮化
    self:setCtrlEnabled("ApplyButton", true)
    self:setCtrlEnabled("ApplyAllButton", true)
    self:setCtrlEnabled("CreatePartyButton", true)

    --[[
    self:setAnnounce(self.partiesInfo[index + 1])
    self:setPartyInfo(self.partiesInfo[index + 1])
    --]]
    --self:setPartySkills(self.partiesInfo[index + 1])
    local id  = self.partiesInfo[panel.index].partyId
    local name = self.partiesInfo[panel.index].partyName
    if self.curParty and self.curParty.partyId == id then
        return
    end

    self.curParty = self.partiesInfo[panel.index]
    if self.curParty and self.curParty.skill then
        self:setCtrlEnabled("ViewSkillButton", true, Me:queryBasic("party/name") ~= "" and "ShowPanel" or "OperatePanel")
    else
        self:setCtrlEnabled("ViewSkillButton", false, Me:queryBasic("party/name") ~= "" and "ShowPanel" or "OperatePanel")
    end

    gf:CmdToServer("CMD_QUERY_PARTY", {id = id,
        name = name, type="brief"})
end

function JoinPartyDlg:getSkillByName(name, party)
    for index, skill in pairs(party.skill) do
        if skill.name == name then return skill end
    end

    return nil
end

function JoinPartyDlg:setAnnounce(party)

    local scrollView = self:getControl("ScrollView")
    scrollView:removeAllChildren()
    local panel = ccui.Layout:create()
    panel:setContentSize(scrollView:getContentSize())
    scrollView:addChild(panel)
    local panelHeight = self:setColorText(party.annouce, panel, nil, nil, nil, nil, 19)
    scrollView:setInnerContainerSize(cc.size(scrollView:getContentSize().width, panelHeight))
    local px, py = panel:getPosition()
    panel:setPosition(px, math.max(0, scrollView:getContentSize().height - panelHeight))

end

-- 设置帮派图标
function JoinPartyDlg:setPartyIcon(partyIcon)
    if self.curPartyIcon ~= partyIcon then
        return
    end

    local iconPanel = self:getControl("SelectedIconPanel")

    if string.isNilOrEmpty(partyIcon) then
        -- 没有帮派图标
        self:setCtrlVisible("Image_210", false, iconPanel)
    else
        -- 有帮派图标
        local isCustomIcon = false
        local iconPath = ResMgr:getPartyIconPath(partyIcon)
        if not gf:isFileExist(iconPath) then
            -- 自定义图标
            iconPath = ResMgr:getCustomPartyIconPath(partyIcon)
            isCustomIcon = true
        end

        if not gf:isFileExist(iconPath) then
            CharMgr:requestPartyIcon(partyIcon)
            self:setCtrlVisible("Image_210", false, iconPanel)
        else
            self:setImage("Image_210", iconPath, iconPanel)
            if isCustomIcon then
                local img = self:getControl("Image_210", nil, iconPanel)
                if img then
                    img:ignoreContentAdaptWithSize(true)
                end
            else
                self:setItemImageSize("Image_210", iconPanel)
            end

            self:setCtrlVisible("Image_210", true, iconPanel)
        end
    end
end

function JoinPartyDlg:setPartyInfo(party)

    local bangzhu = self:getNameByJob(party, CHS[3002897])
    local fubangzhu = self:getNameByJob(party, CHS[3002898])

    self.curPartyIcon = party.partyIcon
    self:setPartyIcon(party.partyIcon)

    local bangzhuPanel = self:getControl("LeaderPanel")
    self:setLabelText("ContentLabel", bangzhu, bangzhuPanel)

    local fubangzhuPanel = self:getControl("DeputyLeaderPanel")
    self:setLabelText("ContentLabel", fubangzhu, fubangzhuPanel)

    local moneyStr = gf:getMoneyDesc(party.money, true)
    self:setLabelText("ContentLabel", moneyStr, "MoneyPanel")

    local createrPanel = self:getControl("CreaterPanel")
    self:setLabelText("ContentLabel", party.creator, createrPanel)

    local createTimePanel = self:getControl("CreateTimePanel")
    local year = gf:getServerDate("%Y",party.create_time)
    local month = gf:getServerDate("%m",party.create_time)
    local date = gf:getServerDate("%d",party.create_time)
    self:setLabelText("ContentLabel", year .. "-" .. month .. "-"  .. date, createTimePanel)

    self:setAnnounce(party)
    self.curParty = party

    if party and party.skill then
        self:setCtrlEnabled("ViewSkillButton", true, Me:queryBasic("party/name") ~= "" and "ShowPanel" or "OperatePanel")
    else
        self:setCtrlEnabled("ViewSkillButton", false, Me:queryBasic("party/name") ~= "" and "ShowPanel" or "OperatePanel")
    end
end

function JoinPartyDlg:getNameByJob(party, str)
    for _,v in pairs(party.leader) do
        if v.job == str then
            return v.name
        end
    end

    return CHS[3002899]
end

-- 判断是否有职位，没有将置灰
function JoinPartyDlg:setJob(party, str)
    local panel = self:getControl(str)
    local buttonName = self:getLabelText("TypeLabel", panel)
    self:removeCtrGrayAndTouchEnbel(str, false)
    for _,name in pairs(party.leader) do
        if name.job == buttonName then
            self:setLabelText("ContentLabel", name.name, panel)
            return
        end
    end
    self:setLabelText("ContentLabel", CHS[4000147], panel)
    return false
end

function JoinPartyDlg:getLevelCHS(level)
    return PartyMgr:getCHSLevelAndPeopleMax(level)
end

function JoinPartyDlg:onPartyInfoButton(sender, eventType)
    self:setCheck("SkillInfoCheckBox", false)
    if not self:isCheck("PartyInfoCheckBox") then
        self:setCheck("PartyInfoCheckBox", true)
    end

    local infoPanel = self:getControl("InfoPanel")
    self:setCtrlVisible("PartyInfoPanel", true, infoPanel)
    self:setCtrlVisible("SkillInfoPanel", false, infoPanel)
end

function JoinPartyDlg:onSkillInfoButton(sender, eventType)
    self:setCheck("PartyInfoCheckBox", false)
    if not self:isCheck("SkillInfoPanel") then
        self:setCheck("SkillInfoPanel", true)
    end

    local infoPanel = self:getControl("InfoPanel")
    self:setCtrlVisible("PartyInfoPanel", false, infoPanel)
    self:setCtrlVisible("SkillInfoPanel", true, infoPanel)
end

function JoinPartyDlg:onApplyButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local PartyListView = self:getControl("PartyListView")
    local pos = PartyListView:getCurSelectedIndex()
    if pos < 0 or pos >= PartyListView:getChildrenCount() then
        -- 索引超出,默认为0
        pos = 0
    end

    local panel = PartyListView:getItem(pos)
    if nil == panel then
        -- 判断是否选择了帮派
        gf:ShowSmallTips(CHS[3002900])
        return
    end

    local index = panel.index

    -- 判断等级    CHS[4000148] "至少#R%d#n级方可加入帮派"
    if Me:queryBasicInt("level") < PartyMgr:getJoinPartyLevelMin() then
        gf:ShowSmallTips(string.format(CHS[4000148], PartyMgr:getJoinPartyLevelMin()))
        return
    end

    -- 角色判断         [4000149] = "你已加入帮派",
    if Me:queryBasic("party/name") ~= "" then
        gf:ShowSmallTips(CHS[4000149])
        return
    end

    -- 人数判断         [4000150] = "该帮派人数已满"
    local levelChs, population = self:getLevelCHS(self.partiesInfo[index].partyLevel)
    if self.partiesInfo[index].population >= population then
        gf:ShowSmallTips(CHS[4000150])
        return
    end

    -- 时间CD判断
    local partyId = self.partiesInfo[index].partyId
    if partyId and self.lastApplyTimeOfParty[partyId] ~= nil and gf:getServerTime() - self.lastApplyTimeOfParty[partyId] < 3 then
        -- 无帮派显示申请和创建
        gf:ShowSmallTips(CHS[7000182])
        return
    end

    self:setCtrlVisible("ApplyEffectImage", true, panel)
    PartyMgr:addParties(self.partiesInfo[index].partyName)
    self.lastApplyTimeOfParty[partyId] = gf:getServerTime()
end

function JoinPartyDlg:onApplyAllButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local PartyListView = self:getControl("PartyListView")

    if Me:queryBasic("party/name") ~= "" then
        gf:ShowSmallTips(CHS[4000149])
        return
    end

    -- 时间CD判断
    if self.lastApplyAllTime ~= nil and gf:getServerTime() - self.lastApplyAllTime < 60 then
        -- 无帮派显示申请和创建
        gf:ShowSmallTips(CHS[4000151])
        return
    end

    PartyMgr:addPartiesOneKey()
    --[[
    for index, partyInfo in pairs(self.partiesInfo) do
        local panel = PartyListView:getItem(index)
        self:setCtrlVisible("ApplyEffectImage", true, panel)

        PartyMgr:addParties(self.partiesInfo[index].partyName)
    end
    --]]

    self.lastApplyAllTime = gf:getServerTime()
end

function JoinPartyDlg:onCreatePartyButton(sender, eventType)
    local limitJoinPartyLevel = PartyMgr:getJoinPartyLevelMin()
    if Me:queryBasicInt("level") < limitJoinPartyLevel then
        gf:ShowSmallTips(string.format(CHS[3002901], limitJoinPartyLevel))
        return
    end

    if 1 == Me:queryBasicInt("to_be_deleted") then
        gf:ShowSmallTips(CHS[5000234])
        return
    end

    if Me:queryBasic("party/name") ~= "" then
        -- 无帮派显示申请和创建
        gf:ShowSmallTips(CHS[3002903])
        return
    end

    DlgMgr:openDlg("CreatePartyDlg")
end

function JoinPartyDlg:onSelectPartyListView(sender, eventType)
end

function JoinPartyDlg:onSelectSkillListView(sender, eventType)
end

function JoinPartyDlg:MSG_PARTY_LIST(data)
    -- self.partiesInfo = PartyMgr.partyListInfo
    self:checkMyParty()
    self:setPartiesList()
end

function JoinPartyDlg:MSG_CREATE_PARTY_SUCC(data)

    -- 有帮派显示帮派信息
    EventDispatcher:addEventListener('MSG_PARTY_INFO', openPartyInfoDlg)

    -- 重新请求帮派信息及帮派日志
    PartyMgr:queryPartyInfo()
    PartyMgr:queryPartyLog()
end

function JoinPartyDlg:checkMyParty()
    if Me:queryBasic("party/name") ~= "" then
        self:setCtrlVisible("ShowPanel", true)
        self:setCtrlVisible("OperatePanel", false)
        self:setCtrlVisible("ViewSkillButton", true, "ShowPanel")
    else
        self:setCtrlVisible("ShowPanel", false)
        self:setCtrlVisible("OperatePanel", true)
        self:setCtrlVisible("ViewSkillButton", false, "ShowPanel")
    end
end

function JoinPartyDlg:selectPartyById(partyId)
    local items = self.listView:getItems()
    for i, panel in pairs(items) do
        if self:getLabelText("IDLabel", panel) == gf:getShowId(partyId) then
            self:chooseParty(panel)
        end
    end
end

function JoinPartyDlg:MSG_PARTY_BRIEF_INFO(data)
    self:setPartyInfo(data)
end

function JoinPartyDlg:setPage(page)
    if page then
        self.curPartyPage = page
    else
        self.curPartyPage = self.curPartyPage + 1
    end
end

-- 重新打开对话框设置第page页帮派列表数据
function JoinPartyDlg:setPartyByPage(page)
    self:setPage(page)
    self.partiesInfo = {}
    self:checkMyParty()
    self:setPartiesList()
end

function JoinPartyDlg:pushData(partyList)
    if not partyList or not next(partyList) then
        return
    end
    local PartyListView = self.listView
    self.start = self.start + #partyList
    if self.start > #PartyMgr.partyListInfo - PER_PAGE_COUNT * 2 then
        PartyMgr:queryParties(self.curPartyPage)
    end


    local innerContainer = PartyListView:getInnerContainerSize()
    innerContainer.height = self.start * PANEL_HEIGHT
    PartyListView:setInnerContainerSize(innerContainer)

    if not self.partiesInfo then
        self.partiesInfo = {}
    end

    if #self.listView:getItems() >= PARTY_MAX_COUNT then
        local isRemoveSelect = false
        for i = #partyList, 1 , -1 do
            local size = self.listView:getItem(i - 1):getContentSize()
            self.listView:removeItem(i - 1)
            local contentSize = {width = self.listView:getInnerContainerSize().width, height = self.listView:getInnerContainerSize().height - size.height}
            self.listView:getInnerContainer():setContentSize(contentSize)

            if self.curParty and self.curParty.partyId == self.partiesInfo[i].partyId then
                isRemoveSelect = true
            end
        end

        if isRemoveSelect then
                --self.partiesInfo = partyList
            local item = self.listView:getItem(0)
            self:chooseParty(item, ccui.TouchEventType.ended)
            PartyListView:requestRefreshView()
        end

    end

    for index, partyInfo in pairs(partyList) do
        table.insert(self.partiesInfo, partyInfo)
        local partyPanel = self.partyPanel:clone()

        self:setLabelText("IDLabel", gf:getShowId(partyInfo.partyId), partyPanel)
        self:setLabelText("NameLabel", partyInfo.partyName, partyPanel)
        self:setLabelText("LevelLabel", self:getLevelCHS(partyInfo.partyLevel), partyPanel)

        local constructStr = gf:getMoneyDesc(partyInfo.construct, true)
        self:setLabelText("ConstructionLabel", constructStr, partyPanel)

        -- 人口
        local levelName, num = PartyMgr:getCHSLevelAndPeopleMax(partyInfo.partyLevel)
        self:setLabelText("MemberNumLabel", partyInfo.population .. "/" .. num, partyPanel)

        partyPanel.index = #self.partiesInfo
        if (self.start + index) % 2 == 0 then
            self:setCtrlVisible("BackImage_2", true, partyPanel)
        end

        self:bindTouchEndEventListener(partyPanel, self.chooseParty)
        PartyListView:pushBackCustomItem(partyPanel)
    end

    --self.partiesInfo = partyList
    if not self.curParty then
        local item = self.listView:getItem(0)
        self:chooseParty(item, ccui.TouchEventType.ended)
        PartyListView:requestRefreshView()
    end
end

function JoinPartyDlg:MSG_SEND_ICON(data)
    self:setPartyIcon(data.md5_value)
end

return JoinPartyDlg
