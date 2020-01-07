-- CharActionEx.lua
-- created by sujl Jan/13/2017
-- 角色动画，包含人物、武器等
-- 支持复合动作

local CharAction = require('animate/CharAction')
local CharActionEx = class('CharActionEx', CharAction)

-- 动作配置
local CharActionInfo = require("cfg/CharActionInfo")

function CharActionEx:ctor()
    CharAction.ctor(self)
end

function CharActionEx:setAction(act, noUpdateNow)
    self.curRealAction = nil
    self.curPlayActIndex = nil

    -- 加载动作配置
    if self:loadActionConfiguration(self.icon, act) and self.actionCfg then
        self.char:setCallback(function()
            self:onActionEnd()
        end)

        self:doMultiActionLoop()
    elseif not self.actionCfg then
        self:setLoopTimes(0)
    end

    CharAction.setAction(self, act, noUpdateNow)
end

-- 加载动作配置
function CharActionEx:loadActionConfiguration(icon, act)
    local cfgs = CharActionInfo[icon]
    if not cfgs then return end
    local cfg = cfgs[gf:getActionStr(act)]
    if cfg == self.actionCfg then return end
    self.actionCfg = nil
    if not cfg then return end
    self.actionCfg = cfg
    return true
end

-- 动作播放结束
function CharActionEx:onActionEnd()
    -- 目前只支持一种格式
    if self.actionCfg then
        self:doMultiActionLoop()
        local act = self.action
        self.action = nil
        CharAction.setAction(self, act)
    end
end

-- 多个动作顺序播放
function CharActionEx:doMultiActionLoop()
    self.curRealAction = nil
    if not self.actionCfg then return end

    if self.curPlayActIndex then
        self.curPlayActIndex = self.curPlayActIndex + 1
    else
        self.curPlayActIndex = 1
    end
    if self.curPlayActIndex > #self.actionCfg then
        self.curPlayActIndex = self.curPlayActIndex - #self.actionCfg
    end

    local actStr = self.actionCfg[self.curPlayActIndex]
    assert(#actStr > 0)
    self.curRealAction = gf:getActionByStr(actStr[1])
    if #actStr > 1 then
        if 'table' == type(actStr[2]) then
            self:setLoopTimes(math.random(actStr[2][1], actStr[2][2]), true)
        else
            self:setLoopTimes(actStr[2], true)
        end
    else
        self:setLoopTimes(1, true)
    end
end

function CharActionEx:getRealAction(typeTag)
    return self.curRealAction or CharAction.getRealAction(self, typeTag)
end

return CharActionEx
