-- EquipmentTabDlg.lua
-- Created by cheny Jan/15/2015
-- 装备标签

local TabDlg = require('dlg/TabDlg')
local EquipmentTabDlg = Singleton("EquipmentTabDlg", TabDlg)

EquipmentTabDlg.defDlg = "EquipmentSplitDlg"

EquipmentTabDlg.dlgs = {
    EquipmentSplitTabDlgCheckBox = "EquipmentSplitDlg",
    EquipmentRefiningTabDlgCheckBox = "EquipmentRefiningDlg",
    EquipmentUpgradeDlgCheckBox = "EquipmentUpgradeDlg",
    EquipmentRefiningSuitDlgCheckBox = "EquipmentRefiningSuitDlg",
    EquipmentEvolveDlgCheckBox = "EquipmentEvolveDlg",
}

EquipmentTabDlg.tabMargin = 5

EquipmentTabDlg.orderList = {
    ["EquipmentSplitTabDlgCheckBox"]        = 1,
    ["EquipmentRefiningTabDlgCheckBox"]     = 2,
    ["EquipmentUpgradeDlgCheckBox"]         = 3,
    ["EquipmentRefiningSuitDlgCheckBox"]    = 4,
    ["EquipmentEvolveDlgCheckBox"]              = 5,
}

-- 2分30秒打开时候要记录选中的装备id
EquipmentTabDlg.lastSelectItemId = nil

function EquipmentTabDlg:init()
    TabDlg.init(self)
    
    if Me:queryBasicInt("level") < 70 then
        self:setCtrlVisible("EquipmentEvolveDlgCheckBox", false)
    end
end

function EquipmentTabDlg:setLastSelectItemId(id)
    self.lastSelectItemId = id
end

function EquipmentTabDlg:getSelectItemBox(clickItem)
    if self:getCurSelectCtrlName() ~= clickItem then
        local panel = self:getControl(clickItem)
        return self:getBoundingBoxInWorldSpace(panel)
    end
end

-- 设置要选中的界面
function EquipmentTabDlg:setSelectDlg(dlgName)
    for i = 1, #self.allRadio do
        if dlgName == "EquipmentReformDlg" and self.allRadio[i] == "EquipmentRefiningTabDlgCheckBox" then
            self.group:selectRadio(i, true)
            self.lastDlg = "EquipmentRefiningDlg"
            self:onSelected(self:getControl(self.allRadio[i]))
            return
        end    
    
        if self.dlgs[self.allRadio[i]] == dlgName then
            self.group:selectRadio(i, true)
            self.lastDlg = dlgName
            self:onSelected(self:getControl(self.allRadio[i]))
            return
        end
    end

    -- 选中开启的最上面一个选项
    if self.allRadio[1] then
        self.group:selectRadio(1, true)
        self:onSelected(self:getControl(self.allRadio[1]))
    end
end

-- 关闭当前显示的对话框
function EquipmentTabDlg:closeRadioDlgExclude(name)

    local realName = self:getCurSelect()
    for radio, dlgName in pairs(self.dlgs) do
        if dlgName ~= realName then
            DlgMgr:closeThisDlgOnly(dlgName)
        end        
    end

    if name ~= "EquipmentReformDlg" then
        DlgMgr:closeThisDlgOnly("EquipmentReformDlg")
    end 

    return 
end

function EquipmentTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "EquipmentSplitDlg"
end

return EquipmentTabDlg
