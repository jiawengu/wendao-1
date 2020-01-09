-- LonghzbInfoDlg.lua
-- Created by songcw Dec/9/2016
-- 龙争虎斗界面信息

local LonghzbInfoDlg = Singleton("LonghzbInfoDlg", Dialog)
local margin_precent = 4.4

function LonghzbInfoDlg:init()
    self:bindListener("ShidaoButton", self.onShidaoButton)

    self.schedule = nil
    self.left_ti = nil
    self.data = nil

    self:setFullScreen()
    self.root:setPositionY(self.root:getPositionY() - self:getWinSize().height  * margin_precent / 100)
end

function LonghzbInfoDlg:setData(data)
    self.data = data

    self:setLabelText("MyTeamLeaderLabel", data.my_team_name)

    self:setLabelText("OppTeamLeaderLabel", data.opp_team_name)

    if data.my_camp_type == LongZHDMgr.CAMP.QL then
        self:setLabelText("LeftLabel", CHS[4300191])
        self:setLabelText("RightLabel", CHS[4300192])
    else
        self:setLabelText("LeftLabel", CHS[4300192])
        self:setLabelText("RightLabel", CHS[4300191])
    end

    self:setWarState(data)

    self:setWarRet(data)

    self:setHourglass()
end

-- 设置战斗结果
function LonghzbInfoDlg:setWarRet(data)
    local isWinner = {}

    local myRetPanel = self:getControl("MyResultPanel")
    local oppRetPanel = self:getControl("OppResultPanel")

    myRetPanel:setVisible(true)
    oppRetPanel:setVisible(true)

    for i = 1, 3 do
        local ret = 0       -- 0,无结果                     1，我赢               2，我输            3 平
        if data["combat_result_" .. i] == LongZHDMgr.WAR_RET.NONE then
            ret = 0
        elseif data["combat_result_" .. i] == LongZHDMgr.WAR_RET.DRAW then
            ret = 3
        else
            ret = 2 --  默认我输
            -- 如果我属青龙，青龙赢则我赢
            if data["combat_result_" .. i] == LongZHDMgr.WAR_RET.QL_WIN and data.my_camp_type == LongZHDMgr.CAMP.QL then
                ret = 1
            end
            -- 如果我属白虎，白虎赢则我赢
            if data["combat_result_" .. i] == LongZHDMgr.WAR_RET.BH_WIN and data.my_camp_type == LongZHDMgr.CAMP.BH then
                ret = 1
            end
        end
        self:setCtrlVisible("Image_" .. i, true, myRetPanel)
        self:setCtrlVisible("Image_" .. i, true, oppRetPanel)

        if ret == 0 then
            self:setCtrlVisible("Image_" .. i, false, myRetPanel)
            self:setCtrlVisible("Image_" .. i, false, oppRetPanel)
        elseif ret == 1 then
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_win, myRetPanel)
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_lose, oppRetPanel)
        elseif ret == 2 then
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_lose, myRetPanel)
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_win, oppRetPanel)
        elseif ret == 3 then
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_draw, myRetPanel)
            self:setImagePlist("Image_" .. i, ResMgr.ui.party_war_draw, oppRetPanel)
        end
    end


end

-- 定时器
function LonghzbInfoDlg:setHourglass()
    if not self.left_ti then
        self:setCtrlVisible("LeftTimePanel", false)
        return
    end

    self:setCtrlVisible("LeftTimePanel", true)
    self:setTimeInfo()
    if not self.schedule then
        self.schedule = schedule(self.root, function()
            self.left_ti = self.left_ti - 1
            if self.left_ti <= 0 then
                self.left_ti = 0
                self:setWarState(self.data)
            end
            self:setTimeInfo()
        end, 1)
    end
end

function LonghzbInfoDlg:setTimeInfo()
    if not self.left_ti then return end

    self:setLabelText("LeftTimeLabel_1", string.format("%02d", math.floor(self.left_ti / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(self.left_ti)))
    self:setLabelText("LeftTimeLabel_2", string.format("%02d", math.floor(self.left_ti / 60 / 60)) .. gf:getServerDate(":%M:%S", tonumber(self.left_ti)))

    self:updateLayout("LeftTimePanel")
end

-- 设置战斗状态 1 入场准备                2 积分                3 决赛
function LonghzbInfoDlg:setWarState(data)
    local state
    if gf:getServerTime() < data.start_time then
        -- 准备
        state = 1
        self.left_ti = math.max(0, data.start_time - gf:getServerTime())
    else
        self.left_ti = math.max(0, data.end_time - gf:getServerTime())
        if data.war_type == LongZHDMgr.RACE_INDEX.FINAL then
            -- 决赛
            state = 3
        else
            -- 积分
            state = 2
        end
    end

    for i = 3, 5 do
        self:setCtrlVisible("TitleImage_" .. i, false)
    end

    self:setCtrlVisible("TitleImage_" .. (2 + state), true)
end

function LonghzbInfoDlg:onShidaoButton(sender, eventType)
    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("ShidaoButton", false)
end

function LonghzbInfoDlg:onCloseButton(sender, eventType)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("ShidaoButton", true)
end

return LonghzbInfoDlg
