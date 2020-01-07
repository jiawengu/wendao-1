-- RankingListDlg.lua
-- Created by chenyq Jan/10/2014
-- 排行榜界面

local Bitset = require("core/Bitset")
local TableRow = require('ctrl/TableRow')
local RadioGroup = require("ctrl/RadioGroup")
local RankingListDlg = Singleton("RankingListDlg", Dialog)

local inRank = 100
local inRankTao = 5000
local PER_PAGE_NUM = 10
local ITEM_PANEL_NORMAL = "normal"

local rankTypeItemPanel = {}

-- 各排行类别的名称信息
local RANK_TYPE_NAMES = {
    [RANK_TYPE.CHAR]                  = CHS[3000032],      -- 个人排行榜
    [RANK_TYPE.PET]                   = CHS[3000033],      -- 宠物排行榜
    [RANK_TYPE.EQUIP]                 = CHS[3003502],
    [RANK_TYPE.GUARD]                 = CHS[3003503],
    [RANK_TYPE.PARTY]                 = CHS[3003504],
    [RANK_TYPE.GET_TAO]               = CHS[3003505],
    [RANK_TYPE.CHALLENGE]             = CHS[3003506],
    [RANK_TYPE.HOUSE]                 = CHS[2200052],
    [RANK_TYPE.PK]                    = CHS[4200225],
    [RANK_TYPE.SYNTH]                 = CHS[4100847], -- 综合排行\
    [RANK_TYPE.ZDD]                   = CHS[4010034], -- 证道排行

    -- 个人排行榜的子类排行榜
    [RANK_TYPE.CHAR_LEVEL]            = CHS[3003507],    -- 等级排行
    [RANK_TYPE.CHAR_TAO]              = CHS[3000034],    -- 道行排行
    [RANK_TYPE.CHAR_MONTH_TAO]        = CHS[5450335],    -- 本月道行排行
    [RANK_TYPE.CHAR_PHY_POWER]        = CHS[3000035],    -- 物伤排行
    [RANK_TYPE.CHAR_MAG_POWER]        = CHS[3000036],    -- 法伤排行
    [RANK_TYPE.CHAR_SPEED]            = CHS[3000037],    -- 速度排行
    [RANK_TYPE.CHAR_DEF]              = CHS[3000038],    -- 防御排行
    [RANK_TYPE.CHAR_UPGRADE_LEVEL]    = CHS[2200053],
--   [RANK_TYPE.CHAR_ARENA]            = CHS[6000147],    -- 竞技排行

    -- 宠物排行榜的子类排行榜
    [RANK_TYPE.PET_MARTIAL]           = CHS[3000039],    -- 武学排行
    [RANK_TYPE.PET_PHY_POWER]         = CHS[3000040],    -- 物伤排行
    [RANK_TYPE.PET_MAG_POWER]         = CHS[3000041],    -- 法伤排行
    [RANK_TYPE.PET_SPEED]             = CHS[3000042],    -- 速度排行
    [RANK_TYPE.PET_DEF]               = CHS[3000043],    -- 防御排行

    -- 装备排行榜的子类排行榜
    [RANK_TYPE.EQUIP_LEVEL_ONE]       = CHS[7150028],    -- 装备等级段70-79
    [RANK_TYPE.EQUIP_LEVEL_TWO]       = CHS[7150022],    -- 装备等级段80-89
    [RANK_TYPE.EQUIP_LEVEL_THREE]     = CHS[7150023],    -- 装备等级段90-99
    [RANK_TYPE.EQUIP_LEVEL_FOUR]      = CHS[7150024],    -- 装备等级段100-109
    [RANK_TYPE.EQUIP_LEVEL_FIVE]      = CHS[7150025],    -- 装备等级段110-119
    [RANK_TYPE.EQUIP_LEVEL_SIX]       = CHS[7150026],    -- 装备等级段120-129

    -- 守护排行榜的子类排行榜
    [RANK_TYPE.GUARD_PHY_POWER]       = CHS[3003512],
    [RANK_TYPE.GUARD_MAG_POWER]       = CHS[3003513],
    [RANK_TYPE.GUARD_SPEED]           = CHS[3003514],
    [RANK_TYPE.GUARD_DEF]             = CHS[3003515],

    -- 帮派排行榜的子类排行榜
    [RANK_TYPE.PARTY_MONEY]           = CHS[3003516],
    [RANK_TYPE.PARTY_WAR]             = CHS[3003517],
    [RANK_TYPE.PARTY_WELFARE]         = CHS[3003518],

    -- 刷道排行榜的子类排行榜
    [RANK_TYPE.GET_TAO_CHUBAO]        = CHS[3003519],
    [RANK_TYPE.GET_TAO_XIANGYAO]      = CHS[3003520],
    [RANK_TYPE.GET_TAO_FUMO]          = CHS[3003521],
    [RANK_TYPE.GET_TAO_FXDX]          = CHS[4000446],

    -- 挑战排行榜的子类排行榜
    [RANK_TYPE.CHALLENGE_ARENA]       = CHS[3003522],
    [RANK_TYPE.CHALLENGE_TOWER]       = CHS[3003523],
    [RANK_TYPE.CHALLENGE_DART]        = CHS[3003524],
    [RANK_TYPE.CHALLENGE_PET]         = CHS[5450031],

    -- PK
    [RANK_TYPE.PK_BULLY]              = CHS[4200221],
    [RANK_TYPE.PK_POLICE]             = CHS[4200222],

    -- 居所排行的子类排汗
    [RANK_TYPE.HOUSE_COMFORT]         = CHS[2200054],

    -- 综合
    [RANK_TYPE.SYNTH_ACHIEVE]         = CHS[4100848],
    [RANK_TYPE.SYNTH_BLOG_POPULAR]      = CHS[5400288],  -- 空间人气


    -- 证道殿
    [RANK_TYPE.ZDD_METAL]      = CHS[4010035],        -- 金系排行
    [RANK_TYPE.ZDD_WOOD]      = CHS[4010036],        -- 木系排行
    [RANK_TYPE.ZDD_WATER]      = CHS[4010037],        -- 水系排行
    [RANK_TYPE.ZDD_FIRE]      = CHS[4010038],        -- 火系排行
    [RANK_TYPE.ZDD_EARTH]      = CHS[4010039],        --土系排行金系排行

    [RANK_TYPE.HERO]      = CHS[4010082],        --英雄会
}

-- 表头标题信息
local RANK_TYPE_TITLE_INFO = {
    -- 个人排行榜的子类排行榜
    [RANK_TYPE.CHAR_LEVEL]        = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3003525]},
    [RANK_TYPE.CHAR_TAO]        = {"", CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000049]},
    [RANK_TYPE.CHAR_MONTH_TAO]  = {"", CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000049]},
    [RANK_TYPE.CHAR_PHY_POWER]  = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000051]},
    [RANK_TYPE.CHAR_MAG_POWER]  = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000052]},
    [RANK_TYPE.CHAR_SPEED]      = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000053]},
    [RANK_TYPE.CHAR_DEF]        = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3000054]},
    [RANK_TYPE.CHAR_UPGRADE_LEVEL]        = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000047], CHS[3003525]},
 --   [RANK_TYPE.CHAR_ARENA]      = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[6000149], CHS[6000148]},

    -- 宠物排行榜的子类排行榜
    [RANK_TYPE.PET_MARTIAL]     = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000048], CHS[3000050]},
    [RANK_TYPE.PET_PHY_POWER]   = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000048], CHS[3000051]},
    [RANK_TYPE.PET_MAG_POWER]   = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000048], CHS[3000052]},
    [RANK_TYPE.PET_SPEED]       = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000048], CHS[3000053]},
    [RANK_TYPE.PET_DEF]         = {CHS[3000044], CHS[3000045], CHS[3000046], CHS[3000048], CHS[3000054]},

    -- 装备排行榜的子类排行榜
    [RANK_TYPE.EQUIP_WEAPON]    = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_HELMET]    = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_ARMOR]     = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_BOOT]      = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_ONE]    = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_TWO]    = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_THREE]  = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_FOUR]   = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_FIVE]   = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},
    [RANK_TYPE.EQUIP_LEVEL_SIX]    = {CHS[3003526], CHS[3003527], CHS[3003528], CHS[3003529], CHS[3003530]},

    -- 守护的子类排行榜
    [RANK_TYPE.GUARD_PHY_POWER]    = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003529], CHS[3003532]},
    [RANK_TYPE.GUARD_MAG_POWER]    = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003529], CHS[3003533]},
    [RANK_TYPE.GUARD_SPEED]        = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003529], CHS[3003534]},
    [RANK_TYPE.GUARD_DEF]          = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003529], CHS[3003535]},

    -- 帮派的子类排行榜
    [RANK_TYPE.PARTY_MONEY]        = {CHS[3003526], CHS[3003525], CHS[3003531], CHS[3003536], CHS[3003516]},
    [RANK_TYPE.PARTY_WAR]          = {CHS[3003526], CHS[3003525], CHS[3003531], CHS[3003536], CHS[3003537]},
    [RANK_TYPE.PARTY_WELFARE]      = {CHS[3003526], CHS[3003525], CHS[3003531], CHS[3003536], CHS[3003538]},

    -- 刷道的子类排行榜
    [RANK_TYPE.GET_TAO_CHUBAO]     = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003540]},
    [RANK_TYPE.GET_TAO_XIANGYAO]   = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003540]},
    [RANK_TYPE.GET_TAO_FUMO]       = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003540]},
    [RANK_TYPE.GET_TAO_FXDX]       = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003540]},

    -- 挑战的子类排行榜
    [RANK_TYPE.CHALLENGE_ARENA]        = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003541]},
    [RANK_TYPE.CHALLENGE_TOWER]        = {"", CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003542]},
    [RANK_TYPE.CHALLENGE_DART]         = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[3003543]},
    [RANK_TYPE.CHALLENGE_PET]          = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[5450035]},

    -- PK
    [RANK_TYPE.PK_BULLY]              = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[4200223]},
    [RANK_TYPE.PK_POLICE]             = {CHS[3003526], CHS[3003527], CHS[3003531], CHS[3003539], CHS[4200224]},

    -- HOUSE
    [RANK_TYPE.HOUSE_COMFORT]       = { CHS[2200055], CHS[2200056], CHS[2200057], CHS[2200058], CHS[2200059] },

    [RANK_TYPE.HERO]    = {"", CHS[4100471], CHS[4300320], CHS[4010115]},
    [RANK_TYPE.SYNTH_ACHIEVE]       = { CHS[2200055], CHS[3000045], CHS[3003531], CHS[3003539], CHS[4100848] },
    [RANK_TYPE.SYNTH_BLOG_POPULAR]    = { CHS[2200055], CHS[3000045], CHS[3003531], CHS[5400289], CHS[5400290] },


    [RANK_TYPE.ZDD_METAL]        = {"", CHS[4100471], CHS[4300320], CHS[4010040]},
    [RANK_TYPE.ZDD_WOOD]        = {"", CHS[4100471], CHS[4300320], CHS[4010040]},
    [RANK_TYPE.ZDD_WATER]        = {"", CHS[4100471], CHS[4300320], CHS[4010040]},
    [RANK_TYPE.ZDD_FIRE]        = {"", CHS[4100471], CHS[4300320], CHS[4010040]},
    [RANK_TYPE.ZDD_EARTH]        = {"", CHS[4100471], CHS[4300320], CHS[4010040]},
}

-- 表中列的宽度信息
local RANK_TYPE_COL_WIDTH = {
    -- 个人排行榜的子类排行榜
    [RANK_TYPE.CHAR_TAO]        = {60, 130, 200, 50, 130},
    [RANK_TYPE.CHAR_MONTH_TAO]  = {60, 130, 200, 50, 130},
    [RANK_TYPE.CHAR_PHY_POWER]  = {60, 130, 200, 50, 130},
    [RANK_TYPE.CHAR_MAG_POWER]  = {60, 130, 200, 50, 130},
    [RANK_TYPE.CHAR_SPEED]      = {60, 130, 200, 50, 130},
    [RANK_TYPE.CHAR_DEF]        = {60, 130, 200, 50, 130},
 --   [RANK_TYPE.CHAR_ARENA]      = {60, 130, 200, 50, 130},

    -- 宠物排行榜的子类排行榜
    [RANK_TYPE.PET_MARTIAL]     = {60, 150, 170, 60, 130},
    [RANK_TYPE.PET_PHY_POWER]   = {60, 150, 170, 60, 130},
    [RANK_TYPE.PET_MAG_POWER]   = {60, 150, 170, 60, 130},
    [RANK_TYPE.PET_SPEED]       = {60, 150, 170, 60, 130},
    [RANK_TYPE.PET_DEF]         = {60, 150, 170, 60, 130},

    [RANK_TYPE.PK_BULLY]        = {60, 150, 170, 60, 130},
    [RANK_TYPE.PK_POLICE]       = {60, 150, 170, 60, 130},
}

-- 数据中对应的字段信息
local RANK_TYPE_FIELD_INFO = {
    -- 个人排行榜的子类排行榜
    [RANK_TYPE.CHAR_LEVEL]        = {"", "name", "level", "polar", "party"},
    [RANK_TYPE.CHAR_TAO]        = {"", "name", "level", "polar", "tao"},
    [RANK_TYPE.CHAR_MONTH_TAO]  = {"", "name", "level", "polar", "mon_tao"},
    [RANK_TYPE.CHAR_PHY_POWER]  = {"", "name", "level", "polar", "phy_power"},
    [RANK_TYPE.CHAR_MAG_POWER]  = {"", "name", "level", "polar", "mag_power"},
    [RANK_TYPE.CHAR_SPEED]      = {"", "name", "level", "polar", "speed"},
    [RANK_TYPE.CHAR_DEF]        = {"", "name", "level", "polar", "def"},
    [RANK_TYPE.CHAR_UPGRADE_LEVEL]        = {"", "name", "upgrade_level", "polar", "party"},

    -- 宠物排行榜的子类排行榜
    [RANK_TYPE.PET_MARTIAL]     = {"", "name", "level", "owner_name", "martial"},
    [RANK_TYPE.PET_PHY_POWER]   = {"", "name", "level", "owner_name", "phy_power"},
    [RANK_TYPE.PET_MAG_POWER]   = {"", "name", "level", "owner_name", "mag_power"},
    [RANK_TYPE.PET_SPEED]       = {"", "name", "level", "owner_name", "speed"},
    [RANK_TYPE.PET_DEF]         = {"", "name", "level", "owner_name", "def"},

    -- 装备排行榜的子类排行榜
    [RANK_TYPE.EQUIP_WEAPON]     = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_HELMET]   = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_ARMOR]   = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_BOOT]       = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_ONE]    = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_TWO]    = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_THREE]  = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_FOUR]   = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_FIVE]   = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},
    [RANK_TYPE.EQUIP_LEVEL_SIX]    = {"", "name", "rebuild_level", "owner_name", "equip_perfect_percent"},

    -- 守护排行榜的子类排行榜
    [RANK_TYPE.GUARD_PHY_POWER]     = {"", "name", "level", "owner_name", "phy_power"},
    [RANK_TYPE.GUARD_MAG_POWER]   = {"", "name", "level", "owner_name", "mag_power"},
    [RANK_TYPE.GUARD_SPEED]   = {"", "name", "level", "owner_name", "speed"},
    [RANK_TYPE.GUARD_DEF]       = {"", "name", "level", "owner_name", "def"},

    -- 刷道排行榜的子类排行榜
    [RANK_TYPE.GET_TAO_CHUBAO]     = {"", "name", "level", "polar", "higest_chub"},
    [RANK_TYPE.GET_TAO_XIANGYAO]   = {"", "name", "level", "polar", "higest_xiangy"},
    [RANK_TYPE.GET_TAO_FUMO]       = {"", "name", "level", "polar", "higest_fum"},
    [RANK_TYPE.GET_TAO_FXDX]       = {"", "name", "level", "polar", "higest_feixdx"},

    -- 帮派排行榜的子类排行榜
    [RANK_TYPE.PARTY_MONEY]     = {"", "name", "level", "population", "money"},
    [RANK_TYPE.PARTY_WAR]        = {"", "name", "level", "population", "party_war_win"},
    [RANK_TYPE.PARTY_WELFARE]       = {"", "name", "level", "population", "salary"},

    -- 竞技场排行榜的子类排行榜
    [RANK_TYPE.CHALLENGE_ARENA]     = {"", "name", "level", "polar", "arena_rank"},
    [RANK_TYPE.CHALLENGE_TOWER]        = {"", "name", "level", "polar", "tontt_layer"},
    [RANK_TYPE.CHALLENGE_DART]       = {"", "name", "level", "polar", "higest_yasby"},
    [RANK_TYPE.CHALLENGE_PET]       = {"", "name", "level", "polar", "douchong_rank"},

    [RANK_TYPE.PK_BULLY]              = {"", "name", "level", "polar", "bully_kill_num"},
    [RANK_TYPE.PK_POLICE]             = {"", "name", "level", "polar", "police_kill_num"},

    [RANK_TYPE.HOUSE_COMFORT]       = { "", "owner_name", "couple_name", "house_type", "comfort" },

    [RANK_TYPE.HERO]        =  {"", "name", "party", "higest_score", ""},
    [RANK_TYPE.SYNTH_ACHIEVE]        = {"", "name", "level", "polar", "achieve"},
    [RANK_TYPE.SYNTH_BLOG_POPULAR]   = {"", "name", "level", "gender", "popular"},

    [RANK_TYPE.ZDD_METAL]        =  {"", "name", "party", "higest_score", ""},
    [RANK_TYPE.ZDD_WOOD]   =        {"", "name", "party", "higest_score", ""},
    [RANK_TYPE.ZDD_WATER]        =  {"", "name", "party", "higest_score", ""},
    [RANK_TYPE.ZDD_FIRE]   =        {"", "name", "party", "higest_score", ""},
    [RANK_TYPE.ZDD_EARTH]        =  {"", "name", "party", "higest_score", ""},

}

-- 排行主类别，及主类别包含的子类别
local RANK_MAIN_TYPE_LIST = {RANK_TYPE.CHAR, RANK_TYPE.EQUIP, RANK_TYPE.PET, RANK_TYPE.PARTY, RANK_TYPE.GET_TAO, RANK_TYPE.CHALLENGE,
                             RANK_TYPE.HOUSE, RANK_TYPE.PK, RANK_TYPE.ZDD, RANK_TYPE.SYNTH, RANK_TYPE.HERO,
}


local ONE_MENU = {
    CHS[4010083], CHS[4010084], CHS[4010085], CHS[4010086],   -- 个人排行
    CHS[4010087], CHS[4010088], CHS[4010089],
    CHS[4010091], CHS[4010090],
}

local SECOND_MENU = {
    [CHS[4010083]] = {CHS[4010092], CHS[4010093], CHS[5450335], CHS[4010094], CHS[4010095], CHS[4010096], CHS[4010097], CHS[4010098]},
    [CHS[4010084]] = {"70~79", "80~89", "90~99", "100~109", "110~119", "120~129"},
    [CHS[4010085]] = {CHS[4010099], CHS[4010094], CHS[4010095], CHS[4010096], CHS[4010097]},
    [CHS[4010086]] = {CHS[4010100], CHS[4010101], CHS[4010102]},
    [CHS[4010087]] = {CHS[3003520], CHS[3003521], CHS[4000446]},
    [CHS[4010088]] = {CHS[6000147], CHS[4010103], CHS[3000713], CHS[4010104]},

    [CHS[4010089]] = {CHS[4010105], CHS[4010106]},
    [CHS[4010090]] = {CHS[4010116], CHS[4100848], CHS[5400288], CHS[4010107]},              -- 综合排行
    [CHS[4010091]] = {CHS[4010108], CHS[4010109], CHS[4010110], CHS[4010111], CHS[4010112]},
}

-- 按钮tag对应的排行榜编号,tag是通用的逻辑下的
local MENU_TAG_TO_RANK_NO = {
    -- 个人
    [101] = RANK_TYPE.CHAR_LEVEL,
    [102] = RANK_TYPE.CHAR_TAO,
    [103] = RANK_TYPE.CHAR_MONTH_TAO,
    [104] = RANK_TYPE.CHAR_PHY_POWER,
    [105] = RANK_TYPE.CHAR_MAG_POWER,
    [106] = RANK_TYPE.CHAR_SPEED,
    [107] = RANK_TYPE.CHAR_DEF,
    [108] = RANK_TYPE.CHAR_UPGRADE_LEVEL,

    [201] = RANK_TYPE.EQUIP_LEVEL_ONE,
    [202] = RANK_TYPE.EQUIP_LEVEL_TWO,
    [203] = RANK_TYPE.EQUIP_LEVEL_THREE,
    [204] = RANK_TYPE.EQUIP_LEVEL_FOUR,
    [205] = RANK_TYPE.EQUIP_LEVEL_FIVE,
    [206] = RANK_TYPE.EQUIP_LEVEL_SIX,

    [301] = RANK_TYPE.PET_MARTIAL,
    [302] = RANK_TYPE.PET_PHY_POWER,
    [303] = RANK_TYPE.PET_MAG_POWER,
    [304] = RANK_TYPE.PET_SPEED,
    [305] = RANK_TYPE.PET_DEF,

    [401] = RANK_TYPE.PARTY_MONEY,
    [402] = RANK_TYPE.PARTY_WAR,
    [403] = RANK_TYPE.PARTY_WELFARE,

    [501] = RANK_TYPE.GET_TAO_XIANGYAO,
    [502] = RANK_TYPE.GET_TAO_FUMO,
    [503] = RANK_TYPE.GET_TAO_FXDX,

    [601] = RANK_TYPE.CHALLENGE_ARENA,
    [602] = RANK_TYPE.CHALLENGE_TOWER,
    [603] = RANK_TYPE.CHALLENGE_DART,
    [604] = RANK_TYPE.CHALLENGE_PET,

    [701] = RANK_TYPE.PK_BULLY,
    [702] = RANK_TYPE.PK_POLICE,

    [801] = RANK_TYPE.ZDD_METAL,
    [802] = RANK_TYPE.ZDD_WOOD,
    [803] = RANK_TYPE.ZDD_WATER,
    [804] = RANK_TYPE.ZDD_FIRE,
    [805] = RANK_TYPE.ZDD_EARTH,

    [901] = RANK_TYPE.HERO,
    [902] = RANK_TYPE.SYNTH_ACHIEVE,
    [903] = RANK_TYPE.SYNTH_BLOG_POPULAR,
    [904] = RANK_TYPE.HOUSE_COMFORT,
}

local RANK_MAIN_TYPE_INFO = {
    [RANK_TYPE.CHAR] = {
        RANK_TYPE.CHAR_LEVEL,
        RANK_TYPE.CHAR_TAO,
        RANK_TYPE.CHAR_MONTH_TAO,
        RANK_TYPE.CHAR_PHY_POWER,
        RANK_TYPE.CHAR_MAG_POWER,
        RANK_TYPE.CHAR_SPEED,
        RANK_TYPE.CHAR_DEF,
        RANK_TYPE.CHAR_UPGRADE_LEVEL,
    },
    [RANK_TYPE.PET]  = {
        RANK_TYPE.PET_MARTIAL,
        RANK_TYPE.PET_PHY_POWER,
        RANK_TYPE.PET_MAG_POWER,
        RANK_TYPE.PET_SPEED,
        RANK_TYPE.PET_DEF
    },
    [RANK_TYPE.EQUIP]  = {
        RANK_TYPE.EQUIP_LEVEL_ONE,
        RANK_TYPE.EQUIP_LEVEL_TWO,
        RANK_TYPE.EQUIP_LEVEL_THREE,
        RANK_TYPE.EQUIP_LEVEL_FOUR,
        RANK_TYPE.EQUIP_LEVEL_FIVE,
        RANK_TYPE.EQUIP_LEVEL_SIX,
    },
    [RANK_TYPE.PARTY]  = {
        RANK_TYPE.PARTY_MONEY,
        RANK_TYPE.PARTY_WAR,
        RANK_TYPE.PARTY_WELFARE,
    },
    [RANK_TYPE.GET_TAO]  = {
        RANK_TYPE.GET_TAO_XIANGYAO,
        RANK_TYPE.GET_TAO_FUMO,
        RANK_TYPE.GET_TAO_FXDX,
    },
    [RANK_TYPE.CHALLENGE]  = {
        RANK_TYPE.CHALLENGE_ARENA,
        RANK_TYPE.CHALLENGE_TOWER,
        RANK_TYPE.CHALLENGE_DART,
        RANK_TYPE.CHALLENGE_PET,
    },
    [RANK_TYPE.PK] = {
        RANK_TYPE.PK_BULLY,
        RANK_TYPE.PK_POLICE,
    },
    [RANK_TYPE.SYNTH] = {
        RANK_TYPE.SYNTH_ACHIEVE,
        RANK_TYPE.SYNTH_BLOG_POPULAR,
        RANK_TYPE.HOUSE_COMFORT,
    },
    [RANK_TYPE.ZDD] = {
        RANK_TYPE.ZDD_METAL,
        RANK_TYPE.ZDD_WOOD,
        RANK_TYPE.ZDD_WATER,
        RANK_TYPE.ZDD_FIRE,
        RANK_TYPE.ZDD_EARTH,
    },
}

-- 子类别转对应的索引(用来映射最后打开的排行)
local CURTYPE_TO_LSITTYPE =
    {
        [RANK_TYPE.CHAR_LEVEL] = 1,
        [RANK_TYPE.CHAR_TAO] = 2,
        [RANK_TYPE.CHAR_PHY_POWER] = 3,
        [RANK_TYPE.CHAR_MAG_POWER] = 4,
        [RANK_TYPE.CHAR_SPEED] = 5,
        [RANK_TYPE.CHAR_DEF] = 6,
  --      [RANK_TYPE.CHAR_ARENA] = 6,
        [RANK_TYPE.PET_MARTIAL] = 1,
        [RANK_TYPE.PET_PHY_POWER] = 2,
        [RANK_TYPE.PET_MAG_POWER] = 3,
        [RANK_TYPE.PET_SPEED] = 4,
        [RANK_TYPE.PET_DEF] = 5,

        [RANK_TYPE.EQUIP_LEVEL_ONE] = 1,
        [RANK_TYPE.EQUIP_LEVEL_TWO] = 2,
        [RANK_TYPE.EQUIP_LEVEL_THREE] = 3,
        [RANK_TYPE.EQUIP_LEVEL_FOUR] = 4,
        [RANK_TYPE.EQUIP_LEVEL_FIVE] = 5,
        [RANK_TYPE.EQUIP_LEVEL_SIX] = 6,

        [RANK_TYPE.GUARD_PHY_POWER] = 1,
        [RANK_TYPE.GUARD_MAG_POWER] = 2,
        [RANK_TYPE.GUARD_SPEED] = 3,
        [RANK_TYPE.GUARD_DEF] = 4,

        [RANK_TYPE.PARTY_MONEY] = 1,
        [RANK_TYPE.PARTY_WAR] = 2,
        [RANK_TYPE.PARTY_WELFARE] = 3,

        [RANK_TYPE.GET_TAO_CHUBAO] = 1,
        [RANK_TYPE.GET_TAO_XIANGYAO] = 2,
        [RANK_TYPE.GET_TAO_FUMO] = 3,

        [RANK_TYPE.CHALLENGE_ARENA] = 1,
        [RANK_TYPE.CHALLENGE_TOWER] = 2,
        [RANK_TYPE.CHALLENGE_DART] = 3,
        [RANK_TYPE.CHALLENGE_PET] = 4,
    }

-- 表格的默认宽高
local DEFAULT_GRID_WIDTH = 30
local DEFAULT_GRID_HEIGHT = 30

-- 行的默认宽度
local ROW_WIDTH = 433

function RankingListDlg:init()
  --  self:bindListViewListener("CategoryListView", self.onSelectCategoryListView)
    self:bindTouchPanel()
    self:cleanMyRanking()
    self.listView = self:getControl('RankingListView', Const.UIListView, "RankingPanel")
    local size = self.listView:getInnerContainerSize()
    size.height = 450
    self.listView:setInnerContainerSize(size)

    self.myRank = 0
    self.rankPetInfo = {}   -- 记录宠物排行榜上所有Me上榜的宠物。怕玩家把宠物卖了等...

    -- 分等级显示的按钮
    self:bindListener("70Panel", self.onTao70LevelButton, "LevelRankingPanel")
    self:bindListener("80Panel", self.onTao80LevelButton, "LevelRankingPanel")
    self:bindListener("90Panel", self.onTao90LevelButton, "LevelRankingPanel")
    self:bindListener("100Panel", self.onTao100LevelButton, "LevelRankingPanel")
    self:bindListener("110Panel", self.onTao110LevelButton, "LevelRankingPanel")
    self:bindListener("120Panel", self.onTao120LevelButton, "LevelRankingPanel")

        self:bindListener("70Panel", self.onTao70LevelButton, "HeroRankingPanel")
    self:bindListener("80Panel", self.onTao80LevelButton, "HeroRankingPanel")
    self:bindListener("90Panel", self.onTao90LevelButton, "HeroRankingPanel")
    self:bindListener("100Panel", self.onTao100LevelButton, "HeroRankingPanel")
    self:bindListener("110Panel", self.onTao110LevelButton, "HeroRankingPanel")
    self:bindListener("120Panel", self.onTao120LevelButton, "HeroRankingPanel")

    -- 道行、通天塔，等级段在title行显示
    self:setTaoLevelByType("close")
    self:setTaoLevelByType("close", nil, "HeroRankingPanel")
    self:bindListener("LevelTouchPanel", self.onOpenLevelButton, "LevelRankingPanel")
    self:bindListener("LevelTouchPanel", self.onOpenLevelButton, "HeroRankingPanel")

    -- 设置互斥按钮
    self.norRadioGroup = RadioGroup.new()
    self.norRadioGroup:setItems(self, { "WeaponCheckBox", "HelmetCheckBox", "ArmorCheckBox", "BootCheckBox" }, self.onEquipCheckBox)

    -- 开启上次默认打开的界面   暂时不需要记录上一次功能
    local rankType,subType  -- =  RankMgr:getLastSelectRankTypeAndSubType()

    local place = RankMgr:getOpenByPlace()
    if place == "arena" then
        rankType = RANK_TYPE.CHALLENGE
        subType = RANK_TYPE.CHALLENGE_ARENA
        RankMgr:setOpenByPlace(nil)
    elseif place == "petStruggle" then
        rankType = RANK_TYPE.CHALLENGE
        subType = RANK_TYPE.CHALLENGE_PET
        RankMgr:setOpenByPlace(nil)
    end

    if rankType == nil  then
        rankType = RANK_TYPE.CHAR
        subType = RANK_TYPE.CHAR_LEVEL

        if GameMgr:IsCrossDist() then
            -- 跨服试道中默认选择个人排行榜->道行排行榜
            subType = RANK_TYPE.CHAR_TAO
        end
    end

    -- 获取排行榜我的信息
    RankMgr:queryMeRankInfo()

    -- 光效
    self.selectEff = self:getControl("SelectedImage"):clone()
    self.selectEff:setVisible(true)
    self.selectEff:retain()

    self.bigSelectEff = self:getControl("BChosenEffectImage"):clone()
    self.bigSelectEff:setVisible(true)
    self.bigSelectEff:retain()

    local rankingPanel = self:getControl("RankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, rankingPanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, rankingPanel), ITEM_PANEL_NORMAL)

    local levelRankingPanel = self:getControl("LevelRankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, levelRankingPanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, levelRankingPanel), RANK_TYPE.CHAR_TAO)

    local equipPanel = self:getControl("LevelEquipmentRankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, equipPanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, equipPanel), RANK_TYPE.EQUIP)

    local petPanel = self:getControl("PetRankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, petPanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, petPanel), RANK_TYPE.PET)

    local partyPanel = self:getControl("PartyRankingPanel")
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, partyPanel), RANK_TYPE.PARTY)


    local heroPanel = self:getControl("HeroRankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, heroPanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, heroPanel), RANK_TYPE.ZDD)

    local housePanel = self:getControl("HouseRankingPanel")
    self:bindListViewListener("RankingListView", self.onSelectRankingListView, self.onLongSelectRankingListView, housePanel)
    self:registerItemPanel(self:getControl('MyRankingPanel1', Const.UIPanel, housePanel), RANK_TYPE.HOUSE)
    housePanel:setVisible(false)
    self:setCtrlVisible("MyRankingPanel", false, "HouseRankingPanel")
    self:setCtrlVisible("NoRankTipPanel", true, "HouseRankingPanel")

    self.bigPanel = self:retainCtrl('BigPanel')

    self.sPanel = self:retainCtrl('SPanel')


    self.listView:removeAllItems()
    local listView1 = self:getControl("RankingListView", Const.UIListView, "LevelRankingPanel")
    listView1:removeAllItems()

    local listView2 = self:getControl("RankingListView", Const.UIListView, "LevelEquipmentRankingPanel")
    listView2:removeAllItems()

    self.listRows = {}
    self:initInfoList(100, 5)
    self.startIndex = 1
    self.info = {}
    self.infoType = nil
    self:hookMsg('MSG_TOP_USER')
    self:hookMsg('MSG_RANK_CLIENT_INFO')
    self:hookMsg('MSG_CHAR_INFO')
    self:hookMsg('MSG_MY_RANK_INFO')
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")

    self.curMainType = nil
    self:setRankTypeList(rankType, subType)
    self.dirty = false

    -- 判断是否有排行榜列表数据过来
    self.haveList = false

    self:initShareBtn()
end

-- 关闭道行、通天塔，等级段
function RankingListDlg:closeTaoLevelListPanel()
    self:setTaoLevelByType("close")
end

-- 设置道行、通天塔，等级段状态
-- type = open, type = close
-- 有index时，表示需要刷新表头
function RankingListDlg:setTaoLevelByType(type, index, panelName)
    self.isLevelOpen = type == "open"

    panelName = panelName or "LevelRankingPanel"

    self:setCtrlVisible("ExpandImage", not self.isLevelOpen, panelName)
    self:setCtrlVisible("ShakeImage", self.isLevelOpen, panelName)
    self:setCtrlVisible("LevelListPanel", self.isLevelOpen, panelName)
    if index then
        self:refreshTitleByIndex(index, panelName)
    end
end

-- 点击道行、通天塔，等级段
function RankingListDlg:onOpenLevelButton(sender, eventType)
    if self.isLevelOpen then
        self:setTaoLevelByType("close", nil, sender:getParent():getParent():getName())
    else
        self:setTaoLevelByType("open", nil, sender:getParent():getParent():getName())
    end
end

function RankingListDlg:initShareBtn()
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("RankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("LevelEquipmentRankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("LevelRankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("PartyRankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("PetRankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("HouseRankingPanel")), SHARE_FLAG.RANKING)
    self:createShareButton(self:getControl("ShareButton", Const.UIPanel, self:getControl("HeroRankingPanel")), SHARE_FLAG.RANKING)
end

-- 增加选中光效一级菜单
function RankingListDlg:addOneSelectEffect(sender)
    self.bigSelectEff:removeFromParent()
    if sender then
        sender:addChild(self.bigSelectEff)
    end
end

-- 增加选中光效
function RankingListDlg:addSelectEffect(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

-- 装备和其他的不一样
function RankingListDlg:getUsePanelName()
    self:setCtrlVisible("RankingPanel", false)
    self:setCtrlVisible("LevelEquipmentRankingPanel", false)
    self:setCtrlVisible("LevelRankingPanel", false)
    self:setCtrlVisible("PartyRankingPanel", false)
    self:setCtrlVisible("HouseRankingPanel", false)
    self:setCtrlVisible("PetRankingPanel", false)
    self:setCtrlVisible("HeroRankingPanel", false)
    if not self.curType then
        self:getControl("RankingPanel"):setVisible(true)
        return "RankingPanel"
    elseif self:getMainType() == RANK_TYPE.EQUIP then
        self:setCtrlVisible("LevelEquipmentRankingPanel", true)
        return "LevelEquipmentRankingPanel"
    elseif self.curType == RANK_TYPE.CHAR_TAO or self.curType == RANK_TYPE.CHAR_MONTH_TAO then
        self:setCtrlVisible("LevelRankingPanel", true)
        return "LevelRankingPanel"
    elseif self.curType == RANK_TYPE.CHALLENGE_TOWER then
        self:setCtrlVisible("LevelRankingPanel", true)
        return "LevelRankingPanel"
    elseif self:getMainType() == RANK_TYPE.PARTY then
        self:setCtrlVisible("PartyRankingPanel", true)
        return "PartyRankingPanel"
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        self:setCtrlVisible("HouseRankingPanel", true)
        return "HouseRankingPanel"
    elseif self:getMainType() == RANK_TYPE.PET then
        self:setCtrlVisible("PetRankingPanel", true)
        return "PetRankingPanel"
    elseif self:getMainType() == RANK_TYPE.ZDD then
        self:setCtrlVisible("HeroRankingPanel", true)
        return "HeroRankingPanel"
    elseif self.curType == RANK_TYPE.HERO then
        self:setCtrlVisible("HeroRankingPanel", true)
        return "HeroRankingPanel"
    else
        self:getControl("RankingPanel"):setVisible(true)
        return "RankingPanel"
    end
end

-- 登记每个排行榜用到的itemPanel
function RankingListDlg:registerItemPanel(ctrl, rankType)
    if nil == ctrl or nil == rankType then return end
    rankTypeItemPanel[rankType] = ctrl
    ctrl:retain()
    ctrl:removeFromParent()
end

-- 获取每个登记排行榜需要用到的itemPanel
function RankingListDlg:getUseItemPanel(rankType)
    if not rankType then return end

    if rankType == RANK_TYPE.CHAR and (self.curType == RANK_TYPE.CHAR_TAO or self.curType == RANK_TYPE.CHAR_MONTH_TAO) or
        rankType == RANK_TYPE.CHALLENGE and self.curType == RANK_TYPE.CHALLENGE_TOWER then
        -- 通天塔，道行需要特殊处理，使用的itemPanel不同于该类别所处大类下的排行榜
        return rankTypeItemPanel[RANK_TYPE.CHAR_TAO]
    end

    if rankType == RANK_TYPE.HERO then
        return rankTypeItemPanel[RANK_TYPE.ZDD]
    end

    local itemPanel = rankTypeItemPanel[rankType]
    if nil == itemPanel then
        return rankTypeItemPanel[ITEM_PANEL_NORMAL]
    end

    return itemPanel
end

function RankingListDlg:cleanMyRanking()
    local panel
    if not self.curType then
        panel = self:getControl("MyRankingPanel")
    elseif self:getMainType() == RANK_TYPE.EQUIP then
        panel = self:getControl("LevelEquipmentRankingPanel")
    elseif self:getMainType() == RANK_TYPE.PARTY then
        panel = self:getControl("PartyRankingPanel")
    elseif self.curType == RANK_TYPE.CHAR_TAO or self.curType == RANK_TYPE.CHAR_MONTH_TAO or self.curType == RANK_TYPE.CHALLENGE_TOWER then
        panel = self:getControl("LevelRankingPanel")
    elseif self:getMainType() == RANK_TYPE.PET then
        panel = self:getControl("PetRankingPanel")
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        panel = self:getControl("HouseRankingPanel")
    else
        panel = self:getControl("MyRankingPanel")
    end

    if not panel then return end
    local myRankPanel = self:getControl("MyRankingPanel", nil, panel)
    self:setLabelText("AttributeLabel1", "", myRankPanel)
    self:setLabelText("AttributeLabel2", "", myRankPanel)
    self:setLabelText("AttributeLabel3", "", myRankPanel)
    self:setLabelText("AttributeLabel4", "", myRankPanel)
    self:setLabelText("AttributeLabel5", "", myRankPanel)
end

function RankingListDlg:cleanup()
    self.haveList = false
    if self.listRows then
        for i = 1, #self.listRows do
            if self.listRows[i] then
                self.listRows[i]:release()
                self.listRows[i] = nil
            end
        end
    end

    self:releaseCloneCtrl("selectEff")
    self:releaseCloneCtrl("bigSelectEff")

    for _, ctrl in pairs(rankTypeItemPanel) do
        ctrl:release()
    end

    rankTypeItemPanel = {}

    self.curSelectItem = nil
    self.menuInfo = nil
    RankMgr:setLastSearchLevel()
    RankMgr:setLastSearchEquip()

    self.myRankPetId = nil
end

-- 初始化列表
function RankingListDlg:initInfoList(rows, cols)
    self.listRows = {}
    for i = 1, rows do
        local item = TableRow.new(DEFAULT_GRID_WIDTH, DEFAULT_GRID_HEIGHT, cols)
        item:setTag(i)
        item:retain()
        table.insert(self.listRows, item)
    end
end

-- 获取主类别
function RankingListDlg:getMainType()
    if not self.curType then return end

    if self.curType < 100 then
        return self.curType
    end

    return math.floor(self.curType / 100)
end

-- 设置排行列表
function RankingListDlg:setRankTypeList(showType, subType)
    self:setMenuList("CategoryListView", ONE_MENU, self.bigPanel, SECOND_MENU, self.sPanel, self.onOneMenu, self.onOneMenu, {
        one = showType and RANK_TYPE_NAMES[showType],
        two = subType and RANK_TYPE_NAMES[subType],
        isScrollToDef = true,
    })
end

-- 创建排行类型项
function RankingListDlg:createRankTypeItem(rankType, isBig)
    local item = self.sPanel
    if isBig then
        item = self.bigPanel
    end

    item = item:clone()
    item:setTag(rankType)
    self:setLabelText('Label', RANK_TYPE_NAMES[rankType], item)
    return item
end

-- 获取指定的排行信息
function RankingListDlg:fetchRankInfo(rankType, minLevel, maxLevel, index, equipType)
    self.haveList = false
    self.curType = rankType
    self.myRank = 0
    if equipType then
        RankMgr:fetchRankInfo(equipType, minLevel, maxLevel)
    else
    RankMgr:fetchRankInfo(rankType, minLevel, maxLevel)
    end
end

-- 设置相应的案件位置
function RankingListDlg:setCurCheckBox(equipType)
    if equipType then
        local index = equipType % 100
            self.norRadioGroup:selectRadio(index, true)
        end
end

function RankingListDlg:getTAOtime(time)
    local min = math.floor(time / 60)
    local sec = math.floor(time % 60)
    if min > 999 then
        return CHS[3003546]
    else
        return string.format(CHS[3003547], min, sec)
    end
end

function RankingListDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel", Const.UIPanel)
    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        if not panel:isVisible() then
            return false
        end

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        --Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        local percent = 0
        if self:getCtrlVisible("RankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "RankingPanel")
        elseif self:getCtrlVisible("LevelRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "LevelRankingPanel")
        elseif self:getCtrlVisible("LevelEquipmentRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "LevelEquipmentRankingPanel")
        elseif self:getCtrlVisible("PartyRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "PartyRankingPanel")
        elseif self:getCtrlVisible("PetRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "PetRankingPanel")
        elseif self:getCtrlVisible("HouseRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "HouseRankingPanel")
        elseif self:getCtrlVisible("HeroRankingPanel") then
            percent = self:getCurScrollPercent("RankingListView", true, "HeroRankingPanel")
        end

        Log:D("The percent is %d%%", percent)

        if percent > 100 then
            -- 加载
            local info
            if RankMgr:isEquipLevelType(self.curType) then
                info = RankMgr:getRankListByType(RankMgr:getLastSearchEquip(), self.minLevel, self.maxLevel, self.startIndex, PER_PAGE_NUM)
            else
                info = RankMgr:getRankListByType(self.curType, self.minLevel, self.maxLevel, self.startIndex, PER_PAGE_NUM)
            end

            if not info or info.count == 0 then
                -- 暂无数据
                gf:ShowSmallTips(CHS[3003548])
                return
            end
            self:pushBackData(info)
        end
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)

end

-- 显示指定的排行信息
function RankingListDlg:showRankInfo(minLevel, maxLevel)
    -- 设置表头信息
    self:setListTitle()

    -- 清空已有数据

    local panel = self:getControl(self:getUsePanelName())

    self.listView = self:getControl("RankingListView", Const.UIListView, panel)
    self.listView:removeAllItems()

    self.listView:doLayout()
    self.listView:refreshView()

    -- 玩家检测是否上榜需要前100条数据
    local forMeCheckInfo
    if RankMgr:isEquipLevelType(self.curType) then
        forMeCheckInfo = RankMgr:getRankListByType(RankMgr:getLastSearchEquip(), self.minLevel, self.maxLevel, 1, 100)
    else
        forMeCheckInfo = RankMgr:getRankListByType(self.curType, self.minLevel, self.maxLevel, 1, 100)
    end

    self:checkMyRank(forMeCheckInfo)

    -- 排行榜每次加载10条数据
    local info
    if RankMgr:isEquipLevelType(self.curType) then
        info = RankMgr:getRankListByType(RankMgr:getLastSearchEquip(), self.minLevel, self.maxLevel, self.startIndex, PER_PAGE_NUM)
    else
        info = RankMgr:getRankListByType(self.curType, self.minLevel, self.maxLevel, self.startIndex, PER_PAGE_NUM)
    end

    if not info or info.count == 0 then
        -- 暂无数据
        gf:ShowSmallTips(CHS[3003549])
        self.listView:setVisible(false)
        self:setCtrlVisible("NoticePanel", true, panel)
        return
    else
        self.listView:setVisible(true)
        self:setCtrlVisible("NoticePanel", false, panel)
    end

    self.minLevel = minLevel
    self.maxLevel = maxLevel
    self:pushBackData(info)
end

function RankingListDlg:getHeroDisplayTime(ti)
    local retStr = ""

    if ti == 0 then return CHS[5000059] end

    if ti < 60 then
        return string.format(CHS[4010041], 1)
    else
        local min = math.ceil( (ti % 3600) / 60 )
        if min == 60 then
            ti = ti + 60
            min = 0
        end

        local minStr = min == 0 and "" or string.format(CHS[4010041], min)

        local days = math.floor(ti / 86400 ) -- 60 * 60 *24
        local daysStr = days == 0 and "" or string.format(CHS[34050], days)

        local hours = math.floor((ti % 86400) / 3600)
        local hoursStr = hours == 0 and "" or string.format(CHS[4100093], hours)

        return daysStr .. hoursStr .. minStr
    end
end

-- 获取排行榜列表最后一位
function RankingListDlg:getDataMaxIndex(info)
    if not info or #info == 0 then
        return 0
    end

    return info[#info].sortIdx
end

-- 设置排行榜列表信息
function RankingListDlg:pushBackData(info)
    if self:getDataMaxIndex(info) == 0 then return end

    -- 添加相应的数据
    local lastIndex = 0
    local height = self:getUseItemPanel(ITEM_PANEL_NORMAL):getContentSize().height
    if self.startIndex > 10 then
        lastIndex = self.startIndex
    end

    self.startIndex = self.startIndex + #info

    local fieldInfo = RANK_TYPE_FIELD_INFO[self.curType]
    local colWidthInfo = RANK_TYPE_COL_WIDTH[self.curType]
    local myRank = 0
    local myName = Me:getName()
    local myGid  = Me:queryBasic("gid")
    local function setSingleInfo(i, panel)
        -- 排名
        self:setLabelText("AttributeLabel1", i, panel)
        for j = 1, #fieldInfo do
            local str = info[i][fieldInfo[j]]
            if fieldInfo[j] == "owner_name" and
                (self:getMainType() == RANK_TYPE.PET
                    or self:getMainType() == RANK_TYPE.EQUIP
                    or self:getMainType() == RANK_TYPE.GUARD) then
                if fieldInfo[j] == "owner_name" then
                    str = gf:getRealName(str)
                end
            elseif fieldInfo[j] == "name" and
                (self:getMainType() == RANK_TYPE.CHAR
                    or self:getMainType() == RANK_TYPE.PK
                    or self:getMainType() == RANK_TYPE.CHALLENGE
                    or self:getMainType() == RANK_TYPE.GET_TAO) then
                str = gf:getRealName(str)
            end

			-- 如果是宠物排行，过滤<地图>
            if self:getMainType() == RANK_TYPE.PET and fieldInfo[j] == "name" then str = PetMgr:trimPetRawName(str) end
            if self:getMainType() == RANK_TYPE.PARTY and fieldInfo[j] == "level" then str = PartyMgr:getCHSLevelAndPeopleMax(str) end

            if fieldInfo[j] == "" then
            elseif fieldInfo[j] == 'higest_chub' then
                self:setLabelText("AttributeLabel" .. j, self:getTAOtime(str) .. CHS[3003550], panel)
            elseif fieldInfo[j] == 'higest_xiangy' then
                self:setLabelText("AttributeLabel" .. j, self:getTAOtime(str) .. CHS[3003550], panel)
            elseif fieldInfo[j] == 'higest_fum' then
                self:setLabelText("AttributeLabel" .. j, self:getTAOtime(str) .. CHS[3003550], panel)
            elseif fieldInfo[j] == 'higest_feixdx' then
                self:setLabelText("AttributeLabel" .. j, self:getTAOtime(str) .. CHS[3003550], panel)
            elseif fieldInfo[j] == 'higest_yasby' then
                self:setLabelText("AttributeLabel" .. j, self:getTAOtime(str), panel)
            elseif fieldInfo[j] == 'rebuild_level' then
                self:setLabelText("AttributeLabel" .. j, string.format(CHS[3003551], str), panel)
            elseif fieldInfo[j] == 'party' then
                if str == "" then str = CHS[3003552] end
                self:setLabelText("AttributeLabel" .. j, str, panel)
            elseif fieldInfo[j] == "polar" then
                local polarStr = gf:getPolar(tonumber(str))
                self:setLabelText("AttributeLabel" .. j, polarStr, panel)
            elseif fieldInfo[j] == 'family' then
                local polarStr = gf:getPolarByFamily(str)
                if polarStr == "" or nil == polarStr then polarStr = CHS[3003552] end
                self:setLabelText("AttributeLabel" .. j, polarStr, panel)
            elseif fieldInfo[j] == 'tao' then
                self:setLabelText("AttributeLabel" .. j, gf:getTaoStr(info[i][fieldInfo[j]], info[i].tao_ex), panel)
            elseif fieldInfo[j] == 'mon_tao' then
                self:setLabelText("AttributeLabel" .. j, gf:getTaoStr(info[i][fieldInfo[j]], info[i].mon_tao_ex), panel)
            elseif fieldInfo[j] == 'equip_perfect_percent' then
                self:setLabelText("AttributeLabel" .. j, (tonumber(str) / 100) .. '%', panel)
            elseif fieldInfo[j] == 'house_type' then
                self:setLabelText("AttributeLabel" .. j, HomeMgr:getHomeTypeCHS(str), panel)
            elseif fieldInfo[j] == "couple_name" then
                self:setLabelText("AttributeLabel" .. j, string.isNilOrEmpty(str) and CHS[2200060] or str, panel)
            elseif fieldInfo[j] == "gender" then
                self:setLabelText("AttributeLabel" .. j, gf:getGenderChs(str), panel)
            elseif fieldInfo[j] == 'higest_score' then
                self:setLabelText("AttributeLabel" .. j, self:getHeroDisplayTime(str), panel)
            else
                self:setLabelText("AttributeLabel" .. j, str, panel)
            end
        end
    end

    table.sort(info, function(l, r) return l.sortIdx < r.sortIdx end)
    local innerContainer = self.listView:getInnerContainerSize()
    innerContainer.height = self.startIndex * height
    self.listView:setInnerContainerSize(innerContainer)

    for k, v in pairs(info) do
        table.insert(self.info, v)
        local i = v.sortIdx
        local rowPanel
        if self.curType == RANK_TYPE.HERO then
            rowPanel = self:getUseItemPanel(self.curType):clone()
        else
            rowPanel = self:getUseItemPanel(self:getMainType()):clone()
        end

        rowPanel:setTag(i)
        for j = 1, #fieldInfo do
            setSingleInfo(k, rowPanel)
        end
        self:setLabelText("AttributeLabel1", i, rowPanel)

        if i % 2 == 0 then
            self:setCtrlVisible("BackImage1", false, rowPanel)
            self:setCtrlVisible("BackImage2", true, rowPanel)
        else
            self:setCtrlVisible("BackImage1", true, rowPanel)
            self:setCtrlVisible("BackImage2", false, rowPanel)
        end

        self.listView:pushBackCustomItem(rowPanel)

        -- 我上榜了
        if self:getMainType() == RANK_TYPE.PARTY then
            if myRank == 0 and info[k].name == Me:queryBasic("party/name") then
                myRank = i
            end
        end
        if info[k].owner_name == myName or info[k].name == myName or info[k].gid == myGid then
            if myRank == 0 then
                myRank = i
            end
        end

        if lastIndex ~= 0 then
            self:jumpToItem(height * lastIndex)
        end
    end

    self.listView:requestRefreshView()
end

-- 检查我在排行榜的哪个位置（然后进行设置我的排行）
function RankingListDlg:checkMyRank(info)
    local myRank = 0
    local inRankItemInfo = nil
    local myName = Me:getName()
    local myGid  = Me:queryBasic("gid")
    if not info then
        -- 排行榜数据为空
        info = {}
    end

    table.sort(info, function(l, r) return l.sortIdx < r.sortIdx end)

    if self:getMainType() == RANK_TYPE.PET then self.rankPetInfo[self.curType] = {} end
        for k, v in pairs(info) do
            local i = v.sortIdx

            -- 我上榜了
            if self:getMainType() == RANK_TYPE.PARTY then
                if myRank == 0 and info[k].name == Me:queryBasic("party/name") then
                    myRank = i
                    break
                end
            elseif self:getMainType() == RANK_TYPE.HOUSE then
                if myRank == 0 and (info[k].owner_name == myName or info[k].couple_name == myName or info[k].gid == myGid or info[k].couple_gid == myGid) then
                    myRank = i
                    inRankItemInfo = info[k]
                    break
                end
            elseif self:getMainType() == RANK_TYPE.PET then
                -- 如果是宠物排行榜，把所有Me上榜的记录下来
                if info[k].owner_name == myName then
                    table.insert(self.rankPetInfo[self.curType], info[k])
                end

                -- WDSY-24206，宠物排行榜，角色名可能与宠物名相同
                -- 只能通过宠物拥有者的gid与角色gid相同才能认为当前角色上榜
                if myRank == 0 and info[k].gid == myGid then
                    myRank = i
                    inRankItemInfo = info[k]
                    break
                end
            else
            if (info[k].owner_name and info[k].owner_name == myName) or (not info[k].owner_name and info[k].name == myName) or info[k].gid == myGid then
                if myRank == 0 then
                    myRank = i
                    inRankItemInfo = info[k]
                end
            end
        end
    end

    -- 设置我的排行
    self:setMyFight(myRank, inRankItemInfo)
end

function RankingListDlg:jumpToItem(offsetY)
    local contentSize = self.listView:getContentSize()
    local innerContainer = self.listView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height;
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end
    local x,y = innerContainer:getPosition()
    local pos = cc.p(x, offsetY)
    innerContainer:setPosition(pos)
end

-- 设置我的排行（排行榜列表最下面固定的一行，即显示自己信息的一行）
function RankingListDlg:setMyFight(myRank, inRankItemInfo)
    -- 若此时Me的数据还没有收到，则返回
    if not RankMgr.meInfo then return end
    self.myRank = myRank

    local panel = self:getControl("RankingPanel")
    if self:getMainType() == RANK_TYPE.EQUIP then
        panel = self:getControl("LevelEquipmentRankingPanel")
    elseif self:getMainType() == RANK_TYPE.PARTY then
        panel = self:getControl("PartyRankingPanel")
    elseif self.curType == RANK_TYPE.CHAR_TAO or self.curType == RANK_TYPE.CHAR_MONTH_TAO or self.curType == RANK_TYPE.CHALLENGE_TOWER then
        panel = self:getControl("LevelRankingPanel")
    elseif self:getMainType() == RANK_TYPE.PET then
        panel = self:getControl("PetRankingPanel")
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        panel = self:getControl("HouseRankingPanel")
    end


    local myRankPanel = self:getControl("MyRankingPanel", Const.UIPanel, panel)
    myRankPanel.info = inRankItemInfo

    local function setMyRanking(str1, str2, str3, str4, str5)
        local rankStr = str1
        if str1 == 0 then
            rankStr = CHS[3003553]
        end

        if self.curType == RANK_TYPE.CHAR_TAO then
            local myLevel = Me:queryInt("level")
            if self.minLevel and myLevel >= self.minLevel and self.maxLevel and myLevel <= self.maxLevel then
                if  RankMgr.meInfo.info.tao_rank == 0 then
                    rankStr = CHS[3003553]
                else
                    rankStr = RankMgr.meInfo.info.tao_rank
                end
            else
                rankStr = CHS[3003553]
            end
        elseif self.curType == RANK_TYPE.CHAR_MONTH_TAO then
            local myLevel = Me:queryInt("level")
            if self.minLevel and myLevel >= self.minLevel and self.maxLevel and myLevel <= self.maxLevel then
                if  RankMgr.meInfo.info.mon_tao_rank == 0 then
                    rankStr = CHS[3003553]
                else
                    rankStr = RankMgr.meInfo.info.mon_tao_rank
                end
            else
                rankStr = CHS[3003553]
            end
        elseif self.curType == RANK_TYPE.GET_TAO_XIANGYAO then
            local myLevel = Me:queryInt("level")
            if str1 == 0 and myLevel >= 80 then
                rankStr = CHS[3003552]
            end

        elseif self.curType == RANK_TYPE.GET_TAO_FUMO then
            local myLevel = Me:queryInt("level")
            if str1 == 0 and myLevel >= 120 then
                rankStr = CHS[3003552]
            end
        end

        self:setLabelText("AttributeLabel1", rankStr, myRankPanel)
        self:setLabelText("AttributeLabel2", str2, myRankPanel)
        self:setLabelText("AttributeLabel3", str3, myRankPanel)
        self:setLabelText("AttributeLabel4", str4, myRankPanel)
        self:setLabelText("AttributeLabel5", str5, myRankPanel)
    end

    local fieldInfo = RANK_TYPE_FIELD_INFO[self.curType]
    if self:getMainType() == RANK_TYPE.CHAR then
        local part = Me:queryBasic("party/name")
        if part == "" then part = CHS[3003552] end
        local family = Me:queryBasic("polar")
        family = gf:getPolar(tonumber(family))
        if family == "" or nil == family then family = CHS[3003552] end
        local str5 = ""
        local level = Me:queryBasicInt("level")
        if self.curType == RANK_TYPE.CHAR_LEVEL then
            str5 = part
        elseif self.curType == RANK_TYPE.CHAR_TAO then
            str5 = gf:getTaoStr(Me:queryBasicInt("tao"), Me:queryBasicInt("tao_ex"))
        elseif self.curType == RANK_TYPE.CHAR_MONTH_TAO then
            str5 = gf:getTaoStr(Me:queryBasicInt("mon_tao"), Me:queryBasicInt("mon_tao_ex"))
        elseif self.curType == RANK_TYPE.CHAR_PHY_POWER then
            if myRank > 0 then str5 = inRankItemInfo.phy_power end
        elseif self.curType == RANK_TYPE.CHAR_MAG_POWER then
            if myRank > 0 then str5 = inRankItemInfo.mag_power end
        elseif self.curType == RANK_TYPE.CHAR_SPEED then
            if myRank > 0 then str5 = inRankItemInfo.speed end
        elseif self.curType == RANK_TYPE.CHAR_DEF then
            if myRank > 0 then str5 = inRankItemInfo.def end
        elseif self.curType == RANK_TYPE.CHAR_UPGRADE_LEVEL then
            level = Me:queryBasicInt("upgrade/level")
            str5 = part
        end

        setMyRanking(myRank, Me:getShowName(), level, family, str5)
    elseif self:getMainType() == RANK_TYPE.PARTY then
        local part = Me:queryBasic("party/name")
        if part == "" then part = CHS[3003552] end
        local level = RankMgr.meInfo.info[fieldInfo[3]]
        setMyRanking(myRank, part, PartyMgr:getCHSLevelAndPeopleMax(level), RankMgr.meInfo.info[fieldInfo[4]], RankMgr.meInfo.info[fieldInfo[5]])
    elseif self:getMainType() == RANK_TYPE.CHALLENGE then
        local part = gf:getPolar(tonumber(Me:queryBasic("polar")))
        if part == "" then part = CHS[3003552] end
        if self.curType == RANK_TYPE.CHALLENGE_DART then
            local time = RankMgr.meInfo.info[fieldInfo[5]]
            local timeStr = ""
            if 0 >= time then
                timeStr = CHS[3003552]
            else
                timeStr = self:getTAOtime(RankMgr.meInfo.info[fieldInfo[5]])
            end
            setMyRanking(myRank, Me:getShowName(), Me:queryBasic("level"), part, timeStr)
        else
            setMyRanking(myRank, Me:getShowName(), Me:queryBasic("level"), part, RankMgr.meInfo.info[fieldInfo[5]])
        end
    elseif self:getMainType() == RANK_TYPE.GET_TAO then
        local family = Me:queryBasic("polar")
        family = gf:getPolar(tonumber(family))
        if family == "" or nil == family then family = CHS[3003552] end
        local time = RankMgr.meInfo.info[fieldInfo[5]]
        local timeStr = ""
        if 0 >= time then
            timeStr = CHS[3003552]
        else
            timeStr = self:getTAOtime(time) .. CHS[3003550]
        end

        setMyRanking(myRank, Me:getShowName(), Me:queryBasic("level"), family, timeStr)
    elseif self:getMainType() == RANK_TYPE.PET then
        if inRankItemInfo then
            -- 如果我上榜了，有数据
            setMyRanking(myRank, inRankItemInfo.name, inRankItemInfo.level, Me:getShowName(), inRankItemInfo[fieldInfo[5]])
        else
            if PetMgr:getPetCount() == 0 then
                setMyRanking(myRank, CHS[3003552], "0", Me:getShowName(), "0")
            end
        end
    elseif self:getMainType() == RANK_TYPE.GUARD then
        local ob = GuardMgr:getFightKingPet(fieldInfo[5])
        if ob == nil then
            setMyRanking(myRank, CHS[3003552], "0", Me:getShowName(), "0")
            return
        end
        local fieldInfo = RANK_TYPE_FIELD_INFO[self.curType]

        setMyRanking(myRank, ob:queryBasic('raw_name'), ob:queryBasic("level"), Me:getShowName(), ob:queryInt(fieldInfo[5]))
    elseif self:getMainType() == RANK_TYPE.EQUIP then
        if myRank ~= 0 and inRankItemInfo then
            -- 我的装备上榜了，取榜上的数据
            setMyRanking(myRank, inRankItemInfo.name, string.format(CHS[3003551], inRankItemInfo.rebuild_level), Me:getShowName(), (inRankItemInfo.equip_perfect_percent / 100) .. "%")
        else
            local equip
            if RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_WEAPON then
                equip = InventoryMgr:getPerfectEquip(EQUIP.WEAPON)
            elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_HELMET then
                equip = InventoryMgr:getPerfectEquip(EQUIP.HELMET)
            elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_ARMOR then
                equip = InventoryMgr:getPerfectEquip(EQUIP.ARMOR)
            elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_BOOT then
                equip = InventoryMgr:getPerfectEquip(EQUIP.BOOT)
            end

            if not equip then
                setMyRanking(CHS[3003553], CHS[3003552], 0, Me:getShowName(), 0)
            else
                setMyRanking(myRank, equip.name, string.format(CHS[3003551], equip.rebuild_level), Me:getShowName(), (equip.equip_perfect_percent / 100) .. "%")
            end
        end
    elseif self:getMainType() == RANK_TYPE.PK then
        local family = gf:getPolar(Me:queryBasicInt("polar"))
        if family == "" or nil == family then family = CHS[3003552] end
        setMyRanking(myRank, Me:getShowName(), Me:queryInt("level"), family, Me:queryInt(fieldInfo[5]))
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        local myHouseRank = RankMgr.myHouseRank
        if myHouseRank then
            self:setCtrlVisible("MyRankingPanel", true, "HouseRankingPanel")
            self:setCtrlVisible("NoRankTipPanel", false, "HouseRankingPanel")
            setMyRanking(myRank, myHouseRank.owner_name, string.isNilOrEmpty(myHouseRank.couple_name) and CHS[2200060] or myHouseRank.couple_name, HomeMgr:getHomeTypeCHS(myHouseRank.house_type), tostring(myHouseRank.comfort))
        else
            self:setCtrlVisible("MyRankingPanel", false, "HouseRankingPanel")
            self:setCtrlVisible("NoRankTipPanel", true, "HouseRankingPanel")
        end
    elseif self:getMainType() == RANK_TYPE.SYNTH then
        local family
        if self.curType == RANK_TYPE.SYNTH_BLOG_POPULAR then
            family = gf:getGenderChs(Me:queryBasicInt("gender"))
        else
            family = gf:getPolar(Me:queryBasicInt("polar"))
        if family == "" or nil == family then family = CHS[3003552] end
        end

        if inRankItemInfo then
            setMyRanking(myRank, Me:getShowName(), inRankItemInfo.level, family, inRankItemInfo[fieldInfo[5]])
        end
    end

    myRankPanel:setTag(self.curType)
    self:bindTouchEndEventListener(myRankPanel, self.myRankPanelButton)
end

-- 在排行榜显示自己信息的那一行点击事件的响应
function RankingListDlg:myRankPanelButton(sender, eventType)
    local tag = sender:getTag()
    if self:getMainType() == RANK_TYPE.CHAR then
    elseif self:getMainType() == RANK_TYPE.PARTY then

    elseif self:getMainType() == RANK_TYPE.CHALLENGE then

    elseif self:getMainType() == RANK_TYPE.GET_TAO then

    elseif self:getMainType() == RANK_TYPE.PET then
        if self.myRank ~= 0 and sender.info then
            -- 我上榜了，向服务器请求
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHOW_RANK_PET, sender.info.iid_str)
            return
        else
            local pet
            if self.myRankPetId then
                pet = PetMgr:getPetById(self.myRankPetId)
            end

            if not pet then
                pet = PetMgr:getFightKingPet(RANK_TYPE_FIELD_INFO[self.curType][5])
            end

            if not pet then return end
            local dlg =  DlgMgr:openDlg("PetCardDlg")
            dlg:setPetInfo(pet, true)
        end
    elseif self:getMainType() == RANK_TYPE.GUARD then
        local ob = GuardMgr:getFightKingPet()
        if ob == nil then
            return
        end
        local dlg = DlgMgr:openDlg("GuardCardDlg")
        dlg:setGuardCardInfo(self:guardToCardData(ob))
    elseif self:getMainType() == RANK_TYPE.EQUIP then
        if self.myRank ~= 0 and sender.info then
            -- 我上榜了，向服务器请求
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_RANK_GET_EQUIP, sender.info.gid, sender.info.iid_str)
            return
        else
            local equipPanel = self:getControl("MyRankingPanel", Const.UIPanel, "LevelEquipmentRankingPanel")

            local equip
            if equipPanel.info and equipPanel.info.iid_str then

                local iidStr = string.match(equipPanel.info.iid_str,":(.+):") or equipPanel.info.iid_str
                equip = InventoryMgr:getItemByIIdFromBag(iidStr)
            else
                if RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_WEAPON then
                    equip = InventoryMgr:getPerfectEquip(EQUIP.WEAPON)
                elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_HELMET then
                    equip = InventoryMgr:getPerfectEquip(EQUIP.HELMET)
                elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_ARMOR then
                    equip = InventoryMgr:getPerfectEquip(EQUIP.ARMOR)
                elseif RankMgr:getLastSearchEquip() == RANK_TYPE.EQUIP_BOOT then
                    equip = InventoryMgr:getPerfectEquip(EQUIP.BOOT)
                end
            end

            if not equip then return end
            local dlg = DlgMgr:openDlg("EquipmentFloatingFrameDlg")
            equip = gf:deepCopy(equip)
            equip.pos = nil
            dlg:setFloatingFrameInfo(equip, true)
            dlg:align(ccui.RelativeAlign.centerInParent)
        end
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        if self.myRank ~= 0 and sender.info then
            if Me:queryBasic("house/id") == sender.info.house_id then
                HomeMgr:showHomeData(Me:queryBasic("gid"))
            else
                HomeMgr:showHomeData(sender.info.gid)
            end
        end
    end
end

-- 守护数据的转化成名片需要的数据
function RankingListDlg:guardToCardData(guard)
    local guardCardInfo = {}
    guardCardInfo["name"] = guard:queryBasic("name")
    guardCardInfo["raw_name"] = guard:queryBasic("raw_name")
    guardCardInfo["icon"] = guard:queryBasicInt("icon")
    guardCardInfo["polar"] = guard:queryBasicInt("polar")
    guardCardInfo["level"] = guard:queryBasicInt("level")
    guardCardInfo["max_life"] = guard:queryBasic("max_life")
    guardCardInfo["fight_score"] = guard:query("fight_score")
    guardCardInfo["phy_power"] = guard:query("phy_power")
    guardCardInfo["mag_power"] = guard:query("mag_power")
    guardCardInfo["speed"] = guard:query("speed")
    guardCardInfo["def"] = guard:query("def")
    guardCardInfo["con"] = guard:query("con")
    guardCardInfo["str"] = guard:query("str")
    guardCardInfo["wiz"] = guard:query("wiz")
    guardCardInfo["dex"] = guard:query("dex")
    guardCardInfo["metal"] = guard:query("metal")
    guardCardInfo["wood"] = guard:query("wood")
    guardCardInfo["water"] = guard:query("water")
    guardCardInfo["fire"] = guard:query("fire")
    guardCardInfo["earth"] = guard:query("earth")
    guardCardInfo["rebuild_level"] = guard:queryBasicInt("rebuild_level")
    guardCardInfo["rank"] = guard:queryBasicInt("rank")
    guardCardInfo["degree"] = guard:queryBasic("degree")
    guardCardInfo["develop_con"] = guard:queryBasic('grow_attrib')["con"]
    guardCardInfo["develop_str"] = guard:queryBasic('grow_attrib')["str"]
    guardCardInfo["develop_wiz"] = guard:queryBasic('grow_attrib')["wiz"]
    guardCardInfo["develop_dex"] = guard:queryBasic('grow_attrib')["dex"]
    guardCardInfo["weapon"] =  GuardMgr:getEquip(guard:queryBasicInt("id"), "weapon")
    guardCardInfo["helmet"] = GuardMgr:getEquip(guard:queryBasicInt("id"), "helmet")
    guardCardInfo["armor"] = GuardMgr:getEquip(guard:queryBasicInt("id"), "armor")
    guardCardInfo["boot"] = GuardMgr:getEquip(guard:queryBasicInt("id"), "boot")

    return guardCardInfo
end

-- 设置表头信息
function RankingListDlg:setListTitle()
    local titleInfo = RANK_TYPE_TITLE_INFO[self.curType]
    if not titleInfo then
        Log:W('Not found title info by rank type:' .. self.curType)
        return
    end

    local panel = self:getControl(self:getUsePanelName())


    for i = 1, #titleInfo do
        local titlePanel= self:getControl("RankingTitlePanel", nil, panel)
        for j = 1,5 do
            self:setLabelText("AttributeNameLabel" .. j, titleInfo[j], titlePanel)
        end

        if self.curType == RANK_TYPE.HERO or self.curType == RANK_TYPE.CHAR_TAO or self.curType == RANK_TYPE.CHAR_MONTH_TAO or self.curType == RANK_TYPE.CHALLENGE_TOWER  or self:getMainType() == RANK_TYPE.ZDD then
            local _,_,index = RankMgr:getMeLevelZone(RANK_TYPE.CHAR_TAO)
            self:refreshTitleByIndex(index)

            -- 通天塔，按钮list第一个不一样
            if self.curType == RANK_TYPE.CHALLENGE_TOWER then
                self:setLabelText("NameLabel", CHS[7150027], "70Panel")
            else
                self:setLabelText("NameLabel", CHS[7150021], "70Panel")
    end
        end
    end
end

-- 通天塔，道行，表头有等级段，在选择后需要刷新表头
function RankingListDlg:refreshTitleByIndex(index, panelName)
    local panel = self:getControl(self:getUsePanelName())
    if panelName then
        panel = self:getControl(panelName)
    end

    local titlePanel= self:getControl("RankingTitlePanel", nil, panel)
    local levelDes = RankMgr:getTaoTitleLevel(index, self.curType)
    self:setLabelText("AttributeNameLabel" .. 1, levelDes, titlePanel)
end

function RankingListDlg:isCanClickSmallMenu(sender, notShowTips)
    local rankType = MENU_TAG_TO_RANK_NO[sender:getTag()]
    if rankType ~= RANK_TYPE.CHAR_TAO and GameMgr:IsCrossDist() then
        if not notShowTips then
            gf:ShowSmallTips(CHS[5000267])
        end
        return
    end

    return true
end

function RankingListDlg:isCanClickBigMenu(sender, notShowTips)
    local rankType = MENU_TAG_TO_RANK_NO[sender:getTag()]
    local rankTag = math.floor(sender:getTag() / 100)
    if ONE_MENU[rankTag] ~= CHS[4010083] and GameMgr:IsCrossDist() then
        if not notShowTips then
            gf:ShowSmallTips(CHS[5000267])
        end

        return
    end

    return true
end

function RankingListDlg:onOneMenu(sender, isDef)
    -- 尝试关闭通天塔、道行等级段列表
    self:closeTaoLevelListPanel()

    local rankType = MENU_TAG_TO_RANK_NO[sender:getTag()]
    if rankType and not RANK_MAIN_TYPE_INFO[rankType] then

        self.curSelectItem = sender

        -- isDef 还有可能是点击类型
        if RankMgr:isEquipLevelType(rankType) then
            --[[ 如果这个信息是装备
            if isDef == true then
                -- 这个情况是，点击装备排行，要默认选择自己等级段
                local flag = math.floor( (Me:queryInt("level") - 70) / 10 ) + 1
                self:onOneMenu(self:getControl("CategoryListView"):getChildByTag(RANK_TYPE.EQUIP * 100 + 4 + flag))
                return
            end
            --]]

            local _,minLevel,maxLevel,_,equipType = RankMgr:getMeLevelToEquipType(rankType)
            self:fetchRankInfo(rankType, minLevel, maxLevel, nil, equipType)
            self:setCurCheckBox(equipType)
            return
        end

        if rankType == RANK_TYPE.CHAR_TAO
            or rankType == RANK_TYPE.CHAR_MONTH_TAO
            or rankType == RANK_TYPE.HERO
            or rankType == RANK_TYPE.CHALLENGE_TOWER
            or math.floor(rankType / 100) == RANK_TYPE.ZDD then
            -- 如果这个信息道行，通天塔
            self:fetchRankInfo(rankType, RankMgr:getMeLevelZone(rankType))
            return
        end

        self:fetchRankInfo(rankType)
        return
    end

end

function RankingListDlg:onSelectCategoryListView(sender, eventType)
    -- 尝试关闭通天塔、道行等级段列表
    self:closeTaoLevelListPanel()

    if not DistMgr:checkCrossDist() then
        -- 跨服区组，无需处理
        return
    end

    local selItem = self:getListViewSelectedItem(sender)
    local rankType = selItem:getTag()

    if self.curSelectItem then
        self:setCtrlVisible('BChosenEffectImage', false, self.curSelectItem)
    end

    if selItem:getName() == "BigPanel" then
        self:setCtrlVisible('BChosenEffectImage', true, selItem)
        self:setCtrlVisible('DownArrowImage', false, selItem)
        self:setCtrlVisible('UpArrowImage', false, selItem)
    end



    if not RANK_MAIN_TYPE_INFO[rankType] then

        self.curSelectItem = selItem
        self:setCtrlVisible('SChosenEffectImage', true, selItem)

        if RankMgr:isEquipLevelType(rankType) then
            -- 如果这个信息是装备
            local _,minLevel,maxLevel,_,equipType = RankMgr:getMeLevelToEquipType(rankType)
            self:fetchRankInfo(rankType, minLevel, maxLevel, nil, equipType)
            self:setCurCheckBox(equipType)
            return
        end

        if rankType == RANK_TYPE.CHAR_TAO
            or rankType == RANK_TYPE.CHAR_MONTH_TAO
            or rankType == RANK_TYPE.HERO
            or rankType == RANK_TYPE.CHALLENGE_TOWER
            or math.floor(rankType / 100) == RANK_TYPE.ZDD then
            -- 如果这个信息道行，通天塔
            self:fetchRankInfo(rankType, RankMgr:getMeLevelZone(rankType))
            return
        end

        self:fetchRankInfo(rankType)
        return
    end

    -- 主类别，刷新排行类型列表
    local subType = 1
    if rankType == RANK_TYPE.EQUIP then
        -- 装备不能默认选择第一项，需要根据角色等级选择等级段
        local _,_,_,index,_ = RankMgr:getMeLevelToEquipType()
        subType = index
    end

    performWithDelay(self.root, function() self:setRankTypeList(rankType, subType) end, 0.1)
end

function RankingListDlg:onLongSelectRankingListView(sender, eventType)

    if not GMMgr:isGM() then return end

    self.menuInfo = nil

    local info = self.info
    local idx = self:getListViewSelectedItemTag(sender)

    if not info or not info[idx] then
        return
    end

    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:addSelectEffect(panel)

    self.menuInfo = { CHS[4300482] }

    if self:getMainType() == RANK_TYPE.EQUIP or self:getMainType() == RANK_TYPE.PET or self:getMainType() == RANK_TYPE.HOUSE then
        self.menuInfo.char = info[idx].owner_name
    else
        self.menuInfo.char = info[idx].name
    end

    -- 弹出菜单
    self:popupMenus(self.menuInfo)
end


-- 设置排行榜列表选中的效果，以及选中后需要显示的东西
function RankingListDlg:onSelectRankingListView(sender, eventType)
    self.menuInfo = nil

    local info = self.info
    local idx = self:getListViewSelectedItemTag(sender)

    if not info or not info[idx] then
        return
    end

    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:addSelectEffect(panel)

    info = info[idx]
    if self:getMainType() == RANK_TYPE.PET then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHOW_RANK_PET, info.iid_str)
        return
    elseif self:getMainType() == RANK_TYPE.GUARD then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_RANK_GET_GUARD, info.iid_str)
        return
    elseif self:getMainType() == RANK_TYPE.EQUIP then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_RANK_GET_EQUIP, info.gid, info.iid_str)
        return
    elseif self:getMainType() == RANK_TYPE.PARTY then
        return
    elseif self:getMainType() == RANK_TYPE.HOUSE then
        if Me:queryBasic("house/id") == info.house_id then
            HomeMgr:showHomeData(Me:queryBasic("gid"))
        else
            HomeMgr:showHomeData(info.gid, HOUSE_QUERY_TYPE.QUERY_BY_CHAR_GID)
        end
        return
    end

    -- 个人排行需要显示弹出菜单
    if info.gid == Me:queryBasic("gid") then
        -- 点击的是玩家自己，不用弹菜单
        return
    end

    self.menuInfo = { CHS[3000056], CHS[3000057] }

    if not (FriendMgr:isBlackByGId(info.gid) or FriendMgr:hasFriend(info.gid)) then
        -- 不在黑名单中也不在好友列表中，添加“加为好友”菜单项
        table.insert(self.menuInfo, CHS[3000058])
    end

    table.insert(self.menuInfo, CHS[5400270])

    self.menuInfo.char = info.name
    self.menuInfo.gid = info.gid
    self.menuInfo.icon = info.icon
    self.menuInfo.level = info.level or 0

    -- 弹出菜单
    self:popupMenus(self.menuInfo)
end

-- 设置点击排行榜列表项中的菜单的响应事件
function RankingListDlg:onClickMenu(idx)
    if not self.menuInfo then return end

    local menu = self.menuInfo[idx]
    if menu == CHS[3000056] then
        -- 查看装备
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.menuInfo.gid)
    elseif menu == CHS[3000057] then
        -- 交流
        FriendMgr:communicat(self.menuInfo.char, self.menuInfo.gid, self.menuInfo.icon, self.menuInfo.level)
            self.menuInfo = nil
    elseif menu == CHS[3000058] then
        -- 发送数据请求
        FriendMgr:requestCharMenuInfo(self.menuInfo.gid)
        return
    elseif menu == CHS[5400270] then
        -- 查看空间
        BlogMgr:openBlog(self.menuInfo.gid)
    elseif menu == CHS[4300482] then
        gf:copyTextToClipboard(self.menuInfo.char)
        gf:ShowSmallTips(CHS[4300483])
    end

    self:closeMenuDlg()
end

-- 排行榜列表数据
function RankingListDlg:MSG_TOP_USER(data)
    if data.type ~= self.curType then
        -- 当前排行榜选择类型与服务器返回类型不一致，装备需要特殊处理（服务器返回的不是装备，且当前选中的不是装备等级段）
        if not RankMgr:isEquipLevelType(self.curType) or not RankMgr:isEquipType(data.type) then
        return
    end
    end

    self.haveList = true

    local minLevel
    local maxLevel
    self.minLevel = nil
    self.maxLevel = nil
    if data.requestType == 2 then
        minLevel = data.minLevel
        maxLevel = data.maxLevel
        self.minLevel = minLevel
        self.maxLevel = maxLevel
    end
    self.startIndex = 1
    self.info = {}
    self.infoType = self:getMainType()
    self:showRankInfo(minLevel, maxLevel)
end

-- 排行榜中Me的数据
function RankingListDlg:MSG_RANK_CLIENT_INFO()
    if self.haveList then
        local info
        if RankMgr:isEquipLevelType(self.curType) then
            info = RankMgr:getRankListByType(RankMgr:getLastSearchEquip(), self.minLevel, self.maxLevel, 1, 100)
        else
            info = RankMgr:getRankListByType(self.curType, self.minLevel, self.maxLevel, 1, 100)
        end

        if not info then
            -- 判断数据是否存在
            return
        end

        self:checkMyRank(info)
        self.haveList = false
    end
end

function RankingListDlg:MSG_CHAR_INFO(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.gid then return end

    self:closeMenuDlg()

    -- 尝试加为好友
    FriendMgr:tryToAddFriend(data.name, data.gid, Bitset.new(data.setting_flag))
    self.menuInfo = nil
end

function RankingListDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.char_id then return end

    self:closeMenuDlg()

    gf:ShowSmallTips(string.format(CHS[5400576], self.menuInfo.char))
    self.menuInfo = nil
end

-- 玩家和宠物排行
function RankingListDlg:MSG_MY_RANK_INFO(data)
    local panel = self:getControl("RankingPanel")
    if self:getMainType() == RANK_TYPE.CHAR or self:getMainType() == RANK_TYPE.SYNTH then
        panel = self:getControl("RankingPanel")
    elseif self:getMainType() == RANK_TYPE.PET then
        panel = self:getControl("PetRankingPanel")
    elseif self:getMainType() == RANK_TYPE.ZDD or self.curType == RANK_TYPE.HERO then
        panel = self:getControl("HeroRankingPanel")
    else
        return
    end

    local function setRankInfoForMy(par1, par2, par3, par4, par5, panel)
        self:setLabelText("AttributeLabel1", par1, panel)
        self:setLabelText("AttributeLabel2", par2, panel)
        self:setLabelText("AttributeLabel3", par3, panel)
        self:setLabelText("AttributeLabel4", par4, panel)
        self:setLabelText("AttributeLabel5", par5, panel)
    end

    local myRankPanel = self:getControl("MyRankingPanel", Const.UIPanel, panel)
    if self.curType == data.rankNo then
        if self:getMainType() == RANK_TYPE.CHAR then
            if self.myRank == 0 then
                self:setLabelText("AttributeLabel5", data.value, myRankPanel)
            end
        elseif self:getMainType() == RANK_TYPE.PET then
            if self.myRank == 0 then
                local pet = PetMgr:getPetById(data.id)
                if pet then
                    local rankStr = CHS[3003553]
                    setRankInfoForMy(rankStr, pet:queryBasic("raw_name"), pet:queryBasic("level"), Me:getShowName(), data.value, myRankPanel)
                    self.myRankPetId = data.id
                end
            end
        elseif self:getMainType() == RANK_TYPE.ZDD then
            local rankStr
            if self.myRank == 0 then
                rankStr = CHS[3003553]
            else
                rankStr = self.myRank
            end

            if self.curType % 10 ~= Me:queryInt("polar") then
                rankStr = CHS[3003552]
            end
            local party = Me:queryBasic("party") == "" and "无" or Me:queryBasic("party")
            setRankInfoForMy(rankStr, Me:queryBasic("name"), party, self:getHeroDisplayTime(data.value), "", myRankPanel)
        elseif self.curType == RANK_TYPE.HERO then
            local rankStr
            if self.myRank == 0 then
                rankStr = CHS[3003553]
            else
                rankStr = self.myRank
            end
            local party = Me:queryBasic("party") == "" and "无" or Me:queryBasic("party")
            setRankInfoForMy(rankStr, Me:queryBasic("name"), party, self:getHeroDisplayTime(data.value), "", myRankPanel)
        elseif self:getMainType() == RANK_TYPE.SYNTH then
            if self.myRank == 0 then
                local rankStr = CHS[3003553]
                local family
                if self.curType == RANK_TYPE.SYNTH_BLOG_POPULAR then
                    family = gf:getGenderChs(Me:queryBasicInt("gender"))
                else
                    family = gf:getPolar(Me:queryBasicInt("polar"))
                    if family == "" or nil == family then family = CHS[3003552] end
                end
                setRankInfoForMy(rankStr, Me:queryBasic("name"), Me:queryBasic("level"), family, data.value, myRankPanel)
            end
        elseif self:getMainType() == RANK_TYPE.ZDD then
            local rankStr
            if self.myRank == 0 then
                rankStr = CHS[3003553]
            else
                rankStr = self.myRank
            end

            if self.curType % 10 ~= Me:queryInt("polar") then
                rankStr = CHS[3003552]
            end
            local party = Me:queryBasic("party") == "" and CHS[3003552] or Me:queryBasic("party")
            setRankInfoForMy(rankStr, Me:queryBasic("name"), party, self:getHeroDisplayTime(data.value), "", myRankPanel)
        end
    end
end

function RankingListDlg:onCloseButton()
    RankMgr:setLastSelectRankTypeAndSubType(self:getMainType(), CURTYPE_TO_LSITTYPE[self.curType])
    DlgMgr:closeDlg(self.name)
end

function RankingListDlg:onEquipCheckBox(sender, eventType)
    if nil == self.curType then return end
    local name = sender:getName()
    if name == "WeaponCheckBox" then
        self:onEquipWeaponButton(sender, eventType)
    elseif name == "HelmetCheckBox" then
        self:onEquipHelmetButton(sender, eventType)
    elseif name == "ArmorCheckBox" then
        self:onEquipArmorButton(sender, eventType)
    elseif name == "BootCheckBox" then
        self:onEquipBootButton(sender, eventType)
    end
end

function RankingListDlg:onEquipWeaponButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchEquip(RANK_TYPE.EQUIP_WEAPON)
    local minLevel, maxLevel = RankMgr:getEquipLevelByType(self.curType)
    self:fetchRankInfo(self.curType, minLevel, maxLevel, nil, RANK_TYPE.EQUIP_WEAPON)
end

function RankingListDlg:onEquipHelmetButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchEquip(RANK_TYPE.EQUIP_HELMET)
    local minLevel, maxLevel = RankMgr:getEquipLevelByType(self.curType)
    self:fetchRankInfo(self.curType, minLevel, maxLevel, nil, RANK_TYPE.EQUIP_HELMET)
end

function RankingListDlg:onEquipArmorButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchEquip(RANK_TYPE.EQUIP_ARMOR)
    local minLevel, maxLevel = RankMgr:getEquipLevelByType(self.curType)
    self:fetchRankInfo(self.curType, minLevel, maxLevel, nil, RANK_TYPE.EQUIP_ARMOR)
end

function RankingListDlg:onEquipBootButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchEquip(RANK_TYPE.EQUIP_BOOT)
    local minLevel, maxLevel = RankMgr:getEquipLevelByType(self.curType)
    self:fetchRankInfo(self.curType, minLevel, maxLevel, nil, RANK_TYPE.EQUIP_BOOT)
end

function RankingListDlg:onTao70LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(1)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 1))
    self:setTaoLevelByType("close", 1, sender:getParent():getParent():getName())
end

function RankingListDlg:onTao80LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(2)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 2))
    self:setTaoLevelByType("close", 2, sender:getParent():getParent():getName())
end

function RankingListDlg:onTao90LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(3)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 3))
    self:setTaoLevelByType("close", 3, sender:getParent():getParent():getName())
end

function RankingListDlg:onTao100LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(4)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 4))
    self:setTaoLevelByType("close", 4, sender:getParent():getParent():getName())
end

function RankingListDlg:onTao110LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(5)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 5))
    self:setTaoLevelByType("close", 5, sender:getParent():getParent():getName())
end

function RankingListDlg:onTao120LevelButton(sender, eventType)
    if nil == self.curType then return end

    RankMgr:setLastSearchLevel(6)
    self:fetchRankInfo(self.curType, RankMgr:getLevelZone(self.curType, 6))
    self:setTaoLevelByType("close", 6, sender:getParent():getParent():getName())
end

function RankingListDlg:onUpdate(dt)
    if self.dirty then
        self.dirty = false
    end
end

-- 打开界面需要某些参数需要重载这个函数
function RankingListDlg:onDlgOpened(param)
    local typeTab = gf:split(param[1], "|")

    local def = {}
    if typeTab[2] then
        local tag = self:getDestTagByRankNo(tonumber(typeTab[2]))
        def.one = math.floor(tag / 100) * 100
        def.two = tonumber(tag)
    else
        local tag = self:getDestTagByRankNo(tonumber(typeTab[1]))
        def.one = math.floor(tag / 100) * 100
        def.two = tonumber(tag)
    end
    def.isScrollToDef = true

    self:setMenuList("CategoryListView", ONE_MENU, self.bigPanel, SECOND_MENU, self.sPanel, self.onOneMenu, self.onOneMenu, def)

    self:setListTitle()
end

function RankingListDlg:getDestTagByRankNo(rankNo)
    for tag, no in pairs(MENU_TAG_TO_RANK_NO) do
        if no == rankNo then
            return tag
        end
    end
end


return RankingListDlg
