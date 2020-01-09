-- created by cheny Feb/19/2014
-- 命令解析器

local CmdParser = {}

function CmdParser:CMD_ADMIN_TEST_SKILL(pkt, data)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_ECHO(pkt, data)
    pkt:PutLong(data.current_time)
    pkt:PutLong(data.peer_time)
end

function CmdParser:MSG_REPLY_ECHO(pkt, data)
    pkt:PutLong(data.reply_time)
end

function CmdParser:CMD_L_GET_ANTIBOT_QUESTION(pkt, data)
    pkt:PutLenString(data.account)
end

function CmdParser:CMD_L_CHECK_USER_DATA(pkt, data)
    pkt:PutLenString4(data.data)
end

function CmdParser:CMD_L_ACCOUNT(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.account)
    pkt:PutLenString(data.password)
    pkt:PutLenString(data.mac)
    pkt:PutLenString(data.data)
    pkt:PutLenString(data.lock)
    pkt:PutLenString(data.dist)
    pkt:PutChar(data.from3rdSdk)
    pkt:PutLenString(data.channel)
    pkt:PutLenString(data.os_ver)
    pkt:PutLenString(data.term_info)
    pkt:PutLenString(data.imei)
    pkt:PutLenString(data.client_original_ver)
    pkt:PutChar(data.not_replace)  -- data.not_replace
end

function CmdParser:CMD_L_GET_SERVER_LIST(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutLong(data.auth_key)
    pkt:PutLenString(data.dist)
end

function CmdParser:CMD_L_CLIENT_CONNECT_AGENT(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutLong(data.auth_key)
    pkt:PutLenString(data.server)
end

function CmdParser:CMD_LOGIN(pkt, data)
    pkt:PutLenString(data.user)
    pkt:PutLong(data.auth_key)
    pkt:PutLong(data.seed)
    pkt:PutChar(data.emulator)
    pkt:PutChar(data.sight_scope)
    pkt:PutLenString(data.version)
    pkt:PutLenString(data.clientid) -- 个推的clientid
    pkt:PutShort(data.netStatus) -- 网络状态
    pkt:PutChar(data.adult)
    pkt:PutLenString(data.signature)
    pkt:PutLenString(data.clientname)
    pkt:PutChar(data.redfinger and 1 or 0)
end

function CmdParser:CMD_LOAD_EXISTED_CHAR(pkt, data)
    pkt:PutLenString(data.char_name)
end

function CmdParser:CMD_LOGOUT(pkt, data)
    pkt:PutChar(data.reason)
end

function CmdParser:CMD_CHAT_EX(pkt, data)
    pkt:PutShort(data.channel)
    pkt:PutShort(data.compress or 0)
    pkt:PutShort(data.orgLength or 0)
    pkt:PutLenString2(data.msg)
    pkt:PutShort(data.cardCount or 0)
    for i = 1, data.cardCount or 0 do
        pkt:PutLenString(data.cardParam)
    end

    -- 语音参数
    pkt:PutLong(data.voiceTime or 0)
    pkt:PutLenString2(data.token or "")
    pkt:PutLenString(data.para or "")
 --   local count = data.item_count or 0
  --  pkt:PutShort(count)
  --  for i = 1, count, 1 do
      --  pkt:PutLong(data[string.format("id%d", i)])
   -- end
end

function CmdParser:CMD_SELECT_MENU_ITEM(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.menu_item)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_C_END_ANIMATE(pkt, data)
    pkt:PutLong(data.answer)
end

function CmdParser:CMD_C_DO_ACTION(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.victim_id)
    pkt:PutLong(data.action)
    pkt:PutLong(data.para)
    pkt:PutLenString(data.para1)
    pkt:PutLenString(data.para2)
    pkt:PutLenString(data.para3)
    pkt:PutLenString(data.skill_talk)
end

function CmdParser:CMD_C_CATCH_PET(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_MULTI_MOVE_TO(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.map_id)
    pkt:PutLong(data.map_index)
    local count = data.count
    pkt:PutShort(count)
    for i = 1, count do
        pkt:PutShort(data[string.format("x%d", i)])
        pkt:PutShort(data[string.format("y%d", i)])
    end
    pkt:PutShort(data.dir)
    pkt:PutLong(data.send_time)
end

function CmdParser:CMD_OTHER_MOVE_TO(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.map_id)
    pkt:PutShort(data[string.format("x%d", data.count)])
    pkt:PutShort(data[string.format("y%d", data.count)])
    pkt:PutShort(data.dir)
end

function CmdParser:CMD_REQUEST_ITEM_INFO(pkt, data)
    pkt:PutLenString(data.item_cookie)
end

function CmdParser:CMD_ENTER_ROOM(pkt, data)
    pkt:PutLenString(data.room_name)
    pkt:PutChar(data.isTaskWalk or 0)
end

function CmdParser:CMD_GENERAL_NOTIFY(pkt, data)
    pkt:PutShort(data.type)
    pkt:PutLenString(data.para1 or '')
    pkt:PutLenString(data.para2 or '')
end

function CmdParser:CMD_CHANGE_TITLE(pkt, data)
    pkt:PutLenString(data.select)
end

function CmdParser:CMD_OPEN_MENU(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.type or 1)
end

-- 无数据包的，通过该消息，不需要再写其他解析接口
function CmdParser:CMD_NO_PACKET(pkt, data)
end

function CmdParser:CMD_KICKOUT(pkt, data)
    pkt:PutLenString(data.peer_name)
end

function CmdParser:CMD_ACCEPT(pkt, data)
    pkt:PutLenString(data.peer_name)
    pkt:PutLenString(data.ask_type)
end

function CmdParser:CMD_REJECT(pkt, data)
    pkt:PutLenString(data.peer_name)
    pkt:PutLenString(data.ask_type)
end

function CmdParser:CMD_REQUEST_JOIN(pkt, data)
    pkt:PutLenString(data.peer_name)
    pkt:PutLong(data.id or 0)
    pkt:PutLenString(data.ask_type)
end

function CmdParser:CMD_CHANGE_TEAM_LEADER(pkt, data)
    pkt:PutLenString(data.new_leader_id)
    pkt:PutChar(data.type or 0)
end

function CmdParser:CMD_C_SELECT_MENU_ITEM(pkt, data)
    pkt:PutLenString(data.menu_item)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_OPER_TELEPORT_ITEM(pkt, data)
    pkt:PutLong(data.id or 0)
    pkt:PutShort(data.oper)
    pkt:PutShort(data.para1 or 0)
    pkt:PutLenString(data.para2 or "")
end

function CmdParser:CMD_ASSIGN_ATTRIB(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.type)
    pkt:PutShort(data.para1)
    pkt:PutShort(data.para2)
    pkt:PutShort(data.para3)
    pkt:PutShort(data.para4)
    pkt:PutShort(data.para5 or 0)
    pkt:PutShort(data.para6 or 0)
end

function CmdParser:CMD_PRE_ASSIGN_ATTRIB(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.type)
    pkt:PutShort(data.para1)
    pkt:PutShort(data.para2)
    pkt:PutShort(data.para3)
    pkt:PutShort(data.para4)
    pkt:PutShort(data.para5 or 0)
end

function CmdParser:CMD_SET_RECOMMEND_ATTRIB(pkt, data)
    pkt:PutLong(data.id or 0)
    pkt:PutChar(data.con or 0)
    pkt:PutChar(data.wiz or 0)
    pkt:PutChar(data.str or 0)
    pkt:PutChar(data.dex or 0)
    pkt:PutChar(data.auto_add or 0)
    pkt:PutChar(data.plan or 0)
end

function CmdParser:CMD_SELECT_VISIBLE_PET(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_SELECT_CURRENT_PET(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.pet_status)
end

function CmdParser:CMD_DROP_PET(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_SET_PET_NAME(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_LEARN_SKILL(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.skill_no)
    pkt:PutShort(data.up_level)
end

function CmdParser:CMD_DOWNGRADE_SKILL(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.skill_no)
end

function CmdParser:CMD_APPLY(pkt, data)
    pkt:PutChar(data.pos)
    pkt:PutShort(data.amount)
end

function CmdParser:CMD_APPLY_EX(pkt, data)
    pkt:PutChar(data.pos)
    pkt:PutShort(data.amount)
    pkt:PutLenString(data.str or "")
end

function CmdParser:CMD_FEED_PET(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutChar(data.pos)
    pkt:PutLenString(data.para or "")
end

function CmdParser:CMD_APPLY_CHONGWU_JINGYANDAN(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutShort(data.num1) -- 宠物经验丹
    pkt:PutShort(data.num2) -- 高级宠物经验丹
end

function CmdParser:CMD_FEED_GUARD(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.pos)
    pkt:PutLenString(data.para or "")
end

function CmdParser:CMD_SORT_PACK(pkt, data)
    pkt:PutShort(data.count)
    pkt:PutLenString2(data.range)
    pkt:PutShort(data.start_pos)
    pkt:PutLenString2(data.to_store_cards or "")
end

function CmdParser:CMD_TELEPORT(pkt, data)
    pkt:PutLong(data.map_id)
    pkt:PutLong(data.x or 0)
    pkt:PutLong(data.y or 0)
    pkt:PutChar(data.isTaskWalk or 0)
end

function CmdParser:CMD_SET_RECOMMEND_POLAR(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.para1)
    pkt:PutChar(data.para2)
    pkt:PutChar(data.para3)
    pkt:PutChar(data.para4)
    pkt:PutChar(data.para5)
    pkt:PutChar(data.auto_add)
    pkt:PutChar(data.plan)
end

function CmdParser:CMD_REFRESH_SERVICE_LOG(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_REFRESH_TASK_LOG(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_GET(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_MOVE_ON_CARPET(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_SHIFT(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.x)
    pkt:PutShort(data.y)
    pkt:PutShort(data.dir)
end

function CmdParser:CMD_SET_SHAPE_TEMP(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutChar(data.is_set)
end

function CmdParser:CMD_PRE_UPGRADE_EQUIP(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.para or "")
end

function CmdParser:CMD_UPGRADE_EQUIP(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.para or "")
end

function CmdParser:CMD_GUARDS_CHANGE_NAME(pkt, data)
    pkt:PutLong(data.guard_id)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_GUARDS_CHEER(pkt, data)
    pkt:PutLong(data.guard_id)
    pkt:PutChar(data.cheer)
end

function CmdParser:CMD_BATCH_BUY(pkt, data)
    pkt:PutLong(data.cash or 0)
    local count = data.count
    pkt:PutChar(count)

    for name, num in pairs(data) do
        if name ~= "cash" and name ~= "count" then
            pkt:PutLenString(name)
            pkt:PutLong(num)
        end
    end
end

function CmdParser:CMD_VERIFY_FRIEND(pkt, data)
    pkt:PutLenString(data.char_name)
    pkt:PutLenString(data.char_gid)
    pkt:PutLenString(data.message)
end

function CmdParser:CMD_ADD_FRIEND(pkt, data)
    pkt:PutLenString(data.group)
    pkt:PutLenString(data.char)
    pkt:PutLong(data.icon or 0)
    pkt:PutShort(data.level or 0)
end

function CmdParser:CMD_REMOVE_FRIEND(pkt, data)
    pkt:PutLenString(data.group)
    pkt:PutLenString(data.char)
end

function CmdParser:CMD_REFRESH_FRIEND(pkt, data)
    pkt:PutLenString(data.group)
    pkt:PutLenString(data.char)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_FINGER(pkt, data)
    pkt:PutLenString(data.char)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_CREATE_NEW_CHAR(pkt, data)
    pkt:PutLenString(data.char_name)
    pkt:PutShort(data.gender)
    pkt:PutShort(data.polar)
end

function CmdParser:CMD_KILL(pkt, data)
    pkt:PutLong(data.victim_id)
    pkt:PutShort(data.flag or 0)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_CLEAN_REQUEST(pkt, data)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_FRIEND_TELL_EX(pkt, data)
    pkt:PutShort(data.flag)
    pkt:PutLenString(data.name)
    pkt:PutShort(data.compress)
    pkt:PutShort(data.orgLength)
    pkt:PutLenString2(data.msg)
    pkt:PutShort(data.cardCount or 0)

    for i = 1, data.cardCount or 0 do
        pkt:PutLenString(data.cardParam)
    end
        -- 语音参数
    pkt:PutLong(data.voiceTime or 0)
    pkt:PutLenString2(data.token or "")

    pkt:PutLenString(data.receive_gid)
end

function CmdParser:CMD_PARTY_MEMBERS(pkt, data)
    pkt:PutShort(data.page or 0)
    pkt:PutLenString(data.name or "")
    pkt:PutLenString(data.gid or "")
end

function CmdParser:CMD_QUERY_PARTY(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_MODIFY_PARTY_QUANQL(pkt, data)
    pkt:PutChar(data.hours)
    pkt:PutChar(data.minutes)
end

function CmdParser:CMD_PARTY_ZHIDUOXING_SKILL(pkt, data)
    pkt:PutLenString(data.skill_name) -- 技能名称，取值为 dizhijuan（地之卷）, renzhijuan（人之卷）, tianzhijuan（天之卷）
end

function CmdParser:CMD_PARTY_ZHIDUOXING_SETUP(pkt, data)
    pkt:PutChar(data.oper_type)  -- 操作类型
    pkt:PutLenString(data.oper_para)  -- 挑选线路
end

function CmdParser:CMD_PARTY_MODIFY_MEMBER(pkt, data)
    pkt:PutLenString(data.name or "")
    pkt:PutLenString(data.gid or "")
    pkt:PutLenString(data.partyDesc or "")
    pkt:PutShort(data.job or 0)
    pkt:PutShort(data.changeBangZhu or 0)
end

function CmdParser:CMD_CREATE_PARTY(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.announce)
end

function CmdParser:CMD_QUERY_PARTYS(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_PARTY_REJECT_LEVEL(pkt, data)
    pkt:PutShort(data.minLevel)
    pkt:PutShort(data.maxLevel)
    pkt:PutChar(data.isWork)
    pkt:PutChar(data.isChange)
end

function CmdParser:CMD_DEVELOP_SKILL(pkt, data)
    pkt:PutLong(data.point)
    pkt:PutShort(data.skill_no)
end

function CmdParser:CMD_GET_PARTY_LOG(pkt, data)
    pkt:PutLong(data.start)
    pkt:PutLong(data.limit)
end

function CmdParser:CMD_BUY_FROM_ELITE_PET_SHOP(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_OPEN_ONLINE_MALL(pkt, data)
    pkt:PutLenString(data["name"] or "")
    pkt:PutLenString(data["para"] or "")
end

function CmdParser:CMD_BUY_FROM_ONLINE_MALL(pkt, data)
	pkt:PutLenString(data["barcode"])
	pkt:PutShort(data["amount"])
	pkt:PutLenString(data["coin_pwd"])
	pkt:PutLenString(data["coin_type"])
	--pkt:PutLenString(gfGetMd5(data["amount"]))
end

function CmdParser:CMD_MAILBOX_OPERATE(pkt, data)
    pkt:PutShort(data.type)
    pkt:PutLenString(data.id)
    pkt:PutShort(data.operate)
end

function CmdParser:CMD_FRIEND_VERIFY_RESULT(pkt, data)
    pkt:PutLenString(data.verifyId)
    pkt:PutLenString(data.charName)
    pkt:PutLenString(data.charGid)
    pkt:PutChar(data.result)
end

function CmdParser:CMD_OPER_SCENARIOD(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.type)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_ANSWER_QUESTIONNAIRE(pkt, data)
    pkt:PutShort(data.id)
    pkt:PutLenString2(data.answer)
    pkt:PutLong(data.time_used)
end

function CmdParser:CMD_SET_LEADER_DECLARATION(pkt, data)
    pkt:PutLenString(data.declaration)
end

function CmdParser:CMD_SET_PARTY_QUANQL(pkt, data)
    pkt:PutChar(data.openType)
    pkt:PutChar(data.select_id)
end

function CmdParser:CMD_PARTY_MODIFY_ANNOUNCE(pkt, data)
    pkt:PutLenString2(data.annouce)
end

function CmdParser:CMD_PARTY_GET_BONUS(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_CONTROL_PARTY_CHANNEL(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.type)
    pkt:PutShort(data.hours)
end

function CmdParser:CMD_REFRESH_PARTY_SHOP(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_BUY_FROM_PARTY_SHOP(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutShort(data.num)
end

function CmdParser:CMD_PARTY_SEND_MESSAGE(pkt, data)
    pkt:PutLenString(data.title)
    pkt:PutLenString(data.msg)
end

function CmdParser:CMD_CLOSE_MENU(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_ADD_PARTY_WAR_MONEY(pkt, data)
    pkt:PutLong(data.cash)
end

function CmdParser:CMD_VIEW_PARTY_WAR_HISTORY(pkt, data)
    pkt:PutLong(data.no)
    pkt:PutChar(data.zone)
end

-- 神秘大礼 抽奖
function CmdParser:CMD_START_AWARD(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutChar(data.step)
end

function CmdParser:CMD_BUY_FESTIVAL_GIFT(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_OPEN_FESTIVAL_TREASURE(pkt, data)
    pkt:PutChar(data.boxId)
end

function CmdParser:CMD_FETCH_LOTTERY_ZNQ_2017(pkt, data)
    pkt:PutChar(data.flag)      -- flag  0 表示请求抽奖，1 表示请求领奖。
end

function CmdParser:CMD_OPEN_FESTIVAL_LOTTERY(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_FETCH_SSNYF_BONUS(pkt, data)
    pkt:PutLenString(data.name)
end

-- 领取奖励
function CmdParser:CMD_SPRING_2019_ZSQF_FETCH(pkt, data)
    pkt:PutChar(data.index)
end

-- 2019春节开始敲钟游戏
function CmdParser:CMD_SPRING_2019_ZSQF_START_GAME(pkt, data)
    pkt:PutChar(data.index)
end

-- 2019春节提交敲钟游戏数据
function CmdParser:CMD_SPRING_2019_ZSQF_COMMIT_GAME(pkt, data)
    pkt:PutChar(data.index)
    pkt:PutLenString(data.result)
end

-- 发送个人信息
function CmdParser:CMD_GATHER_USER_INFO(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.name)   -- ""
    pkt:PutLenString(data.qq)   -- ""
    pkt:PutLenString(data.tel)   -- ""
    pkt:PutLenString2(data.address)
end

-- 宠物点化
function CmdParser:CMD_UPGRADE_PET(pkt, data)
    pkt:PutLenString(data.type)   -- "pet_open_enchant"开启       "pet_enchant"
    pkt:PutLong(data.no)
    pkt:PutLenString(data.pos)   -- "41|42"
    pkt:PutLenString(data.other_pet)   -- ""
    pkt:PutLenString(data.cost_type)   -- ""
    pkt:PutLenString(data.ids)
end

function CmdParser:CMD_MAKE_PILL(pkt, data)
    pkt:PutLong(data.index)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_SET_STALL_GOODS(pkt, data)
    pkt:PutLong(data.inventoryPos)
    pkt:PutLong(data.price)
    pkt:PutShort(data.pos)
    pkt:PutShort(data.type)
    pkt:PutShort(data.amount or 1)
end

function CmdParser:CMD_BUY_FROM_STALL(pkt, data)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.pageStr)
    pkt:PutLong(data.price)
    pkt:PutChar(data.type)
    pkt:PutShort(data.amount or 1)
end

function CmdParser:CMD_START_MATCH_TEAM_LEADER(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.minLevel)
    pkt:PutShort(data.maxLevel)
end

function CmdParser:CMD_GOODS_BUY(pkt, data)
    pkt:PutLong(data.shipper)
    pkt:PutShort(data.pos)
    pkt:PutShort(data.amount)
    pkt:PutShort(data.to_pos)
end

function CmdParser:CMD_SET_SETTING(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutShort(data.value)
end

function CmdParser:CMD_EXCHANGE_GOODS(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.name)
    pkt:PutShort(data.amount)
end

function CmdParser:CMD_UNEQUIP(pkt, data)
    pkt:PutChar(data.from_pos)
    pkt:PutChar(data.to_pos)
end

function CmdParser:CMD_EQUIP(pkt, data)
    pkt:PutChar(data.pos)
    pkt:PutChar(data.equip_part)
end

function CmdParser:CMD_RANDOM_NAME(pkt, data)
    pkt:PutChar(data.gender)
end

function CmdParser:CMD_STORE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.from_pos)
    pkt:PutShort(data.to_pos)
    pkt:PutShort(data.amount)
    pkt:PutLenString(data.container)
end

function CmdParser:CMD_TAKE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.from_pos)
    pkt:PutShort(data.to_pos)
    pkt:PutShort(data.amount)
end

function CmdParser:CMD_OPERATE_PET_STORE(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.pos)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_MARKET_SEARCH_ITEM(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.eatra)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_MARKET_CHECK_RESULT(pkt, data)
    pkt:PutLenString2(data.goodStr)
end

function CmdParser:CMD_L_GET_ACCOUNT_CHARS(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutLong(data.auth_key)
    pkt:PutLenString(data.dist)
end

function CmdParser:CMD_CREATE_LOAD_CHAR(pkt, data)
    pkt:PutLenString(data.char_name)
    pkt:PutShort(data.gender)
    pkt:PutShort(data.polar)
end

function CmdParser:CMD_SWITCH_SERVER(pkt, data)
    pkt:PutLenString(data.serverName)
end

function CmdParser:CMD_ASSIGN_RESIST(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.attribValues)
end

function CmdParser:CMD_FETCH_GIFT(pkt, data)
    pkt:PutLenString(data.code)
end

-- 系统拍卖竞价
function CmdParser:CMD_SYS_AUCTION_BID_GOODS(pkt, data)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLong(data.bid_price)
    pkt:PutLong(data.price)
end

-- 请求打开抢购界面
function CmdParser:CMD_STALL_RUSH_BUY_OPEN(pkt, data)
    pkt:PutLenString(data.goods_gid)
end

function CmdParser:CMD_GOLD_STALL_RUSH_BUY_OPEN(pkt, data)
    pkt:PutLenString(data.goods_gid)
end

-- 寄售相关 begin
--=======
function CmdParser:CMD_TRADING_SELL_ROLE(pkt, data)  -- 在游戏中出售角色
    pkt:PutLong(data.price)
    pkt:PutLenString(data.appointee)    -- 交易的角色 GID
	pkt:PutLenString(data.income)    -- 实际收入
end

function CmdParser:CMD_TRADING_CANCEL_ROLE(pkt, data)  -- 客户端在选角界面请求取回角色
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_TRADING_CHANGE_PRICE_ROLE(pkt, data)  -- 客户端在选角界面请求修改角色价格
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.price)
end

function CmdParser:CMD_TRADING_SELL_ROLE_AGAIN(pkt, data)  -- 客户端在选角界面请求继续寄售角色
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.price)
    pkt:PutLenString(data.income)
end

function CmdParser:CMD_TRADING_SNAPSHOT(pkt, data)  -- 客户端请求商品的快照信息
    pkt:PutLenString(data.goods_gid)
    pkt:PutLenString(data.snapshot_type)
    pkt:PutChar(data.isSync)
    pkt:PutChar(data.isShowCard)
end

function CmdParser:CMD_TRADING_FAVORITE_LIST(pkt, data)  -- 请求聚宝斋收藏列表
    pkt:PutChar(data.list_type)
end

function CmdParser:CMD_TRADING_GOODS_LIST(pkt, data)  -- 请求聚宝斋商品列表
    pkt:PutChar(data.list_type)
    pkt:PutShort(data.goods_type)
    pkt:PutLong(data.key)
end

function CmdParser:CMD_TRADING_CHANGE_FAVORITE(pkt, data)  -- 请求改变商品的收藏
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.is_favorite)
    pkt:PutChar(data.auto_favorite)
end

-- 2017 =============
-- 聚宝斋上架商品
function CmdParser:CMD_TRADING_SELL_GOODS(pkt, data)
    pkt:PutLong(data.price)
    pkt:PutChar(data.type)
    pkt:PutLong(data.para)
    pkt:PutLenString(data.appointee)
    pkt:PutChar(data.sell_type)
	pkt:PutLenString(data.income)
end

-- 聚宝斋取消售上架商品
function CmdParser:CMD_TRADING_CANCEL_GOODS(pkt, data)
    pkt:PutLenString(data.goods_gid)
end

-- 聚宝斋修改商品价格
function CmdParser:CMD_TRADING_CHANGE_PRICE_GOODS(pkt, data)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLong(data.price)
end

-- 聚宝斋重新上架商品
function CmdParser:CMD_TRADING_SELL_GOODS_AGAIN(pkt, data)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLong(data.price)
    pkt:PutChar(data.sell_type)
	pkt:PutLenString(data.income)
end
-- 2017 =============


--=======
-- 寄售相关 end

-- GM相关

function CmdParser:CMD_ADMIN_BLOCK_USER(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.ti)
    pkt:PutLenString(data.reason)
    pkt:PutChar(data.remove_goods)
end

function CmdParser:CMD_ADMIN_QUERY_PLAYER(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_ADMIN_KICKOFF(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_ADMIN_SHUT_CHANNEL(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.ti)
    pkt:PutLenString(data.channel)
    pkt:PutLenString(data.reason)
end

function CmdParser:CMD_ADMIN_BLOCK_ACCOUNT(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutLong(data.ti)
    pkt:PutLenString(data.reason)
    pkt:PutChar(data.remove_goods)
end

function CmdParser:CMD_ADMIN_THROW_IN_JAIL(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.ti)
    pkt:PutLenString(data.reason)
end

function CmdParser:CMD_ADMIN_SNIFF_AT(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_ADMIN_QUERY_ACCOUNT(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_ADMIN_WARN_PLAYER(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.title)
    pkt:PutLenString(data.content)
    pkt:PutChar(data.valid_day)
end

-- 终止战斗
function CmdParser:CMD_ADMIN_STOP_COMBAT(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 接近目标
function CmdParser:CMD_ADMIN_MOVE_TO_TARGET(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 查看进程
function CmdParser:CMD_ADMIN_SEARCH_PROCESS(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 封闭Mac
function CmdParser:CMD_ADMIN_BLOCK_MAC(pkt, data)
    pkt:PutLenString(data.mac)
    pkt:PutLong(data.interval)
    pkt:PutLenString(data.reason)
end

-- 设置玩家等级
function CmdParser:CMD_ADMIN_SET_USER_LEVEL(pkt, data)
    pkt:PutShort(data.level)
end

-- 设置玩家属性
function CmdParser:CMD_ADMIN_SET_USER_ATTRIB(pkt, data)
    pkt:PutLenString(data.attrib)
end

-- 设置宠物等级
function CmdParser:CMD_ADMIN_SET_PET_LEVEL(pkt, data)
    pkt:PutChar(data.petNo)
    pkt:PutShort(data.petLevel)
end

-- 设置宠物属性
function CmdParser:CMD_ADMIN_SET_PET_ATTRIB(pkt, data)
    pkt:PutLenString(data.petType)      -- 宠物类型
    pkt:PutLenString(data.info)         -- 已有宠物则传宠物no，新宠物则传“名称:等级”。
    pkt:PutLenString(data.attrib)       -- 武学、气血、法力、物伤、法伤、防御、速度属性，以“|”分隔。
    pkt:PutLenString(data.skills)       -- 技能1名称、技能1等级，以“:” 分隔；不同技能以“|”分隔。
    pkt:PutLenString(data.morph)        -- 气血幻化、法力幻化、物攻幻化、法攻幻化、速度幻化，以“|”分隔。
    pkt:PutChar(data.rebuild)           -- 强化次数
    pkt:PutChar(data.isDianhua)         -- 是否点化 （非0表示点化）
    pkt:PutLenString(data.godBooks)     -- 天书名称，不同天书以“|”分隔。
    pkt:PutChar(data.isYuhua)         -- 是否羽化 （非0表示点化）
    pkt:PutLong(data.intimacy)         -- 亲密
    pkt:PutChar(data.isFly)         -- 飞升
end

-- 生成指定装备类型
function CmdParser:CMD_ADMIN_MAKE_EQUIPMENT(pkt, data)
    pkt:PutLenString(data.equipType)
    pkt:PutShort(data.req_level)
    pkt:PutChar(data.rebuildLevel)
    pkt:PutLenString(data.blue)      -- 蓝属性类型及对应数值 以“:”分隔；不同属性以“|”分隔。
    pkt:PutLenString(data.pink)         -- 粉属性及对应数值
    pkt:PutLenString(data.yellow)         -- 粉属性及对应数值
    pkt:PutLenString(data.green)       -- 黄属性及对应数值
    pkt:PutLenString(data.black)       -- 套装明属性类型及对应数值，以“:”分隔
    pkt:PutLenString(data.gongming)   -- 共鸣属性
end

function CmdParser:CMD_ADMIN_MAKE_ITEM(pkt, data)
    pkt:PutLenString(data.itemName)
    pkt:PutLong(data.amount)
end

function CmdParser:CMD_L_REQUEST_LINE_INFO(pkt, data)
    pkt:PutLenString(data.account)
end

function CmdParser:CMD_LOOK_ON(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_OPER_MASTER(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.para)
    pkt:PutLenString(data.msg)
end

-- 使用变身卡
function CmdParser:CMD_APPLY_CARD(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutLong(data.id)
end

-- 同意或者拒绝别人对你使用变身卡
function CmdParser:CMD_ANSWER_CHANGE_CARD(pkt, data)
    pkt:PutChar(data.answer)
end

-- 请求变身卡置顶
function CmdParser:CMD_CL_CARD_TOP_ONE(pkt, data)
    pkt:PutLenString(data.card_name)
end

-- 请求变身开格
function CmdParser:CMD_CL_CARD_ADD_SIZE(pkt, data)
    pkt:PutShort(data.count)
end

function CmdParser:CMD_SHIMEN_TASK_DONATE(pkt, data)
    pkt:PutLong(data.money)
end

function CmdParser:CMD_GATHER_UP(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.para)
end

function CmdParser:CMD_SCREEN_RECORD_END(pkt, data)
    pkt:PutLong(data.start_time)
    pkt:PutLong(data.duration)
end

function CmdParser:CMD_PHONE_VERIFY_CODE(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.phone)
end

function CmdParser:CMD_PHONE_BIND(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLenString(data.phone)
    pkt:PutLenString(data.verifyCode)
end

function CmdParser:CMD_SMS_VERIFY_CHECK_CODE(pkt, data)
    pkt:PutLenString(data.verifyCode)
end

function CmdParser:CMD_ANSWER_SECURITY_CODE(pkt, data)
    pkt:PutLong(data.answer)
end

function CmdParser:CMD_SHARE_WITH_FRIENDS(pkt, data)
    pkt:PutLenString(data.actName)
end

function CmdParser:CMD_PET_SPECIAL_SKILL(pkt, data)
    pkt:PutLong(data.petId)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_LOG_ANTI_CHEATER(pkt, data)
    pkt:PutShort(data.count)
    for i = 1, data.count do
        pkt:PutLenString(data[i].action)
        pkt:PutLenString(data[i].para1)
        pkt:PutLenString(data[i].para2)
        pkt:PutLenString(data[i].para3)
        pkt:PutLenString2(data[i].memo)
    end
end

function CmdParser:CMD_WRITE_YYQ(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.type)
    pkt:PutLenString2(data.text)
    pkt:PutChar(data.isShowName)
end

function CmdParser:CMD_SEARCH_YYQ(pkt, data)
    pkt:PutLong(data.yyq_no)
end

function CmdParser:CMD_REQUEST_YYQ_PAGE(pkt, data)
    pkt:PutLong(data.page)
end

function CmdParser:CMD_COMMENT_YYQ(pkt, data)
    pkt:PutLong(data.yyq_no)
    pkt:PutChar(data.oper)
end

function CmdParser:CMD_WRITE_ZFQ(pkt, data)
    pkt:PutLenString(data.gid or "")
    pkt:PutChar(data.type)
    pkt:PutLenString2(data.text)
    pkt:PutChar(data.isShowName)
end

function CmdParser:CMD_SEARCH_ZFQ(pkt, data)
    self:CMD_SEARCH_YYQ(pkt, data)
end

function CmdParser:CMD_REQUEST_ZFQ_PAGE(pkt, data)
    self:CMD_REQUEST_YYQ_PAGE(pkt, data)
end

function CmdParser:CMD_COMMENT_ZFQ(pkt, data)
   self:CMD_COMMENT_YYQ(pkt, data)
end

function CmdParser:CMD_REBUILD_PET(pkt, data)
    pkt:PutLong(data.petId)
    pkt:PutShort(data.rebLevel)
    pkt:PutLenString(data.para)
    pkt:PutLenString(data.useType)
end

-- 师徒系统相关====BENIN
function CmdParser:CMD_REQUEST_APPRENTICE_INFO(pkt, data)
    pkt:PutChar(data.type)  -- 1表示寻师，2表示寻徒，3表示申请成为我的师父的列表，4表示申请成为我的徒弟的列表
end

function CmdParser:CMD_SEARCH_MASTER(pkt, data)
    pkt:PutChar(data.type)  -- 1表示发布，2表示修改留言，3表示撤销
    pkt:PutLenString(data.msg) -- 留言
end

function CmdParser:CMD_SEARCH_APPRENTICE(pkt, data)
    pkt:PutChar(data.type)  -- 1表示发布，2表示修改留言，3表示撤销
    pkt:PutLenString(data.msg) -- 留言
end

function CmdParser:CMD_APPLY_FOR_MASTER(pkt, data)
    pkt:PutChar(data.type)  -- 1表示申请，2表示同意申请，3表示拒绝申请
    pkt:PutLenString(data.gid) -- 对象gid
    pkt:PutLenString(data.message) -- 留言
end

function CmdParser:CMD_APPLY_FOR_APPRENTICE(pkt, data)
    pkt:PutChar(data.type)  -- 1表示申请，2表示同意申请，3表示拒绝申请
    pkt:PutLenString(data.gid) -- 对象gid
    pkt:PutLenString(data.message) -- 留言
end

function CmdParser:CMD_RELEASE_APPRENTICE_RELATION(pkt, data)
    pkt:PutChar(data.type)  --1表示角色和师父关系，2表示解除和徒弟关系
    pkt:PutLenString(data.gid) -- 对象gid
end

function CmdParser:CMD_CHANGE_MASTER_MESSAGE(pkt, data)
    pkt:PutLenString(data.msg) -- 对象gid
end

function CmdParser:CMD_REQUEST_CDSY_TODAY_TASK(pkt, data)
    pkt:PutLenString(data.gid) -- 对象gid
end

function CmdParser:CMD_PUBLISH_CDSY_TASK(pkt, data)
    pkt:PutLenString(data.gid) -- 对象gid
    pkt:PutLenString(data.name) -- 对象名
end

-- 领取出师任务
function CmdParser:CMD_FETCH_CHUSHI_TASK(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 师徒系统相关====END

function CmdParser:CMD_LOG_LJCG_EXCEPTION(pkt, data)
    pkt:PutLenString(data.answer)
    pkt:PutLong(data.tactics)
    pkt:PutLong(data.value)
    pkt:PutLenString(data.sa)
    pkt:PutLenString(data.ca)
end

----珍宝交易相关的指令
function CmdParser:CMD_GOLD_STALL_OPEN(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.page_str)
end

function CmdParser:CMD_GOLD_STALL_PUT_GOODS(pkt, data)
    pkt:PutLong(data.inventoryPos)
    pkt:PutLong(data.price)
    pkt:PutShort(data.pos)
    pkt:PutShort(data.type) -- 宠物、道具、金钱
    pkt:PutLenString(data.appointee)    --  指定的买家 gid
    pkt:PutChar(data.sell_type)  -- 0 普通或指定、5 拍卖
end

function CmdParser:CMD_GOLD_STALL_RESTART_GOODS(pkt, data)
    pkt:PutLenString(data.goodId)
    pkt:PutLong(data.price)
    pkt:PutChar(data.sell_type)  -- 0 普通或指定、5 拍卖
end

function CmdParser:CMD_GOLD_STALL_REMOVE_GOODS(pkt, data)
    pkt:PutLenString(data.goodId)
end

function CmdParser:CMD_GOLD_STALL_BUY_GOODS(pkt, data)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.pageStr)
    pkt:PutLong(data.price)
    pkt:PutChar(data.type)
end

-- 请求修改价格  集市珍宝交易
function CmdParser:CMD_GOLD_STALL_CHANGE_PRICE(pkt, data)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLong(data.price)
end

function CmdParser:CMD_GOLD_STALL_GOODS_STATE(pkt, data)
    self:CMD_MARKET_CHECK_RESULT(pkt, data)
end

function CmdParser:CMD_GOLD_STALL_SEARCH_GOODS(pkt, data)
    self:CMD_MARKET_SEARCH_ITEM(pkt, data)
end

function CmdParser:CMD_GOLD_STALL_GOODS_INFO(pkt, data)
    pkt:PutLenString(data.goodId)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_SAFE_LOCK_OPEN_DLG(pkt, data)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_SAFE_LOCK_SET(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.pwd)
end

function CmdParser:CMD_SAFE_LOCK_CHANGE(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.old_pwd)
    pkt:PutLenString(data.new_pwd)
end

function CmdParser:CMD_SAFE_LOCK_UNLOCK(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.pwd)
end

function CmdParser:CMD_SAFE_LOCK_RESET(pkt, data)
    pkt:PutChar(data.flag)
end

function CmdParser:CMD_PREVIEW_PET_EVOLVE(pkt, data)
    pkt:PutChar(data.mainPetNo)
    pkt:PutChar(data.otherPetNo)
end

function CmdParser:CMD_SET_OFFLINE_DOUBLE_STATUS(pkt, data)
    pkt:PutChar(data.enble)
end

-- 设置如意刷道令的状态
function CmdParser:CMD_SET_SHUADAO_RUYI_STATE(pkt, data)
    pkt:PutChar(data.state)
end

-- 购买如意刷道令点数
function CmdParser:CMD_BUY_SHUADAO_RUYI_POINT(pkt, data)
    pkt:PutChar(data.num)
end

-- 设置托管是否智能
function CmdParser:CMD_SHUAD_SMART_TRUSTEESHIP(pkt, data)
    pkt:PutChar(data.is_smart)
end

function CmdParser:CMD_BUY_SHUAD_TRUSTEESHIP_TIME(pkt, data)
    pkt:PutLong(data.ti)
end

function CmdParser:CMD_SET_SHUAD_TRUSTEESHIP_TASK(pkt, data)
    pkt:PutLenString(data.taskName)
end

function CmdParser:CMD_SET_OFFLINE_JIJI_STATUS(pkt, data)
    pkt:PutChar(data.enble)
end

function CmdParser:CMD_SET_OFFLINE_CHONGFS_STATUS(pkt, data)
    pkt:PutChar(data.enble)
end

function CmdParser:CMD_SET_OFFLINE_ZIQIHONGMENG_STATUS(pkt, data)
    pkt:PutChar(data.enble)
end

function CmdParser:CMD_FETCH_SHUADAO_SCORE_ITEM(pkt, data)
    pkt:PutChar(data.type)   -- 1.强盗领赏令   2.紫气鸿蒙
    pkt:PutChar(data.index)  -- 从0开始
end

function CmdParser:CMD_SET_SHUAD_TRUSTEESHIP_STATE(pkt, data)
    pkt:PutChar(data.state)
end

function CmdParser:CMD_OPEN_SHUAD_TRUSTEESHIP(pkt, data)
    pkt:PutLong(data.ti)
end

function CmdParser:CMD_START_GUESS(pkt, data)
    pkt:PutLong(data.amount)
    pkt:PutChar(data.choice)
end

function CmdParser:CMD_APPLY_FRIEND_ITEM(pkt, data)
    pkt:PutLenString(data.items)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_RESPONSE_TIQIN(pkt, data)
    pkt:PutChar(data.result)
end

-- 赠送相关
function CmdParser:CMD_REQUEST_GIVING(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_SUBMIT_GIVING_ITEM(pkt, data)
    if not data.type or not data.pos then return end
    pkt:PutChar(data.type)
    pkt:PutLong(data.pos)
end

function CmdParser:CMD_REQUEST_TASK_STATUS(pkt, data)
    pkt:PutLenString(data.taskName)
end

function CmdParser:CMD_BUY_WEDDING_LIST(pkt, data)
    pkt:PutLenString2(data.weddinglist)
end

function CmdParser:CMD_SET_RED_PACKET(pkt, data)
    pkt:PutShort(data.each_time_num)
    pkt:PutLong(data.cash)
    pkt:PutShort(data.last_time)
end

function CmdParser:CMD_PARTY_RENAME(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_USER_AGREEMENT(pkt, data)
    pkt:PutLong(data.time)
    pkt:PutLenString(data.version)
end

function CmdParser:CMD_REPLY_SUBMIT_ZIKA(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.operType)
end

function CmdParser:CMD_ADD_FRIEND_GROUP(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_REMOVE_FRIEND_GROUP(pkt, data)
    pkt:PutLenString(data.groupId)
end

function CmdParser:CMD_MOVE_FRIEND_GROUP(pkt, data)
    pkt:PutLenString(data.formGroupId)
    pkt:PutLenString(data.toGroupId)
    pkt:PutLenString2(data.gidListStr)
    pkt:PutLenString2(data.nameListStr)
end

function CmdParser:CMD_MODIFY_FRIEND_GROUP(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLenString(data.newName)
end

function CmdParser:CMD_SET_REFUSE_STRANGER_CONFIG(pkt, data)
    pkt:PutShort(data.level)
end

function CmdParser:CMD_SET_AUTO_REPLY_MSG_CONFIG(pkt, data)
    pkt:PutLenString(data.content)
end

function CmdParser:CMD_SET_REFUSE_BE_ADD_CONFIG (pkt, data)
    pkt:PutShort(data.level)
end

function CmdParser:CMD_ADD_CHAT_GROUP(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_REMOVE_CHAT_GROUP(pkt, data)
    pkt:PutLenString(data.groupId)
end

function CmdParser:CMD_MODIFY_CHAT_GROUP_NAME(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLenString(data.newName)
end

function CmdParser:CMD_INVENTE_CHAT_GROUP_MEMBER(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLenString2(data.gidsListStr)
end

function CmdParser:CMD_REMOVE_MEMBER_TO_CHAT_GROUP(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_MODIFY_CHAT_GROUP_ANNOUS(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLenString(data.content)
end

function CmdParser:CMD_SET_CHAT_GROUP_SETTING(pkt, data)
    pkt:PutLenString(data.groupId)
    pkt:PutLong(data.setting)
end

function CmdParser:CMD_QUIT_CHAT_GROUP(pkt, data)
    pkt:PutLenString(data.groupId)
end

function CmdParser:CMD_ACCEPT_CHAT_GROUP_INVENTE(pkt, data)
    pkt:PutLenString(data.id)
end

function CmdParser:CMD_REFUSE_CHAT_GROUP_INVENTE(pkt, data)
    pkt:PutLenString(data.id)
end

function CmdParser:CMD_CHAT_GROUP_TELL(pkt, data)
    pkt:PutShort(data.flag)
    pkt:PutLenString(data.name)
    pkt:PutShort(data.compress)
    pkt:PutShort(data.orgLength)
    pkt:PutLenString2(data.msg)
    pkt:PutShort(data.cardCount or 0)

    for i = 1, data.cardCount or 0 do
        pkt:PutLenString(data.cardParam)
    end
    -- 语音参数
    pkt:PutLong(data.voiceTime or 0)
    pkt:PutLenString2(data.token or "")

    pkt:PutLenString(data.receive_gid)
end

function CmdParser:CMD_MODIFY_FRIEND_MEMO(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.memo)
end

function CmdParser:CMD_PARTY_HELP(pkt, data)
    pkt:PutLenString(data.keyStr)
end

function CmdParser:CMD_MOONCAKE_GAMEBLING(pkt, data)
    pkt:PutChar(data.oper)
end

function CmdParser:CMD_REQUEST_PH_CARD_INFO(pkt, data)
    pkt:PutLenString(data.keyStr)
end

function CmdParser:CMD_MAILING_ITEM(pkt, data)
    pkt:PutShort(data.pos or 0)
    pkt:PutShort(data.amount or 0)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_PT_RB_SEND_REDBAG(pkt, data)
    pkt:PutShort(data.money)
    pkt:PutShort(data.num)
    pkt:PutLenString(data.msg)
    pkt:PutLenString(data.format)
    pkt:PutLenString(data.actName)
    pkt:PutLenString(data.actId)
end

function CmdParser:CMD_PT_RB_RECV_REDBAG(pkt, data)
    pkt:PutLenString(data.redbag_gid)
end

function CmdParser:CMD_PT_RB_SHOW_REDBAG(pkt, data)
    pkt:PutLenString(data.redbag_gid)
end

function CmdParser:CMD_PT_RB_RECORD(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_SET_PUSH_SETTINGS(pkt, data)
    pkt:PutChar(data.key)
    pkt:PutChar(data.value)
end

function CmdParser:CMD_COMPETE_TOURNAMENT_TOP_USER_INFO(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_KILL_COMPETE_TOURNAMENT_TARGET(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_SEND_DEVICE_TOKEN(pkt, data)
    pkt:PutLenString(data.token)
end

function CmdParser:CMD_SHOCK(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_REQUEST_PK_INFO(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.para1 or "")
    pkt:PutLenString(data.para2 or "")
end

function CmdParser:CMD_GOTO_PK(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_SUBMIT_MULTI_ITEM(pkt, data)
    pkt:PutChar(data.petNum)
    for i = 1, data.petNum do
        pkt:PutLong(data.petList[i] or 0)
    end

    pkt:PutChar(data.itemNum)
    for i = 1, data.itemNum do
        pkt:PutLong(data.itemList[i] or 0)
    end
end

function CmdParser:CMD_ZUOLAO_PLEAD(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_ZUOLAO_RELEASE(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_SELECT_CURRENT_MOUNT(pkt, data)
    pkt:PutLong(data.pet_id or 0)
end

function CmdParser:CMD_ADD_FENGLINGWAN(pkt, data)
    pkt:PutChar(data.no or 0)
    pkt:PutLenString(data.type or "")
end

function CmdParser:CMD_HIDE_MOUNT(pkt, data)
    pkt:PutLong(data.petId or 0)
    pkt:PutChar(data.isHide or 0)
end

function CmdParser:CMD_NOTIFY_ITEM_TIMEOUT(pkt, data)
    pkt:PutLenString(data.str)
    pkt:PutShort(data.pos)
end

function CmdParser:CMD_QUERY_MOUNT_MERGE_RATE(pkt, data)
    pkt:PutShort(data.main_pet_no)
    pkt:PutLenString(data.items_no)
    pkt:PutLenString(data.pets_no)
    pkt:PutChar(data.cost_num)
end

function CmdParser:CMD_PREVIEW_MOUNT_ATTRIB(pkt, data)
    pkt:PutShort(data.pet_no)
    pkt:PutChar(data.target_level)
end

function CmdParser:CMD_MAILBOX_GATHER(pkt, data)
    pkt:PutShort(data.mail_type)
    pkt:PutLenString(data.mail_id)
    pkt:PutShort(data.mail_oper)
    pkt:PutLenString(data.name or "")
    pkt:PutLenString(data.qq or "")
    pkt:PutLenString(data.tel or "")
    pkt:PutLenString2(data.addr or "")
    pkt:PutLenString(data.id or "")
    pkt:PutLenString(data.bank_id or "")
    pkt:PutLenString(data.bank_name or "")
    pkt:PutLenString(data.bank_city or "")
    pkt:PutLenString(data.we_chat or "")
    pkt:PutLenString(data.char_name or "")
    pkt:PutLenString(data.char_id or "")
end

function CmdParser:CMD_CONFIRM_RESULT(pkt, data)
    pkt:PutLenString(data.select or "")
end

function CmdParser:CMD_GODBOOK_BUY_NIMBUS(pkt, data)
    pkt:PutShort(data.pet_no)
    pkt:PutLenString(data.skill_name)
    pkt:PutLenString(data.coin_type)    -- 扣除元宝类型 金元宝为"gold_coin" ，其他""
    pkt:PutShort(data.nimbus)
end

function CmdParser:CMD_DEPOSIT(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.money)
end

function CmdParser:CMD_WITHDRAW(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLong(data.money)
end

function CmdParser:CMD_REQUEST_FUZZY_IDENTITY(pkt, data)
    pkt:PutChar(data.force_request)
end

function CmdParser:CMD_IDENTITY_BIND(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.verifyCode)
end

function CmdParser:CMD_COUPON_BUY_FROM_MALL(pkt, data)
    pkt:PutLenString(data.barcode)
    pkt:PutShort(data.amount)
    pkt:PutLenString(data.coin_pwd)
    pkt:PutLenString(data.coin_type)
    pkt:PutLenString(data.coupon_str)
end

function CmdParser:CMD_MOUNT_CONVERT(pkt, data)
    pkt:PutShort(data.pet_no)
end

function CmdParser:CMD_SUMMON_MOUNT_REQUEST(pkt, data)
    pkt:PutChar(data.flag)
end

--============== 龙争虎斗 begin
function CmdParser:CMD_LH_GUESS_RACE_INFO(pkt, data)
    pkt:PutLong(data.last_ti)
end

function CmdParser:CMD_LH_GUESS_PLANS(pkt, data)
    pkt:PutLenString(data.race_name)
    pkt:PutLenString(data.race_index)
    pkt:PutChar(data.day)
    pkt:PutLong(data.last_ti)
end

function CmdParser:CMD_LH_GUESS_TEAM_INFO(pkt, data)
    pkt:PutLenString(data.race_name)
    pkt:PutLenString(data.camp_type)
    pkt:PutChar(data.camp_index)
    pkt:PutLong(data.last_ti)
end

function CmdParser:CMD_LH_GUESS_CAMP_SCORE(pkt, data)
    pkt:PutLenString(data.race_name)
end

function CmdParser:CMD_LH_GUESS_INFO(pkt, data)
    pkt:PutLenString(data.race_name)
    pkt:PutLenString(data.race_index)
end

function CmdParser:CMD_LH_MODIFY_GUESS(pkt, data)
    pkt:PutLenString(data.race_name)
    pkt:PutLenString(data.race_index)
    pkt:PutLenString(data.camp_type)
end
--============== 龙争虎斗 end

-- 观战中心 >>>>>>>>>>>>>>>>>>>>>
-- 开始观战
function CmdParser:CMD_LOOKON_BROADCAST_COMBAT(pkt, data)
    pkt:PutLenString(data.combat_id)
    pkt:PutChar(data.combat_type)
end

-- 请求战斗录像数据
function CmdParser:CMD_LOOKON_COMBAT_RECORD_DATA(pkt, data)
    pkt:PutLenString(data.combat_id)
    pkt:PutShort(data.page)
end

-- 请求指定战斗的基础数据
function CmdParser:CMD_REQUEST_BROADCAST_COMBAT_DATA(pkt, data)
    pkt:PutLenString(data.combat_id)
end

-- 发送弹幕
function CmdParser:CMD_LOOKON_CHANNEL_MESSAGE(pkt, data)
    pkt:PutLenString(data.combat_id)
    pkt:PutLong(data.interval_tick)
    pkt:PutLenString(data.msg)
end

-- 请求一页录像弹幕信息
function CmdParser:CMD_LOOKON_COMBAT_CHANNEL_DATA(pkt, data)
    pkt:PutLenString(data.combat_id)
    pkt:PutShort(data.page)
end
-- 观战中心<<<<<<<<<<<<<<<<<<<<<<<<

function CmdParser:CMD_REFILL_ARTIFACT_NIMBUS(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_ADD_DUNWU_NIMBUS(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.skill_no)
    pkt:PutChar(data.type)
    pkt:PutShort(data.pos)
end

function CmdParser:CMD_ADD_DUNWU_TIMES(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutShort(data.pos)
end

function CmdParser:CMD_VIEW_DDQK_ATTRIB(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_SUBMIT_ICON(pkt, data)
    pkt:PutChar(data.oper_type)
    pkt:PutLenString(data.md5_value)
    if pkt.PutLenBuffer2 then
        pkt:PutLenBuffer2(data.file_data)
    else
        pkt:PutLenString2("")
    end
end

function CmdParser:CMD_REQUEST_ICON(pkt, data)
    pkt:PutLenString(data.md5_value)
end

function CmdParser:CMD_SET_FOOL_GIFT_RESULT(pkt, data)
    pkt:PutLong(data.money)
    pkt:PutLenString(data.message)
end

function CmdParser:CMD_RECEIVE_FOOL_GIFT(pkt, data)
    pkt:PutLong(data.pos)
end

function CmdParser:CMD_PERFORMANCE(pkt, data)
    pkt:PutChar(data.fr)            -- 帧率
    pkt:PutLong(data.spf)           -- 每帧消耗时间
    pkt:PutLong(data.mapId)         -- 当前所在地图
    pkt:PutLenString(data.pos)      -- 当前位置
    pkt:PutChar(data.act)           -- 当前动作
    pkt:PutChar(data.state)         -- 当前状态(1:战斗,2:观战,0:其他)
    pkt:PutLong(data.am)            -- 可用内存
    pkt:PutLong(data.tm)            -- 总内存
    pkt:PutChar(data.bg)            -- 是否在后台
    pkt:PutLong(data.rds)           -- 已接受数据
    pkt:PutLong(data.sds)           -- 已发送数据
    pkt:PutLenString(data.ti)       -- 设备型号
    pkt:PutLenString(data.os)       -- 系统版本
    pkt:PutLenString(data.bv)       -- 母包版本号
    pkt:PutLenString(data.cv)       -- 当前版本号
    pkt:PutLong(data.tcs)           -- 贴图缓存大小
end

function CmdParser:CMD_REFRESH_CS_SHIDAO_INFO(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_REQUEST_CS_SHIDAO_HISTORY(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLong(data.session)
    pkt:PutLenString(data.levelRange)
    pkt:PutLenString(data.area)
end

function CmdParser:CMD_WXLL_SUBMIT_CHANGECARD(pkt, data)
    pkt:PutLenString(data.id)
end

function CmdParser:CMD_BUY_RECHARGE_SCORE_GOODS(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutShort(data.num)
end

function CmdParser:CMD_BUY_CONSUME_SCORE_GOODS(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutShort(data.num)
end

function CmdParser:CMD_ZNQ_FETCH_LOGIN_GIFT(pkt, data)
    pkt:PutLenString(data.index)
end

function CmdParser:CMD_ZNQ_FETCH_LOGIN_GIFT_2018(pkt, data)
    pkt:PutLenString(data.index)
end

function CmdParser:CMD_ZNQ_FETCH_LOGIN_GIFT_2019(pkt, data)
    pkt:PutLenString(data.index)
end

function CmdParser:CMD_PKM_RESET_POINT(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_PKM_SET_DUNWU_SKILL(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.skill)
end

function CmdParser:CMD_PKM_RECYCLE_ITEM(pkt, data)
    pkt:PutLong(data.id)
end

function CmdParser:CMD_PKM_FETCH_ITEM(pkt, data)
    pkt:PutLenString(data.itemName)
    pkt:PutChar(data.count)
end

function CmdParser:CMD_PKM_GEN_PET(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_PKM_GEN_EQUIPMENT(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.blue)
    pkt:PutLenString(data.pink)
    pkt:PutLenString(data.yellow)
    pkt:PutLenString(data.green)
    pkt:PutLenString(data.black)
    pkt:PutLenString(data.gongming)
end

function CmdParser:CMD_WUXING_SHOP_EXCHANGE(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutShort(data.count)
end

function CmdParser:CMD_GET_FRIEND_BAOSHU_INFO(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_DO_ACTION_ON_BAOSHU(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_WATER_FRIEND(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_LEAVE_ROOM(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.extra)
end

function CmdParser:CMD_CLICK_QQ_GIFT_BTN(pkt, data)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_QMPK_MATCH_TEAM_INFO(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_YISHI_DISMISS(pkt, data)
    pkt:PutLong(data.npc_id)
end

-- 2017老玩家回归，召回道友
function CmdParser:CMD_RECALL_USER_ACTIVITY_OPER(pkt, data)
    pkt:PutLenString(data.oper)
    pkt:PutLenString(data.para)
end
function CmdParser:CMD_ADJUST_BROTHER_ORDER(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.target_gid)
end

function CmdParser:CMD_SET_BROTHER_APPELLATION(pkt,data)
    pkt:PutLenString(data.prefix)
    pkt:PutLenString(data.suffix)
end

function CmdParser:CMD_YISHI_RECRUIT(pkt, data)
    pkt:PutLenString(data.npc_name)
end

function CmdParser:CMD_YISHI_EXCHANGE(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.amount)
end

function CmdParser:CMD_YISHI_IMPROVE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutChar(data.type)
    pkt:PutChar(data.atk_count)
    pkt:PutChar(data.spd_count)
    pkt:PutChar(data.tao_count)
    pkt:PutChar(data.def_count)
end

function CmdParser:CMD_YISHI_SEARCH_MONSTER(pkt, data)
    pkt:PutLenString(data.monster_name)
end

function CmdParser:CMD_YISHI_SWITCH_STATUS(pkt, data)
    pkt:PutChar(data.status)
end

-- 切换元婴、真身
function CmdParser:CMD_CHANGE_CHAR_UPGRADE_STATE(pkt, data)
    pkt:PutChar(data.state)
end

function CmdParser:CMD_SET_GODBOOK_SKILL_STATE(pkt, data)
    pkt:PutChar(data.pos)
    pkt:PutLenString(data.godbook)
    pkt:PutChar(data.disabled)
end

function CmdParser:CMD_SET_DUNWU_SKILL_STATE(pkt, data)
    pkt:PutChar(data.pos)
    pkt:PutLong(data.dunwu)
    pkt:PutChar(data.disabled)
end

function CmdParser:CMD_CHILD_DAY_2017_POKE(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_CHILD_DAY_2017_QUIT(pkt, data)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_CHILD_DAY_2017_REMOVE(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_SUBMIT_PET_UPGRADE_ITEM(pkt, data)
    pkt:PutLenString(data.posString)
end

function CmdParser:CMD_FETCH_SD_2017_LOTTERY(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLong(data.curTime)
end

function CmdParser:CMD_REQUEST_BUY_RARE_ITEM(pkt, data)
    pkt:PutLenString(data.barcode)
    pkt:PutLong(data.num)
end

-- 请求对象的自动喊话信息
function CmdParser:CMD_AUTO_TALK_DATA(pkt, data)
    pkt:PutLong(data.id)
end

-- 请求保存自动喊话信息
function CmdParser:CMD_AUTO_TALK_SAVE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString2(data.content)
end

-- 使用九曲玲珑笔
function CmdParser:CMD_APPLY_JIUQU_LINGLONGBI(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.type)
    pkt:PutLong(data.pos)
end

function CmdParser:CMD_BUY_HOUSE(pkt, data)
    pkt:PutLenString(data.action)
    pkt:PutLenString(data.house_name)
    pkt:PutChar(data.bedroom_level)
    pkt:PutChar(data.store_level)
    pkt:PutChar(data.lianqs_level)
    pkt:PutChar(data.xiulians_level)
end

function CmdParser:CMD_CS_SHIDAO_ZONE_INFO(pkt, data)
    pkt:PutLenString(data.level_index)
    pkt:PutLenString(data.zone)
end

-- 请求销毁贵重道具或者宠物
function CmdParser:CMD_DESTROY_VALUABLE(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLong(data.id)
end

-- 确认销毁该道具或宠物
function CmdParser:CMD_DESTROY_VALUABLE_CONFIRM(pkt, data)
    pkt:PutLong(data.life) -- 玩家输入的气血值
end

function CmdParser:CMD_HOUSE_PLACE_FURNITURE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLong(data.furniture_pos)
    pkt:PutShort(data.bx)
    pkt:PutShort(data.by)
    pkt:PutChar(data.flip)
    pkt:PutChar(data.x)
    pkt:PutChar(data.y)
end

function CmdParser:CMD_HOUSE_TAKE_FURNITURE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLong(data.furniture_pos)
end

function CmdParser:CMD_HOUSE_MOVE_FURNITURE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLong(data.furniture_pos)
    pkt:PutShort(data.bx)
    pkt:PutShort(data.by)
    pkt:PutChar(data.flip)
    pkt:PutChar(data.x)
    pkt:PutChar(data.y)
end

function CmdParser:CMD_HOUSE_DRAG_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_pos)
end

function CmdParser:CMD_HOUSE_TRY_MANAGE(pkt, data)
    pkt:PutLenString(data.dlg_para or "")
end

function CmdParser:CMD_HOUSE_BUY_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_id)
    pkt:PutChar(data.num)
    pkt:PutLong(data.cost)
end

function CmdParser:CMD_REQUEST_HOUSE_DATA(pkt, data)
    pkt:PutLenString(data.dlg)
end

function CmdParser:CMD_HOUSE_CLEAN(pkt, data)
    pkt:PutLenString(data.house_id)
end

function CmdParser:CMD_HOUSE_REPAIR_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutLong(data.cost)
end

function CmdParser:CMD_HOUSE_USE_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutLenString(data.action)
    pkt:PutLenString(data.para1)
    pkt:PutLenString(data.para2)
end

function CmdParser:CMD_REQUEST_FURNITURE_APPLY_DATA(pkt, data)
    pkt:PutLenString(data.type)
end

function CmdParser:CMD_HOUSE_SHOW_DATA(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.queryType)
end

function CmdParser:CMD_HOUSE_ROOM_SHOW_DATA(pkt, data)
    pkt:PutLenString(data.house_id)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_HOUSE_FRIEND_VISIT(pkt, data)
    pkt:PutLenString(data.char_name)
end

function CmdParser:CMD_HOUSE_GOTO_CLEAN(pkt, data)
    pkt:PutLenString(data.char_name)
end

function CmdParser:CMD_HOUSE_RENAME(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_HOUSE_AUTOWALK(pkt, data)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.autoWalkStr)
end

function CmdParser:CMD_CACHE_AUTO_WALK_MSG(pkt, data)
    pkt:PutLenString(data.autoWalkStr)
    pkt:PutLenString(data.homeId or "")
    pkt:PutLenString(data.taskType or "")
    pkt:PutLenString(data.mapName or "")
    pkt:PutLenString(data.serverName or "")
end

function CmdParser:CMD_FINISH_JINGUANGFU(pkt, data)
    pkt:PutChar(data.perfect)
end

function CmdParser:CMD_HOUSE_PLAYER_PRACTICE(pkt, data)
    pkt:PutLenString(data.action)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_WELCOME_DRAW_REQUEST(pkt, data)
    pkt:PutChar(data.flag)  -- 其中 0 == 打开界面，1 == 请求抽奖，2 == 领取奖品
end

function CmdParser:CMD_RESPONSE_CLIENT_SIGNATURE(pkt, data)
    pkt:PutLenString2(data.signature)
    pkt:PutLenString(data.package_name)
    pkt:PutChar(data.isEmulator and 1 or 0)
end

-- 客户端请求退出小游戏
function CmdParser:CMD_AUTUMN_2017_QUIT(pkt, data)
    pkt:PutLenString(data.type)  -- 请求类型 ：pause = 暂停游戏， resume = 恢复游戏，stop = 结束游戏
end

-- 请求接取月饼
function CmdParser:CMD_AUTUMN_2017_PLAY(pkt, data)
    pkt:PutLenString(data.gid)    -- 月饼 GID
end

function CmdParser:CMD_HOUSE_REQUEST_PET_FEED_INFO(pkt, data)
    pkt:PutLenString(data.furniture_iid)
end

-- 前往协助好友打理农田
function CmdParser:CMD_HOUSE_FARM_GOTO_HELP(pkt, data)
    pkt:PutLenString(data.friend_name)
end

function CmdParser:CMD_RECORD_SHUAD_LOG(pkt, data)
    pkt:PutLenString(data.action)
    pkt:PutLenString2(data.log_str)
end

function CmdParser:CMD_SET_CLIENT_USER_STATE(pkt, data)
    pkt:PutLenString(data.state)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_HOUSE_FARM_ACTION(pkt, data)
    pkt:PutChar(data.action)    -- 1 种植  2 打理  3 收获 4 铲除
    pkt:PutChar(data.farm_index - 1)
    pkt:PutLenString(data.para)
end

-- 客户端请求具体赛区的数据
function CmdParser:CMD_CSL_LEAGUE_DATA(pkt, data)
    pkt:PutShort(data.season_no)
    pkt:PutShort(data.level_section)
    pkt:PutChar(data.league_no)
end

-- 客户端请求比赛积分榜
function CmdParser:CMD_CSL_MATCH_DATA(pkt, data)
    pkt:PutShort(data.level)
    pkt:PutLenString(data.match_name)
end

-- 通知个人总积分榜
function CmdParser:CMD_CSL_CONTRIB_TOP_DATA(pkt, data)
    pkt:PutShort(data.level)
end

function CmdParser:CMD_HOUSE_START_COOKING(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutLenString(data.cooking_name)
    pkt:PutLong(data.num)
end

function CmdParser:CMD_HOUSE_ENTRUST(pkt, data)
    pkt:PutChar(data.index)
end

function CmdParser:CMD_HOUSE_START_MAKE_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutLenString(data.furniture_name)
    pkt:PutChar(data.is_use_limit)
end

-- 请求队伍信息
function CmdParser:CMD_REFRESH_REQUEST_INFO(pkt, data)
    pkt:PutLenString(data.ask_type or "")
end

-- 提杆
function CmdParser:CMD_HOUSE_TIGAN(pkt, data)
    pkt:PutChar(data.no)
end

-- 拉扯
function CmdParser:CMD_HOUSE_LACHE(pkt, data)
    pkt:PutLenString(data.key)
    pkt:PutLenString(data.result)  -- "win" : 成功, "lose" : 失败，该字段需要使用 key 进行加密之后再发送给服务端
end

-- 补充鱼竿
function CmdParser:CMD_HOUSE_ADD_POLE_NUM(pkt, data)
    pkt:PutLenString(data.pole_name)
    pkt:PutLong(data.num)
end

-- 补充鱼饵
function CmdParser:CMD_HOUSE_ADD_BAIT_NUM(pkt, data)
    pkt:PutLenString(data.bait_name)
    pkt:PutLong(data.num)
end

function CmdParser:CMD_HOUSE_SELECT_TOOLS(pkt, data)
    pkt:PutLenString(data.pole_name)
    pkt:PutLenString(data.bait_name)
end

-- 提交所需材料
function CmdParser:CMD_SUBMIT_NEED_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutChar(data.index)
    pkt:PutLenString(data.item_name)
    pkt:PutChar(data.num)
end

-- 提交赠礼材料
function CmdParser:CMD_SUBMIT_GIFT_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutChar(data.index)
    pkt:PutLong(data.item_pos)
    pkt:PutChar(data.num)
end

-- 移除所需材料
function CmdParser:CMD_UNSUBMIT_NEED_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutChar(data.index)
end

-- 移除赠礼材料
function CmdParser:CMD_UNSUBMIT_GIFT_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutChar(data.index)
end

-- 发布
function CmdParser:CMD_PUBLISH_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutLenString(data.msg)
end

-- 请求好友求助的材料信息
function CmdParser:CMD_FRIEND_EXCHANGE_MATERIAL_DATA(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_EXCHANGE_MATERIAL(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.pos)
    pkt:PutLong(data.item_pos)
end

-- 中秋博饼请求购买信息
function CmdParser:CMD_AUTUMN_2017_BUY(pkt, data)
    pkt:PutChar(data.flag)
end

-- 重阳节品尝菜肴
function CmdParser:CMD_CHONGYANG_2017_TASTE(pkt, data)
    pkt:PutLong(data.npc_id)
    pkt:PutChar(data.no)
end

-- 选择培育属性
function CmdParser:CMD_PARTY_PYJS_SELECT_ATTRIB(pkt, data)
    pkt:PutLenString(data.name)
end

-- 领取培育巨兽任务
function CmdParser:CMD_PARTY_PYJS_FETCH_TASK(pkt, data)
    pkt:PutLenString(data.name)
end

-- 完成培育巨兽任务
function CmdParser:CMD_PARTY_PYJS_FINISH_TASK(pkt, data)
    pkt:PutLenString(data.name)
end

-- 查询活动的状态
function CmdParser:CMD_QUERY_PYJS(pkt, data)
    pkt:PutChar(data.type)
end

-- 客户端请求戳泡泡
function CmdParser:CMD_PARTY_YZXL_POKE(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 客户端请求暂停、退出、取消暂停
function CmdParser:CMD_PARTY_YZXL_QUIT(pkt, data)
    pkt:PutLenString(data.type)
end

-- 客户端通知飘走的泡泡
function CmdParser:CMD_PARTY_YZXL_REMOVE(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 客户端请求重新戳泡泡
function CmdParser:CMD_PARTY_YZXL_REPLAY(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 查询活动的状态 帮派活动，挑战巨兽
function CmdParser:CMD_QUERY_TZJS(pkt, data)
    pkt:PutChar(data.type)
end

-- 购买管家
function CmdParser:CMD_HOUSE_BUY_GUANJIA(pkt, data)
    pkt:PutLenString(data.gj_type)
end

-- 选择管家
function CmdParser:CMD_HOUSE_SELECT_GUANJIA(pkt, data)
    pkt:PutLenString(data.gj_type)
end

-- 管家改名
function CmdParser:CMD_HOUSE_CHANGE_GUANJIA_NAME(pkt, data)
    pkt:PutLenString(data.gj_type)
    pkt:PutLenString(data.new_name)
end

function CmdParser:CMD_HOUSE_ADD_YH_INFO(pkt, data)
    pkt:PutLenString(data.yh_type)
end

function CmdParser:CMD_HOUSE_CHANGE_YH_NAME(pkt, data)
    pkt:PutLenString(data.yh_type)
    pkt:PutLenString(data.new_name)
end

function CmdParser:CMD_HOUSE_CHANGE_YD_NAME(pkt, data)
    pkt:PutLenString(data.yd_type)
    pkt:PutLenString(data.new_name)
end

function CmdParser:CMD_REQUEST_TEMP_FRIEND_STATE(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.dist_name)
end

-- 抢购商品2017光棍节
function CmdParser:CMD_SINGLES_2017_GOODS_BUY(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.amount)
    pkt:PutChar(data.quota)
end

-- 刷新商品2017光棍节
function CmdParser:CMD_SINGLES_2017_GOODS_REFRESH(pkt, data)
    pkt:PutChar(data.auto)
end

-- 客户端请求成就数据
function CmdParser:CMD_ACHIEVE_VIEW(pkt, data)
    pkt:PutChar(data.category)
end

-- 客户端请求连续交易系统的卖家
function CmdParser:CMD_EXCHANGE_CONTACT_SELLER(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLenString(data.para)
end

-- 集市请求修改价格
function CmdParser:CMD_STALL_CHANGE_PRICE(pkt, data)
    pkt:PutLenString(data.goods_gid)
      pkt:PutLong(data.price)
end

-- 操作西域飞毯
function CmdParser:CMD_HOUSE_OPER_XYFT(pkt, data)
    pkt:PutLong(data.furniture_pos)
end

-- 修改头像
function CmdParser:CMD_BLOG_CHANGE_ICON(pkt, data)
    pkt:PutLenString(data.icon_img)
end


-- 修改地理位置
function CmdParser:CMD_BLOG_CHANGE_LOCATION(pkt, data)
    pkt:PutLenString(data.location)
end

-- 修改签名
function CmdParser:CMD_BLOG_CHANGE_SIGNATURE(pkt, data)
    pkt:PutLenString(data.text)
    pkt:PutLenString(data.voice)
    pkt:PutChar(data.voice_duraction)
end

-- 修改标签
function CmdParser:CMD_BLOG_CHANGE_TAG(pkt, data)
    pkt:PutLenString(data.tag)
end

-- 请求上传资源的 gid
function CmdParser:CMD_BLOG_RESOURE_GID(pkt, data)
    pkt:PutChar(data.op_type)
    pkt:PutShort(#data.suffixs)
    for i = 1, #data.suffixs do
        pkt:PutLenString(data.suffixs[i])
    end
    pkt:PutLenString(data.cookie)
end

-- 请求打开某人的个人空间
function CmdParser:CMD_BLOG_OPEN_BLOG(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.user_gid)
    pkt:PutChar(data.openType)   -- 1 朋友圈  2 留言板
end

-- 请求举报
function CmdParser:CMD_BLOG_REPORT(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.user_gid)
    pkt:PutChar(data.op_type)
    pkt:PutLenString(data.text)
end

-- 查看留言板
function CmdParser:CMD_BLOG_MESSAGE_VIEW(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.host_gid)     -- 空间主人 GID
    pkt:PutLenString(data.message_iid)   -- 留言起始ID
    pkt:PutLong(data.message_time)      -- 留言起始时间
    pkt:PutChar(data.message_num)       -- 查询留言数量
    pkt:PutChar(data.query_type)        -- 请求类型
end

-- 发布留言
function CmdParser:CMD_BLOG_MESSAGE_WRITE(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.host_gid)
    pkt:PutLenString(data.target_gid)
    pkt:PutLenString(data.target_iid)
    pkt:PutLenString(data.target_dist)
    pkt:PutLenString2(data.msg)
end

-- 删除留言
function CmdParser:CMD_BLOG_MESSAGE_DELETE(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.host_gid)
    pkt:PutLenString(data.message_iid) -- 消息唯一标识
end

-- 赠送鲜花
function CmdParser:CMD_BLOG_FLOWER_PRESENT(pkt, data)
    pkt:PutLenString(data.host_gid) -- 空间主人 GID
    pkt:PutLenString(data.flower)   -- 鲜花名字，即类型
end

-- 鲜花查看
function CmdParser:CMD_BLOG_FLOWER_OPEN(pkt, data)
    pkt:PutLenString(data.host_gid)
end

-- 查看送花记录
function CmdParser:CMD_BLOG_FLOWER_VIEW(pkt, data)
    pkt:PutLenString(data.host_gid)  -- 空间主人 GID
    pkt:PutLenString(data.note_iid)   -- 留言起始ID
    pkt:PutLong(data.note_time)      -- 留言起始时间
    pkt:PutChar(data.note_num)       -- 查询留言数量
end

-- 请求空间人气数据
function CmdParser:CMD_BLOG_FLOWER_UPDATE(pkt, data)
    pkt:PutLenString(data.user_dist)  -- 空间主人 GID
    pkt:PutLenString(data.char_gid)  --
end


-- 发表状态
function CmdParser:CMD_BLOG_PUBLISH_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.text)
    pkt:PutLenString(data.img_str)
    pkt:PutChar(data.viewType)       -- 发表请求时的，是否查看个人动态
end

-- 删除状态
function CmdParser:CMD_BLOG_DELETE_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.sid)
end

-- 请求状态列表
function CmdParser:CMD_BLOG_REQUEST_STATUS_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.user_gid)
    pkt:PutLenString(data.last_sid)
    pkt:PutChar(data.viewType)
end

function CmdParser:CMD_BLOG_STATUS_LIST_ABOUT_ME(pkt, data)
    pkt:PutLenString(data.last_sid)
end

function CmdParser:CMD_BLOG_MESSAGE_LIST_ABOUT_ME(pkt, data)
    pkt:PutLenString(data.last_sid)
    pkt:PutChar(data.num)
end


-- 请求某条状态的所有点赞玩家
function CmdParser:CMD_BLOG_REQUEST_LIKE_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.sid)
end

-- 点赞
function CmdParser:CMD_BLOG_LIKE_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.uid)
    pkt:PutLenString(data.sid)
end

-- 发表评论
function CmdParser:CMD_BLOG_PUBLISH_ONE_COMMENT(pkt, data)
    pkt:PutLenString(data.status_dist)
    pkt:PutLenString(data.uid)  -- 发表状态的玩家GID
    pkt:PutLenString(data.sid)  -- 状态GID
    pkt:PutShort(data.reply_cid) -- 回复哪一条评论 若单纯回复动态，则0
    pkt:PutLenString(data.reply_gid) -- 回复玩家的GID
    pkt:PutLenString(data.reply_dist) -- 回复玩家的区组
    pkt:PutLenString(data.text)  -- 回复内容
    pkt:PutChar(data.is_expand)
end

-- 举报某个动态
function CmdParser:CMD_BLOG_REPORT_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.uid)  -- 发表状态的玩家GID
    pkt:PutLenString(data.sid)  -- 状态GID
end

-- 切换个人空间状态 type: 0表示查看所有人的状态  1表示查看自己的状态
function CmdParser:CMD_BLOG_SWITCH_VIEW_SETTING(pkt, data)
    pkt:PutChar(data.type)
end

-- 请求所有评论数据
function CmdParser:CMD_BLOG_ALL_COMMENT_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.sid)  -- 状态GID
end

-- 删除评论
function CmdParser:CMD_BLOG_DELETE_ONE_COMMENT(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.sid)  -- 状态GID
    pkt:PutShort(data.cid)  -- 状态GID
    pkt:PutChar(data.isExpand)
end

function CmdParser:CMD_HMAC_SHA1_BASE64(pkt, data)
    pkt:PutLenString2(data.key)
    local count = data.contents and #data.contents or 0
    pkt:PutShort(count)
    for i = 1, count do
        pkt:PutLenString2(data.contents[i])
	end
end

-- 首充礼包界面白果儿
function CmdParser:CMD_SHOUCHONG_CARD_INFO(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.name)
end

-- 客户端请求布阵界面数据
function CmdParser:CMD_DC_CONFIRM_PETS(pkt, data)
    count = 6;
    pkt:PutShort(count)
    for i = 1, count do
        if data[i] then
            local pet = PetMgr:getPetById(data[i])
            if pet then
                pkt:PutChar(pet:queryBasicInt("no"));
                pkt:PutLenString(pet:queryBasic("name"));
            else
                pkt:PutChar(0);
                pkt:PutLenString("");
end
        else
            pkt:PutChar(0);
            pkt:PutLenString("");
        end
    end
end

-- 客户端发起挑战
function CmdParser:CMD_DC_CHALLENGE_OPPONENT(pkt, data)
    pkt:PutChar(data.no)
end

-- 宠物继承预览
function CmdParser:CMD_PREVIEW_PET_INHERIT(pkt, data)
    pkt:PutChar(data.no1)
    pkt:PutChar(data.no2)
end

-- 客户端请求抽奖
function CmdParser:CMD_NEW_LOTTERY_DRAW(pkt, data)
    pkt:PutChar(data.type)  -- 1 普通抽奖，2 大额抽奖
end

-- 客户端请求出售金钱的信息
function CmdParser:CMD_TRADING_SELL_CASH(pkt, data)
    pkt:PutLenString(data.goods_gid)
end

function CmdParser:CMD_SIMULATOR_LOGIN(pkt, data)
    self:CMD_LOGIN(pkt, data)
end

function CmdParser:CMD_CLIENT_ERR_OCCUR(pkt, data)
    pkt:PutShort(data.errType)
    pkt:PutLenString2(data.msg)
end

-- 客户端进行好运鉴宝
function CmdParser:CMD_NEWYEAR_2018_HYJB(pkt, data)
    pkt:PutChar(data.type)  -- nt8，type（0：免费鉴定；1：付费鉴定；2：领取道具；3：关闭界面）
end

-- 获取群组的 @ 信息
function CmdParser:CMD_CHAT_GROUP_AITE_INFO(pkt, data)
    pkt:PutLenString(data.group_id)
end

-- 2018 元旦活动罗盘寻踪
function CmdParser:CMD_NEWYEAR_2018_LPXZ(pkt, data)
    pkt:PutLenString(data.status)
end

-- 请求聚宝斋寄售角色的居所数据
function CmdParser:CMD_TRADING_HOUSE_DATA(pkt, data)
    pkt:PutLenString(data.house_id)
end

-- 客户端设置仙魔点自动加点
function CmdParser:CMD_SET_RECOMMEND_XMD(pkt, data)
    pkt:PutChar(data.addType)
    pkt:PutChar(data.isOpen)
end

-- 客户端分配仙魔点
function CmdParser:CMD_ASSIGN_XMD(pkt, data)
    pkt:PutShort(data.xian)
    pkt:PutShort(data.mo)
end

-- 打雪战 操作游戏
function CmdParser:CMD_WINTER2018_DAXZ_OPER(pkt, data)
    pkt:PutChar(data.oper)  -- (1. 集雪；2. 丢雪球；3. 防御)
end

-- 2018 寒假作业 - 客户端上传答案
function CmdParser:CMD_WINTER_2018_HJZY(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString(data.answer)
    pkt:PutLenString(data.opType)
end

-- 2018 冻柿子  客户端选择柿子
function CmdParser:CMD_DONGSZ_2018_EAT(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 2018 冻柿子  客户端请求选中柿子
function CmdParser:CMD_DONGSZ_2018_SELECT(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_SHENMI_DALI_PICK(pkt, data)
    pkt:PutChar(data.index)
end

-- 领取第 n 天的登录礼包
function CmdParser:CMD_SEVENDAY_GIFT_FETCH(pkt, data)
    pkt:PutChar(data.day)
end

function CmdParser:CMD_SUBMIT_XUEJING_ITEM(pkt, data)
    pkt:PutLenString(data.items_pos)
end

function CmdParser:CMD_AUTO_FIGHT_SET_DATA(pkt, data)
    pkt:PutLong(data.id)                 -- 对象id
    pkt:PutChar(data.auto_select)        -- 没蓝情况下，普攻还是补蓝
    pkt:PutChar(data.multi_index)        -- 当前使用的自动战斗索引，1 表示使用组合自动战斗，0 表示使用普通自动战斗
    pkt:PutChar(data.action)             -- 普通自动战斗动作
    pkt:PutLong(data.para)               -- 普通自动战斗动作参数,部分字段名差别，所以 or以下

    pkt:PutShort(data.multi_count)             -- 组合自动战斗条数
    for i = 1, data.multi_count do
        pkt:PutChar(data.autoFightData[i].action)             -- 组合自动战斗动作
        pkt:PutLong(data.autoFightData[i].para)               -- 组合自动战斗动作参数,部分字段名差别，所以 or以下
        pkt:PutChar(data.autoFightData[i].round)               -- 组合自动战斗回合数
    end
end

function CmdParser:CMD_MAILBOX_GATHER_PRIVILEGE(pkt, data)
    pkt:PutLenString(data.mail_id)
    pkt:PutShort(data.mail_oper)        -- 操作类型，0 = 读取， 1 = 提交， 2 = 删除
    pkt:PutLenString(data.name or "")         -- 真实姓名
    pkt:PutLenString(data.idcard or "")       -- 身份证号
    pkt:PutLenString(data.phone or "")        -- 手机号码
    pkt:PutLenString(data.wechat or "")       -- 微信
    pkt:PutLenString2(data.address or "")     -- 联系地址
    pkt:PutLenString(data.birth or "")        -- 出生日期
end

-- 返回选择结果
function CmdParser:CMD_SELECT_BONUS_RESULT(pkt, data)
    pkt:PutLenString(data.source)
    pkt:PutLenString(data.select)
end

-- 客户端请求金钱商品的标准价格
function CmdParser:CMD_GOLD_STALL_CASH_PRICE(pkt, data)
    pkt:PutLong(data.name) -- 金钱商品类型
end

-- 请求购买金钱商品
function CmdParser:CMD_GOLD_STALL_BUY_CASH(pkt, data)
    pkt:PutLong(data.name)         -- 金钱商品类型
    pkt:PutLong(data.expect_price) -- 客户端显示的价格
end

-- 举报玩家
-- type取值为:name、talk、cheater、other
-- 如果type为talk
--    reason为消息内容，注意这里应该是服务器下发的消息原文
--    para1为消息发送时间
--    para2为消息checksum值，MSG_MESSAGE_EX中下发
function CmdParser:CMD_REPORT_USER(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.user_gid)
    pkt:PutLenString(data.user_name)
    pkt:PutLenString(data.type)
    pkt:PutShort(data.count)

    for i = 1, data.count do
        pkt:PutLenString2(data.content[i].reason)
        pkt:PutLenString(data.content[i].para1)
        pkt:PutLenString(data.content[i].para2)
        pkt:PutLenString(data.content[i].para3)
    end
end

-- 请求集市交易记录详细信息
function CmdParser:CMD_STALL_RECORD_DETAIL(pkt, data)
    pkt:PutLenString(data.record_id)
end

-- 请求珍宝交易记录详细信息
function CmdParser:CMD_GOLD_STALL_RECORD_DETAIL(pkt, data)
    pkt:PutLenString(data.record_id)
end

-- 使用聊天装饰
function CmdParser:CMD_DECORATION_APPLY(pkt, data)
    pkt:PutShort(data.count)
    for i = 1, data.count do
        pkt:PutLenString(data.list[i].type)
        pkt:PutLenString(data.list[i].name)
    end
end

-- 请求获取某个角色的个人空间装饰信息
function CmdParser:CMD_BLOG_DECORATION_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.user_gid)
end

function CmdParser:CMD_EXECUTE_RESULT(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLenString2(data.result)
    pkt:PutChar(data.finish or 1)
end

function CmdParser:CMD_AUTO_FIGHT_SET_VICTIM(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.friend_id)
    pkt:PutLenString(data.enemy_id)
end

-- 搜索战斗录像列表
function CmdParser:CMD_ADMIN_BROADCAST_COMBAT_LIST(pkt, data)
    pkt:PutLenString(data.dist)
    pkt:PutLenString(data.combat_type)
    pkt:PutLenString(data.name_or_gid)
    pkt:PutLong(data.begin_time)
    pkt:PutLong(data.end_time)
end

-- 查看单场战斗录像
function CmdParser:CMD_ADMIN_REQUEST_LOOKON_GDDB_COMBAT(pkt, data)
    pkt:PutLenString(data.combat_id)
end
--
function CmdParser:CMD_FETCH_STORE_SURPLUS(pkt, data)

end

--  客户端请求总榜数据
function CmdParser:CMD_CSC_RANK_DATA_TOP(pkt, data)
    pkt:PutShort(data.season)
    pkt:PutShort(data.zone)
end

-- 客户端请求段位榜数据
function CmdParser:CMD_CSC_RANK_DATA_STAGE(pkt, data)
    pkt:PutShort(data.season)  -- 第几届
    pkt:PutShort(data.zone)    -- 赛区编号
end

-- 客户端请求设置匹配模式
function CmdParser:CMD_CSC_SET_COMBAT_MODE(pkt, data)
    pkt:PutLenString(data.combat_mode)
end

-- 客户端请求设置自动匹配状态
function CmdParser:CMD_CSC_SET_AUTO_MATCH(pkt, data)
    pkt:PutChar(data.enable)
end

-- 客户端请求设置匹配队员数据
function CmdParser:CMD_START_MATCH_TEAM_LEADER_KFJJC(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.minLevel)
    pkt:PutShort(data.maxLevel)
    pkt:PutLong(data.minTao * Const.ONE_YEAR_TAO)
    pkt:PutLong(data.maxTao * Const.ONE_YEAR_TAO)
    pkt:PutShort(#data.polars)
    for i = 1, #data.polars do
        pkt:PutChar(data.polars[i])
    end
end

-- 通过便捷使用框使用道具
function CmdParser:CMD_QUICK_USE_ITEM(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutChar(data.doubleEnabel)
    pkt:PutChar(data.chongfsEnable)
end

-- 远程使用家具
function CmdParser:CMD_HOUSE_REMOTE_USE_FURNITURE(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutLenString(data.action)
    pkt:PutLenString(data.para1)
    pkt:PutLenString(data.para2)
end

-- 客户端请求修改队伍顺序
function CmdParser:CMD_TEAM_CHANGE_SEQUENCE(pkt, data)
    pkt:PutLong(data.old_id)
    pkt:PutLong(data.new_id)
    pkt:PutLong(data.old_pos)
    pkt:PutLong(data.new_pos)
end

-- 2018劳动节活动客户端通知服务器发生战斗
function CmdParser:CMD_LDJ_2018_NOTIFY_COMBAT(pkt, data)
    pkt:PutShort(data.meX)
    pkt:PutShort(data.meY)
    pkt:PutLong(data.npcId)
    pkt:PutShort(data.npcX)
    pkt:PutShort(data.npcY)
    pkt:PutChar(data.npcDir)
end

-- 2018周年庆 灵猫翻牌
function CmdParser:CMD_LINGMAO_FANPAI_OPER(pkt, data)
    pkt:PutChar(data.oper)
    pkt:PutChar(data.para)
end

function CmdParser:CMD_TRADING_SEARCH_GOODS(pkt, data)
    pkt:PutChar(data.list_type)             -- 1寄售，2公示
    pkt:PutLenString(data.path_str)         -- 搜索类型
    pkt:PutLenString2(data.extra)            -- 搜索条件，同集市 (等级需要指定为 level:50-59)
    pkt:PutLenString2(data.sub_extra)
end

-- 客户端请求操作灵猫
function CmdParser:CMD_ZNQ_2018_OPER_LINGMAO(pkt, data)
    pkt:PutLenString(data.oper) -- forget_skill:遗忘技能，dunwu_skill:顿悟技能，scratch:挠痒，feed:喂食
    pkt:PutLenString(data.para) -- 遗忘的技能名称（oper=forget_skill 时生效）
end

-- 客户端通知挑战好友灵猫
function CmdParser:CMD_ZNQ_2018_LINGMAO_FIGHT(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 客户端请求进行观战
function CmdParser:CMD_ZNQ_2018_LOOKON(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 客户端请求打开切磋界面（请求好友信息）
-- gids(gid以"|"分隔，一次最多6个,空表示只打开界面)
function CmdParser:CMD_ZNQ_2018_REQ_LINGMAO_FRIENDS(pkt, data)
    pkt:PutLenString(data.gids)
end

-- 给好友发送震动
function CmdParser:CMD_SHOCK_FRIEND(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 名人争霸竞猜：客户端查询比赛日信息
function CmdParser:CMD_CG_REQUEST_DAY_INFO(pkt, data)
    pkt:PutChar(data.day)
end

-- 名人争霸竞猜：客户端请求队伍信息
function CmdParser:CMD_CG_REQUEST_TEAM_INFO(pkt, data)
    pkt:PutLenString(data.id)
end

-- 名人争霸竞猜：客户端请求查看战斗录像
function CmdParser:CMD_CG_LOOKON_GDDB_COMBAT(pkt, data)
    pkt:PutLenString(data.competName)
    pkt:PutLenString(data.id)
end

-- 名人争霸竞猜：客户端投票支持队伍
function CmdParser:CMD_CG_SUPPORT_TEAM(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.id)
    pkt:PutLong(data.supports)
end

-- 名人争霸竞猜：客户端请求赛程信息
function CmdParser:CMD_CG_REQUEST_SCHEDULE(pkt, data)
    pkt:PutChar(data.openFlag)
end

-- 修改地理位置
function CmdParser:CMD_LBS_CHANGE_LOCATION(pkt, data)
    pkt:PutLenString(data.location)
    pkt:PutChar(data.type)   -- 1-登录时定位 2-打开界面/切换分页 3-手动定位
    pkt:PutChar(data.result) -- 0:失败 1:成功
end

-- 设置性别
function CmdParser:CMD_LBS_CHANGE_GENDER(pkt, data)
    pkt:PutChar(data.sex)
end

-- 设置年龄
function CmdParser:CMD_LBS_CHANGE_AGE(pkt, data)
    pkt:PutChar(data.age)
end

-- 搜索附近的人
function CmdParser:CMD_LBS_SEARCH_NEAR(pkt, data)
    pkt:PutChar(data.sex)
end

-- 添加区域好友
function CmdParser:CMD_LBS_ADD_FRIEND(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.from_type) -- 通过什么界面发起的操作 1: 区域排行榜 2:附近的人 0:其他
end

-- 发送好友验证并请求添加好友
function CmdParser:CMD_LBS_VERIFY_FRIEND(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.message)
end

-- 同意或拒绝好友验证
function CmdParser:CMD_LBS_FRIEND_VERIFY_RESULT(pkt, data)
    pkt:PutLenString(data.id)
    pkt:PutLenString(data.char_name)
    pkt:PutLenString(data.char_gid)
    pkt:PutChar(data.result)
end

-- 发送跨服聊天消息
function CmdParser:CMD_LBS_FRIEND_TELL(pkt, data)
    self:CMD_FRIEND_TELL_EX(pkt, data)
end

function CmdParser:CMD_LBS_ADD_BLACKLIST_FRIEND(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.gid)
    pkt:PutLong(data.icon or 0)
    pkt:PutShort(data.level or 0)
end

-- 删除区域好友
function CmdParser:CMD_LBS_REMOVE_FRIEND(pkt, data)
    pkt:PutLenString(data.gid)
end

-- 请求区域排行榜数据
function CmdParser:CMD_LBS_RANK_INFO(pkt, data)
    pkt:PutShort(data.type)
end

-- 请求图鉴评论查询列表
function CmdParser:CMD_HANDBOOK_COMMENT_QUERY_LIST(pkt, data)
    pkt:PutLenString(data.key_name)
    pkt:PutLong(data.last_time)
    pkt:PutLenString(data.last_id)
end

-- 发布评论
function CmdParser:CMD_HANDBOOK_COMMENT_PUBLISH(pkt, data)
    pkt:PutLenString(data.key_name)
    pkt:PutLenString(data.comment)
end

-- 删除评论
function CmdParser:CMD_HANDBOOK_COMMENT_DELETE(pkt, data)
    pkt:PutLenString(data.key_name)
    pkt:PutLenString(data.id)
end

-- 点赞
function CmdParser:CMD_HANDBOOK_COMMENT_LIKE(pkt, data)
    pkt:PutLenString(data.key_name)
    pkt:PutLenString(data.id)
end

-- 取出彩凤之魂
function CmdParser:CMD_PET_DELETE_SOUL(pkt, data)
    pkt:PutChar(data.no)
end

-- 夫妻任务-操作游戏
function CmdParser:CMD_DAXZ_OPER(pkt, data)
    pkt:PutChar(data.oper)
end

-- 请求开始摇签
function CmdParser:CMD_DIVINE_START_GAME(pkt, data)
    pkt:PutChar(data.stick)
    pkt:PutChar(data.type)
end

-- 请求结束摇签
function CmdParser:CMD_DIVINE_END_GAME(pkt, data)
    pkt:PutChar(data.stick)
    pkt:PutChar(data.type)
    pkt:PutChar(data.isOk)
end

-- 客户端请求合成耐久度道具
function CmdParser:CMD_MERGE_DURABLE_ITEM(pkt, data)
    local count = #data
    pkt:PutShort(data.index)
    pkt:PutShort(count)
    for i = 1, count do
        local count = #data[i]
        local str = ""
        for j = 1, count do
            str = str .. data[i][j]

            if j < count then
                str = str .. "|"
            end
        end

        pkt:PutLenString2(str)
    end
end

-- 选择位列仙班礼包
function CmdParser:CMD_APPLY_INSIDER_GIFT(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutLenString(data.fasion_name)
end

-- 获取执行玩家的信息
function CmdParser:CMD_GET_CHAR_INFO(pkt, data)
    pkt:PutLenString(data.char_gid) -- 角色 gid
    pkt:PutLenString(data.dlg_type) -- 界面类型
    pkt:PutChar(data.offline)       -- 1 不在线也需要数据
    pkt:PutLenString(data.para)     -- 额外参数，好友验证界面为邮件 id
    pkt:PutLenString(data.user_dist)     -- 区组名
end

-- 在“无名仙境”，玩家与“噬仙虫”发生碰撞时，需要通过以下新增指令通知服务端
function CmdParser:CMD_DUANWU_2018_COLLISION(pkt, data)
    pkt:PutLong(data.monster_id)
    pkt:PutShort(data.x)
    pkt:PutShort(data.y)
    pkt:PutChar(data.dir)
end

-- 客户端发送索引
function CmdParser:CMD_SUMMER_2018_HQZM_INDEX(pkt, data)
    pkt:PutChar(data.no)
end

-- 游戏结束
function CmdParser:CMD_SUMMER_2018_HQZM_GAME_END(pkt, data)
    pkt:PutChar(data.type)
end

-- 元神归位 接收游戏指令
function CmdParser:CMD_YUANSGW_ACCEPTED_COMMAND(pkt, data)
    pkt:PutLong(data.victim_id)          -- 目标ID
    pkt:PutChar(data.action)      -- 动作编号，同策划文档设定的技能编号 1 - 7
    pkt:PutLenString(data.para or "")   -- 额外参数
end

-- 客户端请求聚宝斋自动登录
function CmdParser:CMD_TRADING_AUTO_LOGIN_TOKEN(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_OVERCOME_SET_SIGNATURE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.signature)
end

-- 请求购买、竞拍商品
function CmdParser:CMD_TRADING_BUY_GOODS(pkt, data)
    pkt:PutLenString(data.goods_gid)
end

-- 通知服务端移动结果
function CmdParser:CMD_SUMMER_2018_PUZZLE(pkt, data)
    pkt:PutChar(data.isSubmit)
    pkt:PutLenString(data.mapName)
    pkt:PutChar(data.count)
    for i = 1, data.count do
        pkt:PutChar(data.list[i])
    end
end

-- 吃瓜比赛 - 加速
function CmdParser:CMD_SUMMER_2018_CHIGUA_ACCELERATE(pkt, data)
    pkt:PutLenString(data.text)
end

-- 打开日记本
function CmdParser:CMD_WB_DIARY_SUMMARY(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutShort(data.page)
end

-- 打开一篇日记
function CmdParser:CMD_WB_DIARY(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.diary_id)
end

-- 新增日志
function CmdParser:CMD_WB_DIARY_ADD(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString2(data.content)
    pkt:PutChar(data.flag)
end

-- 编辑日记
function CmdParser:CMD_WB_DIARY_EDIT(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.diary_id)
    pkt:PutLenString2(data.content)
    pkt:PutChar(data.flag)
end

-- 删除日记
function CmdParser:CMD_WB_DIARY_DELETE(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.diary_id)
end

-- 查看纪念日
function CmdParser:CMD_WB_DAY_SUMMARY(pkt, data)
    pkt:PutLenString(data.book_id)
end

-- 新增纪念日
function CmdParser:CMD_WB_DAY_ADD(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.icon)
    pkt:PutLenString(data.name)
    pkt:PutLong(data.day_time)
    pkt:PutLong(data.flag)
end

-- 编辑纪念日
function CmdParser:CMD_WB_DAY_EDIT(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.day_id)
    pkt:PutLenString(data.icon)
    pkt:PutLenString(data.name)
    pkt:PutLong(data.day_time)
    pkt:PutLong(data.flag)
end

-- 删除纪念日
function CmdParser:CMD_WB_DAY_DELETE(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.day_id)
end

-- 关闭纪念册
function CmdParser:CMD_WB_CLOSE_BOOK(pkt, data)
    pkt:PutLenString(data.book_id)
end

-- 设置封面
function CmdParser:CMD_WB_HOME_PIC(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.img or "")
end

-- 提交图片
function CmdParser:CMD_WB_PHOTO_COMMIT(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.img)
    pkt:PutLenString(data.memo)
    pkt:PutChar(data.flag or 0)
end

-- 编辑描述
function CmdParser:CMD_WB_PHOTO_EDIT_MEMO(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.photo_id)
    pkt:PutLenString(data.memo)
    pkt:PutChar(data.flag or 0)
end

-- 删除图片
function CmdParser:CMD_WB_PHOTO_DELETE(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.photo_id)
end

-- 请求相册列表
function CmdParser:CMD_WB_PHOTO_SUMMARY(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutShort(data.page)
end

-- 客户端请求布阵信息
function CmdParser:CMD_LCHJ_REQUEST_PETS_INFO(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.stage)
end

-- 客户端确认布阵信息
function CmdParser:CMD_LCHJ_CONFIRM_PETS_INFO(pkt, data)
    pkt:PutShort(data.count)
    local petList = data.list
    for i = 1, data.count do
        pkt:PutChar(petList[i].no)
        pkt:PutLenString(petList[i].name)
        pkt:PutChar(petList[i].pos)
    end
end

-- 客户端设置宠物的禁用技能信息
function CmdParser:CMD_LCHJ_SET_DISABLE_SKILLS(pkt, data)
    pkt:PutChar(data.no)
    pkt:PutShort(data.count)
    local skillList = data.list
    for i = 1, data.count do
        pkt:PutShort(skillList[i])
    end
end

-- 客户端请求进入战斗
function CmdParser:CMD_LCHJ_CHALLENGE(pkt, data)
    pkt:PutLenString(data.name)
    pkt:PutChar(data.stage)
end

-- 领取合服登录奖励
function CmdParser:CMD_MERGE_LOGIN_GIFT_FETCH(pkt, data)
    pkt:PutChar(data.day)
end

-- 请求领取奖励
function CmdParser:CMD_RECV_HUOYUE_JIANGLI(pkt, data)
    pkt:PutLong(data.open_time)
end

-- 确认战斗结果
function CmdParser:CMD_CSB_GM_CONFIRM_COMBAT_RESULT(pkt, data)
    pkt:PutChar(data.result)            -- 1 确认 0 取消
end

-- 确认最后的冠军,名人争霸
function CmdParser:CMD_CSB_GM_COMMIT_FINAL_WINNER(pkt, data)
    pkt:PutLenString(data.team_id)     -- 队伍id
end

-- 添加区域最近联系人
function CmdParser:CMD_LBS_ADD_FRIEND_TO_TEMP(pkt, data)
    pkt:PutLenString(data.user_gid)
end

-- 举报主页照片
function CmdParser:CMD_WB_REPORT_HOME_PIC(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.img_path)
end

-- 举报照片
function CmdParser:CMD_WB_REPORT_PHOTO(pkt, data)
    pkt:PutLenString(data.book_id)
    pkt:PutLenString(data.photo_id)
end

-- 客栈 - 请求升级客房
function CmdParser:CMD_INN_UPGRADE_ROOM(pkt, data)
    pkt:PutChar(data.id)
end

-- 客栈 - 请求升级餐桌
function CmdParser:CMD_INN_UPGRADE_TABLE(pkt, data)
    pkt:PutChar(data.id)
end

-- 客栈 - 请求改变客人状态
function CmdParser:CMD_INN_CHANGE_GUEST_STATE(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutChar(data.id)
    pkt:PutChar(data.pos)
    pkt:PutChar(data.state)
    pkt:PutLong(data.curTime)
end

-- 客栈 - 开始招待客人
function CmdParser:CMD_INN_ENTERTAIN_GUEST(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutChar(data.id)
    pkt:PutChar(data.pos)
    pkt:PutLong(data.startTime)
    pkt:PutChar(data.duration)
end

-- 客栈随机事件-砍价-客户端进行砍价
function CmdParser:CMD_HEISHI_KANJIA(pkt, data)
    pkt:PutChar(data.kanjia)
end

-- 购买商城道具回调，当道具购买成功/失败（包括关闭界面，取消购买）时通知服务端
function CmdParser:CMD_BUY_CHAR_ITEM_CB(pkt, data)
    pkt:PutLenString(data.from) -- 来源
    pkt:PutChar(data.result)    -- 1 表示购买成功，0 表示购买失败
end

function CmdParser:CMD_WORLD_CUP_2018_SELECT_TEAM(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_WORLD_CUP_2018_FETCH_BONUS(pkt, data)
    pkt:PutLenString(data.stage)
end

-- 客栈 - 请求领取任务奖励
function CmdParser:CMD_INN_TASK_FETCH_BONUS(pkt, data)
    pkt:PutShort(data.id)
end

-- 客栈 - 请求修改客栈名字
function CmdParser:CMD_INN_CHANGE_NAME(pkt, data)
    pkt:PutLenString(data.name)
end

-- 切换标签页
function CmdParser:CMD_FASION_CUSTOM_SWITCH(pkt, data)
    pkt:PutChar(data.fasion_label)
end

-- 穿戴时装
function CmdParser:CMD_FASION_CUSTOM_EQUIP(pkt, data)
    pkt:PutLenString(data.equip_str)
end

-- 购买时装
function CmdParser:CMD_FASION_CUSTOM_BUY(pkt, data)
    pkt:PutLenString(data.name)
end

-- 卸下时装
function CmdParser:CMD_FASION_CUSTOM_UNEQUIP(pkt, data)
    pkt:PutShort(data.pos)
end

-- 收藏柜操作 - 新增
function CmdParser:CMD_FASION_FAVORITE_ADD(pkt, data)
    pkt:PutLenString(data.fav_name)
end

-- 收藏柜操作 - 删除
function CmdParser:CMD_FASION_FAVORITE_DEL(pkt, data)
    pkt:PutLong(data.fav_id)
end

-- 收藏柜操作 - 重命名
function CmdParser:CMD_FASION_FAVORITE_RENAME(pkt, data)
    pkt:PutLong(data.fav_id)
    pkt:PutLenString(data.new_name)
end

-- 收藏柜操作 - 使用
function CmdParser:CMD_FASION_FAVORITE_APPLY(pkt, data)
    pkt:PutLong(data.fav_id)
end

-- 时装自定义展示
function CmdParser:CMD_FASION_CUSTOM_DISABLE(pkt, data)
    pkt:PutChar(data.value)
end

-- 特效开关
function CmdParser:CMD_FASION_EFFECT_DISABLE(pkt, data)
    pkt:PutChar(data.disable)
end

-- 自定义时装 - 批量穿戴
function CmdParser:CMD_FASION_CUSTOM_EQUIP_EX(pkt, data)
    pkt:PutChar(data.is_buy)
    pkt:PutLenString(data.item_names)
end

-- 客户端上报机型信息
function CmdParser:CMD_REPORT_DEVICE(pkt, data)
    pkt:PutLenString(data.device_name)
end


-- 英雄殿修改宣言
function CmdParser:CMD_HERO_SET_SIGNATURE(pkt, data)
	pkt:PutLong(data.id)
	pkt:PutLenString(data.signature)
end

-- 检查生死状的条件
function CmdParser:CMD_LD_CHECK_CONDITION(pkt, data)
	pkt:PutLenString(data.type)
	pkt:PutLenString(data.para1)
    pkt:PutLenString(data.para2)
end

-- 发布生死状
function CmdParser:CMD_LD_START_LIFEDEATH(pkt, data)
	pkt:PutLenString(data.name)     -- 应战方名字
    pkt:PutLong(data.time)          -- 时间
	pkt:PutLenString(data.mode)     -- 模式
    pkt:PutLenString(data.bet_type) -- 赌注类型
    pkt:PutLong(data.bet_num)           -- 赌注的数量
end

-- 请求手续费
function CmdParser:CMD_LD_MATCH_LIFEDEATH_COST(pkt, data)
    pkt:PutShort(data.level)
end

-- 请求生死状比赛数据
function CmdParser:CMD_LD_MATCH_DATA(pkt, data)
    pkt:PutLenString(data.id)
end

-- 接受挑战
function CmdParser:CMD_LD_ACCEPT_MATCH(pkt, data)
    pkt:PutLenString(data.id)
end

-- 观战
function CmdParser:CMD_LD_LOOKON_MATCH(pkt, data)
    pkt:PutLenString(data.id)
end

-- 拒绝挑战
function CmdParser:CMD_LD_REFUSE_MATCH(pkt, data)
    pkt:PutLenString(data.id)
end

-- 参战
function CmdParser:CMD_LD_ENTER_ZHANC(pkt, data)
    pkt:PutLenString(data.id)
end

-- 请求生死状历史数据
function CmdParser:CMD_LD_HISTORY_PAGE(pkt, data)
    pkt:PutLong(data.last_time)
end

-- 分页查询玩家自己的生死状历史数据
function CmdParser:CMD_LD_MY_HISTORY_PAGE(pkt, data)
    pkt:PutLong(data.pos)
    pkt:PutLong(data.last_time)
    pkt:PutChar(data.needGenaral)
end

function CmdParser:CMD_HERO_SET_SIGNATURE(pkt, data)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.signature)
end

-- 批量使用超级神兽丹
function CmdParser:CMD_APPLY_CHAOJISHENSHOUDAN(pkt, data)
    pkt:PutChar(data.no)   -- 宠物 no
    pkt:PutShort(data.num)  -- 超级神兽丹数量
    pkt:PutChar(data.flag) -- 是否优先使用永久限制交易道具
end

-- 查看卷宗
function CmdParser:CMD_DETECTIVE_TASK_CLUE(pkt, data)
    pkt:PutLenString(data.taskName)
end

-- 查看纸条
function CmdParser:CMD_RKSZ_PAPER_MESSAGE(pkt, data)
    pkt:PutLenString(data.taskName)
end

-- 备注
function CmdParser:CMD_DETECTIVE_TASK_CLUE_MEMO(pkt, data)
    pkt:PutLenString(data.taskName)
    pkt:PutLenString(data.state)
    pkt:PutLenString(data.remarks)
end

-- 对暗号
function CmdParser:CMD_RKSZ_ANSWER_CODE(pkt, data)
    pkt:PutLenString(data.code)
end

-- 【探案】江湖绿林 - 结束巡游
function CmdParser:CMD_TANAN_JHLL_GAME_XY(pkt, data)
    pkt:PutChar(data.isFinish)
end

-- 【探案】江湖绿林 - 开始、结束跟踪
function CmdParser:CMD_TANAN_JHLL_GAME_GZ(pkt, data)
    pkt:PutChar(data.isStart)
    pkt:PutChar(data.isFinish)
end

-- 2018教师节答题
function CmdParser:CMD_TEACHER_2018_GAME_S6_SELECT(pkt, data)
    pkt:PutChar(data.answer)
end

function CmdParser:CMD_TEACHER_2018_GAME_S2_SELECT(pkt, data)
    pkt:PutChar(data.power)
end

function CmdParser:CMD_TWZM_BOX_ANSWER(pkt, data)
    local cou = #data
    pkt:PutShort(cou)
    for i = 1, cou do
        pkt:PutChar(data[i]) -- 点击次数(按顺序排列)
    end
end

-- 客户端通知完成了拼图
function CmdParser:CMD_TWZM_FINISH_JIGSAW(pkt, data)
    pkt:PutLenString(data.key)  -- 用于结果检验的 md5 字符串
end

-- 客户端发送拼图状态
function CmdParser:CMD_TWZM_JIGSAW_STATE(pkt, data)
    pkt:PutLenString2(data.status)
end

-- 通知开始摘桃子游戏
function CmdParser:CMD_TWZM_START_PICK_PEACH(pkt, data)
    pkt:PutChar(data.flag) --0表示暂停恢复，1表示开始
end

-- 通知摘桃子游戏得分
function CmdParser:CMD_TWZM_QUIT_PICK_PEACH(pkt, data)
    pkt:PutShort(data.score) --最终得分(提前退出则得分为 -1)
end

-- 客户端发送矩阵变数
function CmdParser:CMD_TWZM_MATRIX_ANSWER(pkt, data)
    local cou = #data
    pkt:PutShort(cou) -- 数字数目
    for i = 1, cou do
        pkt:PutChar(data[i]) -- 数字位置(1-20)。
    end
end

-- 客户端发送矩阵的当前状态
function CmdParser:CMD_TWZM_MATRIX_STATE(pkt, data)
    pkt:PutLenString2(data.status)
end

-- 客户端通知收到的传音信息
function CmdParser:CMD_TWZM_CHUANYINFU_ANSWER(pkt, data)
    pkt:PutLenString(data.key)  -- 用于结果检验的 md5 字符串
    pkt:PutChar(data.type)
    pkt:PutLong(data.num)  -- 尝试次数
end

-- 请求积分排行榜上的队伍数据
function CmdParser:CMD_CSQ_SCORE_TEAM_DATA(pkt, data)
    pkt:PutLenString(data.teamId)
end

-- 请求淘汰赛的队伍数据
function CmdParser:CMD_CSQ_KICKOUT_TEAM_DATA(pkt, data)
    pkt:PutLenString(data.teamId)
end

-- 开始战斗
function CmdParser:CMD_CSQ_GM_START_COMBAT(pkt, data)
    pkt:PutChar(data.matchId)
end

-- 确认战斗结果
function CmdParser:CMD_CSQ_GM_CONFIRM_COMBAT_RESULT(pkt, data)
	pkt:PutChar(data.matchId)
	pkt:PutChar(data.isOk)
end

-- 设置比赛结果
function CmdParser:CMD_CSQ_GM_COMMIT_WINNER(pkt, data)
    pkt:PutChar(data.matchId)
    pkt:PutLenString(data.teamId)
end

-- 客户端请求共鸣属性值
function CmdParser:CMD_PREVIEW_RESONANCE_ATTRIB(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.level)
    pkt:PutLenString(data.attrib)
    pkt:PutChar(data.rebuildLevel)
end

function CmdParser:CMD_TEACHER_2018_HELP(pkt, data)
    pkt:PutLenString(data.desc)
end

-- 客户端通知服务器移除 NPC 聊天
function CmdParser:CMD_REMOVE_NPC_TEMP_MSG(pkt, data)
    pkt:PutShort(data.count)
    for i = 1, data.count do
        pkt:PutLong(data[i])
    end
end

function CmdParser:CMD_LEARN_UPPER_STD_SKILL_COST(pkt, data)
    pkt:PutShort(data.skill_no)
    pkt:PutShort(data.up_level)
end

function CmdParser:CMD_LEARN_UPPER_STD_SKILL(pkt, data)
    pkt:PutShort(data.skill_no)
    pkt:PutShort(data.up_level)
end

function CmdParser:CMD_NATIONAL_2018_SFQJ(pkt, data)
    pkt:PutLenString(data.op_type) -- start：开始、quit：退出、reset：再来一局
end

-- 迷仙镇案使用证物
function CmdParser:CMD_MXAZ_USE_EXHIBIT(pkt, data)
    pkt:PutLong(data.npcId)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_NATIONAL_2018_SFQJ_MOVE(pkt, data)
    pkt:PutChar(data.x)         -- 棋子坐标 x
    pkt:PutChar(data.y)         -- 棋子坐标 y
    pkt:PutChar(data.dir)       -- 棋子移动方向
end

function CmdParser:CMD_AUTUMN_2018_GAME_START(pkt, data)
    pkt:PutChar(data.step)         -- 挑战关卡
end

function CmdParser:CMD_AUTUMN_2018_GAME_FINISH(pkt, data)
    pkt:PutLenString(data.result)
end

-- 大胃王 - 选择变身形象
function CmdParser:CMD_AUTUMN_2018_DWW_SELECT_ICON(pkt, data)
    pkt:PutChar(data.index)
end

-- 大胃王 - 比赛进度
function CmdParser:CMD_AUTUMN_2018_DWW_PROGRESS(pkt, data)
    pkt:PutLenString(data.text)
end

function CmdParser:CMD_TASK_TIP_EX(pkt, data)
    pkt:PutLenString(data.taskName)
end

-- 通知服务端游戏结果
function CmdParser:CMD_CHONGYANG_2018_GAME_FINISH(pkt, data)
    pkt:PutLenString(data.result) --  游戏结果，若通过则result格式须时 tolower(md5(char_gid + play_iid + play_npc))
end

function CmdParser:CMD_CLICK_NPC(pkt, data)
    pkt:PutLong(data.npcId)
end

function CmdParser:CMD_REQUEST_ZZQN_CARD_INFO(pkt, data)
    pkt:PutShort(data.pos)
    pkt:PutLong(data.id)
end


-- 通知服务端游戏结果
function CmdParser:CMD_HALLOWMAX_2018_LYZM_STUDY_RESULT(pkt, data)
    pkt:PutLenString(data.result) --  游戏结果，若通过则result格式须时 tolower(md5(char_gid + play_iid + play_npc))
end


-- 2018万圣节游戏结果
function CmdParser:CMD_HALLOWMAX_2018_LYZM_GAME_RESULT(pkt, data)
    pkt:PutLenString(data.result) -- 游戏结果  使用 game_id 进行加密，sprintf("%d_%s", type, result), type ：1. 表示使用重力；2. 表示使用声控， result: "succ" 表示成功, "fail" 表示失败
end

-- 客户端请求进行校验
function CmdParser:CMD_CHECK_SERVER(pkt, data)
    pkt:PutLenBuffer2(data.buf)
    pkt:PutLong(data.cookie)
end

-- 客户端选择选项
function CmdParser:CMD_QYGD_SELECT_ANSWER_2018(pkt, data)
    pkt:PutChar(data.titleNum)      --  题号
    pkt:PutChar(data.option)         -- 选项
end

-- 购买特效道具
function CmdParser:CMD_FASION_CUSTOM_BUY_EFFECT(pkt, data)
    pkt:PutLenString(data.item_name)
end

-- 购买跟随宠道具
function CmdParser:CMD_BUY_FASHION_PET(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_SET_ACTION_STATUS(pkt, data)
    pkt:PutLong(data.status)
end

-- 客户端关闭界面
function CmdParser:CMD_CLOSE_DIALOG(pkt, data)
    pkt:PutLenString(data.para1)
    pkt:PutLenString(data.para2)
end

-- 客户端关闭界面
function CmdParser:CMD_SXYS_ANSWER_2019(pkt, data)
    pkt:PutChar(data.select_num)
end

function CmdParser:CMD_BWSWZ_NOTIFY_RESULT_2019(pkt, data)
    pkt:PutLenString(data.checksum)
end

-- 冰雪21点 动画播放结束
function CmdParser:CMD_WINTER_2019_BX21D_ACTION_END(pkt, data)
    pkt:PutLenString(data.status)
end

-- 冰雪21点 玩家操作
function CmdParser:CMD_WINTER_2019_BX21D_OPER(pkt, data)
    pkt:PutChar(data.oper)
end

-- 冰雪21点 准备
function CmdParser:CMD_WINTER_2019_BX21D_QUIT(pkt, data)
    pkt:PutLenString(data.status)
end

-- 客户端请求开始游戏
function CmdParser:CMD_CXK_START_GAME_2019(pkt, data)
    pkt:PutChar(data.oper)
end

-- 客户端通知结果
function CmdParser:CMD_CXK_FINISH_GAME_2019(pkt, data)
    pkt:PutChar(data.isQuit)            -- 是否退出界面
    pkt:PutLenString(data.des)          -- 加密后的分数
end

-- 请求开始充值
function CmdParser:CMD_L_START_RECHARGE(pkt, data)
    pkt:PutLenString(data.account)          -- 账号
    pkt:PutShort(data.charge_type)          -- 充值类型
end

-- 请求开始购买会员
function CmdParser:CMD_L_START_BUY_INSIDER(pkt, data)
    pkt:PutLenString(data.account)          -- 账号
    pkt:PutChar(data.type)                  -- 会员类型
end

-- 请求充值的首充数据
function CmdParser:CMD_L_CHARGE_LIST(pkt, data)
    pkt:PutLenString(data.account)          -- 账号
end

-- 请求会员队列数据
function CmdParser:CMD_L_LINE_DATA(pkt, data)
    pkt:PutLenString(data.account)          -- 账号
end

function CmdParser:CMD_HOUSE_PET_STORE_ADD_SIZE(pkt, data)
    pkt:PutLong(data.furniture_pos)
    pkt:PutShort(data.count)
end

function CmdParser:CMD_HOUSE_PET_STORE_OPERATE(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.pos)
end

function CmdParser:CMD_EXCHANGE_EPIC_PET_SUBMIT_DLG(pkt, data)
    pkt:PutLenString(data.target_name)
end

function CmdParser:CMD_EXCHANGE_EPIC_PET_EXCHANGE(pkt, data)
    pkt:PutLenString(data.target)
    pkt:PutShort(#data.pos)
    for i = 1, #data.pos do
        pkt:PutShort(data.pos[i])
    end
end

function CmdParser:CMD_GIVING_RECORD(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_GIVING_RECORD_CARD(pkt, data)
    pkt:PutLenString(data.id)
end

function CmdParser:CMD_KICK_OFF_CLIENT(pkt, data)
    pkt:PutLenString(data.reason)
end

function CmdParser:CMD_MXZA_EXHIBIT_ITEM_LIST(pkt, data)
end

function CmdParser:CMD_MXZA_SUBMIT_EXHIBIT(pkt, data)
    pkt:PutLenString(data.state)
    pkt:PutLenString(data.name)
end

-- 设置固定队称谓
function CmdParser:CMD_SET_FIXED_TEAM_APPELLATION(pkt, data)
    pkt:PutLenString(data.name)
end

function CmdParser:CMD_FIXED_TEAM_OPEN_SUPPLY_DLG(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_FIXED_TEAM_SUPPLY(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutLenString(data.item_name)
end

-- 请求玩家实时快照(若不在线则返回下线时间快照)
function CmdParser:CMD_REQUEST_USER_REALTIME_CARD(pkt, data)
    pkt:PutLenString(data.gid)
end

function CmdParser:CMD_FIXED_TEAM_ONE_KEY(pkt, data)
    pkt:PutLenString(data.gid or "")
end

-- 操作个人招募 新删改查
-- oper取值
--  #define ADD_MESSAGE             1 // 发布信息   para为留言
--  #define CANCEL_MESSAGE          2 // 撤销信息   para为空
--  #define VIEW_DETAIL             3 // 查看信息   para为GID
function CmdParser:CMD_FIXED_TEAM_RECRUIT_SINGLE(pkt, data)
    pkt:PutChar(data.oper)
    pkt:PutLenString2(data.para)
end

-- 查看个人招募信息列表
function CmdParser:CMD_FIXED_TEAM_RECRUIT_SINGLE_QUERY_LIST(pkt, data)
    pkt:PutLenString(data.iid)
    pkt:PutLong(data.time)
    pkt:PutChar(data.polar)
    pkt:PutChar(data.pt_type)
end

-- 操作个人招募信息
-- oper取值
--  #define ADD_MESSAGE             1 // 发布信息   para1为留言，para2为两个寻找玩家的条件"req_polar1;req_pt_type1;req_tao1;req_polar2;req_pt_type2;req_tao2"
--  #define CANCEL_MESSAGE          2 // 撤销信息   para1为空
--  #define VIEW_DETAIL             3 // 查看信息   para1为GID
--  #define TALK_TO_TARGET          4 // 联系对方   para为ID
function CmdParser:CMD_FIXED_TEAM_RECRUIT_TEAM(pkt, data)
    pkt:PutChar(data.oper)
    pkt:PutLenString2(data.para)
    pkt:PutLenString(data.para2)
end

-- 查看队伍招募信息列表
function CmdParser:CMD_FIXED_TEAM_RECRUIT_TEAM_QUERY_LIST(pkt, data)
    pkt:PutLenString(data.iid)
    pkt:PutLong(data.time)
    pkt:PutChar(data.polar)
    pkt:PutChar(data.pt_type)
end

function CmdParser:CMD_L_GET_COMMUNITY_ADDRESS(pkt, data)
    pkt:PutLenString(data.account)
end

function CmdParser:CMD_USE_TONGTIAN_LINGPAI(pkt, data)
    pkt:PutShort(data.pos)
end

function CmdParser:CMD_SET_SHUADAO_RUYI_AMT_STATE(pkt, data)
    pkt:PutChar(data.state)
end

function CmdParser:CMD_MATCH_MAKING_REQ_LIST(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutChar(data.source)
end

function CmdParser:CMD_MATCH_MAKING_REQ_DETAIL(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.isOpen or 0)
end

function CmdParser:CMD_MATCH_MAKING_PUBLISH(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutLenString2(data.message)
end

function CmdParser:CMD_MATCH_MAKING_OPER_ICON(pkt, data)
    pkt:PutLenString(data.portrait or "")
end

function CmdParser:CMD_MATCH_MAKING_OPER_MESSAGE(pkt, data)
    pkt:PutLenString2(data.message)
end

function CmdParser:CMD_MATCH_MAKING_OPER_VOICE(pkt, data)
    pkt:PutLenString(data.voice_addr)
    pkt:PutChar(data.voice_time)
end

function CmdParser:CMD_MATCH_MAKING_OPER_RECV_MSG(pkt, data)
    pkt:PutChar(data.flag)
end

function CmdParser:CMD_MATCH_MAKING_OPER_GENDER(pkt, data)
    pkt:PutChar(data.gender)
end

function CmdParser:CMD_MATCH_MAKING_ADD_FAVORITE(pkt, data)
    pkt:PutChar(data.oper)
    pkt:PutLenString(data.gid or "")
end

function CmdParser:CMD_GOLD_STALL_BID_GOODS(pkt, data)
    pkt:PutLenString(data.goods_id)
    pkt:PutLenString(data.path_str)
    pkt:PutLenString(data.page_str)
    pkt:PutLong(data.old_price)
    pkt:PutLong(data.new_price)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_GOLD_STALL_BUY_AUCTION_GOODS(pkt, data)
        pkt:PutLenString(data.goods_id)
    pkt:PutLenString(data.path_str)
    pkt:PutLenString(data.page_str)
    pkt:PutLong(data.price)
    pkt:PutChar(data.type)
end

-- 选择今日邀约之人
function CmdParser:CMD_YUANXJ_2019_SELECT_TARGET_NPC(pkt, data)
    pkt:PutLenString(data.target_npc)
end

-- 制作约会表现攻略
function CmdParser:CMD_YUANXJ_2019_MAKE_TASK_ITEM(pkt, data)
    pkt:PutLenString(data.para)  -- 格式："情圣秘籍·甜言|情圣秘籍·幽默|情圣秘籍·礼物"
end

-- 2019春节使用工具
function CmdParser:CMD_SPRING_2019_XCXB_USE_TOOL(pkt, data)
    pkt:PutShort(data.x)        -- 横坐标，最小值为 1，最大值为 6
    pkt:PutShort(data.y)        -- 纵坐标，最小值为 1，最大值为 6
    pkt:PutChar(data.tool_type) -- 工具类型，见工具类型定义
end

-- 2019春节购买工具
function CmdParser:CMD_SPRING_2019_XCXB_BUY_TOOL(pkt, data)
    pkt:PutChar(data.tool_type)   -- 工具类型，见工具类型定义.
    pkt:PutShort(data.num)        -- 购买数量
end

function CmdParser:CMD_SPRING_2019_XCXB_GET_BONUS(pkt, data)
    pkt:PutShort(data.x)   -- 工具类型，见工具类型定义.
    pkt:PutShort(data.y)        -- 购买数量
    pkt:PutShort(data.layer_count)
end

function CmdParser:CMD_SPRING_2019_XTCL_COMMIT(pkt, data)
    pkt:PutLenString(data.result)
end

function CmdParser:CMD_GOLD_STALL_PAY_DEPOSIT(pkt, data)
    pkt:PutLenString(data.goods_gid)
    pkt:PutLong(data.expect_price)
    pkt:PutLong(data.deposit)
        pkt:PutLenString(data.path_str)
    pkt:PutLenString(data.page_str)
    pkt:PutChar(data.type)
end

-- 并肩同行 - 领取奖励
function CmdParser:CMD_BJTX_FETCH_BONUS(pkt, data)
    pkt:PutLenString(data.char_gid)   -- 伙伴 gid
    pkt:PutChar(data.index)        -- 领取奖励索引，0 表示从新加入的伙伴变成旧伙伴
end

-- 购买摆件
function CmdParser:CMD_MAP_DECORATION_BUY(pkt, data)
    pkt:PutLenString(data.item_name)   -- 道具名字
end

-- 摆一个摆件
function CmdParser:CMD_MAP_DECORATION_PLACE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLenString(data.item_name)
    pkt:PutShort(data.x)
    pkt:PutShort(data.y)
    pkt:PutShort(data.dir)
    pkt:PutChar(data.ox)
    pkt:PutChar(data.oy)
end

-- 移动一个摆件
function CmdParser:CMD_MAP_DECORATION_MOVE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLong(data.id)
    pkt:PutShort(data.x)
    pkt:PutShort(data.y)
    pkt:PutShort(data.dir)
    pkt:PutChar(data.ox)
    pkt:PutChar(data.oy)
end

-- 移除一个摆件
function CmdParser:CMD_MAP_DECORATION_REMOVE(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutLong(data.id)
end

-- 检查是否是自己的摆件
function CmdParser:CMD_MAP_DECORATION_CHECK(pkt, data)
    pkt:PutLong(data.id)
end



-- 使用愚人节喇叭
function CmdParser:CMD_USE_FOOLS_DAY_LABA(pkt, data)
    pkt:PutLenString(data.npc)
    pkt:PutLenString(data.content)
    pkt:PutShort(data.cardCount or 0)
    for i = 1, data.cardCount or 0 do
        pkt:PutLenString(data.cardParam)
    end
end

-- 结束饮酒
function CmdParser:CMD_FOOLS_DAY_2019_FINISH_GAME(pkt, data)
    pkt:PutLenString(data.result) --  游戏结果，若通过则result格式须时 tolower(md5(char_gid + play_iid + play_npc))
end

function CmdParser:CMD_2019ZNQFP_COMMIT(pkt, data)
    pkt:PutLenString(data.result)
    pkt:PutChar(data.bonus_flag)
end


-- 客户端通知触发了事件
function CmdParser:CMD_SMDG_MOVE(pkt, data)
    pkt:PutChar(data.level)             -- 层数
    pkt:PutShort(data.pos)              -- 当前位置
    pkt:PutLenString(data.has_walk_str) -- 探索区域信息
end

-- 客户端通知迷宫移动信息
function CmdParser:CMD_SMDG_TRIGGER_EVENT(pkt, data)
    pkt:PutChar(data.level)
    pkt:PutChar(data.type) -- 事件类型（1表示指路，2表示遇敌，3表示遇宝）
    pkt:PutLenString(data.right_dir) -- 正确方向(指路时使用，不为空则使用正确方向)
    pkt:PutLenString(data.err_dir)   -- 错误方向(指路时使用，不为空则使用错误方向)
    pkt:PutLenString(data.trea_dir)  -- 宝箱方向
    pkt:PutShort(data.pos)              -- 当前位置
    pkt:PutLenString(data.has_walk_str) -- 探索区域信息
end

-- 客户端通知迷宫通关
function CmdParser:CMD_SMDG_PASS_GAME(pkt, data)
    pkt:PutChar(data.level) -- 层数
    pkt:PutLenString(data.result) -- 校验字符串
end

-- 客户端通知退出迷宫
function CmdParser:CMD_SMDG_QUIT_GAME(pkt, data)
end

-- 2019儿童节护送小龟 客户端通知游戏结果
function CmdParser:CMD_CHILD_DAY_2019_RESULT(pkt, data)
    pkt:PutChar(data.result)
    pkt:PutLenString(data.checkSum)
end

-- 2019儿童节护送小龟 客户端通知服务器触发事件
function CmdParser:CMD_CHILD_DAY_2019_TRIGGER_EVENT(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutShort(data.x)
    pkt:PutShort(data.y)
end

-- 2019儿童节护送小龟 客户端通知服务器析构美食家
function CmdParser:CMD_CHILD_DAY_2019_START_MSJ_FAIL(pkt, data)
end

-- 2019儿童节护送小龟 客户端通知实时数据
function CmdParser:CMD_CHILD_DAY_2019_NOTIFY_DATA(pkt, data)
    pkt:PutLenString(data.gameData)
end

-- 队伍指挥 - 获取自定义命令
function CmdParser:CMD_TEAM_COMMANDER_GET_CMD_LIST(pkt, data)
    pkt:PutChar(data.type)
end

-- 队伍指挥 - 设置自定义命令
function CmdParser:CMD_TEAM_COMMANDER_SET_CMD_LIST(pkt, data)
    pkt:PutChar(data.type)
    pkt:PutChar(data.isReset)
    pkt:PutShort(data.count)
    for i = 1, data.count do
        pkt:PutLenString(data[i])
    end
end

-- 队伍指挥 - 分配、取消指挥权限
function CmdParser:CMD_TEAM_COMMANDER_ASSIGN(pkt, data)
    pkt:PutLenString(data.gid)
    pkt:PutChar(data.flag)
end

-- 队伍指挥 - 战斗中发布队伍指挥指令
function CmdParser:CMD_TEAM_COMMANDER_COMBAT_COMMAND(pkt, data)
    pkt:PutChar(data.toAll)
    pkt:PutLong(data.id)
    pkt:PutLenString(data.command)
end

function CmdParser:CMD_2019ZNQ_CWTX_CLICK(pkt, data)
	pkt:PutShort(data.layer)
	pkt:PutChar(data.x)
	pkt:PutChar(data.y)
end

function CmdParser:CMD_2019ZNQ_CWTX_BONUS_TYPE(pkt, data)
	pkt:PutLenString(data.bonus_type) -- 探索区域信息
end

function CmdParser:CMD_2019ZNQ_CWTX_BACK(pkt, data)
	pkt:PutShort(data.layer)
end

-- 2019 智斗百草提交结果
function CmdParser:CMD_DW_2019_ZDBC_COMMIT(pkt, data)
    pkt:PutLenString(data.answer)
end

function CmdParser:CMD_RANDOM_TTTD_XINGJUN(pkt, data)
	pkt:PutLong(data.pos)
end

function CmdParser:CMD_FASION_CUSTOM_VIEW(pkt, data)
	pkt:PutLenString(data.para)
end

function CmdParser:CMD_SMFJ_BXF_REPORT_RESULT(pkt, data)
	pkt:PutLenString(data.str)
end

function CmdParser:CMD_SMFJ_YLMB_MOVE_STEP(pkt, data)
	pkt:PutChar(data.step)
	pkt:PutChar(data.cmd_no)
end

function CmdParser:CMD_SMFJ_SWZD_MOVE_STEP(pkt, data)
	pkt:PutChar(data.step)
	pkt:PutChar(data.cmd_no)
end

function CmdParser:CMD_SET_PET_FASION_VISIBLE(pkt, data)
	pkt:PutLong(data.no)
	pkt:PutChar(data.visible)
end

-- 更改群主
function CmdParser:CMD_CHANGE_CHAT_GROUP_LEADER(pkt, data)
	pkt:PutLenString(data.changer_gid)
	pkt:PutLenString(data.group_id)
end

function CmdParser:CMD_SMFJ_BSWH_PLAYER_ICON(pkt, data)
	pkt:PutLenString(data.str)
end

function CmdParser:CMD_SMFJ_CJDWW_ADD_PROGRESS(pkt, data)
	pkt:PutLenString(data.str)
end

-- 2019 暑假神秘数字之神秘画卷提交
function CmdParser:CMD_SUMMER_2019_SMSZ_SMHJ_COMMIT(pkt, data)
    pkt:PutChar(data.num)
end

function CmdParser:CMD_LOG_INN_EXCEPTION(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutLenString2(data.log)
end

function CmdParser:CMD_REQUEST_AUTO_WALK_LINE(pkt, data)
	pkt:PutChar(data.line_type)							-- 线路类型（1表示人数最少单线，2表示人数最少双线）
	pkt:PutLenString(data.auto_walk_info)				-- 触发的寻路信息
end

function CmdParser:CMD_LOG_CLIENT_ACTION(pkt, data)
    pkt:PutShort(data.count)
    for i = 1, data.count do
        pkt:PutLenString(data[i].action)
        pkt:PutLenString(data[i].para1)
        pkt:PutLenString(data[i].para2)
        pkt:PutLenString(data[i].para3)
        pkt:PutLenString2(data[i].memo)
    end
end

-- 2019 暑假神秘数字之神秘宝盒提交
function CmdParser:CMD_SUMMER_2019_SMSZ_SMBH_COMMIT(pkt, data)
    pkt:PutLenString(data.num_str) -- 使用 “|” 分割
end

-- 请求货站数据
function CmdParser:CMD_TRADING_SPOT_DATA(pkt, data)
    pkt:PutChar(data.type)
end

-- 收藏商品
function CmdParser:CMD_TRADING_SPOT_COLLECT(pkt, data)
    pkt:PutShort(data.id)
    pkt:PutChar(data.flag)
end

-- 请求货品详情数据
function CmdParser:CMD_TRADING_SPOT_GOODS_DETAIL(pkt, data)
    pkt:PutShort(data.id)
    pkt:PutChar(data.type)
end

-- 请求盈亏数据
function CmdParser:CMD_TRADING_SPOT_PROFIT(pkt, data)
    pkt:PutChar(data.type)
end

-- 购买商品
function CmdParser:CMD_TRADING_SPOT_BUY_GOODS(pkt, data)
    pkt:PutShort(data.id)
    pkt:PutShort(data.num)
    pkt:PutLong(data.price)
end

-- 一键跟买
function CmdParser:CMD_TRADING_SPOT_BID_ONE_PLAN(pkt, data)
    pkt:PutLenString(data.trading_no)
    pkt:PutLenString(data.plan)
    pkt:PutLong(data.total_price)
    pkt:PutLenString(data.char_gid)
    pkt:PutLenString(data.char_name)
end

function CmdParser:CMD_CSML_LEAGUE_DATA(pkt, data)
    pkt:PutShort(data.season_no)
end

-- 客户端请求比赛积分榜
function CmdParser:CMD_CSML_MATCH_DATA(pkt, data)
    pkt:PutLenString(data.match_name)
end


function CmdParser:CMD_BBS_PUBLISH_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.catalog)
	pkt:PutLenString(data.text)
end

function CmdParser:CMD_BBS_DELETE_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.sid)
end

function CmdParser:CMD_BBS_REQUEST_STATUS_LIST(pkt, data)
    pkt:PutLenString(data.catalog)
	pkt:PutLenString(data.last_sid)
end

function CmdParser:CMD_BBS_REQUEST_LIKE_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.sid)
end

function CmdParser:CMD_BBS_PUBLISH_ONE_COMMENT(pkt, data)
    pkt:PutLenString(data.status_dist)
	pkt:PutLenString(data.uid)
	pkt:PutLenString(data.sid)
    pkt:PutShort(data.reply_cid)
	pkt:PutLenString(data.reply_gid)
	pkt:PutLenString(data.reply_dist)
	pkt:PutLenString(data.text)
	pkt:PutChar(data.is_expand)
end

function CmdParser:CMD_BBS_DELETE_ONE_COMMENT(pkt, data)
    pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.sid)
	pkt:PutShort(data.cid)
	pkt:PutChar(data.isExpand)
end

function CmdParser:CMD_BBS_ALL_COMMENT_LIST(pkt, data)
    pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.sid)
end

function CmdParser:CMD_BBS_REPORT_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.uid)
	pkt:PutLenString(data.sid)
end

function CmdParser:CMD_BBS_LIKE_ONE_STATUS(pkt, data)
    pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.uid)
	pkt:PutLenString(data.sid)
end

function CmdParser:CMD_SUMMER_2019_SSWG_END_ACTION(pkt, data)
    pkt:PutLenString(data.status)
end

function CmdParser:CMD_SUMMER_2019_SSWG_OPER(pkt, data)
    pkt:PutChar(data.oper)
	--[[
	#define GAME_OPER_TIPAI         1  // 提牌
	#define GAME_OPER_FANGPAI       2  // 放牌
	#define GAME_OPER_CHOUPAI       3  // 抽牌
	--]]
	pkt:PutLenString(data.para)
end

function CmdParser:CMD_SUMMER_2019_BHKY_RESULT(pkt, data)
    pkt:PutLenString(data.result)
end

function CmdParser:CMD_SUMMER_2019_SXDJ_OPERATE(pkt, data)
    pkt:PutChar(data.index)		-- 位置的索引，与上面格子发送顺序一致
	pkt:PutChar(data.type)		-- 1 打开, 2 移动，para 为目标位置, 3 认输
	pkt:PutLenString(data.para)
end

function CmdParser:CMD_SUMMER_2019_SXDJ_END_ACTION(pkt, data)
    pkt:PutLenString(data.status)
end

function CmdParser:CMD_WQX_ANSWER_QUESTION(pkt, data)	-- 文曲星 - 回答问题
    pkt:PutLenString(data.stage)
	pkt:PutChar(data.question_no)
	pkt:PutLenString(data.answer)
end

function CmdParser:CMD_WQX_CLOSE_DLG(pkt, data)			-- 关闭界面
	pkt:PutLenString(data.stage)
end

function CmdParser:CMD_WQX_APPLY_ITEM(pkt, data)			-- 文曲星 - 使用答题卡
	pkt:PutLenString(data.item_name)
end

function CmdParser:CMD_WQX_HELP_ANSWER_QUESTION(pkt, data)			-- 文曲星 - 使用答题卡
	pkt:PutLenString(data.char_gid)
	pkt:PutLenString(data.help_id)
	pkt:PutChar(data.select_index)
end

function CmdParser:CMD_PET_EXPLORE_MAP_PET_DATA(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutChar(data.map_index)
end

function CmdParser:CMD_PET_EXPLORE_OPER(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutChar(data.type)
    pkt:PutChar(data.map_index)
end

function CmdParser:CMD_PET_EXPLORE_LEARN_SKILL(pkt, data)
    pkt:PutLong(data.pet_id)
    pkt:PutChar(data.skill_id)
end

function CmdParser:CMD_PET_EXPLORE_REPLACE_SKILL(pkt, data)
    pkt:PutLong(data.pet_id)
    pkt:PutChar(data.old_skill_id)
    pkt:PutChar(data.new_skill_id)
end

function CmdParser:CMD_PET_EXPLORE_USE_ITEM(pkt, data)
    pkt:PutLong(data.pet_id)
    pkt:PutChar(data.item_id)
    pkt:PutShort(data.count)
end

function CmdParser:CMD_PET_EXPLORE_MAP_CONDITION_DATA(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutChar(data.map_index)
    pkt:PutLong(data.pet_id1)
    pkt:PutLong(data.pet_id2)
    pkt:PutLong(data.pet_id3)
end

function CmdParser:CMD_PET_EXPLORE_START(pkt, data)
    pkt:PutLong(data.cookie)
    pkt:PutChar(data.map_index)
    pkt:PutLong(data.pet_id1)
    pkt:PutLong(data.pet_id2)
    pkt:PutLong(data.pet_id3)
end

-- 客户端调整水温
function CmdParser:CMD_XCWQ_ADJUST_TEMPERATURE(pkt, data)
    pkt:PutChar(data.type)  -- 0表示降温，1表示升温
end

-- 客户端执行捶背
function CmdParser:CMD_XCWQ_MASSAGE_BACK(pkt, data)
    pkt:PutLong(data.to_id) -- 目标 id
    pkt:PutShort(data.to_x)  -- x 坐标
    pkt:PutShort(data.to_y)  -- y 坐标
    pkt:PutLong(data.cookie)  -- 动作 cookie
end

-- 客户端执行丢肥皂
function CmdParser:CMD_XCWQ_THROW_SOAP(pkt, data)
    pkt:PutLong(data.to_id) -- 目标 id
    pkt:PutShort(data.to_x)  -- x 坐标
    pkt:PutShort(data.to_y)  -- y 坐标
    pkt:PutLong(data.cookie)  -- 动作 cookie
end

-- 分解道具
function CmdParser:CMD_DECOMPOSE_LINGCHEN_ITEM(pkt, data)
    local count = #data
    pkt:PutShort(count) -- 道具数目
    for i = 1, count do
        pkt:PutLong(data[i])  --道具 id
    end
end

-- 兑换道具
function CmdParser:CMD_BUY_LINGCHEN_ITEM(pkt, data)
    pkt:PutLenString(data.name) -- 道具名称
    pkt:PutChar(data.num) -- 道具数目
end

-- 客户端通知执行指令结果
function CmdParser:CMD_SUMMER_2019_XZJS_OPERATE(pkt, data)
    pkt:PutLong(data.no) -- 指令编号（需要使用MSG_SUMMER_2019_XZJS_OPERATE消息中的指令编号）
    local count = #data
    pkt:PutShort(count) -- 指令数
    for i = 1, count do
        pkt:PutChar(data[i])  -- 指令状态（0表示未点击，1表示正确，2表示失败）
    end
end

function CmdParser:CMD_WQX_FINISH_QUESTION(pkt, data)
    pkt:PutLenString(data.stage)
    pkt:PutChar(data.question_no)
end

-- 照料胎儿/灵石
function CmdParser:CMD_CHILD_CARE(pkt, data)
    pkt:PutLenString(data.id) 	-- 娃娃 id
    pkt:PutChar(data.type)  	-- 类型（1表示散步，2表示音乐，3表示按摩，4表示使用安胎药，5表示注入能量）
end

-- 请求 AAA 通知玩家元宝数据
function CmdParser:CMD_L_GET_GOLD_COIN_DATA(pkt, data)
    pkt:PutLenString(data.account)
end

function CmdParser:CMD_L_PRECHARGE_PRESS_BTN(pkt, data)
    pkt:PutLenString(data.account)
    pkt:PutChar(data.type)
end

-- 接生/雕琢
function CmdParser:CMD_CHILD_BIRTH(pkt, data)
    pkt:PutLenString(data.id) 	-- 娃娃 id
end

-- 娃娃改名
function CmdParser:CMD_CHILD_RENAME(pkt, data)
    pkt:PutLenString(data.id) 	-- 娃娃 id
	pkt:PutLenString(data.new_name) 	-- 新的名字
	pkt:PutChar(data.isFirst)  	-- 是否首次
end

-- 注入能量
function CmdParser:CMD_HOUSE_TDLS_INJECT_ENERGY(pkt, data)
    pkt:PutLong(data.pos)
end

-- 通知新的生产信息
function CmdParser:CMD_CHILD_BIRTH_ADD_LOG(pkt, data)
    pkt:PutLenString(data.birth_log)	-- 生产信息
end

-- 通知增加生产进度
function CmdParser:CMD_CHILD_BIRTH_ADD_PROGRESS(pkt, data)
    pkt:PutChar(data.process)	-- 生产信息
end

-- 客户端请求进行灵胎出世
function CmdParser:CMD_HOUSE_TDLS_CHILD_BIRTH(pkt, data)
    pkt:PutLong(data.furniture_id)	-- 生产信息
end

-- 客户端查看状态
function CmdParser:CMD_HOUSE_TDLS_VIEW(pkt, data)
    pkt:PutLong(data.furniture_id)	--
end

-- 存入娃娃金库
function CmdParser:CMD_CHILD_PUT_MONEY(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
	pkt:PutLenString(data.child_name)	-- 娃娃姓名
    pkt:PutLong(data.money)				-- 存入金额
end

-- 娃娃-打水
function CmdParser:CMD_CHILD_BIRTH_WATER(pkt, data)
	pkt:PutChar(data.state)		-- 娃娃id
end

-- 客户端请求抚养信息
function CmdParser:CMD_CHILD_REQUEST_RAISE_INFO(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
	pkt:PutChar(data.type)		--  int8，类型（0表示需要寻路到居所，1表示直接打开界面）
    pkt:PutLenString(data.para or "")		-- 参数
end

-- 客户端对娃娃进行抚养
function CmdParser:CMD_CHILD_RAISE(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
	pkt:PutChar(data.fy_type)		-- 抚养类型
	pkt:PutLenString(data.fy_para)		-- 抚养参数
end

-- 客户端对娃娃设置行程
function CmdParser:CMD_CHILD_SET_SCHEDULE_LIST(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
    pkt:PutLong(data.time)		--
	pkt:PutLong(data.cookie)		-- cookie
	pkt:PutShort(data.count)		-- 抚养个数
	for i = 1, data.count do
		pkt:PutLong(data[i].startTime)		-- 行程开始时间
		pkt:PutChar(data[i].sch_type)		-- 行程类型
	end
end

-- 客户端请求历史行程
function CmdParser:CMD_CHILD_REQUEST_SCHEDULE(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id

end

-- 客户端点击摇篮
function CmdParser:CMD_HOUSE_CRADLE_TALK(pkt, data)
	pkt:PutLong(data.pos)		-- 娃娃id
end

-- 检查单个行程是否合法
function CmdParser:CMD_CHILD_CHECK_SET_SCHEDULE(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
	pkt:PutLong(data.start_time)		-- 开始时间
	pkt:PutChar(data.op_type)		-- 类型
	pkt:PutLong(data.cookie)		-- cookie
	pkt:PutLenString(data.para)		-- 额外参数
end

-- 检测能否修改行程
function CmdParser:CMD_CHILD_CHECK_CHANGE_SCHEDULE(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
	pkt:PutLong(data.record_time)		-- 行程所在日0点
	pkt:PutLong(data.cookie)		-- cookie
end

-- 客户端通知选中娃娃
function CmdParser:CMD_CHILD_SELECT(pkt, data)
	pkt:PutLenString(data.child_id)		-- 娃娃id
end

-- 查看声音列表
function CmdParser:CMD_GOOD_VOICE_SHOW_LIST(pkt, data)
    pkt:PutChar(data.type)  -- 0 发现声音		1 人气声音		2 今日新声		3 搜索声音		(CMD_GOOD_VOICE_SEARCH消息，也会返回MSG_GOOD_VOICE_SHOW_LIST结果，其中list_type为该值)
end

-- 查看声音详情
function CmdParser:CMD_GOOD_VOICE_QUERY_VOICE(pkt, data)
    pkt:PutLenString(data.voice_id)
    pkt:PutChar(data.requestSeasonData or 0)
    pkt:PutChar(data.open_type or 0)        -- 1 为排行版，排行版不需要显示相关按钮
end

-- 收藏声音
function CmdParser:CMD_GOOD_VOICE_COLLECT(pkt, data)
    pkt:PutLenString(data.voice_id)
	pkt:PutChar(data.is_favorite)
end

-- 搜索声音
function CmdParser:CMD_GOOD_VOICE_SEARCH(pkt, data)
    pkt:PutLenString(data.search_text)
end

-- 好声音举报
function CmdParser:CMD_GOOD_VOICE_REPORT(pkt, data)
    pkt:PutLenString(data.voice_id)
	pkt:PutLenString(data.reason)
	pkt:PutChar(data.rp_type)	--  1       // 检测，检测通过之后，服务器主动通知客户端打开举报界面                      2 真正生效
end


-- 点赞
function CmdParser:CMD_GOOD_VOICE_LIKE(pkt, data)
    pkt:PutLenString(data.voice_id)
end

function CmdParser:CMD_GOOD_VOICE_GIVE_FLOWER(pkt, data)
    pkt:PutLenString(data.voice_id)
	pkt:PutLenString(data.flower)
end

-- 上传评委资料
function CmdParser:CMD_GOOD_VOICE_ADD_JUDGE(pkt, data)
    pkt:PutLenString(data.name)
	pkt:PutLenString(data.desc)
	pkt:PutLenString(data.icon_addr)
end

function CmdParser:CMD_GOOD_VOICE_FINAL_VOICES(pkt, data)
	pkt:PutChar(data.day_index)
end

function CmdParser:CMD_GOOD_VOICE_SCORE_DATA(pkt, data)
	pkt:PutShort(data.season_no)
	pkt:PutLenString(data.voice_id)
end

function CmdParser:CMD_GOOD_VOICE_JUDGE_GIVE_SCORE(pkt, data)
	pkt:PutLenString(data.voice_id)
	pkt:PutChar(data.score)
	pkt:PutLenString(data.comment)
end

function CmdParser:CMD_GOOD_VOICE_RANK_LIST(pkt, data)
	pkt:PutShort(data.season_no)
end

function CmdParser:CMD_ADMIN_GOOD_VOICE_DELETE_JUDGE(pkt, data)
	pkt:PutLenString(data.name)
end

function CmdParser:CMD_ADMIN_GOOD_VOICE_DELETE_SCORE(pkt, data)
	pkt:PutLenString(data.voice_id)
	pkt:PutLenString(data.name)
end

function CmdParser:CMD_LEAVE_MESSAGE_VIEW(pkt, data)
	self:CMD_BLOG_MESSAGE_VIEW(pkt, data)
end

function CmdParser:CMD_LEAVE_MESSAGE_WRITE(pkt, data)
    pkt:PutLenString(data.user_dist)
    pkt:PutLenString(data.host_gid)
    pkt:PutLenString(data.target_gid)
    pkt:PutLenString(data.target_iid)
    pkt:PutLenString(data.target_dist)
    pkt:PutLenString2(data.msg)
    pkt:PutLenString(data.para)
end

function CmdParser:CMD_LEAVE_MESSAGE_DELETE(pkt, data)
	self:CMD_BLOG_MESSAGE_DELETE(pkt, data)
end

function CmdParser:CMD_LEAVE_MESSAGE_LIKE(pkt, data)
	-- void cmd_leave_message_like(string user_dist, string char_gid, string message_id);
	pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.char_gid)
	pkt:PutLenString(data.message_id)
end

function CmdParser:CMD_LEAVE_MESSAGE_REPORT(pkt, data)
	-- void cmd_leave_message_like(string user_dist, string char_gid, string message_id);
	pkt:PutLenString(data.user_dist)
	pkt:PutLenString(data.char_gid)
	pkt:PutLenString(data.message_id)
end

function CmdParser:CMD_GOOD_VOICE_UPLOAD(pkt, data)
	pkt:PutLenString(data.title)
	pkt:PutLenString(data.voice_desc)
	pkt:PutLenString(data.voice_addr)
	pkt:PutChar(data.voice_dur)
end

function CmdParser:CMD_ADMIN_GOOD_VOICE_DELETE_VOICE(pkt, data)
	pkt:PutLenString(data.voice_id)
end

-- 请求开始充值
function CmdParser:CMD_L_PRECHARGE_CHARGE(pkt, data)
    pkt:PutLenString(data.account)          -- 账号
    pkt:PutShort(data.charge_type)          -- 充值类型
end

-- 选择时装的编号
function CmdParser:CMD_CHOOSE_FASION(pkt, data)
    pkt:PutLenString(data.type)
    pkt:PutChar(data.index)
end

-- 语音统计
function CmdParser:CMD_VOICE_STAT(pkt, data)
    pkt:PutChar(data.op_type)
    pkt:PutShort(data.duration)
end


function CmdParser:CMD_TRADING_SPOT_GOODS_VOLUME(pkt, data)
    pkt:PutLenString(data.trading_no)
end

function CmdParser:CMD_TRADING_SPOT_LARGE_ORDER_DATA(pkt, data)
    pkt:PutLenString(data.trading_no)
    pkt:PutShort(data.from)
    pkt:PutChar(data.page)
end

function CmdParser:CMD_QIXI_2019_LMQG_SELECT(pkt, data)
	pkt:PutChar(data.martial_no)		--
end

function CmdParser:CMD_CHILD_JOIN_FAMILY(pkt, data)
	pkt:PutLenString(data.id)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_CHILD_HOUSEWORK(pkt, data)
	pkt:PutLenString(data.id)
    pkt:PutChar(data.type)
end

function CmdParser:CMD_CHILD_SUPPLY_ENERGY(pkt, data)
	pkt:PutLenString(data.id)
end

function CmdParser:CMD_CHILD_FOLLOW_ME(pkt, data)
	pkt:PutLenString(data.cid)
    pkt:PutChar(data.flag)
end

function CmdParser:CMD_CHILD_VISIBLE(pkt, data)
	pkt:PutLenString(data.cid)
    pkt:PutChar(data.flag)
end

function CmdParser:CMD_CHILD_PRE_ASSIGN_ATTRIB(pkt, data)
	pkt:PutLenString(data.cid)
    pkt:PutLenString(data.plan)
end

function CmdParser:CMD_CHILD_SURE_ASSIGN_ATTRIB(pkt, data)
	pkt:PutLenString(data.cid)
    pkt:PutLenString(data.plan)
end

-- 领取娃娃日常任务
function CmdParser:CMD_CHILD_FETCH_TASK(pkt, data)
	pkt:PutLenString(data.id)
    pkt:PutLenString(data.task_name)
end

-- 客户端通知退出游戏
function CmdParser:CMD_CHILD_QUIT_GAME(pkt, data)
    pkt:PutChar(data.is_get_reward or 0) -- 是否领取奖励（目前只有“【养育】动物的朋友”需要使用）
end

function CmdParser:CMD_CHILD_SYNC_GAME_DATA(pkt, data)
    pkt:PutLenString(data.task_name)
	pkt:PutLenString2(data.para)
end

function CmdParser:CMD_CHILD_FINISH_GAME(pkt, data)
    pkt:PutLenString(data.task_name)
	pkt:PutLenString(data.result or "") 			-- 游戏结果（“succ”表示胜利，“fail”表示失败）(使用密钥加密)
    pkt:PutLenString(data.socre or "") 			-- 得分（任务“【养育】动物的朋友”需要使用）(使用密钥加密)
	pkt:PutChar(data.guanka or 0)			-- 失败的关卡	1~4

end

function CmdParser:CMD_CHILD_CLICK_TASK_LOG(pkt, data)
    pkt:PutLenString(data.task_name)
end

function CmdParser:CMD_HOUSE_TDLS_MENU(pkt, data)
    pkt:PutLong(data.no)
end

function CmdParser:CMD_SUBMIT_CHILD_UPGRADE_ITEM(pkt, data)
    pkt:PutLenString(data.itemPosStr)
end

-- 补充玩具耐久
function CmdParser:CMD_CHILD_SUPPLY_TOY_DURABILITY(pkt, data)
    pkt:PutLenString(data.child_id)
	pkt:PutLenString(data.toy_name)
    pkt:PutLong(data.toy_id)
end

-- 丢弃玩具
function CmdParser:CMD_CHILD_DROP_TOY(pkt, data)
    pkt:PutLenString(data.child_id)
    pkt:PutLenString(data.toy_name)
end

-- 穿戴玩具
function CmdParser:CMD_CHILD_EQUIP_TOY(pkt, data)
    pkt:PutLenString(data.child_id)
	pkt:PutLenString(data.toy_name)
    pkt:PutLong(data.toy_id)
end

-- 修炼资质
function CmdParser:CMD_CHILD_PRACTICE(pkt, data)
	pkt:PutChar(data.stage)			
    pkt:PutLenString(data.child_id)
    pkt:PutLenString(data.xiulian_type)  -- 修炼类型（气血:"life"，法力:"mana"，速度:"speed"，物攻:"phy"，法攻:"mag"）
end
-- 玩具合成
function CmdParser:CMD_MERGE_CHILD_TOY(pkt, data)
    pkt:PutLong(data.no)					-- 配方编号
    pkt:PutChar(data.hecheng)  -- 合成方式（1表示单次合成非绑定玩具，2表示单次合成绑定玩具，3表示全部合成非绑定玩具，4表示全部合成绑定玩具）
end

-- 请求修炼界面数据
function CmdParser:CMD_CHILD_REQUEST_CULTIVATE_INFO(pkt, data)
    pkt:PutLenString(data.child_id)
end

function CmdParser:CMD_STOP_COMMON_PROGRESS(pkt, data)
    pkt:PutLenString(data.process_type)
end

function CmdParser:CMD_QUERY_CHILD_CARD(pkt, data)
    pkt:PutLenString(data.cid)
end

return CmdParser
