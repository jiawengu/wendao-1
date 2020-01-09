-- AnniversaryTabDlg.lua
-- Created by songcw
-- 周年庆标签界面

local TabDlg = require('dlg/TabDlg')
local AnniversaryTabDlg = Singleton("AnniversaryTabDlg", TabDlg)


-- 按钮与对话框的映射表
AnniversaryTabDlg.dlgs = {
    DLLBCheckBox = "AnniversaryRewardDlg",          -- 登录礼包
    CWMXCheckBox = "AnniversaryPetAdventureDlg",         -- 驯养灵猫
    LCFPCheckBox = "AnniversaryPetCardDlg",--"AnniversaryCatCardDlg",         -- 灵猫翻牌
    ZNLBCheckBox = "AnniversaryGiftDlg",            -- 周年礼包
    GDJCCheckBox = "AnniversaryOtherDlg",           -- 更多精彩
}

AnniversaryTabDlg.orderList = {
    ["DLLBCheckBox"] = 1,
    ["CWMXCheckBox"] = 2,
    ["LCFPCheckBox"] = 3,
    ["ZNLBCheckBox"] = 4,
    ["GDJCCheckBox"] = 5,
}

function AnniversaryTabDlg:init()
    TabDlg.init(self)

    self.scrollCtrl = self:getControl("AnniversaryScrollView")

    if RedDotMgr:hasRedDotInfoByDlgName("SystemFunctionDlg", "AnniversaryButton") then
        RedDotMgr:removeOneRedDot("SystemFunctionDlg", "AnniversaryButton")
    end

end

local AUTO_SCROLL_TIME = 0.3

-- 调整 ScrollView 滚动的位置
function AnniversaryTabDlg:setScrollViewLocation(sender)
    local idx = self.orderList[sender:getName()]
    local scrollY = self.scrollCtrl:getInnerContainer():getPositionY()
    local labelSize = sender:getContentSize()
    local senderHeight = idx * labelSize.height
    local scrollHeight = self.scrollCtrl:getInnerContainer():getContentSize().height - self.scrollCtrl:getContentSize().height
    if scrollHeight + scrollY + self.scrollCtrl:getContentSize().height < senderHeight - idx * 2 then
        -- 向上滑
        local percent = (senderHeight - self.scrollCtrl:getContentSize().height - idx * 2) / (scrollHeight) * 100
        self.scrollCtrl:scrollToPercentVertical(percent, AUTO_SCROLL_TIME, false)
    elseif senderHeight - labelSize.height < scrollHeight + scrollY then
        -- 向下滑
        local percent = (senderHeight - labelSize.height) / (scrollHeight) * 100
        self.scrollCtrl:scrollToPercentVertical(percent, AUTO_SCROLL_TIME, false)
    end
end

function AnniversaryTabDlg:onPreCallBack(sender, idx)
    if not sender then
        return true
    end

    if DlgMgr:sendMsg("AnniversaryPetCardDlg", "getGameisRunning") then
        if sender:getName() ~= "LMFPCheckBox" then
            gf:ShowSmallTips(CHS[4010243])
        end
        return
    end

    -- local name = sender:getName()

    --[[if name == "XYLMCheckBox" and not DlgMgr:getDlgByName("AnniversaryLingMaoDlg") then
        AnniversaryMgr:tryOpenLingMaoDlg()
        return false
    end]]

    self:setScrollViewLocation(sender)

    return true
end

return AnniversaryTabDlg
