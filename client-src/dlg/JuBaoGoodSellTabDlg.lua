-- JuBaoGoodSellTabDlg.lua
-- Created by songcw Dec/30/2016
-- 聚宝斋寄售Tab

local TabDlg = require('dlg/TabDlg')
local JuBaoGoodSellTabDlg = Singleton("JuBaoGoodSellTabDlg", TabDlg)

-- 按钮与对话框的映射表
JuBaoGoodSellTabDlg.dlgs = {
    JuBaoUserSellDlgCheckBox = "UserSellDlg",
    JuBaoPetSellDlgCheckBox = "JuBaoPetSellDlg",
    JuBaoEquipSellDlgCheckBox = "JuBaoEquipSellDlg",
    JuBaoCashSellDlgCheckBox = "JuBaoCashSellDlg",
}

function JuBaoGoodSellTabDlg:onClickCashSell(sender, idx)
    local ctrlName = sender:getName()
    if ctrlName and "JuBaoCashSellDlgCheckBox" == ctrlName then
        if not TradingMgr:getIsCanSellCash() then
            gf:ShowSmallTips(string.format(CHS[7190098], TradingMgr:getSellCashAfterDays()))
            return false
        end
    end
    
    return true
end

JuBaoGoodSellTabDlg:setPreCallBack(JuBaoGoodSellTabDlg.onClickCashSell)

return JuBaoGoodSellTabDlg
