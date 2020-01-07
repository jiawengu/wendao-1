-- WeddingAnniversaryDlg.lua
-- Created by sujl, Apr/10/2018
-- 纪念日增加界面

local DaySelectPanel = require("ctrl/DaySelectPanel")
local Bitset = require('core/Bitset')

local WeddingAnniversaryDlg = Singleton("WeddingAnniversaryDlg", Dialog)

local MSG_LIMIT = 10 * 2

function WeddingAnniversaryDlg:init(param)
    self.param = param
    local day = WeddingBookMgr:getDay(self.param.bookId, self.param.dayId)

    self.chosenImage = self:retainCtrl("ChosenImage", "IconPanel")
    for i = 1, 3 do
        self:getControl("IconButton1", nil, "IconPanel"):removeAllChildren()
    end

    self.nameEdit = self:createEditBox("InputPanel", "NamePanel", nil, function(sender, type)
        if type == "ended" then
        elseif type == "began" then
        elseif type == "changed" then
            local newContent = self.nameEdit:getText()
            if gf:getTextLength(newContent) > MSG_LIMIT then
                newContent = gf:subString(newContent, MSG_LIMIT)
                self.nameEdit:setText(newContent)
                gf:ShowSmallTips(CHS[5400041])
            end

            if gf:getTextLength(newContent) == 0 then
                self:setCtrlVisible("DelButton", false, "NamePanel")
                self:setCtrlVisible("NoneLabel", true, "NamePanel")
            else
                self:setCtrlVisible("NoneLabel", false, "NamePanel")
                self:setCtrlVisible("DelButton", true, "NamePanel")
            end
        end
    end)

    self.nameEdit:setLocalZOrder(1)
    self.nameEdit:setFont(CHS[3003597], 19)
    self.nameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.nameEdit:setText("")
    if day then
        self.nameEdit:setText(day.name)
        local hasText = day.name and #(day.name) > 0
        self:setCtrlVisible("NoneLabel", not hasText, "NamePanel")
        self:setCtrlVisible("DelButton", hasText, "NamePanel")

        local y = gf:getServerDate("*t", day.day_time)["year"]
        local m = gf:getServerDate("*t", day.day_time)["month"]
        local d = gf:getServerDate("*t", day.day_time)["day"]
        self:setLabelText("YearLabel", y, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("MonthLabel", m, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("DayLabel", d, "DayPanel", COLOR3.TEXT_DEFAULT)

        local flag = Bitset.new(day.flag)
        if flag:isSet(1) then
            self:setCheck("MaleCheckBox", true, "MailPanel")
        else
            self:setCheck("MaleCheckBox", false, "MailPanel")
        end

        if flag:isSet(2) then
            self:setCheck("FemaleCheckBox", true, "MailPanel")
        else
            self:setCheck("FemaleCheckBox", false, "MailPanel")
        end

        self:getControl(string.format("IconButton%s", day.icon), nil, "IconPanel"):addChild(self.chosenImage)
    else
        self.nameEdit:setText("")
        self:setCtrlVisible("NoneLabel", true, "NamePanel")

        local dayTime = gf:getServerTime()
        local y = gf:getServerDate("*t", dayTime)["year"]
        local m = gf:getServerDate("*t", dayTime)["month"]
        local d = gf:getServerDate("*t", dayTime)["day"]
        self:setLabelText("YearLabel", y, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("MonthLabel", m, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("DayLabel", d, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:getControl(string.format("IconButton1"), nil, "IconPanel"):addChild(self.chosenImage)
        self:setCheck("MaleCheckBox", true, "MailPanel")
        self:setCheck("FemaleCheckBox", true, "MailPanel")
    end

    self.daySelectPanel = DaySelectPanel.new(self, self:getControl("DayNumPanel"), function(self, y, m, d)
        self:setLabelText("YearLabel", y, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("MonthLabel", m, "DayPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("DayLabel", d, "DayPanel", COLOR3.TEXT_DEFAULT)
    end, "BirthdayConfirmButton", 50, 100)
    self:bindFloatPanelListener("DayNumPanel")

    self:setCtrlVisible("DeleteButton", nil ~= day)

    self:bindListener("DelButton", self.onDelNameButton, "NamePanel")
    self:bindListener("IconButton1", self.onIconButton, "IconPanel")
    self:bindListener("IconButton2", self.onIconButton, "IconPanel")
    self:bindListener("IconButton3", self.onIconButton, "IconPanel")
    self:bindListener("InputPanel1", self.onClickInputPanel, "DayPanel")
    self:bindListener("InputPanel2", self.onClickInputPanel, "DayPanel")
    self:bindListener("InputPanel3", self.onClickInputPanel, "DayPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("DeleteButton", self.onDeleteButton)

    self:hookMsg("MSG_WB_DAY_ADD_RESULT")
    self:hookMsg("MSG_WB_DAY_EDIT_RESULT")
    self:hookMsg("MSG_WB_DAY_DELETE_RESULT")
end

function WeddingAnniversaryDlg:getSelectIcon()
    local iconButton = self.chosenImage:getParent()
    if not iconButton then return end
    local ctlName = iconButton:getName()
    local index = string.match(ctlName, "IconButton(%d)")
    return tostring(index)
end

function WeddingAnniversaryDlg:onDelNameButton(sender, eventType)
    self.nameEdit:setText("")
    self:setCtrlVisible("NoneLabel", true, "NamePanel")
    self:setCtrlVisible("DelButton", false, "NamePanel")
end

function WeddingAnniversaryDlg:onIconButton(sender, eventType)
    if self.chosenImage:getParent() == sender then return end

    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

function WeddingAnniversaryDlg:onClickInputPanel(sender, eventType)
    local y = tonumber(self:getLabelText("YearLabel", "DayPanel"))
    local m = tonumber(self:getLabelText("MonthLabel", "DayPanel"))
    local d = tonumber(self:getLabelText("DayLabel", "DayPanel"))
    local dayTime
    if y and m and d then
        dayTime = os.time({ year = y, month = m, day = d })
    end
    self.daySelectPanel:showPanel(dayTime)
end

function WeddingAnniversaryDlg:onConfirmButton(sender, eventType)
    local icon = self:getSelectIcon()
    local name = self.nameEdit:getText()
    local y = tonumber(self:getLabelText("YearLabel", "DayPanel"))
    local m = tonumber(self:getLabelText("MonthLabel", "DayPanel"))
    local d = tonumber(self:getLabelText("DayLabel", "DayPanel"))
    local dayTime
    if y and m and d then
        dayTime = os.time({ year = y, month = m, day = d, hour = 0 })
    end
    local maleCheck = self:isCheck("MaleCheckBox", "MailPanel")
    local femaleCheck = self:isCheck("FemaleCheckBox", "MailPanel")
    local flag = Bitset.new(0)
    if maleCheck then
        flag:setBit(1, true)
    end

    if femaleCheck then
        flag:setBit(2, true)
    end

    if self.param.dayId then
        local day = WeddingBookMgr:getDay(self.param.bookId, self.param.dayId)
        if not day or (day.name == name and day.day_time == dayTime and day.flag == flag:getI32() and day.icon == icon) then
            -- 没有发生变化
            self:onCloseButton()
            return
        end
    end

    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    if string.isNilOrEmpty(name) then
        gf:ShowSmallTips(CHS[2000476])
        return
    end

    if not dayTime then
        gf:ShowSmallTips(CHS[2000477])
        return
    end

    if not icon then
        gf:ShowSmallTips(CHS[2000478])
        return
    end

    local newName, fitStr = gf:filtText(name)
    if fitStr then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[2000479])
        dlg:setCallFunc(function()
            self.nameEdit:setText(newName)
            gf:ShowSmallTips(CHS[2000480])
            ChatMgr:sendMiscMsg(CHS[2000480])
            Dialog.onCloseButton(dlg)
        end)
        return
    end

    if self.param.dayId then
        -- 修改
        WeddingBookMgr:editDay(self.param.bookId, self.param.dayId, icon, name, dayTime, flag:getI32())
    else
        -- 新增
        WeddingBookMgr:addDay(self.param.bookId, icon, name, dayTime, flag:getI32())
    end

    self:setCtrlEnabled("ConfirmButton", false)
end

function WeddingAnniversaryDlg:onDeleteButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local bookId, dayId = self.param.bookId, self.param.dayId
    gf:confirm(CHS[2000481], function()
        WeddingBookMgr:deleteDay(bookId, dayId)
    end)
end

function WeddingAnniversaryDlg:MSG_WB_DAY_ADD_RESULT(data)
    self:onCloseButton()
end

function WeddingAnniversaryDlg:MSG_WB_DAY_EDIT_RESULT(data)
    self:onCloseButton()
end

function WeddingAnniversaryDlg:MSG_WB_DAY_DELETE_RESULT(data)
    self:onCloseButton()
end

return WeddingAnniversaryDlg