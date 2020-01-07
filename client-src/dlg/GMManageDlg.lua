-- GMManageDlg.lua
-- Created by songcw Feb/23/2016
-- GM输入对话框

local GMManageDlg = Singleton("GMManageDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOXS = {
    "UserSearchCheckBox",
    "AccountSearchCheckBox",
    "ChangeStateCheckBox",
    "NPCSearchCheckBox",
    "ConfigAttribCheckBox",
    "RecordPosCheckBox",
    "WatchCheckBox",
--    "CrossServiceCheckBox",
}

local CHECKBOXS_SEARCH = {
    "SearchByNameCheckBox",
    "SearchByGidCheckBox",
    "CurrentLineCheckBox",
    "CurrentMapCheckBox",
}

local CHECKBOXS_CONFIG = {
    "UserAttribCheckBox",
    "MakePetCheckBox",
    "MakeEquipmentCheckBox",
    "MakeItemCheckBox",
}

local BUTTON_CTRL = {
    [1] = {["func"] = CHS[3002711], ["ctrl"] = "SearchByNameCheckBox"}, 	-- 名称查询
    [2] = {["func"] = CHS[3002712], ["ctrl"] = "SearchByGidCheckBox"},		-- GID查询
    [3] = {["func"] = CHS[3002713], ["ctrl"] = "AccountSearchCheckBox"},		-- 账号查询
    [4] = {["func"] = CHS[3002714], ["ctrl"] = "ChangeStateCheckBox"},		-- 切换隐身
    [5] = {["func"] = CHS[4300049], ["ctrl"] = "NPCSearchCheckBox"},		-- NPC查询
    [6] = {["func"] = CHS[4300047], ["ctrl"] = "CurrentLineCheckBox"},		-- 本线查询
    [7] = {["func"] = CHS[4300048], ["ctrl"] = "CurrentMapCheckBox"},		 -- 本地图查询
    [8] = {["func"] = CHS[4400017], ["ctrl"] = "RecordPosCheckBox"},        -- 记录坐标
    [9] = {["func"] = CHS[4100463], ["ctrl"] = "ConfigAttribCheckBox"},
    [10] = {["func"] = CHS[5420263], ["ctrl"] = "WatchCheckBox"},
  --  [11] = {["func"] = CHS[4300369], ["ctrl"] = "CrossServiceCheckBox"},
}

local RECORD_POS_CHECKBOX = {
    "StartRecordCheckBox",
    "FileListCheckBox",
}

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

local QMPK_FINAL_MATCH_ID = QuanminPK2Mgr:getFinalMatchIdCfg()

function GMManageDlg:init()
    self:setFullScreen()

    -- 事件监听
    self:bindTouchEndEventListener(self.root, self.onCloseLastPanel)

    self:bindListener("SearchByNameCheckBox", self.onNPCSearchButton, "NpcSearchPanel")

    self:setSecondMenuVisible(false)

    -- 单选CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItemsCanReClick(self, CHECKBOXS, self.onMenuCheckBoxClick)

    -- 单选CheckBox
    self.radioGroupSearch = RadioGroup.new()
    self.radioGroupSearch:setItemsCanReClick(self, CHECKBOXS_SEARCH, self.onSearchCheckBoxClick)

    -- 单选CheckBox
    self.radioGroupRecordPos = RadioGroup.new()
    self.radioGroupRecordPos:setItemsCanReClick(self, RECORD_POS_CHECKBOX, self.onPosCheckBoxClick)

    -- 单选CheckBox
    self.radioGroupConfig = RadioGroup.new()
    self.radioGroupConfig:setItemsCanReClick(self, CHECKBOXS_CONFIG, self.onConfigCheckBoxClick)

    self:canDoInit()

    self:hookMsg("MSG_CSQ_GM_REQUEST_CONTROL_INFO")
end

-- 设置二级菜单状态
function GMManageDlg:setSecondMenuVisible(isVisible)
    self:setCtrlVisible("UserSearchPanel", isVisible)
    self:setCtrlVisible("NpcSearchPanel", isVisible)
    self:setCtrlVisible("RecordPosPanel", isVisible)
    self:setCtrlVisible("ConfigAttribPanel", isVisible)
    self:setCtrlVisible("CrossServicePanel", isVisible)
    self:setCtrlVisible("QuanmPKPanel", isVisible)
end

function GMManageDlg:canDoInit()
    for i = 1,#BUTTON_CTRL do
        if GMMgr:isCanDo(BUTTON_CTRL[i].func) then

        else
            self:getControl(BUTTON_CTRL[i].ctrl).notDo = true
            self:getControl("Label", nil, BUTTON_CTRL[i].ctrl):setColor(COLOR3.GRAY)
        end
    end

    if not GMMgr:isCanDo(BUTTON_CTRL[1].func) and not GMMgr:isCanDo(BUTTON_CTRL[2].func) then
        self:getControl("UserSearchCheckBox").notDo = true
        self:getControl("Label", nil, "UserSearchCheckBox"):setColor(COLOR3.GRAY)
    end
end

function GMManageDlg:onNPCSearchButton(sender, eventType)
    GMMgr:cmdQueryNPC()
end

function GMManageDlg:onCloseLastPanel(sender, eventType)
    if self:getCtrlVisible("UserSearchPanel") then
        self:setCtrlVisible("UserSearchPanel", false)
        return
    end

    if self:getCtrlVisible("NpcSearchPanel") then
        self:setCtrlVisible("NpcSearchPanel", false)
        return
    end

    self:onCloseButton()
end

-- 记录坐标
function GMManageDlg:onPosCheckBoxClick(sender, curIdx)
    if curIdx == 1 then
        -- 开始记录
        DlgMgr:openDlg("RecordPosDlg")
        RecordLogMgr:startRocordPos()
        self:onCloseButton()
    elseif curIdx == 2 then
        -- 文件列表
        local dlg = DlgMgr:openDlg("GMPosFileListDlg")
    end
end

-- 配置属性
function GMManageDlg:onConfigCheckBoxClick(sender, curIdx)
    if curIdx == 1 then
        -- 角色属性
        DlgMgr:openDlg("GMRolePropertiesDlg")
    elseif curIdx == 2 then
        -- 宠物生成
        DlgMgr:openDlg("GMPetCreatDlg")
    elseif curIdx == 3 then
        -- 装备制作
        DlgMgr:openDlg("GMEquipmentCreatDlg")
    elseif curIdx == 4 then
        -- 道具生成
        DlgMgr:openDlg("GMItemCreatDlg")
    end
end

function GMManageDlg:onSearchCheckBoxClick(sender, curIdx)
    if sender.notDo then
        gf:ShowSmallTips(CHS[3002715])
        return
    end

    if curIdx == 1 then
        local dlg = DlgMgr:openDlg("GMConfirmDlg")
        dlg:setSearchType("name")
    elseif curIdx == 2 then
        local dlg = DlgMgr:openDlg("GMConfirmDlg")
        dlg:setSearchType("gid")
    elseif curIdx == 3 then
        -- 本线查询
        GMMgr:cmdQueryLocalLine()
    elseif curIdx == 4 then
        -- 本地图查询
        GMMgr:cmdQueryLocalMap()
    end
end

function GMManageDlg:onMenuCheckBoxClick(sender, curIdx)
    if sender.notDo then
        gf:ShowSmallTips(CHS[3002715])
        return
    end

    self:setSecondMenuVisible(false)
    if sender:getName() == "UserSearchCheckBox" then
        self:setCtrlVisible("UserSearchPanel", true)
    elseif sender:getName() == "AccountSearchCheckBox" then
        local dlg = DlgMgr:openDlg("GMConfirmDlg")
        dlg:setSearchType("account")
    elseif sender:getName() == "ChangeStateCheckBox" then
        GMMgr:cmdChangeShadowState()
    elseif sender:getName() == "NPCSearchCheckBox" then
        -- NPC查询
        self:setCtrlVisible("NpcSearchPanel", true)
    elseif sender:getName() == "RecordPosCheckBox" then
        -- 记录坐标
        self:setCtrlVisible("RecordPosPanel", true)
    elseif sender:getName() == "ConfigAttribCheckBox" then
        -- 配置属性
        self:setCtrlVisible("ConfigAttribPanel", true)
    elseif sender:getName() == "WatchCheckBox" then
        DlgMgr:openDlg("GMCombatlogDlg")
    elseif sender:getName() == "CrossServiceCheckBox" then
        self:setCtrlVisible("CrossServicePanel", true)
    end
end

function GMManageDlg:MSG_CSQ_GM_REQUEST_CONTROL_INFO()
    local data = GMMgr:getQmpkGmData()
    self:setCtrlVisible("QuanmPKPanel", true)

    -- 根据matchId刷新字体颜色
    for i = 1, data.count do
        local ctrl = self:getControl("QmpkLabel" .. i)
        if data.list[i].status ~= 2 then
            ctrl:setColor(COLOR3.GRAY)
        else
            ctrl:setColor(COLOR3.WHITE)
        end
    end
end

return GMManageDlg
