-- KuafzcTabDlg.lua
-- Created by songcw Aug/8/2017
-- 跨服战场-tab界面


local TabDlg = require('dlg/TabDlg')
local KuafzcTabDlg = Singleton("KuafzcTabDlg", TabDlg)

-- 按钮与对话框的映射表
KuafzcTabDlg.dlgs = {
    KuafzcsjDlgCheckBox = "KuafzcsjDlg",
    KuafzcscDlgCheckBox = "KuafzcscDlg",
    KuafzcjfDlgCheckBox = "KuafzcjfDlg",
    KuafzcgzDlgCheckBox = "KuafzcgzDlg",
}

function KuafzcTabDlg:cleanup()
    KuafzcMgr:cleanup()
end

function KuafzcTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()

    if name == "KuafzcjfDlgCheckBox"  then
        if KuafzcMgr:isJoinMyDist() then
        else
            gf:ShowSmallTips(CHS[4200439])
        end
        return KuafzcMgr:isJoinMyDist()     
        
    end
    return true
end

return KuafzcTabDlg
