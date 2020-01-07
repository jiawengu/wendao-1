-- ActivitiesSeeDlg.lua
-- Created by songcw Sep/15/2015
-- 活动查看悬浮框

local ActivitiesSeeDlg = Singleton("ActivitiesSeeDlg", Dialog)

local STARS_36_ACTIVE = 1  -- 36天罡星
local STARS_72_ACTIVE = 2  -- 72地煞星

function ActivitiesSeeDlg:init()
    
    self.cell = self:getControl("MonsterUnitPanel")
    self.cell:retain()
    self.cell:removeFromParent()

    self.list = self:getControl("MonsterListView")
end

function ActivitiesSeeDlg:cleanup()
    self:releaseCloneCtrl("cell")
end

function ActivitiesSeeDlg:setActiveInfo(actType)
    local actInfo = ActivityMgr:getStarsActivityInfo(actType)
    self.list:removeAllChildren()
	for i = 1, #actInfo do
	   local panel = self.cell:clone()
        self:initCell(actInfo[i], panel)
	   if nil ~= self.list then
           self.list:pushBackCustomItem(panel)
       end
	end
end

function ActivitiesSeeDlg:initCell(data, cell)
    self:setLabelText("NameLabel", data.name, cell)
    self:setLabelText("LevelLabel", data.level, cell)
    local mapList = gf:split(data.place, CHS[3002241])
    
    for i = 1, #mapList do
        self:setLabelText("MapLabel"..i, mapList[i], cell)
    end
    
    -- 设置形象
    self:setPortrait("PortraitPanel1", data.icon, 0, cell, true, nil, nil, cc.p(0, -36))
end

function ActivitiesSeeDlg:setActiveSingel(info, panel)
    self:setLabelText("NameLabel2", info.name, panel)
    self:setLabelText("LevelLabel2", info.level, panel)
    self:setLabelText("MapLabel2", info.place, panel)
end

return ActivitiesSeeDlg
