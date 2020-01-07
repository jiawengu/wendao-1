-- GiveRecordDlg.lua
-- Created by huangzz Sep/19/2018
-- 赠送记录界面

local GiveRecordDlg = Singleton("GiveRecordDlg", Dialog)

function GiveRecordDlg:init()
    self.timePanel = self:retainCtrl("TimePanel")
    self.contentPanel = self:retainCtrl("ContentPanel")

    self:bindTouchEndEventListener(self.contentPanel, self.onContentPanel)
end

function GiveRecordDlg:setData(data)
    local listView = self:getControl("ListView")
    listView:removeAllItems()

    if not data or #data == 0 then
        self:setCtrlVisible("NoticePanel_0", true)
        return
    end

    self:setCtrlVisible("NoticePanel_0", false)

    table.sort(data, function(l, r)
        if l.time > r.time then return true end
    end)

    local lastTime = 0
    local size = self.contentPanel:getContentSize()
    for i = 1, #data do
        if not gf:isSameDay(lastTime, data[i].time) then
            local timeCell = self.timePanel:clone()
            self:setLabelText("TimeLabel", gf:getServerDate(CHS[4300233], data[i].time), timeCell)
            listView:pushBackCustomItem(timeCell)
        end

        local cell = self.contentPanel:clone()
        local timeStr = gf:getServerDate(CHS[4100718], data[i].time)
        local height
        if data[i].accept_gid == Me:queryBasic("gid") then
            height = self:setColorText(string.format(CHS[5420326], timeStr, data[i].giving_name, data[i].amount, data[i].unit, data[i].item_name), "TextPanel", cell)
        else
            height = self:setColorText(string.format(CHS[5420327], timeStr, data[i].accept_name, data[i].amount, data[i].unit, data[i].item_name), "TextPanel", cell)
        end

        cell:setContentSize(size.width, height + 18)

        cell.data = data[i]
        listView:pushBackCustomItem(cell)

        lastTime = data[i].time
    end
end

function GiveRecordDlg:onContentPanel(sender, eventType)
    local data = sender.data
    if data then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        ChatMgr:sendGiveCardInfo(data.id, rect)
    end
end

return GiveRecordDlg
