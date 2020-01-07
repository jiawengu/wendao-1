-- AnimationMgr.lua
-- Created by cheny Sep/26/2015
-- Animation 管理器

AnimationMgr = Singleton()

-- 更新间隔
local CHECK_INTERVAL = 3000

-- 缓存间隔 2 分钟
local CACHE_TIME = DeviceMgr:isLowMemory() and 6000 or 120000

local PLATFORM_CONFIG = require("PlatformConfig")
local ActionReplaceCfg = require (ResMgr:getCfgPath("ActionReplaceCfg.lua"))

local CUR_VERSION = PLATFORM_CONFIG.CUR_VERSION
local keyIndex = 1

local function checkVersion()
    local ver1, ver2 = gf:getVersionValue(CUR_VERSION)
    if ver1 >= "1.01" then return true end
end

function AnimationMgr:init()
    self.magic = {}
    self.char = {}
    self.lastUpdateTime = 0
end

-- 释放 animation
function AnimationMgr:releaseAnimations(flag)
    local animations
    if flag == "char" then
        animations = self.char
        self.char = {}
    else
        animations = self.magic
        self.magic = {}
    end

    for key, info in pairs(animations) do
        local ani = info[1]
        if ani then
            pcall(function()
                self:removeReleaseEvent(ani)
                ani:release()
            end)
        end
    end
end

-- 清除数据
function AnimationMgr:cleanup()
    self:releaseAnimations("magic")
    self:releaseAnimations("char")

    self.lastUpdateTime = 0
end

function AnimationMgr:addDestructEvent(node, func)
    if not node or not node.registerScriptHandler or 'function' ~= type(node.registerScriptHandler) then return end

    local function onNodeEvent(event)
        if "destruct" == event and func and 'function' == type(func) then
            func(node)
            gf:ftpUploadEx("------------->invalid destruct:\n" .. gfTraceback())
        end
    end

    node:registerScriptHandler(onNodeEvent)
end

function AnimationMgr:removeReleaseEvent(node)
    if not node or not node.unregisterScriptHandler or 'function' ~= type(node.unregisterScriptHandler) then return end

    node:unregisterScriptHandler()
end

function AnimationMgr:resetCacheTime(isLowMemory)
    if nil == isLowMemory then
        isLowMemory = DeviceMgr:isLowMemory()
    end

    CACHE_TIME = isLowMemory and 6000 or 120000
end

-- 异步获取光效对应的 Animation
function AnimationMgr:syncGetMagicAnimation(icon, magicType, func, extra)
    local info = self.magic[icon]

    if not info then
        local plist = ResMgr:getMagicPath(icon, magicType, extra) .. ".plist"
        local pngFile = ResMgr:getMagicPath(icon, magicType, extra) .. ".png"
        local postLoader = function(texture)
            if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() and texture then
                return
            end

            -- 添加动画帧
            if checkVersion() then
                gfAddMagicFrames(plist, icon, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444);
            else
                gfAddMagicFrames(plist, icon);
            end

            -- 再判断一下是否已经创建这个纹理
            -- 这个时候可能同步加载了，所以就无需再次进行创建，否则就泄露了
            if self.magic[icon] then
                info = self.magic[icon]

                if not pcall(function() assert((info[1]):getReferenceCount() >= 1) end) then
                    -- 对象异常了，在C++层被释放了，清除引用
                    self.magic[icon] = nil
                    info = nil
                else
                    info[2] = 0
                end
            end

            if not info then
                -- 创建帧动画
                local animation = cc.Animation:createForMagic(icon)

                if animation then
                    -- 缓存动画
                    animation:retain()
                    info = {animation, 0}
                    self.magic[icon] = info
                    self:addDestructEvent(animation, function()
                        self:removeReleaseEvent(animation)
                        self.magic[icon] = nil
                    end)
                else
                    info = {}
                end
            end

            -- 加载完了，调用
            if type(func) == "function" then
                func(info[1])
            end
        end

        TextureMgr:loadAsync(LOAD_TYPE.MAGIC, pngFile, postLoader, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        return
    end

    info[2] = 0;

    if type(func) == "function" then
        func(info[1])
    end
end

-- 获取光效对应的 Animation
function AnimationMgr:getMagicAnimation(icon, magicType, extra)
    local info = self.magic[icon]

    if not info then
        local plist = ResMgr:getMagicPath(icon, magicType, extra) .. ".plist"

        -- 添加动画帧
        if checkVersion() then
            gfAddMagicFrames(plist, icon, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        else
            gfAddMagicFrames(plist, icon)
        end

        -- 再判断一下是否已经创建这个纹理
        -- 这个时候可能同步加载了，所以就无需再次进行创建，否则就泄露了
        if self.magic[icon] then
            info = self.magic[icon]
            if not pcall(function() assert((info[1]):getReferenceCount() >= 1) end) then
                -- 对象异常了，在C++层被释放了，清除引用
                self.magic[icon] = nil
                info = nil
            else
                info[2] = 0
            end
        end

        if not info then
            -- 创建帧动画
            local animation = cc.Animation:createForMagic(icon)

            if animation then
                -- 缓存动画
                animation:retain()
                info = {animation, 0}
                self.magic[icon] = info
                self:addDestructEvent(animation, function()
                    self:removeReleaseEvent(animation)
                    self.magic[icon] = nil
                end)
            else
                return
            end
        end
    end

    info[2] = 0;
    return info[1];
end

function AnimationMgr:hasLoadTexture(icon, weapon, action, dir, startFrame, endFrame)
    local key = self:getKey(icon, weapon, action, dir, startFrame, endFrame)
    if not AnimationMgr.char[key] then
        return false
    end

    return true
end

function AnimationMgr:getKey(icon, weapon, action, dir, startFrame, endFrame)
    if not self.charKeys then
        self.charKeys = {}
    end

    local t = self.charKeys
    if not t[icon] then
        t[icon] = {}
    end

    t = t[icon]
    if not t[weapon] then
        t[weapon] = {}
    end

    t = t[weapon]
    if not t[action] then
        t[action] = {}
    end

    t = t[action]
    if not t[dir] then
        t[dir] = {}
    end

    t = t[dir]
    if not t[startFrame] then
        t[startFrame] = {}
    end

    t = t[startFrame]
    if not t[endFrame] then
        t[endFrame] = keyIndex
        keyIndex = keyIndex + 1
    end

    local key = t[endFrame]
    return key
end

function AnimationMgr:syncGetCharAnimation(icon, weapon, action, dir, startFrame, endFrame, loadType)
    -- 有可能该动作复用其他地方
    if AnimationMgr:isReplaceAction(icon, action) then
        icon = ActionReplaceCfg[icon].icon
    end

    local key = self:getKey(icon, weapon, action, dir, startFrame, endFrame)
    local info = self.char[key]
    if not info then
        -- 添加动画帧
        local path = string.format("%05d/%05d", icon, weapon)
        local actStr = gf:getActionStr(action)
        local pngFile = ResMgr:getCharPath(path, actStr) .. ".png"
        local plist = ResMgr:getCharPath(path, actStr) .. ".plist"
        local postLoader = function(texture)
            if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() and texture then
                return
            end

            -- 加载
            if checkVersion() then
                gfAddCharFrames(plist, icon, weapon, action, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
            else
                gfAddCharFrames(plist, icon, weapon, action)
            end

            -- 再判断一下是否已经创建这个纹理
            -- 这个时候可能同步加载了，所以就无需再次进行创建，否则就泄露了
            if self.char[key] then
                info = self.char[key]
                if not pcall(function() assert((info[1]):getReferenceCount() >= 1) end) then
                    -- 对象异常了，在C++层被释放了，清除引用
                    self.char[key] = nil
                    info = nil
                else
                    info[2] = 0
                end
            end

            if not info then
                -- 创建帧动画
                local animation = cc.Animation:createForChar(icon, weapon, action, dir, startFrame, endFrame)
                if animation then
                    -- 缓存动画
                    animation:retain()
                    info = {animation, 0}
                    self.char[key] = info
                    self:addDestructEvent(animation, function()
                        self:removeReleaseEvent(animation)
                        self.char[key] = nil
                    end)
                else
                    info = {}
                end
            end

            -- 加载完了
            EventDispatcher:dispatchEvent(key, info[1])
        end

        TextureMgr:loadAsync(loadType, pngFile, postLoader, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        return
    end

    info[2] = 0
    EventDispatcher:dispatchEvent(key, info[1])
end

function AnimationMgr:isReplaceAction(icon, action)
    if ActionReplaceCfg[icon] and ActionReplaceCfg[icon]["replaceAct"][gf:getActionStr(action)] then
        return true
    end

    return
end


-- 获取角色动作对应的 Animation
function AnimationMgr:getCharAnimation(icon, weapon, action, dir, startFrame, endFrame)
    -- 有可能该动作复用其他地方
    if AnimationMgr:isReplaceAction(icon, action) then
        icon = ActionReplaceCfg[icon].icon
    end

    local key = self:getKey(icon, weapon, action, dir, startFrame, endFrame)
    local info = self.char[key]

    if not info then
        -- 添加动画帧
        local path = string.format("%05d/%05d", icon, weapon)
        local actStr = gf:getActionStr(action)
        local plist = ResMgr:getCharPath(path, actStr) .. ".plist"

        if checkVersion() then
            gfAddCharFrames(plist, icon, weapon, action, cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A4444)
        else
            gfAddCharFrames(plist, icon, weapon, action)
        end

        -- 再判断一下是否已经创建这个纹理
        -- 这个时候可能同步加载了，所以就无需再次进行创建，否则就泄露了
        if self.char[key] then
            info = self.char[key]
            if not pcall(function() assert((info[1]):getReferenceCount() >= 1) end) then
                -- 对象异常了，在C++层被释放了，清除引用
                self.char[key] = nil
                info = nil
            else
                info[2] = 0
            end
        end

        if not info then
            -- 创建帧动画
            local animation = cc.Animation:createForChar(icon, weapon, action, dir, startFrame, endFrame)
            if animation then
                -- 缓存动画
                animation:retain()
                info = {animation, 0}
                self.char[key] = info
                self:addDestructEvent(animation, function()
                    self:removeReleaseEvent(animation)
                    self.char[key] = nil
                end)
            else
                return
            end
        end
    end

    info[2] = 0;
    return info[1];
end

function AnimationMgr:update()
    local now = gf:getTickCount()
    if now - self.lastUpdateTime < CHECK_INTERVAL then
        return
    end

    self:checkNow(now)
    self.lastUpdateTime = now
end

function AnimationMgr:checkNow(now)
    if not now then
        now = gf:getTickCount()
    end
    self:check(self.magic, now)
    self:check(self.char, now)
end

function AnimationMgr:checkImmediately()
    self:check(self.magic)
    self:check(self.char)
end

function AnimationMgr:check(animations, now)
    for key, info in pairs(animations) do
        local ani = info[1]
        local ref
        if not pcall(function() ref = ani:getReferenceCount() end) then
            -- 对象异常，已经在C++层被移除，直接移除
            animations[key] = nil
            return
        end
        if ref == 1 then
            if now and info[2] < 1 then
                -- 当前已没有被使用，记录下时间
                info[2] = now
            elseif not now or now - info[2] >= CACHE_TIME then
                -- 太长时间没有使用了，将其清除
                self:removeReleaseEvent(ani)
                ani:release()
                animations[key] = nil
            end
        end
    end
end

AnimationMgr:init()

return AnimationMgr
