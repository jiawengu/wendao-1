-- CheekFarmDlg.lua
-- Created by huangzz Aug/11/2017
-- 农田查看界面

local CheekFarmDlg = Singleton("CheekFarmDlg", Dialog)

local HEALTH_STATUS_IMAGE = {
    [1] = ResMgr.ui.smiling_face,
    [2] = ResMgr.ui.crying_face
}

function CheekFarmDlg:init(tag)
    self:bindListener("DropButton", self.onDropButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("GainButton", self.onGainButton)
    
    local croplandInfo = HomeMgr.croplandInfo or {}
    self.growStatus = nil
    
    self.tag = tag
    if croplandInfo[tag] then
        self.data = croplandInfo[tag]
        self.info = HomeMgr:getFurnitureInfoById(self.data.class_id)
        if not self.info then
            return
        end
        
        self:setData(self.data)
        local startTime = self.data.start_time
        local harvest_time = self.info.harvest_time * 3600
        local function downTime()
            local time = gf:getServerTime() - startTime
            
            if harvest_time > time * 3 then
                if self.growStatus ~= 1 then
                    self:setGrowStatus(1)
                end
            elseif harvest_time <= time then
                self.root:stopAllActions()
                if self.growStatus ~= 3 then
                    self:setGrowStatus(3)
                end
                
                return
            elseif self.growStatus ~= 2 then
                self:setGrowStatus(2)
            end
            
            self:setTime(math.max(harvest_time - time, 0))
        end
        
        downTime()
        
        self:startSchedule(downTime, 1)
    else
        self:setNotCrop()
    end
    
    self:hookMsg("MSG_HOUSE_FARM_DATA")
end

function CheekFarmDlg:setGrowStatus(status)
    local bkImage = self:getControl("BKImage", nil, "ShowPanel")
    if status == 1 then
        self.growStatus = 1
        -- self:setLabelText("AttribLabel", CHS[5400138], "EffectPanel_2")
        
        self:showCropImage(bkImage, ResMgr:getFurniturePath(self.info.harvest_icon, 1))
    elseif status == 2 then
        self.growStatus = 2
        -- self:setLabelText("AttribLabel", CHS[5400139], "EffectPanel_2")

        self:showCropImage(bkImage, ResMgr:getFurniturePath(self.info.harvest_icon, 2))
    else
        self.growStatus = 3
        -- self:setLabelText("AttribLabel", CHS[5400140], "EffectPanel_2")
        self:setLabelText("AttribLabel", CHS[5400146], "EffectPanel_3", COLOR3.TEXT_DEFAULT)
        self:setLabelText("AttribLabel", CHS[5400147], "EffectPanel_4")
        self:setCtrlVisible("StartButton", false)
        self:setCtrlVisible("GainButton", true)
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[1], "EffectPanel_3")
        self:showCropImage(bkImage, ResMgr:getFurniturePath(self.info.harvest_icon, 3))
    end
end

function CheekFarmDlg:showCropImage(bkImage, imagePath)
    bkImage:removeAllChildren()
    local img = ccui.ImageView:create(imagePath)
    img:setPosition(126, 25)
    img:setAnchorPoint(0.5, 0)
    bkImage:addChild(img)
end

function CheekFarmDlg:setTime(time)
    local s = time % 60
    local m = math.floor(time / 60) % 60
    local h = math.floor(time / 3600) 
    if h == 0 and m > 0 then
        self:setLabelText("AttribLabel", string.format(CHS[4000294], m, s), "EffectPanel_4")
    elseif h == 0 and m == 0 then
        self:setLabelText("AttribLabel", string.format(CHS[4200423], s), "EffectPanel_4")
    else
        self:setLabelText("AttribLabel", string.format(CHS[5400141], h, m, s), "EffectPanel_4")
    end
end

function CheekFarmDlg:setData(data)
    self:setLabelText("AttribLabel", self.info.harvest_name, "EffectPanel_1")
    self:setLabelText("AttribLabel", data.name, "EffectPanel_2")
    
    if data.isMy == 1 then
        self:setCtrlEnabled("GainButton", true)
        self:setCtrlVisible("DropButton", true)
    else
        self:setCtrlEnabled("GainButton", false)
        self:setCtrlVisible("DropButton", false)
    end
    
    -- 状态
    self.status = data.status
    if data.status == HOME_CROP_STAUES.STATUS_HEALTH then
        self:setLabelText("AttribLabel", CHS[5400145], "EffectPanel_3", COLOR3.GREEN)
        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("GainButton", false)
        self:setCtrlEnabled("StartButton", false)
        
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[1], "EffectPanel_3")
    elseif data.status == HOME_CROP_STAUES.STATUS_HAS_REDERAL then
        self:setLabelText("AttribLabel", CHS[5400143], "EffectPanel_3", COLOR3.RED)
        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("GainButton", false)
        self:setCtrlEnabled("StartButton", true)
        
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[2], "EffectPanel_3")
    elseif data.status == HOME_CROP_STAUES.STATUS_HAS_INSECT then
        self:setLabelText("AttribLabel", CHS[5400144], "EffectPanel_3", COLOR3.RED)
        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("GainButton", false)
        self:setCtrlEnabled("StartButton", true)
        
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[2], "EffectPanel_3")
    elseif data.status == HOME_CROP_STAUES.STATUS_THIRST then
        self:setLabelText("AttribLabel", CHS[5400142], "EffectPanel_3", COLOR3.RED)
        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("GainButton", false)
        self:setCtrlEnabled("StartButton", true)
        
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[2], "EffectPanel_3")
    elseif data.status == HOME_CROP_STAUES.STATUS_FINISH then
        self:setLabelText("AttribLabel", CHS[5400146], "EffectPanel_3", COLOR3.TEXT_DEFAULT)
        self:setCtrlVisible("StartButton", false)
        self:setCtrlVisible("GainButton", true)
        
        self:setImage("TypeImage", HEALTH_STATUS_IMAGE[1], "EffectPanel_3")
    end
end

function CheekFarmDlg:setNotCrop()
    self:setLabelText("AttribLabel", "", "EffectPanel_1")
    self:setLabelText("AttribLabel", "", "EffectPanel_2")
    self:setLabelText("AttribLabel", "", "EffectPanel_3")
    self:setLabelText("AttribLabel", "", "EffectPanel_4")
    
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("GainButton", false)
    
    local bkImage = self:getControl("BKImage_1", nil, "ShowPanel")
    bkImage:removeAllChildren()
    self.root:stopAllActions()
end

-- 清除作物
function CheekFarmDlg:onDropButton(sender, eventType)
    -- 若玩家距离对应农田距离超过20格，则予以如下弹出提示：
    local mapInfo = MapMgr:getCurrentMapInfo()
    if mapInfo and mapInfo.croplands then
        local x, y = mapInfo.croplands[self.tag].x, mapInfo.croplands[self.tag].y
        if (x - Me.curX) * (x - Me.curX) + (y - Me.curY) * (y - Me.curY) > 480 * 480 then
            gf:ShowSmallTips(CHS[5400150])
            return
        end
    else
        gf:ShowSmallTips(CHS[5400150])
        return
    end

    -- 若当前作物已经成熟，则予以如下弹出提示：
    local startTime = self.data.start_time
    local time = gf:getServerTime() - startTime
    if self.info.harvest_time * 3600 <= time then
        gf:ShowSmallTips(CHS[5400149])
        return
    end

    -- 否则予以如下确认取消选项
    gf:confirm(CHS[5400148], function()
        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
            gf:ShowSmallTips(CHS[5410117])
            return
        end
        
        HomeMgr:requestFarmAction(4 ,self.tag)
    end)
end

-- 作物打理
function CheekFarmDlg:onStartButton(sender, eventType)
    HomeMgr:requestFarmAction(2 ,self.tag, self.status)
end

-- 作物收获
function CheekFarmDlg:onGainButton(sender, eventType)
    HomeMgr:requestFarmAction(3 ,self.tag)
end

function CheekFarmDlg:MSG_HOUSE_FARM_DATA()
    if not self.tag then
        return
    end
    
    local data = HomeMgr.croplandInfo[self.tag]
    if data and next(data) then 
        self:setData(data)
    else
        self:close()
    end
end

return CheekFarmDlg
