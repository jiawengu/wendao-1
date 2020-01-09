-- ChangeCardIllustrationDlg.lua
-- Created by songce Apr/27/2015
-- 变身卡图鉴

local ChangeCardIllustrationDlg = Singleton("ChangeCardIllustrationDlg", Dialog)
local GridPanel = require('ctrl/GridPanel')
local Group = require('ctrl/RadioGroup')
local PageTag = require('ctrl/PageTag')
local Bitset = require("core/Bitset")

-- 普遍宠物列表信息
local normalPetList = require(ResMgr:getCfgPath('NormalPetList.lua'))

-- 格子的高宽
local GRID_WIDTH = 74
local GRID_HEIGHT = 74

-- 格子间的间隔
local GRID_MARGIN_WIDTH = 12.5
local GRID_MARGIN_HEIGHT = 4

-- 设置文本Margin
local TEXT_MARGIN_RIGHT = 20
local TEXT_MARGIN_BOTTOM = 15

-- 每页显示列数、行数、总个数
local COL_PER_PAGE = 3
local ROW_PER_PAGE = 5
local NUM_PER_PAGE = COL_PER_PAGE * ROW_PER_PAGE

ChangeCardIllustrationDlg.pageLastSelectIndex = {}
ChangeCardIllustrationDlg.gotFlag = {}

function ChangeCardIllustrationDlg:init()
    self:bindListener("ExpandButton", self.onExpandButton)
    self:bindListener("CatchNoteButton", self.onCatchNoteButton)
    self:bindListener("MaketBuyButton", self.onMaketBuyButton)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("CardTypeCheckBox", self.onCardTypeCheckBox)
    self:bindListener("RefreshButton", self.onRefreshButton)

    self:bindListener("AllCardPanel", self.onChoseCardType)
    self:bindListener("MonsterPanel", self.onChoseCardType)
    self:bindListener("ElitePanel", self.onChoseCardType)
    self:bindListener("EpicPanel", self.onChoseCardType)
    self:bindListener("BossPanel", self.onChoseCardType)
    self:bindListener("BackGroundPanel", self.onMainPanel)

    self:bindListener("BackImage", self.onTextField, "ListButtonPanel")

    -- 保存变身卡形象图片的初始位置
    local x, y = self:getControl("CardImage", nil, "ImagePanel"):getPosition()
    self.shapeImgPos = {x = x, y = y}

    self:initDisplay()

    self.cardInfo = nil
    -- 本地数据初始化
    if not self.allCards then self:initCardData() end

    self:setUIData()

    -- 克隆属性按钮
    self.attribPanel = self:getControl("ProPanel")
    self.attribPanel:retain()
    self.attribPanel:removeFromParent()

    self.selectEff = self:getControl("PetsImage", nil, self.attribPanel)
    self.selectEff:retain()
    self.selectEff:removeFromParent()
    self.selectEff:setVisible(true)

    self:initAttribList()


    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_CL_CARD_INFO")

    self:MSG_UPDATE()
end

function ChangeCardIllustrationDlg:setUIData()
    -- 更新卡片是否获取过
    self:updateGetInfo()

    -- 设置默认（全部宠物）
    self.curPageIndex = self.curPageIndex or 1
    if self.searchRet then
        self.cardType = "AllCardPanel"
        self:setLabelText("Label1", CHS[4100075])
        self:setCardList(self.searchRet)
        self:setInputText("TextField", self.condition, nil, COLOR3.TEXT_DEFAULT)
        self:setCtrlVisible("Image_122", false)
        self:setCtrlVisible("RefreshButton", true)
    else
        self.cardType = self.cardType or "AllCardPanel"
        self:setCardListByCardType(self.cardType)
    end
end

function ChangeCardIllustrationDlg:cleanup()
    if self.attribPanel then
        self.attribPanel:release()
        self.attribPanel = nil
    end

    if self.selectEff then
        self.selectEff:release()
        self.selectEff = nil
    end
end

function ChangeCardIllustrationDlg:initAttribList()
    local attribute = InventoryMgr:getAllCardAttrib()
    local list = self:resetListView("ListView", 4, ccui.ListViewGravity.centerVertical)
    for i = 1, #attribute do
        local panel = self.attribPanel:clone()
        panel.attribute = attribute[i]
        self:setLabelText("NameLabel", attribute[i].chs, panel)
        list:pushBackCustomItem(panel)

        self:bindTouchEndEventListener(panel, function ()
            self:addSelectEff(panel)
            self:setCtrlVisible("ChoseAttribPanel", false)
            self:setInputText("TextField", panel.attribute.chs, nil, COLOR3.TEXT_DEFAULT)
            self:setCtrlVisible("Image_122", false)
            self:setCtrlVisible("RefreshButton", true)
        end)
    end
end

function ChangeCardIllustrationDlg:addSelectEff(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

-- 初始化对话框，隐藏一些控件
function ChangeCardIllustrationDlg:setCardListByCardType(cardType)
    if cardType == "AllCardPanel" then
        self:setCardList(self.allCards)
        self:setLabelText("Label1", CHS[4100075])
    elseif cardType == "MonsterPanel" then
        self:setCardList(self.monsterCards)
        self:setLabelText("Label1", CHS[4100076])
    elseif cardType == "ElitePanel" then
        self:setCardList(self.eliteCards)
        self:setLabelText("Label1", CHS[4100077])
    elseif cardType == "BossPanel" then
        self:setCardList(self.bossCards)
        self:setLabelText("Label1", CHS[4100078])
    elseif cardType == "EpicPanel" then
        self:setCardList(self.epicCards)
        self:setLabelText("Label1", CHS[5450057])
    end
end

-- 初始化对话框，隐藏一些控件
function ChangeCardIllustrationDlg:initDisplay()
    self:setCtrlVisible("ChoseMenuPanel", false)
    self:setCtrlVisible("ChoseAttribPanel", false)

    self:setCtrlVisible("CatchNoteButton", false)
end

-- 将变身卡按页码保存后
function ChangeCardIllustrationDlg:setCardsPage(cards)
    local destCards = {}

    table.sort(cards, function(l, r)
        if ORDER_BY_CARD_TYPE[l.card_type] < ORDER_BY_CARD_TYPE[r.card_type] then return true end
        if ORDER_BY_CARD_TYPE[l.card_type] > ORDER_BY_CARD_TYPE[r.card_type] then return false end
        if l.order < r.order then return true end
        if l.order > r.order then return false end
    end)

    for i = 1, #cards do
        local page = math.floor((i - 1) / NUM_PER_PAGE) + 1
        if not destCards[page] then destCards[page] = {} end
        table.insert(destCards[page], cards[i])
    end

    for i = 1, #destCards do
        local count = #destCards[i]
        destCards[i].count = count
    end
    return destCards
end

-- 将各种变身卡按需求保存
function ChangeCardIllustrationDlg:initCardData()
    local cards = InventoryMgr:getAllCardInfo()
    local allCards = {}
    local monsterCards = {}
    local eliteCards = {}
    local bossCards = {}
    local epicCards = {}
    for cardName, cardInfo in pairs(cards) do
        cardInfo.cardName = cardName
        local icon = InventoryMgr:getIconByName(cardName)
        cardInfo.imgFile = ResMgr:getItemIconPath(icon)

        if cardInfo.card_type == CARD_TYPE.MONSTER then
            table.insert(monsterCards, cardInfo)
        elseif cardInfo.card_type == CARD_TYPE.ELITE then
            table.insert(eliteCards, cardInfo)
        elseif cardInfo.card_type == CARD_TYPE.BOSS then
            table.insert(bossCards, cardInfo)
        elseif cardInfo.card_type == CARD_TYPE.EPIC then
            table.insert(epicCards, cardInfo)
        end
        table.insert(allCards, cardInfo)
    end

    self.allCards = self:setCardsPage(allCards)
    self.monsterCards = self:setCardsPage(monsterCards)
    self.eliteCards = self:setCardsPage(eliteCards)
    self.bossCards = self:setCardsPage(bossCards)
    self.epicCards = self:setCardsPage(epicCards)
end

-- 更新
function ChangeCardIllustrationDlg:updateGetInfo()
    local count = 0
    self.gotFlag[1] = Bitset.new(StoreMgr:getCardIsGotInfo()[1] or 0)
    self.gotFlag[2] = Bitset.new(StoreMgr:getCardIsGotInfo()[2] or 0)
    self.gotFlag[3] = Bitset.new(StoreMgr:getCardIsGotInfo()[3] or 0)
    self.gotFlag[4] = Bitset.new(StoreMgr:getCardIsGotInfo()[4] or 0)

    local function isGot(order)
        if order <= 32 then
            return self.gotFlag[1]:isSet(order)
        elseif order <= 64 then
            return self.gotFlag[2]:isSet(order - 32)
        elseif order <= 96 then
            return self.gotFlag[3]:isSet(order - 64)
        else
            return self.gotFlag[4]:isSet(order - 96)
        end
    end

    for i = 1, #self.allCards do
        for j = 1, self.allCards[i].count do
            self.allCards[i][j].grayImg = not isGot(self.allCards[i][j].order)
            if not self.allCards[i][j].grayImg then
                count = count + 1
            end
        end
    end

    for i = 1, #self.monsterCards do
        for j = 1, self.monsterCards[i].count do
            self.monsterCards[i][j].grayImg = not isGot(self.monsterCards[i][j].order)
        end
    end

    for i = 1, #self.eliteCards do
        for j = 1, self.eliteCards[i].count do
            self.eliteCards[i][j].grayImg = not isGot(self.eliteCards[i][j].order)
        end
    end

    for i = 1, #self.bossCards do
        for j = 1, self.bossCards[i].count do
            self.bossCards[i][j].grayImg = not isGot(self.bossCards[i][j].order)
        end
    end

    for i = 1, #self.epicCards do
        for j = 1, self.epicCards[i].count do
            self.epicCards[i][j].grayImg = not isGot(self.epicCards[i][j].order)
        end
    end

    self.kindCount = count
end

function ChangeCardIllustrationDlg:setCardList(cards)
    self.showCardList = cards
    local pageView = self:getControl('PageView', Const.UIPageView)
    local contentSize = pageView:getContentSize()
    pageView:removeAllPages()

    if not next(cards) then return end

    for i = 1, #cards do
        local startIndex = 1
        local page = GridPanel.new(contentSize.width, contentSize.height,
            ROW_PER_PAGE, COL_PER_PAGE,  GRID_WIDTH, GRID_HEIGHT, GRID_MARGIN_HEIGHT, GRID_MARGIN_WIDTH)

        -- 额外设置grid上边距
        page:setGridTop(0)
        -- 额外设置文本margin
        page:setTextMargin(TEXT_MARGIN_RIGHT, TEXT_MARGIN_BOTTOM)
        page:setData(self.showCardList[i], startIndex, function(index, sender)
            self.pageLastSelectIndex[i] = index
            self.curPageIndex = i
            self:showCardInfo(index, self.showCardList[i])
        end)
        pageView:addPage(page)
        if not self.pageLastSelectIndex[i] then
            self.pageLastSelectIndex[i] = {}
            self.pageLastSelectIndex[i] = 1
            page:setSelectedGrid(1, 1)
        end
        startIndex = startIndex + NUM_PER_PAGE
    end

    -- 绑定分页控件和分页标签
    local pageTagPanel = self:getControl("PageTagPanel")
    pageTagPanel:removeAllChildren()
    local pageTag = PageTag.new(#cards)
    local tagPanelSz = pageTagPanel:getContentSize()
    pageTag:ignoreAnchorPointForPosition(false)
    pageTag:setAnchorPoint(0.5, 0)
    pageTag:setPositionX(tagPanelSz.width / 2)
    pageTagPanel:addChild(pageTag)
    self:bindPageViewAndPageTag(pageView, pageTag, self.onPageChanged)
    pageTag:setPage(self.curPageIndex - 1)
    performWithDelay(pageTag, function()
        -- 显示选中的宠物信息
        pageTag:setPage(self.curPageIndex)
        for i = 1, #self.pageLastSelectIndex do
            local page = pageView:getPage(i - 1)
            page:setSelectedGridByIndex(self.pageLastSelectIndex[i])
            page:setPositionX((i - self.curPageIndex) * page:getContentSize().width)
        end
        self:showCardInfo(self.pageLastSelectIndex[self.curPageIndex], cards[self.curPageIndex])
        pageView:scrollToPage(self.curPageIndex - 1)
    end, 0)
end

-- 换页面了
function ChangeCardIllustrationDlg:onPageChanged(pageIdx)
    local lastSelectIndex = self.pageLastSelectIndex[pageIdx]
    self.curPageIndex = pageIdx
    self:showCardInfo(lastSelectIndex, self.showCardList[pageIdx])

end

function ChangeCardIllustrationDlg:showCardInfo(index, cardList)
    self.cardInfo = cardList[index]
    local cardInfo = self.cardInfo
    local shapePanel = self:getControl("ImagePanel")

    -- 变身卡等级
    self:setLabelText("LevelLabel_3", cardInfo.card_level, shapePanel)
    self:setLabelText("LevelLabel_4", cardInfo.card_level, shapePanel)

    -- 变身卡宠物半身像
    local petName = string.match(cardInfo.cardName, CHS[4100079])
    local pet = PetMgr:getPetCfg(petName)
    local icon = cardInfo.portrait or pet.icon
    local iconPath = ResMgr:getBigPortrait(icon)

    self:setImage("CardImage", iconPath, "ImagePanel")

    local offset = InventoryMgr:getChangeCardShapeOffset(icon)
    local img = self:getControl("CardImage", nil, "ImagePanel")
    img:setPosition(self.shapeImgPos.x + offset.x, self.shapeImgPos.y + offset.y)

    local polar = gf:getPolar(cardInfo.polar)
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PropertyImage", polarPath, "ImagePanel")
    -- 宠物名
    local showName = cardInfo.cardName
    self:setLabelText("NameLabel", showName, "InfoPanel")
    self:setLabelText("NameLabel_2", showName, "InfoPanel")

    -- 基本属性
    for i = 1, #cardInfo.attrib do
        local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)
        self:setLabelText("AttNameLabel" .. i, cardInfo.attrib[i].chs, nil, COLOR3.BLUE)
        local valueStr = ""
        if cardInfo.attrib[i].value > 0 then
            if cardInfo.grayImg then
                -- 置灰代表没有获得过，显示？号
                valueStr = "+?" .. perce
            else
                valueStr = string.format("+%d", cardInfo.attrib[i].value) .. perce
            end
        else
            if cardInfo.grayImg then
                -- 置灰代表没有获得过，显示？号
                valueStr = "-?" .. perce
            else
                valueStr = string.format("%d", cardInfo.attrib[i].value) .. perce
        end
        end
        self:setLabelText("AttValueLabel" .. i, valueStr, nil, COLOR3.BLUE)
    end
    -- 阵法属性
    local battleArrayAttribTab = cardInfo.battle_arr

    local start = #cardInfo.attrib
    for i = 1, #battleArrayAttribTab do
        local perce = InventoryMgr:isPercentChangeAtt(cardInfo.attrib[i].field)
        local att = battleArrayAttribTab[i]
        self:setLabelText("AttNameLabel" .. (start + i), att.chs, nil, COLOR3.GRAY)
        local valueStr = ""
        if att.value > 0 then
            if cardInfo.grayImg then
                -- 置灰代表没有获得过，显示？号
                valueStr = "+?" .. perce
            else
                valueStr = string.format("+%d", att.value) .. perce
            end
        else
            if cardInfo.grayImg then
                -- 置灰代表没有获得过，显示？号
                valueStr = "-?" .. perce
            else
                valueStr = string.format("%d", att.value) .. perce
        end
        end
        self:setLabelText("AttValueLabel" .. (start + i), valueStr, nil, COLOR3.GRAY)
    end

    -- 持续时间
    local index = #cardInfo.attrib + #cardInfo.battle_arr + 1
    self:setLabelText("AttNameLabel" .. index, CHS[4100092], nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("AttValueLabel" .. index, string.format(CHS[4100093], InventoryMgr:getCardChangeTime(cardInfo.card_type)), nil, COLOR3.TEXT_DEFAULT)

    for i = #cardInfo.attrib + #battleArrayAttribTab + 2, 11 do
        self:setLabelText("AttNameLabel" .. i, "")
        self:setLabelText("AttValueLabel" .. i, "")
    end
    self:updateLayout("PropertyPanel")

    -- 数量
    local amount = InventoryMgr:getAmountByName(cardInfo.cardName) + StoreMgr:getCardAmountByName(cardInfo.cardName)
    self:setLabelText("Label_2", amount, "InfoPanel")

    -- 卡片类型
    self:setLabelText("CardTypeLabel", gf:getCardTypeChs(cardInfo.card_type))
    self:updateLayout("StylePanel")

    -- 出没地
    if normalPetList[petName] and normalPetList[petName]["zoon"] then
        local str = normalPetList[petName]["zoon"][1]
        self:setLabelText("HauntLabel", str)
    else
        self:setLabelText("HauntLabel", CHS[5000059])
    end
    self:updateLayout("MapPanel")

    if cardInfo.card_type == CARD_TYPE.MONSTER then
        self:setCtrlVisible("SpecialCardPanel", false)
        self:setCtrlVisible("BOSSCardPanel", false)
        self:setCtrlVisible("EpicCardPanel", false)
        self:setCtrlVisible("CatchNoteButton", true)
    elseif cardInfo.card_type == CARD_TYPE.ELITE then
        self:setCtrlVisible("SpecialCardPanel", true)
        self:setCtrlVisible("BOSSCardPanel", false)
        self:setCtrlVisible("EpicCardPanel", false)
        self:setCtrlVisible("CatchNoteButton", false)
    elseif cardInfo.card_type == CARD_TYPE.EPIC then
        self:setCtrlVisible("SpecialCardPanel", false)
        self:setCtrlVisible("BOSSCardPanel", false)
        self:setCtrlVisible("EpicCardPanel", true)
        self:setCtrlVisible("CatchNoteButton", false)
    else
        self:setCtrlVisible("SpecialCardPanel", false)
        self:setCtrlVisible("BOSSCardPanel", true)
        self:setCtrlVisible("CatchNoteButton", false)
        self:setCtrlVisible("EpicCardPanel", false)
    end
end

function ChangeCardIllustrationDlg:searchByArrName(condition)
    local searth = {}
    -- self.allCards全部，分为很多页，需每页搜索
    for i = 1, #self.allCards do
        -- 遍历self.allCards表中每一页
        for j = 1, self.allCards[i].count do
            -- 遍历每页中每个卡片属性
            local ret = false
            for n = 1, #self.allCards[i][j].attrib do
                if self.allCards[i][j].attrib[n].chs == condition then
                    ret = true
            end
            end
            for n = 1, #self.allCards[i][j].battle_arr do
                if self.allCards[i][j].battle_arr[n].chs == condition then
                    ret = true
                end
            end

            if ret then
                table.insert(searth, self.allCards[i][j])
            end
        end
    end

    searth = self:setCardsPage(searth)
    return searth
end

function ChangeCardIllustrationDlg:onExpandButton(sender, eventType)
    local condition = self:getInputText("TextField") -- 搜索条件
    if condition == CHS[4100101] then
        gf:ShowSmallTips(CHS[4100102])
        return
    end
    self.pageLastSelectIndex = {}
    self.searchRet = self:searchByArrName(condition)
    if not next(self.searchRet) then
        self.searchRet = nil
        self:setCardList({})
        return
    end
    self.condition = condition
    self.curPageIndex = 1
    self.cardType = "AllCardPanel"
    self:setLabelText("Label1", CHS[4100075])
    self:setCardList(self.searchRet)
end

-- 获取传送位置
function ChangeCardIllustrationDlg:getFlyPosition(mapName)
    local mapInfo =  MapMgr:getMapinfo()

    for k,v in pairs(mapInfo) do
        if v["map_name"] == mapName then
            return v["teleport_x"],v["teleport_y"]
        end
    end

    gf:ShowSmallTips(CHS[6000073])
end

function ChangeCardIllustrationDlg:onCatchNoteButton(sender, eventType)
    if not self.cardInfo then return end
    if Me:queryBasicInt("level") < 15 then
        gf:ShowSmallTips(CHS[4100080])
        return
    end

    if Me:isTeamMember() then
        gf:ShowSmallTips(CHS[6000210])
        return
    end

    local petName = string.match(self.cardInfo.cardName, CHS[4100079])
    local pet = PetMgr:getPetCfg(petName)


    if MapMgr.mapData.map_name == pet.zoon[1] then
        if Me:queryBasicInt("enable_shenmu_points") == 0 then
            gf:confirm(CHS[4100103], function()
                local dlg = DlgMgr:openDlg("PracticeDlg")
                local addPanel = dlg:getControl("ShenMuOpenStatePanel")
                gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                dlg:setAutoWalkAfterCloseDlg(true)

                if PracticeMgr:getIsUseExorcism()  then
                    local addPanel = dlg:getControl("OpenStatePanel")
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                end
            end)
        elseif PracticeMgr:getIsUseExorcism()  then
            gf:confirm(CHS[5400072], function()
                if Me:queryBasicInt("shenmu_points") < 200 then
                    gf:ShowSmallTips(CHS[5420216])
                    ChatMgr:sendMiscMsg(CHS[5420216])
                end

                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                PracticeMgr:autoWalkOnCurMap()
            end)
        else
            if Me:queryBasicInt("shenmu_points") < 200 then
                gf:ShowSmallTips(CHS[5420216])
                ChatMgr:sendMiscMsg(CHS[5420216])
            end

            PracticeMgr:autoWalkOnCurMap()
        end
    else
        MapMgr:flyTo(pet.zoon[1],function ()
            if Me:queryBasicInt("enable_shenmu_points") == 0 then
                gf:confirm(CHS[4100103], function()
                    local dlg = DlgMgr:openDlg("PracticeDlg")
                    local addPanel = dlg:getControl("ShenMuOpenStatePanel")
                    gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                    dlg:setAutoWalkAfterCloseDlg(true)

                    if PracticeMgr:getIsUseExorcism()  then
                        local addPanel = dlg:getControl("OpenStatePanel")
                        gf:createArmatureMagic(ResMgr.ArmatureMagic.use_double_point, addPanel, Const.ARMATURE_MAGIC_TAG)
                    end
                end)
            elseif PracticeMgr:getIsUseExorcism()  then
                gf:confirm(CHS[5400072], function()
                    if Me:queryBasicInt("shenmu_points") < 200 then
                        gf:ShowSmallTips(CHS[5420216])
                        ChatMgr:sendMiscMsg(CHS[5420216])
                    end

                    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                    PracticeMgr:autoWalkOnCurMap()
                end)
            else
                if Me:queryBasicInt("shenmu_points") < 200 then
                    gf:ShowSmallTips(CHS[5420216])
                    ChatMgr:sendMiscMsg(CHS[5420216])
                end

                PracticeMgr:autoWalkOnCurMap()
            end
        end)
    end

    DlgMgr:closeDlg("ChangeCardBagDlg")
    self:onCloseButton()
end

function ChangeCardIllustrationDlg:onMaketBuyButton(sender, eventType)
    if not self.cardInfo then return end
    if Me:queryBasicInt("level") < 50 then
        gf:ShowSmallTips(CHS[4100081])
        return
    end

    local param = CHS[4100000]
    if self.cardInfo.card_type == CARD_TYPE.MONSTER then
        param = param .. ":" .. CHS[4100087]
    elseif self.cardInfo.card_type == CARD_TYPE.ELITE then
        param = param .. ":" .. CHS[4100088]
    elseif self.cardInfo.card_type == CARD_TYPE.BOSS then
        param = param .. ":" .. CHS[4100089]
    elseif self.cardInfo.card_type == CARD_TYPE.EPIC then
        param = param .. ":" .. CHS[5450053]
    end

    local polar = InventoryMgr:getCardInfoByName(self.cardInfo.cardName).polar
    local searchThirdClass = MarketMgr:getChangeCardThirdClass(polar)
    param = param .. ":" .. searchThirdClass

    DlgMgr:openDlgAndsetParam({"MarketBuyDlg", param})
end

function ChangeCardIllustrationDlg:onReduceButton(sender, eventType)
end

function ChangeCardIllustrationDlg:onAddButton(sender, eventType)
end

function ChangeCardIllustrationDlg:onBuyButton(sender, eventType)

end

function ChangeCardIllustrationDlg:onCardTypeCheckBox(sender, eventType)
    self.root:stopAllActions()
    local ctrl = self:getControl("ChoseMenuPanel")
    ctrl:setVisible(not ctrl:isVisible())
end

function ChangeCardIllustrationDlg:onRefreshButton(sender, eventType)


    self.pageLastSelectIndex = {}
    self.curPageIndex = 1
    self.cardType = "AllCardPanel"
    self:cleanSearchData()
    self:setLabelText("Label1", CHS[4100075])
    self:setCardList(self.allCards)
end

function ChangeCardIllustrationDlg:cleanSearchData()
    self.searchRet = nil
    self.condition = nil

    self:setInputText("TextField", CHS[4100101], nil, COLOR3.GRAY)
    self:setCtrlVisible("Image_122", true)
    self:setCtrlVisible("RefreshButton", false)
end

function ChangeCardIllustrationDlg:onTextField(sender, eventType)
    self.root:stopAllActions()
    local ctrl = self:getControl("ChoseAttribPanel")
    ctrl:setVisible(not ctrl:isVisible())
end

function ChangeCardIllustrationDlg:onMainPanel(sender, eventType)
    self:setCtrlVisible("ChoseAttribPanel", false)
    self:setCtrlVisible("ChoseMenuPanel", false)
end

function ChangeCardIllustrationDlg:onChoseCardType(sender, eventType)
    self:setCtrlVisible("ChoseMenuPanel", false)
    if self.cardType == sender:getName() and not self.searchRet then return end
    self:cleanSearchData()
    self.pageLastSelectIndex = {}
    self.curPageIndex = 1
    self.cardType = sender:getName()
    if sender:getName() == "AllCardPanel" then
        self:setCardList(self.allCards)
        self:setLabelText("Label1", CHS[4100075])
    elseif sender:getName() == "MonsterPanel" then
        self:setCardList(self.monsterCards)
        self:setLabelText("Label1", CHS[4100076])
    elseif sender:getName() == "ElitePanel" then
        self:setCardList(self.eliteCards)
        self:setLabelText("Label1", CHS[4100077])
    elseif sender:getName() == "BossPanel" then
        self:setCardList(self.bossCards)
        self:setLabelText("Label1", CHS[4100078])
    elseif sender:getName() == "EpicPanel" then
        self:setCardList(self.epicCards)
        self:setLabelText("Label1", CHS[5450057])
    end
end

function ChangeCardIllustrationDlg:MSG_INVENTORY(data)
    self:MSG_STORE(data)
end

function ChangeCardIllustrationDlg:MSG_STORE(data)
    if self.pageLastSelectIndex and self.pageLastSelectIndex[self.curPageIndex] and self.showCardList and self.showCardList[self.curPageIndex] then
        self:showCardInfo(self.pageLastSelectIndex[self.curPageIndex], self.showCardList[self.curPageIndex])
    end
end


function ChangeCardIllustrationDlg:MSG_UPDATE(data)
    self:setLabelText("Label1_0_1", string.format("%d/%d", self.kindCount, InventoryMgr:getAmountCardsKind()))
end

function ChangeCardIllustrationDlg:MSG_CL_CARD_INFO(data)
    self:updateGetInfo()
    self:setLabelText("Label1_0_1", string.format("%d/%d", self.kindCount, InventoryMgr:getAmountCardsKind()))
    self:setUIData()
end

return ChangeCardIllustrationDlg
