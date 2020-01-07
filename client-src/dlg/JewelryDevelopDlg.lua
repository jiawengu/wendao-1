-- JewelryDevelopDlg.lua
-- Created by
--

local JewelryDevelopDlg = Singleton("JewelryDevelopDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

--  CHS[4000090]:气血   CHS[4000110]:法力    CHS[4000032]:伤害
local MaterialAtt = {
    [EQUIP_TYPE.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP_TYPE.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP_TYPE.WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP_TYPE.WRIST] = {att =  CHS[4000032], field = "phy_power"},
}


-- 第二天装备对应的第一条装备位置
local SECOND_TO_ONE_JEWELEY = {
    [EQUIP.BACK_BALDRIC] = EQUIP.BALDRIC,
    [EQUIP.BACK_NECKLACE] = EQUIP.NECKLACE,
    [EQUIP.BACK_LEFT_WRIST] = EQUIP.LEFT_WRIST,
    [EQUIP.BACK_RIGHT_WRIST] = EQUIP.RIGHT_WRIST,
}

local COST_EXP      = 24000000
local COST_CASH     = 1000000

function JewelryDevelopDlg:init()
    self:bindListener("DevelopButton", self.onDevelopButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListViewListener("JewelryListView", self.onSelectJewelryListView)
    self:bindListener("JewelryImagePanel", self.onJewelryButton)

    self:bindListener("CostCashPanel", self.onShowMoney)
    self:bindListener("HaveCashPanel", self.onShowMoney)

    self:bindListener("CostExpPanel", self.onShowExp)
    self:bindListener("HaveExpPanel", self.onShowExp)

    self.jewelry = nil
    self.curDevelopJewelry = nil

    self:setCtrlVisible("BasicAttibutePanel", false)
    self:setCtrlVisible("AttachAttributePanel", false)
    self:setLabelText("JewelryNameLabel", "", "JewelryNamePanel", COLOR3.TEXT_DEFAULT)

    -- 左侧首饰列表
    self.unitJewelryPanel = self:retainCtrl("JewelryUnitPanel")
    self:bindTouchEndEventListener(self.unitJewelryPanel, self.onSelectJewelry)
    self.selectJewelryEffImage = self:retainCtrl("ChosenEffectImage", self.unitJewelryPanel)

    -- 初始化一下设置完成度
    self:setCompletedProgress()

    -- 初始化左侧首饰列表
    self:initJewelryListView()

    -- 设置消耗
    self:setCost()

    -- 刷新消耗
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_STRENGTHEN_JEWELRY_SUCC")
end

function JewelryDevelopDlg:showRewardDlg(info, rect)
    local rewardInfo = RewardContainer:getRewardInfo(info)
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

function JewelryDevelopDlg:onShowMoney(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showRewardDlg({CHS[6000080], CHS[6000080]}, rect)
end

function JewelryDevelopDlg:onShowExp(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    self:showRewardDlg({CHS[6000081], CHS[4200394]}, rect)
end

function JewelryDevelopDlg:onJewelryButton(sender, eventType)
    if not self.jewelry then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showJewelryFloatDlg(self.jewelry, rect, true)
end


function JewelryDevelopDlg:getJewelries()
    local jewelryRet = {}
    local inventory = InventoryMgr:getAllInventory()
    for _, v in pairs(inventory) do
        if EquipmentMgr:isJewelry(v) and v.req_level >= 120 and not InventoryMgr:isTimeLimitedItem(v) then
            table.insert(jewelryRet, v)
        end
    end

    return jewelryRet
end

function JewelryDevelopDlg:initJewelryListView()
    local jewelryListView = self:resetListView("JewelryListView")
    local jewelries = self:getJewelries()
    for _, jewelry in pairs(jewelries) do
        local panel = self.unitJewelryPanel:clone()
        self:setUnitEquipPanel(jewelry, panel)
        jewelryListView:pushBackCustomItem(panel)
    end

    if not self.jewelry and #jewelries > 0 then
        self:onSelectJewelry(jewelryListView:getItems()[1])
    end

    self:setCtrlVisible("NoticePanel", #jewelries == 0)

    if #jewelries == 0 then
        self:setCtrlEnabled("ChangeButton", false)
    end
end

function JewelryDevelopDlg:setUnitEquipPanel(equip, panel)
    panel:setTag(equip.pos)
    panel.jewelry = equip

    -- 是否装备中
    if equip.pos <= 10 then
        if Me:queryBasicInt("equip_page") == 0 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    elseif equip.pos <= 20 then
        if Me:queryBasicInt("equip_page") == 1 then
            self:setImage("TipImage", ResMgr.ui.equip_one, panel)
        else
            self:setImage("TipImage", ResMgr.ui.equip_two, panel)
        end
    else
        self:setImagePlist("TipImage", ResMgr.ui.touming, panel)
    end

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equip.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    --local color = InventoryMgr:getEquipmentNameColor(equip)
    self:setLabelText("JewelryNameLabel", equip.name, panel, COLOR3.TEXT_DEFAULT)

    -- lv
    self:setLabelText("JewelryLevelValueLabel", equip.req_level, panel)

    -- 部位
    if equip.equip_type == EQUIP.BALDRIC then
        self:setLabelText("JewelryTypeLabel", CHS[3002887], panel)
    elseif equip.equip_type == EQUIP.NECKLACE then
        self:setLabelText("JewelryTypeLabel", CHS[3002888], panel)
    elseif equip.equip_type == EQUIP.LEFT_WRIST or equip.equip_type == EQUIP.RIGHT_WRIST then
        self:setLabelText("JewelryTypeLabel", CHS[3002889], panel)
    end

    -- 冷却
    self:setCtrlVisible("CoolingTipImage", EquipmentMgr:isCoolTimed(equip), panel)

    panel:requestDoLayout()
end

-- 增加选择效果
function JewelryDevelopDlg:addSelectEff(sender)
    self.selectJewelryEffImage:removeFromParent()
    sender:addChild(self.selectJewelryEffImage)
end

-- 点击某个装备
function JewelryDevelopDlg:onSelectJewelry(sender, eventType)
    self:addSelectEff(sender)
    self.jewelry = sender.jewelry
    self:setJewelryInfo()
end

function JewelryDevelopDlg:setCompletedProgress(equip)
    if not equip then
        self:setProgressBar("ProgressBar", 0, 0)

        self:setLabelText("ComLabel", string.format("%d%%", 0), "ProgressBar", COLOR3.WHITE)
        self:setLabelText("ComLabel_1", string.format("%d%%", 0), "ProgressBar")

        self:setCtrlVisible("MaxLevelNoticePanel", false)
        return
    end

    local _, curValue, degree = EquipmentMgr:getJewelryDevelopInfo(equip)
    self:setProgressBar("ProgressBar", degree, 10000)
    self:setLabelText("ComLabel", string.format("%.02f%%", degree / 100), "ProgressBar", COLOR3.WHITE)
    self:setLabelText("ComLabel_1", string.format("%.02f%%", degree / 100), "ProgressBar")

    -- 当前首饰强化等级已达上限。
    if curValue >= Const.JEWELRY_DEVELOP_MAX then
        self:setLabelText("ComLabel", CHS[5000047], "ProgressBar", COLOR3.RED)
        self:setLabelText("ComLabel_1", "", "ProgressBar")
     --   gf:ShowSmallTips(CHS[4010204])
        return
    end
end

function JewelryDevelopDlg:setCost()
    -- 消耗的金钱
    local cashText, fontColor = gf:getArtFontMoneyDesc(COST_CASH)
    self:setNumImgForPanel("CostCashPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 19)

    -- 已有
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryInt("cash"))
    self:setNumImgForPanel("HaveCashPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 19)

    -- 消耗的经验
    local cashText, fontColor = gf:getArtFontMoneyDesc(COST_EXP)
    self:setNumImgForPanel("CostExpPanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 19)

    -- 已有经验
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt("exp"))
    self:setNumImgForPanel("HaveExpPanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 19)
end

function JewelryDevelopDlg:setJewelryInfo()
    if not self.jewelry then return end
    local devStr, devLv, devDegree = EquipmentMgr:getJewelryDevelopInfo(self.jewelry)

    if devLv >= Const.JEWELRY_DEVELOP_MAX then
        self:setCtrlVisible("DevelopButton", false)
        self:setCtrlVisible("CostInfoPanel", false)
        self:setCtrlVisible("CDNoticePanel", false)

        self:setCtrlVisible("MaxLevelNoticePanel", true)
    elseif Me:queryBasicInt("strengthen_jewelry_num") >= 1 then
        self:setCtrlVisible("DevelopButton", false)
        self:setCtrlVisible("CostInfoPanel", false)
        self:setCtrlVisible("MaxLevelNoticePanel", false)

        self:setCtrlVisible("CDNoticePanel", true)
    else
        self:setCtrlVisible("DevelopButton", true)
        self:setCtrlVisible("CostInfoPanel", true)

        self:setCtrlVisible("MaxLevelNoticePanel", false)
        self:setCtrlVisible("CDNoticePanel", false)
    end

    self:setCtrlVisible("BasicAttibutePanel", true)
    self:setCtrlVisible("AttachAttributePanel", true)

    local panel = self:getControl("JewelryAttributeInfoPanel")

    -- icon
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(self.jewelry.icon), panel)
    self:setItemImageSize("EquipmentImage", panel)

    -- name
    local color = InventoryMgr:getEquipmentNameColor(self.jewelry)
    self:setLabelText("JewelryNameLabel", self.jewelry.name, panel, COLOR3.TEXT_DEFAULT)

    local totalAtt = {}

    local blueAtt, transformData = EquipmentMgr:getJewelryBule(self.jewelry)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end
    --[[
    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(self.jewelry, self:getControl("ExChangeLabel"))
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end
    --]]

    for i = 1, 5 do
        if totalAtt[i] then
            self:setLabelText("AttachAttributeLabel" .. i, totalAtt[i].str)
        else
            self:setLabelText("AttachAttributeLabel" .. i, "")
        end
    end

    -- 转换次数
    local changeTimePanel = self:getControl("ChangeTimePanel", nil, "CostInfoPanel")
    self:setCtrlVisible("ChangeTimeLabel", true, changeTimePanel)
    self:setCtrlVisible("LimitLabel", true, changeTimePanel)
    self.jewelry.transform_num = self.jewelry.transform_num or 0
    if self.jewelry.transform_num < Const.JEWELRY_TRANSFORM_MAX_COUNT then
        self:setLabelText("ChangeTimeLabel", string.format(CHS[4010065], self.jewelry.transform_num or 0), changeTimePanel)
        self:setLabelText("LimitLabel", "", changeTimePanel)
    else
        self:setLabelText("ChangeTimeLabel", "", changeTimePanel)
        self:setLabelText("LimitLabel", CHS[4101086], changeTimePanel)
    end

    -- 解除冷却
    if self.jewelry.transform_num < Const.JEWELRY_TRANSFORM_MAX_COUNT and self.jewelry.transform_cool_ti and self.jewelry.transform_cool_ti ~= 0 and self.jewelry.transform_cool_ti >= gf:getServerTime() then
        self:setLabelText("Label1", string.format(CHS[4010066], os.date("%Y-%m-%d %H:%M", self.jewelry.transform_cool_ti)), "CDTimePanel")
    else
        self:setLabelText("Label1", "", "CDTimePanel")
    end

    self:setCtrlEnabled("ChangeButton", not EquipmentMgr:isCoolTimed(self.jewelry))

    if self.jewelry.transform_num >= Const.JEWELRY_TRANSFORM_MAX_COUNT then
        self:setCtrlEnabled("ChangeButton", false)
    end

    self:setCtrlVisible("ChangeLabel1", not EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("ChangeLabel2", not EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("CDLabel1_0", EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")
    self:setCtrlVisible("CDLabel2_0", EquipmentMgr:isCoolTimed(self.jewelry), "ChangeButton")

    -- 强化相关
    local developInfoPanel = self:getControl("BasicAttributePanel")
    local devStr, devLevel = EquipmentMgr:getJewelryDevelopInfo(self.jewelry)
    -- 属性
    local _, attValue =EquipmentMgr:getJewelryAttributeInfo(self.jewelry)

    self:setLabelText("NowLevelLabel", string.format(CHS[6000179], devLevel), developInfoPanel)
    self:setLabelText("FutureLevelLabel", string.format(CHS[6000179], devLevel + 1), developInfoPanel, COLOR3.GREEN)
    if devLevel == Const.JEWELRY_DEVELOP_MAX then
        self:setLabelText("FutureLevelLabel", CHS[5000047], developInfoPanel, COLOR3.RED)
    end

    local attType = MaterialAtt[self.jewelry.equip_type].att

    self:setLabelText("BasicAttributeLabel", attType, developInfoPanel)

    self:setLabelText("NowNumLabel", attValue, developInfoPanel)

    local preValue = attValue + EquipmentMgr:getJewelryDevelopDiff(self.jewelry.equip_type, devLevel, devLevel + 1)
    self:setLabelText("FutureNumLabel", preValue, developInfoPanel, COLOR3.GREEN)
    if devLevel == Const.JEWELRY_DEVELOP_MAX then
        self:setLabelText("FutureNumLabel", CHS[5000047], developInfoPanel, COLOR3.RED)
    end

    self:setCompletedProgress(self.jewelry)
end

function JewelryDevelopDlg:onDevelopButton(sender, eventType)
--
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:queryBasicInt("level") < 125 then
        gf:ShowSmallTips(string.format(CHS[4200493], 125)) -- [4200493] = "角色等级达到#R%d级#n后开放该功能。",
        return
    end

    -- 您本日已经进行过一次首饰强化了，请明日再来。
    if Me:queryBasicInt("strengthen_jewelry_num") >= 1 then
        gf:ShowSmallTips(CHS[4010207])
        return
    end

    -- 请先选择首饰。
    if not self.jewelry then
        gf:ShowSmallTips(CHS[4010206])
        return
    end


    -- 真身状态，才能完成仙魔的转换
    if not Me:isRealBody() then
        gf:ShowSmallTips(CHS[4010205])
        return
    end

    -- 当前首饰强化等级已达上限。
    local devStr, devLv, devDegree = EquipmentMgr:getJewelryDevelopInfo(self.jewelry)
    if devLv >= Const.JEWELRY_DEVELOP_MAX then
        gf:ShowSmallTips(CHS[4010204])
        return
    end

    local item = InventoryMgr:getItemByPos(self.jewelry.pos)
    if not item or not EquipmentMgr:isJewelry(item) then
        gf:ShowSmallTips(CHS[4200586])

        self.jewelry = nil
        -- 初始化左侧首饰列表
        self:initJewelryListView()
        return
    end


       -- 策划要求，第二套装备未生效时，也可以穿戴（第二装备对应的第一装备没有位置，也会生效！！！）
    if Me:isInCombat() and self.jewelry.pos < 41 then
        if self.jewelry.pos < 10 then
            -- 第一套肯定生效
            gf:ShowSmallTips(CHS[4010203]) -- 战斗中不可对已穿戴首饰进行此操作。
            return
        end

        -- 操作第二天装备，需要看看对应的第一套装备有没有，没有也是不可以炒作的
        local oneJewelryPos = SECOND_TO_ONE_JEWELEY[self.jewelry.pos]
        if oneJewelryPos and not InventoryMgr:getItemByPos(oneJewelryPos) then
            gf:ShowSmallTips(CHS[4010203]) -- 战斗中不可对已穿戴首饰进行此操作。
            return
        end
    end

    if Me:queryBasicInt("exp") < COST_EXP then
        gf:ShowSmallTips(CHS[4010202])
        return
    end

    -- 金钱不足
    if COST_CASH > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onDevelopButton") then
        return
    end

    local tip = string.format(CHS[4101157], self.jewelry.name)

    local _, day = gf:converToLimitedTimeDay(self.jewelry.gift)
    if day <= Const.LIMIT_TIPS_DAY then tip = tip .. CHS[4101166] end

    gf:confirm(tip, function ()
        self.curDevelopJewelry = self.jewelry
        gf:CmdToServer("CMD_UPGRADE_EQUIP", {
            pos = self.jewelry.pos,
            type = Const.EQUIP_STRENGTHEN_JEWELRY,
            para = "",
        })
    end)
end

function JewelryDevelopDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200602], isScrollToDef = true}
    DlgMgr:openDlgEx("JewerlyRuleNewDlg", data)
end

function JewelryDevelopDlg:onSelectJewelryListView(sender, eventType)
end

function JewelryDevelopDlg:MSG_UPDATE(data)
    -- 设置消耗
    self:setCost()

    if data and data.strengthen_jewelry_num then
        self:setJewelryInfo()
    end
end

function JewelryDevelopDlg:MSG_STRENGTHEN_JEWELRY_SUCC(data)
    if not self.jewelry or self.jewelry.item_unique ~= data.jewelry_id then return end
    if data.isChange == 1 then
        local newJewelry = InventoryMgr:getItemByIdFromAll(data.jewelry_id)
        DlgMgr:openDlgEx("JewelryShowDlg", {newJewelry, self.curDevelopJewelry or self.jewelry})

        self.jewelry = InventoryMgr:getItemByIdFromAll(data.jewelry_id)
        self:setJewelryInfo()
    else
        self.jewelry = InventoryMgr:getItemByIdFromAll(data.jewelry_id)
        self:setJewelryInfo()
    end

    local jewelryListView = self:getControl("JewelryListView")

    local panel = jewelryListView:getChildByTag(self.jewelry.pos)
    panel.jewelry = self.jewelry
end

return JewelryDevelopDlg
