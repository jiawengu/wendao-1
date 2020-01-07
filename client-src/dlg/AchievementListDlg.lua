-- AchievementListDlg.lua
-- Created by songcw Sep/12/2017
-- 成就界面

local AchievementListDlg = Singleton("AchievementListDlg", Dialog)

local BIG_MENU = {
    -- 成就总览                 人物成长                     伙伴培养               装备打造                人物社交                 任务活动             中洲逸事
    CHS[4100797], CHS[4100798], CHS[4100799], CHS[4100800], CHS[4100801], CHS[4100802], CHS[4100803],
}

local SMALL_MENU = {
    -- 人物成长                         等级                              技能                              道行                               战斗                             金钱
    [CHS[4100798]] = {CHS[4100804], CHS[6000164], CHS[4100805], CHS[4100806], CHS[6000080]},

    -- 伙伴培养         宠物养成        守护养成
    [CHS[4100799]] = {CHS[4100807], CHS[4100808]},

    -- 装备打造             装备          首饰          法宝
    [CHS[4100800]] = {CHS[7002314], CHS[7002313], CHS[7000144]},

    -- 人物社交             好友          帮派          人物关系        个人空间
    [CHS[4100801]] = {CHS[7002308], CHS[6000149], CHS[4100809], CHS[7150017]},

    -- 任务活动         剧情任务        日常活动        节日活动        其他活动
    [CHS[4100802]] = {CHS[4100810], CHS[4100811], CHS[4100813]},

    -- 中洲逸事             趣闻          光辉岁月
    [CHS[4100803]] = {CHS[4100814], CHS[4100815]}
}

local FINISH_MAP = {
    [CHS[4100826]] = 1,       -- 全部成就
    [CHS[4100827]] = 2,          -- 已达成成就
    [CHS[4100828]] = 3,     -- 未达成成就
}

-- 分享按钮对应的频道
local CHANNEL_MAP = {
    1, 2, 5, 4, 9
}

function AchievementListDlg:init()
    self:bindListener("RewardButton", self.onRewardButton)
    self:bindListener("ChoseButton", self.onChoseButton)
    self:bindListener("AllButton", self.onSelectAchieveType)
    self:bindListener("CompleteButton", self.onSelectAchieveType)
    self:bindListener("UnfinishButton", self.onSelectAchieveType)
    self:bindListener("ShareButton_1", self.onShareButton_1)


    for i = 1, 5 do
        local bth = self:getControl("ShareButton_" .. i, nil, "TotalShareListPanel")
        bth:setTag(CHANNEL_MAP[i])
        self:bindTouchEndEventListener(bth, self.onShareButton_1)

        local bth = self:getControl("ShareButton_" .. i, nil, "SingleShareListPanel")
        bth:setTag(CHANNEL_MAP[i])
        self:bindTouchEndEventListener(bth, self.onShareButton_1)
    end

    -- 克隆项初始化
    self:initClone()

    -- 悬浮panel
    self:bindFloatPanelListener("TotalShareListPanel")
    self:bindFloatPanelListener("SingleShareListPanel")
    self:bindFloatPanelListener("ChoseListPanel")


    if not self.lastCloseTime then self.lastCloseTime = {} end

    if not self.lastCloseTime[Me:queryBasic("gid")] or gfGetTickCount() - self.lastCloseTime[Me:queryBasic("gid")] > (60 * 2 + 30) * 1000 then
        self.oneMenu = nil
        self.twoMenu = nil
        self.lastCloseTime = {}
    end

    self.selectId = nil
    self.data = nil

    self:initMenu()

    self:hookMsg("MSG_ACHIEVE_VIEW")

    if AchievementMgr.achieveOverViewData then
        self:setData(AchievementMgr.achieveOverViewData)
    end

    RedDotMgr:removeOneRedDot("GameFunctionDlg", "AchievementButton")

    local data = AchievementMgr.achieveOverViewData
    self:setData(data)
end

function AchievementListDlg:initClone()
    -- 菜单克隆项初始化
    self.bigPanel = self:retainCtrl("BigPanel")
    self.selectBigEff = self:retainCtrl("BChosenEffectImage", self.bigPanel)
    self:bindTouchEndEventListener(self.bigPanel, self.onSelectBigMenuButton)

    self.smallPanel = self:retainCtrl("SmallPanel")
    self.selectSmallEff = self:retainCtrl("SChosenEffectImage", self.smallPanel)
    self:bindTouchEndEventListener(self.smallPanel, self.onSelectSmallMenuButton)

    self.unitAchieve = self:retainCtrl("ListPanel_1")
    self:bindTouchEndEventListener(self.unitAchieve, self.onSelectAcheveButton)
    self:bindListener("ShareButton", self.onShareButton, self.unitAchieve)

    self.unitExpandBar = self:retainCtrl("TipPanel_2", nil, "ListPanel_2")
    self.unitExpandTarget = self:retainCtrl("TipPanel_3", nil, "ListPanel_2")
    self.unitExpandReward = self:retainCtrl("TipPanel_4", nil, "ListPanel_2")
    self.unitExpandFinishTime = self:retainCtrl("TipPanel_5", nil, "ListPanel_2")
    self.unitAchieveExpand = self:retainCtrl("ListPanel_2")
end

-- 初始化左侧菜单
function AchievementListDlg:initMenu()
    local list = self:resetListView("CategoryListView")
    list:setBounceEnabled(false)
    for i = 1, #BIG_MENU do
        local btn = self.bigPanel:clone()
        btn:setTag(i * 100)
        btn:setName(BIG_MENU[i])
        self:setLabelText("Label", BIG_MENU[i], btn)
        list:pushBackCustomItem(btn)
        self:setArrow(btn)

        if self.oneMenu == BIG_MENU[i] then
            self:onSelectBigMenuButton(btn)
        end

        if not self.oneMenu then
            self:onSelectBigMenuButton(btn)
        end
    end
end

-- 点击大项菜单
function AchievementListDlg:onSelectBigMenuButton(sender, eventType)
    if self.oneMenu == sender:getName() and sender.isExp then
        -- 先删除所有二级菜单
        self:removeAllSecondMenu()
        return
    end

    if self.oneMenu ~= sender:getName() then
        self.twoMenu = nil
    end

    self.oneMenu = sender:getName()

    -- 增加光效
    self:addEffBigMenu(sender)

    -- 先删除所有二级菜单
    self:removeAllSecondMenu()

    -- 右侧只有两个panel区分显示，成就总览一个，其他一个
    self:setCtrlVisible("TotalPanel", sender:getName() == CHS[4100797])   -- 成就总览
    self:setCtrlVisible("SinglePanel", sender:getName() ~= CHS[4100797])   -- 成就总览

    if not SMALL_MENU[sender:getName()] then

    else

        if self.oneMenu == CHS[4100824] then
            -- 中洲轶事特别，可能存在动态的绝版成就
            -- 请求数据
            if not self.twoMenu then self.twoMenu = CHS[4100814] end
            local key = string.format("%s-%s", self.oneMenu, self.twoMenu)
            local tData = AchievementMgr.achieveData[key]
            if not tData then
                local cType = AchievementMgr.CATEGORY[self.oneMenu]
                AchievementMgr:queryAchieveByCategory(cType)
            else
                -- 二级菜单，增加
                self:addSecondMenu(sender)
            end
        else
            -- 二级菜单，增加
            self:addSecondMenu(sender)

            -- 请求数据
            local key = string.format("%s-%s", self.oneMenu, self.twoMenu)
            local tData = AchievementMgr.achieveData[key]
            if not tData then
                local cType = AchievementMgr.CATEGORY[self.oneMenu]
                AchievementMgr:queryAchieveByCategory(cType)
            end
        end
    end


end

function AchievementListDlg:addEffSmallMenu(sender)
    self.selectSmallEff:removeFromParent()
    sender:addChild(self.selectSmallEff)
end

-- 点击二级菜单
function AchievementListDlg:onSelectSmallMenuButton(sender, eventType)
    -- 增加光效
    self:addEffSmallMenu(sender)

    self.twoMenu = sender:getName()

    self:setTwoData()
end

function AchievementListDlg:setTwoData()
    -- 进度
    local panel = self:getControl("ChosePanel")
    self:setLabelText("NameLabel", self.twoMenu, panel)

    local key = string.format("%s-%s", self.oneMenu, self.twoMenu)
    local data = AchievementMgr.achieveSecondData[key]

    -- 已完成 %d/%d
    self:setLabelText("CompleteLabel", string.format(CHS[4100829], data.task, data.task_max), panel)
    self:setProcessBarByAchievement(data.point or 0, data.point_max, "TotalAchievePanel", panel)

    local fType = FINISH_MAP[self:getLabelText("ChoseLabel", "ChoseButton")]
    local ret = self:getSingleAchieveData(key, fType)

    if ret and next(ret) then
        table.sort(ret, function(l, r)
            if l.order < r.order then return true end
            if l.order > r.order then return false end
        end)
    end

    self:setAchieveList(ret, "ListPanel")
end

-- finishType  1 全部，2已完成， 3未完成
function AchievementListDlg:getSingleAchieveData(key, finishType)
    local tData = AchievementMgr.achieveData[key]
    if not tData then return end
    local finishData = {}
    local notFinishData = {}
    if finishType == 1 then
        return tData
    else
        for _, uData in pairs(tData) do
            if uData.is_finished == 1 then
                table.insert(finishData, uData)
            else
                table.insert(notFinishData, uData)
            end
        end
    end

    if finishType == 2 then
        return finishData
    else
        return notFinishData
    end
end

function AchievementListDlg:cleanup()
    AchievementMgr:clearData()

    if not self.lastCloseTime then self.lastCloseTime = {} end
    self.lastCloseTime[Me:queryBasic("gid")] = gfGetTickCount()
end

function AchievementListDlg:addSecondMenu(sender)
    if not SMALL_MENU[sender:getName()] then return end
    local list = self:getControl("CategoryListView")
    local menuData = gf:deepCopy(SMALL_MENU[sender:getName()])

    if self.isExsitJBCJ and sender:getName() == CHS[4100824] then
        table.insert(menuData, CHS[4100942])
    end


    sender.isExp = true
    self:setArrow(sender)
    for i = 1, #menuData do
        local smallMenu = self.smallPanel:clone()
        self:setLabelText("Label", menuData[i], smallMenu)
        smallMenu:setName(menuData[i])
        list:insertCustomItem(smallMenu, math.floor(sender:getTag() / 100) + i - 1)

        if not self.twoMenu or self.twoMenu == menuData[i] then
            self:onSelectSmallMenuButton(smallMenu)
        end
    end
--    list:requestDoLayout()
--    list:refreshView()
    list:requestRefreshView()
end

-- 收起所有二级菜单
function AchievementListDlg:removeAllSecondMenu()
    local list = self:getControl("CategoryListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel:getTag() % 100 ~= 0 then
            list:removeChild(panel)
        else
            panel.isExp = false
            if not panel.secondMenu or panel.secondMenu.count == 0 then
                self:setArrow(panel)
            else
                self:setArrow(panel)
            end
        end
    end

    list:requestRefreshView()
end

function AchievementListDlg:setArrow(sender)
    if SMALL_MENU[sender:getName()] then
        if sender.isExp then
            self:setCtrlVisible("DownArrowImage", false, sender)
            self:setCtrlVisible("UpArrowImage", true, sender)
        else
            self:setCtrlVisible("DownArrowImage", true, sender)
            self:setCtrlVisible("UpArrowImage", false, sender)
        end
    else
        -- 没有二级菜单
        self:setCtrlVisible("DownArrowImage", false, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
    end
end

-- 增加大项菜单光效光效
function AchievementListDlg:addEffBigMenu(sender)
    self.selectBigEff:removeFromParent()
    sender:addChild(self.selectBigEff)
end

function AchievementListDlg:setProcessBarByAchievement(cur, max, panelName, root)
    local panel = self:getControl(panelName, nil, root)
    self:setProgressBar("ProgressBar", cur, max, panel)

    self:setLabelText("ValueLabel", string.format("%d/%d", cur, max), panel)
    self:setLabelText("ValueLabel_1", string.format("%d/%d", cur, max), panel)
end


-- 成长总览
function AchievementListDlg:setTotalView(data)
    -- 总览
    self:setProcessBarByAchievement(data.total, data.total_max, "TotalAchievePanel", "TotalPanel")
  --
    -- 人物
    local category = AchievementMgr.CATEGORY.AHVE_CG_RWCZ
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "PersonPanel", "TotalPanel")

    -- 伙伴
    category = AchievementMgr.CATEGORY.AHVE_CG_HBPY
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "FriendsPanel", "TotalPanel")

    -- 装备
    category = AchievementMgr.CATEGORY.AHVE_CG_ZBDZ
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "EquipPanel", "TotalPanel")

    -- 人物社交
    category = AchievementMgr.CATEGORY.AHVE_CG_RWSJ
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "SocietyPanel", "TotalPanel")

    -- 任务活动
    category = AchievementMgr.CATEGORY.AHVE_CG_RWHD
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "TaskPanel", "TotalPanel")

    -- 中洲逸事
    category = AchievementMgr.CATEGORY.AHVE_CG_ZZYS
    self:setProcessBarByAchievement(data.category[category].category_total, data.category[category].category_total_max, "AnecdotePanel", "TotalPanel")
    --]]
end

function AchievementListDlg:onRewardButton(sender, eventType)
    if not self.data then return end
    local dlg = DlgMgr:openDlg("AchievementRewardDlg")
    dlg:setData(self.data)
end

function AchievementListDlg:onShareButton(sender, eventType)
    self.selectId = sender:getParent():getParent().data.achieve_id
    if self.oneMenu == CHS[4100797] then
        self:setCtrlVisible("TotalShareListPanel", true)
    else
        self:setCtrlVisible("SingleShareListPanel", true)
    end
end

function AchievementListDlg:onShareButton_1(sender, eventType)
    local achieve = AchievementMgr:getAchieveInfoById(self.selectId)
    local tag = sender:getTag()
    local sendInfo = string.format("{\t%s=%s=%s}", achieve.name, CHS[4100818],  self.selectId)
    local showInfo = string.format(string.format("{\29%s\29}", achieve.name))

    DlgMgr:reorderDlgByName("ChannelDlg")
    if sender:getTag() == CHAT_CHANNEL.FRIEND then
        DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))
        gf:ShowSmallTips(CHS[4100850])

        local copyInfo = string.format("{%s}", achieve.name)
        gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = showInfo, sendInfo = sendInfo})
        return
    end

    sender:getParent():getParent():getParent():setVisible(false)
    DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", tag))

    DlgMgr:sendMsg("ChannelDlg", "setChannelInputChat", tag, "addCardInfo", sendInfo, showInfo)
end

function AchievementListDlg:onChoseButton(sender, eventType)
    self:setCtrlVisible("ChoseListPanel", true)
end

function AchievementListDlg:onSelectAchieveType(sender, eventType)
    local text = self:getLabelText("Label_90", sender)

    self:setLabelText("ChoseLabel", text, "ChoseButton")
    self:setCtrlVisible("ChoseListPanel", false)

    local fType = FINISH_MAP[self:getLabelText("ChoseLabel", "ChoseButton")]
    if text == CHS[4100827] then
        self:setLabelText("Label_66", CHS[5410157], "ListPanel")
    elseif text == CHS[4100828] then
        self:setLabelText("Label_66", CHS[5410158], "ListPanel")
    end

    self:setTwoData()
end

function AchievementListDlg:setAchieveList(data, root)
    local list = self:resetListView("ListView", 5, nil, root)
    if not data or not next(data) then
        self:setCtrlVisible("TipsImage", true, root)
        self:setCtrlVisible("Label_66", true, root)
        return
    end

    self:setCtrlVisible("TipsImage", false, root)
    self:setCtrlVisible("Label_66", false, root)

    for _, unitData in pairs(data) do
        local unitPanel = self.unitAchieve:clone()
        unitPanel:setTag(_ * 100)
        self:setUnitAchievePanel(unitData, unitPanel)
        list:pushBackCustomItem(unitPanel)
    end
end

function AchievementListDlg:setUnitAchievePanel(data, panel)
    local achieve = AchievementMgr:getAchieveInfoById(data.achieve_id)

    self:setLabelText("NameLabel", achieve.name, panel)

    self:setLabelText("DescLabel", string.format(achieve.achieve_desc, achieve.progress), panel)

    self:setImage("GuardImage", AchievementMgr:getIconById(data.achieve_id), panel)

    AchievementMgr:addJBCJImageByCategory(self:getControl("GuardImage", nil, panel), data.category)

    self:setLabelText("AchieveLabel", achieve.point, panel)

    self:setCtrlVisible("CompleteImage", data.is_finished == 1, panel)

    self:setCtrlVisible("RewardImage", achieve.bonus_desc ~= "", panel)

    panel.data = data
    panel.achieve = achieve
end

-- 点击某个成就
function AchievementListDlg:onSelectAcheveButton(sender, eventType)
    if sender.isExpand then
        local list = sender:getParent():getParent()
        local items = list:getItems()
        for _, panel in pairs(items) do
            panel.isExpand = false
            if panel:getTag() % 100 ~= 0 then
                list:removeChild(panel)
            end
        end

   --     list:requestDoLayout()
        list:refreshView()
   --     list:requestRefreshView()
        return
    end

    local list = sender:getParent():getParent()
    local items = list:getItems()
    for _, panel in pairs(items) do
        panel.isExpand = false
        if panel:getTag() % 100 ~= 0 then
            list:removeChild(panel)
        end
    end


    local unitPanel = self.unitAchieveExpand:clone()
    local pos = math.floor(sender:getTag() / 100)
    unitPanel:setTag(sender:getTag() + 1)
    self:setExpandPanel(sender, unitPanel)
    list:insertCustomItem(unitPanel, pos)

    sender.isExpand = true
  --  list:requestDoLayout()
    list:refreshView()
   -- list:requestRefreshView()
end

function AchievementListDlg:setExpandPanel(sender, panel)
    -- 每项49高度，自适应
    local UNIT_HEIGHT = 49
    local panelCount = 0
    local data = sender.data
    local achieve = AchievementMgr:getAchieveInfoById(data.achieve_id)

    -- 计算panel数量
    if string.match(achieve.achieve_desc, "%%d") then
        -- 进度条
        panelCount = panelCount + 1
    end

    if achieve.target_count > 0 then
        -- 多条件成就
        panelCount = panelCount + math.ceil(achieve.target_count / 3)
    end

    if achieve.bonus_desc ~= "" then
        -- 成就奖励
        panelCount = panelCount + 1
    end

    -- 达成时间
    panelCount = panelCount + 1

    -- 设置panel大小
    local sz = panel:getContentSize()
    panel:setContentSize(sz.width, UNIT_HEIGHT * panelCount)
    local bkImage = self:getControl("PanelBKImage", nil, panel)
    bkImage:setContentSize(sz.width, UNIT_HEIGHT * panelCount)

    -- 底板上移，展开控件属于上面一个控件的效果
    bkImage:setPosition(0, 5)

    -- 子控件y坐标
    local startPosY = UNIT_HEIGHT * (panelCount - 1)

    -- 设置进度条
    if string.match(achieve.achieve_desc, "%%d") then
        local barPanel = self.unitExpandBar:clone()
        if data.is_finished == 0 then
            self:setProgressBar("ProgressBar", data.progress_or_time, data.progress, barPanel)
            self:setLabelText("ValueLabel", string.format("%d/%d", data.progress_or_time, data.progress), barPanel)
            self:setLabelText("ValueLabel_1", string.format("%d/%d", data.progress_or_time, data.progress), barPanel)
        else
            self:setProgressBar("ProgressBar", achieve.progress, achieve.progress, barPanel)
            self:setLabelText("ValueLabel", string.format("%d/%d", achieve.progress, achieve.progress), barPanel)
            self:setLabelText("ValueLabel_1", string.format("%d/%d", achieve.progress, achieve.progress), barPanel)
        end

        panel:addChild(barPanel)
        barPanel:setPosition(cc.p(0, startPosY))
        startPosY = startPosY - UNIT_HEIGHT
    end

    -- 复选框
    local targetData = data
    if data.is_finished == 1 then
        -- 成就已完成，服务器不会再发条件数据，所以取配置数据
        targetData = achieve
        for i = 1, targetData.target_count do
            targetData.target_list[i].is_finished = true
        end
    end

    if targetData.target_count > 0 then
        -- 多条件成就
        local row = math.ceil(targetData.target_count / 3)
        for i = 1, row do
            local targetPanel = self.unitExpandTarget:clone()
            for j = 1, 3 do
                local info = targetData.target_list[(i - 1) * 3 + j]
                if info then
                    self:setCtrlVisible("FinishImage" .. j, info.is_finished, targetPanel)

                    if info.is_finished then
                        self:setLabelText("DescLabel_" .. j, info.des, targetPanel, COLOR3.GREEN)
                    else
                        self:setLabelText("DescLabel_" .. j, info.des, targetPanel, COLOR3.GRAY)
                    end
                else
                    --self:setCheck("FinishImage_" .. j, false, targetPanel)
                    self:setCtrlVisible("FinishImage" .. j, false, targetPanel)
                    self:setLabelText("DescLabel_" .. j, info.des, targetPanel, COLOR3.GRAY)
                end
            end

            panel:addChild(targetPanel)
            targetPanel:setPosition(cc.p(0, startPosY))
            startPosY = startPosY - UNIT_HEIGHT
        end
    end

    -- 成就奖励
    if achieve.bonus_desc ~= "" then
        local rewardPanel = self.unitExpandReward:clone()
        local classList = TaskMgr:getRewardList(achieve.bonus_desc)
        local content = string.match(classList[1][1][2], "#r(.+)")
        self:setLabelText("RewardLabel", content, rewardPanel)

        panel:addChild(rewardPanel)
        rewardPanel:setPosition(cc.p(0, startPosY))
        startPosY = startPosY - UNIT_HEIGHT
    end

    -- 达成时间
    local timePanel = self.unitExpandFinishTime:clone()
    if data.is_finished == 0 then
        self:setLabelText("TimeLabel_2", CHS[4100831], timePanel)
    else
        self:setLabelText("TimeLabel_2", os.date("%Y-%m-%d", data.achieve_time or data.progress_or_time), timePanel)
    end

    panel:addChild(timePanel)
    timePanel:setPosition(cc.p(0, startPosY))
    panel:requestDoLayout()
end

function AchievementListDlg:setData(data)
    self.data = data

    self:setTotalView(data)

    self:setLastChieve(data)

    if data.can_bonus == 0 then
        RedDotMgr:removeOneRedDot("AchievementListDlg", "RewardButton")
    end
end

function AchievementListDlg:setLastChieve(data)
    self:setAchieveList(data.last_achieve, "RecentlyPanel")
end



function AchievementListDlg:MSG_ACHIEVE_VIEW(data)
    if not self.oneMenu then return end
    if AchievementMgr.CATEGORY[self.oneMenu] ~= data.category then return end

    if self.oneMenu == CHS[4100824] then
        -- 中洲轶事特别，可能存在动态的绝版成就
        -- 二级菜单，增加
        self.isExsitJBCJ = false
        for i = 1, data.count do
            if AchievementMgr:getAchieveInfoById(data[i].achieve_id).category == AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
                self.isExsitJBCJ = true
            end
        end

        self:addSecondMenu(self:getControl(self.oneMenu))

        -- 请求数据
        local key = string.format("%s-%s", self.oneMenu, self.twoMenu)
        local tData = AchievementMgr.achieveData[key]
        if not tData then
            local cType = AchievementMgr.CATEGORY[self.oneMenu]
            AchievementMgr:queryAchieveByCategory(cType)
        end
    else
        self:setTwoData()
    end
end

return AchievementListDlg
