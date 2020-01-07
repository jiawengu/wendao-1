-- Dialog.lua
-- created by cheny Oct/14/2014
-- 对话框基类

Dialog = Singleton("Dialog")
local CharAction = require ("animate/CharAction")
local CharActionEx = require ("animate/CharActionEx")
local NumImg = require('ctrl/NumImg')

Dialog.TAG_PORTRAIT = 100
Dialog.TAG_PORTRAIT1 = 101
Dialog.TAG_ACTION_CLOSE = 9999
Dialog.TAG_COLORTEXT_CTRL = 102

Dialog.TAG_NUM_IMG = 111  --定义NumImg的tag
local ARTS_NUM_FONT_DEFAULT = 25 -- 默认美术数字大小

local BLANK_COLOR = cc.c4b(0, 0, 0, 153)
local CTR_BLANK_TAG = 4000766
local MOVE_DISTANCE = 20

local CHECK_DLG_JSON = gf:gfIsFuncEnabled(FUNCTION_ID.CHECK_DLG_JSON_EXIST)

local DEVICE_NAME = DeviceMgr:getDeviceString()
local LIGHT_EFFECT = require(ResMgr:getCfgPath('LightEffect'))
local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))

-- 需要在显示最下面的对话框（包括主界面，战斗界面）

local NEED_SHOW_ON_FLOOR =
    {
        ["GameFunctionDlg"] = -1,
        ["HeadDlg"]             = -1,
        ["ChatDlg"]             = -1,
        ["SystemFunctionDlg"]   = -1,
        ["MissionDlg"]          = -1,
        ["FightInfDlg"]         = -1,
        ["FightPetMenuDlg"] = -1,
        ["FightPetSkillDlg"] = -1,
        ["FightPlayerMenuDlg"] = -1,
        ["FightPlayerSkillDlg"] = -1,
        ["FightRoundDlg"] = -1,
        ["JiuTianBuffDlg"] = -1,
        ["FightTargetChoseDlg"] = -1,
        ["FightUseResDlg"] = -1,
        ["AutoFightSettingDlg"] = -1,
        ["CombatViewDlg"] = -1,
        ["SkillStatusDlg"] = -1,
        ["ScreenRecordingDlg"] = -1,
        ["FightLookOnDlg"] = -1,
        ["HomeFishingDlg"] = -1,
        ["ZhiDuoXingDlg"] = -1,
        ["SouxlpSmallDlg"] = -1,
        ["KuafjjgnDlg"] = -1,
        ["WorldBossLifeDlg"] = -1,
        ["VacationTempDlg"] = -1,
        ["QuanmPK2InfoDlg"] = -1,
        ["WenquanDlg"] = - 1,
        ["FightChildSkillDlg"] = - 1,
    }

local NO_NEED_TO_DELAY_RED_DOT =
{
    ["ActivitiesDlg"] = true,
    ["ZaixqyDlg"] = true,
    ["CallBackDlg"] = true,
    ["WelfareDlg"] = true,
    ["TradingSpotTabDlg"] = true,
}

--[[
function Dialog:init()
end

function Dialog:cleanup()
end

function Dialog:onUpdate()
end]]

-- 派生对象中可通过重新该函数来实现共用对话框配置
function Dialog:getCfgFileName()
    return ResMgr:getDlgCfg(self.name)
end

function Dialog:hideBlankLayer()  -- 移除对话框的背景蒙灰效果
    self.isBlankLayerHide = true
end

function Dialog:setDialogType(isSwallow, isClose)
    if type(isSwallow) == "table" then
        self.isSwallow = isSwallow[1]
        self.isClose = isSwallow[2]
        return
    end
    self.isSwallow = isSwallow
    self.isClose = isClose
end

-- 设置对话框 zorder
function Dialog:setDlgZOrder(zorder)
    if self.blank then
        self.blank:setLocalZOrder(zorder)
    end
end

function Dialog:getDlgZOrder()
    if self.blank then
        return self.blank:getLocalZOrder()
    end
end


-- 该接口打开对话框，不做任何处理，不初始化，json中显示怎样就怎样，如果界面已经打开，则不处理
function Dialog:openForGm()
    -- 获取对话框状态，默认普通对话框
    if nil == self.isSwallow and nil == self.isClose then
        self:setDialogType(false, true)
    end

    local isSwallow = self.isSwallow
    local isClose = self.isClose

    -- 创建触摸处理层，实现对话框分类的关键
    self.blank = ccui.Layout:create()
    self.blank:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    if NEED_SHOW_ON_FLOOR[self.name] then
        self.blank:setLocalZOrder(NEED_SHOW_ON_FLOOR[self.name])
    end

    if not isSwallow and not self.isBlankLayerHide then  -- 当isBlankLayerHide为真，不生成背景蒙灰的效果
        local colorLayer = cc.LayerColor:create(BLANK_COLOR)
        colorLayer:setContentSize(self.blank:getContentSize())
        self.blank:addChild(colorLayer)
        self.blank.colorLayer = colorLayer
    end

    -- 响应 函数
    local function onDealTouch(sender, event)
        if self:isVisible() then
            -- 关闭窗口
            if isClose then
                if self.clickOutCallFunc then
                    self.clickOutCallFunc(self)
                    if self.callFuncOnce then
                        self.clickOutCallFunc = nil
                        self.callFuncOnce = nil
                    end
                end

                if "NpcDlg" == self.name then
                    gf:CmdToServer("CMD_CLOSE_MENU", {id = self.npc_id})
                end

                self:onCloseButtonForGm()
            end
        else
            return false
        end

        return true
    end

    if not gf:getUILayer() then
        local logMsg = {}
        table.insert(logMsg, "error:uiLayer is nil")
        if GameMgr and GameMgr.scene then
            table.insert(logMsg, "curScene:" .. tostring(GameMgr.scene:getType()))
        end
        table.insert(logMsg, tostring(__last_cleanup_top_layer))
        gf:ftpUploadEx(table.concat(logMsg, '\n'))
    end

    -- 添加监听
    if self.blank then
        -- 创建监听事件
        local listener = cc.EventListenerTouchOneByOne:create()

        -- 设置是否需要传递
        listener:setSwallowTouches(not isSwallow)
        listener:registerScriptHandler(onDealTouch, cc.Handler.EVENT_TOUCH_BEGAN)

        -- 添加监听
        local dispatcher = self.blank:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self.blank)
        gf:getUILayer():addChild(self.blank)
    end

    -- 创建对话框节点
    local cfgFile = self:getCfgFileName()
    if CHECK_DLG_JSON or cc.FileUtils:getInstance():isFileExist(cfgFile) then
        self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    end
    if not self.root then
        -- 文件不存在，异常情况
        -- 尝试关闭界面
        pcall(function()
            self:close()
        end)
        return
    end

    -- 注册onUpdate
    self:registOnUpdate()

    self.blank:addChild(self.root)

    if DeviceMgr:getUIScale() then
        self:align(ccui.RelativeAlign.centerInParent, DeviceMgr:getUIScale())
    else
    self:align(ccui.RelativeAlign.centerInParent)
    end

    self:bindListener("CloseButton", self.onCloseButtonForGm)

    -- WDSY-29527 修改
    self:sortAllChildren(self.blank)
end

function Dialog:registOnUpdate()
    if self.onUpdate and 'function' == type(self.onUpdate) then
        self.root:scheduleUpdateWithPriorityLua(function(delayTime) self:onUpdate(delayTime) end, 0)
    end
end

function Dialog:sortAllChildren(ctrl)
    if ctrl and 'function' == type(ctrl.sortAllChildren) then
        ctrl:sortAllChildren()

        local childs = ctrl:getChildren()
        for i = 1, #childs do
            self:sortAllChildren(childs[i])
        end
    end
end

-- 打开界面文件
function Dialog:open(param)
    -- 获取对话框状态，默认普通对话框
    if nil == self.isSwallow and nil == self.isClose then
        self:setDialogType(false, true)
    end

    local isSwallow = self.isSwallow
    local isClose = self.isClose

    -- 创建触摸处理层，实现对话框分类的关键
    self.blank = ccui.Layout:create()
	self.blank:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    if NEED_SHOW_ON_FLOOR[self.name] then
        self.blank:setLocalZOrder(NEED_SHOW_ON_FLOOR[self.name])
    end

    if not isSwallow and not self.isBlankLayerHide then  -- 当isBlankLayerHide为真，不生成背景蒙灰的效果

        local colorLayer = cc.LayerColor:create(BLANK_COLOR)
        colorLayer:setContentSize(self.blank:getContentSize())
        self.blank:addChild(colorLayer)
        self.blank.colorLayer = colorLayer
    end

    -- 响应 函数
    local function onDealTouch(sender, event)
        if self:isVisible() then
            -- 关闭窗口
            if isClose then
                if self.clickOutCallFunc then
                    self.clickOutCallFunc(self)
                    if self.callFuncOnce then
                        self.clickOutCallFunc = nil
                        self.callFuncOnce = nil
                    end
                end

                if "NpcDlg" == self.name then
                    gf:CmdToServer("CMD_CLOSE_MENU", {id = self.npc_id})
                end

                if DlgMgr:getMutexLevel(self.name) == DlgMgr.DLG_TYPE.NORMAL_NO_EFFECT_FOR_CLICK_BLANK then
                else

                    if self.onClickBlank and self:onClickBlank() then
                        -- 如果界面有 onClickBlank 并且返回true，则不期望关闭界面
                    else
                        self:onCloseButton()
                    end
                end
            end
        else
            return false
        end

        return true
    end

    if not gf:getUILayer() then
        local logMsg = {}
        table.insert(logMsg, "error:uiLayer is nil")
        if GameMgr and GameMgr.scene then
            table.insert(logMsg, "curScene:" .. tostring(GameMgr.scene:getType()))
        end
        table.insert(logMsg, tostring(__last_cleanup_top_layer))
        gf:ftpUploadEx(table.concat(logMsg, '\n'))
    end

    -- 添加监听
    if self.blank then
        -- 创建监听事件
        local listener = cc.EventListenerTouchOneByOne:create()

        -- 设置是否需要传递
        listener:setSwallowTouches(not isSwallow)
        listener:registerScriptHandler(onDealTouch, cc.Handler.EVENT_TOUCH_BEGAN)

        -- 添加监听
        local dispatcher = self.blank:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, self.blank)
        gf:getUILayer():addChild(self.blank)
    end

    -- 创建对话框节点
    local cfgFile = self:getCfgFileName()
    if CHECK_DLG_JSON or cc.FileUtils:getInstance():isFileExist(cfgFile) then
    self.root = ccs.GUIReader:getInstance():widgetFromJsonFile(cfgFile)
    end
    if not self.root then
        -- 文件不存在，异常情况
        -- 尝试关闭界面
        pcall(function()
            self:close()
        end)
        return
    end
    if self.onUpdate and 'function' == type(self.onUpdate) then
        self.root:scheduleUpdateWithPriorityLua(function(delayTime) self:onUpdate(delayTime) end, 0)
    end

    self.blank:addChild(self.root)

    -- 创建对话框名字节点
    if ATM_IS_DEBUG_VER then
        self:refreshDlgNamePanel(true)
        EventDispatcher:addEventListener("CONST.SHOW_DLG_NAME", self.refreshDlgNamePanel, self)
    end

    if DeviceMgr:getUIScale() then
        self:align(ccui.RelativeAlign.centerInParent, DeviceMgr:getUIScale())
    else
    self:align(ccui.RelativeAlign.centerInParent)
    end

    self:bindListener("CloseButton", self.onCloseButton)

    if self.init and 'function' == type(self.init) then
        if ATM_IS_DEBUG_VER then
            xpcall(function() self:init(param) end, __G__TRACKBACK__)
        else
            self:init(param)
        end
    end

    -- WDSY-29527 修改
    self:sortAllChildren(self.blank)

    -- 保存下原来的坐标位置，用来还原坐标
    self.originPos = {}
    self.originPos.x, self.originPos.y = self.root:getPosition()

    -- 全部初始化完了，可以加上小红点了
    -- 如果是动态加载的，那只能交由对话框自己处理了
    local function loadRedDot()
        local redDotList = RedDotMgr:getRedDotList(self.name)
        local blinkList = RedDotMgr:getBlinkRedDotList(self.name) or {}
        if nil ~= redDotList then
            for v, k in pairs(redDotList) do
                if not (self:isTabDlg() and self:getCurSelectCtrlName() == k) then
                    self:addRedDot(k, nil, blinkList[k])
                else
                    RedDotMgr:removeOneRedDot(self.name, k, self.root)
                end
            end
        end
    end

    if NO_NEED_TO_DELAY_RED_DOT[self.name] then
        -- 某些对话框延迟一帧增加小红点，会导致小红点延迟出现(例如ActivitiesDlg)
        -- 我们无法肯定非tabDlg的对话框都不需要延迟，所以此处仅对目前有此需求的对话框进行特殊处理
        loadRedDot()
    else
        -- tabDlg的当前选中信息还没初值化，所以需要延迟一帧
        performWithDelay(self.blank, loadRedDot, 0)
    end

    -- 打开对话需要参数
    local dlgName, param =  AutoWalkMgr:getOpenDlgParam()

    if dlgName and param then
        if dlgName == self.name then
            self:onDlgOpened(param)
            AutoWalkMgr:clearOpenDlgParam()
        end
    end
end

function Dialog:refreshDlgNamePanel(showMiscMsg)
    if not ATM_IS_DEBUG_VER then return end

    if not self.nameLabel then
        self.nameLabel = ccui.Text:create()
        self.nameLabel:setFontSize(21)
        self.nameLabel:setColor(cc.c3b(255, 0, 0))
        self.nameLabel:setString(self.name)
        self.nameLabel:setAnchorPoint(0, 0)
        self.root:addChild(self.nameLabel)
    end

    if Const.showDlgName then
        self.nameLabel:setVisible(true)
        if showMiscMsg then
            ChatMgr:sendMiscMsg(string.format(CHS[7100161], self.name))
        end
    else
        self.nameLabel:setVisible(false)
    end
end

-- 设置点击窗口外回调函数
-- func 函数
-- once 是否只生效一次
function Dialog:setClickOutCallBack(func, once)
    self.clickOutCallFunc = func
    self.callFuncOnce = once
end

-- 重新打开界面，实际上是为了调整其在UILayer中的顺序
function Dialog:reopen()
    if self.blank == nil then
        self:open()
    else
        self.blank:stopActionByTag(Dialog.TAG_ACTION_CLOSE)

        -- 由于调用 reorderChild 时如果 z-order 没有变化则不会触发 EventDispatcher 对监听者重新排序
        -- 故需要先修改一下 zOrder
        local zOrder = self:getDlgZOrder()
        self:setDlgZOrder(zOrder + 1)
        gf:getUILayer():reorderChild(self.blank, zOrder)

        gf:getUILayer():sortAllChildren()
    end
end

-- 是否为标签页界面
function Dialog:isTabDlg()
    return false
end

-- hook 通讯模块的 Msg
-- 以 msg 作为回调的函数名
function Dialog:hookMsg(msg)
    MessageMgr:hook(msg, self, self.name)
end

-- 取消该对象所有的 hook 消息
function Dialog:unhookMsg()
    MessageMgr:unhookByHooker(self.name)
end

-- 取消关注事件
function Dialog:removeAllEventListener()
    self:setCloseDlgWhenRefreshUserData(false)
    self:setCloseDlgWhenEnterCombat(false)
end

-- 设置界面的可见性
function Dialog:setVisible(show)
    if self.blank then
        self.blank:setVisible(show)
    end
end

function Dialog:isVisible()
    if nil == self.blank then return true end
    return self.blank:isVisible()
end

-- 设置控件的可见性
function Dialog:setCtrlVisible(ctrlName, visible, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setVisible(visible)
    end

    return ctrl
end

function Dialog:setCtrlFlip(ctrlName, flipX, flipY, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if flipX ~= nil then
        ctrl:setFlippedX(flipX)
    end

    if flipY ~= nil then
        ctrl:setFlippedY(flipY)
    end
end


function Dialog:getCtrlVisible(ctrlName, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        return ctrl:isVisible()
    end
end

function Dialog:setCtrlOnlyEnabled(ctrlName, enabled, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setEnabled(enabled)
    end
end

-- 设置控件的可用性
function Dialog:setCtrlEnabled(ctrlName, enabled, root, allowClick, useBright)
    local ctrl = self:getControl(ctrlName, nil, root)
    if ctrl then
        ctrl:setEnabled(enabled or allowClick)

        ctrl.isGray = false

        if not useBright then
            if enabled then
                gf:resetImageView(ctrl)
            else
                gf:grayImageView(ctrl)
                ctrl.isGray = true
            end
        else
            ctrl:setBright(enabled)
        end
    end
end

-- 获取窗口安全区域
function Dialog:getWinSize()
    local winSize = DeviceMgr:getUIScale() or { width = Const.WINSIZE.width, height = Const.WINSIZE.height, x = 0, y = 0, ox = 0, oy = 0 }
    return winSize
end

-- 设置对话框全屏
function Dialog:setFullScreen()
    local winsize = DeviceMgr:getUIScale() or { width = Const.WINSIZE.width / Const.UI_SCALE, height = Const.WINSIZE.height / Const.UI_SCALE }
    self.root:setContentSize(winsize.width, winsize.height)
    self.root:requestDoLayout()
end

-- 设置对话框中控件全屏
-- 控件有效区域全屏
function Dialog:setCtrlFullScreen(ctrlName, root)
    local winsize = DeviceMgr:getUIScale() or { width = Const.WINSIZE.width / Const.UI_SCALE, height = Const.WINSIZE.height / Const.UI_SCALE }

    local panel
    if 'string' == type(ctrlName) then
        panel = self:getControl(ctrlName, nil, root)
    else
        panel = ctrlName
    end
    if not panel then return end
    panel:setContentSize(winsize.width, winsize.height)
    if panel.requestDoLayout then
    panel:requestDoLayout()
    end
end

-- 设置对话框中控件全屏
-- 控件屏幕全屏
function Dialog:setCtrlFullClient(ctrlName, root, isKeepSize, dontDoLayout)
    local winsize = DeviceMgr:getUIScale() or { width = Const.WINSIZE.width / Const.UI_SCALE, height = Const.WINSIZE.height / Const.UI_SCALE, x = 0, y = 0, ox = 0, oy = 0 }

    local panel
    if 'string' == type(ctrlName) then
        panel = self:getControl(ctrlName, nil, root)
    else
        panel = ctrlName
    end
    if not panel then return end
    if not isKeepSize then
        local curSize = panel:getContentSize()
        panel:setContentSize(winsize.width + winsize.ox * 2, winsize.height + winsize.oy * 2)
        local newSize = panel:getContentSize()
        local cx, cy = panel:getPosition()
        panel:setPosition(cx + (newSize.width - curSize.width) * (panel:getAnchorPoint().x - 0.5), cy + (newSize.height - curSize.height) * (panel:getAnchorPoint().y - 0.5))
    end

    local ox, oy = winsize.x or 0, winsize.y or 0
    ox, oy = ox / Const.UI_SCALE, oy / Const.UI_SCALE
    local x, y = panel:getPosition()
    panel:setPosition(x - ox, y - oy)

    if panel.requestDoLayout and not dontDoLayout then
        panel:requestDoLayout()
    end
end

-- 将控件下的子控件都设置为屏幕全屏
function Dialog:setCtrlFullClientEx(ctrlName, root, isKeepSize)
    local panel
    if 'string' == type(ctrlName) then
        panel = self:getControl(ctrlName, nil, root)
    else
        panel = ctrlName
    end
    if not panel then return end

    panel:setLayoutType(0) -- 调整为绝对布局

    local children = panel:getChildren()
    for i = 1, #children do
        if children[i] then
            self:setCtrlFullClient(children[i], nil, isKeepSize, true)
        end
    end

    if panel.requestDoLayout then
        panel:requestDoLayout()
    end
end

-- 对齐（使用ccui.RelativeAlign）
function Dialog:align(relativeAlign, offset)
    gf:align(self.root, Const.WINSIZE, relativeAlign)
    local ox, oy = 0, 0
    if offset then
        ox, oy = offset.x or 0, offset.y or 0
    end

    local winsize = DeviceMgr:getUIScale() or { designWidth = Const.WINSIZE.width / Const.UI_SCALE, designHeight = Const.WINSIZE.height / Const.UI_SCALE }
    if ox < 0 then
        ox = ox - (Const.WINSIZE.width - winsize.designWidth) / 2
    elseif ox > 0 then
        ox = ox + (Const.WINSIZE.width - winsize.designWidth) / 2
    end

    if oy < 0 then
        oy = oy - (Const.WINSIZE.height - winsize.designHeight) / 2
    elseif oy > 0 then
        oy = oy + (Const.WINSIZE.height - winsize.designHeight) / 2
    end

    local pos = cc.p(self.root:getPositionX() + ox, self.root:getPositionY() + oy)
    self:setPosition(pos)
end

-- 设置对话框位置
-- 相对于设计分别率的位置(以左下顶点为基准)
function Dialog:setPosition(pos)
    if not self.root then
        return
    end

    -- 由于 ui 可能会进行缩放处理,故这里需要先除以缩放比例
    self.root:setPosition(pos.x / Const.UI_SCALE, pos.y / Const.UI_SCALE)
end

function Dialog:bindTouchEventListener(ctrl, func, data)
    if not ctrl then
        Log:W("Dialog:bindTouchEventListener no control ")
        return
    end

    local ctrlName = ctrl:getName()

    -- 事件监听
    local function listener(sender, eventType)
        -- 添加 log 以方便核查崩溃问题
        local str = self.name .. ':' .. tostring(ctrlName) .. ' receive event:' .. tostring(eventType)
        Log:I(str)
        if eventType == ccui.TouchEventType.began then
            -- 记录点击时是否打开WaitDlg
            self.beganWaitDlgIsNotOpen = not DlgMgr:isDlgOpened("WaitDlg")
            func(self, sender, eventType)
        elseif eventType == ccui.TouchEventType.ended then
            -- 控件长按过程中断线，则不进行后续事件处理
            if self.beganWaitDlgIsNotOpen and DlgMgr:isDlgOpened("WaitDlg") then
                func(self, sender, ccui.TouchEventType.canceled)
                return
            end

            if not self:isVisible() or not sender:isVisible() then
                func(self, sender, ccui.TouchEventType.canceled)
                return
            end

            self:touchEndEventFunc(sender, eventType, ctrl, func, data)
        else
            func(self, sender, eventType)
        end
    end

    ctrl:addTouchEventListener(listener)
end

-- 为指定的控件对象绑定 TouchEnd 事件
function Dialog:bindTouchEndEventListener(ctrl, func, data)
    if not ctrl then
        Log:W("Dialog:bindTouchEndEventListener no control ")
        return
    end

    local ctrlName = ctrl:getName()

    -- 事件监听
    local function listener(sender, eventType)
        -- 添加 log 以方便核查崩溃问题
        local str = self.name .. ':' .. tostring(ctrlName) .. ' receive event:' .. tostring(eventType)
        Log:I(str)
        if eventType == ccui.TouchEventType.began then
            -- 记录点击时是否打开WaitDlg
            self.beganWaitDlgIsNotOpen = not DlgMgr:isDlgOpened("WaitDlg")
        elseif eventType == ccui.TouchEventType.ended then
            -- 控件长按过程中断线，则不进行后续事件处理
            if self.beganWaitDlgIsNotOpen and DlgMgr:isDlgOpened("WaitDlg") then
                return
            end

            if not self:isVisible() or not sender:isVisible() then
               return
            end

            -- 再一次置灰的原因是，如果该按钮为服务器下发数据后刷新置灰，在消息之前点击按钮（未放开），刷新后（被置灰）但是由于放开事件又被还原了！
            if sender.isGray then
                gf:grayImageView(sender)
            end

            self:touchEndEventFunc(sender, eventType, ctrl, func, data)
        elseif eventType == ccui.TouchEventType.canceled then
            -- 再一次置灰的原因是，如果该按钮为服务器下发数据后刷新置灰，在消息之前点击按钮（未放开），刷新后（被置灰）但是由于放开事件又被还原了！
            if sender.isGray then
                gf:grayImageView(sender)
        end
    end
    end

    ctrl:addTouchEventListener(listener)
end

function Dialog:touchEndEventFunc(sender, eventType, ctrl, func, data)
    local ctrlName = ctrl:getName()
    local str = self.name .. ':' .. tostring(ctrlName) .. ' receive event:' .. tostring(eventType)
    RecordLogMgr:setOneTouchRecordMemo("clickmouse", str)

    -- GM记录坐标，记录点击的控件
    RecordLogMgr:addPosForPosRecordCtrlName(str)

    -- 移除小红点
    local isRedDotRemoved = self:removeRedDot(sender)

    if not self:playExtraSound(sender) then
        SoundMgr:playEffect("button")
    end



    -- 如果该点击事件有被要求记录点击事件，则发送消息
    local rcdInfo = RecordLogMgr:getAssignDataByDlgName(self.name)
    if rcdInfo and rcdInfo[ctrlName] then
        if gfGetTickCount() - rcdInfo[ctrlName].lastClickTime >= Const.RECORD_CLICK_TIME then
            RecordLogMgr:sendAssignClickLog(self.name, ctrlName)
        end
    end

    -- 已经出发连续点击事件
    if RecordLogMgr.isContinuing then
        local stepInfo = RecordLogMgr:getTiggerStepByDlgName(RecordLogMgr.completeStep)
        if stepInfo and stepInfo.dlgName == self.name and stepInfo.clickCtrlName == ctrlName then
            RecordLogMgr:nextStep()
        end
    end

    -- 触发事件
    local tiggerInfo = RecordLogMgr:getTiggerDataByDlgName(self.name)
    if tiggerInfo and tiggerInfo[ctrlName] and not RecordLogMgr.isContinuing then
        RecordLogMgr:tiggerStart(self.name, ctrlName)
    end

    -- 集市秒拍挂相关
    local marketCheaterCtrl = RecordLogMgr:getMarketCheaterCtrlInfo(self.name)
    if marketCheaterCtrl and marketCheaterCtrl[ctrlName] then
        RecordLogMgr:setMarketCheaterClickTimesData(ctrlName, self.name)
    end


    if sender.doubleClickTips then
        local lastClickTime = sender.lastClickTime or 0
        if gfGetTickCount() - lastClickTime < sender.doubleClickTime then

            if sender.doubleClickTips ~= "" then
            gf:ShowSmallTips(sender.doubleClickTips)
            end
            return
        end

        sender.lastClickTime = gfGetTickCount()
    end

    func(self, sender, eventType, data, isRedDotRemoved)

end

-- 设置有效的两次点击时间
function Dialog:setValidClickTime(panelName, timeInterval, tips, root)
    local ctl = self:getControl(panelName, nil, root)
    ctl.doubleClickTips = tips
    ctl.doubleClickTime = timeInterval
end

-- 界面内的悬浮panel，点击其他地方隐藏    switchPanelName为开关的panel
function Dialog:bindFloatPanelListener(panelName, switchPanelName, switchRoot, cb)
    local panel = 'string' == type(panelName) and self:getControl(panelName) or panelName
    if not panel then return end
    panel:setVisible(false)
    local bkPanel = self:getControl("BKPanel") or self.root
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())

    local switchPanel = self:getControl(switchPanelName, nil, switchRoot)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local rect2 = self:getBoundingBoxInWorldSpace(switchPanel)
        local toPos = touch:getLocation()

        local isInRect2 = false
        if switchPanelName and cc.rectContainsPoint(rect2, toPos) then isInRect2 = true end

        if not cc.rectContainsPoint(rect, toPos) and not isInRect2 and panel:isVisible() then
            panel:setVisible(false)

            if cb then
                cb(self)
            end

            return  true
        end
    end

    self.blank:addChild(layout, 10, 100)
    if panel.requestDoLayout then
    panel:requestDoLayout()
    end

    gf:bindTouchListener(layout, touch)
end

-- 控件绑定事件
function Dialog:bindListener(name, func, root, notOnlyEnd)
    if nil == func then
        Log:W("Dialog:bindListener no function.")
        return
    end

    -- 获取子控件
    local widget = self:getControl(name,nil,root)
    if nil == widget then
        if name ~= "CloseButton" then
            Log:W("Dialog:bindListener no control " .. name)
        end
        return
    end

    -- 事件监听
    if notOnlyEnd then
        self:bindTouchEventListener(widget, func)
    else
        self:bindTouchEndEventListener(widget, func)
    end
end

-- 绑定 ListView 控件的选择事件
-- func 点击回调
-- longTouchCallback 长按的回调
function Dialog:bindListViewListener(name, func, longTouchCallback, root)
    -- 获取子控件
    local listView = self:getControl(name, "ccui.ListView", root)
    if not listView then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    -- 监听事件
    local function listener(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
            listView.noCallClickCB = nil

            if longTouchCallback then
                listView.delayAction = performWithDelay(listView, function()
                    if GuideMgr:isRunning() then
                        return
                    end

                    listView.delayAction = nil
                    listView.noCallClickCB = true
                    longTouchCallback(self, sender, eventType)
                end, GameMgr:getLongPressTime())
            end
        elseif eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            if listView.delayAction then
                listView:stopAction(listView.delayAction)
                listView.delayAction = nil
            end

            if not listView.noCallClickCB then
                func(self, sender, eventType)
                GuideMgr:touchLongCtrl(self.name, name)
            end

            listView.noCallClickCB = nil

            -- 移除小红点
            self:removeRedDot(name, root)
        end
    end

    listView:addEventListener(listener)
end

-- 控件长按
function Dialog:blindLongPress(name, OneSecondLaterFunc, func, root, isCallTouchEnd, cancelFun)

    local widget = nil
    if type(name) == "string" then
        widget = self:getControl(name,nil,root)
    else
        widget = name
    end
    self:blindLongPressWithCtrl(widget, OneSecondLaterFunc, func, true, isCallTouchEnd, cancelFun)
    --[[
    if not widget then
    Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                if type(OneSecondLaterFunc) == "function" then
                    OneSecondLaterFunc(self, sender, eventType)
                end

                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(1),callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                if type(func) == "function" then
                    func(self, sender, eventType)
                end
            end
        end
    end

    widget:addTouchEventListener(listener)
    --]]
end

-- 控件长按
-- needMoveDistance 滑动超过距离是否需要触发长按
function Dialog:blindLongPressWithCtrl(widget, OneSecondLaterFunc, func, needJudgeCancled, isCallTouchEnd, cancelFun)
    if type(widget) ~= "userdata" then
        return
    end

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. self.name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            local callFunc = cc.CallFunc:create(function()
                if GuideMgr:isRunning() then
                    return
                end

                sender:stopAction(self.longPress)
                self.longPress = nil

                if type(OneSecondLaterFunc) == "function" then
                    if needJudgeCancled and not sender:isHighlighted() then
                        -- 会响应 canceled 事件，不处理长按回调
                        return
                    end

                    OneSecondLaterFunc(self, sender, eventType)
                end
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            sender:runAction(self.longPress)
        elseif eventType == ccui.TouchEventType.ended then

            if self.longPress ~= nil then
                sender:stopAction(self.longPress)
                self.longPress = nil
                if type(func) == "function" then
                    GuideMgr:touchLongCtrl(self.name, widget:getName())
                    func(self, sender, eventType)
                    return
                end
            end

            if isCallTouchEnd then
                if type(func) == "function" then
                    func(self, sender, eventType)
                    GuideMgr:touchLongCtrl(self.name, widget:getName())
                end
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.longPress ~= nil then
                sender:stopAction(self.longPress)
                self.longPress = nil
            end

            if cancelFun then
                if type(cancelFun) == "function" then
                    cancelFun(self, sender, eventType)
                end
            end
        end
    end

    widget:addTouchEventListener(listener)
end

-- 绑定ListView控件
--name： 控件名         OneSecondLaterFunc：长按1秒后回调函数         func：普通点击回调
function Dialog:bindListViewListenerOneSecond(name, OneSecondLaterFunc, func)
    -- 获取子控件
    local listView = self:getControl(name, "ccui.ListView")
    if not listView then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- 监听选择结束事件
    local function listener(sender, eventType)
        if eventType == ccui.ListViewEventType.ONSELECTEDITEM_START then
            local callFunc = cc.CallFunc:create(function()
                if GuideMgr:isRunning() then
                    return
                end

                if type(OneSecondLaterFunc) == "function" then
                    OneSecondLaterFunc(self, sender, eventType)
                end

                self.root:stopAction(self.longPress)
                self.longPress = nil
            end)

            self.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            self.root:runAction(self.longPress)
        elseif eventType == ccui.ListViewEventType.ONSELECTEDITEM_END then
            if self.longPress ~= nil then
                self.root:stopAction(self.longPress)
                self.longPress = nil
                if type(func) == "function" then
                    func(self, sender, eventType)
                    GuideMgr:touchLongCtrl(self.name, name)
                end
            end
        end
    end

    listView:addEventListener(listener)
end

-- 绑定长按控件的时间，每隔指定时间 t 调用一次回调 cb(ctrName, times)
-- counterName 用于存储按下控件后 cb 第几次被调用(从 1 开始计数)
function Dialog:bindPressForIntervalCallback(name, t, cb, counterName, root)
    local widget = self:getControl(name, nil, root)
    if not widget then
        Log:W("PartyShopDlg:bindPress no control " .. name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self[counterName] = 1
            schedule(widget , function()
                cb(self, sender:getName(), self[counterName], widget)
                self[counterName] = self[counterName] + 1
            end, t)
        elseif eventType == ccui.TouchEventType.moved then
        else
            cb(self, sender:getName(), self[counterName], widget)
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

-- 获取控件
function Dialog:getControl(name, widgetType, root)
    local widget = nil
    if not name then return end

    if type(root) == "string" then
        root = self:getControl(root, "ccui.Widget")
        widget = ccui.Helper:seekWidgetByName(root, name)
    else
        root = root or self.root
        widget = ccui.Helper:seekWidgetByName(root, name)
    end

    return widget
end

function Dialog:getInputText(name, root)
    local textField = self:getControl(name, Const.UITextField, root)
    if textField == nil then
        return ""
    else
        return textField:getStringValue()
    end
end

function Dialog:setInputText(name, text, root, color3)
    local ctl = self:getControl(name, Const.UITextField, root)
    if nil ~= ctl and text ~= nil then
        ctl:setText(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end
end

function Dialog:setButtonText(name, text, root)
    local ctl = self:getControl(name, Const.UIButton, root)
    if nil ~= ctl and text ~= nil then
        ctl:setTitleText(tostring(text))
    end
end

function Dialog:getButtonText(name, root)
    local ctl = self:getControl(name, Const.UIButton, root)
    if nil ~= ctl then
        return ctl:getTitleText()
    end
end

-- 设置控件大小
function Dialog:getCtrlContentSize(name, root)
    local ctl = self:getControl(name, nil, root)
    if nil ~= ctl then
        return ctl:getContentSize()
    end
end

function Dialog:setCtrlOpacity(name, opacity, root)
    local ctl = self:getControl(name, nil, root)
    if nil ~= ctl then
        ctl:setOpacity(opacity)
    end
end

-- 设置控件大小
function Dialog:setCtrlContentSize(name, w, h, root, addX, addY)
    local ctl = self:getControl(name, nil, root)
    if nil ~= ctl then
        if not w then w = ctl:getContentSize().width end
        if not h then h = ctl:getContentSize().height end

        addX = addX or 0
        addY = addY or 0

        ctl:setContentSize(w + addX, h + addY)
        end

    return ctl
end

function Dialog:setLabelText(name, text, root, color3)

    local ctl = self:getControl(name, Const.UILabel, root)

    if nil ~= ctl and text ~= nil then
        ctl:setString(tostring(text))
        if color3 then
            ctl:setColor(color3)
        end
    end

    -- 有些label控件为auto属性，刷新上级
    if ctl then
        local parentPanel = ctl:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end

        return ctl
    end
end

function Dialog:setCtrlColor(name, color3, root)
    local ctrl = self:getControl(name, Const.UILabel, root)

    if ctrl and color3 then
        ctrl:setColor(color3)
    end
end

function Dialog:getLabelText(name, root)
    local ctl = self:getControl(name, Const.UILabel, root)
    if nil ~= ctl then
        local text = ctl:getString()
        return text
    end
end

-- 设置进度条，在hourglass时间内走完，hourglass为毫秒 ，fun走完后的回调函数  isOpposite是否反方向
function Dialog:setProgressBarByHourglass(name, hourglass, startValue, fun, root, isOpposite)
    local bar = self:getControl(name, Const.UIProgressBar, root)
    if not bar then return end
    bar:setPercent(startValue)
    if hourglass <= 0 then return end

    local startTime = gfGetTickCount()
    local elapseTime = hourglass - hourglass * startValue / 100

    schedule(bar, function()
        local curTime = gfGetTickCount() - startTime
        local value = curTime / hourglass * 100

        if isOpposite then value = (hourglass - curTime - elapseTime) / hourglass * 100 end
        if value > 100 then
            value = 100
        elseif value < 0 then
            value = 0
        end

        bar:setPercent(value)

        if curTime >= hourglass then
            bar:stopAllActions()
            if fun then fun() end
        end
    end, 0)
end

-- 指定起点和终点
function Dialog:setProgressBarByHourglassToEnd(name, hourglass, startValue, endValue, fun, root)

    local bar = self:getControl(name, Const.UIProgressBar, root)
    if not bar then return end
    bar:setPercent(startValue)
    if hourglass <= 0 then return end

    local startTime = gfGetTickCount()
    local elapseTime = hourglass

    schedule(bar, function()
        local curTime = gfGetTickCount() - startTime
        local value = curTime / hourglass * (endValue - startValue) + startValue

        if value > endValue then
            value = endValue
        elseif value < 0 then
            value = 0
        end

        bar:setPercent(value)

        if curTime >= hourglass then
            bar:stopAllActions()
            if fun then fun() end
        end
    end, 0)
end

function Dialog:setProgressBar(name, val, max, root, color, isGrow, func)
    local bar = self:getControl(name, Const.UIProgressBar, root)
    if not bar then return end

    local function grow(desValue)
        local curValue = bar:getPercent() + 1.5
        if curValue > math.min(100, desValue * 100 / max) then
            bar:stopAllActions()
            bar:setPercent(math.min(100, desValue * 100 / max))
            if func then
                performWithDelay(bar, function()
                    func()
                end, 0.05)
            end
        else
            bar:setPercent(curValue)
        end
    end

    if max == nil or val == nil or max == 0 or val < 0 then
        bar:setPercent(0)
        if func then func() end
    else
        if isGrow then
            if val == 0 then val = max end
            schedule(bar, function() grow(val) end, 0.001)
        else
            bar:stopAllActions()
            bar:setPercent(math.min(100, val * 100 / max))
            if func then func() end
        end
    end

    if color ~= nil then
        bar:setColor(color)
    end

    return bar
end

function Dialog:setProgressBarColor(name, color, root)
    local bar = self:getControl(name, Const.UIProgressBar, root)
    if bar == nil then return end

    bar:setColor(color)
end

function Dialog:setImage(name, path, root, noAuto)
    if path == nil or string.len(path) == 0 then return end
    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:loadTexture(path)
    end

    -- 有些Image控件为auto属性，刷新上级
    if not noAuto and img then
        local parentPanel = img:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end
    end

    return img
end

function Dialog:setImagePlist(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
    if not sp then
        Log:D("!!!!!!not spriteFrameCache !!!!!! path: " .. path)
        return
    end
    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:loadTexture(path, ccui.TextureResType.plistType)
    end

    -- 有些Image控件为auto属性，刷新上级
    if img then
        local parentPanel = img:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end

        return img
    end
end

function Dialog:setImageSize(name, size, root)
    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:ignoreContentAdaptWithSize(false)
        img:setContentSize(size)
    end
end

function Dialog:setPanelPlist(name, path, root)
    if path == nil or string.len(path) == 0 then return end
    local sp = cc.SpriteFrameCache:getInstance():getSpriteFrame(path)
    if not sp then
        Log:D("!!!!!!not spriteFrameCache !!!!!! path: " .. path)
        return
    end
    local img = self:getControl(name, Const.UIImage, root)
    if img then
        img:setBackGroundImage(path, ccui.TextureResType.plistType)
    end

    -- 有些Image控件为auto属性，刷新上级
    if img then
        local parentPanel = img:getParent()
        if parentPanel and parentPanel.requestDoLayout and type(parentPanel.requestDoLayout) == "function" then
            parentPanel:requestDoLayout()
        end

        return img
    end
end

function Dialog:bindPageViewAndPageTag(pageView, pageTag, pageChangeCallBack)
    if nil == pageView or nil == pageTag then return end

    -- 属性分页
    local idx = pageView:getCurPageIndex()
    pageTag:setPage(idx+1) -- PageView下标从0开始
    pageView:addEventListener(function(sender, eventType)
        idx = pageView:getCurPageIndex()

        if pageTag:getPage() == idx + 1 then
            -- 没有变化
            return
        end

        pageTag:setPage(idx+1)

        if pageChangeCallBack then
            pageChangeCallBack(self, idx+1)
        end
    end)
end

-- 绑定 CheckBox 事件
function Dialog:bindCheckBoxListener(ctrlName, func, root)
    -- 获取子控件
    local ctrl = self:getControl(ctrlName, Const.UICheckBox, root)
    if not ctrl then
        Log:W("Dialog:ctrl no control " .. ctrlName)
        return
    end

    self:bindCheckBoxWidgetListener(ctrl, func)
end

function Dialog:bindCheckBoxWidgetListener(widget, func)
    if not widget then
        Log:W("Dialog:bindCheckBoxWidgetListener no control ")
        return
    end

    local function listener(sender, eventType)
        SoundMgr:playEffect("button")
        func(self, sender, eventType)
    end

    widget:addEventListener(listener)
end

-- 绑定 Slider 事件
function Dialog:bindSliderListener(ctrlName, func, root)
    -- 获取子控件
    local ctrl = self:getControl(ctrlName, Const.UISlider, root)
    if not ctrl then
        Log:W("Dialog:ctrl no control " .. ctrlName)
        return
    end

    local function listener(sender, eventType)
        func(self, sender, eventType)
    end

    ctrl:addEventListener(listener)
end

-- 关闭一些对话框
function Dialog:doSomeDlgClose()


    local numDlgs = DlgMgr:getNumDlgsCgf()
    for dName, _ in pairs(numDlgs) do
        local dlg = DlgMgr:getDlgByName(dName)
        if dlg and dlg.obj and DlgMgr:getDlgByName(dlg.obj.name) then
        else
            DlgMgr:closeDlg(dName)
        end
    end
end

function Dialog:closeForGm(now, notCloseInputNumDlg)

    -- 为了兼容 对话框修改之前的 自定义对话框
    if nil ~= self.root then
        self.root:removeFromParent()
        self.root = nil
    end

    if nil ~= self.blank then
        self.blank:removeFromParent()
        self.blank = nil
    end

    if not notCloseInputNumDlg then
        self:doSomeDlgClose()
    end
    DlgMgr:clearDlg(self.name)
end

-- 不要在控件的回调函数中调用调用close(true)
function Dialog:close(now, notCloseInputNumDlg)
    local function closeNow()
        GuideMgr:removeCurGuidListCtrl(self.name)

        -- 移除所有小红点
        RedDotMgr:removeRelativeDlg(self.name)

        -- 取消安全锁的相关事件
        SafeLockMgr:removeContinueCbByModule(self.name)

        -- 清除数据
        if self.cleanup and 'function' == type(self.cleanup) then
            self:cleanup()
        end

        -- 释放 retain 的控件
        self:releaseCtrls()

        -- 取消该对象所有的 hook 消息
        self:unhookMsg()

        -- 取消监听事件
        self:removeAllEventListener()

        -- 取消监听
        if ATM_IS_DEBUG_VER then
            self.nameLabel = nil
            EventDispatcher:removeEventListener("CONST.SHOW_DLG_NAME", self.refreshDlgNamePanel, self)
        end

        assert(self.name, "nil == self.name")
        assert(self.name == self.__cls_type__, string.format("self.name(%s) != self.__cls_type__(%s)", tostring(self.name), tostring(self.__cls_type__)))
        DlgMgr:clearDlg(self.name)

        -- 显示打开界面时隐藏的界面, 需放在 DlgMgr:clearDlg 之后，因为显示受 DlgMgr:isNeedShowAndHideMainDlg() 的影响，导致本界面打开时不处理显示主界面
        self:showDlgsWhenOpenHide()

        -- 为了兼容 对话框修改之前的 自定义对话框
        if nil ~= self.root then
            self.root:removeFromParent()
            self.root = nil
        end

        if nil ~= self.blank then
            self.blank:removeFromParent()
            self.blank = nil
        end

        if not notCloseInputNumDlg then
            self:doSomeDlgClose()
        end
    end

    -- 清除该界面中，个人空间挂起的自动下载队列
    BlogMgr:cleanAutoLoad(self.name)

    closeNow()
end

-- offPos 相对于panel中心点的偏移量
-- syncLoad 是否需要异步加载
-- 设置方向
function Dialog:setPortrait(panelName, icon, weapon, root, showAttackByClick, action, func, offPos, orgIcon, syncLoad, dir, pTag, extend, partIndex, partColorIndex)
    local argList = {
        panelName = panelName,
        icon = icon,
        weapon = weapon,
        root = root,
        action = action,
        clickCb = func,
        offPos = offPos,
        orgIcon = orgIcon,
        syncLoad = syncLoad,
        dir = dir,
        pTag = pTag,
        extend = extend,
        partIndex = partIndex,
        partColorIndex = partColorIndex,
    }

    if showAttackByClick then
        argList.showActionByClick = 'attack'
    end

    self:setPortraitByArgList(argList)
end

-- argList 中允许设置的参数
function Dialog:setPortraitByArgList(argList)
    local panelName = argList.panelName
    local icon = argList.icon or 0
    local weapon = argList.weapon or 0
    local root = argList.root
    local showActionByClick = argList.showActionByClick
    local action = argList.action or Const.SA_STAND
    local clickCb = argList.clickCb
    local offPos = argList.offPos or cc.p(0, -36)
    local orgIcon = argList.orgIcon
    local syncLoad = argList.syncLoad
    local dir = argList.dir or 5
    local petIcon = argList.petIcon or 0
    local pTag = argList.pTag
    local extend = argList.extend
    local partIndex = argList.partIndex
    local partColorIndex = argList.partColorIndex

    if IconColorScheme[icon] and string.isNilOrEmpty(partIndex) and string.isNilOrEmpty(partColorIndex) then
        partIndex = IconColorScheme[icon].part
        partColorIndex = IconColorScheme[icon].dye
        icon = IconColorScheme[icon].org_icon
    end

    if gf:isCharExist(icon) == false and not pTag then
        icon = 6005
        weapon = 0
        partIndex = nil
        partColorIndex = nil
    end

    local panel = self:getControl(panelName, nil, root)
    if panel == nil then return end

    local size = panel:getContentSize()
    local char = panel:getChildByTag(pTag or Dialog.TAG_PORTRAIT)

    if icon == nil or icon == 0 then
        if nil ~= char then
            char:removeFromParent()
        end
        return
    end

    if nil == char then
        if extend then
            char = CharActionEx.new(syncLoad)
        else
        char = CharAction.new(syncLoad)
    end
        panel:addChild(char, 0, pTag or Dialog.TAG_PORTRAIT)
    end

    if orgIcon then
        char.orgIcon = orgIcon
    end

    char:set(icon, weapon, action, dir, petIcon, nil, nil, partIndex, partColorIndex)

    local function setPos()
        if nil ~= offPos then
            -- 获取中心点的位置坐标
            local contentSize = panel:getContentSize()
            local basicX = contentSize.width / 2 + offPos.x
            local basicY = contentSize.height / 2 + offPos.y
            char:setPosition(basicX, basicY)
        else
            gf:align(char, size, ccui.RelativeAlign.centerInParent)
        end
    end

    if showActionByClick then
        -- 点击时需要播放施法动作
        self:bindTouchEndEventListener(panel, function(...)
            if showActionByClick == 'attack' then
                char:playActionOnce(function()
                    -- 设置位置
                    setPos()
                end)
            elseif showActionByClick == 'walk' then
                -- 'walk'动作未结束，不重新开始动作
                if char.action == Const.SA_WALK then return end

                char:playWalkThreeTimes(function()
                    -- 设置位置
                    setPos()
                end)
            end

            -- 设置位置
            setPos()

            -- 点击 panel 需要回调
            if clickCb then
                clickCb(...)
            end
        end)
    end

    -- 设置位置
    setPos()
    return char
end

function Dialog:removePortrait(panelName, root, tag)

    local panel = self:getControl(panelName, nil, root)
    if panel == nil then return end

    if not tag then
        panel:removeChildByTag(Dialog.TAG_PORTRAIT)
        panel:removeChildByTag(Dialog.TAG_PORTRAIT1)
    else
        panel:removeChildByTag(tag)
    end
end

function Dialog:setListViewTop(ctrlName, root, margin, isNotDelay)
    local list = self:getControl(ctrlName, Const.UIListView, root)
    local items = list:getItems()
    local height = 0
    margin = margin or 0
    for k, panel in pairs(items) do
        height = height + panel:getContentSize().height
    end

    height = height + (#items - 1) * margin
    if height <= list:getContentSize().height then return end

    if isNotDelay then
        list:getInnerContainer():setPositionY(list:getContentSize().height - height)
        list:requestDoLayout()
    else
        performWithDelay(self.root, function ()
            list:getInnerContainer():setPositionY(list:getContentSize().height - height)
            list:requestDoLayout()
        end, 0)
    end
end

function Dialog:setCtrlTouchEnabled(ctrlName, enable, root)
    local ctrl = self:getControl(ctrlName, nil ,root)
    if ctrl then
        ctrl:setTouchEnabled(enable)
    end
end

function Dialog:resetListView(name, margin, gravity, root, notBounce)
    margin = margin or 0
    gravity = gravity or ccui.ListViewGravity.left

    local list = self:getControl(name, Const.UIListView, root)
    if nil == list then return end

    list:removeAllItems()
    list:setGravity(gravity)
    list:setTouchEnabled(true)
    list:setItemsMargin(margin)
    list:setClippingEnabled(true)
    list:setBounceEnabled(not notBounce)
    list:setInnerContainerSize(cc.size(0, 0))

    if GuideMgr:isRunning() then
        if nil == list.direct then
            list.direct = list:getDirection()
        end

        GuideMgr:addCurGuidListCtrl(self.name, list)
    else
        if list.direct then
            list:setDirection(list.direct)
            list.direct = nil
        end
    end

    local size = list:getContentSize()
    return list, size
end

-- 获取指定 ListView 当前选中项
function Dialog:getListViewSelectedItem(listView)
    if not listView then
        return
    end

    local index = listView:getCurSelectedIndex()
    local item = listView:getItem(index)
    return item
end

-- 获取指定 ListView 当前选中项的 tag
function Dialog:getListViewSelectedItemTag(listView)
    local item = self:getListViewSelectedItem(listView)
    if not item then
        return 0
    end

    return item:getTag()
end

-- 创建弹出菜单
-- menuList: 菜单列表数组
-- 点击菜单项时会调用本对话框的 onClickMenu 函数，参数为菜单项索引
function Dialog:popupMenus(menuList, rect)
    local menuDlg = DlgMgr:openDlg("MenuDlg")
    menuDlg:setMenus(menuList, self.name)

    if not rect then
        rect = {
            x = GameMgr.curTouchPos.x,
            y = GameMgr.curTouchPos.y,
            width = 5,
            height = 5,
        }
    end

    menuDlg:setFloatingFramePos(rect)
end

-- 关闭菜单界面
function Dialog:closeMenuDlg()
    DlgMgr:closeDlg('MenuDlg')
end

function Dialog:updateLayout(name, root)
    local panel = self:getControl(name, Const.UIPanel, root)
    if nil ~= panel then
        panel:requestDoLayout()
    end
end

function Dialog:setCheck(checkBox, isCheck, root)
    local ctl = self:getControl(checkBox, Const.UICheckBox, root)
    if ctl == nil then return end

    if type(isCheck) == "number" then
        isCheck = isCheck ~= 0
    end

    ctl:setSelectedState(isCheck)
end

function Dialog:isCheck(checkBox, root)
    local ctl = self:getControl(checkBox, Const.UICheckBox, root)
    if ctl == nil then return end

    return ctl:getSelectedState()
end

-- 获取指定 node 在屏幕坐标系中的区域
function Dialog:getBoundingBoxInWorldSpace(node)
    if not node then
        return
    end

    local rect = node:getBoundingBox()
    local pt = node:convertToWorldSpace(cc.p(0, 0))
    rect.x = pt.x
    rect.y = pt.y
    rect.width = rect.width * Const.UI_SCALE
    rect.height = rect.height * Const.UI_SCALE

    return rect
end

-- 设置悬浮框位置   rect为触发区域self:getBoundingBoxInWorldSpace(cell)
function Dialog:setFloatingFramePos(rect)
    if not self.root then return end
    if not rect then
        -- 未传入则居中
        self:align(ccui.RelativeAlign.centerInParent)
        return
    end
    local x = (rect.x + rect.width * 0.5)
    local y = (rect.y + rect.height * 0.5)
    local dlgSize = self.root:getContentSize()
    dlgSize.width = dlgSize.width * Const.UI_SCALE
    dlgSize.height = dlgSize.height * Const.UI_SCALE
    local ap = self.root:getAnchorPoint()
    self.root:setAnchorPoint(0,0)
    local posX, posY, isUp
    if x < Const.WINSIZE.width * 0.5 then
        if y > Const.WINSIZE.height * 0.5 then
            -- 触发控件在左上
            posX = rect.x + rect.width
            posY = rect.y - dlgSize.height
            isUp = false
        else
            -- 触发控件在左下2
            posX = rect.x + rect.width
            posY = rect.y + rect.height
            isUp = true
        end
    else
        if y > Const.WINSIZE.height * 0.5 then
            -- 触发控件在右上
            posX = rect.x - dlgSize.width
            posY = rect.y - dlgSize.height
            isUp = false
        else
            -- 触发控件在右下
            posX = rect.x - dlgSize.width
            posY = rect.y + rect.height
            isUp = true
        end
    end

    local winSize = self:getWinSize()

    -- 上下限判断    超出上下限，20单位间隔
    if isUp then
        if (posY + dlgSize.height)  > winSize.oy + winSize.height then
            -- 超出高度
            posY = Const.WINSIZE.height - dlgSize.height - 20 * Const.UI_SCALE
        end
    else
        if posY < winSize.oy then
            posY = 20 * Const.UI_SCALE + winSize.oy
        end
    end

    -- 超出左右屏幕
    if posX < winSize.ox then
        posX = winSize.ox + 20 * Const.UI_SCALE
    elseif posX + dlgSize.width > winSize.width + winSize.ox then
        posX = winSize.width + winSize.ox - 20 * Const.UI_SCALE - dlgSize.width
    end

    self:setPosition(cc.p(posX, posY))
end

-- 将控件置灰,设置是否可点击,默认不可点击
function Dialog:setCtrGrayAndTouchEnbel(name, isTouch)
    local ctr = self:getControl(name)
    if ctr == nil then return end

    local grayLayer = ctr:getChildByTag(CTR_BLANK_TAG)
    if nil == grayLayer then
        grayLayer = cc.LayerColor:create(BLANK_COLOR)
        grayLayer:setContentSize(ctr:getContentSize())
        grayLayer:setTag(CTR_BLANK_TAG)
        ctr:addChild(grayLayer)
    end

    if isTouch ~= nil then
        ctr:setEnabled(isTouch)
    else
        ctr:setEnabled(false)
    end
end

function Dialog:setCtrGrayAndTouchEnbelByCtrl(ctrl, isTouch)
    if ctrl == nil then return end

    local grayLayer = ctrl:getChildByTag(CTR_BLANK_TAG)
    if nil == grayLayer then
        grayLayer = cc.LayerColor:create(BLANK_COLOR)
        grayLayer:setContentSize(ctrl:getContentSize())
        grayLayer:setTag(CTR_BLANK_TAG)
        ctrl:addChild(grayLayer)
    end

    if isTouch ~= nil then
        ctrl:setEnabled(isTouch)
    else
        ctrl:setEnabled(false)
    end
end

-- 将控件置灰层删除,设置是否可点击,默认可点击
function Dialog:removeCtrGrayAndTouchEnbel(name, isTouch)
    local ctr = self:getControl(name)
    if ctr == nil then return end

    local grayLayer = ctr:getChildByTag(CTR_BLANK_TAG)
    if grayLayer ~= nil then
        grayLayer:removeFromParent()
    end

    if isTouch ~= nil then
        ctr:setEnabled(isTouch)
    else
        ctr:setEnabled(true)
    end
end

function Dialog:removeCtrGrayAndTouchEnbelByCtrl(ctrl, isTouch)
    if ctrl == nil then return end

    local grayLayer = ctrl:getChildByTag(CTR_BLANK_TAG)
    if grayLayer ~= nil then
        grayLayer:removeFromParent()
    end

    if isTouch ~= nil then
        ctrl:setEnabled(isTouch)
    else
        ctrl:setEnabled(true)
    end
end

-- 设置Slider控件点击拖动回调
function Dialog:addSliderMoveFun(name, func, panel)
    local slider = self:getControl(name, Const.UISlider, panel)
    if slider == nil then return end

    -- 事件监听
    local function listener(sender, eventType)
        func(self, sender, eventType)
    end

    slider:addEventListener(listener)
end

-- 获取Slider控件百分数
function Dialog:getSliderPercent(name, panel)
    local slider = self:getControl(name, Const.UISlider, panel)
    if slider == nil then return end

    return slider:getPercent()
end

-- 设置Slider控件百分数
function Dialog:setSliderPercent(name, percent, panel)
    local slider = self:getControl(name, Const.UISlider, panel)
    if slider == nil then return end

    return slider:setPercent(percent)
end

-- 给控件添加光效
function Dialog:addMagic(name, icon, param)
    local ctrl = nil
    if type(name) == "string" then
        ctrl = self:getControl(name)
    elseif type(name) == "userdata" then
        ctrl = name
    end

    if nil == ctrl then return end

    local magic
    if ctrl:getChildByTag(icon) then return end

    if param and param.callBack then
        magic = gf:createCallbackMagic(icon, param.callback, param.extraPara)
    elseif param and param.isOnce then
        magic = gf:createSelfRemoveMagic(icon, param.extraPara)
    else
        magic = gf:createLoopMagic(icon, nil, param and param.extraPara)
    end

    ctrl:addChild(magic)
    magic:setTag(icon)

    gf:align(magic, ctrl:getContentSize(), ccui.RelativeAlign.centerInParent)

    return magic
end

-- 重置root节点的位置
function Dialog:resetRootPos()
    if self.originPos then
        self.root:stopAllActions()
        self.root:setPosition(self.originPos)
    end
end

function Dialog:removeMagic(name, icon)
    local ctrl = nil
    if type(name) == "string" then
        ctrl = self:getControl(name)
    elseif type(name) == "userdata" then
        ctrl = name
    end

    if nil == ctrl then return end

    if ctrl:getChildByTag(icon) then
        ctrl:removeChildByTag(icon)
    end
end

--返回点击的BoundingBox,需要转换成窗口坐标
function Dialog:getSelectItemBox(type)
    return nil
end

-- 设置小红点
function Dialog:addRedDot(name, root, isBlink)

    local ctrl = nil
    local realName = ""
    if "string" == type(name) then
        ctrl = self:getControl(name, nil, root)
        if nil == ctrl then
            return
        end

        realName = name
    elseif "userdata" == type(name) then
        ctrl = name
        realName = ctrl:getName()
    end

    if nil == self.redDotList then
        self.redDotList = {}
    end

    if self.onCheckAddRedDot and type(self.onCheckAddRedDot) == "function" and not self:onCheckAddRedDot(realName) then
        RedDotMgr:removeOneRedDot(self.name, realName, self.root)
        return
    end

    gf:setCtrlRedDot(ctrl)

    if isBlink then
        gf:setRedDotBlink(ctrl)
    end

    if self.RED_DOT_SCALE then
        -- 极少数要求缩放小红点，例如 ZaixqyDlg界面
        gf:setRedDotScale(ctrl, self.RED_DOT_SCALE)
    end
    ctrl.hasRedDot = true
    self.redDotList[realName] = name
    -- Log:D("<<<" .. self.name .. ">>>add One red dot!!!")
end

-- 移除小红点
function Dialog:removeRedDot(name, root)
    local ctrl = nil
    local realName = ""
    if "string" == type(name) then
        ctrl = self:getControl(name, nil, root)
        if nil == ctrl then
            return
        end

        realName = name
    elseif "userdata" == type(name) then
        ctrl = name
        realName = ctrl:getName()
    end

    if not ctrl.hasRedDot then
        return
    end

    if nil == self.redDotList then
        self.redDotList = {}
    end

    gf:removeCtrlRedDot(ctrl, true)
    self.redDotList[realName] = nil
    if not self.name then return end
    RedDotMgr:removeOneRedDot(self.name, realName, root)
    -- Log:D("<<<" .. self.name .. ">>>remove One red dot!!!")

    ctrl.hasRedDot = false
    return true
end

-- 获取当前ListView滚动百分比
function Dialog:getCurScrollPercent(name, isVertical, root)
    local listView = self:getControl(name, Const.UIListView, root)
    local listViewSize = listView:getContentSize()

    if not listView then return  0 end

    if isVertical then
        local minY = listViewSize.height - listView:getInnerContainer():getContentSize().height
        local h = -1 * minY
        local curPosY = listView:getInnerContainer():getPositionY()
        if h == 0 then return 0 end
        return (curPosY - minY) / h * 100
    else
        local minX = listViewSize.width - listView:getInnerContainer():getContentSize().width
        local h = -1 * minX
        local curPosX = listView:getInnerContainer():getPositionX()
        if h == 0 then return  0 end
        return (curPosX - minX) / h * 100
    end
end

-- 跳转listView当前最后一个显示的item为指定index的item
function Dialog:setListJumpItem(listView, index)
    local items = listView:getItems()
    if #items < index then return end

    local sz = listView:getContentSize()
    local innerContainer = listView:getInnerContainer()
    local innerSz = innerContainer:getContentSize()
    if innerSz.height <= sz.height then return end

    local positionY = -(#items - index) * items[1]:getContentSize().height
    innerContainer:setPositionY(positionY)
end

-- 移除所有的小红点
function Dialog:removeAllRedDot()
    if nil == self.redDotList then
        self.redDotList = {}
    end

    for k, v in pairs(self.redDotList) do
        self:removeRedDot(v)
    end

    -- Log:D("<<<" .. self.name .. ">>>remove All red dot!!!")
    self.redDotList = {}
    RedDotMgr:removeDlgRedDot(self.name)
end

-- 打开界面需要某些参数需要重载这个函数
function Dialog:onDlgOpened(param)

end

-- 播放自定义的声音(某个按钮需要播放特殊的声音需要 重载这个函数，并return true)
function Dialog:playExtraSound(sender)
    return false
end

-- name 控件名
-- returnType 键盘类型
-- func 键盘回调 包括（retrun ,changed ,began ...）
function Dialog:createEditBox(name, root, returnType,func)
    local function editBoxListner(envent, sender)
        if func ~= nil then
            func(self, envent, sender)
        end
    end

    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName(ResMgr.ui.editBox_back)
    backSprite:setOpacity(0)
    local panel = self:getControl(name, nil , root)
    local editBox = cc.EditBox:create(panel:getContentSize(), backSprite)
    editBox:registerScriptEditBoxHandler(editBoxListner)
    editBox:setReturnType(returnType or cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editBox:setAnchorPoint(0, 0.5)
    editBox:setPosition(5, panel:getContentSize().height / 2)
    editBox:setName("EditBox")
    panel:addChild(editBox)

    return editBox
end

-- setColorText  参数太多，而且会设置 setContentSize
-- 这个不会设置 setContentSize
function Dialog:setColorTextEx(str, panel, color, fontSize)
    fontSize = fontSize or 19
    color = color or COLOR3.TEXT_DEFAULT

    panel:removeAllChildren()
    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str)
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    textCtrl:updateNow()
    --
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((size.width - textW) * 0.5, size.height - (size.height - 19) * 0.5)
    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
end


-- 显示字符串
function Dialog:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, locate, isPunct, isVip)
    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    if not panel then return end
    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, isVip)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    if locate == true or locate == LOCATE_POSITION.MID_BOTTOM then
        textCtrl:setPosition((size.width - textW) / 2, textH + marginY)
    elseif locate == LOCATE_POSITION.RIGHT_BOTTOM then
        textCtrl:setPosition(size.width - textW, textH + marginY)
    else
        textCtrl:setPosition(marginX, textH + marginY)
    end

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)
    local panelHeight = textH + 2 * marginY
    panel:setContentSize(size.width, panelHeight)
    return panelHeight, size.height
end

function Dialog:getColorText(panelName, root)
    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    local child = panel:getChildByTag(Dialog.TAG_COLORTEXT_CTRL)
    if child then
        local textCtrl = tolua.cast(child, "CGAColorTextList")
        if textCtrl then
            return textCtrl:getString()
        end
    end
end

-- 指引使用
function Dialog:youMustGiveMeOneNotifyEx(param, detail)
    -- 如果能调用到这个，那么，这个窗口肯定是已经打开了
    -- 好吧，开始延迟一帧，ListView 无解
    local delay = cc.DelayTime:create(0.09)
    gf:getUILayer().callBackDlgName = self.name
    local action = cc.CallFunc:create(function()
            if DlgMgr:getDlgByName(gf:getUILayer().callBackDlgName) then
                self:youMustGiveMeOneNotify(param, detail)
            end
            gf:getUILayer().callBackDlgName = nil
        end)

    -- 不用self.root是因为。例如指引56，切换标签页时候EquipmentChildDlg被关闭再打开，self.root的action都删除了
 	--   self.root:runAction(cc.Sequence:create(delay, action))
    gf:getUILayer():runAction(cc.Sequence:create(delay, action))
end

-- 如果需要使用指引通知类型，需要重载这个函数
function Dialog:youMustGiveMeOneNotify(param, detail)
    GuideMgr:youCanDoIt(self.name, param)
end

-- statePanel 滑动控件 add byzhengjh
-- isOn 开启状态
-- func 回调
-- key 回调传回去的 key
-- limitConditionFuc 条件函数 默认是false可以切换      true不能切换
function Dialog:createSwichButton(statePanel, isOn, func, key, limitConditionFuc)
    -- 创建滑动开关
    statePanel.isOn = isOn
    local actionTime = 0.2
    local bkImage1 = self:getControl("BKImage1", nil, statePanel)
    local bkImage2 = self:getControl("BKImage2", nil, statePanel)
    local image = self:getControl("Image", nil, statePanel)
    local onPositionX = image:getPositionX()
    statePanel.onPositionX = onPositionX
    local isAtionEnd = true
    local function swichButtonAction(self, sender, eventType, data, noCallBack)
        if not noCallBack and limitConditionFuc and limitConditionFuc(self, statePanel.isOn, key) then -- 有条件限制不能切换
            return
        end

        local action
        if isAtionEnd then
            if statePanel.isOn  then
                local moveto = cc.MoveTo:create(actionTime, cc.p(0, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local fadeIn = cc.FadeIn:create(actionTime)
                    bkImage1:setOpacity(0)
                    bkImage1:runAction(fadeIn)
                    local fadeout = cc.FadeOut:create(actionTime)
                    local delayFunc  = cc.CallFunc:create(function ()
                        isAtionEnd = true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(fadeout, delayFunc)

                    bkImage2:runAction(sq)
                end)

                local deily = cc.DelayTime:create(actionTime)

                action = cc.Spawn:create(moveto, fuc)
                image:runAction(action)

                statePanel.isOn = not statePanel.isOn
            else
                local moveto = cc.MoveTo:create(actionTime, cc.p(onPositionX, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local fadeIn = cc.FadeIn:create(actionTime)
                    bkImage2:setOpacity(0)
                    bkImage2:runAction(fadeIn)

                    local fadeout = cc.FadeOut:create(actionTime)
                    local delayFunc  = cc.CallFunc:create(function ()
                        isAtionEnd= true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(fadeout, delayFunc)

                    bkImage1:runAction(sq)

                end)

                action = cc.Spawn:create(moveto, fuc)
                image:runAction(action)
                statePanel.isOn = not statePanel.isOn
            end

        end
    end

    self:bindTouchEndEventListener(statePanel, swichButtonAction)
    local function onNodeEvent(event)
        if "cleanup" == event then
            if not isAtionEnd and func then
                func(self, statePanel.isOn, key)
            end
        end
    end

    statePanel:registerScriptHandler(onNodeEvent)

    statePanel.touchAction = swichButtonAction

    -- 外部强行停止ACTION时，保证isAtionEnd不会因此而无法重置
    image.resetActionEndFlag = function()
        isAtionEnd = true
    end

    if statePanel.isOn then
        bkImage1:setOpacity(0)
        image:setPositionX(onPositionX)
    else
        bkImage2:setOpacity(0)
        image:setPositionX(0)
    end
end

-- 设置按钮状态并且有动作
function Dialog:switchButtonStatusWithAction(ctrl, status)
    if "function" ~= type(ctrl.touchAction) then
        return
    end

    if ctrl.isOn ~= status then
        ctrl.touchAction(self, ctrl)
    end
end

-- 设置按钮状态
function Dialog:switchButtonStatus(ctrl, status)
    if "function" ~= type(ctrl.touchAction) then
        return
    end

    if ctrl.isOn ~= status then
        local bkImage1 = self:getControl("BKImage1", nil, ctrl)
        local bkImage2 = self:getControl("BKImage2", nil, ctrl)
        local image = self:getControl("Image", nil, ctrl)

        bkImage1:stopAllActions()
        bkImage2:stopAllActions()
        image:stopAllActions()

        if image.resetActionEndFlag then
            image.resetActionEndFlag()
        end

        local onPositionX = ctrl.onPositionX
        ctrl.isOn = status
        if status then
            bkImage1:setOpacity(0)
            bkImage2:setOpacity(1000)
            image:setPositionX(onPositionX)
        else
            bkImage1:setOpacity(1000)
            bkImage2:setOpacity(0)
            image:setPositionX(0)
        end
    end
end

-- 获取切换按钮的状态
function Dialog:getButtonStatus(ctrl)
    return ctrl.isOn
end

-- 分页加载ListView中的内容
-- listViewName listview控件名称
-- touchPanel   响应层控件panel
-- cb           当滚动大于%100后回调
function Dialog:bindListViewByPageLoad(listViewName, touchPaneName, cb, root)

    local listView = self:getControl(listViewName, Const.UIListView, root)
    if not listView then
        return
    end

    local panel = self:getControl(touchPaneName, Const.UIPanel, root)
    if not panel then
        return
    end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        local percent = self:getCurScrollPercent(listViewName, true, root)
        Log:D("The percent is %d%%", percent)

        if type(cb) == "function" then
            cb(self, percent, listView)
        end

        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)


end

-- 2015 06/26 by liuyw
-- 在panel中设置数字图片NumImg控件的方位和字体的大小
function Dialog:setNumImgForPanel(panelNameOrPanel, imgName, amount, showSign, locate, fontSize, root, gap, offsetX, offsetY)
    local panel = panelNameOrPanel
    if type(panelNameOrPanel) == 'string' then
        root = root or self.root
        panel = self:getControl(panelNameOrPanel, nil, root)
    end

    if nil == panel then return end

    local tag = locate * 999
    local numImg = panel:getChildByTag(tag)

    -- 数字图片单例
    if numImg then
        numImg:removeFromParent()
    end

    gap = gap or -1
    numImg = NumImg.new(imgName, amount, showSign, gap)
    numImg:setTag(tag)
    numImg:setLocalZOrder(100)
    panel:addChild(numImg)

    if not offsetX then offsetX = 0 end
    if not offsetY then offsetY = 0 end

    --设置锚点和方位
    local panelSize = panel:getContentSize()
    if locate == LOCATE_POSITION.RIGHT_BOTTOM then     --右下
        numImg:setAnchorPoint(1, 0)
        numImg:setPosition(panelSize.width - 5 + offsetX, 5 + offsetY)
    elseif locate == LOCATE_POSITION.LEFT_BOTTOM then  --左下
        numImg:setAnchorPoint(0, 0)
        numImg:setPosition(5 + offsetX, 5 + offsetY)
    elseif locate == LOCATE_POSITION.RIGHT_TOP then    --右上
        numImg:setAnchorPoint(1, 1)
        numImg:setPosition(panelSize.width - 5 + offsetX, panelSize.height - 5 + offsetY)
    elseif locate == LOCATE_POSITION.LEFT_TOP then     --左上
        numImg:setAnchorPoint(0, 1)
        numImg:setPosition(5 + offsetX, panelSize.height - 5 + offsetY)
    elseif locate == LOCATE_POSITION.CENTER then
        numImg:setAnchorPoint(0, 0.5)
        numImg:setPosition(0 + offsetX, panelSize.height / 2 + offsetY)
    elseif locate == LOCATE_POSITION.MID then          --中间
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2 + offsetX, panelSize.height / 2 + offsetY)
    elseif locate == LOCATE_POSITION.MID_TOP then      --中上
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2 + offsetX, panelSize.height - 5 + offsetY)
    elseif locate == LOCATE_POSITION.MID_BOTTOM then   --中下
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setPosition(panelSize.width / 2 + offsetX, 5 + offsetY)
    else
       Log:W("Location not expected!")
       return
    end

    --设置字体大小
    if fontSize == 25 then
        numImg:setScale(1, 1)
    elseif fontSize == 30 then
        numImg:setScale(17 / 15, 26 / 22)
    elseif fontSize == 23 then
        numImg:setScale(14 / 15, 20 / 22)
    elseif fontSize == 21 then
        numImg:setScale(13 / 15, 18 / 22)
    elseif fontSize == 19 then
        numImg:setScale(12 / 15, 16 / 22)
    elseif fontSize == 17 then
        numImg:setScale(11 / 15, 14 / 22)
    elseif fontSize == 15 then
        numImg:setScale(10 / 15, 12 / 22)
    elseif fontSize == 12.5 then
        numImg:setScale(0.5, 0.5)
    else
        Log:W("Font Size not expected!")
        return
    end

    return numImg
end

-- 移除设置数字图片
function Dialog:removeNumImgForPanel(panelNameOrPanel, locate, root)
    local panel = panelNameOrPanel
    if type(panelNameOrPanel) == 'string' then
        root = root or self.root
        panel = self:getControl(panelNameOrPanel, Const.UIPanel, root)
    end

    if nil == panel then return end

    local tag = locate * 999
    panel:removeChildByTag(tag, true)
end

-- 设置切换场景时关闭界面
function Dialog:setCloseDlgWhenRefreshUserData(enabled)
    if enabled then
        EventDispatcher:addEventListener('REFRESH_USER_DATA', self.onRefreshUserData, self)
    else
        EventDispatcher:removeEventListener('REFRESH_USER_DATA', self.onRefreshUserData, self)
    end
end

-- 设置进入战斗时关闭界面
function Dialog:setCloseDlgWhenEnterCombat(enabled)
    if enabled then
        EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, self.onEnterCombat, self)
    else
        EventDispatcher:removeEventListener(EVENT.ENTER_COMBAT, self.onEnterCombat, self)
    end
end

-- 停止控件上的所有动作
function Dialog:stopAllAction(ctrlName)
    local ctrl
    if type(ctrlName) == "string" then
        ctrl = self:getControl("BKPanel")
    elseif type(ctrlName) == "userdata" then
        ctrl = ctrlName
    else
        return
    end

    if nil == ctrl then return end
    ctrl:stopAllActions()
end

-- 释放供克隆的控件
-- ctrlStr为变量名
function Dialog:releaseCloneCtrl(ctrlStr)
    if self[ctrlStr] then
        self[ctrlStr]:release()
        self[ctrlStr] = nil
    end
end

-- 初始化要clone的ctrl
function Dialog:toCloneCtrl(ctrlStr, root)
    local ctrl = self:getControl(ctrlStr, nil, root)
    ctrl:setVisible(true)
    ctrl:retain()
    ctrl:removeFromParentAndCleanup()

    return ctrl
end

function Dialog:bindFloatingEvent(crtlName, root)
    local panel = self:getControl(crtlName, nil, root)
    if not panel then
        return
    end

    panel:setVisible(false)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        return true
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local box = panel:getBoundingBox()
        if panel:isVisible() then
            panel:setVisible(false)
        end
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 输入框控件，目前适用于安全锁相关
-- 强更后，setColorSpaceHolder 生效
function Dialog:bindEditFieldForSafe(parentPanelName, lenLimit, clenButtonName, verAlign,
    eventCallBack, needUpDlgHeight, placeHolderColor)

    local namePanel = parentPanelName
    if type(parentPanelName) == 'string' then
        namePanel = self:getControl(parentPanelName)
    end

    local textCtrl = self:getControl("TextField", nil, namePanel)
    textCtrl:setPlaceHolder(placeHolder or "")

    if placeHolderColor and textCtrl.setColorSpaceHolder then
        -- placeHolder颜色生效，设置默认字体颜色
        textCtrl:setColorSpaceHolder(placeHolderColor)
    end

    textCtrl:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    textCtrl:setTextVerticalAlignment(verAlign or cc.TEXT_ALIGNMENT_CENTER)
    self:setCtrlVisible(clenButtonName, false, namePanel)
    self:setCtrlVisible("DefaultLabel", true, namePanel)
    if not self.checkImeStatus then
        self.checkImeStatus = {}
    end

    self.upDlgAction = nil
    if needUpDlgHeight and type(needUpDlgHeight) == 'boolean' then
        needUpDlgHeight = self:getTextFieldNeedUpHeight(textCtrl)
    end

    textCtrl:addEventListener(function(sender, eventType)
        -- 当界面上有多个TextField控件时，会收到多个控件的attach事件(底层attachWithIme事件是广播的)
        -- lua层需要根据GameMgr.curTouchPos判断点击的点是否在当前控件上
        if ccui.TextFiledEventType.attach_with_ime == eventType and not self:isContainTouchPos(parentPanelName) then
            return
        end

        if ccui.TextFiledEventType.insert_text == eventType then
            local str = textCtrl:getStringValue()

            self:setCtrlVisible(clenButtonName, true, namePanel)
            self:setCtrlVisible("DefaultLabel", false, namePanel)
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空,如果将来需要有清空输入按钮
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible(clenButtonName, false, namePanel)
                self:setCtrlVisible("DefaultLabel", true, namePanel)
            end
        elseif ccui.TextFiledEventType.attach_with_ime == eventType then
            self.checkImeStatus[parentPanelName] = self:getTextFieldNeedUpHeight(sender)
        elseif ccui.TextFiledEventType.detach_with_ime == eventType then
            self.checkImeStatus[parentPanelName] = false
        end
        if eventCallBack then
            eventCallBack(self, sender, eventType)
        end

        -- 检查界面是否需要在打开输入法或关闭输入法，上移或下移界面
        if needUpDlgHeight and type(needUpDlgHeight) == 'number'
            and (ccui.TextFiledEventType.attach_with_ime == eventType or ccui.TextFiledEventType.detach_with_ime == eventType) then
            if self.upDlgAction then
                return
            end

            self.upDlgAction = performWithDelay(self.root, function()
                local upHeight = self:getDlgUpStatus()
                if upHeight then
                    DlgMgr:upDlg(self.name, upHeight)
                else
                    DlgMgr:resetUpDlg(self.name)
                end

                self.upDlgAction = nil
            end, 0.1)
        end
    end)
end

-- 计算界面需要移动状态，暂时只在ios下有此需求
-- attach时，返回上移高度，detach时返回false
function Dialog:getDlgUpStatus()
    if gf:isIos() then
        for k, v in pairs(self.checkImeStatus) do
            if v then
                return v
            end
        end
    end

    return false
end

-- 判断当前点击的点是否在nodeOrName控件上
function Dialog:isContainTouchPos(nodeOrName)
    local pos = GameMgr.curTouchPos
    local panel
    if type(nodeOrName) == "string" then
        panel = self:getControl(nodeOrName)
    else
        panel = nodeOrName
    end

    local rect = self:getBoundingBoxInWorldSpace(panel)
    if cc.rectContainsPoint(rect, pos) then
        return true
    end
end

-- 计算TextField在iOS下界面需要上移的高度
function Dialog:getTextFieldNeedUpHeight(textCtrl)
    local rect = self:getBoundingBoxInWorldSpace(textCtrl)

    -- WDSY-26703输入法高度暂时按照屏幕高度的2/3来算
    local iosImeHeight = Const.WINSIZE.height / 3 * 2

    -- WDSY=28695，计算输入法高度，需强更后才生效
    if textCtrl.getImeHeight then
        local realImeHeight = textCtrl:getImeHeight()
        if realImeHeight ~= 0 then
            iosImeHeight = realImeHeight
        end
    end

    local needUpDlgHeight = 0
    if rect.y < iosImeHeight then
        needUpDlgHeight = iosImeHeight - rect.y
    end

    return needUpDlgHeight
end

--  绑定数字键盘
function Dialog:bindNumInput(ctrlName, root, limitCallBack, key, isString, useBig)
    local panel = self:getControl(ctrlName, nil, root)
    local function openNumIuputDlg()
        if limitCallBack and "function" == type(limitCallBack) then
            if limitCallBack(self) then
                return
            end
        end

        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg
        if useBig then
            dlg = DlgMgr:openDlg("NumInputExDlg")
        else
            dlg = DlgMgr:openDlg("SmallNumInputDlg")
        end

        dlg:setObj(self)
        dlg:setKey(key)
        dlg:setIsString(true == isString and true or false)
        dlg:updatePosition(rect)

        if self.doWhenOpenNumInput then
            self:doWhenOpenNumInput(ctrlName, root)
        end
    end

    self:bindListener(ctrlName, openNumIuputDlg, root)

    -- 供外部主动调用弹出数字键盘
    return openNumIuputDlg
end

-- 添加光效
function Dialog:addMagicToCtrl(ctrlName, icon, root, pos, dir, extraPara)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then return end

    local effect = LIGHT_EFFECT[icon]
    if not effect then return end

    local armatureType = LIGHT_EFFECT[icon].armatureType
    extraPara = extraPara or LIGHT_EFFECT[icon].extraPara
    local behind = LIGHT_EFFECT[icon].behind
    local magic, dbMagic
    if not armatureType or armatureType == 0 then
        magic = gf:createLoopMagic(icon, nil, extraPara)
        magic:setContentSize(ctrl:getContentSize())
    elseif armatureType == 3 then
        if type(icon) == "table" then
            dbMagic = DragonBonesMgr:createCharDragonBones(icon.icon, icon.armatureName)
            if dbMagic then
                magic = tolua.cast(dbMagic, "cc.Node")
            end
        end
    else
        local actionName
        if LIGHT_EFFECT[icon] and LIGHT_EFFECT[icon]["show_action"] and dir then
            -- 如果骨骼动画已经配置了动作名，则使用配置的
            actionName = LIGHT_EFFECT[icon]["show_action"][dir]
        end

        if not actionName then
            actionName = "Top"
            if behind then
                actionName = "Bottom"
            end
        end

        magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)

        -- 需要循环播放骨骼动画
        magic:getAnimation():play(actionName, -1, 1)
    end

    if 'number' == type(pos) then
        local charAction = ctrl:getChildByTag(Dialog.TAG_PORTRAIT)
        if charAction then
            local x, y
            local cx, cy = charAction:getPosition()
            if 3 == pos then
                x, y = charAction:getHeadOffset()
            elseif 2 == pos then
                x, y = charAction:getWaistOffset()
            elseif 1 == pos then
                x, y = 0, 0
            end
            pos = cc.p(x + cx, y + cy)
        end
    end

    if not pos then
        pos = cc.p(ctrl:getContentSize().width / 2,ctrl:getContentSize().height / 2)
    end

    magic:setPosition(pos)
    ctrl:addChild(magic, behind and -1 or 1, icon)
    return magic
end

function Dialog:removeMagicFromCtrl(ctrlName, icon, root)
    -- 如果有光效，删除
    local sender = self:getControl(ctrlName, nil, root)
    local magic = sender:getChildByTag(icon)
    if magic then
        magic:removeFromParent()
    end
end

-- 指定对话框控件增加循环光效
function Dialog:addLoopMagicToCtrl(ctrlName, icon, root, pos, extraPara)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then return end
    local effect =  gf:createLoopMagic(icon, nil, extraPara)
    effect:setAnchorPoint(0.5, 0.5)

    if not pos then
        pos = cc.p(ctrl:getContentSize().width / 2,ctrl:getContentSize().height / 2)
    end

    effect:setPosition(pos)
    effect:setContentSize(ctrl:getContentSize())
    ctrl:addChild(effect, 1, icon)
end

function Dialog:removeLoopMagicFromCtrl(ctrlName, icon, root)
    -- 如果有光效，删除
    self:removeMagicFromCtrl(ctrlName, icon, root)
end

function Dialog:removeArmatureMagicFromCtrl(ctrlName, tag, root)
    -- 如果有光效，删除
    self:removeMagicFromCtrl(ctrlName, tag, root)
end

function Dialog:getLoopMagicFromCtrl(ctrlName, icon, root)
    local sender = self:getControl(ctrlName, nil, root)
    local magic = sender:getChildByTag(icon)
    return magic
end

-- 添加飞魔、飞仙光效
-- type = 3 飞仙光效   type = 4 飞魔光效
-- (真身)state = true 时才需要添加光效，策划新设定！
function Dialog:addUpgradeMagicToCtrl(ctrlName, type, root, state)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then
        return
    end

    -- 尝试移除
    ctrl:removeChildByTag(Const.UPGRADE_MAGIC_TAG)

    local scale = 1
    local downH = 0
    if not state then
        scale = Const.UPGRADE_CHILD_MAGIC_SCALE
        downH = 15
    end

    local magicIcon = ResMgr:getUpgradeIconByType(type)
    if not magicIcon then
        return
    end

    local effect = gf:createLoopMagic(magicIcon, nil, {loopInterval = 5000, scaleX = scale, scaleY = scale})
    local pos = cc.p(ctrl:getContentSize().width / 2,ctrl:getContentSize().height / 2 - downH)
    effect:setPosition(pos)
    effect:setAnchorPoint(0.5, 0.5)
    effect:setContentSize(ctrl:getContentSize())
    ctrl:addChild(effect)
    effect:setTag(Const.UPGRADE_MAGIC_TAG)
end

-- 移除飞魔、飞仙光效
function Dialog:removeUpgradeMagicToCtrl(ctrlName, root)
    local ctrl = self:getControl(ctrlName, nil, root)
    if not ctrl then
        return
    end

    -- 尝试移除
    ctrl:removeChildByTag(Const.UPGRADE_MAGIC_TAG)
end

-- 添加飞魔、飞仙图标
-- type = 3 飞仙图标   type = 4 飞魔图标
function Dialog:addUpgradeImage(imageCtrlName, type, root)
    self:setCtrlVisible(imageCtrlName, false, root)

    local imagePath = ResMgr:getUpgradeIconByType(type, true)
    if imagePath then
        self:setCtrlVisible(imageCtrlName, true, root)
        self:setImage(imageCtrlName, ResMgr:getUpgradeIconByType(type, true))
    end
end

-- 创建分享按钮
function Dialog:createShareButton(btnCtrl, typeStr, fun, preFun, backFun)
    if nil == btnCtrl then return end

    if ShareMgr:isShowShareBtn() then
        -- 需要显示分享按钮
        btnCtrl:setVisible(true)
    else
        -- 不需要显示分享按钮
        btnCtrl:setVisible(false)
        return
    end

    self:bindTouchEndEventListener(btnCtrl, function()
        if "function" == type(fun) then
            fun(self)
        else
            -- 分享
            ShareMgr:share(typeStr, preFun, backFun)
        end
    end)
end

-- 创建多行多列的scrollView
-- data列表数据
-- cellColne 列表复制的单元
-- func 设置单元数据的函数
-- column 列数
-- startX ， startY 距离边框距离
function Dialog:initScrollViewPanel(data, cellColne, func, scrollView, column, lineSpace, columnSpace, startX, startY, scrollDir)
    if not scrollView then return end
    startX = startX or 0
    startY = startY or 0
    lineSpace = lineSpace or 0
    columnSpace = columnSpace or 0
    scrollView:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local line = math.floor(#data / column)
    local left = #data % column

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + lineSpace) + startY
    local totalWidth = column * (cellColne:getContentSize().width + columnSpace) + startX

    if scrollDir  == ccui.ScrollViewDir.horizontal then
        totalHeight = scrollView:getContentSize().height
    end

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = column
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * column
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + columnSpace) + startX
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + lineSpace) - startY
            cell:setPosition(x, y)
            cell:setTag(tag)
            func(self, cell , data[tag])
            contentLayer:addChild(cell)
        end
    end

    if scrollDir  == ccui.ScrollViewDir.horizontal then
        contentLayer:setContentSize(totalWidth, scrollView:getContentSize().height)
        scrollView:setInnerContainerSize(contentLayer:getContentSize())
    else
        contentLayer:setContentSize(scrollView:getContentSize().width, totalHeight)
        scrollView:setInnerContainerSize(contentLayer:getContentSize())
    end

    if totalHeight < scrollView:getContentSize().height then
        contentLayer:setPositionY(scrollView:getContentSize().height - totalHeight)
    end

    scrollView:addChild(contentLayer, 0, #data * 99)
end

-- 创建协程
function Dialog:startCoroutine(func, ...)
    return startCoroutine(func, ...)
end

-- 协程yield函数
function Dialog:yield(time)
    yield(time, self.blank)
end

-- 停止协程
function Dialog:stopCoroutine(co)
    stopCoroutine(co)
end

function Dialog:onCloseButtonForGm()
    DlgMgr:closeDlgForGm(self.name)
end

function Dialog:onCloseButton()
    if "NpcDlg" == self.name then
        gf:CmdToServer("CMD_CLOSE_MENU", {id = self.npc_id})
        DlgMgr:closeDlg(self.name)
    else
        DlgMgr:closeDlg(self.name)
    end
end

function Dialog:onRefreshUserData()
    if GameMgr.canRefreshUserData then self:onCloseButton() end
end

function Dialog:onEnterCombat()
    self:onCloseButton()
end

-- 创建刮图
-- cb 擦除完成回调方法
-- effectAare 以中点向外扩有效的计算面积占总面积的比例
-- desRate 完成擦除的擦除部分占有效面积的比例
-- canTouchFlag 用于指定标记是否可 Touch 的变量名，界面初始化时需要设置 self[canTouchFlag] = true
--              以确保能够只处理多点触碰中的第一个 Touch 事件
function Dialog:createScratch(ctrlName, scImagePath, erasers, desRate, cb, effectAareRate, canTouchFlag, root)
    local panel = self:getControl(ctrlName, nil, root)

    local rText = cc.RenderTexture:create(panel:getContentSize().width, panel:getContentSize().height)
    rText:setPosition(panel:getContentSize().width/2, panel:getContentSize().height/2)
    panel:addChild(rText)

    -- 创建被擦除的内容，并将其选染在画布上
    local image = cc.Sprite:create(scImagePath)
    image:setAnchorPoint(0, 0)
    image:setPosition(0, 0)

    rText:begin()
    image:visit()
    rText:endToLua()

    local panelW = math.floor(panel:getContentSize().width * effectAareRate)
    local panelH = math.floor(panel:getContentSize().height * effectAareRate)
    local map = {}
    map.all = (panelW + 1) * (panelH + 1)
    map.part = 0
    for i = 1, panelW + 1 do
        map[i] ={}
        for j = 1, panelH + 1 do
            map[i][j] = 1
        end
    end

    local box = panel:getBoundingBox()
    -- x, y 时 panel 在父节点中的偏移，此处要判断的 touchPos 是相对于 panel 的偏移
    -- 所以需要把 x，y 清除
    box.x = 0
    box.y = 0

    local lastPos = {}
    local i = 1
    local eCount = #erasers
    local lastMoveTime = 0
    local function onErase(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        local curPos = {}
        curPos.x = touchPos.x
        curPos.y = touchPos.y

        touchPos = rText:convertToNodeSpace(touchPos)
        touchPos.x = touchPos.x + box.width / 2
        touchPos.y = touchPos.y + box.height / 2

        if nil == box then
            return curPos
        end

        if not lastPos.x then
            lastPos.x = curPos.x
            lastPos.y = curPos.y
        end

        lastPos = rText:convertToNodeSpace(lastPos)
        lastPos.x = lastPos.x + box.width / 2
        lastPos.y = lastPos.y + box.height / 2
        local c = 0
        rText:begin()
        local pos = {}
        pos.x = lastPos.x - touchPos.x
        pos.y = lastPos.y - touchPos.y

        local nurmal = cc.pNormalize(pos)
        local lastDistance = cc.pGetDistance(touchPos, lastPos)
        while lastDistance >= 2.0  do
            touchPos.x = touchPos.x + nurmal.x * 2.0
            touchPos.y = touchPos.y + nurmal.y * 2.0
            if lastDistance <= cc.pGetDistance(touchPos, lastPos) then
                break
            end

            lastDistance = cc.pGetDistance(touchPos, lastPos)
        if cc.rectContainsPoint(box, touchPos) then
                local eraser = erasers[i]
                i = i % eCount + 1

                if not eraser then return curPos end
            eraser:setPosition(touchPos)
            eraser:visit()

                -- 缩小有效的点击范围后，重新取坐标和有效面积
                local effectPos = {}
                effectPos.x = touchPos.x - (box.width - box.width * effectAareRate) / 2
                effectPos.y = touchPos.y - (box.height - box.height * effectAareRate) / 2
            local box2 = {}
            box2.width = box.width * effectAareRate
            box2.height = box.height * effectAareRate
            box2.x = 0
            box2.y = 0
                if cc.rectContainsPoint(box2, effectPos) then
                    local x1 = math.floor(effectPos.x) - eraser.radius + 1
                    local y1 = math.floor(effectPos.y) + eraser.radius - 1
            local x2 = x1 + eraser.radius + eraser.radius - 1
            local y2 = y1 - (eraser.radius + eraser.radius - 1)
            if x1 < 1 then x1 = 1 end
            if y1 > panelH then y1 = panelH end
            if x2 > panelW then x2 = panelW end
            if y2 < 1 then y2 = 1 end

            for i = x1, x2 do
                for j = y2, y1 do
                    if map[i][j] == 1 then
                        map[i][j] = 0
                        map.part = map.part + 1
                    end
                end
            end

            if map.part / map.all >= desRate then
                cb(self, ctrlName)
            end
                end
            end
        end
        rText:endToLua()

        return curPos
    end

    self[canTouchFlag] = true
    local function onTouchBegan(touch, event)
        if not self[canTouchFlag] then
            return false
        end

        i = 1

        -- 本次 Touch 结束之前不允许再次 Touch
        self[canTouchFlag] = false

        local touchPos = touch:getLocation()
        lastPos = {}
        lastPos.x = touchPos.x
        lastPos.y = touchPos.y
            return true
        end

    local function onTouchMove(touch, event)
        if lastMoveTime + 20 > gfGetTickCount() then
            return true
        end

        lastMoveTime = gfGetTickCount()
        lastPos = onErase(touch, event)
        return true
    end

    local function onTouchEnd(touch, event)
        onErase(touch, event)
        lastPos = {}
        self[canTouchFlag] = true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, rText)

    return rText
end

-- 创建橡皮擦
function Dialog:createEraser(radius)
    local eraser = cc.DrawNode:create()
    eraser:drawDot(cc.p(0, 0), radius, cc.c4b(0, 0, 0, 0))
    eraser:setAnchorPoint(0.5, 0.5)
    eraser:setBlendFunc(gl.ONE, gl.ZERO)
    eraser.radius = radius
    return eraser
end

-- 设置技能、小图头像、道具显示大小（图片资源有可能64 * 64 或  96 * 96，统一设置成 64 * 64，）
function Dialog:setItemImageSize(str, root, isNotImg)
    local img = self:getControl(str, nil, root)
    gf:setItemImageSize(img, isNotImg)
end

-- 设置奖励小图标大小（图片资源 96 * 96，统一设置成 48 * 48）
function Dialog:setSmallRewardImageSize(str, root, isNotImg)
    local img = self:getControl(str, nil, root)
    gf:setSmallRewardImageSize(img, isNotImg)
end

-- 设置法宝、顿悟技能标记图片显示大小（图片资源30 * 30，统一设置成 20 * 20的显示大小）
function Dialog:setSkillFlagImageSize(str, root, isNotImg)
    local img = self:getControl(str, nil, root)
    gf:setSkillFlagImageSize(img, isNotImg)
end


-- 检查安全锁
function Dialog:checkSafeLockRelease(funName, ...)
    -- 安全锁判断
    if SafeLockMgr:isToBeRelease() then
        SafeLockMgr:addContinueCb(self.name, funName, ...)
        return true
    end

    return false
end

-- retain 控件并移出父控件，在 close() 中会自动释放
-- 需要再中途去释放的控件不要在此接口中 retain
-- 如果是 ctrlName 是listView中的项，需要注意
-- -- 当帧 Dialog:retainCtrl(ctrlName, root)，list:getItems()数目不会变
-- -- listView:refreshView()后依然如此
-- -- removeFromParent()操作，但是在 listView 中，该操作仅将对象项从 listView 的 InnerContainer 中删除，依然在items里
-- -- 如果隔帧，则没有问题
function Dialog:retainCtrl(ctrlName, root)
    local ctrl
    if type(ctrlName) == "string" then
        ctrl = self:getControl(ctrlName, nil, root)
    elseif type(ctrlName) == "userdata" then
        ctrl = ctrlName
    end

    if ctrl == nil then
        return
    end

    ctrl:setVisible(true)
    ctrl:retain()
    ctrl:removeFromParent()

    -- 对于类似这样的界面继承 BlogCircleEXDlg = Singleton("BlogCircleEXDlg", BlogCircleDlg)
    -- 如果 BlogCircleDlg 中已有 retainCtrl 变量
    -- 则  BlogCircleEXDlg 调用 retainCtrl 方法时，此处的 self.retainCtrl 为 BlogCircleDlg.retainCtrl
    -- 所以为了保证每个界面都有自己的 retainCtrls 表，此处需要使用 self.var.retainCtrl
    -- ps. var 为 Singleton 中定义的变量
    if not self.var.retainCtrls then
        self.var.retainCtrls = {}
    end

    table.insert(self.var.retainCtrls, ctrl)

    return ctrl
end

function Dialog:releaseCtrls()
    if not self.retainCtrls then
        return
    end

    for _, v in ipairs(self.retainCtrls) do
        if v then
            v:cleanup()
            v:release()
        end
    end

    self.retainCtrls = {}
end


-- 定时器
function Dialog:startSchedule(func, time)
    return schedule(self.root, func, time)
end

-- 停止定时器
function Dialog:stopSchedule(schedule)
    if schedule then
        self.root:stopAction(schedule)
    end
end

-- 绑定搜索框关闭时间
function Dialog:bindTipPanelTouchEvent(name)
    local tipPanel = self:getControl(name)
    local layout = ccui.Layout:create()
    layout:setContentSize(tipPanel:getContentSize())
    layout:setPosition(tipPanel:getPosition())
    layout:setAnchorPoint(tipPanel:getAnchorPoint())

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(tipPanel)
        local toPos = touch:getLocation()

        if not cc.rectContainsPoint(rect, toPos) and  tipPanel:isVisible() then
            tipPanel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

-- list移动至目标索引
function Dialog:setListInnerPosByIndex(listName, index, root)
    local list
    if type(listName) == "string" then
        list = self:getControl(listName, nil, root)
    else
        list = listName
    end

    if not #list:getItems() == 0 then return end
    if list:getInnerContainer():getContentSize().height <= list:getContentSize().height then return end

    local inner = list:getInnerContainer()
    local margin = list:getItemsMargin()
    local panel = list:getChildren()[1]
    local height = (panel:getContentSize().height + margin) * (index)

    if height >= list:getContentSize().height then
        inner:setPositionY(height - inner:getContentSize().height)
    end
end

-- 该接口用于菜单设置。支持二级菜单
-- listInfo:如果为 string，表示list控件名称，如果为表，传入list相关属性
-- oneMene :一级菜单,例如 {"菜单一", "菜单二"}
-- secondMenu :二级菜单
-- cfgPara = {one, two, againClickNeedNotHideTwoMenu, isScrollToDef }  -- 一些属性参数
--      one ： 默认点击的一级菜单,   TAG或者内容
--      two ： 默认点击的二级菜单
--      againClickNeedNotHideTwoMenu ： 再次点击已选择菜单时，是否需要删除二级菜单
--      isScrollToDef ：是否需要滚动到默认选择项
function Dialog:setMenuList(listInfo, oneMenus, onePanel, secondMenus, secondPanel, onOneMenuCallBack, onSecondMenuCallBack, cfgPara)
    cfgPara = cfgPara or {}

    -- list 相关设置
    local listView, margin, gravity, root
    if type(listInfo) == "string" then
        margin = 0
        gravity = ccui.ListViewGravity.centerVertical
        listView = self:getControl(listInfo, nil, root)
    elseif type(listInfo) == "table" then
        margin = listInfo.margin or 0
        gravity = listInfo.gravity or ccui.ListViewGravity.centerVertical
        root = listInfo.root
        listView = self:getControl(listInfo.name, nil, root)
    end
    if not listView then return end
    -- 相关属性设置
    listView:removeAllItems()
    listView:setGravity(gravity)
    listView:setTouchEnabled(true)
    listView:setItemsMargin(margin)
    listView:setClippingEnabled(true)
    listView:setInnerContainerSize(cc.size(0, 0))

    local defSelectIndex = 0

    -- 点击二级菜单回调
    local function onSmallMenu(dlg, sender, isDef)
        if type(self.isCanClickSmallMenu) == "function" and not self:isCanClickSmallMenu(sender) then
            return
        end

        local items = listView:getItems()
        local removeBigTag
        for _, panel in pairs(items) do
            local tag = panel:getTag()
            if tag % 100 ~= 0 and math.floor(tag / 100) * 100 ~= sender:getTag() then
                -- 二级菜单，删除
                self:setCtrlVisible("SChosenEffectImage", false, panel)
            else

            end
        end

        self:setCtrlVisible("SChosenEffectImage", true, sender)

        if onSecondMenuCallBack then
            onSecondMenuCallBack(dlg, sender, isDef)
        end
    end

    -- 设置二级菜单
    local function setSmallMenuListByBigMenu(sender)
        local menus = secondMenus[sender:getName()]
        local defaultFlag = nil
        for i = 1, #menus do
            local panel = secondPanel:clone()
            panel:setTag(sender:getTag() + i)
            panel:setName(menus[i])
            self:setLabelText('Label', menus[i], panel)
            listView:insertCustomItem(panel, math.floor(sender:getTag() / 100) + i - 1)

            if not defaultFlag and not cfgPara["two"] and not (type(self.isCanClickSmallMenu) == "function" and not self:isCanClickSmallMenu(panel, true)) then
                defaultFlag = true
                onSmallMenu(self, panel, cfgPara)
            end

            if cfgPara and cfgPara["two"] and (cfgPara["two"] == menus[i] or cfgPara["two"] == panel:getTag()) then
                onSmallMenu(self, panel)
                defSelectIndex = sender:getTag() / 100 + i
                defaultFlag = true
                cfgPara["two"] = nil
            end
        end

        listView:refreshView()
    end

    local function setArrow(state, panel)
        panel.menuState = state
        self:setCtrlVisible("DownArrowImage", false, panel)
        self:setCtrlVisible("UpArrowImage", false, panel)

        if state == MENU_BUTTON_STATE.NORMAL then
            self:setCtrlVisible("DownArrowImage", true, panel)
            self:setCtrlVisible("BChosenEffectImage", false, panel)
            self:setCtrlVisible("SChosenEffectImage", false, panel)
        elseif state == MENU_BUTTON_STATE.EXPAND then
            self:setCtrlVisible("UpArrowImage", true, panel)
            self:setCtrlVisible("BChosenEffectImage", true, panel)
            self:setCtrlVisible("SChosenEffectImage", true, panel)
        else

        end
    end

    -- 删除所有二级菜单
    local function removeSmallMenu(sender)
        local items = listView:getItems()
        local removeBigTag
        for _, panel in pairs(items) do
            local tag = panel:getTag()
            --if tag % 100 ~= 0 and math.floor(tag / 100) * 100 ~= sender:getTag() then
            if tag % 100 ~= 0 then -- 重复点击也要删除二级菜单
                -- 二级菜单，删除
                --panel:removeFromParent()
                listView:removeChild(panel)
                removeBigTag = math.floor(tag / 100) * 100
            else
                self:setCtrlVisible("BChosenEffectImage", false, panel)
            end
        end
        if removeBigTag then
            setArrow(MENU_BUTTON_STATE.NORMAL, listView:getChildByTag(removeBigTag))
            sender.isSelect = false
        end
        listView:requestRefreshView()
    end

    -- 点击一级菜单回调
    local function onBigMenu(dlg, sender)
        if type(self.isCanClickBigMenu) == "function" and not self:isCanClickBigMenu(sender) then
            return
        end

        defSelectIndex = sender:getTag() / 100

        if onOneMenuCallBack then
            onOneMenuCallBack(dlg, sender)
        end

        if secondMenus then
            local isNeedNormal = false -- 再次点击，是否需要收二级菜单起来
            if sender.isSelect == true and sender.menuState == MENU_BUTTON_STATE.EXPAND then
                isNeedNormal = true
            end

            if cfgPara and cfgPara.againClickNeedNotHideTwoMenu then
                isNeedNormal = false
            end

            -- 有二级菜单，先删除所有二级菜单
            removeSmallMenu(sender)

            if sender.menuState == MENU_BUTTON_STATE.NORMAL and not isNeedNormal then
                -- 有对应的二级菜单，增加
                if secondMenus[sender:getName()] then
                    setSmallMenuListByBigMenu(sender)
                end
                setArrow(MENU_BUTTON_STATE.EXPAND, sender)
            elseif sender.menuState == MENU_BUTTON_STATE.EXPAND then
                setArrow(MENU_BUTTON_STATE.EXPAND, sender)
            elseif sender.menuState == MENU_BUTTON_STATE.NO_CHILD then
                setArrow(MENU_BUTTON_STATE.NO_CHILD, sender)
                self:setCtrlVisible("BChosenEffectImage", true, sender)
                self:setCtrlVisible("SChosenEffectImage", true, sender)
            end

            if isNeedNormal then
                self:setCtrlVisible("BChosenEffectImage", true, sender)
                self:setCtrlVisible("SChosenEffectImage", true, sender)
            end

            sender.isSelect = true
        else
            local items = listView:getItems()
            for _, panel in pairs(items) do
                self:setCtrlVisible("BChosenEffectImage", false, panel)
                self:setCtrlVisible("SChosenEffectImage", false, panel)
            end

            self:setCtrlVisible("BChosenEffectImage", true, sender)
            self:setCtrlVisible("SChosenEffectImage", true, sender)
            listView:requestRefreshView()
        end
    end

    -- 如果有一集菜单点击回调，则绑定
    if oneMenus then
        self:bindTouchEndEventListener(onePanel, onBigMenu)
    end

    -- 如果有二集菜单点击回调，则绑定
    if secondMenus then
        self:bindTouchEndEventListener(secondPanel, onSmallMenu)
    end



    local defaultFlag = false
    -- 遍历一级菜单，加入listview中
    for i, menuStr in pairs(oneMenus) do
        local panel = onePanel:clone()
        panel:setTag(i * 100)
        panel:setName(menuStr)

        self:setCtrlVisible("BChosenEffectImage", false, panel)

        self:setLabelText('Label', menuStr, panel)
        listView:pushBackCustomItem(panel)

        -- 是否有二级菜单，没有则隐藏箭头
        if secondMenus and secondMenus[menuStr] then
            setArrow(MENU_BUTTON_STATE.NORMAL, panel)
        else
            setArrow(MENU_BUTTON_STATE.NO_CHILD, panel)
        end

        if not defaultFlag and not cfgPara["one"] and not (type(self.isCanClickBigMenu) == "function" and not self:isCanClickBigMenu(panel, true)) then
            defaultFlag = true
            onBigMenu(self, panel)
        end

        if cfgPara and cfgPara["one"] and (cfgPara["one"] == menuStr or cfgPara["one"] == panel:getTag()) then
            onBigMenu(self, panel)
            defaultFlag = true
            cfgPara["one"] = nil
        end
    end

    if cfgPara and cfgPara.isScrollToDef then
        performWithDelay(self.root, function ()
            self:setListInnerPosByIndex(listView, defSelectIndex)
        end, 0)
    end

    listView:refreshView()
end

-- 定时做相关动作，时装需要循环做动作
function Dialog:displayPlayActions(panelName, root, offset, tag, actions, callback)
    local offPos
    if 'number' == type(offset) then
        offPos = cc.p(0, offset)
    elseif 'table' == type(offset) then
        offPos = offset
    end

    tag = tag or Dialog.TAG_PORTRAIT
    actions = actions or { Const.SA_ATTACK, Const.SA_CAST }
    local actKey = "act" .. tostring(tag)
    tag = tag or Dialog.TAG_PORTRAIT
    local function delayPlayAttack(panel, no)
        -- 和设置形象的偏移一致，为若nil则默认  cc.p(0, -36)        Dialog:setPortraitByArgList(argList)
        local size = panel:getContentSize()
        local function setPos()
            local charNow = panel:getChildByTag(tag)
            if not charNow then return end
            if nil ~= offPos then
                -- 获取中心点的位置坐标
                local contentSize = panel:getContentSize()
                local basicX = contentSize.width / 2 + offPos.x
                local basicY = contentSize.height / 2 + offPos.y
                charNow:setPosition(basicX, basicY)
            --else
            --    gf:align(charNow, size, ccui.RelativeAlign.centerInParent)
            end
        end

        if panel[actKey] then
            panel:stopAction(panel[actKey])
            panel[actKey] = nil
            local charNow = panel:getChildByTag(tag)
            if charNow then
                charNow:resetAction()
            end
            setPos()
        end

        local showAction = actions[(no % #actions) + 1]
        panel[actKey] = performWithDelay(panel, function ()
            local charNow = panel:getChildByTag(tag)
            if not charNow then return end

            if 'function' == type(callback) then callback(showAction) end
            if Const.SA_WALK == showAction then
                charNow:playWalkThreeTimes(function()
                    if 'function' == type(callback) then callback(Const.SA_STAND) end

                    -- 设置位置
                    setPos()

                    delayPlayAttack(panel, no + 1)
                end)
            else
            charNow:playActionOnce(function()
                    if 'function' == type(callback) then callback(Const.SA_STAND) end

                -- 设置位置
                setPos()

                delayPlayAttack(panel, no + 1)
            end, showAction)
            end
        end, 3)
    end

    local shapePanel = self:getControl(panelName, nil, root)
    delayPlayAttack(shapePanel, 0)
end

-- 禁用按钮，防止误触
function Dialog:frozeButton(name, time, root)
    local ctrl = self:getControl(name, nil, root)
    if not ctrl then return end

    time = time or 0.3  -- 防止误触，默认0.3秒
    self:setCtrlEnabled(name, false, root)
    local delay = cc.DelayTime:create(time)
    local func = cc.CallFunc:create(function()
        self:setCtrlEnabled(name, true, root)
    end)
    local action = cc.Sequence:create(delay, func)
    return ctrl:runAction(action)
end

function Dialog:setLastOperTime(key, time)
    -- 存到管理器中，下线需要全部清除
    DlgMgr:setLastTime(self.name .. key, time)
end

function Dialog:getLastOperTime(key)
    return DlgMgr:getLastTime(self.name .. key)
end

-- 检测当前时间是否已超出限制时间
function Dialog:isOutLimitTime(key, spaceTime)
    local lastTime = DlgMgr:getLastTime(self.name .. key)
    if not lastTime or gfGetTickCount() - lastTime >= spaceTime then
        return true
    end
end

-- 创建倒计时
function Dialog:createCountDown(time, ctrlName, root)
    local timePanel = self:getControl(ctrlName, nil, root)
    if not timePanel then return end

    local sz = timePanel:getContentSize()
    local numImg = NumImg.new(ART_FONT_COLOR.B_FIGHT, time, false, -5)
    numImg:setPosition(sz.width / 2, sz.height / 2)
    numImg:setName("countDown")
    timePanel:addChild(numImg)

    return numImg
end

-- 开启倒计时
function Dialog:startCountDown(time, ctrlName, root, callBack)
    local timePanel = self:getControl(ctrlName, nil, root)
    if not timePanel then return end

    local numImg = timePanel:getChildByName("countDown")
    if not numImg then return end

    numImg:setNum(time, false)
    numImg:startCountDown(callBack)

    return numImg
end

-- 停止倒计时
function Dialog:stopCountDown(ctrlName, root)
    local timePanel = self:getControl(ctrlName, nil, root)
    if not timePanel then return end

    local numImg = timePanel:getChildByName("countDown")
    if not numImg then return end

    numImg:stopCountDown()

    return numImg
end

-- 将控件 panel 移到另一个控件 parent 上
function Dialog:moveToOtherParent(panel, newParent)
    local oldParent = panel:getParent()
    if oldParent == newParent then
        return
    end

    local x, y = panel:getPosition()
    local pos = oldParent:convertToWorldSpace(cc.p(x, y))
    pos = newParent:convertToNodeSpace(pos)
    panel:setPosition(pos.x, pos.y)

    panel:retain()
    panel:removeFromParent(false)
    newParent:addChild(panel)
    panel:release()
end

function Dialog:runProgressAction(ctlName, tip, root)
    self:setLabelText(ctlName, tip, root)
    local panel = self:getControl(ctlName, nil, root)
    panel:stopAllActions()
    local i = 1
    schedule(panel, function()
        if not panel:isVisible() then
            panel:stopAllActions()
            return
        end

        self:setLabelText(ctlName, tip .. string.rep(".", i), root)
        i = i + 1
        if i > 3 then
            i = 0
        end
    end, 0.3)
end

function Dialog:hideAllDlgs(excepts)
    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()

    excepts = excepts or {}
    excepts[self.name] = 1
    DlgMgr:showAllOpenedDlg(false, excepts)
end

function Dialog:showDlgsWhenOpenHide()
    if not self.allInvisbleDlgs then return end

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil
end
