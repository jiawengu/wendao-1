-- LingyzmMgr.lua
-- Created by songcw
-- 通天塔神秘房间管理器

TttSmfjMgr = Singleton()

-- 变戏法相关信息
TttSmfjMgr.bxf = {
    rabbit = {},        -- 兔子
    standNpc = {},      -- 站着的npc
}

-- 幽灵漫步npc
TttSmfjMgr.ylmbNpc = {}

-- 手舞足蹈npc
TttSmfjMgr.swzdNpc = {}

-- 变身舞会
TttSmfjMgr.bswhNpc = {}

-- 变戏法npc位置
local BXF_XFYR_POS = cc.p(35, 24)

local YLMB_START_POS = cc.p(31, 16)

-- 玉匣坐标，第一个不用，因为玉匣id为 2到4
local YUXIA_POS = {
    cc.p(0,0),      --
    cc.p(24, 24),
    cc.p(46, 24),
    cc.p(35, 13),
}

-- 变戏法站的的NPC
local BXF_STAND_NPC = {
    {name = CHS[4010302], icon = 6091, dir = 7, pos = BXF_XFYR_POS, id = 1, type = OBJECT_TYPE.NPC},
    {name = CHS[4010304], icon = 20038, dir = 7, pos = YUXIA_POS[2], id = 2, type = OBJECT_TYPE.NPC},
    {name = CHS[4010304], icon = 20038, dir = 7, pos = YUXIA_POS[3], id = 3, type = OBJECT_TYPE.NPC},
    {name = CHS[4010304], icon = 20038, dir = 7, pos = YUXIA_POS[4], id = 4, type = OBJECT_TYPE.NPC},
}

-- 最后需要 * 0.1，所以实际值要 * 0.1
local BXY_BORN_RABBIT_TIME_MIN = 15
local BXY_BORN_RABBIT_TIME_MAX = 20

-- 变戏法游戏时间 15s
local BXF_GAME_PLAY_TIME = 15


local GAME_READY = 0
local GAME_PLAY = 1
local GAME_END = 2

-- 手舞足蹈 游戏 舞林高手 npc
local SWZD_NPC_WLGS = {id = 1, icon = 6002, dir = 6,name = CHS[4010305], pos = cc.p(34, 16), type = OBJECT_TYPE.NPC}

-- 手舞足蹈 玩家位置信息
local SWZD_TEAM_POS ={
    [1]  = {x = 18, y = 21},
    [2]  = {x = 26, y = 21},
    [3]  = {x = 34, y = 21},
    [4]  = {x = 42, y = 21},
    [5]  = {x = 50, y = 21},
}

-- 初始化变戏法
function TttSmfjMgr:initBXF()
    for i = 1, #BXF_STAND_NPC do
        self:createStandNpc(BXF_STAND_NPC[i])
    end

    self.bxfGameState = GAME_READY



    gf:startCountDowm(gf:getServerTime() + 4, "start", function (para )
        -- body
        TttSmfjMgr:cutDown(para)
    end, "bxf_start")
end

-- 倒计时回调
function TttSmfjMgr:cutDown(para)
    if para == "bxf_start" then
        performWithDelay(gf:getUILayer(), function ()
            -- body
            TttSmfjMgr:starTBXF()

            local char = TttSmfjMgr.bxf.standNpc[1]
            char:setChat({msg = CHS[4010303], show_time = 3}, nil, true)
        end, 0.1)
    elseif para == "rabbit_run_end" then
        -- 要等到全部跑完
    end
end

-- 获取变戏法-戏法一人NPC
function TttSmfjMgr:getBxfNpcXfyr()
    if TttSmfjMgr.bxf and TttSmfjMgr.bxf.standNpc and TttSmfjMgr.bxf.standNpc[1] then
        return TttSmfjMgr.bxf.standNpc[1]
    end
end

--
function TttSmfjMgr:createStandNpc(info)
    local char = require("obj/activityObj/TttSmfjNpc").new()

    char:absorbBasicFields({
        id = info.id,
        icon = info.icon,
        name = info.name,
        dir = info.dir,
        type = info.type,
    })

    char:onEnterScene(info.pos.x, info.pos.y)

    char:setAct(Const.SA_STAND, nil, true)

    table.insert(TttSmfjMgr.bxf.standNpc, char)

    return char
end

-- 戏法艺人处产生兔子
function TttSmfjMgr:bornRabbitByXfyr()
    local dlg = DlgMgr:getDlgByName("NoneDlg")
    if not dlg then return end

    if self.bxfEndTime < gfGetTickCount() then return end

    local ti = math.random(BXY_BORN_RABBIT_TIME_MIN, BXY_BORN_RABBIT_TIME_MAX) * 0.1
    performWithDelay(dlg.root, function ()
        local yuxiaTag = math.random(2, 4)
        self.rabbitCount = self.rabbitCount + 1
        TttSmfjMgr:createRabbit(BXF_XFYR_POS, YUXIA_POS[yuxiaTag], self.rabbitCount, yuxiaTag)
        TttSmfjMgr:bornRabbitByXfyr()
    end, ti)
end

-- 宝箱处产生兔子
function TttSmfjMgr:bornRabbitByYx(boxId)
    local dlg = DlgMgr:getDlgByName("NoneDlg")
    if not dlg then return end

    if self.bxfEndTime < gfGetTickCount() then return end

    local ti = math.random(BXY_BORN_RABBIT_TIME_MIN, BXY_BORN_RABBIT_TIME_MAX) * 0.1
    performWithDelay(dlg.root, function ()
        TttSmfjMgr:bornRabbitByYx(boxId)

        local isBorn = math.random( 1, 2 ) == 1 -- 宝匣有50%概率
        if not isBorn then
            return
        end

        local poor
        if boxId == 2 then
            poor = {4, 3}
        elseif boxId == 3 then
            poor = {2, 4}
        else
            poor = {2, 3}
        end
        if not self.boxHasRabbitCount[boxId] or self.boxHasRabbitCount[boxId] <= 0 then return end
        local yuxiaTag = math.random(1, 2)
        self.rabbitCount = self.rabbitCount + 1
        self.boxHasRabbitCount[boxId] = self.boxHasRabbitCount[boxId] - 1
        TttSmfjMgr:createRabbit(YUXIA_POS[boxId], YUXIA_POS[poor[yuxiaTag]], self.rabbitCount, poor[yuxiaTag])

    end, ti)
end

-- 开始变戏法
function TttSmfjMgr:starTBXF()
    self.rabbitCount = 0        -- 兔子总个数
    self.boxHasRabbitCount = {} -- 每个箱子中兔子数
    self.bxfEndTime = gfGetTickCount() + BXF_GAME_PLAY_TIME * 1000  -- 兔子跑动时间
    self.bxfGameState = GAME_PLAY

    gf:startCountDowm(gf:getServerTime() + BXF_GAME_PLAY_TIME + 1, "end", function (para )
        -- body
        TttSmfjMgr:cutDown(para)
    end)

    -- 定时刷新兔子从戏法一人处
    TttSmfjMgr:bornRabbitByXfyr()

    TttSmfjMgr:bornRabbitByYx(2)
    TttSmfjMgr:bornRabbitByYx(3)
    TttSmfjMgr:bornRabbitByYx(4)
end

-- 删除某一只兔子
function TttSmfjMgr:deleteRabbit(tag)
    if not TttSmfjMgr.bxf.rabbit[tag] then return end

    TttSmfjMgr.bxf.rabbit[tag]:cleanup()
    TttSmfjMgr.bxf.rabbit[tag] = nil

    -- 游戏时间结束了
    if self.bxfEndTime < gfGetTickCount() and self.bxfGameState ~= GAME_END then
        local isNoRabbit = true
        -- 如果场上已经没有兔子。则游戏结束
        for i = 1, self.rabbitCount do
            if TttSmfjMgr.bxf.rabbit[i] then
                isNoRabbit = false
            end
        end

        if isNoRabbit then
            self.bxfGameState = GAME_END

            local str = string.format( "%d,%d,%d", self.boxHasRabbitCount[2] or 0, self.boxHasRabbitCount[3] or 0, self.boxHasRabbitCount[4] or 0)
            -- 发送消息至服务器
            performWithDelay(gf:getUILayer(), function ()
                self:clearAllBxfObj()
                DlgMgr:closeDlg("NoneDlg")
                gf:CmdToServer("CMD_SMFJ_BXF_REPORT_RESULT", {str = gfEncrypt(TttSmfjMgr:getEncrypt(str), tostring(Me:getId()))})
            end, 1)
        end
    end
end

function TttSmfjMgr:enterForeground(durTimeTicket)
    if durTimeTicket < 10000 then
        -- 变戏法切入后台10秒内。直接产生兔子
        if self.bxfGameState and self.bxfGameState == GAME_PLAY then
            local count = math.ceil( durTimeTicket / 1000 )
            for i = 1, count do
                local yuxiaTag = math.random(2, 4)
                self.rabbitCount = self.rabbitCount or 0
                self.rabbitCount = self.rabbitCount + 1
                TttSmfjMgr:createRabbit(BXF_XFYR_POS, YUXIA_POS[yuxiaTag], self.rabbitCount, yuxiaTag)
            end
        end
    else
        -- 变戏法切入后台10直接播放结束，客户端自己随机设置箱子宝箱数
        if self.bxfGameState and self.bxfGameState ~= GAME_END then
            local str = string.format( "%d,%d,%d", math.random( 1, 10 ), math.random( 1, 10 ), math.random( 1, 10 ))
            self:clearAllBxfObj()
            DlgMgr:closeDlg("NoneDlg")
            gf:closeCountDown()
            gf:CmdToServer("CMD_SMFJ_BXF_REPORT_RESULT", {str = gfEncrypt(TttSmfjMgr:getEncrypt(str), tostring(Me:getId()))})
        end
    end


    if self.bxfGameState and self.bxfGameState == GAME_PLAY and durTimeTicket < 10000 then

        local count = math.ceil( durTimeTicket / 1000 )
        for i = 1, count do
            local yuxiaTag = math.random(2, 4)
            self.rabbitCount = self.rabbitCount or 0
            self.rabbitCount = self.rabbitCount + 1
            TttSmfjMgr:createRabbit(BXF_XFYR_POS, YUXIA_POS[yuxiaTag], self.rabbitCount, yuxiaTag)
        end
    else

        if durTimeTicket > 10000 then
        end

    end
end

-- 宝箱增加兔子
function TttSmfjMgr:addRabbitByBox(boxId)
    if not self.boxHasRabbitCount[boxId] then self.boxHasRabbitCount[boxId] = 0 end
    self.boxHasRabbitCount[boxId] = self.boxHasRabbitCount[boxId] + 1
end

-- 创建兔子
function TttSmfjMgr:createRabbit(startPos, endPos, id, dest)
    local char = require("obj/activityObj/TttSmfjNpc").new()

    char:absorbBasicFields({
        id = id,
        icon = 6165,
        name = CHS[4010306],
       -- life = info.life,
        dir = 3,
        boxId = dest,
    })

    char:setSeepPrecent(-60)
    char:onEnterScene(startPos.x, startPos.y)
    char:setDestPos(endPos)
    char:setEndPos(endPos.x, endPos.y)
    char:addMagicOnWaist(ResMgr.magic.grey_fog, false)


    TttSmfjMgr.bxf.rabbit[id] = char
end

function TttSmfjMgr:update()
    for _, v in pairs(TttSmfjMgr.bxf.rabbit) do
        v:update()
    end

    for _, v in pairs(TttSmfjMgr.ylmbNpc) do
        v:update()
    end
end


function TttSmfjMgr:clearAllBxfObj()
    for k, v in pairs(TttSmfjMgr.bxf.rabbit) do
        if v then
            v:cleanup()
        end
    end

    for k, v in pairs(TttSmfjMgr.bxf.standNpc) do
        if v then
            v:cleanup()
        end
    end

    TttSmfjMgr.bxf.standNpc = {}

    TttSmfjMgr.bxf.rabbit = {}
end


function TttSmfjMgr:clearAllRabbit()
    for k, v in pairs(TttSmfjMgr.bxf.rabbit) do
        if v then
            v:cleanup()
        end
    end

    TttSmfjMgr.bxf.rabbit = {}
end


-- isFade 渐变消失
function TttSmfjMgr:clearYlmbNpcById(id)

    if id == 1 then
        -- 幽灵消失需要渐隐
        local char = TttSmfjMgr:getYlmbCharById(1)
        if not char then return end
        local fadeAct = cc.FadeOut:create(0.3)
        char.charAction:runAction(fadeAct)
        performWithDelay(gf:getUILayer(), function ()
            char:cleanup()
            TttSmfjMgr.ylmbNpc[10] = nil
        end, 0.5)

        return
    end


    if id then
        for cId, char in pairs(TttSmfjMgr.ylmbNpc) do
            if cId == id then
                char:cleanup()
            end
        end

        TttSmfjMgr.ylmbNpc[id] = nil
    else
        for k, v in pairs(TttSmfjMgr.ylmbNpc) do
            if v then
                v:cleanup()
            end
        end

        TttSmfjMgr.ylmbNpc = {}
    end
end



function TttSmfjMgr:getYlmbStartPos()
    return YLMB_START_POS
end

function TttSmfjMgr:initYLMB()
    local members = TeamMgr.members

    if #members ~= 0 and TeamMgr:inTeam(Me:getId()) then
        -- 如果队伍不止一人，并且我在队伍中，则取队伍数据
        for i = 1, #members do
            local char = members[i]
            local vipType = 0
            local player = CharMgr:getCharById(char.id)
            if player then vipType = player:queryBasicInt("vip_type") end
            local info = {icon = char.org_icon, name = char.name, id = char.id, pos = YLMB_START_POS, vip_type = vipType, type = OBJECT_TYPE.CHAR}

            TttSmfjMgr:createStandNpcForYlmb(info)
        end
    else
        -- 如果只有我一个人，显示我的信息
        local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), id = Me:getId(), pos = YLMB_START_POS, vip_type = Me:getVipType(), type = OBJECT_TYPE.CHAR}
        TttSmfjMgr:createStandNpcForYlmb(info)
   end
end

function TttSmfjMgr:createStandNpcForYlmb(info)
    local char = require("obj/activityObj/TttSmfjNpc").new()

    char:absorbBasicFields({
        id = info.id * 10,
        icon = info.icon,
        name = info.name,
        dir = info.dir or 5,
        type = info.type,
        vip_type = info.vip_type or 0
    })

    char:setSeepPrecent(-30)
    char:onEnterScene(info.pos.x, info.pos.y)
    char:setAct(Const.SA_STAND)
    TttSmfjMgr.ylmbNpc[info.id * 10] = char
    return char
end

function TttSmfjMgr:MSG_SMFJ_BXF_START_GAME(data)
    DlgMgr:openDlg("NoneDlg")
    TttSmfjMgr:initBXF()
end

function TttSmfjMgr:MSG_SMFJ_YLMB_STEP_LIST(data)
    DlgMgr:openDlgEx("SpeclalRoomStrollDlg", data)
end

function TttSmfjMgr:getYlmbCharById(id)
    return TttSmfjMgr.ylmbNpc[id * 10]
end

-- 创建手舞足蹈npc
function TttSmfjMgr:initSwzdObj()

    -- 武林高手 npc
    TttSmfjMgr:createStandNpcForSwzd(SWZD_NPC_WLGS)

    -- 队友信息
    local members = TeamMgr.members

    if #members ~= 0 and TeamMgr:inTeam(Me:getId()) then
        -- 如果队伍不止一人，并且我在队伍中，则取队伍数据
        for i = 1, #members do
            local char = members[i]
            local vipType = 0
            local player = CharMgr:getCharById(char.id)
            if player then vipType = player:queryBasicInt("vip_type") end
            local info = {icon = char.org_icon, name = char.name, id = char.id, pos = SWZD_TEAM_POS[i], vip_type = vipType, type = OBJECT_TYPE.CHAR}
            TttSmfjMgr:createStandNpcForSwzd(info)
        end
    else
        -- 如果只有我一个人，显示我的信息
        local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), id = Me:getId(), pos = SWZD_TEAM_POS[3], vip_type = Me:getVipType(), type = OBJECT_TYPE.CHAR}
        TttSmfjMgr:createStandNpcForSwzd(info)
   end
end

-- 创建手舞足蹈npc
function TttSmfjMgr:createStandNpcForSwzd(info)
    local char = require("obj/activityObj/TttSmfjNpc").new()

    char:absorbBasicFields({
        id = info.id,
        icon = info.icon,
        name = info.name,
        dir = info.dir or 5,
        type = info.type,
        vip_type = info.vip_type or 0
    })

    char:setSeepPrecent(-30)
    char:onEnterScene(info.pos.x, info.pos.y)
    char:setAct(Const.SA_STAND)
    TttSmfjMgr.swzdNpc[info.id] = char
    return char
end

-- 获取手舞足蹈小游戏创建的npc角色
function TttSmfjMgr:getSwzdCharById(id)
    for cId, char in pairs(TttSmfjMgr.swzdNpc) do
        if cId == id then
            return char
        end
    end
end

function TttSmfjMgr:clearSwzdNpcById(id)
    if id then
        for cId, char in pairs(TttSmfjMgr.swzdNpc) do
            if cId == id then
                char:cleanup()
            end
        end

        TttSmfjMgr.swzdNpc[id] = nil
    else
        for k, v in pairs(TttSmfjMgr.swzdNpc) do
            if v then
                v:cleanup()
            end
        end

        TttSmfjMgr.swzdNpc = {}
    end
end


function TttSmfjMgr:MSG_SMFJ_SWZD_STEP_LIST(data)
    self.swzdStepData = data
    self.swzdCharStepData = {}
end

function TttSmfjMgr:MSG_SMFJ_SWZD_MOVE_STEP(data)
    self.swzdCharStepData[data.id] = data
end

function TttSmfjMgr:createStandNpcForBswh(info)
    local char = require("obj/activityObj/TttSmfjNpc").new()

    char:absorbBasicFields({
        id = info.id,
        icon = info.icon,
        name = info.name,
        dir = info.dir or 5,
        type = info.type,
        vip_type = info.vip_type or 0
    })

    char:setSeepPrecent(-30)
    char:onEnterScene(info.pos.x, info.pos.y)
    char:setAct(Const.SA_STAND)
    TttSmfjMgr.bswhNpc[info.id] = char
    return char
end

function TttSmfjMgr:cleanup()
    TttSmfjMgr:clearAllBxfObj()
    TttSmfjMgr:clearYlmbNpcById()
    TttSmfjMgr:clearSwzdNpcById()
    TttSmfjMgr:clearBswhNpc()
end

function TttSmfjMgr:clearBswhNpc()

    for _, v in pairs(TttSmfjMgr.bswhNpc) do
        v:cleanup()
    end

    TttSmfjMgr.bswhNpc = {}
end


function TttSmfjMgr:getBswhNpcById(id)
    return TttSmfjMgr.bswhNpc[id]
end

function TttSmfjMgr:initBswhNpc()
    local info = {id = 1, icon = 6049, name = CHS[3000853], dir = 5, pos = cc.p(34, 16)}
    local char = TttSmfjMgr:createStandNpcForBswh(info)

    local members = TeamMgr.members
    if #members ~= 0 and TeamMgr:inTeam(Me:getId()) then
        -- 如果队伍不止一人，并且我在队伍中，则取队伍数据
        for i = 1, #members do
            local char = members[i]
            local vipType = 0
            local player = CharMgr:getCharById(char.id)
            if player then vipType = player:queryBasicInt("vip_type") end
            local info = {icon = char.org_icon, name = char.name, id = char.id, pos = SWZD_TEAM_POS[i], vip_type = vipType, type = OBJECT_TYPE.CHAR}

            TttSmfjMgr:createStandNpcForBswh(info)
        end
    else
        -- 如果只有我一个人，显示我的信息
        local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), id = Me:getId(), pos = SWZD_TEAM_POS[3], vip_type = Me:getVipType(), type = OBJECT_TYPE.CHAR}
        TttSmfjMgr:createStandNpcForBswh(info)
   end
end

function TttSmfjMgr:MSG_SMFJ_GAME_STATE(data)

    if data.status == 3 then
        performWithDelay(gf:getUILayer(), function ( )
            if GameMgr.scene and GameMgr.scene.map then
                GameMgr.scene.map:setCenterChar(nil)
            end
        end, 2)
    else
        local char = CharMgr:getCharByName(CHS[4200636])
        if GameMgr.scene and GameMgr.scene.map then
            GameMgr.scene.map:setCenterChar(char:getId())
        end
    end

    if data.game_name == CHS[4010300] then  -- 手舞足蹈
        if data.status == 1 then
            DlgMgr:openDlgEx("SpeclalRoomDanceDlg", data)
        elseif data.status == 2 then
            if not DlgMgr:getDlgByName("SpeclalRoomDanceDlg") then
                DlgMgr:openDlgEx("SpeclalRoomDanceDlg", data)
            end
        else
        end
    elseif data.game_name == CHS[4010299] then  -- 变身舞会
        if data.status == 1 then
            DlgMgr:openDlgEx("SpeclalRoomConvertDlg", data)
        elseif data.status == 2 or data.status == 3 then
            if not DlgMgr:getDlgByName("SpeclalRoomConvertDlg") then
                DlgMgr:openDlgEx("SpeclalRoomConvertDlg")
                DlgMgr:sendMsg("SpeclalRoomConvertDlg", "MSG_SMFJ_GAME_STATE", data)
            else
                DlgMgr:sendMsg("SpeclalRoomConvertDlg", "MSG_SMFJ_GAME_STATE", data)
            end

        end
    elseif data.game_name == CHS[4010295] then  -- 超级大胃王
        if data.status == 1 then
            DlgMgr:openDlgEx("SpeclalRoomEatDlg", data)
        else
            if not DlgMgr:getDlgByName("SpeclalRoomEatDlg") then
                DlgMgr:openDlgEx("SpeclalRoomEatDlg")
                DlgMgr:sendMsg("SpeclalRoomEatDlg", "MSG_SMFJ_GAME_STATE", data)
            else
                DlgMgr:sendMsg("SpeclalRoomEatDlg", "MSG_SMFJ_GAME_STATE", data)
            end
        end
    end
end

function TttSmfjMgr:getEncrypt(str)
    return "#@#" .. str .. "#@#"
end

function TttSmfjMgr:MSG_TTT_GJ_NEW_XING(data)
    local ret = {}
    ret.content = CHS[4010308]
    ret.name = CHS[4010309]
    ret.portrait = 6223
    ret.id = 1
    local dlg = DlgMgr:openDlg("NpcDlg")
    dlg.itemPos = data.pos
    dlg:updateDlg(ret)
end

MessageMgr:regist("MSG_TTT_GJ_NEW_XING", TttSmfjMgr)
MessageMgr:regist("MSG_SMFJ_SWZD_MOVE_STEP", TttSmfjMgr)
MessageMgr:regist("MSG_SMFJ_GAME_STATE", TttSmfjMgr)
MessageMgr:regist("MSG_SMFJ_SWZD_STEP_LIST", TttSmfjMgr)
MessageMgr:regist("MSG_SMFJ_BXF_START_GAME", TttSmfjMgr)
MessageMgr:regist("MSG_SMFJ_YLMB_STEP_LIST", TttSmfjMgr)

