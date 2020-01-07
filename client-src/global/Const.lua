-- created by cheny Feb/12/2014
-- 常量定义

-- 事件
EVENT = require("global/Event")

Const = {
    FPS = 30,
    WINSIZE = cc.Director:getInstance():getWinSize(),
    UI_DESIGN_WIDTH = 960,
    UI_DESIGN_HEIGHT = 640,
    UI_SCALE = 1,
    INTERVAL = cc.Director:getInstance():getAnimationInterval(),
    PER_FRAME_LOAD_COUNT = 3,

    MAP_SCALE = 1, -- 相对于原始地图的放缩比例

    LIMIT_MIX = 60, -- 限制交易时间上限

    RECORD_CLICK_TIME = 10 * 1000,    -- 记录点击的事件间隔

    MAX_LIFE_STORE      = 90000000,     -- 气血储备
    MAX_MANA_STORE      = 90000000,     -- 法力储备

    -- 新年趣味对话框开关，注意，任务开启时，要浏览一下界面是否发生变化，见 DlgRelation.lua 中配置
    OPEN_FUN_DLG = false,

    -- touch event
    TOUCH_BEGAN = "began",
    TOUCH_MOVED = "moved",
    TOUCH_ENDED = "ended",
    TOUCH_CANCELLED = "cancelled",

    -- node event
    NODE_ENTER = "enter",
    NODE_EXIT = "exit",
    NODE_ENTERFINISH = "enterTransitionFinish",
    NODE_EXITSTART = "exitTransitionStart",
    NODE_CLEANUP = "cleanup",

    STANDARD = 0,           -- Normal user
    ADMINISTRATOR = 120,    -- Game administrator
    BEHOLDER = 200,         -- Game beholder
    CONTROLLER = 300,       -- Game controller
    DEBUGGER = 1000,        -- Server debugger

    RAW_PANE_WIDTH = 24,    -- 原地图中单元格宽
    RAW_PANE_HEIGHT = 24,   -- 原地图中单元格高
    BLOCK_WIDTH = 256,      -- 地图块宽
    BLOCK_HEIGHT = 256,     -- 地图块高

    TAG_MAP_LAYER       = 100,      -- 地图层对应的 TAG
    TAG_CHAR_LAYER      = 101,      -- 角色层对应的 TAG
    TAG_UI_LAYER        = 102,      -- UI 层对应的 TAG
    TAG_WEATHER_LAYER   = 103,      -- 天气层对应的 TAG
    TAG_WEATHER_ANIM_LAYER = 104,   -- 天气动画层对应的 TAG

    TAG_GUIDE_LAYER = 200,  -- 指引层对应的TAG
    TAG_RED_DOT     = 201,  -- 小红点对应的TAG
    TAG_ATTR_TIP    = 202,  -- 属性提示对应的TAG
	TAG_LOGOUT      = 203,  -- 退出确认框
	TAG_FROZEN      = 204,  -- 冻屏对应的TAG
    TRY_RECRUIT     = 5,    -- 队伍召集
    TAG_COVER_LAYER = 205,   -- 遮挡层对应的 TAG
    TAG_KUAF_LOGO   = 206,  -- 头像跨服 logo 的TAG
    PLAYER_MAX_LEVEL       = 125,   -- 人物最高等级
    PLAYER_MAX_LEVEL_NOT_FLY = 115, -- 人物最高等级      未飞升
    JEWELRY_DEVELOP_MAX     = 20,   -- 首饰强化最高等级

    FIVE_HOURS = 18000, -- 60 * 60 * 5 5小时秒数

    ONE_DAY_SECOND = 24 * 60 * 60,

    ARTIFACT_MAX_LEVEL     = 24,   -- 法宝最高等级
    SHOW_ARTIFACT_ICON_MIN_LEVEL = 70,  -- 显示法宝图标最低等级
    SHOW_EQUIP_ICON_MIN_LEVEL = 40, -- 显示装备图标最低等级
    SHOW_JEWELRY_ICON_MIN_LEVEL = 35, -- 显示装备图标最低等级
    ARTIFACT_EQUIPPED_MIN_LEVEL     = 70,    -- 装备法宝最低等级
    ZF_TREE_MAX_LEVEL = 12, -- 周年庆招福宝树最大等级
    JY_XINDE_MAX_LEVEL = 100, -- 经验心得最大等级

    PET_MAX_LEVEL_NOT_FLY = 115, -- 未飞升的宠物的最高等级（非野生）
    PET_FLY_LIMIT_LEVEL = 110, -- 宠物飞升限制等级

    PLAYER_PET_MAX_DIF = 15, -- 玩家和宠物等级最大差值

    ONE_YEAR_TAO = 360,  -- 一年有 360 天道行

    SLEEP_COST_DUR = 10, --居所中的床每次休息消耗的耐久

    DELAY_TIME_BALANCE = 3, -- 客户端获取server_time后的延迟补偿时间

    -- 控件名称
    UIButton = "ccui.Button",
    UICheckBox = "ccui.CheckBox",
    UIImage = "ccui.ImageView",
    UIAtlasLabel = "ccui.TextAtlas",
    UIBitmapLabel = "ccui.TextBMFont",
    UIProgressBar = "ccui.LoadingBar",
    UISlider = "ccui.Slider",
    UILabel = "ccui.Text",
    UITextField = "ccui.TextField",
    UIPanel = "ccui.Layout",
    UIScrollView = "ccui.ScrollView",
    UIListView = "ccui.ListView",
    UIPageView = "ccui.PageView",

    -- 角色动作
    SA_NONE = -1,            -- 没有动作
    SA_STAND = 0,           -- 站立
    SA_WALK = 1,            -- 行走
    SA_ATTACK = 2,          -- 物理攻击
    SA_DEFENSE = 3,         -- 被击
    SA_PARRY = 4,           -- 防御时被击
    SA_CAST = 5,            -- 法术攻击
    SA_DIE = 6,             -- 死亡
    SA_BAIBAI = 7,          -- 拜拜
    SA_YONGBAO = 8,         -- 拥抱
    SA_JIAOBEI = 9,         -- 交杯
    SA_QINQIN = 10,         -- 亲亲
    SA_SNUGGLE = 11,
    SA_SHOW = 12,
    SA_BOW = 13,
    SA_CLEAN = 14,
    SA_STAND1 = 15,
    SA_SIT = 16,            -- 坐
    SA_EAT = 17,            -- 吃饭
    SA_STAND2 = 18,
    SA_STAND3 = 19,
    SA_ATTACK2 = 20,        -- 攻击动作2
    SA_FLAPPING = 21,       -- 捶
    SA_THROW = 22,          -- 扔
    SA_CRY = 23,
    SA_NUM = 24,             -- 动作总数

    -- 地图上角色动作
    NS_ALIVE = 0, -- 活的状态
    NS_DEAD  = 1, -- 死的状态
    NS_INJURED = 2, -- 受伤状态
    NS_NOTTURN = 3, -- 不可转向
    NS_ATTACK = 4, -- 攻击
    NS_DEFENSE = 8,    -- 防御
    NS_BAIBAI = 16, -- 拜拜状态
    NS_A_YINSHEN  = 17, -- 隐身
    NS_A_JIAOBEI  = 18, -- 交杯
    NS_A_BAOBAO   = 19, -- 抱抱
    NS_A_QINQIN   = 20, -- 亲亲
    NS_BAOBAO = 32, --抱抱状态
    NS_JIAOBEI = 64, -- 交杯状态
    NS_QINQIN = 128, -- 亲亲状态
    NS_SNUGGLE   = 256,
    NS_SHOW      = 512,
    NS_YB_STATUS = 1024,
    NS_YX_STATUS = 2048, -- 元宵节-龙舞训练 NPC
    NS_YR_STATUS = 4096, -- 愚人节-走火入魔 NPC
    NS_ET_STATUS = 8192, -- 儿童节-烹饪美食 NPC
    NS_SJ_STATUS = 16384, -- 暑假-智斗炼魔 NPC
    NS_BOW       = 65536, -- 喜来客栈-书生离开前播放作揖动作

    NS_EAT_STATUS = 100000,    -- 客栈吃状态(该字段目前是客户端自己定义的)
    NS_SIT_STATUS = 100001,    -- 客栈坐状态(该字段目前是客户端自己定义的)

    FA_STAND            = 0,        -- 站立
    FA_WALK             = 1,        -- 行走
    FA_GO_AHEAD         = 2,        -- 人物前移到对方前面
    FA_GO_BACK          = 3,        -- 人物从目标点回来
    FA_DIE_NOW          = 4,        -- 正在死亡
    FA_DIED             = 5,        -- 已经死亡
    FA_QUIT_GAME        = 6,        -- 退出游戏
    FA_GO_TO_PROTECT    = 7,        -- 前去保护
    FA_PROTECT_BACK     = 8,        -- 保护回来
    FA_BE_CALLBACK      = 9,        -- (宠物)被召回
    FA_DODGE_START      = 10,       -- 开始躲避动作(离开站立原点)
    FA_DODGE_END        = 11,       -- 结束躲避动作(回到站立原点)

    FA_ACTION_DEFENSE         = 12, -- 防御
    FA_ACTION_PHYSICAL_ATTACK = 13, -- 物理攻击
    FA_ACTION_CAST_MAGIC      = 14, -- 施展魔法
    FA_ACTION_CAST_MAGIC_END  = 15, -- 施展魔法结束
    FA_ACTION_APPLY_ITEM      = 16, -- 使用道具
    FA_ACTION_BE_APPLY_ITEM   = 17, -- 道具被使用
    FA_ACTION_USE_STUNT       = 18, -- 施展绝技
    FA_ACTION_FLEE            = 19, -- 逃跑
    FA_ACTION_SELECT_PET      = 20, -- 选择宠物出战
    FA_ACTION_CALLBACK_PET    = 21, -- 召回宠物
    FA_ACTION_CATCH_PET       = 22, -- 捕捉宠物
    FA_ACTION_GUARD           = 23, -- 保护
    FA_ACTION_JOINT_ATTACK    = 24, -- 合击
    FA_ACTION_DOUBLE_HIT      = 25, -- 连击
    FA_ACTION_REVIVE          = 26, -- 重生
    FA_ACTION_COUNTER_ATTACK  = 27, -- 反击
    FA_ACTION_ATTACK_FINISH   = 28, -- 攻击完成

    -- 人物被击中时的动作状态
    FA_DYMAGE_PHYSICAL      = 29,   -- 物理伤害
    FA_DYMAGE_MAGIC         = 30,   -- 魔法伤害
    FA_DYMAGE_POSION        = 31,   -- 毒伤害
    FA_DYMAGE_SEL           = 32,   -- 反震伤害
    FA_DYMAGE_DOUBLE_HIT    = 33,   -- 连击伤害
    FA_DYMAGE_STUNT         = 34,   -- 绝招伤害
    FA_DYMAGE_JOINT         = 35,   -- 合击伤害
    FA_DYMAGE_COUNTER       = 36,   -- 反击伤害
    FA_DYMAGE_GUARD         = 37,   -- 保护伤害

    FA_DEFENSE_START        = 38,   -- 防御开始
    FA_DEFENSE_END          = 39,   -- 防御结束

    FA_PARRY_START          = 40,   -- 格挡开始
    FA_PARRY_END            = 41,   -- 格挡结束
    FA_BAIBAI               = 42,   -- 拜拜
    FA_YONGBAO              = 43,   -- 拥抱
    FA_JIAOBEI              = 44,   -- 交杯
    FA_QINQIN               = 45,   -- 亲亲

    FA_SHOW_BEGIN           = 46,   -- 展示开始
    FA_SHOW_END             = 47,   -- 展示结束
    FA_SNUGGLE              = 48,
    FA_BOW                  = 49,
    FA_CLEAN                = 50,

    FA_YONGBAO_ONE       = 51,   -- 拥抱
    FA_QINQIN_ONE        = 52,   -- 亲吻

    FA_PHYSICAL_ATTACK_LOOP = 53,  -- 循环播放攻击动作
    FA_DEFENSE_LOOP         = 54,
    FA_EAT                  = 55,  -- 吃饭
    FA_EAT_LOOP             = 56,  -- 循环播放吃饭动作
    FA_SIT_LOOP             = 57,
    FA_ACTION_PHYSICAL_ATTACK2 = 58, -- 物理攻击2
    FA_FLAPPING             = 59,
    FA_THROW_BEGIN          = 60,
    FA_THROW_END            = 61,
    FA_DEFENSE              = 62,   -- 防御
    FA_ACTION_TOTAL         = 63,   -- 动作总数

    TITLE_IN_COMBAT             = "1",  -- 正在战斗中
    TITLE_IN_TEAM               = "2",  -- 正在队伍中
    TITLE_TEAM_LEADER           = "3",  -- 队长
    TITLE_TEAM_LEADER_TEAM_FULL = "4",  -- 队长并且队伍满员
    TITLE_TEAM_MEMBER           = "5",  -- 队员
    TITLE_LOOKON                = "6",  -- 正在观战中
    TITLE_RED_NAME              = "7",  -- 红名
    TITLE_INSIDER               = "8",  -- 位列仙班（服务端当前未实现，不能用）
    TITLE_IN_SHADOW             = "9",  -- 正在隐身中
    TITLE_BREAK_FLAG            = "10", -- 新帮战军旗打断
    TITLE_OCCUPY_FLAG           = "11", -- 新帮战占领军旗
    TITLE_IN_GATHER             = "12", -- 新帮战采集

    -- 以下 TITLE 暂未使用，使用时需与服务确定编号
    TITLE_IN_EXCHANGE       = CHS[65025],
    TITLE_IN_STALL          = CHS[65032],
    TITLE_IN_STALL_OFFLINE  = CHS[65033],
    TITLE_USE_JINGYAOSHU    = CHS[65034],
    TITLE_USE_JINGYAOLING   = CHS[65035],
    TITLE_REMOTE_STORE      = CHS[65037],
    TITLE_IN_RAID           = CHS[103168],
    TITLE_RAID_MEMBER       = CHS[103169],
    TITLE_RAID_LEADER       = CHS[103170],

    -- 队伍中跟随时角色之间的距离
    CHAR_FOLLOW_DISTANCE    = 50,

    -- 与主人距离该数值是开始走路
    PET_FOLLOW_DISTANCE    = 160,

    -- 与被跟随者距离该数值是开始走路
    NPC_FOLLOW_DISTANCE    = 160,

    -- 走动时，距离 endPos 为该数值时重现设置 endPos
    PET_RESET_DISTANCE    = 60,

    -- 帧图片起始编号
    CHAR_FRAME_START_NO     = 10000,

    -- zorder定义
    ZORDER_SMALLTIP             = 102,  -- 弹出提示框
    ZORDER_DIALOG               = 101,  -- 弹出确认框
    ZORDER_DIALOG_CONFORM       = 101,  -- 弹出确认框
    ZORDER_SCREEN_RECORD        = 100,  -- 录屏按钮层级
    ZORDER_FLOATING             = 99,   -- 悬浮框层级
    ZORDER_SHARE                = 99,   -- 分享框层级
    ZORDER_WAIT                 = 100,   -- 等待界面层级
    ZORDER_TOPMOST              = 255,  -- ui 中顶层 zorder
    ZORDER_LORDLAOZI            = 299,  -- 老君查岗界面

	ZORDER_BIGCONFIRDLG         = 301,  -- 免责声明的对话框层级
    ZORDER_ACHIEVEMENT          = 10,   -- 成就完成提示层级 （只需要比正常的界面默认的层级高）
    ZORDER_CROPLAND             = 10000, -- 农田创建在地图物件层的层级，地图物件层初始物件是加载地图时自带的，有设置层级，未避免被覆盖，农田也要配置个层级。
    ZORDER_FULLBACK             = 99999,

    MAGIC_ALIGN_TYPE_TOP        = 1,    -- 最上层显示
    MAGIC_ALIGN_TYPE_MIDDLE     = 2,    -- 中间层显示(由人物的先后关系决定与他相关的动画的先后关系)
    MAGIC_ALIGN_TYPE_BOTTOM     = 3,    -- 最下层显示
    MAGIC_ALIGN_TYPE_HEAD       = 4,    -- 光效加在头顶
    MAGIC_ALIGN_TYPE_WAIST      = 5,    -- 光效加在腰上
    MAGIC_ALIGN_TYPE_FOOT       = 6,    -- 光效加在脚下
    MAGIC_ALIGN_TYPE_CENTER     = 13,   -- 在屏幕中央显示

    MAGIC_BEHIND_ZORDER  = 0, -- 角色后面的光效的 zorder
    CHARACTION_ZORDER    = 10000, -- 角色真身的 zorder
    CHAR_PROGRESS_ZORDER = 20000, -- 血条、法力条、怒气条的 zorder
    MAGIC_FRONT_ZORDER   = 20000, -- 角色前面的光效的 zorder
    NAME_ZORDER          = 20000, -- 名字的 zorder
    FLYIMG_ZORDER        = 30000, -- 飘字的zorder
    FIGHT_SEL_IMG_ORDER  = 30000, -- 战斗角色选择图片 zorder

    MAP_EFFECT_LAYER_ZORDER = 2, -- 地图表面光效层的 zorder

    -- MSG_DIALOG请求类型
    REQUEST_JOIN_TEAM           = "request_join",      -- 申请组队伍
    REQUEST_JOIN_WARCRAFT       = "warcraft",          -- 申请比武
    REQUEST_JOIN_PARTY          = "party",             -- 申请加入帮派
    REQUEST_JOIN_PARTY_REMOTE   = "party_remote",      -- 远程申请加入帮派
    PARTY_INVITE                = "party_invite",      -- 邀请入帮
    REQUEST_MASTER              = "master",            -- 申请玩家师徒
    INVITE_JOIN_TEAM            = "invite_join",       -- 邀请加入队伍
    REQUEST_JOIN_RAID           = "raid_request",      -- 申请加入团队
    INVITE_JOIN_RAID            = "raid_invite",       -- 邀请加入团队
    AROUND_PLAYER               = "around_player",
    CSC_AROUND_PLAYER          = "csc_around_player",
    PWAR_AROUND_PLAYER               = "pwar_around_player",
    CSC_AROUND_TEAM            = "csc_around_team",
    AROUND_TEAM                 = "around_team",
    REQUEST_TEAM_LEADER         = "request_team_leader", -- 申请带队
    PWAR_AROUND_TEAM    = "pwar_around_team", -- 客户端请求队伍信息时，返回真是队伍人员数量

    KFZC2019_AROUND_TEAM                = "csml_around_team", -- 客户端请求队伍信息时，返回真是队伍人员数量
    KFZC2019_AROUND_PLAYER               = "csml_around_player",

    DEFAULT_FONT_SIZE           = 20, -- 默认UI字体大小

    PET_RANK_WILD               = 1, -- 野生
    PET_RANK_BABY               = 2, -- 宝宝
    PET_RANK_ELITE              = 3, -- 变异
    PET_RANK_EPIC               = 4, -- 神兽
    PET_RANK_GUARD              = 5, -- 守护

    ASSIGN_POINT_ATTRIB         = 1, -- 属性加点(attrib.h)
    ASSIGN_POINT_POLAR          = 2, -- 相性加点(attrib.h)

    -- upgrade_equip.h
    UPGRADE_EQUIP_IDENTIFY        = 1,  -- 装备进化
    UPGRADE_EQUIP_SPLIT       = 2,  -- 装备改造
    UPGRADE_EQUIP_UPGRADE       = 3,  -- 装备改造
    UPGRADE_EQUIP_REFORM        = 4,  -- 装备改造
    EQUIP_REFINE_SUIT        = 5,  -- 装备炼化绿属性
    UPGRADE_JEWELRY_COMPOSE    = 6,   -- 首饰合成
    UPGRADE_JEWELRY_APPOINT    = 13,   -- 制定首饰合成
    UPGRADE_EQUIP_REFINE_PINK    = 7,   -- 炼化 粉
    UPGRADE_EQUIP_REFINE_GOLD    = 8,   -- 炼化 金
    UPGRADE_EQUIP_STRENGTHEN_BLUE    = 9,   -- 强化 兰
    UPGRADE_EQUIP_STRENGTHEN_PINK    = 10,   -- 强化 粉
    UPGRADE_EQUIP_STRENGTHEN_GOLD    = 11,   -- 强化 金
    EQUIP_DELICATE                   = 12,   -- 装备精致鉴定
    EQUIP_EVOLVE                     = 14,   -- 装备进化
    EQUIP_EVOLVE_PREVIEW             = 15,   -- 装备进化
    EQUIP_IDENTIFY_GEM               = 16,   -- 宝石鉴定
    EQUIP_REFINE_APPLY_PREVIEW       = 17,   -- 替换装备炼化属性
    EQUIP_REFINE_CLEAR_PREVIEW       = 18,   -- 还原装备炼化属性
    EQUIP_RECAST_HIGHER_JEWELRY      = 19,    -- 高级首饰重铸
    EQUIP_REFINE_ARTIFACT            = 20,    -- 洗炼法宝
    UPGRADE_ARTIFACT_EXTRA_SKILL     = 21,    -- 法宝特殊技能升级
    EQUIP_DEGENERATION               = 22,   -- 装备退化
    EQUIP_DEGENERATION_PREVIEW       = 23,   -- 装备退化预览
    EQUIP_RESONANCE                  = 24,   -- 装备共鸣
    EQUIP_RESONANCE_PREVIEW          = 25,   -- 装备共鸣预览
    EQUIP_RESONANCE_REPLACE          = 26,   -- 装备共鸣替换
    EQUIP_SPLITE_JEWELRY             = 27,   -- 首饰分解
    EQUIP_TRANSFORM_JEWELRY          = 28,   -- 首饰转换
    EQUIP_UPGRADE_INHERIT            = 30,   -- 执行装备改造继承 para 参数格式 : 副装备位置 | 消费金元宝标志
    EQUIP_UPGRADE_INHERIT_SELECT     = 31,   -- 选择装备改造继承的副装备    para 参数格式 : 副装备位置
    EQUIP_STRENGTHEN_JEWELRY         = 32,   -- 首饰强化


    UPGRADE_EQUIP_REFINE_BLUE_ALL   = 37, -- 蓝属性升级 一键升级
    UPGRADE_EQUIP_REFINE_PINK_ALL   = 38, -- 粉属性升级 一键升级
    UPGRADE_EQUIP_REFINE_YELLOW_ALL = 39, -- 黄属性升级 一键升级

    UPGRADE_EQUIP_JEWELRY       = 4,  -- 首饰升级
    UPGRADE_EQUIP_SUIT          = 5,  -- 炼化套装

    JEWELRY_BLUE_ATTRIB         = 2,  -- 首饰蓝属性
    JEWELRY_BLUE_ATTRIB_EX      = 3,  -- 首饰蓝属性，属性重叠
    JEWELRY_BLUE_ORDER          = 21, -- 首饰蓝属性顺序
    JEWELRY_BLUE_ORDER_EX       = 22, -- 首饰蓝属性顺序,属性重叠
    JEWELRY_ATTRIB_MAX          = 9,  -- 首饰属性最大数量：120级属性为9条，1条基本属性，5条蓝属性，1条限制交易, 1条转换次数，1条冷却

    -- fields.h
    FIELDS_NORMAL           = 1 ,  -- 普通属性第1组
    FIELDS_EXTRA1           = 2 ,  -- 附加魔法属性第2组（蓝属性）
    FIELDS_EXTRA2           = 3 ,  -- 附加魔法属性第3组（粉属性）
    FIELDS_PROP3            = 4 ,  -- 道具的特殊属性（黄属性）
    FIELDS_PART_SUIT        = 7 ,  -- 套装部件上的特殊属性
    FIELDS_SUIT             = 8 ,  -- 套装属性
    FIELDS_RECG             = 9 ,  -- 认主的附加属性
    FIELDS_REBUILD          = 10,  -- 改造属性第9组
    FIELDS_EFFECT           = 11,  -- 特殊道具效果属性
    FIELDS_PROP4            = 12,  -- 道具的第4组附加属性（绿属性）
    FIELDS_MAX              = 12,  -- 最大组数
    BLUE_COMPLETION         = 13,  -- 蓝属性完成度
    PINK_COMPLETION         = 14,  -- 蓝属性完成度
    GOLD_COMPLETION         = 15,  -- 蓝属性完成度
    FIELDS_CHANGE_CARD      = 16,  -- 变身卡属性
    FIELDS_BATTLE_ARRAY     = 17,  -- 阵法属性
    FIELDS_STRENGTHEN       = 18,  -- 首饰强化
    FIELDS_PROP2_PREVIEW    = 23,  -- 装备粉属性炼化预览
    FIELDS_PROP3_PREVIEW    = 24,  -- 装备金属性炼化预览
    FIELDS_PROP4_PREVIEW    = 25,  -- 装备绿属性炼化预览
    FIELDS_SUIT_PREVIEW     = 26,  -- 装备套装属性炼化预览
    FIELDS_RESONANCE        = 27,  -- 装备共鸣属性
    FIELDS_RESONANCE_PREVIEW = 28, -- 装备共鸣预览属性
    FIELDS_RESONANCE_ACTIVED = 29, -- 装备共鸣激活属性

    PROP_LEVEL              = 1,   -- 属性等级
    PROP_DEGREE             = 2,   -- 属性进度
    PROP_VALUE              = 3,   -- 属性值
    PROP_VALUE_NEXT         = 4,   -- 下一属性值（蓝属性）

    MAX_RECORD_TIME         = 15,  -- 最大录音时长

    WRITE_PATH              = "data/",
    LOADING_DLG_ZORDER      = 1000000,  -- 加载界面ZORDER层级
    ZORDER_LORDLAOZI_TIP    = 1000000 - 1,
    FAST_USE_ITEM_DLG_ZORDER = 100, -- 快捷物品使用ZORDER层级
    FAST_CALL_GUARD_DLG_ZORDER = 101, -- 快捷守护使用ZORDER层级
    FAST_GET_NEWGIFT_DLG_ZORDER = 102, -- 快捷礼包ZORDER层级
    VIP_NORMAL              = 0,        -- 非VIP
    VIP_MONTH               = 1,        -- 月卡
    VIP_SEASON              = 2,        -- 季卡
    VIP_YEAR                = 3,        -- 年卡
    LIMIT_TIPS_DAY          = 59,       -- 限制道具提示天数

    GUIDE_VISIBLE           = 120,      -- 指引层的透明度

    PET_STONE_OPEN_LEVEL    = 30,       -- 妖石开放等级

    ITEMIMAGE_SHOWSIZE    = {height = 64, width = 64},  -- 技能、小图头像、道具、大奖励图标图片显示的大小
    ITEMIMAGE_CONTENTSIZE    = {height = 96, width = 96},  -- 技能、部分小图头像、道具、奖励图片新替换的尺寸的大小
    SKILLFLAGIMAGE_SHOWSIZE    = {height = 20, width = 20},  --  法宝、顿悟技能标记图片显示大小
    SKILLFLAGIMAGE_CONTENTSIZE    = {height = 30, width = 30}, --  法宝、顿悟技能标记图片尺寸大小
    SMALLREWARD__SHOWSIZE       = {height = 44, width = 44},    -- 小奖励图标的显示大小
    PARTYICON_SHOWSIZE          = {height = 22, width = 22},    -- 帮派图标

    -- 服务器类型
    KFSDDH_SERVER_TYPE    = 0x00000001, -- 跨服试道大会区组类型
    QMPK_SERVER_TYPE      = 0x00000002, -- 全民PK区组类型
    NSZB_COMPETE          = 0x00000004, -- 女神争霸区组
    CSL_COMPETE           = 0x00000008, -- 跨服战场区组
    XMZB_COMPETE          = 0x00000040, -- 仙魔争霸区组
    KFJJDH_SERVER_TYPE    = 0x00000080, -- 跨服竞技
    MRZF_SERVER_TYPE    = 0x00000100, -- 跨服竞技
    ZBYL_COMPETE          = 0x00000200, -- 争霸娱乐
    MKFSD_SERVER_TYPE     = 0x00000400, -- 月道行跨服试道区组
    MKFZC_SERVER_TYPE     =  0x00000800,    --月跨服战场区组
    QCLD_COMPETE          =  0x00001000,  -- 青城论道战场区组

    VIPBROW_STARTINDEX    = 201,         -- 第一个vip表情编号
    VIPBROW_ENDINDEX      = 280,         -- 最后一个vip表情编号

    NORMALBROW_STARTINDEX = 0,           -- 第一个普通表情编号
    NORMALBROW_ENDINDEX   = 91,          -- 最后一个普通表情编号

    -- 宠物进化计算花费时的假携带等级
    JINIAN_PET_COST_REQ_LEVEL = 60,
    BAIGUOER_PET_COST_REQ_LEVEL = 70,
    MOUNT_PET_COST_REQ_LEVEL = 80,

    -- 地劫任务最大数
    DIJIE_TASK_MAX = 10,

    -- 天劫最大任务数
    TIANJIE_TASK_MAX = 10,

    MAX_MONEY_IN_BAG = 2000000000,

    BUYBACK_TYPE_PET = 1, -- 要销毁的宠物类型
    BUYBACK_TYPE_EQUIPMENT = 2, -- 要销毁的装备类型

    MAX_VIP_DAYS = 7200, -- VIP天数上限，三种VIP都一样

    CULTIVATED_HEIGHT = 104,    -- 开垦的农田的高度
    ARMATURE_MAGIC_TAG = 99999, -- 骨骼动画标记
    UPGRADE_MAGIC_TAG = 99998, -- 飞升动画标记
    UPGRADE_CHILD_MAGIC_SCALE = 0.75,

    PLANT_WEED_TAG = 1170,  -- 农田杂草标记
    PLANT_EARTH_CRACKED_TAG = 1169, -- 农田干裂的旱地标记

    BUBBLE_CAPINSECT_RECT = cc.rect(5, 5, 56, 54),       -- 头顶冒泡图片设置的九宫格最中间图片块的大小

    HORN_BUBBLE_CAPINSECT_RECT = cc.rect(38, 38, 5, 10), -- 喇叭气泡图片设置的九宫格最中间图片块的大小

    HORN_TIP_CAPINSECT_RECT = cc.rect(26, 36, 1, 1),     -- 喇叭提示框背景

    PK_OPEN_LEVEL    = 70,       -- PK开放等级
    INNERALCHEMY_DAY_MAX_SPIRIT = 1000,    -- 内丹每日可吸收最大精气
    RECOMMEND_EXP_LEVEL = 70,    -- 选择奖励时，等级小于70级的角色推荐选择经验

    JEWELRY_TRANSFORM_MAX_COUNT = 10,

    PET_MAX_LONGEVITY = 15000,   -- 宠物最大寿命
    CHAOJI_SSD_ADD_LONGEVITY = 5000, -- 超级神兽丹最大可加寿命
    CHAOJI_SSD_ADD_INTIMACY  = 2000, -- 超级神兽丹最大可加亲密度

    EFFECT_LAYER_OFFSET = 1000000000,

    PUBLIC_KEY = [[
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQC4TTXBfmLoOnJ9MNEGaIzvDk59
l+/96QVHi87UC7mwMM5NHhIdIcsRWIliDQZICDJyzrREBi+qo33SsOH7dt546ozK
EBXAFO/9fjWdjX2F/tIuNKloU4pTLK3RTE5XqmYD2myv86wo1SEM4fdIpu1Pyc9P
kRydAYFSKoxVN6IllwIDAQAB
-----END PUBLIC KEY-----
]]
}

-- 地图有可能放缩，块大小也要跟着变
Const.PANE_WIDTH = Const.RAW_PANE_WIDTH * Const.MAP_SCALE
Const.PANE_HEIGHT = Const.RAW_PANE_HEIGHT * Const.MAP_SCALE

-- 当队员与队长的距离超过该数值时，队长需要拉一下队员
Const.SHIFT_LIMITED_DISTANCE  = 11 * Const.PANE_WIDTH

-- 场景中的对象类型
OBJECT_TYPE = {
    CHAR        = 0x0001,
    MONSTER     = 0x0002,
    NPC         = 0x0004,
    ITEM        = 0x0008,
    CHILD       = 0x0010,
    GUARD       = 0x0020,
    PET         = 0x8000,
    FOLLOW_NPC  = 0x0100,
    GATHER_NPC  = 0x0080,
    SPECIAL_NPC = 0x0040,
    MOVE_NPC    = 0x0200,
    SHINVTU_NPC = 0x0400,
    QT_NPC      = 0x0800,
    MAP_NPC     = 0x1000,
    MAID_NPC    = 0x10000, -- 居所丫鬟
    INN_GUEST   = 0x2000, -- 客栈客人
}

OBJECT_NPC_TYPE = {
    MAID_NPC      = 0x00000001, -- 居所丫鬟
    LS_NPC        = 0x00000002, -- 小岚和小水
    XHQ_NPC       = 0x00000003, -- 寻寒气 NPC
    TM_FOLLOW_NPC = 0x00000004, -- 只能与玩家自己交流的跟随 NPC
    CANNOT_TOUCH  = 0x00000005, -- 不能点击的NPC
    DWW_NPC       = 0x00000006, -- 大胃王npc
    ZJYB_NPC      = 0x00000007, -- 真假月饼npc
    CMD_NPC      = 0x00000008, -- 需要发送消息的NPC
    CHILD_NPC      = 0x00000009, -- 居所娃娃
}

OBJECT_PET_TYPE =
{
    TYPE_FLY = 1,           -- 飞行类外观跟随宠
    TYPE_RUN = 2,           -- 行走类外观跟随宠
}

-- 战斗动作命令
FIGHT_ACTION = {
    DEFENSE          = 1,   -- 防御
    PHYSICAL_ATTACK  = 2,   -- 物理攻击
    CAST_MAGIC       = 3,   -- 施展魔法
    APPLY_ITEM       = 4,   -- 使用道具
    USE_ARTIFACT     = 5,   -- 使用宝物
    USE_STUNT        = 6,   -- 施展绝技
    FLEE             = 7,   -- 逃跑
    SELECT_PET       = 8,   -- 选择宠物出战
    CATCH_PET        = 9,   -- 捕捉宠物
    GUARD            = 10,  -- 保护
    JOINT_ATTACK     = 11,  -- 合击
    DOUBLE_HIT       = 12,  -- 连击
    LEECH_MANA       = 13,  -- 吸魔
    CALLBACK_PET     = 14,  -- 召回宠物
    ACTION_USE_ARTIFACT_EXTRA_SKILL = 16, -- 使用法宝特殊技能
    DIE              = 40,  -- 死亡
    REVIVE           = 41,  -- 重生
    HEAL             = 42,  -- 治疗
    CHECK_STATUS     = 43,  -- 检查状态
    COUNTER_ATTACK   = 44,  -- 反击
    SELECT_MENU      = 45,  -- 选择菜单
    DISAPPEAR        = 46,  -- 直接消失
    DEADLY_KISS      = 47,  -- 死亡缠绵
    DOUBLE_MAGIC_HIT = 48,  -- 法术攻击双击
    CANCEL           = 52,  -- 取消输入
    SPECIAL          = 98,  -- 特殊动作
    NULL             = 99,  -- 不做动作
}

COLOR3 = {
    WHITE = cc.c3b(255, 255, 255),  -- 白色
    BLACK = cc.c3b(0, 0, 0),        -- 黑色
    RED = cc.c3b(200, 0, 0),        -- 红色
    GREEN = cc.c3b(0, 168, 6),      -- 绿色
    CHAR_GREEN = cc.c3b(0, 255, 8), -- 角色名称绿
    CHAR_VIP_BLUE = cc.c3b(0, 222, 242), -- 角色VIP蓝
    CHAR_VIP_BLUE_EX = cc.c3b(0, 140, 255),   -- 角色VIP蓝（部分界面背景太亮需使用该颜色）
    BLUE = cc.c3b(0, 126, 255),       -- 蓝色
    CYAN = cc.c3b(0, 186, 186),     -- 青色
    ORANGE = cc.c3b(76, 32, 0),   -- 橙色
    BROWN = cc.c3b(88, 50, 0 ),     -- 褐色
    YELLOW = cc.c3b(255, 255, 0),   -- 黄色
    PURPLE = cc.c3b(237, 62, 239),  -- 紫色
    GRAY = cc.c3b(102, 102, 102),   -- 灰色
    MAGENTA = cc.c3b(255, 0, 255),  -- 紫红色
    NPC_YELLOW = cc.c3b(255, 234, 0), -- NPC黄色
    PET_MONSTER_YELLOW = cc.c3b(240, 184, 0), -- NPC黄色
    TEXT_DEFAULT = cc.c3b(86, 41, 2),
    DRAMA_TEXT_DEFAULT = cc.c3b(255, 223, 177),
    LIGHT_WHITE = cc.c3b(255, 242, 224), -- 界面上浅白
    LIGHT_BROWN = cc.c3b(166, 99, 41),

    EQUIP_NORMAL = cc.c3b(255, 242, 224), -- 装备的正常颜色
    EQUIP_BLUE = cc.c3b(0, 126, 255), -- 装备的蓝色
    EQUIP_PINK = cc.c3b(237, 62, 239), -- 装备的粉色
    EQUIP_YELLOW = cc.c3b(240, 184, 0), -- 装备的金色
    EQUIP_GREEN = cc.c3b(0, 168, 6), -- 装备的绿色
    EQUIP_BLACK = cc.c3b(102, 102, 102), -- 装备的灰色
    EQUIP_RED = cc.c3b(255, 32, 36), -- 装备的灰色

    GATHER_NAME_COLOR = cc.c3b(232, 115, 255), -- 共乘名字紫色
}

ATLAS_FONT_INFO = {
    ["AtlasLabel0001"] = {
        width = 22;  -- 单个数字宽度
        height = 30; -- 单个数字高度
        startCharMap = "0";
    }
}

-- 美术字对应颜色
ART_FONT_COLOR = {
    DEFAULT = "white_25",          -- 用于元宝金币类的普通文本
    GREEN = "green_25",
    PURPLE = "purple_25",
    YELLOW = "yellow_25",
    RED = "red_25",
    BLUE = "blue_25",
    NORMAL_TEXT = "white_25_black", -- 用于等级类的普通文本
    S_FIGHT = "sfight_num", -- 战斗回合倒计时的
    B_FIGHT = "bfight_num",
    MALL_NUM2 = "mall_num_2",
    MALL_NUM = "mall_num",
    SHENM_NUM = "shenmsz",
}

-- me 的操作
ME_OP = {
    NULL                    = 0,
    FIGHT_ATTACK            = 11,   -- 战斗中普通攻击
    FIGHT_SKILL             = 12,   -- 战斗中--技能攻击
    FIGHTING_TALISMAN       = 13,   -- 战斗中--法宝攻击
    FIGHTING_PROPERTY_ME    = 14,   -- 战斗中--道具攻击(对己方使用)
    FIGHTING_PROPERTY_YOU   = 15,   -- 战斗中--道具攻击(对敌人使用)
    FIGHT_CATCH             = 16,   -- 战斗中--捕捉怪物
    FIGHT_PROTECT           = 17,   -- 战斗中--保护队友
}

SKILL = {
    CLASS_METAL   = 0x01,  -- 金系魔法
    CLASS_WOOD    = 0x02,  -- 木系魔法
    CLASS_WATER   = 0x04,  -- 水系魔法
    CLASS_FIRE    = 0x08,  -- 火系魔法
    CLASS_EARTH   = 0x10,  -- 土系魔法
    CLASS_PUBLIC  = 0x20,  -- 无差别系
    CLASS_PHY     = 0x40,  -- 力系独特技能
    CLASS_PET     = 0x80,  -- 宠物独特技能

    SUBCLASS_A    = 0x01,  -- A类，基础技能
    SUBCLASS_B    = 0x02,  -- B类，相性技能
    SUBCLASS_C    = 0x04,  -- C类，障碍技能
    SUBCLASS_D    = 0x08,  -- D类，辅助技能
    SUBCLASS_E    = 0x10,  -- E类，公共技能
    SUBCLASS_F    = 0x12,  -- F类，被动技能
    SUBCLASS_J    = 0x14,  -- J类，物理群伤技能
    SUBCLASS_O    = 0x15,  -- O类，进阶技能

    LADDER_0      = 0x0000,
    LADDER_1      = 0x0001,  -- 一级
    LADDER_2      = 0x0002,  -- 二级
    LADDER_3      = 0x0004,  -- 三级
    LADDER_4      = 0x0008,  -- 四级
    LADDER_5      = 0x0010,  -- 五级
    LADDER_6      = 0x0020,  -- 六级
    LADDER_7      = 0x0040,  -- 七级
    LADDER_8      = 0x0080,  -- 八级
    LADDER_9      = 0x0100,  -- 九级
    LADDER_10     = 0x0200,  -- 十级

    -- 技能属性
    MAY_CAST_NORMAL         = 1,  -- 平时可以使用
    MAY_CAST_IN_COMBAT      = 2,  -- 战斗时可以使用
    MAY_CAST_SELF           = 3,  -- 可以对自己使用(obsoleted)
    MAY_CAST_FRIEND         = 4,  -- 可以对友人使用
    MAY_CAST_ENEMY          = 5,  -- 可以对敌人使用
    MAY_CAST_ALL_FRIENDS    = 6,  -- 可以对全体队友使用(obsoleted)
    MAY_CAST_ALL_ENEMIES    = 7,  -- 可以对全体敌人使用(obsoleted)
    TYPE_SHIMEN             = 8,  -- 师门类技能
    TYPE_LIVING             = 9,  -- 生活类技能
    TYPE_DEVELOP            = 10, -- 研发类技能
    TYPE_MULTI_PHY_ATTACK   = 11, -- 物理群伤技能
    TYPE_DEVELOP_EX         = 12, -- 非天生研发类技能
    CANNT_CAST_GUARD        = 13, -- 不能对守护使用的技能
    MAY_CAST_DEAD           = 14, -- 可以对死亡的目标使用
    CANNT_CAST_SELF         = 15, -- 不能对自己使用

    EFFECT_TO_SELF          = 1,  -- 对自己的技能光效
    EFFECT_TO_OTHERS        = 2,  -- 对敌方的技能光效
    EFFECT_TO_BOTH          = 3,  -- 对双方的技能光效
}

-- CMD_GENERAL_NOTIFY 使用的类别
NOTIFY = {
    CHAR_RENAME             = 1,  -- 角色改名
    DROP_TASK               = 2,  -- 放弃任务
    GET_RANK_INFO           = 3,  -- 获取排行榜数据
    DELETE_STONE_ATTRIB     = 4,  -- 删除妖石属性
    DELETE_GODBOOK_SKILL    = 5,  -- 删除宠物天书技能
    CALL_GUARD              = 6,  -- 召唤守护
    EQUIP_IDENTIFY          = 7,  -- 装备鉴定
    GUARD_USE_SKILL_D       = 8,  -- 守护是否使用辅助技能
    GUARD_SAVE_GROW         = 9,  -- 是否保存守护培养属性
    WHETHER_BUY_ITEM        = 10, -- 道具不足，询问玩家是否购买道具
    WHETHER_EXCHAGE_CASH    = 11, -- 游戏币不足，询问玩家是否兑换游戏币
    WHETHER_BUY_GOLD        = 12, -- 元宝不足，询问玩家是否充值
    NOTIFY_CLIENT_STATUS    = 16, -- 客户端状态，如未激活、已激活但长时间无输入、正常等
    GET_RECOMMEND_ATTRIB    = 26, -- 请求推荐属性加点设置(notify.h)
    GET_RECOMMEND_POLAR     = 44, -- 请求推荐相性加点设置(notify.h)
    NOTIFY_OPEN_DLG         = 97, -- 打开对话框
    NOTIFY_CLOSE_DLG        = 98, -- 关闭对话框

    RECOMMEND_FRIEND        = 13, -- 请求推荐好友列表
    VERIFY_FRIEND           = 14, -- 通过邮件系统发验证消息给对应的玩家
    GET_CHAR_INFO           = 15, -- 获取指定角色的信息，用于显示角色操作菜单
    NOTIFY_FETCH_DOUBLE_POINTS = 17, -- 领取双倍点数
    NOTIFY_FROZEN_DOUBLE_POINTS = 18, -- 冻结双倍点数
    NOTIFY_BUY_DOUBLE_POINTS = 19, -- 购买双倍点数
    NOTIFY_START_AUTO_PRACTICE = 20, --开始自动练功

    NOTIFY_OPEN_ARENA  = 21,     -- 打开竞技场界面
    NOTIFY_ARENA_TOP_BONUS_LIST = 22,   -- 获取竞技场历史最高排名奖励列表
    NOTIFY_FETCH_ARENA_RANK_BONUS = 23, -- 领取竞技场排名奖励 para1 为要领取的 rank
    NOTIFY_FETCH_ARENA_TIME_BONUS = 24, -- 领取竞技场累计排名奖励
    NOTIFY_OPEN_ARENA_SHOP = 25,        -- 打开竞技场商店
    NOTIFY_ARENA_CHALLENGE = 27,        -- 竞技场挑战对手 para1 为 key
    NOTIFY_ARENA_REFRESH_OPPONENTS = 28,-- 刷新竞技场对手列表
    NOTIFY_ARENA_BUY_TIMES = 29,        -- 购买竞技场挑战次数
    NOTIFY_ARENA_REFRESH_SHOP = 30,     -- 刷新竞技场商店
    NOTIFY_ARENA_BUY_ITEM = 31,         -- 购买竞技场商店中的物品 para1 = key
    NOTIFY_GET_LIVENESS_INFO = 32,      -- 获取活跃度信
    NOTIFY_FETCH_LIVENESS_BONUS = 33,   -- 领取活跃度奖励 para1 为奖励对应的活跃度
    NOTIFY_SHOW_RANK_PET = 34,          -- 获取排行榜中的宠物信息，用于显示宠物名片
    NOTIFY_SEND_INIT_DATA_DONE  = 39,   -- 服务器通知客户端角色数据发送完成
    NOTIFY_LEVEL_UP_PARTY = 41,         -- 升级帮派
    NOTIFY_FINISH_ALCHEMY = 46,         -- 完成炼丹
    NOTIFY_FINISH_ALCHEMY = 46,         -- 完成炼丹
    NOTIFY_EQUIP_REFORM_OK = 49,        -- 重组成功
    NOTIFY_EQUIP_REFINE_OK = 50,        -- 炼化成功
    NOTIFY_EQUIP_STRENGTHEN_OK = 51,        -- 强化成功
    NOTIFY_ENABLE_DOUBLE_POINTS = 52,        -- 开启双倍点数
    NOTIFY_EQUIP_RESONANCE_OK  = 53,    -- 装备共鸣成功
    NOTIFY_EQUIP_UPGRADE_INHERIT_OK =   54, -- 装备继承成功

    NOTIFY_FETCH_MINFO                = 100,          -- 获取信息
    NOTIFY_OPEN_CHILD_DLG_BY_TOY      = 101,          -- 通过玩具打开培养界面

    NOTIFY_BAOZANG_READY_SEARCH       = 10001,        -- 藏宝图
    NOTIFY_OPEN_STORE                 = 10002,        -- 打开仓库
    NOTIFY_CLOSE_STORE                = 10003,        -- 关闭仓库
    NOTIFY_CLOSE_PARTY                = 10006,        -- 关闭帮派相关对话框
    NOTIFY_FAST_ADD_EXTRA             = 10007,        -- 快速添加生命、法力、忠诚储备
    NOTIFY_QUERY_TEAM_EX_INFO         = 10008,        -- 查询组队信息

    NOTIFY_BAXIAN_RESET               = 11001,        -- 重置八仙梦境
    NOTIFY_BAXIAN_ENTER               = 11002,        -- 进入八仙梦境

    NOTIFY_FEED_STONE_OK              = 12000,        -- 打入妖石、补充妖石成功

    GET_EXERCISE            = 20000,    -- 获取修炼的当前轮数
    NOTICE_GET_ITEM_SUCCESS           =  20006, -- 天技商店获得物品对话框
    NOTICE_COMBAT_STATUS_INFO         =  20007, -- 获取战斗状态
    NOTIFY_AUTO_DISCONNECT            =  20011, -- 启动自动断线
    NOTIFY_QUERY_TEAM_INFO            =  20012, -- 查询周围玩家/队伍信息  参数"around_player"   "around_team"
    NOTIFY_QUERY_PARTY_SHOUWEI        =  20015, -- 查询帮派守卫信息
    NOTIFY_QUERY_PARTY_HANGBARUQIN    =  20016, -- 查询帮入侵
    NOTIFY_CHAR_CHANGE_SEX            =  20025, -- 改性别
    NOTIFY_SUBMIT_NANHWS              =  20026, -- 南荒巫术提交变身卡
    NOTIFY_EQUIP_EVOLVE_OK            =  20027, -- 装备进化结果，刷新界面
    NOTIFY_FETCH_REENTRY_ASKTAO       =  20028, -- 再续前缘，0抽奖1领奖
    NOTIFY_FETCH_LIVENESS_LOTTERY     =  20029, -- 活跃度抽奖，0抽奖1领奖
    NOTIFY_FETCH_FESTIVAL_LOTTERY     =  20030, -- 节日活动抽奖
    NOTIFY_CLOSE_GIFT_DLG             =  20033, -- 关闭福利界面
    NOTIFY_EQUIP_DEGENERATION_OK      =  20035, -- 装备退化结果

    NOTIFY_LOOK_PLAYER_EQUIP = 40005,   -- 查看玩家装备
    -- 刷道
    NOTIFY_SHUADAO_OPEN_INTERFACE     =  30002,   -- 打开刷道界面
    NOTIFY_SHUADAO_SET_OFFLINE        =  30003,   -- 设置离线刷道
    NOTIFY_SHUADAO_BUY_OFFLINE_TIME   =  30004,   -- 购买离线刷道时间
    NOTIFY_SHUADAO_DO_BONUS           =  30005,   -- 领取离线刷道奖励
    SELL_ITEM                         =  30006,   -- 出售物品

    NOTIFY_SET_COMBAT_GUARD           =  30010,   -- 设置参战守护
    NOTIFY_REMOVE_ALL_INVITE          =  30011,   -- 清除所有邀请
    NOTIFY_REMOVE_ALL_JOIN            =  30012,   -- 清除所有申请
    NOTIFY_REQUEST_MATCH_SIZE         =  30013,   -- 请求匹配队员与数量
    NOTIFY_RANK_ME_INFO               =  30017,   -- 请求排行榜我的信息
    NOTIFY_RANK_GET_GUARD             =  30018,   -- 请求排行榜守护
    NOTIFY_RANK_GET_EQUIP             =  30019,   -- 请求排行榜装备
    NOTIFY_SUBMIT_PET                 =  30020,   -- 任务提交宠物
    NOTIFY_SET_LOCK_EXP               =  30024,   -- 经验锁
    NOTIFY_SHUADAO_SET_JIJI           =  30029,   -- 急急如律令
    NOTIFT_JOIN_PARTY_WAR             =  30042,   -- 参加帮战
    NOTIFY_REQUSET_PW_BATTLE_INFO     =  30043,   -- 查询帮战中双方信息
    NOTIFY_GET_TEAM_DATA              =  30044,   -- 查询已个队伍信息

    -- 通天塔
    NOTIFY_TTT_GET_BONUS              =  40000,   -- 通天塔领取奖励
    NOTIFY_TTT_DO_REVIVE              =  40001,   -- 通天塔请求复活
    NOTIFY_TTT_JISU_FEISHENG          =  40002,   -- 通天塔急速飞升  元宝
    NOTIFY_TTT_KUAISU_FEISHENG        =  40003,   -- 通天塔快速飞升 金钱
    NOTIFY_TTT_JUMP_ASSURE            =  30025,   -- 通天塔飞升确认
    NOTIFY_TTT_JUMP_CANCEL            =  30026,   -- 通天塔飞升取消
    NOTIFY_TTT_RESET_TASK             =  40004,   -- 通天塔重置任务
    NOTIFY_TTT_GO_NEXT_LAYER          =  40006,   -- 通天塔挑战下层
    NOTIFY_TTT_LEAVE_TOWER            =  40007,   -- 通天塔离开塔

    -- 变异宠物
    NOTICE_BUY_ELITE_PET              =  50001,   -- 成功购买变异宠物

    NOTIFY_PARTY_WAR_SCORE            =  50002,   -- 帮战请求分数
    NOTIFY_PARTY_WAR_INFO             =  50003,   -- 帮战切换界面请求数据

    -- 首充
    NOTIFY_FETCH_SHOUCHONG_GIFT       =  50009,   -- 领取首充
    NOTIFY_REQUEST_REBATE_INFO        =  50010,   -- 首充状态
    NOTIFY_REQUEST_LOTTERY_INFO       =  50014,   -- 请求首充抽奖奖品
    NOTIFY_DRAW_LOTTERY               =  50011,   -- 通知服务器抽奖
    NOTIFY_CANCEL_LOTTERY             =  50013,   -- 通知服务器取消抽奖
    NOTIFY_FETCH_LOTTERY              =  50012,   -- 通知服务器领奖
    NOTIFY_FETCH_DONE                 =  50015,   -- 领奖成功

    NOTIFY_PW_AREA_NO_DATA            =  50016,   -- 帮战该赛区没有数据

    NOTIFY_IOS_REVIEW                 =  50017,   -- IOS评审信息

    NOTIFY_PW_OPEN_WINDOW             =  50018,   -- 请求打开帮战相关对话框 "1"报名  "2"本届赛程 "3"历届
    -- 聊天频道
    NOTICE_QUERY_CARD_INFO            =  20001,     --查询名片信息

    NOTIFY_START_BANGPAI_SHOUWEI      =  50004,     -- 请求开启帮派守卫
    NOTIFY_START_HANBA_RUQIN          =  50005,     -- 请求开启旱魃入侵

    NOTIFY_OPEN_NEWBIE_GIFT           =  40014,     -- 打开新手礼包
    NOTIFY_FETCH_NEWBIE_GIFT          =  40013,     -- 领取新手礼包

    NOTIFY_OPEN_DAILY_SIGN            =  40009,     -- 打开签到界面
    NOTIFY_DO_DAILY_SIGN              =  40010,     -- 进行签到

    NOTIFY_OPEN_SHENMI_DALI           =  40011,     -- 打开神秘大礼界面
    NOTIFY_OPEN_WELFARE               =  40008,     -- 打开福利界面

     NOTICE_STOP_AUTO_WALK            =  20003,     --停止自动遇敌和寻路

    NOTICE_UPDATE_MAIN_ICON           =  20002,     -- 更新主界面图标
    NOTICE_OVER_INSTRUCTION           =  20004,     -- 结束指引
    NOTIFY_FETCH_RECHARGE_GIFT        =  20018,     -- 领取充值礼包
    NOTIFY_OPEN_RECHARGE_GIFT         =  20019,     -- 打开充值礼包
    NOTIFY_FETCH_LOGIN_GIFT           =  20020,     -- 领取7天登入礼包
    NOTIFY_OPEN_LOGIN_GIFT            =  20021,     -- 打开7天登入礼包

    NOTIFY_OPEN_MY_STALL              = 40015,     --打开我的集市
    NOTIFY_STALL_REMOVE_GOODS         = 40016,     --集市下架物品
    NOTIFY_STALL_RESTART_GOODS        = 40017,     --集市重新上架
    NOTIFY_OPEN_STALL_LIST            = 40018,     --集市打开交易列表
    NOTIFY_STALL_SEARCH_ITEM          = 40019,     --集市搜索物品
    NOTIFY_STALL_OPEN_RECORD          = 40020,     --打开交易纪录
    NOTIFY_STALL_ITEM_PRICE           = 45,        --摆摊物品价格
    NOTIFY_STALL_QUERY_PRICE          = 40021,     --查询物品价格
    NOTIFY_STALL_TAKE_CASH            = 40022,     --取钱

    NOTIFY_CANCEL_MATCH_LEADER        = 40024,     -- 取消队长的匹配
    NOTIFY_CANCEL_MATCH_MEMBER        = 40025,     -- 取消队员的匹配
    NOTIFY_START_MATCH_MEMBER         = 40026,     -- 队员开始匹配
    NOTIFY_MATCH_TEAM_LIST            = 40023,     -- 请求队伍列表

    NOTIFY_BUY_INSIDER                = 50006,     -- 请求购买会员
    NOTIFY_DRAW_INSIDER_COIN          = 50007,     -- 请求领取会员元宝
    NOTIFY_REQEUST_INSIDER_INFO       = 50008,     -- 请求领取会员信息
    NOTICE_FETCH_BONUS                = 20005,     -- 领取奖励

    NOTIFY_RANDOM_NAME                = 30007,     -- 申请随机名字

    NOTIFY_ZONE_HAS_NO_TEAM_QUIT      = 30008,     -- 不可组队场景提示是否退出队伍
    NOTIFY_ZONE_HAS_NO_TEAM_CONFIRM   = 30009,     -- 不可组队场景确认退出队伍

    NOTIFY_START_AUTO_FIGHT           = 37,        -- 开启自动战斗
    NOTIFY_GUARD_NEXT_FIGHTSCORE      = 38,        -- 守护下一强化等级对应的战斗力

    NOTIFY_CLOSE_OFFLINE_SHUADAO      = 30016,     -- 关闭刷道离线

    NOTIFY_RECHARGE_COIN              = 30015,     -- 充值元宝，参数1为 充值类型

    NOTIFY_GUARD_GROW_OK              = 47,        -- 守护培养成功

    NOTIFY_EQUIP_UPGRADE_OK           = 48,        -- 武器改造成功
    NOTIFY_REQUEST_GUARD_ID           = 30021,     -- 客户端请求正在历练的守护
    NOTIFY_REQUEST_GUARD_EXPERIENCE   = 30022,     -- 守护请求历练
    NOTIFY_UPGRADE_JEWELRY_OK         = 10000,     -- 首饰合成成功
    NOTIFY_SET_USE_MONEY_TYPE         = 30023,     -- 设置使用金钱还是代金券


    NOTIFY_OPEN_EXORCISM              = 20008,     -- 开启驱魔香
    NOTIFY_CLOSE_EXORCISM             = 20009,     -- 关闭驱魔香
    NOTIFY_EXORCISM_STATUS            = 20010,     -- 驱魔香状态

    NOTIFY_MARKET_CARD                = 30027,    -- 请求物品数据

    NOTIFY_AUTO_FIGHT_SKILL           = 10004,    -- 自动战斗技能配置
    NOTIFY_AUTO_FIGHT_LESS_MANA       = 10005,    -- 自动战斗缺蓝配置

    NOTIFY_MARKET_CHECK_GOOD          = 30028,    -- 检查收藏

    NOTIFY_TEAM_ASK_AGREE             = 30030,    -- 组队同意
    NOTIFY_TEAM_ASK_REFUSE            = 30031,    -- 组队拒绝

    NOTIFY_CONFIRE_RESULT             = 30037,    -- 倒计时结束

    NOTIFY_DELETE_CHAR                = 30032,    -- 删除角色
    NOTIFY_RESPONS_SECRET             = 30033,    -- 删除角色输入密码

    NOTIFY_CANCEL_DELETE_CHAR         = 30034,    -- 取消删除角色

    NOTIFY_GUARD_BASIC_ATTRI          = 30038,    -- 请求守护基础属性
    NOTIFY_NEXT_GUARD_INFO            = 30039,    -- 请求下一等级的守护数据
    NOTIFY_TONGTT_GET_TASK            = 30040,    -- 选择通天塔奖励

    NOTIFY_QUERY_PARTY_SALARY         = 20013,    -- 查询帮派俸禄
    NOTIFY_QUERY_PARTY_CONTRIBUTOR    = 20014,    -- 查询功臣奖励

    NOTIFY_COMBAT_GET_CUR_ROUND       = 30041,    -- 获取战斗的当前轮次
    NOTIFY_QUERY_SHIDAO_INFO          = 20017,    -- 查询试道信息
    NOTIFY_BUY_JIJI                   = 30045,    -- 购买急急如律令

    NOTIFY_REQUEST_BUYBACK_CARD       = 50019,    -- 客户端请求回购物品名片
    NOTIFY_BUY_BACK                   = 50020,    -- 通知回购物品

    NOTIFY_EQUIP_IDENTIFY             = 20022,    -- 装备鉴定成功后，向客户端发送MSG_GENERAL_NOTFY消息
    NOTIFY_FINISH_GATHER              = 20023,    -- 结束采集
    NOTIFY_EQUIP_IDENTIFY_GEM         = 20031,    -- 宝石鉴定结果
    NOTIFY_HIGHER_JEWELRY_RECAST_OK   = 20034,    --高级首饰重铸成功

    NOTIFY_ENABLE_SHENMU_POINTS       = 10009,   -- 开关神木鼎点数
    NOTIFY_BUY_SHENMU_POINTS          = 10010,   -- 购买神木鼎点数

    NOTIFY_SUBMIT_EQUIP               = 20024,   -- 提交装备操作

    NOTIFY_SHUADAO_SET_CHONGFENGSAN   = 30046,   -- 刷道设置宠风散状态
    NOTIFY_BUY_CHONGFENGSAN           = 30047,   -- 购买宠风散点数

    NOTIFY_STALL_BATCH_NUM            = 10011,   -- 通知客户端集市商品可上架的数量
    NOTIFY_MAIL_ALL_LOADED            = 10012,   -- 通知客户端加载所有邮件完毕

    NOTIFY_MOUNT_MERGE_RESULT         = 61000,   -- 骑宠融合结果

    NOTIFY_SHUADAO_SET_ZIQIHONGMENG   = 30048,   -- 刷道设置紫气鸿蒙状态
    NOTIFY_BUY_ZIQIHONGMENG           = 30049,   -- 购买紫气鸿蒙点数

    NOTIFY_BUY_HOUSE_RESULT           = 61002,  -- 购买居所

    NOTIFY_HIDE_NPC                   = 61003,  -- 通知渐隐NPC
    NOTIFY_FRIEND_CLEAR_XINMO         = 61004,  -- 好友协助清除心魔
    NOTIFY_JOIN_PARTY                 = 99,     -- 加入帮派
    NOTIFY_ASSIGN_XMD                 = 50021,  -- 通知客户端仙魔加/洗点完毕

    NOTIFY_TTTD_LEAVE_TOWER           = 50022,  -- 离开通天塔顶

  --  NOTIFY_ZUHE_SKILL_TARGET          = 65535, -- 组合技能目标选择，用于在线更新
}

TASK = {
    ATTRIB_DROP_FLAG        = 1,    -- 任务可放弃
    ATTRIB_LIGHT_SERCH_MASTER        = 3,    -- 师徒界面寻师是否加光效
    ATTRIB_LIGHT_SERCH_APPRENTICE        = 4,    -- 师徒界面寻徒是否加光效
    ATTRIB_NOT_AUTO_WALK    = 5,    -- 是否执行自动任务
    TASK_ATTRIB_ATTACH_EFFECT = 6,  -- 附加属性任务
    TASK_ATTRIB_DESC_APPEND_LOG = 7, -- 任务介绍附加提示信息
    TASK_ATTRIB_CLOSE_EXORCISM = 8,  -- 玩家点击任务自动寻路信息时，需要弹出关闭驱魔香的提示

}

EFFECT_TYPE = {
    FRONT             = 0,    -- 光效在角色前面显示
    BEHIND          = 1,  --光效在人物后面显示（默认显示在人物前面）
    GLOBAL          = 2,  --光效全局播放
    SPECIAL         = 3,  --技能名称在光效播放者身上
    LOCATION_HEAD   = 4,  --角色头顶
    LOCATION_WAIST  = 5,  --角色腰上
    ARMATURE_MAP    = 6,  -- 目录map中的骨骼动画
    ARMATURE_SKILL  = 7,  -- 目录skill中的骨骼动画
    IS_LOOP_EFFECT  = 8,  -- 是否是循环光效
    TOP             = 9,  -- 光效顶层显示
    BOTTOM          = 10,  -- 光效底层显示
}

ARMATURE_TYPE = {
    ARMATURE_MAP            = 1,    -- 地图
    ARMATURE_SKILL          = 2,    -- 技能
    ARMATURE_CHAR           = 4,    -- 角色
    ARMATURE_UI             = 5,    -- UI
}

-- 角色相性
POLAR = {
    METAL   = 1,    -- 金
    WOOD    = 2,    -- 木
    WATER   = 3,    -- 水
    FIRE    = 4,    -- 火
    EARTH   = 5,    -- 土
}

-- 相型对应的门派信息
FAMILY = {
    [POLAR.METAL]     = CHS[5000101],
    [POLAR.WOOD]      = CHS[5000102],
    [POLAR.WATER]     = CHS[5000103],
    [POLAR.FIRE]      = CHS[5000104],
    [POLAR.EARTH]     = CHS[5000105],
}

-- 门派对应的相性
FAMILYTOPOLAR = {
    [CHS[5000101]] = POLAR.METAL,
    [CHS[5000102]] = POLAR.WOOD,
    [CHS[5000103]] = POLAR.WATER,
    [CHS[5000104]] = POLAR.FIRE,
    [CHS[5000105]] = POLAR.EARTH,
}

GUARD_RANK = {
    TONGZI = 1,     -- 童子
    ZHANGLAO = 2,   -- 长老
    SHENLING = 3,      -- 神灵
}

ITEM_ATTRIB = {
    IN_COMBAT           = 2,    -- 物品可以在战斗时使用
    IN_NORMAL           = 3,    -- 物品可以在平时使用
    APPLY_ON_VICTIM     = 4,    -- 物品可以对战斗敌人使用
    APPLY_ON_FRIEND     = 5,    -- 物品可以对战斗队友/组队队友使用
    APPLY_ON_MYSELF     = 6,    -- 物品可以对自己使用
    APPLY_NO_TARGET     = 7,    -- 物品不需要制定任何使用对象
    APPLY_ON_PET        = 8,    -- 物品只能对宠物使用
    APPLY_ON_USER       = 9,    -- 物品只能对玩家使用
    CANT_DROP           = 10,   -- 物品不能丢弃
    CANT_TRADE          = 11,   -- 物品不能交易
    CANT_GIVE           = 12,   -- 物品不能给予
    ITEM_CAN_MAIL       = 13,   -- 物品可以通过邮件寄出
    CLIENT_NOT_ERASE    = 14,   -- 物品使用后不消失
    EXT_DIALOG_BOX      = 15,   -- 使用物品前要有对话框提示
    CAN_MAKE_PILL       = 16,   -- 物品是个用来炼丹的法宝
    CANT_SELL           = 17,   -- 物品不能出售
    CANT_STORE          = 18,   -- 物品不能存储
    CANT_GET            = 19,   -- 物品不能拾取
    APPLY_WHEN_LOCKED   = 20,   -- 物品可以在加锁后使用
    APPLY_ON_GUARD      = 21,   -- 物品只能对守护使用
    CAN_SELL_TO_NPC     = 22,   -- 物品可以对NPC出售
    CAN_SAVE_SPECIAL    = 23,   -- 物品可以在会员行囊保存（针对下线消失的道具）
    ITEM_APPLY_ON_GUIDE = 24,   -- 物品可以优先在指引中使用
    ITEM_APPLY_SHOW_MAIL    = 25,   -- 物品的使用按钮显示为邮寄
    ITEM_CHECK_SAFE_LOCK    = 26,   -- 物品需要检测安全锁
    ITEM_FAST_USE       = 27,   -- 快捷使用界面使用该物品后关闭快捷使用界面
}

ITEM_COMBINED = {
    ITEM_COMBINED_NO        = 0,    -- 不能堆叠
    ITEM_COMBINED_NM        = 1,    -- 普通堆叠，道具不带 iid
    ITEM_COMBINED_EX        = 2,    -- 道具带 iid 的堆叠
}

EQUIP = {
    WEAPON           = 1 , -- 武器
    HELMET           = 2 , -- 头盔
    ARMOR            = 3 , -- 衣服
    NECKLACE         = 4 , -- 项链
    BALDRIC          = 5 , -- 玉佩
    LEFT_WRIST       = 6 , -- 左手镯
    RIGHT_WRIST      = 7 , -- 右手镯
    TALISMAN         = 8 , -- 符具
    ARTIFACT         = 9 , -- 法宝
    BOOT             = 10, -- 鞋子

    BACK_WEAPON      = 11, -- 备用武器
    BACK_HELMET      = 12, -- 备用头盔
    BACK_ARMOR       = 13, -- 备用衣服
    BACK_BOOT        = 14, -- 备用鞋子
    BACK_BALDRIC     = 15, -- 备用玉佩
    BACK_NECKLACE    = 16, -- 备用项链
    BACK_LEFT_WRIST  = 17, -- 备用左手镯
    BACK_RIGHT_WRIST = 18, -- 备用右手镯
    BACK_ARTIFACT    = 19, -- 备用法宝

    FASION_START     = 31, -- 时装开始位置
    FASHION_SUIT     = 31, -- 时装套装(旧代码，兼容)
    FASHION_JEWELRY  = 32, -- 时装首饰(旧代码，兼容)
    FASION_DRESS     = 31, -- 时装礼服
    FASION_BALDRIC   = 32, -- 时装玉佩
    FASION_HAIR      = 33, -- 自定义外观 - 发型 (新增)
    FASION_UPPER     = 34, -- 自定义外观 - 上身 (新增)
    FASION_LOWER     = 35, -- 自定义外观 - 下身 (新增)
    FASION_ARMS      = 36, -- 自定义外观 - 武器 (新增)
    EQUIP_FOLLOW_PET = 37, -- 跟随宠
    FASION_BACK      = 38, -- 自定义外观 - 背饰 (新增)
    FASIONG_END      = 38, -- 时装结束位置
}

EQUIP_TYPE = {
    WEAPON           = 1 , -- 武器类
    HELMET           = 2 , -- 头盔类
    ARMOR            = 3 , -- 衣服类
    NECKLACE         = 4 , -- 项链类
    BALDRIC          = 5 , -- 玉佩类
    WRIST            = 6 , -- 手镯类
    TALISMAN         = 8 , -- 符具类
    ARTIFACT         = 9 , -- 法宝类
    BOOT             = 10, -- 鞋子类
    FASHION_SUIT     = 16, -- 时装套装
    FASHION_JEWELRY  = 17, --时装首饰
    FASHION_PART     = 18, -- 自定义部件
}

ITEM_TYPE = {
    EQUIPMENT        = 1,    -- 装备
    MEDICINE         = 2,    -- 药品
    TASK_ITEM        = 3,    -- 任务物品
    BOOK             = 4,    -- 书籍
    SPECIAL_ITEM     = 5,    -- 特殊物品
    UPGRADE_ITEM     = 6,    -- 升级物品
    ARTIFACT         = 7,    -- 法宝
    TELEPORT         = 8,    -- 传送道具
    SERVICE_ITEM     = 9,    -- 付费服务道具
    CHARGE_ITEM      = 10,   -- 付费功能道具
    CARPET           = 11,   -- 地毯道具
    CHANGE_LOOK_CARD = 12,   -- 变身卡
    GODBOOK          = 13,   -- 天书
    GIFT             = 14,   -- 礼包

    FURNITURE        = 18,   -- 家具
    PLANT_MATERIAL   = 19,   -- 种植收获的材料
    DISH             = 20,   -- 菜肴
    FISH             = 21,   -- 居所中钓到的鱼
    EFFECT           = 23,   -- 特效
    FOLLOW_ELF       = 24,   -- 跟随小精灵
    CUSTOM           = 25,   -- 自定义外观道具
    FIREWORK         = 26,   -- 烟花

    TOY              = 28,   -- 玩具
}

CHAT_CHANNEL = {
    MISC                   = 0,   -- 混合频道
    CURRENT                = 1,   -- 当前频道
    WORLD                  = 2,   -- 世界频道
    TELL                   = 3,   -- 私聊频道
    TEAM                   = 4,   -- 队伍频道
    PARTY                  = 5,   -- 帮会频道
    RUMOR                  = 6,   -- 谣言频道
    SYSTEM                 = 7,   -- 系统频道
    ERROR                  = 8,   -- 错误信息
    FRIEND                 = 9,   -- 好友频道
    DEBUG                  = 10,  -- 调试频道
    FAMILY                 = 11,  -- 门派频道
    INFO                   = 12,  -- 信息频道
    TRADE                  = 13,  -- 交易频道
    MANAGE                 = 14,  -- 管理频道  --此频道要废除，被CS代替了
    CS                     = 14,  -- 客服频道
    WHOOP                  = 15,  -- 呐喊频道
    RAID                   = 16,  -- 团队频道
    HEAD                   = 17,  -- 头顶频道（在头顶弹出内容，且不在当前频道显示）
    IMPEACH                = 18,  -- 举报频道（玩家举报时，转发给ADMINTOOL）
    ADNOTICE               = 19,  -- 公告
    TEAM_INFO              = 20,  -- 队伍信息
    CHAT_GROUP             = 22,  -- 群组聊天
    HORN                   = 30,  -- 喇叭
    WEDDING                = 31,  -- 婚礼弹幕
    TEAM_ENLIST            = 20001, -- 队伍招募
    MATCH_MAKING           = 20000,-- 情缘界面
}

CHANNEL_TIP_TYPE = {
    SHOCK = 1,
}

RANK_TYPE = {
    -- 大类排行榜
    CHAR                  = 1,      -- 个人排行榜
    EQUIP                 = 2,      -- 装备排行榜
    PET                   = 3,      -- 宠物排行榜
    GUARD                 = 4,      -- 守护排行榜
    PARTY                 = 5,      -- 帮派排行榜
    GET_TAO               = 6,      -- 挑战排行榜
    CHALLENGE             = 7,      -- 挑战排行榜
    PK                    = 8,      -- PK排行榜
    HOUSE                 = 9,      -- 居所排行
    SYNTH                 = 10,     -- 总和排行
    ZDD                   = 11,     -- 证道殿


    -- 个人排行榜的子类排行榜
    CHAR_LEVEL            = 101,
    CHAR_TAO              = 102,    -- 道行排行
    CHAR_PHY_POWER        = 103,    -- 物攻排行
    CHAR_MAG_POWER        = 104,    -- 法攻排行
    CHAR_SPEED            = 105,    -- 速度排行
    CHAR_DEF              = 106,    -- 防御排行
    CHAR_UPGRADE_LEVEL    = 107,    -- 元婴血婴排行
    CHAR_MONTH_TAO        = 108,    -- 本月道行排行

    -- 装备排行榜的子类排行榜
    EQUIP_WEAPON                = 201,
    EQUIP_HELMET                = 202,
    EQUIP_ARMOR                 = 203,
    EQUIP_BOOT                  = 204,
    EQUIP_LEVEL_ONE             = 205,
    EQUIP_LEVEL_TWO             = 206,
    EQUIP_LEVEL_THREE           = 207,
    EQUIP_LEVEL_FOUR            = 208,
    EQUIP_LEVEL_FIVE            = 209,
    EQUIP_LEVEL_SIX             = 210,

    -- 宠物排行榜的子类排行榜
    PET_MARTIAL           = 301,    -- 武学排行
    PET_PHY_POWER         = 302,    -- 物攻排行
    PET_MAG_POWER         = 303,    -- 法攻排行
    PET_SPEED             = 304,    -- 速度排行
    PET_DEF               = 305,    -- 防御排行

    -- 守护排行榜子类排行
    GUARD_PHY_POWER             = 401,
    GUARD_MAG_POWER               = 402,
    GUARD_SPEED                 = 403,
    GUARD_DEF                   = 404,

    -- 帮派排行子类排行
    PARTY_MONEY                 = 501,
    PARTY_WAR                   = 502,
    PARTY_WELFARE               = 503,

    -- 刷道排行
    GET_TAO_CHUBAO              = 601,
    GET_TAO_XIANGYAO            = 602,
    GET_TAO_FUMO                = 603,
    GET_TAO_FXDX                = 604,

    -- 挑战排行
    CHALLENGE_ARENA             = 701,
    CHALLENGE_TOWER             = 702,
    CHALLENGE_DART              = 703,
    CHALLENGE_PET               = 704,

    -- PK排行榜
    PK_BULLY                    = 801,
    PK_POLICE                   = 802,

    -- 居所排行
    HOUSE_COMFORT               = 901,

    -- 成就点数
    SYNTH_ACHIEVE     = 1001,
    SYNTH_BLOG_POPULAR          = 1002,


    -- 证道殿排行
    ZDD_METAL              = 1101,
    ZDD_WOOD               = 1102,
    ZDD_WATER              = 1103,
    ZDD_FIRE               = 1104,
    ZDD_EARTH              = 1105,

    --
    HERO              = 1201,
}

-- 角色设置信息settings_flag:
SETTING_FLAG = {
    REFUSE_BE_JOINT         = 1,    -- 拒绝接受组队申请
    REFUSE_FIGHT            = 2,    -- 拒绝切磋武艺
    REFUSE_BE_ADDED         = 3,    -- 拒绝被加为好友
    REFUSE_STRANGER_MSG     = 4,    -- 拒绝陌生人消息
    REFUSE_ALL_MSG          = 5,    -- 拒绝所有人消息
    REFUSE_WORLD_MSG        = 6,    -- 拒绝world频道消息
    REFUSE_TELL_MSG         = 7,    -- 拒绝tell频道消息
    REFUSE_TEAM_MSG         = 8,    -- 拒绝team频道消息
    REFUSE_PARTY_MSG        = 9,    -- 拒绝party频道消息
    REFUSE_RUMOR_MSG        = 10,    -- 拒绝rumor频道消息
    REFUSE_FRIEND_MSG       = 11,    -- 拒绝friend频道消息
    REFUSE_FAMILY_MSG       = 12,    -- 拒绝family频道消息
    REFUSE_CS_MSG           = 13,    -- 拒绝custom_service频道消息
    REFUSE_REQUEST_PARTY    = 14,    -- 拒绝接收入帮请求
    REFUSE_LOOK_EQUIP       = 15,    -- 拒绝查看装备
    REFUSE_WARCRAFT         = 16,    -- 拒绝比武
    VERIFY_BE_ADDED         = 17,    -- 加入好友时要验证
    HIDE_WORLD_MSG          = 18,    -- 隐藏world频道消息
    HIDE_PARTY_MSG          = 19,    -- 隐藏party频道消息
    HIDE_TEAM_MSG           = 20,    -- 隐藏team频道消息
    HIDE_SYSTEM_MSG         = 21,    -- 隐藏system频道消息
    AUTOPLAY_PARTY_VOICE    = 22,    -- 自动播放party语音
    AUTOPLAY_TEAM_VOICE     = 23,    -- 自动播放team语音
    FORBIDDEN_PLAY_VOICE    = 24,    -- 禁止播放语音
    SIGHT_SCOPE             = 25,    -- 视野大小
    HIDE_CURRENT_MSG        = 26,    -- 隐藏current频道消息
    HIDE_RUMOR_MSG          = 27,    -- 隐藏rumor频道消息
    PUSH_BIAOXING_WANLI     = 28,    -- 推送镖行万里
    PUSH_HAIDAO_RUQIN       = 29,    -- 推送海盗入侵
    PUSH_CHANCHU_YAOWANG    = 30,    -- 推送铲除妖王
    PUSH_SHIDAO_DAHUI       = 31,    -- 推送试道大会
    PUSH_SHUADAO_DOUBLE     = 32,    --推送刷道双倍
}

SETTING = {
    SETTING_REFUSE_WORLD_MSG        = "refuse_world_msg",      -- 拒绝world频道消息
    SETTING_REFUSE_TELL_MSG         = "refuse_tell_msg",       -- 拒绝tell频道消息
    SETTING_REFUSE_TEAM_MSG         = "refuse_team_msg",       -- 拒绝team频道消息
    SETTING_REFUSE_PARTY_MSG        = "refuse_party_msg",      -- 拒绝party频道消息
    SETTING_REFUSE_RUMOR_MSG        = "refuse_rumor_msg",      -- 拒绝rumor频道消息
    SETTING_REFUSE_FRIEND_MSG       = "refuse_friend_msg",     -- 拒绝friend频道消息
    SETTING_REFUSE_FAMILY_MSG       = "refuse_family_msg",     -- 拒绝family频道消息
    SETTING_REFUSE_CS_MSG           = "refuse_cs_msg",         -- 拒绝custom_service频道消息
    SETTING_REFUSE_RAID_MSG         = "refuse_raid_msg",       -- 拒绝raid频道消息
    SETTING_REFUSE_REQUEST_PARTY    = "refuse_request_party",  -- 拒绝接收入帮请求
    SETTING_REFUSE_PARTY_AUDIO      = "refuse_party_audio",    -- 拒绝帮派语音
    SETTING_REFUSE_TEAM_AUDIO       = "refuse_team_audio",     -- 拒绝帮派语音
}

-- 权限
PRIVILEGE = {
    STANDARD        = 0,    -- Normal user
    ADMINISTRATOR   = 120,  -- Game administrator
    OBSERVER        = 130,  -- Game observer
    BEHOLDER        = 200,  -- Game beholder
    CONTROLLER      = 300,  -- Game controller
    DEBUGGER        = 1000, -- Server debugger
}

-- 角色状态char_status:
CHAR_STATUS = {
    TEAM_LEADER             = 1,        -- 队长状态
    IN_TEAM                 = 2,        -- 组队中
    IN_COMBAT               = 3,        -- 战斗中
    IN_LOOKON               = 4,        -- 战斗中
}

-- 帮战信息类型
PARTY_TYPE = {
    BID_INFO_TYPE                     = 1,  -- 报名竞价信息
    SCORE_INFO_TYPE                   = 2,  -- 积分排名信息
    SCHEDULE_INFO_TYPE                = 3,  -- 帮战进度信息
    HISTORY_INFO_TYPE                 = 4,  -- 帮战历史记录
    HISTORY_DETAL_COST                = 5,  -- 查看帮战历史详情的花费
    CHAR_PARTY_INFO                   = 6,  -- 角色的帮派阵营信息
    HISTORY_DETAL_SCHEDULE            = 7,  -- 帮战历史的详细信息
    SCHEDULE_INFO_TYPE_EX             = 8,  -- 帮战进度信息（新帮战中使用）
    HISTORY_DETAL_SCHEDULE_EX         = 9,  -- 帮战历史的详细信息（新帮战中使用）
    SCORE_INFO_TYPE_EX                = 10, -- 积分排名信息（新帮战中使用）
    WAR_SERVER                        = 11, -- 举行帮战的服务器
    PARTY_HISTORY_PAGE_TYPE           = 12, -- 帮战历史数据页数
}

-- 帮战结果
PARTY_COMPETITION_RESULT = {
    DRAW                    = "draw",          -- 平局
    ATTACKER_WIN            = "attacker_win",  -- 客场胜
    DEFENSER_WIN            = "defenser_win",  -- 主场胜
    INVALID                 = "invalid",       -- 无效
    PREPARE                 = "",               -- 还没有开始
    LUNKONG                 = "lunkong",         -- 轮空
}

-- 帮战比赛阶段
COMP_STAGE = {
    OTHER                   = "0",                --其他非帮战比赛阶段
    GROUP_STAGE             = "1",                --小组赛
    KNOCKOUT_1              = "2",                --淘汰赛第一场
    KNOCKOUT_2              = "3",                --淘汰赛第二场
    KNOCKOUT_3              = "4",                --淘汰赛第三场（3、4名争夺）
    KNOCKOUT_4              = "5",                --淘汰赛第四场（1、2名争夺）
}

-- 赛区
COMP_ZONE = {
    A                       = "1",    -- A赛区
    B                       = "2",    -- B赛区
    C                       = "3",    -- C赛区
}

-- 兑换游戏币
SilverToCash = {
    [1] = {cash = 3000000, silver = 300, barcode = "C0000001"},
    [2] = {cash = 6000000, silver = 600, barcode = "C0000002"},
    [3] = {cash = 10000000, silver = 1100, barcode = "C0000003"},
    [4] = {cash = 30000000, silver = 3300, barcode = "C0000004"},
    [5] = {cash = 60000000, silver = 7200, barcode = "C0000005"},
    [6] = {cash = 100000000, silver = 12000, barcode = "C0000006"},
}
TEAM_MATCH_TYPE = {
    TEAM_TYPE_ALL         = 0,
    TEAM_TYPE_CHUBAO      = 1,
    TEAM_TYPE_XIANGYAO    = 2,
    TEAM_TYPE_FUMO        = 3,
    TEAM_TYPE_XIANRZL     = 4,
    TEAM_TYPE_XIUXING     = 5,
    TEAM_TYPE_HEIFD       = 6,
    TEAM_TYPE_LIEHJ       = 7,
    TEAM_TYPE_LANRS       = 8,
    TEAM_TYPE_BAINXWL     = 9,
    TEAM_TYPE_HAIDRQ      = 10,
    TEAM_TYPE_TIANGX      = 11,
    TEAM_TYPE_DISX        = 12,
    TEAM_TYPE_LIANGONG    = 13,

    TEAM_TYPE_XUANS       = 15,
    TEAM_TYPE_SHIJUEZHEN  = 16,
    TEAM_TYPE_PIAOMXF     = 17,
    TEAM_TYPE_FXDX        = 18, --飞仙渡邪

    TEAM_TYPE_KFJJC_3V3   = 19, -- 跨服竞技场3V3
    TEAM_TYPE_KFJJC_5V5   = 20, -- 跨服竞技场5V5
}

CONST_DATA = {
    loadNumber = 10,-- 每次滚动加载的条目
    initNumber = 30,-- 初值化聊天条目
    cellSpace = 10,
    containerTag = 999,
    CS_TYPE_STRING = 1,
    CS_TYPE_IMAGE = 2,
    CS_TYPE_BROW = 3,
    CS_TYPE_ANIMATE = 4,
    CS_TYPE_NPC = 5,
    CS_TYPE_ZOOM = 6,
    CS_TYPE_URL = 7,
    CS_TYPE_CARD = 8,
    CS_TYPE_DLG = 9,
    CS_TYPE_TEAM = 10,
    CS_TYPE_CALL = 11,
}

NOTIFICATION = {
    PARTY               = 1,
    PARTY_REQUEST       = 2,
    REMOVE_REQUES       = 3,
}

--数字NumImg在物品Panel中的的摆放位置
LOCATE_POSITION = {
    LEFT_TOP            = 1,    -- 左上
    RIGHT_TOP           = 2,    -- 右上
    LEFT_BOTTOM         = 3,    -- 左下
    RIGHT_BOTTOM        = 4,    -- 右下
    CENTER              = 5,    -- 左偏上下居中
    MID                 = 6,    --中间
    MID_TOP             = 7,    --中上
    MID_BOTTOM          = 8,    --中下
}

-- 主界面的图标状态
MAIN_UI_STATE = {
    STATE_HIDE          = 0,    -- 隐藏状态
    STATE_SHOW          = 1,    -- 显示状态
    STATE_NOTHING       = 2,    -- 无状态
}

-- 金钱类型
MONEY_TYPE = {
    CASH    = 0,
    VOUCHER = 1,
}

BATTERY_HEALTH = {
    OVERHEAT        = 0x00000003,
}

BATTERY_STATE = {
    UNKNOWN         = 0x00000001,   -- 电池没找到
    CHARGING        = 0x00000002,   -- 充电中
    DISCHARGING     = 0x00000003,   --
    NOT_DISCHARGING = 0x00000004,
    FULL            = 0x00000005,   -- 充满了
}

-- 网络类型状态
NET_TYPE = {
    NULL = -1,
    WIFI = 1;
    WAP  = 2;
    NET  = 3;
}

-- 游戏运行状态
GAME_RUNTIME_STATE = {
    PRE_LOGIN       = 1,   -- 登录之前，即点击进入游戏之前
    LOGINING        = 2,   -- 登录游戏中，即进入游戏的第一次过场动画，包括新手战斗阶段
    MAIN_GAME       = 3,   -- 主游戏界面
    QUIT_GAME       = 4,   -- 退出游戏过程
}

-- Magic类型
MAGIC_TYPE = {
    NORMAL = 0,
    MAP    = 1,
}

-- 菜单类型
MENUITEM_FLAG = {
    DIRECT_SELECTED =   '@',    -- 直接被选择的标志
    CRAY_DRAW       =   '~',    -- 灰色显示（不可选）
    OKCANCEL        =   '!',    -- 弹出确定及取消按钮
    PASSWORD        =   '*',    -- 密码处理
}

-- 菜单标示
MIF = {
    NONE = 1,               -- 无
    DIRECT_SELECTED = 2,    -- 直接被选择的标志
    CRAY_DRAW = 3,          -- 灰色显示（不可选）
    OKCANCEL = 4,           -- 弹出确定及取消按钮
    PASSWORD = 5,           -- 密码显示
}

-- 菜单显示模式
MENUITEM_FORMAT = {
    PROMPT       = "#prompt:",
    LEN          = "#LEN:",
    MINLEN       = "#MINLEN:",
    DLG          = "#DLG:",
    ECARD_DLG    = "#ECARDDLG:",
    DEFAULT_TEXT = "#TEXT:",         -- 默认内容
    MAX          = "#MAX:",          -- 默认内容
    TIP          = "#TIP:",
}

MENUITEM_FORMATS = {
    MENUITEM_FORMAT.PROMPT,
    MENUITEM_FORMAT.LEN,
    MENUITEM_FORMAT.MINLEN,
    MENUITEM_FORMAT.DLG,
    MENUITEM_FORMAT.ECARD_DLG,
    MENUITEM_FORMAT.DEFAULT_TEXT,
    MENUITEM_FORMAT.MAX,
    MENUITEM_FORMAT.TIP,
}

SERVER_STATUS = {
    PRESERVER   = 1, -- 维护
    NORMAL      = 2, -- 正常
    BUSY        = 3, -- 繁忙
    FULL        = 4, -- 爆满
    ALLFULL     = 5, -- 满员
    FREE        = 6, -- 空闲
}

CONFIRM_TYPE = {
    EXIT_GAME = 1,   -- 退出游戏打开确认框
    FROM_SERVER = 2, -- 由服务器通知客户端打开确认框,仅限于通用消息中。NOTIFY.NOTIFY_OPEN_CONFIRM_DLG需要标记！
}

WAIT_LINE_STATUS = {
    NONE = -1,      -- 客户端使用状态，表示没有请求到服务端消息
    WAIT = 0,       -- 正在登录的队列,服务器将会断开连接
    PRE_LOGIN = 1,  -- 未登录正在排队队列,服务器将会在10s内保持连接
    LOGINING = 2,   -- 当前等待登录队列,正在登录队列,服务器保持连接
    COMPLATE = 3,   -- 登录完成
}

WAIT_LINE_NAME = {
    NORMAL = "normal",  -- 正常队列
}

GM_LIMITS = {
    GA  = 120,
    GA1 = 130,
    GA2 = 140,
    GA3 = 150,
    GB  = 200,
    GC  = 300,
    GD  = 1000,

    G1  = 101,
    G2  = 102,
    G3  = 103,
    G4  = 104,
}

-- 分享类型
SHARE_TYPE = {
    WECHAT          = 1,
    WECHATMOMENTS   = 2,
    QQ              = 3,
    QZONE           = 4,
    SINAWEIBO       = 5,
    ATMBLOG         = 6,
}

-- 需要分享内容的类型
SHARE_FLAG = {
    USERATTRIB = "UserAttrib",
    RANKING = "rank",
    PETATTRIB = "PetAttrib",
    GETELITEPET = "GetElitePet",
    SHIDAOWZJL = "ShiDaoWZJL",
    CHALLENGLEADER = "ChallengLeader",
    EQUIPATTRIB = "EquipAttrib",
    SYSCONFIG = "SysConfig",
    LEITAI  =   "leitai",
    KFSDJL  = "kfsdjl",
    JIEBAI = "jiebai",
    KFZCJL = "kfzcjl",
    DCDHJL = "dcdhjl",
    KFJJJL = "kfjjjl",
    MRZBJL = "mrzbjl",
    HFFC    = "hffc",
    YXFC  = "yxfc",
    SSZJJ = "sszjj",
    QUANMINPK = "quanminpk",
    QUANMINPKJL = "quanminpkjl",
    FIXTEAM = "fixedteam",
    TRADINGSPOTRANK = "TradingSpotRank",
    HANCHENGHUDONG = "hanchenghudong",

    DIRECT = "direct",
    WUXINGGUESS = "wuxingguess",
    ZHOUNIANQING = "zhounianqing",

    -- 下面配置需要记录分享日志的分享类型,与文档对应
    ["UserAttrib"]          = 1,    -- 角色属性界面点击分享
    ["rank"]                = 2,    -- 排行榜界面点击分享
    ["PetAttrib"]           = 3,    -- 宠物属性、宠物坐骑界面点击分享
    ["GetElitePet"]         = 4,    -- 领取变异、神兽、获得精怪界面点击分享
    ["ShiDaoWZJL"]          = 5,    -- 试道王者领取奖励点击分享
    ["ChallengLeader"]      = 6,    -- 掌门界面点击分享
    ["EquipAttrib"]         = 7,    -- 装备、首饰、法宝、魂器、装备对比、首饰对比、法宝对比、魂器对比悬浮框、时装名片点击分享
    ["SysConfig"]           = 8,    -- 系统设置界面点击分享
    ["leitai"]              = 9,    -- 擂台争霸点击分享按钮分享
    ["kfsdjl"]              = 10,   -- 跨服试道领取奖励点击分享
    ["jiebai"]              = 11,   -- 结拜确认界面点击分享
    ["kfzcjl"]              = 12,   -- 跨服战场领取奖励点击分享
    ["dcdhjl"]              = 13,   -- 斗宠大会领取奖励点击分享
    ["kfjjjl"]              = 14,   -- 跨服竞技领取奖励点击分享
    ["mrzbjl"]              = 15,   -- 名人争霸赛领取奖励点击分享
    ["hffc"]                = 16,   -- 护法风采界面点击分享
    ["yxfc"]                = 17,   -- 英雄风采界面点击分享
    ["sszjj"]               = 18,   -- 生死状家具界面点击分享
    ["quanminpk"]           = 19,   -- 全民PK分享界面点击分享
    ["quanminpkjl"]         = 20,   -- 全民PK领取淘汰赛、决赛奖励点击分享
    ["fixedteam"]           = 21,   -- 结成固定队确认界面点击分享
    ["TradingSpotRank"]     = 22,   -- 商贾货站十大巨商界面点击分享
    ["hanchenghudong"]      = 23,   -- 跨服赛事接引人处点击分享《悍城》互动
}

-- 生肖编号
SHENGX = {
    SHU  = 1,
    NIU  = 2,
    HU   = 3,
    TU   = 4,
    LONG = 5,
    SHE  = 6,
    MA   = 7,
    YANG = 8,
    HOU  = 9,
    JI   = 10,
    GOU  = 11,
    ZHU  = 12
}

-- 分享类型
SAFE_LOCK_STATE = {
    NO_LOCK = 1,            -- 未设置
    BE_LOCK = 2,            -- 已设置
    FORCE_TO_UNLOCL = 3,    -- 强制解除
}

-- 变身卡类型
CARD_TYPE = {
    MONSTER = 1,
    ELITE = 2,
    BOSS = 3,
    EPIC = 4,
}

-- 变身卡排序不同类型的优先级
ORDER_BY_CARD_TYPE = {
    [CARD_TYPE.MONSTER] = 1,
    [CARD_TYPE.ELITE] = 2,
    [CARD_TYPE.EPIC] = 3,
    [CARD_TYPE.BOSS] = 4,
}

-- 性别
GENDER_TYPE = {
    MALE = 1,
    FEMALE = 2,
}

GENDER_NAME = {
    [GENDER_TYPE.MALE] = CHS[5000066],
    [GENDER_TYPE.FEMALE] = CHS[5000067],
}

-- 函数ID
FUNCTION_ID =
{
    VIBRATE                 = 1, -- 震动
    CANCEL_VIBRATE          = 2, -- 取消震动
    FTP_UPLOAD_LOG          = 3, -- 上传android日志
    HELPER_UNLOGIN          = 4, -- 登录界面的联系客服功能
    REMOTE_PUSH             = 5, -- 远程推送
    LEVEL_LOGIN_REPORT      = 6, -- 等级上报
    QUIT_WAY_QUERY          = 7, -- 退出方式查询
    CREATE_ROLE_REPORT      = 8, -- 创角上报
    GET_PACKAGE_MD5         = 9, -- 获取包体MD5
    GET_SIGN_INFO           = 10,-- 获取签名信息
    PATCH_UPDATE            = 11,-- 增量更新
    IOS_LOGINREPORT         = 12,-- iOS登录上报
    IOS_LEVELUPREPORT       = 13,-- iOS升级上报
    CLIP_IMAGE              = 16,-- 启用图片裁剪
    ENABLE_APP_CHECK        = 17,-- 启用应用检测支持
    REMOTE_PUSH_V2950       = 18,-- 个推2.9.5.0版本，解决OPPO推送问题
    CLIP_SCALE_IMAGE        = 19,-- 启动图片缩放剪裁
    CHECK_DLG_JSON_EXIST    = 20,-- 检查json文件是否存在
    ENABLE_PRELOAD_SOUND    = 21,-- 启用音效预加载
    QIYU_INSIDE             = 22,-- 启用七鱼客服系统
    SHOW_HELP_PAGE          = 23,-- 新版联系客服界面
    ENABLE_ORIENTATION      = 24,-- 朝向修正启用
    IOS_VIDEO_FIXED         = 25,-- iOS视频播放BUG修复,修复控制条及contentScale
    IMAGE_PICK_FIXED        = 26,-- 图片拾取问题修复
    ANDROID_GET_PACKAGES    = 27,-- Android下开发获取已安装应用接口
    NEW_JOINTJOINT_TYPE     = 28,-- 新版合击
    CHECK_PERMISSION        = 29,-- 检查权限
    YYB_SDK_BBS             = 30,-- 启用应用宝论坛
    LOCATION_SERVICE        = 31,-- 定位功能
    VIDEOPLAY_V20171228     = 32,-- 视频播放新版本
    SAVE_TO_GALLERY         = 33,-- 保存到相册
    ARD_SOUND_V20180315     = 34,-- ARD_SOUND_V20180315
    ANDROID_RECORD_SCR      = 35,-- Android录屏功能
    YAYA_PLAY_CALLBACK      = 36,-- 支持播放回调
    NOTACH_CHECK_V1         = 37,-- 刘海屏检测支持
    ANDROID_META_DATA       = 38,-- 支持从AndroidManifest.xml读取Meta-data
    NOTACH_CHECK_AP         = 39,-- Android P刘海屏检测支持
    DONT_SEND_ACTIVATE      = 40,-- 不发送激活日志
    DONT_SEND_ACTIVATE_A    = 41,-- 不发送激活日志(所有版本)
    OPPO_SDK_BBS            = 42,--启用OPPO论坛
    PAY_FAIL_CB             = 43,--充值失败回调
    NEW_YAYA_INIT           = 44,-- 新的YayaImMgr::init
}


-- 物品类别
ITEM_CLASS =
{
    WUXING_FU = 1,          -- 五行符咒
    SUMMER_2017_MCD = 2,    -- 2017暑假活动，蒙尘的
    SUMMER_2017_YCD = 3,    -- 2017暑假活动，耀眼的
    FASHION         = 4,    -- 时装，婚服不在此列
    WEDDING_CLOTHES = 5,    -- 婚服
    HOME_LUBAN_MATERIAL = 6,    -- 居所鲁班材料
    HOME_COOK_MATERIAL = 7,     -- 居所烹饪材料
    HOME_PLANT_SEED    = 8,     -- 居所种植的种子或幼苗
    FISH               = 9,     -- 鱼
    BAIHE_HUA          = 10,    -- 2018的百合花
    CAIYAO             = 11,    -- 菜肴
    JOY                = 12,    -- 玩具
}

-- 信号颜色
SIGNAL_COLOR = {
    WHITE   = cc.c3b(255, 255, 255),
    GREEN   = cc.c3b(48, 229, 11),
    YELLOW  = cc.c3b(242, 223,12),
    RED     = cc.c3b(242, 40, 0),
}
-- 精怪类型
MOUNT_TYPE =
{
   MOUNT_TYPE_JINGGUAI  = 1,           -- 坐骑-精怪
   MOUNT_TYPE_YULING    = 2,           -- 坐骑-御灵
}

-- 结构的组编号
GROUP_NO =
{
     FIELDS_BASIC      = 1, -- 物品基础属性值
     FIELDS_VALUE      = 2, -- 物品加成属性值
     FIELDS_SCALE      = 3, -- 物品加成百分比

     STONE_START       = 12, -- 妖石组编号开始
     STONE_END         = 22, -- 妖石组编号结束

     FIELDS_MOUNT_ATTRIB = 23, -- 宠物坐骑属性
}

-- 刷道托管状态
TRUSTEESHIP_STATE = {
    OFF = 0,
    PAUSE = 1,
    OPEN = 2,
}

TRADING_STATE = {
    SHOW =      10,     -- 公示
    AUCTION_SHOW = 11,  -- 拍卖公示
    SALE =      20,     -- 寄售
    AUCTION =   21,     -- 拍卖期
    PAUSE =     30,     -- 暂停寄售，游戏内不管
    PAYMENT =   40,     -- 付款，游戏内不管
    AUCTION_PAYMENT = 41,
    CLOSED =    50,     -- 交易成功
    CANCEL =     60,     -- 取消寄售     此状态下可以重新寄售
    TIMEOUT =   70,     -- 过期         此状态下可以重新寄售
    FETCHED =   80,     -- 商品取回
    FROZEN =    90,     -- 客服冻结
    GOT =       100,    -- 购买商品后买家得到了
    FORCE_CLOSED = 110, -- 强制下架
    ERROR =     120,    -- 错误状态
}

-- 类型，2016-10-29目前只有第一个类型
TRAD_SNAPSHOT = {
    SNAPSHOT    =   "snapshot",
    SNAPSHOT_EQUIP    =   "snapshot_equip",
    SNAPSHOT_BAG               =   "snapshot_bag",
    SNAPSHOT_CARD_STORE    =   "snapshot_card_store",
    SNAPSHOT_STORE    =   "snapshot_store",
    SNAPSHOT_PET_BAG    =   "snapshot_pet_bag",
    SNAPSHOT_PET_STORE    =   "snapshot_pet_store",
    SNAPSHOT_GUARD    =   "snapshot_guard",
    SNAPSHOT_HOME_STORE = "snapshot_home_store",
    SNAPSHOT_FURNITURE_STORE = "snapshot_furniture_store",
    SNAPSHOT_FASION                 = "snapshot_fasion",
    SNAPSHOT_CUSTOM                 = "snapshot_custom",
    SNAPSHOT_EFFECT                 = "snapshot_effect",
    SNAPSHOT_FOLLOW_PET             = "snapshot_follow_pet",
    TRAD_SNAPSHOT_HOUSE_PET_STORE   = "snapshot_house_pet_store",
    SNAPSHOT_CHILD           = "snapshot_child",
}

-- 聚宝斋出售类型
JUBAO_SELL_TYPE = {
    SALE_TYPE_ROLE          = 1,                -- 角色
    SALE_TYPE_CASH          = 2,                -- 金钱
    SALE_TYPE_PET           = 3,                -- 宠物
    SALE_TYPE_WEAPON        = 4,                -- 武器
    SALE_TYPE_PROTECTOR     = 5,                -- 防具
    SALE_TYPE_JEWELRY       = 6,                -- 首饰
    SALE_TYPE_ARTIFACT      = 7,                -- 法宝
}

TASK_LOG_ID = {
    [CHS[2200004]]      = 1,
    [CHS[2200005]]      = 2,
    [CHS[2200006]]      = 3,  -- 修行任务
    [CHS[2200007]]      = 4,  -- 帮派任务
    [CHS[2200008]]      = 5,  -- 帮派日常
    [CHS[2200009]]      = 6,  -- 副本
    [CHS[2200010]]      = 7,  -- 通天塔
    [CHS[2200011]]      = 8,  -- 助人为乐
    [CHS[2200012]]      = 9,  -- 竞技场
    [CHS[2200013]]      = 10, -- 地图守护神
    [CHS[2200014]]      = 11, -- 八仙梦境
}

MARKET_STATUS = {
    STALL_GS_NONE               = 0,
    STALL_GS_SHOWING            = 1,                   -- 公示中
    STALL_GS_SELLING            = 2,                   -- 出售中
    STALL_GS_OUT_SELLING        = 3,               -- 已下架
    STALL_GS_FROZEN             = 4,                    -- 冻结中
    STALL_GS_AUDIT              = 5,   -- 审核中
    STALL_GS_AUDITED            = 6,   -- 已审核
    STALL_GS_NO_PASS            = 7,   -- 审核不通过

    STALL_GS_AUCTION_SHOW       = 11,   -- 拍卖公示期
    STALL_GS_AUCTION            = 12,   -- 拍卖出售期
    STALL_GS_AUCTION_PAYMENT    = 13,   -- 拍卖付款期
}

TRANSFER_ITEM_TYPE = {
    OTHER       = 0,     -- 无
    CASH        = 1,     -- 金钱
    PET         = 2,     -- 宠物
    CHARGE      = 3,     -- 收费道具
    NOT_COMBINE = 4,     -- 不可叠加道具
    COMBINE     = 5,     -- 可叠加道具
}

EQUIPMENT_COLOR_ORDER =
{
    [CHS[7002101]] = 1,  -- 绿
    [CHS[7002102]] = 2,  -- 黄
    [CHS[7002103]] = 3,  -- 粉
    [CHS[7002104]] = 4,  -- 蓝
}

-- 登入时，玩家角色状态
CHAR_ONLINE_STATE = {
    CHAR_LIST_T_NONE            = 0, -- 不在线
    CHAR_LIST_T_ONLINE          = 1, -- 在线
    CHAR_LIST_T_TRUSTEESHIP     = 2, -- 托管
    CHAR_LIST_T_CROSSSERVER     = 3, -- 跨服中
}

TASK_TYPE = {
    STORY_LINE = 1, -- 主线
    FESTIVAL = 2, -- 节日
    ACTIVITY = 3, -- 活动
    PLOT = 4, -- 剧情
    GUIDE = 5, -- 指引
    FUNCION = 6, -- 功能
}

ORE_WARS_CAMP = {
    lanmao = 1,
    chiyan = 2,
}

DIJIE_TASK_LEVEL =
{
        [1] = {min = 72, max = 74},       [2] = {min = 77, max = 79},
        [3] = {min = 82, max = 84},       [4] = {min = 87, max = 89},
        [5] = {min = 92, max = 94},       [6] = {min = 97, max = 99},
        [7] = {min = 102, max = 104},       [8] = {min = 107, max = 109},
        [9] = {min = 112, max = 114},       [10] = {min = 117, max = 119},
}

TIANJIE_TASK_LEVEL =
    {
        [1] = {min = 132, max = 134},       [2] = {min = 137, max = 139},
        [3] = {min = 142, max = 144},       [4] = {min = 147, max = 149},
        [5] = {min = 152, max = 154},       [6] = {min = 157, max = 159},
        [7] = {min = 162, max = 164},       [8] = {min = 167, max = 169},
        [9] = {min = 172, max = 174},       [10] = {min = 177, max = 179},
    }

COMBAT_MODE = {
    COMBAT_MODE_PK                      = 1,   -- PK战斗
    COMBAT_MODE_COMPETE                 = 2,   -- 切磋战斗
    COMBAT_MODE_NORMAL                  = 3,   -- 一般模式
    COMBAT_MODE_DARE                    = 4,   -- 挑战模式
    COMBAT_MODE_WARCRAFT                = 5,   -- 比武战斗
    COMABT_MODE_ARENA                   = 6,   -- 竞技场战斗
    COMBAT_MODE_SHUADAO                 = 7,   -- 刷道战斗
    COMBAT_MODE_DUNGEON                 = 8,   -- 副本战斗
    COMBAT_MODE_XIULIAN                 = 9,   -- 修炼战斗
    COMBAT_MODE_TONGTIANTA              = 10,  -- 通天塔战斗
    COMBAT_MODE_PARTY                   = 11,  -- 帮派战斗
    COMBAT_MODE_PW_PVE                  = 12,  -- 帮派PVE
    COMBAT_MODE_DIJIE                   = 13,  -- 地劫战斗
    COMBAT_MODE_GHOST_01                = 14,  -- 2017年中元节战斗一
    COMBAT_MODE_GHOST_02                = 15,   -- 2017年中元节战斗二
    COMBAT_MODE_QISHA                   = 16,   --七杀战斗
    COMBAT_MODE_LCHJ                    = 17,  -- 灵宠幻境战斗
    COMBAT_MODE_LIFEDEATH               = 18,  -- 生死状战斗
    COMBAT_MODE_TONGTIANTADING          = 19,   -- 通天塔顶战斗
}

SUBMIT_PET_TYPE = {
    SUBMIT_PET_TYPE_NORMAL = 1,
    SUBMIT_PET_TYPE_FEISHENG = 2,
    SUBMIT_PET_TYPE_FEED = 3,  -- 饲养宠物的提交
    SUBMIT_PET_TYPE_INNER_ALLCHEMY = 4, -- 内丹修炼宠物提交
    SUBMIT_PET_TYPE_BUYBACK = 100,  -- 销毁宠物的提交(目前只有客户端配置了该常量)
}

CHILD_TYPE = {
    NO_CHILD = 0,               -- 无
    YUANYING = 1,               -- 元婴
    XUEYING  = 2,               -- 血婴
    UPGRADE_IMMORTAL    = 3,    -- 仙
    UPGRADE_MAGIC       = 4,    -- 魔
}

-- 退出码
LOGOUT_CODE = {
    LGT_SDK_SWITCH          = 1,            -- SDK切换账号
    LGT_SDK_LOGOUT          = 2,            -- SDK登出
    LGT_SDK_QUIT            = 3,            -- SDK退出
    LGT_ESC_QUIT            = 4,            -- ESC键退出
    LGT_BACK_LOGIN          = 5,            -- 返回登录
    LGT_SELECT_CHAR_1       = 6,            -- 选择角色1
    LGT_SELECT_CHAR_2       = 7,            -- 选择角色2
    LGT_REFUSE_AGREEMENT    = 8,            -- 拒绝免责声明
}

PROGRESS_BAR = {
    RED = "ui/ProgressBar0047.png",
    BLUE = "ui/ProgressBar0045.png",
    GREEN = "ui/ProgressBar0049.png",
}

HOME_STORE_TYPE = {
    SMALL = 1, -- 初级储物空间  二排储物格
    MIDDLE = 2, -- 中级储物空间  一页储物格
    BIG = 3, -- 高级储物空间  两页储物格
}

HOME_TYPE = {
    xiaoshe = 1,  -- 小舍
    yazhu = 2,    -- 雅筑
    haozhai = 3,  -- 豪宅
}

-- 居所种植的农作物状态
HOME_CROP_STAUES = {
    STATUS_HEALTH      = 0, -- 健康
    STATUS_HAS_REDERAL = 1, -- 杂草丛生
    STATUS_HAS_INSECT  = 2, -- 害虫生长
    STATUS_THIRST      = 3, -- 土壤缺水
    STATUS_FINISH      = 4, -- 成熟
}

BEDROOM_TYPE = {
    SMALL = 1,
    MIDDLE = 2,
    BIG = 3,
}

STORE_TYPE = {
    HOME_STORE = "home_store",
    NORMAL_STORE = "normal_store",
}

GFD_STATUS1_BTN = {
    [1] = "PartyButton",
    [2] = "ForgeButton",
    [3] = "HomeButton",
    [4] = "GuardButton",
    [5] = "SocialButton",
    ["PartyButton"] = 1,
    ["ForgeButton"] = 2,
    ["HomeButton"] = 3,
    ["GuardButton"] = 4,
    ["SocialButton"] = 5,
}
GFD_STATUS2_BTN = {

    [1] = "AchievementButton",
    [2] = "WatchCenterButton",
    [3] = "SystemButton",

    ["AchievementButton"] = 1,
    ["WatchCenterButton"] = 2,
    ["SystemButton"] = 3,
}

SFD_STATUS_BTN = {
    [1] = "ShengSiButton",
    [2] = "RankingListButton",
    [3] = "MallButton",
    [4] = "TradeButton",
    [5] = "GiftsButton",
    ["ShengSiButton"] = 1,
    ["RankingListButton"] = 2,
    ["MallButton"] = 3,
    ["TradeButton"] = 4,
    ["GiftsButton"] = 5,
}

HOUSE_QUERY_TYPE =
{
    QUERY_BY_CHAR_NAME          = 1,
    QUERY_BY_CHAR_GID           = 2,
}
-- 时装类型
FASION_TYPE = {
    WEDDING     = 1,    -- 婚服
    FASION      = 2,    -- 时装
}


-- 加载类型，类型名称-优先级，数字越小优先级越高
LOAD_TYPE = {
    MAP     = 1,        -- 地图
    NPC     = 2,        -- NPC
    CHAR    = 3,        -- 角色
    MAGIC   = 4,        -- 光效
    MAX     = 4,
}

-- 自动流程的状态
AUTO_OPER_STATE = {
    NORMAL  = "normal",        -- 正常
    SHUAD   = "shuad",         -- 刷道
}

-- 配置动作复用表 raw_action --> real_action
-- 如果模型不存在 raw_action，则使用 real_action
ACTION_REUSE_MAP = {
    [Const.SA_WALK] = Const.SA_STAND,
    [Const.SA_CAST] = Const.SA_ATTACK,
}

-- 提升类型，提升界面增加或移除标记使用
PROMOTE_TYPE = {
    TAG_ATTRIB = 1,
    TAG_POLAR = 2,
    TAG_SKILL = 3,
    TAG_GET_GUARD = 4,       --　可获得守护
    TAG_GUARD_EXP = 5 ,     --　守护历练
    TAG_EQUIP  = 6,
    TAG_PET_ADD_POINT = 7,
    TAG_PET_RESIST_POINT = 8,
    TAG_PET_FENGLING = 9,
    TAG_PET_FLY = 10,
    TAG_XIANMO_POINT = 11,
    TAG_INNER_ALCHEMY = 12,    -- 内丹突破
    TAG_KID_FLY = 13,        -- 娃娃飞升
}

-- 空间操作类型
BLOG_OP_TYPE = {
    BLOG_OP_UPLOAD_ICON                 = 1,        -- 上传头像
    BLOG_OP_DELETE_ICON                 = 2,        -- 删除头像
    BLOG_OP_SIGNATURE                   = 3,        -- 修改签名
    BLOG_OP_REPORT_ICON                 = 4,        -- 举报头像
    BLOG_OP_REPORT_ISIGNATURE           = 5,        -- 举报签名
    BLOG_OP_UPLOAD_CIRCLE               = 6,        -- 上传朋友圈图片
    WB_OP_COVER                         = 7,        -- 纪念册封面
    WE_OP_PHOTO                         = 8,        -- 纪念册相片
    MATCH_MAKING_ICON                   = 9,        -- 寻缘头像
    MATCH_MAKING_VOICE                  = 10,       -- 寻缘语音
    GOOD_VOICE                          = 13,       -- 好声音
    GOOD_VOICE_ICON                     = 14,       -- 好声音头像
}

-- 错误异常
ERR_OCCUR = {
    ACHIEVEMENT_NO_CONFIG   = 0,            -- 发送达成成就时，未收到配置信息   收集数据
    ERROR_TYPE_MAIL         = 1,            -- 邮件信息异常
    ERROR_TYPE_CHECK_SERVER = 2,            -- 校验服务器异常
}

-- 组队匹配类型
MATCH_STATE = {
    NORMAL = 0,
    MEMBER = 1,
    LEADER = 2,
}

-- 游戏效果
GAME_EFFECT = {
    LOW = 2,
    MIDDLE = 1,
    HIGH = 0,
}

-- 内丹境界
INNER_ALCHEMY_STATE = {
    ONE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
}

-- 内丹阶段
INNER_ALCHEMY_STAGE = {
    ONE = 1,
    TWO = 2,
    THREE = 3,
    FOUR = 4,
    FIVE = 5,
}

-- 内丹突破阶段
INNER_ALCHEMY_BREAK_STATUS = {
    NOT_IN_BREAK = 1,
    IN_BREAK = 2,
    OVER_BREAK = 3,
}

-- 对应 MSG_TRADING_GOODS_INFO 中 sell_buy_type
TRADE_SBT = {
    NONE = 0,                   -- 普通出售和购买
    APPOINT_SELL = 1,           -- 指定交易上架
    APPOINT_CONTINUE = 2,       -- 指定交易重新上架
    APPOINT_BUY = 3,            -- 指定交易以指定价格购买
    APPOINT_BUYOUT = 4,         -- 指定交易以一口价购买
    AUCTION = 5,      -- 拍卖
    AUCTION_BUY = 6,            -- 拍卖购买
}

OPEN_URL_TYPE = {
    DEFAULT = 1,     -- 游戏外打开(DeviceMgr:openUrl)
    WEB_DLG = 2,     -- 游戏内打开(WebDlh)
    WSQ_BBS = 3,     -- -- 若已经登录，需要自动登录，否则游客模式
}

AREA_CODE =
{
        [11] = CHS[3003554],
        [12] = CHS[3003555],
        [13] = CHS[3003556],
        [14] = CHS[3003557],
        [15] = CHS[3003558],
        [21] = CHS[3003559],
        [22] = CHS[3003560],
        [23] = CHS[3003561],
        [31] = CHS[3003562],
        [32] = CHS[3003563],
        [33] = CHS[3003564],
        [34] = CHS[3003565],
        [35] = CHS[3003566],
        [36] = CHS[3003567],
        [37] = CHS[3003568],
        [41] = CHS[3003569],
        [42] = CHS[3003570],
        [43] = CHS[3003571],
        [44] = CHS[3003572],
        [45] = CHS[3003573],
        [46] = CHS[3003574],
        [50] = CHS[3003575],
        [51] = CHS[3003576],
        [52] = CHS[3003577],
        [53] = CHS[3003578],
        [54] = CHS[3003579],
        [61] = CHS[3003580],
        [62] = CHS[3003581],
        [63] = CHS[3003582],
        [64] = CHS[3003583],
        [65] = CHS[3003584],
}

MONTH_DAY =
{
    [1] = 31,
    [3] = 31,
    [4] = 30,
    [5] = 31,
    [6] = 30,
    [7] = 31,
    [8] = 31,
    [9] = 30,
    [10] = 31,
    [11] = 30,
    [12] = 31,
}

-- 名人争霸赛程大类
MINGRZB_JC_BIG_TYPE = {
    FINAL = 100,
    JC4   = 200,
    JC8   = 300,
    JC16  = 400,
    JC32  = 500,
    JC64  = 600,
    JC128 = 700,
}

-- 名人争霸投票状态
MINGRZB_JC_SUPPORTS_STATUS = {
    OVER = 1,    -- 非当日比赛，无法投票
    CAN_GO = 2, -- 当日比赛，可投票
    CAN_NOT_GO = 3, -- 当日比赛，但已过投票时间
    FUTURE = 4,  -- 今天之后的比赛，可投票
}

-- 角色菜单类型
CHAR_MUNE_TYPE = {
    SCENE = 1,
    CITY = 2, -- 同城社交
    KUAFU_BLOG = 3, -- 跨服朋友圈
    GROUP_MEMBER = 4, -- 群成员从群组中打开
    GROUP_OWNER = 5,  -- 群主从群组中打开
}


MINGREN_ZHENGBA_CLASS = {
        YUXUAN      = 1,    -- 预选赛
    TAOTAI      = 2,    -- 淘汰赛
    BAN_JUESAI      = 3,    -- 半决赛
    JUESAI      = 4,    -- 决赛
}

GPS_CONFIG = {
    DEFAULT_PLAT_U = "http://webproxy.leiting.com/geocoder.do",
    DEFAULT_PLAT_K = "leiting!@#123",
}

-- 神算子占卜类型
NUMEROLOGY_TYPE = {
    RUYI = 1,    -- 如意签
    XINGYU = 2,  -- 幸运签
    WANFU = 3,   -- 万福签
}

-- 神算子占卜效果类型
NUMEROLOGY = {
    STICK_XYQ_CY_ZBCF = 2006, -- 财运·装备拆分
    STICK_XYQ_CY_ZBLH = 2007, -- 财运·装备炼化
    STICK_XYQ_CY_ZBGZ = 2008, -- 财运·装备改造
    STICK_XYQ_CY_ZBJH = 2009, -- 财运·装备进化
    STICK_XYQ_CY_HCSS = 2011, -- 财运·合成首饰
    STICK_XYQ_CY_SSCZ = 2013, -- 财运·首饰重铸

    STICK_WFQ_CY_GZZX = 3001, -- 财运·观战中心
    STICK_WFQ_CY_JSBT = 3002, -- 财运·集市摆摊
    STICK_WFQ_CY_ZBBT = 3003, -- 财运·珍宝摆摊
}

-- 地图类型
MAP_TYPE = {
    NORMAL = 1, -- 普通地图
    DRAG_MAP = 2, -- 拖动的地图，隐藏Me对象
    MIGONG_MAP = 3, -- 迷宫
}

-- 按钮菜单状态
MENU_BUTTON_STATE = {
    NORMAL = 1,         -- 正常状态（缩起）
    EXPAND = 2,         -- 展开
    NO_CHILD = 3,       -- 无子菜单
}

-- 高级血池、高级灵池和血池灵池共用
FAST_USE_ITEM = {
    --  血池          灵池          驯兽          搜邪罗盘        证道魂
    CHS[4000355], CHS[4000356] ,CHS[4000357] , CHS[7100055], CHS[4300458]
}

-- NPC 聊天的类型
NPC_TELL = {
    NONE    = 0,    -- 默认类型
    INN     = 1,    -- 客栈
    COMMON  = 2,    -- 通用消息
}

-- 每帧需要执行的函数标记
FRAME_FUNC_TAG = {
    CHECK_CONNECT = "check_connect", -- Connection 检查连接
    ENTER_ROOM_EFFECT_CHECK = "enter_room_effect_check", -- 过图特效检查函数
    DRAPMAP_MOVE_TO_UPDATA = "move_to_update",  -- 拖动地图水平移动更新
    PUTTING_ITEM_LOAD      = "putting_item_load", -- 放置道具
    WENQUAN_UPDATE         = "wenquan_update",
    COUPLE_LOVE_SLEEP      = "couple_love_sleep",
}

ZHENBAO_TRADE_TYPE = {
    STALL_SBT_NONE              =   0,   -- 普通出售和购买
    STALL_SBT_APPOINT_SELL      =   1,   -- 指定交易上架
    STALL_SBT_APPOINT_CONTINUE  =   2,   -- 指定交易重新上架
    STALL_SBT_APPOINT_BUY       =   3,   -- 指定交易以指定价格购买
    STALL_SBT_APPOINT_BUYOUT    =   4,   -- 指定交易以一口价购买
    STALL_SBT_AUCTION           =   5,   -- 拍卖上架、重新上架
    STALL_SBT_AUCTION_BUY       =   6,   -- 拍卖购买
}

CONNECT_TYPE = {
    NORMAL = 1,  -- 游戏正常连接
    LINE_UP = 2, -- 排队时充值、购买会员使用的连接
}

ACCOUNT_TYPE = {
    NORMAL  = "normal",  -- 正常登陆
    CHARGE  = "charge",  -- 充值登陆
    INSIDER = "insider", -- 购买会员登陆
    GETCOIN = "getcoin", -- 获取金钱
}

-- 活动奖励类型
ACTIVITY_REWARD_TYPE = {
    EXP              = 1,  -- 经验
    TAO_AND_MARTIAL  = 2,  -- 道行/武学
    ITEM             = 3,  -- 道具
    EQUIP            = 4,  -- 装备
}

-- 集市名片打开类型
MARKET_CARD_TYPE = {
    ME_ACTION = 0,   -- 查看自己的商品
    VIEW_OTHERS = 1, -- 查看其他人的商品
    FLOAT_DLG = 2,   -- 打开名片
}

NPC_DLG_ATTRIB = {
    NOT_CLOSE_WHEN_NOT_NPC = 1,    -- npc 对象消失不关闭界面
    NOT_CLOSE_WHEN_CLICK_OUT = 2,  -- 点击对话框外围不关闭界面
}

-- 跨服试道类型
KFSD_TYPE = {
    NORMAL = 1, -- 常规
    MONTH = 2,  -- 月道行
}

SHARE_TYPE_CONFIG =
{
    SHARE_PIC = 1, -- 分享图片
    SHARE_URL = 2, -- 分享url
}

CONFIRM_MODE = {
    NORMAL    = 0,  -- 战斗外显示，进入战斗中关闭
    ALWAYS_SHOW_IN_COMBAT = 1, -- 战斗中可一直显示，战斗结束时关闭，出战斗关闭
    IN_COMBAT = 2,      -- 战斗中显示，当前回合结束时关闭，出战斗关闭
    ALWAYS_SHOW = 3,    -- 进出战斗不关闭
}


CHANNEL_SOURCE = {
    CHANNEL_SOURCE_CLIENT                   = 0,        -- 来自客户端
    CHANNEL_SOURCE_APPLE_WATCH              = 1,        -- 来自 APPLE WATCH
}

-- 娃娃的一些标记
FLAG_CHILD = {
    TOY_EFF = 1,        -- 一辈子只有一次，第一次使用玩具光效标记
}

-- 预加载微社区类型
PRELOAD_COMMUNITY_TYPE = {
    NONE = 1,        -- 空
    RED_POINT = 2,   -- 红点推送
    GUIDE = 3,       -- 新手指引
}
