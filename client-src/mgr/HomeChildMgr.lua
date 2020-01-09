-- HomeChildMgr.lua
-- created by songcw Frb/21/2019
-- 娃娃系统管理器

HomeChildMgr = Singleton()

local Kid = require('obj/Kid')
local FUNCTION_FURNITURE_MAGIC = require(ResMgr:getCfgPath("FuncFurnitureMagic.lua"))
local ToyEffect =  require (ResMgr:getCfgPath("ToyEffect.lua"))

HomeChildMgr.CHILD_TYPE = {
    FETUS = 1,      -- 胎儿
    STONE = 2,      -- 灵石
    BABY  = 3,      -- 婴儿期
    KID   = 4,      -- 儿童
}

HomeChildMgr.KID_STAGE = {
    XIULIAN = 0,    -- 修炼阶段
    TUPO = 1,    -- 突破
}

local FIELD_MAP = {
    [CHS[4200735]] = "max_life",
    [CHS[4200736]] = "def",
    [CHS[4200737]] = "speed",
    [CHS[4200738]] = "phy_power",
    [CHS[4200739]] = "mag_power",
    [CHS[4200740]] = "max_mana",
}

-- 抚养类型，值以服务器为准
HomeChildMgr.FY_TYPE = {
    WMR         = 1,    -- 喂母乳
    WNN         = 2,    -- 喂牛奶
    WCY         = 3,    -- 喂菜肴
    MY          = 4,    -- 沐浴
    XL          = 5,    -- 洗脸
    WWJ         = 6,    -- 玩玩具
    PW          = 7,    -- 陪玩
    YLQ         = 8,    -- 摇篮曲
    GJKH        = 9,    -- 管家看护
    RSG         = 10,   -- 人参果
    XEL         = 11,   -- 小儿灵
    BLG         = 12,   -- 拨浪鼓
}

-- 行程类型
HomeChildMgr.SCHE_TYPE = {
    NONE        = 0,    -- 无安排
    XZL         = 1,    -- 学走路
    XRZ         = 2,    -- 学认字
    YY          = 3,    -- 游泳
    TGY         = 4,    -- 听古乐
    XW          = 11,   -- 习武
    SS          = 12,   -- 算术
    PB          = 13,   -- 跑步
    MB          = 14,   -- 马步
    HH          = 15,   -- V画画
    XR          = 21,   -- 虚弱
    KJ          = 22,   -- 困倦
    SJ          = 23,   -- 睡觉
}

local WUXING_MAP = {
    CHS[4101372], CHS[4101373], CHS[4101374], CHS[4101375], CHS[4101376]
}

local XINGGE_MAP = {
    --"活泼", "乖巧", "安静",
    CHS[4101382], CHS[4101383], CHS[4101384],
}

local SLEEP_MAGIC_TAG = 10

HomeChildMgr.childData = nil
HomeChildMgr.childLog = {}

local SCHEDULE_MAX = {
    [HomeChildMgr.SCHE_TYPE.XW] = 40,
    [HomeChildMgr.SCHE_TYPE.SS] = 28,
    [HomeChildMgr.SCHE_TYPE.PB] = 27,
    [HomeChildMgr.SCHE_TYPE.MB] = 38,
    [HomeChildMgr.SCHE_TYPE.HH] = 25,
}

-- 日志模板
local TEMPLATE = {
    [1] = CHS[4010397],         -- "%s %s怀孕了，好好培养你们的爱情结晶吧",
    [2] = CHS[4010398],         -- "%s %s突然感到腹部一丝疼痛，似乎是宝宝不太安稳",
    [3] = CHS[4010399],         -- "%s %s肚子里的宝宝踢了母亲一下，看来这个健康的小家伙是在做运动呢",
    [4] = CHS[4010400],         -- "%s %s感受到了胎动，似乎是宝宝感到孤单了，在闹别扭呢",
    [5] = CHS[4010401],         -- "%s %s出去散了散步，对胎儿的健康大有益处",
    [6] = CHS[4010402],         -- "%s %s哼起了优美的旋律，孕妇听音乐对胎儿也是有帮助的哦",
    [7] = CHS[4010403],         -- "%s %s为孕妇细心地按摩酸痛的小腿和腰，真是一个温柔的父亲呢",
    [8] = CHS[4010404],         -- "%s %s你的宝宝成熟度达到100了！做好准备就去找管家进行下一步的接生操作吧",
    [9] = CHS[4010405],         -- "%s %s将送子娘娘赠予的天地灵石首次摆入居所中，正式开始培育",
    [10] = CHS[4010406],         -- "%s %s消耗大量潜能为灵石注入了能量，灵石中传来一股波动",
    [11] = CHS[4010407],         -- "%s %s灵石的成熟度达到200了！做好准备就回居所进行灵石雕琢吧",
    [12] = CHS[4101385],        -- "%s %s进入了婴幼儿期",
    [13] = CHS[4101386],        -- "%s %s甜美地进入了梦乡",
    [14] = CHS[4101387],        -- "%s %s从梦中惊醒，害怕地大哭了起来，导致失眠了。睡觉降低疲劳度%s点",
    [15] = CHS[4101388],        -- "%s %s美美地睡了一个整觉，舒服地起床伸了个懒腰。睡觉降低疲劳度%s点",
    [16] = CHS[4101389],        -- "%s %s身体无力精神不振，好像生病了",
    [17] = CHS[4101390],        -- "%s %s从疾病中慢慢恢复了，身体有些虚弱",
    [18] = CHS[4101391],        -- "%s %s从长期的失眠状态中缓了过来",
    [19] = CHS[4101392],        -- "%s %s服用了“小儿灵”，病痛解除了",
    [20] = CHS[4101393],        -- "%s %s服用了“小儿灵”，总算是不失眠了",
    [21] = CHS[4101394],        -- "%s %s的成长度达到了200，可以为其安排行程了！",
    [22] = CHS[4101395],        -- "%s %s似乎长大了一点，迈着小腿开始会在前庭走来走去了呢",
    [23] = CHS[4101396],        -- "%s %s的成长度达到了500，可以为其安排与资质有关的行程了",
    [24] = CHS[4101397],        -- "%s #Y%s#n成长度达到了#R%s#n点，觉得原本安排的行程已经不适合自己了，因此没有进行行程：#R%s#n", -- 未安排
    [25] = CHS[4101398],        -- "%s #Y%s#n迈着小脚丫一步一步地学起了走路，疲劳度#R+3#n，成长度#G+%s#n",
    [26] = CHS[4101399],        -- "%s #Y%s#n安稳地坐着开始学认字，疲劳度#R+3#n，成长度#G+%s#n",
    [27] = CHS[4101400],        -- "%s #Y%s#n在管家的看护下游泳戏水，好不快活，疲劳度#R+3#n，成长度#G+%s#n，清洁度#G+%s#n",
    [28] = CHS[4101401],        -- "%s #Y%s#n听起了管家用古琴弹奏的乐曲，很是投入，疲劳度#R+3#n，成长度#G+%s#n，心情度#G+%s#n",
    [29] = CHS[4101402],        -- "%s #Y%s#n照着武功秘籍开始习武，疲劳度#R+3#n，成长度#G+5#n，物攻资质#G+%s#n",
    [30] = CHS[4101403],        -- "%s #Y%s#n把玩着手中的算盘开始学算术，疲劳度#R+3#n，成长度#G+5#n，法攻资质#G+%s#n",
    [31] = CHS[4101404],        -- "%s #Y%s#n迈开步子练起了跑步，疲劳度#R+3#n，成长度#G+5#n，速度资质#G+%s#n",
    [32] = CHS[4101405],        -- "%s #Y%s#n认真地扎起了马步，一副小大人的样子，疲劳度#R+3#n，成长度#G+5#n，气血资质#G+%s#n",
    [33] = CHS[4101406],        -- "%s #Y%s#n在白纸上照着画册画了起来，疲劳度#R+3#n，成长度#G+5#n，法力资质#G+%s#n",
    [34] = CHS[4101407],        -- "%s #Y%s#n因太过虚弱，无法完成爹娘安排的行程：#R%s#n，甚是可怜",
    [35] = CHS[4101408],        -- "%s #Y%s#n因太过疲倦，实在无法按原计划完成行程：#R%s#n",
    [36] = CHS[4101409],        -- "%s #Y%s#n被爹娘喊去睡觉了，没有完成原本安排的行程：#R%s#n",
}

-- czd_max、czd_mix:要求的成长度
-- key值对应为 HomeChildMgr.SCHE_TYPE
local SCHEDULE_INFO = {
    [HomeChildMgr.SCHE_TYPE.NONE] = {order = 1, name = CHS[4101358], desc = "", cost = 0,  template = CHS[4200731]}, -- 未安排
    [HomeChildMgr.SCHE_TYPE.XZL] = {order = 1, icon = "ui/Icon2582.png", name = CHS[4101410], desc = CHS[4101422], cost = 1000000, czd_max = 500, template = CHS[4101434]}, -- 学走路
    [HomeChildMgr.SCHE_TYPE.XRZ] = {order = 2, icon = "ui/Icon2583.png", name = CHS[4101411], desc = CHS[4101423], cost = 1000000, czd_max = 500, template = CHS[4101435]}, -- 学认字
    [HomeChildMgr.SCHE_TYPE.YY] = {order = 3, icon = "ui/Icon2584.png", name = CHS[4101412], desc = CHS[4101424], cost = 500000, czd_max = 500, template = CHS[4101436]}, -- 游泳
    [HomeChildMgr.SCHE_TYPE.TGY] = {order = 4, icon = "ui/Icon2585.png", name = CHS[4101413], desc = CHS[4101425], cost = 500000, czd_max = 500, template = CHS[4101437]}, -- 听古乐

    [HomeChildMgr.SCHE_TYPE.XW] = {order = 5, icon = "ui/Icon2586.png", name = CHS[4101414], desc = CHS[4101426], cost = 5000000, isNeedServerData = true, czd_mix = 500, template = CHS[4101438]}, -- 习武
    [HomeChildMgr.SCHE_TYPE.SS] = {order = 6, icon = "ui/Icon2587.png", name = CHS[4101415], desc = CHS[4101427], cost = 5000000, isNeedServerData = true, czd_mix = 500, template = CHS[4101439]}, -- 算术
    [HomeChildMgr.SCHE_TYPE.PB] = {order = 7, icon = "ui/Icon2588.png", name = CHS[4101416], desc = CHS[4101428], cost = 5000000, isNeedServerData = true, czd_mix = 500, template = CHS[4101440]}, -- 跑步
    [HomeChildMgr.SCHE_TYPE.MB] = {order = 8, icon = "ui/Icon2589.png", name = CHS[4101417], desc = CHS[4101429], cost = 5000000, isNeedServerData = true, czd_mix = 500, template = CHS[4101441]}, -- 马步
    [HomeChildMgr.SCHE_TYPE.HH] = {order = 9, icon = "ui/Icon2590.png", name = CHS[4101418], desc = CHS[4101430], cost = 5000000, isNeedServerData = true, czd_mix = 500, template = CHS[4101442]}, -- 画画

    [HomeChildMgr.SCHE_TYPE.XR] = {order = 10, icon = "ui/Icon2591.png", name = CHS[4101419], desc = CHS[4101431], cost = 0, template = CHS[4101443]}, -- 虚弱
    [HomeChildMgr.SCHE_TYPE.KJ] = {order = 11, icon = "ui/Icon2592.png", name = CHS[4101420], desc = CHS[4101432], cost = 0, template = CHS[4101444]}, -- 困倦
    [HomeChildMgr.SCHE_TYPE.SJ] = {order = 12, icon = "ui/Icon2593.png", name = CHS[4101421], desc = CHS[4101433], cost = 0, template = CHS[4101445]}, -- 睡觉
}

local FUYANG_INFO = {
    [HomeChildMgr.FY_TYPE.WMR] = {icon = "ui/Icon2594.png", name = CHS[4101324]}, -- 喂母乳
    [HomeChildMgr.FY_TYPE.WNN] = {icon = "ui/Icon2571.png", name = CHS[4101329]}, -- 喂牛奶
    [HomeChildMgr.FY_TYPE.WCY] = {icon = "ui/Icon2572.png", name = CHS[4101331]}, -- 喂菜肴
    [HomeChildMgr.FY_TYPE.MY] = {icon = "ui/Icon2573.png", name = CHS[4101334]}, -- 沐浴
    [HomeChildMgr.FY_TYPE.XL] = {icon = "ui/Icon2574.png", name = CHS[4101337]}, -- 洗脸
    [HomeChildMgr.FY_TYPE.WWJ] = {icon = "ui/Icon2575.png", name = CHS[4101339]}, -- 玩玩具
    [HomeChildMgr.FY_TYPE.PW] = {icon = "ui/Icon2576.png", name = CHS[4101342]}, -- 陪玩
    [HomeChildMgr.FY_TYPE.YLQ] = {icon = "ui/Icon2577.png", name = CHS[4101344]}, -- 摇篮曲
    [HomeChildMgr.FY_TYPE.GJKH] = {icon = "ui/Icon2578.png", name = CHS[4101346]}, -- 管家看护

    [HomeChildMgr.FY_TYPE.RSG] = {icon = "ui/Icon2579.png", name = CHS[4101348]}, -- 人参果
    [HomeChildMgr.FY_TYPE.XEL] = {icon = "ui/Icon2580.png", name = CHS[4101351]}, -- 小儿灵
    [HomeChildMgr.FY_TYPE.BLG] = {icon = "ui/Icon2581.png", name = CHS[4101354]}, -- 拨浪鼓
}

-- 娃娃门派信息配置
local FAMILY_INFO_CFG = {
    { gender = 1, family = 1, icon = 10001, familyChs = CHS[7100400], itemName = CHS[7100405]},-- 金男娃娃
    { gender = 1, family = 2, icon = 10002, familyChs = CHS[7100401], itemName = CHS[7100406]},-- 木男娃娃
    { gender = 1, family = 3, icon = 10003, familyChs = CHS[7100402], itemName = CHS[7100407]},-- 水男娃娃
    { gender = 1, family = 4, icon = 10004, familyChs = CHS[7100403], itemName = CHS[7100408]},-- 火男娃娃
    { gender = 1, family = 5, icon = 10005, familyChs = CHS[7100404], itemName = CHS[7100409]},-- 土男娃娃
    { gender = 2, family = 1, icon = 11001, familyChs = CHS[7100400], itemName = CHS[7100405]}, --金女娃娃
    { gender = 2, family = 2, icon = 11002, familyChs = CHS[7100401], itemName = CHS[7100406]},-- 木女娃娃
    { gender = 2, family = 3, icon = 11003, familyChs = CHS[7100402], itemName = CHS[7100407]},-- 水女娃娃
    { gender = 2, family = 4, icon = 11004, familyChs = CHS[7100403], itemName = CHS[7100408]},-- 火女娃娃
    { gender = 2, family = 5, icon = 11005, familyChs = CHS[7100404], itemName = CHS[7100409]},-- 土女娃娃
}

-- 儿童期娃娃对象
HomeChildMgr.kids = {}

-- 技能配置
local KID_SKILL_CFG = {
    [POLAR.METAL] = {
        ["PhyType"] = {501},
        ["BType"] = {13, 14},
        ["DType"] = {23, 24},
        ["CType"] = {33, 34},
    },
    [POLAR.WOOD] = {
        ["PhyType"] = {501},
        ["BType"] = {63, 64},
        ["DType"] = {73, 74},
        ["CType"] = {83, 84},
    },
    [POLAR.WATER] = {
        ["PhyType"] = {501},
        ["BType"] = {112, 113},
        ["DType"] = {123, 124},
        ["CType"] = {133, 134},
    },
    [POLAR.FIRE] = {
        ["PhyType"] = {501},
        ["BType"] = {163, 164},
        ["DType"] = {173, 174},
        ["CType"] = {183, 184},
    },
    [POLAR.EARTH] = {
        ["PhyType"] = {501},
        ["BType"] = {212, 213},
        ["DType"] = {223, 224},
        ["CType"] = {233, 234},
    },
}

local KID_SKILL_DESC = require(ResMgr:getCfgPath("KidSkillDesc.lua"))
local KidIntimacyEffctCfg = require(ResMgr:getCfgPath("KidIntimacyCfg.lua"))

local QUALITY_COLOR = {
    [CHS[5450431]] = 1,     [CHS[5450434]] = 2,     [CHS[7002102]] = 3,
}

function HomeChildMgr:getNaijiuByColor(color)
    return (QUALITY_COLOR[color] + 3) * 1000 + 3000
end


function HomeChildMgr:getIntimacyCfg()
    return KidIntimacyEffctCfg
end

function HomeChildMgr:getSkillDesc(skillName)
    return KID_SKILL_DESC[skillName]
end

function HomeChildMgr:getSkillCfgByFamily(family)
    return KID_SKILL_CFG[family]
end

function HomeChildMgr:getFamilyCfg(gender, family)
    if gender and family then
        for i = 1, #FAMILY_INFO_CFG do
            if FAMILY_INFO_CFG[i].gender == gender and FAMILY_INFO_CFG[i].family == family then
                return FAMILY_INFO_CFG[i]
            end
        end
    else
        return FAMILY_INFO_CFG
    end
end

function HomeChildMgr:getScheduleCfg(opType)
    if opType then
        return SCHEDULE_INFO[opType]
    else
        return SCHEDULE_INFO
    end
end

function HomeChildMgr:getFuyangCfg(opType)
    if opType then
        return FUYANG_INFO[opType]
    else
        return FUYANG_INFO
    end
end


function HomeChildMgr:getScheduleMax(opType)
    return SCHEDULE_MAX[opType]
end

function HomeChildMgr:cleanData()
    for k, v in pairs(self.kids) do
        self:deleteKid(k)
    end

    self.kids = {}

    self.childData = nil
    self.childLog = {}
    self.playSleepInHome = nil
    self.birthAnimateData = nil
    self.combatKidId = nil
    self.visibleKidId = nil
end

function HomeChildMgr:isSpcialScheduleValue(scheValue)
    if scheValue >= HomeChildMgr.SCHE_TYPE.XR and scheValue <= HomeChildMgr.SCHE_TYPE.SJ then
        return true
    end

    return false
end

function HomeChildMgr:getStageChsByMature(mature)
    if mature < 50 then
        return CHS[4010408] -- "灵石初期"
    elseif mature < 100 then
        return CHS[4010409] -- "胎光渐显"
    elseif mature < 150 then
        return CHS[4010410] -- "灵脉天筑"
    elseif mature < 200 then
        return CHS[4010411] -- "灵胎期"
    else
        return CHS[4010412] -- "灵胎已成"
    end
end

function HomeChildMgr:getStageChild(child)
    if child.stage == HomeChildMgr.CHILD_TYPE.STONE then
        -- 灵石期
        return CHS[4101378]
    elseif child.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        -- 胎儿期
        return CHS[4101377]
    elseif child.stage == HomeChildMgr.CHILD_TYPE.BABY then
        -- 婴幼儿期
        return CHS[4101379] .. HomeChildMgr:getChildGenderChs(child.gender)
    elseif child.stage == HomeChildMgr.CHILD_TYPE.KID then
        -- 儿童期
        return CHS[7100429] .. HomeChildMgr:getChildGenderChs(child.gender)
    end
end

function HomeChildMgr:getChildGenderChs(gender)
    if gender == GENDER_TYPE.FEMALE then return CHS[4101380] end    -- 女孩
    if gender == GENDER_TYPE.MALE then return CHS[4101381] end      -- 男孩
end

function HomeChildMgr:getPregnancyLogById(id)
    local ret = {}

    if HomeChildMgr.childLog[id] then
        for i = #HomeChildMgr.childLog[id], 1, -1 do
            table.insert( ret, HomeChildMgr.childLog[id][i] )
        end

        return ret
    end

    return {}
end

function HomeChildMgr:getChildByOrderForHomeKidDlg()
    if not HomeChildMgr.childData then return {} end

    local ret = {}
    for _, childInfo in pairs(HomeChildMgr.childData) do
        table.insert( ret, childInfo )
    end

    table.sort( ret, function (l, r )
        if l.stage < r.stage then return true end
        if l.stage > r.stage then return false end
        if l.mature < r.mature then return true end
        if l.mature > r.mature then return false end
        if l.intimacy > r.intimacy then return true end
        if l.intimacy < r.intimacy then return false end
    end )

    return ret
end

function HomeChildMgr:getChildByOrder(useObj)
    local ret = {}

    if useObj then
        ret = self:getKidList()
        table.sort( ret, function (l, r )
            if l:queryInt("stage") < r:queryInt("stage") then return true end
            if l:queryInt("stage") > r:queryInt("stage") then return false end
            if l:queryInt("intimacy") > r:queryInt("intimacy") then return true end
            if l:queryInt("intimacy") < r:queryInt("intimacy") then return false end
        end)
    else
        if not HomeChildMgr.childData then
            return ret
        end

        for _, childInfo in pairs(HomeChildMgr.childData) do
            table.insert( ret, childInfo )
        end

        table.sort( ret, function (l, r )
            if l.stage < r.stage then return true end
            if l.stage > r.stage then return false end
            if l.mature > r.mature then return true end
            if l.mature < r.mature then return false end
            if l.intimacy > r.intimacy then return true end
            if l.intimacy < r.intimacy then return false end
        end)
    end

    return ret
end

function HomeChildMgr:getChildenCount()
    if not HomeChildMgr.childData then return 0 end

    local count = 0
    for _, childInfo in pairs(HomeChildMgr.childData) do
        count = count + 1
    end

    return count
end

function HomeChildMgr:getChildenInfoById(id)
    if not self.childData then return end

    local count = 0
    for _, childInfo in pairs(self.childData) do
        if childInfo.id == id then
            return childInfo
        end
    end
end

-- 获取家务列表
function HomeChildMgr:getChildHomeworkList()
    return self.homeworkList or {}
end

function HomeChildMgr:setKidInfoDlgOpenTips(tips)
    self.kidInfoDlgTips = tips
end


function HomeChildMgr:isHasETQchild()
    if not self.childData then return end
    for id, child in pairs(self.childData) do
        if child.stage == HomeChildMgr.CHILD_TYPE.KID then
            return child.id
        end
    end
end

function HomeChildMgr:requestChildCard(cid)
    gf:CmdToServer("CMD_QUERY_CHILD_CARD", {cid = cid})
end

function HomeChildMgr:MSG_CHILD_CULTIVATE_INFO(data)

    DlgMgr:openDlgEx("KidCultureDlg", data)

    if not self.childData or not next(self.childData) then  return end
    for _, child in pairs(self.childData) do
        if child.id == data.id then
            child.daofa = data.daofa
            child.xinfa = data.xinfa
        end
    end
end


function HomeChildMgr:MSG_CHILD_INFO(data)
    self.homeworkList = data.homeworkList

    if not self.childData then self.childData = {} end

    if data.count == 0 then self.childData = {} end

    for i = 1, data.count do
        local id = data.childInfo[i].id
        self.childData[id] = data.childInfo[i]
    end

    if data.isForceOpen == 1 then
        -- 强制打开界面
        DlgMgr:openDlgEx("KidInfoDlg", data)
    end
end

-- 获取孩子对象信息
function HomeChildMgr:getKidByCid(cid)
    for _, kid in pairs(self.kids) do
        if kid:queryBasic("cid") == cid then
            return kid
        end
    end
end

-- 获取孩子对象信息
function HomeChildMgr:getKidById(id)
    return self.kids[id]
end

-- 获取孩子列表
function HomeChildMgr:getKidList(stage)
    local kidList = {}
    for k, v in pairs(self.kids) do
        if not stage or stage == v:queryBasicInt("stage") then
            table.insert(kidList, v)
        end
    end

    return kidList
end

-- 获取参战状态的孩子
function HomeChildMgr:getFightKid()
    return self.kids[self.combatKidId]
end

-- 判断孩子是否是跟随状态
function HomeChildMgr:isFollowKidByCid(cid)
    local kid = self:getKidByCid(cid)
    if kid and kid:getId() == self.combatKidId then
        return true
    end
end

-- 获取显示在场景中的孩子
function HomeChildMgr:isVisibleKidByCid(cid)
    local kid = self:getKidByCid(cid)
    if kid and kid:getId() == self.visibleKidId then
        return true
    end
end

-- 获取显示在场景中的孩子id
function HomeChildMgr:getVisibleKidId()
    if self.visibleKidId and self.visibleKidId > 0 then
        return self.visibleKidId
    end
end

function HomeChildMgr:MSG_CHILD_LOG(data)
    local id = data.id
    local ret = {}
    for i = 1, data.count do
        local timeStr = gf:getServerDate("%Y.%m.%d %H:%M", data.logInfo[i].ti)
        if data.logInfo[i].template == 1 or data.logInfo[i].template == 9 then
            timeStr = gf:getServerDate("%Y.%m.%d", data.logInfo[i].ti)
        end
        local key = string.format( TEMPLATE[data.logInfo[i].template], timeStr, data.logInfo[i].para, data.logInfo[i].para2, data.logInfo[i].para3)
        table.insert( ret, key )
        end

    HomeChildMgr.childLog[id] = ret
end

function HomeChildMgr:MSG_CHILD_INJECT_ENERGY(data)
    -- "#Z居所-前庭|H=me|furniturePara=name=天地灵石pos=%d,%did=%d#Z",
    local str = string.format( CHS[4010413], data.x, data.y, data.furniture_no)
    local dest = gf:findDest(str)
    dest.action = "$3"
    AutoWalkMgr:beginAutoWalk(dest)
--    HomeMgr:setLSClickType(CHS[4010393])
end

function HomeChildMgr:MSG_CHILD_BIRTH_STONE(data)
    -- "#Z居所-前庭|H=me|furniturePara=name=天地灵石pos=%d,%did=%d#Z",
    local str = string.format( CHS[4101457], data.x, data.y, data.furniture_no)
    local dest = gf:findDest(str)
    dest.action = "$3"

    AutoWalkMgr:beginAutoWalk(dest)
 --   HomeMgr:setLSClickType(CHS[4010432])
end

function HomeChildMgr:MSG_CHILD_BIRTH_RESULT(data)
    DlgMgr:openDlgEx("ChildBirthResultDlg", data)

    DlgMgr:closeDlg("ChildBirthDlg")
    DlgMgr:closeDlg("FastUseItemForWawaDlg")
end

function HomeChildMgr:MSG_CHILD_BIRTH_INFO(data)
    DlgMgr:openDlgEx("ChildBirthDlg", data)
end

function HomeChildMgr:MSG_CHILD_BIRTH_HUSBAND_INFO(data)
    if data.water_stage >= 1 then
        local dlg = DlgMgr:getDlgByName("FastUseItemForWawaDlg")
        if not dlg then
            DlgMgr:openDlgEx("FastUseItemForWawaDlg", data)
        else
            dlg:setData(data)
        end
    else
        DlgMgr:closeDlg("FastUseItemForWawaDlg")
    end
end

function HomeChildMgr:setAllCharVisibleExpByName(name)
    local chars = CharMgr.chars
    for _, v in pairs(chars) do
        if v:queryBasic("name") ~= name then
            v:setVisible(false)
        end
    end
end

function HomeChildMgr:getChildSmallPortraitById(id)
    if not self.childData then return end
    if not self.childData[id] then return end

    local data = self.childData[id]

    if data.stage == self.CHILD_TYPE.FETUS then
        -- 胎儿的头像
        return ResMgr:getSmallPortrait(51528)
    elseif data.stage == self.CHILD_TYPE.STONE then
        return ResMgr:getSmallPortrait(51534)
    elseif data.stage == self.CHILD_TYPE.BABY then
        if data.mature < 300 then
            return ResMgr:getSmallPortrait(51529)
        else
            if not data.gender then data.gender = 1 end
            if data.gender == GENDER_TYPE.MALE then
                return ResMgr:getSmallPortrait(51531)
            else
                return ResMgr:getSmallPortrait(51530)
            end
        end
    elseif data.stage == self.CHILD_TYPE.KID then
        local kid = self:getKidByCid(data.id)
        if kid then
            return ResMgr:getSmallPortrait(kid:queryBasicInt("portrait"))
        end
    end
end

function HomeChildMgr:getChildSmallPortrait(data)
    if not data then return end
    if data.stage == self.CHILD_TYPE.FETUS then
        -- 胎儿的头像
        return ResMgr:getSmallPortrait(51528)
    elseif data.stage == self.CHILD_TYPE.STONE then
        return ResMgr:getSmallPortrait(51534)
    elseif data.stage == self.CHILD_TYPE.BABY then
        if data.growth < 300 then
            return ResMgr:getSmallPortrait(51529)
        else
            if not data.gender then data.gender = 1 end
            if data.gender == GENDER_TYPE.MALE then
                return ResMgr:getSmallPortrait(51531)
            else
                return ResMgr:getSmallPortrait(51530)
            end
        end
    elseif data.stage == self.CHILD_TYPE.KID then
        return ResMgr:getSmallPortrait(data.icon)
    end
end

function HomeChildMgr:setPortrait(id, panel, dlg, kidOffsetPos, dlgData)
    local data
    if dlgData then
        data = dlgData
    else
        if not HomeChildMgr.childData then return end
        if not HomeChildMgr.childData[id] then return end
        data = HomeChildMgr.childData[id]
    end

    panel:removeAllChildren()
    panel:setScale(1)

    if data.stage == HomeChildMgr.CHILD_TYPE.FETUS or data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        local icon
        local actName = "Top"
        if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then icon = 2051 end
        if data.stage == HomeChildMgr.CHILD_TYPE.STONE then
            icon = 2050
            actName = "Top01"
        end
        -- 胎儿的头像
        local magic = ArmatureMgr:createArmatureByType(ARMATURE_TYPE.ARMATURE_UI, icon)
        magic:setPosition(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5)
        magic:getAnimation():play(actName, -1, 1)

        -- 设置偏移量
        if data.stage == HomeChildMgr.CHILD_TYPE.STONE then
            magic:setPositionY(95)
        else
            magic:setPosition(panel:getContentSize().width * 0.5 + 5, 105)
        end
        panel:addChild(magic)
    elseif data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        if data.mature < 300 then
            --return ResMgr:getSmallPortrait(51529)
            local info = FUNCTION_FURNITURE_MAGIC[CHS[4010428]]
            local icon = info.icon

            local dragonArmature = DragonBonesMgr:createUIDragonBones(icon, string.format("%05d", icon))
            local nodeDragonArmature = tolua.cast(dragonArmature, "cc.Node")

            DragonBonesMgr:toPlay(dragonArmature, info.flipAction, -1)
            nodeDragonArmature:setPosition(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5)
            panel:addChild(nodeDragonArmature)
        elseif data.mature < 500 then
            if not data.gender then data.gender = 1 end
            if data.gender == GENDER_TYPE.MALE then
                dlg:setPortrait(panel:getName(), 51531, nil, nil, nil, nil, nil, cc.p(-8, -25))  -- cc.p(0, -20))
            else
                dlg:setPortrait(panel:getName(), 51530, nil, nil, nil, nil, nil, cc.p(-8, -25))
            end
            panel:setScale(1.1)
        else
            if not data.gender then data.gender = 1 end
            if data.gender == GENDER_TYPE.MALE then
                dlg:setPortrait(panel:getName(), 51536, nil, nil, nil, nil, nil, cc.p(-8, -25))
            else
                dlg:setPortrait(panel:getName(), 51535, nil, nil, nil, nil, nil, cc.p(-8, -25))
            end
            panel:setScale(1.1)
        end
    elseif data.stage == HomeChildMgr.CHILD_TYPE.KID then
        if dlgData then
            dlg:setPortrait(panel:getName(), data.icon, nil, nil, true, nil, nil, kidOffsetPos)
        else
            local kid = self:getKidByCid(data.id)
            if kid then
                local argList = {
                    panelName = panel:getName(),
                    icon = kid:getIcon(),
                    weapon = 0,
                    root = panel:getParent(),
                    orgIcon = kid:getOrgIcon(),
                    dir = 5,
                    partIndex = kid:getPartIndex(),
                    partColorIndex = kid:getPartColorIndex(),
                    offPos = kidOffsetPos or nil,
                }
                dlg:setPortraitByArgList(argList)
            end
        end
    end
end

-- 设置娃娃logo
function HomeChildMgr:setChildLogo(dlg, child, ctrlParent)
    local childLogoPanel = dlg:getControl("LogoPanel", nil, ctrlParent)
    childLogoPanel:setVisible(true)
    dlg:setCtrlVisible("SingularPanel", false, childLogoPanel)
    dlg:setCtrlVisible("DoublePanel", false, childLogoPanel)
    childLogoPanel:setLayoutType(ccui.LayoutType.ABSOLUTE)
    childLogoPanel:requestDoLayout()

    local logoPath = {}

    -- 飞升
    if (type(child) == "boolean" and child) or HomeChildMgr:isFlyChild(child) then
        table.insert(logoPath, {path = ResMgr.ui.fly_logo, pList = 0})
    end

    local count = #logoPath
    childLogoPanel:removeAllChildren()
    if count == 0 then return end

    local size = childLogoPanel:getContentSize()
    local imageSize = 20
    local logoMargin = 5

    local function getStartX(count, size)
        local temp = math.floor(count / 2)
    	if count % 2 == 0 then
            return (size.width * 0.5 - temp * (imageSize + logoMargin) - logoMargin * 0.5)
    	else
            return (size.width * 0.5 - temp * (imageSize + logoMargin) - imageSize * 0.5)
    	end
    end

    local function onFlyImageListener(sender, eventType)
        gf:showTipInfo(CHS[7120250], sender)
    end

    local startx = getStartX(count, size) + imageSize * 0.5
    for i = 1, count do
        local logo = logoPath[i]
        local image = ccui.ImageView:create(logo.path, logo.pList)
        image:setPosition(startx + (i - 1) * (imageSize + logoMargin),size.height * 0.5)
        childLogoPanel:addChild(image)

        if logo.path == ResMgr.ui.fly_logo then
            -- 飞升图片增加响应
            image:setTouchEnabled(true)
            image:addTouchEventListener(onFlyImageListener)
        end
    end
end

function HomeChildMgr:isFlyChild(child)
    return child and child:queryBasicInt("has_upgraded") > 0
end

function HomeChildMgr:MSG_CHILD_BIRTH_ANIMATE(data)

    local furn = HomeMgr:getFurnitureById(data.furniture_pos)
    if data.isPlay ~= 1 then
        self.birthAnimateData = nil

        -- 停止休息动画
        if furn and furn.image then
            furn.image:removeChildByTag(SLEEP_MAGIC_TAG)
        end

        HomeChildMgr.playSleepInHome = nil
        return
    else
        self.birthAnimateData = data
        HomeChildMgr.playSleepInHome = data.id
        --CharMgr:setVisible(false)
        local char = CharMgr:getCharById(data.id)
        if char then
            CharMgr:doCharHideStatus(char)
        end
        HomeMgr:showSleepMagic(furn, nil, GENDER_TYPE.FEMALE, true)
    end
end

function HomeChildMgr:getXinggeChs(xingge)
    return XINGGE_MAP[xingge]
end

function HomeChildMgr:getWuXinChs(wxValue)
    return WUXING_MAP[wxValue]
end

-- 相关界面设置娃娃状态
function HomeChildMgr:setChildZT(data, ztPanel, dlg)
    -- 成长度
    local czBarpanel = dlg:getControl("ProgressPanel", nil, ztPanel)
    if not czBarpanel then czBarpanel = dlg:getControl("GrowthPanel", nil, ztPanel) end
    if czBarpanel then
        if data.stage == HomeChildMgr.CHILD_TYPE.BABY then
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 1000, czBarpanel)
        elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 200, czBarpanel)
        else
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 100, czBarpanel)
        end
    end

    -- 饱食度
    local bsdPanel = dlg:getControl("SatiationPanel", nil, ztPanel)
    if bsdPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.feed, 100, bsdPanel)
    end

    -- 清洁度
    local qjdPanel = dlg:getControl("CleanPanel", nil, ztPanel)
    if qjdPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.clean, 100, qjdPanel)
    end

    -- 心情度
    local xqdPanel = dlg:getControl("HappyPanel", nil, ztPanel)
    if xqdPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.happy, 100, xqdPanel)
    end

    -- 健康度
    local jkdPanel = dlg:getControl("HealthyPanel", nil, ztPanel)
    if jkdPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.health, 100, jkdPanel)
    end

    -- 疲劳度
    local pldPanel = dlg:getControl("FatiguePanel", nil, ztPanel)
    if pldPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.fatigue, 100, pldPanel)
    end

    -- 亲密
    local qmdPanel = dlg:getControl("IntimacyPanel", nil, ztPanel)
    if qmdPanel then
        dlg:setLabelText("NumLabel", data.intimacy, qmdPanel)

        qmdPanel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                dlg:setCtrlVisible("TouchImage", true, sender)
            elseif eventType == ccui.TouchEventType.ended then
                dlg:setCtrlVisible("TouchImage", false, sender)
                gf:showTipInfo(CHS[7120212], sender)
            elseif eventType == ccui.TouchEventType.canceled then
                dlg:setCtrlVisible("TouchImage", false, sender)
            end
        end)
    end

    -- 悟性
    local wxPanel = dlg:getControl("TalentPanel", nil, ztPanel)
    if wxPanel then
        dlg:setLabelText("TypeLabel", HomeChildMgr:getWuXinChs(data.wuxing), wxPanel)
    end

    -- 性格
    local xgPanel = dlg:getControl("DispositionPanel", nil, ztPanel)
    if xgPanel then
        dlg:setLabelText("TypeLabel", HomeChildMgr:getXinggeChs(data.xingge), xgPanel)
    end

    -- 状态
    if dlg.name == "KidRearingDlg" then
        dlg:setCtrlVisible("IllPanel", data.healthStage ~= 0, ztPanel)
        dlg:setCtrlVisible("DispositionPanel", data.healthStage == 0, ztPanel)
        if data.healthStage > 0 then
            local ycPanel = dlg:getControl("IllPanel", nil, ztPanel)
            dlg:setLabelText("TypeLabel", HomeChildMgr:getHealthChs(data.healthStage), ycPanel)
        end
    end

end

function HomeChildMgr:getHealthChs(health)
    if health == 1 then
        return CHS[4101320]--"生病"
    elseif health == 2 then
        return CHS[4101321]--"失眠"
    end

    return ""
end

function HomeChildMgr:setChildZZ(data, zzPanel, dlg)
    -- 物攻
    local phyPanel = dlg:getControl("PhyEffectPanel", nil, zzPanel)
    if phyPanel then
        dlg:setLabelText("NumLabel", data.phy_power or 0, phyPanel)
    end

    -- 法攻
    local magPanel = dlg:getControl("MagEffectPanel", nil, zzPanel)
    if magPanel then
        dlg:setLabelText("NumLabel", data.mag_power or 0, magPanel)
    end

    -- 速度
    local speedPanel = dlg:getControl("SpeedEffectPanel", nil, zzPanel)
    if speedPanel then
        dlg:setLabelText("NumLabel", data.speed or 0, speedPanel)
    end

    -- 法力
    local manaPanel = dlg:getControl("ManaEffectPanel", nil, zzPanel)
    if manaPanel then
        dlg:setLabelText("NumLabel", data.mana or 0, manaPanel)
    end

    -- 血量
    local lefePanel = dlg:getControl("LifeEffectPanel", nil, zzPanel)
    if lefePanel then
        dlg:setLabelText("NumLabel", data.life or 0, lefePanel)
    end

    -- 亲密
    local qmdPanel = dlg:getControl("IntimacyPanel", nil, zzPanel)
    if qmdPanel then
        dlg:setLabelText("NumLabel", data.intimacy, qmdPanel)
    end

    -- 总资质
    local allEffectPanel = dlg:getControl("TotalEffectPanel", nil, zzPanel)
    if allEffectPanel then
        local allEffect = (data.phy_power or 0)
            + (data.mag_power or 0)
            + (data.speed or 0)
            + (data.mana or 0)
            + (data.life or 0)
        dlg:setLabelText("NumLabel", allEffect, allEffectPanel)
    end

    -- 悟性
    local wxPanel = dlg:getControl("TalentPanel", nil, zzPanel)
    if wxPanel then
        dlg:setLabelText("TypeLabel", self:getWuXinChs(data.wuxing), wxPanel)
    end

    -- 性格
    local xgPanel = dlg:getControl("DispositionPanel", nil, zzPanel)
    if xgPanel then
        dlg:setLabelText("TypeLabel", HomeChildMgr:getXinggeChs(data.xingge), xgPanel)
    end
    -- 状态
    --[[

    if dlg.name == "KidRearingDlg" then
        dlg:setCtrlVisible("IllPanel", data.healthStage ~= 0, zzPanel)
        dlg:setCtrlVisible("DispositionPanel", data.healthStage == 0, zzPanel)
        if data.healthStage > 0 then
            local ycPanel = dlg:getControl("IllPanel", nil, zzPanel)
            dlg:setLabelText("TypeLabel", HomeChildMgr:getHealthChs(data.healthStage), ycPanel)
        end
    end
--]]
    -- 健康度
    local jkdPanel = dlg:getControl("HealthyPanel", nil, zzPanel)
    if jkdPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.health, 100, jkdPanel)
    end

    -- 疲劳度
    local pldPanel = dlg:getControl("FatiguePanel", nil, zzPanel)
    if pldPanel then
        dlg:setProgressBarForSelf("ProgressBar", data.fatigue, 100, pldPanel)
    end

    -- 成长度
    local czBarpanel = dlg:getControl("ProgressPanel", nil, zzPanel)
    if not czBarpanel then czBarpanel = dlg:getControl("GrowthPanel", nil, zzPanel) end

    if czBarpanel then
        if data.stage == HomeChildMgr.CHILD_TYPE.BABY then
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 1000, czBarpanel)
        elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 200, czBarpanel)
        else
            dlg:setProgressBarForSelf("ProgressBar", data.mature, 100, czBarpanel)
        end

  --      gf:ShowSmallTips(data.stage)
    end
end

function HomeChildMgr:MSG_CHILD_RAISE_INFO(data)

    data.stage = HomeChildMgr.CHILD_TYPE.BABY

    local arrangedCount = 0

    -- 由于服务器下发数据需要转化，所以处理下
    local completedToday = {}   -- 今日已经完成次数需要自己加上去， 服务器又该了！！

    local history_sch_count = 0
    for _, tempInfo in pairs(data.special_sch_data) do
        history_sch_count = history_sch_count + tempInfo.cur_times
    end

    local ret = {}
    ret.completedToday = completedToday
    ret.todayData = {}
    for i = 1, data.today_sch_count do
        local startTime = data.today_sch_data[i].start_time
        local sch_type = data.today_sch_data[i].sch_type
        local unitData = gf:deepCopy(SCHEDULE_INFO[sch_type])
        if not unitData then unitData = {} end
        unitData.sch_type = sch_type
        unitData.startTime = startTime

        local h = tonumber(gf:getServerDate("%H", startTime))
        unitData.timeStr = string.format(CHS[4101446], h)

        if SCHEDULE_INFO[sch_type] and SCHEDULE_INFO[sch_type].isNeedServerData then
            local num1 = completedToday[sch_type] or 0
            local num2 = data.special_sch_data[sch_type] and data.special_sch_data[sch_type].cur_times or 0
            local completed = num1 + num2
            unitData.completed = completed
            unitData.completedPara = data.special_sch_data.sch_type and data.special_sch_data[sch_type].para
            unitData.showDesc = string.format(unitData.desc, completed)
        else
            unitData.showDesc = unitData.desc
        end

        if sch_type == HomeChildMgr.SCHE_TYPE.NONE then
            unitData.name = CHS[4101358]
            unitData.showDesc = ""
        else
            if data.today_sch_data[i].isClose ~= 2 then
                arrangedCount = arrangedCount + 1
            end
        end

        table.insert(ret.todayData, unitData)
	end

    ret.tomorrowData = {}
    for i = 1, data.tomorrow_sch_count do
        local startTime = data.tomorrow_sch_data[i].start_time
        local sch_type = data.tomorrow_sch_data[i].sch_type
        local unitData = gf:deepCopy(SCHEDULE_INFO[sch_type])
        if not unitData then unitData = {} end
        unitData.sch_type = sch_type
        unitData.startTime = startTime
        local h = tonumber(gf:getServerDate("%H", startTime))
        unitData.timeStr = string.format(CHS[4101446], h)
        if SCHEDULE_INFO[sch_type] and SCHEDULE_INFO[sch_type].isNeedServerData then
            local num1 = completedToday[sch_type] or 0
            local num2 = data.special_sch_data[sch_type] and data.special_sch_data[sch_type].cur_times or 0
            local completed = num1 + num2
            unitData.completed = completed
            unitData.completedPara = data.special_sch_data.sch_type and data.special_sch_data.sch_type.para
            unitData.showDesc = string.format(unitData.desc, completed)
        else
            unitData.showDesc = unitData.desc
        end

        if sch_type == HomeChildMgr.SCHE_TYPE.NONE then
            unitData.name = CHS[4101358]
            unitData.showDesc = ""
        else
            arrangedCount = arrangedCount + 1
        end

        table.insert(ret.tomorrowData, unitData)
	end

    ret.arrangedCount = arrangedCount + history_sch_count
    data.ret = ret

    if not DlgMgr:getDlgByName("KidRearingDlg") then
        DlgMgr:openDlgEx("KidRearingDlg", data)
    else
        DlgMgr:sendMsg("KidRearingDlg", "MSG_CHILD_RAISE_INFO", data)
    end
end

function HomeChildMgr:MSG_PLAY_EFFECT_DIGIT(data)
    gf:ShowAttrSmallTips(data)
end

function HomeChildMgr:MSG_CHILD_POSITION(data)
    if data.type == 1 then
        local str = string.format("#Z|%s(%d,%d)|H=%s|$3|endCallBackFuncForSwitchLine=fuy:%s#Z", data.map_name, data.x, data.y,data.home_id,  data.child_id)
        local dest = gf:findDest(str)
        dest.action = "$3"
        AutoWalkMgr:beginAutoWalk(dest)
    else
        local str = string.format( "#Z|%s(%d,%d)|H=%s|endCallBackFuncForSwitchLine=fuy:%s|$3#Z", data.map_name, data.x, data.y, data.home_id, data.child_id)
        local dest = gf:findDest(str)

        local function endWalk( para )
            performWithDelay(gf:getUILayer(), function ()
                local char = CharMgr:getCharById(para)
                if char then char:onClickChar() end
            end)
        end
        AutoWalkMgr:beginAutoWalk(dest)
    end
end

function HomeChildMgr:endCallBackForTakeCareBaby(id)
    local char = CharMgr:getCharById(tonumber(id))
    if char then
        AutoWalkMgr:updateUnFlyAutoWalkInfo()

        -- 停止走动和寻路。因为后面要 furn:startAutoWalk() 所以提前停止
        AutoWalkMgr:endAutoWalk()
        AutoWalkMgr:endRandomWalk()
        char:onClickChar()
    end
end

function HomeChildMgr:endCallBackForfy(id)
    gf:CmdToServer("CMD_CHILD_REQUEST_RAISE_INFO", {child_id = id, type = 1, para = ""})
end

function HomeChildMgr:MSG_CHILD_LIST(data)

    table.sort(data.childInfo, function(l, r)
        if l.intimacy > r.intimacy then return true end
        if l.intimacy < r.intimacy then return false end
    end)
    DlgMgr:openDlgEx("SubmitChildDlg", data)
end

function HomeChildMgr:MSG_CHILD_MONEY(data)
    DlgMgr:sendMsg("KidRearingDlg", "updateMoney", data)
    DlgMgr:sendMsg("KidInfoDlg", "updateMoney", data)
end

function HomeChildMgr:MSG_CHILD_JOIN_FAMILY_SUCC(data)
    local dlg = DlgMgr:getDlgByName("KidApprenticeDoneDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("KidApprenticeDoneDlg")
    end

    dlg:setData(data)
end

-- 设置娃娃主人属性
function HomeChildMgr:setKidOwner(data)
    if data.id < 0 or data.owner_id < 0 then
        return
    end

    if 0 == data.owner_id or data.owner_id ~= Me:getId() then
        -- 删除娃娃
        self:deleteKid(data.id)
        return
    end

    local kid = self:getKidById(data.id)
    if kid then
        kid:setBasic('owner_id', data.owner_id)
    end
end

function HomeChildMgr:deleteKid(id)
    local kid = self:getKidById(id)
    if kid then
        local cid = kid:queryBasic("cid")
        if self.childData and self.childData[cid] then
            self.childData[cid] = nil
        end

        kid:cleanup()
        self.kids[id] = nil
    end
end

function HomeChildMgr:addKid(data)
    local id = data.id
    if id < 0 then
        Log:W('Invalid child id:' .. id)
        return
    end

    local kid = self.kids[id]
    if kid then
        -- 先保存不需要更新的信息
        local noUpInfo = {}
        noUpInfo['def_pet_skill'] = kid:queryBasicInt('def_pet_skill')
        noUpInfo['def_sel_skill_no'] = kid:queryBasicInt('def_sel_skill_no')
        kid:absorbBasicFields(data)
        kid:absorbBasicFields(noUpInfo)
    else
        for myKidId, myKid in pairs(self.kids) do
            -- 避免在界面中显示两只或以上完全相同的宠物
            if myKid:queryBasic("iid_str") == data.iid_str then
                self:deleteKid(myKidId)
                break
            end
        end

        local kid = Kid.new()
        self.kids[id] = kid
        kid:absorbBasicFields(data)

        DlgMgr:sendMsg("HeadDlg", "resetPetHeadImgAndUpdate")
    end

    -- 娃娃状态变化，或者获得儿童期的娃娃，需要更新主界面娃娃图标的显示
    DlgMgr:sendMsg("HeadDlg", "updateChildPanelShow")
end

function HomeChildMgr:MSG_SET_CHILD_OWNER(data)
    self:setKidOwner(data)
end

function HomeChildMgr:MSG_UPDATE_CHILDS(data)
    for i = 1, data.count do
        self:addKid(data[i])
    end
end

function HomeChildMgr:MSG_SET_COMBAT_CHILD(data)
    self.combatKidId = data.id

    DlgMgr:sendMsg("HeadDlg", "updateChildPanelShow")
    DlgMgr:sendMsg("KidInfoDlg", "updateFollowButton")

    if data.out_combat ~= 1 then
        DlgMgr:sendMsg("HeadDlg", "resetPetHeadImgAndUpdate")
    end

    PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_KID_FLY, nil, nil, true)
end

function HomeChildMgr:MSG_SET_VISIBLE_CHILD(data)
    self.visibleKidId = data.id
end

function HomeChildMgr:MSG_CHILD_PRE_ASSIGN_ATTRIB(data)
    local dlg = DlgMgr:getDlgByName("ChildAutoAddPointDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("ChildAutoAddPointDlg")
        dlg:setData(data.cid)
    end
end

function HomeChildMgr:MSG_CHILD_UPGRADE_PRE_INFO(data)
    local dlg = DlgMgr:openDlg("ChildFlyItemDlg")
    dlg:setData(data)
end

function HomeChildMgr:MSG_CHILD_UPGRADE_SUCC(data)
    DlgMgr:closeDlg("ChildFlyItemDlg")
    local dlg = DlgMgr:openDlg("ChildFlyDoneDlg")
    dlg:setData(data)
end

function HomeChildMgr:MSG_CHILD_CARD_INFO(data)
    local dlg = DlgMgr:getDlgByName("ChildCardDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("ChildCardDlg")
        dlg:setData(data)
    end
end

function HomeChildMgr:setMainDlgVisibleFalse()
    if DlgMgr:getDlgByName("ChildDailyMission1Dlg") or DlgMgr:getDlgByName("ChildDailyMission2Dlg") or DlgMgr:getDlgByName("ChildDailyMission3Dlg") or DlgMgr:getDlgByName("ChildDailyMission5Dlg") then
        -- 隐藏主界面相关操作
        CharMgr:doCharHideStatus(Me)
        self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()

        local dlgTab = {
            ["LoadingDlg"] = 1,
            ["ChildDailyMission1Dlg"] = 1,
            ["ChildDailyMission2Dlg"] = 1,
            ["ChildDailyMission3Dlg"] = 1,
            ["ChildDailyMission5Dlg"] = 1,
        }

        DlgMgr:showAllOpenedDlg(false, dlgTab)
    end
end


function HomeChildMgr:MSG_CHILD_STOP_GAME(data)
    DlgMgr:closeDlg("ChildDailyMission1Dlg")
    DlgMgr:closeDlg("ChildDailyMission2Dlg")
    DlgMgr:closeDlg("ChildDailyMission3Dlg")
    DlgMgr:closeDlg("ChildDailyMission5Dlg")
end

function HomeChildMgr:MSG_CHILD_START_GAME(data)

    if data.task_name == CHS[4101491] then  -- 【养育】踩影子
    else
        Me:setPos(gf:convertToClientSpace(data.x, data.y))
        Me:setLastMapPos(data.x, data.y)
        DlgMgr:showLoadingDlgAction()
    end

    performWithDelay(gf:getUILayer(), function ( )
        if data.task_name == CHS[4101490] then
            DlgMgr:openDlgEx("ChildDailyMission1Dlg", data) --  -- 【养育】论道
        elseif data.task_name == CHS[4101491] then
            DlgMgr:openDlgEx("ChildDailyMission2Dlg", data) -- 【养育】踩影子
        elseif data.task_name == CHS[4101492] then
            DlgMgr:openDlgEx("ChildDailyMission3Dlg", data) -- 【养育】动物的朋友

        elseif data.task_name == CHS[4101493] then
                    DlgMgr:openDlgEx("ChildDailyMission5Dlg", data)     -- 【养育】慧眼识娃
        end
        DlgMgr.normalDlgState = 0--定义见 NORMAL_DLG_STATE
    end, 0.1)


end

function HomeChildMgr:isInDailyTask()
    if DlgMgr:getDlgByName("ChildDailyMission1Dlg") then return true end
    if DlgMgr:getDlgByName("ChildDailyMission2Dlg") then return true end
    if DlgMgr:getDlgByName("ChildDailyMission3Dlg") then return true end
    if DlgMgr:getDlgByName("ChildDailyMission5Dlg") then return true end
end


function HomeChildMgr:MSG_CHILD_CLICK_TASK_LOG(data)
    if data.room_id == 0 then
        --gf:CmdToServer('CMD_HOUSE_GO_HOME')
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5420212]))
        return
    end

    gf:CmdToServer("CMD_TELEPORT", {
        map_id = data.room_id, -- 此处不能使用map_id
        x = 0,
        y = 0,
        isTaskWalk = 0,
    })


end


function HomeChildMgr:getEffectByToyName(itemName)

    local pos = gf:findStrByByte(itemName, "（")
    local name = string.sub(itemName, 0, pos - 1)
    local field = FIELD_MAP[name]

    local pos2 = gf:findStrByByte(itemName, "）")
    local color = string.sub(itemName, pos + 3, pos2 - 1)
    local qua = QUALITY_COLOR[color]
    local cfg = ToyEffect[field]
    local lv = math.floor( Me:queryBasicInt("level") / 10 )
    lv = math.min( lv, 11)
    return cfg[lv][qua]
end

MessageMgr:regist("MSG_CHILD_STOP_GAME", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_CARD_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_CULTIVATE_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_CLICK_TASK_LOG", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_START_GAME", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_UPGRADE_PRE_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_UPGRADE_SUCC", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_PRE_ASSIGN_ATTRIB", HomeChildMgr)
MessageMgr:regist("MSG_SET_VISIBLE_CHILD", HomeChildMgr)
MessageMgr:regist("MSG_SET_CHILD_OWNER", HomeChildMgr)
MessageMgr:regist("MSG_SET_COMBAT_CHILD", HomeChildMgr)
MessageMgr:regist("MSG_UPDATE_CHILDS", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_JOIN_FAMILY_SUCC", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_MONEY", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_LIST", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_POSITION", HomeChildMgr)
MessageMgr:regist("MSG_PLAY_EFFECT_DIGIT", HomeChildMgr)

MessageMgr:regist("MSG_CHILD_RAISE_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_BIRTH_STONE", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_BIRTH_ANIMATE", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_BIRTH_HUSBAND_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_BIRTH_INFO", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_BIRTH_RESULT", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_INJECT_ENERGY", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_LOG", HomeChildMgr)
MessageMgr:regist("MSG_CHILD_INFO", HomeChildMgr)

