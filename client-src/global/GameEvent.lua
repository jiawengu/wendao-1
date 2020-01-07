-- GameEvent.lua
-- 游戏相关的时间函数

-- 游戏退出
function onDestroyGame(doEndLua)
	local platform = cc.Application:getInstance():getTargetPlatform()
    if platform == cc.PLATFORM_OS_WINDOWS then
        require("hotupdate"):cleanup()
    end

    if GameMgr then
        CommThread:stop()
        if GameMgr:isYayaImEnabled() then
            -- 释放语音识别引擎
            YayaImMgr:release()
        end

        ShaderMgr:releaseAllShader()
        GameMgr:clearData()
        GameMgr:stopUpdate()
        DlgMgr:unHookMsg()
        cc.Director:getInstance():getTextureCache():unbindAllImageAsync()

        -- 一定要在GameMgr:clearData之后设置
        GameMgr:setGameState(GAME_RUNTIME_STATE.QUIT_GAME)
    end

    local function _postProcess()
        if GameMgr then
            FightMgr:clearWhenEndGame()
            AnimationMgr:cleanup()
            DlgMgr:closeAllDlg()
            Me:cleanup()
            GameMgr:cleanupTopLayers()
        end

        ccs.ActionManagerEx:destroyInstance()
        ccs.GUIReader:destroyInstance()
        ccs.SceneReader:destroyInstance()
        ccs.NodeReader:destroyInstance()
        ccs.ArmatureDataManager:destroyInstance()
        if ImagePicker then ImagePicker:destroyInstance() end
        if 'function' == type(unRegAllOSSFileReqs) then
            unRegAllOSSFileReqs()
        end
        if 'function' == type(releaseAllUpdateCheckReqs) then
            releaseAllUpdateCheckReqs()
        end
    end

    if doEndLua then
        performWithDelay(cc.Director:getInstance():getRunningScene(), function()
            _postProcess()
            cc.Director:getInstance():endToLua()
        end, 0)
    else
        _postProcess()
    end
end