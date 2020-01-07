-- BlogStateDlg.lua
-- Created by songcw Sep/20/2017
-- 个人空间

local BlogStateDlg = Singleton("BlogStateDlg", Dialog)

local MSG_LIMIT = 50 * 2
local UPLOAD_FILE_SIZE = 3 * 1024 * 1024    -- Unit:MB

function BlogStateDlg:init(param)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("DelButton", self.onDelButton)

    self:setCtrlVisible("DelButton", false)
    self.picturePath = {}
    self.orgPictPath = {}
    self.filePath = {}
    self.isLock = false

    self.parentDlg = param

    self:setLabelText("NoteLabel_3", string.format(CHS[4100865], 4))
    self:setLabelText("NoteLabel_2", string.format(CHS[4100864], 50))

    for i = 1, 4 do
        local ctl = self:getControl("PhotoPanel" .. i)
        ctl:setTag(i)
        self:bindListener("PhotoPanel" .. i, self.onPhotoPanel)
        if i ~= 1 then
         --   ctl:setVisible(false)
        end
    end

    self.newNameEdit = self:createEditBox("TextPanel", nil, nil, function(sender, type)
        if type == "ended" then
            self.newNameEdit:setText("")
            self:setCtrlVisible("ContentLabel", true)
        elseif type == "began" then
            local msg = self:getLabelText("ContentLabel")
            self.newNameEdit:setText(msg)
            self:setCtrlVisible("ContentLabel", false)
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelButton", false)
                self:setCtrlVisible("NoneLabel", true)
            else
                self:setCtrlVisible("NoneLabel", false)
                self:setCtrlVisible("DelButton", true)
            end

            self:setLabelText("ContentLabel", newName)

            local leftNum = math.floor((MSG_LIMIT - gf:getTextLength(newName)) / 2)
            self:setLabelText("NoteLabel_2", string.format(CHS[4100864], leftNum))
        end
    end)

    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setFont(CHS[3003597], 19)
    self.newNameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.newNameEdit:setText("")
end

-- 表情界面关闭时
function BlogStateDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("BlogStateDlg")
end

-- 插入表情
function BlogStateDlg:addExpression(expression)

    local content = self:getLabelText("ContentLabel")
    if gf:getTextLength(content .. expression) > MSG_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. expression

    if not self:getCtrlVisible("ContentLabel") then
        -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
        self.newNameEdit:setText(content)
    end

    self:setLabelText("ContentLabel", content)
    self:setCtrlVisible("NoneLabel", false)
    self:setCtrlVisible("DelButton", true)
end

-- 切换输入
function BlogStateDlg:swichWordInput()
    if not self.newNameEdit then return end

    self.newNameEdit:sendActionsForControlEvents(cc.CONTROL_EVENTTYPE_TOUCH_UP_INSIDE)
end

-- 增加空格
function BlogStateDlg:addSpace()
    local content = self:getLabelText("ContentLabel")
    if gf:getTextLength(content .. " ") > MSG_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. " "

    if not self:getCtrlVisible("ContentLabel") then
        -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
        self.newNameEdit:setText(content)
    end

    self:setLabelText("ContentLabel", content)
    self:setCtrlVisible("NoneLabel", false)
    self:setCtrlVisible("DelButton", true)
end

-- 删除字符
function BlogStateDlg:deleteWord()
    local text = self:getLabelText("ContentLabel")
    local len  = string.len(text)
    local deletNum = 0

    if len > 0 then
        if string.byte(text, len) < 128 then       -- 一个字符
            deletNum = 1
        elseif string.byte(text, len - 1) >= 128 and string.byte(text, len - 2) >= 224 then    -- 三个字符
            deletNum = 3
        elseif string.byte(text, len - 1) >= 192 then     -- 两个个字符
            deletNum = 2
        end

        local newtext = string.sub(text, 0, len - deletNum)
        if not self:getCtrlVisible("ContentLabel") then
            -- 该情况，iOS和安卓可能处于编辑状态。win看不出来
            self.newNameEdit:setText(newtext)
        end

        self:setLabelText("ContentLabel", newtext)
        self:setCtrlVisible("NoneLabel", false)
        self:setCtrlVisible("DelButton", true)

        if len - deletNum <= 0 then
            self:setCtrlVisible("NoneLabel", true)
            self:setCtrlVisible("DelButton", false)
        end
    else
        self:setCtrlVisible("DelButton", false)
    end
end

-- 发送消息
function BlogStateDlg:sendMessage(content)
    DlgMgr:closeDlg("LinkAndExpressionDlg")
    self:onConfrimButton()
end

function BlogStateDlg:onExpressionButton(sender, eventType)
    if self.isLock then return end
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "blog")

    -- 界面上推
    local mainPanel = self:getControl("MainPanel")
    local heigth = math.max(0, dlg:getMainBodyHeight() - mainPanel:getPositionY())
    DlgMgr:upDlg("BlogStateDlg", heigth)
end

function BlogStateDlg:onFinishUploadIcon1(files, uploads)
    -- 标记一下，不在上传中
    local panel = self:getControl("PhotoPanel1")

    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[4200457])
        ChatMgr:sendMiscMsg(CHS[4200457])
        panel.isUploading = false
        self:hideProssBar()
        self:setCtrlEnabled("ConfrimButton", true)
        self.isLock = false
        self:makeEditEnabled(true)
        return
    end

    local bar = self:getControl("ProgressBar", nil, "PhotoPanel1")
    bar:stopAllActions()
    local curValue = bar:getPercent()
    self:setProgressBarByHourglassToEnd("ProgressBar", 300, curValue, 100, function ()
        self:setCtrlVisible("PhotoImage", true, "PhotoPanel1")
        self:setImage("PhotoImage", files[1], "PhotoPanel1")
        self:setImageSize("PhotoImage", cc.size(64, 64), "PhotoPanel1")

        self:setCtrlVisible("AddImage", false, "PhotoPanel1")
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel1")

        self.picturePath[1] = uploads[1]
        self.orgPictPath[1] = files[1]

        panel.isUploading = false

        self:startByOrder(2)
    end, "PhotoPanel1")
end

function BlogStateDlg:onFinishUploadIcon2(files, uploads)
    -- 标记一下，不在上传中
    local panel = self:getControl("PhotoPanel2")

    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[4200457])
        ChatMgr:sendMiscMsg(CHS[4200457])
        panel.isUploading = false
        self:hideProssBar()
        self:setCtrlEnabled("ConfrimButton", true)
        self.isLock = false
        self:makeEditEnabled(true)
        return
    end

    local bar = self:getControl("ProgressBar", nil, "PhotoPanel2")
    bar:stopAllActions()
    local curValue = bar:getPercent()
    self:setProgressBarByHourglassToEnd("ProgressBar", 300, curValue, 100, function ()
        self:setCtrlVisible("PhotoImage", true, "PhotoPanel2")
        self:setImage("PhotoImage", files[1], "PhotoPanel2")
        self:setImageSize("PhotoImage", cc.size(64, 64), "PhotoPanel2")

        self:setCtrlVisible("AddImage", false, "PhotoPanel2")
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel2")

        self.picturePath[2] = uploads[1]
        self.orgPictPath[2] = files[1]

        panel.isUploading = false

        self:startByOrder(3)
        end, "PhotoPanel2")
end

function BlogStateDlg:onFinishUploadIcon3(files, uploads)
    -- 标记一下，不在上传中
    local panel = self:getControl("PhotoPanel3")

    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[4200457])
        ChatMgr:sendMiscMsg(CHS[4200457])
        panel.isUploading = false
        self:hideProssBar()
        self:setCtrlEnabled("ConfrimButton", true)
        self.isLock = false
        self:makeEditEnabled(true)
        return
    end

    local bar = self:getControl("ProgressBar", nil, "PhotoPanel3")
    bar:stopAllActions()
    local curValue = bar:getPercent()
    self:setProgressBarByHourglassToEnd("ProgressBar", 300, curValue, 100, function ()
        self:setCtrlVisible("PhotoImage", true, "PhotoPanel3")
        self:setImage("PhotoImage", files[1], "PhotoPanel3")
        self:setImageSize("PhotoImage", cc.size(64, 64), "PhotoPanel3")

        self:setCtrlVisible("AddImage", false, "PhotoPanel3")
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel3")

        self.picturePath[3] = uploads[1]
        self.orgPictPath[3] = files[1]

        panel.isUploading = false
        self:startByOrder(4)
    end, "PhotoPanel3")
end

function BlogStateDlg:onFinishUploadIcon4(files, uploads)
    -- 标记一下，不在上传中
    local panel = self:getControl("PhotoPanel4")
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[4200457])
        ChatMgr:sendMiscMsg(CHS[4200457])
        panel.isUploading = false
        self:setCtrlEnabled("ConfrimButton", true)
        self.isLock = false
        self:makeEditEnabled(true)
        self:hideProssBar()
        return
    end

    local bar = self:getControl("ProgressBar", nil, "PhotoPanel4")
    bar:stopAllActions()
    local curValue = bar:getPercent()
    self:setProgressBarByHourglassToEnd("ProgressBar", 300, curValue, 100, function ()
        self:setCtrlVisible("PhotoImage", true, "PhotoPanel4")
        self:setImage("PhotoImage", files[1], "PhotoPanel4")
        self:setImageSize("PhotoImage", cc.size(64, 64), "PhotoPanel4")

        self:setCtrlVisible("AddImage", false, "PhotoPanel4")
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel4")

        self.picturePath[4] = uploads[1]
        self.orgPictPath[4] = files[1]

        panel.isUploading = false

        self:toUpload()
    end, "PhotoPanel4")
end

function BlogStateDlg:hideProssBar()
    for i = 1, 4 do
        self:setCtrlVisible("ProgressPanel", false, "PhotoPanel" .. i)
    end
end

function BlogStateDlg:getPhotoLoadNum()
    local loadCount = 0
    for i = 1, 4 do
        if self.filePath[i] then
            loadCount = loadCount + 1
        end
    end

    return loadCount
end

function BlogStateDlg:onViewPhoto(sender)
    local tag = sender:getTag()
    if not self.filePath[tag] then return end

    local path = ""
    local haveCount = 0
    local cur = 0
    BlogMgr.orgPicturePath = {}
    for i = 1, 4 do
        if self.filePath[i] then
            if path == "" then
                path = self.filePath[i]
            else
                path = path .. "|" .. self.filePath[i]
            end

            if self.orgPictPath[i] then
                BlogMgr.orgPicturePath[i] = {path = self.orgPictPath[i], key = self.filePath[i]}
            end

            haveCount = haveCount + 1

            if tag == i then
                cur = haveCount
            end
        end
    end

    local dlg = DlgMgr:openDlg("BlogPhotoDlg")
    dlg:setPicture(cur, path, nil, true)
end

function BlogStateDlg:onPhotoPanel(sender, eventType)
    local tag = sender:getTag()
    if self.filePath[tag] then
        BlogMgr:showButtonList(self, sender, "blogStateDel", self.name)
    else
        BlogMgr:showButtonList(self, sender, "blogStateSel", self.name)
    end
end

function BlogStateDlg:startUpload(panelName)
    local panel = self:getControl(panelName)
    panel.isUploading = true
    self:setCtrlVisible("ProgressPanel", true, panelName)
    --self:setProgressBarByHourglass("ProgressBar", 1000, 0, nil, panelName)
    self:setProgressBarByHourglassToEnd("ProgressBar", 2000, 0, 80, nil, panelName)
end

function BlogStateDlg:pickImageDone(key, files)
    local f = io.open(files, 'rb')
    local data = f:read("*a")
    f:close()

    if #data > UPLOAD_FILE_SIZE then
        gf:ShowSmallTips(CHS[2100132])
        return
    end

    local panelName = self:getControl("PhotoPanel" .. key)

    self.orgPictPath[key] = files
    self.filePath[key] = files

    self:setImage("PhotoImage", files, "PhotoPanel" .. key)
    -- self:setImageSize("PhotoImage", cc.size(64, 64), "PhotoPanel" .. key)
    self:setSmallImageSize("PhotoImage", "PhotoPanel" .. key)

    self:setCtrlVisible("AddImage", false, "PhotoPanel" .. key)
    self:setCtrlVisible("PhotoImage", true, "PhotoPanel" .. key)

    self:setLabelText("NoteLabel_3", string.format(CHS[4100865], 4 - self:getPhotoLoadNum()))
end

function BlogStateDlg:setSmallImageSize(imageName, panel)
    local image = self:getControl(imageName, nil, panel)
    local orgSize = image:getContentSize()
    -- 64 * 64缩略图尺寸
    local w1 = orgSize.width
    local h1 = orgSize.height
    local w2 = 64
    local h2 = 64

    if w1 / h1 > w2 / h2 then
        self:setImageSize(imageName, cc.size(w1 * h2 / h1, h2), panel)
    else
        self:setImageSize(imageName, cc.size(w2, h1 * w2 / w1), panel)
    end

end

function BlogStateDlg:copyFile(index, filePath)

    -- 当前版本，处理ios防止文件便大，新加一个就清空了目录，所以放进其他目录下
    local f = io.open(filePath, "rb")
    local data = f:read("*a")

    local fileName = string.format("blogTemp/PhotoPanel%d.png", index)
    if string.match(filePath, ".jpg") then fileName = string.format("blogTemp/PhotoPanel%d.jpg", index) end

    if gfSaveFile("", fileName) then
        local retFile = io.open(cc.FileUtils:getInstance():getWritablePath() .. fileName, "wb")
        retFile:write(data)
        retFile:flush()
        retFile:close()
    end
    f:close()
    return cc.FileUtils:getInstance():getWritablePath() .. fileName
end

function BlogStateDlg:doPhotoPanel(index, filePath)
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

    local retPath = self:copyFile(index, filePath)

    cc.Director:getInstance():getTextureCache():removeTextureForKey(retPath)
    cc.Director:getInstance():getTextureCache():reloadTexture(retPath)

    DlgMgr:sendMsg("BlogStateDlg", "pickImageDone", index, retPath)
end

-- 当前不支持传入其他参数，所以只能充回调接口写多套来实现了......
function PhotoPanel1(filePath)
    return DlgMgr:sendMsg("BlogStateDlg", "doPhotoPanel", 1, filePath)
end

function PhotoPanel2(filePath)
    return DlgMgr:sendMsg("BlogStateDlg", "doPhotoPanel", 2, filePath)
end

function PhotoPanel3(filePath)
    return DlgMgr:sendMsg("BlogStateDlg", "doPhotoPanel", 3, filePath)
end

function PhotoPanel4(filePath)
    return DlgMgr:sendMsg("BlogStateDlg", "doPhotoPanel", 4, filePath)
end

function BlogStateDlg:onSelectPhote(sender, state)
    local cw, ch = BlogMgr:getPhotoClipRange()
    gf:comDoOpenPhoto(state, sender:getName(), cc.size(cw, ch), cc.size(756, 504), 80, state)
end

function BlogStateDlg:onDeletePhote(sender)
    self:setCtrlVisible("PhotoImage", false, sender)

    self:setCtrlVisible("AddImage", true, sender)
    self:setCtrlVisible("ProgressPanel", false, sender)

    local tag = sender:getTag()
    self.picturePath[tag] = nil
    self.orgPictPath[tag] = nil
    self.filePath[tag] = nil
    self:setLabelText("NoteLabel_3", string.format(CHS[4100865], 4 - self:getPhotoLoadNum()))
end

function BlogStateDlg:onDelButton(sender, eventType)
    self:setLabelText("ContentLabel", "")
    self:setCtrlVisible("NoneLabel", true)
    self:setCtrlVisible("DelButton", false)
    self:setLabelText("NoteLabel_2", string.format(CHS[4100864], 50))
end

-- 上传过程让edit失效，setCtrlTouchEnabled接口无用，设置一个新层遮住
function BlogStateDlg:makeEditEnabled(enble)
    if enble then
        local layer = self:getControl("yahaha", nil, "MainPanel")
        if layer then layer:removeFromParent() end
        return
    end

    local layer = ccui.Layout:create()

    layer:setContentSize(self:getCtrlContentSize("TextPanel"))
    layer:setTouchEnabled(true)

    local x, y = self:getControl("TextPanel"):getPosition()
    layer:setLocalZOrder(100000000)
    layer:setPosition(x, y)
    layer:setName("yahaha")
    self:getControl("MainPanel"):addChild(layer)
    self:getControl("MainPanel"):setLayoutType(ccui.LayoutType.ABSOLUTE)

    self:updateLayout("MainPanel")
end

function BlogStateDlg:startByOrder(cur)
    local lock = false

    for i = cur, 4 do
        if self.filePath[i] then

            if not lock then
                BlogMgr:cmdUpload(BLOG_OP_TYPE.BLOG_OP_UPLOAD_CIRCLE, "BlogStateDlg", "onFinishUploadIcon" .. i, self.filePath[i])
                DlgMgr:sendMsg("BlogStateDlg", "startUpload", "PhotoPanel" .. i)
                lock = i
                self:setCtrlEnabled("ConfrimButton", false)
                self:makeEditEnabled(false)
                self.isLock = true
            end

            self:setCtrlVisible("ProgressPanel", true, "PhotoPanel" .. i)
            self:setProgressBar("ProgressBar", 0, 100, "PhotoPanel" .. i)
        end
    end

    if not lock then
        self:toUpload()
    end
end

function BlogStateDlg:toUpload()

    local content = self:getLabelText("ContentLabel")

    BlogMgr.orgPicturePath = {}
    local path = ""
    for i = 1, 4 do
        if self.picturePath[i] then
            if path == "" then
                path = self.picturePath[i]
            else
                path = path .. "|" .. self.picturePath[i]
            end
        end

        if self.orgPictPath[i] then
            BlogMgr.orgPicturePath[i] = {path = self.orgPictPath[i], key = self.picturePath[i]}
        end
    end

    if path == "" and string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[5400577])
        return
    end

    local viewType = DlgMgr:sendMsg(self.parentDlg, "getCheckState") or 0
    BlogMgr:publishStatus(content, path, viewType)
    self:onCloseButton()
end

function BlogStateDlg:onConfrimButton(sender, eventType)
    local content = self:getLabelText("ContentLabel")

    local nameText, haveBadName = gf:filtText(content, nil, true)
    if haveBadName then
        gf:confirm(CHS[4100770], function ()
            self:setLabelText("ContentLabel", nameText)
            gf:ShowSmallTips(CHS[4200454])
            ChatMgr:sendMiscMsg(CHS[4200454])
        end, nil, nil, nil, nil, nil, true)
        return
    end

    self:startByOrder(1)
end

function BlogStateDlg:onDlgOpened(param)
    if param[1] == "shareImage" then
        if string.isNilOrEmpty(param[2]) then return end

        -- WDSY-31366,修改为不直接上传，设置图片即可
        self:pickImageDone(1, param[2])

      	--  BlogMgr:cmdUpload(BLOG_OP_TYPE.BLOG_OP_UPLOAD_CIRCLE, "BlogStateDlg", "onFinishUploadIcon1", param[2])
        --  DlgMgr:sendMsg("BlogStateDlg", "startUpload", "PhotoPanel1")
    end
end

return BlogStateDlg
