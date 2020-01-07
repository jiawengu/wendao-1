-- MingrzbscExDlg.lua
-- Created by lixh Api/17 2018
-- 名人争霸赛程表
-- 策划要求有两个赛程表界面，在不同NPC处打开

local MingrzbscDlg = require('dlg/MingrzbscDlg')
local MingrzbscExDlg = Singleton("MingrzbscExDlg", MingrzbscDlg)

-- 派生对象中可通过重新该函数来实现共用对话框配置
function MingrzbscExDlg:getCfgFileName()
    return ResMgr:getDlgCfg("MingrzbscDlg")
end

return MingrzbscExDlg
