-- WeddingPhotoDlg.lua
-- Created by sujl, Apr/10/2018
-- 相片上传界面

local WeddingPhotoDlg = Singleton("WeddingPhotoDlg", Dialog)

local MSG_LIMIT = 50 * 2
local UPLOAD_FILE_SIZE = 3 * 1024 * 1024    -- Unit:MB

function WeddingPhotoDlg:init(param)
    self.param = param
    local photo
    if self.param.photoId then
        photo = WeddingBookMgr:getPhoto(self.param.bookId, self.param.photoId)
    end

    self.contentEdit = self:createEditBox("TextPanel", nil, nil, function(sender, type)
        if type == "ended" then
            self.contentEdit:setText("")
            self:setCtrlVisible("ContentLabel", true)
        elseif type == "began" then
            local msg = self:getLabelText("ContentLabel")
            self.contentEdit:setText(msg)
            self:setCtrlVisible("ContentLabel", false)
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

            self:setLabelText("ContentLabel", newContent)

            local leftNum = math.floor((MSG_LIMIT - gf:getTextLength(newContent)) / 2)
            self:setLabelText("NoticeLabel", string.format(CHS[2000502], leftNum))
        end
    end)

    self.contentEdit:setLocalZOrder(1)
    self.contentEdit:setFont(CHS[3003597], 19)
    self.contentEdit:setFontColor(cc.c3b(76, 32, 0))
    self.contentEdit:setText("")
    if photo then
        self:setLabelText("ContentLabel", photo.memo)
        self:setCtrlVisible("PhotoImage", true, "PhotoPanel")
        -- self:pickImageDone(photo.img)
        self:setCtrlVisible("NoneLabel", false)
        self:setCtrlVisible("TextLabel", false, "PhotoPanel")
        BlogMgr:assureFile("pickImageDone", self.name, photo.img)

        local leftNum = math.floor((MSG_LIMIT - gf:getTextLength(photo.memo)) / 2)
        self:setLabelText("NoticeLabel", string.format(CHS[2000502], leftNum))
        self:setCheck("ChoseCheckBox", photo.showFlag == 0, "SeeCouplePanel")
    else
        self:setLabelText("ContentLabel", "")
        self:setCtrlVisible("PhotoImage", false, "PhotoPanel")
        self:setCtrlVisible("NoneLabel", true)
        self:setCtrlVisible("TextLabel", true, "PhotoPanel")
    end
    self:setCtrlVisible("ProgressPanel", false, "PhotoPanel")
    self:setCtrlVisible("SeeCouplePanel", WeddingBookMgr:isOwner(self.param.bookId))

    self:bindListener("PhotoPanel", self.onSelectPhoto)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindCheckBoxListener("ChoseCheckBox", self.onChoseCheckBox, "SeeCouplePanel")

    self:hookMsg("MSG_WB_PHOTO_COMMIT_RESULT")
    self:hookMsg("MSG_WB_PHOTO_EDIT_MEMO_RESULT")
end

function WeddingPhotoDlg:cleanup()
    self.filePath = nil
    self.hasShowTip = nil
end

function onWeddingPhotoDlgSelectPhoto(filePath)
    DlgMgr:sendMsg("WeddingPhotoDlg", "doSelectPhoto", filePath)
end

function WeddingPhotoDlg:doSelectPhoto(filePath)
    if string.isNilOrEmpty(filePath) then return end

    filePath = string.trim(string.gsub(filePath, "\\/", "/"))
    local s = string.sub(filePath, 1, 1)
    if '{' == s then
        local data = json.decode(filePath)
        if 'size' ==  data.action then
            return json.encode(BlogMgr:getPhotoScaleSize(960, 640, data.width, data.height))
        elseif 'save' == data.action then
            filePath = data.path
        else
            return
        end
    end

    self:pickImageDone(filePath)
end

function WeddingPhotoDlg:pickImageDone(file)
    local f = io.open(file, 'rb')
    local data = f:read("*a")
    f:close()

    if #data > UPLOAD_FILE_SIZE then
        gf:ShowSmallTips(CHS[2100132])
        return
    end

    self:setImage("PhotoImage", file, "PhotoPanel")
    self:setSmallImageSize("PhotoImage", "PhotoPanel")

    self:setCtrlVisible("PhotoImage", true, "PhotoPanel")

    self.filePath = file
end

function WeddingPhotoDlg:setSmallImageSize(imageName, panel)
    local image = self:getControl(imageName, nil, panel)
    local orgSize = image:getContentSize()
    local w1 = orgSize.width
    local h1 = orgSize.height
    local w2 = 186
    local h2 = 146

    if w1 / h1 > w2 / h2 then
        self:setImageSize(imageName, cc.size(w1 * h2 / h1, h2), panel)
    else
        self:setImageSize(imageName, cc.size(w2, h1 * w2 / w1), panel)
    end

end

function WeddingPhotoDlg:onSelectPhoto(sender, eventType)
    if self.param.flag == 'add' then
        local dlg = BlogMgr:showButtonList(self, sender, "blogStateSel", self.name)
        local x, y = dlg.root:getPosition()
        local curPos = GameMgr.curTouchPos
        dlg:setFloatingFramePos(cc.rect(curPos.x, curPos.y, 0, 0))
    end
end

function onPickWeddingPhoto(filePath)
    DlgMgr:sendMsg("WeddingPhotoDlg", "doSelectPhoto", filePath)
end

function WeddingPhotoDlg:onSelectPhote(sender, state)
    local cw, ch = gf:getPortraitClipRange(72, 48)
    gf:comDoOpenPhoto(state, "onPickWeddingPhoto", cc.size(cw, ch), cc.size(756, 504), 80, true)
end

function WeddingPhotoDlg:onConfirmButton(sender, eventType)
    if 'add' == self.param.flag and string.isNilOrEmpty(self.filePath) then
        gf:ShowSmallTips(CHS[2000494])
        return
    end

    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local content = self:getLabelText("ContentLabel")
    local flag = self:isCheck("ChoseCheckBox", "SeeCouplePanel") and 0 or 1
    local newContent, fitStr = gf:filtText(content)
    if fitStr then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[2000479])
        dlg:setCallFunc(function()
            self:setLabelText("ContentLabel", newContent)
            gf:showTipAndMisMsg(CHS[2000480])
            Dialog.onCloseButton(dlg)
        end)
        return
    end

    if 'add' == self.param.flag then
        BlogMgr:cmdUpload(BLOG_OP_TYPE.WE_OP_PHOTO, "WeddingPhotoDlg", "onFinishUploadPhoto", self.filePath)
        self:setProgressBar("ProgressBar", 0, 100, self:getControl("ProgressPanel", nil, "PhotoPanel"))
        self:setCtrlVisible("ProgressPanel", true, "PhotoPanel")
        self:setProgressBarByHourglassToEnd("ProgressBar", 2000, 0, 80, nil, self:getControl("ProgressPanel", nil, "PhotoPanel"))
        self:makeEditEnabled(false)
        self:setCtrlEnabled("ConfirmButton", false)
    else
        WeddingBookMgr:editPhoto(self.param.bookId, self.param.photoId, self:getLabelText("ContentLabel"), flag)
        self:setCtrlEnabled("ConfirmButton", false)
    end
end

function WeddingPhotoDlg:onFinishUploadPhoto(files, uploads)
    if #files ~= #uploads then
        gf:showTipAndMisMsg(CHS[2000503])
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel")
        self:setCtrlEnabled("ConfirmButton", true)
        self:makeEditEnabled(true)
        return
    end

    local panel = self:getControl("ProgressPanel", nil, "PhotoPanel")
    local bar = self:getControl("ProgressBar", nil, panel)
    bar:stopAllActions()
    local curValue = bar:getPercent()
    self:setProgressBarByHourglassToEnd("ProgressBar", 300, curValue, 100, function ()
        self:setCtrlVisible("ProgressPanel", false, panel)
        WeddingBookMgr:addPhoto(self.param.bookId, uploads[1], self:getLabelText("ContentLabel"), self:isCheck("ChoseCheckBox", "SeeCouplePanel") and 0 or 1)
    end, panel)
end

function WeddingPhotoDlg:hideProssBar()
    self:setCtrlVisible("ProgressPanel", false, "PhotoPanel")
end

function WeddingPhotoDlg:makeEditEnabled(enble)
    if enble then
        local layer = self:getControl("MaskPanel", nil, "MainPanel")
        if layer then layer:removeFromParent() end
        return
    end

    local layer = ccui.Layout:create()

    layer:setContentSize(self:getCtrlContentSize("TextPanel"))
    layer:setTouchEnabled(true)

    local x, y = self:getControl("TextPanel"):getPosition()
    layer:setLocalZOrder(100000000)
    layer:setPosition(x, y)
    layer:setName("MaskPanel")
    self:getControl("MainPanel"):addChild(layer)
    self:getControl("MainPanel"):setLayoutType(ccui.LayoutType.ABSOLUTE)

    self:updateLayout("MainPanel")
end

-- 勾选仅夫妻可见
function WeddingPhotoDlg:onChoseCheckBox(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.param.bookId) then
        gf:ShowSmallTips(CHS[2000475])
        self:setCheck("ChoseCheckBox", not self:isCheck("ChoseCheckBox", "SeeCouplePanel"), "SeeCouplePanel")
        return
    end

    if self:isCheck("ChoseCheckBox", "SeeCouplePanel") and not self.hasShowTip then
        gf:showTipAndMisMsg(CHS[2100162])
        self.hasShowTip = true
    end
end

function WeddingPhotoDlg:MSG_WB_PHOTO_COMMIT_RESULT(data)
    if data.flag == 1 then
        self:onCloseButton()
    else
        self:setCtrlEnabled("ConfirmButton", true)
    end
end

function WeddingPhotoDlg:MSG_WB_PHOTO_EDIT_MEMO_RESULT(data)
    if data.flag == 1 then
        self:onCloseButton()
    else
        self:setCtrlEnabled("ConfirmButton", true)
    end
end

return WeddingPhotoDlg