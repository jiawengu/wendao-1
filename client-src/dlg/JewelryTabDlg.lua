-- JewelryTabDlg.lua
-- Created by huangzz Dec/17/2016
-- 首饰标签

local TabDlg = require('dlg/TabDlg')
local JewelryTabDlg = Singleton("JewelryTabDlg", TabDlg)

JewelryTabDlg.defDlg = "JewelryUpgradeDlg"

JewelryTabDlg.tabMargin = 5

JewelryTabDlg.orderList = {
    ["JewelryUpgradeTabDlgCheckBox"]            = 1,
    ["JewelryDecomposeTabDlgCheckBox"]          = 2,
    ["JewelryRefineTabDlgCheckBox"]             = 3,
    ["JewelryChangeTabDlgCheckBox"]             = 4,
    ["JewelryDevelopTabDlgCheckBox"]             = 5,
}

-- 按钮与对话框的映射表
JewelryTabDlg.dlgs = {
    JewelryUpgradeTabDlgCheckBox = "JewelryUpgradeDlg",
    JewelryDecomposeTabDlgCheckBox = "JewelryDecomposeDlg",
    JewelryRefineTabDlgCheckBox = "JewelryNewRefineDlg",
    JewelryChangeTabDlgCheckBox = "JewelryChangeDlg",
    JewelryDevelopTabDlgCheckBox = "JewelryDevelopDlg",
}

function JewelryTabDlg:init()
    TabDlg.init(self)

    if Me:queryBasicInt("level") < 100 then
        self:setCtrlVisible("JewelryChangeTabDlgCheckBox", false)
    end


    -- 公测要11月22号开放
    if not DistMgr:curIsTestDist() then
        local timeCount = os.time({day = 22, year = 2018, month = 11, hour = 5})
		-- 公测时间小于 2018/11/22 05:00 或者等级小于 115都隐藏
        if gf:getServerTime() - tonumber(timeCount) < 0 or Me:queryBasicInt("level") < 115 then
            self:setCtrlVisible("JewelryDevelopTabDlgCheckBox", false)
        end
    else
        if Me:queryBasicInt("level") < 115 then
            self:setCtrlVisible("JewelryDevelopTabDlgCheckBox", false)
        end
    end
end

function JewelryTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end
    local name = sender:getName()
    if name == "JewelryChangeTabDlgCheckBox" and Me:queryBasicInt("level") < 110 then
        gf:ShowSmallTips(CHS[4101103])
        return false
    end

    if name == "JewelryDevelopTabDlgCheckBox" and Me:queryBasicInt("level") < 125 then
        gf:ShowSmallTips(string.format( CHS[4200493], 125))
        return false
    end

    return true
end

return JewelryTabDlg
