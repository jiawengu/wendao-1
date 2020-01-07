-- NewKuafzcTabDlg.lua
-- Created by
--

local TabDlg = require('dlg/TabDlg')
local NewKuafzcTabDlg = Singleton("NewKuafzcTabDlg", TabDlg)

-- 按钮与对话框的映射表
NewKuafzcTabDlg.dlgs = {
    KuafzcsjDlgCheckBox = "NewKuafzcsjDlg",
    KuafzcscDlgCheckBox = "NewKuafzcscDlg",
    KuafzcjfDlgCheckBox = "NewKuafzcjfDlg",
    KuafzcgzDlgCheckBox = "NewKuafzcgzDlg",
}


function NewKuafzcTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()

    if name == "KuafzcjfDlgCheckBox"  then
        if KuafzcMgr:isJoinMyDist2019() then
        else
            gf:ShowSmallTips(CHS[4200439])
        end
        return KuafzcMgr:isJoinMyDist2019()
    end
    return true
end

function NewKuafzcTabDlg:cleanup()
    KuafzcMgr:cleanup()
end

return NewKuafzcTabDlg
