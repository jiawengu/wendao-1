-- Magic.lua
-- created by cheny Nov/17/2014
-- 光效动画

local TAG_MAGIC_ACTION = 100

-- 非地图动画会存放在 magic 目录或者 magic_n 目录
-- 如果 magic_n 目录启用了，则优先使用该目录下的动画
local CartoonInfo = require "magic/Cartoon.lua" or {}
local CartoonNewInfo = require "magic_n/Cartoon.lua" or {}
local MapCartoonInfo = require "maps/magic/Cartoon" or {}

-- 获取普通光效的配置信息
local function getNormalMagicInfo(icon)
    local info
    if ResMgr:useMagicNRes(icon) then
        -- 优先使用  magic_n
        info = CartoonNewInfo[string.format("%05d", icon)]
    end

    return info or CartoonInfo[string.format("%05d", icon)]
end

local function getInterval(icon, magicType)
    local info = {}
    if MAGIC_TYPE.NORMAL == magicType then
        info = getNormalMagicInfo(icon)
    elseif MAGIC_TYPE.MAP == magicType then
        info = MapCartoonInfo[string.format("%05d", icon)]
    end

    if nil == info then return 0.1 end
    return (tonumber(info["rate"]) or 100) / 1000
end

local function getBasicPoint(icon, magicType)
    local info = {}
    if MAGIC_TYPE.NORMAL == magicType then
        info = getNormalMagicInfo(icon)
    elseif MAGIC_TYPE.MAP == magicType then
        info = MapCartoonInfo[string.format("%05d", icon)]
    end

    if info == nil then return cc.p(0,0) end
    local x = info["centre_x"] or 0
    local y = info["centre_y"] or 0
    local scale = info["scale"] or 100
    return cc.p(x * scale / 100, y * scale / 100)
end

local Magic = class("Magic", function()
    return cc.Sprite:create()
end)

-- callbackOrRemoveSelf：
--      如果设置为函数，则播放完成后回调该函数
--      如果设置为 true，则播放完成后自动删除该动画
--      其他情况则表示要循环播放
-- extraPara = {
--     rotation         已锚点为中心旋转的角度
--     rotationX        绕 X 轴旋转的角度
--     rotationY        绕 Y 轴旋转的角度
--     scaleX           X 方向上缩放比例
--     scaleY           Y 方向上缩放比例
--     alpha            设置透明度
--     frameInterval    设置帧间隔，单位毫秒
--     loopInterval     设置循环间隔，单位毫秒
--     notShowDuringDelay    true时表示在循环间隔期间，隐藏动画
--     skipTime         希望从中间开始播时指定跳过的时间，单位毫秒
--     blendMode        颜色混合方式，目前支持 normal 和 add 两种方式
--                      normal: src_color * alpha + des_color * (1 - alpha)
--                      add:    src_color + des_color
-- }
function Magic:ctor(icon, callbackOrRemoveSelf, magicType, extraPara)
    --if icon ~= 1021 or icon ~= 2020 then icon = 1021 end    ---- cyq just for debug
    self.icon = icon or 0

    if nil == magicType then
        self.magicType = MAGIC_TYPE.NORMAL
    else
        self.magicType = magicType
    end

    local crType = type(callbackOrRemoveSelf)
    if crType == 'function' then
        self.callback = callbackOrRemoveSelf
    elseif crType == 'boolean' then
        self.removeSelf = callbackOrRemoveSelf
    end

	-- 设置缩放信息
	self:setScaleByIcon(icon)

    -- 保存额外参数信息，并进行相应的设置
    self.extraPara = extraPara
    self:processSomeExtraPara(extraPara)

    self:updateNow()
end

-- 处理 extraPara 中的如下数据
--     rotation     以锚点为中心旋转的角度
--     rotationX    绕 X 轴旋转的角度
--     rotationY    绕 Y 轴旋转的角度
--     scaleX       X 方向上缩放比例
--     scaleY       Y 方向上缩放比例
--     alpha        设置透明度
function Magic:processSomeExtraPara(extraPara)
    if not extraPara then
        return
    end

    if extraPara.rotation then
        self:setRotation(extraPara.rotation)
    end

    if extraPara.rotationX then
        self:setRotationSkewX(extraPara.rotationX)
    end

    if extraPara.rotationY then
        self:setRotationSkewY(extraPara.rotationY)
    end

    if extraPara.scaleX then
        self:setScaleX(extraPara.scaleX)
    end

    if extraPara.scaleY then
        self:setScaleY(extraPara.scaleY)
    end

    self:setAlpha(extraPara.alpha)
end

-- 设置透明度
function Magic:setAlpha(alpha)
    if alpha then
        self:setCascadeOpacityEnabled(true)

        if alpha > 255 then
            alpha = 255
        elseif alpha < 0 then
            alpha = 0
        end

        self:setOpacity(alpha)
    end
end

-- 设置该 icon 对应的缩放信息
function Magic:setScaleByIcon(icon)
	local scale
    local iconName = string.format("%05d", icon)
	if self.magicType == MAGIC_TYPE.MAP then
		scale = MapCartoonInfo[iconName] and MapCartoonInfo[iconName].scale
	else
        local info = getNormalMagicInfo(icon)
        scale = info and info.scale
	end

    if scale then
        self.scale = scale
        local scale = 100 / self.scale
        self:setScaleX(scale)
        self:setScaleY(scale)
	else
        self.scale = nil
        self:setScaleX(1)
        self:setScaleY(1)
    end
end

-- 设置编号
function Magic:setIcon(icon)
    if self.icon == icon then return end

	-- 设置缩放信息
	self:setScaleByIcon(icon)

    self.icon = icon
    self:updateNow()
end

-- 立即更新
function Magic:updateNow()
    if self.icon == nil or self.icon == 0 then
        if self.callback then
            self.callback(self)
        end

        return
    end

    local updateNowEx = function(animation)
        if not animation then
            if self.callback then
                self.callback(self)
            end

            local tip = string.format(CHS[2100109], tostring(self.icon))
            gf:ShowSmallTips(tip)
            Log:F(tip)
            return
        end

        local frame = animation:getSpriteFrame(0)
        if nil == frame then
            return
        end

        if "function" ~= type(self.updateAnchorPoint) then
            -- 这种情况，可能对象已经丢失
            return
        end

        self:updateAnchorPoint(frame)

        local interval = getInterval(self.icon, self.magicType)
        if self.extraPara and self.extraPara.frameInterval then
            -- 优先使用 extraPara 中的帧间隔
            interval = self.extraPara.frameInterval / 1000
        end

        -- 如果在战斗中则需要除以战斗加速倍数
        interval = FightMgr:divideSpeedFactorIfInCombat(interval)
        animation:setDelayPerUnit(interval)

        -- 创建动作
        local animate = cc.Animate:create(animation)
        local action
        if self.callback then
            action = cc.Sequence:create(animate, cc.CallFunc:create(self.callback, {icon=self.icon}))
        elseif self.removeSelf then
            action = cc.Sequence:create(animate, cc.RemoveSelf:create())
        else
            if self.extraPara and self.extraPara.loopInterval then
                -- 设置循环间隔
                 if self.extraPara.notShowDuringDelay then
                    action = cc.Sequence:create(
                        cc.CallFunc:create(function() self:setVisible(false) end),
                        cc.DelayTime:create(self.extraPara.loopInterval / 1000),
                        cc.CallFunc:create(function() self:setVisible(true) end),
                        animate
                    )
                 else
                    action = cc.Sequence:create(animate, cc.DelayTime:create(self.extraPara.loopInterval / 1000))
                 end
            else
                action = animate
            end

            action = cc.RepeatForever:create(action)
        end

        self.action = action
        self:stopActionByTag(TAG_MAGIC_ACTION)
        action:setTag(TAG_MAGIC_ACTION)
        self:runAction(action)

        if self.extraPara and self.extraPara.blendMode and not self.extraPara.skipTime then
            self.extraPara.skipTime = 0
        end

        -- 希望从中间开始播时指定跳过的时间
        if self.extraPara and self.extraPara.skipTime then
            -- 第一次会被忽略，所以要调两次 step
            action:step(0)
            action:step(self.extraPara.skipTime / 1000)
        end

        if self.extraPara and self.extraPara.blendMode then
            if self.extraPara.blendMode == 'add' then
                self:setBlendFunc(gl.ONE, gl.ONE)
            end
        end

        -- 设置透明度
        if self.extraPara and self.extraPara.alpha then
            self:setAlpha(self.extraPara.alpha)
        end
    end

    -- 创建帧动画

    if MAGIC_TYPE.MAP == self.magicType then
        -- 异步加载(地图光效)
        AnimationMgr:syncGetMagicAnimation(self.icon, self.magicType, updateNowEx)
    else
        local animation = AnimationMgr:getMagicAnimation(self.icon, self.magicType, self.scale)
        updateNowEx(animation)
    end
end

-- 根据基准点信息，更新锚点信息
function Magic:updateAnchorPoint(frame)
    if frame == nil then return end
    local basicPoint = getBasicPoint(self.icon, self.magicType)
    local size = frame:getOriginalSize()
    self:setAnchorPoint(basicPoint.x/size.width, 1 - basicPoint.y/size.height)

    if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
        local pt = cc.LayerColor:create(cc.c4b(255,0,0,255))
        pt:setContentSize(2,2)
        pt:setPosition(basicPoint.x, size.height - basicPoint.y)
        self:addChild(pt)
    end
end

-- 暂停播放
function Magic:pausePlay()
    --self:stopAllActions()
    self:pause()
end

-- 继续播放
function Magic:continuePlay()
    self:resume()
end

return Magic
