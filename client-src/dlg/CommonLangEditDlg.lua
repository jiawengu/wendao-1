-- CommonLangEditDlg.lua
-- Created by zhengjh Apr/9/2015
-- 常用编辑

local STRING_LIMIT = 10

local CommonLangEditDlg = Singleton("CommonLangEditDlg", Dialog)

function CommonLangEditDlg:init()
    self:bindListener("DefaultButton", self.onDefaultButton)
    self:bindListener("SaveButton", self.onSaveButton)
    self.textFiledList = {}

    self:setFullScreen()

    self.selectEff = self:getControl("Image"):clone()
    self.selectEff:setVisible(true)
    self.selectEff:retain()

    self.delButton = self:getControl("DelAllButton"):clone()
    self.delButton:setVisible(true)
    self.delButton:retain()
    self:bindTouchEndEventListener(self.delButton, self.onDelAllButton)

    self.pickNum = 1
    for i = 1, 8 do
        local panel = self:getControl(string.format("Panel_%d",i), Const.UIPanel)
        local textField = self:getControl("TextField", Const.UITextField, panel)
        textField:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        textField:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)
        textField:setTag(i)
        panel:setTag(i)
        table.insert(self.textFiledList, textField)

        self:bindEditField(string.format("Panel_%d",i), STRING_LIMIT, "DelAllButton")
    end

    self:setDailyWord()
end

function CommonLangEditDlg:cleanup()
    self:releaseCloneCtrl("delButton")
    self:releaseCloneCtrl("selectEff")
end

function CommonLangEditDlg:getSelectEff()
    self.selectEff:removeFromParent(false)
    return self.selectEff
end

function CommonLangEditDlg:getDelButton()
    self.delButton:removeFromParent(false)
    return self.delButton
end

function CommonLangEditDlg:onDelAllButton()

    local panel = self:getControl(string.format("Panel_%d", self.pickNum), Const.UIPanel)
    self:setInputText("TextField", "", panel)
    self:getDelButton()
end

function CommonLangEditDlg:bindEditField(parentPanelName, lenLimit, clenButtonName)

    local namePanel = self:getControl(parentPanelName)
    local textCtrl = self:getControl("TextField", nil, namePanel)
    self:setCtrlVisible(clenButtonName, false, namePanel)
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.attach_with_ime == eventType then
            local panel = textCtrl:getParent()
            self.pickNum = panel:getTag()
            panel:addChild(self:getSelectEff())
            local str = textCtrl:getStringValue()
            if str ~= "" then
                panel:addChild(self:getDelButton())
            end
        elseif ccui.TextFiledEventType.detach_with_ime == eventType then

        elseif ccui.TextFiledEventType.insert_text == eventType then
            local str = textCtrl:getStringValue()
            if str ~= "" then
                local panel = textCtrl:getParent()
                panel:addChild(self:getDelButton())
            end
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end

            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空,如果将来需要有清空输入按钮
            local str = textCtrl:getStringValue()
            if str == "" then
                self:getDelButton()
            end
        end
    end)
end


function CommonLangEditDlg:onDefaultButton(sender, eventType)
   local defaultWord =  ChatMgr:getDefaultDailyWord()
    for i = 1, #self.textFiledList do
        self.textFiledList[i]:setText(defaultWord[i])
    end
    ChatMgr:setDailyWord(defaultWord)
    DlgMgr:sendMsg("LinkAndExpressionDlg", "setDailyWord")
end

function CommonLangEditDlg:onSaveButton(sender, eventType)
    local dailyWord = {}
    for i = 1, #self.textFiledList do
        dailyWord[i] =  self.textFiledList[i]:getStringValue()
    end

    ChatMgr:setDailyWord(dailyWord)
    DlgMgr:closeDlg(self.name)
    DlgMgr:sendMsg("LinkAndExpressionDlg", "setDailyWord")
end

function CommonLangEditDlg:setDailyWord()
    local dailyWord = ChatMgr:getDailyWord()
    for i = 1, #self.textFiledList do
        self.textFiledList[i]:setText(dailyWord[i])
    end
end

function CommonLangEditDlg:checkStringLength(textField)
    local text = textField:getStringValue()
    local len = string.len(text)
    local leftString = text
    local filterStr = ""
    local index = 1

    while  gf:getTextLength(filterStr) <= STRING_LIMIT and index <= len do
        local byteValue = string.byte(text, index)
        if byteValue < 128 then

            filterStr = filterStr..string.sub(text, index, index)
            index = index + 1
        elseif byteValue >= 192 and byteValue < 224 then
            index = index + 2
        elseif  byteValue >= 224 and byteValue <= 239 then
            if gf:getTextLength(filterStr..string.sub(text, index, index + 2)) > STRING_LIMIT then
                break
            else
                filterStr = filterStr..string.sub(text, index, index + 2)
                index = index + 3
            end
        end
    end

    if gf:getTextLength(filterStr) > STRING_LIMIT then
        gf:ShowSmallTips(CHS[4000224])
    end
    textField:setText(tostring(filterStr))
end



return CommonLangEditDlg
