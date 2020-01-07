-- PetInheritDlg.lua
-- Created by lixh2 Sep/21/2017
-- 宠物继承界面

local PetInheritDlg = Singleton("PetInheritDlg", Dialog)

-- 金元宝，银元宝，策划要实现单选框效果
local RadioGroup = require("ctrl/RadioGroup")

local COIN_CHECKBOS = {
    "SilverCheckBox",
    "GoldCheckBox",
}
local COIN_TYPE = {
    SILVER      = "SilverCheckBox",  -- 银元宝
    GOLD     = "GoldCheckBox",    -- 金元宝
}

local NONE_VALUE_STR = "?"

-- 宠物类型-元宝消耗权值
local PET_TYPE_TO_RATE = {
    [Const.PET_RANK_WILD] = 1,
    [Const.PET_RANK_BABY] = 1,
    [Const.PET_RANK_ELITE] = 1.5,
    [Const.PET_RANK_EPIC] = 2,
}

-- 宠物状态:参战，掠阵
local PET_STATE_TO_STR = {CHS[2000026], CHS[2000027]}

function PetInheritDlg:init()
    self:bindListener("SelectButton1", self.onPetInheritButton)
    self:bindListener("SelectButton2", self.onRuleButton)
    self:bindListener("InheritButton", self.onInheritButton)
    self:bindListener("AddPetPanel", self.onAddPetPanel)
    self:bindListener("SliverCoinPanel", self.onSilverAddButton)
    self:bindListener("GoldCoinPanel", self.onGoldCoinAddButton)
    self:bindListener("SilverCoinImage", self.onSilverAddButton)
    self:bindListener("GoldCoinImage", self.onGoldCoinAddButton)
    self.silverCheckBox = self:getControl("SilverCheckBox", Const.UICheckBox, "SliverCoinPanel")
    self.goldCheckBox = self:getControl("GoldCheckBox", Const.UICheckBox, "GoldCoinPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, COIN_CHECKBOS, self.onCoinCheckBox)
    local index = InventoryMgr.UseLimitItemDlgs[self.name] or 2
    self.radioGroup:setSetlctByName(COIN_CHECKBOS[index])

    self.inheritCost = 0

    self:onPetInheritButton()
    self:initPet()
    self:setLeftAttriPanel()
    self:setRightAttriPanel()
    self:refreshMoneyPanel()

    self:hookMsg("MSG_FINISH_PET_INHERIT")
    self:hookMsg("MSG_PREVIEW_PET_INHERIT")
end

function PetInheritDlg:initPet()
    local pet = PetMgr:getLastSelectPet()
    if pet then
        self:setMainPet(pet)
    end

    self.otherPet = nil
end

-- 设置主宠信息
function PetInheritDlg:setMainPet(pet)
    self.mainPet = pet
    self:setMainPetPortrait(pet)
end

-- 设置主宠头像
function PetInheritDlg:setMainPetPortrait(pet)
    -- 宠物形象
    local panel = self:getControl("PetShapePanel1", nil, "PetInheritPanel")
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("NameLabel", nameLevel, panel)
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, panel, true)
    PetMgr:setPetLogo(self, pet, panel)

    -- 设置类型：野生、宝宝
    self:setCtrlVisible("SuffixImage", true, panel)
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet), panel)
end

-- 设置副宠头像
function PetInheritDlg:setOtherPet(pet)
    self.otherPet = pet

    -- 宠物形象
    local panel = self:getControl("PetShapePanel2", nil, "PetInheritPanel")
    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("NameLabel", nameLevel, panel)
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, panel, true)
    PetMgr:setPetLogo(self, pet, panel)

    -- 设置类型：野生、宝宝
    self:setCtrlVisible("SuffixImage", true, panel)
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet), panel)

    -- 隐藏+号
    self:setCtrlVisible("AddImage", false, "AddPetPanel")

    self:refreshAfterAddOtherPet()
end

-- 设置完副宠后刷新其他panel
function PetInheritDlg:refreshAfterAddOtherPet()
    self:setLeftAttriPanel()
    self:setRightAttriPanel()
    self:refreshMoneyPanel()
end

-- 设置左侧属性面板
function PetInheritDlg:setLeftAttriPanel()
    if not self.mainPet then return end
    local mainPet = self.mainPet

    -- 总成长
    local totalAll = mainPet:getAllPromote()

    local levelPanelLeft = self:getControl("AttriNumPanel1", nil, "LeftAttriPanel")
    local martialPanelLeft = self:getControl("AttriNumPanel2", nil, "LeftAttriPanel")
    local flyUpPanelLeft = self:getControl("AttriNumPanel3", nil, "LeftAttriPanel")
    local allPromotePanelLeft = self:getControl("AttriNumPanel4", nil, "LeftAttriPanel")

    local left
    local right
    local color
    local buff
    if self.otherPet then
        -- 有副宠
        local otherPet = self.otherPet

        -- 等级
        left = mainPet:queryInt("level")
        right  = otherPet:queryInt("level")
        self:setLabelText("ValueLabel1", left, levelPanelLeft)
        color, buff = self:getColor(left, right)
        self:setLabelText("ValueLabel2", right .. buff, levelPanelLeft, color)

        -- 武学
        left = mainPet:queryInt("martial")
        right  = otherPet:queryInt("martial")
        self:setLabelText("ValueLabel1", left, martialPanelLeft)
        color, buff = self:getColor(left, right)
        self:setLabelText("ValueLabel2", right .. buff, martialPanelLeft, color)

        -- 飞升状态继承前后不变
        if PetMgr:isFlyPet(mainPet) then
            self:setLabelText("ValueLabel1", CHS[7002287], flyUpPanelLeft)
            self:setLabelText("ValueLabel2", CHS[7002287], flyUpPanelLeft)
        else
            self:setLabelText("ValueLabel1", CHS[7002286], flyUpPanelLeft)
            self:setLabelText("ValueLabel2", CHS[7002286], flyUpPanelLeft)
        end
    else
        self:setLabelText("ValueLabel1", mainPet:queryInt("level"), levelPanelLeft)
        self:setLabelText("ValueLabel2", NONE_VALUE_STR, levelPanelLeft)
        self:setLabelText("ValueLabel1", mainPet:queryInt("martial"), martialPanelLeft)
        self:setLabelText("ValueLabel2", NONE_VALUE_STR, martialPanelLeft)
        if PetMgr:isFlyPet(mainPet) then
           -- 已飞升
            self:setLabelText("ValueLabel1", CHS[7002287], flyUpPanelLeft)
            self:setLabelText("ValueLabel2", CHS[7002287], flyUpPanelLeft)
            self:setLabelText("ValueLabel1", totalAll, allPromotePanelLeft)
            self:setLabelText("ValueLabel2", totalAll, allPromotePanelLeft)
        else
            self:setLabelText("ValueLabel1", CHS[7002286], flyUpPanelLeft)
            self:setLabelText("ValueLabel2", CHS[7002286], flyUpPanelLeft)
            self:setLabelText("ValueLabel1", totalAll, allPromotePanelLeft)
            self:setLabelText("ValueLabel2", totalAll, allPromotePanelLeft)
        end
    end
end

-- 设置右侧属性面板
function PetInheritDlg:setRightAttriPanel()
    if not self.mainPet then return end
    local mainPet = self.mainPet

    -- 总成长
    local totalAll = mainPet:getAllPromote()
    local levelPanelRight = self:getControl("AttriNumPanel1", nil, "RightAttriPanel")
    local martialPanelRight = self:getControl("AttriNumPanel2", nil, "RightAttriPanel")
    local flyUpPanelRight = self:getControl("AttriNumPanel3", nil, "RightAttriPanel")
    local allPromotePanelRight = self:getControl("AttriNumPanel4", nil, "RightAttriPanel")

    local left
    local right
    local color
    local buff
    if self.otherPet then
        -- 有副宠
        local otherPet = self.otherPet
        local otherTotalAll = otherPet:getAllPromote()

        -- 等级
        right = mainPet:queryInt("level")
        left  = otherPet:queryInt("level")
        self:setLabelText("ValueLabel1", left, levelPanelRight)
        color, buff = self:getColor(left, right)
        self:setLabelText("ValueLabel2", right .. buff, levelPanelRight, color)

        -- 武学
        right = mainPet:queryInt("martial")
        left  = otherPet:queryInt("martial")
        self:setLabelText("ValueLabel1", left, martialPanelRight)
        color, buff = self:getColor(left, right)
        self:setLabelText("ValueLabel2", right .. buff, martialPanelRight, color)

        -- 飞升状态继承前后不变
        if PetMgr:isFlyPet(otherPet) then
            self:setLabelText("ValueLabel1", CHS[7002287], flyUpPanelRight)
            self:setLabelText("ValueLabel2", CHS[7002287], flyUpPanelRight)
        else
            self:setLabelText("ValueLabel1", CHS[7002286], flyUpPanelRight)
            self:setLabelText("ValueLabel2", CHS[7002286], flyUpPanelRight)
        end

        -- 总成长
        self:setLabelText("ValueLabel1", otherTotalAll, allPromotePanelRight)
        self:setLabelText("ValueLabel2", otherTotalAll, allPromotePanelRight)
    else
        self:setLabelText("ValueLabel1", NONE_VALUE_STR, levelPanelRight)
        self:setLabelText("ValueLabel2", mainPet:queryInt("level"), levelPanelRight)
        self:setLabelText("ValueLabel1", NONE_VALUE_STR, martialPanelRight)
        self:setLabelText("ValueLabel2", mainPet:queryInt("martial"), martialPanelRight)

        self:setLabelText("ValueLabel1", NONE_VALUE_STR, flyUpPanelRight)
        self:setLabelText("ValueLabel2", NONE_VALUE_STR, flyUpPanelRight)
        self:setLabelText("ValueLabel1", NONE_VALUE_STR, allPromotePanelRight)
        self:setLabelText("ValueLabel2", NONE_VALUE_STR, allPromotePanelRight)
    end
end

function PetInheritDlg:getColor(left, right)
    if left == right then
        return COLOR3.TEXT_DEFAULT, ""
    elseif left < right then
        return COLOR3.GREEN, "↑"
    else
        return COLOR3.RED, "↓"
    end
end

-- 计算继承花费
function PetInheritDlg:getCost()
    if not self.otherPet then
        return 0
    end

    local maxLevel = math.max(self.mainPet:queryInt('level'), self.otherPet:queryInt('level'))
    local maxTypeRate = math.max(PET_TYPE_TO_RATE[self.mainPet:queryInt('rank')], PET_TYPE_TO_RATE[self.otherPet:queryInt('rank')])
    return math.floor(math.max(0.1, 0.97 * math.pow(maxLevel / 120, 2) * 3240 + 375) * maxTypeRate) + 700
end

-- 刷新金钱相关信息
function PetInheritDlg:refreshMoneyPanel(silverCoin, goldCoin)
    if nil == silverCoin then
        silverCoin = Me:queryBasicInt('silver_coin')
    end

    if nil == goldCoin then
        goldCoin = Me:queryBasicInt('gold_coin')
    end

    local silverText, silverTextColor = gf:getArtFontMoneyDesc(silverCoin)
    self:setNumImgForPanel("SilverCoinValuePanel", silverTextColor, silverText, false, LOCATE_POSITION.MID, 23)

    local goldText, goldTextColor = gf:getArtFontMoneyDesc(goldCoin)
    self:setNumImgForPanel("GoldCoinValuePanel", goldTextColor, goldText, false, LOCATE_POSITION.MID, 23)

    self.inheritCost = self:getCost()
    local cashText, fontColor = gf:getArtFontMoneyDesc(tonumber(self.inheritCost))
    self:setNumImgForPanel("ValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
end

-- 金元宝图片
function PetInheritDlg:onGoldCoinAddButton(sender, eventType)
    DlgMgr:openDlg("OnlineRechargeDlg")
end

-- 银元宝图片
function PetInheritDlg:onSilverAddButton(sender, eventType)
    InventoryMgr:openItemRescourse(CHS[3002297])
end

-- 金银元宝单选框
function PetInheritDlg:onCoinCheckBox(sender, eventType)
    if sender:getName() == COIN_TYPE.SILVER then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
        gf:ShowSmallTips(CHS[7190042])
        self.goldCheckBox:setSelectedState(false)
        self:setCtrlVisible("SilverImage", true, "InheritButton")
        self:setCtrlVisible("GoldImage", false, "InheritButton")
    elseif sender:getName() == COIN_TYPE.GOLD then
        InventoryMgr:setLimitItemDlgs(self.name, 2)
        gf:ShowSmallTips(CHS[7190043])
        self.silverCheckBox:setSelectedState(false)
        self:setCtrlVisible("SilverImage", false, "InheritButton")
        self:setCtrlVisible("GoldImage", true, "InheritButton")
    end
end

-- 切换到：宠物继承
function PetInheritDlg:onPetInheritButton(sender, eventType)
    self:setCtrlVisible("SelectImage1", true, "SelectPanel")
    self:setCtrlVisible("SelectImage2", false, "SelectPanel")
    self:setCtrlVisible("PetInheritPanel", true)
    self:setCtrlVisible("InfoPanel", false)
end

-- 切换到：继承规则
function PetInheritDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("SelectImage1", false, "SelectPanel")
    self:setCtrlVisible("SelectImage2", true, "SelectPanel")
    self:setCtrlVisible("PetInheritPanel", false)
    self:setCtrlVisible("InfoPanel", true)
end

-- 添加副宠
function PetInheritDlg:onAddPetPanel(sender, eventType)
    if not self.mainPet then return end

    if PetMgr:getPetCount() == 1 then
        -- 未携带其他宠物
        gf:ShowSmallTips(CHS[7190063])
        return
    end

    -- 打开选择副宠界面
    local dlg = DlgMgr:openDlg("PetEvolveSubmitPetDlg")
    dlg:setSubType("inherit")
    dlg:setPetList(self.mainPet)
end

function PetInheritDlg:onInheritButton(sender, eventType)
    if GameMgr.inCombat then
        -- 判断是否出于战斗中
        gf:ShowSmallTips(CHS[7190044])
        return false
    end

    if self.mainPet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 主宠野生
        gf:ShowSmallTips(CHS[7190045])
        return false
    end

    if PetMgr:isTimeLimitedPet(self.mainPet) then
        -- 主宠限时
        gf:ShowSmallTips(CHS[7190047])
        return
    end

    if PetMgr:isLimitedForeverPet(self.mainPet) then
        -- 主宠永久限制交易
        gf:ShowSmallTips(CHS[7190049])
        return
    end

    if PetMgr:isFeedStatus(self.mainPet) then
        -- 当前主宠正处于#R元神分离饲养#n状态，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190051])
        return
    end

    if self.mainPet:queryBasicInt("lock_exp") == 1 then
        -- 当前宠物已锁定经验，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190053])
        return
    end

    if not self.otherPet then
        -- 请选择副宠
        gf:ShowSmallTips(CHS[7190062])
        return false
    end

    if self.otherPet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 副宠野生
        gf:ShowSmallTips(CHS[7190046])
        return false
    end

    if PetMgr:isTimeLimitedPet(self.otherPet) then
        -- 副宠限时
        gf:ShowSmallTips(CHS[7190048])
        return
    end

    if PetMgr:isLimitedForeverPet(self.otherPet) then
        -- 副宠永久限制交易
        gf:ShowSmallTips(CHS[7190050])
        return
    end

    if PetMgr:isFeedStatus(self.otherPet) then
        -- 当前副宠正处于#R元神分离饲养#n状态，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190052])
        return
    end

    if self.otherPet:queryBasicInt("lock_exp") == 1 then
        -- 当前宠物已锁定经验，无法进行宠物继承。
        gf:ShowSmallTips(CHS[7190054])
        return
    end

    if math.abs(self.mainPet:queryInt('level') - self.otherPet:queryInt('level')) > 15 then
        -- 主副宠差15级以上
        gf:ShowSmallTips(CHS[7190055])
        return
    end

    if PetMgr:isFlyPet(self.mainPet) ~= PetMgr:isFlyPet(self.otherPet) then
        -- 主宠，副宠飞升状态不同
        gf:ShowSmallTips(CHS[7120017])
        return
    end

    local pet_status = self.otherPet:queryInt("pet_status")
    local isRide = PetMgr:isRidePet(self.otherPet:queryBasicInt("id"))
    if pet_status == 1 or pet_status == 2 then
        -- 参战或掠阵
        gf:ShowSmallTips(string.format(CHS[7190056], PET_STATE_TO_STR[pet_status]))
        return
    elseif isRide then
        gf:ShowSmallTips(string.format(CHS[7190056], CHS[5420167]))
        return
    end

    if self:checkSafeLockRelease("onInheritButton") then
        -- 安全锁判断
        return
    end

    pet_status = self.mainPet:queryInt("pet_status")
    isRide = PetMgr:isRidePet(self.mainPet:queryBasicInt("id"))
    if (pet_status == 1 or pet_status == 2 or isRide) and self.otherPet:queryInt('level') - Me:queryInt('level') > 15 then
        -- 参战或掠阵, 继承后等于与主角差15级
        if isRide then
            gf:confirm(string.format(CHS[7190057], CHS[5420167], CHS[5420167]), function()
                self:sendMgs()
            end)
        else
            gf:confirm(string.format(CHS[7190057], PET_STATE_TO_STR[pet_status], PET_STATE_TO_STR[pet_status]), function()
                self:sendMgs()
            end)
        end
    else
        self:sendMgs()
    end
end

function PetInheritDlg:sendMgs()
    gf:CmdToServer("CMD_UPGRADE_PET", {
        type = "pet_inherit",
        no = self.mainPet:queryBasicInt("no"),
        pos = "",
        ids = "",
        other_pet = tostring(self.otherPet:queryBasicInt("no")),
        cost_type = self.goldCheckBox:getSelectedState() and "gold_coin" or "",
    })
end

function PetInheritDlg:MSG_FINISH_PET_INHERIT(data)
    self:onCloseButton()
end

function PetInheritDlg:MSG_PREVIEW_PET_INHERIT(data)
    if not self.otherPet then
        return
    end

    local mainPetAllPromote = data.liftShape1 + data.manaShape1 + data.speedShape1 + data.phyShape1 + data.magShape1
    local otherPetAllPromote = data.liftShape2 + data.manaShape2 + data.speedShape2 + data.phyShape2 + data.magShape2

    -- 刷新总成长信息
    local allPromotePanelLeft = self:getControl("AttriNumPanel4", nil, "LeftAttriPanel")
    local allPromotePanelRight = self:getControl("AttriNumPanel4", nil, "RightAttriPanel")
    local totalAll = self.mainPet:getAllPromote()
    local otherTotalAll = self.otherPet:getAllPromote()
    local color, buff

    self:setLabelText("ValueLabel1", totalAll, allPromotePanelLeft)
    color, buff = self:getColor(totalAll, mainPetAllPromote)
    self:setLabelText("ValueLabel2", mainPetAllPromote .. buff, allPromotePanelLeft, color)

    self:setLabelText("ValueLabel1", otherTotalAll, allPromotePanelRight)
    color, buff = self:getColor(otherTotalAll, otherPetAllPromote)
    self:setLabelText("ValueLabel2", otherPetAllPromote .. buff, allPromotePanelRight, color)
end

return PetInheritDlg
