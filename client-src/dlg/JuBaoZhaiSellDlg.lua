-- JuBaoZhaiSellDlg.lua
-- Created by 
-- 

local JuBaoZhaiGoodsListShowDlg = require('dlg/JuBaoZhaiGoodsListShowDlg')
local JuBaoZhaiSellDlg = Singleton("JuBaoZhaiSellDlg", JuBaoZhaiGoodsListShowDlg)
local RadioGroup = require("ctrl/RadioGroup")

local CHECK_BOXS = {
    "SellListCheckBox",
    "PublicListCheckBox",
}

local CHECK_BOXS_PANEL = {
    ["SellListCheckBox"] = "SellPanel",
    ["PublicListCheckBox"] = "PublicPanel",
}

-- 菜单
local MENU_LIST_ONE = {
    CHS[7000306],   -- 搜索结果
    CHS[4000401],    CHS[7190083],    CHS[4000402], -- 收藏，金钱，角 色 
    CHS[4200254],    CHS[4200255],    CHS[4200256], -- 宠物，武器，防具 
    CHS[4200257],    CHS[4200258],    -- 法宝，首饰
}

local LIST_TYPE_MAP = {
    SellListCheckBox = TradingMgr.LIST_TYPE.SALE_LIST,
    PublicListCheckBox = TradingMgr.LIST_TYPE.SHOW_LIST,
}

-- 单选框初始化
function JuBaoZhaiSellDlg:initForChildDlg()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOXS, self.onCheckBox)
    self.radioGroup:setSetlctByName(CHECK_BOXS[1])
    self.curDisplay = CHECK_BOXS[1]
    
    self:bindListener("CollectButton", self.onCollectButton, "PublicPanel")
    self:bindListener("CollectButton", self.onCollectButton, "SellPanel")
    self:bindListener("ViewButton", self.onViewButton, "SellPanel")
    self:bindListener("ViewButton", self.onViewButton, "PublicPanel")
    self:bindListener("LianxiButton", self.onLianxiButton, "PublicPanel")
    self:bindListener("LianxiButton", self.onLianxiButton, "SellPanel")
    self:bindListener("EagleEyeButton", self.onEagleEyeButton, "PublicPanel")
    self:bindListener("EagleEyeButton", self.onEagleEyeButton, "SellPanel")
end

function JuBaoZhaiSellDlg:getListType()
    return self.curDisplay == "SellListCheckBox" and TradingMgr.LIST_TYPE.SALE_LIST or TradingMgr.LIST_TYPE.SHOW_LIST
end

function JuBaoZhaiSellDlg:getTradingType()
    return LIST_TYPE_MAP
end

-- 初始化菜单
function JuBaoZhaiSellDlg:getBigMenuList()
    return MENU_LIST_ONE
end

-- 初始化菜单
function JuBaoZhaiSellDlg:initMenuList()
    self:setMenuList("SellPanel")
    self:setMenuList("PublicPanel")
end


return JuBaoZhaiSellDlg
