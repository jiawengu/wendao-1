-- CharActionNoLoop.lua
-- Created by chenyq Nov/25/2014
-- 非循环播放的动作

local CharAction = require('animate/CharAction')
local CharActionNoLoop = class('CharActionNoLoop', CharAction)

function CharActionNoLoop:ctor(...)
    CharAction.ctor(self, ...)
    self.loopTimes = 1
end


function CharActionNoLoop:setLastFrame(frame)
    self.lastFrameEx = frame + Const.CHAR_FRAME_START_NO - 1
end

function CharActionNoLoop:setFirstFrame(frame)
    self.firstFrameEx = frame + Const.CHAR_FRAME_START_NO - 1
end

function CharActionNoLoop:initFrame()
    self.keyFrame = self:getCfgInt('keyframe') + Const.CHAR_FRAME_START_NO - 1
end

function CharActionNoLoop:set(icon, weaponIcon, act, dir, partIndex, callback)
    self:setIcon(icon, true)
    self:setBodyPartIndex(partIndex, true)
    self:setWeapon(weaponIcon, true)
    self:setAction(act, true)
    self:setDirection(dir, true)

    self:readCartoonInfo()
    self:initFrame()
    self:setFrames(self.firstFrame, self.lastFrame, true)

    self.char:setCallback(callback)
    self:updateNow()
end

return CharActionNoLoop
