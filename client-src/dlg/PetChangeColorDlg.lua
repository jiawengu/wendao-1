-- PetDressDlg.lua
-- Created by songcw Dec/05/2018
-- 宠物换色

local PetChangeColorDlg = Singleton("PetChangeColorDlg", Dialog)


-- 右侧形象偏移坐标配置表
local OFF_POS = {
-- 例如：
    [6129] = cc.p(-5 , 0),
	[6130] = cc.p(0 , 5),
	[6172] = cc.p(15 , 10),
	[6173] = cc.p(0 , -5),
	[6171] = cc.p(5 , -7),
	[6174] = cc.p(-3 , 0),
	[6281] = cc.p(3 , 5),
}

function PetChangeColorDlg:init()
    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListViewListener("ShowListView", self.onSelectShowListView)

  --  self:bindFloatPanelListener("RulePanel")

    self:setCtrlEnabled("UseButton", false)

    self.pet = DlgMgr:sendMsg("PetAttribDlg", "getCurrentPet")
    if not self.pet then self:onCloseButton() end

    self.dir = 5
    self.icon = nil

    self:setLabelText("NameLabel", self.pet:getShowName(), "NamePanel")

    self.choseImage = self:retainCtrl("UseImage", nil, "PetItemPanel")
    self.showPanel = self:retainCtrl("ShowPanel_1", nil, self:getControl("ShowListView"))

    self:refreshCommonPanel()
    self:refreshListView()

    self:hookMsg("MSG_PET_ICON_UPDATED")
    self:hookMsg("MSG_SET_OWNER")

    if DistMgr:curIsTestDist() then
        self:setImagePlist("GoldCoinImage", ResMgr.ui.small_reward_silver)
    end
end

function PetChangeColorDlg:getColorIconByPet(pet)
    if pet:queryBasicInt("dye_icon") ~= 0 then
        return pet:queryBasicInt("dye_icon")
    end

    return pet:queryBasicInt("icon")
end

-- 形象右转
function PetChangeColorDlg:onTurnRightButton()
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshCommonPanel()
end

-- 形象左转
function PetChangeColorDlg:onTurnLeftButton()
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshCommonPanel()
end

function PetChangeColorDlg:refreshCommonPanel()

    local argList = {
        panelName = "PetPanel",
        icon = self.icon or self:getColorIconByPet(self.pet),
        weapon = 0,
        root = "ShowPanel",
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = nil,
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = nil,
        partColorIndex = nil,
    }

    self:setPortraitByArgList(argList)
end

function PetChangeColorDlg:onUseButton(sender, eventType)
    -- 战斗中不可进行此操作。
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[4000223])
        return
    end

    -- 当前宠物为限时宠物，不可进行此操作。
    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[4010269])
        return
    end

    -- 当前宠物为#R野生宠物#n，不可进行此操作。
    if self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4010270])
        return
    end


    local item = self.choseImage:getParent()
    if item.data.icon == self.pet:queryBasicInt("dye_icon") then
         gf:ShowSmallTips(CHS[4010271]) -- "当前宠物形象与染色形象一致，无需染色。"
        return
    end


    if DistMgr:curIsTestDist() then
        if item.data.coin > Me:getTotalCoin() then
            gf:askUserWhetherBuyCoin()
            return
        end
    else
        if item.data.coin > Me:getGoldCoin() then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end
    end

    local data = item.data


        -- 安全锁判断
    if self:checkSafeLockRelease("onUseButton", data) then
        return
    end

    local tips = string.format(CHS[4010273], data.coin, CHS[6000041],self.pet:getShowName())

   if DistMgr:curIsTestDist() then
        tips = self:useForTestDist(data)
    end

    gf:confirm(tips, function ()
        gf:CmdToServer("CMD_UPGRADE_PET", {
            type = "pet_change_color",
            no = self.pet:queryBasicInt("no"),
            other_pet = "",
            cost_type = tostring(data.icon),
            ids = ""
        })
    end, nil, nil, nil, nil, nil, nil, "PetDressTabDlg")
end

function PetChangeColorDlg:useForTestDist(data)

    local tip1
    if Me:getSilverCoin() >= data.coin then
        tip1 = string.format(CHS[4010274], data.coin, CHS[5450206], self.pet:getShowName(), 10)
    else
        if Me:getSilverCoin() > 0 then
            tip1 = string.format(CHS[4010275], data.coin, CHS[5450206], (data.coin - Me:getSilverCoin()),self.pet:getShowName(), 10)
        else
            tip1 = string.format(CHS[4010276], data.coin, CHS[6000041],self.pet:getShowName())
        end
    end

    return tip1
end

function PetChangeColorDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function PetChangeColorDlg:onSelectShowListView(sender, eventType)
end

-- 刷新道具列表
function PetChangeColorDlg:refreshListView()
    local data = PetMgr:getChangeColorIcons(self.pet:queryBasicInt("icon"))


    local list = self:resetListView("ShowListView", MAGIN)
    local line = math.floor(#data / 2 + 0.5)

    line = math.max( 2,  line)

    local panel
    for i = 1, line do
        panel = self.showPanel:clone()
        self:setPanelData(panel, data, (i - 1) * 2 + 1, i)
        list:pushBackCustomItem(panel)
    end
end

-- 设置道具列表单行道具数据
function PetChangeColorDlg:setPanelData(panel, data, start, line)
    local item
    for i = 1, 2 do
        item = self:getControl("PetShapePanel_" .. tostring(i), nil, panel)
        local uData = data[start + i - 1]
        if uData then
            item:setName(uData.icon)
        end
        self:setItemData(item, uData, line)
    end
end

-- 设置道具列表道具数据
function PetChangeColorDlg:setItemData(item, data, line)
    if data then
        self:setImage("BKImage", ResMgr.ui.bkImage0249, item)
    else
        self:setImage("BKImage", ResMgr.ui.bkImage0250, item)
    end

    item.data = data
    local isDefSelect


    local offPos = OFF_POS[self.pet:queryBasicInt("icon")] or cc.p(0, 0)

	local pos = cc.p(0, -36)
	local destPos = cc.p(pos.x + offPos.x, pos.y + offPos.y)
	--gf:ShowSmallTips(self.pet:queryBasicInt("icon") .. "=  =" .. offPos.x .. "      " .. offPos.y)
    if data then
        local argList = {
            panelName = "PetPanel",
            icon = data.icon,
            weapon = 0,
            root = item,
            action = nil,
            clickCb = nil,
            offPos = destPos,
            orgIcon = nil,
            syncLoad = nil,
            dir = 5,
            pTag = nil,
            extend = nil,
            partIndex = nil,
            partColorIndex = nil,
        }

        self:setPortraitByArgList(argList)

        if self:getColorIconByPet(self.pet) == data.icon then
            self:onClickItemPanel(item)
            isDefSelect = line
        end
    else
   --     item:setVisible(false)
    end

    -- 绑定事件
    self:bindTouchEndEventListener(item, self.onClickItemPanel)

    if isDefSelect then
        performWithDelay(self.root, function ()
            self:setListInnerPosByIndex("ShowListView", isDefSelect)
        end, 0)
    end
end

function PetChangeColorDlg:getOtherColorInfo()
    local ret = {}
    for _, pet in pairs(PetMgr.pets) do
        if pet:queryBasicInt("dye_icon") ~= 0 then
            ret[pet:queryBasicInt("dye_icon")] = pet:queryBasicInt("no")
        end
    end

    return ret
end

function PetChangeColorDlg:onClickItemPanel(sender)
    local data = sender.data
    if not data then return end


    if self.choseImage:getParent() == sender then
    else
        -- 选中新道具(可能是空格)
        self.choseImage:removeFromParent()
        sender:addChild(self.choseImage)

        self.dir = 5

        if data then
            self:resetIcon(data.icon)
            self:refreshCommonPanel()
        end
        self:refreshItemInfo(data)

        self:setCtrlEnabled("UseButton", data.icon ~= self.pet:queryBasicInt("dye_icon"))
        if self.pet:queryBasicInt("dye_icon") == 0 and data.icon == self.pet:queryBasicInt("icon") then
            self:setCtrlEnabled("UseButton", false)
        end
    end
end

-- 刷新道具信息，主要指右侧选中按钮后的效果
function PetChangeColorDlg:refreshItemInfo(data)
    if not data then return end

    local panel = self:getControl("DownPanel")
    local cashText, fontColor = gf:getArtFontMoneyDesc(data.coin)
    self:setNumImgForPanel("GoldCoinValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID_TOP, 23, panel)


    self:setCtrlVisible("GoldCoinPanel", false, panel)
    self:setCtrlVisible("OwnLabel", false, panel)

    local colorId = self.pet:queryBasicInt("dye_icon")
    if colorId ~= 0 and colorId == data.icon then
        self:setCtrlVisible("OwnLabel", true, panel)
    else
        if colorId == 0 and self.pet:queryBasicInt("icon") == data.icon then
            self:setCtrlVisible("OwnLabel", true, panel)
        else
            self:setCtrlVisible("GoldCoinPanel", true, panel)
        end
    end
end

function PetChangeColorDlg:resetIcon(icon)
    self.icon = tonumber(icon)
end

function PetChangeColorDlg:MSG_PET_ICON_UPDATED(data)
    if data.action == "pet_dye" then
        self.pet = PetMgr:getPetById(self.pet:getId())
    end
    self:refreshListView()
end

function PetChangeColorDlg:MSG_SET_OWNER(data)
    if not self.pet then self:onCloseButton() end
    local ownerId = data.owner_id
    if ownerId < 0 then
        self:onCloseButton()
        return
    end

    local id = data.id
    if id < 0 then
        self:onCloseButton()
        return
    end

    if (0 == ownerId or ownerId ~= Me:getId()) and id == self.pet:getId() then
        self:onCloseButton()
        return
    end

end

return PetChangeColorDlg
