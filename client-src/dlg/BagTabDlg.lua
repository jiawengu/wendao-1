-- BagTabDlg.lua
-- Created by zhengjh Aug/5/2015
-- 背包标签页

local TabDlg = require('dlg/TabDlg')
local BagTabDlg = Singleton("BagTabDlg", TabDlg)

-- 按钮与对话框的映射表
BagTabDlg.dlgs = {
    BagDlgCheckBox = "BagDlg",
    StoreItemDlgCheckBox = "StoreItemDlg",
    AlchemyDlgCheckBox = "AlchemyDlg",
    EquipmentIdentifyDlgCheckBox = "EquipmentIdentifyDlg",
    ChangeCardDlgCheckBox = "ChangeCardBagDlg",
}

local DEF_TIME = (60 * 2 +30) * 1000

local BAG_POS = {
    [1] = 0,
    [2] = -397.69,
    [3] = -795.94,
    [4]= -1194,
    [5] = -1591.3,
}

function BagTabDlg:init()
    self.openTime = gfGetTickCount()
    TabDlg.init(self)
end

function BagTabDlg:cleanup()
    self.isOper = false
end

function BagTabDlg:getOpenDefaultDlg()
    return TabDlg.getOpenDefaultDlg(self) or "BagDlg"
end

function BagTabDlg:setLastDlgInfo(lastDlg, para)
    self.lastBagDlg = lastDlg
    self.lastPara = para
end

function BagTabDlg:onSelected(sender, idx)

    TabDlg.onSelected(self, sender, idx)
    
    
    local curDlgName = self:getCurSelect()    
    
    if curDlgName == "BagDlg" or curDlgName == "StoreItemDlg" then
        local curDlg = DlgMgr:getDlgByName(curDlgName)
        if curDlg.setBagIndex and BAG_POS[self.lastPara] then
            curDlg:setBagIndex(BAG_POS[self.lastPara], self.lastPara)
        end
    --[[
        if self.lastBagDlg and self.lastBagDlg ~= curDlgName then
            local curDlg = DlgMgr:getDlgByName(curDlgName)
            if curDlg.setBagIndex and BAG_POS[self.lastPara] then
                curDlg:setBagIndex(BAG_POS[self.lastPara], self.lastPara)
            end
        end
        --]]
    end

end

return BagTabDlg
