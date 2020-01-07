-- MapNpc.lua
-- Created by sujl, Aug/10/2017

local Object = require("obj/Object")
local MapNpc = class("MapNpc", Object)

function MapNpc:init()
end

function MapNpc:action()
    local icon = self:queryBasicInt("icon")
    local flip = self:queryBasicInt("flip") == 1
    local path = ResMgr:getMapNpcIcon(icon)
    local image = ccui.ImageView:create()
    image:loadTexture(path, ccui.TextureResType.localType)

    image:setAnchorPoint(0.5, 0.5)
    image:setFlippedX(flip)

    -- 加载tmx信息
    path = ResMgr:getMapNpcTmx(icon)
    self.tmx = ccexp.TMXTiledMap:create(path)
    if self.tmx then
        self.obstacle = self.tmx:getLayer("obstacle")
        self.shelter = self.tmx:getLayer("shelter")
        image:addChild(self.tmx)
        self.tmx:setVisible(false)
    end

    self.charAction = image

    -- 添加到底层
    self:addToBottomLayer(image)
    image:setLocalZOrder(Const.CHARACTION_ZORDER)
end

function MapNpc:getLayer()
    return self.obstacle
end

function MapNpc:getShelter()
    return self.shelter
end

-- 摆放家具
function MapNpc:putNpc()
    if not GameMgr.scene.map then return end

    local layer = self:getLayer()
    if not layer then return end

    local shelter = self:getShelter()

    local size = layer:getLayerSize()
    local contentSize = layer:getContentSize()
    local x, y = gf:convertToMapSpace(self.curX, self.curY)

    local beginX, beginY = math.floor(x - size.width / 2 + 0.5), math.floor(y - size.height / 2 + 0.5)
    local tileValue, shelterValue
    local t = {}
    for i = 0, size.width - 1 do
        for j = 0, size.height - 1 do
            if self:isFlip() then
                tileValue = layer:getTileGIDAt(cc.p(size.width - 1 - i, j))
                if shelter then
                    shelterValue = shelter:getTileGIDAt(cc.p(size.width - 1 - i, j))
                end
            else
                tileValue = layer:getTileGIDAt(cc.p(i, j))
                if shelter then
                    shelterValue = shelter:getTileGIDAt(cc.p(i, j))
                end
            end
            if tileValue ~= 0 then
                 -- 更新障碍信息
                if not GameMgr.scene.map:isMarkable('obstacleLayer', beginX + i, beginY + j) then
                    GameMgr.scene.map:markLayer('obstacleLayer', beginX + i, beginY + j, 0x7FFFFFFF)
                end
            end
            if shelterValue ~= 0 then
                 -- 更新障碍信息
                if not GameMgr.scene.map:isMarkable('shelterLayer', beginX + i, beginY + j) then
                    GameMgr.scene.map:markLayer('shelterLayer', beginX + i, beginY + j, 0x7FFFFFFF)
                end
            end
        end
    end

    GameMgr.scene.map:updateObstacle()
end

function MapNpc:isFlip()
    return self.charAction and self.charAction:isFlippedX()
end

return MapNpc