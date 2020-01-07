-- TaskMgr.lua
-- created by cheny Dec/05/2014
-- 任务管理器

local Bitset = require('core/Bitset')
local json = require("json")
TaskMgr = Singleton("TaskMgr")

TaskMgr.tasks = {}
TaskMgr.refreshCmds = {} -- 正在刷新的任务
TaskMgr.curTaskWalkPath = {
    task_type = "",
    task_prompt = "",
} -- 当前任务的寻路，用于是否可以完成任务的判断。

local TaskInfo = require("cfg/TaskInfo")
local TASK_SHUADAO = {
    CHS[3004360],
    CHS[3004361],
    CHS[5120005],
}

-- 副本任务名称
local  FUBEN_TASK_NAME= {
    [CHS[3004362]] = CHS[3004362],  -- 黑风洞
    [CHS[5450304]] = CHS[5450304],  -- 幻境—黑风洞
    [CHS[3004363]] = CHS[3004363],
    [CHS[3004364]] = CHS[3004364],  -- 兰若寺
    [CHS[5450305]] = CHS[5450305], -- 幻境—兰若寺
    [CHS[4100554]] = CHS[4100554],
    [CHS[4010164]] = CHS[4010164],
    [CHS[4010178]] = CHS[4010178]

}

-- 任务栏优先显示的任务
local displayFirstTask = ""

-- 隐藏的任务
TaskMgr.hiddenTasks = {}

-- 需要深度隐藏的任务
local TASK_NEED_TO_DEEP_HIDE = {
    [CHS[7000290]] = true, -- 帮派圈圈乐
    [CHS[3004371]] = true, -- 免死护佑
    [CHS[3004372]] = true, -- 打入天牢
    [CHS[4200010]] = true, -- 千变万化
    ["month_card"] = true, -- 内测活跃福利
    [CHS[4300010]] = true, -- 南荒巫术
    [CHS[7000044]] = true, -- 经验心得
    [CHS[7000045]] = true, -- 道武心得
    [CHS[7000091]] = true, -- 孽债血海
    [CHS[7000069]] = true, -- 坐牢2（监狱）
    [CHS[7000199]] = true, -- 杀气腾腾（PK系统）
    [CHS[4100403]] = true, -- 角色公示期
    [CHS[4200517]] = true, -- 占卜任务
}
-- 百级拜师任务情况，  == nil时打开界面请求信息， 0未完成，1已完成。状态变更，服务器会主动通知
TaskMgr.baijiTaskStatus = nil

-- 功能性任务关键字
local funTask = {
    CHS[3004371], CHS[3004372], CHS[4300010],             -- 免死护佑,      坐牢,         南荒巫术
    CHS[4200122], CHS[6400075], CHS[6400076],             -- 内测活跃福利,  预定婚礼时间,  举办结婚典礼
    CHS[4200010], CHS[2000380], CHS[4300073], CHS[7000044],  -- 千变万化,      美味佳肴,     离婚任务,        经验心得
    CHS[7000045], CHS[7000091], CHS[7000069],             -- 道武心得,      孽债血海,      坐牢2（监狱）,
    CHS[4100403], CHS[7002219], CHS[7002220],             -- 角色公示期,    结拜任务,       提亲
    CHS[7002221], CHS[4200383], CHS[4101058],                           -- 出师任务                  九曲玲珑变身
    CHS[7100223], CHS[7100217], CHS[7100218],             -- 道友请留步        随手一算        虔诚求运
}

-- 剧情任务关键字
local storyTask = {
    CHS[3004368], CHS[3004369], CHS[3004370],             -- 妖魔道,       仙魔录,        历练
    CHS[4100298], CHS[4100317], CHS[7002252],             -- (.+)系拜师任务  伏魔记    幻仙劫
    CHS[8000009], CHS[7002281], CHS[2100085],             -- 鲲鹏变        宠物飞升任务   地劫第(.+)劫
    CHS[4200353], CHS[7190111], CHS[7100118],             -- 飞升—引路人    飞升—仙道难  内丹修炼
    CHS[7100159], CHS[5450107], CHS[4010117],             -- 剑冢机缘  天劫第(.+)劫  南天门试炼
}

-- 节日活动关键字
local festivalTask = {
    CHS[7002091], CHS[7002080], CHS[5400086],             -- 【端午节】   【儿童节】      【七夕节】
    CHS[3004366], CHS[4200123], CHS[4200135],             --  劳动节            【暑假】           【七夕】
    CHS[6000392], CHS[6000406], CHS[4200174],             -- 【中元节】    【教师节】       【中秋】
    CHS[6200057], CHS[6200070], CHS[4300117],             -- 【国庆节】    【重阳节】      【光棍节】
    CHS[5000242], CHS[7000080], CHS[7000162],             -- 【元旦节】      【福利】           【圣诞】
    CHS[7000265], CHS[7000266], CHS[5000259],             -- 【寒假】         本轮圈圈积分    【春节】
    CHS[7000261], CHS[5420074], CHS[7003005],             -- 【元宵节】  【情人节】         【植树节】
    CHS[7002034], CHS[7002040], CHS[7002042],             -- 【清明节】  【愚人节】           【委托】
    CHS[5000279], CHS[5410179], CHS[5420285],             -- 【万圣节】【水岚之缘】    【周年庆】
    CHS[5400605], CHS[4101196], CHS[4400044],             -- 【世界杯】 【元旦】 【福缘】
}

-- 奖励对应的小图标
local SMALL_REWARD_ICON =
{
    [CHS[3002165]] = ResMgr.ui.small_cash,                      -- 默认
    [CHS[3002143]] =   ResMgr.ui.small_cash,                    -- 金钱
    [CHS[3002157]] =   ResMgr.ui.small_banggong,                -- 帮贡
    [CHS[3002147]] =   ResMgr.ui.small_daohang,                 -- 道行
    [CHS[3002166]] =   ResMgr.ui.small_common_item,             -- 物品
    [CHS[3002159]] =  ResMgr.ui.small_party_active,             -- 帮派活力值
    [CHS[3002161]] =  ResMgr.ui.small_party_contribution,       -- 帮派建设度
    [CHS[3002167]] =  ResMgr.ui.small_exp,                      -- 经验
    [CHS[3002151]] =  ResMgr.ui.samll_pot,                      -- 潜能
    [CHS[3002163]] =  ResMgr.ui.small_reputation,               -- 声望
    [CHS[3002168]] =  ResMgr.ui.small_jewelry,                  -- 首饰
    [CHS[3002169]] = ResMgr.ui.small_identify_equip,            -- 未鉴定
    [CHS[3002170]] = ResMgr.ui.small_equip,                     -- 装备
    [CHS[3002149]] = ResMgr.ui.small_wuxue,                     -- 武学
    [CHS[5400594]] = ResMgr.ui.small_tao_wu,                    -- 道武
    [CHS[3002145]] = ResMgr.ui.small_voucher,                   -- 代金券
    [CHS[3002171]] = ResMgr.ui.small_title,                     -- 称谓
    [CHS[3002172]] = ResMgr.ui.samll_common_pet,                -- 宠物
    [CHS[3002173]] = ResMgr.ui.samll_vip_icon,                  -- 会员
    [CHS[65036]] = ResMgr.ui.samll_vip_icon,                  -- 会员
    [CHS[3001789]] = ResMgr.ui.samll_vip_icon,                  -- 会员
    [CHS[3001792]] = ResMgr.ui.samll_vip_icon,                  -- 会员
    [CHS[3001800]] = ResMgr.ui.samll_vip_icon,                  -- 会员
	[CHS[3003805]] = ResMgr.ui.samll_vip_icon,                  -- 会员

    [CHS[6400008]] = ResMgr.ui.small_get_reward,                -- 充值好礼
    [CHS[6200002]] = ResMgr.ui.small_change_card,               -- 变身卡
    [CHS[6000260]] = ResMgr.ui.small_friendly_icon,             -- 友好度
    [CHS[6400052]] = ResMgr.ui.small_skill_icon,                -- 技能
    [CHS[6200024]] = ResMgr.ui.small_off_line_time,             -- 离线时间
    [CHS[4300075]] = ResMgr.ui.small_shuadao_jifen,             -- 刷道积分
    [CHS[6000042]] = ResMgr.ui.small_reward_silver,               -- 银元宝
    [CHS[3002153]] = ResMgr.ui.small_reward_glod,                 -- 金元宝
    [CHS[7000144]] = ResMgr.ui.small_artifact,                  -- 法宝
    [CHS[7000282]] = ResMgr.ui.small_daofa,                     -- 道法
    [CHS[7000284]] = ResMgr.ui.small_ziqihongmeng,              -- 紫气鸿蒙点数
    [CHS[5420113]] = ResMgr.ui.small_gold_rose,                 -- 纯金玫瑰
    [CHS[2000247]] = ResMgr.ui.small_polar_upper,               -- 相性上限
    [CHS[2000248]] = ResMgr.ui.small_level_upper,               -- 等级上限
    [CHS[5420169]] = ResMgr.ui.small_object_reward,             -- 实物
    [CHS[5420170]] = ResMgr.ui.small_call_cost_reward,          -- 话费
    [CHS[5420176]] = ResMgr.ui.small_common_item,               -- 解析家具
    [CHS[4100655]] = ResMgr.ui.small_fashion,                   -- 时装
    [CHS[4100818]] = ResMgr.ui.small_title,                     -- 成就
    [CHS[7100152]] = ResMgr.ui.small_attrib_point,              -- 属性点
    [CHS[7100153]] = ResMgr.ui.small_polar_point,               -- 相性点
    [CHS[5450185]] = ResMgr.ui.small_jewelry_essence,           -- 首饰精华
    [CHS[5400801]] = ResMgr.ui.small_item_lingchen,             -- 灵尘
    [CHS[5420304]] = ResMgr.ui.small_chongfengsan,              -- 宠风散点数
    [CHS[4010118]] = ResMgr.ui.xianmo_point,                    -- 仙魔点
    [CHS[7190229]] = ResMgr.ui.small_tan_an_score,              -- 探案积分
    [CHS[7190534]] = ResMgr.ui.small_qinmidu,                   -- 亲密度
    [CHS[4200712]] = ResMgr.ui.small_child_qinmidu,             -- 亲密度
    [CHS[7120211]] = ResMgr.ui.small_wawazizhi,                 -- 娃娃资质
}

-- 全民PK区组中仅显示以下任务
local TASK_IN_QMPK_SERVER = {
    [CHS[7003043]] = true,
    [CHS[7003044]] = true,
    [CHS[7003045]] = true,
    [CHS[7003046]] = true,
    [CHS[4200383]] = true,
    [CHS[7120158]] = true,
}

-- 争霸娱乐区组中显示的任务
local TASK_IN_ZBYL_SERVER = {
    [CHS[7003046]] = true,
    [CHS[4200383]] = true,
    [CHS[4101051]] = true,
}

local HIDE_FILE_PATH = Const.WRITE_PATH .. "hideTask/"

-- 检查的类型
TaskMgr.CHEKC_TASK = {
    DO_TYPE_NORMAL    = 1,
    NOT_TYPE_NPC_ZONE = 2,
    SHOW_SMALL_TIPS = 3,
}

function TaskMgr:getHideFilePath()
    return HIDE_FILE_PATH .. Me:queryBasic("gid") .. ".lua"
end

function TaskMgr:loadHideTask()
    local path = cc.FileUtils:getInstance():getWritablePath() .. self:getHideFilePath()
    if pcall(function() TaskMgr.hiddenTasks = dofile(path) end) then
    else
        TaskMgr.hiddenTasks = {}
    end

    if not TaskMgr.hiddenTasks then
        TaskMgr.hiddenTasks = {}
    end
end

function TaskMgr:saveHideTask()
    local saveData = ""
    for task_type,task_step in pairs(TaskMgr.hiddenTasks) do
        if string.match(task_step, "\n") then
            local temp = string.gsub(task_step, "\n", "#r")
            saveData = saveData .. "\n['" .. task_type .. "']='" .. temp .. "',\n"
        else
        saveData = saveData .. "\n['" .. task_type .. "']='" .. task_step .. "',\n"
    end
    end

    local file = "return {\n" .. saveData .. "\n}"

    gfSaveFile(file, TaskMgr:getHideFilePath())
end

function TaskMgr:setTheFitstDisplayTask(task_type)
    displayFirstTask = task_type
end

function TaskMgr:getTheFitstDisplayTask()
    return displayFirstTask
end

function TaskMgr:setTaskVisible(task)
    if GameMgr.initDataDone and TaskMgr.hiddenTasks[task.task_type] and TaskMgr.hiddenTasks[task.task_type] ~= task.task_prompt then
        if TASK_NEED_TO_DEEP_HIDE[task.task_type] then
            -- 某些任务即使状态发生变化，也不能取消隐藏状态
            if string.len(task.task_prompt) == 0 then
                TaskMgr.hiddenTasks[task.task_type] = nil
                TaskMgr:saveHideTask()
            end
        else
            TaskMgr.hiddenTasks[task.task_type] = nil
            TaskMgr:saveHideTask()
        end
    end
end

function TaskMgr:add(v, isRefresh)
    local task_type = v.task_type
    displayFirstTask = ""
    self.refreshCmds[task_type] = nil

    if GameMgr:IsCrossDist() then
    if DistMgr:isInQMPKServer() then
        -- 全民PK区组内仅显示部分任务
            if not TASK_IN_QMPK_SERVER[task_type] then
            return
        end
    end

        if DistMgr:isInZBYLServer() then
            -- 争霸娱乐区组，只显示部分任务
            if not TASK_IN_ZBYL_SERVER[task_type] then
                return
            end
        end
    end

    self:addReal(v, isRefresh)
end

function TaskMgr:addReal(v, isRefresh)
    local type = v.task_type
    local desc = v.task_desc
    local prompt = v.task_prompt
    local attrib = Bitset.new(v.attrib)

    if not TaskMgr.hiddenTasks or not next(TaskMgr.hiddenTasks) then
        TaskMgr:loadHideTask()
    end

    if string.len(prompt) == 0 then
        if self.tasks[type] ~= nil then
            DlgMgr:sendMsg("MissionDlg", "removeTask", v)
        end

        TaskMgr:setTaskVisible(v)
        self.tasks[type] = nil

        -- 分发任务移除的事件
        local info = {}
        info.type = type
        EventDispatcher:dispatchEvent("EVENT_TASK_DROP", info)

        -- 删除自动处理任务
        if self.autoWalkTask and type == self.autoWalkTask.task_type then
            self.autoWalkTask = nil
        end
    else
        v.task_desc = string.gsub(desc, CHS[2000013], "")
        v.task_prompt = string.gsub(prompt, CHS[2000014], "")

        -- 全角替换为半角
        for str in string.gmatch(v.task_prompt, CHS[5430006]) do
            str = string.gsub(str, CHS[5430007], "(")
            str = string.gsub(str, CHS[5430008], ")")
            v.task_prompt = string.gsub(v.task_prompt, CHS[5430006], str, 1)
        end

        v.attrib = attrib
        v.timeTemp = gfGetTickCount()
        v.taskType = self:getTaskType(v.show_name)

        -- 更新任务是否增加光效
        if Me:queryBasicInt("level") < 10 then
            v.isMagic = true
        end

        if GameMgr.initDataDone and not self.tasks[type] then
            displayFirstTask = type
        end

        TaskMgr:setTaskVisible(v)
        if not self.tasks[type] then
            self.tasks[type] = v  -- 新任务必须加进去，MissionDlg需要排序
            if not GameMgr.initDataDone and TaskMgr.hiddenTasks[v.task_type] then
                -- 登入过程中，如果有隐藏的，不加入MissionDlg界面中
            else
                if isRefresh then
            DlgMgr:sendMsg("MissionDlg", "MSG_TASK_PROMPT")
            end
            end

            if v.task_type ~= CHS[3004375] then -- 通天不需要一接到就自动
                self:doAutoWalkByTask(v)
            end
        else
            -- 同样的任务不执行自动处理逻辑，防止服务器更新一样的任务
            if v.toBeAutoWalk and (v.task_type ~= self.tasks[type].task_type or v.task_prompt ~= self.tasks[type].task_prompt) then
                self:doAutoWalkByTask(v, self.tasks[type])
            end

            self.tasks[type] = v
            if not TaskMgr.hiddenTasks[v.task_type] then
            DlgMgr:sendMsg("MissionDlg", "resetTask", v)
        end
        end

        if v.task_type == CHS[3004381] and not TaskMgr:checkIsCloseDoubleTip(CHS[3004272]) and SystemSettingMgr:getSettingStatus("sight_scope", 0) == 0 then -- 镖行万里 （弹出游戏效果设置）
            gf:ShowSmallTips(CHS[6600011])
            ChatMgr:sendMiscMsg(CHS[6600011])
            TaskMgr:markCloseDoubleTipTime(CHS[3004272])
        end
        end

    if Me.selectTarget and TaskMgr.curTaskWalkPath.task_type == v.task_type then
        Me.selectTarget:removeFocusMagic()
    end

    --AutoWalkMgr:updateUnFlyAutoWalk()

    -- 处理，接收到任务的回调
    self:dealGetTask(v)

    -- 分发任务刷新事件
    EventDispatcher:dispatchEvent(EVENT.TASK_REFRESH, { taskData = v })
end

-- 进行点击任务面板之前的判断条件
function TaskMgr:checkCanGotoTask(tip, task)
    local ret = { result = false}

    repeat
        -- GM处于监听状态下
        if GMMgr:isStaticMode() then
            gf:ShowSmallTips(CHS[3003130])
            break
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003724])
            break
        elseif Me:isLookOn() then
            gf:ShowSmallTips(CHS[3003725])
            break
        end

        if task.task_type == CHS[3000734] then
            gf:CmdToServer("CMD_START_XS_AUTO_WALK", {})
            break
        end

        if tip:getCsType() ~= CONST_DATA.CS_TYPE_NPC and tip:getCsType() ~= CONST_DATA.CS_TYPE_ZOOM then

            -- 愚人节提示
            if task.task_type == CHS[7002044] and task.task_prompt == CHS[7002058] then
                gf:ShowSmallTips(CHS[7002059])
                break
            end

            -- 【劳动节】能者多劳提示
            if task.show_name == CHS[5400050] then
                gf:ShowSmallTips(CHS[5400053])
                break
            end

            if task.show_name == CHS[5450080] and string.match(task.task_prompt, CHS[5450085]) then
                CharMgr:talkToMyTMNpc()
                break
            end

            if string.match(task.show_name, CHS[4101494]) then
                AutoWalkMgr:stopAutoWalk()
                gf:CmdToServer('CMD_CHILD_CLICK_TASK_LOG', { task_name = task.show_name })
                break
            end

            if task.task_type == CHS[4010230] and tonumber(task.task_extra_para) == 1 then
                gf:ShowSmallTips(CHS[4010231])
                break
            end

            if task.task_type == CHS[4010227] and tonumber(task.task_extra_para) == 6 then

                if TeamMgr:getLeaderId() == Me:getId() then
                    -- 【愚人节】收集材料特殊处理：当到达委托任务的步骤时，点击【愚人节】相当于点击【委托】
                    local autoWalkInfo = gf:findDest(task.task_prompt)
                    autoWalkInfo.curTaskWalkPath = {}
                    autoWalkInfo.curTaskWalkPath.task_type = task.task_type
                    autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

                    ret["result"] = true
                    ret["succ_type"] = TaskMgr.CHEKC_TASK.SHOW_SMALL_TIPS
                    ret["autoWalkInfo"] = autoWalkInfo
                else

                    local item = InventoryMgr:getItemByName(CHS[4010232])
                    if item and item[1] then
                        --gf:PrintMap(item)
                        InventoryMgr:applyItem(item[1].pos)
                    end
                end
                break
            end

            -- 第一种类型
            ret["result"] = true
            ret["succ_type"] = TaskMgr.CHEKC_TASK.NOT_TYPE_NPC_ZONE
            break
        else
            if task.task_type == CHS[7002041] and task.task_prompt == CHS[7003024] then
                -- 【愚人节】收集材料特殊处理：当到达委托任务的步骤时，点击【愚人节】相当于点击【委托】
                local relationTask =  TaskMgr:getTaskByParam(CHS[7002042])
                if relationTask then
                    Log:D("the task_prompt:" .. relationTask.task_prompt)
                    local autoWalkInfo = gf:findDest(relationTask.task_prompt)
                    autoWalkInfo.curTaskWalkPath = {}
                    autoWalkInfo.curTaskWalkPath.task_type = relationTask.task_type
                    autoWalkInfo.curTaskWalkPath.task_prompt = relationTask.task_prompt

                    ret["result"] = true
                    ret["succ_type"] = TaskMgr.CHEKC_TASK.DO_TYPE_NORMAL
                    ret["autoWalkInfo"] = autoWalkInfo
                    break
                end
            end


            if task.task_type == CHS[4010227] and tonumber(task.task_extra_para) == 6 then

                if TeamMgr:getLeaderId() == Me:getId() then
                    -- 【愚人节】收集材料特殊处理：当到达委托任务的步骤时，点击【愚人节】相当于点击【委托】
                    local autoWalkInfo = gf:findDest(task.task_prompt)
                    autoWalkInfo.curTaskWalkPath = {}
                    autoWalkInfo.curTaskWalkPath.task_type = task.task_type
                    autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

                    ret["result"] = true
                    ret["succ_type"] = TaskMgr.CHEKC_TASK.SHOW_SMALL_TIPS
                    ret["autoWalkInfo"] = autoWalkInfo
                else
                    local item = InventoryMgr:getItemByName(CHS[4010232])
                    if item then
                        InventoryMgr:applyItem(item.pos)
                    end
                end
                break
            end

            Log:D("the task_prompt:%s", task.task_prompt)
            local autoWalkInfo = gf:findDest(task.task_prompt)
            autoWalkInfo.curTaskWalkPath = {}
            autoWalkInfo.curTaskWalkPath.task_type = task.task_type
            autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

            local function tipCloseQMX()
                gf:confirm(CHS[3003133], function()
                    -- 关闭驱魔香
                    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end, function()
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end)
            end

            if task.attrib:isSet(TASK.TASK_ATTRIB_CLOSE_EXORCISM)
                and PracticeMgr:getIsUseExorcism() then
                tipCloseQMX()
                break
            end

            if (CHS[3003132] == task.task_type
                    or CHS[7002289] == task.task_type
                    or CHS[7002290] == task.task_type)  -- 同甘共苦/地劫第九劫/地劫第十劫
                and "$1" == autoWalkInfo.action
                and PracticeMgr:getIsUseExorcism() then
                tipCloseQMX()
                break
            end

            if CHS[3004452] == task.task_type
               and "$1" == autoWalkInfo.action
               and PracticeMgr:getIsUseExorcism() then
                -- 仙魔录—初现疑云
                gf:confirm(CHS[3004453], function()
                    -- 关闭驱魔香，并触发自动行路
                    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                    DlgMgr:closeDlg("TaskDlg")
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end)

                -- 不需要关闭任务界面
                ret.notCloseTaskDlg = true
                break
            end

            if (CHS[5000264] == task.show_name)
                and "$1" == autoWalkInfo.action
                and PracticeMgr:getIsUseExorcism() then
                -- 历练—云霄长老
                gf:confirm(CHS[5000265], function()
                    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end, function()
                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end)

                break
            end

            if CHS[4100651] == task.task_type or CHS[4100652] == task.task_type then
                if not PracticeMgr:getIsUseExorcism() then
                    gf:confirm(CHS[4100653], function()
                        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_EXORCISM)
                        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                    end, function ()
                    	AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                    end)

                    break
                end
            end

            -- 神木鼎确认框判断后的后续操作
            local function gotoNextForShenMuDing()
                -- body

                if PracticeMgr:getIsUseExorcism() then
                    gf:confirm(CHS[4300011], function()     -- 当前驱魔香处于开启状态，在练功区走动时无法遇怪，是否关闭？
                        if Me:queryBasicInt("shenmu_points") < 200 and Me:queryBasicInt("enable_shenmu_points") ~= 0 then
                            gf:ShowSmallTips(CHS[5420216])
                            ChatMgr:sendMiscMsg(CHS[5420216])
                        end

                        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                    end)

                    return false
                else
                    if Me:queryBasicInt("shenmu_points") < 200 and Me:queryBasicInt("enable_shenmu_points") ~= 0 then
                        gf:ShowSmallTips(CHS[5420216])
                        ChatMgr:sendMiscMsg(CHS[5420216])
                    end

                    AutoWalkMgr:beginAutoWalk(autoWalkInfo)
                end

                return true
            end

            if CHS[4300010] == task.task_type then
                -- 南方巫术
                if Me:queryBasicInt("enable_shenmu_points") == 0 then
                    gf:confirm(CHS[4300016], function() -- "当前神木鼎处于关闭状态，无法获得变身卡，是否前往开启？",
                        TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "ShenMuOpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
                        if PracticeMgr:getIsUseExorcism()  then
                            TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "OpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
                        end
                    end, function ()
                        gotoNextForShenMuDing()
                    end)

                    break
                end

                if not gotoNextForShenMuDing() then
                    break
                end
            end

            -- 正常，返回结果
            ret["result"] = true
            ret["succ_type"] = TaskMgr.CHEKC_TASK.DO_TYPE_NORMAL
            ret["autoWalkInfo"] = autoWalkInfo
        end

    until true

    return ret
end

-- 该任务是否需要自动寻路
function TaskMgr:isNeedAutoWalk(task, taskBefore)
    if task.attrib and task.attrib:isSet(TASK.ATTRIB_NOT_AUTO_WALK) then
        return false
    end

    local isNeed = false
    if string.match(task.task_type, "sm-(.+)") and Me:queryBasicInt("level") >= 30 then  -- 师门任务
        isNeed = true
        if DlgMgr:isDlgOpened("PetShopDlg") then
            DlgMgr:closeDlg("PetShopDlg")
        end

        if DlgMgr:isDlgOpened("PharmacyDlg") then
            DlgMgr:closeDlg("PharmacyDlg")
        end
    elseif string.match(task.task_type, CHS[3004380]) then -- 帮派任务
        isNeed = true
        if DlgMgr:isDlgOpened("PetShopDlg") then
            DlgMgr:closeDlg("PetShopDlg")
        end

        if DlgMgr:isDlgOpened("PharmacyDlg") then
            DlgMgr:closeDlg("PharmacyDlg")
        end

        if self.autoWalkTask and string.match(self.autoWalkTask.task_type, "sm-(.+)") then
            -- 特殊处理：当师门任务和帮派任务同时触发自动任务流程，则只处理师门任务的自动任务流程
            -- 任务 WDSY-21708 增加
            isNeed = false
        end
    elseif task.task_type == CHS[3004375]  then -- 通天塔
        if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
            -- 不是队长
            isNeed = false
        end

        if (self.tongtianInfo and self.tongtianInfo.curLayer >= self.tongtianInfo.breakLayer) or not TaskMgr:getIsAutoChallengeTongtian() then
            isNeed = false
        else
            isNeed = true
        end
    elseif task.task_type == CHS[7002083] then  -- 武学历练
        -- 特殊处理：武学历练的提交变身卡/装备阶段不需要自动寻路
        local taskPrompt = task.task_prompt
        if string.match(taskPrompt, CHS[7003026]) or string.match(taskPrompt, CHS[7003027]) then
            -- 目前用“蓝色、粉色或金色”、“变身卡”字符串来匹配提交装备/变身卡任务
            -- 暂且认为只有对应任务才会出现对应字符串
            isNeed = false
        else
            isNeed = true
        end

        -- 另外，如果提交变身卡/装备的任务完成时改变了任务状态（回复灵兽异人），此时也不执行自动寻路
        -- 通过固定字符串判断当前任务是否处于“回复灵兽异人”的状态，暂且认为此匹配字符串不会改变
        if taskBefore and taskBefore.task_prompt then
            local taskPromptBefore = taskBefore.task_prompt
            if string.match(taskPrompt, CHS[7001020]) and
                  (string.match(taskPromptBefore, CHS[7003026]) or string.match(taskPromptBefore, CHS[7003027])) then
                isNeed = false
            end
        end

        if self.autoWalkTask
            and (string.match(self.autoWalkTask.task_type, CHS[3004380]) or string.match(self.autoWalkTask.task_type, "sm-(.+)")) then
            -- 特殊处理：当武学历练与帮派任务或师门任务同时触发自动任务流程，则只处理师门任务或帮派任务的自动任务流程
            -- 任务 WDSY-21708 增加
            isNeed = false
        end

        if DlgMgr:isDlgOpened("PetShopDlg") then
            DlgMgr:closeDlg("PetShopDlg")
        end

        if DlgMgr:isDlgOpened("PharmacyDlg") then
            DlgMgr:closeDlg("PharmacyDlg")
        end
        if DlgMgr:isDlgOpened("MarketBuyDlg") then
            DlgMgr:closeDlg("MarketBuyDlg")
        end
    end

    return isNeed
end

-- 需要自动寻路的任务
function TaskMgr:doAutoWalkByTask(task, taskBefore)
    if not task or not GameMgr.initDataDone or not self:isNeedAutoWalk(task, taskBefore) then return end

    -- 战斗中不自动寻路
    if Me:isInCombat() then
        self.autoWalkTask = task
        return
    -- 作为队员不自动寻路了
    elseif Me:isTeamMember() then
        self.autoWalkTask = task
        return
    elseif DlgMgr.dlgs["DramaDlg"] and DlgMgr:sendMsg("DramaDlg", "getDramaState") == false then -- 播放剧本
        self.autoWalkTask = task
        return
    elseif task.task_type == CHS[4010103] and DlgMgr:getDlgByName("TongTianDlg") then -- 播放剧本
        self.autoWalkTask = task
        return
    end

    if MapMgr:isInMapByName(CHS[4010293]) then return end

    local decStr = task.task_prompt
    local dest = gf:findDest(decStr)

    -- npc 对话框打开，并且寻路内容含没有选中菜单（M=）需要保存，等npc对话关闭在寻路
    if DlgMgr:isDlgOpened("NpcDlg") and dest and not dest["msgIndex"] then
        self.autoWalkTask = task
        return
    end

    if dest then
        AutoWalkMgr:beginAutoWalk(dest)
    else
        -- 解析打开对话框
        local tempStr = string.match(decStr, "#@.+#@")
        if tempStr then
            -- 解析#@道具名|FastUseItemDlg=道具名
            tempStr = string.match(decStr, "|.+=.+")
        end

        if tempStr then
            tempStr = string.sub(tempStr, 2)
            tempStr = string.sub(tempStr, 1, -3)
            DlgMgr:openDlgWithParam(tempStr)
        end
    end

    self.autoWalkTask  = nil
end

function TaskMgr:continueTaskAutoWalk()
    self:doAutoWalkByTask(self.autoWalkTask)
end

function TaskMgr:getIsAutoChallengeTongtian()
    return self.isAutoChallenge
end

function TaskMgr:setIsAutoChallengeTongtian(bool)
    self.isAutoChallenge = bool
end

-- 获取任务类型  1主线，5指引，4剧情，3活动 ，6功能任务， 2节日
function TaskMgr:getTaskType(taskInfoStr)
    -- 3004365 主线
    if gf:findStrByByte(taskInfoStr, CHS[3004365]) then
        return TASK_TYPE.STORY_LINE
    end

    -- 节日活动
    for _,taskName in pairs(festivalTask) do
        if string.match(taskInfoStr, taskName) then
            return TASK_TYPE.FESTIVAL
        end
    end

    -- 指引任务
    if string.match(taskInfoStr, CHS[3004367]) then
        return TASK_TYPE.GUIDE
    end

    -- 剧情任务
    for _,taskName in pairs(storyTask) do
        if string.match(taskInfoStr, taskName) then
            return TASK_TYPE.PLOT
        end
    end

    -- 功能性任务
    for _,taskName in pairs(funTask) do
        if string.match(taskInfoStr, taskName) then
            return TASK_TYPE.FUNCION
        end
    end

    return TASK_TYPE.ACTIVITY

end

-- 收到任务之后的处理
function TaskMgr:dealGetTask(taskInfo)
    if nil == taskInfo then
        return
    end

    if TaskMgr:isShuaDaoTask(taskInfo.task_type) and Me.isAutoShuaDao then
        -- 进行自动寻路
        -- AutoWalkMgr:beginAutoWalk(gf:findDest(taskInfo.task_prompt))
        taskInfo.autoClick = true
    end
end

function TaskMgr:cleanup(isMsgLoginDone)
    self.tasks = {}
    TaskMgr.hiddenTasks = {}

    -- 换线不删除百级拜师状态
    if not isMsgLoginDone then
        self.baijiTaskStatus = nil
        self.zy_jsscTaskStatus = nil
    end
end

-- 标记一个自动寻路
function TaskMgr:markATWTask(data)
    if data.count == 1 then
        data[1].toBeAutoWalk = true
    else
        local isMarked = false
        for k, v in ipairs(data) do
            if string.match(v.task_type, "sm") then
                v.toBeAutoWalk = true
                isMarked = true
            end
        end

        if not isMarked then
            for k, v in ipairs(data) do
                if string.match(v.task_type, CHS[6000149]) then -- 帮派
                    v.toBeAutoWalk = true
                    isMarked = true
                end
            end
        end

        if not isMarked then
            for k, v in ipairs(data) do
                if string.match(v.task_type, CHS[7002083]) then -- 武学历练
                    v.toBeAutoWalk = true
                    isMarked = true
                end
            end
        end

        if not isMarked then
            data[data.count].toBeAutoWalk = true
        end
    end
end

-- WDSY-33840 服务器部分情况会通知移除客户端不存在的任务，如：帮派任务(囤积物资和收集药品)，购买完材料后请求移除"帮派任务"
-- 但客户端此时该任务不存在，为了保证数据准确，在此先过滤一遍移除不存在任务的情况
function TaskMgr:filtNotExistTaskForRemove(data)
    local ret = {}
    for _, v in ipairs(data) do
        if v.task_prompt ~= "" or (self.tasks and self.tasks[v.task_type]) then
            -- 非移除任务，或者需要被移除的任务存在
            table.insert(ret, v)
        end
    end

    ret.count = #ret
    return ret
end

function TaskMgr:MSG_TASK_PROMPT(data)
    data = self:filtNotExistTaskForRemove(data)

    -- 过滤完不存在的任务后，任务数量可能为0
    if data.count < 1 then return end

    -- 标记一下自动寻路的任务
    TaskMgr:markATWTask(data)

    for k, v in ipairs(data) do
        self:add(v, data.count == 1)

        -- 元旦节罗盘寻踪  在MSG_TASK_PROMPT刷新任务后需要判断是否需要打开小罗盘
        if v.task_type == CHS[7100051] then -- 【元旦节】罗盘寻踪
            self.souxlpData = nil
            DlgMgr:closeDlg("SouxlpSmallDlg")

            if v.task_extra_para then
                local extraData = gf:split(v.task_extra_para, ",")
                if #extraData == 5 then
                    self.souxlpData = extraData
                    if MapMgr:getCurrentMapName() == extraData[1] then
                        DlgMgr:openDlgEx("SouxlpSmallDlg", {
                            mapId = extraData[2],
                            x = extraData[3],
                            y = extraData[4],
                            needAction = extraData[5],
                        })
                    end
                end
            end
        end



        -- 2019情人节任务，如果玩家在S2状态不关闭界面，杀进程，再次登入，应服务器要求，客户端自己弹界面
        -- 处理顶号
        if v.task_type == CHS[4101237] and v.task_extra_para == "2" and MapMgr:isInMapByName(CHS[4101241]) then
            local dlg = DlgMgr:openDlg("DugeonRuleDlg")
            dlg:setType("valentine_2019_cjmg")
        end
    end

    if data.count > 1 then
        DlgMgr:sendMsg("MissionDlg", "MSG_TASK_PROMPT")
    end

end

function TaskMgr:MSG_SERVICE_LOG(data)
    data["service_log"] = true
    self:add(data, true)
end

function TaskMgr:getRewardList(str)
    if str == "" and  str == nil then return end
    -- 过滤掉服务端的$Source=%d+,客户端无需要这个字段,兼容以前的格式
    str = string.gsub(str, "$Source=%d+", "")

    -- 过滤掉服务端的$Value=%d+[.]%d+,客户端无需要这个字段,兼容以前的格式
    str = string.gsub(str, "$Value=%d+[.]*%d*", "")

    -- 过滤掉服务端的$Value=%d+[.]%d+,客户端无需要这个字段,兼容以前的格式
    str = string.gsub(str, "$GiftValue=%d+[.]*%d*", "")

    -- 过滤掉娃娃亲密度娃娃id
    if string.match(str, CHS[4200799]) then
        str = string.gsub(str, "$KID(.+)$+", "")
    end

    local classList = {}

    local list = gf:split(str, "#C")

    local index = 1
    for i = 1, #list do
        if list[i] ~= "" then
            if string.match(list[i], "(#I.+#I)") then
                classList[index] = string.match(list[i], "(#I.+#I)")
                index = index + 1
            else
                classList[index] = {}
                classList[index]["class"] = list[i]
                classList[index]["isClass"] = true
                index = index + 1
            end
        end
    end


    for i = 1, #classList do
        local rewardList = {}
        if not classList[i]["isClass"] then

            local splitString = string.sub (classList[i] , 3, string.len(classList[i] ) - 2) -- 跳过头尾#I
            local rewardListTable = gf:split(splitString, "#I#I")

            for i = 1, #rewardListTable do
                local reward = gf:split(rewardListTable[i], "|")
                table.insert(rewardList, reward)
            end
            classList[i] = rewardList
        end

    end
    return classList
end

function TaskMgr:bindCurTaskWalkPath(type, prompt)
    self.curTaskWalkPath.task_type = type or ""
    self.curTaskWalkPath.task_prompt = prompt or ""
end

function TaskMgr:clearCurTaskWalkPath()
    self.curTaskWalkPath.task_type = ""
    self.curTaskWalkPath.task_prompt = ""
end

-- 检测当前寻路中的任务，是否可以完成
function TaskMgr:checkCurTaskCanComplete()
    local bRetValue = true

    if self.curTaskWalkPath.task_type == "" then
        -- 当前没有任务的自动寻路
        return false
    end

    for name, task in pairs(TaskMgr.tasks) do
        if task.task_type == self.curTaskWalkPath.task_type then
            -- 寻路中的任务为当前完成的任务
            if gf:findStrByByte(task.task_prompt, "#P") then
                if gf:getStringMid(self.curTaskWalkPath.task_prompt, "#P", "#P") == gf:getStringMid(task.task_prompt, "#P", "#P") then
                    -- 找到一个相同的任务
                    bRetValue = false
                    break
                end
            elseif gf:findStrByByte(task.task_prompt, "#Z") then
                if gf:getStringMid(self.curTaskWalkPath.task_prompt, "#Z", "#Z") == gf:getStringMid(task.task_prompt, "#Z", "#Z") then
                    -- 找到一个相同的任务
                    bRetValue = false
                    break
                end
            end
        end
    end

    if bRetValue then
        -- 清除对应的任务信息
       self:clearCurTaskWalkPath()
    end

    return bRetValue
end

-- 获取任务内容
function TaskMgr:getTaskInfo(taskTitle)
    if TaskInfo[taskTitle] then
        return TaskInfo[taskTitle]
    end
end

-- 查询是否有name任务
function TaskMgr:isExistTaskByName(taskName)
    if self.tasks[taskName] == nil then
        return false
    end

    return true
end

-- 根据显示的任务名查询是否有name 任务
function TaskMgr:isExistTaskByShowName(showName)
    for v, k in pairs(self.tasks) do
        if k.show_name == showName then
            return true
        end
    end

    return false
end

-- 获取夫妻惹怒
function TaskMgr:getMarryTask()
    for v, k in pairs(self.tasks) do
        if string.match(v, CHS[4010010]) then
            return k
        end
    end
end

-- 根据显示的任务名查询任务
function TaskMgr:getTaskByShowName(showName)
    for v, k in pairs(self.tasks) do
        if k.show_name == showName then
            return k
        elseif showName == CHS[7190224] and string.match(k.show_name, CHS[7190254]) then
            -- 【周】探案任务 需要获取 探案任务(多个)
            return k
        end
    end
end

-- 尝试刷新任务，只有设置了 refresh ，才会进行刷新
function TaskMgr:tryToRefreshTask(taskName)
    local task = self.tasks[taskName]
    if not task then
        return
    end

    if task.refresh == 0 then
        -- 不需要刷新
        return
    end

    if self.refreshCmds[taskName] then
        -- 正在刷新中
        return
    end

    if task["service_log"] then
        gf:CmdToServer('CMD_REFRESH_SERVICE_LOG', { name = taskName })
    else
        gf:CmdToServer('CMD_REFRESH_TASK_LOG', { name = taskName })
    end

    self.refreshCmds[taskName] = true
end

-- 尝试刷新所有任务，只有设置了 refresh ，才会进行刷新
function TaskMgr:tryToRefreshAllTask()
    for k, v in pairs(self.tasks) do
        self:tryToRefreshTask(k)
    end
end

function TaskMgr:parsingForItem(list)
    local itemInfo = {}

    for i = 1, #list do
        if string.match(list[i], "$(%d+)") and not itemInfo["level"] then
            itemInfo["level"] =  tonumber(string.match(list[i], "$(%d*)"))
        elseif string.match(list[i], "%%bind") then  -- 为限制交易物品，并为道具补充“限制交易时间”属性
            itemInfo["limted"] = true
            if string.match(list[i], "%%bind=(.*)") then
                itemInfo["gift"] = - tonumber(string.match(list[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                itemInfo["gift"] = 2
            end
        elseif string.match(list[i], "%%deadline") then --为限时物品，并为道具补充“限时时间”属性
            itemInfo["time_limited"] = true
            local deadlineStr = string.match(list[i], "%%deadline=(.*)")
            itemInfo["deadline"] = gf:convertStrToTime(deadlineStr)
            itemInfo["isTimeLimitedReward"] = true

            -- 限时必为永久限制交易
            itemInfo["gift"] = 2
            itemInfo["limted"] = true
        elseif string.match(list[i], "$Valid") then  -- 有Valid字段，代表其限时
            itemInfo["time_limited"] = true

            -- 限时必为永久限制交易
            itemInfo["gift"] = 2
            itemInfo["limted"] = true
        elseif string.match(list[i], "#r(%d*)") then
            itemInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "$id(.*)") then -- 补偿格式id
            itemInfo["id"] = string.match(list[i], "$id(.*)")
        elseif string.match(list[i], "$Nimbus") then
            itemInfo["nimbus"] = tonumber(string.match(list[i], "$Nimbus=(.*)"))
        elseif string.match(list[i], "$Alias") then
            itemInfo["alias"] = string.match(list[i], "$Alias=(.*)")
        elseif string.match(list[i], "$RealDesc") then
            itemInfo["real_desc"] = string.match(list[i], "$RealDesc=(.*)")
        elseif string.match(list[i], "$color") then
            local color = string.match(list[i], "$color=%((.*)%)")
            local colorList = gf:split(color, "&")
            if #colorList == 1 then
                itemInfo["color"] = self:getEquipColor(colorList[1])
        else
                itemInfo["color"] = COLOR3.TEXT_DEFAULT
            end
        else
            if string.match(list[i], "(.+)=T") then
                itemInfo["name"] = string.match(list[i], "(.+)=T")
            elseif not string.match(list[i], ".*$.*") then
                itemInfo["name"] = list[i]
            end
        end
    end

    return itemInfo
end

-- 获取装备颜色
function TaskMgr:getEquipColor(key)
    local color
    if key == "white" then
        color = COLOR3.BROWN
    elseif key == "green" then
        color = COLOR3.GREEN
    elseif key == "blue" then
        color = COLOR3.BLUE
    elseif key == "pink" then
        color = COLOR3.MAGENTA
    elseif key == "gold" then
        color = COLOR3.YELLOW
    end

    return color
end

function TaskMgr:parsingForArtifact(list)
    local itemInfo = {}
    itemInfo.name = list[1]
    if string.match(itemInfo.name, ".+=(F)") then
        itemInfo.name = string.match(itemInfo.name, "(.+)=F")
    end

    if list[2] then
        itemInfo.level = tonumber(string.match(list[2], "$(.+)"))
    end

    if list[3] then
        itemInfo.item_polar = tonumber(string.match(list[3], "$(.+)"))
    end

    return itemInfo
end

function TaskMgr:parsingForPet(list)
    local itemInfo = {}
    itemInfo.name = list[1]
    if string.match(itemInfo.name, ".+=(F)") then
        itemInfo.name = string.match(itemInfo.name, "(.+)=F")
    end

    for i = 2, #list do
        if string.find(list[i], "$PlayerLv") then
            -- $PlayerLv 表示宠物显示等级为玩家当前等级
            itemInfo["level"] = Me:queryInt("level")
        elseif string.match(list[i], "$(%d+)") and not itemInfo["level"] then
            itemInfo["level"] =  tonumber(string.match(list[i], "$(%d*)"))
        elseif string.match(list[i], "%%bind") then  -- 为限制交易物品，并为道具补充“限制交易时间”属性
            itemInfo["limted"] = true
            if string.match(list[i], "%%bind=(.*)") then
                itemInfo["gift"] = - tonumber(string.match(list[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                itemInfo["gift"] = 2
    end
        elseif string.match(list[i], "$Valid") then  -- 有Valid字段，代表其限时
            itemInfo["time_limited"] = true

            -- 限时必为永久限制交易
            itemInfo["gift"] = 2
            itemInfo["limted"] = true
        elseif string.match(list[i], "$IsFly") then  -- $IsFly = 1 表示已飞升宠物，0 表示未飞升宠物（未配置默认未飞升）
            itemInfo["isFly"] = tonumber(string.match(list[i], "$IsFly=(.*)"))
        end
    end

    local type = string.match(itemInfo["name"], ".+%((.+)%)")
    if itemInfo["level"]
        and itemInfo["level"] >= Const.PET_MAX_LEVEL_NOT_FLY
        and type ~= CHS[3003810]
        and itemInfo["isFly"] ~= 1 then
        -- 配置的奖励中，非野生宠物且为飞升，最高只能显示 115 级
        itemInfo["level"] = Const.PET_MAX_LEVEL_NOT_FLY
    end

    return itemInfo
end

-- 解析道具的信息
function TaskMgr:spliteItemInfo(list, reward)
    local itemInfo = {}
    if not reward then
        itemInfo = TaskMgr:parsingForItem(list)
    elseif reward[1] == CHS[3002171] then
        itemInfo.name = list[1]
        if list[2] and string.match(list[2], "$Valid") then
            itemInfo["time_limited"] = true
        end
    elseif reward[1] == CHS[7000144] then
        itemInfo = TaskMgr:parsingForArtifact(list)
    elseif reward[1] == CHS[3001218] then
        itemInfo = TaskMgr:parsingForPet(list)
    elseif reward[1] == CHS[3002174] then
        itemInfo.name = reward[1]
        if list[2] then
            local tempItem = TaskMgr:parsingForItem(list)
            itemInfo.level = tempItem.level
            itemInfo.number = tempItem.number
        end
    elseif reward[1] == CHS[5420176] then
        itemInfo = TaskMgr:parsingForFurniture(list)
    elseif reward[1] == CHS[4100655] then
        -- 时装
        itemInfo = TaskMgr:parsingForFashion(list)
    elseif TaskMgr:isAboutMajorR(reward[1]) then
        itemInfo = TaskMgr:parsingForMajorR(list)
    else
        itemInfo = TaskMgr:parsingForItem(list)
    end

    return itemInfo
end

function TaskMgr:isAboutMajorR(name)
    if name == CHS[5420251]
          or name == CHS[5420252]
          or name == CHS[2200073]
          or name == CHS[5400438]
          or name == CHS[5400439]
          or name == CHS[4200798]
          or name == CHS[2200077] then
        -- 聊天头像框、聊天底框、特殊角色特效、空间头像、空间装饰、跟随小精灵
        return true
    end
end

function TaskMgr:parsingForMajorR(list)
    local itemInfo = {}

    itemInfo["name"] = list[1]

    for i = 2, #list do
        if string.match(list[i], "#r(%d*)") then
            itemInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "%%bind") then -- 带有绑定属性的变身卡
            itemInfo["limted"] = true
            if string.match(list[i], "%%bind=(.*)") then
                itemInfo["gift"] = - tonumber(string.match(list[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                itemInfo["gift"] = 2
            end
        elseif string.match(list[i], "$Time=(.*)") then -- 类型
            itemInfo["time"] = string.match(list[i], "$Time=(.*)")
        end
    end

    local num = tonumber(itemInfo["time"])
    if num and num > 0 then
        itemInfo.alias = string.format(CHS[4100668], itemInfo["name"], itemInfo["time"])
    end

    return itemInfo

end

-- 解析时装
function TaskMgr:parsingForFashion(list)
    local itemInfo = {}

    itemInfo["name"] = list[1]

    for i = 2, #list do
        if string.match(list[i], "#r(%d*)") then
            itemInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "%%bind") then -- 带有绑定属性的变身卡
            itemInfo["limted"] = true
            if string.match(list[i], "%%bind=(.*)") then
                itemInfo["gift"] = - tonumber(string.match(list[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                itemInfo["gift"] = 2
            end
        elseif string.match(list[i], "$Time=(.*)") then -- 类型
            itemInfo["time"] = string.match(list[i], "$Time=(.*)")
        elseif string.match(list[i], "$gender=(.*)") then -- 类型
            local gender = string.match(list[i], "$gender=(.*)")
            if gender == "auto" then
                gender = Me:queryBasicInt("gender")
            else
                gender = tonumber(gender)
            end

            local info = InventoryMgr:getItemInfoByName(itemInfo["name"])
            if info and info.gender ~= gender then
                -- 根据性别显示时装
                itemInfo["name"] = info.relation_fashion
            end

            itemInfo["gender"] = gender
        end
    end

    itemInfo.color = CHS[3004104]
    itemInfo.fasion_type = FASION_TYPE.FASION

    if not itemInfo["time"] then
        itemInfo.alias = string.format(CHS[7100134], itemInfo["name"], CHS[4300359])
    elseif tonumber(itemInfo["time"]) <= 0 then
        itemInfo.alias = string.format(CHS[7100134], itemInfo["name"], CHS[4300359])
    else
    itemInfo.alias = string.format(CHS[4100668], itemInfo["name"], itemInfo["time"])
    end

    if not itemInfo["gender"] then
        local info = InventoryMgr:getItemInfoByName(itemInfo["name"])
        if info then
            itemInfo["gender"] = info.gender
        end
    end

    return itemInfo
end

-- 解析家具
function TaskMgr:parsingForFurniture(list)
    local itemInfo = {}

    for i = 1, #list do
        if string.match(list[i], "#r(%d*)") then
            itemInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "%%bind") then -- 带有绑定属性的变身卡
            itemInfo["limted"] = true
            if string.match(list[i], "%%bind=(.*)") then
                itemInfo["gift"] = - tonumber(string.match(list[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                itemInfo["gift"] = 2
            end
        elseif string.match(list[i], "$type=(.*)") then -- 类型
            itemInfo["type"] = string.match(list[i], "$type=(.*)")
        elseif string.match(list[i], "$area=(.*)") then -- 类型
            itemInfo["area"] = string.match(list[i], "$area=(.*)")
        else
            itemInfo["name"] =  list[i]
        end
    end

    return itemInfo
end

-- 解析变身卡信息
function TaskMgr:spliteChangeCardInfo(list)
    local itemInfo = {}

    for i = 1, #list do
        if string.match(list[i], "#r(%d*)") then
            itemInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "%%bind") then -- 带有绑定属性的变身卡
            itemInfo["limted"] = true
        elseif string.match(list[i], "$(.*)") then -- 类型
            itemInfo["type"] = string.match(list[i], "$(.*)")
        else
            itemInfo["name"] =  list[i]
        end
    end

    return itemInfo
end

-- 解析友好度的信息
function TaskMgr:spliteFriendlyInfo(list)
    local friendlyInfo = {}

    for i = 1, #list do
        if string.match(list[i], "$T=(.*)") then
            friendlyInfo["gid"] =  string.match(list[i], "$T=(.*)")
        elseif string.match(list[i], "#r(%d*)") then
            friendlyInfo["number"] = string.match(list[i], "#r(%d*)")
        elseif string.match(list[i], "$N=(.*)") then
            friendlyInfo["friendName"] = string.match(list[i], "$N=(.*)")
        else
            friendlyInfo["name"] =  list[i]
        end
    end

    return friendlyInfo
end

-- 奖励是否是限制交易
function TaskMgr:isLimited(rewardStr)
    if  string.match(rewardStr, "%%bind") then
        local item
        local bindTime = string.match(rewardStr, "%%bind=(%d*)")
        if bindTime and bindTime ~= "" then
            item = {gift = -tonumber(bindTime) - gf:getServerTime() - Const.DELAY_TIME_BALANCE}
        else
            item = {gift = 2}
        end

        return true, InventoryMgr:getLimitAtt(item)
    end

    return false
end

-- 奖励是否是限时
function TaskMgr:isTimeLimited(rewardStr)
    local function getLeftTimeStr(timeLeft)
    	if timeLeft >= 86400 then -- 60 * 60 * 24
            return string.format(CHS[34050], math.ceil(timeLeft / 86400))
        elseif timeLeft >= 3600 then
            return string.format(CHS[4100093], math.ceil(timeLeft / 3600))
        else
            return string.format(CHS[4300223], math.ceil(timeLeft / 60))
    	end
    end


    if string.match(rewardStr, "%%deadline") or string.match(rewardStr, "$Valid") then
        if string.match(rewardStr, "%%deadline") then
            -- 具体时间
            if string.match(rewardStr, "%%deadline=") then
                local str = string.match(rewardStr, "deadline=((%d*)-(%d*)-(%d*)-(%d*):(%d*):(%d*))")
                if str and str ~= "" then
                    -- 格式 F$2%deadline=2017-05-24-23:59:59#I"
                    local timeLimitStr = string.format(CHS[7000077], gf:getServerDate(CHS[4200022], gf:convertStrToTime(str)))
                    return true, timeLimitStr
                end

                str = string.match(rewardStr, "%%deadline=(%d*)")
                if str and str ~= "" then
                    -- 格式 F$2%deadline=12345"

                    local leftTicket = tonumber(str)
                    local timeStr = getLeftTimeStr(leftTicket)

                    local timeLimitStr = string.format(CHS[4200449], timeStr)
                    return true, timeLimitStr
                end
            end
        end

        if string.match(rewardStr, "$Valid") then
            -- 具体时间
            if string.match(rewardStr, "$Valid=") then
                local str = string.match(rewardStr, "Valid=((%d*)-(%d*)-(%d*)-(%d*):(%d*):(%d*))")
                if str and str ~= "" then
                    -- 格式 F$2%deadline=2017-05-24-23:59:59#I"
                    local timeLimitStr = string.format(CHS[7000077], gf:getServerDate(CHS[4200022], gf:convertStrToTime(str)))
                    return true, timeLimitStr
                end

                str = string.match(rewardStr, "Valid=(%d*)")
                if str and str ~= "" then
                    -- 格式 F$2%Valid=1234#I"
                    local leftTicket = tonumber(str)
                    local timeStr = getLeftTimeStr(leftTicket)

                    local timeLimitStr = string.format(CHS[4200449], timeStr)
                    return true, timeLimitStr
                end
            end
        end

        return true
    end

    return false
end

-- 获取副本任务信息
function TaskMgr:getDungeonTask(dungeonName)
    return self.tasks[dungeonName]
end

-- 获取八仙任务
function TaskMgr:getBaxianTask()
    for v, k in pairs(self.tasks) do
        if string.match(k.task_type, CHS[3002227]) then
            return k
        end
    end
end

-- 是否是刷道任务
function TaskMgr:isShuaDaoTask(taskName)
    for i = 1, #TASK_SHUADAO do
        if TASK_SHUADAO[i] == taskName then
            return true
        end
    end

    return false
end

-- 获取有师门任务
function TaskMgr:getSMTask()
    for v, k in pairs(self.tasks) do
        if  (string.match(k.task_type, "sm-(.+)") or k.task_type == CHS[3004373]) and not string.match(k.show_name, CHS[4200347]) then
            return k.task_prompt
        end
    end
end

-- 获得除暴任务
function TaskMgr:getCBTask()
    for v, k in pairs(self.tasks) do
        if k.task_type == CHS[3004374] then
            return k.task_prompt
        end
    end
end

-- 获取通天塔任务
function TaskMgr:getTongtianTowerTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004375] then
            return k.task_prompt
        end
    end
end

-- 获取通天塔任务
function TaskMgr:getTongtianTowerTaskInfo()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004375] then
            return k
        end
    end
end

-- 获取通天塔顶任务
function TaskMgr:getTongtianTowerTopTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[4101274] then
            return k.task_prompt
        end
    end
end

-- 获取历练任务
function TaskMgr:getAdvanceTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004376] then
            return k.task_prompt
        end
    end
end

-- 获取修行任务
function TaskMgr:getXXTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004377] then
            return k.task_prompt
        end
    end
end

-- 获取修行任务
function TaskMgr:getSJZTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[4100325] then
            return k.task_prompt
        end
    end
end

-- 获取助人为乐任务
function TaskMgr:getZhuRenWeiLeTask()
    for v, k in pairs(self.tasks) do
        if  string.match(k.task_type, CHS[3004378]) then
            return k.task_prompt
        end
    end
end

function TaskMgr:getFuBenTaskNameInSpecialMap()
    -- 处于特殊地图的副本任务，其在MissionDlg的显示格式与一般副本相同(displayType)
    if MapMgr:isInZhiShuJieDugeon() then
        -- 植树节
        return CHS[7003006]
    elseif MapMgr:isInBeastsKing() then
        -- 百兽之王
        return CHS[2200036]
    elseif MapMgr:isInMasquerade() then
        -- 化妆舞会（化妆舞会活动暂时不绑定任务，设定任务的目的在于使之不会取到错误的任务）
        return CHS[2200037]
    elseif MapMgr:isInYzrq() then
        return CHS[2000237]
    elseif MapMgr:isInWangMuQinGong() then
        -- 【七夕节】千里相会
        return CHS[5400073]
    elseif MapMgr:isInBaiHuaCongzhong() then
        -- 【七夕】漫步花丛
        return CHS[5450187]
    elseif MapMgr:isInXueJingShengdi() then
        -- 【圣诞】巧收雪精
        return CHS[5450059]
    elseif MapMgr:isInShanZei() then
        if TaskMgr:getTaskByName(CHS[7190231]) then
            -- 【探案】人口失踪
            return CHS[7190231]
        else
            --【劳动节】锄强扶弱
            return CHS[7190144]
        end
    elseif MapMgr:isInTanAnJhll() then
        -- 【探案】江湖绿林
        return CHS[7190256]
    elseif MapMgr:isInTanAnMxza() then
        -- 【探案】迷仙镇案
        return CHS[7190287]
    elseif MapMgr:isInMapByName(CHS[4010025]) then
        return CHS[4010021]
    elseif MapMgr:isInMapByName(CHS[4101241]) then
        return CHS[4101237]
    elseif MapMgr:isInQMJH() then
        -- 【愚人节】千面酒会
        return CHS[5450341]
    end
end

-- 获取副本任务
function TaskMgr:getFuBenTask(excludeSpec)
    if not excludeSpec then
    -- 处于特殊地图的副本任务
    local fubenTaskInSpecialMap = TaskMgr:getFuBenTaskNameInSpecialMap()
    if fubenTaskInSpecialMap then
        for v, k in pairs(self.tasks) do
            if k.task_type == fubenTaskInSpecialMap then
                return k.task_prompt
            end
        end

        return
    end
    end

    for v, k in pairs(self.tasks) do
        if  FUBEN_TASK_NAME[k.task_type] then
            return k.task_prompt
        end
    end
end

-- 获取副本任务数据
function TaskMgr:getFuBenTaskData()
    -- 处于特殊地图的副本任务
    local fubenTaskInSpecialMap = TaskMgr:getFuBenTaskNameInSpecialMap()
    if fubenTaskInSpecialMap then
        for v, k in pairs(self.tasks) do
            if k.task_type == fubenTaskInSpecialMap then
                return k
            end
        end

        return
    end

    for v, k in pairs(self.tasks) do
        if  FUBEN_TASK_NAME[k.task_type] then
            return k
        end
    end
end

-- 获取帮派日常挑战任务
function TaskMgr:getPartyChallengeTask()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004379] then
            return k.task_prompt
        end
    end
end

-- 获取帮派任务
function TaskMgr:getPartyTask()
    for v, k in pairs(self.tasks) do
        if  string.match(k.show_name, CHS[3004380]) then
            return k.task_prompt
        end
    end
end

-- 获取镖行万里
function TaskMgr:getBiaoXingWanLiTask()
    if self.tasks[CHS[3004381]] then
        return self.tasks[CHS[3004381]].task_prompt
    end
end

-- 获取法宝任务
function TaskMgr:getFaBaoTask()
    if self.tasks[CHS[5400000]] then
        return self.tasks[CHS[5400000]].task_prompt
    end
end

-- 悬赏任务
function TaskMgr:getXuanShangTask()
    if self.tasks[CHS[3004382]] then
        return self.tasks[CHS[3004382]].task_prompt
    end
end


-- 获取指定任务
function TaskMgr:getTaskByName(taskName)
    if self.tasks[taskName] then
        return self.tasks[taskName]
    end
end

-- 获取taskType包含指定字符串的第一个任务
function TaskMgr:getTaskByParam(param)
    for k, v in pairs(self.tasks) do
        if string.match(v.task_type, param) then
            return v
        end
    end
end

-- 是否有坐牢任务
function TaskMgr:isHaveJailTask()
	if self.tasks[CHS[3004372]] then
	   return true
	end

	return false
end

-- 是否有被关入监狱的任务
function TaskMgr:isHavePrisonTask()
    if self.tasks[CHS[7000069]] then
        return true
    end

    return false
end

local DOUBLE_POINT_TASK = {
    [CHS[3004360]] = "xiangy",
    [CHS[3004361]] = "fum",
    [CHS[3004377]] = "xiul",
    [CHS[3004374]] = "chub",
    [CHS[3004382]] = "xuans",
    [CHS[6400033]] = "shuad",
    [CHS[6200026]] = "chongfengsan",
    [CHS[3004149]] = "shidaodahui",
    [CHS[3003208]] = "bangzhan",
    [CHS[3004272]] = "biaoxwl", -- 镖行万里
    [CHS[4100325]] = "shijz",
    [CHS[5400070]] = "shuadjz", -- 刷道卷轴
	[CHS[5120005]] = "fxdj", -- 飞仙渡邪
}

-- 记录今日已经关闭双倍提示的任务
function TaskMgr:markCloseDoubleTipTime(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "double_" .. markFlag, 0)
    if not gf:isSameDay5(curTi, ti) then
        cc.UserDefault:getInstance():setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "double_" .. markFlag, os.time())
    end
end

-- 记录今日已经关闭宠风散提示的任务
function TaskMgr:markCloseChongfsTipTime(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "chongfs_" .. markFlag, 0)
    if not gf:isSameDay5(curTi, ti) then
        cc.UserDefault:getInstance():setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "chongfs_" .. markFlag, os.time())
    end
end

-- 记录今日已经提示过了
function TaskMgr:markAlreadyTips(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "tips_" .. markFlag, 0)
    if not gf:isSameDay5(curTi, ti) then
        cc.UserDefault:getInstance():setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "tips_" .. markFlag, os.time())
    end
end

-- 记录今日已经操作过了
function TaskMgr:markTodayCannotTip(taskName, key)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    key = key or ""
    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. key .. "_" .. markFlag, 0)
    if not gf:isSameDay5(curTi, ti) then
        cc.UserDefault:getInstance():setIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. key .. "_" .. markFlag, os.time())
    end
end

-- 查看今天是不是已经关闭这个任务提示
function TaskMgr:checkIsCloseDoubleTip(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "double_" .. markFlag, 0)
    if gf:isSameDay5(curTi, ti) then
        return true
    end

    return false
end

-- 检查今天是不是已经关闭了宠风散
function TaskMgr:checkIsCloseChongfsTip(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "chongfs_" .. markFlag, 0)
    if gf:isSameDay5(curTi, ti) then
        return true
    end

    return false
end

-- 检查今天是不是已经提示过了
function TaskMgr:checkIsTips(taskName)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. "tips_" .. markFlag, 0)
    if gf:isSameDay5(curTi, ti) then
        return true
    end

    return false
end

-- 检查今天是不是已经操作过了
function TaskMgr:checkTodayCanTip(taskName, key)
    if nil == taskName then return end

    local markFlag = DOUBLE_POINT_TASK[taskName]
    if nil == markFlag then return end

    key = key or ""
    local curTi = os.time()
    local ti = cc.UserDefault:getInstance():getIntegerForKey(gf:getShowId(Me:queryBasic("gid")) .. key .. "_" .. markFlag, 0)
    if gf:isSameDay5(curTi, ti) then
        return true
    end

    return false
end

function TaskMgr:checkShuaDaoLing(taskName)
    -- 如意刷道令未开启
    if GetTaoMgr:getRuYiZHLState() then return false end

    -- 不是队长
    if not Me:isTeamLeader() then return end

    -- 任务不在了
    if not TaskMgr:getTaskByName(taskName) then return end

    if Me:isInCombat() then return end

    -- 今天是否已取消检测了
    if TaskMgr:checkTodayCanTip(taskName, "shuadl") then return false end

    if TaskMgr:isShuaDaoTask(taskName) then
        -- 刷道
        gf:confirm(CHS[5420355], function()
            TaskMgr:openDlgAndAddArmatureMagic("GetTaoDlg", "ButtonPanel4:OpenPanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
            end,
            function()
                TaskMgr:markTodayCannotTip(taskName, "shuadl")
            end, nil, nil, nil, nil, nil, "checkShuaDaoLingByShuad")
    end
end

function TaskMgr:checkDouble(taskName, doublePoint)
    if TaskMgr:checkIsCloseDoubleTip(taskName) then return false end

    if Me:queryInt("enable_double_points") == 1 then return false end

    -- 双倍点数不足
    if (CHS[3004377] == taskName or CHS[4100325] == taskName) and ActivityMgr:getActivityCurTimes(taskName) < 60 then
        -- 修行任务还需要判断次数
        gf:confirm(CHS[3004383], function()
            TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "UseOpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
            end,
            function()
                TaskMgr:markCloseDoubleTipTime(taskName)
            end)
    end

    if TaskMgr:isShuaDaoTask(taskName) or CHS[3004374] == taskName then
        -- 刷道和除暴
        gf:confirm(CHS[3004383], function()
            TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "UseOpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
                if Me:isTeamLeader() then
                    DlgMgr:sendMsg("PracticeDlg", "setNeedCheckShuaDaoLing", taskName)
                end
            end,
            function()
                TaskMgr:markCloseDoubleTipTime(taskName)

                TaskMgr:checkShuaDaoLing(taskName)
            end, nil, nil, nil, nil, nil, "checkDoubleByShuad")
    end

    if CHS[3004382] == taskName then
        -- 悬赏
        gf:confirm(CHS[3004383], function()
            TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "UseOpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
            end,
            function()
                TaskMgr:markCloseDoubleTipTime(taskName)
            end)
    end

    if CHS[6400033] == taskName then
        -- 刷道触发
        if (Me:queryBasicInt("double_points") >= 4) then
            gf:confirm(CHS[3004383], function()
                TaskMgr:openDlgAndAddArmatureMagic("PracticeDlg", "UseOpenStatePanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
                end,
                function()
                    TaskMgr:markCloseDoubleTipTime(taskName)
                    TaskMgr:checkChongfengsan(taskName, doublePoint)
                end)
        else
            return false
        end

    end

    return true
end

function TaskMgr:checkChongfengsan(taskName, doublePoint)
    if GetTaoMgr:isChongfsEnable() or TaskMgr:checkIsCloseChongfsTip(taskName) then return false end
    if (GetTaoMgr:getPetFengSanPoint() < 4) then return false end

    if CHS[6400033] == taskName then
        gf:confirm(CHS[6200033], function()
            TaskMgr:openDlgAndAddArmatureMagic("GetTaoDlg", "ChongfsOpenPanel", ResMgr.ArmatureMagic.use_double_point, Const.ARMATURE_MAGIC_TAG)
                                 end,
            function()
                TaskMgr:markCloseChongfsTipTime(taskName)
            end)
    end

    return true
end

function TaskMgr:checkDoubleChongfsTips(taskName)
    if TaskMgr:checkIsTips(taskName) then return end
    local need_d_tip = false
    local need_c_tip = false
    if (Me:queryBasicInt("double_points") < 4) then
        need_d_tip = true
    end

    if (GetTaoMgr:getPetFengSanPoint() < 4) then
        need_c_tip = true
    end

    local tip = ""
    if need_d_tip and need_c_tip then
        tip = CHS[5000261]
    elseif need_d_tip then
        tip = CHS[5000262]
    elseif need_c_tip then
        tip = CHS[5000263]
    else
        return
    end

    if ("" == tip) then
        return
    end

    gf:ShowSmallTips(tip)
    TaskMgr:markAlreadyTips(taskName)
end

function TaskMgr:isExistNewPersonTasg()
    for v, k in pairs(self.tasks) do
        if  k.task_type == CHS[3004384] then
            return true
        end
    end

    return false
end

function TaskMgr:MSG_CHECK_DOUBLE_POINT(data)
    if not TaskMgr:checkDouble(data.task_name, data.check_point) then
        TaskMgr:checkShuaDaoLing(data.task_name)

        if CHS[6400033] == data.task_name then
            -- 双倍点数不够，检查宠风散
            TaskMgr:checkChongfengsan(data.task_name, 0)

            -- 检查是否需要提示
            TaskMgr:checkDoubleChongfsTips(data.task_name)
        end
    end
end

function TaskMgr:MSG_REQUEST_CHANGE_LOOK(data)
    local ti = data.keepTime - gf:getServerTime()
    -- ti时间会有误差，直接写死30秒
    gf:confirm(data.tip, function ()
        gf:CmdToServer('CMD_ANSWER_CHANGE_CARD', { answer = 1 })
    end, function ()
        gf:CmdToServer('CMD_ANSWER_CHANGE_CARD', { answer = 0 })
    end,
    nil,
    30)
end

function TaskMgr:MSG_TONGTIANTA_INFO(data)
    self.tongtianInfo = data
end

-- 是否可以显示自动挑战通天塔
function TaskMgr:isCanChallengeTongtian()
    if not self.tongtianInfo then
        return false
    end

    if self.tongtianInfo.curLayer == self.tongtianInfo.breakLayer
        and self.tongtianInfo.curType == 2 then
        -- 突破层，并且，已经挑战成功了，无法自动战斗
        return false
    end

    return self.tongtianInfo.curLayer <= self.tongtianInfo.breakLayer
end

-- 是否完成百级任务
function TaskMgr:requestBaijiTask()
    gf:CmdToServer("CMD_REQUEST_TASK_STATUS", {taskName = CHS[4100312]})
end

-- 是否完成百级任务
function TaskMgr:isCompleteBaijiTask()
	if self.baijiTaskStatus and self.baijiTaskStatus == 1 then
	   return true
	end

	return false
end

function TaskMgr:isCompleteJSSCTask()
    if self.zy_jsscTaskStatus and self.zy_jsscTaskStatus == 1 then
        return true
    end

    return false
end

function TaskMgr:MSG_TASK_STATUS_INFO(data)
    if data.taskName == CHS[4100312] then
    self.baijiTaskStatus = data.status
    elseif data.taskName == CHS[4200442] then
        self.zy_jsscTaskStatus = data.status
    end
end

-- 帮派 求助名片
function TaskMgr:MSG_PH_CARD_INFO(data)
    local dlg = DlgMgr:openDlg("TaskCardDlg")
    dlg:setData(data.cardInfo, data.keyStr)
end

-- 获取小图标
function TaskMgr:getSamllImage(name)
    return SMALL_REWARD_ICON[name] or SMALL_REWARD_ICON[CHS[3002165]]
end

-- 获取占卜任务信息
-- 当前客户端使用到的占卜效果只有减免费用，所以此函数返回值均为effectId对应的费用折扣
-- 1表示不打折，0表示免费
function TaskMgr:getNumerologyEffect(effctId)
    local task = TaskMgr:getTaskByParam(CHS[7100216])
    if task then
        local effctInfo = json.decode(task.task_extra_para)
        if effctId == effctInfo["stick_id"] then
            if effctInfo["rate"] then
                return effctInfo["rate"] / 10000 / 100
            else
                -- 没有rate字段的，都是免手续费的，直接返回0
                return 0
            end
        end
    end

    return 1
end

function TaskMgr:getLeftTime(leftTime)
    local str = ""
    local day = math.floor(leftTime / (60 * 60 * 24))
    local hour = math.floor(leftTime % (60 * 60 * 24) / (60 * 60))
    local minute = math.floor(leftTime % (60 * 60 * 24) % (60 * 60) / 60)
    local second = math.floor(leftTime % (60 * 60 * 24) % (60 * 60) % 60)

    if day > 0 then
        str = str .. day .. CHS[6000229] -- 天
        if minute > 0 then
            str = string.format(CHS[4200194], str, hour + 1)    -- "%s%d小时",
        else
            if hour == 0 then
                -- x 天0小时0分，需要显示   x-1天24小时
                if day > 1 then
                    str = string.format(CHS[4200194], (day - 1) .. CHS[6000229], 24)    -- "%s%d小时",
        else
                    str = string.format(CHS[4200194], "", 24)    -- "%s%d小时",
        end
    else
                str = string.format(CHS[4200194], str, hour)     -- "%s%d小时",
        end
        end
    else
        if hour > 0 then
            str = str .. hour .. CHS[3002942]       -- 小时
            if second > 0 and (minute > 0 or second > 3) then
                -- WDSY-33976，gf:getServerTime()获取的时间与服务器时间可能存在一定误差
                -- 显示"%s%d分钟"的条件增加 minute > 0 or second > 3, 用于避免一些最多显示1小时的任务，显示了1小时1分钟
                str = string.format(CHS[4200195], str, minute + 1)  -- "%s%d分钟",
            else
                if minute == 0 then
                    -- 1小时0分0秒显示为60分
                    if hour > 1 then
                        str = string.format(CHS[4200195], (hour - 1) .. CHS[3002942], 60)  -- "%s%d分钟"
            else
                        str = string.format(CHS[4200195], "", 60)  -- "%s%d分钟"
            end
        else
                    str = string.format(CHS[4200195], str, minute)  -- "%s%d分钟"
            end
            end
        else
            if minute > 0 then
                if second > 0 then
                    str = (minute + 1) .. CHS[3002943]  -- 分钟
                else
                    str = minute .. CHS[3002943]    -- 分钟
                end
            else
                str = CHS[3004168]  -- 1分钟
            end
        end
    end

    return str
end

function TaskMgr:MSG_TASK_REPORT_INFO(data)
    --[[
    if data.cur_task_round == data.max_task_round and TASK_LOG_ID[data.task_name] then
        local taskName = data.task_name
        LeitingSdkMgr:logReport(gf:buildTaskLog(TASK_LOG_ID[taskName], taskName, "1", string.format("%d/%d", data.cur_task_round, data.max_task_round)))
    end
    ]]
end

function TaskMgr:MSG_HZWH_INFO(data)
    self.masqueradeTime = {startTime = data.startTime, endTime = data.endTime, whcd_id = data.whcd_id}

    DlgMgr:sendMsg("SystemFunctionDlg", "updateServerInfo")
end

function TaskMgr:getMasqueradeTimeInfo()
    return self.masqueradeTime
end

function TaskMgr:MSG_ZNQ_2017_XMMJ(data)
    self.mijingInfo = data
end

function TaskMgr:getMiJingInfo()
    return self.mijingInfo
end

function TaskMgr:MSG_BAISZW_INFO(data)
    self.beastsKingTime = {startTime = data.start_time, endTime = data.end_time, dungeonIndex = data.dungeon_index }

    -- 参考化妆舞会实现，刷新房间名称
    DlgMgr:sendMsg("SystemFunctionDlg", "updateServerInfo")
end

function TaskMgr:getBeastsKingTimeInfo()
    return self.beastsKingTime
end

function TaskMgr:MSG_QMPK_INFO(data)
    self.qmpkInfo = data
end

function TaskMgr:getQMPKInfo()
    return self.qmpkInfo
end

function TaskMgr:MSG_YISHI_ACTIVITY_INFO(data)
    self.yqrqTime = {startTime = data.start_time, endTime = data.end_time, born_time = data.born_time}
end

function TaskMgr:getYzrqTimeInfo()
    return self.yqrqTime
end

function TaskMgr:MSG_MY_KSDZ_INFO(data)
    self.oreWarsInfo = data
end

function TaskMgr:getOreWarsInfo()
    return self.oreWarsInfo
end

function TaskMgr:getOreWarsCampColor()
    if not self.oreWarsInfo or not self.oreWarsInfo.camp then
        return COLOR3.WHITE
    end

    local camp = self.oreWarsInfo.camp
    if camp == ORE_WARS_CAMP.lanmao then
        return COLOR3.BLUE
    elseif camp == ORE_WARS_CAMP.chiyan then
        return COLOR3.RED
    end
end

function TaskMgr:MSG_KSDZ_TIME(data)
    self.oreWarsTimeInfo = data
end

function TaskMgr:getOreWarsTimeInfo()
    return self.oreWarsTimeInfo
end

function TaskMgr:MSG_YONGCWYK_INFO(data)
    self.wykInfo = data

    -- 参考化妆舞会实现，刷新房间名称
    DlgMgr:sendMsg("SystemFunctionDlg", "updateServerInfo")
end

function TaskMgr:getWykInfo()
    return self.wykInfo
end

function TaskMgr:MSG_BAXIAN_LEFT_TIMES(data)
    self.baxian_left_times = data.left_time
end

function TaskMgr:cmdBaxianDice()
    gf:CmdToServer("CMD_BAXIAN_DICE",{})
end

function TaskMgr:cmdBaxianDiceFinish()
    gf:CmdToServer("CMD_BAXIAN_DICE_FINISH",{})
end

-- >>>棕仙楼
function TaskMgr:MSG_ZXSL_INFO(data)
    self.zongXianInfo = data

    DlgMgr:sendMsg("MissionDlg", "refreshFubenPanel")
end

function TaskMgr:getZongXianInfo()
    return self.zongXianInfo
end

function TaskMgr:getZhongXianInfo()
    return self.zhongXianInfo
end

-- 【七夕节】千里相会是否处于可离队状态
function TaskMgr:qianLXHIsCanLeaveTeam()
    local task = self.tasks[CHS[5400073]]
    if task
        and not string.match(task.task_prompt, CHS[5400082])
        and not string.match(task.task_prompt, CHS[5400083])
        and not string.match(task.task_prompt, CHS[5400085]) then

        return false
    end

    return true
end

function TaskMgr:getZongXianAutoWalkTip()
    if not self.zongXianInfo then
        return
    end

    local data = self.zongXianInfo
    local floor = MapMgr:getZongXianLouFloor()
    if not floor then
        return
    end

    local tip
    if floor == 1 then
        if data.qinglong == 1 and
              data.baihu == 1 and
              data.zhuque == 1 and
              data.xuanwu == 1 then
            tip = CHS[7003057]
        end
    elseif floor == 2 then
        if data.zuoHF == 1 and
              data.youHF == 1 then
            tip = CHS[7003058]
        end
    end

    return tip
end
-- <<<<棕仙楼

--
function TaskMgr:getLeftTimeWithMinAndSec(leftTime)
    leftTime = math.max(0, leftTime)
    local min = math.floor(leftTime / 60)
    local sec = leftTime % 60
    return string.format("%02d:%02d", min, sec)
end

-- 该接口，大于1小时显示  xx小时     小于1小时显示xx分钟，小于1分钟显示1分钟
function TaskMgr:getLeftTimeWithHours(leftTime)
    if leftTime > 60 * 60 then
        -- 大于1小时，显示x小时
        return string.format(CHS[4100093], math.ceil(leftTime / (60 * 60)))
    elseif leftTime > 60 then
        -- 大于1分钟，显示x分钟
        local minute = math.ceil(leftTime / 60)
        if minute == 60 then
            -- 时间向上取整为60分钟时，返回1小时
            return string.format(CHS[4100093], 1)
    else
            return string.format(CHS[4300223], minute)
        end
    else
        return string.format(CHS[4300223], 1)
    end
end

-- 打开窗口并且在某个控件上增加骨骼动画
function TaskMgr:openDlgAndAddArmatureMagic(dlgName, ctrlNameStr, particle, resTag)
    local ctrlName, root
    -- 由于控件重名，传父节点，所以 ctrlName 可能为 "ctrl:root"，例如刷道界面宠风散 ButtonPanel2:AddButton
    if string.match(ctrlNameStr, ":") then
        local tab = gf:split(ctrlNameStr, ":")
        root = tab[1]
        ctrlName = tab[2]
    else
        ctrlName = ctrlNameStr
    end

    local dlg = DlgMgr:openDlg(dlgName)
    local ctrl = dlg:getControl(ctrlName, nil, root)
    if ctrl:getChildByTag(resTag) then
        ctrl:removeChildByTag(resTag)
    end

    gf:createArmatureMagic(particle, ctrl, resTag)
end

-- 打開窗口並且在某個控件上增加循環光效
function TaskMgr:MSG_OPEN_DLG_AND_ADD_LOOP_MAGIC(data)
    local magicIcon = string.format("%05d", data.resIcon)
    local magicAction = nil

    for k,v in pairs(ResMgr.ArmatureMagic) do
        if v.name == magicIcon then
            magicAction = v.action
        end
    end

    if magicAction then
        TaskMgr:openDlgAndAddArmatureMagic(data.dlgName, data.ctrlName, {name = magicIcon, action = magicAction}, Const.ARMATURE_MAGIC_TAG)
    end
end

-- 地劫任务奖励
function TaskMgr:MSG_DIJIE_FINISH_TASK(data)
    local dlg = DlgMgr:openDlg("DijFinishDlg")
    dlg:setRewardInfo(data, "diji")
end

-- 天劫-渡劫成功
function TaskMgr:MSG_TIANJIE_FINISH_TASK(data)
    local dlg = DlgMgr:openDlg("DijFinishDlg")
    dlg:setRewardInfo(data, "tianjie")
end

-- 剑冢机缘奖励
function TaskMgr:MSG_FINISH_JIANZHONG_JIYUAN_TASK(data)
    local dlg = DlgMgr:openDlg("DijFinishDlg")
    dlg:setRewardInfo(data, "yuanshen")
end

-- 南天门试炼 奖励界面
function TaskMgr:MSG_FINISH_NTMSL_TASK(data)
    local dlg = DlgMgr:openDlg("DijFinishDlg")
    dlg:setRewardInfo(data, "ntm")
end

function TaskMgr:MSG_ZHONGXIANTA_INFO(data)
    self.zhongXianInfo = data
end

-- 获取任务倒计时显示刷新间隔，默认 10 秒
function TaskMgr:getTaskDelayTime(task)
    if task.task_type == CHS[5400231] and not string.match(task.task_prompt, CHS[5420220]) then
        -- 培育巨兽
        return 1
    end

    return 10
end

-- 获取任务倒计时的显示时间字符串
function TaskMgr:getTaskTimeStr(task, isDesc)
    local leftTime = math.max(0, task.task_end_time - gf:getServerTime())
    local leftTimeStr
    if task.task_type == CHS[5400231] and not string.match(task.task_prompt, CHS[5420220]) then
        -- 培育巨兽
        leftTimeStr = leftTime .. CHS[2000086]
    elseif task.task_type == CHS[5200005] then
        -- 【体验】年卡会员
        leftTime = tonumber(task.task_extra_para)
        leftTimeStr = "" .. math.floor(leftTime / (24 * 60 * 60)) .. CHS[6000229]
    elseif task.task_type == CHS[4200383] then
        -- 九曲玲珑笔描述与提示的倒计时显示不同
        leftTimeStr = self:getLeftTimeWithHours(leftTime)
    else
        leftTimeStr = self:getLeftTime(leftTime)
    end

    return leftTimeStr
end

-- 水岚之缘打开信封
function TaskMgr:MSG_TASK_SHUILZY_CCJM_LETTER()
    DlgMgr:openDlg("BridgeMailDlg")
end

function TaskMgr:isMRZBJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[4101051])
    if journaTask then
        return true
    end

    return false
end

function TaskMgr:isQCLDJournalist()
    local journaTask = TaskMgr:getTaskByName(CHS[7150140])
    if journaTask then
        return true
    end

    return false
end

function TaskMgr:getGiveUpTisByName(taskName, tips)

    if TaskMgr:getTaskByName(taskName) then
        local taskInfo = TaskMgr:getTaskByName(taskName)
        --[[
        -- 修改需求了，接口以后可以用！
        if tonumber(taskInfo.task_extra_para) and tonumber(taskInfo.task_extra_para) <= 11 and tonumber(taskInfo.task_extra_para) >= 1 then
            return CHS[4010121]
        end
        --]]
    end

    return tips
end

-- 进入游戏消息
function TaskMgr:MSG_ENTER_GAME(data)
    if GameMgr:IsCrossDist() then
        local arr = {}
        if DistMgr:isInQMPKServer() then
            -- 全民PK区组
            for task_type, _ in pairs(self.tasks) do
                if not TASK_IN_QMPK_SERVER[task_type] then
                    -- 找到需要移除对应的任务信息
                    table.insert(arr, task_type)
                end
            end
        end

        if DistMgr:isInZBYLServer() then
            -- 争霸娱乐区组
            for task_type, _ in pairs(self.tasks) do
                if not TASK_IN_ZBYL_SERVER[task_type] then
                    -- 找到需要移除对应的任务信息
                    table.insert(arr, task_type)
                end
            end
        end

        for i = 1, #arr do
            -- 移除对应的任务信息
            local data = self.tasks[arr[i]]
            data.task_prompt = ""
            self:addReal(data)
        end
    end
end

function TaskMgr:isInTaskBKTX(taskPara)

    if TaskMgr:getTaskByName(CHS[4010227]) then
        local task = TaskMgr:getTaskByName(CHS[4010227])
        local taskState = tonumber(task.task_extra_para)

        if taskPara then
            return taskPara == taskState
        end

        if taskState and taskState >= 1 and taskState <= 9 then
            return true
        end
    end

    return false
end

MessageMgr:regist("MSG_BAXIAN_LEFT_TIMES", TaskMgr)
MessageMgr:regist("MSG_ZNQ_2017_XMMJ", TaskMgr)
MessageMgr:regist("MSG_TASK_STATUS_INFO", TaskMgr)
MessageMgr:regist("MSG_TASK_PROMPT", TaskMgr)
MessageMgr:regist("MSG_SERVICE_LOG", TaskMgr)
MessageMgr:regist("MSG_CHECK_DOUBLE_POINT", TaskMgr)
MessageMgr:regist("MSG_REQUEST_CHANGE_LOOK", TaskMgr)
MessageMgr:regist("MSG_TONGTIANTA_INFO", TaskMgr)
MessageMgr:regist("MSG_PH_CARD_INFO", TaskMgr)
MessageMgr:regist("MSG_TASK_REPORT_INFO", TaskMgr)
MessageMgr:regist("MSG_HZWH_INFO", TaskMgr)
MessageMgr:regist("MSG_BAISZW_INFO", TaskMgr)
MessageMgr:regist("MSG_QMPK_INFO", TaskMgr)
MessageMgr:regist("MSG_MY_KSDZ_INFO", TaskMgr)
MessageMgr:regist("MSG_KSDZ_TIME", TaskMgr)
MessageMgr:regist("MSG_YONGCWYK_INFO", TaskMgr)
MessageMgr:regist("MSG_YISHI_ACTIVITY_INFO", TaskMgr)
MessageMgr:regist("MSG_ZXSL_INFO", TaskMgr)
MessageMgr:regist("MSG_ZHONGXIANTA_INFO", TaskMgr)
MessageMgr:regist("MSG_DIJIE_FINISH_TASK", TaskMgr)
MessageMgr:regist("MSG_TIANJIE_FINISH_TASK", TaskMgr)
MessageMgr:regist("MSG_FINISH_JIANZHONG_JIYUAN_TASK", TaskMgr)
MessageMgr:regist("MSG_OPEN_DLG_AND_ADD_LOOP_MAGIC", TaskMgr)
MessageMgr:regist("MSG_TASK_SHUILZY_CCJM_LETTER", TaskMgr)
MessageMgr:regist("MSG_FINISH_NTMSL_TASK", TaskMgr)

MessageMgr:hook("MSG_ENTER_GAME", TaskMgr, "TaskMgr")

return TaskMgr
