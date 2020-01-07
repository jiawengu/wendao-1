-- JiuTianBuffDlg.lua
-- Created by sujl, Jun/10/2019
-- 九天真君

local JiuTianBuffDlg = Singleton("JiuTianBuffDlg", Dialog)

function JiuTianBuffDlg:init()
    self:setFullScreen()
end

function JiuTianBuffDlg:refreshData(obj)
    if not obj then return end

    local flag = obj:queryBasicInt("youtj_effect_flag")
    local sunPoint = obj:queryInt("youtj_sun_point")
    local moonPoint = obj:queryInt("youtj_moon_point")

    local id = obj:getId()
    if FightMgr.glossObjsInfo[id] and FightMgr.glossObjsInfo[id].isSet == 1 then
        flag = FightMgr.glossObjsInfo[id].flag or flag
        sunPoint = FightMgr.glossObjsInfo[id].sunPoint or sunPoint
        moonPoint = FightMgr.glossObjsInfo[id].moonPoint or moonPoint
    end

    -- 状态
    if 1 == flag then
        self:setImage("BuffImage", ResMgr.ui.jt_sun)
    elseif 2 == flag then
        self:setImage("BuffImage", ResMgr.ui.jt_moon)
    else
        self:setImage("BuffImage", ResMgr.ui.jt_mixed)
    end

    -- 月涌
    self:setLabelText("MoonLabel_1", moonPoint)
    self:setLabelText("MoonLabel_2", moonPoint)
    local moonProgress = self:getControl("MoonProgressBar")
    moonProgress:setPercent(math.min(100, moonPoint * 100 / 10))

    -- 日升
    self:setLabelText("SunLabel_1", sunPoint)
    self:setLabelText("SunLabel_2", sunPoint)
    local sunProgress = self:getControl("SunProgressBar")
    sunProgress:setPercent(math.min(100, sunPoint * 100 / 10))
end

return JiuTianBuffDlg