-- UserTabDlg.lua
-- Created by cheny Dec/17/2014
-- 角色信息标签页对话框

local TabDlg = require('dlg/TabDlg')
local UserTabDlg = Singleton("UserTabDlg", TabDlg)

UserTabDlg.lastDlg = "UserDlg"
UserTabDlg.orderList = {
    ["UserDlgCheckBox"]             = 1,
    ["UserAddPointDlgCheckBox"]     = 2,
    ["InnerAlchemyDlgCheckBox"]    = 3,
    ["XianMoAddPointDlgCheckBox"]   = 4,
    ["SkillDlgCheckBox"]            = 5,
}

-- 按钮与对话框的映射表
UserTabDlg.dlgs = {
    UserDlgCheckBox = "UserDlg",
    UserAddPointDlgCheckBox = "UserAddPointTabDlg",
    InnerAlchemyDlgCheckBox = "InnerAlchemyDlg",
    XianMoAddPointDlgCheckBox = "XianMoAddPointDlg",
    SkillDlgCheckBox = "SkillDlg",
}

-- 菜单间隔
UserTabDlg.tabMargin = 7

-- 子 Tab 对应的对话框列表
UserTabDlg.subTabDlgs = {
    UserAddPointTabDlg = {"UserAddPointDlg", "PolarAddPointDlg"}
}

function UserTabDlg:init()
    if Me:getLevel() < 110 then
        self.orderList["SkillDlgCheckBox"] = 2.5
    else
        self.orderList["SkillDlgCheckBox"] = 5
    end

    TabDlg.init(self)

    if Me:getLevel() < 110 then
        self:setCtrlVisible("InnerAlchemyDlgCheckBox", false)
        self:setCtrlVisible("XianMoAddPointDlgCheckBox", false)
    else
        self:setCtrlVisible("InnerAlchemyDlgCheckBox", true)
        self:setCtrlVisible("XianMoAddPointDlgCheckBox", true)
    end

    self:hookMsg("MSG_LEVEL_UP")
end

function UserTabDlg:onPreCallBack(sender, idx)
    local name = sender:getName()

    if name == "XianMoAddPointDlgCheckBox" or name == "InnerAlchemyDlgCheckBox" then
        if Me:queryInt("upgrade/level") < 120 then
            local babyStr = CHS[4100560]
            if Me:getChildType() == 2 then babyStr = CHS[4100561] end            
            gf:ShowSmallTips(string.format(CHS[4100878], babyStr))
            return
        end

        if not Me:isFlyToXianMo() then
            gf:ShowSmallTips(CHS[4100879])
            return
        end
    end
    return true
end

function UserTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "UserDlg"
end

function UserTabDlg:MSG_LEVEL_UP(data)
    if data.id ~=  Me:getId() then return end
    if self.orderList["SkillDlgCheckBox"] == 2.5 and Me:getLevel() >= 110 then
        self:init()
    end
end

return UserTabDlg
