-- LoadingDlg.lua
-- Created by Chang_back May/11/2015
-- 加载地图界面

local LoadingDlg = Singleton("LoadingDlg", Dialog)
local CharAction = require ("animate/CharAction")
local PROGRESS_WIDTH = 600  -- 进度条宽度
local PERCENT_DATA = 50
local DATA_TIME = 0.3       -- 假数据加载的时间
local FPS_ADD_RATE = PERCENT_DATA / DATA_TIME / Const.FPS
local lastValue
local DLG_TYPE = {
    DLG_START  = 1,
    DLG_NORMAL = 2,
    DLG_USER   = 3,
}

-- 加载完之后需要调用的回调函数(只调用一次)
local onExitCallFunc = {

}

-- 需要加载的用户数据
local needLoadRes = {

}

-- 记录显示每一行的对象
local showLinesOBj = {

}

function LoadingDlg:init()

    -- 设置适配
    self:setFullScreen()

    local winSize = Const.WINSIZE
    local rootHeight = winSize.height / Const.UI_SCALE
    local rootWidth = winSize.width / Const.UI_SCALE
    self.progressBar = self:getControl("UpdateProgressBar", Const.UIProgressBar)

    -- 加载背景图
    local createBcak = ccui.ImageView:create(ResMgr:getRandomLoadingPic())
    createBcak:setPosition(winSize.width / 2  , winSize.height / 2)
    createBcak:setAnchorPoint(0.5,0.5)
    --createBcak:setLocalZOrder(-1)
    self.blank:addChild(createBcak)
    createBcak:setScale(1/ Const.UI_SCALE , 1/ Const.UI_SCALE )


    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(createBcak:getOrderOfArrival())
    createBcak:setOrderOfArrival(order)
    self.createBcak = createBcak

    -- 设置层级
    self.blank:setLocalZOrder(Const.LOADING_DLG_ZORDER)

    -- 当前要转换的地图信息
    self.map = nil
    PERCENT_DATA = math.random(10, 35)     -- 假数据加载到30%
    FPS_ADD_RATE = PERCENT_DATA / DATA_TIME / Const.FPS
    self.percentLabel = self:getControl("PercentLabel", Const.UILabel)
    self.secondRandom = false
    self.progressBar:setPercent(0)
    self.percentLabel:setString("0%")

    self.loadingDlgType = DLG_TYPE.DLG_NORMAL
    self.curRate = 0.0
    self.userLoadIndex = 1
    lastValue = self.curRate

    -- 随机加载tips
    local tipPanel = self:getControl("TipsPanel")
    tipPanel:setContentSize(rootWidth, tipPanel:getContentSize().height)
    local loadTips = MapMgr:getLoadMapTips()
    local randomNum = math.random(1, #loadTips)
    local tipsLabel = self:getControl("TipsLabel")
    local tips = loadTips[randomNum]["tips"]
    tipsLabel:setString(tips)
    self:setLabelText("TipsLabel_1", tips)

    -- 容错处理
    self:resetZOrder()

    -- 始终显示健康公告
    self:setCtrlVisible("HealthNoteLabel", true)

    self.root:requestDoLayout()
end

function LoadingDlg:close(now)
    if GAME_RUNTIME_STATE.MAIN_GAME ~= GameMgr:getGameState() then
        GameMgr:setGameState(GAME_RUNTIME_STATE.PRE_LOGIN)
    end
    Dialog.close(self, now)
end

-- 扫出一排字
function LoadingDlg:showOneLine(tip, posX, posY, node, func)
    local shaderLayer = cc.Layer:create()
    local wordLayer = cc.LayerGradient:create(cc.c4b(0, 0, 0, 0), cc.c4b(0, 0, 0, 255), cc.p(1, 0))
    local wordLabel = cc.Sprite:create(tip) -- cc.LabelTTF:create(tip, "Arial", 26)
    wordLabel:setPosition(posX, posY)
    local wordSize = wordLabel:getContentSize()
    wordLayer:setContentSize(wordSize.width / 4, wordSize.height)
    wordLayer:setPosition(0, 0)
    local wordLayerBk = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    wordLayerBk:setContentSize(wordSize.width, wordSize.height)
    wordLayerBk:setPosition(wordSize.width / 4, 0)
    shaderLayer:addChild(wordLayer)
    shaderLayer:addChild(wordLayerBk)
    node:addChild(wordLabel, 0)
    node:addChild(shaderLayer, 1)
    shaderLayer:setPosition(posX - wordSize.width / 2 - wordSize.width / 4, posY - wordSize.height / 2)

    local funcCall = cc.CallFunc:create(function()
        func()
        -- shaderLayer:removeFromParentAndCleanup(true)
    end)

    shaderLayer:runAction(cc.Sequence:create(cc.MoveBy:create(2, cc.p(wordSize.width + wordSize.width / 4, 0)), cc.DelayTime:create(0), funcCall, cc.RemoveSelf:create()))
    table.insert(showLinesOBj, wordLabel)
end

function LoadingDlg:setStartDlg()
    SoundMgr:setCanNotPlayEffect(true)

    -- 设置标志位
    self.loadingComplate = false
    self.loadingDlgType = DLG_TYPE.DLG_START

    -- 隐藏正常界面
    self.root:setVisible(false)

    if self.createBcak then
        self.createBcak:removeFromParent()
        self.createBcak = nil
    end

    -- 创建黑幕
    local bklayerD = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    local bkLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 255))
    local func = cc.CallFunc:create(function()
        self:showOneLine(ResMgr.ui.first_start_game1, Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2 + 75, bkLayer, function()
            self:showOneLine(ResMgr.ui.first_start_game2, Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2 - 35, bkLayer, function()
                for i = 1, #showLinesOBj do
                    local ctrl = tolua.cast(showLinesOBj[i], "cc.Sprite")
                    if nil ~= ctrl then
                        ctrl:runAction(cc.Sequence:create(cc.FadeOut:create(2)))
                    end
                end

                self.blank:runAction(cc.Sequence:create(cc.FadeOut:create(2.5), cc.CallFunc:create(function()
                    DlgMgr:closeDlg(self.name)
                    DlgMgr:openDlg("HeadDlg")
                    DlgMgr:openDlg("SystemFunctionDlg")
                    SoundMgr:setCanNotPlayEffect(false)
                end)))

                self.loadingComplate = true
            end)
        end)
    end)

    bklayerD:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    bkLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    bkLayer:setOpacity(50)
    bkLayer:runAction(cc.Sequence:create(cc.FadeIn:create(0.5), func))
    self.blank:addChild(bklayerD)
    self.blank:addChild(bkLayer)
end

function LoadingDlg:setUserDlg(data)
    self.loadingDlgType = DLG_TYPE.DLG_USER
    if nil ~= data then
        needLoadRes = data
    end
end

-- 开始播放动画
function LoadingDlg:showProgress(second)
    if self.progressBar == nil then return end
    performWithDelay(self.root, function()
        self.dirty = true
    end, second)

    -- 过图时隐藏小地图
    local smallMap = DlgMgr:getDlgByName("SmallMapDlg")

    if smallMap ~= nil then DlgMgr:closeDlg("SmallMapDlg") end

    PERCENT_DATA = math.random(10, 35)     -- 假数据加载到30%
    FPS_ADD_RATE = PERCENT_DATA / DATA_TIME / Const.FPS
    self.progressBar:setPercent(0)
    self.curRate = 0
    self.allow = true
    self.dirty = false
end

-- 容错处理，若发现ChatDlg出现，则打印错误信息且将其层级置零
function LoadingDlg:resetZOrder()
    local chatDlg = DlgMgr:getDlgByName("ChatDlg")
    if chatDlg ~= nil then
        local chatDlgZOrder = chatDlg.blank:getLocalZOrder()
        local loadingDlgZOrder = self.blank:getLocalZOrder()
        if chatDlgZOrder >= loadingDlgZOrder then
            -- 若出现ChatDlg层级高于LoadingDlg，则输出error
            assert(chatDlgZOrder < loadingDlgZOrder, CHS[3002914])
            Log:D(CHS[3002915] .. loadingDlgZOrder .. CHS[3002916] .. chatDlgZOrder)
            self.blank:setLocalZOrder(Const.LOADING_DLG_ZORDER)
            chatDlg.blank:setLocalZOrder(0)
        end
    end
end

-- 定时器
function LoadingDlg:onUpdate()
    -- 容错处理
    self:resetZOrder()

    -- 先隐藏其他对话框
    if not self.allow then return end

    if self.curRate >= 100 then
        if DLG_TYPE.DLG_START == self.loadingDlgType and not self.loadingComplate then
            -- 必须等待字出现完成之后才能执行后面的操作
            Log:D(">>>> waiting for show line word!")
            return
        end

        self.dirty = false
        self.curRate = 0.0

        local function checkEnd()
            -- 获取一个节点来作延迟
            local node = gf:getUILayer()
            performWithDelay(node, function()
                local map = GameMgr.scene.map

                local curMapCount = nil
                local totalBLockCount = nil
                if map then
                    curMapCount = map:getCurBlock()
                    totalBLockCount = map:getTotalBlock()
                else
                    curMapCount = 0
                    totalBLockCount = 0
                end

                if curMapCount < totalBLockCount then
                    checkEnd()
                    return
                end

                local zOrder = self.blank:getLocalZOrder()
                local dlgs = DlgMgr.dlgs


                -- 加载完成后检查下当前地图的怪物等级
                MapMgr:checkMapMonsterLevel()
                MapMgr.isLoadEnd = true

                -- 检测下回调函数
                repeat
                    local func = onExitCallFunc[#onExitCallFunc]
                    if "function" == type(func) then
                        func()
                        table.remove(onExitCallFunc, #onExitCallFunc)
                    end
                until #onExitCallFunc <= 0

                -- 检查过图自动寻路
                AutoWalkMgr:enterRoomContinueAutoWalk()

                Me:setLastWalkOrLoadMapTime(gfGetTickCount())

                if DLG_TYPE.DLG_START ~= self.loadingDlgType then
                    DlgMgr:closeDlg(self.name)
                end
            end, 0.3)
        end
        checkEnd()

        self.allow = false
        return
    end

    if DLG_TYPE.DLG_USER ~= self.loadingDlgType then
        if not self.dirty then
            -- 先让进度条跑
            if self.curRate < PERCENT_DATA then
                self.curRate = self.curRate + FPS_ADD_RATE
                if self.curRate > lastValue then
                    self.progressBar:setPercent(self.curRate)
                    lastValue = self.curRate
                end
                self.percentLabel:setString(tostring(math.floor(self.curRate)).."%")
            else
                -- 实现第二段假数据
                if not self.secondRandom then
                    self.secondRandom = true
                    performWithDelay(self.root, function()
                        if self.curRate + 10 >= 70 then
                            return math.max(self.curRate, 70)
                        else
                            PERCENT_DATA = math.random(self.curRate + 10, 70)
                        end
                    end, 0.3)
                end
            end
            return
        end

        -- 正常数据，只加载地图
        local map = GameMgr.scene.map

        local curMapCount = nil
        local totalBLockCount = nil
        if map then
            curMapCount = map:getCurBlock()
            totalBLockCount = map:getTotalBlock()
        else
            curMapCount = 0
            totalBLockCount = 0
        end

        if totalBLockCount <= 0 then
            self.dirty = false
            self.curRate = 0.0
            DlgMgr:closeDlg(self.name)
            return
        end
        local progress_value = curMapCount / totalBLockCount * 100
        if progress_value >= self.curRate then
            self.curRate = progress_value
        end
        if self.curRate > 100 then
            self.curRate = 100
        end
    end

    if DLG_TYPE.DLG_USER == self.loadingDlgType then
        -- 加载传进来的数据
        local count = #needLoadRes
        if self.userLoadIndex > count then
            -- 已经全部加载完了
            self.curRate = 100
        else
            -- 调用回调加载
            local func = needLoadRes[self.userLoadIndex]
            if "function" == type(func) then
                func()
            end

            self.curRate = self.userLoadIndex / count * 100
            self.userLoadIndex = self.userLoadIndex + 1
        end
    end
    self.progressBar:setPercent(self.curRate)
    self.percentLabel:setString(tostring(math.floor(self.curRate)).."%")
end

-- 注册过图完成后的回调函数
function LoadingDlg:registerExitCallBack(func)
    table.insert(onExitCallFunc, func)
end

function LoadingDlg:cleanup()
    onExitCallFunc = {}
    showLinesOBj = {}
end

return LoadingDlg
