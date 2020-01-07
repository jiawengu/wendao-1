-- WeddingDiaryDlg.lua
-- Created by sujl, Apr/10/2018
-- 日记编辑界面

local WeddingDiaryDlg = Singleton("WeddingDiaryDlg", Dialog)

local MSG_LIMIT = 1000 * 2

function WeddingDiaryDlg:init(param)
    self.param = param
    self.hasShowCfmTip = nil
    local flag = self.param.flag
    local diaryId = self.param.diaryId
    local bookId = self.param.bookId
    local diary
    if bookId and diaryId then
        diary = WeddingBookMgr:getDiary(bookId, diaryId)
    end

    local showMy = 'add' == flag or (diary and WeddingBookMgr:isDiaryEdit(diary.flag))
    self:setCtrlVisible("MyDiaryPanel", showMy)
    self:setCtrlVisible("OtherDiaryPanel", not showMy)

    if showMy then
        self.contentEdit = self:createEditBox("TextPanel", "MyDiaryPanel", nil, function(sender, type)
            if type == "ended" then
                self.contentEdit:setText("")
                self:setCtrlVisible("ContentPanel", true, "TextScrollView")
            elseif type == "began" then
                local msg = self:getColorText("ContentPanel")
                self.contentEdit:setText(msg)
                self:setCtrlVisible("ContentPanel", false, "TextScrollView")
            elseif type == "changed" then
                local newContent = self.contentEdit:getText()
                if gf:getTextLength(newContent) > MSG_LIMIT then
                    newContent = gf:subString(newContent, MSG_LIMIT)
                    self.contentEdit:setText(newContent)
                    gf:ShowSmallTips(CHS[5400041])
                end

                if gf:getTextLength(newContent) == 0 then
                    self:setCtrlVisible("DelButton", false)
                    self:setCtrlVisible("NoneLabel", true)
                else
                    self:setCtrlVisible("NoneLabel", false)
                    self:setCtrlVisible("DelButton", true)
                end

                self:setPanelText(newContent, "ContentPanel", "TextScrollView", "MyDiaryPanel")

--                local leftNum = math.floor((MSG_LIMIT - gf:getTextLength(newContent)) / 2)
--                self:setLabelText("NoticeLabel", string.format(CHS[2000502], leftNum))
            end
        end)

        self.contentEdit:setLocalZOrder(1)
        self.contentEdit:setFont(CHS[3003597], 19)
        self.contentEdit:setFontColor(cc.c3b(76, 32, 0))
        self.contentEdit:setText("")
        if not diary or not diary.content then
            self:setPanelText("", "ContentPanel", "TextScrollView", "MyDiaryPanel")
            self:setCtrlVisible("NoneLabel", true, "MyDiaryPanel")
            self:setCheck("ChoseCheckBox", false, "MyDiaryPanel")
        else
            self:setPanelText(diary.content, "ContentPanel", "TextScrollView", "MyDiaryPanel")
            self:setCtrlVisible("NoneLabel", false, "MyDiaryPanel")
            self:setCheck("ChoseCheckBox", diary.view == 1, self:getControl("SeePanel", nil, "MyDiaryPanel"))
            self:setCheck("ChoseCheckBox", diary.view == 2, self:getControl("SeeCouplePanel", nil, "MyDiaryPanel"))

--            local leftNum = math.floor((MSG_LIMIT - gf:getTextLength(diary.content)) / 2)
--            self:setLabelText("NoticeLabel", string.format(CHS[2000502], leftNum))
        end
    else
        -- 此处需要添加滚动支持，目前json不支持
        -- self:setLabelText("TextLabel", string.format(CHS[2000500], WeddingBookMgr:getCoupleName(self.param.bookId)), self:getControl("BKPanel", nil , "OtherDiaryPanel"))
        self:setPanelText(diary.content, "ContentPanel", "TextScrollView", "OtherDiaryPanel")
        self:setLabelText("NoticeLabel", string.format(CHS[2000490], os.date("%Y-%m-%d %H:%M:%S", diary.last_edit_time)), "OtherDiaryPanel")
        self:setLabelText("EstablishLabel", string.format(CHS[4101267], os.date("%Y-%m-%d %H:%M:%S", diary.create_time)), "OtherDiaryPanel")
    end

    self:setCtrlVisible("DeleteButton", showMy and 'add' ~= flag, "MyDiaryPanel")
    self:bindScrollView()

    self:bindListener("CloseButton", self.onCloseButton, "MyDiaryPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton, "MyDiaryPanel")
    self:bindListener("DeleteButton", self.onDeleteButton, "MyDiaryPanel")
    self:bindListener("CloseButton", self.onCloseButton, "OtherDiaryPanel")
    -- self:bindListener("TextScrollView", self.onClickTextView, "MyDiaryPanel")
    self:bindCheckBoxListener("ChoseCheckBox", self.onChoseCheckBox, self:getControl("SeePanel", nil, "MyDiaryPanel"))
    self:bindCheckBoxListener("ChoseCheckBox", self.onChoseCoupleCheckBox, self:getControl("SeeCouplePanel", nil, "MyDiaryPanel"))

    self:hookMsg("MSG_WB_DIARY_ADD_RESULT")
    self:hookMsg("MSG_WB_DIARY_EDIT_RESULT")
    self:hookMsg("MSG_WB_DIARY_DELETE_RESULT")
end

function WeddingDiaryDlg:cleanup()
    self.hasShowCoupleTip = nil
    self.hasShowCfmTip = nil
end

function WeddingDiaryDlg:bindScrollView()
    local clickTime
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            clickTime = gf:getTickCount()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if clickTime and gf:getTickCount() - clickTime < 200 then
                self:onClickTextView()
            end
        end
    end

    local ctrl = self:getControl("TextScrollView", nil, "MyDiaryPanel")
    ctrl:setVisible(true)
    ctrl:addTouchEventListener(listener)
end

function WeddingDiaryDlg:setPanelText(text, panelName, svName, root)
    local panel = self:getControl(panelName, nil, root)
    panel:setAnchorPoint(cc.p(0, 1))
    panel:setVisible(true)
    self:setColorText(text, panelName, root, 5, 10, nil, 21)
    local panelSize = panel:getContentSize()
    local scrollView = self:getControl(svName, nil, root)
    scrollView:setInnerContainerSize(panelSize)
    if panelSize.height < scrollView:getContentSize().height then
        panel:setPositionY(scrollView:getContentSize().height - panelSize.height)
    else
        panel:setPositionY(0)
    end
end

function WeddingDiaryDlg:onChoseCheckBox(sender, eventType)
    local panel = self:getControl("SeePanel", nil, "MyDiaryPanel")
    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        self:setCheck("ChoseCheckBox", not self:isCheck("ChoseCheckBox", panel), panel)
        return
    end

    if self:isCheck("ChoseCheckBox", panel) then
        if not self.hasShowCfmTip then
            gf:confirm(CHS[2000491], function()
                self:setCheck("ChoseCheckBox", false, self:getControl("SeeCouplePanel", nil, "MyDiaryPanel"))
            end, function()
                self:setCheck("ChoseCheckBox", not self:isCheck("ChoseCheckBox", panel), panel)
            end)
            self.hasShowCfmTip = true
        else
            self:setCheck("ChoseCheckBox", false, self:getControl("SeeCouplePanel", nil, "MyDiaryPanel"))
        end
    end
end

function WeddingDiaryDlg:onChoseCoupleCheckBox(sender, eventType)
    local panel = self:getControl("SeeCouplePanel", nil, "MyDiaryPanel")
    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        self:setCheck("ChoseCheckBox", not self:isCheck("ChoseCheckBox", panel), panel)
        return
    end

    if self:isCheck("ChoseCheckBox", panel) then
        if not self.hasShowCoupleTip then
            gf:showTipAndMisMsg(CHS[2100161])
            self.hasShowCoupleTip = true
        end

        self:setCheck("ChoseCheckBox", false, self:getControl("SeePanel", nil, "MyDiaryPanel"))
    end
end

function WeddingDiaryDlg:onDeleteButton(sender, eventType)
--    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
--        gf:ShowSmallTips(CHS[2000475])
--        return
--    end

    local bookId, diaryId = self.param.bookId, self.param.diaryId
    gf:confirm(CHS[2000492], function()
        WeddingBookMgr:deleteDiary(bookId, diaryId)
    end)
end

function WeddingDiaryDlg:onClickTextView(sender, eventType)
    if self.contentEdit then
        self.contentEdit:openKeyboard()
    end
end

function WeddingDiaryDlg:onConfirmButton(sender, eventType)
    local content = self:getColorText("ContentPanel")
    local selfView = self:isCheck("ChoseCheckBox", self:getControl("SeePanel", nil, "MyDiaryPanel"))
    local coupleView = self:isCheck("ChoseCheckBox", self:getControl("SeeCouplePanel", nil, "MyDiaryPanel"))
    if self.param.bookId and self.param.diaryId then
        local diary = WeddingBookMgr:getDiary(self.param.bookId, self.param.diaryId)
        local diaryView = diary.view == 1

        if diary.content == content and diaryView == view then
            -- 未发生变化
            self:onCloseButton()
            return
        end
    end

    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[2000493])
        return
    end

    local newContent, fitStr = gf:filtText(content)
    if fitStr then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[2000479])
        dlg:setCallFunc(function()
            self:setColorText(newContent, "ContentPanel")
            gf:ShowSmallTips(CHS[2000480])
            ChatMgr:sendMiscMsg(CHS[2000480])
            Dialog.onCloseButton(dlg)
        end)
        return
    end

    local viewFlag = selfView and 1 or (coupleView and 2 or 0)

    if self.param.diaryId then
        WeddingBookMgr:editDiary(self.param.bookId, self.param.diaryId, content, viewFlag)
    else
        WeddingBookMgr:addDiary(self.param.bookId, content, viewFlag)
    end
end

-- 增加日记结果
function WeddingDiaryDlg:MSG_WB_DIARY_ADD_RESULT(data)
    self:onCloseButton()
end

-- 编辑日记结果
function WeddingDiaryDlg:MSG_WB_DIARY_EDIT_RESULT(data)
    self:onCloseButton()
end

-- 删除日记结果
function WeddingDiaryDlg:MSG_WB_DIARY_DELETE_RESULT(data)
    self:onCloseButton()
end

return WeddingDiaryDlg
