-- MarketGoldPetInfoDlg.lua
-- Created by songcw
-- 珍宝展示界面，宠物


local MarketGoldPetInfoDlg = Singleton("MarketGoldPetInfoDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 宠物属性、成长、技能checkBox
local PET_DISPLAY_CHECKBOX = {
    "PetBasicInfoCheckBox",
    "PetAttribInfoCheckBox",
    "PetSkillInfoCheckBox",
}

-- 宠物属性、成长、技能checkBox 对应显示的panel
local PET_CHECKBOX_PANEL = {
    ["PetBasicInfoCheckBox"] = "MarketGoldPetInfoBasicDlg",
    ["PetAttribInfoCheckBox"] = "MarketGoldPetInfoAttribDlg",
    ["PetSkillInfoCheckBox"] = "MarketGoldPetInfoSkillDlg",
}

function MarketGoldPetInfoDlg:init(data)
    self:bindListener("SlipButton", self.onSlipButton)
    self:bindListener("SlipButton", self.onSlipButton)
    self:bindListener("SlipButton", self.onSlipButton)
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListViewListener("ListView", self.onSelectListView)

    self.childDlg = {}

    self.data = data
    if data.getId and data:getId() and PetMgr:getPetById(data:getId()) then
        self.isMePet = true
    else
        self.isMePet = false
    end

    self:hookMsg("MSG_GOLD_STALL_BUY_RESULT")
    self:hookMsg("MSG_GOLD_STALL_MINE")
    self:initPetCheckBox()
end

function MarketGoldPetInfoDlg:cleanup()
    if self.childDlg then

        for dlgName, dlg in pairs(self.childDlg) do
            DlgMgr:closeDlg(dlgName)
        end

        self.childDlg = nil
    end
end

-- 单选框初始化
function MarketGoldPetInfoDlg:initPetCheckBox()
    self.radioCheckBox = RadioGroup.new()
    self.radioCheckBox:setItems(self, PET_DISPLAY_CHECKBOX, self.onPetInfoCheckBox)
    self.radioCheckBox:setSetlctByName(PET_DISPLAY_CHECKBOX[1])
end

-- 点击宠物显示信息的checkBox
function MarketGoldPetInfoDlg:onPetInfoCheckBox(sender, eventType)
    for _, panelName in pairs(PET_CHECKBOX_PANEL) do
     --   self:setCtrlVisible(panelName, false)
        self:setCtrlVisible("ChosenPanel", false, _)
        self:setCtrlVisible("UnChosenPanel", true, _)

        if self.childDlg[panelName] then
            DlgMgr:closeDlg(panelName)
            self.childDlg[panelName] = nil
        end
    end

    self:setCtrlVisible("ChosenPanel", true, sender)
    self:setCtrlVisible("UnChosenPanel", false, sender)
 --   self:setCtrlVisible(PET_CHECKBOX_PANEL[sender:getName()], true)

    local dlg = DlgMgr:openDlgEx(PET_CHECKBOX_PANEL[sender:getName()], self.data)
    self.childDlg[PET_CHECKBOX_PANEL[sender:getName()]] = dlg
end

-- 设置宠物
function MarketGoldPetInfoDlg:setPetInfo(pet)








end

function MarketGoldPetInfoDlg:MSG_GOLD_STALL_MINE(data)
    self:onCloseButton()
end

function MarketGoldPetInfoDlg:MSG_GOLD_STALL_BUY_RESULT(data)
    --if data.result == 1 or data.result == 3 then
        self:onCloseButton()
    --end
end

function MarketGoldPetInfoDlg:onSlipButton(sender, eventType)
end

function MarketGoldPetInfoDlg:onSlipButton(sender, eventType)
end

function MarketGoldPetInfoDlg:onSelectListView(sender, eventType)
end

function MarketGoldPetInfoDlg:onSelectListView(sender, eventType)
end

function MarketGoldPetInfoDlg:onSelectListView(sender, eventType)
end

return MarketGoldPetInfoDlg
