-- CgShowDlg.lua
-- Created by sujl, 12/27/2017
-- Cg展示界面

local CgShowDlg = class("CgShowDlg", function()
    return cc.Layer:create()
end)

local VIDEO_SIZE = cc.size(1920, 1080)  -- 视频尺寸：1920x1080
local FILE_NAME = "cg.mp4"
local ASSETR_ESOURCE_ROOT = "assets/"
local CUR_VERSION = 1   -- 当前CG版本

function CgShowDlg:ctor(filePath, callback)
    self.filePath = filePath
    self.callback = callback
    self.root = ccui.Layout:create()
    local winSize = cc.Director:getInstance():getWinSize()
    self.root:setContentSize(cc.size(winSize.width, winSize.height))
    self.root:setAnchorPoint(cc.p(0.5, 0.5))
    self.root:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

    -- 黑底
    self.root:setBackGroundColorType(1)
    self.root:setBackGroundColor(cc.c3b(0, 0, 0))

    self.root:setTouchEnabled(true)
    self:addChild(self.root)

    if gf:isAndroid() or gf:isIos() then
        -- 手机下开始播放CG
        self:playVideo()
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
        elseif eventType == ccui.TouchEventType.ended then
            if self.videoPlayer then
                self.videoPlayer:stop()
            end
            if gf:isIos() then
                performWithDelay(self, function()
                    self:removeFromParent()
                end, 3)
        end
    end
    end

    self.root:addTouchEventListener(listener)

    local function onNodeEvent(event)
        if "cleanup" == event then
            self:onNodeCleanup()
        end
    end

    self:registerScriptHandler(onNodeEvent)

    -- 部分手机不支持在同一帧既开始播放又同时停止播放
    -- 所以延时一帧停止背景音乐
    performWithDelay(self, function()
        -- 禁用音乐音效
        SoundMgr:stopMusicAndSound()
    end, 0)

    if gf.EndGameEx then
        -- 替换esc键退出
        local curNode = self
        gf.EndGameEx = function()
            if curNode and 'function' == type(curNode.removeFromParent) then
                curNode:removeFromParent()
            end
        end
    end

    EventDispatcher:addEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)
end

function CgShowDlg:playVideo()
    if not self.videoPlayer then
        self.videoPlayer = ccexp.VideoPlayer:create()
    end

    local winSize = cc.Director:getInstance():getVisibleSize()
    local size
    if VIDEO_SIZE.width * winSize.height > VIDEO_SIZE.height * winSize.width then
        size = cc.size(winSize.width, VIDEO_SIZE.height * winSize.width / VIDEO_SIZE.width)
    else
        size = cc.size(VIDEO_SIZE.width * winSize.height / VIDEO_SIZE.height, winSize.height)
    end

    self.videoPlayer:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
    self.videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))

    local userDefault = cc.UserDefault:getInstance()
    local musicOn = userDefault:getBoolForKey("musicOn", true)
    local isStop
    self.videoPlayer:addEventListener(function(sender, event)
        if "1" == tostring(event) or "2" == tostring(event) or ("3" == tostring(event) and gf:isAndroid()) then
            isStop = true
            performWithDelay(self, function()
                self:removeFromParent()
            end, 0)
        elseif "0" == tostring(event) then
            if not musicOn and self:isMuteSupport() and 'function' == type(self.videoPlayer.setVolumn) then
                self.videoPlayer:setVolumn(0)
            end
        end

        if isStop then
            local userDefault = cc.UserDefault:getInstance()
            if userDefault then
                local curVer = userDefault:getIntegerForKey("CgVersion", CUR_VERSION)
                userDefault:setIntegerForKey("CgVersion", CUR_VERSION)
                if "3" == tostring(event) or curVer ~= CUR_VERSION then
                    -- 播放完成了，没有跳过，重置跳过次数
                    userDefault:setIntegerForKey("CgSkipTimes", 0)
                else
                    -- 跳过了
                    local skipTimes = userDefault:getIntegerForKey("CgSkipTimes", 0)
                    userDefault:setIntegerForKey("CgSkipTimes", skipTimes + 1)
                end
            end
        end
    end)
    if not musicOn and self:isMuteSupport() and gf:isIos() then
        self.curMediaVolumn = self.videoPlayer:getVolumn()
    end

    self:addChild(self.videoPlayer)
    self:setVisible(false)

    if gf:isAndroid() and not gf:gfIsFuncEnabled(FUNCTION_ID.VIDEOPLAY_V20171228) then
        self.videoPlayer:setContentSize(cc.size(winSize.width, winSize.height))
        self.videoPlayer:setFileName(self:getFilePath())
        self:setVisible(true)
        self.videoPlayer:play()
        self.videoPlayer:seekTo(0.9)

        performWithDelay(self, function()
            if self.videoPlayer then
                self.videoPlayer:setFullScreenEnabled(true)
                self.videoPlayer:setKeepAspectRatioEnabled(true)
            end
        end, 0)
    else
        if self.videoPlayer then
            self.videoPlayer:setContentSize(cc.size(size.width, size.height))
            self.videoPlayer:setFileName(self:getFilePath())
            self.videoPlayer:play()
            self.videoPlayer:seekTo(0.9)
            self:setVisible(true)
        end
    end
end

function CgShowDlg:getFilePath()
    if 1 == string.find(self.filePath, ASSETR_ESOURCE_ROOT) then
        return string.sub(self.filePath, #ASSETR_ESOURCE_ROOT + 1)
    else
        return self.filePath
    end
end

--[[
function CgShowDlg:fixSize()
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local glView = cc.Director:getInstance():getOpenGLView()
    local leftBottom = self.videoPlayer:convertToWorldSpace(cc.p(0, 0))
    local size = self.videoPlayer:getContentSize()
    local rightTop = self.videoPlayer:convertToWorldSpace(cc.p(size.width, size.height));
    local winSize = cc.Director:getInstance():getVisibleSize()
    local uiLeft = frameSize.width / 2 + (leftBottom.x - winSize.width / 2 ) * glView:getScaleX()
    local uiTop = frameSize.height /2 - (rightTop.y - winSize.height / 2) * glView:getScaleY()
    local uiWidth = (rightTop.x - leftBottom.x) * glView:getScaleX()
    local uiHeight = (rightTop.y - leftBottom.y) * glView:getScaleY()

    local ok, ret
    ok, ret = LuaJavaBridge.callStaticMethod("java/lang/Class", "forName", { 'org.cocos2dx.lib.Cocos2dxVideoHelper' }, "(Ljava/lang/String;)Ljava/lang/Class;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/Class", "getDeclaredField", ret, {"mVideoHandler"}, "(Ljava/lang/String;)Ljava/lang/reflect/Field;")
    if not ok then return end
    ok, _ = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "setAccessible", ret, { true }, "(Z)V")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "get", ret, { LuaJavaBridge.ObjectNull() }, "(Ljava/lang/Object;)Ljava/lang/Object;")
    if not ok then return end

    local o = ret
    ok, ret = LuaJavaBridge.callStaticMethod("java/lang/Class", "forName", { 'org.cocos2dx.lib.Cocos2dxVideoHelper$VideoHandler' }, "(Ljava/lang/String;)Ljava/lang/Class;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/Class", "getDeclaredField", ret, {"mReference"}, "(Ljava/lang/String;)Ljava/lang/reflect/Field;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "get", ret, { o }, "(Ljava/lang/Object;)Ljava/lang/Object;") -- mReference
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/ref/WeakReference", "get", ret, {}, "()Ljava/lang/Object;") -- Cocos2dxVideoHelper
    if not ok then return end

    local helper = ret

    ok, ret = LuaJavaBridge.callStaticMethod("java/lang/Class", "forName", { 'org.cocos2dx.lib.Cocos2dxVideoHelper' }, "(Ljava/lang/String;)Ljava/lang/Class;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/Class", "getDeclaredField", ret, {"videoTag"}, "(Ljava/lang/String;)Ljava/lang/reflect/Field;")
    if not ok then return end
    ok, _ = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "setAccessible", ret, { true }, "(Z)V")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "get", ret, { LuaJavaBridge.ObjectNull() }, "(Ljava/lang/Object;)Ljava/lang/Object;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callStaticMethod("com/gbits/ClassUtils", "ObjectToInt", { ret }, "(Ljava/lang/Object;)I" )
    if not ok then return end

    local index = ret

    ok, ret = LuaJavaBridge.callStaticMethod("java/lang/Class", "forName", { 'org.cocos2dx.lib.Cocos2dxVideoHelper' }, "(Ljava/lang/String;)Ljava/lang/Class;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/Class", "getDeclaredField", ret, {"sVideoViews"}, "(Ljava/lang/String;)Ljava/lang/reflect/Field;")
    if not ok then return end
    ok, _ = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "setAccessible", ret, { true }, "(Z)V")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("java/lang/reflect/Field", "get", ret, { helper }, "(Ljava/lang/Object;)Ljava/lang/Object;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("android.util.SparseArray", "get", ret, { index - 1 }, "(I)Ljava/lang/Object;")
    if not ok then return end
    ok, ret = LuaJavaBridge.callObjectMethod("org/cocos2dx/lib/Cocos2dxVideoView", "fixSize", ret, { uiLeft, uiTop, uiWidth, uiHeight }, "(IIII)V")
    if not ok then Log:I(">>>>Failed to fixSize") end

end
]]

function CgShowDlg:onEnterBackground(sender, eventType)
    if gf:isAndroid() then
        if self.videoPlayer then
            self.videoPlayer:stop()
        end
        self:removeFromParent()
    end
end

function CgShowDlg:onNodeCleanup()
    EventDispatcher:removeEventListener("ENTER_BACKGROUND", self.onEnterBackground, self)

    local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE then
        local luaoc = require('luaoc')
        luaoc.callStaticMethod("AppController", "finishVolumnView")
    end

    -- 恢复音乐和音效
    SoundMgr:replayMusicAndSound()

    if self.curMediaVolumn and self:isMuteSupport() and 'function' == type(self.videoPlayer.setVolumn) then
        self.videoPlayer:setVolumn(self.curMediaVolumn)
    end

    if 'function' == type(self.callback) then
        local callback = self.callback
        local scene = cc.Director:getInstance():getRunningScene()
        if scene then
            performWithDelay(scene, function()
                callback()
            end, 0)

            if scene.updateDlg then
                scene.updateDlg:setVisible(false)
            end
        else
            callback()
        end
    end

    -- 由于替换了gf.EndGameEx，此处重新加载一下GlobalFunc.lua
    package.loaded['global/GlobalFunc'] = nil
    require('global/GlobalFunc')
end

function CgShowDlg:isMuteSupport()
    local platform = cc.Application:getInstance():getTargetPlatform()
    if cc.PLATFORM_OS_ANDROID == platform then
        return true
    elseif (platform == cc.PLATFORM_OS_IPAD or platform == cc.PLATFORM_OS_IPHONE) then
        return 'function' == type(ccexp.VideoPlayer.getVolumn)
    end
end

-- 检查是否需要播放当前CG
function CgShowDlg.canSkip()
    local userDefault = cc.UserDefault:getInstance()
    if not userDefault then return end
    local cgVer = userDefault:getIntegerForKey("CgVersion", 0)
    if CUR_VERSION > cgVer then return end     -- 版本更新了
    local skipTimes = userDefault:getIntegerForKey("CgSkipTimes", 0)
    return skipTimes >= 5
end

return CgShowDlg
