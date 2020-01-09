-- AutoWalkMgr.lua
-- created by cheny Jan/04/2015
-- 自动寻路管理器

local AUTO_WALK_MAGIC_KEY = "auto_walk" -- 自动寻路标记
local AUTO_WALK_END_MAGIC_KEY = "auto_walk_end" -- 自动寻路结束标记
local AUTO_WALK_ACTION_TALK = "$0" -- 自动对话
local AUTO_WALK_ACTION_RAND = "$1" -- 随机走动
local AUTO_WALK_ACTION_STOP = "$2" -- 停下
local AUTO_WALK_ACTION_SPECIAL = "$3" -- 一些需要对话，但是又不是npc的特殊的，通过回调实现
local RANDOM_WALK_MAGIC_KEY = "random_walk" -- 巡逻寻路标记

local AUTO_WALK_ACTION_TALK_SCOPE_MIN = 2   -- 自动对话的最小范围
local AUTO_WALK_ACTION_TALK_SCOPE_MAX = 6   -- 自动对话的最大范围
local AUTO_WALK_ACTION_TALK_FOR_SPECIAL = 3 -- 特殊类寻路到达距离

AutoWalkMgr = {} -- 添加本行的目的是为了让 IDE 的 Outline 窗口能够罗列出该管理器的变量和函数
AutoWalkMgr = Singleton("AutoWalkMgr")

-- 此标记主要用于是否显示玩家头上的光效
local unFlyAutoWalkEnd = true

-- 标记是否是不可飞寻路
local unFlyAutoWalkSwitch = false

-- 存放断线重连前的寻路信息
local mStoreAutoWalk = nil

-- 存放断线重连前的巡逻信息
local mStoreRandomWalk = nil

-- 存放断线重连前的降妖/附魔任务的状态
-- 处理顺序有要求，前面的会优先处理
local STORE_TASK_LIST = {CHS[4000291], CHS[4000290], CHS[5120005]}
local mStoreTask = {}

AutoWalkMgr.realX = nil
AutoWalkMgr.realY = nil
AutoWalkMgr.realNpc = nil
AutoWalkMgr.realAction = nil
AutoWalkMgr.talkStr = nil
AutoWalkMgr.realMap = nil
AutoWalkMgr.openDlgStr = nil  -- 到达目的地后打开界面
AutoWalkMgr.destCallback = nil    -- 到达目的地后处理回调函数
AutoWalkMgr.curTaskWalkPath = nil
AutoWalkMgr.tipText = nil
AutoWalkMgr.tipCmd = nil
AutoWalkMgr.canAutoWalkCheckTimes = 0 -- 达到 3 时触发继续自动寻路

-- 不可飞自动寻路的地图
local UnFlyAutoWalkMapName = require(ResMgr:getCfgPath('UnFlyAutoWalkMapName.lua'))

local UNFLY_MAP =
{
    [CHS[5400030]] = true, -- 楼兰城
}

AutoWalkMgr.scheduleId = gf:Schedule(function()
    -- 尝试触发自动寻路
    AutoWalkMgr:tryToContinueAutoWalk()
end, 1)

function AutoWalkMgr:stop()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

-- 检查是否可自动寻路，不可自动寻路时返回提示
function AutoWalkMgr:checkCanAutoWalk()
    local tip
    -- GM处于监听状态下
    if GMMgr:isStaticMode() then
        return false, CHS[3003912]
    end

    if Me:isInJail() then
        -- 处于禁闭状态
        return false, CHS[6000214]
    end

    if Me:isInPrison() then
        -- 处于坐牢状态
        return false, CHS[7000072]
    end

    if Me:isInCombat() then
        return false, CHS[3003913]
    end

    if Me:isLookOn() then
        return false, CHS[3003914]
    end

    if MarryMgr:isWeddingStatus() then
        -- 举行婚礼
        return false, CHS[6200037]
    end

    if ActivityMgr:isChantingStauts() then
        return false, CHS[2000367]
    end

    if Me.isInLieRenXianJing then
        local time = gf:getServerTime()
        if not self.lastTipsTime or time - self.lastTipsTime >= 3 then
            self.lastTipsTime = time
            return false, CHS[5400051]
        end

        return false
    end

    if DlgMgr:isDlgOpened("HomeFishingDlg") then
        return false, CHS[6000214]
    end

    if GuideMgr:isRunning() then
        -- 如果处于指引过程中，不能响应相应操作
        return false
    end

    return true
end

-- 尝试触发自动寻路
-- 3 次检测到站立并且有寻路信息，则继续自动寻路
function AutoWalkMgr:tryToContinueAutoWalk(nowBegin)
    if not GameMgr:isEnterGameOK() or
       not AutoWalkMgr:checkCanAutoWalk() or
       not Me:isControlMove() or
       not Me:isStandAction() or
       self:isAutoWalkArrived() then
        self.canAutoWalkCheckTimes = 0
        return
    end

    if self:isAutoWalk() or Me:isRandomWalk() then
        self.canAutoWalkCheckTimes = self.canAutoWalkCheckTimes + 1
    end

    if (self.canAutoWalkCheckTimes >= 3 or nowBegin) and MapMgr.isLoadEnd then
        -- 尝试触发自动寻路
        if self:isAutoWalk() then
            self:continueAutoWalk()
        end

        --尝试触发巡逻
        if Me:isRandomWalk() then
            if self.lastRandomWalkMapName then
                -- 处理断线重连的情况
                if MapMgr:getCurrentMapName() == self.lastRandomWalkMapName then
                self:randomWalk()
            else
                AutoWalkMgr:endRandomWalk()
                self.lastRandomWalkMapName = nil
            end
            else
                self:randomWalk()
        end
        end

        self.canAutoWalkCheckTimes = 0
    end
end

-- 是否要无视过图点
function AutoWalkMgr:isIgnoreExit()
    if Me:isRandomWalk() then
        -- 巡逻
        return true
    end

    if Me:isInCombat() then
        -- 战斗中
        return true
    end

    if not AutoWalkMgr:getUnFlyAutoWalkStatus() and self.autoWalk then
        -- 可飞寻路
        return true
    end

    if DlgMgr:getDlgByName("DramaDlg") then
        -- 有剧本播放
        return true
    end

    if DlgMgr:isDlgOpened("LingyzmDlg") then
        -- 灵音镇魔界面
        return true
    end

    return false
end

-- 恢复自动寻路
function AutoWalkMgr:resumeRandomWalk(data)
    Me:setIsInRandomWalk(data.tag)
    self.randBindTask = data.randBindTask
    self.randCenter = data.center
    self.randDestination = data.randDestination
    self.lastRandomWalkMapName = data.curMapName
end

-- 获取当前寻路的状态
function AutoWalkMgr:getUnFlyAutoWalkStatus()
    return unFlyAutoWalkSwitch
end

-- 设置当前寻路的状态
function AutoWalkMgr:setUnFlyAutoWalkStatus(enable)
    unFlyAutoWalkSwitch = enable
end

-- 更新跨地图寻路状态,不用飞
function AutoWalkMgr:updateUnFlyAutoWalk(dest)
    if not self:checkGotoUnflyAutoWalk(dest) then
        unFlyAutoWalkSwitch = true
    else
        unFlyAutoWalkSwitch = false
    end
end

function AutoWalkMgr:isUnFlyAutoWalk()
    -- 押送镖银
    if TaskMgr:isExistTaskByName(CHS[3003911]) then
        return true
    end

    -- 副本地图
    if MapMgr:isDungeonMap(MapMgr:getCurrentMapId()) then
        return true
    end
    return false
end

-- 清除寻路相关数据
function AutoWalkMgr:cleanup(keepAutoWalk)
    -- 停止走动和寻路
    self:endAutoWalk()
    self:endRandomWalk()
    self:endUnFlyAutoWalk(true)

    -- 还有玩家的路径会自动寻路
    Me:resetGotoEndPos()
end

function AutoWalkMgr:setNextDest(dest, notfirstUnFlyAutoWalk)
    if Me:isInCombat() or Me:isLookOn() or not MapMgr.isLoadEnd then
        -- 在战斗或观战中，先保存目的地，待退出战斗后恢复寻路
        self.autoWalk = dest

        if nil == notfirstUnFlyAutoWalk then
        self.nextFirstUnFlyAutoWalk = true  -- 设置为第一次
    else
            self.nextFirstUnFlyAutoWalk = not notfirstUnFlyAutoWalk
    end

        DebugMgr:debugLog("AutoWalkMgr:setNextDest:" .. tostringex(dest), dest)
    else
        self:beginAutoWalk(dest, notfirstUnFlyAutoWalk)
        Me:setIsEnterScene(false)
    end
end

-- 自动寻路到某个npc或地图坐标
-- notfirstUnFlyAutoWalk : 由于不可飞寻路存在多次重新定位目标，此标记主要用于标记是否是不可飞后续重定位处理
-- 注：自动寻路家具的目的地坐标不是放置家具的位置而是家具脚底基准点对应地图的位置
function AutoWalkMgr:beginAutoWalk(dest, notfirstUnFlyAutoWalk)
    if GameMgr:isInPartyWar() and DlgMgr:getDlgByName("UseBarDlg") then
        -- 如果帮战中，并且采集中，则直接返回
        return
    end

    -- 部分巡逻功能不需要巡逻效果
    Me.notXunluoMagic = dest and dest.notXunluoMagic

    DebugMgr:log("beginAutoWalk", notfirstUnFlyAutoWalk, nil, nil, dest)

    if not MapMgr.isLoadEnd then
        self:setNextDest(dest, notfirstUnFlyAutoWalk)

        --[[
        if ATM_IS_DEBUG_VER then
            assert(MapMgr.isLoadEnd, "Can't beginAutoWalk when map loading.")
        end
        ]]

        return
    end

    DebugMgr:debugLog("AutoWalkMgr:beginAutoWalk:" .. tostringex(dest), dest)

    -- 分发任务刷新事件
    EventDispatcher:dispatchEvent(EVENT.AUTO_WALK, { autoWalkData = dest })

    -- 通知计步工具停止
    DlgMgr:sendMsg("PedometerDlg", "onDelButton")

    if self.nextFirstUnFlyAutoWalk then     -- 清除标识
        self.nextFirstUnFlyAutoWalk = nil
    end

    if not dest then
        return
    end

    if dest.orgStr then
        if string.match( dest.orgStr, CHS[4101302]) then                  -- |双数线
            local retStr = string.gsub( dest.orgStr, CHS[4101303], "%%s")      -- "双数线"
            gf:CmdToServer("CMD_REQUEST_AUTO_WALK_LINE", {line_type = 2, auto_walk_info = retStr})
            return
        elseif string.match( dest.orgStr, CHS[4101304]) then
            local retStr = string.gsub( dest.orgStr, CHS[4101305], "%%s")
            gf:CmdToServer("CMD_REQUEST_AUTO_WALK_LINE", {line_type = 1, auto_walk_info = retStr})
            return
        end
    end

    local isCan, tip = AutoWalkMgr:checkCanAutoWalk()
    if not isCan then
    if tip then
            gf:ShowSmallTips(tip)
    end

        return
        end

    -- 需要换线先换线
    local lineList = Client:getLineList()
    if dest["area"] then
        local severName = DistMgr:getServerNameByServerId(tonumber(dest["area"]))
        if severName and severName ~= GameMgr:getServerName() then
            gf:CmdToServer("CMD_CACHE_AUTO_WALK_MSG", {autoWalkStr = dest.orgStr, homeId = "", taskType = dest.curTaskWalkPath and dest.curTaskWalkPath.task_type, mapName = dest.map, serverName = severName})
            dest["area"] = nil
            return
        end
    end

    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    -- 特殊处理一下居所寻路（寻路到当前正处于的居所的某个NPC/另外一个居所的NPC，目前NPC特指“管家”）
    if dest.homeInfo and dest.map and MapMgr:isInHouse(dest.map) then
        local homeId = dest.homeInfo
        if homeId == "me" then
            homeId = Me:queryBasic("house/id")
        end

        local npc = dest.npc
        local mapName = MapMgr:getCurrentMapName()
        if MapMgr:isInHouse(mapName) and homeId == HomeMgr:getHouseId() then
            -- 如果自己在居所里面，且自己所处的居所是要到达的居所，则不可飞寻路到NPC
            -- 重新确认寻路地图信息
            local homeTypeCHS = string.match(mapName, "(.+)-.+")
            if npc then
                dest.map = HomeMgr:getMapNameByNpcAndHomeType(npc, homeTypeCHS)

                -- 选择对应居所类型的管家名称
                dest.npc = HomeMgr:getRealNpcNameByNpcAndHomeType(npc, homeTypeCHS)
            else
                -- 进入居所前无法具体判断居所类型，此处需重新取值 dest.map
                local homePlace = string.match(dest.map, ".+-(.+)")
                dest.map = homeTypeCHS .. "-" .. homePlace
                if mapName == dest.map and dest.openDlgStr then
                    -- 未进居所前不知道是什么类型的居所，无法固定配置传入地图的坐标
                    -- 按原本逻辑无法实现到达某目的地打开界面
                    -- 此处进行特判，获取 HomeMgr 中配置的坐标
                    local dlgName = string.match(dest.openDlgStr, "(.+)=.+") or dest.openDlgStr
                    local x, y = HomeMgr:getHomeWalkToXYByDlg(homeTypeCHS, homePlace, dlgName)
                    if x and y then
                        dest.x, dest.y = x, y
                        self.realX, self.realY = x, y
                    end
                end
            end
        else
            -- 自己不在想要去的居所里面，请求服务器把自己送到想要去的居所里面
            if homeId == "" then
                gf:ShowSmallTips(CHS[4300265])
            else
                -- dest.orgStr 正常情况下都会有的
                local homePlace = string.match(dest.map, ".+-(.+)")
                if dest.orgStr then
                    gf:CmdToServer("CMD_CACHE_AUTO_WALK_MSG", {autoWalkStr = dest.orgStr, homeId = homeId, taskType = dest.curTaskWalkPath and dest.curTaskWalkPath.task_type, mapName = dest.map})
                end
            end
            return
        end
    else
        -- 如果我在居所专线，寻路至其他非居所专线的，需要通知服务器，跨线寻路  orgStr为未解析的寻路信息
        if DistMgr:isHomeServer() and not MapMgr:isInHouse(dest.map) and dest.orgStr then
            -- 在队伍中但不是队长
            if TeamMgr:inTeam(Me:getId()) and not Me:isTeamLeader() then
                gf:ShowSmallTips(CHS[5000078])
                return
            end

            gf:CmdToServer("CMD_CACHE_AUTO_WALK_MSG", {autoWalkStr = dest.orgStr, mapName = dest.map, taskType = dest.curTaskWalkPath and dest.curTaskWalkPath.task_type})
            return
        end
    end

    -- 根据当前的位置更新当前是否是不可飞寻路
    self:updateUnFlyAutoWalk(dest)

    if not notfirstUnFlyAutoWalk and self:getUnFlyAutoWalkStatus() then
        -- 如果是不可飞的第一次进入，则直接直接进行
        -- 所以此处存下来的数据是真正的目标
        -- notfirstUnFlyAutoWalk = true

        self.realMap    = dest.map
        self.realNpc    = dest.npc
        self.realAction = dest.action
        self.talkStr    = dest.talkStr
        self.tipText    = dest.tipText
        self.tipCmd    = dest.tipCmd
        self.openDlgStr = dest.openDlgStr
        self.homeInfo   = dest.homeInfo
        self.destCallback   = dest.destCallback
        self.curTaskWalkPath = dest.curTaskWalkPath
        self.furniturePara = dest.furniturePara
        self.endCallBackFuncForSwitchLine = dest.endCallBackFuncForSwitchLine

        if dest.x and dest.y then
            self.realX = dest.x
            self.realY = dest.y
        else
            self.realX = nil
            self.realY = nil
        end
    end

    self.firstUnFlyAutoWalk = not notfirstUnFlyAutoWalk

    local me = Me
    -- 判断是否可以移动
    if not me:getCanMove() then
        return
    end

    -- 是否是队伍成员
    if TeamMgr:isTeamMeber(Me) then
        if not Me.isFightJustNow then
            gf:ShowSmallTips(CHS[6000210])
        end

        return
    end

    self.hasNext = nil

    Me.walkDest = dest -- 仅用于异常恢复

    repeat
        if self:getUnFlyAutoWalkStatus() then
            -- 如果是不可飞自动寻路
            if not notfirstUnFlyAutoWalk  then
                -- 不能直接等于，否则随后面dest值变化，self.unflyAutoWalkDest也会变化。具体出线问题例八仙跨地图寻路
                -- 如果是第一次不可飞进入此逻辑，才需要赋值
                -- 存储的是最原始的目标寻路目标
                self.unflyAutoWalkDest          = {}
                self.unflyAutoWalkDest.action   = dest.action
                self.unflyAutoWalkDest.map      = dest.map
                self.unflyAutoWalkDest.npc      = dest.npc
                self.unflyAutoWalkDest.x        = dest.x
                self.unflyAutoWalkDest.y        = dest.y
                self.unflyAutoWalkDest.effectIndex = dest.effectIndex
                self.unflyAutoWalkDest.msgIndex = dest.msgIndex
                self.unflyAutoWalkDest.homeInfo = dest.homeInfo
                self.unflyAutoWalkDest.openDlgStr = dest.openDlgStr
                self.unflyAutoWalkDest.destCallback = dest.destCallback
                self.unflyAutoWalkDest.curTaskWalkPath = dest.curTaskWalkPath
                self.unflyAutoWalkDest.furniturePara = dest.furniturePara
                self.unflyAutoWalkDest.endCallBackFuncForSwitchLine = dest.endCallBackFuncForSwitchLine


            end

            -- 此标记主要用于是否显示玩家头上的光效
            unFlyAutoWalkEnd = false

            if not self.unflyAutoWalkDest then
                return
            end

            -- 赋值为目标位置
            dest.map = self.realMap
            dest.npc = self.realNpc
            dest.action = self.realAction
            dest.talkStr = self.talkStr
            dest.tipText = self.tipText
            dest.tipCmd = self.tipCmd
            dest.openDlgStr = self.openDlgStr
            dest.destCallback = self.destCallback
            dest.curTaskWalkPath = self.curTaskWalkPath
            dest.furniturePara = self.furniturePara
            dest.endCallBackFuncForSwitchLine = self.endCallBackFuncForSwitchLine

            dest.x = self.realX
            dest.y = self.realY
            dest.rawX = nil
            dest.rawY = nil
            dest.homeInfo = self.homeInfo
            -- 判断是否已经到达目标地图，并判断当前坐标是否是我们的目的地
            if self.realMap == MapMgr:getCurrentMapName() then
                local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
                if mapX == dest.x and mapY == dest.y then
                    -- 如果已经到了目标地图和坐标，直接停止
                    dest.rawX, dest.rawY = dest.x, dest.y
                    self:endUnFlyAutoWalk()
                    break
                end
            end

            -- 如果在这边的话，有两种情况
            -- 1. 不可飞到了目标地图，但是还没有到最终的位置
            -- 2. 不可飞还没到目标地图
            -- 获取自动寻路上的本次目标
            local newPos, npc, msgIndex, action, homeInfo = self:getUnFlyAutoWalkPos(dest)

            -- 检测是否可以继续不可飞
            -- 如果不行则停止，否则继续
            local isStopUnfly = self:checkGotoUnflyAutoWalk(dest)
            if isStopUnfly then
                self:setUnFlyAutoWalkStatus(false)
                self:endUnFlyAutoWalk()
                self:beginAutoWalk(dest)
                return
            else
                if TaskMgr:isExistTaskByName(CHS[3003911]) and DugeonMgr:isInDugeon(MapMgr:getCurrentMapName()) then
                    if not DugeonMgr:isInDugeon(dest.map) then
                        self:endUnFlyAutoWalk()
                        gf:ShowSmallTips(CHS[3003915])
                        return
                    end
                end

                if TaskMgr:isExistTaskByName(CHS[2200039]) then
                    -- 萝卜桃子大收集任务全程限飞，此时无法到达帮派总坛（帮派任务、帮派日常挑战、强帮之道）
                    if dest.map == CHS[3000965] then
                        self:endUnFlyAutoWalk()
                        gf:ShowSmallTips(CHS[5400054])
                        return
                    end
                end

                -- 【七夕节】千里相会 “与好友相会”状态下不可飞
                local task = TaskMgr:getTaskByName(CHS[5400073])
                if task and string.match(task.task_prompt, CHS[5400076]) then
                    if dest.map == CHS[3000965] then
                        self:endUnFlyAutoWalk()
                        gf:ShowSmallTips(CHS[5400078])
                        return
                    end
                end
            end

            if newPos or npc then
                if newPos then
                    dest.x = newPos[1]
                    dest.y = newPos[2]
                end

                    dest.msgIndex = msgIndex
                    dest.action = action
                    dest.npc = npc
                    dest.homeInfo = homeInfo
                if not npc then
                    -- 没有NPC
                    if not dest.x or not dest.y then
                        -- 也没有具体位置
                        self:stopAndDoSomeAction(dest)
                        return
                    else
                        -- 有具体位置
                    break
                end
                end
            else
                -- 没有找到位置和 NPC，那么停止
                me:addMagicOnHead(ResMgr.magic.auto_walk_end, false, nil, 1)
                self:endUnFlyAutoWalk()
                return
            end
        else
            -- 可以飞行自动寻路
            if dest.map ~= nil and dest.map ~= MapMgr:getCurrentMapName() then
                -- 尝试发送飞行指令
                self:endUnFlyAutoWalk()
                if MapMgr:flyTo(dest.map, nil, dest) then
                    -- 发送飞行消息成功，保存寻路信息
                    self.autoWalk = dest
                end

                return
            else
                self:endUnFlyAutoWalk(true)
            end
        end

        -- 如果到了这边只有一种情况了
        -- 就是目标地图和当前地图是一致的
        -- 此时需要处理的就是挪到NPC旁边或者目标位置就可以了
        if dest.x ~= nil and dest.y ~= nil and dest.npc == nil then
            -- 寻路到坐标
            break
        end

        if dest.npc ~= nil then
            -- 寻路到NPC
            local npc = nil
            if  dest.x ~= nil and dest.y ~= nil and dest.npc ~= nil then
                npc = {}
                    npc.x = dest.rawX or dest.x
                    npc.y = dest.rawY or dest.y
                npc.name = dest.npc
            else
                npc = MapMgr:getNpcByName(dest.npc)
            end

            if npc == nil and (not HomeMgr:isFurniture(dest.npc)) then
                gf:ShowSmallTips(string.format(CHS[6000137], dest.npc))
            end

            if npc ~= nil then
                -- 存在NPC信息
                local mapX, mapY = gf:convertToMapSpace(me.curX, me.curY)
                local dist = gf:distance(mapX, mapY, npc.x, npc.y)

                -- 玩家与NPC之前的距离小于等于6个单位，则不再寻路
                if math.floor(dist) <= AUTO_WALK_ACTION_TALK_SCOPE_MAX then
                    -- 处理寻路完成后事件
                    me:setEndPos(mapX, mapY, true)
                    self.autoWalk = dest
                    self.autoWalk.is_walking = true
                    dest.rawX, dest.rawY = npc.x, npc.y
                    self:doAutoWalkEnd(true)

                    -- 过图后直接在目标npc附近，设置自动寻路结束；self:doAutoWalkEnd(true)中self.realX和y未赋值
                    if MapMgr:getCurrentMapName() == self.realMap and self:getUnFlyAutoWalkStatus() then
                        AutoWalkMgr:endUnFlyAutoWalk(true)
                    end

                    self:tryToEndAutoWalk()
                    return
                end

                -- 寻路到npc
                dest.x, dest.y = npc.x, npc.y
                if AUTO_WALK_ACTION_TALK == dest.action then
                    -- 如果是跟npc自动对话则选择距离NPC 2-5 格内进行对话

                    local npcList = CharMgr:getNpcList()
                    local char = nil

                    for k, v in pairs(npcList) do
                       if v.lastMapPosX == dest.x and v.lastMapPosY == dest.y and CharMgr:isEqualName(v:getName(), npc.name) then
                            char = v
                       end
                    end

                    if char == nil and HomeMgr:isFurniture(dest.npc) then
                        -- 家具
                        char = HomeMgr:getFurnByNameAndBasicPos(npc.name, {x = npc.x, y = npc.y})
                    end

                    local ranX, ranY
                    if char == nil then  -- 不在视野内(先用5方向，等出现在屏幕内再开始找真正方向位置)
                        ranX, ranY = self:getNpcTalkPos(5, npc)
                    else
                        ranX, ranY = self:getNpcTalkPos(char:getDir(), npc)
                    end

                    local x = npc.x + ranX
                    local y = npc.y + ranY
                    x,y = MapMgr:adjustPosition(x, y)
                    local pos = GObstacle:Instance():GetNearestPos(x, y)
                    dest.x, dest.y = math.floor(pos / 1000), pos % 1000
                    dest.rawX, dest.rawY = npc.x, npc.y
                end

                break
            end
        end

        -- 没有找到位置也清除自动寻路信息（比如过图#Z天墉城#Z）
        self:stopAndDoSomeAction(dest)
        return
    until true

    Log:D("Auto walk to :")
    gf:PrintMap(dest)
    -- 检查要不要开启驱魔香提示
    if dest.needExorcismTips and dest.map == MapMgr:getCurrentMapName() then
    PracticeMgr:showUseExorcism()
        dest.needExorcismTips = nil
    end

    -- 设置寻路终点
    me:setEndPos(dest.x, dest.y)

    -- 开始自动寻路，删除寻路到达标记，添加自动寻路标记
    me:deleteMagic(AUTO_WALK_END_MAGIC_KEY)
    if not Me.notXunluoMagic then
        me:addMagicOnHead(ResMgr.magic.auto_walk, false, AUTO_WALK_MAGIC_KEY, 1)
    end

    -- 保存自动寻路信息，设置正在自动寻路
    self.autoWalk = dest
    self.autoWalk.is_walking = true

    local mapX, mapY = gf:convertToMapSpace(me.curX, me.curY)
    if mapX == dest.x and mapY == dest.y then
        -- 如果当前位置为寻路位置
        if dest["action"] == AUTO_WALK_ACTION_RAND then -- 随机走动
            self.randCenter = cc.p(mapX, mapY)
            self.randDestination = cc.p(mapX, mapY)
            self.randBindTask = dest.curTaskWalkPath
            self:randomWalk()
            return
        end

        -- 如果寻路的点与当前位置一致则随机一步再回来，让服务器继续出发剧情
        Me:randomSomePosAndBack()

        -- 处理寻路完成后事件
        self:doAutoWalkEnd(true)

        self:endAutoWalk()

        return
    elseif not Me.paths then
        -- 寻路目标不可到达

        -- 家具特殊寻路，需要与家具对话，有可能寻路到附加，坐标差1，再点寻路会寻不到
        if AutoWalkMgr:isAutoWalkArrived() then
            self:doAutoWalkEnd(true)
            self:endAutoWalk()
        end

        -- 如果由于点击主界面钓鱼，寻路钓鱼时，但是家具把路堵住了。需要给予提示       详见WDSY-25727 居所钓鱼寻路优化
        if MapMgr.mapData and string.match(MapMgr.mapData.map_name, CHS[4300296]) and AutoWalkMgr.autoWalk and AutoWalkMgr.autoWalk.orgStr == CHS[4300297] then
            gf:ShowSmallTips(CHS[4300298])
        end

        self:endAutoWalk()
    end
end

function AutoWalkMgr:stopAndDoSomeAction(dest)
    self.autoWalk = dest
    local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
    self.autoWalk.x = mapX
    self.autoWalk.y = mapY
    self:doAutoWalkEnd(true)
    self:tryToEndAutoWalk()
end

-- 获取 npcx相应朝向的90°范围的2-6格位置
function AutoWalkMgr:getNpcTalkPos(dir, npc)
    local randomX, randomY
    local findFlag = false
    local newDir
    newDir = dir or 0
    for i = 0, 7 do
    for i = 1, 10 do
        -- 随便选择一个距离
        randomX = math.random(0, AUTO_WALK_ACTION_TALK_SCOPE_MAX)
        local radomMaxY = math.sqrt( AUTO_WALK_ACTION_TALK_SCOPE_MAX * AUTO_WALK_ACTION_TALK_SCOPE_MAX - randomX * randomX )
        local radomMinY

        if AUTO_WALK_ACTION_TALK_SCOPE_MIN * AUTO_WALK_ACTION_TALK_SCOPE_MIN - randomX * randomX  < 0 then
            radomMinY = 0
        else
            radomMinY = math.sqrt( AUTO_WALK_ACTION_TALK_SCOPE_MIN * AUTO_WALK_ACTION_TALK_SCOPE_MIN - randomX * randomX )
        end

        if radomMinY > radomMaxY then
            radomMinY = radomMaxY
        end

        randomY = math.random(math.floor(radomMinY), math.floor(radomMaxY) )

            if newDir == 7 then -- 西南
            randomX = -randomX
            randomY = randomY
            elseif newDir == 5 then
            randomX = randomX
            randomY = randomY
            elseif newDir == 3 then
                randomX = randomX
                randomY = -randomY
            elseif newDir == 1 then
                randomX = -randomX
                randomY = -randomY
        end

            Log:D(">>>> dir : " .. tostring(newDir) .. " x : " .. tostring(npc.x + randomX) .. ", y : " .. tostring(npc.y + randomY))

            if not GObstacle:Instance():IsObstacle(npc.x + randomX, npc.y + randomY)
                and not AutoWalkMgr:isInExitRange(npc.x + randomX, npc.y + randomY) then
                -- 如果当前点不是障碍点
                -- 并且不是过图点范围
                findFlag = true
            break
        end
        end

        if findFlag then
            -- 如果已经找到了，就不需要再找了
            Log:D("已经找到了，>>>> x : " .. tostring(npc.x + randomX) .. ", y : " .. tostring(npc.y + randomY))
            break
        end

        -- 换个方向查找
        newDir = (newDir + 1) % 8
    end

    if not findFlag then
        -- 如果没有找到点
        randomX, randomY = AutoWalkMgr:getNpcRandPos(npc)
    end

    return randomX, randomY
end

-- 在npc周围随便找个格子吧
function AutoWalkMgr:getNpcRandPos(npc)
    local randomX, randomY
    for i = 1, 10 do
        randomX = math.random(-AUTO_WALK_ACTION_TALK_SCOPE_MAX, AUTO_WALK_ACTION_TALK_SCOPE_MAX)
        randomY = math.random(-AUTO_WALK_ACTION_TALK_SCOPE_MAX, AUTO_WALK_ACTION_TALK_SCOPE_MAX)

        if not AutoWalkMgr:isInExitRange(npc.x + randomX, npc.y + randomY) then
            break
        end

        if 10 == i then
            randomX = 0
            randomY = 0
        end
    end

    return randomX, randomY
end

-- 是否在过图点之内
function AutoWalkMgr:isInExitRange(posX, posY)
    local exits = MapMgr:getExitData()
    local count = exits.count

    local flag = false
    for i = 1, #exits do
        if 1 == exits[i].add_exit then
            local dis = gf:distance(posX, posY, exits[i].x, exits[i].y)

            if dis <= 4 then
                flag = true
            end
        end
    end

    return flag
end

-- 保存当前自动寻路
function AutoWalkMgr:storeAutoWalk()
    mStoreAutoWalk = {
        autoWalk = self.autoWalk,
        nextFirstUnFlyAutoWalk = self.nextFirstUnFlyAutoWalk,
    }

    -- 保存当前巡逻信息
    mStoreRandomWalk = {
        tag = Me:isRandomWalk(),
        curMapName = MapMgr:getCurrentMapName(),
        randBindTask = self.randBindTask,
        center = self.randCenter,
        randDestination = self.randDestination,
    }
end

-- 保存一些任务的状态信息，以便断线重连时使用
-- 需要处理的任务保存在 STORE_TASK_LIST 中，如降妖、伏魔，这些任务在战斗结束后会发生变化
-- 由于断线可能发生在任务状态变更之前，也有可能发生在变更之后服务器未发自动寻路信息之前
-- 故该信息需要在战斗开始时保存，触发人物走路时清除
function AutoWalkMgr:storeSomeTask()
    -- 保存相应的任务信息
    for i = 1, #STORE_TASK_LIST do
        local info = TaskMgr:getTaskByName(STORE_TASK_LIST[i]) or {}
        mStoreTask[STORE_TASK_LIST[i]] = info.task_prompt
    end
end

function AutoWalkMgr:onEnterCombat()
    self:storeSomeTask()
end

-- 清理保存的任务信息
function AutoWalkMgr:clearStoredTask()
    mStoreTask = {}
end

-- 恢复自动寻路
function AutoWalkMgr:restoreAutoWalk(resume)
    -- 恢复巡逻信息
    if resume and mStoreRandomWalk then
        Me:setIsInRandomWalk(mStoreRandomWalk.tag)
        self.randBindTask = mStoreRandomWalk.randBindTask
        self.randCenter = mStoreRandomWalk.center
        self.randDestination = mStoreRandomWalk.randDestination
        self.lastRandomWalkMapName = mStoreRandomWalk.curMapName
    end
    mStoreRandomWalk = nil

    if not mStoreAutoWalk or not mStoreAutoWalk.autoWalk and not mStoreAutoWalk.nextFirstUnFlyAutoWalk then
        -- 无自动寻路信息需要恢复
        if Me:isControlMove() and resume then
            -- 可以主动移动，判断之前保存的任务的状态是否发生变化，如果发生变化需要进行处理
            for i = 1, #STORE_TASK_LIST do
                local info = TaskMgr:getTaskByName(STORE_TASK_LIST[i]) or {}
                if info.task_prompt and mStoreTask[STORE_TASK_LIST[i]] and
                   mStoreTask[STORE_TASK_LIST[i]] ~= info.task_prompt then
                    AutoWalkMgr:beginAutoWalk(gf:findDest(info.task_prompt))
                    break
                end
            end
        end

        self:clearStoredTask()
        return
    end

    if resume then
        self.autoWalk = mStoreAutoWalk.autoWalk
        self.nextFirstUnFlyAutoWalk = mStoreAutoWalk.nextFirstUnFlyAutoWalk
        self:continueAutoWalk()
    end

    mStoreAutoWalk = nil
    self:clearStoredTask()
end

-- 结束自动寻路
function AutoWalkMgr:endAutoWalk()
    -- 删除自动寻路标记及寻路信息
    Me:deleteMagic(AUTO_WALK_MAGIC_KEY)
    -- Me:deleteMagic(RANDOM_WALK_MAGIC_KEY)

    if self.autoWalk then
        DebugMgr:debugLog("AutoWalkMgr:endAutoWalk:" .. tostringex(self.autoWalk) .. "\n" .. debug.traceback(), self.autoWalk)
        self.autoWalk = nil
    end

    if self.nextFirstUnFlyAutoWalk then
        self.nextFirstUnFlyAutoWalk = nil
    end
end

-- 尝试结束自动寻路
function AutoWalkMgr:tryToEndAutoWalk()
    if self.autoWalk then
        if AUTO_WALK_ACTION_TALK ~= self.autoWalk.action or self.autoWalk.talkToNpcStatus then
            self:endAutoWalk()
        end
    end
end

function AutoWalkMgr:getMessageautoClickKeys()
    return self.autoClickKeys
end

function AutoWalkMgr:removeMessageautoClickKeysByKey(key)
    if not self.autoClickKeys then return end
    for _, content in pairs(self.autoClickKeys) do
        if content == key then
            table.remove(self.autoClickKeys, _)
        end
    end

    if #self.autoClickKeys == 0 then self.autoClickKeys = nil end
end

-- 用来自动打开对话框 自动点击某条
function AutoWalkMgr:getMessageIndex()
    return self.msgIndex
end

-- 清除 点击某条的状态
function AutoWalkMgr:clearMessageIndex()
    self.msgIndex = nil
end

-- 清除 点击某条的状态
function AutoWalkMgr:clearMessageAutoClickKeys()
    self.autoClickKeys = nil
end

-- 用来给对话框加光效
function AutoWalkMgr:getEffectIndex()
    return self.effectIndex
end

-- 清除光效状态
function AutoWalkMgr:clearEffectIndex()
    self.effectIndex = nil
end


-- 自动寻路结束需要做的事情
function AutoWalkMgr:doAutoWalkEnd(noShow)
    -- 添加到达目的地光效
    local me = Me

    -- 如果已经在NPC对话范围了则不显示特效
    local isShow = true
    if noShow then
        isShow = false
    end

    if isShow and unFlyAutoWalkEnd then
        if not Me.notXunluoMagic then
            me:addMagicOnHead(ResMgr.magic.auto_walk_end, false, nil, 1)
        end
        me:deleteMagic(AUTO_WALK_MAGIC_KEY)
    end

    if self.autoWalk == nil then return end

    if self.autoWalk.hasNext then
        -- 存在下一段，将在过图结束之后进行处理
        self.hasNext = self.autoWalk.hasNext
    end

    if self.autoWalk.action == AUTO_WALK_ACTION_TALK then
        -- 与npc对话
        local npc = self.autoWalk.npc

        -- 用来自动打开对话框 自动点击某条
        if self.autoWalk["msgIndex"] or self.autoWalk["autoClickKeys"] then
            self:clearMessageIndex()
            self.msgIndex = self.autoWalk["msgIndex"]
            self.autoClickKeys = self.autoWalk["autoClickKeys"]
        end

        -- 给菜单加光效
        if self.autoWalk["effectIndex"] then
            self:clearEffectIndex()
            self.effectIndex = self.autoWalk["effectIndex"]
        end

        -- 当不飞行自动寻路开启时，我们直接获取npc.lastMapX和Y进行赋值
        -- 先用对应的坐标和名字（可能重名）取 npc，取不到再取只用名字取
        local newNpc = MapMgr:getCurMapNpcByPosAndName(self.autoWalk.npc, self.autoWalk.rawX, self.autoWalk.rawY)

        if not newNpc then
            newNpc = MapMgr:getCurMapNpcByName(self.autoWalk.npc)
        end

        if not newNpc then
            -- 怪物类对象只能通过 char 找
            newNpc = CharMgr:getNpcByName(self.autoWalk.npc)
            if newNpc then
                newNpc.x = newNpc.lastMapPosX
                newNpc.y = newNpc.lastMapPosY
            end
        end

        local npcId = nil

        if self.autoWalk.npcId then
            npcId = self.autoWalk.npcId
        end



        local retValue = false
        self:setNpcNoTalkEnd(false)
        if self:getUnFlyAutoWalkStatus() and newNpc then
            self.autoWalk.rawX, self.autoWalk.rawY = newNpc.x, newNpc.y
            retValue = CharMgr:talkToNpc(npc, self.autoWalk.rawX, self.autoWalk.rawY, npcId)
        else
            retValue = CharMgr:talkToNpc(npc, self.autoWalk.rawX, self.autoWalk.rawY, npcId)
        end

        if self.autoWalk and self.autoWalk.rawX and self.autoWalk.rawY then
            -- 设置角色朝向
            local x, y = gf:convertToClientSpace(self.autoWalk.rawX, self.autoWalk.rawY)
            local dir = gf:defineDir(cc.p(Me.curX, Me.curY), cc.p(x, y), Me:getIcon())

            Me:setDir(dir)
            Me:addMoveCmd(Me.lastMapPosX, Me.lastMapPosY)
        end

        if not retValue then
            retValue = CharMgr:talkToMonster(self.autoWalk.npc, npcId)
        end

        if not retValue then
            -- 可能是寻路到家具上了
            retValue = HomeMgr:talkToFurniture(self.autoWalk)
        end

        if not retValue then
            -- 如果都没有找到，那么就蛋疼了
            -- 打个标记，等NPC出现了再说
            self:setTalkToNpcIsEnd(false)
            self:setNpcNoTalkEnd(true)
            Log:D(">>>>> 没有找到 NPC " .. tostring(self.autoWalk.npc) .. " self:setTalkToNpcIsEnd(false)")
        end

        AutoWalkMgr:tryToEndAutoWalk()
    elseif self.autoWalk.action == AUTO_WALK_ACTION_RAND then
        -- 随机走动
        local x, y = self.autoWalk.x, self.autoWalk.y
        self.randCenter = cc.p(x, y)
        self.randDestination = cc.p(x, y)
        self.randBindTask = self.autoWalk.curTaskWalkPath
        self:randomWalk(1.2)
    elseif self.autoWalk.action == AUTO_WALK_ACTION_STOP  then
        -- 如果 有喊话则喊话
        if self.autoWalk["talkStr"] then
            ChatMgr:sendCurChannelMsg(self.autoWalk["talkStr"])
        end

        -- 有文字提示则直接发出文字提示
        if self.autoWalk and self.autoWalk["tipText"] then
            gf:ShowSmallTips(self.autoWalk["tipText"])
        end


        if self.autoWalk and self.autoWalk["tipCmd"] then
            gf:CmdToServer("CMD_TASK_TIP_EX", {taskName = self.autoWalk["tipCmd"]})
        end

        if self.autoWalk["openDlgStr"] then
            if string.match( self.autoWalk["openDlgStr"], "dashui1" ) then
                -- 由于通过对话框方式可以回去已配置好的打水位置，所以通过该方式特殊处理下
                gf:CmdToServer("CMD_CHILD_BIRTH_WATER", {state = 1})
            else
                DlgMgr:openDlgWithParam(self.autoWalk["openDlgStr"])
            end
        end

        local destCallback = self.autoWalk["destCallback"] or {}
        if next(destCallback) then
            -- 自动寻路回调函数，可处理到达某一地点后处理一系列逻辑
            local func = destCallback.func
            local para = destCallback.para
            func(para)
        end

        -- 根据是否寻路完成，更新不可飞寻路信息
        self:updateUnFlyAutoWalkInfo()

        -- 停止走动和寻路
        self:endAutoWalk()
        self:endRandomWalk()
        return
    elseif self.autoWalk.action == AUTO_WALK_ACTION_SPECIAL  then
        if self.autoWalk.furniturePara then
            local id = string.match( self.autoWalk.furniturePara, "id=(.+)MSG")
            id = tonumber(id)
            local furnitures = HomeMgr:getFurnitures()
            local autoWalk = self.autoWalk
            -- 延迟的目的是，有可能还没有走到目的地，发送消息后，会进入采集，导致服务器和客户端位置不一致
            performWithDelay(gf:getUILayer(), function ( )
                local furn = furnitures[id]
                if furn then
                    if string.match(autoWalk.furniturePara, "MSG_CHILD_INJECT_ENERGY") then
                        gf:CmdToServer("CMD_HOUSE_TDLS_INJECT_ENERGY", {pos = id})
                    elseif string.match(autoWalk.furniturePara, "MSG_CHILD_BIRTH_STONE") then
                        gf:CmdToServer("CMD_HOUSE_TDLS_CHILD_BIRTH", {furniture_id = id})
                    elseif string.match(autoWalk.furniturePara, "MSG_CHILD_POSITION") then
                        -- 根据是否寻路完成，更新不可飞寻路信息
                        self:updateUnFlyAutoWalkInfo()

                        -- 停止走动和寻路。因为后面要 furn:startAutoWalk() 所以提前停止
                        self:endAutoWalk()
                        self:endRandomWalk()
                        furn:startAutoWalk()
                        return
                    end
                end
            end, 0.7)
        elseif self.autoWalk.endCallBackFuncForSwitchLine then
            if string.match( self.autoWalk.endCallBackFuncForSwitchLine, "takeCareBaby") then
                local id = string.match( self.autoWalk.endCallBackFuncForSwitchLine, "takeCareBaby:(.+)")
                HomeChildMgr:endCallBackForTakeCareBaby(id)
            elseif string.match( self.autoWalk.endCallBackFuncForSwitchLine, "fuy") then
                local id = string.match( self.autoWalk.endCallBackFuncForSwitchLine, "fuy:(.+)")
                HomeChildMgr:endCallBackForfy(id)
            end
        end

        -- 根据是否寻路完成，更新不可飞寻路信息
        self:updateUnFlyAutoWalkInfo()

        -- 停止走动和寻路
        self:endAutoWalk()
        self:endRandomWalk()
        return
    end

    self:updateUnFlyAutoWalkInfo()
end

-- 更新不可飞寻路信息
function AutoWalkMgr:updateUnFlyAutoWalkInfo()
    if self:getUnFlyAutoWalkStatus() then
        -- 因为不可飞寻路中，此时需要进行判断是否是已经寻路完成了
        -- 存在两种情况
        -- 1. 坐标寻路，那么只要到对应的点就行了
        -- 2. NPC寻路，需要到对应的NPC范围即可
        local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
        if mapX == self.realX and mapY == self.realY then
            -- 坐标寻路，那么只要到对应的点就行了
            if self.unflyAutoWalkDest and self.unflyAutoWalkDest.map == MapMgr:getCurrentMapName() then
                self:endUnFlyAutoWalk(true)
            end
        end

        if self:isAutoWalkArrived() then
            if self.unflyAutoWalkDest and self.unflyAutoWalkDest.map == MapMgr:getCurrentMapName() then
                -- NPC寻路，需要到对应的NPC范围即可
                self:endUnFlyAutoWalk(true)
            end
        end
    end
end

-- 是否等待自动寻路
function AutoWalkMgr:isWaitingAutoWalk()
    -- 有自动寻路信息但是还未自动寻路（更换地图后自动寻路会出现此情况）
    return self.autoWalk ~= nil and self.autoWalk.is_walking ~= true
end

-- 是否到达自动寻路终点
function AutoWalkMgr:isAutoWalkArrived()
    if self.autoWalk ~= nil and self.autoWalk.is_walking == true then
        local x, y = gf:convertToMapSpace(Me.curX, Me.curY)

        -- 如果在离npc一定范围内,就可以直接进行对话
        if AUTO_WALK_ACTION_TALK == self.autoWalk.action then
            if gf:inOffset(x, y, self.autoWalk.rawX or self.autoWalk.x, self.autoWalk.rawY or self.autoWalk.y, AUTO_WALK_ACTION_TALK_SCOPE_MAX) then
                return true
            else
                return false
            end
        end

        if AUTO_WALK_ACTION_SPECIAL == self.autoWalk.action then
            if gf:inOffset(x, y, self.autoWalk.rawX or self.autoWalk.x, self.autoWalk.rawY or self.autoWalk.y, AUTO_WALK_ACTION_TALK_FOR_SPECIAL) then
                return true
            else
                return false
            end
        end

        return self.autoWalk.x == x and self.autoWalk.y == y
    else
        return false
    end
end

-- 是否自动寻路
function AutoWalkMgr:isAutoWalk()
    if nil ~= self.autoWalk then
        return true
    end

    return false
end

function AutoWalkMgr:randomWalk(magicDelayTime)
    DebugMgr:beginRandomWalk({ randCenter = self.randCenter, randDestination = self.randDestination, randBindTask = self.randBindTask,
        isObstacle = GObstacle:Instance():IsObstacle(Me.lastMapPosX, Me.lastMapPosY),
        combatOrLookOn = Me:isInCombat() or Me:isLookOn()
    }) -- WDSY-32905

    if GObstacle:Instance():IsObstacle(Me.lastMapPosX, Me.lastMapPosY) then
        -- 如果当前位置处于障碍点不做处理
        Log:F(CHS[3003916])
        return
    end

    if Me:isInCombat() or Me:isLookOn() then
        return
    end

    -- 记录关联的任务
    local randBindTask = self.randBindTask
    local center = self.randCenter
    local randDestination = self.randDestination
    if center == nil then return end

    local meX, meY = gf:convertToMapSpace(Me.curX, Me.curY)

    local x, y = meX, meY
    local count = 0
    local badPath
    repeat
        -- 在周围15格内随机走动
        x = math.random(-8, 8) + self.randCenter.x
        y = math.random(-8, 8) + self.randCenter.y
        count = count + 1

        -- 矫正地图边界
        x, y = MapMgr:adjustPosition(x, y)
        badPath, _ = gf:findPath(Me, x, y)
    until not badPath or (count > 10)

    self.randomWalking = true

    -- 设置Me的终点
    Me:setEndPos(x, y)

    self.randomWalking = nil

    -- 在寻路失败的情况下，获取的x,y坐标可能为nil
    x, y = Me:getEndPos()

    if badPath or x == nil or y == nil then
        gf:confirm(CHS[2000198], function()
            self.randCenter = center
            self.randDestination = randDestination
            self.randBindTask = randBindTask
            self:randomWalk()
        end, function()
            self:endRandomWalk()
        end)
        return
    end

    -- Me:setEndPos中会清除随机走动，需要重新设置
    self.randCenter = center
    self.randDestination = cc.p(x, y)
    self.randBindTask = randBindTask
    if self.randBindTask then
        TaskMgr:bindCurTaskWalkPath(self.randBindTask.task_type, self.randBindTask.task_prompt)
    else
        TaskMgr:clearCurTaskWalkPath()
    end

    -- 设置Me处于随机移动状态
    Me:setIsInRandomWalk(true)

    -- 巡逻
    if not Me.magics[RANDOM_WALK_MAGIC_KEY] and not Me.notXunluoMagic then
        magicDelayTime = magicDelayTime or 0
        local magic = Me:addMagicOnHead(ResMgr.magic.random_walk, false, RANDOM_WALK_MAGIC_KEY, 1)
        magic:setVisible(false)
        performWithDelay(magic:getParent(), function()
            magic = Me.magics[RANDOM_WALK_MAGIC_KEY]
            if magic then
                Me.magics[RANDOM_WALK_MAGIC_KEY]:setVisible(true)
            end
        end, magicDelayTime)
    end
end

function AutoWalkMgr:endRandomWalk()
    DebugMgr:endRandomWalk({ randCenter = self.randCenter, randDestination = self.randDestination, randBindTask = self.randBindTask }) -- WDSY-32905

    self.randCenter = nil
    self.randDestination = nil
    self.randBindTask = nil
    Me:setIsInRandomWalk(false)
    TaskMgr:clearCurTaskWalkPath()
    if not self.randomWalking then
        Me:deleteMagic(RANDOM_WALK_MAGIC_KEY)
    end
end

-- 到达随机走动的终点
function AutoWalkMgr:isRandomWalkArrived()
    local dest = self.randDestination
    if dest == nil then return false end

    local x, y = gf:convertToMapSpace(Me.curX, Me.curY)
    return dest.x == x and dest.y == y
end

-- 解析寻路规则  addby zhengjh
function AutoWalkMgr:getDest(str)
    local oldStr = str

    -- 目的地队列
    local dest = {}
    local notXunluoMagic
    if string.match(str, "not_xunluo_magic") then
        notXunluoMagic = true
    end

    str = string.match(str, ".*(#[PZ].+#[PZ]).*")
    local destList = gf:split(str, "@")
    if destList then
        if #destList == 1 then          -- 一条：就执行当前指令    二条：判断第一个是不是当前地图 不是就执行第二条
            -- 队伍对人大于teamMeber 执行condition1， 否则执行condition2
            local teamMeber, condition1, condition2= string.match(str, ".+|T>(%d*)%?%((.+)%)%?%((.+)%)")
            if teamMeber then
                local destStr = ""
                if TeamMgr:getTeamNum() > tonumber(teamMeber) then
                    local symbol = string.match(condition1, ".*([PZ])") -- 补齐#P#Z
                    destStr = "#"..condition1.."#"..symbol
                else
                    local symbol = string.match(condition2, ".*([PZ])")
                    destStr = "#"..condition2.."#"..symbol
                end

                 dest = self:getMapDest(destStr)
            else
                dest = self:getMapDest(destList[1])
            end
        else
            -- "#Z揽仙454|揽仙镇(35,105)::多闻道人|$0@P多闻道人126|揽仙镇(35,105)::多闻道人|$0|M=离开#Z"
            -- @后面P或者Z表示 后面是#P或#Z(把#P#补全)
            destList[1] = destList[1]..string.sub(destList[1], 1, 2)
            destList[2] = "#"..string.sub(destList[2], 1, -3)
            destList[2] = destList[2]..string.sub(destList[2], 1, 2)
            local dest1 = self:getMapDest(destList[1])


            if dest1["map"] == MapMgr:getCurrentMapName() then
                dest = dest1
            elseif self:isCanAutoWalk(dest1["map"]) then  -- 如果目标地图可以寻路过去
                dest = dest1
            else
                dest = self:getMapDest(destList[2])
                dest.hasNext = oldStr
            end
        end
    else
        return
    end

    dest.notXunluoMagic = notXunluoMagic
    return dest
end

-- 获取符合条件的线路
function AutoWalkMgr:getMapDest(destStr)
    local dest = {}

    if string.match(destStr, "#P(.+)#P") then
        local str = string.match(destStr, "#P(.+)#P")  -- #P 内容
        local strList = gf:split(str, "|")      -- |先分割出的队列
        dest["action"] = "$0"
                                                -- #Pnpc名字#P(默认第一个npc)
        dest["npc"] = strList[1]
        _,dest["map"] = MapMgr:getNpcByName(dest["npc"])

        -- 如果在2019跨服，需要寻找到自己阵营的npc
        if KuafzcMgr:isInKuafzc2019() then
            if Me:queryBasicInt("act_camp") == 1 then
                dest["map"] = CHS[4010334]--"北部战场"
            elseif Me:queryBasicInt("act_camp") == 2 then
                dest["map"] = CHS[4010332]--"南部战场"
            end
        end

        if  #strList >= 2 then
            for i = 2, #strList do
                if string.match(strList[i], "($%d+)") then   -- $ anction
                    dest["action"] = string.match(strList[i], "($%d+)")
                elseif string.match(strList[i], CHS[3003917]) then  -- 线 代表第几线
                    dest["area"] = string.match(strList[i], CHS[3003917])
                elseif string.match(strList[i], "M=(.+)")  then -- 弹出对话框 选中第几条
                    if string.match(strList[i], "&") then
                        -- 解析出，可能模拟点击NPC菜单至两三级
                        local para = string.match(strList[i], "M=(.+)")
                        dest.autoClickKeys = gf:split(para, "&")
                    else
                        dest["msgIndex"] = string.match(strList[i], "M=(.+)")
                    end
                elseif string.match(strList[i], "E=(.+)")   then -- 在指定的菜单上播放光效
                    -- 解析出，可能模拟点击NPC菜单至两三级
                    local para = string.match(strList[i], "E=(.+)")
                    dest.autoClickKeys = gf:split(para, "&")

                    dest["effectIndex"] = dest.autoClickKeys[#dest.autoClickKeys]

                    table.remove(dest.autoClickKeys, #dest.autoClickKeys)
                    if #dest.autoClickKeys == 0 then dest.autoClickKeys = nil end

                elseif string.match(strList[i], "H=(.+)")  then  -- 居所相关内容
                    dest["homeInfo"] = string.match(strList[i], "H=(.+)")
                elseif string.match(strList[i], "Tip=(.+)") then
                    dest["tipText"] =  string.match(strList[i], "Tip=(.+)")
                elseif string.match(strList[i], "Tip_ex=(.+)") then
                    dest["tipCmd"] =  string.match(strList[i], "Tip_ex=(.+)")
                else                                            -- npc 目标地点
                    if string.match(strList[i], "(.*)::(.*)") then
                        local position, npcName = string.match(strList[i], "(.*)::(.*)")

                        dest["npc"] = npcName
                        self:getMapInfo(position, dest)
                    else                                        -- 没有:: 表示npc名字或者地图
                        self:getMapInfo(strList[i], dest)
                        if  (dest["x"] and  dest["y"]) or MapMgr:flyPosition(strList[i])then   -- 地图
                            dest["npc"] = strList[1]
                        else                                     -- npc
                            local  npcInfo, mapName = MapMgr:getNpcByName(strList[i])

                            if npcInfo then
                                dest["npc"] = strList[i]
                                dest["map"] = mapName
                                dest["x"] = npcInfo.x
                                dest["y"] = npcInfo.y
                            end
                        end
                    end
                end
            end

        end
    elseif string.match(destStr,"#Z(.+)#Z") then
         local str = string.match(destStr, "#Z(.+)#Z")  -- #Z 内容
         local strList = gf:split(str, "|")      -- |先分割出的队列
         dest["action"] = "$2"

         if #strList == 1 then                  -- #Z地图#Z
            self:getMapInfo(strList[1], dest)
         else
            self:getMapInfo(strList[1], dest)   -- 先默认为第一个为默认地点

            for i = 2, #strList do
                if string.match(strList[i], "($%d+)") then   -- $ anction
                    dest["action"] = string.match(strList[i], "($%d+)")
                elseif string.match(strList[i], CHS[3003917]) then  -- 线 代表第几线
                    dest["area"] = string.match(strList[i], CHS[3003917])
                elseif string.match(strList[i], "M=(.+)")  then -- 弹出对话框 选中第几条
                    dest["msgIndex"] = string.match(strList[i], "M=(.+)")
                elseif string.match(strList[i], "E=(.+)")   then -- 在指定的菜单上播放光效
                    dest["effectIndex"] = string.match(strList[i], "E=(.+)")
                elseif string.match(strList[i], "H=(.+)")  then  -- 居所相关内容
                    dest["homeInfo"] = string.match(strList[i], "H=(.+)")
                elseif string.match(strList[i], "T=(.+)") then
                    dest["talkStr"] =  string.match(strList[i], "T=(.+)")
                elseif string.match(strList[i], "Dlg=(.+)") then  -- 到达目的地后打开界面
                    dest["openDlgStr"] = string.match(strList[i], "Dlg=(.+)")
                elseif string.match(strList[i], "Tip=(.+)") then
                    dest["tipText"] =  string.match(strList[i], "Tip=(.+)")
                elseif string.match(strList[i], "Tip_ex=(.+)") then
                    dest["tipCmd"] =  string.match(strList[i], "Tip_ex=(.+)")
                elseif string.match(strList[i], "endCallBackFuncForSwitchLine=(.+)") then    --  到达目的地后回调
                    -- 由于 destCallback 在换线后会被清掉！，所以换线后会回调用该方法
                    -- 正常换线后，会重新下发寻路 key 字符串，所以 destCallback 被清了
                    dest["endCallBackFuncForSwitchLine"] =  string.match(strList[i], "endCallBackFuncForSwitchLine=(.+)")
                elseif string.match(strList[i], "furniturePara=(.+)") then
                    dest.furniturePara = string.match(strList[i], "furniturePara=(.+)")
                    dest.x, dest.y = string.match(dest.furniturePara, "pos=(.+),(.+)id")
                    dest.x = tonumber(dest.x)
                    dest.y = tonumber(dest.y)
                else                                            -- npc 目标地点
                    if string.match(strList[i], "(.*)::(.*)") then
                        local position, npcName = string.match(strList[i], "(.*)::(.*)")

                        if position == "" then
                            dest["npc"] = npcName
                            local  npcInfo, mapName = MapMgr:getNpcByName(dest["npc"])

                            if npcInfo then
                                dest["map"] = mapName
                                dest["x"] = npcInfo.x
                                dest["y"] = npcInfo.y
                            end
                        else
                            dest["npc"] = npcName
                            self:getMapInfo(position, dest)
                        end

                    else                                        -- 没有:: 表示地图名字
                        self:getMapInfo(strList[i], dest)
                    end
                end
            end
         end

    end

    return dest
end

-- 获取地图 地点
function AutoWalkMgr:getMapInfo(position, dest)
    if string.match(position, "(.+)%((%d+),(%d+)%)") then   -- 地图有坐标点 没有就默认传送点
        local mapName, x, y = string.match(position, "(.+)%((%d+),(%d+)%)")
        dest["x"] = x
        dest["y"] = y
        dest["map"] = mapName
    else
        dest["map"] = position
        if position == MapMgr:getCurrentMapName() then
        -- 当前地图，使用 me 的位置即可
            dest["x"], dest["y"]= gf:convertToMapSpace(Me.curX, Me.curY)
        else
            --dest["x"], dest["y"] = MapMgr:flyPosition(position)
        end
    end
end

-- 继续自动寻路直到寻路结束
function AutoWalkMgr:continueAutoWalk()
    local notfirstUnFlyAutoWalk
    if self.nextFirstUnFlyAutoWalk then
        notfirstUnFlyAutoWalk = false
    else
        notfirstUnFlyAutoWalk = true
    end

    self:beginAutoWalk(self.autoWalk, notfirstUnFlyAutoWalk)

    DebugMgr:debugLog("AutoWalkMgr:continueAutoWalk:" .. tostringex(self.autoWalk), self.autoWalk)
end

-- 设置打开寻路中需要打开对话的参数
function AutoWalkMgr:setOpenDlgParam(dlg, param)
    self.dlg = dlg
    self.param = param
end

function AutoWalkMgr:getOpenDlgParam()
    return self.dlg, self.param
end

function AutoWalkMgr:clearOpenDlgParam()
    self.dlg = nil
    self.param = nil
end

-- 不飞地图的自动寻路
function AutoWalkMgr:getUnFlyAutoWalkPos(dest)
    if dest == nil then return end
    local curMapID = MapMgr:getCurrentMapId()

    -- 检测当前地图寻路文件是否存在,不存在默认返回fasle  当前天牢不存在
    local allPath = gf:loadLuaFile("autowalk/"..curMapID)
    if not allPath then
        Log:D("autowalk目录下文件" .. curMapID .. "不存在，地图名" .. MapMgr:getCurrentMapName())
        allPath = {}
    end

    local toMapName = dest.map
    local curMapName = MapMgr:getCurrentMapName()
    local mapPath = allPath[toMapName]

    -- 已经达到目标地图或未配置文件，判断当前地图是否有我们要找的NPC如果有则返回Npc
    if not mapPath then

        local char = CharMgr:getCharById(dest.npcId)
        local npc
        if char then
            npc = {}
            npc.x = self.realX
            npc.y = self.realY
        end

        -- 先用对应的坐标和名字（可能重名）取 npc，取不到再取只用名字取
        if not npc then
            npc = MapMgr:getCurMapNpcByPosAndName(dest.npc, self.realX, self.realY)
        end
        if not npc then
            npc = MapMgr:getCurMapNpcByName(dest.npc)
        end

        if npc then
            -- 如果有NPC则返回NPC数据
            return {npc.x, npc.y}, dest.npc, dest.msgIndex, dest.action, dest.homeInfo
        elseif dest.x and dest.y and curMapName == dest.map then
            -- 没有NPC则返回最初的目标
            return {self.realX, self.realY}, dest.npc, dest.msgIndex, dest.action, dest.homeInfo
        elseif dest.map == MapMgr:getCurrentMapName() and Me and Me.curX and Me.curY then
            -- 寻路至目标家具
            if dest.furniturePara then
                local furnName = string.match( dest.furniturePara, "name=(.+)pos=")
                local id = string.match( dest.furniturePara, "id=(.+)MSG")
                local furn = HomeMgr:getFurnObjById(tonumber(id))
                local pos = string.match( dest.furniturePara, "pos=(.+)id")
                local posTab = gf:split(pos, ",")
                if furn then
                    dest.npcId = furn:getId()
                    return {tonumber(posTab[1]), tonumber(posTab[2])}, furnName, nil , "$0"
                end
            end

            -- 自动寻路信息可能配置为 #Z天墉城#Z，此时已到达目的地但没坐标
            local mapX, mapY = gf:convertToMapSpace(Me.curX, Me.curY)
            return {mapX, mapY}, dest.npc, dest.msgIndex, dest.action, dest.homeInfo
        end

        return nil
    end

    if dest.homeInfo and dest.map and MapMgr:isInHouse(dest.map) and MapMgr:isInHouse(curMapName) then
        -- 居所中自动寻路，有飞毯优先使用飞毯
        local curPlace = string.match(curMapName, ".+-(.+)")
        local destPlace = string.match(dest.map, ".+-(.+)")

        -- 转换一下自动点击的菜单项
        destPlace = ((destPlace == CHS[5000289]) and CHS[5000290] or destPlace)
        if curMapName ~= dest.map then
            if curPlace == CHS[2000282] then
                local furn = HomeMgr:getFurnObjByName(CHS[5400255])
                if furn then
                    dest.npcId = furn:getId()
                    return {furn:getBasicPointInMap()}, CHS[5400255], CHS[5000291] .. destPlace, "$0"
                end
            elseif curPlace == CHS[2000284] then
                local furn = HomeMgr:getFurnObjByName(CHS[5400256])
                if furn then
                    dest.npcId = furn:getId()
                    return {furn:getBasicPointInMap()}, CHS[5400256], CHS[5000291] .. destPlace, "$0"
                end
            end
        end


    end

    -- 如果当前地图的第一个路径是NPC,我们应该去找NPC对话
    local tranNpc = MapMgr:getCurMapNpcByName(mapPath[1])
    if tranNpc then
        -- 找到NPC并自动对话
        local msgIndex = ""

        if CharMgr:isEqualName(tranNpc.name, CHS[3003918]) then
            msgIndex = CHS[3003919]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[3003920]) then
            msgIndex = CHS[3003921]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[3003922]) then
            msgIndex = CHS[3003923]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[3003924]) then
            msgIndex = CHS[3003925]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[6000359]) then
            msgIndex = CHS[6000375]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[4100367]) then
            msgIndex = CHS[4100369]
        elseif CharMgr:isEqualName(tranNpc.name, CHS[4100370]) then
            msgIndex = CHS[4100371]
        elseif tranNpc.defalut_talk then -- 有配置默认菜单项
            msgIndex = string.format(tranNpc.defalut_talk, mapPath[2] or "")
        end

        return {tranNpc.x, tranNpc.y}, tranNpc.name, msgIndex, "$0"
    else
        local nextPathKey = 2

        for k, v in pairs(mapPath) do
            if v == curMapName then
                nextPathKey = k + 1
                break
            end
        end

        local nextMapName = mapPath[nextPathKey]
        local curExitData = {}
        if nextPathKey == 2 then
            local room_name, x, y = string.match(mapPath[1], "(.+)%((%d+),(%d+)%)")
            curExitData[1] = { room_name = mapPath[2], x = x, y = y }
        else
            curExitData = MapMgr.exitData
        end

        for k,v in pairs(curExitData) do
            if v.room_name == nextMapName then
                -- 让玩家寻路到指定的目的地
                return {v.x, v.y}
            end
        end

        local npc = MapMgr:getCurMapNpcByName(mapPath[1])

        if npc then
            return {npc.x, npc.y}, mapPath[1], dest.msgIndex
        end
    end
end

-- 判断到达目标地图是否可以通过自动寻路
function AutoWalkMgr:isCanAutoWalk(mapName)
    local curMapID = MapMgr:getCurrentMapId()

    -- 处理游戏断开连接时清空了数据，场景未切换时玩家点击了寻路，而没有寻路信息导致报错
    if curMapID == 0 then
        return false
    end

    -- 检测当前地图寻路文件是否存在,不存在默认返回fasle  当前天牢不存在
    local allPath = gf:loadLuaFile("autowalk/"..curMapID)
    if not allPath then
        Log:D("autowalk目录下文件" .. tostring(curMapID) .. "不存在，地图名" .. tostring(MapMgr:getCurrentMapName()))
        return false
    end

    local mapPath = allPath[mapName]

    if mapPath then
        return true
    else
        return false
    end
end

function AutoWalkMgr:endUnFlyAutoWalk(isNotStopWalk)
    if not self.autoWalk
        or AUTO_WALK_ACTION_TALK ~= self.autoWalk.action
        or self.autoWalk.talkToNpcStatus ~= false then
        -- 到达 NPC 位置， 打开 NPC 对话框，便进入战斗，若此时清除数据，
        -- 战斗后将无法打开对话框，故等战斗后打开对话框在做清除
        self:setUnFlyAutoWalkStatus(false)
        self.unflyAutoWalkDest = nil
        self.realX = nil
        self.realY = nil
        self.realNpc = nil
        self.realAction = nil
        self.talkStr = nil
        self.openDlgStr = nil
        self.destCallback = nil
        self.curTaskWalkPath = nil
        self.tipText = nil
        self.tipCmd = nil
        unFlyAutoWalkEnd = true
    end

    self:tryToEndAutoWalk()

    if not isNotStopWalk then
        Me:setAct(Const.FA_STAND, true)
    end
end

-- 检测是否继续不飞行自动寻路
function AutoWalkMgr:checkGotoUnflyAutoWalk(dest)
    -- 因为押镖具有全局不飞行自动寻路属性
    if TaskMgr:isExistTaskByName(CHS[3003911]) then
        return false
    end

    -- 萝卜桃子大收集具有全局不飞行自动寻路属性
    if TaskMgr:isExistTaskByName(CHS[2200039]) then
        return false
    end

    if KuafzcMgr:isInKuafzc2019() then
        return false
    end

    -- 【七夕节】千里相会 “与好友相会”状态下不可飞
    local task = TaskMgr:getTaskByName(CHS[5400073])
    if task and string.match(task.task_prompt, CHS[5400076]) then
        return false
    end

    -- 居所内的寻路是不可飞的
    if dest.map and MapMgr:isInHouse(dest.map) then
        return false
    end

    if dest.isClickNpc then
        return true
    end

    local currentMapName = MapMgr:getCurrentMapName()

    -- 某些地图严格限制不可飞；如果要离开此地图，需要自动寻路到离开此地图的指引NPC处（生成新的 AutoWalk）
    if UNFLY_MAP[currentMapName] then
        return false
    end

    -- 主要用于副本地图的逻辑
    -- 不可飞寻路的地图
    local isStopUnfly = true
    for _, mapTable in pairs(UnFlyAutoWalkMapName) do
        local currIsIn = false
        for _, mapName in pairs(mapTable) do
            if currentMapName == mapName then
                currIsIn = true
                break
            end
        end

        if currIsIn then
            -- 当前在不可飞寻路的地图内，查找目的地是否也是不可飞地图
            for _, mapName in pairs(mapTable) do
                if dest.map == mapName then
                    isStopUnfly = false
                end
            end

            break
        end
    end

    return isStopUnfly
end

-- npc 对话框是否打开
-- status = false 表示未与 NPC 对话，不能清除寻路信息
-- status = true 已与 NPC 对话，可清除寻路信息
function AutoWalkMgr:setTalkToNpcIsEnd(status)
    if self.autoWalk then
        self.autoWalk.talkToNpcStatus = status

        if status == true then
            if self:isAutoWalkArrived()
                and self.unflyAutoWalkDest
                and self.unflyAutoWalkDest.map == MapMgr:getCurrentMapName() then
                -- 打开对话框后，要到达目的地才清除不可飞寻路信息
                self:endUnFlyAutoWalk()
            end

            self:endAutoWalk()
        end
    end

    -- 移除上次保存的路径
    Me.lastPaths = nil
    Me.lastPosCount = nil
end

-- 设置NPC 是否开启
function AutoWalkMgr:setNpcNoTalkEnd(status)
    if self.autoWalk then
        self.autoWalk.npcNoTalkEnd = status
    end
end

-- 是否 NPC 已经开启
function AutoWalkMgr:isNpcNoTalkEnd()
    if self.autoWalk then
        return self.autoWalk.npcNoTalkEnd
    end

    return false
end

-- 判断npc对话框是否需要打开
function AutoWalkMgr:isTalkToNpcIsEnd()
    if self.autoWalk then
        if not self.autoWalk.talkToNpcStatus then
            return true
        end
    end

    return false
end

-- 判断是否是自动巡逻
function AutoWalkMgr:curAWisRandomWalk()
    if nil == self.autoWalk then
        return false
    end

    return self.autoWalk.action == AUTO_WALK_ACTION_RAND
end

-- 检查过图自动寻路
function AutoWalkMgr:enterRoomContinueAutoWalk()
    -- 检查不能飞地图的自动寻路
    if self.unflyAutoWalkDest and MapMgr:getHaveGetExtits() and MapMgr.isLoadEnd then
        self:beginAutoWalk(gf:deepCopy(self.unflyAutoWalkDest), true)
        MapMgr:setHaveGetExtits(false)
    end

    -- 检查是否有自动寻路
    if self:isWaitingAutoWalk() and Me:getIsEnterScene() and MapMgr.isLoadEnd then
        -- 有自动寻路信息则自动寻路
        self:continueAutoWalk()
        Me:setIsEnterScene(false)
    end
end

-- 停止自动寻路
function AutoWalkMgr:stopAutoWalk(isNotStopWalk)
    -- 清除自动寻路等标志信息
    AutoWalkMgr:endUnFlyAutoWalk(isNotStopWalk)
    AutoWalkMgr:endAutoWalk()
    AutoWalkMgr:clearMessageIndex()
    AutoWalkMgr:clearEffectIndex()
    AutoWalkMgr:clearOpenDlgParam()

    AutoWalkMgr:endRandomWalk()

    -- 停止自动寻路应该清除第2段寻路标记
    -- WDSY-26274，点地板没有清除第2段，导致玩家寻路被点地板打断后，点npc过图进入副本地图，自动开始第2段寻路
    self.hasNext = nil
end

-- 停止自动寻路
function AutoWalkMgr:MSG_STOP_AUTO_WALK(data)
    if data.task_name == CHS[4300234] then
        -- 南荒巫术耗尽在  处于巡逻状态下，需要确认是否继续
        if Me:isRandomWalk() then
            Me:resetGotoEndPos() -- 清掉，不然会把当前的走完
            AutoWalkMgr:endRandomWalk()

            gf:confirm(CHS[4300235], function ()
                PracticeMgr:autoWalkOnCurMap()
            end)
        end
    else
        Me:resetGotoEndPos()
        AutoWalkMgr:endAutoWalk()
        AutoWalkMgr:stopAutoWalk()
    end
end

-- 获取需要等待NPC出现的寻路信息
function AutoWalkMgr:getNpcAppearAutoInfo()
    if self.autoWalk then
        return self.autoWalk
    end

    return self.needWaitAppearInfo
end

-- 当任务被移除时
function AutoWalkMgr:onTaskDrop(info)
    Log:D("task %s be droped.", info.type)

    -- 判断当前寻路信息是否是放弃的任务，如果是放弃的任务，则停止
    if self.autoWalk
        and self.autoWalk.curTaskWalkPath
        and self.autoWalk.curTaskWalkPath.task_type
        and self.autoWalk.curTaskWalkPath.task_type == info.type then
        -- 停止自动寻路
        Me:resetGotoEndPos()
        self:stopAutoWalk()
        if Me.selectTarget then
            Me.selectTarget:removeFocusMagic()
        end
    end
end

-- hook MSG_MOVE 消息，进行判断是否尝试打开NPC对话框
function AutoWalkMgr:MSG_MOVED(map)
    if map.id ~= Me:getId() then
        -- 不是 Me 的移动消息，无需处理
        return
    end

    if self:isTalkToNpcIsEnd() then
        -- 如果还在等待打开 NPC 对话框，尝试继续寻路
        local destNpc = AutoWalkMgr.autoWalk
        local char = CharMgr:getNpcByPos(destNpc)
        if char and gf:inOffset(map.x, map.y, char.lastMapPosX, char.lastMapPosY, AUTO_WALK_ACTION_TALK_SCOPE_MAX) then
            if char and destNpc then
                if destNpc.action == AUTO_WALK_ACTION_TALK then
                    if char.lastMapPosX == destNpc.rawX and char.lastMapPosY == destNpc.rawY and CharMgr:isEqualName(char:getName(), destNpc.npc) and not destNpc.checkDir then
                        if self:isAutoWalkArrived() then
                            if self:isNpcNoTalkEnd() then
                                -- 直接停止，在setAct中会进行停止自动寻路的逻辑和进行停止自动寻路逻辑之前的处理
                                Me:setAct(Const.FA_STAND)
                                Log:D(">>>>> 直接对话 : " .. char:getName())
                            end
                        end
                    end
                end
            end
        end
    end
end

-- hook MSG_TELEPORT_FAILED 清空当前寻路信息
function AutoWalkMgr:MSG_TELEPORT_FAILED(data)
    if "same_map" == data.fail_msg then
        -- 同一张地图，不用停止
        return
    end

    AutoWalkMgr:stopAutoWalk()
end


function AutoWalkMgr:MSG_AUTO_WALK_LINE(data)
    if data.line_name == "" then
        -- 正常情况不会发生该问题
        if data.line_type == 1 then
            gf:ShowSmallTips(CHS[4101292])        -- 当前区组无单数线路。
        else
            gf:ShowSmallTips(CHS[4101293])        -- 当前区组无双数线路。
        end
        return
    end

    local distName, serverId = DistMgr:getServerShowName(data.line_name)
    local ret = string.format( data.auto_walk_info, string.format(CHS[7180004], serverId))
    AutoWalkMgr:beginAutoWalk(gf:findDest(ret))
end


MessageMgr:regist("MSG_AUTO_WALK_LINE", AutoWalkMgr)
MessageMgr:regist("MSG_STOP_AUTO_WALK", AutoWalkMgr)
MessageMgr:hook("MSG_MOVED", AutoWalkMgr, "AutoWalkMgr")
MessageMgr:hook("MSG_TELEPORT_FAILED", AutoWalkMgr, "AutoWalkMgr")

EventDispatcher:addEventListener("EVENT_TASK_DROP", AutoWalkMgr.onTaskDrop, AutoWalkMgr)
EventDispatcher:addEventListener(EVENT.ENTER_COMBAT, AutoWalkMgr.onEnterCombat, AutoWalkMgr)
