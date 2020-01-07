-- CityTabDlg.lua
-- Created by huangzz Feb/28/2018
-- 同城社交标签页

local TabDlg = require('dlg/TabDlg')
local CityTabDlg = Singleton("CityTabDlg", TabDlg)

CityTabDlg.boxsStates = {}

CityTabDlg.dlgs = {
    CityFriendCheckBox = "CityFriendDlg",
    CityRankingCheckBox = "CityRankingDlg",
    CityNearbyCheckBox = "CityNearbyDlg",
}

function CityTabDlg:getIgnoreDlgWhenCloseCurShowDlg()
    if DlgMgr:getDlgByName(self.name) then
        return { [self.name] = 0, ["CityInfoDlg"] = 0 }
    else
        return self.name
    end
end

function CityTabDlg:onPreCallBack(sender, idx)
    DlgMgr:sendMsg("CityInfoDlg", "autoLocate")
    return true
end

function CityTabDlg:getCheckBoxState(type)
    return self.boxsStates[type]
end

function CityTabDlg:setCheckBoxState(type, flag)
    self.boxsStates[type] = flag
end

function CityTabDlg:cleanup()
    self.boxsStates = {}
end

return CityTabDlg
