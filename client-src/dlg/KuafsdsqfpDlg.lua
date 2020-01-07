-- KuafsdsqfpDlg.lua
-- Created by huangzz July/17/2017
-- 跨服试道赛区分配界面

local KuafsdsqfpDlg = Singleton("KuafsdsqfpDlg", Dialog)

local COMPETITION_AREA = {'A', 'B', 'C', 'D'} -- 赛区
local LEVEL_RANGE = {   -- 等级段
    [1] = {60, 79},
    [2] = {80, 89},
    [3] = {90, 99},
    [4] = {100, 109},
    [5] = {110, 119},
    [6] = {120, 129},
}

function KuafsdsqfpDlg:init()
    for i = 1, #LEVEL_RANGE do
        self:bindListener("LevelTypePanel_" .. i, self.onSelectLevel)
    end
    
    
    for i = 1, 4 do
        self:bindListener("ZoneCheckBox_" .. COMPETITION_AREA[i], self.onSelectZone)
    end

    self:bindListener("OneRowDistPanel", self.onSelectOnePanel)  
    
    self.oneDistPanel = self:getControl("OneRowDistPanel")
    self.oneDistPanel:retain()
    self.oneDistPanel:removeFromParent() 
    
    local label = self:getControl("TimeLabel", nil, self.oneDistPanel)
    label:setLocalZOrder(1)
     
    self.chosenImage = self:getControl("ChosenEffectImage", nil, self.oneDistPanel)
    self.chosenImage:retain()
    self.chosenImage:removeFromParent()  
    self.chosenImage:setVisible(false)
    
    self.distPanels = {}
    self.myDistInfo = {}
    self.allRandInfo = {}
    self.kuafsdMenuInfo = {}
    self.kuafsdRandInfo = {}
    
    
    self:hookMsg("MSG_CS_SHIDAO_ZONE_PLAN")
    self:hookMsg("MSG_CS_SHIDAO_ZONE_INFO")
end
function KuafsdsqfpDlg:onSelectLevel(sender, eventType)
    local ctrlName = sender:getName()
    local ctrlName, tag = string.match(ctrlName, "(LevelTypePanel_)(%d+)")
    tag = tonumber(tag)
    if self.curSelectLevel == tag then
        return
    end
    
    self:onSelectOption(ctrlName, tag)
end

function KuafsdsqfpDlg:onSelectZone(sender, eventType)
    local ctrlName = sender:getName()
    local ctrlPartName, tag = string.match(ctrlName, "(ZoneCheckBox_)(%a+)")
    
    if tag == self.curSelectArea then
        self:setCheck(ctrlPartName ..  tag, true)
        return
    end
    
    self:onSelectOption(ctrlPartName, tag)
end

function KuafsdsqfpDlg:onSelectOnePanel(sender, eventType)
    -- 单个区组选中效果
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
    self.chosenImage:setVisible(true)
end

function KuafsdsqfpDlg:initOption(ctrlName, data, checkInfo)
    local cou = #data
    local tag = 0
    for i = 1, cou do
        local cell
        if ctrlName == "LevelTypePanel_" then
            cell = self:getControl(ctrlName .. i)
        else
            cell = self:getControl(ctrlName .. COMPETITION_AREA[i])
        end
        
        if (ctrlName == "LevelTypePanel_" and checkInfo[LEVEL_RANGE[i][1] .. "-" .. LEVEL_RANGE[i][2]])
            or (ctrlName == "ZoneCheckBox_" and checkInfo[COMPETITION_AREA[i]]) then
            cell:setTouchEnabled(true)
            
            if ctrlName == "LevelTypePanel_" then
                self:setCtrlVisible("ChosenImage", false, cell)
                gf:resetImageView(self:getControl("ChosenImage", nil, cell))
            else
                self:setCheck(ctrlName ..  COMPETITION_AREA[i], false)
                gf:resetImageView(cell)
            end

            -- 等级段默认选择最大的（有数据的）
            if ctrlName == "LevelTypePanel_" then
                tag = i
            end

            -- 赛区默认选编号最低的（有数据的）
            if ctrlName == "ZoneCheckBox_" and tag == 0 then
                tag = COMPETITION_AREA[i]
            end
        else
            -- 未开启的赛区或等级段选项置灰
            cell:setTouchEnabled(false)
            if ctrlName == "LevelTypePanel_" then
                self:setCtrlVisible("ChosenImage", true, cell)
                gf:grayImageView(self:getControl("ChosenImage", nil, cell))
            else
                self:setCheck(ctrlName ..  COMPETITION_AREA[i], false)
                gf:grayImageView(cell)
            end
           
        end
    end
    

    if tag then
        KuafsdsqfpDlg:onSelectOption(ctrlName, tag)
    end
end

function KuafsdsqfpDlg:onSelectOption(ctrlName, tag)
    if not next(self.kuafsdMenuInfo) then
        return
    end
    
    if ctrlName == "LevelTypePanel_" then
        if self.curSelectLevel then
            self:setCtrlVisible("ChosenImage", false, ctrlName .. self.curSelectLevel)
        end

        self:setCtrlVisible("ChosenImage", true, ctrlName .. tag)
        self.curSelectLevel = tag

        -- 重选等级段后，要刷新赛区显示（未开启的置灰）
        self.curSelectArea = nil
        local levelRange = LEVEL_RANGE[tag][1] .. "-" .. LEVEL_RANGE[tag][2]
        KuafsdsqfpDlg:initOption("ZoneCheckBox_", COMPETITION_AREA, self.kuafsdMenuInfo[levelRange])
    else
        if self.curSelectArea then
            self:setCheck(ctrlName .. self.curSelectArea, false)
        end
        
        self:setCheck(ctrlName ..  tag, true)
        self.curSelectArea = tag
        
        local levelRange = LEVEL_RANGE[self.curSelectLevel][1] .. "-" .. LEVEL_RANGE[self.curSelectLevel][2]
        if not self.allRandInfo[levelRange] 
                or not self.allRandInfo[levelRange][tag] then
            -- 未接收过当前等级段及赛区数据
            gf:CmdToServer("CMD_CS_SHIDAO_ZONE_INFO", {
                level_index = levelRange,
                zone = self.curSelectArea
            })
        else
            self:MSG_CS_SHIDAO_ZONE_INFO(self.allRandInfo[levelRange][tag])
        end
    end
end

function KuafsdsqfpDlg:stopSchedule()
    if self.schedulId then
        gf:Unschedule(self.schedulId)
        self.schedulId = nil
    end
end

function KuafsdsqfpDlg:setDistView(cell, data, tag)
    if tag % 2 == 0 then
        self:setCtrlVisible("BackImage_2", true, cell)
    else
        self:setCtrlVisible("BackImage_2", false, cell)
    end
     
    self:setLabelText("IndexLabel", tag, cell)
    self:setLabelText("DistLabel", data.dist_name or "", cell)
    self:setLabelText("TimeLabel", data.start_time and gf:getServerDate(CHS[4300233], data.start_time) or "", cell)
end

function KuafsdsqfpDlg:setMyDistView(data, tag)
    local panel = self:getControl("IndexPanel", nil, "MyselfPanel")
    self:setLabelText("Label", tag, panel)
    panel = self:getControl("DistPanel", nil, "MyselfPanel")
    self:setLabelText("Label", data.dist_name or "", panel)
    panel = self:getControl("TimePanel", nil, "MyselfPanel")
    self:setLabelText("Label", data.start_time and gf:getServerDate(CHS[4300233], data.start_time) or "", panel)
end

function KuafsdsqfpDlg:MSG_CS_SHIDAO_ZONE_INFO(data)
    if not self.curSelectLevel 
        or not self.curSelectArea
        or not next(self.kuafsdMenuInfo) then
    	return
    end
    
    if not self.allRandInfo[data.level_index] then
        self.allRandInfo[data.level_index] = {}
    end
    
    self.allRandInfo[data.level_index][data.zone] = data
    self.kuafsdRandInfo = data
    
    if self.kuafsdMenuInfo[data.level_index] and self.kuafsdMenuInfo[data.level_index].cur_dist_zone == data.zone then
        self:setLabelText("NoteLabel", "", "MyselfPanel")
    elseif self.kuafsdMenuInfo[data.level_index] 
            and self.kuafsdMenuInfo[data.level_index].cur_dist_zone 
            and self.kuafsdMenuInfo[data.level_index].cur_dist_zone ~= "" then
        self:setLabelText("NoteLabel", string.format(CHS[5430010], data.level_index, self.kuafsdMenuInfo[data.level_index].cur_dist_zone), "MyselfPanel")
        self:setMyDistView({}, "")
    else
        self:setLabelText("NoteLabel", string.format(CHS[5430009], data.level_index, data.level_index), "MyselfPanel")
        self:setMyDistView({}, "")
    end
    
    local listView = self:resetListView("DistListView")
    self:stopSchedule()
    listView:removeAllItems()

    local loadcount = 0
    local count = #data
    local curGroup = -1
    
    -- item 优先取之前已创建的 好的条目，不够用时再调用 schedule 逐个创建条目
    for i, cell in ipairs(self.distPanels) do
        if loadcount >= count  then
            return
        end
        
        loadcount = loadcount + 1
        if self.myDistInfo.dist_name and data[loadcount].dist_name == self.myDistInfo.dist_name then
            -- 显示我的区组
            self:setMyDistView(data[loadcount], loadcount)
        end
        
        local cell = self.distPanels[i]
        self:setDistView(cell, data[loadcount], loadcount)
        listView:pushBackCustomItem(cell)
    end

    local function func()
        if loadcount >= count  then
            self:stopSchedule()
            return
        end

        loadcount = loadcount + 1
        if self.myDistInfo.dist_name and data[loadcount].dist_name == self.myDistInfo.dist_name then
            -- 显示我的区组
            self:setMyDistView(data[loadcount], loadcount)
        end
        
        local cell = self.oneDistPanel:clone()
        cell:retain()
        cell:setTag(loadcount)
        table.insert(self.distPanels, cell)
        self:setDistView(cell, data[loadcount], loadcount)
        listView:pushBackCustomItem(cell)
    end

    self.schedulId = gf:Schedule(func, 0.02)
end

function KuafsdsqfpDlg:MSG_CS_SHIDAO_ZONE_PLAN(data)
    self.myDistInfo.dist_name = data.my_dist_name
    
    -- 显示开战时间
    self:setLabelText("DateLabel", gf:getServerDate(CHS[4300031], data.match_day_zero_time), "TimePanel")
    self:setLabelText("TimeLabel", gf:getServerDate(CHS[5430005], data.match_day_zero_time), "TimePanel")
 
    self.kuafsdMenuInfo = data

    if data.count == 0 then
        return
    end

    -- 初始化菜单
    self:initOption("LevelTypePanel_", LEVEL_RANGE, data)
end


function KuafsdsqfpDlg:cleanup()
    self:releaseCloneCtrl("oneDistPanel")
    self:releaseCloneCtrl("chosenImage")
    
    for _, v in pairs(self.distPanels) do
        if v then
            v:release()
        end
    end
    
    self.distPanels = {}
    self.allRandInfo = {}
    self:stopSchedule()
end


return KuafsdsqfpDlg
