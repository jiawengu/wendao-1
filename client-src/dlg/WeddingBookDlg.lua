-- WeddingBookDlg.lua
-- Created by sujl, Apr/3/2018
-- 结婚纪念册

local WeddingBookDlg = Singleton("WeddingBookDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local Bitset = require('core/Bitset')
local DEFAULT_COVER = ResMgr.ui.defaut_wedddingbook_cover
local PHOTO_SMALL_SIZE_STR = "image/resize,w_144"
local reInitRadioTime = 90 -- 2min30sec
local NUM_LIMIT = 300
local NUM_LIMIT_DAY = 20

local radioToPanel = {
    ["CoverCheckBox"]           = "CoverPanel",
    ["PhotoAlbumrCheckBox"]     = "PhotoAlbumPanel",
    ["DiaryCheckBox"]           = "DiaryPanel",
    ["AnniversaryCheckBox"]     = "AnniversaryPanel",
}

local chatChannelToCheckBox = {
    [CHAT_CHANNEL.CURRENT] = "CurrentCheckBox",
    [CHAT_CHANNEL.WORLD] = "WorldCheckBox",
    [CHAT_CHANNEL.PARTY] = "PartyCheckBox",
    [CHAT_CHANNEL.TEAM] = "TeamCheckBox",
}

function WeddingBookDlg:init(id)
    self.id = id

    local checkboxes = {}
    for k, v in pairs(radioToPanel) do
        table.insert(checkboxes, k)
        self:setCtrlVisible(v, false)
    end

    -- 纪念册通用
    self:bindListener("ShareButton", self.onShareButton, "DayPanel")

    -- 封面
    self:bindListener("LoadingPanel", self.onClickLoadingPanel, "CoverPanel")
    self:blindLongPress("PhotoImage", self.onLongClickPhotoImage, self.onClickPhotoImage, "CoverPanel")
    self:setCtrlTouchEnabled("PhotoImage", not WeddingBookMgr:isOwner(self.id), "CoverPanel")

    -- 相册
    self.onePhotoPanel = self:retainCtrl("OnePhotoPanel", "PhotoAlbumPanel")
    -- self:bindTouchEndEventListener(self.onePhotoPanel, self.onClickPhoto)
    self:blindLongPress(self.onePhotoPanel, self.onLongClickPhoto, self.onClickPhoto, "PhotoAlbumPanel")

    -- 日记
    self.oneDiaryPanel = self:retainCtrl("OneDiaryPanel", "DiaryPanel")

    -- 纪念日
    self.oneDayPanel = self:retainCtrl("OneDayPanel", "AnniversaryPanel")
    self:bindCheckBoxListener("MaleCheckBox", self.onItemMaleCheck, self.oneDayPanel)
    self:bindCheckBoxListener("FemaleCheckBox", self.onItemFemaleCheck, self.oneDayPanel)
    self:bindListener("EditButton", self.onItemEditButton, self.oneDayPanel)

    self:bindListener("PhotoButton", self.onCoverPhotoButton, "CoverPanel")
    self:bindListener("AddButton", self.onAddPhotoAlbumrButton, "PhotoAlbumPanel")
    self:bindListener("AddButton", self.onAddDiaryButton, "DiaryPanel")
    self:bindListener("AddButton", self.onAddAnniversaryButton, "AnniversaryPanel")

    -- 日记
    self:bindListener("EditButton", self.onDiaryEditButton, self.oneDiaryPanel)
    self:bindListener("LookButton", self.onDiaryLookButton, self.oneDiaryPanel)
    self:bindListener("LockButton", self.onDiaryLockButton, self.oneDiaryPanel)

    -- 分页请求处理

    -- 日记
    local dirayDelayRequest
    self:bindListViewByPageLoad("DiaryListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            if dirayDelayRequest then
                self.root:stopAction(dirayDelayRequest)
            end
            dirayDelayRequest = performWithDelay(self.root, function()
                local nextPage = WeddingBookMgr:getNextDiaryPage(self.id)
                if nextPage then
                    WeddingBookMgr:openDiarySummary(self.id, nextPage)
                end
                dirayDelayRequest = nil
            end, 0.5)
        elseif percent == 0 then
        elseif percent < 0 then
        end
    end, "DiaryPanel")

    -- 相册
    local photoDelayRequest
    self:bindListViewByPageLoad("PhotoScrollView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            if photoDelayRequest then
                self.root:stopAction(photoDelayRequest)
            end
            photoDelayRequest = performWithDelay(self.root, function()
                local nextPage = WeddingBookMgr:getNextPhotoPage(self.id)
                if nextPage then
                    WeddingBookMgr:openPhotoSummary(self.id, nextPage)
                end
                photoDelayRequest = nil
            end, 0.5)
        elseif percent == 0 then
        elseif percent < 0 then
        end
    end, "PhotoAlbumPanel")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"CoverCheckBox", "PhotoAlbumrCheckBox", "DiaryCheckBox", "AnniversaryCheckBox"}, self.onCheckBox)
    if self.lastSelect and gf:getServerTime() - (self.lastSelect.lastCloseTime or 0) < reInitRadioTime and self.id == self.lastSelect.lastSelectId then
        self.radioGroup:selectRadio(self.lastSelect.lastSelectIndex or 1)
    else
        self.radioGroup:selectRadio(1)
    end

    self:refreshBookInfo()

    self:hookMsg("MSG_WB_DIARY_SUMMARY")
    self:hookMsg("MSG_WB_DIARY")
    self:hookMsg("MSG_WB_DAY_SUMMARY")
    self:hookMsg("MSG_WB_PHOTO_SUMMARY")
    self:hookMsg("MSG_WB_UPDATE_PHOTO")
    self:hookMsg("MSG_WB_DELETE_PHOTO")
    self:hookMsg("MSG_WB_UPDATE_DIARY")
    self:hookMsg("MSG_WB_DELETE_DIARY")
    self:hookMsg("MSG_WB_UPDATE_DAY")
    self:hookMsg("MSG_WB_DELETE_DAY")
    self:hookMsg("MSG_WB_UPDATE_HOME_PIC")
    self:hookMsg("MSG_WB_HOME_INFO")
end

function WeddingBookDlg:cleanup()
    gf:CmdToServer("CMD_WB_CLOSE_BOOK", { book_id = self.id })
    self.lastSelect = { lastSelectIndex = self.radioGroup:getSelectedRadioIndex(), lastCloseTime = gf:getServerTime(), lastSelectId = self.id }
end

-- 标签页切换
function WeddingBookDlg:onCheckBox(sender, eventType)
    local ctlName = sender:getName()

    for k, v in pairs(radioToPanel) do
        if k == ctlName then
            self:setCtrlVisible(v, true)
            local funcName = string.format("refresh%s", v)
            if 'function' == type(self[funcName]) then
                self[funcName](self)
            end
        else
            self:setCtrlVisible(v, false)
        end

        self:setCtrlVisible("ChosenPanel", k == ctlName, k)
        self:setCtrlVisible("UnChosenPanel", k ~= ctlName, k)
    end
end

-- 是否相册主人
function WeddingBookDlg:isBookOwner()
    return WeddingBookMgr:isOwner(self.id)
end

-- 刷新纪念册信息
function WeddingBookDlg:refreshBookInfo()
    if not self.id then return end
    local book = WeddingBookMgr:getBook(self.id)
    if not book then return end

    if book.wedding_end_ti and book.wedding_end_ti > 0 then
        -- 婚姻结束，离婚
        self:setLabelText("TextLabel1", CHS[2000482], "DayPanel")
        self:setLabelText("TextLabel2", string.format("%d", WeddingBookMgr:subTime(book.wedding_end_ti, book.wedding_start_ti)), "DayPanel")
        self:setLabelText("TextLabel3", CHS[2000483], "DayPanel")

        self:setCtrlEnabled("AddButton", false, "PhotoAlbumPanel")
        self:setCtrlEnabled("AddButton", false, "DiaryPanel")
        self:setCtrlEnabled("AddButton", false, "AnniversaryPanel")
    else
        -- 婚姻维持中
        local days = WeddingBookMgr:subTime(gf:getServerTime(), book.wedding_start_ti)
        if days <= 0 then
            if WeddingBookMgr:isOwner(self.id) then
                self:setLabelText("TextLabel1", gf:getServerDate(CHS[5420356], book.wedding_start_ti), "DayPanel")
            else
                self:setLabelText("TextLabel1", gf:getServerDate(CHS[5420357], book.wedding_start_ti), "DayPanel")
            end

            self:setLabelText("TextLabel2", "", "DayPanel")
            self:setLabelText("TextLabel3", "", "DayPanel")
        else
            self:setLabelText("TextLabel1", WeddingBookMgr:isOwner(self.id) and CHS[2000484] or CHS[2100148], "DayPanel")
            self:setLabelText("TextLabel2", string.format("%d",days), "DayPanel")
            self:setLabelText("TextLabel3", CHS[2000485], "DayPanel")
        end

        self:setCtrlEnabled("AddButton", true, "PhotoAlbumPanel")
        self:setCtrlEnabled("AddButton", true, "DiaryPanel")
        self:setCtrlEnabled("AddButton", true, "AnniversaryPanel")
    end

    self:setCtrlVisible("ShareButton", WeddingBookMgr:isOwner(self.id), "DayPanel")
end

-- 分享按钮
function WeddingBookDlg:onShareButton(sender, eventType)
    local showInfo = string.format(string.format("{\29%s%s\29}", Me:getName(), CHS[2100156]))
    local sendInfo = string.format(string.format("{\t%s=%s=%s}", Me:queryBasic("gid"), CHS[2100149], self.id))

    local dlg = DlgMgr:openDlgEx("ShareChannelListExDlg", "JiNianCeDlg", nil, true)
    dlg:setShareText(showInfo, sendInfo)

    local rect = self:getBoundingBoxInWorldSpace(sender)
    rect.x = rect.x + 15
    rect.y = rect.y + 15
    dlg:setFloatingFramePos(rect)
end

-- 刷新封面
function WeddingBookDlg:refreshCoverPanel()
    if not self.id then return end
    local book = WeddingBookMgr:getBook(self.id)
    if not book then return end

    local panel = self:getControl("PlayerNamePanel", nil, "CoverPanel")

    -- 设置夫妻姓名
    self:setLabelText("MaleLabel", book.hus_name, panel)
    self:setLabelText("FemaleLabel", book.wife_name, panel)

    -- 设置封面图片
    if not string.isNilOrEmpty(book.home_img) then
        self:setCtrlVisible("LoadingPanel", true, "CoverPanel")
        self:setCtrlVisible("TextLabel1", true, self:getControl("LoadingPanel", nil, "CoverPanel"))
        self:setCtrlVisible("TextLabel2", false, self:getControl("LoadingPanel", nil, "CoverPanel"))
        BlogMgr:assureFile("refreshCoverImage", self.name, book.home_img)
        self:setCtrlTouchEnabled("LoadingPanel", false, "CoverPanel")
    else
        -- 默认封面
        self:refreshCoverImage(DEFAULT_COVER)
    end

    self:setCtrlVisible("PhotoButton", WeddingBookMgr:isInMarriage(self.id) and WeddingBookMgr:isOwner(self.id), "CoverPanel")
    self:setCtrlVisible("UploadPanel", false, "CoverPanel")
    self:setCtrlVisible("LoveImage1", WeddingBookMgr:isInMarriage(self.id), "CoverPanel")
    self:setCtrlVisible("LoveImage2", not WeddingBookMgr:isInMarriage(self.id), "CoverPanel")
end

-- 刷新封面
function WeddingBookDlg:refreshCoverImage(filePath)
    if string.isNilOrEmpty(filePath) then
        self:setCtrlVisible("LoadingPanel", true, "CoverPanel")
        self:setCtrlVisible("TextLabel1", false, self:getControl("LoadingPanel", nil, "CoverPanel"))
        self:setCtrlVisible("TextLabel2", true, self:getControl("LoadingPanel", nil, "CoverPanel"))
        self:setCtrlTouchEnabled("LoadingPanel", true, "CoverPanel")
    else
        self:setCtrlVisible("LoadingPanel", false, "CoverPanel")
    end
    self:setImage("PhotoImage", filePath, "CoverPanel")
    self:setImageSize("PhotoImage", cc.size(530, 360), "CoverPanel")
end

-- 刷新日记
function WeddingBookDlg:refreshDiaryPanel()
    WeddingBookMgr:openDiarySummary(self.id)
    self:loadDiarys()
    self:setCtrlVisible("AddButton", WeddingBookMgr:isOwner(self.id), "DiaryPanel")
end

-- 加载日记本
function WeddingBookDlg:loadDiarys()
    local diaryList = WeddingBookMgr:getDiaryList(self.id)
    self:setCtrlVisible("NoticePanel", (not diaryList or #diaryList <= 0) and WeddingBookMgr:isOwner(self.id), "DiaryPanel")
    self:setCtrlVisible("NoticePanel2", (not diaryList or #diaryList <= 0) and not WeddingBookMgr:isOwner(self.id), "DiaryPanel")
    local listView = self:resetListView("DiaryListView", nil, nil, "DiaryPanel")
    if not listView or not diaryList then return end
    for i = 1, #diaryList do
        local item = self.oneDiaryPanel:clone()
        self:updateDiaryItem(item, diaryList[i])
        listView:pushBackCustomItem(item)
    end
end

-- 刷新日记本
function WeddingBookDlg:refreshDiarys()
    local diaryList = WeddingBookMgr:getDiaryList(self.id)
    self:setCtrlVisible("NoticePanel", (not diaryList or #diaryList <= 0) and WeddingBookMgr:isOwner(self.id), "DiaryPanel")
    self:setCtrlVisible("NoticePanel2", (not diaryList or #diaryList <= 0) and not WeddingBookMgr:isOwner(self.id), "DiaryPanel")
    local listView = self:getControl("DiaryListView", nil, "DiaryPanel")
    if not listView or not diaryList then return end
    for i = 1, #diaryList do
        local item = listView:getItem(i - 1)
        if not item then
            item = self.oneDiaryPanel:clone()
            listView:pushBackCustomItem(item)
        end
        self:updateDiaryItem(item, diaryList[i])
    end

    local items = listView:getItems()
    for i = #diaryList + 1, #items do
        listView:removeLastItem()
    end
end

-- 长按相片
function WeddingBookDlg:onLongClickPhoto(sender, eventType)
    if WeddingBookMgr:isOwner(self.id) then
        self:onClickPhoto(sender, eventType)
    elseif self:getCtrlVisible("PhotoImage", sender) then
        local dlg = BlogMgr:showButtonList(self, sender, "reportWBPhoto", self.name)
        local curPos = GameMgr.curTouchPos
        dlg:setFloatingFramePos(cc.rect(curPos.x, curPos.y, 0, 0))
    end
end

-- 点击相片
function WeddingBookDlg:onClickPhoto(sender, eventType)
    if self:getCtrlVisible("PhotoImage", sender) then
        local dlg = BlogMgr:showButtonList(self, sender, "weddingBookViewPhoto", self.name)
        local curPos = GameMgr.curTouchPos
        dlg:setFloatingFramePos(cc.rect(curPos.x, curPos.y, 0, 0))
    elseif self:getCtrlVisible("TextLabel2", sender) then
        local data = WeddingBookMgr:getPhoto(self.id, sender.photoId)
        if data then
            BlogMgr:assureFile("setPhoto", self.name, data.img, { process = PHOTO_SMALL_SIZE_STR }, sender:getName())
            self:setCtrlVisible("TextLabel1", true, sender)
            self:setCtrlVisible("TextLabel2", false, sender)
            self:setCtrlVisible("PhotoImage", false, sender)
            self:setCtrlVisible("LoadingImage", true, sender)
        end
    end
end

-- 举报相片
function WeddingBookDlg:doReportPhoto(sender)
    local photoId = sender.photoId
    if not photoId then return end

    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[2100158])
        return
    end

    gf:CmdToServer("CMD_WB_REPORT_PHOTO", {book_id = self.id, photo_id = photoId})
end

-- 查看原图
function WeddingBookDlg:onViewPhoto(sender)
    local photoId = sender.photoId
    local photo = photoId and WeddingBookMgr:getPhoto(self.id, photoId)
    if not photo then
        gf:ShowSmallTips(CHS[2000495])
        return
    end
    if self.photoPreview and #self.photoPreview == 2 and photo then
        local dlg = DlgMgr:openDlg("BlogPhotoDlg")
        dlg:setPicture(sender:getTag(), self.photoPreview[1], self.photoPreview[2])
    end
end

-- 编辑备注
function WeddingBookDlg:onEditComment(sender)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local photoId = sender.photoId
    local photo = photoId and WeddingBookMgr:getPhoto(self.id, photoId)
    if not photo then
        gf:ShowSmallTips(CHS[2000495])
        return
    end

    DlgMgr:openDlgEx("WeddingPhotoDlg", { bookId = self.id, photoId = photoId, flag = 'edit'})
end

-- 删除照片
function WeddingBookDlg:onDeletePhote(sender)
    local photoId = sender.photoId
    local photo = photoId and WeddingBookMgr:getPhoto(self.id, photoId)
    if not photo then
        self:refreshPhoto()
        gf:ShowSmallTips(CHS[2000495])
        return
    end

--    if not WeddingBookMgr:isInMarriage(self.id) then
--        gf:ShowSmallTips(CHS[2000475])
--        return
--    end

    local bookId = self.id
    gf:confirm(CHS[2000496], function()
        WeddingBookMgr:deletePhoto(bookId, photoId)
    end)
end

-- 打开相册
function WeddingBookDlg:refreshPhotoAlbumPanel()
    WeddingBookMgr:openPhotoSummary(self.id)
    self:loadPhotos()
    self:setCtrlVisible("AddButton", WeddingBookMgr:isOwner(self.id), "PhotoAlbumPanel")
end

-- 更新相册数据
function WeddingBookDlg:updatePhotoItem(index, item, data)
    self:setLabelText("TimeLabel", os.date("%Y-%m-%d %H:%M", data.publish_time or os.time()), item)
    local memo = gf:getTextByLenth(data.memo, 24)
    if string.isNilOrEmpty(memo) then
        self:setLabelText("TextLabel", CHS[2000501], item)
    else
        self:setLabelText("TextLabel", memo, item)
    end

    self:setCtrlVisible("TextLabel1", true, item)
    self:setCtrlVisible("TextLabel2", false, item)
    self:setCtrlVisible("PhotoImage", false, item)
    self:setCtrlVisible("LoadingImage", true, item)
    self:setCtrlVisible("Privatemage", 0 == data.showFlag, item)
    item:setName(data.photo_id)
    item.photoId = data.photo_id
    item:setTag(index)

    -- performWithDelay(item, function()
        BlogMgr:assureFile("setPhoto", self.name, data.img, { process = PHOTO_SMALL_SIZE_STR }, data.photo_id)
    -- end, 0)
end

function WeddingBookDlg:setPhoto(path, para)
    local scrollView = self:getControl("PhotoScrollView", nil, "PhotoAlbumPanel")
    if not scrollView then
        return
    end
    local children = scrollView:getChildren()
    local contentLayer
    if not children or #children <= 0 then
        return
    end

    contentLayer = children[1]
    if not contentLayer then return end
    local item = contentLayer:getChildByName(para)
    if string.isNilOrEmpty(path) then
        -- 下载失败
        self:setCtrlVisible("TextLabel2", true, item)
        self:setCtrlVisible("TextLabel1", false, item)
        self:setCtrlVisible("LoadingImage", true, item)
        self:setCtrlVisible("PhotoImage", false, item)
    else
        self:setImage("PhotoImage", path, item)
        self:setCoverSmallImageSize("PhotoImage", item, 232, 142)
        self:setCtrlVisible("PhotoImage", true, item)
        self:setCtrlVisible("TextLabel1", false, item)
        self:setCtrlVisible("LoadingImage", false, item)
    end
end

function WeddingBookDlg:setCoverSmallImageSize(imageName, panel, w, h)
    local image = self:getControl(imageName, nil, panel)
    local orgSize = image:getContentSize()
    local w1 = orgSize.width
    local h1 = orgSize.height
    local w2 = w
    local h2 = h

    if w1 / h1 > w2 / h2 then
        self:setImageSize(imageName, cc.size(w1 * h2 / h1, h2), panel)
    else
        self:setImageSize(imageName, cc.size(w2, h1 * w2 / w1), panel)
    end

end

-- 点击封面加载
function WeddingBookDlg:onClickLoadingPanel(sender, eventType)
    self:refreshCoverPanel()
end

-- 举报封面
function WeddingBookDlg:doReportCover(sender)
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[2100158])
        return
    end

    local book = WeddingBookMgr:getBook(self.id)
    if not book then return end
    if string.isNilOrEmpty(book.home_img) then
        gf:ShowSmallTips(CHS[2100159])
        return
    end

    gf:CmdToServer("CMD_WB_REPORT_HOME_PIC", { book_id = self.id, img_path = book.home_img })
end

-- 长按封面
function WeddingBookDlg:onLongClickPhotoImage(sender, eventType)
    if WeddingBookMgr:isOwner(self.id) then return end

    local dlg = BlogMgr:showButtonList(self, sender, "reportWBCover", self.name)
    local curPos = GameMgr.curTouchPos
    dlg:setFloatingFramePos(cc.rect(curPos.x, curPos.y, 0, 0))
end

-- 点击封面
function WeddingBookDlg:onClickPhotoImage(sender, eventType)
end

function WeddingBookDlg:getPhotoItem(photoId)
    local scrollView = self:getControl("PhotoScrollView", nil, "PhotoAlbumPanel")
    if not scrollView then return end
    local children = scrollView:getChildren()
    if children and children[1] then
        return children[1]:getChildByName(photoId)
    end
end

-- 加载相册
function WeddingBookDlg:loadPhotos()
    local photoList = WeddingBookMgr:getPhotoList(self.id)
    self:setCtrlVisible("NoticePanel", (not photoList or #photoList <= 0) and WeddingBookMgr:isOwner(self.id), "PhotoAlbumPanel")
    self:setCtrlVisible("NoticePanel2", (not photoList or #photoList <= 0) and not WeddingBookMgr:isOwner(self.id), "PhotoAlbumPanel")
    local scrollView = self:getControl("PhotoScrollView", nil, "PhotoAlbumPanel")
    if not scrollView or not photoList then
        return
    end
    scrollView:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local size = self.onePhotoPanel:getContentSize()
    scrollView:addChild(contentLayer)
    local totalHeight = (size.height + 10) * math.ceil(#photoList / 2) - 10
    local photoPaths = {}
    local photoComments  = {}
    for i = 1, #photoList do
        local item = self.onePhotoPanel:clone()
        contentLayer:addChild(item)
        self:updatePhotoItem(i, item, photoList[i])
        item:setPosition(cc.p(((i - 1) % 2) * (size.width + 20), totalHeight - (math.floor((i - 1) / 2) + 1) * size.height - math.floor((i - 1) / 2) * 10))
        table.insert(photoPaths, photoList[i].img)
        table.insert(photoComments, photoList[i].memo)
    end
    self.photoPreview = { photoPaths, photoComments }
    contentLayer:setContentSize(scrollView:getContentSize().width, totalHeight)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())
    if totalHeight < scrollView:getContentSize().height then
        contentLayer:setPositionY(scrollView:getContentSize().height - totalHeight)
    else
        contentLayer:setPositionY(0)
    end
end

-- 刷新相册
function WeddingBookDlg:refreshPhoto()
    local photoList = WeddingBookMgr:getPhotoList(self.id)
    self:setCtrlVisible("NoticePanel", (not photoList or #photoList <= 0) and WeddingBookMgr:isOwner(self.id), "PhotoAlbumPanel")
    self:setCtrlVisible("NoticePanel2", (not photoList or #photoList <= 0) and not WeddingBookMgr:isOwner(self.id), "PhotoAlbumPanel")
    local scrollView = self:getControl("PhotoScrollView", nil, "PhotoAlbumPanel")
    if not scrollView or not photoList then
        return
    end
    local children = scrollView:getChildren()
    local contentLayer
    if not children or #children <= 0 then
        contentLayer = ccui.Layout:create()
        scrollView:addChild(contentLayer)
    else
        contentLayer = children[1]
    end
    children = contentLayer:getChildren()
    local size = self.onePhotoPanel:getContentSize()
    local totalHeight = (size.height + 10) * math.ceil(#photoList / 2) - 10
    local photoPaths = {}
    local photoComments  = {}
    for i = 1, #photoList do
        local item = children[i]
        if not item then
            item = self.onePhotoPanel:clone()
            contentLayer:addChild(item)
        end
        self:updatePhotoItem(i, item, photoList[i])
        item:setPosition(cc.p(((i - 1) % 2) * (size.width + 20), totalHeight - (math.floor((i - 1) / 2) + 1) * size.height - math.floor((i - 1) / 2) * 10))
        table.insert(photoPaths, photoList[i].img)
        table.insert(photoComments, photoList[i].memo)
    end

    self.photoPreview = { photoPaths, photoComments }
    contentLayer:setContentSize(scrollView:getContentSize().width, totalHeight)
    scrollView:setInnerContainerSize(contentLayer:getContentSize())

    local count = #children
    for i = #photoList + 1, count do
        contentLayer:removeChild(children[count])
        count = count - 1
    end

    if totalHeight < scrollView:getContentSize().height then
        contentLayer:setPositionY(scrollView:getContentSize().height - totalHeight)
    else
        contentLayer:setPositionY(0)
    end
end

-- 更新日记数据
function WeddingBookDlg:updateDiaryItem(item, data)
    local portraitPath = ResMgr:getSmallPortrait(data.icon)
    self:setImage("PortraitImage", portraitPath, item)
    self:setCtrlVisible("TitelLabel", false, item)
    self:setColorText(data.general, "TitlePanel", item, nil, nil, cc.c3b(153, 107, 61) , 19)

    self:setLabelText("TimeLabel", os.date("%Y-%m-%d %H:%M", data.create_time or os.time()), item)
    if WeddingBookMgr:isDiaryEdit(data.flag) and WeddingBookMgr:isInMarriage(self.id) then
        self:setCtrlVisible("EditButton", true, item)
        self:setCtrlVisible("LookButton", false, item)
    else
        self:setCtrlVisible("EditButton", false, item)
        self:setCtrlVisible("LookButton", WeddingBookMgr:isDiaryView(data.flag), item)
    end
    self:setCtrlVisible("LockButton", WeddingBookMgr:isDiaryLock(data.flag), item)
    self:setCtrlVisible("TitlePanel", not WeddingBookMgr:isDiaryLock(data.flag), item)
    self:setCtrlVisible("NoneLabel", WeddingBookMgr:isDiaryLock(data.flag), item)
    self:setCtrlVisible("Privatemage", 2 == data.showFlag, item)
    item.diaryId = data.diary_id
end

-- 获取纪念日
function WeddingBookDlg:refreshAnniversaryPanel()
    WeddingBookMgr:openDaySummary(self.id)
    self:loadDays()
    self:setCtrlVisible("AddButton", WeddingBookMgr:isOwner(self.id), "AnniversaryPanel")
end

-- 加载纪念日
function WeddingBookDlg:loadDays()
    local dayList = WeddingBookMgr:getDayList(self.id)
    local listView = self:resetListView("DayListView", nil, nil, "AnniversaryPanel")
    if not listView or not dayList then return end
    for i = 1, #dayList do
        local item = self.oneDayPanel:clone()
        self:updateDayItem(item, dayList[i])
        listView:pushBackCustomItem(item)
    end
end

-- 刷新纪念日
function WeddingBookDlg:refreshDays()
    local dayList = WeddingBookMgr:getDayList(self.id)
    local listView = self:getControl("DayListView", nil, "AnniversaryPanel")
    if not listView or not dayList then return end
    for i = 1, #dayList do
        local item = listView:getItem(i - 1)
        if not item then
            item = self.oneDayPanel:clone()
            listView:pushBackCustomItem(item)
        end
        self:updateDayItem(item, dayList[i])
    end

    local items = listView:getItems()
    for i = #dayList + 1, #items do
        listView:removeLastItem()
    end
end

-- 更新纪念日列表项
function WeddingBookDlg:updateDayItem(item, data)
    local path = ResMgr.wbIcon[data.icon]
    local isMarriageDay = data.type == 1
    self:setImage("IconImage", path, item)
    self:setCtrlVisible("MarryDayPanel", isMarriageDay, item)
    self:setCtrlVisible("DayPanel", not isMarriageDay, item)
    local infoPanel = self:getControl("InfoPanel", nil, item)
    self:setCtrlVisible("MarryBKImage", isMarriageDay, infoPanel)
    self:setCtrlVisible("MarryLabel", isMarriageDay, infoPanel)
    self:setCtrlVisible("DayLabel", not isMarriageDay, infoPanel)
    self:setCtrlVisible("EditButton", not isMarriageDay and WeddingBookMgr:isOwner(self.id), item)
    local panel
    if isMarriageDay then
        panel = self:getControl("MarryDayPanel", nil, item)
    else
        panel = self:getControl("DayPanel", nil, item)
        self:setLabelText("DayLabel", data.name, infoPanel)
    end
    self:setLabelText("DayLabel", os.date("%d", data.day_time), panel)
    self:setLabelText("YearLabel", os.date("%Y.%m", data.day_time), panel)

    local flag = Bitset.new(data.flag)
    local isInMarriage = WeddingBookMgr:isInMarriage(self.id)
    self:setCheck("MaleCheckBox", flag:isSet(1) and isInMarriage, infoPanel)
    self:setCheck("FemaleCheckBox", flag:isSet(2) and isInMarriage, infoPanel)
    self:setCtrlTouchEnabled("MaleCheckBox", WeddingBookMgr:isOwner(self.id), infoPanel)
    self:setCtrlTouchEnabled("FemaleCheckBox", WeddingBookMgr:isOwner(self.id), infoPanel)

    item.dayId = data.day_id
end

function WeddingBookDlg:onItemMaleCheck(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        sender:setSelectedState(false)
        gf:ShowSmallTips(CHS[2000475])
        return
    end
    local item = sender:getParent():getParent()
    local dayId = item.dayId
    local day = WeddingBookMgr:getDay(self.id, dayId)
    if day then
        local flag = Bitset.new(day.flag)
        flag:setBit(1, self:isCheck("MaleCheckBox", item))
        WeddingBookMgr:editDay(self.id, dayId, day.icon, day.name, day.day_time, flag:getI32())
    end
end

function WeddingBookDlg:onItemFemaleCheck(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        sender:setSelectedState(false)
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local item = sender:getParent():getParent()
    local dayId = item.dayId
    local day = WeddingBookMgr:getDay(self.id, dayId)
    if day then
        local flag = Bitset.new(day.flag)
        flag:setBit(2, self:isCheck("FemaleCheckBox", item))
        WeddingBookMgr:editDay(self.id, dayId, day.icon, day.name, day.day_time, flag:getI32())
    end
end

function WeddingBookDlg:onItemEditButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local item = sender:getParent()
    DlgMgr:openDlgEx("WeddingAnniversaryDlg", { bookId = self.id, dayId = item.dayId })
end

function WeddingBookDlg:showUploadCoverProgress()
    self:setCtrlVisible("UploadPanel", true, "CoverPanel")
    self:performUploadCoverProgress(2000, 0, 80)
end

function WeddingBookDlg:performUploadCoverProgress(hourglass, startValue, endValue, func)
    local startTime = gfGetTickCount()
    local elapseTime = hourglass
    self:setLabelText("TextLabel1", string.format(CHS[2100160], startValue), "CoverPanel")

    local panel = self:getControl("UploadPanel", nil, "CoverPanel")
    schedule(panel, function()
        local curTime = gfGetTickCount() - startTime
        local value = math.ceil((curTime / hourglass * (endValue - startValue) + startValue) * 100)

        if value > endValue then
            value = endValue
        elseif value < 0 then
            value = 0
        end

        panel.curValue = value
        self:setLabelText("TextLabel1", string.format(CHS[2100160], value), "CoverPanel")

        if curTime >= hourglass then
            if 'function' == type(func) then
                func()
            end
        end
    end, 0)
end

function WeddingBookDlg:hideUploadCoverProgress()
    local panel = self:getControl("UploadPanel", nil, "CoverPanel")
    if not panel then return end
    local startValue = panel.curValue or 0
    self:performUploadCoverProgress(300, startValue, 100, function()
        performWithDelay(panel, function()
            panel:setVisible(false)
        end, 0)
    end)
end

-- 上传封面
function WeddingBookDlg:uploadWeddingBookCover(filePath)
    if string.isNilOrEmpty(filePath) then return end

    filePath = string.trim(string.gsub(filePath, "\\/", "/"))
    local s = string.sub(filePath, 1, 1)
    if '{' == s then
        local data = json.decode(filePath)
        if 'save' == data.action then
            filePath = data.path
        else
            return
        end
    end

    gf:confirm(CHS[2000486], function()
        -- 设置封面图片
        self:refreshCoverImage(filePath)

        self:showUploadCoverProgress()

        -- 开始上传
        BlogMgr:cmdUpload(BLOG_OP_TYPE.WB_OP_COVER, self.name, "onFinishUploadWeddingBookCover", filePath)
    end)
end

-- 完成封面上传
function WeddingBookDlg:onFinishUploadWeddingBookCover(files, uploads)
    self:setCtrlEnabled("ConfirmButton", true)
    self:hideUploadCoverProgress()
    if #files ~= #uploads then
        gf:showTipAndMisMsg(CHS[2100145])
        return
    end

    gf:CmdToServer("CMD_WB_HOME_PIC", { book_id = self.id, img = uploads[1] })
    WeddingBookMgr:markUploadCover()
end

function onPickWeddingBookCoverPhoto(filePath)
    DlgMgr:sendMsg("WeddingBookDlg", "uploadWeddingBookCover", filePath)
end

-- 上传封面照片
function WeddingBookDlg:onCoverPhotoButton(sender, eventType)
    local dlg = BlogMgr:showButtonList(self, sender, "weddingBookPhotoMenu", self.name)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(x + 20, y - 20))
end

function WeddingBookDlg:isDefaultPhoto()
    local book = WeddingBookMgr:getBook(self.id)
    return not book or string.isNilOrEmpty(book.home_img)
end

-- 打开相机或相册
function WeddingBookDlg:openPhoto(state)
    local leftTime = WeddingBookMgr:canUploadCoverTime()
    if leftTime > 0 then
        gf:ShowSmallTips(string.format(CHS[2000487], leftTime))
        return
    end

    local cw, ch = gf:getPortraitClipRange(53, 36)
    gf:comDoOpenPhoto(state, "onPickWeddingBookCoverPhoto", cc.size(cw, ch), cc.size(530, 360), 80)
end

function WeddingBookDlg:doReset()
    local bookId = self.id
    gf:confirm(CHS[2000488], function()
        gf:CmdToServer("CMD_WB_HOME_PIC", { book_id = bookId})
    end)
end

-- 增加相册
function WeddingBookDlg:onAddPhotoAlbumrButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local book = WeddingBookMgr:getBook(self.id)
    if book and book.photoCount and book.photoCount >= NUM_LIMIT then
        gf:ShowSmallTips(CHS[2000498])
        return
    end

    DlgMgr:openDlgEx("WeddingPhotoDlg", { bookId = self.id, flag = 'add'})
end

-- 增加日记
function WeddingBookDlg:onAddDiaryButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local book = WeddingBookMgr:getBook(self.id)
    if book and book.diaryCount and book.diaryCount >= NUM_LIMIT then
        gf:ShowSmallTips(CHS[2000497])
        return
    end

    DlgMgr:openDlgEx("WeddingDiaryDlg", {bookId = self.id, flag = 'add'})
end

-- 增加纪念日
function WeddingBookDlg:onAddAnniversaryButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local book = WeddingBookMgr:getBook(self.id)
    if book and book.dayCount and book.dayCount >= NUM_LIMIT_DAY then
        gf:ShowSmallTips(CHS[2000499])
        return
    end

    DlgMgr:openDlgEx("WeddingAnniversaryDlg", { bookId = self.id })
end

-- 编辑日记
function WeddingBookDlg:onDiaryEditButton(sender, eventType)
    if not WeddingBookMgr:isInMarriage(self.id) then
        gf:ShowSmallTips(CHS[2000475])
        return
    end

    local item = sender:getParent()
    if not item then return end
    local diaryId = item.diaryId
    if not diaryId then return end

    WeddingBookMgr:openDiary(self.id, diaryId)
end

-- 查看日记
function WeddingBookDlg:onDiaryLookButton(sender, eventType)
    local item = sender:getParent()
    if not item then return end
    local diaryId = item.diaryId
    if not diaryId then return end
    WeddingBookMgr:openDiary(self.id, diaryId)
end

-- 日记锁定
function WeddingBookDlg:onDiaryLockButton(sender, eventType)
    gf:ShowSmallTips(CHS[2000489])
end

function WeddingBookDlg:MSG_WB_DIARY_SUMMARY(data)
    self:refreshDiarys()
end

function WeddingBookDlg:MSG_WB_DIARY(data)
    local bookId = data.book_id
    local diaryId = data.diary_id
    local diary = WeddingBookMgr:getDiary(bookId, diaryId)
    if not diary then return end
    if WeddingBookMgr:isDiaryEdit(diary.flag) then
        DlgMgr:openDlgEx("WeddingDiaryDlg", {bookId = bookId, diaryId = diaryId, flag = 'edit'})
    elseif WeddingBookMgr:isDiaryView(diary.flag) then
        DlgMgr:openDlgEx("WeddingDiaryDlg", {bookId = bookId, diaryId = diaryId, flag = 'view'})
    end
end

function WeddingBookDlg:MSG_WB_DAY_SUMMARY(data)
    self:refreshDays()
end

function WeddingBookDlg:MSG_WB_PHOTO_SUMMARY(data)
    self:refreshPhoto()
end

function WeddingBookDlg:MSG_WB_UPDATE_PHOTO(data)
    self:refreshPhoto()
end

function WeddingBookDlg:MSG_WB_DELETE_PHOTO(data)
    self:refreshPhoto()
end

function WeddingBookDlg:MSG_WB_UPDATE_DIARY(data)
    self:refreshDiarys()
end

function WeddingBookDlg:MSG_WB_DELETE_DIARY(data)
    self:refreshDiarys()
end

function WeddingBookDlg:MSG_WB_UPDATE_DAY(data)
    self:refreshDays()
end

function WeddingBookDlg:MSG_WB_DELETE_DAY(data)
    self:refreshDays()
end

function WeddingBookDlg:MSG_WB_UPDATE_HOME_PIC(data)
    self:refreshCoverPanel()
end

function WeddingBookDlg:MSG_WB_HOME_INFO(data)
    self:refreshBookInfo()
    self:refreshCoverPanel()
end

return WeddingBookDlg
