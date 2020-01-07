-- CombinedServiceTaskDlg.lua
-- Created by sujl, Apr/21/2018
-- 合服促活跃界面

local CombinedServiceTaskDlg = Singleton("CombinedServiceTaskDlg", Dialog)

local TASKS = {
    ["shimen"] = CHS[2200101],
    ["chubao"] = CHS[2200102],
    ["jingjichang"] = CHS[2200103],
    ["party"] = CHS[2200104],
    ["tongtianta"] = CHS[2200105],
    ["dungeon"] = CHS[2200106],
    ["online"] = CHS[2200107],
    ["friend"] = CHS[2200108],
    ["tongggk"] = CHS[2200109],
    ["xiux"] = CHS[2200110],
    ["tournament"] = CHS[2200111],
}

function CombinedServiceTaskDlg:init()
    self:bindListener("GetRewardButton", self.onGetRewardButton)
    self:setCtrlEnabled("GetRewardButton", false)

    self:setImage("ShansImage", ResMgr:getBigPortrait(6236))

    GiftMgr.lastIndex = "WelfareButton24"
    self:refreshContent()
    GiftMgr:requestMergerLoginActiveRewardData()
    self:hookMsg("MSG_OPEN_HUOYUE_JIANGLI")
    self:hookMsg("MSG_OPEN_WELFARE")
end

-- 刷新信息
function CombinedServiceTaskDlg:refreshContent()
    local info = GiftMgr:getMergeLoginActiveRewardData()
    local cashText, fontColor = gf:getArtFontMoneyDesc(info and info.fetch_silver or 0)
    self:setNumImgForPanel("RewardWordsPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "RewardPanel")
    local count = info and #info.tasks or 0
    local welfareData = GiftMgr:getWelfareData()
    for i = 1, count do
        self:setPanelContent(i, info.tasks[i])
        isFinish = isFinish and info.tasks[i].cur_round >= info.tasks[i].max_round
    end

    for i = count + 1, 3 do
        self:setPanelContent(i)
    end

    -- 活动时间
    if info and info.start_time and info.end_time then
        local startTimeStr = gf:getServerDate(CHS[5420147], tonumber(info.start_time))
        local endTimeStr = gf:getServerDate(CHS[5420147], tonumber(info.end_time))
        self:setLabelText("TitleLabel", CHS[5420137] .. startTimeStr .. " - " .. endTimeStr, "TimePanel")
        self:setCtrlVisible("TimePanel", true, "TimePanel")
    else
        self:setCtrlVisible("TimePanel", false, "TimePanel")
    end

    self:setCtrlEnabled("GetRewardButton", info and (Me:queryBasic("gid") ~= info.char_gid or 0 == info.fetch_flag))
    self:setButtonText("GetRewardButton", (info and Me:queryBasic("gid") == info.char_gid and 1 == info.fetch_flag) and CHS[2200113] or CHS[2200112])
end

function CombinedServiceTaskDlg:setPanelContent(index, data)
    local ctlName = string.format("WorkPanel_%d", index)
    local panel = self:getControl(ctlName, nil, "TaskPanel")
    if not panel then return end

    if data then
        -- 活动名
        self:setLabelText("NameLabel", TASKS[data.task_name], panel)

        -- 活动次数
        self:setLabelText("TimeLabel", string.format("%d/%d", data.cur_round, data.max_round), panel)

        -- 状态
        self:setImage("StateImage",  data.cur_round >= data.max_round and ResMgr.ui.task_finish or ResMgr.ui.task_unfinish, panel)
    end

    panel:setVisible(nil ~= data)
end

-- 领取奖励
function CombinedServiceTaskDlg:onGetRewardButton(sender, eventType)
    GiftMgr:getMergeLoginActiveReward()
end

function CombinedServiceTaskDlg:MSG_OPEN_HUOYUE_JIANGLI(data)
    self:refreshContent()
end

function CombinedServiceTaskDlg:MSG_OPEN_WELFARE(data)
    self:refreshContent()
end

return CombinedServiceTaskDlg