-- HomePlantHelpDlg.lua
-- Created by huangzz Mar/16/2018
-- 后院协助界面

local HomePlantHelpDlg = Singleton("HomePlantHelpDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

function HomePlantHelpDlg:init(isRedDotRemoved)
    self:bindListener("ComeToButton", self.onComeToButton)  -- 前往
    self:bindListener("ShapePanel", self.onPortraitPanel, "FriendListPanel")
    self:bindListener("ShapePanel", self.onPortraitPanel, "RecordListPanel")
    self:bindListener("FurnitureImage", self.onFurniture, "FriendListPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"FriendDlgCheckBox", "HelpDlgCheckBox"}, self.onCheckBox)
    self.radioGroup:selectRadio(1)
    
    self.isRedDotRemoved = isRedDotRemoved
    
    self.friendSch = {}
    
    gf:CmdToServer("CMD_HOUSE_FARM_HELP_TARGETS", {})
    gf:CmdToServer("CMD_HOUSE_FARM_HELP_RECORDS", {})
    
    -- 好友列表
    self.friendPanel = self:retainCtrl("OneInfoPanel", "FriendListPanel")
    self:setImage("FurnitureImage", ResMgr:getIconPathByName(CHS[5400255]), self.friendPanel)
    
    -- 记录
    self.recordPanel = self:retainCtrl("OneInfoPanel", "RecordListPanel")
    self.recordsInfo = nil
    
    self:setCtrlVisible("NoticePanel", false, "FriendListPanel")
    self:setCtrlVisible("NoticePanel", false, "RecordListPanel")
    
    self:hookMsg("MSG_HOUSE_FARM_HELP_RECORDS")
    self:hookMsg("MSG_HOUSE_FARM_HELP_TARGETS")
end

function HomePlantHelpDlg:onFurniture(sender, eventType)
    local item = HomeMgr:getFurnitureInfo(CHS[5400255])
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showFurniture(item, rect, true, true)
end

function HomePlantHelpDlg:showCharMenu(sender, data)
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")

    FriendMgr:requestCharMenuInfo(data.gid)
    if FriendMgr:getCharMenuInfoByGid(data.gid) then
        dlg:setting(data.gid)
    else
        dlg:setInfo(data)
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setFloatingFramePos(rect)    
end

-- 角色悬浮框
function HomePlantHelpDlg:onPortraitPanel(sender, eventType)
    local data  = sender:getParent().data
    if data then
        local char = {}
        char.gid = data.gid
        char.name = data.name
        char.level = data.level
        char.icon = data.icon
        char.isOnline = 2
        
        self:showCharMenu(sender, data)
    end
end

function HomePlantHelpDlg:onCheckBox(sender, eventType)
    if sender:getName() == "FriendDlgCheckBox" then
        self:setCtrlVisible("FriendListPanel", true)
        self:setCtrlVisible("RecordListPanel", false)
    else
        self:setCtrlVisible("FriendListPanel", false)
        self:setCtrlVisible("RecordListPanel", true)
        
        if self.recordsInfo then
            self:setList(self.recordsInfo, self.recordPanel, self.setOneRecordPanel, "RecordListPanel", 30)
            self.recordsInfo = nil
        end
    end
end

function HomePlantHelpDlg:setOneFriendPanel(data, cell)
    local friend = FriendMgr:getFriendByGid(data.gid)
    if not friend then
        return
    end
    
    self:setImage("GuardImage", ResMgr:getSmallPortrait(friend:queryBasicInt("icon")), cell)
    
    local panel = self:getControl("PortraitPanel", nil, cell)
    self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT, friend:queryBasicInt("level") or 1, false, LOCATE_POSITION.LEFT_TOP, 21, cell)
    
    self:setLabelText("NameLabel", friend:queryBasic("char"), cell)
    
    -- 协助次数
    self:setHelpNum(data, cell)
    
    if data.has_feitan == 1 then
        self:setCtrlVisible("FurnitureImage", true, cell)
        self:setCtrlVisible("NoneFurnitureLabel", false, cell)
    else
        self:setCtrlVisible("FurnitureImage", false, cell)
        self:setCtrlVisible("NoneFurnitureLabel", true, cell)
    end
    
    cell.data = {
        gid = data.gid,
        name = friend:queryBasic("char"),
        level = friend:queryBasic("level"),
        icon = friend:queryBasic("icon"),
    }
end

function HomePlantHelpDlg:setHelpNum(data, cell)
    local showCou = 1
    -- 浇水
    local panel = self:getControl("EffectPanel" .. showCou, nil, cell)
    if data.water_num > 0 then
        self:setLabelText("NumLabel", "x" .. data.water_num, panel)
        self:setImage("EffectImage", ResMgr.ui.plant_water, panel)
        showCou = showCou + 1
    end

    -- 除草
    local panel = self:getControl("EffectPanel" .. showCou, nil, cell)
    if data.rederel_num > 0 then
        self:setLabelText("NumLabel", "x" .. data.rederel_num, panel)
        self:setImage("EffectImage", ResMgr.ui.plant_weeding, panel)
        showCou = showCou + 1
    end

    -- 除虫
    local panel = self:getControl("EffectPanel" .. showCou, nil, cell)
    if data.insect_num > 0 then
        self:setLabelText("NumLabel", "x" .. data.insect_num, panel)
        self:setImage("EffectImage", ResMgr.ui.plant_kill_insect, panel)
        showCou = showCou + 1
    end
    
    for i = showCou, 3 do
        local panel = self:getControl("EffectPanel" .. i, nil, cell)
        panel:setVisible(false)
    end
end

function HomePlantHelpDlg:setOneRecordPanel(data, cell)
    self:setImage("GuardImage", ResMgr:getSmallPortrait(data.icon), cell)

    local panel = self:getControl("PortraitPanel", nil, cell)
    self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT, data.level or 1, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    self:setLabelText("NameLabel", data.name, cell)
    
    -- 协助次数
    self:setHelpNum(data, cell)

    -- 最近协助时间
    local ctime = gf:getServerTime() - data.time
    local min = math.ceil(ctime / 60)
    if min < 60 then
        if min == 0 then min = 1 end
        self:setLabelText("TimeLabel", string.format(CHS[6000088], min), cell)
    else
        local hours = math.floor(ctime / 3600)
        if hours < 24 then
            if hours == 0 then hours = 1 end
            self:setLabelText("TimeLabel", string.format(CHS[6000087], hours), cell)
        else
            local days = math.floor(ctime / (24 * 3600))
            if days == 0 then days = 1 end
            self:setLabelText("TimeLabel", string.format(CHS[6000086], days), cell)
        end
    end
    
    -- 本月累计协助次数
    if data.total > 999 then
        self:setLabelText("TotalNumLabel", 999 .. CHS[5400201], cell)
    else
        self:setLabelText("TotalNumLabel", data.total .. CHS[5400201], cell)
    end
    
    cell.data = data
end

-- 创建好友列表
function HomePlantHelpDlg:setList(data, cloneCell, cellback, panel, oneLoadNum)
    if #data <= 0 then
        self:setCtrlVisible("MainListView", false, panel)
        self:setCtrlVisible("NoticePanel", true, panel)
        return
    else
        self:setCtrlVisible("MainListView", true, panel)
        self:setCtrlVisible("NoticePanel", false, panel)
    end
    
    local list = self:getControl("MainListView", nil, panel)
    list:removeAllItems()
    list:setInnerContainerSize(cc.size(0, 0))
    self:stopSchedule(panel)

    local curNum = 1
    local cou = #data
    local function func()
        for i = curNum, curNum + oneLoadNum - 1 do
            if i > cou then
                self:stopSchedule(panel)
                return
            end
            
            if data[i].name or FriendMgr:getFriendByGid(data[i].gid) then
                -- 有名字的数据是历史数据，不用判断是否有该好友
                local cell = cloneCell:clone()
                cellback(self, data[i], cell)
                list:pushBackCustomItem(cell)
            end
        end

        curNum = curNum + oneLoadNum
    end

    self.friendSch[panel] = self:startSchedule(func, 0.4)

    func()
    oneLoadNum = 3
end

function HomePlantHelpDlg:stopSchedule(key)
    if self.friendSch[key] then
        Dialog.stopSchedule(self, self.friendSch[key])
        self.friendSch[key] = nil
    end
end

function HomePlantHelpDlg:onComeToButton(sender, eventType)
    local data = sender:getParent().data
    if data then
        gf:CmdToServer("CMD_HOUSE_FARM_GOTO_HELP", {friend_name = data.name})
        DlgMgr:closeDlg("HomePlantCheckDlg")
    end
end

function HomePlantHelpDlg:MSG_HOUSE_FARM_HELP_TARGETS(data)
    self:setList(data, self.friendPanel, self.setOneFriendPanel, "FriendListPanel", 10)
    
    if data.count == 0 and self.isRedDotRemoved then
        gf:ShowSmallTips(CHS[5400590])
    end

    self.isRedDotRemoved = nil
end

function HomePlantHelpDlg:MSG_HOUSE_FARM_HELP_RECORDS(data)
    self.recordsInfo = data
    if self.radioGroup:getSelectedRadioName() == "HelpDlgCheckBox" then 
        self:setList(self.recordsInfo, self.recordPanel, self.setOneRecordPanel, "RecordListPanel", 30)
        self.recordsInfo = nil
    end
end

function HomePlantHelpDlg:onCheckAddRedDot(ctrlName)
    if self.radioGroup:getSelectedRadioName() == ctrlName then
        return false
    end
    
    return true
end

return HomePlantHelpDlg
