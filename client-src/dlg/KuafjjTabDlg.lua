-- KuafjjTabDlg.lua
-- Created by huangzz Jan/02/2018
-- 跨服竞技标签

local TabDlg = require('dlg/TabDlg')
local KuafjjTabDlg = Singleton("KuafjjTabDlg", TabDlg)

KuafjjTabDlg.dlgs = {
    KuafjjscDlgCheckBox = "KuafjjscDlg",
    KuafjjjfDlgCheckBox = "KuafjjjfDlg",
    KuafjjljDlgCheckBox = "KuafjjljDlg",
    KuafjjgzDlgCheckBox = "KuafjjgzDlg",
}

function KuafjjTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()

    if name == "KuafjjjfDlgCheckBox" and not KuafjjMgr:myDistHasJoin() then
        gf:ShowSmallTips(CHS[5400358])
        return false
    end
    
    if name == "KuafjjljDlgCheckBox" and KuafjjMgr:getSeasonTotalNum() == 0 then
        gf:ShowSmallTips(CHS[5400359])
        return false
    end
    
    if name == "KuafjjscDlgCheckBox" and not DlgMgr:getDlgByName("KuafjjscDlg") then
        KuafjjMgr:requestSeasonData()
    end
    
    return true
end

return KuafjjTabDlg
