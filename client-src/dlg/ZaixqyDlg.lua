-- ZaixqyDlg.lua
-- Created by songcw
-- 再续前缘

local ZaixqyDlg = Singleton("ZaixqyDlg", Dialog)
local PageTag = require('ctrl/PageTag')
local RewardContainer = require("ctrl/RewardContainer")

-- 纪念宠物列表
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

local PAGE_COUNT = 4


local EQUIP_ATTRIB = {
    "phy", "mag", "speed", "cskill",
}


local DISPLAY_PANEL = {
    "MainPanel",
    "ZaixqySevenDaysTaskPanel",
    "ZaixqyDrawPanel",
    "ZaixqyGiftPanel",
    "ZaixqyMallPanel",
    "ZaixqySevenDaysGiftPanel",
    "ZaixqyBuyPanel",
}

-- 七日任务配置
local SEVEN_CFG = {
    [1] = {day = CHS[4200270], task = CHS[4200277], taskRound = 10, score_f = 100, icon = 0, def_task = CHS[6000106]},
    [2] = {day = CHS[4200271], task = CHS[4200278], taskRound = 10, score_f = 100, icon = 06036, def_task = CHS[4200284]},
    [3] = {day = CHS[4200272], task = CHS[4200279], taskRound = 1, score_f = 100, icon = 20006, def_task = CHS[4200285]},
    [4] = {day = CHS[4200273], task = CHS[4200280], taskRound = 1, score_f = 150, icon = 06010, def_task = CHS[4200286]},
    [5] = {day = CHS[4200274], task = CHS[4200281], taskRound = 10, score_f = 150, icon = 06031, def_task = CHS[4200287]},
    [6] = {day = CHS[4200275], task = CHS[4200282], taskRound = 1, score_f = 150, icon = 06223, def_task = CHS[4200288]},
    [7] = {day = CHS[4200276], task = CHS[4200283], taskRound = 20, score_f = 150, icon = 06042, def_task = CHS[4200289]},
}

-- 首次回归奖品
local DRAW_FITST_REWARD = {
    -- 道行
    [1] = {chs = CHS[3000049], icon = ResMgr.ui.reward_big_daohang, isPlist = 1, reward = {[1] = CHS[3000049], [2] = CHS[3000049]}},    -- 1倍道行
    -- 经验
    [2] = {chs = CHS[3002167], icon = ResMgr.ui.reward_big_exp, isPlist = 1, reward = {[1] = CHS[3002167], [2] = CHS[3002167]}},    -- 经验
    [3] = {chs = CHS[3002238], icon = ResMgr.ui.reward_big_pot, isPlist = 1, reward = {[1] = CHS[3002238], [2] = CHS[3002238]}},    --
    [4] = {chs = CHS[4200290], icon = ResMgr.ui.huiguiScore, isPlist = 1, reward = {[1] = CHS[3002238], [2] = CHS[3002238]}},
    [5] = {chs = CHS[7000277], item = {name = CHS[7000277]}},     -- 紫气鸿蒙
    [6] = {chs = CHS[4300061], item = {name = CHS[4300061]}},     -- 急急如律令
    [7] = {chs = CHS[6200026], item = {name = CHS[6200026]}},     -- 宠风散
    [8] = {chs = CHS[3000666], item = {name = CHS[3000666]}},     -- 超级女娲石
}

-- 回归奖品
local DRAW_REWARD = {
    [1] = {chs = CHS[3002147], icon = ResMgr.ui.reward_big_daohang, isPlist = 1, reward = {[1] = CHS[3000049], [2] = CHS[3000049]}},    -- 1倍道行
    [2] = {chs = CHS[3002167], icon = ResMgr.ui.reward_big_exp, isPlist = 1, reward = {[1] = CHS[3002167], [2] = CHS[3002167]}},    -- 经验
    [3] = {chs = CHS[3002238], icon = ResMgr.ui.reward_big_pot, isPlist = 1, reward = {[1] = CHS[3002238], [2] = CHS[3002238]}},    -- 经验
    [4] = {chs = CHS[4200291], icon = ResMgr.ui.huiguiScore, isPlist = 1, reward = {[1] = CHS[3002238], [2] = CHS[3002238]}},
    [5] = {chs = CHS[7000277], item = {name = CHS[7000277]}},     -- 紫气鸿蒙
    [6] = {chs = CHS[3001146], item = {name = CHS[3001146]}},     -- 急急如律令
    [7] = {chs = CHS[6200026], item = {name = CHS[6200026]}},     -- 宠风散
    [8] = {chs = CHS[3001251], item = {name = CHS[3001251]}},     -- 超级晶石
}

-- 回归礼包
local GIFT_REWARD = {
    [3] = { -- 特级回归礼包
        [1] = {name = CHS[6000497], isPet = true, icon = 30013, reward = {[1] = CHS[6000079], [2] = CHS[7001054]}, time_limited = 1}, -- 赤焰葫芦
        [2] = {name = CHS[4200292], item = {name = CHS[4200292]}, limted = 2}, -- 修炼卷轴
        [3] = {name = CHS[3001262], item = {name = CHS[3001262]}, time_limited = 1},    -- 宠物经验丹
        [4] = {name = CHS[5400070], item = {name = CHS[5400070]}, time_limited = 1},    -- 刷道卷轴
        [5] = {name = CHS[4200293], reward = {[1] = CHS[4200293], [2] = CHS[4200293]}}, -- 回归积分
        [6] = {name = CHS[3001489], item = {name = CHS[3001489]}, limted = 2},  -- 高级血池
        [7] = {name = CHS[3001490], item = {name = CHS[3001490]}, limted = 2},  -- 高级灵池
        [8] = {name = CHS[3002601], item = {name = CHS[3002601]}, limted = 2},     -- 驯兽诀
    },

    [2] = { -- 超级回归礼包
        [1] = {name = CHS[6000497], isPet = true, icon = 30013, reward = {[1] = CHS[6000079], [2] = CHS[7001053]}, time_limited = 1}, -- 赤焰葫芦
        [2] = {name = CHS[4200292], item = {name = CHS[4200292]}, limted = 2}, -- 修炼卷轴
        [3] = {name = CHS[3001262], item = {name = CHS[3001262]}, time_limited = 1},    -- 宠物经验丹
        [4] = {name = CHS[5400070], item = {name = CHS[5400070]}, time_limited = 1},    -- 刷道卷轴
        [5] = {name = CHS[4200293], reward = {[1] = CHS[4200293], [2] = CHS[4200293]}}, -- 回归积分
        [6] = {name = CHS[3001495], item = {name = CHS[3001495]}, limted = 2},  -- 中级血池
        [7] = {name = CHS[3001496], item = {name = CHS[3001496]}, limted = 2},  -- 中级灵池
        [8] = {name = CHS[3002601], item = {name = CHS[3002601]}, limted = 2},     -- 驯兽诀
    },

    [1] = { -- 普通回归礼包
        [1] = {name = CHS[6000497], isPet = true, icon = 30013, reward = {[1] = CHS[6000079], [2] = CHS[4200335]}, time_limited = 1}, -- 赤焰葫芦
        [2] = {name = CHS[4200292], item = {name = CHS[4200292]}, limted = 2}, -- 修炼卷轴
        [3] = {name = CHS[3001262], item = {name = CHS[3001262]}, time_limited = 1},    -- 宠物经验丹
        [4] = {name = CHS[5400070], item = {name = CHS[5400070]}, time_limited = 1},    -- 刷道卷轴
        [5] = {name = CHS[4200293], reward = {[1] = CHS[4200293], [2] = CHS[4200293]}}, -- 回归积分
        [6] = {name = CHS[3002595], item = {name = CHS[3002595]}, limted = 2},  -- 中级血池
        [7] = {name = CHS[3002598], item = {name = CHS[3002598]}, limted = 2},  -- 中级灵池
        [8] = {name = CHS[3002601], item = {name = CHS[3002601]}, limted = 2},     -- 驯兽诀
    },
}

local REWARD_MAX = 8

ZaixqyDlg.needCount = 0
ZaixqyDlg.startPos = 1
ZaixqyDlg.curPos = 1
ZaixqyDlg.delay = 1
ZaixqyDlg.updateTime = 1

local ONE_DAY = 86400

ZaixqyDlg.data = nil

ZaixqyDlg.RED_DOT_SCALE = 0.65

function ZaixqyDlg:init()
    self:bindListener("PointButton", self.onPointButton)
    self:bindListener("GoSevenButton", self.onSevenButton, "ActivitiesUnitPanel1")
    self:bindListener("GoSevenGiftButton", self.onSevenGiftButton, "ActivitiesUnitPanel1_2")
    self:bindListener("GoHuoyueButton", self.onDisplayDrawButton, "ActivitiesUnitPanel2")
    self:bindListener("GoHuiguiButton", self.onGiftButton, "ActivitiesUnitPanel3")
    self:bindListener("GoHuiguiButton", self.onGiftTHButton, "ActivitiesUnitPanel3_2")
    self:bindListener("GoButton", self.onMallButton, "ActivitiesUnitPanel4")
    self:bindListener("GoButton", self.onTeamRewardButton, "ActivitiesUnitPanel5")
    self:bindListener("DrawButton", self.onDrawButton)
    self:bindListener("GetButton", self.onGetHuiGuiButton, "ZaixqyGiftPanel")
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindSellNumInput()

    self.scoreItemCount = 1
    self.scoreItem = nil
    self.continuousTimes = 0
    self.clickNum = 0
    self.isRotating = false
    self.isRefreashDraw = false
    self.isRefreash = false -- 为true则刷新
    self.isRefreashForScoreShop = false
    self.equipPanel = nil
    self.equip_att = nil
    self.oldDlg = false

    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')

    for _, pName in pairs(DISPLAY_PANEL) do
        self:bindListener("ReturnButton", self.onReturnButton, pName)
    end

    self:setCtrlVisible("LimitTimePanel", false)

    -- 更新积分
    self:updateScoreCount()

    -- 广告page
    self:initPageCtrl()

    self.sevenDayPanel = self:toCloneCtrl("TaskPanel")
    self:bindListener("GetButton", self.onGetSevenButton, self.sevenDayPanel)

    self.scorePanel = self:toCloneCtrl("GoodsPanel")
    self.selectScoreEffImage = self:toCloneCtrl("ChosenEffectImage", self.scorePanel)

    self:bindTouchEndEventListener(self.scorePanel, self.onScorePanel)

    -- 2017 再续前缘
    self.buyPanel = self:retainCtrl("GoodPanel", "ZaixqyBuyPanel")
    self:bindListener("BuyButton", self.onBuyHGButton, self.buyPanel)       -- 特惠购买按钮
    self.fistGiftPanel = self:retainCtrl("FistGiftPanel", "ZaixqySevenDaysGiftPanel")
    self:bindListener("GetButton", self.onGetGiftButton, self.fistGiftPanel) -- 7日领取
    for i = 1, 4 do
        local uPanel = self:getControl("TypePanel" .. i, nil, self.fistGiftPanel)

        local ctrl = self:getControl("CheckBox", Const.UICheckBox, uPanel)
        ctrl:setTag(i)
        self:bindCheckBoxListener("CheckBox", self.onCheckBox, uPanel)

        self:bindListener("ItemImagePanel" .. i, self.onShowEquipButton, self.fistGiftPanel)
    end

    self.giftPanel = self:retainCtrl("GiftPanel", "ZaixqySevenDaysGiftPanel")
    self:bindListener("GetButton", self.onGetGiftButton, self.giftPanel) -- 7日领取

    -- 默认显示主界面
    self:setDisplay("MainPanel")

    self:hookMsg("MSG_REENTRY_ASKTAO_DATA")
    self:hookMsg("MSG_REENTRY_ASKTAO_DATA_NEW")

    self:hookMsg("MSG_REENTRY_ASKTAO_RESULT")
    self:hookMsg("MSG_COMEBACK_SCORE_SHOP_ITEM_LIST")
    self:hookMsg("MSG_COMEBACK_COIN_SHOP_ITEM_LIST")
    self:hookMsg("MSG_COMEBACK_SEVEN_GIFT_ITEM_LIST")
    self:hookMsg("MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST")

    GiftMgr:queryZaixqyDaya()

    -- 请求回归特惠
    GiftMgr:queryHuiGuiBuy()

    -- 请求装备
    local equips = GiftMgr:getZaixqyEuipByAttrib("phy")
    if not equips then
        GiftMgr:queryZaixqyEquip("phy")
    end

    -- 请求7日登录礼包
    GiftMgr:querySevenGift()

    self.oldDlg = not GiftMgr:isOpenNewZaixqy()

    if self.data then
        if self.oldDlg then
            self:MSG_REENTRY_ASKTAO_DATA(self.data)
        else
            self:MSG_REENTRY_ASKTAO_DATA_NEW(self.data)
        end
    end

    self:bindTeamRulePanelListener()

    self:initScrollView()
    self:setDlgDisplay()
end

function ZaixqyDlg:bindTeamRulePanelListener()
    local panel = self:getControl("TeamRulePanel")
    panel:setVisible(false)
    local bkPanel = self:getControl("BKPanel") or self.root
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())

    local function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()

        if panel:isVisible() then
            if cc.rectContainsPoint(rect, toPos) then
                return true     -- 如果在悬浮框中，就吞噬事件
            else
                panel:setVisible(false) -- 否则隐藏悬浮框后再下传事件
            end
        end
    end

    layout:setGlobalZOrder(Const.ZORDER_FLOATING)
    self.blank:addChild(layout, 10, 100)
    panel:requestDoLayout()
    gf:bindTouchListener(layout, touch)
end

function ZaixqyDlg:initScrollView()
    local scrollView = self:getControl("ActivitiesScrollView", Const.UIScrollView)
    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
            self:setCtrlVisible("DownImage", false)
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            self:setCtrlVisible("UpDownImage", false)
        elseif eventType == ccui.ScrollviewEventType.scrolling then
            self:setCtrlVisible("UpDownImage", true)
            self:setCtrlVisible("DownImage", true)
        end
    end
    scrollView:addEventListener(scrollListener)
    -- 初始时上箭头应该是隐藏的
    self:setCtrlVisible("UpDownImage", false)
end

-- 有新旧版本之分
function ZaixqyDlg:setDlgDisplay()
    if self.oldDlg then
        self:setCtrlVisible("ActivitiesUnitPanel1_2", false)
        self:setCtrlVisible("ActivitiesUnitPanel3_2", false)
    else
        self:setCtrlVisible("ActivitiesUnitPanel1_2", true)
        self:setCtrlVisible("ActivitiesUnitPanel3_2", true)
    end
end

function ZaixqyDlg:cleanup()
    self.data = nil
    self:releaseCloneCtrl("sevenDayPanel")
    self:releaseCloneCtrl("selectScoreEffImage")
    self:releaseCloneCtrl("scorePanel")
end

-- 开始转圈
function ZaixqyDlg:onUpdate()
    if not self.isRotating then return end

    if self.updateTime % self.delay ~= 0 then
        self.updateTime = self.updateTime + 1
        return
    end

    -- 如果在战斗中
    if Me:isInCombat() then
        return
    end

    if self.curPos < self.needCount then
        -- 转五行
        self.delay = self:calcSpeed(self.curPos, self.needCount)
        local wuxPos = (self.curPos) % REWARD_MAX + 1
        local rollCtrl = self:getControl("ChosenImage", nil, "BonusPanel_" .. wuxPos)
        rollCtrl:setVisible(true)
        rollCtrl:setOpacity(255)
        self.curPos = self.curPos + 1
        if self.curPos ~= self.needCount then
            local timeT = self.delay * 0.03
            if timeT > 1 then timeT = 1 end
            rollCtrl:runAction(cc.FadeOut:create(timeT))
        else
            rollCtrl:stopAllActions()
        end
    else
        self.isRotating = false
        self.lastTime = 0
        GiftMgr:drawZaixqyReward(1)
    end
end

function ZaixqyDlg:onSubOrAddNum(ctrlName, times)
    if times == 1 then
        self.needShowSubOrAddTips = true
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end

end

function ZaixqyDlg:autoNextPage()
    local pageCtrl = self:getControl("NewsPageView")
    pageCtrl:stopAllActions()

    local delay = cc.DelayTime:create(4)
    local fun = cc.CallFunc:create(function()
        local idx = pageCtrl:getCurPageIndex()
        if idx + 1 < PAGE_COUNT then
            pageCtrl:scrollToPage(idx + 1)
        else
            pageCtrl:scrollToPage(0)
        end
    end)

    pageCtrl:runAction(cc.Sequence:create(delay, fun))

end

-- 初始化主界面的广告page
function ZaixqyDlg:initPageCtrl()
    -- 绑定分页控件和分页标签
    local pageTagPanel = self:getControl("PageDotPanel")
    local pageTag = PageTag.new(PAGE_COUNT, 2, 20, 1)
    local tagPanelSz = pageTagPanel:getContentSize()
    pageTag:ignoreAnchorPointForPosition(false)
    pageTag:setAnchorPoint(0.5, 0)
    pageTag:setPosition(tagPanelSz.width / 2 + 20, -8)
    --   pageTag:setScale(0.6)
    pageTagPanel:addChild(pageTag)

    local pageCtrl = self:getControl("NewsPageView")
    self:bindPageViewAndPageTag(pageCtrl, pageTag, self.autoNextPage)
    pageTag:setPage(1)
    self:autoNextPage()

    local panel = self:getControl("MoveTouchPanel")
    self.isAuto = false
    gf:bindTouchListener(panel, function(touch, event)
        local pos = touch:getLocation()
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local eventCode = event:getEventCode()
        local pageCtrl = self:getControl("NewsPageView")
        if eventCode == cc.EventCode.BEGAN then
            if cc.rectContainsPoint(rect, pos) then
                self.isAuto = true
                pageCtrl:stopAllActions()
            end
        elseif eventCode == cc.EventCode.MOVED then
            if self.isAuto then
                pageCtrl:stopAllActions()
            end
        elseif eventCode == cc.EventCode.ENDED then

            if self.isAuto then
                self:autoNextPage()
                self.isAuto = false
            end
        else
            if self.isAuto then
                self:autoNextPage()
                self.isAuto = false
            end
        end

        -- 需要往后传递
        return true
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED
    }, true)
end

function ZaixqyDlg:updateSlider(sender, eventType)

        self.pageView:addEventListener(function(sender, eventType)
            if ccui.PageViewEventType.turning == eventType and 1 == self.pageView:getCurPageIndex() then
                if true == DlgMgr:isDlgOpened(self.name) then
                    DlgMgr:setVisible(self.name, false)
                end
            end
        end)
end

function ZaixqyDlg:setDisplay(panelName)
    for _, pName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(pName, pName == panelName)
    end
end

-- 设置单个七日任务panel
function ZaixqyDlg:setUnitDayPanel(key, panel)
    local cfgData = SEVEN_CFG[key]

    -- 任务名称
    self:setLabelText("NameLabel", cfgData.day .. "·" .. cfgData.task, panel)

    -- 积分
    if self.data.is_first == 1 then
        self:setLabelText("PointLabel", cfgData.score_f, panel)
    else
        self:setLabelText("PointLabel", math.floor(cfgData.score_f / 10), panel)
    end

    -- 次数
    local max = cfgData.taskRound
    local cur = tonumber(self.data.taskTimes[key])
    if cur > max then
        self:setLabelText("TimesNumLabel", max .. "/" .. max, panel)
    else
        self:setLabelText("TimesNumLabel", cur .. "/" .. max, panel)
    end
    -- icon
    local icon = cfgData.icon
    if icon == 0 then
        if Me:queryBasicInt("polar") == POLAR.METAL then
            icon = 06052
        elseif Me:queryBasicInt("polar") == POLAR.WOOD then
            icon = 06053
        elseif Me:queryBasicInt("polar") == POLAR.WATER then
            icon = 06054
        elseif Me:queryBasicInt("polar") == POLAR.FIRE then
            icon = 06055
        elseif Me:queryBasicInt("polar") == POLAR.EARTH then
            icon = 06056
        end
    end

    -- 按钮状态
    local getBtn = self:getControl("GetButton", nil, panel)
    getBtn:setTag(key)
    getBtn.cfgData = cfgData
    self:setCtrlVisible("GetButton", false, panel)
    self:setCtrlVisible("GotImage", false, panel)
    self:setCtrlVisible("NoneImage", false, panel)
    if self.data.taskFetchedFlag[key] == "1" then
        self:setCtrlVisible("GotImage", true, panel)
    else
        local curTime = gf:getServerTime()

        if curTime >= self.data.start_time + (key - 1) * ONE_DAY then
            self:setCtrlVisible("GetButton", true, panel)
            if cur < max then
                self:setLabelText("Label", CHS[4400018], getBtn)
                self:setLabelText("Label_1", CHS[4400018], getBtn)
            else
                self:setLabelText("Label", CHS[4400021], getBtn)
                self:setLabelText("Label_1", CHS[4400021], getBtn)
            end
        else
            self:setCtrlVisible("NoneImage", true, panel)
        end
    end

    self:setImage("GoodsImage", ResMgr:getSmallPortrait(icon), panel)
end

-- 设置七日数据
function ZaixqyDlg:setSevenDayData()
    if self.isRefreash then
        local listview = self:getControl("GoodsListView")
        local items = listview:getItems()
        for _, panel in pairs(items) do
            self:setUnitDayPanel(_, panel)
        end
    else
        local listview = self:resetListView("GoodsListView", 3)
        for i = 1, #SEVEN_CFG do
            local panel = self.sevenDayPanel:clone()
            self:setUnitDayPanel(i, panel)
            listview:pushBackCustomItem(panel)
        end
    end
end

-- 设置抽奖奖品
function ZaixqyDlg:setDrawData()
    local rewardData
    if self.data.is_first == 1 then
        rewardData = gf:deepCopy(DRAW_FITST_REWARD)
    else
        rewardData = gf:deepCopy(DRAW_REWARD)
    end

    if not self.isRefreashDraw then

        for i = 1, REWARD_MAX do
            local panel = self:getControl("BonusPanel_" .. i)
            self:setCtrlVisible("ChosenImage", false, panel)

            if rewardData[i].icon then
                if rewardData[i].isPlist == 1 then
                    self:setImagePlist("BonusImage", rewardData[i].icon, panel)
                else
                    self:setImage("BonusImage", rewardData[i].icon, panel)
                end

                local image = self:getControl("BonusImage", nil, panel)

                if rewardData[i].icon == ResMgr.ui.no_bachelor_pick then
                    local y = image:getPositionY() - 31
                    image:setPositionY(y)

                    panel:requestDoLayout()
                end
            elseif rewardData[i].petPortrait then
                self:setImage("BonusImage", ResMgr:getSmallPortrait(rewardData[i].petPortrait), panel)
            elseif rewardData[i].itemIcon then
                self:setImage("BonusImage", ResMgr:getItemIconPath(rewardData[i].itemIcon), panel)
            else
                local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(rewardData[i].chs))
                self:setImage("BonusImage", path, panel)
            end

            self:setItemImageSize("BonusImage", panel)

            local image = self:getControl("BonusImage", nil, panel)
            image.data = rewardData[i]
            self:setLabelText("NameLabel", rewardData[i].chs, panel)
        end
        self.isRefreashDraw = true
    end

    if self.data.fetched_liveness_gift == 0 then
        if self.data.active_value < 100 then
            self:setLabelText("NoteLabel_1", CHS[4200294])
        else
            self:setLabelText("NoteLabel_1", CHS[4200295])
        end
    else
        self:setLabelText("NoteLabel_1", CHS[4200294])
    end
end

function ZaixqyDlg:setGiftLogo(data, panel)
    local image = self:getControl("ItemImage", nil, panel)
    image:removeAllChildren()
    if data.limted then
        InventoryMgr:addLogoBinding(image)
    elseif data.time_limited then
        InventoryMgr:addLogoTimeLimit(image)
    end
end

-- 设置回归礼包信息
function ZaixqyDlg:setGiftData(data)
    local gifts = GIFT_REWARD[data.fetched_comeback_type]

    local no1_panel = self:getControl("ItemImagePanel")
    no1_panel.data = gifts[1]
    self:setGiftLogo(no1_panel.data, no1_panel)
    self:setImage("ItemImage", ResMgr:getSmallPortrait(gifts[1].icon), no1_panel)


    self:bindTouchEndEventListener(no1_panel, self.onRewardIconButton)

    for i = 2, 8 do
        local panel = self:getControl("ItemImagePanel" .. (i - 1))
        panel.data = gifts[i]
        if string.match(gifts[i].name, CHS[4200296]) then
            self:setImagePlist("ItemImage", ResMgr.ui.huiguiScore, panel)
        else
            self:setImage("ItemImage", ResMgr:getIconPathByName(gifts[i].name), panel)
        end
        self:setGiftLogo(panel.data, panel)
        self:bindTouchEndEventListener(panel, self.onRewardIconButton)
    end

    local panel = self:getControl("ZaixqyGiftPanel")
    self:setCtrlVisible("GetButton", self.data.fetched_comeback_gift ~= 0, panel)
    self:setCtrlVisible("GotImage", self.data.fetched_comeback_gift == 0, panel)
end

function ZaixqyDlg:setUnitScorePanel(data, panel)
    panel.data = data

    self:setLabelText("GoodsNameLabel", data.name, panel)


    self:setNumImgForPanel("MoneyNumberPanel", ART_FONT_COLOR.NORMAL_TEXT, data.price, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- icon
    self:setImage("GoodsImage", ResMgr:getIconPathByName(data.name), panel)

    self:setLabelText("LeftNumLabel", CHS[4200297] .. data.amount, panel)

    if data.amount <= 0 then
        self:setCtrlEnabled("GoodsImage", false, panel)
        self:setCtrlVisible("SellOutImage", true, panel)
    end

    local image = self:getControl("GoodsImage", nil, panel)
    image:removeAllChildren()
    if data.bind > 1 then
        InventoryMgr:addLogoTimeLimit(image)
    elseif data.bind == 1 then
        InventoryMgr:addLogoBinding(image)
    end
end

-- 设置积分
function ZaixqyDlg:setScoreData(data)
    if self.isRefreashForScoreShop then
        local listview = self:getControl("ScoreListView")
        local items = listview:getItems()
        for i, panel in pairs(items) do
            if not data[i] then
                -- 刷新数据，要是没了，需要移除
                panel:removeFromParent()
                self:onScorePanel(items[1])
            else
                self:setUnitScorePanel(data[i], panel)
            end
        end

        listview:requestRefreshView()
    else
        local listview = self:resetListView("ScoreListView", 3)
        for i = 1, data.count do
            local panel = self.scorePanel:clone()
            self:setUnitScorePanel(data[i], panel)
            listview:pushBackCustomItem(panel)
        end

        local panel = self:getControl("ZaixqyMallPanel")
        self:setCtrlVisible("EmptyPanel", true, panel)
    end
end

-- 设置右侧积分商品信息
function ZaixqyDlg:setScoreGoodsInfo(data)
    -- 设置右侧信息
    local panel = self:getControl("ZaixqyMallPanel")
    self:setCtrlVisible("EmptyPanel", false, panel)

    -- 名称
    local infoPanel = self:getControl("BuyPanel", nil, panel)
    self:setLabelText("GoodsNameLabel", data.name, infoPanel)

    -- 描述
    local descPanel = self:getControl("DescriptionPanel", nil, infoPanel)
    local desc = InventoryMgr:getDescript(data.name)
    if data.name == CHS[6000500] then
        desc = CHS[4200298]
    end

    -- 如果是2018年周年庆的纪念宠物，需要加上
    local petCard = string.match(data.name, CHS[4101005])
    if petCard and jinianPetList[petCard]then
        self:setCtrlVisible("LimitFestivalPanel", true)
    else
        self:setCtrlVisible("LimitFestivalPanel", false)
    end


    local realHeight = self:setColorText(desc, "DescriptionPanel", infoPanel)
    local size = descPanel:getContentSize()
    descPanel:setContentSize(size.width, size.height)

    -- 刷新listview控件
    local listCtrl = self:getControl("GoodsAttribInfoListView", nil, infoPanel)
    listCtrl:doLayout()
    listCtrl:refreshView()

    -- 限时
    if data.bind > 1 then
        self:setCtrlVisible("LimitTimePanel", true)
        self:setLabelText("LimitTimeLabel2", math.floor(data.bind / ONE_DAY), infoPanel)
    else
        self:setCtrlVisible("LimitTimePanel", false)
    end
end

-- 更新我的积分
function ZaixqyDlg:updateMyScore(data)
    local panel = self:getControl("ZaixqyMallPanel")
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.NORMAL_TEXT, data.score, false, LOCATE_POSITION.MID, 21, panel)
end


-- 更新积分商城，选择道具数量
function ZaixqyDlg:updateScoreCount()
    -- 设置右侧信息
    local panel = self:getControl("ZaixqyMallPanel")

    self:setLabelText("NumberLabel", self.scoreItemCount, panel)
    self:setLabelText("NumberLabel_1", self.scoreItemCount, panel)

    -- 商品总价
    self:updateTotalPrice()
end

function ZaixqyDlg:updateTotalPrice()
    local buyButton = self:getControl("BuyButton", nil, "ZaixqyMallPanel")
    if self.scoreItem and self.scoreItemCount then
        self:setLabelText("NumLabel", self.scoreItem.price * self.scoreItemCount, buyButton)
        self:setLabelText("NumLabel_1", self.scoreItem.price * self.scoreItemCount, buyButton)
    end
end

-- 点击单个积分兑换项
function ZaixqyDlg:onScorePanel(sender, eventType)
    self.selectScoreEffImage:removeFromParent()
    sender:addChild(self.selectScoreEffImage)

    if self.scoreItem == sender.data then
        self.clickNum = self.clickNum + 1
        self:onAddButton()
    else
        self.clickNum = 0
        self.scoreItemCount = 1
    end

    self.scoreItem = sender.data

    self:updateScoreCount()
    -- 设置右侧信息
    self:setScoreGoodsInfo(self.scoreItem)
end

function ZaixqyDlg:changeScoreCount(changetype)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end

    if changetype == "add" then
        self.scoreItemCount = self.scoreItemCount + 1

        if self.scoreItem.name ~= CHS[6000500] then
            local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
            if count < self.scoreItemCount then
                self.scoreItemCount = self.scoreItemCount - 1
                gf:ShowSmallTips(CHS[4200300])
                self:updateScoreCount()
                return
            end
        end

        if self.scoreItem and self.scoreItemCount > self.scoreItem.amount then
            self.scoreItemCount = self.scoreItem.amount
            gf:ShowSmallTips(CHS[4200301])
            self:updateScoreCount()
            return
        end
    elseif changetype == "reduce" then
        self.scoreItemCount = self.scoreItemCount - 1
        if self.scoreItemCount < 1 then
            self.scoreItemCount = 1
            gf:ShowSmallTips(CHS[4200302])
            self:updateScoreCount()
            return
        end
    end

    self:updateScoreCount()
end

function ZaixqyDlg:continuousTips()
    if self.clickNum == 4 then
        gf:ShowSmallTips(CHS[3002731])
    end
end

function ZaixqyDlg:onAddButton(sender, eventType)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end
    self:changeScoreCount("add")
    self:continuousTips()
end

function ZaixqyDlg:onReduceButton(sender, eventType)
    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end
    self:changeScoreCount("reduce")
    self.continuousTimes = self.continuousTimes + 1
    self:continuousTips()
end

function ZaixqyDlg:onPointButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    GiftMgr:queryHuiGuiShop()
    self:setDisplay("ZaixqyMallPanel")
end

function ZaixqyDlg:onSevenGiftButton(sender, eventType)
    if not self.data then return end
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end

    if self.data.can_get_gift == 0 then
        gf:ShowSmallTips(CHS[4300271])
        return
    end
    self:setDisplay("ZaixqySevenDaysGiftPanel")
end

function ZaixqyDlg:onSevenButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    self:setDisplay("ZaixqySevenDaysTaskPanel")
end

function ZaixqyDlg:onDisplayDrawButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    self:setDisplay("ZaixqyDrawPanel")
end

-- 回归特惠
function ZaixqyDlg:onGiftTHButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    self:setDisplay("ZaixqyBuyPanel")
end


function ZaixqyDlg:onGiftButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    self:setDisplay("ZaixqyGiftPanel")
end

function ZaixqyDlg:onMallButton(sender, eventType)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    local dlg = DlgMgr:openDlg("ChengweiXuanzeDlg")
    dlg:selectByName(CHS[4200324])
end

function ZaixqyDlg:onTeamRewardButton(btn)
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end
    self:setCtrlVisible("TeamRulePanel", true)
end

function ZaixqyDlg:onGetGiftButton(sender, eventType)
    local para = sender.day
    if para == 1 then
        if not self.equip_att then
            gf:ShowSmallTips(CHS[4300272])
            return
        end

        para = para .. "|" .. self.equip_att
    end

    if sender.day == 1 and Me:queryBasicInt("level") < 70 then
        gf:confirm(CHS[4300273], function ()
            GiftMgr:getSevenGift(para)
        end)
    else
        GiftMgr:getSevenGift(para)
    end
end

function ZaixqyDlg:onBuyHGButton(sender, eventType)

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyHGButton", sender) then
        return
    end

    local function todoBuy(layer)
        -- body

        if 1 == layer then
            local tao = string.match(sender:getParent():getParent().data.reward_desc, CHS[7210000])
            if tao then
                gf:confirm(CHS[7210001], function ()
                    todoBuy(2)
                end)
                return
            end

            todoBuy(2)
        else
            local good_id = sender:getParent():getParent().data.good_id
            local coin = sender:getParent():getParent().data.coin

            gf:confirm(string.format(CHS[4300275], coin), function ()
                GiftMgr:buyHuiGui(good_id)
            end)
        end
    end

    local exp = string.match(sender:getParent():getParent().data.reward_desc, CHS[4300376])
    if exp then
        if Me:isRealBody() then
            -- 真身
            local level = Const.PLAYER_MAX_LEVEL_NOT_FLY
            if Me:isCompletedXiaoFei() then
                level = Const.PLAYER_MAX_LEVEL
            end

            local needExp = -Me:queryInt("exp") - 1                       -- 获取上限等级所需要的经验
            for i = Me:queryBasicInt("level"), level do
                needExp = CharMgr:getMaxExpForLevel(i, true) + needExp
            end

            if needExp < tonumber(exp) then
                gf:confirm(string.format(CHS[4300374], level), function ()
                    todoBuy(1)
                end)
                return
            end
        else
            -- 元婴血婴
            local level = Me:getBabyLevelMax() -- 上限等级
            local needExp = -Me:queryInt("upgrade/exp") - 1                       -- 获取上限等级所需要的经验
            for i = Me:queryBasicInt("upgrade/level"), level do
                needExp = CharMgr:getMaxExpForLevel(i) + needExp
            end

            -- 计算削减
            exp = tonumber(exp)
            local exp1 = Formula:getDayExp(Me:queryBasicInt("level"))
            local exp2 = Formula:getDayExp(Me:queryBasicInt("upgrade/level"))
            exp = math.floor(exp / ( exp1/ exp2))

            if needExp < exp then
                gf:confirm(string.format(CHS[4300375], Me:getChildName(), level), function ()
                    todoBuy(1)
                end)
                return
            end
        end
    end

    todoBuy(1)
end

function ZaixqyDlg:onReturnButton(sender, eventType)
    self:setDisplay("MainPanel")
end

function ZaixqyDlg:goToTask(data)
    local decStr = ""
    if data.def_task == CHS[6000106] then
        -- 师门
        if TaskMgr:getSMTask() then
            decStr = TaskMgr:getSMTask()
        else
            local npcName = gf:getPolarNPC(tonumber(Me:queryBasic("polar")))
            decStr = string.format(CHS[3002200],npcName)
        end

        local dest = gf:findDest(decStr)

        if dest then
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            -- 解析打开对话框
            local tempStr = string.match(decStr, "#@.+#@")
            if tempStr then
                -- 解析#@道具名|FastUseItemDlg=道具名
                tempStr = string.match(decStr, "|.+=.+")
            end
            if tempStr then
                tempStr = string.sub(tempStr,2)
                tempStr = string.sub(tempStr, 1, -3)
                DlgMgr:openDlgWithParam(tempStr)
            end
        end
    elseif data.def_task == CHS[3002195] then
        -- 帮派
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
        else
            if TaskMgr:getPartyTask() then
                decStr = TaskMgr:getPartyTask()
            else
                decStr = CHS[3002215]
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data.def_task == CHS[3002192] then
        if TaskMgr:getXuanShangTask() then
            decStr = TaskMgr:getXuanShangTask()
        else
            decStr = CHS[3002228]     -- 仙界神捕
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data.def_task == CHS[3002205] then -- 助人为乐
        if TaskMgr:getZhuRenWeiLeTask() then
            decStr = TaskMgr:getZhuRenWeiLeTask()
    else
        decStr = CHS[3002207]
    end

    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data.def_task == CHS[3002219] then -- 除暴任务
        if TaskMgr:getCBTask() then
            decStr = TaskMgr:getCBTask()
    else
        decStr = CHS[3002221]
    end

    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data.def_task == CHS[4200288] then -- 副本
        if TaskMgr:getFuBenTask() then
            decStr = TaskMgr:getFuBenTask()
    else
        decStr = CHS[3002209]
    end

    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif data.def_task == CHS[4200289] then -- 修炼
        if Me:queryBasicInt("level") >= 100 then
            if TaskMgr:getSJZTask() then
                decStr = TaskMgr:getSJZTask()
                AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            else
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4400019]))
            end
    else
        if TaskMgr:getXXTask() then
            decStr = TaskMgr:getXXTask()
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4400020]))
        end
    end
    end
end

function ZaixqyDlg:onShowEquipButton(sender, eventType)
    if not sender.equip then return end
    if not self.equip_att then
        gf:ShowSmallTips(CHS[4300272])
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showEquipByEquipment(sender.equip, rect, true)
end

function ZaixqyDlg:onCheckBox(sender, eventType)
    local tag = sender:getTag()
    self.equip_att = EQUIP_ATTRIB[tag]
    local equips = GiftMgr:getZaixqyEuipByAttrib(self.equip_att)
    if equips then
        self:setEquipData()
    else
        GiftMgr:queryZaixqyEquip(self.equip_att)
    end

    for i = 1, 4 do
        local ctrl = self:getControl("CheckBox", Const.UICheckBox, "TypePanel" .. i)
        self:setCheck("CheckBox", false, "TypePanel" .. i)
    end

    sender:setSelectedState(true)
end


function ZaixqyDlg:onGetSevenButton(sender, eventType)
    if not self.data then return end
    local day = sender:getTag()

    if not self:isMeet() then return end

    local content = self:getLabelText("Label", sender)
    if content == CHS[4400018] then
        self:goToTask(sender.cgfdata)
    else
        GiftMgr:getZaixqySeven(day)
    end
end

function ZaixqyDlg:isMeet()
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 35 then
        gf:ShowSmallTips(CHS[4200303])
        return
    end

    return true
end

function ZaixqyDlg:isEndOfZaixqy()
    if not self.data then return end
    local curTime = gf:getServerTime()

    if curTime > self.data.end_time then
        gf:ShowSmallTips(CHS[4200304])
        ChatMgr:sendMiscMsg(CHS[4200304])
        self:onCloseButton()
        return true
    end

    return false
end

function ZaixqyDlg:onDrawButton(sender, eventType)
    if not self.data then return end

    if not DistMgr:checkCrossDist() then return end

    -- 如果在战斗中
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    if self.isRotating then
        return
    end

    if not self:isMeet() then return end

    -- 背包判断
    local emptyCount = InventoryMgr:getEmptyPosCount()
    if emptyCount == 0 then
        gf:ShowSmallTips(CHS[4200307])
        return
    end

    GiftMgr:drawZaixqyReward(0)
end

function ZaixqyDlg:onGetHuiGuiButton(sender, eventType)
    if not self:isMeet() then return end
    GiftMgr:getZaixqyHuiGui()
end

-- 购买回归积分商城物品
function ZaixqyDlg:onBuyButton(sender, eventType)
    if not self.data then return end
    -- 活动结束判断
    if self:isEndOfZaixqy() then
        return
    end

    -- 等级判断
    if Me:queryInt("level") < 35 then
        gf:ShowSmallTips(CHS[4200327])
        return
    end

    if not self.scoreItem then
        gf:ShowSmallTips(CHS[4200299])
        return
    end

    if self.scoreItemCount < 1 then
        gf:ShowSmallTips(CHS[6000034])
        return
    end

    if self.scoreItem.amount <= 0 then
        gf:ShowSmallTips(CHS[4200308])
        return
    end

    if self.scoreItem.amount < self.scoreItemCount then
        gf:ShowSmallTips(CHS[4200308])
        return
    end

    local isItem = InventoryMgr:getItemInfoByName(self.scoreItem.name)
    if not isItem then
        if PetMgr:getPetCount() >= PetMgr:getPetMaxCount() then
            gf:ShowSmallTips(CHS[4200336])
            return
        end
    else
        local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
        if count < self.scoreItemCount then
            self.scoreItemCount = self.scoreItemCount - 1
            gf:ShowSmallTips(CHS[4200309])
            return
        end
    end

    local totalPrice = self.scoreItem.price * self.scoreItemCount
    if self.data.score < totalPrice then
        gf:ShowSmallTips(CHS[4200310])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton", sender, eventType) then
        return
    end

    local unitStr = InventoryMgr:getUnit(self.scoreItem.name)
    if self.scoreItem == CHS[6000500] or self.scoreItem == CHS[6000497] then
        unitStr = CHS[4200328]
    end

    gf:confirm(string.format(CHS[4200329], totalPrice, self.scoreItemCount, unitStr, self.scoreItem.name), function ()
        local info = string.format("%s_%d", self.scoreItem.index, self.scoreItemCount)
        GiftMgr:buyHuiGuiShop(info)
    end)
end


-- 获取活动最大次数
function ZaixqyDlg:getMaxByTask(task)
    local dayTask = ActivityMgr:getDailyActivity()
    for _, taskInfo in pairs(dayTask) do
        if taskInfo.name == task then
            return taskInfo.times
        end
    end

    local limitTask = ActivityMgr:getLimitActivity()
    for _, taskInfo in pairs(limitTask) do
        if taskInfo.name == task then
            return taskInfo.times
        end
    end
end

function ZaixqyDlg:MSG_REENTRY_ASKTAO_DATA_NEW(data)
    self.oldDlg = false

    self.data = data

    local mainPanel = self:getControl("MainPanel")

    -- 活动时间
    local startTimeStr = gf:getServerDate(CHS[5420147], data.start_time)
    local endTimeStr = gf:getServerDate(CHS[5420147], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[4200311], startTimeStr, endTimeStr), mainPanel)

    -- 积分
    self:setLabelText("PointLabel", data.score, mainPanel)
    self:setLabelText("InfoLabel", string.format(CHS[7200002], data.today_bonus_score), "ActivitiesUnitPanel5")

    -- 设置抽奖
    self:setDrawData()

    self.isRefreash = true

    self:setDlgDisplay()
end

function ZaixqyDlg:MSG_REENTRY_ASKTAO_DATA(data)
    self.oldDlg = true

    self.data = data
    self.data.taskTimes = gf:split(data.task_times, ",")
    self.data.taskFetchedFlag = gf:split(data.task_fetched_flag, ",")

    local mainPanel = self:getControl("MainPanel")

    -- 活动时间
    local startTimeStr = gf:getServerDate(CHS[5420147], data.start_time)
    local endTimeStr = gf:getServerDate(CHS[5420147], data.end_time)
    self:setLabelText("TitleLabel", string.format(CHS[4200311], startTimeStr, endTimeStr), mainPanel)

    -- 积分
    self:setLabelText("PointLabel", data.score, mainPanel)

    -- 设置七日任务
    self:setSevenDayData(data)

    -- 设置抽奖
    self:setDrawData()

    -- 设置回归礼包
    self:setGiftData(data)

    self.isRefreash = true

    self:setDlgDisplay()
end

-- 计算转圈间隔
function ZaixqyDlg:calcSpeed(curPos, count)
    if count - curPos < 14 then
        local speed = 6 + (14 - (count - curPos)) * (14 - (count - curPos)) * 0.6
        return math.floor(speed)
    end

    return 6
end

function ZaixqyDlg:MSG_COMEBACK_SCORE_SHOP_ITEM_LIST(data)
    self:setScoreData(data)
    self:updateMyScore(data)
    self.isRefreashForScoreShop = true
end

function ZaixqyDlg:MSG_REENTRY_ASKTAO_RESULT(data)
    if not self.data then return end
    local rewardData
    if self.data.is_first == 1 then
        rewardData = gf:deepCopy(DRAW_FITST_REWARD)
    else
        rewardData = gf:deepCopy(DRAW_REWARD)
    end

    local ret = 1
    for i = 1, REWARD_MAX do
        if string.match(rewardData[i].chs, data.reward) then ret = i + 1 end
    end

    self.needCount = ret - self.startPos + math.random(4,5) * REWARD_MAX
    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1
    self.isRotating = true
    self:setDrawData()
end

function ZaixqyDlg:bindSellNumInput()
    local moneyPanel = self:getControl('NumberValueImage')
    local function openNumIuputDlg()
        if not self.scoreItem then return end
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        self.isStartInput = true
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 + 10)

        self.inputNum = 0
        --   self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindTouchEndEventListener(moneyPanel, openNumIuputDlg)
end

-- 数字键盘删除数字
function ZaixqyDlg:deleteNumber()
    self.scoreItemCount = math.floor(self.scoreItemCount / 10)
    self:updateScoreCount()
end

-- 数字键盘清空
function ZaixqyDlg:deleteAllNumber(key)
    self.scoreItemCount = 0
    self:updateScoreCount()
end

-- 数字键盘插入数字
function ZaixqyDlg:insertNumber(num)
    if self.isStartInput then
        self.scoreItemCount = 0
        self.isStartInput = false
    end
    if num == "00" then
        self.scoreItemCount = self.scoreItemCount * 100
    elseif num == "0000" then
        self.scoreItemCount = self.scoreItemCount * 10000
    else
        self.scoreItemCount = self.scoreItemCount * 10 + num
    end

    local ret = 0
    if self.scoreItem.name ~= CHS[6000500] then
        local count = InventoryMgr:getCountCanAddToBag(self.scoreItem.name, self.scoreItemCount, true)
        if count < self.scoreItemCount then
            self.scoreItemCount = count
            ret = 1
        end
    end

    if self.scoreItem and self.scoreItemCount > self.scoreItem.amount then
        self.scoreItemCount = self.scoreItem.amount
        ret = 2
    end

    if self.scoreItemCount >= 100 then
        self.scoreItemCount = 100
        ret = 3
    end
    if ret == 1 then
        gf:ShowSmallTips(CHS[4200300])
    elseif ret == 2 then
        gf:ShowSmallTips(CHS[4200301])
    elseif ret == 3 then
        gf:ShowSmallTips(CHS[4200325])
    end
    self:updateScoreCount()
end

function ZaixqyDlg:onRewardIconButton(sender, eventType)
    local reward = sender.data.reward
    local rect = self:getBoundingBoxInWorldSpace(sender)

    -- 奖励格式
    if reward then
        local rewardInfo = RewardContainer:getRewardInfo(reward)
        local dlg
        if rewardInfo.desc then
            dlg = DlgMgr:openDlg("BonusInfoDlg")
        else
            dlg = DlgMgr:openDlg("BonusInfo2Dlg")
        end
        rewardInfo.limted = sender.data.limted
        dlg:setRewardInfo(rewardInfo)
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
        return
    end

    -- 道具
    local item = sender.data
    if item then
        local dlg = DlgMgr:openDlg("ItemInfoDlg")
        item["isGuard"] = InventoryMgr:getIsGuard(item.name)
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
    end
end

-- 设置回归特惠
function ZaixqyDlg:setBuyPanel(data)
    local list = self:resetListView("GoodsListView", nil, nil, "ZaixqyBuyPanel")

    list.isLoad = true

    local height = 0
    local flag = 0
    for i = 1, data.count do
        local panel = self.buyPanel:clone()

        self:setUnitBuyPanel(data[i], i, panel)
        list:pushBackCustomItem(panel)

        if data[i].status == 1 and flag == 0 then
            height = height + panel:getContentSize().height
        else
            flag = 1
        end
    end
    list:refreshView()
    local y = list:getContentSize().height - list:getInnerContainer():getContentSize().height + height
    list:getInnerContainer():setPositionY(y)
end

function ZaixqyDlg:setUnitBuyPanel(data, order, panel)

    -- 第一个是购买会员
    self:setCtrlVisible("GoodListPanel1", order == 1, panel)

    local disPanel
    if order == 1 then
        disPanel = self:getControl("GoodListPanel1", nil, panel)
        self:setCtrlVisible("GoodListPanel2", false, panel)
        self:setCtrlVisible("GoodListPanel3", false, panel)
    else
        local expValue = string.match(data.reward_desc, CHS[4400033])
        if expValue and tonumber(expValue) == 0 then
            self:setCtrlVisible("GoodListPanel2", false, panel)
            self:setCtrlVisible("GoodListPanel3", true, panel)
            disPanel = self:getControl("GoodListPanel3", nil, panel)
        else
            self:setCtrlVisible("GoodListPanel2", true, panel)
            self:setCtrlVisible("GoodListPanel3", false, panel)
            disPanel = self:getControl("GoodListPanel2", nil, panel)
    end
    end

    local classList = TaskMgr:getRewardList(data.reward_desc)

    for i = 1, #classList[1] do
        local  info = RewardContainer:getRewardInfo(classList[1][i])
        local infoPanel = self:getControl("ItemPanel" .. i, nil, disPanel)
        if infoPanel then
            -- 如果exp == 0，用的 disPanel 中时没有该panel
        local path = TaskMgr:getSamllImage(info.basicInfo[1])
        self:setImagePlist("ItemImage", path, infoPanel)

        if info.basicInfo[1] == CHS[3000049] then
            self:setLabelText("ItemLabel", string.format("%s：%s" .. CHS[5410102], info.basicInfo[1], info.basicInfo[2]), infoPanel)
        else
            if GameMgr.isIOSReview and string.match(info.basicInfo[1], CHS[4300341]) then
                info.basicInfo[2] = CHS[4300340]
            end
            self:setLabelText("ItemLabel", string.format("%s：%s", info.basicInfo[1], info.basicInfo[2]), infoPanel)
        end
    end
    end

    -- 金钱
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, data.coin, false, LOCATE_POSITION.MID, 21, panel)

    -- 第几天
    self:setLabelText("TimesLabel", string.format(CHS[4300274], gf:changeNumber(data.day)), panel)

    self:setButtonStateBuy(data.status, panel)

    panel.data = data
end

function ZaixqyDlg:setButtonStateBuy(status, rewardPanel)
    self:setCtrlVisible("GotImage", status == 1, rewardPanel)
    self:setCtrlVisible("BuyButton", status == 0, rewardPanel)
    self:setCtrlVisible("NoneImage", status == 2, rewardPanel)
end

-- 设置7日礼包
function ZaixqyDlg:setSevenDaysGift(data)
    local list = self:resetListView("GoodsListView", nil, nil, "ZaixqySevenDaysGiftPanel")

    list.isLoad = true
    local height = 0
    local flag = 0
    for i = 1, data.count do
        local panel = self:createOneRewardPanel(data[i], i)
        list:pushBackCustomItem(panel)

        if data[i].status == 1 and flag == 0 then
            height = height + panel:getContentSize().height
        else
            flag = 1
        end
    end

    list:refreshView()
    local y = list:getContentSize().height - list:getInnerContainer():getContentSize().height + height
    list:getInnerContainer():setPositionY(y)
end

function ZaixqyDlg:setEquipData()
    local equips = GiftMgr:getZaixqyEuipByAttrib(self.equip_att)
    if not equips then
        GiftMgr:queryZaixqyEquip(self.equip_att)
        return
    end

    for i = 1, 4 do
        local unitPanel = self:getControl("ItemImagePanel" .. i, nil, self.equipPanel)
        local equip = equips[i]
        unitPanel.equip = equip
        self:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name), unitPanel)
        self:setNumImgForPanel(unitPanel, ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)


        local imageCtl = self:getControl("ItemImage", nil, unitPanel)
        if equip and InventoryMgr:isTimeLimitedItem(equip) then
            InventoryMgr:removeLogoBinding(imageCtl)
            InventoryMgr:addLogoTimeLimit(imageCtl)
        elseif equip and InventoryMgr:isLimitedItem(equip) then
            InventoryMgr:removeLogoTimeLimit(imageCtl)
            InventoryMgr:addLogoBinding(imageCtl)
        else
            InventoryMgr:removeLogoTimeLimit(imageCtl)
            InventoryMgr:removeLogoBinding(imageCtl)
        end
    end
end

function ZaixqyDlg:setButtonStateGift(status, rewardPanel)
    self:setCtrlVisible("GotImage", status == 1, rewardPanel)
    self:setCtrlVisible("GetButton", status == 0, rewardPanel)
    self:setCtrlVisible("NoneImage", status == 2, rewardPanel)
end

function ZaixqyDlg:createOneRewardPanel(rewardInfo, days)
    local rewardPanel = self.giftPanel:clone()

    -- 设置装备
    if days == 1 then
        rewardPanel = self.fistGiftPanel:clone()
        self.equipPanel = rewardPanel
        self:setEquipData()
        self:getControl("GetButton", nil, rewardPanel).day = rewardInfo.day
        self:setLabelText("TimesLabel", days, rewardPanel)

        self:setButtonStateGift(rewardInfo.status, rewardPanel)
        -- 第几天
        self:setLabelText("TimesLabel", string.format(CHS[4300274], gf:changeNumber(days)), rewardPanel)
        return rewardPanel
    end

        -- 第几天
    self:setLabelText("TimesLabel", string.format(CHS[4300274], gf:changeNumber(days)), rewardPanel)
    self:getControl("GetButton", nil, rewardPanel).day = rewardInfo.day
    -- 设置物品图标
    local itemListPanel = self:getControl("ItemListPanel", Const.UIPanel, rewardPanel)
    itemListPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(rewardInfo.reward_desc, itemListPanel:getContentSize(), nil, nil, true, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setScale(0.8)
    rewardContainer:setPosition(10, itemListPanel:getContentSize().height / 2)
    itemListPanel:addChild(rewardContainer)
    self:setButtonStateGift(rewardInfo.status, rewardPanel)
    return rewardPanel
end

function ZaixqyDlg:MSG_COMEBACK_COIN_SHOP_ITEM_LIST(data)
    if GameMgr.isIOSReview then
        if string.match(data[1].reward_desc, CHS[6000202]) then
            data[1].reward_desc = string.gsub(data[1].reward_desc, CHS[6000202], CHS[3000244])
        end
    end

    local list = self:getControl("GoodsListView", nil, "ZaixqyBuyPanel")
    if list.isLoad then
        -- 刷新按钮
        local items = list:getItems()

        for _, panel in pairs(items) do
            self:setButtonStateBuy(data[_].status, panel)
        end
    else
        self:setBuyPanel(data)
    end
end

function ZaixqyDlg:MSG_COMEBACK_SEVEN_GIFT_ITEM_LIST(data)
    local list = self:getControl("GoodsListView", nil, "ZaixqySevenDaysGiftPanel")
    if list.isLoad then
        -- 刷新按钮
        local items = list:getItems()

        for _, panel in pairs(items) do
            self:setButtonStateGift(data[_].status, panel)
        end
    else
        self:setSevenDaysGift(data)
    end

    -- 不为空表示已经领取了
    if data.fetch_equip_type ~= "" then
        for i = 1, 4 do
            local ctrl = self:getControl("CheckBox", Const.UICheckBox, "TypePanel" .. i)
            self:setCheck("CheckBox", false, "TypePanel" .. i)
            ctrl:setEnabled(false)
        end

        for i, key in pairs(EQUIP_ATTRIB) do
            if key == data.fetch_equip_type then
                self:setCheck("CheckBox", true, "TypePanel" .. i)
                self.equip_att = key
            end
        end

        self:setEquipData()
    end
end

-- 收到装备了
function ZaixqyDlg:MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST(data)
    if not self.equipPanel then return end
    if self.equip_att and self.equip_att ~= data.equip_attrib then return end
    self:setEquipData()
end


return ZaixqyDlg
