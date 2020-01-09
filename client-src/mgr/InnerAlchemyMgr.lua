-- InnerAlchemyMgr.lua
-- created by lixh Des/28/2017
-- 内丹修炼管理器

InnerAlchemyMgr = Singleton()

InnerAlchemyMgr.alchemyData = nil

-- 修炼阶段
local INNER_ALCHEMY_STAGE_CN = {
    CHS[7100129], -- 一阶
    CHS[7100130], -- 二阶
    CHS[7100131], -- 三阶
    CHS[7100132], -- 四阶
    CHS[7100133], -- 五阶
}

-- 修炼境界
local INNER_ALCHEMY_STATE_CN = {
    CHS[7100124], -- 筑基炼气
    CHS[7100125], -- 凝气化神
    CHS[7100126], -- 还虚合道
    CHS[7100127], -- 内丹初成
    CHS[7100128], -- 金丹大成
}

-- 修炼境界图片
local INNER_ALCHEMY_STATE_UI = {
    ResMgr.ui.inner_alchemy_state_one,   -- 内丹修炼境界一
    ResMgr.ui.inner_alchemy_state_two,   -- 内丹修炼境界二
    ResMgr.ui.inner_alchemy_state_three, -- 内丹修炼境界三
    ResMgr.ui.inner_alchemy_state_four,  -- 内丹修炼境界四
    ResMgr.ui.inner_alchemy_state_five,  -- 内丹修炼境界五
}

-- 判断内丹是否开启，等级，大飞(用于名片，聚宝斋等数据)
function InnerAlchemyMgr:isInnerAlchemyOpen(level, upgradeType)
    if level and upgradeType and tonumber(level) >= 120 and tonumber(upgradeType) > CHILD_TYPE.XUEYING then
        return true
    end

    return false
end

-- 获取内丹修炼境界
function InnerAlchemyMgr:getAlchemyState(state)
    if type(state) == 'number' and state > 0 and state <= #INNER_ALCHEMY_STATE_CN then
        return INNER_ALCHEMY_STATE_CN[state]
    end

    return state
end

-- 获取内丹修炼阶段
function InnerAlchemyMgr:getAlchemyStage(stage)
    if type(stage) == 'number' and stage > 0 and stage <= #INNER_ALCHEMY_STAGE_CN then
        return INNER_ALCHEMY_STAGE_CN[stage]
    end

    return stage
end

-- 获取内丹境界图片
function InnerAlchemyMgr:getAlchemyStateUiByState(state)
    if type(state) == 'number' and state > 0 and state <= #INNER_ALCHEMY_STATE_UI then
        return INNER_ALCHEMY_STATE_UI[state]
    end

    return INNER_ALCHEMY_STATE_UI[1]
end

-- 获取当前最大精气
function InnerAlchemyMgr:getCurrentMaxSpirit()
    return Me:queryBasicInt("dan_data/exp_to_next_level")
end

-- 获取当前已获得的精气
function InnerAlchemyMgr:getCurrentSpirit()
    return Me:queryBasicInt("dan_data/exp")
end

-- 获取当天获得的最大精气
function InnerAlchemyMgr:getCurrentDayMaxSpirit()
    return Const.INNERALCHEMY_DAY_MAX_SPIRIT
end

-- 获取当天已获得的精气
function InnerAlchemyMgr:getCurrentDaySpirit()
    return Me:queryBasicInt("dan_data/today_exp")
end

-- 是否达到最高境界最高阶段
function InnerAlchemyMgr:isMaxStateAndStage()
    if Me:queryBasicInt("dan_data/state") == INNER_ALCHEMY_STATE.FIVE and
        Me:queryBasicInt("dan_data/stage") == INNER_ALCHEMY_STAGE.FIVE then
        return true
    end

    return false
end

-- 获取当前内丹突破任务类型
function InnerAlchemyMgr:getBreakTaskType()
    local task = TaskMgr:getTaskByName(CHS[7100118])
    if task then
        if task.task_extra_para and tonumber(task.task_extra_para) == 0 then
            return INNER_ALCHEMY_BREAK_STATUS.IN_BREAK
        else
            return INNER_ALCHEMY_BREAK_STATUS.OVER_BREAK
        end
    else
        return INNER_ALCHEMY_BREAK_STATUS.NOT_IN_BREAK
    end
end

-- 获取内丹数据
function InnerAlchemyMgr:getAlchemyData()
    return self.alchemyData
end

-- 刷新内丹数据
function InnerAlchemyMgr:MSG_REFRESH_NEIDAN_DATA(data)
    self.alchemyData = data
end

-- 可以领取内丹任务
function InnerAlchemyMgr:MSG_NEIDAN_CAN_GET_TASK()
    PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_INNER_ALCHEMY)
end

-- 内丹突破任务领取完成
function InnerAlchemyMgr:MSG_GET_NEIDAN_BREAK_TASK_SUCC()
    PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_INNER_ALCHEMY)
end

-- 内丹突破任务完成
function InnerAlchemyMgr:MSG_NEIDAN_BREAK_TASK_SUCC()
    PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_ATTRIB)
    PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_POLAR)
end

-- Me身上内丹数据发生变化
function InnerAlchemyMgr:MSG_UPDATE(map)
    if map and map["dan_data/exp"] == 0 then
        -- exp == 0 为突破任务完成或初始登录的情况
        PromoteMgr:checkPromote(PROMOTE_TYPE.TAG_INNER_ALCHEMY)
    end
end

MessageMgr:hook("MSG_UPDATE", InnerAlchemyMgr, "InnerAlchemyMgr")
MessageMgr:regist("MSG_GET_NEIDAN_BREAK_TASK_SUCC", InnerAlchemyMgr)
MessageMgr:regist("MSG_NEIDAN_BREAK_TASK_SUCC", InnerAlchemyMgr)
MessageMgr:regist("MSG_NEIDAN_CAN_GET_TASK", InnerAlchemyMgr)
MessageMgr:regist("MSG_REFRESH_NEIDAN_DATA", InnerAlchemyMgr)
