-- ScreenRecordMgr.lua
-- Created by sujl, Mar/10/2016
-- 游戏录屏管理器

ScreenRecordMgr = Singleton()

-- 调用 java 函数
local callJavaFun = function(fun, sig, args)
    local luaj = require('luaj')
    local className = 'com/gbits/ScreenRecordHelper'
    local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
    if not ok then
        gf:ShowSmallTips("call java function:" .. fun .. " failed!")
    else
        return ret
    end
end

-- 调用ios函数
local callOCFun = function (fun, args)
    local luaoc = require('luaoc')
    local ok = nil

    if args then
        ok, ret = luaoc.callStaticMethod('ReplayKitProxy', fun, args)
    else
        ok, ret = luaoc.callStaticMethod('ReplayKitProxy', fun)
    end

    if not ok then
        gf:ShowSmallTips("call oc function:" .. fun .. " failed!")
    else
        return ret
    end
end

function onStartRecordingCB(error)
    Log:D("onStartRecordingCB")

    local isOn = true
    if (gf:isIos() and -5801 == error) or (gf:isAndroid() and "1" == error) then
        gf:ShowSmallTips(CHS[3004305])
        isOn = false
    end

    local dlg = DlgMgr:getDlgByName("ScreenRecordingDlg")
    if dlg then
        dlg:onStartRecord(isOn)
    end

    if ScreenRecordMgr.androidStartAction then
        gf:getUILayer():stopAction(ScreenRecordMgr.androidStartAction)
        ScreenRecordMgr.androidStartAction = nil
    end
end

function onStopRecordingCB(msg)
    Log:D("onStopRecordingCB")

    local dlg = DlgMgr:getDlgByName("ScreenRecordingDlg")
    if dlg then
        dlg:onStopRecord(msg)
    end
end

-- 开始录制
function ScreenRecordMgr:startRecord()
    if gf:isAndroid() then
        self:startAndroidRecord()
    elseif gf:isIos() then
        self:startiOSRecord()
    else
        self.recording = true
    end
end

-- 停止录制
function ScreenRecordMgr:stopRecord()
    if gf:isAndroid() then
        self:stopAndroidRecord()
    elseif gf:isIos() then
        self:stopiOSRecord()
    else
        self.recording = false
    end
end

-- 是否支持录屏
function ScreenRecordMgr:supportRecordScreen()
    if gf:isAndroid() then
        return self:supportAndroidRecord()
    elseif gf:isIos() then
        return self:supportiOSRecord()
    else
        return false
    end
end

-- 是否在录制中
function ScreenRecordMgr:isRecording()
    if gf:isAndroid() then
        return self:supportRecordScreen() and self:isAndroidRecording()
    elseif gf:isIos() then
        return self:isiOSRecording()
    else
        return self.recording
    end
end

-- 是否支持Android录屏功能
function ScreenRecordMgr:supportAndroidRecord()
    return gf:gfIsFuncEnabled(FUNCTION_ID.ANDROID_RECORD_SCR) and callJavaFun("isSupportReplay", "()Z")
end

-- 是否支持iOS录屏功能
function ScreenRecordMgr:supportiOSRecord()
    return callOCFun("isSupportReplay")
end

-- 开始Android录制
function ScreenRecordMgr:startAndroidRecord()
    callJavaFun("startRecording", "()V")
    self.androidStartAction = performWithDelay(gf:getUILayer(), function()
        onStartRecordingCB("1")
    end, 3)
end

-- 开始iOS录制
function ScreenRecordMgr:startiOSRecord()
    callOCFun("startRecording")
end

-- 停止Android录制
function ScreenRecordMgr:stopAndroidRecord()
    callJavaFun("stopRecording", "()V")
end

-- 停止iOS录制
function ScreenRecordMgr:stopiOSRecord()
    callOCFun("stopRecording")
end

-- 是否正处于录制中(iOS)
function ScreenRecordMgr:isiOSRecording()
    return callOCFun("isRecording")
end

-- 是否正处于录制中(Android)
function ScreenRecordMgr:isAndroidRecording()
    return callJavaFun("isRecording", "()Z")
end