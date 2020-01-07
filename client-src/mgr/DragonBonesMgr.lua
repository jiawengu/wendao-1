-- DragonBonesMgr.lua
-- Created by chenyq Apr/13/2017
-- 对 native 层封装出来的 DragonBonesMgr 进行扩展，以方便使用
-- native 层封装的接口详见：tolua++/DragonBonesMgr.pkg
-- 可通过 DragonBonesMgr.isInvalid 来判断该功能是否是无效的
--
--[[ 基本用法：
-- 加载骨骼配置
-- 每一个骨骼名字 dragonBonesName 必须是全局唯一的，需要和策划约定一下
DragonBonesMgr:loadBonesData("bones/Ubbie/Ubbie.json", dragonBonesName)
DragonBonesMgr:loadTextureAtlasData("bones/Ubbie/texture.json", dragonBonesName)

-- 构造 Armature
local nodeArmature = DragonBonesMgr:buildArmature(armatureName, dragonBonesName)

-- 将 Armature 放到某个 node 上，例如 gf:getUILayer()
local node = tolua.cast(nodeArmature, "cc.Node")
node:setPosition(480, 320)
node:setScale(0.5)
gf:getUILayer():addChild(node, 10)

-- 播放指定的动作
DragonBonesMgr:play(nodeArmature, actionName, 1)

-- 监听事件
-- 回调函数中不能直接播下一个动作，客户端会崩溃，需延后一帧在播下一动作
DragonBonesMgr:bindEventListener(nodeArmature, "complete", function(eventType) ... end)
]]

if type(DragonBonesMgr) ~= "table" then
    -- 底层还没有这些接口
    DragonBonesMgr = {
        isInvalid = true
    }
end

local usedCount = {}

-- armatureNode: 通过 DragonBonesMgr:buildArmature 获得到的对象
-- eventType 取值范围如下：
--  "start"
--  "loopComplete"   每次播放完成后回调一次。循环播放3次，则会有3次回调
--  "complete"       全部动作播放完回调。循环播放3次，则会最后一次完成后回调
--  "fadeIn"
--  "fadeInComplete"
--  "fadeOut"
--  "fadeOutComplete"
--  "frameEvent"
--  "soundEvent"
-- callback：回调函数只有一个参数，为 eventType
function DragonBonesMgr:bindEventListener(armatureNode, eventType, callback)
    local dispatcher = DragonBonesMgr:getEventDispatcher(armatureNode)
    if not dispatcher then
        return
    end

    dispatcher = tolua.cast(dispatcher, "cc.EventDispatcher")
    if not dispatcher then
        return
    end


    dispatcher:addCustomEventListener(eventType, callback)
end

-- icon 龙骨动画编号
-- armatureName 动画名，不一定为文件名，可找美术确认
-- dragonBonesName 自定义名，但必须为唯一值
-- ui 相关的龙骨动画
function DragonBonesMgr:createUIDragonBones(icon, armatureName)
    local dragonBonesName = "ui" .. icon

    -- 先加载资源
    local bonesPath, texturePath = self:getBonesUIFilePath(icon)
    self:addDragonBonesFileInfoByName(bonesPath, texturePath, dragonBonesName)
    local node = self:buildArmature(armatureName, dragonBonesName)
    if node then
        self:usedResourceCount(dragonBonesName, armatureName)
    end

    return node
end

-- char 相关的龙骨动画
function DragonBonesMgr:createCharDragonBones(icon, armatureName)
    local dragonBonesName = "char" .. icon

    -- 先加载资源
    local bonesPath, texturePath = self:getBonesCharFilePath(icon)
    self:addDragonBonesFileInfoByName(bonesPath, texturePath, dragonBonesName)
    local node = self:buildArmature(armatureName, dragonBonesName)
    if node then
        self:usedResourceCount(dragonBonesName, armatureName)
    end

    return node
end

-- map 相关的龙骨动画
function DragonBonesMgr:createMapDragonBones(icon, armatureName)
    local dragonBonesName = "map" .. icon

    -- 先加载资源
    local bonesPath, texturePath = self:getBonesMapFilePath(icon)
    self:addDragonBonesFileInfoByName(bonesPath, texturePath, dragonBonesName)
    local node = self:buildArmature(armatureName, dragonBonesName)
    if node then
        self:usedResourceCount(dragonBonesName, armatureName)
    end

    return node
end

-- 移除 ui 相关的龙骨动画资源
function DragonBonesMgr:removeUIDragonBonesResoure(icon, armatureName)
    local dragonBonesName = "ui" .. icon
    self:removeResource(icon, dragonBonesName, armatureName, "ui")
end

-- 移除  char 相关的龙骨动画资源
function DragonBonesMgr:removeCharDragonBonesResoure(icon, armatureName)
    local dragonBonesName = "char" .. icon
    self:removeResource(icon, dragonBonesName, armatureName, "char")
end

-- 移除 map 相关的龙骨动画资源
function DragonBonesMgr:removeMapDragonBonesResoure(icon, armatureName)
    local dragonBonesName = "map" .. icon
    self:removeResource(icon, dragonBonesName, armatureName, "map")
end

function DragonBonesMgr:removeResource(icon, dragonBonesName, armatureName, resType)
    if usedCount[dragonBonesName] and usedCount[dragonBonesName][armatureName] then
        local num = usedCount[dragonBonesName][armatureName]
        num = num - 1
        if num == 0 then
            num = nil
        end

        usedCount[dragonBonesName][armatureName] = num
    end

    if usedCount[dragonBonesName] and not next(usedCount[dragonBonesName]) then
        local bonesPath, texturePath
        if resType == "char" then
            bonesPath, texturePath = self:getBonesCharFilePath(icon)
        elseif resType == "ui" then
            bonesPath, texturePath = self:getBonesUIFilePath(icon)
        elseif resType == "map" then
            bonesPath, texturePath = self:getBonesMapFilePath(icon)
        end

        self:removeBonesFileData(bonesPath, texturePath)
    end
end

function DragonBonesMgr:usedResourceCount(dragonBonesName, armatureName)
    if not usedCount[dragonBonesName] then
        usedCount[dragonBonesName] = {}
    end

    local num = usedCount[dragonBonesName][armatureName]
    if not num then
        num = 0
    end

    num = num + 1

    usedCount[dragonBonesName][armatureName] = num
end

-- 要加载动画必须先加载资源
function DragonBonesMgr:addDragonBonesFileInfoByName(bonesPath, texturePath, name)
    self:loadBonesData(bonesPath, name)
    self:loadTextureAtlasData(texturePath, name)
end

-- 移除加载的动画资源
function DragonBonesMgr:removeBonesFileData(bonesPath, texturePath)
    self:removeBonesDataByFile(bonesPath, true)
    self:removeTextureAtlasDataByFile(texturePath, true)
end

-- 播放不存在的动作会导致客户端卡死，所以先判断一下
function DragonBonesMgr:toPlay(armature, animationName, playTimes)
    if DragonBonesMgr:hasAnimation(armature, animationName) then
        DragonBonesMgr:play(armature, animationName, playTimes)
        return true
    else
        Log:D("[toPlay]:cannot find animation：" .. animationName)
    end
end

function DragonBonesMgr:toStop(armature, animationName, frame)
    if DragonBonesMgr:hasAnimation(armature, animationName) then
        if frame then
            DragonBonesMgr:gotoAndStopByFrame(armature, animationName)
        else
            DragonBonesMgr:stop(armature, animationName)
        end
        return true
    else
        Log:D("[toStop]:cannot find animation：" .. animationName)
    end
end

-- 获取 ui 类的龙骨动画文件路径
function DragonBonesMgr:getBonesUIFilePath(icon)
    return string.format("bones/ui/%05d/%05d.json", icon, icon), string.format("bones/ui/%05d/texture.json", icon)
end

-- 获取 char 类的龙骨动画文件路径
function DragonBonesMgr:getBonesCharFilePath(icon)
    return string.format("bones/char/%05d/%05d.json", icon, icon), string.format("bones/char/%05d/texture.json", icon)
end

-- 获取 map 类的龙骨动画文件路径
function DragonBonesMgr:getBonesMapFilePath(icon)
    return string.format("bones/map/%05d/%05d.json", icon, icon), string.format("bones/map/%05d/texture.json", icon)
end