-- EquipmentInheritDlg.lua
-- Created by songcw June/2018/10
-- 装备继承

local EquipmentInheritDlg = Singleton("EquipmentInheritDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local RewardContainer = require("ctrl/RewardContainer")

function EquipmentInheritDlg:init()
    self:bindListener("InheritButton", self.onInheritButton)
    self:bindListener("NoneEquipImage", self.onNoneEquipImage)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("EquipmentImagePanel", self.onNoneEquipImage, "RightEquipmentPanel")
    self:bindListener("EquipmentImagePanel", self.onMainEquipImage, "LeftEquipmentPanel")
    self:bindCheckBoxListener("CheckBox", self.onCoinCheckBox)

    self:bindListener("SliverCoinPanel", self.onSliverCoinImage, "HavePanel")
    self:bindListener("CashPanel", self.onCashPanel, "HavePanel")
    self:bindListener("GoldCoinPanel", self.onGoldCoinPanel, "HavePanel")

    self:onCoinCheckBox(self:getControl("CheckBox"), nil, true)

    self.mainEquip = nil
    self.oEquip = nil
    self.keyStr = nil
    self.equipAtt = {}

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPGRADE_INHERIT_PREVIEW")
end

function EquipmentInheritDlg:onGoldCoinPanel(sender, eventType)
    DlgMgr:openDlg("OnlineRechargeDlg")
end

function EquipmentInheritDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200592], two = CHS[4200593], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentInheritDlg:onCashPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)

    local rewardInfo = RewardContainer:getRewardInfo({CHS[6000080], CHS[6000080]})
    local dlg
    if rewardInfo.desc then
        dlg = DlgMgr:openDlg("BonusInfoDlg")
    else
        dlg = DlgMgr:openDlg("BonusInfo2Dlg")
    end

    dlg:setRewardInfo(rewardInfo)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function EquipmentInheritDlg:onSliverCoinImage(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3002297])
end


function EquipmentInheritDlg:onMainEquipImage(sender, eventType)
    if not self.mainEquip then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showEquipByEquipment(self.mainEquip, rect, true)
end


function EquipmentInheritDlg:onNoneEquipImage(sender, eventType)
    local equips = self:getSubmitEquipments(self.mainEquip)
    if #equips == 0 then
        gf:ShowSmallTips(CHS[4101113])
        return
    end

    local dlg = DlgMgr:openDlg("SubmitEquipDlg")
    dlg:setData(equips, "EquipmentInheritDlg", self.mainEquip.pos)
end

function EquipmentInheritDlg:onCoinCheckBox(sender, eventType, notTips)
    local panel = self:getControl("CoinPanel", nil, "CostPanel")
    self:setCtrlVisible("SliverCoinImage", sender:getSelectedState(), panel)
    self:setCtrlVisible("GoldCoinImage", not sender:getSelectedState(), panel)

    if notTips then return end
    if sender:getSelectedState() then
        gf:ShowSmallTips(CHS[4101114])
    else
        gf:ShowSmallTips(CHS[4101115])
    end
end

-- 刷新消耗、拥有的金钱、元宝等
function EquipmentInheritDlg:refreshCost()

    -- =========== 已有
    -- 金钱
    local havePanel = self:getControl("HavePanel")
    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("CashValuePanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23, havePanel)
    -- 银元宝
    local silver_coin = Me:queryBasicInt('silver_coin')
    local silverText = gf:getArtFontMoneyDesc(silver_coin)
    self:setNumImgForPanel("SilverCoinValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23, havePanel)
    -- 金元宝
    gold_coin = Me:queryBasicInt('gold_coin')
    local goldText = gf:getArtFontMoneyDesc(gold_coin)
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23, havePanel)
end

function EquipmentInheritDlg:setData(mainEquip)
    self.mainEquip = mainEquip

    -- 设置主装备
    self:setEquip(mainEquip, self:getControl("LeftEquipmentPanel"))

    self:refreshCost()
end

-- 设置装备图标
function EquipmentInheritDlg:setEquip(equip, panel)

    local namePanel = self:getControl("NamePanel", nil, panel)

    if equip == nil then
        self:setImagePlist("EquipmentImage", ResMgr.ui.touming, panel)
        self:setLabelText("NameLabel", "", namePanel)
        return
    end

    -- 装备基本信息：图标、名称、等级
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)
    self:setLabelText("NameLabel", equip.name, namePanel)

    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 属性
    self.equipAtt[panel:getName()] = {}

    -- 改造
    local rebuldLevel = equip.rebuild_level
    local degree = equip["degree_32"]
    local degreeStr = ""
    local rebuildStr = ""
    if degree and degree ~= 0 then
        local degressFloatValue = math.floor(equip["degree_32"] / 100) *100 / 1000000
        degreeStr = string.format(" (+%0.4f%%)", degressFloatValue)
        rebuildStr = string.format("%d%s", equip.rebuild_level, degreeStr)

        local value = equip.rebuild_level + degressFloatValue * 0.01
        table.insert( self.equipAtt[panel:getName()], value )
    else
        rebuildStr = string.format("%d", equip.rebuild_level)
        local value = equip.rebuild_level
        table.insert( self.equipAtt[panel:getName()], value )
    end
    self:setLabelText("OldNumLabel", rebuildStr, panel, COLOR3.TEXT_DEFAULT)

    local upgradeLevelPanel = self:getControl("UpgradeLevelPanel", nil, panel)
    self:setLabelText("NameLabel", CHS[4101116], upgradeLevelPanel)

    -- 属性1
    local attPanel1 = self:getControl("Attribute1Panel", nil, panel)
    if self:isWeapon(equip) then
        self:setLabelText("NameLabel", CHS[3002580], attPanel1)
        local value = equip.extra.phy_power_10 or 0
        self:setLabelText("OldNumLabel", value, attPanel1)
        table.insert( self.equipAtt[panel:getName()], value )
    else
        self:setLabelText("NameLabel", CHS[3002582], attPanel1)
        local value = equip.extra.def_10 or 0
        self:setLabelText("OldNumLabel", value, attPanel1)
        table.insert( self.equipAtt[panel:getName()], value )
    end

    -- 属性2
    local attPanel2 = self:getControl("Attribute2Panel", nil, panel)
    if self:isWeapon(equip) then
        self:setLabelText("NameLabel", CHS[3002581], attPanel2)
        local value = equip.extra.all_attrib_10 or 0
        self:setLabelText("OldNumLabel", value, attPanel2)
        table.insert( self.equipAtt[panel:getName()], value )
    else
        self:setLabelText("NameLabel", CHS[3002583], attPanel2)
        local value = equip.extra.max_life_10 or 0
        self:setLabelText("OldNumLabel", value, attPanel2)
        table.insert( self.equipAtt[panel:getName()], value )
    end

    -- 共鸣
    local gongmPanel = self:getControl("GongmingPanel", nil, panel)
    local gongmAttrib = EquipmentMgr:getGongmingAttrib(equip)
    self:setCtrlVisible("NameLabel", true, gongmPanel)
    self:setCtrlVisible("OldNumLabel", true, gongmPanel)
    self:setCtrlVisible("NoGongmingLabel", true, gongmPanel)
    self:setLabelText("NameLabel", "", gongmPanel)
    self:setLabelText("OldNumLabel", "", gongmPanel)
    self:setLabelText("NoGongmingLabel", "", gongmPanel)
    if not gongmAttrib or not next(gongmAttrib) then
        -- 没有共鸣属性
        self:setLabelText("NoGongmingLabel", CHS[7190139], gongmPanel)
        table.insert( self.equipAtt[panel:getName()], 0 )
    else
        -- 有共鸣属性
        self:setLabelText("NameLabel", EquipmentMgr:getAttribChsOrEng(gongmAttrib.field), gongmPanel)
        self:setLabelText("OldNumLabel", gongmAttrib.value .. EquipmentMgr:getPercentSymbolByField(gongmAttrib.field), gongmPanel)
        table.insert( self.equipAtt[panel:getName()], gongmAttrib.value )
    end

end

-- 是否是武器
function EquipmentInheritDlg:isWeapon(equip)
    if EQUIP_TYPE.WEAPON == equip.equip_type then
        return true
    else
        return false
    end
end

-- 获取可提交的副装备
function EquipmentInheritDlg:getSubmitEquipments(mEquip)
    local inventory = InventoryMgr:getAllInventory()
    local equips = {}
    for _, v in pairs(inventory) do
        local level = v.req_level
        if v.evolve_level then level = v.req_level - v.evolve_level end
        local rebuildLevel = v.rebuild_level or 0
        if mEquip.pos ~= v.pos and v.item_type == ITEM_TYPE.EQUIPMENT and level >= 70 and not InventoryMgr:isLimitedItemForever(v) and rebuildLevel >= 5  and mEquip.equip_type == v.equip_type then
            table.insert(equips, v)
        end
    end

    return equips
end

function EquipmentInheritDlg:getResultValue(key, value, vStr, idx, field)
    if not self.equipAtt[key] then return end -- 容错下
    field = field or ""
    local data = self.equipAtt[key]
    if data[idx] == value then
        return vStr .. EquipmentMgr:getPercentSymbolByField(field), COLOR3.TEXT_DEFAULT
    elseif data[idx] > value then
        return vStr .. EquipmentMgr:getPercentSymbolByField(field) .. "↓", COLOR3.RED
    else
        return vStr .. EquipmentMgr:getPercentSymbolByField(field) .. "↑", COLOR3.GREEN
    end
end

-- 设置预览
function EquipmentInheritDlg:setPreEquip(equip, panel)

-- 改造
    local rebuldLevel = equip.rebuild_level
    local degree = equip["degree_32"]
    local degreeStr = ""
    local rebuildStr = ""
    local value1 = 0
    if degree and degree ~= 0 then
        degreeStr = string.format(" (+%0.4f%%)", math.floor(equip["degree_32"] / 100) *100 / 1000000)
        rebuildStr = string.format("%d%s", equip.rebuild_level, degreeStr)
        value1 = equip.rebuild_level + math.floor(equip["degree_32"] / 100) *100 / 1000000 * 0.01
    else
        rebuildStr = string.format("%d", equip.rebuild_level)
        value1 = equip.rebuild_level
    end

    local retStr, color = self:getResultValue(panel:getName(), value1, rebuildStr, 1)
    self:setLabelText("NewNumLabel", retStr, panel, color)

    local upgradeLevelPanel = self:getControl("UpgradeLevelPanel", nil, panel)
    self:setLabelText("NewNameLabel", CHS[4101116], upgradeLevelPanel)

    self:setNumImgForPanel("EquipmentImagePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 属性1
    local attPanel1 = self:getControl("Attribute1Panel", nil, panel)
    if self:isWeapon(equip) then
        self:setLabelText("NewNameLabel", CHS[3002580], attPanel1)
        local value = equip.extra.phy_power_10 or 0
        local retStr, color = self:getResultValue(panel:getName(), value, value, 2)
        self:setLabelText("NewNumLabel", retStr, attPanel1, color)
    else
        self:setLabelText("NewNameLabel", CHS[3002582], attPanel1)
        local value = equip.extra.def_10 or 0
        local retStr, color = self:getResultValue(panel:getName(), value, value, 2)
        self:setLabelText("NewNumLabel", retStr, attPanel1, color)
    end

    -- 属性2
    local attPanel2 = self:getControl("Attribute2Panel", nil, panel)
    if self:isWeapon(equip) then
        self:setLabelText("NewNameLabel", CHS[3002581], attPanel2)
        local value = equip.extra.all_attrib_10 or 0
        local retStr, color = self:getResultValue(panel:getName(), value, value, 3)
        self:setLabelText("NewNumLabel", retStr, attPanel2, color)
    else
        self:setLabelText("NewNameLabel", CHS[3002583], attPanel2)
        local value = equip.extra.max_life_10 or 0
        local retStr, color = self:getResultValue(panel:getName(), value, value, 3)
        self:setLabelText("NewNumLabel", retStr, attPanel2, color)
    end

    -- 共鸣
    local gongmPanel = self:getControl("GongmingPanel", nil, panel)
    local gongmAttrib = EquipmentMgr:getGongmingAttrib(equip)
    self:setCtrlVisible("NewNameLabel", true, gongmPanel)
    self:setCtrlVisible("NewNumLabel", true, gongmPanel)
    self:setCtrlVisible("NoGongmingLabel_1", true, gongmPanel)
    self:setLabelText("NewNameLabel", "", gongmPanel)
    self:setLabelText("NewNumLabel", "", gongmPanel)
    self:setLabelText("NoGongmingLabel_1", "", gongmPanel)
    if not gongmAttrib or not next(gongmAttrib) then
        -- 没有共鸣属性
        self:setLabelText("NoGongmingLabel_1", CHS[7190139], gongmPanel)
    else
        -- 有共鸣属性
        self:setLabelText("NewNameLabel", EquipmentMgr:getAttribChsOrEng(gongmAttrib.field), gongmPanel)
        local value = gongmAttrib.value
        local retStr, color = self:getResultValue(panel:getName(), value, value, 4, gongmAttrib.field)
        self:setLabelText("NewNumLabel", retStr, gongmPanel)
    end

end

function EquipmentInheritDlg:onInheritButton(sender, eventType)

    if not self.mainEquip then return end

        -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 角色等级达到#R70级#n后开放改造继承功能。
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4200158])
        return
    end

    if not self.oEquip then
        gf:ShowSmallTips(CHS[4101118])
        return
    end

    local attrib = EquipmentMgr:getAttrib(self.mainEquip.pos, 1)
    local rebuildLevel = self.mainEquip.rebuild_level or 0
    if #attrib < 3 and rebuildLevel == 0 then
        gf:ShowSmallTips(CHS[4101119])
        return
    end

    local gAttrib = EquipmentMgr:getAttrib(self.mainEquip.pos, 4)
    if #gAttrib < 1 then
        gf:ShowSmallTips(CHS[4101119])
        return
    end

        -- 改造等级限制
    if rebuildLevel > 5 then
        gf:ShowSmallTips(CHS[4200529])  -- 改造等级超过5级的装备无法作为主装备进行改造继承。
        return
    end

    if Me:isInCombat() then
        if self.mainEquip.pos <= 10 or self.oEquip.pos <= 10 then
            gf:ShowSmallTips(CHS[4101120])
            return
        end
    end

        -- 安全锁判断
    if self:checkSafeLockRelease("onInheritButton") then
        return
    end

    -- 金钱不足
    local costCash = self.data.money
    if costCash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    local flag = self:isCheck("CheckBox") and 0 or 1

    -- 只使用金元宝，元宝不足需要判断
    if flag == 1 and Me:queryBasicInt('gold_coin') < self.data.coin then
                -- 总元宝不足
        gf:askUserWhetherBuyCoin()
        return
    end

    -- 元宝不足判断
    if Me:getTotalCoin() < self.data.coin then
        -- 总元宝不足
        gf:askUserWhetherBuyCoin()
        return
    end


    local tips = self:getTipsForConfirm()

    gf:confirm(tips, function ()
        -- body
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.mainEquip.pos,
            type = Const.EQUIP_UPGRADE_INHERIT,
            para = tostring(self.oEquip.pos) .. "|" .. flag,
        })

        self:onCloseButton()
    end)



end

function EquipmentInheritDlg:getTipsForConfirm()
    local flag = self:isCheck("CheckBox") and 1 or 0

    local _, mLimitDays = gf:converToLimitedTimeDay(self.data.mEquip.gift)
    local _, oLimitDays = gf:converToLimitedTimeDay(self.data.oEquip.gift)


    local _, mOldEquipLimitDays = gf:converToLimitedTimeDay(self.mainEquip.gift)
    local _, oOldEquipLimitDays = gf:converToLimitedTimeDay(self.oEquip.gift)

    local moneyStr = gf:getMoneyDesc(self.data.money)
    local costSCoin = 0
    local costGCoin = 0
    local tips = ""
    if flag == 1 then
        if Me:queryBasicInt("silver_coin") > 0 then

            mLimitDays = math.min( mLimitDays + 10, 60)
            oLimitDays = math.min( oLimitDays + 10, 60)

            costSCoin = math.min(Me:queryBasicInt("silver_coin"), self.data.coin)
            costGCoin = self.data.coin - costSCoin
            if costGCoin ~= 0 then
                tips = string.format(CHS[4101121], moneyStr, costSCoin, costGCoin)
            else
                tips = string.format(CHS[4101122], moneyStr, costSCoin)
            end


            if mLimitDays ~= mOldEquipLimitDays and oLimitDays ~= oOldEquipLimitDays then
                local str = string.format(CHS[4101123], mLimitDays, oLimitDays)
                tips = tips .. str
            elseif mLimitDays ~= mOldEquipLimitDays then
                local str = string.format(CHS[4101124], mLimitDays)
                tips = tips .. str
            elseif oLimitDays ~= oOldEquipLimitDays then
                local str = string.format(CHS[4101125], oLimitDays)
                tips = tips .. str
            end

        else
            costSCoin = 0
            costGCoin = self.data.coin
            tips = string.format(CHS[4101126], moneyStr, costGCoin)

            if mLimitDays ~= mOldEquipLimitDays then
                local str = string.format(CHS[4101127], mLimitDays)
                tips = tips .. str
            end
        end
    else
        costSCoin = 0
        costGCoin = self.data.coin
        tips = string.format(CHS[4101128], moneyStr, costGCoin)

        if mLimitDays ~= mOldEquipLimitDays then
            local str = string.format(CHS[4101129], mLimitDays)
            tips = tips .. str
        end
    end

    return tips
end

function EquipmentInheritDlg:setCheckData(keyStr)
    self.keyStr = keyStr
end

function EquipmentInheritDlg:MSG_UPDATE()
    self:refreshCost()
end


function EquipmentInheritDlg:MSG_UPGRADE_INHERIT_PREVIEW(data)
    -- 效验下服务器下发的是不是当前选择的，不是则return
    if self.keyStr ~= data.pos .. data.para then
        return
    end

    if data.flag ~= 1 then return end

    self.data = data

    self:setCtrlVisible("PlusImage", false)
    self:setCtrlVisible("NoneEquipImage", false)

    -- 消耗
    local costPanel = self:getControl("CostPanel")
    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(data.money)
    self:setNumImgForPanel("CashValuePanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 23, costPanel)
    -- 元宝
    local silverText = gf:getArtFontMoneyDesc(data.coin)
    self:setNumImgForPanel("CoinValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23, costPanel)

    -- 设置副装备
    self.oEquip = InventoryMgr:getItemByPos(tonumber(data.para))
    self:setEquip(self.oEquip, self:getControl("RightEquipmentPanel"))

    -- 设置预览主装备
    self:setPreEquip(data.mEquip, self:getControl("LeftEquipmentPanel"))

    -- 设置预览副装备
    self:setPreEquip(data.oEquip, self:getControl("RightEquipmentPanel"))
end

return EquipmentInheritDlg
