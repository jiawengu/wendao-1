-- created by liuhb Sep/23/2015
-- 地图光效管理器

MapMagicMgr = Singleton()
local defaultMapMagic = require("maps/magic/MapMagic")

-- 所有已存在光效
local lifeMapMagic = {}

function MapMagicMgr:clearData()
    for v, magics in pairs(lifeMapMagic) do
        if magics then
            for _, magic in pairs(magics) do
                magic:removeFromParent()
            end
        end
    end

    lifeMapMagic = {}
    self.magicType = nil
end

function MapMagicMgr:setMapMagicType(magicType)
    self.magicType = magicType
end

function MapMagicMgr:canAddMagic()
    local status = SystemSettingMgr:getSettingStatus("sight_scope")
    return 0 == status or MapMgr:isMapMagicAlwaysShow()
end

-- 统一接口，在某块区域添加光效
function MapMagicMgr:showCurZoneMagic(minX, minY, maxX, maxY)
    if not self:canAddMagic() then
        return
    end

    -- 获取当前区域的所有光效
    local mapName = MapMgr:getCurrentMapName()
    mapName = self.magicType and string.format("%s_%s", mapName, self.magicType) or mapName
    local mapMagic = self:getZoneMagic(mapName, minX, minY, maxX, maxY)

    local magicIndex = string.format("%d_%d", minX, minY)
    for _, magicInfo in pairs(mapMagic) do
        self:showOneMagic(magicInfo, magicIndex)
    end
end

-- 统一接口，在某块区域显示静态光效
function MapMagicMgr:showCurZoneStaticMagic(minX, minY, maxX, maxY)
    if self:canAddMagic() then
        return
    end

    -- 获取当前区域的所有光效
    local mapName = MapMgr:getCurrentMapName()
    mapName = self.magicType and string.format("%s_%s", mapName, self.magicType) or mapName
    local mapMagic = self:getZoneMagic(mapName, minX, minY, maxX, maxY)

    local magicIndex = string.format("%d_%d", minX, minY)
    for _, magicInfo in pairs(mapMagic) do
        if magicInfo.remove_type == "static_frame" then
            -- 显示关键帧
            self:showOneMagic(magicInfo, magicIndex, magicInfo.remove_type)
        end
    end
end

-- 统一接口，移除某块区域的所有光效
function MapMagicMgr:removeCurZoneMagic(minX, minY, maxX, maxY)
    local magicIndex = string.format("%d_%d", minX, minY)

    if not lifeMapMagic[magicIndex] then
        return
    end

    for _, magic in pairs(lifeMapMagic[magicIndex]) do
        if magic then
            magic:removeFromParent()
        end
    end

    lifeMapMagic[magicIndex] = {}
end

-- 显示一个光效
function MapMagicMgr:showOneMagic(magicInfo, magicIndex, remove_type)
    local mapEffectLayer = gf:getMapEffectLayer()
    if magicInfo.type == "armature" and magicInfo.action == "Top" then -- 骨骼动画
        -- 放在人物上层
        mapEffectLayer = gf:getCharTopLayer()
    end

    local magic = mapEffectLayer:getChildByTag(magicInfo.index)
    if magic then
        if magicInfo.type == "bones" then
            local dbMagic = magic.dbMagic
            if remove_type == "static_frame" then
                DragonBonesMgr:toStop(dbMagic, "stand", 0)
            else
                DragonBonesMgr:toPlay(dbMagic, "stand", 0)
            end
        end

        return
    end

    if magicInfo.notShowMagic then
        return
    end

    local magic = nil
    if magicInfo.type == "armature" then -- 骨骼动画
        magic = self:createArmatureAction(magicInfo.effectId, magicInfo.action)
        ArmatureMgr:processSomeExtraPara(magic, magicInfo)
    elseif magicInfo.type == "bones" then -- 龙骨
        local bonesPath, texturePath = ResMgr:getBonesMapFilePath(magicInfo.effectId)
        local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
        if not bExist then return end

        local dbMagic = DragonBonesMgr:createMapDragonBones(magicInfo.effectId, string.format("%05d", magicInfo.effectId))
        if not dbMagic then return end

        magic = tolua.cast(dbMagic, "cc.Node")
        magic.dbMagic = dbMagic

        if remove_type == "static_frame" then
            DragonBonesMgr:toStop(dbMagic, "stand", 0)
        else
            DragonBonesMgr:toPlay(dbMagic, "stand", 0)
        end

        local function onNodeEvent(event)
            if "cleanup" == event then
                if magicInfo then
                    -- DragonBonesMgr:removeMapDragonBonesResoure(magicInfo.effectId, string.format("%05d", magicInfo.effectId))
                end
            end
        end

        magic:registerScriptHandler(onNodeEvent)
    else
        magic = gf:createLoopMagic(magicInfo.effectId, MAGIC_TYPE.MAP, magicInfo)
    end

    local mapSize = MapMgr:getMapSize()
    magic:setPosition(magicInfo.x, mapSize.height * Const.PANE_HEIGHT - magicInfo.y)
    magic:setTag(magicInfo.index)
    magic:setName(magicInfo.remark)
    magic.magicInfo = magicInfo
    mapEffectLayer:addChild(magic, 10)

    if magicInfo.type == "armature" and magicInfo.action == "Top" then -- 骨骼动画
        -- 放在所有人物上层
        magic:setLocalZOrder(gf:getObjZorder(0))
    end

    if not lifeMapMagic[magicIndex] then
        lifeMapMagic[magicIndex] = {}
    end

    table.insert(lifeMapMagic[magicIndex], magic)
end

-- 播放骨骼动画
function MapMagicMgr:createArmatureAction(icon, actionName)
    local magic = ArmatureMgr:createMapArmature(icon)
    magic:setAnchorPoint(0.5, 0.5)
    magic:getAnimation():play(actionName, -1, 1) -- 循环播放
    return magic
end

-- 获取所有需要显示的光效
function MapMagicMgr:getZoneMagic(mapName, minX, minY, maxX, maxY)
    local mapAllMagic = self:getMapMagicByName(mapName)

    local mapSize = MapMgr:getMapSize()
    local zoneMagic = {}
    for index, magicInfo in pairs(mapAllMagic) do
        if minX < magicInfo.x and magicInfo.x < maxX
            and minY < magicInfo.y and magicInfo.y < maxY then
            magicInfo.index = index
            table.insert(zoneMagic, magicInfo)
        end
    end

    return zoneMagic
end

-- 获取地图上所有可以显示的光效
function MapMagicMgr:getMapMagicByName(mapName)
    if nil == defaultMapMagic then
        defaultMapMagic = require("maps/magic/MapMagic")
    end

    return defaultMapMagic[mapName] or { }
end

-- 重置地图光效位置
-- cfg 中支持的配置
--     reload           重新加载相关配置及光效
--     x, y             坐标
--     rotation         已锚点为中心旋转的角度
--     rotationX        绕 X 轴旋转的角度
--     rotationY        绕 Y 轴旋转的角度
--     scaleX           X 方向上缩放比例
--     scaleY           Y 方向上缩放比例
--     alpha            设置透明度
--     notReloadMap     不重新加载地图光效配置文件
function MapMagicMgr:setMagicByRemark(remark, cfg)
    cfg = (cfg or {})
    if cfg.reload then
        -- 重新加载
        self:clearData()
        if not cfg.notReloadMap then
            self:reloadMapMagicCfg()
        end

        local mapSize = MapMgr:getMapSize()
        local meY = mapSize.height * Const.PANE_HEIGHT - Me.curY
        self:showCurZoneMagic(Me.curX - 960, meY - 640, Me.curX + 960, meY + 640)
        return
    end

    local mapEffectLayer = gf:getMapEffectLayer()
    if cfg.type == "armature" and cfg.action == "Top" then
        -- 放在人物上层的骨骼动画
        mapEffectLayer = gf:getCharTopLayer()
    end

    local magic = mapEffectLayer:getChildByName(remark)
    if not magic then
        -- gf:ShowSmallTips(CHS[3004151])
        remark = remark or ""
        Log:D(remark .. CHS[3004151])
        return
    end

    if cfg.x then
        magic:setPositionX(cfg.x)
    end

    if cfg.y then
        local mapSize = MapMgr:getMapSize()
        magic:setPositionX(mapSize.height * Const.PANE_HEIGHT - cfg.y)
    end

    if type(magic.processSomeExtraPara) == 'function' then
        magic:processSomeExtraPara(cfg)
        return
    end

    -- 骨骼动画
    ArmatureMgr:processSomeExtraPara(magic, cfg)
end

-- 在地图特效层x,y播放动画，在角色模型下方
function MapMagicMgr:playArmatureByPos(magicInfo, x, y, magicName, callBack)
    local mapEffectLayer = gf:getMapEffectLayer()
    if mapEffectLayer:getChildByName(magicName) then
        return
    end

    local magic = ArmatureMgr:createMapArmature(magicInfo.name)

    local function cb(sender, eventType)
        if eventType == ccs.MovementEventType.complete then
            if not callBack or callBack == "remove" or type(callBack) ~= 'function' then
                -- 没有回调或者配置为remove则播放完动画后移除，否则调用回调
                magic:stopAllActions()
                magic:removeFromParent(true)
                magic = nil
            else
                callBack(magic)
            end
        end
    end

    magic:setAnchorPoint(0.5, 0.5)
    magic:getAnimation():setMovementEventCallFunc(cb)
    magic:getAnimation():play(magicInfo.action)

    magic:setPosition(x, y)
    magic:setName(magicName)
    mapEffectLayer:addChild(magic, 100)
    return magic
end

-- 在地图特效层x,y 播放循环光效
function MapMagicMgr:playLoopMagic(magicInfo, x, y, name)
    local mapEffectLayer = gf:getMapEffectLayer()
    if not mapEffectLayer then
        return
    end

    if mapEffectLayer:getChildByName(name) then
        return
    end

    local icon = magicInfo.icon
    local magic = gf:createLoopMagic(icon)
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(x, y)
    magic:setName(name)
    mapEffectLayer:addChild(magic)

    return magic
end

-- 根据name移除地图特效层
function MapMagicMgr:remoevMagicByName(name)
    local mapEffectLayer = gf:getMapEffectLayer()
    if not mapEffectLayer then
        return
    end

    local magic = mapEffectLayer:getChildByName(name)
    if magic then
        magic:removeFromParent()
        magic = nil
    end
end

-- 在地图特效层x,y 播放一次光效
function MapMagicMgr:playOnceMagic(magicInfo, x, y, callBack)
    local mapEffectLayer = gf:getMapEffectLayer()
    if not mapEffectLayer then
        return
    end

    local icon = magicInfo.icon
    local magic = gf:createCallbackMagic(icon, function(node)
        node:removeFromParent()
        if callBack then
            callBack()
        end
    end, magicInfo.extraPara)

    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(x, y)
    mapEffectLayer:addChild(magic)

    return magic
end

-- 重新加载地图光效配置文件
function MapMagicMgr:reloadMapMagicCfg()
    package.loaded["maps/magic/MapMagic"] = nil
    defaultMapMagic = require("maps/magic/MapMagic")
end
