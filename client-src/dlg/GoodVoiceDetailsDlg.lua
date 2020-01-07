-- GoodVoiceDetailsDlg.lua
-- Created by songcw
-- 声音详细信息界面

local GoodVoiceDetailsDlg = Singleton("GoodVoiceDetailsDlg", Dialog)

local INIT_LOAD_MESSAGE_NUM = 20 -- 初始请求 20条留言
local ONE_LOAD_MESSAGE_NUM = 10  -- 初始后，每单次请求 10条留言
local WORD_LIMIT        = 60    -- 发送文字限制

local LEN_NORMAL = 132
local LEN_SHORT = 92
local LEN_LONG = 170

function GoodVoiceDetailsDlg:init()
    self:bindListener("ShareButton", self.onShareButton)
    self:bindListener("ReportButton", self.onReportButton)
    self:bindListener("CollectionButton1", self.onCollectionButton)
    self:bindListener("CollectionButton2", self.onCancleCollectionButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("MessageButton", self.onMessageButton)
    self:bindListener("MessageButton_1", self.onMessageButton)
    self:bindListener("PraisetButton", self.onPraisetButton)
    self:bindListener("FlowerstButton", self.onFlowerstButton)
    self:bindListener("WithdrawButton", self.onWithdrawButton)
    self:bindListener("PlayPanel", self.onPlayButton)
    self:bindListener("CloseWriteButton", self.onCloseWriteButton)
    self:bindListener("WriteButton", self.onWriteButton)         -- 切换留言按钮
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("DelVoiceButton", self.onDelVoiceButton)


    self:setValidClickTime("PlayPanel", 500, "")

    self.commentPanel = self:retainCtrl("CommentPanel")
    self:bindTouchEndEventListener(self.commentPanel, self.onClickCommentPanel)
    self:bindListener("SupportImage1", self.onSupportImage, self.commentPanel)

    self.curTime = 0
    self.data = nil

    self:hookMsg("MSG_GOOD_VOICE_COLLECT")
    self:hookMsg("MSG_LEAVE_MESSAGE_LIST")
    self:hookMsg("MSG_LEAVE_MESSAGE_WRITE")
    self:hookMsg("MSG_LEAVE_MESSAGE_LIKE")
    self:hookMsg("MSG_LEAVE_MESSAGE_DELETE")


    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            performWithDelay(self.root, function ( )
                -- body
                local list = self:getControl("ListView")
                local items = list:getItems()
                local panel = items[#items]
                local idsTab = gf:split(self.data.voice_id, "|")
                local distName = idsTab[1]
                local gid = idsTab[3]
                GoodVoiceMgr:requestMessageData(panel.data, ONE_LOAD_MESSAGE_NUM, gid, 1, distName)
            end,0.3)
        end
    end)


    -- 初始化编辑框
    self:setCtrlVisible("DelButton", false, "OutPanel")
    self.inputCtrl = self:createEditBox("TextPanel", "OutPanel", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT then
                content = gf:subString(content, WORD_LIMIT)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400041])
            end


            if len == 0 then
                self:setCtrlContentSize("TextPanel", LEN_LONG, 40, "OutPanel")
                --self.inputCtrl:setContentSize(LEN_LONG, 40)
                self:setCtrlVisible("DelButton", false, "OutPanel")
            else
                --self.inputCtrl:setContentSize(LEN_NORMAL, 40)
                self:setCtrlContentSize("TextPanel", LEN_NORMAL, 40, "OutPanel")
                self:setCtrlVisible("DelButton", true,  "OutPanel")
            end

        end
    end)

    self:setCtrlContentSize("TextPanel", LEN_LONG, 40, "OutPanel")
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 21)
    self.inputCtrl:setFont(CHS[3003794], 21)
    self.inputCtrl:setPlaceHolder(CHS[5400257])
    self.inputCtrl:setPlaceholderFontSize(21)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)


    if GMMgr:isGM() then
        self:setCtrlVisible("MessageButton", false)
        self:setCtrlVisible("MessageButton_1", false)
        self:setCtrlVisible("PraisetButton", false)
        self:setCtrlVisible("FlowerstButton", false)
        self:setCtrlVisible("OutPanel", false)
        self:setCtrlVisible("DelVoiceButton", true)
    else
        self:setCtrlVisible("DelVoiceButton", false)

    end
end

-- 表情按钮
function GoodVoiceDetailsDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(self, "blog")

    -- 界面上推
    local height = dlg:getMainBodyHeight()
    DlgMgr:upDlg("GoodVoiceDetailsDlg", height)
end

-- 插入表情
function GoodVoiceDetailsDlg:addExpression(expression)
    if not self.inputCtrl then return end

    local content = self.inputCtrl:getText()
    if gf:getTextLength(content .. expression) > WORD_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    -- 不会超过字符限制，拼接
    content = content .. expression
    self.inputCtrl:setText(content)
    self:setCtrlVisible("DelButton", true)
end

-- 增加空格
function GoodVoiceDetailsDlg:addSpace()
    if not self.inputCtrl then return end

    local content = self.inputCtrl:getText()
    if gf:getTextLength(content .. " ") > WORD_LIMIT then
        -- 字符超出上限
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    self.inputCtrl:setText(content .. " ")
    self:setCtrlVisible("DelButton", true, "OutPanel2")
end

function GoodVoiceDetailsDlg:sendMessage(content)

    self:onWriteButton(self:getControl("WriteButton"))
end

-- 删除字符
function GoodVoiceDetailsDlg:deleteWord()
    if not self.inputCtrl then return end

    local text = self.inputCtrl:getText()
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
        self.inputCtrl:setText(newtext)

        if len - deletNum <= 0 then
            self:setCtrlVisible("DelButton", false, "OutPanel2")
        end
    else
        self:setCtrlVisible("DelButton", false, "OutPanel2")
    end
end

-- 删除编辑区域内容
function GoodVoiceDetailsDlg:onDelButton(sender, eventType)
    self.inputCtrl:setText("")
    self:setCtrlVisible("DelButton", false)
    self:setCtrlContentSize("TextPanel", LEN_LONG, 40, "OutPanel")
end

function GoodVoiceDetailsDlg:onDelVoiceButton(sender, eventType)

    gf:confirm(CHS[4300496], function ( )
        gf:CmdToServer("CMD_ADMIN_GOOD_VOICE_DELETE_VOICE", {voice_id = self.data.voice_id})
        self:onCloseButton()
    end)
end


function GoodVoiceDetailsDlg:onSupportImage(sender)
    local data = sender:getParent():getParent().data
    local idsTab = gf:split(self.data.voice_id, "|")
    gf:CmdToServer("CMD_LEAVE_MESSAGE_LIKE", {user_dist = idsTab[1], char_gid = idsTab[3], message_id = data.iid})

end


-- 点击单个留言
function GoodVoiceDetailsDlg:onClickCommentPanel(sender)
    if sender.data.sender_gid == Me:queryBasic("gid") then
        -- 自己发的留言
        BlogMgr:showButtonList(self, sender, "goodVoiceMsgEx", self.name)
    else
        -- 其他人发的留言
        BlogMgr:showButtonList(self, sender, "goodVoiceMsg", self.name)
    end
end

-- 撤回留言
function GoodVoiceDetailsDlg:onChehly(sender)

    local idsTab = gf:split(self.data.voice_id, "|")
    local data = sender.data
    gf:confirm(CHS[4200707], function ( )
        -- body
        gf:CmdToServer("CMD_LEAVE_MESSAGE_DELETE", {user_dist = idsTab[1], host_gid = idsTab[3], message_iid = data.iid})
    end)


end
--[[
        pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.host_gid)
    pkt:PutLenString(data.message_iid) -- 消息唯一标识
]]

-- 举报留言
function GoodVoiceDetailsDlg:onReportMsg(sender)

--[[bindListener
[LUA-print] DEBUG :
[LUA-print] DEBUG : { level=125, MSG=21027, icon=6002, popular=0, voice_dur=30,
voice_desc=描述, timestamp=211517, socket_no=101, img_str=, connect_type=1, voic
e_id=now_dist|596035D00060DE000100|5C91A476006C92000E01, voice_title=标题, name=
player02, gid=596035D00060DE000100,  }

]]
    -- 无法举报自己发布的留言。
    if Me:queryBasic("gid") == sender.data.sender_gid then
        gf:ShowSmallTips(CHS[4200653])
        return
    end
    local idsTab = gf:split(self.data.voice_id, "|")
    local data = sender.data
    gf:CmdToServer("CMD_LEAVE_MESSAGE_REPORT", {user_dist = idsTab[1], char_gid = idsTab[3], message_id = data.iid})

    --gf:confirm(onCancel,needInput,hourglassTime,dlgTag,enterCombatNeedColse,onlyConfirm,confirm_type,showMode,countDownTips)

 --   gf:CmdToServer("CMD_GOOD_VOICE_REPORT", {voice_id = self.data.voice_id, reason = "", rp_type = 1})

end

-- 回复此留言
function GoodVoiceDetailsDlg:onCommentMsg(sender)
    --[[
        点击后则可打开留言编辑界面，编辑后的评论将作为回复型评论显示，回复对象为当前评论的玩家，回复型评论的显示格式为

        #Gplayername1#n回复#Gplayername1：内容
    --]]

    self:onMessageButton()
    local btn = self:getControl("WriteButton")
    btn.data = sender.data

    local name = sender.data.sender_name
    if gf:getTextLength(name) > 6 then
        name = gf:subString(name, 6)
    end
    self.inputCtrl:setPlaceHolder(string.format(CHS[5400258], name))

end

-- 点击播放、停止按钮
function GoodVoiceDetailsDlg:onPlayButton(sender)
    if self.coverTimer then

        self.curTime = AudioEngine.getMusicPostion()

        self:setPlayState(false)
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    else
        BlogMgr:assureFile("loadDown", self.name, self.data.voice_addr, nil, self.data.voice_id)
    end
end

-- 切换播放状态
function GoodVoiceDetailsDlg:setPlayState(isPlaying, isNotStop)
    local panel = self:getControl("PlayPanel")

    if isPlaying ~= nil then
        -- 如果有传入isPlaying，直接根据isPlaying值设置
        self:setCtrlVisible("Image1", isPlaying, panel)
        self:setCtrlVisible("Label1", not isPlaying, panel)
        self:setCtrlVisible("Image2", not isPlaying, panel)
        self:setCtrlVisible("Label2", isPlaying, panel)
    else
        -- 没有传入，则切换另一个状态
        local stopImageIsVisible = self:getCtrlVisible("Image1", panel)
        self:setCtrlVisible("Image2", stopImageIsVisible, panel)
        self:setCtrlVisible("Label2", not stopImageIsVisible, panel)
        self:setCtrlVisible("Image1", not stopImageIsVisible, panel)
        self:setCtrlVisible("Label1", stopImageIsVisible, panel)
    end

    if self:getCtrlVisible("Image1", panel) then
        self.lastCoverTickCount = gfGetTickCount()

        local timePanel = self:getControl("VoicePlayerPanel")
        local data = self.data

        -- 旋转
        self.coverTimer = self:startSchedule(function ()
            local curRotation = self.coverImage:getRotation()
            local temp = gfGetTickCount() - self.lastCoverTickCount
            local addRotation = temp / 1000 * 36
            self.coverImage:setRotation(curRotation + addRotation)
            self.lastCoverTickCount = gfGetTickCount()

            local curTime = AudioEngine.getMusicPostion()
            local maxTime = SoundMgr:getMusicDuration()
            maxTime = math.min( maxTime, 60000)

            curTime = math.floor( curTime / 1000 )
            local m = math.floor( curTime / 60 )
            local s = curTime % 60
            -- 当前
            self:setLabelText("StarTimeLabel", string.format( "%02d:%02d", m, s), timePanel)

            local curTime2 = AudioEngine.getMusicPostion()
            self:setProgressBar("ProgressBar", curTime2 / maxTime * 100, 100)

            if curTime >=  math.floor( maxTime / 1000 ) then
                GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()

                if self.coverTimer then
                    self:stopSchedule(self.coverTimer)
                    self.coverTimer = nil

                    self:setProgressBar("ProgressBar", 0, 100)
                    self:setLabelText("StarTimeLabel", string.format( "%02d:%02d", 0, 0), timePanel)
                end
                self.curTime = 0
                DlgMgr:sendMsg("GoodVoiceDetailsDlg", "setPlayState", false)
            end
        end, 0)
    else
        if self.coverTimer then
            self:stopSchedule(self.coverTimer)
            self.coverTimer = nil
        end

        if isNotStop then
        else
            AudioEngine.pauseMusic()
        end
    --    ChatMgr:stopPlayRecord()
    end
end

function GoodVoiceDetailsDlg:cleanup()
    if self.coverTimer then
        self:stopSchedule(self.coverTimer)
        self.coverTimer = nil
        GoodVoiceMgr:stopPlayGoodVoiceAndReplayMusic()
    end

end

--[[
    [LUA-print] DEBUG : [RECV MSG : MSG_GOOD_VOICE_QUERY_VOICE]  [ConnectType:1]
[LUA-print] DEBUG : { level=70, MSG=21027, icon=6001, popular=0, voice_dur=60, v
oice_desc=一二三四五六七八九十一二三四五六七八九十, dist=now_dist, timestamp=234
3918, img_str=, connect_type=1, socket_no=101, gid=5979A91E007AA2000100, voice_t
itle=p0161的声音, name=p0161, voice_id=now_dist|5979A91E007AA2000100|5C93381100B
3F2000E01,  }
]]

function GoodVoiceDetailsDlg:setPhoto(path, para)
    if not path or path == "" then return end
    self:setImage("ShapeImage", path, "ShowPanel")
end

function GoodVoiceDetailsDlg:setMainInfo(data, isNotPlay)
    if self.data and self.data.voice_id == data.voice_id then
        self:updatePopularity(data)
        return
    end

    self.data = data

    -- 歌曲名字
    self:setLabelText("Label", data.voice_title, "VoiceNameImage")

    -- 歌曲简介
    self:setLabelText("DescribeLabel", data.voice_desc, "FurniturePanel")

    -- 播放相关
    self:setVoiceTimeInfo(data)

    -- 封面
    self.coverImage = self:setCtrlVisible("ShapeImage", true, "ShowPanel")
     --self:setImage("ShapeImage", "ui/Icon1551.png", "ShowPanel")

    self:setCtrlVisible("ExamineImage", false, "ShowPanel")
    if GoodVoiceMgr.myVoiceData and GoodVoiceMgr.myVoiceData.voice_id == self.data.voice_id then
        self:setCtrlVisible("ExamineImage", GoodVoiceMgr.myVoiceData.has_review_pass == 0, "ShowPanel")
    end


    -- 封面
    if string.len( data.img_str ) <= 5 then
        local icon = ResMgr:getMatchPortraitByIcon(tonumber(data.img_str))
        self:setImage("ShapeImage", icon, "ShowPanel")
    else
        BlogMgr:assureFile("setPhoto", self.name, data.img_str)
    end


    -- 主人形象
    self:setImage("HosterImage", ResMgr:getSmallPortrait(data.icon))

    -- 主人姓名
    self:setLabelText("HosterNameLabel", data.dist .. "-" .. data.name)

    self:updatePopularity()

    -- 清空留言列表、
    self:resetListView("ListView")
    local idsTab = gf:split(self.data.voice_id, "|")
    local distName = idsTab[1]
    local gid = idsTab[3]
    GoodVoiceMgr:requestMessageData({}, ONE_LOAD_MESSAGE_NUM, gid, 1, distName)

    -- 主题名字
  --  self:setLabelText("NameLabel", GoodVoiceMgr.seasonData.theme_name, "NamePanel")

    -- 收藏按钮
    local isShowCollect = GoodVoiceMgr.collectData[self.data.voice_id] and false or true
    self:setCtrlVisible("CollectionButton1", GoodVoiceMgr.collectData[self.data.voice_id] ~= 1)
    self:setCtrlVisible("CollectionButton2", GoodVoiceMgr.collectData[self.data.voice_id] == 1)

    local idsTab = gf:split(self.data.voice_id, "|")


    self:setCtrlVisible("WithdrawButton", Me:queryBasic("gid") == idsTab[2])


    self:onCloseWriteButton()

    self:setCtrlVisible("MessageButton", data.open_type == 0)
    self:setCtrlVisible("MessageButton_1", data.open_type == 1)
    self:setCtrlVisible("PraisetButton", data.open_type == 0)
    self:setCtrlVisible("FlowerstButton", data.open_type == 0)

    self:setCtrlVisible("ReportButton", data.open_type == 0)
    self:setCtrlVisible("CollectionButton1", data.open_type == 0)


    -- 默认播放
    if not isNotPlay then
        BlogMgr:assureFile("loadDown", self.name, self.data.voice_addr, nil, self.data.voice_id)
    end
end

function GoodVoiceDetailsDlg:updatePopularity(data)
    -- 点赞数
    data = data or self.data
    local popular = math.min(data.popular, 9999999)
    self:setLabelText("PopularityLabel", popular)
end

-- 设置朋友圈照片
function GoodVoiceDetailsDlg:loadDown(path, para)

    if para ~= self.data.voice_id then end

    GoodVoiceMgr:refreshLocalVoice(path, true)

    self.curVoice = path
    SoundMgr:stopMusicAndSound()

    AudioEngine.playMusic(path, false)
    if self.curTime > 0 then
        performWithDelay(gf:getUILayer(), function()
            if 'function' == type(AudioEngine.seekMusic) then
                AudioEngine.seekMusic(self.curTime)
            elseif 'function' == type(cc.SimpleAudioEngine:getInstance().seekMusic) then
                cc.SimpleAudioEngine:getInstance():seekMusic(self.curTime)
            end
        end, 0)
    end

    -- 部分手机出现播放音乐立即关闭后，再次播放获取进度一直为0情况，详见WDSY-36841
    gf:frozenScreen(500)

    SoundMgr:setLastBGMusicFileName(path)
    self:setPlayState(true)
end


-- 设置留言列表信息
function GoodVoiceDetailsDlg:setMessageData(data)
    local list = self:getControl("ListView")
    for i = 1, data.count do
        local panel = self.commentPanel:clone()
        self:setUnitMsgPanel(data[i], panel, list)
        list:pushBackCustomItem(panel)
    end

    self:setCtrlVisible("NoticePanel", #list:getItems() == 0)
end

-- 设置单个留言panel
function GoodVoiceDetailsDlg:setUnitMsgPanel(data, panel, list)
    panel.data = data
--[[
[LUA-print] DEBUG :
[LUA-print] DEBUG : { sender_dist=npatch_dist, sender_name=龙神乾挚爱, like_num=
0, message=呦呦呦, time=1554216076, target_gid=5BF220FA001E6400B6F9, sender_leve
l=125, target_name=加炯小强, sender_gid=5BD6CA39002C6F00B6F9, sender_vip=3, send
er_icon=6001, iid=5CA3748C005D7B00B601, target_dist=npatch_dist,  }
]]

    self:setCtrlVisible("ShowPanel", true, panel)

    local srcHeight = self:getCtrlContentSize("ContentPanel", panel).height

    local msg = ""
    if data.target_name ~= "" then
        msg = string.format( CHS[4200703], data.sender_name, data.target_name, data.message)
    else
        msg = data.message
    end


    local height = self:setColorText(msg, "ContentPanel", panel, 0, 0, nil, 19, nil, nil, data.sender_vip >= 1 )
    if height > srcHeight then

        panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - srcHeight))

        local showPanel = self:getControl("ShowPanel", nil, panel)
        showPanel:setPosition(0, panel:getContentSize().height - showPanel:getContentSize().height)

      --  self:setCtrlContentSize(panel, nil, nil, nil, nil, (height - srcHeight) + 20)
        local image1 = self:setCtrlContentSize("BKImage1", nil, panel:getContentSize().height, panel)
        local image2 = self:setCtrlContentSize("BKImage2", nil, panel:getContentSize().height, panel)
        image1:setPosition(0, 0)
        image2:setPosition(0, 0)
    end


    -- 留言者icon
    self:setImage("MsgHosterImage", ResMgr:getSmallPortrait(data.sender_icon), panel)

    -- 留言者姓名
    self:setLabelText("PlayerNameLabel", data.sender_name, panel)

    -- 留言内容
    self:setLabelText("CommentLabel", data.message, panel)

    -- 留言时间
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d", data.time), panel)

    -- 支持数
    local like_num = math.min(data.like_num, 99999)
    self:setLabelText("SupporLabel", like_num, panel)

    -- 是否点赞过
   -- self:setCtrlVisible("SupportImage1", i % 2 == 0, panel)
   -- self:setCtrlVisible("SupportImage2", i % 2 ~= 0, panel)

    -- 黑白区分
    self:setCtrlVisible("BKImage2", #list:getItems() % 2 == 0, panel)
end

function GoodVoiceDetailsDlg:setVoiceTimeInfo(data)
    if not data then data = {} end

    local timePanel = self:getControl("VoicePlayerPanel")

    local musicTime = data.voice_dur or 0

    -- 最大时间
    local maxM = math.floor(musicTime / 60)
    local maxS = musicTime % 60
    self:setLabelText("EndTimeLabel", string.format( "%02d:%02d", maxM, maxS), timePanel)

    -- 当前
    self:setLabelText("StarTimeLabel", string.format( "%02d:%02d", 0, 0), timePanel)

    -- 进度条
    self:setProgressBar("ProgressBar", 0, 100, timePanel)
end

-- 设置播放进程
-- para 1 重新设置；2为暂停；3为继续播放；
function GoodVoiceDetailsDlg:setPlayTime(time, para)
    local timePanel = self:getControl("VoicePlayerPanel")
    local bar = self:getControl("ProgressBar", nil, timePanel)
    bar:stopAllActions()

    --todo
end

function GoodVoiceDetailsDlg:onReturnButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onAddButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onAddButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onGetButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onStopButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onStartButton(sender, eventType)
end

function GoodVoiceDetailsDlg:onShareButton(sender, eventType)

    if self.data.voice_id == GoodVoiceMgr.myVoiceData.voice_id and GoodVoiceMgr.myVoiceData.has_review_pass ~= 1 then
        gf:ShowSmallTips(CHS[4300492])
        return
    end


    gf:ShowSmallTips(CHS[4200689])

    local showInfo = string.format(string.format("{\29%s：%s\29}", CHS[4200690], self.data.voice_title))
    local sendInfo = string.format(string.format("{\t%s=%s=%s}", CHS[4200690], CHS[4200690], self.data.voice_title .. ";good_voice_id:" .. self.data.voice_id))

-- 真机上无法复制 \29 到输入框中，此处替换
    local copyInfo = string.gsub(showInfo, "\29", "")
    gf:copyTextToClipboardEx(copyInfo, {copyInfo = copyInfo, showInfo = showInfo, sendInfo = sendInfo})
end

function GoodVoiceDetailsDlg:onReportButton(sender, eventType)

    -- 无法举报自己发布的留言。
    if Me:queryBasic("gid") == self.gid then
        gf:ShowSmallTips(CHS[4200692])
        return
    end

    gf:CmdToServer("CMD_GOOD_VOICE_REPORT", {voice_id = self.data.voice_id, reason = "", rp_type = 1})
end

function GoodVoiceDetailsDlg:onCollectionButton(sender, eventType)
    if self.data.voice_id == GoodVoiceMgr.myVoiceData.voice_id and GoodVoiceMgr.myVoiceData.has_review_pass ~= 1 then
        gf:ShowSmallTips(CHS[4300493])
        return
    end

    gf:CmdToServer("CMD_GOOD_VOICE_COLLECT", {voice_id = self.data.voice_id, is_favorite = 1})
end

function GoodVoiceDetailsDlg:onCancleCollectionButton(sender, eventType)
    gf:CmdToServer("CMD_GOOD_VOICE_COLLECT", {voice_id = self.data.voice_id, is_favorite = 0})
end

function GoodVoiceDetailsDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[4200654], sender)
end

function GoodVoiceDetailsDlg:onWriteButton(sender, eventType)
    local idsTab = gf:split(self.data.voice_id, "|")
    local targetDist = idsTab[1]
    local distName = GameMgr:getDistName()

    -- 若当前玩家并未输入任何内容，则给予如下弹出提示
    local content = self.inputCtrl:getText()
    if content == nil or string.len(content) == 0 then
        gf:ShowSmallTips(CHS[5400265])  --
        return
    end


    -- 否则若玩家当前输入字符包括敏感字符（详见[敏感词语表详细设计(design)]部分屏蔽字库），则弹出如下提示框
    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(content, nil, true)
    if haveFilt then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[5420088])
        dlg:setCallFunc(function()
            gf:ShowSmallTips(CHS[5400266])
            ChatMgr:sendMiscMsg(CHS[5400266])
            DlgMgr:closeDlg("OnlyConfirmDlg")
            self.inputCtrl:setText(filtTextStr)
        end, true)

        return
    end

    content = BrowMgr:addGenderSign(content)

    -- 更新一下表情使用时间信息
    BrowMgr:updateBrowUseTime(content)

    self:onDelButton()

--[[
INF : BlogButtonListDlg:UserButton receive event:2
[LUA-print] DEBUG : { sender_dist=now_dist, sender_name=003GM, like_num=0, messa
ge=测试第二条留言, time=1553322781, target_gid=, sender_level=80, target_name=,
sender_gid=597B06050066D8000100, sender_vip=0, sender_icon=6001, iid=5C95D31D008
2E7000E01, target_dist=,  }
--]]
    if sender.data then
        targetDist = sender.data.sender_dist
        GoodVoiceMgr:requestAddMessage(sender.data.sender_gid, sender.data.iid, content, idsTab[3], idsTab[1], targetDist, self.data.voice_id)
    else
        GoodVoiceMgr:requestAddMessage("", "", content, idsTab[3], idsTab[1], targetDist, self.data.voice_id)
    end
end


function GoodVoiceDetailsDlg:onCloseWriteButton(sender, eventType)

    self:setCtrlVisible("MessageButton", self.data.open_type == 0)
    self:setCtrlVisible("MessageButton_1", self.data.open_type == 1)

    self:setCtrlVisible("PraisetButton", true)
    self:setCtrlVisible("FlowerstButton", self.data.open_type == 0)

    self:setCtrlVisible("OutPanel", false)
end

function GoodVoiceDetailsDlg:onMessageButton(sender, eventType)
    --[[
    若玩家当前是第一次使用留言功能（以是否发布过留言为准），且当前账号尚未完成实名认证，则予以如下弹出提示

    需要完成实名认证才可以进行留言。

若玩家在该声音的留言数量超过≥5，则弹出如下提示

    每人对单个声音的留言数量不能超过5个。

若当前声音已不存在，则关闭声音详细信息界面，弹出如下提示

    该声音已不存在，无法留言。
    --]]
    self.inputCtrl:setPlaceHolder(CHS[5400257])
    self.inputCtrl:setPlaceholderFont(CHS[3003794], 21)
    self:setCtrlVisible("MessageButton", false)
    self:setCtrlVisible("MessageButton_1", false)
    self:setCtrlVisible("PraisetButton", false)
    self:setCtrlVisible("FlowerstButton", false)

    self:setCtrlVisible("OutPanel", true)

    local btn = self:getControl("WriteButton")
    btn.data = nil
end

function GoodVoiceDetailsDlg:onPraisetButton(sender, eventType)
    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.canvass_end then

        if gf:getServerTime() > timeData.final_election_start then
            gf:ShowSmallTips(CHS[4300504])   -- 总选阶段无法点赞，道友可前往#R天墉城#n#Y妙音仙子#n处查看晋级作品的评审情况！
        else
            gf:ShowSmallTips(CHS[4300505])   -- gf:ShowSmallTips("当前阶段无法进行点赞。")
        end
        return
    end

    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4300494])
        return
    end

    gf:CmdToServer("CMD_GOOD_VOICE_LIKE", {voice_id = self.data.voice_id})
end

function GoodVoiceDetailsDlg:onFlowerstButton(sender, eventType)
    if Me:queryBasicInt("level") < 70 then
        gf:ShowSmallTips(CHS[4300495])
        return
    end

    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.canvass_end then

        if gf:getServerTime() > timeData.final_election_start then
            gf:ShowSmallTips(CHS[4300506])   -- gf:ShowSmallTips("总选阶段无法献花，道友可前往#R天墉城#n#Y妙音仙子#n处查看晋级作品的评审情况！")
        else
            gf:ShowSmallTips(CHS[4200655])   -- gf:ShowSmallTips("当前阶段无法献花。")
        end
        return
    end

    DlgMgr:openDlgEx("GoodVoiceFlowersDlg", self.data)
end

function GoodVoiceDetailsDlg:onWithdrawButton(sender, eventType)
    local timeData = GoodVoiceMgr.seasonData
    if gf:getServerTime() > timeData.canvass_end then
        gf:ShowSmallTips(CHS[4200686])   -- gf:ShowSmallTips("当前阶段无法撤回声音。")
        return
    end

    if self:checkSafeLockRelease("onWithdrawButton") then
        return
    end

    -- 是否撤回当前参赛声音？
    gf:confirm(CHS[4200687], function ( )
        -- body
        gf:CmdToServer("CMD_GOOD_VOICE_CANCEL")
        self:onCloseButton()
    end)
end


-- 刷新收藏按钮
function GoodVoiceDetailsDlg:MSG_GOOD_VOICE_COLLECT(data)
    if data[self.data.voice_id] then
        self:setCtrlVisible("CollectionButton1", false)
        self:setCtrlVisible("CollectionButton2", true)
    else
        self:setCtrlVisible("CollectionButton1", true)
        self:setCtrlVisible("CollectionButton2", false)
    end
end

-- 刷新收藏按钮
function GoodVoiceDetailsDlg:MSG_LEAVE_MESSAGE_LIST(data)
    local idsTab = gf:split(self.data.voice_id, "|")
    if data.host_gid ~= idsTab[3] then return end
    if data.request_iid == "" then
        self:resetListView("ListView")
    end

    self:setMessageData(data)
end

-- 发布留言成功（新留言）
function GoodVoiceDetailsDlg:MSG_LEAVE_MESSAGE_WRITE(data)
    local idsTab = gf:split(self.data.voice_id, "|")
    if data.host_gid ~= idsTab[3] then return end

 --   self:onCloseWriteButton()
end

function GoodVoiceDetailsDlg:MSG_LEAVE_MESSAGE_DELETE(data)
    local list = self:getControl("ListView")
    local items = list:getItems()
    local height = 0
    local i = 0
    for _, panel in pairs(items) do
        if panel.data.iid == data.iid then
            height = panel:getContentSize().height
            i = _
         --   panel:removeFromParent()
        end
    end

    performWithDelay(list, function ( )
        if i > 0 then
            list:removeItem(i - 1)

            list:requestDoLayout()
            list:refreshView()
        end
    end)

    if #list:getItems() == 0 then
        self:setCtrlVisible("NoticePanel", true)
    end
end


function GoodVoiceDetailsDlg:MSG_LEAVE_MESSAGE_LIKE(data)
    local list = self:getControl("ListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel.data.iid == data.message_id then
            panel.data.like_num = panel.data.like_num + 1
            self:setLabelText("SupporLabel", panel.data.like_num, panel)
        end
    end
end

-- 表情界面关闭时
function GoodVoiceDetailsDlg:LinkAndExpressionDlgcleanup()
    -- 界面话还原
    DlgMgr:resetUpDlg("GoodVoiceDetailsDlg")
end



return GoodVoiceDetailsDlg
