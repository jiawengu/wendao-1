-- StatisticsDlg.lua
-- Created by songcw June/27/2016
-- 今日统计界面

local StatisticsDlg = Singleton("StatisticsDlg", Dialog)

local ICONS = {
    [1] = {["icon"] = ResMgr.ui.small_exp, isPlist = 1},
    [2] = {["icon"] = ResMgr.ui.small_daohang, isPlist = 1},
    [3] = {["icon"] = ResMgr.ui.samll_pot, isPlist = 1},
    [4] = {["icon"] = ResMgr.ui.statistics_siwang, isPlist = 1},
    [5] = {["icon"] = ResMgr.ui.statistics_shizhong, isPlist = 1},
    [6] = {["icon"] = ResMgr.ui.statistics_shuadao},
    [7] = {["icon"] = ResMgr.ui.small_daohang, isPlist = 1},
}

function StatisticsDlg:init()
    for i = 1, #ICONS do
        local panel = self:getControl("StatisticsPanel" .. i)
        if ICONS[i].isPlist then
            self:setImagePlist("Image_175", ICONS[i]["icon"], panel)
        else
            self:setImage("Image_175", ICONS[i]["icon"], panel)
        end
    end

    self:bindListener("StatisticsPanel", self.onCloseButton)
end

function StatisticsDlg:setData(data)
    local destData = {}
    
    -- 经验处理
    local expStr = ""
    expStr = "+" .. data.exp
    table.insert(destData, expStr)

    -- 道行
    local taoStr = ""
    if data.tao == 0 and data.tao_point == 0 then
        taoStr = "+" .. 0
    else
        taoStr = "+" .. gf:getTaoStr(data.tao, data.tao_point)
    end
    table.insert(destData, taoStr)

    local potStr = "+" .. data.pot
    table.insert(destData, potStr)

    local deathStr = data.death .. CHS[3002314]
    table.insert(destData, deathStr)
    
    local onLineStr = ""
    local h = math.floor(data.onLine_time / 3600)
    local m = math.floor((data.onLine_time % 3600) / 60)
    if h == 0 then
        onLineStr = string.format(CHS[6000116], math.floor((data.onLine_time % 3600) / 60))    
    else
        onLineStr = string.format(CHS[4300027], math.floor(data.onLine_time / 3600), math.floor((data.onLine_time % 3600) / 60))  
    end  
    table.insert(destData, onLineStr)
    
    -- 刷道轮次
    local getTaoTimes = data.shuadaoTimes .. CHS[7150000]
    table.insert(destData, getTaoTimes)

    -- 本月道行
    local taoStr = ""
    if data.mon_tao == 0 and data.mon_tao_ex == 0 then
        taoStr = 0
    else
        taoStr = gf:getTaoStr(data.mon_tao or 0, data.mon_tao_ex or 0)
    end
    table.insert(destData, taoStr)

    for i = 1, 7 do
        local panel = self:getControl("StatisticsPanel" .. i)
        self:setLabelText("NumLabel", destData[i], panel)    	
    end

    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.org_icon))

    -- 名称
    self:setLabelText("NameLabel", data.name, "PlayerPanel")

    -- 等级
    self:setNumImgForPanel("PlayerPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level,
        false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 帮派
    if data.party_name == "" then
        self:setLabelText("PartyLabel", string.format(CHS[7100387], CHS[7100117]), "PlayerPanel")
    else
        self:setLabelText("PartyLabel", string.format(CHS[7100387], data.party_name), "PlayerPanel")
    end
end

return StatisticsDlg
