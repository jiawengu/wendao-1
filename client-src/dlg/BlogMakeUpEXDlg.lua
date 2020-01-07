-- BlogMakeUpEXDlg.lua
-- Created by huangzz Feb/03/2018
-- 个人空间装饰界面，第二个

local BlogMakeUpDlg = require('dlg/BlogMakeUpDlg')
local BlogMakeUpEXDlg = Singleton("BlogMakeUpEXDlg", BlogMakeUpDlg)

-- 派生对象中可通过重新该函数来实现共用对话框配置
function BlogMakeUpEXDlg:getCfgFileName()
    return ResMgr:getDlgCfg("BlogMakeUpDlg")
end

function BlogMakeUpEXDlg:onCloseButton()
    local tabDlg = DlgMgr:getDlgByName("BlogEXTabDlg")
    if tabDlg then 
        tabDlg:onCloseButton()
    end
    
    Dialog.onCloseButton(self)
end

return BlogMakeUpEXDlg
