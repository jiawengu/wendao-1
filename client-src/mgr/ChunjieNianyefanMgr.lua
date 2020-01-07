-- ChunjieNianyefanMgr.lua
-- created by huangzz Dec//2015
-- 春节年夜饭管理器

ChunjieNianyefanMgr = Singleton()

local DefaultMapMagic = require("maps/magic/MapMagic")

local PLAY_TIME = 30 -- 播放30秒烟花
local PLAY_TIME24 = 60 -- 24点播放60秒烟花
local INTERVAL = 3600
local START_TIME = 20 * 3600 -- 当天开始播放烟花时间

local YANHUA = {
    01361,
    01362,
    01363,
}

function ChunjieNianyefanMgr:init()
    self.startTime = os.time{year = 2018, month = 01, day = 10, hour = 05, min = 00, sec = 00}
    self.isPlaying = false
    self.scheduleId = gf:Schedule(function()
        if ChunjieNianyefanMgr then
            ChunjieNianyefanMgr:playYanhua()
        end
    end, 1)
end

-- GameMgr:stop调用，用于游戏中不退出重启更新
function ChunjieNianyefanMgr:cleanup()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function ChunjieNianyefanMgr:playYanhua()
    local task = TaskMgr:getTaskByName(CHS[5400698])
    if not task then
       return
    end

    if self.isPlaying then
        return
    end

    local time = gf:getServerTime()
    if self.startTime > time then
        -- 策划设定内测提前开放期间不播放烟花，此处暂定 1 月 10 号前不播放
        return
    end

    local char = CharMgr:getCharByName(CHS[5400702])
    if not char then
        return
    end
    
    local hour = tonumber(gf:getServerDate("%H", time))
    local min = tonumber(gf:getServerDate("%M", time))
    local sec = tonumber(gf:getServerDate("%S", time))
    
    if hour == 0 then
        hour = 24
    end
    
    local curTime = hour * 3600 + min * 60 + sec
    if START_TIME > curTime then
        return
    end

    if curTime - START_TIME > INTERVAL * 5 then
        return
    end
    
    -- 剩余播放烟花时间
    local cou = math.floor((curTime - START_TIME) / INTERVAL) -- 第次播烟花的点
    local hasTime = (curTime - START_TIME) % INTERVAL         -- 距该次开始播放烟花的时间
    local playTime
    if cou <= 3 then
        playTime = PLAY_TIME - hasTime
    else
        playTime = PLAY_TIME24 - hasTime
    end

    if playTime <= 0 or cou > 4 then
        return
    end

    local lastTime = gf:getServerTime()
    self.isPlaying = true
    local function fun()
        local char = CharMgr:getCharByName(CHS[5400702])
        if gf:getServerTime() - lastTime >= playTime or not char then
            self.isPlaying = false
            return
        end

        local x, y = gf:convertToMapSpace(char.curX, char.curY)

        local data = {}
        data.id = Me:getId()  -- 取玩家的 id，不受游戏效果影响，直接播放
        data.effect_no = YANHUA[math.random(1, 3)]
        data.order = 0
        data.x = x + math.random(-8, 8)
        data.y = y + math.random(-6, 8)
        data.loops = 1
        data.interval = 0
        data.during = 0

        PlayActionsMgr:MSG_ANIMATE_IN_CHAR_LAYER(data)

        performWithDelay(gf:getUILayer(), function()
            fun()
        end, math.random(0.2, 0.5))
    end

    fun()
end

function ChunjieNianyefanMgr:stopYHBZSchedule()
    if self.scheduleYHBZId then
        gf:Unschedule(self.scheduleYHBZId)
        self.scheduleYHBZId = nil
    end
end

function ChunjieNianyefanMgr:MSG_SPRING_2019_ZSQF_OPEN(data)
    local dlg = DlgMgr:openDlg("ChunjieNianyefanDlg")
    dlg:setStatus(data)
end

ChunjieNianyefanMgr:init()

MessageMgr:regist("MSG_SPRING_2019_ZSQF_OPEN", ChunjieNianyefanMgr)

return ChunjieNianyefanMgr