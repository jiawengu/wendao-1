-- TanAnMgr.lua
-- Created by lixh May/24/2018
-- 探案管理器

TanAnMgr = Singleton()

--江湖绿林：记录士兵回忆前玩家的位置
TanAnMgr.orgMePos = nil

--江湖绿林：士兵回忆时玩家的视角位置
TanAnMgr.meSightPos = cc.p(199, 119)

--江湖绿林：士兵回忆时不需要被隐藏的对象
TanAnMgr.memoryNotHideChar = {}

--江湖绿林：是否处于士兵回忆状态
TanAnMgr.isInMemory = false

--江湖绿林：回忆状态npc数据
TanAnMgr.memoryNpcs = {}

--江湖绿林：回忆状态npc走动点
local MEMERY_NPC_POS = {START = {x = 191, y = 120}, END = {x = 177, y = 113}}

--江湖绿林：回忆状态npc速度
local MEMERY_NPC_SPEED_PERCENT = -50

--江湖绿林：追踪，光圈位置
local LIGHT_CIRCLE_POS = {x = 51, y = 37}

--江湖绿林：跟踪状态
local FOLLOW_STATUS = {
    NONE = 1,
    TO_CIRCLE = 2,
    WAIT_SERVER = 3,
    IN_FOLLOW = 4,
    FOLLOW_FAIL = 5,
}

--江湖绿林：初始跟踪状态
TanAnMgr.followStatus = FOLLOW_STATUS.NONE

--江湖绿林：追踪npcId
local FOLLOW_NPC_ID = 999

--江湖绿林：追踪行走路线
local FOLLOW_NPC_ROUTE = {
    {{x = 62, y = 44}, {x = 89, y = 60}, {x = 52, y = 85}, {x = 79, y = 106}, {x = 117, y = 80}, {x = 173, y = 111}},
    {{x = 62, y = 44}, {x = 107, y = 15}, {x = 62, y = 44}, {x = 100, y = 68}, {x = 162, y = 35}, {x = 195, y = 57}, {x = 134, y = 89}, {x = 173, y = 111}},
    {{x = 62, y = 44}, {x = 117, y = 80}, {x = 75, y = 107}, {x = 97, y = 135}, {x = 155, y = 102}, {x = 173, y = 111}},
}

--江湖绿林：追踪定时器时间间隔
local FOLLOW_NPC_CHECK_TIME = 0.1

--江湖绿林：追踪NPC喊话
local FOLLOW_NPC_PROPAGANDA = {
    CHS[7190263],
    CHS[7190264],
    CHS[7190265],
    CHS[7190266],
    CHS[7190267],
    CHS[7190268],
    CHS[7190269],
    CHS[7190270],
    CHS[7190271],
    CHS[7190272],
}

-- 江湖绿林：追踪NPC最近距离、最远距离、最长时间配置
local FOLLOW_UNSAFE_CFG = {CLOSED = 5, FARAWAY = 15, CLOSE_TIME = 2, FARAWAY_TIME = 3}

-- 江湖绿林：npc头顶光效偏移
local MAGIC_OFFESET_Y = 20
local CHAT_OFFSET_Y = MAGIC_OFFESET_Y + 20

-- 迷仙镇案 地图家具配置
local MXZA_ROOM_FURNITURE_CFG = {
    [28103] = require(ResMgr:getCfgPath("XiaoTongFuMuJia.lua")),
    [28104] = require(ResMgr:getCfgPath("XiaoTongShuShuJia.lua")),
    [28105] = require(ResMgr:getCfgPath("ChangSheFuJia.lua")),
    [28106] = require(ResMgr:getCfgPath("XiaoTongYeYeJia.lua")),
}

-- 破案时间格式化字符串
function TanAnMgr:getTimeStr(time)
    local day = math.floor(time / 86400)
    local hour = math.floor(time % 86400 / 3600)
    local minute = math.floor(time % 3600 / 60)

    if day == 0 then
        if hour == 0 then
            return string.format(CHS[7190253], minute)
        else
            return string.format(CHS[7190252], hour, minute)
        end
    else
        return string.format(CHS[7190251], day, hour, minute)
    end
end

-- 打开小纸条界面
function TanAnMgr:openTipsDlg(data)
    local dlg = DlgMgr:openDlg("CaseMailDlg")
    dlg:setData(data)
end

function TanAnMgr:MSG_RKSZ_PAPER_MESSAGE(data)
    TanAnMgr:openTipsDlg(data)
end

function TanAnMgr:MSG_DETECTIVE_TASK_CLUE(data)
    local dlg = DlgMgr:openDlg("DossierDlg")
    dlg:setData(data)
end

function TanAnMgr:MSG_DETECTIVE_TASK_CLUE_PARALLEL(data)
    TanAnMgr:MSG_DETECTIVE_TASK_CLUE(data)
end

function TanAnMgr:MSG_DETECTIVE_RANKING_INFO(data)
    local dlg = DlgMgr:openDlg("CaseRankingListDlg")
    dlg:setData(data)
end

-- NPC喊话
function TanAnMgr:setGuestPropaganda(char, text)
    -- 跟踪时定时器中会喊话，达到终点时也会喊话，所以喊话前先清掉其他喊话
    char:removeAllChat()

    ChatMgr:sendCurChannelMsgOnlyClient({
        id = char:getId(),
        gid = 0,
        icon = char:queryBasicInt("icon"),
        name = char:getName(),
        msg =  text,
    })
end

-- 【探案】江湖绿林  启动定时器
function TanAnMgr:startSchedule(timeStamp)
    local tick = 0
    if not self.scheduleId then
        self.scheduleId = gf:Schedule(function()
            if TanAnMgr:isLvLinTaskInThirdStatus() then
                -- 江湖绿林s3状态
                if self.followStatus == FOLLOW_STATUS.NONE then
                    return
                elseif self.followStatus == FOLLOW_STATUS.TO_CIRCLE then
                    if TanAnMgr:isMeInLightCircle() then
                    -- 玩家踩到圈了
                        TanAnMgr:cmdGZResultToServer(true, 0)
                        self.followStatus = FOLLOW_STATUS.WAIT_SERVER
                    end
                elseif self.followStatus == FOLLOW_STATUS.WAIT_SERVER then
                    return
                elseif self.followStatus == FOLLOW_STATUS.IN_FOLLOW then
                    tick = tick + 1

                    -- 跟踪状态，尝试刷新npc速度，尝试进行npc喊话
                    local npc = CharMgr:getCharById(FOLLOW_NPC_ID)
                    if not npc then
                        TanAnMgr:cmdGZResultToServer(false, 0)
                        return
                    end

                    if tick % 10 == 0 then
                        -- 每秒，npc更新一次速度
                        TanAnMgr:updateFollowNpcSpped(npc)
                    end

                    if tick % 40 == 0 then
                        -- 每4秒，npc进行一次喊话
                        TanAnMgr:followNpcPropaganda(npc)
                    end

                    self:checkUnSafeDistance(npc)
                elseif self.followStatus == FOLLOW_STATUS.FOLLOW_FAIL then
                    if not TanAnMgr:isMeInLightCircle() then
                        -- 玩家必须走出圈外才能重新触发跟踪流程
                        self.followStatus = FOLLOW_STATUS.TO_CIRCLE
                    end
                end
            else
                self:stopSchedule()
            end
        end, timeStamp)
    end
end

-- 【探案】江湖绿林  停止定时器
function TanAnMgr:stopSchedule()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

-- 【探案】江湖绿林  进入追踪状态
function TanAnMgr:goToFollowStatus(data)
    local function callBack(index)
        -- 追踪npc到达终点后，尝试进行下一段寻路
        local npc = CharMgr:getCharById(FOLLOW_NPC_ID)
        if not npc then return end

        local goNextFlag = false
        local nextIndex = index + 1
        if self.routine[nextIndex] then
            goNextFlag = true
            performWithDelay(gf:getUILayer(), function()
                -- npc到达上一段终点后，会在下一帧清除到达终点的回调，此处需要延迟一帧设置下一段寻路
                npc:setEndPos(self.routine[nextIndex].x, self.routine[nextIndex].y, {func = callBack, para = nextIndex})
            end, 0)
        else
            self.followStatus = FOLLOW_STATUS.NONE
        end

        if not goNextFlag then
            -- 到达最终目的地，先停止定时器，防止喊话被覆盖
            self:stopSchedule()

            -- npc喊话
            TanAnMgr:setGuestPropaganda(npc, CHS[7190277])

            TanAnMgr:cmdGZResultToServer(false, 1)
        end
    end

    -- 隐藏主界面
    GameMgr:hideAllUI(0)

    -- 移除光圈
    TanAnMgr:removeLightCircleMagic()

    -- 生成随机路线
    self.routine = FOLLOW_NPC_ROUTE[math.random(1, #FOLLOW_NPC_ROUTE)]

    -- 生成npc
    CharMgr:MSG_APPEAR({x = self.routine[1].x, y = self.routine[1].y, dir = 3, id = FOLLOW_NPC_ID, icon = data.icon,
    type = OBJECT_TYPE.NPC, name = data.name, opacity = 0,
    light_effect_count = 0, isNowLoad = true})

    local char = CharMgr:getCharById(FOLLOW_NPC_ID)
    char:setVisible(true)

    -- 生成的npc与Me无需隐藏，其他对象均需要隐藏
    TanAnMgr:setNotHideCharById(FOLLOW_NPC_ID)
    TanAnMgr:setNotHideCharById(Me:getId())

    -- npc出现后0.5秒走动，一出来就在跑的效果不好
    performWithDelay(gf:getUILayer(), function()
        -- 设置npc走到终点，到达终点后回调
        local char = CharMgr:getCharById(FOLLOW_NPC_ID)
        if not char then
            -- 角色不存在，通知追踪失败
            TanAnMgr:cmdGZResultToServer(false, 0)
            return
        end

        char:setEndPos(self.routine[2].x, self.routine[2].y, {func = callBack, para = 2})
        self:startSchedule(FOLLOW_NPC_CHECK_TIME)

        -- 提示跟紧npc
        gf:ShowSmallTips(string.format(CHS[7190280], char:getName()))
    end, 0.5)

    self.followStatus = FOLLOW_STATUS.IN_FOLLOW
end

-- 【探案】江湖绿林  退出追踪状态
function TanAnMgr:outOfFollowStatus()
    -- 显示主界面，解除冻屏
    GameMgr:showAllUI(0)

    -- 停止定时器
    self:stopSchedule()

    -- 重置检测时间
    self.tooClosedTime = 0
    self.tooFarawayTime = 0

    -- 析构npc
    CharMgr:deleteChar(FOLLOW_NPC_ID)

    -- 清空不需要被隐藏的对象id
    TanAnMgr:clearNotHideChar()

    -- 增加跟踪失败标记
    self.followStatus = FOLLOW_STATUS.FOLLOW_FAIL

    -- 退出追踪状态后，尝试再次进入踩圈状态，因为可能是追踪失败
    TanAnMgr:MSG_TASK_PROMPT({TaskMgr.tasks[CHS[7190256]]})
end

-- 【探案】江湖绿林  追踪状态  检查玩家与npc距离
function TanAnMgr:checkUnSafeDistance(npc)
    if not npc then return end

    local npcX, npcY = gf:convertToMapSpace(npc.curX, npc.curY)
    local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)
    if gf:distance(npcX, npcY, meX, meY) < FOLLOW_UNSAFE_CFG.CLOSED then
        -- 距离太近
        if not self.tooClosedTime then self.tooClosedTime = 0 end
        self.tooClosedTime = self.tooClosedTime + FOLLOW_NPC_CHECK_TIME

        TanAnMgr:refreshJhllFollowMagic(ResMgr.magic.tanan_jhll_too_close)
    elseif gf:distance(npcX, npcY, meX, meY) > FOLLOW_UNSAFE_CFG.FARAWAY then
        -- 距离太远
        if not self.tooFarawayTime then self.tooFarawayTime = 0 end
        self.tooFarawayTime = self.tooFarawayTime + FOLLOW_NPC_CHECK_TIME

        TanAnMgr:refreshJhllFollowMagic(ResMgr.magic.tanan_jhll_too_far)
    else
        -- 距离正常，移除特效
        TanAnMgr:refreshJhllFollowMagic()
        return
    end

    if self.tooClosedTime and FOLLOW_UNSAFE_CFG.CLOSE_TIME < self.tooClosedTime then
        -- 太近时间超过限制，停止定时器防止喊话被覆盖，停止走动
        self:stopSchedule()
        npc:setEndPos(gf:convertToMapSpace(npc.curX, npc.curY))
        TanAnMgr:cmdGZResultToServer(false, -1)
    end

    if self.tooFarawayTime and FOLLOW_UNSAFE_CFG.FARAWAY_TIME < self.tooFarawayTime then
        -- 太远时间超过限制，停止定时器防止喊话被覆盖，停止走动
        self:stopSchedule()
        npc:setEndPos(gf:convertToMapSpace(npc.curX, npc.curY))
        TanAnMgr:cmdGZResultToServer(false, -2)
    end
end

-- 【探案】江湖绿林 追踪状态  移除特效
function TanAnMgr:removeJhllFollowMagic(icon)
    if not icon then return end
    local npc = CharMgr:getCharById(FOLLOW_NPC_ID)
    if not npc then return end

    local magic = npc.middleLayer:getChildByTag(icon)
    if magic then
        magic:removeFromParent()
        magic = nil
    end
end

-- 【探案】江湖绿林 追踪状态  特效
function TanAnMgr:refreshJhllFollowMagic(icon)
    local npc = CharMgr:getCharById(FOLLOW_NPC_ID)
    if not npc then return end

    -- 没有icon, 说明需要移除两个特效
    if not icon then
        TanAnMgr:removeJhllFollowMagic(ResMgr.magic.tanan_jhll_too_far)
        TanAnMgr:removeJhllFollowMagic(ResMgr.magic.tanan_jhll_too_close)
        return
    end

    -- 增加警惕特效，先移除松懈特效
    if icon == ResMgr.magic.tanan_jhll_too_far then
        TanAnMgr:removeJhllFollowMagic(ResMgr.magic.tanan_jhll_too_close)
    end

    -- 增加松懈特效，先移除警惕特效
    if icon == ResMgr.magic.tanan_jhll_too_close then
        TanAnMgr:removeJhllFollowMagic(ResMgr.magic.tanan_jhll_too_far)
    end

    -- 通知聊天气泡界面上移
    npc:upAllChat(CHAT_OFFSET_Y)

    -- 特效已存在
    if npc.middleLayer:getChildByTag(icon) then return end

    -- 增加特效
    local headX, headY = npc.charAction:getHeadOffset()
    local magic = gf:createLoopMagic(icon, nil, {blendMode = "add"})
    magic:setAnchorPoint(0.5, 0.5)
    magic:setLocalZOrder(Const.CHARACTION_ZORDER)
    magic:setPosition(0, headY + MAGIC_OFFESET_Y)
    magic:setTag(icon)
    npc:addToMiddleLayer(magic)
end

-- 【探案】江湖绿林 追踪状态  通知服务器结果
function TanAnMgr:cmdGZResultToServer(startFlag, finishFlag)
    gf:CmdToServer("CMD_TANAN_JHLL_GAME_GZ", {isStart = startFlag and 1 or 0, isFinish = finishFlag})

    -- 通知服务器结果后，先停止定时器，等服务器数据回来再重新开启
    if not TeamMgr:inTeam(Me:getId()) then
        -- 非队伍中，触发追踪状态停止定时器，队伍中不停止，因为队伍中服务器不会让玩家进入跟踪状态
        TanAnMgr:stopSchedule()
    end
end

-- 【探案】江湖绿林  追踪状态  更新npc行走速度(-50, +50)的变化范围
function TanAnMgr:updateFollowNpcSpped(char)
    local addPercent = (math.random(0, 10) - 5) * 10
    char:setSeepPrecent(addPercent)
end

-- 【探案】江湖绿林  追踪状态  npc进行喊话
function TanAnMgr:followNpcPropaganda(char)
    local text = FOLLOW_NPC_PROPAGANDA[math.random(1, #FOLLOW_NPC_PROPAGANDA)]
    TanAnMgr:setGuestPropaganda(char, text)
end

-- 【探案】江湖绿林  追踪状态  玩家是否踩到光圈
function TanAnMgr:isMeInLightCircle()
    local mapEffectLayer = gf:getMapEffectLayer()
    if not mapEffectLayer or not mapEffectLayer:getChildByName(CHS[7190262])then
        -- 特效不存在时，不认为踩到光圈了
        return false
    end

    local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)
    if math.abs(meX - LIGHT_CIRCLE_POS.x) < 2 and math.abs(meY - LIGHT_CIRCLE_POS.y) < 2 then
        return true
    end

    return false
end

-- 【探案】江湖绿林  追踪状态  播放光圈效果
function TanAnMgr:playLightCircleMagic()
    if self.followStatus == FOLLOW_STATUS.IN_FOLLOW then return end
    local x, y = gf:convertToClientSpace(LIGHT_CIRCLE_POS.x, LIGHT_CIRCLE_POS.y)
    MapMagicMgr:playLoopMagic({icon = ResMgr.magic.red_circle}, x, y, CHS[7190262])
    if self.followStatus ~= FOLLOW_STATUS.FOLLOW_FAIL then
        -- 非跟踪失败状态，直接切换成踩圈状态
        self.followStatus = FOLLOW_STATUS.TO_CIRCLE
    end

    self:startSchedule(0.1)
end

-- 【探案】江湖绿林  追踪状态  移除光圈效果
function TanAnMgr:removeLightCircleMagic()
    MapMagicMgr:remoevMagicByName(CHS[7190262])
end

-- 【探案】江湖绿林 士兵回忆状态  npcId
function TanAnMgr:getNpcId(i)
    return i  * 100
end

-- 【探案】江湖绿林 士兵回忆状态  通知服务器结果
function TanAnMgr:cmdXYResultToServer(flag)
    gf:CmdToServer("CMD_TANAN_JHLL_GAME_XY", {isFinish = flag and 1 or 0})
end

-- 【探案】江湖绿林 士兵回忆状态  刷新npc
function TanAnMgr:startMemoryNpcs()
    if not self.memoryNpcs.count or self.memoryNpcs.count <= 0 then
        TanAnMgr:cmdXYResultToServer(true)
        return
    end

    local function callBack(id)
        -- npc停止再析构，防止闪没了
        performWithDelay(gf:getUILayer(), function()
            CharMgr:deleteChar(id)
            TanAnMgr:startMemoryNpcs()
        end, 0.1)
    end

    -- 获取npc数据
    local id = TanAnMgr:getNpcId(self.memoryNpcs.count)
    local npcData = self.memoryNpcs.list[1]
    table.remove(self.memoryNpcs.list, 1)
    self.memoryNpcs.count = self.memoryNpcs.count - 1

    -- 回忆中的npc不需要隐藏
    TanAnMgr:setNotHideCharById(id)

    -- 生成npc
    CharMgr:MSG_APPEAR({x = MEMERY_NPC_POS.START.x, y = MEMERY_NPC_POS.START.y, dir = 1, id = id, icon = npcData.icon,
    type = OBJECT_TYPE.NPC, name = npcData.name, opacity = 0,
    light_effect_count = 0, isNowLoad = true})

    local char = CharMgr:getCharById(id)
    char:setVisible(true)
    char:setSeepPrecent(MEMERY_NPC_SPEED_PERCENT)

    -- npc出现后0.5秒再喊话走动，一出来就在跑的效果不好
    performWithDelay(gf:getUILayer(), function()
        -- npc喊话
        TanAnMgr:setGuestPropaganda(char, npcData.text)

        -- 设置npc走到终点，到达终点后回调
        char:setEndPos(MEMERY_NPC_POS.END.x, MEMERY_NPC_POS.END.y, {func = callBack, para = id})
    end, 0.5)
end

-- 【探案】江湖绿林 士兵回忆状态/追踪状态 char是否需要被隐藏
function TanAnMgr:isNeedHideChar(char)
    if (self.isInMemory or TanAnMgr:isLvLinInFollow()) and not self.memoryNotHideChar[char:getId()] then
        return true
    end

    return false
end

-- 【探案】江湖绿林 士兵回忆状态/追踪状态不需要被隐藏的npc
function TanAnMgr:setNotHideCharById(id)
    self.memoryNotHideChar[id] = true
end

-- 【探案】江湖绿林 清空不需要被隐藏的npc
function TanAnMgr:clearNotHideChar()
    self.memoryNotHideChar = {}
end

-- 【探案】江湖绿林 进入士兵回忆状态
function TanAnMgr:goToMemory()
    -- 设置守城士兵不需要隐藏
    local soildier = CharMgr:getCharByName(CHS[7190261])
    if soildier then
        TanAnMgr:setNotHideCharById(soildier:getId())
    end

    -- 记录原来Me的位置，同时切换Me的视角，隐藏Me对象
    self.orgMePos = cc.p(Me.curX, Me.curY)
    Me:setPos(gf:convertToClientSpace(self.meSightPos.x, self.meSightPos.y))
    Me:setVisible(false)

    -- 隐藏主界面，同时冻屏
    GameMgr:hideAllUI(0)
    gf:frozenScreen(-1)

    self.isInMemory = true

    -- 开始播放npc巡游
    TanAnMgr:startMemoryNpcs()

    -- 给回忆中提示
    gf:ShowSmallTips(CHS[7100267])
end

-- 【探案】江湖绿林 退出士兵回忆状态
function TanAnMgr:outOfMemory()
    -- 回到Me原来位置，清除记录的位置，显示Me对象
    Me:setPos(self.orgMePos.x, self.orgMePos.y)
    self.orgMePos = nil
    Me:setVisible(true)

    -- 显示主界面，解除冻屏
    GameMgr:showAllUI(0)
    gf:unfrozenScreen()

    self.isInMemory = false
end

-- 判断【探案】江湖绿林任务是否处于s3状态
function TanAnMgr:isLvLinTaskInThirdStatus()
    local task = TaskMgr:getTaskByName(CHS[7190256])
    if task and task.task_extra_para == "3" then
        return true
    end

    return false
end

-- 【探案】江湖绿林 播放地图阴线/阳线 动画
function TanAnMgr:lvLinAddMapLineMagic(type, magicName, x, y)
    local action = "Bottom01"
    local callBackAction = "Bottom02"
    if type ~= "A" then
        action = "Bottom03"
        callBackAction = "Bottom04"
    end

    local function callBack(magic)
        if magic then
            magic:getAnimation():play(callBackAction)
        end
    end

    MapMagicMgr:playArmatureByPos({name = ResMgr.ArmatureMagic.tanan_ying_yang_line.name, action = action}, x, y, magicName, callBack)
end

-- 【探案】江湖绿林 是否处于跟踪状态
function TanAnMgr:isLvLinInFollow()
    return self.followStatus == FOLLOW_STATUS.IN_FOLLOW
end

-- 【探案】江湖绿林 刷新地图阴线/阳线
function TanAnMgr:lvLinRefreshMapLine(data)
    if not MapMgr:isInMapByName(data.mapName) then return end
    local mapInfo = MapMgr:getMapInfoByName(data.mapName)
    if not mapInfo then return end
    local x, y = gf:convertToClientSpace(mapInfo.npc[1].x, mapInfo.npc[1].y)

    local mapEffectLayer = gf:getMapEffectLayer()
    if not mapEffectLayer then return end

    -- 获取当前已划线数量
    local curCount = 0
    for i = 1, 3 do
        if mapEffectLayer:getChildByName(CHS[7190262] .. i) then
            curCount = curCount + 1
        end
    end

    -- 重置
    if curCount > data.count then
        for i = curCount , data.count, -1 do
            MapMagicMgr:remoevMagicByName(CHS[7190262] .. i)
        end

        return
    elseif curCount == data.count then
        return
    end

    for i = 1, data.count do
        if not mapEffectLayer:getChildByName(CHS[7190262] .. i) then
            TanAnMgr:lvLinAddMapLineMagic(data.list[i], CHS[7190262] .. i, x + 5 + i * 25, y - 40 * i - 20)
        end
    end

    -- 1秒后根据结果给提示
    performWithDelay(gf:getUILayer(), function()
        if data.ret == "ok" then
            gf:ShowSmallTips(CHS[7190278])
        elseif data.ret == "failed" then
            gf:ShowSmallTips(CHS[7190279])

            -- 错误时，需要移除地面阵法效果
            local mapEffectLayer = gf:getMapEffectLayer()
            if not mapEffectLayer then return end

            for i = 1, data.count do
                MapMagicMgr:remoevMagicByName(CHS[7190262] .. i)
            end
        end
    end, 2)
end

-- 【探案】江湖绿林 八卦爻的信息
function TanAnMgr:MSG_TANAN_JHLL_GUA_YAO(data)
    if not data then return end

    data.list = {}
    local len = string.len(data.answer)
    data.count = len
    for i = 1, len do
        data.list[i] = string.sub(data.answer, i, i)
    end

    TanAnMgr:lvLinRefreshMapLine(data)
end

-- 【探案】江湖绿林 跟踪状态数据
function TanAnMgr:MSG_TANAN_JHLL_GAME_GZ(data)
    if data.isStart == 1 then
        -- 进入跟踪状态
        TanAnMgr:goToFollowStatus(data)
    else
        -- 退出跟踪状态
        TanAnMgr:outOfFollowStatus()
    end
end

-- 【探案】江湖绿林 士兵回忆状态数据
function TanAnMgr:MSG_TANAN_JHLL_GAME_XY(data)
    self.memoryNpcs = data

    if data.isStart == 1 then
        TanAnMgr:goToMemory()
    elseif self.isInMemory then
        -- 处于回忆状态，则退出回忆状态
        TanAnMgr:outOfMemory()
    end
end

-- 刷新任务状态
function TanAnMgr:MSG_TASK_PROMPT(data)
    for k, v in ipairs(data) do
        if v.task_type == CHS[7190256] then
            if MapMgr:isInMapByName(CHS[7190215]) and TanAnMgr:isLvLinTaskInThirdStatus() then
                -- 天墉城内， 【探案】江湖绿林 s3状态，尝试开启进入踩圈状态
                self:playLightCircleMagic()
            elseif TanAnMgr:isLvLinInFollow() then
                TanAnMgr:outOfFollowStatus()
            else
                TanAnMgr:removeLightCircleMagic()
            end

            break
        end
    end
end

-- 过图
function TanAnMgr:MSG_ENTER_ROOM()
    if self.isInMemory then
        -- 处于回忆状态，则退出回忆状态
        TanAnMgr:outOfMemory()
    end

    if TanAnMgr:isLvLinInFollow() then
        -- 处于跟踪状态，则退出跟踪状态
        TanAnMgr:outOfFollowStatus()
    end

    if MapMgr:isInMapByName(CHS[7190215]) and TanAnMgr:isLvLinTaskInThirdStatus() then
        -- 天墉城内， 【探案】江湖绿林 s3状态，尝试开启进入踩圈状态
        self:playLightCircleMagic()
    else
        -- 停止定时器
        self:stopSchedule()
    end
end

-- 打开npc对话框
function TanAnMgr:MSG_MENU_LIST()
    if MapMgr:isInTanAnMxza() then
        local talkChar = CharMgr:getChar(Me:getTalkId())
        if not talkChar or talkChar:queryBasicInt("type") ~= OBJECT_TYPE.NPC then return end
        local REQUEST_EXHIBIT_NPC = {
            [CHS[7100366]] = true,  -- 小童母亲
            [CHS[7100367]] = true,  -- 小童父亲
            [CHS[7100368]] = true,  -- 小童叔叔
            [CHS[7100369]] = true,  -- 常舌馥
            [CHS[7100370]] = true,  -- 小童爷爷
            [CHS[7100371] .. "2"] = true,  -- 药店老板
            [CHS[7100372]] = true,  -- 镇内灵石
            [CHS[7100373]] = true,  -- 招魂道士
        }

        if REQUEST_EXHIBIT_NPC[talkChar:getName()] then
            -- 小童,小童的魂魄与捕头不需要打开使用证物界面
            gf:CmdToServer("CMD_MXZA_EXHIBIT_ITEM_LIST", {})
        end
    end
end

-- 迷仙镇案证物列表
function TanAnMgr:MSG_MXZA_EXHIBIT_ITEM_LIST(data)
    self.mxzaItemList = data

    -- 卷宗界面数据刷新
    DlgMgr:sendMsg("DossierDlg", "initMxzaItem")

    if MapMgr:isInTanAnMxza() then
        -- 打开证物界面，判断npc对话框是否还存在，不存在时不打开
        local npcDlg = DlgMgr:getDlgByName("NpcDlg")
        if not npcDlg then return end

        local evidenceDlg = DlgMgr:getDlgByName("CaseEvidenceDlg")
        if not evidenceDlg then
            evidenceDlg = DlgMgr:openDlg("CaseEvidenceDlg")
        end

        if evidenceDlg.lastPos then
            evidenceDlg:setPosition(evidenceDlg.lastPos)
        else
            local npcMainBody = npcDlg:getControl("MainBodyPanel")
            local npcMainBodySz = npcMainBody:getContentSize()
            local evidenceMainBodySz = evidenceDlg:getControl("MainPanel"):getContentSize()
            local npcPos = cc.p(npcMainBody:convertToWorldSpace(cc.p(0, 0)))
            evidenceDlg.lastPos = cc.p(npcPos.x - evidenceMainBodySz.width / 2,
                npcPos.y + npcMainBodySz.height / 2)
            evidenceDlg:setPosition(evidenceDlg.lastPos)
        end
    end
end

-- 获取证物列表
function TanAnMgr:getEvidenceItems()
    if not self.mxzaItemList then return {} end

    local items = {}
    for i = 1, self.mxzaItemList.count do
        local item = InventoryMgr:getItemInfoByName(self.mxzaItemList[i].name)
        if item then
            item = gf:deepCopy(item)
            item.name = self.mxzaItemList[i].name
            item.state = self.mxzaItemList.state
            item.item_unique = i
            item.real_desc = self.mxzaItemList[i].real_desc

            table.insert(items, item)
        end
    end

    return items
end

-- 迷仙镇案打开证物提交界面
function TanAnMgr:MSG_MXZA_SUBMIT_EXHIBIT_DLG(data)
    self.mxzaItemList = data

    local dlg = DlgMgr:openDlg("SubmitMultiItemDlg")
    dlg:setData(TanAnMgr:getEvidenceItems(), 1, "mxza")
end

-- 关闭npc对话框
function TanAnMgr:MSG_MENU_CLOSED()
    if MapMgr:isInTanAnMxza() then
        DlgMgr:closeDlg("CaseEvidenceDlg")
    end
end

-- 【探案】迷仙镇案  进入迷仙镇房屋的需要摆放家具
function TanAnMgr:doWhenEnterMxzRoom()
    if CHS[7190282] ~= MapMgr:getCurrentMapName() then
        -- 需要进入迷仙镇的房屋才需要摆放家具
        local cfg = MXZA_ROOM_FURNITURE_CFG[MapMgr:getCurrentMapId()]
        if not cfg then return end
        HomeMgr:putFurniturnsOnMapByCfg(cfg)
        GameMgr.scene.map:setLoadCountPerFrame(20)
    end
end

-- 通知信件界面提示信息(打开信件界面)
function TanAnMgr:MSG_TWZM_LETTER_DATA(data)
    local dlg = DlgMgr:openDlg("CaseTWMailDlg")
    dlg:setData(data)
end

-- 通知盒子上的文字信息(打开盒子界面)
function TanAnMgr:MSG_TWZM_BOX_DATA(data)
    local dlg = DlgMgr:openDlg("CaseTWBoxDlg")
    dlg:setData(data)
end

-- 通知开始摘桃子游戏
function TanAnMgr:MSG_TWZM_START_PICK_PEACH(data)
    if data.flag == 0 then
        -- 0表示打开界面，1表示正式开始
        DlgMgr:openDlg("CaseRunGameDlg")
    end
end

-- 通知拼图信息(打开拼图界面)
function TanAnMgr:MSG_TWZM_JIGSAW_DATA(data)
    DlgMgr:openDlgEx("CaseTWPiecingDlg", data)
end

-- 通知矩阵数字(打开矩阵界面)
function TanAnMgr:MSG_TWZM_MATRIX_DATA(data)
    DlgMgr:openDlgEx("CaseTWArrayDlg", data)
end

-- 通知WIFI密码信息(打开WIFI密码界面)
function TanAnMgr:MSG_TWZM_SCRIP_DATA(data)
    DlgMgr:openDlgEx("CaseTWPaperDlg", data.content)
end

-- 保存传音数据
function TanAnMgr:addTWVoiceData(data)
    if not self.twVoiceDatas then self.twVoiceDatas = {} end
    if #self.twVoiceDatas >= 50 then
        table.remove(self.twVoiceDatas, 1)
    end

    table.insert(self.twVoiceDatas, data)
end

-- 获取所有的传音数据
function TanAnMgr:getAllTWVoiceData()
    return self.twVoiceDatas
end

-- 通知传音信息(打开传音符界面)
function TanAnMgr:MSG_TWZM_CHUANYINFU(data)
    DlgMgr:openDlgEx("CaseTWSpellDlg", data)
end

function TanAnMgr:clearData(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        self.twVoiceDatas = nil
    end
end

MessageMgr:regist("MSG_MXZA_SUBMIT_EXHIBIT_DLG", TanAnMgr)
MessageMgr:regist("MSG_MXZA_EXHIBIT_ITEM_LIST", TanAnMgr)
MessageMgr:regist("MSG_RKSZ_PAPER_MESSAGE", TanAnMgr)
MessageMgr:regist("MSG_DETECTIVE_TASK_CLUE", TanAnMgr)
MessageMgr:regist("MSG_DETECTIVE_TASK_CLUE_PARALLEL", TanAnMgr)
MessageMgr:regist("MSG_DETECTIVE_RANKING_INFO", TanAnMgr)
MessageMgr:regist("MSG_TANAN_JHLL_GAME_XY", TanAnMgr)
MessageMgr:regist("MSG_TANAN_JHLL_GAME_GZ", TanAnMgr)
MessageMgr:regist("MSG_TANAN_JHLL_GUA_YAO", TanAnMgr)
MessageMgr:hook("MSG_ENTER_ROOM", TanAnMgr, "TanAnMgr")
MessageMgr:hook("MSG_TASK_PROMPT", TanAnMgr, "TanAnMgr")
MessageMgr:hook("MSG_MENU_LIST", TanAnMgr, "TanAnMgr")
MessageMgr:hook("MSG_MENU_CLOSED", TanAnMgr, "TanAnMgr")
MessageMgr:regist("MSG_TWZM_LETTER_DATA", TanAnMgr)
MessageMgr:regist("MSG_TWZM_BOX_DATA", TanAnMgr)
MessageMgr:regist("MSG_TWZM_START_PICK_PEACH", TanAnMgr)
MessageMgr:regist("MSG_TWZM_JIGSAW_DATA", TanAnMgr)
MessageMgr:regist("MSG_TWZM_MATRIX_DATA", TanAnMgr)
MessageMgr:regist("MSG_TWZM_SCRIP_DATA", TanAnMgr)
MessageMgr:regist("MSG_TWZM_CHUANYINFU", TanAnMgr)