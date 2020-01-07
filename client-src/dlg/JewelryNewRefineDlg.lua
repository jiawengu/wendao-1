-- JewelryNewRefineDlg.lua
-- Created by huangzz Apr/19/2018
-- 首饰分解界面

local JewelryNewRefineDlg = Singleton("JewelryNewRefineDlg", Dialog)

local RewardContainer = require("ctrl/RewardContainer")

-- 拥有附加属性的最低等级
local HAS_ATTACH_MIN_LEVEL = 80

function JewelryNewRefineDlg:init()
    self:bindListener("RefineButton", self.onRefineButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ItemImage", self.onShowJewelryInfo, self:getControl("NowPanel"))
    self:bindListener("JewelryUnitPanel", self.onJewelryUnitPanel)

    self:bindListener("OwnCashPanel", self.onShowFloat)
    self:bindListener("CostCashPanel", self.onShowFloat)
    self:bindListener("CashImage1", self.onShowFloat)
    self:bindListener("CashImage2", self.onShowFloat)
    self:bindListener("OwnJinghuaPanel", self.onShowFloat)
    self:bindListener("CostJinghuaPanel", self.onShowFloat)
    self:bindListener("JinghuaImage", self.onShowFloat)
    self:bindListener("JinghuaImage2", self.onShowFloat)

    self.unitPanel = self:retainCtrl("JewelryUnitPanel")
    self.selectImg = self:retainCtrl("ChosenEffectImage", self.unitPanel)

    self.selectJewelry = nil

    self:setListView()

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
end

function JewelryNewRefineDlg:setListView()
    local jewelrys = EquipmentMgr:getCanRefineJewelry()
    local cou = #jewelrys
    if cou == 0 then
        self:setCtrlVisible("NoticePanel", true, "JewelryListPanel")
        self:setCtrlVisible("JewelryListView", false, "JewelryListPanel")

        self:setComparePanel(nil, "FuturePanel")
        self:setComparePanel(nil, "NowPanel")
        self:setCtrlEnabled("RefineButton", false)
        self:setCostPanel(0)
        return
    else
        self:setCtrlVisible("NoticePanel", false, "JewelryListPanel")
        self:setCtrlVisible("JewelryListView", true, "JewelryListPanel")
        self:setCtrlEnabled("RefineButton", true)
    end

    local listView = self:getControl("JewelryListView")
    listView:removeAllItems()
    local firstCell
    for i = 1, cou do
        local cell = self.unitPanel:clone()
        cell:setTag(jewelrys[i].pos)
        self:setUnitEquipPanel(jewelrys[i], cell)
        listView:pushBackCustomItem(cell)

        if self.selectJewelry and self.selectJewelry.pos == jewelrys[i].pos then
            self:onJewelryUnitPanel(cell)
        end

        if i == 1 then
            firstCell = cell
        end
    end

    if not self.selectJewelry and firstCell then
        self:onJewelryUnitPanel(firstCell)
    end
end

function JewelryNewRefineDlg:setUnitEquipPanel(jewelry, panel)
    panel.jewelry = jewelry

    -- 是否装备中
    local no = InventoryMgr:checkSuitNo(jewelry)
    if no == 1 then
        self:setImage("TipImage", ResMgr.ui.equip_one, panel)
    elseif no == 2 then
        self:setImage("TipImage", ResMgr.ui.equip_two, panel)
    else
        self:setImagePlist("TipImage", ResMgr.ui.touming, panel)
    end

    -- icon
    self:setImage("JewelryImage", ResMgr:getItemIconPath(jewelry.icon), panel)
    self:setItemImageSize("JewelryImage", panel)

    -- name
    self:setLabelText("JewelryNameLabel", jewelry.name, panel)

    -- lv
    self:setLabelText("JewelryLevelValueLabel", jewelry.req_level, panel)


    -- 首饰类型
    local jewelryInfo = EquipmentMgr:getComposeJewelryInfoByName(jewelry.name)
    self:setLabelText("JewelryTypeLabel", jewelryInfo.kind, panel)
end

function JewelryNewRefineDlg:onJewelryUnitPanel(sender, eventType)
    local jewelry = sender.jewelry

    if not jewelry then
        return
    end

    self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)

    self.selectJewelry = jewelry

    self:setComparePanel(jewelry, "NowPanel")

    local jewelryInfo = EquipmentMgr:getComposeJewelryInfoByName(jewelry.name)
    self:setComparePanel(jewelryInfo, "FuturePanel")

    self:setCostPanel(jewelry.req_level)
end

function JewelryNewRefineDlg:setComparePanel(jewelry, panelName)
    local panel = self:getControl(panelName, Const.UIPanel, "ComparePanel")
    self:setItemPanel(jewelry, panel)
    self:setBlueAtt(jewelry, panelName)
end

-- 显示悬浮框
function JewelryNewRefineDlg:onShowFloat(sender)
    local parent = sender:getParent()
    if parent:getName() == "JinghuaPanel" then
        RewardContainer:showCommonReward(sender, {CHS[5450185], CHS[5450185]})
    else
        RewardContainer:showCommonReward(sender, {CHS[3002690], CHS[3002690]})
    end
end

function JewelryNewRefineDlg:setItemPanel(jewelry, panel)
    self:setCtrlVisible("AddImage", true, panel)
    local itemImage = self:getControl("ItemImage", nil, panel)

    if jewelry then
        local icon = InventoryMgr:getIconByName(jewelry["name"])
        local img = self:getControl("ItemImage", nil, panel)
        img:loadTexture(ResMgr:getItemIconPath(icon))
        img.jewelry = jewelry

        self:setLabelText("ItemNameLabel", jewelry["name"], panel)

        self:setCtrlVisible("NoneImage", false, panel)
        self:setCtrlVisible("ItemShapePanel", true, panel)
    else
        self:setImagePlist("AddImage", ResMgr.ui.add_symbol, panel)
        self:setLabelText("ItemNameLabel", CHS[5400016], panel)

        self:setCtrlVisible("ItemShapePanel", false, panel)

        self:setCtrlVisible("NoneImage", true, panel)
        self:setCtrlVisible("ItemShapePanel", false, panel)
    end
end

-- 显示附加属性
function JewelryNewRefineDlg:setBlueAtt(jewelry, panelName)
    local panel = self:getControl(panelName, Const.UIPanel, "ComparePanel")

    self:setLabelText("AttribLabel", "", panel)

    for i = 1, 3 do
        self:setLabelText("AttachAttribLabel" .. i, "", panel)
    end

    if not jewelry then
        return
    end

    -- 基础属性
    if jewelry.extra then
        local str = EquipmentMgr:getBaseAttStr(jewelry.extra)
        self:setLabelText("AttribLabel", str or "", panel)
    end

    -- 蓝属性
    local blueAtt = EquipmentMgr:getJewelryBule(jewelry)
    local cou = #blueAtt
    if cou > 0 then
        for i = 1, cou do
            if blueAtt[i] then
                self:setLabelText("AttachAttribLabel" .. i, blueAtt[i], panel)
            end
        end
    elseif panelName == "FuturePanel" then
        local count = math.floor((jewelry.req_level - HAS_ATTACH_MIN_LEVEL) / 10 + 1)
        for i = 1, count do
            self:setLabelText("AttachAttribLabel" .. i, CHS[5400015], panel)
        end
    end
end

-- 重铸
function JewelryNewRefineDlg:onRefineButton(sender, eventType)
    -- 若角色处于禁闭状态，给予弹出提示
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selectJewelry then
        return
    end

    -- 若当前所选首饰已不存在，给予弹出提示
    local item = InventoryMgr:getItemByPos(self.selectJewelry.pos)
    if not item then
        gf:ShowSmallTips(CHS[4200586])
        self.selectJewelry = nil
        self:setListView()
        return
    end

    -- 若该角色首饰精华不足（首饰精华消耗见数值相关），给予弹出提示
    local costEssence = EquipmentMgr:getRefineJewelryCostEssence(self.selectJewelry.req_level) or 0
    if costEssence > Me:queryBasicInt("jewelry_essence") then
        gf:ShowSmallTips(CHS[5450179])
        return
    end

    -- 若玩家在战斗中且当前选定的是穿戴中的首饰（虚影状态下的首饰算穿戴中；在另一套装备方案中但未生效则算未穿戴），则给予弹出提示
    if Me:isInCombat() and InventoryMgr:checkEquipHasUseInCombat(self.selectJewelry) then
        gf:ShowSmallTips(CHS[5450178])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onRefineButton") then
        return
    end

    -- 若角色携带金钱不足(仅可使用金钱，不可使用代金券)，详见道具[道具金钱不足通用处理详细设定(design)]，消耗金钱数量详见数值相关。
    local costMoney = EquipmentMgr:getJewelryUpgradeCost(self.selectJewelry.req_level)
    if gf:checkEnough("cash", costMoney) then
        local tip = ""
        local _, day = gf:converToLimitedTimeDay(self.selectJewelry.gift)
        if not InventoryMgr:isLimitedItem(self.selectJewelry) or day <= 59 then
            tip = CHS[5450183]
        end

        if gf:isExpensive(self.selectJewelry) then
            tip = tip .. CHS[5450182]
        end

        tip = string.format(CHS[5450181], tip)

        gf:confirm(tip, function()
            gf:CmdToServer("CMD_UPGRADE_EQUIP", {pos = self.selectJewelry.pos, type = Const.EQUIP_RECAST_HIGHER_JEWELRY, para = self.selectJewelry.name})
        end)
    end
end

-- 规则
function JewelryNewRefineDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200607], isScrollToDef = true}
    DlgMgr:openDlgEx("JewerlyRuleNewDlg", data)
end

function JewelryNewRefineDlg:onShowJewelryInfo(sender, eventType)
    if not sender.jewelry then
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showJewelryFloatDlg(sender.jewelry, rect, true)
end

-- 重铸成功
function JewelryNewRefineDlg:MSG_GENERAL_NOTIFY(data)
    if data.notify == NOTIFY.NOTIFY_HIGHER_JEWELRY_RECAST_OK then
        local id = tonumber(data.para)
        local jewelry = InventoryMgr:getItemByIdFromAll(id)
        if jewelry then
            DlgMgr:openDlgEx("JewelryShowDlg", {jewelry})

            self.selectJewelry = jewelry
            self:setListView()
        else
            self.selectJewelry = nil
            self:setListView()
        end
    end
end

-- 重铸花费
function JewelryNewRefineDlg:setCostPanel(level)
    -- 金钱消耗
    local costCash = EquipmentMgr:getJewelryUpgradeCost(level) or 0
    local moneyStr, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostCashPanel", fontColor, moneyStr, false, LOCATE_POSITION.CENTER, 21)

    local meMoneyStr, meFontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnCashPanel", meFontColor, meMoneyStr, false, LOCATE_POSITION.CENTER, 21)

    -- 精华消耗
    local costEssence = EquipmentMgr:getRefineJewelryCostEssence(level) or 0
    local str = gf:getArtFontMoneyDesc(costEssence)
    self:setNumImgForPanel("CostJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)

    str = gf:getArtFontMoneyDesc(Me:queryBasicInt("jewelry_essence"))
    self:setNumImgForPanel("OwnJinghuaPanel", ART_FONT_COLOR.NORMAL_TEXT, str, false, LOCATE_POSITION.CENTER, 21)
end

function JewelryNewRefineDlg:MSG_UPDATE()
    if self.selectJewelry then
        self:setCostPanel(self.selectJewelry.req_level)
    end
end

return JewelryNewRefineDlg
