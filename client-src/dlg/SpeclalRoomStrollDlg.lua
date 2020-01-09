-- SpeclalRoomStrollDlg.lua
-- Created by songcw Dec/2018/21
-- 通天塔-神秘房间-幽灵漫步

local ControlDlg = require('dlg/ControlDlg')
local SpeclalRoomStrollDlg = Singleton("SpeclalRoomStrollDlg", ControlDlg)

-- 配表起始点
local START_POS = {

}

local NO_TO_POS = {
    [1]  = {x = 30, y = 20},
    [2]  = {x = 32, y = 19},
    [3]  = {x = 34, y = 18},
    [4]  = {x = 36, y = 17},
    [5]  = {x = 38, y = 16},
    [6]  = {x = 32, y = 21},
    [7]  = {x = 34, y = 20},
    [8]  = {x = 36, y = 19},
    [9]  = {x = 38, y = 18},
    [10] = {x = 40, y = 17},
    [11] = {x = 34, y = 22},
    [12] = {x = 36, y = 21},
    [13] = {x = 38, y = 20},
    [14] = {x = 40, y = 19},
    [15] = {x = 42, y = 18},
    [16] = {x = 36, y = 23},
    [17] = {x = 38, y = 22},
    [18] = {x = 40, y = 21},
    [19] = {x = 42, y = 20},
    [20] = {x = 44, y = 19},
    [21] = {x = 38, y = 24},
    [22] = {x = 40, y = 23},
    [23] = {x = 42, y = 22},
    [24] = {x = 44, y = 21},
    [25] = {x = 46, y = 20},
}

function SpeclalRoomStrollDlg:init(para)

    self:setFullScreen()
    self:bindListener("AttackButton", self.onAttackButton)
    self.isDemoing = false
    self.isStartYLMB = false
    self.isWrongActing = false
    self.stepData = {}

    START_POS = TttSmfjMgr:getYlmbStartPos()


    local char = CharMgr:getCharByName(CHS[4200636])
    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:setCenterChar(char:getId())
    end

    self:setNoMap(NO_TO_POS)

    self.mapPos = self:getNoMap()
    ControlDlg.init(self, para)
--
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })
--]]

    self:hookMsg("MSG_SMFJ_GAME_STATE")
    self:hookMsg("MSG_SMFJ_YLMB_MOVE_STEP")
end



function SpeclalRoomStrollDlg:cleanup()


    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:setCenterChar(nil)
    end

    --self.root:stopAllActions()
    if self.delayCloseId then
        self:stopSchedule(self.delayCloseId)
        self.delayCloseId = nil
    end
    ControlDlg.cleanup(self)



    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    Me:setVisible(true)

    TttSmfjMgr:clearYlmbNpcById()

    gf:closeCountDown()
end

-- 开始演示寒气之脉的轨迹
function SpeclalRoomStrollDlg:startDemo(data)
    if not self.path then
        return
    end

    self:showAllMagic()
    if data.isDemo ~= 1 then
        gf:CmdToServer("CMD_SMFJ_YLMB_IS_READY")
        TttSmfjMgr:initYLMB()
        return
    end

    self.isDemoing = true



    local cou = 1
    local info = {id = 1, icon = 6140, name = CHS[4010296], dir = 5, pos = self.mapPos[self.path[cou]]}
    local char = TttSmfjMgr:createStandNpcForYlmb(info)

    self.scheduleId = self:startSchedule(function()
        cou = cou + 1
        if not self.path[cou] and self.mapPos[self.path[cou]] ~= 0 then -- map[self.path[cou]] == 0  表示攻击
            self:stopSchedule(self.scheduleId)
            self.scheduleId = nil
            TttSmfjMgr:clearYlmbNpcById(1)
            self.isDemoing = false

            -- 通知服务器演示完成
            gf:CmdToServer("CMD_SMFJ_YLMB_IS_READY")

            TttSmfjMgr:initYLMB()
            return
        end

        if self.path[cou] == 0 then
            -- 播放攻击
            char.charAction:playActionOnce()
        else
            -- 移动
            char:setDestPos(self.mapPos[self.path[cou]])
            char:setEndPos(self.mapPos[self.path[cou]].x, self.mapPos[self.path[cou]].y)
        end
    end, 1.5)

end

-- 显示所有的寒气之脉光效
function SpeclalRoomStrollDlg:showAllMagic()
    -- 创建围墙
    self:creatWalls()

    for i = 1, #self:getNoMap() do
        self:creatGrid(i, true)
    end
end

function SpeclalRoomStrollDlg:onUpdate()

end

function SpeclalRoomStrollDlg:onAttackButton(sender, eventType)
    if not self:isCanGoToNext() then return end
    if not self.stepData[Me:getId()] or self.stepData[Me:getId()].step == -1 then return end
    gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = self.stepData[Me:getId()].step + 1, cmd_no = 0})

end

function SpeclalRoomStrollDlg:getCurNo()
    if self.stepData[Me:getId()].step == -1 then
        return 0
    elseif self.stepData[Me:getId()].step == 0 then
        return 3
    else
        if self.stepData[Me:getId()].cmd_no == 0 then
            return self.path[self.stepData[Me:getId()].step]
        else
            return self.stepData[Me:getId()].cmd_no
        end
    end
end

function SpeclalRoomStrollDlg:onRightUpButton(sender, eventType)
    if not self:isCanGoToNext() then return end
    if not self.stepData[Me:getId()] or self.stepData[Me:getId()].step == -1 then return end
    local curNo = self:getCurNo()
    local dest = curNo + 1
    if math.floor( (dest - 1) / 5 ) ~= math.floor( (curNo - 1) / 5 ) then return end

    gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = self.stepData[Me:getId()].step + 1, cmd_no = dest})
end

function SpeclalRoomStrollDlg:onLeftDownButton(sender, eventType)
    if not self:isCanGoToNext() then return end
    if not self.stepData[Me:getId()] or self.stepData[Me:getId()].step == -1 then return end
    local curNo = self:getCurNo()
    local dest = curNo - 1
    if dest <= 0 then return end
    if math.floor( (dest - 1) / 5 ) ~= math.floor( (curNo - 1) / 5 ) then return end

    gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = self.stepData[Me:getId()].step + 1, cmd_no = dest})
end

function SpeclalRoomStrollDlg:onLeftUpButton(sender, eventType)
    if not self:isCanGoToNext() then return end
    if not self.stepData[Me:getId()] or self.stepData[Me:getId()].step == -1 then return end

    local curNo = self:getCurNo()
    local dest = curNo - 5
    if dest < 1 then return end

    gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = self.stepData[Me:getId()].step + 1, cmd_no = dest})
end

function SpeclalRoomStrollDlg:onRightDownButton(sender, eventType)
    if not self:isCanGoToNext() then return end
    if not self.stepData[Me:getId()] or self.stepData[Me:getId()].step == -1 then
        gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = 0, cmd_no = 3})
        return
    end

    local curNo = self:getCurNo()
    local dest = curNo + 5
    if dest > 25 then return end

    gf:CmdToServer("CMD_SMFJ_YLMB_MOVE_STEP", {step = self.stepData[Me:getId()].step + 1, cmd_no = dest})

end


function SpeclalRoomStrollDlg:MSG_SMFJ_GAME_STATE(data)
    if data.status == 2 then
        if self.scheduleId then
            self:stopSchedule(self.scheduleId)
            self.scheduleId = nil
            TttSmfjMgr:clearYlmbNpcById(1)
            self.isDemoing = false
            TttSmfjMgr:initYLMB()
        end

        if data.end_time - gf:getServerTime() > 30 then
            local ti = data.end_time - gf:getServerTime() - 30
            gf:startCountDowm(gf:getServerTime() + ti, "start", function ()
                self.isStartYLMB = true
                performWithDelay(self.root, function ( )
                    -- body
                    gf:startCountDowm(data.end_time, "end")
                end)

            end)
        else
            self.isStartYLMB = true
            gf:startCountDowm(data.end_time, "end")
        end
    elseif data.status == 3 then
        self.delayCloseId = performWithDelay(self.root, function ( )
            DlgMgr:closeDlg(self.name)
        end, 2)
    end
end

function SpeclalRoomStrollDlg:showwrongWay(char)

    char:setChat({msg = CHS[4010297], show_time = 3}, nil, true)
    CharMgr:MSG_PLAY_LIGHT_EFFECT({effectIcon = ResMgr.magic.tj_han_bing, charId = Me:getId()}, char)

    performWithDelay(self.root, function ()
        -- body
        local pos = START_POS
        local x,y = gf:convertToClientSpace(pos.x, pos.y)
      --  char:setLastMapPos(x, y)
        char:setLastMapPos(gf:convertToMapSpace(x, y))
        char:setPos(x, y)
        char:setAct(Const.SA_STAND)
        char:setDir(5)

        if char:queryBasicInt("id") == Me:getId() * 10 then
            self.isWrongActing = false
        end
    end, 3)
end

function SpeclalRoomStrollDlg:MSG_SMFJ_YLMB_MOVE_STEP(data)
    local char = TttSmfjMgr:getYlmbCharById(data.id)
    if not char then return end

    if not self.isStartYLMB then
        -- 还没有开始直接设置位置
        local pos
        if data.step < 0 then
            pos = START_POS
        else
            if self.path[data.step + 1]  == 0 then
                pos = self.mapPos[self.path[data.step]]
            else
                pos = self.mapPos[self.path[data.step + 1]]
            end
        end
        local x,y = gf:convertToClientSpace(pos.x, pos.y)
        char:setPos(x, y)
        char:setAct(Const.SA_STAND)
        char:setDir(5)
    else
        if data.success == 0 then
            if data.id == Me:getId() then
                self.isWrongActing = true
            end

            if data.cmd_no == 0 then
                -- 播放攻击动作错误
                char.charAction:playActionOnce(function ( )
                    -- body
                    self:showwrongWay(char)
                end)

            else
                -- 移动到错误的地方
                char:setDestPos(self.mapPos[data.cmd_no])
                char:setEndPos(self.mapPos[data.cmd_no].x, self.mapPos[data.cmd_no].y)
            end

            data.step = -1
        else
            if data.cmd_no ~= 0 then
                local pos = self.mapPos[data.cmd_no]
                char:setEndPos(pos.x, pos.y)
            else
                -- 播放施法动作
                char.charAction:playActionOnce()
            end
        end
    end

    self.stepData[data.id] = data
end

function SpeclalRoomStrollDlg:isCanGoToNext()

    local char = TttSmfjMgr:getYlmbCharById(Me:getId())
    if not char then return end
    if char.charAction and char.charAction.action ~= Const.SA_STAND then
        return
    end

    if self.isWrongActing then return end
    if not self.isStartYLMB then return end
    if not self.stepData[Me:getId()] then return true end
    if self.stepData[Me:getId()].isSendCmd then return false end

    return true
end

function SpeclalRoomStrollDlg:onTouchPanel(sender, eventType)

end


return SpeclalRoomStrollDlg
