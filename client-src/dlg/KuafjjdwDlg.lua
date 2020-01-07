-- KuafjjdwDlg.lua
-- Created by huangzz Jan/04/2018
-- 跨服竞技段位界面

local KuafjjdwDlg = Singleton("KuafjjdwDlg", Dialog)

function KuafjjdwDlg:init()
    local data = KuafjjMgr.matchTimeData or {}
    local timeStr1 = gf:getServerDate("%m.%d", data.season_start_time or 0)
    local timeStr2 = gf:getServerDate("%m.%d", data.season_end_time or 0)
    self:setLabelText("TitleLabel_1", string.format(CHS[5400405], timeStr1, timeStr2), "MiddleTitleImage")
    self:setLabelText("TitleLabel_2", string.format(CHS[5400405], timeStr1, timeStr2), "MiddleTitleImage")
end

return KuafjjdwDlg
