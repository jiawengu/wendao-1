-- TextureMgr.lua
-- Created by cheny Nov/21/2014
-- 纹理缓存管理器

TextureMgr = Singleton()

TextureMgr.keep = {}

local COLLECT_TRY_TIMES = 20

-- 收集频率:高内存:60s/次，低内存:6s/次
local CLEAN_INTERVAL = DeviceMgr:isLowMemory() and 2 or COLLECT_TRY_TIMES

-- 一帧下载数量
local LOAD_COUNT_PER_FRAME = 5

function TextureMgr:init()
    self.schduleId = gf:Schedule(function() self:update() end, 3)
    gf:Schedule(function() self:checkLoad() end, 0)
    self.count = 0
    self.loadList = {}
end

function TextureMgr:cleanup()
    if self.schduleId then
        gf:Unschedule(self.schduleId)
     end

    self:collectCache()
     for _, v in pairs(self.keep) do
        if v then
            v:release()
        end
    end

    self.keep = {}

    -- 加载队列数组
    self.loadList = {}

    -- 初始化各个加载队列
    for i = 1, LOAD_TYPE.MAX do
        table.insert(self.loadList, {})
    end

    cc.Director:getInstance():getTextureCache():removeAllTextures()
end

function TextureMgr:update()
    self.count = self.count + 1
    if (self.count > CLEAN_INTERVAL) then
        self:collectCache()
        self.count = 0
    end

    local toremove = {}
    for i, v in pairs(self.keep) do
        if v.life ~= nil then
            v.life = v.life - 1
            if v.life < 0 then
                v:release()
                table.insert(toremove,i)
            end
        end
    end

    for _, v in pairs(toremove) do
        table.remove(self.keep, v)
    end
end

function TextureMgr:resetCleanInterval(isLowMemory)
    if nil == isLowMemory then
        isLowMemory = DeviceMgr:isLowMemory()
    end

    CLEAN_INTERVAL = isLowMemory and 2 or COLLECT_TRY_TIMES
end

function TextureMgr:collectCache()
    local textureCache = cc.Director:getInstance():getTextureCache()
    textureCache:removeUnusedTextures()

    --[[
    local strs = string.split(textureCache:getCachedTextureInfo(), "\n")
    for _, v in ipairs(strs) do
        Log:D(v)
    end
    --]]
end

function TextureMgr:keepTexture(texture, seconds)
    if texture.retain == nil then return end
    texture:retain()
    texture.life = seconds

    table.insert(self.keep, texture)
end

function TextureMgr:dumpTextures()
    local textureCache = cc.Director:getInstance():getTextureCache()
    local strs = string.split(textureCache:getCachedTextureInfo(), "\n")
    for _, v in ipairs(strs) do
        Log:D(v)
    end
end

function TextureMgr:loadAsync(loadType, file, callback, fmt, loadCheck)
    if not self.loadList[loadType]  then self.loadList[loadType] = {} end
    table.insert(self.loadList[loadType], { file = file, callback = callback, fmt = fmt, loadCheck = loadCheck })
end

function TextureMgr:checkLoad()
    if not self.loadList or #self.loadList <= 0 then return end

    local count = LOAD_COUNT_PER_FRAME
    for _, v1 in pairs(self.loadList) do
        local v2 = table.remove(v1, 1)
        if v2 and (not v2.loadCheck or v2.loadCheck(v2.file)) then
            if v2.fmt then
                cc.Director:getInstance():getTextureCache():addImageAsync(v2.file, v2.callback, v2.fmt)
            else
                cc.Director:getInstance():getTextureCache():addImageAsync(v2.file, v2.callback)
            end
            count = count - 1
            if count <= 0 then return end
        end
    end
end

TextureMgr:init()
return TextureMgr
