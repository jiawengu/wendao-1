-- BlogInfoDlg.lua
-- Created by sujl
-- 个人信息

local BlogInfoDlg = Singleton("BlogInfoDlg", Dialog)
local BLOG_TAGS = require("cfg/BlogTags")
local oss = require('core/oss')
local RadioGroup = require("ctrl/RadioGroup")

function BlogInfoDlg:init()
    self:bindListener("MoreButton", self.onMoreButton)
    self:blindLongPress("BKImage_3", self.onLongClickPortrait, self.onClickPortrait, "ShowPanel")
    self:bindListener("PositionPanel", self.onClickPositionPanel)
    self:bindListener("SignPanel", self.onClickSignPanel)
    self:blindLongPress("SignPanel", self.onLongClickSign, self.onClickSignPanel)
    self:bindListener("IconPanel", self.onClickLabel)
    self:bindListener("NonePanel", self.onClickLabel, "IconPanel")
    self:bindListener("DecorateButton", self.onDecorateButton, "ShowPanel")

    -- 空间装饰相关
    self:bindFloatPanelListener("DecoratePanel", "DecorateButton", "ShowPanel")
    self.itemPanel = self:retainCtrl("ItemPanel", "DecoratePanel")
    self.chosenImage = self:retainCtrl("ChosenEffectImage", self.itemPanel)
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"IconCheckBox", "BackCheckBox"}, self.onDecCheckbox, "DecoratePanel")
    self.selectDecName = {}

    self:refreshShowPanel()

    self:hookMsg("MSG_BLOG_CHAR_INFO")
    self:hookMsg("MSG_BLOG_DECORATION_LIST")
    self:hookMsg("MSG_DECORATION_LIST")
end

function BlogInfoDlg:cleanup()
    self:stopPlayVoice()
end

function BlogInfoDlg:refreshShowPanel()
    self:setLabelText("NameLabel", BlogMgr:getUserName(self.name), "ShowPanel")
    local polarPath = BlogMgr:getPolarImage(self.name)
    local polarImage = self:getControl("TypeImage", nil, "ShowPanel")
    if polarImage and polarPath then
        polarImage:loadTexture(polarPath, ccui.TextureResType.plistType)
    end

    self:refreshPortrait()
    self:refreshLocation()
    self:refreshSignature()
    self:refreshTag()
    self:refreshDecorate()

    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    self:setCtrlVisible("MoreButton", BlogMgr:isSameDist(gid))
end

-- 刷新装饰相关
function BlogInfoDlg:refreshDecorate()
    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    self.decoratesInfo = nil
    self.showDecorateType = nil
    if gid then
        local name = BlogMgr:getBlogDecorateName(gid, "blog_head") or ""
        self:setPortraitDecorate(name)

        self:setCtrlVisible("DecoratePanel", false)
        local data = BlogMgr:getMyDecorateInfo() or {}
        if gid == Me:queryBasic("gid") and BlogMgr:checkHasDecorate() then
            self.selectDecName = {}
            self.decoratesInfo = data
            self:setCtrlVisible("DecorateButton", true, "ShowPanel")
        else
            self:setCtrlVisible("DecorateButton", false, "ShowPanel")
        end
    end
end

-- 设置头像装饰品
function BlogInfoDlg:setPortraitDecorate(name)
    self:setCtrlVisible("StarPanel", name == CHS[5400444], "MakeUpPanel")
end

-- 空间装饰
function BlogInfoDlg:setDecorates(data)
    local info = data[self.showDecorateType] or {{name = "", time = -1}}

    -- 获取当前选中的装饰
    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    self.selectDecName[self.showDecorateType] = BlogMgr:getBlogDecorateName(gid, self.showDecorateType) or ""

    local scrollView = self:getControl("ItemsScrollView", nil, "DecoratePanel")
    self:initScrollViewPanel(info, self.itemPanel, self.setDecItemPanel, scrollView, #info, 5, 5, 10, 16, ccui.ScrollViewDir.horizontal)
end

-- 设置单个装饰信息
function BlogInfoDlg:setDecItemPanel(cell, data)
    if data.name == "" then
        self:setImage("IconImage", ResMgr.ui.default_icon, cell)
    else
        self:setImage("IconImage", ResMgr:getIconPathByName(data.name), cell)
    end

    if self.selectDecName[self.showDecorateType] == data.name then
        self.chosenImage:removeFromParent()
        cell:addChild(self.chosenImage)

        -- 装饰名
        if data.name == "" then
            if self.showDecorateType == "blog_head" then
                self:setLabelText("UseLabel", CHS[5400442], "DecoratePanel")
            else
                self:setLabelText("UseLabel", CHS[5400443], "DecoratePanel")
            end
        else
            self:setLabelText("UseLabel", data.name, "DecoratePanel")
        end

        -- 使用期限
        local curTime = gf:getServerTime()
        if data.time == -1 then
            self:setLabelText("TimeLabel", CHS[5400440], "DecoratePanel")
        elseif curTime > data.time then
            self:setLabelText("TimeLabel", CHS[7000092], "DecoratePanel")
        else
            self:setLabelText("TimeLabel", os.date(CHS[5410193], data.time), "DecoratePanel")
        end

        self.selectDecItem = cell
    end

    local function longListener(self, sender, eventType)
        if data.name ~= "" then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(data.name, rect)
        end
    end

    local function listener(self, sender, eventType)
        if self.selectDecItem == sender then
            return
        end

        gf:CmdToServer("CMD_DECORATION_APPLY", {
            count = 1,
            list = {{type = self.showDecorateType, name = data.name or ""}}
        })
    end

    self:blindLongPressWithCtrl(cell, longListener, listener)
end

function BlogInfoDlg:onDecorateButton()
    if self.decoratesInfo then
        self:setCtrlVisible("DecoratePanel", true)
        if not self.showDecorateType then
            if not self.decoratesInfo["blog_head"] or #self.decoratesInfo["blog_head"] == 0 then
                self.radioGroup:selectRadio(2)
            else
                self.radioGroup:selectRadio(1)
            end
        end
    end
end

function BlogInfoDlg:onDecCheckbox(sender)
    local name = sender:getName()
    if "IconCheckBox" == name then
        self.showDecorateType = "blog_head"
        self:setDecorates(self.decoratesInfo or {})
    else
        self.showDecorateType = "blog_floor"
        self:setDecorates(self.decoratesInfo or {})
    end
end

function BlogInfoDlg:refreshPortrait()
    local path = BlogMgr:getIcon(self.name)
    if BlogMgr:isDefaultIcon(self.name) then
        self:setPortrait(path, 0.75)
    else
        self:setCtrlVisible("LoadBKImage", true, "ShowPanel")
        BlogMgr:assureFile("setPortrait", self.name, path)
    end
    self:setCtrlVisible("ExamineImage", BlogMgr:isReview(self.name), "ShowPanel")
end

function BlogInfoDlg:setPortrait(filePath, scale)
    local panel = self:getControl("ShapePanel", Const.UIImage, "ShowPanel")
    if panel then
        panel:removeAllChildren()
        if string.isNilOrEmpty(filePath) then return end
        local sp = cc.Sprite:create(filePath)
        if not sp then return end
        local contentSize = sp:getContentSize()
        local pSize = panel:getContentSize()
        sp:setScale(scale or (pSize.width / contentSize.width))
        sp:setPosition(cc.p(pSize.width / 2, pSize.height / 2))
        panel:addChild(sp)
    end
    self:setCtrlVisible("LoadBKImage", false, "ShowPanel")
end

-- 刷新位置信息
function BlogInfoDlg:refreshLocation()
    local location = BlogMgr:getLocation(self.name)
    if string.isNilOrEmpty(location) then
        self:setLabelText("TextLabel", CHS[2000434], "PositionPanel")
    else
        self:setLabelText("TextLabel", BlogMgr:getLocationShowStr(location), "PositionPanel")
    end
end

-- 刷新签名
function BlogInfoDlg:refreshSignature()
    local signature, voice, time = BlogMgr:getSignature(self.name)
    self:setCtrlVisible("VoicePane", not string.isNilOrEmpty(voice), "SignPanel")
    self:setCtrlVisible("SignTextPanel", false, "SignPanel")
    self:setCtrlVisible("SignTextLabel", string.isNilOrEmpty(voice), "SignPanel")

    if string.isNilOrEmpty(voice) then
        if string.isNilOrEmpty(signature) then
            if BlogMgr:isMySelf(self.name) then
                -- self:setColorText(CHS[2000435], "SignTextPanel", "SignPanel", nil, nil, COLOR3.GRAY, 17)
                self:setLabelText("SignTextLabel", CHS[2000435], "SignPanel")
            else
                -- self:setColorText(CHS[2000436], "SignTextPanel", "SignPanel", nil, nil, COLOR3.GRAY, 17)
                self:setLabelText("SignTextLabel", CHS[2000436], "SignPanel")
            end
        else
            -- self:setColorText(signature, "SignTextPanel", "SignPanel", nil, nil, COLOR3.ORANGE, 17)
            self:setLabelText("SignTextLabel", signature, "SignPanel")
        end
    else
        self:setLabelText("TimeLabel", string.format(CHS[2000462], time or 0), self:getControl("VoicePane", nil, "SignPanel"))
        if gf:getTextLength(signature) > 20 * 2 then
            signature = gf:subString(signature, 20 * 2) .. "..."
        end
        self:setLabelText("TextLabel", signature, self:getControl("VoicePane", nil, "SignPanel"))
    end
end

-- 刷新标签
function BlogInfoDlg:refreshTag()
    local tagStr = BlogMgr:getTags(self.name)
    if string.isNilOrEmpty(tagStr) then
        self:setCtrlVisible("AddImag", BlogMgr:isMySelf(self.name), self:getControl("NonePanel", nil, "IconPanel"))
        -- self:setLabelText("TextLabel", BlogMgr:isMySelf(self.name) and CHS[2000437] or CHS[2000438], self:getControl("NonePanel", nil, "IconPanel"))
        self:setCtrlVisible("NoneLabel", not BlogMgr:isMySelf(self.name), "IconPanel")
        self:setCtrlVisible("NonePanel", BlogMgr:isMySelf(self.name), "IconPanel")
        for i = 1, 4 do
            self:setCtrlVisible("IconImage" .. i, false, "IconPanel")
        end
    else
        self:setCtrlVisible("NoneLabel", false, "IconPanel")
        self:setCtrlVisible("NonePanel", false, "IconPanel")
        local tags = gf:split(tagStr, "|")
        for i = 1, #tags do
            self:setCtrlVisible("IconImage" .. i, true, "IconPanel")
            local tagIndex = tonumber(tags[i])
            local typeIndex = math.floor(tagIndex / 100)
            local labelIndex = tagIndex - typeIndex * 100
            local typeTags = BLOG_TAGS[BLOG_TAGS["type"][typeIndex]]
            if typeTags then
                self:setLabelText("Label_136", typeTags[labelIndex], self:getControl("IconImage" .. i, nil, "IconPanel"))
            end
        end

        for i = #tags + 1, 4 do
            self:setCtrlVisible("IconImage" .. i, false, "IconPanel")
        end
    end
end

function onBlogPortraitUpload(filePath)
    DlgMgr:sendMsg("BlogInfoDlg", "uploadPortrait", filePath)
end

function BlogInfoDlg:getUserData()
    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    return BlogMgr:getUserDataByGid(gid)
end

function BlogInfoDlg:uploadPortrait(filePath)
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

    local userData = self:getUserData()
    local dlg = DlgMgr:openDlg("BlogPhotoConfirmDlg")
    dlg:setData(userData, filePath, self.name)
end

function BlogInfoDlg:doOpenPhoto(state)
    BlogMgr:comDoOpenPhoto(state, "onBlogPortraitUpload")
end

-- 打开相册
function BlogInfoDlg:openPhoto(state)
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[2000440])
        return
    end

    local elapse = gf:getServerTime() - BlogMgr:getLastIconModifyTime(self.name)
    if elapse < 30 * 60 then
        gf:ShowSmallTips(string.format(CHS[2000441], 30 - math.floor(elapse / 60)))
        return
    end

    if self:checkSafeLockRelease('doOpenPhoto', state) then
        return
    end

    self:doOpenPhoto(state)
end

-- 删除头像
function BlogInfoDlg:deleteIcon()
    gf:confirm(CHS[2000442], function()
        gf:CmdToServer("CMD_BLOG_DELETE_ICON")
    end)
end

-- 举报头像
function BlogInfoDlg:reportIcon()
    -- CMD_BLOG_REPORT
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[2000443])
        return
    end

    if BlogMgr:isDefaultIcon(self.name) then
        gf:ShowSmallTips(CHS[2000444])
        return
    end

    local gid = BlogMgr:getUserGid(self.name)
    gf:CmdToServer('CMD_BLOG_REPORT', { user_dist = BlogMgr:getDistByGid(gid), user_gid = gid, op_type = BLOG_OP_TYPE.BLOG_OP_REPORT_ICON, text = BlogMgr:getIcon(self.name) })
end

-- 举报签名
function BlogInfoDlg:reportSign()
    if Me:queryBasicInt("level") < 40 then
        gf:ShowSmallTips(CHS[2000445])
        return
    end

    local gid = BlogMgr:getUserGid(self.name)
    gf:CmdToServer('CMD_BLOG_REPORT', { user_dist = BlogMgr:getDistByGid(gid), user_gid = gid, op_type = BLOG_OP_TYPE.BLOG_OP_REPORT_ISIGNATURE, text = BlogMgr:getSignature(self.name) })
end

function BlogInfoDlg:stopPlayVoice()
    ChatMgr:setIsPlayingVoice(false)
    SoundMgr:replayMusicAndSound()
    ChatMgr:stopPlayRecord()

    local actionImg = self.playAction
    self.playAction = nil
    if actionImg then
        self:setCtrlVisible("TimeIconImage", true, actionImg:getParent())
        actionImg:stopAllActions()
        actionImg:removeFromParent()
    end
end

function BlogInfoDlg:playVoice(filePath)
    if not self.playAction or string.isNilOrEmpty(filePath) then
        self:stopPlayVoice()
        return
    end

    ChatMgr:stopPlayRecord()
    local actionImg = self.playAction
    actionImg:setVisible(true)
    self:setCtrlVisible("TimeIconImage", false, actionImg:getParent())
    local _, _, time  = BlogMgr:getSignature(self.name)
    schedule(actionImg, function()
        time = time - 0.1
        if time <= 0 then
            self:stopPlayVoice()
        end
    end, 0.1)

    ChatMgr:setIsPlayingVoice(true)
    ChatMgr:playRecord(filePath, 1, time, true, function()
        DlgMgr:sendMsg("BlogInfoDlg", "stopPlayVoice")
    end)
    ChatMgr:clearPlayVoiceList()
    SoundMgr:stopMusicAndSound()
end

function BlogInfoDlg:onMoreButton(sender, eventType)
    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    local dlg = DlgMgr:openDlgEx("BlogMoreInfoDlg", gid)
    if dlg then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        dlg:setFloatingFramePos(rect)
    end
end

function BlogInfoDlg:onLongClickPortrait(sender, eventType)
    if BlogMgr:isMySelf(self.name) then
        self:onClickPortrait(sender, eventType)
        return
    end

    local dlg = BlogMgr:showButtonList(self, sender, "reportPortrait", self.name)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(x - 50, y + 50))
end

function BlogInfoDlg:onClickPortrait(sender, eventType)
    if not BlogMgr:isMySelf(self.name) then return end

    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    local dlg = BlogMgr:showButtonList(self, sender, "showPortrait", self.name)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(x - 50, y + 50))
end

-- 位置设置
function BlogInfoDlg:onClickPositionPanel(sender, eventType)
    if not BlogMgr:isMySelf(self.name) then return end

    local gid = BlogMgr:getBlogGidByDlgName(self.name)
    DlgMgr:openDlgEx("BlogAddressDlg", gid)
end

function BlogInfoDlg:onLongClickSign(sender, eventType)
    if BlogMgr:isMySelf(self.name) then
        self:onClickSignPanel(sender, eventType)
        return
    end

    local dlg = BlogMgr:showButtonList(self, sender, "reportSign", self.name)
    local x, y = dlg.root:getPosition()
    dlg.root:setPosition(cc.p(x - 100, y - 120))
end

function BlogInfoDlg:onClickSignPanel(sender, eventType)
    if BlogMgr:isMySelf(self.name) then
        if Me:queryBasicInt("level") < 40 then
            gf:ShowSmallTips(CHS[2000446])
            return
        end

        local gid = BlogMgr:getBlogGidByDlgName(self.name)
        DlgMgr:openDlgEx("BlogSignDlg", gid)
    else
        if self.playAction then
            self:stopPlayVoice()
            return
        end

        local _, voice, _ = BlogMgr:getSignature(self.name)
        if string.isNilOrEmpty(voice) then return end

        local voiceSignImg = self:getControl("TimeIconImage", nil, sender)
        local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
        actionImg:setAnchorPoint(0.5, 0.5)
        actionImg:setVisible(false)
        actionImg:setPosition(voiceSignImg:getPosition())
        voiceSignImg:getParent():addChild(actionImg, 0, 997)
        self.playAction = actionImg

        actionImg:registerScriptHandler(function(event)
            if "cleanup" == event then
                if self.playAction then
                    assert(false, "Unexpected error occour at BlogInfoDlg")
                end
            end
        end)

        BlogMgr:assureFile("playVoice", self.name, voice)
    end
end

function BlogInfoDlg:onClickLabel(sender, eventType)
    if BlogMgr:isMySelf(self.name) then
        DlgMgr:openDlgEx("BlogLabelDlg", Me:queryBasic("gid"))
    end
end

-- 头像上传完成
function BlogInfoDlg:onFinishUploadIcon(files, uploads)
    if #files ~= #uploads then
        gf:ShowSmallTips(CHS[2000447])
        ChatMgr:sendMiscMsg(CHS[2000447])
        return
    end

    gf:CmdToServer("CMD_BLOG_CHANGE_ICON", { icon_img = uploads[1] })
end

function BlogInfoDlg:MSG_BLOG_CHAR_INFO(data)
    if data.user_gid ~= BlogMgr:getBlogGidByDlgName(self.name) then return end
    self:refreshShowPanel()
end

-- 当前空间的装饰
function BlogInfoDlg:MSG_BLOG_DECORATION_LIST(data)
    if data.user_gid == BlogMgr:getBlogGidByDlgName(self.name) then
        self:setPortraitDecorate(BlogMgr:getBlogDecorateName(data.user_gid, "blog_head"))
    end
end

-- 玩家自己更换装饰刷新
function BlogInfoDlg:MSG_DECORATION_LIST()
    local gid = Me:queryBasic("gid")
    if gid == BlogMgr:getBlogGidByDlgName(self.name) then
        if self.showDecorateType then
            self.decoratesInfo = BlogMgr:getMyDecorateInfo()
            self:setDecorates(self.decoratesInfo)
        end

        self:setPortraitDecorate(BlogMgr:getBlogDecorateName(gid, "blog_head"))
    end
end

return BlogInfoDlg
