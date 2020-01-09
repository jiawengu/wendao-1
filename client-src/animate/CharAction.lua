-- CharAction.lua
-- created by cheny Nov/14/2014
-- 角色动画，包含人物、武器等

local CharAction = class("CharAction", function()
    return cc.Sprite:create()
end)

local CharPart = require "animate.CharPart"
local ActionReplaceCfg = require (ResMgr:getCfgPath("ActionReplaceCfg.lua"))


local TAG_CHAR                  = 100
local TAG_WEAPON                = 101
local TAG_RIDE_BOTTOM           = 103
local TAG_RIDE_TOP              = 104
local TAG_CHAR_START            = 105       -- 共乘对象起始TAG
local TAG_CHAR_MAX              = 108       -- 共乘对象结束TAG
local TAG_CHAR_SHADOW = 109
local TAG_CHAR_PART_BEGIN       = 1001      -- 部件偏移值
local TAG_CHAR_PART_MAX         = 1020      -- 部件偏移值

local ZORDER_CHAR_SHADOW = -15
local ZORDER_RIDE_BOTTOM        = -10
local ZORDER_CHAR               = 0         -- 注意：[-10, 10] 都属于char[0]/共乘[-4, 4]
local ZORDER_CHAR_START         = 1         -- 共乘对象起始ORDER[1, 4] 或 [-1, -4]
local ZORDER_CHAR_MAX           = 4         -- 共乘对象结束ORDER
local ZORDER_CHAR_PART_START    = 1
local ZORDER_CHAR_PART_MAX      = 10
local ZORDER_WEAPON             = 11
local ZORDER_RIDE_TOP           = 12

local STATUS_TO_LOAD            = 1        -- 正在加载
local STATUS_LOADED             = 2        -- 加载完成

local GATHER_COUNT              = 4          -- 最大共乘数量

-- 测试代码
-- updateAll() update("obj/Me")

-- syncLoad : true 为异步加载，否则为同步加载
function CharAction:ctor(syncLoad, cb)
    self.icon = 0
    self.weaponIcon = 0
    self.direction = 5
    self.orgIcon = 0
    self.action = Const.SA_STAND
    self.rideIcon = 0
    self:setContentSize(cc.size(0,0))
    self:ignoreAnchorPointForPosition(false)
    self:setScale(Const.MAP_SCALE)
    self.firstFrame = Const.CHAR_FRAME_START_NO
    self.lastFrame = Const.CHAR_FRAME_START_NO + 99
    self.loopTimes = 0
    self.reverse = false
    self.syncLoad = syncLoad
    self.rideOffsetX = 0
    self.rideOffsetY = 0
    self.petRideInfo = {}
    self.charOpacity = 0xff
    self.isPausePlay = false
    self.dirtyUpdate = nil
    self.curIsTestDist = DistMgr:curIsTestDist()
    --self.refreshColorAction = nil

    -- 共乘对象icon
    for i = 1, GATHER_COUNT do
        self[string.format("icon%d", i)] = 0
    end

    -- 包含的动作列表状态
    self.partAniStatus = {}

    -- 先设置为不可见，等加载完成之后再设置为可见
    self:setVisible(false)
    self.loadComplateCallBack = nil

    -- 设置加载后的回调函数
    self:setLoadComplateCallBack(cb)

    self:setCascadeOpacityEnabled(true)

    if self.curIsTestDist then
        self.sendDebugLog = true
        local NODE_ENTER = Const.NODE_ENTER
        local NODE_EXIT = Const.NODE_EXIT
        local NODE_CLEAN = Const.NODE_CLEANUP
        local function onNodeEvent(event)
            if not self.sendDebugLog then return end
            if NODE_ENTER == event then
                DebugMgr:recordCharActionLog(tostring(self), "enter", debug.traceback())
            elseif NODE_EXIT == event then
                DebugMgr:recordCharActionLog(tostring(self), "exit", debug.traceback())
            elseif NODE_CLEANUP == event then
                DebugMgr:recordCharActionLog(tostring(self), "cleanup", debug.traceback())
            end
        end
        DebugMgr:recordCharActionLog(tostring(self), "ctor", debug.traceback())

        self:registerScriptHandler(onNodeEvent)
    end

end

function CharAction:initFrame()
end

-- 设置加载角色数据结束之后的回调
function CharAction:setLoadComplateCallBack(cb)
    self.loadComplateCallBack = cb
end

function CharAction:recordCallIndex(index)
    if self.owner and self.owner.recordCallLog then
        self.owner:recordCallLog(index)
    end
end

-- 设置相关信息
function CharAction:set(icon, weaponIcon, act, dir, rideIcon, gatherIcons, shadowIcon, partIndex, partColorIndex)
    self:setIcon(icon, true, rideIcon)
    self:setBodyPartIndex(partIndex, true)
    self:setBodyColorIndex(partColorIndex, true)
    self:setWeapon(weaponIcon, true)
    self:setAction(act, true)
    self:setDirection(dir, true)
    self:setRideIcon(rideIcon, true)
    self:setGatherIcons(gatherIcons, true)
    self:setShadowIcon(shadowIcon, true)

    self:updateNow()
end

-- 设置帧播放范围
function CharAction:setFrames(first, last, noUpdateNow)
    self.firstFrame = first
    self.lastFrame = last
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setFirstFrame(first)
            v:setLastFrame(last)
        end
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

-- 设置是否逆序播放
function CharAction:setReverse(reverse)
    if self.reverse == reverse then
        return
    end

    self.reverse = reverse
    if self.char then
        self.char:setReverse(reverse)
    end

    if self.weapon then
        self.weapon:setReverse(reverse)
    end
end

-- 设置角色编号
function CharAction:setIcon(icon, noUpdateNow, rideIcon)
    if icon == nil or self.icon == icon then
        return
    end

    self:recordCallIndex(201)

    self.icon = icon
    self.cartoonInfo = nil
    self:readCartoonInfo(rideIcon)
    self:setWeapon(0, true)
    self:setBodyPartIndex("", true)
    self:setBodyColorIndex("", true)

    self:recordCallIndex(202)

    -- 重新设置帧范围
    self:initFrame()

    local act
    -- 如果有骑宠，以骑宠动作为准
    if not rideIcon or rideIcon == 0 then
        act = self:getRealAction(TAG_CHAR)
    else
        act = self:getRealAction(TAG_RIDE_BOTTOM)
    end

    self:recordCallIndex(203)

    local char = self:getChildByTag(TAG_CHAR)
    if nil == char then
        self:recordCallIndex(204)
        char = CharPart.new(self.icon, 0, act, self:getRealDirection(), self:getBasicPoint(TAG_CHAR), self:getInterval(), self.syncLoad, self:getLoadType())
        char.owner = self.owner
        self:recordCallIndex(205)
        self:addChild(char, ZORDER_CHAR, TAG_CHAR)
        self:recordCallIndex(206)
        self.char = char

        -- 设置加载的状态
        char:setType("icon")
    end

    self:recordCallIndex(207)

    -- 模型变了，有些模型的 walk 动作会复用 stand 动作，所以需要重新设置动作
    char:setAction(act)

    self:recordCallIndex(208)

    char:setFirstFrame(self.firstFrame)
    char:setLastFrame(self.lastFrame)
    char:setLoopTimes(self.loopTimes)
    char:setReverse(self.reverse)
    char:setInterval(self:getInterval())
    char:setBasicPoint(self:getBasicPoint(TAG_CHAR))
    char:setIcon(self.icon, 0)
    char:setScale(1 / self:getCharScale())
    char:setPetSwingInfo(nil)

    self:recordCallIndex(209)

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
        self:recordCallIndex(210)
    end
    self:recordCallIndex(211)
end

-- 设置动作播放速度， speed : 2，速度变为原来一倍
function CharAction:setAnimationSpeed(speed)
    if speed <= 0 then return end
    local rate = 1 / speed

    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setFrameIntervalRate(rate)
        end
    end

    self:playAnimation()
end

-- 设置共乘角色
function CharAction:setGatherIcons(gatherIcons, noUpdateNow)
    local gatherCount = 0
    if gatherIcons then
        if 'table' == type(gatherIcons) then
            for i = 1, math.min(#gatherIcons, GATHER_COUNT) do
                self:setGatherIcon(i, gatherIcons[i], noUpdateNow)
            end
            gatherCount = #gatherIcons
        else
            self:setGatherIcon(1, gatherIcons, noUpdateNow)
            gatherCount = 1
        end
    end

    -- 清除不需要的数据
    for i = gatherCount + 1, GATHER_COUNT do
        self:setGatherIcon(i, 0, noUpdateNow)
    end
end

-- 设置共乘角色编号
function CharAction:setGatherIcon(index, icon, noUpdateNow)
    local iKey = string.format("icon%d", index)
    if index > GATHER_COUNT or icon == nil or self[iKey] == icon then
        return
    end

    self[iKey] = icon
    if self.cartoonInfo == nil then return end

    local tagValue = TAG_CHAR_START + (index - 1)
    local char = self:getChildByTag(tagValue)
    if 0 == icon then
        self[string.format("char%02d", index)] = nil
        if char then
            -- 删除共乘对象
            self:setPartToBeRemoved(tagValue)
            self:setPartAniLoadedDelay(char:getType())
            return
        end

        self.dirtyUpdate = true
        if not noUpdateNow then
            self:updateNow()
        end

        return
    end

    local act
    -- 如果有骑宠，以骑宠动作为准
    act = self:getRealAction(TAG_CHAR)

    if nil == char then
        char = CharPart.new(icon, 0, act, self:getRealDirection(), self:getBasicPoint(TAG_CHAR), self:getInterval(), self.syncLoad, self:getLoadType())
        self:addChild(char, ZORDER_CHAR_START - index - 1, tagValue)

        -- 设置加载的状态
        char:setType(string.format("char%02d", index))
    elseif self.toBeRemoveParts and self.toBeRemoveParts[tagValue] then
        self.toBeRemoveParts[tagValue] = nil
    end
    self[string.format("char%02d", index)] = char

    char:setFirstFrame(self.firstFrame)
    char:setLastFrame(self.lastFrame)
    char:setLoopTimes(self.loopTimes)
    char:setReverse(self.reverse)
    char:setInterval(self:getInterval())
    char:setBasicPoint(self:getBasicPoint(TAG_CHAR_START + index - 1))
    char:setIcon(self[iKey], 0)
    char:setScale(1 / self:getCharScale())
    char:setPetSwingInfo(nil)

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

-- 设置共乘角色编号
function CharAction:setShadowIcon(icon, noUpdateNow)
    if not icon or self.shadowIcon == icon then
        return
    end

    self.shadowIcon = icon
    if self.cartoonInfo == nil then return end

    local tagValue = TAG_CHAR_SHADOW
    local char = self:getChildByTag(tagValue)
    if 0 == icon then
        self.shadowIcon = nil
        if char then
            -- 删除影子
            self:setPartToBeRemoved(tagValue)
            self:setPartAniLoadedDelay(char:getType())
            self.shadow = nil
            return
        end

        self.dirtyUpdate = true
        if not noUpdateNow then
            self:updateNow()
        end

        return
    end

    local act
    -- 如果有骑宠，以骑宠动作为准\
    act = self:getRealAction(TAG_CHAR)

    if nil == char then
        char = CharPart.new(icon, 0, act, self:getRealDirection(), self:getBasicPoint(TAG_CHAR_SHADOW), self:getInterval(), self.syncLoad, self:getLoadType())
        self:addChild(char, ZORDER_CHAR_SHADOW, tagValue)

        -- 设置加载的状态
        char:setType("shadow")
    elseif self.toBeRemoveParts and self.toBeRemoveParts[tagValue] then
        self.toBeRemoveParts[tagValue] = nil
    end
    self.shadow = char

    char:setFirstFrame(self.firstFrame)
    char:setLastFrame(self.lastFrame)
    char:setLoopTimes(self.loopTimes)
    char:setReverse(self.reverse)
    char:setInterval(self:getInterval())
    char:setBasicPoint(self:getBasicPoint(TAG_CHAR_SHADOW))
    char:setIcon(self.shadowIcon, 0)
    char:setScale(self:getShadowScale())
    char:setPetSwingInfo(nil)

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

-- 设置部件索引
function CharAction:setBodyPartIndex(index, noUpdateNow)
    if not self.icon or self.partIndex == index or (string.isNilOrEmpty(index) and (string.isNilOrEmpty(self.partIndex))) then
        return
    end

    self.partIndex = index
    self:setBodyColorIndex("", true)
    if not self.cartoonInfo then return end

    local count = index and math.floor(#index / 2) or 0

    -- 读取部件信息
    for i = 1, count do
        local j = tonumber(string.sub(index, i * 2 - 1, i * 2))
        if j > 0 then
            local icon = self:getCharPartIcon(tonumber(string.format("%02d%03d", i, j)))
            if icon then
                self:setBodyPart(string.format("charpart%d", i), icon, TAG_CHAR_PART_BEGIN + i - 1, ZORDER_CHAR_PART_START + i - 1)
            end
        else
            self:setBodyPart(string.format("charpart%d", i), 0, TAG_CHAR_PART_BEGIN + i - 1, 0)
        end
    end

    -- 移除不需要的部件
    local fromTag = TAG_CHAR_PART_BEGIN + count
    local children = self:getChildren()
    if children then
        for i, v in ipairs(children) do
            if v then
                local tag = v:getTag()
                if tag >= fromTag and tag <= TAG_CHAR_PART_MAX then
                    self:setBodyPart(string.format("charpart%d", i), 0, tag, 0)
                end
            end
        end
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

-- 部件是否存在
function CharAction:checkCharPartExist(icon, weapon, action)
    local path = string.format("%05d/%05d", icon, weapon)
    local actStr = gf:getActionStr(action or Const.SA_STAND)
    local plist = ResMgr:getCharPath(path, actStr) .. ".plist"

    return cc.FileUtils:getInstance():isFileExist(plist)
end

-- 获取部件实际编号
function CharAction:getCharPartIcon(icon)
    local realIcon = self.icon
    local action = self.action or Const.SA_STAND
    if self:checkCharPartExist(realIcon, icon, action) then
        return icon
    else
        return 0
    end
end

-- 设置部件
function CharAction:setBodyPart(type, icon, tag, zorder)
    local part = self:getChildByTag(tag)
    if not part and 0 == icon then return end
    if part and part.icon == self.icon and part.weapon == icon then
        -- 部件可能处于被析构中
        if self.toBeRemoveParts and self.toBeRemoveParts[tag] then
            self.toBeRemoveParts[tag] = nil
        end
        self:setPartAniLoadedDelay(part:getType())
        return
    end
    if part and 0 == icon then
        self:setPartToBeRemoved(tag)
        self:setPartAniLoadedDelay(part:getType())
        return
    end

    local realIcon = self.icon
    if not part then
        part = CharPart.new(realIcon, icon, self.action, self:getRealDirection(), self:getBasicPoint(tag), self:getInterval(), self.syncLoad, self:getLoadType())
        part.owner = self.owner
        self:addChild(part, zorder, tag)

        -- 设置加载的状态
        part:setType(type)
    elseif self.toBeRemoveParts and self.toBeRemoveParts[tag] then
        self.toBeRemoveParts[tag] = nil
    end

    part:setFirstFrame(self.firstFrame)
    part:setLastFrame(self.lastFrame)
    part:setLoopTimes(self.loopTimes)
    part:setReverse(self.reverse)
    part:setInterval(self:getInterval())
    part:setBasicPoint(self:getBasicPoint(TAG_CHAR))
    part:setIcon(realIcon, icon)
    part:setScale(self:getWeaponScale(icon))
end

function CharAction:setBodyColorIndex(index, noUpdateNow)
    if index == self.partColorIndex or (string.isNilOrEmpty(index) and (string.isNilOrEmpty(self.partColorIndex))) then return end

    index = index or ""
    self.partColorIndex = index

    local function _setBodyColorIndex()
    local tag, part, colorIndex
    local children = self:getChildren()
    for i = 1, #children do
        part = children[i]
        tag = part:getTag()
        if part then
            local j
            if tag >= TAG_CHAR_PART_BEGIN and tag <= TAG_CHAR_PART_MAX then
                -- 换色部件
                j = tag - TAG_CHAR_PART_BEGIN + 2 -- 1为裸模
            elseif tag == TAG_CHAR then
                -- 裸模
                j = 1
            end

            if j then
                local colorIndex = tonumber(string.sub(index, j * 2 - 1, j * 2))
                if colorIndex and colorIndex > 0 then
                    local path = ResMgr:getCharPartColorPath(part.icon, part.weapon)
                    if not cc.FileUtils:getInstance():isFileExist(path) then
                        path = ResMgr:getCharPartColorPath(part.icon, part.weapon, ".luac")
                    end
                    local colorCfg = cc.FileUtils:getInstance():isFileExist(path) and require(path)
                    if colorCfg and colorCfg[colorIndex] then
                        local shader = ShaderMgr:getSimpleColorChangeShader(tostring(colorCfg[colorIndex]))
                        shader:setUniformVec3("delta", colorCfg[colorIndex].delta)
                        shader:setUniformVec2("range", colorCfg[colorIndex].range)
                        shader:setUniformVec2("range1", colorCfg[colorIndex].range1 or cc.p(1, 0))

                        if colorCfg[colorIndex].rate then
                            shader:setUniformMat4("rate", colorCfg[colorIndex].rate)
                        end

                        part:setGLProgramState(shader)
                    else
                        part:setGLProgramState(ShaderMgr:getRawShader())
                    end
                else
                    part:setGLProgramState(ShaderMgr:getRawShader())
                end
            end
        end
    end
        self.refreshColorIndex = nil
        --[[
        if self.refreshColorAction then
            self:stopAction(self.refreshColorAction)
        end
        self.refreshColorAction = nil
        ]]
    end

    --[[
    if self.refreshColorAction then
        self:stopAction(self.refreshColorAction)
        self.refreshColorAction = nil
    end
    ]]

    if self:isAllPartLoaded() and not noUpdateNow then
        -- 部件已经全部加载完成，且没有要求要手动刷新，此处直接刷新即可
        _setBodyColorIndex()
    else
        -- 部件还没有加载完成或要求手动刷新
        self.refreshColorIndex = _setBodyColorIndex
        if noUpdateNow then
            self.dirtyUpdate = true
        end
        --[[
        self.refreshColorAction = performWithDelay(self, function()
            local isLoaded = true
            for k, v in pairs(self.partAniStatus) do
                if STATUS_TO_LOAD == v then
                    isLoaded = false
                    break
                end
            end

            if isLoaded then
                _setBodyColorIndex()
            end
            self.refreshColorAction = nil
        end, 0)
        ]]
    end
end

-- 设置武器编号
function CharAction:setWeapon(icon, noUpdateNow)
    if not icon or self.weaponIcon == icon then
        return
    end

    self:recordCallIndex(212)

    self.weaponIcon = icon

    if self.cartoonInfo == nil then return end

    local weapon = self:getChildByTag(TAG_WEAPON)
    if 0 == icon and weapon then
        -- 删除武器
        self:setPartToBeRemoved(TAG_WEAPON)
        self:setPartAniLoadedDelay(weapon:getType())
        self.weapon = nil
        self:recordCallIndex(213)
        return
    end

    local realIcon = self.icon

    if self.orgIcon and self.orgIcon ~= 0 then
        realIcon = self.orgIcon
    end

    self:recordCallIndex(214)
    if nil == weapon then
        self:recordCallIndex(215)
        weapon = CharPart.new(realIcon, self.weaponIcon, self.action, self:getRealDirection(), self:getBasicPoint(TAG_WEAPON), self:getInterval(), self.syncLoad, self:getLoadType())
        weapon.owner = self.owner
        self:recordCallIndex(214)
        self:addChild(weapon, ZORDER_WEAPON, TAG_WEAPON)

        -- 设置加载的状态
        weapon:setType("weapon")
    elseif self.toBeRemoveParts and self.toBeRemoveParts[TAG_WEAPON] then
        self.toBeRemoveParts[TAG_WEAPON] = nil
    end

    self.weapon = weapon

    self:recordCallIndex(216)

    weapon:setFirstFrame(self.firstFrame)
    weapon:setLastFrame(self.lastFrame)
    weapon:setLoopTimes(self.loopTimes)
    weapon:setReverse(self.reverse)
    weapon:setInterval(self:getInterval())
    weapon:setBasicPoint(self:getBasicPoint(TAG_WEAPON))
    weapon:setIcon(realIcon, self.weaponIcon)
    weapon:setScale(self:getWeaponScale(self.weaponIcon))

    local cfg = CharMgr:getCharCfg(realIcon)
    if cfg and cfg.weaponBlendMode then
        weapon:setBlendMode(cfg.weaponBlendMode[icon])
    end

    self:recordCallIndex(217)

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
        self:recordCallIndex(218)
    end
    self:recordCallIndex(219)
end

-- 判断点是否在该模型上
function CharAction:containsTouchPos(touch)
    local localPos = self:convertTouchToNodeSpace(touch)
    local scale =  self:getCharScale()
    local isContain = false

    -- 需要特殊处理的模型点击区域
    local cfg = CharMgr:getCharCfg(self.icon)
    if self.icon and cfg and self.char.contentRect then
        local clickRect = cfg.clickRect
        if clickRect then
            self.char.contentRect.x = clickRect.x
            self.char.contentRect.y = clickRect.y
            self.char.contentRect.width = clickRect.width
            self.char.contentRect.height = clickRect.height
        end
    end

    if self.char.contentRect then
        local rec = cc.rect(self.char.contentRect.x * scale, self.char.contentRect.y * scale,
        self.char.contentRect.width * scale, self.char.contentRect.height * scale)
        local x, y = self:getRideOffset()
        rec.x = rec.x + x
        rec.y = rec.y + y
        isContain = cc.rectContainsPoint(rec, localPos)
    end

    -- 需要特殊处理的模型点击区域
    local cfg = CharMgr:getCharCfg(self.rideIcon)
    if self.rideIcon and cfg and self.rideBottom.contentRect then
        local clickRect = cfg.clickRect
        if clickRect then
            self.rideBottom.contentRect.x = clickRect.x
            self.rideBottom.contentRect.y = clickRect.y
            self.rideBottom.contentRect.width = clickRect.width
            self.rideBottom.contentRect.height = clickRect.height
        end
    end

    if not isContain and self.rideBottom and self.rideBottom.contentRect then
        local rec = cc.rect(self.rideBottom.contentRect.x * scale, self.rideBottom.contentRect.y * scale,
            self.rideBottom.contentRect.width * scale, self.rideBottom.contentRect.height * scale)
        isContain = cc.rectContainsPoint(rec, localPos)
    end

    local cfg = CharMgr:getCharCfg(self.rideIcon)
    if not isContain and not cfg and self.rideTop and self.rideTop.contentRect then
        local rec = cc.rect(self.rideTop.contentRect.x * scale, self.rideTop.contentRect.y * scale,
            self.rideTop.contentRect.width * scale, self.rideTop.contentRect.height * scale)
        isContain = cc.rectContainsPoint(rec, localPos)
    end

    if not isContain then
        local charpart, rect
        for i = 1, GATHER_COUNT do
            charpart = self:getChildByTag(TAG_CHAR_START + i - 1)
            -- charpart = self[string.format("char%02d", i)]
            if charpart and charpart.contentRect then
                rect = cc.rect(charpart.contentRect.x * scale, charpart.contentRect.y * scale,
                charpart.contentRect.width * scale, charpart.contentRect.height * scale)
                isContain = cc.rectContainsPoint(rect, localPos)
                if isContain then break end
            end
        end
    end

    return isContain
end

-- 设置坐骑
function CharAction:setRideIcon(icon, noUpdateNow)
    if not icon or self.rideIcon == icon then
        return
    end

    self.rideIcon = icon
    self:readCartoonInfo()

    if self.cartoonInfo == nil then
        return
    end

    -- 更新骑宠乘骑信息
    if self.rideIcon > 0 then
        self.petRideInfo = PetMgr:getPetRideInfo(self.rideIcon)
    else
        self.petRideInfo = {}

        if self.char then
            self.char:setPetSwingInfo(nil)
        end
    end

    -- 骑宠发生了变化，需要清除相应的缓存信息
    self:clearBasicPointRange()

    self:setRideBottom(icon, noUpdateNow) -- 骑乘下部分

    if self.petRideInfo["have_top_layer"] then
        self:setRideTop(icon, noUpdateNow) -- 骑乘上部分
    else
        self:setRideTop(0, noUpdateNow)
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

function CharAction:setRideBottom(icon, noUpdateNow)
    local ride = self:getChildByTag(TAG_RIDE_BOTTOM)
    if 0 == icon then
        if ride then
        -- 删除坐骑
            self:setPartToBeRemoved(TAG_RIDE_BOTTOM)
            self:setPartAniLoadedDelay(ride:getType())
        self.rideBottom = nil
        end

        self.dirtyUpdate = true
        if not noUpdateNow then
            self:updateNow()
        end

        return
    end

    local act = self:getRealAction(TAG_RIDE_BOTTOM)
    if nil == ride then
        ride = CharPart.new(icon, 0, act, self:getRealDirection(), self:getBasicPoint(TAG_RIDE_BOTTOM), self:getInterval(), self.syncLoad, self:getLoadType())
        self:addChild(ride, ZORDER_RIDE_BOTTOM, TAG_RIDE_BOTTOM)
        -- 设置加载的状态
        ride:setType("ride_bottom")
    elseif self.toBeRemoveParts and self.toBeRemoveParts[TAG_RIDE_BOTTOM] then
        self.toBeRemoveParts[TAG_RIDE_BOTTOM] = nil
    end

    self.rideBottom = ride

    -- 模型变了，有些模型的 walk 动作会复用 stand 动作，所以需要重新设置动作
    ride:setAction(act)

    -- 之前为self.char执行setAction()操作时，self.rideIcon尚未赋值，导致错误；此时重新setAction()
    if self.char then
        -- 有骑宠，以骑宠动作为准
        self.char:setAction(act)
    end

    ride:setFirstFrame(self.firstFrame)
    ride:setLastFrame(self.lastFrame)
    ride:setLoopTimes(self.loopTimes)
    ride:setReverse(self.reverse)
    ride:setInterval(self:getInterval())
    ride:setBasicPoint(self:getBasicPoint(TAG_RIDE_BOTTOM))
    ride:setIcon(icon, 0)
    ride:setScale(1/self:getCharScale())

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

function CharAction:setRideTop(icon, noUpdateNow)
    local ride = self:getChildByTag(TAG_RIDE_TOP)
    if 0 == icon then
        if ride then
        -- 删除坐骑
        self:setPartToBeRemoved(TAG_RIDE_TOP)
        self:setPartAniLoadedDelay(ride:getType())
        self.rideTop = nil
        end

        return
    end

    local act = self:getRealAction(TAG_RIDE_TOP)
    if nil == ride then
        ride = CharPart.new(icon, 1, act, self:getRealDirection(), self:getBasicPoint(TAG_RIDE_TOP), self:getInterval(), self.syncLoad, self:getLoadType())
        self:addChild(ride, ZORDER_RIDE_TOP, TAG_RIDE_TOP)

        -- 设置加载的状态
        ride:setType("ride_top")
    elseif self.toBeRemoveParts and self.toBeRemoveParts[TAG_RIDE_TOP] then
        self.toBeRemoveParts[TAG_RIDE_TOP] = nil
    end

    self.rideTop = ride

    -- 模型变了，有些模型的 walk 动作会复用 stand 动作，所以需要重新设置动作
    ride:setAction(act)

    ride:setFirstFrame(self.firstFrame)
    ride:setLastFrame(self.lastFrame)
    ride:setLoopTimes(self.loopTimes)
    ride:setReverse(self.reverse)
    ride:setInterval(self:getInterval())
    ride:setBasicPoint(self:getBasicPoint(TAG_RIDE_TOP))
    ride:setIcon(icon, 1)
    ride:setScale(1/self:getCharScale())

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

-- 有些坐骑对应的人物乘骑的 walk 动作不在 00000 目录，需要修改
function CharAction:tryToChangeCharWalkResPathForRide()
    if not self.char then
        return
    end

    local walkIcon = self.petRideInfo["walk_icon"]
    if self.rideIcon and self.rideIcon > 0 and self.action == Const.SA_WALK and walkIcon and walkIcon > 0 then
        self.char:setIcon(self.icon, walkIcon)
        for i = 1, GATHER_COUNT do
            local char = self:getChildByTag(TAG_CHAR_START + i - 1)
            if char then
                local iKey = string.format("icon%d", i)
                char:setIcon(self[iKey], walkIcon)
            end
        end
    else
        self.char:setIcon(self.icon, 0)
        for i = 1, GATHER_COUNT do
            local char = self[string.format("char%02d", i)]
            if char then
                local iKey = string.format("icon%d", i)
                char:setIcon(self[iKey], 0)
            end
        end
    end
end

function CharAction:tryToChangeCharOrder()
    if not self.char then return end

    local step = 1
    if 5 == self.direction or 7 == self.direction then
        step = -1
    end
    local curOrder = 0
    for i = 1, GATHER_COUNT do
        local char = self:getChildByTag(TAG_CHAR_START + i - 1)
        if char then
            curOrder = curOrder + step
            char:setLocalZOrder(curOrder)
        end
    end
end

-- 设置动作
function CharAction:setAction(act, noUpdateNow)
    if act == nil or self.action == act then
        return
    end

    -- 如果有骑宠，以骑宠动作为准
    local actOld = self:getRealAction(TAG_RIDE_BOTTOM)
    self.action = act
    local actNew = self:getRealAction(TAG_RIDE_BOTTOM)

    if self.rideIcon and self.rideIcon > 0 and actOld == actNew then
        -- 骑宠模型，walk 动作复用的是 stand 动作
        -- 无需重新设置动作
        return
    end

    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setInterval(self:getInterval())
            v:setBasicPoint(self:getBasicPoint(v:getTag()))
            v:setAction(self:getRealAction(v:getTag()))
        end
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end

    -- 设置完动作后，更新动作播放时间
    self.totalDelayUnits = self:getTotalDelayUnits()
end

-- 删除无用的部件
function CharAction:removeUnUsedPart()
    if not self.toBeRemoveParts then return end

    local part
    for k, _ in pairs(self.toBeRemoveParts) do
        part = self:getChildByTag(k)
        if part then
            part:removeFromParent()
        end
    end

    self.toBeRemoveParts = null
end

-- 获取动作播放时间：多部件时以char的动作播放时间为准
function CharAction:getTotalDelayUnits()
    return self.char:getTotalDelayUnits()
end

-- 乘骑模型中有些角色的乘骑动作的方向需要做特殊转换，例如土男骑鹿的 2 方向
function CharAction:tryToChangeCharResDirForRide()
    if not self.char or not self.rideIcon or self.rideIcon == 0 then
        -- 不是乘骑模型
        return
    end

    local dir = PetMgr:tryToChangeCharResDirForRide(self.icon, self.rideIcon, self.direction)
    self.char:setDirection(dir or self:getRealDirection())
end

-- 设置方向
function CharAction:setDirection(dir, noUpdateNow)
    if dir == nil or self.direction == dir then return end
    self.direction = dir

    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setInterval(self:getInterval())
            v:setBasicPoint(self:getBasicPoint(v:getTag()))
            v:setDirection(self:getRealDirection())
        end
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

function CharAction:setLoopTimes(times, noUpdateNow)
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setLoopTimes(times)
        end
    end

    self.dirtyUpdate = true
    if not noUpdateNow then
        self:updateNow()
    end
end

function CharAction:isDirtyUpdate()
    return self.dirtyUpdate
end

-- 立即更新
function CharAction:updateNow()
    self.dirtyUpdate = nil

    self:recordCallIndex(107)
    -- 将所有的部件设置为加载状态
    self:setAllAniToLoad()

    -- 乘骑模型中有些角色的乘骑动作的方向需要做特殊转换，例如土男骑鹿的 2 方向
    self:tryToChangeCharResDirForRide()

    -- 有些坐骑对应的人物乘骑的 walk 动作不在 00000 目录，需要修改
    self:tryToChangeCharWalkResPathForRide()

    self:tryToChangeCharOrder()

    self:recordCallIndex(108)

    if self.rideBottom and self.petRideInfo then
        -- 有坐骑，设置坐骑摆动信息
        local act = (self:getRealAction(TAG_RIDE_BOTTOM) == Const.SA_STAND and "stand" or "walk")
        local key = act .. "_swing" .. self.direction
        local swingInfo = self.petRideInfo[key]

        self.char:setPetSwingInfo(swingInfo)
        local char
        for i = 1, GATHER_COUNT do
            char = self:getChildByTag(TAG_CHAR_START + i - 1)
            if char then
                char:setPetSwingInfo(swingInfo)
            end
        end

        if self.petRideInfo['use_swing_for_who'] == 'char' then
            -- 只对角色使用摆动操作
            swingInfo = nil
        end

        self.rideBottom:setPetSwingInfo(swingInfo)

        if self.rideTop then
            self.rideTop:setPetSwingInfo(swingInfo)
        end
    else
        self.char:setPetSwingInfo(nil)
        self:clearBasicPointRange()
    end

    self:recordCallIndex(109)

    local interval = self:getInterval()
    local _, flip = self:getRealDirection()
    local children = self:getChildren()

    -- 先缓存需要更新的部件
    -- 因为在更新过程中，需要删除的部件会被删除掉，导致循环异常
    local needs = {}
    for _, v in pairs(children) do
        if not self:isToBeRemove(v:getTag()) then
            table.insert(needs, v)
        end
    end
    for _, v in pairs(needs) do
        if self:isCharPart(v) then
            if v.setFlippedX then
                v:setFlippedX(flip)
            end

            v:setInterval(interval)

            -- 为了保证各个部件播放一致，此处需要全部更新
            v.dirty = true
            v:updateNow()
        end
    end

    self:recordCallIndex(110)

    --self:resetArea()

    self:recordCallIndex(111)
end

function CharAction:resetAction()
    self.char:setCallback(nil)
    self:setLoopTimes(0)
    self:setAction(Const.SA_STAND)
end

function CharAction:clearEndActionCallBack()
    if self.char then
        self.char:setCallback(nil)
    end
end

-- 播放一次动作，默认播放物理动作
function CharAction:playActionOnce(cb, action)
    self:playAction(cb, action, 1)
end

function CharAction:playAction(cb, action, time)
    if self.action ~= Const.SA_STAND then
        -- 只有在站立动作可直接切换为施法动作（别的动作目前无此需求）
        return
    end

    action = action or Const.SA_ATTACK

    local destActCartoonInfo = self.cartoonInfo[gf:getActionStr(action)]

    -- 有可能该动作复用其他地方
    if not destActCartoonInfo then

        if AnimationMgr:isReplaceAction(self.icon, action) then
            destActCartoonInfo = ActionReplaceCfg[self.icon]["replaceAct"][gf:getActionStr(action)]
        end
    end

    if not destActCartoonInfo and not self.cartoonInfo["attack"] then
        Log:W(self.icon .. ' no attack action!')
        return
    end

    self.char:setCallback(function()
        self:resetAction()

		-- 如果设置了回调，则需要进行调用
        if cb then
            cb()
        end
    end)

	self:setLoopTimes(time)
	self:setAction(action)
end

function CharAction:playWalkThreeTimes(cb)
    if not self.cartoonInfo["walk"] then
        Log:W(self.icon .. ' no walk action!')
        return
    end

    self.char:setCallback(function()
        self:resetAction()

        -- 如果设置了回调，则需要进行调用
        if cb then
            cb()
        end
    end)
    self:setLoopTimes(3)
    self:setAction(Const.SA_WALK)
end

-- 暂停播放
function CharAction:pausePlay()
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:pausePlay()
        end
    end

    self.isPausePlay = true
end

-- 继续播放
function CharAction:continuePlay()
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:continuePlay()
        end
    end

    self.isPausePlay = false
end

-- 设置乘骑偏移
function CharAction:setRideOffset(x, y)
    self.rideOffsetX = x
    self.rideOffsetY = y
end

function CharAction:getGatherSuffix()
    local keys = {}

    for i = 1, GATHER_COUNT do
        local iKey = string.format("icon%d", i)
        if self[iKey] and self[iKey] > 0 then
            table.insert(keys, self[iKey])
        end
    end

    return table.concat(keys, ":")
end

-- 获取骑乘偏移
function CharAction:getRideOffset(icon, tag)
    if tag and (tag < TAG_CHAR_START or tag > TAG_CHAR_MAX) then tag = nil end -- 只有共乘部分需要通过TAG获取
    icon = icon or self.icon
    local offsetX, offsetY
    offsetX, offsetY = PetMgr:getRideOffset(icon, self.rideIcon, self.direction, self:getRealAction(TAG_RIDE_BOTTOM), self.icon .. ":" .. self:getGatherSuffix())
    if 0 == offsetX and 0 == offsetY then
        offsetX, offsetY = PetMgr:getRideOffset(icon, self.rideIcon, self.direction, self:getRealAction(TAG_RIDE_BOTTOM), tag)
    end
    if 0 == offsetX and 0 == offsetY then
        -- 没有配置，取默认的吧
        offsetX, offsetY = PetMgr:getRideOffset(icon, self.rideIcon, self.direction, self:getRealAction(TAG_RIDE_BOTTOM))
    end
    local x = (self.rideOffsetX or 0) + offsetX
    local y = (self.rideOffsetY or 0) + offsetY

    return x, y
end

-- 重新设置范围
function CharAction:resetArea()
    local char = self.char
    if self.rideBottom then
        -- 有坐骑，已坐骑为准
        char = self.rideBottom
        self:setRideOffset(
            self:getCfgInt('waist_x', self.action) - self:getCfgInt('centre_x', self.action),
            self:getCfgInt('centre_y', self.action) - self:getCfgInt('waist_y', self.action)
        )
    else
        self:setRideOffset(0, 0)
    end

    if not char then
        return
    end

    self:setContentSize(char.contentSize or cc.size(0,0))
    self:setAnchorPoint(char.anchorPoint or cc.p(0,0))
    local pos = char.offsetPos or cc.p(0,0)
    local children = self:getChildren()
    local offX, offY
    local tagValue

    for _, v in pairs(children) do
        if self:isCharPart(v) then
            tagValue = v:getTag()
            if tagValue >= TAG_CHAR_START and tagValue <= TAG_CHAR_MAX then
                offX, offY = self:getRideOffset(v.icon, v:getTag())
            else
                offX, offY = self:getRideOffset()
            end

            v:setPosition(pos.x + offX, pos.y + offY)
        end
    end

    -- 坐骑或者非乘骑角色不需要加 rideOffset
    char:setPosition(char.offsetPos or cc.p(0, 0))

    -- 有骑乘上层不需要加 rideOffset
    if self.rideTop then
        self.rideTop:setPosition(char.offsetPos or cc.p(0, 0))
    end

    -- 影子不需要加rideOffset
    if self.shadow then
        self.shadow:setPosition(char.offsetPos or cc.p(0, 0))
end
end

-- 读取动画配置
function CharAction:readCartoonInfo(rideIcon)
    local cartoonInfo = require(ResMgr:getCharCartoonPath(self.icon)) or {}
    self.charCartoonInfo = cartoonInfo
    self.cartoonInfo = cartoonInfo

    -- 如果是乘骑模型，需要以骑宠动画的配置信息为准
    local useRideIcon = rideIcon or self.rideIcon
    if useRideIcon and useRideIcon > 0 then
        cartoonInfo = require(ResMgr:getCharCartoonPath(useRideIcon)) or {}
        self.cartoonInfo = cartoonInfo
    end
end

-- 从指定的配置信息中读取配置
function CharAction:getCfgIntByInfo(key, act, dontChangeAct, cartoonInfo)
    local action = gf:getActionStr(act)
    if action == nil then
        return 0
    end

    local info = cartoonInfo[action]

    if not info then
        if ActionReplaceCfg[self.icon] and ActionReplaceCfg[self.icon]["replaceAct"][action] then
            local destCartoon = require(ResMgr:getCharCartoonPath(ActionReplaceCfg[self.icon].icon))
            info = destCartoon[action]
            cartoonInfo[action] = info
        end
    end


    if (not info or not info["centre_x"]) and not dontChangeAct then
        -- 动作不存在且需要判断是否复用别的动作
        local reuseAct = ACTION_REUSE_MAP[act]
        if reuseAct then
            action = gf:getActionStr(reuseAct)
            info = cartoonInfo[action]
        end
    end

    if self:isCustomDressPlayAttack2() then
        -- 部分自定义时装播放attack时，需要改为播放attack2
        info = cartoonInfo[gf:getActionStr(Const.SA_ATTACK2)]
    end

    if not info then
        return 0
    end

    local realDir, flip = self:getRealDirection()
    if info[key .. "_4"] then
        -- 有 5 个方向的资源，分别为 2、3、4、5、6
        -- 依次对应于 0、1、2、3、4
        local realKey = string.format(key .. "_%d", realDir - 2)
        return tonumber(info[realKey])
    end

    -- 只有两个方向的资源，分别为 3、5，依次对应于 0、1
    if realDir == 5 and info[key .. "_1"] then
        return tonumber(info[key .. "_1"])
    end

    if info[key .. "_0"] then
        return tonumber(info[key .. "_0"])
    end

    if info[key] then
        return tonumber(info[key])
    end

    return 0
end

-- 获取配置信息
function CharAction:getCfgInt(key, act, useCharCartoonInfo, dontChangeAct)
    if self.cartoonInfo == nil then
        self:readCartoonInfo()
    end

    act = act or self.action

    local cartoonInfo = self.cartoonInfo
    if useCharCartoonInfo then
        -- 需要使用角色动画配置信息，不管有无骑宠
        cartoonInfo = self.charCartoonInfo
    end

    return self:getCfgIntByInfo(key, act, dontChangeAct, cartoonInfo)
end

-- 获取实际方向
function CharAction:getRealDirection()
    local dir = self.direction
    local action = self.action
    local flip = false
    if nil == dir or action == nil then return 5 end

    if action == Const.SA_STAND or action == Const.FA_WALK then
        if dir == 1 then dir = 3 flip = true
        elseif dir <= 0 then dir = 4 flip = true
        elseif dir >= 7 then dir = 5 flip = true
        end
    else
        if dir <= 0 or dir == 1 then dir = 3 flip = true
        elseif dir == 2 then dir = 3
        elseif dir == 4 then dir = 5
        elseif dir == 6 or dir >= 7 then dir = 5 flip = true
        end
    end
    return dir, flip
end

-- 根据方向获取左右基准点范围
function CharAction:getDirPointRange()
    local points, flip = self:getBasicPointRange()

    if not points then return end

    -- 如果翻转x要做对称
    if flip then
        local realPonits = {}
        for i = 1, #points do
            local point = {}
            point.x = 0 - points[i].x
            point.y =  points[i].y
            table.insert(realPonits, point)
        end

        return realPonits
    else
        return points
    end
end

function CharAction:isCustomDressPlayAttack2()
    if self.action ~= Const.SA_ATTACK then
        return
    end

    if string.isNilOrEmpty(self.partIndex) then
        return
    end

    local len = #self.partIndex
    assert(20 == len or 16 == len, "part string must be equal to 20 or 16")

    local weaponIndex = tonumber(string.sub(self.partIndex, 1, 2))
    if weaponIndex == 1 or weaponIndex == 4 or weaponIndex == 5 or weaponIndex == 6 then
        -- 当前只有武器编号为1,4,5,6的武器可能有attack2动作
        if self.cartoonInfo[gf:getActionStr(Const.SA_ATTACK2)] then
            return true
        end
    end
end

-- 有些模型的动作会复用别的动作，例如 walk 动作可能复用 stand 动作
-- 本接口用于获取真正要加载的资源对应的动作
function CharAction:getRealAction(typeTag)
    local reuseAction = ACTION_REUSE_MAP[self.action]
    if reuseAction then
        -- 该动作有可能复用别的动作，检测本模型是否存在该动作，如果不存在，则使用 reuseAction 对应的动作
        local useCharInfo = (typeTag == TAG_CHAR or typeTag == TAG_WEAPON
                            or (typeTag >= TAG_CHAR_START and typeTag <= TAG_CHAR_MAX)
                            or (typeTag >= TAG_CHAR_PART_BEGIN and typeTag <= TAG_CHAR_PART_MAX))
        if self:getCfgInt("centre_x", self.action, useCharInfo, true) == 0 then
            -- 无 self.action 动作，复用 reuseAction 对应的动作
            return reuseAction
        end
    end

    if self:isCustomDressPlayAttack2() then
        -- 部分自定义时装播放attack时，需要改为播放attack2
        return Const.SA_ATTACK2
    end

    return self.action
end

-- 清除基准点范围缓存
function CharAction:clearBasicPointRange()
    self['dirBasicPointRange0'] = nil
    self['dirBasicPointRange1'] = nil
    self['dirBasicPointRange2'] = nil
    self['dirBasicPointRange3'] = nil
    self['dirBasicPointRange4'] = nil
    self['dirBasicPointRange5'] = nil
    self['dirBasicPointRange6'] = nil
    self['dirBasicPointRange7'] = nil
end

function CharAction:calcBasicPoints(points, lX, lY, rX, rY, x, y)
     if rX == 0 and rY  == 0 and lX == 0 and  lY == 0 then return  end

    if math.abs(lY - rY) < math.abs(lX - rX) then
        -- 左右基准点斜率
        local k = (lY - rY) / (lX - rX)
        local rangeX1 = (lX - x) / Const.PANE_WIDTH
        local rangeX2 = (rX - x) / Const.PANE_WIDTH

        local b = ((rY - y) - k * (rX - x)) /  Const.PANE_WIDTH

        local step = rangeX1 < rangeX2 and 1 or -1
        for i = rangeX1, rangeX2, step do
            local point = {}
            point.x = self:getNearValue(i)
            point.y = self:getNearValue(k * i + b)
            table.insert(points, point)
        end
    else
        local k = (lX - rX) / (lY - rY)
        local rangeY1 = (lY - y) / Const.PANE_HEIGHT
        local rangeY2 = (rY - y) / Const.PANE_HEIGHT

        local b = ((rX - x) - k * (rY - y)) /  Const.PANE_HEIGHT

        local step = rangeY1 < rangeY2 and 1 or -1
        for i = rangeY1, rangeY2, step do
            local point = {}
            point.y = self:getNearValue(i)
            point.x = self:getNearValue(k * i + b)
            table.insert(points, point)
        end
    end
end

-- 获取基准点的范围
function CharAction:getBasicPointRange()
    local dir, flip= self:getRealDirection()
    local key = "dirBasicPointRange"..dir
    if self[key] then return self[key], flip end

    local scale = self:getCharScale()
    local act = self:getRealAction(TAG_RIDE_BOTTOM)

    local rX = self:getCfgInt('right_x', act) * scale
    local rY = self:getCfgInt('right_y', act) * scale
    local lX = self:getCfgInt('left_x', act) * scale
    local lY = self:getCfgInt('left_y', act) * scale
    local tX = self:getCfgInt('top_x', act) * scale
    local tY = self:getCfgInt('top_y', act) * scale
    local bX = self:getCfgInt('bottom_x', act) * scale
    local bY = self:getCfgInt('bottom_y', act) * scale
    if rX == 0 and rY  == 0 and lX == 0 and  lY == 0 and tX == 0 and tY == 0 and bX == 0 and bY == 0 then return  end

    local x = self:getCfgInt('centre_x', act) * scale
    local y = self:getCfgInt('centre_y', act) * scale
    local points = {}
    self:calcBasicPoints(points, lX, lY, rX, rY, x, y)
    self:calcBasicPoints(points, tX, tY, bX, bY, x, y)

    local shelterInfo = self.petRideInfo["shelter_offset" .. dir]
    if shelterInfo then
        -- 存在遮挡偏移信息，计算相应的偏移点
        local pts = points
        points = {}
        for i = 1, #pts do
            table.insert(points, pts[i])
            table.insert(points, {x = pts[i].x + shelterInfo.x, y = pts[i].y + shelterInfo.y})
            table.insert(points, {x = pts[i].x - shelterInfo.x, y = pts[i].y - shelterInfo.y})
        end
    end

    self[key] = points

    return points, flip
end

-- 四舍五入
function CharAction:getNearValue(value)
    local lastValue = value
    if value < 0 then
        lastValue = math.ceil(value - 0.5)
    else
        lastValue = math.floor(value + 0.5)
    end

    return lastValue
end

-- 获取基准点
function CharAction:getBasicPoint(tag)
    -- 角色和武器的基准点统一取角色动画配置中配置的基准点信息
    local useCharCartoonInfo = (tag == TAG_CHAR or tag == TAG_WEAPON)
    local x, y
    if tag >= TAG_CHAR_START and tag <= TAG_CHAR_MAX then
        local iKey = string.format("icon%d", tag - TAG_CHAR_START + 1)
        local icon = self[iKey]
        local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
        x = self:getCfgIntByInfo('centre_x', self.action, nil, cartoonInfo)
        y = self:getCfgIntByInfo('centre_y', self.action, nil, cartoonInfo)
    elseif tag == TAG_CHAR_SHADOW then
        local icon = self.shadowIcon
        local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
        x = self:getCfgIntByInfo('centre_x', self.action, nil, cartoonInfo)
        y = self:getCfgIntByInfo('centre_y', self.action, nil, cartoonInfo)
    else
        x = self:getCfgInt('centre_x', self.action, useCharCartoonInfo)
        y = self:getCfgInt('centre_y', self.action, useCharCartoonInfo)
    end
    local scale = 1

    if TAG_WEAPON == tag then
        scale = self:getWeaponScale(self.weaponIcon)
    elseif TAG_CHAR_SHADOW == tag then
        --scale = self:getShadowScale()
    else
        scale = self:getCharScale()
    end

    return cc.p(x * scale, y * scale)
end

-- 获取缩放
function CharAction:getCharScale()
    local scale = self:getCfgInt('scale', self.action)
    return scale > 0 and scale / 100 or 1
end

-- 获取武器缩放
function CharAction:getWeaponScale(weaponIcon)
    local scale = 0
    if weaponIcon then
        scale = self:getCfgInt(string.format('%s_scale', tostring(weaponIcon)), self.action)
    end

    return scale > 0 and scale / 100 or 1
end

function CharAction:getShadowScale()
    local icon = self.shadowIcon
    local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
    local scale = self:getCfgIntByInfo("scale", self.action, nil, cartoonInfo)
    return scale > 0 and scale / 100 or 1
end

-- 获取腰基准点与脚基准点的偏移(取的是 stand 动作中的信息)
function CharAction:getWaistOffset()
    local fx = self:getCfgInt('centre_x', Const.SA_STAND, true)
    local fy = self:getCfgInt('centre_y', Const.SA_STAND, true)
    local wx = self:getCfgInt('waist_x', Const.SA_STAND, true)
    local wy = self:getCfgInt('waist_y', Const.SA_STAND, true)
    local scale = self:getScale()
    local _, flip = self:getRealDirection()
    local offX, offY = self:getRideOffset()
    local offHeadX, offHeadY = PetMgr:getRideWaistOffset(self.icon, self.rideIcon, self.direction, self:getRealAction(TAG_RIDE_BOTTOM))
    offX = offX + offHeadX
    offY = offY + offHeadY
    if flip then
        return (fx - wx + offX) * scale, (fy - wy + offY) * scale
    else
        return (wx - fx + offX) * scale, (fy - wy + offY) * scale
    end
end

-- 获取头基准点与脚基准点的偏移(取的是 stand 动作中的信息)
function CharAction:getHeadOffset()
    local fx = self:getCfgInt('centre_x', Const.SA_STAND, true)
    local fy = self:getCfgInt('centre_y', Const.SA_STAND, true)
    local hx = self:getCfgInt('head_x', Const.SA_STAND, true)
    local hy = self:getCfgInt('head_y', Const.SA_STAND, true)
    local scale = self:getScale()
    local _, flip = self:getRealDirection()
    local offX, offY = self:getRideOffset()
    local offHeadX, offHeadY = PetMgr:getRideHeadOffset(self.icon, self.rideIcon, self.direction, self:getRealAction(TAG_RIDE_BOTTOM))
    offX = offX + offHeadX
    offY = offY + offHeadY
    if flip then
        return (fx - hx + offX) * scale, (fy - hy + offY) * scale
    else
        return (hx - fx + offX) * scale, (fy - hy + offY) * scale
    end
end

-- 获取帧间隔
function CharAction:getInterval()
    repeat
        if self.cartoonInfo == nil then break end

        -- 如果有骑宠则需要以骑宠动作的播放时间为准
        local action = gf:getActionStr(self:getRealAction(TAG_RIDE_BOTTOM))
        if action == nil then break end

        local info = self.cartoonInfo[action]
        if info == nil then break end

        local interval = (tonumber(info["rate"]) or 100) / 1000
        local rate = 1
        if action == "attack" or action == "attack2" then
            rate = 0.7
        elseif action == "defense" or action == "parry" or action == "die" then
            rate = 0.4
        end

        return interval * rate
    until true

    return 0.1
end

function CharAction:setCharOpacity(opacity)
    local children = self:getChildren()
    self.charOpacity = opacity
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setOpacity(opacity)
        end
    end
end

-- 设置遮挡
function CharAction:setShelter(shelter)
    local opacity = shelter and 0x7f or self.charOpacity
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setOpacity(opacity)
        end
    end
end

-- 判断指定的动作是否存在
function CharAction:haveAct(saAct)
    if not saAct then
        return false;
    end

    if self.cartoonInfo == nil then
        self:readCartoonInfo()
    end

    local action = gf:getActionStr(saAct)
    if not action then
        return false
    end

    if self.cartoonInfo[action] then
        return true
    else

        -- 有可能该动作复用其他地方
        if AnimationMgr:isReplaceAction(self.icon, action) then
            return true
        end
    end

    return false
end

function CharAction:getHeadPos()
    if self.char == nil then return end
    local size = self.char.contentSize
    local anchor = self.char.anchorPoint
    local x, y = self:getHeadOffset()
    return x + anchor.x * size.width, y + anchor.y * size.height
end

function CharAction:setGray(gray)
    local shader = gray and ShaderMgr:getGrayShader() or ShaderMgr:getRawShader()

    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:setGLProgramState(shader)
        end
    end
end

function CharAction:setPartToBeRemoved(tag)
    if not self.toBeRemoveParts then
        self.toBeRemoveParts = {}
    end

    self.toBeRemoveParts[tag] = 1
end

function CharAction:isToBeRemove(tag)
    return self.toBeRemoveParts and self.toBeRemoveParts[tag]
end

-- 设置所有的部件为加载状态
function CharAction:setAllAniToLoad()
    self.partAniStatus = {}

    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            self.partAniStatus[v:getType()] = STATUS_TO_LOAD
        end
    end
end

-- 设置动画正在加载
function CharAction:setPartAniToLoad(partType)
    self.partAniStatus[partType] = STATUS_TO_LOAD
end

function CharAction:setPartAniLoadedDelay(partType)
    --performWithDelay(self, function() self:setPartAniLoaded(partType) end, 0)
end

function CharAction:isAllPartLoaded()
    local isLoaded = true
    for k, v in pairs(self.partAniStatus) do
        if STATUS_TO_LOAD == v then
            isLoaded = false
            break
        end
    end

    return isLoaded
end

function CharAction:setPartAniLoaded(partType)
    if self.partAniStatus[partType] then
        self.partAniStatus[partType] = STATUS_LOADED
    end

    -- 判断是否全部加载完成
    local isLoaded = self:isAllPartLoaded()

    if isLoaded then
        -- 都加载完了
        self:removeUnUsedPart() -- 移除不需要的部件
        if 'function' == type(self.refreshColorIndex) then
            self.refreshColorIndex()
        end
        self:playAnimation()
        self:setVisible(true)

        if "function" == type(self.loadComplateCallBack) then
            -- 加载后的回调
            performWithDelay(self, function()
                -- 延时一帧，等待环境准备完成，比如self.charAction被正确赋值
                if "function" == type(self.loadComplateCallBack) then
                    self.loadComplateCallBack()
                end
            end, 0)
        end
    end
end

-- 开始播放动画
function CharAction:playAnimation()
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:playAnimation()
        end
    end

    self:resetArea()

    self.isPausePlay = false
end

-- 清理(此处只清理 lua 的数据，不能重写 cc.Node.cleanup 接口)
function CharAction:clear()
    self.sendDebugLog = nil
    self:cleanUnPlayAnimation()
end

-- 清除未播放的动画
function CharAction:cleanUnPlayAnimation()
    local children = self:getChildren()
    for _, v in pairs(children) do
        if self:isCharPart(v) then
            v:clear()
        end
    end
end

-- 是否CharPart
function CharAction:isCharPart(v)
    if self.curIsTestDist then
        if v and not v.setInterval then
            local m = {}
            table.insert(m, "----->invalid charpart:")
            table.insert(m, "type:" .. type(v))
            table.insert(m, "name:" .. tostring(v:getName()))
            table.insert(m, "cname:" .. tostring(v.__cname))
            table.insert(m, gfTraceback())
            gf:ftpUploadEx(table.concat(m, '\n'))
        end
    end
    return v and 'CharPart' == v.__cname and not self:isToBeRemove(v:getTag()) -- and (not self.toBeRemoveParts or not self.toBeRemoveParts[v:getTag()])
end

function CharAction:setLoadType(loadType)
    self.loadType = loadType
end

function CharAction:getLoadType()
    return self.loadType or LOAD_TYPE.CHAR
end

return CharAction
