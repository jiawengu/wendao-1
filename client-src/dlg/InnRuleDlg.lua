-- InnRuleDlg.lua
-- Created by lixh Api/20/2018
-- 客栈规则介绍界面

local InnRuleDlg = Singleton("InnRuleDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

local TYPE_CHECKBOS = {
    "InstructionsCheckBox",
    "RuleCheckBox",
}

local DISPLAY_PANEL = {
    InstructionsCheckBox    = "ScrollView",
    RuleCheckBox            = "RuleScrollView",
}

function InnRuleDlg:init()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, TYPE_CHECKBOS, self.onCheckBox)
    self.radioGroup:selectRadio(1)

    InnMgr:hideOrShowInnMainDlg(false)
end

function InnRuleDlg:onDlgOpened(type)
    if type[1] == "rule" then
        self.radioGroup:selectRadio(2)
    elseif type[1] == "operate" then
        self.radioGroup:selectRadio(1)

        -- 首次进入客栈，服务器通知打开界面，增加此光效
        DlgMgr:sendMsg("InnMainDlg", "addWaitGuestBtnMagic")
    end
end

function InnRuleDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panelName, false)
    end

    self:setCtrlVisible(DISPLAY_PANEL[sender:getName()], true)
end

function InnRuleDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    InnMgr:hideOrShowInnMainDlg(true)
end

return InnRuleDlg
