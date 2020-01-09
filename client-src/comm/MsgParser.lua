-- created by cheny Feb/19/2014
-- 消息解析器

local MsgParser = {}
local Builders = require "comm/Builders"
local Msg = require "comm/global_send"

-- 进行容错处理， dir 只能去 0 到 7 之间的一个数值
local adjustDir = function(dir)
    if dir <= 0 then
        return 0
    elseif dir >= 7 then
        return 7
    else
        return dir
    end
end

-------------------------------------------------------------------------------
-- lua 层直接解析数据的接口
-- 除了 buffer 类接口外，其他的接口效率均比 c++ 层提供的 Packet 类低
-- 所以只有当需要频繁调用  buffer 类接口时才使用这一组接口
-- 如：MSG_LOOKON_COMBAT_RECORD_DATA
function MsgParser:getShort(str, index, strLen)
    if strLen - index + 1 < 2 then
        -- 数据不足
        return 0, index
    end

    local b1, b2 = string.byte(str, index, index + 1)
    return b1 * 256 + b2, index + 2
end

function MsgParser:getLong(str, index, strLen)
    if strLen - index + 1 < 2 then
        -- 数据不足
        return 0, index
    end

    local b1, b2, b3, b4 = string.byte(str, index, index + 3)
    return ((b1 * 256 + b2) * 256 + b3) * 256 + b4, index + 4
end

function MsgParser:getLenString(str, index, strLen)
    if strLen - index + 1 < 1 then
        -- 数据不足
        return "", index
    end

    local len = string.byte(str, index)
    local ret = string.sub(str, index + 1, index + len)
    ret = gfGBKToUTF8(ret)
    return ret, index + 1 + len
end

function MsgParser:getLenBuffer2(str, index, strLen)
    if strLen - index + 1 < 2 then
        -- 数据不足
        return "", index
    end

    local b1, b2 = string.byte(str, index, index + 1)
    local len = b1 * 256 + b2
    return string.sub(str, index + 2, index + 1 + len), index + 2 + len
end
-------------------------------------------------------------------------------

function MsgParser:CMD_ECHO(pkt, data)
end

function MsgParser:MSG_REPLY_ECHO(pkt, data)
    data.peer_time = pkt:GetLong()
end

function MsgParser:MSG_L_ANTIBOT_QUESTION(pkt, data)
    data.question = pkt:GetLenString4()
end

function MsgParser:MSG_L_CHECK_USER_DATA(pkt, data)
    data.result = pkt:GetLong()
    data.cookie = pkt:GetLenString()
end

function MsgParser:MSG_L_AUTH(pkt, data)
    data.type = pkt:GetLenString()
    data.result = pkt:GetLong()
    data.auth_key = pkt:GetLong()
    data.msg = pkt:GetLenString2()
end

function MsgParser:MSG_L_CHANGE_ACCOUNT_ABORT(pkt, data)
    data.flag = pkt:GetChar()
end

function MsgParser:MSG_L_SERVER_LIST(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        data[string.format("id%d", i)] = pkt:GetShort()
        data[string.format("server%d", i)] = pkt:GetLenString()
        data[string.format("ip%d", i)] = pkt:GetLenString()
    end
    for i = 1, count, 1 do
        data[string.format("status%d", i)] = pkt:GetShort()
    end
end

function MsgParser:MSG_L_AGENT_RESULT(pkt, data)
    data.result = pkt:GetLong()
    data.privilege = pkt:GetShort()
    data.ip = pkt:GetLenString()
    data.port = pkt:GetShort()
    data.seed = pkt:GetSignedLong()
    data.auth_key = pkt:GetLong()
    data.id = pkt:GetShort()
    data.serverName = pkt:GetLenString()
    data.serverStatus = pkt:GetChar()

    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_ANSWER_FIELDS(pkt, data)
    local pairs = pkt:GetShort()
    for i = 1, pairs, 1 do
        Builders._fields[pkt:GetShort()] = pkt:GetLenString()
    end
    Log:D("Fields:")
    gf:PrintMap(Builders._fields)
end

function MsgParser:MSG_EXISTED_CHAR_LIST(pkt, data)
    data.severState = pkt:GetShort()
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local char = {}
        Builders:BuildFields(pkt, char)
        char.last_login_time = pkt:GetLong()
        data[i] = char
    end

    data.openServerTime = pkt:GetLong()
    data.account_online = pkt:GetChar() -- 0 不在线；       1 在线；   2 托管中
end

function MsgParser:MSG_ENTER_GAME(pkt, data)
    data.flag = pkt:GetShort()
    data.dist = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.time = pkt:GetLong()
    data.clientTime = gfGetTickCount()
    data.lineNum = pkt:GetShort()
    data.corss_server_dist = pkt:GetChar()
    data.time_zone = pkt:GetSignedChar()
end

function MsgParser:MSG_MENU_LIST(pkt, data)
    data.id = pkt:GetLong()
    data.portrait = pkt:GetLong()
    data.pic_no = pkt:GetShort()
    data.content = pkt:GetLenString2()
    data.secret_key = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.attrib = pkt:GetChar()
end

function MsgParser:MSG_MESSAGE(pkt, data)
    data.channel = pkt:GetShort()
    data.id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.msg = pkt:GetLenString2()
    data.time = pkt:GetLong()
    data.privilege = pkt:GetShort()
    data.server_name = pkt:GetLenString()
    if pkt:GetDataLen() >= 2 then
        data.show_extra = pkt:GetShort()
    end

    data.show_time = pkt:GetChar()
    data.icon = pkt:GetShort()
end

function MsgParser:MSG_NOTIFY_MISC(pkt, data)
    data.msg = pkt:GetLenString2()
    data.time = pkt:GetLong()
end

function MsgParser:MSG_NOTIFY_MISC_EX(pkt, data)
    data.msg = pkt:GetLenString2()
    data.time = pkt:GetLong()
end

function MsgParser:MSG_MESSAGE_IN_RECORD_COMBAT(pkt, data)
    self:MSG_MESSAGE_EX(pkt, data)
end

function MsgParser:MSG_MESSAGE_EX(pkt, data)
    data.channel = pkt:GetShort()
    data.id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.msg = pkt:GetLenString2()
    data.time = pkt:GetLong()
    data.privilege = pkt:GetShort()
    data.server_name = pkt:GetLenString()
    data.show_extra = pkt:GetShort()
    data.compress = pkt:GetShort()
    data.orgLength = pkt:GetShort()
    --data.gid = pkt:GetLenString()
    --data.icon = pkt:GetLong()
    data.cardCount = pkt:GetShort()
    data.cardList = {}
    if data.cardCount > 0 then
        for i = 1, data.cardCount do
            local cardId = pkt:GetLenString()
            -- 服务器中有些名字是带地图名的，如"鹰<北海沙滩>"，故需要将其地图名信息去除
            if string.match(cardId, "<(.+)>") then
                data.cardList[i] = string.gsub(cardId, "<(.+)>", "")
            else
            data.cardList[i] = cardId
        end
    end
    end

    data.voiceTime = pkt:GetLong()
    data.token = pkt:GetLenString2()
    data.checksum = pkt:GetLong()
    -- todo test
   --[[ local voiceData = ChatMgr:getVoiceData()
    if  voiceData then
        data.voiceTime = voiceData["voiceTime"]
        data.token = voiceData["token"]
    end]]


    -- 用来储存好友相关信息
    Builders:BuildFields(pkt, data)

    if data["npc_chat"] then
        -- 愚人节使用喇叭要将玩家头像显示为 npc 头像
        local info = gf:split(data["npc_chat"], ":")
        data["npc_name"] = info[1]
        data["npc_icon"] = info[2]
    end

    if pkt:GetDataLen() <= 0 then return end

    local nItemCookieCount = pkt:GetShort()
    data.item_cookie_count = nItemCookieCount
    for i = 1, nItemCookieCount do
        data[string.format("item_cookie_%d", i)] = pkt:GetLenString()
    end

    if pkt:GetDataLen() <= 0 then return end
    data.tip_index = pkt:GetShort()
end

function MsgParser:MSG_TITLE(pkt, data)
    data.id = pkt:GetLong()
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count, 1 do
        data[i] = tostring(pkt:GetChar())
    end
end

function MsgParser:MSG_RELOCATE(pkt, data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = adjustDir(pkt:GetChar())
end

function MsgParser:MSG_UPDATE_IMPROVEMENT(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_INVENTORY(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local item = {}
        local pos = pkt:GetChar()
        item.pos = pos
        Builders:BuildItemInfo(pkt, item)
        item.extra.pos = pos
        data[i] = item
    end
end

function MsgParser:MSG_OPEN_TIANXS_DIALOG(pkt, data)
    data.price = pkt:GetShort()
    data.max_count = pkt:GetShort()
end

function MsgParser:MSG_REENTRY_ASKTAO_RESULT(pkt, data)
    data.reward = pkt:GetLenString()
end

-- 再续前缘 回归积分商城
function MsgParser:MSG_COMEBACK_SCORE_SHOP_ITEM_LIST(pkt, data)
    data.score = pkt:GetLong()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].index = pkt:GetChar()
        data[i].name = pkt:GetLenString()
        data[i].price = pkt:GetLong()
        data[i].amount = pkt:GetShort()
        data[i].bind = pkt:GetLong()
    end
end

function MsgParser:MSG_RECALL_SCORE_SHOP_ITEM_LIST(pkt, data)
    self:MSG_COMEBACK_SCORE_SHOP_ITEM_LIST(pkt, data)
end


function MsgParser:MSG_RECALLED_USER_DATA_LIST(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].gid = pkt:GetLenString()
        data[i].name = pkt:GetLenString()
        data[i].icon = pkt:GetLong()
        data[i].level = pkt:GetShort()
        data[i].recalled_time = pkt:GetLong()
    end
end

function MsgParser:MSG_LIVENESS_LOTTERY_RESULT(pkt, data)
    data.reward = pkt:GetLenString()
end

function MsgParser:MSG_LIVENESS_REWARDS(pkt, data)
    data.activityRewardCount = pkt:GetChar()
    for i= 1, data.activityRewardCount do
        local activityRewardStatus = {}
        activityRewardStatus.activity = pkt:GetShort()
        activityRewardStatus.status = pkt:GetChar()
        data[i] = activityRewardStatus
    end
end

function MsgParser:MSG_FESTIVAL_LOTTERY_RESULT(pkt, data)
    data.activeName = pkt:GetLenString()
    if data.activeName == "spring_day_2017" then
        data.gameStartTime = pkt:GetLong()
        data.spentTime = pkt:GetLong()
        data.count = pkt:GetChar()
        data.redBagStatus = {}
        for i = 1, data.count do
            data.redBagStatus[i] = pkt:GetChar()
        end
    else
    data.status = pkt:GetChar()
    if data.status > 0 then
    data.rewardIndex = pkt:GetChar()
        if pkt:GetDataLen() >= 2 then
            data.rewardIndex2 = pkt:GetChar()
            data.rewardIndex3 = pkt:GetChar()
        end
    end
    end
end

function MsgParser:MSG_UPDATE_SKILLS(pkt, data)
    data.id = pkt:GetLong()
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local skill = {}
        Builders:BuildSkillBasicInfo(pkt, skill)
        data[i] = skill
    end
end

function MsgParser:MSG_UPDATE(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_UPDATE_APPEARANCE(pkt, data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = adjustDir(pkt:GetShort())
    data.icon = pkt:GetLong()
    data.weapon_icon = pkt:GetLong()
    data.type = pkt:GetShort()
    data.sub_type = pkt:GetLong()
    data.owner_id = pkt:GetLong()
    data.leader_id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
    data.title = pkt:GetLenString()
    data.family = pkt:GetLenString()
    data["party/name"] = pkt:GetLenString()
    data.status = pkt:GetLong()
    data.special_icon = pkt:GetLong()
    if pkt:GetDataLen() >= 4 then
        data.org_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.suit_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.suit_light_effect = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.guard_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.pet_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.shadow_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.shelter_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.mount_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 1 then
        data.alicename = pkt:GetLenString()
    end

    data.gid = pkt:GetLenString()
    data.camp = pkt:GetLenString()
    data.vip_type = pkt:GetChar()   -- 会员类型
    data.isHide = pkt:GetChar()
    data.moveSpeedPercent = pkt:GetSignedChar()
    data["ct_data/score"] = pkt:GetSignedLong()
    data.opacity = pkt:GetChar()
    data.masquerade = pkt:GetLong()
    data["upgrade/state"] = pkt:GetChar()
    data["upgrade/type"] = pkt:GetChar()
    data["obstacle"] = pkt:GetChar()
    data.light_effect_count = pkt:GetShort()
    data.light_effect = {}
    for i = 1, data.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.light_effect, effect)
    end

    if pkt:GetDataLen() >= 4 then
        data.share_mount_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.share_mount_leader_id = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.share_mount_shadow = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 2 then
        data.gather_count = math.max(pkt:GetShort() - 1, 0)

    data.gather_icons = {}
    if pkt:GetDataLen() >= 4 * data.gather_count then
        if data.gather_count >= 1 then                           -- 存在乘客
            data.mount_icon = pkt:GetLong()                     -- 第一位是司机
            for i = 1, data.gather_count do
                table.insert(data.gather_icons, pkt:GetLong())  -- 乘客
            end
        end
    end
    if pkt:GetDataLen() >= 2 then
        data.gather_name_num = pkt:GetShort()
    end
    data.gather_names = {}
    if pkt:GetDataLen() > 0 then
        for i = 1, data.gather_name_num do
            table.insert(data.gather_names, pkt:GetLenString())
        end
    end
    end

    if pkt:GetDataLen() >= 4 then
        data.portrait = pkt:GetLong()
    end

    if pkt:GetDataLen() >= 1 then
        local customIcon = pkt:GetLenString()
        if not string.isNilOrEmpty(customIcon) then
            data.part_index, data.part_color_index = string.match(customIcon, "(.+):(.+)")
        else
            data.part_index, data.part_color_index = "", ""
        end
    end
end

function MsgParser:MSG_UPDATE_APPEARANCE_FIELDS(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_ENTER_ROOM(pkt, data)
    data.map_id = pkt:GetLong()
    data.map_name = pkt:GetLenString()
    data.map_show_name = pkt:GetLenString()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = adjustDir(pkt:GetChar())
    data.map_index = pkt:GetLong()
    data.compact_map_index = pkt:GetShort()
    data.floor_index = pkt:GetChar()
    data.wall_index = pkt:GetChar()
    data.is_safe_zone = pkt:GetChar()
    data.is_task_walk = pkt:GetChar() == 1 and true or false
    data.enter_effect_index = pkt:GetChar()
end

function MsgParser:MSG_DIALOG_OK(pkt, data)
    data.msg = pkt:GetLenString2()
    data.active = pkt:GetShort()
    data.mode = pkt:GetShort()
end

function MsgParser:MSG_SYNC_MESSAGE(pkt, data)
    local dataLen = pkt:GetDataLen()
    local msgLen = pkt:GetShort()
    if dataLen ~= msgLen then
        -- 消息格式不正确
        Log:W("Invalid MSG_SYNC_MESSAGE")
        return
    end

    data.sync_msg = pkt:GetShort()

    local msgStr = Msg[data.sync_msg]
    if not msgStr then
        -- 没有定义该消息
        Log:W(string.format("No msg %04X in global_send.", data.sync_msg))
        return
    end

    -- 解析消息
    local func = MsgParser[msgStr]
    if not func then
        -- 没有解析函数
        Log:W(msgStr.." no parser in MsgParser.")
        return
    end
    local syncData = {
        _socketNo = data._socketNo,
        MSG = data.sync_msg,
        recvSyncMsgTime = gfGetTickCount()
    }

    func(MsgParser, pkt, syncData)

    data.key = MessageMgr:addSyncMsg(syncData)
end

function MsgParser:MSG_C_UPDATE_COMBAT_INFO(pkt, data)
    data.id = pkt:GetLong()
    data.isSet = pkt:GetChar()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_C_UPDATE_APPEARANCE(pkt, data)
    MsgParser:MSG_UPDATE_APPEARANCE(pkt, data)
end


function MsgParser:MSG_C_START_COMBAT(pkt, data)
    data.flag = pkt:GetShort()
    data.mode = pkt:GetChar()
end

function MsgParser:MSG_C_FRIENDS(pkt, data)
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count, 1 do
        local char = {}
        char.id = pkt:GetLong()
        char.leader = pkt:GetShort()
        char.weapon_icon = pkt:GetShort()
        char.pos = pkt:GetShort()
        char.rank = pkt:GetShort()
        char.vip_type = pkt:GetShort()
        Builders:BuildFields(pkt, char)
        char.org_icon = pkt:GetShort()
        char.suit_icon = pkt:GetLong()
        char.suit_light_effect = pkt:GetLong()
        char.special_icon = pkt:GetLong()
        data[i] = char
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local customIcon = pkt:GetLenString()
            local char = data[i]
            if not string.isNilOrEmpty(customIcon) then
                char.part_index, char.part_color_index = string.match(customIcon, "(.+):(.+)")
            else
                char.part_index, char.part_color_index = "", ""
            end
        end
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local char = data[i]
            char.effectIcons = {}
            local size = pkt:GetChar()
            for j = 1, size do
                table.insert(char.effectIcons, pkt:GetLong())
            end
        end
    end
end

function MsgParser:MSG_LC_FRIENDS(pkt, data)
    self:MSG_C_FRIENDS(pkt, data)
end

function MsgParser:MSG_C_OPPONENTS(pkt, data)
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count, 1 do
        local char = {}
        char.id = pkt:GetLong()
        char.leader = pkt:GetShort()
        char.weapon_icon = pkt:GetShort()
        char.pos = pkt:GetShort()
        char.rank = pkt:GetShort()
        char.vip_type = pkt:GetShort()
        Builders:BuildFields(pkt, char)
        char.org_icon = pkt:GetShort()
        char.suit_icon = pkt:GetLong()
        char.suit_light_effect = pkt:GetLong()
        char.special_icon = pkt:GetLong()
        data[i] = char
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local customIcon = pkt:GetLenString()
            local char = data[i]
            if not string.isNilOrEmpty(customIcon) then
                char.part_index, char.part_color_index = string.match(customIcon, "(.+):(.+)")
            else
                char.part_index, char.part_color_index = "", ""
            end
        end
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local char = data[i]
            char.effectIcons = {}
            local size = pkt:GetChar()
            for j = 1, size do
                table.insert(char.effectIcons, pkt:GetLong())
            end
        end
    end
end

function MsgParser:MSG_LC_OPPONENTS(pkt, data)
    self:MSG_C_OPPONENTS(pkt, data)
end

function MsgParser:MSG_C_WAIT_COMMAND(pkt, data)
    data.menu = pkt:GetShort()
    data.id = pkt:GetLong()
    data.time = pkt:GetShort()
    data.question = pkt:GetLong()
    data.round = pkt:GetShort()
    data.curTime = pkt:GetLong()
end

function MsgParser:MSG_LC_WAIT_COMMAND(pkt, data)
    self:MSG_C_WAIT_COMMAND(pkt, data)
end

function MsgParser:MSG_C_ACTION(pkt, data)
    data.round = pkt:GetShort()
    data.attacker_id = pkt:GetLong()
    data.action = pkt:GetShort()
    data.victim_id = pkt:GetLong()
    data.para = pkt:GetLong()
end

function MsgParser:MSG_LC_ACTION(pkt, data)
	self:MSG_C_ACTION(pkt, data)
end

function MsgParser:MSG_C_END_ACTION(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_LC_END_ACTION(pkt, data)
	self:MSG_C_END_ACTION(pkt, data)
end

function MsgParser:MSG_C_ACCEPT_HIT(pkt, data)
    data.id = pkt:GetLong()
    data.hitter_id = pkt:GetLong()
    data.para_ex = pkt:GetLong()
    data.missed = pkt:GetShort()
    data.para = pkt:GetShort()
    data.damage_type = pkt:GetLong()
end

function MsgParser:MSG_LC_ACCEPT_HIT(pkt, data)
	self:MSG_C_ACCEPT_HIT(pkt, data)
end

function MsgParser:MSG_C_LIFE_DELTA(pkt, data)
    data.id = pkt:GetLong()
    data.hitter_id = pkt:GetLong()
    data.point = pkt:GetLong()
    data.effect_no = pkt:GetLong()
    data.damage_type = pkt:GetLong()
end

function MsgParser:MSG_LC_LIFE_DELTA(pkt, data)
	self:MSG_C_LIFE_DELTA(pkt, data)
end

function MsgParser:MSG_C_UPDATE(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_LC_UPDATE(pkt, data)
	self:MSG_C_UPDATE(pkt, data)
end

function MsgParser:MSG_C_CHAR_DIED(pkt, data)
    data.id = pkt:GetLong()
    data.damage_type = pkt:GetLong()
end

function MsgParser:MSG_LC_CHAR_DIED(pkt, data)
	self:MSG_C_CHAR_DIED(pkt, data)
end

function MsgParser:MSG_C_END_COMBAT(pkt, data)
    data.flag = pkt:GetShort()
end

function MsgParser:MSG_LC_END_LOOKON(pkt, data)
    self:MSG_C_END_COMBAT(pkt, data)
end

function MsgParser:MSG_LC_START_LOOKON(pkt, data)
    if pkt:GetDataLen() > 0 then
        data.isBroadcast = pkt:GetChar()
    end

    if pkt:GetDataLen() > 0 then
        data.mode = pkt:GetChar()
end
end

function MsgParser:MSG_LC_LOOKON_NUM(pkt, data)
    data.num = pkt:GetShort()  -- 观战人数
end

function MsgParser:MSG_C_QUIT_COMBAT(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_LC_QUIT_COMBAT(pkt, data)
    self:MSG_C_QUIT_COMBAT(pkt, data)
end

function MsgParser:MSG_C_FLEE(pkt, data)
    data.id = pkt:GetLong()
    data.success = pkt:GetChar()
    data.die = pkt:GetChar()
end

function MsgParser:MSG_LC_FLEE(pkt, data)
	self:MSG_C_FLEE(pkt, data)
end

function MsgParser:MSG_C_MANA_DELTA(pkt, data)
    data.id = pkt:GetLong()
    data.hitter_id = pkt:GetLong()
    data.point = pkt:GetLong()
    data.effect_no = pkt:GetLong()
end

function MsgParser:MSG_LC_MANA_DELTA(pkt, data)
	self:MSG_C_MANA_DELTA(pkt, data)
end

function MsgParser:MSG_C_CHAR_REVIVE(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_LC_CHAR_REVIVE(pkt, data)
    self:MSG_C_CHAR_REVIVE(pkt, data)
end

function MsgParser:MSG_C_CATCH_PET(pkt, data)
    data.id = pkt:GetLong()
    data.monster_id = pkt:GetLong()
    data.success = pkt:GetChar()
end

function MsgParser:MSG_LC_CATCH_PET(pkt, data)
	self:MSG_C_CATCH_PET(pkt, data)
end

function MsgParser:MSG_C_ADD_FRIEND(pkt, data)
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count, 1 do
        local map = {}
        map.id = pkt:GetLong()
        map.leader = pkt:GetShort()
        map.weapon_icon = pkt:GetShort()
        map.pos = pkt:GetShort()
        map.rank = pkt:GetShort()
        map.vip_type = pkt:GetShort()
        Builders:BuildFields(pkt, map)
        map.org_icon = pkt:GetShort()
        map.suit_icon = pkt:GetLong()
        map.suit_light_effect = pkt:GetLong()
        map.special_icon = pkt:GetLong()
        data[i] = map
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local customIcon = pkt:GetLenString()
            local char = data[i]
            if not string.isNilOrEmpty(customIcon) then
                char.part_index, char.part_color_index = string.match(customIcon, "(.+):(.+)")
            else
                char.part_index, char.part_color_index = "", ""
            end
        end
    end

    if pkt:GetDataLen() > count * 4 then
        for i = 1, count do
            local char = data[i]
            char.effectIcons = {}
            local size = pkt:GetChar()
            for j = 1, size do
                table.insert(char.effectIcons, pkt:GetLong())
            end
        end
    end

    for i = 1, count, 1 do
        data[i].actioner_id = pkt:GetLong()
    end
end

function MsgParser:MSG_LC_ADD_FRIEND(pkt, data)
	self:MSG_C_ADD_FRIEND(pkt, data)
end

function MsgParser:MSG_C_ADD_OPPONENT(pkt, data)
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count, 1 do
        local map = {}
        map.id = pkt:GetLong()
        map.leader = pkt:GetShort()
        map.weapon_icon = pkt:GetShort()
        map.pos = pkt:GetShort()
        map.rank = pkt:GetShort()
        map.vip_type = pkt:GetShort()
        Builders:BuildFields(pkt, map)
        map.org_icon = pkt:GetShort()
        map.suit_icon = pkt:GetLong()
        map.suit_light_effect = pkt:GetLong()
        map.special_icon = pkt:GetLong()
        data[i] = map
    end

    if pkt:GetDataLen() > 1 then
        for i = 1, count do
            local customIcon = pkt:GetLenString()
            local char = data[i]
            if not string.isNilOrEmpty(customIcon) then
                char.part_index, char.part_color_index = string.match(customIcon, "(.+):(.+)")
            else
                char.part_index, char.part_color_index = "", ""
            end
        end
    end

    if pkt:GetDataLen() > count * 4 then
        for i = 1, count do
            local char = data[i]
            char.effectIcons = {}
            local size = pkt:GetChar()
            for j = 1, size do
                table.insert(char.effectIcons, pkt:GetLong())
            end
        end
    end

    for i = 1, count, 1 do
        data[i].actioner_id = pkt:GetLong()
    end
end

function MsgParser:MSG_LC_ADD_OPPONENT(pkt, data)
	self:MSG_C_ADD_OPPONENT(pkt, data)
end

function MsgParser:MSG_C_UPDATE_STATUS(pkt, data)
    data.id = pkt:GetLong()
    data.s_num = pkt:GetShort()
    for i = 1, data.s_num do
        data['s' .. i] = pkt:GetLong()
    end
end

function MsgParser:MSG_LC_UPDATE_STATUS(pkt, data)
	self:MSG_C_UPDATE_STATUS(pkt, data)
end

function MsgParser:MSG_C_ACCEPT_MAGIC_HIT(pkt, data)
    local hitterId = pkt:GetLong()
    local damageType = pkt:GetLong()
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local map = {}
        map.hitter_id = hitterId
        map.damage_type = damageType
        map.id = pkt:GetLong()
        map.missed = 1
        data[i] = map
    end

    for i = 1, count, 1 do ----todo
        if pkt:GetDataLen() > 0 then
            data[i].missed = pkt:GetShort()
        end
    end
end

function MsgParser:MSG_LC_ACCEPT_MAGIC_HIT(pkt, data)
	self:MSG_C_ACCEPT_MAGIC_HIT(pkt, data)
end

function MsgParser:MSG_C_UPDATE_IMPROVEMENT(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_LC_UPDATE_IMPROVEMENT(pkt, data)
	self:MSG_C_UPDATE_IMPROVEMENT(pkt, data)
end

function MsgParser:MSG_C_MENU_SELECTED(pkt, data)
    data.id = pkt:GetLong()
    data.menu_item = pkt:GetLenString()
end

function MsgParser:MSG_LC_MENU_SELECTED(pkt, data)
	self:MSG_C_MENU_SELECTED(pkt, data)
end

function MsgParser:MSG_C_DELAY(pkt, data)
    data.id = pkt:GetLong()
    data.delay_time = pkt:GetLong()
end

function MsgParser:MSG_LC_DELAY(pkt, data)
	self:MSG_C_DELAY(pkt, data)
end

function MsgParser:MSG_C_LIGHT_EFFECT(pkt, data)
    data.id = pkt:GetLong()
    data.no = pkt:GetLong()
    data.owner_id = pkt:GetLong()
end

function MsgParser:MSG_LC_LIGHT_EFFECT(pkt, data)
	self:MSG_C_LIGHT_EFFECT(pkt, data)
end

function MsgParser:MSG_C_START_SEQUENCE(pkt, data)
    data.id = pkt:GetLong()
    data.para = pkt:GetLong()
end

function MsgParser:MSG_LC_START_SEQUENCE(pkt, data)
	self:MSG_C_START_SEQUENCE(pkt, data)
end

function MsgParser:MSG_LC_CUR_ROUND(pkt, data)
    self:MSG_C_CUR_ROUND(pkt, data)
end

function MsgParser:MSG_C_OPPONENT_INFO(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local map = {}
        map.count = count
        map.id = pkt:GetLong()
        Builders:BuildFields(pkt, map)
        data[i] = map
    end
end

function MsgParser:MSG_C_DIRECT_OPPONENT_INFO(pkt, data)
    self:MSG_C_OPPONENT_INFO(pkt, data)
end

function MsgParser:MSG_C_DIALOG_OK(pkt, data)
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_C_MESSAGE(pkt, data)
    data.channel = pkt:GetShort()
    data.name = pkt:GetLenString()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_C_ACCEPTED_COMMAND(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_C_LEAVE_AT_ONCE(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_LC_LEAVE_AT_ONCE(pkt, data)
    self:MSG_C_LEAVE_AT_ONCE(pkt, data)
end

function MsgParser:MSG_C_COMMAND_ACCEPTED(pkt, data)
    data.id = pkt:GetLong()
    data.result = pkt:GetShort()
end

function MsgParser:MSG_C_REFRESH_PET_LIST(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count, 1 do
        local map = {}
        map.id = pkt:GetLong()
        map.haveCalled = pkt:GetChar()
        data[i] = map
    end
end

function MsgParser:MSG_C_SANDGLASS(pkt, data)
    data.id = pkt:GetLong()
    data.show = pkt:GetShort()
end

function MsgParser:MSG_LC_SANDGLASS(pkt, data)
    self:MSG_C_SANDGLASS(pkt, data)
end

function MsgParser:MSG_C_CHAR_OFFLINE(pkt, data)
    data.id = pkt:GetLong()
    data.offline = pkt:GetShort()
end

function MsgParser:MSG_LC_CHAR_OFFLINE(pkt, data)
    self:MSG_C_CHAR_OFFLINE(pkt, data)
end

function MsgParser:MSG_C_ACCEPT_MULTI_HIT(pkt, data)
    -- 获取攻击者ID
    local hitterId = pkt:GetLong()

    -- 获取主要受击者id
    local mainVictimId = pkt:GetLong()

    -- 获取伤害类型
    local damageType = pkt:GetLong()

    -- 获取数量
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local tmp = {}
        data[i] = tmp
        tmp.hitter_id = hitterId
        tmp.main_victim_id = mainVictimId
        tmp.damage_type = damageType
        tmp.victim_count = count
        tmp.id = pkt:GetLong()
        tmp.missed = pkt:GetShort()
    end
end

function MsgParser:MSG_C_MENU_LIST(pkt, data)
    data.id = pkt:GetLong()
    data.portrait = pkt:GetShort()
    data.pic_no = pkt:GetShort()
    data.content = pkt:GetLenString2()

    --- cyq todo 确认是否需要 BuildImageInfo
end

function MsgParser:MSG_LC_MENU_LIST(pkt, data)
	self:MSG_C_MENU_LIST(pkt, data)
end

function MsgParser:MSG_PICTURE_DIALOG(pkt, data)
    data.id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.portrait = pkt:GetShort()
    data.pic_no = pkt:GetShort()
    data.content = pkt:GetLenString2()

    --- cyq todo 确认是否需要 BuildImageInfo
end

function MsgParser:MSG_ATTACH_SKILL_LIGHT_EFFECT(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetShort()
    data.type = pkt:GetLong()

    if pkt:GetDataLen() > 0 then
        data.name = pkt:GetLenString()
    end

    if pkt:GetDataLen() > 0 then
        if pkt:GetChar() == 1 then
            data.blendMode = 'add'
        end
    end
end

function MsgParser:MSG_C_BATTLE_ARRAY(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        -- 组织阵法信息
        local map = {}
        map.magic_count = pkt:GetShort()
        for k = 1, map.magic_count do
            map['magic_icon' .. k] = pkt:GetShort()
        end

        map.obj_count = pkt:GetShort()
        for j = 1, map.obj_count do
            map['id' .. j] = pkt:GetLong()
        end
    end
end

function MsgParser:MSG_C_SET_FIGHT_PET(pkt, data)
    data.id = pkt:GetLong()
    data.pet_status = pkt:GetShort()
end

function MsgParser:MSG_C_SET_CUSTOM_MSG(pkt, data)
    data.id = pkt:GetLong()
    data.channel = pkt:GetShort()
    data.server_name = pkt:GetLenString()
    data.msg = pkt:GetLenString()
    data.show_time = pkt:GetChar()
    data.vip_type = pkt:GetChar()
end

function MsgParser:MSG_NULL(pkt, data)
end

function MsgParser:MSG_MOVED(pkt, data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = adjustDir(pkt:GetChar())
end

function MsgParser:MSG_APPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = adjustDir(pkt:GetShort())
    data.icon = pkt:GetLong()
    data.weapon_icon = pkt:GetLong()
    data.type = pkt:GetShort()
    data.sub_type = pkt:GetLong()
    data.owner_id = pkt:GetLong()
    data.leader_id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
    data.title = pkt:GetLenString()
    data.family = pkt:GetLenString()
    data.party = pkt:GetLenString()
    data.status = pkt:GetLong()
    data.special_icon = pkt:GetLong()
    data.org_icon = pkt:GetLong()
    data.suit_icon = pkt:GetLong()
    data.suit_light_effect = pkt:GetLong()
    data.guard_icon = pkt:GetLong()
    data.pet_icon = pkt:GetLong()
    data.shadow_icon = pkt:GetLong()
    data.shelter_icon = pkt:GetLong()
    data.mount_icon = pkt:GetLong()
    data.alicename = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.camp = pkt:GetLenString()
    data.vip_type = pkt:GetChar()
    data.isHide = pkt:GetChar()
    data.moveSpeedPercent = pkt:GetSignedChar()
    data["ct_data/score"] = pkt:GetSignedLong()
    data.opacity = pkt:GetChar()
    data.masquerade = pkt:GetLong()
    data["upgrade/state"] = pkt:GetChar()
    data["upgrade/type"] = pkt:GetChar()
    data["obstacle"] = pkt:GetChar()
    data.light_effect_count = pkt:GetShort()
    data.light_effect = {}
    for i = 1, data.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.light_effect, effect)
    end
    if pkt:GetDataLen() >= 4 then
        data.share_mount_icon = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.share_mount_leader_id = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 4 then
        data.share_mount_shadow = pkt:GetLong()
    end
    if pkt:GetDataLen() >= 2 then
        data.gather_count = math.max(pkt:GetShort() - 1, 0)
    data.gather_icons = {}
    if pkt:GetDataLen() >= 4 * data.gather_count then
        if data.gather_count >= 1 then                          -- 存在乘客
            data.mount_icon = pkt:GetLong()                     -- 第一位是司机
            for i = 1, data.gather_count do
                table.insert(data.gather_icons, pkt:GetLong())  -- 乘客
            end
        end
    end
        if pkt:GetDataLen() >= 2 then
            data.gather_name_num = pkt:GetShort()
    end
    data.gather_names = {}
    if pkt:GetDataLen() > 0 then
        for i = 1, data.gather_name_num do
            table.insert(data.gather_names, pkt:GetLenString())
        end
    end
    end

    if pkt:GetDataLen() >= 4 then
        data.portrait = pkt:GetLong()
    end

    if pkt:GetDataLen() >= 1 then
        local customIcon = pkt:GetLenString()
        if not string.isNilOrEmpty(customIcon) then
            data.part_index, data.part_color_index = string.match(customIcon, "(.+):(.+)")
        else
            data.part_index, data.part_color_index = "", ""
        end
    end
end

function MsgParser:MSG_DISAPPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.type = pkt:GetShort()
end

function MsgParser:MSG_GODBOOK_EFFECT_NORMAL(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetShort()
end

function MsgParser:MSG_GODBOOK_EFFECT_SUMMON(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetShort()
end

function MsgParser:MSG_EXITS(pkt, data)
    local add_exit = pkt:GetChar()
    local count = pkt:GetShort()
    data.count = count

    for i = 1, count do
        local exit = {}
        exit.add_exit = add_exit
        exit.room_name = pkt:GetLenString()
        exit.x = pkt:GetShort()
        exit.y = pkt:GetShort()
        exit.dir = pkt:GetShort()
        data[i] = exit
    end
end

function MsgParser:MSG_NO_PACKET(pkt, data)
end

function MsgParser:MSG_UPDATE_PETS(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local tmp = {}
        data[i] = tmp
        tmp.no = pkt:GetChar()
        tmp.id = pkt:GetLong()
        Builders:BuildPetInfo(pkt, tmp)
    end
end

function MsgParser:MSG_SET_VISIBLE_PET(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_SET_CURRENT_PET(pkt, data)
    data.id = pkt:GetLong()
    data.pet_status = pkt:GetShort()
end

function MsgParser:MSG_SET_OWNER(pkt, data)
    data.id = pkt:GetLong()
    data.owner_id = pkt:GetLong()
end

function MsgParser:MSG_GUARDS_REFRESH(pkt, data)
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local info = {}
        info.id = pkt:GetLong()
        Builders:BuildPetInfo(pkt, info)
        data[i] = info
    end
end

function MsgParser:MSG_GUARD_UPDATE_EQUIP(pkt, data)
    data.id = pkt:GetLong()
    local count = pkt:GetChar()
    for i = 1, count do
        local info = {}
        info.equip_type = pkt:GetLenString()
        Builders:BuildFields(pkt, info)
        data[info.equip_type] = info
    end
end

function MsgParser:MSG_GUARD_UPDATE_GROW_ATTRIB(pkt, data)
    local info = {}
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, info)
    data['grow_attrib'] = info

    if data['grow_attrib'] and data['grow_attrib']["degree_32"] then
        data['grow_attrib']["degree_32"] = math.floor(data['grow_attrib']["degree_32"] / 100) *100 / 1000000
    end
end

function MsgParser:MSG_SET_CURRENT_MOUNT(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_APPELLATION_LIST(pkt, data)
    local count = pkt:GetShort()
    data.title_num = count
    for i = 1, count do
        data[string.format("type%d", i)] = pkt:GetLenString()
        data[string.format("title%d", i)] = pkt:GetLenString()
        data[string.format("title%d_left_time", i)] = pkt:GetLong()
    end
end

function MsgParser:MSG_TASK_PROMPT(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local task = {}
        task.task_type = pkt:GetLenString()
        task.task_desc = pkt:GetLenString2()
        task.task_prompt = pkt:GetLenString2()
        task.refresh = pkt:GetShort()
        task.task_end_time = pkt:GetLong()
        task.attrib = pkt:GetShort()
        task.reward = pkt:GetLenString2()
        task.show_name = pkt:GetLenString()
        if "" == task.show_name then
            task.show_name = task.task_type
        end
        task.task_extra_para = pkt:GetLenString()
        task.task_state = pkt:GetLenString()

        data[i] = task
    end
end

function MsgParser:MSG_UPDATE_TEAM_LIST(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local member = {}
        member.id = pkt:GetLong()
        member.gid = pkt:GetLenString()
        member.suit_icon = pkt:GetLong()
        member.weapon_icon = pkt:GetShort()
        member.org_icon = pkt:GetShort()
        Builders:BuildFields(pkt, member)
        member.card_name = pkt:GetLenString()
        member.light_effect_count = pkt:GetChar()
        member.light_effect = {}
        for i = 1, member.light_effect_count do
            local effect = pkt:GetLong()
            table.insert(member.light_effect, effect)
        end
        data[i] = member
    end
end

function MsgParser:MSG_UPDATE_TEAM_LIST_EX(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local member = {}
        member.id = pkt:GetLong()
        member.gid = pkt:GetLenString()
        member.suit_icon = pkt:GetLong()
        member.weapon_icon = pkt:GetShort()
        member.org_icon = pkt:GetShort()
        Builders:BuildFields(pkt, member)
        member.pos_x = pkt:GetShort()
        member.pos_y = pkt:GetShort()
        member.map_id = pkt:GetLong()
        member.team_status = pkt:GetChar()
        member.card_name = pkt:GetLenString()
        member.comeback_flag = pkt:GetChar() -- 回归标记
        member.light_effect_count = pkt:GetChar()
        member.light_effect = {}
        for i = 1, member.light_effect_count do
            local effect = pkt:GetLong()
            table.insert(member.light_effect, effect)
        end
        data[i] = member
    end
end

function MsgParser:MSG_DIALOG(pkt, data)

    data.caption = pkt:GetLenString()
    data.content = pkt:GetLenString()
    data.peer_name = pkt:GetLenString()
    data.ask_type = pkt:GetLenString()
    local count = pkt:GetShort()
    data.count = count
    -- data.captionGid = pkt:GetLenString()
    for i = 1, count do
        local map = {}
        map.org_icon = pkt:GetLong()
        Builders:BuildFields(pkt, map)
        data[i] = map
        data[i].teamMembersCount = pkt:GetChar()
        data[i].comeback_flag = pkt:GetChar()   -- 回归标记
        if data.ask_type == "csc_around_player" or data.ask_type == "csc_around_team" then
            -- 跨服战场要显示的段位、战斗模式
            data[i].stageStr = pkt:GetLenString()
            data[i].combat_mode = pkt:GetLenString()
        end
    end

    if data[1] then data.captionGid = data[1].gid end

    if pkt:GetDataLen() > 0 then
        data.flag = pkt:GetChar()
    end
end

function MsgParser:MSG_CLEAN_REQUEST(pkt, data)
    data.ask_type = pkt:GetLenString()
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        data[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_SERVICE_LOG(pkt, data)
    data.task_type = pkt:GetLenString()
    data.task_desc = pkt:GetLenString()
    data.task_prompt = pkt:GetLenString()
    data.refresh = pkt:GetShort()
    data.attrib = pkt:GetShort()
end

function MsgParser:MSG_LC_INIT_STATUS(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local info = {}
        info.id = pkt:GetLong()

        info.s_num = pkt:GetShort()
        for i = 1, info.s_num do
            info['s' .. i] = pkt:GetLong()
        end

        info.die = pkt:GetShort()
        data[i] = info
    end
end

function MsgParser:MSG_TELEPORT_EX(pkt, data)
    data.type = pkt:GetShort()
    data.tip = pkt:GetLenString()
    data.id = pkt:GetLong()
end

function MsgParser:MSG_TOP_USER(pkt, data)
    data.type = pkt:GetShort()
    data.cookie = pkt:GetLong()
    data.count = pkt:GetShort()
    data.requestType = pkt:GetChar()

    if 2 == data.requestType then
        -- 如果是根据等级获取的话，那么就有两个字段标志范围
        data.minLevel = pkt:GetShort()
        data.maxLevel = pkt:GetShort()
    end

    for i = 1, data.count do
        local info = {}
        Builders:BuildFields(pkt, info)
        data[i] = info
    end
end

function MsgParser:MSG_RANK_CLIENT_INFO(pkt, data)
    local info = {}
    Builders:BuildFields(pkt, info)
    data.info = info
end

function MsgParser:MSG_GUARD_CARD(pkt, data)
    local Guard = {}
    Guard.raw_name = pkt:GetLenString()
    Builders:BuildPetInfo(pkt, Guard)
    data.cardInfo = Guard

    local equipment = {}
    local count = pkt:GetChar()
    for i = 1, count do
        local info = {}
        info.equip_type = pkt:GetLenString()
        Builders:BuildFields(pkt, info)
        equipment[info.equip_type] = info
    end

    data.cardInfo["weapon"] = equipment["weapon"]
    data.cardInfo["helmet"] = equipment["helmet"]
    data.cardInfo["armor"]  = equipment["armor"]
    data.cardInfo["boot"]   = equipment["boot"]

    local atttrib = {}
    Builders:BuildFields(pkt, atttrib)
    atttrib['grow_attrib'] = atttrib
    data.cardInfo["develop_con"] = atttrib['grow_attrib']["con"] or 0
    data.cardInfo["develop_str"] = atttrib['grow_attrib']["str"] or 0
    data.cardInfo["develop_wiz"] = atttrib['grow_attrib']["wiz"] or 0
    data.cardInfo["develop_dex"] = atttrib['grow_attrib']["dex"] or 0
end

function MsgParser:MSG_EQUIP_CARD(pkt, data)
    data.cardInfo = {}
    data.cardInfo.pos = pkt:GetChar()
    Builders:BuildItemInfo(pkt, data.cardInfo)
end

function MsgParser:MSG_PRE_ASSIGN_ATTRIB(pkt,data)
    data.id = pkt:GetLong()
    data.type = pkt:GetLong()
    data.life_plus = pkt:GetSignedLong()
    data.max_life_plus = pkt:GetSignedLong()
    data.mana_plus = pkt:GetSignedLong()
    data.max_mana_plus = pkt:GetSignedLong()
    data.phy_power_plus = pkt:GetSignedLong()
    data.mag_power_plus = pkt:GetSignedLong()
    data.speed_plus = pkt:GetSignedLong()
    data.def_plus = pkt:GetSignedLong()
    data.free = pkt:GetChar()
end

function MsgParser:MSG_SEND_RECOMMEND_ATTRIB(pkt, data)
    data.id = pkt:GetLong()
    data.con = pkt:GetChar()
    data.wiz = pkt:GetChar()
    data.str = pkt:GetChar()
    data.dex = pkt:GetChar()
    data.auto_add = pkt:GetChar()
    data.plan = pkt:GetChar()
end

function MsgParser:MSG_REFRESH_PET_GODBOOK_SKILLS(pkt, data)
    data.owner_id = pkt:GetLong()
    data.id = pkt:GetLong()

    local count = pkt:GetShort()
    data.god_book_skill_count = count
    for i = 1, count do
        data["god_book_skill_name_"..i] = pkt:GetLenString()
        data["god_book_skill_level_"..i] = pkt:GetShort()
        data["god_book_skill_power_"..i] = pkt:GetShort()
        data["god_book_skill_disabled_" .. i] = pkt:GetChar()
    end
end

function MsgParser:MSG_FINISH_SORT_PACK(pkt, data)
    data.start_range = pkt:GetChar()
end

function MsgParser:MSG_TEAM_MOVED(pkt,data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.map_id = pkt:GetLong()
end

function MsgParser:MSG_SEND_RECOMMEND_POLAR(pkt, data)
    data.id = pkt:GetLong()
    data.para1 = pkt:GetChar()
    data.para2 = pkt:GetChar()
    data.para3 = pkt:GetChar()
    data.para4 = pkt:GetChar()
    data.para5 = pkt:GetChar()
    data.auto_add = pkt:GetChar()
    data.plan = pkt:GetChar()
end

function MsgParser:MSG_PRE_UPGRADE_EQUIP(pkt, data)
    data.pos = pkt:GetChar()
    data.upgrade_type = pkt:GetChar()
    Builders:BuildItemInfo(pkt, data)
    local ss
end

function MsgParser:MSG_UPGRADE_EQUIP_COST(pkt, data)
    data.pos = pkt:GetChar()
    data.upgrade_type = pkt:GetChar()
    data.cash = pkt:GetLong()
    data.num1 = pkt:GetShort()
    data.num2 = pkt:GetShort()
end

function MsgParser:MSG_IDENTIFY_INFO(pkt, data)
    data.time1 = pkt:GetLong()
    data.left1 = pkt:GetChar()
    data.time2 = pkt:GetLong()
end

function MsgParser:MSG_GENERAL_NOTIFY(pkt, data)
    data.notify = pkt:GetShort()
    data.para = pkt:GetLenString()
end

function MsgParser:MSG_GOODS_LIST(pkt, data)
    data.shipper = pkt:GetLong()
    data.shopType = pkt:GetShort()   -- 0为药店   1为杂货店
    data.pk_add = pkt:GetShort()
    data.discount = pkt:GetShort()
    data.server_type = pkt:GetShort()
    data.count = pkt:GetShort()

    local goods = {}
    for i = 1, data.count do
        local goods_no = pkt:GetShort()
        local pay_type = pkt:GetLong()
        local itemCount = pkt:GetShort()
        local name = pkt:GetLenString()
        local value = pkt:GetLong()
        local level = pkt:GetShort()
        local type = pkt:GetChar()  -- 商品分类，未分类时为 0
        table.insert(goods, {goods_no = goods_no, pay_type = pay_type, name = name, value = value, level = level, type = type})
    end
    data.goods = goods

    data.tax = pkt:GetShort()
end

function MsgParser:MSG_ITEM_APPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = pkt:GetShort()
    data.icon = pkt:GetShort()
    data.type = pkt:GetShort()
    data.amount = pkt:GetShort()
    data.name = pkt:GetLenString()

    if pkt:GetDataLen() <= 0 then
        return
    end

    data.item_type = pkt:GetShort()

    if pkt:GetDataLen() > 0 then
        Builders:BuildFields(pkt, data)
    end
end

function MsgParser:MSG_ITEM_DISAPPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.type = pkt:GetShort()
end

function MsgParser:MSG_FRIEND_UPDATE_LISTS(pkt, data)
    local groupCount = pkt:GetShort()
    data.char_count = 0
    for i = 1, groupCount do
        local group = pkt:GetLenString()
        local charCount = pkt:GetShort()
        data.char_count = data.char_count + charCount
        for j = 1, charCount do
            local info = {}
            info.group_count = groupCount
            info.group = group
            local charBuf = pkt:GetLenString()
            local blockedFlag = pkt:GetChar()
            local onlineFlag = pkt:GetChar()
            local serverBuf = pkt:GetLenString()
            info.server_name = serverBuf
            info.insider_level = pkt:GetChar()
            Builders:BuildFields(pkt, info)
            info.blocked = blockedFlag
            info.online = onlineFlag
            info.char = charBuf
            table.insert(data, info)
        end
    end
end

function MsgParser:MSG_FRIEND_ADD_CHAR(pkt, data)
    local count = pkt:GetShort()
    if count <= 0 then return end

    data.count = count
    for i = 1, count do
        local groupBuf = pkt:GetLenString()
        local charBuf = pkt:GetLenString()
        local info = {}
        info.char_count = count
        info.group = groupBuf
        info.char = charBuf
        info.blocked = pkt:GetChar()
        info.online = pkt:GetChar()
        info.server_name = pkt:GetLenString()
        info.insider_level = pkt:GetChar()
        Builders:BuildFields(pkt, info)
        data[i] = info
    end
end

function MsgParser:MSG_FRIEND_REMOVE_CHAR(pkt, data)
    local count = pkt:GetShort()
    if count <= 0 then return end

    for i = 1, count do
        local groupBuf = pkt:GetLenString()
        local charBuf = pkt:GetLenString()
        data.count = count
        data.group = groupBuf
        data.char = charBuf
        data.gid = pkt:GetLenString()
    end
end

function MsgParser:MSG_FRIEND_NOTIFICATION(pkt, data)
    local charBuf = pkt:GetLenString()
    local serverName = pkt:GetLenString()
    data.char = charBuf
    data.server_name = serverName
    data.para = pkt:GetShort()
    data.insider_level = pkt:GetChar()
end

function MsgParser:MSG_FRIEND_UPDATE_PARTIAL(pkt, data)
    data.update_type = pkt:GetShort()  -- 2 表示只刷新不创建
    local groupBuf = pkt:GetLenString()
    local charBuf = pkt:GetLenString()
    data.group = groupBuf
    data.char = charBuf
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_FINGER(pkt, data)
    local count  = pkt:GetChar()
    data.count = count
    for i = 1, count do
        local info = {}
        Builders:BuildFields(pkt, info)
        data[i] = info
    end
end

-- 获得物品动画
function MsgParser:MSG_ICON_CARTOON(pkt, data)
    data.type = pkt:GetShort()
    data.name = pkt:GetLenString()
    data.param = pkt:GetLenString()
    data.rightNow = pkt:GetShort()
end

-- 帮派信息
function MsgParser:MSG_PARTY_INFO(pkt, data)
    data.partyId = pkt:GetLenString()           -- 帮派ID
    data.partyName = pkt:GetLenString()         -- 帮派名称
    data.partyBaseInfo = pkt:GetLenString()     -- 基本信息
    data.partyAnnounce = pkt:GetLenString2()    --
    data.rights = pkt:GetShort()
    data.construct = pkt:GetLong()
    data.money = pkt:GetLong()
    data.createTime = pkt:GetLong()
    data.salary = pkt:GetLong()
    -- autoAcceptLevel   xxxx yyyy z   z表示开关状态，x最小等级，y最大等级
    -- reject_switch开关

    data.autoAcceptLevel = pkt:GetLong()
    data.reject_switch = data.autoAcceptLevel % 10
    data.autoMaxLevel = math.floor(data.autoAcceptLevel / 10) % 1000
    data.autoMinLevel = math.floor(data.autoAcceptLevel / 100000) % 1000

    data.creator = pkt:GetLenString()

    -- 帮派技能
    data.skillCount = pkt:GetShort()            -- 技能个数
    data.skill = {}
    for i = 1,data.skillCount do
        table.insert(data.skill, {
            name = pkt:GetLenString(),
            no = pkt:GetShort(),
            level = pkt:GetShort(),
            currentScore = pkt:GetLong(),
            levelupScore = pkt:GetLong()})
    end

    data.population = pkt:GetShort()
    data.onLineCount = pkt:GetShort()
    data.partyLevel = pkt:GetShort()
    data.partyMap = pkt:GetShort()
    data.heir = pkt:GetLenString()
    -- data.qqlOpenType = pkt:GetShort()
    -- data.qqlOpenToday = pkt:GetShort()
    -- data.qqlLine = pkt:GetShort()
    -- data.qqlAutoStartTime = pkt:GetLenString()
    data.lastAutoJoinTime = pkt:GetLong()

    data.icon_md5 = pkt:GetLenString()
    data.review_icon_md5 = pkt:GetLenString()

    -- 领导
    data.leaderCount = pkt:GetShort()
    data.leader = {}
    for i = 1,data.leaderCount do
        table.insert(data.leader, {
            job = pkt:GetLenString(),
            name = pkt:GetLenString(),})
    end
end

-- 帮派智多星 - 技能信息
function MsgParser:MSG_PARTY_ZHIDUOXING_SKILL(pkt, data)
    if pkt:GetDataLen() > 0 then
        data.start_time = pkt:GetLong()  --
        data.end_time = pkt:GetLong()  --
        data.help_level = pkt:GetChar()   -- 求助等级，取值为 0（不开放）, 1（初级）, 2（中级）, 3（高级）
        data.dizhijuan = pkt:GetChar()    -- 地之卷剩余使用次数
    	data.renzhijuan = pkt:GetChar()   -- 人之卷剩余使用次数
    	data.tianzhijuan = pkt:GetChar()  -- 天之卷剩余使用次数
    end
end

-- 帮派智多星 - 基本信息
function MsgParser:MSG_PARTY_ZHIDUOXING_INFO(pkt, data)
    data.openToday = pkt:GetChar()   -- 状态
    data.auto = pkt:GetChar()    -- 自动开启标记
	data.select_id = pkt:GetChar()   -- 开启线路
	data.start_time = pkt:GetLenString()  -- 开启时间
    data.hard_level = pkt:GetChar()  -- 问题难度  0 = 未配置， 1 = 简单难度， 2 = 普通难度， 3 = 困难难度
    data.help_level = pkt:GetChar()  -- 求助等级 0 = 未开放， 1 = 低级求助， 2 = 中级求助， 3 = 高级求助
end

-- 帮派智多星 - 显示题目
function MsgParser:MSG_PARTY_ZHIDUOXING_QUESTION(pkt, data)
    data.start_time = pkt:GetLong()   -- 状态
    data.end_time = pkt:GetLong()    -- 自动开启标记
    data.duration = pkt:GetChar()   -- 显示时间间隔
    data.message = pkt:GetLenString()  -- 显示题目
end

-- 培育巨兽活动开启信息
function MsgParser:MSG_PARTY_PYJS_SETUP(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
end

-- 选择的培育巨兽属性数据
function MsgParser:MSG_PARTY_PYJS_ATTRIBS(pkt, data)
    data.stage = pkt:GetChar()           -- 阶段编号
    data.choose_end_time = pkt:GetLong() -- 选择截止时间
    data.stage_end_time = pkt:GetLong()  -- 阶段截止时间
    data.grow_value = pkt:GetShort()      -- 成长值
    data.grow_percent = pkt:GetShort()    -- 成长度
    data.breeds = {}
    for i = 1, 5 do
        -- 各个属性的培育次数，依次为 气血、物伤、法伤、速度、道行
        data.breeds[i] = pkt:GetChar()
    end

    data.chooseAttris = {}
    for i = 1, 3 do
        -- 随机可选择配需的三个属性  气血：life，物攻：phy_power，法攻：mag_power，速度：speed，道行：tao
        data.chooseAttris[i] = pkt:GetLenString()
    end
end

-- 培育巨兽数据
function MsgParser:MSG_PARTY_PYJS_STAGE_DATA(pkt, data)
    data.stage = pkt:GetChar()           -- 阶段编号
    data.stage_end_time = pkt:GetLong()  -- 阶段截止时间
    data.grow_value = pkt:GetShort()      -- 成长度
    data.grow_percent = pkt:GetShort()    -- 成长度百分比
    data.breeds = {}
    for i = 1, 5 do
        -- 各个属性的培育次数
        data.breeds[i] = pkt:GetChar()
    end

    data.can_add_value = pkt:GetShort()   -- 完成后可增加的成长度
    data.contribution = pkt:GetShort()    -- 本阶段贡献
    data.chooseAttri = pkt:GetLenString() -- 选择培育的属性
    data.isOpen = pkt:GetChar()    -- 是否打开界面
    data.tasks = {}
    data.count = pkt:GetChar()
    for i = 1, data.count do
        -- 随机可选择配需的三个属性
        local info = {}
        info.name = pkt:GetLenString() -- 任务名
        info.com_count = pkt:GetShort()    -- 已完成次数
        info.total_count = pkt:GetShort()  -- 总的任务次数
        info.status = pkt:GetChar()    -- 当前角色完成状态 （0：未领取；1：已领取；2：已完成）
        table.insert(data.tasks, info)
    end
end

-- 运气测试结果
function MsgParser:MSG_PARTY_YQCS_RESULT(pkt, data)
    data.icon = pkt:GetLong()
    data.myPoint = pkt:GetSignedChar() -- 我的点数
    data.sysPoint = pkt:GetSignedChar() -- 系统的点数   -1：游戏终止；0：未出结果；大于0：已有结果
end

-- 益智训练（戳泡泡）结果
function MsgParser:MSG_PARTY_YZXL_POKE(pkt, data)
    data.gid = pkt:GetLenString()     -- 戳破的泡泡 gid
    data.type = pkt:GetChar()         -- 戳破的泡泡类型
    data.score = pkt:GetChar()        -- 增加的积分
    data.new_gid = pkt:GetLenString() -- 新泡泡的 gid
    data.new_type = pkt:GetChar()     -- 新泡泡的类型
    data.batter_count = pkt:GetChar() -- 连击次数，1次不算连击
    data.blue_score = pkt:GetLong()   -- 蓝泡泡积分
    data.purple_score = pkt:GetLong() -- 紫泡泡积分
    data.gold_score = pkt:GetLong()   -- 金泡泡积分
end

-- 游戏结束
function MsgParser:MSG_PARTY_YZXL_END(pkt, data)
    -- data.star = pkt:GetSignedChar()
    -- data.highest_score = pkt:GetLong()
    data.blue_score = pkt:GetLong()
    data.purple_score = pkt:GetLong()
    data.gold_score = pkt:GetLong()
    -- data.exp = pkt:GetLong()
    -- data.tao = pkt:GetLong()
    -- data.item = pkt:GetLenString()
    data.result = pkt:GetSignedChar() -- 1：挑战成功；0：挑战失败；-1：挑战终止
end

-- 开始戳泡泡游戏
function MsgParser:MSG_PARTY_YZXL_START(pkt, data)
    data.game_time = pkt:GetChar() -- 游戏时间
    data.ready_time = pkt:GetChar() -- 预备时间
    data.count = pkt:GetChar()  -- 泡泡数量
    data.bubbles = {}
    for i = 1, data.count do
        table.insert(data.bubbles, { gid = pkt:GetLenString(), type = pkt:GetChar() })
    end
end

-- 暂停/退出
function MsgParser:MSG_PARTY_YZXL_QUIT(pkt, data)
    data.type = pkt:GetLenString() -- request：暂停、cancel：取消退出、confirm：确认
    data.left_time = pkt:GetChar() -- 剩余时间
end

function MsgParser:MSG_PARTY_YZXL_REMOVE(pkt, data)
    data.gid = pkt:GetLenString()     -- 飘走的泡泡 gid
    data.new_gid = pkt:GetLenString() -- 新泡泡 gid
    data.type = pkt:GetChar()         -- 新泡泡 类型
end

function MsgParser:MSG_PARTY_MEMBERS(pkt, data)
    data.page = pkt:GetShort()
    data.tail = pkt:GetShort()
    data.count = pkt:GetShort()
    data.members = {}
    data.online = 0
    for i = 1,data.count do
        table.insert(data.members, {
            gid = pkt:GetLenString(),
            name = pkt:GetLenString(),
            online = pkt:GetShort(),
            portrait = pkt:GetShort(),
            job = pkt:GetLenString(),
            level = pkt:GetShort(),
            family = pkt:GetLenString(),
            contrib = pkt:GetLong(),
            active = pkt:GetLong(),
            polor = pkt:GetShort(),
            gender = pkt:GetShort(),
            lastWeekActive = pkt:GetLong(),
            thisWeekActive = pkt:GetLong(),
            joinTime = pkt:GetLong(),
            tao = pkt:GetLong(),
            warTimes = pkt:GetShort(),
            logoutTime = pkt:GetLong(),
            curWarTimes = pkt:GetLong(),
            })

        if data.members[i].online == 1 then
            data.online = data.online + 1
    end
    end
end

function MsgParser:MSG_PARTY_QUERY_MEMBER(pkt, data)
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetShort()
    data.level = pkt:GetShort()
    data.title = pkt:GetLenString()
    data.reputation = pkt:GetLong()
    data.totalScore = pkt:GetLong()
    data.totalDied = pkt:GetLong()
    data.rights = pkt:GetShort()
    data.partyDesc = pkt:GetLenString()
    data.job = pkt:GetLenString()
    data.gender = pkt:GetShort()
    data.contrib = pkt:GetLong()
    data.joinTime = pkt:GetLong()
    data.logoutTime = pkt:GetLong()
    data.online = pkt:GetChar()
    data.inTeam = pkt:GetChar()
    data.family = pkt:GetLenString()
    data.polor = pkt:GetChar()
    data.newJob = pkt:GetLenString()
    data.vipType = pkt:GetChar()
    data.serverId = pkt:GetLenString()
end

function MsgParser:MSG_SEND_PARTY_LOG(pkt, data)
    data.start = pkt:GetLong()
    data.count = pkt:GetLong()

    data.info = {}
    for i = 1, data.count do
        local msg = pkt:GetLenString()

        table.insert(data.info, msg)
    end
end

function MsgParser:MSG_OPEN_ELITE_PET_SHOP(pkt, data)
    data.type = pkt:GetChar()
    data.count = pkt:GetShort()
    data.info = {}
    if data.count ~= 65535 then
        for i = 1, data.count do
            local pet = {
                name = pkt:GetLenString(),
                price = pkt:GetLong(),
            }

            table.insert(data.info, pet)
        end
    end
end

function MsgParser:MSG_RECOMMEND_FRIEND(pkt, data)
    local count  = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local info = {}
        Builders:BuildFields(pkt, info)
        data[i] = info
    end
end

function MsgParser:MSG_MAILBOX_REFRESH(pkt, data)
    local count  = pkt:GetShort()
    data.count = count

    local mail = {}
    for i = 1, count do
        local info = {}
        info.id = pkt:GetLenString()
        info.type = pkt:GetShort()
        info.sender = pkt:GetLenString()
        info.title = pkt:GetLenString()
        info.msg = pkt:GetLenString2()
        info.attachment = pkt:GetLenString2()
        info.create_time = pkt:GetLong()
        info.expired_time = pkt:GetLong()
        info.status = pkt:GetShort()


        mail[i] = info
    end

    table.sort(mail, function(l, r)
        if l.create_time < r.create_time then return true end
        if l.create_time > r.create_time then return false end
    end)

    for i = 1, count do
        data[i] = mail[i]
    end
end

function MsgParser:MSG_PARTY_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.partiesInfo = {}

    for i = 1, data.count do
        local party = {}
        self:MSG_PARTY_INFO(pkt, party)
        table.insert(data.partiesInfo, i , party)
    end
end

function MsgParser:MSG_PARTY_LIST_EX(pkt, data)
    data.type = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.partiesInfo = {}

    for i = 1, data.count do
        local party = {}
        party.partyId = pkt:GetLenString()           -- 帮派ID
        party.partyName = pkt:GetLenString()         -- 帮派名称
        party.partyLevel = pkt:GetShort()
        party.population = pkt:GetShort()
        party.construct = pkt:GetLong()
        table.insert(data.partiesInfo, i , party)
    end
end

function MsgParser:MSG_PARTY_BRIEF_INFO(pkt, data)
    data.partyId = pkt:GetLenString()
    data.partyName = pkt:GetLenString()
    data.creator = pkt:GetLenString()
    data.partyLevel = pkt:GetShort()
    data.population = pkt:GetShort()
    data.construct = pkt:GetLong()
    data.partyIcon = pkt:GetLenString()
    data.money = pkt:GetLong()
    data.create_time = pkt:GetLong()
    data.annouce = pkt:GetLenString2()
    data.skillCount = pkt:GetShort()
    data.skill = {}

    for j = 1, data.skillCount do
        table.insert(
            data.skill,
            {
                name = pkt:GetLenString(),
                no = pkt:GetShort(),
                level = pkt:GetShort(),
                currentScore = pkt:GetLong(),
                levelupScore = pkt:GetLong()
            }
        )
    end

    data.leaderCount = pkt:GetShort()
    data.leader = {}
    for k = 1, data.leaderCount do
        table.insert(data.leader, {
            job = pkt:GetLenString(),
            name = pkt:GetLenString(),})
    end
end

function MsgParser:MSG_DUNGEON_LIST(pkt, data)
    data.bonus = pkt:GetShort()
    data.hard_name = pkt:GetLenString() -- 困难副本名称
end

function MsgParser:MSG_DUNGEON_GET_BONUS(pkt, data)
    data.cost = pkt:GetShort()
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1, data.count do
        local item = {
            name = pkt:GetLenString(),
            num = pkt:GetShort(),
            isClose = pkt:GetChar(),
        }
        table.insert(data.items, item)
    end
end

function MsgParser:MSG_BROACAST_TEAM_ASK_STATE(pkt, data)
    data.meTime = pkt:GetShort()
    data.count = pkt:GetChar()
    data.memberInfo = {}
    for i = 1, data.count do
        local memInfo = {}
        memInfo.name = pkt:GetLenString()
        memInfo.state = pkt:GetShort()
        table.insert(data.memberInfo, memInfo)
    end
end

function MsgParser:MSG_ONLINE_MALL_LIST(pkt, data)
    data.para = pkt:GetLenString()
    data.type = pkt:GetChar()
    local count = pkt:GetShort()
    data.count = count
    if count <= 0 then return end
    for i = 1, count, 1 do
        local item = {}
        item["name"] = pkt:GetLenString()
        item["barcode"] = pkt:GetLenString()
        item["for_sale"] = pkt:GetShort()
        item["show_pos"] = pkt:GetShort()
        item["rpos"] = pkt:GetShort()
        item["sale_quota"] = pkt:GetSignedShort()
        item["recommend"] = pkt:GetShort()
        item["coin"] = pkt:GetLong()
        item["discount"] = pkt:GetChar()
        item["discountTime"] = pkt:GetLong()
        item["type"] = pkt:GetChar()
        item["quota_limit"] = pkt:GetShort()
        item["must_vip"] = pkt:GetChar()
        item["is_gift"] = pkt:GetChar()
        item["follow_pet_type"] = pkt:GetSignedChar()
        data[i] = item
    end
end

function MsgParser:MSG_ONLINE_MALL_CASH_LIST(pkt, data)
    local count = pkt:GetShort()
    for i = 1, count do
        local goods = {}
        goods.barcode = pkt:GetLenString()
        goods["sale_quota"] = pkt:GetLong()
        goods["toMoney"] = pkt:GetLong()
        goods["costCoin"] = pkt:GetLong()
        data[i] = goods
    end
end

function MsgParser:MSG_CHAR_INFO(pkt, data)
    data.msg_type = pkt:GetLenString()  -- 客户端传给服务端的标记，可用于判断该消息对应哪个界面
    data.icon = pkt:GetLong()
    data.id = pkt:GetLong()
    data.level = pkt:GetShort()
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.party = pkt:GetLenString()
    data.friend_score = pkt:GetLong()
    data.setting_flag = pkt:GetLong()
    data.char_status = pkt:GetShort()
    data.vip = pkt:GetChar()
    data.serverId = pkt:GetLenString()
    data.account = pkt:GetLenString()
    data.polar = pkt:GetChar()
    data.isInThereFrend = pkt:GetChar()  -- 是否在对方的好友列表
    data.ringScore = pkt:GetSignedLong()
    data.comeback_flag = pkt:GetChar()  -- 回归标记
    data.isOnline = 1
end

function MsgParser:MSG_PLAY_SCENARIOD(pkt, data)
    data.id = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.portrait = pkt:GetShort()
    data.pic_no = pkt:GetShort()
    data.content = pkt:GetLenString2()
    data.isComplete = pkt:GetShort()
    data.isInCombat = pkt:GetChar()
    data.playTime = pkt:GetShort()
    data.task_type = pkt:GetLenString()
end

function MsgParser:MSG_PARTY_CHANNEL_DENY_LIST(pkt, data)
    data.flag = pkt:GetChar()
    data.count = pkt:GetShort()
    data.speakList = {}
    for i = 1, data.count do

        local gid = pkt:GetLenString()
        local endTime = pkt:GetLong()

        local speakInfo = {
            gid = gid,
            endTime = endTime,
        }
        data.speakList[gid] = speakInfo
    end
end

-- 通天塔相关
function MsgParser:MSG_TONGTIANTA_INFO(pkt, data)
    data.curLayer = pkt:GetShort()      -- 当前层
    data.breakLayer = pkt:GetShort()    -- 目标层
    data.curType = pkt:GetChar()        -- 当前状态
    data.topLayer = pkt:GetLong()
    data.npc = pkt:GetLenString()
    data.challengeCount = pkt:GetChar()
    data.bonusType = pkt:GetLenString()
    data.hasNotCompletedSmfj = pkt:GetChar()
end

function MsgParser:MSG_TONGTIANTA_BONUS_DLG(pkt, data)
    data.bonusType = pkt:GetLenString()
    data.dlgType = pkt:GetChar()
    data.bonusValue = pkt:GetLong()
    data.bonusTaoPoint = pkt:GetLong()
end

function MsgParser:MSG_TONGTIANTA_JUMP(pkt, data)
    data.costType = pkt:GetChar()   -- 消耗类型  1元宝2金钱
    data.costCount = pkt:GetLong()  -- 消耗数量
    data.jumpCount = pkt:GetLong()  -- 跳了多少层
end

function MsgParser:MSG_AUTO_PRACTICE_BONUS(pkt, data)
    data.isPackFull = pkt:GetChar()
	data.count = pkt:GetChar()

    for i = 1, data.count do
	    local reward ={}
        reward.user_exp = pkt:GetLong()
        reward.pet_exp = pkt:GetLong()
        reward.cash = pkt:GetLong()
        reward.baby_name = pkt:GetLenString()
        reward.item_num = pkt:GetChar()
        local itemStartIndex = 1

        if reward.baby_name ~= "" then
            local pet = {}
            pet.baby_name = reward.baby_name
            reward[1] = pet
            itemStartIndex = 2
        end

        for j = itemStartIndex, reward.item_num + itemStartIndex - 1 do
            local item = {}
            item.item_name = pkt:GetLenString()
            item.item_num = pkt:GetChar()
            reward[j] = item
        end

        itemStartIndex = reward.item_num + itemStartIndex
        reward.count = pkt:GetChar()        -- 粉才

        for j = itemStartIndex, reward.count + itemStartIndex - 1  do
            local item = {}
            item.item_name = pkt:GetLenString()
            item.level = pkt:GetChar()
            item.item_num = pkt:GetChar()
            reward[j] = item
        end

        data[i] = reward
	end
end

-- 竞技场
function MsgParser:MSG_ARENA_INFO(pkt, data)
    data.rank = pkt:GetLong()
    data.rewardNumber = pkt:GetLong()
    data.totalReward = pkt:GetLong()
    data.challengLeftTimes = pkt:GetShort()
    data.buyLeftTimes = pkt:GetShort()
end

-- 挑战者数据
function MsgParser:MSG_ARENA_OPPONENT_LIST(pkt, data)
    data.count = pkt:GetChar()

    for i = 1, data.count do
        local challenger = {}
        challenger.key = pkt:GetChar()
        challenger.name = pkt:GetLenString()
        challenger.icon = pkt:GetShort()
        challenger.polar = pkt:GetChar()
        challenger.level = pkt:GetShort()
        challenger.party = pkt:GetLenString()
        challenger.rank = pkt:GetLong()
        challenger.daohang = pkt:GetLong()
        data[i] = challenger
    end

end

-- 历史最高排名奖励
function MsgParser:MSG_ARENA_TOP_BONUS_LIST(pkt, data)
    data.highestRank = pkt:GetLong()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local reward = {}
        reward.rank = pkt:GetLong()
        reward.bonus = pkt:GetLong()
        reward.status = pkt:GetChar()
        data[i] = reward
    end
end

-- 声望商店
function MsgParser:MSG_ARENA_SHOP_ITEM_LIST(pkt, data)
    data.count = pkt:GetChar()

    for i = 1, data.count do
        local item = {}
        item.key = pkt:GetLenString()

        item.name = pkt:GetLenString()
        item.price = pkt:GetLong()
        data[i] = item
    end
end

-- 部分活动信息
function MsgParser:MSG_LIVENESS_INFO_EX(pkt, data)
    data.activityCount = pkt:GetShort()

    for i = 1, data.activityCount do
        local activityData = {}
        activityData.name = pkt:GetLenString()
        activityData.count = pkt:GetSignedShort()
        activityData.activeValue = pkt:GetShort()
		activityData.timeStr = pkt:GetLenString()
        data[i] = activityData
    end
end

function MsgParser:MSG_LIVENESS_INFO(pkt, data)
    data.activityCount = pkt:GetShort()

    for i = 1, data.activityCount do
        local activityData = {}
        activityData.name = pkt:GetLenString()
        activityData.count = pkt:GetSignedShort()
        activityData.activeValue = pkt:GetShort()  -- 活跃度服务端*100
		activityData.timeStr = pkt:GetLenString()
        data[i] = activityData
    end

    data.activityRewardCount = pkt:GetChar()

    for i= data.activityCount + 1, data.activityCount + data.activityRewardCount do
        local activityRewardStatus = {}
        activityRewardStatus.activity = pkt:GetShort()
        activityRewardStatus.status = pkt:GetChar()
        data[i] = activityRewardStatus
    end

    local count = data.activityCount + data.activityRewardCount
    data.count = pkt:GetChar()
    for i = count + 1, tonumber(data.count) + count do
        local activityStatus = {}
        activityStatus.name = pkt:GetLenString()
        activityStatus.startTime = pkt:GetLong()
        activityStatus.endTime = pkt:GetLong()
        data[i] = activityStatus
    end

end

function MsgParser:MSG_REFRESH_PARTY_SHOP(pkt, data)
    data.costWing = pkt:GetLong()
    local count = pkt:GetChar()
    data.count = count
    local name, num
    for i = 1, count do
        local item = {}
        item.name = pkt:GetLenString()
        item.num = pkt:GetShort()
        item.cost = pkt:GetLong()
        data[i] = item
    end
end

function MsgParser:MSG_SHUADAO_SCORE_ITEMS(pkt, data)
    data.score = pkt:GetLong()  -- 上次离线时间
    data.fetchState = pkt:GetLong()    -- 总双倍次数
    data.zqhmFetchState = pkt:GetLong() -- 紫气鸿蒙领取状态
end

-- 刷道托管结算数据
function MsgParser:MSG_SHUADAO_TRUSTEESHIP_INFO(pkt, data)
    data.count = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.tao_ex = pkt:GetLong()
    data.martial = pkt:GetLong()
    data.pot = pkt:GetLong()
    data.cash = pkt:GetLong()
    data.voucher = pkt:GetLong()
    data.score = pkt:GetLong()
    data.tru_time = pkt:GetLong()
end

function MsgParser:MSG_SHUADAO_USEPOINT_STATUS(pkt, data)
    data.doubleOffLineState = pkt:GetChar()   -- 离线刷到双倍状态
    data.jjrllOffLineState = pkt:GetChar()   -- 急急如律令
    data.cfsOffLineState =  pkt:GetChar()   -- 宠风散
    data.zqhmOffLineState = pkt:GetChar()   -- 紫气鸿蒙
end

--
function MsgParser:MSG_REFRESH_SHUAD_TRUSTEESHIP(pkt, data)
    data.ti = pkt:GetLong()  -- 时间
    data.state = pkt:GetChar()  -- 状态
    data.task_name = pkt:GetLenString() -- 任务名
    data.is_smart = pkt:GetChar()  -- 是否处于只能托管状态
end

-- 帮派邀请列表
function MsgParser:MSG_PARTY_INVITE(pkt, data)
    data.inviteName = pkt:GetLenString()
    data.partyName = pkt:GetLenString()
    data.partyLevel = pkt:GetChar()
    data.partyConstruction = pkt:GetLong()
    data.partyPopulation = pkt:GetShort()
end

-- 删除帮派邀请列表中某一个
function MsgParser:MSG_PARTY_INVITE_CLEAN(pkt, data)
    data.partyName = pkt:GetLenString()
end

function MsgParser:MSG_SHUADAO_REFRESH(pkt, data)
    data.hasBonus = pkt:GetShort()
    data.xy_higest = pkt:GetShort()
    data.fm_higest = pkt:GetShort()
    data.fx_higest = pkt:GetShort()

    data.off_line_time = pkt:GetLong()
    data.buy_one = pkt:GetShort()
    data.buy_five = pkt:GetShort()
    data.buy_time = pkt:GetShort()
    data.max_buy_time = pkt:GetShort() -- 离线时间最大购买次数

    data.offlineStatus = pkt:GetShort()
    data.max_turn = pkt:GetShort()
    data.lastTaskName = pkt:GetLenString()
    data.max_double = pkt:GetShort()
    data.max_jiji = pkt:GetShort()
    data.jijiStatus = pkt:GetShort()
    data.chongfengsan_time = pkt:GetShort() --  限购宠风散已购买次数
    data.max_chongfengsan_time = pkt:GetShort() -- 限购宠风散最大次数
    data.ziqihongmeng_time = pkt:GetShort() -- 限购紫气鸿蒙已购买次数
    data.max_ziqihongmeng_time = pkt:GetShort() -- 限购紫气鸿蒙最大次数
    data.max_chongfengsan = pkt:GetShort()
    data.chongfengsan_status = pkt:GetShort()

    data.max_ziqihongmeng = pkt:GetShort()
    data.ziqihongmeng_status = pkt:GetShort()
    data.hasDaofaBonus = pkt:GetChar()

    data.count = pkt:GetShort()
    data.tasks = {}
    for i = 1, data.count do
        local taskName = pkt:GetLenString()
        local taskTime = pkt:GetShort()
        data.tasks[taskName] = taskTime
    end
end

function MsgParser:MSG_SHUADAO_REFRESH_BONUS(pkt, data)
    data.lastTime = pkt:GetLong()  -- 上次离线时间
    data.doubleTime = pkt:GetLong()    -- 总双倍次数
    data.doublePoint = pkt:GetLong()   -- 总双倍点数
    data.jjrllPoint = pkt:GetLong()    -- 总的急急如律令
    data.ChongfengsanTimes = pkt:GetLong() -- 宠风散收益几轮
    data.ChongfengsanPoint = pkt:GetLong() -- 消耗宠风散几点
    data.ziqihongmengTimes = pkt:GetLong() -- 紫气鸿蒙收益几轮
    data.ziqihongmengPoint = pkt:GetLong() -- 消耗紫气鸿蒙点数
    data.moneyType = pkt:GetChar() -- 0 代金券  1 金钱
    data.totalFight = pkt:GetShort()   -- 总共多少场战斗
    data.tasks = {}
    data.robber = 0
    for i = 1,data.totalFight do
        local singel = {
            fightTime = pkt:GetShort(),
            rounds = pkt:GetShort(),
            money = pkt:GetLong(),
            tao = pkt:GetLong(),
            taoPoint = pkt:GetLong(),
            martial = pkt:GetLong(),
            potential = pkt:GetLong(),
            daofa = pkt:GetLong(),
            isDouble = pkt:GetChar(),
            jjrllPoint = pkt:GetChar(),
            isUseChongfengsan = pkt:GetChar(),
            isUseZiqihongmeng = pkt:GetChar(),
        }
        table.insert(data.tasks, singel)
        if singel.rounds == 0 then data.robber = data.robber + 1 end
    end
    data.totalTao = pkt:GetLong()
    data.totalTaoPoint = pkt:GetLong()
    data.totalMartial = pkt:GetLong()
    data.totalPotential = pkt:GetLong()
    data.totalDaofa = pkt:GetLong()
    data.totalMoney = pkt:GetLong()
end

function MsgParser:MSG_SHUADAO_REFRESH_BUY_TIME(pkt, data)
    data.buy_one = pkt:GetShort()
    data.buy_five = pkt:GetShort()
    data.off_line_time = pkt:GetLong()
    data.buy_time = pkt:GetShort()
end

function MsgParser:MSG_CHALLENGE_MSG(pkt, data)
    data.record_time = pkt:GetLong()
    data.challenge_staus = pkt:GetChar()
    data.gid = pkt:GetLenString()
    data.player_name = pkt:GetLenString()
    data.vectory_status = pkt:GetChar()
    data.last_ranking = pkt:GetShort()
    data.cur_ranking = pkt:GetShort()
end

function MsgParser:MSG_AUTO_WALK(pkt, data)
    data.dest = pkt:GetLenString()
    data.task_type = pkt:GetLenString()
end

-- 查看装备
function MsgParser:MSG_LOOK_PLAYER_EQUIP(pkt, data)
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
    data.icon = pkt:GetLong()
    data.special_icon = pkt:GetLong()
    data.weapon_icon = pkt:GetLong()
    data.suit_icon = pkt:GetLong()
    data.suit_effect = pkt:GetLong()
    data.power = pkt:GetLong()
    data.partyName = pkt:GetLenString()
    data.fashionIcon = pkt:GetLong()
    data["upgrade/type"] = pkt:GetChar()
    data["upgrade/level"] = pkt:GetShort()

    data.count = pkt:GetChar()
    data["equipment"] = {}
    for i = 1, data.count do
        local equipment = {}
        equipment.pos = pkt:GetShort()
        Builders:BuildItemInfo(pkt, equipment)
        data["equipment"][equipment.pos] = equipment
    end

    data.light_effect_count = pkt:GetChar()
    data.light_effect = {}
    for i = 1, data.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.light_effect, effect)
    end

    local customIcon = pkt:GetLenString()
    if not string.isNilOrEmpty(customIcon) then
        data.part_index, data.part_color_index = string.match(customIcon, "(.+):(.+)")
    else
        data.part_index, data.part_color_index = "", ""
    end
end

function MsgParser:MSG_REPLY_SERVER_TIME(pkt, data)
    data.server_time = pkt:GetLong()
    data.client_time = gfGetTickCount()
    data.time_zone = pkt:GetSignedChar()
end

function MsgParser:MSG_CARD_INFO_FOR_PET(pkt, data)
    Builders:BuildPetInfo(pkt, data.cardInfo)

    data.cardInfo.skills = {}
    local count = pkt:GetShort()
    for i = 1, count, 1 do
        local skill = {}
        Builders:BuildSkillBasicInfo(pkt, skill)
        data.cardInfo.skills[i] = skill
    end

    local count = pkt:GetShort()
    data.cardInfo["god_book_skill_count"] = count
    for i = 1, count do
        data.cardInfo["god_book_skill_name_"..i] = pkt:GetLenString()
        data.cardInfo["god_book_skill_level_"..i] = pkt:GetShort()
        data.cardInfo["god_book_skill_power_"..i] = pkt:GetShort()
        data.cardInfo["god_book_skill_disabled_" .. i] = pkt:GetChar()
    end

    -- 额外属性
    local extraData = {}
    Builders:BuildFields(pkt, extraData)
    for key, value in pairs(extraData) do
        data.cardInfo[key] = (data.cardInfo[key] or 0) + value
    end
end

-- 名片查看
function MsgParser:MSG_CARD_INFO(pkt, data)

    if data.notGid then
    else
        data.cardGid = pkt:GetLenString()
    end

    data.type = pkt:GetLenString()
    data.cardInfo = {}
    if data.type == CHS[3000015] then           -- 道具
        Builders:BuildItemInfo(pkt, data.cardInfo)
    elseif data.type == CHS[6000079] then       -- 宠物
        self:MSG_CARD_INFO_FOR_PET(pkt, data)
    elseif data.type == CHS[6000162] then       -- 守护
        local Guard = {}
        Builders:BuildPetInfo(pkt, Guard)
        data.cardInfo= Guard

     --[[   local equipment = {}
        self:MSG_GUARD_UPDATE_EQUIP(pkt, equipment)
        data.cardInfo["weapon"] = equipment["weapon"]
        data.cardInfo["helmet"] = equipment["helmet"]
        data.cardInfo["armor"]  = equipment["armor"]
        data.cardInfo["boot"]   = equipment["boot"] ]]

        local atttrib = {}
        self:MSG_GUARD_UPDATE_GROW_ATTRIB(pkt, atttrib)
        data.cardInfo["develop_power"] = atttrib['grow_attrib']["power"] or 0
        data.cardInfo["develop_def"] = atttrib['grow_attrib']["def"] or 0
        data.cardInfo["rebuild_level"] = atttrib['grow_attrib']["rebuild_level"] or 0

        data.cardInfo["degree"] = atttrib['grow_attrib']["degree_32"] or 0


    elseif data.type == CHS[6000163] then       -- 任务
        local task = {}
        self:MSG_TASK_PROMPT(pkt, task)
        data.cardInfo = task[1]
    elseif data.type == CHS[6000164] then       -- 技能
        local count = pkt:GetShort()
        Builders:BuildSkillBasicInfo(pkt, data.cardInfo)

    elseif data.type == CHS[6000165] then       -- 称谓
        data.cardInfo["type"] = pkt:GetLenString()
        data.cardInfo["title"] = pkt:GetLenString()
    elseif data.type == CHS[3002133] then       -- 角色
        Builders:BuildFields(pkt, data)
        data.light_effect_count = pkt:GetChar()
        data.light_effect = {}
        for i = 1, data.light_effect_count do
            local effect = pkt:GetLong()
            table.insert(data.light_effect, effect)
        end
        local customIcon = pkt:GetLenString()
        if not string.isNilOrEmpty(customIcon) then
            data.part_index, data.part_color_index = string.match(customIcon, "(.+):(.+)")
        else
            data.part_index, data.part_color_index = "", ""
        end
        data.follow_icon = pkt:GetLong()
    elseif data.type == CHS[4100443] then
        data.combat_id = pkt:GetLenString()
    elseif data.type == CHS[7000012] then
        -- “今日统计”数据解析
        self:MSG_DAILY_STATS(pkt, data)
    elseif data.type == CHS[2200062] then
        data.gid = pkt:GetLenString()
    elseif data.type == CHS[4100818] then   -- 成就
        data.cardInfo["name"] = pkt:GetLenString()
        data.cardInfo["achieve_id"] = pkt:GetLong()
        data.cardInfo["point"] = pkt:GetLong()
        data.cardInfo["achieve_desc"] = pkt:GetLenString()
        data.cardInfo["progress"] = pkt:GetLong()
        data.cardInfo["progress_max"] = pkt:GetLong()
        data.cardInfo["is_finished"] = pkt:GetChar()
        data.cardInfo["time"] = pkt:GetLong()
        data.cardInfo["user"] = pkt:GetLenString()
        data.cardInfo["category"] = pkt:GetShort()

    end

end

function MsgParser:MSG_PET_CARD(pkt, data)
    Builders:BuildPetInfo(pkt, data)

    data.skills = {}
    local count = pkt:GetChar()
    for i = 1, count, 1 do
        local skill = {}
        skill.skill_no = pkt:GetShort()
        skill.skill_level = pkt:GetShort()
        skill.skill_nimbus = pkt:GetLong()
        data.skills[i] = skill
    end

    local count = pkt:GetChar()
    data["god_book_skill_count"] = count
    for i = 1, count do
        data["god_book_skill_name_"..i] = pkt:GetLenString()
        data["god_book_skill_level_"..i] = pkt:GetShort()
        data["god_book_skill_power_"..i] = pkt:GetShort()
        data["god_book_skill_disabled_" .. i] = pkt:GetChar()
    end

            -- 额外属性
    local extraData = {}
    Builders:BuildFields(pkt, extraData)
    for key, value in pairs(extraData) do
        data[key] = (data[key] or 0) + value
end
end

function MsgParser:MSG_PARTY_WAR_BID_INFO(pkt, data)
    data.end_time = pkt:GetLong()
    data.count = pkt:GetShort()
    data.info = {}
    for i = 1, data.count do
        local info = {}
        info.party_name = pkt:GetLenString()
        info.cash = pkt:GetLong()
        table.insert(data.info, info)
    end
end

function MsgParser:MSG_PARTY_WAR_INFO(pkt, data)
    data.type = pkt:GetShort()
    data.count = pkt:GetShort()
    data.itemCount = pkt:GetShort()
    data.info = {}
    for i = 1, data.count do
        local info = {}
        for j = 1, data.itemCount do
            info[pkt:GetLenString()] = pkt:GetLenString()
        end
        table.insert(data.info, info)
    end
    data.isOpenDlg = pkt:GetChar()
end

function MsgParser:MSG_PARTY_WAR_SCORE(pkt, data)
    data.myAction = pkt:GetLong()
    data.myActive = pkt:GetLong()
    data.ourActive = pkt:GetLong()
    data.otherActive = pkt:GetLong()
end

-- 新手礼包
function MsgParser:MSG_NEWBIE_GIFT(pkt, data)
    data.giftCount = pkt:GetChar()
    data.gifts = {}

    for i = 1, data.giftCount do
        local itemList = {}
        itemList.isGot = pkt:GetChar()
        itemList.limitLevel = pkt:GetShort()
        itemList.count = pkt:GetChar()

        for j = 1, itemList.count do
            local item = {}
            item.name = pkt:GetLenString()
            item.number = pkt:GetLong()
            local level = pkt:GetSignedLong()
            if -1 ~= level then
                item.level = level
            end
            itemList[j] = item
        end

        data.gifts[i] = itemList
    end
end

function MsgParser:MSG_SHIDAO_TASK_INFO(pkt, data)
    if pkt:GetDataLen() > 0 then
        data.isPK = pkt:GetChar() -- 是否是决赛
        data.stageId = pkt:GetChar()
        data.monsterPoint = pkt:GetShort()
        data.pkValue = pkt:GetShort()
        data.totalScore = pkt:GetShort()
        data.startTime = pkt:GetLong()
        data.stage1_duration_time = pkt:GetLong() -- 元魔持续时间
        data.stage2_duration_time = pkt:GetLong()
        data.rank = pkt:GetChar()
        data.isMonthTao = pkt:GetChar()
    end
end

function MsgParser:MSG_SHIDAO_GLORY_HISTORY(pkt, data)
    data.levelCount = pkt:GetShort()
    data.levelList = {}
    for i = 1, data.levelCount do
        local levelInfo = {}
        levelInfo.levelBuff = pkt:GetShort()
        levelInfo.timeCount = pkt:GetChar()
        levelInfo.timeInfo = {}
        for n = 1, levelInfo.timeCount do
            local timeInfo = {}
            timeInfo.time = pkt:GetLong()
            timeInfo.isMonth = pkt:GetChar()
            timeInfo.memberCount = pkt:GetChar()
            timeInfo.team = {}
            for j = 1, timeInfo.memberCount do
                local member = {}
                member.isLeader = pkt:GetChar()
                member.memberName = pkt:GetLenString()
                member.level = pkt:GetShort()
                member.family = pkt:GetChar()
                member.gid = pkt:GetLenString()
                member.icon = pkt:GetLong()
                table.insert(timeInfo.team, member)
            end
            table.insert(levelInfo.timeInfo, timeInfo)
        end

        table.insert(data.levelList, levelInfo)
    end
end

-- 每日签到
function MsgParser:MSG_DAILY_SIGN(pkt, data)
    data.monthDays = pkt:GetChar()
    data.signDays = pkt:GetChar()
    data.isCanSgin = pkt:GetChar()
    data.isCanReplenishSign = pkt:GetChar()
    data.itemList = {}

    for i = 1, data.monthDays do
        local item = {}
        item.name = pkt:GetLenString()
        item.number = pkt:GetLong()
        data.itemList[i] = item
    end
end

-- 神秘大礼
function MsgParser:MSG_AWARD_OPEN(pkt, data)
    data.type = pkt:GetChar()
    data.times = pkt:GetLong()
    data.leftTimes = pkt:GetLong()
end

function MsgParser:MSG_AWARD_INFO_EX(pkt, data)
    data.type = pkt:GetChar()
    data.name = pkt:GetLenString()
	data.rate = pkt:GetChar()
end

function MsgParser:MSG_FINISH_AWARD(pkt, data)
    data.type = pkt:GetChar()
    data.isFinish = pkt:GetChar()
end

function MsgParser:MSG_OPEN_WELFARE(pkt, data)
    data.leftTime = pkt:GetLong()  -- 神秘大礼下一次剩余时间
    data.times = pkt:GetChar()   -- 神秘大礼当前可抽奖次数
    data.leftTimes = pkt:GetChar()  -- 神秘大礼当天剩余可抽奖次数
    data.isCanSign = pkt:GetChar()  -- 每日签到
    data.isCanGetNewPalyerGift = pkt:GetChar()
    data.firstChargeState = pkt:GetChar() -- 0 未充值          1 已经充值未领取    2 已经充值已经领取
    data.cumulativeReward = pkt:GetChar() -- 已弃用，服务器未删除该字段
    data.loginGiftState = pkt:GetChar() -- 0 有礼包不可领取          1 有礼包可领取    2 全部领取
	--data.reentryCount = pkt:GetSignedChar() -- 再续前缘领取数目
    data.activeCount = pkt:GetSignedChar() -- -1 表示隐藏； 0 表示不可以抽奖， 1 表示允许抽奖
    data.holidayCount = pkt:GetSignedChar() -- -1 表示隐藏； 其他表示可领取的礼包数
    data.isCanReplenishSign = pkt:GetChar()  -- 1表示可以补签，0表示不可补签
    data.chargePointFlag = pkt:GetSignedChar() -- -1表示活动结束，1表示活动期间
    data.consumePointFlag = pkt:GetSignedChar()  -- -1表示活动结束，1表示活动期间
    data.isShowHuiGui = pkt:GetChar() -- 是否显示老玩家回归
    data.canGetZXQYHuoYue = pkt:GetChar()
    data.canGetZXQYSevenLogin = pkt:GetChar()
    data.isShowZhaohui = pkt:GetChar() -- 是否显示召回道友
    data.activeVIPFlag = pkt:GetChar() -- 是否显示活跃送会员
    data.rename_discount_time = pkt:GetChar() -- 五折改名卡
    data.summerSF2017 = pkt:GetChar() -- 暑假送福
    data.zaohua = pkt:GetSignedChar() -- 暑假送福
    data.welcomeDrawStatue = pkt:GetSignedChar() -- 迎新抽奖活动是否开启，其中 -1 = 未开启， 1 = 可以抽奖， 0 = 不能抽奖， 2 = 已领奖
    data.activeLoginStatue = pkt:GetSignedChar() -- -1表示活动结束，0表示活动期间但无礼包可领取，1有礼包可领取
    data.xundcf = pkt:GetSignedChar() -- -1 时，表示寻道赐福不开启； 为 非负数 时，表示奖励可以领取的次数
    data.mergeLoginStatus = pkt:GetSignedChar()
    data.mergeLoginActiveStatus = pkt:GetSignedChar()
    data.reentryAsktaoRecharge = pkt:GetSignedChar() -- 回归累充 -1 未开启 ， 1 = 可以领奖， 0 = 不能领奖， 2 = 已领奖
    data.expStoreStatus = pkt:GetSignedChar() -- 0 未开启 1 开启

    data.isShowXYFL = pkt:GetSignedChar() -- -1 看不见，1表示小红点
    data.isShowXFSD = pkt:GetSignedChar() -- 新服盛典

    data.newServeAddNum = pkt:GetSignedShort() -- 新服助力加成的百分比 -1 未开启
end

function MsgParser:MSG_FESTIVAL_LOTTERY(pkt, data)
    data.count = pkt:GetChar()            -- 抽将活动数量

    for i = 1, data.count do
        local activity = {}
        local name = pkt:GetLenString()
        activity = {}
        activity.name = name              -- 抽奖名称
        activity.amount = pkt:GetShort()  -- 抽奖次数
        activity.startTime = pkt:GetLong()
        activity.endTime = pkt:GetLong()
        data[name] = activity
    end
end

-- 月首充奖品信息
function MsgParser:MSG_MONTH_CHARGE_GIFT(pkt, data)
    data.month = pkt:GetChar()
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.count = pkt:GetChar()            -- 数量

    for i = 1, data.count do
        data[i] = {}
        data[i].item_name = pkt:GetLenString()
        data[i].item_amount = pkt:GetChar()
        data[i].item_gift = pkt:GetChar()
        data[i].item_icon = pkt:GetLenString()
    end
end

function MsgParser:MSG_WINTER_LOTTERY_MSG(pkt, data)
    data.rewardMsg = pkt:GetLenString2()
end

function MsgParser:MSG_SPRING_LOTTERY_MSG(pkt, data)
    data.redBagNo = pkt:GetChar()  -- 红包编号
    data.msg = pkt:GetLenString2()  -- 提示信息
end

function MsgParser:MSG_RECHARGE_SCORE_GOODS_LIST(pkt, data)
    data.startTime = pkt:GetLong() -- 活动开始时间
    data.endTime = pkt:GetLong()   -- 活动结束时间
    data.deadline = pkt:GetLong()  -- 兑换截止时间
    data.ownPoint = pkt:GetShort() -- 拥有积分
    data.totalPoint = pkt:GetShort() -- 累计积分
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local item = {}
        item.no = pkt:GetChar() + 1 -- 服务端发的是从 0 开始
        item.rewardStr = pkt:GetLenString()
        item.point = pkt:GetShort() -- 购买单个的积分
        item.num = pkt:GetShort()   -- 剩余数量
        data[item.no] = item
    end
end

function MsgParser:MSG_CONSUME_SCORE_GOODS_LIST(pkt, data)
    data.startTime = pkt:GetLong() -- 活动开始时间
    data.endTime = pkt:GetLong()   -- 活动结束时间
    data.deadline = pkt:GetLong()  -- 兑换截止时间
    data.ownPoint = pkt:GetShort() -- 拥有积分
    data.totalPoint = pkt:GetShort() -- 累计积分
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local item = {}
        item.no = pkt:GetChar() + 1 -- 服务端发的是从 0 开始
        item.rewardStr = pkt:GetLenString()
        item.point = pkt:GetShort() -- 购买单个的积分
        item.num = pkt:GetShort()   -- 剩余数量
        data[item.no] = item
    end
end

function MsgParser:MSG_RECHARGE_SCORE_GOODS_INFO(pkt, data)
    data.ownPoint = pkt:GetShort()
    data.totalPoint = pkt:GetShort()
    data.no = pkt:GetChar() + 1
    data.rewardStr = pkt:GetLenString()
    data.point = pkt:GetShort()
    data.num = pkt:GetShort()
end

function MsgParser:MSG_CONSUME_SCORE_GOODS_INFO(pkt, data)
    data.ownPoint = pkt:GetShort()
    data.totalPoint = pkt:GetShort()
    data.no = pkt:GetChar() + 1
    data.rewardStr = pkt:GetLenString()
    data.point = pkt:GetShort()
    data.num = pkt:GetShort()
end

function MsgParser:MSG_OPEN_SSNYF(pkt, data)
    data.status = pkt:GetLenString()        -- 菜肴品尝状态
    data.activeValue = pkt:GetShort()       -- 玩家当前活跃度
    data.start_time = pkt:GetLong()         -- 第一道菜肴开始品尝时间
    data.interval = pkt:GetLong()           -- 间隔
    data.lucky_num = pkt:GetLong()          -- 幸运值
    data.needActiveValue = pkt:GetLong()    -- 品尝所需的活跃度
end

-- 2019春节开始敲钟游戏
function MsgParser:MSG_SPRING_2019_ZSQF_START_GAME(pkt, data)
    data.encrypt_id = pkt:GetLenString()  -- 加密 id
end

-- 春节打开祈福界面
function MsgParser:MSG_SPRING_2019_ZSQF_OPEN(pkt, data)
    data.status = pkt:GetLenString()        -- 祈福领奖状态
    data.lucks_num = pkt:GetLenString()     -- 每个祈福领奖可获得的幸运值数量
    data.activeValue = pkt:GetShort()       -- 玩家当前活跃度
    data.start_time = pkt:GetLong()         -- 开始时间
    data.interval = pkt:GetLong()           -- 间隔
    data.lucky_num = pkt:GetLong()          -- 幸运值
    data.needActiveValue = pkt:GetLong()    -- 祈福所需的活跃度
end

function MsgParser:MSG_PLAY_INSTRUCTION(pkt, data)
    data.guideId = pkt:GetShort()
end

function MsgParser:MSG_STALL_MINE(pkt, data)
    data.dealNum = pkt:GetShort()
    data.sellCash = tonumber(pkt:GetLenString())
    data.stallTotalNum = pkt:GetShort()
    data.record_count_max = pkt:GetShort()
    data.stallNum = pkt:GetShort()
    data.items = {}
    for i = 1, data.stallNum do
        local item = {}
        item.name = pkt:GetLenString()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.pos = i
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.amount = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()
        item.item_polar = pkt:GetChar()
        item.cg_price_count = pkt:GetChar()
        item.init_price = pkt:GetLong()
        table.insert(data.items, item)
    end

end

function MsgParser:MSG_REFRESH_STALL_ITEM(pkt, data)
    data.id = pkt:GetLong()
    data.amount = pkt:GetLong()
    data.price = pkt:GetLong()
end

function MsgParser:MSG_STALL_ITEM_LIST(pkt, data)
    data.totalPage = pkt:GetShort()
    data.cur_page = pkt:GetShort()
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.name =  pkt:GetLenString()
        item.is_my_goods = pkt:GetChar()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.amount = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()
        item.item_polar = pkt:GetChar()
        table.insert(data.itemList, item)
    end

    data.path_str = pkt:GetLenString()  -- 打开集市界面的路径
    data.select_gid = pkt:GetLenString()  -- 选中的商品的 gid
    data.sell_stage = pkt:GetChar()  -- 出售阶段 1 公示 2 逛摊
	data.sort_key = pkt:GetLenString()		-- 排序类型 "price" 按价格、"start_time" 按上架时间 (公示时间)
	data.is_descending = pkt:GetChar()		-- 是否降序
end

function MsgParser:MSG_STALL_SERACH_ITEM_LIST(pkt, data)
    data.type = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1, data.count do
        local item = {}
        item.price = pkt:GetLong()
        Builders:BuildItemInfo(pkt, item)
        table.insert(data.items, item)
    end
end

function MsgParser:MSG_STALL_RECORD(pkt, data)
    data.buyCount = pkt:GetShort()
    data.buyList = {}
    for i = 1, data.buyCount do
        local item = {}
        item.name = pkt:GetLenString()
        item.level = pkt:GetShort()
        item.time = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.amount = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.item_polar = pkt:GetChar()
        item.type = pkt:GetChar()
        item.record_id = pkt:GetLenString()
        table.insert(data.buyList, item)
    end

    data.sellCout = pkt:GetShort()
    data.sellList = {}
    for i = 1, data.sellCout do
        local item = {}
        item.name = pkt:GetLenString()
        item.level = pkt:GetShort()
        item.time = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.amount = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.item_polar = pkt:GetChar()
        item.type = pkt:GetChar()
        item.record_id = pkt:GetLenString()
        table.insert(data.sellList, item)
    end
end

-- 集市抢购
function MsgParser:MSG_STALL_RUSH_BUY_OPEN(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.state = pkt:GetChar()
    data.isOpen = pkt:GetChar()
end

-- 珍宝
function MsgParser:MSG_GOLD_STALL_RUSH_BUY_OPEN(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.state = pkt:GetChar()
    data.isOpen = pkt:GetChar()
end

-- 集市抢购结果
function MsgParser:MSG_STALL_BUY_RESULT(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.type = pkt:GetChar()
    data.result = pkt:GetChar()
    data.tips = pkt:GetLenString()
end

function MsgParser:MSG_GOLD_STALL_BUY_RESULT(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.type = pkt:GetChar()
    data.result = pkt:GetChar() -- 1 购买成功，3下架
    data.tips = pkt:GetLenString()
end

function MsgParser:MSG_PLAY_LIGHT_EFFECT(pkt, data)
    data.charId = pkt:GetLong()
    data.effectIcon = pkt:GetLong()
    data.interval  = pkt:GetShort()
end

function MsgParser:MSG_STOP_LIGHT_EFFECT(pkt, data)
    data.charId = pkt:GetLong()
    data.effectIcon = pkt:GetLong()
end

function MsgParser:MSG_INSIDER_INFO(pkt, data)
    data.vipType = pkt:GetChar()

    -- endTime 可能超出 int 范围，所以服务端分为两部分发送
    local leftTime = pkt:GetLong()
    local curTime = pkt:GetLong()
    data.endTime = curTime + leftTime

    data.isGet = pkt:GetChar()
    data.tempInsider = pkt:GetChar() -- 是否是体验会员
end

-- 系统设置
function MsgParser:MSG_SET_SETTING(pkt, data)
    data.count = pkt:GetShort()
    data.setting = {}

    for i = 1, data.count do
        local key = pkt:GetLenString()
        data.setting[key] = pkt:GetShort()
    end
end

function MsgParser:MSG_MATCH_TEAM_STATE(pkt, data)
    data.state = pkt:GetSignedChar()
    if 0 ~= data.state then
        data.type = pkt:GetChar()
        if 2 == data.state then
            data.minLevel = pkt:GetShort()
            data.maxLevel = pkt:GetShort()
            data.minTao = pkt:GetLong() / Const.ONE_YEAR_TAO -- 客户端以 年为单位
            data.maxTao = pkt:GetLong() / Const.ONE_YEAR_TAO
            data.polars_count = pkt:GetShort()
            data.polars = {}
            for i = 1, data.polars_count do
                data.polars[i] = pkt:GetShort()
            end
        end
    end
end

function MsgParser:MSG_MATCH_TEAM_LIST(pkt, data)
    data.teamCount = pkt:GetShort()
    data.memberCount = pkt:GetShort()
    data.type = pkt:GetChar()
    data.count = pkt:GetShort()
    data.teams = {}
    for i = 1, data.count do
        local team = {}
        team.leaderName = pkt:GetLenString()
        team.leaderIcon = pkt:GetShort()
        team.leaderLevel = pkt:GetShort()
        team.type = pkt:GetChar()
        team.memberCount = pkt:GetChar()
        team.party = pkt:GetLenString()
        table.insert(data.teams, team)
    end
end

function MsgParser:MSG_MATCH_SIZE(pkt, data)
    data.teams = pkt:GetShort()
    data.members = pkt:GetShort()
end

function MsgParser:MSG_CITY_WAR_SCORE(pkt, data)
    data.stage = pkt:GetChar()
    data.cw_action_point = pkt:GetLong()
    data.npc1_life = pkt:GetLong()
    data.npc1_max_life = pkt:GetLong()
    data.npc2_life = pkt:GetLong()
    data.npc2_max_life = pkt:GetLong()
    data.npc3_life = pkt:GetLong()
    data.npc3_max_life = pkt:GetLong()
end

function MsgParser:MSG_LEVEL_UP(pkt, data)
    data.id = pkt:GetLong()
    data.level = pkt:GetShort()
end

-- 元婴、血婴升级
function MsgParser:MSG_UPGRADE_LEVEL_UP(pkt, data)
    data.id = pkt:GetLong()
    data.level = pkt:GetShort()
end

function MsgParser:MSG_NOTIFICATION(pkt, data)
    data.type = pkt:GetShort()
end

function MsgParser:MSG_MENU_SELECT(pkt, data)
    data.item = pkt:GetLenString()
end

function MsgParser:MSG_FIND_CHAR_MENU_FAIL(pkt, data)
    data.msg_type = pkt:GetLenString()  -- 客户端传给服务端的标记，可用于判断该消息对应哪个界面
    data.char_id = pkt:GetLenString()
end

function MsgParser:MSG_RANDOM_NAME(pkt, data)
    data.new_name = pkt:GetLenString()
end

function MsgParser:MSG_COMBAT_STATUS_INFO(pkt, data)
    data.objId = pkt:GetLong()
    data.statusType = pkt:GetLenString()
    Builders:BuildFields(pkt, data)
    data.isCanUseHYJJ = pkt:GetChar() -- 是否可以使用火眼金睛
    data.zhenfaPolar = pkt:GetChar()
end

function MsgParser:MSG_OPEN_EXCHANGE_SHOP(pkt, data)
    data.type = pkt:GetChar()
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1,data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.payName = pkt:GetLenString()

        table.insert(data.items, item)
    end
end

function MsgParser:MSG_LEADER_COMBAT_GUARD(pkt, data)
    data.count = pkt:GetChar()

    data.guardList = {}
    for i = 1, data.count do
        local guard = {}
        guard.guardName = pkt:GetLenString()
        guard.guardLevel = pkt:GetShort()
        guard.guardIcon = pkt:GetShort()
        guard.guardOrder = pkt:GetShort()
        guard.guardId = pkt:GetLong()
        table.insert(data.guardList, guard)
    end
end

-- 重连时通过如下消息发送之前设置的战斗指令
function MsgParser:MSG_FIGHT_CMD_INFO(pkt, data)
--[[
    -- 原解析
    data.count = pkt:GetChar()

    for i = 1, data.count do
        local actionData = {}
        actionData.id = pkt:GetLong()
        actionData.action = pkt:GetShort()
        actionData.param = pkt:GetShort()
        actionData.manaIndex = pkt:GetChar()
        data[i] = actionData
    end
    --]]
    data.count = pkt:GetChar()

    for i = 1, data.count do
        local actionData = {}
        actionData.id = pkt:GetLong()                   -- 对象id
        actionData.auto_select = pkt:GetChar()          -- 没蓝情况下，普攻还是补蓝
        actionData.multi_index = pkt:GetChar()          -- 当前使用的自动战斗索引，1 表示使用组合自动战斗，0 表示使用普通自动战斗
        actionData.action = pkt:GetChar()               -- 普通自动战斗动作
        actionData.para = pkt:GetLong()                 -- 普通自动战斗动作参数
        actionData.autoFightData = {}
        actionData.multi_count = pkt:GetChar()          -- 组合自动战斗条数
        for i = 1, actionData.multi_count do
            actionData.autoFightData[i] = {}
            actionData.autoFightData[i].action = pkt:GetChar()      -- 组合自动战斗动作
            actionData.autoFightData[i].para = pkt:GetLong()      -- 组合自动战斗动作
            actionData.autoFightData[i].round = pkt:GetChar()      -- 组合自动战斗回合数
end
        data[i] = actionData
    end

end

function MsgParser:MSG_SUBMIT_PET(pkt, data)
    data.type = pkt:GetShort()
    data.petCount = pkt:GetShort()
    data.petNameList = {}
    for i = 1, data.petCount do
        local petName = pkt:GetLenString()
        data.petNameList[i] = petName
    end

    data.petState = pkt:GetLong()
end

function MsgParser:MSG_OPEN_AUTO_MATCH_TEAM(pkt, data)
    data.dlgType = pkt:GetChar()
    data.keyName = pkt:GetLenString()
end

-- 请求在历练的守护id
function MsgParser:MSG_GUARD_EXPERIENCE_ID(pkt, data)
    data.guard_id = pkt:GetLong()
end

-- 历练成功返回的消息
function MsgParser:MSG_GUARD_EXPERIENCE_SUCC(pkt, data)
    data.guard_id = pkt:GetLong()
    data.raw_rank = pkt:GetLong()
    data.raw_life = pkt:GetLong()
    data.raw_phy_power = pkt:GetLong()
    data.raw_mag_power = pkt:GetLong()
    data.speed = pkt:GetLong()
    data.def = pkt:GetLong()
end

-- 检查双倍点数
function MsgParser:MSG_CHECK_DOUBLE_POINT(pkt, data)
    data.task_name = pkt:GetLenString()
    data.check_point = pkt:GetLong()
end

-- 仓库
function MsgParser:MSG_STORE(pkt, data)
    data.store_type = pkt:GetLenString()
    local npcID = pkt:GetLong()
    data.count = pkt:GetShort()

    for i = 1, data.count do
        local item = {}
        local isGoon = pkt:GetChar()
        local pos = pkt:GetShort()
        if isGoon == 1 then
            if data.store_type == "normal_store"
                  or data.store_type == "card_store"
                  or data.store_type == "home_store"
                  or data.store_type == "furniture_store"
                  or data.store_type == "couple_store"
                  or data.store_type == "fasion_store"
                  or data.store_type == "custom_store"
                  or data.store_type == "effect_store"
                  or data.store_type == "follow_pet_store"
            then
                local item = {}
                item.pos = pos
                Builders:BuildItemInfo(pkt, item)
                data[i] = item
            else
                local item = {}
                data[i] = item
                data[i].pos = pos
                data[i].cardInfo = {}

                Builders:BuildPetInfo(pkt, data[i].cardInfo)

                data[i].cardInfo.skills = {}
                local count = pkt:GetShort()
                for j = 1, count, 1 do
                    local skill = {}
                    Builders:BuildSkillBasicInfo(pkt, skill)
                    data[i].cardInfo.skills[j] = skill
                end

                local count = pkt:GetShort()
                data[i].cardInfo["god_book_skill_count"] = count
                for j = 1, count do
                    data[i].cardInfo["god_book_skill_name_"..j] = pkt:GetLenString()
                    data[i].cardInfo["god_book_skill_level_"..j] = pkt:GetShort()
                    data[i].cardInfo["god_book_skill_power_"..j] = pkt:GetShort()
                    data[i].cardInfo["god_book_skill_disabled_" .. i] = pkt:GetChar()
                end

                -- 额外属性
                local extraData = {}
                Builders:BuildFields(pkt, extraData)
                for key, value in pairs(extraData) do
                    data[i].cardInfo[key] = (data[i].cardInfo[key] or 0) + value
                end
            end
        else
            data[i] = {}
            data[i].pos = pos
        end
    end
end

function MsgParser:MSG_GIFT_EQUIP_LIST(pkt, data)
    data.count = pkt:GetChar()
    data.equipId = {}
    for i = 1, data.count do
        local id = pkt:GetLong()
        table.insert(data.equipId, id)
    end
end

-- 摆摊道具消息名片
function MsgParser:MSG_MARKET_GOOD_CARD(pkt, data)
    data.id = pkt:GetLenString()
    data.status = pkt:GetChar()
    data.endTime = pkt:GetLong()
    data.item = {}
    Builders:BuildItemInfo(pkt, data.item)
end

-- 摆摊宠物消息名片
function MsgParser:MSG_MARKET_PET_CARD(pkt, data)
    data.goodId = pkt:GetLenString()
    data.status = pkt:GetChar()
    data.endTime = pkt:GetLong()
    Builders:BuildPetInfo(pkt, data)

    data.skills = {}
    local count = pkt:GetChar()
    for i = 1, count, 1 do
        local skill = {}
        skill.skill_no = pkt:GetShort()
        skill.skill_level = pkt:GetShort()
        skill.skill_nimbus = pkt:GetLong()
        data.skills[i] = skill
    end

    local count = pkt:GetChar()
    data["god_book_skill_count"] = count
    for i = 1, count do
        data["god_book_skill_name_"..i] = pkt:GetLenString()
        data["god_book_skill_level_"..i] = pkt:GetShort()
        data["god_book_skill_power_"..i] = pkt:GetShort()
		data["god_book_skill_disabled_"..i] = pkt:GetChar()
    end

		            -- 额外属性
    local extraData = {}
    Builders:BuildFields(pkt, extraData)
    for key, value in pairs(extraData) do
        data[key] = (data[key] or 0) + value
end
end

-- 集市搜索消息
function MsgParser:MSG_MARKET_SEARCH_RESULT(pkt, data)
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.name =  pkt:GetLenString()
        item.is_my_goods = pkt:GetChar()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.amount = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()
        item.item_polar = pkt:GetChar()
        table.insert(data.itemList, item)
    end

    data.is_free = pkt:GetChar()
end

-- 集市检查物品的状态
function MsgParser:MSG_MARKET_CHECK_RESULT(pkt, data)
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.id = pkt:GetLenString()
        item.status = pkt:GetChar()
        item.price = pkt:GetLong()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.amount = pkt:GetShort()
        table.insert(data.itemList, item)
    end

end

function MsgParser:MSG_TEAM_ASK_ASSURE(pkt, data)
    data.is_team_leader = pkt:GetChar() -- 是否是队长，1为队长、0为队员
    data.dlgName = pkt:GetLenString()
    data.content = pkt:GetLenString()
    data.time    = pkt:GetLong()
    data.title   = pkt:GetLenString()
    data.type    = pkt:GetLenString()
	data.para    = pkt:GetLenString()	-- 额外信息
end

-- 区组角色信息返回
function MsgParser:MSG_L_ACCOUNT_CHARS(pkt, data)
    data.distName = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.roleList = {}
    for i = 1, data.count do
        local role = {}
        role.name = pkt:GetLenString()
        role.icon = pkt:GetShort()
        role.level = pkt:GetShort()
        role.deletime = pkt:GetLong()
        table.insert(data.roleList, role)
    end
end

function MsgParser:MSG_ASK_CLIENT_SECRET(pkt, data)
    data.key = pkt:GetLenString()
end

function MsgParser:MSG_MEMBER_QUIT_TEAM(pkt, data)
	data.reason = pkt:GetLenString()
end

function MsgParser:MSG_CREATE_PARTY_SUCC(pkt, data)
    data.partyName = pkt:GetLenString()
end

function MsgParser:MSG_CHAR_ALREADY_LOGIN(pkt, data)
    data.charName = pkt:GetLenString()
end

function MsgParser:MSG_ACCOUNT_IN_OTHER_SERVER(pkt, data)
    data.result = pkt:GetChar()
    data.msg = pkt:GetLenString()
end

-- gs列表
function MsgParser:MSG_REQUEST_SERVER_STATUS(pkt, data)
    local count = pkt:GetShort()
    data.count = count

    for i = 1, count, 1 do
        data[string.format("id%d", i)] = pkt:GetShort()
        data[string.format("server%d", i)] = pkt:GetLenString()
        data[string.format("ip%d", i)] = pkt:GetLenString()
        data[string.format("status%d", i)] = pkt:GetShort()
    end
end

function MsgParser:MSG_SWITCH_SERVER(pkt, data)
    data.result = pkt:GetShort()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_SWITCH_SERVER_EX(pkt, data)
    data.result = pkt:GetShort()
    data.msg = pkt:GetLenString()
    data.gsName = pkt:GetLenString()
end

function MsgParser:MSG_BASIC_GUARD_ATTRI(pkt, data)
    Builders:BuildPetInfo(pkt, data)
end

function MsgParser:MSG_GET_NEXT_RANK_GUARD(pkt, data)
    Builders:BuildPetInfo(pkt, data)
end

function MsgParser:MSG_OTHER_LOGIN(pkt, data)
    data.result = pkt:GetShort()
    data.code = pkt:GetShort()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_C_CUR_ROUND(pkt, data)
    data.round = pkt:GetShort()
    data.animate_done = pkt:GetChar()
end

-- 改名成功断开消息
function MsgParser:MSG_OPER_RENAME(pkt, data)
    data.result = pkt:GetChar()
    data.new_name = pkt:GetLenString()
    data.msg = pkt:GetLenString()
end

-- 更新搜索购买时的物品状态
function MsgParser:MSG_STALL_UPDATE_GOODS_INFO(pkt, data)
    data.id = pkt:GetLenString()
    data.status = pkt:GetChar()
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.amount = pkt:GetShort()
end

-- 排行榜中我的信息  仅人物和宠物
function MsgParser:MSG_MY_RANK_INFO(pkt, data)
    data.rankNo = pkt:GetLong()
    data.id = pkt:GetLong()
    data.value = pkt:GetLong()
    data.iid = pkt:GetLenString()
end

-- 付费信息
function MsgParser:MSG_CHARGE_INFO(pkt, data)
    data.order_id = pkt:GetLenString()
    data.notify_uri = pkt:GetLenString()
    data.product_name = pkt:GetLenString()
    data.money = pkt:GetLong()
    data.product_id = pkt:GetLenString()
end


-- 新帮主界面显示信息
function MsgParser:MSG_NEW_PW_COMBAT_INFO(pkt, data)
    data.start_time = pkt:GetLong()         -- 开始时间
    data.rest_time = pkt:GetLong()          -- 休息时间
    data.is_security = pkt:GetChar()        -- 是否安全区
    data.stage = pkt:GetChar()        -- 赛程阶段
end

-- 帮战
function MsgParser:MSG_PW_BATTLE_INFO(pkt, data)
    data.myPartyName = pkt:GetLenString()
    data.opponentPartyName = pkt:GetLenString()
    data.myPartyPlayerCount = pkt:GetChar()
    data.opponentPartyPlayerCount = pkt:GetChar()
    data.myTotalActive = pkt:GetLong()
    data.opponentTotalActive = pkt:GetLong()

    local myPartyInfo = {}
    myPartyInfo.count = pkt:GetChar()
    for i = 1, myPartyInfo.count do
        local player = {}
        player.name = pkt:GetLenString()
        player.activeValue = pkt:GetLong()
        table.insert(myPartyInfo, player)
    end
    data.myPartyInfo = myPartyInfo

    local opponentPartyInfo = {}
    opponentPartyInfo.count = pkt:GetChar()
    for i = 1, opponentPartyInfo.count do
        local player = {}
        player.name = pkt:GetLenString()
        player.activeValue = pkt:GetLong()
        table.insert(opponentPartyInfo, player)
    end
    data.opponentPartyInfo = opponentPartyInfo
    data.myActiveValue = pkt:GetLong()
    data.myStaminaValue = pkt:GetLong()
    data.endTime = pkt:GetLong()        -- 结束时间
    data.startTime = pkt:GetLong()      -- 比赛开始时间，再次之前是准备时间
    data.needActive = pkt:GetLong()      -- 需要的活跃度
end

-- 队伍信息
function MsgParser:MSG_TEAM_DATA(pkt, data)
    data.isTeam = pkt:GetChar()
    data.count = pkt:GetChar()
    data.teamInfo = {}
    for i = 1, data.count do
        local player = {}
        player.name = pkt:GetLenString()
        player.level = pkt:GetShort()
        player.icon = pkt:GetLong()
        player.id = pkt:GetLong()
        player.vip = pkt:GetChar()
        player.zanli = pkt:GetChar()  -- 暂离为0
        table.insert(data.teamInfo, player)
    end
end

-- 登录排队信息
function MsgParser:MSG_L_WAIT_IN_LINE(pkt, data)
    data.line_name = pkt:GetLenString()
    data.expect_time = pkt:GetLong()
    data.reconnet_time = pkt:GetLong()
    data.waitCode = pkt:GetLong()
    data.count = pkt:GetLong()
    data.keep_alive = pkt:GetChar()
    data.need_wait = pkt:GetSignedChar()
    data.indsider_lv = pkt:GetSignedChar()  -- 会员等级，-1 表示数据获取中
    data.gold_coin = pkt:GetLong()    -- 表示金元宝数量
    data.status = pkt:GetChar() -- 0 表示正常，1 表示 爆满， 2 表示满。
end

-- 开始登录
function MsgParser:MSG_L_START_LOGIN(pkt, data)
    data.type = pkt:GetLenString()
    data.cookie = pkt:GetLenString()
end

-- 任务是否受到加成   目前只有帮派任务次数可能收到加成，type目前只有"party_task"
function MsgParser:MSG_ADD_TASK_ROUND(pkt, data)
    data.type = pkt:GetLenString()
    data.addRound = pkt:GetShort()
end

-- 首充奖池信息
function MsgParser:MSG_LOTTERY_INFO(pkt, data)
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    -- 本期奖池
    data.curReward = {}
    for i = 1, 6 do
        data.curReward[i] = pkt:GetLenString()
    end

    -- 全部奖池
    data.allCount = pkt:GetChar()
    data.allReward = {}
    data.allRewardField = {}
    for i = 1, data.allCount do
        data.allReward[i] = pkt:GetLenString()
        data.allRewardField[i] = pkt:GetLenString()
    end
end

-- 掌门信息
function MsgParser:MSG_MASTER_INFO(pkt, data)
    data.id = pkt:GetLong()
    data.isLeader = pkt:GetShort()
    Builders:BuildFields(pkt, data)
end

-- 特殊重连方法
function MsgParser:MSG_SPECIAL_SWITCH_SERVER(pkt, data)
    data.result = pkt:GetChar()
    data.msg = pkt:GetLenString()
end

-- 跨服换线
function MsgParser:MSG_SPECIAL_SWITCH_SERVER_EX(pkt, data)
    data.result = pkt:GetChar()
    data.msg = pkt:GetLenString()
end

-- 八仙梦境信息
function MsgParser:MSG_BAXIAN_MENGJING_INFO(pkt, data)
    data.times = pkt:GetShort()         -- 剩余次数
    data.curCheckpoint = pkt:GetShort() -- 当前关卡 从0开始
    data.openMax = pkt:GetShort()       -- 开放光卡最大值，从1开始
    data.mainState = pkt:GetChar()      -- 主任务当前状态， 0：没有主任务    1：子任务进行中  2主任务完成
    data.isOpenDlg = pkt:GetChar()      -- 是否打开对话框
end

--  累充消息，已废弃功能。
function MsgParser:MSG_RECHARGE_GIFT(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local reward = {}
        reward.index = pkt:GetChar()
        reward.flag = pkt:GetChar()
        reward.price = pkt:GetShort()
        reward.desc = pkt:GetLenString2()
        data[i] = reward
    end
end

function MsgParser:MSG_LOGIN_GIFT(pkt, data)
    data.loginDays = pkt:GetChar()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local bonus = {}
        bonus.index = pkt:GetChar()
        bonus.flag = pkt:GetChar()
        bonus.desc = pkt:GetLenString2()
        data[i] = bonus
    end
end

-- 回购
function MsgParser:MSG_BUYBACK_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.time = pkt:GetLong()
        item.id = pkt:GetLenString()
        item.count = pkt:GetLong()
        item.price = pkt:GetLong()
        item.type = pkt:GetChar()
        item.level = pkt:GetShort()
        item.skills = pkt:GetChar()
        item.islimit = pkt:GetChar()
        item.deadline = pkt:GetLong()
        item.req_level = pkt:GetShort()
        item.item_polar = pkt:GetChar()
        data.items[i] = item
    end
end

function MsgParser:MSG_BUYBACK_ITEM_CARD(pkt, data)
    data.id = pkt:GetLenString()
    data.item = {}
    Builders:BuildItemInfo(pkt, data.item)
end

function MsgParser:MSG_SYS_AUCTION_UPDATE_GOODS(pkt, data)
    data.id = pkt:GetLenString()            -- 商品Id
    data.name = pkt:GetLenString()          -- 商品名称
    data.price = pkt:GetLong()              -- 商品价格
    data.endTime = pkt:GetLong()            -- 商品拍卖时间戳
    data.goodsLevel = pkt:GetLong()         -- 商品等级
    data.sortIndex = pkt:GetLong()          -- 商品排序索引
    data.isBidder = pkt:GetChar()           -- 是否竞价者
    data.isBided = pkt:GetChar()            -- 是否竞价过
end

function MsgParser:MSG_SYS_AUCTION_GOODS_LIST(pkt, data)
    data.totalPage = pkt:GetShort()
    data.curPage = pkt:GetShort()
    data.count = pkt:GetShort()

    if data.count > 0 then
        data.goods = {}
        for i = 1, data.count do
            data.goods[i] = {}
            self:MSG_SYS_AUCTION_UPDATE_GOODS(pkt, data.goods[i])
        end
    end
end

function MsgParser:MSG_ADMIN_QUERY_ACCOUNT(pkt, data)
    data.count = pkt:GetLong()
    data.info = {}
    for i = 1, data.count do
        data.info[i] = {}
        data.info[i].account = pkt:GetLenString()
        data.info[i].name = pkt:GetLenString()
        data.info[i].ip = pkt:GetLenString()
    end
end

function MsgParser:MSG_AMDIN_NEW_PET(pkt, data)
    data.petId = pkt:GetLong()
end

function MsgParser:MSG_ADMIN_QUERY_PLAYER(pkt, data)
    data.count = pkt:GetLong()
    data.info = {}
    for i = 1, data.count do
        data.info[i] = {}
        data.info[i].server = pkt:GetLenString()
        data.info[i].account = pkt:GetLenString()
        data.info[i].name = pkt:GetLenString()
        data.info[i].gid = pkt:GetLenString()
        data.info[i].level = pkt:GetShort()
        data.info[i].polar = pkt:GetChar()
        data.info[i].mac = pkt:GetLenString()
        data.info[i].ip = pkt:GetLenString()
    end
end

-- GM查询NPC结果
function MsgParser:MSG_ADMIN_QUERY_NPC(pkt, data)
    data.count = pkt:GetShort()
    data.npc = {}
    for i = 1, data.count do
        data.npc[i] = pkt:GetLenString()
    end
end

-- GM查询进程列表
function MsgParser:MSG_PROCESS_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.process = {}
    for i = 1, data.count do
        data.process[i] = {}
        data.process[i].pid = pkt:GetLenString()
        data.process[i].name = pkt:GetLenString()
    end
end

function MsgParser:MSG_BUYBACK_PET_CARD(pkt, data)
    data.goodId = pkt:GetLenString()
    Builders:BuildPetInfo(pkt, data)

    data.skills = {}
    local count = pkt:GetChar()
    for i = 1, count, 1 do
        local skill = {}
        skill.skill_no = pkt:GetShort()
        skill.skill_level = pkt:GetShort()
        skill.skill_nimbus = pkt:GetLong()
        data.skills[i] = skill
    end

    local count = pkt:GetChar()
    data["god_book_skill_count"] = count
    for i = 1, count do
        data["god_book_skill_name_"..i] = pkt:GetLenString()
        data["god_book_skill_level_"..i] = pkt:GetShort()
        data["god_book_skill_power_"..i] = pkt:GetShort()
		data["god_book_skill_disabled_"..i] = pkt:GetChar()
    end

	            -- 额外属性
    local extraData = {}
    Builders:BuildFields(pkt, extraData)
    for key, value in pairs(extraData) do
        data[key] = (data[key] or 0) + value
end
end

function MsgParser:MSG_OPEN_URL(pkt, data)
    data.text = pkt:GetLenString()
    data.str_cancel = pkt:GetLenString()
    data.str_confirm = pkt:GetLenString()
    data.url = pkt:GetLenString()
end

-- 通知客户端玩家的寄售信息
function MsgParser:MSG_TRADING_ROLE(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.state = pkt:GetShort()                     -- 状态，在游戏中都是 STATE_SHOW 状态
    data.end_time = pkt:GetLong()                   -- 当前状态结束时间
    data.price = pkt:GetLong()                      -- 商品的价格
    data.init_price = pkt:GetLong()                      -- 初始价格
    data.change_price_count = pkt:GetShort()        -- 当天修改价格的次数 (每天最多两次)
    data.butout_price = pkt:GetLong()                      -- 一口价
    data.sell_buy_type = pkt:GetChar()              -- 出售购买类型
    data.appointee_name = pkt:GetLenString()        -- 指定交易角色名称
    data.jstr = pkt:GetLenString()
end

-- 通知客户端商品的快照信息
function MsgParser:MSG_TRADING_SNAPSHOT(pkt, data)
    data.goods_gid = pkt:GetLenString()
    data.goods_type = pkt:GetShort()
    data.snapshot_type = pkt:GetLenString()
    data.isShowCard = pkt:GetChar()
    data.content = pkt:GetLenString2()

end

-- 通知客户端自身商品快照信息
function MsgParser:MSG_TRADING_SNAPSHOT_ME(pkt, data)
    data.content = pkt:GetLenString2()
end

-- 通知客户端聚宝斋是否可用
function MsgParser:MSG_TRADING_ENABLE(pkt, data)
    data.enable = pkt:GetChar()
    data.url = pkt:GetLenString()
    data.sellCashAfterDays = pkt:GetChar()
    data.isSellCash = pkt:GetChar()
    data.recommendPrice = pkt:GetLong()
end

-- 解析聚宝物品
function MsgParser:MSG_TRADING_GOODS_INFO(pkt, data)
    data.goods_gid = pkt:GetLenString()         -- 商品 gid
    data.seller_gid = pkt:GetLenString()        -- 出售者 gid
    data.goods_name = pkt:GetLenString()        -- 商品名称
    data.goods_type = pkt:GetLong()
    data.state = pkt:GetLong()                  -- 状态   STATE_TYPE
    data.end_time = pkt:GetLong()               -- 状态结束时间戳
    data.price = pkt:GetLong()                  -- 价格
    data.icon = pkt:GetLong()                   -- 图标
    data.level = pkt:GetLong()                  -- 等级

    data.butout_price = pkt:GetLong()                  -- 一口价
    data.sell_buy_type = pkt:GetChar()                 -- 出售购买类型
    data.appointee_name = pkt:GetLenString()                 -- 指定交易角色名称
    data.appointee_gid = pkt:GetLenString()                 -- 竞拍者 gid或者指定交易玩家gid

    data.para = pkt:GetLenString()              -- 其他，用于json解析

end

-- 通知聚宝斋收藏列表
function MsgParser:MSG_TRADING_FAVORITE_LIST(pkt, data)
    data.list_type = pkt:GetChar()
    data.count = pkt:GetChar()
    data.goods = {}
    for i = 1, data.count do
        data.goods[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data.goods[i])
        data.goods[i].list_type = data.list_type
    end
end

-- 通知聚宝斋商品列表
function MsgParser:MSG_TRADING_GOODS_LIST(pkt, data)
    data.list_type = pkt:GetChar()
    data.goods_type = pkt:GetShort()
    data.key = pkt:GetLong()
    data.is_begin = pkt:GetChar()               -- 1 为开始
    data.is_end = pkt:GetChar()               -- 1 结束
    data.count = pkt:GetChar()
    data.goods = {}
    for i = 1, data.count do
        data.goods[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data.goods[i])
    end

    data.select_gid = pkt:GetLenString() -- 选中的商品 gid
end

-- 通知客户端出售金钱的信息
function MsgParser:MSG_TRADING_SELL_CASH(pkt, data)
    data.standardPrice = pkt:GetLong()
    data.count = pkt:GetChar()
    data.goods = {}
    for i = 1, data.count do
        data.goods[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data.goods[i])
    end
end

-- 通知客户端收藏的商品gid
function MsgParser:MSG_TRADING_FAVORITE_GIDS(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = pkt:GetLenString()
    end
end

-- ==============
-- 通知客户端玩家的单个商品
function MsgParser:MSG_TRADING_GOODS_UPDATE(pkt, data)
    self:MSG_TRADING_GOODS_INFO(pkt,data)
end

-- 通知客户端玩家的寄售商品
function MsgParser:MSG_TRADING_GOODS_MINE(pkt, data)
    data.count = pkt:GetChar()

    for i = 1, data.count do
        data[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt,data[i])

        data[i].init_price = pkt:GetLong()
        data[i].change_price_count = pkt:GetShort()        -- 当天修改价格的次数 (每天最多两次)
    end
end

-- 通知客户端玩家的单个商品
function MsgParser:MSG_TRADING_GOODS_MINE_UPDATE(pkt, data)
    self:MSG_TRADING_GOODS_INFO(pkt,data)

    data.init_price = pkt:GetLong()
    data.change_price_count = pkt:GetShort()
end

-- 移除货架商品
function MsgParser:MSG_TRADING_GOODS_MINE_REMOVE(pkt, data)
    data.goods_gid = pkt:GetLenString()         -- 商品 gid
end

-- 通知客户端操作商品结果
-- op_type：sell_goods 、 cancel_trading 、 change_price 、 continue_sell
function MsgParser:MSG_TRADING_OPER_RESULT(pkt, data)
    data.goods_gid = pkt:GetLenString()         -- 商品 gid
    data.op_type = pkt:GetLenString()         -- 商品 gid
end
-- ==============

-- 目前仅用做GM监听时候清空信息
function MsgParser:MSG_LOGIN_DONE(pkt, data)
    data.name = pkt:GetLenString()
    data.para = pkt:GetLenString()
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_OPEN_SHIDWZDLG(pkt, data)
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count do
        local memberInfo = {}
        memberInfo["gid"] = pkt:GetLenString()
        memberInfo["name"] = pkt:GetLenString()
        memberInfo["level"] = pkt:GetShort()
        memberInfo["polar"] = pkt:GetChar()
        memberInfo["icon"] = pkt:GetShort()
        data[i] = memberInfo
    end
end

function MsgParser:MSG_START_GATHER(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.icon = pkt:GetShort()
    data.word = pkt:GetLenString()
    data.gather_style = pkt:GetLenString()
end

function MsgParser:MSG_GATHER(pkt, data)
    data.id = pkt:GetLong()
    data.status = pkt:GetChar()
end

function MsgParser:MSG_FLOAT_DIALOG(pkt, data)
    data.content = pkt:GetLenString2()
end

function MsgParser:MSG_PHONE_VERIFY_CODE(pkt, data)
    data.type = pkt:GetChar()
    --[[
    #define REQUEST_INIT_PHONE 1 // 首次认证手机
    #define REQUEST_UPDATE_PHONE 2 // 再次认证手机
    #define REQUEST_CHANGE_PHONE_1 3 // 更换认证手机第一次验证
    #define REQUEST_CHANGE_PHONE_2 4 // 更换认证手机第二次验证
    #define REQUEST_INIT_IDENTITY 5 // 实名认证
    --]]
end

function MsgParser:MSG_OPEN_SMS_VERIFY_DLG(pkt, data)
    data.fuzzy_phone = pkt:GetLenString()
    data.last_take_code_time = pkt:GetLong()
end

function MsgParser:MSG_NOTIFY_SECURITY_CODE(pkt, data)
    data.choices = { pkt:GetLong(), pkt:GetLong(), pkt:GetLong(), pkt:GetLong() }
    data.answer = pkt:GetLenString()
    data.finishTime = pkt:GetLong()
    data.triggerTime = pkt:GetLong()
end

function MsgParser:MSG_PREVIEW_SPECIAL_SKILL(pkt, data)
    data.petId = pkt:GetLong()
    data.count = pkt:GetSignedChar()
    data.skills = {}
    if data.count == -1 then return end
    for i = 1, data.count do
        local skillName = pkt:GetLenString()
        table.insert(data.skills, skillName)
    end
end

function MsgParser:MSG_CREATE_NEW_CHAR(pkt, data)
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
end

function MsgParser:MSG_ACTIVITY_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.activityList = {}
    for i = 1, data.count do
        local activity = {}
        activity.name = pkt:GetLenString()
        activity.startTime = pkt:GetLong()
        activity.endTime = pkt:GetLong()
        data.activityList[activity.name] = activity
    end
end

function MsgParser:MSG_ACTIVITY_DATA_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.activityList = {}
    for i = 1, data.count do
        local activity = {}
        activity.key = pkt:GetLenString()
        activity.para = pkt:GetLenString()
        data.activityList[activity.key] = activity
    end
end

function MsgParser:MSG_MEMBER_NOT_IN_PARTY(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_BE_ADD_FRIEND(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.setting = pkt:GetLong()
end

-- 是否愿意接受变身卡
function MsgParser:MSG_REQUEST_CHANGE_LOOK(pkt, data)
    data.tip = pkt:GetLenString()
    data.keepTime = pkt:GetLong()
end

function MsgParser:MSG_CL_CARD_INFO(pkt, data)
    data.size = pkt:GetShort()
    data.max_size = pkt:GetShort()
    data.top_size = pkt:GetShort()
    data.top_id = {}
    for i = 1,data.top_size do
        data.top_id[i] = pkt:GetLong()
    end
    data.history_size = pkt:GetShort()
    data.history_val = {}
    for i = 1,data.history_size do
        data.history_val[i] = pkt:GetLong()
    end
end

function MsgParser:MSG_ITEM_APPLY_FAIL(pkt, data)
    data.pos = pkt:GetChar()
    data.amount = pkt:GetShort()
end

function MsgParser:MSG_SPECIAL_SERVER(pkt, data)
    data.count = pkt:GetShort()
    data.serverIdList = {}

    for i = 1, data.count do
        data.serverIdList[i] = pkt:GetShort()
    end

    data.curLoginServerId = pkt:GetShort()
end

function MsgParser:MSG_REBUILD_PET_RESULT(pkt, data)
    data.flag = pkt:GetChar()
end

-- 今日统计
function MsgParser:MSG_DAILY_STATS(pkt, data)
    data.exp = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.tao_point = pkt:GetLong()
    data.mon_tao = pkt:GetLong()
    data.mon_tao_ex = pkt:GetLong()
    data.pot = pkt:GetLong()
    data.death = pkt:GetLong()
    data.onLine_time = pkt:GetLong()
    data.shuadaoTimes = pkt:GetLong()
    data.org_icon = pkt:GetLong()
    data.level = pkt:GetShort()
    data.name = pkt:GetLenString()
    data.party_name = pkt:GetLenString()
end

-- 聚宝交易记录
function MsgParser:MSG_TRADING_RECORD(pkt, data)
    data.buy_count = pkt:GetShort()
    data.buyInfo = {}
    for i = 1, data.buy_count do
        data.buyInfo[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data.buyInfo[i])
    end

    data.sell_count = pkt:GetShort()
    data.sellInfo = {}
    for i = 1, data.sell_count do
        data.sellInfo[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data.sellInfo[i])
    end
end

---- 珍宝集市相关指令
function MsgParser:MSG_GOLD_STALL_GOODS_LIST(pkt, data)
    data.totalPage = pkt:GetShort()
    data.cur_page = pkt:GetShort()
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.name =  pkt:GetLenString()
        item.is_my_goods = pkt:GetChar()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()         -- json 格式的复用字段中增加 deposit_state; 支付定金状态，0 - 未支付，1 - 已支付，2 - 不能支付，3 - 表示已经退还定金，4 - 表示已经没收定金
        item.item_polar = pkt:GetChar()
        item.buyout_price = pkt:GetLong()
        item.sell_type = pkt:GetChar()
        item.appointee_name = pkt:GetLenString()
   --     item.appointee_account = pkt:GetLenString()

        table.insert(data.itemList, item)
    end

    data.path_str = pkt:GetLenString()  -- 打开集市界面的路径
    data.select_gid = pkt:GetLenString()  -- 选中的商品的 gid
    data.sell_stage = pkt:GetChar()  -- 出售阶段 1 公示 2 逛摊
	data.sort_key = pkt:GetLenString()		-- 排序类型 "price" 按价格、"start_time" 按上架时间 (公示时间)
	data.is_descending = pkt:GetChar()		-- 是否降序
end

function MsgParser:MSG_GOLD_STALL_UPDATE_GOODS_INFO(pkt, data)
    data.id = pkt:GetLenString()
    data.status = pkt:GetShort()
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
end

function MsgParser:MSG_GOLD_STALL_GOODS_STATE(pkt, data)
    data.is_from_client = pkt:GetChar()
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.id = pkt:GetLenString()
        item.status = pkt:GetChar()

        item.sell_type = pkt:GetChar()

        item.price = pkt:GetLong()

        item.buyout_price = pkt:GetLong()

        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.appointee_name = pkt:GetLenString()
        item.para_str = pkt:GetLenString()
        table.insert(data.itemList, item)
    end

end

function MsgParser:MSG_GOLD_STALL_MINE(pkt, data)
    data.dealNum = pkt:GetShort()
    data.sellCash = tonumber(pkt:GetLenString())
    data.stallTotalNum = pkt:GetShort()
    data.stallNum = pkt:GetShort()
    data.items = {}
    for i = 1, data.stallNum do
        local item = {}
        item.name = pkt:GetLenString()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.pos = pkt:GetShort()
        item.status = pkt:GetShort()        -- 1 公示，2出售 ，3下架 0不在
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()     -- json 格式的复用字段中增加 deposit_state; 支付定金状态，0 - 未支付，1 - 已支付，2 - 不能支付，3 - 表示已经退还定金，4 - 表示已经没收定金
        item.item_polar = pkt:GetChar()
        item.cg_price_count = pkt:GetChar()
        item.init_price = pkt:GetLong()
        item.flag_num = pkt:GetLong()    -- 商品标记信息，目前用于记录是否是正常超时下架
        item.stall_item_type = pkt:GetChar()

        item.buyout_price = pkt:GetLong()
        item.sell_type = pkt:GetChar()
        item.appointee_name = pkt:GetLenString()

    --    item.appointee_account = pkt:GetLenString()
        table.insert(data.items, item)
    end
end

function MsgParser:MSG_GOLD_STALL_RECORD(pkt, data)
    data.buyCount = pkt:GetShort()
    data.buyList = {}
    for i = 1, data.buyCount do
        local item = {}
        item.name = pkt:GetLenString()
        item.level = pkt:GetShort()
        item.time = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.item_polar = pkt:GetChar()
        item.stall_item_type = pkt:GetChar()
        item.record_id = pkt:GetLenString()
        item.buy_type = pkt:GetChar()
        table.insert(data.buyList, item)
    end

    data.sellCout = pkt:GetShort()
    data.sellList = {}
    for i = 1, data.sellCout do
        local item = {}
        item.name = pkt:GetLenString()
        item.level = pkt:GetShort()
        item.time = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.req_level = pkt:GetShort()
        item.item_polar = pkt:GetChar()
        item.stall_item_type = pkt:GetChar()
        item.record_id = pkt:GetLenString()
        item.buy_type = pkt:GetChar()
        table.insert(data.sellList, item)
    end
end

function MsgParser:MSG_GOLD_STALL_SEARCH_GOODS(pkt, data)
    data.count = pkt:GetShort()
    data.itemList = {}

    for i = 1, data.count do
        local item = {}
        item.name =  pkt:GetLenString()
        item.is_my_goods = pkt:GetChar()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString() -- json 格式的复用字段中增加 deposit_state; 支付定金状态，0 - 未支付，1 - 已支付，2 - 不能支付，3 - 表示已经退还定金，4 - 表示已经没收定金
        item.item_polar = pkt:GetChar()
        item.buyout_price = pkt:GetLong()
        item.sell_type = pkt:GetChar()
        item.appointee_name = pkt:GetLenString()

     --   item.appointee_account = pkt:GetLenString()
        table.insert(data.itemList, item)
    end
end

function MsgParser:MSG_GOLD_STALL_GOODS_INFO_PET(pkt, data)
    self:MSG_MARKET_PET_CARD(pkt, data)
end

function MsgParser:MSG_GOLD_STALL_GOODS_INFO_ITEM(pkt, data)
	self:MSG_MARKET_GOOD_CARD(pkt, data)
end

function MsgParser:MSG_MEMBER_NOT_IN_PARTY(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_OPEN_GUESS_DIALOG(pkt, data)
    data.flag = pkt:GetChar()
    data.money = pkt:GetLong()
    data.surlus = tonumber(pkt:GetLenString())
    data.overflow = tonumber(pkt:GetLenString())
    data.amount = pkt:GetLong()
    data.choice = pkt:GetChar()
    data.prize = pkt:GetChar()
    data.leftCount = pkt:GetChar()
end

function MsgParser:MSG_REFINE_PET_RESULT(pkt, data)
    data.result = pkt:GetChar()
end

function MsgParser:MSG_PLAY_SOUND(pkt, data)
    data.sound = pkt:GetLenString()
end

-- 安全锁相关beg
function MsgParser:MSG_SAFE_LOCK_INFO(pkt, data)
    data.has_pwd = pkt:GetChar()
    data.isReleaseLock = pkt:GetChar() -- 当前是否验证
    data.reset_start = pkt:GetLong()
    data.reset_end = pkt:GetLong()
    data.reset_days = pkt:GetLong()
end

function MsgParser:MSG_SAFE_LOCK_OPEN_SET(pkt, data)
    data.key = pkt:GetLenString()
end

function MsgParser:MSG_SAFE_LOCK_OPEN_CHANGE(pkt, data)
    data.key = pkt:GetLenString()
end

function MsgParser:MSG_SAFE_LOCK_OPEN_UNLOCK(pkt, data)
    data.key = pkt:GetLenString()
    data.error_count_max = pkt:GetShort()
    data.error_count = pkt:GetShort()
end

function MsgParser:MSG_SAFE_LOCK_OPEN_BAN(pkt, data)
    data.ban_time = pkt:GetLong()
    data.error_count_max = pkt:GetShort()
end
-- 安全锁相关end

function MsgParser:MSG_PREVIEW_PET_EVOLVE(pkt, data)
    data.mainPetId = pkt:GetLong()
    data.otherPetId = pkt:GetLong()
    data.lifeMax = pkt:GetLong()
    data.manaMax = pkt:GetLong()
    data.phyMax = pkt:GetLong()
    data.magMax = pkt:GetLong()
    data.speedMax = pkt:GetLong()
    data.defMax = pkt:GetLong()
    data.lifeGrow = pkt:GetShort()
    data.manaGrow = pkt:GetShort()
    data.speedGrow = pkt:GetShort()
    data.phyGrow = pkt:GetShort()
    data.magGrow = pkt:GetShort()
end


-- 师徒系统相关====BEGIN
function MsgParser:MSG_SEARCH_MASTER_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.userInfo = {}
    for i = 1, data.count do
        local userInfo = {}
        userInfo.gid = pkt:GetLenString()
        userInfo.name = pkt:GetLenString()
        userInfo.level = pkt:GetChar()
        userInfo.icon = pkt:GetLong()
        userInfo.weaponIcon = pkt:GetLong()
        userInfo.suitIcon = pkt:GetLong()
        userInfo["upgrade/type"] = pkt:GetChar()
        userInfo.polar = pkt:GetChar()
        userInfo.party = pkt:GetLenString()
        userInfo.isOnline = pkt:GetChar()
        userInfo.message = pkt:GetLenString()
        userInfo.isApply = pkt:GetChar()
        userInfo.oldStudent = pkt:GetLong()
        userInfo.totalStudentCount = pkt:GetChar()
        table.insert(data.userInfo, userInfo)
    end
end

function MsgParser:MSG_SEARCH_APPRENTICE_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.userInfo = {}
    for i = 1, data.count do
        local userInfo = {}
        userInfo.gid = pkt:GetLenString()
        userInfo.name = pkt:GetLenString()
        userInfo.level = pkt:GetChar()
        userInfo.icon = pkt:GetLong()
        userInfo.weaponIcon = pkt:GetLong()
        userInfo.suitIcon = pkt:GetLong()
        userInfo["upgrade/type"] = pkt:GetChar()
        userInfo.polar = pkt:GetChar()
        userInfo.party = pkt:GetLenString()
        userInfo.isOnline = pkt:GetChar()
        userInfo.message = pkt:GetLenString()
        userInfo.isApply = pkt:GetChar()
        table.insert(data.userInfo, userInfo)
    end
end

function MsgParser:MSG_REQUEST_APPENTICE_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.userInfo = {}
    for i = 1, data.count do
        local userInfo = {}
        userInfo.gid = pkt:GetLenString()
        userInfo.name = pkt:GetLenString()
        userInfo.level = pkt:GetChar()
        userInfo.icon = pkt:GetLong()
        userInfo.weaponIcon = pkt:GetLong()
        userInfo.suitIcon = pkt:GetLong()
        userInfo["upgrade/type"] = pkt:GetChar()
        userInfo.polar = pkt:GetChar()
        userInfo.party = pkt:GetLenString()
        userInfo.isOnline = pkt:GetChar()
        userInfo.message = pkt:GetLenString()
        userInfo.oldStudent = pkt:GetLong()
        userInfo.totalStudentCount = pkt:GetChar()
        userInfo.requestType = pkt:GetChar()   -- 3申请成为某人师父，4申请成为某人徒弟
        table.insert(data.userInfo, userInfo)
    end
end

function MsgParser:MSG_NOTIFY_CHUSHI_LEVEL(pkt, data)
    data.chushiLevel = pkt:GetChar()
end

function MsgParser:MSG_MY_APPENTICE_INFO(pkt, data)
    data.studentCountThisMonth = pkt:GetChar()
    data.count = pkt:GetChar()
    data.userInfo = {}
    for i = 1, data.count do
        local userInfo = {}
        userInfo.isMaster = pkt:GetChar()
        userInfo.gid = pkt:GetLenString()
        userInfo.name = pkt:GetLenString()
        userInfo.level = pkt:GetChar()
        userInfo.icon = pkt:GetLong()
        userInfo.weaponIcon = pkt:GetLong()
        userInfo.suitIcon = pkt:GetLong()
        userInfo["upgrade/type"] = pkt:GetChar()
        userInfo.unOnlineTime = pkt:GetLong()
        userInfo.masterTime = pkt:GetLong()
        userInfo.friend = pkt:GetLong()
        userInfo.oldStudent = pkt:GetLong() -- 出师数
        userInfo.taskTimes = pkt:GetChar() -- 完成任务数

        userInfo.shouyeCount = pkt:GetChar() -- 授业任务个数
        userInfo.shouyeInfo = {}
        for i = 1, userInfo.shouyeCount do
            local info = {}
            info.index = pkt:GetChar() --授业任务索引
            info.completeTimes = pkt:GetChar() -- 完成次数
            table.insert(userInfo.shouyeInfo, info)
        end

        table.insert(data.userInfo, userInfo)
    end

    data.alreadyCompleteCdsyTask = pkt:GetChar()
end

function MsgParser:MSG_REQUEST_APPRENTICE_SUCCESS(pkt, data)
    data.type = pkt:GetChar()
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_MY_SEARCH_APPRENTICE_MESSAGE(pkt, data)
    data.isRegist = pkt:GetChar()
    data.message = pkt:GetLenString()
end

function MsgParser:MSG_MY_SEARCH_MASTER_MESSAGE(pkt, data)
    data.isRegist = pkt:GetChar()
    data.message = pkt:GetLenString()
end

function MsgParser:MSG_MY_MASTER_MESSAGE(pkt, data)
    data.message = pkt:GetLenString()
end

function MsgParser:MSG_NOTIFY_RECORD_APPRENTICE(pkt, data)
    data.type = pkt:GetChar()
end

function MsgParser:MSG_CDSY_TODAY_TASK(pkt, data)
    data.count = pkt:GetChar()
    data.task = {}
    for i = 1, data.count do
        data.task[i] = pkt:GetChar()
    end
end

-- 师徒系统相关====END

function MsgParser:MSG_DEMAND_WANTED_TASK(pkt, data)
    data.count = pkt:GetChar()
    data.teamList = {}
    for i = 1, data.count do
        local member = {}
        member.icon = pkt:GetShort()
        member.level = pkt:GetShort()
        member.name = pkt:GetLenString()
        member.vipType = pkt:GetChar()
        member.times = pkt:GetChar()
        member.status = pkt:GetChar()
        data.teamList[member.name] = member
    end
end

function MsgParser:MSG_COUPLE_INFO(pkt, data)
    data.flag = pkt:GetChar()
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.friend = pkt:GetLong()
    data.icon = pkt:GetLong()
end

function MsgParser:MSG_CLEAR_ALL_CHAR(pkt, data)
    data.id = pkt:GetLong()
    data.mapId = pkt:GetLong()
end

function MsgParser:MSG_OPEN_NANHWS_DIALOG(pkt, data)
    data.card_name = pkt:GetLenString()
    data.pay_count = pkt:GetLong()
    data.left_num = pkt:GetShort()
end

function MsgParser:MSG_SUBMIT_EQUIP(pkt, data)
    data.prompt = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.equipList = {}
    for i = 1, data.count do
        local equip = {}
        equip.id = pkt:GetLong()
        table.insert(data.equipList, equip)
    end
end

function MsgParser:MSG_STOP_AUTO_WALK(pkt, data)
    data.task_name = pkt:GetLenString()
end
function MsgParser:MSG_CHAR_CHANGE_SEX(pkt, data)
    data.gender = pkt:GetShort()
end

function MsgParser:MSG_ADD_FRIEND_VERIFY(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.setting_flag = pkt:GetLong()
end
function MsgParser:MSG_APPLY_FRIEND_ITEM_RESULT(pkt, data)
    data.result = pkt:GetChar()
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_APPLY_QINGYUANHE_RESULT(pkt, data)
    data.result = pkt:GetChar()
end

function MsgParser:MSG_OPEN_TIQIN_DLG(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local member = {}
        member.gender = pkt:GetChar()
        member.org_icon = pkt:GetShort()
        member.weapon_icon = pkt:GetShort()
        member.suit_icon = pkt:GetLong()
        member["upgrade/type"] = pkt:GetChar()
        member.name = pkt:GetLenString()
        member.light_effect_count = pkt:GetChar()
        member.light_effect = {}
        for i = 1, member.light_effect_count do
            local effect = pkt:GetLong()
            table.insert(member.light_effect, effect)
        end
        data[i] = member
    end
end

function MsgParser:MSG_WEDDING_NOW(pkt, data)
    data.result = pkt:GetChar()
    data.isPlayWeddingMusic = pkt:GetChar()
end

function MsgParser:MSG_WEDDING_LIST(pkt, data)
    data.time = pkt:GetLong()
    data.maleName = pkt:GetLenString()
    data.feMaleName = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.price = pkt:GetLong()
        table.insert(data.items, item)
    end
end

function MsgParser:MSG_BANNER(pkt, data)
    data.type = pkt:GetChar()
    data.title = pkt:GetLenString()
    data.content = pkt:GetLenString()
    data.time = pkt:GetLong()
    data.order = pkt:GetShort()
end

function MsgParser:MSG_WEDDING_ALL_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.items = {}
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.price = pkt:GetLong()
        table.insert(data.items, item)
    end

    data.cost_type = pkt:GetLenString()
    data.discount = pkt:GetLong()
end

function MsgParser:MSG_UPDATE_MOVE_SPEED(pkt, data)
    data.id = pkt:GetLong()
    data.moveSpeedPercent = pkt:GetSignedChar()
end

function MsgParser:MSG_NEW_ITEM_INFO(pkt, data)
    data.itemStr = pkt:GetLenString2()
end

function MsgParser:MSG_NEW_APPELLATION_INFO(pkt, data)
    data.str = pkt:GetLenString2()
end

function MsgParser:MSG_NEW_ACTIVITY_INFO(pkt, data)
    data.actType = pkt:GetLenString()
    data.actInfo = pkt:GetLenString2()
end

function MsgParser:MSG_TASK_STATUS_INFO(pkt, data)
    data.taskName = pkt:GetLenString()
    data.status = pkt:GetChar()
end

-- 赠送相关
function MsgParser:MSG_REQUEST_GIVING(pkt, data)
    data.giver = {}
    data.giver.name = pkt:GetLenString()
    data.giver.level = pkt:GetShort()
    data.giver.icon = pkt:GetLong()

    data.receive = {}
    data.receive.name = pkt:GetLenString()
    data.receive.level = pkt:GetShort()
    data.receive.icon = pkt:GetLong()
end

function MsgParser:MSG_OPEN_GIVING_WINDOW(pkt, data)
    data.giver = {}
    data.giver.name = pkt:GetLenString()
    data.giver.icon = pkt:GetLong()
    data.giver["upgrade/type"] = pkt:GetChar()
    data.giver.leftTimes = pkt:GetChar()
    data.giver.light_effect_count = pkt:GetChar()
    data.giver.light_effect = {}
    for i = 1, data.giver.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.giver.light_effect, effect)
    end

    data.receiver = {}
    data.receiver.name = pkt:GetLenString()
    data.receiver.icon = pkt:GetLong()
    data.receiver["upgrade/type"] = pkt:GetChar()
    data.receiver.leftTimes = pkt:GetChar()
    data.receiver.light_effect_count = pkt:GetChar()
    data.receiver.light_effect = {}
    for i = 1, data.receiver.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.receiver.light_effect, effect)
    end
end

function MsgParser:MSG_UPDATE_GIVING_ITEM(pkt, data)
    data.itemType = pkt:GetChar()
    if data.itemType == 0 then
        -- daoju
        data.item = {}
        Builders:BuildItemInfo(pkt, data.item)
    else
        data.item = {}
        Builders:BuildPetInfo(pkt, data.item)

        data.item.skills = {}
        local count = pkt:GetShort()
        for i = 1, count, 1 do
            local skill = {}
            Builders:BuildSkillBasicInfo(pkt, skill)
            data.item.skills[i] = skill
    end

        local count = pkt:GetShort()
        data.item["god_book_skill_count"] = count
        for i = 1, count do
            data.item["god_book_skill_name_"..i] = pkt:GetLenString()
            data.item["god_book_skill_level_"..i] = pkt:GetShort()
            data.item["god_book_skill_power_"..i] = pkt:GetShort()
            data.item["god_book_skill_disabled_" .. i] = pkt:GetChar()
        end

        -- 额外属性
        local extraData = {}
        Builders:BuildFields(pkt, extraData)
        for key, value in pairs(extraData) do
            data.item[key] = (data.item[key] or 0) + value
        end
    end
end

function MsgParser:MSG_COMPLETE_GIVING(pkt, data)
    data.isOK = pkt:GetChar()
end

function MsgParser:MSG_ANIMATE_IN_UI(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetLong()
    data.order = pkt:GetLong()
    data.locate = pkt:GetLong()
    data.loops = pkt:GetLong()
    data.interval = pkt:GetLong()
    data.during = pkt:GetLong()
end

function MsgParser:MSG_ANIMATE_IN_MAP(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetLong()
    data.x = pkt:GetLong()
    data.y = pkt:GetLong()
    data.loops = pkt:GetLong()
    data.interval = pkt:GetLong()
    data.during = pkt:GetLong()
end

function MsgParser:MSG_ANIMATE_IN_CHAR(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetLong()
    data.order = pkt:GetLong()
    data.pos = pkt:GetChar()
    data.loops = pkt:GetLong()
    data.interval = pkt:GetLong()
    data.during = pkt:GetLong()
end

function MsgParser:MSG_ANIMATE_IN_CHAR_LAYER(pkt, data)
    data.id = pkt:GetLong()
    data.effect_no = pkt:GetLong()
    data.order = pkt:GetLong()
    -- data.pos = pkt:GetChar()
    data.x = pkt:GetLong()
    data.y = pkt:GetLong()
    data.loops = pkt:GetLong()
    data.interval = pkt:GetLong()
    data.during = pkt:GetLong()
end

function MsgParser:MSG_SUIJI_RICHANGE_FANBEI(pkt, data)
    data.count = pkt:GetChar()
    data.doubleAct = {}
    for i = 1, data.count do
        data.doubleAct[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_REMOVE_ANIMATE(pkt, data)
    data.id = pkt:GetLong()
    data.type = pkt:GetLong()
    data.effect_no = pkt:GetLong()
end

function MsgParser:MSG_SHENGJI_KUANGHUAN_RATE(pkt, data)
    data.reward_rate = pkt:GetShort()
end

function MsgParser:MSG_INSIDER_DISCOUNT_INFO(pkt, data)
    data.dsicountMonthPrice = pkt:GetLong()
    data.dsicountQuaterPrice = pkt:GetLong()
    data.dsicountYearPrice = pkt:GetLong()
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
end

function MsgParser:MSG_ASK_SUBMIT_ZIKA(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_FRIEND_GROUP_LIST(pkt, data)
    data.count = pkt:GetLong()
    data.groups = {}
    for i = 1, data.count do
        local group = {}
        group.groupId = pkt:GetLenString()
        group.name = pkt:GetLenString()
        table.insert(data.groups, group)
    end
end

function MsgParser:MSG_FRIEND_MOVE_CHAR(pkt, data)
    data.fromId = pkt:GetLenString()
    data.toId = pkt:GetLenString()
    data.count = pkt:GetLong()
    data.gidList = {}
    for i = 1, data.count do
        local gid = pkt:GetLenString()
        table.insert(data.gidList, gid)
    end
end

function MsgParser:MSG_FRIEND_ADD_GROUP(pkt, data)
    data.groupId = pkt:GetLenString()
    data.name = pkt:GetLenString()
end

function MsgParser:MSG_FRINED_REMOVE_GROUP(pkt, data)
    data.groupId = pkt:GetLenString()
end

function MsgParser:MSG_FRIEND_REFRESH_GROUP(pkt, data)
    data.groupId = pkt:GetLenString()
    data.name = pkt:GetLenString()
end

function MsgParser:MSG_CHAT_GROUP(pkt, data)
    data.groupId = pkt:GetLenString()

    -- 用来储存群基本相关信息
    data.info = {}
    data.info.group_id = data.groupId
    Builders:BuildFields(pkt, data.info)

    data.count = pkt:GetLong()
    data.members = {}
    for i = 1, data.count do
        local member = {}
        -- 用来储存群基本相关信息
        member.group_id = data.groupId
        member.member_gid = pkt:GetLenString()
        Builders:BuildFields(pkt, member)
        table.insert(data.members, member)
    end
end

function MsgParser:MSG_CHAT_GROUP_PARTIAL(pkt, data)
    self:MSG_CHAT_GROUP(pkt, data)
end

function MsgParser:MSG_CHAT_GROUP_MEMBERS(pkt, data)
    data.group_id = pkt:GetLenString()
    data.member_gid = pkt:GetLenString()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_DELETE_CHAT_GROUP(pkt, data)
    data.groupId = pkt:GetLenString()
end

function MsgParser:MSG_REMOVE_CHAT_GROUP_MEMBER(pkt, data)
    data.groupId = pkt:GetLenString()
    data.memberId = pkt:GetLenString()
end

function MsgParser:MSG_FRIEND_MEMO(pkt, data)
    data.count = pkt:GetShort()
    data.memos = {}
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.memo = pkt:GetLenString()
        table.insert(data.memos, info)
    end
end

function MsgParser:MSG_MOONCAKE_GAMEBLING_RESULT(pkt, data)
    data.bonus = pkt:GetSignedChar()
end

-- 节日活动（目前只有国庆）
function MsgParser:MSG_FESTIVAL_GIFT_INFO(pkt, data)
    data.introduce = pkt:GetLenString() -- 将活动结束
    data.time = pkt:GetLong()      -- 截止时间
    data.loginTime = 0                  -- MSG_MY_FESTIVAL_GIFT_INFO中赋值
    data.active = 0                     -- MSG_MY_FESTIVAL_GIFT_INFO中赋值
    data.getedBoxIndex = 0              -- MSG_MY_FESTIVAL_GIFT_INFO中赋值
    data.giftCount = pkt:GetChar()
    data.gifts = {}
    for i = 1, data.giftCount do
        local info = {}
        info.name = pkt:GetLenString() -- 礼包名
        info.buyTimeMax = pkt:GetChar()
        info.reward = pkt:GetLenString() -- 礼包内容
        info.costType = pkt:GetChar() -- -- 1金钱，2银元宝3金元宝4活跃5登入天数
        info.curPrice = pkt:GetShort()
        info.isNeedVip = pkt:GetChar()
        info.orgType = pkt:GetChar()
        info.orgPrice = pkt:GetShort()

        info.buyTimeCur = 0                 -- MSG_MY_FESTIVAL_GIFT_INFO中赋值
        table.insert(data.gifts, info)
    end

    data.boxCount = pkt:GetChar()
    data.boxs = {}
    for i = 1, data.boxCount do
        local info = {}
        info.boxIndex = pkt:GetChar()
        info.openCount = pkt:GetChar()
        info.boxIntro = pkt:GetLenString()
        info.isGeted = 0
        table.insert(data.boxs, info)
    end
end

function MsgParser:MSG_NOTIFY_END_FESTIVAL_GIFT(pkt, data)
    data.dlgName = pkt:GetLenString()
    data.tips = pkt:GetLenString()
end

function MsgParser:MSG_OPEN_LIVENESS_LOTTERY(pkt, data)
    data.alas = pkt:GetLenString()
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.level = pkt:GetShort()
    data.activeValue = pkt:GetShort()
end

function MsgParser:MSG_WRITE_YYQ_RESULT(pkt, data)
    data.result = pkt:GetChar()
end

function MsgParser:MSG_SEARCH_YYQ_RESULT(pkt, data)
    data.update_time = pkt:GetLenString()
    data.yyq_no = pkt:GetLong()
    data.from_gid = pkt:GetLenString()
    data.from_name = pkt:GetLenString()
    data.to_gid = pkt:GetLenString()
    data.to_name = pkt:GetLenString()
    data.yyq_type = pkt:GetChar()
    data.text = pkt:GetLenString()
    data.praise = pkt:GetLong()
    data.tread = pkt:GetLong()
    data.is_show_name = pkt:GetChar()
end

function MsgParser:MSG_YYQ_PAGE(pkt, data)
    data.curPage = pkt:GetLong()
    data.allPage = pkt:GetLong()
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local tab = {}
        tab.update_time = pkt:GetLenString()
        tab.yyq_no = pkt:GetLong()
        tab.from_gid = pkt:GetLenString()
        tab.from_name = pkt:GetLenString()
        tab.to_gid = pkt:GetLenString()
        tab.to_name = pkt:GetLenString()
        tab.yyq_type = pkt:GetChar()
        tab.text = pkt:GetLenString()
        tab.praise = pkt:GetLong()
        tab.tread = pkt:GetLong()
        tab.is_show_name = pkt:GetChar()
        table.insert(data, tab)
    end
end

function MsgParser:MSG_REQUEST_MY_YYQ_RESULT(pkt, data)
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local tab = {}
        tab.update_time = pkt:GetLenString()
        tab.yyq_no = pkt:GetLong()
        tab.from_gid = pkt:GetLenString()
        tab.from_name = pkt:GetLenString()
        tab.to_gid = pkt:GetLenString()
        tab.to_name = pkt:GetLenString()
        tab.yyq_type = pkt:GetChar()
        tab.text = pkt:GetLenString()
        tab.praise = pkt:GetLong()
        tab.tread = pkt:GetLong()
        tab.is_show_name = pkt:GetChar()
        table.insert(data, tab)
    end
end

function MsgParser:MSG_REFRESH_YYQ_INFO(pkt, data)
    data.update_time = pkt:GetLenString()
    data.yyq_no = pkt:GetLong()
    data.from_gid = pkt:GetLenString()
    data.from_name = pkt:GetLenString()
    data.to_gid = pkt:GetLenString()
    data.to_name = pkt:GetLenString()
    data.yyq_type = pkt:GetChar()
    data.text = pkt:GetLenString()
    data.praise = pkt:GetLong()
    data.tread = pkt:GetLong()
    data.is_show_name = pkt:GetChar()
end

function MsgParser:MSG_WRITE_ZFQ_RESULT(pkt, data)
    self:MSG_WRITE_YYQ_RESULT(pkt, data)
end

function MsgParser:MSG_STAT_HANGUP_ZFQ(pkt, data)
    self:MSG_STAT_HANGUP_YYQ(pkt, data)
end

function MsgParser:MSG_SEARCH_ZFQ_RESULT(pkt, data)
    self:MSG_SEARCH_YYQ_RESULT(pkt, data)
end

function MsgParser:MSG_ZFQ_PAGE(pkt, data)
    self:MSG_YYQ_PAGE(pkt, data)
end

function MsgParser:MSG_REQUEST_MY_ZFQ_RESULT(pkt, data)
    self:MSG_REQUEST_MY_YYQ_RESULT(pkt, data)
end

function MsgParser:MSG_REFRESH_ZFQ_INFO(pkt, data)
    self:MSG_REFRESH_YYQ_INFO(pkt, data)
end

-- 我的节日福利信息
function MsgParser:MSG_MY_FESTIVAL_GIFT_INFO(pkt, data)
    data.loginTime = pkt:GetChar()
    data.active = pkt:GetShort()
    data.giftCount = pkt:GetChar()
    data.gifts = {}
    for i = 1, data.giftCount do
        local info = {}
        info.name = pkt:GetLenString() -- 礼包名
        info.buyTimeCur = pkt:GetChar()
        table.insert(data.gifts, info)
    end
    local getedBox = pkt:GetChar()
    data.boxs = {}
    for i = 1, getedBox do
        local getNum = pkt:GetChar()
        data.boxs[getNum] = {}
    end
end

function MsgParser:MSG_APPLY_SUCCESS(pkt, data)
    data.itemName = pkt:GetLenString()
end

function MsgParser:MSG_PH_CARD_INFO(pkt, data)
    data.keyStr = pkt:GetLenString()
    local task = {}
    self:MSG_TASK_PROMPT(pkt, task)
    data.cardInfo = task[1]
end

function MsgParser:MSG_QUANFU_HONGBAO_RECORD(pkt, data)
    data.size = pkt:GetShort()
    data.list = {}
    for i = 1, data.size do
        local oneRecord = {}
        oneRecord.text = pkt:GetLenString()
        table.insert(data.list, oneRecord)
    end
end

function MsgParser:MSG_KICK_OFF(pkt, data)
    data.tip = pkt:GetLenString()
end

function MsgParser:MSG_PT_RB_SEND_INFO(pkt, data)
    data.leftTimes = pkt:GetShort()
    data.memberCount = pkt:GetShort()

    data.activiesCount = pkt:GetShort()
    data.activiesInfo = {}
    for i = 1, data.activiesCount do
        data.activiesInfo[i] = {}
        data.activiesInfo[i].name = pkt:GetLenString()
        data.activiesInfo[i].participation = pkt:GetShort()
        data.activiesInfo[i].activeId = pkt:GetLenString()
    end
end

function MsgParser:MSG_PT_RB_RECV_REDBAG(pkt, data)
    data.type = pkt:GetChar()
    data.totalCoin = pkt:GetLong()
    data.coin = pkt:GetLong()
    data.redbag_gid = pkt:GetLenString()
    data.senderName = pkt:GetLenString()
    data.msg = pkt:GetLenString()
    data.sendTime = pkt:GetLong()
    data.count = pkt:GetShort()
    data.state = pkt:GetChar()
    data.is_sender = pkt:GetChar()
    data.is_recv = pkt:GetChar()
    data.size = pkt:GetShort()
    data.list = {}

    for i = 1, data.size do
        local info = {}
        info.name = pkt:GetLenString()
        info.coin = pkt:GetLong()
        info.time = pkt:GetLong()
        table.insert(data.list, info)
    end
end

function MsgParser:MSG_PT_RB_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.redbagList = {}

    for i = 1, data.count do
        local redbag = {}
        redbag.redbag_gid = pkt:GetLenString()
        redbag.senderName = pkt:GetLenString()
        redbag.msg = pkt:GetLenString()
        redbag.time = pkt:GetLong()
        redbag.count = pkt:GetShort()
        redbag.state = pkt:GetChar()
        redbag.is_sender = pkt:GetChar()
        redbag.is_recv = pkt:GetChar()
        table.insert(data.redbagList, redbag)
    end
end

function MsgParser:MSG_QUESTIONNAIRE_INFO(pkt, data)
    data.id = pkt:GetShort()
    data.name = pkt:GetLenString()
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.bonus_desc = pkt:GetLenString()

    data.question_count = pkt:GetShort()
    data.questions = {}
    for i = 1, data.question_count do
        table.insert(data.questions, pkt:GetLenString2())
    end
end

function MsgParser:MSG_PT_RB_RECORD(pkt, data)
    data.type = pkt:GetChar()
    data.count = pkt:GetLong()
    data.total = pkt:GetLong()
    data.size = pkt:GetShort()
    data.list = {}

    for i = 1, data.size do
        local info = {}
        info.name = pkt:GetLenString()
        info.coin = pkt:GetLong()
        info.time = pkt:GetLong()
        table.insert(data.list, info)
    end
end

function MsgParser:MSG_COMPETE_TOURNAMENT_INFO(pkt, data)
    data.curSeason = pkt:GetLenString()
    data.winTimes = pkt:GetLong()
    data.loseTimes = pkt:GetLong()
    data.drawTimes = pkt:GetLong()
    data.escapeTimes = pkt:GetLong()
    local total = data.winTimes + data.loseTimes + data.drawTimes + data.escapeTimes
    if total == 0 then
        data.winRate = "0.0" -- 胜率
    else
        data.winRate = string.format("%.1f", data.winTimes / total * 100) -- 胜率
    end

    data.prev_rank = pkt:GetShort()
    data.prev_score = pkt:GetSignedLong()

    data.curRanking = {}

    data.count = pkt:GetShort()
    for i = 1, data.count do
        data.curRanking[i] = {}
        data.curRanking[i].gid = pkt:GetLenString()
        data.curRanking[i].name = pkt:GetLenString()
        data.curRanking[i].level = pkt:GetShort()
        data.curRanking[i].polar = pkt:GetChar()
        data.curRanking[i].score = pkt:GetSignedLong()
        data.curRanking[i].rank = i
    end
end

function MsgParser:MSG_COMPETE_TOURNAMENT_TARGETS(pkt, data)
    data.count = pkt:GetShort()
    data.listInfo = {}
    for i = 1, data.count do
        data.listInfo[i] = {}
        data.listInfo[i].gid = pkt:GetLenString()
        data.listInfo[i].name = pkt:GetLenString()
        data.listInfo[i].icon = pkt:GetLong()
        data.listInfo[i].level = pkt:GetChar()
        data.listInfo[i].isTeam = pkt:GetChar()
        data.listInfo[i].teamMembersCount = pkt:GetChar()
        data.listInfo[i].score = pkt:GetSignedLong()
        data.listInfo[i].rank = i
    end

end

function MsgParser:MSG_COMPETE_TOURNAMENT_PREVIOUS_INFO(pkt, data)
    data.season = pkt:GetLenString()
    data.score = pkt:GetSignedLong()
    data.rank = pkt:GetShort()
end

function MsgParser:MSG_COMPETE_TOURNAMENT_TOP_CATALOG(pkt, data)
    data.count = pkt:GetShort()
    data.content = {}
    for i = 1, data.count do
        data.content[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_COMPETE_TOURNAMENT_TOP_USER_INFO(pkt, data)
    data.season = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.winners = {}
    for i = 1, data.count do
        data.winners[i] = {}
        data.winners[i].gid = pkt:GetLenString()
        data.winners[i].name = pkt:GetLenString()
        data.winners[i].level = pkt:GetShort()
        data.winners[i].icon = pkt:GetLong()
        data.winners[i]["upgrade/type"] = pkt:GetChar()
        data.winners[i].polar = pkt:GetChar()
        data.winners[i].score = pkt:GetSignedLong()
    end
end

function MsgParser:MSG_BAXIAN_LEFT_TIMES(pkt, data)
    data.left_time = pkt:GetShort()
end

function MsgParser:MSG_SET_PUSH_SETTINGS(pkt, data)
    data.value = pkt:GetLenString()
end

function MsgParser:MSG_FUZZY_IDENTITY(pkt, data)
    data.isBindName = pkt:GetChar()
    data.isBindPhone = pkt:GetChar()
    data.bindName = pkt:GetLenString()
    data.bindId = pkt:GetLenString()
    data.bindPhone = pkt:GetLenString()
end

function MsgParser:MSG_WULIANGXINJING_XINDE_INFO(pkt, data)
    local count = pkt:GetShort()
    data.count = count
    for i = 1, count do
        local info = {}
        info.id = pkt:GetLong()
        info.jyxd_times = pkt:GetChar()
        info.dwxd_times = pkt:GetChar()
        data[i] = info
    end
end

function MsgParser:MSG_WULIANGXINJING_INFO(pkt, data)
    data.jyxd_times = pkt:GetChar()
    data.dwxd_times = pkt:GetChar()
end

function MsgParser:MSG_ZUOLAO_INFO(pkt, data)
    local count = pkt:GetLong()
    data.count = count
    for i = 1, count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.level = pkt:GetShort()
        info.family = pkt:GetLenString()
        info.polar = pkt:GetShort()
        info.server_name = pkt:GetLenString()
        info.last_ti = pkt:GetLong()
        data[i] = info
    end
end

function MsgParser:MSG_RELEASE_SUCC(pkt, data)
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_PK_RECORD(pkt, data)
    data.type = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.update_time = pkt:GetLenString()
        info.server_name = pkt:GetLenString()
        Builders:BuildFields(pkt, info)
        table.insert(data.list, info)
    end
end

function MsgParser:MSG_HIDE_MOUNT(pkt, data)
    data.petId = pkt:GetLong()
    data.isHide = pkt:GetChar()
end

function MsgParser:MSG_RECORD_INFO(pkt, data)
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        data.list[pkt:GetLenString()] = pkt:GetLenString()
    end
end

function MsgParser:MSG_PK_FINGER(pkt, data)
    local count  = pkt:GetChar()
    data.count = count
    data.list = {}
    for i = 1, count do
        local info = {}
        Builders:BuildFields(pkt, info)
        table.insert(data.list, info)
    end
end

function MsgParser:MSG_SUBMIT_MULTI_ITEM(pkt, data)
    data.type = pkt:GetChar()

    data.limitNum = pkt:GetChar()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local item_id = pkt:GetLong()
        table.insert(data.list, item_id)
    end
end

function MsgParser:MSG_SET_CURRENT_MOUNT(pkt, data)
    data.ride_id = pkt:GetLong()
end

-- 超级大BOSS
function MsgParser:MSG_SUPER_BOSS_KILL_FIRST(pkt, data)
    data.flag = pkt:GetChar()          -- 0 显示图鉴， 1 显示首杀
    data.monster_count = pkt:GetChar() -- 超级大BOSS数量
    for i = 1, data.monster_count do
        local bossName = pkt:GetLenString()                         -- boss 名字
        data[bossName]= {}
        data[bossName].boss_name = bossName
        data[bossName].kill_time = pkt:GetLong()                 -- 首杀时间
        data[bossName].player_count = pkt:GetChar()              -- 首杀队伍人数
        data[bossName].plays = {}
        for j = 1, data[bossName].player_count do
            data[bossName].plays[j] = {}                         -- 首杀队伍
            data[bossName].plays[j].gid = pkt:GetLenString()     -- 首杀队伍玩家 gid
            data[bossName].plays[j].name = pkt:GetLenString()    -- 首杀队伍玩家 名字
            data[bossName].plays[j].level = pkt:GetShort()       -- 首杀队伍玩家 等级
            data[bossName].plays[j].icon = pkt:GetLong()         -- 首杀队伍玩家 icon
        end
    end
end

function MsgParser:MSG_QUERY_MOUNT_MERGE_RATE(pkt, data)
    data.rate = pkt:GetLong()
end

function MsgParser:MSG_PREVIEW_MOUNT_ATTRIB(pkt, data)
    data.pet_no = pkt:GetShort()
    data.target_level = pkt:GetChar()
    data.all_attrib = pkt:GetLong()
    data.phy_power = pkt:GetLong()
    data.mag_power = pkt:GetLong()
    data.def = pkt:GetLong()
    data.speed = pkt:GetLong()
end

function MsgParser:MSG_CONFIRM(pkt, data)
    data.tips = pkt:GetLenString()
    data.down_count = pkt:GetLong()
    data.only_confirm = pkt:GetChar()
    data.confirm_type = pkt:GetLenString()
    data.confirmText = pkt:GetLenString()
    data.cancelText = pkt:GetLenString()
    data.show_dlg_mode = pkt:GetChar()
    data.countDownTips = pkt:GetLenString()

    data.para_str = pkt:GetLenString2()  -- json格式字段
    data.no_close_btn = pkt:GetChar()
end

-- ==========龙争虎斗
function MsgParser:MSG_LONGHU_INFO(pkt, data)
    data.is_open = pkt:GetChar()

    if data.is_open == 0 then return end

    data.war_type = pkt:GetLenString()

    data.my_team_name = pkt:GetLenString()
    data.opp_team_name = pkt:GetLenString()

    data.my_camp_type = pkt:GetLenString()
    data.my_camp_index = pkt:GetChar()
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()

    data.combat_result_1 = pkt:GetLenString()
    data.combat_result_2 = pkt:GetLenString()
    data.combat_result_3 = pkt:GetLenString()
end


function MsgParser:MSG_LH_GUESS_RACE_INFO(pkt, data)
    data.last_ti = pkt:GetLong()
    data.count = pkt:GetShort()

    for i = 1, data.count do
        local key = pkt:GetLenString()
        data[key] = pkt:GetLenString()
    end
end

function MsgParser:MSG_LH_GUESS_PLANS(pkt, data)
    data.last_ti = pkt:GetLong()
    data.race_name = pkt:GetLenString()
    data.race_index = pkt:GetLenString()
    data.day = pkt:GetChar()
    data.count = pkt:GetChar()

    for i = 1, data.count do
        local QLIndex = pkt:GetChar()

        data[QLIndex] = {}

        data[QLIndex].QLIndex = QLIndex
        data[QLIndex].QLName = pkt:GetLenString()

        data[QLIndex].BHIndex = pkt:GetChar()
        data[QLIndex].BHName = pkt:GetLenString()

        data[QLIndex].warRet = pkt:GetLenString()
    end
end

function MsgParser:MSG_LH_GUESS_CAMP_SCORE(pkt, data)
    data.race_name = pkt:GetLenString()
    data.QLCount = pkt:GetChar()
    data.QLData = {}
    for i = 1, data.QLCount do
        data.QLData[i] = {}
        data.QLData[i].camp_index = pkt:GetChar()
        data.QLData[i].score = pkt:GetLong()
        data.QLData[i].name = pkt:GetLenString()
    end

    data.BHCount = pkt:GetChar()
    data.BHData = {}
    for i = 1, data.BHCount do
        data.BHData[i] = {}
        data.BHData[i].camp_index = pkt:GetChar()
        data.BHData[i].score = pkt:GetLong()
        data.BHData[i].name = pkt:GetLenString()
    end
end

function MsgParser:MSG_LH_GUESS_INFO(pkt, data)
    data.race_name = pkt:GetLenString()
    data.race_index = pkt:GetLenString()
    data.camp_type = pkt:GetLenString()
    data.timeStr = pkt:GetLenString()

    data.start_ti = pkt:GetLong()
    data.end_ti = pkt:GetLong()
    data.select_times = pkt:GetChar()
end

function MsgParser:MSG_LH_GUESS_TEAM_INFO(pkt, data)
    data.teamName = pkt:GetLenString()
    data.count = pkt:GetChar()

    data.teamInfo = {}
    for i = 1, data.count do
        data.teamInfo[i] = {}
        data.teamInfo[i].name = pkt:GetLenString()
        data.teamInfo[i].dist = pkt:GetLenString()
        data.teamInfo[i].level = pkt:GetShort()
        data.teamInfo[i].polar = pkt:GetChar()
        data.teamInfo[i].gender = pkt:GetChar()
        data.teamInfo[i].icon = pkt:GetLong()
    end
end

-- ==========龙争虎斗

function MsgParser:MSG_SUMMON_MOUNT_RESULT(pkt, data)
    data.flag = pkt:GetChar()
    data.name = pkt:GetLenString()
end

function MsgParser:MSG_SUMMON_MOUNT_NOTIFY(pkt, data)
    data.flag = pkt:GetChar()
    data.id = pkt:GetLong()
end

function MsgParser:MSG_DUNWU_SKILL(pkt, data)
    data.pet_id = pkt:GetLong()
    data.skill_no = pkt:GetShort()
    data.type = pkt:GetChar()
    data.delta = pkt:GetChar()
end

function MsgParser:MSG_TASK_REPORT_INFO(pkt, data)
    data.task_name = pkt:GetLenString()
    data.cur_task_round = pkt:GetShort()
    data.max_task_round = pkt:GetShort()
end

function MsgParser:MSG_VIEW_DDQK_ATTRIB(pkt, data)
    data.id = pkt:GetLong()
    data.con = pkt:GetShort()
    data.wiz = pkt:GetShort()
    data.str = pkt:GetShort()
    data.dex = pkt:GetShort()
    data.max_round = pkt:GetChar()
end

function MsgParser:MSG_PARTY_ICON(pkt, data)
    data.id = pkt:GetLong()
    data.md5_value = pkt:GetLenString()
end

function MsgParser:MSG_SEND_ICON(pkt, data)
    data.md5_value = pkt:GetLenString()

    if pkt.GetLenBuffer2 then
        data.file_data = pkt:GetLenBuffer2()
    end
end

function MsgParser:MSG_WEDDING_CHECK_MUSIC(pkt, data)
    data.isReturn = pkt:GetChar()
end

function MsgParser:MSG_OPEN_FOOL_PLAYER_GIFT(pkt, data)
    data.name = pkt:GetLenString()
    data.pos = pkt:GetLong()
    data.money = pkt:GetLong()
    data.message = pkt:GetLenString()
    data.type = pkt:GetLenString()
end

function MsgParser:MSG_OPEN_CHAT_DLG(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.level = pkt:GetShort()
end

-- 接收实时弹幕
function MsgParser:MSG_LOOKON_CHANNEL_MESSAGE(pkt, data)
    data.sender = pkt:GetLenString()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_LOOKON_COMBAT_CHANNEL_DATA(pkt, data)
    data.combat_id = pkt:GetLenString()                    -- 赛事Id
    data.page = pkt:GetShort()
    data.count = pkt:GetShort()                            -- 消息数量

    data.barrage = {}
    for i = 1, data.count do
        data.barrage[i] = {}
        data.barrage[i].interval_tick = pkt:GetLong()
        data.barrage[i].sender = pkt:GetLenString()
        data.barrage[i].msg = pkt:GetLenString()
    end
end

-- 观战中心战斗录像数据
-- 由于 pkt:getLenBuffer2 比较耗时，故直接使用 MsgParser 的接口解析数据
function MsgParser:MSG_LOOKON_COMBAT_RECORD_DATA(pkt, data, rawData)
    local index = 3 -- 前面两个字节为消息编号
    local len = string.len(rawData)
    data.combat_id, index = self:getLenString(rawData, index, len) -- 赛事Id
    data.page, index = self:getShort(rawData, index, len)
    data.count, index = self:getShort(rawData, index, len)         -- 消息数量
    data.msg = {}

    local Connection = require "comm/Connection"
    local binaryStr
    for i = 1, data.count do
        data.msg[i] = {}
        data.msg[i].interval_tick, index = self:getLong(rawData, index, len)

        binaryStr, index = self:getLenBuffer2(rawData, index, len)
        data.msg[i].para = Connection:parseData(binaryStr)
    end
end

function MsgParser:parseStringHexToBinary(hex)
    local str = ""
    for i = 1, string.len(hex) - 1, 2 do
        local sss = string.sub(hex, i, i + 1)
        local n = tonumber(sss, 16)
        str = str .. string.char(n)
    end
    return str
end

-- 观战中心-开始直播观战
function MsgParser:MSG_LOOKON_BROADCAST_COMBAT_STATUS(pkt, data)
    data.combat_id = pkt:GetLenString()
    data.start_time = pkt:GetLong()
end

-- 观战大厅赛事列表
function MsgParser:MSG_BROADCAST_COMBAT_LIST(pkt, data)
    data.total_page = pkt:GetShort()                            -- 总共有多少页的数据
    data.page = pkt:GetShort() + 1                                  -- 当前第几页   从0开始,所以加1
    data.count = pkt:GetShort()                                 -- 这页有几条数据
    data.combats = {}
    for i = 1, data.count do
        data.combats[i] = {}
        data.combats[i].combat_id = pkt:GetLenString()          -- 赛事Id
        data.combats[i].combat_type = pkt:GetLenString()        -- 比赛类型，比如: "试道大会"
        data.combats[i].combat_sub_type = pkt:GetLenString()    -- 比赛子类型，例如名人争霸："四强赛"
        data.combats[i].start_time = pkt:GetLong()
        data.combats[i].combat_play_type = pkt:GetChar()        -- COMBAT_TYPE_LIVING (1) or COMBAT_TYPE_RECORDED (2)
        data.combats[i].att_dist = pkt:GetLenString()
        data.combats[i].att_name = pkt:GetLenString()           -- 攻击方
        data.combats[i].def_dist = pkt:GetLenString()
        data.combats[i].def_name = pkt:GetLenString()           -- 防御方
        data.combats[i].total_round = pkt:GetShort()            -- 战斗回合数
        data.combats[i].view_times = pkt:GetLong()              -- 观看次数
    end
end

-- 指定战斗的基础数据
function MsgParser:MSG_BROADCAST_COMBAT_DATA(pkt, data)
    data.combat_id = pkt:GetLenString()          -- 赛事Id
    data.combat_type = pkt:GetLenString()
    data.start_time = pkt:GetLong()
    data.combat_play_type = pkt:GetChar()
    data.att_dist = pkt:GetLenString()
    data.att_name = pkt:GetLenString()           -- 攻击方
    data.def_dist = pkt:GetLenString()
    data.def_name = pkt:GetLenString()           -- 防御方
    data.total_round = pkt:GetShort()            -- 战斗回合数
    data.view_times = pkt:GetLong()              -- 观看次数
    data.recorded_channel_interval = pkt:GetLong()  -- 每页对应多少秒的弹幕
    data.result = pkt:GetChar()                  -- 0 无结果       1 攻击方赢      2防御方赢  3平局
    data.att_count = pkt:GetShort()
    data.att = {}
    for i = 1, data.att_count do
        data.att[i] = {}
        data.att[i].name = pkt:GetLenString()
        data.att[i].dist = pkt:GetLenString()
        data.att[i].party = pkt:GetLenString()
        data.att[i].icon = pkt:GetShort()
        data.att[i].level = pkt:GetShort()
    end

    data.def_count = pkt:GetShort()
    data.def = {}
    for i = 1, data.def_count do
        data.def[i] = {}
        data.def[i].name = pkt:GetLenString()
        data.def[i].dist = pkt:GetLenString()
        data.def[i].party = pkt:GetLenString()
        data.def[i].icon = pkt:GetShort()
        data.def[i].level = pkt:GetShort()
    end
end

function MsgParser:MSG_RECORDED_COMBAT_INVALID(pkt, data)
    data.combat_id = pkt:GetLenString()
end

-- 周年庆抽奖小红点
function MsgParser:MSG_CAN_FETCH_FESTIVAL_GIFT(pkt, data)
    data.activeName = pkt:GetLenString()  -- 活动名称
    data.count = pkt:GetChar()
end

-- 2017周年庆 抽奖结果
function MsgParser:MSG_ZNQ_LOTTERY_RESULT(pkt, data)
    data.result = pkt:GetChar()  -- 抽奖结果
end

-- 给客户端刷新跨服试道信息
function MsgParser:MSG_CS_SHIDAO_TASK_INFO(pkt, data)
    data.type = pkt:GetChar()     -- 1 常规  2 月道行
    data.levelRange = pkt:GetLenString()  -- 等级段
    data.area = pkt:GetLenString()  -- 赛区
    data.is_running = pkt:GetChar()  -- 比赛是否开启（1表示正式比赛，0表示准备阶段）
    data.team_score = pkt:GetLong()  -- 队伍积分
    data.pk_num = pkt:GetLong()      -- 对决值
    data.start_time = pkt:GetLong()  -- 比赛开始时间
    data.end_time = pkt:GetLong()    -- 比赛结束时间
    data.rank = pkt:GetShort()       -- 玩家排名
    data.oust_time = pkt:GetLong()   -- 淘汰时间
end

function MsgParser:MSG_CS_SHIDAO_HISTORY(pkt, data)
    data.type = pkt:GetChar()     -- 1 常规  2 月道行
    data.session = pkt:GetLong()
    data.levelRange = pkt:GetLenString()
    data.area = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local teamInfo = {}
        teamInfo.rank = pkt:GetChar()
        teamInfo.score = pkt:GetLong()
        teamInfo.dist_name = pkt:GetLenString()
        teamInfo.leader_name = pkt:GetLenString()
        teamInfo.member_count = pkt:GetChar()
        for i = 1, teamInfo.member_count do
            local member = {}
            Builders:BuildFields(pkt, member)
            table.insert(teamInfo, member)
        end

        data[teamInfo.rank] = teamInfo
    end
end

function MsgParser:MSG_CS_SHIDAO_PLAN(pkt, data)
    data.maxSession = pkt:GetLong() -- 最大届数
    data.count = pkt:GetLong() -- 几届
    for i = 1, data.count do
        local sessionInfo = {}
        sessionInfo.session = pkt:GetLong()-- 届
        sessionInfo.count = pkt:GetChar()-- 多少个等级段
        for j = 1, sessionInfo.count do
            local levelInfo = {}
            levelInfo.levelRange = pkt:GetLenString() -- 等级段
            levelInfo.count = pkt:GetChar() -- 多少个赛区
            for k = 1, levelInfo.count do
                local area = pkt:GetLenString() -- 赛区
                levelInfo[area] = area
            end
            sessionInfo[levelInfo.levelRange] = levelInfo
        end

        table.insert(data, sessionInfo)
    end
end

function MsgParser:MSG_CS_SERVER_TYPE(pkt, data)
    data.server_type = pkt:GetLong()
end

function MsgParser:MSG_OPEN_CS_SHIDWZDLG(pkt, data)
    data.rank = pkt:GetChar()
    local count = pkt:GetChar()
    data.count = count
    for i = 1, count do
        local memberInfo = {}
        memberInfo["gid"] = pkt:GetLenString()
        memberInfo["name"] = pkt:GetLenString()
        memberInfo["level"] = pkt:GetShort()
        memberInfo["polar"] = pkt:GetChar()
        memberInfo["icon"] = pkt:GetShort()
        data[i] = memberInfo
    end
end

function MsgParser:MSG_START_TASK_COMBAT(pkt, data)
    data.task_name = pkt:GetLenString()
end

function MsgParser:MSG_QQ_LINK_ADDRESS(pkt, data)
    data.addr = pkt:GetLenString()
end

function MsgParser:MSG_LIEREN_XIANJING(pkt, data)
    data.duration = pkt:GetChar()
end

function MsgParser:MSG_ZUI_XIN_WU(pkt, data)
    data.duration = pkt:GetChar()
end

function MsgParser:MSG_HZWH_INFO(pkt, data)
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.whcd_id = pkt:GetShort()
end

function MsgParser:MSG_FRESH_MY_BAOSHU_INFO(pkt, data)
    data.level = pkt:GetChar()
    data.cur_exp = pkt:GetLong()
    data.level_up_exp = pkt:GetLong()
    data.stage = pkt:GetChar()
    data.has_worm = pkt:GetChar()
    data.bonus_type = pkt:GetLenString()
    data.bonus_num = pkt:GetLenString()
    data.health = pkt:GetChar()
    data.bonus_exp = pkt:GetLenString()
    data.bonus_tao = pkt:GetLenString()
    data.next_compute_time = pkt:GetLong()
    data.type = pkt:GetLenString()
    data.next_water_time = pkt:GetLong()
end

function MsgParser:MSG_GET_FRIEND_BAOSHU_INFO(pkt, data)
    data.error_type = pkt:GetChar()
    if data.error_type == 2 then
        data.gid = pkt:GetLenString()
        data.type = pkt:GetLenString()
        data.level = pkt:GetChar()
        data.cur_exp = pkt:GetLong()
        data.level_up_exp = pkt:GetLong()
        data.stage = pkt:GetChar()
        data.health = pkt:GetChar()
    end
end

function MsgParser:MSG_GET_WATER_LIST(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local gid = pkt:GetLenString()
        table.insert(data, gid)
    end
end

function MsgParser:MSG_ZNQ_LOGIN_GIFT(pkt, data)
    data.loginDays = pkt:GetChar()  -- 登录天数
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local bonus = {}
        bonus.index = pkt:GetChar() -- 礼包编号
        bonus.flag = pkt:GetChar() -- 是否已经领取过 0 不可领取、1 可以领取、2 已经领取
        bonus.needDays = pkt:GetChar() -- 领取礼包所需的天数
        bonus.desc = pkt:GetLenString2()--  礼包的奖励描述
        table.insert(data, bonus)
    end
end

function MsgParser:MSG_ZNQ_LOGIN_GIFT_2018(pkt, data)
    self:MSG_ZNQ_LOGIN_GIFT(pkt, data)
    data.end_time = pkt:GetLong()
end

function MsgParser:MSG_ZNQ_LOGIN_GIFT_2019(pkt, data)
    self:MSG_ZNQ_LOGIN_GIFT_2018(pkt, data)
end

function MsgParser:MSG_WUXING_SHOP_REFRSH(pkt, data)
    data.refreshTime = pkt:GetLong() -- 下次刷新时间
    data.size = pkt:GetChar() -- 商品数量
    for i = 1, data.size do
        local itemInfo = {}
        itemInfo.name = pkt:GetLenString() -- 兑换商品名称
        itemInfo.price = pkt:GetShort() -- 兑换所需道具数量
        itemInfo.num = pkt:GetShort() -- 当前消耗配额
        itemInfo.totalNum = pkt:GetShort() -- 每日最大限额
        itemInfo.limited = pkt:GetChar() -- 是否为限制交易
        table.insert(data, itemInfo)
    end
end

function MsgParser:MSG_ZNQ_2017_XMMJ(pkt, data)
    data.alias = pkt:GetLenString()
    data.room_name = pkt:GetLenString()
    data.floor = pkt:GetShort()
    data.strength = pkt:GetShort()
    data.guard = pkt:GetShort()
    data.book = pkt:GetShort()
end

-- 玩家或者宠物的对象id
function MsgParser:MSG_ASSIGN_RESIST(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_BAISZW_INFO(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.dungeon_index = pkt:GetChar()
end
function MsgParser:MSG_QMPK_MATCH_PLAN_INFO(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        local stage = pkt:GetLenString()
        local infoCount = pkt:GetChar()
        info.stage = stage

        for j = 1, infoCount do
            local teamInfo = {}
            teamInfo.id = pkt:GetChar()
            teamInfo.gid = pkt:GetLenString()
            table.insert(info, teamInfo)
        end

        table.insert(data, info)
    end
end

function MsgParser:MSG_QMPK_MATCH_LEADER_INFO(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        table.insert(data, info)
    end
end

function MsgParser:MSG_QMPK_MATCH_TIME_INFO(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.stage = pkt:GetLenString()
        local num = pkt:GetChar()
        for j = 1, num do
            local time = pkt:GetLong()
            table.insert(info, time)
        end

        table.insert(data, info)
    end

    data.is_match_begin = pkt:GetChar()
end

function MsgParser:MSG_QMPK_MATCH_TEAM_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.teamName = pkt:GetLenString()
    data.teamInfo = {}
    for i = 1, data.count do
        local char = {}
        local dist = pkt:GetLenString()
        Builders:BuildFields(pkt, char)
        char.dist = dist
        table.insert(data.teamInfo, char)
    end
end

function MsgParser:MSG_OPEN_QMPK_BONUS_DLG(pkt, data)
    data.stage = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local memberInfo = {}
        memberInfo["gid"] = pkt:GetLenString()
        memberInfo["name"] = pkt:GetLenString()
        memberInfo["level"] = pkt:GetShort()
        memberInfo["polar"] = pkt:GetChar()
        memberInfo["icon"] = pkt:GetShort()
        data[i] = memberInfo
    end
end

function MsgParser:MSG_OPEN_BROTHER_DLG(pkt, data)
    data.appellation = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.level = pkt:GetShort()
        info.icon = pkt:GetLong()
        table.insert(data, info)
    end
end

function MsgParser:MSG_BROTHER_ORDER(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetShort()
        info.name = pkt:GetLenString()
        table.insert(data, info)
    end
end

function MsgParser:MSG_BROTHER_APPELLATION(pkt, data)

    data.prefix = pkt:GetLenString()
    data.suffix = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetShort()
        info.name = pkt:GetLenString()
        table.insert(data, info)
    end
end

function MsgParser:MSG_RAW_BROTHER_INFO(pkt, data)
    data.appellation = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetShort()
        info.name = pkt:GetLenString()
        info.has_confirm = pkt:GetChar()
        table.insert(data, info)
    end
end

function MsgParser:MSG_REQUEST_BROTHER_INFO(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.friend = pkt:GetLong()
        info.name = pkt:GetLenString()
        table.insert(data, info)
    end
end

function MsgParser:MSG_ADD_FRIEND_OPER(pkt, data)
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.party_name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.level = pkt:GetLong()
end

function MsgParser:MSG_MY_KSDZ_INFO(pkt, data)
    data.lmjs = pkt:GetLong()
    data.cylm = pkt:GetLong()
    data.camp = pkt:GetChar()
    data.score = pkt:GetLong()
    data.rank = pkt:GetLong()
end

function MsgParser:MSG_KSDZ_TIME(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
end

function MsgParser:MSG_BAOSHI_INFO(pkt, data)
    data.jiasu = pkt:GetLong()
    data.xuyin = pkt:GetLong()
    data.qiangli = pkt:GetLong()
end

function MsgParser:MSG_REENTRY_ASKTAO_DATA_NEW(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.score = pkt:GetLong()
    data.today_bonus_score = pkt:GetChar()
    data.is_first = pkt:GetChar()
    data.active_value = pkt:GetShort()
    data.fetched_liveness_gift = pkt:GetChar() -- 1已经领取活跃度礼包     0未领取
    data.can_get_gift = pkt:GetChar() -- 是否可以领取.
    data.gift_fetched_flag = pkt:GetLenString() -- 七日任务领取标记，示例："1,1,0,0,0,0,0"，表示第一天，第二天的任务奖励已领取
end

function MsgParser:MSG_REENTRY_ASKTAO_DATA(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.score = pkt:GetLong()
    data.is_first = pkt:GetChar()
    data.active_value = pkt:GetShort()
    data.fetched_liveness_gift = pkt:GetChar() -- 1已经领取活跃度礼包     0未领取
    data.fetched_comeback_gift = pkt:GetChar() -- 0 已经领取，1 普通，2超级 3特技
    data.fetched_comeback_type = pkt:GetChar() -- 1 普通，2超级 3特技
    data.task_times = pkt:GetLenString() -- 七日任务完成次数, 示例："1,2,3,4,5,6,7"，共7个数据，对应每天任务的完成次数
    data.task_fetched_flag = pkt:GetLenString() -- 七日任务领取标记，示例："1,1,0,0,0,0,0"，表示第一天，第二天的任务奖励已领取
end

function MsgParser:MSG_RECALL_USER_ACTIVITY_DATA(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.score = pkt:GetLong()
    data.today_recall_times = pkt:GetShort()    -- 今日召回次数
    data.today_bonus_score = pkt:GetShort()     -- 今日召回积分
    data.total_recall_succ_times = pkt:GetShort() -- 累计召回成功次数
    data.total_bonus_score = pkt:GetShort()     -- 累计召回积分
end

function MsgParser:MSG_RECALL_USER_DATA_LIST(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].gid = pkt:GetLenString()
        data[i].name = pkt:GetLenString()
        data[i].icon = pkt:GetLong()
        data[i].level = pkt:GetShort()
        data[i].has_recall = pkt:GetChar()
    end
end

function MsgParser:MSG_RECALL_USER_SUCCESS(pkt, data)
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_CHAR_DELETE(pkt, data)
    data.is_delete = pkt:GetChar()
end

function MsgParser:MSG_YONGCWYK_INFO(pkt, data)
    data.act_alias = pkt:GetLenString()
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.xiaoy_count = pkt:GetShort()
    data.xiaoy_need = pkt:GetShort()
    data.toum_count = pkt:GetShort()
    data.toum_need = pkt:GetShort()
    data.shouw_count = pkt:GetShort()
    data.shouw_need = pkt:GetShort()
    data.layer = pkt:GetShort()
    data.layer_max = pkt:GetShort()
    data.is_finish = pkt:GetChar()
    data.dungeon_index = pkt:GetChar()
end

function MsgParser:MSG_QMPK_INFO(pkt, data)
    data.stage = pkt:GetLenString()
    data.tip = pkt:GetLenString()
    data.has_confirm = pkt:GetChar()
    if data.has_confirm == 1 then
        data.count = pkt:GetChar()
        data.names = {}
        for i = 1, data.count do
            local name = pkt:GetLenString()
            table.insert(data.names, name)
        end
    end
end

function MsgParser:MSG_YISHI_RECRUIT_DIALOG(pkt, data)
    data.flag = pkt:GetChar()
    data.mode = pkt:GetChar()
    data.merit = pkt:GetLong()
    data.count1 = pkt:GetChar()
    data.recruit_npcs = {}
    for i = 1, data.count1 do
        local npc = {}
        npc.npc_name = pkt:GetLenString()
        npc.npc_icon = pkt:GetShort()
        npc.atk_type = pkt:GetChar()
        npc.merit = pkt:GetLong()
        table.insert(data.recruit_npcs, npc)
    end
    data.count2 = pkt:GetChar()
    data.own_npcs = {}
    for i = 1, data.count2 do
        local npc = {}
        npc.npc_id = pkt:GetLong()
        npc.npc_name = pkt:GetLenString()
        npc.npc_icon = pkt:GetShort()
        npc.npc_rank = pkt:GetChar()
        npc.atk_count = pkt:GetChar()
        npc.spd_count = pkt:GetChar()
        npc.tao_count = pkt:GetChar()
        npc.def_count = pkt:GetChar()
        table.insert(data.own_npcs, npc)
    end
end

function MsgParser:MSG_YISHI_DISMISS_RESULT(pkt, data)
    data.npc_id = pkt:GetLong()
end

function MsgParser:MSG_YISHI_RECRUIT_RESULT(pkt, data)
    data.merit = pkt:GetLong()
    data.npc = {}
    data.npc.npc_id = pkt:GetLong()
    data.npc.npc_name = pkt:GetLenString()
    data.npc.npc_icon = pkt:GetShort()
    data.npc.npc_rank = pkt:GetChar()
    data.npc.atk_count = pkt:GetChar()
    data.npc.spd_count = pkt:GetChar()
    data.npc.tao_count = pkt:GetChar()
    data.npc.def_count = pkt:GetChar()
end

function MsgParser:MSG_YISHI_IMPROVE_DIALOG(pkt, data)
    data.merit = pkt:GetLong()
    data.atk = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.spd = pkt:GetLong()
    data.def = pkt:GetLong()
    data.type = pkt:GetChar()
    data.atk_count = pkt:GetChar()
    data.spd_count = pkt:GetChar()
    data.tao_count = pkt:GetChar()
    data.def_count = pkt:GetChar()
    data.left_count = pkt:GetChar()
    data.count = pkt:GetChar()
    data.npcs = {}
    for i = 1, data.count do
        local npc = {}
        npc.npc_id = pkt:GetLong()
        npc.npc_name = pkt:GetLenString()
        npc.npc_icon = pkt:GetShort()
        npc.npc_rank = pkt:GetChar()
        npc.type = pkt:GetChar()
        npc.atk_count = pkt:GetChar()
        npc.spd_count = pkt:GetChar()
        npc.tao_count = pkt:GetChar()
        npc.def_count = pkt:GetChar()
        npc.left_count = pkt:GetChar()
        npc.amount = pkt:GetChar()
        table.insert(data.npcs, npc)
    end
end

function MsgParser:MSG_YISHI_IMPROVE_RESULT(pkt, data)
    data.left_merit = pkt:GetLong()
    data.cost_merit = pkt:GetLong()
    data.npc = {}
    data.npc.npc_id = pkt:GetLong()
    data.npc.npc_name = pkt:GetLenString()
    data.npc.npc_icon = pkt:GetShort()
    data.npc.npc_rank = pkt:GetChar()
    data.npc.type = pkt:GetChar()
    data.npc.atk_count = pkt:GetChar()
    data.npc.spd_count = pkt:GetChar()
    data.npc.tao_count = pkt:GetChar()
    data.npc.def_count = pkt:GetChar()
    data.npc.left_count = pkt:GetChar()
    data.npc.amount = pkt:GetChar()
end

function MsgParser:MSG_YISHI_IMPROVE_PREVIEW(pkt, data)
    data.left_merit = pkt:GetLong()
    data.cost_merit = pkt:GetLong()
    data.npc = {}
    data.npc.npc_id = pkt:GetLong()
    data.npc.npc_name = pkt:GetLenString()
    data.npc.npc_icon = pkt:GetShort()
    data.npc.npc_rank = pkt:GetChar()
    npc.type = pkt:GetChar()
    data.npc.atk_count = pkt:GetChar()
    data.npc.spd_count = pkt:GetChar()
    data.npc.tao_count = pkt:GetChar()
    data.npc.def_count = pkt:GetChar()
    data.npc.left_count = pkt:GetChar()
    data.npc.amount = pkt:GetChar()
end

function MsgParser:MSG_YISHI_EXCHANGE_DIALOG(pkt, data)
    data.merit = pkt:GetLong()
    data.count = pkt:GetChar()
    data.goods = {}
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.price = pkt:GetShort()
        table.insert(data.goods, item)
    end
end

function MsgParser:MSG_YISHI_EXCHANGE_RESULT(pkt, data)
    data.merit = pkt:GetLong()
end

function MsgParser:MSG_YISHI_SEARCH_RESULT(pkt, data)
    data.result = pkt:GetChar()
    data.desc = pkt:GetLenString()
end

function MsgParser:MSG_YISHI_ACTIVITY_INFO(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.born_time = pkt:GetLong()
end

function MsgParser:MSG_WEEK_ACTIVITY_INFO(pkt, data)
    data.count = pkt:GetShort()
    data.activities = {}
    for i = 1, data.count do
        local alias = pkt:GetLenString()
        table.insert(data.activities, alias)
    end
end

function MsgParser:MSG_ACTIVE_BONUS_INFO(pkt, data)
    data.fetch_state = pkt:GetChar() -- 0 不可领取， 1可领取， 2已经领取
    data.show_reddot = pkt:GetChar()
    data.active1 = pkt:GetShort()
    data.active2 = pkt:GetShort()
    data.active3 = pkt:GetShort()
    data.active4 = pkt:GetShort()
    data.active5 = pkt:GetShort()
    data.active6 = pkt:GetShort()
end

function MsgParser:MSG_YISHI_PLAYER_STATUS(pkt, data)
    data.status = pkt:GetChar()
end

function MsgParser:MSG_BAXIAN_DICE(pkt, data)
    data.result = pkt:GetChar()
end

function MsgParser:MSG_ZXSL_INFO(pkt, data)
    data.qinglong = pkt:GetChar()
    data.baihu = pkt:GetChar()
    data.zhuque = pkt:GetChar()
    data.xuanwu = pkt:GetChar()
    data.zuoHF = pkt:GetChar()
    data.youHF = pkt:GetChar()
    data.huanying = pkt:GetChar()
end
function MsgParser:MSG_CHILD_DAY_2017_POKE(pkt, data)
    data.gid = pkt:GetLenString()
    data.type = pkt:GetChar()
    data.score = pkt:GetChar()
    data.new_gid = pkt:GetLenString()
    data.new_type = pkt:GetChar()
    data.batter_count = pkt:GetChar()
    data.blue_score = pkt:GetLong()
    data.purple_score = pkt:GetLong()
    data.gold_score = pkt:GetLong()
end
function MsgParser:MSG_CHAR_UPGRADE_COAGULATION(pkt, data)
    data.upgrade_type = pkt:GetChar()
end
function MsgParser:MSG_DIJIE_FINISH_TASK(pkt, data)
    data.round = pkt:GetChar()
    data.bonus_exp = pkt:GetLong()
    data.polar_upper1 = pkt:GetChar()
    data.polar_upper2 = pkt:GetChar()
    data.level_upper1 = pkt:GetChar()
    data.level_upper2 = pkt:GetChar()
end

function MsgParser:MSG_TIANJIE_FINISH_TASK(pkt, data)
    self:MSG_DIJIE_FINISH_TASK(pkt, data)
end

function MsgParser:MSG_CHILD_DAY_2017_END(pkt, data)
    data.star = pkt:GetSignedChar()
    data.highest_score = pkt:GetLong()
    data.blue_score = pkt:GetLong()
    data.purple_score = pkt:GetLong()
    data.gold_score = pkt:GetLong()
    data.exp = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.item = pkt:GetLenString()
    data.no_bonus = pkt:GetChar()
end

function MsgParser:MSG_CHILD_DAY_2017_START(pkt, data)
    data.game_time = pkt:GetChar()
    data.ready_time = pkt:GetChar()
    data.count = pkt:GetChar()
    data.bubbles = {}
    for i = 1, data.count do
        table.insert(data.bubbles, { gid = pkt:GetLenString(), type = pkt:GetChar() })
    end
end

function MsgParser:MSG_CHILD_DAY_2017_QUIT(pkt, data)
    data.type = pkt:GetLenString()
    data.left_time = pkt:GetChar()
end

function MsgParser:MSG_CHILD_DAY_2017_REMOVE(pkt, data)
    data.gid = pkt:GetLenString()
    data.new_gid = pkt:GetLenString()
    data.type = pkt:GetChar()
end

function MsgParser:MSG_PET_UPGRADE_PRE_INFO(pkt, data)
    data.id = pkt:GetLong()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_PET_UPGRADE_SUCC(pkt, data)
    data.id = pkt:GetLong()
    data.before = {}
    data.after = {}
    Builders:BuildFields(pkt, data.before)
    Builders:BuildFields(pkt, data.after)
end

function MsgParser:MSG_UPGRADE_TASK_PET(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_UPDATE_ANTIADDICTION_STATUS(pkt, data)
    data.is_startup = pkt:GetChar()
    data.total_online = pkt:GetLong()
    data.last_online = pkt:GetLong()
    data.adult_status = pkt:GetSignedChar() -- -1 不检测 0 未成年 1 已成年 2 未认证
    data.switch3 = pkt:GetChar()
    data.switch5 = pkt:GetChar()
    data.second_enable = pkt:GetChar() --  第二套是否开启使用
    data.switch7 = pkt:GetChar()       -- 是否开启了 switch7
    data.player_age = pkt:GetSignedShort()  -- 玩家年龄 -1 表示未知
    data.is_guest = pkt:GetChar()   -- 是否是游客，0 表示不是，否则为 1
    data.small_age = pkt:GetShort()   -- 限制年龄
    data.young_coin_cost_limit = pkt:GetLong()  -- 单次允许花费的元宝数量
    data.small_age_online = pkt:GetLong()  -- 小年龄在线时长
    data.young_online = pkt:GetLong() -- 未成年在线时长

    if data.is_guest == 1 and data.second_enable == 1 then
        -- 游客只有第二套生效，生效时必须未验证且开启防沉迷
        data.adult_status = 2
    end
end

function MsgParser:MSG_RARE_SHOP_ITEMS_INFO(pkt, data)
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local item = {}
        item.barcode = pkt:GetLenString()
        item.name = pkt:GetLenString()
        item.cost = pkt:GetLong()
        item.num = pkt:GetLong()
        table.insert(data, item)
    end
end

function MsgParser:MSG_RENAME_DISCOUNT(pkt, data)
    data.price = pkt:GetLong() -- 价格
    data.org_price = pkt:GetLong() -- 原价
    data.time_out = pkt:GetLong()
    data.buy_count = pkt:GetLong()    -- 可购买次数
end

function MsgParser:MSG_SD_2017_LOTTERY_RESULT(pkt, data)
    data.type = pkt:GetChar() + 1 -- 奖池类型（0,1,2,3 分别代表紫气、福盈、小喜、道心，-1 表示奖池不存在）
    data.reward = pkt:GetChar() + 1-- 奖品编号（0,1,2,3,4,5 表示奖品的序号）
end

function MsgParser:MSG_SD_2017_LOTTERY_INFO(pkt, data)
    data.startTime = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.score = pkt:GetLong()
    data.ziqi_quota = pkt:GetShort()
    data.fuying_quota = pkt:GetShort()
    data.xiaoxi_quota = pkt:GetShort()
    data.ziqi_count = pkt:GetChar()
    data.ziqi_desc = {}
    for i = 1, data.ziqi_count do
        data.ziqi_desc[i] = pkt:GetLenString()
    end

    data.fuying_count = pkt:GetChar()
    data.fuying_desc = {}
    for i = 1, data.fuying_count do
        data.fuying_desc[i] = pkt:GetLenString()
    end

    data.xiaoxi_count = pkt:GetChar()
    data.xiaoxi_desc = {}
    for i = 1, data.xiaoxi_count do

        data.xiaoxi_desc[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_RARE_SHOP_ONE_ITEM_INFO(pkt, data)
    data.barcode = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.cost = pkt:GetLong()
    data.num = pkt:GetLong()
end

function MsgParser:MSG_FORMER_NAME(pkt, data)
    data.is_ok = pkt:GetChar()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_PARTY_FORMER_NAME(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_AUTO_TALK_DATA(pkt, data)
    data.id = pkt:GetLong()
    data.content = pkt:GetLenString2()
end

function MsgParser:MSG_OPEN_MODIFY_HOUSE_SPACE_DLG(pkt, data)
    data.action = pkt:GetLenString()
    data.last_house = pkt:GetLenString()
    data.cur_house = pkt:GetLenString()
    data.price = pkt:GetLong()
    data.selects = {
        ["bed_room"] = pkt:GetChar(),
        ["store_room"] = pkt:GetChar(),
        ["artifact_room"] = pkt:GetChar(),
        ["practice_room"] = pkt:GetChar(),
    }
end

function MsgParser:MSG_REFRESH_RUYI_INFO(pkt, data)
    data.state = pkt:GetChar()
    data.amt_state = pkt:GetChar()
end

function MsgParser:MSG_OPEN_ZAOHUA_ZHICHI(pkt, data)
    data.total = pkt:GetShort()
    data.count = pkt:GetChar()
    data.rec_times = pkt:GetChar()
end

-- 客户端请求赛区安排
function MsgParser:MSG_CS_SHIDAO_ZONE_PLAN(pkt, data)
    data.my_dist_name = pkt:GetLenString() -- 区组名
    data.my_dist_start_time = pkt:GetLong() -- 本区组的开服时间
    data.match_day_zero_time = pkt:GetLong() -- 本月比赛那天的零点
    data.count = pkt:GetChar() -- 等级段个数
    for i = 1, data.count do
        local level_index = pkt:GetLenString() -- 等级段
        data[level_index] = {}
        data[level_index].count = pkt:GetChar() -- 赛区的数量
        for j = 1, data[level_index].count do
            local area = pkt:GetLenString()
            data[level_index][area] = area
        end

        local cur_dist_zone = pkt:GetLenString() -- 等级段
        data[level_index].cur_dist_zone = cur_dist_zone
    end
end

-- 客户端请求赛区安排的具体数据
function MsgParser:MSG_CS_SHIDAO_ZONE_INFO(pkt, data)
    data.level_index = pkt:GetLenString() -- 等级段
    data.zone = pkt:GetLenString() -- 赛区
    data.dist_count = pkt:GetShort()
    for i = 1, data.dist_count do
        local dist_info = {}
        dist_info.dist_name = pkt:GetLenString() -- 区组名
        dist_info.start_time = pkt:GetLong() -- 开服时间
        table.insert(data, dist_info)
    end
end

-- 通知可以销毁的列表
function MsgParser:MSG_DESTROY_VALUABLE_LIST(pkt, data)
    data.type = pkt:GetChar()  -- 类型
    data.id_str = pkt:GetLenString() -- 贵重道具、宠物位置列表，以 "|" 分隔，如 "41|42|50"
end

-- 通知打开销毁界面
function MsgParser:MSG_DESTROY_VALUABLE(pkt, data)
    data.type = pkt:GetChar()  -- 类型
    data.id = pkt:GetLong() -- 位置
    data.life = pkt:GetLong() -- 玩家气血值
end

function MsgParser:MSG_HOUSE_FURNITURE_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.map_index = pkt:GetLong()
    data.obstacle = {}
    local len = pkt:GetShort()
    for i = 1, len do
        table.insert(data.obstacle, pkt:GetChar())
    end

	data.hoster_count = pkt:GetShort()
	data.hosters = {}
	for i = 1, data.hoster_count do
		data.hosters[pkt:GetLenString()] = 1
	end
end

-- 家具列表
function MsgParser:MSG_HOUSE_FURNITURE_DATA_PAGE(pkt, data)
    data.count = pkt:GetShort()
    data.furnitures = {}
    for i = 1, data.count do
        local f = {}
        f.furniture_pos = pkt:GetLong()
        f.furniture_id = pkt:GetLong()
        f.bx = pkt:GetShort()
        f.by = pkt:GetShort()
        f.flip = pkt:GetChar()  -- 只有两个方向时，表示翻转，超出两个方向时，表示方向（方向值 10 ~ 17）
        f.x = pkt:GetSignedChar()
        f.y = pkt:GetSignedChar()
        f.durability = pkt:GetShort()
        table.insert(data.furnitures, f)
    end
end

function MsgParser:MSG_HOUSE_FURNITURE_OPER(pkt, data)
    data.house_id = pkt:GetLenString()
    data.map_index = pkt:GetLong()
    data.cookie = pkt:GetLong()
    data.action = pkt:GetLenString()
    data.result = pkt:GetLong()
    data.furniture_pos = pkt:GetLong()
    data.furniture_id = pkt:GetLong()
    data.bx = pkt:GetShort()
    data.by = pkt:GetShort()
    data.flip = pkt:GetChar()  -- 只有两个方向时，表示翻转，超出两个方向时，表示方向（方向值 10 ~ 17）
    data.x = pkt:GetSignedChar()
    data.y = pkt:GetSignedChar()
    data.durability = pkt:GetShort()
end

function MsgParser:MSG_ADD_HOUSE_FURNITURE_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.map_index = pkt:GetLong()
    data.count = pkt:GetShort()
    data.furnitures = {}
    for i = 1, data.count do
        local f = {}
        f.furniture_pos = pkt:GetLong()
        f.furniture_id = pkt:GetLong()
        f.bx = pkt:GetShort()
        f.by = pkt:GetShort()
        f.flip = pkt:GetChar() -- 只有两个方向时，表示翻转，超出两个方向时，表示方向（方向值 10 ~ 17）
        f.x = pkt:GetSignedChar()
        f.y = pkt:GetSignedChar()
        f.durability = pkt:GetShort()
        table.insert(data.furnitures, f)
    end
end

function MsgParser:MSG_HOUSE_UPDATE_STYLE(pkt, data)
    data.map_index = pkt:GetLong()
    data.floor_index = pkt:GetChar()
    data.wall_index = pkt:GetChar()
end

function MsgParser:MSG_HOUSE_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.house_prefix = pkt:GetLenString()
    data.comfort = pkt:GetShort()
    data.cleanliness = pkt:GetChar()
    data.clean_costtime = pkt:GetChar()
    data.store_type = pkt:GetChar()
end

function MsgParser:MSG_BEDROOM_FURNITURE_APPLY_DATA(pkt, data)
    data.bedroom_type = pkt:GetChar()
    data.max_times = pkt:GetChar()
    data.cur_times = pkt:GetChar()
    data.couple_rest_times = pkt:GetChar() -- 夫妻中已休息的最大值
end

function MsgParser:MSG_HOUSE_SHOW_DATA(pkt, data)
    data.char_gid = pkt:GetLenString()
    data.char_name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.suit_icon = pkt:GetLong()
    data.weapon_icon = pkt:GetLong()
    data["upgrade/type"] = pkt:GetChar()
    data.light_effect_count = pkt:GetChar()
    data.light_effect = {}
    for i = 1, data.light_effect_count do
        local effect = pkt:GetLong()
        table.insert(data.light_effect, effect)
    end
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.house_prefix = pkt:GetLenString()
    data.comfort = pkt:GetShort()
    data.cleanliness = pkt:GetChar()
    data.today_clean_times = pkt:GetChar()
end

function MsgParser:MSG_HOUSE_ROOM_SHOW_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.type = pkt:GetChar()
    data.floor_index = pkt:GetChar()
    data.wall_index = pkt:GetChar()
    data.count = pkt:GetShort()
    data.furnitures = {}
    local f
    for i = 1, data.count do
        f = {}
        f.furniture_id = pkt:GetLong()
        f.bx = pkt:GetShort()
        f.by = pkt:GetShort()
        f.is_flip = pkt:GetChar()
        f.x = pkt:GetSignedChar()
        f.y = pkt:GetSignedChar()
        table.insert(data.furnitures, f)
    end
end

function MsgParser:MSG_VISIT_HOUSE_FAILED(pkt, data)
    data.char_name = pkt:GetLenString()
end

function MsgParser:MSG_MARRY_HOUSE_SHOW_DATA(pkt, data)
    data.char_gid = pkt:GetLenString()
    data.char_name = pkt:GetLenString()
    data.male_name = pkt:GetLenString()
    data.famale_name = pkt:GetLenString()
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.house_prefix = pkt:GetLenString()
    data.comfort = pkt:GetShort()
    data.cleanliness = pkt:GetChar()
    data.today_clean_times = pkt:GetChar()
end

function MsgParser:MSG_HOUSE_FUNCTION_FURNITURE_LIST(pkt, data)
    data.house_id = pkt:GetLenString()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local furniture = {}
        furniture.furniture_pos = pkt:GetLong()
        furniture.furniture_id = pkt:GetLong()
        furniture.durability = pkt:GetShort()
        furniture.isUseing = pkt:GetChar()
        table.insert(data, furniture)
    end
end

function MsgParser:MSG_HOUSE_UPDATE_DATA(pkt, data)
    data.store_type = pkt:GetShort()
end

function MsgParser:MSG_OPEN_DLG_AND_ADD_LOOP_MAGIC(pkt, data)
    data.dlgName = pkt:GetLenString()
    data.ctrlName = pkt:GetLenString()
    data.resIcon = pkt:GetLong()
end

function MsgParser:MSG_HOUSE_PET_FEED_STATUS_INFO(pkt, data)
    data.bowl_id = pkt:GetLong()  -- 食盆id
    data.status = pkt:GetChar() -- 当前状态，0:停止，1:进行中
    data.is_my = pkt:GetChar()  -- 是否是自己的家具，0: 不是，1: 是
end

function MsgParser:MSG_HOUSE_PET_FEED_VALUE_INFO(pkt, data)
    data.bowl_id = pkt:GetLong()    -- 食盆id
    data.efficiency = pkt:GetLong()  -- 当前效率（已加成后的数值）
    data.rate = pkt:GetChar()        -- 加成家具的加成比例
    data.type = pkt:GetChar()            -- 当前奖励类型（0:经验、1:武学）
    data.bonus_value = pkt:GetLong()     -- 积累奖励的数值
end

function MsgParser:MSG_HOUSE_PET_FEED_FOOD_INFO(pkt, data)
    data.bowl_id = pkt:GetLong() -- 食盆id
    data.bowl_iid = pkt:GetLenString()
    data.num = pkt:GetLong()     -- 剩余饲料数量
    data.max_num = pkt:GetLong()      -- 饲料的上限
    data.remain_time = pkt:GetLong()    -- 可维持分钟
    data.next_bonus_time = pkt:GetLong()-- 下一次产出收益时间，当前时间 - 最后一次产出收益时间
end

function MsgParser:MSG_HOUSE_PET_FEED_SELECT_PET(pkt, data)
    data.bowl_id = pkt:GetLong()    -- 食盆id
    data.pet_iid = pkt:GetLenString() -- 宠物iid
    data.pet_name = pkt:GetLenString() -- 宠物名字
    data.pet_icon = pkt:GetLong()    -- 宠物icon
    data.is_show_pet = pkt:GetChar()
    Builders:BuildPetInfo(pkt, data)
end

function MsgParser:MSG_HOUSE_FEEDING_LIST(pkt, data)
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local info = {}
        info.pet_iid = pkt:GetLenString()  -- 正在饲养的宠物的iid
        info.pet_name = pkt:GetLenString()
        info.pet_icon = pkt:GetLong()
        info.food_num = pkt:GetLong()   -- 食料数量
        info.max_food = pkt:GetLong()   -- 食料上限
        info.bowl_iid = pkt:GetLenString()
        info.bowl_name = pkt:GetLenString()
        info.bowl_pos = pkt:GetLong()
        table.insert(data, info)
    end
end

function MsgParser:MSG_CHANTING_NOW(pkt, data)
    data.status = pkt:GetChar()
end
function MsgParser:MSG_ME_HOUSE_RANK_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.owner_name = pkt:GetLenString()
    data.couple_name = pkt:GetLenString()
    data.comfort = pkt:GetShort()
end

-- 抽奖结果预览
function MsgParser:MSG_WELCOME_DRAW_PREVIEW(pkt, data)
    data.name = pkt:GetLenString()
end

-- 界面信息
function MsgParser:MSG_WELCOME_DRAW_OPEN(pkt, data)
    data.server_time = pkt:GetLong()  -- 开服时间
    data.start_time = pkt:GetLong()
    data.end_time   = pkt:GetLong()
    data.create_time = pkt:GetLong()  -- 创建角色时间
    data.condition = pkt:GetLenString() -- 抽奖条件
    data.goods_desc = pkt:GetLenString2()  -- 奖品
end

function MsgParser:MSG_SHUADAO_FINAL_ROUND(pkt, data)
    data.task_name = pkt:GetLenString()
end

function MsgParser:MSG_CALL_GUARD_SUCC(pkt, data)
    data.guard_id = pkt:GetLong()
end

function MsgParser:MSG_ZHONGXIANTA_INFO(pkt, data)
    data.feature = pkt:GetLenString()
    data.layer = pkt:GetChar()
    data.max_layer = pkt:GetChar()
end
--[[
#define MSG_HOUSE_ARTIFACT_VALUE                    0xB112  // 法宝修炼数值部分
        make32(furniture_pos),                                      // 家具位置
        make16(space_num),                                          // 空间
        make32(home_comfort),                                       // 舒适度
        make32(max_comfort),                                        // 最大舒适度
        make32(cleanliness),                                        // 清洁度
        make32(max_cleanliness),                                    // 最大清洁度
        make32(durability),                                         // 耐久度
        make32(max_durability),                                     // 最大耐久度
        make32(nimbus),                                             // 灵气
        make32(max_nimbus),                                         // 最大的灵气值
        make32(daofa_em),                                           // 道法效率
        make32(keep_ti),                                            // 持续的时间
        make8(cur_status)                                          // 状态
        --]]
function MsgParser:MSG_HOUSE_SELECT_ARTIFACT(pkt, data)
    data.name = pkt:GetLenString()
    data.furniture_pos = pkt:GetLong()
    data.furniture_iid = pkt:GetLenString()

    if data.furniture_iid ~= "" then
        data.item = {}
        Builders:BuildItemInfo(pkt, data.item)
    end
end

function MsgParser:MSG_HOUSE_ARTIFACT_VALUE(pkt, data)
    data.name = pkt:GetLenString()
    data.furniture_pos = pkt:GetLong()
    data.space_num = pkt:GetShort()
    data.home_comfort = pkt:GetLong()
    data.max_comfort = pkt:GetLong()
    data.cleanliness = pkt:GetLong()
    data.max_cleanliness = pkt:GetLong()
    data.durability = pkt:GetLong()
    data.max_durability = pkt:GetLong()
    data.nimbus = pkt:GetLong()
    data.max_nimbus = pkt:GetLong()
    data.daofa_em = pkt:GetLong()     -- 修炼效率(已加成后的数值)
    data.rate = pkt:GetChar()         -- 加成家具的加成比例
    data.keep_ti = pkt:GetLong()
    data.cur_status = pkt:GetChar()
    data.isOpen = pkt:GetChar()
    data.all_bonus_exp = pkt:GetLong()
end

-- int8 cleanliness, int16 furniture_id, int32 furniture_pos, int16 furniture_durability, int32 next_bonus_time, int8 xinmo, int32 total_bonus_tao);
function MsgParser:MSG_PLAYER_PRACTICE_DATA(pkt, data)
    data.name = pkt:GetLenString()
    data.status = pkt:GetChar()
    data.xiuls_level = pkt:GetChar()
    data.comfort = pkt:GetShort()
    data.cleanliness = pkt:GetChar()
    data.furniture_id = pkt:GetLong()
    data.furniture_pos = pkt:GetLong()
    data.furniture_durability = pkt:GetShort()
    data.next_bonus_time = pkt:GetLong()
    data.xinmo = pkt:GetChar()
    data.bonus_tao = pkt:GetLong()         -- 修炼效率(已加成后的数值)
    data.rate = pkt:GetChar()              -- 加成家具的加成比例
    data.total_bonus_tao = pkt:GetLong()
end

function MsgParser:MSG_PLAYER_PRACTICE_XINMO_UPDATED(pkt, data)
    data.xinmo = pkt:GetChar()
end

function MsgParser:MSG_PLAYER_PRACTICE_FRIEND_DATA(pkt, data)
    data.gid = pkt:GetLenString()
    data.status = pkt:GetChar()
    data.furniture_id = pkt:GetLong()
    data.polar = pkt:GetChar()
    data.xinmo = pkt:GetChar()
    data.furniture_durability = pkt:GetShort()

end

function MsgParser:MSG_PLAYER_PRACTICE_HELP_TARGETS(pkt, data)
    data.count = pkt:GetShort()
    data.members = {}
    for i = 1, data.count do
        data.members[i] = {}
        data.members[i].gid = pkt:GetLenString()
        data.members[i].flag = pkt:GetChar()
        data.members[i].xinmo = pkt:GetChar()
        data.members[i].friend = pkt:GetLong()
    end
end

function MsgParser:MSG_HOUSE_FURNITURE_EFFECT(pkt, data)
    data.count = pkt:GetShort()
    data.eff = {}
    for i = 1, data.count do
        local pos = pkt:GetLong()
        local endTime = pkt:GetLong()
        local effIcon = pkt:GetLong()
        data.eff[pos] = {endTime = endTime, effIcon = effIcon}
    end
end

function MsgParser:MSG_PLAYER_PRACTICE_HELP_ME_RECORDS(pkt, data)
    data.count = pkt:GetShort()
    data.members = {}
    for i = 1, data.count do
        data.members[i] = {}
        data.members[i].gid = pkt:GetLenString()
        data.members[i].name = pkt:GetLenString()
        data.members[i].icon = pkt:GetLong()
        data.members[i].level = pkt:GetShort()
        data.members[i].clear_xinmo = pkt:GetChar()
        data.members[i].op_time = pkt:GetLong()
        data.members[i].flag = pkt:GetChar()
    end
end


function MsgParser:MSG_HOUSE_CUR_ARTIFACT_PRACTICE(pkt, data)
    data.furniture_pos = pkt:GetLong()
    data.furniture_name = pkt:GetLenString()
    data.dur = pkt:GetLong()
    data.max_dur = pkt:GetLong()
    data.nimbus = pkt:GetLong()
    data.max_nimbus = pkt:GetLong()
    if data.furniture_pos ~= 0 then
        data.artifact = {}
        Builders:BuildItemInfo(pkt, data.artifact)
    end
end

-- 给客户端发送当前正在修炼玩家的精简数据
function MsgParser:MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO(pkt, data)
    data.furniture_name = pkt:GetLenString()
    data.dur = pkt:GetLong()
    data.xinmo = pkt:GetLong()
end

-- 切换当前状态
function MsgParser:MSG_CHANGE_ME_STATE(pkt, data)
    data.toState = pkt:GetLenString()
    data.para = pkt:GetLenString()
    data.logStr = pkt:GetLenString()
end

function MsgParser:MSG_ZCS_FURNITURE_APPLY_DATA(pkt, data)
    data.totalNum = pkt:GetChar()
    data.leftNum = pkt:GetChar()
end

function MsgParser:MSG_PLAY_ZCS_EFFECT(pkt, data)
    data.pos = pkt:GetLong()
end

function MsgParser:MSG_PLAY_CHAR_ACTION(pkt, data)
    data.id = pkt:GetLong()
    data.action = pkt:GetLong()
    data.loops = pkt:GetLong()
end

function MsgParser:MSG_AUTUMN_2017_START(pkt, data)
    data.ready_time = pkt:GetChar()  -- 准备时间
    data.game_time = pkt:GetChar()   -- 持续时间
    data.count = pkt:GetChar()       -- 月饼数量
    for i = 1, data.count do
        local mount = {}
        mount.gid = pkt:GetLenString()   -- 月饼 GID
        mount.type = pkt:GetLenString() -- 月饼 类型 ： wuren / dousha / xiangong / shitou
        mount.time = pkt:GetLong()      -- 月饼 刷新时间（时间参考对象为游戏开始时间）
        table.insert(data, mount)
    end
end

-- 结束中秋节小游戏
function MsgParser:MSG_AUTUMN_2017_FINISH(pkt, data)
    data.score = pkt:GetShort()           -- 分数
    data.highest_score = pkt:GetShort()         -- 最高分数
    data.wuren_count = pkt:GetChar()     -- 五仁月饼数量
    data.dousha_count = pkt:GetChar()    -- 豆沙月饼数量
    data.xiangong_count = pkt:GetChar()  -- 仙宫月饼数量
    data.shitou_count = pkt:GetChar()    -- 石头数量
    data.bonus_exp = pkt:GetLong()       -- 奖励经验
    data.bonus_tao = pkt:GetLong()      -- 奖励道行
    data.bonus_item = pkt:GetLenString()      -- 奖励道具
    data.bonus_type = pkt:GetLenString()     -- 奖励类型，其中 exp = 经验奖励（默认奖励类型），tao = 道行奖励
end

-- 通知客户端退出小游戏
function MsgParser:MSG_AUTUMN_2017_QUIT(pkt, data)
    data.type = pkt:GetLenString()      -- pause = 暂停游戏， resume = 恢复游戏，stop = 结束游戏
    data.left_time = pkt:GetChar()     -- 剩余时间
end


-- 通知接取月饼结果
function MsgParser:MSG_AUTUMN_2017_PLAY(pkt, data)
    data.gid = pkt:GetLenString()    -- 月饼 GID
    data.type = pkt:GetLenString()  -- 月饼 类型 ： wuren / dousha / xiangong / shitou
    data.score = pkt:GetChar()  -- 月饼分数
    data.total_score = pkt:GetShort()    -- 总积分
    data.wuren_count = pkt:GetShort()    -- 五仁月饼数量
    data.dousha_count = pkt:GetShort()   -- 豆沙月饼数量
    data.xiangong_count = pkt:GetShort()  -- 仙宫月饼数量
end

-- 天墉城阅兵动画
function MsgParser:MSG_NATIONAL_TYCYB(pkt, data)
    data.action = pkt:GetLong()      -- 动作 （ACTION_CAST_MAGIC表示法术攻击，ACTION_PHYSICAL_ATTACK表示物理攻击）
    data.cast_effect = pkt:GetLong() -- 技能光效
    data.d4_effect = pkt:GetLong()   -- 辅助光效
    data.speack_content = pkt:GetLenString() -- 头顶喊话
    data.no_dalay = pkt:GetChar() -- 不延时喊话
    data.speck_count = pkt:GetLong()
    data.speck_npc = {}
    for i = 1, data.speck_count do
        local id = pkt:GetLong()
        table.insert(data.speck_npc, id)
    end
end

-- 过图失败
function MsgParser:MSG_TELEPORT_FAILED(pkt, data)
    data.fail_msg = pkt:GetLenString()
end

function MsgParser:MSG_MAP_NPC(pkt, data)
    data.icon = pkt:GetLong()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.ox = pkt:GetSignedChar()
    data.oy = pkt:GetSignedChar()
    data.flip = pkt:GetChar()
end

function MsgParser:MSG_HOUSE_FARM_DATA(pkt, data)
    data.active_farm_count = pkt:GetChar()   -- 已开垦农田数量
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.farm_index = pkt:GetChar() + 1   -- 农田编号转为 1~16
        info.class_id = pkt:GetLong()     -- 种子或者树苗的编号
        info.start_time = pkt:GetLong()   -- 开始种植时间
        info.status = pkt:GetChar()      -- 状态
        info.isMy = pkt:GetChar()
        info.name = pkt:GetLenString()    -- 农作物主人名字
        data[info.farm_index] = info
    end
end

function MsgParser:MSG_HOUSE_SHOW_FARM_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.active_farm_count = pkt:GetChar()   -- 已开垦农田数量
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.farm_index = pkt:GetChar() + 1   -- 农田编号转为 1~16
        info.class_id = pkt:GetLong()     -- 种子或者树苗的编号
        info.start_time = pkt:GetLong()   -- 开始种植时间
        data[info.farm_index] = info
    end
end

function MsgParser:MSG_FARM_PLAY_EFFECT(pkt, data)
    data.farm_index = pkt:GetChar() + 1
    data.clear_status = pkt:GetChar()
end

-- 服务器通知客户端战场实时数据
function MsgParser:MSG_CSL_LIVE_SCORE(pkt, data)
    data.our_dist = pkt:GetLenString()          -- 我方区组名称
    data.other_dist = pkt:GetLenString()        -- 对方方区组名称
    data.our_score = pkt:GetLong()              -- 我方积分
    data.other_score = pkt:GetLong()            -- 对方积分
    data.score = pkt:GetLong()                  -- 自己的积分，特殊玩家为 0
    data.contrib = pkt:GetLong()                  -- 自己的贡献积分
    data.start_time = pkt:GetLong()                  -- 开始时间
    data.pair_time = pkt:GetLong()                  -- 开始匹配时间
    data.end_time = pkt:GetLong()                  -- end_time
end

-- 通知客户端比赛时间
function MsgParser:MSG_CSL_ROUND_TIME(pkt, data)
    data.season_no = pkt:GetShort()         --
    data.total_round = pkt:GetShort()       --
    data.group_round = pkt:GetShort()       --
    data.match_duration = pkt:GetLong()     --
    data.ti_count = pkt:GetShort()          --
    for i = 1, data.ti_count do
        data[i] = pkt:GetLong()                 --
    end
end

-- 通知客户端联赛所有简要信息
function MsgParser:MSG_CSL_ALL_SIMPLE(pkt, data)
    data.seasonNo = pkt:GetShort()         -- 最大届数
    data.seasonData = {}
    for i = 1, data.seasonNo do
        data.seasonData[i] = {}
        data.seasonData[i].levelCount = pkt:GetChar()                       -- 该届的等级段数量
        data.seasonData[i].levelData = {}
        for j = 1, data.seasonData[i].levelCount do
            data.seasonData[i].levelData[j] = {}
            data.seasonData[i].levelData[j].minLevel = pkt:GetShort()       -- 该等级段的最小等级
            data.seasonData[i].levelData[j].maxLevel = pkt:GetShort()       -- 该等级段的最大等级
            data.seasonData[i].levelData[j].areaCount = pkt:GetChar()       -- 该等级段的赛区数
            data.seasonData[i].levelData[j].league_no = pkt:GetChar()       -- 当前区组所在的赛区
            data.seasonData[i].levelData[j].group_no = pkt:GetChar()       -- 当前区组所在的赛区
        end
    end
end

-- 通知客户端具体赛区的数据             通过整理后 ret才是最终想要的数据
function MsgParser:MSG_CSL_LEAGUE_DATA(pkt, data)
    data.seasonNo = pkt:GetShort()         -- 最大届数
    data.level = pkt:GetShort()         -- 等级段
    data.area = pkt:GetChar()           -- 赛区
    data.match_duration = pkt:GetLong() -- 单场比赛的持续时间
    data.champion = pkt:GetLenString()

    local ret = {}          -- 通过整理后 ret才是最终想要的数据
    ret.key = string.format("%d|%d|%d", data.seasonNo, data.level, data.area)
    data.group_count = pkt:GetChar() -- 小组数量
    data.group_data1 = {}
    ret.groupInfo = {}
    ret.groupInfo.count = data.group_count
    local distInfo = {}
    local groupWarInfo = {}

    for i = 1, data.group_count do
        data.group_data1[i] = {}
        data.group_data1[i].group_no = pkt:GetChar()
        data.group_data1[i].is_end = pkt:GetChar()
        data.group_data1[i].dist_count = pkt:GetChar()
        data.group_data1[i].dists = {}
        ret.groupInfo[i] = {}
        ret.groupInfo[i].groupNo = data.group_data1[i].group_no
        ret.groupInfo[i].distCount = data.group_data1[i].dist_count
        ret.groupInfo[i].distInfo = {}

        for j = 1, data.group_data1[i].dist_count do
            data.group_data1[i].dists[j] = pkt:GetLenString()
            ret.groupInfo[i].distInfo[j] = {}
            ret.groupInfo[i].distInfo[j].distName = data.group_data1[i].dists[j]

            if not distInfo[ret.groupInfo[i].distInfo[j].distName] then
                distInfo[ret.groupInfo[i].distInfo[j].distName] = {isWinner = (j == 1 and data.group_data1[i].is_end == 1),distName = data.group_data1[i].dists[j], point = 0, score = 0, win = 0, lost = 0, draw = 0}
            end
            if not groupWarInfo[data.group_data1[i].dists[j]] then
                groupWarInfo[data.group_data1[i].dists[j]] = {}
            end
        end
    end

    data.knockout_round_count = pkt:GetChar() -- 淘汰赛轮数
    data.knockout_data1 = {}
    for i = 1, data.knockout_round_count do
        data.knockout_data1[i] = {}
        data.knockout_data1[i].knockout_round_no = pkt:GetChar()
        data.knockout_data1[i].knockout_match_count = pkt:GetChar()
        data.knockout_data1[i].match_ids = {}
        for j = 1, data.knockout_data1[i].knockout_match_count do
            data.knockout_data1[i].match_ids[j] = pkt:GetLenString()
        end
    end

    local startWarTime

    data.group_count2 = pkt:GetChar() -- 小组数量
    data.group_data2 = {}
    for i = 1, data.group_count2 do
        data.group_data2[i] = {}
        data.group_data2[i].group_no = pkt:GetChar()
        data.group_data2[i].group_match_count = pkt:GetChar()
        data.group_data2[i].group_match_info = {}
        for j = 1, data.group_data2[i].group_match_count do
            data.group_data2[i].group_match_info[j] = {}
            data.group_data2[i].group_match_info[j].match_id = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].match_name = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].start_time = pkt:GetLong()
            data.group_data2[i].group_match_info[j].point = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].score = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].ret_type = pkt:GetChar()

            startWarTime = startWarTime or data.group_data2[i].group_match_info[j].start_time

            if data.group_data2[i].group_match_info[j].point == "" then
                -- 比赛未开始

                local distArr = gf:split(data.group_data2[i].group_match_info[j].match_name, " VS ")
                local dist1, dist2 = distArr[1], distArr[2]

                local pointArr = gf:split(data.group_data2[i].group_match_info[j].point, ":")
                local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])

                local scoreArr = gf:split(data.group_data2[i].group_match_info[j].score, ":")
                local score1, score2 = tonumber(scoreArr[1]), tonumber(scoreArr[2])

                local warInfo1 = {}
                local warInfo2 = {}


                -- 战况信息
                if groupWarInfo[dist1] then
                    warInfo1.myDist = dist1
                    warInfo1.enemyDist = dist2
                    warInfo1.start_time = data.group_data2[i].group_match_info[j].start_time

                    table.insert(groupWarInfo[dist1], warInfo1)
                end
                if groupWarInfo[dist2] then
                    warInfo2.myDist = dist2
                    warInfo2.enemyDist = dist1
                    warInfo2.start_time = data.group_data2[i].group_match_info[j].start_time
                    table.insert(groupWarInfo[dist2], warInfo2)
                end

            else
                local distArr = gf:split(data.group_data2[i].group_match_info[j].match_name, " VS ")
                local dist1, dist2 = distArr[1], distArr[2]

                local pointArr = gf:split(data.group_data2[i].group_match_info[j].point, ":")
                local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])

                local scoreArr = gf:split(data.group_data2[i].group_match_info[j].score, ":")
                local score1, score2 = tonumber(scoreArr[1]), tonumber(scoreArr[2])

                local warInfo1 = {}
                local warInfo2 = {}
                if point1 > point2 then
                    distInfo[dist1].win = distInfo[dist1].win + 1
                    distInfo[dist2].lost = distInfo[dist2].lost + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 1 -- 赢了
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 2 -- 输了
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                elseif point1 < point2 then
                    distInfo[dist1].lost = distInfo[dist1].lost + 1
                    distInfo[dist2].win = distInfo[dist2].win + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 2 -- 输了
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 1 -- 赢了
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                else
                    distInfo[dist1].draw = distInfo[dist1].draw + 1
                    distInfo[dist2].draw = distInfo[dist2].draw + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 3 -- 平局
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 3 -- 平局
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                end

                -- 战况信息
                if groupWarInfo[dist1] then
                    warInfo1.myDist = dist1
                    warInfo1.enemyDist = dist2
                    warInfo1.start_time = data.group_data2[i].group_match_info[j].start_time

                    table.insert(groupWarInfo[dist1], warInfo1)
                end
                if groupWarInfo[dist2] then
                    warInfo2.myDist = dist2
                    warInfo2.enemyDist = dist1
                    warInfo2.start_time = data.group_data2[i].group_match_info[j].start_time
                    table.insert(groupWarInfo[dist2], warInfo2)
                end

                distInfo[dist1].point = distInfo[dist1].point + point1
                distInfo[dist2].point = distInfo[dist2].point + point2
            end
        end
    end

    ret.distInfo = distInfo
    ret.groupWarInfo = groupWarInfo
    ret.startWarTime = startWarTime
    ret.match_duration = data.match_duration

    local knockoutInfo = {}

    data.knockout_round_count2 = pkt:GetChar() -- 淘汰赛轮数
    data.knockout_data2 = {}
    for i = 1, data.knockout_round_count2 do
        data.knockout_data2[i] = {}
        data.knockout_data2[i].knockout_round_no = pkt:GetChar()
        data.knockout_data2[i].knockout_match_count = pkt:GetChar()
        data.knockout_data2[i].match_info = {}
        local oneRound = {}
        for j = 1, data.knockout_data2[i].knockout_match_count do
            data.knockout_data2[i].match_info[j] = {}
            data.knockout_data2[i].match_info[j].match_id = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].match_name = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].start_time = pkt:GetLong()
            data.knockout_data2[i].match_info[j].point = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].score = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].ret_type = pkt:GetChar()

            -- 小组赛未结束，淘汰赛match_name 为空字符串
            if data.knockout_data2[i].match_info[j].match_name ~= "" then
                local unitData = {}

                local distArr = gf:split(data.knockout_data2[i].match_info[j].match_name, " VS ")
                unitData[1] = distArr[1]
                unitData[2] = distArr[2]

                if data.knockout_data2[i].match_info[j].point == "" then
                    unitData.winner = ""
                    unitData.winnerNo = ""
                else
                    local pointArr = gf:split(data.knockout_data2[i].match_info[j].point, ":")
                    local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])
                    if point1 > point2 then
                        unitData.winner = distArr[1]
                        unitData.winnerNo = (j - 1) * 2 + 1
                    else
                        unitData.winner = distArr[2]
                        unitData.winnerNo = (j - 1) * 2 + 2
                    end
                end

                unitData["start_time"] = data.knockout_data2[i].match_info[j].start_time
                table.insert(oneRound, unitData)
            else
                table.insert(oneRound, {[1] = "", [2] = "", start_time = data.knockout_data2[i].match_info[j].start_time, winnerNo = "", winner = ""})
            end
        end

        table.insert(knockoutInfo, oneRound)
    end

    ret.knockoutInfo = knockoutInfo
    data.ret = ret
end

-- 通知积分界面简要信息
function MsgParser:MSG_CSL_MATCH_SIMPLE(pkt, data)
    data.total_round = pkt:GetChar()                -- 联赛总轮数
    data.group_round = pkt:GetChar()                -- 小组赛轮数
    data.level_section_count = pkt:GetChar()        -- 等级段数量
    data.levelRangeInfo = {}                        -- 等级段信息

    for i = 1, data.level_section_count do
        local levelRangeInfo = {}
        levelRangeInfo.level_min = pkt:GetShort()       -- 最低等级
        levelRangeInfo.level_max = pkt:GetShort()       -- 最高等级
        levelRangeInfo.league_no = pkt:GetChar()        -- 当前区组所属赛区，没有比赛为 0
        levelRangeInfo.group_no = pkt:GetChar()         -- 当前区组所属小组，没有比赛为 0
        levelRangeInfo.has_total_top = pkt:GetChar()    -- 是否已经有总积分榜了
        levelRangeInfo.group_end = pkt:GetChar()        -- 小组赛是否已经结束
        levelRangeInfo.group_match_count = pkt:GetChar()    -- 小组赛数量
        levelRangeInfo.groupMatchData = {}
        for j = 1, levelRangeInfo.group_match_count do
            levelRangeInfo.groupMatchData[j] = {}
            levelRangeInfo.groupMatchData[j].match_id = pkt:GetLenString()
            levelRangeInfo.groupMatchData[j].match_name = pkt:GetLenString()
            levelRangeInfo.groupMatchData[j].start_time = pkt:GetLong()
            levelRangeInfo.groupMatchData[j].point = pkt:GetLenString()
            levelRangeInfo.groupMatchData[j].score = pkt:GetLenString()
            levelRangeInfo.groupMatchData[j].ret_type = pkt:GetChar()
            levelRangeInfo.groupMatchData[j].round = pkt:GetChar()
        end

        levelRangeInfo.knockout_match_count = pkt:GetChar()           -- 淘汰赛数量
        levelRangeInfo.knockoutInfo = {}                              -- 淘汰赛信息
        for j = 1, levelRangeInfo.knockout_match_count do
            levelRangeInfo.knockoutInfo[j] = {}
            levelRangeInfo.knockoutInfo[j].match_id = pkt:GetLenString()
            levelRangeInfo.knockoutInfo[j].match_name = pkt:GetLenString()
            levelRangeInfo.knockoutInfo[j].start_time = pkt:GetLong()
            levelRangeInfo.knockoutInfo[j].point = pkt:GetLenString()
            levelRangeInfo.knockoutInfo[j].score = pkt:GetLenString()
            levelRangeInfo.knockoutInfo[j].ret_type = pkt:GetChar()
            levelRangeInfo.knockoutInfo[j].round = pkt:GetChar()
        end

        data.levelRangeInfo[i] = levelRangeInfo
    end
end

-- 通知客户端个人总积分数据
function MsgParser:MSG_CSL_CONTRIB_TOP_DATA(pkt, data)
    data.count = pkt:GetChar()
    data.rankInfo = {}
    for i = 1, data.count do
        data.rankInfo[i] = {}
        data.rankInfo[i].rank = pkt:GetShort()
        data.rankInfo[i].gid = pkt:GetLenString()
        data.rankInfo[i].name = pkt:GetLenString()
        data.rankInfo[i].level = pkt:GetShort()
        data.rankInfo[i].polar = pkt:GetChar()
        data.rankInfo[i].contrib = pkt:GetLong()
        data.rankInfo[i].combat = pkt:GetShort()
        data.rankInfo[i].win = pkt:GetShort()
    end
    data.myCount = pkt:GetChar()    -- 为0代表未上榜，1则取相关数据
    data.myRankInfo = {}
    for i = 1, data.myCount do
        data.myRankInfo[i] = {}
        data.myRankInfo[i].rank = pkt:GetShort()
        data.myRankInfo[i].gid = pkt:GetLenString()
        data.myRankInfo[i].name = pkt:GetLenString()
        data.myRankInfo[i].level = pkt:GetShort()
        data.myRankInfo[i].polar = pkt:GetChar()
        data.myRankInfo[i].contrib = pkt:GetLong()
        data.myRankInfo[i].combat = pkt:GetShort()
        data.myRankInfo[i].win = pkt:GetShort()
    end
end

function MsgParser:MSG_CSL_MATCH_DATA(pkt, data)
    data.level = pkt:GetShort()
    data.name = pkt:GetLenString()
    data.rankInfo = {}
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data.rankInfo[i] = {}
        data.rankInfo[i].rank = pkt:GetShort()
        data.rankInfo[i].gid = pkt:GetLenString()
        data.rankInfo[i].name = pkt:GetLenString()
        data.rankInfo[i].level = pkt:GetShort()
        data.rankInfo[i].polar = pkt:GetChar()
        data.rankInfo[i].contrib = pkt:GetLong()
        data.rankInfo[i].combat = pkt:GetShort()
        data.rankInfo[i].win = pkt:GetShort()
    end
end

function MsgParser:MSG_CSL_MATCH_DATA_COMPETE(pkt, data)
    data.level_min = pkt:GetShort()
    data.level_max = pkt:GetShort()
    data.total_round = pkt:GetChar()                -- 联赛总轮数
    data.group_round = pkt:GetChar()                -- 小组赛轮数
    data.round = pkt:GetChar()                      -- 当前轮数
    data.dist = pkt:GetLenString()                  -- 查看积分的区组
    data.match_name = pkt:GetLenString()            -- 比赛名称
    data.start_time = pkt:GetLong()                 -- 开始时间
    data.point = pkt:GetLenString()                 -- 比赛结果情况
    data.score = pkt:GetLenString()                 -- 比分情况
    data.ret_type = pkt:GetChar()                   -- 小组赛轮数
    data.count = pkt:GetChar()                      -- 数量
    data.rankInfo = {}
    for i = 1, data.count do
        data.rankInfo[i] = {}
        data.rankInfo[i].rank = pkt:GetShort()
        data.rankInfo[i].gid = pkt:GetLenString()
        data.rankInfo[i].name = pkt:GetLenString()
        data.rankInfo[i].level = pkt:GetShort()
        data.rankInfo[i].polar = pkt:GetChar()
        data.rankInfo[i].contrib = pkt:GetLong()
        data.rankInfo[i].combat = pkt:GetShort()
        data.rankInfo[i].win = pkt:GetShort()
    end
    data.myCount = pkt:GetChar()    -- 为0代表未上榜，1则取相关数据
    data.myRankInfo = {}
    for i = 1, data.myCount do
        data.myRankInfo[i] = {}
        data.myRankInfo[i].rank = pkt:GetShort()
        data.myRankInfo[i].gid = pkt:GetLenString()
        data.myRankInfo[i].name = pkt:GetLenString()
        data.myRankInfo[i].level = pkt:GetShort()
        data.myRankInfo[i].polar = pkt:GetChar()
        data.myRankInfo[i].contrib = pkt:GetLong()
        data.myRankInfo[i].combat = pkt:GetShort()
        data.myRankInfo[i].win = pkt:GetShort()
    end
end

function MsgParser:MSG_CSL_FETCH_BONUS(pkt, data)
    data.title = pkt:GetLenString()                 -- 称谓
    data.contrib = pkt:GetLong()                    -- 贡献积分
    data.rank = pkt:GetChar()                       -- 名次
end

function MsgParser:MSG_HOUSE_ENTRUST(pkt, data)
    data.finish = pkt:GetChar()
    data.limit = pkt:GetChar()
    data.count = pkt:GetChar()
    data.npcs = {}

    for i = 1, data.count do
        local npc = {}
        npc.index = pkt:GetChar()
        npc.eid = pkt:GetChar()
        npc.npc_name = pkt:GetLenString()
        npc.npc_icon = pkt:GetLong()
        npc.m_name = pkt:GetLenString()
        npc.m_num = pkt:GetLong()
        npc.p_name = pkt:GetLenString()
        npc.p_num = pkt:GetLong()
        table.insert(data.npcs, npc)

        -- WDSY-23067 中改名
        if npc.m_name == CHS[5400202] then
            npc.m_name = CHS[5400196]
    	end
end
end


function MsgParser:MSG_HOUSE_FISH_BASIC(pkt, data)
    -- 玩家的基础数据
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.level = pkt:GetLong()
    data.is_married = pkt:GetChar()

    if data.is_married == 1 then
        -- 夫妻的基础数据
        local couple = {}
        couple.gid = pkt:GetLenString()
        couple.name = pkt:GetLenString()
        couple.icon = pkt:GetLong()
        data.couple = couple
    end

    -- 玩家的钓鱼数据
    data.fish_level = pkt:GetLong()      -- 钓鱼等级
    data.proficiency = pkt:GetLong()     -- 当前熟练度
    data.max_proficiency = pkt:GetLong() -- 最大熟练度
    data.today_fishing_time = pkt:GetLong() --
    data.pole_name = pkt:GetLenString()
    data.bait_name = pkt:GetLenString()
    data.pole_count = pkt:GetLong()
    data.bait_count = pkt:GetLong()
    data.key = pkt:GetLenString()
    data.cur_status = pkt:GetLenString()

    -- 玩家的历史钓鱼数据
    data.count = pkt:GetLong()
    data.his_info = {}
    for i = 1, data.count do
        local info = {}
        info.time = pkt:GetLong()  -- 时间
        info.level = pkt:GetLong() -- 鱼的等级
        info.fish_name = pkt:GetLenString()  -- 鱼的名字
        table.insert(data.his_info, info)
    end
end

-- 当前使用的渔具
function MsgParser:MSG_HOUSE_USE_FISH_TOOL(pkt, data)
    data.gid = pkt:GetLenString()
    data.pole_name = pkt:GetLenString()
    data.bait_name = pkt:GetLenString()
    data.pole_count = pkt:GetLong()
    data.bait_count = pkt:GetLong()
end

-- 抛竿状态
function MsgParser:MSG_HOSUE_FISH_PAOGAN(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 浮标跑动状态
function MsgParser:MSG_HOSUE_FISH_FUBIAOPAODONG(pkt, data)
    data.gid = pkt:GetLenString()
    data.start_time = pkt:GetLong()
    data.count = pkt:GetLong()
    for i = 1, data.count do
        local no = pkt:GetChar() + 1
        table.insert(data, no)
    end
end

-- 浮标跑动失败状态
function MsgParser:MSG_HOSUE_FISH_FUBIAOPAODONG_FAIL(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 拉扯状态
function MsgParser:MSG_HOSUE_FISH_LACHE(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 拉扯失败状态
function MsgParser:MSG_HOSUE_FISH_LACHE_FAIL(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 钓鱼成功状态
function MsgParser:MSG_HOSUE_FISH_SUCC(pkt, data)
    data.gid = pkt:GetLenString()
    data.level = pkt:GetLong()
    data.fish_name = pkt:GetLenString()
end

-- 所有渔具的数据
function MsgParser:MSG_HOUSE_ALL_FISH_TOOL_INFO(pkt, data)
    data.gid = pkt:GetLenString()

    -- 鱼竿数据
    data.pole_count = pkt:GetChar()
    data.poles = {}
    for i = 1, data.pole_count do
        local name = pkt:GetLenString()
        local num = pkt:GetLong()
        data.poles[name] = num
    end

    -- 鱼饵数据
    data.bait_count = pkt:GetChar()
    data.baits = {}
    for i = 1, data.bait_count do
        local name = pkt:GetLenString()
        local num = pkt:GetLong()
        data.baits[name] = num
    end
end

-- 部分渔具的数据
function MsgParser:MSG_HOUSE_FISH_TOOL_PART_INFO(pkt, data)
    data.gid = pkt:GetLenString()
    data.tool_type = pkt:GetChar() -- 渔具类型 (1: 鱼竿，2: 鱼饵)
    data.count = pkt:GetChar()
    data.tools = {}
    for i = 1, data.count do
        local name = pkt:GetLenString()
        local num = pkt:GetLong()
        data.tools[name] = num
    end
end

-- 退出钓鱼状态
function MsgParser:MSG_HOSUE_QUIT_FISH(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 钓鱼夫妻改名
function MsgParser:MSG_HOUSE_FISH_CHANGE_NAME(pkt, data)
    data.gid = pkt:GetLenString()
    data.old_name = pkt:GetLenString()
    data.new_name = pkt:GetLenString()
end

--
function MsgParser:MSG_EXCHANGE_MATERIAL_TARGETS(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()    -- 好友 gid
        info.total_need = pkt:GetChar()  -- 还需要多少个材料才能集满，用于排序
        info.exchange_times = pkt:GetChar() -- 今日已赠送次数
        table.insert(data, info)
    end
end

function MsgParser:MSG_FRIEND_EXCHANGE_MATERIAL_DATA(pkt, data)
    data.gid = pkt:GetLenString()    -- 好友 gid
    data.msg = pkt:GetLenString()    -- 附言
    data.exchange_times = pkt:GetChar()    -- 今日已赠送次数
    data.need_count = pkt:GetShort()  --需求材料类别数
    data.needs = {}
    for i = 1, data.need_count do
        local info = {}
        info.pos = pkt:GetChar()
        info.name = pkt:GetLenString()  -- 材料名
        info.req_num = pkt:GetChar()   -- 需求材料数量
        info.get_num = pkt:GetChar()   -- 已获取的数量
        table.insert(data.needs, info)

        -- WDSY-23067 中改名
        if info.name == CHS[5400202] then
            info.name = CHS[5400196]
    	end
    end

    data.gifts = {}
    data.gift_count = pkt:GetShort()   -- 赠礼材料类别数
    for i = 1, data.gift_count do
        local info = {}
        info.pos = pkt:GetChar()
        info.name = pkt:GetLenString() -- 材料名
        info.num = pkt:GetChar()       --
        if info.num > 0 then
            table.insert(data.gifts, info)

            -- WDSY-23067 中改名
            if info.name == CHS[5400202] then
                info.name = CHS[5400196]
        	end
    	end
end
end

-- 可领取的材料邮件
function MsgParser:MSG_MATERIAL_MAILBOX_REFRESH(pkt, data)
    data.count = pkt:GetShort()
    data.info = {}
    for i = 1, data.count do
        local info  = {}
        info.id = pkt:GetLenString()
        info.sender = pkt:GetLenString()
        info.sender_icon = pkt:GetLong()
        info.sender_level = pkt:GetShort()
        info.attachment = pkt:GetLenString()
        info.create_time = pkt:GetLong()
        data.info[i] = info

        -- WDSY-23067 中改名
        info.attachment = string.gsub(info.attachment, CHS[5400202], CHS[5400196])
    end
end

-- 通知客户端某个材料邮件被领取
function MsgParser:MSG_FETCH_MATERIAL_MAIL(pkt, data)
    data.id = pkt:GetLenString()
    data.remain_times = pkt:GetChar()
end

-- 战斗无条件使用捕捉
function MsgParser:MSG_C_UNRESERVED_CATCH(pkt, data)
    data.count = pkt:GetChar()
end

-- 玩家自己的材料交换数据
function MsgParser:MSG_ME_EXCHANGE_MATERIAL_DATA(pkt, data)
    data.is_publish = pkt:GetChar()
    data.has_material_unfetch = pkt:GetChar()
    data.msg = pkt:GetLenString()
    data.needCount = pkt:GetShort()
    data.needData = {}
    for i = 1, data.needCount do
        local info = {}
        info.index = pkt:GetChar()
        info.name = pkt:GetLenString()
        info.req_num = pkt:GetChar()
        info.get_num = pkt:GetChar()
        data.needData[info.index] = info

        -- WDSY-23067 中改名
        if info.name == CHS[5400202] then
            info.name = CHS[5400196]
    	end
    end

    data.giftCount = pkt:GetShort()
    data.giftData = {}
    for i = 1, data.giftCount do

        local info = {}
        info.index = pkt:GetChar()
        info.name = pkt:GetLenString()
        info.num = pkt:GetChar()
        data.giftData[info.index] = info

        -- WDSY-23067 中改名
        if info.name == CHS[5400202] then
            info.name = CHS[5400196]
    	end
    end

    data.isNoSet = (data.needCount == 0 and data.giftCount == 0)
end

-- 战斗无条件使用捕捉
function MsgParser:MSG_TYCYB_TURN_DIR(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].npc_id = pkt:GetLong()
        data[i].x = pkt:GetLong()
        data[i].y = pkt:GetLong()
        data[i].dir = pkt:GetChar()
    end
end

-- 农田数据，用于居所入口界面显示
function MsgParser:MSG_HOUSE_REQUEST_FARM_INFO(pkt, data)
    data.farm_num = pkt:GetShort()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.farm_index = pkt:GetChar()
        info.class_id = pkt:GetLong()
        info.start_time = pkt:GetLong()
        info.status = pkt:GetChar()
        table.insert(data, info)
    end
end

function MsgParser:MSG_HOUSE_OTHER_FURNITURE_DATA(pkt, data)
    data.home_type = pkt:GetChar()          -- 居所类型
    data.bed_icon = pkt:GetLong()           -- 床的图标
    data.bedroom_type = pkt:GetChar()       -- 卧室类型
    data.max_rest_count = pkt:GetChar()     -- 最大休息次数
    data.cur_rest_count = pkt:GetChar()     -- 当前已经休息次数
    data.max_fish_count = pkt:GetChar()     -- 最大钓鱼次数
    data.cur_fish_count = pkt:GetChar()     -- 当前已经钓鱼次数
    data.max_nafu_count = pkt:GetChar()     -- 最大纳福次数
    data.cur_nafu_count = pkt:GetChar()     -- 当前已经纳福次数
    data.max_cleanliness = pkt:GetShort()    -- 最大清洁度
    data.cur_cleanliness = pkt:GetShort()    -- 当前清洁度
end

-- 请求需要帮助的好友列表
function MsgParser:MSG_HOUSE_FARM_HELP_TARGETS(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.house_id = pkt:GetLenString()
        info.rederel_num = pkt:GetChar()
        info.insect_num = pkt:GetChar()
        info.water_num = pkt:GetChar()
        info.has_feitan = pkt:GetChar()
        table.insert(data, info)
    end
end

-- 通知需要帮助的好友列表数量
function MsgParser:MSG_HOUSE_FARM_HELP_TARGETS_NUM(pkt, data)
    data.num = pkt:GetShort()
end

-- 通知好友协助记录
function MsgParser:MSG_HOUSE_FARM_HELP_RECORDS(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.time = pkt:GetLong()
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.icon = pkt:GetShort()
        info.level = pkt:GetShort()
        info.rederel_num = pkt:GetChar()
        info.insect_num = pkt:GetChar()
        info.water_num = pkt:GetChar()
        info.total = pkt:GetShort()
        table.insert(data, info)
    end
end

-- 中秋博饼购买信息
function MsgParser:MSG_AUTUMN_2017_BUY(pkt, data)
    data.count = pkt:GetChar()
    data.max_count = pkt:GetChar()
    data.price = pkt:GetShort()
end

-- 活动额外数据
function MsgParser:MSG_ACTIVITY_EXTRA_DATA(pkt, data)
    data.count = pkt:GetChar()
    data.extraInfo = { }
    for i = 1, data.count do
        data.extraInfo[pkt:GetLenString()] = pkt:GetLenString()
    end
end


-- 通知活动开启信息
function MsgParser:MSG_PARTY_TZJS_SETUP(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
end

-- 通知挑战巨兽信息
function MsgParser:MSG_PARTY_TZJS_INFO(pkt, data)
    data.is_open = pkt:GetChar()
    data.start_time_chanllenge = pkt:GetLong()
    data.end_time_chanllenge = pkt:GetLong()
    data.end_time_active = pkt:GetLong()
    data.end_time_protect = pkt:GetLong()
    data.life = pkt:GetLong()
    data.max_life = pkt:GetLong()

    data.py_life = pkt:GetShort()
    data.py_phy_power = pkt:GetShort()
    data.py_mag_power = pkt:GetShort()
    data.py_speed = pkt:GetShort()
    data.py_tao = pkt:GetShort()

    data.growth = pkt:GetShort()
    data.grow_dest = pkt:GetShort()

    data.playerCount = pkt:GetShort()
    local playersInfo = {}
    for i = 1, data.playerCount do
        local one = {}
        one.name = pkt:GetLenString()

        one.contrib = pkt:GetLong()
        table.insert(playersInfo, one)
    end

    table.sort(playersInfo, function(l, r)
        if l.contrib > r.contrib then return true end
        if l.contrib < r.contrib then return false end
    end)

    data.playersInfo = playersInfo

    -- 由于     WDSY-30827 任务，改成分页加载，所以需要排序后，找出自己的排行
    for i = 1, data.playerCount do
        if playersInfo[i].name == Me:queryBasic("name") then
            data.myRinkInfo = playersInfo[i]
            data.myRank = i
        end
    end

    data.newsInfo = {}
    data.newsCount = pkt:GetShort()

    for i = 1, data.newsCount do
        local one = {}
        one.end_time = pkt:GetLong()
        one.name = pkt:GetLenString()
        one.damage = pkt:GetLong()
        one.contribution = pkt:GetLong()
        one.isMyTeam = pkt:GetChar()
        table.insert(data.newsInfo, one)
    end

    table.sort(data.newsInfo, function(l, r)
        if l.end_time > r.end_time then return true end
        if l.end_time < r.end_time then return false end
    end)


end

-- 重阳节品尝菜肴返回消息
function MsgParser:MSG_CHONGYANG_2017_TASTE(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.npc_id = pkt:GetLong()
    data.type = pkt:GetChar()
    data.taste = pkt:GetChar()
    data.amount1 = pkt:GetShort()
    data.amount2 = pkt:GetShort()
    data.amount3 = pkt:GetShort()
end

-- 已拥有管家的数据
function MsgParser:MSG_HOUSE_ALL_GUANJIA_INFO(pkt, data)
    data.cur_select_gj_type = pkt:GetLenString()
    local count = pkt:GetChar()
    data.gjs = {}
    data.gj_count = count
    for i = 1, count do
        data.gjs[pkt:GetLenString()] = { gj_name = pkt:GetLenString() }
    end
end

function MsgParser:MSG_HOUSE_GJ_ACTION(pkt, data)
    data.npc_id = pkt:GetLong()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_HOUSE_ALL_YH_INFO(pkt, data)
    local count = pkt:GetChar()
    data.npcs = {}
    for i = 1, count do
        table.insert(data.npcs, { yh_type = pkt:GetLenString(), name = pkt:GetLenString() })
    end
end

function MsgParser:MSG_HOUSE_REST_ANIMATE(pkt, data)
    data.furniture_pos = pkt:GetLong()
    data.count = pkt:GetChar()     -- 1 单人，2双人
    data.isPlay = pkt:GetChar()  -- 1 开始， 2 停止
end

function MsgParser:MSG_COMEBACK_COIN_SHOP_ITEM_LIST(pkt, data)
    data.count = pkt:GetChar()

    for i = 1, data.count do
        data[i] = {}
        data[i].good_id = pkt:GetChar()
        data[i].day = pkt:GetChar()
        data[i].coin = pkt:GetLong()
        data[i].reward_desc = pkt:GetLenString()
        data[i].status = pkt:GetChar()
    end
end

function MsgParser:MSG_COMEBACK_SEVEN_GIFT_ITEM_LIST(pkt, data)
   data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].day = pkt:GetChar()
        data[i].reward_desc = pkt:GetLenString()
        data[i].status = pkt:GetChar()
    end

    data.fetch_equip_type = pkt:GetLenString()
end

function MsgParser:MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST(pkt, data)
    data.equip_attrib = pkt:GetLenString()
    for i = 1, 4 do
        local item = {}
        Builders:BuildItemInfo(pkt, item)
        data[i] = item
    end
end

-- 通知客户端最近联系人的状态
function MsgParser:MSG_TEMP_FRIEND_STATE(pkt, data)
    data.gid = pkt:GetLenString()   -- 好友gid
    data.online = pkt:GetChar()     -- 好友在线状态（2 表示离线，1 表示在线）
end

function MsgParser:MSG_HOUSE_ALL_YD_INFO(pkt, data)
    data.yd_type = pkt:GetLenString()
    data.yd_name = pkt:GetLenString()
end

-- 通知客户端挑战巨兽结算数据  挑战巨兽
function MsgParser:MSG_PARTY_TZJS_COMBAT_INFO(pkt, data)
    data.tao = pkt:GetLenString()        -- 道行
    data.martial = pkt:GetLong()         -- 武学
    data.contribution = pkt:GetLong()       -- 获得贡献
    data.active = pkt:GetLong()       -- 获得贡献

    data.team_user_count = pkt:GetChar()
    for i = 1, data.team_user_count do
        data[i] = {}
        data[i].pingjia = pkt:GetChar()     -- 评价（0 表示没有，1 表示 MVP，2 表示神医，3 表示神封）
        data[i].name = pkt:GetLenString()   -- 角色名

        data[i].contribution = pkt:GetLong()       -- 获得贡献
        data[i].curRank = pkt:GetShort()           -- 当前排名
        data[i].rankChange = pkt:GetSignedLong()        -- 排名变化（正数表示上升，负数表示下降，0 表示不变）。
    end
end

-- 通知客户端排行信息（按名次先后排序）
function MsgParser:MSG_PARTY_TZJS_RANK_INFO(pkt, data)
     data.end_time = pkt:GetLong()       -- 挑战结束时间
     data.count = pkt:GetShort()         -- 数据数目
     for i = 1, data.count do
        data[i] = {}
        data[i].name = pkt:GetLenString()   -- 角色名
        data[i].contrib = pkt:GetLong()     -- 贡献度
     end
end

-- 商品列表 2017光棍节
function MsgParser:MSG_SINGLES_2017_GOODS_LIST(pkt, data)
    data.start_ti = pkt:GetLong()
    data.end_ti = pkt:GetLong()
    data.update_ti = pkt:GetLong()
    data.cost_cash = pkt:GetLong()
    data.buy_flag = pkt:GetChar()   --  flag == 0 时 普通刷新；flag == 1 时 购买成功后的商品刷新； flag == 2 时 购买失败后的商品刷新 <-- 新增
    data.buy_count = pkt:GetChar()
    data.count = pkt:GetChar()

    data.goodsInfo = {}

    data.pet = {}
    data.pet.name = pkt:GetLenString()
    data.pet.quota = pkt:GetChar()
    data.pet.buy_step = pkt:GetChar()
    data.pet.now_step = pkt:GetLong()
    data.pet.req_step = pkt:GetLong()

    data.count = data.count - 1
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.quota = pkt:GetChar()
        item.buy_step = pkt:GetChar()
        item.now_step = pkt:GetLong()
        item.req_step = pkt:GetLong()

        table.insert(data.goodsInfo, item)
    end
end

-- 查看BUFF类家具数据
function MsgParser:MSG_HOUSE_PRACTICE_BUFF_DATA(pkt, data)
    data.pos = pkt:GetLong()
    data.type = pkt:GetChar()
    data.tolerance = pkt:GetShort()
    data.status = pkt:GetChar()
    data.buffValue = pkt:GetChar()
    data.startupBuffValue = pkt:GetChar()
end

-- 刷新BUFF类家具界面
function MsgParser:MSG_HOUSE_REFRESH_PRACTICE_BUFF_DATA(pkt, data)
    data.pos = pkt:GetLong()
    data.tolerance = pkt:GetShort()
    data.status = pkt:GetChar()
    data.buffValue = pkt:GetChar()
    data.startupBuffValue = pkt:GetChar()
end

-- 正处于战斗状态的木桩，客户端用于显示头顶战斗标记
function MsgParser:MSG_HOUSE_COMBATING_PUPPET_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.values = {}
    for i = 1, data.count do
        table.insert(data.values, {id = pkt:GetLong(), state = pkt:GetChar() })
    end
end

-- 服务器通知成就配置
function MsgParser:MSG_ACHIEVE_CONFIG(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}
        data[i].achieve_id = pkt:GetLong()
        data[i].name = pkt:GetLenString()
        data[i].point = pkt:GetLong()
        data[i].progress = pkt:GetLong()
        data[i].bonus_desc = pkt:GetLenString()
        data[i].achieve_desc = pkt:GetLenString()
        data[i].category = pkt:GetShort()
        data[i].order = pkt:GetShort()
        data[i].target_count = pkt:GetChar()
        data[i].target_list = {}
        for j = 1, data[i].target_count do
            local tmpInfo = {}
            tmpInfo.des = pkt:GetLenString()
            tmpInfo.process = pkt:GetSignedShort()
            tmpInfo.is_finished = false
            data[i].target_list[j] = tmpInfo
    end
    end
end


-- 服务器通知成就总览
function MsgParser:MSG_ACHIEVE_OVERVIEW(pkt, data)
    data.bonus_point = pkt:GetLong()
    data.bonus_desc = pkt:GetLenString()
    data.can_bonus = pkt:GetChar()
    data.total = pkt:GetLong()
    data.total_max = pkt:GetLong()
    data.category_num = pkt:GetChar()
    data.category = {}
    for i = 1, data.category_num do
        data.category[i] = {}
        data.category[i].category_total = pkt:GetLong()
        data.category[i].category_total_max = pkt:GetLong()
    end
    data.lastest_num = pkt:GetChar()
    data.last_achieve = {}
    for i = 1, data.lastest_num do
        data.last_achieve[i] = {}
        data.last_achieve[i].achieve_id = pkt:GetLong()
        data.last_achieve[i].achieve_time = pkt:GetLong()
        data.last_achieve[i].is_finished = 1
    end
end

-- 服务器通知成就数据
function MsgParser:MSG_ACHIEVE_VIEW(pkt, data)
    data.category = pkt:GetChar()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}
        data[i].achieve_id = pkt:GetLong()
        data[i].is_finished = pkt:GetChar()
        data[i].progress_or_time = pkt:GetLong()
        data[i].target_count = pkt:GetChar()
        data[i].target_list = {}
        for j = 1, data[i].target_count do
            local tmpInfo = {}
            tmpInfo.des = pkt:GetLenString()
            tmpInfo.process = pkt:GetSignedShort()
            tmpInfo.is_finished = true
            data[i].target_list[j] = tmpInfo
    end
    end
end

-- 服务器通知完成成就
function MsgParser:MSG_ACHIEVE_FINISHED(pkt, data)
    data.achieve_id = pkt:GetLong()
    data.achieve_name = pkt:GetLenString()
end

function MsgParser:MSG_EXCHANGE_CONTACT_SELLER(pkt, data)
    data.type = pkt:GetLenString()  -- 交易系统类型   "集市"、"珍宝"、"聚宝斋"
    data.goods_gid = pkt:GetLenString() -- 商品 gid
    data.para = pkt:GetLenString() -- 复用参数，告诉服务器需要刷新界面的信息 以 \| 分隔
    data.gid = pkt:GetLenString() -- 出售者 gid
    data.name = pkt:GetLenString() -- 出售者名字
    data.level = pkt:GetLong()
    data.icon = pkt:GetLong()
    data.is_friend = pkt:GetChar()
    data.is_online = pkt:GetChar()
    data.goods_name = pkt:GetLenString() -- 商品名称
end

-- 通知请求上传资源 gid 结果
function MsgParser:MSG_BLOG_RESOURE_GID(pkt, data)
    data.cookie = pkt:GetLenString()
    data.is_ok = pkt:GetChar()
    local count = pkt:GetChar()
    data.gids = {}
    for i = 1, count do
        table.insert(data.gids, pkt:GetLenString())
    end
end

-- 留言列表
function MsgParser:MSG_BLOG_MESSAGE_LIST(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.request_iid = pkt:GetLenString() -- 消息唯一标识，此为空时，表示首次刷新
    data.count = pkt:GetSignedChar()  -- 消息数量,此为-1时，表示请求刷新失败
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()         -- 消息唯一标识
        info.sender_gid = pkt:GetLenString()  -- 发送者gid
        info.sender_name = pkt:GetLenString() -- 发送者名字
        info.sender_icon = pkt:GetShort()
        info.sender_level = pkt:GetShort()
        info.sender_vip = pkt:GetChar()       -- 会员类型，0 = 普通， 1 = 月卡， 2 = 季卡， 3 = 年卡
        info.sender_dist = pkt:GetLenString() -- 发送者区组
        info.target_gid = pkt:GetLenString()  -- 目标gid，此为空时，表示正常留言；不为空时，表示回复对象
        info.target_name = pkt:GetLenString() -- 目标名字
        info.target_dist = pkt:GetLenString() -- 目标区组
        info.time = pkt:GetLong()             -- 留言时间
        info.message = pkt:GetLenString2()    -- 留言信息
        table.insert(data, info)
    end
end

function MsgParser:MSG_BLOG_MESSAGE_LIST_ABOUT_ME(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.request_iid = pkt:GetLenString() -- 消息唯一标识，此为空时，表示首次刷新
    data.count = pkt:GetSignedChar()  -- 消息数量,此为-1时，表示请求刷新失败
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()         -- 消息唯一标识
        info.char_gid = pkt:GetLenString()    -- 空间主人的 gid
        info.char_name = pkt:GetLenString()    -- 空间主人的 name
        info.sender_gid = pkt:GetLenString()  -- 发送者gid
        info.sender_name = pkt:GetLenString() -- 发送者名字
        info.sender_icon = pkt:GetShort()
        info.sender_level = pkt:GetShort()
        info.sender_vip = pkt:GetChar()       -- 会员类型，0 = 普通， 1 = 月卡， 2 = 季卡， 3 = 年卡
        info.sender_dist = pkt:GetLenString() -- 发送者区组
        info.target_gid = pkt:GetLenString()  -- 目标gid，此为空时，表示正常留言；不为空时，表示回复对象
        info.target_name = pkt:GetLenString() -- 目标名字
        info.target_dist = pkt:GetLenString() -- 目标区组
        info.time = pkt:GetLong()             -- 留言时间
        info.message = pkt:GetLenString2()    -- 留言信息
        table.insert(data, info)
    end
end

function MsgParser:MSG_BLOG_MESSAGE_NUM_ABOUT_ME(pkt, data)
    data.count = pkt:GetShort()
end

-- 通知个人空间信息
function MsgParser:MSG_BLOG_CHAR_INFO(pkt, data)
    data.user_gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.polar = pkt:GetChar()
    data.gender = pkt:GetChar()
    data.title = pkt:GetLenString()
    data.party_name = pkt:GetLenString()
    data.couple_name = pkt:GetLenString()
    data.location = pkt:GetLenString()
    data.signature = pkt:GetLenString()
    data.signature_voice = pkt:GetLenString()
    data.signature_voice_time = pkt:GetChar()
    data.tag = pkt:GetLenString()
    data.icon_img_ex_ti = pkt:GetLong()
    local brother_count = pkt:GetChar()
    data.brothers = {}
    for i = 1, brother_count do
        table.insert(data.brothers, {
            ["gid"] = pkt:GetLenString(),
            ["name"] = pkt:GetLenString(),
            ["icon"] = pkt:GetLong(),
        })
    end
    data.icon_img = pkt:GetLenString()
    data.under_review = pkt:GetChar()
    data.level = pkt:GetShort()
end

-- 发布留言成功（新留言）
function MsgParser:MSG_BLOG_MESSAGE_WRITE(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
end

-- 删除留言成功
function MsgParser:MSG_BLOG_MESSAGE_DELETE(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.iid = pkt:GetLenString()         -- 消息唯一标识
end

-- 赠送鲜花结果
function MsgParser:MSG_BLOG_FLOWER_PRESENT(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人 GID
    data.flag = pkt:GetChar() -- 赠送鲜花成功标记， flag = 0 表示失败；flag = 1 表示成功
end

-- 鲜花列表
function MsgParser:MSG_BLOG_FLOWER_INFO(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人 GID
    data.times1 = pkt:GetChar() -- 康乃馨赠送次数
    data.times2 = pkt:GetChar() -- 蓝玫瑰消耗金钱
    data.times3 = pkt:GetChar() -- 郁金香消耗元宝
end

-- 送花记录列表
function MsgParser:MSG_BLOG_FLOWER_LIST(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.request_iid = pkt:GetLenString() -- 消息唯一标识，此为空时，表示首次刷新
    data.count = pkt:GetSignedChar()  -- 消息数量
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()         -- 消息唯一标识
        info.flower = pkt:GetLenString()  -- 送花类型
        info.gid = pkt:GetLenString() -- 送花者gid
        info.name = pkt:GetLenString()     -- 送花者名字
        info.icon = pkt:GetShort()     -- 送花者形象
        info.level = pkt:GetShort()  -- 送花者等级
        info.time = pkt:GetLong()     -- 送花时间
        table.insert(data, info)
    end
end

-- 空间人气、鲜花数目
function MsgParser:MSG_BLOG_FLOWER_UPDATE(pkt, data)
    data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.popular = pkt:GetLong() -- 空间人气
    data.flower = pkt:GetLong()  -- 收到的鲜花数
end


-- 状态数据
function MsgParser:MSG_BLOG_UPDATE_ONE_STATUS(pkt, data, isAboutMe)
    data.sid = pkt:GetLenString()   -- 状态GID
    data.uid = pkt:GetLenString()   -- 玩家GID
    data.dist = pkt:GetLenString()
    data.insider = pkt:GetChar()    -- 会员


    data.time = pkt:GetLong()
    data.text = pkt:GetLenString2()
    data.img_str = pkt:GetLenString()
    data.like_num = pkt:GetShort()  -- 点赞数量
    data.comment_num = pkt:GetShort()  -- 评论数量
    if isAboutMe == true then
        data.name = pkt:GetLenString()
        data.polar = pkt:GetChar()
        data.gender = pkt:GetChar()
        data.level = pkt:GetShort()
        data.icon = gf:getIconByGenderAndPolar(data.gender, data.polar)
    end

    local user = FriendMgr:getFriendByGid(data.uid)
    if user then
        data.name = user:queryBasic("char")
        data.level = user:queryBasic("level")
        data.icon = user:queryBasicInt("icon")
    elseif Me:queryBasic("gid") == data.uid then
        data.name = Me:queryBasic("name")
        data.level = Me:queryBasic("level")
        data.icon = Me:queryBasicInt("icon")
    end

    data.like_count = pkt:GetShort()  -- 这里最大值为3
    data.likeNameList = {}
    for i = 1, data.like_count do
        local user = {}
        user.uid = pkt:GetLenString()
        user.name = pkt:GetLenString()
        user.dist = pkt:GetLenString()
        local inFriendData = FriendMgr:getFriendByGid(user.uid)
        if inFriendData then
            user.name = inFriendData:queryBasic("char")
        elseif Me:queryBasic("gid") == user.uid then
            user.name = Me:queryBasic("name")
        end

        table.insert(data.likeNameList, user)
    end

    data.comment_count = pkt:GetShort()  -- 这里最大值为3
    data.commentData = {}
    for i = 1, data.comment_count do
        local commentData = {}
        commentData.cid = pkt:GetShort()
        commentData.time = pkt:GetLong()
        commentData.uid = pkt:GetLenString()        -- 评论玩家GID
        commentData.name = pkt:GetLenString()       -- 评论玩家名字
        commentData.dist = pkt:GetLenString()       -- 评论玩家区组
        commentData.insider = pkt:GetChar()    -- 会员

        commentData.reply_uid = pkt:GetLenString()        -- 评论玩家GID
        commentData.reply_name = pkt:GetLenString()       -- 评论玩家名字
        commentData.reply_dist = pkt:GetLenString()       -- 评论玩家区组
        commentData.text = pkt:GetLenString()       -- 评论内容

        local user = FriendMgr:getFriendByGid(commentData.uid)
        if user then
            commentData.name = user:queryBasic("char")
        elseif Me:queryBasic("gid") == commentData.uid then
            commentData.name = Me:queryBasic("name")
        end

        local user = FriendMgr:getFriendByGid(commentData.reply_uid)
        if user then
            commentData.reply_name = user:queryBasic("char")
        elseif Me:queryBasic("gid") == commentData.reply_uid then
            commentData.reply_name = Me:queryBasic("name")
        end

        data.commentData[i] = commentData
    end
end

function MsgParser:MSG_BLOG_REQUEST_STATUS_LIST(pkt, data, isGetFormServer)
    data.viewType = pkt:GetChar()
    data.uid = pkt:GetLenString()

    local tempCount = pkt:GetShort()
    local likeSid = {}
    for i = 1, tempCount do
        local sid = pkt:GetLenString()
        likeSid[sid] = 1
    end

    data.count = pkt:GetShort()
    local misCount = 0
    local ret = {}
    for i = 1, data.count do
        local unitData = {}
        self:MSG_BLOG_UPDATE_ONE_STATUS(pkt, unitData, isGetFormServer)

        if likeSid[unitData.sid] then
            unitData.isLike = true
        else
            unitData.isLike = false
        end
            table.insert(ret, unitData)
        end

    for i = 1, #ret do
        data[i] = ret[i]
    end

    data.count = data.count - misCount
end

-- 点赞成功
function MsgParser:MSG_BLOG_LIKE_ONE_STATUS(pkt, data)
    data.sid = pkt:GetLenString()
end

function MsgParser:MSG_BLOG_STATUS_LIST_ABOUNT_ME(pkt, data)
    data.uid = pkt:GetLenString()

    local tempCount = pkt:GetShort()
    local likeSid = {}
    for i = 1, tempCount do
        local sid = pkt:GetLenString()
        likeSid[sid] = 1
    end

    data.count = pkt:GetShort()
    local misCount = 0
    local ret = {}
    for i = 1, data.count do
        local unitData = {}
        self:MSG_BLOG_UPDATE_ONE_STATUS(pkt, unitData, true)

        if likeSid[unitData.sid] then
            unitData.isLike = true
        else
            unitData.isLike = false
        end

        table.insert(ret, unitData)
    end

    for i = 1, #ret do
        data[i] = ret[i]
    end

    data.count = data.count - misCount
end

function MsgParser:MSG_BLOG_STATUS_NUM_ABOUT_ME(pkt, data)
    data.count = pkt:GetShort()
end

function MsgParser:MSG_BLOG_DELETE_ONE_STATUS(pkt, data)
    data.sid = pkt:GetLenString()
end

function MsgParser:MSG_BLOG_REQUEST_LIKE_LIST(pkt, data)
    data.sid = pkt:GetLenString()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}
        data[i].uid = pkt:GetLenString()
        data[i].name = pkt:GetLenString()
        data[i].icon = pkt:GetLong()
        data[i].level = pkt:GetShort()
        data[i].dist = pkt:GetLenString() -- 新增
        data[i].iid = data[i].uid  -- iid 记录的唯一标识
    end
end

function MsgParser:MSG_BLOG_ALL_COMMENT_LIST(pkt, data)
    data.sid = pkt:GetLenString()
    data.comment_num = pkt:GetShort()
    data.comment_count = data.comment_num -- 为了和另一个消息字段上保持一致
    data.commentData = {}
    for i = 1, data.comment_num do
        data.commentData[i] = {}
        data.commentData[i].cid = pkt:GetShort()
        data.commentData[i].time = pkt:GetLong()
        data.commentData[i].uid = pkt:GetLenString()
        data.commentData[i].name = pkt:GetLenString()
        data.commentData[i].dist = pkt:GetLenString()   -- (新增)
        data.commentData[i].insider = pkt:GetChar()    -- 会员
        data.commentData[i].reply_uid = pkt:GetLenString()        -- 评论玩家GID
        data.commentData[i].reply_name = pkt:GetLenString()       -- 评论玩家名字
        data.commentData[i].reply_dist = pkt:GetLenString()       -- 评论玩家区组  (新增)
        data.commentData[i].text = pkt:GetLenString()       -- 评论内容
    end
end

function MsgParser:MSG_BLOG_DELETE_ONE_COMMENT(pkt, data)
    data.sid = pkt:GetLenString()
    data.cid = pkt:GetShort()
end

function MsgParser:MSG_CHAR_INFO_EX(pkt, data)
    self:MSG_CHAR_INFO(pkt, data)
end

function MsgParser:MSG_OFFLINE_CHAR_INFO(pkt, data)
    data.msg_type = pkt:GetLenString()  -- 客户端传给服务端的标记，可用于判断该消息对应哪个界面
    data.gid = pkt:GetLenString()        -- 评论玩家GID
    data.name = pkt:GetLenString()       -- 评论玩家名字
    data.level = pkt:GetShort()       -- 评论玩家名字
    data.icon = pkt:GetLong()       -- 评论玩家名字
end

-- 通知个人空间信息
function MsgParser:MSG_BLOG_OPEN_BLOG(pkt, data)
    data.user_dist = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.openType = pkt:GetChar()  -- 1 朋友圈 2 留言板
end

function MsgParser:MSG_HMAC_SHA1_BASE64(pkt, data)
    data.key = pkt:GetLenString2()
    data.count = pkt:GetShort()
    data.rets = {}
    local keys = {}
    for i = 1, data.count do
        table.insert(keys, pkt:GetLenString2())
    end

    local count = pkt:GetShort()
    for i = 1, count do
        data.rets[keys[i]] = pkt:GetLenString2()
    end
end

function MsgParser:MSG_SHUADAO_BONUS_TYPE(pkt, data)
    data.bonus_type = pkt:GetLenString()
end

-- 首充礼包界面白果儿
function MsgParser:MSG_SHOUCHONG_CARD_INFO(pkt, data)
    data.notGid = true
    MsgParser:MSG_CARD_INFO(pkt, data)
end

-- 通知客户端斗宠界面数据
function MsgParser:MSG_DC_INFO(pkt, data)
    data.seasonStr = pkt:GetLenString() -- 赛季
    data.rank = pkt:GetShort()          -- 排名
    data.martial = pkt:GetLong()        -- 每 20 分钟可获得的武学
    data.total_martial = pkt:GetLong()  -- 可领取的累计武学
    data.left_num = pkt:GetChar()       -- 剩余挑战次数
    data.server_level = pkt:GetShort()  -- 服务器最高等级
    data.isOpen = pkt:GetChar()        -- 是否打开斗宠界面
end

-- 通知客户端斗宠界面数据
function MsgParser:MSG_DC_OPPONENT_LIST(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.no = pkt:GetChar()  -- 对手编号（发起挑战时需要使用此编号）
        info.name = pkt:GetLenString()      -- 玩家名称
        info.icon = pkt:GetLong()           -- icon
        info.polar = pkt:GetChar()          -- 相性
        info.level = pkt:GetShort()         -- 等级
        info.partyName = pkt:GetLenString() -- 帮派
        info.rank = pkt:GetShort()          -- 排名
        info.num = pkt:GetChar()            -- 上阵宠物数目
        info.isChallenging = pkt:GetChar()   -- 是否正在被我挑战
        table.insert(data, info)
    end
end

-- 通知客户端当前阵容
function MsgParser:MSG_DC_PETS(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local no = pkt:GetChar() -- 宠物位置
        local id = pkt:GetLong() -- 宠物 id,无宠物时，值为-1
        data[no] = id
    end
end

-- 通知客户端获得称谓奖励
function MsgParser:MSG_DC_WIN_PETS(pkt, data)
    data.rank = pkt:GetChar()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.name = pkt:GetLenString()
        info.level = pkt:GetShort()
        info.icon = pkt:GetLong()
        info.martial = pkt:GetLong()
        info.polar = pkt:GetChar()
        table.insert(data, info)
    end

    data.seasonStr = pkt:GetLenString() -- 赛季
end

-- 宠物继承
function MsgParser:MSG_FINISH_PET_INHERIT(pkt, data)
    data.mainPetNo = pkt:GetChar()
    data.otherPetNo = pkt:GetChar()
end

-- 宠物继承预览信息
function MsgParser:MSG_PREVIEW_PET_INHERIT(pkt, data)
    data.liftShape1 = pkt:GetSignedLong()
    data.manaShape1 = pkt:GetSignedLong()
    data.speedShape1 = pkt:GetSignedLong()
    data.phyShape1 = pkt:GetSignedLong()
    data.magShape1 = pkt:GetSignedLong()

    data.liftShape2 = pkt:GetSignedLong()
    data.manaShape2 = pkt:GetSignedLong()
    data.speedShape2 = pkt:GetSignedLong()
    data.phyShape2 = pkt:GetSignedLong()
    data.magShape2 = pkt:GetSignedLong()
end

-- 新充值好礼界面数据
function MsgParser:MSG_NEW_LOTTERY_INFO(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()

    -- 好礼一览奖品显示
    data.all_rewards_count = pkt:GetChar()
    data.rewards = {}
    for i = 1, data.all_rewards_count do
        local info = {}
        info.no = pkt:GetChar()
        info.name = pkt:GetLenString()
        info.desc = pkt:GetLenString()
        info.level = pkt:GetChar()  -- 奖品等级 0 特等，1 一等， 2 二等
        if not data.rewards[info.level] then
            data.rewards[info.level] = {}
        end

        table.insert(data.rewards[info.level], info)
    end
end

-- 客户端抽奖的结果
function MsgParser:MSG_NEW_LOTTERY_DRAW(pkt, data)
    data.reward_str = pkt:GetLenString()  -- 奖品名称
    data.level = pkt:GetChar()      -- 奖品等级 0 特等，1 一等， 2 二等
end

-- 客户端领取奖励的结果
function MsgParser:MSG_NEW_LOTTERY_FETCH(pkt, data)
    data.name = pkt:GetLenString()
    data.level = pkt:GetChar()
end

function MsgParser:MSG_SIMULATOR_LOGIN(pkt, data)
    data.ti = pkt:GetLong()
end

function MsgParser:MSG_BLOG_OSS_TOKEN(pkt, data)
    data.ret = pkt:GetLenString2()
end

function MsgParser:MSG_COMMUNITY_TOKEN(pkt, data)
    data.token = pkt:GetLenString()
    data.red_dot_type = pkt:GetLong()
end
function MsgParser:MSG_PLAY_SCREEN_EFFECT(pkt, data)
    data.duration = pkt:GetChar()
end

-- 通知客户端好运鉴宝界面信息
function MsgParser:MSG_NEWYEAR_2018_HYJB(pkt, data)
    data.result = pkt:GetLenString()    -- 当前鉴定结果（空字符串表示第一次鉴定）
    data.isLimit = pkt:GetChar()
    data.process = pkt:GetLong()    -- 鉴定进度（单位0.01）
    data.cost = pkt:GetLong()    -- 鉴定消耗
    data.npcId = pkt:GetLong()    -- npcId
    data.itemName = pkt:GetLenString()
end

-- 群组的@信息
function MsgParser:MSG_CHAT_GROUP_AITE_INFO(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetLong()
        info.insider_level = pkt:GetChar()
        info.isOnline = pkt:GetChar()
        info.party_name = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 帮派的 @ 信息
function MsgParser:MSG_PARTY_AITE_INFO(pkt, data)
    data.party_name = pkt:GetLenString()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetLong()
        info.insider_level = pkt:GetChar()
        info.isOnline = pkt:GetChar()
        info.party_job = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 显示【水岚之缘】任务界面
function MsgParser:MSG_TASK_SHUILZY_DIALOG(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.task_name = pkt:GetLenString()
        info.status = pkt:GetChar()      -- 任务状态
        info.level = pkt:GetChar()       -- 任务开启等级
        info.start_time = pkt:GetLong()  -- 任务开启时间
        info.end_time = pkt:GetLong()    -- 任务关闭时间
        table.insert(data, info)
    end
end

-- 动画
function MsgParser:MSG_PLAY_SCREEN_ANIMATE(pkt, data)
    data.play_type = pkt:GetChar()          -- 1 开启动画，2 停止动画
    data.animate_name = pkt:GetLenString()  -- 动画名称
end

function MsgParser:MSG_C_CREATE_SEQUENCE(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_LC_CREATE_SEQUENCE(pkt, data)
    self:MSG_C_CREATE_SEQUENCE(pkt, data)
end

function MsgParser:MSG_TRADING_HOUSE_DATA(pkt, data)
    data.house_id = pkt:GetLenString()
    data.house_type = pkt:GetChar()
    data.comfort = pkt:GetShort()
    data.wos_level = pkt:GetChar()
    data.chuws_level = pkt:GetChar()
    data.lianqs_level = pkt:GetChar()
    data.xiuls_level = pkt:GetChar()
    data.total_space = pkt:GetChar()
    data.max_space = pkt:GetChar()
    data.guanjia_count = pkt:GetShort()
    data.guanjia_names = {}
    for i = 1, data.guanjia_count do
        local name = pkt:GetLenString()
        if name ~= CHS[2000412] then
            table.insert(data.guanjia_names, name)
        end
    end

    data.guanjia_count = #data.guanjia_names
    data.yahuan_count = pkt:GetShort()
    data.yahuan_names = {}
    for i = 1, data.yahuan_count do
        local name = pkt:GetLenString()
        table.insert(data.yahuan_names, name)
    end
end

-- 通知仙魔点自动加点配置
function MsgParser:MSG_RECOMMEND_XMD(pkt, data)
    data.addType = pkt:GetChar()  --  int8，加点方案（１：自动加仙道点；２：自动加魔道点。）
    data.isOpen = pkt:GetChar()
end

function MsgParser:MSG_CLEAN_ALL_REQUEST(pkt, data)
    data.ask_type = pkt:GetLenString()
end

-- 打雪战 角色的所有数据
function MsgParser:MSG_WINTER2018_DAXZ_CHAR_INFO(pkt, data)
    self:MSG_C_UPDATE_APPEARANCE(pkt, data)
end

-- 打雪战 角色的操作时间
function MsgParser:MSG_WINTER2018_DAXZ_OPER(pkt, data)
    data.leftTime = pkt:GetLong()
    data.rounds = pkt:GetLong()
    data.player_xq_num = pkt:GetChar()
end

-- 打雪战 界面表现的数据
function MsgParser:MSG_WINTER2018_DAXZ_SHOW(pkt, data)
    data.npc_oper = pkt:GetChar()
    data.npc_xq_num = pkt:GetChar()

    data.player_oper = pkt:GetChar()
    data.player_xq_num = pkt:GetChar()
end

-- 打雪战 结果
function MsgParser:MSG_WINTER2018_DAXZ_BONUS(pkt, data)
    data.ret = pkt:GetChar()    --  1：胜利，2：失败
    data.exp = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.itemName = pkt:GetLenString()
    data.isExitGame = pkt:GetChar()
end

-- 打雪战 游戏结束
function MsgParser:MSG_WINTER2018_DAXZ_END(pkt, data)
    data.x = pkt:GetShort()    --  1：胜利，2：失败
    data.y = pkt:GetShort()
    data.dir = pkt:GetChar()
end

-- 2018 寒假作业 - 通知客户端作答
function MsgParser:MSG_WINTER_2018_HJZY(pkt, data)
    data.type = pkt:GetLenString()
    data.answer = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.question = {}
    for i = 1, data.count do
        table.insert(data.question, pkt:GetLenString2())
    end
end

-- 2018 冻柿子 进入游戏
function MsgParser:MSG_DONGSZ_2018_START(pkt, data)
    data.startTime = pkt:GetLong()
    data.playerOne = {}
    MsgParser:MSG_C_UPDATE_APPEARANCE(pkt, data.playerOne)
    data.playerTwo = {}
    MsgParser:MSG_C_UPDATE_APPEARANCE(pkt, data.playerTwo)
end

-- 2018 冻柿子 回合数据更新
function MsgParser:MSG_DONGSZ_2018_ROUND(pkt, data)
    data.eatPlayerGid =  pkt:GetLenString()
    data.rountStartTime = pkt:GetLong()
    data.rountEndTime = pkt:GetLong()
    data.persimmonCount = pkt:GetChar()
    data.persimmon = {}
    for i = 1, data.persimmonCount do
        local persimmon = {}
        persimmon.gid = pkt:GetLenString()
        persimmon.status = pkt:GetChar()
        persimmon.statrEatTime = pkt:GetLong()
        persimmon.endEatTime = pkt:GetLong()
        table.insert(data.persimmon, persimmon)
    end
end

-- 2018 冻柿子 游戏结束
function MsgParser:MSG_DONGSZ_2018_END(pkt, data)
    data.gameResult = pkt:GetChar()
    data.rewardType = pkt:GetChar()
    data.reward = pkt:GetLong()
end

-- 2018 冻柿子 通知吃到涩柿子
function MsgParser:MSG_DONGSZ_2018_HIT(pkt, data)
    data.failPlayerGid =  pkt:GetLenString()
end

-- 2018 冻柿子 通知当前地图位置
function MsgParser:MSG_DONGSZ_2018_END_POS(pkt, data)
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = pkt:GetChar()
end

-- 通知客户端当前选中柿子
function MsgParser:MSG_DONGSZ_2018_SELECT(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 神秘大礼砸蛋版本数据
function MsgParser:MSG_SHENMI_DALI_OPEN(pkt, data)
    data.online_time = pkt:GetLong()   -- 累积在线时间
    data.count = pkt:GetChar()          -- 银蛋数量

    for i = 1, 8 do
        data[i] = {}
        data[i].index    = pkt:GetChar()        -- 序号 ： 1 - 8
        data[i].time    = pkt:GetShort()        -- 累积时间，单位：秒
        data[i].name    = pkt:GetLenString()    -- 奖励类型 : 无、经验、道行、潜能、银元宝
        data[i].brate       = pkt:GetChar() -- 奖励倍数 : 0、1、3、10
    end
end

-- 通知挑选结果
function MsgParser:MSG_SHENMI_DALI_PICK(pkt, data)
    data.index = pkt:GetChar()
    data.result = pkt:GetChar()
    data.name = pkt:GetLenString()
    data.brate = pkt:GetChar()
end

-- 所有活跃登录礼包的数据
function MsgParser:MSG_SEVENDAY_GIFT_LIST(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local bonus = {}
        bonus.day = pkt:GetChar()
        bonus.desc = pkt:GetLenString()
        table.insert(data, bonus)
    end
end

-- 所有活跃登录礼包领取状态的数据
function MsgParser:MSG_SEVENDAY_GIFT_FLAG(pkt, data)
    data.loginDays = pkt:GetChar()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local bonus = {}
        bonus.flag = pkt:GetChar() -- 0 未领取，1已领取
        table.insert(data, bonus)
    end
end

-- 通知客户端龙舞训练动作
function MsgParser:MSG_LANTERN_2018_ACTION(pkt, data)
    data.npc_id = pkt:GetLong()         -- NPC id
    data.action = pkt:GetLenString()    -- 动作名称
end

function MsgParser:MSG_AUTO_FIGHT_SKILL(pkt, data)
    data.user_is_multi = pkt:GetChar()                      -- 玩家是否使用组合自动战斗
    data.user_round = pkt:GetChar()                         -- 玩家当前动作剩余回合数
    data.user_action = pkt:GetChar()
    data.user_next_action = pkt:GetChar()
    data.user_para = pkt:GetSignedLong()                          -- 玩家当前动作参数
    data.user_next_para = pkt:GetSignedLong()                     -- 玩家下一个动作参数
    data.pet_is_multi = pkt:GetChar()                       -- 宠物是否使用组合自动战斗
    data.pet_round = pkt:GetChar()                          -- 宠物当前动作剩余回合数
    data.pet_action = pkt:GetChar()
    data.pet_next_action = pkt:GetChar()
    data.pet_para = pkt:GetSignedLong()                          -- 宠物当前动作参数
    data.pet_next_para = pkt:GetSignedLong()                          -- 宠物下一个动作参数
end

-- 微社区地址
function MsgParser:MSG_COMMUNITY_ADDRESS(pkt, data)
    data.address = pkt:GetLenString()
end

function MsgParser:MSG_L_GET_COMMUNITY_ADDRESS(pkt, data)
    data.address = pkt:GetLenString()
end

-- 选择奖励数据
function MsgParser:MSG_SELECT_BONUS_DATA(pkt, data)
    data.source = pkt:GetLenString()
    data.dlg_type = pkt:GetChar()
    data.during_ti = pkt:GetLong()
    data.tips = pkt:GetLenString()
end

-- 退出选择奖励
function MsgParser:MSG_SELECT_BONUS_CANCEL(pkt, data)
    data.source = pkt:GetLenString()
end

-- 通知客户端珍宝系统的配置信息
function MsgParser:MSG_GOLD_STALL_CONFIG(pkt, data)
    data.is_enable = pkt:GetChar()              -- 整个珍宝系统是否可用
    data.enable_gold_stall_cash = pkt:GetChar() -- 珍宝系统是否可以进行金钱交易 (是否有金钱标签)
    data.sell_cash_aft_days = pkt:GetChar()     -- 珍宝金钱交易在开服几天后开放
    data.start_gold_stall_cash = pkt:GetChar()  -- 珍宝金钱交易是否已经开放过
    data.enable_appoint = pkt:GetChar()         -- 珍宝金钱交易是否开放指定交易
    data.enable_autcion = pkt:GetChar()         -- 是否可以进行拍卖

    data.close_time = pkt:GetLong()             -- 珍宝交易关闭时间

end

-- 服务器通知金钱商品的标准价格
function MsgParser:MSG_GOLD_STALL_CASH_PRICE(pkt, data)
    data.name = pkt:GetLong()       -- 金钱商品类型
    data.class_str = pkt:GetLenString()  -- 波动价格数据，是一个 json 格式的字符串 (如 "{80:100,90:333}")
end

-- 通知金钱商品列表
function MsgParser:MSG_GOLD_STALL_CASH_GOODS_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local name = pkt:GetLenString()  -- 商品名称
        local price = pkt:GetLong()      -- 商品价格
        data[name] = price
    end
end

function MsgParser:MSG_OPEN_REPORT_USER_DLG(pkt, data)
    data.user_dist = pkt:GetLenString()
    data.user_gid = pkt:GetLenString()
    data.user_name = pkt:GetLenString()

    data.reason = pkt:GetLenString()
end

-- 通知集市交易记录详细信息
function MsgParser:MSG_STALL_RECORD_DETAIL(pkt, data)
    data.record_id = pkt:GetLenString()
    data.goods_type = pkt:GetChar()
    if data.goods_type == TRANSFER_ITEM_TYPE.OTHER then
    elseif data.goods_type == TRANSFER_ITEM_TYPE.CASH then
    elseif data.goods_type == TRANSFER_ITEM_TYPE.PET then
        self:MSG_PET_CARD(pkt, data)
    elseif data.goods_type == TRANSFER_ITEM_TYPE.CHARGE then
        Builders:BuildItemInfo(pkt, data)
    elseif data.goods_type == TRANSFER_ITEM_TYPE.NOT_COMBINE then
        Builders:BuildItemInfo(pkt, data)
    elseif data.goods_type == TRANSFER_ITEM_TYPE.COMBINE then
        Builders:BuildItemInfo(pkt, data)
    end
end

-- 通知集市交易记录详细信息
function MsgParser:MSG_GOLD_STALL_RECORD_DETAIL(pkt, data)
    self:MSG_STALL_RECORD_DETAIL(pkt, data)
end

-- 聊天装饰列表
function MsgParser:MSG_DECORATION_LIST(pkt, data)
    data.type = pkt:GetLenString()
    data.usedName = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local item = {}
        item.name = pkt:GetLenString()
        item.time = pkt:GetSignedLong()
        item.getTime = pkt:GetLong()
        data.list[i] = item
    end

    table.sort(data.list, function(l, r)
        if l.getTime > r.getTime then return true end
        if l.getTime < r.getTime then return false end
    end)
end

-- 某个角色的个人空间装饰信息
function MsgParser:MSG_BLOG_DECORATION_LIST(pkt, data)
    data.user_gid = pkt:GetLenString()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local item = {}
        local type = pkt:GetLenString()      -- 装饰类型
        item.name = pkt:GetLenString()      -- 装饰名称
        item.end_time = pkt:GetSignedLong() -- 到期时间，若 end_time = -1 表示永久。
        data[type] = item
    end
end

function MsgParser:MSG_SHUADAO_COMBAT_FAIL(pkt, data)
    data.task_name = pkt:GetLenString()
end

function MsgParser:MSG_SHUADAO_COMBAT_SUCC(pkt, data)
    data.task_name = pkt:GetLenString()
end

function MsgParser:MSG_LIST_DUMP_FILES(pkt, data)
    data.cookie = pkt:GetLong()
    data.search_dir = pkt:GetLenString()
end

function MsgParser:MSG_UPLOAD_DUMP_FILE(pkt, data)
    data.cookie = pkt:GetLong()
    data.file_path = pkt:GetLenString()
    data.server = pkt:GetLenString()
end

function MsgParser:MSG_EXECUTE_LUA_CODE(pkt, data)
    data.cookie = pkt:GetLong()
    data.code = pkt:GetLenString2()
    data.flag = pkt:GetChar()
end

function MsgParser:MSG_QISHA_SHILIAN_KILL_FIRST(pkt, data)
    data.count = pkt:GetChar()  -- 为0表示没有记录，1表示有首杀
    if data.count == 0 then return end  -- 为0不需要再解析了
    data.kill_time = pkt:GetLong()
    data.num = pkt:GetChar()    -- 玩家数量
            data.plays = {}
    for i = 1, data.num do
        data.plays[i] = {}
        data.plays[i].gid = pkt:GetLenString()
        data.plays[i].name = pkt:GetLenString()
        data.plays[i].level = pkt:GetShort()
        data.plays[i].icon = pkt:GetLong()
    end
end

-- 通知战斗录像列表
function MsgParser:MSG_ADMIN_BROADCAST_COMBAT_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.combat_id = pkt:GetLenString()
        info.dist = pkt:GetLenString()
        info.combat_type = pkt:GetLenString()
        info.atk_name = pkt:GetLenString()
        info.time = pkt:GetLong()
        table.insert(data, info)
    end
end

function MsgParser:MSG_OPEN_STORE_DIALOG(pkt, data)
    data.type = pkt:GetChar()         -- 界面类型
    data.surplus = pkt:GetLenString() -- 存款剩余金额
end

-- 刷新内丹数据
function MsgParser:MSG_REFRESH_NEIDAN_DATA(pkt, data)
    data.isTop = pkt:GetChar()
    if data.isTop == 0 then
        data.nxState = pkt:GetChar()
        data.nxStage = pkt:GetChar()
        data.nxAttribPoint = pkt:GetShort()
        data.nxPolarPoint = pkt:GetShort()
    end
end

-- 通知客户端当前赛季简要信息
function MsgParser:MSG_CSC_SEASON_DATA(pkt, data)
    data.season_count = pkt:GetShort() -- 一共有几届
    data.seasons = {}
    for i = 1, data.season_count do
        data.seasons[i] = pkt:GetShort() -- 该届的赛区数量
    end

    data.zone_count = pkt:GetShort()  -- 赛区数量
    for i = 1, data.zone_count do
        data[i] = {}
        data[i].dist_count = pkt:GetShort()  -- 该赛区区组数量
        for j = 1, data[i].dist_count do
            local info = {}
            info.index = j
            info.dist_name = pkt:GetLenString()    -- 区组名称
            info.start_time = pkt:GetLong()        -- 区组开服时间戳
            table.insert(data[i], info)
        end
    end

    data.last_season_no = pkt:GetShort()  -- 当前第几届；当为第一届并且没有结束时，无法查看历届排行数据
    data.my_dist_in_zone = pkt:GetShort() -- 玩家所在区组属于哪个赛区；都不属于为 0
    data.season_end = pkt:GetChar()            -- 当前赛季是否已经结束
    data.season_start_time = pkt:GetLong()     -- 当前赛季的第一场比赛开始时间

    local info = {}
    info.contrib = pkt:GetLong()   -- 玩家积分
    info.combat = pkt:GetLong()   -- 战斗次数
    info.win = pkt:GetLong()      -- 战斗胜利次数
    data.myRankInfo = info
end

function MsgParser:MSG_CSC_RANK_DATA_TOP(pkt, data)
    data.season = pkt:GetShort()    -- 第几届
    data.zone = pkt:GetShort()    -- 赛区编号
    data.count = pkt:GetShort()  -- 排行数据条数
    data.rankInfo = {}
    for i = 1, data.count do
        local info = {}
        info.rank = i
        info.dist_name = pkt:GetLenString() -- 区组名称
        info.gid = pkt:GetLenString()  -- 玩家 gid
        info.name = pkt:GetLenString() -- 玩家名称
        info.level = pkt:GetLong()    -- 玩家等级
        info.contrib = pkt:GetLong()   -- 玩家积分
        info.combat = pkt:GetLong()   -- 战斗次数
        info.win = pkt:GetLong()      -- 战斗胜利次数
        info.polar = pkt:GetLong()     -- 玩家相性
        table.insert(data.rankInfo, info)
    end
end

function MsgParser:MSG_CSC_RANK_DATA_TOP_COMPETE(pkt, data)
    data.count = pkt:GetShort()  -- 排行数据条数
    data.rankInfo = {}
    for i = 1, data.count do
        local info = {}
        info.rank = i
        info.dist_name = pkt:GetLenString() -- 区组名称
        info.gid = pkt:GetLenString()  -- 玩家 gid
        info.name = pkt:GetLenString() -- 玩家名称
        info.level = pkt:GetLong()    -- 玩家等级
        info.contrib = pkt:GetLong()   -- 玩家积分
        info.combat = pkt:GetLong()   -- 战斗次数
        info.win = pkt:GetLong()      -- 战斗胜利次数
        info.polar = pkt:GetLong()     -- 玩家相性
        table.insert(data.rankInfo, info)
    end

    data.myData = {}
    data.myData.rank = pkt:GetShort()
    data.myData.contrib = pkt:GetLong()
    data.myData.combat = pkt:GetLong()
    data.myData.win = pkt:GetLong()
end

function MsgParser:MSG_CSC_RANK_DATA_STAGE(pkt, data)
    data.season = pkt:GetShort()   -- 第几届
    data.zone = pkt:GetShort() -- 赛区编号
    data.stage_count = pkt:GetShort() -- 段位数量
    for i = 1, data.stage_count do
        local stage = pkt:GetShort() -- 段位编号 从 低 1 ~ 高 7
        data[stage] = {}
        data[stage].stage = stage
        data[stage].count = pkt:GetShort()  -- 排行数据条数
        data[stage].rankInfo = {}
        for j = 1, data[stage].count do
            local info = {}
            info.rank = j
            info.dist_name = pkt:GetLenString() -- 区组名称
            info.gid = pkt:GetLenString()  -- 玩家 gid
            info.name = pkt:GetLenString() -- 玩家名称
            info.level = pkt:GetLong()    -- 玩家等级
            info.contrib = pkt:GetLong()   -- 玩家积分
            info.combat = pkt:GetLong()   -- 战斗次数
            info.win = pkt:GetLong()      -- 战斗胜利次数
            info.polar = pkt:GetLong()     -- 玩家相性
            table.insert(data[stage].rankInfo, info)
        end
    end
end

function MsgParser:MSG_CSC_RANK_DATA_STAGE_COMPETE(pkt, data)
    data.stage_count = pkt:GetShort() -- 段位数量
    for i = 1, data.stage_count do
        local stage = i -- 段位编号 从 低 1 ~ 高 7
        data[stage] = {}
        data[stage].stage = stage
        data[stage].count = pkt:GetShort()  -- 排行数据条数
        data[stage].rankInfo = {}
        for j = 1, data[stage].count do
            local info = {}
            info.rank = j
            info.dist_name = pkt:GetLenString() -- 区组名称
            info.gid = pkt:GetLenString()  -- 玩家 gid
            info.name = pkt:GetLenString() -- 玩家名称
            info.level = pkt:GetLong()    -- 玩家等级
            info.contrib = pkt:GetLong()   -- 玩家积分
            info.combat = pkt:GetLong()   -- 战斗次数
            info.win = pkt:GetLong()      -- 战斗胜利次数
            info.polar = pkt:GetLong()     -- 玩家相性
            table.insert(data[stage].rankInfo, info)
        end
    end
end

-- 通知客户端打开领取奖励后的分享界面
function MsgParser:MSG_CSC_FETCH_BONUS(pkt, data)
    data.title = pkt:GetLenString()   -- 称谓
    data.score = pkt:GetLong()         -- 积分
    data.rank = pkt:GetChar()  -- 排名
end

-- 通知客户端跨服竞技信息界面数据
function MsgParser:MSG_CSC_PLAYER_CONTEST_DATA(pkt, data)
    data.rank = pkt:GetShort()
    data.contrib = pkt:GetLong() -- 积分
    data.stage = pkt:GetShort()  -- 1~21 7个段位 每段 3阶
    data.cur_stage_contrib = pkt:GetSignedLong()  -- 当前段位积分
    data.last_stage_contrib = pkt:GetSignedLong()  -- 下一段位积分
    data.combat = pkt:GetLong()
    data.win = pkt:GetLong()
    data.combat_mode = pkt:GetLenString()
    data.is_matching = pkt:GetChar()
end

-- 通知客户端匹配模式
function MsgParser:MSG_CSC_NOTIFY_COMBAT_MODE(pkt, data)
    data.combat_mode = pkt:GetLenString()
end

-- 通知客户端自动匹配状态
function MsgParser:MSG_CSC_NOTIFY_AUTO_MATCH(pkt, data)
    data.enable = pkt:GetChar()
end

-- 跨服竞技场战斗结束
function MsgParser:MSG_CSC_COMBAT_END(pkt, data)
    data.is_win = pkt:GetChar()        -- 1 : 胜利，0 : 失败
    data.player_size = pkt:GetChar()   -- 玩家数量
    for i = 1, data.player_size do
        local info = {}
        info.gid = pkt:GetLenString()   -- 玩家 GID
        info.name = pkt:GetLenString()  -- 玩家名字
        info.level = pkt:GetShort()      -- 玩家等级
        info.polar = pkt:GetChar()        -- 玩家相性
        info.gender = pkt:GetChar()
        info.change_score = pkt:GetSignedLong()     --改变的分数
        info.old_score = pkt:GetLong()        -- 改变前的分数
        info.stage_desc = pkt:GetLenString()  -- 小段位描述

        table.insert(data, info)
    end
end

-- 通知客户端组队匹配最小道行
function MsgParser:MSG_CSC_TEAM_MATCH_MIN_TAO(pkt, data)
    data.min_tao = pkt:GetLong()  -- 精确到年
end

-- 通知客户端保护时间
function MsgParser:MSG_CSC_PROTECT_TIME(pkt, data)
    data.protect_time = pkt:GetLong()
end

-- 通知比赛日信息
function MsgParser:MSG_CSC_MATCHDAY_DATA(pkt, data)
    data.season_start_time = pkt:GetLong()
    data.season_end_time = pkt:GetLong()
    data.matchday_start_time = pkt:GetLong()
    data.matchday_pair_time = pkt:GetLong()
    data.matchday_end_time = pkt:GetLong()
    data.matchday_close_time = pkt:GetLong()
end

function MsgParser:MSG_ENABLE_SPECIAL_AUTO_WALK(pkt, data)
    data.enable = pkt:GetChar() == 1
end

function MsgParser:MSG_FOOLS_2018_ACTION(pkt, data)
    data.npc_id = pkt:GetLong()
    data.npc_action = pkt:GetLenString()
end

function MsgParser:MSG_XIAOLIN_GUANGJI(pkt, data)
    data.type = pkt:GetChar()
    data.duration = pkt:GetChar()
end

function MsgParser:MSG_FINISH_JIANZHONG_JIYUAN_TASK(pkt, data)
    data.bonus_exp = pkt:GetLong()
    data.level_upper1 = pkt:GetShort()
    data.level_upper2 = pkt:GetShort()
end

function MsgParser:MSG_PET_ECLOSION_RESULT(pkt, data)
    data.result = pkt:GetChar()
end

function MsgParser:MSG_WORLD_BOSS_LIFE(pkt, data)
    data.life_str = pkt:GetLenString()       -- 当前血量
    data.max_life_str = pkt:GetLenString()   -- 最大血量
end


function MsgParser:MSG_WORLD_BOSS_RANK(pkt, data)
    data.count = pkt:GetShort()   -- 数据数量，玩家自己的数据在最后一个，只有一个的情况说明没有排名数据
    for i = 1, data.count do
        local info = {}
        info.rank = pkt:GetSignedShort() -- 排名，-1 表示不上榜
        info.name = pkt:GetLenString() -- 名称
        info.damage = pkt:GetLong() -- 伤害值
        table.insert(data, info)
    end
end

function MsgParser:MSG_WORLD_BOSS_RESULT(pkt, data)
    data.old_rank = pkt:GetSignedShort()   -- 旧的排名, -1 表示榜外（1000 名以外）
    data.new_rank = pkt:GetSignedShort()   -- 新的排名
    data.inside_rank = pkt:GetShort()   -- 榜内的名次
    data.add_damage = pkt:GetLong()   -- 本次增加的伤害值
    data.new_damage = pkt:GetLong()   -- 新的伤害值
end

function MsgParser:MSG_ROOM_GUANJIA_INFO(pkt, data)
    data.id = pkt:GetLong()
    data.icon = pkt:GetLong()
    data.name = pkt:GetLenString()
end

-- 打开便捷使用框
function MsgParser:MSG_QUICK_USE_ITEM(pkt, data)
    data.pos = pkt:GetShort()
    data.doublePoint = pkt:GetShort()
    data.doubleEnable = pkt:GetChar()
    data.chongfsPoint = pkt:GetShort()
    data.chongfsEnable = pkt:GetChar()
end

-- 居所-加成家具数据
function MsgParser:MSG_HOUSE_ALL_PRACTICE_BUFF_DATA(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local type = pkt:GetChar()  -- -- 类型  1人物            2法宝            3宠物
        data[type] = {}
        data[type].type = type
        data[type].amount = pkt:GetChar()  -- 数量
        data[type].furniture_pos = pkt:GetLong()   -- 家具位置
        data[type].furniture_durability = pkt:GetShort()   -- 家具耐久
        data[type].buff_value = pkt:GetChar()  -- 加成值
    end
end

function MsgParser:MSG_CHILD_2018_ACTION(pkt, data)
    data.npc_id = pkt:GetLong()
    data.action = pkt:GetChar()
end

-- 2018周年庆 灵猫翻牌
function MsgParser:MSG_LINGMAO_FANPAI_DATA(pkt, data)
    data.gameDay = pkt:GetChar()
    data.status = pkt:GetChar()
    local str = pkt:GetLenString()
    data.list = {}
    for i = 1, string.len(str) do
        table.insert(data.list, string.sub(str, i, i))
    end
end


function MsgParser:MSG_TRADING_SEARCH_GOODS(pkt, data)
    data.list_type = pkt:GetChar()  -- 1寄售，2公示
    data.is_begin = pkt:GetChar()               -- 1 为开始
    data.is_end = pkt:GetChar()               -- 1 结束
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}
        self:MSG_TRADING_GOODS_INFO(pkt, data[i])
    end

    data.goods_type = pkt:GetLenString()
end

-- 通知客户端我的灵猫信息
function MsgParser:MSG_ZNQ_2018_MY_LINGMAO_INFO(pkt, data)
    data.status = pkt:GetChar()   -- 灵猫状态（0:没有灵猫，1:灵猫正常，2:灵猫离家）
    data.level = pkt:GetChar()    -- 灵猫等级
    data.max_exp = pkt:GetShort() -- 当前等级经验上限
    data.exp = pkt:GetShort()     -- 灵猫经验
    data.mood = pkt:GetChar()     -- 灵猫心情
    data.last_time_tickle = pkt:GetLong()  -- 最后一次挠痒时间
    data.food = pkt:GetChar()         -- 灵猫饱食度
    data.liveness = pkt:GetChar()     -- 可喂食的活跃度
    data.combat_num = pkt:GetChar()       -- 可获得奖励的切磋次数
    data.learn_num = pkt:GetChar()    -- 学习次数
    data.end_time = pkt:GetLong()     -- 活动结束时间，0表示活动未开启
    data.refreshTime = pkt:GetLong()  -- 下次更新饱食或心情度时间
    data.openType = pkt:GetChar()     -- 是否强制打开界面
end

-- 通知客户端好友灵猫信息
function MsgParser:MSG_ZNQ_2018_FRIEND_LINGMAO_INFO(pkt, data)
    data.gid = pkt:GetLenString()
    data.level = pkt:GetSignedChar()  -- 灵猫等级 （-1表示没有灵猫，-2表示好友不在线，-3表示灵猫消失, ，-4表示请求失败）
    data.mood = pkt:GetChar()   -- 灵猫心情
    data.food = pkt:GetChar()   -- 灵猫饱食度
    data.combat_status = pkt:GetChar()   -- 与该好友灵猫的战斗关系（0:未战斗，1:表示战斗中，2:表示已战斗）
end

-- 通知客户端技能信息
function MsgParser:MSG_ZNQ_2018_LINGMAO_SKILLS(pkt, data)
    data.newSkill = pkt:GetLenString() -- 待替换的顿悟技能(若不为空表示有可替换的顿悟技能)
    data.count = pkt:GetChar()  -- 技能数目
    data.skills = {}
    for i = 1, data.count do
        local name = pkt:GetLenString() -- 技能名称
        data.skills[name] = true
    end
end

-- 服务器通知客户端操作灵猫成功
function MsgParser:MSG_ZNQ_2018_OPER_LINGMAO(pkt, data)
    data.oper = pkt:GetLenString()
end

-- 名人争霸竞猜：通知客户端名人争霸主界面竞猜信息
function MsgParser:MSG_CG_INFO(pkt, data)
    data.isOpen = pkt:GetChar()
    data.supportCardNum = pkt:GetLong()
    data.jcPoints = pkt:GetLong()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local dayInfo = {}
        dayInfo.date = pkt:GetLong()
        dayInfo.endDate = pkt:GetLong()
        dayInfo.day = pkt:GetSignedChar()
        table.insert(data.list, dayInfo)
    end
end

-- 名人争霸竞猜：服务器通知某个比赛日信息
function MsgParser:MSG_CG_DAY_INFO(pkt, data)
    data.day = pkt:GetSignedChar()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.day = data.day
        tmpInfo.competName = pkt:GetLenString()
        tmpInfo.aTeamId = pkt:GetLenString()
        tmpInfo.aTeamName = pkt:GetLenString()
        tmpInfo.aTeamSupportNum = pkt:GetLong()
        tmpInfo.bTeamId = pkt:GetLenString()
        tmpInfo.bTeamName = pkt:GetLenString()
        tmpInfo.bTeamSupportNum = pkt:GetLong()
        tmpInfo.mySupports = pkt:GetShort()
        tmpInfo.supportStatus = pkt:GetChar()
        tmpInfo.supportResult = pkt:GetChar()
        if tmpInfo.aTeamId ~= "" and tmpInfo.bTeamId ~= "" then
            -- 只保留两队都不轮空的数据
            table.insert(data.list, tmpInfo)
            end
    end
end

-- 名人争霸竞猜：通知客户端决赛队伍详细信息
function MsgParser:MSG_CG_FINAL_MATCH_INFO(pkt, data)
    data.aTeamName = pkt:GetLenString()
    data.aCount = pkt:GetChar()
    data.aTeamList = {}
    for i = 1, data.aCount do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.icon = pkt:GetShort()
        tmpInfo.isLeader = pkt:GetChar()
        table.insert(data.aTeamList, tmpInfo)
        end

    data.bTeamName = pkt:GetLenString()
    data.bCount = pkt:GetChar()
    data.bTeamList = {}
    for i = 1, data.bCount do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.icon = pkt:GetShort()
        tmpInfo.isLeader = pkt:GetChar()
        table.insert(data.bTeamList, tmpInfo)
    end
end


-- 名人争霸竞猜：服务器通知客户端队伍信息
function MsgParser:MSG_CG_TEAM_INFO(pkt, data)
    data.id = pkt:GetLenString()
    data.teamName = pkt:GetLenString()
    data.memberNum = pkt:GetChar()
    data.memberList = {}
    for i = 1, data.memberNum do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.tao = pkt:GetLong()
        tmpInfo.isTeamLeader = pkt:GetChar()
        table.insert(data.memberList, tmpInfo)
    end

    data.competitionCount = pkt:GetChar()
    data.competitionList = {}
    for i = 1, data.competitionCount do
        local tmpInfo = {}
        tmpInfo.competName = pkt:GetLenString()
        tmpInfo.day = pkt:GetSignedChar()
        tmpInfo.time = pkt:GetLong()
        tmpInfo.otherName = pkt:GetLenString()
        tmpInfo.mySupports = pkt:GetLong()
        tmpInfo.otherSupports = pkt:GetLong()
        tmpInfo.isWin = pkt:GetChar()
        tmpInfo.mvCount = pkt:GetChar()
        tmpInfo.mvList = {}
        for j = 1, tmpInfo.mvCount do
            local mvDetail = {}
            mvDetail.id = pkt:GetLenString()
            mvDetail.result = pkt:GetChar()
            table.insert(tmpInfo.mvList, mvDetail)
        end

        table.insert(data.competitionList, tmpInfo)
    end
end

-- 名人争霸竞猜：通知客户端我的竞猜数据
function MsgParser:MSG_CG_MY_GUESS(pkt, data)
    data.supportCardNum = pkt:GetLong()
    data.jcPoints = pkt:GetLong()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.competName = pkt:GetLenString()
        tmpInfo.day = pkt:GetSignedChar()
        tmpInfo.aTeamId = pkt:GetLenString()
        tmpInfo.aTeamName = pkt:GetLenString()
        tmpInfo.aTeamSupportNum = pkt:GetLong()
        tmpInfo.bTeamId = pkt:GetLenString()
        tmpInfo.bTeamName = pkt:GetLenString()
        tmpInfo.bTeamSupportNum = pkt:GetLong()
        tmpInfo.mySupports = pkt:GetShort()
        tmpInfo.supportStatus = pkt:GetChar()
        tmpInfo.supportResult = pkt:GetChar()
        tmpInfo.incomes = pkt:GetLong()
        if tmpInfo.aTeamId ~= "" and tmpInfo.bTeamId ~= "" then
            -- 只保留两队都不轮空的数据
            table.insert(data.list, tmpInfo)
        end
    end
end

-- 名人争霸竞猜：通知客户端支持队伍后的结果
function MsgParser:MSG_CG_SUPPORT_RESULT(pkt, data)
    data.supportCardNum = pkt:GetLong()
    data.jcPoints = pkt:GetLong()
    data.day = pkt:GetSignedChar()
    data.competName = pkt:GetLenString()
    data.aTeamId = pkt:GetLenString()
    data.aTeamName = pkt:GetLenString()
    data.aTeamSupportNum = pkt:GetLong()
    data.bTeamId = pkt:GetLenString()
    data.bTeamName = pkt:GetLenString()
    data.bTeamSupportNum = pkt:GetLong()
    data.mySupports = pkt:GetShort()
    data.supportStatus = pkt:GetChar()
    data.supportResult = pkt:GetChar()
end

-- 名人争霸竞猜：通知客户端赛程信息
function MsgParser:MSG_CG_SCHEDULE(pkt, data)
    data.openDlgFlag = pkt:GetChar()
    data.hasChampion = pkt:GetChar()
    data.championId = pkt:GetLenString()
    data.championName = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.day = pkt:GetSignedChar()
        tmpInfo.date = pkt:GetLong()
        tmpInfo.teamCount = pkt:GetChar()
        for j = 1, tmpInfo.teamCount do
            local teamInfo = {}
            teamInfo.day = tmpInfo.day
            teamInfo.date = tmpInfo.date
            teamInfo.teamId = pkt:GetLenString()
            teamInfo.leaderName = pkt:GetLenString()
            teamInfo.isCanUse = pkt:GetChar()
            table.insert(data.list, teamInfo)
        end
    end
end

-- 角色基础数据
function MsgParser:MSG_LBS_CHAR_INFO(pkt, data)
    data.sex = pkt:GetChar()
    data.age = pkt:GetSignedChar()
    data.location = pkt:GetLenString()
    data.lat = pkt:GetLong() / 1000000
    data.lng = pkt:GetLong() / 1000000
    data.share_near_endtime = pkt:GetLong()
end

-- 个人空间中的头像信息
function MsgParser:MSG_LBS_BLOG_ICON_IMG(pkt, data)
    data.icon_img = pkt:GetLenString()
    data.under_review = pkt:GetChar()
end

-- 搜索附近的人 - 结果
function MsgParser:MSG_LBS_SEARCH_NEAR(pkt, data)
    data.share_near_endtime = pkt:GetLong()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.dist_name = pkt:GetLenString()
        info.icon = pkt:GetShort()
        info.level = pkt:GetShort()
        info.sex = pkt:GetChar()
        info.age = pkt:GetSignedChar()
        info.icon_img = pkt:GetLenString()
        info.lat = pkt:GetLong() / 1000000
        info.lng = pkt:GetLong() / 1000000
        table.insert(data, info)
    end
end

-- 区域好友列表
function MsgParser:MSG_LBS_FRIEND_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.char = pkt:GetLenString()
        info.dist_name = pkt:GetLenString()
        info.icon = pkt:GetShort()
        info.level = pkt:GetShort()
        info.sex = pkt:GetChar()
        info.age = pkt:GetSignedChar()
        info.icon_img = pkt:GetLenString()
        info.location = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 区域好友GID列表
function MsgParser:MSG_LBS_FRIEND_GID_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 通知客户端打开区域好友验证
function MsgParser:MSG_LBS_ADD_FRIEND_VERIFY(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.dist_name = pkt:GetLenString()
    data.setting_flag = pkt:GetLong()
end

-- 通知被加为区域好友
function MsgParser:MSG_LBS_BE_ADD_FRIEND(pkt, data)
    data.name = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.dist_name = pkt:GetLenString()
    data.setting = pkt:GetLong()
end

-- 通知客户端添加好友成功
function MsgParser:MSG_LBS_ADD_FRIEND_OPER(pkt, data)
    data.gid = pkt:GetLenString()
    data.char = pkt:GetLenString()
    data.dist_name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.level = pkt:GetShort()
    data.sex = pkt:GetChar()
    data.age = pkt:GetSignedChar()
    data.icon_img = pkt:GetLenString()
    data.location = pkt:GetLenString()
end

-- 添加区域好友黑名单
function MsgParser:MSG_LBS_REMOVE_FRIEND(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 返回区域排行榜数据
function MsgParser:MSG_LBS_RANK_INFO(pkt, data)
    data.type = pkt:GetShort()
    data.count = pkt:GetShort()

    for i = 1, data.count do
        local info = {}
        Builders:BuildFields(pkt, info)
        info.rank = i
        data[i] = info
    end
end

-- 同城功能开关
function MsgParser:MSG_LBS_ENABLE(pkt, data)
    data.enable = pkt:GetChar()
end
-- 名人争霸-淘汰赛数据
function MsgParser:MSG_CSB_KICKOUT_TEAM_MATCH_INFO(pkt, data)
    data.round_id = pkt:GetLenString()

    data.myTeamName = pkt:GetLenString()
    data.oppTeamName = pkt:GetLenString()

    data.warCount = pkt:GetChar()
    local resultStr = pkt:GetLenString()
    data.myResult = {} -- 战斗结果标记，例："10" ，如果此时总局数为3，说明第一局 我 胜利，第二局 other 胜利，第三局还没打
    for i = 1, data.warCount do
        data.myResult[i] = string.sub(resultStr, i, i)
    end
    data.is_yuxuan = pkt:GetChar() -- 1预选，0淘汰
    data.warClass = self:forMingrenZhengbaChanegeClass(data)
end

-- 用于转化名人争霸，淘汰赛、预选赛等
function MsgParser:forMingrenZhengbaChanegeClass(data)
    local round_id = data.round_id

    if data.is_yuxuan == 1 then
        return MINGREN_ZHENGBA_CLASS.YUXUAN
    end

    if round_id == "kickout_1_1" then
        return MINGREN_ZHENGBA_CLASS.JUESAI
    elseif round_id == "kickout_2_1" then
        return MINGREN_ZHENGBA_CLASS.BAN_JUESAI
    elseif round_id == "kickout_128_1" then
        return MINGREN_ZHENGBA_CLASS.YUXUAN
    else
        return MINGREN_ZHENGBA_CLASS.TAOTAI
    end
end


-- 名人争霸-预选赛数据
function MsgParser:MSG_CSB_PRE_KICKOUT_TEAM_MATCH_INFO(pkt, data)
    data.round_id = pkt:GetLenString()

    data.condition = pkt:GetChar() -- 晋级分数
    data.places = pkt:GetShort()    -- 名额
    data.myTeamPoint = pkt:GetChar() -- 分数
    data.myTeamRank = pkt:GetShort()    -- 队伍排名
        data.is_yuxuan = pkt:GetChar() -- 1预选，0淘汰
            data.warClass = self:forMingrenZhengbaChanegeClass(data)
end

function MsgParser:MSG_CSB_MATCH_TIME_INFO(pkt, data)
    data.round_id = pkt:GetLenString()

    data.enterWarPlace = pkt:GetLong()
    data.startTime = pkt:GetLong()
    data.pair_time = pkt:GetLong()
    data.endTime = pkt:GetLong()
    data.protect_time = pkt:GetLong()
    data.rest_time = pkt:GetLong()  -- 战斗结束休息时间，淘汰赛使用
    data.result = pkt:GetChar() -- 0没有结果，1晋级，2淘汰
    data.is_yuxuan = pkt:GetChar() -- 1预选，0淘汰
        data.warClass = self:forMingrenZhengbaChanegeClass(data)
end

function MsgParser:MSG_CSB_BONUS_INFO(pkt, data)
    data.bonus_type = pkt:GetShort()    -- 奖励类型, 128 - 128淘汰赛；64 - 64淘汰赛 ... 2 - 亚军，1 - 冠军

    -- 名人争霸 0 冠军，  1亚军， 2 四强  4八强 16 三十二强 64 一二八枪

    data.count = pkt:GetChar()      -- 队伍数量

    for i = 1, data.count do
        data[i] = {}
        data[i].gid = pkt:GetLenString()
        data[i].name = pkt:GetLenString()
        data[i].level = pkt:GetShort()
        data[i].polar = pkt:GetChar()
        data[i].icon = pkt:GetShort()
    end
end

function MsgParser:MSG_CHANNEL_TIP(pkt, data)
    data.channel = pkt:GetShort()        -- 频道编号，例如：好友频道（CHANNEL_FRIEND）
    data.from_gid = pkt:GetLenString()   -- 发送方GID
    data.from_name = pkt:GetLenString()  -- 发送方名字
    data.recv_gid = pkt:GetLenString()   -- 接收方GID
    data.recv_name = pkt:GetLenString()   -- 接收方GID
    data.message = pkt:GetLenString()    -- 提示信息
end

-- 通知开始摇签
function MsgParser:MSG_DIVINE_START_GAME(pkt, data)
    data.stick = pkt:GetChar()
    data.type = pkt:GetChar()
end

-- 通知结束摇签
function MsgParser:MSG_DIVINE_END_GAME(pkt, data)
    data.stick = pkt:GetChar()
    data.type = pkt:GetChar()
    data.isOk = pkt:GetSignedChar()
end

-- 通知摇签结果
function MsgParser:MSG_DIVINE_GAME_RESULT(pkt, data)
    data.type = pkt:GetChar()
    data.des = pkt:GetLenString()
end

-- 通知客户端生成耐久性道具
function MsgParser:MSG_MERGE_DURABLE_ITEM(pkt, data)
    data.flag = pkt:GetChar()
end

-- 显示会员礼包可选中的时装列表
function MsgParser:MSG_SHOW_INSIDER_GIFT(pkt, data)
    data.pos = pkt:GetShort()
    data.insider_price = pkt:GetShort()
    data.fasion_price = pkt:GetShort()
    data.count = pkt:GetChar()      -- 时装数量
    for i = 1, data.count do
        data[i] = pkt:GetLenString()    -- 可供选择的时装名称
    end
end
-- 图鉴评论查询列表
function MsgParser:MSG_HANDBOOK_COMMENT_QUERY_LIST(pkt, data)
    data.key_name = pkt:GetLenString()
    data.last_id = pkt:GetLenString()
    data.count = pkt:GetSignedShort()
    for i = 1, data.count do
        local info = {}
        info.id = pkt:GetLenString()
        info.time = pkt:GetLong()
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.comment = pkt:GetLenString()
        info.like_num = pkt:GetShort()
        info.has_like = pkt:GetChar()
        table.insert(data, info)
    end
end

-- 通知发布评论成功
function MsgParser:MSG_HANDBOOK_COMMENT_PUBLISH(pkt, data)
    data.id = pkt:GetLenString()
    data.key_name = pkt:GetLenString()
    data.comment = pkt:GetLenString()
    data.time = pkt:GetLong()
end

-- 通知删除评论成功
function MsgParser:MSG_HANDBOOK_COMMENT_DELETE(pkt, data)
    data.id = pkt:GetLenString()
end

-- 通知点赞成功
function MsgParser:MSG_HANDBOOK_COMMENT_LIKE(pkt, data)
    data.id = pkt:GetLenString()
end

function MsgParser:MSG_OPEN_WEDDING_CHANNEL(pkt, data)
    data.startTime = pkt:GetLong()
end

-- 打雪仗-角色数据
function MsgParser:MSG_DAXZ_CHAR_INFO(pkt, data)
    data.corps = pkt:GetChar()      -- 玩家阵营， 1 攻击方，2 防御方
    self:MSG_UPDATE_APPEARANCE(pkt, data)
end

-- 打雪仗-结束
function MsgParser:MSG_DAXZ_END(pkt, data)
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.dir = pkt:GetChar()      -- 方向
end

-- 打雪仗-操作阶段
function MsgParser:MSG_DAXZ_OPER(pkt, data)
    self:MSG_WINTER2018_DAXZ_OPER(pkt, data)
end

-- 打雪仗-显示阶段
function MsgParser:MSG_DAXZ_SHOW(pkt, data)
    data.count = pkt:GetChar()      --
    for i = 1, data.count do
        local id = pkt:GetLong()
        if id == Me:getId() then
            data.player_oper = pkt:GetChar()
        else
            data.npc_oper = pkt:GetChar()
        end
    end

    data.player_xq_num = pkt:GetChar()
end

-- 夫妻任务，打雪仗，奖励
function MsgParser:MSG_DAXZ_OPER(pkt, data)
    self:MSG_WINTER2018_DAXZ_OPER(pkt, data)
end

-- 夫妻任务-打雪仗-奖励
function MsgParser:MSG_DAXZ_BONUS(pkt, data)
    data.ret = pkt:GetChar()    --  1：胜利，2：失败
    data.tao = pkt:GetLong()
    data.martial = pkt:GetLong()
    data.exp = 0
    data.itemName = pkt:GetLenString()
    data.isExitGame = pkt:GetChar()
end


function MsgParser:MSG_DUANWU_2018_COLLISION(pkt, data)
    data.ret = pkt:GetChar()    --   1 = 碰撞成功， 0 = 碰撞失败
end

-- 打雪仗操作状态
function MsgParser:MSG_DAXZ_OPER_STATE(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].id = pkt:GetLong()
        data[i].is_done = pkt:GetChar()
    end
end

-- 暑假活动-智斗炼魔NPC动作
function MsgParser:MSG_SUMMER_2018_ACTION(pkt, data)
    data.npc_id = pkt:GetLong()    --  1：胜利，2：失败
    data.flag = pkt:GetChar()   -- 1 表示躺下， flag = 0 恢复正常
end

-- 开始寒气之脉
function MsgParser:MSG_SUMMER_2018_HQZM_START(pkt, data)
    data.cou = pkt:GetChar()
    data.path = {}
    for i = 1, data.cou do
        table.insert(data.path, pkt:GetChar())
    end
end

-- 结束寒气之脉
function MsgParser:MSG_SUMMER_2018_HQZM_END(pkt, data)
    data.flag = pkt:GetChar() -- 1踩错
end

-- 进入游戏场景
function MsgParser:MSG_YUANSGW_START_GAME(pkt, data)
    data.map_name = pkt:GetLenString() -- 场景地图
    data.x = pkt:GetChar()      -- 地图视野固定坐标中心点X
    data.y = pkt:GetChar()      -- 地图视野固定坐标中心点Y
end

-- 角色的游戏信息
function MsgParser:MSG_YUANSGW_CHAR_INFO(pkt, data)
    data.type = pkt:GetChar() -- 阵营
    data.player = {}
    self:MSG_C_UPDATE_APPEARANCE(pkt, data.player)
end

-- 游戏当前回合数
function MsgParser:MSG_YUANSGW_CUR_ROUND(pkt, data)
    data.round = pkt:GetChar() -- 回合数
    data.nxet_round_time = pkt:GetLong()  -- 下一回合开始时间
    data.temp1 = pkt:GetChar() -- 本体温度
    data.temp2 = pkt:GetChar() -- 元神温度

    data.count = pkt:GetChar() -- 元神温度
    for i = 1, data.count do
        data[i] = {}
        data[i].id = pkt:GetLong() -- 角色ID
        data[i].flag = pkt:GetChar() -- 0 = 等待输入指令， 1 = 指令已输入完成
    end
end

-- 进入游戏等待状态
function MsgParser:MSG_YUANSGW_WAIT_COMMAND(pkt, data)
    data.wait_command_time = pkt:GetChar()   -- 等待剩余时间
    data.round = pkt:GetChar()               -- 当前回合数
    data.time = pkt:GetLong()                -- 系统时间
end

-- 设置指令成功后，清除角色身上的沙漏
function MsgParser:MSG_YUANSGW_SANDGLASS(pkt, data)
    data.id = pkt:GetLong() -- 角色ID
    data.flag = pkt:GetChar() -- 0 = 失败， 1 = 成功
end

-- 通知退出游戏
function MsgParser:MSG_YUANSGW_QUIT_GAME(pkt, data)
    data.id = pkt:GetLong() -- 角色ID
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
end

-- 通知客户端聚宝斋自动登录token
function MsgParser:MSG_TRADING_AUTO_LOGIN_TOKEN(pkt, data)
    data.token = pkt:GetLenString()
end

-- 通知客户端打开拼图界面
function MsgParser:MSG_SUMMER_2018_PUZZLE(pkt, data)
    data.status = pkt:GetChar()
    data.mapName = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.order = {}
    for i = 1, data.count do
        data.order[i] = pkt:GetChar()
    end
end

-- 通知客户端下雨相关信息
function MsgParser:MSG_SUMMER_2018_WEATHER(pkt, data)
    data.mapName = pkt:GetLenString()
    data.rainStartTime = pkt:GetLong()
    data.rainEndTime = pkt:GetLong()
end

-- 游戏当前回合播放序列
function MsgParser:MSG_YUANSGW_ACTION_SEQUENCE(pkt, data)
    local count = pkt:GetChar() -- 数量
    for i = 1, count do
        local info = {}
        info.caster_id = pkt:GetLong() -- 当前ID
        info.victim_id = pkt:GetLong() -- 目标ID
        info.action = pkt:GetChar() -- 动作ID，即 1-7
        info.temp_bef = pkt:GetChar()  -- 之前温度
        info.temp_aft = pkt:GetChar()  -- 之后温度
        table.insert(data, info)
    end
end

-- 证道殿护法
function MsgParser:MSG_OVERCOME_NPC_INFO(pkt, data)
    data.id = pkt:GetLong()
    data.isLeader = pkt:GetChar()
    Builders:BuildFields(pkt, data)
end

-- 通知客户端竞拍的商品gid
function MsgParser:MSG_TRADING_AUCTION_BID_GIDS(pkt, data)
    data.count = pkt:GetChar()      --
    for i = 1, data.count do
        data[i] = pkt:GetLenString()
    end
end

-- 通知聚宝斋竞拍列表
function MsgParser:MSG_TRADING_AUCTION_BID_LIST(pkt, data)
    data.count = pkt:GetChar()      --
    for i = 1, data.count do
         data[i] = {}
         self:MSG_TRADING_GOODS_INFO(pkt, data[i])
    end
end

-- 通知客户端打开聚宝斋 url，并且自动登录
function MsgParser:MSG_TRADING_OPEN_URL(pkt, data)
    data.trading_url = pkt:GetLenString()
    data.text = pkt:GetLenString()
    data.str_cancel = pkt:GetLenString()
    data.str_confirm = pkt:GetLenString()
    data.goods_gid = pkt:GetLenString()
    data.auto_favorite = pkt:GetChar()      --
    data.action = pkt:GetChar()
end

-- 吃瓜比赛 - 比赛数据
function MsgParser:MSG_SUMMER_2018_CHIGUA_DATA(pkt, data)
    data.player_id1 = pkt:GetLong() --玩家1的ID，对应站位47，33     重连时，如果该玩家已下线，有可能为0
    data.player_id2 = pkt:GetLong() --玩家2的ID，对应站位45，35     重连时，如果该玩家已下线，有可能为0
    data.start_time = pkt:GetLong() -- 比赛开始时间，显示倒计时
    data.frame_interval = pkt:GetShort() --每帧多少毫秒
    data.total_distance = pkt:GetLong() / 1000000 --跑道总路程: INT(浮点数 * 1000000)
end

-- 吃瓜比赛 - 加速图标
function MsgParser:MSG_SUMMER_2018_CHIGUA_EFFECT(pkt, data)
    data.seq = pkt:GetShort() -- 第几帧
    data.pos = pkt:GetChar() -- 随机数，双方玩家根据同一个公式，计算加速图标显示在哪个位置
    data.end_seq = pkt:GetShort() -- 加速效果第几帧结束
end

-- 吃瓜比赛 - 帧数据
function MsgParser:MSG_SUMMER_2018_CHIGUA_FRAME(pkt, data)
    data.seq = pkt:GetShort() -- 第几帧
    data.frame_interval = pkt:GetShort() -- 距离上一帧的时间可能大于 MSG_SUMMER_2018_CHIGUA_DATA 中的帧间隔
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.from_distance = pkt:GetLong() / 1000000 -- 本帧起跑点(浮点数 * 1000000)
        info.to_distance = pkt:GetLong() / 1000000 -- 本帧目标点
        info.show_effect = pkt:GetChar() -- 是否显示加速光效
        table.insert(data, info)
    end
end

-- 吃瓜比赛 - 结果
function MsgParser:MSG_SUMMER_2018_CHIGUA_RESULT(pkt, data)
    data.ob1_result = pkt:GetChar()
    data.ob2_result = pkt:GetChar()
end

-- 打开纪念册
function MsgParser:MSG_WB_HOME_INFO(pkt, data)
    data.book_id = pkt:GetLenString()
    data.wedding_start_ti = pkt:GetLong()
    data.wedding_end_ti = pkt:GetLong()
    data.hus_name = pkt:GetLenString()
    data.wife_name = pkt:GetLenString()
    data.home_img = pkt:GetLenString()
end

-- 打开日记本
function MsgParser:MSG_WB_DIARY_SUMMARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.diarys = {}
    data.diaryList = {}
    data.page = pkt:GetShort()
    data.page_count = pkt:GetShort()
    for i = 1, data.page_count do
        local diary = {}
        diary.diary_id = pkt:GetLenString()
        diary.create_time = pkt:GetLong()
        diary.last_edit_time = pkt:GetLong()
        diary.general = pkt:GetLenString()
        diary.flag = pkt:GetLong()
        diary.showFlag = pkt:GetChar()
        diary.icon = pkt:GetLong()
        data.diarys[diary.diary_id] = diary
    end
end

-- 打开一篇日记
function MsgParser:MSG_WB_DIARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.diary_id = pkt:GetLenString()
    data.content = pkt:GetLenString2()
    data.flag = pkt:GetChar()
end

-- 新增日志
function MsgParser:MSG_WB_DIARY_ADD_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
    data.diary_id = pkt:GetLenString()
end

-- 编辑日记
function MsgParser:MSG_WB_DIARY_EDIT_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.diary_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 删除日记
function MsgParser:MSG_WB_DIARY_DELETE_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.diary_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 查看纪念日
function MsgParser:MSG_WB_DAY_SUMMARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.days = {}
    for i = 1, data.count do
        local day = {}
        day.day_id = pkt:GetLenString()
        day.icon = pkt:GetLenString()
        day.name = pkt:GetLenString()
        day.day_time = pkt:GetLong()
        day.type = pkt:GetChar()
        day.flag = pkt:GetLong()
        day.last_check_ti = pkt:GetLong()
        data.days[day.day_id] = day
    end
end

-- 新增纪念日
function MsgParser:MSG_WB_DAY_ADD_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
    data.day_id = pkt:GetLenString()
end

-- 编辑纪念日
function MsgParser:MSG_WB_DAY_EDIT_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.day_id = pkt:GetLenString()
    data.icon = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.day_time = pkt:GetLong()
    data.flag = pkt:GetLong()
end

-- 删除纪念日
function MsgParser:MSG_WB_DAY_DELETE_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.day_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 主界面图片
function MsgParser:MSG_WB_HOME_PIC(pkt, data)
    data.book_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 提交图片
function MsgParser:MSG_WB_PHOTO_COMMIT_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
    data.photo_id = pkt:GetLenString()
end

-- 编辑描述
function MsgParser:MSG_WB_PHOTO_EDIT_MEMO_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.photo_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 删除图片
function MsgParser:MSG_WB_PHOTO_DELETE_RESULT(pkt, data)
    data.book_id = pkt:GetLenString()
    data.photo_id = pkt:GetLenString()
    data.flag = pkt:GetChar()
end

-- 请求相册列表
function MsgParser:MSG_WB_PHOTO_SUMMARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.page = pkt:GetShort()
    data.page_count = pkt:GetShort()
    data.photos = {}
    for i = 1, data.page_count do
        local photo = {}
        photo.photo_id = pkt:GetLenString()
        photo.img = pkt:GetLenString()
        photo.memo = pkt:GetLenString()
        photo.publish_time = pkt:GetLong()
        photo.showFlag = pkt:GetChar()
        data.photos[photo.photo_id] = photo
    end
end

-- 更新照片数据
function MsgParser:MSG_WB_UPDATE_PHOTO(pkt, data)
    data.book_id = pkt:GetLenString()
    data.photo_id = pkt:GetLenString()
    data.img = pkt:GetLenString()
    data.memo = pkt:GetLenString()
    data.publish_time = pkt:GetLong()
    data.showFlag = pkt:GetChar()
end

-- 删除照片数据
function MsgParser:MSG_WB_DELETE_PHOTO(pkt, data)
    data.book_id = pkt:GetLenString()
    data.photo_id = pkt:GetLenString()
end

-- 更新日记数据
function MsgParser:MSG_WB_UPDATE_DIARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.diary_id = pkt:GetLenString()
    data.last_edit_time = pkt:GetLong()
    data.content = pkt:GetLenString2()
    data.general = pkt:GetLenString()
    data.flag = pkt:GetLong()
    data.showFlag = pkt:GetChar()
    data.icon = pkt:GetLong()
end

-- 删除日记数据
function MsgParser:MSG_WB_DELETE_DIARY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.diary_id = pkt:GetLenString()
end

-- 更新纪念日数据
function MsgParser:MSG_WB_UPDATE_DAY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.day_id = pkt:GetLenString()
    data.icon = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.day_time = pkt:GetLong()
    data.type = pkt:GetChar()
    data.flag = pkt:GetLong()
    data.last_check_ti = pkt:GetLong()
end

-- 删除纪念日数据
function MsgParser:MSG_WB_DELETE_DAY(pkt, data)
    data.book_id = pkt:GetLenString()
    data.day_id = pkt:GetLenString()
end

-- 主页图片
function MsgParser:MSG_WB_UPDATE_HOME_PIC(pkt, data)
    data.book_id = pkt:GetLenString()
    data.img = pkt:GetLenString()
end

-- 创建纪念册成功
function MsgParser:MSG_WB_CREATE_BOOK_EFFECT(pkt, data)
    data.pos = pkt:GetChar()
end

-- 通知客户端关卡信息
function MsgParser:MSG_LCHJ_INFO(pkt, data)
    data.curStage = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local stageInfo = {}
        stageInfo.name = pkt:GetLenString()
        stageInfo.state = pkt:GetChar()
        table.insert(data.list, stageInfo)
    end

    data.isMustOpenDlg = pkt:GetChar()
end

-- 通知客户端布阵信息
function MsgParser:MSG_LCHJ_PETS_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local petInfo = {}
        petInfo.no = pkt:GetChar()
        petInfo.pos = pkt:GetChar()
        table.insert(data.list, petInfo)
    end

    data.monsterCount = pkt:GetChar()
    data.monsterList = {}
    for i = 1, data.monsterCount do
        local monsterInfo = {}
        monsterInfo.name = pkt:GetLenString()
        monsterInfo.icon = pkt:GetLong()
        monsterInfo.pos = pkt:GetChar()
        table.insert(data.monsterList, monsterInfo)
    end
end

-- 通知客户端宠物的禁用技能信息
function MsgParser:MSG_LCHJ_DISABLE_SKILLS(pkt, data)
    data.no = pkt:GetChar()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local id = pkt:GetShort()
        table.insert(data.list, id)
    end
end

-- 是否可以打开赛程界面
function MsgParser:MSG_CG_CAN_OPEN_SECHEDULE(pkt, data)
    data.canOpen = pkt:GetChar()
end

-- 首饰转换完成
function MsgParser:MSG_TRANSFORM_JEWELRY_COMPLETE(pkt, data)
    data.pos = pkt:GetShort() -- 操作位置
end

-- 客户端进行砍价
function MsgParser:MSG_HEISHI_KANJIA_INFO(pkt, data)
    data.itemName = pkt:GetLenString()
    data.itemsCount = pkt:GetChar()
    data.orgPrice = pkt:GetShort()
    data.price = pkt:GetShort()
    data.lastCutPrice = pkt:GetShort()
    data.isStart = pkt:GetChar() -- 未开始则打开界面
    data.totalTime = pkt:GetChar()
    data.endTime = pkt:GetLong()
    data.type = pkt:GetChar()
end

-- 首饰分解完成
function MsgParser:MSG_SPLIT_JEWELRY_COMPLETE(pkt, data)
    data.type = pkt:GetChar()  -- 0 失败  1 成功
    data.tip = pkt:GetLenString()
end

-- 客栈 - 通知客栈基础数据
function MsgParser:MSG_INN_BASE_DATA(pkt, data)
    data.level = pkt:GetChar()
    data.exp = pkt:GetShort()
    data.expToNext = pkt:GetShort()
    data.deluxe = pkt:GetShort()
    data.unitTongCoin = pkt:GetShort()
    data.tongCoin = pkt:GetLong()
    data.innName = pkt:GetLenString()
    data.tableCount = pkt:GetChar()
    data.tableInfo = {}
    for i = 1, data.tableCount do
        local tmpInfo = {}
        tmpInfo.id = pkt:GetChar()
        tmpInfo.level = pkt:GetChar()
        table.insert(data.tableInfo, tmpInfo)
    end

    table.sort(data.tableInfo, function(l, r)
        if l.id < r.id then return true end
        if l.id > r.id then return false end
    end)

    data.roomCount = pkt:GetChar()
    data.roomInfo = {}
    for i = 1, data.roomCount do
        local tmpInfo = {}
        tmpInfo.id = pkt:GetChar()
        tmpInfo.level = pkt:GetChar()
        table.insert(data.roomInfo, tmpInfo)
    end

    table.sort(data.roomInfo, function(l, r)
        if l.id < r.id then return true end
        if l.id > r.id then return false end
    end)
end

-- 客栈 - 通知客栈候客区数据
function MsgParser:MSG_INN_WAITING_DATA(pkt, data)
    data.level = pkt:GetChar()
    data.guestCount = pkt:GetChar()
    data.guestCountMax = pkt:GetChar()
    data.waitTime = pkt:GetShort()
    data.guestFullTime = pkt:GetLong()
    data.beggerType = pkt:GetChar()
    data.beggerStartTime = pkt:GetLong()
    data.beggerEndTime = pkt:GetLong()
end

-- 客栈 - 通知客栈客人数据
function MsgParser:MSG_INN_GUEST_DATA(pkt, data)
    data.guestCount = pkt:GetChar()
    data.guestInfo = {}
    for i = 1, data.guestCount do
        local tmpInfo = {}
        tmpInfo.posInfo = pkt:GetLenString()
        local infoArray = gf:split(tmpInfo.posInfo, "_")
        tmpInfo.type = infoArray[1]
        tmpInfo.id = tonumber(infoArray[2])
        tmpInfo.pos = tonumber(infoArray[3])
        tmpInfo.state = pkt:GetChar()
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.startTime = pkt:GetLong()
        tmpInfo.offsetVal = pkt:GetLong()
        tmpInfo.bubbleId = pkt:GetLong()
        tmpInfo.preState = pkt:GetChar()
        tmpInfo.preName = pkt:GetLenString()
        tmpInfo.preIcon = pkt:GetLong()
        tmpInfo.preStartTime = pkt:GetLong()
        tmpInfo.barStartTime = pkt:GetLong()
        tmpInfo.barDuaration = pkt:GetChar()
        data.guestInfo[tmpInfo.posInfo] = tmpInfo
    end
end

-- 通知客户端播放动作
function MsgParser:MSG_NPC_ACTION(pkt, data)
    data.npcId = pkt:GetLong()
    data.action = pkt:GetLong()
end

-- 通知客户端添加 npc 最近频道消息
function MsgParser:MSG_ADD_NPC_TEMP_MSG(pkt, data)
    data.msgId = pkt:GetLong()
    data.msgType = pkt:GetChar()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.content = pkt:GetLenString()
    data.time = pkt:GetLong()
end

function MsgParser:MSG_MERGE_LOGIN_GIFT_LIST(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.loginDays = pkt:GetChar()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local bonus = {}
        bonus.index = pkt:GetChar()
        bonus.flag = pkt:GetChar()
        bonus.desc = pkt:GetLenString()
        data[i] = bonus
    end
end

function MsgParser:MSG_OPEN_XUNDAO_CIFU(pkt, data)
    data.start_time = pkt:GetLong()  -- 活动开始时间
    data.end_time = pkt:GetLong()  -- 活动结束时间
    data.total = pkt:GetShort()
    data.count = pkt:GetChar()
    data.rec_times = pkt:GetChar()
end

function MsgParser:MSG_OPEN_HUOYUE_JIANGLI(pkt, data)
    data.char_gid = pkt:GetLenString()
    data.fetch_flag = pkt:GetChar()
    data.open_time = pkt:GetLong()
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.fetch_silver = pkt:GetShort()
    data.count = pkt:GetChar()
    data.tasks = {}
    for i = 1, data.count do
        local task = {}
        task.task_name = pkt:GetLenString()
        task.cur_round = pkt:GetChar()
        task.max_round = pkt:GetChar()
        table.insert(data.tasks, task)
    end
end

-- gm 名人争霸控制数据
function MsgParser:MSG_CSB_GM_REQUEST_CONTROL_INFO(pkt, data)
    data.session = pkt:GetChar()         -- 场次
    data.captain = pkt:GetLenString()    -- 队长名称

    data.one_team_id = pkt:GetLenString()
    data.one_team_name = pkt:GetLenString()
    data.other_team_id = pkt:GetLenString()
    data.other_team_name = pkt:GetLenString()
end

function MsgParser:MSG_CROSS_SERVER_CHAR_INFO(pkt, data)
    data.gid = pkt:GetLenString()    --
    data.dist_name = pkt:GetLenString()    --
    data.name = pkt:GetLenString()    --
    data.level = pkt:GetShort()    --
    data.icon = pkt:GetLong()
    data.online = pkt:GetChar()
end

function MsgParser:MSG_LBS_ADD_FRIEND_TO_TEMP(pkt, data)
    data.user_gid = pkt:GetLenString()
    data.ret = pkt:GetChar()    -- 0 失败，弹确认框
end
-- 客户端收到此消息时，播放到圈圈的动作
function MsgParser:MSG_QIXI_2018_EFFECT(pkt, data)
    data.char_id = pkt:GetLong() --  播放动作的角色id
    data.carpet_x = pkt:GetShort() --
    data.carpet_y = pkt:GetShort() --
    data.radius = pkt:GetChar() --
    data.flag = pkt:GetChar()  -- 1 = 红圈圈, 2 = 黄圈圈
    data.msg = pkt:GetLenString()
end

-- 2018世界杯 -- 小组赛
function MsgParser:MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP(pkt, data)
    data.stage = pkt:GetLenString()    -- 比赛阶段
    data.support_team = pkt:GetLenString()    -- 支持球队
    data.support_num = pkt:GetShort()   -- 支持次数
    data.select_time_start = pkt:GetLong()  -- 可选择支持球队时间
    data.select_time_end = pkt:GetLong()
    data.support_time_start = pkt:GetLong()  -- 可使用球队支持卡时间
    data.support_time_end = pkt:GetLong()
    data.bonus_time_start = pkt:GetLong()  -- 可领取奖励时间
    data.bonus_time_end = pkt:GetLong()

    data.teams = {}
    for i = 1, 32 do
        data.teams[i] = pkt:GetLenString()
    end
end

function MsgParser:MSG_QIXI_2018_ACTOR(pkt, data)
    data.actor = pkt:GetChar() -- 1 = 挑战者， 2= 观察者， 0 = 无（均不可见）
end
-- 购买商城道具消息
function MsgParser:MSG_ASK_BUY_ONLINE_ITEM(pkt, data)
    data.para = pkt:GetLenString() -- 道具描述，同 WHETHER_BUY_ITEM 的 para 解析
    data.from = pkt:GetLenString() --来源
end

-- 返回检查生死状的条件
function MsgParser:MSG_LD_RET_CHECK_CONDITION(pkt, data)
    data.type = pkt:GetLenString() -- 检查类型
    data.result = pkt:GetChar()    -- 结果
    data.msg = pkt:GetLenString()  -- 提示信息
end
-- 商城购买道具结果
function MsgParser:MSG_BUY_FROM_MALL_RESULT(pkt, data)
    data.result = pkt:GetShort() -- 结果，1 表示购买成功，0 表示购买失败
    data.barcode = pkt:GetLenString() -- 条形码
end

-- 客栈 - 通知客栈任务数据
function MsgParser:MSG_INN_TASK_DATA(pkt, data)
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.id = pkt:GetShort()
        tmpInfo.coin = pkt:GetShort()
        tmpInfo.process = pkt:GetShort()
        tmpInfo.maxProcess = pkt:GetShort()
        tmpInfo.state = pkt:GetChar()
        data.list[i]  = tmpInfo
    end
end

-- 客栈 - 玩家登录后，需要通知给客户端的信息
function MsgParser:MSG_INN_ENTER_WORLD(pkt, data)
    data.enable = pkt:GetChar()
    data.level = pkt:GetChar()
end

-- 时装自定义界面信息
function MsgParser:MSG_FASION_CUSTOM_LIST(pkt, data)
    data.flag = pkt:GetChar()   -- 1 打开界面 0 仅刷新数据
    data.label = pkt:GetSignedChar()
    data.para = pkt:GetLenString()
    data.count2 = pkt:GetShort()
    data.malls = {}
    for i = 1, data.count2 do
        data.malls[i] = {}
        data.malls[i].name = pkt:GetLenString()
        data.malls[i].goods_price = pkt:GetLong()
    end
end

function MsgParser:MSG_PET_FASION_CUSTOM_LIST(pkt, data)
    self:MSG_FASION_CUSTOM_LIST(pkt, data)
end

-- 收藏柜数据
function MsgParser:MSG_FASION_FAVORITE_LIST(pkt, data)
    data.count = pkt:GetChar()
    data.favs = {}
    for i = 1, data.count do
        local fav = {}
        fav.fav_no = pkt:GetLong()
        fav.fav_name = pkt:GetLenString()
        fav.fav_plan = pkt:GetLenString()
        data.favs[fav.fav_no] = fav
    end
end

-- 收藏方案使用成功
function MsgParser:MSG_FASION_FAVORITE_APPLY(pkt, data)
    data.fav_no = pkt:GetLong()  -- 收藏方案编号
    data.label = pkt:GetChar()   -- 收藏对应的标签
end

-- 2018世界杯 -- 淘汰赛
function MsgParser:MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT(pkt, data)
    data.stage = pkt:GetLenString()    -- 比赛阶段
    data.support_team = pkt:GetLenString()    -- 支持球队
    data.support_num = pkt:GetShort()   -- 支持次数
    data.select_time_start = pkt:GetLong()  -- 可选择支持球队时间
    data.select_time_end = pkt:GetLong()
    data.support_time_start = pkt:GetLong()  -- 可使用球队支持卡时间
    data.support_time_end = pkt:GetLong()
    data.bonus_time_start = pkt:GetLong()  -- 可领取奖励时间
    data.bonus_time_end = pkt:GetLong()
    data.teams = {}
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data.teams[i] = {}
        data.teams[i].one_name = pkt:GetLenString()
        data.teams[i].one_result = pkt:GetSignedChar()
        data.teams[i].two_name = pkt:GetLenString()
        data.teams[i].two_result = pkt:GetSignedChar()

    end

            --[[
            #define NO_RESULT       0   // 没结果
            #define WINNER          1   // 胜利
            #define LOSER           2   // 失败
        --]]
end

-- 2018世界杯 -- 查询奖励信息
function MsgParser:MSG_WORLD_CUP_2018_BONUS_INFO(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].stage = pkt:GetLenString()
        data[i].support_team = pkt:GetLenString()
        data[i].promotion = pkt:GetSignedChar() -- -1:未开始 0:没有晋级 1:晋级   如果是半决赛阶段，1,2,3表示名次及是否晋级
        data[i].has_bonus = pkt:GetChar() -- 0:没有奖励 1:可领取 2:已领取
    end
end

-- 时装操作完成
function MsgParser:MSG_FASION_CUSTOM_END(pkt, data)
    data.type = pkt:GetLenString()
end

function MsgParser:MSG_FASION_CUSTOM_BEGIN(pkt, data)
    data.type = pkt:GetLenString()
end


-- 用于通知客户端显示图标
function MsgParser:MSG_LD_LIFEDEATH_ID(pkt, data)
    data.id = pkt:GetLenString() --  生死状 id
    data.time = pkt:GetLong()   -- 对决开始时间
    data.type = pkt:GetChar() -- 0 不播动画， 1 播动画
end

-- 生死状列表
function MsgParser:MSG_LD_LIFEDEATH_LIST(pkt, data)
    data.time_space = pkt:GetLong()  -- 时间间隔
    data.count = pkt:GetShort() -- 数量
    for i = 1, data.count do
        local info = {}
        info.time = pkt:GetLong()  -- 时间戳
        info.flag = pkt:GetChar()  -- 1 表示已预订，0 表示未预定
        table.insert(data, info)
    end
end

-- 应战方生死状数据
function MsgParser:MSG_LD_MATCH_DEFENSE_DATA(pkt, data)
    data.icon = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
end

-- 分布生死状的手续费
function MsgParser:MSG_LD_MATCH_LIFEDEATH_COST(pkt, data)
    data.cost = pkt:GetLong()
end

-- 生死状比赛数据
-- status
---- invalid 无效
---- atk_raise 挑战方发起
---- def_accept 应战方接受
---- def_refuse 应战方拒绝
---- over_time 超时
-- result
---- ""         没有结果
---- no_start"  双方都没来
---- atk"       挑战方胜利
---- def"       应战方胜利
---- draw"      平局（相当于应战方胜利）
function MsgParser:MSG_LD_MATCH_DATA(pkt, data)
    data.id = pkt:GetLenString()

    -- 挑战方数据
    local attInfo = {}
    attInfo.gid = pkt:GetLenString()
    attInfo.icon = pkt:GetLong()
    attInfo.name = pkt:GetLenString()
    attInfo.level = pkt:GetShort()
    data.attInfo = attInfo

    -- 应战方数据
    local defInfo = {}
    defInfo.gid = pkt:GetLenString()
    defInfo.icon = pkt:GetLong()
    defInfo.name = pkt:GetLenString()
    defInfo.level = pkt:GetShort()
    data.defInfo = defInfo

    data.status = pkt:GetLenString()     -- 当前状态 atk_raise 挑战方发起 def_accept 应战方接受 def_refuse 应战方拒绝,
    data.result = pkt:GetLenString()
    data.time = pkt:GetLong()            -- 开始时间
    data.mode = pkt:GetLenString()       -- 挑战模式
    data.bet_type = pkt:GetLenString()   -- 赌注类型
    data.bet_num = pkt:GetLong()         -- 赌注数量
end

function MsgParser:MSG_LD_HISTORY_PAGE(pkt, data)
    data.type = pkt:GetChar()  -- 1. 全部历史记录；2. 个人历史记录
    data.last_time = pkt:GetLong()
    data.count = pkt:GetSignedChar()
    for i = 1, data.count do
        local info = {}
        info.id = pkt:GetLenString()

        local att_info = {}
        att_info.gid = pkt:GetLenString()  -- 挑战方数据
        att_info.icon = pkt:GetLong()
        att_info.name = pkt:GetLenString()
        att_info.level = pkt:GetShort()
        info.att_info = att_info

        local def_info = {}
        def_info.gid = pkt:GetLenString()  -- 应战方数据
        def_info.icon = pkt:GetLong()
        def_info.name = pkt:GetLenString()
        def_info.level = pkt:GetShort()
        info.def_info = def_info

        info.result = pkt:GetLenString()    -- 当前状态,
        info.time = pkt:GetLong() -- 开始时间
        info.mode = pkt:GetLenString()      -- 挑战模式
        info.bet_type = pkt:GetLenString()  -- 赌注类型
        info.bet_num = pkt:GetLong()    -- 赌注数量

        -- 挑战方战斗数据
        local att_members = {}
        info.att_count = pkt:GetChar()
        for j = 1, info.att_count do
            att_members[j] = {}
            att_members[j].gid = pkt:GetLenString()
            att_members[j].icon = pkt:GetLong()
            att_members[j].name = pkt:GetLenString()
            att_members[j].level = pkt:GetShort()
        end

        info.att_members = att_members

        -- 应战方战斗数据
        local def_members = {}
        info.def_count = pkt:GetChar()
        for j = 1, info.def_count do
            def_members[j] = {}
            def_members[j].gid = pkt:GetLenString()
            def_members[j].icon = pkt:GetLong()
            def_members[j].name = pkt:GetLenString()
            def_members[j].level = pkt:GetShort()
        end

        info.def_members = def_members

        table.insert(data, info)
    end
end

function MsgParser:MSG_LD_GENERAL_INFO(pkt, data)
    data.own_gid = pkt:GetLenString()
    data.own_icon = pkt:GetLong()
    data.own_name = pkt:GetLenString()
    data.total_num = pkt:GetLong()
    data.send_num = pkt:GetLong()
    data.rec_num = pkt:GetLong()
    data.win_num = pkt:GetLong()
    data.win_cash = pkt:GetLong() * 1000 -- 服务端已千万为单位，客户端已万为单位
    data.win_coin = pkt:GetLong()
end

-- 打开乾坤图
function MsgParser:MSG_GHOST_2018_QIANKT(pkt, data)
    data.index = pkt:GetChar()
    data.mapName = pkt:GetLenString()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
end

-- 打开天机仪
function MsgParser:MSG_GHOST_2018_TIANJY(pkt, data)
    data.actionFlag = pkt:GetChar()
    data.mapName = pkt:GetLenString()
    data.monsterX = pkt:GetShort()
    data.monsterY = pkt:GetShort()
end

-- 播放成功、失败光效
function MsgParser:MSG_OPERATE_RESULT(pkt, data)
    data.flag = pkt:GetChar() -- flag = 0，表示失败； flag = 1，表示成功
    data.opType = pkt:GetLenString() -- 操作类型
    --[[
    套装炼化    :   "suit_refine"
    装备拆分    :   "equip_split"
    装备改造    :   "equip_upgrade"
    装备炼化    :   "pink_refine" / "gold_refine"
    守护培养    :   "guard_grow"
    首饰合成    :   "jewelry_upgrade"
    宠物强化    :   "pet_rebuild"
    宠物洗炼    :   "pet_refine"
        --]]
end

-- 英雄会护法
function MsgParser:MSG_HERO_NPC_INFO(pkt, data)
    data.id = pkt:GetLong()
    data.isLeader = pkt:GetChar()
    Builders:BuildFields(pkt, data)
end

-- 停止战斗中光效
function MsgParser:MSG_C_STOP_LIGHT_EFFECT(pkt, data)
    data.charId = pkt:GetLong()
    data.effectIcon = pkt:GetShort()
end

-- 通知播放战斗中循环光效
function MsgParser:MSG_COMBAT_LIGHT_EFFECT(pkt, data)
    data.charId = pkt:GetLong()
    data.effectIcon = pkt:GetShort()
    data.effectPos = pkt:GetLong()
end

function MsgParser:MSG_FINISH_NTMSL_TASK(pkt, data)
    data.chengwei = pkt:GetLenString()
    data.exp = pkt:GetLong()
    data.xianmoPoint = pkt:GetChar()
end

-- 卷宗数据
function MsgParser:MSG_DETECTIVE_TASK_CLUE(pkt, data)
    data.taskName = pkt:GetLenString()
    data.percent = pkt:GetSignedShort() / 10
    data.showLeftTime = pkt:GetLong() - gf:getServerTime()
    data.hasNext = pkt:GetChar()
    data.hasNext = data.hasNext == 1
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.index = i
        tmpInfo.state = pkt:GetLenString()
        tmpInfo.des = pkt:GetLenString()
        tmpInfo.tips = pkt:GetLenString()
        tmpInfo.remarks = pkt:GetLenString()
        if i == data.count then
            tmpInfo.showLeftTime = data.showLeftTime
        else
            tmpInfo.showLeftTime = 0
        end

        data.list[i] = tmpInfo
    end
end

-- 卷宗数据
function MsgParser:MSG_DETECTIVE_TASK_CLUE_PARALLEL(pkt, data)
    data.taskName = pkt:GetLenString()
    data.percent = pkt:GetSignedShort() / 10
    data.hasNext = pkt:GetChar()
    data.hasNext = data.hasNext == 1
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.index = i
        tmpInfo.state = pkt:GetLenString()
        tmpInfo.des = pkt:GetLenString()
        tmpInfo.tips = pkt:GetLenString()
        tmpInfo.remarks = pkt:GetLenString()
        tmpInfo.showLeftTime = pkt:GetLong() - gf:getServerTime()

        data.list[i] = tmpInfo
    end
end

-- 十佳捕快排行榜
function MsgParser:MSG_DETECTIVE_RANKING_INFO(pkt, data)
    data.meFinishTime = pkt:GetSignedLong()
    data.meTanLevel = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.gid = pkt:GetLenString()
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.tanLevel = pkt:GetLenString()
        tmpInfo.tanTime = pkt:GetLong()
        data.list[i] = tmpInfo
    end
end

-- 【探案】江湖绿林 - 开始、结束进行巡游
function MsgParser:MSG_TANAN_JHLL_GAME_XY(pkt, data)
    data.isStart = pkt:GetChar()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.text = pkt:GetLenString()
        data.list[i] = tmpInfo
    end
end

-- 【探案】江湖绿林 - 开始、结束进行跟踪
function MsgParser:MSG_TANAN_JHLL_GAME_GZ(pkt, data)
    data.isStart = pkt:GetChar()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetLong()
end

-- 【探案】江湖绿林 - 八卦爻的信息
function MsgParser:MSG_TANAN_JHLL_GUA_YAO(pkt, data)
    data.mapName = pkt:GetLenString()
    data.answer = pkt:GetLenString()
    data.ret = pkt:GetLenString()
end

-- 纸条数据
function MsgParser:MSG_RKSZ_PAPER_MESSAGE(pkt, data)
    data.name = pkt:GetLenString()
    data.timeStr = pkt:GetLenString()
end


function MsgParser:MSG_TEACHER_2018_GAME_S6(pkt, data)
    data.question = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.select = {}
    for i = 1, 4 do
        data.select[pkt:GetLenString()] = i
    end

    data.answer = pkt:GetChar()
    data.end_ti = pkt:GetLong()
end

function MsgParser:MSG_TEACHER_2018_GAME_S2(pkt, data)
    data.min_power = pkt:GetChar()
    data.max_power = pkt:GetChar()

    data.total_power = pkt:GetShort()
    data.count = pkt:GetChar()
    data.members = {}
    for i = 1, data.count do
        data.members[i] = {}
        data.members[i].gid = pkt:GetLenString()
        data.members[i].name = pkt:GetLenString()
        data.members[i].level = pkt:GetShort()
        data.members[i].icon = pkt:GetLong()
		data.members[i].power = pkt:GetSignedChar()
    end

    data.end_ti = pkt:GetLong()
end

-- 通知信件界面提示信息(打开信件界面)
function MsgParser:MSG_TWZM_LETTER_DATA(pkt, data)
    data.letter_clue = pkt:GetLenString() -- 信封中的线索
    data.cou = pkt:GetShort()
    for i = 1, data.cou do
        local str = pkt:GetLenString()
        table.insert(data, str)
    end
end

-- 通知盒子上的文字信息(打开盒子界面)
function MsgParser:MSG_TWZM_BOX_DATA(pkt, data)
    data.cou = pkt:GetShort() -- int16，文字数目
    for i = 1, data.cou do
        local info = {}
        info.word = pkt:GetLenString()  -- 文字内容(按顺序排列)
        info.img_index = pkt:GetChar()  -- 文字图案类型(1-4)
        table.insert(data, info)
    end

    data.total_num = pkt:GetChar() -- 点击总次数
end

-- 通知开锁结果
function MsgParser:MSG_TWZM_BOX_RESULT(pkt, data)
    data.result = pkt:GetChar() -- 0表示失败，1表示正确，2表示正确但包裹不足。
end

-- 通知拼图信息(打开拼图界面)
function MsgParser:MSG_TWZM_JIGSAW_DATA(pkt, data)
    data.map_name = pkt:GetLenString() -- 地图名称
    data.npc_x = pkt:GetShort() -- x坐标
    data.npc_y = pkt:GetShort() -- y坐标
    data.gameStatus = pkt:GetLenString2() -- 当前界面状态
    data.gid = pkt:GetLenString()-- 本任务 gid，用于校验
end

-- 通知开始摘桃子游戏
function MsgParser:MSG_TWZM_START_PICK_PEACH(pkt, data)
    data.flag = pkt:GetChar() --0表示打开界面，1表示正式开始
end

-- 通知摘桃子游戏结束或暂停
function MsgParser:MSG_TWZM_QUIT_PICK_PEACH(pkt, data)
    data.flag = pkt:GetChar() -- 0表示暂停，1表示结束
end

-- 通知矩阵数字(打开矩阵界面)
function MsgParser:MSG_TWZM_MATRIX_DATA(pkt, data)
    data.tip_index = pkt:GetChar() -- 提示内容类型 1-4，对应文档中四种奇偶类型。
    data.tip_place = pkt:GetChar() -- 提示内容的位置(1-5)。
    data.zhensf_num = pkt:GetChar() -- 镇尸符数量
    data.isComplete = pkt:GetChar() -- 是否完成贴符
    data.gameStatus = pkt:GetLenString2() -- 当前界面状态
    data.cou = pkt:GetShort() -- 数字数目
    data.formula = {}
    for i = 1, data.cou do
        local info = {}
        info.num = pkt:GetChar() -- 数字位置。按先上侧后左侧显示9个数字。
        info.index = pkt:GetChar() -- 数字使用的公式编号(1-4)。
        data.formula[i] = info
    end
end

-- 通知客户端矩阵结果
function MsgParser:MSG_TWZM_MATRIX_RESULT(pkt, data)
    data.result = pkt:GetChar() -- 0表示失败，1表示成功。
end

-- 通知WIFI密码信息(打开WIFI密码界面)
function MsgParser:MSG_TWZM_SCRIP_DATA(pkt, data)
    data.content = pkt:GetLenString() -- WIFI密码
end

-- 通知传音信息(打开传音符界面)
function MsgParser:MSG_TWZM_CHUANYINFU(pkt, data)
    data.content = pkt:GetLenString() --传音内容
    data.gid = pkt:GetLenString()-- 本任务 gid，用于校验
end

function MsgParser:MSG_GS_REBOOT(pkt, data)
    if pkt:GetDataLen() > 0 then
        data.tip = pkt:GetLenString()
    end
end

function MsgParser:MSG_UPGRADE_INHERIT_PREVIEW(pkt, data)
    data.pos = pkt:GetShort()
    data.para = pkt:GetLenString() --传音内容
    data.flag = pkt:GetChar()           -- 0表示失败，1表示成功。
    data.money = pkt:GetLong()          -- 消耗金钱数量
    data.coin = pkt:GetLong()           -- 消耗元宝数量

    -- 主装备预览数据
    local item = {}
    Builders:BuildItemInfo(pkt, item)
    data.mEquip = item

    -- 副装备预览数据
    local item = {}
    Builders:BuildItemInfo(pkt, item)
    data.oEquip = item
end

function MsgParser:MSG_RECALL_USER_SCORE_DATA(pkt, data)
    data.start_time = pkt:GetLong()          -- 开始时间
    data.end_time = pkt:GetLong()           -- 截止时间
    data.score = pkt:GetLong()           -- 积分
end

-- 通知客户端冻屏
function MsgParser:MSG_FROZEN_SCREEN(pkt, data)
    data.duration = pkt:GetShort()
end

-- 通知客户端黑幕淡入淡出
function MsgParser:MSG_NOTIFY_SCREEN_FADE(pkt, data)
    data.type = pkt:GetChar() -- 类型(1表示淡入，2表示淡出)
    data.duration = pkt:GetLong() -- 播放时间
end

-- 所有比赛的时间节点
function MsgParser:MSG_CSQ_ALL_TIME(pkt, data)
    data.warmupStartTime = pkt:GetLong()    -- 热身赛
    data.warmupEndTime = pkt:GetLong()
    data.signupStartTime = pkt:GetLong()    -- 报名赛
    data.signupEndTime = pkt:GetLong()

    data.zoneNum = pkt:GetChar()            -- 积分赛
    data.zoneList = {}
    for i = 1, data.zoneNum do
        local tmpInfo = {}
        tmpInfo.zone = pkt:GetLenString()
        tmpInfo.num = pkt:GetChar()
        tmpInfo.timeList = {}
        for j = 1, tmpInfo.num do
            local timeInfo = {}
            timeInfo.startTime = pkt:GetLong()
            timeInfo.endTime = pkt:GetLong()
            table.insert(tmpInfo.timeList, timeInfo)
        end

        table.insert(data.zoneList, tmpInfo)
    end

    data.kickoutNum = pkt:GetChar()	    -- 淘汰赛
    data.kickoutList = {}
    for i = 1, data.kickoutNum do
        local timeInfo = {}
        timeInfo.startTime = pkt:GetLong()
        timeInfo.endTime = pkt:GetLong()
        table.insert(data.kickoutList, timeInfo)
    end

    data.finalStartTime = pkt:GetLong() -- 总决赛
    data.endStartTime = pkt:GetLong()
end

-- 积分排行榜数据
function MsgParser:MSG_CSQ_SCORE_RANK(pkt, data)
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.teamId = pkt:GetLenString()
        tmpInfo.winTimes = pkt:GetShort()
        tmpInfo.lostTimes = pkt:GetShort()
        tmpInfo.seriesWinTimes = pkt:GetShort()
        tmpInfo.giveUpTimes = pkt:GetShort()
        tmpInfo.score = pkt:GetShort()
        tmpInfo.name = pkt:GetLenString()
        table.insert(data.list, tmpInfo)
    end
end

-- 积分排行榜上的队伍数据
function MsgParser:MSG_CSQ_SCORE_TEAM_DATA(pkt, data)
    data.teamId = pkt:GetLenString()
    data.count = pkt:GetChar()
    data.teamName = pkt:GetLenString()
    data.teamInfo = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.gid = pkt:GetLenString()
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.dist = pkt:GetLenString()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.isLeader = pkt:GetChar()
        if tmpInfo.name == data.teamName then
            data.dist = tmpInfo.dist
        end

        table.insert(data.teamInfo, tmpInfo)
    end

    table.sort(data.teamInfo, function(l, r)
        if l.isLeader < r.isLeader then return false end
        if l.isLeader > r.isLeader then return true end
    end)
end

-- 淘汰赛所有队伍数据
function MsgParser:MSG_CSQ_KICKOUT_ALL_TEAM_DATA(pkt, data)
    data.teamCount = pkt:GetShort()
    data.teamMap = {}
    for i = 1, data.teamCount do
        local tmpInfo = {}
            tmpInfo.teamId = pkt:GetLenString()
        tmpInfo.name = pkt:GetLenString()
        data.teamMap[tmpInfo.teamId] = tmpInfo
        end

    data.matchCount = pkt:GetChar()
    data.matchMap = {}
    for i = 1, data.matchCount do
        local tmpInfo = {}
        tmpInfo.matchId = pkt:GetLenString()
        tmpInfo.teamNum = pkt:GetShort()
        tmpInfo.teamList = {}
        for j = 1, tmpInfo.teamNum do
            local tmpTeamId = pkt:GetLenString()
            table.insert(tmpInfo.teamList, tmpTeamId)
            if tmpInfo.matchId == "kickout_64" and data.teamMap[tmpTeamId] then
                data.teamMap[tmpTeamId].rank = j
        end
        end

        data.matchMap[tmpInfo.matchId] = tmpInfo
    end
end

-- 自己的全民PK数据
function MsgParser:MSG_CSQ_MY_DATA(pkt, data)
    data.name = pkt:GetLenString()
    data.isSignUp = pkt:GetChar()
    data.zone = pkt:GetLenString()
    data.teamId = pkt:GetLenString()
    data.curResult = pkt:GetLenString()
    data.bonusTime = pkt:GetLong()
    data.winTimes = pkt:GetShort()
    data.lostTimes = pkt:GetShort()
    data.seriesWinTimes = pkt:GetShort()
    data.giveUpTimes = pkt:GetShort()
    data.score = pkt:GetShort()
    data.isCitySignUp = pkt:GetChar()
    data.taotaiStartTime = pkt:GetLong()
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.isLeader = pkt:GetChar()
        tmpInfo.gid = pkt:GetLenString()
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.dist = pkt:GetLenString()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.weaponIcon = pkt:GetLong()
        tmpInfo.suitIcon = pkt:GetLong()
        tmpInfo.suitLightEffect = pkt:GetLong()
        table.insert(data.list, tmpInfo)
    end
end

-- 请求淘汰赛的队伍数据
function MsgParser:MSG_CSQ_KICKOUT_TEAM_DATA(pkt, data)
    self:MSG_CSQ_SCORE_TEAM_DATA(pkt, data)
end

-- 奖励信息
function MsgParser:MSG_CSQ_BONUS_INFO(pkt, data)
    self:MSG_OPEN_QMPK_BONUS_DLG(pkt, data)
end

-- 请求控制数据
function MsgParser:MSG_CSQ_GM_REQUEST_CONTROL_INFO(pkt, data)
    data.count = pkt:GetChar()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.matchId = pkt:GetChar()
        tmpInfo.status = pkt:GetChar()
        tmpInfo.combatNum = pkt:GetChar()
        tmpInfo.winnerLeaderName = pkt:GetLenString()
        tmpInfo.lastCobEndTime = pkt:GetLong()
        tmpInfo.oneTeamId = pkt:GetLenString()
        tmpInfo.oneTeamName = pkt:GetLenString()
        tmpInfo.otherTeamId = pkt:GetLenString()
        tmpInfo.otherTeamName = pkt:GetLenString()
        data.list[i] = tmpInfo
    end
end

-- 比赛时间信息
function MsgParser:MSG_CSQ_MATCH_TIME_INFO(pkt, data)
    data.status = pkt:GetLenString() -- 状态，包含:"score"、"kickout"、"final"
    data.matchId = pkt:GetLenString() -- kickout_64、kickout_32、kickout_16、kickout_8、kickout_4
    data.endSignTime = pkt:GetLong()  -- 报名截止时间
    data.enterTime = pkt:GetLong()   -- 入场时间
    data.startTime = pkt:GetLong()   -- 开始时间
    data.pairTime = pkt:GetLong()    -- 第一次开始战斗时间
    data.endTime = pkt:GetLong()     -- 结束时间
    data.restTime = pkt:GetLong()    -- 战斗结束休息时间
    data.matchFlag = pkt:GetChar()   -- 比赛结果0 没结果，1 晋级，2 淘汰
    data.myName = pkt:GetLenString() -- 己方名字
    data.otherName = pkt:GetLenString() -- 另外一方名字
    data.notInFight = pkt:GetChar()   -- 是否进入战斗
    data.isCompetEnd = pkt:GetChar()  -- 今日比赛是否结束 积分赛使用
    data.scoreMatchRound = pkt:GetChar()  -- 当前积分比赛次数
    data.cobNum = pkt:GetChar()      -- 总的战斗次数
    data.cobFlag = pkt:GetLenString() -- 例: "010"，0 表示胜败，1 表示胜利;积分赛期间 "12,12,12,12"
    data.leftCobNum = pkt:GetShort()  -- 当前剩余战斗数量
    data.cobId = pkt:GetChar()       -- 总决赛时：1、2 表示半决赛；3 表示季殿军之战；4 表示冠亚军之战。
    data.finalResult = pkt:GetChar() -- 总决赛结果：1、2、3、4，分别代表冠军，亚军，季军，殿军
    data.hasConfirmCob = pkt:GetChar() -- 是否存在未确认的结果
    data.memberCount = pkt:GetChar()
    data.teamlist = {}
    for i = 1, data.memberCount do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.dist = pkt:GetLenString()
        tmpInfo.isLeader = pkt:GetChar()
        table.insert(data.teamlist, tmpInfo)
    end
end

-- 通知客户端共鸣属性值
function MsgParser:MSG_PREVIEW_RESONANCE_ATTRIB(pkt, data)
    data.type = pkt:GetChar()
    data.level = pkt:GetShort()
    data.attrib = pkt:GetLenString()
    data.rebuildLevel = pkt:GetChar()
    data.gongmingAttrib = pkt:GetShort()
end

function MsgParser:MSG_TEACHER_2018_CHANNEL(pkt, data)
    data.channel = pkt:GetShort()
    data.msg = pkt:GetLenString()
end

-- 精研技能信息
function MsgParser:MSG_LEARN_UPPER_STD_SKILL_COST(pkt, data)
    data.skill_no = pkt:GetShort() --
    data.level = pkt:GetShort() --
    data.new_level = pkt:GetShort() --
    data.need_pot = pkt:GetLong()
    data.need_cash = pkt:GetLong()
end

-- 2018 国庆节 - 四方棋局
function MsgParser:MSG_NATIONAL_2018_SFQJ(pkt, data)
    data.start_time = pkt:GetLong()        -- 游戏开始时间戳，还没有开始为 0
    data.end_time = pkt:GetLong()        -- 游戏开始时间戳，还没有开始为 0
    data.move_end_time = pkt:GetLong()
    data.move_corps = pkt:GetChar()        -- 当前移动棋子的阵营。
    data.win_corps = pkt:GetChar()         -- 当前胜利的阵营
    data.is_pvp = pkt:GetChar()         -- 是否pvp
    data.corps_count = pkt:GetChar()        -- 阵营数
    data.corps_info = {}
    for i = 1, data.corps_count do
        data.corps_info[i] = {}
        data.corps_info[i].gid = pkt:GetLenString()
        data.corps_info[i].name = pkt:GetLenString()
        data.corps_info[i].icon = pkt:GetLong()
        data.corps_info[i].moves = pkt:GetLong()        -- 移动步数
        data.corps_info[i].is_leave = pkt:GetChar()        -- 移动步数
        data.corps_info[i].corps = i        -- 移动步数
    end
    data.chessData = {}
    data.chess_size_x = pkt:GetChar()
    for i = 1, data.chess_size_x do
        data.chessData[i] = {}
        data.chess_size_y = pkt:GetChar()
        for j = 1, data.chess_size_y do
            data.chessData[i][j] = pkt:GetChar()
        end
    end

    data.drive_corps = pkt:GetChar()
    data.is_auto = pkt:GetChar()
    data.drive_x = pkt:GetChar()
    data.drive_y = pkt:GetChar()
    data.drive_dir = pkt:GetChar()
    data.eat_count = pkt:GetChar()
    data.eatData = {}
    for i = 1, data.eat_count do
        data.eatData[i] = {}
        data.eatData[i].eat_x = pkt:GetChar()
        data.eatData[i].eat_y = pkt:GetChar()
        data.eatData[i].eat_corps = data.drive_corps == 1 and 2 or 1
    end
end

-- 通知客户端九天真君的信息
function MsgParser:MSG_JIUTIAN_ZHENJUN(pkt, data)
    data.curCheckpoint = pkt:GetChar()  -- 当前可挑战第几关，从 0 开始计算，大于等于 openMax 则说明通关了
    data.openMax = pkt:GetChar()       -- 开放光卡最大值，从1开始
    data.is_open = pkt:GetChar()       -- 是否开启界面
end

-- 通知开始游戏
function MsgParser:MSG_AUTUMN_2018_GAME_START(pkt, data)
    data.step = pkt:GetChar() --挑战关卡
    data.iid = pkt:GetLenString() -- 关卡密钥
    data.end_time = pkt:GetLong() -- 游戏结束时间
end

-- 通关提示
function MsgParser:MSG_AUTUMN_2018_GAME_FINISH(pkt, data)
    data.exp = pkt:GetLong() --未削减前的人物经验
    data.tao = pkt:GetLong()-- 未削减前的人物道行
end

-- 大胃王 - 准备阶段
function MsgParser:MSG_AUTUMN_2018_DWW_PREPARE(pkt, data)
    data.successScore = pkt:GetShort()
    data.maxScore = pkt:GetShort()
end

-- 大胃王 - 开始比赛
function MsgParser:MSG_AUTUMN_2018_DWW_START(pkt, data)
    data.seed = pkt:GetLong()
    data.playerOneGid = pkt:GetLenString()
    data.playerOneName = pkt:GetLenString()
    data.playerOneIndex = pkt:GetChar()
    data.playerTwoGid = pkt:GetLenString()
    data.playerTwoName = pkt:GetLenString()
    data.playerTwoIndex = pkt:GetChar()
end

-- 大胃王 - 比赛进度
function MsgParser:MSG_AUTUMN_2018_DWW_PROGRESS(pkt, data)
    data.scoreOne = pkt:GetShort()
    data.scoreTwo = pkt:GetShort()
end

-- 大胃王 - 比赛结果
function MsgParser:MSG_AUTUMN_2018_DWW_RESULT(pkt, data)
    data.result = pkt:GetChar()
    data.resultOne = pkt:GetShort()
    data.resultTwo = pkt:GetShort()
end

-- 赛事管理员数据
function MsgParser:MSG_MATCH_ADMIN_DATA(pkt, data)
    data.count = pkt:GetShort()
    data.warData = {}
    for i = 1, data.count do
        local warKey = pkt:GetLenString()
        local endTime = pkt:GetLong()
        data.warData[warKey] = endTime
    end
end


-- 通知客户端打开“饮酒界面”
function MsgParser:MSG_CHONGYANG_2018_GAME_START(pkt, data)
    data.iid = pkt:GetLenString()
    data.npc_name = pkt:GetLenString()
    data.npc_icon = pkt:GetShort()
    data.end_time = pkt:GetLong()
end

-- 通知客户端打开“酒册界面”
function MsgParser:MSG_CHONGYANG_2018_GAME_BOOK(pkt, data)
    data.count = pkt:GetChar()       -- 数量
    for i = 1, data.count do
        local name = pkt:GetLenString() -- NPC名称
        local flag = pkt:GetChar()  -- 通关标记， 0 = 未通关， 1 = 已通关
        data[name] = flag
    end
end

-- 通知对象淡化消失
function MsgParser:MSG_OBJECT_DISAPPEAR(pkt, data)
    data.id = pkt:GetLong()       -- 对象 id
    data.time = pkt:GetLong()     -- 消失时间（毫秒）
end

-- 通知对象淡化消失
function MsgParser:MSG_ZZQN_CARD_INFO(pkt, data)
    data.pos = pkt:GetShort()
    data.id = pkt:GetLong()
    data.npcName = pkt:GetLenString() -- NPC名称
    data.icon = pkt:GetLong()
    data.gender = pkt:GetChar()
    data.address = pkt:GetLenString() -- 地址
    data.hobby = pkt:GetLenString() -- 爱好
    data.myTrait = pkt:GetLenString() -- 本人特征
    data.loverTrait = pkt:GetLenString() -- 心仪人特征
end

-- 2018万圣节开始学习
function MsgParser:MSG_HALLOWMAX_2018_LYZM_STUDY(pkt, data)
    data.status = pkt:GetLenString()
    data.game_id = pkt:GetLenString()     --  game_id 用于加密结果
end

-- 2018万圣节游戏进入
function MsgParser:MSG_HALLOWMAX_2018_LYZM_GAME_ENTER(pkt, data)
    data.game_index = pkt:GetChar() + 1      -- 当前关卡
end

-- 2018万圣节开始游戏
function MsgParser:MSG_HALLOWMAX_2018_LYZM_GAME(pkt, data)
    data.status = pkt:GetLenString()
    data.game_id = pkt:GetLenString()     -- game_id 用于加密结果
    data.game_index = pkt:GetChar() + 1      -- 当前关卡
end

-- 通知客户端校验结果
function MsgParser:MSG_CHECK_SERVER(pkt, data)
    data.buf = pkt:GetLenBuffer2()
    data.cookie = pkt:GetLong()
end

-- 通知客户端情缘观点界面信息
function MsgParser:MSG_QYGD_INFO_2018(pkt, data)
    data.end_time = pkt:GetLong()
    data.cur_num = pkt:GetChar()
    data.total_num = pkt:GetChar()
    data.wanz_heart = pkt:GetChar()
    data.canq_heart = pkt:GetChar()
    data.title = pkt:GetLenString()
    data.answers = {}
    for i = 1, 3 do
        data.answers[i] = pkt:GetLenString()
    end
    data.my_op = pkt:GetChar()
    data.other_name = pkt:GetLenString()
    data.other_icon = pkt:GetLong()
    data.other_op = pkt:GetChar()
end

function MsgParser:MSG_JIUTIAN_ZHENJUN_KILL_FIRST(pkt, data)
    data.monster_count = pkt:GetChar() -- 超级大BOSS数量
    for i = 1, data.monster_count do
        local bossName = pkt:GetLenString()                         -- boss 名字
        data[bossName]= {}
        data[bossName].boss_name = bossName
        data[bossName].kill_time = pkt:GetLong()                 -- 首杀时间
        data[bossName].player_count = pkt:GetChar()              -- 首杀队伍人数
        data[bossName].plays = {}
        for j = 1, data[bossName].player_count do
            data[bossName].plays[j] = {}                         -- 首杀队伍
            data[bossName].plays[j].gid = pkt:GetLenString()     -- 首杀队伍玩家 gid
            data[bossName].plays[j].name = pkt:GetLenString()    -- 首杀队伍玩家 名字
            data[bossName].plays[j].level = pkt:GetShort()       -- 首杀队伍玩家 等级
            data[bossName].plays[j].icon = pkt:GetLong()         -- 首杀队伍玩家 icon
        end
    end
end

function MsgParser:MSG_STRENGTHEN_JEWELRY_SUCC(pkt, data)
    data.jewelry_id = pkt:GetLong()
    data.isChange = pkt:GetChar()
end

function MsgParser:MSG_FASION_EFFECT_LIST(pkt, data)
    local count = pkt:GetShort()
    data.malls = {}
    for i = 1, count do
        local item = {}
        item.name = pkt:GetLenString()
        item.goods_price = pkt:GetLong()
        table.insert(data.malls, item)
    end

    local count = pkt:GetShort()
    data.effect_own = {}
    for i = 1, count do
        local name = pkt:GetLenString()
        table.insert(data.effect_own, name)
    end
end

-- 通知跟随宠道具列表
function MsgParser:MSG_FOLLOW_PET_VIEW(pkt, data)
    local count = pkt:GetChar()
    data.malls = {}
    for i = 1, count do
        local item = {}
        item.name = pkt:GetLenString()
        item.goods_price = pkt:GetLong()
        table.insert(data.malls, item)
    end
end

-- 通知客户端题目     2019年寒假活动之赏雪吟诗
function MsgParser:MSG_SXYS_QUESTION_INFO_2019(pkt, data)
    data.end_ti = pkt:GetLong()
    data.question = pkt:GetLenString()
    data.answer1 = pkt:GetLenString()
    data.answer2 = pkt:GetLenString()
    data.answer3 = pkt:GetLenString()
    data.answer4 = pkt:GetLenString()
end

-- 通知客户端隐藏界面(显示吟诗效果) 2019年寒假活动之赏雪吟诗
function MsgParser:MSG_SXYS_HIDE_DLG_2019(pkt, data)
    data.flag = pkt:GetLong()
end

-- 通知客户端进入游戏(过图后发送、更新结果时发送)
function MsgParser:MSG_BWSWZ_START_GAME_2019(pkt, data)
    data.today_max_point = pkt:GetLong()
    data.succ_point = pkt:GetLong()
    data.chengwei_point = pkt:GetLong()
    data.cookie = pkt:GetLenString()
end

-- 冰雪21点数据
function MsgParser:MSG_WINTER_2019_BX21D_DATA(pkt, data)
    data.status = pkt:GetLenString()						-- 游戏状态
	data.remain_ti = pkt:GetLong()							-- 剩余时间，在 "running" 阶段使用

	data.cur_index = pkt:GetChar()							-- 当前操作玩家的编号
	data.player_count = pkt:GetChar()						-- 玩家数量
	data.players_info = {}
	for i = 1, data.player_count do
		data.players_info[i] = {}
		data.players_info[i].index = pkt:GetChar()			-- 玩家编号
		data.players_info[i].icon = pkt:GetLong()			-- 玩家icon
		data.players_info[i].name = pkt:GetLenString()		-- 玩家名字
		data.players_info[i].prepared = pkt:GetChar()		-- 是否已经准备就绪，准备阶段使用
		data.players_info[i].is_online = pkt:GetChar()		-- 1 表示在线，0 表示不在线

		data.players_info[i].gid = pkt:GetLenString()		-- 玩家 GID
		data.players_info[i].card_num = pkt:GetShort()		-- 当前手上牌的数量
		data.players_info[i].card_id = {}
		for j = 1, data.players_info[i].card_num do
			data.players_info[i].card_id[j] = pkt:GetShort()	-- 牌 id（0 表示牌不可见，1 - 4 特殊牌，5 - 36分别按照顺序对应 4个2、4个3、4个4...4个9，37 - 52 对应 10 的牌。）
		end
		data.players_info[i].final_total = pkt:GetShort()		-- 最终点数，0 表示当前还没有结果，大于0 则表示已经有结果了
	end

	data.boss_card_num = pkt:GetShort()						-- 庄家当前手上牌的数量
	data.boss_card_id = {}
	for i = 1, data.boss_card_num do
		data.boss_card_id[i] = pkt:GetShort()				--
	end
	data.boss_final_total = pkt:GetShort()
end

-- 当前轮次
function MsgParser:MSG_WINTER_2019_BX21D_CUR_ROUND(pkt, data)
	data.cur_index = pkt:GetChar()
end

-- 奖励数据
function MsgParser:MSG_WINTER_2019_BX21D_BONUS(pkt, data)
	data.flag = pkt:GetChar() 	-- 0 失败， 1 赢， 2平局，3逃跑
	data.bonus_num = pkt:GetChar()

	for i = 1, data.bonus_num do
		local type = pkt:GetLenString()
		data[type] = pkt:GetLenString()
	end
end

function MsgParser:MSG_NEW_PARTY_WAR(pkt, data)
	data.ti = pkt:GetLong()
end

function MsgParser:MSG_CXK_START_GAME_2019(pkt, data)
	data.flag = pkt:GetChar()           -- 0表示打开界面，1表示开始游戏
    data.cookie = pkt:GetLenString()
end

function MsgParser:MSG_CXK_BONUS_INFO_2019(pkt, data)
    data.flag = pkt:GetChar()   -- 0 没有奖励  1 有奖励
	data.score = pkt:GetLong()
    data.highScore = pkt:GetLong()
    data.exp = pkt:GetLong()
    data.tao = pkt:GetLong()
    data.item = pkt:GetLenString()
end

-- 通知客户端战斗操作结果
function MsgParser:MSG_COMBAT_ACTION_RESULT(pkt, data)
    data.attacker_id = pkt:GetLong()
    data.victim_id = pkt:GetLong()
    data.type = pkt:GetChar()
    data.result = pkt:GetChar()
    data.itemName = pkt:GetLenString()
end

-- 通知客户端阵营中成员选择了指令
function MsgParser:MSG_SELECT_COMMAND(pkt, data)
    data.attacker_id = pkt:GetLong()
    data.victim_id = pkt:GetLong()
    data.action = pkt:GetChar()
    data.no = pkt:GetLong()
end

function MsgParser:MSG_SET_ACTION_STATUS_COMPLETE(pkt, data)
    data.status = pkt:GetLong() -- 当前完成的状态
end

function MsgParser:MSG_L_CHARGE_DATA(pkt, data)
    self:MSG_CHARGE_INFO(pkt, data)
end

function MsgParser:MSG_L_CHARGE_LIST(pkt, data)
	data.server_time = pkt:GetLong()
    data.result = pkt:GetLong() -- 同 GS 返回的首充类型
end

-- 会员队列数据
function MsgParser:MSG_L_LINE_DATA(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.line_name = pkt:GetLenString()
        info.expect_time = pkt:GetLong()
        table.insert(data, info)
    end
end

function MsgParser:MSG_AAA_CHARGE_DATA_LIST(pkt, data)
    data.end_time = pkt:GetLong()
    data.count = pkt:GetChar()
    for i = 1, data.count do
        local info = {}
        info.type = pkt:GetLenString()
        info.num = pkt:GetLong()
        data[info.type] = info
    end
end

-- 好友推荐列表
function MsgParser:MSG_FRIEND_RECOMMEND_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.icon = pkt:GetShort()
        info.name = pkt:GetLenString()
        info.party_name = pkt:GetLenString()
        info.is_vip = pkt:GetChar()
        info.level = pkt:GetShort()
        info.gid = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 通知玩家队友自动战斗开关
function MsgParser:MSG_FRIEND_AUTO_FIGHT_CONFIG(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}
        data[i].id = pkt:GetLong()
        data[i].auto_fight = pkt:GetChar()
    end
end

function MsgParser:MSG_HOUSE_PET_STORE_DATA(pkt, data)
    data.furniture_pos = pkt:GetLong()
    data.cur_size = pkt:GetChar()
    data.max_size = pkt:GetChar()
end

function MsgParser:MSG_HOUSE_SHOW_PET_STORE_LIST(pkt, data)
    data.owner_gid = pkt:GetLenString()
    data.couple_gid = pkt:GetLenString()
    local count = pkt:GetShort()
    data.pets = {}
    for i = 1, count do
        local pet = {}
        pet.furniture_pos = pkt:GetLong()
        pet.name = pkt:GetLenString()
        pet.icon = pkt:GetShort()
        table.insert(data.pets, pet)
    end
end

function MsgParser:MSG_EXCHANGE_EPIC_PET_SHOP(pkt, data)
    data.pet_names = {}
    local count = pkt:GetShort()
    for i = 1, count do
        table.insert(data.pet_names, pkt:GetLenString())
    end
end


function MsgParser:MSG_EXCHANGE_EPIC_PET_SUBMIT_DLG(pkt, data)
    data.target_name = pkt:GetLenString()
end

function MsgParser:MSG_C_UPDATE_DATA(pkt, data)
    self:MSG_C_UPDATE(pkt, data)
end

function MsgParser:MSG_LC_UPDATE_DATA(pkt, data)
    self:MSG_C_UPDATE_DATA(pkt, data)
end

-- 赠送记录
function MsgParser:MSG_GIVING_RECORD(pkt, data)
    data.count = pkt:GetShort() -- 条数
    for i = 1, data.count do
        local info = {}
        info.id = pkt:GetLenString()
        info.time = pkt:GetLong()
        info.giving_gid = pkt:GetLenString()
        info.accept_gid = pkt:GetLenString()
        info.giving_name = pkt:GetLenString()
        info.accept_name = pkt:GetLenString()
        info.amount = pkt:GetShort()
        info.unit = pkt:GetLenString()
        info.item_name = pkt:GetLenString()
        table.insert(data, info)
    end
end

-- 打开分享好友界面
function MsgParser:MSG_OPEN_SHARE_FRIEND_DLG(pkt, data)
    data.act_name = pkt:GetLenString()
end

-- 通知开始界面信息
function MsgParser:MSG_FIXED_TEAM_START_DATA(pkt, data)
end

-- 通知客户端请求数据
function MsgParser:MSG_REQUEST_LIST(pkt, data)
    data.ask_type = pkt:GetLenString()
    data.count = pkt:GetShort() -- 条数
    for i = 1, data.count do
        local info = {}
        info.peer_name = pkt:GetLenString()

        local count = pkt:GetShort()
        info.count = count
        for i = 1, count do
            local map = {}
            map.org_icon = pkt:GetLong()
            Builders:BuildFields(pkt, map)
            map.teamMembersCount = pkt:GetChar()
            map.comeback_flag = pkt:GetChar()   -- 回归标记
            if data.ask_type == "csc_around_player" or data.ask_type == "csc_around_team" then
                -- 跨服战场要显示的段位、战斗模式
                map.stageStr = pkt:GetLenString()
                map.combat_mode = pkt:GetLenString()
            end

            table.insert(info, map)
        end

        table.insert(data, info)
    end
end

function MsgParser:MSG_PET_ENCHANT_END(pkt, data)
end

-- 打开提交证物界面
function MsgParser:MSG_MXZA_SUBMIT_EXHIBIT_DLG(pkt, data)
    data.state = pkt:GetLenString()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.real_desc = pkt:GetLenString()
        data[i] = tmpInfo
    end
end

-- 迷仙镇案证物列表
function MsgParser:MSG_MXZA_EXHIBIT_ITEM_LIST(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.real_desc = pkt:GetLenString()
        data[i] = tmpInfo
    end
end

-- 通知称谓界面信息
function MsgParser:MSG_FIXED_TEAM_APPELLATION(pkt, data)
    data.type = pkt:GetChar()
    data.team_name = pkt:GetLenString()
end


-- 通知确认界面信息
function MsgParser:MSG_FIXED_TEAM_CHECK_DATA(pkt, data)
    data.action = pkt:GetChar()
    data.team_name = pkt:GetLenString()
    data.members = {}
    local count = pkt:GetChar()
    for i = 1, count do
        local m = {}
        m.gid = pkt:GetLenString()
        m.name = pkt:GetLenString()
        m.icon = pkt:GetLong()
        m.has_confirm = pkt:GetChar()
        table.insert(data.members, m)
    end
end

-- 通知完成界面信息
function MsgParser:MSG_FIXED_TEAM_FINISH_DATA(pkt, data)
    data.team_name = pkt:GetLenString()
    data.members = {}
    local count = pkt:GetChar()
    for i = 1, count do
        local m = {}
        m.gid = pkt:GetLenString()
        m.name = pkt:GetLenString()
        m.icon = pkt:GetLong()
        table.insert(data.members, m)
    end
end

-- 通知固定队信息
function MsgParser:MSG_FIXED_TEAM_DATA(pkt, data)
    data.name = pkt:GetLenString()
    data.level = pkt:GetChar()
    data.intimacy = pkt:GetLong()
    data.max_intimacy = pkt:GetLong()
    data.members = {}
    local count = pkt:GetShort()
    for i = 1, count do
        local m = {}
        m.gid = pkt:GetLenString()
        m.name = pkt:GetLenString()
        m.level = pkt:GetShort()
        m.icon = pkt:GetLong()
        m.tao = pkt:GetLong()
        m.last_logout_time = pkt:GetLong() -- 最近的一次离线时间
        m.join_time = pkt:GetLong()
        table.insert(data.members, m)
    end
end

-- 通知补充储备界面
function MsgParser:MSG_FIXED_TEAM_OPEN_SUPPLY_DLG(pkt, data)
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.life = pkt:GetLong()
    data.mana = pkt:GetLong()
    data.loyalty = pkt:GetLong()
    data.life_item_name = pkt:GetLenString()
    data.life_item_num = pkt:GetChar()
    data.mana_item_name = pkt:GetLenString()
    data.mana_item_num = pkt:GetChar()
    data.loyalty_item_name = pkt:GetLenString()
    data.loyalty_item_num = pkt:GetChar()
end

-- 单人寻队，玩家自己的招募信息
function MsgParser:MSG_FIXED_TEAM_RECRUIT_MY_SINGLE(pkt, data)
    data.has_publish = pkt:GetChar() -- 是否有发布招募信息
    data.pt_type = pkt:GetChar()     -- 加点偏向
    data.msg = pkt:GetLenString2()   -- 完整留言内容
end

-- 个人招募信息列表
function MsgParser:MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST(pkt, data)
    data.request_iid = pkt:GetLenString()
    data.request_time = pkt:GetLong()
    data.last_iid = pkt:GetLenString()
    data.last_time = pkt:GetLong()
    data.polar = pkt:GetChar()
    data.pt_type = pkt:GetChar()

    -- self:MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST_EX(pkt, data)

    data.preData = {}
    data.preData.count = pkt:GetShort()
    for i = 1, data.preData.count do
        local info = {}
        info.iid = pkt:GetLenString()
        table.insert(data.preData, info)
    end
end

function MsgParser:MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST_EX(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()
        info.create_time = pkt:GetLong()
        info.name = pkt:GetLenString()
        info.online = pkt:GetChar()
        info.level = pkt:GetShort()
        info.tao = pkt:GetLong()
        info.icon = pkt:GetLong()
        info.polar = pkt:GetSignedChar()
        info.pt_type = pkt:GetSignedChar()
        info.short_msg = pkt:GetLenString()
        table.insert(data, info)

        if info.pt_type == -1 then info.pt_type = 0 end
        if info.polar == -1 then info.polar = 0 end
    end
end

-- 个人招募详细信息
function MsgParser:MSG_FIXED_TEAM_RECRUIT_SINGLE_DETAIL(pkt, data)
    data.gid = pkt:GetLenString()
    data.create_time = pkt:GetLong()
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
    data.tao = pkt:GetLong()
    data.icon = pkt:GetLong()
    data.polar = pkt:GetSignedChar()
    data.pt_type = pkt:GetSignedChar()
    data.msg = pkt:GetLenString2()

    if data.pt_type == -1 then data.pt_type = 0 end
    if data.polar == -1 then data.polar = 0 end
end

-- 组队招募详细信息
function MsgParser:MSG_FIXED_TEAM_RECRUIT_TEAM_DETAIL(pkt, data)
    data.iid = pkt:GetLenString()
    data.team_name = pkt:GetLenString()
    data.team_level = pkt:GetShort()
    data.msg = pkt:GetLenString2()

    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetShort()
        info.tao = pkt:GetSignedLong()
        info.polar = pkt:GetSignedChar()
        info.pt_type = pkt:GetSignedChar()
        if info.pt_type == -1 then info.pt_type = 0 end
        if info.polar == -1 then info.polar = 0 end
        if info.tao == -1 then info.tao = 0 end
        table.insert(data, info)
    end

    table.sort(data, function(l, r)
        if l.level > r.level then return true end
        if l.level < r.level then return false end

        if l.tao > r.tao then return true end
        if l.tao < r.tao then return false end

        return l.name < r.name
    end)

    local count = pkt:GetShort()
    for i = 1, count do
        local info = {}
        info.tao = pkt:GetLong()
        info.polar = pkt:GetChar()
        info.pt_type = pkt:GetChar()
        table.insert(data, i, info)
    end

    local cou = #data
    for i = 1, 5 - cou do
        table.insert(data, 1, {})
    end
end

function MsgParser:MSG_FIXED_TEAM_RECRUIT_TEAM_LIST(pkt, data)
    data.request_iid = pkt:GetLenString()
    data.request_time = pkt:GetLong()
    data.last_iid = pkt:GetLenString()
    data.last_time = pkt:GetLong()
    data.polar = pkt:GetSignedChar()
    data.pt_type = pkt:GetSignedChar()

   --  self:MSG_FIXED_TEAM_RECRUIT_TEAM_LIST_EX(pkt, data)

    data.preData = {}
    data.preData.count = pkt:GetShort()
    for i = 1, data.preData.count do
        local info = {}
        info.iid = pkt:GetLenString()
        table.insert(data.preData, info)
    end
end

function MsgParser:MSG_FIXED_TEAM_RECRUIT_TEAM_LIST_EX(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()
        info.create_time = pkt:GetLong()
        info.team_name = pkt:GetLenString()
        info.team_level = pkt:GetShort()
        info.team_num = pkt:GetChar()
        info.ave_level = pkt:GetShort()
        info.ave_tao = pkt:GetLong()
        info.req_str = pkt:GetLenString()
        info.short_msg = pkt:GetLenString()
        table.insert(data, info)
    end
end

function MsgParser:MSG_FIXED_TEAM_RECRUIT_MY_TEAM(pkt, data)
    data.has_publish = pkt:GetChar()
    data.msg = pkt:GetLenString2()
    data.iid = pkt:GetLenString()
    data.create_time = pkt:GetLong()
    data.team_name = pkt:GetLenString()
    data.team_level = pkt:GetShort()
    data.team_num = pkt:GetChar()
    data.ave_level = pkt:GetShort()
    data.ave_tao = pkt:GetLong()
    data.req_str = pkt:GetLenString()
    data.short_msg = pkt:GetLenString()

    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.gid = pkt:GetLenString()
        info.name = pkt:GetLenString()
        info.icon = pkt:GetLong()
        info.level = pkt:GetShort()
        info.tao = pkt:GetSignedLong()
        info.polar = pkt:GetSignedChar()
        info.pt_type = pkt:GetSignedChar()
        if info.pt_type == -1 then info.pt_type = 0 end
        if info.polar == -1 then info.polar = 0 end
        if info.tao == -1 then info.tao = 0 end
        table.insert(data, info)
    end

    table.sort(data, function(l, r)
        if l.level > r.level then return true end
        if l.level < r.level then return false end

        if l.tao > r.tao then return true end
        if l.tao < r.tao then return false end

        return l.name < r.name
    end)

    local count = pkt:GetShort()
    for i = 1, count do
        local info = {}
        info.tao = pkt:GetSignedLong()
        info.polar = pkt:GetSignedChar()
        info.pt_type = pkt:GetSignedChar()

        if info.pt_type == -1 then info.pt_type = 0 end
        if info.polar == -1 then info.polar = 0 end
        if info.tao == -1 then info.tao = 0 end
        table.insert(data, i, info)
    end
end

function MsgParser:MSG_FIXED_TEAM_RECRUIT_TALK(pkt, data)
    data.gid = pkt:GetLenString()
end

function MsgParser:MSG_FIXED_TEAM_CHECK(pkt, data)
    data.has_fixed_team = pkt:GetChar()
end

function MsgParser:MSG_SHOW_RECONNECT_PARA(pkt, data)
    data.dist_name = pkt:GetLenString()
    data.end_time = pkt:GetLong()
    data.msg = pkt:GetLenString()
end

function MsgParser:MSG_TTT_NEW_XING(pkt, data)
    data.result = pkt:GetShort()
    data.xing_name = pkt:GetLenString()
end

-- 通知寻缘列表
function MsgParser:MSG_MATCH_MAKING_QUERY_LIST(pkt, data)
    data.type = pkt:GetChar()
    local count = pkt:GetShort()
    data.list = {}
    for i = 1, count do
        local item = {}
        item.gid = pkt:GetLenString()
        item.name = pkt:GetLenString()
        item.level = pkt:GetShort()
        item.gender = pkt:GetChar()
        item.polar = pkt:GetChar()
        item.portrait = pkt:GetLenString()
        item.remark = pkt:GetLenString2()
        item.match = pkt:GetChar()
        table.insert(data.list, item)
    end
end

-- 通知寻缘详细信息
function MsgParser:MSG_MATCH_MAKING_DETAIL(pkt, data)
    data.gid = pkt:GetLenString()
    data.name = pkt:GetLenString()
    data.level = pkt:GetShort()
    data.tao = pkt:GetLong()
    data.tao_ex = pkt:GetLong()
    data.gender = pkt:GetChar()
    data.real_gender = pkt:GetChar()
    data.polar = pkt:GetChar()
    data.portrait = pkt:GetLenString()
    data.remark = pkt:GetLenString2()
    data.voice_addr = pkt:GetLenString()
    data.voice_time = pkt:GetChar()
    data.match = pkt:GetChar()
    data.is_collect = pkt:GetChar()
end

-- 通知寻缘个人设置信息
function MsgParser:MSG_MATCH_MAKING_SETTING(pkt, data)
    data.portrait = pkt:GetLenString()
    data.gender = pkt:GetChar()
    data.remark = pkt:GetLenString2()
    data.voice_addr = pkt:GetLenString()
    data.voice_time = pkt:GetChar()
    data.receive_msg = pkt:GetChar()
    data.publish = pkt:GetChar()
end

-- 通知修改收藏的结果
function MsgParser:MSG_MATCH_MAKING_FAVORITE_RET(pkt, data)
    data.gid = pkt:GetLenString()
    data.result = pkt:GetChar()
end

function MsgParser:MSG_GOLD_STALL_AUCTION_BID_GIDS(pkt, data)
    data.count = pkt:GetChar() -- 条数
    data.gids = {}
    for i = 1, data.count do
        local goods_gid = pkt:GetLenString()         -- 商品 gid
        local time = pkt:GetLong()                   -- 竞拍时间戳
        data.gids[goods_gid] = time
    end
end

function MsgParser:MSG_GOLD_STALL_MY_BID_GOODS(pkt, data)
    data.count = pkt:GetShort() -- 条数
    data.itemList = {}
    for i = 1, data.count do
        local item = {}
        item.name =  pkt:GetLenString()
        item.is_my_goods = pkt:GetChar()
        item.id = pkt:GetLenString()
        item.price = pkt:GetLong()
        item.status = pkt:GetShort()
        item.startTime = pkt:GetLong()
        item.endTime = pkt:GetLong()
        item.level = pkt:GetShort()
        item.unidentified = pkt:GetChar()
        item.req_level = pkt:GetShort()
        item.extra = pkt:GetLenString()         -- json 格式的复用字段中增加 deposit_state; 支付定金状态，0 - 未支付，1 - 已支付，2 - 不能支付，3 - 表示已经退还定金，4 - 表示已经没收定金
        item.item_polar = pkt:GetChar()
        item.buyout_price = pkt:GetLong()
        item.sell_type = pkt:GetChar()
        item.appointee_name = pkt:GetLenString()

   --     item.appointee_account = pkt:GetLenString()
        table.insert(data.itemList, item)
    end
end

-- 播放进入地图的特殊光效
function MsgParser:MSG_PLAY_ENTER_ROOM_EFFECT(pkt, data)
    data.key = pkt:GetLenString()
end

-- 相约元霄活动中，NPC播放爱心光效
function MsgParser:MSG_YUANXJ_2019_PREPARE_DATA(pkt, data)
    data.target_npc = pkt:GetLenString()
end

function MsgParser:MSG_SPRING_2019_XCXB_DATA(pkt, data)
    data.today_bonus_num = pkt:GetChar() -- 今日奖励次数
    data.layer_count = pkt:GetShort()    -- 当前爆破的层数
    data.layer_size = pkt:GetChar()      -- 层数，正常为 6
    for i = 1, data.layer_size do
        data[i] = {}
        data[i].stone_size = pkt:GetChar()  -- 每层多少个石头
        for j = 1, data[i].stone_size do
            local info = {}
            info.stone_type = pkt:GetShort()    -- 岩石状态
            info.stone_dura = pkt:GetShort()    -- 耐久，普通石头为 1，黄金石头为 2，特殊石头为 1
            info.stone_visible = pkt:GetShort() -- 1 表示可见，0表示不可见
            info.bonus_name = pkt:GetLenString() -- 奖励名字
            info.isGot = pkt:GetChar()        -- 是否已经领取，1 已领取，0 未领取
            data[i][j] = info
        end
    end

    data.has_play_item_guide = pkt:GetChar()
end

-- 2019春节奖励数据
function MsgParser:MSG_SPRING_2019_XCXB_BONUS_DATA(pkt, data)
    data.count = pkt:GetShort()    -- 奖励条数
    for i = 1, data.count do
        local info = {}
        info.item_name = pkt:GetLenString()
        info.num = pkt:GetShort()
        table.insert(data, info)
    end
end

-- 2019春节购买界面数据
function MsgParser:MSG_SPRING_2019_XCXB_BUY_DATA(pkt, data)
    for i = 1, 3 do
        local info = {}
        info.left_num = pkt:GetShort()
        table.insert(data, info)
    end
end

-- 2019新春寻宝领取奖励
function MsgParser:MSG_SPRING_2019_XCXB_GET_BONUS(pkt, data)
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.item_name = pkt:GetLenString()
end

function MsgParser:MSG_COUNTDOWN(pkt, data)
    data.end_time = pkt:GetLong()
end

function MsgParser:MSG_VALENTINE_2019_EFFECT_DATA(pkt, data)
    data.count = pkt:GetShort()
    data.effInfo = {}
    for i = 1, data.count do
        local gid = pkt:GetLenString()
        data.effInfo[gid] = pkt:GetChar()
    end
end

function MsgParser:MSG_SPRING_2019_XTCL_START_GAME(pkt, data)
    data.idx = pkt:GetChar()
    data.cl1 = pkt:GetLenString()
    data.cl2 = pkt:GetLenString()
    data.cl3 = pkt:GetLenString()
    data.cl_rand_value = pkt:GetLong()
    data.encrypt_id = pkt:GetLenString()
end

-- 2019植树节活动-聚木成林 房间光效
function MsgParser:MSG_ZHISJJUMCL_ROOM_EFFECT(pkt, data)
    data.room_name = pkt:GetLenString()
    data.has_effect = pkt:GetChar()
end

-- 并肩同行 - 通知匹配信息
function MsgParser:MSG_BJTX_FIND_FRIEND(pkt, data)
    data.flag = pkt:GetChar()       -- 1：打开，0：关闭
    data.name = pkt:GetLenString()  -- 伙伴名字
    data.icon = pkt:GetLong()       -- 图标
    data.level = pkt:GetShort()     -- 等级
    data.polar = pkt:GetChar()      -- 相性
end

-- 并肩同行 - 通知福利界面信息
function MsgParser:MSG_BJTX_WELFARE(pkt, data)
    data.end_time = pkt:GetLong()
    data.count = pkt:GetShort()
    for i = 1, data.count do
        data[i] = {}

        data[i].icon = pkt:GetLong()  --  图标
        data[i].name = pkt:GetLenString()  --  名字
        data[i].gid = pkt:GetLenString()  --  gid
        data[i].is_new = pkt:GetChar()  --  是否是新的
        data[i].bonus_size = pkt:GetShort()  --  图标
        data[i].bonusData = {}
        data[i].completedCount = 0
        for j = 1, data[i].bonus_size do
            data[i].bonusData[j] = {}
            data[i].bonusData[j].index  = pkt:GetChar() -- 奖励索引
			data[i].bonusData[j].item_count  = pkt:GetChar() -- 个数
            data[i].bonusData[j].item_name  = pkt:GetLenString() -- 道具名字
            data[i].bonusData[j].num_max  = pkt:GetLong() -- 要求进度
            data[i].bonusData[j].num  = pkt:GetLong() -- 当前进度
            data[i].bonusData[j].is_fetch  = pkt:GetChar() -- 当前进度

            if data[i].bonusData[j].num_max == data[i].bonusData[j].num then
                data[i].completedCount = data[i].completedCount + 1
            end
        end
    end
end

-- 地图摆件出现
function MsgParser:MSG_MAP_DECORATION_APPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.icon = pkt:GetLong()
    data.x = pkt:GetShort()  -- 地图 x 坐标
    data.y = pkt:GetShort()  -- 地图 y 坐标
    data.dir = pkt:GetShort()
    data.ox = pkt:GetSignedChar()    -- 偏移 x
    data.oy = pkt:GetSignedChar()    -- 偏移 y
    -- data.owner_gid = pkt:GetLenString()
end

-- 开始摆件
function MsgParser:MSG_MAP_DECORATION_START(pkt, data)
    data.name = pkt:GetLenString()      -- 道具名称
end

-- 地图摆件消失
function MsgParser:MSG_MAP_DECORATION_DISAPPEAR(pkt, data)
    data.id = pkt:GetLong()
    data.type = pkt:GetShort()
end

-- 操作的结果
function MsgParser:MSG_MAP_DECORATION_RESULT(pkt, data)
    data.cookie = pkt:GetLong()    -- 道具 id
    data.action = pkt:GetLenString()
    data.result = pkt:GetChar()
end

-- 操作的结果
function MsgParser:MSG_MAP_DECORATION_CHECK(pkt, data)
    data.id = pkt:GetLong()
    data.result = pkt:GetChar()
end

-- 通知开始饮酒
function MsgParser:MSG_FOOLS_DAY_2019_START_GAME(pkt, data)
    data.iid = pkt:GetLenString()
    data.npc_name = pkt:GetLenString()
    data.npc_icon = pkt:GetShort()
    data.end_time = pkt:GetLong()
end


-- 2019周年庆萌猫翻牌开始
function MsgParser:MSG_2019ZNQFP_START(pkt, data)
    data.encrypt_id = pkt:GetLenString()
    data.num = pkt:GetShort()
end

-- 2019周年庆萌猫翻牌奖励
function MsgParser:MSG_2019ZNQFP_BONUS(pkt, data)
    data.fp_num = pkt:GetShort()
    data.hightest_socre = pkt:GetShort()
    data.bonus_level = pkt:GetChar()
    data.bonus_count = pkt:GetChar()

    for i = 1, data.bonus_count do
        local bonus_type = pkt:GetLenString()
        data[bonus_type] = pkt:GetLenString()
    end
end

function MsgParser:MSG_SMDG_START_GAME(pkt, data)
    data.iid = pkt:GetLenString()
    data.no = pkt:GetChar()    -- 地图编号
    data.level = pkt:GetChar() -- 层数
    data.has_time = pkt:GetLong() -- 耗时
    data.show_way_count = pkt:GetChar() -- 指路触发次数
    data.meet_enermy_count = pkt:GetChar() -- 遇敌触发次数
    data.meet_treasure_count = pkt:GetChar() -- 遇宝触发次数
    data.pos = pkt:GetSignedShort()  -- 当前位置 x * 100 + y
    data.has_walk_str = pkt:GetLenString() -- 探索区域信息
end

-- 回复客户端触发事件(剧本播放结束后发送此消息)
function MsgParser:MSG_SMDG_TRIGGER_EVENT(pkt, data)
    data.level = pkt:GetChar() -- 层数
    data.type = pkt:GetChar()    -- 事件类型（1表示指路，2表示遇敌，3表示遇宝）
    data.result = pkt:GetChar()  -- 触发结果（0表示失败，1表示成功）
end

-- 通知客户端结算界面
function MsgParser:MSG_SMDG_FINISH_GAME(pkt, data)
    data.level = pkt:GetChar()      -- 层数
    data.has_time = pkt:GetLong()   -- 耗时
    data.result = pkt:GetChar()     -- 游戏结果（0表示失败，1表示成功）
end

-- 通知客户端结算界面
function MsgParser:MSG_DW_2019_KWDZ(pkt, data)
    data.id = pkt:GetLong()      -- id
    data.corp = pkt:GetLenString()  -- "tian" 甜味阵营, "xian" 咸味阵营
end

function MsgParser:MSG_2019ZNQ_CWTX_DATA(pkt, data)
	data.state = pkt:GetChar()      -- 状态，如果为STATE_READY消息时，该消息只有一个字段，不会发送下面的字段
	if data.state == 0 then return end
	data.level = pkt:GetShort()		-- 探险等级
	data.exp = pkt:GetShort()		-- 探险经验
    data.upgrade_need_exp = pkt:GetShort()		-- 升到下级所需经验
	data.damage = pkt:GetShort()		-- 探险伤害
	data.tao = pkt:GetShort()		-- 探险武学

	data.temp_damage = pkt:GetSignedShort()		-- 探险伤害
	data.temp_tao = pkt:GetSignedShort()		-- 探险武学

	data.act_power = pkt:GetShort()		-- 探险值
	data.max_act_power = pkt:GetShort()		-- 最大探险值
	data.full_power_time = pkt:GetLong()      -- 探险值满的时间，如果为0，表示已满
    data.next_refresh_time = pkt:GetLong()
	data.layer = pkt:GetShort()		-- 秘境层数
	data.remain_layer_times = pkt:GetChar()      -- 今日可探索秘境层数
	data.remain_bonus_times = pkt:GetChar()      -- 今日可开启宝箱数量
	data.baoxiang_layer = pkt:GetShort()		-- 宝箱所在层数
	data.bonus_type = pkt:GetLenString()  -- 奖励类型  tao exp
	data.cell_count = pkt:GetShort()	-- 25个格子的数据
	data.cells = {}
	for i = 1, data.cell_count do
		data.cells[i] = {}
		data.cells[i].cell_type = pkt:GetChar()
		data.cells[i].click_status = pkt:GetChar()
		data.cells[i].extra_data = pkt:GetShort()
	end
end

function MsgParser:MSG_2019ZNQ_CWTX_CLICK(pkt, data)

	data.layer = pkt:GetShort()		-- 秘境层数
	data.x = pkt:GetChar()
	data.y = pkt:GetChar()

	data.bef_data = {}

	data.bef_data.cell_type = pkt:GetChar()
	data.bef_data.click_status = pkt:GetChar()
	data.bef_data.extra_data = pkt:GetShort()

	data.atf_data = {}
	data.atf_data.cell_type = pkt:GetChar()
	data.atf_data.click_status = pkt:GetChar()
	data.atf_data.extra_data = pkt:GetShort()

end

function MsgParser:MSG_2019ZNQ_CWTX_ACT_LOG(pkt, data)

	data.ti = pkt:GetLong()		-- 秘境层数
	data.log = pkt:GetLenString()  -- 奖励类型  tao exp
    data.layer = pkt:GetShort()
end

-- 2019儿童节护送小龟 通知客户端开始护送小龟游戏
function MsgParser:MSG_CHILD_DAY_2019_START_GAME(pkt, data)
    data.id = pkt:GetLenString()
end

-- 2019儿童节护送小龟 通知客户端停止游戏（收到此消息后，客户端再按设定进行清理操作）
function MsgParser:MSG_CHILD_DAY_2019_STOP_GAME(pkt, data)
    data.result = pkt:GetChar()
    data.npcId = pkt:GetLong()
end

-- 2019儿童节护送小龟 通知客户端触发事件结果
function MsgParser:MSG_CHILD_DAY_2019_EVENT_RESULT(pkt, data)
    data.result = pkt:GetChar()
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.npcId = pkt:GetLong()
end

-- 2019儿童节护送小龟 通知客户端触发事件结果
function MsgParser:MSG_CHILD_DAY_2019_DATA(pkt, data)
    data.gameData = pkt:GetLenString()
    self:MSG_CHILD_DAY_2019_EVENT_RESULT(pkt, data)
end

-- 队伍指挥 - 通知自定义命令
function MsgParser:MSG_TEAM_COMMANDER_CMD_LIST(pkt, data)
    data.type = pkt:GetChar()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        data.list[i] = pkt:GetLenString()
    end
end

-- 队伍指挥 - 拥有指挥权限的玩家
function MsgParser:MSG_TEAM_COMMANDER_GID(pkt, data)
    data.gid = pkt:GetLenString()
end

-- 队伍指挥 - 战斗中的队伍指挥数据
function MsgParser:MSG_TEAM_COMMANDER_COMBAT_DATA(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local tmp = {}
        tmp.id = pkt:GetLong()
        tmp.command = pkt:GetLenString()
        data[i] = tmp
    end
end

-- 2019 智斗百草开始游戏
function MsgParser:MSG_DW_2019_ZDBC_DATA(pkt, data)
    data.type = pkt:GetLenString() -- 标识下一步要干什么：“start” 为刚打开界面时，“next_question”  为下一道题目，“next_answer” 为下一次答题机会，“stop” 游戏结果。
    data.index = pkt:GetChar()     -- 题目编号
    data.tm_num = pkt:GetChar()    -- 当前完成了几道题目
    data.win_num = pkt:GetChar()   -- 当前胜利了几次
    data.dt_num = pkt:GetChar()    -- 当前题目答题次数
end

-- 通知客户端打开通天令牌界面
function MsgParser:MSG_OPEN_TTLP_DLG(pkt, data)
	data.xingJunCount = pkt:GetShort()
	data.xingJunInfo = {}
	for i = 1, data.xingJunCount do
		data.xingJunInfo[i] = {}
		data.xingJunInfo[i].name = pkt:GetLenString()
		data.xingJunInfo[i].icon = pkt:GetLong()
	end

    data.itemPos = pkt:GetShort()
    data.leftTime = pkt:GetChar()
end

-- 通知通天塔顶信息
function MsgParser:MSG_TONGTIANTADING_XINGJUN_LIST(pkt, data)
	data.xingJunCount = pkt:GetShort()
	for i = 1, data.xingJunCount do
		data[i] = {}
		data[i].name = pkt:GetLenString()
	end
    data.leftTime = pkt:GetChar()     -- 剩余次数
end

-- 通知客户端战斗中阵法信息
function MsgParser:MSG_BATTLE_ARRAY_INFO(pkt, data)
    data.friend_polar = pkt:GetChar()  -- 我方阵法相性（无相性则为0）
    data.opponent_polar = pkt:GetChar() -- 对方阵法相性（无相性则为0）
    data.type = pkt:GetSignedChar()  -- 阵法克制（无克制为0，我方克制对方为1，对方克制我方为-1）
end

-- 回归累充活动数据
function MsgParser:MSG_REENTRY_ASKTAO_RECHARGE_DATA(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.gift_end_time = pkt:GetLong()
    data.flag = pkt:GetChar()
    data.progress = pkt:GetShort()
    data.max_progress = pkt:GetShort()
    data.bonus_desc = pkt:GetLenString()
end

--
function MsgParser:MSG_SMFJ_YLMB_STEP_LIST(pkt, data)
	data.isDemo = pkt:GetChar()	--	是否需要演示

	data.stepCount = pkt:GetShort()
	data.path = {}
	for i = 1, data.stepCount do
		table.insert(data.path, pkt:GetChar())
	end
end

-- void msg_smfj_ylmb_move_step(int32 id, int8 step, int8 cmd_no, int8 success);
function MsgParser:MSG_SMFJ_YLMB_MOVE_STEP(pkt, data)
	data.id = pkt:GetLong()
	data.step = pkt:GetSignedChar()
	data.cmd_no = pkt:GetChar()
	data.success = pkt:GetChar()
end

function MsgParser:MSG_SMFJ_GAME_STATE(pkt, data)
	data.game_name = pkt:GetLenString()
	data.status = pkt:GetChar()			-- 1  准备阶段 				2  游戏进行中			3   游戏结束
	data.end_time = pkt:GetLong()
end

function MsgParser:MSG_SMFJ_SWZD_STEP_LIST(pkt, data)
	data.stepCount = pkt:GetShort()
	data.path = {}
	for i = 1, data.stepCount do
		table.insert(data.path, pkt:GetChar())
	end
end

-- void msg_smfj_swzd_move_step(int32 id, int8 step, int8 cmd_no, int8 success);
function MsgParser:MSG_SMFJ_SWZD_MOVE_STEP(pkt, data)
	data.id = pkt:GetLong()
	data.step = pkt:GetSignedChar()
	data.cmd_no = pkt:GetChar()
	data.success = pkt:GetChar()
end

function MsgParser:MSG_PET_ICON_UPDATED(pkt, data)
	data.action = pkt:GetLenString()
	data.result = pkt:GetChar()
end

function MsgParser:MSG_SMFJ_BSWH_PLAYER_ICON(pkt, data)
	data.id = pkt:GetLong()
	data.icon = pkt:GetLong()
end

function MsgParser:MSG_SMFJ_CJDWW_OPER_USER(pkt, data)
	data.id = pkt:GetLong()
	data.name = pkt:GetLenString()
	data.icon = pkt:GetLong()
end

function MsgParser:MSG_SMFJ_CJDWW_PROGRESS(pkt, data)
	data.progress = pkt:GetLong()
	data.total_progress = pkt:GetLong()
end

function MsgParser:MSG_TTT_GJ_NEW_XING(pkt, data)
	data.pos = pkt:GetShort()
	data.curName = pkt:GetLenString()
end

function MsgParser:MSG_SHNTM_FAIL(pkt, data)
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
    data.count = pkt:GetShort()
    data.monsterIdMap = {}
    for i = 1, data.count do
        local id = pkt:GetLong()
        data.monsterIdMap[id] = true
    end
end

function MsgParser:MSG_AUTO_WALK_LINE(pkt, data)
	data.line_type = pkt:GetChar()						-- 线路类型（1表示人数最少单线，2表示人数最少双线）
	data.auto_walk_info = pkt:GetLenString()			-- 触发的寻路信息
	data.line_name = pkt:GetLenString()					-- 线路名（若不存在则为空）
end

function MsgParser:MSG_HTTP_TOKEN(pkt, data)
    data.server = pkt:GetLenString();
    data.token = pkt:GetLenString();
end

function MsgParser:MSG_NEW_DIST_PRECHARGE_DATA(pkt, data)
    data.dist_name = pkt:GetLenString()
    data.start_time = pkt:GetLong()
	data.end_charge_time = pkt:GetLong()
    data.end_time = pkt:GetLong()       --
    data.hot_value = pkt:GetLong()
    data.start_server_time = pkt:GetLong()
    data.isOffical = pkt:GetChar()
end

function MsgParser:MSG_L_GOLD_COIN_DATA(pkt, data)
    data.gold_coin = pkt:GetLong()
    data.gift_gold_coin = pkt:GetLong()
    data.precharge_coin = pkt:GetLong()
    data.already_return_coin = pkt:GetLong()
end

function MsgParser:MSG_L_INSIDER_ACT_DATA(pkt, data)
    data.discount_start_time = pkt:GetLong()
    data.discount_end_time = pkt:GetLong()
    data.vip_start_time = pkt:GetLong()
    data.vip_end_time = pkt:GetLong()
end


-- 2019 暑假神秘数字之神秘画卷数据
function MsgParser:MSG_SUMMER_2019_SMSZ_SMHJ(pkt, data)
	data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].color = pkt:GetLenString()
    end

    data.commit_num = pkt:GetChar()  -- 提交次数

    -- 已找到索引
    data.find_count = pkt:GetChar()
    for i = 1, data.find_count do
        local num = pkt:GetShort()
        if not data[num + 1] then data[num + 1] = {} end
        data[num + 1].hasFind  = true
    end

	local count = pkt:GetChar()
    for i = 1, count do
        local random = pkt:GetShort() -- 随机数
        if i <= 10 then
            if not data[i] then data[i] = {} end
            data[i].pos_index = math.floor(random / 100)
            data[i].scale_index = random % 100
        else
            data.map_index = random
        end
    end

    data.can_commit = pkt:GetChar()
end

-- 2019 暑假神秘数字之神秘画卷结果
function MsgParser:MSG_SUMMER_2019_SMSZ_SMHJ_RESULT(pkt, data)
    data.result = pkt:GetChar() -- 1 成功， 0 失败
end

-- 2019 暑假神秘数字之神秘宝盒数据
function MsgParser:MSG_SUMMER_2019_SMSZ_SMBH(pkt, data)
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data[i] = {}
        data[i].color = pkt:GetLenString()
    end

    data.num_str = pkt:GetLenString()
    data.result = pkt:GetChar()
end


-- 2019 暑假神秘数字之神秘宝盒结果
function MsgParser:MSG_SUMMER_2019_SMSZ_SMBH_RESULT(pkt, data)
    data.result = pkt:GetChar() -- 1 成功， 0 失败
end

-- 当前是否开放货站功能
function MsgParser:MSG_SPOT_ENABLE(pkt, data)
    data.flag = pkt:GetChar()
    data.flag = data.flag == 1
    data.open_time = pkt:GetLong()
end

-- 响应货站数据
function MsgParser:MSG_TRADING_SPOT_DATA(pkt, data)
    data.trading_no = pkt:GetLenString()
    data.open_time = pkt:GetLong()
    data.close_time = pkt:GetLong()
    data.needOpenDlg = pkt:GetChar()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.goods_id = pkt:GetShort()
        tmpInfo.price = pkt:GetLong()
        tmpInfo.last_range = pkt:GetSignedLong()
        tmpInfo.volume = pkt:GetShort()
        tmpInfo.all_price = tmpInfo.price * tmpInfo.volume
        tmpInfo.status = pkt:GetChar()
        tmpInfo.is_collected = pkt:GetChar()
        tmpInfo.is_collected = tmpInfo.is_collected == 1
        data.list[i] = tmpInfo
    end
end

-- 收藏结果
function MsgParser:MSG_TRADING_SPOT_COLLECT(pkt, data)
    data.goods_id = pkt:GetShort()
    data.is_collected = pkt:GetChar()
    data.is_collected = data.is_collected == 1
end

-- 最近10期走势图
function MsgParser:MSG_TRADING_SPOT_GOODS_LINE(pkt, data)
    data.goods_id = pkt:GetShort()
    data.init_price = pkt:GetLong()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.close_price = pkt:GetLong()
        tmpInfo.range = pkt:GetSignedLong()
        tmpInfo.status = pkt:GetChar()
        data.list[data.count - i + 1] = tmpInfo
    end
end

-- 历史涨跌
function MsgParser:MSG_TRADING_SPOT_GOODS_RANGE(pkt, data)
    data.goods_id = pkt:GetShort()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.trading_no = pkt:GetLenString()
        tmpInfo.range = pkt:GetSignedLong()
        data.list[i] = tmpInfo
    end
end

-- 盈亏记录
function MsgParser:MSG_TRADING_SPOT_GOODS_RECORD(pkt, data)
    data.goods_id = pkt:GetShort()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.trading_no = pkt:GetLenString()
        tmpInfo.all_price = tonumber(pkt:GetLenString())
        tmpInfo.profit = pkt:GetSignedLong()
        data.list[i] = tmpInfo
    end
end

-- 上期盈亏 or 历史盈亏
function MsgParser:MSG_TRADING_SPOT_PROFIT(pkt, data)
    data.bank_money = pkt:GetLenString()
    data.list_type = pkt:GetChar()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.trading_no = pkt:GetLenString()
        tmpInfo.goods_id = pkt:GetShort()
        tmpInfo.range = pkt:GetSignedLong()
        tmpInfo.all_price = tonumber(pkt:GetLenString())
        tmpInfo.profit = pkt:GetSignedLong()
        data.list[i] = tmpInfo
    end
end

-- 货站名片
function MsgParser:MSG_TRADING_SPOT_GOODS_CARD(pkt, data)
    data.gid = pkt:GetLenString()
    data.char_name = pkt:GetLenString()
    self:MSG_TRADING_SPOT_GOODS_RECORD(pkt, data)
end

-- 货站余额
function MsgParser:MSG_TRADING_SPOT_UPDATE_MONEY(pkt, data)
    data.bank_money = pkt:GetLenString()
end

-- 货站买入方案
function MsgParser:MSG_TRADING_SPOT_CHAR_BID_INFO_CARD(pkt, data)
    data.card_gid = pkt:GetLenString()
    data.gid = pkt:GetLenString()
    data.char_name = pkt:GetLenString()
    data.trading_no = pkt:GetLenString()
    data.open_time = pkt:GetLong()
    data.close_time = pkt:GetLong()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.goods_id = pkt:GetShort()
        tmpInfo.price = pkt:GetLong()
        tmpInfo.range = pkt:GetSignedLong()
        tmpInfo.volume = pkt:GetShort()
        tmpInfo.all_price = tmpInfo.price * tmpInfo.volume
        data.list[i] = tmpInfo
    end
end

-- 货站十人巨商
function MsgParser:MSG_TRADING_SPOT_RANK_LIST(pkt, data)
    data.me_profit = pkt:GetLenString()
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.char_gid = pkt:GetLenString()
        tmpInfo.char_name = pkt:GetLenString()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.polar = pkt:GetChar()
        tmpInfo.icon = pkt:GetLong()
        tmpInfo.sum_profit = pkt:GetLenString()
        tmpInfo.sum_profit = tonumber(tmpInfo.sum_profit)
        data.list[i] = tmpInfo
    end
end

-- 货站买过商品列表
function MsgParser:MSG_TRADING_SPOT_CARD_GOODS_LIST(pkt, data)
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.goods_id = pkt:GetShort()
        data.list[i] = tmpInfo
    end
end

function MsgParser:MSG_CSML_ROUND_TIME(pkt, data)
	data.season_no = pkt:GetShort()						-- 赛季届数
	data.total_round = pkt:GetShort()					-- 总轮数
	data.group_round = pkt:GetShort()					-- 小组赛轮数
	data.match_duration	= pkt:GetLong()					-- 每场比赛持续时间
	data.start_time	= pkt:GetLong()						-- 赛季开始时间
	data.signup_end_ti = pkt:GetLong()					-- 报名截止时间
	data.group_ti = pkt:GetLong()						-- 小组赛名单公布时间，当参数名单未确定时，轮数为 0
	data.knockout_ti = pkt:GetLong()					-- 淘汰赛名单公布时间
	data.round_size = pkt:GetShort()					-- 轮数
	data.round_ti_info = {}
	for i = 1, data.round_size do
		data.round_ti_info[i] = pkt:GetLong()
	end
end

function MsgParser:MSG_CSML_ALL_SIMPLE(pkt, data)
	data.season_no = pkt:GetShort()						-- 赛季届数
	data.inGroup = {}
	for i = 1, data.season_no do
		data.inGroup[i] = pkt:GetChar()
	end
end

function MsgParser:MSG_CSML_LEAGUE_DATA(pkt, data)
    data.seasonNo = pkt:GetShort()         -- 最大届数
 --   data.level = pkt:GetShort()         -- 等级段
 --   data.area = pkt:GetChar()           -- 赛区
    data.match_duration = pkt:GetLong() -- 单场比赛的持续时间
    data.champion = pkt:GetLenString()

    local ret = {}          -- 通过整理后 ret才是最终想要的数据
 --   ret.key = string.format("%d|%d|%d", data.seasonNo, data.level, data.area)
	ret.key = data.seasonNo
    data.group_count = pkt:GetChar() -- 小组数量
    data.group_data1 = {}
    ret.groupInfo = {}
    ret.groupInfo.count = data.group_count
    local distInfo = {}
    local groupWarInfo = {}

    for i = 1, data.group_count do
        data.group_data1[i] = {}
        data.group_data1[i].group_no = pkt:GetChar()
        data.group_data1[i].is_end = pkt:GetChar()
        data.group_data1[i].dist_count = pkt:GetChar()
        data.group_data1[i].dists = {}
        ret.groupInfo[i] = {}
        ret.groupInfo[i].groupNo = data.group_data1[i].group_no
        ret.groupInfo[i].distCount = data.group_data1[i].dist_count
        ret.groupInfo[i].distInfo = {}

        for j = 1, data.group_data1[i].dist_count do
            data.group_data1[i].dists[j] = pkt:GetLenString()
            ret.groupInfo[i].distInfo[j] = {}
            ret.groupInfo[i].distInfo[j].distName = data.group_data1[i].dists[j]

            if not distInfo[ret.groupInfo[i].distInfo[j].distName] then
                distInfo[ret.groupInfo[i].distInfo[j].distName] = {isWinner = ((j == 1 or j == 2) and data.group_data1[i].is_end == 1),distName = data.group_data1[i].dists[j], point = 0, score = 0, win = 0, lost = 0, draw = 0}
            end
            if not groupWarInfo[data.group_data1[i].dists[j]] then
                groupWarInfo[data.group_data1[i].dists[j]] = {}
            end
        end
    end

    data.knockout_round_count = pkt:GetChar() -- 淘汰赛轮数
    data.knockout_data1 = {}
    for i = 1, data.knockout_round_count do
        data.knockout_data1[i] = {}
        data.knockout_data1[i].knockout_round_no = pkt:GetChar()
        data.knockout_data1[i].knockout_match_count = pkt:GetChar()
        data.knockout_data1[i].match_ids = {}
        for j = 1, data.knockout_data1[i].knockout_match_count do
            data.knockout_data1[i].match_ids[j] = pkt:GetLenString()
        end
    end

    local startWarTime

    data.group_count2 = pkt:GetChar() -- 小组数量
    data.group_data2 = {}
    for i = 1, data.group_count2 do
        data.group_data2[i] = {}
        data.group_data2[i].group_no = pkt:GetChar()
        data.group_data2[i].group_match_count = pkt:GetChar()
        data.group_data2[i].group_match_info = {}
        for j = 1, data.group_data2[i].group_match_count do
            data.group_data2[i].group_match_info[j] = {}
            data.group_data2[i].group_match_info[j].match_id = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].match_name = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].start_time = pkt:GetLong()
            data.group_data2[i].group_match_info[j].point = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].score = pkt:GetLenString()
            data.group_data2[i].group_match_info[j].ret_type = pkt:GetChar()

            startWarTime = startWarTime or data.group_data2[i].group_match_info[j].start_time

            if data.group_data2[i].group_match_info[j].point == "" then
                -- 比赛未开始

                local distArr = gf:split(data.group_data2[i].group_match_info[j].match_name, " VS ")
                local dist1, dist2 = distArr[1], distArr[2]

                local pointArr = gf:split(data.group_data2[i].group_match_info[j].point, ":")
                local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])

                local scoreArr = gf:split(data.group_data2[i].group_match_info[j].score, ":")
                local score1, score2 = tonumber(scoreArr[1]), tonumber(scoreArr[2])

                local warInfo1 = {}
                local warInfo2 = {}


                -- 战况信息
                if groupWarInfo[dist1] then
                    warInfo1.myDist = dist1
                    warInfo1.enemyDist = dist2
                    warInfo1.start_time = data.group_data2[i].group_match_info[j].start_time

                    table.insert(groupWarInfo[dist1], warInfo1)
                end
                if groupWarInfo[dist2] then
                    warInfo2.myDist = dist2
                    warInfo2.enemyDist = dist1
                    warInfo2.start_time = data.group_data2[i].group_match_info[j].start_time
                    table.insert(groupWarInfo[dist2], warInfo2)
                end

            else
                local distArr = gf:split(data.group_data2[i].group_match_info[j].match_name, " VS ")
                local dist1, dist2 = distArr[1], distArr[2]

                local pointArr = gf:split(data.group_data2[i].group_match_info[j].point, ":")
                local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])

                local scoreArr = gf:split(data.group_data2[i].group_match_info[j].score, ":")
                local score1, score2 = tonumber(scoreArr[1]), tonumber(scoreArr[2])

                local warInfo1 = {}
                local warInfo2 = {}
                if point1 > point2 then
                    distInfo[dist1].win = distInfo[dist1].win + 1
                    distInfo[dist2].lost = distInfo[dist2].lost + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 1 -- 赢了
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 2 -- 输了
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                elseif point1 < point2 then
                    distInfo[dist1].lost = distInfo[dist1].lost + 1
                    distInfo[dist2].win = distInfo[dist2].win + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 2 -- 输了
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 1 -- 赢了
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                else
                    distInfo[dist1].draw = distInfo[dist1].draw + 1
                    distInfo[dist2].draw = distInfo[dist2].draw + 1

                    -- 战况信息
                    if groupWarInfo[dist1] then
                        warInfo1.myRet = 3 -- 平局
                        warInfo1.score = string.format("%d:%d", score1, score2)
                    end
                    if groupWarInfo[dist2] then
                        warInfo2.myRet = 3 -- 平局
                        warInfo2.score = string.format("%d:%d", score2, score1)
                    end
                end

                -- 战况信息
                if groupWarInfo[dist1] then
                    warInfo1.myDist = dist1
                    warInfo1.enemyDist = dist2
                    warInfo1.start_time = data.group_data2[i].group_match_info[j].start_time

                    table.insert(groupWarInfo[dist1], warInfo1)
                end
                if groupWarInfo[dist2] then
                    warInfo2.myDist = dist2
                    warInfo2.enemyDist = dist1
                    warInfo2.start_time = data.group_data2[i].group_match_info[j].start_time
                    table.insert(groupWarInfo[dist2], warInfo2)
                end

                distInfo[dist1].point = distInfo[dist1].point + point1
                distInfo[dist2].point = distInfo[dist2].point + point2
            end
        end
    end

    ret.distInfo = distInfo
    ret.groupWarInfo = groupWarInfo
    ret.startWarTime = startWarTime
    ret.match_duration = data.match_duration

    local knockoutInfo = {}

    data.knockout_round_count2 = pkt:GetChar() -- 淘汰赛轮数
    data.knockout_data2 = {}
    for i = 1, data.knockout_round_count2 do
        data.knockout_data2[i] = {}
        data.knockout_data2[i].knockout_round_no = pkt:GetChar()
        data.knockout_data2[i].knockout_match_count = pkt:GetChar()
        data.knockout_data2[i].match_info = {}
        local oneRound = {}
        for j = 1, data.knockout_data2[i].knockout_match_count do
            data.knockout_data2[i].match_info[j] = {}
            data.knockout_data2[i].match_info[j].match_id = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].match_name = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].start_time = pkt:GetLong()
            data.knockout_data2[i].match_info[j].point = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].score = pkt:GetLenString()
            data.knockout_data2[i].match_info[j].ret_type = pkt:GetChar()

            -- 小组赛未结束，淘汰赛match_name 为空字符串
            if data.knockout_data2[i].match_info[j].match_name ~= "" then
                local unitData = {}

                local distArr = gf:split(data.knockout_data2[i].match_info[j].match_name, " VS ")
                unitData[1] = distArr[1]
                unitData[2] = distArr[2]

                if data.knockout_data2[i].match_info[j].point == "" then
                    unitData.winner = ""
                    unitData.winnerNo = ""
                else
                    local pointArr = gf:split(data.knockout_data2[i].match_info[j].point, ":")
                    local point1, point2 = tonumber(pointArr[1]), tonumber(pointArr[2])
                    if point1 > point2 then
                        unitData.winner = distArr[1]
                        unitData.winnerNo = (j - 1) * 2 + 1
                    else
                        unitData.winner = distArr[2]
                        unitData.winnerNo = (j - 1) * 2 + 2
                    end
                end

                unitData["start_time"] = data.knockout_data2[i].match_info[j].start_time
                table.insert(oneRound, unitData)
            else
                table.insert(oneRound, {[1] = "", [2] = "", start_time = data.knockout_data2[i].match_info[j].start_time, winnerNo = "", winner = ""})
            end
        end

        table.insert(knockoutInfo, oneRound)
    end

    ret.knockoutInfo = knockoutInfo
    data.ret = ret
end

function MsgParser:MSG_CSML_MATCH_SIMPLE(pkt, data)
	data.has_fixtures = pkt:GetChar()				-- 是否已经安排赛程
    data.total_round = pkt:GetChar()                -- 联赛总轮数
    data.group_round = pkt:GetChar()                -- 小组赛轮数
	data.group_no = pkt:GetChar()                -- 当前区组所属小组，没有比赛为 0
	data.has_total_top = pkt:GetChar()				-- 是否已经有总积分榜了
	data.group_end = pkt:GetChar()					-- 小组赛是否已经结束
	data.group_match_count = pkt:GetChar()			-- 小组赛数量

    local groupMatchData = {}
	for i = 1, data.group_match_count do
		groupMatchData[i] = {}
		groupMatchData[i].match_id = pkt:GetLenString()
		groupMatchData[i].match_name = pkt:GetLenString()
		groupMatchData[i].start_time = pkt:GetLong()
		groupMatchData[i].point = pkt:GetLenString()
		groupMatchData[i].score = pkt:GetLenString()
		groupMatchData[i].ret_type = pkt:GetChar()
		groupMatchData[i].round = pkt:GetChar()
	end
	data.groupMatchData = groupMatchData

    data.knockout_match_count = pkt:GetChar()           -- 淘汰赛数量
    local knockoutInfo = {}                              -- 淘汰赛信息
	for i = 1, data.knockout_match_count do
		knockoutInfo[i] = {}
		knockoutInfo[i].match_id = pkt:GetLenString()
		knockoutInfo[i].match_name = pkt:GetLenString()
		knockoutInfo[i].start_time = pkt:GetLong()
		knockoutInfo[i].point = pkt:GetLenString()
		knockoutInfo[i].score = pkt:GetLenString()
		knockoutInfo[i].ret_type = pkt:GetChar()
		knockoutInfo[i].round = pkt:GetChar()
	end
	data.knockoutInfo = knockoutInfo
end

function MsgParser:MSG_CSML_MATCH_DATA(pkt, data)
    data.name = pkt:GetLenString()
    data.rankInfo = {}
    data.count = pkt:GetChar()
    for i = 1, data.count do
        data.rankInfo[i] = {}
        data.rankInfo[i].rank = pkt:GetShort()
        data.rankInfo[i].gid = pkt:GetLenString()
        data.rankInfo[i].name = pkt:GetLenString()
        data.rankInfo[i].level = pkt:GetShort()
        data.rankInfo[i].polar = pkt:GetChar()
        data.rankInfo[i].contrib = pkt:GetLong()
        data.rankInfo[i].combat = pkt:GetShort()
        data.rankInfo[i].win = pkt:GetShort()
    end
end

function MsgParser:MSG_CSML_CONTRIB_TOP_DATA(pkt, data)
	self:MSG_CSL_CONTRIB_TOP_DATA(pkt, data)
end

function MsgParser:MSG_CSML_LIVE_SCORE(pkt, data)
	data.personScore = pkt:GetLong()		-- 个人积分
	data.personTilizhi = pkt:GetLong()		-- 个人体力值
	data.endTime = pkt:GetLong()			-- 比赛结束时间
	data.myDist = pkt:GetLenString()		-- string，我方区组名称
	data.ourTotalScore = pkt:GetLong()		-- 我方总积分
	data.ourPersonCount = pkt:GetShort()		-- 我方在场人数
	data.ourRankCount = pkt:GetShort()		-- 我方上榜人数
	data.ourRankInfo = {}
	for i = 1, data.ourRankCount do
		data.ourRankInfo[i] = {}
		data.ourRankInfo[i].name = pkt:GetLenString()
		data.ourRankInfo[i].score = pkt:GetLong()
	end

	data.enermyDist	= pkt:GetLenString()	-- 对方区组名称
	data.enermyTotalScore = pkt:GetLong()	-- 对方总积分
	data.enermyPersonCount = pkt:GetShort()		-- 对方在场人数
	data.enermyRankCount = pkt:GetShort()		-- 对方上榜人数
	data.enermyRankInfo = {}
	for i = 1, data.enermyRankCount do
		data.enermyRankInfo[i] = {}
		data.enermyRankInfo[i].name = pkt:GetLenString()
		data.enermyRankInfo[i].score = pkt:GetLong()
	end
end

function MsgParser:MSG_CSML_CONTRIB_TOP_DATA(pkt, data)
	self:MSG_CSL_CONTRIB_TOP_DATA(pkt, data)
end

function MsgParser:MSG_BBS_UPDATE_ONE_STATUS(pkt, data)
	self:MSG_BLOG_UPDATE_ONE_STATUS(pkt, data, true)
end

function MsgParser:MSG_BBS_DELETE_ONE_STATUS(pkt, data)
	self:MSG_BLOG_DELETE_ONE_STATUS(pkt, data)
end

function MsgParser:MSG_BBS_REQUEST_STATUS_LIST(pkt, data)
	data.catalog = pkt:GetLenString()
	self:MSG_BLOG_REQUEST_STATUS_LIST(pkt, data, true)
end

function MsgParser:MSG_BBS_REQUEST_LIKE_LIST(pkt, data)
	self:MSG_BLOG_REQUEST_LIKE_LIST(pkt, data)
end

function MsgParser:MSG_BBS_OPEN_COMMENT_DLG(pkt, data)
	self:MSG_OPEN_COMMENT_DLG(pkt, data)
end

function MsgParser:MSG_BBS_UPDATE_ONE_COMMENT(pkt, data)
	self:MSG_BLOG_UPDATE_ONE_COMMENT(pkt, data)
end


function MsgParser:MSG_BBS_ALL_COMMENT_LIST(pkt, data)
	self:MSG_BLOG_ALL_COMMENT_LIST(pkt, data)
end


function MsgParser:MSG_BBS_LIKE_ONE_STATUS(pkt, data)
	self:MSG_BLOG_LIKE_ONE_STATUS(pkt, data)
end

function MsgParser:MSG_CSML_MATCH_DATA_COMPETE(pkt, data)
    data.total_round = pkt:GetChar()                -- 联赛总轮数
    data.group_round = pkt:GetChar()                -- 小组赛轮数
    data.round = pkt:GetChar()                      -- 当前轮数
    data.dist = pkt:GetLenString()                  -- 查看积分的区组
    data.match_name = pkt:GetLenString()            -- 比赛名称
    data.start_time = pkt:GetLong()                 -- 开始时间
    data.point = pkt:GetLenString()                 -- 比赛结果情况
    data.score = pkt:GetLenString()                 -- 比分情况
    data.ret_type = pkt:GetChar()                   -- 小组赛轮数
    data.count = pkt:GetChar()                      -- 数量
    data.rankInfo = {}
    for i = 1, data.count do
        data.rankInfo[i] = {}
        data.rankInfo[i].rank = pkt:GetShort()
        data.rankInfo[i].gid = pkt:GetLenString()
        data.rankInfo[i].name = pkt:GetLenString()
        data.rankInfo[i].level = pkt:GetShort()
        data.rankInfo[i].polar = pkt:GetChar()
        data.rankInfo[i].contrib = pkt:GetLong()
        data.rankInfo[i].combat = pkt:GetShort()
        data.rankInfo[i].win = pkt:GetShort()
    end
    data.myCount = pkt:GetChar()    -- 为0代表未上榜，1则取相关数据
    data.myRankInfo = {}
    for i = 1, data.myCount do
        data.myRankInfo[i] = {}
        data.myRankInfo[i].rank = pkt:GetShort()
        data.myRankInfo[i].gid = pkt:GetLenString()
        data.myRankInfo[i].name = pkt:GetLenString()
        data.myRankInfo[i].level = pkt:GetShort()
        data.myRankInfo[i].polar = pkt:GetChar()
        data.myRankInfo[i].contrib = pkt:GetLong()
        data.myRankInfo[i].combat = pkt:GetShort()
        data.myRankInfo[i].win = pkt:GetShort()
    end
end

function MsgParser:MSG_TRADING_SPOT_BBS_CATALOG_LIST(pkt, data)
	data.count = pkt:GetShort()
	data.catalogs = {}
	for i = 1, data.count do
		data.catalogs[i] = pkt:GetLenString()
	end
end

function MsgParser:MSG_SUMMER_2019_SSWG_DATA(pkt, data)
	data.status = pkt:GetLenString()						-- 游戏状态，下面有阶段定义
	data.remain_ti = pkt:GetLong()							-- 剩余时间，在 "running" 阶段使用
	data.cur_index = pkt:GetChar()							-- 当前操作玩家的编号
	data.player_count = pkt:GetChar()						-- 玩家数量
	data.players = {}
	for i = 1, data.player_count do
		data.players[i] = {}
		data.players[i].index = pkt:GetChar()				-- 玩家编号
		data.players[i].icon = pkt:GetLong()
		data.players[i].name = pkt:GetLenString()
		data.players[i].prepared = pkt:GetChar()			-- 是否已经准备就绪，准备阶段使用
		data.players[i].is_online = pkt:GetChar()			-- 1 表示在线，0 表示不在线
		data.players[i].gid = pkt:GetLenString()
		data.players[i].card_num = pkt:GetShort()				-- 当前手上牌的数量
		data.players[i].trusteehip_flag = pkt:GetChar()				-- 托管标识
	end

	data.show_type = pkt:GetChar()							-- 当前显示动作类型 见 ShiswgDlg 前几排注释
	data.para =	pkt:GetLenString()							-- 客户端标记
	data.my_card_num = pkt:GetShort()						-- 当前手上牌的数量
	data.my_cards = {}
	for i = 1, data.my_card_num do
		local card_id = pkt:GetShort()
		table.insert(data.my_cards, card_id)
	end
end

function MsgParser:MSG_SUMMER_2019_SSWG_BONUS(pkt, data)
	data.count = pkt:GetChar()
	data.rankInfo = {}
	for i = 1, data.count do
		local rank = pkt:GetChar()
		local name = pkt:GetLenString()
		data.rankInfo[rank] = name
	end

	data.result = pkt:GetChar() 	-- 0 失败， 1 赢，
	data.bonus_num = pkt:GetChar()

	for i = 1, data.bonus_num do
		local type = pkt:GetLenString()
		data[type] = pkt:GetLenString()
	end
end

function MsgParser:MSG_SUMMER_2019_BHKY_START(pkt, data)
    data.max_time = pkt:GetLong()
    data.sucess_time = pkt:GetLong()
    data.title_time = pkt:GetLong()
    data.cookie = pkt:GetLenString()
end

function MsgParser:MSG_SUMMER_2019_SXDJ_DATA(pkt, data)
	data.status = pkt:GetLenString()						-- 游戏状态
	data.remain_ti = pkt:GetLong()							-- 剩余时间，在 "running" 阶段使用
	data.cur_round = pkt:GetChar()							-- 当前回合数
	data.cur_oper_gid = pkt:GetLenString()					-- 当前玩家 GID
	data.corp_count = pkt:GetChar()							-- 阵营数量
	data.corps_info = {}
	for i = 1, data.corp_count do
		data.corps_info[i] = {}
		data.corps_info[i].corp = pkt:GetChar()				-- 阵营
		data.corps_info[i].icon = pkt:GetLong()				-- 头像
		data.corps_info[i].name = pkt:GetLenString()		-- 名字
		data.corps_info[i].level = pkt:GetShort()			-- 等级
		data.corps_info[i].gid = pkt:GetLenString()			-- 玩家 GID
		data.corps_info[i].action_point = pkt:GetShort()	-- 行动力
		data.corps_info[i].prepared = pkt:GetChar()			-- 准备状态 1 已准备，0 未准备。
	end

	data.board_count = pkt:GetChar()						-- 棋牌上的格子数量，正常为 36 不会变
	data.board_info = {}

	for i = 1, data.board_count do
		data.board_info[i] = {}
		data.board_info[i].corp = pkt:GetChar()
		data.board_info[i].type = pkt:GetChar()				-- 宠物蛋类型 1、2、3、4、5、6、7、8、9 分别对应文档中的宠物蛋类型, 0 表示当前位置啥都没有, 10 表示只是一个蛋
		data.board_info[i].state = pkt:GetChar()			-- 宠物蛋状态, 0 表示未打开状态, 1 表示透明状态, 2 表示宠物状态；状态切换为：0->1 或 0->2 或者 1->2

		--[[
		// 以上两个参数结合使用，
		// 当位置上没有蛋也没有宠物时： state=4, type=0，
		// 蛋： state=0, type=10,
		// 透明蛋:  state=1, type=1-9,
		// 宠物： state=2, type=1-6,
		-]]
	end
end

function MsgParser:MSG_SUMMER_2019_SXDJ_OPERATOR(pkt, data)
	data.cur_round = pkt:GetChar()							-- 当前回合数
	data.cur_oper_gid = pkt:GetLenString()						-- 操作玩家 GID
	data.remain_ti = pkt:GetLong()
end

function MsgParser:MSG_SUMMER_2019_SXDJ_DO_ACTION(pkt, data)
	data.type = pkt:GetChar()						-- 动作类型
	data.cur_round = pkt:GetChar()						-- 动作类型
	--[[
// 1 打开（para1为子类型，1 标识炸弹，2 标识火眼金睛，3 标识宠物，4 标识空，在 para1 为炸弹和火眼金睛时，para2 标识生效的位置索引、显示的物品和状态，格式：23,5，23 表示位置索引，5 表示物品与 type 定义相同）,
// 2 移动（para1 目标位置，para2动作类型 1 标识移动 2 标识吃））
	--]]
	data.index = pkt:GetChar()						-- 动作位置的索引，与上面格子发送顺序一致
	data.para1 = pkt:GetLenString()
	data.para2 = pkt:GetLenString()
end

function MsgParser:MSG_SUMMER_2019_SXDJ_CHANGE_STATUS(pkt, data)
	data.status = pkt:GetLenString()						-- 操作玩家 GID
end

function MsgParser:MSG_SUMMER_2019_SXDJ_BONUS(pkt, data)
	data.result = pkt:GetChar()
	data.bonus_num = pkt:GetChar()
	for i = 1, data.bonus_num do
		local type = pkt:GetLenString()
		data[type] = pkt:GetLenString()
	end
end

function MsgParser:MSG_CSML_FETCH_BONUS(pkt, data)
	self:MSG_CSL_FETCH_BONUS(pkt, data)
end

-- 文曲星 - 问题信息

function MsgParser:MSG_WQX_QUESTION_DATA(pkt, data)
	data.stage = pkt:GetLenString()					-- 第几关，取值：verify、stage_1、stage_2、stage_3
	data.question_no = pkt:GetChar()				-- 第几题，取值1-3
	data.question = pkt:GetLenString()				-- 题目
	data.answer_count = pkt:GetShort()
	data.answers = {}
	for i = 1, data.answer_count do
		data.answers[i] = {}
		data.answers[i].text = pkt:GetLenString()
	end

	data.ret = pkt:GetLenString()				-- 题目

	data.help_times_count = pkt:GetShort()
	for i = 1, data.answer_count do					-- data.answer_count 和 data.help_times_count 是一样的
		data.answers[i].help_times = pkt:GetChar()
	end
	data.start_time = pkt:GetLong()					-- 答题结束时间
	data.end_time = pkt:GetLong()					-- 答题结束时间
	data.item_qz = pkt:GetChar()					-- 求助卡数量
	data.item_ts = pkt:GetChar()					-- 探索卡数量
	data.item_js = pkt:GetChar()					-- 加时卡数量
	data.removed_item = pkt:GetLenString()			-- 使用探索卡被排除的选项
	data.is_use_help = pkt:GetChar()				-- 是否使用了求助卡、
	data.has_verify = pkt:GetChar()					-- 是否开启验证
end

--(string stage, BOOL success, string bonus_desc);
function MsgParser:MSG_WQX_STAGE_RESULT(pkt, data)
	data.stage = pkt:GetLenString()					-- 第几关，取值：verify、stage_1、stage_2、stage_3
	data.success = pkt:GetChar()
	data.bonus_desc = pkt:GetLenString()
	data.end_time = pkt:GetLong()					-- 答题结束时间
end

-- (string char_gid, string help_id, string question, string items[], int32 end_time);
function MsgParser:MSG_WQX_HELP_QUESTION_DATA(pkt, data)
	data.char_gid = pkt:GetLenString()					-- 第几关，取值：verify、stage_1、stage_2、stage_3
	data.help_id = pkt:GetLenString()
	data.question = pkt:GetLenString()
	data.answers = {}
	data.answer_count = pkt:GetShort()
	for i = 1, data.answer_count do
		data.answers[i] = {}
		data.answers[i].text = pkt:GetLenString()
	end
	data.end_time = pkt:GetLong()					-- 答题结束时间
end

function MsgParser:MSG_PET_EXPLORE_OPEN_DLG(pkt, data)
end

function MsgParser:MSG_PET_EXPLORE_ALL_PET_DATA(pkt, data)
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.pet_id = pkt:GetLong()
        tmpInfo.in_explore = pkt:GetChar() == 1
        tmpInfo.skill_count = pkt:GetShort()
        tmpInfo.skill_list = {}
        for j = 1, tmpInfo.skill_count do
            local skillInfo = {}
            skillInfo.skill_id = pkt:GetChar()
            skillInfo.skill_level = pkt:GetChar()
            skillInfo.exp = pkt:GetShort()
            tmpInfo.skill_list[j] = skillInfo
        end

        data.list[i] = tmpInfo
    end
end

function MsgParser:MSG_PET_EXPLORE_ONE_PET_DATA(pkt, data)
    data.pet_id = pkt:GetLong()
    data.in_explore = pkt:GetChar() == 1
    data.skill_count = pkt:GetShort()
    data.skill_list = {}
    for i = 1, data.skill_count do
        local skillInfo = {}
        skillInfo.skill_id = pkt:GetChar()
        skillInfo.skill_level = pkt:GetChar()
        skillInfo.exp = pkt:GetShort()
        data.skill_list[i] = skillInfo
    end
end

function MsgParser:MSG_PET_EXPLORE_ALL_ITEM_DATA(pkt, data)
    data.count = pkt:GetShort()
    data.list = {}
    for i = 1, data.count do
        local tmpInfo = {}
        tmpInfo.item_id = pkt:GetChar()
        tmpInfo.num = pkt:GetShort()
        data.list[i] = tmpInfo
    end
end

function MsgParser:MSG_PET_EXPLORE_MAP_BASIC_DATA(pkt, data)
    data.cookie = pkt:GetLong()
    data.explore_time = pkt:GetChar()
    data.map_refresh_count = pkt:GetChar()
end

function MsgParser:MSG_PET_EXPLORE_ONE_MAP_DATA(pkt, data)
    data.cookie = pkt:GetLong()
    data.map_index = pkt:GetChar()
    data.degree = pkt:GetChar()
    data.map_name = pkt:GetLenString()
    data.map_icon = pkt:GetLong()
    data.bonus_desc = pkt:GetLenString()
    data.need_ti = pkt:GetShort()
    data.status = pkt:GetChar()
    data.map_id = pkt:GetChar()
    data.start_time = pkt:GetLong()
end

function MsgParser:MSG_PET_EXPLORE_MAP_PET_DATA(pkt, data)
    data.cookie = pkt:GetLong()
    data.map_index = pkt:GetChar()
    data.is_stop = pkt:GetChar()
    data.pet_count = pkt:GetShort()
    data.pet_list = {}
    for i = 1, data.pet_count do
        local tmpInfo = {}
        tmpInfo.pet_index = pkt:GetChar()
        tmpInfo.pet_iid = pkt:GetLenString()
        tmpInfo.name = pkt:GetLenString()
        tmpInfo.key_name = pkt:GetLenString()
        tmpInfo.level = pkt:GetShort()
        tmpInfo.martial = pkt:GetLong()
        tmpInfo.longevity = pkt:GetLong()
        tmpInfo.intimacy = pkt:GetLong()
        tmpInfo.skill_count = pkt:GetShort()
        tmpInfo.skill_list = {}
        for j = 1, tmpInfo.skill_count do
            local skillInfo = {}
            skillInfo.skill_id = pkt:GetChar()
            skillInfo.skill_level = pkt:GetChar()
            skillInfo.exp = pkt:GetShort()
            tmpInfo.skill_list[j] = skillInfo
        end

        data.pet_list[i] = tmpInfo
    end
end

function MsgParser:MSG_PET_EXPLORE_MAP_CONDITION_DATA(pkt, data)
    data.cookie = pkt:GetLong()
    data.map_index = pkt:GetChar()
    data.is_stop = pkt:GetChar()
    data.succ_rule_count = pkt:GetShort()
    data.succ_rule_list = {}
    for i= 1, data.succ_rule_count do
        local tmpInfo = {}
        tmpInfo.id = pkt:GetChar()
        data.succ_rule_list[i] = tmpInfo
    end

    data.big_succ_rule_count = pkt:GetShort()
    data.big_succ_rule_list = {}
    for i = 1, data.big_succ_rule_count do
        local tmpInfo = {}
        tmpInfo.id = pkt:GetChar()
        data.big_succ_rule_list[i] = tmpInfo
    end

    data.succ_rate = 0
    pkt:GetShort()
    for i= 1, data.succ_rule_count do
        data.succ_rule_list[i].rate = pkt:GetChar()
        data.succ_rule_list[i].para1 = pkt:GetSignedLong()
        data.succ_rule_list[i].para2 = pkt:GetSignedLong()
        data.succ_rate = data.succ_rate + data.succ_rule_list[i].rate
    end

    data.big_succ_rate = 0
    data.max_big_succ_rate = 0
    pkt:GetShort()
    for i = 1, data.big_succ_rule_count do
        data.big_succ_rule_list[i].rate = pkt:GetChar()
        data.big_succ_rule_list[i].max_rate = pkt:GetChar()
        data.big_succ_rule_list[i].para1 = pkt:GetSignedLong()
        data.big_succ_rule_list[i].para2 = pkt:GetSignedLong()
        data.big_succ_rate = data.big_succ_rate + data.big_succ_rule_list[i].rate
        data.max_big_succ_rate = data.max_big_succ_rate + data.big_succ_rule_list[i].max_rate
    end
end

function MsgParser:MSG_PET_EXPLORE_START(pkt, data)
end

function MsgParser:MSG_PET_EXPLORE_BONUS(pkt, data)
    data.result = pkt:GetChar()
    data.bonus_num = pkt:GetShort()
    data.bonus_list = {}
    for i = 1, data.bonus_num do
        local tmpInfo = {}
        tmpInfo.pet_name = pkt:GetLenString()
        tmpInfo.bonus_type = pkt:GetLenString()
        tmpInfo.desc = pkt:GetLenString()
        data.bonus_list[i] = tmpInfo
    end

    data.item_id = tonumber(pkt:GetLenString())
    data.item_desc = pkt:GetLenString()
    data.bonus_type = pkt:GetLenString()
    data.bonus_desc = pkt:GetLenString()
end

-- 通知场景信息
function MsgParser:MSG_XCWQ_DATA(pkt, data)
    data.end_time = pkt:GetLong()  -- 活动截止时间
    data.guaji_reward_cou = pkt:GetLong()  -- 本周挂机奖励次数
    data.hudong_reward_cou = pkt:GetLong()  -- 本周互动奖励次数
    data.beidong_reward_cou = pkt:GetLong()   -- 本周被动奖励次数
    data.water_temp = pkt:GetChar()        -- 水温数值
    data.player_name = pkt:GetLenString()  -- 使用玉露精华的玩家名称（若无人使用则为空）
    data.player_gid = pkt:GetLenString()
end

-- 广播捶背动作
function MsgParser:MSG_XCWQ_MASSAGE_BACK(pkt, data)
    data.from_id = pkt:GetLong()  -- 捶背角色 id
    data.to_id = pkt:GetLong()  -- 被捶背角色 id
end

-- 广播丢肥皂动作
function MsgParser:MSG_XCWQ_THROW_SOAP(pkt, data)
    data.from_id = pkt:GetSignedLong()  -- 执行者 id
    data.to_id = pkt:GetSignedLong()    -- 目标 id （目标不存在则为-1）
    data.to_x = pkt:GetShort()    -- 目标 x 坐标
    data.to_y = pkt:GetShort()    -- 目标 y 坐标
end

-- 通知动作失败（客户端解除移动限制）
function MsgParser:MSG_XCWQ_ACTION_FAIL(pkt, data)
    data.cookie = pkt:GetLong()  -- 动作 cookie
end

-- 通知客户端互动信息（按时间由早到晚）
function MsgParser:MSG_XCWQ_RECORD(pkt, data)
    data.att_count = pkt:GetShort()
    data.att_info = {}
    for i = 1, data.att_count do
        local info = {}
        info.type = pkt:GetChar()             -- 类型（1表示捶背，2表示丢肥皂）
        info.player_name = pkt:GetLenString() -- 玩家名称
        info.player_gid = pkt:GetLenString()
        table.insert(data.att_info, info)
    end

    data.def_count = pkt:GetShort()
    data.def_info = {}
    for i = 1, data.def_count do
        local info = {}
        info.type = pkt:GetChar()             -- 类型（1表示捶背，2表示丢肥皂）
        info.player_name = pkt:GetLenString() -- 玩家名称
        info.player_gid = pkt:GetLenString()
        table.insert(data.def_info, info)
    end
end

-- 通知单次互动信息（只对互动双方发送）
function MsgParser:MSG_XCWQ_ONE_RECORD(pkt, data)
    data.type = pkt:GetChar()             -- 类型（1表示捶背，2表示丢肥皂）
    data.from_name = pkt:GetLenString() -- 发起方名称
    data.from_gid = pkt:GetLenString()
    data.to_name = pkt:GetLenString() -- 目标方名称
    data.to_gid = pkt:GetLenString()
end

-- 通知打开玉露精华界面
function MsgParser:MSG_XCWQ_OPEN_YLJH_DLG(pkt, data)
    data.coin = pkt:GetLong()  -- 花费元宝数
end

-- 通知房间玩家播放特效
function MsgParser:MSG_USE_YLJH(pkt, data)
    data.name = pkt:GetLenString()
end

-- 通知灵尘商店信息
function MsgParser:MSG_LINGCHEN_DATA(pkt, data)
    data.isOpen = pkt:GetChar() -- 是否强制打开
    data.count = pkt:GetShort()  -- 花费元宝数
    for i = 1, data.count do
        local info = {}
        info.name = pkt:GetLenString() -- 道具名称
        info.num = pkt:GetChar() -- 道具可购买数量
        info.cost = pkt:GetLong() -- 道具价格
        table.insert(data, info)
    end
end

-- 通知分解结果
function MsgParser:MSG_DECOMPOSE_ITEM_RESULT(pkt, data)
    data.result = pkt:GetChar() -- 成功为1，失败为0
end

-- 通知游戏数据
function MsgParser:MSG_SUMMER_2019_XZJS_DATA(pkt, data)
    data.start_time = pkt:GetLong() -- 比赛开始时间，显示倒计时
    data.total_distance = pkt:GetLong() --总长度（像素）
    data.count = pkt:GetShort()
    data.ship_info = {}
    for i = 1, data.count do
        local info = {}
        info.no = pkt:GetChar()   -- 小船编号
        info.name = pkt:GetLenString()
        info.icon = pkt:GetLong()
        data.ship_info[info.no] = info
    end
end

-- 通知游戏帧数据
function MsgParser:MSG_SUMMER_2019_XZJS_FRAME(pkt, data)
    data.seq = pkt:GetLong() -- 第几帧
    data.frame_interval = pkt:GetLong() -- 距离上一帧的时间可能大于 MSG_SUMMER_2018_CHIGUA_DATA 中的帧间隔
    data.count = pkt:GetShort()
    data.frame_info = {}
    for i = 1, data.count do
        local info = {}
        info.no = pkt:GetChar()   -- 小船编号
        info.from_distance = pkt:GetLong() -- 本帧起跑点(浮点数 * 1000000)
        info.to_distance = pkt:GetLong()   -- 本帧目标点
        info.effect_type = pkt:GetSignedChar()   -- 光效类型（-1表示减速光效、0表示无光效、1表示加速光效）
        data.frame_info[info.no] = info
    end

    data.has_time = pkt:GetLong() -- 耗时（秒）
end

-- 通知客户端当前执行指令状态（指令重刷或重连时发送）
function MsgParser:MSG_SUMMER_2019_XZJS_OPERATE(pkt, data)
    data.no = pkt:GetLong()   -- 指令编号
    data.left_time = pkt:GetChar() -- 下次指令更新时间
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local info = {}
        info.dir = pkt:GetChar()    -- 指令类型（1-4分别表示4个方向）
        info.status = pkt:GetChar() -- 指令状态（0表示未点击，1表示正确，2表示失败）
        table.insert(data, info)
    end

    data.total_time = pkt:GetChar()
end

-- 通知游戏结果
function MsgParser:MSG_SUMMER_2019_XZJS_RESULT(pkt, data)
    data.rank = pkt:GetSignedChar() -- 名次（1-3表示不同名次，0表示中途退出，-1表示活动结束强制退出）
    data.reward_type = pkt:GetLenString() -- 奖励类型("exp"、"tao"，若无奖励则为空)
    data.num = pkt:GetLong() -- 奖励数值
    data.has_time = pkt:GetLong() -- 耗时（秒）
end

function MsgParser:MSG_SUMMER_2019_SXDJ_FAIL(pkt, data)
    data.round = pkt:GetChar()    -- 回合
	data.oper = pkt:GetChar()    -- 操作
end

function MsgParser:MSG_OPEN_TO_TIP_MOUNT(pkt, data)
    data.pet_id = pkt:GetLong()
end

-- 通知客户端播放夫妻之礼动画
function MsgParser:MSG_HOUSE_SEX_LOVE_ANIMATE(pkt, data)
    data.furniture_pos = pkt:GetLong()
    data.start_time = gf:getServerTime()-- pkt:GetLong()
end

-- 通知娃娃界面信息
function MsgParser:MSG_CHILD_INFO(pkt, data)
	data.isForceOpen = pkt:GetChar()	-- 是否强制打开
	data.selectId = pkt:GetLenString() 				-- 娃娃 id
    data.homeworkCount = pkt:GetShort() -- 可执行家务的数量
    data.homeworkList = {}
    for i = 1, data.homeworkCount do
        data.homeworkList[i] = {}
        data.homeworkList[i].type = pkt:GetChar()       -- 家务类型
        data.homeworkList[i].leftTimes = pkt:GetChar()   -- 家务剩余可完成次数
    end

    data.count = pkt:GetShort()			-- 娃娃数量
	data.childInfo = {}
	for i = 1, data.count do
		data.childInfo[i] = {}
		data.childInfo[i].id = pkt:GetLenString() 				-- 娃娃 id
		data.childInfo[i].stage = pkt:GetChar() 				-- 娃娃阶段（1表示胎儿，2表示灵石）
		data.childInfo[i].name = pkt:GetLenString() 			-- 娃娃名字
		data.childInfo[i].gender = pkt:GetChar() 				-- 性别
        data.childInfo[i].family = pkt:GetChar() 				-- 门派
        data.childInfo[i].vitality = pkt:GetChar() 				-- 体力值
		data.childInfo[i].mature = pkt:GetLong() 				-- 成熟度
		data.childInfo[i].health = pkt:GetLong() 				-- 健康度
		data.childInfo[i].feed = pkt:GetLong() 					-- 饱食度
		data.childInfo[i].clean = pkt:GetLong() 				-- 清洁度
		data.childInfo[i].happy = pkt:GetLong() 				-- 心情度
		data.childInfo[i].fatigue = pkt:GetLong() 				-- 疲劳度
		data.childInfo[i].intimacy = pkt:GetLong() 				-- 亲密度
		data.childInfo[i].isRenamed = pkt:GetChar() 			-- 是否改名过
		data.childInfo[i].isSleep = pkt:GetChar() 				-- 是否睡觉
		data.childInfo[i].healthStage = pkt:GetChar() 			-- 健康状况 （0表示正常，1表示生病，2表示失眠）
		data.childInfo[i].isNeedCare = pkt:GetChar() 			-- 是否需要照顾
		data.childInfo[i].destroyTime = pkt:GetLong() 				-- int32，销毁截止时间（0表示未销毁，否则表示销毁时间）（新增）
		data.childInfo[i].money = pkt:GetLong() 				-- 金钱
		data.childInfo[i].wuxing = pkt:GetChar() 			-- 悟性
		data.childInfo[i].xingge = pkt:GetChar() 			-- 性格
		data.childInfo[i].phy_power = pkt:GetLong() 			-- 物攻成长
		data.childInfo[i].mag_power = pkt:GetLong() 			-- 法攻成长
		data.childInfo[i].speed = pkt:GetLong() 				-- 速度成长
		data.childInfo[i].mana = pkt:GetLong() 					-- 法力
		data.childInfo[i].life = pkt:GetLong() 					-- 血量
		data.childInfo[i].task_name = pkt:GetLenString() 			-- 今日任务名称(新增)
		data.childInfo[i].task_stage = pkt:GetChar() 				-- 任务状态，0表示未领取，1表示已领取，2表示已完成(新增)
		data.childInfo[i].task_owner = pkt:GetLenString()
		data.childInfo[i].daofa = pkt:GetLong() 					-- 道法残卷(新增)
		data.childInfo[i].xinfa = pkt:GetLong() 					-- 心法残卷(新增)
	end
end

-- 通知娃娃日志信息
function MsgParser:MSG_CHILD_LOG(pkt, data)
    data.id = pkt:GetLenString()			-- 娃娃 id
	data.count = pkt:GetShort()				-- 日志数量
	data.logInfo = {}
	for i = 1, data.count do
		data.logInfo[i] = {}
		data.logInfo[i].ti = pkt:GetLong() 						-- 日志时间
		data.logInfo[i].template = pkt:GetChar() 				-- 日志模板
		data.logInfo[i].para = pkt:GetLenString() 				-- 模板参数1（目前最多只会用到一个参数，将来根据需求再调整）
		data.logInfo[i].para2 = pkt:GetLenString() 				-- 模板参数1（目前最多只会用到一个参数，将来根据需求再调整）
		data.logInfo[i].para3 = pkt:GetLenString() 				-- 模板参数1（目前最多只会用到一个参数，将来根据需求再调整）
	end
end

-- 通知播放唱歌动画
function MsgParser:MSG_CHILD_SING(pkt, data)
	data.singer = pkt:GetLenString()			-- 唱歌者 id
	data.listening = pkt:GetLenString()			-- 被唱歌者 id
end

function MsgParser:MSG_CHILD_INJECT_ENERGY(pkt, data)
	data.furniture_no = pkt:GetLong()				-- 家具编号
	data.x = pkt:GetShort() 				--
	data.y = pkt:GetShort() 				--
end

function MsgParser:MSG_CHILD_BIRTH_INFO(pkt, data)
	data.stage = pkt:GetChar()					-- 类型
	data.process = pkt:GetChar()				-- 生产进度
	data.isShowChatButton = pkt:GetChar()		-- 是否夫妻共同生成，共同生成需要显示按钮
	data.endTime = pkt:GetLong() 				-- 结束时间
	data.count = pkt:GetShort() 				-- 生产信息数目
	data.productionInfo = {}
	for i = 1, data.count do
		data.productionInfo[i] = {}
		data.productionInfo[i].content = pkt:GetLenString()	-- 生产信息
		data.productionInfo[i].isEffect = pkt:GetChar()	-- 生产信息
	end
end

-- 通知丈夫生产数据
function MsgParser:MSG_CHILD_BIRTH_HUSBAND_INFO(pkt, data)
	data.water_stage = pkt:GetChar()							-- 打水状态（0表示不需要打水，1表示等待打水，2表示打水返回）
	data.home_id = pkt:GetLenString()
	data.room = pkt:GetLenString()			-- 被唱歌者 id
    data.x = pkt:GetShort() 				-- 健康度
	data.y = pkt:GetShort() 				-- 健康度
end

-- 通知生产结果
function MsgParser:MSG_CHILD_BIRTH_RESULT(pkt, data)
	data.result = pkt:GetChar()							-- （1表示成功，0表示失败）
	data.id = pkt:GetLenString()
end


-- 通知客户端寻路到灵石旁并选择灵胎出世
function MsgParser:MSG_CHILD_BIRTH_STONE(pkt, data)
	self:MSG_CHILD_INJECT_ENERGY(pkt, data)
end

function MsgParser:MSG_CHILD_BIRTH_ANIMATE(pkt, data)
	data.isPlay = pkt:GetChar()  -- 1 开始， 2 停止
	data.id = pkt:GetLong()
    data.furniture_pos = pkt:GetLong()     -- 1 单人，2双人
end

-- 通知娃娃抚养信息
function MsgParser:MSG_CHILD_RAISE_INFO(pkt, data)
    data.update_time = pkt:GetLong()   -- 需要强制刷新的日期0点（新增）
    data.para = pkt:GetLenString()
	data.id = pkt:GetLenString()
	data.name = pkt:GetLenString()
	data.feed = pkt:GetLong() 					-- 饱食度
	data.clean = pkt:GetLong() 				-- 清洁度
	data.happy = pkt:GetLong() 				-- 心情度
	data.health = pkt:GetLong() 				-- 健康度
	data.fatigue = pkt:GetLong() 				-- 疲劳度
	data.healthStage = pkt:GetChar() 			-- 悟性
	data.wuxing = pkt:GetChar() 			-- 悟性
	data.xingge = pkt:GetChar() 			-- 性格
	data.gender = pkt:GetChar()  				-- 性别
	data.icon = pkt:GetLong()
	data.destroyTime = pkt:GetLong()		-- 销毁截止时间（0表示未销毁，否则表示销毁时间）（新增）
	data.mature = pkt:GetLong() 				-- 成熟度、成长度
	data.phy_power = pkt:GetLong()					--
	data.mag_power = pkt:GetLong()					--
	data.speed = pkt:GetLong()					--
	data.life = pkt:GetLong()					--
	data.mana = pkt:GetLong()					--

	data.money = pkt:GetLong()					-- 娃娃金库
	data.history_sch_count = 1

	data.fy_data = {}
	data.fy_count = pkt:GetShort()				-- 抚养操作数目
	for i = 1, data.fy_count do
		data.fy_data[i] = {}
		data.fy_data[i].op_type = pkt:GetChar()	-- 抚养操作类型
		data.fy_data[i].cd_end_time = pkt:GetLong()	-- CD 结束时间
	end

	data.special_sch_data = {}
	data.special_sch_count = pkt:GetShort()			-- 特殊行程数目（有次数限制的行程）
	for i = 1, data.special_sch_count do
		local sch_type = pkt:GetChar()
		data.special_sch_data[sch_type] = {}
		data.special_sch_data[sch_type].sch_type = sch_type			-- 行程类型
		data.special_sch_data[sch_type].cur_times = pkt:GetLong()	-- 当前次数
	end

	data.today_sch_cookie = pkt:GetLong()					-- 今日行程 cookie（cookie 大于 0，表示已安排过）
	data.today_sch_count = pkt:GetShort()					-- int16，今日行程数目
	data.today_sch_data = {}
	for i = 1, data.today_sch_count do
		data.today_sch_data[i] = {}
		data.today_sch_data[i].start_time = pkt:GetLong()		-- 开始时间
		data.today_sch_data[i].sch_type = pkt:GetChar()		-- int8，行程类型
		data.today_sch_data[i].isClose = pkt:GetChar()		-- int8，是否结算
	end

	data.tomorrow_sch_cookie = pkt:GetLong()					-- 今日行程 cookie（cookie 大于 0，表示已安排过）
	data.tomorrow_sch_count = pkt:GetShort()					-- int16，今日行程数目
	data.tomorrow_sch_data = {}
	for i = 1, data.tomorrow_sch_count do
		data.tomorrow_sch_data[i] = {}
		data.tomorrow_sch_data[i].start_time = pkt:GetLong()		-- 开始时间
		data.tomorrow_sch_data[i].sch_type = pkt:GetChar()		-- int8，行程类型
		data.tomorrow_sch_data[i].isClose = pkt:GetChar()		-- int8，是否结算
	end
end

function MsgParser:MSG_CHILD_SCHEDULE(pkt, data)
	data.id = pkt:GetLenString()
	data.name = pkt:GetLenString()
	data.wuxing = pkt:GetChar()	-- 悟性
	data.xingge = pkt:GetChar()	-- 性格
	data.mature = pkt:GetLong()	-- 性格
	data.sch_data = {}
	data.sch_count = pkt:GetShort()					-- int16，今日行程数目
	for i = 1, data.sch_count do
		data.sch_data[i] = {}
		data.sch_data[i].time = pkt:GetLong()	-- 行程时间
		data.sch_data[i].sch_type = pkt:GetChar()	-- 行程类型
		data.sch_data[i].para1 = pkt:GetLenString()	-- 行程变量1
		data.sch_data[i].para2 = pkt:GetLenString()	-- 行程变量2
		data.sch_data[i].para3 = pkt:GetLenString()	-- 行程变量3
	end
end

function MsgParser:MSG_START_COMMON_PROGRESS(pkt, data)
	data.process_time = pkt:GetLong()
	data.type = pkt:GetLenString()
	data.para = pkt:GetLenString()
end

-- 通知行程检测结果
function MsgParser:MSG_CHILD_CHECK_SCHEDULE_RESULT(pkt, data)
	data.id = pkt:GetLenString()
	data.startTime = pkt:GetLong()
	data.sch_type = pkt:GetChar()
	data.result = pkt:GetChar()
	data.para = pkt:GetLenString()
end

function MsgParser:MSG_CHILD_CHECK_CHANGE_SCHEDULE_RET(pkt, data)
	data.id = pkt:GetLenString()			-- 娃娃 id
	data.record_time = pkt:GetLong()		-- ，行程所在日0点
	data.isCanModify = pkt:GetChar()			-- 是否可修改
end

function MsgParser:MSG_PLAY_EFFECT_DIGIT(pkt, data)
	data.attrStr = pkt:GetLenString()			--	疲劳度(fatigue)，饱食度(satiation)，心情度(mood)，清洁度(cleanliness)
	data.value = pkt:GetLong()				-- 数值
end

function MsgParser:MSG_CHILD_POSITION(pkt, data)
	data.child_id = pkt:GetLenString()				-- 居所 id
	data.type = pkt:GetChar()						--	1表示在房屋摇篮，2表示在前庭NPC
	data.home_id = pkt:GetLenString()				-- 居所 id
	data.map_name = pkt:GetLenString()				-- 房间名称
	data.furniture_pos = pkt:GetLong()				-- 居所摇篮编号
	data.npc_id = pkt:GetLong()				-- 居所摇篮编号
	data.x = pkt:GetLong()
	data.y = pkt:GetLong()
end

function MsgParser:MSG_CHILD_LIST(pkt, data)
	data.count = pkt:GetShort()
	data.childInfo = {}
	for i = 1, data.count do
		data.childInfo[i] = {}
		data.childInfo[i].id = pkt:GetLenString()		-- 娃娃 id
		data.childInfo[i].name = pkt:GetLenString()		-- 娃娃名称
		data.childInfo[i].icon = pkt:GetLong()			-- 娃娃icon
		data.childInfo[i].gender = pkt:GetChar()			-- 娃娃icon
		data.childInfo[i].mature = pkt:GetLong()		-- 娃娃成长度（婴幼儿期有效）
		data.childInfo[i].stage = pkt:GetChar()			-- 娃娃阶段
		data.childInfo[i].intimacy = pkt:GetLong()		-- 亲密
		data.childInfo[i].life = pkt:GetLong()			-- 血量成长
		data.childInfo[i].mana = pkt:GetLong()			-- 法力成长
		data.childInfo[i].speed = pkt:GetLong()			-- 速度成长
		data.childInfo[i].phy_power = pkt:GetLong()		-- 物攻成长
		data.childInfo[i].mag_power = pkt:GetLong()		-- 法攻成长
		data.childInfo[i].money = pkt:GetLong()			-- 成长金库
        data.childInfo[i].isFollow = pkt:GetChar()			-- 是否跟随
	end
end

function MsgParser:MSG_PLAY_EFFECT(pkt, data)
    data.name = pkt:GetLenString()
end

function MsgParser:MSG_CHILD_MONEY(pkt, data)
    data.id = pkt:GetLenString()		-- 娃娃 id
	data.name = pkt:GetLenString()
	data.money = pkt:GetLong()
end

function MsgParser:MSG_GOOD_VOICE_SHOW_LIST(pkt, data)
    data.list_type = pkt:GetChar()			-- 0 发现声音		1 人气声音		2 今日新声		3 搜索声音		(CMD_GOOD_VOICE_SEARCH消息，也会返回MSG_GOOD_VOICE_SHOW_LIST结果，其中list_type为该值)
	data.count = pkt:GetShort()
	data.voiceShowData = {}
	for i = 1, data.count do
		data.voiceShowData[i] = {}
		--[[
		local ids = pkt:GetLenString()
		local idsTab = gf:split(ids, "|")
		data.voiceShowData[i].dist = idsTab[1]
		data.voiceShowData[i].hoster_gid = idsTab[2]
		data.voiceShowData[i].voice_id = idsTab[3]
		--]]
		data.voiceShowData[i].voice_id = pkt:GetLenString()
		data.voiceShowData[i].name = pkt:GetLenString()
		data.voiceShowData[i].img_str = pkt:GetLenString()
		data.voiceShowData[i].voice_title = pkt:GetLenString()
		data.voiceShowData[i].popular = pkt:GetLong()
	end
end

-- string id, string gid, string name, int16 icon, int16 level, string img_str, string voice_title, string voice_desc, int8 voice_dur, int32 popular
function MsgParser:MSG_GOOD_VOICE_QUERY_VOICE(pkt, data)
	data.voice_id = pkt:GetLenString()

	local idsTab = gf:split(data.voice_id, "|")
	data.dist = idsTab[1]

	data.gid = pkt:GetLenString()
	data.name = pkt:GetLenString()
	data.icon = pkt:GetShort()
	data.level = pkt:GetShort()
	data.img_str = pkt:GetLenString()
	data.voice_title = pkt:GetLenString()
	data.voice_desc = pkt:GetLenString()

	data.voice_addr = pkt:GetLenString()

	data.voice_dur = pkt:GetChar()
	data.popular = pkt:GetLong()

	data.open_type = pkt:GetChar()
end

-- string voice_id, int8 is_favorite
function MsgParser:MSG_GOOD_VOICE_COLLECT(pkt, data)
	data.count = pkt:GetShort()
	for i = 1, data.count do
		local id = pkt:GetLenString()
		data[id] = 1
	end
end

function MsgParser:MSG_GOOD_VOICE_SEASON_DATA(pkt, data)
	data.season_no = pkt:GetShort()
	if pkt:GetDataLen() then
	data.theme_name = pkt:GetLenString()
	data.upload_start = pkt:GetLong()		-- 上传阶段时间
	data.upload_end = pkt:GetLong()
	data.canvass_start = pkt:GetLong()		-- 声援阶段时间
	data.canvass_end = pkt:GetLong()
	data.primary_election_start = pkt:GetLong()		-- 初选阶段时间
	data.primary_election_end = pkt:GetLong()
	data.final_election_start = pkt:GetLong()		-- 总选阶段时间
	data.final_election_end = pkt:GetLong()
	else
		data.theme_name = ""
		data.upload_start = 0
		data.upload_end = 0
		data.canvass_start = 0
		data.canvass_end = 0
		data.primary_election_start = 0
		data.primary_election_end = 0
		data.final_election_start = 0
		data.final_election_end = 0
end
end

function MsgParser:MSG_GOOD_VOICE_MY_VOICE(pkt, data)
-- void msg_good_voice_my_voice(string voice_id, int8 has_review_pass, int8 carnation_num);;
	data.voice_id = pkt:GetLenString()
	data.has_review_pass = pkt:GetChar()	-- 是否通过评审
	data.carnation_num = pkt:GetChar()		-- 康乃馨数量
end

function MsgParser:MSG_GOOD_VOICE_FINAL_VOICES(pkt, data)
	data.day_index = pkt:GetChar()
	data.public_time = pkt:GetLong()
	data.is_judge = pkt:GetChar()	-- 是否通过评审
	data.count = pkt:GetShort()
	data.voiceData = {}
	for i = 1, data.count do
		data.voiceData[i] = {}
		data.voiceData[i].id = pkt:GetLenString()
		data.voiceData[i].voice_title = pkt:GetLenString()
		data.voiceData[i].icon_img = pkt:GetLenString()
		data.voiceData[i].score = pkt:GetSignedChar()
		data.voiceData[i].name = pkt:GetLenString()
		data.voiceData[i].voice_addr = pkt:GetLenString()
	end
end

function MsgParser:GOOD_VOICE_FINAL_SHOW_DATA_FOR_JUDGE(pkt, data)
	data.count = pkt:GetShort()
	data.voiceData = {}
	for i = 1, data.count do
		data.voiceData[i] = {}
		data.voiceData[i].id = pkt:GetLenString()
		data.voiceData[i].voice_title = pkt:GetLenString()
		data.voiceData[i].icon_img = pkt:GetLenString()
		data.voiceData[i].score = pkt:GetSignedChar()
		data.voiceData[i].name = pkt:GetLenString()
		data.voiceData[i].voice_addr = pkt:GetLenString()
		data.voiceData[i].comment = pkt:GetLenString()
	end
end

function MsgParser:MSG_GOOD_VOICE_JUDGES(pkt, data)
	data.count = pkt:GetShort()
	data.judes_for_nomal = {}
	for i = 1, data.count do
		data.judes_for_nomal[i] = {}
		data.judes_for_nomal[i].name = pkt:GetLenString()
		data.judes_for_nomal[i].desc = pkt:GetLenString()
		data.judes_for_nomal[i].icon_img = pkt:GetLenString()
	end
end

function MsgParser:MSG_GOOD_VOICE_SCORE_DATA(pkt, data)
	data.voice_id = pkt:GetLenString()
	data.voice_title = pkt:GetLenString()
	data.basic_score = pkt:GetChar()
	data.total_score = pkt:GetSignedChar()
	data.count = pkt:GetShort()
	data.scoreData = {}
	for i = 1, data.count do
		data.scoreData[i] = {}
		data.scoreData[i].icon_img = pkt:GetLenString()
		data.scoreData[i].name = pkt:GetLenString()
		data.scoreData[i].score = pkt:GetSignedChar()
		data.scoreData[i].comment = pkt:GetLenString()
	end
end

function MsgParser:MSG_GOOD_VOICE_RANK_LIST(pkt, data)
--encap:mapping GOOD_VOICE_FINAL_SHOW_DATA=string id, string voice_title, string icon_img, int8 score, string name, string voice_addr
--void msg_good_voice_rank_list(int16 season_no, GOOD_VOICE_FINAL_SHOW_DATA voices[]);
	data.season_no = pkt:GetShort()
	data.count = pkt:GetShort()
	data.rankInfo = {}
	for i = 1, data.count do
		data.rankInfo[i] = {}
		data.rankInfo[i].voice_id = pkt:GetLenString()
		data.rankInfo[i].voice_title = pkt:GetLenString()
		data.rankInfo[i].icon_img = pkt:GetLenString()
		data.rankInfo[i].score = pkt:GetChar()
		data.rankInfo[i].name = pkt:GetLenString()
		data.rankInfo[i].voice_addr = pkt:GetLenString()
	end
end

function MsgParser:MSG_GOOD_VOICE_BE_DELETED(pkt, data)
	data.voice_id = pkt:GetLenString()
end

function MsgParser:MSG_LEAVE_MESSAGE_WRITE(pkt, data)
	self:MSG_BLOG_MESSAGE_WRITE(pkt, data)
end

function MsgParser:MSG_LEAVE_MESSAGE_DELETE(pkt, data)
	self:MSG_BLOG_MESSAGE_DELETE(pkt, data)
end

function MsgParser:MSG_LEAVE_MESSAGE_LIST(pkt, data)
	data.host_gid = pkt:GetLenString() -- 空间主人GID
    data.request_iid = pkt:GetLenString() -- 消息唯一标识，此为空时，表示首次刷新
    data.count = pkt:GetSignedChar()  -- 消息数量,此为-1时，表示请求刷新失败
    for i = 1, data.count do
        local info = {}
        info.iid = pkt:GetLenString()         -- 消息唯一标识
        info.sender_gid = pkt:GetLenString()  -- 发送者gid
        info.sender_name = pkt:GetLenString() -- 发送者名字
        info.sender_icon = pkt:GetShort()
        info.sender_level = pkt:GetShort()
        info.sender_vip = pkt:GetChar()       -- 会员类型，0 = 普通， 1 = 月卡， 2 = 季卡， 3 = 年卡
        info.sender_dist = pkt:GetLenString() -- 发送者区组
        info.target_gid = pkt:GetLenString()  -- 目标gid，此为空时，表示正常留言；不为空时，表示回复对象
        info.target_name = pkt:GetLenString() -- 目标名字
        info.target_dist = pkt:GetLenString() -- 目标区组
        info.time = pkt:GetLong()             -- 留言时间
        info.message = pkt:GetLenString2()    -- 留言信息
		info.like_num = pkt:GetLong()
        table.insert(data, info)
    end
end

function MsgParser:MSG_LEAVE_MESSAGE_LIKE(pkt, data)
	data.char_gid = pkt:GetLenString()
	data.message_id = pkt:GetLenString()
end

function MsgParser:MSG_NEW_DIST_CHONG_BANG_DATA(pkt, data)
    data.start_time = pkt:GetLong()
    data.end_time = pkt:GetLong()
    data.tao_rank_index = pkt:GetShort()
    data.level_rank_index = pkt:GetShort()
end

function MsgParser:MSG_CHILD_MONEY(pkt, data)
    data.id = pkt:GetLenString()		-- 娃娃 id
	data.name = pkt:GetLenString()
	data.money = pkt:GetLong()
end

function MsgParser:MSG_QIXI_2019_LMQG_INFO(pkt, data)
	data.end_time = pkt:GetLong()
	data.needCollectCount = pkt:GetChar()					-- 每人需要收集的总数
	data.playerInfo = {}
	for i = 1, 2 do
		data.playerInfo[i] = {}
		data.playerInfo[i].player_id = pkt:GetLong()						-- 玩家1 id
		data.playerInfo[i].player_name = pkt:GetLenString()						-- 玩家1 名字
		data.playerInfo[i].player_icon = pkt:GetLong()						-- 玩家1 icon
		data.playerInfo[i].player_collected = pkt:GetChar()					-- 玩家1 已收集数目
		data.playerInfo[i].player_material_type = pkt:GetChar()				-- 玩家1 收集的材料类型(1-6)
	end
end

function MsgParser:MSG_QIXI_2019_LMQG_REFRESH(pkt, data)
    data.next_refresh_time = pkt:GetLong()				-- 下次刷新时间(下次刷新时间前可点击)
	data.martials = {}
	data.count = pkt:GetShort()
	for i = 1, data.count do
		data.martials[i] = {}
		data.martials[i].type = pkt:GetChar()
		data.martials[i].pos = pkt:GetChar()
	end
end

function MsgParser:MSG_QIXI_2019_LMQG_SCORE(pkt, data)
	data.player_id = pkt:GetLong()						-- 玩家1 id
	data.player_collected = pkt:GetChar()					-- 玩家1 已收集数目
	data.pos = pkt:GetChar()					-- 玩家1 已收集数目
end

function MsgParser:MSG_MAIL_NOT_EXIST(pkt, data)
	data.id = pkt:GetLenString()
end

function MsgParser:MSG_ENABLE_COMMUNITY(pkt, data)
    local count = pkt:GetShort()
    local k, v
    for i = 1, count do
        k = pkt:GetLenString()
        v = pkt:GetChar()
        data[k] = v
    end
end

function MsgParser:MSG_SF_LOGIN_CHAR_FAIL(pkt, data)
    data.result = pkt:GetLenString()
end

-- 可选择的时装列表
function MsgParser:MSG_CHOOSE_FASION_LIST(pkt, data)
    data.type = pkt:GetLenString()  -- 时装列表的类型
    data.count = pkt:GetChar() -- 时装列表的数据
    for i = 1, data.count do
        local info = {}
        info.index = pkt:GetChar() -- 编号
        info.name = pkt:GetLenString()   -- 时装名字
        info.icon = pkt:GetLong() --
        info.price = pkt:GetLong() -- 价格
        table.insert(data, info)
    end
end

function MsgParser:MSG_OFFICIAL_DIST(pkt, data)
    data.isOffical = pkt:GetChar()
end

function MsgParser:MSG_TRADING_SPOT_GOODS_VOLUME(pkt, data)
    data.trading_no = pkt:GetLenString()
	data.count = pkt:GetShort()

	data.goods_info = {}
	for i = 1, data.count do
		--int16 goods_id, int32 open, int16 volume, int32 chg_ratio
		data.goods_info[i] = {}
		data.goods_info[i].goods_id = pkt:GetShort()
		data.goods_info[i].open = pkt:GetLong()			-- 开盘价
		data.goods_info[i].volume = pkt:GetLong()			-- 成交量
		data.goods_info[i].chg_ratio = pkt:GetSignedLong()		-- 涨跌幅
	end
end

--
function MsgParser:MSG_TRADING_SPOT_LARGE_ORDER_DATA(pkt, data)
    data.trading_no = pkt:GetLenString()
	data.from = pkt:GetShort()
	data.count = pkt:GetShort()
	for i = 1, data.count do
		--string update_time, string gid, string name, int16 icon, int16 level, int16 goods_id, int32 cash_cost
		data[i] = {}
		data[i].update_time = pkt:GetLong()
		data[i].gid = pkt:GetLenString()
		data[i].name = pkt:GetLenString()
		data[i].icon = pkt:GetShort()
		data[i].level = pkt:GetShort()
		data[i].goods_id = pkt:GetShort()
		data[i].cash_cost = pkt:GetLong()
	end
end


function MsgParser:MSG_CHILD_JOIN_FAMILY(pkt, data)
	data.id = pkt:GetLenString()
end

function MsgParser:MSG_CHILD_JOIN_FAMILY_SUCC(pkt, data)
    data.id = pkt:GetLenString()
	data.family = pkt:GetChar()
    data.gender = pkt:GetChar()
end

function MsgParser:MSG_SET_CHILD_OWNER(pkt, data)
    data.id = pkt:GetLong()
    data.owner_id = pkt:GetLong()
end

function MsgParser:MSG_UPDATE_CHILDS(pkt, data)
    data.count = pkt:GetShort()
    for i = 1, data.count do
        local tmp = {}
        data[i] = tmp
        tmp.cid = pkt:GetLenString()
        tmp.id = pkt:GetLong()
        Builders:BuildPetInfo(pkt, tmp)
    end
end

function MsgParser:MSG_SET_COMBAT_CHILD(pkt, data)
    data.id = pkt:GetLong()
    data.out_combat = pkt:GetChar()
end

function MsgParser:MSG_SET_VISIBLE_CHILD(pkt, data)
    data.id = pkt:GetLong()
end

function MsgParser:MSG_CHILD_PRE_ASSIGN_ATTRIB(pkt,data)
    data.cid = pkt:GetLenString()
    data.max_life = pkt:GetSignedLong()
    data.max_mana = pkt:GetSignedLong()
    data.phy_power = pkt:GetSignedLong()
    data.mag_power = pkt:GetSignedLong()
    data.speed = pkt:GetSignedLong()
    data.def = pkt:GetSignedLong()
end

function MsgParser:MSG_CHILD_START_GAME(pkt, data)
    data.task_name = pkt:GetLenString()			-- 任务名称
	data.child_id = pkt:GetLenString()		-- 娃娃名称
	data.child_name = pkt:GetLenString()		-- 娃娃名称
	data.child_icon = pkt:GetLong()				-- 娃娃 icon
	data.pwd = pkt:GetLenString()				-- 本次游戏密钥(客户端使用该密钥对结果进行 des 加密)
    data.x = pkt:GetShort()
    data.y = pkt:GetShort()
end

function MsgParser:MSG_CHILD_GAME_RESULT(pkt, data)
    data.task_name = pkt:GetLenString()			-- 任务名称
	data.result = pkt:GetChar()
	data.qinmi = pkt:GetLong()					-- 亲密
	data.daofa = pkt:GetChar()
	data.xinfa = pkt:GetChar()
end

function MsgParser:MSG_CHILD_GAME_SCORE(pkt, data)
    data.task_name = pkt:GetLenString()			-- 任务名称
	data.thisScore = pkt:GetChar()				-- int8，本次得分
	data.hightestScore = pkt:GetChar()				-- int8，最高得分
	data.totalSore = pkt:GetChar()				-- int8，满分数值
	data.qinmi = pkt:GetLong()					-- 亲密
	data.daofa = pkt:GetChar()					-- int8，可获得道法残卷奖励数量
	data.xinfa = pkt:GetChar()					-- int8，可获得心法残卷奖励数量
end


function MsgParser:MSG_CHILD_CLICK_TASK_LOG(pkt, data)
    data.task_name = pkt:GetLenString()			-- 任务名称
	data.room_id = pkt:GetLong()			-- 任务名称
end

function MsgParser:MSG_CHILD_CULTIVATE_INFO(pkt, data)
	data.stage = pkt:GetChar()				-- 娃娃stage 0表示修炼阶段，1表示突破阶段，不同阶段本消息的资质和资质上限对应该阶段的资质和资质上限。
	data.id = pkt:GetLenString()			-- 娃娃 id
	data.name = pkt:GetLenString()			-- 娃娃 名字
	data.icon = pkt:GetLong()				-- 娃娃 icon
	data.daofa = pkt:GetLong()				-- 道法残卷数量
	data.xinfa = pkt:GetLong()				-- 心法残卷数量

	data.init_life = pkt:GetLong()				-- 初始气血资质
	data.init_mana = pkt:GetLong()				-- 初始法力资质
	data.init_speed = pkt:GetLong()				-- 初始速度资质
	data.init_phy = pkt:GetLong()				-- 初始物攻资质
	data.init_mag = pkt:GetLong()				-- 初始法攻资质

	data.add_life = pkt:GetLong()				-- 修炼增加的气血资质
	data.add_mana = pkt:GetLong()				-- 修炼增加的法力资质
	data.add_speed = pkt:GetLong()				-- 修炼增加的速度资质
	data.add_phy = pkt:GetLong()				-- 修炼增加的物攻资质
	data.add_mag = pkt:GetLong()				-- 修炼增加的法攻资质

	data.add_life_max = pkt:GetLong()				-- 修炼增加的气血资质
	data.add_mana_max = pkt:GetLong()				-- 修炼增加的法力资质
	data.add_speed_max = pkt:GetLong()				-- 修炼增加的速度资质
	data.add_phy_max = pkt:GetLong()				-- 修炼增加的物攻资质
	data.add_mag_max = pkt:GetLong()				-- 修炼增加的法攻资质

	data.toy_count = pkt:GetShort()				-- 装备的玩具数量
	data.toys = {}
	for i = 1, data.toy_count do
		data.toys[i] = {}
		data.toys[i].toy_name = pkt:GetLenString()
		data.toys[i].naijiu = pkt:GetLong()
	end

	data.toy_buff_life = pkt:GetLong()			-- int32，玩具增加的气血
	data.toy_buff_mana = pkt:GetLong()			-- int32，玩具增加的法力
	data.toy_buff_phy = pkt:GetLong()			-- int32，玩具增加的物攻
	data.toy_buff_mag = pkt:GetLong()			-- int32，玩具增加的法攻
	data.toy_buff_speed = pkt:GetLong()			-- int32，玩具增加的速度
	data.toy_buff_def = pkt:GetLong()			-- int32，玩具增加的防御
end

function MsgParser:MSG_HOUSE_TDLS_MENU(pkt, data)
    data.no = pkt:GetLong()			-- 任务名称
	data.count = pkt:GetShort()
	data.menu = {}
	for i = 1, data.count do
		data.menu[i] = pkt:GetLenString()
	end
end

function MsgParser:MSG_CHILD_UPGRADE_PRE_INFO(pkt, data)
    data.id = pkt:GetLenString()
    Builders:BuildFields(pkt, data)
end

function MsgParser:MSG_CHILD_UPGRADE_SUCC(pkt, data)
    data.id = pkt:GetLenString()
    data.before = {}
    data.after = {}
    Builders:BuildFields(pkt, data.before)
    Builders:BuildFields(pkt, data.after)
end


-- 通知修炼资质成功
function MsgParser:MSG_CHILD_PRACTICE_SUCC(pkt, data)
	data.id = pkt:GetLenString()			-- 娃娃 id
end

-- 玩具合成结果
function MsgParser:MSG_MERGE_CHILD_TOY(pkt, data)
	data.result = pkt:GetChar()					-- 合成结果（1表示成功，0表示失败）
end

function MsgParser:MSG_CHILD_STOP_GAME(pkt, data)
	data.task_name = pkt:GetLenString()
	data.child_id = pkt:GetLenString()
end

function MsgParser:MSG_CHILD_CARD_INFO(pkt, data)
    data.cid = pkt:GetLenString()
    data.stage = pkt:GetChar()
    data.name = pkt:GetLenString()
    data.icon = pkt:GetLong()
    data.gender = pkt:GetChar()
    data.polar = pkt:GetChar()
    data.is_upgrade = pkt:GetChar()
    data.money = pkt:GetLong()
    data.daofa = pkt:GetLong()
    data.xinfa = pkt:GetLong()
    data.maturity = pkt:GetShort()
    data.health = pkt:GetChar()
    data.mature = pkt:GetShort()
    data.feed = pkt:GetChar()
    data.clean = pkt:GetChar()
    data.happy = pkt:GetChar()
    data.fatigue = pkt:GetChar()
    data.wuxing = pkt:GetChar()
    data.xingge = pkt:GetChar()
    data.vitality = pkt:GetChar()
    data.status = pkt:GetChar()
    data.life_shape = pkt:GetShort()
    data.life_shape_percent = pkt:GetChar()
    data.mana_shape = pkt:GetShort()
    data.mana_shape_percent = pkt:GetChar()
    data.speed_shape = pkt:GetShort()
    data.speed_shape_percent = pkt:GetChar()
    data.phy_shape = pkt:GetShort()
    data.phy_shape_percent = pkt:GetChar()
    data.mag_shape = pkt:GetShort()
    data.mag_shape_percent = pkt:GetChar()

    data.owner_count = pkt:GetShort()
    data.owner_list = {}
    for i = 1, data.owner_count do
        data.owner_list[i] = {}
        data.owner_list[i].name = pkt:GetLenString()
        data.owner_list[i].intimacy = pkt:GetLong()
    end

    table.sort(data.owner_list, function(l, r)
        if l.intimacy > r.intimacy then return true end
        if l.intimacy < r.intimacy then return false end
    end)

    data.toy_count = pkt:GetShort()
    data.toy_list = {}
    for i = 1, data.toy_count do
        data.toy_list[i] = {}
        data.toy_list[i].name = pkt:GetLenString()
        data.toy_list[i].naijiu = pkt:GetLong()
        data.toy_list[i].naijiu_max = pkt:GetLong()
    end
end

return MsgParser
