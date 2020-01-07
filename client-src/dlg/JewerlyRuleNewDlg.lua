-- JewerlyRuleNewDlg.lua
-- Created by
--

local JewerlyRuleNewDlg = Singleton("JewerlyRuleNewDlg", Dialog)

-- 一级菜单，注意，该一级菜单是总菜单，需要根据等级判断是否开启
local MENU_BIG_CLASS = {
    -- "合成, "分解, 重铸", 转换", 强化"
    CHS[4200605], CHS[4200606], CHS[4200607], CHS[4200604], CHS[4200602]
}

-- 菜单对应显示的panel
local MENU_PANEL_MAP = {
    [CHS[4200605]] = "UpgradePanel",
    [CHS[4200606]] = "DecomposePanel",
    [CHS[4200607]] = "RefinePanel",
    [CHS[4200604]] = "ChangePanel",
    [CHS[4200602]] = "DevelopPanel",
}

function JewerlyRuleNewDlg:init(data)
    self:bindListener("AllAttributeLink", self.onAllAttributeLink, "UpgradePanel")
    self:bindListener("AllAttributeLink", self.onAllAttributeLink, "RefinePanel")
    self:bindListener("AllAttributeLink", self.onAllAttributeLink, "ChangePanel")

    self.bigMenuPanel = self:retainCtrl("BigPanel")
    self.smallMenuPanel = self:retainCtrl("SPanel")

    -- 左侧菜单处理
    self:setMenuList("CategoryListView", self:getBigMenus(), self.bigMenuPanel, nil, nil, self.onClickBigMenu, nil, data)

end

-- 获取一级菜单
function JewerlyRuleNewDlg:getBigMenus()
    local bigMenus = {}
    -- 合成
    table.insert( bigMenus, CHS[4200605])
    -- 分解
    table.insert( bigMenus, CHS[4200606])
    -- 重铸
    table.insert( bigMenus, CHS[4200607])
    -- 转换
    if Me:queryBasicInt("level") >= 100 then
        table.insert( bigMenus, CHS[4200604])
    end

    -- 强化
    -- 公测要11月22号开放
    if not DistMgr:curIsTestDist() then
        local timeCount = os.time({day = 22, year = 2018, month = 11, hour = 5})
		-- 公测时间小于 2018/11/22 05:00 或者等级小于 115都隐藏
        if gf:getServerTime() - tonumber(timeCount) > 0 and Me:queryBasicInt("level") >= 115 then
            table.insert( bigMenus, CHS[4200602])
        end
    else
        if Me:queryBasicInt("level") >= 115 then
            table.insert( bigMenus, CHS[4200602])
        end
    end

    return bigMenus
end

-- 点击一级菜单
function JewerlyRuleNewDlg:onClickBigMenu(sender, isDef)
    for menuName, panelName in pairs(MENU_PANEL_MAP) do
        self:setCtrlVisible(panelName, menuName == sender:getName())
    end
end

function JewerlyRuleNewDlg:onAllAttributeLink(sender, eventType)
    DlgMgr:openDlgEx("EquipmentRuleAttributeDlg", "Jewelry")
end

return JewerlyRuleNewDlg
