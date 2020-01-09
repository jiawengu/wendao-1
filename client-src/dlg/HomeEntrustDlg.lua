-- HomeEntrustDlg.lua
-- Created by sujl, Aug/17/2017
-- 居民委托界面

local HomeEntrustDlg = Singleton("HomeEntrustDlg", Dialog)
local HomeEntrust = require(ResMgr:getCfgPath("HomeEntrust.lua"))

function HomeEntrustDlg:init(data)
    self:bindListener("FinishButton", self.onFinishButton, self:getControl("TaskPanel", nil, "TaskListView"))
    self:bindListener("MaterialIconPanel1", self.onIconPanel1, self:getControl("TaskPanel", nil, "TaskListView"))
    self:bindListener("MaterialIconPanel2", self.onIconPanel2, self:getControl("TaskPanel", nil, "TaskListView"))

    self.data = data

    local isFirst = true
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType then
            -- 获取控件
            local listViewCtrl = sender

            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local listViewSize = listViewCtrl:getContentSize()

            -- 计算滚动的百分比
            local totalWidth = innerSize.width - listViewSize.width

            local innerPosX = listInnerContent:getPositionX()
            local persent = (-innerPosX) / totalWidth

            if not isFirst then
                self:setCtrlVisible("LeftImage", persent > 0 and self.data.count >= 3)
                self:setCtrlVisible("RightImage", persent < 1 and self.data.count >= 3)
            end
            isFirst = nil
        end
    end
    local listView = self:getControl("TaskListView", nil, "MainPanel")
    listView:addScrollViewEventListener(onScrollView)

    self.taskPanel = self:retainCtrl("TaskPanel", "TaskListView")

    self:initListView()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_HOUSE_ENTRUST")
end

function HomeEntrustDlg:cleanup()
end

function HomeEntrustDlg:initListView()
    local listView = self:resetListView("TaskListView", 10, nil, "MainPanel")
    local item
    for i = 1, self.data.count do
        item = self.taskPanel:clone()
        self:setItemData(item, self.data.npcs[i])
        listView:pushBackCustomItem(item)
    end
    self:setCtrlVisible("NoticePanel", self.data.count <= 0, "MainPanel")
    self:setCtrlVisible("LeftImage", false)
    self:setCtrlVisible("RightImage", self.data.count >= 3)
    self:setCtrlVisible("CutoffImage1", self.data.count > 0, "MainPanel")
    self:setCtrlVisible("CutoffImage2", self.data.count > 0, "MainPanel")
end

function HomeEntrustDlg:setItemData(item, npc)
    self:setImage("NPCImage", ResMgr:getBigPortrait(npc.npc_icon), item)
    self:setLabelText("NameLabel", string.format(CHS[2000406], npc.npc_name), item)
    self:setImage("IconImage", ResMgr:getIconPathByName(npc.m_name), self:getControl("MaterialIconPanel1", nil, item))
    local count = InventoryMgr:getAmountByName(npc.m_name, true)
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, string.format("%d/%d", count, npc.m_num), false, LOCATE_POSITION.RIGHT_BOTTOM, 15, self:getControl("MaterialIconPanel1", nil, item))
    self:setImage("IconImage", ResMgr:getIconPathByName(npc.p_name), self:getControl("MaterialIconPanel2", nil, item))
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, npc.p_num, false, LOCATE_POSITION.RIGHT_BOTTOM, 15, self:getControl("MaterialIconPanel2", nil, item))
    local text = HomeEntrust[npc.eid]
    if text then
        local mInfo = InventoryMgr:getItemInfoByName(npc.m_name)
        local pInfo = InventoryMgr:getItemInfoByName(npc.p_name)
        self:setColorText(string.format(text, npc.m_num, mInfo.unit, npc.m_name, npc.p_num, pInfo.unit, npc.p_name), "TaskInfoPanel", item, nil, nil, nil, 17, nil, true)
    end
    self:setCtrlEnabled("UnfinishedButton", false, item)
    self:setCtrlVisible("FinishButton", count >= npc.m_num, item)
    self:setCtrlVisible("UnfinishedButton", count < npc.m_num, item)
    item.npc = npc
end

function HomeEntrustDlg:onIconPanel1(sender, eventType)
    local npc = sender:getParent():getParent().npc
    if not npc then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)          
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(npc.m_name))
    info.name = npc.m_name
    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function HomeEntrustDlg:onIconPanel2(sender, eventType)
    local npc = sender:getParent():getParent().npc
    if not npc then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)          
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(npc.p_name))
    info.name = npc.p_name
    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function HomeEntrustDlg:onFinishButton(sender, eventType)
    local npc = sender:getParent().npc
    if not npc then return end

    HomeMgr:cmdEntrust(npc)
end

function HomeEntrustDlg:MSG_INVENTORY(data)
    local listView = self:getControl("TaskListView", nil, "MainPanel")
    local items = listView:getItems()
    for i = 1, #items do
        self:setItemData(items[i], self.data.npcs[i])
    end
end

function HomeEntrustDlg:MSG_HOUSE_ENTRUST(data)
    self.data = data
    self:initListView()
end

function HomeEntrustDlg:test(count)
    self.data.count = count
    self:MSG_HOUSE_ENTRUST(self.data)
end

return HomeEntrustDlg
