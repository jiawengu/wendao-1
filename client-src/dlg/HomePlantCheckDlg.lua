-- HomePlantCheckDlg.lua
-- Created by huangzz Aug/30/2017
-- 居所外查看种植界面


local HomePlantCheckDlg = Singleton("HomePlantCheckDlg", Dialog)

function HomePlantCheckDlg:init()
    self:bindListener("HelpButton", self.onHelpButton)
    self:bindListener("ComeBackButton", self.onComeBackButton)  -- 前往后院
    self.infoPanel = self:retainCtrl("InfoPanel_2")
    self.plantPanel = self:retainCtrl("PlantPanel")
    
    self.cells = {}
    
    self:setPlantView()

    self:startSchedule(function ()
        local curTime = gf:getServerTime()
        for _, cell in ipairs(self.cells) do
            local harTime = cell.harTime
            local startTime = cell.startTime
            if harTime and startTime and not cell.finish then
                local time = gf:getServerTime() - startTime
                if harTime <= time then
                    self:setLabelText("EffectLabel", CHS[5400146], cell, COLOR3.TEXT_DEFAULT)
                    self:setLabelText("EffectLabel_1", CHS[5400147], cell)
                    self:setImage("EffectImage", ResMgr.ui.smiling_face, cell)
                    cell.finish = true
                    return
                end
            
                self:setTime(harTime - time, cell)
            end
        end
    end, 1)
    
    gf:CmdToServer("CMD_HOUSE_REQUEST_FARM_INFO", {})
    self:hookMsg("MSG_HOUSE_REQUEST_FARM_INFO")
end

function HomePlantCheckDlg:onHelpButton(sender, eventType, data, isRedDotRemoved)
    DlgMgr:openDlgEx("HomePlantHelpDlg", isRedDotRemoved)
end

function HomePlantCheckDlg:onComeBackButton(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5420211]))
    self:onCloseButton()
end

function HomePlantCheckDlg:setPlantView()
    local listView = self:resetListView("MainListView", 5)
    local info = HomeMgr.farmInfoForCheck

    if not info then
        return
    end
    
    self.cells = {}
    self.itemCou = 0

    for i = 1, info.farm_num do
        local cell = self:getItem(listView)
        if info[i] then
            self:setOnePanel(info[i], cell)
            table.insert(self.cells, cell)
        else
            self:setNotPlantPanel(cell)
        end
    end
end

function HomePlantCheckDlg:getItem(listView)
    local cell
    if self.itemCou == 0 then
        cell = self.plantPanel
    else
        cell = self.infoPanel:clone()
    end
    
    cell.finish = false
    listView:pushBackCustomItem(cell)
    self.itemCou = self.itemCou + 1
    return cell
end

function HomePlantCheckDlg:setTime(time, cell)
    if time < 0 then
        self:setLabelText("EffectLabel", CHS[5400146], cell, COLOR3.TEXT_DEFAULT)
        self:setLabelText("EffectLabel_1", CHS[5400147], cell)
        self:setImage("EffectImage", ResMgr.ui.smiling_face, cell)
        return
    end
    
    local s = time % 60
    local m = math.floor(time / 60) % 60
    local h = math.floor(time / 3600) 
    if h == 0 and m > 0 then
        self:setLabelText("EffectLabel_1", string.format(CHS[4000294], m, s), cell)
    elseif h == 0 and m == 0 then
        self:setLabelText("EffectLabel_1", string.format(CHS[4200423], s), cell)
    else
        self:setLabelText("EffectLabel_1", string.format(CHS[5400141], h, m, s), cell)
    end
end

function HomePlantCheckDlg:setNotPlantPanel(cell)
    self:setCtrlVisible("NonePanel", false, cell)
    self:setImage("GuardImage", ResMgr.ui.cultivated_farmland_96, cell)
    self:setLabelText("EffectLabel", CHS[5420213], cell, COLOR3.TEXT_DEFAULT)
    self:setLabelText("EffectLabel_1", CHS[7002255], cell)
end

-- 农作物悬浮框
function HomePlantCheckDlg:onShowCrop(sender)
    local info = sender.info
    if info then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(info.harvest_name, rect)
    end
end

function HomePlantCheckDlg:setOnePanel(data, cell)
    self:setCtrlVisible("NonePanel", false, cell)

    local panel = self:getControl("EffectPanel", nil, cell)
    
    local time = gf:getServerTime() - data.start_time
    local info = HomeMgr:getFurnitureInfoById(data.class_id)
    if info then
        local itemInfo = InventoryMgr:getItemInfoByName(info.harvest_name)
        local harTime = info.harvest_time * 3600
        cell.startTime = data.start_time
        cell.harTime = harTime
        self:setTime(harTime - time, cell)

        if itemInfo then
            self:setImage("GuardImage", ResMgr:getItemIconPath(itemInfo.icon), cell)
        end
    end
    
    local shapePanel = self:getControl("ShapePanel", nil, cell)
    shapePanel.info = info
    shapePanel:setTouchEnabled(true)
    self:bindTouchEndEventListener(shapePanel, self.onShowCrop)
    
    if data.status == HOME_CROP_STAUES.STATUS_HEALTH then
        self:setLabelText("EffectLabel", CHS[5400145], cell, COLOR3.GREEN)
        
        self:setImage("EffectImage", ResMgr.ui.smiling_face, panel)
    elseif data.status == HOME_CROP_STAUES.STATUS_HAS_REDERAL then
        self:setLabelText("EffectLabel", CHS[5400143], cell, COLOR3.RED)

        self:setImage("EffectImage", ResMgr.ui.crying_face, panel)
    elseif data.status == HOME_CROP_STAUES.STATUS_HAS_INSECT then
        self:setLabelText("EffectLabel", CHS[5400144], cell, COLOR3.RED)

        self:setImage("EffectImage", ResMgr.ui.crying_face, panel)
    elseif data.status == HOME_CROP_STAUES.STATUS_THIRST then
        self:setLabelText("EffectLabel", CHS[5400142], cell, COLOR3.RED)

        self:setImage("EffectImage", ResMgr.ui.crying_face, panel)
    elseif data.status == HOME_CROP_STAUES.STATUS_FINISH then
        self:setLabelText("EffectLabel", CHS[5400146], cell, COLOR3.TEXT_DEFAULT)
        self:setLabelText("EffectLabel_1", CHS[5400147], cell)
        
        self:setImage("EffectImage", ResMgr.ui.smiling_face, panel)
    end
end


function HomePlantCheckDlg:MSG_HOUSE_REQUEST_FARM_INFO(data)
    self:setPlantView()
end

function HomePlantCheckDlg:cleanup()
    DlgMgr:closeDlg("HomePlantHelpDlg")
end

return HomePlantCheckDlg
