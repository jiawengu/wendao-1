-- CoagulationChildDlg.lua
-- Created by songcw May/03/2017
-- 结婴界面

local CoagulationChildDlg = Singleton("CoagulationChildDlg", Dialog)

local BABY_TYPE_FOR_TEST = 1 -- 0没有结婴     1结元婴     2结血婴

local RESET_COST = {
    [1] = {name = CHS[3000666], needCount = 2},
    [2] = {name = CHS[3000689], needCount = 1, isJewelry = true, level = 70},
}
function CoagulationChildDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("BKImage", "BKPanel", true)
    self:setCtrlFullClient("Panel_30", "BKPanel")

    self:bindListener("TouchPanel", self.onVSelectButton, "VitalityChildPanel")
    self:bindListener("TouchPanel", self.onBSelectButton, "BloodChildPanel")
    self:bindListener("ConfrimButton1", self.onConfrimButton)
    self:bindListener("ConfrimButton2", self.onConfrimButton)
    self:bindListener("AddCashButton", self.onAddCashButton)

    self.isFirst = nil
    self.selectChildType = Me:getChildType()


    self:setBabyShape()

    self:hookMsg("MSG_ENTER_ROOM")
    self:hookMsg("MSG_CHAR_UPGRADE_COAGULATION")

    local panel = self:getControl("ChildPanel", nil, "MainPanel")
    local panelSize = panel:getContentSize()
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top01", panel, nil, nil, nil, nil, panelSize.height * 0.5 + 20)

    self:setDisplay()

    self:setBabyShape()
end

function CoagulationChildDlg:onCostImage(sender, eventType)
    if not self.isMagicing then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local data = sender.data
        local name = sender.data.name
        if data.isJewelry then
            local item = gf:deepCopy(InventoryMgr:getItemInfoByName(name))
            local dlg = DlgMgr:openDlg("JewelryInfoDlg")
            local pos = item.pos or 6
            local item = dlg:getInitJewelry(pos, name)
            item.pos = nil
            dlg:setJewelryInfo(item, pos, true)
            dlg:setFloatingFramePos(rect)
        else
            InventoryMgr:showBasicMessageDlg(name, rect)
        end
    end
end


function CoagulationChildDlg:setBabyShape()
    local vitalityChild = self:getControl("VitalityChildPanel") -- 元婴panel
    local bloodChild = self:getControl("BloodChildPanel")       -- 血婴panel

    local panel1 = self:getControl("ShadowPanel", nil, vitalityChild)
    local image1 = panel1:getChildByName(ResMgr.ui.char_shadow_img)
    if not image1 then
        image1 = cc.Sprite:create(ResMgr.ui.char_shadow_img)
        image1:setName(ResMgr.ui.char_shadow_img)
        image1:setPosition(panel1:getContentSize().width * 0.5, 20)
        panel1:addChild(image1)
    end
    self:setPortrait("BabyPanel", 07008, 0, vitalityChild)

    local image2 = self:getControl("BabyPanel", nil, bloodChild):getChildByName(ResMgr.ui.char_shadow_img)
    if not image2 then
    local image2 = cc.Sprite:create(ResMgr.ui.char_shadow_img)
        image2:setName(ResMgr.ui.char_shadow_img)
        image2:setPosition(panel1:getContentSize().width * 0.5, 20)
        self:getControl("ShadowPanel", nil, bloodChild):addChild(image2)
    end
    self:setPortrait("BabyPanel", 07009, 0, bloodChild, nil, nil, nil, nil, nil, nil, 7)
  --  bloodChild:addChild(cc.Sprite:create(ResMgr.ui.char_shadow_img))
end

--
function CoagulationChildDlg:setPayInfo()
    local vitalityChild = self:getControl("VitalityChildPanel") -- 元婴panel
    local bloodChild = self:getControl("BloodChildPanel")       -- 血婴panel

    local function setInfo(root)
    	for i = 1, 2 do
            local panel = self:getControl("ItemImagePanel" .. i, nil, root)
            panel.data = RESET_COST[i]
            local amount = InventoryMgr:getAmountByName(RESET_COST[i].name)
            self:setImage("ItemImage", ResMgr:getIconPathByName(RESET_COST[i].name), panel)
            if amount < RESET_COST[i].needCount then
                self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.RED, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
            else
                self:setNumImgForPanel("NumberPanel1", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_TOP, 21, panel)
            end

            if RESET_COST[i].level then
                self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, RESET_COST[i].level, false, LOCATE_POSITION.LEFT_TOP, 21)
            end

            local needStr = "/" .. RESET_COST[i].needCount
            self:setNumImgForPanel("NumberPanel2", ART_FONT_COLOR.NORMAL_TEXT, needStr, false, LOCATE_POSITION.LEFT_TOP, 21, panel)
            self:bindTouchEndEventListener(panel, self.onCostImage)
    	end
    end

    setInfo(vitalityChild)
    setInfo(bloodChild)
end

-- 设置界面显示
function CoagulationChildDlg:setDisplay()
    self:setPayInfo()

    local vitalityChild = self:getControl("VitalityChildPanel") -- 元婴panel
    local bloodChild = self:getControl("BloodChildPanel")       -- 血婴panel

    -- 隐藏消耗
    self:setCtrlVisible("PayPanel", false, vitalityChild)
    self:setCtrlVisible("PayPanel", false, bloodChild)

    self:setCtrlVisible("HaveImage", false, vitalityChild)
    self:setCtrlVisible("HaveImage", false, bloodChild)

    self:setCtrlVisible("Image1", false, vitalityChild)
    self:setCtrlVisible("Image1", false, bloodChild)

    self:setCtrlVisible("ConfrimButton1", false)
    self:setCtrlVisible("ConfrimButton2", false)

    if Me:getChildType() == 0 then
        local panel = self:getControl("ChildPanel", nil, "MainPanel")
        local panelSize = panel:getContentSize()
        self.sitMagic = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top02", panel, nil, nil, nil, nil, panelSize.height * 0.5 + 20)
    elseif Me:getChildType() == 1 then
        self:setCtrlVisible("HaveImage", true, vitalityChild)
        self:setCtrlVisible("Image1", true, vitalityChild)
        self:setCtrlVisible("VitalityChildImage", true)
        if not self.isFirst then
            self:setCtrlVisible("PayPanel", true, bloodChild)
        end
    elseif Me:getChildType() == 2 then
        self:setCtrlVisible("BloodChildImage", true)
        self:setCtrlVisible("HaveImage", true, bloodChild)
        self:setCtrlVisible("Image1", true, bloodChild)
        if not self.isFirst then
            self:setCtrlVisible("PayPanel", true, vitalityChild)
        end
    end
end

-- 关闭按钮、增加金钱按钮屏幕靠边对齐
function CoagulationChildDlg:adaptScreen()
    local winsize = cc.Director:getInstance():getWinSize()
    local leftX = (self.root:getContentSize().width - winsize.width) / Const.UI_SCALE * 0.5
    if leftX > 0 then leftX = 0 end

    local closeBtn = self:getControl("CloseButton")
    local topRightY = winsize.height / Const.UI_SCALE - closeBtn:getContentSize().height * 0.5 - (winsize.height / Const.UI_SCALE - self.root:getContentSize().height) * 0.5
    local r_t_pos = {x = leftX + 10 + closeBtn:getContentSize().width * 0.5, y = topRightY}
    closeBtn:setPosition(r_t_pos)

    local vitalityChild = self:getControl("VitalityChildPanel") -- 元婴panel
    vitalityChild:setPositionX(leftX)
    local bloodChild = self:getControl("BloodChildPanel")       -- 血婴panel
    local blodSize = bloodChild:getContentSize()
    local bloodX = (winsize.width - blodSize.width) / Const.UI_SCALE - (winsize.width - self.root:getContentSize().width) / Const.UI_SCALE * 0.5
    bloodChild:setPositionX(bloodX)

    local addCashBtn = self:getControl("AddCashButton") -- 锚点0.5
    local bottomRightX = (winsize.width) / Const.UI_SCALE - (winsize.width - self.root:getContentSize().width) / Const.UI_SCALE * 0.5 - 10 - addCashBtn:getContentSize().width
    if (self.root:getContentSize().width - winsize.width) / Const.UI_SCALE * 0.5 > 0 then
        bottomRightX = (winsize.width) / Const.UI_SCALE - 10 - addCashBtn:getContentSize().width
    end

    local bottomRightY = winsize.height / Const.UI_SCALE - addCashBtn:getContentSize().height - (winsize.height / Const.UI_SCALE - self.root:getContentSize().height) * 0.5

    local r_b_pos = {x = bottomRightX, y = bottomRightY}
    addCashBtn:setPosition(r_b_pos)
end

function CoagulationChildDlg:coagulation(bType)
    local str = gf:getChildName(bType)
    if Me:getChildType() == 0 then
        -- 当前没有结婴
        gf:confirm(string.format(CHS[4100575], str), function ()
            -- 处于禁闭状态
            if Me:isInJail() then
                gf:ShowSmallTips(CHS[6000214])
                return
            end

            -- 若在战斗中直接返回
            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003663])
                return
            end

            -- 安全锁判断
            if SafeLockMgr:isToBeRelease() then
                return
            end
            self.isSend = true
            self.isFirst = true
            gf:CmdToServer("CMD_CONFIRM_RESULT", {select = bType})
        end)
    else
        local dlg = DlgMgr:openDlg("CheckChangeChildDlg")
        dlg:setChildInfo(bType, str)
    end
end

function CoagulationChildDlg:setSelectImageState()
    local vitalityChild = self:getControl("VitalityChildPanel") -- 元婴panel
    local bloodChild = self:getControl("BloodChildPanel")       -- 血婴panel

    self:setCtrlVisible("Image1", self.selectChildType == 1, vitalityChild)
    self:setCtrlVisible("Image1", self.selectChildType == 2, bloodChild)
end

function CoagulationChildDlg:playMagic()
    local panel = self:getControl("ChildPanel", nil, "MainPanel")
    local panelSize = panel:getContentSize()
    self:setCtrlVisible("VitalityChildImage", false, panel)
    self:setCtrlVisible("BloodChildImage", false, panel)
    self:setCtrlVisible("ConfrimButton1", false)
    self:setCtrlVisible("ConfrimButton2", false)
    panel:stopAllActions()

    local magic1 = panel:getChildByName("Top03")
    if magic1 then
        magic1:removeFromParent()
    end

    local magic2 = panel:getChildByName("Top04")
    if magic2 then
        magic2:removeFromParent()
    end

    if self.sitMagic then
        self.sitMagic:removeFromParent(true)
        self.sitMagic = nil
    end

    local function canTouch()
        if Me:getChildType() == 0 then
            self:setCtrlVisible("ConfrimButton1", true)
        else
            self:setCtrlVisible("ConfrimButton2", self.selectChildType ~= Me:getChildType())
        end

        self.isMagicing = false
    end

    if self.selectChildType == 1 then
        self.isMagicing = true
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top03", panel, canTouch, nil, nil, nil, panelSize.height * 0.5 + 20, 5)
        local delayTi = cc.DelayTime:create(2.1)
        local callAct = cc.CallFunc:create(function()
            self:setCtrlVisible("VitalityChildImage", true, panel)
        end)
        panel:runAction(cc.Sequence:create(delayTi, callAct))
    elseif self.selectChildType == 2 then
        self.isMagicing = true
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top04", panel, canTouch, nil, nil, nil, panelSize.height * 0.5 + 20, 5)
        local delayTi = cc.DelayTime:create(2.1)
        local callAct = cc.CallFunc:create(function()
            self:setCtrlVisible("BloodChildImage", true, panel)
        end)
        panel:runAction(cc.Sequence:create(delayTi, callAct))
    end
end

function CoagulationChildDlg:onVSelectButton(sender, eventType)
    if not self.selectChildType and Me:getChildType() == CHILD_TYPE.YUANYING then return end
    if self.selectChildType == CHILD_TYPE.YUANYING then return end
    if self.isFirst then return end
    self.selectChildType = CHILD_TYPE.YUANYING
    self:setSelectImageState()
    self:playMagic()
end

function CoagulationChildDlg:onBSelectButton(sender, eventType)
    if not self.selectChildType and Me:getChildType() == CHILD_TYPE.XUEYING then return end

    if self.selectChildType == CHILD_TYPE.XUEYING then return end
    if self.isFirst then return end
    self.selectChildType = CHILD_TYPE.XUEYING
    self:setSelectImageState()
    self:playMagic()
end

function CoagulationChildDlg:onConfrimButton(sender, eventType)
    if not self.selectChildType then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    self:coagulation(self.selectChildType)
end

function CoagulationChildDlg:onVStartButton(sender, eventType)
    self:coagulation(1, CHS[4100560])
end

function CoagulationChildDlg:onBStartButton(sender, eventType)
    self:coagulation(2, CHS[4100561])
end

function CoagulationChildDlg:cleanup()
    if not self.isSend then
        gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
    end
    self.isSend = false
    self.isMagicing = false
end

function CoagulationChildDlg:onAddCashButton(sender, eventType)
    DlgMgr:openDlg("ChildRuleDlg")
end

function CoagulationChildDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

function CoagulationChildDlg:MSG_CHAR_UPGRADE_COAGULATION(data)
    self:setDisplay()
    local panel = self:getControl("ChildPanel", nil, "MainPanel")
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.jieying.name, "Top05", panel, nil, nil, nil, nil,panel:getContentSize().height * 0.5 + 10)
end

return CoagulationChildDlg
