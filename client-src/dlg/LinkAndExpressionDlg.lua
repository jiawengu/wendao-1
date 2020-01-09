-- LinkAndExpressionDlg.lua
-- Created by zhengjh Jun/2/2015
-- 链接 表情 常用语

local LinkAndExpressionDlg = Singleton("LinkAndExpressionDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local PageTag = require ("ctrl/RadioPageTag")
local json = require("json")
local MALE = "1"
local FEMALE = "2"
local TRADING_SPOT_ITEM_CFG = require (ResMgr:getCfgPath("TradingSpotItemCfg.lua"))

local CONST_DATA =
{
    ExpressionNumber = Const.NORMALBROW_ENDINDEX - Const.NORMALBROW_STARTINDEX + 1,       -- 普通表情总的个数
    ExpressionFrameNumber = 20,  -- 每个表情最多的帧数
    VipExpressionNumber = Const.VIPBROW_ENDINDEX - Const.VIPBROW_STARTINDEX + 1,    -- vip 表情个数
}

-- 常用短语最多显示22个汉字
local USERFUL_WORLDS_SHOW_LENTH = 44

local PAGECHECKBOX_SPACE = 7
local MOVE_DISTANCE = 80

-- 每个单元格之间的列间距 和行间距
local SPACE_CONFIG =
{
    ["ItemCheckBox"] = {8, 15},
    ["ExpressionCheckBox"] = {0, 0},
    ["PetCheckBox"] = {10, 6},
    ["StatisticsCheckBox"] = {10, 6},
    ["TitleCheckBox"] = {8, 10},
    ["TaskCheckBox"] = {8, 10},
    ["HistoryCheckBox"] = {10, 6},
    ["MarketItemCheckBox"] = {8, 6},
    ["ZhenbaoItemCheckBox"] = {0, 0},
    ["JubaoItemCheckBox"] = {0, 0},
    ["UsefulCheckBox"] = {2, 8},
    ["TradingSpotCheckBox"] = {8, 1},
    ["ChildCheckBox"] = {10, 6},
}

-- 每个面板的行和列
local COUNT_CONFIG =
{
    ["ItemCheckBox"] = {2, 7},
    ["ExpressionCheckBox"] = {3, 9},
    ["PetCheckBox"] = {2, 2},
    ["StatisticsCheckBox"] = {2, 2},
    ["TitleCheckBox"] = {3, 2},
    ["TaskCheckBox"] = {3, 2},
    ["HistoryCheckBox"] = {2, 2},
    ["MarketItemCheckBox"] = {2, 2},
    ["ZhenbaoItemCheckBox"] = {2, 2},
    ["JubaoItemCheckBox"] = {2, 2},
    ["UsefulCheckBox"] = {3, 2},
    ["TradingSpotCheckBox"] = {3, 3},
    ["ChildCheckBox"] = {2, 2},
}

local Config_Data =
{
    ItemCheckBox = "ItemPanel",
    PetCheckBox = "PetPanel",
    StatisticsCheckBox = "GuardPanel",
    TaskCheckBox = "TaskPanel",
    SkillCheckBox = "SkillPanel",
    TitleCheckBox = "TitlePanel",
    ExpressionCheckBox = "ExpressionPanel",
    HistoryCheckBox = "HistoryPanel",
    MarketItemCheckBox = "MarketItemPanel",
    ZhenbaoItemCheckBox = "ZhenbaoItemPanel",
    JubaoItemCheckBox = "JubaoItemPanel",
    UsefulCheckBox = "UsefulPanel",
    TradingSpotCheckBox = "TradingSpotItemPanel",
    ChildCheckBox = "PetPanel",
}

local TITLE_BUTTON =
{
    [1] = {ctrName = "ExpressionCheckBox", labelStr = CHS[6000463], icon = ResMgr.ui.button_expression, type = "CheckBox"}, -- 问道表情
    [2] = {ctrName = "ItemCheckBox", labelStr = CHS[6000466], icon = ResMgr.ui.button_item, type = "CheckBox"}, -- 道 具
    [3] = {ctrName = "UsefulCheckBox", labelStr = CHS[7100205], icon = ResMgr.ui.button_useful, type = "CheckBox"}, -- 常用短语
    [4] = {ctrName = "HistoryCheckBox", labelStr = CHS[6000464], icon = ResMgr.ui.button_history, type = "CheckBox"}, -- 输入历史
    [5] = {ctrName = "ShakeButton", labelStr = CHS[4101023], icon = ResMgr.ui.button_shake, type = "Button"}, -- 震动
    [6] = {ctrName = "CallButton", labelStr = CHS[5400299], icon = ResMgr.ui.button_call, type = "Button"}, -- 呼 叫
    [7] = {ctrName = "PetCheckBox", labelStr = CHS[6000467], icon = ResMgr.ui.button_pet, type = "CheckBox"}, -- 宠 物
    [8] = {ctrName = "SkillCheckBox", labelStr = CHS[6000470], icon = ResMgr.ui.button_skill, type = "CheckBox"}, -- 技 能
    [9] = {ctrName = "CharButton", labelStr = CHS[6000465], icon = ResMgr.ui.button_char, type = "Button"}, -- 输入历史
    [10] = {ctrName = "StatisticsCheckBox", labelStr = CHS[6000468], icon = ResMgr.ui.button_statistics, type = "Button"}, -- 今日统计
    [11] = {ctrName = "TaskCheckBox", labelStr = CHS[6000469], icon = ResMgr.ui.button_task, type = "CheckBox"}, -- 任 务
    [12] = {ctrName = "PartyRedBagButton", labelStr = CHS[6000471], icon = ResMgr.ui.button_partyredbag, type = "Button"}, -- 红 包
    [13] = {ctrName = "TitleCheckBox", labelStr = CHS[6000472], icon = ResMgr.ui.button_title, type = "CheckBox"}, -- 称 谓
    [14] = {ctrName = "WatchButton", labelStr = CHS[4100443], icon = ResMgr.ui.button_watch, type = "Button"},   -- 分享赛事
    [15] = {ctrName = "HouseCheckBox", labelStr = CHS[2100095], icon = ResMgr.ui.button_house, type = "Button"}, -- 居所展示
    [16] = {ctrName = "ChildCheckBox", labelStr = CHS[7120213], icon = ResMgr.ui.kid_logo_image, type = "CheckBox"}, -- 娃 娃
    [17] = {ctrName = "MarketItemCheckBox", labelStr = CHS[5410121], icon = ResMgr.ui.button_marketitem, type = "CheckBox"}, -- 集市
    [18] = {ctrName = "ZhenbaoItemCheckBox", labelStr = CHS[5410122], icon = ResMgr.ui.button_zhenbaoitem, type = "CheckBox"}, -- 珍宝
    [19] = {ctrName = "JubaoItemCheckBox", labelStr = CHS[5410123], icon = ResMgr.ui.button_jubaoitem, type = "CheckBox"}, -- 聚宝斋
    [20] = {ctrName = "TradingSpotCheckBox", labelStr = CHS[7190483], icon = ResMgr.ui.button_tradingspot, type = "CheckBox"}, -- 货品
    [21] = {ctrName = "TradingSpotSlnButton", labelStr = CHS[7190487], icon = ResMgr.ui.button_tradingspot, type = "Button"}, -- 买入方案
}

function LinkAndExpressionDlg:init()

    -- 屏幕做等比缩放
    local winSize = self:getWinSize()
    local scale =  (winSize.width / Const.UI_SCALE) / self.root:getContentSize().width
    self.root:setScale(scale)
    self.root:setPosition(Const.WINSIZE.width / Const.UI_SCALE / 2 + winSize.x, self.root:getContentSize().height * scale / 2 + winSize.oy * 2)

    self:bindListener("SpaceButton", self.onSpaceButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("WordButton", self.onWordButton)

    self.typeCheck = self:getControl("TypeCheckBox")
    self.typeCheck:retain()
    self.typeCheck:removeFromParent()

    self.typeButton = self:getControl("TypeButton")
    self.typeButton:retain()
    self.typeButton:removeFromParent()

    self.itemCell = self:getControl("SingleItemPanel", Const.UIPanel)
    self.itemCell:retain()
    self.itemCell:removeFromParent()

    self.petCell = self:getControl("SinglePetPanel", Const.UIPanel)
    self.petCell:retain()
    self.petCell:removeFromParent()

    self.guardCell = self:getControl("SingleGuardPanel", Const.UIPanel)
    self.guardCell:retain()
    self.guardCell:removeFromParent()

    self.taskCell = self:getControl("SingleTaskPanel", Const.UIPanel)
    self.taskCell:retain()
    self.taskCell:removeFromParent()

    self.titleCell = self:getControl("SingleTitlePanel", Const.UIPanel)
    self.titleCell:retain()
    self.titleCell:removeFromParent()

    self.historyCell = self:getControl("SingleHistoryPanel", Const.UIPanel)
    self.historyCell:retain()
    self.historyCell:removeFromParent()

    self.marketItemCell = self:retainCtrl("SingleItemPanel", "MarketItemPanel")
    self.zhenbaoItemCell = self:retainCtrl("SingleItemPanel", "ZhenbaoItemPanel")
    self.jubaoItemCell = self:retainCtrl("SingleItemPanel", "JubaoItemPanel")
    self.usefulItemCell = self:retainCtrl("SingleUsefulPanel", "UsefulPanel")
    self.tradingSpotItemCell = self:retainCtrl("SingleItemPanel", "TradingSpotItemPanel")

    self.myJbzCollectItemInfo = {}

    self.showCheckBox = {}
    self:setCtrlVisible("NoItemLabel", false, "JubaoItemPanel")

    self:hookMsg("MSG_MARKET_CHECK_RESULT")
    self:hookMsg("MSG_STALL_MINE")
    self:hookMsg("MSG_GOLD_STALL_GOODS_STATE")
    self:hookMsg("MSG_GOLD_STALL_MINE")
    self:hookMsg("MSG_TRADING_FAVORITE_LIST")
    self:hookMsg("MSG_TRADING_SNAPSHOT")
    self:hookMsg("MSG_TRADING_GOODS_MINE")
    self:hookMsg("MSG_TRADING_ROLE")
    self:hookMsg("MSG_TRADING_SPOT_CARD_GOODS_LIST")
    self:hookMsg("MSG_TRADING_SPOT_DATA")
end

function LinkAndExpressionDlg:initTyepCheckBoxInfo()
    self:initCheckBox()
    self:bindListener("CharButton", self.onCharButton)
    self:bindListener("ShakeButton", self.onShakeButton)
    self:bindListener("StatisticsCheckBox", self.onStatisticsCheckBox)
    self:bindListener("PartyRedBagButton", self.onPartyRedBagButton)
    self:bindListener("WatchButton", self.onWatchButton)
    self:bindListener("HouseCheckBox", self.onHouseCheckBox)
    self:bindListener("CallButton", self.onCallButton)
    self:bindListener("TradingSpotSlnButton", self.onTradingSpotSlnButton)

    self.panelListTable = {}
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, self.showCheckBox.boxs, self.onCheckBox)

    -- vip标签页
    self.vipRadioGroup = RadioGroup.new()
    self.vipRadioGroup:setItems(self, {"CommonCheckBox", "VipCheckBox"}, self.onExpressionCheckBox)

    -- 道具标签页
    self.itemRadioGroup = RadioGroup.new()
    self.itemRadioGroup:setItems(self, {"BagItemCheckBox", "ChangeCardCheckBox"}, self.onItemCheckBox)
    self.itemRadioGroup:selectRadio(1)

    -- 集市道具标签页
    self.marketItemRadioGroup = RadioGroup.new()
    self.marketItemRadioGroup:setItems(self, {"MyGoodsCheckBox", "MyCollectionCheckBox"}, self.onMarketItemCheckBox, "MarketItemPanel")

    -- 珍宝道具标签页
    self.zhenbaoItemRadioGroup = RadioGroup.new()
    self.zhenbaoItemRadioGroup:setItems(self, {"MyGoodsCheckBox", "MyCollectionCheckBox"}, self.onZhenbaoItemCheckBox, "ZhenbaoItemPanel")

    -- 聚宝斋道具标签页
    self.jubaoItemRadioGroup = RadioGroup.new()
    self.jubaoItemRadioGroup:setItems(self, {"MyGoodsCheckBox", "MyCollectionCheckBox"}, self.onJubaoItemCheckBox, "JubaoItemPanel")

    -- 货站标签页
    self.tradingSpotRadioGroup = RadioGroup.new()
    self.tradingSpotRadioGroup:setItems(self, {"BuyCheckBox", "AllCheckBox"}, self.onTradingSpotCheckBox, "TradingSpotItemPanel")

    -- 默认选中第一个
    self:setTabListInfo("ExpressionCheckBox")
    self.radioGroup:selectRadio(1)

    -- 技能标签页
    local pageTag = PageTag.new(self, {'SKillPageCheckBox', 'SkillPageCheckBox_0', 'SkillPageCheckBox_1'})
    local skillPageView = self:getControl("SkillPanel")
    self:bindPageViewAndPageTag(self:getControl("PageView", Const.UIPageView, skillPageView), pageTag)
end

function LinkAndExpressionDlg:checkCanShow(i)
    if self.objType == "TradingSpotDiscuss" then
        -- 货站讨论，只需要显示表情、货品、货品买入方案
        if TITLE_BUTTON[i].ctrName == "ExpressionCheckBox" or TITLE_BUTTON[i].ctrName == "TradingSpotCheckBox"
            or TITLE_BUTTON[i].ctrName == "TradingSpotSlnButton" then
            return true
        end

        return false
    elseif (TITLE_BUTTON[i].ctrName == "TradingSpotCheckBox" or TITLE_BUTTON[i].ctrName == "TradingSpotSlnButton")
        and (not TradingSpotMgr:isTradingSpotEnable() or not TradingSpotMgr:isTradingSpotOpen()) then
        -- 货站相关按钮需要系统开启再显示
        return false
    elseif TITLE_BUTTON[i].ctrName ~= "ExpressionCheckBox" and (self.objType == "blog" or self.objType == "bookComment" or self.objType == "hornFools") then
        return false
    elseif self.objType == CHAT_CHANNEL.FRIEND and TITLE_BUTTON[i].ctrName ~= "ExpressionCheckBox" and FriendMgr:getKuafObjDist(self.chatGid) then
        -- 跨服对象只显示表情
        return false
    elseif TITLE_BUTTON[i].ctrName == "ShakeButton" then
        -- 只有帮派频道有红包按钮
        if self.objType ~= CHAT_CHANNEL.FRIEND then
            return false
        end
    elseif TITLE_BUTTON[i].ctrName == "PartyRedBagButton" then
        -- 只有帮派频道有红包按钮
        if self.objType ~= CHAT_CHANNEL.PARTY then
            return false
        end
    elseif TITLE_BUTTON[i].ctrName == "WatchButton" then
        -- 分享赛事按钮只有观看比赛时才会出现
        if not WatchCenterMgr:canShowShareAndBarrage() then
            return false
        end
    elseif TITLE_BUTTON[i].ctrName == "JubaoItemCheckBox" then
        -- 聚宝斋按钮部分渠道不显示
        if not TradingMgr:getTradingEnable() or DeviceMgr:isReviewVer() then
            return false
        end
    elseif TITLE_BUTTON[i].ctrName == "ZhenbaoItemCheckBox" then
        if not MarketMgr:isShowGoldMarket() then
            return false
        end
    elseif TITLE_BUTTON[i].ctrName == "CallButton" then
        -- 呼叫成员按钮
        if self.objType ~= CHAT_CHANNEL.CHAT_GROUP and self.objType ~= CHAT_CHANNEL.PARTY then
            return false
        end
    end

    return true
end

function LinkAndExpressionDlg:initCheckBox()
    local buttonList = {}
    self.showCheckBox.boxs = {}
        for i = 1, #TITLE_BUTTON do
            if self:checkCanShow(i) then
                table.insert(buttonList, TITLE_BUTTON[i])

                if TITLE_BUTTON[i].type == "CheckBox" then
                    self.showCheckBox[TITLE_BUTTON[i].ctrName] = true
                    table.insert(self.showCheckBox.boxs, TITLE_BUTTON[i].ctrName)
                end
            end
        end

    local pageView = self:getControl("TypePageView")
    pageView:setTouchEnabled(true)
    pageView:stopAllActions()
    pageView:removeAllPages()
    local expressionNumber = #buttonList
    local lineNumber = 3
    local columnNumber = 3
    local pageNumber = math.floor(expressionNumber / (columnNumber * lineNumber))
    local pageLeft = expressionNumber % (columnNumber * lineNumber)
    local curPageContainNumber = 0

    if pageLeft ~= 0 then
        pageNumber = pageNumber + 1
    end

    for z = 1, pageNumber do
        if pageNumber  == z and pageLeft ~= 0 then
            curPageContainNumber = pageLeft
        else
            curPageContainNumber = columnNumber * lineNumber
        end

        local page = ccui.Layout:create()
        local pageSize = pageView:getContentSize()
        page:setContentSize(pageSize)
        if z ~= 1 then
            -- WDSY-23570 由于pageView在doLayout会延迟一帧执行
            -- 为防止玩家在未doLayout之前点击非第一页链接按钮，将除第一页外的页面放到第一页右边
            page:setPosition(pageSize.width, 0)
        end

        local line = math.floor( curPageContainNumber / columnNumber) + 1
        local left = curPageContainNumber % columnNumber
        local lineCount = 0

        for i = 1, line do
            if i == line then
                lineCount = left
            else
                lineCount = columnNumber
            end

            for j = 1, lineCount do
                local tag = columnNumber * (i - 1) + j + (z - 1) * columnNumber * lineNumber
                local data = buttonList[tag]
                if nil ~= data then
                    local cell = self:createTypeCell(data)
                    local posx = (j - 1) * (cell:getContentSize().width + 20) + 1
                    local posy = page:getContentSize().height - (i - 1)*(cell:getContentSize().height + 20)
                    cell:setPosition(posx, posy)
                    cell:setAnchorPoint(0,1)
                    page:addChild(cell)
                end
            end
        end

        pageView:addPage(page)
        end

    performWithDelay(pageView, function()
    pageView:scrollToPage(0)
    end, 0.01)

    -- 加入页数
    local panel = self:getControl("TypePanel")
    local pageTable = {}
    local pageCheckBox = self:getControl("TypePageCheckBox")
    pageCheckBox:setSelectedState(false)
    table.insert(pageTable, "TypePageCheckBox")
    local beginX = (panel:getContentSize().width - pageNumber *(pageCheckBox:getContentSize().width + PAGECHECKBOX_SPACE) + PAGECHECKBOX_SPACE) / 2
    pageCheckBox:setPositionX(beginX)
    pageCheckBox:setTag(1)
    pageCheckBox:setTouchEnabled(false)

    for i = 1, pageNumber - 1 do
        local pageCheckname = string. format("TypePageCheckBox%d", i)
        table.insert(pageTable, pageCheckname)
        local pageNumberCell = pageCheckBox:clone()
        local pox = beginX + (pageCheckBox:getContentSize().width + PAGECHECKBOX_SPACE) * i
        pageNumberCell:setPositionX(pox)
        pageNumberCell:setTag(i + 1)
        pageNumberCell:setTouchEnabled(false)
        panel:addChild(pageNumberCell)
    end

    -- 绑定分页控件和分页标签
    pageView:addEventListener(function(sender, eventType)
        local index = pageView:getCurPageIndex()

        if eventType == ccui.PageViewEventType.turning then
            for i = 1, pageNumber do
                local checkBox = panel:getChildByTag(i)
                if index + 1  == i then
                    checkBox:setSelectedState(true)
                else
                    checkBox:setSelectedState(false)
                end
            end
        end
    end)
end

function LinkAndExpressionDlg:createTypeCell(data)
    local cell

    if data.type == "CheckBox" then
        cell = self.typeCheck:clone()
    else
        cell = self.typeButton:clone()
    end

    local path = data.icon
    self:setImage("Image", path, cell)

    self:setLabelText("Label", data.labelStr, cell)

    cell:setName(data.ctrName)

    return cell
end

function LinkAndExpressionDlg:onCheckBox(sender, type)
    local name = sender:getName()
    if name == "TradingSpotCheckBox" and not self:canShowTradingSpotGoods() then
        -- 货站货品不能选中
        sender:setSelectedState(false)
        return
    end

    for k,v in pairs(self.panelListTable) do
        if v then
            v:setVisible(false)
        end
    end

    if self.panelListTable[name]
        and name ~= "HistoryCheckBox"
        and name ~= "PetCheckBox"
        and name ~= "ChildCheckBox" then
        -- 历史界面需要时时刷新，娃娃、宠物公用同一个panel，也需要时时刷新
        self.panelListTable[name]:setVisible(true)
    else
        self:setTabListInfo(name)
    end
end

function LinkAndExpressionDlg:setTabListInfo(name)
    self.panelListTable[name] = self:getControl(Config_Data[name])
    self.panelListTable[name]:setVisible(true)

    local clonePanel = nil
    local dataTable = {}
    local func = nil

    if name == "ItemCheckBox" then
        clonePanel = self.itemCell
        func = self.setItemCellInfo
        dataTable = self:getItemList()
    elseif name == "PetCheckBox" then
        clonePanel = self.petCell
        func = self.setPetCellInfo
        dataTable = self:getPetList()
    elseif name  == "StatisticsCheckBox" then
        clonePanel = self.guardCell
        func = self.setGuardInfo
        dataTable = self:getGuardList()
    elseif name == "TaskCheckBox" then
        clonePanel = self.taskCell
        func = self.setTaskInfo
        dataTable = self:getTaskList()
    elseif name == "SkillCheckBox" then
        self:createSkillListInfo()
        return
    elseif name == "TitleCheckBox" then
        clonePanel = self.titleCell
        func = self.setTitleInfo
        dataTable = self:getTitleList()
    elseif name == "ExpressionCheckBox" then
        --local index = ChatMgr:getExpressionTab()
        self.vipRadioGroup:selectRadio(1)   -- 默认选第一个
        return
    elseif name == "HistoryCheckBox" then
        self["HistoryCheckBox"] = {} -- 清空上次选中的图片
        clonePanel = self.historyCell
        func = self.setHistoryInfo
        dataTable = self:getHistoryList()
    elseif name == "MarketItemCheckBox" then
        self.marketItemRadioGroup:selectRadio(1)
        return
    elseif name == "ZhenbaoItemCheckBox" then
        self.zhenbaoItemRadioGroup:selectRadio(1)
        return
    elseif name == "JubaoItemCheckBox" then
        self.jubaoItemRadioGroup:selectRadio(1)
        return
    elseif name == "UsefulCheckBox" then
        clonePanel = self.usefulItemCell
        func = self.setUsefulWords
        dataTable = UsefulWordsMgr:getUsefulWordsData()
    elseif name == "TradingSpotCheckBox" then
        clonePanel = self.tradingSpotItemCell
        func = self.setTradingSpotCellInfo
        self.tradingSpotRadioGroup:selectRadio(1)
        dataTable = self:getTradingSpotItemList()
    elseif name == "ChildCheckBox" then
        clonePanel = self.petCell
        func = self.setChildCellInfo
        dataTable = HomeChildMgr:getChildByOrder(true)
    end

    if dataTable == nil then return end
    self:createPages(name, clonePanel, dataTable, func)
end

-- 创建页面
function LinkAndExpressionDlg:createPages(name, clonePanel, dataTable, func, isVip)
    local pageView = self:getControl("PageView", Const.UIPageView, self.panelListTable[name])
    pageView:setMoveDistanceToChangePage(MOVE_DISTANCE)
    pageView:setTouchEnabled(true)
    pageView:stopAllActions()
    pageView:removeAllPages()

    if self[name] then
        self[name].selectImg = nil
    end

    if not dataTable or #dataTable <= 0 then
        self:setCtrlVisible("NoticeLabel", true, self.panelListTable[name])
        if name == "PetCheckBox" then
            self:setLabelText("NoticeLabel", CHS[7120234], self.panelListTable[name])
        elseif name == "ChildCheckBox" then
            self:setLabelText("NoticeLabel", CHS[7120235], self.panelListTable[name])
        end
    else
        self:setCtrlVisible("NoticeLabel", false, self.panelListTable[name])
    end

    local expressionNumber = #dataTable
    local lineNumber = COUNT_CONFIG[name][1]
    local columnNumber = COUNT_CONFIG[name][2]
    local pageNumber = math.floor(expressionNumber / (columnNumber * lineNumber))
    local pageLeft = expressionNumber % (columnNumber * lineNumber)
    local curPageContainNumber = 0

    if pageLeft ~= 0 then
        pageNumber = pageNumber + 1
    end
    local z = 1
    local function createPage()
       -- for z = 1, pageNumber do
            if  z > pageNumber then
                pageView:stopAllActions()
                --pageView:scrollToPage(0)
                return
            end

            if pageNumber  == z and pageLeft ~= 0 then
                curPageContainNumber = pageLeft
            else
                curPageContainNumber = columnNumber * lineNumber
            end


            local page = ccui.Layout:create()
            page:setContentSize(pageView:getContentSize())
            local line = math.floor( curPageContainNumber / columnNumber) + 1
            local left = curPageContainNumber % columnNumber
            local lineCount = 0

            for i = 1, line do
                if i == line then
                    lineCount = left
                else
                    lineCount = columnNumber
                end

                for j = 1, lineCount do
                    local tag = columnNumber * (i - 1) + j + (z - 1) * columnNumber * lineNumber
                    local data = dataTable[tag]
                    if nil ~= data then
                        local cell

                        if clonePanel == nil then   -- 没克隆自己创建
                            cell = self:createOneExpression(dataTable[tag], page, isVip)
                        else
                            cell = clonePanel:clone()
                            func(self, cell, dataTable[tag], tag)
                        end

                        local posx = (j - 1) * (cell:getContentSize().width + SPACE_CONFIG[name][1]) + 1
                        local posy = page:getContentSize().height - (i - 1)*(cell:getContentSize().height + SPACE_CONFIG[name][2])
                        cell:setPosition(posx, posy)
                        cell:setAnchorPoint(0,1)
                        page:addChild(cell)
                    end
                end
            end
            z = z + 1
            pageView:addPage(page)
       -- end
       if z == 2 then
            -- 由于第一页改为了立即创建，此处需要延时一帧，因为还没有doLayout过，
            -- 直接scollToPage的话，由于PageView中的数据还未更新，引起异常
            performWithDelay(pageView, function() pageView:scrollToPage(0) end, 0)
       end

    end

    createPage()  -- 帮派指引需要直接调用第一页的表情控件，只用schedule，可能表情控件还未创建，就直接被调用，会报错
    if pageNumber > 1 then
    schedule(pageView , createPage, 0.05)
    end

    -- 加入页数
    local pageTable = {}
    local pageCheckBox = self:getControl("PageCheckBox", nil, self.panelListTable[name])
    pageCheckBox:setSelectedState(false)
    table.insert(pageTable, "PageCheckBox")
    local showPageNum = pageNumber == 0 and 1 or pageNumber
    local beginX = (self.panelListTable[name]:getContentSize().width - showPageNum *(pageCheckBox:getContentSize().width + PAGECHECKBOX_SPACE) + PAGECHECKBOX_SPACE) / 2 + pageCheckBox:getContentSize().width * 0.5
 --   local beginX = self.panelListTable[name]:getContentSize().width * 0.5
    pageCheckBox:setPositionX(beginX)
    pageCheckBox:setTag(1)
    pageCheckBox:setTouchEnabled(false)

    for i = 2 , 10 do
        local checkBox = self.panelListTable[name]:getChildByTag(i)
        if checkBox then
            checkBox:removeFromParent()
        end
    end

    for i = 1, pageNumber - 1 do
        local pageCheckname = string. format("PageCheckBox%d", i)
        table.insert(pageTable, pageCheckname)
        local pageNumberCell = pageCheckBox:clone()
        local pox = beginX + (pageCheckBox:getContentSize().width + PAGECHECKBOX_SPACE) * i
        pageNumberCell:setPositionX(pox)
        pageNumberCell:setTag(i + 1)
        pageNumberCell:setTouchEnabled(false)
        self.panelListTable[name]:addChild(pageNumberCell)
    end

    -- 绑定分页控件和分页标签
    pageView:addEventListener(function(sender, eventType)
        local index = pageView:getCurPageIndex()

        if eventType == ccui.PageViewEventType.turning then
            if not self.panelListTable[name] then return end
            for i = 1, pageNumber do
                local checkBox = self.panelListTable[name]:getChildByTag(i)
                if index + 1  == i then
                    checkBox:setSelectedState(true)
                else
                    checkBox:setSelectedState(false)
                end
            end
        end

    end)

end

-- 创建一个表情
function LinkAndExpressionDlg:createOneExpression(fileName, page, isVip)
    local expressHeight  = math.floor((page:getContentSize().height - SPACE_CONFIG["ExpressionCheckBox"][1] * COUNT_CONFIG["ExpressionCheckBox"][1]) /  COUNT_CONFIG["ExpressionCheckBox"][1])
    local expressWidth= math.floor((page:getContentSize().width - SPACE_CONFIG["ExpressionCheckBox"][2] * COUNT_CONFIG["ExpressionCheckBox"][2]) /  COUNT_CONFIG["ExpressionCheckBox"][2])

    if not isVip then
        if BrowMgr:isGenderBrow(fileName) then
            if Me:queryBasic("gender") == FEMALE then
                fileName = fileName.."f"
            elseif Me:queryBasic("gender") == MALE then
                fileName = fileName.."m"
            end
        end
    end

    local sprite =self:createAnimate(fileName)
    sprite:setAnchorPoint(0.5,0.5)
    sprite:setPosition(expressWidth/2, expressHeight/2)
    sprite:setName(fileName)

    local layout = ccui.Layout:create()
    layout:setContentSize(expressWidth, expressHeight)
    layout:setTouchEnabled(true)
    layout:setAnchorPoint(0,1)
    layout:addChild(sprite)
    layout:setName(fileName)

    local closeButton = self:getControl("CloseButton")
    local function imgTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            if self["ExpressionCheckBox"].latSelcelCheckBox == "VipCheckBox" then
                if Me:isVip() then
                    self:callBack("addExpression", "#"..fileName)
                else
                    gf:ShowSmallTips(CHS[3002911])
                end
            else
                self:callBack("addExpression", "#"..fileName)
            end

            local folatLayout = closeButton:getChildByTag(999)
            if folatLayout then
                folatLayout:removeFromParent()
            end
        elseif ccui.TouchEventType.began == eventType then
            local folatLayout = closeButton:getChildByTag(999)
            if folatLayout then
                folatLayout:removeFromParent()
            end

            local folatLayout =  self:createExpressionFoloat(sender)
            local pt = sender:convertToWorldSpace(cc.p(0, 0))
            local rect = sender:getBoundingBox()
            local pt = closeButton:convertToNodeSpace(pt)

            folatLayout:setPosition(pt.x + rect.width /2 , pt.y  + rect.height + 10)
            closeButton:addChild(folatLayout, 999 , 999)
        elseif ccui.TouchEventType.moved == eventType
            or ccui.TouchEventType.canceled == eventType then
            local folatLayout = closeButton:getChildByTag(999)
            if folatLayout then
                folatLayout:removeFromParent()
            end
        end
    end

    layout:addTouchEventListener(imgTouch)

    return layout
end

function LinkAndExpressionDlg:createExpressionFoloat(sender)
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5, 0)
    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.chat_back_groud)
    backSprite:setAnchorPoint(0.5, 1)
    backSprite:setLocalZOrder(-1)
    backSprite:setContentSize(sender:getContentSize().width * 1.5 + 10, sender:getContentSize().height * 1.5 + 10)
    layout:addChild(backSprite)

    local fileName = sender:getName()
    local sprite =self:createAnimate(fileName)
    sprite:setAnchorPoint(0.5, 0.5)
    sprite:setScale(1.5)
    layout:addChild(sprite)

    local backSprite1 = ccui.ImageView:create(ResMgr.ui.chat_back_groud_down, ccui.TextureResType.plistType)
    backSprite1:setAnchorPoint(0.5, 0)
    backSprite1:setLocalZOrder(0)
    layout:addChild(backSprite1)

    local hegiht = backSprite:getContentSize().height + backSprite1:getContentSize().height
    layout:setContentSize(backSprite:getContentSize().width, hegiht)
    sprite:setPosition(layout:getContentSize().width / 2, layout:getContentSize().height/2)
    backSprite:setPosition(layout:getContentSize().width / 2, layout:getContentSize().height )
    backSprite1:setPosition(layout:getContentSize().width / 2, 2)

    return layout
end

function LinkAndExpressionDlg:createAnimate(fileName)
    local filePath = "brow/"..fileName
    gfAddFrames(filePath .. ".plist", filePath .. "/");

    -- 创建帧动画
    local animation =  cc.Animation:create()
    animation:setDelayPerUnit(0.2)
    for i = 0,CONST_DATA.ExpressionFrameNumber do
        local framName = string.format("%s/%05d",filePath,i)
        local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(framName)
        if  not frame then
            break
        end
        animation:addSpriteFrame(frame)
    end

    -- 创建动作
    local animate = cc.Animate:create(animation)
    local sprite =  cc.Sprite:create()
    local repeatAction = cc.RepeatForever:create(animate)
    sprite:runAction(repeatAction)
    animate:update(0)

    return sprite
end

function LinkAndExpressionDlg:onItemCheckBox(sender, type)
    -- 主checkbox判断
    if not self.panelListTable["ItemCheckBox"] or not self.panelListTable["ItemCheckBox"]:isVisible() then
        return
    end

    local clonePanel = self.itemCell
    local dataTable = {}
    local func = self.setItemCellInfo

    if self["ItemCheckBox"] == nil then
        self["ItemCheckBox"] = {}
    end

    if self["ItemCheckBox"].latSelcelCheckBox  == sender:getName() then
        return
    end

    self["ItemCheckBox"].selectImg = nil

    dataTable = self:getItemList()

    self["ItemCheckBox"].latSelcelCheckBox = sender:getName()
    self:createPages("ItemCheckBox", clonePanel, dataTable, func)
end

function LinkAndExpressionDlg:onExpressionCheckBox(sender, type)
    local clonePanel = nil
    local dataTable = {}
    local func = nil
    local isvip = nil

    if self["ExpressionCheckBox"] == nil then
        self["ExpressionCheckBox"] = {}
    end

    if self["ExpressionCheckBox"].latSelcelCheckBox  == sender:getName() then
        return
    end

    if sender:getName() == "CommonCheckBox" then
        dataTable = BrowMgr:getBrowUseTimeOrderList()
        ChatMgr:setExpressionTab(1)
    else
        dataTable = BrowMgr:getBrowUseTimeOrderList("isVip")
        isvip = true
        ChatMgr:setExpressionTab(2)
    end

    self["ExpressionCheckBox"].latSelcelCheckBox = sender:getName()
    self:createPages("ExpressionCheckBox", clonePanel, dataTable, func, isvip)
end

function LinkAndExpressionDlg:setUsefulWords(cell, str, tag)
    cell:setTag(tag)
    self:setUsefulWordsText(str, cell)
    cell.words = str
    self:bindTouchEndEventListener(cell, self.onUsefulWords)
    self:bindListener("CompilePanel", self.onUsefulWords, cell)
end

function LinkAndExpressionDlg:onUsefulWords(sender, eventType)
    local name = sender:getName()
    if name == "CompilePanel" then
        local parent = sender:getParent()
        DlgMgr:openDlgEx("UsefulPhraseEditorDlg", {tag = parent:getTag(), str = parent.words})
    else
        self:callBack("addExpression", sender.words)
        self:addSelcetImage(sender, "UsefulCheckBox")
    end
end

function LinkAndExpressionDlg:canShowTradingSpotGoods()
    if not TradingSpotMgr:isTradingSpotOpen() then return end

    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190486])
        return
    end

    if not TradingSpotMgr:isMeLevelMeetCondition() then
        gf:ShowSmallTips(CHS[7190478])
        return
    end

    return true
end

function LinkAndExpressionDlg:onTradingSpotCheckBox(sender, type)
    if not self:canShowTradingSpotGoods() then return end

    if self["TradingSpotCheckBox"] == nil then
        self["TradingSpotCheckBox"] = {}
    end

    if self["TradingSpotCheckBox"].latSelcelCheckBox == sender:getName() then
        return
    end

    self["TradingSpotCheckBox"].selectImg = nil

    self["TradingSpotCheckBox"].latSelcelCheckBox = sender:getName()

    local itemList = self:getTradingSpotItemList()
    if itemList then
        self:setCtrlVisible("NoItemLabel", false, "TradingSpotItemPanel")
        self:setCtrlVisible("PageView", true, "TradingSpotItemPanel")
        self:createPages("TradingSpotCheckBox", self.tradingSpotItemCell, itemList, self.setTradingSpotCellInfo)
    end
end

function LinkAndExpressionDlg:getTradingSpotItemList()
    if self.tradingSpotRadioGroup:getSelectedRadioName() == "BuyCheckBox" then
        -- 买过的
        gf:CmdToServer("CMD_TRADING_SPOT_CARD_GOODS_LIST", {})
    else
        -- 所有货品
        local ret = {}
        for i, v in ipairs(TRADING_SPOT_ITEM_CFG) do
            table.insert(ret, {goodsId = i, name = v.name})
        end

        return ret
    end
end

function LinkAndExpressionDlg:setTradingSpotCellInfo(cell, data)
    -- 图标
    local _, itemInfo = TradingSpotMgr:getItemInfo(data.goodsId)
    self:setImage("PortraitImage", ResMgr:getItemIconPath(itemInfo.icon), cell)

    -- 名称
    self:setLabelText("NameLabel", data.name, cell)

    cell.info = data

    local function onTouchTradingSpotItem(dlg, sender, eventType)
        self:addSelcetImage(sender, "TradingSpotCheckBox")

        if not TradingSpotMgr:isTradingSpotEnable() then
            gf:ShowSmallTips(CHS[7190486])
            return
        end

        if not TradingSpotMgr:isMeLevelMeetCondition() then
            gf:ShowSmallTips(CHS[7190478])
            return
        end

        local sendInfo = string.format("{\t%s=%s=%s}", sender.info.name, CHS[7190483], sender.info.goodsId)
        local showInfo = string.format("{\29%s\29}", string.format(CHS[7190484], sender.info.name))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    self:bindTouchEndEventListener(cell, onTouchTradingSpotItem)
end

-- 设置常用短语显示，分单行、双行
function LinkAndExpressionDlg:setUsefulWordsText(str, panel)
    local panel1 = self:getControl("TestPanel1", Const.UIPanel, panel)
    local panel2 = self:getControl("TestPanel2", Const.UIPanel, panel)
    local text1 = gf:subString(str, USERFUL_WORLDS_SHOW_LENTH / 2) or ""
    local text2 = ""
    if text1 then
        text2 = string.sub(str, string.len(text1) + 1, -1)
    end

    if text2 and text2 ~= "" then
        text2 = gf:getTextByLenth(text2, USERFUL_WORLDS_SHOW_LENTH / 2)
        self:setLabelText("TextLabel1", text1, panel2, COLOR3.TEXT_DEFAULT)
        self:setLabelText("TextLabel2", text2, panel2,COLOR3.TEXT_DEFAULT)
        panel1:setVisible(false)
        panel2:setVisible(true)
    else
        self:setLabelText("TextLabel1", text1, panel1, COLOR3.TEXT_DEFAULT)
        panel1:setVisible(true)
        panel2:setVisible(false)
    end
end

-- 更新常用短语
function LinkAndExpressionDlg:updateUsefulWords(tag, str)
    local usefulPanel = self:getControl("UsefulPanel")
    local pageView = self:getControl("PageView", Const.UIPageView, usefulPanel)
    local curPage = pageView:getPages()[pageView:getCurPageIndex() + 1]
    local panel = curPage:getChildByTag(tag)
    if panel then
        self:setUsefulWordsText(str, panel)
        panel.words = str
        self:updateLayout()
    end
end

function LinkAndExpressionDlg:setItemCellInfo(cell, data)
    local function OneSecondLaterFunc()
        local item = InventoryMgr:getItemByPos(data["pos"])
        if not item and data["pos"] >= StoreMgr:getCardStartPos() then
            item = StoreMgr:getCardByPos(data["pos"])
        end

        if not item then return end

        local rect = self:getBoundingBoxInWorldSpace(cell)
        InventoryMgr:showOnlyFloatCardDlg(item, rect)
    end

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "ItemCheckBox")
        if data.item_type == ITEM_TYPE.CHANGE_LOOK_CARD then
            local item = StoreMgr:getCardByPos(data["pos"])
            if not item then item = InventoryMgr:getItemByPos(data["pos"]) end
            if item then
                local str = string.format("{\t%s=%s=%s}", item["name"], CHS[3000015], item["item_unique"])
                local showInfo = string.format("{\29%s\29}", item["name"])
                self:callBack("addCardInfo", str,showInfo)
            end
        else
            local item = InventoryMgr:getItemByPos(data["pos"])
            if item then
            	-- 仙粽2需要显示别名仙粽
                local name = item["alias"] == "" and item["name"] or item["alias"]
                local str = string.format("{\t%s=%s=%s}", name, CHS[3000015], item["item_unique"])
                local showInfo = string.format("{\29%s\29}", name)

                self:callBack("addCardInfo", str,showInfo)
            end
        end

        OneSecondLaterFunc()
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)

    -- 道具图片
    local image = self:getControl("ItemImage", Const.UIImage, cell)
    image:loadTexture(data["imgFile"])
    self:setItemImageSize("ItemImage", cell)

    -- 道具数量
    if data.text then
        local num = tonumber(data.text)
        if num and num > 1 then
            self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, num, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        end
    end

    -- 道具等级
    if data.level then
        self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    if data.req_level then
        self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 如果是法宝，则要显示相性
    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(image, data.item_polar)
    end

    local item = InventoryMgr:getItemByPos(data.pos)
    if item then
        if InventoryMgr:isTimeLimitedItem(item) then
            -- 限时
            InventoryMgr:removeLogoBinding(image)
            InventoryMgr:addLogoTimeLimit(image)
        elseif InventoryMgr:isLimitedItem(item) then
            -- 限制交易
            InventoryMgr:removeLogoTimeLimit(image)
            InventoryMgr:addLogoBinding(image)
        else
            -- 非限制交易
            InventoryMgr:removeLogoTimeLimit(image)
            InventoryMgr:removeLogoBinding(image)
        end

        -- 融合标识
        if item and InventoryMgr:isFuseItem(item.name) then
            InventoryMgr:addLogoFuse(image)
        end

        if item and item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
            InventoryMgr:addLogoUnidentified(image)
        end
    end
end

function LinkAndExpressionDlg:getItemList()

    local dataTable = {}
    local equip = InventoryMgr:getEquipments() -- 武器数据
    local Jewelry = InventoryMgr:getJewelrys() -- 首饰数据
    local artifact = InventoryMgr:getArtifact() -- 法宝数据
    local backEquip = InventoryMgr:getBackEquipments() -- 第二套武器
    local backJewelry = InventoryMgr:getBackJewelrys() -- 第二套首饰数据
    local backArtifact = InventoryMgr:getBackArtifact() -- 第二套法宝
    local bag1 = InventoryMgr:getBag1Items() -- 包裹数据
    local bag2 = InventoryMgr:getBag2Items() -- 行囊数据
    local bag3 = InventoryMgr:getBag3Items()
    local bag4 = InventoryMgr:getBag4Items()
    local bag5 = InventoryMgr:getBag5Items()

    -- 是否是变身卡
    local isChangeCard = self:isCheck("ChangeCardCheckBox")

    if isChangeCard then
        local cardBag = StoreMgr:getChangeCard()
        local topKey = StoreMgr:getCardTop()
        local orderCard = {}
        for id, info in pairs(cardBag) do
            local top = 100
            local cardInform = InventoryMgr:getCardInfoByName(info.name)
            info.card_type = cardInform.card_type
            info.order = cardInform.order
            for i = 1,#topKey do
                if topKey[i] == info.order then
                    top = i
                end
            end
            info.topOrder = top
            table.insert(orderCard, info)
        end

        table.sort(orderCard, function(l, r)
            if l.topOrder < r.topOrder then return true end
            if l.topOrder > r.topOrder then return false end
            if ORDER_BY_CARD_TYPE[l.card_type] < ORDER_BY_CARD_TYPE[r.card_type] then return true end
            if ORDER_BY_CARD_TYPE[l.card_type] > ORDER_BY_CARD_TYPE[r.card_type] then return false end
            if l.order < r.order then return true end
            if l.order > r.order then return false end
        end)
        for i = 1, #orderCard do
            table.insert(dataTable, {name = orderCard[i].name, pos = orderCard[i].pos, imgFile = ResMgr:getItemIconPath(orderCard[i].icon), item_type = orderCard[i].item_type, level = orderCard[i].level})
        end

        local cards = InventoryMgr:getChangeCard()
        for i = 1, #cards do
            table.insert(dataTable, {name = cards[i].name, pos = cards[i].pos, imgFile = ResMgr:getItemIconPath(cards[i].icon), item_type = cards[i].item_type, level = cards[i].level})
        end

        -- WDSY-19198 要求，显示方式改成变身卡套格式
        local retData = {}
        local temp = {}
        local index = 0
        for i, info in pairs(dataTable) do
            if not temp[info.name] then
                index = index + 1
                temp[info.name] = index
                local cardData = gf:deepCopy(info)
                cardData.text = 1
                table.insert(retData, cardData)
            else
                retData[temp[info.name]].text = retData[temp[info.name]].text + 1
            end
        end

        return retData
    end

    for i = 1, equip["count"] do
        if equip[i]["imgFile"] and InventoryMgr:getItemByPos(equip[i]["pos"]) then
            table.insert(dataTable, equip[i])
        end
    end

    for i = 1, Jewelry["count"] do
        if InventoryMgr:getItemByPos(Jewelry[i]["pos"])then
            table.insert(dataTable, Jewelry[i])
        end
    end

    -- 法宝
    for i = 1, artifact["count"] do
        local item = InventoryMgr:getItemByPos(artifact[i]["pos"])
        if item then
            table.insert(dataTable, artifact[i])
        end
    end

    for i = 1, backEquip["count"] do
        if equip[i]["imgFile"] and InventoryMgr:getItemByPos(backEquip[i]["pos"]) then
            table.insert(dataTable, backEquip[i])
        end
    end

    for i = 1, backJewelry["count"] do
        if InventoryMgr:getItemByPos(backJewelry[i]["pos"])then
            table.insert(dataTable, backJewelry[i])
        end
    end

    -- 第二套法宝
    for i = 1, backArtifact["count"] do
        local item = InventoryMgr:getItemByPos(backArtifact[i]["pos"])
        if item then
            table.insert(dataTable, backArtifact[i])
        end
    end



    for i = 1, bag1["count"] do
        if bag1[i]["imgFile"] and bag1[i].item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD and not bag1[i].isNotAddLinkAndExpressionDlg then
            table.insert(dataTable, bag1[i])
        end
    end

    for i = 1, bag2["count"] do
        if bag2[i]["imgFile"] and bag2[i].item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD and not bag2[i].isNotAddLinkAndExpressionDlg then
            table.insert(dataTable, bag2[i])
        end
    end

    for i = 1, bag3["count"] do
        if bag3[i]["imgFile"] and bag3[i].item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD  and not bag3[i].isNotAddLinkAndExpressionDlg then
            table.insert(dataTable, bag3[i])
        end
    end

    for i = 1, bag4["count"] do
        if bag4[i]["imgFile"] and bag4[i].item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD  and not bag4[i].isNotAddLinkAndExpressionDlg then
            table.insert(dataTable, bag4[i])
        end
    end

    for i = 1, bag5["count"] do
        if bag5[i]["imgFile"] and bag5[i].item_type ~= ITEM_TYPE.CHANGE_LOOK_CARD  and not bag5[i].isNotAddLinkAndExpressionDlg then
            table.insert(dataTable, bag5[i])
        end
    end

    return dataTable
end

function LinkAndExpressionDlg:setPetCellInfo(cell, pet)
    -- 宠物头像
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    image:loadTexture(path)
    self:setItemImageSize("PortraitImage", cell)

    -- 名称
    local namePanel = self:getControl("NameLabel", Const.UILabel, cell)
    local name = gf:getPetName(pet["basic"])
    namePanel:setString(name)

    -- 等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(CHS[2000015] .. pet:queryBasic("level"))

    -- 限时/限制交易标识
    if PetMgr:isTimeLimitedPet(pet) then
        InventoryMgr:removeLogoBinding(image)
        InventoryMgr:addLogoTimeLimit(image)
    elseif PetMgr:isLimitedPet(pet) then
        InventoryMgr:removeLogoTimeLimit(image)
        InventoryMgr:addLogoBinding(image)
    else
        InventoryMgr:removeLogoTimeLimit(image)
        InventoryMgr:removeLogoBinding(image)
    end

    local function touch(sender, eventType)

        self:addSelcetImage(cell, "PetCheckBox")

        local sendInfo = string.format("{\t%s=%s=%s}", pet:queryBasic("raw_name"), CHS[6000079],  pet:getId())
        local showInfo = string.format("{\29%s\29}", pet:queryBasic("raw_name"))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)
end

function LinkAndExpressionDlg:setChildCellInfo(cell, child)
    -- 娃娃头像
    local path = ResMgr:getSmallPortrait(child:queryBasicInt("portrait"))
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    image:loadTexture(path)
    self:setItemImageSize("PortraitImage", cell)

    -- 名称
    local namePanel = self:getControl("NameLabel", Const.UILabel, cell)
    local name = child:getName()
    if child:queryInt("stage") == HomeChildMgr.CHILD_TYPE.FETUS then
        name = CHS[7120227]
    elseif child:queryInt("stage") == HomeChildMgr.CHILD_TYPE.STONE then
        name = CHS[7120228]
    end

    namePanel:setString(name)

    -- 亲密度
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(string.format(CHS[7120214], child:queryInt("intimacy")))

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "ChildCheckBox")
        local sendInfo = string.format("{\t%s=%s=%s}", name, CHS[7120229], child:queryBasic("cid"))
        local showInfo = string.format("{\29%s\29}", name)
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        HomeChildMgr:requestChildCard(child:queryBasic("cid"))
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)
end

function LinkAndExpressionDlg:getPetList()
    local function sort(left, right)
        if left:queryInt("intimacy") > right:queryInt("intimacy") then return true
        elseif left:queryInt("intimacy") < right:queryInt("intimacy") then return false
        end

        if left:queryInt("level") > right:queryInt("level") then return true
        elseif left:queryInt("level") < right:queryInt("level") then return false
        end

        if left:queryInt("shape") > right:queryInt("shape") then return true
        elseif left:queryInt("shape") < right:queryInt("shape") then return false
        end

        if left:getName() < right:getName() then return true
        else return false
        end
    end

    local petList = {}
    for k,v in pairs(PetMgr.pets) do
        table.insert(petList, v)
    end

    table.sort(petList, sort)

    return petList
end

function LinkAndExpressionDlg:getGuardList()
    local guardsList = {}
    local fightArr = {}
    if nil == GuardMgr.objs then return  end

    local function sortFunc(l, r)
        -- 排序逻辑
        if l.combat_guard > r.combat_guard then return true
        elseif l.combat_guard < r.combat_guard then return false
        end

        if l.rank > r.rank then return true
        elseif l.rank < r.rank then return false
        end

        if l.polar < r.polar then return true
        else return false
        end
    end

    for k, v in pairs(GuardMgr.objs) do
        table.insert(fightArr, {id = v:queryBasicInt("id"), combat_guard = v:queryBasicInt("combat_guard"),
            rank = v:queryBasicInt("rank"), polar = v:queryBasic("polar")})
    end

    table.sort(fightArr, sortFunc)

    for i = 1, #fightArr do
        table.insert(guardsList, GuardMgr:getGuard(fightArr[i].id))
    end

    return guardsList
end

function LinkAndExpressionDlg:setGuardInfo(cell, guard)
    -- 头像
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    local imgPath = ResMgr:getSmallPortrait(guard:queryBasicInt("icon"))
    image:loadTexture(imgPath)
    self:setItemImageSize("PortraitImage")

    -- 名称
    local nameLabel = self:getControl("NameLabel_1", Const.UILabel, cell)
    local name = guard:queryBasic("name")  -- 设置名字
    nameLabel:setString(name)
    -- 根据守卫的品质类型，设置守卫名字的颜色
    local rank = guard:queryBasicInt("rank")  -- 获取守卫品质
    local color = CharMgr:getNameColorByType(OBJECT_TYPE.GUARD, false, rank)  -- 获取与品质对应的颜色
    nameLabel:setColor(color)  -- 设置颜色

    -- 等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(CHS[2000015] .. guard:queryBasic("level"))

    -- 相性
    local polarLabel  = self:getControl("PolarLabel", Const.UILabel, cell)
    polarLabel:setString(gf:getPolar(guard:queryBasicInt("polar")))

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "StatisticsCheckBox")

        local sendInfo = string.format("{\t%s=%s=%s}", guard:queryBasic("raw_name"), CHS[6000162],  guard:queryBasicInt('id'))
        local showInfo = string.format("{\29%s\29}", guard:queryBasic("raw_name"))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        local dlg = DlgMgr:openDlg("GuardCardDlg")          -- 长按一秒守卫，打开守卫名片对话框
        local rect = self:getBoundingBoxInWorldSpace(cell)
        dlg:setGuardCardInfo(self:guardToCardData(guard))   -- 将守卫的数据传入对话框
        --dlg.root:setAnchorPoint(0, 0)
        --dlg:setFloatingFramePos(rect)
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)
end

-- 守护数据的转化成名片需要的数据
function LinkAndExpressionDlg:guardToCardData(guard)
	local guardCardInfo = {}
    guardCardInfo["name"] = guard:queryBasic("name")
    guardCardInfo["raw_name"] = guard:queryBasic("raw_name")
    guardCardInfo["icon"] = guard:queryBasicInt("icon")
    guardCardInfo["polar"] = guard:queryBasicInt("polar")
    guardCardInfo["level"] = guard:queryBasicInt("level")
    guardCardInfo["max_life"] = guard:queryBasic("max_life")
    guardCardInfo["fight_score"] = guard:queryBasic("fight_score")
    guardCardInfo["phy_power"] = guard:queryBasic("phy_power")
    guardCardInfo["mag_power"] = guard:queryBasic("mag_power")
    guardCardInfo["speed"] = guard:queryBasic("speed")
    guardCardInfo["def"] = guard:queryBasicInt("def")
    guardCardInfo["con"] = guard:queryBasicInt("con")
    guardCardInfo["str"] = guard:queryBasicInt("str")
    guardCardInfo["wiz"] = guard:queryBasicInt("wiz")
    guardCardInfo["dex"] = guard:queryBasicInt("dex")
    guardCardInfo["metal"] = guard:queryBasicInt("metal")
    guardCardInfo["wood"] = guard:queryBasicInt("wood")
    guardCardInfo["water"] = guard:queryBasicInt("water")
    guardCardInfo["fire"] = guard:queryBasicInt("fire")
    guardCardInfo["earth"] = guard:queryBasicInt("earth")
    guardCardInfo["rebuild_level"] = guard:queryBasicInt("rebuild_level")
    guardCardInfo["rank"] = guard:queryBasicInt("rank")
    guardCardInfo["intimacy"] = guard:queryBasic("intimacy")
   -- guardCardInfo["degree"] = guard:queryBasic("degree")

    guardCardInfo["develop_power"] = guard:queryBasic('grow_attrib')["power"] or 0
    guardCardInfo["develop_def"] = guard:queryBasic('grow_attrib')["def"] or 0
    guardCardInfo["rebuild_level"] = guard:queryBasic('grow_attrib')["rebuild_level"] or 0
    guardCardInfo["degree"] = guard:queryBasic('grow_attrib')["degree_32"] or 0

    return guardCardInfo
end

function LinkAndExpressionDlg:getTaskList()
    local taskList = {}
    for k, v in pairs(TaskMgr.tasks) do
        table.insert(taskList,  v)
    end

    return taskList
end

function LinkAndExpressionDlg:setTaskInfo(cell, task)
    -- 名称
    local nameLabel = self:getControl("NameLabel", Const.UILabel, cell)
    nameLabel:setString(task["show_name"])

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "TaskCheckBox")

        local sendInfo = string.format("{\t%s=%s=%s}", task["show_name"], CHS[6000163],  task["task_type"])
        local showInfo = string.format("{\29%s\29}", task["show_name"])
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        if DlgMgr:isDlgOpened("TaskCardDlg") then
            DlgMgr:closeDlg("TaskCardDlg")
        end

        local dlg = DlgMgr:openDlg("TaskCardDlg")
        local rect = self:getBoundingBoxInWorldSpace(cell)
        dlg:setData(task)
        --dlg.root:setAnchorPoint(0, 0)
        --dlg:setFloatingFramePos(rect)
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)  -- 长按回调函数
end

function LinkAndExpressionDlg:createSkillListInfo()
    local skillList = {}
    local id = Me:getId()

    local phySkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_J)
    if phySkill then
        table.insert(skillList, phySkill[1])
    end

    local bSkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_B)

    local skillsTabA, skillsTabB = SkillMgr:getSkillsByCombatMode(COMBAT_MODE.COMBAT_MODE_TONGTIANTADING)

    if bSkill then
        for k,v in pairs(bSkill) do
            if not skillsTabB[v.no] then
            table.insert(skillList, v)
            else
                -- 特殊技能不显示，如果需要显示，后续可根据skills.lua 中 skill_para判断
        end
    end
    end

    -- 攻击技能
    local page1 = self:getControl("SkillPanelPage_1")
    local areaPanel = self:getControl("SkillAreaPanel_1", Const.UIPanel, page1)
    for i = 1, #skillList do
        if i > 6 then return   end-- 超过6个属于异常
        local skillPanel = self:getControl(string.format("SkillPanel_%d", i), Const.UIPanel, areaPanel)
        self:setSkillInfo(skillPanel, skillList[i])
    end


    local cSKill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_C)
    if cSKill then
        for k,v in pairs(cSKill) do
            table.insert(skillList, v)
        end
    end

    -- 障碍技能
    local cAreaPanel = self:getControl("SkillAreaPanel_2", Const.UIPanel, page1)
    for i = 1, #cSKill do
        if i > 5 then return   end
        local skillPanel = self:getControl(string.format("SkillPanel_%d", i), Const.UIPanel, cAreaPanel)
        self:setSkillInfo(skillPanel, cSKill[i])
    end

    local dSkill = {}
    local dSkillWithQinMiWuJian = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_D)

    -- 除去亲密无间复制的宠物技能
    for k, v in pairs(dSkillWithQinMiWuJian) do
        local skill = SkillMgr:getSkill(id, v.no)
        if not skill.isTempSkill or skill.isTempSkill == 0 then
            table.insert(dSkill, v)
        end
    end

    if dSkill then
        for k,v in pairs(dSkill) do
            table.insert(skillList, v)
        end
    end

    -- 辅助技能
    local page2 = self:getControl("SkillPanelPage_2")
    local areaPanel2 = self:getControl("SkillAreaPanel_1", Const.UIPanel, page2)

    for i = 1, #dSkill do
        if i > 5 then return   end
        local skillPanel = self:getControl(string.format("SkillPanel_%d", i), Const.UIPanel, areaPanel2)
        self:setSkillInfo(skillPanel, dSkill[i])
    end

    local fSkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_F)
    if fSkill then
        for k,v in pairs(fSkill) do
            table.insert(skillList, v)
        end
    end

    -- 被动技能
    local fareaPanel = self:getControl("SkillAreaPanel_2", Const.UIPanel, page2)
    for i = 1, #fSkill do
        if i > 5 then return   end
        local skillPanel = self:getControl(string.format("SkillPanel_%d", i), Const.UIPanel, fareaPanel)
        self:setSkillInfo(skillPanel, fSkill[i])
    end

    local skills = SkillMgr:getCoupleSkillInfo()
    local jiebaiSkills = SkillMgr:getJiebaiSkillInfo()
    for i = 1, #jiebaiSkills do
        table.insert(skills, jiebaiSkills[i])
    end

    local page3 = self:getControl("SkillPanelPage_3")
    local coupulePanel = self:getControl("SkillAreaPanel_1", Const.UIPanel, page3)
    -- 夫妻技能

    for i = 1, #skills do
        if i > 5 then return   end
        local skillPanel = self:getControl(string.format("SkillPanel_%d", i), Const.UIPanel, coupulePanel)
        skills[i].no = skills[i].skill_no
        self:setSkillInfo(skillPanel, skills[i])
    end

    local skillPanel = self:getControl("SkillPanel")
    local pageView = self:getControl("PageView", Const.UIPageView, skillPanel)
    pageView:setMoveDistanceToChangePage(MOVE_DISTANCE)

    return skillList
end

function LinkAndExpressionDlg:setSkillInfo(cell, skill)
    -- 技能图片
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    local path = SkillMgr:getSkillIconPath(skill.no)
    image:loadTexture(path)
    self:setItemImageSize("PortraitImage", cell)
    image:setVisible(true)

    -- 技能等级
    if skill.level then
        self:setNumImgForPanel(cell, ART_FONT_COLOR.NORMAL_TEXT, skill.level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "SkillCheckBox")
        local sendInfo = string.format("{\t%s=%s=%s}", SkillMgr:getSkillName(skill.no), CHS[6000164],  skill.no)
        local showInfo = string.format("{\29%s\29}", SkillMgr:getSkillName(skill.no))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
        local rect = self:getBoundingBoxInWorldSpace(cell)
        --dlg:setSkillBySKill(skill, SkillMgr:getSkillName(skill["no"]), 1, false, rect)
        dlg:setInfo(SkillMgr:getSkillName(skill["no"]), Me:getId(), false, rect)

        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)
end


function LinkAndExpressionDlg:getTitleList()
    local titleList = {}
    local titleNum = Me:queryBasicInt("title_num")
    for i = 1, titleNum do
        local title  = {}
        title["title"] = Me:queryBasic(string.format("title%d", i))
        title["type"] = Me:queryBasic(string.format("type%d", i))
        if title["title"] ~= "" and title["type"] ~= "" then
            table.insert(titleList, title)
        end
    end

    return titleList
end

function LinkAndExpressionDlg:setTitleInfo(cell, title)
    -- 名称
    local nameLabel = self:getControl("NameLabel", Const.UILabel, cell)
    nameLabel:setString(CharMgr:getChengweiShowName(title["title"]))

    local function touch(sender, eventType)
        self:addSelcetImage(cell, "TitleCheckBox")

        local sendInfo = string.format("{\t%s=%s=%s}", title["title"], CHS[6000165],  title["type"])
        local showInfo = string.format("{\29%s\29}", CharMgr:getChengweiShowName(title["title"]))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    local function OneSecondLaterFunc()
        local title = title["title"]
        local rect = self:getBoundingBoxInWorldSpace(cell)
        local dlg = DlgMgr:openDlg("TitleCardDlg")
        dlg:setData(title)
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
    end

    self:blindLongPressWithCtrl(cell, OneSecondLaterFunc, touch, true)
end

function LinkAndExpressionDlg:setHistoryInfo(cell, msg)
    self:setLabelText("NameLabel", msg["showInfo"], cell)

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local sendInfo = msg["sendInfo"]
            local showInfo = msg["showInfo"]

            local isCardExist = true

            -- 对道具/宠物进行特殊处理
            local name, type, idStr, iidStr = string.match(sendInfo, "{\t(.+)=(.+)=(.+)=(.*)}")
            if type and (type == CHS[3000015] or type == CHS[3001218]) then
                if type == CHS[3000015] then
                    if iidStr == nil or iidStr == "" then  -- 没有iid信息
                        local item = InventoryMgr:getItemByIdFromAll(tonumber(idStr), true)
                        if not item then  -- 无法根据id获取道具
                            isCardExist = false
                        else
							-- 优先取别名，因为 仙粽 和 仙粽2
                            if item.alias and item.alias ~= "" then
                                effName = item.alias
                            else
                                effName = item.name
                            end

                            if effName ~= name then  -- 能够根据id获取道具，但与名片道具不匹配
                            isCardExist = false
                        end
                        end
                    else
                        local item = InventoryMgr:getItemByIIdFromAll(iidStr)
                        if not item then -- 无法根据iid获取道具
                            isCardExist = false
                        end
                    end
                elseif type == CHS[3001218] then
                    if iidStr == nil or iidStr == "" then -- 没有iid信息
                        local pet = PetMgr:getPetById(tonumber(idStr))
                        if not pet then  -- 无法根据id获取宠物
                            isCardExist = false
                        elseif pet:queryBasic("raw_name") ~= name then  -- 能够根据id获取宠物，但与名片宠物不匹配
                            isCardExist = false
                        end
                    else
                        local pet = PetMgr:getPetByIId(iidStr)
                        if not pet then  -- 无法根据iid获取宠物
                            isCardExist = false
                        end
                    end
                end
            end

            -- 对任务/称谓作特殊处理
            local showName, type, key = string.match(sendInfo, "{\t(.+)=(.+)=(.+)}")
            if type and (type == CHS[6000163] or type == CHS[6000165]) then
                if type == CHS[6000163] then
                    if not TaskMgr:isExistTaskByShowName(showName) then
                        isCardExist = false
                    end
                elseif type == CHS[6000165] then
                    if not gf:isChengWeiExist(showName) then
                        isCardExist = false
                    end
                end
            end

            if not isCardExist then
                -- 如果名片信息对应物品/宠物已经不存在，则给出提示，且输入到聊天栏的名片信息被移除
                gf:ShowSmallTips(CHS[7000116])
                sendInfo = nil
                showInfo = string.gsub(showInfo, "{\29(.+)\29}", "")
            end

            self:addSelcetImage(cell, "HistoryCheckBox")
            self:callBack("addCardInfo", sendInfo, showInfo, true)
        end
    end

    cell:addTouchEventListener(touch)
end

function LinkAndExpressionDlg:getHistoryList()
      return ChatMgr:getHistoryMsg()
end

function LinkAndExpressionDlg:cleanup()
    self:releaseCloneCtrl("typeCheck")
    self:releaseCloneCtrl("typeButton")
    self:releaseCloneCtrl("itemCell")
    self:releaseCloneCtrl("petCell")
    self:releaseCloneCtrl("guardCell")
    self:releaseCloneCtrl("taskCell")
    self:releaseCloneCtrl("titleCell")
    self:releaseCloneCtrl("historyCell")

    self.myMarketStallItemInfo = nil
    self.myCollectMarketItemInfo = nil
    self.myZhenbaoStallItemInfo = nil
    self.myColoectZhenbaoItemInfo = nil
    self.myJbzCollectItemInfo = {}
    self.waitingTradingSpot = nil

    if self["ExpressionCheckBox"] then
        self["ExpressionCheckBox"].latSelcelCheckBox  = nil
    end

    for k,v in pairs(Config_Data) do
        if self[k] then
            self[k] = nil
        end
    end

    -- 调用界面关闭逻辑
    self:callBack("LinkAndExpressionDlgcleanup")
end

-- 回调对象
function LinkAndExpressionDlg:setCallObj(obj, objType, chatGid)
    self.obj = obj
    self.objType = objType
    self.chatGid = chatGid
    self:initTyepCheckBoxInfo()
end

-- 调用回调方法
function LinkAndExpressionDlg:callBack(funcName, ...)
    local func = self.obj[funcName]
    local name = self.obj.name
    if name and string.match(name, "(.+)Dlg") and not DlgMgr:isDlgOpened(name)then
        -- 界面已经关闭
        return
    end

    if self.obj and func then
        func(self.obj, ...)
    end
end

function LinkAndExpressionDlg:addSelcetImage(cell, name)
    if self[name] == nil then
        self[name] = {}
    end

    local selectImg = self:getControl("ChosenEffectImage", Const.UIImage, cell)

    if self[name].selectImg == nil then
        self[name].selectImg = selectImg
        selectImg:setVisible(true)
    else
        self[name].selectImg:setVisible(false)
        self[name].selectImg = selectImg
        selectImg:setVisible(true)
    end
end


function LinkAndExpressionDlg:onSpaceButton(sender, eventType)
    self:callBack("addSpace")
end

function LinkAndExpressionDlg:onDelButton(sender, eventType)
    self:callBack("deleteWord")
end

function LinkAndExpressionDlg:onSendButton(sender, eventType)
    self:callBack("sendMessage")
end

function LinkAndExpressionDlg:onWordButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    self:callBack("swichWordInput")
end


function LinkAndExpressionDlg:onShakeButton(sender, eventType)
    -- 点击了震动提醒
    local gid = DlgMgr:sendMsg("FriendDlg", "getCurChatGid")
    local name = DlgMgr:sendMsg("FriendDlg", "getCurChatName")
    local char = FriendMgr:getFriendByGid(gid)

    if not char then
        gf:ShowSmallTips(string.format(CHS[4101024], name))
        return
    end
    if char:queryBasicInt("online") == 2 then
        -- 不在线
        gf:ShowSmallTips(CHS[4101025])
        return
    end

    gf:CmdToServer("CMD_SHOCK_FRIEND", {gid = char:queryBasic("gid")})
end

function LinkAndExpressionDlg:onCharButton(sender, eventType)
    local sendInfo = string.format("{\t%s=%s=%s}", Me:queryBasic("name"), CHS[3002912],  Me:getId())
    local showInfo = string.format("{\29%s\29}", Me:queryBasic("name"))
    self:callBack("addCardInfo", sendInfo, showInfo)
end

function LinkAndExpressionDlg:onStatisticsCheckBox(sender, eventType)
    local sendInfo = string.format("{\t%s=%s=%s}", Me:queryBasic("name"), CHS[7000012],  Me:getId())
    local showInfo = string.format("{\29%s\29}", CHS[7000012])
    self:callBack("addCardInfo", sendInfo, showInfo)
end

function LinkAndExpressionDlg:onHouseCheckBox(sender, eventType)
    if string.isNilOrEmpty(Me:queryBasic("house/id")) then
        gf:ShowSmallTips(CHS[2100096])
        return
    end
    local sendInfo = string.format("{\t%s=%s=%s}", Me:queryBasic("house/id"), CHS[2100095],  Me:getId())
    local showInfo = string.format("{\29%s\29}", string.format(CHS[2100097], Me:queryBasic("name")))
    self:callBack("addCardInfo", sendInfo, showInfo)
end

function LinkAndExpressionDlg:onCallButton(sender, eventType)
    self:callBack("addCallSign")
end

-- 货品：买入方案
function LinkAndExpressionDlg:onTradingSpotSlnButton(sender, eventType)
    if self.waitingTradingSpot then return end

    if not TradingSpotMgr:isTradingSpotOpen() then return end

    if not TradingSpotMgr:isTradingSpotEnable() then
        gf:ShowSmallTips(CHS[7190486])
        return
    end

    if not TradingSpotMgr:isMeLevelMeetCondition() then
        gf:ShowSmallTips(CHS[7190478])
        return
    end

    TradingSpotMgr:requestMainSpotData(1)
    self.waitingTradingSpot = true
end

function LinkAndExpressionDlg:getSelectItemBox(clickItem)
    if "0m" == clickItem then
        local str = "0m"
        if Me:queryBasicInt("gender") == 2 then str = "0f" end
        local ctrl = self:getControl("PageView", Const.UIPageView, self.panelListTable["ExpressionCheckBox"]):getPage(0):getChildByName(str)
        return self:getBoundingBoxInWorldSpace(ctrl)
    end
end

function LinkAndExpressionDlg:onWatchButton(sender, eventType)
    if not WatchCenterMgr:isCombatInWatchCenter() then
        gf:ShowSmallTips(CHS[4100458])
        return
    end

    local data = WatchCenterMgr:getCombatData()
    local sendInfo = string.format("{\t%s=%s=%s}", Me:queryBasic("name"), CHS[4100443],  data.combat_id)
    local showInfo = string.format("{\29%s\29}", CHS[4100443])
    self:callBack("addCardInfo", sendInfo, showInfo)
end

function LinkAndExpressionDlg:onPartyRedBagButton(sender, eventType)
    if Me:queryInt("level") < 50 then
        gf:ShowSmallTips(string.format(CHS[6000473], 50))
        return
    end

    if Me:queryBasic("party/name") == "" then
        gf:ShowSmallTips(CHS[6000474])
        return
    end

    DlgMgr:openDlg("PartyOutRedBagDlg")
end

-- 点击菜单
function LinkAndExpressionDlg:onClickMenu(sender, eventType)
    self:setCtrlVisible("PanicBuyButton", false)
    if self.selectMenuBtn and self.selectMenuBtn.classType ~= sender.classType then
        self.curPage = 1

        self.selectItemData = false
        self.selectItemCell = false
        self:swichCancelAndCollectBtn(false)

        self:setCtrlVisible("UnlockButton", false)

        self:setCtrlVisible("BuyButton", false)
        self:setCtrlVisible("PublicInfoPanel", false)
    end

    -- 设置选中菜单
    self.selectMenuBtn = sender

    -- 排序标志
    self:setSortFlag(self.sortType)

    -- 增加选择菜单选中效果
    self:addSelectImage(sender)

    -- 获取相关商品
    self.listInfo = self:getDataByType(sender.classType)

    self.totalPage = math.floor((#self.listInfo - 1) / PAGE_MAX_COUNT + 1)

    -- 显示右上角，商品个数
    self:setCtrlVisible("CollectionInfoPanel", false)
    self:setCtrlVisible("PanicBuyInfoPanel", false)

    if sender.classType == CHS[4100075] then
        self:setCtrlVisible("CollectionInfoPanel", true)

    elseif sender.classType == CHS[4200201] then
        self:setCtrlVisible("PanicBuyInfoPanel", true)

    end
    self:updateLayout("CollectionInfoPanel")

    -- 设置页码
    self:setPageInfo(self.listInfo)

    -- 设置数据
    local itemsInfo = self:getItemsByPage(self.curPage, PAGE_MAX_COUNT, self.listInfo)

    -- 初始化 ScrollView
    local scrollview = self:getControl("ItemScrollView")
    scrollview:removeAllChildren()
    if not next(self.listInfo) then
        self:setCtrlVisible("NoticePanel", true)
        return
    end
    self:setCtrlVisible("NoticePanel", false)

    -- 设置数据
    self:initListPanel(itemsInfo, self.itemCellCtrl, self.setItemData, scrollview, true)
end

function LinkAndExpressionDlg:setTradeItemInfo(cell, data, ctrlName)
    local imgPath
    local isPet = false
    local goodsType
    if PetMgr:getPetIcon(data.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(data.name))
        data.name = PetMgr:getShowNameByRawName(data.name)
        local petShowName = MarketMgr:getPetShowName(data)
        data.petShowName = petShowName
        isPet = true
    else
        local icon = InventoryMgr:getIconByName(data.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    local goodsImage = self:getControl("IconImage", Const.UIImage, cell)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("IconImage", cell)
    goodsImage:setVisible(true)

    local iconPanel = self:getControl("IconPanel", nil, cell)
    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 设置数量
    if data.amount and data.amount > 1 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 法宝相性
    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end



    local isDesignated = (data.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_APPOINT_SELL)
    local isVendue = (data.sell_type == ZHENBAO_TRADE_TYPE.STALL_SBT_AUCTION)

    if isDesignated or isVendue then
        self:setCtrlVisible("StateBKImage_0", true, cell)
        -- 价格
        self:setCtrlVisible("PricePanel_1", false, cell)
        local panel2 = self:setCtrlVisible("PricePanel_2", true, cell)
        local str, color = gf:getMoneyDesc(data.price, true)
        self:setLabelText("CoinLabel", str, panel2, color)
        self:setLabelText("CoinLabel2", str, panel2)

        local panel3 = self:setCtrlVisible("PricePanel_3", true, cell)
        local str, color = gf:getMoneyDesc(data.buyout_price, true)
        self:setLabelText("CoinLabel", str, panel3, color)
        self:setLabelText("CoinLabel2", str, panel3)

        if isVendue then
            -- 拍卖
            self:setLabelText("SellStateValueLabel_1_0", CHS[4010053], cell)
            self:setLabelText("SellStateValueLabel_2_0", CHS[4010053], cell)

            self:setLabelText("SellTypeLabel", CHS[4101211], panel2)
            self:setLabelText("SellTypeLabel", CHS[4101212], panel3)
        else
            -- 指定交易
            self:setLabelText("SellStateValueLabel_1_0", CHS[4101207], cell)
            self:setLabelText("SellStateValueLabel_2_0", CHS[4101207], cell)
        end
    else
        self:setLabelText("SellStateValueLabel_1_0", "", cell)
        self:setLabelText("SellStateValueLabel_2_0", "", cell)
        self:setCtrlVisible("StateBKImage_0", false, cell)

            -- 价格
        local str, color = gf:getMoneyDesc(data.price, true)
        self:setLabelText("CoinLabel", str, cell, color)
        self:setLabelText("CoinLabel2", str, cell)

        self:setCtrlVisible("PricePanel_1", true, cell)
        self:setCtrlVisible("PricePanel_2", false, cell)
        self:setCtrlVisible("PricePanel_3", false, cell)
    end

    -- 带属性超级黑水晶
    if string.match(data.name, CHS[3003008]) then
        local name = string.gsub(data.name,CHS[3003009],"")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1], cell)
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = data.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003010])[field] then bai = "%" end
        end

        self:setLabelText("NameLabel2", value .. bai .. "/" .. maxValue .. bai, cell)

        self:setCtrlVisible("NameLabel", true, cell)
        self:setCtrlVisible("NameLabel2", true, cell)
        self:setCtrlVisible("OneNameLabel", false, cell)
    else
        -- 名字
        self:setLabelText("OneNameLabel", data.petShowName or data.name, cell)
        self:setCtrlVisible("NameLabel", false, cell)
        self:setCtrlVisible("NameLabel2", false, cell)
    end



    -- 收藏标签
    if self[ctrlName] and self[ctrlName].latSelcelCheckBox == "MyCollectionCheckBox" then
        self:setCtrlVisible("CollectionImage", true, cell)
    else
        self:setCtrlVisible("CollectionImage", false, cell)
    end

    local function touch(sender, eventType)
      --  Log:D("好难找点击响应位置！！集市")
        self:addSelcetImage(cell, ctrlName)
        local type = ctrlName == "MarketItemCheckBox" and CHS[7002311] or CHS[7002312]
        local exchangeType
        if type == CHS[7002311] then
            exchangeType = self["MarketItemCheckBox"].latSelcelCheckBox == "MyCollectionCheckBox" and MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_COLLECTION or MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_MINE
        else
            exchangeType = self["ZhenbaoItemCheckBox"].latSelcelCheckBox == "MyCollectionCheckBox" and MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_COLLECTION or MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_MINE
        end
        local name = data.petShowName or data.name
        local showStr = type .. CHS[7000078] .. name
        local sendInfo = string.format("{\t%s=%s=%s|%d}", showStr, type,  data.id, exchangeType)
        local showInfo = string.format("{\29%s\29}", showStr)
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    self:bindTouchEndEventListener(cell, touch)

    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            touch(cell)

            -- 下方按钮状态
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.FLOAT_DLG,
                rect, isPet, true, self:getTradeType(ctrlName))
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)
    -- iconPanel:setTouchEnabled(false)
end

function LinkAndExpressionDlg:getTradeType(name)
    if name == "MarketItemCheckBox" then
        return MarketMgr.TradeType.marketType
    else
        return MarketMgr.TradeType.goldType
    end
end

function LinkAndExpressionDlg:setMarketItemInfo(cell, item)
    -- 设置商品单元格为货币为金钱
    self:setCtrlVisible("GoldImage", false, cell)
    self:setCtrlVisible("CoinImage", true, cell)

    self:setTradeItemInfo(cell, item, "MarketItemCheckBox")
end

function LinkAndExpressionDlg:setZhenbaoItemInfo(cell, item)
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, cell)
    self:setCtrlVisible("CoinImage", false, cell)

    self:setTradeItemInfo(cell, item, "ZhenbaoItemCheckBox")
end

function LinkAndExpressionDlg:setJubaoItemInfo(cell, data)
    local name
    local iconPanel = self:getControl("IconPanel", nil, cell)
    if not data.para then
        -- 角色自己
        -- 名字
        name = Me:getShowName()
        self:setLabelText("OneNameLabel", name, cell)

        -- 头像
        self:setImage("IconImage", ResMgr:getSmallPortrait(Me:queryBasicInt("icon")), cell)
        self:setItemImageSize("IconImage", cell)

        local level = Me:queryInt("level")
        if level ~= 0 then
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 19)
        end
    else
        local info = json.decode(data.para)
        for field, value in pairs(info) do
            data[field] = value
        end

        if data.level ~= 0 then
            self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19)
        end

        local bigType = math.floor(data.goods_type / 100)
        if bigType == JUBAO_SELL_TYPE.SALE_TYPE_PET or bigType == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
            self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), cell)
        else
            self:setImage("IconImage", ResMgr:getItemIconPath(data.icon), cell)

            -- 如果有相性
            InventoryMgr:addPetPolarImage(self:getControl("IconImage", nil, cell), data.polar)
        end

        -- 名称
        name = data.goods_name
        self:setLabelText("OneNameLabel", data.goods_name, cell)
    end

    -- 收藏
    local gid_key = data.goods_gid
    if self["JubaoItemCheckBox"] and self["JubaoItemCheckBox"].latSelcelCheckBox == "MyCollectionCheckBox" then
        self:setCtrlVisible("CollectionImage", true, cell)
        gid_key = gid_key .. "|" .. "2" .. "|" .. data.list_type
    else
        self:setCtrlVisible("CollectionImage", false, cell)
        gid_key = gid_key .. "|" .. "1"
    end

    -- 价格
    local cashText = gf:getArtFontMoneyDesc(tonumber(data.price))

    for i = 1, 3 do
        self:setCtrlVisible("PricePanel_" .. i, false, cell)
    end

    if data.butout_price and data.butout_price > 0 and data.sell_buy_type ~= TRADE_SBT.AUCTION then

        local panel1 = self:setCtrlVisible("PricePanel_2", true, cell)
        panel1:setVisible(true)
        self:setLabelText("SellTypeLabel", CHS[4101056], panel1)
        self:setNumImgForPanel("RMBValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 17, panel1)

        local panel2 = self:setCtrlVisible("PricePanel_3", true, cell)
        panel2:setVisible(true)
        self:setLabelText("SellTypeLabel", CHS[4101057], panel2)

        local cashText2 = gf:getArtFontMoneyDesc(tonumber(data.butout_price))
        self:setNumImgForPanel("RMBValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText2, false, LOCATE_POSITION.LEFT_TOP, 17, panel2)
    elseif data.sell_buy_type == TRADE_SBT.AUCTION and data.state == TRADING_STATE.AUCTION then

        local panel1 = self:setCtrlVisible("PricePanel_2", true, cell)
        panel1:setVisible(true)
        self:setLabelText("SellTypeLabel", CHS[4200524], panel1)
        self:setNumImgForPanel("RMBValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.LEFT_BOTTOM, 17, panel1)

        local panel2 = self:setCtrlVisible("PricePanel_3", true, cell)
        panel2:setVisible(true)
        self:setLabelText("SellTypeLabel", CHS[4200525], panel2)

        local cashText2 = gf:getArtFontMoneyDesc(tonumber(data.butout_price))
        self:setNumImgForPanel("RMBValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText2, false, LOCATE_POSITION.LEFT_TOP, 17, panel2)
    else
        local panel1 = self:setCtrlVisible("PricePanel_1", true, cell)
        panel1:setVisible(true)
        self:setNumImgForPanel("RMBValuePanel", ART_FONT_COLOR.DEFAULT, "$" .. cashText, false, LOCATE_POSITION.LEFT_TOP, 17, panel1)
    end

	-- 聊天链接
    TradingMgr:setSellBuyTypeFlag(data.sell_buy_type, self, cell)


    local function touch(sender, eventType)
     --   Log:D("好难找点击响应位置！！聚宝")
        self:addSelcetImage(cell, "JubaoItemCheckBox")
        local showStr = CHS[5410123] .. CHS[7000078] .. name
        local sendInfo = string.format("{\t%s=%s=%s}", showStr, CHS[5410123],  gid_key)
        local showInfo = string.format("{\29%s\29}", showStr)
        self:callBack("addCardInfo", sendInfo, showInfo)
    end

    self:bindTouchEndEventListener(cell, touch)

    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            touch(cell)
            if not data.goods_type then
                return
            end

            local goodsType = math.floor(data.goods_type / 100)
            if goodsType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON
                or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then

                TradingMgr:tradingSnapshot(data.goods_gid, TRAD_SNAPSHOT.SNAPSHOT, 0, 1)
            end
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)
end

function LinkAndExpressionDlg:onMarketItemCheckBox(sender, type)
    if self["MarketItemCheckBox"] == nil then
        self["MarketItemCheckBox"] = {}
    end

    if self["MarketItemCheckBox"].latSelcelCheckBox  == sender:getName() then
        return
    end

    self:setCtrlVisible("NoCollectionLabel", false, "MarketItemPanel")
    self:setCtrlVisible("NoItemLabel", false, "MarketItemPanel")

    local dataTable
    local clonePanel = self.marketItemCell
    local func = self.setMarketItemInfo
    if sender:getName() == "MyGoodsCheckBox" then
        if not self.myMarketStallItemInfo then
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_MY_STALL)
            dataTable = {}
        else
            dataTable = self.myMarketStallItemInfo
        end

        if #dataTable == 0 then
            self:setCtrlVisible("NoItemLabel", true, "MarketItemPanel")
        end
    else
        if not self.myCollectMarketItemInfo then
            dataTable = self:getShowItems(MarketMgr:getCollectDataByType(CHS[4100075], MarketMgr.TradeType.marketType))
            MarketMgr:checkCollectItemStatus(MarketMgr.TradeType.marketType)
        else
            dataTable = self.myCollectMarketItemInfo
        end

        if #dataTable == 0 then
            self:setCtrlVisible("NoCollectionLabel", true, "MarketItemPanel")
        end
    end

    self["MarketItemCheckBox"].selectImg = nil

    self["MarketItemCheckBox"].latSelcelCheckBox = sender:getName()
    self:createPages("MarketItemCheckBox", clonePanel, dataTable, func)
end

function LinkAndExpressionDlg:onZhenbaoItemCheckBox(sender, type)
    if self["ZhenbaoItemCheckBox"] == nil then
        self["ZhenbaoItemCheckBox"] = {}
    end

    if self["ZhenbaoItemCheckBox"].latSelcelCheckBox  == sender:getName() then
        return
    end

    self:setCtrlVisible("NoCollectionLabel", false, "ZhenbaoItemPanel")
    self:setCtrlVisible("NoItemLabel", false, "ZhenbaoItemPanel")

    local dataTable
    local clonePanel = self.zhenbaoItemCell
    local func = self.setZhenbaoItemInfo
    if sender:getName() == "MyGoodsCheckBox" then
        if not self.myZhenbaoStallItemInfo then
            MarketMgr:requestRefreshMySell(MarketMgr.TradeType.goldType)
            dataTable = {}
        else
            dataTable = self.myZhenbaoStallItemInfo
        end

        if #dataTable == 0 then
            self:setCtrlVisible("NoItemLabel", true, "ZhenbaoItemPanel")
        end
    else
        if not self.myColoectZhenbaoItemInfo then
            dataTable = self:getShowItems(MarketMgr:getCollectDataByType(CHS[4100075], MarketMgr.TradeType.goldType))
            MarketMgr:checkCollectItemStatus(MarketMgr.TradeType.goldType)
        else
            dataTable = self.myColoectZhenbaoItemInfo
        end

        if #dataTable == 0 then
            self:setCtrlVisible("NoCollectionLabel", true, "ZhenbaoItemPanel")
        end
    end

    self["ZhenbaoItemCheckBox"].selectImg = nil

    self["ZhenbaoItemCheckBox"].latSelcelCheckBox = sender:getName()
    self:createPages("ZhenbaoItemCheckBox", clonePanel, dataTable, func)
end

function LinkAndExpressionDlg:onJubaoItemCheckBox(sender, type)
    if self["JubaoItemCheckBox"] == nil then
        self["JubaoItemCheckBox"] = {}
    end

    if self["JubaoItemCheckBox"].latSelcelCheckBox  == sender:getName() then
        return
    end

    self:setCtrlVisible("NoCollectionLabel", false, "JubaoItemPanel")
    self:setCtrlVisible("NoItemLabel", false, "JubaoItemPanel")

    local dataTable
    local clonePanel = self.jubaoItemCell
    local func = self.setJubaoItemInfo
    if sender:getName() == "MyGoodsCheckBox" then
        dataTable =  self:getTradingData()
        if #dataTable == 0 then
            self:setCtrlVisible("NoItemLabel", true, "JubaoItemPanel")
        end
    else
        dataTable = self:getJubaoCollectdata()
        if not dataTable then
            TradingMgr:queryTradingCollectList(TradingMgr.LIST_TYPE.SALE_LIST)
            TradingMgr:queryTradingCollectList(TradingMgr.LIST_TYPE.SHOW_LIST)
            TradingMgr:queryTradingCollectList(TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST)
            TradingMgr:queryTradingCollectList(TradingMgr.LIST_TYPE.AUCTION_LIST)
            dataTable = {}
        end

        if #dataTable == 0 then
            self:setCtrlVisible("NoCollectionLabel", true, "JubaoItemPanel")
        end
    end

    self["JubaoItemCheckBox"].selectImg = nil

    self["JubaoItemCheckBox"].latSelcelCheckBox = sender:getName()
    self:createPages("JubaoItemCheckBox", clonePanel, dataTable, func)
end

function LinkAndExpressionDlg:getShowItems(allItems)
    local items = {}
    for _, v in ipairs(allItems) do
        local itemName = MarketMgr:getItemNameForJudgePublicity(v)
        if v.status ~= 3 and MarketMgr:isPublicityItem(itemName) then
            -- 超时不显示
            table.insert(items, v)
        end
    end

    local function sortMarketItem(l, r)
        if l.price > r.price then return true end
        if l.price < r.price then return false end

        if l.startTime > r.startTime then return true end
        if l.startTime < r.startTime then return false end

        return false
    end

    table.sort(items, sortMarketItem)

    return items
end

function LinkAndExpressionDlg:getMainBodyHeight()
    local mainPanel = self:getControl("MainBodyPanel")
    return mainPanel:getContentSize().height * self.root:getScale()
end

-- 集市摆摊信息
function LinkAndExpressionDlg:MSG_STALL_MINE(data)
    self.myMarketStallItemInfo = self:getShowItems(MarketMgr:getMySellItemListInfo(MarketMgr.TradeType.marketType).items or {})
    if not self["MarketItemCheckBox"] or self["MarketItemCheckBox"].latSelcelCheckBox ~= "MyGoodsCheckBox" then
        return
    end

    local clonePanel = self.marketItemCell
    local func = self.setMarketItemInfo
    self["MarketItemCheckBox"].selectImg = nil
    self:createPages("MarketItemCheckBox", clonePanel, self.myMarketStallItemInfo, func)
    if #self.myMarketStallItemInfo == 0 then
        self:setCtrlVisible("NoCollectionLabel", false, "MarketItemPanel")
        self:setCtrlVisible("NoItemLabel", true, "MarketItemPanel")
    else
        self:setCtrlVisible("NoCollectionLabel", false, "MarketItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "MarketItemPanel")
    end
end

-- 集市收藏信息
function LinkAndExpressionDlg:MSG_MARKET_CHECK_RESULT(data)
    self.myCollectMarketItemInfo = self:getShowItems(MarketMgr:getCollectDataByType(CHS[4100075], MarketMgr.TradeType.marketType))
    if not self["MarketItemCheckBox"] or self["MarketItemCheckBox"].latSelcelCheckBox ~= "MyCollectionCheckBox" then
        return
    end

    local clonePanel = self.marketItemCell
    local func = self.setMarketItemInfo
    self["MarketItemCheckBox"].selectImg = nil
    self:createPages("MarketItemCheckBox", clonePanel, self.myCollectMarketItemInfo, func)
    if #self.myCollectMarketItemInfo == 0 then
        self:setCtrlVisible("NoCollectionLabel", true, "MarketItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "MarketItemPanel")
    else
        self:setCtrlVisible("NoCollectionLabel", false, "MarketItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "MarketItemPanel")
    end
end

-- 珍宝摆摊信息
function LinkAndExpressionDlg:MSG_GOLD_STALL_MINE(data)
    self.myZhenbaoStallItemInfo = self:getShowItems(MarketMgr:getMySellItemListInfo(MarketMgr.TradeType.goldType).items or {})
    if not self["ZhenbaoItemCheckBox"] or self["ZhenbaoItemCheckBox"].latSelcelCheckBox ~= "MyGoodsCheckBox" then
        return
    end

    local clonePanel = self.zhenbaoItemCell
    local func = self.setZhenbaoItemInfo
    self["ZhenbaoItemCheckBox"].selectImg = nil
    self:createPages("ZhenbaoItemCheckBox", clonePanel, self.myZhenbaoStallItemInfo, func)
    if #self.myZhenbaoStallItemInfo == 0 then
        self:setCtrlVisible("NoCollectionLabel", false, "ZhenbaoItemPanel")
        self:setCtrlVisible("NoItemLabel", true, "ZhenbaoItemPanel")
    else
        self:setCtrlVisible("NoCollectionLabel", false, "ZhenbaoItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "ZhenbaoItemPanel")
    end
end

-- 珍宝收藏信息
function LinkAndExpressionDlg:MSG_GOLD_STALL_GOODS_STATE(data)
    self.myColoectZhenbaoItemInfo = self:getShowItems(MarketMgr:getCollectDataByType(CHS[4100075], MarketMgr.TradeType.goldType))
    if not self["ZhenbaoItemCheckBox"] or self["ZhenbaoItemCheckBox"].latSelcelCheckBox ~= "MyCollectionCheckBox" then
        return
    end

    local clonePanel = self.zhenbaoItemCell
    local func = self.setZhenbaoItemInfo
    self["ZhenbaoItemCheckBox"].selectImg = nil
    self:createPages("ZhenbaoItemCheckBox", clonePanel, self.myColoectZhenbaoItemInfo, func)
    if #self.myColoectZhenbaoItemInfo == 0 then
        self:setCtrlVisible("NoCollectionLabel", true, "ZhenbaoItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "ZhenbaoItemPanel")
    else
        self:setCtrlVisible("NoCollectionLabel", false, "ZhenbaoItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "ZhenbaoItemPanel")
    end
end

local function sortTradItem(l, r)
    if l.price > r.price then return true end
    if l.price < r.price then return false end

    if l.end_time > r.end_time then return true end
    if l.end_time < r.end_time then return false end

    return false
end

function LinkAndExpressionDlg:getJubaoCollectdata()
    if not self.myJbzCollectItemInfo[TradingMgr.LIST_TYPE.SALE_LIST]
        or not self.myJbzCollectItemInfo[TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST]
        or not self.myJbzCollectItemInfo[TradingMgr.LIST_TYPE.AUCTION_LIST]
        or not self.myJbzCollectItemInfo[TradingMgr.LIST_TYPE.SHOW_LIST] then
        -- 聚宝的出售收藏和公示收藏信息是分开获取的，等消息都收到后再处理
        return
    end

    local data = {}

    for listType, dataTab in pairs(self.myJbzCollectItemInfo) do
        for _, v in ipairs(dataTab) do
            if v.state ~= TRADING_STATE.TIMEOUT and v.goods_type ~= TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
                -- 超时商品和金钱类商品不显示
                local item = gf:deepCopy(v)
                item.collectType = TradingMgr.LIST_TYPE.SALE_LIST
                table.insert(data, item)
            end
        end
    end


--[[

    for _, v in ipairs(self.myJbzCollectItemInfo[TradingMgr.LIST_TYPE.SHOW_LIST]) do
        if v.state ~= TRADING_STATE.TIMEOUT and v.goods_type ~= TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
            -- 超时商品和金钱类商品不显示
            local item = gf:deepCopy(v)
            item.collectType = TradingMgr.LIST_TYPE.SHOW_LIST
            table.insert(data, item)
        end
    end
--]]
    table.sort(data, sortTradItem)

    return data
end

-- 聚宝斋收藏物品信息
function LinkAndExpressionDlg:MSG_TRADING_FAVORITE_LIST(data)
    self.myJbzCollectItemInfo[data.list_type] = data.goods

    if not self["JubaoItemCheckBox"] or self["JubaoItemCheckBox"].latSelcelCheckBox ~= "MyCollectionCheckBox" then
        return
    end

    local dataTable = self:getJubaoCollectdata()
    if dataTable then
        local clonePanel = self.jubaoItemCell
        local func = self.setJubaoItemInfo
        self["JubaoItemCheckBox"].selectImg = nil
        self:createPages("JubaoItemCheckBox", clonePanel, dataTable, func)
        if #dataTable == 0 then
            self:setCtrlVisible("NoCollectionLabel", true, "JubaoItemPanel")
            self:setCtrlVisible("NoItemLabel", false, "JubaoItemPanel")
        else
            self:setCtrlVisible("NoCollectionLabel", false, "JubaoItemPanel")
            self:setCtrlVisible("NoItemLabel", false, "JubaoItemPanel")
        end
    end
end

function LinkAndExpressionDlg:getTradingData()
    local items = {}
    local dataTable = TradingMgr:getTradingData() or {}
    for _, v in ipairs(dataTable) do
        if v.state ~= TRADING_STATE.TIMEOUT and v.goods_type ~= TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
            -- 超时商品和金钱类商品不显示
            table.insert(items, v)
        end
    end

    table.sort(items, sortTradItem)
    return items
end

function LinkAndExpressionDlg:MSG_TRADING_GOODS_MINE()
    if not self["JubaoItemCheckBox"] or self["JubaoItemCheckBox"].latSelcelCheckBox ~= "MyGoodsCheckBox" then
        return
    end

    local clonePanel = self.jubaoItemCell
    local func = self.setJubaoItemInfo
    local dataTable = self:getTradingData()
    self["JubaoItemCheckBox"].selectImg = nil
    self:createPages("JubaoItemCheckBox", clonePanel, dataTable, func)
    if #dataTable == 0 then
        self:setCtrlVisible("NoCollectionLabel", false, "JubaoItemPanel")
        self:setCtrlVisible("NoItemLabel", true, "JubaoItemPanel")
    else
        self:setCtrlVisible("NoCollectionLabel", false, "JubaoItemPanel")
        self:setCtrlVisible("NoItemLabel", false, "JubaoItemPanel")
    end
end

function LinkAndExpressionDlg:MSG_TRADING_ROLE()
    self:MSG_TRADING_GOODS_MINE()
end

-- 聚宝斋显示名片
function LinkAndExpressionDlg:MSG_TRADING_SNAPSHOT(data)
    if data.snapshot_type ~= TRAD_SNAPSHOT.SNAPSHOT then return end
    if data.isShowCard == 0 then return end

    local goodsType = math.floor(data.goods_type / 100)
    if goodsType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON
        or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then

        local jsonData
        if pcall(function()
            jsonData = json.decode(data.content)
        end) then
        else
            return
        end

        local equipTemp = TradingMgr:changeIndexToFieldByEquip(jsonData)
        local equip = TradingMgr:getEquipByData(equipTemp)
        equip.isJubao = true
        InventoryMgr:showOnlyFloatCardDlg(equip)
    end
end

-- 货站买过的商品
function LinkAndExpressionDlg:MSG_TRADING_SPOT_CARD_GOODS_LIST(data)
    if self.radioGroup:getSelectedRadioName() == "TradingSpotCheckBox"
        and self.tradingSpotRadioGroup:getSelectedRadioName() == "BuyCheckBox" then
        -- 界面还停留在货站买过选项
        if data.count > 0 then
            table.sort(data.list, function(l, r)
                if l.goods_id < r.goods_id then return true end
                if l.goods_id > r.goods_id then return false end
            end)

            local retList = {}
            for i = 1, data.count do
                local itemName, _ = TradingSpotMgr:getItemInfo(data.list[i].goods_id)
                table.insert(retList, {goodsId = data.list[i].goods_id, name = itemName})
            end

            self:setCtrlVisible("NoItemLabel", false, "TradingSpotItemPanel")
            self:setCtrlVisible("PageView", true, "TradingSpotItemPanel")
            self:createPages("TradingSpotCheckBox", self.tradingSpotItemCell, retList, self.setTradingSpotCellInfo)
        else
            self:setCtrlVisible("NoItemLabel", true, "TradingSpotItemPanel")
            self:setCtrlVisible("PageView", false, "TradingSpotItemPanel")
        end
    end
end

-- 货站主界面数据,用于打开货品买入方案
function LinkAndExpressionDlg:MSG_TRADING_SPOT_DATA(data)
    if self.waitingTradingSpot then
        self.waitingTradingSpot = nil

        if TradingSpotMgr:isInRestTime() then
            gf:ShowSmallTips(CHS[7190498])
            return
        end

        local itemList = TradingSpotMgr:getGoodsListByType(2)
        if #itemList <= 0 then
            gf:ShowSmallTips(CHS[7190491])
            return
        end

        if TradingSpotMgr:checkCloseTradingTime() then
            gf:ShowSmallTips(CHS[7190492])
            return
        end

        local sendInfo = string.format("{\t%s=%s=%s}", CHS[7190487], CHS[7190487], data.trading_no)
        local showInfo = string.format("{\29%s\29}", string.format(CHS[7190484], CHS[7190487]))
        self:callBack("addCardInfo", sendInfo, showInfo)
    end
end

return LinkAndExpressionDlg
