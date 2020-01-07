-- KuafjjgnDlg.lua
-- Created by huangzz Jan/05/2018
-- 跨服竞技顶部功能界面

local KuafjjgnDlg = Singleton("KuafjjgnDlg", Dialog)

local MODE_IMG = {
    [""]    = ResMgr.ui.kuafjj_combat_no_choose,
    ["1V1"] = ResMgr.ui.kuafjj_combat_1V1,
    ["3V3"] = ResMgr.ui.kuafjj_combat_3V3,
    ["5V5"] = ResMgr.ui.kuafjj_combat_5V5,
}

local protectTime = 0
local startTime = 0
local startMatchTime = 0
local endTime = 0
local closeTime = 0

function KuafjjgnDlg:init()
    self:setFullScreen()
    
    self:bindListener("SelectButton_1", self.onSelectButton_1)
    self:bindListener("SelectButton_2", self.onSelectButton_2)
    self:bindListener("SelectButton_3", self.onSelectButton_3)
    self:bindListener("Button_1", self.onButton_1)
    self:bindListener("Button_2", self.onButton_2)
    
    self:bindFloatPanelListener("NumberFloatPanel", "Button_2", nil, function() 
        self:setNumberFloatVisible(false)
    end)
    
    protectTime = KuafjjMgr.protectTime or 0
    local data = KuafjjMgr.matchTimeData or {}
    startTime = data.matchday_start_time or 0
    startMatchTime = data.matchday_pair_time or 0
    endTime = data.matchday_end_time or 0
    closeTime = data.matchday_close_time or 0
    
    self.schedulId = nil
    
    self:setLabelText("LeftLabel", "")
    
    self:setDownTime()
    
    self:hookMsg("MSG_CSC_NOTIFY_COMBAT_MODE")
    self:hookMsg("MSG_CSC_PROTECT_TIME")
    self:hookMsg("MSG_CSC_MATCHDAY_DATA")
end

function KuafjjgnDlg:onSelectButton_1(sender, eventType)
    self:setNumberFloatVisible(false)
    
    KuafjjMgr:requestCombatMode("1V1")
end

function KuafjjgnDlg:onSelectButton_2(sender, eventType)
    self:setNumberFloatVisible(false)
    
    KuafjjMgr:requestCombatMode("3V3")
end

function KuafjjgnDlg:onSelectButton_3(sender, eventType)
    self:setNumberFloatVisible(false)
    
    KuafjjMgr:requestCombatMode("5V5")
end

function KuafjjgnDlg:onButton_1(sender, eventType)
    gf:CmdToServer("CMD_CSC_PLAYER_CONTEST_DATA", {})
end

function KuafjjgnDlg:setNumberFloatVisible(isVisible)
    self:setCtrlVisible("NumberFloatPanel", isVisible)
    
    local str = isVisible and CHS[5400362] or CHS[5400363]
    self:setLabelText("Label_3", str)
    self:setLabelText("Label_4", str)
end

function KuafjjgnDlg:onButton_2(sender, eventType)
    if KuafjjMgr:checkKuafjjIsEnd() then
        return
    end
    
    if GMMgr:isGM() or KuafjjMgr:isKFJJJournalist() then
        gf:ShowSmallTips(CHS[5400425])
        return
    end

    local panel = self:getControl("NumberFloatPanel")
    self:setNumberFloatVisible(not panel:isVisible())
end

function KuafjjgnDlg:setDownTime()
    if not self.schedulId then
        local hasInform = false
        self.schedulId = self:startSchedule(function()
            local curTime = gf:getServerTime()
            local lastTime = -1
            local str
            if curTime < protectTime then
                -- 保护时间
                lastTime = protectTime - curTime
                str = CHS[5400403]
            elseif curTime < startTime then
                -- 开始比赛时间
                lastTime = startTime - curTime
                str = CHS[5400404]
            elseif curTime < startMatchTime then
                -- 可开始匹配时间
                lastTime = startMatchTime - curTime
                str = CHS[5400346]
            elseif curTime < endTime then
                -- 比赛结束时间
                str = CHS[5400347]
                lastTime = endTime - curTime
            elseif curTime <= closeTime then
                -- 关闭战场时间
                str = CHS[5400407]
                lastTime = closeTime - curTime
                
                if not hasInform then
                    DlgMgr:sendMsg("MissionDlg", "displayType")
                    DlgMgr:sendMsg("KuafjjInfoDlg", "setDlgView")
                    hasInform = true
                end
            end
            
            if lastTime >= 0 then
                self:setTime(lastTime, str)
            else
                self:stopSchedule(self.schedulId)
                self.schedulId = nil
            end
        end, 1)
    end
end

function KuafjjgnDlg:setTime(lastTime, str)
    local min = math.floor(lastTime / 60)
    local sec = lastTime % 60
    local timeStr = string.format("%02d:%02d", min, sec)
    
    self:setLabelText("LeftLabel", str .. " " .. timeStr)
end

function KuafjjgnDlg:MSG_CSC_NOTIFY_COMBAT_MODE(data)
    -- 更新模式
    self:setImage("TypeImage", MODE_IMG[data.combat_mode])
end

function KuafjjgnDlg:MSG_CSC_PROTECT_TIME(data)
    protectTime = data.protect_time
    
    self:setDownTime()
end

function KuafjjgnDlg:MSG_CSC_MATCHDAY_DATA(data)
    startTime = data.matchday_start_time or 0
    startMatchTime = data.matchday_pair_time or 0
    endTime = data.matchday_end_time or 0
    closeTime = data.matchday_close_time or 0
    
    self:setDownTime()
end

return KuafjjgnDlg
