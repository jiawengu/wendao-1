-- CaseCipherDlg.lua
-- Created by lixh May/25/2018
-- 探案-对暗号界面

local CaseCipherDlg = Singleton("CaseCipherDlg", Dialog)

function CaseCipherDlg:init()
    self:bindListener("CleanTextButton", self.onCleanTextButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindEditFieldForSafe("MainPanel", 20, "CleanTextButton", cc.TEXT_ALIGNMENT_LEFT, nil, true)

    -- 有缓存数据
    if self.lastText and self.lastText ~= "" then
        self:setInputText("TextField", self.lastText, "MainPanel")
        self:getControl("CleanTextButton"):setVisible(true)
        self:setCtrlVisible("DefaultLabel", false)
    end
end

function CaseCipherDlg:onCleanTextButton(sender, eventType)
    local panel = self:getControl("MainPanel")
    self:setInputText("TextField", "", panel)
    self:getControl("CleanTextButton"):setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

function CaseCipherDlg:onConfrimButton(sender, eventType)
    gf:confirm(CHS[7190237], function()
        local text = self:getInputText("TextField", "MainPanel")
        gf:CmdToServer("CMD_RKSZ_ANSWER_CODE", {code = text})
        
        -- 缓存数据在每次确认后清除
        self.lastText = nil
    
        self:onCloseButton(nil, nil, true)
    end)
end

function CaseCipherDlg:onCloseButton(sender, eventType, notSafeText)
    if not notSafeText then
        self.lastText = self:getInputText("TextField", "MainPanel")
    end

    DlgMgr:closeDlg(self.name)
end

return CaseCipherDlg
