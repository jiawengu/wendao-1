-- WatchCentreTeamDlg.lua
-- Created by songcw Feb/07/2017
-- 观战对阵队伍界面

local WatchCentreTeamDlg = Singleton("WatchCentreTeamDlg", Dialog)

function WatchCentreTeamDlg:init()
end

-- 设置界面数据
function WatchCentreTeamDlg:setData(data)
    -- 区组
    self:setLabelText("BlockLabel", data[1].dist)
   
    -- 队员信息
    for i = 1, 5 do
        if data[i] then    
            local shapePanel1 = self:getControl("ShapePanel" .. i)
            self:setImage("ShapeImage", ResMgr:getSmallPortrait(data[i].icon), shapePanel1)
            self:setNumImgForPanel(shapePanel1, ART_FONT_COLOR.NORMAL_TEXT, data[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)        
            self:setLabelText("PlayerNameLabel" .. i, gf:getRealName(data[i].name))
            self:setLabelText("PlayerPartyLabel" .. i, data[i].party)
        end
    end        
end


return WatchCentreTeamDlg
