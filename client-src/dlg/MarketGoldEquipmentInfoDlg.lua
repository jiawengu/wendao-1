-- MarketGoldEquipmentInfoDlg.lua
-- Created by songcw
-- 珍宝展示界面，装备


local MarketGoldEquipmentInfoDlg = Singleton("MarketGoldEquipmentInfoDlg", Dialog)

function MarketGoldEquipmentInfoDlg:init()
    self:bindListener("SlipButton", self.onSlipButton)

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_GOLD_STALL_MINE")
end

function MarketGoldEquipmentInfoDlg:cleanup()
    if self.childDlg then

        for dlgName, dlg in pairs(self.childDlg) do
            DlgMgr:closeDlg(dlgName)
        end

        self.childDlg = nil
    end

    self.item = nil
end

function MarketGoldEquipmentInfoDlg:onSlipButton(sender, eventType)
end

-- 更新向下提示
function MarketGoldEquipmentInfoDlg:updateDownArrow(sender, eventType)
    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)


        self:setCtrlVisible("SlipButton", persent < 93)-- 留一点空余部分
    end
end

-- 设置武器信息
function MarketGoldEquipmentInfoDlg:setEquipmentInfo(equipment)
    self.item = equipment
    EquipmentMgr:setEquipForJubao(self, equipment)


    local scrollview = self:getControl("ScrollView")


    scrollview:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
end

function MarketGoldEquipmentInfoDlg:MSG_INVENTORY(data)
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

function MarketGoldEquipmentInfoDlg:MSG_GOLD_STALL_BUY_RESULT(data)
    --if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    --end
end

function MarketGoldEquipmentInfoDlg:MSG_GOLD_STALL_MINE(data)
    if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    end
end

return MarketGoldEquipmentInfoDlg
