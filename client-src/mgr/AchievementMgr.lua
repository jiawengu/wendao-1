-- AchievementMgr.lua
-- created by songcw Sep/14/2017
-- 成就管理器

AchievementMgr = Singleton()
local AchievementCfg = require (ResMgr:getCfgPath("AchievementCfg.lua"))

AchievementMgr.autoDisplayAchieve = {}

-- 二级菜单对应进度值，需要从两个消息中取
AchievementMgr.achieveSecondData = {}

-- 成就配置信息
AchievementMgr.achievements = {}

-- 成就数据
AchievementMgr.achieveData = {}

AchievementMgr.CATEGORY = {
    AHVE_CG_RWCZ        = 1,    -- 人物成长
    [1] = CHS[4100819],
    [CHS[4100819]] = 1,

    AHVE_CG_HBPY        = 2,    -- 伙伴培养
    [2] = CHS[4100820],
    [CHS[4100820]] = 2,

    AHVE_CG_ZBDZ        = 3,    -- 装备打造
    [3] = CHS[4100821],
    [CHS[4100821]] = 3,

    AHVE_CG_RWSJ        = 4,    -- 人物社交
    [4] = CHS[4100822],
    [CHS[4100822]] = 4,
    AHVE_CG_RWHD        = 5,    -- 任务活动
    [5] = CHS[4100823],
    [CHS[4100823]] = 5,
    AHVE_CG_ZZYS        = 6,    -- 中洲轶事
    [6] = CHS[4100824],
    [CHS[4100824]] = 6,

    AHVE_CG_RWCZ_DJ     = 101,     -- 等级
    [101] = CHS[4100804],
    AHVE_CG_RWCZ_JN     = 102,     -- 技能
    [102] = CHS[6000164],
    AHVE_CG_RWCZ_DH     = 103,     -- 道行
    [103] = CHS[4100805],
    AHVE_CG_RWCZ_ZD     = 104,     -- 战斗
    [104] = CHS[4100806],
    AHVE_CG_RWCZ_JQ     = 105,     -- 金钱
    [105] = CHS[6000080],

    AHVE_CG_HBPY_CW     = 201,     -- 宠物
    [201] = CHS[4100807],
    AHVE_CG_HBPY_SH     = 202,     -- 守护
    [202] = CHS[4100808],

    AHVE_CG_ZBDZ_ZB     = 301,     -- 装备
    [301] = CHS[7002314],
    AHVE_CG_ZBDZ_SS     = 302,     -- 首饰
    [302] = CHS[7002313],
    AHVE_CG_ZBDZ_FB     = 303,     -- 法宝
    [303] = CHS[7000144],

    AHVE_CG_RWSJ_HY     = 401,     -- 好友
    [401] = CHS[7002308],
    AHVE_CG_RWSJ_BP     = 402,     -- 帮派
    [402] = CHS[6000149],
    AHVE_CG_RWSJ_GX     = 403,     -- 人物关系
    [403] = CHS[4100809],
    AHVE_CG_RWSJ_BLOG   = 404,     -- 个人空间
    [404] = CHS[7150017],


    AHVE_CG_RWHD_JQ     = 501,     -- 剧情任务
    [501] = CHS[4100810],
    AHVE_CG_RWHD_RC     = 502,     -- 日常活动
    [502] = CHS[4100811],
    AHVE_CG_RWHD_JR     = 503,     -- 节日活动
    [503] = CHS[4100812],
    AHVE_CG_RWHD_QT     = 504,     -- 其他活动
    [504] = CHS[4100813],


    AHVE_CG_ZZYS_QW     = 601,     -- 趣闻
    [601] = CHS[4100814],
    AHVE_CG_ZZYS_SY     = 602,     -- 光辉岁月
    [602] = CHS[4100815],
    AHVE_CG_ZZYS_JB     = 603,     -- 绝版成就
    [603] = CHS[4100942],
}

-- 清空数据
function AchievementMgr:clearData()
    self.autoDisplayAchieve = {}
    AchievementMgr.achieveData = {}
end

-- 将自动播放成就列表情况
function AchievementMgr:removeAllDisplayAchieve()
    self.autoDisplayAchieve = {}
end

function AchievementMgr:removeAchieveCompByName(name)
    for _, data in pairs(self.autoDisplayAchieve) do
        if data.achieve_name == name then
            table.remove(self.autoDisplayAchieve, _)
            return
        end
    end
end

function AchievementMgr:stopAutoComp()
    if self.nextAchieve then
        gf:getUILayer():stopAction(self.nextAchieve)
        self.nextAchieve = nil
    end

    AchievementMgr:removeAllDisplayAchieve()
end

-- 打开下一个成就
function AchievementMgr:openNextAchieve()
    if not next(self.autoDisplayAchieve) then return end

    if not next(self.achievements) then return end

    if GuideMgr:isRunning() then return end

    self.nextAchieve = performWithDelay(gf:getUILayer(), function ()
        if not next(self.autoDisplayAchieve) then return end
        local dlg = DlgMgr:openDlg("AchievementCompleteDlg")
        dlg:setData(self.autoDisplayAchieve[1])
    end, 0.3)
end

-- 客户端请求领取成就奖励
function AchievementMgr:getBonus()
    gf:CmdToServer("CMD_ACHIEVE_BONUS")
end

-- 请求成就配置
function AchievementMgr:queryAchieveCfg()
    if not AchievementMgr.achieveSecondData or not next(AchievementMgr.achieveSecondData) then
        gf:CmdToServer("CMD_ACHIEVE_CONFIG")
    end
end

-- 请求成就配置, 若有achieve_id需要默认选中
function AchievementMgr:queryAchieveOverView()
    gf:CmdToServer("CMD_ACHIEVE_OVERVIEW")
end

-- 请求成就配置
function AchievementMgr:queryAchieveByCategory(cType)
    gf:CmdToServer("CMD_ACHIEVE_VIEW", {category = cType})
end

function AchievementMgr:MSG_ACHIEVE_FINISHED(data)
    if DlgMgr:isDlgOpened("AchievementCompleteDlg") or next(self.autoDisplayAchieve) then
        table.insert(self.autoDisplayAchieve, data)
    else
        if not next(self.achievements) then
            local msg = gf:getServerTime() .. "|" .. data.achieve_id .. "|" .. DebugMgr:getLastRecAchieveConfigTime()
            gf:sendErrInfo(ERR_OCCUR.ACHIEVEMENT_NO_CONFIG, msg)
            return
        end
        local dlg = DlgMgr:openDlg("AchievementCompleteDlg")
        dlg:setData(data)
    end
end

function AchievementMgr:getAchieveInfoById(id)
    return AchievementMgr.achievements[id]
end



function AchievementMgr:MSG_ACHIEVE_OVERVIEW(data)
    for _, lastData in pairs(data.last_achieve) do
        local achieve = AchievementMgr:getAchieveInfoById(lastData.achieve_id)
        lastData.order = achieve.order
    end

    AchievementMgr.achieveOverViewData = data

    AchievementMgr:stopAutoComp()
    DlgMgr:closeDlg("AchievementCompleteDlg")

    local last = DlgMgr:getLastDlgByTabDlg('AchievementTabDlg') or 'AchievementListDlg'
    DlgMgr:openDlg(last)


end

function AchievementMgr:getKeyByCategory(category)

    local bigCate = math.floor(category / 100)
    local bigStr = AchievementMgr.CATEGORY[bigCate]

    local sStr = AchievementMgr.CATEGORY[category]
    return string.format("%s-%s", bigStr, sStr)
end

function AchievementMgr:getKeyById(id)
    -- 其实单个成就配置就又类别，但是是后来加的，不改动太多代码，再通过id获取下类别
    local ach = AchievementMgr:getAchieveInfoById(id)

    local category = ach.category
    return AchievementMgr:getKeyByCategory(category)
end

-- 获取原始的类别
function AchievementMgr:getRawKeyById(id)
    local category = math.floor(id / 1000)
    return AchievementMgr:getKeyByCategory(category)
end

function AchievementMgr:getRawInfoByIdName(id, name)
    local cateStr = AchievementMgr:getRawKeyById(id)
    local infos = AchievementCfg["INFO"][cateStr]
    for keyName, unitData in pairs(infos) do
        if keyName == name then
            return unitData
        end
    end
end

-- 增加绝版成就标识
function AchievementMgr:addJBCJImageByCategory(ctr, category)
    if category ~= AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
        return
    end

    local sp = ctr:getChildByName("addJBCJImage")
    if sp then return end

    local polarPath = ResMgr.ui.achieve_jueban_word
    local sp = ccui.ImageView:create()
    sp:loadTexture(polarPath)
    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(size.width - spSize.width - 2, spSize.height + 5)
    sp:setName("addJBCJImage")
    ctr:addChild(sp)
end

function AchievementMgr:getIconById(id)

    local cateStr = AchievementMgr:getOrgKey(id)
    local icon = AchievementCfg["MENU_ICON"][cateStr]
    return icon
end

-- 该接口是用于绝版成就获取原始类别
function AchievementMgr:getOrgKey(id)
    local bigCate = math.floor(id / 100000)
    local bigStr = AchievementMgr.CATEGORY[bigCate]

    local sCate = math.floor(id / 1000)
    local sStr = AchievementMgr.CATEGORY[sCate]
    return string.format("%s-%s", bigStr, sStr)
end

-- 清除某个大类的所有数据
function AchievementMgr:clearCategoryData(category)
    if not self.achieveData then return end

    local cateName = AchievementMgr.CATEGORY[category]
    for k, v in pairs(self.achieveData) do
        if string.match(k, cateName) then
            self.achieveData[k] = nil
        end
    end
end

function AchievementMgr:MSG_ACHIEVE_CONFIG(data)

    DebugMgr:logAchieveConfigRecTime()

    AchievementMgr.achieveSecondData = {}

    if data.count <= 0 then
        gf:sendErrInfo(ERR_OCCUR.ACHIEVEMENT_NO_CONFIG, CHS[4300331])
    end

    for i = 1, data.count do
        AchievementMgr.achievements[data[i].achieve_id] = data[i]
        local cateStr = AchievementMgr:getKeyByCategory(data[i].category)
        local achieves = AchievementCfg["INFO"][cateStr]

        -- 绝版成就，需要充原始类别中寻找
        if data[i].category == AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
            local cateStr = AchievementMgr:getOrgKey(data[i].achieve_id)
            achieves = AchievementCfg["INFO"][cateStr]
        end

        if not achieves[data[i].name] then
--            gf:ShowSmallTips("注意！！！！，匹配不一致")
--            gf:ShowSmallTips(data[i].name)
        else
            if data[i].achieve_desc == "" then

                if GameMgr.isIOSReview then
                    AchievementMgr.achievements[data[i].achieve_id].achieve_desc = achieves[data[i].name].IOSReview_desc or achieves[data[i].name].achieve_desc
                else
                    AchievementMgr.achievements[data[i].achieve_id].achieve_desc = achieves[data[i].name].achieve_desc
                end
            end
        end

        -- 二级菜单每个总进度值
        if not AchievementMgr.achieveSecondData[cateStr] then
            AchievementMgr.achieveSecondData[cateStr] = {}
            AchievementMgr.achieveSecondData[cateStr].point = 0
            AchievementMgr.achieveSecondData[cateStr].point_max = 0
            AchievementMgr.achieveSecondData[cateStr].task = 0
            AchievementMgr.achieveSecondData[cateStr].task_max = 0
        end

        -- 绝版成就，最大完成点数不计算
        if data[i].category ~= AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
            AchievementMgr.achieveSecondData[cateStr].task_max = AchievementMgr.achieveSecondData[cateStr].task_max + 1
            AchievementMgr.achieveSecondData[cateStr].point_max = AchievementMgr.achieveSecondData[cateStr].point_max + data[i].point
        end
    end
end

function AchievementMgr:MSG_ACHIEVE_VIEW(data)
    local has = {}

    self:clearCategoryData(data.category)
    for i = 1, data.count do
        local cateStr = AchievementMgr:getKeyById(data[i].achieve_id)
        if not AchievementMgr.achieveData[cateStr] then
            AchievementMgr.achieveData[cateStr] = {}
        end

        local achieve = gf:deepCopy(AchievementMgr:getAchieveInfoById(data[i].achieve_id))
        achieve.is_finished = data[i].is_finished
        achieve.progress_or_time = data[i].progress_or_time

        if achieve.target_count > 0 then
            -- 该成就有多个条件
            for j = 1, achieve.target_count do
                if achieve.is_finished == 1 then
                    -- 成就已完成，子目标都设置为完成(客户端需要自己设置，服务器不会再发)
                    achieve.target_list[j].is_finished = true
                else
                    -- 成就未完成，使用子目标数据更新目标是否完成标记
                    local des = achieve.target_list[j].des
                    for k = 1, data[i].target_count do
                        if data[i].target_list[k].des == des then
                            achieve.target_list[j].is_finished = data[i].target_list[k].is_finished
                        end
                    end
                end
            end
        end

        -- 未完成的绝版成就不显示
        if achieve.category == AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB and achieve.is_finished ~= 1 then
        else
            table.insert(AchievementMgr.achieveData[cateStr], achieve)
        end


        has[data[i].achieve_id] = 1

        if not has[cateStr] then
            AchievementMgr.achieveSecondData[cateStr].point = 0
            AchievementMgr.achieveSecondData[cateStr].task = 0
            has[cateStr] = 1
        end

        if achieve.is_finished == 1 then
            AchievementMgr.achieveSecondData[cateStr].point = AchievementMgr.achieveSecondData[cateStr].point + achieve.point
            AchievementMgr.achieveSecondData[cateStr].task = AchievementMgr.achieveSecondData[cateStr].task + 1

            -- 绝版成就，最大完成点数 == 当前点数
            if achieve.category == AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
                AchievementMgr.achieveSecondData[cateStr].task_max = AchievementMgr.achieveSecondData[cateStr].task
                AchievementMgr.achieveSecondData[cateStr].point_max = AchievementMgr.achieveSecondData[cateStr].point
            end
        end
    end

    -- 把服务器未下发的。标记未完成。
    for id, unitCfg in pairs(AchievementMgr.achievements) do


        -- 绝版成就未完成是不添加的         data.category 表示大项，所以 unitCfg.category / 100
        if math.floor(unitCfg.category / 100)  == data.category and unitCfg.category ~= AchievementMgr.CATEGORY.AHVE_CG_ZZYS_JB then
            if not has[unitCfg.achieve_id] then
                local achieve = gf:deepCopy(AchievementMgr:getAchieveInfoById(unitCfg.achieve_id))
                achieve.is_finished = 0
                achieve.progress_or_time = 0
                local cateStr = AchievementMgr:getKeyById(unitCfg.achieve_id)
                if not AchievementMgr.achieveData[cateStr] then
                    AchievementMgr.achieveData[cateStr] = {}
                end
                table.insert(AchievementMgr.achieveData[cateStr], achieve)
            end
        end
    end
end

-- 超级大BOSS的第一滴血
function AchievementMgr:getSuperBossFB()
    return self.superBossInfo
end

function AchievementMgr:getQiShaFB()
    return self.qishaInfo
end

function AchievementMgr:getJiuTianFB()
    return self.jiutianInfo
end

-- 超级大BOSS首杀
function AchievementMgr:MSG_SUPER_BOSS_KILL_FIRST(data)
    self.superBossInfo = data
end

function AchievementMgr:MSG_QISHA_SHILIAN_KILL_FIRST(data)
    self.qishaInfo = data
end

-- 查询超级大boss、七杀首杀记录
-- 代码放在成就管理器好像有点奇怪，但是感觉貌似没有什么也别好的地方
function AchievementMgr:queryFirstSkill()
    gf:CmdToServer("CMD_REQUEST_ALL_KILL_FIRST")
end

-- 九天首杀
function AchievementMgr:MSG_JIUTIAN_ZHENJUN_KILL_FIRST(data)
    self.jiutianInfo = data
end

MessageMgr:regist("MSG_JIUTIAN_ZHENJUN_KILL_FIRST", AchievementMgr)
MessageMgr:regist("MSG_QISHA_SHILIAN_KILL_FIRST", AchievementMgr)
MessageMgr:regist("MSG_SUPER_BOSS_KILL_FIRST", AchievementMgr)
MessageMgr:regist("MSG_ACHIEVE_FINISHED", AchievementMgr)
MessageMgr:regist("MSG_ACHIEVE_VIEW", AchievementMgr)
MessageMgr:regist("MSG_ACHIEVE_CONFIG", AchievementMgr)
MessageMgr:regist("MSG_ACHIEVE_OVERVIEW", AchievementMgr)

