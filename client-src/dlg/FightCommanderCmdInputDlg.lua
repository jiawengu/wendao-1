-- FightCommanderCmdInputDlg.lua
-- Created by lixh Des/11/2018
-- 战斗指挥指令输入界面

local FightCommanderCmdInputDlg = Singleton("FightCommanderCmdInputDlg", Dialog)

local MAX_INPUT_LEN = 8

function FightCommanderCmdInputDlg:init()
    self:bindListener("DelAllButton", self.onDelAllButton)
    self:bindListener("CancleButton", self.onCancleButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self.editBox = self:createEditBox("InputPanel", nil, nil, function(sender, type) 
        if type == "changed" then
            local str = self.editBox:getText()

            local filtStr, haveFilt = gf:filtText(str, nil, true)
            if haveFilt then
                gf:ShowSmallTips(CHS[7190413])
                self.editBox:setText("")
            end

            if gf:getTextLength(str) > MAX_INPUT_LEN then
                gf:ShowSmallTips(CHS[7190414])
                str = gf:subString(str, MAX_INPUT_LEN)
                self.editBox:setText(str)
            end

            self:setCtrlVisible("DelAllButton", gf:getTextLength(self.editBox:getText()) > 0)
        end
    end)

    self.editBox:setFont(CHS[3003597], 21)
    self.editBox:setPlaceholderFont(CHS[3003597], 21)
    self.editBox:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.editBox:setPlaceHolder(CHS[7190415])
    self.editBox:setFontColor(cc.c3b(76, 32, 0))
    self.editBox:setText("")
    self:setCtrlVisible("DelAllButton", gf:getTextLength(self.editBox:getText()) > 0)
end

function FightCommanderCmdInputDlg:setData(str, callback)
    if str then
        self.editBox:setText(str)
    end

    self.callBack = callback
    self:setCtrlVisible("DelAllButton", gf:getTextLength(self.editBox:getText()) > 0)
end

function FightCommanderCmdInputDlg:onDelAllButton(sender, eventType)
    self.editBox:setText("")
    self:setCtrlVisible("DelAllButton", false)
end

function FightCommanderCmdInputDlg:onCancleButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function FightCommanderCmdInputDlg:onConfrimButton(sender, eventType)
    if self.callBack then
        self.callBack(self.editBox:getText())
    end

    self:onCancleButton(sender,eventType)
end

return FightCommanderCmdInputDlg
