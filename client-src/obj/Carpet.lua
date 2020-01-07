-- Carpet.lua
-- Created by chenyq Apr/21/2015
-- 地毯道具

local Dropped = require("obj/Dropped")

local Carpet = class("Carpet", Dropped)

local CarpetInfo = require("cfg/CarpetInfo")

local PORTRAIT = 1

function Carpet:init()
    self.meLastInCarpet = false
end

function Carpet:action()
    local icon = self:queryBasicInt("icon")
    if icon <= 0 then
        return
    end

    if CarpetInfo[icon] and CarpetInfo[icon].type == PORTRAIT then
        -- 头像
        local path = ResMgr:getBigPortrait(icon)
        local image = ccui.ImageView:create()
        image:loadTexture(path, ccui.TextureResType.localType)
        image:setPosition(0, 0)
        self:addToBottomLayer(image)

    else
        -- 光效
        local extraPara
        if CarpetInfo[icon] and CarpetInfo[icon].extraPara then
            extraPara = CarpetInfo[icon].extraPara
        end
        
        local magic = gf:createLoopMagic(icon, nil, extraPara)
        magic:setPosition(0, 0)
        self:addToBottomLayer(magic)
    end

    self.radius = self:queryBasicInt('carpet_radius')
end

-- x, y是否在Carpet的半径范围内
function Carpet:isInCarpet(x, y)
    local radius = self.radius
    if math.abs(x - self.mapX) < radius and math.abs(y - self.mapY) < radius then
        return true
    end

    return false
end

function Carpet:update()
    local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)
    local meInCarpet = self:isInCarpet(meX, meY)
    if not self.meLastInCarpet and meInCarpet then
        Me:sendAllLeftMoves()
        gf:CmdToServer('CMD_MOVE_ON_CARPET', { id = self:queryBasicInt('id') })
    end

    self.meLastInCarpet = meInCarpet
end

return Carpet
