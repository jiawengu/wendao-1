-- JuBaoUserViewPetDlg.lua
-- Created by songcw Dec/7/2016
-- 聚宝斋宠物信息界面

local JuBaoUserViewPetDlg = Singleton("JuBaoUserViewPetDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local DataObject = require("core/DataObject")

-- 携带、仓库checkBox
local COME_FROM_CHECKBOX = {
   "CatchButton",
   "PetHouseButton",
   "StorageButton",
}

-- 宠物属性、成长、技能checkBox
local DISPLAY_CHECKBOX = {
    "PetBasicInfoCheckBox",
    "PetAttribInfoCheckBox",
    "PetSkillInfoCheckBox",
}

-- 携带、仓库checkBox对应显示的listview
local COME_FROM_DISPLAY = {
    ["CatchButton"] = "PetTakeListView",
    ["PetHouseButton"] = "PetHouseStoreListView",
    ["StorageButton"] = "PetStoreListView",
}

-- 宠物属性、成长、技能checkBox 对应显示的panel
local CHECKBOX_PANEL = {
    ["PetBasicInfoCheckBox"] = "PetBasicInfoPanel",
    ["PetAttribInfoCheckBox"] = "PetAttribInfoPanel",
    ["PetSkillInfoCheckBox"] = "PetSkillInfoPanel",
}

function JuBaoUserViewPetDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")

    self:setCtrlEnabled("CatchButton", false)
    self:setCtrlEnabled("PetHouseButton", false)
    self:setCtrlEnabled("StorageButton", false)

    -- 克隆项
    self:initRetainPanels()

    -- 初始化3个ScrollView
    for _, panelName in pairs(CHECKBOX_PANEL) do
        local scollCtrl = self:getControl("ScrollView", nil, panelName)
        local container = self:getControl("InfoPanel", nil, scollCtrl)
        scollCtrl:setInnerContainerSize(container:getContentSize())
    end

    -- 单选框初始化
    self:initCheckBox()

    -- 获取gid
    self.goods_gid = DlgMgr:sendMsg("JuBaoUserViewTabDlg", "getGid")

    -- 从管理器中取数据设置
    self:setDataFormMgr()

    -- 价格信息
    TradingMgr:setPriceInfo(self)

    self:hookMsg("MSG_TRADING_SNAPSHOT")
end

-- 设置数据
function JuBaoUserViewPetDlg:setDataFormMgr()
    -- 设置数据
    if self.goods_gid then
        local bagData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_BAG)
        if bagData then
            local retPets = {}
            for i, petData in pairs(bagData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retPets, objcet)
            end
            self:setTakingPets(retPets)
            -- 有数据打开界面默认选择携带
            self:onComeFromCheckBox(self:getControl(COME_FROM_CHECKBOX[1]))
        else
            TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_BAG)
        end

        local storeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_STORE)
        if storeData then
            local retPets = {}
            for i, petData in pairs(storeData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retPets, objcet)
            end
            self:setStorePets(retPets)
        else
            TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_STORE)
        end

        local houseData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE)
        if houseData then
            local retPets = {}
            for i, petData in pairs(houseData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retPets, objcet)
            end
            self:setHouseStorePets(retPets)
        else
            TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE)
        end
    end
end

-- 点击向下按钮
function JuBaoUserViewPetDlg:onDownTipsPanel(sender, eventType)
    local scroll = self:getControl("ScrollView", nil, sender:getParent())
    local listInnerContent = scroll:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local listViewSize = scroll:getContentSize()

    -- 计算滚动的百分比
    local totalHeight = innerSize.height - listViewSize.height
    local innerPosY = listInnerContent:getPositionY()
    if innerPosY < -230 then
        listInnerContent:setPositionY(innerPosY + 230)
    else
        self:removeMagic(sender, ResMgr:getMagicDownIcon())
        sender:setVisible(false)
        listInnerContent:setPositionY(0)
    end
end

-- 更新向下提示
function JuBaoUserViewPetDlg:updateDownArrow(sender, eventType)
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

        if persent < 90 then
            self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        else
            self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        end
    end
end

-- 增加向下光效
function JuBaoUserViewPetDlg:addMagicAndSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

-- 删除向下光效
function JuBaoUserViewPetDlg:removeMagicAndNoSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

-- 单选框初始化
function JuBaoUserViewPetDlg:initCheckBox()
    -- 携带、仓库
    self.comeFromRGroup = RadioGroup.new()
    self.comeFromRGroup:setItemsByButton(self, COME_FROM_CHECKBOX, self.onComeFromCheckBox)
   -- self.comeFromRGroup:setSetlctByName(COME_FROM_CHECKBOX[1])
    self:onComeFromCheckBox(self:getControl(COME_FROM_CHECKBOX[1]))

    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, DISPLAY_CHECKBOX, self.onPetInfoCheckBox)
    self.radioCheckBox:setSetlctByName(DISPLAY_CHECKBOX[1])
end

-- 初始化克隆
function JuBaoUserViewPetDlg:initRetainPanels()
    -- 克隆

    self.oneRowPanel = self:toCloneCtrl("OneRowPanel")


    self.chosenImage = self:toCloneCtrl("ChosenImage", self.oneRowPanel)
end

-- 清理资源
function JuBaoUserViewPetDlg:cleanup()
    self:releaseCloneCtrl("chosenImage")
    self:releaseCloneCtrl("oneRowPanel")
end

function JuBaoUserViewPetDlg:setGid(gid)
    self.goods_gid = gid

    DlgMgr:sendMsg("JuBaoUserViewTabDlg", "setGid", gid)
end

-- 设置宠物
function JuBaoUserViewPetDlg:setPets(pets, gid, snapshot_type)
    if self.goods_gid ~= gid then return end

    local retPets = {}
    for i, petData in pairs(pets) do
        local objcet = DataObject.new()
        objcet:absorbBasicFields(petData)
        table.insert(retPets, objcet)
    end

    if snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_PET_BAG then
        self:setTakingPets(retPets)
    elseif snapshot_type == TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE then
        self:setHouseStorePets(retPets)
    else
        self:setStorePets(retPets)
    end
end

-- 设置携带宠物
function JuBaoUserViewPetDlg:setStorePets(pets)
    local listView = self:getControl("PetStoreListView")
    if not next(pets) then return end
    self:setCtrlEnabled("StorageButton", true)

    self:setPetsList(listView, pets)
end

-- 设置宠物小屋宠物
function JuBaoUserViewPetDlg:setHouseStorePets(pets)
    local listView = self:getControl("PetHouseStoreListView")
    if not next(pets) then return end
    self:setCtrlEnabled("PetHouseButton", true)

    self:setPetsList(listView, pets)
end

-- 设置携带宠物
function JuBaoUserViewPetDlg:setTakingPets(pets)
    local listView = self:getControl("PetTakeListView")
    if not next(pets) then return end

    self:setCtrlEnabled("CatchButton", true)
    self:setPetsList(listView, pets)
end

-- 设置宠物listview
function JuBaoUserViewPetDlg:setPetsList(list, pets)
    local count = #pets
    local rowCount = math.ceil(count / 2)
    for i = 1, rowCount do
        local parentPanel = self.oneRowPanel:clone()
        local leftPanel = self:getControl("PetInfoPanel_1", nil, parentPanel)
        self:setUnitPetCell(pets[i * 2 - 1], leftPanel)
        local rightPanel = self:getControl("PetInfoPanel_2", nil, parentPanel)
        self:setUnitPetCell(pets[i * 2], rightPanel)
        list:pushBackCustomItem(parentPanel)
    end
end

-- 设置单个宠物列表
function JuBaoUserViewPetDlg:setUnitPetCell(pet, panel)
    if not pet then
        panel:setVisible(false)
        return
    end

    -- 头像
    self:setImage("GoodsImage", ResMgr:getSmallPortrait(pet:queryBasicInt("icon")), panel)
    self:setItemImageSize("GoodsImage", panel)
    -- 相性
    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, panel)

    -- 名字
    self:setLabelText("NameLabel", pet:queryBasic("name"), panel)

    -- 类型
    self:setLabelText("TypeLabel", string.format("(%s)", gf:getPetRankDesc(pet) or ""), panel)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP,21, panel)

    local pet_status = pet:queryInt("stamp_type")
    -- pet_status 和游戏中正常的不一样，仅此特殊
    --[[
    #define PET_STAMP_NONE              0       // 宠物在休息
    #define PET_STAMP_COMBAT            1       // 宠物在参战
    #define PET_STAMP_SUPPLY            2       // 宠物在掠阵
    #define PET_STAMP_SUPPLY_AWARD      3       // 宠物在掠阵共通
    #define PET_STAMP_MOUNT             4       // 宠物在骑乘
    #define PET_STAMP_MOUNT_AWARD       5       // 宠物在骑乘共通
    --]]
    self:setCtrlVisible("StatusImage", true, panel)
    if pet_status == 1 then
        -- 参战
        self:setImage("StatusImage", ResMgr.ui.canzhan_flag_new, panel)

    elseif pet_status == 2 then
        -- 掠阵
        self:setImage("StatusImage", ResMgr.ui.luezhen_flag_new, panel)
    elseif pet_status == 3 or pet_status == 5 then
        self:setImage("StatusImage", ResMgr.ui.gongtong_flag_new, panel)
    elseif pet_status == 4 then-- 骑乘状态
        self:setImage("StatusImage", ResMgr.ui.ride_flag_new, panel)
    else
        self:setCtrlVisible("StatusImage", false, panel)
    end

    panel.pet = pet

    -- 事件监听
    self:bindTouchEndEventListener(panel, self.onSelectPet)
end

-- 点击某个宠物
function JuBaoUserViewPetDlg:onSelectPet(sender, eventType)
    self.pet = sender.pet
    self:addSelectPetEff(sender)

    self:setPetInfo(self.pet)
end

-- 设置宠物
function JuBaoUserViewPetDlg:setPetInfo(pet)
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
end

-- 设置宠物形象的
function JuBaoUserViewPetDlg:setShapeInfo(pet)
    -- 名字等级
    self:setLabelText("NameLabel_1", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")
    self:setLabelText("NameLabel_2", string.format(CHS[4000391], pet:queryBasic("name"), pet:queryInt("level")), "NamePanel")

    -- 设置形象
    local icon = pet:queryBasicInt("dye_icon") ~= 0 and pet:queryBasicInt("dye_icon") or pet:queryBasicInt("icon")
    self:setPortrait("UserPanel", icon, 0, nil, true, nil, nil, cc.p(0, -50))

    -- 宠物logo
    PetMgr:setPetLogo(self, pet)
end

-- 增加点击宠物的选中光效
function JuBaoUserViewPetDlg:addSelectPetEff(sender)
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

-- 点击宠物显示信息的checkBox
function JuBaoUserViewPetDlg:onPetInfoCheckBox(sender, eventType)
    for _, panelName in pairs(CHECKBOX_PANEL) do
        self:setCtrlVisible(panelName, false)

        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
    self:setCtrlVisible(CHECKBOX_PANEL[sender:getName()], true)
end

-- 点击携带、仓库chebox
function JuBaoUserViewPetDlg:onComeFromCheckBox(sender, eventType)
    for _, panelName in pairs(COME_FROM_DISPLAY) do
        self:setCtrlVisible(panelName, false)
    end

    self:setCtrlVisible(COME_FROM_DISPLAY[sender:getName()], true)

    local listView = self:getControl(COME_FROM_DISPLAY[sender:getName()])
    local item = listView:getItem(0)
    if item then
        local panel = self:getControl("PetInfoPanel_1", nil, item)
        self:onSelectPet(panel)
    end
end

function JuBaoUserViewPetDlg:onNoteButton(sender, eventType)
    gf:showTipInfo(CHS[4100945], sender)
end

function JuBaoUserViewPetDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoUserViewPetDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

-- 设置技能名片
function JuBaoUserViewPetDlg:setSkillCard(pet, skillName, sender, dlgType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
    dlg:setSKillByName(skillName , rect, true)
end

function JuBaoUserViewPetDlg:MSG_TRADING_SNAPSHOT(data)
    if not self.goods_gid then return end
    if data.goods_gid ~= self.goods_gid then return end

    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_PET_BAG then
        local bagData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_BAG)
        local retPets = {}
        for i, petData in pairs(bagData) do
            local objcet = DataObject.new()
            objcet:absorbBasicFields(petData)
            table.insert(retPets, objcet)
        end
        self:setTakingPets(retPets)

        -- 收到数据，默认选择携带
        if retPets and next(retPets) then
            self:onComeFromCheckBox(self:getControl(COME_FROM_CHECKBOX[1]))
        end
    end

    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_PET_STORE then
        local storeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_PET_STORE)
        if storeData then
            local retPets = {}
            for i, petData in pairs(storeData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retPets, objcet)
            end

            self:setStorePets(retPets)
        end
    end

    if data.snapshot_type == TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE then
        local storeData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.TRAD_SNAPSHOT_HOUSE_PET_STORE)
        if storeData then
            local retPets = {}
            for i, petData in pairs(storeData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retPets, objcet)
            end

            self:setHouseStorePets(retPets)
        end
    end
end

return JuBaoUserViewPetDlg
