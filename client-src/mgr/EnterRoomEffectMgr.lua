-- EnterRoomEffectMgr.lua
-- created by lixh Jul/28/2018
-- 切换屏幕中心(过图,同地图切换左边)，需要播放特效

EnterRoomEffectMgr = Singleton("EnterRoomEffectMgr")

-- 需要播放特效的切换点配置
local EFFECT_CFG = {
    [1] = {type = "CrossFade",    effectTime = 2.0}, -- 原场景渐渐消失，目标场景渐渐出现
    [2] = {type = "Fade",         effectTime = 2.0}, -- 原场景渐渐变暗，目标场景渐渐出现
    [3] = {type = "TurnOffTiles", effectTime = 2.0}, -- 原场景呈无数正方形碎片逐渐消失，消失后显示出目标场景
    [4] = {type = "FadeBL",       effectTime = 2.0}, -- 右上角出现许多方块翻滚，逐渐蔓延至左下角，并将原场景刷新为目标场景
    [5] = {type = "FadeTR",       effectTime = 2.0}, -- 左下角角出现许多方块翻滚，逐渐蔓延至右上角，并将原场景刷新为目标场景
}

EnterRoomEffectMgr.oldScene = nil
EnterRoomEffectMgr.newScene = nil

-- 初始化场景
function EnterRoomEffectMgr:initScene(isOld)
    -- 开始播放特效前的操作
    self:doBeforeEffect()

    local layer = ccui.Layout:create()
    layer:setContentSize(Const.WINSIZE)
    local rText = cc.RenderTexture:create(Const.WINSIZE.width, Const.WINSIZE.height,
        cc.TEXTURE2_D_PIXEL_FORMAT_RGB_A8888, 0x88F0)
    rText:setPosition(Const.WINSIZE.width / 2, Const.WINSIZE.height / 2)
    rText:begin()
    GameMgr.scene:visit()
    rText:endToLua()
    layer:addChild(rText)

    if isOld then
        if self.oldScene then
            return
        end

        self.oldScene = cc.Scene:create()
        self.oldScene:addChild(layer)
        self.oldScene:retain()
    else
        if self.newScene then
            return
        end

        self.newScene = cc.Scene:create()
        self.newScene:addChild(layer)
        self.newScene:retain()
    end
end

-- 开始播放特效
function EnterRoomEffectMgr:startEffect(effectCfg, callBack)
    self.effectType = effectCfg.type
    self.effectTime = effectCfg.effectTime
    self.effectCfg = effectCfg
    self.callBack = callBack

    -- 旧场景入栈
    cc.Director:getInstance():pushScene(self.oldScene)

    -- 新场景不需要渲染主界面
    EnterRoomEffectMgr:setMainDlgVisible(false)

    -- 注册帧函数，在新场景地图加载完成时做效果
    if GameMgr.scene.map and GameMgr.scene.map:isCurSightLoadOver() then
        -- 地图已记载完成时，避免同帧切换场景，延迟一帧
        performWithDelay(self.oldScene, function()
            GameMgr:registFrameFunc(FRAME_FUNC_TAG.ENTER_ROOM_EFFECT_CHECK, self.update, self, true)
        end, 0)
    else
        GameMgr:registFrameFunc(FRAME_FUNC_TAG.ENTER_ROOM_EFFECT_CHECK, self.update, self, true)
    end
end

-- 定时器函数
function EnterRoomEffectMgr:update()
    if GameMgr.scene.map and GameMgr.scene.map:isCurSightLoadOver() then
        -- 加载完后，先取消检查函数
        GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.ENTER_ROOM_EFFECT_CHECK)

        -- 地图块加载完成, 初始化新场景
        EnterRoomEffectMgr:initScene()

        -- 新场景入栈 
        cc.Director:getInstance():pushScene(EnterRoomEffectMgr:getEffect(self.newScene,
           self.effectCfg))

        -- 延迟场景出栈
        performWithDelay(self.newScene, function()
            cc.Director:getInstance():popScene()
            cc.Director:getInstance():popScene()
            self.oldScene:cleanup()
            self.oldScene:release()
            self.oldScene = nil
            self.newScene:cleanup()
            self.newScene:release()
            self.newScene = nil

            EnterRoomEffectMgr:doAfterPopScene()
        end, self.effectTime + 0.1)
    end
end

-- 开始播放特效前的操作
function EnterRoomEffectMgr:doBeforeEffect()
    DlgMgr:setVisible("DramaDlg", false)
end

-- 播放特效后的操作
function EnterRoomEffectMgr:doAfterEffect()
    DlgMgr:setVisible("DramaDlg", true)
end

-- 回到GameScene时需要处理的事情
function EnterRoomEffectMgr:doAfterPopScene()
    -- 显示主界面
    EnterRoomEffectMgr:setMainDlgVisible(true)

    -- 播放特效后的操作
    self:doAfterEffect()

    -- 重新注册各界面定时器
    for k ,v in pairs(DlgMgr.dlgs) do
        v:registOnUpdate()
    end

    if self.callBack then
        self.callBack()
    end
end

-- 显示/隐藏主界面(立即隐藏，立即显示)
function EnterRoomEffectMgr:setMainDlgVisible(flag)
    if not flag or not MapMgr:isInMapByName(CHS[5400718]) then
        DlgMgr:setVisible("ChatDlg", flag)
    end

    if flag then
        DlgMgr:showDlgWhenNoramlDlgClose()
    else
        DlgMgr:closeDlgWhenNoramlDlgOpen(nil, true)
    end
end

-- 根据配置获取效果
function EnterRoomEffectMgr:getEffect(scene, info)
    local type = info.type
    local time = info.effectTime
    if type == "PageTurnLeft" then
        -- 向左翻页
        return cc.TransitionPageTurn:create(time , scene, false)
    elseif type == "PageTurnRight" then
        -- 向右翻页
        return cc.TransitionPageTurn:create(time , scene, true)
    elseif type == "CrossFade" then
        -- 原场景渐渐消失，目标场景渐渐出现。梦境！！！
        return cc.TransitionCrossFade:create(time , scene)
    elseif type == "Fade" then
        -- 原场景变黑，目标场景渐渐出现。睡了一觉的感觉？
        return cc.TransitionFade:create(time , scene)
    elseif type == "FadeEx" then
        -- 原场景变黑，目标场景渐渐出现。睡了一觉的感觉？
        local layer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
        local pause = info.pauseTime or 1
        local action = cc.Sequence:create(
            cc.FadeIn:create((time - pause) / 2),
            cc.DelayTime:create(pause),
            cc.FadeOut:create((time - pause) / 2)
        )
        layer:runAction(action)
        scene:addChild(layer)
        return scene
    elseif type == "FadeBL" then
        -- 右上角方块 有点炫
        return cc.TransitionFadeBL:create(time , scene)
    elseif type == "FadeDown" then
        -- 从上往下百叶窗
        return cc.TransitionFadeDown:create(time , scene)
    elseif type == "FadeTR" then
        -- 左下角方块 有点炫
        return cc.TransitionFadeTR:create(time , scene)
    elseif type == "FadeUp" then
        -- 从下往上百叶窗
        return cc.TransitionFadeUp:create(time , scene)
    elseif type == "FlipAngularRight" then
        -- 向右翻转180度消失，向左翻转180度出现
        return cc.TransitionFlipAngular:create(time , scene, 0)
    elseif type == "FlipAngularLeft" then
        -- 向左翻转180度消失，向右翻转180度出现
        return cc.TransitionFlipAngular:create(time , scene, 1)
    elseif type == "FlipX" then
        -- 水平翻转
        return cc.TransitionFlipX:create(time , scene)
    elseif type == "FlipY" then
        -- 垂直翻转
        return cc.TransitionFlipY:create(time , scene)
    elseif type == "JumpZoom" then
        -- 跳走，在跳出来
        return cc.TransitionJumpZoom:create(time , scene)
    elseif type == "MoveInB" then
        -- 从下推上来
        return cc.TransitionMoveInB:create(time , scene)
    elseif type == "MoveInL" then
        -- 从左推出来
        return cc.TransitionMoveInL:create(time , scene)
    elseif type == "MoveInT" then
        -- 从上推下来
        return cc.TransitionMoveInT:create(time , scene)
    elseif type == "MoveInR" then
        -- 从右推出来
        return cc.TransitionMoveInR:create(time , scene)
    elseif type == "ProgressHorizontal" then
        --从左往右扫描屏幕，刷出新的场景 有点炫
        return cc.TransitionProgressHorizontal:create(time , scene)
    elseif type == "ProgressVertical" then
        -- 从上往下扫描屏幕，刷出新的场景 有点炫
        return cc.TransitionProgressVertical:create(time , scene)
    elseif type == "ProgressInOut" then
        -- 从中间扫描到四周，刷出新的场景 有点炫
        return cc.TransitionProgressInOut:create(time , scene)
    elseif type == "ProgressOutIn" then
        -- 从四周扫描到中间，刷出新的场景 有点炫
        return cc.TransitionProgressOutIn:create(time , scene)
    elseif type == "RotoZoom" then
        -- 旋转消失，再旋转出现。     有的炫
        return cc.TransitionRotoZoom:create(time , scene)
    elseif type == "ShrinkGrow" then
        -- 一个变小消失，一个变大出现
        return cc.TransitionShrinkGrow:create(time , scene)
    elseif type == "SlideInB" then
        -- 从下面感觉不出来跟MoveInB的区别滑出
        return cc.TransitionSlideInB:create(time , scene)
    elseif type == "SlideInL" then
        -- 感觉不出来跟MoveInL的区别
        return cc.TransitionSlideInL:create(time , scene)
    elseif type == "SlideInT" then
        -- 感觉不出来跟MoveInT的区别
        return cc.TransitionSlideInT:create(time , scene)
    elseif type == "SlideInR" then
        -- 感觉不出来跟MoveInR的区别
        return cc.TransitionSlideInR:create(time , scene)
    elseif type == "SplitCols" then
        -- 3列抽出消失，3列插入出现
        return cc.TransitionSplitCols:create(time , scene)
    elseif type == "SplitRows" then
        -- 2行抽出消失，2行插入出现
        return cc.TransitionSplitRows:create(time , scene)
    elseif type == "TurnOffTiles" then
        -- 随机很多小碎块出现 有点炫(但是相同场景有的像BUG)
        return cc.TransitionTurnOffTiles:create(time , scene)
    elseif type == "ZoomFlipX" then
        -- 跟FlipX的区别在翻的有深度
        return cc.TransitionZoomFlipX:create(time , scene)
    elseif type == "ZoomFlipY" then
        --  跟FlipY的区别在翻的有深度
        return cc.TransitionZoomFlipY:create(time , scene)
    elseif type == "ZoomFlipAngularLeft" then
        -- 跟FlipAngularLeft的区别在翻的有深度
        return cc.TransitionZoomFlipAngular:create(time , scene, 0)
    elseif type == "ZoomFlipAngularRight" then
        -- 跟FlipAngularRight的区别在翻的有深度
        return cc.TransitionZoomFlipAngular:create(time , scene, 1)
    end

    return scene
end

function EnterRoomEffectMgr:MSG_ENTER_ROOM(map)
    local cfg = EFFECT_CFG[map.enter_effect_index]
    if not cfg or not self.oldScene then
        return
    end

    self:startEffect(cfg)
end

function EnterRoomEffectMgr:MSG_PLAY_ENTER_ROOM_EFFECT(map)
    local cfg = EFFECT_CFG[map.key]
    if not cfg then
        return
    end

    self:initScene(true, map.key)

    self:startEffect(cfg)
end

MessageMgr:hook("MSG_ENTER_ROOM", EnterRoomEffectMgr, "EnterRoomEffectMgr")
MessageMgr:regist("MSG_PLAY_ENTER_ROOM_EFFECT", EnterRoomEffectMgr)