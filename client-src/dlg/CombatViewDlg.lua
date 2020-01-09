-- CombatViewDlg.lua
-- Created by songcw June/9/2015
-- 战斗查看界面

local CombatViewDlg = Singleton("CombatViewDlg", Dialog)

-- isPlist资源类型，1为plist中读取，未配置dlg则需要特殊处理,iconFlag用于判断该图标是否激活  remoRelationRed需要删除关联的小红点
local ViewsButton = {
    -- 背包
    {icon = ResMgr.ui.main_icon5, isPlist = 1, dlg = "BagDlg", iconFlag = 1, ctrlName = "BagBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "BagButton"},},
    -- 装备
    {icon = ResMgr.ui.main_icon30, isPlist = 1, dlg = "EquipmentTabDlg", iconFlag = 4, ctrlName = "EquipBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "EquipButton"},},
    -- 首饰
    {icon = ResMgr.ui.main_icon29, isPlist = 1, dlg = "JewelryUpgradeDlg", iconFlag = 4, ctrlName = "JewelryBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "JewelryButton"},},
    -- 法宝
    {icon = ResMgr.ui.main_icon32, isPlist = 1, dlg = "ArtifactTabDlg", iconFlag = 4, ctrlName = "ArtifactBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "ArtifactButton"},},
    -- 在线商城
    {icon = ResMgr.ui.main_icon14, isPlist = 1, dlg = "OnlineMallTabDlg", iconFlag = 11, ctrlName = "OnlineMallBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "MallButton"},},
    -- 集市
    {icon = ResMgr.ui.main_icon1, isPlist = 1, iconFlag = 13, dlg = "MarketBuyDlg", ctrlName = "MarketBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "MarketButton"},},
    -- 活动
    {icon = ResMgr.ui.main_icon2, isPlist = 1, iconFlag = 18, ctrlName = "ActiveBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "ActivityButton"}},
    -- 任务
    {icon = ResMgr.ui.main_icon22, isPlist = 1, dlg = "TaskDlg", ctrlName = "TaskBtn", remoRelationRed = {dlg = "MissionDlg", ctrl = "MissionCheckBox"}},
    -- 队伍
    {icon = ResMgr.ui.main_icon21, isPlist = 1, dlg = "TeamDlg", ctrlName = "TeamBtn", remoRelationRed = {dlg = "MissionDlg", ctrl = "TeamCheckBox"}, limitFunc = "onTeamLimit"},
    -- 刷道
    {icon = ResMgr.ui.main_icon4, isPlist = 1, dlg = "GetTaoDlg", iconFlag = 17, ctrlName = "TaoBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "ShuadaoButton"}},
    -- 练功
    {icon = ResMgr.ui.main_icon13, isPlist = 1, dlg = "PracticeDlg", iconFlag = 16, ctrlName = "PracticeBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "LiangongButton"}},
    -- 设置
    {icon = ResMgr.ui.main_icon8, isPlist = 1, dlg = "SystemConfigDlg", ctrlName = "SysBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "SystemButton"}},
    -- 帮派
    {icon = ResMgr.ui.main_icon3, isPlist = 1, iconFlag = 3, ctrlName = "PartyBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "PartyButton"}},
    -- 排行榜
    {icon = ResMgr.ui.main_icon6, isPlist = 1, dlg = "RankingListDlg", iconFlag = 10, ctrlName = "RankingBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "RankingListButton"}},
    -- 珍宝
    {icon = ResMgr.ui.main_icon27, isPlist = 1, ctrlName = "BaoBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "TreasureButton"}, },
    -- 拍卖
    {icon = ResMgr.ui.main_icon26, isPlist = 1, dlg = "MarketAuctionDlg", ctrlName = "AuctionBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "AuctionButton"},},
    -- 货站
    {icon = ResMgr.ui.main_icon52, isPlist = 1, ctrlName = "TradingSpotBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "TradingSpotButton"}, },
    -- 聚宝
    {icon = ResMgr.ui.main_icon31, isPlist = 1, ctrlName = "JuBaoBtn", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "JubaoButton"}, },
    -- 居所
    {icon = ResMgr.ui.main_icon40, iconFlag = 25, isPlist = 1, ctrlName = "HomeButton", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "HomeButton"}, },
    -- 成就
    {icon = ResMgr.ui.main_icon_achieve, iconFlag = 27, isPlist = 0, dlg = "AchievementListDlg", ctrlName = "AchievementBtn", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "AchievementButton"},  },
    -- 社区
    {icon = ResMgr.ui.main_icon43, iconFlag = { 28, 30 }, isPlist = 1, dlg = "CommunityDlg", ctrlName = "CommunityButton", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "CommunityButton"}},
    -- 寻缘
    {icon = ResMgr.ui.main_icon50, iconFlag = 31, isPlist = 1, dlg = "MatchmakingDlg", ctrlName = "FindLoveButton", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "FindLoveButton"}},
    -- 纪念册
    {icon = ResMgr.ui.main_icon51, iconFlag = 32, isPlist = 1, dlg = "WeddingBookDlg", ctrlName = "MarryBookButton", remoRelationRed = {dlg = "GameFunctionDlg", ctrl = "MarryBookButton"}},
    -- 周年庆
    {icon = ResMgr.ui.main_icon34, iconFlag = 23, isPlist = 1, dlg = "AnniversaryTabDlg", ctrlName = "AnniversaryButton", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "AnniversaryButton"}},
    -- 福利
    {icon = ResMgr.ui.main_icon10, iconFlag = 15, isPlist = 1, dlg = "WelfareDlg", ctrlName = "WelfareButton", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "GiftsButton"},},

    -- 好声音
    {icon = ResMgr.ui.main_icon_goodvoice,isPlist = 0, iconFlag = 35, dlg = "GoodVoiceExhibitionDlg", ctrlName = "GoodVoiceButton", remoRelationRed = {dlg = "SystemFunctionDlg", ctrl = "GoodVoiceButton"},},
}

-- 按钮尺寸
CombatViewDlg.buttonSize = {}

-- 已经激活的图标
CombatViewDlg.activeViewButtons = {}

local MOVE_DISTANCE = 80
local PAGECHECKBOX_SPACE = 20
local PAGECHECKBOX_HEIGHT = 15

local REMEMBER_TIME = (60 * 2 + 30) * 1000

local rowMax = 4
local colMax = 3
local margin = 6
local maxButtonEveryPage = 12

-- 打开帮派界面
local function openPartyInfoDlg()
    EventDispatcher:removeEventListener('MSG_PARTY_INFO', openPartyInfoDlg)

    local last = DlgMgr:getLastDlgByTabDlg('PartyInfoTabDlg') or 'PartyInfoDlg'
    DlgMgr:openDlg(last)
end
function CombatViewDlg:init()
    self:setFullScreen()
    self:bindListener("HideDialogButton", self.onHideDialogButton)
    self:bindListener("ShowDialogButton", self.onShowDialogButton)
    self:bindListener("SystemButton", self.onSystemButton)
    local button = self:getControl("SystemButton")
    self.button = button:clone()
    self.button:retain()
    button:removeFromParent()

    local pageCheckBox = self:getControl("PageCheckBox")
    self.pageCheckBox = pageCheckBox:clone()
    self.pageCheckBox:retain()
    pageCheckBox:removeFromParent()

    self.buttonSize = self.button:getContentSize()
    self.curSelectIndex = self.curSelectIndex or 0

    self.isMove = false
    self.activeViewButtons = {}
    self.activeViewButtons = self:getRealViewButton()
    self:setBodySize()
    self:initButtons()

    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function CombatViewDlg:getRealViewButton()
    for i, button in pairs(ViewsButton) do

        if button.iconFlag == nil then
            if button.ctrlName == "JuBaoBtn" then
                if TradingMgr:getTradingEnable() and not DeviceMgr:isReviewVer() then
                    self.activeViewButtons[i] = button
                end
            elseif button.ctrlName == "BaoBtn" then
                if MarketMgr:isShowGoldMarket() then
                    self.activeViewButtons[i] = button
                end
            elseif button.ctrlName == "TradingSpotBtn" then
                if GuideMgr:isIconExist(34) and TradingSpotMgr:isTradingSpotEnable() then
                    self.activeViewButtons[i] = button
                end
            else
                self.activeViewButtons[i] = button
            end
        else
            if GuideMgr:isIconExist(button.iconFlag) then
                if button.dlg == "EquipmentTabDlg" then
                     if Me:queryBasicInt("level") >= Const.SHOW_EQUIP_ICON_MIN_LEVEL then
                        self.activeViewButtons[i] = button
                     end

                elseif button.dlg == "JewelryUpgradeDlg" then
                    if Me:queryBasicInt("level") >= Const.SHOW_JEWELRY_ICON_MIN_LEVEL then
                        self.activeViewButtons[i] = button
                    end

                elseif button.dlg == "ArtifactTabDlg" then
                    if Me:getLevel() >= Const.SHOW_ARTIFACT_ICON_MIN_LEVEL then
                        self.activeViewButtons[i] = button
                    end
                else
                    self.activeViewButtons[i] = button
                end
            end
        end
    end

    return self.activeViewButtons
end

function CombatViewDlg:setBodySize()
    local panel = self:getControl("MainBodyPanel")
    local pageView = self:getControl("PageView")
    local mainBodySize = panel:getContentSize()
    local count = 0
    for i, info in pairs(self.activeViewButtons) do
        count = count + 1
    end

    local col = colMax, math.floor((count - 1) / rowMax + 1)
    local row = math.min(rowMax, count)

    local totalMargin = 0
    if col > 1 then totalMargin = margin * (col - 1) end

    local height = mainBodySize.height + (col - 1) * self.buttonSize.height + totalMargin
    if count > maxButtonEveryPage then
        -- 超过一页需要显示分页符，分页符占据一定高度
        height = height + PAGECHECKBOX_HEIGHT
    end

    panel:setContentSize(mainBodySize.width + (row - 1) * self.buttonSize.width + 10, height)
    panel:setPositionY( panel:getPositionY() - panel:getContentSize().height + mainBodySize.height + 5)

    local panelSize = panel:getContentSize()
    pageView:setContentSize(panelSize.width - 12, panelSize.height)
    pageView:setPositionX(6)
end

function CombatViewDlg:initButtons()
    local panel = self:getControl("MainBodyPanel")
    local pageView = self:getControl("PageView")
    pageView:setMoveDistanceToChangePage(MOVE_DISTANCE)
    pageView:setClippingEnabled(true)
    pageView:setTouchEnabled(true)
    pageView:stopAllActions()
    pageView:removeAllPages()

    local panelSize = panel:getContentSize()
    local pagePanel = ccui.Layout:create()
    pagePanel:setContentSize(panelSize)

    local count = 0
    for i, info in pairs(self.activeViewButtons) do
        count = count + 1
    end



    local index = 1
    local pageNumber = 1
    -- 创建页面
    for i, info in pairs(self.activeViewButtons) do
        local button = self.button:clone()
        button:setTag(i)
        button:loadTextureNormal(info.icon, info.isPlist)
        button:setName(info.ctrlName)
        -- button:setAnchorPoint(0, 0)
        local col = math.floor((index - 1) / rowMax + 1)
        local row = index % rowMax
        if row == 0 then row = rowMax end
        local contentSize = button:getContentSize()

        button:setPosition(margin * 0.5 + (row - 1) * (self.buttonSize.width + margin) + contentSize.width / 2, panelSize.height - (margin + self.buttonSize.height) * col + contentSize.height / 2)
        pagePanel:addChild(button)
        self:bindTouchEndEventListener(button, self.onButton)

        index = index + 1

        if index > maxButtonEveryPage and count > maxButtonEveryPage and pageNumber * maxButtonEveryPage < count then
            pageView:addPage(pagePanel)
            pagePanel = ccui.Layout:create()
            pagePanel:setContentSize(panelSize)
            index = 1
            pageNumber = pageNumber + 1
        end
    end

    pageView:addPage(pagePanel)

    if pageNumber > 1 then
        -- 创建分页标签
        local checkBoxList = {}
        for i = 1, pageNumber do
            local pageNumberCell = self.pageCheckBox:clone()
            panel:addChild(pageNumberCell)

            local space = PAGECHECKBOX_SPACE
            local panelWidth = panel:getContentSize().width
            local allPageNumberCellWidth = (pageNumber - 1) * space
            local posx = panelWidth / 2 - allPageNumberCellWidth / 2 + (i - 1) * space
            local posy = PAGECHECKBOX_HEIGHT
            pageNumberCell:setPosition(posx, posy)
            pageNumberCell:setTag(i)
            pageNumberCell:setTouchEnabled(false)
            table.insert(checkBoxList, pageNumberCell)
        end

        -- 初始化分页选择
        -- 2分30秒内保存分页选择项
        if self:isOutLimitTime("lastTime", REMEMBER_TIME) then
            self.curSelectIndex = 0
        end

        performWithDelay(pageView, function() pageView:scrollToPage(self.curSelectIndex) end, 0)

        -- 绑定分页控件和分页标签
        pageView:addEventListener(function(sender, eventType)
            local index = pageView:getCurPageIndex()
            self.curSelectIndex = index
            if eventType == ccui.PageViewEventType.turning then
                for i = 1, pageNumber do
                    local checkBox = checkBoxList[i]
                    if index + 1  == i then
                        checkBox:setSelectedState(true)
                    else
                        checkBox:setSelectedState(false)
                    end
                end
            end
        end)
    end

    local newSize = panel:getContentSize()
    self.moveSizeX = newSize.width
    panel:setPositionX(0)

    self:updateLayout("MainBodyPanel")

    local viewX, viewY = panel:getPosition()
    local movePanel = self:getControl("MovePanel")
    movePanel:setPositionX(viewX + newSize.width)
    self:setCtrlVisible("HideDialogButton", false)
    self:setCtrlVisible("ShowDialogButton", true)
    panel:setVisible(false)
    self:updateLayout("MovePanel")

    self.root:setPositionX(self.root:getPositionX() - self.moveSizeX)
end

function CombatViewDlg:getRowIndex(index)
    if index < rowMax + 1 then return 1 end
    return math.floor((index - 1) / rowMax + 1)
end

function CombatViewDlg:onHideDialogButton(sender, eventType)
    if self.isMove then return end
    local panel = self:getControl("MainBodyPanel")
    local movePanel = self:getControl("MovePanel")

    self.isMove = true
    self:setCtrlVisible("HideDialogButton", false)
    self:setCtrlVisible("ShowDialogButton", true)

    local hideAction = cc.MoveBy:create(0.15, cc.p(-self.moveSizeX, 0))
    local endAction = cc.CallFunc:create(function()
        self.isMove = false
        panel:setVisible(false)
    end)

    local MoveAction = cc.Sequence:create(hideAction, endAction)

    self.root:runAction(MoveAction)
end

function CombatViewDlg:onShowDialogButton(sender, eventType)
    if self.isMove then return end
    local panel = self:getControl("MainBodyPanel")
    local movePanel = self:getControl("MovePanel")

    self.isMove = true
    self:setCtrlVisible("HideDialogButton", true)
    self:setCtrlVisible("ShowDialogButton", false)
    panel:setVisible(true)
    local hideAction = cc.MoveBy:create(0.15, cc.p(self.moveSizeX, 0))
    local endAction = cc.CallFunc:create(function()
        self.isMove = false
    end)

    local MoveAction = cc.Sequence:create(hideAction, endAction)

    self.root:runAction(MoveAction)
end

function CombatViewDlg:onButton(sender, eventType, data, isRedDotRemoved)
    local tag = sender:getTag()

    if ViewsButton[tag] and ViewsButton[tag]["limitFunc"] and self[ViewsButton[tag]["limitFunc"]]() then
        return
    end

    if ViewsButton[tag] and ViewsButton[tag].remoRelationRed then
        RedDotMgr:removeOneRedDot(ViewsButton[tag].remoRelationRed.dlg, ViewsButton[tag].remoRelationRed.ctrl)

        local ctrlName = ViewsButton[tag].ctrlName

        if ctrlName == "MarketBtn" or ctrlName == "BaoBtn"or ctrlName == "AuctionBtn"or ctrlName == "JuBaoBtn" or ctrlName == "TradingSpotBtn" then
            -- 集市、珍宝、聚宝斋、拍卖、货站。如果都没有小红点了，则外层的交易也要去掉小红点
            local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
            if dlg then
                local marketRed = dlg:getControl("MarketButton"):getChildByTag(Const.TAG_RED_DOT)
                local treasureRed = dlg:getControl("TreasureButton"):getChildByTag(Const.TAG_RED_DOT)
                local AuctionRed = dlg:getControl("AuctionButton"):getChildByTag(Const.TAG_RED_DOT)
                local jubaoRed = dlg:getControl("JubaoButton"):getChildByTag(Const.TAG_RED_DOT)
                local tradingSpotRed = dlg:getControl("TradingSpotButton"):getChildByTag(Const.TAG_RED_DOT)

                if not marketRed and not treasureRed and not AuctionRed and not jubaoRed and not tradingSpotRed then
                    RedDotMgr:removeOneRedDot("SystemFunctionDlg", "ShowTradeButton")
                end
            end
        elseif ctrlName == "EquipBtn" or ctrlName == "JewelryBtn" or ctrlName == "ArtifactBtn" then
            -- 装备、首饰、法宝
            local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
            if dlg then
                local equipRed = dlg:getControl("EquipButton"):getChildByTag(Const.TAG_RED_DOT)
                local jewelryRed = dlg:getControl("JewelryButton"):getChildByTag(Const.TAG_RED_DOT)
                local artifactBtnRed = dlg:getControl("ArtifactButton"):getChildByTag(Const.TAG_RED_DOT)

                if not equipRed and not jewelryRed and not artifactBtnRed then
                    RedDotMgr:removeOneRedDot("GameFunctionDlg", "ForgeButton")
                end
            end
        elseif ctrlName == "SysBtn" or ctrlName == "PartyBtn" or ctrlName == "HomeButton" or ctrlName == "AchievementBtn" then
            -- 设置、帮派、居所、成就
            local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
            if dlg then
                local partyRed = dlg:getControl("PartyButton"):getChildByTag(Const.TAG_RED_DOT)
                local guardRed = dlg:getControl("GuardButton"):getChildByTag(Const.TAG_RED_DOT)
                local sysRed = dlg:getControl("SystemButton"):getChildByTag(Const.TAG_RED_DOT)
                local forgeRed = dlg:getControl("ForgeButton"):getChildByTag(Const.TAG_RED_DOT)
                local homeRed = dlg:getControl("HomeButton"):getChildByTag(Const.TAG_RED_DOT)
                local achievementRed = dlg:getControl("AchievementButton"):getChildByTag(Const.TAG_RED_DOT)
                local socailRed = dlg:getControl("SocialButton"):getChildByTag(Const.TAG_RED_DOT)
                local watchCenterRed = dlg:getControl("WatchCenterButton"):getChildByTag(Const.TAG_RED_DOT)

               -- if not partyRed and not guardRed and not sysRed and not forgeRed
               --     and not homeRed and not achievementRed and not socailRed and not watchCenterRed then
               --     RedDotMgr:removeOneRedDot("GameFunctionDlg", "StatusButton1")
               --     RedDotMgr:removeOneRedDot("GameFunctionDlg", "StatusButton2")
               --     RedDotMgr:removeOneRedDot("GameFunctionDlg", "StatusButton3")
               -- end
            end
        elseif ctrlName == "CommunityButton" or ctrlName == "MarryBookButton" or ctrlName == "FindLoveButton" then
            -- 社区、寻缘、纪念册
            local dlg = DlgMgr:getDlgByName("GameFunctionDlg")
            if dlg then
                local findLoveRed = dlg:getControl("FindLoveButton"):getChildByTag(Const.TAG_RED_DOT)
                local marryBookRed = dlg:getControl("MarryBookButton"):getChildByTag(Const.TAG_RED_DOT)
                local communityRed = dlg:getControl("CommunityButton"):getChildByTag(Const.TAG_RED_DOT)
                local teachRed = dlg:getControl("TeachButton"):getChildByTag(Const.TAG_RED_DOT)

               -- if not findLoveRed and not marryBookRed and not communityRed and not teachRed then
               --     RedDotMgr:removeOneRedDot("GameFunctionDlg", "SocialButton")
               -- end
            end
        end
    end

    if ViewsButton[tag] and ViewsButton[tag].remoRelationRed then
        local ctrlName = ViewsButton[tag].ctrlName

        if ctrlName == "TaskBtn" or ctrlName == "TeamBtn" then
            DlgMgr:openTabDlg(ViewsButton[tag].dlg)
        else
            local info = ViewsButton[tag].remoRelationRed
            DlgMgr:sendMsg(info.dlg, "on" .. info.ctrl, sender, eventType, data, isRedDotRemoved)
            return
        end
    end
end

function CombatViewDlg:onTeamLimit()
    if MapMgr:isInYuLuXianChi() then
        gf:ShowSmallTips(CHS[5450463])
        return true
    end

    return false
end

function CombatViewDlg:showParty()
    DlgMgr:sendMsg("GameFunctionDlg", "onPartyButton")
end

function CombatViewDlg:cleanup()
    if self.button then
        self.button:release()
        self.button = nil
    end

    self:releaseCloneCtrl("pageCheckBox")

    self:setLastOperTime("lastTime", gfGetTickCount())
    EventDispatcher:removeEventListener('MSG_PARTY_INFO', openPartyInfoDlg)
end

return CombatViewDlg
