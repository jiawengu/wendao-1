-- ChatMgr.lua
-- created by zhengjh Apr/29/2015
-- 系统设置管理器

SystemSettingMgr = Singleton()
local SystemConfig = {}
local json = require("json")
local Bitset = require('core/Bitset')

SERVER_PUSH_KEY = {
    PUSH_FRIEND_MESSAGE     = 0,    -- 推送好友消息
    PUSH_OFFLINE_SHUADAO    = 1,    -- 推送离线刷道消息
    PUSH_PARTY_ZDX          = 2,    -- 帮派智多星
    PUSH_PARTY_QDLX         = 3,    -- 强盗来袭
    PUSH_PARTY_HBRQ         = 4,    -- 旱魃入侵+
    PUSH_SUPER_BOSS         = 5,
    PUSH_TRUSTEESHIP_SHUADAO = 6,
    PUSH_SHOCK_REMIND         = 7,   -- 震动提醒
    PUSH_PK_REMIND          = 8,     -- 被强P提醒
    PUSH_INN                = 9,     -- 客栈推送
    PUSH_GOLD_STALL         = 10,   -- 珍宝交易
    PUSH_MAX                = 11,     -- 用于记录共有几条推送
}

local RADIOGROUP_LOCAL_CONFIG = {
    ["sight_scope"] = 3,
    ["refuse_look_equip"] = 1,
    ["refuse_party_image"] = 3,
    ["visit_house"] = 3
}

function SystemSettingMgr:getConfigByKey(key)
    return RADIOGROUP_LOCAL_CONFIG[key]
end

function SystemSettingMgr:sendSeting(key, value)
    gf:CmdToServer("CMD_SET_SETTING", { key = key, value = value })
end

function SystemSettingMgr:MSG_SET_SETTING(data)
    for k, v in pairs(data["setting"]) do
        if SystemConfig[k] ~= v and RADIOGROUP_LOCAL_CONFIG[k] then
            local isLocalStorge = Bitset.new(RADIOGROUP_LOCAL_CONFIG[k])
            if isLocalStorge:isSet(2) then
                self:saveSetting(k, v)
            end
        end

        SystemConfig[k] = v
    end
end

function SystemSettingMgr:sendPushSetting(key, value)
    if value then
        gf:CmdToServer('CMD_SET_PUSH_SETTINGS', { key = key, value = 1})
    else
        gf:CmdToServer('CMD_SET_PUSH_SETTINGS', { key = key, value = 0})
    end
end

function SystemSettingMgr:MSG_SET_PUSH_SETTINGS(data)
    --self.pushSettings = data.value
    if not data then return end
    self.pushSettings = {}
    for i = 1, #data.value do
        self.pushSettings[i] = data.value:sub(i, i)
    end
end

function SystemSettingMgr:getPushSetting(key, defaultValue)
    if not self.pushSettings then return false end
    if not key then
        return self.pushSettings
    end

    return tonumber(self.pushSettings[key + 1]) or defaultValue
end

-- 载入配置
function SystemSettingMgr:loadSetting()
    -- 默认打开装备查看
    SystemConfig["refuse_look_equip"] = 0
    local userDefault = cc.UserDefault:getInstance()
    if userDefault then
        local settingStr = userDefault:getStringForKey("local_settings")
        if settingStr and "" ~= settingStr then
            pcall(function()
                local localSetting = json.decode(settingStr)
                for k, v in pairs(localSetting) do
                    SystemConfig[k] = v
                end
            end)
        end
    end

end

-- 保存配置
function SystemSettingMgr:saveSetting(key, value)
    local oldValue = SystemConfig[key]
    SystemConfig[key] = value
    local userDefault = cc.UserDefault:getInstance()
    if userDefault then
        local settingStr = userDefault:getStringForKey("local_settings")
        local localSetting
        if settingStr and "" ~= settingStr then
            localSetting = json.decode(settingStr)
        else
            localSetting = {}
        end

        pcall(function()
            localSetting[key] = value
            userDefault:setStringForKey("local_settings", json.encode(localSetting))
            userDefault:flush()
        end)
    end

    if oldValue ~= value then
        EventDispatcher:dispatchEvent("SYSTEM_SETTING_CHANGE", key, oldValue, value)
    end
end

-- 获取配置状态
function SystemSettingMgr:getSettingStatus(key, defaultValue)
    if key and SystemConfig then
        return SystemConfig[key] or defaultValue
    else
        return SystemConfig
    end
end

function SystemSettingMgr:clearData()
    SystemConfig = {}
end

function SystemSettingMgr:initServerSet()
    if SystemConfig then
        SystemConfig["award_supply_pet"] = nil
        SystemConfig["auto_reply_msg"] = nil
    end
end

function SystemSettingMgr:MSG_ASK_CLIENT_SECRET(data)
    self.secretKey = data.key
end

function SystemSettingMgr:getDelCharSecretKey()
    return self.secretKey
end

-- 设置音乐开关
function SystemSettingMgr:setMusicEnable(isOn)
    if isOn == true then
        -- 需要播放音乐
        SoundMgr:resumeMusic()
    else
        -- 不用播放音乐
        SoundMgr:pauseMusic()
    end

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("musicOn", isOn)
end

-- 获取音乐开关
function SystemSettingMgr:getMusicEnable()
    local userDefault = cc.UserDefault:getInstance()
    return userDefault:getBoolForKey("musicOn", true)
end

-- 设置音效开关
function SystemSettingMgr:setSoundEnable(isOn)
    if isOn == true then
        -- 需要播放音乐
        SoundMgr:resumeSound()
    else
        -- 不用播放音乐
        SoundMgr:stopSoundEX()
    end

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("soundOn", isOn)
end

-- 获取音效开关
function SystemSettingMgr:getSoundEnable()
    local userDefault = cc.UserDefault:getInstance()
    return userDefault:getBoolForKey("soundOn", true)
end

-- 设置配音开关
function SystemSettingMgr:setDubbingEnable(isOn)
    if isOn then
        -- 需要播放配音
        SoundMgr:resumeDubbing()
    else
        -- 需要播放配音
        SoundMgr:stopDubbing()
    end

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("dubbingOn", isOn)
end

-- 获取配音开关
function SystemSettingMgr:getDubbingEnable()
    local userDefault = cc.UserDefault:getInstance()
    return userDefault:getBoolForKey("dubbingOn", true)
end

-- 设置提示音开关
function SystemSettingMgr:setHintEnable(isOn)
    if isOn then
        -- 需要播放提示音
        SoundMgr:resumeHint()
    else
        -- 需要播放提示音
        SoundMgr:stopHint()
    end

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setBoolForKey("hintOn", isOn)
end

-- 获取提示音开关
function SystemSettingMgr:getHintEnable()
    local userDefault = cc.UserDefault:getInstance()
    return userDefault:getBoolForKey("hintOn", true)
end

-- 设置音量
function SystemSettingMgr:setVolumeValue(value)
    value = value / 100.0
    SoundMgr:changeMusicVolumeValue(value)
    SoundMgr:changeSoundVolumeValue(value)

    -- 保存数据
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setFloatForKey("musicValue", value)
    userDefault:setFloatForKey("soundValue", value)
end

-- 获取音量
function SystemSettingMgr:getVolumeValue()
    local userDefault = cc.UserDefault:getInstance()
    return 100 * userDefault:getFloatForKey("musicValue", 0.5)
end

-- 载入本地设置
SystemSettingMgr:loadSetting()

MessageMgr:regist("MSG_SET_SETTING", SystemSettingMgr)
MessageMgr:regist("MSG_ASK_CLIENT_SECRET", SystemSettingMgr)
MessageMgr:regist("MSG_SET_PUSH_SETTINGS", SystemSettingMgr)

return SystemSettingMgr
