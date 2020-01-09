-- ExerciseDlg.lua
-- Created by liuhb Mar/03/2015
-- 修炼概要界面

local ExerciseDlg = Singleton("ExerciseDlg", Dialog)

local TASK_MAP = {
    {taskName = CHS[5000084], npc = CHS[5000086], map = CHS[5000088], levLimit = 20},
    {taskName = CHS[5000085], npc = CHS[5000087], map = CHS[5000088], levLimit = 60},
}

function ExerciseDlg:init()
    self:bindListener("XiuxingButton", self.onXiuxingButton)
    self:bindListener("XianRenZhiLuButton", self.onXianRenZhiLuButton)
    self:bindListener("ShiJueZhenButton", self.onShiJueZhenButton)
    self:bindListener("RuleButton", self.onRuleButton)
    gf:sendGeneralNotifyCmd(NOTIFY.GET_EXERCISE)

    self:updateView("0/0")
    self:hookMsg("MSG_GENERAL_NOTIFY")
end

function ExerciseDlg:updateView(timeStr)
    local time, totle = string.match(timeStr, "(%d+)/(%d+)")
    -- 获取当日已经完成轮次
    self.completeTime = time or 0
    self.totleTime = totle or 0

    local timeStr = string.format("%d/%d", time, totle)
    if totle > time then
        self:setLabelText("TimesLabel2", timeStr, nil, COLOR3.GREEN)
    else
        self:setLabelText("TimesLabel2", timeStr, nil, COLOR3.RED)
    end
end

function ExerciseDlg:checkIsCanOperate(levLimit, taskName)
    -- 判断是否是处于组队，且非暂离
    if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
        gf:ShowSmallTips(CHS[5000078])
        return false
    end

    -- 判断是否出于战斗中
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[5000079])
        return false
    end

    -- 获取当前等级
    local level = Me:queryBasicInt("level")
    if level < levLimit then
        local taskStr = string.format(CHS[5000080], taskName, levLimit)
        gf:ShowSmallTips(taskStr)
        return false;
    end

    return true
end

function ExerciseDlg:onXiuxingButton(sender, eventType)
    if not self:checkIsCanOperate(TASK_MAP[2].levLimit, TASK_MAP[2].taskName) then
        return
    end

    -- 判断今天轮次是否已经完成
    if self.completeTime >= self.totleTime then
        gf:confirm(CHS[5000081], function() self:autoFindNpc(TASK_MAP[1].map, TASK_MAP[1].npc) end)
    else
        self:autoFindNpc(TASK_MAP[2].map, TASK_MAP[2].npc)
    end
end

function ExerciseDlg:onXianRenZhiLuButton(sender, eventType)
    if not self:checkIsCanOperate(TASK_MAP[1].levLimit, TASK_MAP[1].taskName) then
        return
    end

    -- 判断今天轮次是否已经完成
    if self.completeTime >= self.totleTime then
        gf:confirm(CHS[5000081], function() self:autoFindNpc(TASK_MAP[1].map, TASK_MAP[1].npc) end)
    else
        self:autoFindNpc(TASK_MAP[1].map, TASK_MAP[1].npc)
    end
end

-- 自动寻路
function ExerciseDlg:autoFindNpc(map, npcName)
    -- 获取任务信息
    if npcName == CHS[5000086] and TaskMgr:isExistTaskByShowName(CHS[5000084]) then
        local taskInfo = TaskMgr:getTaskByShowName(CHS[5000084])
        AutoWalkMgr:beginAutoWalk(gf:findDest(taskInfo.task_prompt)) 
        return
    end

    if npcName == CHS[5000087] and TaskMgr:isExistTaskByShowName(CHS[5000085]) then
        local taskInfo = TaskMgr:getTaskByShowName(CHS[5000085])
        AutoWalkMgr:beginAutoWalk(gf:findDest(taskInfo.task_prompt))
        return
    end

    -- 获取NPC
    local mapId = MapMgr:getMapByName(map)
    local npc = MapMgr:getNpcByName(npcName)
    local autoWalkStr = string.format(CHS[3002594], npcName, map, npc.x, npc.y)
    AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
    DlgMgr:closeDlg(self.name)
end

function ExerciseDlg:onShiJueZhenButton(sender, eventType)
    gf:ShowSmallTips(CHS[5000082])
end

function ExerciseDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[5000083], sender)
end

function ExerciseDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.GET_EXERCISE ~= data.notify then
        return
    end

    -- 获取字符串，并设置
    local timeStr = data.para
    self:updateView(timeStr)
end

return ExerciseDlg
