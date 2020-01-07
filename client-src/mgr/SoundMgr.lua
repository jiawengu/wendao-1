-- SoundMgr.lua
-- created by wangc
-- 声音管理

require('AudioEngine')

SoundMgr = Singleton("SoundMgr")
local SoundInfo = require(ResMgr:getCfgPath('Sound.lua')) -- 声音配置文件
local SoundPreloadList = require(ResMgr:getCfgPath('SoundPreloadList.lua')) -- 预加载音效配置文件
local SoundLength = require(ResMgr:getCfgPath('SoundLength.lua')) -- 音效时长文件
local lastBGMusicFileName = nil -- 上次播放的背景声音文件

local musicVolumeValue = 1      -- 当前音量（背景音乐）
local soundVolumeValue = 1      -- 当前音量（音效）

local musicOn          = true
local soundOn          = true
local dubbingOn        = true
local hintOn           = true

local bgStartPlayTime  = 0      -- 背景开始播放的时间

local PRELOAD_COUNT_PER_FRAME = 5

-- 音效类型包括一般音效、NPC配音和提示音
local SOUND_TYPE = {
    SOUND = 1,
    DUBBING = 2,
    HINT = 3
}

-- “清除保存的过期音效数据”的间隔时间
local cleanSoundDataInterval = 6 * 1000
local soundIsPlaying = {}
local dubbingIsPlaying = {}
local hintIsPlaying = {}
local soundPlayList = {}

local volumeByType = {}

-- 好声音声音质量
local GD_QUALITY = 2

function SoundMgr:init()
    self:readCfg()
    self:preloadEffect()
    self.lastTime = gfGetTickCount()
end

local callJavaFun = function(fun, sig, args)
    local luaj = require('luaj')
    local className = 'org/cocos2dx/lib/Cocos2dxHelper'
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        gf:ShowSmallTips("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

function SoundMgr:preloadEffect()
    if not DeviceMgr:isAndroid() or not gf:gfIsFuncEnabled(FUNCTION_ID.ENABLE_PRELOAD_SOUND) then return end
    local osVer = DeviceMgr:getOSVer()
    if osVer > "7" then
        -- Android 7上预加载音效
        if not gf:gfIsFuncEnabled(FUNCTION_ID.ARD_SOUND_V20180315) then
        local scheduleId, path, filePath
        local i = 1
        scheduleId = gf:Schedule(function()
            local count = math.min(#SoundPreloadList - i + 1, PRELOAD_COUNT_PER_FRAME)
            if count <= 0 then
                if scheduleId then
                    gf:Unschedule(scheduleId)
                    scheduleId = nil
                end
                return
            end

            for j = 1, count do
                path = ResMgr:getSoundFilePath(SoundPreloadList[i])
                filePath = cc.FileUtils:getInstance():fullPathForFilename(path)
                local pos, len = string.find(filePath, "assets/");
                if pos and len then
                    filePath = string.sub(filePath, pos + len);
                end

                callJavaFun("preloadEffectEx", "(Ljava/lang/String;)V", { filePath })
                i = i + 1
            end
        end, 0)
        else
            local filePath
            for i = 1, #SoundPreloadList do
                filePath = ResMgr:getSoundFilePath(SoundPreloadList[i])
                AudioEngine.preloadEffect(filePath)
    end
        end
    end
end

function SoundMgr:update()
    -- 每隔一段时间，清除保存的过期音效数据
    local nowTime = gfGetTickCount()
    if nowTime - self.lastTime < cleanSoundDataInterval then
        return
    end

    for k, v in pairs(soundIsPlaying) do
        if nowTime - v > cleanSoundDataInterval then
            soundIsPlaying[k] = nil
        end
    end

    for k, v in pairs(dubbingIsPlaying) do
        if nowTime - v > cleanSoundDataInterval then
            dubbingIsPlaying[k] = nil
        end
    end

    for k, v in pairs(hintIsPlaying) do
        if nowTime - v > cleanSoundDataInterval then
            hintIsPlaying[k] = nil
        end
    end

    self.lastTime = nowTime
end

function SoundMgr:readCfg()
    -- 读取配置文件
    local userDefault = cc.UserDefault:getInstance()

    -- 音量
    musicVolumeValue  = userDefault:getFloatForKey("musicValue", 0.5)
    soundVolumeValue = userDefault:getFloatForKey("soundValue", 1)

    -- 是否打开
    musicOn = userDefault:getBoolForKey("musicOn", true)
    soundOn = userDefault:getBoolForKey("soundOn", true)
    dubbingOn = userDefault:getBoolForKey("dubbingOn", true)
    hintOn = userDefault:getBoolForKey("hintOn", true)

    self:setMusicVolumeValue(musicVolumeValue)
    self:setSoundVolumeValue(soundVolumeValue)

    if musicOn == true then
        self:resumeMusic()
    else
        self:pauseMusic()
    end

    if soundOn == true then
        self:resumeSound()
    else
        self:pauseSound()
    end

    if dubbingOn == true then
        self:resumeDubbing()
    else
        self:stopDubbing()
    end

    if hintOn == true then
        self:resumeHint()
    else
        self:stopHint()
    end
end

-- 取得声音
function SoundMgr:getSoundByKey(key)
    local info = SoundInfo[key]
    if nil == info then
        return
    end

    return info
end

-- 设置音量
function SoundMgr:setMusicVolumeValue(value)
    -- 暂存音量值
    musicVolumeValue = value
    AudioEngine.setMusicVolume(musicVolumeValue)
end

function SoundMgr:setSoundVolumeValue(value)
    soundVolumeValue = value
    AudioEngine.setEffectsVolume(soundVolumeValue)
end

function SoundMgr:setSoundVolumeValueByType(soundType, value)
    volumeByType[soundType] = value
    local sounds = self:getSoundEffectByType(soundType)
    for k, v in pairs(sounds) do
        AudioEngine.setEffectVolume(k, value)
    end
end

function SoundMgr:getLastBGMusicFileName()
    return lastBGMusicFileName
end

function SoundMgr:setLastBGMusicFileName(fileName)
    lastBGMusicFileName = fileName
end

-- 播放背景音乐
-- bStartImmediately：是否立即执行
function SoundMgr:playMusic(soundKey, bStartImmediately, fromPos)
    -- 取得声音文件名
    local musicFileName = SoundMgr:getSoundByKey(soundKey)

    if musicFileName == nil then
        -- 没有声音文件
        return
    end

    -- 声音没改变
    if musicFileName == lastBGMusicFileName and not self.toBePlayBGMusicFile then
        return
    end

    if false == musicOn or false == self.isCanPlaySound then
        -- 声音处于关闭状态，记录将要播放的音乐
        self.toBePlayBGMusicFile = soundKey
        return
    end

    -- 记录上次的声音文件
    lastBGMusicFileName = musicFileName
    self.toBePlayBGMusicFile = nil

    -- 播放声音文件
    AudioEngine.playMusic(ResMgr:getSoundFilePath(musicFileName), true)
    if fromPos and fromPos > 0 then
        performWithDelay(gf:getUILayer(), function()    -- WDSY-1655延迟一帧原因详见任务
            if 'function' == type(AudioEngine.seekMusic) then
                AudioEngine.seekMusic(fromPos)
            elseif 'function' == type(cc.SimpleAudioEngine:getInstance().seekMusic) then
                cc.SimpleAudioEngine:getInstance():seekMusic(pos)
            end
        end, 0)
    end

    if bStartImmediately == true then
        -- 立即播放
        AudioEngine.setMusicVolume(musicVolumeValue)
        bgStartPlayTime = 0
    else
        -- 音量从 0 开始
        AudioEngine.setMusicVolume(0.0)
        -- 取得当前时间
        bgStartPlayTime = gfGetTickCount()
    end
end

-- 播放战斗场景背景音乐
function SoundMgr:playFightingBackupMusic()
    -- 随机一首背景音乐
    local index = math.random(1, 2)

    -- 播放背景文件
    SoundMgr:playMusic("fight"..index, true)
    --AudioEngine.setMusicVolume(musicVolumeValue)
end

-- 获取背景音乐播放位置
function SoundMgr:getMusicPostion()
    return AudioEngine.getMusicPostion()
end

-- 获取背景音乐时长
function SoundMgr:getMusicDuration()
    return AudioEngine.getMusicDuration()
end

-- 播放技能音效
function SoundMgr:playSkillEffect(magic, delayTime)
    local soundInfo = self:getSoundByKey(magic)
    if soundInfo then
        if 'table' == type(soundInfo) then
            local fileName = tostring(soundInfo[1])
            local delay = tonumber(soundInfo[2]) + (tonumber(delayTime) or 0)
            if delay and delay > 0 then
                -- 有延时，需要延时播放
                performWithDelay(gf:getUILayer(), function()
                    self:playEffectByFileName(fileName)
                end, delay)
            else
                -- 直接播放
                self:playEffectByFileName(fileName)
            end
        else
            local delay = (tonumber(delayTime) or 0)
            if delay and delay > 0 then
                -- 有延时，需要延时播放
                performWithDelay(gf:getUILayer(), function()
                    self:playEffectByFileName(tostring(soundInfo))
                end, delay)
            else
                -- 直接播放
                self:playEffectByFileName(tostring(soundInfo))
            end
        end
    end
end

-- 播放音效
function SoundMgr:playEffect(effectName, delay, callback)
    local effectFileName = self:getSoundByKey(effectName)
    local _delay = tonumber(delay) or 0
    if _delay > 0 then
        performWithDelay(gf:getUILayer(), function()
            local soundId = self:playEffectByFileName(effectFileName)
            if callback then callback(soundId) end
        end, _delay)
    else
        local soundId = self:playEffectByFileName(effectFileName)
        if callback then callback(soundId) end
    end
end

function SoundMgr:getSoundLength(key)
    if not key then return cleanSoundDataInterval end
    return SoundLength[key] or cleanSoundDataInterval
end

function SoundMgr:beginSound(key)
    if soundPlayList then
        local list = soundPlayList[key]
        if not list then return end
        local item
        local now = gfGetTickCount()
        local duration = self:getSoundLength(key)
        for key, value in pairs(list) do
            if value and value + duration < now then
                AudioEngine.stopEffect(key)
                list[key] = nil
            end
        end
    end
end

function SoundMgr:endSound(key, soundId)
    soundPlayList = soundPlayList or {}
    local list = soundPlayList[key]
    if not list then
        list = {}
        soundPlayList[key] = list
    end
    list[soundId] = gfGetTickCount()
end

function SoundMgr:playEffectByFileName(effectFileName)
    if effectFileName == nil then
        return
    end

    if soundOn == false or self.isCanPlaySound == false or self.canNotPlayEffect then
        return
    end

    self:beginSound(effectFileName)
    self:setSoundVolumeValue(soundVolumeValue)
    local soundId = AudioEngine.playEffectWithVolume(ResMgr:getSoundFilePath(effectFileName), false, volumeByType[SOUND_TYPE.SOUND] or 1)

    -- 记录正在播放的一般音效
    soundIsPlaying[soundId] = gfGetTickCount()
    self:endSound(effectFileName, soundId)

    return soundId
end

-- 播放提示音
function SoundMgr:playHint(effectName)
    local effectFileName = self:getSoundByKey(effectName)
    if effectFileName == nil then
        return
    end

    if hintOn == false or self.isCanPlaySound == false or self.canNotPlayEffect then
        return
    end

    self:beginSound(effectFileName)
    self:setSoundVolumeValue(soundVolumeValue)
    local hintId = AudioEngine.playEffectWithVolume(ResMgr:getSoundFilePath(effectFileName), false, volumeByType[SOUND_TYPE.HINT] or 1)

    -- 记录正在播放的一般音效
    hintIsPlaying[hintId] = gfGetTickCount()
    self:endSound(effectFileName, hintId)
    return hintId
end

-- 播放配音
function SoundMgr:playNpcEffect(effectName)
    local fileName = effectName .. ".mp3"
    if dubbingOn == false or self.isCanPlaySound == false or self.canNotPlayEffect then
        return
    end

    self:beginSound(fileName)
    self:setSoundVolumeValue(soundVolumeValue)
    local dubbingId = AudioEngine.playEffectWithVolume(ResMgr:getSoundFilePath(fileName), false, volumeByType[SOUND_TYPE.DUBBING] or 1)

    -- 记录正在播放的配音
    dubbingIsPlaying[dubbingId] = gfGetTickCount()
    self:endSound(fileName, dubbingId)
    return dubbingId
end

function SoundMgr:stopEffectById(id)
    if not id then return end
    AudioEngine.pauseEffect(id)
end

function SoundMgr:stopEffectExById(id)
    if not id then return end
    AudioEngine.stopEffect(id)
end

-- 持续更新时间
function SoundMgr:changingMusicValue()
    if bgStartPlayTime == 0 then
        return
    end

    if AudioEngine.getMusicVolume() >= musicVolumeValue then
        -- 已经是最大音量
        bgStartPlayTime = 0
        return
    end

    local currentTime = gfGetTickCount()

    -- 设置音量
    AudioEngine.setMusicVolume((currentTime - bgStartPlayTime) / 3000 * musicVolumeValue)
end

function SoundMgr:changeMusicVolumeValue(value)
    if value < 0 then
        value = 0.0
    end

    if value > 1 then
        value = 1
    end

    musicVolumeValue = value
    AudioEngine.setMusicVolume(value)
end

function SoundMgr:changeSoundVolumeValue(value)
    if value < 0 then
        value = 0.0
    end

    if value > 1 then
        value = 1
    end

    soundVolumeValue = value
    AudioEngine.setEffectsVolume(soundVolumeValue)
end

function SoundMgr:isMusicOn()
    return musicOn
end

function SoundMgr:isDubbingOn()
    return dubbingOn
end

function SoundMgr:isSoundOn()
    return soundOn
end

function SoundMgr:pauseMusic()
    AudioEngine.pauseMusic()
    musicOn = false
end

function SoundMgr:pauseSound()
    SoundMgr:pauseSoundEffectByType(SOUND_TYPE.SOUND)
    -- AudioEngine.pauseAllEffects()
    soundOn = false
end

function SoundMgr:stopDubbing()
    SoundMgr:stopSoundEffectByType(SOUND_TYPE.DUBBING)
    dubbingOn = false
end

function SoundMgr:stopHint()
    SoundMgr:stopSoundEffectByType(SOUND_TYPE.HINT)
    hintOn = false
end

function SoundMgr:resumeMusic()
    musicOn = true
    if self.toBePlayBGMusicFile then
        self:playMusic(self.toBePlayBGMusicFile, true)
    end
    AudioEngine.resumeMusic()
end

function SoundMgr:resumeSound()
    SoundMgr:resumeSoundEffectByType(SOUND_TYPE.SOUND)
    -- AudioEngine.resumeAllEffects(soundVolumeValue)
    soundOn = true
end

function SoundMgr:resumeDubbing()
    SoundMgr:resumeSoundEffectByType(SOUND_TYPE.DUBBING)
    dubbingOn = true
end

function SoundMgr:resumeHint()
    SoundMgr:resumeSoundEffectByType(SOUND_TYPE.HINT)
    hintOn = true
end

-- 语音播放需要停止音乐
function SoundMgr:stopMusic()
    if musicOn then
        AudioEngine.pauseMusic()
    end
end

-- 语音播放完后需要恢复音乐
function SoundMgr:replayMusic()
    if musicOn then
        self:resumeMusic()
    end
end

-- 语音播放需要停止全部音效（包括配音）
function SoundMgr:stopSound()
    if soundOn or dubbingOn or hintOn then
        AudioEngine.pauseAllEffects()
    end
end

-- 停止播放当前全部音效（包括配音）
function SoundMgr:stopCurAllSound()
    AudioEngine.stopAllEffects()
end

function SoundMgr:stopSoundEX()
    SoundMgr:stopSoundEffectByType(SOUND_TYPE.SOUND)
    -- AudioEngine.stopAllEffects()
    soundOn = false
end

-- 语音播放完后需要恢复音效
function SoundMgr:replaySound()
    if soundOn then
        SoundMgr:resumeSoundEffectByType(SOUND_TYPE.SOUND)
        -- AudioEngine.resumeAllEffects(soundVolumeValue)
    end
end


-- 语音播放完后需要恢复配音
function SoundMgr:replayDubbing()
    if dubbingOn then
        SoundMgr:resumeSoundEffectByType(SOUND_TYPE.DUBBING)
    end
end

-- 语音播放完后需要恢复提示音
function SoundMgr:replayHint()
    if hintOn then
        SoundMgr:resumeSoundEffectByType(SOUND_TYPE.HINT)
    end
end

-- 停止音乐和音效
function SoundMgr:stopMusicAndSound()
    self.isCanPlaySound = false
    self:stopMusic()

    -- 停止所有音效（包括配音和提示音）
    self:stopSound()
end

-- 恢复音乐和音效
function SoundMgr:replayMusicAndSound()
    self.isCanPlaySound = true
    self:replayMusic()
    self:replaySound()
    self:replayDubbing()
    self:replayHint()
end

function SoundMgr:getSoundEffectByType(type)
    if type == SOUND_TYPE.SOUND then
        return soundIsPlaying
    elseif type == SOUND_TYPE.DUBBING then
        return dubbingIsPlaying
    else
        return hintIsPlaying
    end
end

-- 恢复指定类型的音效（一般音效/NPC配音/提示音）
function SoundMgr:resumeSoundEffectByType(type)
    for k, v in pairs(self:getSoundEffectByType(type)) do
        AudioEngine.resumeEffect(k)
    end
end

-- 暂停指定类型的音效（一般音效/NPC配音/提示音）
function SoundMgr:pauseSoundEffectByType(type)
    for k, v in pairs(self:getSoundEffectByType(type)) do
        AudioEngine.pauseEffect(k)
    end
end

-- 中止指定类型的音效（一般音效/NPC配音/提示音）
function SoundMgr:stopSoundEffectByType(type)
    for k, v in pairs(self:getSoundEffectByType(type)) do
        AudioEngine.stopEffect(k)
    end
end

function SoundMgr:stopSoundEffectBySoundId(key, soundId)
    if soundPlayList then
        key = self:getSoundByKey(key)
        local list = soundPlayList[key]
        if not list then return end
        for key, value in pairs(list) do
            if soundId == key then
                AudioEngine.stopEffect(soundId)
                list[key] = nil
                break
            end
        end
    end
end

-- 屏蔽音效，目前用于创建角色战斗结束播放字幕时使用
function SoundMgr:setCanNotPlayEffect(canNotPlayEffect)
    if canNotPlayEffect then
        self.canNotPlayEffect = true
    else
        self.canNotPlayEffect = false
    end
end

-- 重新在如音效配置
-- 仅用于音效配置测试时使用
function SoundMgr:reloadSoundCfg()
    package.loaded[ResMgr:getCfgPath('Sound.lua')] = nil
    SoundInfo = require(ResMgr:getCfgPath('Sound.lua'))
end


--[[
    -- 调用 java 函数
local callJavaFun = function(className, fun, sig, args)
    local luaj = require('luaj')
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        Log:E("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end
]]

local callJavaFunForGoodVoice = function(fun, sig, args)
    local luaj = require('luaj')
    local ok, ret = luaj.callStaticMethod("com/gbits/RecordHelper", fun, args, sig)
    if not ok then
        gf:ShowSmallTips("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 调用ios函数
local callOCFunForGoodVoice = function (fun, ...)
    local luaoc = require('luaoc')
    local ok = nil
    local arg = { ... }
    local ret = nil

    local t = {}
    for i, v in ipairs(arg) do
        t[string.format("arg%d", i)] = v
    end

    if #arg > 0 then
        ok, ret = luaoc.callStaticMethod("RecordHelper", fun, t)
    else
        ok, ret = luaoc.callStaticMethod("RecordHelper", fun)
    end

    if ok then
        return ret
    else
        Log:I('fun: ' .. fun .. ' ret: ' .. ret)
    end
end

function onGoodVoiceRecordEvent(eventType)
    if 1 == tonumber(eventType) then
        -- 录音停止
        if not DlgMgr:getDlgByName("GoodVoiceMineDlg") then
            os.remove(SoundMgr.curMediaFileForGV)
        else
            DlgMgr:sendMsg("GoodVoiceMineDlg", "onEndRecordCallBack")
        end
        SoundMgr.curMediaFileForGV = nil
    end
end

--[[
    function SoundRecordDlg:onBeginButton(sender, eventType)
    self.isRecording = nil
    -- if not ChatMgr:beginRecord(sender, self, 90, self.quality, true, false) then return end
    self.curMediaFile = callJavaFun("com/gbits/RecordHelper", "getSavePath", "(Ljava/lang/String;)Ljava/lang/String;", { "my.mp3" })
    Log:I(">>>>>>>>>>>>curMusic:%s", self.curMediaFile)
    callJavaFun("com/gbits/RecordHelper", "beginRecord", "(Ljava/lang/String;IILjava/lang/String;)V", { self.curMediaFile, 44100, 5, "onRecordEvent" })

    self:setCtrlVisible("SoundPanel1", false)
    self:setCtrlVisible("SoundPanel2", true)
    self:setCtrlVisible("SoundPanel3", false)
    SoundMgr:stopMusicAndSound()

    self.isRecording = true
end
]]

function SoundMgr:beginRecordForGoodVoice(fileName, isReBegin)

   if not gf:checkPermission("Record", "SoundMgr:beginRecordForGoodVoice", nil, function() gf:gotoSetting("Record") end) then return false end


    local function beginRecord( )
        if SoundMgr.curMediaFileForGV then
            gf:ShowSmallTips(CHS[3003948])
            return false
        end

    --  SoundMgr.isRecordingForGV = true
        SoundMgr.curMediaFileForGV = nil

        local backup = gf:getShowId(Me:queryBasic("gid")) .. gf:getServerTime() .. ".mp3"
        fileName = fileName or backup

        SoundMgr:stopMusicAndSound()

        local ok, ret
        if gf:isAndroid() then
            SoundMgr.curMediaFileForGV = callJavaFunForGoodVoice("getSavePath", "(Ljava/lang/String;)Ljava/lang/String;", { fileName })
            ok, ret = callJavaFunForGoodVoice("beginRecord", "(Ljava/lang/String;IILjava/lang/String;)V", { SoundMgr.curMediaFileForGV, 44100, GD_QUALITY, "onGoodVoiceRecordEvent" })

        elseif gf:isIos() then
            SoundMgr.curMediaFileForGV = callOCFunForGoodVoice("getSavePath", fileName)
            ok, ret = callOCFunForGoodVoice("beginRecord", SoundMgr.curMediaFileForGV, 44100, GD_QUALITY, "onGoodVoiceRecordEvent" )
        else
            return false
        end

        DlgMgr:sendMsg("GoodVoiceMineDlg", "waitForSoundMgrBeginOK")
        return true
    end

    if isReBegin then
        beginRecord()
    else
        gf:confirm(CHS[4300508], function ()
            -- body
            beginRecord()
        end)
    end


end

function SoundMgr:getMusicDurationByNameForGoodVoice(filePath)
    local duration = 0
    if gf:isAndroid() then
        duration = callJavaFunForGoodVoice("getDuration", "(Ljava/lang/String;)I", { filePath })
    elseif gf:isIos() then
        duration = callOCFunForGoodVoice("getDuration", filePath)
    else
        return 10000
    end

    duration = math.min(duration, 60000)

    return duration
end

function SoundMgr:endRecordForGoodVoice()
    if gf:isAndroid() then
        callJavaFunForGoodVoice("endRecord", "()V", { })
    elseif gf:isIos() then
        callOCFunForGoodVoice("endRecord")
    else
        return false
    end
end


-- 初始化
SoundMgr:init()


return SoundMgr
