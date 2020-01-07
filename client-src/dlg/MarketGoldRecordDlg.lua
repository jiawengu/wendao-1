-- MarketRecordDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝记录界面

local MarketRecordDlg = require('dlg/MarketRecordDlg')
local MarketGoldRecordDlg = Singleton("MarketGoldRecordDlg", MarketRecordDlg)

function MarketGoldRecordDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketRecordDlg")
end

function MarketGoldRecordDlg:viewItem(data)
    gf:CmdToServer("CMD_GOLD_STALL_RECORD_DETAIL", data);
end

function MarketGoldRecordDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", true, self.itemCtrl)
    self:setCtrlVisible("CoinImage", false, self.itemCtrl)
end

-- 设置所有hook消息
function MarketGoldRecordDlg:setAllHookMsgs()
    self:hookMsg("MSG_GOLD_STALL_RECORD")
    self:hookMsg("MSG_GOLD_STALL_RECORD_DETAIL")
end

function MarketGoldRecordDlg:MSG_GOLD_STALL_RECORD()
    self:MSG_STALL_RECORD()
end

function MarketGoldRecordDlg:MSG_GOLD_STALL_RECORD_DETAIL(data)
    self:MSG_STALL_RECORD_DETAIL(data)
end

function MarketGoldRecordDlg:tradeType()
    return MarketMgr.TradeType.goldType
end

function MarketGoldRecordDlg:setTileInfo(key)
    local infoPanel = self:getControl("InfoPanel")
    local listTitlePanel = self:getControl("ListTitlePanel")
    local leftTimelable = self:getControl("Label3", nil, listTitlePanel)
    local str = ""
    if key == "SellListView" then
        str = CHS[6000225]
        self:setCtrlVisible("InfoLabel1", false, infoPanel)
        self:setCtrlVisible("InfoLabel2", true, infoPanel)
    elseif key == "BuyListView" then
        str = CHS[6000226]
        self:setCtrlVisible("InfoLabel1", false, infoPanel)
        self:setCtrlVisible("InfoLabel2", true, infoPanel)
    elseif key == "VerifyListView" then
        str = CHS[6000227]
        self:setCtrlVisible("InfoLabel1", true, infoPanel)
        self:setCtrlVisible("InfoLabel2", false, infoPanel)
    end

    leftTimelable:setString(str)
end

return MarketGoldRecordDlg
