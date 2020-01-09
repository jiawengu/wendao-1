-- UsefulPhraseEditorDlg.lua
-- Created by lixh Mar/16/2018
-- 常用短语编辑界面

local UsefulPhraseEditorDlg = Singleton("UsefulPhraseEditorDlg", Dialog)

-- 最长汉字个数
local LIMIT_WORD = 30

function UsefulPhraseEditorDlg:init(data)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindEditFieldForSafe("InputPanel", LIMIT_WORD, "DelButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, 160)

    self.tag = data.tag
    self:setInputText("TextField", data.str)
    self:setCtrlVisible("DelButton", gf:getTextLength(data.str) > 0)
end

function UsefulPhraseEditorDlg:onDelButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
end

function UsefulPhraseEditorDlg:onSendButton(sender, eventType)
    local text = self:getInputText("TextField") or ""

    UsefulWordsMgr:setUsefulWordsData(self.tag, text)

    self:onCloseButton()
end

function UsefulPhraseEditorDlg:cleanup()
    self.tag = nil
end

return UsefulPhraseEditorDlg
