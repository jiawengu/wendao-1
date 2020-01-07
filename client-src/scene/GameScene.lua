-- GameScene.lua
-- created by cheny
-- 游戏场景

require "Cocos2d"
require "Cocos2dConstants"
require "global/Const"
local Map = require("obj/Map")
local DragMap = require("obj/map/DragMap")
local Weather = require("obj/Weather")
local MiGongMap = require("obj/map/MiGongMap")
local Magic = require("animate/Magic")
local GameScene = class("GameScene", Scene)
local WeatherAnimCfg = require(ResMgr:getCfgPath("WeatherAnimCfg.lua"))

local EXITS_DIR = {
    HOUSE_QIANTING  = 9,    -- 居所前厅光效
    HOUSE_HOUYUAN   = 10,    -- 居所后院光效
    NORTH_WEST   = 11,    -- 西北方向(居所后院光效X轴对称)
    SOUTH_EAST   = 12,    -- 东南方向(居所前庭光效X轴对称)
}

function GameScene:init()
    -- 关闭等待界面
    DlgMgr:closeDlg("WaitDlg")
    DlgMgr:openDlg("MissionDlg")
    DlgMgr:openDlg("GameFunctionDlg")
    DlgMgr:openDlg("HeadDlg")
    DlgMgr:openDlg("ChatDlg")
    DlgMgr:openDlg("SystemFunctionDlg")

    local timeZone = gf:getClientTimeZone()
    if timeZone ~= GameMgr.clientTimeZone then
        GameMgr.clientTimeZone = timeZone
    end

    local deviceCfg = DeviceMgr:getUIScale()
    if deviceCfg and deviceCfg.fullback then
        DlgMgr:openDlg(deviceCfg.fullback)
    end

    GameMgr.curMainUIState = MAIN_UI_STATE.STATE_SHOW

    local userDefault = cc.UserDefault:getInstance()
    if userDefault and userDefault:getBoolForKey("screenRecordOn", false) and ScreenRecordMgr:supportRecordScreen() then
        DlgMgr:openDlg("ScreenRecordingDlg")
    end

    self.scheduleId = nil
    self.lastTime = 0
    self:startSendMoveCmdsSch()

    -- 有可能在场景还未创建时就受到了MSG_EXITS
    self:checkExits()

    MessageMgr:hook("MSG_EXITS", self, "GameScene")
end

function GameScene:startSendMoveCmdsSch()
    local time = 1.1
    if MapMgr:isInBaiHuaCongzhong() or MapMgr:isInYuLuXianChi() then
        time = 0.3
    end

    if self.lastTime == time and self.scheduleId then
        return
    end

    self.lastTime = time
    if self.scheduleId then
        self:stopAction(self.scheduleId)
    end

    self.scheduleId = schedule(self, function() self:sendMoveCmds() end, time)
end

function GameScene:onNodeEnter()
    -- 有可能在场景还未创建时就受到了MSG_EXITS
    self:checkExits()
    MessageMgr:unhook("MSG_EXITS", "GameScene")
    MessageMgr:hook("MSG_EXITS", self, "GameScene")
end

function GameScene:onNodeCleanup()
    MessageMgr:unhookByHooker('GameScene')
end

function GameScene:initMap(map_id)
    local map = nil

    catch(function()
        local mapInfo = MapMgr:getMapinfo()
        local info = mapInfo[map_id]
        if info.mapType == MAP_TYPE.DRAG_MAP then
            -- 拖动类型的地图
            map = DragMap.new(info.map_id, nil)
        elseif info.mapType == MAP_TYPE.MIGONG_MAP then
            map = MiGongMap.new(info.map_id, nil)
        else
            map = Map.new(info.map_id, nil)
        end

        self.backsize = map:getContentSize()
        gf:getMapBgLayer():addChild(map, -1)
    end, function()
        self.backsize = cc.size(0, 0)
    end)
    self.map = map

    -- 天气系统
    WeatherMgr:removeWeather()
    local weather = Weather:create(map_id)
    if weather then
        WeatherMgr:addWeather(weather)
    end

    -- 天气动画系统
    gf:getWeatherAnimLayer():removeAllChildren()
    local weatherAnim = WeatherMgr:getWeatherAnim(map_id)
    if weatherAnim then
        WeatherMgr:addWeatherAnim(weatherAnim)
    end

    return map
end

-- 创建天气动画系统
-- 目前支持两种动画：骨骼动画及粒子动画
function GameScene:createWeatherAnim(map_id)
    if not WeatherAnimCfg or not WeatherAnimCfg[map_id] then return end   -- 未配置动画系统

    local cfg = WeatherAnimCfg[map_id]
    if cfg.type == "particle" then
        -- 粒子动画
        local icon = string.format("%05d", cfg.icon)
        local quad = cc.ParticleSystemQuad:create(ResMgr:getParticleWeatherAnimatePath(icon))
        quad:setAnchorPoint(0.5, 0.5)
        quad:setPosition(Const.WINSIZE.width / 2 + cfg.x, Const.WINSIZE.height / 2 + cfg.y)
        quad:setPosVar(cc.vertex2F(Const.WINSIZE.width / 2 + cfg.x, Const.WINSIZE.height / 2 + cfg.y))
        return quad
    elseif cfg.type == "armature" then
        local icon = string.format("%05d", cfg.icon)
        local anim = ArmatureMgr:createWeathArmature(icon)
        anim:setAnchorPoint(0.5, 0.5)
        anim:setPosition(Const.WINSIZE.width / 2 + cfg.x, Const.WINSIZE.height / 2 + cfg.y)
        anim:getAnimation():play(cfg.action)
        return anim
    end
end

-- 获取场景高度
function GameScene:getHeight()
    return self.backsize.height
end

function GameScene:sendMoveCmds()
    CharMgr:sendMoveCmds()

    if Me:isChangingRoom() == true then
        -- 正在过图
        return
    end

    local data = self.exits
    if data == nil then
        -- 过图点信息不存在
        return
    end

    local x, y = Me.curX, Me.curY
    local count = data.count
    for i = 1, count do
        -- 遍历所有的过图点
        local name = string.format("%d_%d", data[i].x, data[i].y)
        local sprite = gf:getMapEffectLayer():getChildByName(name)
        local radia = self:getExitRadia(name)
        if sprite ~= nil then
            local sx, sy = sprite:getPosition()
            if gf:distance(x, y, sx, sy) < radia then
                -- 是否需要无视过图点
                if not AutoWalkMgr:isIgnoreExit() and Me:isControlMove() and Const.SA_STAND == Me.faAct then
                    -- 防止被拉回来再发次最新的位置信息
                    CharMgr:sendMoveCmds()
                    local isTaskWalk
                    if AutoWalkMgr.autoWalk and AutoWalkMgr.autoWalk.curTaskWalkPath then
                        isTaskWalk = MapMgr:tryCheckTaskForLoading(AutoWalkMgr.autoWalk.curTaskWalkPath.task_type)
                    end
                    gf:CmdToServer("CMD_ENTER_ROOM", { room_name = data[i].room_name, isTaskWalk = isTaskWalk and 1 or 0 })
                    Me:setChangeRoom(true)
                    EventDispatcher:dispatchEvent(EVENT.CMD_ENTER_ROOM, { toRoom = data[i].room_name })
                end
            end
        end
    end
end

function GameScene:getExitRadia(name)
    local mapInfo = MapMgr:getCurrentMapInfo()
    local rate = 1
    if mapInfo and mapInfo.exit_range and mapInfo.exit_range[name] then
        rate = mapInfo.exit_range[name] or 1
    end

    return (Const.PANE_WIDTH + Const.PANE_HEIGHT) * rate
end

-- 显示障碍点
function GameScene:showObstacle()
    local obstacle = self.map.obstacle
    if nil == obstacle then return end
    obstacle:setVisible(not obstacle:isVisible())

    local mapSize = self.map:getContentSize()
    obstacle:setPosition(0, mapSize.height)
    obstacle:setAnchorPoint(0, 1)
end

-- 检查过图点
function GameScene:checkExits()
    local data = MapMgr:getExits()
    if not data or not data.count then return end

    self:MSG_EXITS(data)
end

-- 添加过图点
function GameScene:addExit(exit)
    local name = string.format("%d_%d", exit.x, exit.y)
    if exit.add_exit == 1 then
        local x = (exit.x + 0.5) * Const.PANE_WIDTH
        local y = self.backsize.height - (exit.y + 0.5) * Const.PANE_HEIGHT
        local exitSp = gf:getMapEffectLayer():getChildByName(name)
        if nil ~= exitSp and exitSp:getPositionX() == x and exitSp:getPositionY() == y then
            -- 已经存在了，不再刷新
            return
        end

        gf:getMapEffectLayer():removeChildByName(name)
        local exitSprite
        if EXITS_DIR.HOUSE_QIANTING == exit.dir then
            exitSprite = Magic.new(ResMgr.magic.exit_house_qianting, nil, nil, {blendMode = "add"})
        elseif EXITS_DIR.HOUSE_HOUYUAN == exit.dir then
            exitSprite = Magic.new(ResMgr.magic.exit_house_houyuan, nil, nil, {blendMode = "add"})
        elseif EXITS_DIR.NORTH_WEST == exit.dir then
            -- 西北方向(居所后院光效X轴对称)
            exitSprite = Magic.new(ResMgr.magic.exit_house_houyuan, nil, nil, {blendMode = "add"})
            exitSprite:setFlipX(true)
        elseif EXITS_DIR.SOUTH_EAST == exit.dir then
            -- 东南方向(居所前庭光效X轴对称)
            exitSprite = Magic.new(ResMgr.magic.exit_house_qianting, nil, nil, {blendMode = "add"})
            exitSprite:setFlipX(true)
        else
            exitSprite = Magic.new(ResMgr.magic.exit_default)
        end
        exitSprite:setName(name)
        exitSprite:setPosition(x, y)
        gf:getMapEffectLayer():addChild(exitSprite)
    else
        gf:getMapEffectLayer():removeChildByName(name)
    end
end

-- 添加过图点
function GameScene:MSG_EXITS(data)
    self.exits = data
    local count = data.count
    local exitData = {}

    for i = 1, count do
        self:addExit(data[i])
        exitData[i] = data[i]
    end

    -- 保存下当前过图点
    MapMgr:setExitData(exitData)
    MapMgr:setHaveGetExtits(true)


    -- 检查过图自动寻路
    AutoWalkMgr:enterRoomContinueAutoWalk()
end
return GameScene
