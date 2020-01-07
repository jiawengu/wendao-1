-- SummerSncgMgr.lua
-- Created by haungzz Apr/13/2018
-- 暑假谁能吃瓜活动管理器

SummerSncgMgr = Singleton()

SummerSncgMgr.frameQueue = {}

local POS = {
    {startPos = {x = 47, y = 33}, endPos = {x = 182, y = 115}},
    {startPos = {x = 45, y = 34}, endPos = {x = 180, y = 116}},
}

function SummerSncgMgr:update()
    if self.runState == 2 then
        local curTime = gfGetTickCount()
        local hasTime = curTime - self.startTickTime

        if hasTime <= 0 then
            return
        end

        if not self.curFrame or self.curFrame.totalTime < hasTime + (1 / Const.FPS) * 1000 then
            local frame = self:getOneFrameInfo(hasTime)
            if frame then
                self.curFrame = frame
                
                -- 通知当前跑到第几帧，用于显示加速图标
                DlgMgr:sendMsg("WatermelonRaceDlg", "setCurSeq", frame.seq)

                for i = 1, 2 do
                    local char = CharMgr:getCharById(i)
                    if char and self.curFrame[i].show_effect == 1 and char:queryBasic("gid") ~= Me:queryBasic("gid") then
                        -- 添加队员的加速光效，自己的加速光效在点击加速时直接添加
                        self:palySpeedMagic(char)
                    end
                end
            end
        end
        
        for i = 1, 2 do
            local char = CharMgr:getCharById(i)
            if char then
                local startPos = POS[i].startPos
                local endPos = POS[i].endPos
                local endX, endY = gf:convertToClientSpace(endPos.x, endPos.y)

                if endX <= char.curX + 0.5 and endY >= char.curY - 0.5 then
                    -- 到达终点
                    self.runState = 0
                    
                    char:setAct(Const.FA_STAND)
                    local char2 = CharMgr:getCharById(i % 2 + 1)
                    if char2 then
                        char2:setAct(Const.FA_STAND)
                    end
                    
                    gf:CmdToServer("CMD_SUMMER_2018_CHIGUA_ARRIVE", {})
                    return
                end
                
                local totalTime = self.curFrame.totalTime
                if hasTime > totalTime then
                    hasTime = totalTime
                end
                
                -- 计算当前时间点要跑到的坐标点
                local curToDis = (self.curFrame[i].to_distance / (totalTime)) * hasTime
                local rat = curToDis / self.basicData.total_distance
                local x = startPos.x + (endPos.x - startPos.x) * rat
                local y = startPos.y + (endPos.y - startPos.y) * rat
                
                local cx, cy = gf:convertToClientSpace(x, y)
                if endX <= cx and endY >= cy then
                    -- 防止到终点后会被拉一下
                    cx = endX
                    cy = endY
                end
                
                char:setPos(cx, cy)
                
                if char:isStandAction() then
                    char:setAct(Const.FA_WALK)
                end
            end
        end
    end
end

function SummerSncgMgr:stopRunGame()
    self.runState = 0  -- 标记比赛结束
    
    CharMgr:deleteChar(1)
    CharMgr:deleteChar(2)

    Me:setVisible(true)
    
    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:setCenterChar(nil)
    end
end

function SummerSncgMgr:getFrameInterval()
    return self.frameInterval or 200
end

-- 获取当前跑到的帧数
function SummerSncgMgr:getCurFrameNum()
    if self.curFrame then
        return self.curFrame.seq
    end
end

-- 从帧队列中获取一帧计算
function SummerSncgMgr:getOneFrameInfo(time)
    if not self.frameQueue[1] then
        return
    end
    
    repeat
        local info = table.remove(self.frameQueue, 1)
        if info.totalTime >= time + (1 / Const.FPS) * 1000 or not self.frameQueue[1] then
            return info
        end
        
    until false
end

function SummerSncgMgr:clearData()
    self.frameQueue = {}
    self.runState = 0
    self.curFrame = nil
    self:stopRunGame()
end

function SummerSncgMgr:cmdAccelerate(seq, pos, rate)
    local text = string.format("%d #@#@# %d #@#@# %d", seq, pos, rate)
    local locationStr = gfEncrypt(text, tostring(Me:getId()))
    gf:CmdToServer("CMD_SUMMER_2018_CHIGUA_ACCELERATE", {text = locationStr})
    
    -- 直接播放加速光效
    if rate > 100 then
        for i = 1, 2 do
            local char = CharMgr:getCharById(i)
            if char and char:queryBasic("gid") == Me:queryBasic("gid") then
                self:palySpeedMagic(char)
            end
        end
    end
end

-- 播放加速光效
function SummerSncgMgr:palySpeedMagic(char)
    if char.sncgMagic then
        char.sncgMagic:removeFromParent()
    end
    
    local icon = tonumber(ResMgr.ArmatureMagic.run_add_speed_foot.name)
    char:addMagicOnFoot(icon, true, icon, ARMATURE_TYPE.ARMATURE_MAP)

    char.sncgMagic = char:addMagicOnFoot(ResMgr.magic.run_add_speed_waist, false, false, nil, nil, function(node) 
        char.sncgMagic:removeFromParent()
        char.sncgMagic = nil
        char:deleteMagic(icon)
    end)
end

-- 吃瓜比赛 - 比赛数据
function SummerSncgMgr:MSG_SUMMER_2018_CHIGUA_DATA(data)
    self.basicData = data
    self.frameInterval = data.frame_interval
    self.runState = 1   -- 赛跑状态 1 倒计时 2 开跑 0 结束或未开始
    self.frameQueue = {}
    self.curFrame = nil
    
    self.hasReceiveFrameCou = 0  -- 标记收到第几条帧数据
    
    self.lastFrameTotalTime = nil  -- 存储执行到上一帧要花费的时间
    
    Me:setVisible(false)

    DlgMgr:openDlgEx("WatermelonRaceDlg", data)
    
    -- 创建假的模型
    local members = TeamMgr.members_ex
    for i = 1, 2 do
        local member = TeamMgr:getExMemberById(data["player_id" .. i])
        if member then
            local map = {
                id = i,
                x = POS[i].startPos.x,
                y = POS[i].startPos.y,
                dir = 5,
                icon = member.org_icon,
                weapon_icon = member.weapon_icon,
                type = member.type,
                sub_type = member.sub_type,
                name = member.name,
                level = member.level,
                family = member.family,
                ["party/name"] = member["party/name"],
                org_icon = member.org_icon,
                suit_icon = member.suit_icon,
                gid = member.gid,
                is2018SJ_SNCG = 1,
            }

            local char = CharMgr:loadCharData(map)
            CharMgr:loadChar(map)
            
            if data["player_id" .. i] == Me:getId() then
                if GameMgr.scene and GameMgr.scene.map then
                    GameMgr.scene.map:setCenterChar(i)
                end
            end
        end
    end
end

-- 吃瓜比赛 - 帧数据
function SummerSncgMgr:MSG_SUMMER_2018_CHIGUA_FRAME(data)
    if self.runState == 0 then
        -- 游戏未开始，异常收到的帧数据直接丢弃
        return
    end

    self.hasReceiveFrameCou = self.hasReceiveFrameCou + 1

    if self.runState == 1 and self.hasReceiveFrameCou == 1 then
        -- 从收到的第三帧开始跑，缓存两帧
        -- 可能掉线，收到的是第一条是中间帧
        local ctime = math.max(0, gf:getServerTime() - self.basicData.start_time)
        self.startTickTime = gfGetTickCount() - (ctime * 1000) + self.frameInterval * 2
        self.runState = 2
    end

    if not self.lastFrameTotalTime then
        self.lastFrameTotalTime = self.frameInterval * (data.seq - 1)
    end
    
    -- data.frame_interval 中包含在服务端计算的时间，所以正常会比 self.frameInterval 大
    data.totalTime = self.lastFrameTotalTime + data.frame_interval
    self.lastFrameTotalTime = data.totalTime
    
    if self.startTickTime then
        -- 收到第一条前切入后台或掉线重连，会导致开始时间的误差较大，此处修复一下
        local curTickTime = gfGetTickCount()
        if self.startTickTime < curTickTime - self.lastFrameTotalTime + self.frameInterval 
                or self.startTickTime > curTickTime - self.lastFrameTotalTime + self.frameInterval * 3 then
            self.startTickTime = curTickTime - self.lastFrameTotalTime + self.frameInterval * 2
        end
    end

    table.insert(self.frameQueue, data)
end

-- 吃瓜比赛 - 加速图标
function SummerSncgMgr:MSG_SUMMER_2018_CHIGUA_EFFECT(data)
    local dlg = DlgMgr:getDlgByName("WatermelonRaceDlg")
    if dlg then
        dlg:addSpendImg(data)
    end
end

-- 吃瓜比赛 - 结果
function SummerSncgMgr:MSG_SUMMER_2018_CHIGUA_RESULT(data)
    local dlg = DlgMgr:getDlgByName("WatermelonRaceDlg")
    -- 播动画
    if dlg then
        if data.ob1_result == 1 or data.ob2_result == 1 then
            -- 胜利方头顶当前频道喊话：“嘿嘿，这个大西瓜我就拿走了！”，胜利方弹出对话后0.5秒，失败方头顶当前频道喊话：“可恶，下次我一定不会输的！”，失败方喊话结束0.5秒后，结束赛跑状态。
            local winChar, loseChar
            if data.ob1_result == 1 then
                winChar = CharMgr:getCharById(1)
                loseChar = CharMgr:getCharById(2)
            elseif data.ob2_result == 1 then
                winChar = CharMgr:getCharById(2)
                loseChar = CharMgr:getCharById(1)
            end

            if not winChar or not loseChar then
                DlgMgr:closeDlg("WatermelonRaceDlg")
                return
            end

            local action = cc.Sequence:create(
                cc.CallFunc:create(function() 
                    ChatMgr:sendCurChannelMsgOnlyClient({
                        id = winChar:getId(),
                        gid = winChar:queryBasic("gid"),
                        icon = winChar:queryBasicInt("icon"),
                        name = winChar:getName(),
                        msg =  CHS[5450171],
                    })
                end),
    
                cc.DelayTime:create(1.5),
    
                cc.CallFunc:create(function() 
                    ChatMgr:sendCurChannelMsgOnlyClient({
                        id = loseChar:getId(),
                        gid = loseChar:queryBasic("gid"),
                        icon = loseChar:queryBasicInt("icon"),
                        name = loseChar:getName(),
                        msg =  CHS[5450172],
                    })
                end),
    
                cc.DelayTime:create(1.5),
    
                cc.CallFunc:create(function() 
                    DlgMgr:closeDlg("WatermelonRaceDlg")
                end)
            )
            
            dlg.root:runAction(action)
        elseif data.ob1_result == 3 and data.ob2_result == 3 then
            -- 比赛平局时，双方当前频道喊话：“居然是平局，那就下次再分胜负吧！”喊话结束0.5秒后，结束赛跑状态。
            local action = cc.Sequence:create(
                cc.CallFunc:create(function() 
                    for i = 1, 2 do
                        local char = CharMgr:getCharById(i)
                        if char then
                            ChatMgr:sendCurChannelMsgOnlyClient({
                                id = char:getId(),
                                gid = char:queryBasic("gid"),
                                icon = char:queryBasicInt("icon"),
                                name = char:getName(),
                                msg =  CHS[5450173],
                            })
                        end
                    end
                end),

                cc.DelayTime:create(3),

                cc.CallFunc:create(function() 
                    DlgMgr:closeDlg("WatermelonRaceDlg")
                end)
            )
            
            dlg.root:runAction(action)
        else
            DlgMgr:closeDlg("WatermelonRaceDlg")
            Me:setAct(Const.SA_STAND, true)
            AutoWalkMgr:stopAutoWalk()
        end
    else
        self:stopRunGame()
    end
end

MessageMgr:regist("MSG_SUMMER_2018_CHIGUA_RESULT", SummerSncgMgr)
MessageMgr:regist("MSG_SUMMER_2018_CHIGUA_DATA", SummerSncgMgr)
MessageMgr:regist("MSG_SUMMER_2018_CHIGUA_FRAME", SummerSncgMgr)
MessageMgr:regist("MSG_SUMMER_2018_CHIGUA_EFFECT", SummerSncgMgr)