-- EquipmentRuleAttributeDlg.lua
-- Created by songcw Oct/2018/9
-- 装备属性一览表

local EquipmentRuleAttributeDlg = Singleton("EquipmentRuleAttributeDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local CHECKBOX = {
    "WeaponButton",    "ArmorButton",      "HelmetButton",     "BootButton",
    "YupeiButton",     "XianglianButton",  "ShouzhuoButton"
}

local BTN_EQUIP_TYPE = {
    ["WeaponButton"] = EQUIP_TYPE.WEAPON,
    ["ArmorButton"] = EQUIP_TYPE.ARMOR,
    ["HelmetButton"] = EQUIP_TYPE.HELMET,
    ["BootButton"] = EQUIP_TYPE.BOOT,

    ["YupeiButton"] = EQUIP_TYPE.BALDRIC,
    ["XianglianButton"] = EQUIP_TYPE.NECKLACE,
    ["ShouzhuoButton"] = EQUIP_TYPE.WRIST,
}


-- 共鸣属性，不同相性需要排除的
local GM_PAICHU_POLOR = {
    [1] = {[CHS[3000437]] = 1, [CHS[3000438]] = 1, [CHS[3000439]] = 1, [CHS[3000440]] = 1,
        [CHS[3000411]] = 1, [CHS[3000410]] = 1, [CHS[3000409]] = 1, [CHS[3000408]] = 1,
    },

    [2] = {[CHS[3000436]] = 1, [CHS[3000438]] = 1, [CHS[3000439]] = 1, [CHS[3000440]] = 1,
        [CHS[3000412]] = 1, [CHS[3000410]] = 1, [CHS[3000409]] = 1, [CHS[3000408]] = 1,
    },

    [3] = {[CHS[3000436]] = 1, [CHS[3000437]] = 1, [CHS[3000439]] = 1, [CHS[3000440]] = 1,
        [CHS[3000412]] = 1, [CHS[3000411]] = 1, [CHS[3000409]] = 1, [CHS[3000408]] = 1,
    },

    [4] = {[CHS[3000436]] = 1, [CHS[3000437]] = 1, [CHS[3000438]] = 1, [CHS[3000440]] = 1,
        [CHS[3000412]] = 1, [CHS[3000411]] = 1, [CHS[3000410]] = 1, [CHS[3000408]] = 1,
    },

    [5] = {[CHS[3000436]] = 1, [CHS[3000437]] = 1, [CHS[3000438]] = 1, [CHS[3000439]] = 1,
        [CHS[3000412]] = 1, [CHS[3000411]] = 1, [CHS[3000410]] = 1, [CHS[3000409]] = 1,
    },
}


local POLAR_WEAPON = {
    CHS[3001023], CHS[3001028], CHS[3001033], CHS[3001038], CHS[3001043],
}

function EquipmentRuleAttributeDlg:init(dlgType)

    self.unitPanel = self:retainCtrl("UnitPanel")

    self.dlgType = dlgType or "Refining"
    self.group = RadioGroup.new()
    self.group:setItemsByButton(self, CHECKBOX, self.onCheckBox)

    self:setCtrlVisible("TypePanel", false)
    self:setCtrlVisible("JewelryTypePanel", false)
    self:setCtrlVisible("GongmingTitlePanel", false)

    -- 如果是首饰相关，单选框显示首饰
    if string.match( self.dlgType, "Jewelry") then
        self:setCtrlVisible("JewelryTypePanel", true)
        self:onCheckBox(self:getControl("YupeiButton"))
        self.group:setSetlctButtonByName("YupeiButton")
    elseif string.match( self.dlgType, "Gongming") then
        self:setCtrlVisible("GongmingTitlePanel", true)
        self:onCheckBox(self:getControl(CHECKBOX[1]))
    else
        self:setCtrlVisible("TypePanel", true)
        self:onCheckBox(self:getControl(CHECKBOX[1]))

        if self.dlgType == "Suit" then

        --    gf:ShowSmallTips(string.format( "武器-%s", POLAR_WEAPON[Me:queryBasicInt("polar")]))
            self:setLabelText("WeaponButtonLabel", string.format( CHS[4200609], POLAR_WEAPON[Me:queryBasicInt("polar")]))
        end
    end
end

function EquipmentRuleAttributeDlg:onCheckBox(sender, eventType)

    local function setAttrib(data, panelName, parentPanel)
        if data then
            local panel = self:getControl(panelName, nil, parentPanel)
            self:setLabelText("AttriLabel1", data, panel)
        else
            self:setCtrlVisible(panelName, false, parentPanel)
        end
    end

    local allAttrib = {}
    if self.dlgType == "Refining" or self.dlgType == "Jewelry" then
        allAttrib = EquipmentMgr:getAllAddAttribByEquipType(BTN_EQUIP_TYPE[sender:getName()])
    elseif self.dlgType == "Gongming" then
        local atts = EquipmentMgr:getGongmingAttribList()

        -- 特殊要求，排除非本相性的 GM_PAICHU_POLOR allAttrib
        local paichuAtt = GM_PAICHU_POLOR[Me:queryBasicInt("polar")]
        for i, attName in pairs(atts) do
            if not paichuAtt[attName] then
                table.insert( allAttrib, attName )
            end
        end

    elseif self.dlgType == "Suit" then
        if "WeaponButton" == sender:getName() then
            allAttrib = EquipmentMgr:getAllSuitAttribByEquipType(POLAR_WEAPON[Me:queryBasicInt("polar")])
        else
            allAttrib = EquipmentMgr:getAllSuitAttribByEquipType(BTN_EQUIP_TYPE[sender:getName()])
        end
    else
        return
    end



    local list = self:resetListView("ListView")
    local count = math.floor((#allAttrib - 1) / 3) + 1
    local idx = 0
    for i = 1, count do
        local uPanel = self.unitPanel:clone()
        idx = idx + 1
        setAttrib(allAttrib[idx], "UnitPanel1", uPanel)

        idx = idx + 1
        setAttrib(allAttrib[idx], "UnitPanel2", uPanel)

        idx = idx + 1
        setAttrib(allAttrib[idx], "UnitPanel3", uPanel)

        list:pushBackCustomItem(uPanel)
    end
end


return EquipmentRuleAttributeDlg
