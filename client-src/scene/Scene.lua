-- Scene.lua
-- Created by chenyq Nov/10/2014
-- 场景基类

Scene = class("Scene", function()
    return cc.Scene:create()
end)

local NodeEvent = {
    NODE_ENTER = "enter",
    NODE_EXIT = "exit",
    NODE_ENTERFINISH = "enterTransitionFinish",
    NODE_EXITSTART = "exitTransitionStart",
    NODE_CLEANUP = "cleanup",
}

function Scene:ctor(uiOnly)
    GameMgr:setTopLayers(self, uiOnly)

    DlgMgr:closeAllDlg()

    self:init()

    local function onNodeEvent(event)
        if NodeEvent.NODE_ENTER == event then
            self:onNodeEnter()
        elseif NodeEvent.NODE_EXIT == event then
            self:onNodeExit()
        elseif NodeEvent.NODE_CLEANUP == event then
            self:onNodeCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)
end

function Scene:getType()
    return self.__cname
end

function Scene:getHeight()
    return 0
end

function Scene:init() end
function Scene:onNodeEnter() end
function Scene:onNodeExit() end
function Scene:onNodeCleanup() end
