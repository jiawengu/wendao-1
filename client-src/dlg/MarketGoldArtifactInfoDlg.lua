-- MarketGoldArtifactInfoDlg.lua
-- Created by songcw
-- 珍宝展示界面，法宝

local MarketGoldArtifactInfoDlg = Singleton("MarketGoldArtifactInfoDlg", Dialog)

function MarketGoldArtifactInfoDlg:init()
    self:bindListener("SlipButton", self.onSlipButton)

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_GOLD_STALL_MINE")
end

-- 设置法宝信息
function MarketGoldArtifactInfoDlg:setArtifactInfo(artifact)
    self.item = artifact
    EquipmentMgr:setArtifactForJubao(self, artifact)
end

function MarketGoldArtifactInfoDlg:cleanup()
    if self.childDlg then

        for dlgName, dlg in pairs(self.childDlg) do
            DlgMgr:closeDlg(dlgName)
        end

        self.childDlg = nil
    end

    self.item = nil
end

function MarketGoldArtifactInfoDlg:MSG_INVENTORY(data)
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

function MarketGoldArtifactInfoDlg:MSG_GOLD_STALL_BUY_RESULT(data)

        self:onCloseButton()

end

function MarketGoldArtifactInfoDlg:MSG_GOLD_STALL_MINE(data)
    if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    end
end

function MarketGoldArtifactInfoDlg:onSlipButton(sender, eventType)
end

return MarketGoldArtifactInfoDlg
