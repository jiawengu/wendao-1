-- GuardAttribDlg.lua
-- Created by liuhb  Jan/29/2015
-- 守护属性界面

local DataObject = require('core/DataObject')
local RadioGroup = require("ctrl/RadioGroup")
local GuardAttribDlg = Singleton("GuardAttribDlg", Dialog)

local POLAR_MAX = 30 + 8
local POLAR_PC = 0.8

local STUDY_BSKILL = {1, 24, 40, 60}
local STUDY_DSKILL = {1, 40, 50, 70}

local GUARD_ATTR_CHANGE_COLOR = COLOR3.BLUE
local GUARD_ATTR_NORMAL_COLOR = COLOR3.TEXT_DEFAULT

-- 消耗类型
local GUARD_COST_TYPE = {
    ["GOLD"]    = 0,        -- 仅能用金元宝
    ["CASH"]    = 1,        -- 代金券
    ["SILVER"]  = 2,        -- 仅能用银元宝
    ["COIN"]    = 3,        -- 元宝,含金元宝和银元宝
}

function GuardAttribDlg:init()
    -- 基础控件
    self:bindListener("RenameButton", self.onRenameButton)
    self:bindListener("CombatButton", self.onCombatButton)
    self:bindListener("SupplyButton", self.onSupplyButton)
    self:bindListener("AttribButton", self.onAttribButton)

    -- 已经召唤界面
    self:bindListener("SkillButton", self.onSkillButton)
    self:bindListener("AdvanceButton", self.onAdvanceButton)
    self:bindListener("DevelopButton", self.onDevelopButton)

    -- 未召唤界面
    self:bindListener("CallButton", self.onCallButton)

    -- 辅助下拉
    self:bindListener("SupplyPanel", self.onSupplyPanel)
    self:bindListener("AttackPanel", self.onAttackPanel)
    self:bindTouchEvent()


    self:onTouchAttribPanel("LifePanel", CHS[3002751])
    self:onTouchAttribPanel("PhyPowerPanel", CHS[3002752])
    self:onTouchAttribPanel("MagPowerPanel", CHS[3002753])
    self:onTouchAttribPanel("SpeedPanel", CHS[3002754])
    self:onTouchAttribPanel("DefencePanel", CHS[3002755])
    self:onTouchAttribPanel("IntimacyPanel", CHS[3002756])
    self:onTouchAttribPanel("DevelopPanel", CHS[3002757])

    self.unOwnGuards = {}

    RedDotMgr:removeOneRedDot("GameFunctionDlg", "GuardButton")
    PromoteMgr:removeByTag(PROMOTE_TYPE.TAG_GET_GUARD)

    self:hookMsg("MSG_BASIC_GUARD_ATTRI")
    self:hookMsg("MSG_LEVEL_UP")
end

-- 设置守护信息
function GuardAttribDlg:setGuardInfo(guardName)
    if nil == guardName then return end

    self.selectName = guardName
    local guard = GuardMgr:getGuardByRawName(guardName)

    -- 取不到说明还没召唤
    if not guard then
        guard = self.unOwnGuards[guardName]
        if guard then
            self:setExistGuardInfo(guard)
        else
            self:setUnExistGuardInfo(guardName)
        end

        self:setCtrlVisible("CalledPanel", false)
        self:setCtrlVisible("UnCalledPanel", true)
    else
        self:setExistGuardInfo(guard)
        self:setCtrlVisible("CalledPanel", true)
        self:setCtrlVisible("UnCalledPanel", false)
    end
end

-- 设置不存在守护数据
function GuardAttribDlg:setUnExistGuardInfo(guardName)
    local guardInfo = GuardMgr:getGuardCalledInfoByRawName(guardName)
    if not guardInfo then return end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_GUARD_BASIC_ATTRI, guardName, string.format("%d;%d", gf:getIntPolar(guardInfo[3]), guardInfo[8])) -- "相性;rank"
end

-- 设置存在守护的数据
function GuardAttribDlg:setExistGuardInfo(guard)
    if nil == guard then return end

    -- 设置基础属性
    self:setBasicAttri(guard)

    -- 在对应的Label内设置相应的值
    local metal = guard:queryInt("metal")
    local wood = guard:queryInt("wood")
    local water = guard:queryInt("water")
    local fire = guard:queryInt("fire")
    local earth = guard:queryInt("earth")

    local id = guard:queryInt("id")
    if 0 == id then
        self:setLabelText("MetalValueLabel", metal)
        self:setLabelText("WoodValueLabel", wood)
        self:setLabelText("WaterValueLabel", water)
        self:setLabelText("FireValueLabel", fire)
        self:setLabelText("EarthValueLabel", earth)
    else
        local guardStrength = GuardMgr:getStrengthById(id)
        self:setLabelTextWithCheckGrow("MetalValueLabel", "strengthlev", metal, guardStrength, 9)
        self:setLabelTextWithCheckGrow("WoodValueLabel", "strengthlev", wood, guardStrength, 9)
        self:setLabelTextWithCheckGrow("WaterValueLabel", "strengthlev", water, guardStrength, 9)
        self:setLabelTextWithCheckGrow("FireValueLabel", "strengthlev", fire, guardStrength, 9)
        self:setLabelTextWithCheckGrow("EarthValueLabel", "strengthlev", earth, guardStrength, 9)
    end
end

function GuardAttribDlg:setBasicAttri(guard)
    local name = ""
    local icon = 0              -- 形象
    local polar = 0             -- 相性
    local life = 0              -- 气血
    local max_life = 0          -- 最大气血
    local phy_power = 0         -- 物伤
    local mag_power = 0         -- 法伤
    local speed = 0             -- 速度
    local def = 0               -- 防御
    local intimacy = 0          -- 亲密
    local con = 0               -- 体质
    local wiz = 0               -- 灵力
    local str = 0               -- 力量
    local dex = 0               -- 敏捷
    local level = 0             -- 等级
    if nil ~= guard then
        name =      guard:queryBasic("name")
        icon =      guard:queryBasic("icon")
        polar =     guard:queryBasicInt("polar")
        life =      guard:queryInt("life")
        max_life =  guard:queryInt("max_life")
        phy_power = guard:queryInt("phy_power")
        mag_power = guard:queryInt("mag_power")
        speed =     guard:queryInt("speed")
        def =       guard:queryInt("def")
        intimacy =  guard:queryInt("intimacy")
        con =       guard:queryInt("con")
        wiz =       guard:queryInt("wiz")
        str =       guard:queryInt("str")
        dex =       guard:queryInt("dex")
        level =     guard:queryInt("level")

        -- 更新参战按钮
        local isFight = guard:queryInt("combat_guard")
        if 1 == isFight then
            self:setLabelText("CombatLabel", CHS[5000026])
        else
            self:setLabelText("CombatLabel", CHS[5000016])
        end

        -- 更新辅助选框
        local isAssist = guard:queryInt("use_skill_d")
        if 1 ~= isAssist then
            self:setLabelText("SupplyLabel", CHS[3002758])
        else
            self:setLabelText("SupplyLabel", CHS[3002759])
        end
    end

    -- 设置信息
    self:setLabelText("GuardNameLabel", name)  -- 设置守护属性——名称
    self:setPortrait("GuardIconPanel", icon, 0, nil, true, nil, nil, cc.p(0, -40))

    self:setLabelText("LifeValueLabel", max_life)
    self:setLabelText("PhyValueLabel", phy_power, nil, GUARD_ATTR_CHANGE_COLOR)
    self:setLabelText("MagValueLabel", mag_power, nil, GUARD_ATTR_CHANGE_COLOR)
    self:setLabelText("SpeedValueLabel", speed, nil, GUARD_ATTR_CHANGE_COLOR)
    self:setLabelText("DefenceValueLabel", def, nil, GUARD_ATTR_CHANGE_COLOR)
    self:setLabelText("IntimacyValueLabel", intimacy, nil, GUARD_ATTR_NORMAL_COLOR)
    self:setDevelopValue(GuardMgr:getGrowAttrib(guard:queryInt("id")))

    -- 相性图标
    local polar = gf:getPolar(polar)
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, "CalledPanel")

    local grow_attr = GuardMgr:getGrowAttrib(guard:queryInt("id"))
    self:setLabelTextWithCheckGrow("ConValueLabel", "con", con, grow_attr)
    self:setLabelTextWithCheckGrow("WizValueLabel", "wiz", wiz, grow_attr)
    self:setLabelTextWithCheckGrow("StrValueLabel", "str", str, grow_attr)
    self:setLabelTextWithCheckGrow("DexValueLabel", "dex", dex, grow_attr)

    if 0 == guard:queryInt("id") then
        local callLevel = guard:queryInt("call_level")
        if callLevel > Me:queryInt("level") then
            self:setLabelText("LevelValueLabel", callLevel, nil, COLOR3.RED)
        else
            self:setLabelText("LevelValueLabel", callLevel, nil, COLOR3.TEXT_DEFAULT)
        end
        
        self:setImagePlist("PolarImage", polarPath, "UnCalledPanel")

        -- 设置金钱消耗
        local cashText, fontColor = gf:getArtFontMoneyDesc(guard:queryInt('cost_coin'))
        self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 25)

        local rank = guard:queryInt("rank")
        local guardInfo = GuardMgr:getGuardCalledInfoByRawName(guard:queryBasic('raw_name'))
        local costType = DistMgr:isTestDist(GameMgr:getDistName()) and guardInfo[14] or guardInfo[6]

        if 3 == rank then
            self:setCtrlVisible("MoneyImage", fasle)
            self:setCtrlVisible("CoinImage", GUARD_COST_TYPE.GOLD == costType)
            self:setCtrlVisible("CoinImage1", GUARD_COST_TYPE.COIN == costType)
        else
            self:setCtrlVisible("MoneyImage", true)
            self:setCtrlVisible("CoinImage", fasle)
            self:setCtrlVisible("CoinImage1", fasle)
        end
    end

    -- 设置对应的描述
    local desc = GuardMgr:getGuardDescByRawName(guard:queryBasic("raw_name"))
    local rank = guard:queryInt("rank")

    self:setLabelText("GuardDescLabel", desc["desc" .. rank])

    -- 设置品质
    local rankImg = self:getGuardColorByRank(rank)
    local coverImgCtrl = self:getControl("QualityImage")
    self:setCtrlVisible("QualityImage", true)
    coverImgCtrl:loadTexture(rankImg)

    -- 更新布局
    self:updateLayout("LifePanel")
    self:updateLayout("PhyPowerPanel")
    self:updateLayout("MagPowerPanel")
    self:updateLayout("SpeedPanel")
    self:updateLayout("DefencePanel")
    self:updateLayout("ConPanel")
    self:updateLayout("WizPanel")
    self:updateLayout("StrPanel")
    self:updateLayout("DexPanel")
end

function GuardAttribDlg:getGuardColorByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_attr_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_attr_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_attr_rank3
    end

    return nil
end

-- 守护培养进度
function GuardAttribDlg:setDevelopValue(developAttrib)
    -- 培养等级
    local level = self:getControl("DevelopValueLabel", Const.UILabel)
    if developAttrib["degree_32"] ~= 0 then
        level:setString(string.format(CHS[3002761], developAttrib["rebuild_level"], developAttrib["degree_32"]))
    else
        level:setString(string.format(CHS[3002762], developAttrib["rebuild_level"]))
    end
end

function GuardAttribDlg:setLabelTextWithCheckGrow(labelStr, key, value, table, limit)
    local lt = limit or 0
    if table[key] and table[key] > lt then
        self:setLabelText(labelStr, value)
    else
        self:setLabelText(labelStr, value)
    end
end

-- 设置参战状态
function GuardAttribDlg:onCombatButton(sender, eventType)
    if nil == self.selectName then return end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002763])
        return
    end

    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if not guard then
        return
    end

    local isFight = guard:queryInt("combat_guard")

    if 1 == isFight then
        -- 如果是参战状态下，发送休息命令
        gf:CmdToServer("CMD_GUARDS_CHEER", {
            guard_id = guard:queryBasicInt("id"),
            cheer = 0,
        })
    else
        -- 如果在休息状态下
        local isUseSkillD = guard:queryInt("use_skill_d")

        if true == isUseSkillD then
            self:setGuardAssist()
        end
        local fightCount = DlgMgr:sendMsg("GuardListChildDlg", "getCurrentFightGuardCount")
        if 4 > fightCount then
            -- 发送参战命令
            gf:CmdToServer("CMD_GUARDS_CHEER", {
                guard_id = guard:queryBasicInt("id"),
                cheer = 1,
            })
        else
            -- 如果当前参战守护大于等于4个，则弹出“替换守护”选择框
            local dlg = DlgMgr:openDlg("TeamGuardMenuDlg")
            dlg:initExchangeGuard(guard:queryBasicInt("id")) -- 初始化“替换守护”界面
            dlg:setIndex(1, self:getBoundingBoxInWorldSpace(self:getControl("CombatButton")))  -- 第一个参数代表选择框放在按钮右边
        end
    end
end

-- 设置辅助状态
function GuardAttribDlg:onSupplyButton(sender, eventType)
    if nil == self.selectName then return end


    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if not guard then
        return
    end

    self:setCtrlVisible("ChosePanel", true)

   --[[ local isFight = guard:queryInt("combat_guard")
    local isUseSkillD = guard:queryInt("use_skill_d")

    if 1 ~= isUseSkillD then
        self:setGuardAssist()
        gf:ShowSmallTips(CHS[3002764])
    else
        self:setGuardUnAssist()
    end]]
end

function GuardAttribDlg:onSupplyPanel()
    self:setCtrlVisible("ChosePanel", false)
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if not guard then
        return
    end

    local isUseSkillD = guard:queryInt("use_skill_d")
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002763])
        return
    elseif isUseSkillD == 1 then
        return
    end

    self:setGuardAssist()

    gf:ShowSmallTips(CHS[3002765])
end

function GuardAttribDlg:onAttackPanel()
    self:setCtrlVisible("ChosePanel", false)
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if not guard then
        return
    end

    local isUseSkillD = guard:queryInt("use_skill_d")
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002763])
        return
    elseif isUseSkillD ~= 1 then
        return
    end

    self:setGuardUnAssist()
    gf:ShowSmallTips(CHS[3002766])
end

function GuardAttribDlg:bindTouchEvent()
    local chosePanel = self:getControl("ChosePanel")
    local bkPanel = self:getControl("BKPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())

    local function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(chosePanel)
        local toPos = touch:getLocation()
        local classRect = self:getBoundingBoxInWorldSpace(listPanel)

        if not cc.rectContainsPoint(rect, toPos) and  chosePanel:isVisible() then
            chosePanel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

function GuardAttribDlg:setGuardAssist()
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if nil == guard then return end

    gf:sendGeneralNotifyCmd(NOTIFY.GUARD_USE_SKILL_D, guard:queryBasicInt("id"), 1)
end

function GuardAttribDlg:setGuardUnAssist()
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if nil == guard then return end

    gf:sendGeneralNotifyCmd(NOTIFY.GUARD_USE_SKILL_D, guard:queryBasicInt("id"), 0)
end

function GuardAttribDlg:onRenameButton(sender, eventType)
    if nil == self.selectName then return end
    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if nil == guard then return end
    local dlg = DlgMgr:openDlg("GuardRenameDlg")
    dlg:setGuard(guard)
end

-- 召唤守护
function GuardAttribDlg:onCallButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.selectName then
        gf:ShowSmallTips(CHS[3002768])
        return
    end

    local guardInfo = GuardMgr:getGuardCalledInfoByRawName(self.selectName)
    if Me:getLevel() < guardInfo[1] then
        -- 未达到召唤要求的等级，给予相应的提示
        gf:ShowSmallTips(CHS[3000113])
        return
    end

    local sour = InventoryMgr:getItemByName(CHS[3002623])
    if self.selectName == CHS[3002631] and next(sour) then
        gf:confirm(CHS[4200009], function ()
            local dlg = DlgMgr:openDlg("BagDlg")
            dlg:onDlgOpened({CHS[3002623]})
            self:onCloseButton()
        end)
        return
    end

    if GuardMgr:isGuardExist(guardInfo[4]) then
        -- 已拥有该守护，给予相应的提示
        gf:ShowSmallTips(CHS[3000112])
        return
    end

    local moneyStr = ""
    local costType = DistMgr:isTestDist(GameMgr:getDistName()) and guardInfo[14] or guardInfo[6]

    if  GUARD_COST_TYPE.SILVER == costType
        or GUARD_COST_TYPE.GOLD == costType
        or GUARD_COST_TYPE.COIN == costType
    then
        -- 消耗的是金元宝/银元宝
        -- 安全锁判断
        if self:checkSafeLockRelease("onCallButton") then
            return
        end

        if Me:queryBasicInt('gold_coin') < guardInfo[7] and GUARD_COST_TYPE.GOLD == costType then
            -- 金元宝不足
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end

        if Me:queryBasicInt('silver_coin') < guardInfo[7] and GUARD_COST_TYPE.SILVER == costType then
            -- 银元宝不足
            gf:askUserWhetherBuyCoin("silver_coin")
            return
        end

        if Me:getTotalCoin() < guardInfo[7] and GUARD_COST_TYPE.COIN == costType then
            -- 元宝不足
            gf:askUserWhetherBuyCoin()
            return
        end

        moneyStr = guardInfo[7] .. CHS[3002769]
    else
        -- 消耗的是游戏币
        local cash = guardInfo[7]
        if not gf:checkHasEnoughMoney(cash) then
            return
        end

        local cashText = gf:getMoneyDesc(guardInfo[7])
        moneyStr = cashText .. CHS[3002770]
    end

    gf:confirm(string.format(CHS[3002771], moneyStr, self.selectName), function()
        -- 召唤守护
        gf:sendGeneralNotifyCmd(NOTIFY.CALL_GUARD, guardInfo[4])
    end)

end

function GuardAttribDlg:onAttribButton(sender, eventType)
    local attribPanel = self:getControl("AttribPanel_2")

    local isVisible = attribPanel:isVisible()
    attribPanel:setVisible(not isVisible)

    gf:bindTouchListener(attribPanel, function(touch, event)
            local pos = touch:getLocation()
            local eventCode = event:getEventCode()
            if eventCode == cc.EventCode.BEGAN then
                local box = self:getBoundingBoxInWorldSpace(attribPanel)
                if not cc.rectContainsPoint(box, pos) then
                    attribPanel:setVisible(false)
                end

                return false
            end
        end, {
            cc.Handler.EVENT_TOUCH_BEGAN
        }, true)
end

function GuardAttribDlg:onSkillButton(sender, eventType)
    if self.selectName == nil then return end
    local dlg = DlgMgr:openDlg("GuardSkillDlg")
    dlg:setSkill(GuardMgr:getGuardByRawName(self.selectName))
end

function GuardAttribDlg:onAdvanceButton(sender, eventType)
    if self.selectName == nil then return end

    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if nil == guard then return end

    if guard:queryInt("rank") == GUARD_RANK.SHENLING then
        gf:ShowSmallTips("#Y" .. guard:queryBasic("name") .. CHS[3002772])
        return
    end

    -- 打开历练界面
    local dlg = DlgMgr:openDlg("GuardAdvanceDlg")
    if dlg then
        dlg:setGuardAdvanceInfo(guard)
        return
    end
end

function GuardAttribDlg:onDevelopButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if self.selectName == nil then return end

    if Me:queryInt("level") < 55 then
        gf:ShowSmallTips(CHS[3002773])
        return
    end

    local guard = GuardMgr:getGuardByRawName(self.selectName)
    if nil == guard then return end

    -- 打开培养界面
    local dlg = DlgMgr:openDlg("GuardDevelopDlg")
    if dlg then
        dlg:setGuardDevelopInfo(guard:queryBasicInt("id"))
        return
    end
end

function GuardAttribDlg:MSG_LEVEL_UP(data)
    if data.id ~=  Me:getId() then return end
    self.unOwnGuards = {}
end

function GuardAttribDlg:MSG_BASIC_GUARD_ATTRI(data)
    local guardInfo = GuardMgr:getGuardCalledInfoByRawName(data.raw_name)

    if nil == guardInfo then return end

    local guard = GuardMgr:getGuardByRawName(data.raw_name)

    if guard then return end
    
    local guard = DataObject.new() 
    data.icon = guardInfo[2]
    data.name = data.raw_name
    data.call_level = guardInfo[1]
    data.polar = gf:getIntPolar(guardInfo[3])
    data.cost_coin = guardInfo[7]
    data.rank = guardInfo[8]
    guard:absorbBasicFields(data)
    self:setExistGuardInfo(guard)

    self.unOwnGuards[data.raw_name] = guard
end

-- 点击弹出属性的悬浮框
function GuardAttribDlg:onTouchAttribPanel(ctrlName, info)
    local ctrl = self:getControl(ctrlName)
    local selectImage = self:getControl("ChosenEffectImage", Const.UIImage, ctrl)
    selectImage:setVisible(false)
    ctrl:setTouchEnabled(true)
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if sender:getName() == "IntimacyPanel" then
                local guard = GuardMgr:getGuardByRawName(self.selectName)
                local intimacy = guard and guard:queryInt("intimacy") or 0
                DlgMgr:openDlgEx("GuardIntimacyInfoDlg", intimacy)
            else
                selectImage:setVisible(true)
                gf:showTipInfo(info, ctrl)
            end
        elseif eventType == ccui.TouchEventType.moved then
            selectImage:setVisible(false)
        elseif eventType == ccui.TouchEventType.ended then
            selectImage:setVisible(false)
        end
    end

    if ctrl then
        ctrl:addTouchEventListener(listener)
    end
end


function GuardAttribDlg:onDlgOpened(list)
    performWithDelay(self.root,function()
        DlgMgr:sendMsg("GuardListChildDlg", "selectGuardByName", list[1])
    end, 0)
end

return GuardAttribDlg
