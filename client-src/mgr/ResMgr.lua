-- ResMgr.lua
-- Created by chenyq Nov/10/2014
-- 资源管理器，负责管理资源路径、代码中使用的图片 icon，光效 icon

local CartoonNewInfo = require "magic_n/Cartoon" or {}
local LoadingPicInfo = require "loading_pic/PictureName" or {}

ResMgr = Singleton()

-- 是否开启调试
local isDebug = false

-- ui 信息(请按字母顺序排列，以方便查看 key 是否重复)
ResMgr.ui = {
    button_file         = 'Button0002.png',
    button_pressed      = 'Button0003.png',
    task_pressed        = 'Frame0002.png',
    big_cash            = 'Icon0072.png',
    big_silver          = 'Icon0074.png',
    big_gold            = 'Icon0073.png',
    close_button        = 'Button0001.png',
    checkbox_file1      = 'CheckBox0009.png',
    checkbox_file2      = 'CheckBox0008.png',
    fight_wait          = 'SkillText0035.png',
    fight_progress_back = 'ui/Icon0268.png',
    fight_progress_life = 'ui/ProgressBar0060.png',
    fight_progress_mana = 'ui/ProgressBar0061.png',
    fight_progress_back_anger = 'ui/ProgressBar0071.png',
    fight_progress_anger = 'ui/ProgressBar0069.png',
    fight_progress_top_anger = 'ui/ProgressBar0070.png',
    fight_bg_img        = 'ui/fight_bg.png',
    fight_bg_img_center = 'ui/fight_bg_center.png',
    fight_sel_img       = 'ui/Icon0271.png',
    fight_sel_down_img  = 'ui/Icon0272.png',
    guard_equip_lev_star_1 = 'ui/Icon0002.png',
    guard_equip_lev_star_2 = 'ui/Icon0003.png',
    guard_equip_lev_star_3 = 'ui/star_3.png',
    grid_back           = 'Frame0005.png',
    grid_select         = 'Frame0014.png',
    gold                = 'Icon0088.png',
    img_text_bg         = 'Background0005.png',
    img_text_select     = 'Frame0056.png',
    pet_skill_list_none = 'items/01205_50.png',
    pet_phy_skill_icon  = 'skillicon/09001.png',             -- 力宠物理攻击技能图标
    party_war_win       = "Icon0218.png",
    party_war_lose      = "Icon0398.png",
    party_war_draw      = "Icon0399.png",

    silver              = 'Icon0081.png',
    channel_world       = 'channel/ChannelIcon0001.png',
    channel_party       = 'channel/ChannelIcon0002.png',
    channel_team        = 'channel/ChannelIcon0003.png',
    channel_adnotice    = 'channel/ChannelIcon0006.png',
    channel_rumour      = 'channel/ChannelIcon0005.png',
    channel_system      = 'channel/ChannelIcon0007.png',
    channel_misc        = 'channel/ChannelIcon0004.png',    -- 杂项没有先用系统
    channel_current     = 'channel/ChannelIcon0008.png',
    channel_horn        = 'channel/ChannelIcon0009.png',    -- 喇叭频道文字
    horn_image          = 'ui/Icon1512.png',                -- 喇叭图片
    npc_menu_normal     = 'Frame0015.png',                  -- npc菜单没选中的图片
    npc_menu_select     = 'Frame0016.png',                  -- npc菜单中的内容
    chat_back_groud     = 'Icon0111.png',                   -- 表情气泡
    chat_back_groud_down = 'Icon0117.png',                  -- 表情气泡向下尖角

    chat_red_bag_back_groud = "Icon0548.png",            -- 聊天红包气泡
    chat_def_back_groud     = "Icon0530.png",             -- 聊天默认气泡

    red_bag_image       = 'ui/Icon0547.png',                -- 红包
    small_red_bag_image = 'ui/Icon0551.png',                -- 小红包图片

    chat_horn_back_groud  = 'ui/Background0125.png',        -- 喇叭喊话气泡背景


    chat_horn_back_arrow  = 'ui/Icon1511.png',              -- 喇叭喊话尖角
    chat_horn_back_groud  = 'ui/Background0125.png',        -- 喇叭喊话气泡背景

    chat_time_back_groud = 'Frame0070.png',                 -- 聊天时间底图
    red_dot             = "ui/Icon1520.png",                -- 小红点资源路径
    undefine_equip      = "ui/Icon0205.png",              -- 未鉴定装备
    gift                = "ui/Icon0290.png",                -- 绑定标识
    time_limit          = "ui/Icon0590.png",                -- 限时标识
    fuse                = "ui/Icon1780.png",                -- 绑定标识
    money               = "ui/Icon0072.png",                -- 金钱图标
    yinyuanbao          = "ui/Icon0074.png",                -- 银元宝图标
    npc_button          = "ui/Frame0157.png",                  -- NPC对话框按钮
    bag_no_item_bg_img  = "Frame0093.png",                  -- 道具背包格子背景
    bag_no_item_shadow_img = "Frame0095.png",               -- 道具背包格子没物品的阴影
    bag_can_not_use_item_img = "Frame0133.png",             -- 道具背包格子无法使用背景
    bag_item_bg_img     = "Frame0094.png",                  -- 道具背包格子背景
    bag_item_select_img = "Frame0024.png",                  -- 道具选择后前置图片
    equip_yupei_img     = "ui/image0028.png",                -- 装备玉佩底图
    equip_xianglian_img = "ui/image0032.png",                -- 装备项链底图
    equip_shouzhuo_img  = "ui/image0029.png",                -- 装备手镯底图
    equip_weapon_img    = "ui/image0027.png",                -- 装备武器底图
    equip_helmet_img    = "ui/image0026.png",                -- 装备头盔底图
    equip_boot_img      = "ui/image0033.png",                -- 装备鞋子底图
    equip_armor_img     = "ui/image0034.png",                -- 装备衣服底图
    equip_hair_img      = "ui/Icon1944.png",                 -- 装备自定义头发底图
    equip_upper_img     = "ui/Icon1951.png",                 -- 装备自定义衣服底图
    equip_lower_img     = "ui/Icon1946.png",                 -- 装备自定义裤子底图
    equip_arms_img      = "ui/Icon1949.png",                 -- 装备自定义武器底图
    equip_back_img      = "ui/Icon2520.png",                 -- 装备自定义背饰底图
    equip_pet_img       = "ui/Icon2121.png",                 -- 装备跟宠底图
    equip_fashion_img   = "ui/Icon1933.png",                 -- 装备时装底图

    equip_talisman_img = "ui/image0031.png",                -- 符具 地图
    equip_artifact_img = "ui/image0030.png",                -- 法宝地图

    npc_button_down     = "ui/Button0152.png",                  -- NPC对话框按钮
    char_shadow_img     = "other/shadow.png",               -- 人物阴影
    progress_red_bar    = "ui/ProgressBar0052.png",         -- 红色Slider进度条
    progress_red_button = "Button0144.png",              -- 红色Slider进度条按钮
    progress_yellow_button = "Button0144.png",           -- 黄色进度条按钮
    progress_green_bar  = "ui//ProgressBar0051.png",        -- 绿色进度条
    experience          = "BigRewardIcon0005.png",           -- 经验
    daohang             = "BigRewardIcon0003.png",                -- 道行
    shuadao_jifen       = "BigRewardIcon0031.png",
    title               = "BigRewardIcon0016.png",                -- todo （称谓没有资源用其他代替）
    others_icon         = "BigRewardIcon0003.png",       -- 其他
    pot_icon            = "BigRewardIcon0010.png",       -- 潜能
    item_common         = "BigRewardIcon0022.png",       -- 道具通用图
    pet_common          = "BigRewardIcon0017.png",       -- 宠物通用图
    ride_pet_common     = "BigRewardIcon0036.png",       -- 骑宠通用图
    big_banggong        = "BigRewardIcon0001.png",       -- 帮贡
    big_identify_equip  = "BigRewardIcon0013.png",       --  未鉴定
    big_yinyuanbao      = "Icon0074.png",                --  大银元宝
    big_equip           = "BigRewardIcon0014.png",       -- 装备
    big_jewelry         = "BigRewardIcon0012.png",       -- 大首饰图标
    big_party_contribution = "BigRewardIcon0015.png",    -- 帮派建设度
    voucher             = "Icon329.png",                 -- 代金券
    big_party_active    = "BigRewardIcon0019.png",       -- 帮派活力值
    big_reputation      = "BigRewardIcon0011.png",       -- 声望
    big_vip_icon        = "BigRewardIcon0023.png",       -- vip
    big_friendly_icon   = "BigRewardIcon0026.png",       -- 友好度
    jdong_card          = "BigRewardIcon0025.png",       -- 京东卡
    get_reward_icon     = "BigRewardIcon0027.png",       -- 抽奖次数
    big_change_card     = "BigRewardIcon0028.png",       --  变身卡
    big_off_line_time   = "BigRewardIcon0029.png",       -- 离线时间
    big_skill_icon      = "BigRewardIcon0030.png",       -- 技能
	big_weapon          = "BigRewardIcon0037.png",       -- 武器
    big_artifact        = "BigRewardIcon0038.png",       -- 法宝大图标
    big_ziqihongmeng    = "BigRewardIcon0039.png",       -- 紫气鸿蒙大图标
    big_daofa           = "BigRewardIcon0040.png",       -- 道法大图标
    big_gold_rose       = "BigRewardIcon0041.png",       -- 纯金玫瑰大图标
    big_qq_vip          = "BigRewardIcon0042.png",       -- QQ会员
    big_polar_upper     = "BigRewardIcon0045.png",       -- 相性上限
    big_level_upper     = "BigRewardIcon0046.png",       -- 等级上限
    big_object_reward   = "BigRewardIcon0022.png",        -- 实物奖励大图标
    big_call_cost_reward = "BigRewardIcon0022.png",       -- 话费奖励大图标
    big_attrib_point    = "BigRewardIcon0051.png",       -- 属性点奖励大图标
    big_polar_point     = "BigRewardIcon0050.png",       -- 相性点奖励大图标
    big_tao_wu          = "BigRewardIcon0052.png",       -- 道行和武学
    big_wuxue           = "BigRewardIcon0053.png",       -- 武学
    big_inn_coin        = "BigRewardIcon0054.png",       -- 客栈喜来通宝大图标
    big_tan_an_score    = "BigRewardIcon0057.png",       -- 探案积分大图标
    big_jewelry_essence = "BigRewardIcon0055.png",      -- 首饰精华大图标
    big_item_lingchen   = "ui/Icon2416.png",               -- 道具灵尘大图标
    big_xianmo_point = "BigRewardIcon0056.png",   -- 大仙魔点
    big_chongfengsan    = "BigRewardIcon0058.png",  -- 宠风散点数大图标
    big_qinmidu         = "BigRewardIcon0059.png",  -- 亲密度大图标
    big_wawazizhi       = "BigRewardIcon0060.png",  -- 娃娃资质大图标

    small_cash          = "Icon0072.png",                   -- 金钱小图标
    small_banggong      = "BigRewardIcon0001.png",        -- 帮贡小图标
    small_daohang       = "BigRewardIcon0003.png",        -- 道行小图标
    small_common_item   = "BigRewardIcon0022.png",        -- 道具通用小图标
    small_party_active  = "BigRewardIcon0019.png",        -- 帮派活力值
    small_party_contribution = "BigRewardIcon0015.png",   -- 帮派建设度
    small_exp           = "BigRewardIcon0005.png",        -- 经验小图标
    samll_pot           = "BigRewardIcon0010.png",        -- 潜能
    small_reputation    = "BigRewardIcon0011.png",        -- 声望
    small_jewelry       = "BigRewardIcon0012.png",        -- 首饰
    small_identify_equip = "BigRewardIcon0013.png",       -- 未鉴定装备
    small_equip         = "BigRewardIcon0014.png",        -- 装备
    small_title         = "BigRewardIcon0016.png",        -- 称谓小图标
    samll_common_pet    = "BigRewardIcon0017.png",        -- 宠物通用小图标
    samll_vip_icon      = "BigRewardIcon0023.png",        -- 会员小图标
    small_voucher       = "Icon329.png",                   -- 代金券
    small_get_reward    = "BigRewardIcon0027.png",        -- 抽奖次数小图标
    small_change_card   = "BigRewardIcon0028.png",        -- 变身卡小图标
    small_friendly_icon = "BigRewardIcon0026.png",        -- 友好度
    small_off_line_time = "BigRewardIcon0029.png",        -- 离线时间
    small_skill_icon    = "BigRewardIcon0030.png",        -- 技能
    small_shuadao_jifen = "BigRewardIcon0031.png",
    small_artifact      = "BigRewardIcon0038.png",        -- 法宝小图标
    small_ziqihongmeng  = "BigRewardIcon0039.png",       -- 紫气鸿蒙小图标
    small_daofa         = "BigRewardIcon0040.png",       -- 道法小图标
    small_gold_rose     = "BigRewardIcon0041.png",        -- 纯金玫瑰小图标
    small_polar_upper   = "BigRewardIcon0045.png",        -- 相性上限小图标
    small_level_upper   = "BigRewardIcon0046.png",        -- 等级上限小图标
    small_object_reward   = "BigRewardIcon0022.png",        -- 实物奖励小图标
    small_call_cost_reward   = "BigRewardIcon0022.png",     -- 话费奖励小图标
    small_fashion   = "BigRewardIcon0047.png",     -- 话费奖励小图标
    small_reward_cash   = "Icon0072.png",     -- 金钱小图标
    small_reward_voucher = "Icon329.png",     -- 代金券小图标
    small_reward_glod   = "Icon0073.png",     -- 元宝小图标
    small_reward_silver  = "Icon0074.png",     -- 元宝小图标
    small_attrib_point  = "BigRewardIcon0051.png",     -- 属性点小图标
    small_polar_point   = "BigRewardIcon0050.png",     -- 相性点小图标
    small_tao_wu          = "BigRewardIcon0052.png",   -- 道行和武学
    small_wuxue           = "BigRewardIcon0053.png",   -- 道行
    small_jewelry_essence = "BigRewardIcon0055.png",   -- 首饰精华
    small_item_lingchen   = "ui/Icon2416.png",              -- 道具灵尘小图标
    xianmo_point = "BigRewardIcon0056.png",   -- 仙魔点
    small_tan_an_score    = "BigRewardIcon0057.png",   -- 探案积分
    small_chongfengsan    = "BigRewardIcon0058.png",   -- 宠风散点数小图标
    small_qinmidu         = "BigRewardIcon0059.png",  -- 亲密度大图标
    small_child_qinmidu   = "BigRewardIcon0062.png",    -- 娃娃亲密
    small_wawazizhi       = "BigRewardIcon0060.png",  -- 娃娃资质小图标

    huiguiScore         = "BigRewardIcon0043.png",       -- 回归积分
    zhaohuiScore     = "BigRewardIcon0044.png",        -- 召回积分

    touming          = "Icon0189.png",                -- 透明图片
    fightClick          = "ui/fightClick.png",                -- 选择战斗操作对象相应区域

    yellow_bubble       = "ProgressBar0016.png",            -- 黄色泡泡特效
    green_bubble        = "ProgressBar0010.png",            -- 绿色泡泡特效
    yellow_bar          = "ProgressBar0014.png",            -- 黄色进度条
    green_bar           = "ProgressBar0006.png",            -- 绿色进度条
    red_bubble          = "ProgressBar0009.png",            -- 红色泡泡特效
    red_bar             = "ui/ProgressBar0026.png",         -- 红色进度条
    luezhen_flag        = "ui/Icon0131.png",                -- 掠阵标识符
    canzhan_flag        = "ui/Icon0094.png",                -- 参战标识符
    ride_flag           = "ui/Icon0592.png",                -- 骑乘标识符
    vioce_time_back     = "Frame0062.png",                  -- 语音条
    vioce_sign          = "ui/Icon0156.png",                -- 语音标志
    voice_other_sign    = "ui/Icon0394.png",                -- 语音的另一个标志（金黄色，用于左下角聊天）
    cancelVoice_img     = "ui/Icon0155.png",                -- 取消录音
    onVoice_img         = "ui/Icon0154.png",                -- 开始录音
    chenwei_name_bgimg  = "TextField0010.png",              -- 角色名称或者称谓底图
    pet_skill_none      = "Frame0090.png",                  -- 不能拥有的技能底图
    newGuyGift          = "ui/Icon0118.png",
    create_role_back    = "ui/CreateChar0011.jpg",          -- 创建角色背景图
    small_tip           = "Frame0078.png",                  -- 不可选提示框背景图
    have_img            = "ui/Icon0095.png",                -- 已拥有图片
    advanced_img        = "ui/Icon0168.png",                -- 历练中图片

    luezhen_flag_new        = "ui/Icon0525.png",                -- 掠阵标识符 新
    canzhan_flag_new        = "ui/Icon0523.png",                -- 参战标识符 新
    gongtong_flag_new       = "ui/Icon0537.png",                -- 共通标识符 新
    ride_flag_new           = "ui/Icon0591.png",                -- 骑乘标识
    follow_flag_new         = "ui/Icon2603.png",                -- 跟随标识

    fuzhu_flag              = "ui/Icon0524.png",                -- 守护辅助
    attack_flag             = "ui/Icon0529.png",                -- 守护攻击

    polar_metal         = "ui/Icon0172.png",                -- 金
    polar_wood          = "ui/Icon0173.png",                -- 木
    polar_water         = "ui/Icon0174.png",                -- 水
    polar_fire          = "ui/Icon0175.png",                -- 火
    polar_earth         = "ui/Icon0176.png",                -- 土

    suit_polar_metal         = "Polar0001.png",                -- 金
    suit_polar_wood          = "Polar0003.png",                -- 木
    suit_polar_water         = "Polar0005.png",                -- 水
    suit_polar_fire          = "Polar0007.png",                -- 火
    suit_polar_earth         = "Polar0009.png",                -- 土

    -- 与策划杨东黎确认，仅在 CombatStatusDlg 界面使用的相性资源
    combatStatusDlg_polar_metal         = "ui/Polar0020.png",                -- 金
    combatStatusDlg_polar_wood          = "ui/Polar0021.png",                -- 木
    combatStatusDlg_polar_water         = "ui/Polar0022.png",                -- 水
    combatStatusDlg_polar_fire          = "ui/Polar0023.png",                -- 火
    combatStatusDlg_polar_earth         = "ui/Polar0024.png",                -- 土

    shengx_shu  = "wuxing0001.png",
    shengx_niu  = "wuxing0002.png",
    shengx_hu   = "wuxing0003.png",
    shengx_tu   = "wuxing0004.png",
    shengx_long = "wuxing0005.png",
    shengx_she  = "wuxing0006.png",
    shengx_ma   = "wuxing0007.png",
    shengx_yang = "wuxing0008.png",
    shengx_hou  = "wuxing0009.png",
    shengx_ji   = "wuxing0010.png",
    shengx_gou  = "wuxing0011.png",
    shengx_zhu  = "wuxing0012.png",

    add_symbol          = "Button0103.png",    				-- 加号底图
    ask_symbol          = "Icon0235.png",            -- 问号

    auto_talk_add_symbol = "ui/Icon0969.png",

    guard_rank1 = "Frame0141.png",
    guard_rank2 = "Frame0142.png",
    guard_rank3 = "Frame0143.png",

    guard_attr_rank1 = "ui/Icon0242.png",
    guard_attr_rank2 = "ui/Icon0243.png",
    guard_attr_rank3 = "ui/Icon0244.png",

    guard_status_combat         = "ui/Icon0094.png",
    guard_status_use_skill_d    = "ui/Icon0252.png",

    talk_bubbles                = "ui/Frame0185.png",    -- 气泡聊天背景
    talk_bubbles_arrow          = "ui/Frame0186.png",
    friend_heart_filled         = "ui/Icon0248.png",
    friend_heart_empty          = "ui/Icon0249.png",

    reward_big_banggong         = "BigRewardIcon0001.png",
    reward_big_daohang_exp      = "BigRewardIcon0002.png",
    reward_big_daohang          = "BigRewardIcon0003.png",
    reward_big_wuxue            = "BigRewardIcon0053.png",
    reward_big_money_exp        = "BigRewardIcon0004.png",
    reward_big_exp              = "BigRewardIcon0005.png",
    reward_big_pot_daohang      = "BigRewardIcon0006.png",
    reward_big_pot_money        = "BigRewardIcon0007.png",
    reward_big_pot_money_dao    = "BigRewardIcon0008.png",
    reward_big_pot_exp          = "BigRewardIcon0009.png",
    reward_big_pot              = "BigRewardIcon0010.png",
    reward_big_shengwang        = "BigRewardIcon0011.png",
    reward_big_jewelry          = "BigRewardIcon0012.png",
    reward_big_unidentified_equip    = "BigRewardIcon0013.png",
    reward_big_equip            = "BigRewardIcon0014.png",
    reward_big_VIP              = "BigRewardIcon0023.png",
    reward_big_fashion              = "BigRewardIcon0047.png",
    -- 装备底图
    blue_equip_back_image   = "Frame0141.png",    -- 蓝装底图
    pink_equip_back_image   = "Frame0142.png",    -- 粉装底图
    yellow_equip_back_image = "Frame0143.png",    -- 黄装底图
    green_equip_back_image  = "Frame0159.png",    -- 绿装底图
    suit_equip_back_image   = "Frame0160.png",    -- 套装底图

    equip_one  = 'ui/Icon0319.png',
    equip_two  = 'ui/Icon0318.png',

    -- 分享图片
    sys_share_pic = "noencrypt/sharePic.jpg",
    sys_share_pic_qr_code = "noencrypt/sharePic3.png",

    -- 滚动条图片
    slider_scroll_image = "Slider0002.png",

    evolve_star_gray         = "ui/Icon0003.png",
    evolve_star_compelete    = "ui/Icon0002.png",
    evolve_star_tobe         = "ui/Icon0522.png",

    dianhua_logo         = "ui/Icon0437.png",
    huanhua_logo         = "ui/Icon0544.png",
    expensive_logo       = "ui/Icon0438.png",
    fenghua_logo         = "ui/Icon0573.png",
    fly_logo             = "ui/Icon0914.png",
    banner_image         = "ui/Icon0502.png",     -- 横幅
    yuhua_logo           = "ui/Icon1567.png",

    -- 擂台小霸王
    arena_one               = "ui/Icon0576.png",
    arena_two               = "ui/Icon0577.png",
    arena_three             = "ui/Icon0578.png",
    arena_four              = "ui/Icon0579.png",
    arena_five              = "ui/Icon0580.png",

    item_huafei         = "ui/Icon0589.png",
    no_bachelor_pick        = "ui/Icon0601.png",

    tradingFlag_public              = "ui/Icon0595.png",
    tradingFlag_sell                = "ui/Icon0596.png",
    tradingFlag_timeOut             = "ui/Icon0597.png",
    tradingFlag_freeze              = "ui/Icon0598.png",

    dunWu_skill_mark                = "SkillText0041.png",

    artifact_special_skill_mark     = "SkillText0042.png",

    -- 道
    dao_word                        = "ui/Icon0667.png",

    -- 抽奖刮图
    scratch_lottery                 = "ui/Icon0666.png",

    -- 默认审核图标
    default_review_icon             = "ui/Icon0712.png",

    -- 防外挂点击
    touch_pos                       = "ui/Icon0729.png",

    is_yes                           = 'Frame0080.png',
    is_no                            = 'Button0030.png',
    phy_img                         = "ui/Icon0942.png",
    mag_img                         = "ui/Icon0943.png",
    comeback_flag                    = 'ui/Icon0952.png',

    prevent_fatigue_0                = 'ui/Button0223.png', -- 防沉迷时，05:00-02:01 期间显示的图片
    prevent_fatigue_3                = 'ui/Button0222.png', -- 防沉迷时，02:00-00:01 期间显示的图片
    prevent_fatigue_5                = 'ui/Button0221.png', -- 防沉迷时，00:00 显示的图片

    smiling_face                     = "ui/Icon1098.png",   -- 笑脸
    crying_face                      = "ui/Icon1099.png",   -- 哭脸

    cultivated_farmland               = "ui/Icon1102.png",   -- 开垦的农田
    uncultivated_farmland             = "ui/Icon1103.png",   -- 未开垦的农田（尺寸 192 * 104）

    cultivated_farmland_96          = "ui/Icon1316.png",   -- 未开垦的农田（尺寸 96 * 96）

    farmland_has_insect               = "ui/Icon1173.png",     -- 有害虫的标识
    farmland_has_rederal              = "ui/Icon1172.png",     -- 有杂草的标识
    farmland_has_thirst               = "ui/Icon1174.png",     -- 土壤缺水
    farmland_crop_is_grown            = "ui/Icon1175.png",     -- 农作物成熟

    fish_background                 = "ui/Icon1145.png",    -- 居所钓鱼背景
    fish_default_portrait           = "ui/Icon1140.png",   -- 钓鱼默认头像
    not_pole_default                =  "ui/Icon1142.png",   -- 没有选择鱼竿时的默认图片
    not_bait_default                =  "ui/Icon1143.png",   -- 没有选择鱼饵时的默认图片

    plant_earth_cracked             =  "ui/Icon1169.png",   -- 土地龟裂
    plant_weed1                     =  "ui/Icon1170.png",   -- 杂草1
    plant_weed2                     =  "ui/Icon1171.png",   -- 杂草2

    hexia_word                      = "ui/Icon1214.png", --"河虾",
    hexie_word                      = "ui/Icon1215.png",  -- 河蟹
    xiaohuangyu_word                = "ui/Icon1216.png", --"小黄鱼",
    caoyu_word                      = "ui/Icon1217.png", --"草鱼",
    nianyu_word                     = "ui/Icon1218.png", --"鲶鱼",
    niqiu_word                      = "ui/Icon1219.png", --"泥鳅",
    liyu_word                       = "ui/Icon1220.png", --"鲤鱼",
    duobaoyu_word                   = "ui/Icon1222.png", --"多宝鱼",
    shibanyu_word                   = "ui/Icon1223.png", --"石斑鱼"
    qinglongyu_word                 = "ui/Icon1224.png", --"青龙鱼",
    shayu_word                      = "ui/Icon1225.png", -- "鲨鱼",
    hetun_word                      = "ui/Icon1221.png", --"河豚",

    menu_item_vip                   = "ui/Icon1268.png",

    small_hint_bed                 = "ui/Icon1258.png",  -- 床提示小图标
    small_hint_sleep               = "ui/Icon1259.png",  -- 睡觉提示小图标
    small_hint_pond                = "ui/Icon1260.png",  -- 荷塘提示小图标
    small_hint_fish                = "ui/Icon1261.png",  -- 鱼提示小图标
    small_hint_tree                = "ui/Icon0938.png",  -- 树提示小图标
    small_hint_zcnf                = "ui/Icon1262.png",  -- 招财纳福提示小图标
    small_hint_home                = "ui/Icon1017.png",  -- 居所提示小图标
    small_hint_broom               = "ui/Icon1018.png",  -- 扫帚提示小图标
    home_broom                     = "ui/Icon1263.png",  -- 居所扫帚图标

    xiaoshe_hetang                 = "ui/Icon1255.png",  -- 小舍河塘图标
    yazhu_hetang                   = "ui/Icon1256.png",  -- 雅筑河塘图标
    haozhai_hetang                 = "ui/Icon1257.png",  -- 豪宅河塘图标

    tianzhijuan                     = "ui/Icon1237.png",  -- 天之卷
    dizhijuan                       = "ui/Icon1236.png",  -- 地之卷
    renzhijuan                      = "ui/Icon1235.png",  -- 人之卷

    pyjs_feed_grass                 = "ui/Icon1244.png",  -- 培育巨兽-喂食灵草
    pyjs_yizhixunlian               = "ui/Icon1245.png",  -- 培育巨兽-益智训练
    pyjs_zhandouxunlian             = "ui/Icon1246.png",  -- 培育巨兽-战斗训练
    pyjs_xuexijishu                 = "ui/Icon1247.png",  -- 培育巨兽-学习技术
    pyjs_yunqiceshi                 = "ui/Icon1248.png",  -- 培育巨兽-运气测试
    pyjs_suduxunlian                = "ui/Icon1249.png",  -- 培育巨兽-速度训练

    -- 培育巨兽 n 阶
    chinese_num1                    = "ui/Icon1185.png", -- 中文一
    chinese_num2                    = "ui/Icon1186.png", -- 中文二
    chinese_num3                    = "ui/Icon1187.png", -- 中文三
    chinese_num4                    = "ui/Icon1188.png", -- 中文四
    chinese_num5                    = "ui/Icon1189.png", -- 中文五
    chinese_num6                    = "ui/Icon1190.png", -- 中文六
    chinese_num7                    = "ui/Icon1191.png", -- 中文七

    blog_kangnaixin                 = "ui/Icon1336.png", -- 个人空间-康乃馨
    blog_yujinxiang                 = "ui/Icon1338.png", -- 个人空间-郁金香
    blog_lanmeigui                  = "ui/Icon1337.png", -- 个人空间-蓝玫瑰

    likeImage                     = 'ui/Icon1370.png',

    npc_word_chat                   = "ui/Icon1522.png", -- 聊天界面中的NPC文字标识

    dcdh_reward_bg_metal            = "ui/Icon1310.png",  -- 斗宠大会-金属性宠物奖励背景
    dcdh_reward_bg_wood             = "ui/Icon1311.png",  -- 斗宠大会-木属性宠物奖励背景
    dcdh_reward_bg_water            = "ui/Icon1312.png",  -- 斗宠大会-水属性宠物奖励背景
    dcdh_reward_bg_fire             = "ui/Icon1313.png",  -- 斗宠大会-火属性宠物奖励背景
    dcdh_reward_bg_earth            = "ui/Icon1314.png",  -- 斗宠大会-土属性宠物奖励背景
    dcdh_reward_bg_none             = "ui/Icon1315.png",  -- 斗宠大会-无属性宠物奖励背景

    dcdh_chengwei_none              = "ui/Icon1293.png",  -- 斗宠大会-无称谓图标
    dcdh_chengwei_xcdr              = "ui/Icon1294.png",  -- 斗宠大会-驯宠达人图标
    dcdh_chengwei_xczj              = "ui/Icon1295.png",  -- 斗宠大会-驯宠专家图标
    dcdh_chengwei_xcds              = "ui/Icon1296.png",  -- 斗宠大会-驯宠大师图标

    dcdh_choose_pet                 = "ui/Icon1346.png",  -- 宠物布阵-选中宠物光圈

    zhanbao_order_up_plist          = "Frame0119.png",   -- 战报排名上升图标
    zhanbao_order_down_plist        = "Frame0118.png",   -- 战报排名下降图标

    upgrade_immortal                = "ui/Icon1411.png",    -- 飞仙图标
    upgrade_magic                   = "ui/Icon1412.png",    -- 飞魔图标
    user_upgrade_immortal_icon      = "ui/Icon1431.png",    -- 角色界面仙图标
    user_upgrade_magic_icon         = "ui/Icon1429.png",    -- 角色界面魔图标
    user_upgrade_immortal_light     = "ui/Icon1430.png",    -- 角色界面仙光效图片
    user_upgrade_magic_light        = "ui/Icon1428.png",    -- 角色界面魔光效图片

    metal_male_big_image              = "ui/CreateChar0002.png",    -- 金男创建角色时的大图片
    metal_female_big_image            = "ui/Icon0461.png",          -- 金女创建角色时的大图片
    wood_male_big_image               = "ui/Icon0462.png",          -- 木男创建角色时的大图片
    wood_female_big_image             = "ui/CreateChar0004.png",    -- 木女创建角色时的大图片
    water_male_big_image              = "ui/Icon0463.png",          -- 水男创建角色时的大图片
    water_female_big_image            = "ui/CreateChar0006.png",    -- 水女创建角色时的大图片
    fire_male_big_image               = "ui/CreateChar0008.png",    -- 火男创建角色时的大图片
    fire_female_big_image             = "ui/Icon0464.png",          -- 火女创建角色时的大图片
    earth_male_big_image              = "ui/CreateChar0010.png",    -- 土男创建角色时的大图片
    earth_female_big_image            = "ui/Icon0465.png",          -- 土女创建角色时的大图片

    vacation_homework_num_one         = "ui/Icon1451.png",  -- 寒假作业题目编号：大写一
    vacation_homework_num_two         = "ui/Icon1452.png",  -- 寒假作业题目编号：大写二
    vacation_homework_num_three       = "ui/Icon1453.png",  -- 寒假作业题目编号：大写三
    vacation_homework_num_four        = "ui/Icon1454.png",  -- 寒假作业题目编号：大写四
    vacation_homework_num_five        = "ui/Icon1455.png",  -- 寒假作业题目编号：大写五
    vacation_homework_num_six         = "ui/Icon1456.png",  -- 寒假作业题目编号：大写六
    vacation_homework_num_seven       = "ui/Icon1457.png",  -- 寒假作业题目编号：大写七
    vacation_homework_num_eight       = "ui/Icon1458.png",  -- 寒假作业题目编号：大写八
    vacation_homework_num_nine        = "ui/Icon1459.png",  -- 寒假作业题目编号：大写九
    vacation_homework_num_ten         = "ui/Icon1460.png", -- 寒假作业题目编号：大写十

    vacation_homework_nous            = "ui/Icon1461.png",  -- 寒假作业标题：常识
    vacation_homework_chinese         = "ui/Icon1462.png",  -- 寒假作业标题：语文
    vacation_homework_math            = "ui/Icon1463.png",  -- 寒假作业标题：数学
    vacation_homework_guess           = "ui/Icon1464.png",  -- 寒假作业标题：猜谜
    vacation_homework_biology         = "ui/Icon1465.png",  -- 寒假作业标题：生物
    vacation_homework_astronomy       = "ui/Icon1466.png",  -- 寒假作业标题：天文
    vacation_homework_geograpy        = "ui/Icon1467.png",  -- 寒假作业标题：地理
    vacation_homework_chemistry       = "ui/Icon1468.png",  -- 寒假作业标题：化学
    vacation_homework_physical        = "ui/Icon1469.png",  -- 寒假作业标题：物理
    vacation_homework_humanity        = "ui/Icon1470.png",  -- 寒假作业标题：人文

    vacation_persimmon                = "ui/Icon1499.png",  -- 寒假冻柿子图片
    hand_gather                       = "ui/Icon0294.png",  -- 采集时手掌图标：进度条

	-- 神兽
	epic_jiangliang              = "ui/Icon1270.png",
	epic_dongshan                = "ui/Icon1269.png",
	epic_xuanwu                  = "ui/Icon1271.png",
	epic_zhuque                  = "ui/Icon1272.png",

	-- 精怪
	jingGuai_xianyang            = "ui/Icon0570.png",
	jingGuai_lingyan             = "ui/Icon0566.png",
	jingGuai_huanlu              = "ui/Icon0565.png",
	jingGuai_chiyan              = "ui/Icon0563.png",
	jingGuai_yubao               = "ui/Icon0571.png",
	jingGuai_xianhu              = "ui/Icon0569.png",
	jingGuai_wuji                = "ui/Icon0568.png",
	jingGuai_yuelu               = "ui/Icon0572.png",
	jingGuai_gulu                = "ui/Icon0564.png",
	jingGuai_beiji               = "ui/Icon0562.png",
	jingGuai_taiji               = "ui/Icon0567.png",

	-- 纪念
    jinian_wenyu                 = "ui/Icon0842.png",
	jinian_hongdao               = "ui/Icon0843.png",

	-- 分页标签
	page_circle_selected         = "ui/Icon0668.png",
	page_circle_unSelected       = "ui/Icon0669.png",

	-- 实物与话费（抽奖）
	shiwu1  					 = "ui/Icon1074.png",
    shiwu2  					 = "ui/Icon1075.png",
    shiwu3  					 = "ui/Icon1076.png",
    shiwu4  					 = "ui/Icon1082.png",
    shiwu5  					 = "ui/Icon1083.png",
    shiwu6  					 = "ui/Icon1077.png",
    shiwu7  					 = "ui/Icon1078.png",
    shiwu8  					 = "ui/Icon1079.png",
    shiwu9  					 = "ui/Icon1080.png",
    shiwu10 					 = "ui/Icon1081.png",
    shiwu11 					 = "ui/Icon1085.png",
    shiwu12 					 = "ui/Icon1084.png",
    shiwu13 					 = "ui/Icon0074.png",
    shiwu14                      = "ui/Icon1829.png", -- 小米MIX2S
    shiwu15                      = "ui/Icon1831.png", -- 六福金手串
    shiwu16                      = "ui/Icon1824.png", -- HUAWEI P20
    shiwu17                      = "ui/Icon1826.png", -- OPPO R15
    shiwu18                      = "ui/Icon1828.png", -- VIVO X21
    shiwu19                      = "ui/Icon1830.png", -- Switch NS
    shiwu20                      = "ui/Icon1827.png", -- 100元京东卡
    shiwu21                      = "ui/Icon2610.png", -- HUAWEI P30
    shiwu22                      = "ui/Icon2609.png", -- 30元京东卡
    shiwu23                      = "ui/Icon2612.png", -- OPPO R17
    shiwu24                      = "ui/Icon2613.png", -- vivo X27
    shiwu25                      = "ui/Icon2611.png", -- iPad mini5

	-- 话费（抽奖）
	huafei                       = "ui/Icon0589.png",
    huafei100                    = "ui/Icon1825.png", -- 话费·100元

	reward_gulu                  = "ui/Icon1086.png",
	rewaed_beiji                 = "ui/Icon0734.png",

	-- 战斗自动喊话
	auto_talk1                   = "ui/Icon0972.png",
	auto_talk2                   = "ui/Icon0973.png",
	auto_talk3                   = "ui/Icon0975.png",

	-- 空间语音转圈
	blog_voice_progressTimer     = "ui/Icon1278.png",

	-- 骰子
	bobing_touzi1                       = "BoBing0012.png",
	bobing_touzi2                       = "BoBing0013.png",
	bobing_touzi3                       = "BoBing0014.png",
	bobing_touzi4                       = "BoBing0015.png",
	bobing_touzi5                       = "BoBing0016.png",
	bobing_touzi6                       = "BoBing0017.png",

	-- 水岚之缘剪影
    shuilan_jiangying1           = "ui/Icon1491.png",
    shuilan_jiangying2           = "ui/Icon1492.png",
    shuilan_jiangying3           = "ui/Icon1493.png",
    shuilan_jiangying4           = "ui/Icon1494.png",
    shuilan_jiangying5           = "ui/Icon1495.png",
    shuilan_jiangying6           = "ui/Icon1496.png",
    shuilan_jiangying7           = "ui/Icon1497.png",
    shuilan_jiangying8           = "ui/Icon1498.png",

	-- 水岚之缘序号
    shuilan_no1                  = "ui/Icon1481.png",
    shuilan_no2                  = "ui/Icon1482.png",
    shuilan_no3                  = "ui/Icon1483.png",
    shuilan_no4                  = "ui/Icon1484.png",
    shuilan_no5                  = "ui/Icon1485.png",
    shuilan_no6                  = "ui/Icon1486.png",
    shuilan_no7                  = "ui/Icon1487.png",
    shuilan_no8                  = "ui/Icon1488.png",

	-- 守岁年夜饭界面
	caiyao1                      = "ui/Icon2268.png",
    caiyao2                      = "ui/Icon2269.png",
    caiyao3                      = "ui/Icon2270.png",
    caiyao4                      = "ui/Icon2271.png",
    caiyao5                      = "ui/Icon2272.png",
    caiyao6                      = "ui/Icon2273.png",

	-- 主界面图标
	main_icon1                   = "MainIcon0001.png",
	main_icon2                   = "MainIcon0002.png",
	main_icon3                   = "MainIcon0003.png",
	main_icon4                   = "MainIcon0004.png",
	main_icon5                   = "MainIcon0005.png",
	main_icon6                   = "MainIcon0006.png",
	main_icon8                   = "MainIcon0008.png",
	main_icon10                  = "MainIcon0010.png",  -- 福利图标
	main_icon13                  = "MainIcon0013.png",
	main_icon14                  = "MainIcon0014.png",
	main_icon17                  = "MainIcon0017.png",
	main_icon18                  = "MainIcon0018.png",
	main_icon21                  = "MainIcon0021.png",
	main_icon22                  = "MainIcon0022.png",
	main_icon26                  = "MainIcon0026.png",
	main_icon27                  = "MainIcon0027.png",
	main_icon29                  = "MainIcon0029.png",
	main_icon30                  = "MainIcon0030.png",
	main_icon31                  = "MainIcon0031.png",
	main_icon32                  = "MainIcon0032.png",
    main_icon34                  = "MainIcon0034.png", -- 周年庆图标
	main_icon40                  = "MainIcon0040.png",
	main_icon43                  = "MainIcon0043.png",
	main_icon50                  = "MainIcon0050.png",  -- 寻缘
	main_icon51                  = "MainIcon0051.png",  -- 纪念册
    main_icon52                  = "MainIcon0052.png",  -- 货站
	main_icon_achieve            = "ui/Icon1265.png",
    main_icon_goodvoice            = "ui/Icon2567.png",

	-- 输入框背景
	editBox_back                 = "Frame0011.png",

	-- 节日活动界面
	reward_box1                  = "ui/Icon0559.png",
    reward_box2                  = "ui/Icon0560.png",
    reward_box3                  = "ui/Icon0561.png",
    reward_box4                  = "ui/Icon0690.png",

	-- 宠物食粮
	pet_food_buy                 = "ui/Icon1049.png",


	-- 鱼类等级文字
    fish_level_word1             = "ui/Icon1201.png",
	fish_level_word2             = "ui/Icon1202.png",
	fish_level_word3             = "ui/Icon1203.png",
	fish_level_word4             = "ui/Icon1204.png",
	fish_level_word5             = "ui/Icon1205.png",
	fish_level_word6             = "ui/Icon1206.png",
	fish_level_word7             = "ui/Icon1207.png",
	fish_level_word8             = "ui/Icon1208.png",
	fish_level_word9             = "ui/Icon1209.png",
	fish_level_word10            = "ui/Icon1210.png",
	fish_level_word11            = "ui/Icon1211.png",
	fish_level_word12            = "ui/Icon1212.png",

	-- 钓鱼浮漂倒计时
	fish_progressTimer           = "ui/Icon1149.png",
    wawa_circle_progressTimer           = "ui/Background0254.png",

	-- 家具摆放界面
	furn_type_image1             = "ui/Icon1031.png",    --前庭-桌凳
    furn_type_image2             = "ui/Icon1027.png",    --前庭-摆设
    furn_type_image3             = "ui/Icon1030.png",    --前庭-围墙
    furn_type_image4             = "ui/Icon1028.png",    --前庭-地面
    furn_type_image5             = "ui/Icon1029.png",    --前庭-功能
    furn_type_image6             = "ui/Icon1021.png",    --房屋-床柜
    furn_type_image7             = "ui/Icon1026.png",    --房屋-桌椅
    furn_type_image8             = "ui/Icon1020.png",    --房屋-摆设
    furn_type_image9             = "ui/Icon1024.png",    --房屋-墙饰
    furn_type_image10            = "ui/Icon1022.png",    --房屋-地毯
    furn_type_image11            = "ui/Icon1023.png",    --房屋-地砖
    furn_type_image12            = "ui/Icon1025.png",    --房屋-功能
    furn_type_image13            = "ui/Icon1033.png",    --后院-椅凳
    furn_type_image14            = "ui/Icon1032.png",    --后院-摆设
    furn_type_image15            = "ui/Icon1251.png",    --后院-功能

	-- 居所
	house_xiaoshe                = "ui/Icon0982.png",
    house_yazhu                  = "ui/Icon0983.png",
    house_haozhai                = "ui/Icon0984.png",

	-- 第一次进入游戏加载文字
    first_start_game1            = "ui/CreateChar0014.png",
	first_start_game2            = "ui/CreateChar0015.png",

    -- 禁止登录模拟器界面
	service_tel                  = "ui/Icon1448.png",
	service_qq                   = "ui/Icon1449.png",
	service_qq_group             = "ui/Icon1502.png",
	service_wx                   = "ui/Icon1503.png",

	-- 好运宝鉴界面
	quest_mark                   = "ui/Icon1378.png",
    option_a                     = "ui/Icon0432.png",
    option_b                     = "ui/Icon0433.png",
    option_c                     = "ui/Icon0434.png",

	-- 义士招募/辞退界面
	quest_mark_plist             = "Icon0235.png",

	-- 矿石大战宝石使用界面
	qiangli_word1                = "ui/Icon0868.png",
    qiangli_word2                = "ui/Icon0894.png",
    qiangli_word3                = "ui/Icon0895.png",
    qiangli_word4                = "ui/Icon0896.png",
    qiangli_word5                = "ui/Icon0897.png",
    qiangli_word6                = "ui/Icon0898.png",

    qiangli_circlr1              = "ui/Icon0865.png",
    qiangli_circlr2              = "ui/Icon0892.png",
    qiangli_circlr3              = "ui/Icon0893.png",

    ore_progress_timer           = "ui/Icon0864.png",

	-- 挑战巨兽结算界面
	mvp_word                     = 'ui/Icon1371.png',  -- MVP
    shenyi_word                  = 'ui/Icon1373.png',  -- 表示神医
    shenfeng_word                = 'ui/Icon1372.png',  -- 表示神封

	-- 骑宠召唤界面
    call_pet_back                = "ui/Frame0169.png",

	-- 宠物成长-进度条
	progressbar43                = "ProgressBar0043.png",
	progressbar44                = "ProgressBar0044.png",
	progressbar41                = "ProgressBar0041.png",

    -- 宠物成长总览界面
    pet_skill_grid	             = "Frame0104.png",

	-- 分享
	atm_logo                     = "ui/LogoW.png",
	atm_share_url_logo           = "noencrypt/ShareReward.png",
    atm_share_url_icon           = "noencrypt/ShareIcon.jpg",

	-- 奖励界面
	qmpk_stage_title_word1        = "ui/Icon0804.png",
    qmpk_stage_title_word2        = "ui/Icon0871.png",
    qmpk_stage_title_word3        = "ui/Icon0803.png",
    qmpk_stage_title_word4        = "ui/Icon0802.png",
    qmpk_stage_title_word5        = "ui/Icon0801.png",
    qmpk_stage_title_word6        = "ui/Icon0800.png",
    qmpk_stage_title_word7        = "ui/Icon0799.png",
    qmpk_stage_title_word9        = "ui/Icon2104.png",
    qmpk_stage_title_word10       = "ui/Icon2105.png",

	metal_male_back               = "ui/Icon0407.png",
    metal_female_back             = "ui/Icon0517.png",
    wood_male_back                = "ui/Icon0518.png",
    wood_female_back              = "ui/Icon0408.png",
    water_male_back               = "ui/Icon0519.png",
    water_female_back             = "ui/Icon0409.png",
    fire_male_back                = "ui/Icon0410.png",
    fire_female_back              = "ui/Icon0520.png",
    earth_male_back               = "ui/Icon0411.png",
    earth_female_back             = "ui/Icon0521.png",

    -- 搜邪罗盘界面
    souxlp_init_tip                = "ui/Icon1393.png",
    souxlp_correct_tip             = "ui/Icon1394.png",
    souxlp_toMiddle_tip            = "ui/Icon1395.png",
    souxlp_mistake_tip             = "ui/Icon1396.png",
    souxlp_toNeedle_tip            = "ui/Icon1397.png",
    souxlp_finish_tip              = "ui/Icon1398.png",

	-- 今日统计界面
	statistics_siwang              = "Icon0292.png",
	statistics_shizhong            = "Frame0111.png",
	statistics_shuadao             = "ui/Icon0293.png",

	-- 超级大BOSS，选择boss界面
    super_boss_word1               = "ui/Icon0639.png",      -- 黑熊妖皇
    super_boss_word2               = "ui/Icon0673.png",      -- 血炼魔猪
    super_boss_word3               = "ui/Icon0731.png",      -- 赤血鬼猿
    super_boss_word4               = "ui/Icon0959.png",

    jiut_boss_zhu               = "ui/Icon2001.png",      -- 朱天君
    jiut_boss_cheng               = "ui/Icon2002.png",      -- 成天君
    jiut_boss_you               = "ui/Icon2003.png",      -- 幽天君
    qisha_boss               = "ui/Icon1600.png",      -- 七杀


    jiutian_ztj                    = "ui/Icon2115.png",     -- 九天朱天君
    jiutian_ctj                    = "ui/Icon2116.png",     -- 九天成天君
    jiutian_ytj                    = "ui/Icon2117.png",     -- 九天幽天君

	-- 推送界面
    system_push_back1              = "TextField0007.png",
	system_push_back2              = "TextField0008.png",

    -- 队伍界面
	team_state_guard               = "ui/Icon0125.png",
	team_state_zanli               = "ui/Icon0124.png",
	team_state_captain             = "ui/Icon0121.png",

	-- 打雪仗技能界面
	vacation_show_skill1           = 'ui/Icon1437.png',
	vacation_show_skill2           = 'ui/Icon1436.png',
	vacation_show_skill3           = 'ui/Icon1439.png',
	vacation_show_skill4           = 'ui/Icon1438.png',

    -- 等待转圈界面
    wait_circle                    = "ui/Icon0250.png",

	-- 观战中心 - 赛事详情界面
	watch_centre_tag1              = "ui/Icon0744.png", -- 金
    watch_centre_tag2              = "ui/Icon0747.png", -- 木
    watch_centre_tag3              = "ui/Icon0748.png", -- 水
    watch_centre_tag4              = "ui/Icon0743.png", -- 水
    watch_centre_tag5              = "ui/Icon0751.png", -- 水
	watch_centre_tag6              = "ui/Icon0745.png", -- 金
	watch_centre_tag7              = "ui/Icon0746.png", -- 木
	watch_centre_tag8              = "ui/Icon0749.png", -- 水
	watch_centre_tag9              = "ui/Icon0742.png", -- 水
	watch_centre_tag10             = "ui/Icon0750.png", -- 水

	watch_play_type1               = 'ui/Icon0720.png',
	watch_play_type2               = 'ui/Icon0721.png',

    watch_type1                    = 'ui/Icon0718.png',   -- 跨服帮战
    watch_type2                    = 'ui/Icon0717.png',   -- 帮战
    watch_type3                    = 'ui/Icon0719.png',   -- 跨服试道大会
    watch_type4                    = 'ui/Icon0716.png',   -- 试道大会
    watch_type5                    = 'ui/Icon0741.png',   -- 全民PK赛
    watch_type6                    = 'ui/Icon1125.png',   -- 跨服战场
    watch_type7                    = 'ui/Icon1582.png',   -- 跨服竞技
    watch_type8                    = 'ui/Icon1871.png',   -- 名人争霸赛

	-- 进度条
	progressbar_red                = "ui/ProgressBar0047.png",
    progressbar_blue               = "ui/ProgressBar0045.png",
    progressbar_green              = "ui/ProgressBar0049.png",

	-- 区组管理器
	dist_state1 				   = "ui/Icon0229.png", -- 维护
	dist_state2 				   = "ui/Icon0226.png", -- 正常
	dist_state3 				   = "ui/Icon0227.png", -- 繁忙
	dist_state4 				   = "ui/Icon0228.png", -- 爆满

	dist_state_word1               = "ui/Icon0224.png", -- 爆满
	dist_state_word2               = "ui/Icon0225.png", -- 满员
	dist_state_word3               = "ui/Icon0253.png", -- 空

	-- 成就
	achieve_jueban_word            = "ui/Icon1504.png",

    -- 指引
	guide_click_circle             = "ui/GuideImage0001.png",
	guide_light_circle             = "ui/Background042.png",

	-- 宠物食盆上的食粮
	pet_bowl_food11 			   = "ui/Icon1040.png",
	pet_bowl_food12                = "ui/Icon1041.png",
	pet_bowl_food13                = "ui/Icon1042.png",
	pet_bowl_food21                = "ui/Icon1043.png",
	pet_bowl_food22                = "ui/Icon1044.png",
	pet_bowl_food23                = "ui/Icon1045.png",
	pet_bowl_food31                = "ui/Icon1046.png",
	pet_bowl_food32                = "ui/Icon1047.png",
	pet_bowl_food33                = "ui/Icon1048.png",

	-- 龙争虎斗
    lzhd_no1                       = 'ui/Icon0646.png',
    lzhd_no2                       = 'ui/Icon0647.png',
    lzhd_no3                       = 'ui/Icon0648.png',
    lzhd_no4                       = 'ui/Icon0649.png',
    lzhd_no5                       = 'ui/Icon0650.png',
    lzhd_no6                       = 'ui/Icon0651.png',
    lzhd_no7                       = 'ui/Icon0652.png',
    lzhd_no8                       = 'ui/Icon0653.png',

	-- 元婴/血婴
	yuanying                       = "ui/Icon0883.png",
	xueying                        = "ui/Icon0882.png",

	-- 更新场景
	updateScene_logo               = "ui/Icon0241.png",
	health_notice                  = "ui/Icon0527.png",
	oper_right                     = "ui/Icon0526.png",

	-- 圆的角色头像
	char_protrait_circle6001 = "ui/Icon0824.png",
    char_protrait_circle6002 = "ui/Icon0826.png",
    char_protrait_circle6003 = "ui/Icon0828.png",
    char_protrait_circle6004 = "ui/Icon0830.png",
    char_protrait_circle6005 = "ui/Icon0832.png",
    char_protrait_circle7001 = "ui/Icon0825.png",
    char_protrait_circle7002 = "ui/Icon0827.png",
    char_protrait_circle7003 = "ui/Icon0829.png",
    char_protrait_circle7004 = "ui/Icon0831.png",
    char_protrait_circle7005 = "ui/Icon0833.png",

	-- 相性标识
	SmallPolar1              = "SmallPolar0001.png",
	SmallPolar2              = "SmallPolar0002.png",
	SmallPolar3              = "SmallPolar0003.png",
	SmallPolar4              = "SmallPolar0004.png",
	SmallPolar5              = "SmallPolar0005.png",
	SmallPolar6              = "SmallPolar0006.png",

	-- 角色形象图
	role_metal_male          = "ui/Icon0101.png",
    role_metal_female        = "ui/Icon0496.png",
    role_wood_male           = "ui/Icon0497.png",
    role_wood_female         = "ui/Icon0102.png",
    role_water_male          = "ui/Icon0498.png",
    role_water_female        = "ui/Icon0103.png",
    role_fire_male           = "ui/Icon0104.png",
    role_fire_female         = "ui/Icon0499.png",
    role_earth_male          = "ui/Icon0105.png",
    role_earth_female        = "ui/Icon0500.png",

	-- 宠物
	jingguai_word           = "ui/Icon0574.png",
	yuling_word             = "ui/Icon0575.png",
	yesheng_word            = "ui/Icon0441.png",
    dianhua_word            = "ui/Icon0444.png",
	qianghua_word           = "ui/Icon0443.png",
	baobao_word             = "ui/Icon0442.png",
	bianyi_word             = "ui/Icon0445.png",
	shenshou_word           = "ui/Icon1273.png",
    yuhua_word              = "ui/Icon1566.png",

	-- 技能等阶图片
    skill_ladder1           = "SkillText0021.png",
    skill_ladder2           = "SkillText0022.png",
    skill_ladder3           = "SkillText0023.png",
    skill_ladder4           = "SkillText0024.png",
    skill_ladder5           = "SkillText0025.png",

	-- 战斗中状态效果
	fight_buff01            = "BuffIcon0001.png",
	fight_buff02            = "BuffIcon0002.png",
	fight_buff03            = "BuffIcon0003.png",
	fight_buff04            = "BuffIcon0004.png",
	fight_buff05            = "BuffIcon0005.png",
	fight_buff06            = "BuffIcon0006.png",
	fight_buff07            = "BuffIcon0007.png",
	fight_buff08            = "BuffIcon0008.png",
	fight_buff09            = "BuffIcon0009.png",
	fight_buff10            = "BuffIcon0010.png",
	fight_buff11            = "BuffIcon0011.png",
	fight_buff12            = "BuffIcon0012.png",
	fight_buff13            = "BuffIcon0013.png",
	fight_buff14            = "BuffIcon0014.png",
	fight_buff15            = "BuffIcon0015.png",
	fight_buff16            = "BuffIcon0016.png",
	fight_buff17            = "BuffIcon0017.png",
	fight_buff18            = "BuffIcon0018.png",
	fight_buff19            = "BuffIcon0019.png",
	fight_buff20            = "BuffIcon0020.png",
	fight_buff21            = "BuffIcon0021.png",
	fight_buff22            = "BuffIcon0022.png",
	fight_buff23            = "BuffIcon0023.png",
	fight_buff24            = "BuffIcon0024.png",
	fight_buff25            = "BuffIcon0025.png",
	fight_buff26            = "BuffIcon0026.png",
	fight_buff27            = "BuffIcon0027.png",
	fight_buff28            = "BuffIcon0028.png",
    fight_buff29            = "BuffIcon0029.png",
    fight_buff30            = "BuffIcon0030.png",
    fight_buff31            = "BuffIcon0031.png",
    fight_buff32            = "BuffIcon0032.png",
    fight_buff33            = "BuffIcon0033.png",
	-- 金钱
	mall_cash1              = "MallIcon0004.png",
	mall_cash2              = "MallIcon0005.png",
	mall_cash3              = "MallIcon0006.png",
	mall_cash4              = "MallIcon0007.png",

	-- 气泡地图
	bubble_back             = "ui/40001.png",

	-- 气泡箭头
	bubble_arrow            = "ui/40002.png",

	-- 技能名字文字
	skill_text01            = "SkillText0001.png",
	skill_text02            = "SkillText0002.png",
	skill_text03            = "SkillText0003.png",
	skill_text04            = "SkillText0004.png",
	skill_text05            = "SkillText0005.png",
	skill_text06            = "SkillText0006.png",
	skill_text07            = "SkillText0007.png",
	skill_text08            = "SkillText0008.png",
	skill_text09            = "SkillText0009.png",
	skill_text10            = "SkillText0010.png",
	skill_text11            = "SkillText0011.png",
	skill_text12            = "SkillText0012.png",
	skill_text13            = "SkillText0013.png",
	skill_text14            = "SkillText0014.png",
	skill_text15            = "SkillText0015.png",
	skill_text16            = "SkillText0016.png",
	skill_text17            = "SkillText0017.png",
	skill_text18            = "SkillText0018.png",
	skill_text26            = "SkillText0026.png",
	skill_text27            = "SkillText0027.png",
	skill_text34            = "SkillText0034.png",
	skill_text37            = "SkillText0037.png",
	skill_text38            = "SkillText0038.png",
	skill_text39            = "SkillText0039.png",
	skill_text36            = "SkillText0036.png",
	skill_text40            = "SkillText0040.png",
	skill_text44            = "SkillText0044.png",
	skill_text45            = "SkillText0045.png",
	skill_text48            = "SkillText0048.png",
	skill_text47            = "SkillText0047.png",
	skill_text43            = "SkillText0043.png",
	skill_text46            = "SkillText0046.png",

    skill_text49            = "SkillText0049.png",
    skill_text50            = "SkillText0050.png",
    skill_text51            = "SkillText0051.png",

	-- 音量图片
	voice_img01             = "ui/Icon0148.png",
    voice_img02             = "ui/Icon0149.png",
    voice_img03             = "ui/Icon0150.png",
    voice_img04             = "ui/Icon0151.png",
    voice_img05             = "ui/Icon0152.png",
    voice_img06             = "ui/Icon0153.png",
    voice_img07             = "ui/Icon0346.png",
    voice_img08             = "ui/Icon0343.png",

    -- 表情链接按钮
    button_expression       = "ui/Button0069.png", -- 问道表情
    button_history          = "ui/Button0148.png", -- 输入历史
    button_char             = "ui/Button0149.png", -- 输入历史
    button_item             = "ui/Button0060.png", -- 道 具
    button_pet              = "ui/Button0065.png", -- 宠 物
    button_call             = "ui/Button0228.png", -- 呼 叫
    button_statistics       = "ui/Button0189.png", -- 今日统计
    button_task             = "ui/Button0070.png", -- 任 务
    button_skill            = "ui/Button0067.png", -- 技 能
    button_partyredbag      = "ui/Button0191.png", -- 红 包
    button_title            = "ui/Button0049.png", -- 称 谓
    button_house            = "ui/Button0226.png", -- 居所展示
    button_watch            = "ui/Icon0722.png",   -- 分享赛事
    button_marketitem       = "ui/Button0232.png", -- 集市
    button_zhenbaoitem      = "ui/Button0233.png", -- 珍宝
    button_jubaoitem        = "ui/Button0240.png", -- 聚宝斋
    button_shake            = "ui/Button0231.png", -- 震动
    button_tradingspot      = "ui/Button0341.png", -- 货站

    zhaohuanling_bianyi     = "ui/Icon0286.png",  -- 召唤令-十二生肖
    zhaohuanling_shenshou   = "ui/Icon1285.png",  -- 召唤令-上古神兽

    grid_progressTimer      = "ui/Icon1509.png",  -- 格子倒计时黑幕

    nyf_lucky               = "ui/Icon1508.png",  -- 年夜饭幸运值图标
    default_icon            = "ui/Icon1546.png",  -- 图片内容为"默认",大小为96x96

    xuejing_jianying  = 'ui/Icon1588.png',        -- 血精剪影
    banner_hxyh = 'ui/Icon1595.png',            -- 黑熊妖皇
    banner_xlmz = 'ui/Icon1596.png',            -- 血炼魔猪
    banner_cxgy = 'ui/Icon1597.png',            -- 赤血鬼猿
    banner_myxh = 'ui/Icon1598.png',            -- 魅影蝎后
    banner_qsmj = 'ui/Icon1599.png',            -- 七杀魔君

    gress = "ui/Icon2642.png",

    inner_alchemy_state_one   = "ui/Icon1541.png",  -- 内丹修炼境界一
    inner_alchemy_state_two   = "ui/Icon1542.png",  -- 内丹修炼境界二
    inner_alchemy_state_three = "ui/Icon1543.png",  -- 内丹修炼境界三
    inner_alchemy_state_four  = "ui/Icon1544.png",  -- 内丹修炼境界四
    inner_alchemy_state_five  = "ui/Icon1545.png",  -- 内丹修炼境界五

    -- 跨服竞技称谓图片
    kuafjj_title_zhisheng     = "ui/Icon1575.png",
    kuafjj_title_zhizun       = "ui/Icon1573.png",
    kuafjj_title_mingwang     = "ui/Icon1571.png",
    kuafjj_title_shanjun      = "ui/Icon1572.png",
    kuafjj_title_zhengren     = "ui/Icon1574.png",
    kuafjj_title_jushi        = "ui/Icon1570.png",
    kuafjj_title_daotong      = "ui/Icon1569.png",

    kuafjj_combat_no_choose   = "ui/Icon1561.png",
    kuafjj_combat_1V1         = "ui/Icon1555.png",
    kuafjj_combat_3V3         = "ui/Icon1556.png",
    kuafjj_combat_5V5         = "ui/Icon1557.png",

    -- 登录换区时人物状态的图片
    login_change_dist_public  = "ui/Icon1576.png",      -- 公示期
    login_change_dist_sell = "ui/Icon1577.png",         -- 寄售期
    login_change_dist_cross_server = "ui/Icon1578.png", -- 跨服中
    login_change_dist_trusteeship = "ui/Icon1579.png",  -- 托管中
    login_change_dist_timeout = "ui/Icon1580.png",      -- 已过期
    login_change_dist_online = "ui/Icon1581.png",       -- 在线中

    -- 世界BOSS 血条
    boss_life_bar_purple  = "ui/ProgressBar0079.png",      -- 紫色血条
    boss_life_bar_blue    = "ui/ProgressBar0077.png",      -- 蓝色血条
    boss_life_bar_green   = "ui/ProgressBar0078.png",      -- 绿色血条
    boss_life_bar_yellow  = "ui/ProgressBar0076.png",      -- 黄色血条
    boss_life_bar_red     = "ui/ProgressBar0075.png",      -- 红色血条

    -- 灵猫不同心情对应图片
    lingmao_mood_0  = "ui/Icon1624.png",
    lingmao_mood_20 = "ui/Icon1623.png",
    lingmao_mood_40 = "ui/Icon1622.png",
    lingmao_mood_60 = "ui/Icon1621.png",
    lingmao_mood_80 = "ui/Icon1620.png",

    -- 灵猫不同饱食度对应图片
    lingmao_food_0  = "ui/Icon1629.png",
    lingmao_food_20 = "ui/Icon1628.png",
    lingmao_food_40 = "ui/Icon1627.png",
    lingmao_food_60 = "ui/Icon1626.png",
    lingmao_food_80 = "ui/Icon1625.png",

    mingrzb_jc_lose = "ui/Icon1651.png", -- 名人争霸赛竞猜失败 标签
    mingrzb_jc_win  = "ui/Icon1652.png", -- 名人争霸赛竞猜胜利 标签
    mingrzb_jc_big_lose = "ui/Icon1668.png", -- 名人争霸赛竞猜失败 大标签
    mingrzb_jc_big_win  = "ui/Icon1667.png", -- 名人争霸赛竞猜胜利 大标签
    mingrzb_jc_win_8    = "ui/Icon1722.png",   -- 名人争霸赛竞猜赛程表8强
    mingrzb_jc_win_32   = "ui/Icon1721.png",   -- 名人争霸赛竞猜赛程表32强

    -- 同城社交
    gender_male_sign   = "ui/Icon1632.png", -- 男性符号
    gender_female_sign = "ui/Icon1633.png", -- 女性符号

    kuaf_logo          = "ui/Icon1631.png",  -- 跨服标识
    button_useful      = "ui/Button0273.png", -- 常用短语按钮

    -- 名人争霸赛
    mrzb_rank_1        = "ui/Icon1648.png",    -- 冠军奖励
    mrzb_rank_2        = "ui/Icon1647.png",    -- 亚军奖励
    mrzb_rank_4        = "ui/Icon1646.png",    -- 四强奖励
    mrzb_rank_8        = "ui/Icon1645.png",    -- 8强奖励
    mrzb_rank_16       = "ui/Icon1644.png",    -- 16强奖励
    mrzb_rank_32       = "ui/Icon1643.png",    -- 32强奖励
    mrzb_rank_64       = "ui/Icon1642.png",    -- 64强奖励
    mrzb_rank_128      = "ui/Icon1685.png",    -- 128强奖励

    jiebai_dage         = "ui/Icon1686.png",    -- 大哥
    jiebai_erge         = "ui/Icon1687.png",    -- 二哥
    jiebai_sange         = "ui/Icon1688.png",    -- 三哥
    jiebai_sige         = "ui/Icon1689.png",    -- 四哥

    jiebai_erdi         = "ui/Icon1690.png",    -- 二弟
    jiebai_sandi         = "ui/Icon1691.png",    -- 三地
    jiebai_sidi         = "ui/Icon1692.png",    -- 四弟
    jiebai_wudi         = "ui/Icon1693.png",    --  五弟

    jiebai_dajie         = "ui/Icon1694.png",    -- 大姐
    jiebai_erjie         = "ui/Icon1695.png",    -- 二哥
    jiebai_sanjie         = "ui/Icon1696.png",    -- 三哥
    jiebai_sijie         = "ui/Icon1697.png",    -- 四哥

    jiebai_ermei         = "ui/Icon1698.png",    -- 二弟
    jiebai_sanmei         = "ui/Icon1699.png",    -- 三地
    jiebai_simei         = "ui/Icon1700.png",    -- 四弟
    jiebai_wumei         = "ui/Icon1701.png",    --  五弟

    shitu_shifu         =  "ui/Icon1702.png",    --  师父
    shitu_tudi         =  "ui/Icon1703.png",    --  徒弟

    fuqi_niangzi      = "ui/Icon1704.png",    --  相公
    fuqi_xianggong      = "ui/Icon1705.png",    --  娘子

    -- 协助好友
    plant_weeding        = "ui/Icon1674.png", -- 除草
    plant_water          = "ui/Icon1675.png", -- 浇水
    plant_kill_insect    = "ui/Icon1676.png", -- 除虫

    -- 寒气之脉
    hqzm_grid_white      = "ui/Icon1816.png", -- 白色格子
    hqzm_grid_dark       = "ui/Icon1815.png", -- 深色格子
    hqzm_wall1           = "ui/Icon1819.png", -- 上边墙
    hqzm_wall2           = "ui/Icon1820.png", -- 下边墙


    vacation_ysgw_skill1 = "ui/Icon1812.png",   -- 引火
    vacation_ysgw_skill2 = "ui/Icon1806.png",   -- 加热
    vacation_ysgw_skill3 = "ui/Icon1814.png",   -- 炙烤
    vacation_ysgw_skill4 = "ui/Icon1804.png",   -- 滴水
    vacation_ysgw_skill5 = "ui/Icon1802.png",   -- 倒水
    vacation_ysgw_skill6 = "ui/Icon1808.png",   -- 喷水
    vacation_ysgw_skill7 = "ui/Icon1810.png",   -- 休息

    jigsaw_puzzle_corner     = "ui/Icon1797.png", -- 拼图角背景
    jigsaw_puzzle_raw_line   = "ui/Icon1798.png", -- 拼图横边背景
    jigsaw_puzzle_col_line   = "ui/Icon1799.png", -- 拼图竖边背景

    sncg_speed_circle    = "ui/Icon1844.png",   -- 谁能吃瓜加速图标光圈

    -- 纪念册默认封面
    defaut_wedddingbook_cover = "ui/Icon1756.png",   -- 纪念册默认封面

    lchj_guli       = "ui/Icon1759.png",    -- 灵宠幻境-孤离境
    lchj_goulian    = "ui/Icon1764.png",    -- 灵宠幻境-钩镰境
    lchj_qixi       = "ui/Icon1758.png",    -- 灵宠幻境-奇袭境
    lchj_daoxin     = "ui/Icon1760.png",    -- 灵宠幻境-道心境
    lchj_wuxing     = "ui/Icon1762.png",    -- 灵宠幻境-五行境
    lchj_shengsi    = "ui/Icon1757.png",    -- 灵宠幻境-生死境
    lchj_qimen      = "ui/Icon1765.png",    -- 灵宠幻境-奇门境
    lchj_wuyou      = "ui/Icon1763.png",    -- 灵宠幻境-无忧境
    lchj_xuanreng   = "ui/Icon1761.png",    -- 灵宠幻境-悬刃境
    lchj_guli_icon       = "ui/Icon1768.png",    -- 灵宠幻境-孤离境
    lchj_goulian_icon    = "ui/Icon1767.png",    -- 灵宠幻境-钩镰境
    lchj_qixi_icon       = "ui/Icon1770.png",    -- 灵宠幻境-奇袭境
    lchj_daoxin_icon     = "ui/Icon1766.png",    -- 灵宠幻境-道心境
    lchj_wuxing_icon     = "ui/Icon1773.png",    -- 灵宠幻境-五行境
    lchj_shengsi_icon    = "ui/Icon1771.png",    -- 灵宠幻境-生死境
    lchj_qimen_icon      = "ui/Icon1769.png",    -- 灵宠幻境-奇门境
    lchj_wuyou_icon      = "ui/Icon1772.png",    -- 灵宠幻境-无忧境
    lchj_xuanreng_icon   = "ui/Icon1774.png",    -- 灵宠幻境-悬刃境

    -- 任务
    task_finish        = "ui/Icon0203.png",     -- 任务达成
    task_unfinish      = "ui/Icon0538.png",     -- 任务未达成
    inn_gather_bubber    = "ui/Icon1854.png",    -- 客栈-采集气泡
    inn_coin_magic       = "ui/Icon1855.png",    -- 客栈-用来做动画的金币图片
    inn_bar_bg           = "ui/ProgressBar0083.png",    -- 客栈-采集进度条背景
    inn_bar_content      = "ui/ProgressBar0082.png",    -- 客栈-采集进度条内容
    npc_image_tag        = "ui/Icon1834.png",    -- npc头像标记

    party_job_word_bangzhu        = "ui/Icon1887.png",   -- 帮主
    party_job_word_fubangzhu      = "ui/Icon1888.png",   -- 副帮主
    party_job_word_zhanglao_xw    = "ui/Icon1891.png",   -- 玄武长老
    party_job_word_zhanglao_ql    = "ui/Icon1890.png",   -- 青龙长老
    party_job_word_zhanglao_bh    = "ui/Icon1889.png",   -- 白虎长老
    party_job_word_zhanglao_zq    = "ui/Icon1892.png",   -- 朱雀长老
    party_job_word_zhanglao_cl    = "ui/Icon1894.png",   -- 苍兰护法
    party_job_word_hufa_yl        = "ui/Icon1903.png",   -- 远雷护法
    party_job_word_hufa_jf        = "ui/Icon1897.png",   -- 尖峰护法
    party_job_word_hufa_yf        = "ui/Icon1902.png",   -- 夜伏护法
    party_job_word_hufa_yh        = "ui/Icon1904.png",   -- 云海护法
    party_job_word_tangzhu_dx     = "ui/Icon1895.png",   -- 德馨堂主
    party_job_word_tangzhu_sx     = "ui/Icon1899.png",   -- 素侠堂主
    party_job_word_tangzhu_al     = "ui/Icon1893.png",   -- 暗龙堂主
    party_job_word_tangzhu_hw     = "ui/Icon1896.png",   -- 虎威堂主
    party_job_word_tangzhu_zy     = "ui/Icon1905.png",   -- 紫云堂主
    party_job_word_tangzhu_tx     = "ui/Icon1900.png",   -- 听雪堂主
    party_job_word_tangzhu_mx     = "ui/Icon1898.png",   -- 梦溪堂主
    party_job_word_tangzhu_xf     = "ui/Icon1901.png",   -- 玄风堂主

    inn_food_bubber_one         = "ui/Icon1861.png",    -- 客栈菜肴气泡图片1
    inn_food_bubber_two         = "ui/Icon1862.png",    -- 客栈菜肴气泡图片2
    inn_food_bubber_three       = "ui/Icon1863.png",    -- 客栈菜肴气泡图片3
    inn_food_bubber_four        = "ui/Icon1864.png",    -- 客栈菜肴气泡图片4
    inn_food_bubber_five        = "ui/Icon1865.png",    -- 客栈菜肴气泡图片5
    inn_room_bubber_one         = "ui/Icon1879.png",    -- 客栈房间气泡图片1
    inn_room_bubber_two         = "ui/Icon1880.png",    -- 客栈房间气泡图片2
    inn_room_bubber_three       = "ui/Icon1881.png",    -- 客栈房间气泡图片3

    inn_manual_task1            = "ui/Icon1964.png",    --初次迎客
    inn_manual_task2            = "ui/Icon1965.png",    --初次招待
    inn_manual_task3            = "ui/Icon1966.png",    --扩展候客区
    inn_manual_task4            = "ui/Icon1966.png",    --宽阔的候客区
    inn_manual_task5            = "ui/Icon1967.png",    --购买桌椅
    inn_manual_task6            = "ui/Icon1968.png",    --扩展房间
    inn_manual_task7            = "ui/Icon1965.png",    --门庭若市
    inn_manual_task8            = "ui/Icon1969.png",    --升级桌椅

    watch_image                 = "ui/Icon2616.png",    -- 手表标记

    -- 世界杯国家
    footBall                        = "ui/Icon1952.png",
    sjb_sup_card                        = "ui/Icon1956.png",
    [CHS[4300377]]                       = "ui/Icona1.png",    -- 俄罗斯
    [CHS[4300378]]                       = "ui/Icona2.png",  -- 沙特阿拉伯
    [CHS[4300379]]                       = "ui/Icona3.png",     -- 埃及
    [CHS[4300380]]                  = "ui/Icona4.png",    -- 乌拉圭

    [CHS[4300381]]                = "ui/Iconb1.png",    -- 葡萄牙
    [CHS[4300382]]                  = "ui/Iconb2.png",  -- 西班牙
    [CHS[4300383]]                  = "ui/Iconb3.png",     -- 摩洛哥
    [CHS[4300384]]                 = "ui/Iconb4.png",    -- 伊朗

    [CHS[4300385]]                 = "ui/Iconc1.png",    -- 法国
    [CHS[4300386]]                   = "ui/Iconc2.png",  -- 澳大利亚
    [CHS[4300387]]                 = "ui/Iconc3.png",     -- 秘鲁
    [CHS[4300388]]                 = "ui/Iconc4.png",    -- 丹麦

    [CHS[4300389]]                  = "ui/Icond1.png",    -- 阿根廷
    [CHS[4300390]]                 = "ui/Icond2.png",  -- 冰岛
    [CHS[4300391]]                   = "ui/Icond3.png",     -- 克罗地亚
    [CHS[4300392]]                 = "ui/Icond4.png",    -- 尼日利亚

    [CHS[4300393]]                 = "ui/Icone1.png",    -- 巴西
    [CHS[4300394]]                 = "ui/Icone2.png",  -- 瑞士
    [CHS[4300395]]                    = "ui/Icone3.png",     -- 哥斯达黎加
    [CHS[4300396]]                   = "ui/Icone4.png",    -- 塞尔维亚

    [CHS[4300397]]                 = "ui/Iconf1.png",    -- 德国
    [CHS[4300398]]                  = "ui/Iconf2.png",  -- 墨西哥
    [CHS[4300399]]                 = "ui/Iconf3.png",     -- 瑞典
    [CHS[4300400]]                 = "ui/Iconf4.png",    -- 韩国

    [CHS[4300401]]                = "ui/Icong1.png",    -- 比利时
    [CHS[4300402]]                  = "ui/Icong2.png",  -- 巴拿马
    [CHS[4300403]]                  = "ui/Icong3.png",     -- 突尼斯
    [CHS[4300404]]                  = "ui/Icong4.png",    -- 英格兰

    [CHS[4300405]]               = "ui/Iconh1.png",    -- 波兰
    [CHS[4300406]]                   = "ui/Iconh2.png",  -- 塞内加尔
    [CHS[4300407]]                   = "ui/Iconh3.png",     -- 哥伦比亚
    [CHS[4300408]]                 = "ui/Iconh4.png",    -- 日本

-- 国旗称谓图标 Char:addQiuMiIcon(root, teamName) 中调用
    [CHS[4300377] .. "title"]       = "ui/Icona101.png",    -- 俄罗斯
    [CHS[4300378] .. "title"]       = "ui/Icona201.png",  -- 沙特阿拉伯
    [CHS[4300379] .. "title"]       = "ui/Icona301.png",     -- 埃及
    [CHS[4300380] .. "title"]       = "ui/Icona401.png",    -- 乌拉圭

    [CHS[4300381] .. "title"]       = "ui/Iconb101.png",    -- 葡萄牙
    [CHS[4300382] .. "title"]       = "ui/Iconb201.png",  -- 西班牙
    [CHS[4300383] .. "title"]       = "ui/Iconb301.png",     -- 摩洛哥
    [CHS[4300384] .. "title"]       = "ui/Iconb401.png",    -- 伊朗

    [CHS[4300385] .. "title"]       = "ui/Iconc101.png",    -- 法国
    [CHS[4300386] .. "title"]       = "ui/Iconc201.png",  -- 澳大利亚
    [CHS[4300387] .. "title"]       = "ui/Iconc301.png",     -- 秘鲁
    [CHS[4300388] .. "title"]       = "ui/Iconc401.png",    -- 丹麦

    [CHS[4300389] .. "title"]       = "ui/Icond101.png",    -- 阿根廷
    [CHS[4300390] .. "title"]       = "ui/Icond201.png",  -- 冰岛
    [CHS[4300391] .. "title"]       = "ui/Icond301.png",     -- 克罗地亚
    [CHS[4300392] .. "title"]       = "ui/Icond401.png",    -- 尼日利亚

    [CHS[4300393] .. "title"]       = "ui/Icone101.png",    -- 巴西
    [CHS[4300394] .. "title"]       = "ui/Icone201.png",  -- 瑞士
    [CHS[4300395] .. "title"]       = "ui/Icone301.png",     -- 哥斯达黎加
    [CHS[4300396] .. "title"]       = "ui/Icone401.png",    -- 塞尔维亚

    [CHS[4300397] .. "title"]       = "ui/Iconf101.png",    -- 德国
    [CHS[4300398] .. "title"]       = "ui/Iconf201.png",  -- 墨西哥
    [CHS[4300399] .. "title"]       = "ui/Iconf301.png",     -- 瑞典
    [CHS[4300400] .. "title"]       = "ui/Iconf401.png",    -- 韩国

    [CHS[4300401] .. "title"]       = "ui/Icong101.png",    -- 比利时
    [CHS[4300402] .. "title"]       = "ui/Icong201.png",  -- 巴拿马
    [CHS[4300403] .. "title"]       = "ui/Icong301.png",     -- 突尼斯
    [CHS[4300404] .. "title"]       = "ui/Icong401.png",    -- 英格兰

    [CHS[4300405] .. "title"]       = "ui/Iconh101.png",    -- 波兰
    [CHS[4300406] .. "title"]       = "ui/Iconh201.png",  -- 塞内加尔
    [CHS[4300407] .. "title"]       = "ui/Iconh301.png",     -- 哥伦比亚
    [CHS[4300408] .. "title"]       = "ui/Iconh401.png",    -- 日本

    tanan_jhll_yang_line        = "ui/Icon1411.png",    -- 【探案】江湖绿林 阳线
    tanan_jhll_yin_line         = "ui/Icon1412.png",    -- 【探案】江湖绿林 阴线
    tanan_jhll_dossier_title    = "ui/Icon1963.png",    -- 【探案】江湖绿林 卷轴标题
    tanan_tw_dossier_title    = "ui/Icon2008.png",    -- 【探案】天外之谜 卷轴标题
    tanan_mxza_dossier_title    = "ui/Icon2009.png",    -- 【探案】迷仙镇案 卷轴标题

    case_jia_word               = "ui/Icon1911.png",  -- 甲
    case_yi_word                = "ui/Icon1912.png",  -- 乙
    case_bing_word              = "ui/Icon1913.png",  -- 丙
    case_ding_word              = "ui/Icon1914.png",  -- 丁
    case_wu_word                = "ui/Icon1915.png",  -- 戊
    case_ji_word                = "ui/Icon1916.png",  -- 己
    case_geng_word              = "ui/Icon1917.png",  -- 庚
    case_xin_word               = "ui/Icon1918.png",  -- 辛
    case_ren_word               = "ui/Icon1919.png",  -- 壬
    case_gui_word               = "ui/Icon1920.png",  -- 癸

    case_box_img1               = "ui/Icon1921.png",
    case_box_img2               = "ui/Icon1924.png",
    case_box_img3               = "ui/Icon1922.png",
    case_box_img4               = "ui/Icon1923.png",

    case_scratch                = "ui/Icon1972.png",

    qmpk_title_txwd             = "ui/Icon2093.png",
    qmpk_title_bsgs             = "ui/Icon2094.png",
    qmpk_title_wfmd             = "ui/Icon2095.png",
    qmpk_title_yrdq             = "ui/Icon2096.png",
    qmpk_title_dxst             = "ui/Icon2097.png",
    qmpk_title_fhxl             = "ui/Icon2098.png",
    qmpk_title_rzzl             = "ui/Icon2099.png",
    qmpk_title_rhzs             = "ui/Icon2100.png",
    qmpk_title_yxhj             = "ui/Icon2101.png",

    qmpk_taotai_128             = "ui/Icon2087.png",
    qmpk_taotai_64              = "ui/Icon2088.png",
    qmpk_taotai_32              = "ui/Icon2089.png",
    qmpk_taotai_16              = "ui/Icon2090.png",
    qmpk_taotai_8               = "ui/Icon2091.png",
    qmpk_taotai_4               = "ui/Icon2092.png",
    qmpk_taotai_3               = "ui/Icon2106.png",
    qmpk_taotai_2               = "ui/Icon2107.png",
    qmpk_taotai_1               = "ui/Icon2110.png",
    qmpk_taotai_0               = "ui/Icon2111.png",

    qmpk_metal_male          = "ui/Icon2074.png",
    qmpk_wood_male           = "ui/Icon2080.png",
    qmpk_water_male          = "ui/Icon2081.png",
    qmpk_fire_male           = "ui/Icon2077.png",
    qmpk_earth_male          = "ui/Icon2078.png",
    qmpk_metal_female        = "ui/Icon2079.png",
    qmpk_wood_female         = "ui/Icon2075.png",
    qmpk_water_female        = "ui/Icon2076.png",
    qmpk_fire_female         = "ui/Icon2082.png",
    qmpk_earth_female        = "ui/Icon2083.png",

    -- 四方棋局中，举起棋子的资源
    sfqj_white_chess            = "ui/Icon1975.png",
    sfqj_black_chess            = "ui/Icon1977.png",

    -- 四方棋局中，自己颜色表示
    sfqj_white_flag            = "ui/Icon1980.png",
    sfqj_black_flag            = "ui/Icon1979.png",

    mxz_door_card              = "ui/Icon7016.png", -- 迷仙镇门牌
    dww_food_one               = "ui/Icon2030.png", -- 2018中秋大胃王桌子上的食物
    dww_food_two               = "ui/Icon2031.png", -- 2018中秋大胃王桌子上的食物

    -- 探案任务 DossierDlg 界面标题资源
    tanan_bjfy                 = "ui/Icon2071.png", -- 镖局风雨

    -- 灵音镇魔
    lingyzm_click_tip         = "ui/Icon2065.png",
    lingyzm_talk_tip           = "ui/Icon2064.png",
    lingyzm_choose_tip          = "ui/Icon2173.png",

    -- 畅饮菊酒
    changyjj_yellow_block    = "ui/Icon2039.png",
    changyjj_red_block       = "ui/Icon2145.png",
    changyjj_green_circle    = "ui/Icon2038.png",
    changyjj_gray_circle     = "ui/Icon2146.png",

    atlasLabel0001           = "ui/AtlasLabel0001.png",
    atlasLabel0001_add       = "ui/Icon2150.png",

    poker_1                  = "ui/Icon2151.png",
    poker_2                  = "ui/Icon2152.png",
    poker_3                  = "ui/Icon2153.png",
    poker_4                  = "ui/Icon2154.png",
    poker_5                  = "ui/Icon2155.png",
    poker_6                  = "ui/Icon2156.png",
    poker_7                  = "ui/Icon2157.png",
    poker_8                  = "ui/Icon2158.png",
    poker_9                  = "ui/Icon2159.png",
    poker_10                 = "ui/Icon2160.png",
    poker_back               = "ui/Icon2161.png",

	--  谁是乌龟-纸牌
    wg_poker_1                  = "shuiswg0001.png",
    wg_poker_2                  = "shuiswg0002.png",
    wg_poker_3                  = "shuiswg0003.png",
    wg_poker_4                  = "shuiswg0004.png",
    wg_poker_5                  = "shuiswg0005.png",
    wg_poker_6                  = "shuiswg0006.png",
    wg_poker_7                  = "shuiswg0007.png",
    wg_poker_8                  = "shuiswg0008.png",
    wg_poker_back               = "shuiswg0009.png",


    fight_obj_down_arrow       = "ui/Icon2142.png", -- 战斗中obj头顶向下箭头

    spouse_action_qinqin       = "ui/Icon2141.png",
    spouse_action_baobao       = "ui/Icon2139.png",
    spouse_action_jiaobei      = "ui/Icon2140.png",

    fabao_gongtong_flag        = "ui/Icon2168.png",

    head_title_back            = "ui/Icon2183.png",

    VacationWhiteDlgClick      = "ui/Icon2200.png",

    iqiyi_season_member      = "ui/Icon2237.png",   -- 爱奇艺VIP会员季卡
    hc_title                 = "ui/Icon2238.png",   -- 《悍城》专属称谓
    hc_share_pic             = "noencrypt/sharePic2.jpg",  -- 《悍城》分享图片

    welfare_recharge_gift         = "ui/Icon0332.png",
    welfare_recharge_score        = "ui/Icon0333.png",
    welfare_consume_score         = "ui/Icon0334.png",
    welfare_first_recharge        = "ui/Icon0335.png",
    welfare_first_recharge_month  = "ui/Icon0336.png",

    lineup_vip_word1              = "ui/Icon2234.png",  -- 月卡
    lineup_vip_word2              = "ui/Icon2235.png",  -- 季卡
    lineup_vip_word3              = "ui/Icon2236.png",  -- 年卡

    fixed_team_level0             = "ui/Icon2290.png",
    fixed_team_level1             = "ui/Icon2291.png",
    fixed_team_level2             = "ui/Icon2292.png",
    fixed_team_level3             = "ui/Icon2293.png",
    fixed_team_level4             = "ui/Icon2294.png",
    fixed_team_level5             = "ui/Icon2295.png",

    fixed_team_pt_type_liliang    = "ui/Icon2287.png",
    fixed_team_pt_type_lingli     = "ui/Icon2285.png",
    fixed_team_pt_type_tizhi      = "ui/Icon2286.png",
    fixed_team_pt_type_minjie     = "ui/Icon2284.png",

    normal_panel_back      = "ui/Button0180.png",
    green_panel_back      = "ui/Button0335.png",

    wait_back                     = "Background047.png", -- 等待转圈的背景图片

    -- 月道行跨服试道文字提示
    month_tao_kuafsd_tip1         = "ui/Icon2204.png",
    month_tao_kuafsd_tip2         = "ui/Icon2205.png",

    kuafsd_title                  = "ui/Icon2365.png",
    month_tao_kuafsd_title        = "ui/Icon2367.png",

    -- 月道行试道文字提示
    month_tao_sd_tip1             = "ui/Icon2201.png",
    month_tao_sd_tip2             = "ui/Icon2202.png",
    month_tao_sd_tip3             = "ui/Icon2203.png",

    -- 新春寻宝
    xunbao_rock_nomal             = "ui/Icon2263.png",  -- 普通岩石
    xunbao_rock_gold2             = "ui/Icon2264.png",  -- 耐久度为 2 的黄金岩石
    xunbao_rock_gold1             = "ui/Icon2265.png",  -- 耐久度为 1 的黄金岩石
    xunbao_rock_special           = "ui/Icon2266.png",  -- 特殊岩石
    xunbao_rock_hide              = "ui/Icon2267.png",  -- 隐藏状态的岩石
    xunbao_rock_nomal_has_item    = "ui/Icon2311.png",  -- 含有道具的普通岩石
    xunbao_rock_gold2_has_item    = "ui/Icon2312.png",  -- 含有道具的耐久度为 2 的黄金岩石
    xunbao_rock_gold1_has_item    = "ui/Icon2313.png",  -- 含有道具的耐久度为 1 的黄金岩石
    xunbao_rock_shadow_nomal      = "ui/Icon2315.png",  -- 含有道具的普通岩石的阴影
    xunbao_rock_shadow_gold       = "ui/Icon2314.png",  -- 含有道具的黄金岩石的阴影

    select_red_rect               = "ui/Icon2278.png",  -- 红色选择方块图片
    select_green_rect             = "ui/Icon2258.png",  -- 绿色选择方块图片

    button_remove                 = "ui/Icon0995.png",
    button_return                 = "ui/Icon2299.png",

    -- 神秘地宫
    smdg_part_black_img1          = "ui/Icon2306.png",
    smdg_part_black_img2          = "ui/Icon2307.png",
    smdg_part_black_img3          = "ui/Icon2304.png",
    smdg_part_black_img4          = "ui/Icon2305.png",
    smdg_part_black_img5          = "ui/Icon2310.png",
    smdg_all_black_img            = "ui/Icon2308.png",
    smdg_back_img                 = "ui/Icon2301.png",
    smdg_one_wall_img             = "ui/Icon2303.png",
    smdg_two_wall_img             = "ui/Icon2309.png",

    child_day_feed_pet            = "ui/Icon2326.png", -- 儿童节喂养宠物图标
    child_day_throw_stone         = "ui/Icon2327.png", -- 儿童节扔石子图标

    -- 秘境探险界面相关
    cwtx_weapon                   = "ui/Icon2319.png",      -- 武器
    cwtx_juanzhou                 = "ui/Icon2328.png",      -- 卷轴
    cwtx_food                     = "ui/Icon2320.png",      -- 食物
    cwtx_channel                  = "ui/Icon2321.png",      -- 通道
    cwtx_none1                    = "ui/Icon2323.png",      -- 无1
    cwtx_none2                    = "ui/Icon2324.png",      -- 无2
    cwtx_blank0                    = "ui/Icon2322.png",      -- 砖块1
    cwtx_blank1                    = "ui/Icon2355.png",      -- 砖块2
    cwtx_blank2                    = "ui/Icon2356.png",      -- 砖块3
    cwtx_monster1                    = "ui/Icon2350.png",      -- 无2
    cwtx_monster2                    = "ui/Icon2351.png",      -- 砖块1
    cwtx_monster3                    = "ui/Icon2352.png",      -- 砖块2
    cwtx_monster4                    = "ui/Icon2353.png",      -- 砖块3
    cwtx_monster_wu                 = "ui/Icon2349.png",
    cwtx_monster_sh                 = "ui/Icon2348.png",
    cwtx_jshj                 = "ui/Icon2369.png",           -- 绝世好剑
    cwtx_xd                 = "ui/Icon2370.png",           -- 仙丹
    cwtx_zsb                 = "ui/Icon2371.png",           -- 指示牌
    cwtx_jt                 = "ui/Icon2415.png",           -- 仙丹


    mcfp_back_iamge                 = "ui/Icon2362.png",

    -- 固定队特权图标
    team_fixed_func1              = "ui/Icon2330.png",
    team_fixed_func2              = "ui/Icon2331.png",
    team_fixed_func3              = "ui/Icon2332.png",
    team_fixed_func4              = "ui/Icon2333.png",
    team_fixed_func5              = "ui/Icon2334.png",
    team_fixed_func6              = "ui/Icon2335.png",
    team_fixed_func7              = "ui/Icon2336.png",
    team_fixed_func8              = "ui/Icon2702.png",

    fight_command_tag_bg          = "ui/Icon2364.png", -- 战斗指挥标记背景

    zhenfa_non_polar              = "ui/Icon2374.png",  -- 无相性阵法图标
    recharge_bar_bk               = "ui/Frame0252.png",         -- 回归充值进度背景图
    recharge_bar_progress         = "ui/ProgressBar0084.png",   -- 回归充值进度图

    start_icon                    = "ui/Icon0912.png",  -- 开始
    end_icon                      = "ui/Icon2375.png",  -- 结束


    bkImage0249        = 'ui/Frame0249.png',
    bkImage0250        = 'ui/Frame0250.png',

    reserver_charge_share_official     = "noencrypt/sharePic5.jpg", -- 新服预约活动分享官方图片
    reserver_charge_share_unOfficial   = "noencrypt/sharePic6.jpg", -- 新服预约活动分享渠道图片
    finish_target                 = "ui/Icon2523.png", -- 达成目标图片


    big_right_arrow     = 'ui/Button0195.png', -- 大的右箭头
    small_right_arrow   = 'ui/Button0182.png', -- 小的右箭头


    wenquan_record_att_word = 'ui/Icon2396.png', -- 温泉互动主动文字
    wenquan_record_def_word = 'ui/Icon2397.png', -- 温泉互动被动文字


    select_arrows           = "ui/Icon0171.png",

    -- 小舟竞赛
    xiaozjs_riverway_start  = "ui/Background0250.png",
    xiaozjs_riverway_mid    = "ui/Background0251.png",
    xiaozjs_riverway_end    = "ui/Background0252.png",
    xiaozjs_riverway_line   = "ui/Icon2420.png",   -- 起跑、终止线

    xiaozjs_dir_flag_def        = "ui/Icon2417.png",
    xiaozjs_dir_flag_right      = "ui/Icon2419.png",
    xiaozjs_dir_flag_err        = "ui/Icon2418.png",

    sxdj_egg                = "ui/Icon2430.png",    -- 生效对决的蛋
    sxdj_zd                 = "ui/Icon2262.png",    -- 生肖对决 炸弹
    sxdj_hyjj                 = "ui/Icon2431.png",    -- 生肖对决 炸弹
    sxdj_grid_white         = "ui/Icon2432.png",
    sxdj_grid_black         = "ui/Icon2433.png",


    pet_explore_skill_caiji         = "ui/Icon2469.png", -- 宠物探险小队 技能 采集
    pet_explore_skill_zhandou       = "ui/Icon2473.png", -- 宠物探险小队 技能 战斗
    pet_explore_skill_sousuo        = "ui/Icon2471.png", -- 宠物探险小队 技能 搜索
    pet_explore_skill_chuidiao      = "ui/Icon2470.png", -- 宠物探险小队 技能 垂钓
    pet_explore_skill_wajue         = "ui/Icon2472.png", -- 宠物探险小队 技能 挖掘

    pet_explore_materail_caiji      = "ui/Icon2474.png", -- 宠物探险小队 材料 采集
    pet_explore_materail_zhandou    = "ui/Icon2478.png", -- 宠物探险小队 材料 战斗
    pet_explore_materail_sousuo     = "ui/Icon2476.png", -- 宠物探险小队 材料 搜索
    pet_explore_materail_chuidiao   = "ui/Icon2475.png", -- 宠物探险小队 材料 垂钓
    pet_explore_materail_wajue      = "ui/Icon2477.png", -- 宠物探险小队 材料 挖掘

    ChildBirthDlgGreen              = "ui/Icon2500.png", -- 绿色
    ChildBirthDlgYellow             = "ui/Icon2499.png", -- 黄色
    ChildBirthDlgBrown              = "ui/Icon2498.png", -- 棕色
    ChildBirthDlgRed                = "ui/Icon2497.png", -- 红色

    dashui_image                    = "ui/Icon2506.png",    -- 娃娃界面打水

    fatigue_image                   = "ui/Icon2515.png",    -- 疲劳度
    satiation_image                 = "ui/Icon2513.png",    -- ，饱食度
    mood_image                      = "ui/Icon2514.png",    -- 心情度
 --   cleanliness                     = "ui/Icon2514.png",    -- 心情度
    lmqg_gz                         = "ui/Icon2595.png",    -- 浪漫巧果盖子
    auto_fight_kid_text             = "ui/Icon2607.png",    -- 自动战斗娃娃文字
    auto_fight_pet_text             = "SkillText0019.png",  -- 自动战斗宠物文字
    kid_logo_image                  = "ui/Icon2604.png",    -- 宠物标志图片
    kid_bozhong_image                 = "ui/Icon2635.png",    -- 娃娃播种图片
    kid_shouhuo_image                 = "ui/Icon2636.png",    -- 娃娃收获图片
    kid_diaoyu_image                  = "ui/Icon2637.png",    -- 娃娃钓鱼图片
    jt_sun                          = "ui/Icon2711.png", -- 骄阳
    jt_moon                         = "ui/Icon2712.png", -- 骄阳
    jt_mixed                        = "ui/Icon2710.png", -- 混合

}

ResMgr.loadingPic = {
    qipao       = "loading_pic/qibao.jpg",
    tianyong    = "loading_pic/tianyong.jpg",
    createchar = "loading_pic/createchar.jpg",
}

-- 圆的角色头像
local ICON_TO_CIRCLE_PORTRAIT =
{
    [6001] = ResMgr.ui.char_protrait_circle6001,
    [6002] = ResMgr.ui.char_protrait_circle6002,
    [6003] = ResMgr.ui.char_protrait_circle6003,
    [6004] = ResMgr.ui.char_protrait_circle6004,
    [6005] = ResMgr.ui.char_protrait_circle6005,
    [7001] = ResMgr.ui.char_protrait_circle7001,
    [7002] = ResMgr.ui.char_protrait_circle7002,
    [7003] = ResMgr.ui.char_protrait_circle7003,
    [7004] = ResMgr.ui.char_protrait_circle7004,
    [7005] = ResMgr.ui.char_protrait_circle7005,
}

-- 结婚纪念日图章
ResMgr.wbIcon = {
    ["1"] = "ui/Icon1747.png",
    ["2"] = "ui/Icon1748.png",
    ["3"] = "ui/Icon1749.png",
}

-- 光效信息(请按字母顺序排列，以方便查看 key 是否重复)
ResMgr.magic = {
    confusion           = 4009,     -- 混乱
    corps               = 7025,     -- 团长
    deadly_kiss         = 6020,     -- 死亡缠绵
    def_up              = 4006,     -- 防御上升
    dodge_up            = 4010,     -- 躲闪上升
    exchanging          = 6001,     -- 正在交易中
    fighting            = 1005,     -- 战斗中
    forgotten           = 4001,     -- 遗忘
    frozen              = 4005,     -- 冰冻
    first_login_charge  = 1063,     -- 当天首次登入首充光效
    first_login_during_znq  = 1130,     -- 周年庆期间第一次登录游戏
    immune_mag_damage   = 6006,     -- 免疫魔法攻击(如意圈)
    immune_phy_damage   = 6017,     -- 免疫物理攻击(神龙罩)
    jiangyaoshu         = 6009,     -- 使用惊妖术
    jiangyaoling        = 6074,     -- 使用惊铃
    leader              = 1011,     -- 队长
    leader_team_full    = 1023,     -- 队长（队员满了）
    level_up            = 2001,     -- 升级
    look_on             = 7026,     -- 观战中
    parry_effect        = 1256,     -- 格挡/防御时在腰部显示的光效
    phy_power_up        = 4002,     -- 物理伤害上升（己方光效）
    phy_power_up_ex     = 4011,     -- 物理伤害上升（敌方光效）
    passive_attack      = 6015,     -- 反弹物理攻击(乾坤罩)
    poison              = 4003,     -- 中毒
    polar_changed       = 6073,     -- 五行改变
    recover_life        = 4004,     -- 气血上升(持续加血)
    sleep               = 4007,     -- 昏睡
    speed_up            = 4008,     -- 速度上升
    stunt               = 2002,     -- 必杀
    auto_walk           = 8145,     -- 自动寻路
    auto_walk_end       = 8146,     -- 自动寻路结束
    tj_lie_yan          = 3018,     -- 天书技能---烈炎
    tj_jing_lei         = 3019,     -- 天书技能---惊雷
    tj_qing_mu          = 3020,     -- 天书技能---青木
    tj_sui_shi          = 3024,     -- 天书技能---碎石
    tj_han_bing         = 3021,     -- 天书技能---寒冰
    walk_pos_effect     = 06022,    -- 点击地图特效

    fanzhuan_qiankun    = 6073,     -- 翻转乾坤
    loyalty             = 6011,     -- 游说之舌
    mana_shield         = 1071,     -- 法力护盾
    add_life_by_mana    = 8106,     -- 移花接木
    five_color          = 8107,     -- 五色光环
    ready_to_fight      = 1052,     -- 战斗界面输入完成提示，暂时用表情 12的资源代替，替换时需要确认对应的表情动画是否要替换
    focus_target        = 01061,    -- 选中光效
    gather_magic        = 01065,    -- 采集光效
    blue_equip_effect   = 01026,    -- 蓝装特效
    pink_equip_effect   = 01027,    -- 粉装特效
    yellow_equip_effect = 01028,    -- 黄装特效
    green_equip_effect  = 01029,    -- 绿装特效
    suit_equip_effect   = 01030,    -- 套装特效
    sys_lock            = 01059,    -- 锁屏时候的光效
    master_select       = 07003,    -- 师徒任务选中光效

    huanbing_zhiji      = 08376,    -- 缓兵之计
    shushou_jiuqin      = 08378,    -- 束手就擒
    wenfeng_sangdan     = 08380,    -- 闻风丧胆
    aitong_yujue        = 08382,    -- 哀痛欲绝
    yangjing_xurui      = 08384,    -- 养精蓄锐
    jingangquan         = 08247,    -- 金刚圈
    chaofeng            = 01081,    -- 嘲讽
    zaohua              = 01075,    -- 造化之池

    lianqi              = 01176,    -- 法宝修炼光效，炼器台
    shanggu_lianqi      = 1177,    -- 法宝修炼光效，炼器台

    npw_break_flag      = 1198,     -- 新帮战破坏战旗
    npw_occupy_flag     = 1197,     -- 新帮战占领战旗
    npw_in_gather     = 1196,     -- 新帮战采集
    rabbit_dizziness    = 01147,   -- 接月饼兔子眩晕
    smash_to_pieces     = 01146,   -- 月饼摔碎
    get_mooncake        = 01151,   -- 接取月饼光效
    rabbit_boot_walk    = 01149,   -- 兔子奔跑脚底光效
    mooncake_surround    = 01213,   -- 月饼环绕光效

	main_fish = 1214,     -- 主界面钓鱼
	fish_wave_water1     = 01191,    -- 钓鱼水波光效1 （对应浮漂5个动作）
    fish_wave_water2     = 01192,    -- 钓鱼水波光效2
    fish_wave_water3     = 01193,    -- 钓鱼水波光效3
    fish_wave_water4     = 01194,    -- 钓鱼水波光效4
    fish_wave_water5     = 01195,    -- 钓鱼水波光效5

    plant_seed           = 01165,    -- 播种
    plant_water          = 01166,    -- 浇水
    plant_kill_insect    = 01167,    -- 除虫
    plant_weeding        = 01168,    -- 除草
    plant_harvest        = 01169,    -- 收获
    plant_has_insect     = 01170,    -- 生虫

    blog_btn             = 01257,    -- 个人空间按钮环绕光效
    upgrade_immortal     = 08043,    -- 飞仙人物身上环绕光效
    upgrade_magic        = 08045,    -- 飞魔人物身上环绕光效

    xian_skill_left      = 1116,    -- 仙魔技能光效，左边，战斗对象站在地方位置
    xian_skill_right      = 1117,    -- 仙魔技能光效，右，战斗对象站在地方位置

    volume                = 01035,   -- 语音音量光效

	zhaofu_tree_shuxin    = 01129,   -- 招福宝树树心光效
	zhaofu_tree_worm      = 01127,   -- 招福宝树虫子光效

	lianqi_magic          = 1178,    -- 炼器台光效
	shanggu_lianqi_magic  = 1179,    -- 上古炼器台光效

	guide_magic           = 01037, -- 指引光效

	down_arrow_magic      = 01034, -- 获取向下箭头

	dunshu_start          = 1160,  -- 遁术开始光效
	dunshu_end            = 1161,  -- 遁术结束光效

	-- 满屏花瓣光效
	full_screen_flower1   = 01067,
	full_screen_flower2   = 01068,
	full_screen_flower3   = 01069,

    wenq_full_screen_flower1   = 01471,
    wenq_full_screen_flower2   = 01473,
    wenq_full_screen_flower3   = 01474,

	-- 气泡破碎效果
	poke_bubble_effect1 = 1137,   -- 蓝
    poke_bubble_effect2 = 1136,   -- 紫
    poke_bubble_effect3 = 1135,   -- 黄

    -- 宠物饲养光效
    pet_feed_get_tao    = 01159,
	pet_feed_get_exp    = 01158,

	-- 过图点
	exit_house_qianting   = 1156,
	exit_house_houyuan    = 1155,
	exit_default          = 1021,

	status_qisha_yin = 08402,   -- 七杀-阴
	status_qisha_yang = 08404,  -- 七杀-阳

    status_weiya = 1329,   -- 威压
    status_diliebo_flag = 01331,    -- 地列表标记

    status_daofa_wubian = 01343, -- 道法无边

	star_shadow_effect = 01261, -- 星影特效
    world_chat_under_arrow = 01258, -- 世界聊天界面下拉箭头指引环绕光效

    elf = 50201,                -- 跟随小精灵

    anniversary_card_ab = 01285,    -- 周年庆翻牌AB特效
    anniversary_card_bc = 01286,    -- 周年庆翻牌BC特效
    anniversary_card_ca = 01287,    -- 周年庆翻牌CA特效
    yuhua_btn               = 01309,

    -- 夫妻任务、冻柿子中角色脚底光效
    char_foot_eff1  = 8050,
    char_foot_eff2  = 8051,
    water_skill_B3  = 06042, -- 水系 B3 技能
    wood_skill_B3   = 02016, -- 木系 B3 技能

    run_add_speed_waist = 01123, -- 加速光效

    has_new_att         = 01262, -- 首饰出现新属性
    inn_coin_rotate     = 01312, -- 客栈金币旋转特效

    random_walk         = 01311, -- 随机寻路

    yellow_circle       = 06068, -- 黄色圈圈特效
    red_circle          = 06066, -- 红色圈圈特效
    dww_piaohan         = 01265, -- 2018中秋大胃王飘汗

    tanan_jhll_too_far   = 01322, -- 探案 江湖绿林 松懈特效
    tanan_jhll_too_close = 01321, -- 探案 江湖绿林 警惕特效

    tanan_tw_zhenshifu_burn = 01325, -- 探案 天外之谜 镇尸符燃烧
    love_effect = 07010,    -- 夫妻爱心光效

    circle_purple = 06067,
    circle_golden = 06068,
    head_tip_purple = 01369,
    head_tip_golden = 01370,

    grey_fog        = 06071,  -- 灰雾

    xian            = 08043,
    mo              = 08045,
    yuanying        = 08044,
    xueying         = 08046,

    xunbao_use_shovel     = 01373,
    xunbao_use_bomb    = 01374,
    xunbao_broken_nomal_rock = 01388,
    xunbao_broken_gold_rock = 01376,

    duanwujie2019ZBX = 1391,
    duanwujie2019KillMonstrt = 1390,

    mcpf_open_card      = 01392,

    cwtx_xlzq           = 01404,        -- 仙灵之气
    cwtx_zq           = 01403,          -- 瘴气

    bainian_fuluzhu = 01420, -- 2019拜年福禄猪动画

    swim_pos_effect         = 01410,    -- 点击水面游泳光效
    wenquan_throw_soap      = 01407,    -- 温泉仍肥皂
    wenquan_throw_soap_crash = 01405,    -- 温泉仍肥皂弹出泡沫

    xiaozjs_click_btn       = 01399,    -- 点击指令按钮光效
    xiaozjs_speedup_wave    = 01411,    -- 加速水波
    xiaozjs_def_wave        = 01400,

    bhky_fire_ball          = 01397,    -- 冰火考验-火球
    bhky_ice_ball           = 01398,    -- 冰火考验-冰球
    headDlg_magic       = 01435,    -- 头像界面环绕光效
    userDlg_cbjy        = 01436,    -- 角色信息界面，储备经验环绕光效
    reserve_charge_bar = 01459,         -- 预充值进度条特效
    reserve_charge_get_percent = 01460, -- 预充值到达百分比特效
}

-- 龙骨动画相关
ResMgr.DragonBones = {
    jieyuebing_tuzi     = 1148,   -- 接月饼中的兔子动画
    home_fishing_yugan  = 1199,   -- 居所钓鱼的鱼竿
    fupiao_fudong       = 1200,   -- 钓鱼浮漂上下浮动
    catch_fish          = 1201,   -- 捕获到的鱼
    zhaocaishu          = 1221,   -- 招财树动画
    pw_zhanqi           = 1215,   -- 帮战战旗
	jinsiniaolong       = 10027,  -- 金丝鸟笼
    fuluzhu             = 02042,  -- 2019拜年动画福禄猪

    anniversary_lingmao_type1 = 01273, -- 周年庆灵猫形象第一阶段
    anniversary_lingmao_type2 = 01274, -- 周年庆灵猫形象第二阶段
    anniversary_lingmao_type3 = 06321, -- 周年庆灵猫形象第三阶段

    creatCharBKtree1 = 2033,    -- 创角界面背景树
    creatCharBKtree2 = 2032,    -- 创角界面背景树

    creatCharUptree1 = 2031,    -- 创角界面前景树
    creatCharUptree2 = 2030,    -- 创角界面前景树

    creatCharShape1 = 1223,
    creatCharShape2 = 1224,
    creatCharShape3 = 1225,
    creatCharShape4 = 1226,
    creatCharShape5 = 1227,
    creatCharShape6 = 1228,
    creatCharShape7 = 1229,
    creatCharShape8 = 1230,
    creatCharShape9 = 1231,
    creatCharShape10 = 1232,
}

-- 骨骼动画
ResMgr.ArmatureMagic = {
    main_ui_btn         = {name = "01062", action = "Bottom"},  -- 主界面按钮
    pet_fight_btn       = {name = "01064", action = "Bottom"},  -- 宠物参战按钮
    use_double_point    = {name = "01066", action = "Bottom"},  -- 双倍切换按钮
    system_config_btn    = {name = "01389", action = "Bottom"},  -- 双倍切换按钮
    mall_discount       = {name = "01072", action = "Bottom"},  -- 商场折扣券
    mystery_gift        = {name = "01079", action = "Bottom"},  -- 神秘大礼
    find_master_btn     = {name = "06072", action = "Bottom"},  -- 寻师按钮
    item_around         = {name = "08298", action = "Bottom"},  -- 物品栏环绕
    npc_dlg             = {name = "08299", action = "Bottom"},  -- npc对话框
    main_ui_tast1       = {name = "08303", action = "Bottom"},  -- 主界面任务(一行)
    main_ui_task2       = {name = "08304", action = "Bottom"},  -- 主界面任务(二行)
    quick_use_item      = {name = "01036", action = "Bottom"},  -- 快速使用道具
    safe_lock_btn       = {name = "01114", action = "Bottom"},  -- 安全锁按钮环绕光效
    bobing_prize        = {name = "01242", action = ""},        -- 博饼奖励结果
    market_qianggou     = {name = "01241", action = ""},        -- 集市抢购
    bobing_toutouzi     = {name = "Bobing", action = ""},       -- 博饼中的投骰子动画

    diji_bed_sleep      = {name = "01246", action = ""},       -- 低级床睡觉动画
    zhongji_bed_sleep   = {name = "01247", action = ""},       -- 中级床睡觉动画
    gaoji_bed_sleep     = {name = "01248", action = ""},       -- 高级级床睡觉动画

    chengjiu            = {name = "01240", action = "Top"},    -- 达成成就

    charge_draw_fanpai  = {name = "01218", action = ""},    -- 充值翻牌光效
    charge_draw_fanpai_ten  = {name = "01340", action = ""},    -- 充值翻牌光效 - 十连抽
    luopan_dir_light    = {name = "01267", action = ""},    -- 罗盘寻踪，小罗盘方向光效
    upgrade_immortal_top    = {name = "01252", action = "Top01"},    -- 飞仙top层光效
    upgrade_immortal_bottom = {name = "01252", action = "Bottom01"}, -- 飞仙bottom层光效
    upgrade_magic_top    = {name = "01252", action = "Top02"},    -- 飞魔top层光效
    upgrade_magic_bottom = {name = "01252", action = "Bottom02"}, -- 飞魔bottom层光效

    baiyuguanyinxiang    = {name = "01216", action = ""},
    qibaoruyi	         = {name = "01217", action = ""},

    daxuzhang            = {name = "01259", action = ""},    -- 打雪仗

    jieying              = {name = "CoagulationChild", action = ""},    -- 结婴

    eightgod             = {name = "eightgod", action = ""},   -- 八仙

    house_renwuxiulian   = {name = "renwuxiulian", action = ""},   -- 居所-人物修炼

    pet_call_lingpo      = {name = "lingpo", action = ""},
    pet_call_beckones    = {name = "Beckones", action = ""},

    jinguangfu           = {name = "jinguangfu", action = ""},   -- 金光符

    childday_bubble      = {name = "01134", action = ""},         -- 儿童节泡泡

    -- 钓鱼界面
    home_fish_swim_fish  = {name = "01235", action = ""},  -- 游鱼
    home_fish_wave       = {name = "01222", action = ""},  -- 水波

    -- 登录背景界面
    login_back_magic     = {name = "01125", action = ""},
    login_back_bird1     = {name = "01131", action = ""},
    login_back_bird2     = {name = "01132", action = ""},

    -- 中秋接月饼界面
    midautumn_score_magic = {name = "01150", action = ""},

    -- 招财树界面
    zcs_play_magic       = {name = "01157", action = ""},

    -- 神秘大礼界面
    online_gift          = {name = "OnlineGiftDlg01", action = ""},

    -- 搜邪罗盘界面
    souxlp_stone         = {name = "01249", action = ""},

    click_cropland       = {name = "01168", action = ""}, -- 点击农田光效

    zf_tree_water        = {name = "01126", action = ""}, -- 招福宝树浇水动画

    marry_action         = {name = "marryAction", action = ""},

    -- 神秘大礼蛋的光效     Bottom01 砸蛋  Bottom02 可砸蛋发光 Bottom03 10倍奖励 Bottom04 三倍
    online_gift_egg         = {name = "01272", action = ""},  -- 神秘大礼蛋的光效

    PracticeDlg_shuangb         = {name = "01115", action = "Bottom"},

    funny_magic         = {name = "01289", action = "Bottom"},

    innerAlchemy_state    = {name = "01260", action = ""}, -- 内丹境界特效
    innerAlchemy_stage    = {name = "01284", action = ""}, -- 内丹阶段特效

    new_function_open     = {name = "01058", action = ""}, -- 新功能开启特效
    npc_food_red_area     = {name = "01288", action = ""}, -- npc脚底红色扇形特效

    lingmao_leave_letter  = {name = "01293", action = ""}, -- 灵猫出走的信封动画
    lingmao_feed          = {name = "01277", action = ""}, -- 灵猫喂食动画
    lingmao_touch         = {name = "01276", action = ""}, -- 灵猫爱抚动画

    create_char         = {name = "02034", action = "Bottom"}, -- 创角界面特效
    zhanbu_yaoqian        = {name = "01295", action = ""},  -- 神算子占卜摇签
    zhanbu_yaoqian_guide  = {name = "01152", action = "Bottom01"},  -- 神算子占卜摇签引导

    summer_hqzm           = {name = "01290", action = ""},   -- 暑假活动寒气之脉特效
    summer_xyby           = {name = "01298", action = "Bottom02"},  -- 暑假活动行云布雨水洼特效

    run_add_speed_foot    = {name = "01301", action = ""},    -- 暑假活动行脚底加速特效
    announcement_horn     = {name = "01320", action = "Bottom01"},  -- 公告界面小喇叭特效
    inn_barprogress_des   = {name = "01317", action = ""},    -- 客栈修行中、用餐中描述动画
    inn_fur_update        = {name = "01314", action = ""},    -- 客栈家具升级、新增动画
    inn_wait_around       = {name = "01315", action = "Bottom"},  -- 客栈候客区环绕动画
    inn_add_tcoin         = {name = "01318", action = "Top"},  -- 客栈候客区环绕动画
    inn_get_guest_btn     = {name = "01334", action = "Bottom"}, -- 首次进入客栈，候客按钮环绕特效
    inn_bomb_coin         = {name = "01327", action = ""},      -- 采集金币炸开特效

    results_succed         = {name = "01056", action = "Top"},      --
    results_failure         = {name = "01057", action = "Top"},      --

    sjb_arrow_left             = {name = "01344", action = "Bottom01"},      -- 世界杯界面箭头
    sjb_arrow_right             = {name = "01344", action = "Bottom02"},      -- 世界杯界面箭头

    zhaitaozi_monkey      = {name = "01346", action = "Bottom01"}, -- 探案摘桃子中的猴子光效

    midautumn_real_cake   = {name = "01264", action = ""},   -- 中秋 真月饼光效
    tanan_ying_yang_line  = {name = "01323", action = ""},         -- 探案江湖绿林 阴阳划线

    tanan_tw_open_box     = {name = "01324", action = ""}, -- 探案 天外之谜 打开盒子
    tanan_tw_zhenshifu_light = {name = "01326", action = ""}, -- 探案 天外之谜 镇尸符发光
    midautumn_eat_btn     = {name = "01266", action = "Top"}, -- 2018中秋大胃王 eat按钮点击特效


    point_head_eff         = {name = "01359", action = "Top01"},  -- 21点人物操作

    yanhua_ssfh            = {name = "01361", action = "Top"}, -- 烟花-盛世繁华
    yanhua_mtxy            = {name = "01362", action = "Top"}, -- 烟花-满天星雨
    yanhua_xlcy            = {name = "01363", action = "Top"}, -- 烟花-绚丽彩焰

    lihua_whzm             = {name = "02036", action = "Top01"},  -- 礼花·万花争鸣

    yanhua_succ            = {name = "01289", action = "Bottom06"}, -- 烟花

    fight_record_guide     = {name = "01387", action = "Bottom"},  -- 战斗指令指引

    zhongsqf_knock         = {name = "01377", action = ""},  -- 钟声祈福敲钟动画

    xunbao_guide         = {name = "02025", action = ""},  -- 钟声祈福敲钟动画
    spring_festival_happy  = {name = "02035", action = ""},  -- 春节快乐字特效
    spring_festival_wait_bk  = {name = "02037", action = ""},  -- 春节特效待机背景
    cwtx_open_box         = {name = "01391", action = "Top"},  -- 秘境探险开宝箱
    cwtx_no_open_box         = {name = "01391", action = "Bottom"},  -- 秘境探险未开启宝箱
    shenm_baohe          = {name = "02029", action = ""},  -- 神秘宝盒

    shenm_baohe          = {name = "02029", action = ""},  -- 神秘宝盒
    pet_explore_reward   = {name = "02041", action = "Top"},  -- 宠物探险奖励
    pet_explore_start   = {name = "02043", action = ""},      -- 宠物探险开始

    wenquan_soap_tip          = {name = "02040", action = ""},
    wenquan_temp_tip         = {name = "02038", action = ""},

    sxdj_egg    = {name = "02044", action = ""},    -- Bottom 和 top 两层
    qixi_color_flower    = {name = "02053", action = "Top"},    -- 七夕五彩情花特效
    lmqg_gsgz              = {name = "02048", action = "Top01"},            -- 七夕-浪漫巧果-盖上盖子
    lmqg_dkgz              = {name = "02048", action = "Top02"},            -- 七夕-浪漫巧果-打开盖子
    lmqg_get              = {name = "02052", action = "Top"},            -- 七夕-浪漫巧果-手抓特效
    lmqg_zzqg              = {name = "02049", action = "Top"},            -- 七夕-浪漫巧果-手抓特效
    magic02045              = {name = "02045", action = "Bottom"},
    magic02046              = {name = "02046", action = "Bottom"},
    magic02074              = {name = "02074", action = "Bottom"},
}

ResMgr.SkillText = {
    [CHS[3004276]] = ResMgr.ui.skill_text01,
    [CHS[3004277]] = ResMgr.ui.skill_text02,
    [CHS[3004278]] = ResMgr.ui.skill_text03,
    [CHS[3004279]] = ResMgr.ui.skill_text04,
    [CHS[3004280]] = ResMgr.ui.skill_text05,
    [CHS[3004281]] = ResMgr.ui.skill_text06,
    [CHS[3004282]] = ResMgr.ui.skill_text07,
    [CHS[3004283]] = ResMgr.ui.skill_text08,
    [CHS[3004284]] = ResMgr.ui.skill_text09,
    [CHS[3004285]] = ResMgr.ui.skill_text10,
    [CHS[3004286]] = ResMgr.ui.skill_text11,
    [CHS[3004287]] = ResMgr.ui.skill_text12,
    [CHS[3004288]] = ResMgr.ui.skill_text13,
    [CHS[3004289]] = ResMgr.ui.skill_text14,
    [CHS[3004290]] = ResMgr.ui.skill_text15,
    [CHS[3004291]] = ResMgr.ui.skill_text16,
    [CHS[3004292]] = ResMgr.ui.skill_text17,
    [CHS[3004293]] = ResMgr.ui.skill_text18,
    [CHS[3004277]] = ResMgr.ui.skill_text02,
    [CHS[3004294]] = ResMgr.ui.skill_text26,
    [CHS[3004295]] = ResMgr.ui.skill_text27,
    [CHS[3004296]] = ResMgr.ui.skill_text34,
    [CHS[3001987]] = ResMgr.ui.skill_text37,
    [CHS[3001988]] = ResMgr.ui.skill_text38,
    [CHS[3001989]] = ResMgr.ui.skill_text39,
    [CHS[3001990]] = ResMgr.ui.skill_text36,
    [CHS[3001991]] = ResMgr.ui.skill_text40,
    [CHS[3001942]] = ResMgr.ui.skill_text44,
    [CHS[3001943]] = ResMgr.ui.skill_text45,
    [CHS[3001944]] = ResMgr.ui.skill_text48,
    [CHS[3001945]] = ResMgr.ui.skill_text47,
    [CHS[3001946]] = ResMgr.ui.skill_text43,
    [CHS[3001947]] = ResMgr.ui.skill_text46,


    [CHS[4100982]] = ResMgr.ui.skill_text49,
    [CHS[4100967]] = ResMgr.ui.skill_text50,
    [CHS[4100968]] = ResMgr.ui.skill_text51,
}

ResMgr.icon = {
    fasion_ruyinian     = 21009,
    fasion_jixiangtian  = 21010,
    peach               = 52039, -- 桃子
    baoxiang            = 52035,
    tonglingdaoren      = 06042, -- 通灵道人
    yuanying            = 7008,  -- 元婴
    xueying             = 7009,  -- 血婴
    lianhuaguniang      = 6019,  -- 连花姑娘
    zhanglaoban         = 6012, -- 张老板
    item_ruyinian       = 9506,
    item_jixiangtian    = 9507
}

local ROLE_UI_IMAGE =
{
    [POLAR.METAL..GENDER_TYPE.MALE] =ResMgr.ui.role_metal_male,
    [POLAR.METAL..GENDER_TYPE.FEMALE] = ResMgr.ui.role_metal_female,
    [POLAR.WOOD..GENDER_TYPE.MALE] = ResMgr.ui.role_wood_male,
    [POLAR.WOOD..GENDER_TYPE.FEMALE] = ResMgr.ui.role_wood_female,
    [POLAR.WATER..GENDER_TYPE.MALE] = ResMgr.ui.role_water_male,
    [POLAR.WATER..GENDER_TYPE.FEMALE] = ResMgr.ui.role_water_female,
    [POLAR.FIRE..GENDER_TYPE.MALE] = ResMgr.ui.role_fire_male,
    [POLAR.FIRE..GENDER_TYPE.FEMALE] = ResMgr.ui.role_fire_female,
    [POLAR.EARTH..GENDER_TYPE.MALE] =ResMgr.ui.role_earth_male,
    [POLAR.EARTH..GENDER_TYPE.FEMALE] = ResMgr.ui.role_earth_female,
}
local ANIMATE_PATH = "animate/"

-- 路径信息
-- 获取对话框配置文件
function ResMgr:getDlgCfg(dlgName)
    return "ui/" .. dlgName .. ".json"
end

function ResMgr:getCirclePortraitPathByIcon(icon)
    return ICON_TO_CIRCLE_PORTRAIT[icon]
end

-- 获取跟随精灵
function ResMgr:getFollowSprite(icon, followPetType)
    if ResMgr.icon.fasion_ruyinian == icon or ResMgr.icon.fasion_jixiangtian == icon then
        local petName = InventoryMgr:getFollowPetNameByType(followPetType)
        local followPets = DressMgr:getFollowPet()
        if petName and followPets[petName] then
            return followPets[petName].effect_icon
    else
        return 0
    end
    else
        return 0
    end
end

-- 获取探案的天干文字图片
function ResMgr:getCaseTianganWordImg(word)
    if word == CHS[5450243] then
        return self.ui.case_jia_word
    elseif word == CHS[5450244] then
        return self.ui.case_yi_word
    elseif word == CHS[5450245] then
        return self.ui.case_bing_word
    elseif word == CHS[5450246] then
        return self.ui.case_ding_word
    elseif word == CHS[5450247] then
        return self.ui.case_wu_word
    elseif word == CHS[5450248] then
        return self.ui.case_ji_word
    elseif word == CHS[5450249] then
        return self.ui.case_geng_word
    elseif word == CHS[5450250] then
        return self.ui.case_xin_word
    elseif word == CHS[5450251] then
        return self.ui.case_ren_word
    elseif word == CHS[5450252] then
        return self.ui.case_gui_word
    end
end

-- 帮派职位图片资源配置
local PARTY_JOB_IMAGE_CFG = {
    [CHS[3000191]] = ResMgr.ui.party_job_word_bangzhu,    -- 帮主
    [CHS[3000193]] = ResMgr.ui.party_job_word_fubangzhu,  -- 副帮主
    [CHS[3000194]] = ResMgr.ui.party_job_word_zhanglao_xw,     -- 玄武长老
    [CHS[3000195]] = ResMgr.ui.party_job_word_zhanglao_ql,     -- 青龙长老
    [CHS[3000196]] = ResMgr.ui.party_job_word_zhanglao_bh,     -- 白虎长老
    [CHS[3000197]] = ResMgr.ui.party_job_word_zhanglao_zq,     -- 朱雀长老
    [CHS[3000198]] = ResMgr.ui.party_job_word_zhanglao_cl,     -- 苍兰护法
    [CHS[3000199]] = ResMgr.ui.party_job_word_hufa_yl,         -- 远雷护法
    [CHS[3000200]] = ResMgr.ui.party_job_word_hufa_jf,         -- 尖峰护法
    [CHS[3000201]] = ResMgr.ui.party_job_word_hufa_yf,         -- 夜伏护法
    [CHS[3000202]] = ResMgr.ui.party_job_word_hufa_yh,         -- 云海护法
    [CHS[3000203]] = ResMgr.ui.party_job_word_tangzhu_dx,      -- 德馨堂主
    [CHS[3000204]] = ResMgr.ui.party_job_word_tangzhu_sx,      -- 素侠堂主
    [CHS[3000205]] = ResMgr.ui.party_job_word_tangzhu_al,      -- 暗龙堂主
    [CHS[3000206]] = ResMgr.ui.party_job_word_tangzhu_hw,      -- 虎威堂主
    [CHS[3000207]] = ResMgr.ui.party_job_word_tangzhu_zy,      -- 紫云堂主
    [CHS[3000208]] = ResMgr.ui.party_job_word_tangzhu_tx,      -- 听雪堂主
    [CHS[3000209]] = ResMgr.ui.party_job_word_tangzhu_mx,      -- 梦溪堂主
    [CHS[3000210]] = ResMgr.ui.party_job_word_tangzhu_xf,      -- 玄风堂主
}

function ResMgr:getPartyJobWordImagePath(job)
    return PARTY_JOB_IMAGE_CFG[job]
end

-- 获取相性图片路径
function ResMgr:getPolarImagePath(polar)
    if polar == CHS[3004297] or polar == 1 then
        return self.ui.SmallPolar1
    elseif polar == CHS[3004298] or polar == 2 then
        return self.ui.SmallPolar2
    elseif polar == CHS[3004299] or polar == 3 then
        return self.ui.SmallPolar3
    elseif polar == CHS[3004300] or polar == 4 then
        return self.ui.SmallPolar4
    elseif polar == CHS[3004301] or polar == 5 then
        return self.ui.SmallPolar5
    end

    return self.ui.SmallPolar6
end

function ResMgr:getSuitPolarImagePath(polar)
    if polar == CHS[3004297] or polar == 1 then
        return self.ui.suit_polar_metal
    elseif polar == CHS[3004298] or polar == 2 then
        return self.ui.suit_polar_wood
    elseif polar == CHS[3004299] or polar == 3 then
        return self.ui.suit_polar_water
    elseif polar == CHS[3004300] or polar == 4 then
        return self.ui.suit_polar_fire
    elseif polar == CHS[3004301] or polar == 5 then
        return self.ui.suit_polar_earth
    end
end

-- 获取宠物类型图片路径
function ResMgr:getPetRankImagePath(pet)
    local rank = pet:queryBasicInt("rank")
    local mount_type = pet.mount_type or pet:queryInt("mount_type")

    if mount_type == MOUNT_TYPE.MOUNT_TYPE_JINGGUAI then -- 精怪
        return ResMgr.ui.jingguai_word
    elseif mount_type == MOUNT_TYPE.MOUNT_TYPE_YULING then -- 御灵
        return ResMgr.ui.yuling_word
    elseif rank == Const.PET_RANK_WILD then
        -- 野生
        return ResMgr.ui.yesheng_word
    elseif rank == Const.PET_RANK_BABY then
        if PetMgr:isYuhuaCompleted(pet) then
            -- 点化
            return ResMgr.ui.yuhua_word
        end

        if pet:queryBasicInt("enchant") == 2 then
            -- 点化
            return ResMgr.ui.dianhua_word
        end
        if pet.phy_rebuild_level or pet.mag_rebuild_level then
            if pet.phy_rebuild_level > 0 or pet.mag_rebuild_level > 0 then
                -- 强化
                return ResMgr.ui.qianghua_word
            end
        else
            if pet:queryInt("phy_rebuild_level") > 0 or pet:queryInt("mag_rebuild_level") > 0  then
                -- 强化
                return ResMgr.ui.qianghua_word
            end
        end
        -- 宝宝
        return ResMgr.ui.baobao_word
    elseif rank == Const.PET_RANK_ELITE then
        -- 变异
        return ResMgr.ui.bianyi_word
    elseif rank == Const.PET_RANK_EPIC then
        -- 神兽
        return ResMgr.ui.shenshou_word
    end

    return ResMgr.ui.yesheng_word
end

-- 获取角色资源路径
function ResMgr:getCharPath(path, act)
    return string.format("char/%s/%s", path or "", act or "");
end

-- 是否使用  magic_n 中的光效
function ResMgr:useMagicNRes(icon)
    if CartoonNewInfo[string.format("%05d", icon)] then
        -- 存在配置，需要再检测一下资源是否存在(检测 plist 文件即可)
        local bExist = cc.FileUtils:getInstance():isFileExist(string.format("magic_n/%05d.plist", icon))
        return bExist
    end

    return false
end

-- 获取光效资源路径
function ResMgr:getMagicPath(icon, magicType, extra)
    local prePath
    icon = (icon or 0)
    if MAGIC_TYPE.MAP == magicType then
        prePath = "maps/magic"
    elseif self:useMagicNRes(icon) and CartoonNewInfo[string.format("%05d", icon)] then
        -- 优先使用  magic_n 且存在对应的配置
        prePath = "magic_n"
    else
        prePath = "magic"
    end

    if extra and isDebug then
        return string.format("%s/%05d_%s", prePath, icon, tostring(extra));
    else
        return string.format("%s/%05d", prePath, icon);
    end
end

-- 获取角色Cartoon.ini路径
function ResMgr:getCharCartoonPath(icon)
    return string.format("char/%05d/00000/Cartoon.lua", icon or 0)
end

-- 获取换色方案配置
function ResMgr:getCharPartColorPath(icon, part, suffix)
    suffix = suffix or ".lua"
    return string.format("char/%05d/%05d/color%s", icon or 0, part or 0, suffix)
end

-- 获取地图障碍点路径
function ResMgr:getMapInfoPath(id)
    return string.format("maps/%05d/back.lua", id)
end

-- 获取地图障碍点路径
function ResMgr:getMapObstaclePath(id)
    return string.format("maps/tmx/%05d.tmx", id)
end

-- 获取地图块路径
function ResMgr:getMapBlockPath(id, x, y, flipX, flipY)
    return string.format("maps/%05d/%d_%d.jpg", id, x, y)
end

-- 地图映射配置
local MAPPING_MAP_BLOCK =
{
    [28200] = 28100,
    [28300] = 28100,
    [28201] = 28101,
    [28301] = 28101,
    [28202] = 28102,
    [28302] = 28102,
}

function ResMgr:getMapBlockPathByName(id, name, index, wall_index)
    id = MAPPING_MAP_BLOCK[id] or id
    if string.match(name, "co:.*") then
        return string.format("maps/%05d/scene_%s.png", id, string.match(name, "co:(.*)"))
    elseif string.match(name, "o:.*") then
        return string.format("maps/%05d/item%02d_%s.png", id, index, string.match(name, "o:(.*)"))
    elseif string.match(name, "w:.*") then
        return string.format("maps/%05d/wall%02d_%s.png", id, wall_index, string.match(name, "w:(.*)"))
    else
        return string.format("maps/%05d/floor%02d_%s.png", id, index, name)
    end
end

local ICON_TO_BONES = {
    [6001] = ResMgr.DragonBones.creatCharShape1,
    [7001] = ResMgr.DragonBones.creatCharShape2,
    [7002] = ResMgr.DragonBones.creatCharShape3,
    [6002] = ResMgr.DragonBones.creatCharShape4,
    [7003] = ResMgr.DragonBones.creatCharShape5,
    [6003] = ResMgr.DragonBones.creatCharShape6,
    [6004] = ResMgr.DragonBones.creatCharShape7,
    [7004] = ResMgr.DragonBones.creatCharShape8,
    [6005] = ResMgr.DragonBones.creatCharShape9,
    [7005] = ResMgr.DragonBones.creatCharShape10,
}

function ResMgr:getCharBoneShape(icon)
    return ICON_TO_BONES[icon]
end

-- 获取小头像路径
function ResMgr:getSmallPortrait(icon)
    if icon == nil then return end

    return string.format("portraits/%05d_01_s.png", icon or 0)
end

-- 获取大头像路径
function ResMgr:getBigPortrait(icon)
    if icon == nil then return end
    return string.format("portraits/%05d_01_b.png", icon)
end

-- 获取地图NPC路径
function ResMgr:getMapNpcIcon(icon)
    if not icon then return end
    return string.format("map_npcs/%05d.png", icon)
end

-- 获取地图NPC的tile信息
function ResMgr:getMapNpcTmx(icon)
    if not icon then return end
    return string.format("map_npcs/%05d.tmx", icon)
end

-- 获取NPC的tile信息
function ResMgr:getNpcTmx(icon)
    if not icon then return end
    return string.format("char/tmx/%05d.tmx", icon)
end

-- 获取数字图片资源路径
function ResMgr:getNumImg(group)
    return string.format("num/%s", group)
end

function ResMgr:getSkillTextImg(skill)
    return string.format("ui/%s", skill)
end

-- 获取配置文件路径
function ResMgr:getCfgPath(filename)
    return gf:getFileName('cfg/' .. (filename or ''))
end

-- 获取空间资源路径
function ResMgr:getBlogPath(fileName, subres)
    if subres then
        return string.format("%s/blogs/%s_%s.%s", Const.WRITE_PATH, gf:getFileName(fileName), gfGetMd5(subres), gf:getFileExt(fileName))
    else
        return string.format("%s/blogs/%s", Const.WRITE_PATH, fileName)
    end
end

-- 获取自定义帮派图标路径
function ResMgr:getCustomPartyIconPath(fileName)
    return string.format("%s/%s/partyicon/%s.jpg", cc.FileUtils:getInstance():getWritablePath(), Const.WRITE_PATH, fileName)
end

-- 获取帮派图标路径
function ResMgr:getPartyIconPath(icon)
    if 'number' == type(icon) then
        return string.format("partyicon/default%03d.png", icon)
    else
        return string.format("partyicon/%s", icon)
    end
end

-- 检查默认帮派图标是否存在
function ResMgr:checkPartyIconPaht(icon)
    if 'number' == type(icon) then
        if cc.FileUtils:getInstance():isFileExist(string.format("partyicon/default%03d.epg", icon)) then
            return true
        else
            return cc.FileUtils:getInstance():isFileExist(string.format("partyicon/default%03d.png", icon))
        end
    else
        local fileName = gf:getFileName(icon)

        if cc.FileUtils:getInstance():isFileExist(string.format("partyicon/%s.epg", fileName)) then
            return true
        else
            return cc.FileUtils:getInstance():isFileExist(string.format("partyicon/%s.png", fileName))
        end
    end
end

-- 获取帮派图标配置路径
function ResMgr:getPartyIconCfgPath(filename)
    return string.format("partyicon/%s", filename)
end

-- 获取技能图标文件路径
function ResMgr:getSkillIconPath(icon)
    return string.format('skillicon/%05d.png', icon)
end

-- 获取文字图片
function ResMgr:getWordsImgPath(name)
    return string.format('wordsimg/%s.png', name)
end

-- 获取文字plist
function ResMgr:getAttrWordsPlistPath()
    return "other/attributelabel"
end

-- 根据名称获取道具icon路径
function ResMgr:getIconPathByName(name)
    local petCfg = PetMgr:getPetCfg(name)
    if petCfg and petCfg.icon then
        return ResMgr:getSmallPortrait(petCfg.icon)
    else
        if InventoryMgr:isPlist(name) then
            return InventoryMgr:getIconByName(name), true
        else
            return ResMgr:getItemIconPath(InventoryMgr:getIconByName(name))
        end
    end
end

-- 获取道具图标路径
function ResMgr:getItemIconPath(icon)

    -- 特殊处理模块,如果为金钱和银元宝
    if icon == CHS[3004302] then
        return ResMgr.ui.money
    end

    if icon == CHS[3004303] then
        return ResMgr.ui.voucher
    end

    if icon == CHS[3004304] then
        return ResMgr.ui.yinyuanbao
    end

    return string.format("items/%05d_50.png", icon or 1001)
end

-- 获取对应ladder的美术字
function ResMgr:getLadderPath(ladder)
    if ladder == SKILL.LADDER_1 then
        return self.ui.skill_ladder1
    elseif ladder == SKILL.LADDER_2 then
        return self.ui.skill_ladder2
    elseif ladder == SKILL.LADDER_3 then
        return self.ui.skill_ladder3
    elseif ladder == SKILL.LADDER_4 then
        return self.ui.skill_ladder4
    elseif ladder == SKILL.LADDER_5 then
        return self.ui.skill_ladder5
    end
end

-- 获取 shader 文件
function ResMgr:getShaderPath(name)
    return "shader/" .. name
end

-- 获取sound文件路径
function ResMgr:getSoundFilePath(name)
    return "sound/"..name
end

-- 获取气泡底图
function ResMgr:getBubblesFile()
    return self.ui.bubble_back
end

-- 获取气泡箭头
function ResMgr:getBubblesArrowFile()
    return self.ui.bubble_arrow
end

-- 获取向下箭头
function ResMgr:getMagicDownIcon()
    return self.magic.down_arrow_magic
end

-- 获取向下箭头
function ResMgr:getFightStatusMove(isShow)
    if isShow then
        return self.ui.main_icon17
    else
        return self.ui.main_icon18
    end
end

-- 获取采集的图片
function ResMgr:getGatherIcon(icon)
    return string.format("ui/Icon%04d.png", icon or 0258)
end

-- 获取UI的图片
function ResMgr:getUIIcon(icon)
    return string.format("ui/Icon%04d.png", icon)
end

-- 获取角色界面底图
function ResMgr:getUserDlgPolarBgImg(polar, gender)
    local key = polar .. gender
    return ROLE_UI_IMAGE[key]
end

-- 根据相性和性别获取角色icon
function ResMgr:getIconByPolarAndGender(polar, gender)
    for i = 1, #self.createCharInfo do
        local icon = self.createCharInfo[i][3]

        if  self.createCharInfo[i][1] == polar and self.createCharInfo[i][4] == GENDER_NAME[gender] then
            return icon
        end
    end
end

-- 根据角色icon获取相性和性别
function ResMgr:getPolarAndGenerByIcon(icon)
    local gender
    local polar
    for i = 1, #self.createCharInfo do
        local info = self.createCharInfo[i]
        if icon == info[3] then
            polar = info[1]
            if info[4] == CHS[3000254] then
                gender = GENDER_TYPE.MALE
            else
                gender = GENDER_TYPE.FEMALE
            end
        end
    end

    if gender and polar then
        return polar, gender
    end
end

-- 获取角色原色头像
function ResMgr:getUserSmallPortrait(polar, gender)
    return ResMgr:getSmallPortrait(self:getIconByPolarAndGender(polar, gender))
end

function ResMgr:getBuffIconPath()
    return "ui/bufficon"
end
-- 获取战斗中状态效果文件
function ResMgr:getFightStatus(type)
    if type == 1 then
        -- 中毒
        return self.ui.fight_buff02
    elseif type == 2 then
        -- 昏睡
        return self.ui.fight_buff07
    elseif type == 3 then
        -- 遗忘
        return self.ui.fight_buff09
    elseif type == 4 then
        -- 冰冻
        return self.ui.fight_buff01
    elseif type == 5 then
        -- 混乱
        return self.ui.fight_buff05
    elseif type == 13 then
        -- 速度上升
        return self.ui.fight_buff08
    elseif type == 14 then
        -- 物理伤害上升
        return self.ui.fight_buff04
    elseif type == 17 then
        -- 躲闪上升
        return self.ui.fight_buff06
    elseif type == 18 then
        -- 防御力上升
        return self.ui.fight_buff03
    elseif type == 19 then
        -- 气血上升(持续加血)
        return self.ui.fight_buff10
    elseif type == 27 then
        -- 乾坤罩
        return self.ui.fight_buff13
    elseif type == 28 then
        -- 死亡缠绵特效
        return self.ui.fight_buff16
    elseif type == 29 then
        -- 游说之舌
        return self.ui.fight_buff18
    elseif type == 30 then
        -- 神龙罩
        return self.ui.fight_buff15
    elseif type == 31 then

        -- 如意圈
        return self.ui.fight_buff14
    elseif type == 32 then

        -- 五行改变
        return self.ui.fight_buff12
    elseif type == 33 then
        -- 翻转乾坤
        return self.ui.fight_buff12
    elseif type == 34 then
        -- 法力护盾
        return self.ui.fight_buff11
    elseif type == 35 then
        -- 无色光环
        return self.ui.fight_buff17
    elseif type == 36 then
        -- 移花接木技能状态
        return self.ui.fight_buff19
    elseif type == 43 then
        -- 缓兵之计
        return self.ui.fight_buff20
    elseif type == 44 then
        -- 束手就擒
        return self.ui.fight_buff21
    elseif type == 45 then
        -- 哀痛欲绝
        return self.ui.fight_buff23
    elseif type == 46 then
        -- 闻风丧胆
        return self.ui.fight_buff22
    elseif type == 47 then
        -- 养精蓄锐
        return self.ui.fight_buff24
    elseif type == 48 then
        -- 颠倒乾坤
        return self.ui.fight_buff25
    elseif type == 49 then
        -- 金刚圈
        return self.ui.fight_buff26
    elseif type == 52 then
        -- 嘲讽
        return self.ui.fight_buff27
    elseif type == 55 then
        -- 七杀 YANG
        return self.ui.fight_buff30
    elseif type == 54 then
        -- 七杀 阴
        return self.ui.fight_buff29
    elseif type == 56 then
        -- 七杀 阴
        return self.ui.fight_buff31
    elseif type == 58 then
        -- 威压  资源为替代资源
        return self.ui.fight_buff32
    elseif type == 60 then
        return self.ui.fight_buff33
    elseif type == 100 then
        -- 火眼金睛
        return self.ui.fight_buff28
     end

    return nil
end

-- 粒子光效
function ResMgr:getParticleFilePath(name)
    return ANIMATE_PATH .. "ui/" .. name ..".plist"
end

-- 粒子光效
function ResMgr:getParticleWeatherAnimatePath(name)
    return ANIMATE_PATH .. "weather/" .. name ..".plist"
end

-- ui资源路径
function ResMgr:getUIArmatureFilePath(name)
    return ANIMATE_PATH .. "ui/" .. name ..".ExportJson"
end

-- 技能资源路径
function ResMgr:getSkillFilePath(icon)
    return ANIMATE_PATH .. "skill/" .. icon.. "/" .. icon ..".ExportJson"
end

-- 角色骨骼动画资源路径
function ResMgr:getCharFilePath(icon)
    return ANIMATE_PATH .. "char/" .. icon.. "/" .. icon ..".ExportJson"
end

-- 地图光效资源路径
function ResMgr:getMapFilePath(icon)
    return ANIMATE_PATH .. "map/" .. icon.. "/" .. icon ..".ExportJson"
end

-- 天气光效资源路径
function ResMgr:getWeatherAnimatePath(icon)
    return ANIMATE_PATH .. "weather/" .. icon ..".ExportJson"
end

-- 影子光效资源路径
function ResMgr:getShadowFilePath(icon)
    return "other/" .. icon .. ".png"
end

function ResMgr:getStoreMoneyIcon(money)
    local icon
    if money >= 0 and money < 10000000 then
        icon = self.ui.mall_cash1
    elseif money >= 10000000 and money < 100000000 then
        icon = self.ui.mall_cash2
    elseif money >= 100000000 and money < 1000000000 then
        icon = self.ui.mall_cash3
    elseif money >= 1000000000 then
        icon = self.ui.mall_cash4
    end

    return icon
end

-- 获取天气贴图
function ResMgr:getWeatherFilePath(no)
    return string.format("weather/cloud_%03d.png", no)
end

function ResMgr:getRandomLoadingPic()
    local pictureNames = LoadingPicInfo
    local num = math.random(1, #pictureNames)
    return "loading_pic/" .. pictureNames[num]
end

function ResMgr:getLoadingPic(index)
    local pictureNames = LoadingPicInfo
    index = (index % #pictureNames) + 1
    return "loading_pic/" .. pictureNames[index]
end

-- 获取家具路径
function ResMgr:getFurniturePath(icon, iconNo)
    if not iconNo or iconNo == 0 then
        return string.format("furniture/%05d.png", icon)
    else
        return string.format("furniture/%05d_%d.png", icon, iconNo)
    end
end

-- 获取家具tile信息
function ResMgr:getFurnitureTilePath(icon, iconNo)
    if not iconNo or iconNo == 0 then
        return string.format("furniture/%05d.tmx", icon)
    else
        return string.format("furniture/%05d_%d.tmx", icon, iconNo)
    end
end

-- 获取骨骼动画家具路径
function ResMgr:getAnimateFurniturePath(icon)
    return string.format(ANIMATE_PATH .. "furniture/%s.ExportJson", icon)
end

-- 获取骨骼动画家具tile信息
function ResMgr:getAnimateFurnitureTilePath(icon, dir)
    return string.format(ANIMATE_PATH .. "furniture/%05d_%d.tmx", icon, dir)
end

-- 获取 ui 类的龙骨动画文件路径
function ResMgr:getBonesUIFilePath(icon)
    return DragonBonesMgr:getBonesUIFilePath(icon)
end

-- 获取 char 类的龙骨动画文件路径
function ResMgr:getBonesCharFilePath(icon)
    return DragonBonesMgr:getBonesCharFilePath(icon)
end

-- 获取 map 类的龙骨动画文件路径
function ResMgr:getBonesMapFilePath(icon)
    return DragonBonesMgr:getBonesMapFilePath(icon)
end

-- type = 3飞仙
-- type = 4飞魔
-- isImage = true, 返回图标
-- isImage = false, 返回光效，默认返回光效
function ResMgr:getUpgradeIconByType(type, isImage)
    if not type then
        return
    end

    if isImage then
        if type == CHILD_TYPE.UPGRADE_IMMORTAL then
            return ResMgr.ui.upgrade_immortal
        elseif type == CHILD_TYPE.UPGRADE_MAGIC then
            return ResMgr.ui.upgrade_magic
        end
    else
        if type == CHILD_TYPE.UPGRADE_IMMORTAL then
            return ResMgr.magic.upgrade_immortal
        elseif type == CHILD_TYPE.UPGRADE_MAGIC then
            return ResMgr.magic.upgrade_magic
        end
    end
end

function ResMgr:getGenderSignByGender(gender)
     if gender == GENDER_TYPE.MALE then
        return self.ui.gender_male_sign
     elseif gender == GENDER_TYPE.FEMALE then
        return self.ui.gender_female_sign
     end
end

function ResMgr:getRelationIconByTitle(title)
    local title_icon_map = {
        [CHS[4101061]] = ResMgr.ui.jiebai_dage,         -- 大哥
        [CHS[4101062]] = ResMgr.ui.jiebai_erge,     -- 二哥
        [CHS[4101063]] = ResMgr.ui.jiebai_sange,
        [CHS[4101064]] = ResMgr.ui.jiebai_sige,

        [CHS[4101065]] = ResMgr.ui.jiebai_erdi,
        [CHS[4101066]] = ResMgr.ui.jiebai_sandi,
        [CHS[4101067]] = ResMgr.ui.jiebai_sidi,
        [CHS[4101068]] = ResMgr.ui.jiebai_wudi,

        [CHS[4101069]] = ResMgr.ui.jiebai_dajie,
        [CHS[4101070]] = ResMgr.ui.jiebai_erjie,
        [CHS[4101071]] = ResMgr.ui.jiebai_sanjie,
        [CHS[4101072]] = ResMgr.ui.jiebai_sijie,

        [CHS[4101073]] = ResMgr.ui.jiebai_ermei,
        [CHS[4101074]] = ResMgr.ui.jiebai_sanmei,
        [CHS[4101075]] = ResMgr.ui.jiebai_simei,
        [CHS[4101076]] = ResMgr.ui.jiebai_wumei,

        [CHS[4101077]] = ResMgr.ui.shitu_shifu,
        [CHS[4101078]] = ResMgr.ui.shitu_tudi,

        [CHS[4101079]] = ResMgr.ui.fuqi_xianggong,
        [CHS[4101080]] = ResMgr.ui.fuqi_niangzi,
    }

    return title_icon_map[title]
end

-- 获取小地图文件
function ResMgr:getSmallMapFile(mapId)
    local mapInfo = MapMgr:getMapInfoById(mapId)
    if mapInfo then
        return string.format("maps/smallMaps/%05d.jpg", mapId)
    end
end

-- icon是否为双人坐骑icon
function ResMgr:isCoupleRideIcon(icon)
    return icon == 31501 or icon == 31502
end

-- 角色信息
ResMgr.createCharInfo = require('cfg/CreateCharInfo')

ResMgr.matchPortraitInfo = {
    { "ui/Icon2221.png", "ui/Icon2220.png" },
    { "ui/Icon2223.png", "ui/Icon2222.png" },
    { "ui/Icon2225.png", "ui/Icon2224.png" },
    { "ui/Icon2227.png", "ui/Icon2226.png" },
    { "ui/Icon2229.png", "ui/Icon2228.png" },
}

ResMgr.matchPortraitInfoForIcon = {

    [6001] = "ui/Icon2221.png", -- 金男
    [6002] = "ui/Icon2222.png", -- 木女
    [6003] = "ui/Icon2224.png", -- 水女
    [6004] = "ui/Icon2227.png", -- 火男
    [6005] = "ui/Icon2229.png", -- 土男

    [7001] = "ui/Icon2220.png", -- 金女
    [7002] = "ui/Icon2223.png", -- 木男
    [7003] = "ui/Icon2225.png", -- 水男
    [7004] = "ui/Icon2226.png", -- 火女
    [7005] = "ui/Icon2228.png", -- 土女
}

ResMgr.matchMakingMatchImage = {
    "ui/Icon2210.png",
    "ui/Icon2211.png",
    "ui/Icon2213.png",
    "ui/Icon2214.png",
}

function ResMgr:getMatchPortraitByIcon(icon)
    return ResMgr.matchPortraitInfoForIcon[icon]
end

function ResMgr:getMatchPortrait(polar, gender)
    return ResMgr.matchPortraitInfo[polar][gender]
end

return ResMgr
