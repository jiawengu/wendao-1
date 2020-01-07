-- EquipmentRuleNewDlg.lua
-- Created by Oct/2018/9
-- 装备规则总览

local EquipmentRuleNewDlg = Singleton("EquipmentRuleNewDlg", Dialog)


-- 一级菜单
local MENU_BIG_CLASS = {
    --"装备总览, "拆分, "重组, "炼化, "改造, "套装, "进化,
    CHS[4200598], CHS[4200599], CHS[4200597], CHS[4200594], CHS[4200592], CHS[4200596], CHS[4200591],
}

-- 二级菜单
local MENU_SMALL_CLASS = {
    [CHS[4200594]] = {CHS[4200594], CHS[4200600], CHS[4200601], CHS[4200602]},
    [CHS[4200592]] = {CHS[4200592], CHS[4200595], CHS[4200593]},
    [CHS[4200591]] = {CHS[4200591], CHS[4200603]},
}


-- 一级菜单对应的界面
local BIG_MENU_DLG = {
    [CHS[4200598]] = "EquipmentRuleNewFirstPageDlg",
    [CHS[4200599]] = "EquipmentRuleNewSplitDlg",
    [CHS[4200597]] = "EquipmentRuleNewReformDlg",
    [CHS[4200596]] = "EquipmentRuleNewSuitDlg",
}

-- 二级菜单对应的界面
local SMALL_MENU_DLG = {
    [CHS[4200594]] = "EquipmentRuleNewRefiningDlg",
    [CHS[4200600]] = "EquipmentRuleNewRefiningPinkDlg",
    [CHS[4200601]] = "EquipmentRuleNewRefiningYellowDlg",
    [CHS[4200602]] = "EquipmentRuleNewStrengthenDlg",
    [CHS[4200592]] = "EquipmentRuleNewUpgradeDlg",
    [CHS[4200595]] = "EquipmentRuleNewGongmingDlg",
    [CHS[4200593]] = "EquipmentRuleNewInheritDlg",
    [CHS[4200591]] = "EquipmentRuleNewEvovleDlg",
    [CHS[4200603]] = "EquipmentRuleNewDegenerationDlg",
}

function EquipmentRuleNewDlg:init(data)

    self.bigMenuPanel = self:retainCtrl("BigPanel")
    self.smallMenuPanel = self:retainCtrl("SPanel")

    self.relationDlgName = nil

    -- 左侧菜单处理
    self:setMenuList("CategoryListView", self:getBigMenus(), self.bigMenuPanel, MENU_SMALL_CLASS, self.smallMenuPanel, self.onClickBigMenu, self.onClickSmallMenu, data)

end


function EquipmentRuleNewDlg:getBigMenus()
    local menus = {}

    -- 装备总览
    table.insert( menus, CHS[4200598] )

    -- 拆分
    if Me:queryBasicInt("level") >= 50 then
        table.insert( menus, CHS[4200599] )
    end

    -- 重组
    if Me:queryBasicInt("level") >= 50 then
        table.insert( menus, CHS[4200597] )
    end

    -- 炼化
    if Me:queryBasicInt("level") >= 50 then
        table.insert( menus, CHS[4200594] )
    end

    -- 改造
    if Me:queryBasicInt("level") >= 40 then
        table.insert( menus, CHS[4200592] )
    end

    -- 套装
    if Me:queryBasicInt("level") >= 70 then
        table.insert( menus, CHS[4200596] )
    end

    -- 进化
    if Me:queryBasicInt("level") >= 70 then
        table.insert( menus, CHS[4200591] )
    end

    return menus
end

-- 点击一级菜单
function EquipmentRuleNewDlg:onClickBigMenu(sender, isDef)
    -- 关闭一级打开的右侧界面
    self:closeChildDlg()

    local dlgName = BIG_MENU_DLG[sender:getName()]
    if dlgName then
        self.childDlg = DlgMgr:openDlg(dlgName)
        self.relationDlgName = dlgName
    end
end

-- 点击二级菜单
function EquipmentRuleNewDlg:onClickSmallMenu(sender, isDef)
    -- 关闭一级打开的右侧界面
    self:closeChildDlg()

    local dlgName = SMALL_MENU_DLG[sender:getName()]
    if dlgName then
        performWithDelay(self.root, function ( )
            -- body
            self.childDlg = DlgMgr:openDlg(dlgName)
            self.relationDlgName = dlgName
        end)
    end
end

function EquipmentRuleNewDlg:closeChildDlg()
    if self.relationDlgName then
        DlgMgr:closeDlg(self.relationDlgName)
        self.relationDlgName = nil
        self.childDlg = nil
    end
end

-- 模拟点击一级菜单，和 onClickBigMenu 区别在于，要设置选中的光效
function EquipmentRuleNewDlg:onGotoMenu(menuName, smallMenu)
    local data = {one = menuName, two = smallMenu, isScrollToDef = true}
    self:setMenuList("CategoryListView", self:getBigMenus(), self.bigMenuPanel, MENU_SMALL_CLASS, self.smallMenuPanel, self.onClickBigMenu, self.onClickSmallMenu, data)
end

function EquipmentRuleNewDlg:cleanup()
    self:closeChildDlg()
end

return EquipmentRuleNewDlg
