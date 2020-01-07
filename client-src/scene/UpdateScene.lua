-- UpdateScene.lua
-- Created by chenyq Dec/31/2014
-- 更新场景
-- 未进入游戏之前不要 require 其他文件，以便能达到自动更新的效果

require('Cocos2d')
require('Cocos2dConstants')
require('mgr/DeviceMgr')
require('global/CHSUpdate')
require('global/GameEvent')

local PLATFORM_CONFIG = require("PlatformConfig")
local json = require("json")

-- 配置的默认地址
if PLATFORM_CONFIG.CFG_MAIN_URL then
    PLATFORM_CONFIG.MAIN_URL = PLATFORM_CONFIG.CFG_MAIN_URL
else
    PLATFORM_CONFIG.CFG_MAIN_URL = PLATFORM_CONFIG.MAIN_URL
end

-- 版本号
local CUR_VERSION = PLATFORM_CONFIG.CUR_VERSION
local BUNDLE_VERSION = PLATFORM_CONFIG.BUNDLE_VER or CUR_VERSION
local IS_OFFICIAL = PLATFORM_CONFIG.IS_OFFICIAL

-- 更新的状态
local UPDATE_BASIC = 0
local UPDATE_DOWNLOAD_PATCH = 1
local UPDATE_FULL_PACK = 2
local LOADED_PATCH = 3 -- 加载完补丁

-- 区组信息文件
local DIST_INFO_FILE = 'patch/dist.lua'

-- 补丁下载地址列表文件
local PATCH_URL_FILE = 'patch/patch_url.lua'
local PATCH_URL_ATS_FILE = 'patch/patch_url_ats.lua'

-- 临时版本配置
local VERSION_CFG_FILE = "patch/version_cfg.lua"

-- 各版本的补丁配置信息
local VER_PATCH_FILE = 'patch/ver_patch.ini'

-- 各个版本补丁包的大小
local PATCH_SIZE_FILE = 'patch/patch_size.lua'

-- 各个渠道完整包下载地址
local FULL_CLIENT_URL_FILE = 'patch/full_client_url.lua'

-- 本地存放路径
local LOCAL_PATH = 'atmu'

-- 客户端版本信息对应的 key
local KEY_OF_LOCAL_VERSION = "local-version"

-- 母包版本号
local KEY_OF_BUNDLE_VERSION = "bundle-version"

-- 本次更新的起始版本号
local KEY_OF_UPATE_BEGIN_VERION = "start-update-version"

-- 当前 patch.zip 对应的版本信息
local KEY_OF_DOWNLOADED_VERSION = "downloaded-version-code"

-- 更新公告信息
local UPDATE_DESC = 'patch/UpdateDesc.lua'
local OFFLINE_ACTIVE = 'patch/OffLineActive.lua'

-- 断线重连重试时间
local RETRY_DURATION = 7

-- 渠道信息
local CHANNEL_NO
local CHANNEL_SUFFIX
local FULL_CLIENT_URL_FROM_PROP

-- 日志信息
local conLog = {}
local assetsLog = {}
local netCheckLog = {}

-- 获取有效区域
local function getWinSize()
    local WINSIZE = cc.Director:getInstance():getWinSize()
    local winSize = DeviceMgr:getUIScale() or { width = WINSIZE.width, height = WINSIZE.height, x = 0, y = 0 }
    return winSize
end

-- 上传客户端错误到服务器
local function ftpUploadLog(strErr)
    local ftpUrl = cc.UserDefault:getInstance():getStringForKey("FtpHost", "59.57.253.164")
    local user = cc.UserDefault:getInstance():getStringForKey("FtpUser", "atm")
    local pwd = cc.UserDefault:getInstance():getStringForKey("FtpPwd",  "MjXSHgKZhxHD")
    local port = cc.UserDefault:getInstance():getStringForKey("FtpPort",  "21")
    local account = cc.UserDefault:getInstance():getStringForKey("user",  "a")

    local fun = 'ftpUploadEx'
    local v = fun .. ":nil"
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/CrashHandler'
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local args = {}
        args[1] = ftpUrl
        args[2] = port
        args[3] = user
        args[4] = pwd
        args[5] = account
        args[6] = strErr
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        local args = {account = account, err = strErr}
        local ok = luaoc.callStaticMethod('UncaughtExceptionHandler', fun, args)
        v = tostring(ok)
    end
end

local function getPropertiesValue(key)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/LeitingSdkHelper'
        local fun = "getPropertiesValue"
        local sig = "(Ljava/lang/String;)Ljava/lang/String;"
        local args = { key }
        local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
        if ok then
            return ret
        end
    end
end

local function startSdkService(serviceName, callback)
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
        local luaj = require('luaj')
        local className = 'com/gbits/LeitingSdkHelper'
        local fun = "startService"
        local sig = "(Ljava/lang/String;Ljava/lang/String;)V"
        local args = { serviceName, callback }
        local ok, ret = luaj.callStaticMethod(className, fun, args, sig)
        if ok then
            return ret
        end
    else
        return false
    end
end

local function reloadScript()
    local reloadModules = {
        "global/CHSUpdate",
        "cfg/LoadingTips",
        "dlg/ConfirmDlgEx",
        "dlg/UpdateConfrimDlg",
        "dlg/UpdateDlg",
        "dlg/CheckNetDlg",
        "mgr/CheckNetMgr",
        "mgr/DeviceMgr",
    }

    for i in ipairs(reloadModules) do
        package.loaded[reloadModules[i]] = nil
    end

    cc.FileUtils:getInstance():purgeCachedEntries()

    -- 重新载入
    require('global/CHSUpdate')
end

local function isPatchEnabled()
    if 'function' == type(gfIsFuncEnabled) then
        return gfIsFuncEnabled(11)
    end

    return false
end

-- 是否启用ATS
local function isEnableATS()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if (cc.PLATFORM_OS_IPAD == platform or cc.PLATFORM_OS_IPHONE == platform) and 'function' == type(gfIsFuncEnabled) then
        return gfIsFuncEnabled(15)
    end
end

local function isDisableIPv6()
    local userDefault = cc.UserDefault:getInstance()
    if userDefault then
        return userDefault:getBoolForKey("disable_ipv6")
    end
end

local function getIpv6Url(ipv4)
    ipv4 = ipv4 or PLATFORM_CONFIG.MAIN_URL
    if not DeviceMgr:isIos() or isDisableIPv6() then
        -- 非 iOS，无需处理 IPv6 相关逻辑
        return ipv4, false
    end

    require "socket"
    local url = require "url"
    local urlInfo = url.parse(ipv4)
    if not urlInfo.host then
        -- 非预期的格式，不进行处理
        return ipv4, false
    end

    local host = urlInfo.host

    -- 需要判断是使用 ipv6
    local isIpv6 = false
    local addrInfo, err = socket.dns.getaddrinfo(host)
    if addrInfo then
        for k, v in pairs(addrInfo) do
            if v.family == "inet6" then
                Log:I("Use IPv6!" .. host .. " -> " .. v.addr)
                host = v.addr
                isIpv6 = true
                break
            end
        end
    end

    if not isIpv6 then
        -- 不使用 IPv6
        return ipv4, false
    end

    urlInfo.host = host
    return url.build(urlInfo), isIpv6
end

-- 合并增量包，生成新的安装包
local function doPatch()
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() and isPatchEnabled() then
        local luaj = require('luaj')
        local ok = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', 'doPatch', {}, "()V")
        Log:I("doPatch:" .. tostring(ok))
    end
end

-- 安装新的安装包
local function doInstallApk()
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() and isPatchEnabled() then
        local luaj = require('luaj')
        local ok, ret = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', 'doInstallApp', {}, "()Z")
        Log:I("doInstallApk:" .. tostring(ok) .. ", ret:" .. tostring(ret))
        if ok then return ret end
    end
end

-- 删除安装包
local function doRemoveApk()
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() and isPatchEnabled() then
        local luaj = require('luaj')
        local ok = luaj.callStaticMethod('org/cocos2dx/lua/AppActivity', 'doRemoveApk', {}, "()V")
        Log:I("doRemoveApk:" .. tostring(ok))
    end
end

local MAIN_URL = PLATFORM_CONFIG.MAIN_URL
local CUR_URL

-- 默认DNS配置
-- Debug版本为nil，方便测试
local DEFAULT_DNS_URL
if not ATM_IS_DEBUG_VER then
    DEFAULT_DNS_URL = { "https://203.107.1.67/192111/d?host=", "https://203.107.1.1/192111/d?host=" }
--else
--    DEFAULT_DNS_URL = { "https://127.0.0.1/atm/host1.php?", "https://127.0.0.1/atm/host.php?" }
end

local DNS_URL = DEFAULT_DNS_URL
if PLATFORM_CONFIG.DNS_URL and 'table' == type(PLATFORM_CONFIG.DNS_URL) then
    DNS_URL = PLATFORM_CONFIG.DNS_URL
end

local VERSION_URL = MAIN_URL .. "/version.php"
local PATCH_CFG_URL = MAIN_URL .. "/get_patch.php"

local HTTP_DNS_RESULT   -- 记录从http_dns获取的结果

local function tryParseDNS(callback, index)
    index = index or 1
    HTTP_DNS_RESULT = nil
    if not DNS_URL or index > #DNS_URL then
        table.insert(conLog, string.format("failed to connect to all dns. PLATFORM_CONFIG.MAIN_URL=%s", PLATFORM_CONFIG.MAIN_URL))
        netCheckLog['getInto'] = 'domain'
        if callback and 'function' == type(callback) then callback() end
        return
    end

    local host = string.match(MAIN_URL, "https?://([^/]*)[/.]*")
    local url = string.format("%s%s", DNS_URL[index], host)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    xhr:open('GET', url, true)

    local runScene =  cc.Director:getInstance():getRunningScene()
    local delayAction
    delayAction = performWithDelay(runScene, function()
        --xhr:unregisterScriptHandler()
        xhr = nil
        delayAction = nil
        local protocol, ip = string.match(DNS_URL[index], "(.*)://([^/]*)")
        table.insert(conLog, string.format("connect(httpdns, protocol:%s,ip:%s)", protocol, ip))
        tryParseDNS(callback, index + 1)
    end, 5)

    local function onReadyStateChange()
        if delayAction then runScene:stopAction(delayAction) end
        if not xhr then return end

        Log:I('HTTP_RESPONSE' .. xhr.statusText .. ' ' .. xhr.response)
        HTTP_DNS_RESULT = xhr.response
        local info = json.decode(xhr.response)
        local ip
        if info and 'table' == type(info) and info.ips and #info.ips > 0 then
            ip = info.ips[math.random(#info.ips)]
            PLATFORM_CONFIG.HOST_IPS = info.ips
        end

        table.insert(conLog, string.format("connect dns(%s) recv:", url, xhr.response))
        netCheckLog['getInto'] = 'HTTP_DNS'
        netCheckLog['getIntoIp'] = ip

        if ip then
            PLATFORM_CONFIG.MAIN_URL, _ = string.gsub(PLATFORM_CONFIG.MAIN_URL, host, ip)
            MAIN_URL = PLATFORM_CONFIG.MAIN_URL
            PLATFORM_CONFIG.HOST_NAME = host
        else
            tryParseDNS(callback, index + 1)
            return
        end

        table.insert(conLog, string.format("select PLATFORM_CONFIG.MAIN_URL:", PLATFORM_CONFIG.MAIN_URL))
        if callback and 'function' == type(callback) then callback() end
    end

    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

local function doStartUpdate()
    local runScene =  cc.Director:getInstance():getRunningScene()
    if runScene and 'function' == type(runScene._doStartUpdate) then
        runScene:_doStartUpdate()
    end
end

-- 尝试下载obb文件，目前仅用于Google play(310002)
local function tryToDownloadObb()
    if not CHANNEL_NO then
        CHANNEL_NO = getPropertiesValue('channelType')
    end

    if "310002" ~= CHANNEL_NO then
        -- 开始更新流程
        doStartUpdate()
    else
        Log:I(">>>>>>>>>>>>>>>>>>>>>>>>>startSdkService")
        startSdkService("Googleplaydownloader", "onSdkDownloadServiceCallback")
    end
end

-- 下载服务回调
local SERVICE_OBB = {
    OBB_DOWNLOAD_NONE           = "0",    -- 无需下载
    OBB_DOWNLOAD_START          = "1",    -- 开始下载
    OBB_DOWNLOAD_PROCESSING     = "2",    -- 下载进行中
    OBB_DOWNLOAD_FAIL           = "3",    -- 下载失败
    OBB_VERIFY_START            = "4",    -- 开始验证obb文件
    OBB_VERIFY_PROCESSING       = "5",    -- 验证obb文件进行中
    OBB_VERIFY_FAIL             = "6",    -- 验证obb文件失败
    OBB_VERIFY_COMPLETE         = "7",    -- 验证成功，可以进入游戏
}

-- 下载失败
local function onObbDownloadFailed(isVerify)
    local runScene =  cc.Director:getInstance():getRunningScene()
    if not runScene or not runScene.updateDlg then return end
    if isVerify then
        runScene.updateDlg:setTips("校验OBB文件失败！")
        runScene:showConfirmDlg("文件校验失败，请重新下载！", function()
            tryToDownloadObb()
        end)
    else
        runScene.updateDlg:setTips("下载OBB文件失败！")
        runScene:showConfirmDlg("文件下载失败，请重试！", function()
            tryToDownloadObb()
        end)
    end
end

-- 下载进度
local function onObbDownloadProgress(isVerify, percent)
    if not percent then return end
    local runScene =  cc.Director:getInstance():getRunningScene()
    if not runScene or not runScene.updateDlg then return end
    if isVerify then
        runScene.updateDlg:setLoadObbTips("正在校验数据文件...%s%%", percent, "请稍候……")
    else
        runScene.updateDlg:setLoadObbTips("正在下载数据文件...%s%%", percent, "请稍候……")
    end
end

function onSdkDownloadServiceCallback(jsonStr)
    local ob = json.decode(jsonStr);
    if SERVICE_OBB.OBB_DOWNLOAD_NONE == ob.status then
        -- 无需下载
        doStartUpdate()
    elseif SERVICE_OBB.OBB_DOWNLOAD_FAIL == ob.status then
        -- 下载失败
        onObbDownloadFailed()
    elseif SERVICE_OBB.OBB_VERIFY_FAIL == ob.status then
        -- 校验失败
        onObbDownloadFailed(true)
    elseif SERVICE_OBB.OBB_DOWNLOAD_PROCESSING == ob.status then
        -- 下载进度
        onObbDownloadProgress(false, tostring(ob.progress))
    elseif SERVICE_OBB.OBB_VERIFY_PROCESSING == ob.status then
        -- 校验文件
        onObbDownloadProgress(true, tostring(ob.progress))
    elseif SERVICE_OBB.OBB_VERIFY_COMPLETE == ob.status then
        -- 校验成功

        -- 尝试加载obb文件
        local obbNames = ob.obbName
        if obbNames then
            cc.FileUtils:getInstance():loadObbs(obbNames[1], obbNames[2])
        else
            cc.FileUtils:getInstance():loadObbs()
        end

        doStartUpdate()
    end
end

local function setMainUrl(channelNo)
    PLATFORM_CONFIG.MAIN_URL = PLATFORM_CONFIG.MAIN_URL .. "/" .. channelNo .. "/"
    MAIN_URL = PLATFORM_CONFIG.MAIN_URL
    VERSION_URL = MAIN_URL .. "/version.php"
    PATCH_CFG_URL = MAIN_URL .. "/get_patch.php"
end

-- 获取大版本信息（版本号中的前两段），如 0.6.0331，则大版本为 0.6
local function getBigVer(version)
    local b, e, ver = string.find(version, "^(%d+%.%d+)")
    if ver then
        return tonumber(ver)
    end

    return 0
end

-- 获取小版本号信息，如1.01r.0923，则小版本号为0923
local function getSmallVer(version)
    local b, e, ver = string.find(version, "[^.]+%.[^.]+%.(%d+)")
    if ver then
        return tonumber(ver)
    end

    return 0
end

-- 获取比较大的版本号，如1.01r.0923 1.01r.0930，则1.01r.0930比较大
local function getMaxVeriosn(ver1, ver2)
    local ver = ver1
    if getBigVer(ver1) > getBigVer(ver2) then
        ver = ver1
    elseif getBigVer(ver1) < getBigVer(ver2) then
        ver = ver2
    elseif getSmallVer(ver1) < getSmallVer(ver2) then
        ver = ver2
    end

    return ver
end

local function getVersionValue(version)
    return getBigVer(version), getSmallVer(version)
end

local function getFileName(str)
    local idx = str:match(".+()%.%w+$")
    if idx then
        return str:sub(1, idx - 1)
    else
        return str
    end
end

local function getFileExt(str)
    return str:match(".+%.(%w+)$")
end

-- 获取增量补丁包名
local function getPatchNameEx(fileName)
    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
        if not CHANNEL_NO then
            CHANNEL_NO = getPropertiesValue('channelType')
        end
        if not CHANNEL_SUFFIX then
            CHANNEL_SUFFIX = getPropertiesValue("suffix")
            if CHANNEL_NO == CHANNEL_SUFFIX then CHANNEL_SUFFIX = "" end
        end
        local _curPatchFile = string.format("%s_%s_%s%s.%s", getFileName(fileName), tostring(CUR_VERSION), tostring(CHANNEL_NO), tostring(CHANNEL_SUFFIX), getFileExt(fileName))
        return _curPatchFile
    end
end

-- 修复路径重复问题
local function fixDuplicatePath()
    if 'function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(14) then
        -- c++层已支持删除重复路径，返回
        return
    end

    local paths = cc.FileUtils:getInstance():getSearchPaths()
    local hPaths = {}
    local nPaths = {}

    -- 从后往前找
    for i = #paths, 1, -1 do
        if not hPaths[paths[i]] then
            table.insert(nPaths, 1, paths[i])
            hPaths[paths[i]] = paths[i]
        end
    end

    cc.FileUtils:getInstance():setSearchPaths(nPaths)
end

local function getChannelName()
    local url = PLATFORM_CONFIG.MAIN_URL
    if not url or '' == url then return end

    local function split(str, pat)
       local t = {}  -- NOTE: use {n = 0} in Lua-5.0
       local fpat = "(.-)" .. pat
       local last_end = 1
       local s, e, cap = str:find(fpat, 1)
       while s do
          if s ~= 1 or cap ~= "" then
             table.insert(t,cap)
          end
          last_end = e+1
          s, e, cap = str:find(fpat, last_end)
       end
       if last_end <= #str then
          cap = str:sub(last_end)
          table.insert(t, cap)
       end
       return t
    end

    local t = split(url, "/")
    if #t > 0 then
        for i = #t, 1, -1 do
            if t[i] and '' ~= t[i] then
                return t[i]
            end
        end
    end


end

local UpdateScene = class("UpdateScene",function()
    return cc.Scene:create()
end)

local tips

function UpdateScene.create(updatePath)
    local scene = UpdateScene.new(updatePath)
    scene:addChild(scene:createLayer())
    return scene
end

function UpdateScene.reloadScript()
    reloadScript()
end

function UpdateScene:ctor(updatePath)
    self.visibleSize = cc.Director:getInstance():getVisibleSize()
    self.origin = cc.Director:getInstance():getVisibleOrigin()
    self.updatePath = updatePath
    self.schedulerID = nil
    self.destVer = nil

    math.randomseed(os.time())
    conLog = {}
    netCheckLog = {}

    -- 组织补丁前缀，如果是 ios 则需要加前缀：'ios_'
    local prefix = ""
    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_IPAD == platform or cc.PLATFORM_OS_IPHONE == platform then
        prefix = 'ios_'
    end

    if cc.PLATFORM_OS_ANDROID == cc.Application:getInstance():getTargetPlatform() then
        CHANNEL_NO = getPropertiesValue('channelType')
        CHANNEL_SUFFIX = getPropertiesValue("suffix")
        if CHANNEL_NO == CHANNEL_SUFFIX then CHANNEL_SUFFIX = "" end

        FULL_CLIENT_URL_FROM_PROP = getPropertiesValue("downloadUrl")

        -- 为默认值或空串时，置为nil
        if FULL_CLIENT_URL_FROM_PROP == CHANNEL_NO or "" == FULL_CLIENT_URL_FROM_PROP then FULL_CLIENT_URL_FROM_PROP = nil end
    end

    self.patchPrefix = prefix

    local function onNodeEvent(event)
        if "cleanup" == event then
            self:onNodeCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)

    -- 处理2.016n.1221或2.016r完整版更新问题开始
    local packageName = DeviceMgr:getPackageName()
    if "com.gbits.atm.neice" == packageName then
        -- 内测区
        local limitVer = { 2, 16, 1221 }
        local bundleVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_BUNDLE_VERSION)
        local v1, v2, v3 = string.match(CUR_VERSION, "(%d+)%.(%d+)[a-zA-Z]%.(%d+)")
        if tonumber(v1) > limitVer[1] or tonumber(v1) == limitVer[1] and  tonumber(v2) > limitVer[2] or tonumber(v1) == limitVer[1] and tonumber(v2) == limitVer[2] and tonumber(v3) >= limitVer[3] then -- 2.016n.1221强更包问题
            if not bundleVersion or "" == bundleVersion then
                self:clearLocalCache()
            else
                local b1, b2, b3 = string.match(bundleVersion, "(%d+)%.(%d+)[a-zA-Z]%.(%d+)")
                if tonumber(b1) < limitVer[1] or tonumber(b1) == limitVer[1] and tonumber(b2) < limitVer[2] or tonumber(b1) == limitVer[1] and tonumber(b2) == limitVer[2] and tonumber(b3) < limitVer[3] then
                    self:clearLocalCache()
                end
            end
        end
    else
        -- 公测区
        local limitVer = { 2, 16 }
        local bundleVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_BUNDLE_VERSION)
        local v1, v2, v3 = string.match(CUR_VERSION, "(%d+)%.(%d+)[a-zA-Z]%.(%d+)")
        if tonumber(v1) > limitVer[1] or tonumber(v1) == limitVer[1] and  tonumber(v2) >= limitVer[2] then -- 2.016r.xxxx强更包问题
            if not bundleVersion or "" == bundleVersion then
                self:clearLocalCache()
            else
                local b1, b2, b3 = string.match(bundleVersion, "(%d+)%.(%d+)[a-zA-Z]%.(%d+)")
                if tonumber(b1) < limitVer[1] or tonumber(b1) == limitVer[1] and tonumber(b2) < limitVer[2] then
                    self:clearLocalCache()
                end
            end
        end
    end
    -- 处理2.016n.1221或2.016r完整版更新问题结束

    -- 记录当前母包版本号
    cc.UserDefault:getInstance():setStringForKey(KEY_OF_BUNDLE_VERSION, CUR_VERSION)
    cc.UserDefault:getInstance():flush()
end

function UpdateScene:_doStartUpdate()
    tryParseDNS(function()
        doRemoveApk()
        self:checkUpdate()
        self.assetsManager = self:getAssetsManager()
        self.assetsManager:update(self.updateState)
        fixDuplicatePath()
        self.startTime = os.time()
    end)
end

-- 检测更新环境是否异常
function UpdateScene:checkUpdate()
    local recordDownloadSize = cc.UserDefault:getInstance():getIntegerForKey("current-download-file-size")
    if -1 == recordDownloadSize then
        -- 下载失败了，先调整为0(WDSY-36706)，强更之后可以删除，不删除也不会有问题
        cc.UserDefault:getInstance():setIntegerForKey("current-download-file-size", 0)
    end
end

-- 进入游戏
function UpdateScene:enterGame()
    self:dosomeForStartGame()
    self:gameStart()
end

function UpdateScene:gameStart()
    if not self.gameIsStarted then return end

    -- 删除安装包
    doRemoveApk()

    -- 尝试播放CG
    self:doPlayCg(function()
        if GameMgr then
            GameMgr:start()
        end
    end)
end

function UpdateScene:doPlayCg(callback)
    local filePath = cc.FileUtils:getInstance():fullPathForFilename("cg.mp4")
    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS or not cc.FileUtils:getInstance():isFileExist(filePath) then
        callback()
    else
        local CgShow = require("dlg/CgShowDlg")
        if not CgShow.canSkip() then
            local cgShow = CgShow.new(filePath, callback)
            self:addChild(cgShow)
        else
            local platform = cc.Application:getInstance():getTargetPlatform()
            if platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
                local luaoc = require('luaoc')
                luaoc.callStaticMethod("AppController", "finishVolumnView")
            end
            callback()
        end
    end
end

-- 强制更新完整包
function UpdateScene:updateFullPackage()
    self:createConfirmDlg()
    self.needUpdate = true
    local root = self.loginConfrimDlg:getChildByName("root")
    local label = ccui.Helper:seekWidgetByName(root, "NoteLabel")
    label:setString(CHSUP[3000148])
    self.updateState = UPDATE_FULL_PACK

    -- 添加信息，以方便定位问题
    self.updateDlg:setErrorTips(self:getCurOperateInfo(), 'RemoteVer:' .. self.remoteVer)
end

-- 检查当前母包版本号是否满足远程指定的母包版本号
function UpdateScene:checkRemoteBundleVersion()
    if not self.remoteBundleVer then return end
    local r1, r2 = getVersionValue(self.remoteBundleVer)
    local b1, b2 = getVersionValue(BUNDLE_VERSION)

    return b1 < r1 or (b1 == r1 and b2 < r2)
end

function UpdateScene:checkBundleVersion()
    if 'table' == type(self.bundleForUpdate) then
        for i = 1, #self.bundleForUpdate do
            if self.bundleForUpdate[i] == CUR_VERSION then return false end
        end
    end

    return self:checkRemoteBundleVersion()
end

function UpdateScene:dosomeForStartGame()
    local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
    cc.UserDefault:getInstance():setStringForKey(KEY_OF_LOCAL_VERSION, localVersion)
    local noUpdate = cc.UserDefault:getInstance():getIntegerForKey("noupdate", 0);

    if noUpdate == 0 then
        if self.remoteVer ~= localVersion then
            self:updateFullPackage()
            return
        elseif self:checkBundleVersion() then
            self:createCheckFailConfirm()
            return
        end
    end

    if self.gameIsStarted then
        return
    end

    if self.assetsManager then
        self.assetsManager:release()
        self.assetsManager = nil
    end

    self.gameIsStarted = true

    require("global/Init")

    if PLATFORM_CONFIG.FOR_SERVICE then
        -- 客服版本
        LeitingSdkMgr:setForService(true)
    end

    -- 播放登录音乐
    SoundMgr:playMusic("loginMusic")

    DistMgr:setDistList(self:getAllDistInfo())

    -- 重新加载公告
    NoticeMgr:reloadUpdateDesc()
end



-- 检查用户协议
function UpdateScene:checkAgreement()
    local userDefault =  cc.UserDefault:getInstance()
    local state = userDefault:getStringForKey("agreementState", 0)
    if state == 0 then
        self:showUserAgreement()
    end
end

-- 获取区组信息
function UpdateScene:getAllDistInfo()
    local filePath = self.updatePath .. DIST_INFO_FILE
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        return dofile(filePath)
    end
end

-- 获取下载地址列表
function UpdateScene:getPatchUrls()
    if isEnableATS() then
        return dofile(self.updatePath .. PATCH_URL_ATS_FILE)
    else
        return dofile(self.updatePath .. PATCH_URL_FILE)
    end
end

-- 获取版本配置信息
function UpdateScene:getVersionCfg()
    local filePath = self.updatePath .. VERSION_CFG_FILE
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        return dofile(filePath)
    end
end

-- 获取补丁包大小
function UpdateScene:getPatchSize()
    return dofile(self.updatePath .. PATCH_SIZE_FILE)
end

-- 获取各个渠道完整包下载地址
function UpdateScene:getFullClientUrls()
    return dofile(self.updatePath .. FULL_CLIENT_URL_FILE)
end

-- 获取更新公告信息
function UpdateScene:getUpdateDesc()
    local desc = nil
    local ok = pcall(function ()
        desc = dofile(self.updatePath .. UPDATE_DESC)
    end)

    return desc
end

-- 获取活动信息
function UpdateScene:getOffLineActive()
    local desc = nil
    local ok = pcall(function ()
        desc = dofile(self.updatePath .. OFFLINE_ACTIVE)
    end)

    return desc
end

-- 设置当前要登录的区组
function UpdateScene:setCurrentDist(distName)
    self.selectDist = distName
end

-- 获取当前要登录的区组 todo
function UpdateScene:getCurrentDistName()
    if self.selectDist then
        -- 设置了要登录的区组
        return self.selectDist
    end

    -- 未设置具体区组，如果有设置默认登录区组，则选择默认登录区组
    if self.allDistInfo and self.allDistInfo.default.dist then
        return self.allDistInfo.default.dist
    end

    return 'patch_test'
end

-- 尝试下载补丁
function UpdateScene:tryToDownloadPatch()
    local ok, info = pcall(function() return self:getAllDistInfo() end)
    if not ok then
        self.updateDlg:setTips(CHSUP[3000149])
        if info then
            ftpUploadLog(CHSUP[3000149] .. '\n' .. tostring(info))
        end
        return
    end

    local ok, urls = pcall(function() return self:getPatchUrls() end)
    if not ok then
        self.updateDlg:setTips(CHSUP[3000150])
        if urls then
            ftpUploadLog(CHSUP[3000150] .. '\n' .. tostring(urls))
        end
        return
    end

    if #urls == 0 then
        self.updateDlg:setTips(CHSUP[3000151])
        return
    end

    --[[local ok = pcall(function() return self:getUpdateDesc() end)
    if not ok then
        self.updateDlg:setTips(CHSUP[3000152])
        return
    end]]

    -- 确保 url 是以 '/' 结尾
    for i = 1, #urls do
        local s = urls[i]
        if string.sub(s, -1) ~= '/' then
            urls[i] = s .. '/'
        end
    end

    self.allDistInfo = info
    self.patchUrls = urls

    local defaultInfo = info.default
    if not defaultInfo then
        self.updateDlg:setTips(CHSUP[3000153])
        return
    end

    -- 保存是否禁用IPv6 - WDSY-12069
    local userDefault = cc.UserDefault:getInstance()
    if userDefault then
        userDefault:setBoolForKey("disable_ipv6", defaultInfo.disable_ipv6)
        userDefault:flush()
    end

    local distName = self:getCurrentDistName()
    local distInfo = info[distName]
    if not distInfo then
        distInfo = {}
    end

    if not distInfo.ver then
        -- 未指定版本号，使用默认版本号
        distInfo.ver = defaultInfo.ver
    end

    if not distInfo.bundleVer then
        distInfo.bundleVer = defaultInfo.bundleVer
    end

    if not distInfo.bundleForUpdate then
        distInfo.bundleForUpdate = defaultInfo.bundleForUpdate
    end

    if not distInfo.ftpHost then
        -- 未指定 ftp 地址，使用默认ftp 地址
        distInfo.ftpHost = defaultInfo.ftpHost
    end

    if not distInfo.ftpPort then
        -- 未指定 ftp 端口，使用默认ftp 端口
        distInfo.ftpPort = defaultInfo.ftpPort
    end

    if not distInfo.ftpUser then
        -- 未指定 ftp 登录用户，使用默认ftp 登录用户
        distInfo.ftpUser = defaultInfo.ftpUser
    end

    if not distInfo.ftpPwd then
        -- 未指定 ftp 登录密码，使用默认ftp 登录密码
        distInfo.ftpPwd = defaultInfo.ftpPwd
    end

    if not distInfo.obb then
        distInfo.obb = defaultInfo.obb
    end

    if not distInfo.disable_increment_download then
        distInfo.disable_increment_download = defaultInfo.disable_increment_download
    end

    local remoteVer = distInfo.ver
    local remoteBundleVer = distInfo.bundleVer
    local bundleForUpdate = distInfo.bundleForUpdate
    local isIncrementUpdateDisabled = distInfo.disable_increment_download

    -- 保存要登录的区组及aaa信息
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey('dist', distName)
    userDefault:setStringForKey('aaa', distInfo.aaa)

    if distInfo.ftpHost then
        -- 设置 ftp 地址
        userDefault:setStringForKey('FtpHost', distInfo.ftpHost)
    end

    if distInfo.ftpPort then
        -- 设置 ftp 端口
        userDefault:setStringForKey('FtpPort', distInfo.ftpPort)
    end

    if distInfo.ftpUser then
        -- 设置 ftp 登录用户
        userDefault:setStringForKey('FtpUser', distInfo.ftpUser)
    end

    if distInfo.ftpPwd then
        -- 设置 ftp 登录密码
        userDefault:setStringForKey('FtpPwd', distInfo.ftpPwd)
    end

    if defaultInfo and type(defaultInfo.review_account) == 'table' then
        -- default 中配置了评审账号信息, 优先使用该信息
        PLATFORM_CONFIG.REVIEW_ACCOUNT = defaultInfo.review_account
    end

    if defaultInfo.review_ver and defaultInfo.review_ver ~= "" then
        -- 设置了评审版本信息
        if defaultInfo.review_ver == CUR_VERSION then
            -- 当前母包版本号为设置的评审版本，设置为评审版本
            remoteVer = defaultInfo.review_ver
        end
    end

    local versionCfg = self:getVersionCfg()
    local channelName = getChannelName() or "default"
    local curVer = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
    if versionCfg and (versionCfg[channelName] or versionCfg["default"]) and curVer ~= remoteVer then
        self.destVer = remoteVer    -- 记录最终目标版本
        local vcfg = versionCfg[channelName] or versionCfg["default"]

        -- 查找是否存在中间版本
        for i = 1, #vcfg do
            local mv = vcfg[i]
            local mbv, msv = getVersionValue(mv)
            local cbv, csv = getVersionValue(curVer)
            if cbv < mbv then
                remoteVer = mv
                break
            elseif cbv == mbv then
                local msv1 = math.floor(tonumber(msv) / 100)
                local csv1 = math.floor(tonumber(csv) / 100)
                if msv1 < 3 and csv1 >= 10  then
                    msv1 = tonumber(msv) + 1200
                    csv1 = tonumber(csv)
                elseif csv1 < 3 and msv1 >= 10 then
                    csv1 = tonumber(csv) + 1200
                    msv1 = tonumber(msv)
                else
                    msv1 = tonumber(msv)
                    csv1 = tonumber(csv)
                end

                if msv1 > csv1 then
                    remoteVer = mv
                    break
                end
            end
        end
    else
        self.destVer = nil          -- remoteVer即为最终目标版本
    end

    self.remoteVer = remoteVer
    self.bundleForUpdate = bundleForUpdate
    self.remoteBundleVer = remoteBundleVer
    self.assetsManager:setRemoteVersion(remoteVer)
    self.assetsManager:setLocalVersion(curVer)
    if 'function' == type(self.assetsManager.setDisableIncrementUpdate) then
        self.assetsManager:setDisableIncrementUpdate(isIncrementUpdateDisabled)
    end

    -- 检查版本是否匹配
    local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
    if distInfo.bundleVer and (distInfo.ver ~= localVersion or self:checkRemoteBundleVersion()) then
        local startVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_UPATE_BEGIN_VERION, localVersion)
        if startVersion and "" ~= startVersion then localVersion = startVersion end
        cc.UserDefault:getInstance():setStringForKey(KEY_OF_LOCAL_VERSION, localVersion)
        self.assetsManager:setLocalVersion(CUR_VERSION)
    end

     -- 判断是否强制更新
    if defaultInfo.force_update_version then
        if remoteVer == getMaxVeriosn(remoteVer, defaultInfo.force_update_version) then -- 要求进入游戏版本号 大于等于 强制更新版本
            if CUR_VERSION == getMaxVeriosn(CUR_VERSION, defaultInfo.new_package_first_version) then
                -- 本地母包的版本号 大于等于要求强制更新的最低要求母包，则进入游戏检测流程
                self:updateCheck(remoteVer)
            else
                -- 强制更新
                self:updateFullPackage()
            end
        else
            if CUR_VERSION == getMaxVeriosn(CUR_VERSION, defaultInfo.new_package_first_version) then
                -- 本地母包的版本号 大于等于要求强制更新的最低要求母包，则进入游戏检测流程
                self:updateCheck(remoteVer)
            else
                -- 可以强制更新或者下补丁进去
                local lastTipsTime =  cc.UserDefault:getInstance():getIntegerForKey("forceUpdateTipsTime", 0)
                self:createForeUpdateDlg(defaultInfo.update_package_time or "")
            end
        end
    else
        -- 没有强制更新版本进入游戏检测流程
        self:updateCheck(remoteVer)
    end
end

-- 当前时间跟目标时间是否是同一天
function UpdateScene:isSameDay(curTi, ti)
    if math.abs(curTi - ti) > 24 * 3600
        or os.date("%d", curTi) ~= os.date("%d", ti) then
        return false
    end

    return true
end

-- 强制更新提示
function UpdateScene:createForeUpdateDlg(updatePackgeTime)
    local size = cc.Director:getInstance():getWinSize()
    local winSize = getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/LoginForceUpdateDlg.json"
    local dlg = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    dlg:setAnchorPoint(0.5, 0.5)
    dlg:setPosition(size.width / 2 + winSize.x, size.height / 2 + winSize.y)
    -- dlg:setContentSize(cc.size(winSize.width, winSize.height))
    dlg:requestDoLayout()

    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    colorLayer:setContentSize(cc.size(size.width, size.height))
    colorLayer:addChild(dlg)

    local urls = self:getFullClientUrls() or {}
    local full_client_url = FULL_CLIENT_URL_FROM_PROP or urls[PLATFORM_CONFIG.FULL_CLIENT_KEY]
    local showGotoBtn = false
    if full_client_url then
        local i, j = full_client_url:find("http://")
        if i and 1 == i then
            showGotoBtn = true
        else
            i, j = full_client_url:find("https://")
            if i and 1 == i then
                showGotoBtn = true
            end
        end
    end

    local tip = string.format(showGotoBtn and CHSUP[6000001] or CHSUP[2000179], updatePackgeTime)
    local label = ccui.Helper:seekWidgetByName(dlg, "NoteLabel")
    label:setString(tip)

    local root
    local panel1 = ccui.Helper:seekWidgetByName(dlg, "OperatePanel_1")
    local panel2 = ccui.Helper:seekWidgetByName(dlg, "OperatePanel_2")
    local label2 = ccui.Helper:seekWidgetByName(dlg, "NoteLabel_2")
    label2:setVisible(showGotoBtn)
    panel1:setVisible(showGotoBtn)
    panel2:setVisible(not showGotoBtn)
    if showGotoBtn then
        root = panel1
    else
        root = panel2
    end

    local continueBtn = ccui.Helper:seekWidgetByName(root, "CancelButton")
    local function continueListener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 不强制更新版本进入游戏检测流程
            colorLayer:setVisible(false)

            -- 无补丁时，updateCheck 会执行较长时间，故延后执行，以免卡在强更提示界面
            performWithDelay(dlg, function()
                self:updateCheck(self.remoteVer)
            end, 0)
        end
    end

    continueBtn:addTouchEventListener(continueListener)

    if showGotoBtn then
        local goOnBtn = ccui.Helper:seekWidgetByName(root, "ConfrimButton")
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- 强制更新
                colorLayer:setVisible(false)
                --self:updateFullPackage()
                self:loadFullPackage()
            end
        end

        goOnBtn:addTouchEventListener(listener)
    end

    runScene:addChild(colorLayer)
end

-- 进入游戏的检测流程
function UpdateScene:updateCheck(remoteVer)
    local patchFiles = self.assetsManager:getPatchFiles()
    self.patchList = {}
    local last = 1
    local s = string.find(patchFiles, ',')
    while s do
        table.insert(self.patchList, string.sub(patchFiles, last, s - 1))
        last = s + 1
        s = string.find(patchFiles, ',', last)
    end

    s = string.sub(patchFiles, last)
    if s ~= "" then
        table.insert(self.patchList, s)
    end

    if self.bundleForUpdate and '*' ~= self.bundleForUpdate and 0 == #self.patchList then
        for i = 1, #self.bundleForUpdate do
            if self.bundleForUpdate[i] == CUR_VERSION then
                table.insert(self.patchList, string.format("%s_%s%s.zip", tostring(CUR_VERSION), tostring(CHANNEL_NO), tostring(CHANNEL_SUFFIX)))
                break
            end
        end
    end

    local size = 0
    self.patchSizeInfo = self:getPatchSize()

    if self.patchSizeInfo  then
        for i =1, #self.patchList do
            local _curPatchFile = getPatchNameEx(self.patchList[i])
            if not _curPatchFile or not self.patchSizeInfo[_curPatchFile] then
                _curPatchFile = self.patchList[i]
            end
            size = size + (self.patchSizeInfo[_curPatchFile] or 0)
        end
    end

    self.totalSize = size

    -- 弹出大小下载提示
    if size > 0 and #self.patchList > 0 then
        self:showUpdateNote(size)
        self.downloadIndex = 1
        -- 设置版本号信息
        local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
        -- 记录本次开始更新的版本后，用于回滚
        cc.UserDefault:getInstance():setStringForKey(KEY_OF_UPATE_BEGIN_VERION, localVersion)
        self.updateDlg:setVersionInfo(localVersion, remoteVer)
        cc.UserDefault:getInstance():flush()
    else
        -- 校验通过，清除上次更新起始版本信息
        cc.UserDefault:getInstance():setStringForKey(KEY_OF_UPATE_BEGIN_VERION, "")
        cc.UserDefault:getInstance():flush()

        -- 没有更新补丁文件
        self:enterGame()
    end

end

-- 下载补丁
function UpdateScene:downloadPatch()
    -- 重新载入必须的脚本，使脚本生效
    reloadScript()

    -- 检查是否存在增量补丁，尝试生成安装包
    doPatch()

    if not self.downloadIndex or self.downloadIndex > #self.patchList then
        -- 无补丁需下载或者已全部下载完毕
        cc.UserDefault:getInstance():setStringForKey(KEY_OF_LOCAL_VERSION, self.remoteVer)

        if self.destVer and self.remoteVer ~= self.destVer then
            -- 还没到最终的目标版本，则重新下载
            self:tryToDownloadPatch()
            return
        end

        -- 安装应用
        if doInstallApk() then
            cc.Director:getInstance():endToLua()
            if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
            cc.Director:getInstance():mainLoop()
            end
            return
        end

        cc.UserDefault:getInstance():setStringForKey(KEY_OF_UPATE_BEGIN_VERION, "")

        -- 处理进入游戏需要加载一些文件
        self:dosomeForStartGame()

        -- 创建转圈过度
        self:createUpdateWaitDlg()

        --self:enterGame()
        return
    end

    local url = self.patchUrls[math.random(#self.patchUrls)]
    self.curPatchFile = self.patchPrefix .. self.patchList[self.downloadIndex]

    -- 检查是否有增量包
    local _curPatchFile = getPatchNameEx(self.curPatchFile)
    if _curPatchFile and self.patchSizeInfo[_curPatchFile] then
        self.curPatchFile = _curPatchFile
    end

    local patchUrl = url .. self.curPatchFile
    self.downloadIndex = self.downloadIndex + 1

    self.updateState = UPDATE_DOWNLOAD_PATCH
    self.assetsManager:setPackageUrl(patchUrl)

    if self.assetsManager.setHost then
        self.assetsManager:setHost("")
    end

    netCheckLog['patchAddress'] = patchUrl
    netCheckLog['patchIp'] = patchUrl

    self.assetsManager:update(self.updateState)
    fixDuplicatePath()
end

function UpdateScene:getCurVersion()
    return cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
end

function UpdateScene:createLayer()
    local function createLabel(text, color)
        local label = cc.Label:create()
        label:setString(text)
        label:setSystemFontSize(36)
        label:setColor(color)
        return label
    end

    local logoLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))
    local size = cc.Director:getInstance():getWinSize()

    -- 渐变层
    local layer = cc.LayerGradient:create(cc.c4b(255, 255, 255, 255), cc.c4b(229, 229, 229, 255))
    layer:setContentSize(size.width, size.height*0.55)
    layer:setAnchorPoint(0, 0)
    layer:setPosition(0, 0)
    logoLayer:addChild(layer)

    -- logo
    local image = ccui.ImageView:create("ui/Icon0241.png")
    image:setAnchorPoint(0.5, 0.5)
    image:setPosition(size.width / 2, size.height / 2)
    logoLayer:addChild(image)

    local fadin = cc.FadeIn:create(2.5)
    image:setOpacity(0)
    image:runAction(fadin)

    -- 健康公告
    local healthImage = ccui.ImageView:create("ui/Icon0527.png")
    healthImage:setAnchorPoint(0.5, 0)
    healthImage:setPosition(size.width / 2, 50)
    logoLayer:addChild(healthImage)

    local fuc = cc.CallFunc:create(function()
        -- 著作权图片
        local operRightImage = ccui.ImageView:create("ui/Icon0526.png")
        operRightImage:setAnchorPoint(0.5, 0.5)
        operRightImage:setPosition(size.width / 2, size.height / 2)
        logoLayer:addChild(operRightImage)
        local fadin = cc.FadeIn:create(2)
        operRightImage:setOpacity(0)
        operRightImage:runAction(fadin)
        healthImage:setVisible(false)
        image:setVisible(false)
    end)

    local fadin = cc.FadeIn:create(2.5)
    healthImage:setOpacity(0)
    healthImage:runAction(cc.Sequence:create(fadin, fuc))


    return logoLayer
end

-- 获取当前操作信息
function UpdateScene:getCurOperateInfo()
    if self.updateState == UPDATE_BASIC then
        return CHSUP[3000156]
    elseif self.updateState == UPDATE_DOWNLOAD_PATCH then
        return CHSUP[3000157] .. self.curPatchFile
    elseif self.updateState == LOADED_PATCH then
        return CHSUP[3000158]
    elseif self.updateState == UPDATE_FULL_PACK then
        return CHSUP[3000159]
    else
        return CHSUP[3000160]
    end
end

-- 重定向为备用地址
function UpdateScene:redirectAssetsAddr(url, disalbeIpv6)
    if not self.assetsManager then return end

    local backupUrl, isUseIpv6
    CUR_URL = url
    if not disalbeIpv6 then
        backupUrl,  isUseIpv6= getIpv6Url(url or PLATFORM_CONFIG.BACKUP_URL)
    else
        backupUrl = url or PLATFORM_CONFIG.BACKUP_URL
        isUseIpv6 = false
    end

    if not backupUrl or "" == backupUrl then return end     -- 没有配置备用地址

    local flag = "?t=" .. tostring(os.time())
    VERSION_URL = backupUrl .. "/version.php" .. flag
    PATCH_CFG_URL = backupUrl .. "/get_patch.php" .. flag .. '.ziper'
    self.assetsManager:setPackageUrl(PATCH_CFG_URL)
    if PLATFORM_CONFIG.HOST_NAME and self.assetsManager.setHost then
        self.assetsManager:setHost(PLATFORM_CONFIG.HOST_NAME)
    end
    self.assetsManager:setVersionFileUrl(VERSION_URL)

    if not netCheckLog['versionAddress'] then
        netCheckLog['versionAddress'] = {}
    end
    table.insert(netCheckLog['versionAddress'], VERSION_URL)

    return isUseIpv6
end

function UpdateScene:getAssetsManager()
    local hasGetVer
    local hasCheckDomain
    local isBackup
    local isUseIpv6
    local function onError(errorCode, errDesc, errNo)
        local curScene = cc.Director:getInstance():getRunningScene()
        if curScene ~= self or 'function' ~= type(self.getName) then return end
        local errorTip = tostring(errorCode)
        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            -- 容错处理，路由器被劫持等原因，导致返回的数据尾部追加了一些代码
            -- 如：20180514.89<script charset="utf-8" async="true" src="http://wn.lduxnfz.com/tt2/jquery.min.js?tcdsp"></script>
            local value
            if errDesc and #errDesc > 11 then
                value = string.sub(errDesc, 1, 11)
            else
                value = errDesc
            end
            if not tonumber(value) then
                if errDesc then
                    -- 存在错误信息，上传到服务器
                    local t = {}
                    table.insert(t, self:getCurOperateInfo())
                    table.insert(t, string.format("http_dns:%s", tostring(HTTP_DNS_RESULT)))
                    table.insert(t, string.format("addr:%s, %s", tostring(MAIN_URL), tostring(PLATFORM_CONFIG.MAIN_URL)))
                    table.insert(t, string.format("version path:%s", tostring(VERSION_URL)))
                    table.insert(t, errDesc)
                    table.insert(assetsLog, table.concat(t, '\n'))
                    netCheckLog['new_version'] = errDesc
                end

                if isUseIpv6 then
                    isUseIpv6 = self:redirectAssetsAddr(CUR_URL, true) -- 调整为域名地址
                    self:retryUpdateWhenDisconnect()
                elseif PLATFORM_CONFIG.MAIN_URL ~= PLATFORM_CONFIG.CFG_MAIN_URL and PLATFORM_CONFIG.MAIN_URL ~= PLATFORM_CONFIG.BACKUP_URL then
                    -- 获取失败，尝试从配置地址中获取
                    PLATFORM_CONFIG.MAIN_URL = PLATFORM_CONFIG.CFG_MAIN_URL
                    isUseIpv6 = self:redirectAssetsAddr(PLATFORM_CONFIG.MAIN_URL)
                    self:retryUpdateWhenDisconnect()
                elseif PLATFORM_CONFIG.MAIN_URL == PLATFORM_CONFIG.CFG_MAIN_URL and PLATFORM_CONFIG.BACKUP_URL then
                    -- 获取失败，尝试从备用地址中获取
                    PLATFORM_CONFIG.MAIN_URL = PLATFORM_CONFIG.BACKUP_URL
                    isUseIpv6 = self:redirectAssetsAddr(PLATFORM_CONFIG.MAIN_URL)
                    self:retryUpdateWhenDisconnect()
                else
                    self.updateDlg:setTips(CHSUP[2200004])
                end
            else
                -- 配置文件不需要更新，尝试更新补丁
                hasGetVer = true
                self:tryToDownloadPatch()
            end
            return
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            if hasGetVer then
                table.insert(assetsLog, string.format("connect to %s failed:%s", VER_PATCH_FILE, tostring(errNo)))
            else
                table.insert(assetsLog, string.format("connect to %s failed:%s", VERSION_URL, tostring(errNo)))
            end

            -- 网络异常，先默默重试
            self.startTime = nil == self.startTime and os.time() or self.startTime
            if os.time() - self.startTime < RETRY_DURATION then
                performWithDelay(self, function()
                    self:retryUpdateWhenDisconnect()
                end, 1)
            else

                errorTip = errorTip .. ':ASSETSMANAGER_NETWORK ERROR'
                self.startTime = nil

                if isUseIpv6 then
                    isUseIpv6 = self:redirectAssetsAddr(CUR_URL, true) -- 调整为域名地址
                    self:retryUpdateWhenDisconnect()
                elseif not hasCheckDomain then
                    -- 测试一下域名的情况(IPv6)
                    hasCheckDomain = true
                    isUseIpv6 = self:redirectAssetsAddr(PLATFORM_CONFIG.CFG_MAIN_URL) -- 调整为域名地址
                    self:retryUpdateWhenDisconnect()
                elseif not isBackup then
                    isBackup = true
                    isUseIpv6 = self:redirectAssetsAddr() -- 调整为备用地址
                    self:retryUpdateWhenDisconnect()
                else
                    -- 已经是备用地址了，给出提示信息
                    self:redirectAssetsAddr() -- 调整为备用地址
                    self:connectErrReport(self.updateState)
                    self:createConfirmDlg(errNo, CheckNetMgr:isEnabled(), netCheckLog)
                    self.loginConfrimDlg:setVisible(true)
                    assetsLog = {}
                end
            end
            --self:enterGame()
        elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
            self.updateDlg:setErrorTips(self:getCurOperateInfo(), CHSUP[3000161])
        elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
            self.updateDlg:setErrorTips(self:getCurOperateInfo(), CHSUP[3000162])
        else
            self.updateDlg:setErrorTips(self:getCurOperateInfo(), CHSUP[3000163] .. tostring(errorCode))
        end

        --tips:setString(errorTip)
        --self.reMmenu:setVisible(true)

        -- 判断是否需要显示进入游戏按钮
       --[[ local version = tonumber(self.assetsManager:getVersion())
        if nil == version then
            version = 0
        end

        local isMustUpdate = (version * 100) % 10
        if 0 == isMustUpdate then
            self.menu:setVisible(true)
        else
            self.reMmenu:setPosition(self.visibleSize.width / 2, self.visibleSize.height * 1 / 4)
        end]]
    end

    local function onProgress(percent)
        if percent < 0 then
            percent = 0
        end

        if self.updateState == UPDATE_DOWNLOAD_PATCH then
            local progress = string.format("downloading %d%%", percent)

            local size = 0
            local _curPatchFile

            if self.patchSizeInfo  then
                for i =1, self.downloadIndex - 2 do
                    _curPatchFile = getPatchNameEx(self.patchList[i])
                    if not _curPatchFile or not self.patchSizeInfo[_curPatchFile] then
                        _curPatchFile = self.patchList[i]
                    end
                    size = size + self.patchSizeInfo[_curPatchFile] or 0
                end
            end

            _curPatchFile = getPatchNameEx(self.patchList[self.downloadIndex - 1])
            if not _curPatchFile or not self.patchSizeInfo[_curPatchFile] then
                _curPatchFile = self.patchList[self.downloadIndex - 1]
            end
            size = size + self.patchSizeInfo[_curPatchFile] * percent / 100

            self.updateDlg:setLoadTips(self.downloadIndex - 1, #self.patchList, percent, size, self.totalSize)
        end
    end

    local function onSuccess()
        -- 尝试记录激活日志
        DeviceMgr:tryToSendActivateLogIfNeed()

        if self.updateState == UPDATE_DOWNLOAD_PATCH then
            -- 设置下载完的版本号
            local version = string.match(self.patchList[self.downloadIndex - 1], "atmu_.+_(.+).zip")
            if version then
                cc.UserDefault:getInstance():setStringForKey(KEY_OF_LOCAL_VERSION, version)
            end

            -- 继续下载补丁
            self:downloadPatch()
        else
            -- 尝试更新补丁
            self:tryToDownloadPatch()
        end
        self.startTime = os.time()
    end

    if self.assetsManager then
        return self.assetsManager
    end

    CUR_URL = PLATFORM_CONFIG.MAIN_URL
    local r, e = pcall(function() MAIN_URL, isUseIpv6 = getIpv6Url() end)
    if not r then
        Log:E(e)
        MAIN_URL = PLATFORM_CONFIG.MAIN_URL
    end

    VERSION_URL = MAIN_URL .. "/version.php"
    PATCH_CFG_URL = MAIN_URL .. "/get_patch.php"

    if not netCheckLog['versionAddress'] then
        netCheckLog['versionAddress'] = {}
    end
    table.insert(netCheckLog['versionAddress'], VERSION_URL)

    -- 为了防止相应的文件被长期缓存住，给相关文件的 url 追加一个时间信息
    -- AssetsManager 中要求 patch 对应的 url 中要包含  .zip，故加了个 .ziper
    local flag = "?t=" .. tostring(os.time())
    local assetsManager = cc.AssetsManager:new(PATCH_CFG_URL .. flag .. '.ziper', VERSION_URL .. flag, self.updatePath)
    assetsManager:retain()
    assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    assetsManager:setDelegate(onProgress, cc.ASSETSMANAGER_PROTOCOL_PROGRESS)
    assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )
    assetsManager:setConnectionTimeout(6)
    assetsManager:setUpdateCodePath(LOCAL_PATH)
    assetsManager:setLocalVersion(CUR_VERSION)
    assetsManager:setVerPathFile(VER_PATCH_FILE)
    if PLATFORM_CONFIG.HOST_NAME and assetsManager.setHost then
        assetsManager:setHost(PLATFORM_CONFIG.HOST_NAME)
    end
    assetsLog = {}
    return assetsManager
end

function UpdateScene:update()
    -- 当前 patch.zip 的内容有可能不正确，需要先清除该版本信息，以便能够正确获取 patch.zip
    cc.UserDefault:getInstance():setStringForKey(KEY_OF_DOWNLOADED_VERSION, "")
    cc.UserDefault:getInstance():flush()

    -- 先检测是否要更新配置信息
    self.updateState = UPDATE_BASIC

    -- 放在下一帧执行，以避免场景切换延后
    performWithDelay(self, function()
        self:initBackImage()
        if PLATFORM_CONFIG.FOR_SERVICE then
            -- 客服版本
            self:InputConfirm()
        else
            self:startUpdate()
        end
    end, 4.5)
end

-- 查看输入的值是否存在
function UpdateScene:hasChannel(channelNo)
    for _, channel in pairs(PLATFORM_CONFIG.FOR_SERVICE_LIST) do
        if channelNo == channel then
            return true
        end
    end

    return false
end

-- 清除本地补丁等数据
function UpdateScene:clearLocalCache()
    -- 先删除对应的版本patch信息
    cc.FileUtils:getInstance():removeDirectory(cc.FileUtils:getInstance():getWritablePath() .. "patch/")

    -- 删除对应代码及资源的路径
    cc.FileUtils:getInstance():removeDirectory(cc.FileUtils:getInstance():getWritablePath() .. LOCAL_PATH)

    cc.UserDefault:getInstance():setStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
    cc.UserDefault:getInstance():setStringForKey("current-version-code", "")
end

-- 输入渠道
function UpdateScene:InputConfirm()
    local runScene = cc.Director:getInstance():getRunningScene()
    local ConfirmEx = require("dlg/ConfirmDlgEx")
    if not ConfirmEx then return end
    local inputDlg = ConfirmEx.create()

    -- 清除补丁数据
    self:clearLocalCache()

    inputDlg:setCallBack(function(input)
        if not self:hasChannel(input) then
            self:updateConfirmDlg()
            return
        end

        setMainUrl(input)
        self:startUpdate()
        runScene:removeChild(inputDlg)
    end)
    runScene:addChild(inputDlg)
end

function UpdateScene:startUpdate()
    self:changeUpdateScence()
    tryToDownloadObb()
end

-- 更新提示
function UpdateScene:showUpdateNote(size)
    local runScene =  cc.Director:getInstance():getRunningScene()
    local UpdateConfrimDlg = require('dlg/UpdateConfrimDlg')
    local updateConfrimDlg = UpdateConfrimDlg.create()
    updateConfrimDlg:setName("UpdateConfrimDlg")
    updateConfrimDlg:setInfo(size, self, self.showUpdateConfirm, self.downloadPatch)
    runScene:addChild(updateConfrimDlg)
end

-- 更新提示点击取消后，继续给出确认提示框
-- 之前的更新提示框不会移除，若在再次弹出的确认提示框中点击取消，则回到之前的更新提示框
function UpdateScene:showUpdateConfirm()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local UpdateConfrimDlg = require('dlg/UpdateConfrimDlg')
    local updateConfrimDlg = UpdateConfrimDlg.create()
    updateConfrimDlg:setUpdateConfirmInfo(self, self.setUpdateConfrimDlgVisible, true)
    runScene:addChild(updateConfrimDlg)

    self:setUpdateConfrimDlgVisible(false)
end

function UpdateScene:setUpdateConfrimDlgVisible(isVisible)
    local runScene =  cc.Director:getInstance():getRunningScene()
    local updateConfrimDlg = runScene:getChildByName("UpdateConfrimDlg")
    if updateConfrimDlg then updateConfrimDlg:setVisible(isVisible) end
end

-- 显示输入渠道错误确认框
function UpdateScene:updateConfirmDlg()
    local runScene = cc.Director:getInstance():getRunningScene()
    local UpdateConfrimDlg = require('dlg/UpdateConfrimDlg')
    local updateConfrimDlg = UpdateConfrimDlg.create()
    updateConfrimDlg:setChannelInfo(self, function()
    end)
    runScene:addChild(updateConfrimDlg)
end

-- 初始化背景
function UpdateScene:initBackImage()
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    runScene:removeAllChildren()

    local LoginBack = require("dlg/LoginBack2019Dlg")
    local backNode = LoginBack.new()
    runScene:addChild(backNode)
end

function UpdateScene:changeUpdateScence()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)
    local UpdateDlg = require('dlg/UpdateDlg')
    self.updateDlg = UpdateDlg.create()
    self.updateDlg:setUpdateDlgState(1)
    self.updateDlg:initDefaulInfo(localVersion)
    runScene:addChild(self.updateDlg)
end

-- 显示网络检测界面
function UpdateScene:showCheckNetDlg()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local CheckNetDlg = require('dlg/CheckNetDlg')
    local checkNetDlg = CheckNetDlg.create(1, nil, netCheckLog)
    runScene:addChild(checkNetDlg)
end

-- 下载完整包
function UpdateScene:loadFullPackage()
    -- 尝试打开完整包下载链接
    local urls = self:getFullClientUrls() or {}
    local full_client_url = FULL_CLIENT_URL_FROM_PROP or urls[PLATFORM_CONFIG.FULL_CLIENT_KEY]
    if full_client_url then
        DeviceMgr:openUrl(full_client_url)
    end

    if DeviceMgr:isAndroid() then
        --performWithDelay(cc.Director:getInstance():getRunningScene(), function()
            cc.Director:getInstance():endToLua()
            if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
            cc.Director:getInstance():mainLoop()
            end
        --end, 0.1)
    end
end

function UpdateScene:retryUpdateWhenDisconnect()
    if  self.needUpdate then
        -- 前往下载完整包
        self:loadFullPackage()
    elseif self.updateState == UPDATE_BASIC then
        if self.assetsManager and type(self.assetsManager.isDownloading) == "function" then
            if not self.assetsManager:isDownloading() then
                self.assetsManager:update(self.updateState)
                fixDuplicatePath()
            else
                performWithDelay(self, function()
                    self:retryUpdateWhenDisconnect()
                end, 0)
            end
        else
            performWithDelay(self, function()
                self.assetsManager:update(self.updateState)
                fixDuplicatePath()
            end, 0.1)
        end
    elseif self.updateState == UPDATE_DOWNLOAD_PATCH then
        self.downloadIndex = self.downloadIndex - 1
        self:downloadPatch()
    elseif self.updateState == LOADED_PATCH then
        --self:enterGame()
        self:gameStart()
    end
end

-- 弹出确认框
function UpdateScene:showConfirmDlg(text, onConfirm, onCheck, showOther)
    -- 确认回调
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 隐藏界面
            self.loginConfrimDlg:setVisible(false)

            -- retryUpdateWhenDisconnect 有可能会执行较长时间，故延后执行，以免卡在提示界面
            performWithDelay(self.loginConfrimDlg, function()
                if 'function' == type(onConfirm) then
                    onConfirm()
                end
            end, 0)
        end
    end

    -- 检查回调
    local function checkListener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                performWithDelay(self.loginConfrimDlg, function()
                    if 'function' == type(onCheck) then
                        onCheck()
                    end
                end, 0)
            end
        end

    if self.loginConfrimDlg then
        local root = self.loginConfrimDlg:getChildByName("root")
        local widget = ccui.Helper:seekWidgetByName(root, "ConfrimButton")
        if widget then
            widget:setVisible(not showOther)
            widget:addTouchEventListener(listener)
        end

        widget = ccui.Helper:seekWidgetByName(root, "ConfrimButton_1")
        if widget then
            widget:setVisible(showOther)
            widget:addTouchEventListener(listener)
        end

        widget = ccui.Helper:seekWidgetByName(root, "CheckButton")
        if widget then
            widget:setVisible(showOther)
            widget:addTouchEventListener(checkListener)
        end
        self.loginConfrimDlg:setVisible(true)
        return
    end
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/LoginConfrimDlg.json"

    self.loginConfrimDlg = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    self.loginConfrimDlg:setContentSize(size)

    local root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    root:setAnchorPoint(0.5, 0.5)
    root:setPosition(size.width / 2, size.height / 2)
    root:setName("root")
    self.loginConfrimDlg:addChild(root)

    local widget = ccui.Helper:seekWidgetByName(root, "ConfrimButton")

    local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)

    if text then
        local noteLabel = ccui.Helper:seekWidgetByName(root, "NoteLabel")
        noteLabel:setString(text)
    end

    widget:setVisible(not showOther)
    widget:addTouchEventListener(listener)

    -- ConfrimButton_2
    local widget = ccui.Helper:seekWidgetByName(root, "ConfrimButton_1")
    if widget then
        widget:addTouchEventListener(listener)
        widget:setVisible(showOther)
    end

    -- CheckButton
    local widget = ccui.Helper:seekWidgetByName(root, "CheckButton")
    if widget then
        widget:addTouchEventListener(checkListener)
        widget:setVisible(showOther)
    end

    local runScene =  cc.Director:getInstance():getRunningScene()
    runScene:addChild(self.loginConfrimDlg)
    self.loginConfrimDlg:setVisible(true)
end

-- 断线重新连接
function UpdateScene:createConfirmDlg(errDesc, showOther, data)
    local tips
    if errDesc then
        tips = string.format(CHSUP[2000127], tostring(errDesc))
    end

    if not showOther then
        self:showConfirmDlg(tips, function()
            self:retryUpdateWhenDisconnect()
        end)
    else
        self:showConfirmDlg(tips, function()
            self:retryUpdateWhenDisconnect()
        end, function()
            local CheckNetDlg = require('dlg/CheckNetDlg')
            local checkNetDlg = CheckNetDlg.create(1, function(isSucc)
                if isSucc then
                    self.loginConfrimDlg:setVisible(false)
                    performWithDelay(self.loginConfrimDlg, function()
                        self:retryUpdateWhenDisconnect()
                    end, 0)
                end
            end, data)
            local runScene =  cc.Director:getInstance():getRunningScene()
            runScene:addChild(checkNetDlg)
        end, showOther)
    end
end

function UpdateScene:createCheckFailConfirm()
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/LoginConfrimDlg.json"

    self.loginConfrimDlg = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    self.loginConfrimDlg:setContentSize(size)



    local root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    root:setAnchorPoint(0.5, 0.5)
    root:setPosition(size.width / 2, size.height / 2)
    self.loginConfrimDlg:addChild(root)

    local widget = ccui.Helper:seekWidgetByName(root, "ConfrimButton")

    local noteLabel = ccui.Helper:seekWidgetByName(root, "NoteLabel")
    noteLabel:setString(CHSUP[2000159])

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:loadFullPackage()
        end
    end

    widget:addTouchEventListener(listener)

    local runScene =  cc.Director:getInstance():getRunningScene()
    runScene:addChild(self.loginConfrimDlg)
end

-- 创建更新完等待界面
function UpdateScene:createUpdateWaitDlg()
    local size = cc.Director:getInstance():getWinSize()
    local winSize = getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/WaitDlg.json"
    self.updateWaitDlg = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    self.updateWaitDlg:setAnchorPoint(0.5, 0.5)
    self.updateWaitDlg:setPosition(size.width / 2 + winSize.x, size.height / 2 + winSize.y)

    local image = ccui.ImageView:create("ui/Icon0250.png")
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    image:runAction(action)
    image:setAnchorPoint(0.5, 0.5)
    image:setScale(0.8)
    image:setPosition(self.updateWaitDlg:getContentSize().width / 2, self.updateWaitDlg:getContentSize().height / 2)
    self.updateWaitDlg:addChild(image, 10, 10)
    self.updateWaitDlg:setTouchEnabled(true)

    local deily = cc.DelayTime:create(2)
    local func = cc.CallFunc:create(function()
        --runScene:removeChild(self.updateWaitDlg)
        self.updateWaitDlg:setVisible(false)
        self:createConfirmDlg()

        local root = self.loginConfrimDlg:getChildByName("root")
        local label = ccui.Helper:seekWidgetByName(root, "NoteLabel")
        label:setString(CHSUP[3000164])
        self.updateState = LOADED_PATCH
        self.loginConfrimDlg:setVisible(true)
        self.updateWaitDlg = nil
    end)

    self.updateWaitDlg:runAction(cc.Sequence:create(deily, func))
    runScene:addChild(self.updateWaitDlg)
end

function UpdateScene:checkNetConnection(callback)
    local msg = {}
    require("mgr/CheckNetMgr")

    local function sendCallback()
        if 'function' == type(callback) and msg and msg.ping and msg.traceRout then
            callback(msg)
        end
    end

    if UPDATE_BASIC == state then
        -- 下载配置中
        local ip = CheckNetMgr:getIpByHost("update.leiting.com")
        if ip then
            CheckNetMgr:ping(function(s)
                -- table.insert(logs, s)
                msg['ping'] = s
                sendCallback()
            end, ip)
            CheckNetMgr:traceroute(function(s)
                -- table.insert(logs, s)
                msg['traceRout'] = s
                sendCallback()
            end, ip)
        end
    elseif UPDATE_DOWNLOAD_PATCH == state then
        -- 下载补丁中
        local ip = CheckNetMgr:getIpByHost("atmdl.leiting.com")
        if ip then
            CheckNetMgr:ping(function(s)
                -- table.insert(logs, s)
                msg['ping'] = s
                sendCallback()
            end, ip)
            CheckNetMgr:traceroute(function(s)
                -- table.insert(logs, s)
                msg['traceRout'] = s
                sendCallback()
            end, ip)
        end
    end
end

-- 错误上报
function UpdateScene:connectErrReport(state)
    if not conLog then return end

    local logs = {}
    table.insert(logs, table.concat(conLog, '\n'))
    if assetsLog then
        local logstr = table.concat(assetsLog, '\n')
        table.insert(logs, logstr)
        netCheckLog['memo'] = table.concat(logs, '\n')
    end

    if 0 ~= DeviceMgr:getNetWorkStatus() then
        -- 上报平台
        local account = cc.UserDefault:getInstance():getStringForKey("user",  "a")
        netCheckLog['account'] = account
        CheckNetMgr:logReportNetCheck(netCheckLog)
    else
        local function createDebugDlg(errDesc)
            local size = cc.Director:getInstance():getWinSize()
            local runScene =  cc.Director:getInstance():getRunningScene()
            local jsonName =  "ui/GMDebugTipsDlg.json"

            local dlg = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
            dlg:setContentSize(size)

            local root = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
            root:setAnchorPoint(0.5, 0.5)
            root:setPosition(size.width / 2, size.height / 2)
            root:setName("root")
            dlg:addChild(root)

            if errDesc then
                local tipsLabel = ccui.Helper:seekWidgetByName(root, "TipsLabel")
                tipsLabel:setString(errDesc)
            end

            local title1 = ccui.Helper:seekWidgetByName(root, "TitleLabel_1")
            title1:setString(CHSUP[2300003])
            local title2 = ccui.Helper:seekWidgetByName(root, "TitleLabel_2")
            title2:setString(CHSUP[2300003])

            local captureBtn = ccui.Helper:seekWidgetByName(root, "CaptureButton")
            captureBtn:setVisible(false)

            local closeBtn = ccui.Helper:seekWidgetByName(root, "CloseButton")
            local function listener2(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    dlg:removeFromParent()
                end
            end
            closeBtn:addTouchEventListener(listener2)

            local runScene =  cc.Director:getInstance():getRunningScene()
            runScene:addChild(dlg)
        end

        createDebugDlg("AssetsManager error:\n" .. table.concat(logs, '\n'))
    end
end

-- 资源释放
function UpdateScene:onNodeCleanup()
    if self.assetsManager then
        self.assetsManager:release()
        self.assetsManager = nil
    end
end

return UpdateScene
