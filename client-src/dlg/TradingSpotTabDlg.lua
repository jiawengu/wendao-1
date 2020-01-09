-- TradingSpotTabDlg.lua
-- Created by lixh Des/26/2018
-- 商贾货站页签

local TabDlg = require('dlg/TabDlg')
local TradingSpotTabDlg = Singleton("TradingSpotTabDlg", TabDlg)

TradingSpotTabDlg.orderList = {
    ['TradingSpotItemDlgCheckBox']     = 1,
    ['TradingSpotProfitDlgCheckBox']   = 2,
    ['TradingSpotDiscussDlgCheckBox']  = 3,
    ["TradingSpotInfoDlgCheckBox"] = 4,
}

TradingSpotTabDlg.dlgs = {
    TradingSpotItemDlgCheckBox     = 'TradingSpotItemDlg',
    TradingSpotProfitDlgCheckBox   = 'TradingSpotProfitDlg',
    TradingSpotDiscussDlgCheckBox  = 'TradingSpotDiscussDlg',
    TradingSpotInfoDlgCheckBox  = 'TradingSpotInfoDlg',
}

TradingSpotTabDlg.defDlg = "TradingSpotItemDlg"

function TradingSpotTabDlg:init()
    TabDlg.init(self)
end

function TradingSpotTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "TradingSpotItemDlg"
end

return TradingSpotTabDlg
