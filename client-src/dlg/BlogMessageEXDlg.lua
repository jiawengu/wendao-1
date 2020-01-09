-- BlogMessageDlg.lua
-- Created by liuhb  Sep/20/2017
-- 个人空间留言板

local BlogMessageDlg = require('dlg/BlogMessageDlg')
local BlogMessageEXDlg = Singleton("BlogMessageEXDlg", BlogMessageDlg)

BlogMessageEXDlg.relationLeftDlgName = "BlogInfoEXDlg"

function BlogMessageEXDlg:getCfgFileName()
    return ResMgr:getDlgCfg("BlogMessageDlg")
end

-- 表情按钮
function BlogMessageEXDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "blog")

    -- 界面上推
    local height = dlg:getMainBodyHeight()
    DlgMgr:upDlg("BlogMessageEXDlg", height)
end

-- 表情界面关闭时
function BlogMessageEXDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("BlogMessageEXDlg")
end

return BlogMessageEXDlg
