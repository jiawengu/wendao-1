-- CarpetLayer.lua
-- Created by sujl, Jan/15/2017
-- 地毯层，模拟TMXLayer实现

local CarpetLayer = class("CarpetLayer")

function CarpetLayer:ctor(layer)
    self.layerSize = layer:getLayerSize()
    self.blocks = {}
    local v
    for j = 0, self.layerSize.height - 1 do
        for i = 0, self.layerSize.width - 1 do
            v, _ = layer:getTileGIDAt(cc.p(i, j))
            table.insert(self.blocks, v)
        end
    end
end

function CarpetLayer:getLayerSize()
    return self.layerSize
end

function CarpetLayer:getTileGIDAt(p)
    return self.blocks[self.layerSize.width * p.y + p.x + 1]
end

function CarpetLayer:setTileGID(v, p)
    self.blocks[self.layerSize.width * p.y + p.x + 1] = v
end

return CarpetLayer