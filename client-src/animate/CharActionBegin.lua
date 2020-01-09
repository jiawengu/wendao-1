-- CharActionBegin.lua
-- Created by chenyq Nov/24/2014
-- 开始动作

local CharActionNoLoop = require('animate/CharActionNoLoop')
local CharActionBegin = class('CharActionBegin', CharActionNoLoop)

function CharActionBegin:ctor()
    CharActionNoLoop.ctor(self)
end

function CharActionBegin:initFrame()
    CharActionNoLoop.initFrame(self)
    if self.lastFrameEx then
        self.lastFrame = self.lastFrameEx
    else
        self.lastFrame = self.keyFrame - 1
    end
end

return CharActionBegin
