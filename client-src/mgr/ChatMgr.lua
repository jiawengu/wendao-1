-- ChatMgr.lua
-- created by cheny Nov/27/2014
-- 聊天系统管理器

ChatMgr = Singleton()
local DataObject = require("core/DataObject")
local Bitset = require('core/Bitset')
local YvErrorCode = require(ResMgr:getCfgPath('YvErrorCode.lua'))

local SAVE_PATH = Const.WRITE_PATH -- "dailyWord/"
local MAX_MESSAGE_NUM = 1000 -- 频道消息上限
local MAX_HISTORY_MSG = 8 -- 历史发送的消息上限
local CHAT_SHOW_TIME = 3 -- 头顶信息的显示时间


local channelSetCofig=
{
    [CHAT_CHANNEL["WORLD"]] = "hide_world_msg",
    [CHAT_CHANNEL["PARTY"]] = "hide_party_msg",
    [CHAT_CHANNEL["TEAM"]]  = "hide_team_msg",
    [CHAT_CHANNEL["CURRENT"]]  = "hide_current_msg",
    [CHAT_CHANNEL["TEAM_INFO"]] = "hide_team_msg",
}

local chatData =
{
    worldChatData = {},
    partyChatData = {},
    teamChatData = {},
    currentChatData = {},
    systemChatData = {},
    rumorChatData = {},
    miscChatData = {},
    adnoticeChatData = {},
    hornChatData = {},
    allChatData = {},

    [CHAT_CHANNEL["WORLD"]] = ResMgr.ui["channel_world"],
    [CHAT_CHANNEL["PARTY"]] = ResMgr.ui["channel_party"],
    [CHAT_CHANNEL["TEAM"]] = ResMgr.ui["channel_team"],
    [CHAT_CHANNEL["ADNOTICE"]] = ResMgr.ui["channel_adnotice"],
    [CHAT_CHANNEL["SYSTEM"]] = ResMgr.ui["channel_system"],
    [CHAT_CHANNEL["RUMOR"]] = ResMgr.ui["channel_rumour"],
    [CHAT_CHANNEL["MISC"]] = ResMgr.ui["channel_misc"],
    [CHAT_CHANNEL["TEAM_INFO"]] = ResMgr.ui["channel_team"],
    [CHAT_CHANNEL["CURRENT"]] = ResMgr.ui["channel_current"],
    [CHAT_CHANNEL["HORN"]] = ResMgr.ui["channel_horn"]
}

local DefaultDailyWord = require("cfg/DefaultDailyWord")

local DailyWord =
{
}

local channelCurIndex =
{
    [CHAT_CHANNEL["WORLD"]] = 0,
    [CHAT_CHANNEL["PARTY"]] = 0,
    [CHAT_CHANNEL["TEAM"]] = 0,
    [CHAT_CHANNEL["ADNOTICE"]] = 0,
    [CHAT_CHANNEL["SYSTEM"]] = 0,
    [CHAT_CHANNEL["RUMOR"]] = 0,
    [CHAT_CHANNEL["MISC"]] = 0,
    [CHAT_CHANNEL["TEAM_INFO"]] = 0,
    [CHAT_CHANNEL["CURRENT"]] = 0,
    [CHAT_CHANNEL["HORN"]] = 0,
    ["allChatIndex"] = 0,
}

-- 音量图片
local VOICEIMG_CONFIG =
    {
        [1] = ResMgr.ui.voice_img01,
        [2] = ResMgr.ui.voice_img02,
        [3] = ResMgr.ui.voice_img03,
        [4] = ResMgr.ui.voice_img04,
        [5] = ResMgr.ui.voice_img05,
        [6] = ResMgr.ui.voice_img06,
        [7] = ResMgr.ui.voice_img07,
        [8] = ResMgr.ui.voice_img08,
    }

-- 通过技能名片打开的技能悬浮框，某些技能不需要显示详细信息（目标数/消耗法力等）
local SHOW_SIMPLE_SKILL_CARD = {
    [CHS[6000281]] = true,
    [CHS[6000282]] = true,
    [CHS[6000283]] = true,
    [CHS[7002210]] = true,
}

ChatMgr.mediaId = 1

ChatMgr.hasOneCallMe = {}

-- 用于举报界面的数据
ChatMgr.tipOffUserData = {}

-- 举报过的玩家
ChatMgr.hasTipOffUser = {}
local TIPOFF_LIMIT = 10 -- 举报界面上限个数

-- 当名片字符串需要转义的子串
local CARD_FILT_TEXT = {"#b", "#u"}

-- 录音时是否自动上传、转换文本
ChatMgr.autoConvertText = true

function ChatMgr:processMsg(data)
    -- todo
    gf:PrintMap(data)
end

function ChatMgr:MSG_DIALOG_OK(data)
    gf:ShowSmallTips(data.msg)
end

function ChatMgr:MSG_NOTIFY_MISC(data)
    -- TODO: 有些界面会关注MSG_MESSAGE消息，暂时不确定是否有代码会通过该方式关注杂项消息
    --       当游戏运行在后台时，MSG_MESSAGE会有一些特殊处理

    if data.updateTime then
        data.time = gf:getServerTime()
    end

    MessageMgr:pushMsg({
        MSG = 0x2FFF, -- [0x2FFF] = "MSG_MESSAGE"
        channel = CHAT_CHANNEL["MISC"],
        id = 0,
        msg = data.msg,
        time = data.time,
        privilege = 0,
        server_name = "",
        recvSyncMsgTime = data.recvSyncMsgTime
    })
end

function ChatMgr:MSG_NOTIFY_MISC_EX(data)
    -- 杂项消息
    self:MSG_NOTIFY_MISC(data)

    self:MSG_DIALOG_OK(data)
end

-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作请放在doMessageToUi()函数中处理
function ChatMgr:MSG_MESSAGE(data)
    data["originalMsg"] = data["msg"] -- 消息原文，不能做处理，否则无法举报

    -- 不允许玩家使用 #i，故将 #i 转义成普通字符串显示
    data["msg"] = gf:excapeFlagInColorString(data["msg"], 'i')

    -- 名片处理（把名片的参数替换成名片id）
    if data["cardCount"] and data["cardCount"] > 0 then
        local idStr = data["cardList"][1]

        if string.match(data["msg"], "=worldCupInfo")  then
         --   data["showMsg"] = string.match(data["msg"], "{\t(.+)=worldCupInfo=worldCupInfo")
            local team = string.match(data["msg"], "=worldCupInfo:(.+)}")

            local str1 = ""
            local str2 = ""
            if team then
                str1 = string.match(data["msg"], CHS[4300451]) or ""
                local temp = string.format("=worldCupInfo=worldCupInfo:%s}(.+)", team)
                str2 = string.match(data["msg"], temp) or ""

                data["msg"] = str1 .. string.format(CHS[4300441], team) .. str2
            else
                str1 = string.match(data["msg"], CHS[4300452]) or ""
                str2 = string.match(data["msg"], "=worldCupInfo=worldCupInfo:}(.+)") or ""

                data["msg"] = str1 .. CHS[4300437] .. str2
            end
        elseif string.match(data["msg"], "{\t.+=(.+=.+)}")  then
            if string.match(data["msg"], "=fishHomeInfo=me") or string.match(data["msg"], "=teacher_2018=") or string.match(data["msg"], "=innInfo=me") then
                -- 居所钓鱼玩家可发信息邀请其他玩家一起钓鱼
                -- 聊天条目自动寻路逻辑已被屏蔽，所以配置成名片格式，并在名片响应中特殊处理。
                -- 具体见 gf:onCGAColorText(textCtrl, sender, bindTask)
                -- 客栈随机事件同钓鱼一样特殊处理
            else
                local relstr = string.format("{\t%s}", idStr)
                local cardType = string.match(data["msg"], "{\t.+=(.+)=.+}")
                if cardType == CHS[6000165] then
                    relstr = CharMgr:doChengWeiShowName(relstr)
                elseif cardType == CHS[5450219] then
                    local showStr = string.match(data["msg"], "{\t(..-)=.+=.+}")
                    relstr = string.gsub(relstr, "{\t".. cardType, "{\t" .. showStr, 1)
                elseif cardType == CHS[4101110] then
                    local showStr = string.match(data["msg"], "{\t(..-)=.+=.+}")
                    relstr = string.gsub(relstr, "{\t".. cardType, "{\t" .. CHS[4101112] .. showStr, 1)
                elseif cardType == CHS[7190483] or cardType == CHS[7190487] then
                    -- 货站货品，货站买入方案
                    local showStr = string.match(data["msg"], "{\t(..-)=.+=.+}")
                    relstr = string.gsub(relstr, "{\t".. cardType, "{\t" .. CHS[7190485] .. showStr, 1)
                elseif DeviceMgr:isReviewVer() and cardType == CHS[2400003] then
                    -- 评审版本不显示聚宝斋名片
                    return
                elseif cardType == CHS[7120229] then
                    -- 娃娃
                    local showStr = string.match(data["msg"], "{\t(..-)=.+=.+}")
                    relstr = string.gsub(relstr, "{\t".. showStr, "{\t" .. showStr .. CHS[7120230], 1)
                end

                data['cardType'] = cardType
                data["msg"] = string.gsub(data["msg"], "{\t(..-)}", relstr)
                data["idStr"] = relstr
            end
        end
    end

    -- bool 转换 是否是vip
    if data["show_extra"] == 1 then
        data["show_extra"] = true
    else
        data["show_extra"] = false
    end

    if data["channel"] == CHAT_CHANNEL["FRIEND"] then
        -- 好友消息，交由好友管理器处理
        local filteText, haveFilt = self:filtText(data)
        data["msg"] = filteText
        data["haveFilt"] = haveFilt
        FriendMgr:setChatMsg(data)

        if not GameMgr:isInBackground() then
            -- 不在后台，显示气泡
            local friDlg = DlgMgr:getDlgByName("FriendDlg")
            if friDlg then
                local gid = friDlg:getCurChatGid()
                if friDlg:isOutsideWin() then
                    -- 不管是谁，隐藏了，就给提示
                    DlgMgr:sendMsg("ChatDlg", "doFriendPopup", data)
                else
                    if gid ~= data.gid then
                        -- 显示好友时，如果不是同一个好友
                        DlgMgr:sendMsg("ChatDlg", "doFriendPopup", data)
                    end
                end
            else
                DlgMgr:sendMsg("ChatDlg", "doFriendPopup", data)
            end
        end
    elseif data["channel"] == CHAT_CHANNEL["CHAT_GROUP"] then -- 群组消息
        local filteText, haveFilt = self:filtText(data)
        data["msg"] = filteText
        data["haveFilt"] = haveFilt
        FriendMgr:setGroupChatMsg(data)
    elseif data["channel"] == CHAT_CHANNEL["WORLD"] then
        self:insertChatdata("worldChatData", data)
    elseif data["channel"] == CHAT_CHANNEL["HORN"] then
        self:insertChatdata("hornChatData", data)
        self:setHornPopupMsg(data)
    elseif data["channel"] == CHAT_CHANNEL["PARTY"] then
        if self:isRedBagMsg(data["msg"]) then -- 红包
            self.hasRedBag = true
        end

        self:insertChatdata("partyChatData", data)
    elseif data["channel"] == CHAT_CHANNEL["TEAM"] or data["channel"] == CHAT_CHANNEL["TEAM_INFO"] then
        self:insertChatdata("teamChatData", data)

        -- 结拜过程中，翻译得到的语音文本要显示在界面上（在后台则不作处理）
        if (not GameMgr:isInBackground()) and data["token"] and data["token"] ~= "" and data["msg"] ~= "" then
            DlgMgr:sendMsg("JiebSortOrderDlg", "chatPopUp", data)
            DlgMgr:sendMsg("JiebSetTitleDlg", "chatPopUp", data)
        end
    elseif data["channel"] == CHAT_CHANNEL.CURRENT then
        -- 战斗中，当前频道由战斗管理器处理
        self:insertChatdata("currentChatData", data)
    elseif data["channel"] == CHAT_CHANNEL["SYSTEM"] or data["channel"] == CHAT_CHANNEL["ADNOTICE"]
        or data["channel"] == CHAT_CHANNEL["MISC"] or data["channel"] == CHAT_CHANNEL["RUMOR"] then
        self:insertSystemData(data)
    elseif data["channel"] == CHAT_CHANNEL["WEDDING"] then
        data.sender = data.name
        BarrageTalkMgr:creatBarrage(data)
    end

    self:doMessageToUi(data)
end

-- 如果游戏在后台不允许操作ui相关的操作，这样贴图会创建不成功，导致进前台时候，被创建过的贴图不显示了
function ChatMgr:doMessageToUi(data)
    if GameMgr:isInBackground() then return end

    -- 队长喊话成功，队长获得不可选提示
    if data.channel == CHAT_CHANNEL.TEAM_INFO then
        if data.name == Me:getName() and Me:isTeamLeader() then
            gf:ShowSmallTips(CHS[3003935])
        end
    end

    if data["channel"] == CHAT_CHANNEL["TEAM"] then
        if Me:isInCombat() or Me:isLookOn() then
            FightMgr:setChat(data, true)
        else
            ChatMgr:setChat(data, true)
        end
    elseif data["channel"] == CHAT_CHANNEL.HEAD then
        if Me:isInCombat() or Me:isLookOn() then
            FightMgr:setChat(data, true)
        else
            ChatMgr:setChat(data, true)
        end
    elseif data["channel"] == CHAT_CHANNEL.CURRENT then

        if Me:isInCombat() or Me:isLookOn() then
            FightMgr:setChat(data, true)
        else
            ChatMgr:setChat(data, true)
        end
    elseif data["channel"] == CHAT_CHANNEL["ADNOTICE"] then
        --显示公告同时，就要打开公告窗口
        ChatMgr:showCenterAdnotice(data)
    elseif data["channel"] == CHAT_CHANNEL["ERROR"] then
        gf:ShowSmallTips(data["msg"])
    end

    -- 有红包
    if self:isRedBagMsg(data["msg"]) and (DlgMgr:sendMsg("ChannelDlg", "getCurChannel") ~= CHAT_CHANNEL["PARTY"] or ChatMgr:channelDlgIsOutsideWin())  then
        DlgMgr:sendMsg("ChatDlg", "addRedbagImage")
    end
end

-- 设置头顶聊天对话
function ChatMgr:setChat(data, isNotUpdate, notDisplayHead)
    local char = CharMgr:getChar(data.id)
    if char then
        -- 服务器有下发 show_time，并且show_time == 0，则需要客户端设置显示时间
        if data.show_time and tonumber(data.show_time) and tonumber(data.show_time) > 0 then
        else
            data.show_time = CHAT_SHOW_TIME
        end

        if not notDisplayHead then
            char:setChat(data)
        end
        if not isNotUpdate then
            -- 发到当前频道 （头顶冒泡）
            data.name = char:getName()
            data.channel = CHAT_CHANNEL["CURRENT"]
            data.time = gf:getServerTime()
            data.show_extra = true
            ChatMgr:insertChatdata("currentChatData",data)
        end
    end
end

-- 是否有玩家 @自己的信息
function ChatMgr:doSomeHasOneCallMe(data)
    -- 为所有的 @ 成员名字后面添加空格
    -- [ ]? 为0或一个空格，如果有空格则直接替换掉，不再添加多余的空格
    data["chatStr"] = string.gsub(data["chatStr"], "(\29@..-\29)[ ]?", "%1 ")

    -- 为@ 自己添加颜色
    local callMeStr = "\29@" .. Me:getShowName() .. "\29"
    local changeCou = 0
    data["chatStr"], changeCou = string.gsub(data["chatStr"], callMeStr, "#B%1#n")
    if changeCou > 0 then
        -- 有人 @ 自己
        data.hasOneCallMe = true
        return true
    end
end

-- 喇叭喊话消息显示处理
function ChatMgr:setHornPopupMsg(data)
    local message = data.msg
    local name = gf:getRealName(data.name)

    if data["channel"] ~= CHAT_CHANNEL["HORN"] then
        return
    end

    if FriendMgr:isBlackByGId(data.gid) then
        return
    end

    if gf:isNullOrEmpty(message) or gf:isNullOrEmpty(name) then
        return
    end

    message = "#cFFDB4B[" .. name .. "]：#n" .. message
    local itemInfo = InventoryMgr:getItemInfoByName(data["horn_name"])
    if not itemInfo or not itemInfo["bubble_tip_horn"] then
        itemInfo = InventoryMgr:getItemInfoByName(CHS[5400319])
    end

    message = "#i" .. itemInfo["bubble_tip_horn"] .. "#i" .. message
    local backIcon = itemInfo["bubble_tip_back"]

    self.curShowHornMsg = {msg = message, icon = backIcon, time = gf:getServerTime()}

    if not GameMgr:isInBackground() then
        DlgMgr:sendMsg("ChatDlg", "doHornPopup", self.curShowHornMsg)
        DlgMgr:sendMsg("ChannelDlg", "doHornPopup", self.curShowHornMsg)
    end
end

-- 是否是红包消息
function ChatMgr:isRedBagMsg(msg)
    if msg and string.match(msg, "{\29redbag=.+|.+|.+|.*}") then
        return true
    end

    return false
end

-- 获取红包数据
function ChatMgr:getRedbagIdByMsg(msg)
    local data = string.match(msg or "", "{\29redbag=(.+)}")
    local redbag = {}
    if msg and data then
        local list = gf:split(data, "|")
        redbag.gid = list[1]
        redbag.type = list[2]
        redbag.party_gid = list[3]
        redbag.msg = list[4]
    end

    return redbag
end

-- 名片字符串特殊处理
-- 当名片字符串左右两边"#b"数量不相等时，说明"#b"效果将作用于名片字符串，策划不想要这种效果，所以需要转义一下
function ChatMgr:filtCardStr(str)
    if string.isNilOrEmpty(str) then return str end
    local cardText = string.match(str, "{\9(.*)}")
    if cardText then
        local left, right = string.match(str, "(.*){\9.*}(.*)")
        local hasFilt = false
        if not string.isNilOrEmpty(left) and not string.isNilOrEmpty(right) then
            for i = 1, #CARD_FILT_TEXT do
                left, hasFilt = gf:excapeOneFlagInColorString(left, CARD_FILT_TEXT[i], true)
                if hasFilt then
                    right = gf:excapeOneFlagInColorString(right, CARD_FILT_TEXT[i])
                end

                hasFilt = false
            end

            return left .. "{\9" .. cardText .. "}" .. right
        end
    end

    return str
end

-- 过滤非法字符,名片中含有非法字符不过滤
-- isNotTips 为true时，不给敏感字的弹出提示
function ChatMgr:filtText(data, isNotTips)
    if not GMMgr:isGMByPrivilege(data.privilege) then
        -- 除了GM，不允许玩家使用#r、\n（换行）
        -- 将 #r 转义成普通字符串显示
        data.msg = gf:excapeFlagInColorString(data["msg"], 'rm')

        --  将 \n 转义成空字符串显示
        data.msg = string.gsub(data["msg"], '\\n', '')
        data.msg = string.gsub(data["msg"], '\n', '')
    end

    local filteText = ""
    local haveFilt = false

    -- 不允许“非系统文字”使用#@（界面链接）
    -- 将 #@ 转义成普通字符串显示
    data.msg = gf:excapeFlagInColorString(data["msg"], '@')

    if data.not_check_bw == 1 then
        return data["msg"]
    end

    -- 呼叫好友消息的名字可能含有敏感字，先提取出来，等处理完敏感字再插进去
    local callInfo = {}
    local callCou = 0
    if data["channel"] == CHAT_CHANNEL["PARTY"] or data["channel"] == CHAT_CHANNEL["CHAT_GROUP"] then
        for callStr in string.gfind(data["msg"], ".-(\29@.-\29).-") do
            table.insert(callInfo, callStr)
        end

        callCou = #callInfo
        if callCou > 0 then
            data["msg"] = string.gsub(data["msg"], "\29@.-\29", "{@\t}")
        end
    end

    if data["idStr"]  then
        -- 该字符中含有名片,并且有非法字符，还原名片中的非法字符
        local text = string.gsub(data["msg"], "{\t(..-)}", "{\t}")
        filteText, haveFilt = gf:filtText(text, data["gid"])
        filteText = string.gsub(filteText, "{\t(.-)}", data["idStr"])
    elseif string.match(data["msg"], "{\9.*}") then
        local tStr = string.match(data["msg"], ".*({\9.*}).*")
        local text = string.gsub(data["msg"], "{\9.*}", "{\t}")
        filteText, haveFilt = gf:filtText(text, data["gid"])
        filteText = string.gsub(filteText, "{\t}", tStr)
    elseif string.match(data["msg"], ".*#T(.+)#T.*") then -- #T格式里面有非法字符不过滤
        local tStr = string.match(data["msg"], ".*(#T.+#T).*")
        local text = string.gsub(data["msg"], "#T(.+)#T", "{\t}")
        filteText, haveFilt = gf:filtText(text, data["gid"])
        filteText = string.gsub(filteText, "{\t}", tStr)
    elseif self:isRedBagMsg(data.msg) then -- 帮派红包
        local redbag = ChatMgr:getRedbagIdByMsg(data["msg"])
        if redbag.msg then
            filteText, haveFilt = gf:filtText(redbag.msg, data["gid"])
        end

        if haveFilt then
            filteText = string.format("{\29redbag=%s|%s|%s|%s}", redbag.gid or "", redbag.type or "", redbag.party_gid or "", filteText)
        else
            filteText = data["msg"]
        end
    else
        if string.match(data["msg"], "{\t.*\t}") then
            local articleTitle, articleId, comment = string.match(data["msg"], "{\t(.*)\27(.*)\27(.*)\t}")
            filteText = data["msg"]
        else
        filteText, haveFilt = gf:filtText(data["msg"], data["gid"], isNotTips)
    end
    end

    if callCou > 0 then
        for i = 1, callCou do
            filteText = string.gsub(filteText, "{@\t}", callInfo[i], 1)
        end
    end

    return filteText, haveFilt
end

-- 插入非系统的消息
-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作请放在doMessageToUi()函数中处理
function ChatMgr:insertChatdata(key, data)
    local chatTable = {}

    chatTable["gid"] = data["gid"]
    chatTable["icon"] = data["icon"]
    chatTable["chatStr"] = data["msg"]
    chatTable["time"] = data["time"]
    chatTable["name"] = data["name"]
    chatTable["show_extra"] = data["show_extra"]
    chatTable["level"] = data["level"]
    chatTable["channel"] = data["channel"]
    chatTable["comeback_flag"] = data["comeback_flag"]
    chatTable["chat_floor"] = data["chat_floor"]  -- 聊天气泡框
    chatTable["chat_head"] = data["chat_head"]    -- 聊天头像框
    chatTable["horn_name"] = data["horn_name"]    -- 喇叭
    chatTable["channel"] = data["channel"]
    chatTable["msg"] = data["originalMsg"] or data["msg"] -- 消息原文，不能做处理，否则无法举报
    chatTable["checksum"] = data["checksum"] or 0
    chatTable["time"] = data["time"]
    chatTable["sysTipType"] = data["sysTipType"]
    chatTable["id"] = data["id"] or 0
    chatTable["recvSyncMsgTime"] = data["recvSyncMsgTime"]
    chatTable["npc_name"] = data["npc_name"]
    chatTable["npc_icon"] = data["npc_icon"]

    if nil == data["voiceTime"] then
        data["voiceTime"] = 0
    end

    chatTable["voiceTime"] = data["voiceTime"] / 1000
    chatTable["token"] = data["token"]

    if not data["gid"]
        and (data["channel"] == CHAT_CHANNEL["PARTY"]
            or data["channel"] == CHAT_CHANNEL["WORLD"]
            or data["channel"] == CHAT_CHANNEL["TEAM"]
            or data["channel"] == CHAT_CHANNEL["CURRENT"]) then
        -- 可交互频道的系统消息特殊处理
        chatTable["gid"] = 0
        if data["name"] == "" then
            -- 非 NPC 发言的系统消息
            chatTable["chatStr"] =  string.format("#i%s#i%s", chatData[data["channel"]], data["msg"])
        elseif not data["icon"] or data["icon"] == 0 then
            -- 非 NPC 发言的系统消息
            chatTable["chatStr"] =  string.format("#i%s#i[%s]%s", chatData[data["channel"]], data["name"], data["msg"])
        end
    else
        local filteText, haveFilt = self:filtText(data)
        data["msg"] = filteText
        chatTable["chatStr"] = filteText
        data["haveFilt"] = haveFilt
        chatTable["haveFilt"] = haveFilt
    end

    if data["channel"] == CHAT_CHANNEL["PARTY"] and ChatMgr:doSomeHasOneCallMe(chatTable) then
        -- 有人呼叫
        local dlg = DlgMgr:getDlgByName("ChannelDlg")
        if dlg and dlg:setHasOneCallMe(data["channel"]) then
            -- 已经缓存到 ui 中，清除该标记
            self.hasOneCallMe[data["channel"]] = nil
        else
            -- 界面未打开或对应聊天框未创建
            self.hasOneCallMe[data["channel"]] = true
        end

        RedDotMgr:insertOneRedDot("ChannelDlg", "PartyCheckBox", nil, nil, true)
        RedDotMgr:insertOneRedDot("ChatDlg", "ChatButton", nil, nil, true)
    end

    -- 语音文本特殊处理（分为语音内容和文字内容，语音发过来时msg是""，等问题过来时才把内容加上去)
    if chatTable["token"] and chatTable["token"] ~= "" then
        -- 语音翻译文本结束后发过来的文本内容
        local isTranslateText = self:addVoiceText(chatData[key], chatTable, string.isNilOrEmpty(chatTable["chatStr"]))
        if not isTranslateText then
            self:insertChat(chatData[key], chatTable, data.channel)
        end
    else
        self:insertChat(chatData[key], chatTable, data.channel)
    end

    -- 自动播放语音队列
    if chatTable["token"] ~= "" and data["msg"] == "" and  not GameMgr:isInBackground() then -- 收到语音就添加到语音队列(语音发过来时msg是""，等问题过来时才把内容加上去)
        local voiceData = {}
   		voiceData["channel"] = data["channel"]
		voiceData["voiceTime"] = data["voiceTime"] / 1000
		voiceData["token"] = data["token"]
		voiceData["gid"] = data["gid"]
		voiceData["time"] = data["time"]
      	self:addPlayVoiceList(voiceData)
    end

    local settingTable = SystemSettingMgr:getSettingStatus()

    -- 1.没屏蔽频道把内容发下左下角内容区域     2.并且不是红包
    if  not settingTable[channelSetCofig[data["channel"]]] or settingTable[channelSetCofig[data["channel"]]] == 0 and not self:isRedBagMsg(data["msg"]) then
        local chatAllData = {}
        local flagUI = chatData[data["channel"]]
        if nil == flagUI then
            return
        end

        chatAllData["show_extra"] = data["show_extra"]
        chatAllData["gid"] = data["gid"]
        chatAllData["name"] = data["name"]
        chatAllData["needFresh"] = data["needFresh"]
        chatAllData["token"] = data["token"]
        chatAllData["chatStr"] = data["msg"]

        chatAllData["level"] = data["level"]
        chatAllData["icon"] = data["icon"]
        chatAllData["channel"] = data["channel"]
        chatAllData["msg"] = data["originalMsg"] or data["msg"] -- 消息原文，不能做处理，否则无法举报
        chatAllData["checksum"] = data["checksum"] or 0
        chatAllData["time"] = data["time"]
        chatAllData["recvSyncMsgTime"] = data["recvSyncMsgTime"]

        -- 语音
        if chatAllData["token"] and chatTable["token"] ~= ""then
            chatAllData["chatStr"]= string.format("#i%s#i%s", ResMgr.ui.voice_other_sign, chatAllData["chatStr"])
        end

        if data["name"] == "" then
            chatAllData["chatStr"] = string.format("#i%s#i%s", chatData[data["channel"]], chatAllData["chatStr"])
        else
            -- 过滤掉左下角角色职称
            local name = string.match(data["name"], "(.*) .*")
            if name then
                data["name"] = name
            end

            chatAllData["chatStr"] = string.format("#i%s#i#<[%s]#>%s", chatData[data["channel"]], data["npc_name"] or data["name"], chatAllData["chatStr"])
        end

         if chatTable["token"] and chatTable["token"] ~= "" then
            -- 语音翻译文本
            if not self:addVoiceText(chatData["allChatData"], chatAllData, string.isNilOrEmpty(data["msg"])) then
                self:insertChat(chatData["allChatData"], chatAllData, "allChatIndex")
            end
            local dlg = DlgMgr:getDlgByName("ChatDlg")
            if dlg and not GameMgr:isInBackground() then
                dlg:MSG_MESSAGE()
            end
         else
            self:insertChat(chatData["allChatData"], chatAllData, "allChatIndex")
         end
    end
end

--  是否是语音的翻译文本
function ChatMgr:isVoiceTranslateText(data)
	if data and data["token"] and data["token"] ~= "" and data["msg"] ~= "" then
	   return true
	else
	   return false
	end
end

-- 找到面板中的语音，然后补上文字
function ChatMgr:addVoiceText(data, insertData, checkDataOnly)
    local isTranslateText = false
    for i = #data, 1 , -1 do
        if data[i].token ==  insertData["token"] then
            if not checkDataOnly then
            data[i].chatStr = insertData["chatStr"]
            data[i].msg = insertData["msg"]
            data[i].haveFilt = insertData["haveFilt"]
            data[i].needFresh = true
            end
            isTranslateText = true
            break
        end
    end

    return isTranslateText
end

-- 往频道表里面插入数据
-- chatTbale 存某个频道的所有数据
-- 当前收到消息要往频道里面插入
-- tableKeyIndex某个频道当前的数据最大数的索引
-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作请放在doMessageToUi()函数中处理
function ChatMgr:insertChat(chatTbale, data, tableKeyIndex)
    if tableKeyIndex == CHAT_CHANNEL["TEAM_INFO"] then -- 队伍的一键喊话 和队伍为统一频道的数据共同用一个索引变量
        tableKeyIndex = CHAT_CHANNEL["TEAM"]
    end

    if tableKeyIndex == CHAT_CHANNEL["HORN"] then
        -- 喇叭要同时显示在世界频道
        local worldData = gf:deepCopy(data)
        self:insertChat(chatData["worldChatData"], worldData, CHAT_CHANNEL["WORLD"])
    end

    if data["recvSyncMsgTime"] and data["time"] then
        -- 同步消息的时间以显示的时间为准
        local lastData = chatTbale[#chatTbale]
        if lastData and lastData["time"] then
            data["time"] = math.max(data["time"] + math.floor((gfGetTickCount() - data["recvSyncMsgTime"]) / 1000), lastData["time"])
        else
            data["time"] = data["time"] + math.floor((gfGetTickCount() - data["recvSyncMsgTime"]) / 1000)
        end

        data["recvSyncMsgTime"] = 0
    end

    self:checkChatTableIsOver(chatTbale)
    channelCurIndex[tableKeyIndex] =  channelCurIndex[tableKeyIndex] + 1
    data["index"] = channelCurIndex[tableKeyIndex]
    table.insert(chatTbale, data)
end

-- 检查表是不是超最大值
function ChatMgr:checkChatTableIsOver(chatTable)
    if #chatTable >= MAX_MESSAGE_NUM then
        table.remove(chatTable, 1)
    end
end


-- 根据系统频道获取相应的数据key
function ChatMgr:getSysDataKey(channel)
    local dataKey = ""

    if channel == CHAT_CHANNEL["ADNOTICE"] then
        dataKey = "adnoticeChatData"
    elseif channel == CHAT_CHANNEL["RUMOR"] then
         dataKey = "rumorChatData"
    elseif channel == CHAT_CHANNEL["MISC"] then
        dataKey = "miscChatData"
    elseif channel == CHAT_CHANNEL["SYSTEM"] then
        dataKey = "systemChatData"
    end

    return dataKey
end

-- 插入系统消息
-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作请放在doMessageToUi()函数中处理
function ChatMgr:insertSystemData(data)
    --公告在对话窗口中显示
    local chatTable = {}
    chatTable["channel"] = data["channel"]

    if data["channel"] == CHAT_CHANNEL["CURRENT"] then
        if data["name"] ~= "" then
            chatTable["chatStr"] = string.format("#<[%s]#>%s", data["name"],data["msg"])
        else
            chatTable["chatStr"] = data["msg"]
        end
    else
        chatTable["chatStr"] = string.format("#i%s#i%s", chatData[data["channel"]], data["msg"])
    end

    chatTable["time"] = data["time"]
    chatTable["show_extra"] = data["show_extra"]
    chatTable["recvSyncMsgTime"] = data["recvSyncMsgTime"]
    self:insertChat(chatData[self:getSysDataKey(data.channel)], chatTable, data.channel)

    local settingTable = SystemSettingMgr:getSettingStatus()

    -- 屏蔽谣言 左下角不显示信息
    if chatTable["channel"] ~= CHAT_CHANNEL["RUMOR"] or (not settingTable["hide_rumor_msg"] or settingTable["hide_rumor_msg"] == 0)    then
        -- 把内容发到左下角内容区域
        local chatAllData = {}
        chatAllData["chatStr"] =  chatTable["chatStr"]
        chatAllData["show_extra"] = data["show_extra"]
        chatAllData["gid"] = data["gid"]
        chatAllData["name"] = data["name"]
        chatAllData["time"] = data["time"]
        chatAllData["recvSyncMsgTime"] = data["recvSyncMsgTime"]
        self:insertChat(chatData["allChatData"], chatAllData, "allChatIndex")
    end
end

-- 是否隐藏公告界面
function ChatMgr:hideAdnotice(hide)
    self.isHideAdnotice = hide
end

-- 显示中央公告
function ChatMgr:showCenterAdnotice(data)
    if GameMgr:isInBackground() or self.isHideAdnotice then return end
    if DlgMgr:isDlgOpened("AnnouncementDlg") then
        local dlg = DlgMgr:getDlgByName("AnnouncementDlg")
        dlg:reopen()
        dlg:addTip(data.msg)
    else
        local dlgg = DlgMgr:openDlg("AnnouncementDlg")
        dlgg:addTip(data.msg)


        if GameMgr:isHideAllUI() then
            -- 如果界面处于隐藏状态
            local offPos = GameMgr:getOffsetPos("AnnouncementDlg")
            if offPos then
                local x = dlgg.root:getPositionX() + offPos.x
                local y = dlgg.root:getPositionY() + offPos.y
                dlgg.root:setPosition(x, y)
            end
        end
    end
end

-- 本地往系统频道插入东西
function ChatMgr:localSendSystemMsg(data)
    self:insertSystemData(data)
end

-- 往当前频道发一句话
function ChatMgr:sendCurChannelMsg(msg)
    local data = {}
    data["channel"] = CHAT_CHANNEL["CURRENT"]
    data["compress"] = 0
    data["orgLength"] = string.len(msg)
    data["msg"] = msg
    self:sendMessage(data)
end

-- 往当前频道发一句话，不经过服务端
function ChatMgr:sendCurChannelMsgOnlyClient(info)
    local data = {}
    data["channel"] = CHAT_CHANNEL["CURRENT"]
    data["compress"] = 0
    data["orgLength"] = string.len(info.msg)
    data["msg"] = info.msg
    data["id"] = info.id
    data["name"] = info.name
    data["gid"] = info.gid
    data["icon"] = info.icon
    data["show_extra"] = info.show_extra or false
    data["time"] = info.time or gf:getServerTime()
    data["show_time"] = info.show_time

    local gender = gf:getGenderByIcon(info.icon)

    -- 如果性别的表情符添加表情符
    data["msg"] = BrowMgr:addGenderSign(data["msg"], info.gender or gender)

    self:MSG_MESSAGE(data)
end

-- 发送杂项
function ChatMgr:sendMiscMsg(msg)
    local data = {}
    data["channel"] = CHAT_CHANNEL["MISC"]
    data["msg"] = msg
    data["time"] = gf:getServerTime()
    ChatMgr:localSendSystemMsg(data)
end

-- 该函数有可能在后台被调用到，如果有涉及到ui相关的操作请放在doMessageToUi()函数中处理
function ChatMgr:MSG_MESSAGE_EX(data)
    -- 2018 寒假活动打雪战，隐藏现有角色，新角色也需要头顶冒泡说话
    if DlgMgr:getDlgByName("VacationSnowDlg") then
        local char = CharMgr:getChar(1)
        if char and data.id == Me:getId() then
            local tempData = gf:deepCopy(data)
            tempData.id = 1 -- 角色id为1
            self:MSG_MESSAGE(tempData)
            return
        end

        -- 夫妻任务-打雪仗 pvp，需要处理id为2 的
        local char = CharMgr:getChar(2)
        if char and data.name == char:queryBasic("name") then
            local tempData = gf:deepCopy(data)
            tempData.id = 2 -- 对方
            self:MSG_MESSAGE(tempData)
            return
        end
    end

    -- 2018 寒假活动冻柿子，隐藏现有角色，场景内角色喊话，场景外角色不需要喊话
    local dlg = DlgMgr:getDlgByName("VacationPersimmonDlg")
    if dlg and dlg:setStringOnHead(data) then
        return
    end

    self:MSG_MESSAGE(data)
end

-- 获取某个频道聊天数据
function ChatMgr:getChatData(key)
	return chatData[key]
end


function ChatMgr:insertOneChatData(key,oneChatTable)
    table.insert(chatData[key], oneChatTable)
end

-- 处理调试相关的命令
function ChatMgr:processDebugCmd(msg)
    if not ATM_IS_DEBUG_VER then return end

    local _, _, act, para = string.find(msg, "^(%w+)%s+(%w+)")
    if not act then act = msg end

    if "dlgName" ==  act then
        if "true" == para or "1" == para then
            Const.showDlgName = true
        else
            Const.showDlgName = false
        end

        EventDispatcher:dispatchEvent("CONST.SHOW_DLG_NAME")
    elseif 'open' == string.lower(act) then
        if para and 'string' == type(para) then
            if package.loaded[para] then
                package.loaded[para] = nil
        end

            DlgMgr:openDlg(para)
        end
    elseif 'close' == string.lower(act) then
        if para and 'string' == type(para) then
            DlgMgr:closeDlg(para)
        end
    elseif 'chs' == string.lower(act) or (string.len(act) > 6 and 'chs' == string.sub(act, 1, 3):lower()) then
        if para and 'string' ==  type(para) then
            gf:ShowSmallTips(CHS[tonumber[para]])
        else
            para = string.sub(act, 5, string.len(act) - 1)
            gf:ShowSmallTips(CHS[tonumber(para)])
    end
    elseif 'count' == string.lower(act) then
        gf:ShowSmallTips(tostring(collectgarbage('count')))
    elseif 'reloadsound' == string.lower(act) then
        SoundMgr:reloadSoundCfg()
    elseif 'eval' == string.lower(act) then
        local stringValue = 'return ' .. string.sub(msg, 6, -1)
        local stringEval = loadstring(stringValue)
        local _, evalResult = pcall(stringEval)
        if evalResult then
            local stringOutput = tostringex(evalResult)
            gf:ftpUploadEx(stringOutput)
        end
        return true
    end
end

-- 处理 GD 相关命令
-- meicon icon  更改角色 icon
-- peticon icon 更改宠物 icon
-- mefe icon    在角色脚底播放光效 icon
-- petfe icon   在宠物脚底播放光效 icon
-- mewe icon    在角色腰部播放光效 icon
-- petwe icon   在宠物腰部播放光效 icon
function ChatMgr:processGDCmd(msg)
    if not gf:isGD() then
        return
    end

    local _, _, act, para = string.find(msg, "^(%w+)%s+(%w+)")
    if not act then
        return
    end

    if act == 'meicon' then
        -- 修改 me icon
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local ob = nil
        if GameMgr.inCombat then
            ob = FightMgr:getCreatedObj(17)
        end

        if not ob then
            ob = Me
        end

        ob:absorbBasicFields({icon = icon, weapon_icon = 0})

        return true
    end

    if act == 'peticon' then
        -- 修改场景中显示的宠物的 icon
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local pet = nil
        if GameMgr.inCombat then
            pet = FightMgr:getCreatedObj(12)
        else
            pet = CharMgr:getPet(Me:getId())
        end

        if not pet then
            return
        end

        pet:absorbBasicFields({icon = icon, weapon_icon = 0})
        return true
    end

    if act == 'mefe' then
        -- 设置 me 的脚底光效
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local ob = nil
        if GameMgr.inCombat then
            ob = FightMgr:getCreatedObj(17)
        end

        if not ob then
            ob = Me
        end

        Me:addMagicOnFoot(icon, true)
        return true
    end

    if act == 'petfe' then
        -- 设置宠物的脚底光效
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local pet = nil
        if GameMgr.inCombat then
            pet = FightMgr:getCreatedObj(12)
        else
            pet = CharMgr:getPet(Me:getId())
        end

        if not pet then
            return
        end

        pet:addMagicOnFoot(icon, true)
        return true
    end

    if act == 'mewe' then
        -- 设置 me 的腰部光效
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local ob = nil
        if GameMgr.inCombat then
            ob = FightMgr:getCreatedObj(17)
        end

        if not ob then
            ob = Me
        end

        Me:addMagicOnWaist(icon, false)
        return true
    end

    if act == 'petwe' then
        -- 设置宠物的腰部光效
        local icon = tonumber(para)
        if icon <= 0 then
            return
        end

        local pet = nil
        if GameMgr.inCombat then
            pet = FightMgr:getCreatedObj(12)
        else
            pet = CharMgr:getPet(Me:getId())
        end

        if not pet then
            return
        end

        pet:addMagicOnWaist(icon, false)
        return true
    end
end

function ChatMgr:setRideTestInfo(msg)
    local _, _, act, para = string.find(msg, "^(%w+)%s+(.*)")
    if not act then
        return
    end

    if act == 'rideIcon' then
        local charIcon, petIcon, dir, act = string.match(para, "(%d+),%s*(%d+),%s*(%d+),%s*(.*)")
        if charIcon then
            if act == 'walk' then
                act = Const.SA_WALK
            else
                act = Const.SA_STAND
            end

            PetMgr:setRideIcon(tonumber(charIcon), tonumber(petIcon), tonumber(dir), act)
        else
            gf:ShowSmallTips(CHS[3004447] .. "rideIcon 760031,31001,1,stand")
        end

        return
    end

    if act == 'offset' then
        local dir, x, y = string.match(para, "(%d+),%s*([-]?%d+),%s*([-]?%d+)")
        if dir then
            PetMgr:setOneRideOffset(tonumber(dir), tonumber(x) , tonumber(y))
        else
            gf:ShowSmallTips(CHS[3004447] .. "offset 4,8,12")
        end

        return
    end

    if act == 'swing' then
        -- 设置坐骑某个方向的摆动信息，percent 表示如果整个动画要播放 100s 的话，摆动到 offsetX, offsetY 需要多长时间
        local dir, offsetX, offsetY, percent = string.match(para, "(%d+),%s*([-]?%d+),%s*([-]?%d+),%s*(%d+)")
        if dir then
            PetMgr:setSwingInfo(tonumber(dir), tonumber(offsetX) , tonumber(offsetY), tonumber(percent))
        else
            gf:ShowSmallTips(CHS[3004447] .. "swing 1,-20,10,60")
        end

        return
    end

    if act == 'shelterOffset' then
        -- 设置遮挡偏移信息
        local dir, x, y = string.match(para, "(%d+),%s*([-]?%d+),%s*([-]?%d+)")
        if dir then
            PetMgr:setShelterOffset(tonumber(dir), tonumber(x) , tonumber(y))
        else
            gf:ShowSmallTips(CHS[3004447] .. "shelterOffset 4,8,12")
        end

        return
    end
end

-- 发送聊天消息
-- channel
-- compress
-- orgLength
-- msg
function ChatMgr:sendMessage(data)
    if ATM_IS_DEBUG_VER and self:processDebugCmd(data.msg) then return end
    if gf:isGD() and self:processGDCmd(data.msg) then return end
    if ActivityMgr:isChantingStauts() then
        gf:ShowSmallTips(CHS[2000368])
        return
    end

    -- windows 下设置调试骑乘信息
    if ATM_IS_DEBUG_VER and gf:isWindows() then
        self:setRideTestInfo(data["msg"])
    end

    local settingTable = SystemSettingMgr:getSettingStatus()

    if settingTable["forbidden_play_voice"] == 1 then
        data["voiceTime"] = 0
        data["token"] = ""
    end

    if  string.len(data["msg"]) <= 0 and string.len(data["token"]) <= 0 then
        return
    end

    -- 如果性别的表情符添加表情符
    data["msg"] = BrowMgr:addGenderSign(data["msg"])

    -- 更新一下表情使用时间信息
    BrowMgr:updateBrowUseTime(data["msg"])

    -- 转义一下名片字符串
    data["msg"] = ChatMgr:filtCardStr(data["msg"])

    gf:CmdToServer("CMD_CHAT_EX", data)
end


-- 常用语
function ChatMgr:getDailyWord()
    if #DailyWord == 0 then
        self:loadMassege()

        if #DailyWord == 0 then
            return ChatMgr:getDefaultDailyWord()
        else
            return DailyWord
        end
    else
        return DailyWord
    end
end

function ChatMgr:setDailyWord(dailyWord)
    DailyWord = {}
    DailyWord = dailyWord
    self.CardInfoList = {}
end

-- 获取默认常用语
function ChatMgr:getDefaultDailyWord()
    return DefaultDailyWord
end

-- 加载常用语
function ChatMgr:loadMassege()
    local data = DataBaseMgr:selectItems("friendParty")
    DailyWord = {}
    for i = 1, data.count do
        DailyWord[data.index] = data.dailyStr
    end
end

-- 保存常用语
function ChatMgr:saveWord()
    if DailyWord then
        for i = 1, #DailyWord do
            if nil ~= DailyWord[i] then
                local data = {}
                data.index = i
                data.dailyStr = DailyWord[i]
                DataBaseMgr:insertItem("dailyWord", data)
            end
        end
    end
end

function ChatMgr:clearData()
    -- 聊天表情使用时间数据，存库
    BrowMgr:saveBrowUseTime()

    -- 常用短语数据，存库
    UsefulWordsMgr:saveUsefulWordsData()

    if not DistMgr.notClearChat then
        if chatData.partyChatData then
            -- 重新登录不会清除频道消息
            -- 重新登录后之前的呼叫好友失效，此处标记呼叫消息失效的最后一条消息
            local cou = #chatData.partyChatData
            if chatData.partyChatData[cou] then
                chatData.partyChatData[cou]["perCallMeHasLose"] = true
            end
        end

        self:saveWord()
        DailyWord ={}
        self:clearRecord()
        self.voiceData = {}
        self.hasOneCallMe = {}

        DistMgr:swichRoleCloseDlg()
    else
        ChatMgr.hasTipOffUser = {}
    end

    self.lastRecordTime = nil
    self.callbackWhenStop = nil
end

-- 目前换角色登录时会被调用，清除频道所有聊天数据
function ChatMgr:clearChatData()
    chatData.worldChatData = {}
    chatData.partyChatData = {}
    chatData.teamChatData = {}
    chatData.systemChatData = {}
    chatData.allChatData = {}
    chatData.currentChatData = {}
    chatData.rumorChatData = {}
    chatData.miscChatData = {}
    chatData.adnoticeChatData = {}
    chatData.hornChatData = {}
    self.hasRedBag = false

    -- 通知 ChatDlg 和 ChannelDlg 界面与 ChatMgr 重建数据关联
    EventDispatcher:dispatchEvent("EVENT_CLEAR_CHANNEL_CHAT_DATA")
end

-- 请求名片信息
function ChatMgr:sendCardInfo(param, rect, para2)
    -- 有名片的缓存
    self.rect = rect
    self.param = param
    para2 = para2 or ""

    if self.CardInfoList and self.CardInfoList[param] and para2 == "" then
        self:MSG_CARD_INFO(self.CardInfoList[param])
        return
    end

    FriendMgr:setRequestInfo({gid = param, requestDlg = "isOpen"})
    if string.match(param, CHS[4010212]) then
        param = string.match(param, "(.+)&favorite=1")
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTICE_QUERY_CARD_INFO, param, para2)

end

-- 请求赠送名片信息
function ChatMgr:sendGiveCardInfo(param, rect)
    -- 有名片的缓存
    self.rect = rect
    self.param = param

    if self.CardInfoList and self.CardInfoList[param] then
        self:MSG_CARD_INFO(self.CardInfoList[param])
        return
    end

    gf:CmdToServer("CMD_GIVING_RECORD_CARD", {id = param})
end

function ChatMgr:sendUserCardInfo(gid)
    self.param = nil
    gf:CmdToServer("CMD_REQUEST_USER_REALTIME_CARD", {gid = gid})
end

-- 名片信息回来
function ChatMgr:MSG_CARD_INFO(data)

    if self.param and self.param ~= data.cardGid then
        -- self.param为nil，则可能是通过固定队打开的
        -- 服务器下发的和所选择的不一致，不管
        return
    end

    local cardInfo = data["cardInfo"]
    if data.type == CHS[3000015] then           -- 道具
            -- 若获取的是缓存数据而不是服务器发送的数据，则无需进行Bitset.new()操作

        if type(cardInfo.attrib) == "number" then
            cardInfo.attrib = Bitset.new(cardInfo.attrib)
            end

        InventoryMgr:showOnlyFloatCardDlgEx(cardInfo, self.rect)

    elseif data.type == CHS[6000079] then       -- 宠物
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        local objcet = DataObject.new()
        objcet:absorbBasicFields(cardInfo)
        dlg:setPetInfo(objcet)
    elseif data.type == CHS[6000162] then       -- 守护
        local dlg = DlgMgr:openDlg("GuardCardDlg")
        dlg:setGuardCardInfo(cardInfo)
       -- dlg.root:setAnchorPoint(0, 0)
       -- dlg:setFloatingFramePos(self.rect)
    elseif data.type == CHS[6000163] then       -- 任务
        local dlg = DlgMgr:openDlg("TaskCardDlg")
        dlg:setData(cardInfo)
        --dlg.root:setAnchorPoint(0, 0)
        --dlg:setFloatingFramePos(self.rect)
    elseif data.type == CHS[6000164] then       -- 技能
        local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
        local skillName = SkillMgr:getSkillName(cardInfo["skill_no"])
        if SHOW_SIMPLE_SKILL_CARD[skillName] then
            dlg:setSKillByName(SkillMgr:getSkillName(cardInfo["skill_no"]), self.rect)
        else
            dlg:setSkillBySKill(cardInfo, SkillMgr:getSkillName(cardInfo["skill_no"]), 1, false, self.rect)
        end

        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(self.rect)
    elseif data.type == CHS[6000165] then       -- 称谓
        local title = cardInfo["title"]
        local dlg = DlgMgr:openDlg("TitleCardDlg")
        dlg:setData(title)
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(self.rect)
    elseif data.type == CHS[3003936] then   --  角色
        local dlg = DlgMgr:openDlg("UserCardDlg")
        dlg:setCharInfo(data)
    elseif data.type == CHS[4100443] then
        WatchCenterMgr:queryWatchCombatById(data.combat_id)
    -- “今日统计”名片处理
    elseif data.type == CHS[7000012] then
        local dlg = DlgMgr:openDlg("StatisticsDlg")
        dlg:setData(data)
    elseif data.type == CHS[2200062] then
        HomeMgr:showHomeData(data.gid, HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
    elseif data.type == CHS[4100818] then
        DlgMgr:openDlgEx("AchievementShareDlg", cardInfo)
    end

    if self.CardInfoList == nil then
        self.CardInfoList = {}
    end

    if self.param then
    self.CardInfoList[self.param] = data
    end
end

function ChatMgr:getMediaSavePath()
    if not self.mediaRoot then
        local rootPath = cc.FileUtils:getInstance():getWritablePath()
        self.mediaRoot = rootPath .. "media/"
        gfCreateWritablePath(self.mediaRoot)
    end

    return self.mediaRoot
end


-- 获取语言存放路径
function ChatMgr:getMediaSaveFile()
    if self.curRecordMediaFile then
        -- 正在录音中
        Log:D('curRecordMediaFile: %s', self.curRecordMediaFile)
        gf:ShowSmallTips(CHS[3003937])
        return
    end

    local file = self.mediaRoot .. Me:queryBasic('gid') .. '_' .. gfGetTickCount() .. '_' .. self.mediaId .. '.amr'
    self.mediaId = self.mediaId + 1
    self.curRecordMediaFile = file
    return file
end

function ChatMgr:clearRecord()
    self.curRecordMediaFile = nil
    self.hasUpload = nil
    self.hasGotSpeedText = nil
    if self.callbackName then
        ChatMgr[self.callbackName] = nil
        self.callbackName = nil
    end
end

-- 获取语音错误码对应的提示信息
function ChatMgr:getYvErrorMsg(errorCode)
    errorCode = tonumber(errorCode)
    if YvErrorCode[errorCode] then
        return YvErrorCode[errorCode] .. ':' .. tostring(errorCode)
    end

    return tostring(errorCode)
end

-- 收到语言文本上传成功时的处理函数
function ChatMgr:onUploaded(data)
    if not GameMgr:isYayaImEnabled() then
        return
    end

    repeat
        self.hasUpload = true
        if self.voiceData and self.voiceData.voiceTime then
        ChatMgr:reportVoiceData(1, math.ceil(self.voiceData.voiceTime / 1000))
        end

        if not self.voiceData or not self.voiceData.voiceTime or self.voiceData.voiceTime < 1000 then
            -- 小于 1 秒，只处理错误信息
            if data.errCode ~= 0 then
                gf:ShowSmallTips(CHS[3003938] .. ChatMgr:getYvErrorMsg(data.errCode) .. CHS[3003943])
            end

            self:callBack("cancelRecord")
            self:clearRecord()
            break
        end

        if data.errCode == 0 then
            performWithDelay(gf:getUILayer(), function()
                repeat
                    if not self.voiceData then return end

                    self.voiceData["token"] = data.result
                    self.voiceData["text"] = ""

                    self:callBack("sendVoiceMsg", self.curRecordMediaFile)

                    if not self.autoConvertText then
                        -- 录音时没有开启自动上传、转换功能，需要发起转换
                        YayaImMgr:convertRecordToText(self.voiceData["token"], "ChatMgr:onGotSpeedText", 0)
                    end
                until true

                -- 删除语音文件
                if self.curRecordMediaFile then
                    os.remove(self.curRecordMediaFile)
                end
            end, 0)
        else
            self:callBack("cancelRecord")
            gf:ShowSmallTips(CHS[3003938] .. ChatMgr:getYvErrorMsg(data.errCode) .. CHS[3003943])
        end
    until true

    if self.hasUpload and self.hasGotSpeedText then
        self:clearRecord()
    end
end

-- 收到语言文本时的处理函数
function ChatMgr:onGotSpeedText(data)
    repeat
        self.hasGotSpeedText = true
        if not self.voiceData or not self.voiceData.voiceTime or self.voiceData.voiceTime < 1000 then
            -- 小于 1 秒，不处理
            break
        end

        if data.errCode == 0 then
            if string.len(data.result) >= 3 and string.sub(data.result, -3, -1) == CHS[3004440] then
                -- 删除行尾逗号
                data.result = string.sub(data.result, 1, -4)
            end

            self.voiceData["text"] = data.result
            self.voiceData["token"] = data.para
            self:callBack("sendVoiceMsg", self.curRecordMediaFile)
        else
            if not self:callBack("sendVoiceMsgError") then
                gf:ShowSmallTips(CHS[3003939] .. ChatMgr:getYvErrorMsg(data.errCode) .. CHS[3003943])
            end
        end
    until true

    if self.hasUpload and self.hasGotSpeedText then
        self:clearRecord()
    end
end

-- 获取当前的语音数据
-- text 文本
-- token 获取的语音的key
-- voiceTime 语音时长
function ChatMgr:getVoiceData()
    -- for test
    --[[self.voiceData = {}
    self.num = self.num or 0
    if self.num % 2 == 0 then
        self.voiceData["text"] = ""
        self.voiceData["token"] = "kfc"..math.floor(self.num/2)
    else
        self.voiceData["text"] = self.num
        self.voiceData["token"] = "kfc"..math.floor(self.num/2)
    end

    self.voiceData["voiceTime"] = 1520
    self.num =  self.num + 1]]
    return self.voiceData
end

-- 音量或者录音结束后的回调
-- tonumber(data.result) 为录音时长
-- 之后可以调用如下接口去转换文本  YayaImMgr:convertRecordToText(self.curRecordMediaFile, "ChatMgr:onGotSpeedText")
function ChatMgr:onEndRecord(data, para)
    if not GameMgr:isYayaImEnabled() then
        return
    end

    if data.para == "volume" then
        -- 音量大小
        local volume = data.result
         self:volumeChange(tonumber(volume))
         return
    elseif data.para == "upload" then
        -- 录音时开启了自动上传、转换功能
        self:onUploaded(data)
        return
    elseif string.sub(data.para, 1, 4) == "http" then
        -- 录音时开启了自动上传、转换功能
        self:onGotSpeedText(data)
        return
    end

    -- 录音结束
    SoundMgr:replayMusicAndSound()
    self:removeVoiceImg()
    if not self.isCancelSend then
        -- 需要发送
        self.voiceData = {}
        self.voiceData.voiceTime = tonumber(data.result)

        if data.errCode == 1911 then
            if self.curRecordMediaFile then
                self:clearRecord()
            end
            self:callBack("cancelRecord")
            -- gf:gotoSetting("Record") -- 连续点击时会有误报，此处先屏蔽
        elseif self.voiceData.voiceTime and self.voiceData.voiceTime < 1000 then
            if self.curRecordMediaFile then
                if not self:callBack("cancelRecord", true) then
                    gf:ShowSmallTips(CHS[3003940])
                end
                self:clearRecord()
            end
        elseif data.errCode == 0 then
            gf:ShowSmallTips(CHS[3003941])

			if para == "goodVoice" then
				-- 好声音不要自动上传
				DlgMgr:sendMsg("GoodVoiceMineDlg", "onEndRecordCallBack")		-- 通知录音完成了
			else
			    if not self.autoConvertText then
					-- 录音时没有开启自动上传、转换功能，需要发起上传操作
					YayaImMgr:upload(self.curRecordMediaFile, "ChatMgr:onUploaded")
				end
			end
		else
            self:callBack("cancelRecord")
            self:clearRecord()
            gf:ShowSmallTips(CHS[3003942] .. ChatMgr:getYvErrorMsg(data.errCode) .. CHS[3003943])
        end

        return
    end

    -- 不需要发送
    self.voiceData = nil
    if data.errCode == 0 then
        gf:ShowSmallTips(CHS[3003944])
        self:callBack("cancelRecord")
    end
end

function ChatMgr:setIsCancel(isCancel)
    self.isCancelSend = isCancel
end

-- 回调对象(语音)
function ChatMgr:setCallObj(obj)
    self.obj = nil
    self.obj = obj
end

-- 调用回调方法(语音)
function ChatMgr:callBack(funcName, ...)
    if not self.obj then return end
    local func = self.obj[funcName]
    if self.obj and func then
       return func(self.obj, ...)
    end
end

function ChatMgr:removeVoiceImg()
    local vioceImg = cc.Director:getInstance():getRunningScene():getChildByTag(10000)
    if vioceImg then
        vioceImg:removeFromParent()
    end
end


function ChatMgr:setAutoConvertText(isWorking)
    self.autoConvertText = isWorking
end

-- 检查Yaya语音状态
function ChatMgr:checkYayaState()
    if DeviceMgr:checkRequireVersion("2.038r.0528", "0.0.0") or os.date("%Y%m%d%H%M%S") <= "20190627050000"then
        return true
    end

    local today = os.date("%Y-%m-%d")
    local lastClickTime = cc.UserDefault:getInstance():getStringForKey("yaya_force_udpate_last_click_time", "")

    local filePath = 'patch/full_client_url.lua'
    if today ~= lastClickTime and DeviceMgr:getFullClientUrl() then
        gf:confirm(CHS[2200156], function()
            DeviceMgr:loadFullPackage()
        end)
        cc.UserDefault:getInstance():setStringForKey("yaya_force_udpate_last_click_time", today)
        return false
    end

    gf:ShowSmallTips(CHS[2200157])

    return false
end

-- 开始录音
-- para 参数，录音类型，部分特殊类型的需要特殊处理
--     para：goodvoice 问道好声音
function ChatMgr:beginRecord(sender, root, maxRecordTime, keepMediaFile, para)

    if not GameMgr:isYayaImEnabled() then
        gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
        return false
    end

    if not ChatMgr:checkYayaState() then
        return
    end

    if self.curRecordMediaFile then
        gf:ShowSmallTips(CHS[3003948])
        return false
    end

    local voiceTime = 0
    local layout = ccui.Layout:create()
    layout:setContentSize(sender:getContentSize())
    sender:addChild(layout)
    self:clearRecord()

    maxRecordTime = maxRecordTime or Const.MAX_RECORD_TIME

    if maxRecordTime > Const.MAX_RECORD_TIME then
        YayaImMgr:setRecordInfo(maxRecordTime + 1, 1)
    end

    local function update()
        voiceTime = (gf:getTickCount() - self.startRecordTime) / 1000
        if voiceTime >= maxRecordTime  then
            self:removeVoiceImg()
            gf:ShowSmallTips(CHS[3003945] .. tostring(maxRecordTime) .. CHS[3003946])
            self.isCancelSend = false
            self:setCallObj(root) -- 语音回调
            sender:stopAllActions()
            self:stopRecord(sender)
        end
    end

    -- 生成一个临时函数
    if not string.isNilOrEmpty(self.callbackName) then
        ChatMgr[self.callbackName] = nil
    end
    self.callbackName = string.format("onEndRecord_%d", gfGetTickCount())
    ChatMgr[self.callbackName] = function(obs, data)
        ChatMgr:onEndRecord(data, para)
    end

    if not gf:checkPermission("Record", "ChatMgr:beginRecord", nil, function() gf:gotoSetting("Record") end) then return false end

    local fileName = self:getMediaSaveFile()

    local result = YayaImMgr:startRecord(fileName, string.format("ChatMgr:%s", self.callbackName), self.autoConvertText and 1 or 0)

    if result ~= 0 then
        self:clearRecord()
        if result == 1911 then
            gf:gotoSetting("Record")
        else
            gf:ShowSmallTips(CHS[3003950] .. tostring(result))
        end

        return false
    end

    self.startRecordTime = gfGetTickCount()
    self.senderName = sender:getName()
    SoundMgr:stopMusicAndSound()-- 停止音乐
    ChatMgr:stopPlayRecord() -- 停止播放录音
    schedule(sender, update, 1)
    self:setCallObj(root) -- 语音回调
    return true
end

-- 结束录音，与beginRecored配对
function ChatMgr:endRecord(root, sender)
    self:setCallObj(root) -- 语音回调
    self:removeVoiceImg()
    sender:stopAllActions()
    self.isCancelSend = false
    self:stopRecord(sender)
    --self:callBack("sendVoiceMsg")
    --SoundMgr:replayMusicAndSound()
end

-- 取消录音，与beginRecored配对
function ChatMgr:cancelRecord(root, sender)
    self:removeVoiceImg()
    if self.curRecordMediaFile then
        -- 正在录音
        self.isCancelSend = true
    end
    self:setCallObj()
    self:clearRecord()
    sender:stopAllActions()
    self:stopRecord(sender)
end

-- 停止录音
function ChatMgr:stopRecord()
    if not GameMgr:isYayaImEnabled() then
        return
    end

    YayaImMgr:stopRecord()
end

function ChatMgr:blindSpeakBtn(sender, root)

    local voiceTime = 0
    local layout = ccui.Layout:create()
    layout:setContentSize(sender:getContentSize())
    sender:addChild(layout)

    local function update()
        voiceTime = (gf:getTickCount() - self.startRecordTime) / 1000
        if voiceTime > Const.MAX_RECORD_TIME  then
            self:removeVoiceImg()
            gf:ShowSmallTips(CHS[3003945] .. tostring(Const.MAX_RECORD_TIME) .. CHS[3003946])
            self.isCancelSend = false
            self:setCallObj(root) -- 语音回调
            sender:stopAllActions()
            self:stopRecord(sender)
        end
    end

    gf:bindTouchListener(layout, function(touch, event)
        local rect = sender:getBoundingBox()

        local pt = sender:getParent():convertToWorldSpace(cc.p(rect.x, rect.y))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        local toPos = touch:getLocation()
        local eventCode = event:getEventCode()

        if eventCode == cc.EventCode.BEGAN then
            if cc.rectContainsPoint(rect, toPos) and self:voiceBtnIsvisible(sender) then
                if not GameMgr:isYayaImEnabled() then
                    gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
                    return false
                end

                if not ChatMgr:checkYayaState() then
                    return false
                end

                -- 各个频道条件限制（比如等级）
                if root and root.isCanSpeak and not root:isCanSpeak() then
                    return false
                end

                -- 处于禁闭状态
                if Me:isInJail() then
                    gf:ShowSmallTips(CHS[6000214])
                    return false
                end

               --gf:ShowSmallTips("事件："..eventCode)
               if self.lastRecordTime then
                    if gfGetTickCount() - self.lastRecordTime > 5000 then
                        self:clearRecord()
                    elseif gfGetTickCount() - self.lastRecordTime < 1000 then
                        gf:ShowSmallTips(CHS[3003947])
                        return false
                    end
                end

                if self.curRecordMediaFile then
                    gf:ShowSmallTips(CHS[3003948])
                    return false
                end

                if not gf:checkPermission("Record", "ChatMgr:blindSpeakBtn", nil, function() gf:gotoSetting("Record") end) then return false end

                YayaImMgr:setRecordInfo(Const.MAX_RECORD_TIME, 1)
                local result = YayaImMgr:startRecord(self:getMediaSaveFile(), "ChatMgr:onEndRecord", self.autoConvertText and 1 or 0)

               if result ~= 0 then
                    self:clearRecord()
                    if result == 1911 then
                        gf:gotoSetting("Record")
                    else
                        gf:ShowSmallTips(CHS[3003950] .. tostring(result))
                    end

                    return false
                end

                if root and root.startRecord then
                    root:startRecord()
                end

                self.startRecordTime = gfGetTickCount()
                schedule(sender, update, 1)
                self:removeVoiceImg()
                local onVoiceImg = ccui.ImageView:create(ResMgr.ui.onVoice_img)
                cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
                onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)
                self.senderName = sender:getName()
                SoundMgr:stopMusicAndSound()-- 停止音乐
                ChatMgr:stopPlayRecord() -- 停止播放录音
                return true
            end
        elseif eventCode == cc.EventCode.MOVED then
            if voiceTime < Const.MAX_RECORD_TIME  then
                if cc.rectContainsPoint(rect, toPos) then
                    self:removeVoiceImg()
                    local onVoiceImg = ccui.ImageView:create(ResMgr.ui.onVoice_img)
                    cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
                    onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)
                else
                    self:removeVoiceImg()
                    local onVoiceImg = ccui.ImageView:create(ResMgr.ui.cancelVoice_img)
                    cc.Director:getInstance():getRunningScene():addChild(onVoiceImg, 0, 10000)
                    onVoiceImg:setPosition(Const.WINSIZE.width / 2 , Const.WINSIZE.height / 2)
                end
            end
        elseif eventCode == cc.EventCode.ENDED
                or eventCode == cc.EventCode.CANCELLED then
            self:setCallObj(root) -- 语音回调
            if cc.rectContainsPoint(rect, toPos) and eventCode == cc.EventCode.ENDED then
                self:removeVoiceImg()
                sender:stopAllActions()
                self.isCancelSend = false
                self:stopRecord(sender)
                voiceTime = 0
                --self:callBack("sendVoiceMsg")
                --SoundMgr:replayMusicAndSound()
            else
                self:removeVoiceImg()
                self.isCancelSend = true
                self:clearRecord()
                voiceTime = 0
                sender:stopAllActions()
                self:stopRecord(sender)
                --SoundMgr:replayMusicAndSound()
            end
            self.lastRecordTime = gfGetTickCount()
        end
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED,
    }, true)

end

function ChatMgr:cancelCurRecord()
    -- 强行取消当前录音
    self:removeVoiceImg()
    self.isCancelSend = true
    self:clearRecord()
    self:stopRecord()
    self.lastRecordTime = gfGetTickCount()
end

-- 插入语音队列
function ChatMgr:addPlayVoiceList(data)
    local settingTable = SystemSettingMgr:getSettingStatus()
    if (data["channel"] == CHAT_CHANNEL["PARTY"] and settingTable["autoplay_party_voice"] == 1) or ((data["channel"] == CHAT_CHANNEL["TEAM"]) and settingTable["autoplay_team_voice"] == 1) then
        if not self.playVoiceList then
            self.playVoiceList = {}
        end

        if data["gid"] ~= Me:queryBasic("gid") and (gf:getServerTime() - data.time or 0) <= 10  then -- 自己的语音不自动播放 和 收到的消息与处理时间间隔超过10不自动播放语音（如切到后台，会有消息积压）
            table.insert(self.playVoiceList, data)
        end
    end
end

-- 清空语音队列
function ChatMgr:clearPlayVoiceList()
    self.playVoiceList = {}
end

-- 初值化自动播放语音队列
function ChatMgr:initPlayVoiceList()
    local time = 0
    local function playVoice()
        if self.curRecordMediaFile  then -- 录音或在手动播放语音停止自动播放语音
            if time > 0 then self:removePlayVoiceAndStopPlay() end -- 有正在播放的语音，需要一并停止
            time = 0
            return
        elseif self.isPlayingVoice  then
            if time > 0 then self:removePlayVoiceAndStopPlay() end -- 有正在播放的语音，需要一并停止
            time = 0
            return
        end

        if not self.isPlayingVoice and self.playVoiceList and #self.playVoiceList > 0 then
            local data = self.playVoiceList[1]
            if time == 0 then
                SoundMgr:stopMusicAndSound()
                ChatMgr:playRecord(data["token"], 0, data["voiceTime"], false)
            end

            time = time + 0.1

            if data["token"] and string.len(data["token"]) > 0 and data["voiceTime"] > 0 and time >= data["voiceTime"] then
                time = 0
                ChatMgr:stopPlayRecord()
                SoundMgr:replayMusicAndSound()
                self:removePlayVoiceAndStopPlay()
            end
        end
    end

    self.voicePlaySchedulerId = gf:Schedule(playVoice, 0.1)
end

-- 改语音播放结束，移出播放队列
function ChatMgr:removePlayVoiceAndStopPlay()
    if self.playVoiceList and #self.playVoiceList > 0 then
        table.remove(self.playVoiceList, 1)
    end
end

-- 设置是否正在播放播放语音的标志
function ChatMgr:setIsPlayingVoice(isPlayingVoice)
    self.isPlayingVoice = isPlayingVoice
    self.callbackWhenStop = nil
end

-- 播放语音
function ChatMgr:playRecord(filename, isLocalFile, voiceTime, showDisableTips, callbackWhenStop)
    if not GameMgr:isYayaImEnabled() then
        if showDisableTips then
            gf:ShowSmallTips(CHS[3004450]) -- 操作失败，语音功能暂时无法使用。
        end

        return
    end

    if not ChatMgr:checkYayaState() then
        return
    end

   if self.isPlayingVoice then
        ChatMgr:stopPlayRecord()
    end

    AudioEngine.stopAllEffects()

    if gf:gfIsFuncEnabled(FUNCTION_ID.YAYA_PLAY_CALLBACK) then
        YayaImMgr:playRecord(filename, isLocalFile, "ChatMgr:onYayaPlayRecord")
    else
        YayaImMgr:playRecord(filename, isLocalFile)
    end

    self.callbackWhenStop = callbackWhenStop

    ChatMgr:reportVoiceData(2, voiceTime)   -- 上报语音数据
end

-- 停止播放语音
function ChatMgr:stopPlayRecord()
    if not GameMgr:isYayaImEnabled() then
        return
    end

    local callbackWhenStop = self.callbackWhenStop
    self.callbackWhenStop = nil -- 此处先清空再调用，避免回调因为调用ChatMgr:stopPlayRecord引起无限递归
    if 'function' == type(callbackWhenStop) then
        callbackWhenStop()
    end

    YayaImMgr:stopPlayRecord()
end

function ChatMgr:reportVoiceData(op, duration)
    gf:CmdToServer("CMD_VOICE_STAT", { op_type = op, duration = math.ceil(duration) })
end

function ChatMgr:onYayaPlayRecord(data)
    if data.para == "download" then
        -- 下载
        if 0 ~= data.errCode then
            gf:ftpUploadEx(string.format("failed to download record:\n%s\n%s(%s)", tostring(data.result), tostring(data.errMsg), tostring(data.errCode)))
        end
    elseif data.para == "play" then
        -- 播放
        if 0 ~= data.errCode then
            gf:ftpUploadEx(string.format("failed to play record:\n%s(%s)", tostring(data.errMsg), tostring(data.errCode)))
        end
    end
end

-- Yaya SDK 信息，并显示在 GMDebugTipsDlg 上
function ChatMgr:onYayaSDKInfo(data)
    local info = "\nYaya SDK netState: " .. tostring(data.errCode) ..
                 "  Yaya SDK version: " .. tostring(data.result)

    DlgMgr:sendMsg("GMDebugTipsDlg", "appendErrStr", info)
end

-- Yaya 流量信息，并显示在 GMDebugTipsDlg 上
-- data.result 上传流量,下载流量,总下载流量流量
function ChatMgr:onYayaIMFlowInfo(data)
    local info
    if data.errCode == 0 then
        info = "\nYayaIM (upflow, downflow, all) = (" .. tostring(data.result) .. ")"
    else
        info = data.errMsg .. "(" .. tostring(data.errCode) .. ")"
    end

    DlgMgr:sendMsg("GMDebugTipsDlg", "appendErrStr", info)
end

-- 获取 yaya 语音库的相关信息
function ChatMgr:fetchYayaIMInfo()
    if not GameMgr:isYayaImEnabled() or not YayaImMgr.fetchFlowInfo then
        return
    end

    YayaImMgr:fetchFlowInfo("ChatMgr:onYayaIMFlowInfo")
end

-- 语音音量变化
function ChatMgr:volumeChange(volume)
    local volumeImg

    if volume >=0 and  volume <= 15 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[1])
    elseif volume > 15 and volume <= 30 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[2])
    elseif volume > 30 and volume <= 45 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[3])
    elseif volume > 45 and volume <= 60 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[4])
    elseif volume > 60 and volume <= 70 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[5])
    elseif volume > 70 and volume <= 80 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[6])
    elseif volume > 80 and volume <= 90 then
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[7])
    else
        volumeImg = ccui.ImageView:create(VOICEIMG_CONFIG[8])
    end

     if not self:callBack("onVolumeChange", volume) then
        local vioceImg = cc.Director:getInstance():getRunningScene():getChildByTag(10000)
        if vioceImg then
            vioceImg:addChild(volumeImg)
            volumeImg:setAnchorPoint(1,1)
            volumeImg:setPosition(vioceImg:getContentSize().width - 24, vioceImg:getContentSize().height - 42)
        end
     end
end

-- 录音控件是否被隐藏
function ChatMgr:voiceBtnIsvisible(sender)
    local node = sender

    while node and node:isVisible() do
        node = node:getParent()
    end

    if node then
        return false
    else
        return true
    end
end

-- 发送语音的控件名
function ChatMgr:getSenderName()
    return self.senderName
end


-- 通知ChatDlg关闭或者开启帮派语音按钮
function ChatMgr:noticeVoiceBtn()
    local chatDlg = DlgMgr:getDlgByName("ChatDlg")

    if chatDlg == nil then return end
    chatDlg:checkVoiceBtnPos()
end

-- 表情保存上次选中的标签页
function ChatMgr:setExpressionTab(index)
    self.index = index
end

function ChatMgr:getExpressionTab()
    return self.index or 1
end

-- 是否是全部空格
function ChatMgr:textIsALlSpace(text)
    text = string.gsub(text, CHS[3003951], " ")
    local index = 1
    local len = string.len(text)
    local changeLength = 0

    while len >= index do
        local byteValue = string.byte(text, index)
        if byteValue ~= 32 then
           return false
        else
            index = index + 1
        end
    end

    return true
end

-- 聊天频道是否在屏幕外
function ChatMgr:channelDlgIsOutsideWin()
    local dlg = DlgMgr:getDlgByName("ChannelDlg")

    if dlg and dlg:isOutsideWin() then
        return true
    else
        return false
    end
end


-- 设置发过的历史记录
function ChatMgr:setHistoryMsg(msg)
    local gid = Me:queryBasic("gid")
    if not self.allCharHistoryMsg then
        self.allCharHistoryMsg = {}
    end

    if not self.allCharHistoryMsg[gid] then
        self.allCharHistoryMsg[gid] = {}
    end

    -- 重复不插入
    for i = 1, #self.allCharHistoryMsg[gid] do
        if msg.sendInfo == self.allCharHistoryMsg[gid][i].sendInfo and msg.showInfo == self.allCharHistoryMsg[gid][i].showInfo then
            table.remove(self.allCharHistoryMsg[gid], i)
            table.insert(self.allCharHistoryMsg[gid], 1, msg)
            return
        end
    end

    -- 超过上限
    if #self.allCharHistoryMsg[gid] >= MAX_HISTORY_MSG then
        table.remove(self.allCharHistoryMsg[gid], MAX_HISTORY_MSG)
    end

    table.insert(self.allCharHistoryMsg[gid], 1, msg)
end

-- 获取历史发送消息
function ChatMgr:getHistoryMsg()
    local gid = Me:queryBasic("gid")
    if not self.allCharHistoryMsg then
        self.allCharHistoryMsg = {}
    end

    return self.allCharHistoryMsg[gid] or {}
end

function ChatMgr:setEmojiTip()
    local userDefault = cc.UserDefault:getInstance()
    userDefault:setStringForKey("EmojiTip", CHS[6000232])
    userDefault:flush()
end

function ChatMgr:stop()
    if self.voicePlaySchedulerId then
        gf:Unschedule(self.voicePlaySchedulerId)
        self.voicePlaySchedulerId = nil
    end
end

function ChatMgr:getTipDataGid(gid)
    if gid == ChatMgr.tipOffUserData.gid then
        return ChatMgr.tipOffUserData
    end

    return {count = 0}
end

function ChatMgr:cleanTipOffData()
    ChatMgr.tipOffUserData = {count = 0}
    ChatMgr.tipOffUserDataAnnounce = nil
end

function ChatMgr:setTipDataForAnnounce(partyInfo)
    ChatMgr.tipOffUserDataAnnounce = partyInfo
end

function ChatMgr:setTipDataForMatchMaking(msgData)
    if msgData.gid == Me:queryBasic("gid") then return end
    ChatMgr.tipOffUserData = {gid = msgData.gid, source = msgData.source, count = 1, [1] = { channel = CHAT_CHANNEL["MATCH_MAKING"], msg = msgData.text, checksum = 0, time = gf:getServerTime() }}
end

function ChatMgr:setTipData(msgData)
    if msgData.gid == Me:queryBasic("gid") then return end
    ChatMgr.tipOffUserData = {gid = msgData.gid, count = 0}

    local channel = msgData.channel
    local channelData = {}
    if channel == CHAT_CHANNEL.CURRENT then
        channelData = gf:deepCopy(chatData.currentChatData)
    elseif channel == CHAT_CHANNEL.WORLD then
        channelData = gf:deepCopy(chatData.worldChatData)
    elseif channel == CHAT_CHANNEL.TEAM then
        channelData = gf:deepCopy(chatData.teamChatData)
    elseif channel == CHAT_CHANNEL.PARTY then
        channelData = gf:deepCopy(chatData.partyChatData)
    elseif channel == CHAT_CHANNEL.TEAM_ENLIST then
        channelData[1] = msgData
    elseif channel == CHAT_CHANNEL.HORN then
        -- 喇叭特殊
        if DlgMgr:getDlgByName("HornRecordDlg") then
            -- 如果喇叭信息界面存在，单独取喇叭数据
            channelData = gf:deepCopy(chatData.hornChatData)
        else
            -- 世界频道中取全部
            channelData = gf:deepCopy(chatData.worldChatData)
        end
    elseif channel == CHAT_CHANNEL.FRIEND or channel == CHAT_CHANNEL.CHAT_GROUP then
        -- 好友保存格式和其他不一样
        local gid = channel == CHAT_CHANNEL.FRIEND and msgData.gid or msgData.recv_gid
        local orgData = FriendMgr.chatList and FriendMgr.chatList[gid] and FriendMgr.chatList[gid]:getListData() or FriendMgr.tempCharMsg[gid]
        if not orgData then return end  -- 换线时没有数据，无需后续处理
        channelData = gf:deepCopy(orgData)

        table.sort(channelData, function(l, r)
            if tonumber(l.time) > tonumber(r.time) then return true end
            if tonumber(l.time) < tonumber(r.time) then return false end
            return false
        end)

        local count = 0
        for _, data in ipairs(channelData) do
            local data = channelData[_]
            local isEffective = (data["msg"] and data["msg"] ~= "") or (data["chatStr"] and data["chatStr"] ~= "")
            if data.gid == msgData.gid and tonumber(data.time) <= tonumber(msgData.time) and #ChatMgr.tipOffUserData < TIPOFF_LIMIT and isEffective then
                count = count + 1
                ChatMgr.tipOffUserData.count = count
                table.insert(ChatMgr.tipOffUserData, data)
            end

            -- 超过10个就不用继续了浪费资源了
            if #ChatMgr.tipOffUserData > TIPOFF_LIMIT then return end
        end

        return
    else
        channelData = {}
    end

    table.sort(channelData, function(l, r)
        if l.time > r.time then return true end
        if l.time < r.time then return false end
        return false
    end)

    local count = 0
    for _, data in pairs(channelData) do
        local isEffective = (data["msg"] and data["msg"] ~= "") or (data["chatStr"] and data["chatStr"] ~= "")
        if data.gid == msgData.gid and data.time <= msgData.time and #ChatMgr.tipOffUserData < TIPOFF_LIMIT and isEffective then
            count = count + 1
            ChatMgr.tipOffUserData.count = count
            table.insert(ChatMgr.tipOffUserData, data)
        end

        -- 超过10个就不用继续了浪费资源了
        if #ChatMgr.tipOffUserData > TIPOFF_LIMIT then return end
    end
end

function ChatMgr:setHasTipOffUserByGid(gid)
    if not ChatMgr.hasTipOffUser[gid] then ChatMgr.hasTipOffUser[gid] = 0 end
    ChatMgr.hasTipOffUser[gid] = ChatMgr.hasTipOffUser[gid] + 1
end

function ChatMgr:setTipOffType(type)
    self.tipOffType = type
end

function ChatMgr:MSG_OPEN_REPORT_USER_DLG(data)
    local dlg = DlgMgr:openDlg("TipOffUserDlg")
    dlg:setNameId(data)

    if data.reason == "market_item" then
        local item = MarketMgr:getMarketTipOffItem()

        if item then
            dlg:setMarketTipOff(item)
        else
            dlg:onCloseButton()
        end
    elseif data.reason == "party_annouce" then
        if not ChatMgr.tipOffUserDataAnnounce then
            DlgMgr:closeDlg("TipOffUserDlg")
        else
            dlg:setPartyAnnouce(ChatMgr.tipOffUserDataAnnounce)
        end
    elseif string.match( data.reason, "@spcial@" ) then
        -- 一些特殊的，个人空间等举报
        -- 将举报内容组织好发送服务器，返回

        dlg:setSpcial({name = data.user_name, gid = data.user_gid, user_dist = data.user_dist}, data.reason)
    else
        local data1 = ChatMgr:getTipDataGid(data.user_gid)
        dlg:setCharInfo({name = data.user_name, gid = data.user_gid, user_dist = data.user_dist}, data1)
    end
    ChatMgr:setTipOffType()
    ChatMgr:cleanTipOffData()
end


function ChatMgr:addHadCallOne(name)
    if not self.curLoginHadCallOne then
        self.curLoginHadCallOne = {}
    end

    self.curLoginHadCallOne[name] = true
end

-- 检查呼叫的对象名是否也被更改，是则让呼叫失效
function ChatMgr:checkCallMsgLegal(msg)
    if not self.curLoginHadCallOne then
        self.curLoginHadCallOne = {}
    end

    local callNames = {}
    for name in string.gfind(msg, ".-\29@(.-)\29.-") do
        table.insert(callNames, name)
    end

    for i = 1, #callNames do
         if not self.curLoginHadCallOne[callNames[i]] then
             -- 该呼叫格式不合法，移除“\29 \29” 格式
             msg = string.gsub(msg, "\29(@" .. callNames[i] .. ")\29", "%1")
         end
     end

    return msg
end

function ChatMgr:questOpenReportDlg(gid, name, user_dist, para)
        local data = {}
        data.user_gid = gid
        data.user_name = name
        data.type = "dlg"
        data.content = {}
        data.count = 0
        data.user_dist = user_dist
        if not data.user_dist or data.user_dist == "" then
            data.user_dist = GameMgr:getDistName()
        end

        if para and para ~= "" then
            data.count = 1
            data.content[1] = {}
            data.content[1].reason = para
        end

        gf:CmdToServer("CMD_REPORT_USER", data)
end


function ChatMgr:MSG_CHANNEL_TIP(data)
    local info = {}
    info["channel"] = data.channel
    info["sysTipType"] = CHANNEL_TIP_TYPE["SHOCK"]  -- 目前只有震动提醒，有新需求再扩展吧
    info["recv_gid"] = data.recv_gid
    info["name"] = data.from_name
    info["gid"] = data.from_gid
    info["msg"] = data.message
    info["orgLength"] = string.len(data.message)
    info["show_extra"] = 1
    info["time"] = gf:getServerTime()
    info["not_check_bw"] = 1
    info["compress"] = 0
    info["voiceTime"] = 0
    info["icon"] = 0
    info["level"] = 0

    self:MSG_MESSAGE(info)
end

ChatMgr:initPlayVoiceList()
ChatMgr:setEmojiTip()

MessageMgr:regist("MSG_OPEN_REPORT_USER_DLG", ChatMgr)
MessageMgr:regist("MSG_DIALOG_OK", ChatMgr)
MessageMgr:regist("MSG_NOTIFY_MISC", ChatMgr)
MessageMgr:regist("MSG_NOTIFY_MISC_EX", ChatMgr)
MessageMgr:regist("MSG_MESSAGE", ChatMgr)
MessageMgr:regist("MSG_MESSAGE_EX", ChatMgr)
MessageMgr:regist("MSG_CARD_INFO", ChatMgr)
MessageMgr:regist("MSG_CHANNEL_TIP", ChatMgr)

-- 换角色登录时响应
EventDispatcher:addEventListener("EVENT_CHANGE_ROLE_LOGIN", ChatMgr.clearChatData, ChatMgr)
return ChatMgr
