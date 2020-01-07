-- PlayActionsMgr.lua
-- Created by zhengjh Jun/22/2016
-- 播放一些动作集合管理器

PlayActionsMgr = Singleton()

-- distanceX 是以垂直方向左右便宜的度数

local UI_ORDER =
{
    ANIMATION_LOCATION_ABOVE_SCREEN =  0,  -- UI上层
    ANIMATION_LOCATION_BELOW_SCREEN =  1,  -- UI下层
}

local CHAR_LAYER_ORDER = {
    TOP = 0,     -- 角色上层
    BOTTOM = 1,  --  角色下层
    MIDDLE = 2,  -- 角色中间层
}

local ANIMATION_TYPE =
{
    ANIMATION_IN_CHAR  = 1,  -- 角色
    ANIMATION_IN_MAP   = 2,  -- 在地图上
    ANIMATION_IN_UI    = 3,  -- UI上
}

-- 粒子效果
local actions_config =
{   -- 花瓣
   [08262] = {
        ["objCount"] = 3,
            ["obj1"] = {icon = ResMgr.magic.full_screen_flower1, degree = {0, 360}, scale = {40, 110}, distanceY = {100, 300}, distanceX = 15, zoder = 3, number = {2, 3}, time = 1.3, interval = 0.1, repeatTimes = 11},
            ["obj2"] = {icon = ResMgr.magic.full_screen_flower2, degree = {0, 360}, scale = {40, 110}, distanceY = {100, 300}, distanceX = 15, zoder = 2, number = {3, 5}, time = 1.3, interval = 0.1, repeatTimes = 11},
            ["obj3"] = {icon = ResMgr.magic.full_screen_flower3, degree = {0, 360}, scale = {40, 100}, distanceY = {100, 300}, distanceX = 15, zoder = 1, number = {6, 9}, time = 1.3, interval = 0.1, repeatTimes = 11},
    },
    [01471] = {
        ["objCount"] = 3,
            ["obj1"] = {icon = ResMgr.magic.wenq_full_screen_flower1, degree = {0, 360}, scale = {40, 110}, distanceY = {100, 300}, distanceX = 15, zoder = 3, number = {2, 3}, time = 1.3, interval = 0.1, repeatTimes = 22},
            ["obj2"] = {icon = ResMgr.magic.wenq_full_screen_flower2, degree = {0, 360}, scale = {40, 110}, distanceY = {100, 300}, distanceX = 15, zoder = 2, number = {3, 5}, time = 1.3, interval = 0.1, repeatTimes = 22},
            ["obj3"] = {icon = ResMgr.magic.wenq_full_screen_flower3, degree = {0, 360}, scale = {40, 100}, distanceY = {100, 300}, distanceX = 15, zoder = 1, number = {6, 9}, time = 1.3, interval = 0.1, repeatTimes = 22},
    },
}

-- func icon光效 对应 要执行的函数，单词播放完，要有回调通知
local EFFECT_INFO =
{
    [01471] = {func = "playFollowingflower"},
    [08262] = {func = "playFollowingflower"},
    [06067] = {func = "playEffectAction"},
    [08263] = {func = "playArmatureaction"},
    [08265] = {func = "playArmatureaction"},
    [08264] = {func = "playArmatureaction"},
    [08278] = {func = "playArmatureaction"},
    [08280] = {func = "playArmatureaction"},
    [08279] = {func = "playArmatureaction"},
    [08281] = {func = "playArmatureaction"},
    [08267] = {func = "playArmatureaction"},
    [01361] = {func = "playArmatureaction", type = "yanhua", callback = "onPlayYanhua", limitFunc = "onPlayYanhuaLimit", sound = "yanhua", removeInCombat = true},
    [01362] = {func = "playArmatureaction", type = "yanhua", callback = "onPlayYanhua", limitFunc = "onPlayYanhuaLimit", sound = "yanhua", removeInCombat = true},
    [01363] = {func = "playArmatureaction", type = "yanhua", callback = "onPlayYanhua", limitFunc = "onPlayYanhuaLimit", sound = "yanhua", removeInCombat = true},
    [01289] = {func = "playArmatureaction"},
    [02036] = {func = "playArmatureaction", type = "lihua",  callback = "onPlayLihua",  limitFunc = "onPlayLihuaLimit",  sound = "yanhua", soundTimes = 2, removeInCombat = true},
}

local curPlayYanhuaNum = 0

local armatureaction_config =
{
    [08263] = {actionName = "action08263", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08265] = {actionName = "action08265", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08264] = {actionName = "action08264", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08278] = {actionName = "action08278", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08280] = {actionName = "action08280", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08279] = {actionName = "action08279", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08281] = {actionName = "action08281", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [08267] = {actionName = "action08267", jsonName = ResMgr.ArmatureMagic.marry_action.name},
    [01361] = {actionName = "Top", jsonName = ResMgr.ArmatureMagic.yanhua_ssfh.name, magicType = "map", scale = 1.4},
    [01362] = {actionName = "Top", jsonName = ResMgr.ArmatureMagic.yanhua_mtxy.name, magicType = "map", scale = 1.4},
    [01363] = {actionName = "Top", jsonName = ResMgr.ArmatureMagic.yanhua_xlcy.name, magicType = "map", scale = 1.4},
    [01289] = {actionName = "Bottom06", jsonName = ResMgr.ArmatureMagic.yanhua_succ.name},   -- 成功结拜或结成固定队播放
    [02036] = {actionName = "Top01", jsonName = ResMgr.ArmatureMagic.lihua_whzm.name},
}

local CHAR_EFFECT_POS =
{
    head = 0,
    waist = 1,
    foot = 2,
}

PlayActionsMgr.animates = {}

local uniqueId = 0

-- 粒子效果 如 （满屏花瓣）
function PlayActionsMgr:playFollowingflower(layer, key, fuc)
    local info = actions_config[key]
    local totalCount = 0
    local playCount = 0

    local function callBack()
        playCount = playCount + 1
        if playCount >= totalCount then
            fuc()
            return
        end
    end

    for i = 1, info["objCount"] do
        local obj = info["obj" .. i]
        local layout = ccui.Layout:create()
        layout:setContentSize(Const.WINSIZE.width, Const.WINSIZE.height)
        layout:setLocalZOrder(obj.zoder)

        local repeatTimes = 0
        local function createActions()
            if repeatTimes > obj.repeatTimes then layout:stopAllActions() return end
            repeatTimes = repeatTimes + 1
            -- 随机个数
            local num = math.random(obj.number[1], obj.number[2])
            for j = 1, num do
                local function callFunc (node)
                    node:removeFromParent(true)
                    callBack()
                end

                local image = gf:createCallbackMagic(obj.icon, callFunc)
                totalCount = totalCount + 1

                -- 初值角度
                local degree = math.random(obj.degree[1], obj.degree[2])
                image:setRotation(degree)

                -- 缩放系数
                local scale = math.random(obj.scale[1], obj.scale[2])
                image:setScale(scale / 100)

                -- 出现位置
                local ranx = math.floor(Const.WINSIZE.width / 5)
                local rany = math.floor(Const.WINSIZE.height / 5)
                local x = math.random(0, ranx) * 5
                local y = math.random(0, rany) * 5
                image:setPosition(x, y)

                -- 结束位置
                local rany = math.random(obj.distanceY[1], obj.distanceY[2])
                local endY = y - rany
                local offsetX = math.tan(math.rad(obj.distanceX)) * rany
                local randx = x - offsetX

                if ranx < 0 then
                    randx = 0
                end

                local endX = math.random(randx, x + offsetX)

                local moveTo = cc.MoveTo:create(obj.time, cc.p(endX, endY))
                image:runAction(moveTo)
                layout:addChild(image)
            end
        end

        schedule(layout, createActions, obj.interval)

        layer:addChild(layout)
    end
end

-- 创建普通光效
function PlayActionsMgr:playEffectAction(layer, icon, callBack)
    local function callFunc (node)
        node:removeFromParent(true)
        callBack()
    end

    local image = gf:createCallbackMagic(icon, callFunc)
    layer:addChild(image)
    layer:setContentSize(image:getContentSize())
end

-- 创建配置编辑的动画
function PlayActionsMgr:playArmatureaction(layer, key, callBack)
    local actionInfo = armatureaction_config[key]
    local ui
    if actionInfo["magicType"] == "map" then
        ui = ArmatureMgr:createMapArmature(actionInfo["jsonName"])
    else
        ui = ArmatureMgr:createArmature(actionInfo["jsonName"])
    end

    local function func(sender, type, id)
        if type == ccs.MovementEventType.complete then
            ui:stopAllActions()
            callBack()
        end
    end

    layer:addChild(ui)
    ui:setScale(actionInfo.scale or 1)
    ui:getAnimation():play(actionInfo["actionName"])
    ui:getAnimation():setMovementEventCallFunc(func)
end


function PlayActionsMgr:playSound(layer, key, times)
    local times = times or 1
    local len = SoundMgr:getSoundLength(SoundMgr:getSoundByKey(key)) / 1000
    local function callBack()
        SoundMgr:playEffect(key, nil, function(soundId)
            layer.soundId = soundId
        end)

        times = times - 1
        if times <= 0 then return end
        performWithDelay(layer, callBack, len)
    end

    callBack()
end

-- times 播放次数 0 表示循环播放
-- interval 每次播放的间隔
function PlayActionsMgr:playActionByTimes(layer, key, times, interval)
    local playTimes = 0
    if not EFFECT_INFO[key] then return end
    local funcName = EFFECT_INFO[key].func
    local cbName = EFFECT_INFO[key].callback
    local sound = EFFECT_INFO[key].sound

    local function callBack()
        performWithDelay(layer, function ()
            playTimes = playTimes + 1
            if times ~= 0 and playTimes >= times then
                self:deleteOneAction(layer)
                return
            end

            self[funcName](self, layer, key, callBack)
            if sound then self:playSound(layer, sound, EFFECT_INFO[key]["soundTimes"]) end
        end, interval or 0)
    end

    if self[cbName] then self[cbName](self, "add") end
    self[funcName](self, layer, key, callBack)
    if sound then self:playSound(layer, sound, EFFECT_INFO[key]["soundTimes"]) end
end

-- 持续播放多长时间
function PlayActionsMgr:playActionContinuTime(layer, key, continuTime)
    local lastTime = gf:getServerTime()
    local function callBack()
        if gf:getServerTime() - lastTime > continuTime then
            self:deleteOneAction(layer)
        end
    end

    self:playActionByTimes(layer, key, 0, 0) -- 循环持续播放

    schedule(layer, callBack, 0.3)
end

function PlayActionsMgr:playBanner(data)
    local node = ccui.Layout:create()
    node:setContentSize(Const.WINSIZE)
    local image = ccui.ImageView:create(ResMgr.ui.banner_image)
    image:setPosition(Const.WINSIZE.width / 2, Const.WINSIZE.height * 3 / 4)
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(23)
    lableText:setString(data.content or "")
    lableText:setContentSize(image:getContentSize().width, 0)
    lableText:updateNow()
    local labelW, labelH = lableText:getRealSize()
    local layerColor = tolua.cast(lableText, "cc.LayerColor")
    image:addChild(layerColor)

    local pos = cc.p((image:getContentSize().width - labelW) * 0.5, (image:getContentSize().height + labelH) * 0.5)
    layerColor:setPosition(pos)

    local fuc = cc.CallFunc:create(function() node:stopAllActions() node:removeFromParent(true) end)
    local action = cc.Sequence:create(cc.DelayTime:create(data.time or 3), fuc)

    node:addChild(image)
    node:runAction(action)
    gf:getUILayer():addChild(node)
end

--  在ui层播放光效
function PlayActionsMgr:MSG_ANIMATE_IN_UI(data)
    local info = EFFECT_INFO[data.effect_no]
    if not info then return end
    if info.limitFunc and not self[info.limitFunc](self, data) then
        return
    end

    local uiLayout = ccui.Layout:create()
    if data.locate == LOCATE_POSITION.MID then
        uiLayout:setPosition(Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2)
    end

    uiLayout:setContentSize(gf:getUILayer():getContentSize())
    gf:getUILayer():addChild(uiLayout)

    if data.order == UI_ORDER.ANIMATION_LOCATION_BELOW_SCREEN then
        uiLayout:setLocalZOrder(-1)
    else
        uiLayout:setLocalZOrder(1)
    end

    self:doPlayAction(uiLayout, data)
end

-- 在地图层播放光效
function PlayActionsMgr:MSG_ANIMATE_IN_MAP(data)
    local mapLayout = ccui.Layout:create()

    local x, y = gf:convertToClientSpace(data.x, data.y)
    mapLayout:setPosition(x, y)
    local mapEffectLayer = gf:getMapEffectLayer()
    mapEffectLayer:addChild(mapLayout)

    self:doPlayAction(mapLayout, data)
end

-- 烟花创建、移除的回调函数
function PlayActionsMgr:onPlayYanhua(event)
    if not self.playActionsNum["yanhua"] then self.playActionsNum["yanhua"] = 0 end
    if event == "add" then
        self.playActionsNum["yanhua"] = self.playActionsNum["yanhua"] + 1
    elseif event == "remove" then
        self.playActionsNum["yanhua"] = self.playActionsNum["yanhua"] - 1
    end

    return true
end

-- 礼花创建、移除的回调函数
function PlayActionsMgr:onPlayLihua(event)
    if not self.playActionsNum["lihua"] then self.playActionsNum["lihua"] = 0 end
    if event == "add" then
        self.playActionsNum["lihua"] = self.playActionsNum["lihua"] + 1
    elseif event == "remove" then
        self.playActionsNum["lihua"] = self.playActionsNum["lihua"] - 1
    end

    return true
end

-- 烟花限制播放的函数
function PlayActionsMgr:onPlayYanhuaLimit(data)
    if Me:isInCombat() or Me:isLookOn() then
        return
    end

    if data.id ~= Me:getId() then
        -- 不是自己播放的烟花，需要检测播放数量
        local gameSetting = SystemSettingMgr:getSettingStatus("sight_scope")
        local curPlayYanhuaNum = self.playActionsNum["yanhua"] or 0
        if (GAME_EFFECT.LOW == gameSetting and curPlayYanhuaNum >= 5)
            or (GAME_EFFECT.MIDDLE == gameSetting and curPlayYanhuaNum >= 10)
            or (curPlayYanhuaNum >= 20) then
            return
        end
    end

    return true
end

-- 礼花限制播放的函数
function PlayActionsMgr:onPlayLihuaLimit(data)
    if Me:isInCombat() or Me:isLookOn() then
        return
    end

    if self.playActionsNum["lihua"] and self.playActionsNum["lihua"] >= 1 then
        return
    end

    return true
end

-- 开始播放
function PlayActionsMgr:doPlayAction(layer, data)
    local id = self:getUniqueId()
    layer:setVisible(self:canVisible())
    layer:setTag(id)
    layer.effectNo = data.effect_no

    self.animates[id] = layer

    -- 如果有持续 优先播放持续时间
    if (data.during or 0) ~= 0 then
        self:playActionContinuTime(layer, data.effect_no, data.during)
    else
        self:playActionByTimes(layer, data.effect_no, data.loops, data.interval)
    end
end

function PlayActionsMgr:MSG_ANIMATE_IN_CHAR_LAYER(data)

    if HomeChildMgr:isInDailyTask() then return end

    local info = EFFECT_INFO[data.effect_no]
    if not info then return end
    if info.limitFunc and not self[info.limitFunc](self, data) then
        return
    end

    if EFFECT_INFO[data.effect_no].type == "yanhua" then
        -- 烟花向上偏移 5 个块的距离
        data.y = math.max(data.y - 5, 1)
    end

    local mapLayout = ccui.Layout:create()
    local x, y = gf:convertToClientSpace(data.x, data.y)
    mapLayout:setPosition(x, y)
    local layer
    if data.order == CHAR_LAYER_ORDER.MIDDLE then
        layer = gf:getCharMiddleLayer()
    elseif data.order == CHAR_LAYER_ORDER.BOTTOM then
        layer = gf:getCharBottomLayer()
    else
        layer = gf:getCharTopLayer()
    end

    layer:addChild(mapLayout)
    self:doPlayAction(mapLayout, data)
end

function PlayActionsMgr:MSG_ANIMATE_IN_CHAR(data)
    local char = CharMgr:getChar(data["id"])
    if not char then return end

    local magicKey = nil
    if data["loops"] == 0 then -- 循环播放
        magicKey = data["effect_no"]
    end

    if data["pos"] == CHAR_EFFECT_POS["foot"] then
        char:addMagicOnFoot(data["effect_no"], data["order"] == 1, magicKey)
    elseif data["pos"] == CHAR_EFFECT_POS["waist"] then
        char:addMagicOnWaist(data["effect_no"], data["order"] == 1, magicKey)
    elseif data["pos"] == CHAR_EFFECT_POS["head"] then
        char:addMagicOnHead(data["effect_no"], data["order"] == 1, magicKey)
    end
end

function PlayActionsMgr:getUniqueId()
    uniqueId = uniqueId + 1
    return uniqueId
end

function PlayActionsMgr:canVisible()
    if Me:isInCombat() or Me:isLookOn() then
        return false
    end

    return true
end

function PlayActionsMgr:setVisible(visible)
    for _, v in pairs(self.animates) do
        v:setVisible(visible and self:canVisible())
    end
end

function PlayActionsMgr:deleteOneAction(animate)
    local info = animate.effectNo and EFFECT_INFO[animate.effectNo]
    if animate.soundId then
        -- 停掉对应的音效
        local info = animate.effectNo and EFFECT_INFO[animate.effectNo]
        if info.sound then
            SoundMgr:stopSoundEffectBySoundId(info.sound, animate.soundId)
        end
    end

    if info.callback and self[info.callback] then self[info.callback](self, "remove") end

    local id = animate:getTag()
    self.animates[id] = nil
    animate:removeFromParent()
end

function PlayActionsMgr:onEnterCombat()
    -- 进战斗要直接移除配置 removeInCombat 的光效
    for _, v in pairs(self.animates) do
        if v.effectNo and EFFECT_INFO[v.effectNo] and EFFECT_INFO[v.effectNo].removeInCombat then
            self:deleteOneAction(v)
        end
    end
end

-- 当前是否在播放礼花光效
function PlayActionsMgr:isPlayLiHua()
    for _, v in pairs(self.animates) do
        if v.effectNo == 02036 then
            return true
        end
    end
end

function PlayActionsMgr:clearAllAnimates()
    for _, v in pairs(self.animates) do
        self:deleteOneAction(v)
    end

    self.animates = {}
    uniqueId = 0
    self.playActionsNum = {}
end

function PlayActionsMgr:MSG_REMOVE_ANIMATE(data)
    if data.type == ANIMATION_TYPE.ANIMATION_IN_CHAR then
        self:removeCharEffect(data.id, data.effect_no)
	end
end

function PlayActionsMgr:removeCharEffect(id, effect_no)
    local char = CharMgr:getChar(id)
    if not char then return end
    char:deleteMagic(effect_no)
end

EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, PlayActionsMgr.onEnterCombat, PlayActionsMgr)

MessageMgr:regist("MSG_ANIMATE_IN_UI", PlayActionsMgr)
MessageMgr:regist("MSG_ANIMATE_IN_MAP", PlayActionsMgr)
MessageMgr:regist("MSG_ANIMATE_IN_CHAR", PlayActionsMgr)
MessageMgr:regist("MSG_ANIMATE_IN_CHAR_LAYER", PlayActionsMgr)
MessageMgr:regist("MSG_REMOVE_ANIMATE", PlayActionsMgr)

return PlayActionsMgr
