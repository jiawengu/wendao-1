-- CharMgr.lua
-- Created by chenyq Nov/14/2014
-- 负责管理场景中的角色

local List = require("core/List")
CharMgr = Singleton()
CharMgr.chars = {}
CharMgr.npcList = {}
CharMgr.guoQingJieSoldiers = {}
CharMgr.hasEffectSoldiers = {}
CharMgr.actionStatusInfo = {}
CharMgr.lastRequestIconTime = {}

local ChengWeiColor = require(ResMgr:getCfgPath('ChengWei.lua'))
local LightEffect = require(ResMgr:getCfgPath('LightEffect.lua'))
local CharConfig = require(ResMgr:getCfgPath('CharConfig.lua'))

local USER_ATTRIB_LIST = require(ResMgr:getCfgPath('UserAttribList.lua'))
local USER_ATTRIB_LIST_TEST = require(ResMgr:getCfgPath('UserAttribListTest.lua'))

-- 初始化加载地图上角色的队列
local CharLoadList = List.new()

local PlayerCharLoadList = List.new()

local CJMG_EFF_INFO = {
        [1] = 06011,    [2] = 04009,    [3] = 04010,    [4] = 04010,    [5] = 04009,    [6] = 06011
}


local CHAR_TONGTIANTA = {
    [CHS[3003927]] = 1,
    [CHS[3003928]] = 1,
    [CHS[3003929]] = 1,
    [CHS[3003930]] = 1,
    [CHS[3003931]] = 1,
    [CHS[3003932]] = 1,
    [CHS[3003933]] = 1,
}

local SPECIAL_CHENGWEI = {
    ["jiebai_"] = CHS[7002211],  -- 结拜
    ["fteam_"] = CHS[2100251],   -- 固定队
}

local OUT_USER_LIST_NAME = {
    [CHS[4200399]] = 1,
    [CHS[4200400]] = 1,
    [CHS[4200401]] = 1,
    [CHS[4200402]] = 1,
}

local STATUS_ACTION = {
    [Const.NS_A_QINQIN] = {act = Const.FA_QINQIN, icon = 42101},
    [Const.NS_A_BAOBAO] = {act = Const.FA_YONGBAO, icon = 42101},
    [Const.NS_A_JIAOBEI] = {act = Const.FA_JIAOBEI, icon = 42101},
}

function CharMgr:checkPos(x, y)
-- todo
end

function CharMgr:checkDir(dir)
-- todo
end

function CharMgr:isBusy(id)
-- todo
end

function CharMgr:addBusyness(id, type, map, step)
-- todo
end

-- 设置场景中的角色是否可见
function CharMgr:setVisible(flag)
    for _, v in pairs(self.chars) do
        v:setVisible(flag)
    end
end

function CharMgr:getChar(id)
    return self.chars[id]
end

function CharMgr:getPet(ownerId)
    for _, v in pairs(self.chars) do
        if v:queryBasicInt("owner_id") == ownerId then
            return v
        end
    end
end

-- 清空宠物的主人
function CharMgr:clearPetOwner(ownerId)
    local pet = self:getPet(ownerId)
    if not pet then
        return
    end

    pet:setOwner(nil)
end

function CharMgr:deleteChar(id)
    local char = self.chars[id]
    self.npcList[id] = nil
    self.chars[id] = nil
    self.guoQingJieSoldiers[id] = nil
    self.actionStatusInfo[id] = nil

    PlayerCharLoadList:removeSomeBySubkey("id", id)
    CharLoadList:removeSomeBySubkey("id", id)

    if self.loadCharTimestamp then
        self.loadCharTimestamp[id] = nil
    end

    if self.needLoadWhenMeStand then
        for i = 1, #self.needLoadWhenMeStand do
            if self.needLoadWhenMeStand[i].id == id then
                self.needLoadWhenMeStand[i].isDelete = true
            end
        end
    end

    if char and not self.hasEffectSoldiers[id] then
        -- 离开场景
        char:cleanup()
    end
end

function CharMgr:getNpcList()
    return self.npcList
end

function CharMgr:clearAllChar()
    self.npcList = {}
    self.guoQingJieSoldiers = {}

    self:clearLoadCharListSize()

    for id, v in pairs(self.hasEffectSoldiers) do
        -- self.chars 中存的士兵对象，在 CharMgr:deleteChar(id) 中可能已被赋空，但未被析构
        if not self.chars[id] then
            v:cleanup()
        end
    end

    self.hasEffectSoldiers = {}

    for k, v in pairs(self.chars) do
        if k and v then
            if v:queryBasicInt("is2018SJ_SNCG") == 1 and DlgMgr:isDlgOpened("WatermelonRaceDlg") then
                -- 谁能吃瓜活动创建的模型，在 SummerSncgMgr:stopRunGame() 中调用移除
            else
            self.chars[k] = nil
            if v and v:getId() == Me:getId() then
                v:onExitScene()
            else
                v:cleanup()
            end
        end
        end
    end

    self.lastWMXJTime = nil
    self.actionStatusInfo = {}
    self.lastRequestIconTime = {}


    self.qrjCjmg2019Data = nil

    PuttingItemMgr:clearAllItems()
end

-- 发送移动命令
function CharMgr:sendMoveCmds()
    for _, char in pairs(self.chars) do
        char:sendMoveCmds()
    end
end

-- 处理发送移动命令之后的事件
function CharMgr:dealAfterSendMoveCmds()
    for _, char in pairs(self.chars) do
        char:dealAfterSendMoveCmds()
    end
end

-- 更新
local deleteCharIds = {}
function CharMgr:update()
    local i = 1
    for _, char in pairs(self.chars) do
        char:update()
        if char:isNeedDelete() then
            deleteCharIds[i] = char:getId()
            i = i + 1
        end
    end

    for i = #deleteCharIds, 1, -1 do
        if deleteCharIds[i] then
            CharMgr:deleteChar(deleteCharIds[i])
            deleteCharIds[i] = nil
        end
    end

    -- 遍历完成，开始加载新角色了
    self:loadCharsOneFPS()

    -- WDSY-28117
    -- 在2018端午节任务时，如果在无名仙境，需要判断角色和噬仙虫相对位置
    -- 当前设定为，在无名仙境，char是 噬仙虫，0.5s检测一次
    if MapMgr:isInMapByName(CHS[4010025]) then

        self.lastWMXJTime = self.lastWMXJTime or 0

        if gfGetTickCount() - self.lastWMXJTime < 500 then
			-- 间隔0.5秒
        else
            for _, char in pairs(self.chars) do
                if string.match(char:queryBasic("name"), CHS[4010026]) then
                    if gf:distance(char.curX, char.curY, Me.curX, Me.curY) <= 100 then

                        Me:sendMoveCmds()
                        local x, y = gf:convertToMapSpace(char.curX, char.curY)
                        gf:CmdToServer("CMD_DUANWU_2018_COLLISION", {
                            monster_id = char:getId(),
                            x = x,
                            y = y,
                            dir = char:queryBasicInt("dir")
                        })
                    end
                end
            end

            self.lastWMXJTime = gfGetTickCount()
        end
    end
end

-- para 额外的辅助判断参数
function CharMgr:getChengWeiColor(str, para)
     -- 通天塔判断
    if CHAR_TONGTIANTA[para] then
        return COLOR3.BLUE
    end

    -- 某些特殊称谓需要将“具体称谓名称”转化为“称谓类别名称”获取称谓的颜色和来源
    for k, v in pairs(SPECIAL_CHENGWEI) do
        if string.match(str, k) then
            str = v
        end
    end

    if ChengWeiColor[str] then
        return ChengWeiColor[str].color
    end

    for title, info in pairs(ChengWeiColor) do
        local len = string.len(title)
        if title ~= "" and string.sub(str,string.len(str) - len + 1, -1) == title then
            return ChengWeiColor[title].color
        end
    end

    return COLOR3.GREEN
end

function CharMgr:getChengweiShowName(title)
    -- 某些称谓名称使用“前缀”来表明“称谓类别”，实际称谓名称需要处理一下获取
    if not title then
        return ""
    end

    for k, v in pairs(SPECIAL_CHENGWEI) do
        if string.match(title, k) then
             local list = gf:split(title, k)
             return list[2]
        end
    end

    return title
end

function CharMgr:doChengWeiShowName(str)
    for k, v in pairs(SPECIAL_CHENGWEI) do
        if string.match(str, k) then
            str = string.gsub(str, k, "")
        end
    end

    return str
end

function CharMgr:getChenweiResource(str)
    -- 某些特殊称谓需要将“具体称谓名称”转化为“称谓类别名称”获取称谓的颜色和来源
    for k, v in pairs(SPECIAL_CHENGWEI) do
        if string.match(str, k) then
            str = v
        end
    end

	if ChengWeiColor[str] then
	   if GameMgr.isIOSReview and ChengWeiColor[str].reviewRes then
            return ChengWeiColor[str].reviewRes
       else
            return ChengWeiColor[str].rescourse
       end
    end

    for title, info in pairs(ChengWeiColor) do
        local len = string.len(title)
        if title ~= "" and string.sub(str,string.len(str) - len + 1, -1) == title then
            if GameMgr.isIOSReview and ChengWeiColor[title].reviewRes then
                return ChengWeiColor[title].reviewRes
            else
                return ChengWeiColor[title].rescourse
            end
        end
    end

   return ""
end

function CharMgr:talkToNpc(name, posx , posy, npcId)
    if name == nil then return false end

    for _, char in pairs(self.npcList) do
        -- 如果有npcId 直接通过npcId进行判断
        if npcId and npcId == char:getId() then
            if char:getType() == "GatherNpc" then
				self:talkToGatherNpc(char)
            else
                if OBJECT_NPC_TYPE.CMD_NPC == char:queryBasicInt("sub_type") then
                    gf:CmdToServer("CMD_CLICK_NPC", {npcId = char:getId()})
                else
                    CharMgr:openNpcDlg(char:getId())
                end
            end

            -- 此时有可能会触发战斗，故先标记一下，以方便战斗结束后做处理
            AutoWalkMgr:setTalkToNpcIsEnd(false)
            return true
        end
    end

    -- 拆成另个循环，因为居所丫鬟可改名管家，会寻找错误
    for _, char in pairs(self.npcList) do
        if self:isEqualName(char:getName(), name, char:queryBasic('alicename'))
            and (char:getType() == "Npc" or char:getType() == "GatherNpc" )and
            char.lastMapPosX == posx and char.lastMapPosY == posy then
            if char:getType() == "GatherNpc" then
                self:talkToGatherNpc(char)
            else
                if OBJECT_NPC_TYPE.CMD_NPC == char:queryBasicInt("sub_type") then
                    gf:CmdToServer("CMD_CLICK_NPC", {npcId = char:getId()})
                else
                    CharMgr:openNpcDlg(char:getId())
                end
            end


            -- 此时有可能会触发战斗，故先标记一下，以方便战斗结束后做处理
            AutoWalkMgr:setTalkToNpcIsEnd(false)
            return true
        end
    end


    return false
end

function CharMgr:talkToMonster(name, npcId)
    if name == nil then return end

    for _, char in pairs(self.chars) do
        -- 如果有npcId 直接通过npcId进行判断
        if npcId and npcId == char:getId() then
            CharMgr:openNpcDlg(char:getId())

            -- 此时有可能会触发战斗，故先标记一下，以方便战斗结束后做处理
            AutoWalkMgr:setTalkToNpcIsEnd(false)
            return true
        end

        if char:getName() == name and char:getType() == "Monster" then
            CharMgr:openNpcDlg(char:getId())

            -- 此时有可能会触发战斗，故先标记一下，以方便战斗结束后做处理
            AutoWalkMgr:setTalkToNpcIsEnd(false)
            return true
        end
    end

    return false
end

function CharMgr:isInScreenNPC(name)
    if name == nil then return end

    for _, char in pairs(self.chars) do
        if self:isEqualName(char:getName(), name) and char:getType() == "Npc" then
            return true
        end
    end

    return false
end

-- 如果 name 是带有编号的 NPC 名，不能调用 此接口获取 NPC
function CharMgr:getNpcByName(name)
    if name == nil then return nil end

    for _, char in pairs(self.chars) do
        if char:getName() == name and (char:getType() == "Npc" or char:getType() == "Monster") then
            return char
        end
    end

    return nil
end

function CharMgr:getCharById(id)
    if id == nil then return nil end

    for _, char in pairs(self.chars) do
        if char:getId() == id then
            return char
        end
    end

    return nil
end

function CharMgr:getCharByName(name)
    if name == nil then return nil end

    for _, char in pairs(self.chars) do
        if char:getName() == name then
            return char
        end
    end

    return nil
end

function CharMgr:getNpcByPos(autowalk)
    if not autowalk then return end

    for _, char in pairs(self.chars) do
        if (self:isEqualName(char:getName(), autowalk.npc))
            and (char.lastMapPosX == autowalk.rawX)
            and (char.lastMapPosY == autowalk.rawY)
            and (char:getType() == "Npc" or char:getType() == "Monster") then
            return char
        end
    end
end

function CharMgr:isNowLoadChar(char)
    if char.status == Const.NS_YX_STATUS
        or char.status == Const.NS_YR_STATUS
        or char.status == Const.NS_ET_STATUS
        or char.status == Const.NS_SJ_STATUS
        or char.isNowLoad then
        return true
    end

    return false
end

function CharMgr:getNeedRemoveLightEffect(map)
    local char = self:getChar(map.id)
    if not char then return end

    local count = char:queryBasicInt("light_effect_count")
    if count <= 0 then return end

    local newMagics = {}
    for i = 1, map.light_effect_count do
        newMagics[map.light_effect[i]] = map.light_effect[i]
    end

    local toRemoves = {}
    local lightEffects = char:queryBasic("light_effect")
    if lightEffects then
        for _, v in ipairs(lightEffects) do
            if not newMagics[v] then
                table.insert(toRemoves, v)
            end
        end
    end

    return toRemoves
end

-- 角色出现
function CharMgr:MSG_APPEAR(map)
    local toRemoves = self:getNeedRemoveLightEffect(map)

    -- 应该需要先缓存数据，再创建相应的形象部件
    local char = self:loadCharData(map)

    -- 具体创建将压入栈中
    if char:getId() ~= Me:getId() then
        if self:isNowLoadChar(map) then
            self:loadChar(map)
        else
            self:pushOneToLoadCharList(map)
        end
    end

    -- 设置透明度
    char.middleLayer:setCascadeOpacityEnabled(true)
    char.middleLayer:setOpacity((100 - map.opacity) / 100 * 255)

    -- 附加的额外光效
    if not MapMgr:isInYuLuXianChi() then
        -- 玉露仙池地图屏蔽所有角色特效
        for i = 1, map.light_effect_count do
            if map.light_effect[i] then
                CharMgr:MSG_PLAY_LIGHT_EFFECT({charId = map.id, effectIcon = map.light_effect[i]})
            end
        end
    end

    -- 删除不需要的附加光效
    if toRemoves then
        for i = 1, #toRemoves do
            if char and toRemoves[i] then
                char:deleteMagic(toRemoves[i])
            end
        end
    end

    -- 2018劳动节锄强扶弱副本npc出现时，需要开启该活动特殊处理
    if self:isCharInLabor(char) then
        char:setCanTouch(false)
    end

	-- 2019 情人节活动
    if self.qrjCjmg2019Data then
        for gid, no in pairs(self.qrjCjmg2019Data.effInfo) do
            local char = CharMgr:getCharByGid(gid)
            if char and CJMG_EFF_INFO[no] then
                local tempData = {charId = char:getId(), effectIcon = CJMG_EFF_INFO[no]}
                CharMgr:MSG_PLAY_LIGHT_EFFECT(tempData)
                end
            end
        end

end

-- 角色移动
function CharMgr:MSG_MOVED(map)
    self:checkPos(map.x, map.y)
    self:checkDir(map.dir)

    if map.id == Me:getId() then
        -- 记录数据，用于战斗后重置玩家的位置，防止出现被服务端拉回的现象
        -- WDSY-27767 修改为也要记录不可操控对象的数据，有些活动退出战斗后会设置队员离队，此时如果没有数据，会出现被服务端拉回的现象
        Me.lastMap = map

        -- 目前人物由自己控制移动，忽略服务器对自己的移动确认，只需记录一下在服务器端的位置即可
        if Me:isControlMove() or Me.isLimitMoveByClient then
        Me:setBasic('x', map.x)
        Me:setBasic('y', map.y)
        return
    end
    end

    if TeamMgr:getLeaderId() == Me:getId() and TeamMgr:inTeam(map.id) and not Me:isPassiveMode() then
        -- 对象在队伍中，不对其数据进行处理，被动模式下要处理接受到的数据
        return
    end

    local char = self:getChar(map.id)
    if not char then
        return
    end

    if self.guoQingJieSoldiers[map.id] then
        -- 国庆节阅兵士兵站住后要调整朝向
        char.guoQingJieSoldiersDir = map.dir
    end

    local type = char:queryBasicInt('type')
    char:setBasic('x', map.x)
    char:setBasic('y', map.y)

    local leaderId = 0
    if type == OBJECT_TYPE.PET or type == OBJECT_TYPE.FOLLOW_NPC or type == OBJECT_TYPE.GUARD 
        or type == OBJECT_TYPE.CHILD then
        leaderId = char:queryBasicInt('owner_id')
    elseif Me:getId() == TeamMgr:getLeaderId() and TeamMgr:inTeam(map.id) then
        leaderId = Me:getId()
    end

    if not (leaderId == Me:getId() and Me:isControlMove()) then
        -- 收到了自己附属对象移动的消息，目前人物自己控制移动，忽略服务器对自己附属对象的移动确认
        char:updateDestination(map.x, map.y)
    end
end

-- 角色不再视野内
function CharMgr:MSG_DISAPPEAR(map)
    if self:isBusy(map.id) and not map.busyness then
        self:addBusyness(map.id, "GBusynessDisappear", map, nil)
        return
    end

    if map.type == OBJECT_TYPE.CHAR then
        self:clearPetOwner(map.id)
    end

    if map.type == OBJECT_TYPE.FOLLOW_NPC then
        local char = self:getChar(map.id)
        if char and char:queryBasicInt("owner_id") == Me:queryBasicInt("id") then
            local x = Me:queryBasic("x")
            local y = Me:queryBasic("y")
            gf:CmdToServer('CMD_SHIFT', { id = map.id, x = x, y = y, dir = 0 })
        end
    end

    if ActivityHelperMgr:isShntmMonster(map.id) then
        -- 守护南天门怪物的析构逻辑在 ActivityHelperMgr 中处理
    elseif Me:getId() ~= map.id then
        self:deleteChar(map.id)
    elseif map.type == OBJECT_TYPE.NPC then
        Me:setTalkId(0)
    end
end

-- 刷新 title
function CharMgr:MSG_TITLE(map)
    local char = self:getChar(map.id)
    if not char then
        return
    end

    char:refreshTitle(map)
end

function CharMgr:MSG_UPDATE_APPEARANCE(map)
    local char = self:getChar(map.id)
    if not char then
        return
    end

    -- 设置透明度
    char.middleLayer:setCascadeOpacityEnabled(true)
    char.middleLayer:setOpacity((100 - map.opacity) / 100 * 255)

    -- 设置速度
    char:setSeepPrecent(map.moveSpeedPercent)

    -- 根据status设置下action
    if char:queryBasicInt("status") ~= map.status then
        self:setCharActByStauts(char, map.status, map)
    end

    local toRemoves = self:getNeedRemoveLightEffect(map)

    char:absorbBasicFields(map)
    char:addShadow()

    -- 处理玩家的隐藏状态
    self:doCharHideStatus(char)

    -- 附加的额外光效
    if not MapMgr:isInYuLuXianChi() then
        for i = 1, map.light_effect_count do
            if map.light_effect[i] then
                CharMgr:MSG_PLAY_LIGHT_EFFECT({charId = map.id, effectIcon = map.light_effect[i]})
            end
        end
    end

    -- 删除不需要的附加光效
    if toRemoves then
        for i = 1, #toRemoves do
            if char and toRemoves[i] then
                char:deleteMagic(toRemoves[i])
                end
            end
        end
end

function CharMgr:MSG_UPDATE_APPEARANCE_FIELDS(map)
    local char = self:getChar(map.id)
    if not char then
        return
    end

    char:absorbBasicFields(map)
end

function CharMgr:MSG_RELOCATE(data)
    local char = self:getChar(data.id)
    if not char then
        return
    end

    local x, y = gf:convertToClientSpace(data.x, data.y)
    char:setLastMapPos(data.x, data.y)
    char:setPos(x, y)
    char:setAct(Const.SA_STAND)
    char:setDir(data.dir)
end

function CharMgr:getChengwei(rank)
    local rankTable = ChengWeiColor[rank]

    if rankTable  then
        return rankTable
    end
end

-- 根据charType获取名称颜色
function CharMgr:getNameColorByType(type, isVip, rank, deepVipColor)
    if type == OBJECT_TYPE.CHAR then
        if not isVip or isVip == 0 then
            return COLOR3.CHAR_GREEN
        else
            if deepVipColor then
                return COLOR3.CHAR_VIP_BLUE_EX
            else
            return COLOR3.CHAR_VIP_BLUE
        end
        end
    elseif type == OBJECT_TYPE.GUARD then  -- 如果角色是守卫:根据守卫品质决定名字颜色
        if rank == GUARD_RANK.TONGZI then
            return COLOR3.BLUE
        elseif rank == GUARD_RANK.ZHANGLAO then
            return COLOR3.PURPLE
        elseif rank == GUARD_RANK.SHENLING then
            return COLOR3.YELLOW
        else
            Log:W("Guard quality not matched!")
            return COLOR3.GREEN
        end
    elseif type == OBJECT_TYPE.PET or type == OBJECT_TYPE.FOLLOW_NPC or type == OBJECT_TYPE.MONSTER or type == OBJECT_TYPE.CHILD then
        return COLOR3.PET_MONSTER_YELLOW
    elseif type == OBJECT_TYPE.NPC or type == OBJECT_TYPE.SPECIAL_NPC  or type == OBJECT_TYPE.GATHER_NPC or type == OBJECT_TYPE.MOVE_NPC then
        return COLOR3.NPC_YELLOW
    else
        return COLOR3.WHITE
    end
end

-- 播放光效
function CharMgr:playLightEffect(char, data)
    if nil == char then
        return
    end

    -- 获取光效时需要进行转换
    -- 目前是因为仙魔光效在真身/元婴(血婴)状态下需要播放不同的光效
    -- 服务器发送过来的光效编号都是一样的，此处进行转换
    local effect = LightEffect[gf:tryConvertMagicKey(data.effectIcon, char:getIcon())]

    if effect == nil then
        Log:W(data.effectIcon.." is no config in LightEffect.lua")
        return
    end

    if effect.follow_dis then
        -- 跟随移动的动画
        if not char.followMagic then char.followMagic = {} end
        char.followMagic[data.effectIcon] = { effect = data.effectIcon, pos = cc.p(char.curX, char.curY), follow_dis = effect.follow_dis }
        return
    end

    char:playLightEffect(effect, data)
end

-- 停止光效
function CharMgr:stopLightEffect(char, data)
    local effect = LightEffect[data.effectIcon]

    if not effect then
        Log:W(data.effectIcon.." is no config in LightEffect.lua")
        return
    end

    if effect.magicKey then
        char:deleteMagic(data.effectIcon)
    end
end

function CharMgr:MSG_UPDATE(map)

    print("CharMgr befor:", Me:queryBasic("party/name") or "nil", map["party/name"] or nil)
    -- 由于支持部分字段更新的对象只有宠物和Me，如果要扩展请在下面逻辑扩展。
    local pet = PetMgr:getPetById(map.id)

    if pet then
        pet:absorbBasicFields(map)
    else
        local preDoubles = GetTaoMgr:getAllDoublePoint()
        local preJiji = GetTaoMgr:getAllJijiPoint()
        local preCFS = GetTaoMgr:getPetFengSanPoint()
        local preZQHM = GetTaoMgr:getAllZiQiHongMengPoint()

        -- Me.realId有值的时候，证明Me处于监听别人状态，不更新Me原来信息
        if map.id ~= Me.realId then
            Me:startWaitData()
            EventDispatcher:dispatchEvent("MSG_UPDATE", map)
            if self.chars[Me:getId()] and map.id ~= Me:getId() then
                if not map["passive_mode"] and not DebugMgr:isRunning() then
                    gf:ftpUploadEx(string.format("invalid id(%s) for me(%s)", map.id, Me:getId()))
                end
                map.id = nil    -- 此处无需更新
            end
            Me:absorbBasicFields(map)
            Me:updateAfterLoadAction()
        else
            -- 有些字段在监听状态下也必须更新
            Me:startWaitData()
            Me:absorbBasicFields({static_mode = map["static_mode"]})
            if map["static_mode"] == 0 then Me.realId = nil end
            Me:updateAfterLoadAction()
        end

        if GetTaoMgr:checkOfflineIsOn() then
            -- 急急如律令、宠风散、双倍任意一条满足，需要给小红点 by songcw
            -- 消耗前 （ 设置消耗的点数  < 玩家拥有的点数 ）     and    消耗后  （设置消耗的点数 >= 玩家拥有的点数）
            -- pointName,例如双倍为 double_points，          prePoint更新前的值             设置的消耗点数
            local function isMeetTrigger(pointName, prePoint, setPoint, openState)
                if openState == 1 and map[pointName] and map[pointName] < prePoint and setPoint <= prePoint and setPoint > map[pointName] then
                    return true
                end
                return false
            end

            if isMeetTrigger("double_points", preDoubles, GetTaoMgr:getMyDoublePoint(), GetTaoMgr:getOffLineCostStatus(1))
                or isMeetTrigger("shuadao/jiji-rulvling", preJiji, GetTaoMgr:getMyJiji(), GetTaoMgr:getOffLineCostStatus(2))
                or isMeetTrigger("shuadao/chongfeng-san", preCFS, GetTaoMgr:getMyChongFengSan(), GetTaoMgr:getOffLineCostStatus(3))
                or isMeetTrigger("shuadao/ziqihongmeng", preZQHM, GetTaoMgr:getMyZiQiHongMeng(), GetTaoMgr:getOffLineCostStatus(4)) then
                RedDotMgr:addShuaDaoRedDot()
            end
        end

        -- 检查语音按钮
        ChatMgr:noticeVoiceBtn()
    end

    -- 判断是否处于监听状态
    if GMMgr:isGM() then
        --  如果是GM
        if GMMgr:isStaticMode() then
            -- 处于监听状态
            if not DlgMgr:getDlgByName("GMStopMonitoringDlg") then
                DlgMgr:openDlg("GMStopMonitoringDlg")
            end
        else
            if DlgMgr:getDlgByName("GMStopMonitoringDlg") then
                DlgMgr:closeDlg("GMStopMonitoringDlg")
            end
        end
    end
    print("CharMgr:", Me:queryBasic("party/name"))
end

-- 播放角色光效
function CharMgr:MSG_PLAY_LIGHT_EFFECT(data, destChar)
    local char = destChar or CharMgr:getChar(data.charId)
    if nil == char then
        Log:D("Not found object by CharMgr:getChar " .. (data.charId or 0))
        return
    end

    self:playLightEffect(char, data)
end

function CharMgr:MSG_STOP_LIGHT_EFFECT(data)
    local char = CharMgr:getChar(data.charId)

    if char then
        self:stopLightEffect(char, data)
        end
end

function CharMgr:MSG_SEND_RECOMMEND_ATTRIB(data)
    -- 无需处理
end

function CharMgr:MSG_PRE_ASSIGN_ATTRIB(data)
    -- 无需处理
end

-- 查看装备
function CharMgr:MSG_LOOK_PLAYER_EQUIP(data)
    local dlg = DlgMgr:openDlg("SeeEquipmentDlg")
    dlg:setData(data)
end

-- 打开npc对话
function CharMgr:openNpcDlg(npcId)
    Me:sendAllLeftMoves() -- 同步位置

    if AutoWalkMgr:getMessageIndex() then
        gf:CmdToServer("CMD_OPEN_MENU", { id = npcId, type = 0})
    else
        gf:CmdToServer("CMD_OPEN_MENU", { id = npcId, type = 1 })
    end

    Me:setTalkWithNpc(true)
end

-- 与采集npc对话
function CharMgr:talkToGatherNpc(char)
    if char:isCanGather() then
        AutoWalkMgr:cleanup()
        Me:sendAllLeftMoves() -- 同步位置

        -- 某些采集物采集之前需要先向服务器进行确认，服务器决定后续操作
        local confirmBeforeGather = char:needConfirmBeforeGather()
        if confirmBeforeGather then
            gf:CmdToServer("CMD_GATHER_UP", {id = char:getId(), para = 1})
        else
            gf:CmdToServer("CMD_GATHER_UP", {id = char:getId(), para = 0 })
    end
    end
end

-- 设置使用金钱还是代金券
function CharMgr:setUseMoneyType(type)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SET_USE_MONEY_TYPE, type)
end

-- 获取角色加载队列
function CharMgr:getLoadCharList()
    return CharLoadList
end


function CharMgr:canLoadPlayer(char)
    if not char:checkHasLoadTexture() then
        if AutoWalkMgr.autoWalk or Me:isWalkAction() then
            return false
        end

        if Me.bReadyMove then
            return false
        end

        if Me:isTeamMember() then
            if DlgMgr:isDlgOpened("LoadingDlg") then
                return false
            end

            if Me.lastWalkOrLoadMapTime and gfGetTickCount() - Me.lastWalkOrLoadMapTime < 1500 then
                return false
            end

            local char = self:getCharById(TeamMgr:getLeaderId())
            if char and char:isWalkAction() then
                return false
            end
        end
    end

    return true
end

-- 往角色加载队列后添加一个角色
function CharMgr:pushOneToLoadCharList(data)
    if (data.type == OBJECT_TYPE.CHAR
        or data.type == OBJECT_TYPE.PET
        or data.type == OBJECT_TYPE.FOLLOW_NPC)
        and not TeamMgr:inTeamEx(data.id) then
        PlayerCharLoadList:pushBack(data)
    else
    CharLoadList:pushBack(data)
    end
end

-- 从角色加载队列前获取一个角色
function CharMgr:popLoadCharListFront()
    if not self.loadCharTimestamp then
        self.loadCharTimestamp = {}
    end

    if not self.needLoadWhenMeStand then
        self.needLoadWhenMeStand = {}
    end

    local data = nil
    repeat
        if CharLoadList:size() > 0 then
            data = CharLoadList:popFront()
        elseif PlayerCharLoadList:size() > 0 then
           repeat
                data = PlayerCharLoadList:popFront()

                local char = self:getCharById(data.id)
                local canLoad = char and self:canLoadPlayer(char)

                if char and not canLoad then
                    table.insert(self.needLoadWhenMeStand, data)
                    data = nil
                end


                if PlayerCharLoadList:size() == 0 or canLoad then
                    break
                end
           until false
        else
            break
        end

        if data and (not self.loadCharTimestamp[data.id] or data.timestamp >= self.loadCharTimestamp[data.id]) then
            -- 队员数据可能同时存在于 PlayerCharLoadList 和 CharLoadList 中
            -- 由于两边的加载机制不一样，可能导致较新的队员数据先加载，再加载旧的队员数据，故此处已时间戳判断是否旧数据
            self.loadCharTimestamp[data.id] = data.timestamp
            break
        else
            data = nil
        end
    until false

    return data
end

-- 获取角色加载队列的大小
function CharMgr:getLoadCharListSize()
    return CharLoadList:size() + PlayerCharLoadList:size()
end

-- 清除所有加载队列
function CharMgr:clearLoadCharListSize()
    CharLoadList = List.new()
    PlayerCharLoadList = List.new()
    self.loadCharTimestamp = nil
    self.needLoadWhenMeStand = nil
end

-- 获取多少帧加载一个模型
function CharMgr:getMaxFrameForLoad()
    if GAME_EFFECT.HIGH == SystemSettingMgr:getSettingStatus("sight_scope") then
        return 5
    else
        return 3
    end
end

-- 获取一帧需要加载的队列
function CharMgr:getLoadCharsOneFPS()
    if not self.frameCounterForLoad then
        self.frameCounterForLoad = 0
    end

    self.frameCounterForLoad = self.frameCounterForLoad + 1

    if 0 == self:getLoadCharListSize() then
        return {}
    end

    local arr = {}
    if self.frameCounterForLoad >= self:getMaxFrameForLoad() then
        self.frameCounterForLoad = 0
        table.insert(arr, self:popLoadCharListFront())
    end

    return arr
end

-- 加载更新角色
function CharMgr:loadCharsOneFPS()
    local charsData = self:getLoadCharsOneFPS()

    for i = 1, #charsData do
        self:loadChar(charsData[i])
    end

    if not Me:isWalkAction() and self.needLoadWhenMeStand then
        for i = 1, #self.needLoadWhenMeStand do
            if not self.needLoadWhenMeStand[i].isDelete then
                self:pushOneToLoadCharList(self.needLoadWhenMeStand[i])
            end
        end

        self.needLoadWhenMeStand = nil
    end
end

-- 先将数据存储起来,不显示
function CharMgr:loadCharData(map)
    if nil == map then return end

    self:checkPos(map.x, map.y)
    self:checkDir(map.dir)

    local char = self:getChar(map.id)
    if char then
        if self:isBusy(map.id) and not map.busyness then
            self:addBusyness(map.id, "GBusynessAppear", map, nil)
            return
        end
    else
        if map.type == OBJECT_TYPE.ITEM or map.type == OBJECT_TYPE.GUARD then
            return
        elseif map.type == OBJECT_TYPE.CHAR then
            -- 玩家
            if Me:getId() == map.id then
                -- me 出现了
                char = Me
            else
                char = require("obj/Player").new(map.x, map.y)
                -- 设置好友标记 todo
            end

            local pet = self:getPet(map.id)
            if pet then
                pet:setOwner(char)
                char:setBasic("pet_id", pet:getId())
            end
        elseif map.type == OBJECT_TYPE.PET then
            -- 宠物
            local sub_type = map.sub_type
            if OBJECT_PET_TYPE.TYPE_FLY == sub_type then
                char = require("obj/FollowElf").new(map.x, map.y)
            elseif OBJECT_PET_TYPE.TYPE_RUN == sub_type then
                char = require("obj/FollowSprite").new(map.x, map.y)
            else
                char = require("obj/Pet").new(map.x, map.y)
            end
            local owner = self:getChar(map.owner_id)
            if owner then
                char:setOwner(owner)
                owner:setBasic("pet_id", map.id)
            end
        elseif map.type == OBJECT_TYPE.FOLLOW_NPC then
            -- 跟随NPC
            local sub_type = map.sub_type
            if OBJECT_NPC_TYPE.TM_FOLLOW_NPC == sub_type then
                char = require("obj/TMFollowNpc").new(map.x, map.y)
            else
                char = require("obj/FollowNpc").new(map.x, map.y)
            end

            local owner = self:getChar(map.owner_id)
            if owner then
                char:setOwner(owner)
                owner:setBasic("pet_id", map.id)
            end
        elseif map.type == OBJECT_TYPE.NPC or map.type == OBJECT_TYPE.SPECIAL_NPC or map.type == OBJECT_TYPE.SHINVTU_NPC then
            local sub_type = map.sub_type
            if OBJECT_NPC_TYPE.CHILD_NPC == sub_type then
                char = require('obj/ChildNpc').new(map.x, map.y)
            elseif OBJECT_NPC_TYPE.MAID_NPC == sub_type then
                char = require('obj/MaidNpc').new(map.x, map.y)
            elseif OBJECT_NPC_TYPE.LS_NPC == sub_type then
                char = require('obj/LSNpc').new(map.x, map.y)
            elseif OBJECT_NPC_TYPE.XHQ_NPC == sub_type then
                char = require('obj/XhqNpc').new(map.x, map.y)
            elseif OBJECT_NPC_TYPE.DWW_NPC == sub_type then
                char = require('obj/DwwNpc').new(map.x, map.y)
            elseif MapMgr:isInMapByName(CHS[7190182]) then
                -- 客栈中的npc走自己的逻辑
                char = require('obj/InnNpc').new(map.x, map.y)
            elseif OBJECT_NPC_TYPE.ZJYB_NPC == sub_type then
                -- 真假月饼 npc
                char = require('obj/ZjybNpc').new(map.x, map.y)
            else
                -- 系统 NPC 或者是掌门 NPC
                char = require('obj/Npc').new(map.x, map.y)
            end
        elseif map.type == OBJECT_TYPE.MONSTER then
            -- 怪物
            char = require('obj/Monster').new(map.x, map.y)
        elseif map.type == OBJECT_TYPE.GATHER_NPC then
            char = require('obj/GatherNpc').new(map.x, map.y)
        elseif map.type == OBJECT_TYPE.MOVE_NPC then
            char = require('obj/MoveNpc').new(map.x, map.y)
        elseif map.type == OBJECT_TYPE.QT_NPC then
            char = require('obj/QTNpc').new(map.x, map.y)
        elseif map.type == OBJECT_TYPE.INN_GUEST then
            char = require('obj/InnGuest').new(map.x, map.y)
        elseif map.type == OBJECT_TYPE.CHILD then
            -- 娃娃在场景里的表现与跟随宠物类似
            char = require('obj/FollowSprite').new(map.x, map.y)
            local owner = self:getChar(map.owner_id)
            if owner then
                char:setOwner(owner)
                owner:setBasic("pet_id", map.id)
            end
        else
            Log:W("Unkown object type: " .. map.type)
            return
        end
    end

    if not char then
        Log:W("char is nil")
        return
    end

    self.chars[map.id] = char

    self:doSomeWhenLoadCharData(map)

    -- 需要先隐藏
    char:setVisible(false)

    -- 然后设置数据
    char:absorbBasicFields(map)

    char:setSeepPrecent(map.moveSpeedPercent)

    if char:getId() == Me:getId() then
        -- Me需要立即加载
        self:loadChar(map)
    end

    self:doWhenLoadChar(char, map)

    if char:queryBasicInt("status") == Const.NS_YB_STATUS then
        -- 国庆节阅兵中的士兵
        self.guoQingJieSoldiers[map.id] = char
        char.guoQingJieSoldiersDir = map.dir
    end

    return char
end

function CharMgr:doSomeWhenLoadCharData(map)
    if MapMgr:isInBaiHuaCongzhong() and map.type == OBJECT_TYPE.CHAR then
        -- 百花丛中的角色不显示坐骑及婚服
        map.notShowRidePet = 1
        map.notShowHunfu = 1
    else
        map.notShowRidePet = 0
        map.notShowHunfu = 0
    end

    if map.status == Const.NS_NOTTURN then
        -- 不可转向
        map.isFixDir = 1
    end
end

-- 加载出现的东西
function CharMgr:loadChar(map)
    if nil == map then return end

    -- 获取角色，确保角色已经被创建
    local char = self:getChar(map.id)
    if nil == char then return end

    -- 根据status设置下action
    local isSetAct = self:setCharActByStauts(char, char:queryBasicInt("status"))
    if not isSetAct then
        -- 角色站立
        char:setAct(Const.FA_STAND)
    end

    if char.toPlayMagic then
        -- 有光效需要处理
        for _, v in pairs(char.toPlayMagic) do
            CharMgr:MSG_PLAY_LIGHT_EFFECT(v)
        end
        char.toPlayMagic = nil
    end

    -- 观战或者战斗需要隐藏人物
    self:doCharHideStatus(char)

    -- 角色出现需要一些特殊的动作
    --[[if map.specialActionId and map.specialActionId ~= 0 then
        char:doSomeSpecialAction(map.specialActionId)
        char:setVisible(false)
    end]]
end

-- 处理对象的隐藏操作(所有对象Me+其他场景对象)
function CharMgr:doAllCharHideStatus(char)
    if char:isGather() and char:isShowRidePet() then
        char:setVisible(false)
    else
        char:setVisible(true)
    end
end

-- 处理玩家隐藏操作(非Me对象)
function CharMgr:doCharHideStatus(char)
    -- 观战或者战斗需要隐藏人物
    if self:isNeedHideChar(char:getId(), char:queryBasicInt("isHide") == 1 or char:queryBasicInt("status") == Const.NS_A_YINSHEN) then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("VacationSnowDlg") and char:queryInt("is2018HJ_DXZ") ~= 1 then
        -- 2018寒假活动需要隐藏
    elseif DlgMgr:getDlgByName("VacationPersimmonDlg") and char:queryInt("is2018HJ_DSZ") ~= 1 then
        -- 2018寒假冻柿子活动需要显示的模型
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("VacationTempDlg") and char:queryInt("is2018SJ_YSGW") ~= 1 then
        -- 2018暑假元神归位活动需要隐藏
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("WatermelonRaceDlg") and char:queryInt("is2018SJ_SNCG") ~= 1 and char:getName() ~= CHS[5450174] then
        -- 2018暑假谁能吃瓜活动需要隐藏
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("ControlDlg") and char:getName() ~= CHS[5410261] and char:getName() ~= CHS[5410262] and char:queryBasicInt("sub_type") ~= OBJECT_NPC_TYPE.XHQ_NPC then
        -- 2018暑假寒气之脉
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("CaseRunGameDlg") and (char:getType() == "Player" or char:queryBasicInt("type") == OBJECT_TYPE.PET or char:queryBasicInt("type") == OBJECT_TYPE.FOLLOW_NPC) and char:getId() ~= Me:getId() then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("LingyzmDlg") and char:getId() ~= Me:getId() and char:getName() ~= CHS[3000823] then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("ChangyjjDlg") then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("NewYearGuardDlg") and char:getType() ~= "BwswzNpc" and char:getId() ~= Me:getId() then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("NoneDlg") and char:getType() ~= "TttSmfjNpc" then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("SpeclalRoomStrollDlg") and char:getType() ~= "TttSmfjNpc" then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("SpeclalRoomDanceDlg") and char:getType() ~= "TttSmfjNpc" then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("SpeclalRoomConvertDlg") and char:getType() ~= "TttSmfjNpc" then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("SpeclalRoomEatDlg") and char:getType() ~= "TttSmfjNpc" and char:getType() ~= OBJECT_NPC_TYPE.DWW_NPC then
      --  gf:ShowSmallTips(char:queryBasic("name"))
        char:setVisible(false)
    elseif MapMgr:isInMapByName(CHS[4010293]) and CharMgr:getCharByName(CHS[4010302]) then

        if CharMgr:getCharByName(CHS[4010302]) and char:queryBasic("name") == CHS[4200636] then
            char:setVisible(false)
        else
            char:setVisible(true)
        end
    elseif YuanXiaoMgr:isNeedHideChar(char) then
        -- 元宵节舞龙要隐藏其旁边距离不超过 4 格的角色
        char:setVisible(false)
elseif MapMgr:isInDragMap() and (char:getType() ~= OBJECT_TYPE.INN_GUEST and char:getType() ~= "InnNpc"
    and char:getType() ~= OBJECT_NPC_TYPE.DWW_NPC) then
    -- 拖动类型地图，客栈客人/npc 之外的对象都隐藏
    char:setVisible(false)
    elseif char:getType() == OBJECT_TYPE.INN_GUEST then
        -- 客栈中的客人显示与隐藏自己控制
        char:setVisible(char.isVisible)
    elseif TanAnMgr:isNeedHideChar(char) then
        -- 【探案】江湖绿林
        char:setVisible(false)
    elseif InnMgr:isNeedHideChar(char) then
        -- 2018 中秋大胃王
        char:setVisible(false)
    elseif char:getType() == "ZjybNpc" and not char.isStartCircleWalk then
        char:setVisible(false)
    elseif ActivityMgr.sxys2019NpcId then
        -- 隐藏非自己所有角色
        if char:getType() == "Player" and char:queryBasicInt("id") ~= Me:getId() then
            char:setVisible(false)
        end

        -- 隐藏非自己的跟随宠物、跟随精灵都要隐藏
        if char:queryBasicInt("owner_id") ~= 0 and char:queryBasicInt("owner_id") ~= Me:getId() then
            char:setVisible(false)
        end
    elseif DlgMgr:getDlgByName("VacationWhiteDlg") then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("ShengxdjDlg") and char:getType() ~= "SxdjNpc" then
        char:setVisible(false)
    elseif ActivityHelperMgr:isInBhkySummer2019() and char:getType() ~= "Npc" and char:getId() ~= Me:getId() then
        char:setVisible(false)
    elseif MapMgr:isInYuLuXianChi() and char:getType() ~= "Player" and char:getType() ~= "Npc" then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("LangmqgDlg") then
        char:setVisible(false)
    elseif DlgMgr:getDlgByName("ChildDailyMission2Dlg") then
        if char:getType() ~= "ChildCyzNpc" then
            char:setVisible(false)
        end
    elseif DlgMgr:getDlgByName("ChildDailyMission3Dlg") then
        if char:getType() ~= "ChildDwdpyNpc" then
            char:setVisible(false)
        end
    elseif DlgMgr:getDlgByName("ChildDailyMission5Dlg") then
        if char:getType() ~= "ChildDwdpyNpc" then
            char:setVisible(false)
        end
    elseif DlgMgr:getDlgByName("ChildDailyMission1Dlg")  then
        char:setVisible(false)
    else
        self:doAllCharHideStatus(char)
    end
end

-- 切换人物动作
function CharMgr:setCharActByStauts(char, status, map)
    if not status or not char then return end
    local act = nil
    local id = char:getId()
    self.actionStatusInfo[id] = nil
    if status == Const.NS_ALIVE then
        if char.faAct ~= Const.FA_WALK and char.faAct ~= Const.FA_STAND then
            act = Const.FA_STAND
        end
    elseif status == Const.NS_DEAD then
        act = Const.FA_DIED

        -- 播放死亡动作，一般死亡状态的npc不允许改变方向，但如果一开始服务器发过来的数据
        -- 就是死亡状态并且有方向，那还是以服务器的数据为准
        if not char.dir then
            local dir = char:queryBasicInt('dir')
            char:setDir(dir)
        end
    elseif status == Const.NS_SNUGGLE then
        act = Const.FA_SNUGGLE
    elseif status == Const.NS_SHOW then
        act = Const.FA_SHOW_BEGIN
    elseif status == Const.NS_ATTACK then
        act = Const.FA_PHYSICAL_ATTACK_LOOP
    elseif status == Const.NS_DEFENSE then
         act = Const.FA_DEFENSE_LOOP
    elseif STATUS_ACTION[status] then
        self.actionStatusInfo[id] = STATUS_ACTION[status]
        act = STATUS_ACTION[status].act
    elseif char:getIcon() == 42101 then -- 新郎才这些动作
        if status == Const.NS_BAIBAI then
            act = Const.FA_BAIBAI
        elseif status == Const.NS_QINQIN then
            act = Const.FA_QINQIN
        elseif status == Const.NS_BAOBAO then
            act = Const.FA_YONGBAO
        elseif status == Const.NS_JIAOBEI then
            act = Const.FA_JIAOBEI
        end
    elseif status == Const.NS_EAT_STATUS then
        act = Const.FA_EAT_LOOP
    elseif status == Const.NS_SIT_STATUS then
        act = Const.FA_SIT_LOOP
    end

    if STATUS_ACTION[status] or status == Const.NS_A_YINSHEN then
        if not Me:isTeamLeader() then
            -- 强制拉到目的地播放动作
            local x, y = map and map["x"] or char:queryBasicInt("x"), map and map["y"] or char:queryBasicInt("y")
            char:setPos(gf:convertToClientSpace(x, y))
            char:setLastMapPos(x, y)

            -- 防止再次走动
            char.bReadyMove = false
            char:resetGotoEndPos()

            if status == Const.NS_A_YINSHEN then
                char:setAct(Const.FA_STAND)
            end
        end
    end

    if act then
        char:setAct(act)
    end

    return act
end

-- 设置隐藏除了  excepts 中的角色对象
function CharMgr:setNeedHideCharExcepts(excepts)
    self.needHideExcepts = excepts
end

-- 需要隐藏角色的条件
function CharMgr:isNeedHideChar(charId, isHide)
    local needHideChar = false
	if Me:isInCombat() or Me:isLookOn() then
	   needHideChar = true
    elseif Me:isInJail() and MapMgr:getCurrentMapName() == CHS[3003934] and charId  ~= Me:getId() then
	    needHideChar = true
	elseif isHide then
        needHideChar = true
	end

	if HomeMgr.playSleepInHome then
        needHideChar = true
	end

    if HomeChildMgr.playSleepInHome == charId then
        needHideChar = true
    end

    if self.needHideExcepts and not self.needHideExcepts[charId] then
        needHideChar = true
    end

    local char = self:getChar(charId)

    if char and char:queryBasicInt("owner_id") == HomeChildMgr.playSleepInHome then
        needHideChar = true
    end

    if char
        and char:getType() == "Player"
        and charId ~= Me:getId()
        and not TeamMgr:inTeam(charId) then
        -- 国庆节阅兵检测玩家是否在阅兵 NPC 形象 5 格范围内，是则隐藏非自己或非自己所在队伍的角色的形象
        local x, y = gf:convertToMapSpace(char.curX, char.curY)
        for k, v in pairs(self.guoQingJieSoldiers) do
            local charPos = cc.p(gf:convertToMapSpace(v.curX, v.curY))
            if charId ~= v:getId() and math.abs(x - charPos.x) < 5 and math.abs(y - charPos.y) < 5 then
                needHideChar = true
                break
            end
        end
    end

	return needHideChar
end

-- 在加载角色的时候处理的事务
function CharMgr:doWhenLoadChar(char, map)
    if nil == char then return end

    char:onEnterScene(map.x, map.y)
    char:setPos(gf:convertToClientSpace(map.x, map.y))

    if self.npcList == nil then
        self.npcList = {}
    end

    if map.type == OBJECT_TYPE.NPC or map.type == OBJECT_TYPE.MONSTER or map.type == OBJECT_TYPE.SPECIAL_NPC  or map.type == OBJECT_TYPE.GATHER_NPC then
        self.npcList[map.id] = char

        -- npc出现 根据朝向调整对话位置
        local destNpc = AutoWalkMgr.autoWalk
        if destNpc and gf:inOffset(Me:queryBasicInt("x"), Me:queryBasicInt("y"), char.lastMapPosX, char.lastMapPosY, 6) then
            if char.lastMapPosX == destNpc.rawX and char.lastMapPosY == destNpc.rawY and self:isEqualName(char:getName(), destNpc.npc) and not destNpc.checkDir then
                AutoWalkMgr.autoWalk.x = char.lastMapPosX
                AutoWalkMgr.autoWalk.y = char.lastMapPosY
                AutoWalkMgr.autoWalk.checkDir = true    -- 标记一下已经根据APPERA的方向寻路了
                AutoWalkMgr:continueAutoWalk()
            end
        end
    elseif map.type == OBJECT_TYPE.CHAR then
        if char:inMeTeam() then
            -- 队员出现了
            -- 由于客户端会缓存行走信息，为了不让队员一直被拉，故将队员的位置设置为队长移动命令中间的坐标
            -- 并让队员走到队长要去的位置
            char:setPos(Me:getMiddlePosFromMoveCmd())

            -- 需要进行设置lastMapPos不然，会出现队员卡在某个位置原地踏步
            char:setLastMapPos(gf:convertToMapSpace(char.curX, char.curY))

            if nil ~= Me.endX and nil ~= Me.endY then
                char:setEndPos(gf:convertToMapSpace(Me.endX, Me.endY))
            end
        end
    end
end

-- 获取对应点上的玩家
function CharMgr:getCharsByPos(pos)
    local chars = {}
    for k, char in pairs(self.chars) do
        local charPos = cc.p(gf:convertToMapSpace(char.curX, char.curY))
        if pos.x == charPos.x and pos.y == charPos.y then
            table.insert(chars, char)
        end
    end

    return chars
end

-- 设置光效方向，初始方向 1
function CharMgr:getCouple()
    local gid = Me:queryBasic("marriage/couple_gid")
    for k, char in pairs(self.chars) do
        if char:queryBasic("gid") == gid then
            return char
        end
    end
end

function CharMgr:MSG_GATHER(data)
    local char = self:getChar(data.id)
    if nil == char or (char:getType() ~= "GatherNpc") then return end

    char:setGatherStatus(data.status)
end


-- 清除消息
function CharMgr:MSG_CLEAR_ALL_CHAR(data)
    -- 收到Enter_room的消息直接进行清除操作
    CharMgr:clearAllChar()
end

-- 设置角色速度
function CharMgr:MSG_UPDATE_MOVE_SPEED(data)
    local char = self:getChar(data.id)
    if nil == char then return end

    char:setSeepPrecent(data.moveSpeedPercent)
end

-- 游戏效果设置
function CharMgr:OnSettingChanged(key, oldValue, newValue)
    if "sight_scope" ~= key then return end
    for _, v in pairs(self.chars) do
        if v then
            v:onAbsorbBasicFields()
            v:addShadow()
        end
    end
end

function CharMgr:onShelterChanged()
    for _, v in pairs(self.chars) do
        if v and 'function' == type(v.updateShelter) then
            local mapX, mapY = gf:convertToMapSpace(v.curX, v.curY)
            v:updateShelter(mapX, mapY)
        end
    end
end

function CharMgr:MSG_PARTY_ICON(data)
    local char = self:getChar(data.id)
    if not char then
        return
    end

    char:setBasic("party_icon", data.md5_value)
    local fileName = data.md5_value
    if string.isNilOrEmpty(fileName) then
        char:updateName()
        return
    end

    local filePath = ResMgr:getCustomPartyIconPath(fileName)
    if not cc.FileUtils:getInstance():isFileExist(filePath) then
        filePath = ResMgr:getPartyIconPath(fileName)
    end

    if not cc.FileUtils:getInstance():isFileExist(filePath) then
        self:requestPartyIcon(fileName)
    else
        char:updateName()
    end
end

-- 请求自定义图标
function CharMgr:requestPartyIcon(fileName)
    local curTime = gf:getServerTime()
    if not self.lastRequestIconTime[fileName] or curTime - self.lastRequestIconTime[fileName] > 10 then
        gf:CmdToServer('CMD_REQUEST_ICON', {["md5_value"] = fileName})
        self.lastRequestIconTime[fileName] = curTime
    end
end

function CharMgr:MSG_SEND_ICON(data)
    local md5_value = data.md5_value
    local file_data = data.file_data

    if not file_data then return end

    local filePath = string.format("%s/partyicon/%s.jpg", Const.WRITE_PATH, md5_value)
    gfWriteFile(filePath, file_data)

    for _, v in pairs(self.chars) do
        if v and v:queryBasic("party_icon") == md5_value then
            v:updateName()
        end
    end
end

function CharMgr:MSG_LIEREN_XIANJING(data)
    Me.isInLieRenXianJing = true

    -- 停止移动
    AutoWalkMgr:endRandomWalk()
    AutoWalkMgr:stopAutoWalk()

    performWithDelay(gf:getUILayer(), function ()
        Me.isInLieRenXianJing = false
    end, data.duration)
end

function CharMgr:MSG_ZUI_XIN_WU(data)
    Me.hasZuiXinWu = true
    DlgMgr:returnToMain()
    gf:creatCoverLayer()
    performWithDelay(gf:getUILayer(), function ()
        Me.hasZuiXinWu = false
    end, data.duration)
end

-- 用于判断 NPC 名字是否一样
-- 自动寻路时，查找 NPC，由于 MapInfo.lua 中配置的 NPC 名带了编号，
-- 而 NPC 对象的名称没有带编号，故另判别名是否相等
-- 判断本地配置的 npc 名与 npc 对象名是否一样时，要调用此方法。
function CharMgr:isEqualName(charName, destName, charAliasName)
    if charName == destName then
        return true
    else
        local npc = MapMgr:getCurMapNpcByName(destName)
        if npc and ((npc.alias and npc.alias == charName) or npc.name == charName or
            (charAliasName and charAliasName == npc.alias)) then
            return  true
        else
            return false
        end
    end
end

-- 新增和修改称谓配置
function CharMgr:MSG_NEW_APPELLATION_INFO(data)
    local appellation = {}

    if pcall(function() appellation = loadstring(data.str)() end) then
    end

    if type(appellation) ~= "table" then return end
    for key, value in pairs(appellation) do
        ChengWeiColor[key] = value
    end
end

-- 在一定时间内渐隐NPC
function CharMgr:fadeOutChar(id, time)
    local char = CharMgr:getChar(id)
    if char then
        char:fadeOut(time)
    end
end

function CharMgr:MSG_PLAY_CHAR_ACTION(data)
    local char = self:getChar(data.id)
    if not char or not char.charAction then
        return
    end

    if data.action == FIGHT_ACTION.CAST_MAGIC and char.charAction:haveAct(Const.SA_CAST) then
        local function callback(act)
            if act == Const.FA_ACTION_CAST_MAGIC then
                char:setAct(Const.FA_STAND)
            end
        end

        char:setEndActCallback(callback)
        char:setAct(Const.FA_ACTION_CAST_MAGIC)
    elseif data.action == FIGHT_ACTION.PHYSICAL_ATTACK and char.charAction:haveAct(Const.SA_ATTACK) then
        local function callback(act)
            if act == Const.FA_ACTION_PHYSICAL_ATTACK then
                char:setAct(Const.FA_STAND)
            end
        end

        char:setEndActCallback(callback)
        char:setAct(Const.FA_ACTION_PHYSICAL_ATTACK, nil, func)
    elseif data.action == FIGHT_ACTION.DEFENSE and char.charAction:haveAct(Const.SA_DEFENSE) then
        local function callback(act)
            if act == Const.FA_ACTION_DEFENSE then
                char:setAct(Const.FA_STAND)
            end
        end

        char:setEndActCallback(callback)
        char:setAct(Const.FA_ACTION_DEFENSE)
    elseif data.action == FIGHT_ACTION.DIE and char.charAction:haveAct(Const.SA_DIE) then
        char:setDieAction(data.loops)
    end
end

-- 设置光效方向，初始方向 1
function CharMgr:setMagicDir(dir, magic)
    if not magic then
        return
    end

    if dir == 1 then
        self:setMagicFlipped(magic, false, false)
    elseif dir == 3 then
        self:setMagicFlipped(magic, true, false)
    elseif dir == 5 then
        self:setMagicFlipped(magic, true, true)
    elseif dir == 7 then
        self:setMagicFlipped(magic, false, true)
    end
end

function CharMgr:setMagicFlipped(magic, isFlipX, isFlipY)
    local anchorPoint = magic:getAnchorPoint()
    local isFlippedX = magic:isFlippedX()
    local isFlippedY = magic:isFlippedY()
    if isFlippedX == isFlipX and isFlippedY == isFlipY then
        return
    end

    if isFlipX and isFlippedX ~= isFlipX then
        anchorPoint.x = 1 - anchorPoint.x
    end

    if isFlipY and isFlippedY ~= isFlipY then
        anchorPoint.y = 1 - anchorPoint.y
    end

    magic:setAnchorPoint(anchorPoint.x, anchorPoint.y)
    magic:setFlippedX(isFlipX)
    magic:setFlippedY(isFlipY)
end

function CharMgr:MSG_NATIONAL_TYCYB(data)
    local time = data.no_dalay == 1 and 0 or 0.5
    for _, char in pairs(self.guoQingJieSoldiers) do
        -- 停止行走时，调整士兵朝向
        local dir = char.guoQingJieSoldiersDir
        if dir then
            char:setDir(dir)

            -- 调整光效方向
            local magic = char.magics[self.soldiersEffect]
            if self.soldiersEffect == 4002 and magic then
                self:setMagicDir(dir, magic)
            end
        end
    end

    performWithDelay(gf:getUILayer(), function()
        -- 动作
        if data.action == FIGHT_ACTION.CAST_MAGIC then
            for _, char in pairs(self.guoQingJieSoldiers) do
                if char.charAction then
                    char.charAction:playActionOnce(nil, Const.SA_CAST)
                end
            end
        elseif data.action == FIGHT_ACTION.PHYSICAL_ATTACK then
            for _, char in pairs(self.guoQingJieSoldiers) do
                if char.charAction then
                    char.charAction:playActionOnce(nil, Const.SA_ATTACK)
                end
            end
        end
    end, time)


    if data.cast_effect > 0 then
        performWithDelay(gf:getUILayer(), function()
            for id, char in pairs(self.guoQingJieSoldiers) do
                self:MSG_PLAY_LIGHT_EFFECT({effectIcon = data.cast_effect, charId = id})
            end
        end, time)

        time = time + 0.05
    end

    local effectD4 = data.d4_effect
    if effectD4 > 0 then
        performWithDelay(gf:getUILayer(), function()
            for id, char in pairs(self.guoQingJieSoldiers) do
                local magic = char.magics[effectD4]
                if not magic then
                    -- 有光效的话不用再重复添加了
                    self:MSG_PLAY_LIGHT_EFFECT({effectIcon = effectD4, charId = id})

                    -- 调整光效方向
                    magic = char.magics[effectD4]
                    local dir = char.guoQingJieSoldiersDir
                    if dir and effectD4 == 4002 and magic then
                        self:setMagicDir(dir, magic)
                    end
                end
            end
        end, time)

        self.soldiersEffect = data.d4_effect
        time = time + 0.05
    end

    if data.speack_content ~= "" then
        -- 喊话
        performWithDelay(gf:getUILayer(), function()
            if data.speck_count > 0 then
                -- 指定士兵喊话
                for _, id in ipairs(data.speck_npc) do
                    local char = self.guoQingJieSoldiers[id]
                    if char then
                        char:setChat({time = gf:getServerTime(), show_time = 2.5, msg = data.speack_content})
                    end
                end
            else
                -- 所有士兵喊话
                for id, char in pairs(self.guoQingJieSoldiers) do
                    char:setChat({time = gf:getServerTime(), show_time = 2.5, msg = data.speack_content})
                end
            end

        end, time)
    end
end

function CharMgr:MSG_NATIONAL_TYCYB_END(data)
    self.hasEffectSoldiers = {}
    for id, char in pairs(self.guoQingJieSoldiers) do
        -- 国庆节阅兵，士兵离开前播放光效
        self.hasEffectSoldiers[id] = char
        local function callback()
            -- 遁术光效第一部分播完后回调，播放第二部分并析构对应的士兵对象
            local effect = LightEffect[ResMgr.magic.dunshu_end]
            local magic = gf:createSelfRemoveMagic(effect["icon"], effect["extraPara"])
            magic:setPosition(char.curX, char.curY)
            gf:getMapLayer():addChild(magic)

            self.hasEffectSoldiers[id] = nil

            self.npcList[id] = nil
            self.chars[id] = nil
            self.guoQingJieSoldiers[id] = nil
            char:cleanup()
        end

        local effect = LightEffect[ResMgr.magic.dunshu_start]
        char:addMagicOnFoot(effect["icon"], effect["behind"], false, effect["armatureType"], effect["extraPara"], callback)
    end
end

-- 设置光效方向，初始方向 1
function CharMgr:MSG_TYCYB_TURN_DIR(data)
    for i = 1, data.count do
        local npc = self:getChar(data[i].npc_id)
        if npc then
            local x, y = gf:convertToClientSpace(data[i].x, data[i].y)
            npc:setPos(x, y)
            npc:setDir(data[i].dir)
            npc.guoQingJieSoldiersDir = data[i].dir
        end
    end
end

function CharMgr:openCharMenuContentDlg(touch, clickObId)
    local playerList = {}
    local count = 0

    -- 如果在天牢中，就看不到其他人，也就没必要显示人物列表
    if Me:isInJail() then return end

    for _, v in pairs(CharMgr.chars) do
        local type = v:getType()
        if (type == "Player" and v ~= Me)
              or type == "Npc"
              or type == "MaidNpc"
              or type == "Monster"
              or type == "GatherNpc"
              or type == "TMFollowNpc" then
            if v.charAction and (v.visible or (v:queryBasicInt("share_mount_leader_id") ~= 0 and v:isShowRidePet())) and v:isCanTouch() then
                local isContainsTouchPos
                local charAction = v.charAction
                local driverId = v:queryBasicInt("share_mount_leader_id")
                if driverId ~= 0 and driverId ~= v:getId() then
                    local driverChar = self:getCharById(driverId)
                    if driverChar then
                        charAction = driverChar.charAction
                    end
                end
                if charAction and charAction.containsTouchPos then
                    isContainsTouchPos = charAction:containsTouchPos(touch)
                else
                    local pos = v.middleLayer:convertToNodeSpace(touch:getLocation())
                    local rect = v.charAction:getBoundingBox()
                    isContainsTouchPos = cc.rectContainsPoint(rect, pos)
                end

                if isContainsTouchPos then
                    -- 采集物，没有采集状态不出现在列表
                    if type == "GatherNpc" and not v:isCanGather() then
                        return
                    end

                    if type == "TMFollowNpc" then
                        v.order = 1
                    elseif type == "Npc" or type == "MaidNpc" then
                        v.order = 2
                    elseif type == "GatherNpc" and v:isCanGather() then
                        v.order = 3
                    elseif type == "Monster" then
                        v.order = 4
                    else
                        v.order = 5
                    end

                    if type == "Monster" and OUT_USER_LIST_NAME[v:getName()] then
                        -- 暑假2017追查内鬼，队伍中对象为怪物，不显示在列表中
                    elseif MapMgr:isInMapByName(CHS[4101241]) and type ~= "GatherNpc" then
                    else
                        table.insert(playerList, v)
                        count = count + 1
                    end
                end
            end
        end
    end

    -- 家具
    local curHouseId = HomeMgr:getHouseId()
    if curHouseId ~= 0 and not DlgMgr:isDlgOpened("HomePuttingDlg") then
        -- 布置界面打开时，点击功能型不弹出悬浮框
        local furnitures = HomeMgr:getCanClickFurniture()
        local function containsTouchPos(touch, v)
            local pos = v.image:getParent():convertTouchToNodeSpace(touch)
            local rect = v.image:getBoundingBox()
            local name = v:getName()
            local furnitureInfo = HomeMgr:getFurnitureInfo(name)
            if furnitureInfo.clickRect then
                -- 有自定义的点击响应区域
                rect = furnitureInfo.clickRect
            end

            if curHouseId ~= Me:queryBasic("house/id")
                and not furnitureInfo.otherCanClick then
                return false
            end

            return cc.rectContainsPoint(rect, pos)
        end

        for i = 1, #furnitures do
            if containsTouchPos(touch, furnitures[i]) and furnitures[i].visible then
                table.insert(playerList, furnitures[i])
                count = count + 1
                furnitures[i].order = 5
            end
        end
    end

    if count > 1 then
        if MapMgr:isInMapByName(CHS[4010025]) or DlgMgr:isDlgOpened("UseBarDlg") then
        -- 如果端午节采集仙粽子，在无名仙境， 点击怪物不响应
        elseif MapMgr:isInMapByName(CHS[4101241]) and DlgMgr:isDlgOpened("UseBarDlg") then
        else
            local dlg = DlgMgr:openDlg("UserListDlg")
            local function sort(l,r)
                if l.order < r.order then return true end
            end
            table.sort(playerList, function(l, r)  return sort(l,r)  end)
            local pos = touch:getLocation()
            dlg:setInfo(playerList, count, pos)
        end
        return true
    elseif 1 == count and (Me:getId() == clickObId) and (Me:isMountLeader() or Me:isGather()) then
        performWithDelay(Me.middleLayer, function()
            if Me.selectTarget then
                -- 移除上一个对象的光效
                Me.selectTarget:removeFocusMagic()
            end

            Me.selectTarget = playerList[1]
            playerList[1]:showTargetHeadDlg()
            Me.selectTarget = Me
            Me:addFocusMagic()
        end, 0)

        return true
    end
end

function CharMgr:MSG_PLAY_SCREEN_ANIMATE(data)
    if data.animate_name == "shuilzy_06" or data.animate_name == "shuilzy_08" then
        local char = self:getCharByName(CHS[5410202])
        if char then
            char:onAnimate(data)
        else
            gf:unfrozenScreen()
        end
    elseif data.animate_name == CHS[5400714] then
        local colorLayer = gf:frozenScreen(2000 , 0, 2000, true)
        local action = cc.Sequence:create(
            cc.FadeIn:create(1),
            cc.DelayTime:create(1),
            cc.FadeOut:create(1))

        colorLayer:runAction(action)
    end
end

-- 判断对象是否为2018劳动节锄强扶弱npc
function CharMgr:isCharInLabor(char)
    if MapMgr:isInShanZeiLaoChao() and char:getName() == CHS[7190151] then
        return true
    end

    return false
end

-- 获取2018劳动节锄强扶弱npc
function CharMgr:getLaborActivityNpcs()
    local ret = {}
    for _, v in pairs(self.chars) do
        if self:isCharInLabor(v) then
            -- 巡逻山贼
            table.insert(ret, v)
        end
    end

    return ret
end

-- 删除2018打雪战的char
function CharMgr:remove2018DXZ()
    self:deleteChar(1)
    self:deleteChar(2)
end

function CharMgr:MSG_DAXZ_CHAR_INFO(data)
    data.is2018HJ_DXZ = 1

    -- 服务器未调整方向、坐标，需要客户端配置
    local CHAR_DXZ_INFO = {
        [1] = {dir = 1, x = 43, y = 40},
        [2] = {dir = 5, x = 27, y = 32},
    }

    if data.name == Me:queryBasic("name") then
        data.dir = CHAR_DXZ_INFO[1].dir
        data.x = CHAR_DXZ_INFO[1].x
        data.y = CHAR_DXZ_INFO[1].y
        data.id = 1

        data.light_effect_count = 1
        data.light_effect = {ResMgr.magic.char_foot_eff1}

    else
        data.dir = CHAR_DXZ_INFO[2].dir
        data.x = CHAR_DXZ_INFO[2].x
        data.y = CHAR_DXZ_INFO[2].y
        data.id = 2

        data.light_effect_count = 1
        data.light_effect = {ResMgr.magic.char_foot_eff2}
    end

    self:MSG_APPEAR(data)
end

-- 设置光效方向，初始方向 1
function CharMgr:MSG_WINTER2018_DAXZ_CHAR_INFO(data)
    data.is2018HJ_DXZ = 1
    self:MSG_APPEAR(data)
end

function CharMgr:talkToMyTMNpc()
    for _, char in pairs(self.chars) do
        if char:getType() == "TMFollowNpc"
            and char.owner
            and char.owner:queryBasic("gid") == Me:queryBasic("gid") then
            char:onClickChar()
        end
    end
end

function CharMgr:getCharBasicPointCfgInt(key, act, cartoonInfo)
    act = act or Const.SA_STAND
    local action = gf:getActionStr(act)
    if action == nil then
        return 0
    end

    local info = cartoonInfo[action]
    if not info then
        return 0
    end

    if info[key .. "_0"] then
        return tonumber(info[key .. "_0"])
    end

    if info[key] then
        return tonumber(info[key])
    end

    return 0
end


function CharMgr:getCharBasicPoint(icon, key, action)


    action = action or Const.SA_STAND
    local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
    local x = CharMgr:getCharBasicPointCfgInt(key .. "_x", action, cartoonInfo)
    local y = CharMgr:getCharBasicPointCfgInt(key .. "_y", action, cartoonInfo)
    --local x = self:getCfgInt('centre_x', Const.SA_STAND, cartoonInfo)
    --local y = self:getCfgInt('centre_y', Const.SA_STAND, cartoonInfo)
    local scale = 1

    local scaleTemp = CharMgr:getCharBasicPointCfgInt('scale', action, cartoonInfo)

    scale = scaleTemp > 0 and scaleTemp / 100 or 1

    return cc.p(x * scale, y * scale)
end

-- 通知客户端将被修正位置
-- WDSY-28211 结婚队伍经过蛋糕时，需要临时移除蛋糕的障碍点，等队伍走开时在恢复障碍点
-- 结婚队伍离开后，服务端走的是 enter_room 重新刷新角色位置，防止角色站在障碍点上，但玩家的自动寻路会在收到 MSG_APPEAR 时被中断
-- 解决方法：此处标记 Me.needContinueAutoWalk = true， Me:onEnterScene(mapX, mapY) 中根据该标记将正在进行的自动寻路标记为未开始的自动寻路。
function CharMgr:MSG_REVISE_POS()
    if Me:isTeamMember() or AutoWalkMgr:getUnFlyAutoWalkStatus() then
        -- 不可飞自动寻路过图后都会自动取 self.unflyAutoWalkDest 中的数据再次开启自动寻路，所以不用处理
        return
    end

    if AutoWalkMgr.autoWalk then
        Me.needContinueAutoWalk = true
    end
end

-- 根据传入等级获取该等级最大经验值
-- isRealBody == true 表示真身   其他表示元婴、血婴
function CharMgr:getMaxExpForLevel(level, isRealBody)
    if DistMgr:curIsTestDist() then
        -- 内测
        if isRealBody then
            return USER_ATTRIB_LIST_TEST[level].exp
        else
            return USER_ATTRIB_LIST_TEST[level].upgrade_exp
        end

    else
        -- 公测
        if isRealBody then
            return USER_ATTRIB_LIST[level].exp
        else
            return USER_ATTRIB_LIST[level].upgrade_exp
        end
    end
end

function CharMgr:MSG_NPC_ACTION(data)
    local npcId = data.npcId
    local char = CharMgr:getChar(npcId)
    if char then
        if char:queryBasicInt("icon") == 51514 or char:queryBasicInt("icon") == 51513 then
            local onActionEnd = char.onActionEnd
            char.onActionEnd = function(self)
                char:setAct(Const.FA_STAND)
                char.onActionEnd = onActionEnd
            end
            char:setAct(data.action)
            -- char:setAct(Const.FA_ACTION_FLEE)
        end
    end
end

function CharMgr:getCharCfg(icon, name)
    local cfg
    -- 又不需要了，有需要再去掉注释
    --[[if name then
        cfg = CharConfig[name]
    end]]

    if not cfg and icon then
        cfg = CharConfig[icon]
    end

    return cfg
end

-- 通知对象淡化消失
function CharMgr:MSG_OBJECT_DISAPPEAR(map)
    local obj = self:getCharById(map.id)
    if obj then
        obj:fadeOut(map.time / 1000)
    end
end

-- 是否包含指定gid的对象
function CharMgr:hasCharByGids(...)
    local gids = { ... }

    local gid
    for _, v in pairs(self.chars) do
        gid = v:queryBasic("gid")
        for i = 1, #gids do
            if gid == gids[i] then return true end
        end
    end
end

function CharMgr:getCharByGid(gid)
    for _, v in pairs(self.chars) do
        if gid == v:queryBasic("gid") then
            return v
        end
    end

    return
end

function CharMgr:getCharByGids(...)
    local gids = { ... }

    local gid
    local ret = {}
    for _, v in pairs(self.chars) do
        gid = v:queryBasic("gid")
        for i = 1, #gids do
            if gid == gids[i] then table.insert(ret, v) end
        end
    end

    return ret
end

-- 通知服务端播放状态动作
function CharMgr:setActionStatus(status)
    self.actionStatusInfo[Me:getId()] = nil

    gf:CmdToServer("CMD_SET_ACTION_STATUS", {status = status})
end

-- 请求停止播放状态动作
function CharMgr:MSG_SET_ACTION_STATUS_COMPLETE(data)
    DlgMgr:closeDlg("CharMenuContentDlg")
end

-- 播放状态动作时要使用对应的 icon
function CharMgr:getStatusActionIcon(id, act)
    if self.actionStatusInfo and self.actionStatusInfo[id] then
        if self.actionStatusInfo[id].act == act then
            return self.actionStatusInfo[id].icon
        elseif id == Me:getId() then
            -- 动作不对，直接停止
            self:setActionStatus(Const.NS_ALIVE)
        end
    end
end

-- 检查是否终止状态动作
function CharMgr:checkStatusAction(id, act)
    if self.actionStatusInfo and self.actionStatusInfo[id] then
        if self.actionStatusInfo[id].act ~= act then
            self.actionStatusInfo[id] = nil
            if id == Me:getId() then
                -- 动作不同，直接停止
                self:setActionStatus(Const.NS_ALIVE)
            end
        end
    end
end

function CharMgr:MSG_VALENTINE_2019_EFFECT_DATA(data)
    if data.count <= 0 and self.qrjCjmg2019Data and self.qrjCjmg2019Data.count > 0 then
		-- 删除光效
        for gid, no in pairs(self.qrjCjmg2019Data.effInfo) do
            local char = CharMgr:getCharByGid(gid)
            if char and CJMG_EFF_INFO[no] then
                local tempData = {charId = char:getId(), effectIcon = CJMG_EFF_INFO[no]}
                CharMgr:MSG_STOP_LIGHT_EFFECT(tempData)
            end

            if char == Me then
                char.isLimitMoveByClient = false
            end
        end

        self.qrjCjmg2019Data = nil
        return
    end

	-- 增加光效
    for gid, no in pairs(data.effInfo) do
        local char = CharMgr:getCharByGid(gid)
        if char and CJMG_EFF_INFO[no] then
            if char == Me and (no == 2 or no == 5) then
                Me.toPos = nil
                Me.isMoved = false
                AutoWalkMgr:stopAutoWalk()
                Me.isLimitMoveByClient = true
            end
            local tempData = {charId = char:getId(), effectIcon = CJMG_EFF_INFO[no]}
            CharMgr:MSG_PLAY_LIGHT_EFFECT(tempData)
            end
        end

    self.qrjCjmg2019Data = data
end

-- 2019端午节口味大战相关数据
function CharMgr:MSG_DW_2019_KWDZ(data)

    local title = data.corp == "tian" and CHS[4010251] or CHS[4010252]
    if data.corp == "" then title = nil end

    local char = CharMgr:getCharById(data.id)
    if char then
        char:updateLeiTaiTitle()
        char:updateName()
        char.dwj2019kwdzTitle = title
    end
end


MessageMgr:regist("MSG_DW_2019_KWDZ", CharMgr)

MessageMgr:regist("MSG_VALENTINE_2019_EFFECT_DATA", CharMgr)

MessageMgr:regist("MSG_SET_ACTION_STATUS_COMPLETE", CharMgr)
MessageMgr:regist("MSG_OBJECT_DISAPPEAR", CharMgr)
MessageMgr:regist("MSG_NPC_ACTION", CharMgr)
MessageMgr:regist("MSG_DAXZ_CHAR_INFO", CharMgr)
MessageMgr:regist("MSG_WINTER2018_DAXZ_CHAR_INFO", CharMgr)
MessageMgr:regist("MSG_TYCYB_TURN_DIR", CharMgr)
MessageMgr:regist("MSG_UPDATE", CharMgr)
MessageMgr:regist("MSG_APPEAR", CharMgr)
MessageMgr:regist("MSG_MOVED", CharMgr)
MessageMgr:regist("MSG_DISAPPEAR", CharMgr)
MessageMgr:regist("MSG_TITLE", CharMgr)
MessageMgr:regist("MSG_UPDATE_APPEARANCE", CharMgr)
MessageMgr:regist("MSG_UPDATE_APPEARANCE_FIELDS", CharMgr)
MessageMgr:regist("MSG_RELOCATE", CharMgr)
MessageMgr:regist("MSG_PLAY_LIGHT_EFFECT", CharMgr)
MessageMgr:regist("MSG_STOP_LIGHT_EFFECT", CharMgr)
MessageMgr:regist("MSG_SEND_RECOMMEND_ATTRIB", CharMgr)
MessageMgr:regist("MSG_PRE_ASSIGN_ATTRIB", CharMgr)
MessageMgr:regist("MSG_LOOK_PLAYER_EQUIP", CharMgr)
MessageMgr:regist("MSG_GATHER", CharMgr)
MessageMgr:regist("MSG_CLEAR_ALL_CHAR", CharMgr)
MessageMgr:regist("MSG_UPDATE_MOVE_SPEED", CharMgr)
MessageMgr:regist("MSG_PARTY_ICON", CharMgr)
MessageMgr:regist("MSG_SEND_ICON", CharMgr)
MessageMgr:regist("MSG_LIEREN_XIANJING", CharMgr)
MessageMgr:regist("MSG_ZUI_XIN_WU", CharMgr)
MessageMgr:regist("MSG_NEW_APPELLATION_INFO", CharMgr)
MessageMgr:regist("MSG_PLAY_CHAR_ACTION", CharMgr)
MessageMgr:regist("MSG_NATIONAL_TYCYB", CharMgr)
MessageMgr:regist("MSG_NATIONAL_TYCYB_END", CharMgr)
MessageMgr:regist("MSG_PLAY_SCREEN_ANIMATE", CharMgr)

EventDispatcher:addEventListener("SYSTEM_SETTING_CHANGE", CharMgr.OnSettingChanged, CharMgr)
EventDispatcher:addEventListener("Shelter_changed", CharMgr.onShelterChanged, CharMgr)

-- 调试代码
function CharMgr:setIcon(icon, weaponIcon, partIndex, colorIndex, dir, act)
    if not gf:isWindows() then return end -- 仅供windows下调试

    dir = dir or 4
    act = act or Const.SA_STAND

    Me:setAct(act)
    MessageMgr:localPushMsg('MSG_UPDATE', {id = Me:getId(), mount_icon = 0, pet_icon = 0, icon = icon, weapon_icon = weaponIcon, dir=dir, part_index = partIndex, part_color_index = colorIndex});
end

-- 设置部件换色颜色值
function CharMgr:setColor(index, color, range, range1, rate)
    local charAction = Me.charAction
    if not charAction then return end

    local part = 0 == index and charAction:getChildByTag(100) or charAction:getChildByTag(1001 + index - 1) -- 0为裸模
    if not part then return end

    local shader
    if string.isNilOrEmpty(part.partIndex) then
        shader = ShaderMgr:createSimpleColorChangeShader()
        part:setGLProgramState(shader)
    else
        shader = part:getGLProgramState()
    end

    if color or range then
        if color then
            shader:setUniformVec3("delta", color)
        end
        if range then
            shader:setUniformVec2("range", range)
        end
        if range1 then
            shader:setUniformVec2("range1", range1)
        else
            shader:setUniformVec2("range1", cc.p(1, 0))
        end
        if rate then
            shader:setUniformMat4("rate", rate)
        end
    else
        part:setGLProgramState(ShaderMgr:getRawShader())
    end
end

-- 获取部件的配色方案
function CharMgr:getColor(index)
    local charAction = Me.charAction
    if not charAction then return end

    local part = charAction:getChildByTag(1001 + index - 1)
    if not part then return end

    local state = part:getGLProgramState()
    if not state then return end

    local delta = gl._getUniform(state:getGLProgram():getProgram(), 2)
    local range = gl._getUniform(state:getGLProgram():getProgram(), 3)
    local range1 = gl._getUniform(state:getGLProgram():getProgram(), 4)

    return delta, range, range1
end

-- 保存配色方案
function CharMgr:saveColor(index, partIndex)
    local charAction = Me.charAction
    if not charAction then return end

    local part = charAction:getChildByTag(1001 + partIndex - 1)
    if not part then return end

    local delta, range, range1 = self:getColor(partIndex)
    local colorCfg = require(ResMgr:getCharPartColorPath(part.icon, part.weapon))
    if not colorCfg then
        colorCfg = {}
    end

    colorCfg[index] = { delta = { x = delta[1], y = delta[2], z = delta[3] }, range = { x = range[1], y = range[2]} }
    if range1 and range1[1] < range1[2] then
        colorCfg[index]["range1"] = { x = range1[1], y = range1[2] }
    end

    self:writeFile(ResMgr:getCharPartColorPath(part.icon, part.weapon), colorCfg)
end

-- 写入文件
function CharMgr:writeFile(path, cfg)
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. "../../res/" .. path
    local f = io.open(filePath, 'wb')
    f:write("return {\n")
    for k, v in pairs(cfg) do
        local s = ""
        if v.range.x < v.range.y then
            if v.range1 and v.range1.x < v.range1.y then
            s = string.format(", range1 = {x = %f, y = %f}", v.range1.x, v.range1.y)
        end

            f:write(string.format("    [%d] = { delta = { x = %f, y = %f, z = %f }, range = { x = %f, y = %f}%s ,", k, v.delta.x, v.delta.y, v.delta.z, v.range.x, v.range.y, s))

            if v.rate then
                f:write("\n")
                f:write(string.format("        rate = {%f, %f, %f, %f,\n", v.rate[1], v.rate[2], v.rate[3], v.rate[4]))
                f:write(string.format("                %f, %f, %f, %f,\n", v.rate[5], v.rate[6], v.rate[7], v.rate[8]))
                f:write(string.format("                %f, %f, %f, %f,\n", v.rate[9], v.rate[10], v.rate[11], v.rate[12]))
                f:write(string.format("                %f, %f, %f, %f}\n", v.rate[13], v.rate[14], v.rate[15], v.rate[16]))
            f:write(string.format("    },\n"))
            else
                f:write("},\n")
    end
    end
    end
    f:write("}\n")
    f:close()
end
