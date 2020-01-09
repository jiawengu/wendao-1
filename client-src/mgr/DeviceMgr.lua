-- DeviceMgr.lua
-- Created by chenyq Sep/29/2015
-- 设备信息管理器

local json = require('json')
local PLATFORM_CONFIG = require("PlatformConfig")
local platform = cc.Application:getInstance():getTargetPlatform()

-- 版本号
local CUR_VERSION = PLATFORM_CONFIG.CUR_VERSION

-- 此文件在更新阶段会调用，故不能使用 Singleton()
DeviceMgr = {}

local FUNC_ID = {
    NOTACH_CHECK_V1         = 37,-- 刘海屏检测支持
    NOTACH_CHECK_AP         = 39,-- Android P刘海屏检测支持
}

-- 已知的模拟器包名
local EMULATOR_PACAKGENAME = {
    "com.haimawan.push",
    "com.blue.huang17.agent",
    "com.buxiubianfu.IME",
    "com.tiantian.ime",
    "com.tencent.tinput",
    "cn.yzz.app.launcher",
    "com.qm.serverime",
    "com.xiaopi.appstatechange",
    "com.youxin.collect",
    "com.android.emu.inputservice",
    "com.kapou.launcher",
    "com.fiftyone",
    "com.yiwan.service",
    "com.yiwan.sea_ime.SeaIme",
    "cn.itools.vm.softkeyboard",
}

-- 已知的模拟的路径
local EMULATOR_PATH = {
    "/data/data/com.bluestacks.home/",
    "/data/data/com.bignox.app.store.hd/",
    "/sdcard/Android/data/com.bluestacks.home/",
    "system/etc/xxzs_prop.sh",
    "/system/app/ldAppStore",
    "/mnt/USB3",
    "/sdcard/Android/data/com.bignox.app.store.hd",
    "/system/app/ldAppStore2",
    "/sdcard/.51service",
    "/storage/emulated/0/BigNoxGameHD",
    "/storage/emulated/0/$MuMu共享文件夹",
    "/storage/sdcard/.51service",
    "/storage/6868-79D1/windows/BstSharedFolder",
    "/storage/emulated/0/Android/data/com.microvirt.guide",
}

-- 调用对应平台的函数
local callPlatformFun = function(fun)
    local v = fun .. ":nil"
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()Ljava/lang/String;"
        local args = {}
        local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
        if ok then
            v = ret
        end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok, ret = luaoc.callStaticMethod('AppController', fun)
        if ok then
            v = ret
        end
    end

    Log:I('fun: ' .. fun .. ' ret: ' .. v)
    return v
end


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

-- 调用 iOS SDK 函数
local callOCSdkFun = function (cls, fun, args)
    local luaoc = require('luaoc')
    local ok, ret = luaoc.callStaticMethod(cls, fun, args)
    if not ok then
        return "fail"
    end

    -- Log:I('callOCFun %s, ret: %s', fun, tostring(ret))
    return ret
end

-- 是否为 android pad
function DeviceMgr:isAndroidPad()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local sig = '()I'
        local args = {}
        local className = 'org/cocos2dx/lua/AppActivity'
        local methodName = 'getScreenSize'
        local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
        if ok and ret > 70 then
            -- 大于 7 寸则认为是 pad
            return true
        end
    end

    return false
end

-- 是否android平台
function DeviceMgr:isAndroid()
    if platform == cc.PLATFORM_OS_ANDROID then
        return true
    end
    return false
end

-- 是否ios平台
function DeviceMgr:isIos()
    if platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        return true
    end
    return false
end

-- 打开浏览器
function DeviceMgr:openUrl(url)
    local fun = 'openUrl'
    local v = fun .. ":nil"
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(Ljava/lang/String;)V"
        local args = {}
        args[1] = url
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local args = {url = url}
        local ok = luaoc.callStaticMethod('AppController', fun, args)
        v = tostring(ok)
    end
end

-- 是否为 pad
function DeviceMgr:isPad()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local sig = '()I'
        local args = {}
        local className = 'org/cocos2dx/lua/AppActivity'
        local methodName = 'getScreenSize'
        local ok, ret = luaj.callStaticMethod(className, methodName, args, sig)
        if ok and ret > 70 then
            -- 大于 7 寸则认为是 pad
            return true
        end
    elseif platform == cc.PLATFORM_OS_IPAD then
        return true
    end

    return false
end

-- 获取 mac 信息
function DeviceMgr:getMac()
    return callPlatformFun('getMac')
end

-- 获取操作系统版本
function DeviceMgr:getOSVer()
    return callPlatformFun('getOSVer')
end

-- 获取终端型号
function DeviceMgr:getTermInfo()
    local termInfo = callPlatformFun('getTermInfo')
    if string.find(termInfo, "emulator-") or (self.checkEmulator and self:checkEmulator()) then
        return "0:" .. termInfo
    else
        return "1:" .. termInfo
    end
end

-- 获取 android imei 信息
function DeviceMgr:getImei()
    return callPlatformFun('getImei')
end

function DeviceMgr:getSerialno()
    if self:isAndroid() then
        return callPlatformFun('getSerialno')
    end

    return ""
end

function DeviceMgr:getAndroidId()
    if self:isAndroid() then
        return callPlatformFun('getAndroidId')
    end

    return ""
end

function DeviceMgr:getChannelNO()
    if not self.channelNO then
        if self:isAndroid() then
            self.channelNO = callJavaFun('com/gbits/LeitingSdkHelper', "getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { 'channelType' })
        elseif self:isIos() then
            self.channelNO = callOCSdkFun('LeitingSdkHelper', "getPropertiesValue", {name='CHANNEL_NO'})
        end
    end

    return self.channelNO or ""
end

function DeviceMgr:getMedia()
    if not self.media then
        if self:isAndroid() then
            self.media = callJavaFun('com/gbits/LeitingSdkHelper', "getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { 'media' })
        elseif self:isIos() then
            self.media = ""
        end
    end

    return self.media or ""
end

-- 尝试发送激活日志，如果日志已发送过，则不再发送
function DeviceMgr:tryToSendActivateLogIfNeed()
    if (self:isAndroid() and 'function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(40)) or
        ('function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(41)) then
        return
    end

    local userDefault = cc.UserDefault:getInstance()
    local flag = userDefault:getStringForKey('activated', '0')
    if flag ~= '0' then
        return
    end

    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('POST', PLATFORM_CONFIG.LOG_URL, false)

    local key = PLATFORM_CONFIG.LOG_KEY
    local gameCode = 'wd'
    local createDate = os.date("%Y-%m-%d %H:%M:%S")
    local sign = string.lower(gfGetMd5(gameCode .. key .. createDate))
    local imei = self:getImei()
    if platform == cc.PLATFORM_OS_ANDROID then
        -- android 下 imei 有可能为空，为了方便去重，此处需要添加额外信息
        imei = imei .. '|' .. self:getSerialno() .. '|' .. self:getAndroidId()
    end

    local data = {
        gameType = "1",
        gameCode = gameCode,
        sign = sign,
        createDate = createDate,
        osVer = self:getOSVer(),
        terminInfo = self:getTermInfo(),
        mac = self:getMac(),
        imei = imei,
        channel = self:getChannelNO(),
        media = self:getMedia(),
        clientVer = CUR_VERSION,
    }

    local function onReadyStateChange()
        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send('params=' .. json.encode(data))

    userDefault:setStringForKey('activated', '1')
end

-- 获取设备内存
function DeviceMgr:getTotalMemory()
    if self.totalMemory then return self.totalMemory end

    if not self:checkRequireVersion("1.02p.0901", "1.02p.0901") then
        if self:isIos() then
            self.totalMemory = tonumber(callPlatformFun("getTotalMemory"))
        end
    else
        self.totalMemory = tonumber(callPlatformFun("getTotalMemory"))
    end

    return self.totalMemory
end

-- 获取设备可用内存
function DeviceMgr:getAvailMemory()
    if not self:checkRequireVersion("1.02p.0901", "1.02p.0901") then return end
    return tonumber(callPlatformFun("getAvailMemory"))
end

-- 获取设备型号
function DeviceMgr:getDeviceString()
    if self:isIos() then
        return callPlatformFun("getDeviceString")
    else
        return callPlatformFun('getTermInfo')
    end
end

-- 是否处于低内存
function DeviceMgr:isLowMemory(immediately)
    local availMem = DeviceMgr:getAvailMemory()
    local totalMem = DeviceMgr:getTotalMemory()

    availMem = availMem and tonumber(availMem) or 0
    totalMem = totalMem and tonumber(totalMem) or 0

    if availMem > 0 and totalMem > 0 and availMem / totalMem < 0.03 then
        return true
    else
        return false
    end
end

-- 获取进程信息
function DeviceMgr:getProcessList()
    if self:isAndroid() then
        return callPlatformFun('getProcessList')
    else
        return ""
    end
end

local function getVersionValue(version)
    local b, e, ver = string.find(version, "^(%d+%.%d+)")
    if ver then
        local versionData = {}
        string.gsub(version, '[^.]+', function(w) table.insert(versionData, w) end)
        if versionData and #versionData >= 3 then
            return ver, versionData[3]
        else
            return ver, "0"
        end
    end

    return "0", "0"
end

local function getCurrentVer()
    return cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
end

function DeviceMgr:getOriginalVer()
    return CUR_VERSION
end

function DeviceMgr:isReviewVer()
    if not DistMgr then return false end
    local defaultInfo = DistMgr:getDefaultInfo()
    if defaultInfo and gf:isIos() and defaultInfo.review_ver == DeviceMgr:getOriginalVer() then
        return true
    else
        return false
    end
end

function DeviceMgr:isEmulator()
    if nil ~= self.runInEmulator then return self.runInEmulator end

    if self:isAndroid() then
        self.runInEmulator = DeviceMgr:checkEmulator()
    else
        self.runInEmulator = false
    end

    return self.runInEmulator
end

-- 检查版本
-- verPublic:公测版本
-- verInternal:内测版本
function DeviceMgr:checkRequireVersion(verPublic, verInternal)
    local ver1, ver2 = getVersionValue(CUR_VERSION)
    local isTestDist = DistMgr and DistMgr:isTestDist(GameMgr:getDistName())
    local _ver1, _ver2
    if isTestDist then
        _ver1, _ver2 = getVersionValue(verInternal)
    else
        _ver1, _ver2 = getVersionValue(verPublic)
    end

    return ver1 > _ver1 or (ver1 == _ver1 and ver2 >= _ver2)
end

function DeviceMgr:doPatch()
    if self:isAndroid() then
        callJavaFun('org/cocos2dx/lua/AppActivity', "tryPatch", "()V", {})
    end
end

-- 获取安装包的MD5
function DeviceMgr:getPackageMD5()
    if not gf:gfIsFuncEnabled(FUNCTION_ID.GET_PACKAGE_MD5) then return end

    return callPlatformFun("getPackageMd5")
end

-- 获取签名信息
function DeviceMgr:getSignInfo()
    if not gf:gfIsFuncEnabled(FUNCTION_ID.GET_SIGN_INFO) then return end

    return callPlatformFun("getSignInfo")
end

-- 是否可以使用QQ
function DeviceMgr:isQQAvailable()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(Ljava/lang/String;)Z"
        local args = {}
        args[1] = "com.tencent.mobileqq"
        local ok, v = luaj.callStaticMethod(className, 'isAppAvailable', args, sig)
        if ok then return v end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local args = {url = "mqq://"}
        local ok, v = luaoc.callStaticMethod('AppController', 'canOpenURL', args)
        if ok then return v end
    end
end

-- 应用是否可用
function DeviceMgr:isAppAvailable(packageName)
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(Ljava/lang/String;)Z"
        local args = {}
        args[1] = packageName
        local ok, v = luaj.callStaticMethod(className, 'isAppAvailable', args, sig)
        if ok then return v end
    end
end

function DeviceMgr:showCapture(callback)
    if self:isAndroid() then
        callJavaFun('org/cocos2dx/lua/AppActivity', "showCapture", "(Ljava/lang/String;)V", {callback})
    elseif self:isIos() then
        callOCSdkFun("AppController", "showCapture", {arg1=callback})
    end
end

function DeviceMgr:getPackageName()
    if self:isAndroid() then
        local path = cc.FileUtils:getInstance():getWritablePath()
        if path then
            local packageName = string.match(path, ".*/(.*)/files")
            return packageName
        end
    end
end

function DeviceMgr:isPackagesInstalled(packages)
    if not self:isAndroid() then return end

    if 'function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(27) then
        local str = self:getInstalledPackages()
        if str then
            local t = json.decode(str)
            local ht = {}
            for i = 1, #t do
                ht[t[i]] = true
            end

            for i = 1, #packages do
                if ht[packages[i]] then
					if Client and 'function' == type(Client.pushDebugInfo) then
						Client:pushDebugInfo('emulator-installed package: ' .. packages[i])
					end
					self.emuCheckInfo = 'emulator-installed package: ' .. packages[i]
                    return true
                end
            end
        end
    else
        local function isIntsall(name)
            local luaj = require('luaj')
            local className = 'org/cocos2dx/lua/AppActivity'
            local sig = "(Ljava/lang/String;)Z"
            local args = {}
            args[1] = name
            local ok, v = luaj.callStaticMethod(className, 'isAppAvailable', args, sig)
            if ok then return v end
        end

        for i = 1, #packages do
             if isIntsall(packages[i]) then
				if Client and 'function' == type(Client.pushDebugInfo) then
				    Client:pushDebugInfo('emulator-installed package: ' .. packages[i])
				end
				self.emuCheckInfo = 'emulator-installed package: ' .. packages[i]
                return true
            end
        end
    end
end

function DeviceMgr:isFilesExist(files, checkDirectory)
    if not self:isAndroid() then return false end
    local function isExistFile(name)
        local luaj = require('luaj')
        local className = 'com/gbits/patcher/utils/ApkInfoTool'
        local sig = "(Ljava/lang/String;)Z"
        local args = {}
        args[1] = name
        local ok, v = luaj.callStaticMethod(className, 'existsFile', args, sig)
        if ok then return v end
    end

    local function isDirectory(name)
        local luaj = require('luaj')
        local className = 'com/gbits/patcher/utils/ApkInfoTool'
        local sig = "(Ljava/lang/String;)Z"
        local args = {}
        args[1] = name
        local ok, v = luaj.callStaticMethod(className, 'isDirectory', args, sig)
        if ok then return v end
    end

    for i = 1, #files do
        if isExistFile(files[i]) then
            if Client and 'function' == type(Client.pushDebugInfo) then
                Client:pushDebugInfo('emulator-file exist: ' .. files[i])
            end
            self.emuCheckInfo = 'emulator-file exist: ' .. files[i]
            return true
        end
        if checkDirectory and isDirectory(files[i]) then
            if Client and 'function' == type(Client.pushDebugInfo) then
                Client:pushDebugInfo('emulator-isDirectory: ' .. files[i])
            end
            self.emuCheckInfo = 'emulator-isDirectory: ' .. files[i]
            return true
        end
    end
    return false
end


function DeviceMgr:checkEmulator()
    return self:isPackagesInstalled(EMULATOR_PACAKGENAME) or self:isFilesExist(EMULATOR_PATH, true)
end

-- 获取网络状态
function DeviceMgr:getNetWorkStatus()
    if self:isAndroid() then
        local netType = callJavaFun('org/cocos2dx/lua/AppActivity', "GetNetype", "()I")
        if -1 == netType then
            state = 0
        elseif 1 == netType then
            state = 1
        elseif 2 == netType or 3 == netType then
            state = 2
        end
    elseif self:isIos() then
        state = callOCSdkFun('AppController', "getNetWorkStatus")
    else
        state = 1
    end

    return state
end

function DeviceMgr:getOrientation()
    if self:isAndroid() then
        return callJavaFun('org/cocos2dx/lua/AppActivity', "getOrientation", "()I", {})
    elseif self:isIos() then
        return callOCSdkFun("AppController", "getOrientation")
    end
end

function DeviceMgr:getCfgOrientation()
    if not self:isAndroid() then return end
    return callJavaFun('org/cocos2dx/lua/AppActivity', "getCfgOrientation", "()I", {})
end

-- 是否使用红手指
function DeviceMgr:isRedFinger()
    local files = {
        "/data/data/com.redfinger.appstore",
        "/data/data/com.redfinger.launcher",
    }

    return self:isFilesExist(files)
end

-- 是否root
function DeviceMgr:isRoot()
    if not self:isAndroid() then return false end
    local files = {
        "/system/bin/su",
        "/system/xbin/su",
    }

    return callJavaFun('org/cocos2dx/lua/AppActivity', "isRoot", "(Ljava/lang/String;)Z", { json.encode(files) })
end

-- 相机是否可用
function DeviceMgr:checkCameraAuth()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()Z"
        local ok, v = luaj.callStaticMethod(className, 'checkCameraAuth', {}, sig)
        if ok then return v end
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local ok, v = luaoc.callStaticMethod('AppController', 'checkCameraAuth')
        if ok then return v end
    end
end

-- 跳转到权限设置
function DeviceMgr:gotoSetting()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()V"
        luaj.callStaticMethod(className, 'showSetting', {}, sig)
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
    end
end

-- 获取已安装应用列表
function DeviceMgr:getInstalledPackages()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "()Ljava/lang/String;"
        local ok, v = luaj.callStaticMethod(className, 'getInstalledPackages', {}, sig)
        if ok then return v end
    end
end

-- 安卓启动intent
function DeviceMgr:startActivityByIntent(settingName)
    if not gf:gfIsFuncEnabled(FUNCTION_ID.LOCATION_SERVICE) then
        return
    end

    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'org/cocos2dx/lua/AppActivity'
        local sig = "(Ljava/lang/String;)V"
        local args = {[1] = settingName}
        luaj.callStaticMethod(className, 'startActivityByIntent', args, sig)
    end
end

-- 开始日志采集
function DeviceMgr:startLogcat(args)
    local luaj = require('luaj')
    if not args then
        luaj.callStaticMethod("com/gbits/logcat/Logcat", "startLogcat", {}, "()V")
    else
        luaj.callStaticMethod("com/gbits/logcat/Logcat", "startLogcat", { args }, "(Ljava/lang/String;)V")
    end
end

-- 停止日志采集
function DeviceMgr:stopLogcat(filePath)
    local ok
    local luaj = require('luaj')
    ok = luaj.callStaticMethod("com/gbits/logcat/Logcat", "stopLogcat", {}, "()V")
    if not ok then return end
    luaj.callStaticMethod("com/gbits/logcat/Logcat", "dumpLogcat", { filePath }, "(Ljava/lang/String;)V")
end

-- 获取刘海屏高度
function DeviceMgr:getNotchHeight()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getNotchHeight", {}, "()I")
        if ok then return ret end
    end
end

-- 获取DPI
function DeviceMgr:getDensity()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getDensity", {}, "()F")
        if ok then return ret end
    end
end

-- 获取缩放配置
function DeviceMgr:makeUIScale()
    local deviceName = DeviceMgr:getDeviceString()
    if not deviceName or #deviceName <= 0 then return end

    local deviceCfg = require("cfg/UIScaleForDevices")
    local cfg

    if not deviceCfg[deviceName] then
        local displayStr = self:isSMNotch() and self:getDisplayCutoutSM() or self:getDisplayCutout()
        if not displayStr or "" == displayStr then

        local notchHeight = self:getNotchHeight()
        if notchHeight and notchHeight > 0 then
            local director = cc.Director:getInstance()
            local frameSize = director:getOpenGLView():getFrameSize()
                local sw = frameSize["width"]
                local sh = frameSize["height"]
            local scale = 640 / sh
            local width, height = sw * scale, 640
            cfg = {
                scale = 1,
                --ox = notchHeight * scale,
                --oy = 0,
                x = 0,
                y = 0,
                width = width - notchHeight * scale * 2 - 2,
                height = height,
                designWidth = width,
                designHeight = height,
            }
        end
        else
            local cutout = json.decode(displayStr)
            if cutout.rects and #cutout.rects > 0 then
                local director = cc.Director:getInstance()
                local frameSize = director:getOpenGLView():getFrameSize()
                local notchHeight = math.max(cutout.left or 0, cutout.right or 0)
                local sw = frameSize.width
                local sh = frameSize.height
                local scale = 640 / sh
                local width, height = sw * scale, 640
                cfg = {
                    scale = 1,
                    --ox = notchHeight * scale,
                    --oy = 0,
                    x = 0,
                    y = 0,
                    width = width - notchHeight * scale * 2 - 2,
                    height = height,
                    designWidth = width,
                    designHeight = height,
                }
            end
        end

        deviceCfg[deviceName] = cfg
    else
        cfg = deviceCfg[deviceName]
    end

    if cfg then
        cfg.ox = (cfg.designWidth - cfg.width) / 2
        cfg.oy = (cfg.designHeight - cfg.height) / 2
        if cfg.checkWidth then
        -- 设备需要进行容错处理，如果获取的宽度小于检查宽度，则按照非刘海屏处理
        local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
            local frameWidth = 1080 / frameSize["height"] * frameSize["width"]
            if cfg.checkWidth > frameWidth then cfg = nil end
    end
    end

    self.uiScaleCfg = cfg
    self.hasMakeUIScale = true
end

function DeviceMgr:getUIScale()
    if not self.uiScaleCfg and not self.hasMakeUIScale then
        -- 配置生成不成功，再次重试
        self:makeUIScale()

            if self.uiScaleCfg then
                local designResolutionWidth = 960
            local designResolutionHeight = self.uiScaleCfg.designHeight or self:getDesignHeight()
                local designResolutionPolicy  = cc.ResolutionPolicy.FIXED_HEIGHT

                -- resize the design resolution
                cc.Director:getInstance():getOpenGLView():setDesignResolutionSize(designResolutionWidth, designResolutionHeight, designResolutionPolicy)
            end
        end
    return self.uiScaleCfg
end

-- 是否刘海屏
function DeviceMgr:isNotchInScreen()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "isNotchInScreen", {}, "()Z")
        if ok then return ret end
    end
end

-- 是否华为刘海屏
function DeviceMgr:isHWNotchInScreen()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "isHWNotchInScreen", {}, "()Z")
        if ok then return ret end
    end
end

-- 获取设备宽度
function DeviceMgr:getScreenWidth()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getScreenWidth", {}, "()I")
        if ok then
            if self:isHWNotchInScreen() then
                ret = ret + DeviceMgr:getNotchHeight() or 0
            end
            return ret
        end
    end
end

-- 获取设备高度
function DeviceMgr:getScreenHeight()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_V1) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getScreenHeight", {}, "()I")
        if ok then return ret end
    end
end

-- 是否位置的刘海机型
function DeviceMgr:isUnknowNotch()
    return self:isNotchInScreen() and self:getNotchHeight() <= 0 and not DeviceMgr:getUIScale()
end

-- 是否开启某项强更
function DeviceMgr:isFuncEnabled(funcId)
    if 'function' == type(gfIsFuncEnabled) and 'number' == type(funcId) then
        return gfIsFuncEnabled(funcId)
    end

    return false
end

function DeviceMgr:getDesignHeight()
    local director = cc.Director:getInstance()
    local frameSize = director:getOpenGLView():getFrameSize()

    local deviceHeight = frameSize["height"]

    local bPad = self:isPad()
    if bPad and deviceHeight >= 768 then
        designHeight = 768
    else
        designHeight = 640
    end

    return designHeight
end

function DeviceMgr:getDisplayCutout()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_AP) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getDisplayCutout", {}, "()Ljava/lang/String;")
        if ok then return ret end
    end
end

function DeviceMgr:isSMNotch()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_AP) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "isSMNotch", {}, "()Z")
        if ok then return ret end
    end
end

function DeviceMgr:getDisplayCutoutSM()
    if platform == cc.PLATFORM_OS_ANDROID and self:isFuncEnabled(FUNC_ID.NOTACH_CHECK_AP) then
        local ok
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod("com/gbits/DeviceUtil", "getDisplayCutoutSM", {}, "()Ljava/lang/String;")
        if ok then return ret end
    end
end

function DeviceMgr:getFullClientUrl()
    local urls = require('patch/full_client_url.lua') or {}
    local PLATFORM_CONFIG = require("PlatformConfig")

    local fullClientUrlFromProp
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
        local channelNo = callJavaFun('com/gbits/LeitingSdkHelper', "getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { 'channelType' })
        local channelSuffix = callJavaFun('com/gbits/LeitingSdkHelper', "getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { "suffix" })
        if channelNo == channelSuffix then channelSuffix = "" end

        fullClientUrlFromProp = callJavaFun('com/gbits/LeitingSdkHelper', "getPropertiesValue", "(Ljava/lang/String;)Ljava/lang/String;", { "downloadUrl" })

        -- 为默认值或空串时，置为nil
        if fullClientUrlFromProp == channelNo or "" == fullClientUrlFromProp then fullClientUrlFromProp = nil end
    end

    local full_client_url = fullClientUrlFromProp or urls[PLATFORM_CONFIG.FULL_CLIENT_KEY]

    return full_client_url
end

function DeviceMgr:loadFullPackage()
    local full_client_url = DeviceMgr:getFullClientUrl()
    if full_client_url then
        DeviceMgr:openUrl(full_client_url)
    end

end

DeviceMgr:makeUIScale()

return DeviceMgr
