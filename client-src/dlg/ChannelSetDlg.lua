-- ChannelSetDlg.lua
-- Created by zhengjh May/21/2015
-- 聊天频道设置

local ChannelSetDlg = Singleton("ChannelSetDlg", Dialog)

local CHECKBOX_CONFIG =
{
    ["WorldCheckBox"] = "hide_world_msg",
    ["PartyCheckBox"] = "hide_party_msg",
    ["TeamCheckBox"] = "hide_team_msg",
   -- ["SystemCheckBox"] = "hide_system_msg",
    ["CurrentCheckBox"] = "hide_current_msg",
    ["RumorCheckBox"] = "hide_rumor_msg",
    ["PartyAudioCheckBox"] = "autoplay_party_voice",
    ["TeamAudioCheckBox"] = "autoplay_team_voice",
    ["FliterVoiceCheckBox"] = "forbidden_play_voice",
}

-- 选中值为0 没选中为1 （如世界频道选中就是不屏蔽）
-- 其他正常都是选中为1， 没选中为 0
local OPPOSITE_VALUE =
{
    ["WorldCheckBox"] = "hide_world_msg",
    ["PartyCheckBox"] = "hide_party_msg",
    ["CurrentCheckBox"] = "hide_current_msg",
    ["RumorCheckBox"] = "hide_rumor_msg",
    ["TeamCheckBox"] = "hide_team_msg",
    --["SystemCheckBox"] = "hide_system_msg",
}

local SAVA_LOCAL = {
    WorldVoiceCheckBox = 1,
    TeamVoiceCheckBox = 1,
    PartyVoiceCheckBox = 1,
}

function ChannelSetDlg:init()
    self:bindCheckBoxListener("WorldCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("PartyCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("TeamCheckBox", self.checkBoxClick)

    self:bindCheckBoxListener("CurrentCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("RumorCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("PartyAudioCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("TeamAudioCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("FliterVoiceCheckBox", self.checkBoxClick)

    -- 语音按钮
    self:bindCheckBoxListener("WorldVoiceCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("TeamVoiceCheckBox", self.checkBoxClick)
    self:bindCheckBoxListener("PartyVoiceCheckBox", self.checkBoxClick)

    self:initCheckBox()

        --     WDSY-37577 海外版需屏蔽语音仅发送文字的设置选项
    if LeitingSdkMgr:isOverseas() then
        self:setCtrlVisible("FliterVoiceCheckBox", false)

        SystemSettingMgr:sendSeting("forbidden_play_voice", 0)
    end
end


function ChannelSetDlg:checkBoxClick(sender, eventType)
    local key = CHECKBOX_CONFIG[sender:getName()]

    -- 开关保存在本地的
    local userDefault = cc.UserDefault:getInstance()
    if SAVA_LOCAL[sender:getName()] then
        if eventType == ccui.CheckBoxEventType.selected then
            userDefault:setIntegerForKey(sender:getName(), 1)
            gf:ShowSmallTips(CHS[3003682])
        elseif eventType == ccui.CheckBoxEventType.unselected then
            userDefault:setIntegerForKey(sender:getName(), 0)
            gf:ShowSmallTips(CHS[3003687])
        end
        DlgMgr:sendMsg("ChatDlg", "checkVoiceBtnPos")
        return
    end

    -- 开关状态需发送服务器
    if eventType == ccui.CheckBoxEventType.selected then
        if OPPOSITE_VALUE[sender:getName()] then
            SystemSettingMgr:sendSeting(key, 0)
            gf:ShowSmallTips(CHS[3003682])
        else
            SystemSettingMgr:sendSeting(key, 1)

            gf:ShowSmallTips(CHS[3003682])
        end

    elseif eventType == ccui.CheckBoxEventType.unselected then
        if OPPOSITE_VALUE[sender:getName()] then
            SystemSettingMgr:sendSeting(key, 1)
            gf:ShowSmallTips(CHS[3003687])
        else
            SystemSettingMgr:sendSeting(key, 0)
            gf:ShowSmallTips(CHS[3003687])
        end
    end
end

function ChannelSetDlg:initCheckBox()
    local settingTable = SystemSettingMgr:getSettingStatus()

    for k, v in pairs(CHECKBOX_CONFIG) do
        self:setCheckBoxStaus(k, settingTable[v])
    end

    local userDefault = cc.UserDefault:getInstance()
    for k, v in pairs(SAVA_LOCAL) do
        self:setCheckBoxStaus(k, userDefault:getIntegerForKey(k, 1))
    end

end

function ChannelSetDlg:setCheckBoxStaus(name, status)
    local radio = self:getControl(name, Const.UICheckBox)


    if SAVA_LOCAL[name] then
        radio:setSelectedState(status == 1)
        return
    end

    if radio then
        if status == 1 then
            if OPPOSITE_VALUE[name] then
                radio:setSelectedState(false)
            else
                radio:setSelectedState(true)
            end
        elseif status == 0 or status == nil then
            if OPPOSITE_VALUE[name] then
                radio:setSelectedState(true)
            else
                radio:setSelectedState(false)
            end
        end
    end

end


return ChannelSetDlg
