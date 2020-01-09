-- MatchmakingDlg.lua
-- Created by sujl, Sept/20/2018
-- 寻缘平台界面

local MatchmakingDlg = Singleton("MatchmakingDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 面板初始化接口
local NAME_INIT_FUNC = {
    ["FindTabDlgCheckBox"]      = "setFindInfo",
    ["SetTabDlgCheckBox"]       = "setMyInfo",
    ["CollectCheckBox"]         = "setCollectInfo",
}

local MSG_LIMIT = 400

local MATCH_MAKING_PUBLISH = {
    PUBLISHED = 1,
    NOPUBLISH = 0,
}

function MatchmakingDlg:init()
    self:bindListener("ChangePhotoButton", self.onChangePhotoButton, "SetPanel")
    self:bindListener("AddButton", self.onDeleteVoiceButton, self:getControl("OneVoicePane", nil, "SetPanel"))
    self:bindListener("AddButton", self.onAddVoiceButton, self:getControl("NoneVoicePane", nil, "SetPanel"))
    self:bindListener("InfoButton", self.onInfoButton, "SetPanel")
    self:bindListener("SexChangeButton", self.onSexChangeButton, "SetPanel")
    self:bindListener("TypeButton1", self.onTypeButton1, "SexChoosePanel")
    self:bindListener("TypeButton2", self.onTypeButton2, "SexChoosePanel")
    self:bindListener("ConfirmButton", self.onConfirmButton, "SetPanel")
    self:bindListener("CancelButton", self.onCancelButton, "SetPanel")
    self:bindListener("DelButton", self.onDeleteButton, self:getControl("MessagePanel", nil, "SetPanel"))
    self:bindListener("TimeButton", self.onPlayVoice, self:getControl("OneVoicePane", nil, "SetPanel"))
    self:bindListener("ChangeButton", self.onChangeButton, "FindPanel")
    self:bindListener("PhotoPanel", self.onClickPhotoPanel, "SetPanel")

    self:bindFloatPanelListener("RulePanel", "InfoButton", "SetPanel")
    self:bindFloatPanelListener("SexChoosePanel", "SexChangeButton", "SetPanel")

    local switchPanel = self:getControl("OpenStatePanel", nil, "MatchmakerPanel")
    self:createSwichButton(switchPanel, true, self.onSwitchReciveMsg)

    self.playerPanel = self:retainCtrl("PlayerPanel", self:getControl("FindPanel", nil, "MainPanel"))
    self:bindListener("BKImage", self.onClickMatchPanel, self:getControl("MatchPanel1", nil, self.playerPanel))
    self:bindListener("BKImage", self.onClickMatchPanel, self:getControl("MatchPanel2", nil, self.playerPanel))

    self:getControl("PlayerPanel", nil, self:getControl("CollectPanel", nil, "MainPanel")):removeFromParent()

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"FindTabDlgCheckBox", "SetTabDlgCheckBox", "CollectCheckBox"}, self.onCheckBox, "SwitchPanel", nil, function(self, sender)
        local name = sender:getName()
        if name == "FindTabDlgCheckBox" then
            if 1 ~= MatchMakingMgr:getMySetting().publish then
                gf:ShowSmallTips(CHS[2000509])
                return false
            end

            local antiaddictionInfo = Me:getAntiaddictionInfo()
            if Me:isAntiAddictionStartup() and antiaddictionInfo["switch5"] == 1 and antiaddictionInfo["adult_status"] ~= 1 then
                gf:ShowSmallTips(CHS[5420358])
                return
            end
        end

        return true
    end)

    local messagePanel = self:getControl("MessagePanel", nil, "SetPanel")
    self.signTextEdit = self:createEditBox("TextPanel", messagePanel, nil, function(sender, type)
        if type == "ended" then
            local msg = self.signTextEdit:getText()
            self.signTextEdit:setText("")
            -- self:setCtrlVisible("SignTextLabel", true, messagePanel)
            self:setCtrlVisible("ScrollView", true, messagePanel)
            gf:CmdToServer("CMD_MATCH_MAKING_OPER_MESSAGE", { message = msg })
        elseif type == "began" then
            -- local msg = self:getLabelText("SignTextLabel", messagePanel)
            local msg = self:getColorText("ContentPanel", messagePanel)
            self.signTextEdit:setText(msg)
            --self:setCtrlVisible("SignTextLabel", false, messagePanel)
            self:setCtrlVisible("ScrollView", false, messagePanel)
        elseif type == "changed" then
            local newName = self.signTextEdit:getText()

            -- 移除换行符 WDSY-34713
            newName = string.gsub(newName, "\n", "")
            newName = string.gsub(newName, "\r", "")

            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                gf:ShowSmallTips(CHS[4000224])
            end

            self.signTextEdit:setText(newName)

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelButton", false, messagePanel)
                self:setCtrlVisible("NoneLabel", true, messagePanel)
            else
                self:setCtrlVisible("NoneLabel", false, messagePanel)
                self:setCtrlVisible("DelButton", true, messagePanel)
            end

            -- self:setLabelText("SignTextLabel", newName, messagePanel)
            self:setPanelText(newName, "ContentPanel", "ScrollView", messagePanel)
        end
    end)
    local editContentSize = self.signTextEdit:getContentSize()
    self.signTextEdit:setLocalZOrder(1)
    self.signTextEdit:setFont(CHS[3003597], 19)
    self.signTextEdit:setFontColor(cc.c3b(76, 32, 0))
    self.signTextEdit:setText("")
    self:setCtrlVisible("DelButton", false, messagePanel)
    self:setCtrlVisible("TextPanel", false, self:getControl("MessagePanel", nil, "SetPanel"))
    self:bindScrollView()

    if not MatchMakingMgr:isPublished() then
        -- 没有发布
        self.radioGroup:selectRadio(2)
    else
        -- 存在列表数据
        self.radioGroup:selectRadio(1)
    end

    self:hookMsg("MSG_MATCH_MAKING_SETTING")
    self:hookMsg("MSG_MATCH_MAKING_QUERY_LIST")
    self:hookMsg("MSG_MATCH_MAKING_FAVORITE_RET")
end

function MatchmakingDlg:cleanup()
    self:stopPlayVoice()
    self.isFirstFind = nil
    self.hasCloseRecvMsg = nil
    MatchMakingMgr:clearData() -- 清除缓存数据

    gf:CmdToServer("CMD_CLOSE_DIALOG", { para1 = "match_making", para2 = "" })
end

function MatchmakingDlg:setTitle(title)
    self:setLabelText("TitleLabel_1", title, "TitlePanel")
    self:setLabelText("TitleLabel_2", title, "TitlePanel")
end

function MatchmakingDlg:setPanelText(text, panelName, svName, root)
    local panel = self:getControl(panelName, nil, root)
    panel:setAnchorPoint(cc.p(0, 1))
    panel:setVisible(true)
    self:setColorText(text, panelName, root, 5, 5, nil, 19)
    local panelSize = panel:getContentSize()
    local scrollView = self:getControl(svName, nil, root)
    scrollView:setInnerContainerSize(panelSize)
    if panelSize.height < scrollView:getContentSize().height then
        panel:setPositionY(scrollView:getContentSize().height - panelSize.height)
    else
        panel:setPositionY(0)
    end
end

function MatchmakingDlg:bindScrollView()
    local clickTime
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            clickTime = gf:getTickCount()
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            if clickTime and gf:getTickCount() - clickTime < 200 then
                self:onClickMessagePanel()
            end
        end
    end

    local ctrl = self:getControl("ScrollView", nil, self:getControl("MessagePanel", nil, "SetPanel"))
    ctrl:setVisible(true)
    ctrl:addTouchEventListener(listener)
end

-- 设置信息
function MatchmakingDlg:setMyInfo()
    self:setTitle(CHS[2000510])
    local root = self:getControl("InfoPanel", nil, "SetPanel")

    self:setLabelText("NameLabel", string.format(CHS[2000511], Me:getName()), root)
    self:setLabelText("LevelLabel", string.format(CHS[2000512], Me:getLevel()), root)
    self:setLabelText("TypeLabel", string.format(CHS[2000513], gf:getPolar(Me:queryBasicInt("polar")), gf:getGenderChs(Me:queryBasicInt("gender"))), root)
    self:setLabelText("TaoLabel", string.format(CHS[2000514], gf:getTaoStr(Me:queryBasicInt("tao"), 0)), root)

    local mySetting = MatchMakingMgr:getMySetting()
    if mySetting then
        self:refreshMyPortrait(mySetting.portrait)
        self:setLabelText("SexLabel", gf:getGenderChs(mySetting.gender), root)
        --self:setLabelText("SignTextLabel", mySetting.remark, self:getControl("MessagePanel", nil, "SetPanel"))
        self:setPanelText(mySetting.remark, "ContentPanel", "ScrollView", messagePanel)
        self:setCtrlVisible("NoneLabel", string.isNilOrEmpty(mySetting.remark), self:getControl("MessagePanel", nil, "SetPanel"))
        self:setCtrlVisible("DelButton", not string.isNilOrEmpty(mySetting.remark) and not MatchMakingMgr:isPublished(), self:getControl("MessagePanel", nil, "SetPanel"))

        local voicePanel = self:getControl("VoicePanel", nil, root)
        local hadVoice = not string.isNilOrEmpty(mySetting.voice_addr)
        self:setCtrlVisible("OneVoicePane", hadVoice, voicePanel)
        self:setCtrlVisible("NoneVoicePane", not hadVoice, voicePanel)

        if hadVoice then
            local oneVoicePanel = self:getControl("OneVoicePane", nil, voicePanel)
            self:setLabelText("TimeLabel", string.format(CHS[2000462], mySetting.voice_time), oneVoicePanel)
        end

        -- 是否接受红娘消息
        local switchPanel = self:getControl("OpenStatePanel", nil, "MatchmakerPanel")
        self:switchButtonStatus(switchPanel, mySetting.receive_msg == 1)

        self:setCtrlVisible("ConfirmButton", MATCH_MAKING_PUBLISH.PUBLISHED ~= mySetting.publish, "SetPanel")
        self:setCtrlVisible("CancelButton", MATCH_MAKING_PUBLISH.PUBLISHED == mySetting.publish, "SetPanel")
    end
end

-- 显示查找提示
function MatchmakingDlg:showFindNotice(showType)
    self:setCtrlVisible("NoticePanel1", 1 == showType, "FindPanel")
    self:setCtrlVisible("NoticePanel2", 2 == showType, "FindPanel")
    self:setCtrlVisible("NoticePanel3", 3 == showType, "FindPanel")
    self:setCtrlVisible("NoticePanel4", 4 == showType, "FindPanel")
end

-- 设置寻缘信息
function MatchmakingDlg:setFindInfo()
    self:setTitle(CHS[2000515])
    local list = self:resetListView("CombatsListView", 0, 0, "FindPanel")
    self.id2items = {}

    if self.isFirstFind then
        self:setCtrlEnabled("ChangeButton", true, "FindPanel")
        self.isFirstFind = nil
    end

    local datas = MatchMakingMgr:getQueryList(1)
    if not datas or #datas <= 0 then
        if not datas then
            self:showFindNotice(4)
            self:runProgressAction("InfoLabel", CHS[2000516], self:getControl("NoticePanel4", nil, "FindPanel"))
            self:setCtrlEnabled("ChangeButton", false, "FindPanel")
            performWithDelay(self:getControl("NoticePanel4", nil, "FindPanel"), function()
                gf:CmdToServer("CMD_MATCH_MAKING_REQ_LIST", { type = 1, source = 2 })
            end, 2)
            self.isFirstFind = true
        else
            self:showFindNotice(2)
        end
        return
    end

    self:showFindNotice()
    local item
    for i = 1, #datas, 2 do
        item = self:createLineItem(datas, i, i + 1)
        list:pushBackCustomItem(item)
    end
end

-- 设置收藏信息
function MatchmakingDlg:setCollectInfo()
    self:setTitle(CHS[2000517])
    local list = self:resetListView("CombatsListView", 0, 0, "CollectPanel")
    self.id2items = {}
    local datas = MatchMakingMgr:getQueryList(0)
    self:setCtrlVisible("NoticePanel1", not datas or #datas <= 0 or false, "CollectPanel")
    if not datas then
        gf:CmdToServer("CMD_MATCH_MAKING_REQ_LIST", { type = 0, source = 2 })
        return
    end

    local item
    for i = 1, #datas, 2 do
        item = self:createLineItem(datas, i, i + 1)
        list:pushBackCustomItem(item)
    end
end

function MatchmakingDlg:createLineItem(data, index1, index2)
    local lineItem = self.playerPanel:clone()
    local item
    local data1 = data[index1]
    item = self:getControl("MatchPanel1", nil, lineItem)
    self:setItemData(item, data1)
    item.index = index1

    local data2 = data[index2]
    item = self:getControl("MatchPanel2", nil, lineItem)
    self:setItemData(item, data2)
    item.index = index2

    return lineItem
end

function MatchmakingDlg:setItemData(item, data)
    item:setVisible(nil ~= data)
    if not data then return end

    item:setName(data.gid)
    self:setLabelText("NameLabel", data.name, item)
    self:setLabelText("LevelLabel", string.format(CHS[2000518], data.level), item)
    self:setLabelText("TypeLabel", string.format(CHS[2000519], gf:getPolar(data.polar), gf:getGenderChs(data.gender)), item)
    self:setLabelText("MessageLabel", gf:getTextByCharLength(data.remark or "", 20), item)
    self:setLabelText("ValueLabel", string.format("%d%%", data.match), self:getControl("MatchValuePanel", nil, item))
    local panel = self:getControl("MatchValuePanel", nil, item)
    local image
     if data.match < 60 then
        image = ResMgr.matchMakingMatchImage[1]
    elseif data.match < 80 then
        image = ResMgr.matchMakingMatchImage[2]
    elseif data.match < 95 then
        image = ResMgr.matchMakingMatchImage[3]
    else
        image = ResMgr.matchMakingMatchImage[4]
    end
    self:setCtrlVisible("ValueImage", false, self:getControl("MatchValuePanel", nil, item))
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(image))
    progressTimer:setName("ProgressTimer")
    progressTimer:setReverseDirection(false)
    panel:addChild(progressTimer)
    progressTimer:setPercentage(data.match)
    local x, y = self:getControl("ValueImage", nil, self:getControl("MatchValuePanel", nil, item)):getPosition()
    progressTimer:setPosition(cc.p(x, y))
    panel:requestDoLayout()

    if self.id2items then
        self.id2items[tostring(item)] = item
    end

    self:refreshPortrait(self:getControl("PortraitPanel", nil, item), data, "setPortrait1", tostring(item))
end

-- 刷新自己头像
function MatchmakingDlg:refreshMyPortrait(path)
    if string.isNilOrEmpty(path) then
        self:setImage("ShapeImage", ResMgr:getMatchPortrait(Me:queryBasicInt("polar"), Me:queryBasicInt("gender")), "SetPanel")
        self:setCtrlVisible("LoadingLabel", false, "SetPanel")
        self:setCtrlVisible("NoneLabel", false, "SetPanel")
        self:setCtrlVisible("ShapeImage", true, "SetPanel")
    else
        self:setCtrlVisible("LoadingLabel", true, "SetPanel")
        self:setCtrlVisible("NoneLabel", false, "SetPanel")
        self:setCtrlVisible("ShapeImage", false, "SetPanel")
        BlogMgr:assureFile("setPortrait", self.name, path, nil, "PhotoPanel")
    end
end

-- 设置自己头像
function MatchmakingDlg:setPortrait(filePath, para)
    local photoPanel = para
    if filePath then
        self:setImage("ShapeImage", filePath, photoPanel)
        self:setCtrlVisible("ShapeImage", true, photoPanel)
        self:setCtrlVisible("LoadingLabel", false, photoPanel)
        self:setCtrlVisible("NoneLabel", false, photoPanel)
    else
        self:setCtrlVisible("ShapeImage", false, photoPanel)
        self:setCtrlVisible("LoadingLabel", false, photoPanel)
        self:setCtrlVisible("NoneLabel", true, photoPanel)
    end
end

-- 刷新头像
function MatchmakingDlg:refreshPortrait(photoPanel, data, callback, para)
    self:setImage("PortraitImage", ResMgr:getMatchPortrait(data.polar, data.gender), photoPanel)
    if not string.isNilOrEmpty(data.portrait) then
        BlogMgr:assureFile(callback, self.name, data.portrait, nil, para)
    end
end

-- 设置头像
function MatchmakingDlg:setPortrait1(filePath, para)
    local photoPanel = self.id2items and self.id2items[para]
    if not photoPanel then return end
    if filePath then
        self:setImage("PortraitImage", filePath, photoPanel)
    end
end

function onMatchmakingDlgPortraitUpload(filePath)
    DlgMgr:sendMsg("MatchmakingDlg", "uploadPortrait", filePath)
end

function MatchmakingDlg:doOpenPhoto(state)
    local cw, ch = gf:getPortraitClipRange(72, 48)
    gf:comDoOpenPhoto(state, "onMatchmakingDlgPortraitUpload", cc.size(cw, ch), cc.size(756, 504), 80, true)
end

function MatchmakingDlg:uploadPortrait(filePath)
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

    BlogMgr:cmdUpload(BLOG_OP_TYPE.MATCH_MAKING_ICON, self.name, "onFinishUploadIcon", filePath)
    MatchMakingMgr:markUploadPortrait()
end

function MatchmakingDlg:onFinishUploadIcon(files, uploads)
    if #files ~= #uploads then
        gf:showTipAndMisMsg(CHS[2000535])
        return
    end

    gf:CmdToServer("CMD_MATCH_MAKING_OPER_ICON", { portrait = uploads[1] })
    self:setImage("ShapeImage", files[1], photoPanel)
end

function onMatchmakingPortraitUpload(filePath)
    DlgMgr:sendMsg("MatchmakingDlg", "uploadPortrait", filePath)
end

function MatchmakingDlg:doOpenPhoto(state)
    BlogMgr:comDoOpenPhoto(state, "onMatchmakingPortraitUpload")
end

-- 打开相册
function MatchmakingDlg:openPhoto(state)
    local leftTime = MatchMakingMgr:canUploadCoverTime()
    if leftTime > 0 then
        gf:ShowSmallTips(string.format(CHS[2000536], leftTime))
        return
    end

    if self:checkSafeLockRelease('doOpenPhoto', state) then
        return
    end

    self:doOpenPhoto(state)
end

-- 删除头像
function MatchmakingDlg:deleteIcon()
    gf:confirm(CHS[2000537], function()
        gf:CmdToServer("CMD_MATCH_MAKING_OPER_ICON", { oper = 2 })
    end)
end

function MatchmakingDlg:stopPlayVoice()
    ChatMgr:setIsPlayingVoice(false)
    SoundMgr:replayMusicAndSound()
    ChatMgr:stopPlayRecord()
    if self.playAction then
        local actionImg = self.playAction
        if actionImg then
            self:setCtrlVisible("TimeIconImage", true, actionImg:getParent())
            actionImg:stopAllActions()
            actionImg:removeFromParent()
        end
    end
    self.playAction = nil
end

function MatchmakingDlg:playVoice(filePath, time)
    if not self.playAction or string.isNilOrEmpty(filePath) then
        self:stopPlayVoice()
        return
    end

    if not GameMgr:isYayaImEnabled() then
        self:stopPlayVoice()
        gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
        return
    end

    local actionImg = self.playAction
    actionImg:setVisible(true)
    self:setCtrlVisible("TimeIconImage", false, actionImg:getParent())
    schedule(actionImg, function()
        time = time - 0.1
        if time <= 0 then
            self:stopPlayVoice()
        end
    end, 0.1)

    ChatMgr:stopPlayRecord()
    ChatMgr:setIsPlayingVoice(true)
    ChatMgr:playRecord(filePath, 1, time, true, function()
        DlgMgr:sendMsg("MatchmakingDlg", "stopPlayVoice")
    end)
    ChatMgr:clearPlayVoiceList()
    SoundMgr:stopMusicAndSound()
end

function MatchmakingDlg:onUploadSignVoice(voice_addr, voice_text, voice_time)
    gf:CmdToServer("CMD_MATCH_MAKING_OPER_VOICE", { voice_addr = voice_addr, voice_time = voice_time })
end

-- 上传照片
function MatchmakingDlg:onChangePhotoButton(sender)
    if MatchMakingMgr:isPublished() then
        gf:ShowSmallTips(CHS[2000520])
        return
    end

    local dlg = BlogMgr:showButtonList(self, sender, "matchMakeShow", self.name)
    local curX, curY = dlg.root:getPosition()
    dlg:setFloatingFramePos(cc.rect(curX - 175, curY, 0, 0))
end

-- 添加留言
function MatchmakingDlg:onAddVoiceButton()
    if MatchMakingMgr:isPublished() then
        gf:ShowSmallTips(CHS[2000520])
        return
    end

    DlgMgr:openDlgEx("MatchmakingSignDlg")
end

-- 删除留言
function MatchmakingDlg:onDeleteVoiceButton()
    if MatchMakingMgr:isPublished() then
        gf:ShowSmallTips(CHS[2000520])
        return
    end

    gf:confirm(CHS[2000538], function()
        gf:CmdToServer('CMD_MATCH_MAKING_OPER_VOICE', { voice_addr = "", voice_text = "", voice_time = 0 })
    end)
end

-- 接收红娘消息
function MatchmakingDlg:onSwitchReciveMsg(isOn)
    if not self.hasCloseRecvMsg and not isOn then
        gf:confirm(CHS[2000521], function()
            gf:CmdToServer("CMD_MATCH_MAKING_OPER_RECV_MSG", { flag = isOn and 1 or 0 })
        end, function()
            self:switchButtonStatus(self:getControl("OpenStatePanel", nil, "MatchmakerPanel"), not isOn)
        end)
    else
        gf:CmdToServer("CMD_MATCH_MAKING_OPER_RECV_MSG", { flag = isOn and 1 or 0 })
    end

    if not isOn then
        self.hasCloseRecvMsg = true
    end
end

-- 信息按钮
function MatchmakingDlg:onInfoButton()
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(not rulePanel:isVisible())
end

-- 性别选择
function MatchmakingDlg:onSexChangeButton(sender)
    if MatchMakingMgr:isPublished() then
        gf:ShowSmallTips(CHS[2000520])
        return
    end
    local panel = self:getControl("SexChoosePanel")
    panel:setVisible(not panel:isVisible())
end

-- 选择男性
function MatchmakingDlg:onTypeButton1(sender)
    self:setLabelText("SexLabel", CHS[2000522], "SetPanel")
    gf:CmdToServer("CMD_MATCH_MAKING_OPER_GENDER", { gender = 1 })
    self:onSexChangeButton()
end

-- 选择女性
function MatchmakingDlg:onTypeButton2(sender)
    self:setLabelText("SexLabel", CHS[2000523], "SetPanel")
    gf:CmdToServer("CMD_MATCH_MAKING_OPER_GENDER", { gender = 2 })
    self:onSexChangeButton()
end

-- 编辑框删除按钮
function MatchmakingDlg:onDeleteButton(sender)
    local messagePanel = self:getControl("MessagePanel", nil, "SetPanel")
    --self:setLabelText("SignTextLabel", "", messagePanel)
    self:setPanelText("", "ContentPanel", "ScrollView", messagePanel)
    self.signTextEdit:setText("")
    self:setCtrlVisible("DelButton", false, messagePanel)
    self:setCtrlVisible("NoneLabel", true, messagePanel)
end

-- 播放语音留言
function MatchmakingDlg:onPlayVoice(sender)
    if self.playAction then
        self:stopPlayVoice()
        return
    end

    local mySetting = MatchMakingMgr:getMySetting()
    if not mySetting or not mySetting.voice_addr then return end

    local voiceSignImg = self:getControl("TimeIconImage", nil, sender:getParent())
    local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
    actionImg:setAnchorPoint(0.5, 0.5)
    actionImg:setVisible(false)
    actionImg:setPosition(voiceSignImg:getPosition())
    voiceSignImg:getParent():addChild(actionImg, 0, 997)
    self.playAction = actionImg

    BlogMgr:assureFile("playVoice", self.name, mySetting.voice_addr, nil, mySetting.voice_time)
end

-- 确认发布
function MatchmakingDlg:onConfirmButton(sender)
    local antiaddictionInfo = Me:getAntiaddictionInfo()
    if Me:isAntiAddictionStartup() and antiaddictionInfo["switch5"] == 1 and antiaddictionInfo["adult_status"] ~= 1 then
        gf:ShowSmallTips(CHS[5420358])
        return
    end

    --local remark = self:getLabelText("SignTextLabel", nil, self:getControl("MesssagePanel", nil, "SetPanel"))
    local remark = self:getColorText("ContentPanel", self:getControl("MesssagePanel", nil, "SetPanel"))
    if gf:getTextLength(remark) < 10 then
        gf:ShowSmallTips(CHS[2000524])
        return
    end

    local newContent, fitStr = gf:filtText(remark)
    if fitStr then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[2000479])
        dlg:setCallFunc(function()
            self:setColorText(newContent, "ContentPanel", self:getControl("MesssagePanel", nil, "SetPanel"), 5, 5, nil, 19)
            gf:CmdToServer("CMD_MATCH_MAKING_OPER_MESSAGE", { message = newContent })
            Dialog.onCloseButton(dlg)
        end)
        return
    end

    gf:confirm(CHS[2000525], function()
        gf:CmdToServer("CMD_MATCH_MAKING_PUBLISH", { type = 1, message = newContent })

        MatchMakingMgr:clearData() -- 清除缓存数据，用于刷新数据
    end)
end

-- 取消发布
function MatchmakingDlg:onCancelButton(sender)
    gf:confirm(CHS[2000526], function()
        gf:CmdToServer("CMD_MATCH_MAKING_PUBLISH", { type = 0 })
    end)
end

function MatchmakingDlg:onCheckBox(sender, eventType)
    local name = sender:getName()

    self:setCtrlVisible("FindPanel", "FindTabDlgCheckBox" == name, "MainPanel")
    self:setCtrlVisible("SetPanel", "SetTabDlgCheckBox" == name, "MainPanel")
    self:setCtrlVisible("CollectPanel", "CollectCheckBox" == name, "MainPanel")

    if NAME_INIT_FUNC[name] and 'function' == type(self[NAME_INIT_FUNC[name]]) then
        self[NAME_INIT_FUNC[name]](self)
    end
end

-- 换一批
function MatchmakingDlg:onChangeButton(sender)
    sender:stopAllActions()
    self:resetListView("CombatsListView", 0, 0, "FindPanel")
    self:showFindNotice(4)
    self:runProgressAction("InfoLabel", CHS[2000527], self:getControl("NoticePanel4", nil, "FindPanel"))
    self:setCtrlEnabled("ChangeButton", false, "FindPanel")
    self:setLabelText("Label_1", string.format("%ds", 10), changeBtn)
    self:setLabelText("Label_2", string.format("%ds", 10), changeBtn)

    performWithDelay(sender, function()
        gf:CmdToServer("CMD_MATCH_MAKING_REQ_LIST", { type = 1, source = 2 })
    end, 2)
    local startTime = gf:getServerTime()

    local function doChange()
        local elapse = gf:getServerTime() - startTime
        local changeBtn = self:getControl("ChangeButton", nil, "FindPanel")
        if changeBtn then
            self:setLabelText("Label_1", string.format("%ds", 10 - elapse), changeBtn)
            self:setLabelText("Label_2", string.format("%ds", 10 - elapse), changeBtn)
        end
        if elapse >= 10 then
            self:setCtrlEnabled("ChangeButton", true, "FindPanel")
            self:setLabelText("Label_1", CHS[2000539], changeBtn)
            self:setLabelText("Label_2", CHS[2000539], changeBtn)
        else
            performWithDelay(sender, doChange, 1)
        end
    end

    performWithDelay(sender, doChange, 1)
end

-- 点击菜单项
function MatchmakingDlg:onClickMatchPanel(sender)
    local gid = sender:getParent():getName()
    if string.isNilOrEmpty(gid) then return end

    local selectIndex = self.radioGroup:getSelectedRadioIndex()
    DlgMgr:openDlgEx("MatchmakingInfoDlg", { type = (1 == selectIndex and 1 or 0), index = sender:getParent().index })
end

-- 重新加载头像
function MatchmakingDlg:onClickPhotoPanel()
    local mySetting = MatchMakingMgr:getMySetting()
    if mySetting then
        self:refreshMyPortrait(mySetting.portrait)
    end
end

function MatchmakingDlg:onClickMessagePanel()
    if MatchMakingMgr:isPublished() then
        gf:ShowSmallTips(CHS[2000520])
    else
        self.signTextEdit:openKeyboard()
    end
end

function MatchmakingDlg:MSG_MATCH_MAKING_SETTING(data)
    local selectIndex = self.radioGroup:getSelectedRadioIndex()
    if 2 == selectIndex then
        self:setMyInfo()
    end
end

function MatchmakingDlg:MSG_MATCH_MAKING_QUERY_LIST(data)
    local selectIndex = self.radioGroup:getSelectedRadioIndex()
    if 1 == selectIndex then
        self:setFindInfo()
    elseif 3 == selectIndex then
        self:setCollectInfo()
    end
end

function MatchmakingDlg:MSG_MATCH_MAKING_FAVORITE_RET(data)
    self:setCollectInfo()
end

return MatchmakingDlg

-- DlgMgr:openDlg("MatchmakingDlg")
