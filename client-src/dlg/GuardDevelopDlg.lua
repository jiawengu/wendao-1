-- GuardDevelopDlg.lua
-- Created by zhengjh Feb/3/2015
-- 守护培养

local ATTRIBUTE_CONFIG =
{
    str = "Str",
    dex = "Dex",
    wiz = "Wiz",
    con = "Con",
    StrResultLabel = CHS[6000011],
    WizResultLabel = CHS[6000012],
    DexResultLabel = CHS[6000013],
    ConResultLabel = CHS[6000014],
    developSave = 1,
    developCancel = 0,
}

local FloatImgTag = 999

local GUARD_ATTR_CHANGE_COLOR = COLOR3.BLUE

local GuardDevelopDlg = Singleton("GuardDevelopDlg", Dialog)

function GuardDevelopDlg:init()
    self:bindListener("DevelopButton", self.onDevelopButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("RefiningButton", self.onCloseButton)  -- 离开
    self:bindListener("StrImage", self.onStrImage)
    self:bindListener("WizImage", self.onWizImage)
    self:bindListener("DexImage", self.onDexImage)
    self:bindListener("ConImage", self.onConImage)
    self:bindListener("CostImagePanel", self.onItemImage)
    self:bindListener("InfoButton", self.onInfoButton)

    self.itemName = CHS[3002787]
    self.useItemNum = self.useItemNum or 1

    -- 设置图片
    self:setImage("CostImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.itemName)))
    self:setItemImageSize("CostImage")

    -- 设置成长丹数量
    self:MSG_INVENTORY()

    -- 刷新属性
    self:hookMsg("MSG_GUARD_UPDATE_GROW_ATTRIB")

    -- 刷新道具数量
    self:hookMsg("MSG_INVENTORY")
end

function GuardDevelopDlg:onDevelopButton(sender, eventType)

    local meLevel = Me:queryBasicInt("level")
    local limitLevel = 55
    if limitLevel > meLevel then
        gf:ShowSmallTips(string.format(CHS[3002788], limitLevel))
        return
    end

    local guardAttribute = GuardMgr:getGrowAttrib(self.guardId)
    if nil == guardAttribute then
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002789])
    elseif guardAttribute["rebuild_level"] >=  GuardMgr:getMaxDevelopLevel() then
        gf:ShowSmallTips(CHS[3002790])
    else
        -- 培养
        local amount = InventoryMgr:getAmountByName(self.itemName)
        local itemPos = InventoryMgr:getItemPosByName(self.itemName)
        if amount >= self.useItemNum then
            InventoryMgr:feedGuard(self.guardId, itemPos, tostring(self.useItemNum))
        else
            gf:askUserWhetherBuyItem({[self.itemName] = self.useItemNum})
        end
    end

end

-- 培养后的信息显示
function GuardDevelopDlg:setDevelopedInfo(guardAttribute)
    self:setRuslteLabel("StrResultLabel", guardAttribute["str_add"], guardAttribute["str"], guardAttribute["str_max"])
    self:setRuslteLabel("WizResultLabel", guardAttribute["wiz_add"], guardAttribute["wiz"], guardAttribute["wiz_max"])
    self:setRuslteLabel("DexResultLabel", guardAttribute["dex_add"], guardAttribute["dex"], guardAttribute["dex_max"])
    self:setRuslteLabel("ConResultLabel", guardAttribute["con_add"], guardAttribute["con"], guardAttribute["con_max"])

    -- 按钮隐藏和显示
    self:setCtrlVisible("ConfrimButton", true)
    self:setCtrlVisible("CancelButton", true)
    self:setCtrlVisible("DevelopButton", false)
end

-- 培养前的信息
function GuardDevelopDlg:setDevelopBeforeInfo()
    -- 结果初值化置空
    self:setLabelText("StrResultLabel", "")
    self:setLabelText("WizResultLabel", "")
    self:setLabelText("DexResultLabel", "")
    self:setLabelText("ConResultLabel", "")

    --培养初值化保存取消隐藏
    self:setCtrlVisible("ConfrimButton", false)
    self:setCtrlVisible("CancelButton", false)
    self:setCtrlVisible("DevelopButton", true)
end

function GuardDevelopDlg:onConfrimButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.GUARD_SAVE_GROW, self.guardId, ATTRIBUTE_CONFIG.developSave)
    gf:ShowSmallTips(string.format(CHS[6000005], self.guardName))
end

function GuardDevelopDlg:onCancelButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.GUARD_SAVE_GROW, self.guardId, ATTRIBUTE_CONFIG.developCancel)
    gf:ShowSmallTips(string.format(CHS[6000004], self.guardName))
end

function GuardDevelopDlg:onStrImage(sender, eventType)
    gf:showTipInfo(CHS[6000000], sender)
end

function GuardDevelopDlg:onWizImage(sender, eventType)
    gf:showTipInfo(CHS[6000001], sender)
end

function GuardDevelopDlg:onDexImage(sender, eventType)
    gf:showTipInfo(CHS[6000002], sender)
end

function GuardDevelopDlg:onConImage(sender, eventType)
    gf:showTipInfo(CHS[6000003], sender)
end

-- 显示道具信息
function GuardDevelopDlg:onItemImage(sender, eventType)
    local item = self:getControl("CostImagePanel", Const.UIImage)
    local rect = self:getBoundingBoxInWorldSpace(item)
	InventoryMgr:showBasicMessageDlg(self.itemName, rect)
end

-- con     培养增加的总体质
-- str     培养增加的总力量
-- wiz     培养增加的总灵力
-- dex     培养增加的总敏捷
-- con_add 当前培养增加的体质
-- str_add 当前培养增加的力量
-- wiz_add 当前培养增加的灵力
-- dex_add 当前培养增加的敏捷
-- con_max 培养可增加的体质的最大值
-- str_max 培养可增加的力量的最大值
-- wiz_max 培养可增加的灵力的最大值
-- dex_max 培养可增加的敏捷的最大值
function GuardDevelopDlg:setGuardDevelopInfo(guardId)
    local ctrl = self:getControl("DevelopButton")
    ctrl:setTouchEnabled(true)
    gf:resetImageView(ctrl)

    if self.guardId ~= guardId  or not self.useItemNum then
        self.useItemNum = 1
    end

    -- 初值化培养属性
    self.guardId = guardId
    self.guardName = GuardMgr:getGuard(guardId):queryBasic("name")
    local guard =  GuardMgr:getGuard(guardId)

    self:initGuardInfo(guard)

    self:getControl("DevelopButton", Const.UIButton):setTouchEnabled(true)

end

function GuardDevelopDlg:setGuardShapInfo(guard)

    -- 名字
    local name = guard:queryBasic("name")
    self:setLabelText("GuardNameLabel", name, self.root)

    -- 等级
    local level = guard:queryBasic("level")
    self:setLabelText("LevelLabel", level..CHS[3002791], self.root)

    -- 相性
    local polar = guard:queryBasicInt("polar")
    self:setLabelText("PolarLabel", gf:getPolar(polar))

    -- 形象
    local icon = guard:queryBasic("icon")
    self:setPortrait("GuardIconPanel", icon, 0, nil, true)

    -- 品质
    local rank = guard:queryBasicInt("rank")
    local imagePath = GuardMgr:getGuardRankImage(rank)
    self:setImage("QualityImage", imagePath)

    -- 守护介绍
    local polar = gf:getPolar(guard:queryBasicInt("polar"))
    local rank = guard:queryBasicInt("rank")
    local guardDecribe = GuardMgr:getGuardDescByPolarAndRank(polar, rank)
    self:setLabelText("DescLabel", guardDecribe)
end

function GuardDevelopDlg:initGuardInfo(guard)
    if nil == guard then return end
    self:setGuardShapInfo(guard)

    local developPanel = self:getControl("OldGuardPanel")
    self:setDevelopInfo(developPanel, GuardMgr:getGrowAttrib(self.guardId))

    -- 设置培养进度信息
    self:setDevelopDegreeInfo(GuardMgr:getGrowAttrib(self.guardId))

    local developedPanel = self:getControl("NewGuardPanel")
    self:setDevelopInfo(developedPanel, GuardMgr:getNextLevGrowAttrib(self.guardId))
end

function GuardDevelopDlg:setDevelopDegreeInfo(developAttrib)
    if developAttrib["degree_32"] == 0 then
        self:setLabelText("ProgressLabel", "")
    else
        self:setLabelText("ProgressLabel", string.format("%0.4f%%", developAttrib["degree_32"]))
    end

    self:setProgressBar("ProgressBar", developAttrib["degree_32"] , 100)
end

function GuardDevelopDlg:onInfoButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local text = CHS[3002794]
    local dlg = DlgMgr:openDlg("FloatingFrameDlg")
    dlg:setText(text)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function GuardDevelopDlg:setDevelopInfo(panel, developAttrib)
    -- 培养等级
    local level = self:getControl("DevelopLevelLabel", Const.UILabel, panel)
    level:setString(developAttrib["rebuild_level"] ..CHS[3002791])

    local completionLabel = self:getControl("DevelopCompletionLabel", Const.UILabel, panel)

    if completionLabel then
        if developAttrib["degree_32"] == 0 then
            completionLabel:setString("")
        else
            completionLabel:setString(string.format("(+%0.4f%%)", developAttrib["degree_32"]))
        end
    end

    local addAttrib = GuardMgr:getDevelopBasciAttrib(developAttrib["rebuild_level"])

    -- 伤害培养
    local attactValueLabel = self:getControl("GuardAttributeValueLabel1", Const.UILabel, panel)
    attactValueLabel:setString(string.format("%d", math.floor(developAttrib["power"] * addAttrib["add_attack"])))
    
    -- 法伤
    local attactValueLabel2 = self:getControl("GuardAttributeValueLabel2", Const.UILabel, panel)
    attactValueLabel2:setString(math.floor(developAttrib["power"] * addAttrib["add_attack"] * 0.75))

    -- 防御培养
    local defenceValueLabel = self:getControl("GuardAttributeValueLabel3", Const.UILabel, panel)
    defenceValueLabel:setString(string.format("%d", math.floor(developAttrib["def"] * addAttrib["add_defense"])))

    if panel:getName() == "NewGuardPanel" then
        if developAttrib["rebuild_level"] > GuardMgr:getMaxDevelopLevel() then
            level:setString((GuardMgr:getMaxDevelopLevel())..CHS[3002791])
            level:setColor(COLOR3.RED)
            attactValueLabel:setString(CHS[3002795])
            attactValueLabel:setColor(COLOR3.RED)
            self:setLabelText("GuardAttributeValueLabel2", CHS[3002795], panel, COLOR3.RED)
            defenceValueLabel:setString(CHS[3002795])
            defenceValueLabel:setColor(COLOR3.RED)

            self:setCtrlVisible("DevelopButton", false)
            self:setCtrlVisible("ProcessPanel", false)
            self:setCtrlVisible("CostPanel", false)
            self:setCtrlVisible("RefiningButton", true)
            self:setCtrlVisible("MaxImage", true)
        else
            level:setColor(COLOR3.GREEN)
            attactValueLabel:setColor(COLOR3.GREEN)
            attactValueLabel2:setColor(COLOR3.GREEN)
            defenceValueLabel:setColor(COLOR3.GREEN)

            self:setCtrlVisible("DevelopButton", true)
            self:setCtrlVisible("ProcessPanel", true)
            self:setCtrlVisible("CostPanel", true)
            self:setCtrlVisible("RefiningButton", false)
            self:setCtrlVisible("MaxImage", false)
        end
    end
end

-- 刷新守护信息
function GuardDevelopDlg:MSG_GUARD_UPDATE_GROW_ATTRIB(data)
    --self:MSG_INVENTORY()
	if data["id"] ~= self.guardId then
	   return
	else
	   self:setGuardDevelopInfo(data["id"])
	end
end

-- 设置成长丹的数量
function GuardDevelopDlg:MSG_INVENTORY( )
    local amount = InventoryMgr:getAmountByName(self.itemName)

    if amount < self.useItemNum then
        self:setLabelText("OwnLabel1", amount, nil, COLOR3.RED)
    else
        if amount > 999 then
            amount = "*"
        end

        self:setLabelText("OwnLabel1", amount, nil, COLOR3.TEXT_DEFAULT)
    end

    self:updateLayout("CostImagePanel")
end

function GuardDevelopDlg:playDevelopEffect(guardIDStr)
    -- todo
end

return GuardDevelopDlg