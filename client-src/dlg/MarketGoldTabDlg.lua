-- MarketGoldTabDlg.lua
-- Created by zhengjh Apr/20/2016
-- 珍宝标签页面

local TabDlg = require('dlg/TabDlg')
local MarketGoldTabDlg = Singleton("MarketGoldTabDlg", TabDlg)


MarketGoldTabDlg.lastDlg = "MarketGoldBuyDlg"

-- 按钮与对话框的映射表
MarketGoldTabDlg.dlgs = {
    MarketBuyDlgCheckBox = "MarketGoldBuyDlg",
    MarketSellDlgCheckBox = "MarketGoldSellDlg",
    MarketPublicityDlgCheckBox = "MarketGlodPublicityDlg",
    MarketCollectionDlgCheckBox = "MarketGoldCollectionDlg",
    MarketVendueDlgCheckBox = "MarketGoldVendueDlg",
}

function MarketGoldTabDlg:init()
    TabDlg.init(self)
    self:setCtrlVisible("MarketAuctionDlgCheckBox", false)
    self:setCtrlVisible("MarketVendueDlgCheckBox", false)

    if MarketMgr.goldStallConfig and MarketMgr.goldStallConfig.enable_autcion == 1 then
        self:setCtrlVisible("MarketVendueDlgCheckBox", true)
    end
end

function MarketGoldTabDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MarketTabDlg")
end

function MarketGoldTabDlg:preClick(sender, idx)
    local meLevel = Me:getLevel()
    local ctrlName = sender:getName()
    if ctrlName == "MarketSellDlgCheckBox" then
        if meLevel < MarketMgr:getGoldOnSellLevel() then
            gf:ShowSmallTips(string.format(CHS[3003100], MarketMgr:getGoldOnSellLevel()))
            return false
        end
    end

    return true
end

MarketGoldTabDlg:setPreCallBack(MarketGoldTabDlg.preClick)

return MarketGoldTabDlg
