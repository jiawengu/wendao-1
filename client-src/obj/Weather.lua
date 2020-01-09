-- Weather.lua
-- Created by sujl, Mar/2/2017
-- 天气系统

local Weather = class("Weather", function()
    return cc.Layer:create()
end)

local RANDOM_SPEED = {-4, -3, -2, 0, 0, 0, 2, 3, 4};

function Weather:create(map_id)
    local no = WeatherMgr:getMapWeatherInfo(map_id)
    if not no then return end

    return Weather.new(map_id)
end

function Weather:ctor(map_id)
    if not map_id then return end
    local mapInfo = MapMgr:getMapinfo()
    local resourceMapId = mapInfo[map_id].map_id
    self.info = require(ResMgr:getMapInfoPath(resourceMapId))
    if not self.info then return end
    self.width = self.info.new_width
    self.height = self.info.new_height

    local cfg = WeatherMgr:getMapWeatherInfo(map_id)
    if not cfg then return end

    local no
    self.startX = 0
    self.startY = 0
    if 'table' == type(cfg) then
        no = cfg.icon
        self.speedX = cfg.xSpeed
        self.speedY = cfg.ySpeed
        self.blendMode = cfg.blendMode
        self.bgColor = cfg.bgColor
    else
        no = cfg
        self.speedX = RANDOM_SPEED[math.random(1, 9)]
        self.speedY = RANDOM_SPEED[math.random(1, 9)]
    end

    -- 加载天气贴图
    self.wTexture = cc.Director:getInstance():getTextureCache():addImage(ResMgr:getWeatherFilePath(no))
    if not self.wTexture then return end

    self.tw = self.wTexture:getPixelsWide()
    self.th = self.wTexture:getPixelsHigh()

    -- 创建天气系统
    self:createWeather()
end

-- 创建天气系统
function Weather:createWeather()
    -- 蒙板
    if self.bgColor then
        local colorLayer = cc.LayerColor:create(self.bgColor)
        colorLayer:setContentSize({width = self.width, height = self.height})
        self:addChild(colorLayer)
    end

    -- 获取贴图宽高
    local tw = self.tw
    local th = self.th

    self.sprites = {}
    local sprite

    local left = -tw
    local right = 0 == self.width % tw and self.width + tw or self.width + tw * 2
    local bottom = -th
    local top = 0 == self.height % th and self.height + th or self.height + th * 2

    for i = left, right, tw do
        for j = bottom, top, th do
            sprite = cc.Sprite:createWithTexture(self.wTexture)
            sprite:setPosition(self.startX + i, self.startY + j)
            self:addChild(sprite)
            if self.blendMode then
                sprite:setBlendFunc(self.blendMode.org, self.blendMode.tar)
            end

            table.insert(self.sprites, sprite)
        end
    end

    schedule(self, function()
        self:update()
    end)
end

-- 更新
function Weather:update()
    self.startX = self.startX + self.speedX
    if self.startX <= -self.tw or self.startX >= self.tw then self.startX = 0 end

    self.startY = self.startY + self.speedY
    if self.startY <= -self.th or self.startY >= self.th then self.startY = 0 end

    self:draw()
end

-- 绘制
function Weather:draw()
    local k = 1
    local sprite
    local tw = self.tw
    local th = self.th
    local left = -tw
    local right = 0 == self.width % tw and self.width + tw or self.width + tw * 2
    local bottom = -th
    local top = 0 == self.height % th and self.height + th or self.height + th * 2

    for i = left, right, tw do
        for j = bottom, top, th do
            sprite = self.sprites[k]
            sprite:setPosition(self.startX + i, self.startY + j)
            k = k + 1
        end
    end
end

return Weather
