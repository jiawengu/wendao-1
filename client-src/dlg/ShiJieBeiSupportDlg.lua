-- ShiJieBeiSupportDlg.lua
-- Created by songcw Jun/04/2018
--

local ShiJieBeiSupportDlg = Singleton("ShiJieBeiSupportDlg", Dialog)

function ShiJieBeiSupportDlg:init(data)

    self:bindListener("SupplyButton", self.onSupplyButton)
    self:bindPressForIntervalCallback("AddButton", 0.2, self.onAddButton, "times")
    self:bindPressForIntervalCallback("ReduceButton", 0.2, self.onReduceButton, "times")
    self:bindSliderListener("AddSlider",self.onSlider)

    self.newAddNum = 0
    -- 拥有支持券数量
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[4300432], true)

    self:setLabelText("Label_89", data.support_team)

    self:setImage("Image_88", ResMgr.ui[data.support_team])
    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[4300432]))
    self:refreshHaveSupportsNum(data.support_num)
    self:refreshNumPanel()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP")

--    self:setLabelText("TicketLabel_2", "+")
end

-- 刷新已投票数量
function ShiJieBeiSupportDlg:refreshHaveSupportsNum(num)
    self:setLabelText("TicketLabel_1", string.format(CHS[4300433], num))  -- 已支持数量：%d
end

-- slider事件
function ShiJieBeiSupportDlg:onSlider(sender, eventType)
    local percent = sender:getPercent()
    self.newAddNum = math.ceil(self.haveNum * percent / 100)

    -- 陈俊说需要精准下
    local float = self.haveNum * percent / 100 - math.floor( self.haveNum * percent / 100 )
    if float < 0.5 then
        self.newAddNum = math.floor(self.haveNum * percent / 100)
    else
        self.newAddNum = math.ceil(self.haveNum * percent / 100)
    end

    self:refreshNumPanel()
end

-- 刷新支持券显示数量
function ShiJieBeiSupportDlg:refreshNumPanel()
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[4300432], true)
    self:setNumImgForPanel("NumberPanel", ART_FONT_COLOR.NORMAL_TEXT, self.haveNum - self.newAddNum, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "ItemPanel")
    self:setLabelText("NumberLabel", self.newAddNum, "AddTicketPanel")
    self:setLabelText("TicketLabel_2", string.format(CHS[7100195], self.newAddNum), "TicketPanel")

    -- 刷新slider
    local slider = self:getControl("AddSlider")
    local percent = self.newAddNum * 100 / self.haveNum
    slider:setPercent(percent)

    -- 刷新按钮置灰
    self:refreshButtonStatus()
end

-- 刷新按钮置灰
function ShiJieBeiSupportDlg:refreshButtonStatus()
    self:setCtrlEnabled("ReduceButton", self.newAddNum > 0)
    self:setCtrlEnabled("AddButton", self.newAddNum < self.haveNum)
    self:setCtrlEnabled("SupplyButton", self.newAddNum > 0)
end

function ShiJieBeiSupportDlg:onReduceButton(sender, eventType)
    if self.newAddNum > 0 then
        self.newAddNum = self.newAddNum - 1
        self:refreshNumPanel()
    end
end

function ShiJieBeiSupportDlg:onAddButton(sender, eventType)
    if self.newAddNum < self.haveNum then
        self.newAddNum = self.newAddNum + 1
        self:refreshNumPanel()
    end
end


function ShiJieBeiSupportDlg:onSupplyButton(sender, eventType)
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[4300432], true)
    if self.haveNum == 0 or self.haveNum < self.newAddNum then
        gf:ShowSmallTips(CHS[4300434])
        return
    end

    local item = InventoryMgr:getItemByName(CHS[4300432])
    gf:CmdToServer('CMD_APPLY', {pos = item[1].pos, amount = self.newAddNum})
    self:onCloseButton()
end

function ShiJieBeiSupportDlg:MSG_INVENTORY(data)
    self.newAddNum = 0
    -- 拥有支持券数量
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[4300432], true)
    self:refreshNumPanel()
end

function ShiJieBeiSupportDlg:MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP(data)
    self:refreshHaveSupportsNum(data.support_num)
end

return ShiJieBeiSupportDlg
