-- FunnyDlg.lua
-- Created by songcw Jan/23/2018
-- WDSY-26872 趣味界面


local FunnyDlg = require('dlg/FunnyDlg')
local Funny1Dlg = Singleton("Funny1Dlg", FunnyDlg)

--[[
function Funny1Dlg:getCfgFileName()
    return ResMgr:getDlgCfg("ReentryAsktaoDlg")
end
--]]

return Funny1Dlg
