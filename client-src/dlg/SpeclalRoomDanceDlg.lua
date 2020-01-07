-- SpeclalRoomDanceDlg.lua
-- Created by songcw Dec/2018/21
-- 通天塔-神秘房间-手舞足蹈

local SpeclalRoomDanceDlg = Singleton("SpeclalRoomDanceDlg", Dialog)

function SpeclalRoomDanceDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClient("TouchPanel")
    self:bindListener("UpButton", self.onUpButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LeftButton", self.onLefttButton)
    self:bindListener("DownButton", self.onDownButton)

    -- 隐藏相关角色
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    -- 变量清空
    self.charStepData = {}
    self.myStep = nil
    self.times = 1

    -- 初始化npc
    TttSmfjMgr:initSwzdObj()

    -- 变幻方向标
    self.dirMaps = TttSmfjMgr.swzdStepData

    -- 3秒倒计时
    if data and data.status == 1 and data.end_time -  gf:getServerTime() > 0 then
        -- 显示3秒倒计时
        gf:startCountDowm(data.end_time, "start")
    end

    self:hookMsg("MSG_SMFJ_SWZD_STEP_LIST")
    self:hookMsg("MSG_SMFJ_GAME_STATE")
    self:hookMsg("MSG_SMFJ_SWZD_MOVE_STEP")
end

-- 定时变幻
function SpeclalRoomDanceDlg:changeDir()
    if not self.dirMaps.path[self.times] then return end
    if self.gameState and self.gameState == 3 then return end

    -- 我没有操作，输了
    if not self.meOper.isLose and self.times ~= 1 and self.meOper[self.times - 1] ~= self.dirMaps.path[self.times - 1] and not self.meOper.isLose then
        local char = TttSmfjMgr:getSwzdCharById(Me:getId())
        char:setChat({msg = CHS[4101288], show_time = 3}, nil, true)
        char:setDir(5)
        char:setAct(Const.FA_DIED)
        self.meOper.isLose = true
        gf:CmdToServer("CMD_SMFJ_SWZD_MOVE_STEP", {step = self.times - 2, cmd_no = 0})
    end

    local char = TttSmfjMgr:getSwzdCharById(1)
    char:setDir(self.dirMaps.path[self.times])
    char.charAction:playActionOnce(function ()
        performWithDelay(self.root, function ()
            self.times = self.times + 1
            self:changeDir()
        end, 1.75 - self.times * 0.05)
    end)
end


function SpeclalRoomDanceDlg:cleanup()
    TttSmfjMgr:clearSwzdNpcById()

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    Me:setVisible(true)

    gf:closeCountDown()

    self.root:stopAllActions()
end

function SpeclalRoomDanceDlg:onUpButton(sender, eventType)
    if self.gameState ~= 2 then return end
    if self.meOper.isLose then return end
    if self.dirMaps.path[self.times] ~= 3 then
        local char = TttSmfjMgr:getSwzdCharById(Me:getId())
        char:setChat({msg = CHS[4101289], show_time = 3}, nil, true)
        char:setDir(5)
        char:setAct(Const.FA_DIED)
        self.meOper.isLose = true
    else
        self.meOper[self.times] = 3
    end

    gf:CmdToServer("CMD_SMFJ_SWZD_MOVE_STEP", {step = self.times - 1, cmd_no = 3})
end

function SpeclalRoomDanceDlg:onRightButton(sender, eventType)
    if self.gameState ~= 2 then return end
    if self.meOper.isLose then return end
    if self.dirMaps.path[self.times] ~= 5 then
        local char = TttSmfjMgr:getSwzdCharById(Me:getId())
        char:setChat({msg = CHS[4101289], show_time = 3}, nil, true)
        char:setDir(5)
        char:setAct(Const.FA_DIED)
        self.meOper.isLose = true
    else
        self.meOper[self.times] = 5
    end

    self.myStep = nil
    gf:CmdToServer("CMD_SMFJ_SWZD_MOVE_STEP", {step = self.times - 1, cmd_no = 5})
end

function SpeclalRoomDanceDlg:onLefttButton(sender, eventType)
    if self.gameState ~= 2 then return end
    if self.meOper.isLose then return end
    if self.dirMaps.path[self.times] ~= 1 then
        local char = TttSmfjMgr:getSwzdCharById(Me:getId())
        char:setChat({msg = CHS[4101289], show_time = 3}, nil, true)
        char:setDir(5)
        char:setAct(Const.FA_DIED)
        self.meOper.isLose = true
    else
        self.meOper[self.times] = 1
    end

    gf:CmdToServer("CMD_SMFJ_SWZD_MOVE_STEP", {step = self.times - 1, cmd_no = 1})
end

function SpeclalRoomDanceDlg:onDownButton(sender, eventType)
    if self.gameState ~= 2 then return end
    if self.meOper.isLose then return end
    if self.dirMaps.path[self.times] ~= 7 then
        local char = TttSmfjMgr:getSwzdCharById(Me:getId())
        char:setChat({msg = CHS[4101289], show_time = 3}, nil, true)
        char:setDir(5)
        char:setAct(Const.FA_DIED)
        self.meOper.isLose = true
    else
        self.meOper[self.times] = 7
    end

    gf:CmdToServer("CMD_SMFJ_SWZD_MOVE_STEP", {step = self.times - 1, cmd_no = 7})
end

--
function SpeclalRoomDanceDlg:MSG_SMFJ_SWZD_MOVE_STEP(data)
    local char = TttSmfjMgr:getSwzdCharById(data.id)
    if not char then return end

    if data.success == 0 then
        char:setDir(5)
        char:setAct(Const.FA_DIED)


        if data.id ~= Me:getId() then
            if data.cmd_no == 0 then
                char:setChat({msg = CHS[4101288], show_time = 3}, nil, true)
            else
                char:setChat({msg = CHS[4101289], show_time = 3}, nil, true)
            end
        end
    else
        char:setDir(data.cmd_no)
        char.charAction:playActionOnce()
    end
end

function SpeclalRoomDanceDlg:setTimes(times)
    self.times = times
    self.myStep = times
end

function SpeclalRoomDanceDlg:MSG_SMFJ_GAME_STATE(data)
    if data.game_name ~= CHS[4010290] then return end   -- 手舞足蹈
    if not self.dirMaps then return end

    if data.status == 2 then
        local char = TttSmfjMgr:getSwzdCharById(1)
        char:setChat({msg = CHS[4010291], show_time = 3}, nil, true)  -- 跟我一起动起来！

        -- 游戏开始了
        self.meOper = {}
        if data.end_time - gf:getServerTime() > 0 then
            gf:startCountDowm(data.end_time, "end")

            -- 收到消息时，我已经输了，NPC不播放动画了
            if TttSmfjMgr.swzdCharStepData and TttSmfjMgr.swzdCharStepData[Me:getId()] and TttSmfjMgr.swzdCharStepData[Me:getId()].success == 0 then
                for cid, charInfo in pairs(TttSmfjMgr.swzdCharStepData) do
                    if charInfo.success == 0 then
                        self:MSG_SMFJ_SWZD_MOVE_STEP(charInfo)
                    end
                end

                self.meOper.isLose = true
            else
                self.times = self.times or 1
                self.myStep = self.myStep or 1
                self:changeDir()
            end
        end
    elseif data.status == 3 then
        -- 结束时候，延迟一会关闭界面
        performWithDelay(self.root, function ()
            self:onCloseButton()
        end, 2)
    end
    self.gameState = data.status
end

return SpeclalRoomDanceDlg
