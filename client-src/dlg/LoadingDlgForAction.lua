-- LoadingDlg.lua
-- Created by songcw Apri/16/2019
-- 过图表现界面
-- 该仅提供过图表现

local LoadingDlg = require('dlg/LoadingDlg')

local LoadingDlgForAction = Singleton("LoadingDlgForAction", LoadingDlg)

local LOAD_TIME = 1.4

function LoadingDlgForAction:getCfgFileName()
    return ResMgr:getDlgCfg("LoadingDlg")
end

function LoadingDlgForAction:init(seconds)
    LoadingDlg.init(self)

    seconds = seconds or LOAD_TIME

    self:showProgress(seconds)
end

-- 开始播放动画
function LoadingDlgForAction:showProgress(second)
    self:setProgressBarByHourglass("UpdateProgressBar", second * 1000, 0, function ( )
        self:onCloseButton()
    end)
end

return LoadingDlgForAction
