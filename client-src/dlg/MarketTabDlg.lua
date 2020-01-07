-- MarketTabDlg.lua
-- Created by liuhb Apr/22/2015
-- 集市标签页面

local TabDlg = require('dlg/TabDlg')
local MarketTabDlg = Singleton("MarketTabDlg", TabDlg)


MarketTabDlg.lastDlg = "MarketBuyDlg"

-- 按钮与对话框的映射表
MarketTabDlg.dlgs = {
    MarketBuyDlgCheckBox = "MarketBuyDlg",
    MarketSellDlgCheckBox = "MarketSellDlg",
    MarketPublicityDlgCheckBox = "MarketPublicityDlg",
    MarketCollectionDlgCheckBox = "MarketCollectionDlg",
}

function MarketTabDlg:init()
    TabDlg.init(self)
    self:setCtrlVisible("MarketVendueDlgCheckBox", false)
end

function MarketTabDlg:preClick(sender, idx)
    local meLevel = Me:getLevel()
    local ctrlName = sender:getName()
    if ctrlName == "MarketSellDlgCheckBox" then
        if meLevel < MarketMgr:getOnSellLevel() then
            gf:ShowSmallTips(string.format(CHS[3003100], MarketMgr:getOnSellLevel()))
            return false
        end
    end

    return true
end

function MarketTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "MarketBuyDlg"
end

MarketTabDlg:setPreCallBack(MarketTabDlg.preClick)

return MarketTabDlg
