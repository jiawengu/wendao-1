-- JuBaoZhaiVendueDlg.lua
-- Created by
--


local JuBaoZhaiGoodsListShowDlg = require('dlg/JuBaoZhaiGoodsListShowDlg')
local JuBaoZhaiVendueDlg = Singleton("JuBaoZhaiVendueDlg", JuBaoZhaiGoodsListShowDlg)
local RadioGroup = require("ctrl/RadioGroup")

local CHECK_BOXS = {
    "VendueListCheckBox",
    "PublicListCheckBox",
}

local CHECK_BOXS_PANEL = {
    ["VendueListCheckBox"] = "VenduePanel",
    ["PublicListCheckBox"] = "PublicPanel",
}

-- 菜单
local MENU_LIST_ONE = {
    CHS[7000306],   -- 搜索结果
    CHS[4000401],    CHS[4010051], -- 收藏，
    CHS[4200254],    CHS[4200255],    CHS[4200256], -- 宠物，武器，防具
    CHS[4200257],    CHS[4200258],    -- 法宝，首饰
}

local MENU_LIST_ONE_PUBLIC = {
    CHS[7000306],   -- 搜索结果
    CHS[4000401],   -- 收藏，
    CHS[4200254],    CHS[4200255],    CHS[4200256], -- 宠物，武器，防具
    CHS[4200257],    CHS[4200258],    -- 法宝，首饰
}

local MAIN_GOOD_TYPE = {
    [CHS[2200144]] = JUBAO_SELL_TYPE.SALE_TYPE_ROLE,                    -- 角色
    [CHS[2200145]] = JUBAO_SELL_TYPE.SALE_TYPE_CASH,                    -- 金钱
    [CHS[2200146]] = JUBAO_SELL_TYPE.SALE_TYPE_PET,                     -- 宠物
    [CHS[2200147]] = JUBAO_SELL_TYPE.SALE_TYPE_WEAPON,                  -- 武器
    [CHS[2200148]] = JUBAO_SELL_TYPE.SALE_TYPE_PROTECTOR,               -- 防具
    [CHS[2200149]] = JUBAO_SELL_TYPE.SALE_TYPE_JEWELRY,                 -- 首饰
    [CHS[2200150]] = JUBAO_SELL_TYPE.SALE_TYPE_ARTIFACT ,               -- 法宝
}

local LIST_TYPE_MAP = {
    VendueListCheckBox = TradingMgr.LIST_TYPE.AUCTION_LIST,
    PublicListCheckBox = TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST,
}

-- 单选框初始化
function JuBaoZhaiVendueDlg:initForChildDlg()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOXS, self.onCheckBox)
    self.radioGroup:setSetlctByName(CHECK_BOXS[1])
    self.curDisplay = CHECK_BOXS[1]

    self:bindListener("CollectButton", self.onCollectButton, "PublicPanel")
    self:bindListener("CollectButton", self.onCollectButton, "VenduePanel")
    self:bindListener("ViewButton", self.onViewButton, "VenduePanel")
    self:bindListener("ViewButton", self.onViewButton, "PublicPanel")
    self:bindListener("LianxiButton", self.onLianxiButton, "PublicPanel")
    self:bindListener("LianxiButton", self.onLianxiButton, "VenduePanel")
    self:bindListener("EagleEyeButton", self.onEagleEyeButton, "PublicPanel")
    self:bindListener("EagleEyeButton", self.onEagleEyeButton, "VenduePanel")

    self:hookMsg("MSG_TRADING_AUCTION_BID_LIST")
end


function JuBaoZhaiVendueDlg:setMenuList(panelName)
    if not self:getControl(panelName) then return end
    local list = self:resetListView("GoodsTypeListView", 5, nil, panelName)
    list:setBounceEnabled(false)

    if panelName == "PublicPanel" then
        -- 加载一级菜单
        for i = 1, #MENU_LIST_ONE_PUBLIC do
            local bigMenu = self.bigMenuPanel:clone()
            self:setBigMenuCellInfo(i, bigMenu, MENU_LIST_ONE_PUBLIC)
            list:pushBackCustomItem(bigMenu)
        end
    else
        -- 加载一级菜单
        for i = 1, #MENU_LIST_ONE do
            local bigMenu = self.bigMenuPanel:clone()
            self:setBigMenuCellInfo(i, bigMenu, MENU_LIST_ONE)
            list:pushBackCustomItem(bigMenu)
        end
    end

    list:doLayout()
    list:refreshView()
end

function JuBaoZhaiVendueDlg:setNoticePanelTips(curListType)
    local panel = self:getControl("NoticePanel", nil, "VenduePanel")
    if curListType  == CHS[4010051] then
        self:setLabelText("InfoLabel1", CHS[4101097], panel)
        self:setLabelText("InfoLabel2", CHS[4101098], panel)
    else
        self:setLabelText("InfoLabel1", CHS[4101099], panel)
        self:setLabelText("InfoLabel2", CHS[4101100], panel)
    end
end

function JuBaoZhaiVendueDlg:onEagleEyeButton(sender, eventType)

    local dlg = DlgMgr:openDlg("JuBaoZhaiSearchDlg")
    dlg:setForVendue()
end

function JuBaoZhaiVendueDlg:getListType()
    return self.curDisplay == "VendueListCheckBox" and TradingMgr.LIST_TYPE.AUCTION_LIST or TradingMgr.LIST_TYPE.AUCTION_SHOW_LIST
end

function JuBaoZhaiVendueDlg:getTradingType()
    return LIST_TYPE_MAP
end

-- 初始化菜单
function JuBaoZhaiVendueDlg:getBigMenuList()
    return MENU_LIST_ONE
end

-- 初始化菜单
function JuBaoZhaiVendueDlg:initMenuList()
    self:setMenuList("VenduePanel")
    self:setMenuList("PublicPanel")
end

-- 获取子菜单
function JuBaoZhaiVendueDlg:getSubMenuList(str)
    return nil
end

function JuBaoZhaiVendueDlg:getGoodTypeByName(name)
    return JuBaoZhaiGoodsListShowDlg.getGoodTypeByName(self, name) or MAIN_GOOD_TYPE[name]
end

function JuBaoZhaiVendueDlg:MSG_TRADING_AUCTION_BID_LIST(data)
    data.list_type = TradingMgr.LIST_TYPE.AUCTION_LIST
    self:MSG_TRADING_GOODS_LIST(data, CHS[4010051])
end

return JuBaoZhaiVendueDlg
