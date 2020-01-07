
-- PetAttribDlg.lua
-- Created by cheny Dec/23/2014
-- 宠物属性界面

local PetAttribDlg = Singleton("PetAttribDlg", Dialog)
local Group = require('ctrl/RadioGroup')
local PET_ATTRIB_LIST = require(ResMgr:getCfgPath('PetAttribList.lua'))
local PET_ATTRIB_LIST_TEST = require(ResMgr:getCfgPath('PetAttribListTest.lua'))

-- 超过该等级就不可参战和掠阵
local MAX_LEVEL_DIFF = 15

local DELAY_TIME = 1

-- progressbar最大宽度
local MAX_PROGRESSBAR_WIDTH = 229
local MARGIN_LEFT = 7

local YSGT_EFFECT_LEVEL = 45
local CWWG_EFFECT_LEVEL = 70

local JINGYAN_DAN = {
    [1] = CHS[3001111],
    [2] = CHS[4200404],
}

local ITEM_INDEX = {
    [CHS[3003330]] = 1, -- 宠物经验丹
    [CHS[4200404]] = 2, -- 高级宠物经验丹
    [CHS[3003329]] = 3, -- 超级神兽丹
}

function PetAttribDlg:init()

    -- 忽略超级神兽丹的标记
    self.isIgnorChaojiTips = false

    -- 忽略神兽丹的标记
    self.isIgnorTips = false

    self.isLongPress = false

    -- 点击成长按钮需要记录当前宠物
    self.sendFlyInfoRequestPet = nil

    -- 是否需要打开元神共通界面标记
    self.isNeedOpenChangeDlg = false

    self:setCtrlVisible("PetFunctionPanel", false)

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.PETATTRIB, function ()
        -- 点击分享后关闭面板
        self:getControl("PetFunctionPanel"):setVisible(false)
        ShareMgr:share(SHARE_FLAG.PETATTRIB)
    end)

    -- 宠物相关按钮
    self:bindListener("ViewOrHideButton", self.onViewOrHideButton)
    self:bindListener("RenameButton", self.onRenameButton)
    self:bindListener("DressButton", self.onDressButton)
    self:bindListener("FreeButton", self.onFreeButton)
    self:blindLongPress("LockExp", self.onLockExpButtonLong, self.onLockExpButton)
    self:blindLongPress("UnlockExp", self.onLockExpButtonLong, self.onLockExpButton)
    self:bindListener("HideButton", self.onViewOrHideButton)
    self:bindListener("PetStrengthButton", self.onPetStrengthButton)
    self:bindListener("PetDianhuaButton", self.onPetDianhuaButton)
    self:bindListener("PetGrowButton", self.onPetGrowButton)
    self:bindListener("PetFunctionButton", self.onPetFunctionButton)
    self:bindListener("PetEvolveButton", self.onPetEvolveButton)
    self:bindListener("PetChangeButton", self.onPetChangeButton)
    self:bindListener("PetHuanHuaButton", self.onPetHuanHuaButton)
    self:bindListener("AddMartialButton", self.onInheritButton)

    self:bindListener("ShapePanel1", self.onShowFloatButton, "AddExpPanel")
    self:bindListener("ShapePanel2", self.onShowFloatButton, "AddExpPanel")
    self:bindListener("ShapePanel2", self.onShowFloatButton, "AddIntimacyPanel")

    self:bindListener("CheckEffectButton", function(dlg, sender, eventType)
        if not self.selectPet then return end
        self:setCtrlVisible("CheckEffectPanel", true)
    end)

    self:bindListener("PetEffectButton", function(dlg, sender, eventType)
        if not self.selectPet then return end
        if self.selectPet:queryInt("rank") == Const.PET_RANK_ELITE then
            -- 当前宠物为变异（、神兽、元灵）宠物，无法进行成长洗炼。
            gf:ShowSmallTips(string.format(CHS[3003313], gf:getPetRankDesc(self.selectPet)))
            return
        end
        local dlg = DlgMgr:openDlg("PetGrowingDlg")
        dlg:setPetInfo(self.selectPet)

        -- 请求宠物天技
        PetMgr:requestPetGodSkill(self.selectPet:queryBasicInt("id"), "preview")
        PetMgr:getCanFeedSuperLuLimit()
    end)

    self:bindListener("PetStoneButton", function(dlg, sender, eventType)
        if not self.selectPet then return end
        if Me:queryInt("level") < PetMgr:getPetStoneOpenLevel() then
            gf:ShowSmallTips(string.format(CHS[3003314], PetMgr:getPetStoneOpenLevel()))
            return
        end

        local dlg = DlgMgr:openDlg("PetStoneDlg")
        dlg:setPetInfo(self.selectPet)
    end)

    -- 基础属性相关按钮
    self:bindListener("LoyaltyButton", self.onLoyaltyButton)
    self:bindListener("LongevityButton", self.onLongevityButton)
    self:bindListener("AddLongevityButton", self.onAddLongevityButton)
    self:bindListener("IntimacyButton", self.onIntimacyButton)
    self:bindListener("MartialButton", self.onMartialButton)
    self:bindListener("AddLoyaltyButton", self.onAddLoyaltyButton)

    self:bindListener("FightButton", self.onButtonTouch)
    self:bindListener("SupplyButton", self.onButtonTouch)

    self:setCtrlVisible("ViewButton", true)
    self:setCtrlVisible("HideButton", false)
	self:setCtrlVisible("AddLongevityButton", true)


    -- 使用宠物经验丹相关
    local addExpPanel = self:getControl("AddExpPanel")
    local nomorPanel = self:getControl("UsePanel1", nil, addExpPanel)
    nomorPanel:setTag(1)
    self:bindPressForIntervalCallback('ReduceButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)
    self:bindPressForIntervalCallback('AddButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)

    local heightPanel = self:getControl("UsePanel2", nil, addExpPanel)
    heightPanel:setTag(2)
    self:bindPressForIntervalCallback('ReduceButton', 0.15, self.onSubOrAddNum, 'times', heightPanel)
    self:bindPressForIntervalCallback('AddButton', 0.15, self.onSubOrAddNum, 'times', heightPanel)

    self:bindListener("ConfirmButton", self.onConfirmButton, addExpPanel)
    self.useNumber1 = 0
    self.useNumber2 = 0
    self.clickNum = 0
    self.isAdd = 1

    -- 使用超级神兽丹添加亲密度相关
    local addPanel = self:getControl("AddIntimacyPanel")
    local nomorPanel = self:getControl("UsePanel2", nil, addPanel)
    nomorPanel:setTag(3)
    self:bindPressForIntervalCallback('ReduceButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)
    self:bindPressForIntervalCallback('AddButton', 0.15, self.onSubOrAddNum, 'times', nomorPanel)
    self:bindListener("ConfirmButton", self.onConfirmButton, addPanel)
    self:bindListener("PlusImage", self.onPlusImage, addPanel)
    self.useNumber3 = 0

    self:bindShowTipsByName("Life")
    self:bindShowTipsByName("Mana")
    self:bindShowTipsByName("Phy")
    self:bindShowTipsByName("Mag")
    self:bindShowTipsByName("Speed")
    self:bindShowTipsByName("Defence")
    self:bindShowTipsByName("Loyalty")
    self:bindShowTipsByName("Longevity")
    self:bindShowTipsByName("Intimacy")
    self:bindShowTipsByName("Martial")
    self:bindShowTipsByName("CarryLevel")

    self:buttonInit()

    local pet = DlgMgr:sendMsg("PetListChildDlg","getCurrentPet")
    self:setPetInfo(pet)

    -- 补充亲密度
    self:bindListener("AddIntimacyButton", function(dlg, sender, eventType)
        if not DistMgr:checkCrossDist() then return end

        if not self.selectPet then return end
        self:showFastUsePanel("AddIntimacyPanel")
    end)

    -- 补充寿命
    self:bindListener("AddLongevityButton", function(dlg, sender, eventType)
        if not DistMgr:checkCrossDist() then return end

        if not self.selectPet then return end
        self:showFastUsePanel("AddLongevityPanel")
    end)

    -- 补充经验
    self:bindListener("AddExpButton", function(dlg, sender, eventType)
        if not self.selectPet then return end

        if Me:queryInt("level") < 40 then
            gf:ShowSmallTips(CHS[4200409])
            return
        end
        self:showFastUsePanel("AddExpPanel")
    end)

    self:bindPanelEvent("AddIntimacyPanel")
    self:bindPanelEvent("AddLongevityPanel")
    self:bindPanelEvent("AddExpPanel")
    self:bindPanelEvent("CheckEffectPanel")
    self:bindPanelEvent("PetFunctionPanel")
    self:bindPanelEvent("TipsPanel")
    self:bindPanelEvent("MartinInstroducePanel")
    self:bindLimitedCheckBox("AddLongevityPanel", "LimitedCheckBox")
    self:bindLimitedCheckBox("IntimacyPanel", "LimitedCheckBox")


    self:hookMsg("MSG_SET_VISIBLE_PET")
    self:hookMsg("MSG_SET_CURRENT_PET")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_SET_SETTING")
    self:hookMsg("MSG_UPGRADE_TASK_PET")
    self:hookMsg("MSG_FINISH_PET_INHERIT")

    local intimacyPanel = self:getControl("IntimacyPanel", Const.UIPanel)
    local longevityPanel = self:getControl("AddLongevityPanel", Const.UIPanel)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("LimitedCheckBox", false, longevityPanel)
        self:setCheck("LimitedCheckBox", false, intimacyPanel)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("LimitedCheckBox", true, longevityPanel)
        self:setCheck("LimitedCheckBox", false, intimacyPanel)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 11 then
        self:setCheck("LimitedCheckBox", true, longevityPanel)
        self:setCheck("LimitedCheckBox", true, intimacyPanel)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 10 then
        self:setCheck("LimitedCheckBox", false, longevityPanel)
        self:setCheck("LimitedCheckBox", true, intimacyPanel)
    end

    self:bindHideGrowBtn()

    -- 绑定数字键盘
    self:bindNumInput("UsePanel1","AddExpPanel", nil, 1)
    self:bindNumInput("UsePanel2","AddExpPanel", self.isMeetPetLevel, 2)

    self:bindNumInput("UsePanel2","AddIntimacyPanel", nil, 3)

    -- 刷新宠物列表
    DlgMgr:sendMsg("PetListChildDlg", "refreshList")

    self:doEffect()
end

function PetAttribDlg:isMeetPetLevel()
    if not self.selectPet then return true end
    if self.selectPet:queryInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200408])
        return true
    end
end

function PetAttribDlg:clearCwwgEffect(btn)
    local magic = btn:getChildByTag(ResMgr.magic.world_chat_under_arrow)
    if magic then
        magic:removeFromParent()
        return true
    end

    local magic = btn:getChildByTag(ResMgr.magic.yuhua_btn)
    if magic then
        magic:removeFromParent()
        return true
    end

    return false
end

function PetAttribDlg:doEffect()
    -- 外观光效
    local hasShowYSGT = cc.UserDefault:getInstance():getIntegerForKey("cwwgDress" .. gf:getShowId(Me:queryBasic("gid"))) or 0
    if hasShowYSGT ~= 1 and Me:getLevel() >= CWWG_EFFECT_LEVEL then
        -- 大于等于70级的玩家第一次打开宠物属性界面，需要在宠物外观按钮处播放环绕光效
        local btn1 = self:getControl("PetFunctionButton")
        local effect = btn1:getChildByTag(ResMgr.magic.world_chat_under_arrow)
        if not effect then
            local effect = gf:createLoopMagic(ResMgr.magic.world_chat_under_arrow, nil, {blendMode = "normal"})
            effect:setScale(0.85)
            effect:setAnchorPoint(0.5, 0.5)
            effect:setPosition(btn1:getContentSize().width / 2,btn1:getContentSize().height / 2)
            btn1:addChild(effect, 1, ResMgr.magic.world_chat_under_arrow)

            local btn2 = self:getControl("DressButton")
            local effect = btn2:getChildByTag(ResMgr.magic.yuhua_btn)
            if not effect then
                local effect = gf:createLoopMagic(ResMgr.magic.yuhua_btn, nil, {blendMode = "add"})
                effect:setScale(0.96, 1.04)
                effect:setAnchorPoint(0.5, 0.5)
                effect:setPosition(btn2:getContentSize().width / 2,btn2:getContentSize().height / 2)
                btn2:addChild(effect, 1, ResMgr.magic.yuhua_btn)
            end

        end
    end
end

function PetAttribDlg:onSubOrAddNum(ctrlName, times, sender)

    if sender:getParent():getTag() == 2 and self.selectPet:getLevel() < 70 then
        gf:ShowSmallTips(CHS[4200408])
        return
    end

    if times == 1 then
        self.clickNum = self.clickNum  + 1  -- 点击次数，不包括长按
    elseif self.clickNum < 4 then
        self.clickNum = 0
    end

    if ctrlName == "AddButton" then
        if self.isAdd == 0 then
            self.clickNum = 1
            self.isAdd = 1
        end

        self:onAddButton(sender)
    elseif ctrlName == "ReduceButton" then
        if self.isAdd == 1 then
            self.clickNum = 1
            self.isAdd = 0
        end

        self:onReduceButton(sender)
    end

end

-- 点击减号按钮，参数longClick为判断是否长按的标志位
function PetAttribDlg:onReduceButton(sender, eventType)
    if not self.selectPet then
        return
    end

    if not sender then return end
    local tag = sender:getParent():getTag()

    if self["useNumber" .. tag] <= 0 then
        -- 长按时无法置灰，放开时再重新置灰
        gf:grayImageView(sender)
        return
    else
        self["useNumber" .. tag] = self["useNumber" .. tag] - 1
    end

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[7000130])
        self.clickNum = 0
    end

    if tag == 3 then
        -- 超级神兽丹
        self:initAddIntimacyFastUsePanel()
    else
        self:initAddExpFastUsePanel()
    end
end

-- 点击加号按钮，参数longClick为判断是否长按的标志位
function PetAttribDlg:onAddButton(sender, eventType)
    if not self.selectPet then
        return
    end

    if not sender then return end
    local tag = sender:getParent():getTag()

    local num = self["useNumber" .. tag]
    if tag == ITEM_INDEX[CHS[3003329]] then
        -- 超级神兽丹
        local useForeverBind = self:isCheck("LimitedCheckBox", "AddIntimacyPanel")
        local maxUseNumber = InventoryMgr:getAmountByNameIsForeverBind(CHS[3003329], useForeverBind)
        if num >= maxUseNumber then
            gf:ShowSmallTips(string.format(CHS[5420316], CHS[3003329]))
            return
        end
    else
        -- 宠物经验丹
        local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber1, self.useNumber2)
        if previewLevel >= self.selectPet:getMaxLevel() then
            gf:ShowSmallTips(CHS[7000132])
            return
        end

        if num >= InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[tag], true) then
            if sender:getParent():getName() == "UsePanel2" then
                gf:ShowSmallTips(string.format( CHS[5420316], CHS[4200404]))
                --gf:ShowSmallTips("#R高级宠物经验丹#n数量不足，无法继续增加。")
            else
                gf:ShowSmallTips(string.format( CHS[5420316], CHS[3003330]))
              --  gf:ShowSmallTips("#R宠物经验丹#n数量不足，无法继续增加。")
            end

            --gf:ShowSmallTips(CHS[7000131])
            return
        end
    end

    self["useNumber" .. tag] = num + 1

    if self.clickNum == 3 then
        gf:ShowSmallTips(CHS[7000130])
        self.clickNum = 0
    end

    if tag == ITEM_INDEX[CHS[3003329]] then
        -- 超级神兽丹
        self:initAddIntimacyFastUsePanel()
    else
        self:initAddExpFastUsePanel()
    end
end

-- 根据“宠物升级所需经验数值”、“宠物经验丹在宠物处于不同等级下的经验提升数值”配表，计算使用一定数量经验丹的预览等级
function PetAttribDlg:getPreviewLevelByUseNumber(useNumber, heightUseNumber)
    if not self.selectPet then
        return
    end

    local level = self.selectPet:queryBasicInt("level")
    local exp = self.selectPet:queryBasicInt("exp")
    local petAttribList

    -- 内测区组与公测区组使用不同的配表，因为升级经验有差异
    if DistMgr:curIsTestDist() then
        petAttribList = PET_ATTRIB_LIST_TEST
    else
        petAttribList = PET_ATTRIB_LIST
    end


    for i= 1, useNumber do
        exp = exp + petAttribList[level].jingyandan_exp
        while exp >= petAttribList[level].exp do
            exp = exp - petAttribList[level].exp
            level = level + 1
            if level > self.selectPet:getMaxLevel() then  -- 容错处理：防止取当前经验配表没有的数值而导致报错，非策划设定
                return level, 0
            end
        end
    end

    for i= 1, heightUseNumber do
        exp = exp + petAttribList[level].gaoji_jingyandan_exp
        while exp >= petAttribList[level].exp do
            exp = exp - petAttribList[level].exp
            level = level + 1
            if level > self.selectPet:getMaxLevel() then  -- 容错处理：防止取当前经验配表没有的数值而导致报错，非策划设定
                return level, 0
            end
        end
    end

    local expPercent = math.floor(exp / petAttribList[level].exp * 100)
    return level, expPercent
end

function PetAttribDlg:updateAddExpPanel()
    if not self.selectPet then
        return
    end

    local function displayFun(itemName, panel, useNum)

        local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber1, self.useNumber2)
        -- 更新使用数量
        self:setLabelText("NumLabel", useNum, panel)

        -- 更新最大等级
        self:setLabelText("MaxLevelLabel_1", self.selectPet:getMaxLevel(), panel)

        -- 更新预览等级
        self:setLabelText("NowLevelLabel_1", string.format(CHS[7000133], previewLevel, previewPercent), panel)

        -- 更新宠物经验丹数量
        if amount == 0 then
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)
        else
            self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)
        end
    end

    local expPanel = self:getControl("AddExpPanel")
    local nomorPanel = self:getControl("ShapePanel1", nil, expPanel)
    displayFun(CHS[3001111], nomorPanel, self.useNumber1)

    local heightPanel = self:getControl("ShapePanel2", nil, expPanel)
    displayFun(CHS[4200404], heightPanel, self.useNumber2)

end

function PetAttribDlg:bindHideGrowBtn()
    self.topLayer = ccui.Layout:create()
    self.topLayer:setLocalZOrder(100)
    self.topLayer:setContentSize(self.root:getContentSize())

    -- 添加监听
    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(function ()
        performWithDelay(self:getControl("PetGrowButton"),function ()
                self:setGrowBtnState(false)
            end,0.2)
        end, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加监听
    local dispatcher = self.topLayer:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, self.topLayer)
    self.root:addChild(self.topLayer)
end

function PetAttribDlg:buttonInit()
    self.btnIsShow = false
end

function PetAttribDlg:bindPanelEvent(name)
    local panel = self:getControl(name, Const.UIPanel)
    if not panel then return end

    local function checkVisible()
        local node1 = self:getControl("AddIntimacyPanel", Const.UIPanel)
        local node2 = self:getControl("AddLongevityPanel", Const.UIPanel)
        local node3 = self:getControl("AddExpPanel", Const.UIPanel)
        local node4 = self:getControl("CheckEffectPanel", Const.UIPanel)
        local node5 = self:getControl("PetFunctionPanel", Const.UIPanel)
        local node6 = self:getControl("TipsPanel", Const.UIPanel)

        if node1:isVisible()then
            return node1
        end

        if node2:isVisible() then
            return node2
        end

        if node3:isVisible() then
            return node3
        end

        if node4:isVisible() then
            return node4
        end

        if node5:isVisible() then
            return node5
        end

        if node6:isVisible() then
            return node6
        end

        return nil
    end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d, name:%s", touchPos.x, touchPos.y, event:getCurrentTarget():getName())
        local panel = checkVisible()

        if not panel or not panel:isVisible() then
            return false
        end

        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        self:closeFastUsePanel()
        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
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

-- 设置宠物
function PetAttribDlg:setPetInfo(pet)
    -- 记录上一次选择宠物的ID
    local lastSelectPetId
    if self.selectPet then
        lastSelectPetId = self.selectPet:getId()
    end

    if pet ~= self.selectPet then
        -- 如果参战按钮有光效，切换宠物的时候去除光效
        local btn = self:getControl("FightButton")
        local effMagic = btn:getChildByTag(Const.ARMATURE_MAGIC_TAG)
        if effMagic then btn:removeChild(effMagic) end

        -- 如果显示悬浮按钮（点化等），切换宠物的时候隐藏
        self:setGrowBtnState(false)

        -- 隐藏功能栏
        local isVisible = self:getControl("PetFunctionPanel"):isVisible()
        if isVisible then
            self:setCtrlVisible("PetFunctionPanel", false)
            self:clearCwwgEffect(self:getControl("DressButton"))
        end

            -- 忽略超级神兽丹的标记
        self.isIgnorChaojiTips = false

        -- 忽略神兽丹的标记
        self.isIgnorTips = false
    end


    self.selectPet = pet
    if not pet then
        self:resetData()
        return
    end

    -- 切换宠物需要清除需要打开元神共通界面标记
    self:clearIsNeedOpenChangeDlg()

    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setCtrlVisible("SuffixImage", true)
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    self:getControl("ShareButton"):setEnabled(true)

    self:updateFastUsePanel()

    -- 切换宠物时重置使用经验丹数量，并更新经验丹使用界面
    -- 如果选中的宠物没有变，则不重置使用经验丹数量
    if not pet or not lastSelectPetId or lastSelectPetId ~= pet:getId() then
        self.useNumber1 = 0
        self.useNumber2 = 0
        self.useNumber3 = 0
    end

    self:initAddIntimacyFastUsePanel()
    self:initAddExpFastUsePanel()

    local icon = 0              -- 形象
    local polar = 0             -- 相性
    local life = 0              -- 气血
    local max_life = 0          -- 最大气血
    local mana = 0              -- 法力
    local max_mana = 0          -- 最大法力
    local phy_power = 0         -- 物伤
    local mag_power = 0         -- 法伤
    local speed = 0             -- 速度
    local def = 0               -- 防御
    local loyalty = 0           -- 忠诚
    local longevity = 0         -- 寿命
    local intimacy = 0          -- 亲密
    local martial = 0           -- 武学
    local lastMonMartial = 0    -- 上月武学
    local exp = 0               -- 经验
    local exp_to_next_level = 0 -- 升级经验
    local percent = 0           -- 经验百分比
    local name = ""
    local level = 0

    local lifeShape = 0        -- 气血成长
    local manaShape = 0        -- 法力成长
    local speedShape = 0       -- 速度成长
    local phyShape = 0         -- 物攻成长
    local magShape = 0         -- 法功成长
    local phyShapeAdd = 0     -- 物攻强化增加成长
    local magShapeAdd = 0     -- 法功强化增加成长
    local totalAdd = 0         -- 增加成长和
    local totalShape = 0       -- 全部成长
    local req_level = 0

    local phyStrongTime = 0   -- 物攻强化次数
    local magStrongTime = 0   -- 法功强化次数

    local phyStrongRate = 0   -- 物攻强化完成度
    local magStrongRate = 0   -- 法功强化完成度

    if nil ~= pet then
        icon = pet:getDlgIcon(nil, nil, true)
        polar = pet:queryBasicInt("polar")
        life = pet:getExtraRecoverLife()
        max_life = pet:queryInt("max_life")
        mana = pet:getExtraRecoverMana()
        max_mana = pet:queryInt("max_mana")
        phy_power = pet:queryInt("phy_power")
        mag_power = pet:queryInt("mag_power")
        speed = pet:queryInt("speed")
        def = pet:queryInt("def")
        loyalty = pet:queryInt("loyalty")
        longevity = pet:queryInt("longevity")
        intimacy = pet:queryInt("intimacy")
        martial = pet:queryInt("martial")
        lastMonMartial = pet:queryInt("last_mon_martial")
        exp = pet:queryInt("exp")
        exp_to_next_level = pet:queryInt("exp_to_next_level")
        percent = exp / exp_to_next_level * 100
        name = pet:queryBasic("name")
        level = pet:queryInt("level")
        req_level = pet:queryInt("req_level")

        lifeShape = pet:queryInt("pet_life_shape")
        manaShape = pet:queryInt("pet_mana_shape")
        speedShape = pet:queryInt("pet_speed_shape")
        phyShape = pet:queryInt("pet_phy_shape")
        magShape = pet:queryInt("pet_mag_shape")
        magShapeAdd = pet:queryInt("mag_rebuild_add")
        phyShapeAdd = pet:queryInt("phy_rebuild_add")
        totalAdd = magShapeAdd + phyShapeAdd
        totalShape = lifeShape + manaShape + speedShape + phyShape + magShape

        phyStrongTime = pet:queryInt("phy_rebuild_level")
        magStrongTime = pet:queryInt("mag_rebuild_level")
        phyStrongRate = pet:queryInt("phy_rebuild_rate")
        magStrongRate = pet:queryInt("mag_rebuild_rate")

        -- 设置形象
        self:setPortrait("PetIconPanel", icon, 0, self.root, true, nil, nil, cc.p(0, -36))
        self:setCtrlEnabled("PetIconPanel", true)
        self:setLabelText("PetPolarLabel", gf:getPolar(polar))
    end

    -- 设置观看和显示的按钮
    if self.selectPet:queryBasicInt("appear") == 1 then
        -- 显示收回按钮
        self:setCtrlVisible("ViewOrHideButton", false)
        self:setCtrlVisible("HideButton", true)
    else
        self:setCtrlVisible("ViewOrHideButton", true)
        self:setCtrlVisible("HideButton", false)
    end

    -- 设置参战和掠阵显示按钮
    local status = self.selectPet:queryBasicInt("pet_status")
    local fightButton = self:getControl("FightButton", Const.UIButton)
    local supplyButton = self:getControl("SupplyButton", Const.UIButton)

    if status == 0 then
        self:setCtrlVisible("FightLabel", true, fightButton)
        self:setCtrlVisible("RestLabel", false, fightButton)
        self:setCtrlVisible("SupplyLabel", true, supplyButton)
        self:setCtrlVisible("RestLabel", false, supplyButton)
    elseif status == 1 then
        self:setCtrlVisible("FightLabel", false, fightButton)
        self:setCtrlVisible("RestLabel", true, fightButton)
        self:setCtrlVisible("SupplyLabel", true, supplyButton)
        self:setCtrlVisible("RestLabel", false, supplyButton)
    elseif status == 2 then
        self:setCtrlVisible("FightLabel", true, fightButton)
        self:setCtrlVisible("RestLabel", false, fightButton)
        self:setCtrlVisible("SupplyLabel", false, supplyButton)
        self:setCtrlVisible("RestLabel", true, supplyButton)
    end

    -- 设置信息
    if PetMgr:isTimeLimitedPet(self.selectPet) then  -- 限时宠物
        local timeLimitStr = PetMgr:convertLimitTimeToStr(self.selectPet:queryBasicInt("deadline"))
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", CHS[7000083])
        self:setLabelText("TimeLimitLabel", timeLimitStr)
    elseif PetMgr:isLimitedPet(self.selectPet) then  -- 限制交易宠物
        local limitDesr, day = gf:converToLimitedTimeDay(self.selectPet:queryInt("gift"))
        self:setLabelText("TradeLabel", limitDesr)
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    else
        self:setLabelText("TradeLabel", "")
        self:setLabelText("UntradeLabel", "")
        self:setLabelText("TimeLimitLabel", "")
    end

    -- 设置生命
    if life < max_life and Me:queryInt("extra_life") == 0 then
        self:setLabelText("LifeValueLabel", string.format("%d", life), nil, COLOR3.RED)
    else
        self:setLabelText("LifeValueLabel", string.format("%d", life), nil, COLOR3.TEXT_DEFAULT)
    end

    -- 设置法力
    if mana < max_mana and Me:queryInt("extra_mana") == 0 then
        self:setLabelText("ManaValueLabel", string.format("%d", mana), nil, COLOR3.RED)
    else
        self:setLabelText("ManaValueLabel", string.format("%d", mana), nil, COLOR3.TEXT_DEFAULT)
    end

    -- 忠诚
    if loyalty < 100 and Me:queryInt("backup_loyalty") == 0 then
        self:setLabelText("LoyaltyValueLabel", loyalty, nil, COLOR3.RED)
    else
        self:setLabelText("LoyaltyValueLabel", loyalty, nil, COLOR3.TEXT_DEFAULT)
    end

    -- 忠诚补充按钮在忠诚小于等于70显示
    self:setCtrlVisible("AddLoyaltyButton", (loyalty <= 70 and Me:queryInt("backup_loyalty") <= 0))

    -- 携带等级
    self:setLabelText("CarryLevelValueLabel", req_level, nil, COLOR3.TEXT_DEFAULT)

    -- 设置经验
    local percent = math.floor(exp * 100 / exp_to_next_level)
    --if percent > 100 then  percent = 100 end
    self:setLabelText("ExpValueLabel", string.format("%d/%d(%d%%)", exp, exp_to_next_level, percent))
    self:setLabelText("ExpValueLabel_1", string.format("%d/%d(%d%%)", exp, exp_to_next_level, percent))
    self:setProgressBar("ExpProgressBar", exp, exp_to_next_level)

    self:setLabelText("PhyValueLabel", phy_power)
    self:setLabelText("MagValueLabel", mag_power)
    self:setLabelText("SpeedValueLabel", speed)
    self:setLabelText("DefenceValueLabel", def)
    self:setLabelText("IntimacyValueLabel", intimacy)

    if (MapMgr:isInShiDao() and ShiDaoMgr:isMonthTaoShiDao())
        or (DistMgr:isInKFSDServer() and ShiDaoMgr:isMonthTaoKFSD())
        or DistMgr:isInKFZC2019Server() then
        self:setLabelText("MartialValueLabel", lastMonMartial)
        self:setLabelText("MartialLabel", CHS[5410321])
    else
    self:setLabelText("MartialValueLabel", martial)
        self:setLabelText("MartialLabel", CHS[5410085])
    end

    -- 寿命
    if longevity < 100 then
        self:setLabelText("LongevityValueLabel", longevity, nil, COLOR3.RED)
    else
        self:setLabelText("LongevityValueLabel", longevity, nil, COLOR3.TEXT_DEFAULT)
    end

    self:setLabelText("NameLabel", pet:getShowName())

    -- 设置经验锁定
    local lock = self.selectPet:queryBasicInt("lock_exp")

    if lock == 0 then
        self:setCtrlVisible("UnlockExp", true)
        self:setCtrlVisible("LockExp", false)
    else
        self:setCtrlVisible("UnlockExp", false)
        self:setCtrlVisible("LockExp", true)
    end

    -- 资质相关
    -- 气血成长
    local basicLife = PetMgr:getPetBasicShape(pet, "life_effect")
    if lifeShape ~= basicLife then
        self:setLabelText("LifeLabel_1", string.format("%d(%d + %d)", lifeShape, basicLife, lifeShape - basicLife), "CheckEffectPanel")
    else
        self:setLabelText("LifeLabel_1", lifeShape, "CheckEffectPanel")
    end

    -- 法力成长
    local basicMana = PetMgr:getPetBasicShape(pet, "mana_effect")
    if manaShape ~= basicMana then
        self:setLabelText("ManaLabel_1", string.format("%d(%d + %d)", manaShape, basicMana, manaShape - basicMana), "CheckEffectPanel")
    else
    self:setLabelText("ManaLabel_1", manaShape, "CheckEffectPanel")
    end

    -- 速度成长
    local basicSpeed = PetMgr:getPetBasicShape(pet, "speed_effect")
    if speedShape ~= basicSpeed then
        self:setLabelText("SpeedLabel_1", string.format("%d(%d + %d)", speedShape, basicSpeed, speedShape - basicSpeed), "CheckEffectPanel")
    else
    self:setLabelText("SpeedLabel_1", speedShape, "CheckEffectPanel")
    end

    -- 物攻成长
    local basicPhy = PetMgr:getPetBasicShape(pet, "phy_effect")
    if phyShape ~= basicPhy then
        self:setLabelText("PhyLabel_1", string.format("%d(%d + %d)", phyShape, basicPhy, phyShape - basicPhy), "CheckEffectPanel")
    else
        self:setLabelText("PhyLabel_1", phyShape, "CheckEffectPanel")
    end

    -- 法攻成长
    local basicMag = PetMgr:getPetBasicShape(pet, "mag_effect")
    if magShape ~= basicMag then
        self:setLabelText("MagLabel_1", string.format("%d(%d + %d)", magShape, basicMag, magShape - basicMag), "CheckEffectPanel")
    else
        self:setLabelText("MagLabel_1", magShape, "CheckEffectPanel")
    end

    -- 总成长
    local totalAll = lifeShape + manaShape + speedShape + phyShape + magShape
    local totalBasic = basicLife + basicMana + basicSpeed + basicPhy + basicMag
    if totalAll ~= totalBasic then
        self:setLabelText("TotalLabel_1", string.format("%d(%d + %d)", totalAll, totalBasic, totalAll - totalBasic), "CheckEffectPanel")
    else
        self:setLabelText("TotalLabel_1", totalShape, "CheckEffectPanel")
    end


    -- 更新布局
    self:updateLayout("LifePanel")
    self:updateLayout("ManaPanel")
    self:updateLayout("PhyPanel")
    self:updateLayout("MagPanel")
    self:updateLayout("SpeedPanel")
    self:updateLayout("DefencePanel")
    self:updateLayout("ExpPanel")
    self:updateLayout("MartialPanel")
    self:updateLayout("LoyaltyPanel")
    self:updateLayout("IntimacyPanel")
    self:updateLayout("LongevityPanel")
    self:updateLayout("CheckEffectPanel")
end

function PetAttribDlg:setPetLogoPanel(pet)
    self:bindListener("PetLogoPanel", self.onPetLogoPanel)
    PetMgr:setPetLogo(self, pet)
end

function PetAttribDlg:onPetLogoPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("PetIdentificationDlg")
    dlg:setData(self.selectPet)
    local dlgSize = dlg.root:getContentSize()
    dlgSize.height = dlgSize.height * Const.UI_SCALE
    local posX = rect.x + rect.width - (50 * Const.UI_SCALE)
    local posY = rect.y - dlgSize.height
    dlg.root:setAnchorPoint(0,0)
    dlg:setPosition(cc.p(posX, posY))
end

-- 限制道具CheckBox
function PetAttribDlg:bindLimitedCheckBox(panelName, name)
    local panel = self:getControl(panelName, Const.UIPanel)

    self:bindCheckBoxListener(name, function(dlg, sender, eventType)
        if panelName == "AddLongevityPanel" then
            self:showFastUsePanel("AddLongevityPanel")

            local flag = InventoryMgr.UseLimitItemDlgs[self.name]
            -- 取十位数
            flag = math.floor(flag / 10)

            if sender:getSelectedState() == true then
                flag = tostring(flag) .. "1"
                InventoryMgr:setLimitItemDlgs(self.name, tonumber(flag))
            else
                flag = tostring(flag) .. "0"

                InventoryMgr:setLimitItemDlgs(self.name, tonumber(flag))
            end
        else
            local flag = InventoryMgr.UseLimitItemDlgs[self.name]
            -- 取个位数
            flag = flag % 10
            if sender:getSelectedState() == true then
                flag = "1" .. tostring(flag)
                InventoryMgr:setLimitItemDlgs(self.name, tonumber(flag))
            else
                flag = "0" .. tostring(flag)
                InventoryMgr:setLimitItemDlgs(self.name, tonumber(flag))
            end
            self:showFastUsePanel("AddIntimacyPanel")
        end

        if self:isCheck(name, panel) then
            gf:ShowSmallTips(CHS[3003316])
        end

    end, panel)

end

-- 绑定提示框
function PetAttribDlg:bindShowTipsByName(keyName)
    local panel = self:getControl(keyName.."Panel")

    panel:addTouchEventListener(function(sender, eventType)

        if eventType == ccui.TouchEventType.began then
            local name = sender:getName()

            if gf:findStrByByte(name, "Loyalty") then
                    gf:showTipInfo(CHS[3003317], sender)
            elseif gf:findStrByByte(name, "Life") then
                    gf:showTipInfo(CHS[3003318], sender)
            elseif gf:findStrByByte(name, "Mana") then
                    gf:showTipInfo(CHS[3003319], sender)
            elseif gf:findStrByByte(name, "Phy") then
                    gf:showTipInfo(CHS[3003320], sender)
            elseif gf:findStrByByte(name, "Mag") then
                    gf:showTipInfo(CHS[3003321], sender)
            elseif gf:findStrByByte(name, "Speed") then
                    gf:showTipInfo(CHS[3003322], sender)
            elseif gf:findStrByByte(name, "Defence") then
                    gf:showTipInfo(CHS[3003323], sender)
            elseif gf:findStrByByte(name, "Longevity") then
                    gf:showTipInfo(CHS[3003324], sender)
            elseif gf:findStrByByte(name, "Intimacy") then
                    if self.selectPet then
                        DlgMgr:openDlgEx("PetIntimacyInfoDlg", self.selectPet)
                    end
            elseif gf:findStrByByte(name, "CarryLevel") then
                    gf:showTipInfo(CHS[4100268], sender)
            elseif gf:findStrByByte(name, "Martial") then
                if not DlgMgr:isDlgOpened("MartinIntroduceDlg") then
                    DlgMgr:openDlgEx("MartinIntroduceDlg", self.selectPet)
                end
            end
                self:getControl("Image_214", Const.UIImage, sender):setVisible(true)
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.canceled then
                self:getControl("Image_214", Const.UIImage, sender):setVisible(false)
        elseif eventType == ccui.TouchEventType.ended then
                self:getControl("Image_214", Const.UIImage, sender):setVisible(false)
        end

    end)
end

function PetAttribDlg:showFastUsePanel(name)
    local intimacyPanel = self:getControl("IntimacyPanel", Const.UIPanel)
    local longevityPanel = self:getControl("LongevityPanel", Const.UIPanel)
    local expPanel = self:getControl("ExpPanel", Const.UIPanel)
    self:setCtrlVisible("AddIntimacyPanel", false)
    self:setCtrlVisible("AddExpPanel", false)
    self:setCtrlVisible("AddLongevityPanel", false)
    self:setCtrlVisible("BackPanel", false, intimacyPanel)
    self:setCtrlVisible("BackPanel", false, longevityPanel)
    self:setCtrlVisible("BackPanel", false, expPanel)

    self:setCtrlVisible(name, true)
    if name == "AddIntimacyPanel" then
        self:setCtrlVisible("BackPanel", true, intimacyPanel)
        self:initAddIntimacyFastUsePanel()
    elseif name == "AddExpPanel" then
        self:setCtrlVisible("BackPanel", true, expPanel)
        self:initAddExpFastUsePanel()
        --self:initFastUsePanel({["ShapePanel1"] = CHS[3003330], ["ShapePanel2"] = CHS[4200404]}, "AddExpPanel")
    elseif name == "AddLongevityPanel" then
        self:setCtrlVisible("BackPanel", true, longevityPanel)
        self:initFastUsePanel({["UseSuperdrugPanel"] = CHS[3003329], ["UsedrugPanel"] = CHS[3003331]}, "AddLongevityPanel")
    end
end

function PetAttribDlg:closeFastUsePanel(name)
    if self:notCloseFastUsePanel(name) then
        return
    end

    local intimacyPanel = self:getControl("IntimacyPanel", Const.UIPanel)
    local longevityPanel = self:getControl("LongevityPanel", Const.UIPanel)
    local expPanel = self:getControl("ExpPanel", Const.UIPanel)
    self:setCtrlVisible("AddIntimacyPanel", false)

    -- 关闭经验丹使用界面时，重置经验丹使用数量
    self:setCtrlVisible("AddExpPanel", false)
    self.useNumber1 = 0
    self.useNumber2 = 0
    self.curTempPanel = nil

    self:setCtrlVisible("AddLongevityPanel", false)
    self:setCtrlVisible("CheckEffectPanel", false)

    local isVisible = self:getControl("PetFunctionPanel"):isVisible()
    if isVisible then
        self:setCtrlVisible("PetFunctionPanel", false)
        self:clearCwwgEffect(self:getControl("DressButton"))
    end


    self:setCtrlVisible("TipsPanel", false)
    self:setCtrlVisible("BackPanel", false, intimacyPanel)
    self:setCtrlVisible("BackPanel", false, longevityPanel)
    self:setCtrlVisible("BackPanel", false, expPanel)
    self:setCtrlVisible("ChosenEffectImage", false, intimacyPanel)
    self:setCtrlVisible("ChosenEffectImage", false, longevityPanel)
    self:setCtrlVisible("ChosenEffectImage", false, expPanel)
end

function PetAttribDlg:getItemNamesByFastPanelName(fastUsePanelName)
    if fastUsePanelName == "AddLongevityPanel" then
        return {["UseSuperdrugPanel"] = CHS[3003329], ["UsedrugPanel"] = CHS[3003331]}
    end
end

function PetAttribDlg:updateFastUsePanel(fastUsePanelName)
    if not self.selectPet then return end
    for _, fastUsePanelName in pairs({"AddLongevityPanel"}) do
        local panel = self:getControl(fastUsePanelName, Const.UIPanel)
        local items = {}
        local isUseLimited = false

        local itemNames = self:getItemNamesByFastPanelName(fastUsePanelName)

        for key, itemName in pairs(itemNames) do
            self:updateOneFastUsePanel(panel, itemName, key)
        end
    end
end

-- 更新单条悬浮框
function PetAttribDlg:updateOneFastUsePanel(panel, itemName, key)
    local isUseLimited = false
    if self:isCheck("LimitedCheckBox", panel) or string.match(itemName, CHS[3003330]) then
        isUseLimited = true
    else
        isUseLimited = false
    end

    local tempPanel = self:getControl(key, Const.UIPanel, panel)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)

    tempPanel.name = itemName

    if amount == 0 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.RED, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    else
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    end

    if panel:getName() == "AddIntimacyPanel" then
        self:updateIntimacyItem(amount)
    end

    return isUseLimited
end

function PetAttribDlg:initAddIntimacyFastUsePanel()
    if not self.selectPet then return end

    local panel = self:getControl("AddIntimacyPanel")
    local itemName = CHS[3003329]
    self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), panel)

    self:updateOneFastUsePanel(panel, itemName, "ShapePanel2")

    -- 更新使用数量
    local useNum = self["useNumber" .. ITEM_INDEX[itemName]]
    local numberPanel = self:getControl("UsePanel2", nil, panel)
    self:setLabelText("NumLabel", useNum, numberPanel)

    -- 寿命预览
    local longevity = self.selectPet:queryInt("longevity") + useNum * Const.CHAOJI_SSD_ADD_LONGEVITY
    if longevity > Const.PET_MAX_LONGEVITY then
        longevity = longevity - math.floor((longevity - Const.PET_MAX_LONGEVITY) / Const.CHAOJI_SSD_ADD_LONGEVITY) * Const.CHAOJI_SSD_ADD_LONGEVITY
    end

    self:setLabelText("MaxLevelLabel_1", longevity, panel)

    -- 亲密预览
    local intimacy = self.selectPet:queryInt("intimacy") + useNum * Const.CHAOJI_SSD_ADD_INTIMACY
    self:setLabelText("NowLevelLabel_1", intimacy, panel)

    self:setCtrlEnabled("ReduceButton", useNum ~= 0, panel)
end

function PetAttribDlg:updateIntimacyItem(num)
    local itemName = CHS[3003329]
    local panel = self:getControl("AddIntimacyPanel")
    local shapePanel = self:getControl("ShapePanel2", nil, panel)

    local img = self:getControl("GuardImage", nil, panel)
    if num > 0 then
        self:setCtrlVisible("PlusImage", false, panel)
        gf:resetImageView(img)
        shapePanel.needBuy = false
    else
        self:setCtrlVisible("PlusImage", true, panel)
        gf:grayImageView(img)
        shapePanel.needBuy = true
    end

    shapePanel.lastNum = num

    local useNum = self["useNumber" .. ITEM_INDEX[itemName]]
    if useNum > num then
        self["useNumber" .. ITEM_INDEX[itemName]] = math.min(useNum, num)
    end
end

function PetAttribDlg:initAddExpFastUsePanel()
    if not self.selectPet then return end
    local panel = self:getControl("AddExpPanel", Const.UIPanel)

    local items = {CHS[3003330], CHS[4200404]}
    local isUseLimited = false
    for i = 1, 2 do
        local shapeName = "ShapePanel" .. i
        local itemName = items[i]
        isUseLimited = self:updateOneFastUsePanel(panel, itemName, shapeName)

        -- 设置img
        local shapePanel = self:getControl(shapeName, Const.UIPanel, panel)
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), shapePanel)
        self:setItemImageSize("GuardImage", shapePanel)

        local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, true)
        if amount == 0 or self.selectPet:getLevel() >= self.selectPet:getMaxLevel() or self.selectPet:getLevel() >= Me:getLevel() then
            self["useNumber" .. ITEM_INDEX[itemName]] = 0
        end

        if itemName == CHS[4200404] and self.selectPet:getLevel() < 70 then
            self.useNumber2 = 0
        end

        -- 更新使用数量
        local useNum = self["useNumber" .. ITEM_INDEX[itemName]]
        local numberPanel = self:getControl("UsePanel" .. i, nil, panel)
        self:setLabelText("NumLabel", useNum, numberPanel)

        self:setCtrlEnabled("ReduceButton", useNum ~= 0, numberPanel)
    end

    local previewLevel, previewPercent = self:getPreviewLevelByUseNumber(self.useNumber1, self.useNumber2)

    -- 更新最大等级
    self:setLabelText("MaxLevelLabel_1", self.selectPet:getMaxLevel(), panel)

    -- 更新预览等级
    self:setLabelText("NowLevelLabel_1", string.format(CHS[7000133], previewLevel, previewPercent), panel)
end

function PetAttribDlg:initFastUsePanel(itemNames, addPanelName)
    if not self.selectPet then return end
    local panel = self:getControl(addPanelName, Const.UIPanel)
    local items = {}
    local isUseLimited = false

    self.curTempPanel = nil

    for key, itemName in pairs(itemNames) do
        isUseLimited = self:updateOneFastUsePanel(panel, itemName, key)

        -- 设置img
        local tempPanel = self:getControl(key, Const.UIPanel, panel)
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), tempPanel)
        self:setItemImageSize("GuardImage", tempPanel)
        self:setLabelText("NameLabel", itemName, tempPanel)
        self:setCtrlVisible("ChosenEffectImage", false, tempPanel)
--[[
        -- 如果是宠物经验丹，则走不同于神兽丹和超级神兽丹的流程
        if string.format(itemName, CHS[3003330]) then

            -- 宠物经验丹使用数量以及预览等级初始化
            self:updateAddExpPanel()
            break
        end
--]]
        self:blindLongPress(key,
            function(dlg, sender, eventTye)
                -- 取消上次选中
                if self.curTempPanel and self.curTempPanel ~= tempPanel then
                    self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
                end

                self.curDelay = 0
                self.isLongPress = true
                self.curItemName = itemName
                self.curIsUseLimited = isUseLimited
                self.curTempPanel = tempPanel
                self:setCtrlVisible("ChosenEffectImage", true, self.curTempPanel)
            end,

            function(dlg, sender, eventType)
                if self.isLongPress then
                    self.isLongPress = false
                    return
                end

                if not sender:getParent():isVisible() then
                    return
                end

                local item = InventoryMgr:getPriorityUseInventoryByName(itemName, isUseLimited)
                if not item then
                    self:needItemOperate(itemName)
                    return
                end

                -- 取消上次选中
                if self.curTempPanel and self.curTempPanel ~= tempPanel then
                    self:setCtrlVisible("ChosenEffectImage", false, self.curTempPanel)
                end

                local para = ""
                if itemName == CHS[3003329] or itemName == CHS[3003331] then
                    if isUseLimited then
                        para = "1"
                    else
                        para = "0"
                    end
                end

                self.curItemName = itemName
                self.curIsUseLimited = isUseLimited
                self.curTempPanel = tempPanel
                self:setCtrlVisible("ChosenEffectImage", true, tempPanel)
                if self:checkCanUseItem(itemName) then
                    if (itemName == CHS[3003329] and self.isIgnorChaojiTips)
                        or (itemName == CHS[3003331] and self.isIgnorTips) then
                        local pos = InventoryMgr:getItemPosByName(itemName)
                        gf:CmdToServer("CMD_FEED_PET", { no = self.selectPet:queryBasicInt("no"), pos = item.pos, para = para})
                    else
                        local pos = InventoryMgr:getItemPosByName(itemName)
                        InventoryMgr:feedPetByIsLimitItem(itemName, self.selectPet, para, isUseLimited)
                    end
                else
                    self:closeFastUsePanel(itemName)
                    self.isLongPress = false
                end
            end,
         panel, true, function ()
                self.isLongPress = false
         end)
    end
end

-- 点击属性弹出提示框
function PetAttribDlg:showTipsByName(sender, eventType)

end

function PetAttribDlg:resetData()
    local fightButton = self:getControl("FightButton", Const.UIButton)
    local supplyButton = self:getControl("SupplyButton", Const.UIButton)
    self:getControl("PetIconPanel"):removeAllChildren()
    self:getControl("PetLogoPanel"):removeAllChildren()
    self:setCtrlEnabled("PetIconPanel", false)
    self:getControl("ShareButton"):setEnabled(false)
    self:setLabelText("PetPolarLabel", "")
    self:setCtrlVisible("ViewOrHideButton", false)
    self:setCtrlVisible("HideButton", true)
    self:setCtrlVisible("FightLabel", true, fightButton)
    self:setCtrlVisible("RestLabel", false, fightButton)
    self:setCtrlVisible("SupplyLabel", true, supplyButton)
    self:setCtrlVisible("RestLabel", false, supplyButton)
    self:setCtrlVisible("SuffixImage", false)

    self:setLabelText("LevelLabel", "")
    self:setLabelText("UntradeLabel", "")
    self:setLabelText("TimeLimitLabel", "")
    self:setLabelText("LifeValueLabel", "")
    self:setLabelText("ManaValueLabel", "")
    self:setLabelText("LoyaltyValueLabel", "")
    self:setLabelText("ExpValueLabel", "")
    self:setLabelText("ExpValueLabel_1", "")
    self:setProgressBar("ExpProgressBar", 0, 1)
    self:setLabelText("PhyValueLabel", "")
    self:setLabelText("MagValueLabel", "")
    self:setLabelText("SpeedValueLabel", "")
    self:setLabelText("DefenceValueLabel", "")
    self:setLabelText("LongevityValueLabel", "")
    self:setLabelText("IntimacyValueLabel", "")
    self:setLabelText("MartialValueLabel", "")
    self:setLabelText("NameLabel", "")
    self:setCtrlVisible("UnlockExp", true)
    self:setCtrlVisible("LockExp", false)
    self:updateLayout("LifePanel")
    self:updateLayout("ManaPanel")
    self:updateLayout("PhyPanel")
    self:updateLayout("MagPanel")
    self:updateLayout("SpeedPanel")
    self:updateLayout("DefencePanel")
    self:updateLayout("ExpPanel")
end

-- 获取当前宠物编号
function PetAttribDlg:getCurrentPet()
    return self.selectPet
end

-- 设置按钮置灰状态
function PetAttribDlg:setButtonStatus()
    if true then return end
    local visible = false
    local status = 0
    if self.selectPet ~= nil then
        visible = self.selectPet:queryBasicInt("appear") == 1
        status = self.selectPet:queryBasicInt("pet_status")
    end

    local viewOrHide = CHS[3000126]
    if visible then
        viewOrHide = CHS[3000127]
    end

    self:setButtonText('ViewOrHideButton', viewOrHide)

    if status > 2 then
        status = 0
    end

    self.statusGroup:selectRadio(status + 1, true)
end

-- 更改宠物状态
function PetAttribDlg:onButtonTouch(sender, eventType)
    if not self.selectPet then return end

    local effMagic = sender:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    if effMagic then sender:removeChild(effMagic) end

    local visible = false
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        local status = 0

        if self.selectPet ~= nil then
            visible = self.selectPet:queryBasicInt("appear") == 1
            status = self.selectPet:queryBasicInt("pet_status")
        end
        return
    end
    local status = 0

    if sender:getName() == "FightButton" then
        local label = self:getControl("FightLabel")
        if label:isVisible() then
            status = 1
        else
            status = 0
        end
    else
        local label = self:getControl("SupplyLabel")
        if label:isVisible() then
            status = 2
        else
            status = 0
        end
    end

    local level = self.selectPet:queryBasicInt("level")
    if level - Me:getLevel() > MAX_LEVEL_DIFF and status > 0 then
        -- 宠物等级过高
        if status == 1 then
            gf:ShowSmallTips(CHS[3000128])    -- 宠物与角色等级相差过大不可参战
        else
            gf:ShowSmallTips(CHS[3000130])    -- 物与角色等级相差过大不可掠阵
        end

        self:setButtonStatus()
        return
    end

    local pet = self.selectPet
    local reqLevel = pet:queryInt("req_level")
    if reqLevel and reqLevel > Me:getLevel() and status > 0 then
        -- 未达到宠物携带等级要求
        if status == 1 then
            gf:ShowSmallTips(string.format(CHS[3000129], reqLevel))    -- 未达到宠物携带等级要求不可参战
        else
            gf:ShowSmallTips(string.format(CHS[3000131], reqLevel))    -- 未达到宠物携带等级要求不可掠阵
        end

        --self:setButtonStatus()
        return
    end

    local petId = pet:getId()

    if not PetMgr:getPetById(petId) then return end     -- 宠物可能被移除了

    if status == 2 then
        if not PetMgr:haveGoodbookSkill(petId) then
            -- 无天书技能
            gf:ShowSmallTips(CHS[3000132])
            --self:setButtonStatus()
            return
        end

        if PetMgr:isAllGodBookDisable(petId) then
            -- 天书技能全部被禁用了
            gf:ShowSmallTips(CHS[7003076])
            return
        end

        if not PetMgr:goodbookHaveNimbus(petId) then
            -- 天书无灵气
            gf:ShowSmallTips(CHS[3000133])
            --self:setButtonStatus()
            return
        end
    end



    if PetMgr:isRidePet(self.selectPet:getId()) then
        if status == 1 then
            gf:ShowSmallTips(CHS[6000545])    -- 该宠物处于骑乘状态，不可参战
        else
            gf:ShowSmallTips(CHS[6000546])    -- 该宠物处于骑乘状态，不可掠阵
        end

        return
    end

    gf:CmdToServer("CMD_SELECT_CURRENT_PET", {
        id = petId,
        pet_status = status,
    })
end


-- 宠物外观
function PetAttribDlg:onDressButton(sender, eventType)

    self:getControl("PetFunctionPanel"):setVisible(false)
    self:clearCwwgEffect(sender)
    if not self.selectPet then return end
    gf:CmdToServer("CMD_FASION_CUSTOM_VIEW", {para = "PetDressDlg"})

end

-- 宠物改名
function PetAttribDlg:onRenameButton(sender, eventType)

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.selectPet == nil then return end

    if self.selectPet:queryBasicInt("fasion_id") ~= 0 then
        gf:ShowSmallTips(CHS[4010289])
        return
    end

    local dlg = DlgMgr:openDlg("RenamePetDlg")
    dlg:setPet(self.selectPet)
end

-- 宠物放生
function PetAttribDlg:onFreeButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectPet == nil then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local nGodBookCount = self.selectPet:queryBasicInt('god_book_skill_count')
    if nGodBookCount and nGodBookCount >= 1 then
        gf:ShowSmallTips(CHS[6200040])
        return
    end

    local pet_status = self.selectPet:queryInt("pet_status")
    if pet_status == 1 then
        gf:ShowSmallTips(CHS[3003334])
        return
    elseif pet_status == 2 then
        gf:ShowSmallTips(CHS[3003335])
        return
    elseif PetMgr:isRidePet(self.selectPet:getId()) then
        gf:ShowSmallTips(CHS[6000544])
        return
    elseif PetMgr:isFeedStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    elseif PetMgr:isCFZHStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[2500066])
        return
    end

    if TaskMgr:isExistNewPersonTasg() then
        gf:ShowSmallTips(CHS[3003336])
        return
    end

    if gf:isExpensive(self.selectPet, true) then
        gf:ShowSmallTips(CHS[3003337])
        ChatMgr:sendMiscMsg(CHS[3003337])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onFreeButton", sender, eventType) then
        return
    end

    local id = self.selectPet:getId()
    local selectPet = self.selectPet    -- 缓存，避免在弹出确认框过程中数据被清除

    -- 当前宠物为限时宠物，不可进行此操作。
    if PetMgr:isTimeLimitedPet(selectPet) then
        gf:confirm(string.format(CHS[4300512], selectPet:getName()), function ()
            gf:CmdToServer("CMD_DROP_PET", { id = id })
        end)
        return
    end

    local function freePet()
        local emptyCount = InventoryMgr:getEmptyPosCount()
        if selectPet:queryInt('rank') == Const.PET_RANK_WILD then
            -- 野生
            gf:CmdToServer("CMD_DROP_PET", { id = id })
        else
            -- 非野生
            local emptyCount = InventoryMgr:getEmptyPosCount()
            local skillCount = #SkillMgr:getPetRawSkillNoAndLadder(id)
            if skillCount == 0 then
                if emptyCount == 0 then
                    gf:ShowSmallTips(CHS[3003338])
                    return
                end
                gf:CmdToServer("CMD_DROP_PET", { id = id })
            else
                if emptyCount < 2 then
                    gf:ShowSmallTips(CHS[3003339])
                    return
                end
                gf:CmdToServer("CMD_DROP_PET", { id = id })
            end
        end
    end

    if self.selectPet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 野生
        gf:confirm(string.format(CHS[2000028], gf:getPetName(self.selectPet.basic, true)), freePet)
    else
        -- 非野生
        local skillCount = #SkillMgr:getPetRawSkillNoAndLadder(id)
        if skillCount == 0 then
            gf:confirm(string.format(CHS[3003340], gf:getPetName(self.selectPet.basic, true)), freePet)
        else

            if PetMgr:isLimitedPet(self.selectPet) then
                gf:confirm(string.format(CHS[4300511], gf:getPetName(self.selectPet.basic, true), skillCount, skillCount), freePet)
            else
            gf:confirm(string.format(CHS[3003341], gf:getPetName(self.selectPet.basic, true), skillCount, skillCount), freePet)
        end
    end
    end
end

-- 忠诚
function PetAttribDlg:onLoyaltyButton(sender, eventType)
    gf:showTipInfo(CHS[2000029], sender)
end

-- 寿命
function PetAttribDlg:onLongevityButton(sender, eventType)
    gf:showTipInfo(CHS[2000030], sender)
end

-- 增加寿命
function PetAttribDlg:onAddLongevityButton(sender, eventType)
    if self.selectPet == nil then return end
    DlgMgr:openDlg("PetAddLongevityDlg")
end

-- 亲密度
function PetAttribDlg:onIntimacyButton(sender, eventType)
    if self.selectPet then
        DlgMgr:openDlgEx("PetIntimacyInfoDlg", self.selectPet)
    end
end

-- 增加忠诚
function PetAttribDlg:onAddLoyaltyButton(sender, eventType)
    if not self.selectPet then return end
    gf:confirm(CHS[4300144], function ()
        local dlg = DlgMgr:openDlg("UserDlg")
        dlg:onAddBackupButton()
        dlg:setLoyaltyEff(true)
        self:onCloseButton()
    end)
end

-- 武学
function PetAttribDlg:onMartialButton(sender, eventType)
    local std = Formula:getStdMartial(Me:queryBasicInt("level"))
    gf:showTipInfo(string.format(CHS[2000032],std), sender)
end

-- 技能
function PetAttribDlg:onSkillButton(sender, eventType)
    if self.selectPet == nil then return end

    --DlgMgr:openDlg('PetSkillDlg')

    local dlg =  DlgMgr:openDlg("PetGrowingDlg")
    dlg:setPetInfo(self.selectPet)
end

-- 属性
function PetAttribDlg:onAttribButton(sender, eventType)
    if self.selectPet == nil then return end
    DlgMgr:openDlg('PetAssignAttribDlg')
end

-- 显示技能面板
function PetAttribDlg:showSkillPanel(tips, flag, para)
    local petList = DlgMgr:openDlg('PetListChildDlg')
    petList:initPetList(flag, para)

    -- 显示技能页面
    DlgMgr:openDlg('PetSkillDlg')

    if tips then
        gf:ShowSmallTips(tips)
    end
end

function PetAttribDlg:setGrowBtnState(isShow)
    if isShow == self.btnIsShow then return end

    self.btnIsShow = not self.btnIsShow
    -- self:setCtrlVisible("PetGrowPanel", self.btnIsShow)
end

function PetAttribDlg:onShowFloatButton(sender, eventType)
    if not sender.name then return end

    if sender.needBuy then
        gf:askUserWhetherBuyItem(sender.name)
    else
        local rect = self:getBoundingBoxInWorldSpace(sender)
        InventoryMgr:showBasicMessageDlg(sender.name, rect)
    end
end

function PetAttribDlg:onPetHuanHuaButton(sender, eventType)
    if not self.selectPet then return end
    local dlg = DlgMgr:openDlg("PetHuanHuaDlg")
    dlg:setMainPet(self.selectPet)
end

function PetAttribDlg:onInheritButton(sender, eventType)
    if not self.selectPet then return end

    if self.selectPet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 当前宠物为野生宠物，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190036])
        return
    end

    if PetMgr:isTimeLimitedPet(self.selectPet) then
        -- 当前宠物为限时宠物，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190037])
        return
    end

    if PetMgr:isLimitedForeverPet(self.selectPet) then
        -- 当前宠物为永久限制交易状态，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190038])
        return
    end

    if PetMgr:isFeedStatus(self.selectPet) then
        -- 当前宠物正处于#R元神分离饲养#n状态，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190039])
        return
    end

    if self.selectPet:queryBasicInt("lock_exp") == 1 then
        -- 当前宠物已锁定经验，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190040])
        return
    end

    DlgMgr:openDlg("PetInheritDlg")
end

function PetAttribDlg:onPetChangeButton(sender, eventType)
    if not self.selectPet then return end

    if not DistMgr:checkCrossDist() then return end

    local robPet = PetMgr:getRobPet()
    if not PetMgr:isRidePet(self.selectPet:getId()) and (not robPet or robPet:getId() ~= self.selectPet:getId()) then
        gf:ShowSmallTips(CHS[2000118])
        return
    end

    -- 判断是否是共通宠物,不是的话弹出确认框，关闭元神共通
    local changePet = PetMgr:getChangePet()
    if changePet and self.selectPet:getId() ~= changePet:getId() then
        gf:confirm(CHS[4200199],
                function ()
                    SystemSettingMgr:sendSeting("award_supply_pet", 0)
                self.isNeedOpenChangeDlg = true
                end)
        return
    end

    local fightPet = PetMgr:getFightPet()
    if not fightPet then
        gf:ShowSmallTips(CHS[2000119])
        return
    end

    local dlg = DlgMgr:openDlg("PetChangeDlg")
    dlg:setChangePet(self.selectPet)
end

function PetAttribDlg:onPetEvolveButton(sender, eventType)
    if not self.selectPet then return end
    local rank = ""
    if self.selectPet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003810]))
        return
    elseif self.selectPet:queryInt('rank') == Const.PET_RANK_ELITE then
        gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003813]))
        return
    elseif self.selectPet:queryInt('rank') == Const.PET_RANK_EPIC then
        gf:ShowSmallTips(string.format(CHS[4100150], CHS[3003814]))
        return
    end

    if self.selectPet:getLevel() > Me:getLevel() + 15 then
        gf:ShowSmallTips(CHS[4100152])
        return
    end

    if self.selectPet:queryInt("req_level") > Me:getLevel() then
        gf:ShowSmallTips(CHS[4100151])
        return
    end

    local dlg = DlgMgr:openDlg("PetEvolveDlg")
    dlg:setMainPet(self.selectPet)
end

function PetAttribDlg:onPetGrowButton(sender, eventType)
    if not self.selectPet then
        return
    end

    if not DistMgr:checkCrossDist() then return end

    self.sendFlyInfoRequestPet = self.selectPet
    gf:CmdToServer("CMD_REQUEST_UPGRADE_TASK_PET")

    -- WDSY-23114 解决宠物成长总览界面飞升信息闪一下问题，在收到MSG_UPGRADE_TASK_PET再打开界面
    -- DlgMgr:openDlg("PetGrowPandectDlg")
end

function PetAttribDlg:onPetFunctionButton(sender, eventType)
    local panel = self:getControl("PetFunctionPanel")
    panel:setVisible(not panel:isVisible())

    if self:clearCwwgEffect(sender) then
        cc.UserDefault:getInstance():setIntegerForKey("cwwgDress" .. gf:getShowId(Me:queryBasic("gid")), 1)
    end
end

function PetAttribDlg:onPetStrengthButton(sender, eventType)
    if not self.selectPet then return end

    if self.selectPet:queryInt('rank') == Const.PET_RANK_ELITE then
        gf:ShowSmallTips(CHS[5300007])
        return
    end

    local dlg = DlgMgr:openDlg("PetDevelopDlg")
    dlg:setPetInfo(self.selectPet)
end

function PetAttribDlg:onPetDianhuaButton(sender, eventType)
    if not self.selectPet then return end

    if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4000384])
        return
    end

    local dlg = DlgMgr:openDlg("PetDianhuaDlg")
    dlg:setPet(self.selectPet)
end

-- 查看/隐藏宠物
function PetAttribDlg:onViewOrHideButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectPet == nil then return end

    local id = 0
    if self.selectPet:queryBasicInt("appear") ~= 1 then
        id = self.selectPet:getId()
    end

    gf:CmdToServer("CMD_SELECT_VISIBLE_PET", { id = id })
end


function PetAttribDlg:MSG_SET_VISIBLE_PET(data)
    self:setPetInfo(self.selectPet)
end

function PetAttribDlg:MSG_SET_CURRENT_PET(data)
    self:setPetInfo(self.selectPet)
end

-- 更新神兽丹、超级神兽丹
function PetAttribDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    if self.curTempPanel and (data[1].name == CHS[3003329] or data[1].name == CHS[3003331]) then
        self:updateFastUsePanel()
    end

    if data[1].name == CHS[3003329] then
        self:initAddIntimacyFastUsePanel()
    end
end

function PetAttribDlg:MSG_UPDATE_PETS(data)
    self:setPetInfo(self.selectPet)
    DlgMgr:sendMsg('PetAssignAttribDlg', 'setPetInfo', self.selectPet)
end

function PetAttribDlg:MSG_UPDATE(data)
    self:setPetInfo(self.selectPet)
    DlgMgr:sendMsg('PetAssignAttribDlg', 'setPetInfo', self.selectPet)
end

function PetAttribDlg:onLockExpButton(sender, eventType)
    if not self.selectPet then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local lock = self.selectPet:queryBasicInt("lock_exp")
    if lock == 0 then
        local moneyStr = gf:getMoneyDesc(5000000)
        local lv = Const.PLAYER_MAX_LEVEL
        local confirmDlg = gf:confirm(string.format(CHS[3003342], lv, moneyStr),
            function()
                self:onLockExpConfirm()
            end)
        confirmDlg:setConfirmText(CHS[7000000])
    else
        self:onLockExpConfirm()
    end
end

function PetAttribDlg:onLockExpConfirmCb(money)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if self.selectPet:queryInt("level") >= Const.PLAYER_MAX_LEVEL then
        gf:ShowSmallTips(string.format(CHS[3003345], self.selectPet:queryBasic("name")))
        return
    end

    if Me:getVipType() == 0 then
        gf:ShowSmallTips(CHS[3003346])
        return
    end

    if PetMgr:isFeedStatus(self.selectPet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end

    if gf:checkCostIsEnough(money) then
        -- 安全锁判断
        if self:checkSafeLockRelease("onLockExpConfirmCb", money) then
            return
        end

        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, self.selectPet:queryBasicInt("id"), 1)
    end
end

function PetAttribDlg:onLockExpConfirmCb2(money)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if gf:checkCostIsEnough(money) then
        -- 安全锁判断
        if self:checkSafeLockRelease("onLockExpConfirmCb2", money) then
            return
        end
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_LOCK_EXP, self.selectPet:queryBasicInt("id"), 0)
    end
end

function PetAttribDlg:onLockExpConfirm()
    if not self.selectPet then return end
    local lock = self.selectPet:queryBasicInt("lock_exp")
    local money = 0
    if lock == 0 then
        money = 5000000
        local moneyStr = gf:getMoneyDesc(money)
        gf:confirm(string.format(CHS[3003344], moneyStr), function()
            self:onLockExpConfirmCb(money)
        end)
    else
        money = 3200000
        local moneyStr = gf:getMoneyDesc(money)
        gf:confirm(string.format(CHS[3003347], moneyStr), function()
            self:onLockExpConfirmCb2(money)
        end)
    end
end

function PetAttribDlg:onLockExpButtonLong(sender, eventType)

end

function PetAttribDlg:checkCanUseItem(name)
    if not self.selectPet then return false end

    -- 宠物经验丹跨服区组禁止使用
    if InventoryMgr:isCrossDistCanNotUse(name) then
        if not DistMgr:checkCrossDist() then return false end
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if name == CHS[3003330] then
        if Me:queryInt("level") < 40 then
            gf:ShowSmallTips(CHS[3003348])
            return false
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003333])
            return false
        end

        if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(CHS[3003349])
            return false
        end

        if self.selectPet:queryInt("level") >= Me:queryInt("level") then
            gf:ShowSmallTips(CHS[3003350])
            return false
        end

        if self.selectPet:queryInt("level") >= self.selectPet:getMaxLevel() then
            -- 若玩家喂养宠物超过当前宠物可达到的最高等级
            gf:ShowSmallTips(CHS[5000269])
            return false
        end

        if self.useNumber1 == 0 and self.useNumber2 == 0 then
            gf:ShowSmallTips(CHS[7000134])
            return false
        end

        if self.selectPet:queryBasicInt("lock_exp") ~= 0 then
            gf:ShowSmallTips(CHS[3003351])
            return false
        end

        return true
    elseif name == CHS[3003331] then
        if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(CHS[3003352])
            return false
        end

        if self.selectPet:queryInt("longevity") >= Const.PET_MAX_LONGEVITY then
            gf:ShowSmallTips(string.format(CHS[3003353], self.selectPet:queryBasic("name")))
            return false
        end

        return true
    elseif name == CHS[3003329] then
        if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(CHS[3003352])
            return false
        end

        return true
    end

    return false
end

-- 部分条件即使不满足使用条件也不隐藏显示神兽丹的panel
function PetAttribDlg:notCloseFastUsePanel(name)
    if name == CHS[3003331] then
        if self.selectPet:queryInt("rank") == Const.PET_RANK_WILD then
            return false
        end

        if self.selectPet:queryInt("longevity") >= Const.PET_MAX_LONGEVITY then
            return true
        end
    end

    return false
end

-- 批量喂养宠物经验丹
function PetAttribDlg:feedPetByIsLimitItem(pet, para, para2)
    gf:CmdToServer("CMD_APPLY_CHONGWU_JINGYANDAN", { no = pet:queryBasicInt("no"), num1 = tonumber(para), num2 = tonumber(para2)})
end

-- 批量喂养超级神兽丹
function PetAttribDlg:feedPetChaoJiShenShouDan(pet, num)
    local str, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    local isUseLimitItem = self:isCheck("LimitedCheckBox", "AddIntimacyPanel") and 1 or 0
    local itemName = CHS[3003329]

    local bindNum = InventoryMgr:getAmountByNameForeverBind(itemName)
    if not self.isIgnorChaojiTips and isUseLimitItem == 1 and bindNum > 0 and day <= Const.LIMIT_TIPS_DAY then
        bindNum = math.min(math.min(bindNum, num), math.ceil((Const.LIMIT_TIPS_DAY + 1 - day) / 10))
        gf:confirm(string.format(CHS[3004113], 10 * bindNum), function()
            gf:CmdToServer("CMD_APPLY_CHAOJISHENSHOUDAN", { no = pet:queryBasicInt("no"), num = num, flag = isUseLimitItem})

            if not DlgMgr:isDlgOpened("PetAttribDlg") then return end
            self:checkLimitedTip(itemName)

            self["useNumber" .. ITEM_INDEX[itemName]]  = 0
             self:initAddIntimacyFastUsePanel()
        end)
    else
        gf:CmdToServer("CMD_APPLY_CHAOJISHENSHOUDAN", { no = pet:queryBasicInt("no"), num = num, flag = isUseLimitItem})
        self["useNumber" .. ITEM_INDEX[itemName]]  = 0
        self:initAddIntimacyFastUsePanel()
    end
end

-- 宠物经验丹使用
function PetAttribDlg:onConfirmButton(sender)
    if not self.selectPet then
        return
    end

    local panelName = sender:getParent():getName()
    if panelName == "AddIntimacyPanel" then
        local itemName = CHS[3003329]  -- 超级神兽丹
        if self:checkCanUseItem(itemName) then
            if self["useNumber" .. ITEM_INDEX[itemName]] == 0 then
                gf:ShowSmallTips(CHS[5420317])
                return false
            end

            -- 批量使用宠物经验丹
            self:feedPetChaoJiShenShouDan(self.selectPet, self.useNumber3)
        end
    else
        local itemName = CHS[3003330]  -- 宠物经验丹
        if self:checkCanUseItem(itemName) then

            -- 批量使用宠物经验丹
            self:feedPetByIsLimitItem(self.selectPet, tostring(self.useNumber1), tostring(self.useNumber2))

            self.useNumber1 = 0
            self.useNumber2 = 0
            self:initAddExpFastUsePanel()
        end
    end
end

function PetAttribDlg:checkLimitedTip(itemName)

    if DlgMgr:getDlgByName("PetGrowingDlg") or
       DlgMgr:getDlgByName("PetDevelopDlg") or
       DlgMgr:getDlgByName("PetStoneDlg") then
        return
    end

    if itemName == CHS[3003329] then
        self.isIgnorChaojiTips = true
    elseif itemName == CHS[3003331] then
        self.isIgnorTips = true
    end
end

function PetAttribDlg:onUpdate(dt)
    if self.isLongPress then
        -- todo
        if not self.curDelay then
            self.curDelay = 0
        end

        self.curDelay = self.curDelay + (1 / Const.FPS)

        if self.curDelay >= DELAY_TIME then
            self.curDelay = self.curDelay - DELAY_TIME
            if self:checkCanUseItem(self.curItemName) then
                local item = InventoryMgr:getPriorityUseInventoryByName(self.curItemName, self.curIsUseLimited)
                if not item then
                    self:needItemOperate(self.curItemName)
                    return
                end

                local pos = item.pos

                local itemTemp = InventoryMgr:getItemByPos(pos)

                -- 安全锁判断
                if SafeLockMgr:isToBeRelease(itemTemp) then
                    return
                end

                local isNeedShow = true
                local para = ""

                if self.curItemName == CHS[3003329] then
                    if self.curIsUseLimited then
                        para = "1"
                    else
                        para = "0"
                    end
                    if self.curIsUseLimited and not self.isIgnorChaojiTips then

                    else
                        isNeedShow = false
                    end
                elseif self.curItemName == CHS[3003331] then
                    if self.curIsUseLimited then
                        para = "1"
                    else
                        para = "0"
                    end
                    if self.curIsUseLimited and not self.isIgnorTips then

                    else
                        isNeedShow = false
                    end
                else
                    isNeedShow = false
                end

                if isNeedShow then
                    InventoryMgr:feedPetByIsLimitItem(self.curItemName, self.selectPet, para, self.curIsUseLimited)
                else
                    local items = InventoryMgr:getItemByName(self.curItemName, not self.curIsUseLimited)
                    gf:CmdToServer("CMD_FEED_PET", { no = self.selectPet:queryBasicInt("no"), pos = item.pos, para = para})
                end
            else
                self:closeFastUsePanel(self.curItemName)
                self.isLongPress = false
            end

        end

    end
end

-- 打开界面需要某些参数需要重载这个函数
function PetAttribDlg:onDlgOpened(param)
    local dlg = DlgMgr:openDlg("PetListChildDlg")
    dlg:onDlgOpened(tonumber(param[1]))

    if param[2] and param[2] == "combat" and PetMgr.pets[tonumber(param[1])] then
        local btn = self:getControl("FightButton")
        -- lixh2 WDSY-21401 帧光效修改为粒子光效：宠物参战按钮环绕光效
        gf:createArmatureMagic(ResMgr.ArmatureMagic.pet_fight_btn, btn, Const.ARMATURE_MAGIC_TAG)
    end
end

function PetAttribDlg:needItemOperate(itemName)
    if itemName == CHS[3003329] then
        gf:askUserWhetherBuyItem(itemName)
    elseif itemName == CHS[3003330] then
        gf:ShowSmallTips(CHS[3003354])
    elseif itemName == CHS[3003331] then
        gf:ShowSmallTips(CHS[3003354])
    end
end

function PetAttribDlg:getMaxUseNumber(key)
    if not self.selectPet then
        return
    end

    local level = self.selectPet:queryBasicInt("level")
    local maxLevel = self.selectPet:getMaxLevel()
    local exp = self.selectPet:queryBasicInt("exp")
    local petAttribList
    local canUseNumber = InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[key], true) or 0

    if level >= maxLevel then return 0 end

    -- 内测区组与公测区组使用不同的配表，因为升级经验有差异
    if DistMgr:curIsTestDist() then
        petAttribList = PET_ATTRIB_LIST_TEST
    else
        petAttribList = PET_ATTRIB_LIST
    end

    -- 模拟使用宠物经验丹
    local previewUseJingyandan = function(useNumber, jingyandan_exp, limitLevel)
        if limitLevel and level >= limitLevel then return 0 end
        for i= 1, useNumber do
            exp = exp + petAttribList[level][jingyandan_exp]
            while exp >= petAttribList[level].exp do
                exp = exp - petAttribList[level].exp
                level = level + 1
                if limitLevel and level >= limitLevel then
                    return i
                end
            end
        end
        return useNumber
    end

    if key ~= 2 then
        previewUseJingyandan(self.useNumber2, "gaoji_jingyandan_exp")
        canUseNumber = previewUseJingyandan(canUseNumber, "jingyandan_exp", maxLevel)
    else
        previewUseJingyandan(self.useNumber1, "jingyandan_exp")
        canUseNumber = previewUseJingyandan(canUseNumber, "gaoji_jingyandan_exp", maxLevel)
    end


    return canUseNumber
end

-- 数字键盘插入数字
function PetAttribDlg:insertNumber(num, key)
    local count = num

    if count < 0 then
        count = 0
    end

    if key == 3 then
        -- 超级神兽丹
        local useForeverBind = self:isCheck("LimitedCheckBox", "AddIntimacyPanel")
        local maxUseNumber = InventoryMgr:getAmountByNameIsForeverBind(CHS[3003329], useForeverBind)
        if count > maxUseNumber then
            gf:ShowSmallTips(string.format(CHS[5420316], CHS[3003329]))

            count = maxUseNumber
        end
    else
        local maxUseNumber = self:getMaxUseNumber(key) or 0

        if maxUseNumber < count then
            if maxUseNumber == InventoryMgr:getAmountByNameIsForeverBind(JINGYAN_DAN[key], true) then
                gf:ShowSmallTips(string.format(CHS[5420316], JINGYAN_DAN[key]))
            else
                gf:ShowSmallTips(CHS[5420008])
            end

            count = maxUseNumber
        end
    end

    self["useNumber" .. key] = count

    if  key == 3 then
        self:initAddIntimacyFastUsePanel()
    else
        self:initAddExpFastUsePanel()
    end

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(count)
    end
end

function PetAttribDlg:clearIsNeedOpenChangeDlg()
    self.isNeedOpenChangeDlg = false
end

function PetAttribDlg:MSG_SET_SETTING(data)
    for k, v in pairs(data["setting"]) do
        if "award_supply_pet" == k and 0 == v and self.isNeedOpenChangeDlg then

            -- 通过宠物属性界面关闭了宠物元神共通
            local fightPet = PetMgr:getFightPet()
            if not fightPet then
                gf:ShowSmallTips(CHS[2000119])
                return
            end

            local selectPet = PetMgr:getLastSelectPet()
            if selectPet:queryBasicInt('pet_status') == 2 or PetMgr:isRidePet(selectPet:getId()) then
                local dlg = DlgMgr:openDlg("PetChangeDlg")
                dlg:setChangePet(selectPet)
            end

            self.isNeedOpenChangeDlg = false

            return
        end
    end
end

function PetAttribDlg:MSG_UPGRADE_TASK_PET(data)
    if not data.id or not self.sendFlyInfoRequestPet then
        return
    end

    -- 点击宠物属性界面成长按钮，在此处打开宠物成长预览界面，但是如果服务器消息还没回来，玩家切换到另外的宠物，则不打开
    if self.sendFlyInfoRequestPet:getId() == self.selectPet:getId() then
        DlgMgr:openDlg("PetGrowPandectDlg")
    end
end

function PetAttribDlg:MSG_FINISH_PET_INHERIT(data)
    local mainPet = PetMgr:getPetByNo(data.mainPetNo)
    if not mainPet then
        return
    end

    local dlg = DlgMgr:getDlgByName("PetListChildDlg")
    dlg:selectPetId(mainPet:queryBasicInt("id"))
end

return PetAttribDlg
