-- SeekFriendMemberDlg.lua
-- Created by songcw Oct/22/2018
-- 寻找好友界面-福利界面

local SeekFriendMemberDlg = Singleton("SeekFriendMemberDlg", Dialog)

function SeekFriendMemberDlg:init()
--    self:bindListener("InforButton", self.onInforButton)
--    self:bindListener("InforButton", self.onInforButton)
--    self:bindListViewListener("ListView", self.onSelectListView)

    self.unitPanel = self:retainCtrl("UnitPanel")
    local leftPanel = self:getControl("LeftPanel", nil, self.unitPanel)
    local rightPanel = self:getControl("RightPanel", nil, self.unitPanel)

    self:bindTouchEndEventListener(leftPanel, self.selectChar)
    self:bindTouchEndEventListener(rightPanel, self.selectChar)
    self:bindListener("PortraitPanel", self.onPortraitPanel, leftPanel)
    self:bindListener("PortraitPanel", self.onPortraitPanel, rightPanel)

    self:setCtrlOnlyEnabled("InforButton", false, leftPanel)
    self:setCtrlOnlyEnabled("InforButton", false, rightPanel)

  --  self:bindListener("InforButton", self.onInforButton, leftPanel)
  --  self:bindListener("InforButton", self.onInforButton, rightPanel)

    -- 再一次请求，怕玩家福利界面放很久才切换，更新数据
    gf:CmdToServer("CMD_BJTX_WELFARE")

    local data = GiftMgr:getXYFLData()
    self:setFriends(data)

    self:hookMsg("MSG_BJTX_WELFARE")
end

function SeekFriendMemberDlg:setFriends(data)
    local list = self:resetListView("ListView")

    if not data then return end

    local count = data.count / 2 + data.count % 2
    local idx = 0
    for i = 1, count do
        local panel = self.unitPanel:clone()

        idx = idx + 1
        self:setUnitPanel(data[idx], self:getControl("LeftPanel", nil, panel))

        idx = idx + 1
        self:setUnitPanel(data[idx], self:getControl("RightPanel", nil, panel))

        list:pushBackCustomItem(panel)
    end
end

function SeekFriendMemberDlg:selectChar(sender)
    local data = sender.data
    DlgMgr:openDlgEx("SeekFriendWelfareDlg", data)

    if data.is_new == 1 then
        gf:CmdToServer("CMD_BJTX_FETCH_BONUS", {char_gid = data.gid, index = 0})
    end

end

function SeekFriendMemberDlg:onPortraitPanel(sender)
    local data = sender:getParent().data
    if not data or data.gid == Me:queryBasic("gid") then return end
    local char = {}
    char.gid = data.gid
    char.name = data.name
    char.level = data.level or 0
    char.icon = data.icon

    local rect = self:getBoundingBoxInWorldSpace(sender)
    FriendMgr:openCharMenu(char, nil, rect)
end

function SeekFriendMemberDlg:setUnitPanel(data, cell)

    if not data then
        cell:setVisible(false)
        return
    end

    cell.data = data
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)
    self:setLabelText("NameLabel", data.name, cell)

    self:setLabelText("TargetLabel", string.format( CHS[4010223], data.completedCount), cell)

    if data.is_new == 1 then
        self:addRedDot(cell)
    end

    for i = 1, data.bonus_size do
        if data.bonusData[i].is_fetch == 0 and data.bonusData[i].num_max <= data.bonusData[i].num then
            self:addRedDot(cell)
        end
    end
end

function SeekFriendMemberDlg:onInforButton(sender, eventType)
end

function SeekFriendMemberDlg:onInforButton(sender, eventType)
end

function SeekFriendMemberDlg:onSelectListView(sender, eventType)
end


function SeekFriendMemberDlg:MSG_BJTX_WELFARE(data)
    self:setFriends(data)
end

return SeekFriendMemberDlg
