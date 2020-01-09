-- BlogCircleEXDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间，打开第二个

local BlogCircleDlg = require('dlg/BlogCircleDlg')
local BlogCircleEXDlg = Singleton("BlogCircleEXDlg", BlogCircleDlg)

-- 派生对象中可通过重新该函数来实现共用对话框配置
function BlogCircleEXDlg:getCfgFileName()
    return ResMgr:getDlgCfg("BlogCircleDlg")
end

function BlogCircleEXDlg:cleanup()
    -- 由于Tab标签页切换，有时候只关闭该对话框，所以需要手动关闭 BlogInfoDlg
    DlgMgr:closeDlg("BlogInfoEXDlg")  
end

return BlogCircleEXDlg
