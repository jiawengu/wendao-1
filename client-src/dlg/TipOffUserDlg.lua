-- TipOffUserDlg.lua
-- Created by songcw Dec/28/2017
-- 举报界面

local TipOffUserDlg = Singleton("TipOffUserDlg", Dialog)

local LIMIT = 80

local MESSAGE_LIMIT = 10

local TIPOFF_TYPE = {
    ["Panel_1"] = "name",
    ["Panel_2"] = "icon",
    ["Panel_3"] = "talk",
    ["Panel_4"] = "cheater",
    ["Panel_5"] = "other",
}

local PANEL_DISPLAY= {
    ["Panel_1"] = "TipOffNamePanel",
    ["Panel_2"] = "TipOffIconPanel",
    ["Panel_3"] = "TipOffSpeechPanel",
    ["Panel_4"] = "TipOffContentPanel",
    ["Panel_5"] = "TipOffContentPanel",
}

local CHANNEL_CHS=
    {
        [CHAT_CHANNEL["WORLD"]] = CHS[4300319],
        [CHAT_CHANNEL["PARTY"]] = CHS[4300320],
        [CHAT_CHANNEL["TEAM"]]  = CHS[4300321],
        [CHAT_CHANNEL["CURRENT"]]  = CHS[4300322],
        [CHAT_CHANNEL["FRIEND"]]  = CHS[4300323],
        [CHAT_CHANNEL["TEAM_ENLIST"]] = CHS[5410310],
        [CHAT_CHANNEL["MATCH_MAKING"]] = CHS[2000543],
    }

local DEFAULT_UNIT_HEIGHT = 0 -- 初始化赋值

local MAX_FILT_MESSAGE_NUM = 1000

function TipOffUserDlg:init()
    self:bindListener("ReasonTypeCheckBox", self.onReasonTypeCheckBox)
    self:bindListener("CheckBox", self.onCheckBox)
    self:bindListener("TipOffButton", self.onTipOffButton)
    self:bindListener("CleanTextButton", self.onCleanTextButton)

    self:setCtrlVisible("CleanTextButton", false)

    self:setCtrlVisible("TipOffMarketPanel", false)
    self:setCtrlVisible("TipOffPartyPanel", false)

    self:setCtrlVisible("UserNamePanel", true)
    self:setCtrlVisible("PartyNamePanel", false)

    -- 传入空时，初始化隐藏对应panel
    self:showByPanel("")

    self.speechPanel = self:retainCtrl("SpeechPanel_1")
    DEFAULT_UNIT_HEIGHT = self:getCtrlContentSize("ContentPanel1", self.speechPanel).height

    self.tipOffType = nil   -- 举报类型
    self.talkData = nil     -- 言论
    self.partyInfo = nil
    self.spcialData = nil

    self:bindFloatPanelListener("ChoseMenuPanel")

    for i = 1, 5 do
        self:bindListener("Panel_" .. i, self.onSelectWhy)
    end

    self:bindEditFieldForSafe("TipOffContentPanel", LIMIT, "CleanTextButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, 120)
 --   self:bindEditField("InputTextField", LIMIT)

end

function TipOffUserDlg:showByPanel(pName)
    for _, panelName in pairs(PANEL_DISPLAY) do
        self:setCtrlVisible(panelName, false)
    end

    if PANEL_DISPLAY[pName] then
    self:setCtrlVisible(PANEL_DISPLAY[pName], true)
    end
end

function TipOffUserDlg:getLastByData(channelData, char, ret)
    if not channelData then return ret end
    local count = 0
    for index = #channelData, math.max(1, #channelData - MAX_FILT_MESSAGE_NUM), -1 do
        local unitData = channelData[index]
        local isEffective = (unitData["msg"] and unitData["msg"] ~= "") or (unitData["chatStr"] and unitData["chatStr"] ~= "")
        if unitData.gid == char.gid and count < MESSAGE_LIMIT and isEffective then
            count = count + 1
            table.insert(ret, unitData)
        end

        if count >= MESSAGE_LIMIT then return ret end
    end

    return ret
end

function TipOffUserDlg:getLastByChannel(channel, char, ret)

    local channelData
    if channel == CHAT_CHANNEL.CURRENT then
        channelData = ChatMgr:getChatData("currentChatData")
    elseif channel == CHAT_CHANNEL.WORLD then
        channelData = ChatMgr:getChatData("worldChatData")
    elseif channel == CHAT_CHANNEL.TEAM then
        channelData = ChatMgr:getChatData("teamChatData")
    elseif channel == CHAT_CHANNEL.PARTY then
        channelData = ChatMgr:getChatData("partyChatData")
    elseif channel == CHAT_CHANNEL.HORN then
        channelData = ChatMgr:getChatData("hornChatData")
    end


    if not channelData then return ret end
    local count = 0
    for index = #channelData, math.max(1, #channelData - MAX_FILT_MESSAGE_NUM), -1 do
        local unitData = channelData[index]
        local isEffective = (unitData["msg"] and unitData["msg"] ~= "") or (unitData["chatStr"] and unitData["chatStr"] ~= "")
        if unitData.gid == char.gid and count < MESSAGE_LIMIT and isEffective and unitData.channel == channel then
            count = count + 1
            table.insert(ret, unitData)
        end

        if count >= MESSAGE_LIMIT then return ret end
    end

    return ret
end

-- 如果地图点击或者其他形式打开的，从所有频道找最近的10条
-- 与吕寅确认，每个频道找最近的 MAX_FILT_MESSAGE_NUM 条记录
function TipOffUserDlg:getAllTips(char)
    local ret = {}

    -- 当前
    ret = self:getLastByChannel(CHAT_CHANNEL.CURRENT, char, ret)

    -- 世界
    ret = self:getLastByChannel(CHAT_CHANNEL.WORLD, char, ret)

    -- 喇叭
    ret = self:getLastByChannel(CHAT_CHANNEL.HORN, char, ret)

    -- 队伍
    ret = self:getLastByChannel(CHAT_CHANNEL.TEAM, char, ret)

    -- 帮派
    ret = self:getLastByChannel(CHAT_CHANNEL.PARTY, char, ret)

    -- 好友
    local friendData = FriendMgr.chatList and FriendMgr.chatList[char.gid] and FriendMgr.chatList[char.gid]:getListData() or FriendMgr.tempCharMsg[char.gid]
    ret = self:getLastByData(friendData, char, ret)

    -- 群
    for qunGid, dt in pairs(FriendMgr.chatGroupsInfo) do
        local friendData = FriendMgr.chatList and FriendMgr.chatList[qunGid] and FriendMgr.chatList[qunGid]:getListData() or FriendMgr.tempCharMsg[qunGid]
        ret = self:getLastByData(friendData, char, ret)
    end

    table.sort(ret, function(l, r)
        if tonumber(l.time) > tonumber(r.time) then return true end
        if tonumber(l.time) < tonumber(r.time) then return false end
    end)

    ret.count = #ret

    return ret

end

function TipOffUserDlg:setNameId(data)
    -- 名称
    self:setLabelText("NameLabel", data.user_name, "UserNamePanel")

    -- id
    self:setLabelText("NameLabel", gf:getShowId(data.user_gid), "UserIDPanel")
end

function TipOffUserDlg:setCharInfo(char, data)
    self.char = char

    -- 名称
    self:setLabelText("NameLabel", char.name, "UserNamePanel")

    -- id
    self:setLabelText("NameLabel", gf:getShowId(char.gid), "UserIDPanel")

    -- 设置最近10条
    local list = self:resetListView("ListView")
    local data = ChatMgr:getTipDataGid(char.gid)
    if data.count == 0 then
        data = self:getAllTips(char)
    end

    local count = math.min(data.count, 10)
    for i = 1, count do
        -- 10000 为该功能之前的旧数据
        if data[i] and data[i].channel and data[i].channel ~= 10000 and data[i].channel ~= CHAT_CHANNEL["MATCH_MAKING"] then
            local panel = self.speechPanel:clone()
            panel:setTag(i)
            panel.data = data[i]

            -- 数据库读取的 是 chatStr字段

            if ChatMgr:getChatData(data[i].channel) then
                self:setImage("ChannelImage", ChatMgr:getChatData(data[i].channel), panel)
                self:setCtrlVisible("ChannelImage", true, panel)

                local str = ""
                if data[i]["chatStr"] and data[i]["chatStr"] ~= "" then
                    str = str .. data[i]["chatStr"]
                else
                    str = str .. data[i]["msg"]
                end

                str = string.match(str, ".png#i(.+)") or str

                local height = self:setColorText(str, "ContentPanel1", panel, nil, nil, nil, nil, nil, nil, data[i].show_extra)
                if height > DEFAULT_UNIT_HEIGHT then
                    panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
                end

            else
                self:setCtrlVisible("ChannelImage", false, panel)
            end

            if data[i].channel == CHAT_CHANNEL.CHAT_GROUP then
                local groupInfo = FriendMgr:convertGroupInfo(FriendMgr:getChatGroupInfoById(data[i].recv_gid))
                local str = string.format(CHS[4300313],groupInfo.group_name)
                if data[i]["chatStr"] and data[i]["chatStr"] ~= "" then
                    str = str .. data[i]["chatStr"]
                else
                    str = str .. data[i]["msg"]
                end

                local height = self:setColorText(str, "ContentPanel2", panel, nil, nil, nil, nil, nil, nil, data[i].show_extra)
                if height > DEFAULT_UNIT_HEIGHT then
                    panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
                end
            elseif data[i].channel == CHAT_CHANNEL.FRIEND then
                local str = CHS[4300314]
                if data[i]["chatStr"] and data[i]["chatStr"] ~= "" then
                     str = str .. data[i]["chatStr"]
                else
                    str = str .. data[i]["msg"]
                end

                local height = self:setColorText(str, "ContentPanel2", panel, nil, nil, nil, nil, nil, nil, data[i].show_extra)
                if height > DEFAULT_UNIT_HEIGHT then
                    panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
                end
            elseif data[i].channel == CHAT_CHANNEL["TEAM_ENLIST"] then
                local str = CHS[5410316] .. data[i]["msg"]
                local height = self:setColorText(str, "ContentPanel2", panel, nil, nil, nil, nil, nil, nil, data[i].show_extra)
                if height > DEFAULT_UNIT_HEIGHT then
                    panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
            end
            end
            list:pushBackCustomItem(panel)
        else
            local panel = self.speechPanel:clone()
            panel:setTag(i)
            panel.data = data[i]

            self:setCtrlVisible("ChannelImage", false, panel)
            local height = self:setColorText(data[i].msg, "ContentPanel2", panel)
            if height > DEFAULT_UNIT_HEIGHT then
                panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
            end

            list:pushBackCustomItem(panel)
        end
    end

    self:setCtrlVisible("Label_1", #list:getItems() ~= 0)
    self:setCtrlVisible("ListView", #list:getItems() ~= 0)
    self:setCtrlVisible("NoticePanel", #list:getItems() == 0)

    -- 根据来源设置举报原因的可见性
    self:setCtrlVisible("Panel_2", data.source == "match_making", "ChoseMenuPanel")

    self:resizeChoseMenuPanel()
end

function TipOffUserDlg:resizeChoseMenuPanel()
    -- 重排界面
    local panel
    local menuPanel = self:getControl("ChoseMenuPanel")
    local panelY = menuPanel:getPositionY()
    local size = menuPanel:getContentSize()
    local item = self:getControl("Panel_5", nil, menuPanel)
    local startY = item:getPositionY()
    local unVisCount = 0
    for i = 5, 1, -1 do
        panel = self:getControl(string.format("Panel_%d", i), nil, menuPanel)
        if panel:isVisible() then
            panel:setPositionY(startY)
            startY = startY + panel:getContentSize().height
        else
            unVisCount = unVisCount + 1
        end
    end

    size.height = size.height - unVisCount * item:getContentSize().height
    menuPanel:setContentSize(size)
    menuPanel:setPositionY(panelY - unVisCount * item:getContentSize().height)
    menuPanel:requestDoLayout()
end

-- 选择具体原因
function TipOffUserDlg:onSelectWhy(sender, eventType)
    local str = self:getLabelText("NameLabel", sender)
    self:setLabelText("Label1", str, "ReasonTypeCheckBox")
    self:setCtrlVisible("ChoseMenuPanel", false)

    self:showByPanel(sender:getName())

    self.tipOffType = TIPOFF_TYPE[sender:getName()]
end

-- 点击 - 请选择举报原因
function TipOffUserDlg:onReasonTypeCheckBox(sender, eventType)
    self:setCtrlVisible("ChoseMenuPanel", true)
end


function TipOffUserDlg:onCheckBox(sender, eventType)
    local panel = sender:getParent()
    local tag = panel:getTag()
    local data = panel.data
    if not self.talkData then self.talkData = {} end
    if sender:getSelectedState() then
        self.talkData[tag] = data
    else
        self.talkData[tag] = nil
    end
end


function TipOffUserDlg:bindEditField(ctrlName, lenLimit, cleanButton)
    local textCtrl = self:getControl(ctrlName)
    local parentPanel = textCtrl:getParent()
--    cleanButton:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
  --          cleanButton:setVisible(true)
            self:setCtrlVisible("DefaultLabel", false)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > lenLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end
            textCtrl:setText(tostring(gf:subString(str, lenLimit * 2)))
            self:setCtrlVisible("CleanTextButton", true)
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
      --          cleanButton:setVisible(false)
                self:setCtrlVisible("DefaultLabel", true)
                self:setCtrlVisible("CleanTextButton", false)
            end
        end

        -- 检查界面是否需要在打开输入法或关闭输入法，上移或下移界面
        if (ccui.TextFiledEventType.attach_with_ime == eventType or ccui.TextFiledEventType.detach_with_ime == eventType) then
            if self.upDlgAction then
                return
            end

            self.upDlgAction = performWithDelay(self.root, function()
                if self:isDlgAttachIme() then
                    DlgMgr:upDlg(self.name, 120)
                else
                    DlgMgr:resetUpDlg(self.name)
                end

                self.upDlgAction = nil
            end, 0.1)
        end
    end)
end

-- 清除按钮
function TipOffUserDlg:onCleanTextButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("DefaultLabel", true)
    self:setCtrlVisible("CleanTextButton", false)
end


function TipOffUserDlg:onTipOffSpcialButton(sender, eventType)
    local data = {}
    data.user_gid = self.char.gid
    data.user_name = self.char.name
    data.type = "talk"
    data.user_dist = self.char.user_dist

    data.content = {}
    data.count = 1
    data.content[1] = {}
    data.content[1].reason = self.spcialData[2]
    data.content[1].para1 = self.spcialData[3]
    data.content[1].para2 = self.spcialData[4]
    data.content[1].para3 = gfGetMd5(   Me:getId() .. self.spcialData[4] .. self.spcialData[2] .. "2ABded7zC)$Cii"    )

    gf:CmdToServer("CMD_REPORT_USER", data)
    self:onCloseButton()
end

-- 集市举报
function TipOffUserDlg:onTipOffMarketButton(sender, eventType)
    local item = MarketMgr:getMarketTipOffItem()
    if not item then
        self:onCloseButton()
        return
    end

    local data = {}
    data.user_gid = item.id
    data.user_name = item.name
    data.type = "goods"
    data.user_dist = ""

    data.content = {}
    data.count = 1
    data.content[1] = {}
    data.content[1].reason = ""
    data.content[1].para1 = ""
    data.content[1].para2 = ""
    data.content[1].para3 = ""

    gf:CmdToServer("CMD_REPORT_USER", data)
    self:onCloseButton()
end

-- 帮派举报
function TipOffUserDlg:onTipOffPartyButton(sender, eventType)


    local data = {}
    data.user_gid = self.partyInfo.partyId
    data.user_name = self.partyInfo.partyName
    data.type = "announce"
    data.user_dist = ""

    data.content = {}
    data.count = 1
    data.content[1] = {}
    data.content[1].reason = self.partyInfo.partyAnnounce or self.partyInfo.annouce
    data.content[1].para1 = ""
    data.content[1].para2 = ""
    data.content[1].para3 = ""

    gf:CmdToServer("CMD_REPORT_USER", data)
    self:onCloseButton()
end

function TipOffUserDlg:onTipOffButton(sender, eventType)


    if self.tipOffType == "spcial" then
        self:onTipOffSpcialButton(sender, eventType)
        return
    end

    if self.tipOffType == "market_goods" then
        self:onTipOffMarketButton(sender, eventType)
        return
    end

    if self.tipOffType == "announce" then
        self:onTipOffPartyButton(sender, eventType)
        return
    end

    if not self.tipOffType then
        gf:ShowSmallTips(CHS[4300315])
        return
    end

    if Me:queryInt("level") < 35 then
        gf:ShowSmallTips(CHS[4300312])
        return
    end

    if self.tipOffType == "talk" and #self:getControl("ListView"):getItems() <= 0 then
        gf:ShowSmallTips(CHS[4300324])
        return
    end


    if self.tipOffType == "talk" and (not self.talkData or not next(self.talkData)) then
        gf:ShowSmallTips(CHS[4300316])
        return
    end

    if (self.tipOffType == "other" or self.tipOffType == "cheater") and self:getInputText("TextField") == "" then
        gf:ShowSmallTips(CHS[4300317])
        return
    end

    local data = {}
    data.user_gid = self.char.gid
    data.user_name = self.char.name
    data.type = self.tipOffType
    data.user_dist = self.char.user_dist
    if not data.user_dist or data.user_dist == "" then
        data.user_dist = GameMgr:getDistName()
    end
    data.content = {}
    data.count = 0
    if self.tipOffType == "talk" then
        for i = 1, 10 do
            if self.talkData[i] then
                data.count = data.count + 1
                data.content[data.count] = {}
                data.content[data.count].reason = self.talkData[i]["msg"] or self.talkData[i]["chatStr"]
                data.content[data.count].para1 = tostring(self.talkData[i].time)
                data.content[data.count].para2 = tostring(self.talkData[i].checksum)

                if CHANNEL_CHS[self.talkData[i].channel] then
                    data.content[data.count].para3 = CHANNEL_CHS[self.talkData[i].channel]
                elseif self.talkData[i].channel == CHAT_CHANNEL.CHAT_GROUP then
                    local groupInfo = FriendMgr:convertGroupInfo(FriendMgr:getChatGroupInfoById(self.talkData[i].recv_gid))
                    data.content[data.count].para3 = string.format(CHS[4300313],groupInfo.group_name)
                else
                    data.content[data.count].para3 = ""
                end
            end
        end
    else
        data.count = 1
        data.content[1] = {}
        data.content[1].reason = self:getInputText("TextField")
        data.content[1].para1 = ""
        data.content[1].para2 = ""
        data.content[1].para3 = ""
    end

    gf:CmdToServer("CMD_REPORT_USER", data)
    ChatMgr:setHasTipOffUserByGid(self.char.gid)

    self:onCloseButton()
end

-- 集市聚宝
function TipOffUserDlg:setMarketTipOff(item)
    self.tipOffType = "market_goods"

    self:setCtrlVisible("TipOffMarketPanel", true)

    self:setCtrlVisible("Label3", false)
    self:showByPanel("")

    self:setLabelText("Label1", CHS[4300468], "ReasonTypeCheckBox")
    self:setCtrlOnlyEnabled("ReasonTypeCheckBox", false)

    self.isPet = false
    if PetMgr:getPetIcon(item.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(item.name))
        item.name = PetMgr:getShowNameByRawName(item.name)
        local petShowName = MarketMgr:getPetShowName(item)
        item.petShowName = petShowName
        isPet = true
    else
        local icon = InventoryMgr:getIconByName(item.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    local goodsImage = self:getControl("IconImage", Const.UIImage)
    goodsImage:loadTexture(imgPath)
    self:setItemImageSize("IconImage")
    goodsImage:setVisible(true)


    local cell = self:getControl("ItemPanel")
     local iconPanel = self:getControl("IconPanel", nil, cell)
    local data = item
         -- 设置数量
    if data.amount and data.amount > 1 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if data.req_level and data.req_level > 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    if data.item_polar then
        InventoryMgr:addArtifactPolarImage(goodsImage, data.item_polar)
    end

     -- 带属性超级黑水晶
    if string.match(data.name, CHS[3003008]) then
        local name = string.gsub(data.name,CHS[3003009],"")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1], cell)
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = data.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003010])[field] then bai = "%" end
        end

        self:setLabelText("NameLabel2", value .. bai .. "/" .. maxValue .. bai, cell)

        self:setCtrlVisible("NameLabel", true, cell)
        self:setCtrlVisible("NameLabel2", true, cell)
        self:setCtrlVisible("OneNameLabel", false, cell)
    else

        -- 名字
        self:setLabelText("OneNameLabel", data.petShowName or data.name, cell)
        self:setCtrlVisible("NameLabel", false, cell)
        self:setCtrlVisible("NameLabel2", false, cell)
    end

    -- 金钱
    local price = data.price

    local str, color = gf:getMoneyDesc(price, true)
    local coinLabel = self:getControl("CoinLabel", nil, cell)
    coinLabel:setColor(color)
    coinLabel:setString(str)
    self:setLabelText("CoinLabel2", str, cell)
    local iconPanel = self:getControl("IconPanel", nil, cell)
        -- 超时
    if data.status == 3 then
        self:setCtrlVisible("TimeoutImage", true, cell)
        -- 公示中
    elseif data.status == 1 then
        self:setCtrlVisible("TimeLabel", true, cell)
        local leftTime = data.endTime - gf:getServerTime()
        local timeStr = MarketMgr:getTimeStr(leftTime)
        self:setLabelText("TimeLabel", timeStr, cell)
    elseif data.status == 4 then
        self:setCtrlVisible("TipImage", true, cell)
    else
        self:setCtrlVisible("BackImage", false, iconPanel)

    end


    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            MarketMgr:requireMarketGoodCard(data.id.."|"..data.endTime, MARKET_CARD_TYPE.FLOAT_DLG, rect, isPet, true, MarketMgr.TradeType.marketType)
        end
    end


    iconPanel:addTouchEventListener(showFloatPanel)

end

-- 帮派宗旨
function TipOffUserDlg:setPartyAnnouce(data)
    self.partyInfo = data
    self.tipOffType = "announce"

    self:setCtrlVisible("TipOffPartyPanel", true)

    self:setCtrlVisible("UserNamePanel", false)
    self:setCtrlVisible("PartyNamePanel", true)

    self:setLabelText("NameLabel", data.partyName, "PartyNamePanel")

    self:setCtrlVisible("Label3", false)
    self:showByPanel("")

    self:setLabelText("Label1", CHS[4300481], "ReasonTypeCheckBox")
    self:setCtrlOnlyEnabled("ReasonTypeCheckBox", false)


    local list = self:getControl("ListView", nil, "TipOffPartyPanel")
    self:setColorText(data.partyAnnounce or data.annouce, "Panel_132", list)
end

function TipOffUserDlg:setSpcial(char, reason)

    self:onSelectWhy(self:getControl("Panel_3"))
    self:setCtrlOnlyEnabled("ReasonTypeCheckBox", false)

    local info = gf:split(reason, ";")
    local data = {count = 1}
    data[1] = {msg = info[2]}

    self.spcialData = info

    self.char = char

    self.tipOffType = "spcial"

    -- 名称
    self:setLabelText("NameLabel", char.name, "UserNamePanel")

    -- id
    self:setLabelText("NameLabel", gf:getShowId(char.gid), "UserIDPanel")

    -- 设置最近10条
    local list = self:resetListView("ListView")

    local count = math.min(data.count, 10)
    for i = 1, count do

        local panel = self.speechPanel:clone()
        panel:setTag(i)
        panel.data = data[i]

        self:setCtrlVisible("ChannelImage", false, panel)
        local height = self:setColorText(data[i].msg, "ContentPanel2", panel)
        if height > DEFAULT_UNIT_HEIGHT then
            panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + (height - DEFAULT_UNIT_HEIGHT))
        end

        list:pushBackCustomItem(panel)
    end

    self:setCtrlVisible("Label_1", #list:getItems() ~= 0)
    self:setCtrlVisible("ListView", #list:getItems() ~= 0)
    self:setCtrlVisible("NoticePanel", #list:getItems() == 0)

    -- 根据来源设置举报原因的可见性
    self:setCtrlVisible("Panel_2", data.source == "match_making", "ChoseMenuPanel")

    self:resizeChoseMenuPanel()
end

return TipOffUserDlg
