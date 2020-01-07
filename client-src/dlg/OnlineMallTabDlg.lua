-- OnlineMallTabDlg.lua
-- Created by zhengjh Mar/2/2015
-- 商城标签页


local TabDlg = require('dlg/TabDlg')
local OnlineMallTabDlg = Singleton("OnlineMallTabDlg", TabDlg)

OnlineMallTabDlg.defDlg = "OnlineMallDlg"

-- 按钮与对话框的映射表
OnlineMallTabDlg.dlgs = {
    RechargeCheckBox = "OnlineRechargeDlg",
    ItemCheckBox = "OnlineMallDlg",
    VIPCheckBox = "OnlineMallVIPDlg",
    MoneyCheckBox = "OnlineMallExchangeMoneyDlg",
}

function OnlineMallTabDlg:init()
    if GameMgr.isIOSReview then
        local checkBox = self:getControl("VIPCheckBox")
        self:setLabelText("UnChosenLabel_1", CHS[3003183], checkBox)
        self:setLabelText("UnChosenLabel_2", CHS[3003183], checkBox)
        
        self:setLabelText("ChosenLabel_1", CHS[3003183], checkBox)
        self:setLabelText("ChosenLabel_2", CHS[3003183], checkBox)
    end
    
    RedDotMgr:removeOneRedDot("SystemFunctionDlg", "MallButton")
    TabDlg.init(self)
end

function OnlineMallTabDlg:cleanup()
    performWithDelay(gf:getUILayer(), function ()
        if not Me:isGetCoin() and Me:getVipType() > 0 then
            RedDotMgr:insertOneRedDot("SystemFunctionDlg", "MallButton")
        end  
    end, 0)
end

function OnlineMallTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "OnlineMallDlg"
end

return OnlineMallTabDlg
