-- SafeLockMainDlg.lua
-- Created by song May/26/2015
-- 安全锁界面

local SafeLockMainDlg = Singleton("SafeLockMainDlg", Dialog)

function SafeLockMainDlg:init()
    self:bindListener("SetButton", self.onSetButton)
    self:bindListener("ModifyButton", self.onModifyButton)
    self:bindListener("ForceReleaseButton", self.onForceReleaseButton)
    self:bindListener("ReleaseButton", self.onReleaseButton)
    self:bindListener("CancelForceReleaseButton", self.onCancelForceReleaseButton)

    if SafeLockMgr.lockInfo then
        self:setTipsByMode(SafeLockMgr.lockInfo.lockState)
        self:setBtnByMode(SafeLockMgr.lockInfo.lockState)
    end

    -- 打开安全锁界面请求信息
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockMainDlg")

    self:hookMsg("MSG_SAFE_LOCK_INFO")
end

function SafeLockMainDlg:attachLightEffect()
    local btn = self:getControl("SetButton")
    local effect = btn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if not effect then
        -- lixh2 WDSY-21401 安全锁按钮光效替换为骨骼动画
        gf:createArmatureMagic(ResMgr.ArmatureMagic.safe_lock_btn, btn, Const.ARMATURE_MAGIC_TAG)
    end
end

-- 初始化界面，隐藏相关控件
function SafeLockMainDlg:initDisplay()
    self:setCtrlVisible("SetButton", false)
    self:setCtrlVisible("ModifyButton", false)
    self:setCtrlVisible("ForceReleaseButton", false)
    self:setCtrlVisible("ReleaseButton", false)
    self:setCtrlVisible("CancelForceReleaseButton", false)
end

function SafeLockMainDlg:setBtnByMode(mode)
    self:initDisplay()
    if mode == SAFE_LOCK_STATE.NO_LOCK then
        self:setCtrlVisible("SetButton", true)
    elseif mode == SAFE_LOCK_STATE.BE_LOCK then
        self:setCtrlVisible("ModifyButton", true)
        self:setCtrlVisible("ForceReleaseButton", true)
        self:setCtrlVisible("ReleaseButton", true)
    elseif mode == SAFE_LOCK_STATE.FORCE_TO_UNLOCL then
        self:setCtrlVisible("CancelForceReleaseButton", true)
        self:setCtrlVisible("ReleaseButton", true)
    end
end

function SafeLockMainDlg:setTipsByMode(mode)
    local scrollView = self:getControl("ScrollView")
    local tips = self:getTipsByMode(mode)
    local panel = self:getControl("Panel", nil, "TipsPanel"):clone()
    self:setColorTextInPanel(tips, panel, nil, 0, panel:getContentSize().height)
    scrollView:removeAllChildren()
    panel:setPosition(0,0)
    scrollView:addChild(panel)
    scrollView:setInnerContainerSize(panel:getContentSize())
end

function SafeLockMainDlg:setColorTextInPanel(str, panelCtrl, root)
    panelCtrl:removeAllChildren()
    local size = panelCtrl:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    if textH > size.height then
        textCtrl:setPosition(0, textH)
    else
        textCtrl:setPosition(0, size.height)
    end
    panelCtrl:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
    panelCtrl:setContentSize(size.width, textH)
end

function SafeLockMainDlg:getTipsByMode(mode)
    if mode == SAFE_LOCK_STATE.NO_LOCK then
        local str1 = CHS[4200013] -- "你当前#G尚未设置安全锁#n。",
        local str2 = CHS[4200014] -- "设置安全锁后，在进行消费元宝、改变角色、宠物、装备属性的大部分操作时需要先验证安全锁后方可继续。",
        local str3 = CHS[4200039]
        local str4 = CHS[4300487]

        return str1 .. "\n" .. str2 .. "\n" .. str3 .. "\n" .. str4
    elseif mode == SAFE_LOCK_STATE.BE_LOCK then
        local str1 = CHS[4200015] -- 你当前#R安全锁设置成功#n。
        local str2 = CHS[4200016] -- "你当前#R安全锁验证成功#n。"
        local str3 = CHS[4200017] -- "设置安全锁后，在进行消费元宝、改变角色、宠物、装备属性的大部分操作时需要先验证安全锁后方可继续。"
        local str4 = CHS[4200039]
        local str5 = CHS[7000001]
        local str6 = CHS[4300487]

        -- 判断当前登入是否验证过
        if SafeLockMgr.lockInfo.isReleaseLock == 0 then
            return str1 .. "\n" .. str3 .. "\n" .. str4 .. "\n" .. str6 .. "\n" .. str5
        else
            return str2 .. "\n" .. str3 .. "\n" .. str4 .. "\n" .. str6
        end
    elseif mode == SAFE_LOCK_STATE.FORCE_TO_UNLOCL then
        local str1 = CHS[4200018] -- "你当前#R安全锁处于强制解除状态#n。"
        local str2 = CHS[4200019] -- "强制解除的等待时间为7天，期间无法进行修改密码的操作，您可以取消强制解除，但取消后再次申请时等待时间仍从7天开始计时。"
        local str3 = CHS[4200020] -- "在强制解除期间安全锁仍有效，在进行消费元宝、改变角色、宠物、装备属性的大部分操作时需先验证安全锁后方可继续。"
        local str4 = string.format(CHS[4200021], gf:getServerDate(CHS[4200022], SafeLockMgr.lockInfo.reset_start))
        local str5 = string.format(CHS[4200023], gf:getServerDate(CHS[4200022], SafeLockMgr.lockInfo.reset_end))

        return str1 .. "\n" .. str2 .. "\n" .. str3 .. "\n" .. str4 .. "\n" .. str5
    end
end

function SafeLockMainDlg:onSetButton(sender, eventType)
    -- 清除光效
    local magic = sender:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if magic then
        magic:removeFromParent()
    end

    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockSetDlg")
end

function SafeLockMainDlg:onModifyButton(sender, eventType)
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockModifyDlg")
end

function SafeLockMainDlg:onForceReleaseButton(sender, eventType)
    DlgMgr:openDlg("SafeLockForceReleaseDlg")
end

function SafeLockMainDlg:onReleaseButton(sender, eventType)
    if not SafeLockMgr.lockInfo then return end
    if SafeLockMgr.lockInfo.isReleaseLock == 1 then
        gf:ShowSmallTips(CHS[4200024]) -- "你当前已验证安全锁密码成功，无需重复验证。"
        return
    end

    -- 清除回调数据
    SafeLockMgr:clearLastRelaseEvent()
    SafeLockMgr:cmdOpenSafeLockDlg("SafeLockReleaseDlg")
end

function SafeLockMainDlg:onCancelForceReleaseButton(sender, eventType)
    if not SafeLockMgr.lockInfo then return end
    local lastTime = SafeLockMgr.lockInfo.reset_end - gf:getServerTime()
    local day = math.floor(lastTime / (60 * 60 * 24))
    local hour = math.floor(lastTime % (60 * 60 * 24) / (60 * 60))
    local min = math.ceil(lastTime % (60 * 60 * 24) % (60 * 60) / 60)
    local timeStr = ""
    if day == 0 then
        if hour == 0 then
            timeStr = min .. CHS[3002943]
        else
            timeStr = hour .. CHS[3002942] .. min .. CHS[4200025]
        end
    else
        timeStr = day .. CHS[6000229] .. hour .. CHS[3002942] .. min .. CHS[4200025]
    end

    gf:confirm(string.format(CHS[4200026], timeStr),
        function ()
        	SafeLockMgr:cmdResetSafeLock(0)
        end)
end

function SafeLockMainDlg:MSG_SAFE_LOCK_INFO(data)
    self:setTipsByMode(SafeLockMgr.lockInfo.lockState)
    self:setBtnByMode(SafeLockMgr.lockInfo.lockState)
end

return SafeLockMainDlg
