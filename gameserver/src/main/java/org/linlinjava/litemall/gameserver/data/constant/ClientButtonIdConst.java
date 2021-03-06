package org.linlinjava.litemall.gameserver.data.constant;

public class ClientButtonIdConst {
    public static final int CHAR_RENAME = 1;  // 角色改名
    public static final int DROP_TASK = 2;  // 放弃任务
    public static final int GET_RANK_INFO = 3;  // 获取排行榜数据
    public static final int DELETE_STONE_ATTRIB = 4;  // 删除妖石属性
    public static final int DELETE_GODBOOK_SKILL = 5;  // 删除宠物天书技能
    public static final int CALL_GUARD = 6;  // 召唤守护
    public static final int EQUIP_IDENTIFY = 7;  // 装备鉴定
    public static final int GUARD_USE_SKILL_D = 8;  // 守护是否使用辅助技能
    public static final int GUARD_SAVE_GROW = 9;  // 是否保存守护培养属性
    public static final int WHETHER_BUY_ITEM = 10; // 道具不足，询问玩家是否购买道具
    public static final int WHETHER_EXCHAGE_CASH = 11; // 游戏币不足，询问玩家是否兑换游戏币
    public static final int WHETHER_BUY_GOLD = 12; // 元宝不足，询问玩家是否充值
    public static final int NOTIFY_CLIENT_STATUS = 16; // 客户端状态，如未激活、已激活但长时间无输入、正常等
    public static final int GET_RECOMMEND_ATTRIB = 26; // 请求推荐属性加点设置(notify.h)
    public static final int GET_RECOMMEND_POLAR = 44; // 请求推荐相性加点设置(notify.h)
    public static final int NOTIFY_OPEN_DLG = 97; // 打开对话框
    public static final int NOTIFY_CLOSE_DLG = 98; // 关闭对话框
    public static final int RECOMMEND_FRIEND = 13; // 请求推荐好友列表
    public static final int VERIFY_FRIEND = 14; // 通过邮件系统发验证消息给对应的玩家
    public static final int GET_CHAR_INFO = 15; // 获取指定角色的信息，用于显示角色操作菜单
    public static final int NOTIFY_FETCH_DOUBLE_POINTS = 17; // 领取双倍点数
    public static final int NOTIFY_FROZEN_DOUBLE_POINTS = 18; // 冻结双倍点数
    public static final int NOTIFY_BUY_DOUBLE_POINTS = 19; // 购买双倍点数
    public static final int NOTIFY_START_AUTO_PRACTICE = 20; //开始自动练功
    public static final int NOTIFY_OPEN_ARENA = 21;     // 打开竞技场界面
    public static final int NOTIFY_ARENA_TOP_BONUS_LIST = 22;   // 获取竞技场历史最高排名奖励列表
    public static final int NOTIFY_FETCH_ARENA_RANK_BONUS = 23; // 领取竞技场排名奖励 para1 为要领取的 rank
    public static final int NOTIFY_FETCH_ARENA_TIME_BONUS = 24; // 领取竞技场累计排名奖励
    public static final int NOTIFY_OPEN_ARENA_SHOP = 25;        // 打开竞技场商店
    public static final int NOTIFY_ARENA_CHALLENGE = 27;        // 竞技场挑战对手 para1 为 key
    public static final int NOTIFY_ARENA_REFRESH_OPPONENTS = 28;// 刷新竞技场对手列表
    public static final int NOTIFY_ARENA_BUY_TIMES = 29;        // 购买竞技场挑战次数
    public static final int NOTIFY_ARENA_REFRESH_SHOP = 30;     // 刷新竞技场商店
    public static final int NOTIFY_ARENA_BUY_ITEM = 31;         // 购买竞技场商店中的物品 para1 = key
    public static final int NOTIFY_GET_LIVENESS_INFO = 32;      // 获取活跃度信
    public static final int NOTIFY_FETCH_LIVENESS_BONUS = 33;   // 领取活跃度奖励 para1 为奖励对应的活跃度
    public static final int NOTIFY_SHOW_RANK_PET = 34;          // 获取排行榜中的宠物信息，用于显示宠物名片
    public static final int NOTIFY_SEND_INIT_DATA_DONE = 39;   // 服务器通知客户端角色数据发送完成
    public static final int NOTIFY_LEVEL_UP_PARTY = 41;         // 升级帮派
    public static final int NOTIFY_FINISH_ALCHEMY = 46;         // 完成炼丹
    public static final int NOTIFY_EQUIP_REFORM_OK = 49;        // 重组成功
    public static final int NOTIFY_EQUIP_REFINE_OK = 50;        // 炼化成功
    public static final int NOTIFY_EQUIP_STRENGTHEN_OK = 51;        // 强化成功
    public static final int NOTIFY_ENABLE_DOUBLE_POINTS = 52;        // 开启双倍点数
    public static final int NOTIFY_EQUIP_RESONANCE_OK = 53;    // 装备共鸣成功
    public static final int NOTIFY_EQUIP_UPGRADE_INHERIT_OK = 54; // 装备继承成功
    public static final int NOTIFY_FETCH_MINFO = 100;          // 获取信息
    public static final int NOTIFY_OPEN_CHILD_DLG_BY_TOY = 101;          // 通过玩具打开培养界面
    public static final int NOTIFY_BAOZANG_READY_SEARCH = 10001;        // 藏宝图
    public static final int NOTIFY_OPEN_STORE = 10002;        // 打开仓库
    public static final int NOTIFY_CLOSE_STORE = 10003;        // 关闭仓库
    public static final int NOTIFY_CLOSE_PARTY = 10006;        // 关闭帮派相关对话框
    public static final int NOTIFY_FAST_ADD_EXTRA = 10007;        // 快速添加生命、法力、忠诚储备
    public static final int NOTIFY_QUERY_TEAM_EX_INFO = 10008;        // 查询组队信息
    public static final int NOTIFY_BAXIAN_RESET = 11001;        // 重置八仙梦境
    public static final int NOTIFY_BAXIAN_ENTER = 11002;        // 进入八仙梦境
    public static final int NOTIFY_FEED_STONE_OK = 12000;        // 打入妖石、补充妖石成功
    public static final int GET_EXERCISE = 20000;    // 获取修炼的当前轮数
    public static final int NOTICE_GET_ITEM_SUCCESS = 20006; // 天技商店获得物品对话框
    public static final int NOTICE_COMBAT_STATUS_INFO = 20007; // 获取战斗状态
    public static final int NOTIFY_AUTO_DISCONNECT = 20011; // 启动自动断线
    public static final int NOTIFY_QUERY_TEAM_INFO = 20012; // 查询周围玩家/队伍信息  参数"around_player"   "around_team"
    public static final int NOTIFY_QUERY_PARTY_SHOUWEI = 20015; // 查询帮派守卫信息
    public static final int NOTIFY_QUERY_PARTY_HANGBARUQIN = 20016; // 查询帮入侵
    public static final int NOTIFY_CHAR_CHANGE_SEX = 20025; // 改性别
    public static final int NOTIFY_SUBMIT_NANHWS = 20026; // 南荒巫术提交变身卡
    public static final int NOTIFY_EQUIP_EVOLVE_OK = 20027; // 装备进化结果，刷新界面
    public static final int NOTIFY_FETCH_REENTRY_ASKTAO = 20028; // 再续前缘，0抽奖1领奖
    public static final int NOTIFY_FETCH_LIVENESS_LOTTERY = 20029; // 活跃度抽奖，0抽奖1领奖
    public static final int NOTIFY_FETCH_FESTIVAL_LOTTERY = 20030; // 节日活动抽奖
    public static final int NOTIFY_CLOSE_GIFT_DLG = 20033; // 关闭福利界面
    public static final int NOTIFY_EQUIP_DEGENERATION_OK = 20035; // 装备退化结果
    public static final int NOTIFY_LOOK_PLAYER_EQUIP = 40005;   // 查看玩家装备
    // 刷道
    public static final int NOTIFY_SHUADAO_OPEN_INTERFACE = 30002;   // 打开刷道界面
    public static final int NOTIFY_SHUADAO_SET_OFFLINE = 30003;   // 设置离线刷道
    public static final int NOTIFY_SHUADAO_BUY_OFFLINE_TIME = 30004;   // 购买离线刷道时间
    public static final int NOTIFY_SHUADAO_DO_BONUS = 30005;   // 领取离线刷道奖励
    public static final int SELL_ITEM = 30006;   // 出售物品
    public static final int NOTIFY_SET_COMBAT_GUARD = 30010;   // 设置参战守护
    public static final int NOTIFY_REMOVE_ALL_INVITE = 30011;   // 清除所有邀请
    public static final int NOTIFY_REMOVE_ALL_JOIN = 30012;   // 清除所有申请
    public static final int NOTIFY_REQUEST_MATCH_SIZE = 30013;   // 请求匹配队员与数量
    public static final int NOTIFY_RANK_ME_INFO = 30017;   // 请求排行榜我的信息
    public static final int NOTIFY_RANK_GET_GUARD = 30018;   // 请求排行榜守护
    public static final int NOTIFY_RANK_GET_EQUIP = 30019;   // 请求排行榜装备
    public static final int NOTIFY_SUBMIT_PET = 30020;   // 任务提交宠物
    public static final int NOTIFY_SET_LOCK_EXP = 30024;   // 经验锁
    public static final int NOTIFY_SHUADAO_SET_JIJI = 30029;   // 急急如律令
    public static final int NOTIFT_JOIN_PARTY_WAR = 30042;   // 参加帮战
    public static final int NOTIFY_REQUSET_PW_BATTLE_INFO = 30043;   // 查询帮战中双方信息
    public static final int NOTIFY_GET_TEAM_DATA = 30044;   // 查询已个队伍信息
    // 通天塔
    public static final int NOTIFY_TTT_GET_BONUS = 40000;   // 通天塔领取奖励
    public static final int NOTIFY_TTT_DO_REVIVE = 40001;   // 通天塔请求复活
    public static final int NOTIFY_TTT_JISU_FEISHENG = 40002;   // 通天塔急速飞升  元宝
    public static final int NOTIFY_TTT_KUAISU_FEISHENG = 40003;   // 通天塔快速飞升 金钱
    public static final int NOTIFY_TTT_JUMP_ASSURE = 30025;   // 通天塔飞升确认
    public static final int NOTIFY_TTT_JUMP_CANCEL = 30026;   // 通天塔飞升取消
    public static final int NOTIFY_TTT_RESET_TASK = 40004;   // 通天塔重置任务
    public static final int NOTIFY_TTT_GO_NEXT_LAYER = 40006;   // 通天塔挑战下层
    public static final int NOTIFY_TTT_LEAVE_TOWER = 40007;   // 通天塔离开塔
    // 变异宠物
    public static final int NOTICE_BUY_ELITE_PET = 50001;   // 成功购买变异宠物
    public static final int NOTIFY_PARTY_WAR_SCORE = 50002;   // 帮战请求分数
    public static final int NOTIFY_PARTY_WAR_INFO = 50003;   // 帮战切换界面请求数据
    // 首充
    public static final int NOTIFY_FETCH_SHOUCHONG_GIFT = 50009;   // 领取首充
    public static final int NOTIFY_REQUEST_REBATE_INFO = 50010;   // 首充状态
    public static final int NOTIFY_REQUEST_LOTTERY_INFO = 50014;   // 请求首充抽奖奖品
    public static final int NOTIFY_DRAW_LOTTERY = 50011;   // 通知服务器抽奖
    public static final int NOTIFY_CANCEL_LOTTERY = 50013;   // 通知服务器取消抽奖
    public static final int NOTIFY_FETCH_LOTTERY = 50012;   // 通知服务器领奖
    public static final int NOTIFY_FETCH_DONE = 50015;   // 领奖成功
    public static final int NOTIFY_PW_AREA_NO_DATA = 50016;   // 帮战该赛区没有数据
    public static final int NOTIFY_IOS_REVIEW = 50017;   // IOS评审信息
    public static final int NOTIFY_PW_OPEN_WINDOW = 50018;   // 请求打开帮战相关对话框 "1"报名  "2"本届赛程 "3"历届
    // 聊天频道
    public static final int NOTICE_QUERY_CARD_INFO = 20001;     //查询名片信息
    public static final int NOTIFY_START_BANGPAI_SHOUWEI = 50004;     // 请求开启帮派守卫
    public static final int NOTIFY_START_HANBA_RUQIN = 50005;     // 请求开启旱魃入侵
    public static final int NOTIFY_OPEN_NEWBIE_GIFT = 40014;     // 打开新手礼包
    public static final int NOTIFY_FETCH_NEWBIE_GIFT = 40013;     // 领取新手礼包
    public static final int NOTIFY_OPEN_DAILY_SIGN = 40009;     // 打开签到界面
    public static final int NOTIFY_DO_DAILY_SIGN = 40010;     // 进行签到
    public static final int NOTIFY_OPEN_SHENMI_DALI = 40011;     // 打开神秘大礼界面
    public static final int NOTIFY_OPEN_WELFARE = 40008;     // 打开福利界面
    public static final int NOTICE_STOP_AUTO_WALK = 20003;     //停止自动遇敌和寻路
    public static final int NOTICE_UPDATE_MAIN_ICON = 20002;     // 更新主界面图标
    public static final int NOTICE_OVER_INSTRUCTION = 20004;     // 结束指引
    public static final int NOTIFY_FETCH_RECHARGE_GIFT = 20018;     // 领取充值礼包
    public static final int NOTIFY_OPEN_RECHARGE_GIFT = 20019;     // 打开充值礼包
    public static final int NOTIFY_FETCH_LOGIN_GIFT = 20020;     // 领取7天登入礼包
    public static final int NOTIFY_OPEN_LOGIN_GIFT = 20021;     // 打开7天登入礼包
    public static final int NOTIFY_OPEN_MY_STALL = 40015;     //打开我的集市
    public static final int NOTIFY_STALL_REMOVE_GOODS = 40016;     //集市下架物品
    public static final int NOTIFY_STALL_RESTART_GOODS = 40017;     //集市重新上架
    public static final int NOTIFY_OPEN_STALL_LIST = 40018;     //集市打开交易列表
    public static final int NOTIFY_STALL_SEARCH_ITEM = 40019;     //集市搜索物品
    public static final int NOTIFY_STALL_OPEN_RECORD = 40020;     //打开交易纪录
    public static final int NOTIFY_STALL_ITEM_PRICE = 45;        //摆摊物品价格
    public static final int NOTIFY_STALL_QUERY_PRICE = 40021;     //查询物品价格
    public static final int NOTIFY_STALL_TAKE_CASH = 40022;     //取钱
    public static final int NOTIFY_CANCEL_MATCH_LEADER = 40024;     // 取消队长的匹配
    public static final int NOTIFY_CANCEL_MATCH_MEMBER = 40025;     // 取消队员的匹配
    public static final int NOTIFY_START_MATCH_MEMBER = 40026;     // 队员开始匹配
    public static final int NOTIFY_MATCH_TEAM_LIST = 40023;     // 请求队伍列表
    public static final int NOTIFY_BUY_INSIDER = 50006;     // 请求购买会员
    public static final int NOTIFY_DRAW_INSIDER_COIN = 50007;     // 请求领取会员元宝
    public static final int NOTIFY_REQEUST_INSIDER_INFO = 50008;     // 请求领取会员信息
    public static final int NOTICE_FETCH_BONUS = 20005;     // 领取奖励
    public static final int NOTIFY_RANDOM_NAME = 30007;     // 申请随机名字
    public static final int NOTIFY_ZONE_HAS_NO_TEAM_QUIT = 30008;     // 不可组队场景提示是否退出队伍
    public static final int NOTIFY_ZONE_HAS_NO_TEAM_CONFIRM = 30009;     // 不可组队场景确认退出队伍
    public static final int NOTIFY_START_AUTO_FIGHT = 37;        // 开启自动战斗
    public static final int NOTIFY_GUARD_NEXT_FIGHTSCORE = 38;        // 守护下一强化等级对应的战斗力
    public static final int NOTIFY_CLOSE_OFFLINE_SHUADAO = 30016;     // 关闭刷道离线
    public static final int NOTIFY_RECHARGE_COIN = 30015;     // 充值元宝，参数1为 充值类型
    public static final int NOTIFY_GUARD_GROW_OK = 47;        // 守护培养成功
    public static final int NOTIFY_EQUIP_UPGRADE_OK = 48;        // 武器改造成功
    public static final int NOTIFY_REQUEST_GUARD_ID = 30021;     // 客户端请求正在历练的守护
    public static final int NOTIFY_REQUEST_GUARD_EXPERIENCE = 30022;     // 守护请求历练
    public static final int NOTIFY_UPGRADE_JEWELRY_OK = 10000;     // 首饰合成成功
    public static final int NOTIFY_SET_USE_MONEY_TYPE = 30023;     // 设置使用金钱还是代金券

    public static final int NOTIFY_OPEN_EXORCISM = 20008;     // 开启驱魔香
    public static final int NOTIFY_CLOSE_EXORCISM = 20009;     // 关闭驱魔香
    public static final int NOTIFY_EXORCISM_STATUS = 20010;     // 驱魔香状态
    public static final int NOTIFY_MARKET_CARD = 30027;    // 请求物品数据
    public static final int NOTIFY_AUTO_FIGHT_SKILL = 10004;    // 自动战斗技能配置
    public static final int NOTIFY_AUTO_FIGHT_LESS_MANA = 10005;    // 自动战斗缺蓝配置
    public static final int NOTIFY_MARKET_CHECK_GOOD = 30028;    // 检查收藏
    public static final int NOTIFY_TEAM_ASK_AGREE = 30030;    // 组队同意
    public static final int NOTIFY_TEAM_ASK_REFUSE = 30031;    // 组队拒绝
    public static final int NOTIFY_CONFIRE_RESULT = 30037;    // 倒计时结束
    public static final int NOTIFY_DELETE_CHAR = 30032;    // 删除角色
    public static final int NOTIFY_RESPONS_SECRET = 30033;    // 删除角色输入密码
    public static final int NOTIFY_CANCEL_DELETE_CHAR = 30034;    // 取消删除角色
    public static final int NOTIFY_GUARD_BASIC_ATTRI = 30038;    // 请求守护基础属性
    public static final int NOTIFY_NEXT_GUARD_INFO = 30039;    // 请求下一等级的守护数据
    public static final int NOTIFY_TONGTT_GET_TASK = 30040;    // 选择通天塔奖励
    public static final int NOTIFY_QUERY_PARTY_SALARY = 20013;    // 查询帮派俸禄
    public static final int NOTIFY_QUERY_PARTY_CONTRIBUTOR = 20014;    // 查询功臣奖励
    public static final int NOTIFY_COMBAT_GET_CUR_ROUND = 30041;    // 获取战斗的当前轮次
    public static final int NOTIFY_QUERY_SHIDAO_INFO = 20017;    // 查询试道信息
    public static final int NOTIFY_BUY_JIJI = 30045;    // 购买急急如律令
    public static final int NOTIFY_REQUEST_BUYBACK_CARD = 50019;    // 客户端请求回购物品名片
    public static final int NOTIFY_BUY_BACK = 50020;    // 通知回购物品
    public static final int NOTIFY_EQUIP_IDENTIFY = 20022;    // 装备鉴定成功后，向客户端发送MSG_GENERAL_NOTFY消息
    public static final int NOTIFY_FINISH_GATHER = 20023;    // 结束采集
    public static final int NOTIFY_EQUIP_IDENTIFY_GEM = 20031;    // 宝石鉴定结果
    public static final int NOTIFY_HIGHER_JEWELRY_RECAST_OK = 20034;    //高级首饰重铸成功
    public static final int NOTIFY_ENABLE_SHENMU_POINTS = 10009;   // 开关神木鼎点数
    public static final int NOTIFY_BUY_SHENMU_POINTS = 10010;   // 购买神木鼎点数
    public static final int NOTIFY_SUBMIT_EQUIP = 20024;   // 提交装备操作
    public static final int NOTIFY_SHUADAO_SET_CHONGFENGSAN = 30046;   // 刷道设置宠风散状态
    public static final int NOTIFY_BUY_CHONGFENGSAN = 30047;   // 购买宠风散点数
    public static final int NOTIFY_STALL_BATCH_NUM = 10011;   // 通知客户端集市商品可上架的数量
    public static final int NOTIFY_MAIL_ALL_LOADED = 10012;   // 通知客户端加载所有邮件完毕
    public static final int NOTIFY_MOUNT_MERGE_RESULT = 61000;   // 骑宠融合结果
    public static final int NOTIFY_SHUADAO_SET_ZIQIHONGMENG = 30048;   // 刷道设置紫气鸿蒙状态
    public static final int NOTIFY_BUY_ZIQIHONGMENG = 30049;   // 购买紫气鸿蒙点数
    public static final int NOTIFY_BUY_HOUSE_RESULT = 61002;  // 购买居所
    public static final int NOTIFY_HIDE_NPC = 61003;  // 通知渐隐NPC
    public static final int NOTIFY_FRIEND_CLEAR_XINMO = 61004;  // 好友协助清除心魔
    public static final int NOTIFY_JOIN_PARTY = 99;     // 加入帮派
    public static final int NOTIFY_ASSIGN_XMD = 50021;  // 通知客户端仙魔加/洗点完毕
    public static final int NOTIFY_TTTD_LEAVE_TOWER = 50022;  // 离开通天塔顶
}
