require "Cocos2d"
require('src/core/Log')
inspect = require("src/inspect")

-- 是否为 debug 版本
ATM_IS_DEBUG_VER = gfIsDebug()

-- 是否启用性能分析
local ENABLE_PROFILE = false

local time_profile = { st = {}, ct = {} }

-- 帧数
local FPS = 30

local function _formatValue(v)
    if 'string' == type(v) then
        if 'function' == type(gfConvertToCString) and 'function' == type(gfConvertBufferToString) and #v > #gfConvertToCString(v) then
            -- buffer
            return string.format("%s", gfConvertBufferToString(v))
        else
            return string.format("'%s'", tostring(v))
        end
    else
        return tostring(v)
    end
end

local function indent(c)
    local indent = ""
    for k = 1, c do
        indent = indent .. "    "
    end
    return indent
end

function tostringex(v, m, i, l)
    if not m then m = {} end
    if nil == i then i = 1 end
    local ret = ""
    l = l or 3

    if m[v] then
        ret = m[v]
    elseif type(v) == "table" then
        local t = ""
        m[v] = _formatValue(v)
        for k, v1 in pairs(v) do
            if type(v1) ~= 'function' then
                if i < l then
                    t = t .. indent(i) .. tostring(k) .. ":" .. tostringex(v1, m, i + 1, l) .. ',\n'
                else
                    t = t .. indent(i) .. tostring(k) .. ":" .. _formatValue(v1) .. ',\n'
                end
            end
        end
        ret = "\n" .. indent(i - 1) .. "{\n" .. t .. indent(i - 1) .. "}"
    else
        ret = _formatValue(v)
    end

    return ret
end

local myTraceback = function()
    local ret = ""
    local level = 3
    ret = ret .. "stack traceback: "
    while true do
        -- get stack info
        local info = debug.getinfo(level, "Sln")
        if not info then break end

        if info.what == "C" then
            -- C function
            ret = ret .. tostring(level) .. "C function\n"
        else
            -- Lua function
            ret = ret .. string.format("%s:%d in `%s`\n", info.short_src, info.currentline, info.name or "")
        end

        -- get local vars
        local i = 1
        while true do
            local name, value = debug.getlocal(level, i)
            if not name then break end

            ret = ret .. "  " .. name .. " = " .. tostringex(value) .. "\n"

            i = i + 1
        end

        level = level + 1
    end

    return ret
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

-- for CCLuaEngine traceback
-- 注意，需要同步修改GlobalFunc中相应的函数
function __G__TRACKBACK__(msg)
    local logMsg = tostring(msg) .. "\n" .. myTraceback()

    -- 显示设备和用户信息
    logMsg = logMsg .. ">>>>>>>>>>>>>>>>>\n"
    if DeviceMgr then
        local termInfo = DeviceMgr:getTermInfo()
        local osVer = DeviceMgr:getOSVer()
        logMsg = string.format("%sterm_info:%s, os_ver:%s\n", logMsg, termInfo and termInfo or "unknown", osVer and osVer or "unknown")
    end
    if cc.UserDefault:getInstance() then
        logMsg = string.format("%sdist:%s, version:%s\n", logMsg,  cc.UserDefault:getInstance():getStringForKey("lastLoginDist"),
            cc.UserDefault:getInstance():getStringForKey("local-version"))
    end
    logMsg = string.format("%sdata:%s", logMsg, os.date())

    -- 显示日志
    Log:E("%s", logMsg)

    -- 记入报错日志
    ftpUploadLog(logMsg)    -- 此处直接上传

    logMsg = logMsg.."\n-------- __G__TRACKBACK__ >>>>>>>>"
	return msg
end

local function main()
    collectgarbage("collect")

    -- avoid memory leak
    collectgarbage("setpause", 100)
    collectgarbage("setstepmul", 200) -- 将5000减少为200，减缓回收速度，使垃圾回收过程中对帧率的影响可以小一些

    -- 设置启用报错日志放在日期目录下
    -- cc.UserDefault:getInstance():setBoolForKey("pathByDay", true)
    -- cc.UserDefault:getInstance():flush()

    -- 优先搜索更新目录中内容
    local updatePath = cc.FileUtils:getInstance():getWritablePath()
    cc.FileUtils:getInstance():addSearchPath(updatePath .. "atmu/src")
    cc.FileUtils:getInstance():addSearchPath(updatePath .. "atmu/res")
    Log:I('Update path:' .. updatePath)

    cc.FileUtils:getInstance():addSearchPath("src")
    cc.FileUtils:getInstance():addSearchPath("res")

    cc.FileUtils:getInstance():addSearchPath("raw/src")
    cc.FileUtils:getInstance():addSearchPath("raw/res")

    cc.FileUtils:getInstance():addSearchPath("obb/src")
    cc.FileUtils:getInstance():addSearchPath("obb/res")

    -- 添加文件路径
    cc.FileUtils:getInstance():addSearchPath(updatePath .. "data")

    -- define the design resolution
    local designWidth = 960;
    local designHeight = 640;

    -- retrieve device resolution
    -- 取得设备的分辨率
    local director = cc.Director:getInstance()
    local frameSize = director:getOpenGLView():getFrameSize()

    local deviceWidth = frameSize["width"]
    local deviceHeight = frameSize["height"]

    Log:D("deviceWidth:" ..deviceWidth .. " deviceHeight:".. deviceHeight)
    Log:D("view width:" ..director:getVisibleSize().width .. " view height:".. director:getVisibleSize().height)

    -- 启动手表管理器
    require('mgr/WatchMgr')

    -- 先看是否有配置
    require("mgr/DeviceMgr")
    local deviceCfg = DeviceMgr:getUIScale()
    if deviceCfg then
        designHeight = deviceCfg.designHeight or designHeight
    else
        designHeight = DeviceMgr:getDesignHeight()
    end

    -- print out parameters
    Log:D("device width:"..deviceWidth);
    Log:D("device height:"..deviceHeight);

    local userDefault = cc.UserDefault:getInstance()

    local designResolutionWidth = designWidth
    local designResolutionHeight = designHeight
    local designResolutionPolicy  = cc.ResolutionPolicy.FIXED_HEIGHT

    -- resize the design resolution
    -- FIXED_HEIGHT 模式下，宽度不一定是 designResolutionWidth，而是：designResolutionHeight * 屏幕宽 / 屏幕高
    director:getOpenGLView():setDesignResolutionSize(designResolutionWidth, designResolutionHeight, designResolutionPolicy)

    -- after screen fitted
    Log:D("view width:" ..director:getVisibleSize().width .. " view height:".. director:getVisibleSize().height)

    director:setAnimationInterval(1 / FPS)
    director:setDisplayStats(false)

    local UpdateScene = require('scene/UpdateScene')
    local updateScene = UpdateScene.create(updatePath)
    if director:getRunningScene() then
        director:replaceScene(updateScene)
    else
        director:runWithScene(updateScene)
    end

    local userDefault = cc.UserDefault:getInstance()
    local noUpdate = userDefault:getIntegerForKey("noupdate", 0);

    if noUpdate == 1 then
        -- 直接进入游戏
        updateScene:enterGame()
    else
        -- 检查更新
        updateScene:update()
    end

    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_WINDOWS then
        require("hotupdate")
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:scheduleScriptFunc(function()
            if FetchConsoleCmd then
                local string = FetchConsoleCmd()
                if string then
                    local cmd = loadstring(string)
                    if cmd then
                        xpcall(cmd, __G__TRACKBACK__)
                    end
                    ShowPrompt()
                end
            end
        end, 0, false)
    end
end

-- 更新电池状态
function postBatteryPercent(result)
    -- gf:ShowSmallTips("电池的状态回来了！为 ：" .. result)
    if type(result) ~= "string" then return end

    local rawlevel, scale, status, health = string.match(result, "(%d+);(%d+);(%d+);(%d+)")
  --[[  GameMgr.batteryState = {
        rawlevel    = tonumber(rawlevel),
        scale       = tonumber(scale),
        status      = tonumber(status),
        health      = tonumber(health)
    }]]

   local batteryInfo = {
       rawlevel    = tonumber(rawlevel),
        scale       = tonumber(scale),
        status      = tonumber(status),
        health      = tonumber(health)
        }

    BatteryAndWifiMgr:setBatteryInfo(batteryInfo)
    -- 找到SystemFunctionDlg
    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        dlg:updateBattery(tonumber(rawlevel), tonumber(scale), tonumber(status), tonumber(health))
    end

    local dlg = DlgMgr:getDlgByName("FightRoundDlg")
    if dlg then
        dlg:updateBattery(tonumber(rawlevel), tonumber(scale), tonumber(status), tonumber(health))
    end
end

-- 更新网络状态
function postNetworkStatus(result)
    if type(result) ~= "string" then return end

    -- 找到SystemFunctionDlg
    local networkState = string.match(result, "(%d+);")
    BatteryAndWifiMgr:setNetworkState(tonumber(networkState))

    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        dlg:updateNetwork(tonumber(networkState))
    end

    local dlg = DlgMgr:getDlgByName("FightRoundDlg")
    if dlg then
        dlg:updateNetwork(tonumber(networkState))
    end
end

-- 更新wifi状态
function postWifiStrength(result)
    -- gf:ShowSmallTips("wifi状态回来了！为 ：" .. result)
    if type(result) ~= "string" then return end

    -- 找到SystemFunctionDlg
    local wifiState, level = string.match(result, "(%d+);(-*%d+)")
    local wifiInfo =
    {
        wifiState = tonumber(wifiState),
        level = tonumber(level),
    }
    BatteryAndWifiMgr:setWifiInfo(wifiInfo) -- 缓存wifi信息


    local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
    if dlg then
        dlg:updateWifiStatus(tonumber(wifiState), tonumber(level))
    end

    local dlg = DlgMgr:getDlgByName("FightRoundDlg")
    if dlg then
        dlg:updateWifiStatus(tonumber(wifiState), tonumber(level))
    end
end

-- 切换到后台后，每隔一段时间会调用该函数
function gfOnBackgroundFrame(para)
    if GameMgr then
        GameMgr:onBackgroundFrame()
    end
end

-- 设置快捷操作
function setShortcutOper(oper)
    Log:D(string.format("setShortcutOper:%d", oper))
    ShortcutMgr:setOper(oper)
end

-- 内存警告
function didReceiveMemoryWarnging()
    if AnimationMgr then
        AnimationMgr:checkImmediately()
    end

    if TextureMgr then
        TextureMgr:collectCache()
    end
end

-- test测试代码
function reloadDlg(dlgName)
    DlgMgr:closeDlg(dlgName, nil, true)

    package.loaded["dlg/" .. dlgName] = nil

    DlgMgr:openDlg(dlgName)
end

-- 显示性能消耗
function printProfile()
    if not ENABLE_PROFILE or not time_profile or not time_profile.ct then return end

    local r = {}
    for k, v in pairs(time_profile.ct) do
        -- print(k, tostringex(v))
        table.insert(r, { name = k, v = v })
    end
    table.sort(r, function(l, r)
        if (l.v.avg_time or 0) > (r.v.avg_time or 0) then return true end
        if (l.v.avg_time or 0) < (r.v.avg_time or 0) then return false end

        if (l.v.times or 0) > (r.v.times or 0) then return true end
        if (l.v.times or 0) < (r.v.times or 0) then return false end

        return false
    end)

    Log:I("--------------->")
    local o = {}
    table.insert(o, "#func_name, times, avg_time, total_time, call_time")
    Log:I("#func_name, times, total_time, avg_time, call_time")
    for _, v in ipairs(r) do
        Log:I(string.format("%s,%s,%s,%s,%s", v.name, tostring(v.v.times), tostring(v.v.avg_time), tostring(v.v.total_time), tostring(v.v.call_time)))
        table.insert(o, string.format("%s,%s,%s,%s,%s", v.name, tostring(v.v.times), tostring(v.v.avg_time), tostring(v.v.total_time), tostring(v.v.call_time)))
    end
    if gf and gf.ftpUploadLog then
        gf:ftpUploadLog(table.concat(o, '\n'))
    end
    Log:I("<---------------")
end

if ENABLE_PROFILE then
    debug.sethook(function(e)
        local info = debug.getinfo(2, "Sln")
        if not info then return end
        local key = string.format("%s:%s:%s", info.short_src, tostring(info.linedefined), info.name or "unknown")
        if 'call' == e then
            local st = time_profile.st[key]
            if not st then
                time_profile.st[key] = {}
                st = time_profile.st[key]
            end
            table.insert(st, gfGetTickCount())
        elseif 'return' == e then
            local sts = time_profile.st[key]
            if not sts then
                -- assert(false, key)
                return
            end

            local ct = time_profile.ct[key]
            if not ct then
                ct = {}
                time_profile.ct[key] = ct
                time_profile.count = (time_profile.count or 0) + 1
            end
            local et = gfGetTickCount()

            local st = table.remove(sts) or et

            -- 调用次数
            ct.times = (ct.times or 0) + 1

            -- 本次消耗
            ct.call_time = (et - st)
            ct.total_time = (ct.total_time or 0) + ct.call_time
            ct.avg_time = ct.total_time / ct.times

            -- print(key, tostringex(time_profile.ct[key]), time_profile.count)
        end
    end, 'cr')
end

-- 文件更新，仅在windows上可用
function update(...)
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform ~= cc.PLATFORM_OS_WINDOWS then
        Log:I("update is avalible on windows only!")
        return
    end

    local t = { ... }
    local hotupdate = require("hotupdate")
    for _, v in ipairs(t) do
        hotupdate:reload(v)
    end
end

function updateAll()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform ~= cc.PLATFORM_OS_WINDOWS then
        Log:I("update is avalible on windows only!")
        return
    end

    local hotupdate = require("hotupdate")
    hotupdate:reloadAll()
end

local function http_get_script(url, mod)
    local mod_f = string.gsub(mod, "%.", "/")
    url = url .. mod_f .. ".lua"
    print("http_get_script:", url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_BLOB
    xhr:open("GET", url)
    xhr:retain()

    local co = coroutine.running()
    assert(co, debug.traceback())

    local function onXhrChange()
        print("onXhrChange:", xhr.status)
        if not co then return end
        if xhr.status == 200 then
            return coroutine.resume(co, xhr.response)
        end
        if xhr.status == 404 or xhr.status == 0 then
            return coroutine.resume(co, nil)
        end
    end

    xhr:registerScriptHandler(onXhrChange)
    xhr:send()
    local data = coroutine.yield(xhr)
    print("data:", data and #data)
    xhr:release()
    co = nil
    assert(data, url)
    return loadstring(data, mod)()
end



local status, msg = xpcall(function()
    coroutine.resume(coroutine.create(function()
        local loc_config = require "src/loc_config"
        if not loc_config.enable then return main() end
        local url = loc_config.url
        xpcall(http_get_script, print, url, "loc_init")
        local loc_list = http_get_script(url, "loc_list")
        print(inspect(loc_list))
        for i, v in ipairs(loc_list) do
            local ret, obj = xpcall(http_get_script, print, url, v)
            assert(ret, obj)
            package.loaded[v] = obj
        end

        main()
    end))
end, __G__TRACKBACK__)
if not status then
	error(msg)
end
