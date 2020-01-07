-- LoginBack2019Dlg.lua
-- Created by haungzz, Dec/28/2018
-- 登录背景界面

local CHANGE_TIME = 15
local WAIT_TIME = 10

local startTime = 1545741828  -- 随便取的时间

local LoginBack2019Dlg = class("LoginBack2019Dlg", function()
    return cc.Layer:create()
end)

function LoginBack2019Dlg:ctor(param)
    self:UnloadPatchRes()

    local winSize = cc.Director:getInstance():getWinSize()
    local pos = cc.p(winSize.width / 2, winSize.height / 2)
    local nightEffect = self:createArmature("02028")
    nightEffect:setPosition(pos)
    nightEffect:getAnimation():play("Bottom01", -1, 1)
    self:addChild(nightEffect)

    local dayEffect = self:createArmature("02028")
    dayEffect:setPosition(pos)
    dayEffect:getAnimation():play("Bottom02", -1, 1)
    self:addChild(dayEffect)

    local isNight = false
    local fadeTime = CHANGE_TIME
    local delayTime = WAIT_TIME

    local userDefault = cc.UserDefault:getInstance()
    local str = userDefault:getStringForKey("LoginBack2019DlgParam", "")

    if str ~= "" then
        local arg = self:split(str, "|")
        delayTime = tonumber(arg[1]) or WAIT_TIME
        fadeTime = tonumber(arg[2]) or CHANGE_TIME
        isNight = arg[3] == "true" and true or false

        userDefault:setStringForKey("LoginBack2019DlgParam", "")
    else
        local curTime = os.time()
        if curTime < startTime then
            startTime = curTime
        end

        local totalTime = (CHANGE_TIME + WAIT_TIME) * 2
        local hasTime =  (curTime - startTime) % totalTime

        if hasTime >= totalTime / 2 then
            hasTime = hasTime - totalTime / 2
            isNight = true
        end

        delayTime = math.max(0, WAIT_TIME - hasTime)
        if hasTime <= WAIT_TIME then
            fadeTime = CHANGE_TIME
        else
            fadeTime = CHANGE_TIME - (hasTime - WAIT_TIME)
        end
    end

    if isNight then
        dayEffect:setOpacity((1 - fadeTime / CHANGE_TIME) * 255)
    else
        dayEffect:setOpacity(fadeTime / CHANGE_TIME * 255)
    end

    if not param or not param.doAction then
        -- 不播动画，防止更新阻塞出现卡顿
        nightEffect:getAnimation():gotoAndPause(0)
        dayEffect:getAnimation():gotoAndPause(0)

        -- 保存数据，避免从更新场景到登录场景变化过大
        userDefault:setStringForKey("LoginBack2019DlgParam", delayTime .. "|" .. fadeTime .. "|" .. tostring(isNight))
        return
    end

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.loopComplete then
            nightEffect:getAnimation():gotoAndPlay(0) 
        end
    end

    dayEffect:getAnimation():setMovementEventCallFunc(func)

    local function func(delayTime, fadeTime, isNight)
        performWithDelay(self, function()
            local fadeAct 
            if not isNight then
                -- 白天，delayTime 后白天逐渐出现
                fadeAct = cc.FadeOut:create(fadeTime)
            else
                -- 晚上，delayTime 后白天逐渐出现
                fadeAct = cc.FadeIn:create(fadeTime)
            end

            local action = cc.Sequence:create(
                fadeAct,
                cc.CallFunc:create(function()
                    func(WAIT_TIME, CHANGE_TIME, not isNight)
                end)
            )

            dayEffect:runAction(action)
        end, delayTime)
    end

    func(delayTime, fadeTime, isNight)
end

function LoginBack2019Dlg:cleanup()
end

-- 分割字符串
function LoginBack2019Dlg:split(s, delim)
    if not s or type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = self:findStrByByte(s, delim, start) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 根据字节来查找字符串
function LoginBack2019Dlg:findStrByByte(str, patt, s)
    local startPos = s or 1
    local charF, charE
    for i = startPos, string.len(str) - string.len(patt) + 1 do
        local flag = true
        for j = 1, string.len(patt) do
            if string.byte(str, i + j - 1) ~= string.byte(patt, j) then
                flag = false
                break
            end
        end

        if flag then
            -- 找到了
            charF = i
            charE = i + string.len(patt) - 1
            break
        end
    end

    return charF, charE
end


function LoginBack2019Dlg:createArmature(icon)
    -- 先加载资源
    local path = string.format("animate/ui/%s.ExportJson", icon)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    return ccs.Armature:create(icon)
end

-- 释放补丁更新的文件
function LoginBack2019Dlg:UnloadPatchRes()
    ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo("animate/ui/02028.ExportJson")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("animate/ui/020280.png")
    cc.Director:getInstance():getTextureCache():removeTextureForKey("animate/ui/020281.png")
end

return LoginBack2019Dlg