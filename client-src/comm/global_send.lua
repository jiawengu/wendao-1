-- created by cheny Feb/19/2014
-- 命令、消息定义

Cmd = {
    -- from 0x0000
    CMD_ECHO							= 0x10B2,
    MSG_REPLY_ECHO						= 0x10B3,
    CMD_L_GET_ANTIBOT_QUESTION			= 0x0B05,
    CMD_L_CHECK_USER_DATA				= 0x1B03,
    CMD_L_ACCOUNT						= 0x2350,
    CMD_L_GET_SERVER_LIST				= 0x3354,
    CMD_L_CLIENT_CONNECT_AGENT			= 0x3356,
    CMD_LOGIN							= 0x3002,
    CMD_LOGOUT							= 0x0004,
    CMD_LOAD_EXISTED_CHAR				= 0x1060,
    CMD_CHAT_EX							= 0x4062,
    CMD_SELECT_MENU_ITEM				= 0x3038,
    CMD_MULTI_MOVE_TO					= 0xF0C2,
    CMD_OTHER_MOVE_TO                   = 0x40AE,
    CMD_ENTER_ROOM                      = 0x1030,
    CMD_GENERAL_NOTIFY                  = 0xF908,

    -- Combat command from client to server
    CMD_C_DO_ACTION						= 0x3202,
    CMD_C_END_ANIMATE					= 0x2204,
    CMD_C_FLEE							= 0x0206,
    CMD_C_CATCH_PET						= 0x1208,
    CMD_C_SELECT_MENU_ITEM				= 0x220A,
    CMD_C_SET_POS						= 0x120C,

    CMD_REQUEST_ITEM_INFO               = 0x10CD,
    CMD_CHANGE_TITLE                    = 0x10C0,
    CMD_OPEN_MENU                       = 0x1036,
    CMD_QUIT_TEAM                       = 0x001A,
    CMD_KICKOUT                         = 0x1018,
    CMD_RETURN_TEAM                     = 0x001C,
    CMD_LEAVE_TEMP_TEAM                 = 0x1020,
    CMD_ACCEPT                          = 0x1024,
    CMD_REJECT                          = 0x1026,
    CMD_REQUEST_JOIN                    = 0x103C,
    CMD_CHANGE_TEAM_LEADER              = 0x001E,
    CMD_C_SELECT_MENU_ITEM              = 0x220A,
    CMD_OPER_TELEPORT_ITEM              = 0x40CE,
    CMD_ASSIGN_ATTRIB                   = 0x203E,
    CMD_PRE_ASSIGN_ATTRIB               = 0x3802,
    CMD_SET_RECOMMEND_ATTRIB            = 0x2294,
    CMD_SELECT_VISIBLE_PET              = 0x1084,
    CMD_SELECT_CURRENT_PET              = 0x1042,
    CMD_DROP_PET                        = 0x1086,
    CMD_SET_PET_NAME                    = 0x2050,
    CMD_LEARN_SKILL                     = 0x2074,
    CMD_DOWNGRADE_SKILL                 = 0x8073,  -- 技能降级
    CMD_APPLY                           = 0x202C,
    CMD_APPLY_EX                        = 0x5006,
    CMD_FEED_PET                        = 0x204E,
    CMD_SORT_PACK                       = 0x2036,
    CMD_GUARDS_CHANGE_NAME              = 0x10F5,
    CMD_GUARDS_CHEER                    = 0x10FB,
    CMD_CREATE_NEW_CHAR                 = 0x205C,
    CMD_KILL                            = 0x1012,
    CMD_CLOSE_MENU                      = 0x003A,
    CMD_REFRESH_SERVICE_LOG             = 0x10DC,
    CMD_REFRESH_TASK_LOG                = 0x1070,
    CMD_GET                             = 0x104A,
    CMD_MOVE_ON_CARPET                  = 0x10F0,
    CMD_SHIFT                           = 0x1098,

    -- 好友相关
    CMD_ADD_FRIEND                      = 0x2066,
    CMD_REMOVE_FRIEND                   = 0x2068,
    CMD_REFRESH_FRIEND                  = 0x206A,
    CMD_FINGER                          = 0x1072,
    CMD_VERIFY_FRIEND                   = 0xA026,

    -- 请求更新服务器时间
    CMD_ASK_SERVER_TIME                 = 0xA030,

    CMD_FRIEND_TELL_EX                  = 0x506E,

    CMD_CLEAN_REQUEST                   = 0x1096,

    -- from 0x8000
    CMD_TELEPORT                        = 0x8000,
    CMD_SET_RECOMMEND_POLAR             = 0x8002,
    CMD_SET_SHAPE_TEMP                  = 0x8004,
    CMD_PRE_UPGRADE_EQUIP               = 0x8006,
    CMD_UPGRADE_EQUIP                   = 0x8008,
    CMD_BATCH_BUY                       = 0x800A,
    CMD_CREATE_PARTY                    = 0x800C,
    CMD_QUERY_PARTYS                    = 0x800E,
    CMD_PARTY_REJECT_LEVEL              = 0x8010,
    CMD_PARTY_GET_BONUS                 = 0x8012,
    CMD_REFRESH_PARTY_SHOP              = 0x8016,
    CMD_BUY_FROM_PARTY_SHOP             = 0x8018,

    -- from 0x9000
    CMD_FEED_GUARD                      = 0x9002,
    CMD_FRIEND_VERIFY_RESULT            = 0x9004,
    CMD_ADMIN_TEST_SKILL                = 0x9A00,

    -- from 0xA000
    CMD_MAILBOX_OPERATE                 = 0xA000,

    -- from 0xB000
    CMD_OPER_SCENARIOD                  = 0xB001,

    CMD_ANSWER_QUESTIONNAIRE            = 0x5003,

    -- 帮派
    CMD_PARTY_INFO                      = 0x00B2,
    CMD_PARTY_MEMBERS                   = 0x20B8,
    CMD_PARTY_MODIFY_MEMBER             = 0x40BA,
    CMD_PARTY_REQUEST_LIST              = 0x10B0,
    CMD_DEVELOP_SKILL                   = 0x20B0,
    CMD_CONTROL_PARTY_CHANNEL           = 0x2E3A,
    CMD_GET_PARTY_CHANNEL_DENY_LIST     = 0x2E3C,
    CMD_GET_PARTY_LOG                   = 0x21A0,
    CMD_SET_LEADER_DECLARATION          = 0x8014,
    CMD_PARTY_SEND_MESSAGE              = 0x10F6,
    -- CMD_SET_PARTY_QUANQL                = 0xD000,
    CMD_PARTY_MODIFY_ANNOUNCE           = 0x10B6,
    CMD_QUERY_PARTY                     = 0xA012,
    -- CMD_MODIFY_PARTY_QUANQL             = 0xA05E, -- 设置帮帮排圈圈乐时间
    CMD_PARTY_ZHIDUOXING_SKILL          = 0xA0AD, -- 帮派智多星 - 使用技能
    CMD_PARTY_ZHIDUOXING_GOTO           = 0xA0AF, -- 帮派智多星 - 前往活动地图
    CMD_PARTY_ZHIDUOXING_SETUP          = 0xA0B1, -- 帮派智多星 - 活动设置
    CMD_PARTY_ZHIDUOXING_QUERY          = 0xA0B3, -- 请求智多星信息
    CMD_PARTY_PYJS_SETUP                = 0xD12C, -- 尝试开启帮派活动
    CMD_REQUEST_PARTY_PYJS_INFO         = 0xD112, -- 客户端请求培育巨兽数据
    CMD_PARTY_PYJS_SELECT_ATTRIB        = 0xD12A, -- 选择培育属性
    CMD_PARTY_PYJS_FETCH_TASK           = 0xD126, -- 领取培育巨兽任务
    CMD_PARTY_PYJS_FINISH_TASK          = 0xD128, -- 完成培育巨兽任务
    CMD_QUERY_PYJS                      = 0xD12E, -- 查询活动的状态
    CMD_PARTY_YQCS_GET_RESULT           = 0xD118, -- 客户端请求一决胜负
    CMD_PARTY_YQCS_ADD_POINT            = 0xD11A, -- 客户端请求加点
    CMD_PARTY_YQCS_REPLAY               = 0xD11C, -- 客户端请求重来
    CMD_PARTY_YQCS_CONFIRM_RESULT       = 0xD124, -- 播完投骰子动画后通知服务端
    CMD_PARTY_YQCS_QUIT                 = 0xD10E, -- 客户端通知结束运气测试
    CMD_PARTY_YZXL_POKE                 = 0xD11E, -- 客户端请求戳泡泡
    CMD_PARTY_YZXL_QUIT                 = 0xD120, -- 客户端请求暂停、退出、取消暂停
    CMD_PARTY_YZXL_REMOVE               = 0xD122, -- 客户端通知飘走的泡泡
    CMD_PARTY_YZXL_REPLAY               = 0xD116, -- 客户端请求重新戳泡泡

    -- 变异宠物商店
    CMD_BUY_FROM_ELITE_PET_SHOP         = 0xD004,
    -- 在线商城
    CMD_OPEN_ONLINE_MALL                = 0x00D8,
    CMD_BUY_FROM_ONLINE_MALL            = 0x20DA,

    -- 帮战报名
    CMD_BID_PARTY_WAR                   = 0xD006,
    CMD_ADD_PARTY_WAR_MONEY             = 0xD008,
    CMD_REFRESH_PARTY_WAR_BID           = 0xD00A,
    CMD_VIEW_PARTY_WAR_HISTORY          = 0x10F2,

    CMD_UPGRADE_PET                     = 0xD042,

    -- 神秘大礼抽奖
    CMD_START_AWARD                     = 0xC002,

    -- 请求购买天书灵气
    CMD_GODBOOK_BUY_NIMBUS              = 0x8060,

    -- 发送个人信息
    CMD_GATHER_USER_INFO                = 0xA044,

    CMD_REQUEST_FESTIVAL_GIFT_INFO      = 0xD098,

    CMD_BUY_FESTIVAL_GIFT               = 0xD094,

    CMD_OPEN_FESTIVAL_TREASURE          = 0xD096,

    CMD_OPEN_FESTIVAL_LOTTERY           = 0xA048,

    -- 客户端品尝年夜饭
    CMD_FETCH_SSNYF_BONUS               = 0xD0B6,

    -- 炼丹
    CMD_MAKE_PILL                       = 0x70A8,

    -- 集市相关
    CMD_SET_STALL_GOODS                 = 0x40C6,
    CMD_BUY_FROM_STALL                  = 0x30CA,
    CMD_START_MATCH_TEAM_LEADER         = 0xC006,
    CMD_SET_SETTING                     = 0x2094,

    -- 系统设置
    CMD_SET_SETTING                     = 0x2094,

    -- 药店
    CMD_GOODS_BUY                       = 0x3044,

    CMD_RANDOM_NAME                     = 0xB011,

    -- 天技秘笈商店
    CMD_EXCHANGE_GOODS                  = 0xA006,

    CMD_EQUIP                           = 0x1028,
    CMD_UNEQUIP                         = 0x202A,

    -- 摆摊搜索
    CMD_MARKET_SEARCH_ITEM              = 0xB028,

    -- 将背包物品存入仓库
    CMD_STORE                           = 0x4078,
    -- 将仓库物品拿进背包
    CMD_TAKE                            = 0x4076,
    -- 存取宠物
    CMD_OPERATE_PET_STORE               = 0x801A,

    -- 检查
    CMD_MARKET_CHECK_RESULT             = 0xB033,

    -- 请求区组角色的信息
    CMD_L_GET_ACCOUNT_CHARS             = 0xB034,
    CMD_CREATE_LOAD_CHAR                = 0xB039,
    -- 请求线列表跟状态
    CMD_REQUEST_SERVER_STATUS           = 0x00DE,
    CMD_SWITCH_SERVER                   = 0x10D4,
    CMD_ASSIGN_RESIST                   = 0x108E,

    -- 兑换码
    CMD_FETCH_GIFT                      = 0xB04A,

    -- 请求夫妻信息
    CMD_REQUEST_COUPLE_INFO             = 0xB074,

    -- 拍卖相关
    CMD_SYS_AUCTION_GOODS_LIST          = 0x8024, -- 请求拍卖数据
    CMD_SYS_AUCTION_BID_GOODS           = 0x8026, -- 系统拍卖竞价

    -- 请求打开抢购界面
    CMD_STALL_RUSH_BUY_OPEN             = 0x8116,
    CMD_GOLD_STALL_RUSH_BUY_OPEN             = 0x811A,

    -- GM相关
    CMD_ADMIN_SHADOW_SELF               = 0xD038,   -- 切换隐身状态
    CMD_ADMIN_BLOCK_USER                = 0xD03A,
    CMD_ADMIN_QUERY_PLAYER              = 0x1A06,
    CMD_ADMIN_KICKOFF                   = 0x1AEC,
    CMD_ADMIN_SHUT_CHANNEL              = 0x4AF4,
    CMD_ADMIN_BLOCK_ACCOUNT             = 0x3AE4,
    CMD_ADMIN_THROW_IN_JAIL             = 0x1AF6,
    CMD_ADMIN_SNIFF_AT                  = 0x1A02,
    CMD_ADMIN_QUERY_ACCOUNT             = 0xD036,
    CMD_ADMIN_WARN_PLAYER               = 0xD03C,
    CMD_ADMIN_STOP_COMBAT               = 0xD074, -- 终止战斗
    CMD_ADMIN_MOVE_TO_TARGET            = 0xD076, -- 接近目标
    CMD_ADMIN_SEARCH_PROCESS            = 0xD078, -- 查看进程
    CMD_ADMIN_QUERY_LOCAL_LINE          = 0xD07A, -- 查询本线
    CMD_ADMIN_QUERY_LOCAL_MAP           = 0xD07C, -- 查询本地图
    CMD_ADMIN_BLOCK_MAC                 = 0x1AE4, -- 封闭Mac
    CMD_ADMIN_QUERY_NPC                 = 0xD072, -- 查询NPC

    CMD_ADMIN_SET_USER_LEVEL            = 0xD0BA, -- GM 设置玩家等级
    CMD_ADMIN_SET_USER_ATTRIB           = 0xD0BC, -- 设置玩家属性
    CMD_ADMIN_SET_PET_LEVEL             = 0xD0BE, -- 设置宠物等级
    CMD_ADMIN_SET_PET_ATTRIB            = 0xD0C0, -- 设置宠物属性
    CMD_ADMIN_MAKE_EQUIPMENT            = 0xD0C2, -- 生成指定装备类型
    CMD_ADMIN_MAKE_ITEM                 = 0xD0C4, -- 生成指定道具、金钱

    -- 龙争虎斗
    CMD_LH_GUESS_RACE_INFO              = 0xB0BB,   -- 请求时间
    CMD_LH_GUESS_PLANS                  = 0xB0BD,   -- 请求对阵信息
    CMD_LH_GUESS_TEAM_INFO              = 0xB0BF,   -- 请求队伍信息
    CMD_LH_GUESS_CAMP_SCORE             = 0xB0C1,   -- 请求阵营的积分信息
    CMD_LH_GUESS_INFO                   = 0xB0C3,   -- 请求竞猜信息
    CMD_LH_MODIFY_GUESS                 = 0xB0C5,   -- 请求修改竞猜

    -- 寄售相关
    CMD_TRADING_SELL_ROLE               = 0x8052,   -- 在游戏中出售角色
    CMD_TRADING_CANCEL_ROLE             = 0x8054,   -- 客户端在选角界面请求取回角色
    CMD_TRADING_CHANGE_PRICE_ROLE       = 0x8056,   -- 客户端在选角界面请求修改角色价格
    CMD_TRADING_SELL_ROLE_AGAIN         = 0x8058,   -- 客户端在选角界面请求继续寄售角色
    CMD_TRADING_SNAPSHOT                = 0x805A,   -- 客户端请求商品的快照信息
    CMD_TRADING_SNAPSHOT_ME             = 0x805C,   -- 客户端请求自身商品快照信息

    CMD_TRADING_SELL_GOODS              = 0x8068,         -- 聚宝斋上架商品
    CMD_TRADING_CANCEL_GOODS            = 0x806A,         -- 聚宝斋取消售上架商品
    CMD_TRADING_CHANGE_PRICE_GOODS      = 0x806C,         -- 聚宝斋修改商品价格
    CMD_TRADING_SELL_GOODS_AGAIN        = 0x806E,         -- 聚宝斋重新上架商品



    CMD_TRADING_FAVORITE_LIST           = 0x8062,   -- 请求聚宝斋收藏列表
    CMD_TRADING_GOODS_LIST              = 0x8064,   -- 请求聚宝斋商品列表
    CMD_TRADING_CHANGE_FAVORITE         = 0x8066,   -- 请求改变商品的收藏


    CMD_SEARCH_COMPETE_TOURNAMENT_TARGETS = 0x5010,  -- 刷新擂台挑战
    CMD_KILL_COMPETE_TOURNAMENT_TARGET    = 0x5012,  -- 擂台挑战某人
    CMD_COMPETE_TOURNAMENT_TOP_USER_INFO  = 0x5013,  -- 请求10强

    -- 请求排队信息
    CMD_L_REQUEST_LINE_INFO             = 0xB058,

    -- 观战
    CMD_LOOK_ON                         = 0x1090,
    CMD_QUIT_LOOK_ON                    = 0x0092,

    -- 修改掌门留言
    CMD_OPER_MASTER                     = 0x30AC,

    -- 使用变身卡
    CMD_APPLY_CARD                      = 0x00FA,
    CMD_ANSWER_CHANGE_CARD              = 0xD044,
    CMD_CL_CARD_TOP_ONE                 = 0x802C,
    CMD_CL_CARD_ADD_SIZE                = 0x802A,

    -- 捐款
    CMD_SHIMEN_TASK_DONATE              = 0x8022,
    CMD_GATHER_UP                       = 0xA014,

    -- 录屏
    CMD_SCREEN_RECORD_END               = 0x8028,

    -- 手机绑定
    CMD_PHONE_VERIFY_CODE               = 0x8030,       --请求绑定手机的验证码
    CMD_PHONE_BIND                      = 0x8032,       --请求绑定手机
    CMD_SMS_TAKE_CHECK_CODE             = 0x5030,       -- 获取验证码
    CMD_SMS_VERIFY_CHECK_CODE           = 0x5031,       -- 提交验证码

    -- 老君查岗
    CMD_REQUEST_SECURITY_CODE           = 0xD03E,       -- 请求重新获取验证码
    CMD_ANSWER_SECURITY_CODE            = 0xD040,       -- 回答验证码结果
    CMD_LOG_LJCG_EXCEPTION              = 0xD046,       -- 通知服务器记录查岗异常日志

    CMD_SHARE_WITH_FRIENDS              = 0x8036,      -- 客户端通知服务器分享成功

    -- 洗天技
    CMD_PET_SPECIAL_SKILL               = 0xA01A,

    -- 记录活动界面的点击前往事件
    CMD_LOG_ANTI_CHEATER                = 0xA01C,

    -- 节日活动列表开启和结束时间
    CMD_ACTIVITY_LIST                   = 0x8038,

    CMD_WRITE_YYQ                       = 0xB0C9, -- 【情人节】姻缘签内容提交
    CMD_SEARCH_YYQ                      = 0xB0CC, --  搜索姻缘签
    CMD_REQUEST_YYQ_PAGE                = 0xB0CE, -- 请求姻缘签分页数据
    CMD_REQUEST_MY_YYQ                  = 0xB0D0, -- 请求我的姻缘签
    CMD_COMMENT_YYQ                     = 0xB0D2, -- 评论一个姻缘签

    CMD_WRITE_ZFQ                       = 0xB15E, -- 祝福签内容提交
    CMD_SEARCH_ZFQ                      = 0xB156, --  搜索祝福签
    CMD_REQUEST_ZFQ_PAGE                = 0xB158, -- 请求祝福签分页数据
    CMD_REQUEST_MY_ZFQ                  = 0xB15A, -- 请求我的祝福签
    CMD_COMMENT_ZFQ                     = 0xB15C, -- 评论一个祝福签

    -- 一键强化
    CMD_REBUILD_PET                     = 0xA01E,

    -- 经验心得/道武心得使用次数
    CMD_GET_WULIANGXINJING_XINDE_INFO   = 0x5004,

    -- 无量心经使用次数
    CMD_GET_WULIANGXINJING_INFO         = 0x5007,

    -- 确认框
    CMD_CONFIRM_RESULT                  = 0x5100,

    -- 师徒系统相关
    CMD_REQUEST_APPRENTICE_INFO         = 0xD04A,   -- 查看寻师寻徒申请信息  1表示寻师，2表示寻徒，3表示申请
    CMD_SEARCH_MASTER                   = 0xD04C,   -- 修改寻师留言
    CMD_SEARCH_APPRENTICE               = 0xD04E,   -- 修改寻徒留言
    CMD_APPLY_FOR_MASTER                = 0xD052,   -- 申请成为师父
    CMD_APPLY_FOR_APPRENTICE            = 0xD054,   -- 申请成为徒弟
    CMD_RELEASE_APPRENTICE_RELATION     = 0xD056,   -- 解除师徒关系
    CMD_MY_APPRENTICE_INFO              = 0xD058,   -- 查看我的师徒关系
    CMD_CHANGE_MASTER_MESSAGE           = 0xD064,   -- 查看我的师徒关系
    CMD_REQUEST_CDSY_TODAY_TASK         = 0xD06C,   -- 请求今日随机任务
    CMD_PUBLISH_CDSY_TASK               = 0xD06A,   -- 请求发布任务
    CMD_FETCH_CHUSHI_TASK               = 0xD1E0,   -- 领取出师任务

    -- 刷新当前角色所有数据
    CMD_REFRESH_USER_DATA               = 0XD048,

    CMD_SWITCH_BACK_EQUIP               = 0x000E, -- 切换装备

    CMD_REQUEST_DAILY_STATS             = 0xD06E, -- 今日数据统计

    -- 珍宝交易系统
    CMD_GOLD_STALL_OPEN_MY              = 0x8100,  -- 打开自己的金元宝交易界面
    CMD_GOLD_STALL_OPEN                 = 0x8102,  -- 请求金元宝交易逛摊
    CMD_GOLD_STALL_PUT_GOODS            = 0x8104,  -- 金元宝交易上架
    CMD_GOLD_STALL_RESTART_GOODS        = 0x8106, -- 金元宝交易重新上架
    CMD_GOLD_STALL_REMOVE_GOODS         = 0x8108, -- 金元宝交易下架商品
    CMD_GOLD_STALL_BUY_GOODS            = 0x810A, -- 金元宝交易购买商品
    CMD_GOLD_STALL_RECORD               = 0x810B, -- 金元宝交易查看交易记录
    CMD_GOLD_STALL_TAKE_CASH            = 0x810D, -- 金元宝交易提取金元宝
    CMD_GOLD_STALL_GOODS_STATE          = 0x810E, -- 金元宝交易请求商品状态
    CMD_GOLD_STALL_SEARCH_GOODS         = 0x8110, -- 金元宝交易请求搜索
    CMD_GOLD_STALL_GOODS_INFO           = 0x8112, -- 金元宝交易请求商品名片
    CMD_GOLD_STALL_CHANGE_PRICE         = 0x811C, -- 请求修改价格

    -- 安全锁相关
    CMD_SAFE_LOCK_OPEN_DLG              = 0x803A, -- 请求打开安全锁界面
    CMD_SAFE_LOCK_SET                   = 0x803C, -- 请求设置密码
    CMD_SAFE_LOCK_CHANGE                = 0x803E, -- 请求修改密码
    CMD_SAFE_LOCK_UNLOCK                = 0x8040, -- 请求解锁
    CMD_SAFE_LOCK_RESET                 = 0x8042, -- 请求或取消强制解锁

    CMD_PREVIEW_PET_EVOLVE              = 0xD070, -- 请求宠物进化预览

    CMD_SET_OFFLINE_DOUBLE_STATUS       = 0xB0A0, -- 设置离线刷道双倍状态
    CMD_SET_OFFLINE_JIJI_STATUS         = 0xB0A2, -- 设置离线刷道急急如律令状态
    CMD_SET_OFFLINE_CHONGFS_STATUS      = 0xB0A4, -- 设置离线刷道宠风散状态
    CMD_SET_OFFLINE_ZIQIHONGMENG_STATUS = 0x5025, -- 设置离线刷道紫气鸿蒙状态
    CMD_SHUAD_SMART_TRUSTEESHIP         = 0xB0D6, -- 设置托管是否智能

    CMD_FETCH_SHUADAO_SCORE_ITEM        = 0xB0A6, -- 请求积分道具
    CMD_REFRESH_SHUAD_TRUSTEESHIP       = 0xB0B6, -- 请求刷道托管数据
    CMD_OPEN_SHUAD_TRUSTEESHIP          = 0xB0B4, -- 开启刷道托管
    CMD_SET_SHUAD_TRUSTEESHIP_STATE     = 0xB0B5, -- 设置托管状态
    CMD_SET_SHUAD_TRUSTEESHIP_TASK      = 0xB0B3, -- 设置托管任务
    CMD_BUY_SHUAD_TRUSTEESHIP_TIME      = 0xB0B2, -- 购买托管时间
    CMD_SHUADAO_TRUSTEESHIP_INFO        = 0xB0BA, -- 请求刷道结算数据

    CMD_START_GUESS                     = 0xA021, -- 五行开始
    CMD_FETCH_GUESS_SURPLUS             = 0xA024, -- 五行提款

    CMD_APPLY_FRIEND_ITEM               = 0xB066, -- 赠送好友
    CMD_RESPONSE_TIQIN                  = 0xB06C, -- 求婚结果

    -- 赠送相关
    CMD_REQUEST_GIVING                  = 0xD084, -- 向队友发起赠送请求
    CMD_CANCEL_GIVING                   = 0xD08C, -- 取消赠送
    CMD_ACCEPT_GIVING                   = 0xD08A,
    CMD_OPEN_GIVING_WINDOW              = 0xD086, -- 玩家同意对方赠送，打开赠送界面
    CMD_SUBMIT_GIVING_ITEM              = 0xD088, -- 提交赠送物品

    CMD_REQUEST_TASK_STATUS             = 0xA03E, -- 查询

    CMD_BUY_WEDDING_LIST                = 0xB070, -- 购买礼单
    CMD_SET_RED_PACKET                  = 0xB072, -- 设置撒红包的数量

    CMD_PARTY_RENAME                    = 0x8044, -- 请求修改帮派名称
    CMD_GET_INSIDER_DISCOUNT_INFO       = 0xD082, -- 客户端请求会员折扣活动信息

    CMD_REPLY_SUBMIT_ZIKA               = 0xA036, -- 用于提交教师节字卡

    CMD_ADD_FRIEND_GROUP                = 0xB07A, -- 添加一个新分组
    CMD_REMOVE_FRIEND_GROUP             = 0xB07C, -- 删除一个分组
    CMD_MOVE_FRIEND_GROUP               = 0xB082, -- 移动一个好友分组
    CMD_MODIFY_FRIEND_GROUP             = 0xB08F, -- 修改好友分组名字

    CMD_SET_REFUSE_STRANGER_CONFIG      = 0xB078, -- 设置拒绝陌生人消息设置
    CMD_SET_AUTO_REPLY_MSG_CONFIG       = 0xB084, -- 设置自动回复设置
    CMD_SET_REFUSE_BE_ADD_CONFIG        = 0xB086, -- 设置拒绝好友申请设置
    CMD_ADD_CHAT_GROUP                  = 0xB088, -- 添加一个群组
    CMD_REMOVE_CHAT_GROUP               = 0xB08A, -- 删除一个群组
    CMD_MODIFY_CHAT_GROUP_NAME          = 0xB08C, -- 修改一个群组名字
    CMD_REMOVE_MEMBER_TO_CHAT_GROUP     = 0xB090, -- 从一个群组移除成员
    CMD_MODIFY_CHAT_GROUP_ANNOUS        = 0xB092, -- 修改群组的公告信息
    CMD_SET_CHAT_GROUP_SETTING          = 0xB094, -- 修改某个群组的设置信息
    CMD_QUIT_CHAT_GROUP                 = 0xB096, -- 退出一个群组
    CMD_INVENTE_CHAT_GROUP_MEMBER       = 0xB080, -- 邀请好友到群组
    CMD_ACCEPT_CHAT_GROUP_INVENTE       = 0xB098, -- 接受群组邀请
    CMD_REFUSE_CHAT_GROUP_INVENTE       = 0xB09A, -- 拒绝群组邀请
    CMD_MODIFY_FRIEND_MEMO              = 0xB09E, -- 修改好友备注信息
    CMD_CHAT_GROUP_TELL                 = 0xB09C, -- 群组聊天
    CMD_PARTY_HELP                      = 0xD08E,  -- 提交装备求助
    CMD_MOONCAKE_GAMEBLING              = 0xA040, -- 请求博饼操作
    CMD_PT_RB_SEND_INFO                 = 0x8046,  -- 打开帮派红包发送界面，请求数据
    CMD_PT_RB_SEND_REDBAG               = 0x8048,  -- 请求发送帮派红包
    CMD_PT_RB_RECV_REDBAG               = 0x804A,  -- 请求接收帮派红包
    CMD_PT_RB_LIST                      = 0x804C,  -- 请求帮派红包列表
    CMD_PT_RB_SHOW_REDBAG               = 0x804E,  -- 查看帮派红包
    CMD_PT_RB_RECORD                    = 0x8050,  -- 查看帮派红包记录
    CMD_USER_AGREEMENT                  = 0x809E, -- 同意用户协议
    CMD_REQUEST_PH_CARD_INFO            = 0xD09A, -- 帮派求助信息
    CMD_MAILING_ITEM                    = 0x809A, -- 客户端请求邮寄道具
    CMD_QUANFU_HONGBAO_RECORD           = 0x809C, -- 客户端请求全服红包领取记录

    CMD_OPEN_LIVENESS_LOTTERY           = 0xA046,
    CMD_LEAVE_BAXIAN                    = 0x6000, -- 客户端在任务界面点击离开八仙梦境
    CMD_LEAVE_DUNGEON                   = 0x6002, -- 客户端在任务界面点击离开副本
    CMD_SET_PUSH_SETTINGS               = 0xD092, -- 设置服务器推送开关
    CMD_SEND_DEVICE_TOKEN               = 0xD09C, -- 通知device_token
    CMD_SHOCK                           = 0xB076, -- 客户端请求震动提醒玩家

    CMD_AUTO_FIGHT_INFO                 = 0x6004,  -- 请求自动战斗技能配置信息

    CMD_REQUEST_PK_INFO                 = 0xB0AA, -- 请求服务端数据
    CMD_GOTO_PK                         = 0xB0AC, -- 前往PK
    CMD_SUBMIT_MULTI_ITEM               = 0xA050, -- 提交多个物品

    CMD_ZUOLAO_PLEAD                    = 0xB0AE, -- 求情
    CMD_ZUOLAO_RELEASE                  = 0xB0AF, -- 保释

    CMD_SELECT_CURRENT_MOUNT            = 0x111E, -- 选择和取消当前坐骑
    CMD_ADD_FENGLINGWAN                 = 0xD0A2, -- 元宝增加风灵丸
    CMD_HIDE_MOUNT                      = 0xD0A4, -- 通知是否隐藏坐骑
    CMD_QUERY_MOUNT_MERGE_RATE          = 0x5020, -- 查询骑宠的融合成功率
    CMD_PREVIEW_MOUNT_ATTRIB            = 0x5022, -- 查询骑宠融合成功之后的属性
    CMD_MAILBOX_GATHER                  = 0xA052,
    CMD_NOTIFY_ITEM_TIMEOUT             = 0xD0A6,

    CMD_DEPOSIT                         = 0x207E,  -- 存钱
    CMD_WITHDRAW                        = 0x2080,  -- 取钱

    CMD_REQUEST_FUZZY_IDENTITY          = 0xD0A8,  -- 请求认证信息
    CMD_IDENTITY_BIND                   = 0xD0AA,  -- 请求实名认证

    CMD_COUPON_BUY_FROM_MALL            = 0x805E,  -- 客户端请求使用折扣券购买商城道具
    CMD_MOUNT_CONVERT                   = 0x5024,  -- 宠物转化
    CMD_SUMMON_MOUNT_REQUEST            = 0xA054,  -- 请求召唤精怪

    CMD_ADD_DUNWU_NIMBUS                = 0xD0AE,  -- 增加进阶技能灵气值
    CMD_ADD_DUNWU_TIMES                 = 0xD0B0,  -- 增加顿悟次数
    CMD_DO_REPLENISH_SIGN               = 0x6006,  -- 请求补签

    CMD_REFILL_ARTIFACT_NIMBUS          = 0xD0AC,  -- 补充法宝灵气

    CMD_VIEW_DDQK_ATTRIB                = 0xD0B4,  -- 颠倒乾坤查看目标属性

    -- 聚宝交易记录
    CMD_TRADING_RECORD                  = 0x8071,   -- 请求聚宝斋交易记录

    -- 观战中心 >>>>>>>>>>>>>>>>>>>>>
    CMD_LOOKON_BROADCAST_COMBAT         = 0x5E00,   -- 开始观战
    CMD_QUIT_LOOKON_BROADCAST_COMBAT    = 0x5E01,   -- 退出观战
    CMD_REQUEST_BROADCAST_COMBAT_LIST   = 0x5E02,   -- 观战大厅赛事列表
    CMD_REQUEST_BROADCAST_COMBAT_DATA   = 0x5E04,   -- 请求指定战斗的基础数据
    CMD_LOOKON_COMBAT_RECORD_DATA       = 0x5E07,   -- 请求战斗录像数据
    CMD_LOOKON_CHANNEL_MESSAGE          = 0x5E09,   -- 发送弹幕

    CMD_LOOKON_COMBAT_CHANNEL_DATA      = 0x5E0B,   -- 请求一页录像弹幕信息
    -- 观战中心<<<<<<<<<<<<<<<<<<<<<<<<

    CMD_REQUEST_ICON                    = 0x5037,  -- 请求图标的buffer信息
    CMD_SUBMIT_ICON                     = 0x5036,  -- 上传图标
    CMD_DELETE_PARTY_ICON               = 0x5035,  -- 清除帮派图标
    CMD_START_WEDDING                   = 0xB0D5,  -- 请求开始婚礼

    CMD_SET_FOOL_GIFT_RESULT            = 0x6008,  -- 设置礼物结果（愚人节分发礼物活动）
    CMD_RECEIVE_FOOL_GIFT               = 0x6010,  -- 领取礼物（愚人节分发礼物活动）

    CMD_PERFORMANCE                     = 0x8098,  -- 性能数据上报

    -- 跨服试道
    CMD_REFRESH_CS_SHIDAO_INFO         = 0xB0D7,   -- 客户端请求刷新跨服试道信息
    CMD_REQUEST_CS_SHIDAO_HISTORY      = 0xB0D8,   -- 客户端请求刷新跨服试道历史数据
    CMD_REFRESH_CS_SHIDAO_PLAN         = 0xB0DC,   -- 客户端请求刷新跨服试道历史数据的菜单
    CMD_REQUEST_CS_SHIDAO_ASSIGN_ZONE_PLAN = 0x503E, -- 客户端请求刷新试道赛区分配数据

    CMD_WXLL_SUBMIT_CHANGECARD         = 0x6012,   -- 武学历练提交变身卡

    CMD_BUY_RECHARGE_SCORE_GOODS        = 0xD0C6,  -- 购买积分道具
    CMD_REQUEST_RECHARGE_SCORE_GOODS    = 0xD0C8,  -- 客户端请求积分商品列表

    CMD_CLICK_QQ_GIFT_BTN               = 0xD0E4,  -- 客户端通知点击了QQ会员礼包相关按钮


    CMD_LEAVE_HZWH                     = 0xB0EF,   -- 离开舞会场地

    CMD_LEAVE_BAISZW                   = 0x8075,   -- 离开百兽战场

    CMD_GET_MY_BAOSHU_INFO             = 0x600E,   -- 请求我的宝树数据
    CMD_GET_FRIEND_BAOSHU_INFO         = 0x6014,   -- 请求好友的宝树数据
    CMD_DO_ACTION_ON_BAOSHU            = 0x6016,   -- 对自己宝树的一些操作
    CMD_WATER_FRIEND                   = 0x6018,   -- 给好友浇水
    CMD_GET_WATER_LIST                 = 0x601A,   -- 浇过水的好友列表

    CMD_ZNQ_OPEN_LOGIN_GIFT            = 0x600A,    -- 打开周年庆登录礼包界面申请数据
    CMD_ZNQ_FETCH_LOGIN_GIFT           = 0x600C,    -- 领取周年庆登录礼包
    CMD_WUXING_SHOP_EXCHANGE           = 0xA066,    -- 五行商店兑换
    CMD_WUXING_SHOP_REFRSH             = 0xA068,    -- 五行商店刷新

    CMD_ZNQ_OPEN_LOGIN_GIFT_2018       = 0xB18D,    -- 2018 周年庆登录礼包打开
    CMD_ZNQ_FETCH_LOGIN_GIFT_2018      = 0xB18E,    -- 2018 周年庆登录礼包获取

    CMD_ZNQ_OPEN_LOGIN_GIFT_2019       = 0xB28D,    -- 2019 周年庆登陆礼包打开
    CMD_ZNQ_FETCH_LOGIN_GIFT_2019      = 0xB28E,    -- 2019 周年庆登陆礼包获取

    -- 全民PK
    CMD_PKM_RESET_POINT                = 0xD0D6,    -- 加点重置（角色、宠物）
    CMD_PKM_GEN_EQUIPMENT              = 0xD0D8,    -- 生成装备
    CMD_PKM_GEN_PET                    = 0xD0DA,    -- 生成宠物
    CMD_PKM_SET_DUNWU_SKILL            = 0xD0DC,    -- 修改宠物顿悟技能
    CMD_PKM_FETCH_ITEM                 = 0xD0DE,    -- 领取道具
    CMD_PKM_RECYCLE_ITEM               = 0xD0E0,    -- 回收道具

    CMD_RECALL_USER_ACTIVITY_OPER      = 0x5044,    -- 召回道友

    CMD_FETCH_LOTTERY_ZNQ_2017         = 0xD0CF,   -- 客户端请求抽奖
    CMD_LEAVE_ROOM                     = 0x8077,   -- 离开须弥秘境

    CMD_QMPK_MATCH_INFO                = 0xB0F0,   -- 请求全民PK比赛数据
    CMD_QMPK_MATCH_TEAM_INFO           = 0xB0F3,   -- 请求全民PK队伍数据

    CMD_QMPK_MATCH_TIME_INFO           = 0xB0F6,   -- 请求全民PK时间数据

    CMD_ADJUST_BROTHER_ORDER           = 0xD0E6,   -- 队长通知调整顺序
    CMD_CONFIRM_BROTHER_ORDER          = 0xD0E8,   -- 队长确认顺序
    CMD_SET_BROTHER_APPELLATION        = 0xD0EA,   -- 队长通知前后缀
    CMD_CONFIRM_BROTHER_APPELLATION    = 0xD0EC,   -- 队长确认称谓
    CMD_CONFIRM_JIEBAI                 = 0xD0EE,   -- 确认结拜
    CMD_CANCEL_BROTHER                 = 0xD0F0,   -- 通知关闭结拜界面
    CMD_REQUEST_BROTHER_INFO           = 0xD0F2,   -- 请求结拜信息
    CMD_LEAVE_KSDZ                     = 0x601C,   -- 离开矿石大战

    CMD_YISHI_DISMISS                  = 0xA070,   -- 请求辞退义士
    CMD_YISHI_RECRUIT                  = 0xA07B,   -- 请求招募义士
    CMD_YISHI_IMPROVE                  = 0xA07F,   -- 请求强化义士
    CMD_YISHI_EXCHANGE                 = 0xA085,   -- 请求换取物资
    CMD_YISHI_LEAVE_ROOM               = 0xA087,   -- 请求离开地图
    CMD_YISHI_SEARCH_MONSTER           = 0xA089,   -- 查找怪物
    CMD_YISHI_SWITCH_STATUS            = 0xA08B,   -- 切换玩家状态


    CMD_CHANGE_CHAR_UPGRADE_STATE      = 0x5051,   -- 切换元婴、血婴、真身

    CMD_FETCH_ACTIVE_BONUS             = 0xD0F6,   -- 领取活跃会员奖励
    CMD_GET_ACTIVE_BONUS_INFO          = 0xD0F8,   -- 获取活动会员信息
    CMD_BAXIAN_DICE                    = 0x8079,   -- 客户端八仙掷骰子
    CMD_BAXIAN_DICE_FINISH             = 0x807B,   -- 客户端八仙掷骰子结束

    CMD_CHILD_DAY_2017_POKE            = 0x8081,   -- 客户端请求戳泡泡
    CMD_CHILD_DAY_2017_QUIT            = 0x8083,   -- 客户端请求退出游戏
    CMD_CHILD_DAY_2017_REMOVE          = 0x8089,   -- 客户端请求移除泡泡

    CMD_SET_GODBOOK_SKILL_STATE       = 0xD0FA,   -- 设置天书技能启用状态
    CMD_SET_DUNWU_SKILL_STATE          = 0xD0FC,   -- 设置顿悟技能启用状态


    CMD_SUBMIT_PET_UPGRADE_ITEM         = 0xB0FB,   -- 提交宠物飞升物品
    CMD_REQUEST_UPGRADE_TASK_PET        = 0xB102,   -- 请求正在飞升的宠物

    CMD_RENAME_DISCOUNT                 = 0x808B,      -- 客户端向服务器请求改名卡折扣信息
    CMD_RENAME_DISCOUNT_BUY             = 0x808D,-- 客户端向服务器请求购买折扣改名卡

    CMD_FETCH_SD_2017_LOTTERY           = 0xD0FE,   -- 客户端通知进行抽奖 0表示抽奖，1表示领奖
    CMD_REQUEST_SD_2017_LOTTERY_INFO    = 0xD100,   -- 客户端请求抽奖信息

    CMD_REQUEST_BUY_RARE_ITEM           = 0xB0FE,   -- 稀有物品商店购买物品

    CMD_FORMER_NAME                     = 0x808E,   -- 客户端向服务器请求曾用名
    CMD_PARTY_FORMER_NAME               = 0xD104,   -- 获取帮派曾用名
    CMD_AUTO_TALK_DATA                  = 0x8090,   -- 请求对象的自动喊话信息
    CMD_AUTO_TALK_SAVE                  = 0x8092,   -- 请求保存自动喊话信息

    CMD_APPLY_JIUQU_LINGLONGBI          = 0xB104,   -- 使用九曲玲珑笔

    CMD_SET_SHUADAO_RUYI_STATE          = 0xB105,   -- 设置如意刷道令的状态
    CMD_BUY_SHUADAO_RUYI_POINT          = 0xB106,   -- 购买如意刷道令点数

    CMD_OPEN_ZAOHUA_ZHICHI              = 0xA093,   -- 请求打开造化之池
    CMD_RECV_ZAOHUA_ZHICHI              = 0xA095,   -- 请求吸收造化之池

    CMD_REQUEST_CONSUME_SCORE_GOODS     = 0xA097,  -- 请求消费积分商品信息
    CMD_BUY_CONSUME_SCORE_GOODS         = 0xA099,  -- 消费积分购买商品
    CMD_BUY_HOUSE                       = 0x5061,   -- 购买居所
    CMD_HOUSE_PLACE_FURNITURE           = 0x5063,   -- 摆放家具
    CMD_HOUSE_TAKE_FURNITURE            = 0x5064,   -- 取回家具
    CMD_HOUSE_MOVE_FURNITURE            = 0x5065,   -- 移动家具
    CMD_HOUSE_DRAG_FURNITURE            = 0x5066,   -- 开始拖动
    CMD_HOUSE_TRY_MANAGE                = 0x5067,   -- 开始管理房屋
    CMD_HOUSE_QUIT_MANAGE               = 0x5068,   -- 取消拖动
    CMD_HOUSE_BUY_FURNITURE             = 0x5071,   -- 购买家具


    CMD_REQUEST_HOUSE_DATA              = 0x5074, -- 请求居所信息
    CMD_HOUSE_CLEAN                     = 0x5075, -- 打扫房间
    CMD_HOUSE_REPAIR_FURNITURE          = 0x5076, -- 修理家具
    CMD_HOUSE_USE_FURNITURE             = 0x5077, -- 使用家具
    CMD_REQUEST_FURNITURE_APPLY_DATA    = 0x5078, -- 请求卧室信息
    CMD_HOUSE_GO_HOME                   = 0x506A, -- 回居所
    CMD_HOUSE_SHOW_DATA                 = 0x506B, -- 查看某人居所
    CMD_HOUSE_ROOM_SHOW_DATA            = 0x507A, -- 请求居所家具信息
    CMD_HOUSE_FRIEND_VISIT              = 0x507D, -- 拜访别人的居所
    CMD_HOUSE_GOTO_CLEAN                = 0x507E, -- 前往清扫
    CMD_HOUSE_FUNCTION_FURNITURE_LIST   = 0x5080, -- 请求功能型家具

    CMD_CS_SHIDAO_ZONE_INFO             = 0xB10A,  -- 客户端请求某等级段及赛区的具体数据

    CMD_DESTROY_VALUABLE                = 0x8094,  -- 请求销毁贵重道具或者宠物
    CMD_DESTROY_VALUABLE_CONFIRM        = 0x8096,   -- 确认销毁该道具或宠物

    CMD_APPLY_CHONGWU_JINGYANDAN        = 0xA09D,   -- 使用宠物经验丹
    CMD_HOUSE_RENAME                    = 0x5082,   -- 居所改名
    CMD_HOUSE_AUTOWALK                  = 0x5084,   -- 传送到对应ID的居所
    CMD_CACHE_AUTO_WALK_MSG             = 0xD10A, -- 需要跨线寻路
    CMD_WELCOME_DRAW_REQUEST            = 0xA09F, -- 请求抽奖
    CMD_FINISH_JINGUANGFU               = 0xD10C,   -- 通知金光符绘制完成
    CMD_HOUSE_PLAYER_PRACTICE           = 0x5090,   -- 请求居所任务修炼数据
    CMD_AUTUMN_2017_QUIT                = 0xA0A9,   -- 客户端请求暂停小游戏
    CMD_AUTUMN_2017_PLAY                = 0xA0AB,   -- 请求接取月饼
    CMD_HOUSE_REQUEST_PET_FEED_INFO     = 0xB119,   -- 在非居所专线请求宠物饲养数据
    CMD_HOUSE_REQUEST_ARTIFACT_INFO     = 0xB115,   -- 在非居所专线请求法宝修炼的数据
    CMD_HOUSE_OTHER_FURNITURE_DATA      = 0xB142,   -- 请求居所入口其它提醒信息
    CMD_HOUSE_FARM_HELP_TARGETS         = 0x5118,   -- 请求需要帮助的好友列表
    CMD_HOUSE_FARM_HELP_TARGETS_NUM     = 0x511A,   -- 请求需要帮助的好友列表数量（用于小红点）
    CMD_HOUSE_FARM_HELP_RECORDS         = 0x511C,   -- 请求好友协助记录
    CMD_HOUSE_FARM_GOTO_HELP            = 0x511E,   -- 前往协助好友打理农田

    CMD_RESPONSE_CLIENT_SIGNATURE       = 0x5203, -- 发送客户端包体签名信息
    CMD_RECORD_SHUAD_LOG                = 0xB137,   -- 记录自动刷道日志
    CMD_SET_CLIENT_USER_STATE           = 0xB138,   -- 设置玩家状态数据

    CMD_CSL_LIVE_SCORE                  = 0x80A0,   -- 客户端请求战场实时数据
    CMD_CSL_ROUND_TIME                  = 0x80A2,   -- 客户端请求比赛时间
    CMD_CSL_ALL_SIMPLE                  = 0x80A4,   -- 客户端请求所有联赛简要信息
    CMD_CSL_LEAGUE_DATA                 = 0x80A6,   -- 客户端请求具体赛区的数据
    CMD_CSL_MATCH_SIMPLE                = 0x80A8,   -- 客户端请求具体比赛简要数据
    CMD_CSL_MATCH_DATA                  = 0x80AA,   -- 客户端请求比赛积分榜
    CMD_CSL_CONTRIB_TOP_DATA            = 0x80AC,   -- 客户端请求比赛积分榜  个人


    CMD_HOUSE_FARM_ACTION               = 0x5110, -- 居所种植相关请求

    CMD_HOUSE_START_COOKING             = 0xB11B,   -- 开始烹饪
    CMD_HOUSE_ENTRUST                   = 0x80B2,   -- 客户端请求委托兑换
    CMD_HOUSE_START_MAKE_FURNITURE      = 0xB11C,   -- 开始制作家具

    CMD_REFRESH_REQUEST_INFO           = 0xA0A5,   -- 请求队伍信息

    CMD_HOUSE_ENTER_FISH                = 0xB127, -- 进入钓鱼状态
    CMD_HOUSE_QUIT_FISH                 = 0xB128, -- 退出钓鱼状态
    CMD_HOUSE_START_FISH                = 0xB129, -- 开始钓鱼
    CMD_HOUSE_TIGAN                     = 0xB12A, -- 提杆
    CMD_HOUSE_LACHE                     = 0xB12B, -- 拉扯
    CMD_HOUSE_ADD_POLE_NUM              = 0xB12C, -- 补充鱼竿
    CMD_HOUSE_ADD_BAIT_NUM              = 0xB12D, -- 补充鱼饵
    CMD_HOSUE_FISH_ALL_TOOLS            = 0xB12E, -- 请求所有的渔具
    CMD_HOUSE_SELECT_TOOLS              = 0xB12F, -- 选择渔具

    CMD_SUBMIT_NEED_EXCHANGE_MATERIAL       = 0x5121,   -- 提交所需材料
    CMD_SUBMIT_GIFT_EXCHANGE_MATERIAL       = 0x5122,   -- 提交赠礼材料
    CMD_UNSUBMIT_NEED_EXCHANGE_MATERIAL     = 0x5123,   -- 移除所需材料
    CMD_UNSUBMIT_GIFT_EXCHANGE_MATERIAL     = 0x5124,   -- 移除赠礼材料
    CMD_PUBLISH_EXCHANGE_MATERIAL           = 0x5125,   -- 发布
    CMD_UNPUBLISH_EXCHANGE_MATERIAL         = 0x5126,   -- 撤回
    CMD_EXCHANGE_MATERIAL_MAILBOX           = 0x512B,   -- 可领取的材料邮件



    CMD_HOUSE_FISH_PAUSE                = 0xB131, -- 暂停钓鱼
    CMD_HOUSE_FISH_CONTINUE             = 0xB132, -- 继续钓鱼

    CMD_FRIEND_EXCHANGE_MATERIAL_DATA   = 0x5129, -- 请求好友材料求助数据
    CMD_EXCHANGE_MATERIAL               = 0x512E, -- 赠送好友材料

    CMD_HOUSE_REQUEST_FARM_INFO         = 0x5114, -- 在非居所专线请求居所农田的数据

    CMD_AUTUMN_2017_BUY                 = 0xA0B6, -- 刷新购买信息或请求购买筛子

    CMD_LEAVE_NEW_PW                    = 0xD114, -- 客户端请求离开帮战赛场

    -- 挑战巨兽相关
    CMD_QUERY_TZJS                      = 0xD134,       -- 查询活动的状态 帮派活动，挑战巨兽
    CMD_PARTY_TZJS_SETUP                = 0xD130,       -- 尝试开启活动
    CMD_REQUEST_PARTY_TZJS_INFO         = 0xD136,       -- 请求刷新挑战巨兽界面
    CMD_PARTY_TZJS_CHALLENGE            = 0xD132,       -- 确认开始挑战

    CMD_CHONGYANG_2017_TASTE            = 0xA0B8, -- 重阳节品尝菜肴

    CMD_HOUSE_BUY_GUANJIA               = 0xB139, -- 购买管家
    CMD_HOUSE_SELECT_GUANJIA            = 0xB13A, -- 选择管家
    CMD_HOUSE_CHANGE_GUANJIA_NAME       = 0xB13B, -- 管家改名

    CMD_HOUSE_ADD_YH_INFO               = 0xB140, -- 增加一个丫鬟
    CMD_HOUSE_CHANGE_YH_NAME            = 0xB141, -- 丫鬟改名
    CMD_HOUSE_CHANGE_YD_NAME            = 0xA401, -- 园丁改名

    CMD_REQUEST_PARTY_TZJS_RANK         = 0xD144, -- 客户端请求挑战巨兽排行信息

    CMD_REQUEST_TEMP_FRIEND_STATE       = 0xD146, -- 客户端请求某玩家的在线状态（返回 MSG_TEMP_FRIEND_STATE 消息）

    CMD_SINGLES_2017_GOODS_BUY          = 0xA0BA, -- 抢购商品 2017光棍节
    CMD_SINGLES_2017_GOODS_REFRESH      = 0xA0BC, -- 刷新商品 2017光棍节

    CMD_SHOUCHONG_CARD_INFO             = 0xA0BE, -- 首充礼包界面白果儿

    -- 成就
    CMD_ACHIEVE_CONFIG                  = 0x80B4, -- 客户端请求成就配置
    CMD_ACHIEVE_OVERVIEW                = 0x80B6, -- 客户端请求成就总览
    CMD_ACHIEVE_VIEW                    = 0x80B8, -- 客户端请求成就数据
    CMD_ACHIEVE_BONUS                   = 0x80BA, -- 客户端请求领取成就奖励

    -- 集市、聚宝联系买家
    CMD_EXCHANGE_CONTACT_SELLER         = 0x80BC, -- 客户端请求连续交易系统的卖家
    CMD_STALL_CHANGE_PRICE              = 0x811E, -- 集市请求修改价格

    CMD_HOUSE_OPER_XYFT                 = 0xB144, -- 操作西域飞毯

    -- 个人空间
    CMD_BLOG_CHANGE_ICON                = 0x80BE, -- 修改头像
    CMD_BLOG_DELETE_ICON                = 0x80C0, -- 删除头像
    CMD_BLOG_CHANGE_LOCATION            = 0x80C2, -- 修改地理位置
    CMD_BLOG_CHANGE_SIGNATURE           = 0x80C4, -- 修改签名
    CMD_BLOG_CHANGE_TAG                 = 0x80C6, -- 修改标签
    CMD_BLOG_RESOURE_GID                = 0x80C8, -- 请求上传资源的 gid
    CMD_BLOG_OPEN_BLOG                  = 0x80CA, -- 请求打开某人的个人空间
    CMD_BLOG_REPORT                     = 0x80CC, -- 请求举报

    CMD_BLOG_MESSAGE_VIEW               = 0xA101, -- 请求留言板留言数据（根据某一条留言，请求其往后的 num 条数据）
    CMD_BLOG_MESSAGE_WRITE              = 0xA103, -- 发布留言
    CMD_BLOG_MESSAGE_DELETE             = 0xA105, -- 删除留言
    CMD_BLOG_FLOWER_PRESENT             = 0xA107, -- 赠送鲜花
    CMD_BLOG_FLOWER_OPEN                = 0xA109, -- 查询可赠送的鲜花信息
    CMD_BLOG_FLOWER_VIEW                = 0xA10B, -- 查看送花记录
    CMD_BLOG_FLOWER_UPDATE              = 0xA10D, -- 请求鲜花数目和空间人气信息

    CMD_BLOG_PUBLISH_ONE_STATUS         = 0x5150,   -- 发表状态
    CMD_BLOG_DELETE_ONE_STATUS          = 0x5152,   -- 删除状态
    CMD_BLOG_REQUEST_STATUS_LIST        = 0x5154,   -- 请求状态列表
    CMD_BLOG_REQUEST_LIKE_LIST          = 0x5156,   -- 请求某条状态的所有点赞玩家
    CMD_BLOG_OPEN_COMMENT_DLG           = 0x5158,   -- 尝试打开评论窗口
    CMD_BLOG_PUBLISH_ONE_COMMENT        = 0x515A,   -- 发表评论
    CMD_BLOG_DELETE_ONE_COMMENT         = 0x515C,   -- 删除评论
    CMD_BLOG_ALL_COMMENT_LIST           = 0x515E,   -- 请求所有评论数据
    CMD_BLOG_REPORT_ONE_STATUS          = 0x5160,   -- 举报状态
    CMD_BLOG_AGREE_STATUS_AGREEMENT     = 0x5161,   -- 同意协议
    CMD_BLOG_LIKE_ONE_STATUS            = 0x5162,   -- 点赞
    CMD_BLOG_SWITCH_VIEW_SETTING        = 0x5163,   -- 切换个人空间状态
    CMD_HMAC_SHA1_BASE64                = 0x80D0,   -- 请求 HMAC_SHA1 加密并且 BASE64 的结果
    CMD_BLOG_STATUS_LIST_ABOUT_ME       = 0x5167,   -- 与我有关的未读状态数据
    CMD_BLOG_MESSAGE_LIST_ABOUT_ME      = 0x516A,   -- 与我有关的未读留言数据
    CMD_BLOG_REQUEST_UNREAD_DATA        = 0x516C,   -- 请求空间中的未读数据
    CMD_BLOG_OSS_TOKEN                  = 0x80D4,   -- 客户端请求 oss token
    CMD_DC_REFRESH_OPPONENTS            = 0xD13A, -- 客户端请求刷新对手
    CMD_DC_LOOKON                       = 0xD140, -- 客户端请求观战斗宠s
    CMD_DC_CONFIRM_PETS                 = 0xD13E, -- 客户端确认当前阵容
    CMD_DC_CHALLENGE_OPPONENT           = 0xD138, -- 客户端发起挑战

    CMD_NEW_LOTTERY_INFO                = 0xB148,  -- 客户端新充值好礼的奖励数据
    CMD_NEW_LOTTERY_DRAW                = 0xB149,   -- 客户端请求抽奖
    CMD_NEW_LOTTERY_FETCH               = 0xB14A,   -- 客户端请求领取奖励
    CMD_NEW_LOTTERY_CANCEL              = 0xB14B,   -- 客户端请求退出本次抽奖
    CMD_TRADING_SELL_CASH               = 0x80CE,   -- 客户端请求出售金钱的信息
    CMD_PREVIEW_PET_INHERIT             = 0xA0C0,  -- 请求预览宠物继承

    CMD_SIMULATOR_LOGIN                 = 0xA201,   -- 继续以模拟器形式登录

    CMD_CLIENT_ERR_OCCUR                = 0xD15A,   -- 客户端通知服务器出现错误
    CMD_REQUEST_COMMUNITY_TOKEN         = 0xD14C,   -- 向服务器请求社区token

    CMD_NEWYEAR_2018_HYJB               = 0xD148,   -- 客户端进行好运鉴宝


    CMD_CHAT_GROUP_AITE_INFO            = 0xB14F,  -- 获取群组的 @ 信息
    CMD_PARTY_AITE_INFO                 = 0xB151,  -- 获取帮派的 @ 信息

    CMD_NEWYEAR_2018_LPXZ               = 0x80D2,  -- 2018 元旦活动罗盘寻踪

    CMD_TASK_SHUILZY_DIALOG             = 0xA203,  -- 打开【水岚之缘】任务界面
    CMD_TASK_SHUILZY_CCJM_LETTER        = 0xA205,  -- 确认已经阅读信封

    CMD_TRADING_HOUSE_DATA              = 0x5116,  -- 请求聚宝斋寄售角色的居所数据

    CMD_REQUEST_RECOMMEND_XMD           = 0xD15E,   -- 客户端请求仙魔点自动加点配置
    CMD_SET_RECOMMEND_XMD               = 0xD15C,   -- 客户端设置仙魔点自动加点
    CMD_ASSIGN_XMD                      = 0xD14A,   -- 客户端分配仙魔点

    -- 打雪仗
    CMD_WINTER2018_DAXZ_START           = 0xB165,   -- 开始游戏
    CMD_WINTER2018_DAXZ_OPER            = 0xB166,   -- 操作游戏
    CMD_WINTER2018_DAXZ_SHOW_DONE       = 0xB167,   -- 显示结束
    CMD_WINTER2018_DAXZ_QUIT_GAME       = 0xB168,   -- 退出游戏
    CMD_WINTER2018_DAXZ_PAUSE_GAME      = 0xB169,   -- 暂停游戏
    CMD_WINTER2018_DAXZ_CONTINUE_GAME   = 0xB16A,   -- 继续游戏

    CMD_WINTER_2018_HJZY                = 0x80D6,   -- 2018 寒假作业 - 客户端上传答案
    CMD_DONGSZ_2018_EAT                 = 0xD150,   -- 客户端选择柿子
    CMD_DONGSZ_2018_DONE                = 0xD152,   -- 客户端结束回合
    CMD_DONGSZ_2018_QUIT                = 0xD154,   -- 客户端请求中止游戏
    CMD_DONGSZ_2018_REQUEST_END_POS     = 0xD156,   -- 客户端退出游戏时请求当前位置
    CMD_DONGSZ_2018_SELECT              = 0xD14E,   -- 客户端请求选中柿子
    CMD_SHENMI_DALI_OPEN                = 0xA207,   -- 请求神秘大礼数据 -- 砸蛋版本
    CMD_SHENMI_DALI_PICK                = 0xA209,   -- 请求挑选银蛋


    CMD_SEVENDAY_GIFT_FETCH             = 0xB16F,  -- 领取第 n 天的登录礼包
    CMD_SEVENDAY_GIFT_LIST              = 0xB15F,  -- 请求活跃登录礼包的数据

    CMD_TRY_USE_LABA                    = 0xB17D,   --  尝试使用喇叭

    CMD_SUBMIT_XUEJING_ITEM             = 0x5026,   -- 提交血精
    CMD_AUTO_FIGHT_SET_DATA             = 0x80D8,   -- 设置自动战斗数据


    CMD_MAILBOX_GATHER_PRIVILEGE        = 0xA403,   -- 大R玩家信息收集

    CMD_SELECT_BONUS_RESULT             = 0xB173,   -- 返回选择奖励结果

    CMD_GOLD_STALL_CASH_PRICE           = 0x8120,   -- 客户端请求金钱商品的标准价格
    CMD_GOLD_STALL_CASH_GOODS_LIST      = 0x8122,   -- 请求金钱商品列表
    CMD_GOLD_STALL_BUY_CASH             = 0x8124,   -- 请求购买金钱商品

    CMD_REPORT_USER                     = 0x5204,   -- 举报玩家

    CMD_STALL_RECORD_DETAIL             = 0x8126,   -- 请求集市交易记录详细信息
    CMD_GOLD_STALL_RECORD_DETAIL        = 0x8128,   -- 请求珍宝交易记录详细信息
    CMD_DECORATION_APPLY                = 0xA20B,   -- 使用装饰
    CMD_BLOG_DECORATION_LIST            = 0xA113,   -- 请求获取某个角色的个人空间装饰信息

    CMD_EXECUTE_RESULT                  = 0xD160,   -- 客户端返回最近一次执行结果，并打印在服务器后台
    CMD_AUTO_FIGHT_SET_VICTIM           = 0x80EE,   -- 设置自动战斗的目标
    CMD_REQUEST_ALL_KILL_FIRST          = 0x5130,   -- 请求所有首杀记录

    CMD_ADMIN_BROADCAST_COMBAT_LIST     = 0x5E10,   -- 搜索战斗录像列表
    CMD_ADMIN_REQUEST_LOOKON_GDDB_COMBAT = 0x5E12,   -- 查看单场战斗录像

    CMD_FETCH_STORE_SURPLUS             = 0xA409,   -- 请求五行竞猜仓库金额

    CMD_REFRESH_NEIDAN_DATA             = 0xB17F,   -- 请求刷新内丹数据
    CMD_GET_NEIDAN_BREAK_TASK           = 0xB181,   -- 请求获得内丹突破任务
    CMD_NEIDAN_BREAK_TASK               = 0xB183,   -- 请求完成突破任务
    CMD_NEIDAN_SUBMIT_PET               = 0xB185,   -- 请求内丹修炼提交宠物

    CMD_CSC_SEASON_DATA                 = 0x80DA,   -- 客户端请求当前赛季简要信息
    CMD_CSC_RANK_DATA_TOP               = 0x80DC,   -- 客户端请求总榜数据
    CMD_CSC_RANK_DATA_STAGE             = 0x80DE,   -- 客户端请求段位榜数据
    CMD_CSC_PLAYER_CONTEST_DATA         = 0x80E2,   -- 客户端请求跨服竞技信息界面数据
    CMD_CSC_SET_COMBAT_MODE             = 0x80E4,   -- 客户端请求设置匹配模式
    CMD_CSC_SET_AUTO_MATCH              = 0x80E6,   -- 客户端请求设置自动匹配状态
    CMD_START_MATCH_TEAM_LEADER_KFJJC   = 0xC028,   -- 客户端请求匹配队员信息
    CMD_CSC_RANK_DATA_TOP_COMPETE       = 0x80F6,   -- 客户端请求总榜数据（跨服战场中）
    CMD_CSC_RANK_DATA_STAGE_COMPETE     = 0x80F8,   -- 客户端请求段位榜数据（跨服战场中）

    CMD_CANCEL_ASK_MEMBER_ASSURE        = 0xB188,   -- 退出投票
    CMD_LEAVE_JIANZHONG                 = 0x5028,   -- 离开剑冢

    CMD_WORLD_BOSS_LIFE                 = 0x80F4,   -- 请求 BOSS 的血量
    CMD_WORLD_BOSS_RANK                 = 0x80F0,   -- 请求 BOSS 的排名数据
    CMD_ROOM_GUANJIA_INFO               = 0xB18B,   -- 请求管家数据
    CMD_QUICK_USE_ITEM                  = 0xA20D,   -- 通过便捷使用框使用道具

    CMD_HOUSE_REMOTE_USE_FURNITURE      = 0x508B,   -- 远程使用家具
    CMD_TEAM_CHANGE_SEQUENCE            = 0x8206,   -- 客户端请求修改队伍顺序
    CMD_LDJ_2018_NOTIFY_COMBAT          = 0xD16A,   -- 2018劳动节活动客户端通知服务器发生战斗
    CMD_LINGMAO_FANPAI_OPER             = 0x5170,   -- 2018周年庆 灵猫翻牌
    CMD_TRADING_SEARCH_GOODS            = 0x80FA,   -- 聚宝斋请求搜索
    CMD_ZNQ_2018_REQ_LINGMAO_INFO       = 0xD16C,   -- 客户端查询灵猫信息
    CMD_ZNQ_2018_OPER_LINGMAO           = 0xD16E,   -- 客户端请求操作灵猫
    CMD_ZNQ_2018_LINGMAO_FIGHT          = 0xD170,   -- 客户端通知挑战好友灵猫
    CMD_ZNQ_2018_LOOKON                 = 0xD172,   -- 客户端请求进行观战
    CMD_ZNQ_2018_REQ_LINGMAO_SKILLS     = 0xD174,   -- 客户端请求打开顿悟界面（请求技能信息）
    CMD_ZNQ_2018_REQ_LINGMAO_FRIENDS    = 0xD176,   -- 客户端请求打开切磋界面（请求好友灵猫信息）
    CMD_ZNQ_2018_REPLACE_SKILL          = 0xD186,   -- 客户端请求替换顿悟技能
    CMD_SHOCK_FRIEND                    = 0xA115,   -- 给好友发送震动
    CMD_CSB_MATCH_INFO                  = 0xB192,   --  名人争霸请求数据

    CMD_CG_REQUEST_DAY_INFO             = 0xD182,   -- 名人争霸竞猜：客户端查询比赛日信息
    CMD_CG_SUPPORT_TEAM                 = 0xD17A,   -- 名人争霸竞猜：客户端投票支持队伍
    CMD_CG_LOOKON_GDDB_COMBAT           = 0xD184,   -- 名人争霸竞猜：客户端请求查看战斗录像
    CMD_CG_REQUEST_MY_GUESS             = 0xD17C,   -- 名人争霸竞猜：客户端请求我的竞猜数据
    CMD_CG_REQUEST_TEAM_INFO            = 0xD178,   -- 名人争霸竞猜：客户端查询队伍信息
    CMD_CG_REQUEST_SCHEDULE             = 0xD18C,   -- 名人争霸竞猜：客户端请求赛程信息
    CMD_LBS_REQUEST_OPEN_DLG            = 0x50B0,   -- 打开同城交互界面
    CMD_LBS_CHANGE_LOCATION             = 0x50B3,   -- 修改地理位置
    CMD_LBS_CHANGE_GENDER               = 0x50B4,   -- 设置性别
    CMD_LBS_CHANGE_AGE                  = 0x50B5,   -- 设置年龄
    CMD_LBS_SEARCH_NEAR                 = 0x50B6,   -- 搜索附近的人
    CMD_LBS_ADD_FRIEND                  = 0x50B8,   -- 添加区域好友
    CMD_LBS_VERIFY_FRIEND               = 0x50BA,   -- 发送好友验证并请求添加好友
    CMD_LBS_FRIEND_VERIFY_RESULT        = 0x50BB,   -- 同意或拒绝好友验证
    CMD_LBS_FRIEND_TELL                 = 0x50C0,   -- 发送聊天消息
    CMD_LBS_REMOVE_FRIEND               = 0x50C1,   -- 删除区域好友
    CMD_LBS_DISABLE_BE_SEARCH           = 0x50C4,   -- 取消位置共享
    CMD_LBS_ADD_BLACKLIST_FRIEND        = 0x50C5,   -- 添加区域好友黑名单
    CMD_LBS_RANK_INFO                   = 0x80FC,   -- 请求区域排行榜数据

    CMD_DIVINE_START_GAME               = 0x8200,   -- 请求开始摇签
    CMD_DIVINE_END_GAME                 = 0x8202,   -- 请求结束摇签

    CMD_MERGE_DURABLE_ITEM              = 0xD18A,   -- 客户端请求合成耐久度道具

    CMD_APPLY_INSIDER_GIFT              = 0xA40A,   -- 使用会员礼包

    CMD_GET_CHAR_INFO                   = 0x8207,    -- 获取执行玩家的信息
    CMD_CG_REQUEST_INFO                 = 0xD19C,   -- 客户端请求名人争霸竞猜信息
	CMD_HANDBOOK_COMMENT_QUERY_LIST     = 0x5180,   -- 请求图鉴评论查询列表
    CMD_HANDBOOK_COMMENT_PUBLISH        = 0x5182,   -- 发布评论
    CMD_HANDBOOK_COMMENT_DELETE         = 0x5184,   -- 删除评论
    CMD_HANDBOOK_COMMENT_LIKE           = 0x5186,   -- 点赞

    CMD_PET_DELETE_SOUL                 = 0xB1A2,   -- 取出彩凤之魂

    CMD_DAXZ_START                      = 0xB19E,   -- 开始游戏
    CMD_DAXZ_OPER                       = 0xB19F,   -- 操作游戏
    CMD_DAXZ_SHOW_DONE                  = 0xB1A0,   -- 显示结束
    CMD_DAXZ_QUIT_GAME                  = 0xB1A1,   -- 退出游戏

    CMD_DUANWU_2018_EXPLAIN             = 0xA0C8,   -- 2018端午，说明界面关闭时通知服务器
    CMD_DUANWU_2018_COLLISION           = 0xA0C6,   -- 在“无名仙境”，玩家与“噬仙虫”发生碰撞时，需要通过以下新增指令通知服务端

    CMD_SUMMER_2018_HQZM_INDEX          = 0xB1C7,   -- 客户端发送索引
    CMD_SUMMER_2018_HQZM_GAME_END       = 0xB1C8,   -- 游戏结束

    CMD_YUANSGW_ACCEPTED_COMMAND        = 0xA0D6,   -- 元神归位发送动作指令
    CMD_YUANSGW_QUIT_GAME               = 0xA0D0,   -- 请求退出游戏
    CMD_YUANSGW_END_ANIMATE             = 0xA0D2,   -- 通知动画播完

    CMD_TRADING_AUTO_LOGIN_TOKEN        = 0x5210,   -- 客户端请求聚宝斋自动登录
    CMD_SUMMER_2018_PUZZLE              = 0xA0CA,   -- 通知服务端移动结果

    CMD_OVERCOME_SET_SIGNATURE          = 0x50D0,   -- 证道殿修改护法宣言
    CMD_TRADING_AUCTION_BID_LIST        = 0x820A,   -- 请求聚宝斋竞拍列表

    CMD_TRADING_BUY_GOODS               = 0x820C,   -- 请求购买、竞拍商品


    CMD_SUMMER_2018_CHIGUA_ACCELERATE   = 0x5173,   -- 吃瓜比赛 - 加速
    CMD_SUMMER_2018_CHIGUA_ARRIVE       = 0x5174,   -- 吃瓜比赛 - 有人到达终点

    CMD_WB_DIARY_SUMMARY                = 0xB1A5,   -- 打开日记本
    CMD_WB_DIARY                        = 0xB1A7,   -- 打开一篇日记
    CMD_WB_DIARY_ADD                    = 0xB1A9,   -- 新增日志
    CMD_WB_DIARY_EDIT                   = 0xB1AB,   -- 编辑日记
    CMD_WB_DIARY_DELETE                 = 0xB1AD,   -- 删除日记
    CMD_WB_DAY_SUMMARY                  = 0xB1AF,   -- 查看纪念日
    CMD_WB_DAY_ADD                      = 0xB1B1,   -- 新增纪念日
    CMD_WB_DAY_EDIT                     = 0xB1B3,   -- 编辑纪念日
    CMD_WB_DAY_DELETE                   = 0xB1B5,   -- 删除纪念日
    CMD_WB_CLOSE_BOOK                   = 0xB1B7,   -- 关闭纪念册
    CMD_WB_HOME_PIC                     = 0xB1B8,   -- 主界面图片
    CMD_WB_PHOTO_COMMIT                 = 0xB1BA,   -- 提交图片
    CMD_WB_PHOTO_EDIT_MEMO              = 0xB1BC,   -- 编辑描述
    CMD_WB_PHOTO_DELETE                 = 0xB1BE,   -- 删除图片
    CMD_WB_PHOTO_SUMMARY                = 0xB1C1,   -- 请求相册列表
    CMD_WB_REPORT_HOME_PIC              = 0xB1EC,   -- 举报主页照片
    CMD_WB_REPORT_PHOTO                 = 0xB1ED,   -- 举报照片

    CMD_LCHJ_REQUEST_PETS_INFO           = 0xD190,   -- 客户端请求布阵信息
    CMD_LCHJ_CONFIRM_PETS_INFO           = 0xD192,   -- 客户端确认布阵信息
    CMD_LCHJ_SET_DISABLE_SKILLS          = 0xD194,   -- 客户端设置宠物的禁用技能信息
    CMD_LCHJ_CHALLENGE                   = 0xD196,   -- 客户端请求进入战斗
    CMD_LCHJ_LOOKON                      = 0xD198,   -- 客户端请求进入观战
    CMD_SKIP_LOOK_ON                     = 0xD19A,   -- 客户端请求跳过当前观战
    CMD_CG_CAN_OPEN_SECHEDULE           = 0xB1D0,    -- 是否可以打开赛程界面


    CMD_HEISHI_KANJIA_START             = 0xD19E,   -- 客户端开始砍价游戏（开始或从暂停恢复）
    CMD_HEISHI_KANJIA_QUIT              = 0xD1A0,   -- 客户端退出黑市砍价
    CMD_HEISHI_KANJIA_PAUSE              = 0xD1A2,   -- 客户端暂停黑市砍价
    CMD_HEISHI_KANJIA                   = 0xD1A4,   -- 客户端进行砍价

    CMD_INN_UPGRADE_ROOM        = 0x820E,   -- 客栈 - 请求升级客房
    CMD_INN_UPGRADE_TABLE       = 0x8210,   -- 客栈 - 请求升级餐桌
    CMD_INN_UPGRADE_WAITING     = 0x8212,   -- 客栈 - 请求升级候客区
    CMD_INN_GUEST_COME_IN       = 0x8214,   -- 客栈 - 迎客
    CMD_INN_CHANGE_GUEST_STATE  = 0x8216,   -- 客栈 - 请求改变客人状态
    CMD_MERGE_LOGIN_GIFT_LIST           = 0x5206,   -- 合服登录礼包
    CMD_MERGE_LOGIN_GIFT_FETCH          = 0x5208,   -- 合服登录礼包 - 领取

    CMD_OPEN_XUNDAO_CIFU                = 0xA40C,   -- 请求打开寻道赐福
    CMD_RECV_XUNDAO_CIFU                = 0xA40E,   -- 请求吸收寻道赐福
    CMD_OPEN_HUOYUE_JIANGLI             = 0xA410,   -- 请求打开界面
    CMD_RECV_HUOYUE_JIANGLI             = 0xA412,   -- 请求领取奖励


    CMD_CSB_GM_OPEN_CONTROL             = 0xB1D4,   -- GM 请求名人争霸控制
    CMD_CSB_GM_CONFIRM_COMBAT_RESULT    = 0xB1D7,   -- 确认战斗结果
    CMD_CSB_GM_CANCEL_CONTROL_INFO      = 0xB1D8,   -- 退出控制
    CMD_CSB_GM_START_COMBAT             = 0xB1D5,   -- 开始战斗

    CMD_CSB_GM_COMMIT_FINAL_WINNER      = 0xB1D9,   -- 确认最后的冠军,名人争霸
    CMD_LBS_ADD_FRIEND_TO_TEMP          = 0x50C7,   -- 添加区域最近联系人

    CMD_LD_CHECK_CONDITION              = 0xB1E2,   -- 检查生死状的条件
    CMD_LD_START_LIFEDEATH              = 0xB1DB,   -- 开始一个生死状
    CMD_LD_LIFEDEATH_LIST               = 0xB1DD,   -- 请求生死状列表
    CMD_LD_MATCH_LIFEDEATH_COST         = 0xB1E0,   -- 请求手续费
    CMD_LD_MATCH_DATA                   = 0xB1E3,   -- 请求比赛数据
    CMD_LD_ACCEPT_MATCH                 = 0xB1E5,   -- 接受挑战
    CMD_LD_REFUSE_MATCH                 = 0xB1E6,   -- 拒绝挑战
    CMD_LD_ENTER_ZHANC                  = 0xB1E7,   -- 参战
    CMD_LD_HISTORY_PAGE                 = 0xB1E8,   -- 分页历史数据
    CMD_LD_MY_HISTORY_PAGE              = 0xB1EA,   -- 分页查询玩家历史数据
    CMD_LD_LOOKON_MATCH                 = 0xB1FC,    -- 观看生死状

    CMD_BUY_CHAR_ITEM_CB                = 0xB1EF,   -- 购买商城道具回调，当道具购买成功/失败（包括关闭界面，取消购买）时通知服务端

    CMD_INN_TASK_FETCH_BONUS               = 0x821E, -- 客栈 - 请求领取任务奖励
    CMD_HOUSE_PLAYER_PRACTICE_HELP_TARGETS = 0x5099, -- 请求人物修炼可协助的好友的数据
    CMD_HERO_SET_SIGNATURE              = 0x50D2,   -- 英雄会，修改角色签名
    CMD_WORLD_CUP_2018_PLAY_TABLE       = 0x520A,   -- 2018世界杯 -- 查询赛事数据
    CMD_WORLD_CUP_2018_SELECT_TEAM      = 0x520D,
    CMD_WORLD_CUP_2018_FETCH_BONUS      = 0x520F,   -- 2018世界杯 -- 领取奖励

    CMD_INN_CHANGE_NAME                    = 0x8218, -- 客栈 - 请求修改客栈名字

    CMD_FASION_CUSTOM_VIEW              = 0xA20F,   -- 打开时装自定义界面
    CMD_FASION_CUSTOM_SWITCH            = 0xA211,   -- 切换标签页
    CMD_FASION_CUSTOM_EQUIP             = 0xA212,   -- 穿戴时装
    CMD_FASION_CUSTOM_BUY               = 0xA213,   -- 购买时装
    CMD_FASION_CUSTOM_UNEQUIP           = 0xA21D,   -- 卸下时装
    CMD_FASION_FAVORITE_VIEW            = 0xA214,   -- 打开收藏柜
    CMD_FASION_FAVORITE_ADD             = 0xA216,   -- 收藏柜操作 - 新增
    CMD_FASION_FAVORITE_DEL             = 0xA218,   -- 收藏柜操作 - 删除
    CMD_FASION_FAVORITE_RENAME          = 0xA21A,   -- 收藏柜操作 - 重命名
    CMD_FASION_FAVORITE_APPLY           = 0xA21C,   -- 收藏柜操作 - 使用
    CMD_FASION_CUSTOM_DISABLE           = 0xA21E,   -- 时装自定义展示
    CMD_FASION_EFFECT_DISABLE           = 0xA21F,   -- 特效开关
    CMD_INN_ENTERTAIN_GUEST             = 0x8220,   -- 客栈 - 开始招待客人
    CMD_FASION_CUSTOM_EQUIP_EX          = 0x8226,   -- 自定义时装 - 批量穿戴

    CMD_CANCEL_COMMUNITY_REDPOINT       = 0xD1BE,   -- 客户端通知服务器取消微社区小红点标记
    CMD_REPORT_DEVICE                   = 0xD1C0,   -- 客户端上报机型信息

    CMD_APPLY_CHAOJISHENSHOUDAN         = 0xD1CA,   -- 批量使用超级神兽丹
    CMD_HOUSE_REST_ANIMATE_DONE         = 0xB222,   -- 通知床动画播放结束


    CMD_DETECTIVE_TASK_CLUE             = 0x50E0,    -- 查看卷宗
    CMD_RKSZ_PAPER_MESSAGE              = 0x50E2,    -- 查看纸条
    CMD_RKSZ_READ_PAPER_MESSAGE         = 0x50E4,    -- 读纸条
    CMD_DETECTIVE_TASK_CLUE_MEMO        = 0x50E6,    -- 备注
    CMD_RKSZ_ANSWER_CODE                = 0x50E5,    -- 对暗号

    CMD_TEACHER_2018_GAME_S2_SELECT     = 0xB1F5,   -- 教师节拔草游戏力度
    CMD_TEACHER_2018_GAME_S2_SHOCK      = 0xB1F8,   -- 教师节拔草游戏震动提醒
    CMD_TEACHER_2018_GAME_S6_SELECT     = 0xB1F7,   -- 教师节答题游戏答题

    CMD_TEACHER_2018_LXES_APPLY_ZZ      = 0xB1FB,   -- 2018 教师节使用种子，在 S1 状态下点击任务界面使用
    CMD_TANAN_JHLL_GAME_XY              = 0x821A,   -- 【探案】江湖绿林 - 结束巡游
    CMD_TANAN_JHLL_GAME_GZ              = 0x821C,   -- 【探案】江湖绿林 - 开始、结束跟踪
    CMD_MXAZ_USE_EXHIBIT                = 0x50E8,   -- 迷仙镇案使用证物

    CMD_TWZM_BOX_ANSWER                 = 0xD1AA,   -- 客户端通知服务器开锁的点击次数
    CMD_TWZM_RESPONSE_BOX_RESULT        = 0xD1A8,   -- 客户端通知成功动画播放完毕
    CMD_TWZM_FINISH_JIGSAW              = 0xD1B4,   -- 客户端通知完成了拼图
    CMD_TWZM_JIGSAW_STATE               = 0xD1BA,   -- 客户端发送拼图状态
    CMD_TWZM_START_PICK_PEACH           = 0xD1AE,   -- 通知开始摘桃子游戏
    CMD_TWZM_QUIT_PICK_PEACH            = 0xD1B0,   -- 通知摘桃子游戏得分
    CMD_TWZM_PAUSE_PICK_PEACH           = 0xD1AC,   -- 客户端请求暂停游戏
    CMD_TWZM_MATRIX_ANSWER              = 0xD1B2,   -- 客户端发送矩阵变数
    CMD_TWZM_MATRIX_STATE               = 0xD1BC,   -- 客户端发送矩阵的当前状态
    CMD_TWZM_RESPONSE_MATRIX_RESULT     = 0xD1B6,   -- 客户端通知矩阵动画播放完毕
    CMD_TWZM_CHUANYINFU_ANSWER          = 0xD1B8,   -- 客户端通知收到的传音信息

    CMD_CSQ_ALL_TIME          = 0xB20A,   -- 所有比赛的时间节点
    CMD_CSQ_SCORE_RANK        = 0xB20C,   -- 请求积分排行榜
    CMD_CSQ_SCORE_TEAM_DATA   = 0xB20E,   -- 请求积分排行榜上的队伍数据
    CMD_CSQ_KICKOUT_DATA      = 0xB210,   -- 请求淘汰赛数据
    CMD_CSQ_MY_DATA           = 0xB212,   -- 请求自己的全民PK数据
    CMD_CSQ_KICKOUT_TEAM_DATA = 0xB214,   -- 请求淘汰赛的队伍数据

    CMD_CSQ_GM_OPEN_CONTROL	= 0xB201,            -- 请求控制
    CMD_CSQ_GM_START_COMBAT = 0xB202,            -- 开始战斗
    CMD_CSQ_GM_CONFIRM_COMBAT_RESULT = 0xB204,   -- 确认战斗结果
    CMD_CSQ_GM_CANCEL_CONTROL = 0xB205,          -- 退出控制
    CMD_CSQ_GM_COMMIT_WINNER = 0xB206,           -- 设置比赛结果
    CMD_CSQ_MATCH_INFO = 0xB207,                 -- 请求当前比赛数据
    CMD_PREVIEW_RESONANCE_ATTRIB = 0xD1C2,       -- 客户端请求共鸣属性值
    CMD_PKM_UPGRADE_CHANGE = 0xD1C4,             -- 客户端请求转换仙魔

    CMD_TEACHER_2018_HELP =  0xB224,             -- 客户端请求协助 2018教师节
    CMD_REMOVE_NPC_TEMP_MSG = 0x822A,            -- 客户端通知服务器移除 NPC 聊天

    -- 四方棋局
    CMD_NATIONAL_2018_SFQJ              = 0x8222,   -- 2018 国庆节 - 四方棋局
    CMD_NATIONAL_2018_SFQJ_MOVE         = 0x8224,   -- 2018 国庆节 - 四方棋局，移动棋子

    CMD_LEARN_UPPER_STD_SKILL_COST      = 0x50D5,   -- 查询精研
    CMD_LEARN_UPPER_STD_SKILL           = 0x50D4,   -- 精研技能

    CMD_JIUTIAN_ZHENJUN                 = 0x8228,   -- 请求挑战九天真君

    -- 真假月饼
    CMD_AUTUMN_2018_GAME_START          = 0xA0E8,   -- 请求开始游戏
    CMD_AUTUMN_2018_GAME_FINISH         = 0xA0EA,   -- 汇报本关卡游戏结果

    CMD_AUTUMN_2018_DWW_SELECT_ICON     = 0x5191,   -- 大胃王 - 选择变身形象
    CMD_AUTUMN_2018_DWW_QUIT            = 0x5193,   -- 大胃王 - 退出比赛
    CMD_AUTUMN_2018_DWW_PROGRESS        = 0x5194,   -- 大胃王 - 比赛进度
    CMD_AUTUMN_2018_DWW_AGAIN           = 0x5197,   -- 大胃王 - 再次挑战

    CMD_TASK_TIP_EX                     = 0x822C,

    -- 重阳-畅饮菊酒
    CMD_CHONGYANG_2018_GAME_FINISH      = 0xA0ED,   -- 通知服务端游戏结果

    CMD_CLICK_NPC                       = 0xD1C6,   -- 点击NPC发送消息
    CMD_REQUEST_ZZQN_CARD_INFO          = 0xD1C8,   -- 客户端请求名片信息

    -- 灵音镇魔
    CMD_HALLOWMAX_2018_LYZM_STUDY_RESULT = 0xB21A,   -- 2018万圣节学习结果
    CMD_HALLOWMAX_2018_LYZM_GAME_RESULT  = 0xB21D,   -- 2018万圣节游戏结果
    CMD_HALLOWMAX_2018_LYZM_GAME_FINISH  = 0xB21E,   -- 2018万圣节游戏结束
    CMD_HALLOWMAX_2018_LYZM_GAME_CONTINUE  = 0xB21F,   -- 2018万圣节游戏继续

    CMD_CHECK_SERVER                     = 0x121E,      -- 客户端请求进行校验

    CMD_QYGD_SELECT_ANSWER_2018         = 0xD1CC,       -- 客户端选择选项
    CMD_QYGD_CLOSE_DLG_2018             = 0xD1CE,       -- 客户端通知关闭了游戏界面

    CMD_FASION_CUSTOM_BUY_EFFECT        = 0xB226,       -- 购买特效道具
    CMD_FASION_EFFECT_VIEW              = 0xB227,       -- 查看可购买特效列表
    CMD_BUY_FASHION_PET                 = 0xD1D0,       -- 购买跟随宠道具
    CMD_FOLLOW_PET_VIEW                 = 0xD1D2,       -- 请求跟随宠道具列表

    CMD_SXYS_ANSWER_2019                 = 0xD1D4,       -- 客户端答题               2019年寒假活动之赏雪吟诗
    CMD_CLOSE_DIALOG                     = 0xD1D6,       -- 客户端关闭答题界面

    -- 宝物守卫战
    CMD_BWSWZ_LEAVE_GAME_2019            = 0xD1D8,       -- 客户端退出游戏
    CMD_BWSWZ_NOTIFY_RESULT_2019         = 0xD1DA,       -- 客户端通知游戏结果

    -- 冰雪21点
    CMD_WINTER_2019_BX21D_PREPARE       = 0xB22C,           -- 准备
    CMD_WINTER_2019_BX21D_ACTION_END    = 0xB22D,           -- 动画播放结束
    CMD_WINTER_2019_BX21D_OPER          = 0xB22E,           -- 玩家操作
    CMD_WINTER_2019_BX21D_QUIT          = 0xB232,           -- 退出游戏
    CMD_WINTER_2019_BX21D_CONTINUE      = 0xB233,           -- 继续游戏

    CMD_EXP_WARE_FETCH                 = 0xB234,           -- 领取经验仓库数值

    CMD_CXK_START_GAME_2019             = 0xD1DE,           -- 客户端请求开始游戏
    CMD_CXK_FINISH_GAME_2019            = 0xD1DC,           -- 客户端通知结果

    CMD_SET_ACTION_STATUS               = 0xB229,        -- 设置动作状态

    -- 登录排队
    CMD_L_START_RECHARGE                = 0xB235,        -- 请求开始充值
    CMD_L_START_BUY_INSIDER             = 0xB23A,        -- 请求开始购买会员
    CMD_L_CHARGE_LIST                   = 0xB238,        -- 请求充值的首充数据
    CMD_L_LINE_DATA                     = 0xB23B,        -- 请求会员队列数据
    CMD_GET_AAA_CHARGE_BONUS            = 0xB242,        -- 请求充值奖励结果

    CMD_HOUSE_PET_STORE_ADD_SIZE        = 0x50A5,           -- 扩充居所宠物仓库格子
    CMD_HOUSE_PET_STORE_OPERATE         = 0x50A6,           -- 操作居所宠物仓库
    CMD_EXCHANGE_EPIC_PET_EXIT          = 0x50AA,           -- 变异兑换神兽 - 退出商店
    CMD_EXCHANGE_EPIC_PET_SUBMIT_DLG    = 0x50AC,           -- 变异兑换神兽 - 请求打开提交界面
    CMD_EXCHANGE_EPIC_PET_EXCHANGE      = 0x50AE,           -- 变异兑换神兽 - 兑换

    CMD_GIVING_RECORD                   = 0xB24A,           -- 请求赠送记录
    CMD_GIVING_RECORD_CARD              = 0xB24C,           -- 请求赠送记录名片

    -- 2019春节-钟声祈福
    CMD_SPRING_2019_ZSQF_COMMIT_GAME    = 0xB25E,           -- 提交敲钟游戏数据
    CMD_SPRING_2019_ZSQF_START_GAME     = 0xB25C,           -- 开始敲钟游戏
    CMD_SPRING_2019_ZSQF_FETCH          = 0xB260,           -- 领取奖励
    CMD_SPRING_2019_ZSQF_QUIT_GAME      = 0xB267,           -- 2019春节退出游戏

    CMD_MATCH_MAKING_REQ_LIST           = 0xD1E2,           -- 请求寻缘信息
    CMD_MATCH_MAKING_REQ_SETTING        = 0xD1E6,           -- 请求寻缘个人设置信息
    CMD_MATCH_MAKING_REQ_DETAIL         = 0xD1E4,           -- 请求寻缘详细信息
    CMD_MATCH_MAKING_PUBLISH            = 0xD1E8,           -- 发布寻缘信息
    CMD_MATCH_MAKING_OPER_ICON          = 0xD1EA,           -- 修改头像
    CMD_MATCH_MAKING_OPER_MESSAGE       = 0xD1EC,           -- 修改留言
    CMD_MATCH_MAKING_ADD_FAVORITE       = 0xD1EE,           -- 添加收藏
    CMD_MATCH_MAKING_OPER_VOICE         = 0xD1F0,           -- 修改语音留言
    CMD_MATCH_MAKING_OPER_GENDER        = 0xD1E6,           -- 修改真实性别
    CMD_MATCH_MAKING_OPER_RECV_MSG      = 0xD1F2,           -- 修改是否接收红娘消息
    CMD_OPEN_WEDDING_BOOK               = 0xD1F4,           -- 请求打开结婚纪念册
    CMD_KICK_OFF_CLIENT                 = 0xD1F8,           -- 客户端通知服务器将客户端踢下线并记录日志
    CMD_MXZA_EXHIBIT_ITEM_LIST          = 0x50EA,           -- 迷仙镇案证物列表
    CMD_MXZA_SUBMIT_EXHIBIT             = 0x50ED,           -- 选择提交证物

    CMD_GOLD_STALL_BID_GOODS            = 0x812A,           -- 珍宝请求竞拍商品
    CMD_GOLD_STALL_BUY_AUCTION_GOODS    = 0x812C,           -- 珍宝请求购买竞拍商品
    CMD_GOLD_STALL_MY_BID_GOODS         = 0x812E,           -- 珍宝请求我竞拍商品


    CMD_YUANXJ_2019_SELECT_TARGET_NPC   = 0x502A,           -- 选择今日邀约之人
    CMD_YUANXJ_2019_MAKE_TASK_ITEM      = 0x502B,           -- 制作约会表现攻略
    CMD_YUANXJ_2019_PLAY_SCENARIO       = 0x502D,           -- 播放约会剧本


    CMD_SPRING_2019_XCXB_USE_TOOL       = 0xB262,           -- 2019春节使用工具
    CMD_SPRING_2019_XCXB_BUY_TOOL       = 0xB263,           -- 2019春节购买工具
    CMD_SPRING_2019_XCXB_BONUS_DATA     = 0xB264,           -- 2019春节奖励数据
    CMD_SPRING_2019_XCXB_BUY_DATA       = 0xB26D,           -- 2019春节购买界面数据
    CMD_SPRING_2019_XCXB_GET_BONUS       = 0xB26F,          -- 2019新春寻宝领取奖励
	CMD_SPRING_2019_XCXB_FINISH         = 0xB274,           -- 2019新春寻宝退出游戏

    CMD_VALENTINE_2019_PREPARE_START_GAME       = 0x503B,   -- 情人节采集玫瑰 - 准备开始

    CMD_SPRING_2019_XTCL_COMMIT         = 0xB26C,           -- 提交游戏结果

    CMD_STOP_BUILD_FIXED_TEAM           = 0xD1FA,           -- 停止缔结固定队
    CMD_CONFIRM_START_BUILD_FIXED_TEAM  = 0xD1FC,           -- 确认开始缔结固定队
    CMD_SET_FIXED_TEAM_APPELLATION      = 0xD1FE,           -- 设置固定队称谓
    CMD_CONFIRM_FIXED_TEAM_APPELLATION  = 0xD200,           -- 确认固定队称谓
    CMD_FINISH_BUILD_FIXED_TEAM         = 0xD202,           -- 完成缔结固定队
    CMD_FIXED_TEAM_OPEN_SUPPLY_DLG      = 0xD204,           -- 打开补充储备界面
    CMD_FIXED_TEAM_SUPPLY               = 0xD206,           -- 使用补充储备
    CMD_FIXED_TEAM_ONE_KEY              = 0xD208,           -- 一键组队
    CMD_FIXED_TEAM_OPEN_ALL_SETTING     = 0xD20A,           -- 全部开启固定队开关
    CMD_FIXED_TEAM_REQUEST_DATA         = 0xD20C,           -- 请求固定队信息
    CMD_REQUEST_USER_REALTIME_CARD      = 0xD20E,           -- 请求玩家实时快照(若不在线则返回下线时间快照)

    -- 招募
    CMD_FIXED_TEAM_RECRUIT_SINGLE            = 0x50F0,      -- 操作个人招募 新删改查
    CMD_FIXED_TEAM_RECRUIT_SINGLE_QUERY_LIST = 0x50F1,      -- 查看个人招募信息列表
    CMD_FIXED_TEAM_RECRUIT_TEAM              = 0x50F5,      -- 操作个人招募信息
    CMD_FIXED_TEAM_RECRUIT_TEAM_QUERY_LIST   = 0x50F6,      -- 查看队伍招募信息列表
    CMD_FIXED_TEAM_CHECK                     = 0x50FB,      -- 请求是否有固定队

    CMD_GOLD_STALL_PAY_DEPOSIT               = 0x8130,      -- 珍宝请求支付指定交易定金

    CMD_L_GET_COMMUNITY_ADDRESS              = 0xB280,      -- 请求微社区的地址

    CMD_SPRING_2019_XTCL_STOP                = 0xB287,      -- 2019停止喜填春联游戏

    CMD_USE_TONGTIAN_LINGPAI                 = 0xB289,      -- 使用通天令牌
    CMD_SET_SHUADAO_RUYI_AMT_STATE           = 0xB293,      -- 如意刷道令自动匹配状态

    CMD_BJTX_FIND_FRIEND                = 0x822E,           -- 并肩同行 - 请求退出匹配
    CMD_BJTX_WELFARE                    = 0x8230,           -- 并肩同行 - 打开福利界面
    CMD_BJTX_FETCH_BONUS                = 0x8232,           -- 并肩同行 - 领取奖励

    CMD_MAP_DECORATION_START                    = 0xB278,   -- 开始摆件
    CMD_MAP_DECORATION_FINISH                   = 0xB27A,   -- 结束摆件
    CMD_MAP_DECORATION_PLACE                    = 0xB275,   -- 摆一个摆件
    CMD_MAP_DECORATION_MOVE                     = 0xB276,   -- 移动一个摆件
    CMD_MAP_DECORATION_REMOVE                   = 0xB277,   -- 移除一个摆件
    CMD_MAP_DECORATION_BUY                      = 0xB27C,   -- 购买摆件
    CMD_MAP_DECORATION_CHECK                    = 0xB27E,   -- 检查是否是自己的摆件

    CMD_USE_FOOLS_DAY_LABA                      = 0xD210,   -- 使用愚人节喇叭
    CMD_FOOLS_DAY_2019_FINISH_GAME              = 0xD212,   -- 结束饮酒

    CMD_2019ZNQFP_START                         = 0xB284,   --  2019周年庆萌猫翻牌开始
    CMD_2019ZNQFP_COMMIT                        = 0xB285,   --  2019周年庆萌猫翻牌提交

    CMD_SMDG_TRIGGER_EVENT                      = 0xD216,   -- 客户端通知触发了事件
    CMD_SMDG_PASS_GAME                          = 0xD21A,   -- 客户端通知迷宫通关
    CMD_SMDG_QUIT_GAME                          = 0xD21C,   -- 客户端通知退出迷宫
    CMD_SMDG_MOVE                               = 0xD218,   -- 客户端通知迷宫移动信息
    CMD_SMDG_START_GAME                         = 0xD214,   -- 客户端通知开始游戏
    CMD_2019ZNQFP_FINISH                        = 0xB28A,   -- 2019周年庆萌猫翻牌结束

    CMD_2019ZNQ_CWTX_DATA                       = 0x51A1,   -- 秘境探险 游戏数据
    CMD_2019ZNQ_CWTX_START                      = 0x51A3,   -- 开始游戏
    CMD_2019ZNQ_CWTX_BONUS_TYPE                       = 0x51A4,   -- 设置奖励类型
    CMD_2019ZNQ_CWTX_CLICK                      = 0x51A5,   -- 点击格子
    CMD_2019ZNQ_CWTX_BACK                       = 0x51A8,   -- 通过时空秘境返回之前的地图
    CMD_CHILD_DAY_2019_RESULT            = 0xD21E,   -- 2019儿童节护送小龟 客户端通知游戏结果
    CMD_CHILD_DAY_2019_TRIGGER_EVENT     = 0xD220,   -- 2019儿童节护送小龟 客户端通知服务器触发事件
    CMD_CHILD_DAY_2019_START_MSJ_FAIL    = 0xD228,   -- 2019儿童节护送小龟 客户端通知服务器析构美食家
    CMD_CHILD_DAY_2019_NOTIFY_DATA       = 0xD24C,   -- 2019儿童节护送小龟 客户端通知实时数据

    CMD_TEAM_COMMANDER_GET_CMD_LIST    = 0x5054,   -- 队伍指挥 - 获取自定义命令
    CMD_TEAM_COMMANDER_SET_CMD_LIST    = 0x5056,   -- 队伍指挥 - 设置自定义命令
    CMD_TEAM_COMMANDER_ASSIGN          = 0x5057,   -- 队伍指挥 - 分配、取消指挥权限
    CMD_TEAM_COMMANDER_COMBAT_COMMAND  = 0x5059,   -- 队伍指挥 - 战斗中发布队伍指挥指令

    CMD_DW_2019_ZDBC_FINISH                     = 0xB290,   -- 2019 智斗百草结束游戏
    CMD_DW_2019_ZDBC_COMMIT                     = 0xB292,   -- 2019 智斗百草提交结果

    CMD_OPEN_TTLP_DLG                           = 0xD226,   -- 客户端请求打开通天令牌界面
    CMD_RESTORE_TTTD_XINGJUN                    = 0xD222,   -- 恢复初始通天塔顶挑战目标
    CMD_RANDOM_TTTD_XINGJUN                     = 0xD224,   -- 随机通天塔顶挑战目标
    CMD_LOG_INN_EXCEPTION                    = 0x5053,      -- 客栈异常日志

    CMD_SMFJ_BXF_REPORT_RESULT                  = 0x5134,   -- 通天塔神秘房间  变戏法箱子兔子数
    CMD_SMFJ_YLMB_MOVE_STEP                     = 0x5137,   -- 神秘房间 - 幽灵漫步移动
    CMD_SMFJ_YLMB_IS_READY                      = 0x5139,   -- 神秘房间 幽灵漫步演示结束
    CMD_SMFJ_SWZD_MOVE_STEP                     = 0x513E,

    CMD_SET_PET_FASION_VISIBLE                  = 0x512F,   -- 是否显示时装形象

    CMD_CHANGE_CHAT_GROUP_LEADER                = 0xB294,   -- 更改群主

    CMD_SMFJ_BSWH_PLAYER_ICON                   = 0x513B,   -- 神秘房间 变身舞会确定形象
    CMD_SMFJ_CJDWW_ADD_PROGRESS                 = 0x5142,   -- 神秘房间 - 超级大胃王 - 添加进度

    CMD_REQUEST_AUTO_WALK_LINE                  = 0xD22E,   -- 客户端请求自动寻路线路
    CMD_SPRING_2019_BNDH                     = 0x8246,      -- 客户端播放拜年动画结束

    CMD_SUMMER_2019_SMSZ_SMHJ_COMMIT            = 0xB296,   -- 2019 暑假神秘数字之神秘画卷提交
    CMD_SUMMER_2019_SMSZ_SMBH_COMMIT            = 0xB299,   -- 2019 暑假神秘数字之神秘宝盒提交
    CMD_SUMMER_2019_SMSZ_SMHJ_STOP              = 0xB297,   -- 2019 暑假神秘数字之神秘画卷停止
    CMD_SUMMER_2019_SMSZ_SMBH_STOP              = 0xB29A,   -- 2019 暑假神秘数字之神秘宝盒停止
    CMD_SUMMER_2019_SMSZ_SMHJ_OPEN              = 0xB29B,   -- 2019 暑假神秘数字之神秘画卷打开

    CMD_TRADING_SPOT_DATA                   = 0x51B1,   -- 请求货站数据
    CMD_TRADING_SPOT_COLLECT                = 0x51B3,   -- 收藏商品
    CMD_TRADING_SPOT_GOODS_DETAIL           = 0x51B5,   -- 请求货品详情数据
    CMD_TRADING_SPOT_PROFIT                 = 0x51B9,   -- 请求盈亏数据
    CMD_TRADING_SPOT_BUY_GOODS              = 0x51BC,   -- 购买商品
    CMD_TRADING_SPOT_GET_MONEY              = 0x51BB,   -- 取钱
    CMD_TRADING_SPOT_RANK_LIST              = 0x51BF,   -- 十人巨商
    CMD_TRADING_SPOT_BID_ONE_PLAN           = 0x51C4,   -- 一键跟买
    CMD_TRADING_SPOT_CARD_GOODS_LIST        = 0x51C5,   -- 买过商品列表

    CMD_CSML_ROUND_TIME                         = 0x8236,   -- 跨服战场2019 客户端请求比赛时间
    CMD_CSML_ALL_SIMPLE                         = 0x8238,   -- 跨服战场2019 客户端请求所有联赛简要信息
    CMD_CSML_LEAGUE_DATA                        = 0x823A,   -- 跨服战场2019 客户端请求具体赛区的数据
    CMD_CSML_MATCH_SIMPLE                       = 0x823C,   -- 跨服战场2019 客户端请求具体比赛简要数据
    CMD_CSML_MATCH_DATA                         = 0x823E,    -- 跨服战场2019 客户端请求具体比赛数据
    CMD_CSML_CONTRIB_TOP_DATA                   = 0x8240,   -- 跨服战场2019 客户端请求个人总积分数据
    CMD_CSML_LIVE_SCORE                         = 0x8234,   -- 跨服战场2019 客户端请求战场实时数据

    -- 商贾货站玩法-讨论
    CMD_BBS_PUBLISH_ONE_STATUS                  = 0x51D0,   -- 发表状态
    CMD_BBS_DELETE_ONE_STATUS					= 0x51D2,	-- 删除状态
    CMD_BBS_REQUEST_STATUS_LIST                 = 0x51D4,   -- 请求状态列表
    CMD_BBS_REQUEST_LIKE_LIST                   = 0x51D6,   -- 请求某条状态的所有点赞玩家
    CMD_BBS_PUBLISH_ONE_COMMENT                 = 0x51DA,   -- 发表评论
    CMD_BBS_DELETE_ONE_COMMENT                  = 0x51DC,   -- 删除评论
    CMD_BBS_ALL_COMMENT_LIST                    = 0x51DE,   -- 请求所有评论数据
    CMD_BBS_REPORT_ONE_STATUS                   = 0x51E0,   -- 举报状态
    CMD_BBS_LIKE_ONE_STATUS                     = 0x51E2,   -- 点赞
    CMD_TRADING_SPOT_BBS_CATALOG_LIST           = 0x51C1,   -- 货站讨论区帖子列表


    CMD_CSML_LEAVE_ZHANCHANG                    = 0xD22C,   -- 离开战场

    CMD_SUMMER_2019_SSWG_PREPARE                = 0xB2A4,   -- 2019 暑假活动之谁是乌龟准备
    CMD_SUMMER_2019_SSWG_END_ACTION             = 0xB2A2,   -- 2019 暑假活动之谁是乌龟结束动画
    CMD_SUMMER_2019_SSWG_OPER                   = 0xB2A3,   -- 2019 暑假活动之谁是乌龟操作
    CMD_SUMMER_2019_SSWG_QUIT                   = 0xB2A5,   -- 2019 暑假活动之谁是乌龟退出
    CMD_SUMMER_2019_SSWG_CONTINUE               = 0xB2A6,   -- 2019 暑假活动之谁是乌龟继续

    CMD_SUMMER_2019_BHKY_RESULT               = 0xD232,   -- 2019 暑假活动之冰火考验游戏结果
    CMD_SUMMER_2019_BHKY_QUIT                 = 0xD230,   -- 2019 暑假活动之冰火考验退出游戏

    CMD_SUMMER_2019_SXDJ_OPERATE                = 0xB2AB,   -- 2019年暑假活动之生肖对决 玩家操作
    CMD_SUMMER_2019_SXDJ_END_ACTION             = 0xB2AE,   -- 2019年暑假活动之生肖对决 动作结束
    CMD_SUMMER_2019_SXDJ_QUIT                   = 0xB2B0,   -- 2019年暑假活动之生肖对决 退出

    -- 文曲星
    CMD_WQX_ANSWER_QUESTION                     = 0x51F1,   -- 文曲星 - 回答问题
    CMD_WQX_CLOSE_DLG                           = 0x51F2,   -- 文曲星 - 关闭界面
    CMD_WQX_FINISH_GAME                         = 0x51F3,   -- 文曲星 - 结束答题
    CMD_WQX_APPLY_ITEM                          = 0x51F4,   -- 文曲星 - 使用答题卡
    CMD_WQX_NEXT_STAGE                          = 0x51F5,   -- 文曲星 - 挑战下一关

    CMD_WQX_HELP_ANSWER_QUESTION                = 0x51F8,   -- 文曲星 - 帮助好友答题

    CMD_PET_EXPLORE_LEARN_SKILL                 = 0xB2B2,   -- 宠物探索小队 - 学习技能
    CMD_PET_EXPLORE_REPLACE_SKILL               = 0xB2B3,   -- 宠物探索小队 - 替换技能
    CMD_PET_EXPLORE_USE_ITEM                    = 0xB2B5,   -- 宠物探索小队 - 使用道具
    CMD_PET_EXPLORE_MAP_PET_DATA                = 0xB2BC,   -- 宠物探索小队 - 地图宠物数据
    CMD_PET_EXPLORE_MAP_CONDITION_DATA          = 0xB2BE,   -- 宠物探索小队 - 地图条件数据
    CMD_PET_EXPLORE_OPER                        = 0xB2B8,   -- 宠物探索小队 - 探索操作
    CMD_PET_EXPLORE_START                       = 0xB2B9,   -- 宠物探索小队 - 开始探索

    CMD_XCWQ_ADJUST_TEMPERATURE                 = 0xD234,   -- 客户端调整水温
    CMD_XCWQ_MASSAGE_BACK                       = 0xD236,   -- 客户端执行捶背
    CMD_XCWQ_THROW_SOAP                         = 0xD238,   -- 客户端执行丢肥皂
    CMD_XCWQ_USE_YLJH                           = 0xD23A,   -- 客户端使用玉露精华
    CMD_XCWQ_LEAVE                              = 0xD23C,   -- 客户端退出场景
    CMD_REENTRY_ASKTAO_RECHARGE_DATA         = 0x5E13,      -- 回归累充活动数据
    CMD_REENTRY_ASKTAO_RECHARGE_FETCH_BONUS  = 0x5E15,      -- 回归累充领取奖励
    CMD_LOG_CLIENT_ACTION                       = 0x5216,   -- 记录client_action_log


    CMD_DECOMPOSE_LINGCHEN_ITEM                 = 0xD240,      -- 分解道具
    CMD_BUY_LINGCHEN_ITEM                       = 0xD242,      -- 兑换道具
    CMD_OPEN_LINGCHEN_SHOP                      = 0xD244,      -- 客户端要求打开商店界面

    -- 小舟竞赛
    CMD_SUMMER_2019_XZJS_OPERATE                = 0xD248,      -- 客户端通知执行指令结果
    CMD_SUMMER_2019_XZJS_QUIT_GAME              = 0xD24A,      -- 客户端请求退出游戏

    CMD_SUMMER_2019_SXDJ_PREPARE                = 0xB2C2,      -- 2019 暑假活动之生肖对决准备
    CMD_WQX_FINISH_QUESTION                     = 0x51FA,       -- 文曲星 - 完成题目

    CMD_L_GET_GOLD_COIN_DATA                    = 0xB2C8,   -- 请求 AAA 通知玩家元宝数据
    CMD_L_GET_INSIDER_ACT                       = 0xB2C9,   -- 请求会员打折活动数据
    CMD_L_PRECHARGE_PRESS_BTN                   = 0x5219,   -- 记录预充值活动中，界面点击次数


    CMD_CHILD_REQUEST_INFO                      = 0xD24E,   -- 客户端请求娃娃界面信息
    CMD_CHILD_CARE                              = 0xD250,   -- 照料胎儿/灵石
    CMD_CHILD_BIRTH                             = 0xD252,   -- 接生/雕琢
    CMD_CHILD_RENAME                            = 0xD254,   -- 娃娃改名
    CMD_HOUSE_TDLS_INJECT_ENERGY                = 0xD256,   -- 使用对灵石注入能量

    CMD_CHILD_BIRTH_FINISH                      = 0xD258,   -- 客户端通知结束(为了表现效果由客户端通知结束，误差在一定范围内认为结束合法，只有倒计时满的情况由客户端通知)
    CMD_CHILD_BIRTH_WATER                       = 0xD25A,   -- 打水返回通知接生婆
    CMD_CHILD_BIRTH_ADD_LOG                     = 0xD25C,   -- 通知新的生产信息
    CMD_CHILD_BIRTH_ADD_PROGRESS                = 0xD25E,   -- 通知增加生产进度
    CMD_HOUSE_TDLS_CHILD_BIRTH                       = 0xD262,   -- 客户端请求进行灵胎出世
    CMD_CHILD_PUT_MONEY                          = 0xD260,   -- 存入娃娃金库

    CMD_CHILD_REQUEST_RAISE_INFO                = 0xD270,   -- 客户端请求抚养信息
    CMD_CHILD_RAISE                             = 0xD264,   -- 客户端对娃娃进行抚养
    CMD_CHILD_SET_SCHEDULE_LIST                 = 0xD266,   -- 客户端对娃娃设置行程
    CMD_CHILD_REQUEST_SCHEDULE                  = 0xD268,   -- 客户端请求历史行程
    CMD_HOUSE_CRADLE_TALK                       = 0xD26A,   -- 客户端点击摇篮
    CMD_CHILD_CHECK_SET_SCHEDULE                = 0xD26C,   -- 检查单个行程是否合法
    CMD_CHILD_CHECK_CHANGE_SCHEDULE             = 0xD26E,   -- 检测能否修改行程
    CMD_STOP_COMMON_PROGRESS                    = 0xD272,   -- 客户端通知进度条播放完毕

    CMD_CHILD_SELECT                            = 0xD274,   -- 客户端通知选中娃娃

    CMD_GOOD_VOICE_SHOW_LIST                    = 0x5220,   -- 查看声音列表
    CMD_GOOD_VOICE_QUERY_VOICE                  = 0x5222,   -- 查看声音详情
    CMD_GOOD_VOICE_COLLECT                      = 0x5224,   -- 收藏声音
    CMD_GOOD_VOICE_SEARCH                       = 0x5226,   -- 搜索声音
    CMD_GOOD_VOICE_REPORT                       = 0x5227,   -- 举报声音
    CMD_GOOD_VOICE_UPLOAD                       = 0x5228,   -- 上传声音
    CMD_GOOD_VOICE_CANCEL                       = 0x522A,   -- 撤回声音
    CMD_GOOD_VOICE_OPEN_DLG                     = 0x522B,   -- 打开主界面
    CMD_GOOD_VOICE_LIKE                         = 0x522D,   -- 点赞
    CMD_GOOD_VOICE_GIVE_FLOWER                  = 0x522E,   -- 送花
    CMD_GOOD_VOICE_ADD_JUDGE                    = 0x522F,   -- 增加评委
    CMD_GOOD_VOICE_JUDGES                       = 0x5230,   -- 评委列表
    CMD_GOOD_VOICE_FINAL_VOICES                 = 0x5232,   -- 查看终选的声音
    CMD_GOOD_VOICE_JUDGE_GIVE_SCORE             = 0x5234,   -- 评委打分
    CMD_GOOD_VOICE_SCORE_DATA                   = 0x5235,   -- 查看声音评分(包含本届和历届的)
    CMD_GOOD_VOICE_RANK_LIST                    = 0x5237,   -- 查看排行榜
    CMD_ADMIN_GOOD_VOICE_DELETE_JUDGE           = 0x523A,   -- GM删除好声音评委
    CMD_ADMIN_GOOD_VOICE_DELETE_SCORE           = 0x523B,   -- GM删除好声音评委
    CMD_LEAVE_MESSAGE_VIEW                      = 0x523D,   --
    CMD_LEAVE_MESSAGE_WRITE                     = 0x523F,
    CMD_LEAVE_MESSAGE_DELETE                    = 0x5241,
    CMD_LEAVE_MESSAGE_LIKE                      = 0x5242,
    CMD_LEAVE_MESSAGE_REPORT                    = 0x5244,   -- 举报留言

    CMD_SUMMER_2019_SSWG_CANCEL_TRUSTEESHIP     = 0xB2CB,   -- 取消托管

    CMD_QIXI_2019_LMQG_SELECT                   = 0xD278,   -- 客户端选择材料
    CMD_QIXI_2019_LMQG_QUIT                     = 0xD27A,   -- 客户端主动退出

    CMD_CHILD_JOIN_FAMILY                     = 0xD27E,   -- 娃娃-请求拜师
    CMD_CHILD_HOUSEWORK                       = 0xD280,   -- 娃娃-请求做家务
    CMD_CHILD_SUPPLY_ENERGY                   = 0xD282,   -- 娃娃-请求补充体力
    CMD_HOUSE_TDLS_VIEW                        = 0xD284,    -- 客户端查看状态
    CMD_NEW_DIST_CHONG_BANG_DATA                = 0x5217,   -- 请求新服盛典数据
    CMD_ADMIN_GOOD_VOICE_DELETE_VOICE           = 0x5246,   --  GM删除好声音音频
    CMD_L_PRECHARGE_CHARGE                      = 0xB2CC,   -- 预充值活动期间使用的充值
    CMD_START_XS_AUTO_WALK                      = 0xD2A0,   -- 客户端请求进行悬赏寻路

    CMD_CHOOSE_FASION                           = 0xB2D1,   -- 选择时装的编号

    CMD_VOICE_STAT                              = 0x8262,   -- 语音统计
    CMD_TRADING_SPOT_GOODS_VOLUME               = 0x51C7,   -- 全服买入总额
    CMD_TRADING_SPOT_LARGE_ORDER_DATA           = 0x51C9,   -- 大额买单数据
    CMD_CHILD_FOLLOW_ME                        = 0x824E,    -- 让娃娃跟随我
    CMD_CHILD_VISIBLE                          = 0x8250,    -- 娃娃是否可见
    CMD_CHILD_PRE_ASSIGN_ATTRIB                = 0x8252,    -- 准备分配属性比例
    CMD_CHILD_SURE_ASSIGN_ATTRIB               = 0x8254,    -- 确认分配属性比例
    CMD_CHILD_FETCH_TASK                        = 0xD286,   -- 领取娃娃日常任务
    CMD_CHILD_QUIT_GAME                         = 0xD28E,   -- 客户端通知退出游戏

    CMD_CHILD_SYNC_GAME_DATA                    = 0xD28C,   -- 客户端同步游戏数据
    CMD_CHILD_FINISH_GAME                       = 0xD28A,   -- 客户端通知结束游戏
    CMD_CHILD_CLICK_TASK_LOG                    = 0xD288,   -- 点击娃娃任务当前提示
    CMD_HOUSE_TDLS_MENU                         = 0xD29C,   -- 客户端获取灵石菜单
    CMD_SUBMIT_CHILD_UPGRADE_ITEM               = 0x5250,   -- 提交娃娃飞升物品

    CMD_CHILD_SUPPLY_TOY_DURABILITY             = 0xD290,   -- 补充玩具耐久
    CMD_CHILD_DROP_TOY                          = 0xD292,   -- 丢弃玩具
    CMD_CHILD_EQUIP_TOY                         = 0xD294,   -- 穿戴玩具
    CMD_CHILD_PRACTICE                          = 0xD296,   -- 修炼资质
    CMD_MERGE_CHILD_TOY                         = 0xD298,   -- 玩具合成
    CMD_CHILD_REQUEST_CULTIVATE_INFO            = 0xD29A,   -- 请求修炼界面数据
    CMD_QUERY_CHILD_CARD                        = 0xD2A2,   -- 客户端请求娃娃信息        
}

local Msg = {
    [0x1366] = "MSG_CLIENT_CONNECTED",
    [0xB036] = "MSG_AAA_CONNECTED",
    [0x1368] = "MSG_CLIENT_DISCONNECTED",
    [0x10B2] = "CMD_ECHO",
    [0x10B3] = "MSG_REPLY_ECHO",
    [0x1B06] = "MSG_L_ANTIBOT_QUESTION",
    [0x2B04] = "MSG_L_CHECK_USER_DATA",
    [0x5351] = "MSG_L_AUTH",
    [0x4355] = "MSG_L_SERVER_LIST",
    [0x3357] = "MSG_L_AGENT_RESULT",
    [0xF00D] = "MSG_ANSWER_FIELDS",
    [0xF061] = "MSG_EXISTED_CHAR_LIST",
    [0x10E1] = "MSG_ENTER_GAME",
    [0x2037] = "MSG_MENU_LIST",
    [0x2FFF] = "MSG_MESSAGE",
    [0x3FFF] = "MSG_MESSAGE_EX",
    [0xA116] = "MSG_CHANNEL_TIP",     -- 发送聊天频道的提示信息
    [0xF0E7] = "MSG_TITLE",
    [0xF0DB] = "MSG_RELOCATE",
    [0x103B] = "MSG_MENU_CLOSED",
    [0xFFE7] = "MSG_UPDATE_IMPROVEMENT",
    [0xFFF5] = "MSG_INVENTORY",
    [0x7FEB] = "MSG_UPDATE_SKILLS",
    [0xFFF7] = "MSG_UPDATE",
    [0xF0DD] = "MSG_UPDATE_APPEARANCE",
    [0xFFE1] = "MSG_ENTER_ROOM",
    [0x1FE5] = "MSG_DIALOG_OK",
    [0x402F] = "MSG_MOVED",
    [0xFFF9] = "MSG_APPEAR",
    [0x2FFD] = "MSG_DISAPPEAR",
    [0x2EFB] = "MSG_GODBOOK_EFFECT_SUMMON",
    [0x2EF9] = "MSG_GODBOOK_EFFECT_NORMAL",
    [0xFFFB] = "MSG_EXITS",
    [0xFFE3] = 'MSG_UPDATE_PETS',
    [0x1065] = 'MSG_SET_VISIBLE_PET',
    [0x1043] = 'MSG_SET_CURRENT_PET',
    [0x2FED] = 'MSG_SET_OWNER',
    [0x2EF0] = 'MSG_GUARDS_REFRESH',
    [0x20E9] = 'MSG_SET_CURRENT_MOUNT',
    [0xF301] = 'MSG_APPELLATION_LIST',
    [0xF071] = 'MSG_TASK_PROMPT',
    [0x1017] = 'MSG_UPDATE_TEAM_LIST',
    [0x1019] = 'MSG_UPDATE_TEAM_LIST_EX',
    [0x4FF3] = 'MSG_DIALOG',
    [0xF097] = 'MSG_CLEAN_REQUEST',
    [0x3FBD] = 'MSG_SERVICE_LOG',
    [0xFD0A] = 'MSG_TELEPORT_EX',
    [0xF0D5] = 'MSG_TOP_USER',
    [0x3801] = 'MSG_PRE_ASSIGN_ATTRIB',
	[0x402D] = 'MSG_TEAM_MOVED',
    [0x2295] = 'MSG_SEND_RECOMMEND_ATTRIB',
    [0x2EF7] = 'MSG_REFRESH_PET_GODBOOK_SKILLS',
    [0x2039] = 'MSG_FINISH_SORT_PACK',
    -- Part 1-combat (responding)
    [0x0203] = "MSG_C_ACCEPTED_COMMAND",
    [0x2207] = "MSG_C_FLEE",
    [0x3209] = "MSG_C_CATCH_PET",
    -- Part 2-combat (push)
    [0x0DFF] = "MSG_C_START_COMBAT",
    [0x0DFD] = "MSG_C_END_COMBAT",
    [0xFDFB] = "MSG_C_FRIENDS",
    [0xFDF9] = "MSG_C_OPPONENTS",
    [0x2DD1] = "MSG_C_DIRECT_OPPONENT_INFO",
    [0x4DF7] = "MSG_C_ACTION",
    [0x1DF5] = "MSG_C_CHAR_DIED",
    [0x1DF3] = "MSG_C_CHAR_REVIVE",
    [0x3DF1] = "MSG_C_LIFE_DELTA",
    [0x3DEF] = "MSG_C_MANA_DELTA",
    [0x2DED] = "MSG_C_UPDATE_STATUS",
    [0x1DEB] = "MSG_C_WAIT_COMMAND",
    [0x4DE9] = "MSG_C_ACCEPT_HIT",
    [0x1DE7] = "MSG_C_END_ACTION",
    [0x1DE5] = "MSG_C_QUIT_COMBAT",
    [0xFDE3] = "MSG_C_ADD_FRIEND",
    [0xFDE1] = "MSG_C_ADD_OPPONENT",
    [0xFDDF] = "MSG_C_UPDATE_IMPROVEMENT",
    [0xF0FF] = "MSG_C_UPDATE_APPEARANCE",
    [0xFDDD] = "MSG_C_ACCEPT_MAGIC_HIT",
    [0x1DDB] = "MSG_C_LEAVE_AT_ONCE",
    [0x3DD9] = "MSG_C_MESSAGE",
    [0x1DD7] = "MSG_C_DIALOG_OK",
    [0xFDD5] = "MSG_C_UPDATE",
    [0x2DD3] = "MSG_C_COMMAND_ACCEPTED",
    [0xFDD1] = "MSG_SYNC_MESSAGE",
    [0x3DCF] = "MSG_C_MENU_LIST",
    [0x2DCD] = "MSG_C_MENU_SELECTED",
    [0xFDCB] = "MSG_C_REFRESH_PET_LIST",
    [0x2DC9] = "MSG_C_DELAY",
    [0x2DC7] = "MSG_C_LIGHT_EFFECT",
    [0x0DC5] = "MSG_C_WAIT_ALL_END",
    [0x2DC3] = "MSG_C_START_SEQUENCE",
    [0x2DC1] = "MSG_C_SANDGLASS",
    [0x2DBF] = "MSG_C_CHAR_OFFLINE",
    [0x4DEB] = "MSG_C_ACCEPT_MULTI_HIT",
    [0xFDBD] = "MSG_C_OPPONENT_INFO",
    [0xFDBB] = "MSG_C_BATTLE_ARRAY",
    [0xFDB1] = "MSG_C_SET_FIGHT_PET",
    [0xFDB3] = "MSG_C_SET_CUSTOM_MSG",
    [0xFDB4] = "MSG_NULL",
    [0xF0D9] = "MSG_PICTURE_DIALOG",
    [0x2EFC] = "MSG_ATTACH_SKILL_LIGHT_EFFECT",
    [0x23A9] = "MSG_GENERAL_NOTIFY",
    [0xFFDF] = "MSG_GOODS_LIST",
    [0xFFF1] = "MSG_ITEM_APPEAR",
    [0x20E5] = "MSG_ITEM_DISAPPEAR",
    [0xA043] = "MSG_C_UPDATE_COMBAT_INFO",
    [0xD14B] = "MSG_C_CREATE_SEQUENCE",
    [0xD14D] = "MSG_LC_CREATE_SEQUENCE",
    [0xD09F] = "MSG_MORPH_SUCCESS",
    -- from 0x8000
    [0x8003] = "MSG_SEND_RECOMMEND_POLAR",
    [0x8007] = "MSG_PRE_UPGRADE_EQUIP",
    [0x8005] = "MSG_UPGRADE_EQUIP_COST",
    [0x8009] = "MSG_IDENTIFY_INFO",
    [0x8017] = "MSG_REFRESH_PARTY_SHOP",

    -- 帮派邀请相关
    [0xD08F] = "MSG_PARTY_INVITE",
    [0xA059] = "MSG_PARTY_INVITE_CLEAN",

    -- from 0x9000
    [0x9001] = "MSG_GUARD_UPDATE_EQUIP",
    [0x9003] = "MSG_GUARD_UPDATE_GROW_ATTRIB",
    [0x9005] = "MSG_RECOMMEND_FRIEND",
    [0x9007] = "MSG_CHAR_INFO",
    [0x9017] = "MSG_PET_CARD",

    -- from 0xA000
    [0xA001] = "MSG_MAILBOX_REFRESH",
    -- from 0xB000
    [0xB000] = "MSG_PLAY_SCENARIOD",

    -- 帮派相关
    [0xF0A1] = "MSG_PARTY_INFO",
    [0xF0A3] = "MSG_PARTY_MEMBERS",
    [0xF0A5] = "MSG_PARTY_QUERY_MEMBER",
    [0x0FB7] = "MSG_REQUEST_ECARD_INFO",
    [0xF0B3] = "MSG_PARTY_LIST",
    [0xA011] = "MSG_PARTY_LIST_EX",
    [0x2E39] = "MSG_PARTY_CHANNEL_DENY_LIST",
    [0x2333] = "MSG_SEND_PARTY_LOG",
    [0xA013] = "MSG_PARTY_BRIEF_INFO",
    [0xA0AE] = "MSG_PARTY_ZHIDUOXING_SKILL", -- 帮派智多星 - 技能信息
    [0xA0B0] = "MSG_PARTY_ZHIDUOXING_INFO",  -- 帮派智多星 - 基本信息
    [0xA600] = "MSG_PARTY_ZHIDUOXING_QUESTION",  -- 帮派智多星 - 基本信息

    [0xD12B] = "MSG_PARTY_PYJS_SETUP",      -- 培育巨兽活动开启信息
    [0xD127] = "MSG_PARTY_PYJS_ATTRIBS",    -- 选择的培育巨兽属性数据
    [0xD129] = "MSG_PARTY_PYJS_STAGE_DATA", -- 培育巨兽数据
    [0xD119] = "MSG_PARTY_YQCS_RESULT",     -- 运气测试结果
    [0xD11D] = "MSG_PARTY_YZXL_POKE",       -- 益智训练（戳泡泡）结果
    [0xD11F] = "MSG_PARTY_YZXL_QUIT",       -- 暂停/退出
    [0xD121] = "MSG_PARTY_YZXL_REMOVE",     -- 泡泡移除的结果
    [0xD123] = "MSG_PARTY_YZXL_START",      -- 开始戳泡泡游戏
    [0xD125] = "MSG_PARTY_YZXL_END",        -- 游戏结束

    -- 变异商店
    [0xD001] = "MSG_OPEN_ELITE_PET_SHOP",
    -- 获得物品动画
    [0xA004] = "MSG_ICON_CARTOON",

    -- 重置快速使用物品勿扰模式
    [0xD0E1] = "MSG_RESET_FAST_USE_ITEM",

    -- 副本相关
    [0xB002] = "MSG_DUNGEON_LIST",
    [0xB003] = "MSG_DUNGEON_GET_BONUS",
    [0xB047] = "MSG_BROACAST_TEAM_ASK_STATE",

    -- 通天塔
    [0xC003] = "MSG_TONGTIANTA_INFO",
    [0xC005] = "MSG_TONGTIANTA_BONUS_DLG",
    [0xB022] = "MSG_TONGTIANTA_JUMP",
    [0xB023] = "MSG_TONGTIANTA_JUMP_CANCEL",
    [0xB025] = "MSG_OPEN_FEISHENG_DLG",

    -- 刷道
    [0xB004] = "MSG_SHUADAO_REFRESH",
    [0xB005] = "MSG_SHUADAO_REFRESH_BONUS",
    [0xB006] = "MSG_SHUADAO_REFRESH_BUY_TIME",
    [0xB0A3] = "MSG_SHUADAO_USEPOINT_STATUS",
    [0xB0B7] = "MSG_REFRESH_SHUAD_TRUSTEESHIP",
    [0xB0A1] = "MSG_SHUADAO_SCORE_ITEMS",
    [0xB0B9] = "MSG_SHUADAO_TRUSTEESHIP_INFO",

    [0x3065] = "MSG_FRIEND_GROUP_OPERATION",
    [0xF067] = "MSG_FRIEND_UPDATE_LISTS",
    [0xF069] = "MSG_FRIEND_ADD_CHAR",
    [0x306B] = "MSG_FRIEND_REMOVE_CHAR",
    [0x206D] = "MSG_FRIEND_NOTIFICATION",
    [0x5FB9] = "MSG_FRIEND_UPDATE_PARTIAL",
    [0xF073] = "MSG_FINGER",

    -- 在线商城
    [0xFFDB] = "MSG_ONLINE_MALL_LIST",

    -- 购买游戏币
    [0xD013] = "MSG_ONLINE_MALL_CASH_LIST",

    -- 扫荡
    [0x9009] = "MSG_AUTO_PRACTICE_BONUS",

    -- 竞技场
    [0x900B] =  "MSG_ARENA_INFO",
    [0x900D] = "MSG_ARENA_OPPONENT_LIST",
    [0x900F] = "MSG_ARENA_TOP_BONUS_LIST",
    [0x9011] = "MSG_ARENA_SHOP_ITEM_LIST",
    [0x9015] = "MSG_CHALLENGE_MSG",

    -- 活动
    [0x9013] = "MSG_LIVENESS_INFO",
    [0xB007] = "MSG_AUTO_WALK",
    [0xD0E3] = "MSG_LIVENESS_INFO_EX",

    -- 查看装备
    [0xC001] = "MSG_LOOK_PLAYER_EQUIP",

    -- 名片产看
    [0xA002] = "MSG_CARD_INFO",

    -- 更新服务器时间
    [0xA031] = "MSG_REPLY_SERVER_TIME",

    -- 打开天星石购买界面
    [0xA035] = "MSG_OPEN_TIANXS_DIALOG",

    -- 再续前缘，奖品
    [0xA03B] = "MSG_REENTRY_ASKTAO_RESULT",

    -- 再续前缘 回归积分商城
    [0x5042] = "MSG_COMEBACK_SCORE_SHOP_ITEM_LIST",
    -- 召回积分商城
    [0x5043] = "MSG_RECALL_SCORE_SHOP_ITEM_LIST",
    -- 历史召回玩家信息
    [0x5048] = "MSG_RECALLED_USER_DATA_LIST",

    -- 活跃度，奖品
    [0xA045] = "MSG_LIVENESS_LOTTERY_RESULT",
    [0xA200] = "MSG_LIVENESS_REWARDS",
    [0xA04B] = "MSG_FESTIVAL_LOTTERY_RESULT",

    -- 帮战信息
    [0xD003] = "MSG_PARTY_WAR_BID_INFO",
    [0xF101] = "MSG_PARTY_WAR_INFO",
    [0xD005] = "MSG_PARTY_WAR_SCORE",

    -- 新手礼包
    [0xC013] = "MSG_NEWBIE_GIFT",

    -- 每日签到
    [0xC011] = "MSG_DAILY_SIGN",

    -- 神秘大礼
    [0xC00D] = "MSG_AWARD_OPEN",
    [0xC009] = "MSG_AWARD_INFO_EX",     -- 欲抽奖
    [0xC00B] = "MSG_FINISH_AWARD",      -- 抽奖结束
    [0xC007] = "MSG_OPEN_WELFARE",      -- 福利
    [0xA05B] = "MSG_FESTIVAL_LOTTERY",  -- 抽奖活动
    [0xA05D] = "MSG_WINTER_LOTTERY_MSG", -- 寒假抽奖信息
    [0xA05F] = "MSG_SPRING_LOTTERY_MSG", -- 春节红包提示信息
    [0xD0B7] = "MSG_OPEN_SSNYF",  -- 服务器通知客户端打开年夜饭界面
    [0xD0C7] = "MSG_RECHARGE_SCORE_GOODS_LIST", -- 通知充值积分活动信息
    [0xD0C9] = "MSG_RECHARGE_SCORE_GOODS_INFO", -- 通知充值积分单个商品信息

    [0xA092] = "MSG_MONTH_CHARGE_GIFT", -- 月首充信息

    -- 试道大会
    [0xC019] = "MSG_SHIDAO_TASK_INFO",
    [0xC017] = "MSG_SHIDAO_GLORY_HISTORY",

    [0xA005] = "MSG_PLAY_INSTRUCTION",

    -- 集市相关消息
    [0xC01B] = "MSG_STALL_MINE",
    [0xC01D] = "MSG_REFRESH_STALL_ITEM",
    [0xC01F] = "MSG_STALL_ITEM_LIST",
    [0xC021] = "MSG_STALL_RECORD",
    [0xC023] = "MSG_STALL_SERACH_ITEM_LIST",
    [0x8117] = "MSG_STALL_RUSH_BUY_OPEN",
    [0x811B] = "MSG_GOLD_STALL_RUSH_BUY_OPEN",
    [0x8119] = "MSG_STALL_BUY_RESULT",
    [0x811D] = "MSG_GOLD_STALL_BUY_RESULT",

    -- 播放光效
    [0x2FD3] = "MSG_PLAY_LIGHT_EFFECT",

    -- 停止播放特效
    [0xA009] = "MSG_STOP_LIGHT_EFFECT",

    -- 自动组队
    [0xC025] = "MSG_MATCH_TEAM_STATE",
    [0xC027] = "MSG_MATCH_TEAM_LIST",
    [0xB013] = "MSG_MATCH_SIZE",

    -- 帮派攻城战
    [0xD007] = "MSG_CITY_WAR_SCORE",
    [0x10E3] = "MSG_LEVEL_UP",
    [0x5052] = "MSG_UPGRADE_LEVEL_UP", --  元婴血婴升级

    -- 消息字段
    [0x1013] = "MSG_NOTIFICATION",

    -- vip界面信息
    [0xD009] = "MSG_INSIDER_INFO",

    -- 系统设置
    [0xF095] = "MSG_SET_SETTING",

    -- 选择菜单项,仅组队状态下使用
    [0xB008] = "MSG_MENU_SELECT",

    [0xB009] = "MSG_FIND_CHAR_MENU_FAIL",

    [0xB010] = "MSG_RANDOM_NAME",

    [0xB012] = "MSG_LEADER_COMBAT_GUARD",

    -- 天技商店
    [0xA007] = "MSG_OPEN_EXCHANGE_SHOP",
    -- 重连时通过如下消息发送之前设置的战斗指令
    [0x9019] = "MSG_FIGHT_CMD_INFO",

    [0xB016] = "MSG_GUARD_CARD",

    [0xB017] = "MSG_EQUIP_CARD",

    -- 超级大BOSS
    [0xA057] = "MSG_SUPER_BOSS_KILL_FIRST",

    -- 当前战斗状态
    [0xA008] = "MSG_COMBAT_STATUS_INFO",

    [0xB015] = "MSG_RANK_CLIENT_INFO",

    [0xB019] = "MSG_OPEN_AUTO_MATCH_TEAM",

    [0xB018] = "MSG_SUBMIT_PET",

    [0xB021] = "MSG_GUARD_EXPERIENCE_ID",

    [0xB020] = "MSG_GUARD_EXPERIENCE_SUCC",

    [0xB024] = "MSG_CHECK_DOUBLE_POINT",
    [0xB026] = "MSG_START_CHALLENGE",

    [0xA00B] = "MSG_GIFT_EQUIP_LIST",

    -- 集市
    [0xB030] = "MSG_MARKET_GOOD_CARD",
    [0xB031] = "MSG_MARKET_PET_CARD",
    [0xB029] = "MSG_MARKET_SEARCH_RESULT",

    -- 仓库
    [0xF0ED] = "MSG_STORE",

    -- 集市收藏检查
    [0xB032] = "MSG_MARKET_CHECK_RESULT",
    [0xB037] = "MSG_TEAM_ASK_ASSURE",
    [0xB038] = "MSG_TEAM_ASK_CANCEL",

    [0xB035] = "MSG_L_ACCOUNT_CHARS",
    [0xB040] = "MSG_ASK_CLIENT_SECRET",

    [0xB044] = "MSG_MEMBER_QUIT_TEAM",
    [0xB045] = "MSG_CREATE_PARTY_SUCC",
    [0xB041] = "MSG_CHAR_ALREADY_LOGIN",
    [0xB046] = "MSG_ACCOUNT_IN_OTHER_SERVER",
    [0x8021] = "MSG_STALL_UPDATE_GOODS_INFO", -- 更新搜索购买时的物品状态

    -- gs列表
    [0xF0DF] = "MSG_REQUEST_SERVER_STATUS",
    [0x20D5] = "MSG_SWITCH_SERVER",
    [0x20D6] = "MSG_SWITCH_SERVER_EX",

    [0xB048] = "MSG_BASIC_GUARD_ATTRI",

    [0xB049] = "MSG_GET_NEXT_RANK_GUARD",  -- 发送下一等级守护数据

    [0xB054] = "MSG_OTHER_LOGIN",
    [0xB055] = "MSG_C_CUR_ROUND",

    [0xB056] = "MSG_OPER_RENAME", -- 改名成功断开消息

    [0xB059] = "MSG_CHARGE_INFO",

    [0xD091] = "MSG_MY_RANK_INFO",

    -- 登录排队
    [0xB057] = "MSG_L_WAIT_IN_LINE",


    [0xD117] = "MSG_NEW_PW_COMBAT_INFO",
    [0xF103] = "MSG_PW_BATTLE_INFO",
    [0xF105] = "MSG_TEAM_DATA",

	-- Lookon combat message
	[0x09FF] = "MSG_LC_START_LOOKON",
    [0x09FD] = "MSG_LC_END_LOOKON",
	[0xF9FB] = "MSG_LC_FRIENDS",
	[0xF9F9] = "MSG_LC_OPPONENTS",
	[0x49F7] = "MSG_LC_ACTION",
	[0x29F5] = "MSG_LC_CHAR_DIED",
	[0x19F3] = "MSG_LC_CHAR_REVIVE",
	[0x39F1] = "MSG_LC_LIFE_DELTA",
	[0x39EF] = "MSG_LC_MANA_DELTA",
	[0x29ED] = "MSG_LC_UPDATE_STATUS",
	[0x19EB] = "MSG_LC_WAIT_COMMAND",
	[0x39E9] = "MSG_LC_ACCEPT_HIT",
	[0x19E7] = "MSG_LC_END_ACTION",
	[0x29E5] = "MSG_LC_FLEE",
	[0x39E3] = "MSG_LC_CATCH_PET",
	[0xF9E1] = "MSG_LC_INIT_STATUS",
	[0x19DF] = "MSG_LC_QUIT_COMBAT",
	[0xF9DD] = "MSG_LC_UPDATE_IMPROVEMENT",
	[0xF9DB] = "MSG_LC_ACCEPT_MAGIC_HIT",
	[0x19D9] = "MSG_LC_LEAVE_AT_ONCE",
	[0xF9D7] = "MSG_LC_ADD_FRIEND",
	[0xF9D5] = "MSG_LC_ADD_OPPONENT",
	[0xF9D3] = "MSG_LC_UPDATE",
	[0x39D1] = "MSG_LC_MENU_LIST",
	[0x2DCF] = "MSG_LC_MENU_SELECTED",
	[0x29CD] = "MSG_LC_DELAY",
	[0x29CB] = "MSG_LC_LIGHT_EFFECT",
	[0x09C9] = "MSG_LC_WAIT_ALL_END",
	[0x29C7] = "MSG_LC_SANDGLASS",
	[0x2DC5] = "MSG_LC_CHAR_OFFLINE",
	[0x29C3] = "MSG_LC_START_SEQUENCE",
    [0x29C4] = "MSG_LC_CUR_ROUND",
    [0x29C5] = "MSG_LC_LOOKON_NUM",

    [0xB05B] = "MSG_ADD_TASK_ROUND",

    [0xD00B] = "MSG_LOTTERY_INFO",

    -- 八仙信息
    [0x8023] = "MSG_BAXIAN_MENGJING_INFO",	-- 掌门信息
    [0xF0AD] = "MSG_MASTER_INFO",
    [0xB05F] = "MSG_SPECIAL_SWITCH_SERVER",
    [0xA00D] = "MSG_RECHARGE_GIFT",

    [0xB0EA] = "MSG_SPECIAL_SWITCH_SERVER_EX",  -- 跨服换线

    [0x8027] = "MSG_SYS_AUCTION_UPDATE_GOODS",  -- 更新单个商品数据
    [0X8025] = "MSG_SYS_AUCTION_GOODS_LIST",    -- 拍卖数据

    [0xFA2B] = "MSG_ADMIN_QUERY_ACCOUNT",       -- GM查询账号结果
    [0xFA07] = "MSG_ADMIN_QUERY_PLAYER",       -- GM查询角色结果
    [0xD073] = "MSG_ADMIN_QUERY_NPC",           -- GM查询NPC结果
    [0xD079] = "MSG_PROCESS_LIST",              -- GM查询进程列表

    [0xD0CE] = "MSG_AMDIN_NEW_PET",             -- GM生成新宠物

    -- 龙争虎斗
    [0xB0BC] = "MSG_LH_GUESS_RACE_INFO",    -- 返回显示的安排时间
    [0xB0BE] = "MSG_LH_GUESS_PLANS",        -- 返回对阵信息
    [0xB0C0] = "MSG_LH_GUESS_TEAM_INFO",    -- 返回队伍信息
    [0xB0C2] = "MSG_LH_GUESS_CAMP_SCORE",   -- 返回阵营的积分信息
    [0xB0C4] = "MSG_LH_GUESS_INFO",         -- 有奖竞猜信息
    [0xB0C7] = "MSG_LONGHU_INFO",           -- 龙虎比赛的信息
    [0x8053] = "MSG_TRADING_ROLE",  -- 通知客户端玩家的寄售信息
    [0x805B] = "MSG_TRADING_SNAPSHOT", -- 通知客户端商品的快照信息
    [0x805D] = "MSG_TRADING_SNAPSHOT_ME", -- 通知客户端自身商品快照信息
    [0x8057] = "MSG_TRADING_ENABLE",        -- 通知客户端聚宝斋是否可用

    [0x8063] = "MSG_TRADING_FAVORITE_LIST",         -- 通知聚宝斋收藏列表
    [0x8065] = "MSG_TRADING_GOODS_LIST",            -- 通知聚宝斋商品列表
    [0x8067] = "MSG_TRADING_FAVORITE_GIDS",         -- 通知客户端收藏的商品 gid
    [0x8070] = "MSG_TRADING_GOODS_UPDATE",          -- 通知客户端某商品信息，聚宝

    [0x8055] = "MSG_OPEN_URL",

    [0xA00F] = "MSG_LOGIN_GIFT",    -- 登入礼包
    [0xD00D] = "MSG_BUYBACK_LIST",  -- 服务器通知回购物品列表
    [0xD00F] = "MSG_BUYBACK_ITEM_CARD", -- 服务器通知回购物品名片信息
    [0xD011] = "MSG_BUYBACK_PET_CARD", -- 服务器通知回购宠物名片信息
    [0xB060] = "MSG_OPEN_SHIDWZDLG", -- 打开试道王者界面

    [0xD011] = "MSG_BUYBACK_PET_CARD", -- 服务器通知回购宠物名片信息

    [0x1003] = "MSG_LOGIN_DONE",

    -- 开始采集
    [0xA015] = "MSG_START_GATHER",
    [0xA017] = "MSG_GATHER",
    [0xA019] = "MSG_FLOAT_DIALOG",

    -- 手机绑定
    [0x8033] = "MSG_PHONE_VERIFY_CODE",  --返回请求手机验证码成功
    [0x5032] = "MSG_OPEN_SMS_VERIFY_DLG", -- 打开手机验证窗口
    -- 老君查岗
    [0xD03D] = "MSG_NOTIFY_SECURITY_CODE",  --通知客户端回答验证码
    [0xD03F] = "MSG_FINISH_SECURITY_CODE",  -- 通知客户端验证码回答结束
    [0xA019] = "MSG_FLOAT_DIALOG",

    -- 宠物洗天技
    [0xA01B] = "MSG_PREVIEW_SPECIAL_SKILL",

    -- 创建角色
    [0x205D] = "MSG_CREATE_NEW_CHAR",

    -- 节日活动时间列表
    [0x8039] = "MSG_ACTIVITY_LIST",

    -- 玩家活动数据
    [0x5200] = "MSG_ACTIVITY_DATA_LIST",

    -- 通知玩家不在帮派内
    [0xB063] = "MSG_MEMBER_NOT_IN_PARTY",

    -- 恢复是否愿意接受变身
    [0xD045] = "MSG_REQUEST_CHANGE_LOOK",

    -- 变身卡相关消息
    [0x802B] = "MSG_CL_CARD_INFO",

    [0xB061] = "MSG_BE_ADD_FRIEND",
    [0x8029] = "MSG_ITEM_APPLY_FAIL",

    [0xB07E] = "MSG_COUPLE_INFO",

    -- 珍宝交易系统
    [0x8101] = "MSG_GOLD_STALL_MINE",       -- 通知自己的金元宝交易数据
    [0x8103] = "MSG_GOLD_STALL_GOODS_LIST", -- 通知金元宝交易逛摊数据
    [0x8105] = "MSG_GOLD_STALL_UPDATE_GOODS_INFO",      -- 通知更新单个商品数据
    [0x810C] = "MSG_GOLD_STALL_RECORD",    -- 金元宝交易通知交易记录
    [0x810F] = "MSG_GOLD_STALL_GOODS_STATE", -- 金元宝交易通知商品状态
    [0x8111] = "MSG_GOLD_STALL_SEARCH_GOODS", -- 金元宝交易通知搜索结果
    [0x8113] = "MSG_GOLD_STALL_GOODS_INFO_PET", -- 金元宝交易请求宠物名片
    [0x8115] = "MSG_GOLD_STALL_GOODS_INFO_ITEM",  -- 金元宝交易请求道具名片
    [0xB062] = "MSG_SPECIAL_SERVER",
    [0xA01D] = "MSG_REBUILD_PET_RESULT",
    [0x8072] = "MSG_TRADING_RECORD",            -- 聚宝交易记录

    -- 师徒系统相关====BEGIN
    [0xD059] = "MSG_SEARCH_MASTER_INFO",        -- 寻师信息
    [0xD05B] = "MSG_SEARCH_APPRENTICE_INFO",    -- 寻徒信息
    [0xD05D] = "MSG_REQUEST_APPENTICE_INFO",    -- 申请信息
    [0xD05F] = "MSG_MY_APPENTICE_INFO",         -- 我的师徒信息
    [0xD065] = "MSG_REQUEST_APPRENTICE_SUCCESS",-- 申请成功
    [0xD063] = "MSG_MY_SEARCH_APPRENTICE_MESSAGE",-- 我的寻徒留言
    [0xD061] = "MSG_MY_SEARCH_MASTER_MESSAGE",-- 我的寻师留言
    [0xD067] = "MSG_MY_MASTER_MESSAGE",         -- 我的师父留言
    [0xD069] = "MSG_NOTIFY_RECORD_APPRENTICE",         -- 我的师父留言
    [0xD06D] = "MSG_CDSY_TODAY_TASK",         -- 今日随机任务
    [0xD111] = "MSG_NOTIFY_CHUSHI_LEVEL",       -- 通知客户端当前服务器最大出师等级

    -- 师徒系统相关====END

    -- 安全锁相关
    [0x803B] = "MSG_SAFE_LOCK_INFO",                -- 通知客户端当前安全锁信息
    [0x803D] = "MSG_SAFE_LOCK_OPEN_SET",            -- 通知打开设置密码界面
    [0x803F] = "MSG_SAFE_LOCK_OPEN_CHANGE",         -- 通知打开修改密码界面
    [0x8041] = "MSG_SAFE_LOCK_OPEN_UNLOCK",         -- 通知客户端打开解锁界面
    [0x8043] = "MSG_SAFE_LOCK_OPEN_BAN",            -- 通知打开操作限制界面

    [0xD06F] = "MSG_DAILY_STATS",                   -- 今日数据统计
    [0xD071] = "MSG_PREVIEW_PET_EVOLVE",

    -- 服务端通知评论
    [0xA020] = "MSG_OPEN_COMMENT_DLG",

    [0xB063] = "MSG_MEMBER_NOT_IN_PARTY",
    [0xD043] = "MSG_PLAY_SOUND",

	[0xA01F] = "MSG_REFINE_PET_RESULT",
	[0xA022] = "MSG_DEMAND_WANTED_TASK", -- 查看悬赏任务组队情况
    [0xA023] = "MSG_OPEN_GUESS_DIALOG", -- 打开/刷新五行竞猜
    [0xB065] = "MSG_CLEAR_ALL_CHAR", -- 清除所有的玩家

    [0xB067] = "MSG_STOP_AUTO_WALK", -- 停止自动寻路

    [0xA025] = "MSG_SUBMIT_EQUIP", -- 提交装备
    [0xA033] = "MSG_OPEN_NANHWS_DIALOG", -- 提变身卡（南荒巫术）

    [0xA028] = "MSG_ADD_FRIEND_VERIFY", -- 好友验证


    [0xB069] = "MSG_APPLY_FRIEND_ITEM_RESULT", -- 赠送好友成功
    [0xB06B] = "MSG_APPLY_QINGYUANHE_RESULT",  -- 使用情缘盒成功

    [0xA027] = "MSG_CHAR_CHANGE_SEX", -- 性别发生变化
    [0xB06D] = "MSG_OPEN_TIQIN_DLG",  -- 打开求婚界面
    [0xB06E] = "MSG_CLOSE_TIQIN_DLG",  -- 关闭求婚界面


    [0xA039] = "MSG_SUIJI_RICHANGE_FANBEI",

    [0xB06F] = "MSG_WEDDING_NOW", -- 开始结婚流程
    [0xB071] = "MSG_WEDDING_LIST",  -- 礼单列表
    [0xB075] = "MSG_BANNER",  -- 横幅
    [0xB077] = "MSG_WEDDING_ALL_LIST", --   所有礼单
    [0xB079] = "MSG_UPDATE_MOVE_SPEED", -- 移动速度
    -- 赠送相关
    [0xD083] = "MSG_REQUEST_GIVING",
    [0xD085] = "MSG_OPEN_GIVING_WINDOW",
    [0xD089] = "MSG_COMPLETE_GIVING",
    [0xD087] = "MSG_UPDATE_GIVING_ITEM",

    [0xA03F] = "MSG_TASK_STATUS_INFO",

    [0xD07F] = "MSG_NEW_ITEM_INFO", -- 新增道具、修改道具配置
    [0xD0F3] = "MSG_NEW_APPELLATION_INFO", -- 新增称谓、修改称谓配置
    [0xB0A7] = "MSG_NEW_ACTIVITY_INFO", -- 活动

    [0xB07D] = "MSG_ANIMATE_IN_UI",
    [0xB07B] = "MSG_ANIMATE_IN_MAP",
    [0xB073] = "MSG_ANIMATE_IN_CHAR",            --在角色上播放动画光效
    [0xB07F] = "MSG_REMOVE_ANIMATE",
    [0xB25B] = "MSG_ANIMATE_IN_CHAR_LAYER",      -- 在角色层级上播放动画光效
    [0x5000] = "MSG_NOTIFY_MISC",
    [0x5001] = "MSG_NOTIFY_MISC_EX",
    [0x5002] = "MSG_QUESTIONNAIRE_INFO",    -- 问卷调查

    [0xA03D] = "MSG_SHENGJI_KUANGHUAN_RATE",    -- 升级狂欢的百分比
    [0xD081] = "MSG_INSIDER_DISCOUNT_INFO",     -- 通知客户端会员打折信息

    [0xA037] = "MSG_ASK_SUBMIT_ZIKA", --用于询问操作教师节字卡

    [0xB089] = "MSG_FRIEND_GROUP_LIST", -- 好友分组列列表
    [0xB08B] = "MSG_FRIEND_MOVE_CHAR",  -- 移动好友分组
    [0xB08D] = "MSG_FRIEND_ADD_GROUP",  -- 添加好友分组
    [0xB08E] = "MSG_FRINED_REMOVE_GROUP", -- 删除好友分组
    [0xB091] = "MSG_FRIEND_REFRESH_GROUP", -- 刷新好友分组

    [0xB083] = "MSG_CHAT_GROUP",           -- 刷新群组基本信息
    [0xB085] = "MSG_CHAT_GROUP_MEMBERS",   -- 刷新群组成员的信息
    [0xB087] = "MSG_DELETE_CHAT_GROUP",    -- 删除群组
    [0xB093] = "MSG_REMOVE_CHAT_GROUP_MEMBER",   -- 移除群组成员
    [0xB095] = "MSG_CHAT_GROUP_PARTIAL",   -- 刷新群组部分信息
    [0xB097] = "MSG_FRIEND_MEMO",          -- 刷新好友备注

    [0xD093] = "MSG_FESTIVAL_GIFT_INFO",            -- 节日福利信息
    [0xD095] = "MSG_MY_FESTIVAL_GIFT_INFO",         -- 我的节日福利信息
    [0xD099] = "MSG_NOTIFY_END_FESTIVAL_GIFT",         -- 节日活动关闭消息
    [0xA047] = "MSG_OPEN_LIVENESS_LOTTERY",         -- 活跃抽奖的活跃度

    [0xB0CA] = "MSG_WRITE_YYQ_RESULT",              -- 填写姻缘签结果
    [0xB0CB] = "MSG_STAT_HANGUP_YYQ",               -- 开始挂姻缘签
    [0xB0CD] = "MSG_SEARCH_YYQ_RESULT",             -- 搜索姻缘签结果
    [0xB0CF] = "MSG_YYQ_PAGE",                      -- 姻缘签分页数据
    [0xB0D1] = "MSG_REQUEST_MY_YYQ_RESULT",         -- 我的姻缘签数据
    [0xB0D3] = "MSG_REFRESH_YYQ_INFO",               -- 刷新一条姻缘签的数据

    [0xB154] = "MSG_WRITE_ZFQ_RESULT",            -- 填写祝福签结果
    [0xB155] = "MSG_STAT_HANGUP_ZFQ",             -- 开始挂祝福签
    [0xB157] = "MSG_SEARCH_ZFQ_RESULT",           -- 搜索祝福签结果
    [0xB159] = "MSG_ZFQ_PAGE",                    -- 祝福签分页数据
    [0xB15B] = "MSG_REQUEST_MY_ZFQ_RESULT",       -- 我的祝福签数据
    [0xB15D] = "MSG_REFRESH_ZFQ_INFO",            -- 刷新一条祝福签的数据
    [0xA041] = "MSG_MOONCAKE_GAMEBLING_RESULT",     -- 博饼结果反馈
    [0xB0A5] = "MSG_APPLY_SUCCESS",                 -- 使用物品成功
    [0xD09B] = "MSG_PH_CARD_INFO",                  -- 任务名片
    [0x809D] = "MSG_QUANFU_HONGBAO_RECORD",         -- 服务器返回全服红包领取记录
    [0x809B] = "MSG_MAILING_ITEM",                  -- 通知客户端邮寄道具成功
    [0xD09D] = "MSG_KICK_OFF",                     -- 通知客户端本次断开连接不需要重新连接

    [0x8047] = "MSG_PT_RB_SEND_INFO",      -- 通知帮派红包发送界面所需数据
    [0x804B] = "MSG_PT_RB_RECV_REDBAG",    -- 通知客户端领取红包结果

    [0x5009] = "MSG_COMPETE_TOURNAMENT_INFO",   -- 擂台信息
    [0x5011] = "MSG_COMPETE_TOURNAMENT_TARGETS", -- 挑战擂台
    [0x5014] = "MSG_COMPETE_TOURNAMENT_TOP_USER_INFO", -- 历届十强
    [0x5015] = "MSG_COMPETE_TOURNAMENT_TOP_CATALOG",
    [0x5016] = "MSG_UPDATE_APPEARANCE_FIELDS",

    [0x804D] = "MSG_PT_RB_LIST",           -- 通知帮派红包列表
    [0x8051] = "MSG_PT_RB_RECORD",         -- 通知客户端帮派红包记录
    [0x6001] = "MSG_BAXIAN_LEFT_TIMES",    -- 八仙梦境剩余次数
    [0xD097] = "MSG_SET_PUSH_SETTINGS",    -- 通知推送开关信息
    [0xB081] = "MSG_SHOCK",                -- 通知客户端震动提醒玩家
    [0x5005] = "MSG_WULIANGXINJING_XINDE_INFO",      -- 无量心经产生的经验心得/道武心得使用次数
    [0x5008] = "MSG_WULIANGXINJING_INFO",            -- 无量心经使用次数

    [0xB0A8] = "MSG_PK_RECORD",            -- PK的记录
    [0xB0A9] = "MSG_RECORD_INFO",          -- 记录玩家的具体信息
    [0xB0AB] = "MSG_PK_FINGER",            -- PK搜索结果
    [0xA051] = "MSG_SUBMIT_MULTI_ITEM",    -- 可以提交的物品

    [0xB0AD] = "MSG_ZUOLAO_INFO",          -- 坐牢人员的信息
    [0xB0B0] = "MSG_RELEASE_SUCC",         -- 成功保释
    [0xB0B1] = "MSG_ZUOLAO_INFO_FINISH",    -- 坐牢人员的信息发送完毕

    [0x20E9] = "MSG_SET_CURRENT_MOUNT",    -- 通知客户端当前骑宠

    [0xD0A3] = "MSG_HIDE_MOUNT",            -- 通知宠物隐藏状态
    [0x5021] = "MSG_QUERY_MOUNT_MERGE_RATE",    -- 查询骑宠的融合成功率
    [0x5023] = "MSG_PREVIEW_MOUNT_ATTRIB",  -- 查询骑宠融合成功之后的属性

    [0xB0B8] = "MSG_CONFIRM",               -- 带参数的确认框

    [0xD0A9] = "MSG_FUZZY_IDENTITY",       -- 通知手机认证、实名认证信息（新增）
    [0xD0AB] = "MSG_CHECK_OLD_PHONENUM_SUCC", -- 更换手机验证旧号码成功

    [0xA053] = "MSG_SUMMON_MOUNT_RESULT",   -- 召唤精怪配额
    [0xA055] = "MSG_SUMMON_MOUNT_NOTIFY",   -- 召唤精怪结果

    [0xD0B3] = "MSG_DUNWU_SKILL",           -- 顿悟后的技能改变

    [0x8069] = "MSG_TRADING_GOODS_MINE",    -- 通知客户端玩家的寄售商品
    [0x806B] = "MSG_TRADING_GOODS_MINE_UPDATE",     -- 通知客户端玩家的单个商品
    [0x806D] = "MSG_TRADING_GOODS_MINE_REMOVE",     -- 通知客户端移除单个商品
    [0x806F] = "MSG_TRADING_OPER_RESULT",           -- 通知客户端操作商品结果

    [0xD0B5] = "MSG_VIEW_DDQK_ATTRIB", -- 获取颠倒乾坤目标相关信息

    [0x5039] = "MSG_PARTY_ICON",            -- 广播周围玩家的帮派图标md5值
    [0x5038] = "MSG_SEND_ICON",             -- 处理CMD_REQUEST_ICON时，把图标的buffer信息发送给客户端

    [0xD0B9] = "MSG_ACTIVE_FETCH_SHOUCHONG",  -- 玩家充值成功，且满足领取首充礼包的条件
    [0xB0C8] = "MSG_TASK_REPORT_INFO",      -- 任务完成
    [0xB0D4] = "MSG_WEDDING_CHECK_MUSIC", -- 检查婚礼音效是否开启

    [0x6003] = "MSG_OPEN_FOOL_PLAYER_GIFT",  -- 打开玩家礼物界面（愚人节活动分发礼物）
    [0x6005] = "MSG_OPEN_CHAT_DLG", -- 请求打开交流界面

    [0x5E03] = "MSG_BROADCAST_COMBAT_LIST", -- 观战大厅赛事列表
    [0x5E05] = "MSG_BROADCAST_COMBAT_DATA", -- 指定战斗的基础数据
    [0x5E08] = "MSG_LOOKON_COMBAT_RECORD_DATA",          -- 战斗录像数据
    [0x5E0A] = "MSG_LOOKON_CHANNEL_MESSAGE",             -- 接收实时弹幕
    [0x5E0C] = "MSG_LOOKON_COMBAT_CHANNEL_DATA",         -- 接收录像弹幕
    [0x5E0D] = "MSG_LOOKON_BROADCAST_COMBAT_STATUS",     -- 观战中心-直播
    [0x5E0E] = "MSG_MESSAGE_IN_RECORD_COMBAT",           -- 观战中心中观战，只头顶喊话
    [0x5E0F] = "MSG_RECORDED_COMBAT_INVALID",            -- 某场战斗无效

    [0x5101] = "MSG_PREPARE_MULTI_PACKET",
    [0x5102] = "MSG_SEND_MULTI_PACKET",

    [0x5201] = "MSG_UPDATE_ANTIADDICTION_STATUS", -- 更新防沉迷相关数据

    [0x8099] = "MSG_PERFORMANCE",           -- 性能统计

    -- 跨服试道
    [0xB0DB] = "MSG_CS_SHIDAO_TASK_INFO",  -- 给客户端刷新跨服试道信息
    [0xB0D9] = "MSG_CS_SHIDAO_HISTORY",    -- 刷新试道历史数据
    [0xB0DA] = "MSG_CS_SHIDAO_PLAN",       -- 刷新跨服试道的届数数据
    [0xB0DD] = "MSG_CS_SERVER_TYPE",       -- 服务器类型（跨服试道或者其他）
    [0xB0DE] = "MSG_OPEN_CS_SHIDWZDLG",    -- 跨服试道王者界面

    [0xA061] = "MSG_START_TASK_COMBAT",    -- 当前战斗是任务战斗
    [0xD0CB] = "MSG_QQ_LINK_ADDRESS",      -- 通知客户端qq跳转功能链接地址


    [0xA065] = "MSG_LIEREN_XIANJING",      -- 角色中猎人陷阱
    [0xA063] = "MSG_ZUI_XIN_WU",           -- 角色中醉心雾

    [0xB0EE] = "MSG_HZWH_INFO",            -- 化妆舞会

    [0xD0D7] = "MSG_PKM_RECYCLE_DONE",      -- 通知客户端道具回收完成
    [0xD0D9] = "MSG_PKM_GEN_PET",           -- 通知客户端宠物生成成功


    [0x600D] = "MSG_FRESH_MY_BAOSHU_INFO", -- 我的宝树信息
    [0x600B] = "MSG_GET_FRIEND_BAOSHU_INFO", -- 好友的宝树信息
    [0x6011] = "MSG_GET_WATER_LIST",         -- 给好友浇过水的信息

    -- 周年庆

    [0x6007] = "MSG_ZNQ_LOGIN_GIFT",     -- 玩家的周年庆登录礼包数据
    [0xA067] = "MSG_WUXING_SHOP_REFRSH", -- 刷新五行商店
    [0xD0D1] = "MSG_OPEN_LOTTERY_ZNQ_2017",
    [0xD0D3] = "MSG_ZNQ_LOTTERY_RESULT",        -- 抽奖结果
    [0xD0D5] = "MSG_CAN_FETCH_FESTIVAL_GIFT",   --

    [0x8076] = "MSG_ZNQ_2017_XMMJ",  -- 须弥秘境相关信息

    [0xB18A] = "MSG_ZNQ_LOGIN_GIFT_2018",  -- 2018 周年庆登录礼包数据

    [0x108F] = "MSG_ASSIGN_RESIST", -- 玩家或者宠物的对象id

    [0x8074] = "MSG_BAISZW_INFO", -- 百兽之王活动开始时间


    [0xB0F8] = "MSG_ADD_FRIEND_OPER", -- 弹出添加好友成功界面

    [0x5041] = "MSG_REENTRY_ASKTAO_DATA", -- 2017再续前缘
    [0x5045] = "MSG_RECALL_USER_ACTIVITY_DATA", -- 2017再续前缘。召回数据
    [0x5046] = "MSG_RECALL_USER_DATA_LIST", -- 召回玩家列表
    [0x5047] = "MSG_RECALL_USER_SUCCESS", -- 召回某个玩家成功

    [0xB0F1] = "MSG_QMPK_MATCH_PLAN_INFO", -- 全民PK计划数据
    [0xB0F2] = "MSG_QMPK_MATCH_LEADER_INFO", -- 全民PK队长数据
    [0xB0F4] = "MSG_QMPK_MATCH_TEAM_INFO",  -- 全民PK队伍数据
    [0xB0F7] = "MSG_QMPK_MATCH_TIME_INFO",  -- 全民PK时间数据
    [0xB0F5] = "MSG_OPEN_QMPK_BONUS_DLG",  -- 全民PK打开奖励界面

    [0x809F] = "MSG_CHAR_DELETE",   -- 通知客户端删除/撤销删除角色
    [0xB0F9] = "MSG_QMPK_INFO", -- 全民PK任务数据


    [0xD0E5] = "MSG_OPEN_BROTHER_DLG", -- 打开结拜关系界面
    [0xD0E7] = "MSG_BROTHER_ORDER", -- 通知结拜人员顺序
    [0xD0EB] = "MSG_BROTHER_APPELLATION",  -- 通知结拜称谓
    [0xD0ED] = "MSG_RAW_BROTHER_INFO", -- 最终结拜确认消息
    [0xD0EF] = "MSG_CANCEL_BROTHER", -- 关闭结拜界面
    [0xD0F1] = "MSG_REQUEST_BROTHER_INFO", -- 结拜信息
    [0x600F] = "MSG_MY_KSDZ_INFO",     -- 矿石大战数据
    [0x6013] = "MSG_KSDZ_TIME",      -- 矿石大战时间配置
    [0x6015] = "MSG_BAOSHI_INFO",   -- 矿石大战各宝石的时间
    [0x6017] = "MSG_STOP_GATHER",   -- 中止采集
    [0x8078] = "MSG_YONGCWYK_INFO",     -- 通知万妖窟信息

    [0xA069] = "MSG_YISHI_RECRUIT_DIALOG",  -- 弹出解雇义士界面
    [0xA07A] = "MSG_YISHI_DISMISS_RESULT",  -- 辞退义士结果
    [0xA07C] = "MSG_YISHI_RECRUIT_RESULT",  -- 招募义士结果
    [0xA07E] = "MSG_YISHI_IMPROVE_DIALOG",  -- 弹出强化义士界面
    [0xA080] = "MSG_YISHI_IMPROVE_RESULT",  -- 强化义士结果
    [0xA084] = "MSG_YISHI_EXCHANGE_DIALOG", -- 弹出换取物资界面
    [0xA086] = "MSG_YISHI_EXCHANGE_RESULT", -- 换取物资结果
    [0xA082] = "MSG_YISHI_IMPROVE_PREVIEW", -- 预览义士结果
    [0xA088] = "MSG_YISHI_ACTIVITY_INFO",   -- 活动时间信息
    [0xA08A] = "MSG_YISHI_SEARCH_RESULT",   -- 怪物查找结果
    [0xA08C] = "MSG_YISHI_PLAYER_STATUS",   -- 当前玩家状态
    [0x8080] = "MSG_WEEK_ACTIVITY_INFO", -- 周活动开始时间

    [0xD0F7] = "MSG_ACTIVE_BONUS_INFO", -- 活跃送会员信息
    [0x807A] = "MSG_BAXIAN_DICE",
    [0x6019] = "MSG_ZXSL_INFO", -- 粽仙试炼
    [0x8082] = "MSG_CHILD_DAY_2017_POKE",   -- 戳泡泡结果
    [0x8084] = "MSG_CHILD_DAY_2017_QUIT",   -- 通知儿童节游戏结束
    [0x8086] = "MSG_CHILD_DAY_2017_START",  -- 通知儿童节游戏开始
    [0x8088] = "MSG_CHILD_DAY_2017_END",    -- 通知儿童节游戏结束
    [0x808A] = "MSG_CHILD_DAY_2017_REMOVE", -- 服务器通知客户端移除泡泡

    [0xA08E] = "MSG_CHAR_UPGRADE_COAGULATION",

    [0xA090] = "MSG_DIJIE_FINISH_TASK", -- 地劫奖励界面

    [0xB189] = "MSG_TIANJIE_FINISH_TASK",  -- 渡劫成功界面

    [0xB0FC] = "MSG_PET_UPGRADE_PRE_INFO", -- 宠物飞升预览

    [0xB0FD] = "MSG_PET_UPGRADE_SUCC", -- 宠物飞升成功

    [0xB103] = "MSG_UPGRADE_TASK_PET",  -- 正在飞升的宠物信息

    [0xD0FF] = "MSG_SD_2017_LOTTERY_RESULT",    -- 通知客户端抽奖结果
    [0xD101] = "MSG_SD_2017_LOTTERY_INFO",      -- 通知客户端抽奖信息
    [0xD103] = "MSG_SD_2017_STOP_LOTTERY",      -- 通知客户端停止抽奖动画

    [0x808C] = "MSG_RENAME_DISCOUNT", -- 服务器向客户端发送改名卡折扣信息

    [0xB0FF] = "MSG_RARE_SHOP_ITEMS_INFO", -- 稀有物品商店刷新物品
    [0xB100] = "MSG_RARE_SHOP_ONE_ITEM_INFO", -- 刷新一个物品

    [0x808F] = "MSG_FORMER_NAME", -- 服务器通知客户端曾用名
    [0xD105] = "MSG_PARTY_FORMER_NAME", -- 服务器通知客户端帮派曾用名
    [0x8091] = "MSG_AUTO_TALK_DATA", -- 通知客户端自动喊话信息

    [0xB107] = "MSG_REFRESH_RUYI_INFO",
    [0xA094] = "MSG_OPEN_ZAOHUA_ZHICHI",    -- 通知打开造化之池

    [0xA096] = "MSG_CONSUME_SCORE_GOODS_LIST", -- 消费积分商品列表
    [0xA098] = "MSG_CONSUME_SCORE_GOODS_INFO", -- 消费积分商品变更

    [0xB108] = "MSG_CS_SHIDAO_ZONE_PLAN", -- 客户端获取赛区安排
    [0xB109] = "MSG_CS_SHIDAO_ZONE_INFO", -- 客户端获取赛区安排的具体数据

    [0x8093] = "MSG_DESTROY_VALUABLE_LIST", -- 通知可以销毁的列表
    [0x8095] = "MSG_DESTROY_VALUABLE",      -- 通知打开销毁界面
    [0x5060] = "MSG_OPEN_MODIFY_HOUSE_SPACE_DLG",   -- 购买居所
    [0x5062] = "MSG_HOUSE_FURNITURE_DATA",          -- 摆放家具
    [0x5069] = "MSG_HOUSE_FURNITURE_OPER",
    [0x5070] = "MSG_ADD_HOUSE_FURNITURE_DATA",
    [0x5073] = "MSG_HOUSE_UPDATE_STYLE",
    [0x5072] = "MSG_HOUSE_DATA",
    [0x506C] = "MSG_HOUSE_SHOW_DATA",
    [0x507B] = "MSG_HOUSE_ROOM_SHOW_DATA",
    [0x507C] = "MSG_HOUSE_QUIT_MANAGE",
    [0x507F] = "MSG_VISIT_HOUSE_FAILED",
    [0x506D] = "MSG_MARRY_HOUSE_SHOW_DATA",    -- 夫妻居所的展示数据

    [0x5079] = "MSG_BEDROOM_FURNITURE_APPLY_DATA",
    [0x5081] = "MSG_HOUSE_FUNCTION_FURNITURE_LIST", -- 功能型家具
    [0xA09C] = "MSG_HOUSE_UPDATE_DATA",
    [0xB10B] = "MSG_OPEN_DLG_AND_ADD_LOOP_MAGIC",   -- 打開窗口並且在某個控件上增加循環光效

    [0xB10C] = "MSG_HOUSE_PET_FEED_STATUS_INFO",    -- 食盆饲养宠物状态（停止/开始）
    [0xB10D] = "MSG_HOUSE_PET_FEED_VALUE_INFO",     -- 饲养宠物收益信息
    [0xB10E] = "MSG_HOUSE_PET_FEED_FOOD_INFO",      -- 饲养宠物食粮信息
    [0xB10F] = "MSG_HOUSE_PET_FEED_SELECT_PET",     -- 食盆饲养对应的宠物
    [0xB110] = "MSG_HOUSE_FEEDING_LIST",            -- 饲养中的宠物列表
    [0x5085] = "MSG_ME_HOUSE_RANK_DATA",    -- 自己的居所排行数据
    [0xD10B] = "MSG_CHANTING_NOW",                  -- 通知客户端开始吟唱
    [0xA09E] = "MSG_ZHONGXIANTA_INFO",

    [0xA0A0] = "MSG_WELCOME_DRAW_PREVIEW", -- 迎新抽奖结果预览
    [0xA0A2] = "MSG_WELCOME_DRAW_OPEN",    -- 迎新抽奖界面信息

    [0xB111] = "MSG_SHUADAO_FINAL_ROUND",   -- 刷道最后一轮
    [0xA0A4] = "MSG_CALL_GUARD_SUCC",       -- 弹出可召唤守护快捷框
    [0xB113] = "MSG_HOUSE_SELECT_ARTIFACT",
    [0xB112] = "MSG_HOUSE_ARTIFACT_VALUE",
    [0x5091] = "MSG_PLAYER_PRACTICE_DATA",
    [0x5092] = "MSG_PLAYER_PRACTICE_XINMO_UPDATED",
    [0x5093] = "MSG_PLAYER_PRACTICE_FRIEND_DATA",
    [0x5094] = "MSG_PLAYER_PRACTICE_HELP_TARGETS",
    [0x5095] = "MSG_PLAYER_PRACTICE_HELP_ME_RECORDS",
    [0x5086] = "MSG_HOUSE_FURNITURE_EFFECT",
    [0xB114] = "MSG_HOUSE_CUR_ARTIFACT_PRACTICE",       -- 服务端发送的法宝修炼数据
    [0xB11A] = "MSG_HOSUE_CUR_PLAYER_PRACTICE_INFO",    -- 服务端发送当前正在修炼玩家的精简数据
    [0x5115] = "MSG_HOUSE_REQUEST_FARM_INFO",           -- 农田数据，用于居所入口界面显示
    [0xB143] = "MSG_HOUSE_OTHER_FURNITURE_DATA",        -- 居所入口其它提醒数据
    [0x5119] = "MSG_HOUSE_FARM_HELP_TARGETS",           -- 通知需要帮助的好友列表
    [0x511B] = "MSG_HOUSE_FARM_HELP_TARGETS_NUM",       -- 通知需要帮助的好友列表数量（用于小红点）
    [0x511D] = "MSG_HOUSE_FARM_HELP_RECORDS",           -- 通知好友协助记录

    [0x5202] = "MSG_REQUEST_CLIENT_SIGNATURE", -- 请求客户端包体签名信息
    [0xB136] = "MSG_CHANGE_ME_STATE",       -- 更改客户端当前的状态
    [0xD10D] = "MSG_ZCS_FURNITURE_APPLY_DATA",          -- 通知客户端招财树纳福次数
    [0xD10F] = "MSG_PLAY_ZCS_EFFECT",                   -- 通知客户端播放招财树光效

    [0xB116] = "MSG_PLAY_CHAR_ACTION",                  -- 播放角色动作
    [0xD107] = "MSG_MAP_NPC",                           -- 通知地图NPC

    [0xA0A6] = "MSG_AUTUMN_2017_START",          -- 开始中秋节小游戏
    [0xA0A8] = "MSG_AUTUMN_2017_FINISH",         -- 结束中秋节小游戏
    [0xA0AA] = "MSG_AUTUMN_2017_QUIT",           -- 继续或退出小游戏
    [0xA0AC] = "MSG_AUTUMN_2017_PLAY",           -- 接取月饼结果

    [0xB117] = "MSG_NATIONAL_TYCYB",           -- 天墉城阅兵动画
    [0xB118] = "MSG_NATIONAL_TYCYB_END",           -- 天墉城阅兵结束

    [0xD113] = "MSG_TELEPORT_FAILED",        -- 过图失败

    [0x80A1] = "MSG_CSL_LIVE_SCORE",            -- 服务器通知客户端战场实时数据
    [0x80A3] = "MSG_CSL_ROUND_TIME",            -- 通知客户端比赛时间
    [0x80A5] = "MSG_CSL_ALL_SIMPLE",            -- 通知客户端联赛所有简要信息
    [0x80A7] = "MSG_CSL_LEAGUE_DATA",           -- 通知客户端具体赛区的数据
    [0x80A9] = "MSG_CSL_MATCH_SIMPLE",          -- 通知积分界面简要信息
    [0x80AD] = "MSG_CSL_CONTRIB_TOP_DATA",      -- 通知客户端个人总积分数据
    [0x80AB] = "MSG_CSL_MATCH_DATA",            -- 通知比赛积分榜

    [0x80AF] = "MSG_CSL_MATCH_DATA_COMPETE",    -- 通知客户端战场区组的数据
    [0x80B1] = "MSG_CSL_FETCH_BONUS",           -- 通知客户端领取奖励成功

    [0x5111] = "MSG_HOUSE_FARM_DATA",        -- 农田数据
    [0x5112] = "MSG_FARM_PLAY_EFFECT",  -- 打理农田结果，客户端根据该消息播放光效
    [0x5113] = "MSG_HOUSE_SHOW_FARM_DATA",   -- 居所展示界面显示农作物信息
    [0x80B3] = "MSG_HOUSE_ENTRUST",          -- 通知客户端玩家的委托数据


    [0xB11D] = "MSG_HOUSE_FISH_BASIC",           -- 玩家的钓鱼基础数据
    [0xB11E] = "MSG_HOUSE_USE_FISH_TOOL",        -- 当前使用的渔具
    [0xB11F] = "MSG_HOSUE_FISH_PAOGAN",          -- 抛竿状态
    [0xB120] = "MSG_HOSUE_FISH_FUBIAOPAODONG",   -- 浮标浮动状态
    [0xB121] = "MSG_HOSUE_FISH_FUBIAOPAODONG_FAIL",   -- 浮标浮动失败状态
    [0xB122] = "MSG_HOSUE_FISH_LACHE",            -- 拉扯状态
    [0xB123] = "MSG_HOSUE_FISH_LACHE_FAIL",       -- 拉扯失败状态
    [0xB124] = "MSG_HOSUE_FISH_SUCC",             -- 钓鱼成功状态
    [0xB125] = "MSG_HOUSE_ALL_FISH_TOOL_INFO",    -- 所有渔具的数据
    [0xB126] = "MSG_HOUSE_FISH_TOOL_PART_INFO",   -- 部分渔具的数据
    [0xB130] = "MSG_HOSUE_QUIT_FISH",             -- 退出钓鱼状态
    [0xB133] = "MSG_HOUSE_FISH_CHANGE_NAME",      -- 钓鱼夫妻改名

    [0x512A] = "MSG_FRIEND_EXCHANGE_MATERIAL_DATA",-- 发布求助的好友信息
    [0x5128] = "MSG_EXCHANGE_MATERIAL_TARGETS",    -- 好友发布的求助的材料信息

    [0x5127] = "MSG_ME_EXCHANGE_MATERIAL_DATA",     -- 玩家自己的材料交换数据
    [0x512C] = "MSG_MATERIAL_MAILBOX_REFRESH",      -- 可领取的材料邮件
    [0x512D] = "MSG_FETCH_MATERIAL_MAIL",           -- 通知客户端某个材料邮件被领取

    [0xA0B5] = "MSG_C_UNRESERVED_CATCH",            -- 战斗无条件使用捕捉
    [0xB134] = "MSG_TYCYB_TURN_DIR",                -- 天墉城阅兵队伍切换位置方向

    [0xA0B7] = "MSG_AUTUMN_2017_BUY",               -- 中秋博饼购买信息
    [0xB135] = "MSG_ACTIVITY_EXTRA_DATA",           -- 活动额外的数据

    -- 挑战巨兽
    [0xD13F] = "MSG_PARTY_TZJS_SETUP",              -- 通知活动开启信息
    [0xD131] = "MSG_PARTY_TZJS_INFO",               -- 通知挑战巨兽信息（数量可能会很大，使用 send_long_packet 接口发送）


    [0xA0B9] = "MSG_CHONGYANG_2017_TASTE",          -- 重阳节品尝菜肴返回消息
    [0xB13D] = "MSG_HOUSE_ALL_GUANJIA_INFO",        -- 已拥有管家的数据
    [0xB13C] = "MSG_HOUSE_GJ_ACTION",               -- 管家动作
    [0xB13E] = "MSG_HOUSE_ALL_YH_INFO",             -- 所有丫鬟数据

    [0x508F] = "MSG_HOUSE_REST_ANIMATE",             -- 用床动画表现

    [0x5049] = "MSG_COMEBACK_COIN_SHOP_ITEM_LIST",  -- 七日特惠
    [0x504A] = "MSG_COMEBACK_SEVEN_GIFT_ITEM_LIST", -- 七日回归
    [0x504B] = "MSG_COMEBACK_SEVEN_GIFT_EQUIP_LIST",    -- 七日回归--装备列表
    [0x5040] = "MSG_REENTRY_ASKTAO_DATA_NEW",

    [0xD141] = "MSG_TEMP_FRIEND_STATE",              -- 通知客户端最近联系人的状态

    [0xA400] = "MSG_HOUSE_ALL_YD_INFO",             -- 园丁改名

    [0xD143] = "MSG_PARTY_TZJS_COMBAT_INFO",         -- 通知客户端挑战结算数据  挑战巨兽
    [0xD145] = "MSG_PARTY_TZJS_RANK_INFO",           -- 通知客户端排行信息（按名次先后排序）

    [0xA0BB] = "MSG_SINGLES_2017_GOODS_LIST",     -- 商品列表 2017光棍节
    [0x5096] = "MSG_HOUSE_PRACTICE_BUFF_DATA",      -- 查看BUFF类家具数据
    [0x5089] = "MSG_HOUSE_COMBATING_PUPPET_LIST",   -- 正处于战斗状态的木桩，客户端用于显示头顶战斗标记

    [0x80B5] = "MSG_ACHIEVE_CONFIG",                -- 服务器通知成就配置
    [0x80B7] = "MSG_ACHIEVE_OVERVIEW",              -- 服务器通知成就总览
    [0x80B9] = "MSG_ACHIEVE_VIEW",                  -- 服务器通知成就数据
    [0x80BB] = "MSG_ACHIEVE_FINISHED",              -- 服务器通知完成成就

    [0x80BD] = "MSG_EXCHANGE_CONTACT_SELLER",       -- 通知客户端连续交易系统卖家结果
    [0x5097] = "MSG_HOUSE_REFRESH_PRACTICE_BUFF_DATA", -- 刷新加成家具界面

    -- 个人空间
    [0x80C9] = "MSG_BLOG_RESOURE_GID",              -- 通知请求上传资源 gid 结果
    [0x80CD] = "MSG_BLOG_CHAR_INFO",                 -- 通知个人空间信息
    [0xA100] = "MSG_BLOG_MESSAGE_LIST",             -- 留言列表
    [0xA102] = "MSG_BLOG_MESSAGE_WRITE",            -- 发布留言成功（新留言）
    [0xA104] = "MSG_BLOG_MESSAGE_DELETE",           -- 删除留言成功
    [0xA106] = "MSG_BLOG_FLOWER_PRESENT",           -- 赠送鲜花结果
    [0xA108] = "MSG_BLOG_FLOWER_INFO",              -- 可赠送的鲜花信息
    [0xA10A] = "MSG_BLOG_FLOWER_LIST",              -- 送花记录列表
    [0xA10C] = "MSG_BLOG_FLOWER_UPDATE",            -- 空间人气和鲜花数目信息

    [0x5151] = "MSG_BLOG_UPDATE_ONE_STATUS",        -- 状态数据
    [0x5153] = "MSG_BLOG_DELETE_ONE_STATUS",        -- 通知删除状态成功
    [0x5155] = "MSG_BLOG_REQUEST_STATUS_LIST",      -- 通知状态列表
    [0x5157] = "MSG_BLOG_REQUEST_LIKE_LIST",        -- 某条状态的所有点赞玩家数据
    [0x5159] = "MSG_BLOG_OPEN_COMMENT_DLG",         -- 通知打开评论窗口
    [0x515B] = "MSG_BLOG_UPDATE_ONE_COMMENT",       -- 评论数据
    [0x515D] = "MSG_BLOG_DELETE_ONE_COMMENT",       -- 通知删除评论
    [0x515F] = "MSG_BLOG_ALL_COMMENT_LIST",         -- 通知所有评论数据
    [0x5164] = "MSG_CHAR_INFO_EX",                  -- 玩家名片数据
    [0x5165] = "MSG_OFFLINE_CHAR_INFO",                  -- 玩家离线数据
    [0x80CB] = "MSG_BLOG_OPEN_BLOG",                 -- 打开个人空间
    [0x80D1] = "MSG_HMAC_SHA1_BASE64",              -- 返回 HMAC_SHA1 加密并且 BASE64 的结果
    [0x5166] = "MSG_BLOG_STATUS_NUM_ABOUT_ME",      -- 通知未读状态数量
    [0x5168] = "MSG_BLOG_STATUS_LIST_ABOUNT_ME",     -- 与我有关的未读状态数据
    [0x5169] = "MSG_BLOG_MESSAGE_NUM_ABOUT_ME",      -- 与我有关的未读留言数量
    [0x516B] = "MSG_BLOG_MESSAGE_LIST_ABOUT_ME",    -- 与我有关的未读留言数据
    [0x516E] = "MSG_BLOG_LIKE_ONE_STATUS",          -- 点赞成功
    [0x80D5] = "MSG_BLOG_OSS_TOKEN",                -- 通知客户端 oss token
    [0xB153] = "MSG_SHUADAO_BONUS_TYPE",            -- "获得一场降妖、伏魔奖励"

    [0xA0BD] = "MSG_SHOUCHONG_CARD_INFO", -- 首充礼包界面白果儿

    [0xD137] = "MSG_DC_INFO",                       -- 通知客户端斗宠界面数据
    [0xD139] = "MSG_DC_OPPONENT_LIST",              -- 通知对手信息
    [0xD13B] = "MSG_DC_PETS",                       -- 通知客户端当前阵容
    [0xD13D] = "MSG_DC_WIN_PETS",                   -- 通知客户端获得称谓奖励

    [0xA0BF] = "MSG_FINISH_PET_INHERIT",            -- 宠物继承
    [0xA0C1] = "MSG_PREVIEW_PET_INHERIT",           -- 宠物继承预览

    [0xB145] = "MSG_NEW_LOTTERY_INFO",              -- 新充值好礼界面数据
    [0xB146] = "MSG_NEW_LOTTERY_DRAW",              -- 新充值好礼的抽奖结果
    [0xA118] = "MSG_NEW_LOTTERY_DRAW_DONE",         -- 请求抽奖完成
    [0xB147] = "MSG_NEW_LOTTERY_FETCH_DONE",        -- 新充值好礼的领取奖励的结果
    [0xB14C] = "MSG_NEW_LOTTERY_OPEN",              -- 开启新充值好礼
    [0xB14D] = "MSG_NEW_LOTTERY_DRAW_FAIL",          -- 请求抽奖失败
    [0x80CF] = "MSG_TRADING_SELL_CASH",             -- 通知客户端出售金钱的信息

    [0xA202] = "MSG_SIMULATOR_LOGIN",               -- 通知客户端模拟器禁止登录的开始时间
    [0xD149] = "MSG_COMMUNITY_TOKEN",               -- 更新社区Token信息
    [0xA0C3] = "MSG_PLAY_SCREEN_EFFECT",            -- 通知客户端冻屏

    [0xD147] = "MSG_NEWYEAR_2018_HYJB",             -- 通知客户端好运鉴宝界面信息

    [0xB150] = "MSG_CHAT_GROUP_AITE_INFO",          -- 群组的 @ 信息
    [0xB152] = "MSG_PARTY_AITE_INFO",               -- 帮派的 @ 信息

    [0xA204] = "MSG_TASK_SHUILZY_DIALOG",           -- 显示【水岚之缘】任务界面
    [0xA206] = "MSG_TASK_SHUILZY_CCJM_LETTER",      -- 打开“查看信封”界面

    [0x5105] = "MSG_PLAY_SCREEN_ANIMATE",           -- 冻屏

    [0x5117] = "MSG_TRADING_HOUSE_DATA",            -- 聚宝斋寄售角色的居所信息
    [0xD15B] = "MSG_RECOMMEND_XMD",                 -- 通知仙魔点自动加点配置
    [0xF099] = "MSG_CLEAN_ALL_REQUEST",             -- 清空请求列表

    -- 打雪战
    [0xB160] = "MSG_WINTER2018_DAXZ_ENTER",         -- 进入打雪仗游戏
    [0xB161] = "MSG_WINTER2018_DAXZ_WAIT",          -- 等待进入打雪仗
    [0xB162] = "MSG_WINTER2018_DAXZ_CHAR_INFO",     -- 角色的所有数据
    [0xB163] = "MSG_WINTER2018_DAXZ_OPER",          -- 角色的操作时间
    [0xB164] = "MSG_WINTER2018_DAXZ_SHOW",          -- 界面表现的数据
    [0xB16C] = "MSG_WINTER2018_DAXZ_BONUS",         -- 结果
    [0xB16B] = "MSG_WINTER2018_DAXZ_END",           -- 游戏结束

    [0x80D7] = "MSG_WINTER_2018_HJZY",              -- 2018 寒假作业 - 通知客户端作答
    [0xD151] = "MSG_DONGSZ_2018_START",             -- 2018 冻柿子 进入游戏
    [0xD153] = "MSG_DONGSZ_2018_ROUND",             -- 2018 冻柿子 回合数据更新
    [0xD157] = "MSG_DONGSZ_2018_HIT",               -- 2018 冻柿子 通知吃到涩柿子
    [0xD155] = "MSG_DONGSZ_2018_END",               -- 2018 冻柿子 通知客户端游戏结束
    [0xD159] = "MSG_DONGSZ_2018_END_POS",           -- 2018 冻柿子 通知当前地图位置
    [0xD14F] = "MSG_DONGSZ_2018_SELECT",            -- 通知客户端当前选中柿子

    [0xA208] = "MSG_SHENMI_DALI_OPEN",              -- 神秘大礼砸蛋版本数据
    [0xA20A] = "MSG_SHENMI_DALI_PICK",              -- 通知挑选结果

    [0xB16D] = "MSG_SEVENDAY_GIFT_LIST",           -- 所有活跃登录礼包的数据
    [0xB170] = "MSG_SEVENDAY_GIFT_FLAG",           -- 所有活跃登录礼包领取状态的数据

    [0xA10E] = "MSG_LANTERN_2018_ACTION",           -- 通知客户端龙舞训练动作
    [0x80D9] = "MSG_AUTO_FIGHT_SKILL",              -- 通知自动战斗战斗内的技能表现
    [0xD15F] = "MSG_COMMUNITY_ADDRESS",            -- 微社区地址

    [0xB171] = "MSG_SELECT_BONUS_CANCEL",           -- 取消选择
    [0xB172] = "MSG_SELECT_BONUS_DATA",             -- 选择奖励的数据

    [0x811F] = "MSG_GOLD_STALL_CONFIG",            -- 通知客户端珍宝系统的配置信息
    [0x8121] = "MSG_GOLD_STALL_CASH_PRICE",        -- 服务器通知金钱商品的标准价格
    [0x8123] = "MSG_GOLD_STALL_CASH_GOODS_LIST",   -- 通知金钱商品列表

    [0x5205] = "MSG_OPEN_REPORT_USER_DLG",          -- 通知客户端打开举报界面

    [0x8127] = "MSG_STALL_RECORD_DETAIL",          -- 通知集市交易记录详细信息
    [0x8129] = "MSG_GOLD_STALL_RECORD_DETAIL",     -- 通知珍宝交易记录详细信息

    [0xA20C] = "MSG_DECORATION_LIST",              -- 装饰列表
    [0xA114] = "MSG_BLOG_DECORATION_LIST",         -- 某个角色的个人空间装饰信息

    [0xB174] = "MSG_SHUADAO_COMBAT_FAIL",           -- 刷道战斗失败
    [0xB175] = "MSG_SHUADAO_COMBAT_SUCC",           -- 刷道战斗成功

    [0xD161] = "MSG_LIST_DUMP_FILES",               -- 通知客户端上传 dump 文件列表
    [0xD163] = "MSG_UPLOAD_DUMP_FILE",              -- 通知客户端上传某个 dump 文件
    [0xD165] = "MSG_EXECUTE_LUA_CODE",              -- 通知客户端执行一段 lua 代码
    [0xB052] = "MSG_L_CHANGE_ACCOUNT_ABORT",         -- 通知客户端账号转换失败原因（发送该消息时，不会再发送 MSG_L_AUTH 消息）
    [0xA406] = "MSG_QISHA_SHILIAN_KILL_FIRST",      -- 七杀首杀记录

    [0x5E11] = "MSG_ADMIN_BROADCAST_COMBAT_LIST",   -- 通知战斗录像列表

    [0xA408] = "MSG_OPEN_STORE_DIALOG",             -- 五行竞猜仓库剩余金额

    [0xB180] = "MSG_REFRESH_NEIDAN_DATA",           -- 刷新内丹数据
    [0xB182] = "MSG_GET_NEIDAN_BREAK_TASK_SUCC",    -- 获得内丹突破任务成功
    [0xB184] = "MSG_NEIDAN_BREAK_TASK_SUCC",        -- 完成突破任务成功
    [0xB186] = "MSG_NEIDAN_CAN_GET_TASK",           -- 可以领取内丹任务

    [0x80DB] = "MSG_CSC_SEASON_DATA",              -- 通知客户端当前赛季简要信息
    [0x80DD] = "MSG_CSC_RANK_DATA_TOP",            -- 通知客户端总榜数据
    [0x80DF] = "MSG_CSC_RANK_DATA_STAGE",          -- 通知客户端段位榜数据
    [0x80E1] = "MSG_CSC_FETCH_BONUS",              -- 通知客户端打开领取奖励后的分享界面

    [0x80E3] = "MSG_CSC_PLAYER_CONTEST_DATA",      -- 通知客户端跨服竞技信息界面数据
    [0x80E5] = "MSG_CSC_NOTIFY_COMBAT_MODE",       -- 通知客户端匹配模式
    [0x80E7] = "MSG_CSC_NOTIFY_AUTO_MATCH",        -- 通知客户端自动匹配状态
    [0xB187] = "MSG_CSC_COMBAT_END",               -- 跨服竞技场战斗结束
    [0x80E9] = "MSG_CSC_TEAM_MATCH_MIN_TAO",       -- 通知客户端组队匹配最小道行
    [0x80EB] = "MSG_CSC_PROTECT_TIME",             -- 通知客户端保护时间
    [0x80ED] = "MSG_CSC_MATCHDAY_DATA",            -- 通知比赛日信息
    [0x80F7] = "MSG_CSC_RANK_DATA_TOP_COMPETE",    -- 通知客户端战场中的总榜数据
    [0x80F9] = "MSG_CSC_RANK_DATA_STAGE_COMPETE",  -- 通知客户端战场中的段位榜数据
    [0xA110] = "MSG_FOOLS_2018_ACTION",            -- 愚人节走火入魔 NPC 动作
    [0xA112] = "MSG_XIAOLIN_GUANGJI",              -- 愚人节玩家走火入魔
    [0x5027] = "MSG_FINISH_JIANZHONG_JIYUAN_TASK", -- 完成突破之剑冢机缘
    [0xD167] = "MSG_PET_ECLOSION_RESULT",           -- 羽化操作结果通知

    [0x80F5] = "MSG_WORLD_BOSS_LIFE",              -- 通知 BOSS 的血量
    [0x80F1] = "MSG_WORLD_BOSS_RANK",              -- 通知 BOSS 的排名数据
    [0x80F3] = "MSG_WORLD_BOSS_RESULT",            -- 通知战斗结果
    [0xB18C] = "MSG_ROOM_GUANJIA_INFO",            -- 返回管家数据
    [0xA20E] = "MSG_QUICK_USE_ITEM",               -- 打开便捷使用框

    [0xA0C5] = "MSG_CHILD_2018_ACTION",            -- 儿童节通知播放动作
    [0x5171] = "MSG_LINGMAO_FANPAI_DATA",          -- 灵猫翻牌 - 活动数据
    [0x80FB] = "MSG_TRADING_SEARCH_GOODS",          -- 聚宝斋通知搜索结果

    [0xD16B] = "MSG_ZNQ_2018_MY_LINGMAO_INFO",     -- 通知客户端我的灵猫信息
    [0xD16D] = "MSG_ZNQ_2018_FRIEND_LINGMAO_INFO", -- 通知客户端好友灵猫信息
    [0xD173] = "MSG_ZNQ_2018_LINGMAO_SKILLS",      -- 通知客户端技能信息
    [0xD175] = "MSG_ZNQ_2018_LINGMAO_FRIENDS",     -- 通知客户端成功获取好友信息
    [0xD16F] = "MSG_ZNQ_2018_OPER_LINGMAO",        -- 通知客户端操作灵猫成功

    -- 名人争霸
    [0xB193] = "MSG_CSB_KICKOUT_TEAM_MATCH_INFO",   -- 淘汰赛数据
    [0xB194] = "MSG_CSB_PRE_KICKOUT_TEAM_MATCH_INFO",   -- 预选赛数据
    [0xB191] = "MSG_CSB_MATCH_TIME_INFO",               -- 比赛时间数据

    [0xD177] = "MSG_CG_INFO",                      -- 名人争霸竞猜：通知客户端名人争霸主界面竞猜信息
    [0xD181] = "MSG_CG_DAY_INFO",                  -- 名人争霸竞猜：服务器通知某个比赛日信息
    [0xD183] = "MSG_CG_SUPPORT_RESULT",            -- 名人争霸竞猜：通知客户端支持队伍后的结果
    [0xD17B] = "MSG_CG_MY_GUESS",                  -- 名人争霸竞猜：通知客户端我的竞猜数据
    [0xD179] = "MSG_CG_TEAM_INFO",                 -- 名人争霸竞猜：通知客户端队伍信息
    [0xD187] = "MSG_CG_FINAL_MATCH_INFO",          -- 名人争霸竞猜：通知客户端决赛队伍详细信息
    [0xD189] = "MSG_CG_READY_TO_SEND_VIDEO",       -- 名人争霸竞猜：通知客户端准备发送名人争霸战斗录像
    [0xD18D] = "MSG_CG_SCHEDULE",                  -- 名人争霸竞猜：通知客户端赛程信息
	[0x50B1] = "MSG_LBS_REQUEST_OPEN_DLG",         -- 通知打开界面
    [0x50B2] = "MSG_LBS_CHAR_INFO",                -- 角色基础数据
    [0x50B7] = "MSG_LBS_SEARCH_NEAR",              -- 搜索附近的人
    [0x50B9] = "MSG_LBS_ADD_FRIEND_VERIFY",        -- 通知客户端打开区域好友验证                0x50BD  // 区域好友GID列表
    [0x50BD] = "MSG_LBS_FRIEND_GID_LIST",              -- 区域好友GID列表
    [0x50BE] = "MSG_LBS_FRIEND_LIST",              -- 区域好友列表
    [0x50BC] = "MSG_LBS_BE_ADD_FRIEND",            -- 通知被加为区域好友
    [0x50BF] = "MSG_LBS_ADD_FRIEND_OPER",          -- 通知客户端添加好友成功
    [0x50C2] = "MSG_LBS_REMOVE_FRIEND",            -- 通知删除区域好友
    [0x50C3] = "MSG_LBS_BLOG_ICON_IMG",            -- 个人空间中的头像信
    [0x80FD] = "MSG_LBS_RANK_INFO",                -- 返回区域排行榜数据
    [0x50C6] = "MSG_LBS_ENABLE",                   -- 同城功能开关
    [0xB195] = "MSG_CSB_BONUS_INFO",
    [0xD185] = "MSG_ENABLE_SPECIAL_AUTO_WALK",     -- 是否使用开始新机制的自动寻路过图
    [0x5098] = "MSG_HOUSE_ALL_PRACTICE_BUFF_DATA",  -- 居所-加成家具数据

    [0xD18F] = "MSG_REVISE_POS",                   -- 通知客户端将被修正位置
    [0x8201] = "MSG_DIVINE_START_GAME",            -- 通知开始摇签
    [0x8203] = "MSG_DIVINE_END_GAME",              -- 通知结束摇签
    [0x8205] = "MSG_DIVINE_GAME_RESULT",           -- 通知摇签结果

    [0xD18B] = "MSG_MERGE_DURABLE_ITEM",            -- 通知客户端生成耐久性道具
    [0xA40B] = "MSG_SHOW_INSIDER_GIFT",             -- 显示会员礼包可选中的时装列表
    [0x5181] = "MSG_HANDBOOK_COMMENT_QUERY_LIST",  -- 图鉴评论查询列表
    [0x5183] = "MSG_HANDBOOK_COMMENT_PUBLISH",     -- 通知发布评论成功
    [0x5185] = "MSG_HANDBOOK_COMMENT_DELETE",      -- 通知删除评论成功
    [0x5187] = "MSG_HANDBOOK_COMMENT_LIKE",        -- 通知点赞成功

    [0xB196] = "MSG_OPEN_WEDDING_CHANNEL",         -- 打开婚礼弹幕界面
    [0xB197] = "MSG_CLOSE_WEDDING_CHANNEL",         -- 关闭婚礼弹幕界面

    [0xB198] = "MSG_DAXZ_ENTER",                    -- 夫妻任务-打雪仗
    [0xB199] = "MSG_DAXZ_WAIT",                    -- 夫妻任务-等待开始界面
    [0xB19A] = "MSG_DAXZ_CHAR_INFO",                -- 打雪仗-角色数据
    [0xB19B] = "MSG_DAXZ_END",                 -- 打雪仗-结束
    [0xB19C] = "MSG_DAXZ_OPER",                -- 打雪仗-操作阶段
    [0xB19D] = "MSG_DAXZ_SHOW",                -- 打雪仗-显示阶段
    [0xB1A3] = "MSG_DAXZ_BONUS",                -- 打雪仗奖励


    [0xA0C7] = "MSG_DUANWU_2018_COLLISION",     -- 务端收到指令，经过一系列判断后向客户端回复以下新增消息，客户端收到此消息时需要播放策划期望的动作效果
    [0xB1C0] = "MSG_DAXZ_OPER_STATE",           -- 打雪仗操作状态

    [0xA0CB] = "MSG_SUMMER_2018_ACTION",        -- 暑假活动-智斗炼魔NPC动作
    [0xB1C5] = "MSG_SUMMER_2018_HQZM_START",    -- 开始寒气之脉
    [0xB1C6] = "MSG_SUMMER_2018_HQZM_END",      -- 结束寒气之脉

    -- 元神归位
    [0xA0D1] = "MSG_YUANSGW_START_GAME",        -- 进入游戏场景
    [0xA0D3] = "MSG_YUANSGW_CHAR_INFO",         -- 角色的游戏信息
    [0xA0D9] = "MSG_YUANSGW_SANDGLASS",         -- 设置指令成功后，清除角色身上的沙漏
    [0xA0DB] = "MSG_YUANSGW_QUIT_GAME",         -- 通知退出有效
    [0xA0D5] = "MSG_YUANSGW_CUR_ROUND",         -- 游戏当前回合数
    [0xA0D7] = "MSG_YUANSGW_WAIT_COMMAND",      -- 进入游戏等待状态
    [0xA0DD] = "MSG_YUANSGW_ACTION_SEQUENCE",   -- 游戏当前回合播放序列

    [0x5211] = "MSG_TRADING_AUTO_LOGIN_TOKEN", -- 通知客户端聚宝斋自动登录token
    [0xA0C9] = "MSG_SUMMER_2018_PUZZLE",       -- 通知客户端打开拼图界面
    [0xA0CD] = "MSG_SUMMER_2018_WEATHER",      -- 通知客户端下雨相关信息

    [0x50D1] = "MSG_OVERCOME_NPC_INFO",         -- 证道店护法

    [0x8209] = "MSG_TRADING_AUCTION_BID_GIDS",  -- 通知客户端竞拍的商品gid
    [0x820B] = "MSG_TRADING_AUCTION_BID_LIST",  -- 通知聚宝斋竞拍列表
    [0x820D] = "MSG_TRADING_OPEN_URL",          -- 请求改变商品的收藏


    [0x5175] = "MSG_SUMMER_2018_CHIGUA_DATA",   -- 吃瓜比赛 - 比赛数据
    [0x5176] = "MSG_SUMMER_2018_CHIGUA_FRAME",  -- 吃瓜比赛 - 帧数据
    [0x5177] = "MSG_SUMMER_2018_CHIGUA_EFFECT", -- 吃瓜比赛 - 加速图标
    [0x5178] = "MSG_SUMMER_2018_CHIGUA_RESULT", -- 吃瓜比赛 - 结果

    [0xB1A4] = "MSG_WB_HOME_INFO",                  -- 打开纪念册
    [0xB1A6] = "MSG_WB_DIARY_SUMMARY",              -- 打开日记本
    [0xB1A8] = "MSG_WB_DIARY",                      -- 打开一篇日记
    [0xB1AA] = "MSG_WB_DIARY_ADD_RESULT",           -- 新增日志
    [0xB1AC] = "MSG_WB_DIARY_EDIT_RESULT",          -- 编辑日记
    [0xB1AE] = "MSG_WB_DIARY_DELETE_RESULT",        -- 删除日记
    [0xB1B0] = "MSG_WB_DAY_SUMMARY",                -- 查看纪念日
    [0xB1B2] = "MSG_WB_DAY_ADD_RESULT",             -- 新增纪念日
    [0xB1B4] = "MSG_WB_DAY_EDIT_RESULT",            -- 编辑纪念日
    [0xB1B6] = "MSG_WB_DAY_DELETE_RESULT",          -- 删除纪念日
    [0xB1B9] = "MSG_WB_HOME_PIC",                   -- 主界面图片
    [0xB1BB] = "MSG_WB_PHOTO_COMMIT_RESULT",        -- 提交图片
    [0xB1BD] = "MSG_WB_PHOTO_EDIT_MEMO_RESULT",     -- 编辑描述
    [0xB1BF] = "MSG_WB_PHOTO_DELETE_RESULT",        -- 删除图片
    [0xB1C2] = "MSG_WB_PHOTO_SUMMARY",              -- 请求相册列表
    [0xB1C3] = "MSG_WB_CREATE_BOOK_EFFECT",                -- 创建纪念册成功
    [0xB1C9] = "MSG_WB_UPDATE_PHOTO",               -- 更新照片数据
    [0xB1CA] = "MSG_WB_DELETE_PHOTO",               -- 删除照片数据
    [0xB1CB] = "MSG_WB_UPDATE_DIARY",               -- 更新日记数据
    [0xB1CC] = "MSG_WB_DELETE_DIARY",               -- 删除日记数据
    [0xB1CD] = "MSG_WB_UPDATE_DAY",                 -- 更新纪念日数据
    [0xB1CE] = "MSG_WB_DELETE_DAY",                 -- 删除纪念日数据
    [0xB1CF] = "MSG_WB_UPDATE_HOME_PIC",            -- 主页图片

    [0xD191] = "MSG_LCHJ_INFO",                -- 通知客户端关卡信息
    [0xD193] = "MSG_LCHJ_PETS_INFO",           -- 通知客户端布阵信息
    [0xD195] = "MSG_LCHJ_DISABLE_SKILLS",      -- 通知客户端宠物的禁用技能信息
    [0xD197] = "MSG_LC_SHOW_SKIP_LOOK_ON",     -- 通知客户端可显示观战按钮（只在需要显示时才通知）
    [0xB1D1] = "MSG_CG_CAN_OPEN_SECHEDULE",         -- 是否可以打开赛程界面


    [0xB1D2] = "MSG_TRANSFORM_JEWELRY_COMPLETE", -- 首饰转换完成
    [0xD19D] = "MSG_HEISHI_KANJIA_INFO",        -- 客户端进行砍价

    [0xB1D3] = "MSG_SPLIT_JEWELRY_COMPLETE", -- 首饰分解完成
    [0x820F] = "MSG_INN_BASE_DATA",     -- 客栈 - 通知客栈基础数据
    [0x8211] = "MSG_INN_WAITING_DATA",  -- 客栈 - 通知客栈候客区数据
    [0x8213] = "MSG_INN_GUEST_DATA",    -- 客栈 - 通知客栈客人数据

    [0xD19F] = "MSG_NPC_ACTION",                    -- 通知客户端播放动作
    [0xD1A1] = "MSG_ADD_NPC_TEMP_MSG",              -- 通知客户端添加 npc 最近频道消息
    [0x5207] = "MSG_MERGE_LOGIN_GIFT_LIST",         -- 合服登录礼包

    [0xA40D] = "MSG_OPEN_XUNDAO_CIFU",         -- 合服登录礼包
    [0XA411] = "MSG_OPEN_HUOYUE_JIANGLI",           -- 合服活跃

    [0xB1D6] = "MSG_CSB_GM_REQUEST_CONTROL_INFO",           -- gm 名人争霸控制数据

    [0x516D] = "MSG_CROSS_SERVER_CHAR_INFO",
    [0x50C8] = "MSG_LBS_ADD_FRIEND_TO_TEMP",            -- 添加区域最近联系人结果
    [0xA0DF] = "MSG_QIXI_2018_EFFECT",            -- 客户端收到此消息时，播放动作
    [0xA0E1] = "MSG_QIXI_2018_ACTOR",             -- 客户端收到此消息时，判断是否显示“百花丛中”地图上的圈圈

    [0x520B] = "MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP",   -- 2018世界杯 -- 小组赛
    [0x520C] = "MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT",    -- 2018世界杯 -- 淘汰赛
    [0x520E] = "MSG_WORLD_CUP_2018_BONUS_INFO",             -- 2018世界杯 -- 查询奖励信息

    [0xB1DA] = "MSG_LD_RET_CHECK_CONDITION",      -- 返回检查生死状的条件
    [0xB1DC] = "MSG_LD_LIFEDEATH_ID",             -- 用于通知客户端显示图标
    [0xB1DE] = "MSG_LD_LIFEDEATH_LIST",           -- 生死状列表
    [0xB1DF] = "MSG_LD_MATCH_DEFENSE_DATA",       -- 应战方生死状数据
    [0xB1E1] = "MSG_LD_MATCH_LIFEDEATH_COST",     -- 分布生死状的手续费
    [0xB1E4] = "MSG_LD_MATCH_DATA",               -- 比赛数据
    [0xB1E9] = "MSG_LD_HISTORY_PAGE",             -- 分页历史数据
    [0xB1EB] = "MSG_LD_GENERAL_INFO",             -- 玩家整体数据
    [0xA0E3] = "MSG_GHOST_2018_QIANKT",             -- 打开乾坤图
    [0xA0E5] = "MSG_GHOST_2018_TIANJY",             -- 打开天机仪
    [0xA0E7] = "MSG_OPERATE_RESULT",                -- 播放成功、失败光效
    [0xB1F0] = "MSG_ASK_BUY_ONLINE_ITEM",      -- 购买商城道具消息
    [0x2FBB] = "MSG_BUY_FROM_MALL_RESULT",     -- 商城购买道具结果
    [0x821F] = "MSG_INN_TASK_DATA",            -- 客栈 - 通知客栈任务数据
    [0x8215] = "MSG_INN_ENTER_WORLD",          -- 客栈 - 玩家登录后，需要通知给客户端的信息

    [0xA210] = "MSG_FASION_CUSTOM_LIST",        -- 时装自定义界面信息
    [0xA215] = "MSG_FASION_FAVORITE_LIST",      -- 收藏柜数据
    [0xA220] = "MSG_FASION_FAVORITE_APPLY",     -- 收藏方案使用成功
    [0xA221] = "MSG_FASION_CUSTOM_END",         -- 时装操作完成
    [0xA222] = "MSG_FASION_CUSTOM_BEGIN",       -- 时装操作完成

    [0x508C] = "MSG_HOUSE_FURNITURE_DATA_PAGE", -- 家具列表

    [0x50D3] = "MSG_HERO_NPC_INFO",             -- 英雄阵，查看英雄留言
    [0x8227] = "MSG_UPLOAD_COMBAT_MESSAGE",     -- 通知客户端上传战斗消息，以便分析卡战斗的情况

    [0xD1A3] = "MSG_FINISH_NTMSL_TASK",             -- 通知客户端打开奖励界面 南天门试炼
    [0xD1A5] = "MSG_C_STOP_LIGHT_EFFECT",           -- 通知客户端停止战斗中光效
    [0xD1A7] = "MSG_COMBAT_LIGHT_EFFECT",           -- 通知播放战斗中循环光效
    [0xB1F3] = "MSG_L_START_LOGIN",                 -- 通知客户端开始登录

    [0x50E7] = "MSG_DETECTIVE_RANKING_INFO",        -- 十佳捕快排行榜
    [0x50E1] = "MSG_DETECTIVE_TASK_CLUE",           -- 卷宗数据
    [0x50E3] = "MSG_RKSZ_PAPER_MESSAGE",            -- 纸条数据

    [0xB1F4] = "MSG_TEACHER_2018_GAME_S2",          -- 2018 教师节拔草游戏开始
    [0xB1F9] = "MSG_TEACHER_2018_GAME_S2_END",          -- 2018 教师节拔草游戏结束
    [0xB1F6] = "MSG_TEACHER_2018_GAME_S6",          -- 2018 教师节答题游戏开始
    [0xB1FA] = "MSG_TEACHER_2018_GAME_S6_END",          -- 2018 教师节答题游戏结束

    [0x8219] = "MSG_TANAN_JHLL_GAME_XY",            -- 【探案】江湖绿林 - 开始、结束进行巡游
    [0x821B] = "MSG_TANAN_JHLL_GAME_GZ",            -- 【探案】江湖绿林 - 开始、结束进行跟踪
    [0x821D] = "MSG_TANAN_JHLL_GUA_YAO",            -- 【探案】江湖绿林 - 八卦爻的信息

    -- 探案-天外之谜
    [0xD1A9] = "MSG_TWZM_LETTER_DATA",               -- 通知信件界面提示信息(打开信件界面)
    [0xD1AB] = "MSG_TWZM_BOX_DATA",                  -- 通知盒子上的文字信息(打开盒子界面)
    [0xD1BB] = "MSG_TWZM_BOX_RESULT",                  -- 通知开锁结果
    [0xD1AD] = "MSG_TWZM_JIGSAW_DATA",                  -- 通知拼图信息(打开拼图界面)
    [0xD1AF] = "MSG_TWZM_START_PICK_PEACH",             -- 通知开始摘桃子游戏
    [0xD1B1] = "MSG_TWZM_QUIT_PICK_PEACH",             -- 通知摘桃子游戏结束或暂停
    [0xD1B3] = "MSG_TWZM_MATRIX_DATA",             -- 通知矩阵数字(打开矩阵界面)
    [0xD1B5] = "MSG_TWZM_MATRIX_RESULT",             -- 通知客户端矩阵结果
    [0xD1B7] = "MSG_TWZM_SCRIP_DATA",             -- 通知WIFI密码信息(打开WIFI密码界面)
    [0xD1B9] = "MSG_TWZM_CHUANYINFU",             -- 通知传音信息(打开传音符界面)

    [0xB1FD] = "MSG_GS_REBOOT",               -- GS 关机
    [0xA117] = "MSG_UPGRADE_INHERIT_PREVIEW",       -- 发送装备预览信息

    [0x504C] = "MSG_RECALL_USER_SCORE_DATA",       -- 活动结束后，可兑换积分时的活动数据 再续前缘
    [0x822B] = "MSG_FROZEN_SCREEN",                -- 通知客户端冻屏

    [0xB20B] = "MSG_CSQ_ALL_TIME",              -- 所有比赛的时间节点
    [0xB20D] = "MSG_CSQ_SCORE_RANK",            -- 积分排行榜数据
    [0xB20F] = "MSG_CSQ_SCORE_TEAM_DATA",       -- 请求积分排行榜上的队伍数据
    [0xB213] = "MSG_CSQ_MY_DATA",               -- 自己的全民PK数据
    [0xB215] = "MSG_CSQ_KICKOUT_TEAM_DATA",     -- 请求淘汰赛的队伍数据
    [0xB217] = "MSG_CSQ_KICKOUT_ALL_TEAM_DATA", -- 淘汰赛所有队伍数据
    [0xB203] = "MSG_CSQ_GM_REQUEST_CONTROL_INFO",  -- 控制结果数据
    [0xB208] = "MSG_CSQ_MATCH_TIME_INFO",       -- 比赛时间信息
    [0xD1C1] = "MSG_PREVIEW_RESONANCE_ATTRIB",       -- 通知客户端共鸣属性值
    [0xB216] = "MSG_CSQ_BONUS_INFO",            -- 奖励信息
    [0xB223] = "MSG_TEACHER_2018_CHANNEL",      -- 通知客户端求助消息 2018教师节
    [0x50D6] = "MSG_LEARN_UPPER_STD_SKILL_COST",    -- 精研技能信息

    [0x8223] = "MSG_NATIONAL_2018_SFQJ",    -- 2018 国庆节 - 四方棋局
    [0x8229] = "MSG_JIUTIAN_ZHENJUN",               -- 通知客户端九天真君的信息
    [0x50E9] = "MSG_DETECTIVE_TASK_CLUE_PARALLEL",    -- 卷宗数据 -- 并行线索

    -- 真假月饼
    [0xA0E9] = "MSG_AUTUMN_2018_GAME_START",    -- 通知开始游戏
    [0xA0EB] = "MSG_AUTUMN_2018_GAME_FINISH",   -- 通关提示

    [0x5190] = "MSG_AUTUMN_2018_DWW_PREPARE",    -- 大胃王 - 准备阶段
    [0x5192] = "MSG_AUTUMN_2018_DWW_START",      -- 大胃王 - 开始比赛
    [0x5195] = "MSG_AUTUMN_2018_DWW_PROGRESS",   -- 大胃王 - 比赛进度
    [0x5196] = "MSG_AUTUMN_2018_DWW_RESULT",     -- 大胃王 - 比赛结果

    -- 重阳-畅饮菊酒
    [0xA0EC] = "MSG_CHONGYANG_2018_GAME_START",   -- 通知客户端打开“饮酒界面”
    [0xA0EE] = "MSG_CHONGYANG_2018_GAME_BOOK",    -- 通知客户端打开“酒册界面”

    [0xD1BD] = "MSG_OBJECT_DISAPPEAR",            -- 通知对象淡化消失
    [0xD1C7] = "MSG_ZZQN_CARD_INFO",                -- 服务器通知客户端名片信息

    -- 灵音镇魔
    [0xB218] = "MSG_HALLOWMAX_2018_LYZM_STUDY",           -- 2018万圣节开始学习
    [0xB219] = "MSG_HALLOWMAX_2018_LYZM_STUDY_STOP",      -- 2018万圣节停止学习
    [0xB221] = "MSG_HALLOWMAX_2018_LYZM_GAME_ENTER",           -- 2018万圣节游戏进入
    [0xB21B] = "MSG_HALLOWMAX_2018_LYZM_GAME",            -- 2018万圣节开始游戏
    [0xB21C] = "MSG_HALLOWMAX_2018_LYZM_GAME_STOP",       -- 2018万圣节停止游戏

    [0x1FC3] = "MSG_CHECK_SERVER",                      -- 通知客户端校验结果
    [0xD1CB] = "MSG_QYGD_INFO_2018",                        -- 通知客户端情缘观点界面信息
    [0x5131] = "MSG_JIUTIAN_ZHENJUN_KILL_FIRST",            -- 九天首杀
    [0xB225] = "MSG_STRENGTHEN_JEWELRY_SUCC",            -- 首饰强化成功
    [0xB228] = "MSG_FASION_EFFECT_LIST",                -- 可购买特效列表
    [0xD1D1] = "MSG_FOLLOW_PET_VIEW",                   -- 通知跟随宠道具列表

    [0xD1CD] = "MSG_SXYS_QUESTION_INFO_2019",                -- 通知客户端题目     2019年寒假活动之赏雪吟诗
    [0xD1CF] = "MSG_SXYS_HIDE_DLG_2019",                   -- 通知客户端隐藏界面(显示吟诗效果) 2019年寒假活动之赏雪吟诗

    [0xD1D7] = "MSG_BWSWZ_START_GAME_2019",                -- 宝物守卫战-通知客户端进入游戏(过图后发送、更新结果时发送)

    [0xB22B] = "MSG_WINTER_2019_BX21D_DATA",            -- 比赛数据
    [0xB22F] = "MSG_WINTER_2019_BX21D_ENTER",           -- 进入游戏
    [0xB230] = "MSG_WINTER_2019_BX21D_CUR_ROUND",       -- 当前轮次（这条消息看下有没有必要）
    [0xB231] = "MSG_WINTER_2019_BX21D_BONUS",           -- 奖励数据

    [0xD115] = "MSG_NEW_PARTY_WAR",

    -- 2019寒假活动踩雪块
    [0xD1D9] = "MSG_CXK_START_GAME_2019",               -- 通知客户端进入游戏界面
    [0xD1DB] = "MSG_CXK_BONUS_INFO_2019",               -- 通知客户端奖励信息
    [0xD1D5] = "MSG_COMBAT_ACTION_RESULT",              -- 通知客户端战斗操作结果
    [0xD1D3] = "MSG_SELECT_COMMAND",                    -- 通知客户端阵营中成员选择了指令

    [0xB22A] = "MSG_SET_ACTION_STATUS_COMPLETE",        -- 设置动作状态结束

    -- 排队登录
    [0xB236] = "MSG_L_CHARGE_DATA",                     -- 返回充值数据
    [0xB239] = "MSG_L_CHARGE_LIST",                     -- 首充数据返回
    [0xB23C] = "MSG_L_LINE_DATA",                       -- 会员队列数据
    [0xB241] = "MSG_AAA_CHARGE_DATA_LIST",              -- 排队中充值奖励数据

    [0xB249] = "MSG_FRIEND_RECOMMEND_LIST",              -- 好友推荐列表
    [0xD1DD] = "MSG_FRIEND_AUTO_FIGHT_CONFIG",          -- 通知玩家队友自动战斗开关

    [0x50A7] = "MSG_HOUSE_PET_STORE_DATA",              -- 居所宠物仓库信息
    [0x50A8] = "MSG_HOUSE_SHOW_PET_STORE_LIST",         -- 居所前庭三只宠物的外观数据

    [0x50A9] = "MSG_EXCHANGE_EPIC_PET_SHOP",            -- 变异兑换神兽 - 商店界面
    [0x50AB] = "MSG_EXCHANGE_EPIC_PET_CHECK_EXIT",      -- 变异兑换神兽 - 重连时检测是否已经退出商店
    [0x50AD] = "MSG_EXCHANGE_EPIC_PET_SUBMIT_DLG",      -- 变异兑换神兽 - 通知打开提交界面

    [0xB246] = "MSG_MATCH_ADMIN_DATA",                  -- 赛事管理员数据
    [0xD1E1] = "MSG_MATCH_MAKING_QUERY_LIST",           -- 通知寻缘列表
    [0xD1E3] = "MSG_MATCH_MAKING_DETAIL",               -- 通知寻缘详细信息
    [0xD1E5] = "MSG_MATCH_MAKING_SETTING",              -- 通知寻缘个人设置信息
    [0xD1E7] = "MSG_C_UPDATE_DATA",                     -- 通过同步消息更新数据，不会走序列
    [0xD1E9] = "MSG_LC_UPDATE_DATA",                    -- 通过同步消息更新数据，不会走序列

    [0xB24B] = "MSG_GIVING_RECORD",             -- 发送赠送记录

    -- 2019春节-钟声祈福
    [0xB25D] = "MSG_SPRING_2019_ZSQF_START_GAME",  -- 打开敲钟游戏界面
    [0xB25F] = "MSG_SPRING_2019_ZSQF_OPEN",        -- 打开祈福界面
    [0xD1EB] = "MSG_MATCH_MAKING_FAVORITE_RET",         -- 通知修改收藏的结果
    [0xB268] = "MSG_SPRING_2019_ZSQF_QUIT_GAME",   -- 2019春节退出游戏

    [0x812B] = "MSG_GOLD_STALL_AUCTION_BID_GIDS",       -- 通知珍宝交易竞拍的商品
    [0x812F] = "MSG_GOLD_STALL_MY_BID_GOODS",           -- 珍宝通知我竞拍商品

    -- 2019 相约元霄
    [0x5029] = "MSG_PLAY_ENTER_ROOM_EFFECT",        -- 播放进入地图的特殊光效
    [0x502C] = "MSG_YUANXJ_2019_PLAY_AIXIN_EFFECT", -- NPC播放爱心光效
    [0x502E] = "MSG_YUANXJ_2019_PREPARE_DATA",      -- 准备数据

    [0xB261] = "MSG_SPRING_2019_XCXB_DATA",           -- 2019春节宝物数据
    [0xB265] = "MSG_SPRING_2019_XCXB_BONUS_DATA",     -- 2019春节奖励数据
    [0xB269] = "MSG_SPRING_2019_XCXB_USET_TOOL_FAIL", -- 2019春节使用工具失败
    [0xB26E] = "MSG_SPRING_2019_XCXB_BUY_DATA",       -- 2019春节购买界面数据
    [0xB270] = "MSG_SPRING_2019_XCXB_GET_BONUS",       -- 2019新春寻宝领取奖励
    [0x5214] = "MSG_OPEN_SHARE_FRIEND_DLG",     -- 打开分享好友界面

    [0xD1ED] = "MSG_REQUEST_LIST",             -- 通知客户端请求数据
    [0xB266] = "MSG_PET_ENCHANT_END",           -- 宠物点化完成

    [0x503A] = "MSG_COUNTDOWN",                     -- 倒计时
    [0x503C] = "MSG_VALENTINE_2019_EFFECT_DATA",     -- 2019 情人节采集玫瑰 - 神秘玉匣特殊效果

    [0xB26A] = "MSG_SPRING_2019_XTCL_START_GAME",       -- 开始游戏
    [0xB26B] = "MSG_SPRING_2019_XTCL_STOP_GAME",        -- 结束游戏

    [0x50EC] = "MSG_MXZA_SUBMIT_EXHIBIT_DLG",   -- 打开提交证物界面
    [0x50EB] = "MSG_MXZA_EXHIBIT_ITEM_LIST",   -- 迷仙镇案证物列表

    [0xD1F9] = "MSG_FIXED_TEAM_START_DATA",     -- 通知开始界面信息
    [0xD1FB] = "MSG_FIXED_TEAM_APPELLATION",    -- 通知称谓界面信息
    [0xD1FD] = "MSG_FIXED_TEAM_CHECK_DATA",     -- 通知确认界面信息
    [0xD1FF] = "MSG_FIXED_TEAM_FINISH_DATA",    -- 通知完成界面信息
    [0xD201] = "MSG_CANCEL_BUILD_FIXED_TEAM",   -- 通知取消缔结
    [0xD203] = "MSG_FIXED_TEAM_DATA",           -- 通知固定队信息
    [0xD205] = "MSG_FIXED_TEAM_OPEN_SUPPLY_DLG",-- 通知补充储备界面

    [0x50F2] = "MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST",         -- 个人招募，玩家自己的招募信息
    [0x50F3] = "MSG_FIXED_TEAM_RECRUIT_MY_SINGLE",           -- 个人招募信息列表
    [0x50F4] = "MSG_FIXED_TEAM_RECRUIT_SINGLE_DETAIL",       -- 个人招募详细信息
    [0x50F7] = "MSG_FIXED_TEAM_RECRUIT_MY_TEAM",             -- 组队招募，玩家自己队伍的招募信息
    [0x50F8] = "MSG_FIXED_TEAM_RECRUIT_TEAM_LIST",           -- 组队招募信息列表
    [0x50F9] = "MSG_FIXED_TEAM_RECRUIT_TEAM_DETAIL",         -- 组队招募详细信息
    [0x50FA] = "MSG_FIXED_TEAM_RECRUIT_TALK",                -- 需要联系的对象
    [0x50FC] = "MSG_FIXED_TEAM_CHECK",                       --
    [0x50FD] = "MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST_EX",      --
    [0x50FE] = "MSG_FIXED_TEAM_RECRUIT_TEAM_LIST_EX",        --

    [0xB273] = "MSG_SHOW_RECONNECT_PARA", -- 显示角色列表的参数
    [0xB281] = "MSG_L_GET_COMMUNITY_ADDRESS", -- 返回微社区的地址

    [0xB288] = "MSG_TTT_NEW_XING",                           -- 当前通天塔的星君

    [0x503C] = "MSG_VALENTINE_2019_EFFECT_DATA",    -- 2019 情人节采集玫瑰 - 神秘玉匣特殊效果
    [0x5198] = "MSG_ZHISJJUMCL_ROOM_EFFECT",        -- 2019植树节活动-聚木成林 房间光效

    [0x822F] = "MSG_BJTX_FIND_FRIEND",                  -- 并肩同行 - 通知匹配信息
    [0x8231] = "MSG_BJTX_WELFARE",                      -- 并肩同行 - 通知福利界面信息

    [0xB271] = "MSG_MAP_DECORATION_APPEAR",         -- 地图摆件出现
    [0xB272] = "MSG_MAP_DECORATION_DISAPPEAR",      -- 地图摆件消失
    [0xB279] = "MSG_MAP_DECORATION_START",          -- 开始摆件
    [0xB27B] = "MSG_MAP_DECORATION_FINISH",         -- 结束摆件
    [0xB27D] = "MSG_MAP_DECORATION_RESULT",         -- 操作的结果
    [0xB27F] = "MSG_MAP_DECORATION_CHECK",         -- 检查是否是自己的摆件

    [0xD211] = "MSG_FOOLS_DAY_2019_START_GAME",    -- 通知开始饮酒

    [0xD213] = "MSG_NOTIFY_SCREEN_FADE",           -- 通知客户端黑幕淡入淡出

    [0xB286] = "MSG_2019ZNQFP_START",               -- 2019周年庆萌猫翻牌开始
    [0xB282] = "MSG_2019ZNQFP_BONUS",               -- 2019周年庆萌猫翻牌奖励
    [0xB283] = "MSG_2019ZNQFP_FINISH",              -- 2019周年庆萌猫翻牌结束

    [0xD215] = "MSG_SMDG_START_GAME",               -- 通知客户端打开迷宫界面
    [0xD217] = "MSG_SMDG_TRIGGER_EVENT",            -- 回复客户端触发事件(剧本播放结束后发送此消息)
    [0xD21B] = "MSG_SMDG_FINISH_GAME",              -- 通知客户端结算界面
    [0xB28B] = "MSG_DW_2019_KWDZ",                  -- 2019端午节口味大战数据

    [0x51A2] = "MSG_2019ZNQ_CWTX_DATA",             -- 秘境探险 游戏数据
    [0x51A6] = "MSG_2019ZNQ_CWTX_CLICK",            -- 点击格子的反馈，用于动画播放
    [0x51A7] = "MSG_2019ZNQ_CWTX_ACT_LOG",
	[0xD21D] = "MSG_CHILD_DAY_2019_START_GAME",     -- 2019儿童节护送小龟 通知客户端开始护送小龟游戏
    [0xD21F] = "MSG_CHILD_DAY_2019_STOP_GAME",      -- 2019儿童节护送小龟 通知客户端停止游戏（收到此消息后，客户端再按设定进行清理操作）
    [0xD221] = "MSG_CHILD_DAY_2019_EVENT_RESULT",   -- 2019儿童节护送小龟 通知客户端触发事件结果
    [0xD24D] = "MSG_CHILD_DAY_2019_DATA",           -- 2019儿童节护送小龟 重连时，服务器通知客户端实时的游戏数据

    [0x5055] = "MSG_TEAM_COMMANDER_CMD_LIST",       -- 队伍指挥 - 通知自定义命令
    [0x5058] = "MSG_TEAM_COMMANDER_GID",            -- 队伍指挥 - 拥有指挥权限的玩家
    [0x505A] = "MSG_TEAM_COMMANDER_COMBAT_DATA",    -- 战斗中的队伍指挥数据

    [0xB28C] = "MSG_ZNQ_LOGIN_GIFT_2019",           -- 2019 周年庆登陆礼包数据

    [0xB28F] = "MSG_DW_2019_ZDBC_DATA",             -- 2019 智斗百草游戏数据
    [0xD223] = "MSG_OPEN_TTLP_DLG",                 -- 通知客户端打开通天令牌界面
    [0xD225] = "MSG_TONGTIANTADING_XINGJUN_LIST",   -- 通知通天塔顶信息

    [0xD229] = "MSG_BATTLE_ARRAY_INFO",                      -- 通知客户端战斗中阵法信息
    [0x5132] = "MSG_PET_ICON_UPDATED",

    [0x5133] = "MSG_SMFJ_BXF_START_GAME",           -- 通天塔神秘房间     变戏法开始
    [0x5135] = "MSG_SMFJ_YLMB_STEP_LIST",           -- 神秘房间 - 幽灵漫步步骤列表
    [0x5136] = "MSG_SMFJ_YLMB_START_GAME",          -- 神秘房间 - 幽灵漫步开始
    [0x5138] = "MSG_SMFJ_YLMB_MOVE_STEP",           -- 神秘房间 - 幽灵漫步移动
    [0x513A] = "MSG_SMFJ_GAME_STATE",               -- 神秘房间 - 通用的游戏状态

    [0x513D] = "MSG_SMFJ_SWZD_STEP_LIST",           -- 手舞足蹈步骤列表

    [0x513F] = "MSG_SMFJ_SWZD_MOVE_STEP",           -- 手舞足蹈步骤列表
    [0x513C] = "MSG_SMFJ_BSWH_PLAYER_ICON",         -- 玩家变身形象
    [0x5140] = "MSG_SMFJ_CJDWW_PROGRESS",           -- 神秘房间 - 超级大胃王
    [0x5141] = "MSG_SMFJ_CJDWW_OPER_USER",          -- 神秘房间 - 超级大胃王 - 当前操作的玩家
    [0x5143] = "MSG_TTT_GJ_NEW_XING",               -- 使用高级通天令牌
    [0x5106] = "MSG_PET_FASION_CUSTOM_LIST",              -- 宠物时装信息
    [0xD22B] = "MSG_SHNTM_FAIL",                    -- 通知客户端守护南天门失败，需要播放冲破南天门效果

    [0xD22D] = "MSG_AUTO_WALK_LINE",                -- 服务器通知客户端自动寻路线路
    [0xD22F] = "MSG_HTTP_TOKEN",                    -- 通知 https 登录信息

    [0xB295] = "MSG_SUMMER_2019_SMSZ_SMHJ",              -- 2019 暑假神秘数字之神秘画卷数据
    [0xB29D] = "MSG_SUMMER_2019_SMSZ_SMHJ_RESULT",              -- 2019 暑假神秘数字之神秘画卷结果
    [0xB298] = "MSG_SUMMER_2019_SMSZ_SMBH",              -- 2019 暑假神秘数字之神秘宝盒数据
    [0xB29C] = "MSG_SUMMER_2019_SMSZ_SMBH_RESULT",       -- 2019 暑假神秘数字之神秘宝盒结果

    [0x51B0] = "MSG_SPOT_ENABLE",                     -- 当前是否开放货站功能
    [0x51B2] = "MSG_TRADING_SPOT_DATA",               -- 响应货站数据
    [0x51B4] = "MSG_TRADING_SPOT_COLLECT",            -- 收藏结果
    [0x51B6] = "MSG_TRADING_SPOT_GOODS_LINE",         -- 最近10期走势图
    [0x51B7] = "MSG_TRADING_SPOT_GOODS_RANGE",        -- 历史涨跌
    [0x51B8] = "MSG_TRADING_SPOT_GOODS_RECORD",       -- 特定商品的盈亏记录
    [0x51BA] = "MSG_TRADING_SPOT_PROFIT",             -- 上期盈亏 or 历史盈亏
    [0x51BD] = "MSG_TRADING_SPOT_GOODS_CARD",         -- 商品名片
    [0x51BE] = "MSG_TRADING_SPOT_UPDATE_MONEY",       -- 货站账户余额
    [0x51C3] = "MSG_TRADING_SPOT_CHAR_BID_INFO_CARD", -- 买入方案名片数据
    [0x51C0] = "MSG_TRADING_SPOT_RANK_LIST",          -- 十人巨商
    [0x51C6] = "MSG_TRADING_SPOT_CARD_GOODS_LIST",    -- 买过商品列表

    [0x8237] = "MSG_CSML_ROUND_TIME",                -- 通知客户端比赛时间  跨服战场2019
    [0x8239] = "MSG_CSML_ALL_SIMPLE",               -- 通知客户端联赛所有简要信息 跨服战场2019
    [0x823B] = "MSG_CSML_LEAGUE_DATA",              -- 通知客户端具体赛区的数据 跨服战场2019
    [0x823D] = "MSG_CSML_MATCH_SIMPLE",             -- 通知客户端具体比赛简要数据 跨服战场2019
    [0x823F] = "MSG_CSML_MATCH_DATA",               -- 通知客户端具体比赛数据  跨服战场2019
    [0x8241] = "MSG_CSML_CONTRIB_TOP_DATA",         -- 通知客户端个人总积分数据 跨服战场2019
    [0x8245] = "MSG_CSML_FETCH_BONUS",

    [0x8235] = "MSG_CSML_LIVE_SCORE",               -- 服务器通知客户端战场实时数据
    [0x8243] = "MSG_CSML_MATCH_DATA_COMPETE",             -- 战场中通知个人积分榜信息

    -- 商贾货站玩法-讨论
    [0x51D1] = "MSG_BBS_UPDATE_ONE_STATUS",         -- 状态数据
    [0x51D3] = "MSG_BBS_DELETE_ONE_STATUS",         -- 通知删除状态成功
    [0x51D5] = "MSG_BBS_REQUEST_STATUS_LIST",       -- 通知状态列表
    [0x51D7] = "MSG_BBS_REQUEST_LIKE_LIST",         -- 某条状态的所有点赞玩家数据
    [0x51D9] = "MSG_BBS_OPEN_COMMENT_DLG",          -- 通知打开评论窗口
    [0x51DB] = "MSG_BBS_UPDATE_ONE_COMMENT",        -- 评论数据
    [0x51DF] = "MSG_BBS_ALL_COMMENT_LIST",          -- 通知所有评论数据
    [0x51E3] = "MSG_BBS_LIKE_ONE_STATUS",           -- 点赞成功
    [0x51C2] = "MSG_TRADING_SPOT_BBS_CATALOG_LIST", -- 货站讨论区帖子列表

    [0xB2A0] = "MSG_SUMMER_2019_SSWG_ENTER",        -- 2019 暑假活动之谁是乌龟进入游戏
    [0xB2A1] = "MSG_SUMMER_2019_SSWG_DATA",         -- 2019 暑假活动之谁是乌龟游戏数据
    [0xB2A7] = "MSG_SUMMER_2019_SSWG_BONUS",        -- 2019 暑假活动之谁是乌龟奖励信息

    [0xD231] = "MSG_SUMMER_2019_BHKY_START",        -- 2019 暑假活动之冰火考验开始游戏
    [0xB2A8] = "MSG_SUMMER_2019_SXDJ_ENTER",        -- 2019年暑假活动之生肖对决 进入游戏
    [0xB2A9] = "MSG_SUMMER_2019_SXDJ_DATA",         -- 2019年暑假活动之生肖对决 游戏数据
    [0xB2AA] = "MSG_SUMMER_2019_SXDJ_OPERATOR",     -- 2019年暑假活动之生肖对决 通知操作
    [0xB2AC] = "MSG_SUMMER_2019_SXDJ_DO_ACTION",    -- 2019年暑假活动之生肖对决 通知动作
    [0xB2AD] = "MSG_SUMMER_2019_SXDJ_CHANGE_STATUS",        -- 2019年暑假活动之生肖对决 切换状态
    [0xB2AF] = "MSG_SUMMER_2019_SXDJ_BONUS",        -- 2019年暑假活动之生肖对决 奖励信息
    [0xB2C3] = "MSG_SUMMER_2019_SXDJ_FAIL",               -- 暑假活动之生肖对决操作失败

    [0x51F0] = "MSG_WQX_QUESTION_DATA",             -- 文曲星 - 问题信息
    [0x51F6] = "MSG_WQX_STAGE_RESULT",              -- 文曲星 - 闯关结果
    [0x51F9] = "MSG_WQX_HELP_QUESTION_DATA",        -- 文曲星 - 帮助好友答题的题目数据

    [0xB2C1] = "MSG_PET_EXPLORE_OPEN_DLG",              -- 宠物探索小队 - 打开界面
    [0xB2B1] = "MSG_PET_EXPLORE_ALL_PET_DATA",          -- 宠物探索小队 - 所有宠物数据
    [0xB2BB] = "MSG_PET_EXPLORE_ONE_PET_DATA",          -- 宠物探索小队 - 单只宠物数据
    [0xB2B4] = "MSG_PET_EXPLORE_ALL_ITEM_DATA",         -- 宠物探索小队 - 所有探险技能升级道具
    [0xB2B6] = "MSG_PET_EXPLORE_MAP_BASIC_DATA",        -- 宠物探索小队 - 地图基础数据
    [0xB2B7] = "MSG_PET_EXPLORE_ONE_MAP_DATA",          -- 宠物探索小队 - 单张地图数据
    [0xB2BD] = "MSG_PET_EXPLORE_MAP_PET_DATA",          -- 宠物探索小队 - 地图宠物数据
    [0xB2BF] = "MSG_PET_EXPLORE_MAP_CONDITION_DATA",    -- 宠物探索小队 - 地图条件数据
    [0xB2C0] = "MSG_PET_EXPLORE_START",                 -- 宠物探索小队 - 开始探索，用于客户端播放开始动画
    [0xB2BA] = "MSG_PET_EXPLORE_BONUS",                 -- 宠物探索小队 - 奖励信息

    [0xD2A1] = "MSG_USE_YLJH",                      -- 通知房间玩家播放特效
    [0xD233] = "MSG_XCWQ_DATA",                     -- 通知场景信息
    [0xD235] = "MSG_XCWQ_MASSAGE_BACK",             -- 广播捶背动作
    [0xD237] = "MSG_XCWQ_THROW_SOAP",               -- 广播丢肥皂动作
    [0xD239] = "MSG_XCWQ_ACTION_FAIL",              -- 通知动作失败（客户端解除移动限制）
    [0xD23D] = "MSG_XCWQ_RECORD",                   -- 通知客户端互动信息（按时间由早到晚）
    [0xD23F] = "MSG_XCWQ_ONE_RECORD",               -- 通知单次互动信息（只对互动双方发送）
    [0xD23B] = "MSG_XCWQ_OPEN_YLJH_DLG",            -- 通知打开玉露精华界面
    [0x5E14] = "MSG_REENTRY_ASKTAO_RECHARGE_DATA",  -- 回归累充活动数据

    [0xD241] = "MSG_LINGCHEN_DATA",                 -- 通知灵尘商店信息
    [0xD243] = "MSG_DECOMPOSE_ITEM_RESULT",         -- 通知分解结果

    -- 小舟竞赛
    [0xD247] = "MSG_SUMMER_2019_XZJS_DATA",         -- 通知游戏数据
    [0xD245] = "MSG_SUMMER_2019_XZJS_FRAME",        -- 通知游戏帧数据
    [0xD24B] = "MSG_SUMMER_2019_XZJS_OPERATE",      -- 通知客户端当前执行指令状态（指令重刷或重连时发送）
    [0xD249] = "MSG_SUMMER_2019_XZJS_RESULT",       -- 通知游戏结果
    [0xD22D] = "MSG_AUTO_WALK_LINE",                -- 服务器通知客户端自动寻路线路
    [0xD22F] = "MSG_HTTP_TOKEN",                    -- 通知 https 登录信息
    [0x5E14] = "MSG_REENTRY_ASKTAO_RECHARGE_DATA",  -- 回归累充活动数据

    [0xB2C6] = "MSG_NEW_DIST_PRECHARGE_DATA",       -- 新服预充值界面数据
    [0xB2C7] = "MSG_L_GOLD_COIN_DATA",       -- AAA 通知玩家元宝数据
    [0xB2CA] = "MSG_L_INSIDER_ACT_DATA",     -- AAA 返回会员打折活动数据

    [0xD275] = "MSG_OPEN_TO_TIP_MOUNT",      -- 通知客户端打开坐骑界面并显示光效
    [0x5221] = "MSG_GOOD_VOICE_SHOW_LIST",          -- 查看声音结果
    [0x5223] = "MSG_GOOD_VOICE_QUERY_VOICE",        -- 声音详情数据
    [0x5225] = "MSG_GOOD_VOICE_COLLECT",            -- 收藏结果
    [0x5229] = "MSG_GOOD_VOICE_MY_VOICE",           -- 我的声音
    [0x522C] = "MSG_GOOD_VOICE_SEASON_DATA",        -- 赛季信息
    [0x5231] = "MSG_GOOD_VOICE_JUDGES",             -- 评委列表
    [0x5233] = "MSG_GOOD_VOICE_FINAL_VOICES",       -- 终选的声音数据
    [0x5236] = "MSG_GOOD_VOICE_SCORE_DATA",         -- 声音评分数据
    [0x5238] = "MSG_GOOD_VOICE_RANK_LIST",          -- 排行榜数据
    [0x5239] = "MSG_GOOD_VOICE_BE_DELETED",         -- 声音已经失效
    [0x523E] = "MSG_LEAVE_MESSAGE_WRITE",           --
    [0x5240] = "MSG_LEAVE_MESSAGE_DELETE",
    [0x523C] = "MSG_LEAVE_MESSAGE_LIST",
    [0x5243] = "MSG_LEAVE_MESSAGE_LIKE",            -- 点赞成功

    [0x8247] = "MSG_HOUSE_SEX_LOVE_ANIMATE",       -- 通知客户端播放夫妻之礼动画

    [0xD24F] = "MSG_CHILD_INFO",                    -- 通知娃娃界面信息
    [0xD251] = "MSG_CHILD_LOG",                     -- 通知娃娃日志信息
    [0xD253] = "MSG_CHILD_SING",                    -- 通知播放唱歌动画
    [0xD255] = "MSG_CHILD_INJECT_ENERGY",           -- 通知客户端找到灵石并注入能量

    [0xD257] = "MSG_CHILD_BIRTH_INFO",              -- 通知妻子生产数据
    [0xD259] = "MSG_CHILD_BIRTH_HUSBAND_INFO",      -- 通知丈夫生产数据
    [0xD25B] = "MSG_CHILD_BIRTH_RESULT",            -- 通知生产结果
    [0xD25D] = "MSG_CHILD_BIRTH_STONE",             -- 通知客户端寻路到灵石旁并选择灵胎出世
    [0xD25F] = "MSG_CHILD_BIRTH_ANIMATE",           -- 通知客户端接生动画

    [0xD261] = "MSG_CHILD_RAISE_INFO",              -- 通知娃娃抚养信息
    [0xD263] = "MSG_CHILD_SCHEDULE",                -- 通知客户端历史行程
    [0xD265] = "MSG_START_COMMON_PROGRESS",          -- 通知播放抚养操作进度条
    [0xD267] = "MSG_PLAY_EFFECT_DIGIT",             -- 通知客户端飘字
    [0xD269] = "MSG_CHILD_CHECK_SCHEDULE_RESULT",   -- 通知行程检测结果
    [0xD26B] = "MSG_CHILD_CHECK_CHANGE_SCHEDULE_RET",   -- 检测能否修改行程结果
    [0xD26D] = "MSG_CHILD_POSITION",                -- 通知娃娃位置信息

    [0xD273] = "MSG_CHILD_LIST",                    -- 通知玩家娃娃列表
    [0xD277] = "MSG_PLAY_EFFECT",                   -- 通知播放特效

    [0xD275] = "MSG_OPEN_TO_TIP_MOUNT",      -- 通知客户端打开坐骑界面并显示光效
    [0xD271] = "MSG_CHILD_MONEY",                   -- 通知娃娃金库金钱信息
    [0xD279] = "MSG_QIXI_2019_LMQG_INFO",           -- 通知游戏基本信息(进入游戏或重连时发送)
    [0xD27B] = "MSG_QIXI_2019_LMQG_REFRESH",        -- 服务器通知材料刷新(每3秒发送)
    [0xD27D] = "MSG_QIXI_2019_LMQG_SCORE",          -- 服务器通知更新分数
    [0x8249] = "MSG_MAIL_NOT_EXIST",                -- 通知客户端该邮件不存在
    [0xB2CD] = "MSG_ENABLE_COMMUNITY",              -- 是否开启 oppo 社区
    [0xB2CE] = "MSG_CHECK_SHUADAO_BONUS",           -- 检查是否存在刷道奖励

    [0xD27F] = "MSG_CHILD_JOIN_FAMILY",          -- 通知娃娃拜师
    [0xD281] = "MSG_CHILD_JOIN_FAMILY_SUCC",     -- 通知娃娃拜师成功
    [0x5218] = "MSG_NEW_DIST_CHONG_BANG_DATA",      -- 新服盛典活动数据
    [0x5245] = "GOOD_VOICE_FINAL_SHOW_DATA_FOR_JUDGE",
    [0xB2CF] = "MSG_SF_LOGIN_CHAR_FAIL",

    [0xB2D0] = "MSG_CHOOSE_FASION_LIST",            -- 可选择的时装列表
    [0xD2A5] = "MSG_OFFICIAL_DIST",                 -- 通知客户端当前是否官方区组
    [0x51C8] = "MSG_TRADING_SPOT_GOODS_VOLUME",     -- 全服买入总额
    [0x51CA] = "MSG_TRADING_SPOT_LARGE_ORDER_DATA", -- 大额买单数据
    [0x824B] = "MSG_SET_CHILD_OWNER",            -- 设置娃娃的拥有者
    [0x824D] = "MSG_UPDATE_CHILDS",              -- 更新娃娃数据
    [0x824F] = "MSG_SET_COMBAT_CHILD",           -- 参战娃娃 id
    [0x8251] = "MSG_SET_VISIBLE_CHILD",          -- 可见娃娃 id
    [0x8253] = "MSG_CHILD_PRE_ASSIGN_ATTRIB",    -- 准备分配属性比例

    [0xD283] = "MSG_CHILD_START_GAME",              -- 通知客户端开始游戏
    [0xD287] = "MSG_CHILD_GAME_RESULT",             --
    [0xD289] = "MSG_CHILD_GAME_SCORE",
    [0xD28B] = "MSG_CHILD_CLICK_TASK_LOG",

    [0xD28F] = "MSG_CHILD_CULTIVATE_INFO",         -- 通知修炼界面数据
    [0xD29B] = "MSG_HOUSE_TDLS_MENU",               --通知客户端灵石菜单
    [0x5251] = "MSG_CHILD_UPGRADE_PRE_INFO",        -- 娃娃飞升预览
    [0x5252] = "MSG_CHILD_UPGRADE_SUCC",            -- 娃娃飞升成功
    [0xD28D] = "MSG_CHILD_STOP_GAME",
    [0xD2A3] = "MSG_CHILD_CARD_INFO",               -- 服务器返回娃娃名片信息
}


return Msg
