-- DebugMgr.lua
-- Created by liuhb Mar/21/2016
-- DEBUG 管理器
-- 这里面将不允许对数据进行修改操作

DebugMgr = Singleton()
local json = require("json")
local List = require("core/List")

local checkCharListTime = true

local lastRecAchieveCfgTime = 0

-- 检查角色列表是否为空
function DebugMgr:checkCharListIsNull(Meid, mapId)
    catch(function() DebugMgr:checkCharListIsNullEx(Meid, mapId) end)
end

function DebugMgr:checkCharListIsNullEx(Meid, mapId)
    if "table" ~= type(CharMgr.chars) then
        -- 数据错误
        return
    end

    local str = nil
    for id, obj in pairs(CharMgr.chars) do
        if Me:getId() ~= id then
            -- 有人没清除掉
            -- 赋值操作是为了把关心的数值打印出来
            local charList = CharMgr.chars
            local curMapId = MapMgr:getCurrentMapId()
            if checkCharListTime then
                -- 只能触发一次
                checkCharListTime = false

                if not str then
                    str = ""
                end

                str = str .. ">>>> debug check charList isn't null!\n" ..
                    "\n Me id : " .. tostring(Meid) ..
                    "\n curMapId : " .. tostring(MapMgr:getCurrentMapId()) ..
                    "\n tomapId : " .. tostring(mapId) ..
                    "\n char id : " .. tostring(id)
            end
        end
    end

    if str then
        -- 直接写到本地日志
        Log:F(str)
    end
end

-- 战斗消息
local fightMsgMap = {}

function DebugMgr:beginFightMsg()
    if not self:enableFightMsgRecord() then
        self.curFightList = nil
        return
    end

    if not fightMsgMap then fightMsgMap = {} end

    self.curFightList = {}
    self.doUploadCombatMsg = nil

    if #fightMsgMap >= 1 then   -- 只记录1场
        table.remove(fightMsgMap, 1)
    end

    table.insert(fightMsgMap, self.curFightList)
end

function DebugMgr:endFightMsg()
    self.curFightList = nil
    if self.doUploadCombatMsg then
        self:saveFightMsg("MSG_UPLOAD_COMBAT_MESSAGE")
    end
end

function DebugMgr:recordFightMsg(msgName, map)
    if not msgName then
        return
    end

    if not self:enableFightMsgRecord() then return end
    if 'MSG_MESSAGE' == msgName or 'MSG_MESSAGE_EX' == msgName then return end

    if 'MSG_C_START_COMBAT' == msgName or 'MSG_LC_START_LOOKON' == msgName then
        self:beginFightMsg()
    end

    if not self.curFightList then return end

    -- 生成记录数据
    if FightMgr[msgName] or string.find(msgName, "CMD_C_") then
        local msg = { ["msgName"] = msgName, ["map"] = map, ["time"] = gf:getServerTime() }
        table.insert(self.curFightList, msg)
    end
end

function DebugMgr:saveFightMsg(msg)
    if not self:enableFightMsgRecord() then return end

    self.doUploadCombatMsg = nil
    self.fightLogCount = (self.fightLogCount or 0) + 1

    -- 此处使用coroutine组织上传数据
    local function coUpload()

        -- 缓存当前的数据，因为协程会在后天慢慢上传
        local _fightMsgMap = fightMsgMap

        -- 已经上传，后面的就不用在记录了
        self:endFightMsg()

        -- 清空所有的数据
        fightMsgMap = {}

        local rootPath = cc.FileUtils:getInstance():getWritablePath() .. "/fightLog/"
        local logPath = rootPath .. "files.txt"

        if not cc.FileUtils:getInstance():isFileExist(logPath) then
            gfSaveFile("", "fightLog/files.txt")
        end

        local curTime = os.time()
        local f
        f = io.open(logPath, "a")
        if not f then return end
        f:write(tostring(curTime) .. '\n')
        f:close()

        local filePath = rootPath .. string.format("fightmsg_%s.txt", os.date("%Y-%m-%d-%H-%M-%S", curTime))
        f = io.open(filePath, "wb")
        if not f then return end
        f:write("desc:" .. tostring(msg))

        for i = 1, #_fightMsgMap do
            local combatMsg = _fightMsgMap[i]
            f:write(string.format("\n>>>>>>>>>>>>>>>>>COMBAT:%d\n[\n", i))
            for j = 1, #combatMsg do
                f:write(json.encode(combatMsg[j]))
                if j ~= #combatMsg then
                    f:write(",\n")
                else
                    f:write("\n")
                end

                -- 每组织20条数据休息一下
                coroutine.yield()
            end

            -- 每场战斗休息一下
            coroutine.yield()
        end

        f:write("]\n>>>>>>>>>>>>>>>>>")
        if DeviceMgr then
            local termInfo = DeviceMgr:getTermInfo()
            local osVer = DeviceMgr:getOSVer()
            f:write(string.format("\nterm_info:%s, os_ver:%s", termInfo and termInfo or "unknown", osVer and osVer or "unknown"))
        end
        if cc.UserDefault:getInstance() then
            dist = cc.UserDefault:getInstance():getStringForKey("lastLoginDist")
            f:write(string.format("\ndist:%s, version:%s", dist,
                cc.UserDefault:getInstance():getStringForKey("local-version")))
        end
        f:write(string.format("\ndata:%s", os.date()))

        -- 休息一下
        coroutine.yield()
        f:close()
        self.coUpload = nil

        Log:I("战斗信息保存成功")
    end

    self.coUpload = coroutine.create(coUpload)
    coroutine.resume(self.coUpload)
end

-- 清除日志文件
function DebugMgr:clearFightLog(time)
    time = math.floor(time/3600/24) * 3600 * 24
    local LOG_PATH = cc.FileUtils:getInstance():getWritablePath() .. "/fightLog/"
    local filePath = LOG_PATH .. "files.txt"
    if cc.FileUtils:getInstance():isFileExist(filePath) then
        local f
        f = io.open(filePath, "r+")
        if not f then return end
        local t
        local fs = {}
        for i in f:lines() do
            t = tonumber(i)
            if t and t < time then
                os.remove(LOG_PATH .. string.format("fightmsg_%s.txt", os.date("%Y-%m-%d-%H-%M-%S", t)))
            else
                table.insert(fs, i)
            end
        end
        f:close()
        local str = table.concat(fs, '\n')
        if str and #str > 0 then
            str = str .. '\n'
        end
        gfSaveFile(str, "fightLog/files.txt")
    end
end

-- 重置记录场次数量
function DebugMgr:resetFightLogCount()
    self.fightLogCount = 0
end

function DebugMgr:uploadFightMsg(msg, notShowTip)
    if not self:enableFightMsgRecord() then return end

    self.doUploadCombatMsg = nil

    local logMsg = {}
    table.insert(logMsg, "desc:" .. tostring(msg))

    -- 此处使用coroutine组织上传数据
    local function coUpload()

        -- 缓存当前的数据，因为协程会在后天慢慢上传
        local _fightMsgMap = fightMsgMap

        -- 已经上传，后面的就不用在记录了
        self:endFightMsg()

        -- 清空所有的数据
        fightMsgMap = {}

        for i = 1, #_fightMsgMap do
            local combatMsg = _fightMsgMap[i]
            table.insert(logMsg, string.format(">>>>>>>>>>>>>>>>>COMBAT:%d", i))
            for j = 1, #combatMsg do
                table.insert(logMsg, tostringex(combatMsg[j]))

                -- 每组织20条数据休息一下
                coroutine.yield()
            end

            -- 每场战斗休息一下
            coroutine.yield()
        end

        table.insert(logMsg, ">>>>>>>>>>>>>>>>>")
        if DeviceMgr then
            local termInfo = DeviceMgr:getTermInfo()
            local osVer = DeviceMgr:getOSVer()
            table.insert(logMsg, string.format("term_info:%s, os_ver:%s", termInfo and termInfo or "unknown", osVer and osVer or "unknown"))
        end
        if cc.UserDefault:getInstance() then
            dist = cc.UserDefault:getInstance():getStringForKey("lastLoginDist")
            table.insert(logMsg, string.format("dist:%s, version:%s", dist,
                cc.UserDefault:getInstance():getStringForKey("local-version")))
        end
        table.insert(logMsg, string.format("data:%s", os.date()))

        -- 休息一下
        coroutine.yield()

        local text = table.concat(logMsg, "\n")

        gf:ftpUploadEx(text)
        self.coUpload = nil

        if not notShowTip then
            gf:ShowSmallTips("信息反馈成功")
        end
        Log:I("信息反馈成功")
    end

    self.coUpload = coroutine.create(coUpload)
    coroutine.resume(self.coUpload)
end

function DebugMgr:MSG_UPLOAD_COMBAT_MESSAGE(data)
    if not self.curFightList then
        self:saveFightMsg("MSG_UPLOAD_COMBAT_MESSAGE")
    else
        self.doUploadCombatMsg = true
    end
end

function DebugMgr:MSG_ENTER_GAME(data)
    DebugMgr:clearFightLog(os.time() - 2 * 24 * 3600)
    DebugMgr:resetFightLogCount()
end

-- 内测专区/Debug/桌面应用开启
function DebugMgr:enableFightMsgRecord()
    --return DistMgr:isTestDist(GameMgr:getDistName()) or gfIsDebug() or gf:isWindows()
    return self.fightLogCount and self.fightLogCount < 5
end

function DebugMgr:onFrame()
    -- 如果存在协程的话，继续唤醒
    if self.coUpload then coroutine.resume(self.coUpload) end
end

function DebugMgr:uploadFightMgrData(msg)
    if not GFightMgr.DumpAllData then return end
    local logMsg = {}
    table.insert(logMsg, "------>FightMgrData:" .. tostring(msg))
    table.insert(logMsg, GFightMgr:DumpAllData())
    local text = table.concat(logMsg, "\n")
    gf:ftpUploadEx(text)
    Log:D(text)
end

function DebugMgr:recordCharActionLog(key, event, stacktrace)
    if not self.charActionLog then
        self.charActionLog = {}
    end

    if not self.charActionLog[key] then
        self.charActionLog[key] = {}
    end

    self.charActionLog[key][event] = stacktrace
end

function DebugMgr:logCharActionError(key)
    if not self.charActionLog then return end
    if not self.charActionLog[key] then return end
    local str = ">>>>>>>>>>>>>>>CharAction Log:\n"
    for k, v in pairs(self.charActionLog[key]) do
        str = str .. string.format("%s:\n%s\n", k, v)
    end

    gf:ftpUploadEx(str)
    Log:D(str)
end

function DebugMgr:logAchieveConfigRecTime()
    lastRecAchieveCfgTime = gf:getServerTime()
end

function DebugMgr:getLastRecAchieveConfigTime()
    return lastRecAchieveCfgTime
end

-- WDSY-27195
local clientStatusLog = {}
function DebugMgr:addClientStatusLog(text)
    if DistMgr and not DistMgr:curIsTestDist() then return end
    if self.reportClientStatusTimes and self.reportClientStatusTimes >= 3 then return end

    table.insert(clientStatusLog, "--------------------------------")
    table.insert(clientStatusLog, text)
    table.insert(clientStatusLog, debug.traceback())
end

-- WDSY-27195
function DebugMgr:checkClientStatus()
    if DistMgr and not DistMgr:curIsTestDist() then return end
    local distName = GameMgr.dist
    if not string.match(distName, CHS[6000239]) and not string.match(distName, CHS[6000240]) then return end
    if not MessageMgr.isInBackground or (self.recordClientStatusCount and self.recordClientStatusCount >= 3) then return end
    Log:F(string.format("@@@@@@@@@@checkClientStatus, client_status:%s, self.recordClientStatusCount:%s, MessageMgr.isInBackground:%s\n%s\n%s",
        tostring(GameMgr.clientStatus),
        tostring(self.recordClientStatusCount or 0),
        tostring(MessageMgr.isInBackground),
        debug.traceback(),
        table.concat(clientStatusLog, '\n')))
    clientStatusLog = {}
    self.recordClientStatusCount = (self.recordClientStatusCount or 0) + 1
end

-- WDSY-27195
function DebugMgr:recordClientStatus(text)
    if DistMgr and not DistMgr:curIsTestDist() then return end
    local distName = GameMgr.dist
    if not string.match(distName, CHS[6000239]) and not string.match(distName, CHS[6000240]) then return end
    if self.reportClientStatusTimes and self.reportClientStatusTimes >= 3 then return end
    Log:F(string.format("@@@@@@@@@@@@@@@@client status error occure:%s\n%s\n%s", text, debug.traceback(), table.concat(clientStatusLog, '\n')))
    clientStatusLog = {}
    self.reportClientStatusTimes = (self.reportClientStatusTimes or 0) + 1
end

-- WDSY-27195
function DebugMgr:clearClientStatus()
    clientStatusLog = {}
end

-- 开启本地日志记录
--[[
    -- 内测启用
    DebugMgr:enableLocalLog(function(data)
        return DistMgr and DistMgr:curIsTestDist() -- 内测区开启
    end)

    -- 自动寻路核查
    DebugMgr:enableLocalLog(function(data) return data and ((data.curTaskWalkPath and data.curTaskWalkPath.from_server) or (data.MSG == 0xB007)) end)   -- 开启记录服务器发起的自动寻路日志
]]
function DebugMgr:enableLocalLog(enableCallback)
    self.localLogEnabledCallback = enableCallback
end

-- 记录本地日志
function DebugMgr:debugLog(str, data)
    if 'function' == type(self.localLogEnabledCallback) and self.localLogEnabledCallback(data) then
        Client:pushDebugInfo(str)
    end
end

-- WDSY-32905
local lastRandomWalk
function DebugMgr:beginRandomWalk(info)
    if not DistMgr or not DistMgr:curIsTestDist() then return end
    lastRandomWalk = { b_info = info, b_stack = debug.traceback() }
end

function DebugMgr:endRandomWalk(info)
    if not DistMgr or not DistMgr:curIsTestDist() then return end

    if not lastRandomWalk then
        return
    end

    if not lastRandomWalk.e then
        lastRandomWalk.e = {}
    end

    table.insert(lastRandomWalk.e, { info = info, statck = debug.traceback() })
end

function DebugMgr:getLastRandomWalk()
    return lastRandomWalk
end

-- WDSY-32905

-- WDSY-33170

local loginInfos = List.new()

function DebugMgr:beginLogin(msg)
    if not loginInfos or not DistMgr or not DistMgr:curIsTestDist() then return end
    loginInfos:pushBack(string.format("%s:\n%s", msg, debug.traceback()))
end

function DebugMgr:endLogin()
    if not loginInfos or not DistMgr or not DistMgr:curIsTestDist() then return end
    if loginInfos:size() > 0 then
        loginInfos:popFront()
    end
end

function DebugMgr:saveLoginInfo()
    if not loginInfos or not DistMgr or not DistMgr:curIsTestDist() then return end
    if loginInfos:size() > 0 then
        local val = loginInfos:get(1)
        if val then Log:F(val) end
    end
end

-- WDSY-33170

-------------------------------------------------------------------------------------------------
--[[
代码调试功能支持，不得删除
]]

-- 从指定的http服务器下载文件到本地目录
function DebugMgr:downloadFile(url, filePath)
    -- 尝试创建文件及目录
    local uncompress
    if not filePath then
        filePath = string.format("%d%d.zip", gf:getServerTime(), gfGetTickCount())
        uncompress = true
    end

    gfSaveFile("", filePath)
    filePath = cc.FileUtils:getInstance():getWritablePath() .. filePath

    local httpFile = HttpFile:create()
    httpFile:retain()

    -- 回调请求
    local function _callback(state, value)
        if 1 == state then
            -- 下载中，value为进度
            local t = { ["progress"] = tostring(value) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = self.cookie, result = json.encode(t), finish = 0 })
        elseif 0 == state then
            -- 下载成功
            httpFile:release()

            if uncompress then
                -- 需要解压
                if not gfUncompress(filePath, cc.FileUtils:getInstance():getWritablePath()) then
                    local t = { ["ret"] = string.format("success to downloadAndUncompress file(%s->%s).", url, filePath) }
                    gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = self.cookie, result = json.encode(t) })
                end
                os.remove(filePath)
            else
                local t = { ["ret"] = string.format("success to download file(%s->%s).", url, filePath) }
                gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = self.cookie, result = json.encode(t) })
            end
        elseif 2 == state then
            -- 下载失败
            httpFile:release()

            local t = { ["ret"] = string.format("failed to download file(%s->%s).", url, filePath) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = self.cookie, result = json.encode(t) })
        end
    end

    httpFile:setDelegate(_callback)
    httpFile:downloadFile(url, filePath)
end

function DebugMgr:MSG_LIST_DUMP_FILES(data)
    if not gf:isAndroid() then
        local t = {["error"] = 'unsupport' }
        gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t)})
        return
    end

    local s, e = pcall(function()
        local ok, ret
        ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "getClassTypeByName", {"java.lang.Class"}, "(Ljava/lang/String;)Ljava/lang/Class;")
        ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "newArray", {ret, 1}, "(Ljava/lang/Class;I)Ljava/lang/Object;")
        local ca = ret
        ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "getClassTypeByName", {"java.lang.String"}, "(Ljava/lang/String;)Ljava/lang/Class;")
        local sc = ret
        ok, ret = LuaJavaBridge.callStaticMethod("java/lang/reflect/Array", "set", {ca, 0, sc}, "(Ljava/lang/Object;ILjava/lang/Object;)V")
        ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "newArray", {sc, 1}, "(Ljava/lang/Class;I)Ljava/lang/Object;")
        local sa = ret
        ok, ret = LuaJavaBridge.callStaticMethod("java/lang/reflect/Array", "set", {sa, 0, cc.FileUtils:getInstance():getWritablePath() .. data.search_dir}, "(Ljava/lang/Object;ILjava/lang/Object;)V")

        ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "newInstance", { 'java.io.File', ca, sa }, "(Ljava/lang/String;[Ljava/lang/Class;[Ljava/lang/Object;)Ljava/lang/Object;")
        local df = ret

        ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "exists", df, {}, "()Z")
        if not ret then
            local t = { ["error"] = string.format("%s isn't exists.", cc.FileUtils:getInstance():getWritablePath() .. data.search_dir) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
            return
        end

        ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "isDirectory", df, {}, "()Z")
        if not ok or not ret then
            local t = { ["error"] = string.format("%s isn't directory.", cc.FileUtils:getInstance():getWritablePath() .. data.search_dir) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
            return
        end

        ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "listFiles", df, {}, "()[Ljava/io/File;")
        if not ok then
            local t = { ["error"] = string.format("failed to call %s, ret=%s", "listFiles", tostring(ret)) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
            return
        end
        local files = ret

        if not files then
            local t = { ["error"] = string.format("listing %s is nil, maybe it isn't directory or it isn't exists.", cc.FileUtils:getInstance():getWritablePath() .. data.search_dir) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
            return
        end

        ok, ret = LuaJavaBridge.callStaticMethod("java/lang/reflect/Array", "getLength", { files }, "(Ljava/lang/Object;)I")
        local length = ret
        local ts = {}
        for i = 1, length do
            local t = {}
            ok, ret = LuaJavaBridge.callStaticMethod("java/lang/reflect/Array", "get", { files, i - 1 }, "(Ljava/lang/Object;I)Ljava/lang/Object;")
            local file = ret
            ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "getAbsolutePath", file, {}, "()Ljava/lang/String;")
            t["file_path"] = ret
            ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "isFile", file, {}, "()Z")
            t["is_file"] = ret
            ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "isDirectory", file, {}, "()Z")
            t["is_directory"] = ret
            ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "length", file, {}, "()J")
            t["length"] = ret
            ok, ret = LuaJavaBridge.callObjectMethod("java/io/File", "lastModified", file, {}, "()J")
            t["last_modified"] = os.date("%Y%m%d%H%M%S", ret / 1000)
            table.insert(ts, t)
        end

        local result = json.encode(ts)
        Log:D(">>>>>>>>>>>>>>>>MSG_LIST_DUMP_FILES:%s", result)
        gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = result })
    end)
    if not s then
        local t = { ["error"] = e }
        gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
    end
end

function DebugMgr:MSG_UPLOAD_DUMP_FILE(data)
    if cc.FileUtils:getInstance():isFileExist(data.file_path) then
        -- gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode({ret = gfReadFile(data.file_path)}) })
        local httpFile = HttpFile:create()
        httpFile:retain()
        local function _callback(state, value)
            if 1 == state then
                Log:I("...upload:%s%%", tostring(value))
            elseif 0 == state then
                performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                    httpFile:release()
                    gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode({ret = string.format("succeed to upload file:%s", data.file_path)}) })
                    Log:I("succeed to upload file:%s", data.file_path)
                end, 0)
            elseif 2 == state then
                performWithDelay(cc.Director:getInstance():getRunningScene(), function()
                    httpFile:release()
                    gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode({ret = string.format("failed to upload file:%s", data.file_path)}) })
                end, 0)
            end
        end

        httpFile:setDelegate(_callback)
        httpFile:uploadFile(data.server, "file", data.file_path, "application/octet-stream")
    else
        gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode({ret = "can't found file:" .. data.file_path}) })
    end
end

function DebugMgr:MSG_EXECUTE_LUA_CODE(data)
    if string.isNilOrEmpty(data.code) then return end

    local s, e = pcall(function()
        if 0 == data.flag then
            self.cookie = data.cookie
        end
        local ret = loadstring(data.code)()
        if 0 ~= data.flag then
            local t = { ["ret"] = tostring(ret) }
            gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
        end
    end)
    if not s then
        local t = { ["error"] = e }
        gf:CmdToServer('CMD_EXECUTE_RESULT', { cookie = data.cookie, result = json.encode(t) })
    end
end

function DebugMgr:loadFile(path)
    local f = io.open(cc.FileUtils:getInstance():getWritablePath() .. path, "rb")
    if not f then return end
    local data = f:read("*a")
    f:close()
    local ob = json.decode(data)
    return ob
end

-- 从文件中加载异常战斗
function DebugMgr:loadCombat(path)
    local msgs = self:loadFile(path)
    if not msgs or #msgs <= 0 then return end
    self.fightMsg = {}
    for i = #msgs, 1, -1 do
        table.insert(self.fightMsg, msgs[i])
    end

    self:sendNext()
end

-- 修复数据
function DebugMgr:fixedMsg(data)
    local m = {}
    for k, v in pairs(data) do
        if tonumber(k) then
            m[tonumber(k)] = v
        else
            m[k] = v
        end
    end

    return m
end

function DebugMgr:sendNext(isAnimatedEnd)
    if not self.fightMsg or #self.fightMsg <= 0 then return end
    local isBreak = false
    local ct
    while (self.fightMsg and #self.fightMsg > 0)
    do
        local msg = self.fightMsg[#self.fightMsg]
        if msg and msg.map then
            if isAnimatedEnd and msg.msgName ~= "CMD_C_END_ANIMATE" then return end

            if "MSG_C_SANDGLASS" == msg.msgName then
                ChatMgr:sendMiscMsg("-------------New Round--------------")
                self.startDoActionTime = gfGetTickCount()
            end

            if msg.msgName == "CMD_C_END_ANIMATE" then
                if isAnimatedEnd then
                    isAnimatedEnd = nil
                    if self.startDoActionTime then
                        ChatMgr:sendMiscMsg(string.format("Animation play:%d", gfGetTickCount() - self.startDoActionTime))
                        self.startDoActionTime = gfGetTickCount()
                    end
                else
                    break
                end
            elseif msg.msgName == "CMD_C_DO_ACTION" then
            elseif msg.msgName == "CMD_C_CLEANALLACTION" then
                FightMgr:CleanAllAction()
            elseif msg.msgName == "MSG_C_WAIT_COMMAND" then
                if not isAnimatedEnd then
                    performWithDelay(gf:getUILayer(), function()
                        table.remove(self.fightMsg)
                        self:sendNext()
                    end, 3)
                end
                break
            else
                MessageMgr:pushMsg(self:fixedMsg(msg.map))
                ct = msg.map.timestamp
            end
        end
        table.remove(self.fightMsg)
    end
end

function DebugMgr:sendDoAction(msg, data)
    if not self.fightMsg or #self.fightMsg <= 0 then
        self.fightMsg = nil
        return
    end

    self:sendNext(true)
end

function DebugMgr:isRunning()
    return self.fightMsg and #self.fightMsg > 0
end

-- 记录调试日志
function DebugMgr:log(log_type, p1, p2, p3, memo)
    DataBaseMgr:insertItem("debugData", {
        update_time = tostring(gf:getServerTime()),
        account = tostring(Client:getAccount()),
        gid = tostring(Me:queryBasic("gid")),
        mac = tostring(DeviceMgr:getMac()),
        type = tostring(log_type),
        p1 = tostring(p1),
        p2 = tostring(p2),
        p3 = tostring(p3),
        memo = tostring(json.encode(memo)),
    })
end

-- 上传调试日志
function DebugMgr:upload_log(id, log_type, update_time, count)
    local limit = "1 "
    if id then
        limit = limit .. string.format("and `static_id`='%s' ", tostring(id))
    end

    if log_type then
        limit = limit .. string.format("and `type`='%s' ", log_type)
    end

    if update_time then
        limit = limit .. string.format("and `update_time`>='%s'", tostring(update_time))
    end

    if type(count) == "number" then
        limit = limit .. string.format(" limit %s", tostring(count))
    else
        limit = limit .. " limit 1"
    end

    local data = DataBaseMgr:selectItems("debugData", limit)
    gf:ftpUploadEx(json.encode(data))
    return json.encode(data)
end

MessageMgr:regist("MSG_LIST_DUMP_FILES", DebugMgr)
MessageMgr:regist("MSG_UPLOAD_DUMP_FILE", DebugMgr)
MessageMgr:regist("MSG_EXECUTE_LUA_CODE", DebugMgr)
MessageMgr:regist("MSG_UPLOAD_COMBAT_MESSAGE", DebugMgr)
MessageMgr:hook("MSG_ENTER_GAME", DebugMgr, "DebugMgr")