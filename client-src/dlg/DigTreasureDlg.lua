-- DigTreasureDlg.lua
-- Created by songcw Aug/21/2015
-- 挖宝进度条

local DigTreasureDlg = Singleton("DigTreasureDlg", Dialog)

function DigTreasureDlg:init()
    self:getControl("ProgressBar"):setPercent(0)
end

function DigTreasureDlg:setTask(name)
    gf:frozenScreen(0, 0)
    local function callBack()
        gf:unfrozenScreen()
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_BAOZANG_READY_SEARCH, name)    
        DlgMgr:closeDlg("DigTreasureDlg")      
    end
    
    self:setProgressBar("ProgressBar", 100, 100, nil, nil, true, callBack)
end

return DigTreasureDlg
