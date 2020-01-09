-- MatchmakingInfoDlg.lua
-- Created by sujl, Sept/28/2018
-- 寻缘详细界面

local MatchmakingInfoDlg = Singleton("MatchmakingInfoDlg", Dialog)

function MatchmakingInfoDlg:init(param)
    self:setFullScreen()

    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("TimeButton", self.onClickVoice, self:getControl("OneVoicePane", nil, "VoicePane"))
    self:bindListener("PhotoPanel", self.onClickPhotoPanel)
    self:bindListener("OtherButton", self.onOtherButton)
    self:bindListener("TalkButton", self.onTalkButton)
    self:bindListener("CollectButton", self.onCollectButton)
    self:bindListener("CancelCollectButton", self.onCollectButton)
    self:bindListener("BlogButton", self.onBlogButton)

    if param then
        self.curIndex = param.index
        self.curType = param.type
        self:setInfo(data, true)
    end

    self:hookMsg("MSG_MATCH_MAKING_DETAIL")
    self:hookMsg("MSG_MATCH_MAKING_FAVORITE_RET")
end

function MatchmakingInfoDlg:cleanup()
    self:stopPlayVoice()
    self.showData = nil
    self.curIndex = nil
    self.curType = nil
end

function MatchmakingInfoDlg:onDlgOpened(param)
    self.gid = param and param[1]
    self:setInfo()
end

function MatchmakingInfoDlg:setInfo(noReset, isInit)
    local data
    if self.showData and noReset then
        local detail = MatchMakingMgr:getDetail(self.showData.gid)
        data = detail or self.showData
    else
        local gid = self.gid
        if not gid then
            data = MatchMakingMgr:getQueryDataByIndex(self.curType, self.curIndex)
            gid = data and data.gid
        end
        if gid then
            local detail = MatchMakingMgr:getDetail(gid)
            gf:CmdToServer("CMD_MATCH_MAKING_REQ_DETAIL", { gid = gid })
            if detail then
                data = detail
            end
        end

        if not data then
            self:setVisible(false)
            performWithDelay(self.root, function ()
                -- body
                self:onCloseButton()
            end, 0)
            return
        end
    end

    self.showData = data

    self:setLabelText("NameLabel", string.format(CHS[2000511], data.name), "InfoPanel")
    self:setLabelText("LevelLabel", string.format(CHS[2000528], data.level), "InfoPanel")
    self:setLabelText("SexLabel", string.format(CHS[2000529], gf:getGenderChs(data.real_gender)), "InfoPanel")
    self:setLabelText("TypeLabel", string.format(CHS[2000513], gf:getPolar(data.polar), gf:getGenderChs(data.gender)), "InfoPanel")
    self:setLabelText("TaoLabel", string.format(CHS[2000514], gf:getTaoStr(data.tao or 0, 0)), "InfoPanel")
    self:setLabelText("ValueLabel", string.format("%d%%", data.match or 0), self:getControl("MatchValuePanel", nil, "InfoPanel"))
    self:setCtrlVisible("ValueImage", false, self:getControl("MatchValuePanel", nil, "InfoPanel"))
    local panel = self:getControl("MatchValuePanel", nil, "InfoPanel")
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
    self:setCtrlVisible("ValueImage", false, self:getControl("MatchValuePanel", nil, "InfoPanel"))
    local child = panel:getChildByName("ProgressTimer")
    if child then
        child:removeFromParent()
    end
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(image))
    progressTimer:setName("ProgressTimer")
    progressTimer:setReverseDirection(false)
    panel:addChild(progressTimer)
    progressTimer:setPercentage(data.match)
    local x, y = self:getControl("ValueImage", nil, self:getControl("MatchValuePanel", nil, "InfoPanel")):getPosition()
    progressTimer:setPosition(cc.p(x, y))
    panel:requestDoLayout()

    --self:setLabelText("SignTextLabel", data.remark or "", self:getControl("MessagePanel", nil, "InfoPanel"))
    self:setPanelText(data.remark or "", "ContentPanel", "ScrollView", self:getControl("MessagePanel", nil, "InfoPanel"))
    self:refreshPortrait(data.portrait, ResMgr:getMatchPortrait(data.polar, data.gender))

    local voicePanel = self:getControl("VoicePanel", nil, "InfoPanel")
    local hadVoice = not string.isNilOrEmpty(data.voice_addr)
    self:setCtrlVisible("OneVoicePane", hadVoice, voicePanel)
    self:setCtrlVisible("NoneVoicePane", not hadVoice, voicePanel)

    if hadVoice then
        local oneVoicePanel = self:getControl("OneVoicePane", nil, voicePanel)
        self:setLabelText("TimeLabel", data.voice_time, oneVoicePanel)
    end

    self:setCtrlVisible("LeftButton", self.curIndex and self.curIndex > 1)
    local datas = MatchMakingMgr:getQueryList(self.curType)
    local count = datas and #datas or 0
    self:setCtrlVisible("RightButton", self.curIndex and self.curIndex < count)
    self:setCtrlVisible("CollectButton", 1 ~= data.is_collect)
    self:setCtrlVisible("CancelCollectButton", 1 == data.is_collect)
end

function MatchmakingInfoDlg:setPanelText(text, panelName, svName, root)
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

function MatchmakingInfoDlg:setButtonText(btnName, text, root)
    local button = self:getControl(btnName, nil, root)
    self:setLabelText("NumLabel", text, button)
    self:setLabelText("NumLabel_1", text, button)
end

-- 刷新自己头像
function MatchmakingInfoDlg:refreshPortrait(path, defaultPath)
    if string.isNilOrEmpty(path) then
        self:setImage("ShapeImage", defaultPath, "PhotoPanel")
        self:setCtrlVisible("LoadingLabel", false, "PhotoPanel")
        self:setCtrlVisible("NoneLabel", false, "PhotoPanel")
        self:setCtrlVisible("ShapeImage", true, "PhotoPanel")
    else
        self:setCtrlVisible("LoadingLabel", true, "PhotoPanel")
        self:setCtrlVisible("NoneLabel", false, "PhotoPanel")
        self:setCtrlVisible("ShapeImage", false, "SetPanel")
        BlogMgr:assureFile("setPortrait", self.name, path, nil, "PhotoPanel")
    end
end

-- 设置自己头像
function MatchmakingInfoDlg:setPortrait(filePath, para, objectName)
    if not self.showData or objectName ~= self.showData.portrait then return end
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

function MatchmakingInfoDlg:stopPlayVoice()
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

function MatchmakingInfoDlg:playVoice(filePath, time)
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
        DlgMgr:sendMsg("MatchmakingInfoDlg", "stopPlayVoice")
    end)
    ChatMgr:clearPlayVoiceList()
    SoundMgr:stopMusicAndSound()
end

-- 是否可以增加为好友
function MatchmakingInfoDlg:isCanAddFriend()
    if not self.showData then return false end
    local gid = self.showData.gid
    return not FriendMgr:hasFriend(gid)
end

-- 是否可以删除好友
function MatchmakingInfoDlg:isCanDeleteFriend()
    if not self.showData then return false end
    local gid = self.showData.gid
    return FriendMgr:hasFriend(gid)
end

-- 举报
function MatchmakingInfoDlg:doReport()
    if not self.showData then return end
    ChatMgr:setTipDataForMatchMaking({ gid = self.showData.gid, text = self.showData.remark or "", source = "match_making" })

    local function doIt()
        if Me:queryInt("level") < 35 then
            gf:ShowSmallTips(CHS[4300312])
            self:onCloseButton()
            return
        end

        local data = {}
        data.user_gid = self.showData.gid
        data.user_name = self.showData.name
        data.type = "dlg"
        data.content = {}
        data.count = 0
        data.user_dist = self.showData.dist_name
        if not data.user_dist or data.user_dist == "" then
            data.user_dist = GameMgr:getDistName()
        end

        gf:CmdToServer("CMD_REPORT_USER", data)
        return
    end

    if ChatMgr.hasTipOffUser[self.showData.gid] and ChatMgr.hasTipOffUser[self.showData.gid] == 1 then
        if not FriendMgr:isBlackByGId(self.showData.gid) then
            gf:confirm(string.format(CHS[4300318], self.showData.name), function()
                FriendMgr:addBlack(self.showData.name, gf:getIconByGenderAndPolar(self.showData.gender, self.showData.polar), self.showData.level, self.showData.gid, self.showData.user_dist or GameMgr:getDistName())
            end, function ()
                doIt()
            end)
            return
        else
            doIt()
        end
    else
        doIt()
    end
end

-- 增加好友
function MatchmakingInfoDlg:doAddFriend()
    if not self.showData then return end
    local name = self.showData.name
    local gid = self.showData.gid
    if not name or not gid then return end

    if FriendMgr:hasFriend(gid) then
        -- 如果已经是己方好友
        local str = string.format(CHS[5000060], name)

        gf:confirm(str, function()
            FriendMgr:deleteFriend(name, gid)
        end)

    else
        FriendMgr:addFriend(name)
    end
end

-- 删除好友
function MatchmakingInfoDlg:doDeleteFriend()
    self:doAddFriend()
end

function MatchmakingInfoDlg:onLeftButton()
    self.curIndex = math.max(1, self.curIndex - 1)
    self:setInfo()
end

function MatchmakingInfoDlg:onRightButton()
    local datas = MatchMakingMgr:getQueryList(self.curType)
    local count = datas and #datas or 0
    self.curIndex = math.min(count, self.curIndex + 1)
    self:setInfo()
end

function MatchmakingInfoDlg:onClickVoice(sender)
    if self.playAction then
        self:stopPlayVoice()
        return
    end

    if not self.showData then return end

    local voiceSignImg = self:getControl("TimeIconImage", nil, sender:getParent())
    local actionImg = gf:createLoopMagic(ResMgr.magic.volume)
    actionImg:setAnchorPoint(0.5, 0.5)
    actionImg:setVisible(false)
    actionImg:setPosition(voiceSignImg:getPosition())
    voiceSignImg:getParent():addChild(actionImg, 0, 997)
    self.playAction = actionImg

    BlogMgr:assureFile("playVoice", self.name, self.showData.voice_addr, nil, self.showData.voice_time)
end

function MatchmakingInfoDlg:onClickPhotoPanel()
end

function MatchmakingInfoDlg:onOtherButton(sender)
    local dlg = BlogMgr:showButtonList(self, sender, "matchMakingOther", self.name)
    local curX, curY = dlg.root:getPosition()
    dlg:setFloatingFramePos(cc.rect(curX - 165, curY, 0, 0))
end

function MatchmakingInfoDlg:onTalkButton()
    if not self.showData then return end
    if FriendMgr:isBlackByGId(self.showData.gid) then
        gf:ShowSmallTips(CHS[2000532])
        return
    end

    FriendMgr:communicat(self.showData.name, self.showData.gid, self.showData.portrait, self.showData.level, true, self.showData.user_dist or GameMgr:getDistName())
end

function MatchmakingInfoDlg:onCollectButton()
    if not self.showData then return end
    gf:CmdToServer("CMD_MATCH_MAKING_ADD_FAVORITE", { oper = (self.showData.is_collect == 1 and 0 or 1), gid = self.showData.gid })
end

function MatchmakingInfoDlg:onBlogButton()
    if not self.showData then return end
    BlogMgr:openBlog(self.showData.gid, nil, nil, self.showData.dist_name or GameMgr:getDistName())
end

function MatchmakingInfoDlg:MSG_MATCH_MAKING_DETAIL(data)
    self:setInfo(true)
end

function MatchmakingInfoDlg:MSG_MATCH_MAKING_FAVORITE_RET(data)
    self:setInfo(true)
    gf:CmdToServer("CMD_MATCH_MAKING_REQ_LIST", { type = 0, source = 2 })
end

return MatchmakingInfoDlg
