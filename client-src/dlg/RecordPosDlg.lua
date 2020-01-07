-- RecordPosDlg.lua
-- Created by song

local RecordPosDlg = Singleton("RecordPosDlg", Dialog)

function RecordPosDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ScreenRecordingDlg")
end

function RecordPosDlg:init()
    self.panel = self:getControl("RecordingPanel")
    gf:align(self.panel, Const.WINSIZE, ccui.RelativeAlign.alignParentTopLeft)
    self:bindDragListener(self.panel, function(x, y)
        local posX, posY = self.panel:getPosition()
        self.panel:setPosition(cc.p(posX + x, posY + y))
    end, self.onEndButton)
    
    if not self.image then    
        -- 创建image
        self.image = ccui.ImageView:create(ResMgr.ui.touch_pos)
        self.image:retain()    
    end
end

function RecordPosDlg:addEffect(x, y)
    self.image:removeFromParent()
    self.image:stopAllActions()
    
    -- 闪烁动作
    local blink = cc.Blink:create(2, 7)
    self.image:runAction(blink)

    -- 设置位置，放进先关场景
    self.image:setPosition(x, y)
    gf:getUILayer():addChild(self.image)

    performWithDelay(self.image, function ()
        self.image:removeFromParent()
        --self.image:removeFromParentAndCleanup()
    end, 2)
end

function RecordPosDlg:cleanup()
    if self.image then
        self.image:removeFromParent()
        self.image:stopAllActions()
        self.image:release()
        self.image = nil
    end
end

function RecordPosDlg:onEndButton(sender, eventType)
    DlgMgr:closeDlg("RecordPosDlg")
    RecordLogMgr:endOnceRecord()
end

function RecordPosDlg:bindDragListener(widget, func, click)
    if type(widget) ~= "userdata" then
        return
    end

    if not widget then
        Log:W("Dialog:ScreenRecordingDlg no control " .. self.name)
        return
    end

    local lastTouchPos
    local isMoving = false
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
            isMoving = false
        elseif eventType == ccui.TouchEventType.ended then
            if not self:playExtraSound(sender) then
                SoundMgr:playEffect("button")
            end

            if click and not isMoving then click(self, sender, eventType) end
        elseif eventType == ccui.TouchEventType.moved then
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y 
            if func and (math.abs(offsetX) > 5 or math.abs(offsetY) > 5) then func(offsetX, offsetY) isMoving = true end
            lastTouchPos = touchPos
        end
    end

    widget:addTouchEventListener(listener)
end

return RecordPosDlg
