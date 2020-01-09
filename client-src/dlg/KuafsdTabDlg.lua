-- KuafsdTabDlg.lua
-- Created by huangzz Dec/15/2018
-- 跨服试道标签界面

local TabDlg = require('dlg/TabDlg')
local KuafsdTabDlg = Singleton("KuafsdTabDlg", TabDlg)

KuafsdTabDlg.tabMargin = 7

-- 按钮与对话框的映射表
KuafsdTabDlg.dlgs = {
    KuafsdsqfpDlgCheckBox = "KuafsdsqfpDlg",            -- 时间
    KuafsdwzDlgCheckBox = "KuafsdwzDlg",           -- 赛程
    KuafsdgzDlgCheckBox = "KuafsdgzDlg",         -- 规则  
}

KuafsdTabDlg.lastDlg = "KuafsdgzDlg"
KuafsdTabDlg.orderList = {
    ["KuafsdsqfpDlgCheckBox"]   = 1,
    ["KuafsdwzDlgCheckBox"]     = 2,
    ["KuafsdgzDlgCheckBox"]     = 3,
}

function KuafsdTabDlg:init()
    TabDlg.init(self)
end

function KuafsdTabDlg:refreshView(type)
    if type == KFSD_TYPE.MONTH then
        self.orderList["KuafsdsqfpDlgCheckBox"] = 5
        self:setCtrlVisible("KuafsdsqfpDlgCheckBox", false)
    else
        self.orderList["KuafsdsqfpDlgCheckBox"] = 1
        self:setCtrlVisible("KuafsdsqfpDlgCheckBox", true)
    end

    self.kuafType = type

    TabDlg.refreshView(self, self.allRadio)
end

function KuafsdTabDlg:isMonthTaoKFSD()
    return self.kuafType == KFSD_TYPE.MONTH
end

function KuafsdTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end

    local name = sender:getName()
    if name == "KuafsdsqfpDlgCheckBox" and not DlgMgr:isDlgOpened("KuafsdsqfpDlg") then
        gf:CmdToServer("CMD_REQUEST_CS_SHIDAO_ASSIGN_ZONE_PLAN", {})
        return false
    end

    if name == "KuafsdwzDlgCheckBox" and not DlgMgr:isDlgOpened("KuafsdwzDlg") then
        if self:isMonthTaoKFSD() then
            gf:CmdToServer("CMD_REQUEST_CS_SHIDAO_HISTORY", {
                type = KFSD_TYPE.MONTH,
                session = 0, 
                levelRange = "120-129",
                area = ''
            })
        else
            gf:CmdToServer("CMD_REFRESH_CS_SHIDAO_PLAN", {})
        end
        return false
    end

    return true
end

return KuafsdTabDlg
