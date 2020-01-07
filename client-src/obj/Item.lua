-- Item.lua
-- Created by chenyq Apr/21/2015
-- 场景中的道具

local Object = require("obj/Object")

local Item = class("Item", Object)

-- 对象进入场景
function Item:onEnterScene(mapX, mapY)
    self.mapX = mapX
    self.mapY = mapY
    
    Object.onEnterScene(self, mapX, mapY)
end

return Item
