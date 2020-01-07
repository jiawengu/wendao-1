-- LonghzbTeamInfoDlg.lua
-- Created by songcw Nov/28/2016
-- 龙争虎斗队伍信息界面

local LonghzbTeamInfoDlg = Singleton("LonghzbTeamInfoDlg", Dialog)

function LonghzbTeamInfoDlg:init()
    self:hookMsg("MSG_LH_GUESS_PLANS")
end

function LonghzbTeamInfoDlg:setData(data)

    -- 队伍名
    self:setLabelText("NameLabel", data.teamName, "NamePanel")
    
    for i = 1, 5 do
        local panel = self:getControl("UserPanel_" .. i)
            
        if data.teamInfo[i] then
            panel:setVisible(true)
            self:setImage("Image", ResMgr:getSmallPortrait(data.teamInfo[i].icon), panel)
            self:setItemImageSize("Image", panel)
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.teamInfo[i].level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            self:setLabelText("NameLabel", gf:getRealName(data.teamInfo[i].name), panel)
        else
            panel:setVisible(false)
        end
    
        panel:requestDoLayout()        
    end
end

function LonghzbTeamInfoDlg:MSG_LH_GUESS_TEAM_INFO(data)
    self:setData(data)
end

return LonghzbTeamInfoDlg
