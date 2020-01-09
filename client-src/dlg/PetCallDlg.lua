-- PetCallDlg.lua
-- Created by sujl, Nov/14/2016
-- 骑宠召唤界面

local PetCallDlg = Singleton("PetCallDlg", Dialog)

-- 光效对应的TAG值，方便动画移除
local MAGIC_TAG = {
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top01"] = 1001,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top0102"] = 1010,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top02"] = 1002,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top03"] = 1003,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top04"] = 1004,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top05"] = 1005,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top06"] = 1006,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top07"] = 1007,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top08"] = 1008,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Top09"] = 1009,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom01"] = 1061,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom02"] = 1062,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom03"] = 1063,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom0302"] = 1067,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom04"] = 1064,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom0402"] = 1068,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom05"] = 1065,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom06"] = 1066,
    [ResMgr.ArmatureMagic.pet_call_beckones.name .. "/Bottom0602"] = 1069,
    [ResMgr.ArmatureMagic.pet_call_lingpo.name .. "/Top01"] = 2001,
    [ResMgr.ArmatureMagic.pet_call_lingpo.name .. "/Top02"] = 2002,
    [ResMgr.ArmatureMagic.pet_call_lingpo.name .. "/Top03"] = 2003,
    [ResMgr.ArmatureMagic.pet_call_lingpo.name .. "/Top04"] = 2004,
}

local SUMMON_COST_ONE = 5000000
local SUMMON_COST_TEN = 50000000

-- 对话框初始化
function PetCallDlg:init()
    self:setFullScreen()
    self.blank:setLocalZOrder(-1)

    self:bindListener("ReturnPanel", self.onCloseButton)
    self:bindListener("BaitButtonPanel_1", self.onBaitButton1)
    self:bindListener("BaitButtonPanel_2", self.onBaitButton2)
    self:bindListener("CallButton", self.onCallButton, "CallButtonPanel")
    self:bindListener("CallButton_1", self.onCallButton, "CallButtonPanel")
    self:bindListener("BaitPanel", self.onAddBait)
    self:bindListener("MoneyPanel", self.onAddMoney)
    self:bindListener("InfoButton", self.onInfoButton)

    self.panel = self:getControl("SoulPanel")
    self.panel:setVisible(true)
    self.touchPanel = self:getControl("CenterPanel")
    self.baitButtonPanel1 = self:getControl("BaitButtonPanel_1")
    self.baitButtonPanel2 = self:getControl("BaitButtonPanel_2")

    self:setCtrlVisible("CallButtonPanel", false)
    self.disableTouch = false

    -- 为方便拖动时修改位置，将锚点全部调整为中心
    for i = 1, 8 do
        local panel = self:getControl(string.format("SoulPanel_%d", i), Const.UIPanel, "SoulPanel")
        panel:setAnchorPoint(0.5, 0.5)
    end

    self:bindSoulPanel("SoulPanel")
    self:setCtrlVisible("SoulPanel", false)

    -- 设置适配
    local winSize = cc.Director:getInstance():getWinSize()
    local rootHeight = winSize.height / Const.UI_SCALE
    local rootWidth = winSize.width / Const.UI_SCALE

    -- 加载背景图
    local createBcak = ccui.ImageView:create(ResMgr.ui.call_pet_back)
    createBcak:setPosition(rootWidth / 2, rootHeight / 2)
    createBcak:setAnchorPoint(0.5,0.5)
    self.blank:addChild(createBcak)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(createBcak:getOrderOfArrival())
    createBcak:setOrderOfArrival(order)
    self.createBcak = createBcak

    self.root:requestDoLayout()

    -- 播放界面初始动画
    self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom01", nil, function()
        self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom02")
        self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom01")
        self.baitButtonPanel1:setTouchEnabled(true)
        self.baitButtonPanel2:setTouchEnabled(true)
    end)

    -- 按钮淡入
    self.baitButtonPanel1:setTouchEnabled(false)
    self.baitButtonPanel1:setOpacity(0)
    self.baitButtonPanel1:runAction(cc.Sequence:create(cc.FadeIn:create(1.42)))
    self.baitButtonPanel2:setTouchEnabled(false)
    self.baitButtonPanel2:setOpacity(0)
    self.baitButtonPanel2:runAction(cc.Sequence:create(cc.FadeIn:create(1.42)))

    self:initData()

    self:hookMsg('MSG_SUMMON_MOUNT_RESULT')
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SUMMON_MOUNT_NOTIFY")
end

function PetCallDlg:cleanup()
    self.disableTouch = false
    self.num = nil
    self.callData = nil
    self.responseCallback = nil
    self.curPetId = nil
    self.onShowPet = nil
    self.delayAction = nil
    self.disableTouch = nil
    self.curTouch = nil

    -- 尝试关闭等待界面
    DlgMgr:closeDlg("WaitDlg")
end

-- 初始化数据
function PetCallDlg:initData()
    self:refreshItem()
    self:refreshCash()
end

function PetCallDlg:refreshCost()
    local cost
    if 1 == self.num then
        self.curCost = SUMMON_COST_ONE
    elseif 10 == self.num then
        self.curCost = SUMMON_COST_TEN
    end

    local costText, costColor = gf:getArtFontMoneyDesc(self.curCost)
    self:setNumImgForPanel("NumLabelPanel", costColor, costText, false, LOCATE_POSITION.LEFT_TOP, 19, "CallButtonPanel")
end

-- 刷新道具
function PetCallDlg:refreshItem()
    local items = InventoryMgr:getItemByName(CHS[2200001])
    local amount = 0
    for i = 1, #items do
        amount = amount + items[i].amount
    end

    self:setLabelText("NumLabel", amount, "BaitPanel")
end

-- 刷新金钱
function PetCallDlg:refreshCash()
    local cashText, cashColor = gf:getMoneyDesc(Me:queryInt("cash"), true)
    self:setLabelText("NumLabel", cashText, "MoneyPanel", cashColor)
end

-- 播放骨骼动画
function PetCallDlg:createArmatureAction(showPanel, icon, actionName, zorder, callback)
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)

            if callback and "function" == type(callback) then callback() end
        end
    end

    if 'string' == type(showPanel) then
        showPanel = self:getControl(showPanel)
    end

    showPanel:setVisible(true)
    magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    if zorder then
        magic:setLocalZOrder(zorder)
    end

    local tag = MAGIC_TAG[string.format("%s/%s", icon, actionName)]
    if tag and 'number' == type(tag) then
        magic:setTag(tag)
    else
        gf:ShowSmallTips("Invalid args:" .. string.format("%s/%s", icon, actionName))
    end
    showPanel:addChild(magic)

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actionName)

    return magic
end

-- 移除骨骼动画
function PetCallDlg:removeMagic(showPanel, icon, action)
    local tag = MAGIC_TAG[string.format("%s/%s", icon, action)]
    local ob = showPanel:getChildByTag(tag)
    if ob then
        ob:removeFromParent(true)
    end
end

-- 批量移除骨骼动画
function PetCallDlg:removeMagics(root, name, ...)
    local action
    for i = 1, select('#', ...) do
        action = select(i, ...)
        self:removeMagic(root, name, action)
    end
end

-- 是否含有某个动画
function PetCallDlg:getMagic(root, icon, action)
    local tag = MAGIC_TAG[string.format("%s/%s", icon, action)]
    local ob = root:getChildByTag(tag)
    return ob
end

-- 绑定精魄拖动事件
function PetCallDlg:bindSoulPanel(panel)
    if 'string' == type(panel) then
        panel = self:getControl(panel)
    end

    --panel:setAnchorPoint(0.5, 0.5)
    local function onTouchesBegan(touche, eventType)
            -- 拖动开始

            -- 面板不可见
            if not self:getCtrlVisible("SoulPanel") or self.disableTouch or self.curTouch then return false end

            local ctrl
            local magic
            for i = 1, 8 do
                ctrl = self:getControl(string.format("SoulPanel_%d", i))
                local rect = self:getBoundingBoxInWorldSpace(ctrl)

                -- 先检查是否有精魄被选中
                if ctrl:isVisible() and cc.rectContainsPoint(rect, touche:getLocation()) then
                    self.curTouch = ctrl
                    self:doOper()
                    -- self.curTouch:setAnchorPoint(0.5, 0.5)
                    local x, y = ctrl:getPosition()
                    self.curTouchPos = {["x"] = x, ["y"] = y}

                    local big = cc.ScaleTo:create(0.3, 1.3)
                    local small = cc.ScaleTo:create(0.2, 1.2)
                    local scaleAction = cc.Sequence:create(big, small)
                    self.curTouch:stopAllActions()
                    self.curTouch:setScale(1)
                    self.curTouch:runAction(scaleAction)

                    local quad = self.curTouch:getChildByTag(5001)
                    if not quad then
                        quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath(string.format("particlestar%s", 10 == self.num and "2" or "")))
                        local size = self.curTouch:getContentSize()
                        --quad:setPosition(size.width / 2, size.height / 2)
                        local wp = self.curTouch:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
                        local lp = self.root:convertToNodeSpace(wp)
                        quad:setPosition(lp.x, lp.y)
                        --local zorder = self:getControl("TextImage", Const.UIImage, self.curTouch):getLocalZOrder()
                        quad:setTag(5001)
                        self.root:addChild(quad)
                        self.curQuad = quad
                    end

                    quad = self.root:getChildByTag(5003)
                    if quad then
                        quad:removeFromParent(true)
                    end

                    quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath(string.format("Particledianji%s", 10 == self.num and "2" or "")))
                    local size = self.curTouch:getContentSize()
                    quad:setPosition(size.width / 2, size.height / 2)
                    quad:setTag(5003)
                    quad:setAutoRemoveOnFinish(true)
                    self.curTouch:addChild(quad)
                end

                if self.curTouch then
                    -- 被选中了，其他精魄半透明化
                    for i = 1, 8 do
                        ctrl = self:getControl(string.format("SoulPanel_%d", i))
                        if ctrl ~= self.curTouch then
                            local tag
                            if 1 == self.num then
                                tag = MAGIC_TAG[string.format("%s/%s", ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top01")]
                            elseif 10 == self.num then
                                tag = MAGIC_TAG[string.format("%s/%s", ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top02")]
                            end

                            magic = ctrl:getChildByTag(tag)
                            if magic then
                                magic:setOpacity(77)
                            end
                        end
                    end
                end
            end
            return self.curTouch ~= nil
        end

        local function onTouchesMoved(touche, eventType)
            -- 拖动中，设置精魄位置
            local ctrlPos = self.panel:convertToNodeSpace(touche:getLocation())
            if self.curTouch then
                self.curTouch:setPosition(ctrlPos)

                if self.curQuad then
                    local quad = self.curQuad
                    local size = self.curTouch:getContentSize()
                    local wp = self.curTouch:convertToWorldSpace(cc.p(size.width / 2, size.height / 2))
                    local lp = self.root:convertToNodeSpace(wp)
                    quad:setPosition(lp.x, lp.y)
                end
            end
            return true
        end

        local function onTouchesEnd(touche, eventType)
            -- 拖动结束
            if not self.curTouch then return end

            local action
            if 1 == self.num then
                action = "Top03"
            elseif 10 == self.num then
                action = "Top04"
            end

            -- 取消拖动
            local function cancelDrag()
                local ctrl
                local magic
                self.curTouch:stopAllActions()
                for i = 1, 8 do
                    ctrl = self:getControl(string.format("SoulPanel_%d", i))
                    ctrl:setScale(1)
                    local tag
                    if 1 == self.num then
                        tag = MAGIC_TAG[string.format("%s/%s", ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top01")]
                    elseif 10 == self.num then
                        tag = MAGIC_TAG[string.format("%s/%s", ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top02")]
                    end
                    magic = ctrl:getChildByTag(tag)
                    if magic then
                        magic:setOpacity(255)
                    end
                end
                self.curTouch:setPosition(self.curTouchPos.x, self.curTouchPos.y)
                self:idleOper()
            end

            local touchRect = self:getBoundingBoxInWorldSpace(self.touchPanel)
            if cc.rectContainsPoint(touchRect, touche:getLocation()) then
                -- 拖动到中央区域

                repeat
                    -- 尝试召唤精怪
                    if not self:tryCallPet() then
                        -- 召唤失败
                        cancelDrag()
                        break
                    end

                    -- 禁用拖动
                    self.disableTouch = true

                    self:createArmatureAction(self.touchPanel, ResMgr.ArmatureMagic.pet_call_lingpo.name, action, nil, function()
                        -- 播放召唤动画结束

                        self:doOper()

                        -- 开始播放宠物获得动画
                        self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom04%s", 10 == self.num and "02" or ""))

                        -- 播放动画并领取宠物
                        local function doTakePet()
                            self:takeCallPet()
                            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom06%s", 10 == self.num and "02" or ""), nil, function()
                                self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom06%s", 10 == self.num and "02" or ""))
                            end)
                            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Top01%s", 10 == self.num and "02" or ""), nil, function()
                                local function showPet()
                                    local dlg = DlgMgr:openDlg("GetElitePetDlg")
                                    -- dlg:setDlgInfo(self.callData.name, NOTIFY.NOTICE_BUY_ELITE_PET)
                                    dlg:setPet(PetMgr:getPetById(self.curPetId))
                                    dlg:setNotifyDlg(self.name)
                                    DlgMgr:closeDlg("WaitDlg")
                                    self.curPetId = nil
                                    self.onShowPet = nil
                                    self.num = nil
                                end

                                if self.curPetId then
                                    showPet()
                                else
                                    DlgMgr:openDlg("WaitDlg")
                                    self.onShowPet = showPet
                                end

                                local action = cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
                                    self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Top01%s", 10 == self.num and "02" or ""))
                                    self.root:removeChildByTag(5002)
                                end))

                                self:setCtrlVisible("TextImage_1", true, "TipsPanel")
                                self:setCtrlVisible("TextImage_2", false, "TipsPanel")
                            end)

                            local quad = self.root:getChildByTag(5002)
                            if quad then
                                quad:removeFromParent(true)
                            end

                            quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath("Particlebaozha"))
                            local size = self.root:getContentSize()
                            quad:setPosition(size.width / 2, size.height / 2)
                            quad:setTag(5002)
                            self.root:addChild(quad)

                            DlgMgr:closeDlg("WaitDlg")

                            self.responseCallback = nil
                        end

                        -- self.callData = { name = "北极熊" }

                        -- 领取宠物
                        if self.callData then
                            -- 服务器已经返回宠物信息，播放领取动画
                            doTakePet()
                        else
                            DlgMgr:openDlg("WaitDlg")
                            self.responseCallback = doTakePet
                        end

                    end)
                    for i = 1, 8 do
                        local ctrl = self:getControl(string.format("SoulPanel_%d", i))
                        ctrl:setScale(1)
                        local actionName
                        if 1 == self.num then actionName = "Top01"
                        elseif 10 == self.num then actionName = "Top02"
                        end

                        local magic = ctrl:getChildByTag(MAGIC_TAG[string.format("%s/%s", ResMgr.ArmatureMagic.pet_call_lingpo.name, actionName)])
                        if ctrl ~= self.curTouch then
                            local disp = cc.Sequence:create(cc.FadeOut:create(0.5), cc.CallFunc:create(function()
                                magic:removeFromParent(true)
                                ctrl:setVisible(false)
                            end))
                            magic:runAction(disp)
                        else
                            magic:removeFromParent(true)
                            ctrl:setVisible(false)
                        end
                    end
                    self.curTouch:setPosition(self.curTouchPos.x, self.curTouchPos.y)
                until true
            else
                -- 拖动取消
                cancelDrag()
            end

            if self.curQuad then
                self.curQuad:removeFromParent(true)
            end

            self.curTouch = nil
            return true
        end

        local listener = cc.EventListenerTouchOneByOne:create()
        listener:setSwallowTouches(true)
        listener:registerScriptHandler(onTouchesBegan, cc.Handler.EVENT_TOUCH_BEGAN )
        listener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCH_ENDED )
        listener:registerScriptHandler(onTouchesMoved, cc.Handler.EVENT_TOUCH_MOVED)
        listener:registerScriptHandler(onTouchesEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

        local dispatcher = panel:getEventDispatcher()
        dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 检查召唤条件
function PetCallDlg:checkCallPet()
    local items = InventoryMgr:getItemByName(CHS[2200001])
    local amount = 0
    for i = 1, #items do
        amount = amount + items[i].amount
    end

    -- 道具不足
    if amount < self.num then
        gf:askUserWhetherBuyItem({[CHS[2200001]] = self.num - amount})
        return false
    end

    -- 金钱不足
    if Me:queryBasicInt("cash") < self.curCost then
        gf:askUserWhetherBuyCash(self.curCost - Me:queryBasicInt("cash"))
        return false
    end

    if PetMgr:getFreePetCapcity() == 0 then
        gf:ShowSmallTips(CHS[3003072])
        return false
    end

    return true
end

-- 尝试召唤
function PetCallDlg:tryCallPet()
    if not self:checkCallPet() then return end

    -- 请求服务器召唤精怪
    if 1 == self.num then
        PetMgr:requestMount(1)
    elseif 10 == self.num then
        PetMgr:requestMount(2)
    end

    return true
end

-- 领取召唤到的宠物
function PetCallDlg:takeCallPet()
    -- 请求服务器领取召唤精怪
    if 1 == self.num then
        PetMgr:requestMount(3)
    elseif 10 == self.num then
        PetMgr:requestMount(4)
    end
end

-- 设置召唤
function PetCallDlg:doBait(num)
    self:setCtrlVisible("CallButtonPanel", true)
    self:setCtrlVisible("CallButton", num == 1, "CallButtonPanel")
    self:setCtrlVisible("CallButton_1", num == 10, "CallButtonPanel")

    self:setCtrlVisible("BaitButtonImage_2", num == 1, "BaitButtonPanel_1")
    self:setCtrlVisible("BaitButtonImage_2", num == 10, "BaitButtonPanel_2")

    self.num = num  -- 召唤类型:1/10

    self:refreshCost()
end

-- 开始操作
function PetCallDlg:doOper()
    if not self.delayAction then return end

    self.root:stopAction(self.delayAction)
    -- self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom04")
    self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom03%s", 10 == self.num and "02" or ""))
    if not self:getMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom04%s", 10 == self.num and "02" or "")) then
        self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom04%s", 10 == self.num and "02" or ""), nil, function()
            self.delayAction = nil
        end)
    end

    self.delayAction = nil
end

-- 停止操作
function PetCallDlg:idleOper(delayTime)
    if self.delayAction then return end

    delayTime = delayTime or 10

    self.delayAction = performWithDelay(self.root, function()
        self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom04%s", 10 == self.num and "02" or ""))
        if not self:getMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom03%s", 10 == self.num and "02" or "")) then
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom03%s", 10 == self.num and "02" or ""), nil, function()
                self.delayAction = nil
            end)
        end
    end, delayTime)
end

function PetCallDlg:showDust(posCtrl, order)
    local quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath("particleyanwu"))
    local size = quad:getContentSize()
         local x, y = posCtrl:getPosition()
    local wp = posCtrl:getParent():convertToWorldSpace(cc.p(x + size.width / 2, y + size.height / 2))
    local lp = self.root:convertToNodeSpace(wp)
    quad:setPosition(lp.x, lp.y)
    if order then quad:setLocalZOrder(order) end
    quad:setAutoRemoveOnFinish(true)
    self.root:addChild(quad)
end

function PetCallDlg:onDlgClose(dlgName)
    if 'GetElitePetDlg' ~= dlgName then return end

    self:setCtrlVisible("BaitButtonPanel_1", true)
    self:setCtrlVisible("BaitButtonPanel_2", true)
    self:setCtrlVisible("BaitButtonImage_2", false, "BaitButtonPanel_1")
    self:setCtrlVisible("BaitButtonImage_2", false, "BaitButtonPanel_2")

    -- 显示精魄面板
    self:setCtrlVisible("SoulPanel", false)
    self.disableTouch = false

    -- 播放界面初始动画
    self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom02")
end

-- 普通召唤
function PetCallDlg:onBaitButton1(sender, eventType)
    if not self.num then
        -- 开始普通召唤
        self:removeMagics(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, 'Top02', 'Top03', 'Top04', 'Top05', 'Top06', 'Top07')

        local magic = self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top02", self.root:getLocalZOrder() + 1, function()
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top06")
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top02")
        end)

        local zorder = magic:getLocalZOrder() - 1
        local quadParent = self:getControl("DustPanel_1", Const.UIPanel, "DustPanel")
        quadParent:runAction(cc.Sequence:create(cc.DelayTime:create(0.12), cc.CallFunc:create(function()
            self:showDust(quadParent, zorder)
        end)))
    elseif 1 ~= self.num then
        -- 高级召唤 --> 普通召唤
        self:removeMagics(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, 'Top02', 'Top03', 'Top04', 'Top05', 'Top07')
        self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top05", nil, function()
            if not self:getMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top06") then
                self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top06")
            end
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top05")
        end)
    end
    self:doBait(1)
end

-- 高级召唤
function PetCallDlg:onBaitButton2(sender, eventType)
    if not self.num then
        -- 开始高级召唤
        self:removeMagics(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, 'Top02', 'Top03', 'Top04', 'Top05', 'Top06', 'Top07')
        local magic = self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top03", self.root:getLocalZOrder() + 1, function()
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top06")
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top07")
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top03")
        end)
        local zorder = magic:getLocalZOrder() - 1
        for i = 1, 5 do
            local quadParent = self:getControl(string.format("DustPanel_%d", i), Const.UIPanel, "DustPanel")
            quadParent:runAction(cc.Sequence:create(cc.DelayTime:create(0.12), cc.CallFunc:create(function()
                self:showDust(quadParent, zorder)
            end)))
        end
    elseif 10 ~= self.num then
        -- 普通召唤 --> 高级召唤
        self:removeMagics(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, 'Top02', 'Top03', 'Top04', 'Top05', 'Top07')
        local magic = self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top04", self.root:getLocalZOrder() + 1, function()
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top07", self.root:getLocalZOrder() + 1)
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top04")
        end)

        local zorder = magic:getLocalZOrder() - 1
        for i = 2, 5 do
            local quadParent = self:getControl(string.format("DustPanel_%d", i), Const.UIPanel, "DustPanel")
            quadParent:runAction(cc.Sequence:create(cc.DelayTime:create(0.12), cc.CallFunc:create(function()
                self:showDust(quadParent, zorder)
            end)))
        end
    end
    self:doBait(10)
end

-- 召唤精怪
-- 打开精怪召唤面板
function PetCallDlg:onCallButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onCallButton", sender, eventType) then
        return
    end

    if not self:checkCallPet() then return end

    self:setCtrlVisible("CallButtonPanel", false)

    self:removeMagics(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top06", "Top07")

    if 1 == self.num then
        -- 播放普通召唤面板动画
        self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top08", nil, function()
            -- 停止播放Bottom02
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom02")
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top08")
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, string.format("Bottom06%s", 10 == self.num and "02" or ""), nil, function()
                self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom06")
                self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom04")
            end)

            -- 显示精魄面板
            self:setCtrlVisible("SoulPanel", true)
            self.disableTouch = true

            for i = 1, 8 do
                local panel = string.format("SoulPanel_%d", i)
                local zorder = self:getControl("TextImage", Const.UIImage, panel):getLocalZOrder()
                local action = cc.Sequence:create(cc.DelayTime:create(0.125 * (i - 1)), cc.CallFunc:create(function()
                    local m = self:createArmatureAction(panel, ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top01", zorder - 5)
                    m:setScale(0)
                    local big = cc.ScaleTo:create(0.2, 1)

                    local func
                    if 8 == i then
                        func = cc.CallFunc:create(function()
                            local key = string.format("first_call_pet_%s", tostring(Me:queryBasic("gid")))
                            if cc.UserDefault:getInstance():getBoolForKey(key) then
                                self:idleOper()
                            else
                                self:idleOper(0)
                            end

                            cc.UserDefault:getInstance():setBoolForKey(key, true)
                            cc.UserDefault:getInstance():flush()

                            self:setCtrlVisible("TextImage_1", false, "TipsPanel")
                            self:setCtrlVisible("TextImage_2", true, "TipsPanel")

                            self.disableTouch = false
                        end)
                    end
                    local scaleAction = cc.Sequence:create(big, func)
                    m:runAction(scaleAction)
                end))

                self:getControl(panel):runAction(action)
            end
        end)
    elseif 10 == self.num then
        -- 播放普通召唤面板动画
        self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top09", nil, function()
            -- 停止播放Bottom02
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom02")
            self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Top09")
            self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom0602", nil, function()
                self:removeMagic(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom0602")
                self:createArmatureAction(self.root, ResMgr.ArmatureMagic.pet_call_beckones.name, "Bottom0402")
            end)

            -- 显示精魄面板
            self:setCtrlVisible("SoulPanel", true)
            self.disableTouch = true

            for i = 1, 8 do
                local panel = string.format("SoulPanel_%d", i)
                local zorder = self:getControl("TextImage", Const.UIImage, panel):getLocalZOrder()
                local action = cc.Sequence:create(cc.DelayTime:create(0.125 * (i - 1)), cc.CallFunc:create(function()
                    -- self:createArmatureAction(panel, ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top01", zorder - 5)
                    local m = self:createArmatureAction(panel, ResMgr.ArmatureMagic.pet_call_lingpo.name, "Top02", zorder - 5)
                    -- m:setOpacity(0)
                    -- m:runAction(cc.Sequence:create(cc.FadeIn:create(1)))
                    m:setScale(0)
                    local big = cc.ScaleTo:create(0.2, 1)

                    local func
                    if 8 == i then
                        func = cc.CallFunc:create(function()
                            local key = string.format("first_call_pet_%s", tostring(Me:queryBasic("gid")))
                            if cc.UserDefault:getInstance():getBoolForKey(key) then
                                self:idleOper()
                            else
                                self:idleOper(0)
                            end

                            cc.UserDefault:getInstance():setBoolForKey(key, true)
                            cc.UserDefault:getInstance():flush()

                            self:setCtrlVisible("TextImage_1", false, "TipsPanel")
                            self:setCtrlVisible("TextImage_2", true, "TipsPanel")

                            self.disableTouch = false
                        end)
                    end

                    local scaleAction = cc.Sequence:create(big, func)
                    m:runAction(scaleAction)
                end))

                self:getControl(panel):runAction(action)
            end
        end)
    end

    self:setCtrlVisible("BaitButtonPanel_1", false)
    self:setCtrlVisible("BaitButtonPanel_2", false)
end

function PetCallDlg:onAddBait(sender, eventType)
    OnlineMallMgr:openOnlineMall("ConvenientBuyDlg", nil, { [CHS[2200001]] = 1 })
end

function PetCallDlg:onAddMoney(sender, eventType)
    gf:showBuyCash()
end

-- 召唤规则说明界面
function PetCallDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("PetCallRuleDlg")
end

function PetCallDlg:MSG_SUMMON_MOUNT_RESULT(data)
    self.callData = data

    if self.responseCallback and 'function' == type(self.responseCallback) then
        self.responseCallback()
        self.responseCallback = nil
    end
end

function PetCallDlg:MSG_INVENTORY(data)
    self:refreshItem()
end

function PetCallDlg:MSG_UPDATE(data)
    self:refreshCash()
end

function PetCallDlg:MSG_SUMMON_MOUNT_NOTIFY(data)
    self.curPetId = data.id

    if self.onShowPet then
        self.onShowPet()
    end
end

return PetCallDlg
