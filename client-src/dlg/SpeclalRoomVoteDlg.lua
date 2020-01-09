-- SpeclalRoomVoteDlg.lua
-- Created by songcw Dec/11/2018
-- 通天塔神秘房间投票界面

local DugeonVoteDlg = require('dlg/DugeonVoteDlg')
local SpeclalRoomVoteDlg = Singleton("SpeclalRoomVoteDlg", DugeonVoteDlg)

local TITLE = {
    CHS[4010298], CHS[4010295], CHS[4010299], CHS[4010300], CHS[4010301]
}

-- 设置秒数
function SpeclalRoomVoteDlg:setTimeHour()
end

function SpeclalRoomVoteDlg:setTitle(data)

    DugeonVoteDlg.setTitle(self, data)

    self:setCtrlVisible("StopVoteButton", true)

    for i = 1, 5 do
        self:setCtrlVisible("RulePanel_" .. i, false)
    end

    local title = ""
    if data.type == CHS[4010298] then  -- 变戏法
        title = CHS[4010298]
        self:setCtrlVisible("RulePanel_1", true)
    elseif data.type == CHS[4010295] then
        title = CHS[4010295]
        self:setCtrlVisible("RulePanel_2", true)
    elseif data.type == CHS[4010299] then
        title = CHS[4010299]
        self:setCtrlVisible("RulePanel_3", true)
    elseif data.type == CHS[4010300] then
        title = CHS[4010300]
        self:setCtrlVisible("RulePanel_4", true)
    elseif data.type == CHS[4010301] then
        title = CHS[4010301]
        self:setCtrlVisible("RulePanel_5", true)
    end

    self:setLabelText("TitleLabel_1", title)
    self:setLabelText("TitleLabel_2", title)

    -- 第一次需要5s倒计时
    if data.para ~= "" then
        local ret = gf:split(data.para, "|")
        for _, infoStr in pairs(ret) do
            local temp = gf:split(infoStr, ":")
            if Me:queryBasic("gid") == temp[1] and temp[2] == "0" then
                self:setCtrlEnabled("AgreeButton", false)
                self:setHourglassEx(5)
            end
        end
    end
end

function SpeclalRoomVoteDlg:setHourglassEx(time)
    local function hourglassCallBackEx(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil
        end
    end

    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0

    self:setLabelText("Label_1", string.format( CHS[4200638], 5), "AgreeButton")
    self:setLabelText("Label_2", string.format( CHS[4200638], 5), "AgreeButton")

    hourglassCallBackEx()

    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)

        self:setLabelText("Label_1", string.format( CHS[4200638], (time - elapse)), "AgreeButton")
        self:setLabelText("Label_2", string.format( CHS[4200638], (time - elapse)), "AgreeButton")

        if math.max(0, time - elapse) == 0 then
            hourglassCallBackEx()
            self:setCtrlEnabled("AgreeButton", true)
            self:setLabelText("Label_1", CHS[4200639], "AgreeButton")
            self:setLabelText("Label_2", CHS[4200639], "AgreeButton")
        end
    end, 1);
end

function SpeclalRoomVoteDlg:setUiInfo()
    -- 队长不需要同意拒绝
    self:setCtrlVisible("SendNotifyButton", false)

    if self.voteData then
        if "release_brother" == self.voteData.type or "change_appellation" == self.voteData.type then
            -- 结拜相关的投票界面不需要显示震动提醒按钮
            self:setCtrlVisible("SendNotifyButton", false)
        end
    end
end

-- 应服务器要求，都发拒绝消息
function SpeclalRoomVoteDlg:onStopVoteButton()
    self:onRefuseButton()
end


return SpeclalRoomVoteDlg


