-- CharActionEnd.lua
-- Created by chenyq Nov/24/2014
-- 结束动作

local CharActionNoLoop = require('animate/CharActionNoLoop')
local CharActionEnd = class('CharActionEnd', CharActionNoLoop)

function CharActionEnd:ctor()
    CharActionNoLoop.ctor(self)
end

function CharActionEnd:initFrame()
    CharActionNoLoop.initFrame(self)
    if self.firstFrameEx then
        self.firstFrame = self.firstFrameEx
    else
        self.firstFrame = self.keyFrame
    end
end

return CharActionEnd
