-- Log.lua
-- created by cheny Oct/14/2014
-- 输出日志

Log = {}
Log.emsg = ""
-- Log.enablePrintStack = true

local log = gfLog

local LOG_SUB_PATH = "/logs/"
local LOG_PATH = cc.FileUtils:getInstance():getWritablePath() .. LOG_SUB_PATH

-- 调试信息（保留）
function Log:D(...)
    if ATM_IS_DEBUG_VER then
        print("DEBUG : " .. string.format(...))
    end

    Log:printStack()
end

-- 信息（保留）
function Log:I(...)
    gfLog("INF : " .. string.format(...))

    Log:printStack()
end

-- 警告信息
function Log:W(...)
    gfLog("WARNNING : " .. string.format(...))

    Log:printStack()
end

-- 错误信息
function Log:E(...)
    local msg = string.format(...)
    self.emsg = self.emsg .. '\n' .. msg

    gfLog("ERROR : " .. msg)

    Log:printStack()
end

-- 写入到文件
function Log:F(...)
    local msg = string.format(...)
    local time = math.floor(os.time()/3600/24) * 3600 * 24
    local filePath = LOG_PATH .. tostring(os.date("%Y-%m-%d", time)) .. ".log"
    local f
    if not cc.FileUtils:getInstance():isFileExist(filePath) then
        if not cc.FileUtils:getInstance():isFileExist(LOG_PATH .. "files.txt") then
            gfSaveFile("", LOG_SUB_PATH .. "files.txt")
        end
        f = io.open(LOG_PATH .. "files.txt", "a")
        if not f then return end
        f:write(tostring(time) .. '\n')
        f:close()
    end
    local f =  io.open(filePath, "a")
    if not f then return end
    f:write(string.format("%s    %s\n", tostring(os.date("%Y-%m-%d %H:%M:%S", os.time())), msg))
    f:close()
    self:I(...)
end

-- 清除日志文件
function Log:CF(time)
    time = math.floor(time/3600/24) * 3600 * 24
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
                os.remove(LOG_PATH .. tostring(os.date("%Y-%m-%d", t)) .. ".log")
            else
                table.insert(fs, i)
            end
        end
        f:close()
        local str = table.concat(fs, '\n')
        if str and #str > 0 then
            str = str .. '\n'
        end
        gfSaveFile(str, LOG_SUB_PATH .. "files.txt")
    end
end

function Log:printStack()
    if not ATM_IS_DEBUG_VER or not self.enablePrintStack then return end

    local ret = ""
    local level = 3
    ret = ret .. "stack traceback: \n"
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

        level = level + 1
    end

    print(ret)
end

-- 记录调用栈信息
function Log:Traceback()
    gfLog("INF : " .. debug.traceback())
end

-- 临时调试信息（不保留）
function Log:T(...)
    if ATM_IS_DEBUG_VER then
        print("trace : ", ...)
    end
end

-- 清除过期日志
Log:CF(os.time() - 3 * 24 * 3600)

return Log
