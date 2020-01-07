-- DramaDlg.lua
-- Created by liuhb Mar/05/2015
-- 剧本对话显示界面

local DramaDlg = Singleton("DramaDlg", Dialog)

DramaDlg.OPER = {
    SKIP_SCENAROID    = 1,
    NEXT_SCENE        = 2,
    CLOSED            = 3,
}

local AUTO_DELAY = 20
local SCENAROID_END = 1
local MARGIN = 10
local isEnd = false
local hasNewOne = false

local curData = {}

local SHAPE_OFFSET = {
    [1273] = {imgOff = {y = -30, x = 0}, bonesOff = {y = -56, x = -20}},
    [1274] = {bonesOff = {y = -26, x = -20}},
    [6321] = {bonesOff = {y = -26, x = -20}}
}

-- 剧本人物头像透明度配置
local ICON_OPACITY_CFG = {
    [CHS[7190301]] = 153, -- 小童的魂魄
}

function DramaDlg:init()
    -- 终止自动寻路和自动遇敌
    AutoWalkMgr:cleanup()

    self:bindListener("SkipButton", self.onSkipButton)
    self:bindListener("TouchPanel", self.onNextScene)

    -- 切换下一幕操作
    self.turnToNextScene = false

    -- 根据分辨率适配屏幕
    local contentSize = self.root:getContentSize()
    self:setFullScreen()
    self:setCtrlVisible("OtherNameLabel", false)
    self:setCtrlVisible("OtherShapeImage", false)
    self.blank:setLocalZOrder(Const.ZORDER_TOPMOST)
    local winSize = self:getWinSize()
    local bkCtrl = self:getControl("BKPanel")
    bkCtrl:setContentSize(winSize.width / Const.UI_SCALE, bkCtrl:getContentSize().height)
    local dramaCtrl = self:getControl("DramaPanel")
    dramaCtrl:setContentSize(winSize.width / Const.UI_SCALE, dramaCtrl:getContentSize().height)

    local touchPanel = self:getControl("TouchPanel")
    touchPanel:setContentSize(cc.size(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE))
    touchPanel:setPosition(cc.p((-winSize.ox or 0 - (winSize.x or 0)), (-winSize.oy or 0) - (winSize.y or 0)))

    local screenPanel = self:getControl("LockScreenPanel")
    screenPanel:setContentSize(cc.size(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE))
    screenPanel:setPosition(cc.p((-winSize.ox or 0 - (winSize.x or 0)), (-winSize.oy or 0) - (winSize.y or 0)))

    -- 开始动画
    self:startAction()

    local x, y = self:getControl("ShapeImage", nil, "NpcNormalPanel"):getPosition()
    self.shapeImgPos = {x = x, y = y}
    x, y = self:getControl("ShapeChildPanel", nil, "NpcBonesPanel"):getPosition()
    self.shapeBonesPos = {x = x, y = y}

    self:hookMsg("MSG_PLAY_SCENARIOD")
end

function DramaDlg:startAction()
    self:closeAllAction()

    -- 黑幕
    local bkCtrl = self:getControl("BKPanel")
    local dramaCtrl = self:getControl("DramaPanel")
    self:setCtrlVisible("NpcPanel", false)

    -- 移动上面板
    bkCtrl:setAnchorPoint(cc.p(0, 1))
    bkCtrl:setPosition(0, Const.WINSIZE.height / Const.UI_SCALE + bkCtrl:getContentSize().height)
    local bkMoveAction = cc.MoveBy:create(0.3, cc.p(0, - bkCtrl:getContentSize().height))
    bkCtrl:stopAllActions()
    bkCtrl:runAction(bkMoveAction)

    -- 移动下面板
    local winSize = self:getWinSize()
    dramaCtrl:setPosition(0, -dramaCtrl:getContentSize().height - winSize.oy)
    dramaCtrl:setAnchorPoint(cc.p(0, 0))
    local dramaMoveAction = cc.MoveBy:create(0.3, cc.p(0, dramaCtrl:getContentSize().height))
    local func = cc.CallFunc:create(function()
        self.isOpenFinish = true
        self:setCtrlVisible("NpcPanel", true)
        Log:D(CHS[3002382])
        local winSize = self:getWinSize()
        if winSize and winSize.fullback then
            DlgMgr:setVisible(winSize.fullback, false)
        end
    end)

    dramaCtrl:stopAllActions()
    dramaCtrl:runAction(cc.Sequence:create(dramaMoveAction, func))

    self.blank.colorLayer:setVisible(false)
    local upPanel = self:getControl("LockScreenPanel")
    upPanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    local imageCtrl = self:getControl("LockScreenUpImage")
    imageCtrl:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, imageCtrl:getContentSize().height)
    imageCtrl = self:getControl("LockScreenDownImage")
    imageCtrl:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, imageCtrl:getContentSize().height)
end

function DramaDlg:closeAction()
    local bkCtrl = self:getControl("BKPanel")
    local dramaCtrl = self:getControl("DramaPanel")

    -- 移动上面板
    bkCtrl:setAnchorPoint(cc.p(0, 1))
    local bkMoveAction = cc.MoveBy:create(0.3, cc.p(0, bkCtrl:getContentSize().height))
    bkCtrl:runAction(bkMoveAction)

    -- 移动下面板
    local winSize = self:getWinSize()
    dramaCtrl:setAnchorPoint(cc.p(0, 0))
    local dramaMoveAction = cc.MoveBy:create(0.3, cc.p(0, -dramaCtrl:getContentSize().height - winSize.oy))
    local func = cc.CallFunc:create(function()
        self:setCtrlVisible("NpcPanel", false)

        Log:D(CHS[3002383])
    end)

    local func2 = cc.CallFunc:create(function()
        local winSize = self:getWinSize()
        if winSize and winSize.fullback then
            DlgMgr:setVisible(winSize.fullback, true)
        end

        self:FrozenScreen()

        local fadeOut1 = cc.FadeOut:create(0.2)
        local fadeOut2 = cc.FadeOut:create(0.2)
        local panel1 = self:getControl("NpcBonesPanel")
   --     panel1:runAction(fadeOut1)
        local panel2 = self:getControl("NpcNormalPanel")
        panel2:runAction(fadeOut2)
    end)

    local delay = cc.DelayTime:create(0.2)

    local func3 = cc.CallFunc:create(function()
        self:releaseBones()
    end)

    dramaCtrl:stopAllActions()
    dramaCtrl:runAction(cc.Spawn:create(cc.Sequence:create(func, dramaMoveAction, func3), func2))
end

function DramaDlg:cleanup()
    if nil ~= self.id then
        if not BattleSimulatorMgr:isRunning() and not isEnd then
            gf:CmdToServer("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.SKIP_SCENAROID, para = " " })
        end

        gf:CmdToServer("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.CLOSED, para = "" })
    end

    local winSize = self:getWinSize()
    if winSize and winSize.fullback then
        DlgMgr:setVisible(winSize.fullback, true)
    end


    -- 显示所有按钮,区分战斗中跟战斗外
    if not Me:isInCombat() and not Me:isLookOn() then
        if HomeChildMgr:isInDailyTask() then
        else
            DlgMgr:setAllDlgVisible(true)
        end
    else
        FightMgr:openFightDlgs()
    end

    self.id = nil
    isEnd = nil
    hasNewOne = nil
    curData = {}
    self.totalDelay = nil

    -- 删除NPC脚底的光效
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    self:releaseBones()
end

function DramaDlg:releaseBones()
    -- 如果有骨骼动画时，释放相关资源
    local panel = self:getControl("ShapeChildPanel")
    local magic = panel:getChildByName("charPortrait")

    if magic then
        DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
    end

    panel:removeAllChildren()
end

function DramaDlg:updateView(data)
    curData = data
    self.id = data.id
    self.content = data.content

    -- 剧本播放结束
    if SCENAROID_END == data.isComplete then
        -- 如果处于战斗
        if Me:isInCombat() or Me:isLookOn() then
            self:closeAction()
        end

        isEnd = data.isComplete
        return
    end

    -- 判断是否处于战斗中
    local ctrl = self:getControl("SkipButton")
    --[[
    if 1 == curData.isInCombat then
        self:setCtrlVisible("SkipImage_1", false)
        self:setCtrlVisible("SkipNoteLabel", false)
        ctrl:setVisible(false)
    else
        self:setCtrlVisible("SkipImage_1", true)
        self:setCtrlVisible("SkipNoteLabel", true)
        ctrl:setVisible(true)
    end
    ]]
    local visible = (1 ~= curData.isInCombat or nil ~= GFightMgr.SkipSyncMessage) and not BattleSimulatorMgr:isRunning()
    self:setCtrlVisible("SkipImage_1", visible)
    self:setCtrlVisible("SkipNoteLabel", visible)
    ctrl:setVisible(visible)

    -- 设置中间对话内容
    local textLableCtrl = self:getControl("Panel_21")
    local box = textLableCtrl:getContentSize()
    local width = Const.WINSIZE.width / Const.UI_SCALE - textLableCtrl:getPositionX() + box.width / 2 - 100 * Const.UI_SCALE
    box.width = box.width * (Const.WINSIZE.width / Const.UI_DESIGN_WIDTH)
    local tip = CGAColorTextList:create()
    if data.portrait ~= 0 then
        tip:setDefaultColor(COLOR3.DRAMA_TEXT_DEFAULT.r, COLOR3.DRAMA_TEXT_DEFAULT.g, COLOR3.DRAMA_TEXT_DEFAULT.b)
    else
        tip:setDefaultColor(COLOR3.BLUE.r, COLOR3.BLUE.g, COLOR3.BLUE.b)
    end

    tip:setFontSize(25)
    --tip:setContentSize(width, 0)
    if tip.setPunctTypesetting then
        tip:setPunctTypesetting(true)
    end
    tip:setContentSize(box.width, 0)
    tip:setString(data.content, true)
    tip:setPosition(MARGIN, box.height)
    tip:updateNow()
    textLableCtrl:removeAllChildren()
    textLableCtrl:addChild(tolua.cast(tip, "cc.LayerColor"))

    self:setLabelText("ContentLabel", "")

    self:setCtrlVisible("NpcBonesPanel", false)
    self:setCtrlVisible("NpcNormalPanel", false)

    -- 设置对方的头像及名字
    if data.portrait ~= 0 then
        local bonesPath, texturePath = ResMgr:getBonesCharFilePath(data.portrait)
        local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
        local showName = gf:getRealName(data.name)
        local portrait
        if bExist then
            local portraitsPanel = self:getControl("NpcBonesPanel")
            portraitsPanel:setVisible(true)
            portrait = self:creatCharDragonBones(data.portrait, "ShapeChildPanel")
            self:setLabelText("NameLabel_1", showName, portraitsPanel)
            self:setLabelText("NameLabel_2", showName, portraitsPanel)

            -- 对形象做偏移
            local shapePanel = self:getControl("ShapeChildPanel", nil, portraitsPanel)
            local offsets = SHAPE_OFFSET[data.portrait]
            if offsets and offsets.bonesOff then
                local offset = offsets.bonesOff
                shapePanel:setPosition(self.shapeBonesPos.x + offset.x, self.shapeBonesPos.y + offset.y)
            else
                shapePanel:setPosition(self.shapeBonesPos.x, self.shapeBonesPos.y)
            end
        else
            local portraitsPanel = self:getControl("NpcNormalPanel")
            portraitsPanel:setVisible(true)
            portraitsPanel:setOpacity(255)
            portraitsPanel:stopAllActions()
            self:setLabelText("NameLabel_1", showName, portraitsPanel)
            self:setLabelText("NameLabel_2", showName, portraitsPanel)
            local iconPath = ResMgr:getBigPortrait(data.portrait)
            self:setImage("ShapeImage", iconPath, portraitsPanel)
            self:setCtrlVisible("ShapeImage", true, portraitsPanel)
            self:setCtrlVisible("NamePanel", true, portraitsPanel)
            self:updateLayout("ShapePanel", portraitsPanel)

            -- 对形象做偏移
            local img = self:getControl("ShapeImage", nil, portraitsPanel)
            local offsets = SHAPE_OFFSET[data.portrait]
            if offsets and offsets.imgOff then
                local offset = offsets.imgOff
                img:setPosition(self.shapeImgPos.x + offset.x, self.shapeImgPos.y + offset.y)
            else
                img:setPosition(self.shapeImgPos.x, self.shapeImgPos.y)
            end

            portrait = img
        end

        if ICON_OPACITY_CFG[data.name] then
            -- 配置了透明度则更新头像透明度
            portrait:setOpacity(ICON_OPACITY_CFG[data.name])
        end
    else
        self:setCtrlVisible("ShapeImage", false, "NpcBonesPanel")
        self:setCtrlVisible("NamePanel", false, "NpcBonesPanel")

        self:setCtrlVisible("ShapeImage", false, "NpcNormalPanel")
        self:setCtrlVisible("NamePanel", false, "NpcNormalPanel")
    end
end

function DramaDlg:creatCharDragonBones(icon, panelName)
    local panel = self:getControl(panelName)
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return magic
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end

    panel:removeAllChildren()

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5 + 16, 26)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    return magic
end

function DramaDlg:onSkipButton(sender, eventType)
    if nil == self.id then return end

    -- 如果已经是结束，点击关闭
    if SCENAROID_END == isEnd then
        -- WDSY-1876增加，WDSY-10750删除
        -- 在关闭剧本的动画过程，点击跳过会进入该分支，导致在普通场景会打开战斗相关的界面
        -- FightMgr:openFightDlgs()

        -- 显示所有按钮
        if not Me:isInCombat() and not Me:isLookOn() then
            if HomeChildMgr:isInDailyTask() then
            else
                DlgMgr:setAllDlgVisible(true)
            end
        else
            FightMgr:openFightDlgs()
        end

        isEnd = nil
        return
    end

    if not BattleSimulatorMgr:isRunning() then
        gf:CmdToServer("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.SKIP_SCENAROID, para = "" })
    else
        BattleSimulatorMgr:sendCombatDoActionToBattleSimulator("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.SKIP_SCENAROID, para = " " })
    end

    if 1 == curData.isInCombat then
        -- 战斗中跳过剧本
        GFightMgr:SkipSyncMessage(0xB000)
    end

    gf:CmdToServer("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.CLOSED, para = "" })

    self.id = nil
    isEnd = nil
    DlgMgr:closeDlg(self.name)

    -- 显示所有按钮
    if not Me:isInCombat() and not Me:isLookOn() then
        TaskMgr:continueTaskAutoWalk()
        if HomeChildMgr:isInDailyTask() then
        else
            DlgMgr:setAllDlgVisible(true)
        end
    else
        FightMgr:openFightDlgs()
    end
end

function DramaDlg:onNextScene(sender, eventType)
    if nil == self.id then return end

    -- 如果已经是结束，点击关闭
    if SCENAROID_END == isEnd then
        self:FrozenScreen()
        return
    end

    self.lastClickTime = gfGetTickCount()
    self.turnToNextScene = true
    if not BattleSimulatorMgr:isRunning() then
        gf:CmdToServer("CMD_OPER_SCENARIOD", {id = self.id, type = self.OPER.NEXT_SCENE, para = "" })
    else
        -- 这个地方type需要发送为 1， 特殊用法
        BattleSimulatorMgr:sendCombatDoActionToBattleSimulator("CMD_OPER_SCENARIOD", {id = self.id, type = 1, para = "" })
    end
end

function DramaDlg:FrozenScreen()
    if not self.totalDelay then
        self.frozenStartTime = gfGetTickCount()
        self.totalDelay = 3
    end

    -- 剧本已经开始关闭操作，再次冻屏时，如果超过totalDelay，则不用重新冻屏了，等上一次冻屏操作完成即可
    if gfGetTickCount() - self.frozenStartTime >= self.totalDelay * 1000 then return end

    local func = cc.CallFunc:create(function()
        local funcClose = cc.CallFunc:create(function()
            if hasNewOne then
                return
            end

            self.totalDelay = nil
            DlgMgr:closeDlg(self.name)

            -- 显示所有按钮
            if not Me:isInCombat() and not Me:isLookOn() then
                if HomeChildMgr:isInDailyTask() then
                else
                    DlgMgr:setAllDlgVisible(true)
                end
            else
                FightMgr:openFightDlgs()
            end
        end)

        -- 两块黑底淡出效果
        local fadeOut = cc.FadeOut:create(0.5)
        local imageCtrl = self:getControl("LockScreenPanel")

        imageCtrl:stopAllActions()
        imageCtrl:runAction(cc.Sequence:create(fadeOut, funcClose))
    end)

    local delayTime = math.min(math.max(0, self.totalDelay * 1000 - (gfGetTickCount() - self.frozenStartTime)) / 1000, 0.3)
    local action = cc.Sequence:create(cc.DelayTime:create(delayTime), func)
    self.root:stopAllActions()
    self.root:runAction(action)
end

-- 停止所有的动作
function DramaDlg:closeAllAction()
    self:stopAllAction("BKPanel")
    self:stopAllAction("DramaPanel")
    self:stopAllAction("LockScreenPanel")
    self:stopAllAction(self.root)
end

function DramaDlg:MSG_PLAY_SCENARIOD(data)
    if not DlgMgr:isDlgOpened(self.name) then
        return
    end

    self:updateView(data)
    self.turnToNextScene = false

    self.totalDelay = nil
    if SCENAROID_END == data.isComplete then
        hasNewOne = false
        self:closeAction()
        DlgMgr:sendMsg("GameFunctionDlg", "openFastUseDlg")

        -- 剧本播完自动寻路
        TaskMgr:continueTaskAutoWalk()
        --TaskMgr:doAutoWalkByTask(TaskMgr:getTaskByName(data.task_type))
        return
    end

    if isEnd and not hasNewOne then
        self:startAction()
    end

    hasNewOne = true
    isEnd = false

    -- 使用定时器，绑定在root下，进行20秒自动翻页
    local delay = cc.DelayTime:create(data.playTime or AUTO_DELAY)
    local func = cc.CallFunc:create(function() self:onNextScene() end)
    local action  = cc.Sequence:create(delay, func)

    self.root:stopAllActions()
    self.root:runAction(action)
end

function DramaDlg:getDramaState()
    return isEnd
end

-- 获取是否处于从这一幕到下一幕的过渡时间
function DramaDlg:isTurnToNextScene()
    return self.turnToNextScene
end

-- 只显示上下黑幕
function DramaDlg:juestShowBlackBackground()
    self:setCtrlVisible("NpcNormalPanel", false, "DramaPanel")
    self:setCtrlVisible("NpcBonesPanel", false, "DramaPanel")
    self:setCtrlVisible("NoteLabel", false, "BKPanel")
    self:setCtrlVisible("SkipPanel", false, "BKPanel")
end

return DramaDlg
