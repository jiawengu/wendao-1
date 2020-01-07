-- JuBaoPetOperateDlg.lua
-- Created by songcw Jan/04/2017
-- 聚宝斋宠物查看界面

local JuBaoViewPetDlg = Singleton("JuBaoViewPetDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 宠物属性、成长、技能checkBox
local DISPLAY_CHECKBOX = {
    "PetBasicInfoCheckBox",
    "PetAttribInfoCheckBox",
    "PetSkillInfoCheckBox",
}

-- 宠物属性、成长、技能checkBox 对应显示的panel
local CHECKBOX_PANEL = {
    ["PetBasicInfoCheckBox"] = "PetBasicInfoPanel",
    ["PetAttribInfoCheckBox"] = "PetAttribInfoPanel",
    ["PetSkillInfoCheckBox"] = "PetSkillInfoPanel",
}

function JuBaoViewPetDlg:init()
    self:bindListener("BuyButton", self.onBuyButton, "CommonSellPanel")
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")
    self:bindListener("VendueButton", self.onBuyButton, "VendueSellPanel")
    self:bindListener("VendueButton", self.onBuyButton, "VenduePublicPanel")

    self:bindListener("NoteButton", self.onNoteVendueButton, "VendueSellPanel")
    self:bindListener("NoteButton", self.onNoteVendueButton, "VenduePublicPanel")

    -- 初始化3个ScrollView
    for _, panelName in pairs(CHECKBOX_PANEL) do
        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local container = self:getControl("InfoPanel", nil, scollCtrl)
        scollCtrl:setInnerContainerSize(container:getContentSize())

        container:requestDoLayout()
        scollCtrl:setInnerContainerSize(container:getContentSize())
        scollCtrl:requestDoLayout()
    end

    -- 单选框初始化
    self:initCheckBox()

end


-- 单选框初始化
function JuBaoViewPetDlg:initCheckBox()
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onPetInfoCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])
end

-- 点击宠物显示信息的checkBox
function JuBaoViewPetDlg:onPetInfoCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)

        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end

function JuBaoViewPetDlg:setPet(pet, data)

    self.goods_gid = data.goods_gid

    TradingMgr:setPriceInfo(self)

    -- 设置宠物形象的
    self:setShapeInfo(pet)

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryInt("icon")), "PortraitPanel")
    self:setItemImageSize("GuardImage", "PortraitPanel")

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, pet:queryInt("level"), false, LOCATE_POSITION.LEFT_TOP, 21, "PortraitPanel")

    -- 姓名
    self:setLabelText("NameLabel", pet:queryBasic("name"), "PetBasicInfoPanel")

    -- 交易
    local strLimitedTime = gf:converToLimitedTimeDay(pet:query("gift"))
    if not strLimitedTime or strLimitedTime == "" then
        self:setLabelText("ExChangeLabel", CHS[4200239] .. CHS[4200228], "PetBasicInfoPanel")
    else
        self:setLabelText("ExChangeLabel", CHS[4200239] .. strLimitedTime, "PetBasicInfoPanel")
    end

    -- 武学
    self:setLabelText("TaoLabel", CHS[4200230] .. pet:queryInt("martial"))

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- 基本信息
    PetMgr:setBasicInfoForCard(pet, self, true)

    -- 宠物资质
    PetMgr:setAttribInfoForCard(pet, self, true)

    -- 宠物技能
    PetMgr:setSkillInfoForCard(pet, self, true)

    PetMgr:setIntimacyForCard(self, "isJubao", pet)
end

-- 设置宠物形象的
function JuBaoViewPetDlg:setShapeInfo(pet)
    -- 名字等级
    self:setLabelText("NameLabel_1", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")
    self:setLabelText("NameLabel_2", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")

    -- 设置形象
    local icon = pet:queryBasicInt("dye_icon") ~= 0 and pet:queryBasicInt("dye_icon") or pet:queryBasicInt("icon")
    self:setPortrait("UserPanel", icon, 0, nil, true, nil, nil, cc.p(0, -50))

    -- 宠物logo
    PetMgr:setPetLogo(self, pet)
end


function JuBaoViewPetDlg:onNoteVendueButton(sender, eventType)
    TradingMgr:showVendueTipsInfo(sender)
end

function JuBaoViewPetDlg:onNoteButton(sender, eventType)
    gf:showTipInfo(CHS[4100945], sender)
end

function JuBaoViewPetDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end

    TradingMgr:tryBuyItem(self.goods_gid, self.name)
--[[
    local data = TradingMgr:getTradGoodsData(self.goods_gid, "info")
    if data.state == TRADING_STATE.SHOW then
        local tips = CHS[4000400] .. "\n" .. CHS[4101052]
        gf:confirmEx(tips, CHS[4101053], function ()
            TradingMgr:modifyCollectGoods(self.goods_gid, 1)
            TradingMgr:askAutoLoginToken(self.name, self.goods_gid)
        end, CHS[4101054])
        return
    end

    local str = CHS[4200205]
    if TradingMgr:modifyCollectGoods(self.goods_gid, 1) then
        str = CHS[4300216] .. str
    end
    gf:confirm(str,function ()
        TradingMgr:askAutoLoginToken(self.name, self.goods_gid)
    end)
    --]]
end

function JuBaoViewPetDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

return JuBaoViewPetDlg
