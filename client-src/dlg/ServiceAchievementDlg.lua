-- ServiceAchievementDlg.lua
-- Created by songcw Jan/29/2018
-- 首杀

local ServiceAchievementDlg = Singleton("ServiceAchievementDlg", Dialog)

-- 左侧菜单大类别
local BIG_MENU = {
    CHS[7002146], CHS[4100959], CHS[4010189]
}

local SMALL_MENU = {
    [CHS[7002146]] = {CHS[4300156], CHS[4300157], CHS[7002094], CHS[7002306]},

    [CHS[4010189]] = {CHS[4010190], CHS[4010191], CHS[4010192]},
}

-- 奖励图标
local REWARD_ICON = {
    [CHS[4300156]] = {[1] = {portrait = ResMgr.ui.samll_common_pet, reward = CHS[4300335], testReward = CHS[6000502], testPortrait = ResMgr.ui.samll_common_pet}},      -- 黑熊妖皇
    [CHS[4300157]] = {[1] = {portrait = ResMgr.ui.samll_common_pet, reward = CHS[6000521], testReward = CHS[6000502], testPortrait = ResMgr.ui.samll_common_pet}},      -- 血炼魔猪
    [CHS[7002094]] = {[1] = {portrait = ResMgr.ui.samll_common_pet, reward = CHS[6000521], testReward = CHS[6000502], testPortrait = ResMgr.ui.samll_common_pet}},      -- 赤血鬼猿
    [CHS[7002306]] = {[1] = {portrait = ResMgr.ui.samll_common_pet, reward = CHS[6000521], testReward = CHS[6000502], testPortrait = ResMgr.ui.samll_common_pet}},      -- 魅影蝎后
    [CHS[4100959]] = {[1] = {itemName = CHS[4000268], testItemName = CHS[4000268], reward = CHS[4400035]}, [2] = {itemName = CHS[5420044], testItemName = CHS[5420044], reward = CHS[4400036]}},
    [CHS[4010190]] = {[1] = {itemName = CHS[4000268], testItemName = CHS[4000268], reward = CHS[4010193]}, [2] = {itemName = CHS[5420044], testItemName = CHS[5420044], reward = "召唤令·上古神兽 × 10"}},
    [CHS[4010191]] = {[1] = {itemName = CHS[4000268], testItemName = CHS[4000268], reward = CHS[4010194]}, [2] = {itemName = CHS[5420044], testItemName = CHS[5420044], reward = "召唤令·上古神兽 × 10"}},
    [CHS[4010192]] = {[1] = {itemName = CHS[4000268], testItemName = CHS[4000268], reward = CHS[4010195]}, [2] = {itemName = CHS[5420044], testItemName = CHS[5420044], reward = "召唤令·上古神兽 × 15"}},
}

local BOSS_SHAPE_INFO = {
    [CHS[4300156]] = {icon = 06600, reward = CHS[4300335], testReward = CHS[6000502], nameIcon = ResMgr.ui.super_boss_word1, bannerStr = ResMgr.ui.banner_hxyh},      -- 黑熊妖皇
    [CHS[4300157]] = {icon = 06603, reward = CHS[6000521], testReward = CHS[6000502], nameIcon = ResMgr.ui.super_boss_word2, bannerStr = ResMgr.ui.banner_xlmz},      -- 血炼魔猪
    [CHS[7002094]] = {icon = 06604, reward = CHS[6000521], testReward = CHS[6000502], nameIcon = ResMgr.ui.super_boss_word3, bannerStr = ResMgr.ui.banner_cxgy},      -- 赤血鬼猿
    [CHS[7002306]] = {icon = 06605, reward = CHS[6000521], testReward = CHS[6000502], nameIcon = ResMgr.ui.super_boss_word4, bannerStr = ResMgr.ui.banner_myxh},      -- 魅影蝎后
    [CHS[4100959]] = {icon = 20063, reward = CHS[4300336], testReward = CHS[4300336], bannerStr = ResMgr.ui.banner_qsmj, nameIcon = ResMgr.ui.qisha_boss},

    [CHS[4010190]] = {icon = 06413, reward = CHS[4010196], bannerStr = ResMgr.ui.jiutian_ztj, nameIcon = ResMgr.ui.jiut_boss_zhu},
    [CHS[4010191]] = {icon = 06414, reward = CHS[4010197], bannerStr = ResMgr.ui.jiutian_ctj, nameIcon = ResMgr.ui.jiut_boss_cheng},
    [CHS[4010192]] = {icon = 06415, reward = CHS[4010198], bannerStr = ResMgr.ui.jiutian_ytj, nameIcon = ResMgr.ui.jiut_boss_you},
}

function ServiceAchievementDlg:init()
    self:bindListener("Button_284", self.onButton_284)
    self:bindListener("CommentButton", self.onCommentButton)  -- 点评
  --  self:bindListViewListener("CategoryListView", self.onSelectCategoryListView)

    -- 菜单克隆项初始化
    self.bigPanel = self:retainCtrl("BigPanel")
    self.selectBigEff = self:retainCtrl("BChosenEffectImage", self.bigPanel)
    self:bindTouchEndEventListener(self.bigPanel, self.onSelectBigMenuButton)

    self.smallPanel = self:retainCtrl("SmallPanel")
    self.selectSmallEff = self:retainCtrl("SChosenEffectImage", self.smallPanel)
    self:bindTouchEndEventListener(self.smallPanel, self.onSelectSmallMenuButton)

    self:bindFloatPanelListener("ShowPanel_1")
    self:bindFloatPanelListener("ShowPanel_2")

    if not self.lastCloseTime then self.lastCloseTime = {} end

    if not self.lastCloseTime[Me:queryBasic("gid")] or gfGetTickCount() - self.lastCloseTime[Me:queryBasic("gid")] > (60 * 2 + 30) * 1000 then
        self.oneMenu = nil
        self.twoMenu = nil
        self.lastCloseTime = {}
    end

    self:initMenu()

    self:hookMsg("MSG_SUPER_BOSS_KILL_FIRST")
    self:hookMsg("MSG_QISHA_SHILIAN_KILL_FIRST")
end

-- 点评
function ServiceAchievementDlg:onCommentButton(sender)
    local data
    local type
    if self.oneMenu == CHS[4100959] and BOSS_SHAPE_INFO[self.oneMenu] then
        data = {name = CHS[5410260], icon = BOSS_SHAPE_INFO[self.oneMenu].icon}
        type = "qisha_shilian"
    elseif self.oneMenu == CHS[7002146] and self.twoMenu and BOSS_SHAPE_INFO[self.twoMenu] then
        data = {name = self.twoMenu, icon = BOSS_SHAPE_INFO[self.twoMenu].icon}
        type = "boss"
    elseif self.oneMenu == CHS[4010189] and self.twoMenu and BOSS_SHAPE_INFO[self.twoMenu] then
        data = {name = self.twoMenu, icon = BOSS_SHAPE_INFO[self.twoMenu].icon}
        type = "jiutian"
    end

    if data then
        local dlg = DlgMgr:openDlg("BookCommentDlg")
        dlg:setCommentObj(data, type)
    end
end

function ServiceAchievementDlg:cleanup()

    if not self.lastCloseTime then self.lastCloseTime = {} end
    self.lastCloseTime[Me:queryBasic("gid")] = gfGetTickCount()
end

-- 初始化左侧菜单
function ServiceAchievementDlg:initMenu()
    local list = self:resetListView("CategoryListView")
  --  self.oneMenu = nil
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

function ServiceAchievementDlg:addEffSmallMenu(sender)
    self.selectSmallEff:removeFromParent()
    sender:addChild(self.selectSmallEff)
end

-- 点击二级菜单
function ServiceAchievementDlg:onSelectSmallMenuButton(sender, eventType)
    -- 增加光效
    self:addEffSmallMenu(sender)

    self.twoMenu = sender:getName()



    if self.oneMenu == CHS[7002146] then
        -- 超级大BOSS
        local data = AchievementMgr:getSuperBossFB()
        if data and next(data) then
            self:setBossInfo(data[self.twoMenu], self.twoMenu)
        else
            self:setBossInfo(nil, self.twoMenu)
        end
    elseif self.oneMenu == CHS[4010189]then
        local data = AchievementMgr:getJiuTianFB()
        if data and next(data) then
            self:setBossInfo(data[self.twoMenu], self.twoMenu)
        else
            self:setBossInfo(nil, self.twoMenu)
        end
    end
 --   self:setTwoData()
end

-- 点击大项菜单
function ServiceAchievementDlg:onSelectBigMenuButton(sender, eventType)
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

    if not SMALL_MENU[sender:getName()] then
        local data = AchievementMgr:getQiShaFB()
        if data and data.count == 1 then
            local retData = gf:deepCopy(data)
            retData.boss_name = CHS[4100959]
            self:setBossInfo(retData)
        else
            self:setBossInfo(nil, CHS[4100959])
        end
    else
        -- 二级菜单，增加
        self:addSecondMenu(sender)
    end
end

-- 收起所有二级菜单
function ServiceAchievementDlg:removeAllSecondMenu()
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

-- 增加大项菜单光效光效
function ServiceAchievementDlg:addEffBigMenu(sender)
    self.selectBigEff:removeFromParent()
    sender:addChild(self.selectBigEff)
end

-- 显示奖励
function ServiceAchievementDlg:showRewardIcon(bossName, isCompleted)
    local panel = self:getControl("TitlePanel_2")
    if isCompleted then
        self:setCtrlVisible("WordsLabel_1", true, panel)
        self:setCtrlVisible("WordsLabel_2", false, panel)
        self:setCtrlVisible("TimeLabel", true, panel)
        self:setCtrlVisible("RewardImage_2", false)
        self:setCtrlVisible("RewardLabel_2", false)
        self:setCtrlVisible("RewardImage_1", false)
        self:setCtrlVisible("RewardLabel_1", false)
        return
    end



    self:setCtrlVisible("WordsLabel_1", false, panel)
    self:setCtrlVisible("WordsLabel_2", true, panel)
    self:setCtrlVisible("TimeLabel", false, panel)

    local rewardInfo = REWARD_ICON[bossName]

    -- 第一个
    local leftInfo = rewardInfo[1]
    if DistMgr:curIsTestDist() then
        if leftInfo.testPortrait then
            self:setImagePlist("RewardImage_1", leftInfo.testPortrait)
        else
            self:setImage("RewardImage_1", ResMgr:getItemIconPath(InventoryMgr:getIconByName(leftInfo.testItemName)))
        end

        self:setLabelText("RewardLabel_1", leftInfo.testReward or leftInfo.reward)
    else
        if leftInfo.portrait then
            self:setImagePlist("RewardImage_1", leftInfo.portrait)
        else
            self:setImage("RewardImage_1", ResMgr:getItemIconPath(InventoryMgr:getIconByName(leftInfo.itemName)))
        end
        self:setLabelText("RewardLabel_1", leftInfo.reward)
    end

    self:setCtrlVisible("RewardImage_1", true)
    self:setCtrlVisible("RewardLabel_1", true)

    local rightInfo = rewardInfo[2]
    if not rightInfo then
        self:setCtrlVisible("RewardImage_2", false)
        self:setCtrlVisible("RewardLabel_2", false)
        return
    end

    self:setCtrlVisible("RewardImage_2", true)
    self:setCtrlVisible("RewardLabel_2", true)
    if DistMgr:curIsTestDist() then
        if rightInfo.testPortrait then
            self:setImagePlist("RewardImage_2", rightInfo.testPortrait)
        else
            self:setImage("RewardImage_2", ResMgr:getItemIconPath(InventoryMgr:getIconByName(rightInfo.testItemName)))
        end
        self:setLabelText("RewardLabel_2", rightInfo.testReward or rightInfo.reward)
    else
        if rightInfo.portrait then
            self:setImagePlist("RewardImage_2", rightInfo.portrait)
        else
            self:setImage("RewardImage_2", ResMgr:getItemIconPath(InventoryMgr:getIconByName(rightInfo.itemName)))
        end
        self:setLabelText("RewardLabel_2", rightInfo.reward)
    end

end

function ServiceAchievementDlg:setBossInfo(data, bossName)
    local bName = data and data.boss_name or bossName
    self:setImage("BossImage", ResMgr:getSmallPortrait(BOSS_SHAPE_INFO[bName].icon))
    self:setImage("NameImage_2", BOSS_SHAPE_INFO[bName].bannerStr)
    self:setImage("NameImage_2", BOSS_SHAPE_INFO[bName].nameIcon, "ShowPanel_1")
    self:setImage("NameImage_2", BOSS_SHAPE_INFO[bName].nameIcon, "ShowPanel_2")

    local shapePanel = self.oneMenu == CHS[7002146] and "ShowPanel_1" or "ShowPanel_2"
    if not data then
        -- 没有数据
        self:setCtrlVisible("FirstKillPointImage", true)
        self:setCtrlVisible("InfoPanel", false)
        self:setPortrait("BossIconPanel", BOSS_SHAPE_INFO[bossName].icon, 0, shapePanel, true, nil, nil, cc.p(0, -60))
        self:showRewardIcon(bName, false)
        return
    end
    self:showRewardIcon(bName, true)

    self:setCtrlVisible("FirstKillPointImage", false)
    self:setCtrlVisible("InfoPanel", true)

    local panel = self:getControl("TitlePanel_2")
    -- 形象
    self:setPortrait("BossIconPanel", BOSS_SHAPE_INFO[data.boss_name].icon, 0, shapePanel, true, nil, nil, cc.p(0, -60))

    -- 时间
    local timeStr = gf:getServerDate(CHS[4300158], data.kill_time)
    self:setLabelText("TimeLabel", string.format(CHS[4300338], timeStr), panel)

    -- 首杀队伍
    for i = 1, 5 do
        local panel = self:getControl("MemberPanel_" .. i)
        local info = data.plays[i]
        if info then
            self:setImage("UserImage", ResMgr:getSmallPortrait(info.icon), panel)
            self:setItemImageSize("UserImage", panel)
         --   self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

            self:setLabelText("LevelLabel", info.level .. CHS[5300006], panel)

            self:setCtrlVisible("TeamLeaderImage", (i == 1), panel)
            self:setLabelText("MemberNameLabel", info.name, panel)
            self:setLabelText("MemberIDLabel", gf:getShowId(info.gid), panel)
            panel:setVisible(true)
            panel:requestDoLayout()
        else
            panel:setVisible(false)
        end
    end
end

function ServiceAchievementDlg:addSecondMenu(sender)
    if not SMALL_MENU[sender:getName()] then return end
    local list = self:getControl("CategoryListView")
    local menuData = gf:deepCopy(SMALL_MENU[sender:getName()])

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

    list:requestRefreshView()
end

function ServiceAchievementDlg:setArrow(sender)
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

function ServiceAchievementDlg:onButton_284(sender, eventType)

    self:setCtrlVisible("ShowPanel_1", self.oneMenu == CHS[7002146])
    self:setCtrlVisible("ShowPanel_2", self.oneMenu ~= CHS[7002146])
end

function ServiceAchievementDlg:MSG_SUPER_BOSS_KILL_FIRST(data)
    if self.oneMenu ~= CHS[7002146] then return end
    local data = AchievementMgr:getSuperBossFB()
    if data and next(data) then
        self:setBossInfo(data[self.twoMenu], self.twoMenu)
    end
end

function ServiceAchievementDlg:MSG_QISHA_SHILIAN_KILL_FIRST(data)
    if self.oneMenu == CHS[4100959] then
        local data = AchievementMgr:getQiShaFB()
        if data and data.count == 1 then
            local retData = gf:deepCopy(data)
            retData.boss_name = CHS[4100959]
            self:setBossInfo(retData)
        else
            self:setBossInfo(nil, CHS[4100959])
        end
    end
end

return ServiceAchievementDlg
