-- KuafsdgzDlg.lua
-- Created by huangzz Dec/15/2018
-- 跨服试道规则说明界面

local KuafsdgzDlg = Singleton("KuafsdgzDlg", Dialog)

function KuafsdgzDlg:init()
    self:setDlgType()
end

function KuafsdgzDlg:onDlgOpened(param)
    local type = tonumber(param and param[1])
    local dlg = DlgMgr:getDlgByName("KuafsdTabDlg")
    if dlg then
        dlg:refreshView(type)
    end

    self:setDlgType()
end

function KuafsdgzDlg:setDlgType()
    if DlgMgr:sendMsg("KuafsdTabDlg", "isMonthTaoKFSD") then
        self:setCtrlVisible("ListView", false)
        self:setCtrlVisible("MonthListView", true)
        self:setImage("MiddleTitleImage_1", ResMgr.ui.month_tao_kuafsd_title)
    else
        self:setCtrlVisible("ListView", true)
        self:setCtrlVisible("MonthListView", false)
        self:setImage("MiddleTitleImage_1", ResMgr.ui.kuafsd_title)
    end
end

return KuafsdgzDlg
