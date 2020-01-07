-- LingChongHuanJingMgr.lua
-- Created by lixh Api/08/2018
-- 灵宠幻境管理器

LingChongHuanJingMgr = Singleton()

-- 幻境编号
local LCHJ_TYPE = {
    GULI        = "gulijing",    -- 孤离境,
    GOULIAN     = "goulianjing", -- 钩镰境,
    QIXI        = "qixijing",    -- 奇袭境,
    DAOXIN      = "daoxinjing",  -- 道心境,
    WUXIN       = "wuxingjing",  -- 五行境,
    SHENGSI     = "shengsijing", -- 生死境,
    QIMEN       = "qimenjing",   -- 奇门境,
    WUYOU       = "wuyoujing",   -- 无忧境,
    XUANRENG    = "xuanrenjing", -- 悬刃境,
}

-- 幻境基本信息配置
local LCHJ_CONFIG = {
    [LCHJ_TYPE.GULI]     = {name = CHS[7100233], icon = ResMgr.ui.lchj_guli_icon,     nameIcon = ResMgr.ui.lchj_guli},     -- 孤离境
    [LCHJ_TYPE.GOULIAN]  = {name = CHS[7100234], icon = ResMgr.ui.lchj_goulian_icon,  nameIcon = ResMgr.ui.lchj_goulian},  -- 钩镰境
    [LCHJ_TYPE.QIXI]     = {name = CHS[7100235], icon = ResMgr.ui.lchj_qixi_icon,     nameIcon = ResMgr.ui.lchj_qixi},     -- 奇袭境
    [LCHJ_TYPE.DAOXIN]   = {name = CHS[7100236], icon = ResMgr.ui.lchj_daoxin_icon,   nameIcon = ResMgr.ui.lchj_daoxin},   -- 道心境
    [LCHJ_TYPE.WUXIN]    = {name = CHS[7100237], icon = ResMgr.ui.lchj_wuxing_icon,   nameIcon = ResMgr.ui.lchj_wuxing},   -- 五行境
    [LCHJ_TYPE.SHENGSI]  = {name = CHS[7100238], icon = ResMgr.ui.lchj_shengsi_icon,  nameIcon = ResMgr.ui.lchj_shengsi},  -- 生死境
    [LCHJ_TYPE.QIMEN]    = {name = CHS[7100239], icon = ResMgr.ui.lchj_qimen_icon,    nameIcon = ResMgr.ui.lchj_qimen},    -- 奇门境
    [LCHJ_TYPE.WUYOU]    = {name = CHS[7100240], icon = ResMgr.ui.lchj_wuyou_icon,    nameIcon = ResMgr.ui.lchj_wuyou},    -- 无忧境
    [LCHJ_TYPE.XUANRENG] = {name = CHS[7100241], icon = ResMgr.ui.lchj_xuanreng_icon, nameIcon = ResMgr.ui.lchj_xuanreng}, -- 悬刃境
}

-- 幻境挑战状态
local LCHJ_STATE = {
    SELECT_NOT_DO = 0, -- 已选中，但未进入战斗
    DOING = 1,         -- 已选中，已进入战斗
    PASS = 2,          -- 已通过
    NOT_DO = 3,        -- 未开启
}

-- 等级要求
local LCHJ_LEVEL_REQUEST = 70

-- 宠物禁用技能信息
LingChongHuanJingMgr.petNotInUseSkills = {}

-- 挑战关卡信息
LingChongHuanJingMgr.stageData = nil

-- 获取当前挑战关卡
function LingChongHuanJingMgr:getCurStage()
    if not self.stageData then return 1 end
    return self.stageData.curStage
end

-- 计算当前关卡下标
function LingChongHuanJingMgr:getCurStageIndex()
    local curStage = LingChongHuanJingMgr:getCurStage()
    local stageInfo = self.stageData
    for i = 1, stageInfo.count do
        if stageInfo.list[i] and stageInfo.list[i].name == curStage then
            return i
        end
    end

    return 1
end

-- 获取幻境配置
function LingChongHuanJingMgr:getHuanJingCfg(type)
    return LCHJ_CONFIG[type]
end

-- 获取幻境状态配置
function LingChongHuanJingMgr:getHuanJingStateCfg()
    return LCHJ_STATE
end

-- 获取幻境等级要求
function LingChongHuanJingMgr:getHuanJingLevelRequest()
    return LCHJ_LEVEL_REQUEST
end

-- 判断宠物，技能是否正在使用
function LingChongHuanJingMgr:isSkillCanUse(petNo, skillId)
    local notInUseSkillData = self.petNotInUseSkills[petNo]
    if notInUseSkillData then
        for i = 1, notInUseSkillData.count do
            if skillId == notInUseSkillData.list[i] then
                return false
            end
        end
    end

    return true
end

-- 幻境界面关卡数据
function LingChongHuanJingMgr:MSG_LCHJ_INFO(data)
    -- 保存挑战关卡信息
    self.stageData = data

    local dlg = DlgMgr:getDlgByName("LingChongDlg")
    if dlg then
        dlg:refreshDlgInfo(data)
    else
        if data.isMustOpenDlg == 1 then
            dlg = DlgMgr:openDlg("LingChongDlg")
            dlg:refreshDlgInfo(data)
        end
    end
end

-- 幻境界面布阵信息
function LingChongHuanJingMgr:MSG_LCHJ_PETS_INFO(data)
    local dlg = DlgMgr:openDlg("LingChongOrderDlg")
    dlg:setData(data)
end

-- 幻境宠物禁用技能信息
function LingChongHuanJingMgr:MSG_LCHJ_DISABLE_SKILLS(data)
    if data and data.no then
        self.petNotInUseSkills[data.no] = data
    end
end

MessageMgr:regist("MSG_LCHJ_INFO", LingChongHuanJingMgr)
MessageMgr:regist("MSG_LCHJ_PETS_INFO", LingChongHuanJingMgr)
MessageMgr:regist("MSG_LCHJ_DISABLE_SKILLS", LingChongHuanJingMgr)

