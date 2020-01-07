-- GatherNpc.lua
-- Created by zhengjh Feb/29/2016
-- 采集npc

local Char = require("obj/Char")
local GatherNpc = class("GatherNpc", Char)
local Object = require("obj/Object")
local GatherConfig = require(ResMgr:getCfgPath("GatherConfig.lua"))

function GatherNpc:init()
    Char.init(self)
    self.needBindClickEvent = true

    EventDispatcher:addEventListener("GATHER_FINISHED", self.getherFinished, self)
end

function GatherNpc:getLoadType()
    return LOAD_TYPE.NPC
end

function GatherNpc:setAct(act)
    local icon = self:getIcon()
    local path = ResMgr:getBigPortrait(icon)
    local image = ccui.ImageView:create()
    image:loadTexture(path, ccui.TextureResType.localType)

    -- 配置锚点
    local gatherConfigIcon = GatherConfig[icon]
    local anchor_x = 0.5
    local anchor_y = 0
    if gatherConfigIcon then
        anchor_x = gatherConfigIcon.anchor_x or 0.5
        anchor_y = gatherConfigIcon.anchor_y or 0
    end

    image:setAnchorPoint(anchor_x, anchor_y)

    self.charAction = image

    -- 添加到中间层
    self:addToMiddleLayer(image)
    image:setLocalZOrder(Const.CHARACTION_ZORDER)

    -- 绑定事件
    self:bindEvent()

    -- 设置遮挡信息
    local mapX, mapY = gf:convertToMapSpace(self.curX, self.curY)
    self:updateShelter(mapX, mapY)

    -- 设置采集物默认光效
    self:addNormalGatherMagic()

    if gatherConfigIcon and gatherConfigIcon["flipX_by_map"] then
        -- 处理 x 方向的镜像
        local mapInfo = MapMgr:getCurrentMapInfo()
        if mapInfo then
            image:setFlippedX(mapInfo.flipX)

            if self.dbMagicInfo and self.dbMagicInfo.dbMagic then
                local dbMagic = self.dbMagicInfo.dbMagic
                if mapInfo.flipX then
                    DragonBonesMgr:toPlay(dbMagic, self.dbMagicInfo.actionName, -1)
                else
                    DragonBonesMgr:toPlay(dbMagic, self.dbMagicInfo.flipActionName, -1)
                end
            end
        end
    end
end

function GatherNpc:updateShelter(mapX, mapY)
    local map = GameMgr.scene.map
    if map == nil or self.charAction == nil then return end
    self:setShelter(map:isShelter(mapX, mapY))
end

function GatherNpc:setShelter(shelter)
    local opacity = shelter and 0x7f or 0xff
    self.charAction:setOpacity(opacity)
end

function GatherNpc:setDir()
end

function GatherNpc:onClickChar()
    Me:setAct(Const.FA_STAND)
    CharMgr:talkToGatherNpc(self)
end

function GatherNpc:getherFinished()
    Char.removeFocusMagic(self)
end

-- 点击对象时添加选中特效
function GatherNpc:addFocusMagic()
    -- 可以采集才添加光效
    if self:isCanGather() then
        Char.addFocusMagic(self)
    end
end

-- 采集物默认光效
function GatherNpc:addNormalGatherMagic()
    local icon = self:getIcon()
    local gatherConfigIcon = GatherConfig[icon]
    if not gatherConfigIcon or not gatherConfigIcon["normal_effect"] then
        return
    end

    local behindChar = gatherConfigIcon["normal_effect_behind_char"]
    local magic = gatherConfigIcon["normal_effect"]
    local armatureType = 0
    local magicKey = magic
    if gatherConfigIcon["normal_effect_type"] == "DBMagic" then
        -- 龙骨动画，类型为 3
        armatureType = 3
        magicKey = magic.icon

        self:tryToReleaseDbMagic()
        self.dbMagicInfo = magic
    end

    local magicNode, dbMagic = self:addMagicOnFoot(magic, behindChar, magicKey, armatureType)
    if dbMagic then
        DragonBonesMgr:toPlay(dbMagic, magic.actionName, -1)
        self.dbMagicInfo.dbMagic = dbMagic
    end
end

-- 采集光效
function GatherNpc:addGatherMagic()
    local behindChar = true
    local icon = self:getIcon()
    local gatherConfigIcon = GatherConfig[icon]
    if gatherConfigIcon and gatherConfigIcon["effect_behind_char"] ~= nil then
        behindChar = gatherConfigIcon["effect_behind_char"]
    end

    local extraPara = nil
    if gatherConfigIcon and gatherConfigIcon["normal_effect_extra_para"] then
        extraPara = gatherConfigIcon["normal_effect_extra_para"]
    end

    self:addMagicOnFoot(ResMgr.magic.gather_magic, behindChar, ResMgr.magic.gather_magic, nil, extraPara)
end

-- 移除光效
function GatherNpc:removeGatherMagic()
    self:deleteMagic(ResMgr.magic.gather_magic)
end


function GatherNpc:getIcon()
    local icon = self:queryBasicInt('icon')
    return icon
end

function GatherNpc:isCanGather()

    -- 如果客户端单方面的禁止移动，不能采集
    if Me.isLimitMoveByClient then
        return false
    end

    if self.status == 1 then
        return true
    else
        return false
    end
end

function GatherNpc:isCanTouch()
    if  MarryMgr:isWeddingStatus() or ActivityMgr:isChantingStauts() then
        return false
    elseif self:isCanGather()then
        return true
    else
        return false
    end
end

function GatherNpc:getShowName()
    local name = ""

    -- 如果是npc 显示用别名
    if  self:queryBasic('alicename') ~= "" then
        name = self:queryBasic('alicename')
    else
        name = gf:getRealName(self:queryBasic('name'))
    end

    if name == CHS[4000417] and GameMgr:isInPartyWar() then -- 矿区战旗
        if self:queryBasic("camp") == "" then
            return name
        elseif self:queryBasic("camp") == Me:queryBasic("party/name") then
            return CHS[4000418] -- 己方占领
        else
            return CHS[4000419]
        end
    elseif name == CHS[4010335] and DistMgr:isInKFZC2019Server() then -- 矿区战旗
        if self:queryBasic("camp") == "" then
            return name
        else
            return string.format( CHS[4010336], self:queryBasic("camp")) .. name
        end
    end

    return name
end

function GatherNpc:setVisible(visible)
    Char.setVisible(self, visible)

    if visible then
        -- 不采集隐藏名字,    矿区战旗除外
        local gath = GatherConfig[self:queryBasicInt("icon")]
        if not self:isCanGather() then
            -- 矿区战旗特别
            if GatherConfig[self:queryBasicInt("icon")] and GatherConfig[self:queryBasicInt("icon")].is_always_show_name then
            else
                self:setNameVisible(false)
            end
        end
    end
end

function GatherNpc:setNameVisible(isVible)
    if self.nameBgImage then
        self.nameBgImage:setVisible(isVible)
    end
end

function GatherNpc:setGatherStatus(status)
    self.status = status

    if status == 1 then
        self:addGatherMagic()
        self:setNameVisible(true)
    else
        self:removeGatherMagic()
        -- 矿区战旗特别
        if GatherConfig[self:queryBasicInt("icon")] and GatherConfig[self:queryBasicInt("icon")].is_always_show_name then
        else
            self:setNameVisible(false)
        end
    end
end

function GatherNpc:onAbsorbBasicFields()
    -- 更新名字
    self:updateName()
end

function GatherNpc:getShadow()
    local icon = self:getIcon()
    local gatherConfigIcon = GatherConfig[icon]
    if gatherConfigIcon and gatherConfigIcon["shadow_icon"] then
        if gatherConfigIcon["shadow_icon"] ~= "" then
            -- 影子文件默认放在目录'other/'下
            self:setBasic("shadow_icon", gatherConfigIcon["shadow_icon"])
        else
            return
        end
    end

    return Char.getShadow(self)
end

function GatherNpc:needConfirmBeforeGather()
    local icon = self:getIcon()
    local gatherConfigIcon = GatherConfig[icon]
    if gatherConfigIcon and gatherConfigIcon["confirm_before_gather"] then
        return gatherConfigIcon["confirm_before_gather"]
    end
end

function GatherNpc:tryToReleaseDbMagic()
    if self.dbMagicInfo then
        DragonBonesMgr:removeCharDragonBonesResoure(self.dbMagicInfo.icon, self.dbMagicInfo.armatureName)
        self.dbMagicInfo = nil
    end
end

-- 清理（重载）
function GatherNpc:cleanup()
    EventDispatcher:removeEventListener("GATHER_FINISHED", self.getherFinished, self)

    self:tryToReleaseDbMagic()
    Object.cleanup(self)
end

--
-- 在腰基准点上添加光效
-- behind：在人物前面还是人物后面
-- magicKey：如果没有设置，则动画播放完后自动删除
--           如果设置了，则动画循环播放，并保存在 self.magics 中
function GatherNpc:addMagicOnWaist(icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
    local magic = self:addMagic(0, 0, icon, behind, magicKey, armatureType, extraPara, callback, layerFlag)
    magic.getPosFunc = "getWaistOffset"

    return magic
end

return GatherNpc
