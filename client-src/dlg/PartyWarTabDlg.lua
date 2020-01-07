-- PartyWarTabDlg.lua
-- Created by liuhb Apr/7/2015
-- 帮战右侧标签

local TabDlg = require('dlg/TabDlg')
local PartyWarTabDlg = Singleton("PartyWarTabDlg", TabDlg)

PartyWarTabDlg.dlgs = {
    SignUpCheckBox      = "PartyWarSignUpDlg",
    ScheduleCheckBox    = "PartyWarScheduleDlg",
    HistoryCheckBox     = "PartyWarHistoryDlg",
    InstructionCheckBox = "PartyWarInstructionDlg",
}

local DLG_MSG_MAP = {
    SignUpCheckBox      = PartyWarMgr.DLGTYPE.BID,
    ScheduleCheckBox    = PartyWarMgr.DLGTYPE.FIXTURES,
    HistoryCheckBox     = PartyWarMgr.DLGTYPE.HISTORY,
}

function PartyWarTabDlg:init()
--    self:hookMsg("MSG_GENERAL_NOTIFY")
    TabDlg.init(self)
end

function PartyWarTabDlg:onClick(sender, idx)
    local name = sender:getName()
    
    if 1 then return end
    if DLG_MSG_MAP[name] then
        PartyWarMgr:requestDlgInfo(DLG_MSG_MAP[name])
    end
end

function PartyWarTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()

    if name == "SignUpCheckBox" and not DlgMgr:getDlgByName("PartyWarSignUpDlg") then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_PW_OPEN_WINDOW, "1")
        return false
    elseif name == "ScheduleCheckBox" and not DlgMgr:getDlgByName("PartyWarScheduleDlg") then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_PW_OPEN_WINDOW, "2")
        return false
    elseif name == "HistoryCheckBox" and not DlgMgr:getDlgByName("PartyWarHistoryDlg") then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_PW_OPEN_WINDOW, "3")
        return false
    end
    return true
end

--[[
function PartyWarTabDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_PW_OPEN_WINDOW == data.notify  then
        for _, dlgName in pairs(PartyWarTabDlg.dlgs) do
            -- 不知道为什么这边要关闭对话框，但是报名界面点刷新，关闭对话框又打开界面会闪，所以报名界面不关闭
            if dlgName == "PartyWarSignUpDlg" and data.para == "1" then
                
            else
                DlgMgr:closeThisDlgOnly(dlgName)
            end
        end
    
        if data.para == "1" then
            DlgMgr:openDlg("PartyWarSignUpDlg")
            self:setSelectDlg("PartyWarSignUpDlg")
        elseif data.para == "2" then
            DlgMgr:openDlg("PartyWarScheduleDlg")
            self:setSelectDlg("PartyWarScheduleDlg")
        elseif data.para == "3" then
            DlgMgr:openDlg("PartyWarHistoryDlg")
            self:setSelectDlg("PartyWarHistoryDlg")
        end
    end
end
--]]
PartyWarTabDlg:setCallBack(PartyWarTabDlg.onClick)

return PartyWarTabDlg
