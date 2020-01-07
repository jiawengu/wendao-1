-- SystemPushDlg.lua
-- Created by zhengjh Oct/26/2015
-- 推送

local SystemPushDlg = Singleton("SystemPushDlg", Dialog)

-- 本地推送
local PANEL_CONFIG =
{
    ["BiaoxwlPanel"] = "push_biaoxing_wanli",
    ["HaidrqPanel"] = "push_haidao_ruqin",
    ["ChancywPanel"] = "push_chanchu_yaowang",
    ["ShiddhPanel"] = "push_shidao_dahui",
    ["DoubleTaoPanel"] = "push_shuadao_double",
    ["SuperBossPanel"] = "push_super_boss",
    ["WeekActivityPanel"] = "push_week_act",
    ["WorldBossPanel"] = "push_world_boss",
}

-- 服务器推送
local REMOTE_PANEL_CONFIG = {
    ["PartyCirclePanel"] = SERVER_PUSH_KEY.PUSH_PARTY_ZDX,
    ["PartybrigandPanel"] = SERVER_PUSH_KEY.PUSH_PARTY_QDLX,
    ["PartyHanbaPanel"] = SERVER_PUSH_KEY.PUSH_PARTY_HBRQ,
    ["GetTaoTrusteeshipPanel"] = SERVER_PUSH_KEY.PUSH_TRUSTEESHIP_SHUADAO,
    ["InnPanel"] = SERVER_PUSH_KEY.PUSH_INN,
}

local bk_icon = {
    [0] = ResMgr.ui.system_push_back1,
    [1] = ResMgr.ui.system_push_back2,
}

function SystemPushDlg:init()
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("UnSelectButton", self.onUnSelectButton)
    self:bindListViewListener("PushListView", self.onSelectPushListView)
    self:bindCheckBoxListener("FriendCheckBox", self.onFriendCheckBox)
    self:bindCheckBoxListener("OffLineCheckBox", self.onOffLineCheckBox)
    self:bindCheckBoxListener("ShakeCheckBox", self.onShockCheckBox)
    self:bindCheckBoxListener("PKCheckBox", self.onPKCheckBox)

    self:setCheck("FriendCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_FRIEND_MESSAGE))
    self:setCheck("OffLineCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_OFFLINE_SHUADAO))
    self:setCheck("ShakeCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_SHOCK_REMIND))
    self:setCheck("PKCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_PK_REMIND))

    self:initSwichPanel(PANEL_CONFIG, self.onSwichButton)
    self:initSwichPanel(REMOTE_PANEL_CONFIG, self.onSwichRemoteButton)

    local list = self:getControl("PushListView")
    list:requestDoLayout()
    local items = list:getItems()
    for i = 1,#items do
        local panel = items[i]
        self:setImagePlist("BackImage", bk_icon[i % 2], panel)
    end


    if ActivityMgr:startNewActivity() then
        self:setLabelText("CycleLabel", CHS[6000110], "BiaoxwlPanel")
    else
        self:setLabelText("CycleLabel", CHS[5410232], "BiaoxwlPanel")
    end

    local activity = ActivityMgr:getActivityByName(CHS[6400001])
    if activity and ActivityMgr:checkLimitActCanShow(activity) then
        self:setLabelText("ActiveLabel", CHS[6400001], "ShiddhPanel")
    else
        self:setLabelText("ActiveLabel", CHS[5450332], "ShiddhPanel")
    end

    -- 官方和渠道，显示不同的panel
    self:setCtrlVisible("CheckBoxPanel_Guanfang", DistMgr:isOfficalDist())
    self:setCtrlVisible("CheckBoxPanel_Qudao", not DistMgr:isOfficalDist())

    -- 渠道
    if not DistMgr:isOfficalDist() then
        self:setCheck("FriendCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_FRIEND_MESSAGE), "CheckBoxPanel_Qudao")
        self:setCheck("OffLineCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_OFFLINE_SHUADAO), "CheckBoxPanel_Qudao")
        self:setCheck("ShakeCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_SHOCK_REMIND), "CheckBoxPanel_Qudao")
        self:setCheck("PKCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_PK_REMIND), "CheckBoxPanel_Qudao")
        self:setCheck("ZhenbaoCheckBox", 1 == SystemSettingMgr:getPushSetting(SERVER_PUSH_KEY.PUSH_GOLD_STALL), "CheckBoxPanel_Qudao")

        self:bindCheckBoxListener("FriendCheckBox", self.onFriendCheckBox, "CheckBoxPanel_Qudao")
        self:bindCheckBoxListener("OffLineCheckBox", self.onOffLineCheckBox, "CheckBoxPanel_Qudao")
        self:bindCheckBoxListener("ShakeCheckBox", self.onShockCheckBox, "CheckBoxPanel_Qudao")
        self:bindCheckBoxListener("PKCheckBox", self.onPKCheckBox, "CheckBoxPanel_Qudao")

        self:bindCheckBoxListener("ZhenbaoCheckBox", self.onZhenbaoCheckBox, "CheckBoxPanel_Qudao")
    end
end

function SystemPushDlg:cleanup()
    gf:uncheckPermission("Push")
end

function SystemPushDlg:checkPush(onSucc)
    --[[
    if not gf:checkPermission("Push") then
        gf:gotoSetting("Push")
    end
    ]]
    gf:checkPermission("Push", "SystemPushDlg", onSucc, function()
        gf:gotoSetting("Push")
    end)
end

function SystemPushDlg:initSwichPanel(cfgs, onSwich)
    local getFunc
    if REMOTE_PANEL_CONFIG == cfgs then
        getFunc = SystemSettingMgr.getPushSetting
    else
        getFunc = SystemSettingMgr.getSettingStatus
    end
    for k,v in pairs(cfgs) do
        local panel = self:getControl(k)
        local statePanel = self:getControl("OpenStatePanel", nil, panel)

        local boolValue = false

        if getFunc(SystemSettingMgr, v) == 1 then
            boolValue = true
        end

        self:createSwichButton(statePanel, boolValue, onSwich, k)
    end
end

function SystemPushDlg:onSelectButton(sender, eventType)
end

function SystemPushDlg:onUnSelectButton(sender, eventType)
end

function SystemPushDlg:onSelectPushListView(sender, eventType)
end

function SystemPushDlg:onSwichButton(isOn, key)
    SystemPushDlg:checkPush(function()
     if isOn then
        SystemSettingMgr:sendSeting(PANEL_CONFIG[key], 1)
     else
        SystemSettingMgr:sendSeting(PANEL_CONFIG[key], 0)
     end
     end)
end

function SystemPushDlg:onSwichRemoteButton(isOn, key)
    SystemSettingMgr:sendPushSetting(REMOTE_PANEL_CONFIG[key], isOn)
    SystemPushDlg:checkPush()
end

function SystemPushDlg:onFriendCheckBox(sender, eventType)
    SystemSettingMgr:sendPushSetting(SERVER_PUSH_KEY.PUSH_FRIEND_MESSAGE, sender:getSelectedState())
    SystemPushDlg:checkPush()
end

function SystemPushDlg:onOffLineCheckBox(sender, eventType)
    SystemSettingMgr:sendPushSetting(SERVER_PUSH_KEY.PUSH_OFFLINE_SHUADAO, sender:getSelectedState())
   SystemPushDlg:checkPush()
end

function SystemPushDlg:onShockCheckBox(sender, eventType)
    SystemSettingMgr:sendPushSetting(SERVER_PUSH_KEY.PUSH_SHOCK_REMIND, sender:getSelectedState())
    SystemPushDlg:checkPush()
end

function SystemPushDlg:onPKCheckBox(sender, eventType)
    SystemSettingMgr:sendPushSetting(SERVER_PUSH_KEY.PUSH_PK_REMIND, sender:getSelectedState())
    SystemPushDlg:checkPush()
end

function SystemPushDlg:onZhenbaoCheckBox(sender, eventType)
    SystemSettingMgr:sendPushSetting(SERVER_PUSH_KEY.PUSH_GOLD_STALL, sender:getSelectedState())
    SystemPushDlg:checkPush()
end

return SystemPushDlg
