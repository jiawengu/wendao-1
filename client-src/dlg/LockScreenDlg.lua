-- LockScreenDlg.lua
-- Created by songcw
-- 锁屏界面

local LockScreenDlg = Singleton("LockScreenDlg", Dialog)

function LockScreenDlg:init()

    -- 置顶
    self.blank:setLocalZOrder(Const.LOADING_DLG_ZORDER + 1)
    self.root:setGlobalZOrder(Const.LOADING_DLG_ZORDER + 1)
    self:getControl("Panel_11"):setGlobalZOrder(Const.LOADING_DLG_ZORDER + 1)
    local contentSize = self.root:getContentSize()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    self.root:requestDoLayout()

    --[[ 走马灯
    self.lampNum = 0
    self.isMove = false
    schedule(self.root, function() self:setLamp() end, 0.5)
    --]]
    -- 解除屏幕锁定文字
    self:setCtrlVisible("TipImage", false)

    self.magic = gf:createLoopMagic(ResMgr.magic.sys_lock)
    local panel = self:getControl("LockFrameImage")
    self.magic:setPosition(panel:getContentSize().width * 0.5 - 5, panel:getContentSize().height * 0.5)
    panel:addChild(self.magic)

    performWithDelay(self.root,function ()
        self.lockImage = self:getControl("LockButtonImage")
        local panel = self:getControl("Panel_11")
        self.lockRect = self:getBoundingBoxInWorldSpace(self.lockImage)
        self.lockIsClick = false
        local function onTouchesBegan(touche, eventType)
            if self.lockIsClick then return false end
            if cc.rectContainsPoint(self.lockRect, touche:getLocation()) then
                self.lockIsClick = true
                self.startLockTime = gfGetTickCount()
                return true
            end
            Log:D("%f:::::::::::%f", self.lockRect.x, touche:getLocation().x)
            return false
        end

        local function onTouchesMoved(touche, eventType)
            if self.lockIsClick then
                self.isMove = true
                self.magic:setVisible(false)
                local ctrlPos = panel:convertToNodeSpace(touche:getLocation())
                local posX = ctrlPos.x
                if posX < 0 then posX = 0 end
                local width = panel:getContentSize().width
                if posX > width then posX = width end
                self.lockImage:setPositionX(posX)
            end
            return true
        end

        local function onTouchesEnd(touche, eventType)
            if self.lockIsClick then
                -- local ctrlPos = panel:convertToNodeSpace(touche:getLocation())
                -- local posX = ctrlPos.x
                local posX = self.lockImage:getPositionX()
                if posX < 0 then posX = 0 end
                if posX >= panel:getContentSize().width and gfGetTickCount() - self.startLockTime > 200 then
                    posX = panel:getContentSize().width
                    self.lockIsClick = false

                    local disp = cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(function()
                        self:onCloseButton()
                    end))

                    self.root:runAction(disp)
                else
                    self.lockImage:stopAllActions()
                    local moveRight = cc.EaseSineIn:create(cc.MoveTo:create(0.3, cc.p(0, self.lockImage:getPositionY())))
                    self.lockImage:runAction(cc.Sequence:create(moveRight, cc.CallFunc:create(function()
                        self.isMove = nil
                        self.magic:setVisible(true)
                    end)))
                end
            end
            self.lockIsClick = false
            self.startLockTime = 0
            return true
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCH_ENDED )
        listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCH_CANCELLED)


        local dispatcher = panel:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)


    end, 0)

end

function LockScreenDlg:setLamp()
    if self.isMove then return end
    for i = 1,4 do
        self:setCtrlVisible("WaitImage" .. i, false)
    end
    self:setCtrlVisible("WaitImage" .. (self.lampNum + 1), true)
    self.lampNum = self.lampNum + 1
    self.lampNum = self.lampNum % 4
end

function LockScreenDlg:showTipImage()
    local image = self:getControl("TipImage")
    image:setVisible(true)
    image:setOpacity(255)
    image:stopAllActions()

    local fadeOutAct = cc.EaseSineIn:create(cc.FadeOut:create(2.5))
    image:runAction(fadeOutAct)
end

function LockScreenDlg:close()
    Dialog.close(self)
end

return LockScreenDlg
