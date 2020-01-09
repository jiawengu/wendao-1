-- UserDlg.lua
-- created by cheny Dec/03/2014
-- 角色对话框

local UserDlg = Singleton("UserDlg", Dialog)
local PageTag = require ("ctrl/RadioPageTag")
local TOTAL_PAGES = 3
local TEXT_WIDTH = 212
local MARGIN_LEFT = 8
local EXP_WIDTH = 211
local TEN_SECONDS = 10000 -- 10 * 1000
local RELATION_MAX_COUNT = 5    -- 关系条目最大个数

local TITLE_LIST = {
    CHS[5000040],
    CHS[5000041],
    CHS[5000042]
}

function UserDlg:init()
    -- 如果是帮派地图，置灰选择称谓按钮
    if GameMgr:isInPartyWar() then
        self:setCtrlEnabled("ChangeAppellationButton", false)
    end

    self:setCtrlVisible("StoreExpTipsPanel", false)

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.USERATTRIB)

    -- 绑定按钮
    self:bindListener("ChangeAppellationButton", self.onChengweixuanzeButton)
    self:bindListener("ChangeNameButton", self.onGaimingButton)
    self:bindListener("STDTaoButton", self.onBiaodaoButton)

    local btnPanel = self:getControl("DownPanel")
    self:bindListener("CharButton", self.onCharButton, btnPanel)
    self:bindListener("BabyButton", self.onBabyButton, btnPanel)


    self:bindListener("MedicineButton", self.onMedicineButton)
    self:bindListener("SupermarketButton", self.onSupermarketButton)

    self.leftButton = self:getControl("LeftButton", Const.UIButton)
    self.rightButton = self:getControl("RightButton", Const.UIButton)
    self:blindLongPress("LockExpButton", self.onLockExpButtonLong, self.onLockExpButton)
    self:blindLongPress("UnLockExpButton", self.onLockExpButtonLong, self.onLockExpButton)
    self:bindListener("InfoButton", self.onInfoButton, self:getControl("DownPanel"))


    self:bindFloatPanelListener("StoreExpFFPanel1")
    self:bindFloatPanelListener("StoreExpFFPanel2")
    self:bindFloatPanelListener("RelationPanel", nil, nil, function ()
        local list = self:getControl("ListView")
        list:jumpToTop()
    end)

    self:bindListener("AttributeButton", function(dlg, sender, eventType)
        local bVisible = self:getCtrlVisible("AttributeFFPanel")
        self:setCtrlVisible("AttributeFFPanel", not bVisible)
    end)

    -- 社交关系
    self:bindListener("RelationButton", function(dlg, sender, eventType)
        if not DistMgr:checkCrossDist() then return end

        local bVisible = self:getCtrlVisible("RelationPanel")
        self:setCtrlVisible("RelationPanel", not bVisible)

    end)

    -- 补充储备
    self:bindListener("AddButton", function(dlg, sender, eventType)
        local bVisible = self:getCtrlVisible("AddReservePanel")
        self:setCtrlVisible("AddReservePanel", not bVisible)

        -- 若角色PK值大于0，给出提示
        if Me:queryBasicInt("total_pk") > 0 then
            gf:ShowSmallTips(CHS[7000062])
        end
    end, "AttributeInfoPanel")

    -- 储备经验
    self:setTouchEffect("StoreExpPanel", self.onInfoButton)

    -- 好心值
    self:setTouchEffect("GoodValuePanel", self.onGoodValuePanel)

    -- 气血储备
    self:setTouchEffect("LifeStorePanel", self.onLifeStorePanel)

    -- 忠诚储备
    self:setTouchEffect("LoyaltyStorePanel", self.onLoyaltyStorePanel)

    -- 法力储备
    self:setTouchEffect("magicStorePanel", self.onMagicStorePanel)

    -- 气血
    self:setTouchEffect("LifePanel", self.onLifePanel)

    -- 物伤
    self:setTouchEffect("PhyPowerPanel", self.onPhyPowerPanel)

    -- 法力
    self:setTouchEffect("MagicPanel", self.onMagicPanel)

    -- 法伤
    self:setTouchEffect("MagPowerPanel", self.onMagPowerPanel)

    -- 速度
    self:setTouchEffect("SpeedPanel", self.onSpeedPanel)

    -- 防御
    self:setTouchEffect("DefencePanel", self.onDefencePanel)

    self:bindTipsPanel()

    self.relationUnitPanel = self:getControl("InfoPanel", nil, "RelationInfoPanel")
    self.relationUnitPanel:retain()
    self.relationUnitPanel:removeFromParent()

    self:setCtrlVisible("RelationPanel", false)


    -- 查询一下夫妻信息
    MarryMgr:questLoverInfo()

    -- 查询我的师徒信息
    MasterMgr:cmdQueryMyMaster()

    -- 查询一些结拜信息
    JiebaiMgr:queryJiebaiInfo()

    self:setRelationInfo()

    self:MSG_UPDATE()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg("MSG_COUPLE_INFO")
    self:hookMsg("MSG_MY_APPENTICE_INFO")

    self:hookMsg("MSG_REQUEST_BROTHER_INFO")
end

function UserDlg:showCbjyMagic()
    local magic = gf:createLoopMagic(ResMgr.magic.userDlg_cbjy, nil, {blendMode = "add"})
    magic:setName(ResMgr.magic.userDlg_cbjy)
    local ctrl = self:getControl("StoreExpPanel")
    ctrl:addChild(magic)

    self:setCtrlVisible("StoreExpTipsPanel", true)
end

function UserDlg:onDlgOpened(list, param)
    if 'FromZhuxianTask' == param then
        -- 主线任务中要求打开的，需要给予切换真身才能继续任务的提示
        gf:ShowSmallTips(CHS[3010012])
    end
end

-- 忠诚光效
function UserDlg:setLoyaltyEff(isVisible)
    local panel = self:getControl("Panel_219")
    panel:setVisible(isVisible)

    if isVisible then
        local big = cc.ScaleTo:create(0.8, 1.07)
        local small = cc.ScaleTo:create(0.8, 1)
        local orderAct = cc.Sequence:create(big, small)
        --local panel = self:getControl("EffectPanel")

        panel:runAction(cc.RepeatForever:create(orderAct))
    else
        panel:stopAllActions()
    end

end

function UserDlg:setTouchEffect(panelName, func)
    local panel = self:getControl(panelName, Const.UIPanel)
    panel:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:setCtrlVisible("TouchImage", true, panel)
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self:setCtrlVisible("TouchImage", false, panel)
            func(self, sender, ccui.TouchEventType.canceled)
        elseif eventType == ccui.TouchEventType.canceled then
            self:setCtrlVisible("TouchImage", false, panel)
        end
    end)
end

function UserDlg:cleanup()
    self:releaseCloneCtrl("relationUnitPanel")

    self:releaseDragonBones()
end

function UserDlg:releaseDragonBones()
    local panel = self:getControl("PortraitPanel")
    local magic = panel:getChildByName("charPortrait")

    if magic then
        DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        magic:removeFromParent()
    end
end

function UserDlg:bindTipsPanel()

    local panel = self:getControl("AttributeFFPanel")

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        panel:setVisible(false)
        self:setCtrlVisible("AddReservePanel", false)

        self:setLoyaltyEff(false)

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

function UserDlg:onShowPage(idx)
    self:setLabelText("PageTitelLabel", TITLE_LIST[idx])
end

function UserDlg:onAddBackupButton(sender, eventType)
    local bVisible = self:getCtrlVisible("AddReservePanel")
    self:setCtrlVisible("AddReservePanel", not bVisible)
end

function UserDlg:onInfoButton(sender, eventType)
    if Me:getChildType() == 0 then
        self:setCtrlVisible("StoreExpFFPanel1", true)
    else
        self:setLabelText("TitleLabel5", string.format(CHS[4100589], Me:getChildName(), Me:getChildName()), "StoreExpFFPanel2")
        self:setLabelText("TitleLabel6", string.format(CHS[4100590], Me:getChildName()), "StoreExpFFPanel2")
        self:setCtrlVisible("StoreExpFFPanel2", true)
    end

    local magic = sender:getChildByName(ResMgr.magic.userDlg_cbjy)
    if magic then magic:removeFromParent() end

    self:setCtrlVisible("StoreExpTipsPanel", false)
end

function UserDlg:onLifePanel(sender, eventType)
    local tip = CHS[7200011]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onPhyPowerPanel(sender, eventType)
    local tip = CHS[7200012]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onMagicPanel(sender, eventType)
    local tip = CHS[7200013]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onMagPowerPanel(sender, eventType)
    local tip = CHS[7200014]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onSpeedPanel(sender, eventType)
    local tip = CHS[7200015]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onDefencePanel(sender, eventType)
    local tip = CHS[7200016]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onLifeStorePanel(sender, eventType)
    local tip = string.format(CHS[7000101], Const.MAX_LIFE_STORE)
    gf:showTipInfo(tip, sender)
end

function UserDlg:onMagicStorePanel(sender, eventType)
    local tip = string.format(CHS[7000102], Const.MAX_MANA_STORE)
    gf:showTipInfo(tip, sender)
end

function UserDlg:onLoyaltyStorePanel(sender, eventType)
    local tip = CHS[7000103]
    gf:showTipInfo(tip, sender)
end

function UserDlg:onChengweixuanzeButton()
    DlgMgr:openDlg("ChengweiXuanzeDlg")
end

function UserDlg:onMedicineButton()
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300029]))
    self:onCloseButton()
end

function UserDlg:onSupermarketButton()
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300030]))
    self:onCloseButton()
end

function UserDlg:isMeetChildCondition()
    if Me:queryInt("level") < 110 then
        gf:ShowSmallTips(CHS[4100571])
        return
    end

    if Me:getChildType() == 0 then
        gf:ShowSmallTips(CHS[4100572])
        return
    end

    if Me.lastUpgradeTie and gfGetTickCount() - Me.lastUpgradeTie < TEN_SECONDS then
        gf:ShowSmallTips(CHS[4100573])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    return true
end

function UserDlg:onCharButton()
    if Me:isRealBody() then
        gf:ShowSmallTips(string.format(CHS[4100591]))
        return
    end

    if self:isMeetChildCondition() then
        DlgMgr:openDlg("CharToBabyDlg")
    end
end

function UserDlg:onBabyButton()
    if not Me:isRealBody() then
        gf:ShowSmallTips(string.format(CHS[4100592], Me:getChildName()))
        return
    end

    if self:isMeetChildCondition() then
        if TaskMgr:isExistTaskByName(CHS[4100602]) then
            gf:ShowSmallTips(CHS[4100603])
        else
            DlgMgr:openDlg("CharToBabyDlg")
        end
    end
end

function UserDlg:onBiaodaoButton()
    if not DlgMgr:isDlgOpened("TaoIntroduceDlg") then
        DlgMgr:openDlg("TaoIntroduceDlg")
    end
end

function UserDlg:onLockExpButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end


    local lock = Me:queryBasicInt("lock_exp")
    if lock == 0 then
        local moneyStr = gf:getMoneyDesc(5000000)
        -- WDSY-19919黄炜相明确写死人物最高等级
        local confirmDlg = gf:confirm(string.format(CHS[3003779], Const.PLAYER_MAX_LEVEL, moneyStr),
        function()
            UserDlg:onLockExpConfirm()
        end)
        confirmDlg:setConfirmText(CHS[7000000])
    else
        UserDlg:onLockExpConfirm()
    end
end

function UserDlg:onLockExpConfirmCb1()
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(string.format(CHS[3003782]))
        return
    end

    if not Me:isRealBody() then
        gf:ShowSmallTips(string.format(CHS[4100593], Me:getChildName()))
        return
    end

    --原有限制满级玩家无法锁经验的语句，现已取消
    if Me:getVipType() == 0 then
        gf:ShowSmallTips(CHS[3003784])
        return
    end

    if Me:queryBasicInt("exp_ware_data/exp_ware") > 0 then
        -- 经验仓库中还有经验
        gf:confirm(CHS[5400647], function()
            if gf:checkCostIsEnough(5000000) then
                -- 安全锁判断
                if self:checkSafeLockRelease("onLockExpConfirmCb1") then
                    return
                end
                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, 0, 1)
            end
        end)
    else
        if gf:checkCostIsEnough(5000000) then
            -- 安全锁判断
            if self:checkSafeLockRelease("onLockExpConfirmCb1") then
                return
            end
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, 0, 1)
        end
    end
end

function UserDlg:onLockExpConfirmCb2(isFreeUnlock)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not Me:isRealBody() then
        gf:ShowSmallTips(string.format(CHS[4100594], Me:getChildName()))
        return
    end

    if isFreeUnlock or gf:checkCostIsEnough(3200000)  then
        -- 安全锁判断
        if self:checkSafeLockRelease("onLockExpConfirmCb2", isFreeUnlock) then
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, 0, 0)
    end
end

function UserDlg:onLockExpConfirm()
    local lock = Me:queryBasicInt("lock_exp")
    if lock == 0 then
        local moneyStr = gf:getMoneyDesc(5000000)
        gf:confirm(string.format(CHS[3003781], moneyStr), function()
            self:onLockExpConfirmCb1()
        end)
    else
        local tip = ""
        local isFreeUnlock = false
        if Me:queryBasicInt("free_unlock_exp_times") >= 1 then
            tip = CHS[7002277]
            isFreeUnlock = true
        else
            local moneyStr = gf:getMoneyDesc(3200000)
            tip = string.format(CHS[3003785], moneyStr)
        end

        gf:confirm(tip, function()
            self:onLockExpConfirmCb2(isFreeUnlock)
        end)
    end
end

function UserDlg:onLockExpButtonLong(sender, eventType)

end

function UserDlg:onGaimingButton()
    if GameMgr:isShiDaoServer() or MapMgr:isInShiDao() then
        gf:ShowSmallTips(CHS[5420201])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003786])
        return
    end

    if self:checkSafeLockRelease("onGaimingButton") then
        return
    end

    if Me:getLevel() < 20 then
        gf:ShowSmallTips(CHS[2000097])
        return
    end

    DlgMgr:openDlg("UserRenameDlg")
end

-- 设置属性（若有装备加成，需要显示蓝色）
function UserDlg:setColorProp(ctrl, prop)
    self:setLabelText(ctrl, Me:query(prop))
    if Me:queryInt(prop) ~= Me:queryBasicInt(prop) then
        local label = self:getControl(ctrl, Const.UILabel)
        label:setColor(COLOR3.BLUE)
    end
end

-- 形象大图
function UserDlg:setShapeImage()
   if not Me:isRealBody() then
        -- 设置元婴、血婴图
        self:setCtrlVisible("PortraitImage", false)
        self:setCtrlVisible("XianImage", false)
        self:setCtrlVisible("Image_4", false, "BKImagePanel")

        self:creatCharDragonBones(Me:getChildPortrait(), -130)
    else
        -- 设置角色底图
        self:setCtrlVisible("PortraitImage", false)
        if Me:queryBasicInt("polar") == 0 then
            self:setCtrlVisible("PortraitPanel", false)
        else
            self:setCtrlVisible("PortraitPanel", true)
            self:creatCharDragonBones(ResMgr:getCharBoneShape(gf:getIconByGenderAndPolar(Me:queryBasicInt("gender"), Me:queryBasicInt("polar"))), -30)
        end
    end

            -- 角色界面仙魔标记，仙魔光效图片
            local upgradeType = Me:queryInt("upgrade/type")
            self:setCtrlVisible("XianImage", upgradeType == CHILD_TYPE.UPGRADE_IMMORTAL or
                upgradeType == CHILD_TYPE.UPGRADE_MAGIC)
            self:setCtrlVisible("Image_4", upgradeType == CHILD_TYPE.UPGRADE_IMMORTAL or
                upgradeType == CHILD_TYPE.UPGRADE_MAGIC, "BKImagePanel")

            if upgradeType == CHILD_TYPE.UPGRADE_IMMORTAL then
                self:setImage("XianImage", ResMgr.ui.user_upgrade_immortal_icon)
                self:setImage("Image_4", ResMgr.ui.user_upgrade_immortal_light, "BKImagePanel")
            elseif upgradeType == CHILD_TYPE.UPGRADE_MAGIC then
                self:setImage("XianImage", ResMgr.ui.user_upgrade_magic_icon)
                self:setImage("Image_4", ResMgr.ui.user_upgrade_magic_light, "BKImagePanel")
            end
end

function UserDlg:creatCharDragonBones(icon, offsetY)
    local panel = self:getControl("PortraitPanel")
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return
        else
            self:releaseDragonBones()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    panel:setScale(0.75)

    local magic = tolua.cast(dbMagic, "cc.Node")
    offsetY = offsetY or 0
    magic:setPosition(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5 + offsetY)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
end

-- 真身元婴状态
function UserDlg:setChildDisplay()
    local btnPanel = self:getControl("DownPanel")
    self:setLabelText("CharLabel", string.format(CHS[4100595], Me:queryInt("level")), btnPanel)

    if Me:getChildType() == 0 then
        self:setLabelText("BabyLabel", string.format(CHS[4100596]), btnPanel)
    elseif Me:getChildType() == 1 then
        self:setLabelText("BabyLabel", string.format(CHS[4100597], Me:queryInt("upgrade/level")), btnPanel)
    elseif Me:getChildType() == 2 then
        self:setLabelText("BabyLabel", string.format(CHS[4100598], Me:queryInt("upgrade/level")), btnPanel)
    end

    self:setCtrlVisible("CharImage", Me:isRealBody(), btnPanel)
    self:setCtrlVisible("BabyImage", not Me:isRealBody(), btnPanel)
end

function UserDlg:setMeInfo()
    -- 设置形象大图
    self:setShapeImage()

    -- 设置真身元婴按钮
    self:setChildDisplay()

    -- 我的信息
    --self:setLabelText("LevelLabel", Me:queryBasic("level") .. "级")
    if (MapMgr:isInShiDao() and ShiDaoMgr:isMonthTaoShiDao())
        or (DistMgr:isInKFSDServer() and ShiDaoMgr:isMonthTaoKFSD())
        or DistMgr:isInKFZC2019Server() then
        local taoDesc = gf:getTaoStr(Me:queryInt("last_mon_tao"), Me:queryInt("last_mon_tao_ex"))
        self:setLabelText("MonthTaovalueLabel", taoDesc)
        if taoDesc ~= gf:getTaoStr(Me:queryBasicInt("last_mon_tao"), Me:queryBasicInt("last_mon_tao_ex")) then
            local label = self:getControl("MonthTaovalueLabel", Const.UILabel)
            label:setColor(COLOR3.BLUE)
        end

        self:setCtrlVisible("TaoPanel", false)
        self:setCtrlVisible("MonthTaoPanel", true)
    else
        local taoDesc = gf:getTaoStr(Me:queryInt("tao"), Me:queryInt("tao_ex"))
        self:setLabelText("TaovalueLabel", taoDesc)
        if taoDesc ~= gf:getTaoStr(Me:queryBasicInt("tao"), Me:queryBasicInt("tao_ex")) then
            local label = self:getControl("TaovalueLabel", Const.UILabel)
            label:setColor(COLOR3.BLUE)
        end

        self:setCtrlVisible("TaoPanel", true)
        self:setCtrlVisible("MonthTaoPanel", false)
    end

    self:setLabelText("NameLabel", Me:getShowName())
    self:setLabelText("IdLabel",CHS[3003788] .. gf:getShowId(Me:queryBasic("gid")))

    -- 称谓
    local title = Me:queryBasic("title")
    if string.len(title) == 0 then title = CHS[34048] end
    self:setLabelText("AppellationLabel", CharMgr:getChengweiShowName(title))

    -- 经验
    if Me:isRealBody() then
        self:setLabelText("ExpTextLabelLabel", CHS[4100599], "ExpPanel")
        local exp, exp_to_next_level = Me:queryInt("exp"), Me:queryInt("exp_to_next_level")
        self:setProgressBar("ExpProgressBar", exp, exp_to_next_level)
        local realExpPercent = math.floor(100 * exp / exp_to_next_level)
        self:setLabelText("ExpvalueLabel", string.format("%d/%d(%d%%)", exp, exp_to_next_level, realExpPercent))
        self:setLabelText("ExpvalueLabel2", string.format("%d/%d(%d%%)", exp, exp_to_next_level, realExpPercent))
    else
        self:setLabelText("ExpTextLabelLabel", string.format(CHS[4100600], Me:getChildName()), "ExpPanel")
        local exp, exp_to_next_level = Me:queryInt("upgrade/exp"), Me:queryInt("upgrade/exp_to_next_level")
        self:setProgressBar("ExpProgressBar", exp, exp_to_next_level)
        local realExpPercent = math.floor(100 * exp / exp_to_next_level)
        self:setLabelText("ExpvalueLabel", string.format("%d/%d(%d%%)", exp, exp_to_next_level, realExpPercent))
        self:setLabelText("ExpvalueLabel2", string.format("%d/%d(%d%%)", exp, exp_to_next_level, realExpPercent))
    end

    -- 经验储备
    local expEx = Me:queryBasicInt("store_exp")
    self:setLabelText("StoreExpValueLabel", expEx)
    if Me:isRealBody() then
        local lock = Me:queryBasicInt("lock_exp")
        if lock ~= 0 then
            self:setCtrlVisible("UnLockExpButton", false)
            self:setCtrlVisible("LockExpButton", true)
        else
            self:setCtrlVisible("UnLockExpButton", true)
            self:setCtrlVisible("LockExpButton", false)
        end
    else
        self:setCtrlVisible("UnLockExpButton", false)
        self:setCtrlVisible("LockExpButton", false)
    end

    self:updateLayout("StoreExpPanel")

    -- 基本属性

    -- 气血
    local curLife = Me:getExtraRecoverLife()
    local maxLife = Me:queryInt("max_life")
    if Me:isInCombat() then
        curLife = Me:queryInt("life")
    end

    if curLife == maxLife then
        self:setLabelText("LifeValueLabel", curLife, nil, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("LifeValueLabel", curLife, nil, COLOR3.RED)
    end
    self:setLabelText("LifeMaxLabel", "/" .. maxLife, nil, COLOR3.TEXT_DEFAULT)

    self:updateLayout("LifePanel")

    -- 蓝
    local curMana = Me:getExtraRecoverMana()
    local maxMana = Me:queryInt("max_mana")
    if Me:isInCombat() then
        curMana = Me:queryInt("mana")
    end

    if curMana == maxMana then
        self:setLabelText("MagicValueLabel", curMana, nil, COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText("MagicValueLabel", curMana, nil, COLOR3.RED)
    end
    self:setLabelText("MagicMaxLabel", "/" .. maxMana, nil, COLOR3.TEXT_DEFAULT)

    self:updateLayout("MagicPanel")


    self:setColorProp("PhyPowerValueLabel", ("phy_power"))
    self:setColorProp("MagPowerValueLabel", ("mag_power"))
    self:setColorProp("SpeedValueLabel", ("speed"))
    self:setColorProp("DefenceValueLabel", ("def"))
    self:setLabelText("PotValueLabel", Me:query("pot"))
    self:setLabelText("LifeStoreValueLabel", Me:query("extra_life"))
    self:setLabelText("magicStoreValueLabel", Me:query("extra_mana"))
    self:setLabelText("LoyaltyStoreValueLabel", Me:query("backup_loyalty"))
    self:updateLayout("LifeStorePanel")
    self:updateLayout("magicStorePanel")
    self:updateLayout("LoyaltyStorePanel")
    self:updateLayout("UpPanel")

    -- 抗性
    self:setLabelText("ResistMetalValueLabel", Me:query("resist_metal") .. "%")
    self:setLabelText("ResistWoodValueLabel",  Me:query("resist_wood") .. "%")
    self:setLabelText("ResistWaterValueLabel", Me:query("resist_water") .. "%")
    self:setLabelText("ResistFireValueLabel",  Me:query("resist_fire") .. "%")
    self:setLabelText("ResistEarthValueLabel", Me:query("resist_earth") .. "%")

    self:setLabelText("IgnoreResistMetalValueLabel", Me:query("ignore_resist_metal") .. "%")
    self:setLabelText("IgnoreResistWoodValueLabel",  Me:query("ignore_resist_wood") .. "%")
    self:setLabelText("IgnoreResistWaterValueLabel", Me:query("ignore_resist_water") .. "%")
    self:setLabelText("IgnoreResistFireValueLabel",  Me:query("ignore_resist_fire") .. "%")
    self:setLabelText("IgnoreResistEarthValueLabel", Me:query("ignore_resist_earth") .. "%")

    -- WDSY-27121中。应服务器要求，将此处加上所有抗异常
    self:setLabelText("ResistForgottenValueLabel", (Me:query("resist_forgotten") + Me:query("all_resist_except")) .. "%")
    self:setLabelText("ResistPoisonValueLabel",    (Me:query("resist_poison") + Me:query("all_resist_except")) .. "%")
    self:setLabelText("ResistFrozenValueLabel",    (Me:query("resist_frozen") + Me:query("all_resist_except")) .. "%")
    self:setLabelText("ResistSleepValueLabel",     (Me:query("resist_sleep") + Me:query("all_resist_except")) .. "%")
    self:setLabelText("ResistConfusionValueLabel", (Me:query("resist_confusion") + Me:query("all_resist_except")) .. "%")

    self:setLabelText("IgnoreResistForgottenValueLabel", Me:query("ignore_resist_forgotten") .. "%")
    self:setLabelText("IgnoreResistPoisonValueLabel",    Me:query("ignore_resist_poison") .. "%")
    self:setLabelText("IgnoreResistFrozenValueLabel",    Me:query("ignore_resist_frozen") .. "%")
    self:setLabelText("IgnoreResistSleepValueLabel",     Me:query("ignore_resist_sleep") .. "%")
    self:setLabelText("IgnoreResistConfusionValueLabel", Me:query("ignore_resist_confusion") .. "%")

    -- 补充储备
    self:setAddReserveInfo()
end

-- 社交关系
function UserDlg:setRelationInfo()
    self:setLabelText("CreatTimeLabel_1", gf:getServerDate(CHS[4300031], Me:queryBasicInt("create_time")))
    if Me:queryBasic("party") == "" then
        self:setLabelText("PartyLabel_1", CHS[5000059])
    else
        self:setLabelText("PartyLabel_1", Me:queryBasic("party"))
    end

    local relationShip = {}
    -- relation：真实关系（统称）；showRelation：用于显示的关系（特指）
    if MarryMgr:isMarried() and MarryMgr:getLoverInfo() then
        local lover = MarryMgr:getLoverInfo()
        local gender = tonumber(gf:getGenderByIcon(lover.icon))
        local relation
        if gender == GENDER_TYPE.MALE then
            relation = CHS[6000292]
        elseif gender == GENDER_TYPE.FEMALE then
            relation = CHS[6000293]
        end

        local info = {
            name = lover.name,
            gid = lover.gid,
            friend = lover.friend,
            relation = CHS[4300032],
            showRelation = relation,
            shouye = "",
            masterTask = ""
        }

        table.insert(relationShip, info)
    else
        -- 加入没有婚姻关系的数据
        table.insert(relationShip, {title = CHS[4300032], notRelation = 1})
    end

    if JiebaiMgr:hasJiebaiRelation() then
        local jiebaiInfo = JiebaiMgr:getJiebaiInfo()
        for i = 1, #jiebaiInfo do
            table.insert(relationShip, jiebaiInfo[i])
        end
    else
        table.insert(relationShip, {title = CHS[7002211], notRelation = 1})
    end

    -- 获取我的师父
    local myTeacher = MasterMgr:getMyTeacherInfo()
    if myTeacher then
        local player = myTeacher
        local myInfo = MasterMgr:getMeInfoInMaster()
        local info = {
            name = player.name,
            gid = player.gid,
            friend = player.friend,
            relation = CHS[4300053],
            showRelation = CHS[4300043],
            shouye = "",
            studentLevel = myInfo.level
        }

        if myInfo.shouyeCount == 0 then
            info.shouye = CHS[4300033] -- "授业任务（未发布）",
        elseif myInfo.shouyeCount ~= myInfo.shouyeCompleteCount then
            info.shouye = CHS[4300034] -- "授业任务（未完成）",
        else
            info.shouye =  CHS[4300035]
        end

        if myInfo.level < MasterMgr:getBeMasterLevel() then
            if myInfo.taskTimes == 0 then
                info.masterTask = CHS[4300036]
            else
                info.masterTask = CHS[4300037]
            end
        else
            info.masterTask = CHS[4300038]
        end
        table.insert(relationShip, info)
    end

    -- 获取我的徒弟
    local myStudents = MasterMgr:getMyStudentsInfo()
    if myStudents then
        for i = 1, #myStudents do
            local player = myStudents[i]
            local info = {
                name = player.name,
                gid = player.gid,
                friend = player.friend,
                relation = CHS[4300053],
                showRelation = CHS[4300042],
                shouye = "",
                studentLevel = player.level
            }

            if player.shouyeCount == 0 then
                info.shouye = CHS[4300033] -- "授业任务（未发布）",
            elseif player.shouyeCount ~= player.shouyeCompleteCount then
                info.shouye = CHS[4300034] -- "授业任务（未完成）",
            else
                info.shouye = CHS[4300035]
            end

            if player.level < MasterMgr:getBeMasterLevel() then
                if player.taskTimes == 0 then
                    info.masterTask = CHS[4300036]
                else
                    info.masterTask = CHS[4300037]
                end
            else
                info.masterTask = CHS[4300038]
            end
            table.insert(relationShip, info)
        end
    end

    if not myTeacher and (not myStudents or #myStudents == 0) then
        table.insert(relationShip, {title = CHS[4300053], notRelation = 1})
    end

    local relationPanel = self:getControl("RelationInfoPanel")
    local list = self:resetListView("ListView")
    list:setVisible(true)
    list:setBounceEnabled(false)
    if #relationShip == 0 then
        local clonePanel = self.relationUnitPanel:clone()
        self:setUnitRelationPanel(nil, clonePanel)
        list:pushBackCustomItem(clonePanel)
    end

    for i = 1, #relationShip do
        local user = relationShip[i]
        local clonePanel = self.relationUnitPanel:clone()
        self:setCtrlVisible("BKImage_1", i % 2 ~= 0, clonePanel)
        self:setCtrlVisible("BKImage_2", i % 2 == 0, clonePanel)
        self:setUnitRelationPanel(user, clonePanel)
        list:pushBackCustomItem(clonePanel)
    end

    local size = self.relationUnitPanel:getContentSize()
    local newSize = {width = size.width, height = size.height * (#list:getItems())}
    newSize.height = math.min(newSize.height, size.height * RELATION_MAX_COUNT)
    list:setContentSize(newSize)
    local titleSize = self:getControl("TitlePanel", nil, relationPanel):getContentSize()
    local srcSelationPanelSize = relationPanel:getContentSize()
    relationPanel:setContentSize(srcSelationPanelSize.width, titleSize.height + newSize.height + 1)
    self:getControl("BKImage", nil, relationPanel):setContentSize(srcSelationPanelSize.width, titleSize.height + newSize.height + 1)

    local displayPaenl = self:getControl("RelationPanel")
    self.dlgRelationSize = self.dlgRelationSize or displayPaenl:getContentSize()
    local count = 1
    if #list:getItems() >= 1 then
        count = math.min(#list:getItems() - 1, RELATION_MAX_COUNT - 1)
    end

    displayPaenl:setContentSize(self.dlgRelationSize.width, self.dlgRelationSize.height + count * size.height)
    displayPaenl:requestDoLayout()
end

function UserDlg:setUnitRelationPanel(user, clonePanel)
    if not user then
        self:setLabelText("RelationLabel", "", clonePanel)
        self:setLabelText("NameLabel", "", clonePanel)
        self:setLabelText("FriendlyLabel", "", clonePanel)
        self:setLabelText("TaskLabel_1", "", clonePanel)
        self:setLabelText("TaskLabel_2", "", clonePanel)
        self:setLabelText("TaskLabel_3", "", clonePanel)

        self:setCtrlVisible("GotoButton", false, clonePanel)
        self:setCtrlVisible("CommunionButton", false, clonePanel)

        self:setCtrlVisible("NoneLabel_1", false, clonePanel)
        self:setCtrlVisible("NoneLabel_2", false, clonePanel)
        return
    end

    if user.notRelation then
        self:setLabelText("RelationLabel", user.title, clonePanel)
        self:setCtrlVisible("NoneLabel_1", user.title == CHS[4300032], clonePanel)
        self:setCtrlVisible("NoneLabel_2", user.title ~= CHS[4300032], clonePanel)
        if user.title == CHS[7002211] then
            self:setLabelText("NoneLabel_2", CHS[7002213], clonePanel)
        end

        self:setCtrlVisible("GotoButton", true, clonePanel)
        self:setCtrlVisible("CommunionButton", false, clonePanel)

        self:setLabelText("NameLabel", "", clonePanel)
        self:setLabelText("FriendlyLabel", "", clonePanel)
        self:setLabelText("TaskLabel_1", "", clonePanel)
        self:setLabelText("TaskLabel_2", "", clonePanel)
        self:setLabelText("TaskLabel_3", "", clonePanel)

        self:bindListener("GotoButton", function(dlg, sender, eventType)
            if user.title == CHS[4300032] then
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300051]))
            elseif user.title == CHS[7002211] then
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7002212]))
            else
                --AutoWalkMgr:beginAutoWalk(gf:findDest("#@MasterDlg#@"))
                DlgMgr:openDlg("MasterDlg")
            end

            self:onCloseButton()
        end, clonePanel)

        clonePanel:requestDoLayout()
        return
    end

    self:setCtrlVisible("NoneLabel_1", false, clonePanel)
    self:setCtrlVisible("NoneLabel_2", false, clonePanel)
    self:setLabelText("RelationLabel", user.showRelation, clonePanel)
    self:setLabelText("NameLabel", gf:getRealName(user.name), clonePanel)
    self:setLabelText("FriendlyLabel", user.friend, clonePanel)
    if user.relation == CHS[4300053] then -- 师徒
        -- 师父
        if user.shouye == CHS[4300033] and user.studentLevel >= MasterMgr:getBeMasterLevel() then
            -- 如果等级达到出师并且未发布授业任务，则只显示出师任务，排版需居中
            self:setLabelText("TaskLabel_1", "", clonePanel)
            self:setLabelText("TaskLabel_2", "", clonePanel)
            self:setLabelText("TaskLabel_3", user.masterTask, clonePanel)
        else
            self:setLabelText("TaskLabel_1", user.shouye, clonePanel)
            self:setLabelText("TaskLabel_2", user.masterTask, clonePanel)
            self:setLabelText("TaskLabel_3", "", clonePanel)
        end

        self:setCtrlVisible("GotoButton", true, clonePanel)
        self:setCtrlVisible("CommunionButton", false, clonePanel)
    elseif user.relation == CHS[4300032] then  -- 夫妻
        self:setLabelText("TaskLabel_1", user.shouye, clonePanel)
        self:setLabelText("TaskLabel_2", user.masterTask, clonePanel)
        self:setLabelText("TaskLabel_3", user.masterTask, clonePanel)
        self:setCtrlVisible("GotoButton", false, clonePanel)
        self:setCtrlVisible("CommunionButton", true, clonePanel)
    elseif user.relation == CHS[7002211] then  -- 结拜
        self:setLabelText("TaskLabel_1", "", clonePanel)
        self:setLabelText("TaskLabel_2", "", clonePanel)
        self:setLabelText("TaskLabel_3", "", clonePanel)

        self:setCtrlVisible("GotoButton", false, clonePanel)
        self:setCtrlVisible("CommunionButton", true, clonePanel)
    end

    self:bindListener("GotoButton", function(dlg, sender, eventType)
        -- AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4300039]))
        DlgMgr:openDlg("MasterRelationDlg")
        self:onCloseButton()
    end, clonePanel)

    self:bindListener("CommunionButton", function(dlg, sender, eventType)
        FriendMgr:communicat(user.name, user.gid, user.icon, user.level)
    end, clonePanel)
end

-- 补充储备信息
function UserDlg:setAddReserveInfo()
    -- pk值影响购买价格
    local pkCostCoef = 1 + Me:queryBasicInt("total_pk") * 0.05
    if pkCostCoef > 2 then
        pkCostCoef = 2
    end

    local function generalConditions(level)
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if Me:queryInt("level") < level then
            gf:ShowSmallTips(string.format(CHS[3002380], level))
            return
        end

        return true
    end

    local panel = self:getControl("AddReservePanel")
    local lifePanel = self:getControl("LifePanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002595]), lifePanel)
    self:setItemImageSize("GuardImage", lifePanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)
        if not generalConditions(10) then return end

        if Me:queryInt("extra_life") + 300000 > Const.MAX_LIFE_STORE then
            gf:ShowSmallTips(CHS[3003770])
            return
        end

        local cost = 120000  * pkCostCoef
        local money = gf:getMoneyDesc(cost)
        gf:confirm(string.format(CHS[3003772], money), function()
            if not gf:checkHasEnoughMoney(cost) then
                gf:askUserWhetherBuyCash(cost)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 1)
        end)

    end, lifePanel)

    local manaPanel = self:getControl("ManaPanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002598]), manaPanel)
    self:setItemImageSize("GuardImage", manaPanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)
        if not generalConditions(10) then return end

        if Me:queryInt("extra_mana") + 300000 > Const.MAX_MANA_STORE then
            gf:ShowSmallTips(CHS[3003773])
            return
        end

        local cost = 360000  * pkCostCoef
        local money = gf:getMoneyDesc(cost)
        gf:confirm(string.format(CHS[3003774], money), function()
            if not gf:checkHasEnoughMoney(cost) then
                gf:askUserWhetherBuyCash(cost)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 2)
        end)
    end, manaPanel)

    local loyaltyPanel = self:getControl("LoyaltyPanel", nil, panel)
    self:setImage("GuardImage", ResMgr:getIconPathByName(CHS[3002601]), loyaltyPanel)
    self:setItemImageSize("GuardImage", loyaltyPanel)
    self:bindListener("AddButton", function(dlg, sender, eventType)
        self:setCtrlVisible("AddReservePanel", true)

        if not generalConditions(20) then return end

        if Me:queryInt("backup_loyalty") + 300 > 3000000 then
            gf:ShowSmallTips(CHS[3003776])
            return
        end

        local money = gf:getMoneyDesc(1800000 * pkCostCoef)
        gf:confirm(string.format(CHS[3003777], money), function()
            if not gf:checkHasEnoughMoney(1800000) then
                gf:askUserWhetherBuyCash(1800000)
                return
            end

            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FAST_ADD_EXTRA, 3)
        end)
    end, loyaltyPanel)
end

function UserDlg:MSG_UPDATE(data)
    -- 设置我的信息
    self:setMeInfo()

    -- 设置好心值
    self:setGoodValueInfo()
end

function UserDlg:MSG_UPDATE_IMPROVEMENT(data)
    self:MSG_UPDATE()
end

-- 设置好心值
function UserDlg:setGoodValueInfo()
    self:setLabelText("GoodValueLabel_1", Me:queryInt("nice"))

    self:updateLayout("GoodValuePanel")
end

-- 好心值面板
function UserDlg:onGoodValuePanel(sender, enventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("GoodDlg")
    --dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function UserDlg:MSG_COUPLE_INFO(data)
    self:setRelationInfo()
end

function UserDlg:MSG_MY_APPENTICE_INFO(data)
    self:setRelationInfo()
end

function UserDlg:MSG_REQUEST_BROTHER_INFO(data)
    self:setRelationInfo()
end

return UserDlg
