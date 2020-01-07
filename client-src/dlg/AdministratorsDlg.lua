-- AdministratorsDlg.lua
-- Created by songcw Sep/11/2018
-- 赛事管理

local AdministratorsDlg = Singleton("AdministratorsDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CROSS_COMPET_CHECKBOX = {
    "MRZBCheckBox",
    "QMPKCheckBox",
}

local QMPK_CHECKBOX = {
    "CheckBox_1",
    "CheckBox_2",
    "CheckBox_3",
    "CheckBox_4",
}

function AdministratorsDlg:init()
    -- 单选CheckBox
    self.radioGroupCompetition = RadioGroup.new()
    self.radioGroupCompetition:setItemsCanReClick(self, CROSS_COMPET_CHECKBOX, self.onCompetitionCheckBoxClick)

    -- 单选CheckBox
    self.radioGroupQmpk = RadioGroup.new()
    self.radioGroupQmpk:setItemsCanReClick(self, QMPK_CHECKBOX, self.onQuanmpkCheckBoxClick)

    self:setCtrlVisible("QuanmPKPanel", false)

    self:hookMsg("MSG_CSQ_GM_REQUEST_CONTROL_INFO")
end

-- 全名PK单选
function AdministratorsDlg:onQuanmpkCheckBoxClick(sender, curIdx)
    local matchData = GMMgr:getQmpkGmData()
    if not matchData then return end
    local info = matchData.list[curIdx]
    if info.status == 1 then
        -- 本阶段比赛已结束，无法进行管理
        gf:ShowSmallTips(CHS[7100313])
    elseif info.status == 3 then
        -- 当前不处于该阶段，无法进行管理
        gf:ShowSmallTips(CHS[7100314])
    else
        DlgMgr:openDlgEx("GMQuanmPKFightDlg", curIdx)
    end
end

-- 赛事
function AdministratorsDlg:onCompetitionCheckBoxClick(sender, curIdx)
    if curIdx == 1 then
        -- 名人争霸
        GMMgr:openGM_MRZB_CONTROL()
    elseif curIdx == 2 then
        -- 全名PK
        GMMgr:openGM_QMPK_CONTROL()
    end
end

function AdministratorsDlg:MSG_CSQ_GM_REQUEST_CONTROL_INFO()
    local data = GMMgr:getQmpkGmData()
    self:setCtrlVisible("QuanmPKPanel", true)

    -- 根据matchId刷新字体颜色
    for i = 1, data.count do
        local ctrl = self:getControl("Label", nil, "CheckBox_" .. i)
        if data.list[i].status ~= 2 then
            ctrl:setColor(COLOR3.GRAY)
        else
            ctrl:setColor(COLOR3.WHITE)
        end
    end
end

return AdministratorsDlg
