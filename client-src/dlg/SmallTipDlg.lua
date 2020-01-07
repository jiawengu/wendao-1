-- SmallTipDlg.lua
-- created by cheny Nov/27/2014
-- 弹出提示对话框

local MARGIN = 10
local BACK_WIDTH = 600
local TIP_WIDTH = BACK_WIDTH - MARGIN*2
local SHOW_OFFSET_Y = 100
local SHOW_DURATION = 1.2
local MOVE_DURATION = 0.25
local HIGH_SPEED_MOVE_DURATION = 0.05
local MOVE_TAG = 100
local TIP_INTERVAL = 400
local HIGH_SPEED_TIP_INTERVAL = 100

local List = require "core/List"
local SmallTipDlg = Singleton("SmallTipDlg", Dialog)

function SmallTipDlg:open()
    self.root = cc.Layer:create()
    self.root:setLocalZOrder(self:getZOrder())
    gf:getUILayer():addChild(self.root)
    self.list = List.new()
    self:align(ccui.RelativeAlign.centerInParent)
    self.actionTips = {}
    self.lastTime = 0
    self.hasStopAction = nil

    self.listener = function() DlgMgr:closeDlg(self.name) end
    EventDispatcher:addEventListener("clearGameData",  self.listener)

    -- 由于open被重载, 必须自行设置更新函数
    self.root:scheduleUpdateWithPriorityLua(function() self:onUpdate() end, 0)

    self:hookMsg("MSG_ENTER_ROOM")
end

function SmallTipDlg:cleanup()
    self:cleanData()
    if self.listener then
        EventDispatcher:removeEventListener("clearGameData", self.listener)
        self.listener = nil
    end
end

function SmallTipDlg:getZOrder()
    return SmallTipsMgr:getLocalZOrder()-- Const.ZORDER_SMALLTIP
end

function SmallTipDlg:generateTip(str)
    -- 生成颜色字符串控件
    local tip = CGAColorTextList:create()
    tip:setFontSize(19)
    tip:setString(str)
    tip:setContentSize(TIP_WIDTH, 0)
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip:setPosition(MARGIN, h + MARGIN)

    local layer = ccui.Layout:create()
    layer:setBackGroundImage(ResMgr.ui.small_tip, ccui.TextureResType.plistType)
    layer:setBackGroundImageScale9Enabled(true)
    layer:setContentSize(cc.size(w + MARGIN*2, h + MARGIN*2))
    layer:setPosition(Const.WINSIZE.width/2, Const.WINSIZE.height/2 - SHOW_OFFSET_Y)
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)
    local colorLayer = tolua.cast(tip, "cc.LayerColor")
    layer:addChild(colorLayer)
    layer:setCascadeOpacityEnabled(true) --将透明度对子节点生效

    return layer
end

function SmallTipDlg:moveTo(tip, x, y)
    if nil == tip then
        return
    end

    local moveDuration
    if self.list:size() > 5 then
        -- 如果在加快TIP输出速度后，缓存的TIP数量仍然过多，则加快TIP的移动速度
        moveDuration = HIGH_SPEED_MOVE_DURATION
    end

    local move = cc.MoveTo:create(moveDuration or MOVE_DURATION, cc.p(x, y))
    local fadeIn = cc.FadeIn:create(moveDuration or MOVE_DURATION)
    local action = cc.Spawn:create(move, fadeIn)
    action:setTag(MOVE_TAG)

    tip = tolua.cast(tip, "cc.LayerColor")
    if tip and tip:getActionByTag(MOVE_TAG) then tip:stopActionByTag(MOVE_TAG) end
    tip:runAction(action)
end

function SmallTipDlg:fadeOut(tip)
    local function remove()
        -- 必须清除数据,防止正在运行的动作执行报错
        tip:removeFromParent(true)
    end

    if nil == tip then
        return
    end


    local move = cc.MoveBy:create(MOVE_DURATION, cc.p(0, tip:getContentSize().height))
    local fadeOut = cc.FadeOut:create(MOVE_DURATION)
    tip:stopAllActions()
    tip:runAction(cc.Sequence:create(cc.Spawn:create(move, fadeOut), cc.CallFunc:create(remove)))
end

function SmallTipDlg:addTip(str)
    if nil == str then return end
    local curTip = self:generateTip(str)
    curTip:setVisible(false)
    self.list:pushBack(curTip)
    self.root:addChild(curTip)
end

function SmallTipDlg:onUpdate()
    if not MapMgr.isLoadEnd and DlgMgr:isVisible("LoadingDlg") then
        return
    end

    if self.list:size() <= 0 then
        if self.hasStopAction and #self.actionTips > 0 then
            -- 重新开启停掉的定时器
            local curTip = self.actionTips[#self.actionTips]
            if curTip then
                self:doMoveTo(curTip)
            end
        end

        return
    end

    local needToSpeedUpTip
    local curTime = gfGetTickCount()
    if self.list:size() > 3 and curTime - self.lastTime > HIGH_SPEED_TIP_INTERVAL then
        -- 缓存信息过多，需要加快TIP的输出速度
        needToSpeedUpTip = true
    end

    if curTime - self.lastTime >= TIP_INTERVAL or needToSpeedUpTip then
        -- 重置
        self.lastTime = curTime

        -- 显示一条
        local tip = self.list:popFront()
        table.insert(self.actionTips, tip)
        self:doAction(tip)
    end

end

function SmallTipDlg:removeTip(tip)
    if not tip then
        tip = self.actionTips[1]
        table.remove(self.actionTips, 1)
    else
        for i = 1, #self.actionTips do
            if self.actionTips[i] == tip then
                table.remove(self.actionTips, i)
                break
            end
        end
    end

    self:fadeOut(tip)
end

function SmallTipDlg:doMoveTo(curTip)
    -- 屏幕中点
    local cx, cy = Const.WINSIZE.width / 2, Const.WINSIZE.height / 2

    -- 最后一条在中间
    cy = cy - curTip:getContentSize().height/2
    local size = self.list:size()
    for i = 1, #self.actionTips do
        local tip = self.actionTips[i]
        cy = cy + tip:getContentSize().height
    end

    for i = 1, #self.actionTips do
        local tip = self.actionTips[i]
        cy = cy - tip:getContentSize().height
        self:moveTo(tip, cx, cy)

        if tip.lastActionTime then
            -- 重新开启停掉的定时器
            self:setRemoveAction(tip, tip.lastActionTime)
            tip.lastActionTime = nil
        end
    end

    self.hasStopAction = nil
end

function SmallTipDlg:setRemoveAction(tip, delayTime)
    local function remove()
        self:removeTip(tip)
    end

    local seq = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(remove))
    tip:runAction(seq)
end

function SmallTipDlg:doAction(curTip)

    if self.actionTips and #self.actionTips > 4 then
        -- 加快了TIP输出速度，导致可见的TIP过多，需要限制界面中显示的TIP数量
        self:removeTip()
    end

    curTip:setVisible(true)
    curTip:setOpacity(0)

    self:doMoveTo(curTip)

    self:setRemoveAction(curTip, SHOW_DURATION)
    curTip.startTime = gfGetTickCount()
end

function SmallTipDlg:MSG_ENTER_ROOM()
    if not MapMgr.isLoadEnd and DlgMgr:isVisible("LoadingDlg") and not self.hasStopAction then
        local curTime = gfGetTickCount()
        local lastTime
        for _, v in pairs(self.actionTips)do
            lastTime = SHOW_DURATION - (curTime - v.startTime) / 1000
            if lastTime > 0.2 then
                -- 剩余时间过短，缓存没有意义，所以大于 0.2 才处理
                v:stopAllActions()
                v.lastActionTime = lastTime
                self.hasStopAction = true
            end
        end
    end
end

-- 清除数据
function SmallTipDlg:cleanData()
    for i = 1, #self.actionTips do
        self.actionTips[i]:stopAllActions()
        self.actionTips[i]:removeFromParent(true)
    end

    self.list = List.new()
    self.actionTips = {}
end

return SmallTipDlg
