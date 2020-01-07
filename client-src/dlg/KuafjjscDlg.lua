-- KuafjjscDlg.lua
-- Created by huangzz Jan/02/2018
-- 跨服竞技赛区分配界面

local KuafjjscDlg = Singleton("KuafjjscDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local ZONES = {'A', 'B', 'C', 'D', 'E', 'F', 'G'}

function KuafjjscDlg:init()
    self:bindListener("OneRowDistPanel", self.onOneRowDistPanel)
    self.zoneCheckBox = self:retainCtrl("ZoneCheckBox_A")
    self.oneDistPanel = self:retainCtrl("OneRowDistPanel")
    self.chosenImage = self:retainCtrl("ChosenEffectImage", self.oneDistPanel)
    
    self.distCtrls = {}
    
    self.zoneData = {}
    
    self:initZoneCheckBoxs()
    
    -- 滚动加载
    self:bindListViewByPageLoad("DistListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            self:setDistListView()
        end
    end, "DistListPanel")
    
    self:hookMsg("MSG_CSC_SEASON_DATA")
end

function KuafjjscDlg:onOneRowDistPanel(sender)
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

-- 创建赛区标签列表
function KuafjjscDlg:initZoneCheckBoxs()
    local listView = self:getControl("ZoneListView")
    local cou = KuafjjMgr:getZoneCount()
    if not cou then
        return
    end
    
    local ctrl = {}
    for i = 1, cou do
        local cell = self.zoneCheckBox:clone()
        cell:setTag(i)
        cell:setName(ZONES[i])
        self:setLabelText("Label", CHS[5400027] .. " " .. ZONES[i], cell)
        listView:pushBackCustomItem(cell)

        table.insert(ctrl, ZONES[i])
    end
    
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, ctrl, self.onZoneCheckBox)
    self.radioGroup:selectRadio(1)
end


function KuafjjscDlg:onZoneCheckBox(sender, eventType)
    self.selectZone = sender:getTag()

    self:MSG_CSC_SEASON_DATA()
end

function KuafjjscDlg:setOneDistPanel(data, i, cell)
    self:setCtrlVisible("BackImage_2", i % 2 == 0, cell)

    self:setLabelText("IndexLabel", i, cell)
    self:setLabelText("DistLabel", data.dist_name or "", cell)
    self:setLabelText("TimeLabel", data.start_time and gf:getServerDate(CHS[4300233], data.start_time) or "", cell)
end

function KuafjjscDlg:getDistCell(num)
    if self.distCtrls[num] then
        return self.distCtrls[num]
    else
        local cell = self.oneDistPanel:clone()
        cell:retain()
        cell:setTag(num)
        self.distCtrls[num] = cell
        return cell
    end
end

function KuafjjscDlg:setDistListView(isReset)
    if not self.zoneData[self.selectZone] then
        return
    end
    
    local data = self.zoneData[self.selectZone]
    if data.dist_count == 0 then
        self:setCtrlVisible("DistListView", false)
        self:setCtrlVisible("NoticePanel", true)
        return
    else
        self:setCtrlVisible("DistListView", true)
        self:setCtrlVisible("NoticePanel", false)
    end
    
    local listView
    if isReset then
        listView = self:resetListView("DistListView")
        self.chosenImage:removeFromParent()
        self.loadNum = 1
    else
        listView = self:getControl("DistListView")
    end
    
    local loadNum = self.loadNum
    if loadNum > #data then
        return
    end
    
    for i = 1, 10 do
        if data[loadNum] then
            local cell = self:getDistCell(loadNum)
            self:setOneDistPanel(data[loadNum], loadNum, cell)
            listView:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    listView:doLayout()
    listView:refreshView()
    self.loadNum = loadNum
end

function KuafjjscDlg:setMyDistView(data)
    local panel = self:getControl("IndexPanel", nil, "MyselfPanel")
    self:setLabelText("Label", data.index or "", panel)
    panel = self:getControl("DistPanel", nil, "MyselfPanel")
    self:setLabelText("Label", data.dist_name or "", panel)
    panel = self:getControl("TimePanel", nil, "MyselfPanel")
    self:setLabelText("Label", data.start_time and gf:getServerDate(CHS[4300233], data.start_time) or "", panel)
end

function KuafjjscDlg:MSG_CSC_SEASON_DATA()
    local data  = KuafjjMgr:getSeasonData()
    if not data and data[self.selectZone] then
        return
    end
    
    self.zoneData = data
    self:setDistListView(true)
    
    local myData = KuafjjMgr:getMyDistData()
    if myData then
        if myData.zone ~= self.selectZone then
            self:setMyDistView({})
            self:setLabelText("NoteLabel", string.format(CHS[5400345], ZONES[myData.zone]), "MyselfPanel")
        else
            self:setMyDistView(myData)
            self:setLabelText("NoteLabel", "", "MyselfPanel")
        end
    else
        self:setMyDistView({})
        self:setLabelText("NoteLabel", CHS[5400344], "MyselfPanel")
    end

    local month = tonumber(gf:getServerDate("%m", data.season_start_time))
    self:setLabelText("MonthLabel", string.format(CHS[5420351], month, month % 12 + 1))
end

function KuafjjscDlg:cleanup()
    if self.distCtrls then
        for _, v in pairs(self.distCtrls) do
            v:release()
        end
    end
    
    self.distCtrls = nil
    self.zoneData = nil
end

return KuafjjscDlg
