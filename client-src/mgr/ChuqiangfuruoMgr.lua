-- ChuqiangfuruoMgr.lua
-- created by lixh Feb/02/2018
-- 锄强扶弱管理器
-- 2018劳动节活动

ChuqiangfuruoMgr = Singleton()

-- npc的4个方向对应扇形区域
-- x,y表示两个方向的矢量，len表示两个方向最长检测距离
local DIR_TO_RED_POS = {
    [1] = {x = -1, y = -1, len = 3}, -- 1方向：西北
    [3] = {x =  1, y = -1, len = 3}, -- 3方向：东北
    [5] = {x =  1, y =  1, len = 3}, -- 5方向：东南
    [7] = {x = -1, y =  1, len = 3}, -- 7方向：西南
}

-- 开始检测2018劳动节锄强扶弱副本npc
function ChuqiangfuruoMgr:laborStartCheckPos()
    if not MapMgr:isInShanZei() then return end
    if self.laborScheduleId then return end

    self.laborScheduleId = gf:Schedule(function()
        ChuqiangfuruoMgr:update()
    end, 0)
end

-- 停止检测2018劳动节锄强扶弱副本npc
function ChuqiangfuruoMgr:laborStopCheckPos()
    if self.laborScheduleId then
        gf:Unschedule(self.laborScheduleId)
        self.laborScheduleId = nil
    end
end

function ChuqiangfuruoMgr:update()
    -- 不在山贼地图，停止检测me与npc的位置
    if not MapMgr:isInShanZei() then
        ChuqiangfuruoMgr:laborStopCheckPos()
    end

    -- 战斗中，不检测
    if Me:isInCombat() then return end

    -- 玩家与巡逻山贼对话，不检测
    if ChuqiangfuruoMgr:isPlayDramaWithShanZei() then return end

    -- 获取npc巡逻山贼
    local npcs = CharMgr:getLaborActivityNpcs()
    if not npcs then return end

    local npcsRedPos = {}
    for i = 1, #npcs do
        local npcX, npcY = gf:convertToMapSpace(npcs[i].curX, npcs[i].curY)
        local npcDir = npcs[i]:getDir()
        local redArea = DIR_TO_RED_POS[npcDir]

        -- 有可能地图坐标非法，所以需要进行修正
        npcX, npcY = MapMgr:adjustPosition(npcX, npcY)
        local pos = GObstacle:Instance():GetNearestPos(npcX, npcY)
        if 0 ~= pos then
            npcX, npcY = math.floor(pos / 1000), pos % 1000
        end

        if redArea then
            -- 特效为一个扇形区域，策划给的是一个矩形区域，所有可以用2次遍历
            for j = 1, redArea.len do
                for k = 1, redArea.len do
                    local redPointX = npcX + j * redArea.x
                    local redPointY = npcY + k * redArea.y
                    local meMapX, meMapY = gf:convertToMapSpace(Me.curX, Me.curY)

                    -- 有可能地图坐标非法，所以需要进行修正
                    meMapX, meMapY = MapMgr:adjustPosition(meMapX, meMapY)
                    pos = GObstacle:Instance():GetNearestPos(meMapX, meMapY)
                    if 0 ~= pos then
                        meMapX, meMapY = math.floor(pos / 1000), pos % 1000
                    end

                    if redPointX == meMapX and redPointY == meMapY then
                        -- 进入战斗前关闭NPC对话框，关闭剧本界面
                        DlgMgr:closeDlg("NpcDlg")
                        DlgMgr:closeDlg("DramaDlg")

                        -- 触发战斗
                        gf:CmdToServer("CMD_LDJ_2018_NOTIFY_COMBAT", {
                            meX = meMapX,
                            meY = meMapY,
                            npcId = npcs[i]:getId(),
                            npcX = npcX,
                            npcY = npcY,
                            npcDir = npcDir
                        })

                        return
                    end
                end
            end
        end
    end
end

-- 判断玩家是否在与巡逻山贼播剧本
function ChuqiangfuruoMgr:isPlayDramaWithShanZei()
    local dlg = DlgMgr:getDlgByName("DramaDlg")
    if dlg and dlg.id and dlg.content then
        if (dlg.id == Me:getId() and dlg.content == CHS[7190157]) or dlg.content == CHS[7190156] then
            -- 山贼没有判断id的原因是，有可能剧本界面id还没有收到，但界面就已经打开了，所以暂时只判断内容，也没有什么问题
            return true
        end
    end
end

function ChuqiangfuruoMgr:MSG_ENTER_ROOM()
    if MapMgr:isInShanZeiLaoChao() then
        ChuqiangfuruoMgr:laborStartCheckPos()
    end

    -- 进入场景后，也许是从后台切回来的，需要提示玩家已经回到过图点了
    if self.needShowTips then
        gf:ShowSmallTips(CHS[7190155])
        ChatMgr:sendMiscMsg(CHS[7190155])
        self.needShowTips = false
    end
end

-- 2018劳动节锄强扶弱副本任务s10状态需要提示
-- 此副本，只要切后台，服务器就会让玩家重新进入此副本地图，所以提示部分在MSG_ENTER_ROOM里面做，此处只打一个标记
function ChuqiangfuruoMgr:onEnterForeground()
    if MapMgr:isInShanZeiLaoChao() then
        local task = TaskMgr:getTaskByName(CHS[7190144])
        if task and string.match(task.task_prompt, CHS[7190154]) then
            self.needShowTips = true
        end

        local task = TaskMgr:getTaskByName(CHS[7190231])
        if task and string.match(task.task_prompt, CHS[7190154]) then
            self.needShowTips = true
        end
    end
end

MessageMgr:hook("MSG_ENTER_ROOM", ChuqiangfuruoMgr, "ChuqiangfuruoMgr")
EventDispatcher:addEventListener('ENTER_FOREGROUND', ChuqiangfuruoMgr.onEnterForeground, ChuqiangfuruoMgr)
