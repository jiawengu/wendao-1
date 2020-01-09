-- HomeTabDlg.lua
-- Created by huangzz Aug/08/2017
-- 进入居所标签

local TabDlg = require('dlg/TabDlg')
local HomeTabDlg = Singleton("HomeTabDlg", TabDlg)

-- 按钮与对话框的映射表
HomeTabDlg.dlgs = {
    HomeDlgCheckBox = "HomeInDlg",            -- 返回居所界面
    HomeKidDlgCheckBox = "HomeKidDlg",      -- 居所小孩界面
    XiulianDlgCheckBox = "HomeCheckDlg",      -- 居所修炼界面
    PlantDlgCheckBox = "HomePlantCheckDlg",   -- 种植查看界面
    OtherDlgCheckBox = "HomeOtherCheckDlg",   -- 其它查看界面
}

HomeTabDlg.orderList = {
    ["HomeDlgCheckBox"] = 1,
    ["HomeKidDlgCheckBox"] = 2,
    ["XiulianDlgCheckBox"] = 3,
    ["PlantDlgCheckBox"] = 4,
    ["OtherDlgCheckBox"] = 5,
}

function HomeTabDlg:init()
    TabDlg.init(self)

    gf:CmdToServer("CMD_CHILD_REQUEST_INFO")        -- 提前请求一下居所娃娃数据
end

function HomeTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end
    local name = sender:getName()
    if name == "HomeKidDlgCheckBox" then
        local count = HomeChildMgr:getChildenCount()
        if not count then
            -- 数据没有收到，正常情况由于延迟，不给提示和反应
            return false
        elseif count <= 0 then
            gf:ShowSmallTips(CHS[4010394])                -- ("你尚未拥有娃娃或天地灵石，可找#R风月谷#n的#Y送子娘娘#n了解如何获得娃娃。")
            return false
        end
    end

    return true
end

return HomeTabDlg
