-- UpdateCheck.lua
-- Created by sujl, May/20/2016
-- 游戏内自动更新检测

local UpdateCheck = class("UpdateCheck")

local PLATFORM_CONFIG = require("PlatformConfig")

-- 版本号
local CUR_VERSION = PLATFORM_CONFIG.CUR_VERSION

-- 更新的状态
local UPDATE_BASIC = 0
local UPDATE_DOWNLOAD_PATCH = 1
local UPDATE_FULL_PACK = 2
local LOADED_PATCH = 3 -- 加载完补丁

-- 区组信息文件
local DIST_INFO_FILE = 'patch/dist.lua'

-- 补丁下载地址列表文件
local PATCH_URL_FILE = 'patch/patch_url.lua'

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

-- 当前 patch.zip 对应的版本信息
local KEY_OF_DOWNLOADED_VERSION = "downloaded-version-code"

-- 更新公告信息
local UPDATE_DESC = 'patch/UpdateDesc.lua'
local OFFLINE_ACTIVE = 'patch/OffLineActive.lua'

-- 渠道信息
local CHANNEL_NO
local CHANNEL_SUFFIX
local conLog = {}

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

local MAIN_URL
local VERSION_URL
local PATCH_CFG_URL
local CUR_URL
local isUseIpv6

-- 设置 version.php 和 get_patch.php 的地址
local function resetUrl()
    local r, e = pcall(function() MAIN_URL, isUseIpv6 = getIpv6Url() end)
    if not r then
        Log:E(e)
        MAIN_URL = PLATFORM_CONFIG.MAIN_URL
    end

    VERSION_URL = MAIN_URL .. "/version.php"
    PATCH_CFG_URL = MAIN_URL .. "/get_patch.php"
    CUR_URL = PLATFORM_CONFIG.MAIN_URL
    return isUseIpv6
end

isUseIpv6 = resetUrl()

-- 断线重连重试时间
local RETRY_DURATION = 3

local _assetsManager = nil
local _assetsManagerRef = 0

local function tryRetainAssetsManager()
    _assetsManagerRef = _assetsManagerRef + 1
end

local function tryReleaseAssetsManager()
    _assetsManagerRef = math.max(_assetsManagerRef - 1, 0)
    if _assetsManager and _assetsManagerRef <= 0 then
        _assetsManager:release()
        _assetsManager = nil
    end
end

UpdateCheck.updatePath = cc.FileUtils:getInstance():getWritablePath()

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

-- 修复路径重复问题
local function fixDuplicatePath()
    if 'function' == type(gfIsFuncEnabled) and gfIsFuncEnabled(14) then
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

function UpdateCheck:ctor()
    self.onFinish = nil
    self.netCheckLog = {}
    tryRetainAssetsManager()
end

function UpdateCheck:dispose()
    self:cleanup()
    tryReleaseAssetsManager()
end

-- 获取区组信息
function UpdateCheck:getAllDistInfo()
    return dofile(self.updatePath .. DIST_INFO_FILE)
end

    -- 获取补丁包大小
function UpdateCheck:getPatchSize()
    return dofile(self.updatePath .. PATCH_SIZE_FILE)
end

function UpdateCheck:getDist()
    if self.distName then
        return DistMgr:getDistInfoByName(self.distName)
    end
end

-- 获取各个渠道完整包下载地址
function UpdateCheck:getFullClientUrls()
    return dofile(self.updatePath .. FULL_CLIENT_URL_FILE)
end

-- 获取当前要登录的区组 todo
function UpdateCheck:getCurrentDistName()
    local allDistInfo = self:getAllDistInfo()

    if allDistInfo and allDistInfo.default.dist then
        return allDistInfo.default.dist
    end

    return 'patch_test'
end

-- 检查是否时放行账号
function UpdateCheck:checkEnterPermission()
    local allDistInfo = self:getAllDistInfo()
    local account = Client:getAccount()
    if allDistInfo and allDistInfo.default and allDistInfo.default.accList then
        for i = 1, #allDistInfo.default.accList do
            if allDistInfo.default.accList[i] == account then return true end
        end
    end
end

-- 尝试检查是否需要补丁
function UpdateCheck:tryToCheckPatch()
    local info = self:getAllDistInfo()

    local defaultInfo = info.default
    if not defaultInfo then
        gf:ShowSmallTips(CHSUP[3000153])
        return
    end

    local distName = self:getCurrentDistName()
    local distInfo = info[distName]
    if not distInfo then
        --[[
        gf:ShowSmallTips(CHSUP[3000154] .. distName .. CHSUP[3000155])
        return]]
        distInfo = {}
    end

    if not distInfo.ver then
        -- 未指定版本号，使用默认版本号
        distInfo.ver = defaultInfo.ver
    end

    local remoteVer = distInfo.ver

    if defaultInfo.review_ver and defaultInfo.review_ver ~= "" then
        -- 设置了评审版本信息
        if defaultInfo.review_ver == CUR_VERSION then
            -- 评审版本比当前要求的版本高且当前客户端版本为评审版本
            -- 故该版本为评审版本，要求的版本号需要修改为评审版本号
            remoteVer = defaultInfo.review_ver
        end
    end

    if not distInfo.bundleForUpdate then
        distInfo.bundleForUpdate = defaultInfo.bundleForUpdate
    end

    self.distInfo = distInfo
    _assetsManager:setRemoteVersion(remoteVer)

    -- 判断是否强制更新
    if defaultInfo.force_update_version then
        if remoteVer == getMaxVeriosn(remoteVer, defaultInfo.force_update_version) then -- 要求进入游戏版本号 大于等于 强制更新版本
            if CUR_VERSION == getMaxVeriosn(CUR_VERSION, defaultInfo.new_package_first_version) then
                -- 本地母包的版本号 大于等于要求强制更新的最低要求母包，则进入游戏检测流程
                self:updateCheckGame()
            else
                -- 强制更新
                self:perReloadGame()
            end
        else
            if CUR_VERSION == getMaxVeriosn(CUR_VERSION, defaultInfo.new_package_first_version) then
                -- 本地母包的版本号 大于等于要求强制更新的最低要求母包，则进入游戏检测流程
                self:updateCheckGame()
            else
                -- 强制更新有效期
                local lastTipsTime =  cc.UserDefault:getInstance():getIntegerForKey("forceUpdateTipsTime", 0)
                if not self:isHavePatch() and not self:isSameDay(os.time(), lastTipsTime) then    -- 没有补丁并且今天没有弹出过提示
                    -- 可以强制更新或者下补丁进去
                    self:createForeUpdateDlg(defaultInfo.update_package_time or "")
                    cc.UserDefault:getInstance():setIntegerForKey("forceUpdateTipsTime", os.time())
                else
                    self:updateCheckGame()
                end
            end
        end
    else
        -- 没有强制更新版本进入游戏检测流程
        self:updateCheckGame()
    end
end

-- 当前时间跟目标时间是否是同一天
function UpdateCheck:isSameDay(curTi, ti)
    if math.abs(curTi - ti) > 24 * 3600
        or os.date("%d", curTi) ~= os.date("%d", ti) then
        return false
    end

    return true
end

-- 弹出重启游戏操作
function UpdateCheck:perReloadGame()
    if gf:isIos() and GameMgr.scene and "LoginScene" ~= GameMgr.scene:getType() then
        Client:doGSDisConnect({})
    else
        gf:confirm(string.format(CHS[2000094]), function()
            -- 重启游戏
            performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                self:reloadGame()
            end, 0)
        end, function()
            -- 退出游戏
            performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                cc.Director:getInstance():endToLua()
                if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                    cc.Director:getInstance():mainLoop()
                end
            end, 0.1)
        end)
    end
end

-- 进入游戏的检测流程
function UpdateCheck:updateCheckGame()
    local info = self:getAllDistInfo()
    local defaultInfo = info.default
    if self:isHavePatch() and self.onFinish then
        self:perReloadGame()
    else
        -- 检查服务器状态
        DistMgr:setDistList(dofile(self.updatePath .. DIST_INFO_FILE))
        local dist = self:getDist()
        if dist and dist["state"] == 1 and not self:checkEnterPermission() then -- 维护中
            local maintenance_tip
            if dist.maintenance_tip then  -- 区组配置了维护提示信息
                maintenance_tip = dist.maintenance_tip
            elseif defaultInfo.maintenance_tip then  -- 配置了default的维护提示信息
                maintenance_tip = defaultInfo.maintenance_tip
            else
                maintenance_tip = CHS[3003793]
            end

            local dlg = DlgMgr:openDlg("MaintenanceConfirmDlg")
            dlg:setText(maintenance_tip)
            self:doFinish(false)
        else
            -- 可以进入游戏了
            self:doFinish(true)
        end
    end
end

-- 是否有补丁
function UpdateCheck:isHavePatch()
    local patchFiles = _assetsManager:getPatchFiles()
    local patchList = {}
    local last = 1
    local s = string.find(patchFiles, ',')
    while s do
        table.insert(patchList, string.sub(patchFiles, last, s - 1))
        last = s + 1
        s = string.find(patchFiles, ',', last)
    end

    s = string.sub(patchFiles, last)
    if s ~= "" then
        table.insert(patchList, s)
    end

    if self.distInfo and self.distInfo.bundleForUpdate and '*' ~= self.distInfo.bundleForUpdate and 0 == #patchList then
        for i = 1, #self.distInfo.bundleForUpdate do
            if self.distInfo.bundleForUpdate[i] == CUR_VERSION then
                table.insert(patchList, string.format("%s_%s%s.zip", tostring(CUR_VERSION), tostring(CHANNEL_NO), tostring(CHANNEL_SUFFIX)))
                break
            end
        end
    end

    local size = 0
    local patchSizeInfo = self:getPatchSize()

    if patchSizeInfo  then
        for i =1, #patchList do
            size = size + patchSizeInfo [patchList[i]] or 0
        end
    end

    if size > 0 and #patchList > 0 then
        return true
    else
        return false
    end
end


-- 下载完整包
function UpdateCheck:loadFullPackage()
    -- 尝试打开完整包下载链接
    local urls = self:getFullClientUrls() or {}
    if urls[PLATFORM_CONFIG.FULL_CLIENT_KEY] then
        DeviceMgr:openUrl(urls[PLATFORM_CONFIG.FULL_CLIENT_KEY])
    end

    if DeviceMgr:isAndroid() then
        -- performWithDelay(cc.Director:getInstance():getRunningScene(), function()
            cc.Director:getInstance():endToLua()
            if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_ANDROID then
                cc.Director:getInstance():mainLoop()
            end
        -- end, 0.1)
    end
end


-- 强制更新提示
function UpdateCheck:createForeUpdateDlg(updatePackageTime)
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/LoginForceUpdateDlg.json"
    local dlg = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    dlg:setAnchorPoint(0.5, 0.5)
    dlg:setPosition(size.width / 2, size.height / 2)

    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    colorLayer:setContentSize(size)
    colorLayer:addChild(dlg)

    local urls = self:getFullClientUrls() or {}
    local full_client_url = urls[PLATFORM_CONFIG.FULL_CLIENT_KEY]
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

    local tip = string.format(showGotoBtn and CHSUP[6000001] or CHSUP[2000179], updatePackageTime)
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
            self:updateCheckGame()
        end
    end

    continueBtn:addTouchEventListener(continueListener)

    if showGotoBtn then
        local goOnBtn = ccui.Helper:seekWidgetByName(root, "ConfrimButton")
        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                -- 强制更新
                colorLayer:setVisible(false)
                self:loadFullPackage()
            end
        end

        goOnBtn:addTouchEventListener(listener)
    end

    runScene:addChild(colorLayer)
end

function UpdateCheck:doFinish(result)
    if self.onFinish and 'function' == type(self.onFinish) then
        self.onFinish(result)
    end
end

-- 重启载入游戏
function UpdateCheck:reloadGame()
    -- 清除一些全局变量
    GameMgr:stop()

    -- 卸载游戏脚本
    for k, v in pairs(package.loaded) do
        if not initModules[k] then
            package.loaded[k] = nil
        end
    end

    cc.FileUtils:getInstance():purgeCachedEntries()

    -- 重新运行更新场景
    package.loaded['scene/UpdateScene'] = nil
    local UpdateScene = require('scene/UpdateScene')
    if 'function' == type(UpdateScene.reloadScript) then
        UpdateScene.reloadScript()
    else
        -- 兼容旧的UpdateScene，下次强更时可以删除这段代码
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
        reloadScript()
    end
    Const = nil -- WDSY-26137
    local updateScene = UpdateScene.create(self.updatePath)
    local director = cc.Director:getInstance()
    if director:getRunningScene() then
        director:replaceScene(updateScene)
    else
        director:runWithScene(updateScene)
    end

    local userDefault = cc.UserDefault:getInstance()
    local noUpdate = userDefault:getIntegerForKey("noupdate", 0);

    -- 移除全局变量
    local toBeRemove = {}
    for k, _ in pairs(_G) do
        if not __globalVars__[k] then
            table.insert(toBeRemove, k)
        end
    end

    for i = 1, #toBeRemove do
        _G[toBeRemove[i]] = nil
    end

    if noUpdate == 1 then
        -- 直接进入游戏
        updateScene:enterGame()
    else
        -- 检查更新
        updateScene:update()
    end
end

function UpdateCheck:getNetCheckLog()
    if next(self.netCheckLog) then
        return self.netCheckLog
    end
end

-- 断线重新连接
function UpdateCheck:createConfirmDlg(errDesc, callback)
    local size = cc.Director:getInstance():getWinSize()
    local runScene =  cc.Director:getInstance():getRunningScene()
    local jsonName =  "ui/LoginConfrimDlg.json"
    local confirmDlg = ccs.GUIReader:getInstance():widgetFromJsonFile(jsonName)
    confirmDlg:setAnchorPoint(0.5, 0.5)
    confirmDlg:setPosition(size.width / 2, size.height / 2)


    local colorLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    colorLayer:setContentSize(size)
    colorLayer:addChild(confirmDlg)
    local widget = ccui.Helper:seekWidgetByName(confirmDlg, "ConfrimButton")
    local localVersion = cc.UserDefault:getInstance():getStringForKey(KEY_OF_LOCAL_VERSION, CUR_VERSION)

    if errDesc then
        local noteLabel = ccui.Helper:seekWidgetByName(confirmDlg, "NoteLabel")
        noteLabel:setString(errDesc)
    end
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            -- 隐藏界面
            colorLayer:removeFromParent(true)
            if callback and 'function' == type(callback) then
                callback()
            end
        end
    end

    widget:addTouchEventListener(listener)
    gf:getUILayer():addChild(colorLayer)
    return colorLayer
end

function UpdateCheck:doCheck(distName, onFinish)
    if DistMgr.forReview then
        onFinish(true)
        return
    end

    self.onFinish = onFinish
    self.distName = distName
    self.netCheckLog = {}

    if not CHANNEL_NO then
        CHANNEL_NO = getPropertiesValue('channelType')
    end
    if not CHANNEL_SUFFIX then
        CHANNEL_SUFFIX = getPropertiesValue("suffix")
        if CHANNEL_NO == CHANNEL_SUFFIX then CHANNEL_SUFFIX = "" end
    end

    isUseIpv6 = resetUrl()

    local flag = "?t=" .. tostring(os.time())

    if not _assetsManager then
        -- 网络有可能切换了，需要重新设置 version.php 和 get_patch.php 的地址
        isUseIpv6 = resetUrl()

        _assetsManager = cc.AssetsManager:new(PATCH_CFG_URL .. flag .. '.ziper', VERSION_URL .. flag, self.updatePath)
        _assetsManager:retain()

        _assetsManager:setConnectionTimeout(3)
        _assetsManager:setUpdateCodePath(LOCAL_PATH)
        _assetsManager:setLocalVersion(CUR_VERSION)
        _assetsManager:setVerPathFile(VER_PATCH_FILE)

        if not self.netCheckLog['versionAddress'] then
            self.netCheckLog['versionAddress'] = {}
        end
        table.insert(self.netCheckLog['versionAddress'], VERSION_URL)

        if PLATFORM_CONFIG.HOST_NAME and _assetsManager.setHost then
            _assetsManager:setHost(PLATFORM_CONFIG.HOST_NAME)
        end
    end

    -- 重定向为备用地址
    local function redirectAssetsAddr(newUrl, disalbeIpv6)
        if not _assetsManager then return end

        local backupUrl, isUseIpv6
        if not disalbeIpv6 then
            backupUrl, isUseIpv6 = getIpv6Url(newUrl or PLATFORM_CONFIG.BACKUP_URL)
        else
            backupUrl = newUrl or PLATFORM_CONFIG.BACKUP_URL
            isUseIpv6 = false
        end
        if not backupUrl or "" == backupUrl then return end     -- 没有配置备用地址

        local flag = "?t=" .. tostring(os.time())
        CUR_URL = newUrl
        VERSION_URL = backupUrl .. "/version.php" .. flag
        PATCH_CFG_URL = backupUrl .. "/get_patch.php" .. flag .. '.ziper'
        _assetsManager:setPackageUrl(PATCH_CFG_URL)
        _assetsManager:setVersionFileUrl(VERSION_URL)

        if not self.netCheckLog['versionAddress'] then
            self.netCheckLog['versionAddress'] = {}
        end
        table.insert(self.netCheckLog['versionAddress'], VERSION_URL)

        return isUseIpv6
    end

    local function retryUpdate()
        if _assetsManager and type(_assetsManager.isDownloading) == "function" then
            if not _assetsManager:isDownloading() then
                _assetsManager:update(self.updateState)
                fixDuplicatePath()
            else
                performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                    retryUpdate()
                end, 0)
            end
        else
            performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                _assetsManager:update(self.updateState)
                fixDuplicatePath()
            end, 0.1)
        end
    end

    local errorTips = {}
    local hasGetVersion
    local hasCheckDomain
    local isBackup
    local function onError(errorCode, errorDesc, errNo)
        local curVersionCode = cc.UserDefault:getInstance():getStringForKey("current-version-code", "")
        local downVersionCode = cc.UserDefault:getInstance():getStringForKey("downloaded-version-code", "")

        if errorCode == cc.ASSETSMANAGER_NO_NEW_VERSION then
            -- 配置文件不需要更新，尝试更新补丁
            hasGetVersion = true
            self:tryToCheckPatch()
        elseif errorCode == cc.ASSETSMANAGER_NETWORK then
            if hasGetVersion then
                table.insert(conLog, string.format("connect to %s failed:%s", PATCH_CFG_URL, tostring(errNo)))
            else
                table.insert(conLog, string.format("connect to %s failed:%s", VERSION_URL, tostring(errNo)))
            end

            -- 网络异常，先默默重试
            self.startTime = nil == self.startTime and os.time() or self.startTime
            if os.time() - self.startTime < RETRY_DURATION then
                performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                    _assetsManager:update(self.updateState)
                    fixDuplicatePath()
                end, 1)
                return
            else
                self.startTime = nil
                if not errorTips then
                    errorTips = {}
                end
                table.insert(errorTips, tostring(errNo))

                if isUseIpv6 then
                    isUseIpv6 = redirectAssetsAddr(CUR_URL, true) -- 调整为域名地址
                    retryUpdate()
                    return
                elseif not hasCheckDomain then
                    -- 测试一下域名的情况(IPv6)
                    hasCheckDomain = true
                    isUseIpv6 = redirectAssetsAddr(PLATFORM_CONFIG.CFG_MAIN_URL)        -- 重定向为域名地址
                    retryUpdate()
                    return
                elseif not isBackup then
                    isBackup = true
                    isUseIpv6 = redirectAssetsAddr()        -- 重定向为备用地址
                    retryUpdate()
                    return
                else
                    local tip = CHS[2300023]
                    if errorTips and #errorTips > 0 then
                        tip = tip .. CHS[2300024]
                        tip = tip .. table.concat(errorTips, ",")
                    end

                    Client:tipWhenCannotConnect()

                    local dlg = self:createConfirmDlg(tip, function()
                        performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                            if GameMgr.scene and "LoginScene" ~= GameMgr.scene:getType() then
                                Client:doGSDisConnect({})
                            else
                                self:doFinish(false)
                            end
                        end, 0)
                    end)

                    local logStr = table.concat(conLog, '\n')
                    self.netCheckLog['memo'] = logStr
                    local account = cc.UserDefault:getInstance():getStringForKey("user",  "a")
                    self.netCheckLog['account'] = account
                    CheckNetMgr:logReportNetCheck(self.netCheckLog)
                    conLog = {}
                end
            end
        elseif errorCode == cc.ASSETSMANAGER_CREATE_FILE then
            gf:ShowSmallTips('[' .. curVersionCode .. ' ' .. downVersionCode .. ' ' .. CHSUP[3000156] .. '] ' .. CHSUP[3000161])
        elseif errorCode == cc.ASSETSMANAGER_UNCOMPRESS then
            gf:ShowSmallTips('[' .. curVersionCode .. ' ' .. downVersionCode .. ' ' .. CHSUP[3000156] .. '] ' .. CHSUP[3000162])
        else
            gf:ShowSmallTips('[' .. curVersionCode .. ' ' .. downVersionCode .. ' ' .. CHSUP[3000156] .. '] ' .. CHSUP[3000163] .. tostring(errorCode))
        end
        tryReleaseAssetsManager()
    end

    local function onSuccess()
        if self.updateState == UPDATE_BASIC then
            self:tryToCheckPatch()
        end
        self.startTime = os.time()

        tryReleaseAssetsManager()
    end

    _assetsManager:setDelegate(onError, cc.ASSETSMANAGER_PROTOCOL_ERROR )
    _assetsManager:setDelegate(onSuccess, cc.ASSETSMANAGER_PROTOCOL_SUCCESS )

    tryRetainAssetsManager()

    self.updateState = UPDATE_BASIC
    _assetsManager:update(UPDATE_BASIC)
    fixDuplicatePath()
    conLog = {}
end

function UpdateCheck:cleanup()
    self.onFinish = nil
    self.distName = nil
    self.netCheckLog = {}
    isUseIpv6 = nil
    CUR_URL = nil
end

function releaseAllUpdateCheckReqs()
    _assetsManagerRef = 0
    if _assetsManager then
        _assetsManager:release()
        _assetsManager = nil
    end
end

return UpdateCheck
