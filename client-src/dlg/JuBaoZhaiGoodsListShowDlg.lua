-- JuBaoZhaiGoodsListShowDlg.lua
-- Created by songcw
-- 聚宝斋商品列表展示基类
-- 当前用于聚宝斋寄售、拍卖两个界面

local JuBaoZhaiGoodsListShowDlg = Singleton("JuBaoZhaiGoodsListShowDlg", Dialog)

-- 菜单
local MENU_LIST_ONE = {
    -- 初始化中，子类 getBigMenuList 接口获取对应菜单
}

-- 二级菜单
local MENU_LIST_TWO = {
    --     角  色               云霄洞                       玉柱洞                        斗阙宫                      金光洞                        白骨洞
    [CHS[4000402]] = {CHS[3000880], CHS[3000910], CHS[3000917], CHS[3001677], CHS[3001705]},

    --  宠物                          普通                            变异                            神兽                          其他                              精怪                      御灵                              -- 纪念
    [CHS[4200254]] = {CHS[3001219], CHS[3001220], CHS[3003814], CHS[4100360], CHS[4200237], CHS[4200238], CHS[7002139]},

    -- 武器                            枪                                  爪                               剑                                   扇                               锤
    [CHS[4200255]] = {CHS[3003023], CHS[3003024], CHS[3003025], CHS[3003026], CHS[3003027]},

    -- 防具                           男帽                              女帽                          男衣                              女衣                          鞋子
    [CHS[4200256]] = {CHS[3003028], CHS[3003029], CHS[3003030], CHS[3003031], CHS[3003036]},

    -- 法宝                               混元金斗                番天印                         定海珠                     金蛟剪                     阴阳镜                         卸甲金葫                九龙神火罩
    [CHS[4200257]] = {CHS[7000138], CHS[7000143], CHS[7000137], CHS[7000139], CHS[7000140], CHS[7000141], CHS[7000142]},

    -- 首饰                               玉佩                          项链                              手镯
    [CHS[4200258]] = {CHS[4200259], CHS[4200260], CHS[4200261]},
}

-- 服务端的一级菜单顺序
local MENU_LIST_ONE_IN_SERVER = {
    CHS[4000402],    CHS[7190083],      CHS[4200254],  -- 角  色  金 钱  宠  物
    CHS[4200255],    CHS[4200256],      CHS[4200258],  -- 武 器   防 具  首 饰
    CHS[4200257],   -- 法宝
}

-- 一级菜单状态
local ONE_MENU_STATE = {
    NO_SECOND_MENU = 1,     -- 无二级菜单
    SECOND_HIDE = 2,        -- 隐藏二级状态
    SECOND_SHOW = 3,        -- 显示二级菜单
}

local DISPLAY_PANEL = {
    ["SellListCheckBox"] = "SellPanel",
    ["PublicListCheckBox"] = "PublicPanel",
    ["VendueListCheckBox"] = "VenduePanel",
}

local GOODS_TITLE_PANEL = {
    "NamePanel", "InfoPanel", "LeftTimesPanel",
}

local LIST_TYPE_MAP = {
    -- 初始化中，子类 getBigMenuList 接口获取对应菜单
}

local CHECKBOX_NAME = {
    [CHS[5410124]] = "SellListCheckBox",
    [CHS[4101096]] = "VendueListCheckBox",
    [CHS[5410125]] = "PublicListCheckBox",
}


local GOODS_TYPE = {
    [CHS[7190083]] = TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS,   -- 金钱

    [CHS[3000880]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_METAL,
    [CHS[3000910]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_WOOD,
    [CHS[3000917]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_WATER,
    [CHS[3001677]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_FIRE,
    [CHS[3001705]] = TradingMgr.GOODS_TYPE.SALE_TYPE_USER_EARTH,

    [CHS[3001219]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_NORMAL,        -- 普通
    [CHS[3001220]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_ELITE,        -- 变异
    [CHS[3003814]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_EPIC,        -- 神兽
    [CHS[4100360]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_OTHER,        -- 其他
    [CHS[4200237]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI,        -- 精怪
    [CHS[4200238]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING,        -- 御灵
    [CHS[7002139]] = TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINIAN,        -- 纪念

    [CHS[3003023]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_GUN,
    [CHS[3003024]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_CLAW,
    [CHS[3003025]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_SWORD,
    [CHS[3003026]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_FAN,
    [CHS[3003027]] = TradingMgr.GOODS_TYPE.SALE_TYPE_WEAPON_HAMMER,

    [CHS[3003028]] = TradingMgr.GOODS_TYPE.SALE_TYPE_HELMET_MALE,
    [CHS[3003029]] = TradingMgr.GOODS_TYPE.SALE_TYPE_HELMET_FEMALE,
    [CHS[3003030]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARMOR_MALE,
    [CHS[3003031]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARMOR_FEMALE,
    [CHS[3003036]] = TradingMgr.GOODS_TYPE.SALE_TYPE_BOOT,

    [CHS[7000138]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_HUNYJD,
    [CHS[7000143]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_FANTY,
    [CHS[7000137]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_DINGHZ,
    [CHS[7000139]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_JINJJ,
    [CHS[7000140]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_YINYJ,
    [CHS[7000141]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_XIEJJH,
    [CHS[7000142]] = TradingMgr.GOODS_TYPE.SALE_TYPE_ARTIFACT_JIULSHZ,

    [CHS[4200259]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_BALDRIC,
    [CHS[4200260]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_NECKLACE,
    [CHS[4200261]] = TradingMgr.GOODS_TYPE.SALE_TYPE_JEWELRY_WRIST,

    [CHS[7000306]] = CHS[7000306],
}

local SORT_TYPE = {
    PRICE_UP        = 1,        -- 价格升序
    PRICE_DOWN      = 2,        -- 价格降序
    TAO_UP          = 3,        -- 道行升序
    TAO_DOWN        = 4,        -- 道行降序
    TIME_UP         = 5,        -- 时间升序
    TIME_DOWN       = 6,        -- 时间降序
}

-- 法宝需要排序
local SKILL_ORDER = {
    [CHS[3001942]] = 1, -- 颠倒乾坤
    [CHS[3001943]] = 2, -- 金刚圈
    [CHS[3001944]] = 3, -- 物极必反
    [CHS[3001945]] = 4, -- 天眼
    [CHS[3001946]] = 5, -- 嘲讽
    [CHS[3001947]] = 6, -- 亲密无间
}

-- 每页显示个数
local PAGE_COUNT    = 10

function JuBaoZhaiGoodsListShowDlg:init()

    MENU_LIST_ONE = self:getBigMenuList()
    LIST_TYPE_MAP = self:getTradingType()

    -- 还原变量
    self:cleanup()

    -- 初始化克隆、绑定一些事件
    self:initRetainPanels()

    -- 初始化菜单
    self:initMenuList()

    -- 初始化滚动加载
    self:initListScroingLoad()

    -- 相关按钮初始化
    self:initButton()

    -- 单选框初始化，子类自己实现
    self:initForChildDlg()

    self:hookMsg("MSG_TRADING_FAVORITE_GIDS")
    self:hookMsg("MSG_TRADING_FAVORITE_LIST")
    self:hookMsg("MSG_TRADING_SNAPSHOT")
end

-- 子类获取各自获取
function JuBaoZhaiGoodsListShowDlg:getTradingType()
end

-- 子类获取各自菜单
function JuBaoZhaiGoodsListShowDlg:getBigMenuList()
end



-- 相关按钮初始化
function JuBaoZhaiGoodsListShowDlg:initButton()

    local function initButtonByPanelName(panelName)
        local panel = self:getControl(panelName)
        if not panel then return end
        local priceButton = self:getControl("NamePanel", nil, panel)
        priceButton.def_sort = SORT_TYPE.PRICE_UP
        self:bindTouchEndEventListener(priceButton, self.onSortButton)

        local taoButton = self:getControl("InfoPanel", nil, panel)
        taoButton.def_sort = SORT_TYPE.TAO_UP
        self:bindTouchEndEventListener(taoButton, self.onSortButton)

        local timeButton = self:getControl("LeftTimesPanel", nil, panel)
        timeButton.def_sort = SORT_TYPE.TIME_UP
        self:bindTouchEndEventListener(timeButton, self.onSortButton)

            -- 搜索
        self:bindEditFieldForSafe(panelName, 6, "CleanFieldButton", nil, nil, true)
        self:bindListener("CleanFieldButton", self.onCleanButton, panel)
        self:bindListener("CleanSearchButton", self.onCleanSearchButton, panel)
        self:bindListener("SearchButton", self.onSearchButton, panel)
    end

    initButtonByPanelName("PublicPanel")
    initButtonByPanelName("SellPanel")
    initButtonByPanelName("VenduePanel")
end

-- 初始化滚动加载
function JuBaoZhaiGoodsListShowDlg:initListScroingLoad()
    -- 滚动加载
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent, listView)

        if not self.curIsSearchRet[self.curDisplay] and ( self.curDisplay and self.lastBigMenuName[self.curDisplay] ~= CHS[4000401]) then

            if percent > 100 then
                        -- 加载
                local retData = self:getGoodsListNext()
                self:setGoodsListInfo(retData)
            elseif percent < 0 then
                local retData = self:getGoodsListLast()
                if #retData > 0 then
                    local posY = listView:getInnerContainer():getPositionY()

                    self:setGoodsListInfo(retData, nil, true)

                    listView:getInnerContainer():setPositionY(posY)
                end
            end
        end
    end, "SellPanel")

    -- 滚动加载
    if self:getControl("PublicPanel") then
        self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent, listView)
            if not self.curIsSearchRet[self.curDisplay] and ( self.curDisplay and self.lastBigMenuName[self.curDisplay] ~= CHS[4000401]) then
                if percent > 100 then
                        local retData = self:getGoodsListNext()
                        self:setGoodsListInfo(retData)
                elseif percent < 0 then



                        local retData = self:getGoodsListLast()
                        if #retData > 0 then

                            local posY = listView:getInnerContainer():getPositionY()

                            self:setGoodsListInfo(retData, nil, true)

                            listView:getInnerContainer():setPositionY(posY)
                        end
                end
            end

        end, "PublicPanel")
    end
end

-- 单选框初始化，子类自己实现
function JuBaoZhaiGoodsListShowDlg:initForChildDlg()
end

function JuBaoZhaiGoodsListShowDlg:setDisplayPanel(isVisible)
    for _, panelName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panelName, isVisible)
    end
end

function JuBaoZhaiGoodsListShowDlg:onCheckBox(sender, eventType)
    self:setDisplayPanel(false)
    if not DISPLAY_PANEL[sender:getName()] then
        return
    end
    self.curDisplay = sender:getName()
    self:setCtrlVisible(DISPLAY_PANEL[self.curDisplay], true)

    self:setCollectBtnLabel(CHS[4000401])

    -- 第一次切换默认选择
    if LIST_TYPE_MAP[self.curDisplay] and not self.isNotFristOnCheck[self.curDisplay] then
        self.isNotFristOnCheck[self.curDisplay] = true
        local list = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])
        local panel = list:getItem(1) -- 默认选中搜藏
        self:onClickBigMenu(panel)
    end

    --[[ 上一次时收藏，特殊处理，选择
    if LIST_TYPE_MAP[self.curDisplay] and self.lastBigMenuName[self.curDisplay] == CHS[4000401] then

        TradingMgr:queryTradingCollectList(LIST_TYPE_MAP[self.curDisplay])
    end]]

    -- 如果切换太快，导致数据没有被放进当前数据列表中
    if LIST_TYPE_MAP[self.curDisplay] then
        if (self.curGoodsList and not next(self.curGoodsList)) or (self.curGoodsList[self.curDisplay] and not next(self.curGoodsList[self.curDisplay])) then
            local data = TradingMgr:getDataByClass(LIST_TYPE_MAP[self.curDisplay], self:getGoodTypeByName(self.curGoodsType[self.curDisplay]))
            if not data or not next(data) then
                self:resetListView("ListView", 0, nil, DISPLAY_PANEL[self.curDisplay])
                self:setCtrlVisible("NoticePanel", true, DISPLAY_PANEL[self.curDisplay])

                if self.setNoticePanelTips then
                    self:setNoticePanelTips(self.curGoodsType[self.curDisplay])
                end

                return
            end

            self:setCtrlVisible("NoticePanel", false, DISPLAY_PANEL[self.curDisplay])
            local sortFun = TradingMgr:getSortFun(SORT_TYPE.PRICE_UP)
            self.curSortType[self.curDisplay] = SORT_TYPE.PRICE_UP

            self.curGoodsList[self.curDisplay] = gf:deepCopy(data)
            sortFun(self.curGoodsList[self.curDisplay])

            self.curListStart[self.curDisplay] = 1
            local retData = self:getGoodsListNext()
            self:setGoodsListInfo(retData, true)
            self:upDateArrow()
        end
    end
end


function JuBaoZhaiGoodsListShowDlg:cleanup()
    self.curDisplay = nil
    self.lastBigMenuName = {}
    self.lastSmallMenuName = {}
    self.curGoodsList = {}
    self.curIsSearchRet = {}
    self.curSelectChar = {}
    self.curGoodsType = {}
    self.curListStart = {}
    self.curSortType = {}
    self.isNotFristOnCheck = {}

    -- 增加向上滚动，所以该变量用于记录第一个list项在对应表中位置
    self.listViewFirst = {}

    self.lastTime = gfGetTickCount()

    if self.defaultSelectGid then
        DlgMgr:closeDlg("WaitDlg")
    end

    self.defaultSelectGid = nil
    if self.bigSelectMenuImage2 then
        self.bigSelectMenuImage2:release()
        self.bigSelectMenuImage2 = nil
    end

    if self.smallSelectMenuImage2 then
        self.smallSelectMenuImage2:release()
        self.smallSelectMenuImage2 = nil
    end
end

-- 初始化克隆、绑定一些事件
function JuBaoZhaiGoodsListShowDlg:initRetainPanels()
    -- 菜单、选中效果
    self.bigMenuPanel = self:retainCtrl("BigPanel")
    self.bigSelectMenuImage = self:retainCtrl("BChosenEffectImage", self.bigMenuPanel)
    self.bigSelectMenuImage2 = self.bigSelectMenuImage:clone()
    self.bigSelectMenuImage2:retain()

    -- 事件监听
    self:bindTouchEndEventListener(self.bigMenuPanel, self.onClickBigMenu)

    self.smallMenuPanel = self:retainCtrl("SPanel")
    self.smallSelectMenuImage = self:retainCtrl("SChosenEffectImage", self.smallMenuPanel)
    self.smallSelectMenuImage2 = self.smallSelectMenuImage:clone()
    self.smallSelectMenuImage2:retain()

        -- 事件监听
    self:bindTouchEndEventListener(self.smallMenuPanel, self.onClickSmallMenu)

    -- 单个商品
    self.saleGoodsCell = self:retainCtrl("SaleGoodsInfoPanel")
    self:bindListener("GoodsPanel", self.onShowCard, self.saleGoodsCell)
    self:bindTouchEndEventListener(self.saleGoodsCell, self.onSelectGoods)
    self.saleGoodsSelectImage = self:retainCtrl("ChosenImage", self.saleGoodsCell)
end

function JuBaoZhaiGoodsListShowDlg:setMenuList(panelName)
    if not self:getControl(panelName) then return end
    local list = self:resetListView("GoodsTypeListView", 5, nil, panelName)
    list:setBounceEnabled(false)
    -- 加载一级菜单
    for i = 1, #MENU_LIST_ONE do
        local bigMenu = self.bigMenuPanel:clone()
        self:setBigMenuCellInfo(i, bigMenu, MENU_LIST_ONE)
        list:pushBackCustomItem(bigMenu)
    end

    list:doLayout()
    list:refreshView()
end

-- 初始化菜单
function JuBaoZhaiGoodsListShowDlg:initMenuList()
    self:setMenuList("SellPanel")
    self:setMenuList("PublicPanel")
end

-- 获取子菜单
function JuBaoZhaiGoodsListShowDlg:getSubMenuList(str)
    return MENU_LIST_TWO and MENU_LIST_TWO[str]
end

-- 设置单个一级菜单
function JuBaoZhaiGoodsListShowDlg:setBigMenuCellInfo(index, menuPanel, menus)
    -- 显示内容
    local menuStr = menus[index]

    menuPanel:setTag(index * 100)
    menuPanel:setName(menuStr)

    -- 显示label
    self:setLabelText("Label", menuStr, menuPanel)

    -- 二级菜单
    menuPanel.secondMenus = self:getSubMenuList(menuStr)

    -- 根据是否有二级菜单显示相关箭头
    if menuPanel.secondMenus then
        -- 有二级菜单,默认收缩
        self:setArrow(ONE_MENU_STATE.SECOND_HIDE, menuPanel)
    else
        -- 无二级菜单，全部隐藏
        self:setArrow(ONE_MENU_STATE.NO_SECOND_MENU, menuPanel)
    end
end

-- 一级菜单的箭头设置
function JuBaoZhaiGoodsListShowDlg:setArrow(type, panel)
    self:setCtrlVisible("DownArrowImage", false, panel)
    self:setCtrlVisible("UpArrowImage", false, panel)

    panel.secondType = type

    if type == 1 then
        -- 无二级菜单，不显示
    elseif type == 2 then
        -- 显示向下，（点击展开）
        self:setCtrlVisible("DownArrowImage", true, panel)
    elseif type == 3 then
        -- 显示向上，（点击收缩）
        self:setCtrlVisible("UpArrowImage", true, panel)
    end
end

-- 一级菜单选中光效
function JuBaoZhaiGoodsListShowDlg:addBigMenuSelectEff(sender)
    if self.curDisplay == "SellListCheckBox" or self.curDisplay == "VendueListCheckBox" then
        self.bigSelectMenuImage:removeFromParent()
        sender:addChild(self.bigSelectMenuImage)
    else
        self.bigSelectMenuImage2:removeFromParent()
        sender:addChild(self.bigSelectMenuImage2)
    end
end

-- 删除所有二级菜单
function JuBaoZhaiGoodsListShowDlg:removeSmallMenu(sender)
    local list = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])
    if not list then return end
    local items = list:getItems()
    for _, panel in pairs(items) do
        local tag = panel:getTag()
        if tag % 100 ~= 0 and math.floor(tag / 100) * 100 ~= sender:getTag() then
            -- 二级菜单，删除
            --panel:removeFromParent()
            list:removeChild(panel)
        else
            -- 一级菜单，有子菜单，设置箭头
            if panel.secondType ~= ONE_MENU_STATE.NO_SECOND_MENU and math.floor(tag / 100) * 100 ~= sender:getTag() then
                self:setArrow(ONE_MENU_STATE.SECOND_HIDE, panel)
            end
        end
    end

    list:requestRefreshView()
end

-- 点击一级菜单
function JuBaoZhaiGoodsListShowDlg:onClickBigMenu(sender)
    -- 清除上一次点击的二级菜单
    if self.lastBigMenuName[self.curDisplay] ~= sender:getName() then
        self.lastSmallMenuName[self.curDisplay] = ""
    end

    -- 情况当前选中的玩家
    self.curSelectChar[self.curDisplay] = nil
    self:addChosenEffByGoods()
    --]]
    -- 选中光效
    self:addBigMenuSelectEff(sender)

    -- 先删除 除sender外的二级菜单
    self:removeSmallMenu(sender)

    -- 设置二级菜单
    self:setSmallMenuListByBigMenu(sender)

    -- 查询数据
    self:queryData(sender)

    -- 上一次点击的二级菜单
    self.lastBigMenuName[self.curDisplay] = sender:getName()

    -- 收藏，金钱按钮需要隐藏搜索Panel
    local senderName = sender:getName()
    if senderName == CHS[7190083] then
        -- 金钱Panel，搜索按钮部分显示金钱数量，隐藏联系卖家按钮
        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(Me:queryBasicInt('cash')))
        self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("MoneyPanel", true, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("LianxiButton", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("SearchPanel", false, DISPLAY_PANEL[self.curDisplay])
    elseif senderName == CHS[4000401] then  -- "收  藏"
        self:setCtrlVisible("SearchPanel", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("MoneyPanel", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("LianxiButton", true, DISPLAY_PANEL[self.curDisplay])
    elseif senderName == CHS[7000306] then  -- 搜索结果
        self:setCtrlVisible("SearchPanel", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("MoneyPanel", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("LianxiButton", true, DISPLAY_PANEL[self.curDisplay])
    else
        self:setCtrlVisible("SearchPanel", true, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("MoneyPanel", false, DISPLAY_PANEL[self.curDisplay])
        self:setCtrlVisible("LianxiButton", true, DISPLAY_PANEL[self.curDisplay])
    end

    self:setCtrlVisible("EagleEyeResultInfoPanel", senderName == CHS[7000306], DISPLAY_PANEL[self.curDisplay])

    self:setCollectBtnLabel(CHS[4000401])

    local list = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])
    if list then list:requestDoLayout() end
end

function JuBaoZhaiGoodsListShowDlg:addChosenEffByGoods(sender)
    self.saleGoodsSelectImage:removeFromParent()
    if sender then
        sender:addChild(self.saleGoodsSelectImage)
        if sender.charInfo and sender.charInfo.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
            self:setCtrlVisible("LianxiButton", false, DISPLAY_PANEL[self.curDisplay])
        else
            self:setCtrlVisible("LianxiButton", true, DISPLAY_PANEL[self.curDisplay])
        end
    end
end


-- 设置收藏按钮显示
function JuBaoZhaiGoodsListShowDlg:setCollectBtnLabel(str)
    local panel = self:getControl("CollectButton", nil, DISPLAY_PANEL[self.curDisplay])
    if panel then
        self:setLabelText("Label1", str, panel)
        self:setLabelText("Label2", str, panel)
    end
end

function JuBaoZhaiGoodsListShowDlg:getGoodTypeByName(name)
    return GOODS_TYPE[name]
end

-- 查询数据
function JuBaoZhaiGoodsListShowDlg:queryData(sender)
    -- 获取 list_type
    local list_type = LIST_TYPE_MAP[self.curDisplay]
    if not list_type then return end
	if not self.curGoodsList[self.curDisplay] then self.curGoodsList[self.curDisplay] = {} end

    -- 判断是否请求收藏列表
    if sender:getName() == CHS[4000401] then
        self.curIsSearchRet[self.curDisplay] = nil

        if not self.notRequest then
            TradingMgr:queryTradingCollectList(list_type)
        end

        -- 设置当前选择的商品类型
        self.curGoodsType[self.curDisplay] = sender:getName()
        self.curGoodsList[self.curDisplay] = {}
        self.curListStart[self.curDisplay] = 1
        self.curSelectChar[self.curDisplay] = nil
        return
    elseif sender:getName() == CHS[7000306] then

        -- 设置当前选择的商品类型
        self.curGoodsType[self.curDisplay] = sender:getName()
        self.curGoodsList[self.curDisplay] = {}
        self.curListStart[self.curDisplay] = 1
        self.curSelectChar[self.curDisplay] = nil
        local data = {}
        data.list_type = self:getListType()
       -- data.goods_type = self.curGoodsType[self.curDisplay]
        self:MSG_TRADING_GOODS_LIST(data, CHS[7000306])
        return
    elseif sender:getName() == CHS[4010051] then
        gf:CmdToServer("CMD_TRADING_AUCTION_BID_LIST", {})
        self.curGoodsType[self.curDisplay] = sender:getName()
        self.curGoodsList[self.curDisplay] = {}
        self.curListStart[self.curDisplay] = 1
        self.curSelectChar[self.curDisplay] = nil
        return
    end

    -- 获取  goods_type
    local goods_type = self:getGoodTypeByName(sender:getName())
    if not goods_type then return end


    -- 设置当前选择的商品类型
    self.curGoodsType[self.curDisplay] = sender:getName()
    self.curGoodsList[self.curDisplay] = {}
    self.curListStart[self.curDisplay] = 1
    -- 请求数据
    self.curIsSearchRet[self.curDisplay] = nil
    self.curSelectChar[self.curDisplay] = nil

    if not self.notRequest then
    TradingMgr:queryTradingGoodsList(list_type, goods_type)
    end
end

-- 设置二级菜单
function JuBaoZhaiGoodsListShowDlg:setSmallMenuListByBigMenu(bigMenu)
    -- list为上级listView
    local list = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])

    -- 二级菜单处理
    if bigMenu.secondType == ONE_MENU_STATE.NO_SECOND_MENU  then
        -- 没有二级菜单

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.NO_SECOND_MENU, bigMenu)

    elseif bigMenu.secondType == ONE_MENU_STATE.SECOND_HIDE then
        -- 当前为隐藏二级状态状态

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.SECOND_SHOW, bigMenu)

        -- 增加二级菜单   !!!!!!!!!!!!!
        local defSelect = false
        for i = 1, #bigMenu.secondMenus do
            local smallMenu = self.smallMenuPanel:clone()
            self:setSmallMenuCellInfo(i, smallMenu, bigMenu)
            list:insertCustomItem(smallMenu, math.floor(bigMenu:getTag() / 100) + i - 1)

            if self.lastSmallMenuName[self.curDisplay] and self.lastSmallMenuName[self.curDisplay] == smallMenu:getName() then
                self:onClickSmallMenu(smallMenu)
                defSelect = true
            end
        end

        if not defSelect then
            local defSelectPanel = list:getItem(math.floor(bigMenu:getTag() / 100))
            self:onClickSmallMenu(defSelectPanel)
        end


    elseif bigMenu.secondType == ONE_MENU_STATE.SECOND_SHOW then

        -- 当前为显示二级状态状态

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.SECOND_HIDE, bigMenu)

        -- 删除二级菜单
        for i = #bigMenu.secondMenus, 1, -1 do
            list:removeItem(math.floor(bigMenu:getTag() / 100) + i - 1)
        end
    end
end

-- 二级菜单选中光效
function JuBaoZhaiGoodsListShowDlg:addSmallMenuSelectEff(sender)
    if self.curDisplay == "SellListCheckBox" or self.curDisplay == "VendueListCheckBox" then
        self.smallSelectMenuImage:removeFromParent()
        sender:addChild(self.smallSelectMenuImage)
    else
        self.smallSelectMenuImage2:removeFromParent()
        sender:addChild(self.smallSelectMenuImage2)
    end
end

-- 点击二级菜单
function JuBaoZhaiGoodsListShowDlg:onClickSmallMenu(sender)
    -- 选中光效
    self:addSmallMenuSelectEff(sender)

    -- 查询数据
    self:queryData(sender)


    -- 默认显示收藏
    if self.lastSmallMenuName[self.curDisplay] ~= sender:getName() then
        self:setCollectBtnLabel(CHS[4000401])
    end

    -- 上一次点击的二级菜单
    self.lastSmallMenuName[self.curDisplay] = sender:getName()
end

-- 设置二级菜单
function JuBaoZhaiGoodsListShowDlg:setSmallMenuCellInfo(index, menuPanel, bigMenu)
    -- 文本
    local secondMenu = self:getSubMenuList(bigMenu:getName())
    if not secondMenu then return end
    local content = secondMenu[index]
    menuPanel:setName(content)

    -- 对应一级菜单的空间名
    menuPanel.parentName = bigMenu:getName()

    local bigTag = bigMenu:getTag()
    menuPanel:setTag(bigTag + index)

    -- 设置显示文本
    self:setLabelText("Label", content, menuPanel)
end


function JuBaoZhaiGoodsListShowDlg:onViewButton(sender, eventType)
    if not self.curSelectChar[self.curDisplay] then
        gf:ShowSmallTips(CHS[4000405])
        return
    end

    -- 如果界面开启过程中，某个商品由公示变为寄售，给予提示
    if (self.curSelectChar[self.curDisplay].state == TRADING_STATE.SHOW or self.curSelectChar[self.curDisplay].state == TRADING_STATE.AUCTION_SHOW) and gf:getServerTime() > self.curSelectChar[self.curDisplay].end_time then
        gf:ShowSmallTips(CHS[4300294])
        return
    end

    -- 如果界面开启过程中，某个商品由寄售变过期
    if self.curSelectChar[self.curDisplay].state == TRADING_STATE.SALE and gf:getServerTime() > self.curSelectChar[self.curDisplay].end_time then
        gf:ShowSmallTips(CHS[4300295])
        return
    end

    -- 如果界面开启过程中，某个商品由拍卖变过期
    if self.curSelectChar[self.curDisplay].state == TRADING_STATE.AUCTION and gf:getServerTime() > self.curSelectChar[self.curDisplay].end_time then
        gf:ShowSmallTips(CHS[4200526])
        return
    end

    local sync = 0
    -- 如果界面开启过程中，付款期到过期
    if (self.curSelectChar[self.curDisplay].state == TRADING_STATE.PAYMENT or self.curSelectChar[self.curDisplay].state == TRADING_STATE.AUCTION_PAYMENT) and gf:getServerTime() > self.curSelectChar[self.curDisplay].end_time then

        if self.curSelectChar[self.curDisplay].state == TRADING_STATE.PAYMENT then
            gf:ShowSmallTips(CHS[4300295])
        else
            gf:ShowSmallTips(CHS[4200526])
        end

        sync = 1 -- 付款中，同步一下
        return
    end

    if self.curSelectChar[self.curDisplay].goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
        local dlg = DlgMgr:openDlg("JuBaoViewCashDlg")
        dlg:setData(self.curSelectChar[self.curDisplay])
        return
    end

    TradingMgr:setTradGoodsData(self.curSelectChar[self.curDisplay])


    if self.curSelectChar[self.curDisplay].state == TRADING_STATE.AUCTION then
        -- 拍卖的时候要刷新 竞拍次数
        sync = 1

    end

    TradingMgr:tradingSnapshot(self.curSelectChar[self.curDisplay].goods_gid, TRAD_SNAPSHOT.SNAPSHOT, sync)
end

function JuBaoZhaiGoodsListShowDlg:onCollectButton(sender, eventType)
    local str = self:getLabelText("Label1", sender)
    if not self.curSelectChar[self.curDisplay] then
        if str == CHS[4000401] then
            gf:ShowSmallTips(CHS[4000406])
        else
            gf:ShowSmallTips(CHS[4000407])
        end

        return
    end

    if str == CHS[4000401] then
        TradingMgr:modifyCollectGoods(self.curSelectChar[self.curDisplay].goods_gid, 1)
    else
        TradingMgr:modifyCollectGoods(self.curSelectChar[self.curDisplay].goods_gid, 0)
    end
end

function JuBaoZhaiGoodsListShowDlg:onEagleEyeButton(sender, eventType)
    DlgMgr:openDlg("JuBaoZhaiSearchDlg")
end

function JuBaoZhaiGoodsListShowDlg:getListType()
end

-- 联系卖家
function JuBaoZhaiGoodsListShowDlg:onLianxiButton(sender, eventType)
    if not self.curSelectChar[self.curDisplay] then
        gf:ShowSmallTips(CHS[4100832])
        return
    end
    if self.curGoodsType[self.curDisplay] == CHS[4000401] then
        local para = MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_COLLECTION .. "|" .. self:getListType()
        MarketMgr:connectSeller(CHS[5410123], self.curSelectChar[self.curDisplay].goods_gid, para, self.name, self.curSelectChar[self.curDisplay].goods_name)
        return
    end

    local exchangeType = MarketMgr.CARD_EXCHANGE.CARD_EXCHANGE_LIST
    local goodsType = self:getGoodTypeByName(self.curGoodsType[self.curDisplay])
    if self.curGoodsType[self.curDisplay] == CHS[4010051] then
        goodsType = self.curSelectChar[self.curDisplay].goods_type
    end

    local stateType = self:getListType()

    local keyStr = exchangeType .. "|" .. goodsType .. "|" .. stateType

    MarketMgr:connectSeller(CHS[5410123], self.curSelectChar[self.curDisplay].goods_gid, string.format(keyStr, exchangeType, goodsType, stateType), self.name, self.curSelectChar[self.curDisplay].goods_name)

end

-- 请求数据后，数据接收完成，由管理器通知刷新
function JuBaoZhaiGoodsListShowDlg:MSG_TRADING_GOODS_LIST(data, defineGoodsType)

    if not self.curDisplay or not LIST_TYPE_MAP[self.curDisplay] then
        return
    end

    if data.list_type ~= LIST_TYPE_MAP[self.curDisplay] then
        return
    end

    if self.name == "JuBaoZhaiVendueDlg" then
        -- 拍卖界面没有子项，验证大项
        -- 点击聊天频道中商品名片， 和  拍卖界面点击某个大菜单，goods_type值不一样
        -- 详见任务 WDSY-34461
        local goods_type = data.goods_type
        if data.goods and next(data.goods) then
            goods_type = math.floor(data.goods[1].goods_type / 100)
        end

        if defineGoodsType then
            if defineGoodsType ~= self.curGoodsType[self.curDisplay] then
                return
            end
        else
            if goods_type and self.curGoodsType[self.curDisplay] and goods_type ~= self:getGoodTypeByName(self.curGoodsType[self.curDisplay]) then
                return
            end
        end
    else

        if defineGoodsType then
            if defineGoodsType ~= self.curGoodsType[self.curDisplay] then
                return
            end
        else
            if self.curGoodsType[self.curDisplay] and data.goods_type ~= self:getGoodTypeByName(self.curGoodsType[self.curDisplay]) then
                return
            end
        end
    end

    local isMoneyCashData = false
    if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
        isMoneyCashData = true
    end

    -- 金钱类没有二级图标，所以self.lastSmallMenuName[self.curDisplay]为空
    if not isMoneyCashData and not string.isNilOrEmpty(self.lastSmallMenuName[self.curDisplay]) and self:getGoodTypeByName(self.lastSmallMenuName[self.curDisplay]) ~= data.goods_type then return end

    local saleData = TradingMgr:getDataByClass(data.list_type, defineGoodsType or data.goods_type)
    if not saleData or not next(saleData) then
        self:resetListView("ListView", 0, nil, DISPLAY_PANEL[self.curDisplay])
        if isMoneyCashData and not TradingMgr:getIsCanSellCash() then
            -- 开服前20天，点击金钱，不会有数据，莲花姑娘提示修改
            self:setLabelText("InfoLabel1" , string.format(CHS[7190084], TradingMgr:getSellCashAfterDays()), DISPLAY_PANEL[self.curDisplay])
            self:setLabelText("InfoLabel2" , CHS[7190085], DISPLAY_PANEL[self.curDisplay])
        else
            self:setLabelText("InfoLabel1" , CHS[7190086], DISPLAY_PANEL[self.curDisplay])
            self:setLabelText("InfoLabel2" , CHS[7190087], DISPLAY_PANEL[self.curDisplay])
        end

        self:setCtrlVisible("NoticePanel", true, DISPLAY_PANEL[self.curDisplay])
        if self.setNoticePanelTips then
            self:setNoticePanelTips(self.curGoodsType[self.curDisplay])
        end
        return
    end

    self:setCtrlVisible("NoticePanel", false, DISPLAY_PANEL[self.curDisplay])

    local sortFun = TradingMgr:getSortFun(SORT_TYPE.PRICE_UP)
    self.curSortType[self.curDisplay] = SORT_TYPE.PRICE_UP

    self.curGoodsList[self.curDisplay] = gf:deepCopy(saleData)

    if defineGoodsType == CHS[4010051] then
        -- 竞拍不需要排序
    else
        sortFun(self.curGoodsList[self.curDisplay])
    end

    self.curListStart[self.curDisplay] = 1
    local retData = self:getGoodsListNext()
    self:setGoodsListInfo(retData, true)
    self:upDateArrow()
end

-- 设置排序箭头,区分寄售or公示
function JuBaoZhaiGoodsListShowDlg:upDateArrow(isHideAll)
    if not self.curDisplay or not LIST_TYPE_MAP[self.curDisplay] then return end
    if not self.curGoodsType[self.curDisplay] then return end

    -- 隐藏
    for _, panelName in pairs(GOODS_TITLE_PANEL) do
        self:setArrowPanel(3, panelName)
    end

    if isHideAll then return end

    -- 显示
    if self.curSortType[self.curDisplay] == SORT_TYPE.PRICE_UP or self.curSortType[self.curDisplay] == SORT_TYPE.PRICE_DOWN then
        self:setArrowPanel(self.curSortType[self.curDisplay] % 2, GOODS_TITLE_PANEL[1])
    elseif self.curSortType[self.curDisplay] == SORT_TYPE.TAO_UP or self.curSortType[self.curDisplay] == SORT_TYPE.TAO_DOWN then
        self:setArrowPanel(self.curSortType[self.curDisplay] % 2, GOODS_TITLE_PANEL[2])
    elseif self.curSortType[self.curDisplay] == SORT_TYPE.TIME_UP or self.curSortType[self.curDisplay] == SORT_TYPE.TIME_DOWN then
        self:setArrowPanel(self.curSortType[self.curDisplay] % 2, GOODS_TITLE_PANEL[3])
    end
end

-- 根据状态设置箭头  1升序，2为降序，其他隐藏箭头
function JuBaoZhaiGoodsListShowDlg:setArrowPanel(state, panelName)
    if not self.curDisplay or not LIST_TYPE_MAP[self.curDisplay] then return end
    if not self.curGoodsType[self.curDisplay] then return end
    local panel = self:getControl(panelName, nil, DISPLAY_PANEL[self.curDisplay])

    self:setCtrlVisible("UpImage", false, panel)
    self:setCtrlVisible("DownImage", false, panel)

    if state == 1 then
        self:setCtrlVisible("UpImage", true, panel)
    elseif state == 0 then
        self:setCtrlVisible("DownImage", true, panel)
    end
end

function JuBaoZhaiGoodsListShowDlg:getGoodsListLast()
    if not LIST_TYPE_MAP[self.curDisplay] then
        return {}
    end

    if not self.curGoodsList[self.curDisplay] or not next(self.curGoodsList[self.curDisplay]) then
        return {}
    end

    local retData = {}
    if self.listViewFirst[self.curDisplay] and self.listViewFirst[self.curDisplay] ~= 1 then
        local start = math.max( 1, self.listViewFirst[self.curDisplay] - PAGE_COUNT)
        for i = start, self.listViewFirst[self.curDisplay] - 1 do
            local data = self.curGoodsList[self.curDisplay][i]
            if data then
                table.insert(retData, data)

            end
        end
    end

    return retData
end

function JuBaoZhaiGoodsListShowDlg:getGoodsListNext()
    if not LIST_TYPE_MAP[self.curDisplay] then
        return {}
    end

    if not self.curGoodsList[self.curDisplay] or not next(self.curGoodsList[self.curDisplay]) then
        return {}
    end

    local start = self.curListStart[self.curDisplay]
    local retData = {}
    local addCount = 0
    for i = start, start + PAGE_COUNT - 1 do
        local data = self.curGoodsList[self.curDisplay][i]
        if data then
            table.insert(retData, data)
            addCount = addCount + 1
        end
    end

    self.curListStart[self.curDisplay] = self.curListStart[self.curDisplay] + addCount
    return retData
end

function JuBaoZhaiGoodsListShowDlg:getShowDefaultList()
    if not self.defaultSelectGid or self.defaultSelectGid == "" then return {} end
    if not LIST_TYPE_MAP[self.curDisplay] then
        return {}
    end

    if not self.curGoodsList[self.curDisplay] or not next(self.curGoodsList[self.curDisplay]) then
        return {}
    end

    if #self.curGoodsList[self.curDisplay] < PAGE_COUNT then
        -- 总数小于10，不需要特殊处理
        return self:getGoodsListNext()
    end


    local idx = 0
    for i = 1, #self.curGoodsList[self.curDisplay] do
        if self.defaultSelectGid == self.curGoodsList[self.curDisplay][i].goods_gid then
            idx = i
        end
    end

    if idx == 0 then
        --  容错
        return self:getGoodsListNext()
    else
        if idx >= PAGE_COUNT then
            self.curListStart[self.curDisplay] = idx - PAGE_COUNT + 1

            self.listViewFirst[self.curDisplay] = idx - PAGE_COUNT + 1
        else
            self.curListStart[self.curDisplay] = 1
        end
    end

    return self:getGoodsListNext()
end


-- 设置商品
function JuBaoZhaiGoodsListShowDlg:setGoodsListInfo(data, isReset, isInHead)

    local list = self:getControl("ListView", nil, DISPLAY_PANEL[self.curDisplay])
    local height = list:getInnerContainer():getContentSize().height
    if isReset then
        height = 0
        self:resetListView("ListView", 0, nil, DISPLAY_PANEL[self.curDisplay])
        list:stopAction(self.loadDelay)
    end

    local addHeight = 0
    if isInHead then
        for i = #data, 1, -1 do
            local panel = self.saleGoodsCell:clone()
            self:setSaleGoodsUnitPanel(data[i], panel,i)
            list:insertCustomItem(panel, 0)
            height = height + panel:getContentSize().height
        end

        self.listViewFirst[self.curDisplay] = self.listViewFirst[self.curDisplay] - #data

    else
        for i = 1, #data do
            local panel = self.saleGoodsCell:clone()
            self:setSaleGoodsUnitPanel(data[i], panel,i)
            list:pushBackCustomItem(panel)
            height = height + panel:getContentSize().height
        end
    end
    local needLoad = false
    if self.defaultSelectGid then
        self:resetListView("ListView", 0, nil, DISPLAY_PANEL[self.curDisplay])

        local retData = self:getShowDefaultList()
        self:setGoodsListInfo(retData)
        self.defaultSelectGid = nil

    end

    if not needLoad then
        list:doLayout()
        list:refreshView()
        DlgMgr:closeDlg("WaitDlg")
    end
end

-- 设置指定交易
function JuBaoZhaiGoodsListShowDlg:setAppointeeFlag(isApppintee, panel)
    self:setCtrlVisible("StateBKImage", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_1", isApppintee, panel)
    self:setCtrlVisible("SellStateValueLabel_2", isApppintee, panel)
end

-- 公示、寄售商品单个panel设置
function JuBaoZhaiGoodsListShowDlg:setSaleGoodsUnitPanel(data, panel, i)

	if not data.isDecode then
	    local info = json.decode(data.para)
	    for field, value in pairs(info) do
	        data[field] = value
	    end
	end

    -- 如果是法宝，根据法宝技能设置排序位置，没有技能则默认以个大值
    if data.extra_skill_name then
        data.artifact_skill_order = SKILL_ORDER[data.extra_skill_name]
    else
        data.artifact_skill_order = 100
    end

    -- 收藏
    local favoriteData = TradingMgr:getFavoriteInfo()
    if favoriteData[data.goods_gid] then
        self:setCtrlVisible("CollectImage", true, panel)
    else
        self:setCtrlVisible("CollectImage", false, panel)
    end

    -- 指定交易标记
   -- self:setAppointeeFlag(data.sell_buy_type == TRADE_SBT.APPOINT_SELL, panel)
    TradingMgr:setSellBuyTypeFlag(data.sell_buy_type, self, panel)

    TradingMgr:setAuctionFlag(data, self, panel)


    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 名称
    self:setCtrlVisible("NameLabel", true, panel)
    self:setLabelText("NameLabel", data.goods_name, panel)

    self:setLabelText("InfoLabel", "", panel)
    self:setCtrlVisible("CashInfoPanel", false, panel)
    local bigType = math.floor(tonumber(data.goods_type) / 100)
    if bigType == JUBAO_SELL_TYPE.SALE_TYPE_CASH then
        self:setImage("GoodsImage", ResMgr.ui.money, panel)
        self:setCtrlVisible("NameLabel", false, panel)
        self:setCtrlVisible("CashInfoPanel", true, panel)

        local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(data.goods_name))
        self:setNumImgForPanel("CashPanel", fontColor, cashText, false, LOCATE_POSITION.LEFT_TOP, 23, panel)
        local moneyStr, fontColor = gf:getMoneyDesc(math.floor(tonumber(data.goods_name) / data.price), true)
        self:setLabelText("PerValueLabel", moneyStr, panel, fontColor)
        self:setLabelText("PerValueLabel2", moneyStr, panel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, "", false, LOCATE_POSITION.LEFT_TOP, 21, panel)
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_PET then
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(data.icon), panel)


        if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_JINGGUAI or data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_PET_YULING then
            -- 御灵、精怪显示阶位
            if data.capacity_level == data.default_capacity_level then
                self:setLabelText("InfoLabel", string.format(CHS[4300213], data.capacity_level), panel)
            else
                self:setLabelText("InfoLabel", string.format(CHS[4300214], data.default_capacity_level, data.capacity_level - data.default_capacity_level), panel)
            end
        else
            -- 普通、变异、其他显示武学
            -- 道行、宠物为武学
            if data.martial then
                self:setLabelText("InfoLabel", string.format(CHS[4100441], data.martial), panel)
            end
        end

    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_ROLE then
        self:setImage("GoodsImage", ResMgr:getSmallPortrait(data.icon), panel)

        if data.tao then
            self:setLabelText("InfoLabel", string.format(CHS[4100404], gf:getTaoStr(data.tao, 0)), panel)
        end

        if data.upgrade_type then
            self:setLabelText("InfoLabel", "", panel)
            self:setLabelText("InfoLabel2", string.format(CHS[4100404], gf:getTaoStr(data.tao, 0)), panel)

            if data.upgrade_type == 0 then
                self:setLabelText("InfoLabel3", CHS[4100577], panel)
            else
                self:setLabelText("InfoLabel3", string.format(CHS[4100578], gf:getChildName(data.upgrade_type), data.upgrade_level), panel)
            end

            self:setCtrlVisible("InfoLabel2", true, panel)
            self:setCtrlVisible("InfoLabel3", true, panel)
        end


    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY then
        if data.best_prop_key then
            local attChs = EquipmentMgr:getAttribChsOrEng(data.best_prop_key)
            local bai = EquipmentMgr:getPercentSymbolByField(data.best_prop_key)
            local retChs = attChs .. " " .. data.best_prop_val .. bai
            if data.best_prop_max then
                retChs = retChs .. "/" .. data.best_prop_max .. bai
            end
            self:setLabelText("InfoLabel", retChs, panel)
        end

        -- 图标
        self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), panel)
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then
        -- 图标
        self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), panel)
        if data.extra_skill_name and data.extra_skill_name ~= "" then
            self:setLabelText("InfoLabel", CHS[4100459] .. data.extra_skill_name, panel)
        else
            self:setLabelText("InfoLabel", CHS[4100460], panel)
        end
    elseif bigType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON or bigType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR then
        self:setImage("GoodsImage", ResMgr:getItemIconPath(data.icon), panel)

        if data.rebuild_level and data.rebuild_level ~= 0 then
            self:setLabelText("InfoLabel", string.format(CHS[4100461], data.rebuild_level) , panel)
        else
            self:setLabelText("InfoLabel", CHS[4100462], panel)
        end
    end

    self:setItemImageSize("GoodsImage", panel)

    -- 如果有相性
    InventoryMgr:addPetPolarImage(self:getControl("GoodsImage", nil, panel), data.polar)

    -- 剩余时间
    self:setLabelText("StateLabel", TradingMgr:getLeftTime(data.end_time - gf:getServerTime()), panel)

    -- 价格
    local cashText = gf:getArtFontMoneyDesc(tonumber(data.price))
    if data.sell_buy_type == TRADE_SBT.APPOINT_SELL or data.sell_buy_type == TRADE_SBT.AUCTION then
        cashText = gf:getArtFontMoneyDesc(tonumber(data.butout_price))
    end
    self:setNumImgForPanel("PriceValuePanel_2", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23, panel)
    self:setNumImgForPanel("PriceValuePanel_1", ART_FONT_COLOR.DEFAULT, "$", false, LOCATE_POSITION.MID, 23, panel)

    -- 点击事件
    panel.charInfo = data

    if self.defaultSelectGid == data.goods_gid then
        self.defaultSelectGid = nil
        performWithDelay(panel, function()
            self:onSelectGoods(panel)
            local listView = panel:getParent():getParent()
            local index = listView:getIndex(panel)
            local container = listView:getInnerContainer()
            local innerSize = container:getContentSize()
            local listViewSize = listView:getContentSize()

            -- 计算滚动的百分比
            local totalHeight = listViewSize.height - innerSize.height
            local distance =  panel:getContentSize().height * index
            local posy = distance + totalHeight
            if posy > 0 then posy = 0 end
            container:setPositionY(posy)
        end, 0)
    end
end

-- 点击查看名片
function JuBaoZhaiGoodsListShowDlg:onShowCard(sender)
    local data = sender:getParent().charInfo

    -- 如果是金钱，不需要请求快照信息，直接打开预览界面
    if data.goods_type == TradingMgr.GOODS_TYPE.SALE_TYPE_CASH_GOODS then
        local dlg = DlgMgr:openDlg("JuBaoViewCashDlg")
        dlg:setData(data)
    end

    self:onSelectGoods(sender:getParent())

    local goodsType = math.floor(tonumber(data.goods_type) / 100)
    if goodsType == JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_WEAPON
        or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR or goodsType == JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT then

        TradingMgr:tradingSnapshot(data.goods_gid, TRAD_SNAPSHOT.SNAPSHOT, 0, 1)
    end
end

-- 选择商品
function JuBaoZhaiGoodsListShowDlg:onSelectGoods(sender, eventType)
    self:addChosenEffByGoods(sender)

    self.curSelectChar[self.curDisplay] = sender.charInfo

    -- 收藏
    local favoriteData = TradingMgr:getFavoriteInfo()
    if favoriteData[sender.charInfo.goods_gid] then
        self:setCollectBtnLabel(CHS[3002944])
    else
        self:setCollectBtnLabel(CHS[4000401])
    end
end

-- 收藏操作结果
function JuBaoZhaiGoodsListShowDlg:MSG_TRADING_FAVORITE_GIDS(data)
    local list = self:getControl("ListView", nil, DISPLAY_PANEL[self.curDisplay])
    local faDate = TradingMgr:getFavoriteInfo()
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel.charInfo then
            if faDate[panel.charInfo.goods_gid] then
                self:setCtrlVisible("CollectImage", true, panel)
            else
                self:setCtrlVisible("CollectImage", false, panel)
            end

            if self.curSelectChar[self.curDisplay] and self.curSelectChar[self.curDisplay].goods_gid == panel.charInfo.goods_gid then
                if faDate[panel.charInfo.goods_gid] then
                    self:setCollectBtnLabel(CHS[3002944])
                else
                    self:setCollectBtnLabel(CHS[4000401])
                end
            end
        end
    end
end


function JuBaoZhaiGoodsListShowDlg:MSG_TRADING_SNAPSHOT(data)
    if data.snapshot_type ~= TRAD_SNAPSHOT.SNAPSHOT then return end
    if data.isShowCard == 0 then return end

    local goodsType = math.floor(tonumber(data.goods_type) / 100)
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
     --   InventoryMgr:showOnlyFloatCardDlg(equip)
        equip.pos = nil
        InventoryMgr:showOnlyFloatCardDlgEx(equip)
    end
end

-- 收藏中的商品
function JuBaoZhaiGoodsListShowDlg:MSG_TRADING_FAVORITE_LIST(data)
    if not self.curDisplay or not LIST_TYPE_MAP[self.curDisplay] then return end

    if data.list_type ~= LIST_TYPE_MAP[self.curDisplay] then return end

    if self.curGoodsType[self.curDisplay] ~= CHS[4000401] then return end

    -- WDSY-24078,没有发现为什么收到收藏列表消息时，WDSY-24078竟然还是有值的，怀疑 WaitDlg因为其他关系关闭了，所以可以点击
    -- 容错处理 self.defaultSelectGid = nil
    self.defaultSelectGid = nil

    if data.count == 0 then
        self:setGoodsListInfo({}, true)
        self:setCtrlVisible("NoticePanel", true, DISPLAY_PANEL[self.curDisplay])
        if self.setNoticePanelTips then
            self:setNoticePanelTips(self.curGoodsType[self.curDisplay])
        end
        return
    end

    self:setCtrlVisible("NoticePanel", false, DISPLAY_PANEL[self.curDisplay])
    for i = 1, data.count do
        if data.goods[i].para then
            local info = json.decode(data.goods[i].para)
            for field, value in pairs(info) do
                data.goods[i][field] = value
            end
        end
    end

    -- 可以加载收藏商品了
    local sortFun = TradingMgr:getSortFun(SORT_TYPE.PRICE_UP)
    self.curSortType[self.curDisplay] = SORT_TYPE.PRICE_UP

    self.curGoodsList[self.curDisplay] = data.goods
    sortFun(self.curGoodsList[self.curDisplay])


    self.curListStart[self.curDisplay] = 1
    self:setGoodsListInfo(self.curGoodsList[self.curDisplay], true)
    self:upDateArrow(true)
end

-- 点击排序，价格
function JuBaoZhaiGoodsListShowDlg:onSortButton(sender, eventType)
    -- 是否可以排序
    if not self.curDisplay then return end
    if not self.curGoodsType[self.curDisplay] then return end

    -- 这个data可能是历史数据
    local data = TradingMgr:getDataByClass(LIST_TYPE_MAP[self.curDisplay], self:getGoodTypeByName(self.curGoodsType[self.curDisplay]))
    if not data or not next(data) then return end

    -- 获取排序方法
    local sortFun
    local menuType = self:getGoodTypeByName(self.curGoodsType[self.curDisplay])             -- 查询的编号

    if menuType == CHS[7000306] then
        -- 如果是搜索结果，需要获取对应的搜索类型
        local list_type = LIST_TYPE_MAP[self.curDisplay]
        local str = TradingMgr:getSearchGoodsType(list_type)
        if string.match(str, "|") then
            menuType = tonumber(string.match(str, "(%d+)|"))
        else
            menuType = tonumber(TradingMgr:getSearchGoodsType(list_type))
        end
    end

    if self.curSortType[self.curDisplay] ~= sender.def_sort then
        sortFun = TradingMgr:getSortFun(sender.def_sort, menuType)
        self.curSortType[self.curDisplay] = sender.def_sort
    else
        sortFun = TradingMgr:getSortFun(sender.def_sort + 1, menuType)
        self.curSortType[self.curDisplay] = sender.def_sort + 1
    end

    -- 排序，防止消息延迟，增加容错
    if not self.curGoodsList[self.curDisplay] then return end
    sortFun(self.curGoodsList[self.curDisplay])
    self.curListStart[self.curDisplay] = 1
    local retData = self:getGoodsListNext()
    self:setGoodsListInfo(retData, true)

    -- 更新箭头
    self:upDateArrow()
end

function JuBaoZhaiGoodsListShowDlg:seachDataByName(str, data)
    local retData = {}
    if not data then return retData end

    for i = 1, #data do
        if string.match(data[i].goods_name, str) then
            table.insert(retData, data[i])
        end
    end

    return retData
end


function JuBaoZhaiGoodsListShowDlg:onSearchButton(sender, eventType)
    local parentPanel = sender:getParent()
    local code = self:getInputText("TextField", parentPanel)

    if code == "" then
        gf:ShowSmallTips(CHS[4000403])
        return
    end


    local retSearchData = self:seachDataByName(code, self.curGoodsList[self.curDisplay])
    if not next(retSearchData) then
        gf:ShowSmallTips(CHS[4000404])
        return
    end

    local sortFun = TradingMgr:getSortFun(SORT_TYPE.PRICE_UP)
    self.curIsSearchRet[self.curDisplay] = true
    self.curSortType[self.curDisplay] = SORT_TYPE.PRICE_UP

    sortFun(retSearchData)
    self:setGoodsListInfo(retSearchData, true)
    self:upDateArrow()

    -- 搜索完隐藏
    sender:setVisible(false)
end

function JuBaoZhaiGoodsListShowDlg:onCleanButton(sender, eventType)
    local parentPanel = sender:getParent()
    local textCtrl = self:getControl("TextField", nil, parentPanel)
    textCtrl:setText("")
    sender:setVisible(false)

    -- 是否可以
    if not self.curDisplay or not LIST_TYPE_MAP[self.curDisplay] then return end

    self:setCtrlVisible("DefaultLabel", true, DISPLAY_PANEL[self.curDisplay])
end

function JuBaoZhaiGoodsListShowDlg:onCleanSearchButton(sender, eventType)
    if not self.curGoodsList[self.curDisplay] or not next(self.curGoodsList[self.curDisplay]) then return end

    local parentPanel = sender:getParent()
    self:setCtrlVisible("SearchButton", true, parentPanel)

    local sortFun = TradingMgr:getSortFun(SORT_TYPE.PRICE_UP)
    self.curIsSearchRet[self.curDisplay] = false
    self.curSortType[self.curDisplay] = SORT_TYPE.PRICE_UP
    -- 排序
    sortFun(self.curGoodsList[self.curDisplay])
    self.curListStart[self.curDisplay] = 1
    local retData = self:getGoodsListNext()
    self:setGoodsListInfo(retData, true)

    -- 更新箭头
    self:upDateArrow()
end

function JuBaoZhaiGoodsListShowDlg:MSG_TRADING_SEARCH_GOODS(data)

local LIST_TYPE_PANEL = {
        [TradingMgr.LIST_TYPE.SALE_LIST] = "SellListCheckBox",
[TradingMgr.LIST_TYPE.SHOW_LIST] = "PublicListCheckBox",
        [TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST] = "PublicListCheckBox",
[TradingMgr.LIST_TYPE.AUCTION_LIST] = "VendueListCheckBox",
}


    local checkBoxName = LIST_TYPE_PANEL[data.list_type]
    self.radioGroup:setSetlctByName(checkBoxName)
    self.curDisplay = checkBoxName
    self:onClickBigMenu(self:getControl(CHS[7000306], nil, DISPLAY_PANEL[self.curDisplay]))
end

-- 根据商品类别编号，返回商品名称
function JuBaoZhaiGoodsListShowDlg:getGoodsNameByNo(no)
    for k,v in pairs(GOODS_TYPE) do
        if v == no then
            return k
        end
    end

    return ""
end

function JuBaoZhaiGoodsListShowDlg:onDlgOpened(list)
    local checkBoxName = CHECKBOX_NAME[list[1]]

    if not LIST_TYPE_MAP[checkBoxName] then
        self.radioGroup:setSetlctByName(checkBoxName)
        return
    end

    if list[2] then
        local oneTag = tonumber(list[2])
        local secondName
        if not oneTag  then
            for i, name in ipairs(MENU_LIST_ONE) do
                if list[2] == name then
                    oneTag = i
                    secondName = name
                    break
                end
            end
        else
            secondName = MENU_LIST_ONE_IN_SERVER[oneTag]
        end

        self.isNotFristOnCheck[checkBoxName] = true
        self.radioGroup:setSetlctByName(checkBoxName)
        local listView = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])

        local panel = listView:getChildByName(secondName)
        if not panel then
            return
        end

        local secondTag = tonumber(list[3])
        if secondTag then
            self.lastSmallMenuName[self.curDisplay] = self:getGoodsNameByNo(list[2] * 100 + secondTag)
        else
            self.lastSmallMenuName[self.curDisplay] = list[3]
        end

        -- list[4] 为选中指定的道具的gid，目前该逻辑为先刷数据后打开界面，所以打开界面后不用再请求数据
        if list[4] then
            self.notRequest = true
            self.defaultSelectGid = list[4]
            DlgMgr:openDlg("WaitDlg")
        end

        self.lastBigMenuName[self.curDisplay] = secondName
        self:onClickBigMenu(panel)
        self.notRequest = false

        local listView = self:getControl("GoodsTypeListView", nil, DISPLAY_PANEL[self.curDisplay])
        local curGoodsType = self.curGoodsType[self.curDisplay]
        performWithDelay(panel, function ()
            if curGoodsType ~= self.curGoodsType[self.curDisplay]
                or checkBoxName ~= self.curDisplay then
                return
            end

            local index = listView:getIndex(panel)
            local container = listView:getInnerContainer()
            local innerSize = container:getContentSize()
            local listViewSize = listView:getContentSize()

            -- 计算滚动的百分比
            local totalHeight = listViewSize.height - innerSize.height
            local distance =  panel:getContentSize().height * index
            local posy = distance + totalHeight
            if posy > 0 then posy = 0 end
            container:setPositionY(posy)
        end, 0)
    else
        self.radioGroup:setSetlctByName(checkBoxName)
    end
end

return JuBaoZhaiGoodsListShowDlg
