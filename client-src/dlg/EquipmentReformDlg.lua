-- EquipmentReformDlg.lua
-- Created by songcw July/28/2015
-- 装备重组


local EquipmentReformDlg = Singleton("EquipmentReformDlg", Dialog)

function EquipmentReformDlg:init()
    self:bindListener("ReformButton", self.onReformButton)
    self:bindListener("InfoButton", self.onInfoButton)


    self:bindListener("EquipmentImagePanel", self.onOpenSelectEquipDlg)
    local attriPanel = self:getControl("AttributePanel")
    for i = 1,3 do
        local panel = self:getControl("ItemImagePanel" .. i)
        panel:setTag(i)
        self:bindListener("ItemImagePanel" .. i, self.onOpenSelectCrystalDlg)
        self:setLabelText("AttributeLabel1", CHS[3002528], panel)
        self:setLabelText("AttributeLabel2", CHS[3002529], panel)
     --   self:setCtrlVisible("AttributeLabel2", false, panel)
        self:setCtrlVisible("FrameImage2", false, panel)
        self:setCtrlVisible("AttributeLabel" .. i, false, attriPanel)
    end
    self:setCtrlVisible("FrameImage", false, "EquipmentImagePanel")

    self:bindListener("GuideButton", self.onGuideButton)
    self:setCtrlVisible("GuideButton", EquipmentMgr:isShowGuideButton(self.name))

    EquipmentMgr:setTabList("EquipmentReformDlg")

    self.equip = nil
    self.blueAtt = {}

    local cashText, fontColor = gf:getArtFontMoneyDesc(0)
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:MSG_UPDATE()
end

function EquipmentReformDlg:onGuideButton()
    DlgMgr:openDlg("EquipRecombinationGuideDlg")
end

function EquipmentReformDlg:setDlgZero()
    local attriPanel = self:getControl("AttributePanel")
    for i = 1,3 do
        local panel = self:getControl("ItemImagePanel" .. i)

        self:setLabelText("AttributeLabel1", CHS[3002528], panel)
        self:setLabelText("AttributeLabel2", CHS[3002529], panel)
     --   self:setCtrlVisible("AttributeLabel2", false, panel)
        self:setCtrlVisible("FrameImage", true, panel)
		self:setCtrlVisible("FrameImage2", false, panel)
        local imgCtrl = self:getControl("ItemImage", nil, panel)
        imgCtrl:ignoreContentAdaptWithSize(true)
        imgCtrl:loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)
        self:getControl("LevelPanel", nil, panel):removeAllChildren()

        self:setCtrlVisible("AttributeLabel" .. i, false, attriPanel)
    end
    local onePanel = self:getControl("OnePanel")
    self:getControl("EquipmentImage", nil, onePanel):loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)

    self.equip = nil
    self.blueAtt = {}
end

function EquipmentReformDlg:setEquipInfo(equipInfo)
    self.equip = equipInfo
    self.blueAtt = {}
    local equipPanel = self:getControl("OnePanel")
    self:setCtrlVisible("EquipmentImage_1", false)
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(equipInfo.icon), equipPanel)
    self:setItemImageSize("EquipmentImage", equipPanel)
    self:setLabelText("EquipmentNameLabel", equipInfo.name, equipPanel)
    self:setCtrlVisible("EquipmentNameLabel", true, equipPanel)
    self:setCtrlVisible("FrameImage", true, "EquipmentImagePanel")
    self:setCtrlVisible("NoEquipmentLabel", false, equipPanel)
    equipPanel:requestDoLayout()

    local attriPanel = self:getControl("AttributePanel")
    for i = 1,3 do
        local panel = self:getControl("ItemImagePanel" .. i)

        self:setLabelText("AttributeLabel1", CHS[3002528], panel)
        self:setLabelText("AttributeLabel2", CHS[3002529], panel)
      --  self:setCtrlVisible("AttributeLabel2", false, panel)
        self:setCtrlVisible("FrameImage", true, panel)
        self:setCtrlVisible("FrameImage2", false, panel)
        local imgCtrl = self:getControl("ItemImage", nil, panel)
        imgCtrl:ignoreContentAdaptWithSize(true)
        imgCtrl:loadTexture(ResMgr.ui.add_symbol, ccui.TextureResType.plistType)
        self:getControl("LevelPanel", nil, panel):removeAllChildren()

        self:setCtrlVisible("AttributeLabel" .. i, false, attriPanel)
    end

    local costCash = self:getCostCash(equipInfo.req_level)
    local cashText, fontColor = gf:getArtFontMoneyDesc(costCash)
    self:setNumImgForPanel("CostMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
end

function EquipmentReformDlg:getCostCash(equipLevel)
    if equipLevel < 70 then
        return 0
    end

    return equipLevel * 1000 + 5000
end

function EquipmentReformDlg:setCrystalInfo(crystalInfo)
    self.blueAtt[crystalInfo.index] = crystalInfo
    local panel = self:getControl("ItemImagePanel" .. crystalInfo.index)
    self:setImage("ItemImage", ResMgr:getItemIconPath(crystalInfo.icon), panel)
    self:setItemImageSize("ItemImage", panel)
    self:setLabelText("AttributeLabel1", crystalInfo.strAtt, panel)
    self:setLabelText("AttributeLabel2", crystalInfo.strValue, panel)
    self:setCtrlVisible("AttributeLabel2", true, panel)
    self:setCtrlVisible("FrameImage", false, panel)
    self:setCtrlVisible("FrameImage2", true, panel)

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.DEFAULT, self.equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 25, panel)
    self:setAttLabel()
end

function EquipmentReformDlg:onOpenSelectEquipDlg(sender, eventType)
    local dlg = DlgMgr:openDlg("EquipmentSelectDlg")
    if self.equip then
        dlg:onChooseLevel(nil, nil, self.equip.req_level)
    else
        dlg:onChooseLevel(nil, nil, math.floor(Me:queryInt("level") / 10) * 10)
    end
end

function EquipmentReformDlg:onOpenSelectCrystalDlg(sender, eventType)
    if not self.equip then
        gf:ShowSmallTips(CHS[3002530])
        return
    end
    local dlg = DlgMgr:openDlg("EquipmentSelectCrystalDlg")
    dlg:setCrystalInfo(self.equip, sender:getTag(), self.blueAtt)
end

function EquipmentReformDlg:setAttLabel()
    local att = {}
    for i = 1, 3 do
        if self.blueAtt[i] then
            table.insert(att, self.blueAtt[i])
        end
    end

    local panel = self:getControl("AttributePanel")
    for i = 1, 3 do
        if i <= #att then
            self:setLabelText("AttributeLabel" .. i, att[i].strAtt .. " " .. att[i].strValue, panel)
            self:setCtrlVisible("AttributeLabel" .. i, true, panel)
        else
            self:setCtrlVisible("AttributeLabel" .. i, false, panel)
        end
    end
end

function EquipmentReformDlg:MSG_UPDATE(data)
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("OwnMoneyPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
end

function EquipmentReformDlg:onReformButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 是否选择装备
    if not self.equip then
        gf:ShowSmallTips(CHS[3002530])
        return
    end

    -- 包裹
    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[3002532])
        return
    end

    -- 是否3颗黑水晶
    local att = {}
    local posStr = ""
    for i = 1, 3 do
        if self.blueAtt[i] then
            table.insert(att, self.blueAtt[i])
        end
    end
    if #att == 3 then
        posStr = att[1].pos
        if att[2] then posStr = posStr .. "|" .. att[2].pos end

        if att[3] then posStr = posStr .. "|" .. att[3].pos end
    else
        gf:ShowSmallTips(CHS[3002533])
        return
    end

    -- 金钱
    local costCash = self:getCostCash(self.equip.req_level)
    if costCash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    local haveGift = 0
    for i = 1,3 do
        local item = InventoryMgr:getItemByPos(att[i].pos)
        if InventoryMgr:isLimitedItemForever(item) then
            haveGift = haveGift + 1
        end
    end

    if haveGift ~= 0 then
        gf:confirm(string.format(CHS[3002534], haveGift * 10), function()
            EquipmentMgr:equipReform(self.equip.icon, posStr)
        end)
    else
        EquipmentMgr:equipReform(self.equip.icon, posStr)
    end
end

function EquipmentReformDlg:onInfoButton(sender, eventType)
    local data = {one = CHS[4200597], isScrollToDef = true}
    DlgMgr:openDlgEx("EquipmentRuleNewDlg", data)
end

function EquipmentReformDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_REFORM_OK == data.notify  then
        self:setDlgZero()
        DlgMgr:sendMsg("EquipmentChildDlg", "setEquipReformListView", tonumber(data.para))
    end
end

function EquipmentReformDlg:youMustGiveMeOneNotify(param)
    if "undifinedEquip" == param then
        local att = {}
        local posStr = ""
        for i = 1, #self.blueAtt do
            if self.blueAtt[i] then
                table.insert(att, self.blueAtt[i])
            end
        end

        local haveGift = 0
        for i = 1, #self.blueAtt do
            local item = InventoryMgr:getItemByPos(att[i].pos)
            if InventoryMgr:isLimitedItemForever(item) then
                haveGift = haveGift + 1
            end
        end

        if 0 ~= haveGift then
            GuideMgr:youCanDoIt(self.name, param)
        else
            GuideMgr:youCanDoIt(self.name, "")
        end
    else
        GuideMgr:youCanDoIt(self.name, param)
    end
end

return EquipmentReformDlg
