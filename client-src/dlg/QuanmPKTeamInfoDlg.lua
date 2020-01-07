-- QuanmPKTeamInfoDlg.lua
-- Created by yangym Apr/24/2017
-- 全民PK队伍信息界面

local QuanmPKTeamInfoDlg = Singleton("QuanmPKTeamInfoDlg", Dialog)

function QuanmPKTeamInfoDlg:init()
end

function QuanmPKTeamInfoDlg:setData(data)
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
            self:setLabelText("DistLabel", data.teamInfo[i].dist, panel)
        else
            panel:setVisible(false)
        end

        panel:requestDoLayout()
    end
end

return QuanmPKTeamInfoDlg
