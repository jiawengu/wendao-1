-- MarketGoldJewerlyInfoDlg.lua
-- Created by songcw
-- 珍宝展示界面，首饰

local MarketGoldJewerlyInfoDlg = Singleton("MarketGoldJewerlyInfoDlg", Dialog)

function MarketGoldJewerlyInfoDlg:init()
    self:bindListener("SlipButton", self.onSlipButton)

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_GOLD_STALL_MINE")
end

function MarketGoldJewerlyInfoDlg:onSlipButton(sender, eventType)
end

-- 设置首饰信息
function MarketGoldJewerlyInfoDlg:setJewelryInfo(jewelry)
    self.item = jewelry
    EquipmentMgr:setJewelryForJubao(self, jewelry)
end

function MarketGoldJewerlyInfoDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end

    if not self.item then
        self:onCloseButton()
        return
    end

    for i = 1, data.count do
        if data[i].pos == self.item.pos and not data[i].name then
            self:onCloseButton()
        end
    end
end

function MarketGoldJewerlyInfoDlg:cleanup()
    if self.childDlg then
        for dlgName, dlg in pairs(self.childDlg) do
            DlgMgr:closeDlg(dlgName)
        end

        self.childDlg = nil
    end

    self.item = nil
end

function MarketGoldJewerlyInfoDlg:MSG_GOLD_STALL_BUY_RESULT(data)
    --if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    --end
end

function MarketGoldJewerlyInfoDlg:MSG_GOLD_STALL_MINE(data)
    if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    end
end

return MarketGoldJewerlyInfoDlg
