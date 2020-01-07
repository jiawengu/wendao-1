-- WeddingBookMgr.lua
-- Created by sujl, Apr/4/2018
-- 管理当前存在和曾经存在的婚姻关系

local Bitset = require('core/Bitset')

WeddingBookMgr = Singleton("WeddingBookMgr")

local DIARY_EDIT = 1
local DIARY_VIEW = 2

-- 封面上传时间限制
local COVER_UPLOAD_TIME_LIMIT = 10 * 60

-- 一页的数量
local COUNT_PER_PAGE = 20

-- 夫妻信息
WeddingBookMgr.books = {}

-- 是否处于婚姻中
function WeddingBookMgr:isInMarriage(bookId)
    local book = self:getBook(bookId)
    if not book then return end
    return book.wedding_end_ti <= 0
end

function WeddingBookMgr:getCoupleName(bookId)
    local book = self:getBook(bookId)
    if not book then return end
    if book.hus_name == Me:getName() then
        return book.wife_name
    else
        return book.hus_name
    end
end

-- 是否是纪念册的拥有者(服务器双方)
function WeddingBookMgr:isOwner(bookId)
    local book = self:getBook(bookId)
    if not book then return end

    local meName = Me:getName()
    return book.hus_name == meName or book.wife_name == meName
end

-- 清除数据
function WeddingBookMgr:clearData()
    -- self.books = {}
    self.lastUploadCover = nil
    self.guidePos = nil
end

-- 检查是否可以上传
function WeddingBookMgr:canUploadCoverTime()
    local first = self.lastUploadCover and self.lastUploadCover[math.max(1, #self.lastUploadCover - 2)]
    if not first then return 0 end   -- 没有记录
    if gf:getServerTime() - first <= COVER_UPLOAD_TIME_LIMIT and #self.lastUploadCover - 2 > 0 then
        return math.ceil((COVER_UPLOAD_TIME_LIMIT - (gf:getServerTime() - first)) / 60)
    end
    return 0
end

-- 记录最近上传的图片
function WeddingBookMgr:markUploadCover()
    -- 只保留2张
    if not self.lastUploadCover then
        self.lastUploadCover = {}
    else
        local count = #self.lastUploadCover
        if count >= 3 then
            self.lastUploadCover[1] = self.lastUploadCover[count - 2]
            self.lastUploadCover[2] = self.lastUploadCover[count - 1]
        end
    end

    table.insert(self.lastUploadCover, gf:getServerTime())
end

-- 通过id获取夫妻信息
function WeddingBookMgr:getBook(id)
    return self.books[id]
end

-- 获取日记
function WeddingBookMgr:getDiary(bookId, diaryId)
    local book = self:getBook(bookId)
    if not book or not book.diarys then return end
    return book.diarys[diaryId]
end

-- 获取日记列表
function WeddingBookMgr:getDiaryList(bookId)
    local book = self:getBook(bookId)
    if not book or not book.diarys then return end
    local list = {}
    for _, v in pairs(book.diarys) do
        table.insert(list, v)
    end

    table.sort(list, function(l, r)
        return l.last_edit_time > r.last_edit_time
    end)

    return list
end

-- 是否可编辑
function WeddingBookMgr:isDiaryEdit(flag)
    local diaryFlag = Bitset.new(flag)
    return diaryFlag:isSet(DIARY_EDIT)
end

-- 是否可查看
function WeddingBookMgr:isDiaryView(flag)
    local diaryFlag = Bitset.new(flag)
    return diaryFlag:isSet(DIARY_VIEW)
end

-- 是否锁定
function WeddingBookMgr:isDiaryLock(flag)
    return 0 == flag
end

-- 以5点作为切换点
function WeddingBookMgr:getDayTime(time)
    if time < 5 * 3600 then return 0 end
    time = time - 5 * 3600
    local t = os.date("*t", time)
    return t.year, t.yday
end

-- 获取一年的天数
function WeddingBookMgr:getDayByYear(y)
    if (y % 4 == 0 and y % 400 ~= 0) or (y % 400) == 0 then
        return 366
    else
        return 365
    end
end

-- 获取两个时间的时间差(以5点作为切换点)
function WeddingBookMgr:subTime(to, from)
    --[[local fy, fd = self:getDayTime(from)
    local ty, td = self:getDayTime(to)

    local d
    if fy < ty then
        d = self:getDayByYear(fy) - fd
        for i = fy + 1, ty - 1 do
            d = d + self:getDayByYear(i)
        end
        d = d + td
    else
        d = td - fd
    end
    return d]]

    return math.floor((to - from) / Const.ONE_DAY_SECOND)
end

-- 打开日记本
function WeddingBookMgr:openDiarySummary(bookId, page)
    gf:CmdToServer("CMD_WB_DIARY_SUMMARY", {book_id = bookId, page = page or 1})
end

-- 打开某一篇日记
function WeddingBookMgr:openDiary(bookId, diaryId)
    gf:CmdToServer("CMD_WB_DIARY", { book_id = bookId, diary_id = diaryId })
end

-- 增加日记
function WeddingBookMgr:addDiary(bookId, content, flag)
    gf:CmdToServer("CMD_WB_DIARY_ADD", { book_id = bookId, content = content, flag = flag })
end

-- 编辑日记
function WeddingBookMgr:editDiary(bookId, diaryId, content, flag)
    gf:CmdToServer("CMD_WB_DIARY_EDIT", { book_id = bookId, diary_id = diaryId, content = content, flag = flag })
end

-- 删除日记
function WeddingBookMgr:deleteDiary(bookId, diaryId)
    gf:CmdToServer("CMD_WB_DIARY_DELETE", { book_id = bookId, diary_id = diaryId })
end

-- 更新本地日记信息
function WeddingBookMgr:refreshDiary(bookId, diaryId, content, view)
    local diary = self:getDiary(bookId, diaryId)
    if not diary then return end
    diary.content = content
    diary.view = view
end

-- 获取当前加载的日记页数
function WeddingBookMgr:getCurDiaryPage(bookId)
    local book = self:getBook(bookId)
    if not book then return 1 end

    return book.diaryPage or 1
end

function WeddingBookMgr:getNextDiaryPage(bookId)
    local book = self:getBook(bookId)
    if not book or not book.diaryPage then return end

    if book.diaryPage * COUNT_PER_PAGE >= book.diaryCount then return end

    return book.diaryPage + 1
end

-- 查看纪念日
function WeddingBookMgr:openDaySummary(bookId)
    gf:CmdToServer("CMD_WB_DAY_SUMMARY", {book_id = bookId})
end

-- 增加纪念日
function WeddingBookMgr:addDay(bookId, icon, name, dayTime, flag)
    gf:CmdToServer("CMD_WB_DAY_ADD", { book_id = bookId, icon = icon, name = name, day_time = dayTime, flag = flag })
end

-- 编辑纪念日
function WeddingBookMgr:editDay(bookId, dayId, icon, name, dayTime, flag)
    gf:CmdToServer("CMD_WB_DAY_EDIT", { book_id = bookId, day_id = dayId, icon = icon, name = name, day_time = dayTime, flag = flag })
end

-- 删除纪念日
function WeddingBookMgr:deleteDay(bookId, dayId)
    gf:CmdToServer("CMD_WB_DAY_DELETE", { book_id = bookId, day_id = dayId })
end

-- 获取纪念日
function WeddingBookMgr:getDay(bookId, dayId)
    local book = self:getBook(bookId)
    if not book or not book.days then return end
    local days = book.days
    return days[dayId]
end

-- 获取纪念日列表
function WeddingBookMgr:getDayList(bookId)
    local book = self:getBook(bookId)
    if not book or not book.days then return end
    local days = book.days
    local dayList = {}
    for _, v in pairs(days) do
        table.insert(dayList, v)
    end

    -- 排序
    -- 结婚纪念日为第一条
    -- 时间由近及远
    table.sort(dayList, function(l, r)
        if l.type == 1 then return true end
        if r.type == 1 then return false end

        if l.day_time > r.day_time then return true end
        if l.day_time < r.day_time then return false end
        return l.last_check_ti > r.last_check_ti
    end)

    return dayList
end

-- 打开相册
function WeddingBookMgr:openPhotoSummary(bookId, page)
    page = page or 1
    gf:CmdToServer("CMD_WB_PHOTO_SUMMARY", { book_id = bookId, page = page})
end

-- 提交相片
function WeddingBookMgr:addPhoto(bookId, img, memo, flag)
    gf:CmdToServer("CMD_WB_PHOTO_COMMIT", { book_id = bookId, img = img, memo = memo, flag = flag })
end

-- 编辑描述
function WeddingBookMgr:editPhoto(bookId, photoId, memo, flag)
    gf:CmdToServer("CMD_WB_PHOTO_EDIT_MEMO", { book_id = bookId, photo_id = photoId, memo = memo, flag = flag })
end

-- 删除相片
function WeddingBookMgr:deletePhoto(bookId, photoId)
    gf:CmdToServer("CMD_WB_PHOTO_DELETE", { book_id = bookId, photo_id = photoId })
end

-- 获取相片
function WeddingBookMgr:getPhoto(bookId, photoId)
    local book = self:getBook(bookId)
    if not book or not book.photos then return end
    return book.photos[photoId]
end

-- 获取相片列表
function WeddingBookMgr:getPhotoList(bookId)
    local book = self:getBook(bookId)
    if not book or not book.photos then return end
    local photoList = {}
    for _, v in pairs(book.photos) do
        table.insert(photoList, v)
    end

    table.sort(photoList, function(l, r)
        return l.publish_time > r.publish_time
    end)

    return photoList
end

function WeddingBookMgr:getCurPhotoPage(bookId)
    local book = self:getBook(bookId)
    if not book then return 1 end

    return book.photoPage or 1
end

function WeddingBookMgr:getNextPhotoPage(bookId)
    local book = self:getBook(bookId)
    if not book or not book.photoPage then return end

    if book.photoPage * COUNT_PER_PAGE >= book.photoCount then return end

    return book.photoPage + 1
end

-- 生成包裹道具
function WeddingBookMgr:onGetBagItem(data)
    if self.guideId and data.item_unique == self.guideId then
        data.isItemAround = true
    end
end

-- 点击包裹道具
function WeddingBookMgr:onClickBagItem(data)
    if self.guideId and data.item_unique == self.guideId then
        data.isItemAround = nil
        self.guidePos = nil
        EventDispatcher:removeEventListener(EVENT.GET_BAG_ITEM, WeddingBookMgr.onGetBagItem, WeddingBookMgr)
        EventDispatcher:removeEventListener(EVENT.BAG_ITEM_CLICK, WeddingBookMgr.onClickBagItem, WeddingBookMgr)
        EventDispatcher:removeEventListener(EVENT.BAGDLG_CLEANUP, WeddingBookMgr.onBagDlgCleanup, WeddingBookMgr)
    end
end

function WeddingBookMgr:onBagDlgCleanup(data)
    self.guidePos = nil
    EventDispatcher:removeEventListener(EVENT.GET_BAG_ITEM, WeddingBookMgr.onGetBagItem, WeddingBookMgr)
    EventDispatcher:removeEventListener(EVENT.BAG_ITEM_CLICK, WeddingBookMgr.onClickBagItem, WeddingBookMgr)
    EventDispatcher:removeEventListener(EVENT.BAGDLG_CLEANUP, WeddingBookMgr.onBagDlgCleanup, WeddingBookMgr)
end

function WeddingBookMgr:MSG_WB_HOME_INFO(data)
    if not self.books[data.book_id] then
        self.books[data.book_id] = data
    else
        local book = self.books[data.book_id]
        for k, v in pairs(data) do
            book[k] = v
        end
    end

    DlgMgr:openDlgEx("WeddingBookDlg", data.book_id)
    DlgMgr:reorderDlgByName("WeddingBookDlg")
end

-- 日记摘要信息
function WeddingBookMgr:MSG_WB_DIARY_SUMMARY(data)
    local book = self:getBook(data.book_id)
    if not book then return end
    if 1 == data.page then
        book.diarys = data.diarys
    else
        for k, v in pairs(data.diarys) do
            book.diarys[k] = v
        end
    end

    book.diaryCount = data.count
    book.diaryPage = data.page
end

-- 日记内容
function WeddingBookMgr:MSG_WB_DIARY(data)
    self:refreshDiary(data.book_id, data.diary_id, data.content, data.flag)
end

-- 增加日记结果
function WeddingBookMgr:MSG_WB_DIARY_ADD_RESULT(data)
end

-- 编辑日记结果
function WeddingBookMgr:MSG_WB_DIARY_EDIT_RESULT(data)
end

-- 删除日记结果
function WeddingBookMgr:MSG_WB_DIARY_DELETE_RESULT(data)
end

-- 纪念日内容
function WeddingBookMgr:MSG_WB_DAY_SUMMARY(data)
    local book = self:getBook(data.book_id)
    if not book then return end
    book.days = data.days
    book.dayCount = data.count
end

-- 增加纪念日结果
function WeddingBookMgr:MSG_WB_DAY_ADD_RESULT(data)
end

-- 编辑纪念日结果
function WeddingBookMgr:MSG_WB_DAY_EDIT_RESULT(data)
end

-- 删除纪念日结果
function WeddingBookMgr:MSG_WB_DAY_DELETE_RESULT(data)
end

-- 提交封面
function WeddingBookMgr:MSG_WB_HOME_PIC(data)
end

-- 提交相片
function WeddingBookMgr:MSG_WB_PHOTO_COMMIT_RESULT(data)
end

-- 编辑相片
function WeddingBookMgr:MSG_WB_PHOTO_EDIT_MEMO_RESULT(data)
end

-- 删除相片
function WeddingBookMgr:MSG_WB_PHOTO_DELETE_RESULT(data)
end

-- 相册列表
function WeddingBookMgr:MSG_WB_PHOTO_SUMMARY(data)
    local book = self:getBook(data.book_id)
    if not book then return end
    if 1 == data.page then
        book.photos = data.photos
    else
        for k, v in pairs(data.photos) do
            book.photos[k] = v
        end
    end
    book.photoCount = data.count
    book.photoPage = data.page
end

function WeddingBookMgr:MSG_WB_CREATE_BOOK_EFFECT(data)
    if data and data.pos then
        local item = InventoryMgr:getItemByPos(data.pos)
        if not item then return end
        self.guideId = item.item_unique
        DlgMgr:sendMsg("GameFunctionDlg", "doMarryEffect", data.pos)

        EventDispatcher:addEventListener(EVENT.GET_BAG_ITEM, WeddingBookMgr.onGetBagItem, WeddingBookMgr)
        EventDispatcher:addEventListener(EVENT.BAG_ITEM_CLICK, WeddingBookMgr.onClickBagItem, WeddingBookMgr)
        EventDispatcher:addEventListener(EVENT.BAGDLG_CLEANUP, WeddingBookMgr.onBagDlgCleanup, WeddingBookMgr)
    end
end

function WeddingBookMgr:MSG_WB_UPDATE_PHOTO(data)
    local book = self:getBook(data.book_id)
    if not book or not book.photos then return end
    local photo = book.photos[data.photo_id]
    if not photo then
        photo = {}
        photo.photo_id = data.photo_id
        book.photos[photo.photo_id] = photo
        book.photoCount = (book.photoCount or 0) + 1
    end
    photo.img = data.img
    photo.memo = data.memo
    photo.publish_time = data.publish_time
    photo.showFlag = data.showFlag
end

function WeddingBookMgr:MSG_WB_DELETE_PHOTO(data)
    local book = self:getBook(data.book_id)
    if not book or not book.photos then return end
    book.photos[data.photo_id] = nil
    book.photoCount = math.max((book.photoCount or 0) - 1, 0)
end

function WeddingBookMgr:MSG_WB_UPDATE_DIARY(data)
    local book = self:getBook(data.book_id)
    if not book or not book.diarys then return end
    local diary =  book.diarys[data.diary_id]
    if not diary then
        diary = {}
        diary.diary_id = data.diary_id
        book.diarys[diary.diary_id] = diary
        book.diaryCount = (book.diaryCount or 0) + 1
    end
    diary.last_edit_time = data.last_edit_time
    diary.content = data.content
    diary.general = data.general
    diary.flag = data.flag
    diary.icon = data.icon
    diary.showFlag = data.showFlag
end

function WeddingBookMgr:MSG_WB_DELETE_DIARY(data)
    local book = self:getBook(data.book_id)
    if not book or not book.diarys then return end
    book.diarys[data.diary_id] = nil
    book.diaryCount = math.max((book.diaryCount or 0) - 1, 0)
end

function WeddingBookMgr:MSG_WB_UPDATE_DAY(data)
    local book = self:getBook(data.book_id)
    if not book or not book.days then return end
    local day = book.days[data.day_id]
    if not day then
        day = {}
        day.day_id = data.day_id
        book.days[day.day_id] = day
        book.dayCount = (book.dayCount or 0) + 1
    end
    day.icon = data.icon
    day.name = data.name
    day.day_time = data.day_time
    day.type = data.type
    day.flag = data.flag
    day.last_check_ti  = data.last_check_ti
end

function WeddingBookMgr:MSG_WB_DELETE_DAY(data)
    local book = self:getBook(data.book_id)
    if not book or not book.days then return end
    book.days[data.day_id] = nil
    book.dayCount = math.max((book.dayCount or 0) - 1, 0)
end

function WeddingBookMgr:MSG_WB_UPDATE_HOME_PIC(data)
    local book = self:getBook(data.book_id)
    if not book then return end
    book.home_img = data.img
end

MessageMgr:regist("MSG_WB_HOME_INFO", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DIARY_SUMMARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DIARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DIARY_ADD_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DIARY_EDIT_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DIARY_DELETE_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DAY_SUMMARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DAY_ADD_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DAY_EDIT_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DAY_DELETE_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_HOME_PIC", WeddingBookMgr)
MessageMgr:regist("MSG_WB_PHOTO_COMMIT_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_PHOTO_EDIT_MEMO_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_PHOTO_DELETE_RESULT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_PHOTO_SUMMARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_CREATE_BOOK_EFFECT", WeddingBookMgr)
MessageMgr:regist("MSG_WB_UPDATE_PHOTO", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DELETE_PHOTO", WeddingBookMgr)
MessageMgr:regist("MSG_WB_UPDATE_DIARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DELETE_DIARY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_UPDATE_DAY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_DELETE_DAY", WeddingBookMgr)
MessageMgr:regist("MSG_WB_UPDATE_HOME_PIC", WeddingBookMgr)