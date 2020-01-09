-- MingrzbtpDlg.lua
-- Created by lixh Mar/05/2018
-- 名人争霸竞猜界面

local MingrzbtpDlg = Singleton("MingrzbtpDlg", Dialog)

function MingrzbtpDlg:init(data)
    self:bindPressForIntervalCallback("AddButton", 0.2, self.onAddButton, "times")
    self:bindPressForIntervalCallback("ReduceButton", 0.2, self.onReduceButton, "times")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindSliderListener("AddSlider",self.onSlider)

    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[7100186]))
    self:setLabelText("TeamLabel", string.format(CHS[7100198], data.name))
    self:refreshHaveSupportsNum(data.supports)

    -- 拥有支持券数量
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[7100186], true)
    
    self.newAddNum = 0

    self:refreshNumPanel()
    
    self.teamInfo = data
end

-- 刷新已投票数量
function MingrzbtpDlg:refreshHaveSupportsNum(num)
    self:setLabelText("TicketLabel_1", string.format(CHS[7100194], num), "TicketPanel")
end

-- 刷新支持券显示数量
function MingrzbtpDlg:refreshNumPanel()
    self.haveNum = InventoryMgr:getAmountByNameIsForeverBind(CHS[7100186], true)
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
function MingrzbtpDlg:refreshButtonStatus()
    self:setCtrlEnabled("ReduceButton", self.newAddNum > 0)
    self:setCtrlEnabled("AddButton", self.newAddNum < self.haveNum)
    self:setCtrlEnabled("ConfirmButton", self.newAddNum > 0)
end

-- slider事件
function MingrzbtpDlg:onSlider(sender, eventType)
    local percent = sender:getPercent()
    self.newAddNum = math.ceil(self.haveNum * percent / 100)
    self:refreshNumPanel()
end

function MingrzbtpDlg:onAddButton(sender, eventType)
    if self.newAddNum < self.haveNum then
        self.newAddNum = self.newAddNum + 1
        self:refreshNumPanel()
    end
end

function MingrzbtpDlg:onReduceButton(sender, eventType)
    if self.newAddNum > 0 then
        self.newAddNum = self.newAddNum - 1
        self:refreshNumPanel()
    end
end

function MingrzbtpDlg:onConfirmButton(sender, eventType)
    MingrzbjcMgr:fetchScSupportsTeam(self.teamInfo.competName, self.teamInfo.id, self.newAddNum)
end

-- 投票后，刷新数据
function MingrzbtpDlg:MSG_CG_SUPPORT_RESULT(data)
    self:refreshHaveSupportsNum(data.mySupports)

    self.newAddNum = 0
    self:refreshNumPanel()
end

return MingrzbtpDlg
