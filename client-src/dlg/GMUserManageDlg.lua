-- GMUserManageDlg.lua
-- Created by songcw Feb/24/2016
-- GM 操作角色界面对话框

local GMUserManageDlg = Singleton("GMUserManageDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOXS = {
    "WainingCheckBox",
    "KickOffCheckBox",
    "ForbidSpeakingCheckBox",
    "RestrictUserCheckBox",
    "BlockUserCheckBox",
    "BlockAccountCheckBox",
    "MonitoringCheckBox",
    "StopCombatCheckBox",
    "MoveToCheckBox",
    "ViewProcessCheckBox",
    "BlockMacCheckBox",
}

local BUTTON_CTRL = {
    [1] = {["func"] = CHS[3002719], ["ctrl"] = "WainingCheckBox"},
    [2] = {["func"] = CHS[3002720], ["ctrl"] = "KickOffCheckBox"},
    [3] = {["func"] = CHS[3002721], ["ctrl"] = "ForbidSpeakingCheckBox"},
    [4] = {["func"] = CHS[3002722], ["ctrl"] = "RestrictUserCheckBox"},
    [5] = {["func"] = CHS[3002723], ["ctrl"] = "BlockUserCheckBox"},
    [6] = {["func"] = CHS[3002724], ["ctrl"] = "BlockAccountCheckBox"},
    [7] = {["func"] = CHS[3002725], ["ctrl"] = "MonitoringCheckBox"},
    [8] = {["func"] = CHS[3002723], ["ctrl"] = "StopCombatCheckBox"},
    [9] = {["func"] = CHS[3002724], ["ctrl"] = "MoveToCheckBox"},
    [10] = {["func"] = CHS[3002725], ["ctrl"] = "ViewProcessCheckBox"},
    [11] = {["func"] = CHS[4300114], ["ctrl"] = "BlockMacCheckBox"}
}

function GMUserManageDlg:init()
    self:setFullScreen()

    -- 事件监听
    self:bindTouchEndEventListener(self.root, self.onCloseButton)

    -- 单选CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItemsCanReClick(self, CHECKBOXS, self.onMenuCheckBox)

    self.userInfo = nil
    self:canDoInit()
end

function GMUserManageDlg:canDoInit()
    for i = 1,#BUTTON_CTRL do
        if GMMgr:isCanDo(BUTTON_CTRL[i].func) then

        else
            self:getControl(BUTTON_CTRL[i].ctrl).notDo = true
            self:getControl("Label", nil, BUTTON_CTRL[i].ctrl):setColor(COLOR3.GRAY)
        end
    end
end

function GMUserManageDlg:onMenuCheckBox(sender, curIdx)
    if sender.notDo then
        gf:ShowSmallTips(CHS[3002726])
        return
    end

    if curIdx == 1 then
        -- 警告
        local dlg = DlgMgr:openDlg("GMWarningDlg")
        dlg:setDlgInfoByUser(self.userInfo)
     --   GMMgr:cmdWainingPlayer()
    elseif curIdx == 2 then
        -- 强踢下线
        local dlg = DlgMgr:openDlg("GMConfirmDlg")
        dlg:setSearchType("kickOff", self.userInfo)
    elseif curIdx == 3 then
        -- 禁言
        local dlg = DlgMgr:openDlg("GMForbidSpeakingDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    elseif curIdx == 4 then
        -- 禁闭角色
        local dlg = DlgMgr:openDlg("GMRestrictUserDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    elseif curIdx == 5 then
        -- 封闭角色
        local dlg = DlgMgr:openDlg("GMBlockUserDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    elseif curIdx == 6 then
        -- 封闭账号
        local dlg = DlgMgr:openDlg("GMBlockAccountDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    elseif curIdx == 7 then
        GMMgr:cmdSniffAT(self.userInfo.name)
    elseif curIdx == 8 then
        -- 停止战斗
        GMMgr:cmdStopCombat(self.userInfo.gid)
    elseif curIdx == 9 then
        -- 接近目标
        GMMgr:cmdMoveToTarget(self.userInfo.gid)
    elseif curIdx == 10 then
        -- 查看进程
        GMMgr:cmdSearchProcess(self.userInfo.gid)
    elseif curIdx == 11 then
        -- 封闭Mac
        local dlg = DlgMgr:openDlg("GMBlockMacDlg")
        dlg:setDlgInfoByUser(self.userInfo)
    end
end

function GMUserManageDlg:setUser(userInfo)
    self.userInfo = userInfo
end

function GMUserManageDlg:getUser()
    return self.userInfo
end

return GMUserManageDlg
