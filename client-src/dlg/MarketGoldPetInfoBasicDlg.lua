-- MarketGoldPetInfoBasicDlg.lua
-- Created by
--

local MarketGoldPetInfoBasicDlg = Singleton("MarketGoldPetInfoBasicDlg", Dialog)

function MarketGoldPetInfoBasicDlg:init(pet)
    self:bindListener("SlipButton", self.onSlipButton)
   -- self:bindListViewListener("ListView", self.onSelectListView)

        -- 设置宠物形象的
    -- 名字等级
    self:setLabelText("ValueLabel", pet:queryBasic("raw_name"), "NamePanel")

    -- 设置形象  getPetIcon
    self:setPortrait("PetPanel", self:getPetIcon(pet), 0, nil, true, nil, nil, cc.p(0, -50))

    -- 宠物logo
    PetMgr:setPetLogo(self, pet)

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryInt("icon")), "PortraitPanel")
    self:setItemImageSize("GuardImage", "PortraitPanel")

    -- 姓名
    self:setLabelText("NameLabel", pet:queryBasic("raw_name"), "PetBasicInfoPanel")

    -- 交易
    local strLimitedTime = gf:converToLimitedTimeDay(pet:query("gift"))
    if not strLimitedTime or strLimitedTime == "" then
        self:setLabelText("ValueLabel", CHS[4200228], "ExChangePanel")
    else
        self:setLabelText("ValueLabel", strLimitedTime, "ExChangePanel")
    end

    -- 武学
    self:setLabelText("ValueLabel", pet:queryInt("martial"), "TaoLevelPanel")

        -- 等级
    local levelPanel = self:getControl("LevelPanel", nil, "PetBasicInfoPanel")
    self:setLabelText("ValueLabel", pet:queryInt("level"), levelPanel)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    -- 基本信息
    PetMgr:setBasicInfoForCard(pet, self, nil, true)

    -- 设置亲密
    self:setLabelText("ValueLabel", CHS[4300225], "IntimacyPanel")

    self.isInitListView = true

    local scrollview = self:getControl("ListView")
    scrollview:addScrollViewEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
end

function MarketGoldPetInfoBasicDlg:getPetIcon(pet)
    if pet:queryBasicInt("dye_icon") ~= 0 then
        return pet:queryBasicInt("dye_icon")
    end

    return pet:queryBasicInt("icon")
end

-- 更新向下提示
function MarketGoldPetInfoBasicDlg:updateDownArrow(sender, eventType)

    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)

        if not self.isInitListView then
            self:setCtrlVisible("SlipButton", persent < 93)-- 留一点空余部分
        end

        self.isInitListView = false
    end
end

function MarketGoldPetInfoBasicDlg:onSlipButton(sender, eventType)
end

function MarketGoldPetInfoBasicDlg:onSelectListView(sender, eventType)
end

return MarketGoldPetInfoBasicDlg
