-- PartyRedBagMoneyRecordDlg.lua
-- Created by zhengjh Aug/27/2016
-- 帮派红包记录 

local PartyRedBagMoneyRecordDlg = Singleton("PartyRedBagMoneyRecordDlg", Dialog)
local COLUMN = 2
local PANEL_CONFIG =
{
    OutRedBagPanel = "OutRedBagMainPanel",
    GetRedBagPanel = "GetRedBagMainPanel",
}

function PartyRedBagMoneyRecordDlg:init()
    self:bindListener("TagButton", self.onTagButton)
    self:bindListener("OutRedBagPanel", self.onOutRedBagPanel)
    self:bindListener("GetRedBagPanel", self.onGetRedBagPanel)
    
    self.oneGetRedBagRow = self:getControl("OneRowRecordPanel")
    self.oneGetRedBagRow:retain()
    self.oneGetRedBagRow:removeFromParent()

    self.getRedBagCell = self:getControl("GetRecordPanel_1", nil, self.oneGetRedBagRow)
    self.getRedBagCell:retain()
    self.getRedBagCell:removeFromParent()
    
    self.oneOutRedBagRow = self:getControl("OneRowRecordPanel")
    self.oneOutRedBagRow:retain()
    self.oneOutRedBagRow:removeFromParent()

    self.outRedBagCell = self:getControl("OutRecordPanel_1", nil, self.oneOutRedBagRow)
    self.outRedBagCell:retain()
    self.outRedBagCell:removeFromParent()
    
    -- 关闭tip
    self:bindCloseTips()
    
    self.panelList = {}
    
    for k, v in pairs(PANEL_CONFIG) do
        if v then
            local panel = self:getControl(v)
            panel:setVisible(false)
        end
    end
    
    self:swichPanel(self:getControl("GetRedBagPanel"))
    
    PartyMgr:getRedBagRecord()
    self:hookMsg("MSG_PT_RB_RECORD")
end

function PartyRedBagMoneyRecordDlg:MSG_PT_RB_RECORD(data)
    if data.type == 1 then -- 发送
        self:initOutRecordList()
    elseif data.type == 0 then -- 接收
        self:initGetRecordList()
    end
end

function PartyRedBagMoneyRecordDlg:initOutRecordList()
    local record = PartyMgr:getSendRedbagRecord()
    if not record then return end
    local count = record.size
    local data = record.list
    
    -- 发出的红包
    self:setLabelText("OutNumLabel", record.count)
    
    -- 总金额
    local totalPanel = self:getControl("OutTotalPanel")
    self:setLabelText("TotalLabel", record.total, totalPanel)
    
    if count == 0 then
        self:setCtrlVisible("OutRedBagNoticePanel", true)
        self:setCtrlVisible("MyOutRecordListView", true)
        return
    end
    

    local listView = self:getControl("MyOutRecordListView")
    listView:removeAllChildren()
    listView:setVisible(true)
    self:setCtrlVisible("OutRedBagNoticePanel", false)
    
    local line = math.floor(count / COLUMN)
    local left = count % COLUMN

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    
    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUMN
        end
        
        local oneRow = self:createOutRow(data, i, curColunm)
        listView:pushBackCustomItem(oneRow)
    end
end

function PartyRedBagMoneyRecordDlg:createOutRow(data, line, column)
    local row = self.oneOutRedBagRow:clone()
    for i = 1, column do
        local tag = (line - 1) * COLUMN + i
        local cell = self:createOutCell(data[tag])
        cell:setAnchorPoint(0, 1)
        local x = (cell:getContentSize().width + 10) * (i - 1)
        local y = cell:getContentSize().height
        cell:setPosition(x, y)
        row:addChild(cell)
        row:requestDoLayout()
    end

    return row
end

function PartyRedBagMoneyRecordDlg:createOutCell(data)
    local cell = self.outRedBagCell:clone()
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d", data.time or  0), cell)
    self:setLabelText("OutBonusLabel", data.coin, cell)

    return cell
end

function PartyRedBagMoneyRecordDlg:initGetRecordList()
    local record = PartyMgr:getRecvRedbagRecord()
    if not record then return end
    local count = record.size
    local data = record.list

    
    -- 抢到的红包
    self:setLabelText("GetNumLabel", record.count)
    
    -- 抢到总金额
    local totalPanel = self:getControl("GetTotalPanel")
    self:setLabelText("TotalLabel", record.total, totalPanel)
    
    if count == 0 then
        self:setCtrlVisible("GetRedBagNoticePanel", true)
        self:setCtrlVisible("MyGetRecordListView", true)
        return
    end
    
    local listView = self:getControl("MyGetRecordListView")
    listView:removeAllChildren()
    listView:setVisible(true)
    self:setCtrlVisible("GetRedBagNoticePanel", false)
    local line = math.floor(count / COLUMN)
    local left = count % COLUMN

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUMN
        end

        local oneRow = self:createGetRow(data, i, curColunm)
        listView:pushBackCustomItem(oneRow)
    end
end

function PartyRedBagMoneyRecordDlg:createGetRow(data, line, column)
    local row = self.oneGetRedBagRow:clone()
    for i = 1, column do
        local tag = (line - 1) * COLUMN + i
        local cell = self:createGetCell(data[tag])
        cell:setAnchorPoint(0, 1)
        local x = (cell:getContentSize().width + 10) * (i - 1)
        local y = cell:getContentSize().height
        cell:setPosition(x, y)
        row:addChild(cell)
        row:requestDoLayout()
    end

    return row
end

function PartyRedBagMoneyRecordDlg:createGetCell(data)
    local cell = self.getRedBagCell:clone()
    self:setLabelText("NameLabel", gf:getRealName(data.name), cell)
    self:setLabelText("GetBonusLabel", data.coin, cell)

    return cell
end

function PartyRedBagMoneyRecordDlg:onTagButton(sender, eventType)
    local panel = self:getControl("TagBKPanel")
    if panel:isVisible()  then
        self:setCtrlVisible("TagBKPanel", false)
    else
        self:setCtrlVisible("TagBKPanel", true)
    end 
end

function PartyRedBagMoneyRecordDlg:onOutRedBagPanel(sender, eventType)
    self:swichPanel(sender)
    self:setCtrlVisible("TagBKPanel", false)
    local string = self:getControl("EnoughLabel", nil, sender):getString()
    local btn = self:getControl("TagButton")
    self:setLabelText("TitleLabel", string, btn)
end

function PartyRedBagMoneyRecordDlg:onGetRedBagPanel(sender, eventType)
    self:swichPanel(sender)
    self:setCtrlVisible("TagBKPanel", false)
    local string = self:getControl("EnoughLabel", nil, sender):getString()
    local btn = self:getControl("TagButton")
    self:setLabelText("TitleLabel", string, btn)
end

function PartyRedBagMoneyRecordDlg:swichPanel(sender)
    local name = sender:getName()

    for k, v in pairs(self.panelList) do
        if v then
            v:setVisible(false)
        end
    end
    
    if self.panelList[name] then
        self.panelList[name]:setVisible(true)
    else
        self:initPanelList(name)
    end
end

function PartyRedBagMoneyRecordDlg:initPanelList(name)
    self.panelList[name] = self:getControl(PANEL_CONFIG[name])
    self.panelList[name]:setVisible(true)
    
    if name == "OutRedBagPanel" then
        self:initOutRecordList()
    elseif name == "GetRedBagPanel" then
        self:initGetRecordList()
    end
end


function PartyRedBagMoneyRecordDlg:bindCloseTips()
    local panel = self:getControl("TagBKPanel")
    local bkPanel = self:getControl("BKPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())
    self:setCtrlVisible("ChongfsPayPanel", false)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()
        if not cc.rectContainsPoint(rect, toPos) and panel:isVisible() then
            self:setCtrlVisible("TagBKPanel", false)
            return true
        end
    end

    self.root:addChild(layout, 10, 1)
    gf:bindTouchListener(layout, touch)
end

function PartyRedBagMoneyRecordDlg:cleanup()
    self:releaseCloneCtrl("oneGetRedBagRow")
    self:releaseCloneCtrl("getRedBagCell")
    self:releaseCloneCtrl("oneOutRedBagRow")
    self:releaseCloneCtrl("outRedBagCell")
end

return PartyRedBagMoneyRecordDlg
