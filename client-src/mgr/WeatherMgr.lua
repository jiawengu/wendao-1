-- WeatherMgr.lua
-- Created by lixh, Api/13/2018
-- 天气系统管理器

WeatherMgr = Singleton()

local Weather = require("obj/Weather")
local WEATHER_CONFIG = require (ResMgr:getCfgPath("WeatherCfg.lua"))

-- 需要添加天气的地图
WeatherMgr.needWeatherMap = {}

-- 获取mapId地图需要添加的天气
function WeatherMgr:getMapWeatherInfo(mapId)
    -- 有一些地图配置了常在的天气，这些地图的天气的添加不需要控制，直接在文件中有配置，可以直接通过mapId取到
    local weatherName = self:getWeatherCfgByName(mapId)
    local isGameEffectOk = self:isGameEffectOk()

    if weatherName and isGameEffectOk then
        -- 有配置mapId的天气信息说明是常在的
        return WeatherMgr:getWeatherCfgByName(weatherName)
    elseif self.needWeatherMap[mapId] and (isGameEffectOk or self.needWeatherMap[mapId].notRelatedToGameEffect) then
        return self.needWeatherMap[mapId]
    end
end

-- 获取配置文件中的天气信息
function WeatherMgr:getWeatherCfgByName(weatherName)
    return WEATHER_CONFIG[weatherName]
end

-- 设置需要播放天气的地图
-- notRelatedToGameEffect : 与游戏效果无关的天气，默认为 false， 一些特殊活动的天气系统需要设置此项
-- 与游戏效果有关的天气，需要在游戏效果为低时移除，游戏效果为低时不添加天气
function WeatherMgr:setMapWeatherById(mapId, weatherName, notRelatedToGameEffect)
    self.needWeatherMap[mapId] = self:getWeatherCfgByName(weatherName)
    self.needWeatherMap[mapId].notRelatedToGameEffect = notRelatedToGameEffect
end

-- 清除地图天气
function WeatherMgr:clearMapWeatherById(mapId)
    self.needWeatherMap[mapId] = nil
end

-- 添加天气系统
function WeatherMgr:addMapWeatherById(mapId, weatherName, notRelatedToGameEffect)
    if not weatherName then return end

    self:setMapWeatherById(mapId, weatherName, notRelatedToGameEffect)
    local curMapId = MapMgr:getCurrentMapId()
    if curMapId == 0 or curMapId ~= mapId then return end

    local weather = Weather:create(mapId)
    if weather then
        self:addWeather(weather)
    end
end

-- 移除天气系统
function WeatherMgr:removeWeather()
    gf:getWeatherLayer():removeAllChildren()
end

-- 清除数据
function WeatherMgr:clearData()
    WeatherMgr.needWeatherMap = {}
end

-- 添加天气到天气层
function WeatherMgr:addWeather(weather)
    self:removeWeather()
    gf:getWeatherLayer():addChild(weather)
end

-- 添加天气动画到天气动画层
function WeatherMgr:addWeatherAnim(weatherAnim)
    gf:getWeatherAnimLayer():removeAllChildren()
    gf:getWeatherAnimLayer():addChild(weatherAnim)
end

-- 根据地图id创建天气动画
function WeatherMgr:getWeatherAnim(mapId)
    if self:isGameEffectOk() and GameMgr.scene then
        return GameMgr.scene:createWeatherAnim(mapId)
    end
end

-- 当前游戏效果是否允许增加天气系统
function WeatherMgr:isGameEffectOk()
    return GAME_EFFECT.LOW ~= SystemSettingMgr:getSettingStatus("sight_scope")
end

-- 更新游戏效果, 天气系统和天气动画系统受影响
function WeatherMgr:OnSettingChanged(key, oldValue, newValue)
    if "sight_scope" ~= key then return end
    local isGameEffectOk = self:isGameEffectOk()

    local mapId = MapMgr:getCurrentMapId()
    local weatherCfg = self:getMapWeatherInfo(mapId)

    -- 天气系统是否显示，与游戏效果和具体活动配置都有关
    if weatherCfg then
        self:addMapWeatherById(mapId, weatherCfg.name, weatherCfg.notRelatedToGameEffect)
    else
        self:removeWeather()
    end

    -- 天气动画系统, 也受影响，在此一并处理
    if isGameEffectOk and GameMgr.scene and GameMgr.scene:getType() == "GameScene" then
        local weatherAnim = GameMgr.scene:createWeatherAnim(mapId)
        if weatherAnim then
            WeatherMgr:addWeatherAnim(weatherAnim)
        end
    else
        gf:getWeatherAnimLayer():removeAllChildren()
    end
end

EventDispatcher:addEventListener("SYSTEM_SETTING_CHANGE", WeatherMgr.OnSettingChanged, WeatherMgr)
