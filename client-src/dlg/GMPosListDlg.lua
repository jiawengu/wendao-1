-- GMPosListDlg.lua
-- Created by songcw Mar/06/2017
-- GM记录点信息

local GMPosListDlg = Singleton("GMPosListDlg", Dialog)

function GMPosListDlg:init()    
    self.unitPanel = self:toCloneCtrl("OnePosPanel")
    self.selectImage = self:toCloneCtrl("ChosenEffectImage", self.unitPanel)
    
    self.posStr = nil
    
    self:bindTouchEndEventListener(self.unitPanel, self.onAddEffectBtn)
    
    local x = self.root:getPosition()
    self.root:setPositionX(x + 200)
    
    self:bindDragListener("MoveButton", function(x, y)
        local posX, posY = self.root:getPosition()
        self.root:setPosition(cc.p(posX + x, posY + y))
    end)
end


function GMPosListDlg:bindDragListener(widget, func, click)
    if type(widget) ~= "userdata" then
        widget = self:getControl(widget)        
    end

    if not widget then
        return
    end

    local lastTouchPos
    local isMoving = false
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
            isMoving = false
            gf:ShowSmallTips(CHS[4300218])
        elseif eventType == ccui.TouchEventType.ended then
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


function GMPosListDlg:cleanup()
    self:releaseCloneCtrl("unitPanel")
    self:releaseCloneCtrl("selectImage")
    
    local dlg1 = DlgMgr:getDlgByName("GMManageDlg")
    if dlg1 then
        dlg1:setVisible(true)
    end

    local dlg2 = DlgMgr:getDlgByName("GMPosFileListDlg")
    if dlg2 then
        dlg2:setVisible(true)
    end
    
    if self.image then
        self.image:removeFromParent()
        self.image:release()
        self.image = nil
    end
end

function GMPosListDlg:addSelectImage(sender)
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

-- 点击后界面产生图标显示
function GMPosListDlg:onAddEffectBtn(sender, eventType)
    self.posStr = sender.posStr
    self:addSelectImage(sender)
    
    
    if self.opDlg then
        self.opDlg:onCloseButtonForGm()
        self.opDlg = nil
    end
    
    -- 打开相关界面
    local ctrlInfo = sender.ctrlInfo
    if ctrlInfo then
        local dlgName, ctrlName = string.match(sender.ctrlInfo, ";(.*Dlg):(.+) receive")
        self.opDlg = DlgMgr:openDlgForGM(dlgName, true)
        if self.opDlg then
            local ctrl = self.opDlg:getControl(ctrlName)
            if ctrl then
                ctrl:setVisible(true)
                local panel = ctrl:getParent()
                if panel then panel:setVisible(true) end
                
                
                if "WelfareDlg" == dlgName then
                    for i = 16, 0, -1 do
                        local tempPanel = self.opDlg:getControl("WelfareScrollPanel" .. i)
                        if tempPanel then
                            local ctl = self.opDlg:getControl(ctrlName, nil, tempPanel)
                            if not ctl then
                                tempPanel:removeFromParent()
                            end
                        end
                    end

                    local panel = self.opDlg:getControl("Panel", nil, "WelfareScrollView")
                    local scrollCtrl = self.opDlg:getControl("WelfareScrollView")
                    panel:setContentSize(scrollCtrl:getContentSize().width, scrollCtrl:getContentSize().height)
                    scrollCtrl:setInnerContainerSize(panel:getContentSize())
                    panel:requestDoLayout()
                end
                
            end
        end
    end
    
    if not self.image then    
        -- 创建image
        self.image = ccui.ImageView:create(ResMgr.ui.touch_pos)
        self.image:retain()    
    end
    
    self.image:removeFromParent()
--    self.image:setVisible(true)
    self.image:stopAllActions()
       
    -- 闪烁动作
    local blink = cc.Blink:create(2, 7)
    self.image:runAction(blink)
    
    -- 设置位置，放进先关场景
    local pos = gf:split(self.posStr, ",") 
    self.image:setPosition(pos[1], pos[2])
    gf:getUILayer():addChild(self.image)
    
    performWithDelay(self.image, function ()
        if self.image then
            self.image:removeFromParent()
            self.image = nil
        end
        --self.image:removeFromParentAndCleanup()
    end, 2)
end

function GMPosListDlg:setListInfo(posInfos)
    local list = self:resetListView("ListView")
    local fileList = RecordLogMgr:getPosRecordFile("fileName")
    for _, recordInfo in pairs(posInfos) do
        local panel = self.unitPanel:clone()
        
        local splitInfo = gf:splitBydelims(recordInfo, {";"})
        local posStr = splitInfo[1]
        local reTime = splitInfo[2]
        local ctrlInfo = splitInfo[4]
        
        panel.ctrlInfo = ctrlInfo
        panel.posStr = posStr
        self:setLabelText("NameLabel", posStr, panel)
        if reTime then
            reTime = string.sub(reTime, 2, -1)
            self:setLabelText("TimeLabel", os.date("%H:%M:%S", reTime), panel)
        else
            self:setLabelText("TimeLabel", "", panel)
        end
        list:pushBackCustomItem(panel)        
    end
end

return GMPosListDlg
