-- ChongYangFoodDlg.lua
-- Created by lixh Sep/06/2017
-- 重阳宴席界面

local ChongYangFoodDlg = Singleton("ChongYangFoodDlg", Dialog)

-- 饱食度：重阳糕，菊花酒，羊肉面，大闸蟹，牛肉煲
local TASTE_MAP = {10, 10, 20, 20, 30}

function ChongYangFoodDlg:init()
    self:bindListener("TasteButton", self.onTasteButton, "ChongYangGaoPanel")
    self:getControl("TasteButton", nil, "ChongYangGaoPanel").tag = 1
    self:bindListener("TasteButton", self.onTasteButton, "JuHuaJiuPanel")
    self:getControl("TasteButton", nil, "JuHuaJiuPanel").tag = 2
    
    self.lastTasteTime = 0

    self:hookMsg("MSG_CHONGYANG_2017_TASTE")
end

-- 帮派宴席需要打开特殊菜肴
function ChongYangFoodDlg:openSpecialFood()
    self:setScheduleStart(self:getRefreshLeftTime())
    self:openSpecialFoodByName("YangRouPanel")
    self:openSpecialFoodByName("DaPanXiePanel")
    self:openSpecialFoodByName("NiuRouBaoPanel")
    
    self:bindListener("TasteButton", self.onTasteButton, "YangRouPanel")
    self:getControl("TasteButton", nil, "YangRouPanel").tag = 3
    self:bindListener("TasteButton", self.onTasteButton, "DaPanXiePanel")
    self:getControl("TasteButton", nil, "DaPanXiePanel").tag = 4
    self:bindListener("TasteButton", self.onTasteButton, "NiuRouBaoPanel")
    self:getControl("TasteButton", nil, "NiuRouBaoPanel").tag = 5
end

-- 打开特殊菜肴
function ChongYangFoodDlg:openSpecialFoodByName(name)
    local panel = self:getControl(name)
    self:setCtrlVisible("HungryLabel", true, panel)
    self:setCtrlVisible("BlackPanel", false, panel)
    
    self:setCtrlVisible("TasteButton", true, panel)
    self:setCtrlEnabled("TasteButton", true, panel)
    
    self:setCtrlVisible("SurplusLabel", true, panel)
end

-- 获取当前特殊菜肴距离刷新时间
function ChongYangFoodDlg:getRefreshLeftTime()
    local zeroTime = gf:getServerTodayZeroTime() -- 当天5:00
    local firstNodeTime = zeroTime + 7 * 3600    -- 当天12:00
    local secondNodeTime = zeroTime + 13 * 3600  -- 当天18:00
    local thirdNodeTime = zeroTime + 17 * 3600   -- 当天22:00
    local currentTime = gf:getServerTime()
    local leftTime = 0
    
    if currentTime <= firstNodeTime then
        leftTime = firstNodeTime - currentTime
    elseif currentTime > firstNodeTime and currentTime <= secondNodeTime then
        leftTime = secondNodeTime - currentTime
    elseif currentTime > secondNodeTime and currentTime <= thirdNodeTime then
        leftTime = thirdNodeTime - currentTime
    elseif currentTime > thirdNodeTime then
        leftTime = thirdNodeTime - currentTime + 14 * 3600
    end
    
    return leftTime
end

-- 显示刷新菜肴倒计时
function ChongYangFoodDlg:showRefreshTime(time)
    local hour = math.floor(time / 3600) % 24
    local min = math.floor(time / 60) % 60
    local sec = time % 60
    local timeStr = string.format("%02d:%02d:%02d", hour, min, sec)
    self:setLabelText("TimeLabel", timeStr, "YangRouPanel")
    self:setCtrlVisible("TimeLabel", true, "YangRouPanel")
    self:setLabelText("TimeLabel", timeStr, "DaPanXiePanel")
    self:setCtrlVisible("TimeLabel", true, "DaPanXiePanel")
    self:setLabelText("TimeLabel", timeStr, "NiuRouBaoPanel")
    self:setCtrlVisible("TimeLabel", true, "NiuRouBaoPanel")
end

-- 开启倒计时
function ChongYangFoodDlg:setScheduleStart(leftTime)
    self:showRefreshTime(leftTime)

    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            if leftTime > 0 then
                -- 显示倒计时
                self:showRefreshTime(leftTime)
                leftTime = leftTime - 1
            else
                -- 停止倒计时
                self:showRefreshTime(0)
                gf:CmdToServer("CMD_CHONGYANG_2017_TASTE", {npc_id = self.npcId, no = 0})
                self:clearSchedule()
            end
        end, 1)
    end
end

-- 停止倒计时
function ChongYangFoodDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end
end

function ChongYangFoodDlg:cleanup()
    self:clearSchedule()
end

-- 与策划沟通，此界面需要在玩家远离npc后被关闭
function ChongYangFoodDlg:onUpdate()
    if not CharMgr:getChar(self.npcId) then
        -- 远离NPC了
        self:onCloseButton()
    end
end

function ChongYangFoodDlg:onTasteButton(sender, eventType)
    -- 战斗中不可进行此操作
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[7100040])
        return
    end
    
    -- 美食也需细嚼慢咽，两次品尝菜肴不能小于1秒钟
    if gf:getServerTime() - self.lastTasteTime < 1 then
        gf:ShowSmallTips(CHS[7100041])
        return
    end
    
    -- 当前饱食度无法品尝此菜肴
    local senderTag = sender.tag
    if self.taste + TASTE_MAP[senderTag] > 100 then
        gf:ShowSmallTips(CHS[7100042])
        return
    end
    
    -- 当前菜肴已经被吃光了，下次上菜时间再来品尝吧
    if senderTag == 3 and self.amount1 <= 0 or senderTag == 4 and self.amount2 <= 0 or senderTag == 5 and self.amount3 <= 0 then
        gf:ShowSmallTips(CHS[7100043])
        return
    end
    
    gf:CmdToServer("CMD_CHONGYANG_2017_TASTE", {npc_id = self.npcId, no = sender.tag})
    self.lastTasteTime = gf:getServerTime()
end

function ChongYangFoodDlg:MSG_CHONGYANG_2017_TASTE(data)
    self.npcId = data.npc_id
    self.npcType = data.type
    self.taste = data.taste
    self:setProgressBar("ExpProgressBar", self.taste, 100)
    self:setLabelText("ExpValueLabel", string.format("%d/%d", self.taste, 100))
    
    self.amount1 = data.amount1
    self.amount2 = data.amount2
    self.amount3 = data.amount3
    
    -- 帮派宴席
    if self.npcType == 1 then
        self:openSpecialFood()
        self:setLabelText("SurplusLabel", string.format(CHS[7100044], self.amount1), "YangRouPanel")
        self:setLabelText("SurplusLabel", string.format(CHS[7100044], self.amount2), "DaPanXiePanel")
        self:setLabelText("SurplusLabel", string.format(CHS[7100044], self.amount3), "NiuRouBaoPanel")
    end
end

return ChongYangFoodDlg
