-- KidCultureDlg.lua
-- Created by songcw Apir/19/2019
-- 娃娃玩具界面

local KidCultureDlg = Singleton("KidCultureDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")



-- 页面标签页
local CHECK_BOX = {"AttributeCheckBox", "HouseworkPanelCheckBox"}

-- 标题
local TITLE_MAP = {
    ["AttributeCheckBox"] = CHS[4200744],
    ["HouseworkPanelCheckBox"] = CHS[4200745],
}

-- panel
local PANEL_MAP = {
    ["AttributeCheckBox"] = {"XiulianAttributePanel", "XiulianPanel"},
    ["HouseworkPanelCheckBox"] = {"KidPanel"},
}


local JOY_RIGHT_MAP = {
    "TotalAttributePanel", "ItemAttributePanel", "ChoicePanel"
}

local TOTAL_PANEL_MAP = {
    "XiulianAttributePanel", "XiulianPanel", "KidPanel", "TotalAttributePanel", "ItemAttributePanel", "ChoicePanel"
}

local BASIC_GROWTH = {
    LIFE = 0.67,    MANA = 0.32,    SPEED = 0.47,   PHY = 0.47,     MAG = 0.69
}

local ATTRIBUTE_PANEL_MAP = {
    "PhysicsPanel", "ManaPanel", "SpeedPanel", "BloodPanel", "MagicPanel"
}

local JOY_TYPE = {
    [CHS[4200746]]         = 1,    -- 全部
    [CHS[4200747]]          = 2,    -- 竹马
    [CHS[4200748]]          = 3,    -- 毽子
    [CHS[4200749]]          = 4,    -- 蹴球
    [CHS[4200750]]          = 5,    -- 弹弓
    [CHS[4200751]]          = 6,    -- 陀螺
    [CHS[4200752]]          = 7,    -- 风筝
}

local ATTRIBUTE_MAP = {
    MAG = CHS[4200753],
    PHY = CHS[4200754],
    SPEED = CHS[4200755],
    LIFE = CHS[4200756],
    MANA = CHS[4200753],
    [CHS[4200735]] = CHS[4200756],
    [CHS[4200736]] = CHS[4200757],
    [CHS[4200737]] = CHS[4200755],
    [CHS[4200738]] = CHS[4200758],
    [CHS[4200739]] = CHS[4200759],
    [CHS[4200740]] = CHS[4200753],
    [CHS[4200747]] = CHS[4200756],
    [CHS[4200748]] = CHS[4200757],
    [CHS[4200749]] = CHS[4200755],
    [CHS[4200750]] = CHS[4200758],
    [CHS[4200751]] = CHS[4200759],
    [CHS[4200752]] = CHS[4200753],
}

local FIELD_MAP = {
    [CHS[4200735]] = "max_life",
    [CHS[4200736]] = "def",
    [CHS[4200737]] = "speed",
    [CHS[4200738]] = "phy_power",
    [CHS[4200739]] = "mag_power",
    [CHS[4200740]] = "max_mana",
}

local QUALITY_COLOR = {
    [CHS[5450431]] = 1,     [CHS[5450434]] = 2,     [CHS[7002102]] = 3,
}

function KidCultureDlg:init(data)
    for i = 1, 3 do
        self:bindListener("IncreaseButton", self.onIncreaseButton, "EquipIconPanel" .. i)
        self:bindListener("EquipIconPanel" .. i, self.onSelectEquipPanel)
    end

    for i = 1, 4 do
        self:bindListener("SelectIconPanel" .. i, self.onSelectToyPanel)
    end

    for i = 1, 3 do
        self:bindListener("IconPanel" .. i, self.onCanjuan, "XiulianPanel")
    end

    self:bindListener("AllStonePanel", self.onSelectToyType)
    self:bindListener("ZhumaPanel", self.onSelectToyType)
    self:bindListener("JianziPanel", self.onSelectToyType)
    self:bindListener("CuqiuPanel", self.onSelectToyType)
    self:bindListener("DangongPanel", self.onSelectToyType)
    self:bindListener("TuoluoPanel", self.onSelectToyType)
    self:bindListener("FengzhenPanel", self.onSelectToyType)

    self:bindListener("TipsButton", self.onTipsButton, "TotalAttributePanel")
    self:bindListener("DiscardButton", self.onDiscardButton, "ItemAttributePanel")
    self:bindListener("SupplementButton", self.onSupplementButton)
    self:bindListener("DiscardButton", self.onChoiceDiscardButton, "ChoicePanel")
    self:bindListener("ScreenButton", self.onScreenButton)
    self:bindListener("XiulianButton", self.onXiulianButton)
    self:bindListener("TipsButton", self.onXiulianTipsButton, "XiulianAttributePanel")
    self:bindListener("TipsButton", self.onStageTipsButton, "StagePanel")

    self:bindListener("QualificationsTipsPanel", function ()
        self:setCtrlVisible("QualificationsTipsPanel", false)
    end)

    self:bindListener("XiulianTipsPanel", function ()
        self:setCtrlVisible("XiulianTipsPanel", false)
    end)

    self:bindListener("ToysScreenPanel", function ()
        self:setCtrlVisible("ToysScreenPanel", false)
    end)

    self:bindListener("ToysTipsPanel", function ()
        self:setCtrlVisible("ToysTipsPanel", false)
    end)

    self:bindFloatPanelListener("XiulianTipsPanel")
    self:bindFloatPanelListener("ToysScreenPanel")
    self:bindFloatPanelListener("ToysTipsPanel")
    self:bindFloatPanelListener("QualificationsTipsPanel")

    for _, panelName in pairs(ATTRIBUTE_PANEL_MAP) do
        local panel = self:getControl(panelName, nil, "XiulianAttributePanel")
        self:setCtrlVisible("SelectionImage", false, panel)
        self:bindListener("ZizhiButton", self.onZizhiButton, panel)
    end

    self.data = data
    self.selectToy = nil
    self.selectEquiToy = nil

    -- 复选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECK_BOX, self.onCheckBox)
    self.radioGroup:selectRadio(1) -- 默认选择第一项
    self.selectAttributeData = nil

    self.equipSelectToyImage = self:retainCtrl("ChosenImage", "EquipIconPanel1")
    self.toSelectToyImage = self:retainCtrl("SelectionImage", "SelectIconPanel1")
    self.toyRowPanel = self:retainCtrl("RowPanel")

  --  EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)

    self:hookMsg("MSG_CHILD_CULTIVATE_INFO")
end

function KidCultureDlg:onOpenDlgRequestData()
    gf:CmdToServer("CMD_CHILD_REQUEST_CULTIVATE_INFO", {child_id = self.data.id})
end

function KidCultureDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(TOTAL_PANEL_MAP) do
        self:setCtrlVisible(panelName, false)
    end

    for _, panelName in pairs(PANEL_MAP[sender:getName()]) do
        self:setCtrlVisible(panelName, true)
    end


    for _, panelName in pairs(ATTRIBUTE_PANEL_MAP) do
        local panel = self:getControl(panelName, nil, "XiulianAttributePanel")
        self:setCtrlVisible("SelectionImage", false, panel)
    end

    self.selectAttributeData = nil



    for _, checkName in pairs(CHECK_BOX) do
        local panel = self:getControl(checkName)
        local isChosen = sender:getName() == checkName
        -- 标签页
        self:setCtrlVisible("ChosenLabel_1", isChosen, panel)
        self:setCtrlVisible("ChosenLabel_2", isChosen, panel)
        self:setCtrlVisible("UnChosenLabel_1", not isChosen, panel)
        self:setCtrlVisible("UnChosenLabel_2", not isChosen, panel)
    end

    self:setLabelText("TitleLabel", TITLE_MAP[sender:getName()])

    self:setDisplayByType(sender:getName())

    if sender:getName() == "HouseworkPanelCheckBox" then
        -- 点击修炼，默认选择属性
        for _, panelName in pairs(JOY_RIGHT_MAP) do
            self:setCtrlVisible(panelName, panelName == "TotalAttributePanel")
            self.equipSelectToyImage:removeFromParent()
        end

        self:onSelectToyType(self:getControl("AllStonePanel"))
    end
end


function KidCultureDlg:setDisplayByType(type)

    if type == "AttributeCheckBox" then
        self:setXiulianData()
    elseif type == "HouseworkPanelCheckBox" then
        self:setToyData()
    end

end

function KidCultureDlg:setToyData()
    local panel = self:getControl("KidPanel")

    -- 名字
    local namePanel = self:getControl("NamePanel", nil, panel)
    self:setLabelText("NameLabel", self.data.name, namePanel)

    -- 形象
    HomeChildMgr:setPortrait(self.data.id, self:getControl("KidIconPanel", nil, panel), self)

    self:setToyListView()

    -- 属性
    self:setToyAttrib()

    -- 已装备的玩家
    self:updateEquipToys()
end

function KidCultureDlg:updateEquipToys()
    local equipToys = self.data.toys
    for i = 1, 3 do
        local panel = self:getControl("EquipIconPanel" .. i)
        panel.data = equipToys[i]
        if equipToys[i] then
            local image = self:setImage("ItemImage", ResMgr:getIconPathByName(equipToys[i].toy_name), panel)
            self:setImageSize("ItemImage", {width = 64,height = 64}, panel)
            self:setCtrlVisible("IncreaseButton", false, panel)

            if equipToys[i].naijiu > 0 then
                gf:resetImageView(image)
            else
                gf:grayImageView(image)
            end

        else
            self:setImagePlist("ItemImage", ResMgr.ui.pet_skill_grid, panel)
            self:setImageSize("ItemImage", {width = 74,height = 74}, panel)
            self:setCtrlVisible("IncreaseButton", true, panel)


        end

        if self.equipSelectToyImage:getParent() == panel and not self:getCtrlVisible("XiulianPanel") then
            self.equipSelectToyImage:removeFromParent()
            self:onSelectEquipPanel(panel)

        end
    end
end

function KidCultureDlg:setToyAttrib()
    local kid = HomeChildMgr:getKidByCid(self.data.id)
    local maxLife = kid:queryInt("max_life")
    local maxMana = kid:queryInt("max_mana")
    local phy = kid:queryInt("phy_power")
    local mag = kid:queryInt("mag_power")
    local speed = kid:queryInt("speed")
    local def = kid:queryInt("def")

    local function setAttrib(value, buffValue, panelName)
        local panel = self:getControl(panelName, nil, "TotalAttributePanel")
        self:setLabelText("InitialNumLabel", value - buffValue, panel)
        self:setLabelText("ChangelNumLabel", value, panel)

        self:setCtrlVisible("PromoteImage", buffValue ~= 0, panel)
        self:setCtrlVisible("ChangelNumLabel", buffValue ~= 0, panel)
    end

    setAttrib(maxLife, self.data.toy_buff_life, "BloodPanel")
    setAttrib(maxMana, self.data.toy_buff_mana, "ManaPanel")
    setAttrib(phy, self.data.toy_buff_phy, "PhysicsPanel")
    setAttrib(mag, self.data.toy_buff_mag, "MagicPanel")
    setAttrib(speed, self.data.toy_buff_speed, "SpeedPanel")
    setAttrib(def, self.data.toy_buff_def, "DefensePanel")
end

function KidCultureDlg:getToysByType(toyType)
    local items = InventoryMgr:getItemByClass(ITEM_CLASS.JOY)
    local ret = {}
    for _, item in pairs(items) do
        local info = gf:deepCopy(item)
        info.colorOrder = QUALITY_COLOR[info.color]

        if string.match( info.name, CHS[4200735] ) then
            info.itemOrder = 1
            info.showName = CHS[4200735]
        elseif string.match( info.name, CHS[4200736] ) then
            info.itemOrder = 2
            info.showName = CHS[4200736]
        elseif string.match( info.name, CHS[4200737] ) then
            info.itemOrder = 3
            info.showName = CHS[4200737]
        elseif string.match( info.name, CHS[4200738] ) then
            info.itemOrder = 4
            info.showName = CHS[4200738]
        elseif string.match( info.name, CHS[4200739] ) then
            info.itemOrder = 5
            info.showName = CHS[4200739]
        elseif string.match( info.name, CHS[4200740] ) then
            info.itemOrder = 6
            info.showName = CHS[4200740]
        end

        if toyType == CHS[4200746] or not toyType then
            table.insert( ret, info )
        elseif toyType == CHS[4200747] and info.itemOrder == 1 then
            table.insert( ret, info )
        elseif toyType == CHS[4200748] and info.itemOrder == 2 then
            table.insert( ret, info )
        elseif toyType == CHS[4200749] and info.itemOrder == 3 then
            table.insert( ret, info )
        elseif toyType == CHS[4200750] and info.itemOrder == 4 then
            table.insert( ret, info )
        elseif toyType == CHS[4200751] and info.itemOrder == 5 then
            table.insert( ret, info )
        elseif toyType == CHS[4200752] and info.itemOrder == 6 then
            table.insert( ret, info )
        end
    end

    table.sort( ret, function(l, r)
        if l.colorOrder > r.colorOrder then return true end
        if l.colorOrder < r.colorOrder then return false end
        if l.itemOrder < r.itemOrder then return true end
        if l.itemOrder > r.itemOrder then return false end
    end )

    return ret
--[[
    =>item
{["alias"] = "",["amount"] = 1,["attrib"] = table[3],["color"] = CHS[5450430],["combined"] = 1,["deadline"] = 0,["extra"] = table[1],["extra_desc"] = "",["gift"] = 0,["icon"] = 2126,["iid_str"] = "",["item_type"] = 28,["item_unique"] = 21036,["limit_use_time"] = 0,["locked"] = 0,["max_req_level"] = 0,["name"] = "竹马（绿色）",["party/contrib"] = 0,["pos"] = 41,["reputation"] = 0,["req_level"] = 40,["source"] = "",["type"] = 8,["value"] = 10000}
=>item
{["alias"] = "",["amount"] = 2,["attrib"] = table[3],["color"] = CHS[7002102],["combined"] = 1,["deadline"] = 0,["extra"] = table[1],["extra_desc"] = "",["gift"] = 0,["icon"] = 2126,["iid_str"] = "",["item_type"] = 28,["item_unique"] = 21038,["limit_use_time"] = 0,["locked"] = 0,["max_req_level"] = 0,["name"] = "竹马（金色）",["party/contrib"] = 0,["pos"] = 42,["reputation"] = 0,["req_level"] = 40,["source"] = "",["type"] = 8,["value"] = 90000}
=>item
{["alias"] = "",["amount"] = 1,["attrib"] = table[3],["color"] = CHS[5450434],["combined"] = 1,["deadline"] = 0,["extra"] = table[1],["extra_desc"] = "",["gift"] = 0,["icon"] = 2126,["iid_str"] = "",["item_type"] = 28,["item_unique"] = 21039,["limit_use_time"] = 0,["locked"] = 0,["max_req_level"] = 0,["name"] = "竹马（紫色）",["party/contrib"] = 0,["pos"] = 43,["reputation"] = 0,["req_level"] = 40,["source"] = "",["type"] = 8,["value"] = 30000}
=>
]]
end

function KidCultureDlg:setUnitToyGrid(data, panel)
    panel.data = data
    if data then
        local img = self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), panel)

            --self:setImagePlist("ItemImage", ResMgr.ui.pet_skill_grid, panel)
            self:setImageSize("ItemImage", {width = 64,height = 64}, panel)

        if data.amount > 1 then
            self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        else
            self:removeNumImgForPanel(panel, LOCATE_POSITION.RIGHT_BOTTOM)
        end

        if data and InventoryMgr:isTimeLimitedItem(data) then
            InventoryMgr:removeLogoBinding(img)
            InventoryMgr:addLogoTimeLimit(img)
        elseif data and InventoryMgr:isLimitedItem(data) then
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:addLogoBinding(img)
        else
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:removeLogoBinding(img)
        end
    else
        local img = self:setImagePlist("ItemImage", ResMgr.ui.touming, panel)
        self:setImagePlist("ItemImage", ResMgr.ui.pet_skill_grid, panel)
        self:setImageSize("ItemImage", {width = 74,height = 74}, panel)
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:removeLogoBinding(img)
    end
end

function KidCultureDlg:setToyListView(toyType)
    local list = self:resetListView("JoyListView")
    self.selectToy = nil
    self.toSelectToyImage:removeFromParent()

    local items = self:getToysByType(toyType)

    if #items == 0 then
        self:setCtrlVisible("TipsPanel", true, "ChoicePanel")
        self:setSelectToyInfo()
        return
    end

    local count = math.ceil( #items / 4 )
    count = math.max( 3, count )
    local idx = 0

    for i = 1, count do
        local panel = self.toyRowPanel:clone()

        for j = 1, 4 do
            idx = idx + 1
            self:setUnitToyGrid(items[idx], self:getControl("SelectIconPanel" .. j, nil, panel))
        end

        list:pushBackCustomItem(panel)

        if not self.selectToy and i == 1 then
            self:onSelectToyPanel(self:getControl("SelectIconPanel1", nil, panel))
        end
    end
    self:setCtrlVisible("TipsPanel", false, "ChoicePanel")

end

function KidCultureDlg:setXiulianData()
    local panel = self:getControl("XiulianPanel")

    -- 修炼阶段
    local xlStagePanel = self:getControl("StagePanel", nil, panel)
    if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
        self:setLabelText("InforLabel", CHS[4200781])

        -- 按钮名称
        self:setLabelText("Label_1", CHS[4200783], "XiulianButton")
        self:setLabelText("Label_2", CHS[4200783], "XiulianButton")
    else
        self:setLabelText("InforLabel", CHS[4200782])

                -- 按钮名称
        self:setLabelText("Label_1", CHS[4200784], "XiulianButton")
        self:setLabelText("Label_2", CHS[4200784], "XiulianButton")
    end




    -- 名字
    local namePanel = self:getControl("NamePanel", nil, panel)
    self:setLabelText("NameLabel", self.data.name, namePanel)

    -- 形象
    HomeChildMgr:setPortrait(self.data.id, self:getControl("KidIconPanel", nil, panel), self)

    -- 道法、心法卷轴
    local iconPanel1 = self:getControl("IconPanel1", nil, panel)
    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[4101495]), iconPanel1)
    local iconPanel2 = self:getControl("IconPanel2", nil, panel)
    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[4101496]), iconPanel2)


    local tipsPanel = self:getControl("TipsPanel", nil, panel)
    if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
        self:setLabelText("TipsLabel", CHS[4200785], iconPanel1)
        self:setLabelText("TipsLabel", CHS[4200786], iconPanel2)
        self:setLabelText("NumLabel", self.data.daofa .. "/10", iconPanel1)
        self:setLabelText("NumLabel", self.data.xinfa .. "/10", iconPanel2)
        self:setLabelText("Label1", CHS[4200787], tipsPanel)
        self:setLabelText("Label2", CHS[4200788], tipsPanel)
    else
        self:setLabelText("TipsLabel", CHS[4200789], iconPanel1)
        self:setLabelText("TipsLabel", CHS[4200790], iconPanel2)
        self:setLabelText("NumLabel", self.data.daofa .. "/50", iconPanel1)
        self:setLabelText("NumLabel", self.data.xinfa .. "/50", iconPanel2)
        self:setLabelText("Label1", CHS[4200791], tipsPanel)
        self:setLabelText("Label2", CHS[4200792], tipsPanel)
    end

    -- 设置成长
    self:setGrowthInfo()
end

function KidCultureDlg:setGrowthInfo()
    local panel = self:getControl("XiulianAttributePanel")
    -- 总修炼资质
    local data = self.data
    local total = data.init_life + data.init_mana + data.init_speed + data.init_phy + data.init_mag
    total = data.add_life + data.add_mana + data.add_speed + data.add_phy + data.add_mag + total
    self:setLabelText("Label_98_0_1", total, panel)

    if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
        self:setLabelText("Label_98", CHS[4200793])
    else
        self:setLabelText("Label_98", CHS[4200794])
    end


    -- 物攻
    self:setProgressBarForSelf(data.init_phy, data.add_phy, data.add_phy_max, "PHY", self:getControl("PhysicsPanel", nil, panel))

    -- 法攻
    self:setProgressBarForSelf(data.init_mag, data.add_mag, data.add_mag_max, "MAG", self:getControl("ManaPanel", nil, panel))

    -- 速度
    self:setProgressBarForSelf(data.init_speed, data.add_speed, data.add_speed_max, "SPEED", self:getControl("SpeedPanel", nil, panel))

    -- 气血
    self:setProgressBarForSelf(data.init_life, data.add_life, data.add_life_max, "LIFE", self:getControl("BloodPanel", nil, panel))

    -- 法力
    self:setProgressBarForSelf(data.init_mana, data.add_mana, data.add_mana_max, "MANA", self:getControl("MagicPanel", nil, panel))
end



function KidCultureDlg:setProgressBarForSelf(basic, add, maxValue, type, panel)
    self:setLabelText("TotalNumLabel", basic, panel)
    self:setLabelText("TotalNumLabel_0", basic, panel)
    self:setLabelText("XiulianNumLabel", " + " .. add, panel)
    self:setLabelText("XiulianNumLabel_0", " + " .. add, panel)

    if add >= maxValue and maxValue > 0 then
        if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
            self:setLabelText("TipsLabel", CHS[4200760], panel)     -- 已满
            self:setLabelText("TipsLabel_0", CHS[4200760], panel)     -- 已满
        else
            self:setLabelText("TipsLabel", CHS[4200780], panel)     -- 已满
            self:setLabelText("TipsLabel_0", CHS[4200780], panel)     -- 已满
        end
    elseif basic == 0 then
        self:setLabelText("TipsLabel", CHS[4200761], panel)     -- 无法提升
        self:setLabelText("TipsLabel_0", CHS[4200761], panel)     -- 已满
    elseif basic > 0 and maxValue == 0 then
        self:setLabelText("TipsLabel", CHS[4200761], panel)     -- 无法提升
        self:setLabelText("TipsLabel_0", CHS[4200761], panel)     -- 无法提升
    else
        self:setLabelText("TipsLabel", CHS[4200762], panel)
        self:setLabelText("TipsLabel_0", CHS[4200762], panel)
    end

    --local bth = self:getControl("ZizhiButton", nil, panel)
    panel.data = {basic = basic, add = add, type = type, maxValue = maxValue}

    self:setProgressBar("ProgressBar", basic, basic + maxValue, panel)
    self:setProgressBar("ProgressBar_0", basic + add, basic + maxValue, panel)
end

function KidCultureDlg:onZizhiButton(sender, eventType)
    for _, panelName in pairs(ATTRIBUTE_PANEL_MAP) do
        local panel = self:getControl(panelName, nil, "XiulianAttributePanel")
        self:setCtrlVisible("SelectionImage", false, panel)
    end

    self:setCtrlVisible("SelectionImage", true, sender:getParent())

    self.selectAttributeData = sender:getParent().data
end

function KidCultureDlg:getNaijiuByColor(color)
    return (QUALITY_COLOR[color] + 3) * 1000 + 3000
end

function KidCultureDlg:setSelectToyInfo(data)
    local panel = self:getControl("InforPanel", "ChoicePanel")
    if not data then
        self:setImagePlist("ItemImage", ResMgr.ui.pet_skill_grid, panel)
        self:setImageSize("ItemImage", {width = 74,height = 74}, panel)
        self:setLabelText("NameLabel", "", panel, COLOR3.TEXT_DEFAULT)
        self:setLabelText("QualityLabel", "", panel)
        self:setLabelText("AttributeLabel", "", panel)
        self:setLabelText("DurableLabel", "", panel)

        self:setCtrlVisible("IconPanel", false, panel)
        return
    end

    self:setCtrlVisible("IconPanel", true, panel)
    local img = self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), panel)
    self:setLabelText("NameLabel", data.name, panel, InventoryMgr:getItemColor(data))
    self:setLabelText("QualityLabel", string.format( CHS[4200763], data.color), panel)
    self:setLabelText("AttributeLabel", string.format( "%s：%d", ATTRIBUTE_MAP[data.showName], HomeChildMgr:getEffectByToyName(data.name)), panel)
    self:setLabelText("DurableLabel", string.format(CHS[4200765], self:getNaijiuByColor(data.color)), panel)
end


function KidCultureDlg:onSelectToyType(sender, eventType)
    local name = self:getLabelText("NameLabel", sender)
    self:setLabelText("NameLabel", name, "ScreenButton")

    self:setCtrlVisible("ToysScreenPanel", false)


    self:setToyListView(name)
end


function KidCultureDlg:onCanjuan(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)

    if sender:getName() == "IconPanel1" then
        InventoryMgr:showBasicMessageDlg(CHS[4101495], rect)
    else
        InventoryMgr:showBasicMessageDlg(CHS[4101496], rect)
    end
end

function KidCultureDlg:onSelectToyPanel(sender, eventType)
    if self.toSelectToyImage:getParent() == sender:getParent() then
        return
    end

    if not sender.data then return end

    self.toSelectToyImage:removeFromParent()
    sender:addChild(self.toSelectToyImage)

    self.selectToy = sender.data

    self:setSelectToyInfo(self.selectToy)

end


function KidCultureDlg:onSelectEquipPanel(sender, eventType)
    if self.equipSelectToyImage:getParent() == sender then
        return
    end

    if not sender.data then
        self:onIncreaseButton(sender:getChildByName("IncreaseButton"))
        return
    end


    for _, panelName in pairs(JOY_RIGHT_MAP) do
        self:setCtrlVisible(panelName, panelName == "ItemAttributePanel")
    end

    self.equipSelectToyImage:removeFromParent()
    sender:addChild(self.equipSelectToyImage)

    for _, panelName in pairs(JOY_RIGHT_MAP) do
        self:setCtrlVisible(panelName, panelName == "ItemAttributePanel")
    end

    self:setSelectEquipToy(sender.data)
    self.selectEquiToy = sender.data
end


function KidCultureDlg:setSelectEquipToy(data)
    local panel = self:getControl("ItemAttributePanel")
    local image = self:setImage("ItemImage", ResMgr:getIconPathByName(data.toy_name), panel)

    if data.naijiu > 0 then
        gf:resetImageView(image)
    else
        gf:grayImageView(image)
    end

    --self:setLabelText("NameLabel", ATTRIBUTE_MAP[data.toy_name] .. "：")
    local pos = gf:findStrByByte(data.toy_name, "（")
    local name = string.sub(data.toy_name, 0, pos - 1)

    local pos2 = gf:findStrByByte(data.toy_name, "）")
    local color = string.sub(data.toy_name, pos + 3, pos2 - 1)

    local namePanel = self:getControl("NamePanel", nil, panel)
    self:setLabelText("NameLabel", data.toy_name, namePanel, InventoryMgr:getItemColor({color = color}))

    local attPanel = self:getControl("AttributePanel", nil, panel)
    self:setLabelText("NameLabel", ATTRIBUTE_MAP[name] .. "：", attPanel)
    if name == CHS[4200735] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_life, attPanel)
    elseif name == CHS[4200736] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_def, attPanel)
    elseif name == CHS[4200737] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_speed, attPanel)
    elseif name == CHS[4200738] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_phy, attPanel)
    elseif name == CHS[4200739] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_mag, attPanel)
    elseif name == CHS[4200740] then
        self:setLabelText("NumLabel", "+" .. self.data.toy_buff_mana, attPanel)
    end

    local durPanel = self:getControl("DurablePanel", nil, panel)



  --  self:setLabelText("NumLabel", data.naijiu .. "/" .. self:getNaijiuByColor(color), durPanel)
    self:setLabelText("NumLabel", data.naijiu, durPanel)
    self:setLabelText("NameLabel", CHS[4200766], durPanel)
end

function KidCultureDlg:onIncreaseButton(sender, eventType)
    if self.equipSelectToyImage:getParent() == sender:getParent() then
        return
    end

    for _, panelName in pairs(JOY_RIGHT_MAP) do
        self:setCtrlVisible(panelName, panelName == "ChoicePanel")
    end

    self.equipSelectToyImage:removeFromParent()
    sender:getParent():addChild(self.equipSelectToyImage)
end


function KidCultureDlg:onXiulianTipsButton(sender, eventType)
    self:setCtrlVisible("XiulianTipsPanel", true)
end

function KidCultureDlg:onStageTipsButton(sender, eventType)
    self:setCtrlVisible("QualificationsTipsPanel", true)
end


-- 丢弃玩具
function KidCultureDlg:onDiscardButton(sender, eventType)

    if not self.selectEquiToy then
        gf:ShowSmallTips(CHS[4200777])
        return
    end
    gf:CmdToServer("CMD_CHILD_DROP_TOY", {child_id = self.data.id, toy_name = self.selectEquiToy.toy_name})
end

function KidCultureDlg:onSupplementButton(sender, eventType)
    if not self.selectEquiToy then return end
    local amount = InventoryMgr:getAmountByName(self.selectEquiToy.toy_name)
    if amount <= 0 then
        gf:ShowSmallTips(CHS[4200767])
        return
    end

    self.selectEquiToy.child_id = self.data.id
    DlgMgr:openDlgEx("KidToysDurableDlg", self.selectEquiToy)
end

function KidCultureDlg:onChoiceDiscardButton(sender, eventType)
    if not self.selectToy then
        gf:ShowSmallTips(CHS[4200777])
        return
    end
    gf:CmdToServer("CMD_CHILD_EQUIP_TOY", {child_id = self.data.id, toy_id = self.selectToy.item_unique, toy_name = self.selectToy.name})

end

function KidCultureDlg:onScreenButton(sender, eventType)
    self:setCtrlVisible("ToysScreenPanel", true)
end

function KidCultureDlg:onXiulianButton(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selectAttributeData then

        if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
            gf:ShowSmallTips(CHS[4200768])
        else
            gf:ShowSmallTips(CHS[4200795])
        end

        return
    end

    if self.selectAttributeData.add >= self.selectAttributeData.maxValue then


        if self.data.stage == HomeChildMgr.KID_STAGE.XIULIAN then
            gf:ShowSmallTips(string.format(CHS[4200769], ATTRIBUTE_MAP[self.selectAttributeData.type]))
        else

            gf:ShowSmallTips(string.format(CHS[4200796], ATTRIBUTE_MAP[self.selectAttributeData.type]))
        end

        return
    end

   -- string.lower( self.selectAttributeData.type )

    gf:CmdToServer("CMD_CHILD_PRACTICE", {child_id = self.data.id, xiulian_type = string.lower( self.selectAttributeData.type ), stage = self.data.stage})
end

function KidCultureDlg:onTipsButton(sender, eventType)
    self:setCtrlVisible("ToysTipsPanel", true)
end



function KidCultureDlg:MSG_CHILD_CULTIVATE_INFO(data)
    self.data = data
    self:setXiulianData()
    self:setToyData()
end


return KidCultureDlg
