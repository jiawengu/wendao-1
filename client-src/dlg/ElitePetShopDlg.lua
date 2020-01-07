-- ElitePetShopDlg.lua
-- Created by songcw July/27/2015
-- 变异宠物商店

local ElitePetShopDlg = Singleton("ElitePetShopDlg", Dialog)

-- 变异宠物列表信息
local VariationPetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

-- 神兽宠物列表信息
local EpicPetList = require(ResMgr:getCfgPath('EpicPetList.lua'))

local LIST_MAX_COUNT = 3

function ElitePetShopDlg:init(type)
    self:bindListener("BuyButton", self.onBuyButton, "OperatePanel")
    self:bindListener("BuyButton", self.onSubmitButton, "SubmissionPanel")
 --   self:bindListener("ShapeButton", self.onShapeButton)

    -- 是否使用服务器价格
    self.serverPrice = nil

    -- 宠物Panel克隆
    self.petUnitPanel = self:getControl("ZodiacPanel", Const.UIPanel)
    self.petUnitPanel:retain()
    self.petUnitPanel:removeFromParent()

    -- 宠物选中光效克隆
    self.petSelectEff = self:getControl("BChosenEffectImage", Const.UIPanel, self.petUnitPanel)
    self.petSelectEff:retain()
    self.petSelectEff:removeFromParent()
    self.petSelectEff:setVisible(true)

    self.dlgType = type
    local petList
    local cashName
    if self.dlgType == 2 then
        petList = EpicPetList
        cashName = CHS[7190029] -- 召唤令·上古神兽
        self:setLabelText("Label", CHS[7190035], "ShapeButton")
        self:setLabelText("Label", CHS[7190035], "ShapeButton")
        self:setLabelText("TitleLabel1", CHS[7190081], "TitlePanel")
        self:setLabelText("TitleLabel2", CHS[7190081], "TitlePanel")
    elseif self.dlgType == 3 then
        petList = EpicPetList
        self:setLabelText("Label", CHS[7190035], "ShapeButton")
        self:setLabelText("Label", CHS[7190035], "ShapeButton")
        self:setLabelText("TitleLabel1", CHS[7190081], "TitlePanel")
        self:setLabelText("TitleLabel2", CHS[7190081], "TitlePanel")
    else
        petList = VariationPetList
        cashName = CHS[4000268] -- 召唤令·十二生肖
        self:setLabelText("Label", CHS[7190034], "ShapeButton")
        self:setLabelText("Label", CHS[7190034], "ShapeButton")
        self:setLabelText("TitleLabel1", CHS[7190082], "TitlePanel")
        self:setLabelText("TitleLabel2", CHS[7190082], "TitlePanel")
    end

    -- 宠物列表排序
    self.petListorder = {}
    for i, pet in pairs(petList) do
        table.insert(self.petListorder, pet)
    end
    table.sort(self.petListorder, function(l, r) return l.order < r.order end)

    if cashName then
        local cashText, fontColor = gf:getArtFontMoneyDesc(InventoryMgr:getAmountByName(cashName))
        self:setNumImgForPanel("OwnAmountPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 25)
    end

    self:setCtrlVisible("SubmissionPanel", 3 == self.dlgType)
    self:setCtrlVisible("OperatePanel", 3 ~= self.dlgType)

    self:hookMsg("MSG_OPEN_ELITE_PET_SHOP", ElitePetShopDlg)
    self:hookMsg("MSG_EXCHANGE_EPIC_PET_SHOP")
end

function ElitePetShopDlg:cleanup()
    if self.petSelectEff then
        self.petSelectEff:release()
        self.petSelectEff = nil
    end

    if self.petUnitPanel then
        self.petUnitPanel:release()
        self.petUnitPanel = nil
    end

    self.openSelectParam = nil

    if 3 == self.dlgType then
        gf:CmdToServer("CMD_EXCHANGE_EPIC_PET_EXIT")
    end
end

function ElitePetShopDlg:getPetSelectImage()
    self.petSelectEff:removeFromParent()
    return self.petSelectEff
end

-- 设置宠物列表new   格式如 VariationPetList.lua
function ElitePetShopDlg:initLeftPetList()
    -- list控件设置
    local petListView = self:resetListView("PetTypeListView", 4)
    local selectName = self.petListorder[1].name
    if self.openSelectParam then
        selectName = self.openSelectParam[1]
    end

    for i = 1, #self.petListorder do
        local panel = self.petUnitPanel:clone()
        panel.petName = self.petListorder[i].name
        panel:setTag(i)
        self:setImage("PetImage", ResMgr:getSmallPortrait(self.petListorder[i].icon), panel)
        self:setItemImageSize("PetImage", panel)
        self:setLabelText("PetNameLabel", self.petListorder[i].name, panel)
        self:setCtrlVisible("PriceLabel", self.dlgType ~= 3, panel)
        self:setCtrlVisible("PriceImage", self.dlgType ~= 3, panel)
        self:setLabelText("PriceLabel", self.petListorder[i].price, panel)
        if self.dlgType == 2 then
            self:setImage("PriceImage", ResMgr.ui.zhaohuanling_shenshou, panel)
        else
            self:setImage("PriceImage", ResMgr.ui.zhaohuanling_bianyi, panel)
        end

        petListView:pushBackCustomItem(panel)

        self:bindTouchEndEventListener(panel, self.onSetPetAttrib)

        if selectName == self.petListorder[i].name then
            self:onSetPetAttrib(panel)
        end
    end

    if self.dlgType == 2 then
        self:setImage("HaveCashImage_1", ResMgr.ui.zhaohuanling_shenshou, "OperatePanel")
    else
        self:setImage("HaveCashImage_1", ResMgr.ui.zhaohuanling_bianyi, "OperatePanel")
    end
end

-- 设置宠物列表   格式如 VariationPetList.lua
function ElitePetShopDlg:setPetListFromSer(data)
    self.serverPrice = data.info
    self:setPriceBySer(data.info)
end

-- 服务器发的数据必须要按生肖顺序
function ElitePetShopDlg:setPriceBySer(info)
    local petListView = self:getControl("PetTypeListView")
    local items = petListView:getItems()
    for i,panel in pairs(items) do
        self:setLabelText("PriceLabel", info[i].price, panel)
    end
end

function ElitePetShopDlg:onSetPetAttrib(sender, eventType)
    if not sender then
        local listView = self:getControl("PageListView")
        local panel = listView:getItem(0)
        sender = self:getControl("Panel1")
    end

    local tag = sender:getTag()
    local petInfo = self.petListorder[tag]
    self.selectPet = petInfo
    self:setPetAttribInfo(petInfo, tag)

    sender:addChild(self:getPetSelectImage())
    sender:requestDoLayout()
end

function ElitePetShopDlg:setPetAttribInfo(petInfo, tag)
    local add = 40

    local panel = self:getControl("PetShapePanel")

    self:setPortrait("PetIconPanel", petInfo.icon, 0, panel, true, nil, nil, cc.p(-5, -36))

    self:setLabelText("PetNameLabel", petInfo.name, "PetNamePanel_0")

    self:setLabelText("PetPolarLabel", petInfo.polar, panel)

    -- 血量成长
    local life = petInfo.life + add + Formula:getElitePetBasicAddByValue(petInfo.life)
    self:setLabelText("LifeValueLabel", life)

    -- 法力成长
    local mana = petInfo.mana + add + Formula:getElitePetBasicAddByValue(petInfo.mana)
    self:setLabelText("ManaValueLabel", mana)

    -- 速度成长
    local speed = petInfo.speed + add + Formula:getElitePetBasicAddByValue(petInfo.speed)
    self:setLabelText("SpeedValueLabel", speed)

    -- 物攻成长
    local phy_attack = petInfo.phy_attack + add + Formula:getElitePetBasicAddByValue(petInfo.phy_attack)
    self:setLabelText("PhyPowerValueLabel", phy_attack)

    -- 法攻成长
    local mag_attack = petInfo.mag_attack + add + Formula:getElitePetBasicAddByValue(petInfo.mag_attack)
    self:setLabelText("MagPowerValueLabel", mag_attack)

    -- 总成长
    self:setLabelText("TotalEffectValueLabel", life + mana + speed + phy_attack + mag_attack)

    -- 价格
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.DEFAULT, petInfo.price, false, LOCATE_POSITION.CENTER, 23, self:getControl("OwnPanel"))

    self:setLabelText("LevelLabel", CHS[3002398] .. petInfo.level_req)

    -- 天生技能
    for i = 1, 3 do
        self:setImage("SkillImage_" .. i, SkillMgr:getSkillIconFilebyName(petInfo.skills[i]))
        local panel = self:getControl("SkillPanel_" .. i)
        self:setCtrlVisible("ChosenEffectImage", false, panel)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.skillFloatDlg)
    end
end

function ElitePetShopDlg:skillFloatDlg(sender, eventType)
    for i = 1, 3 do
        local panel = self:getControl("SkillPanel_" .. i)
        self:setCtrlVisible("ChosenEffectImage", false, panel)
    end
    self:setCtrlVisible("ChosenEffectImage", true, sender)

    local skillIndex = sender:getTag()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    SkillMgr:showSkillDescDlg(self.selectPet.skills[skillIndex], 0, true, rect)
end

function ElitePetShopDlg:doSubmit()
    if not self.selectPet then
        gf:ShowSmallTips(CHS[2100228])
        return
    end

    gf:CmdToServer("CMD_EXCHANGE_EPIC_PET_SUBMIT_DLG", { target_name = self.selectPet.name })
end

function ElitePetShopDlg:onBuyButton(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local pet = {type = self.dlgType, name = self.selectPet.name}
    gf:CmdToServer("CMD_BUY_FROM_ELITE_PET_SHOP", pet)
end

function ElitePetShopDlg:onSubmitButton()
    if not self:checkSafeLockRelease(doSubmit) then
        self:doSubmit()
    end
end

function ElitePetShopDlg:onShapeButton(sender, eventType)
    local ctrl = self:getControl("ChoseMenuPanel_0", nil, sender)
    ctrl:setVisible(ctrl:isVisible() == false)
end

function ElitePetShopDlg:onSelectPetListView(sender, eventType)
end

-- 打开界面需要某些参数需要重载这个函数
function ElitePetShopDlg:onDlgOpened(param)
    self.openSelectParam = param
end

function ElitePetShopDlg:MSG_OPEN_ELITE_PET_SHOP()
    self:initLeftPetList()
end

function ElitePetShopDlg:MSG_EXCHANGE_EPIC_PET_SHOP()
    self:initLeftPetList()
end

return ElitePetShopDlg
