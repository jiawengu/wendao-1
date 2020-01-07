-- ArmatureMgr.lua
-- Created by zhengjh Jun/26/2016
-- 动作一些操作的管理器

ArmatureMgr = Singleton()

local furnCount = {}

-- 要加载动画必须先加载资源
function ArmatureMgr:addArmatureFileInfoByName(path)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
end

-- 移除资源，如果没有用
function ArmatureMgr:removeArmatureFileInfoByName(path)
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(path)
end

function ArmatureMgr:createArmature(name)
    -- 先加载资源
    local path = ResMgr:getUIArmatureFilePath(name)
    self:addArmatureFileInfoByName(path)
    return  ccs.Armature:create(name)
end

function ArmatureMgr:createUIArmature(icon)
    -- 先加载资源
    local icon = string.format("%05d", icon)
    local path = ResMgr:getUIArmatureFilePath(icon)
    self:addArmatureFileInfoByName(path)
    return  ccs.Armature:create(icon)
end

function ArmatureMgr:removeUIArmature(name)
    local path = ResMgr:getUIArmatureFilePath(name)
    self:removeArmatureFileInfoByName(path)
end

function ArmatureMgr:createSkillArmature(icon)
    -- 先加载资源
    local icon = string.format("%05d", icon)
    local path = ResMgr:getSkillFilePath(icon)
    self:addArmatureFileInfoByName(path)
    return  ccs.Armature:create(icon)
end

function ArmatureMgr:createCharArmature(icon)
    -- 先加载资源
    local icon = string.format("%05d", icon)
    local path = ResMgr:getCharFilePath(icon)
    self:addArmatureFileInfoByName(path)
    return  ccs.Armature:create(icon)
end

function ArmatureMgr:createMapArmature(icon)
    -- 先加载资源
    local icon = string.format("%05d", icon)
    local path = ResMgr:getMapFilePath(icon)
    self:addArmatureFileInfoByName(path)
    return ccs.Armature:create(icon)
end

function ArmatureMgr:createFurnitureArmature(icon)
    -- 先加载资源
    local icon = string.format("%05d", icon)
    local path = ResMgr:getAnimateFurniturePath(icon)
    self:addArmatureFileInfoByName(path)
    if not furnCount[icon] then
        furnCount[icon] = 0
    end

    furnCount[icon] = furnCount[icon] + 1

    return ccs.Armature:create(icon)
end

function ArmatureMgr:removeFurnitureArmature(icon)
    local icon = string.format("%05d", icon)
    if furnCount[icon] and furnCount[icon] > 0 then
        furnCount[icon] = furnCount[icon] - 1
    end

    if furnCount[icon] == 0 then
        local path = ResMgr:getAnimateFurniturePath(icon)
        self:removeArmatureFileInfoByName(path)
    end
end

-- 天气动画
function ArmatureMgr:createWeathArmature(icon)
    local icon = string.format("%05d", icon)
    local path = ResMgr:getWeatherAnimatePath(icon)
    self:addArmatureFileInfoByName(path)
    return ccs.Armature:create(icon)
end

function ArmatureMgr:createArmatureByType(type, icon, actionName)
    local magic
    if type == ARMATURE_TYPE.ARMATURE_MAP then
        magic = ArmatureMgr:createMapArmature(icon)
    elseif type == ARMATURE_TYPE.ARMATURE_SKILL then
        magic = ArmatureMgr:createSkillArmature(icon)
    elseif type == ARMATURE_TYPE.ARMATURE_CHAR then
        magic = ArmatureMgr:createCharArmature(icon)
    elseif type == ARMATURE_TYPE.ARMATURE_UI then
        magic = ArmatureMgr:createUIArmature(icon)
    end

    return magic
end

function ArmatureMgr:setArmaturePlayOnce(magic, actionName)
    local function func(sender, type, id)
        if type == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
        end
    end

    magic:setAnchorPoint(0.5, 0.5)
    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actionName, -1, 0)
end

-- 处理 cfg 中的如下数据
--     rotation     以锚点为中心旋转的角度
--     rotationX    绕 X 轴旋转的角度
--     rotationY    绕 Y 轴旋转的角度
--     scaleX       X 方向上缩放比例
--     scaleY       Y 方向上缩放比例
--     alpha        设置透明度
function ArmatureMgr:processSomeExtraPara(magic, cfg)
    if not magic then
        return
    end

    if cfg.rotation then
        magic:setRotation(cfg.rotation)
    end

    if cfg.rotationX then
        magic:setRotationSkewX(cfg.rotationX)
    end

    if cfg.rotationY then
        magic:setRotationSkewY(cfg.rotationY)
    end

    if cfg.scaleX then
        magic:setScaleX(cfg.scaleX)
    end

    if cfg.scaleY then
        magic:setScaleY(cfg.scaleY)
    end

    local alpha = cfg.alpha
    if alpha then
        magic:setCascadeOpacityEnabled(true)

        if alpha > 255 then
            alpha = 255
        elseif alpha < 0 then
            alpha = 0
        end

        magic:setOpacity(alpha)
    end
end

return ArmatureMgr
