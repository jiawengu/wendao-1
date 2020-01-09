-- WenqxDlg.lua
-- Created by songcw Jan/25/2019
-- 文曲星答题界面

local WenqxDlg = Singleton("WenqxDlg", Dialog)

local ITEM_LIST = {
    CHS[4010377],      CHS[4010378],      CHS[4010379]
}

local STAGE_MAP = {
    ["stage_1"] = "StagePanel_1",
    ["stage_2"] = "StagePanel_2",
    ["stage_3"] = "StagePanel_3",
}

local LETTER = {
    "A ",       "B ",       "C ",        "D "
}

local MAX_LEFT_TIME = 25

function WenqxDlg:init(data)
    self:bindListener("QuitButton", self.onFangqiButton, "QuitPanel")
    self:bindListener("QuitButton", self.onContinueButton, "ContinuePanel")
    self:bindListener("QuitButton", self.onQuitButton, "ResultPanel_2")
    self:bindListener("NoteButton", self.onNoteButton)


    self.isNotConfirm = false
    self.isLock = false

    for i = 1, 3 do
        local panel = self:getControl("ItemPanel_" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onItemButton)
    end

    for i = 1, 4 do
        local panel = self:getControl("AnswerPanel_" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onChoiceButton)
    end

    self:setQuestionData(data)

    self:hookMsg("MSG_WQX_QUESTION_DATA")
    self:hookMsg("MSG_WQX_STAGE_RESULT")
end


function WenqxDlg:getMaxTime()
    if not self.data then return MAX_LEFT_TIME end

    local maxTi = self.data.end_time - self.data.start_time
    return maxTi
end

function WenqxDlg:onChoiceButton(sender, eventType)

    if self.isLock then return end

    if sender.isRemoved then
        gf:ShowSmallTips(CHS[4200640])
        return
    end

    local tag = sender:getTag()
    self:setCtrlVisible("ChosenImage", true, sender)

    local answer = gfDecrypt(self.data.ret, "wenqx")

    local tab = gf:split(answer, ",")
    answer = tonumber(tab[2])

    self:setCtrlVisible("RightImage", answer == tag, sender)
    self:setCtrlVisible("WrongImage", answer ~= tag, sender)
    self:setCtrlEnabled(sender:getName(), false)

    self.isLock = true

    gf:CmdToServer("CMD_WQX_ANSWER_QUESTION", {stage = self.data.stage, question_no = self.data.question_no, answer = self.data.answers[tag].text})

    performWithDelay(sender, function ()
        -- body
        gf:CmdToServer("CMD_WQX_FINISH_QUESTION", {stage = self.data.stage, question_no = self.data.question_no})
    end, 0.5)
end

function WenqxDlg:onItemButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(ITEM_LIST[sender:getTag()], rect)

    local dlg = DlgMgr:getDlgByName("ItemInfoDlg")
    dlg:setLabelText("Label_16", CHS[4010380], "ResourceButton")

    self.selectItem = sender

    local eff = sender:getChildByTag(999)
    if eff then eff:removeFromParent() end
end

function WenqxDlg:useItem()
    if not self.selectItem then return end

    if self.selectItem.amount <= 0 then
        gf:ShowSmallTips(string.format( CHS[4101318], ITEM_LIST[self.selectItem:getTag()]))
        return
    end

    gf:CmdToServer("CMD_WQX_APPLY_ITEM", {item_name = ITEM_LIST[self.selectItem:getTag()]})
end

function WenqxDlg:onNoteButton(sender, eventType)
    if not self.data then return end

    DlgMgr:openDlgEx("WenqxRuleDlg", self.data)
end

function WenqxDlg:onCloseButton(sender, eventType)
    if self.isNotConfirm then
        self:onQuitButton()
    else
        if self:getCtrlVisible("AnswerPanel") then
            gf:confirm(CHS[4010381], function ()
            -- body
                gf:CmdToServer("CMD_WQX_CLOSE_DLG", {stage = self.data.stage})
                DlgMgr:closeDlg("WenqxDlg")
            end)
        else
            self:onFangqiButton()
        end
    end
end

function WenqxDlg:setQuestionData(data)
    if not data then return end

    if self.data and data.end_time > self.data.end_time and self.data.question_no == data.question_no then
        -- 时间有加长，给一个效果
        local panel = self:getControl("TimePanel", nil, "QuestionPanel")
        local big = cc.ScaleTo:create(0.1, 1.5, 1.5)
        local normal = cc.ScaleTo:create(0.1, 1, 1)
        panel:runAction(cc.Sequence:create(big, normal))
    end

    self.data = data

--[[答案提示！
    local answer = gfDecrypt(self.data.ret, "wenqx")
    local tab = gf:split(answer, ",")
    answer = tonumber(tab[2])
    gf:ShowSmallTips(answer)
--]]

    self:setCtrlVisible("ResultPanel_1", false)
    self:setCtrlVisible("ResultPanel_2", false)
    self:setCtrlVisible("AnswerPanel", true)

    -- 关卡
    for stg, panelName in pairs(STAGE_MAP) do
        if data.stage == stg then
            self:setCtrlVisible("Panel_1", true, panelName)
            self:setCtrlVisible("Panel_2", false, panelName)
        else
            self:setCtrlVisible("Panel_1", false, panelName)
            self:setCtrlVisible("Panel_2", true, panelName)
        end
    end

    local questionNumStr = string.format( "(%d/3) ", data.question_no)

    -- 设置题目
    self:setLabelText("QuestionLabel", questionNumStr .. data.question)

    -- 设置倒计时
    self:setHourglass(math.min( self:getMaxTime(), data.end_time - gf:getServerTime()))

    -- 设置答案
    for i = 1, 4 do
        local panel = self:getControl("AnswerPanel_" .. i)
        if data.answers[i] then
            self:setLabelText("AnswerLabel", LETTER[i] .. data.answers[i].text, panel)
            panel:setVisible(true)

            panel.isRemoved = false


            if data.removed_item ~= "" and data.removed_item == data.answers[i].text then
                self:setLabelText("AnswerLabel", "", panel)
                panel.isRemoved = true
            end

            local votePanel = self:setCtrlVisible("VotePanel", data.is_use_help == 1, panel)
            if data.is_use_help == 1 and data.answers[i] then
                self:setLabelText("Label", data.answers[i].help_times, votePanel)
            end

        else
            panel:setVisible(false)
        end
        panel:setEnabled(true)

        self:setCtrlVisible("ChosenImage", false, panel)
        self:setCtrlVisible("RightImage", false, panel)
        self:setCtrlVisible("WrongImage", false, panel)
    end

    -- 相关卡片
    --self:setImage("GoodsImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName("加时卡")))
    local amount = {data.item_js, data.item_ts, data.item_qz}
    for i = 1, 3 do
        local panel = self:getControl("ItemPanel_" .. i)
        panel.amount = amount[i]
        self:setImage("GoodsImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(ITEM_LIST[i])), panel)
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount[i], false, LOCATE_POSITION.RIGHT_BOTTOM, 21, panel)
        self:setLabelText("Label", ITEM_LIST[i], panel)
    end
end

function WenqxDlg:setHourglass(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0

    self:setLabelText("Label_1", tostring(time), "TimePanel")
    if self.timerId then
        gf:Unschedule(self.timerId)
    end

    local function hourglassCallBack(parameters)
        if self.timerId then
            gf:Unschedule(self.timerId)
            self.timerId = nil

            if not self.isLock then
                gf:CmdToServer("CMD_WQX_ANSWER_QUESTION", {stage = self.data.stage, question_no = self.data.question_no, answer = ""})
            end
        end
    end

    self.timerId = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)

        self:setLabelText("Label_1", tostring(math.max(0, time - elapse)), "TimePanel")

        if math.max(0, time - elapse) == 0 then
            hourglassCallBack()
        end
    end, 1)
end

function WenqxDlg:setHourglassForFangqi(time)
    -- 开始180s倒计时
    local startTime = gf:getServerTime()
    local elapse = 0

    local panel = self:getControl("QuitButton", nil, "ResultPanel_1")
    self:setLabelText("TimeLabel_1", "(" .. tostring(time) .. ")", panel)
    self:setLabelText("Time2Label_2", "(" .. tostring(time) .. ")", panel)
    if self.timerId2 then
        gf:Unschedule(self.timerId2)
        self.timerId2 = nil
    end

    local function hourglassCallBack(parameters)
        if self.timerId2 then
            gf:Unschedule(self.timerId2)
            self.timerId2 = nil
        end
    end

    self.timerId2 = gf:Schedule(function()
        elapse = math.max(0, gf:getServerTime() - startTime)

        local panel = self:getControl("QuitButton", nil, "ResultPanel_1")
        self:setLabelText("TimeLabel_1", "(" .. tostring(math.max(0, time - elapse)).. ")", panel)
        self:setLabelText("Time2Label_2", "(" .. tostring(math.max(0, time - elapse)).. ")", panel)

        if math.max(0, time - elapse) == 0 then
            hourglassCallBack()
        end
    end, 1)
end

function WenqxDlg:cleanup()
    self.data = nil
    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end
end

function WenqxDlg:onFangqiButton(sender, eventType)
    gf:confirm(CHS[4010382], function ( )
        self:onQuitButton()
    end)
end

function WenqxDlg:onQuitButton(sender, eventType)
    gf:CmdToServer("CMD_WQX_FINISH_GAME")
    DlgMgr:closeDlg(self.name)
end

function WenqxDlg:onContinueButton(sender, eventType)
    gf:CmdToServer("CMD_WQX_NEXT_STAGE")
end

function WenqxDlg:MSG_WQX_QUESTION_DATA(data)
    if data.stage == "verify" then
        self:onCloseButton()
        return
    end

    if self.timerId2 then
        gf:Unschedule(self.timerId2)
        self.timerId2 = nil
    end

    self.isLock = false

    if self.data then            -- 增加光效
        local magic = {}
        magic.name = ResMgr.ArmatureMagic.point_head_eff.name
        magic.action = "Bottom01"

        if data.item_js > self.data.item_js then
            local panel = self:getControl("ItemPanel_" .. 1)
            gf:createArmatureMagic(magic, panel, 999, 0, 0)
        elseif data.item_ts > self.data.item_ts then
            local panel = self:getControl("ItemPanel_" .. 2)
            gf:createArmatureMagic(magic, panel, 999, 0, 0)
        elseif data.item_qz > self.data.item_qz then
            local panel = self:getControl("ItemPanel_" .. 3)
            gf:createArmatureMagic(magic, panel, 999, 0, 0)
        end
    end

    self:setQuestionData(data)
end

function WenqxDlg:setWin(data)
    local temp = TaskMgr:getRewardList(data.bonus_desc)
    if temp and temp[1] then
        local rewardTab = temp[1]
        local panel = self:getControl("RewardPanel_1")
        for i = 1, 2 do
            if rewardTab[i] then
                local value
                local res = ResMgr.ui.daohang
                if rewardTab[i][1] == CHS[4100805] then -- 道行
                    res = ResMgr.ui.daohang
                    value = tonumber(string.match(rewardTab[i][2], "#r(%d+)"))
                    value = gf:getTaoStr(value)
                elseif rewardTab[i][1] == CHS[5410085] then -- 武学
                    res = ResMgr.ui.big_wuxue
                    value = tonumber(string.match(rewardTab[i][2], "#r(%d+)"))
                end
                self:setImagePlist("RewardImage_" .. i, res, panel)


                self:setLabelText("NumLabel_" .. i, value .. CHS[7100071])
                self:setCtrlVisible("RewardImage_" .. i, true)
                self:setCtrlVisible("NumLabel_" .. i, true)
            else
                self:setCtrlVisible("RewardImage_" .. i, false, panel)
                self:setCtrlVisible("NumLabel_" .. i, false, panel)
            end
        end
    else
        -- 异常情况
    end

    self:setHourglassForFangqi(math.min( 30, data.end_time - gf:getServerTime()))

    -- 随机获得奖励
    local num = tonumber(string.match(data.stage, "stage_(%d+)"))
    local gotPanel = self:getControl("RewardPanel_2", nil, "ResultPanel_1")

    local continuePanel = self:getControl("ContinuePanel", nil, "ResultPanel_1")
    local continueGetPanel = self:getControl("RewardPanel", nil, "ResultPanel_1")
    for i = 1, 3 do
        -- 已经获得栏中   概率获得物品
        if num >= i then
            self:setCtrlVisible("RewardImage_" .. i, true, gotPanel)
            self:setCtrlVisible("NumLabel_" .. i, true, gotPanel)
        else
            self:setCtrlVisible("RewardImage_" .. i, false, gotPanel)
            self:setCtrlVisible("NumLabel_" .. i, false, gotPanel)
        end

        -- 继续闯关可获得
        if num + 1 >= i then
            self:setCtrlVisible("RewardImage_" .. i, true, continueGetPanel)
            self:setCtrlVisible("NumLabel_" .. i, true, continueGetPanel)
        else
            self:setCtrlVisible("RewardImage_" .. i, false, continueGetPanel)
            self:setCtrlVisible("NumLabel_" .. i, false, continueGetPanel)
        end
    end
end

function WenqxDlg:setLose(data)
    local temp = TaskMgr:getRewardList(data.bonus_desc)
    if temp and temp[1] then
        local panel = self:getControl("ResultPanel_2")
        local rewardTab = temp[1]

        -- 不显示武学
        local removeIdx = 0
        for i = 1, #rewardTab do
            if rewardTab[i][1] == CHS[5410085] then
                removeIdx = i
            end
        end
        table.remove( rewardTab, removeIdx )

        for i = 1, 4 do
            if rewardTab[i] then
                local res = ResMgr.ui.daohang
                local str
                if rewardTab[i][1] == CHS[4100805] then     -- 道行
                    res = ResMgr.ui.daohang
                    local num = tonumber(string.match(rewardTab[i][2], "#r(%d+)"))
                    str =  gf:getTaoStr(num).. CHS[7100071]
                elseif rewardTab[i][1] == CHS[5410085] then         -- 武学
                    str = tonumber(string.match(rewardTab[i][2], "#r(%d+)")) .. CHS[7100071]
                    res = ResMgr.ui.big_wuxue
                elseif rewardTab[i][1] == CHS[3002169] then -- 未鉴定
                    res = ResMgr.ui.big_equip
                    str = CHS[4101227]
                elseif rewardTab[i][1] == CHS[3002864] then -- 装备
                    res = ResMgr.ui.big_equip
                    str = CHS[4101227] --"装备"
                elseif rewardTab[i][1] == CHS[3002166] then -- 物品
                    res = ResMgr.ui.item_common
                    str = gf:splitBydelims(rewardTab[i][2], {"%", "$", "#r"})[1]
                elseif rewardTab[i][1] == CHS[3002168] then -- 首饰
                    res = ResMgr.ui.big_jewelry
                    str = gf:splitBydelims(rewardTab[i][2], {"%", "$", "#r"})[1]
                end
                self:setImagePlist("RewardImage_" .. i, res, panel)
                self:setLabelText("NumLabel_" .. i, str, panel)

                self:setCtrlVisible("RewardImage_" .. i, true)
                self:setCtrlVisible("NumLabel_" .. i, true)
            else
                self:setCtrlVisible("RewardImage_" .. i, false, panel)
                self:setCtrlVisible("NumLabel_" .. i, false, panel)
            end
        end

    end
end

function WenqxDlg:setResultData(data)

    if data.success == 1 then

        if data.stage == "stage_3" then
            self.isNotConfirm = true
            self:setLose(data)      -- stage_3 胜利要显示失败的panel，修改成功、失败label
            self:setLabelText("TitleLabel", CHS[4010384], "ResultPanel_2")        -- 闯关成功
        else
            self:setWin(data)
        end
    else
        self.isNotConfirm = true
        self:setLose(data)
    end
end

function WenqxDlg:MSG_WQX_STAGE_RESULT(data)
    self:setCtrlVisible("AnswerPanel", false)

    DlgMgr:closeDlg("ItemInfoDlg")

    self:setCtrlVisible("ResultPanel_1", data.success == 1)
    self:setCtrlVisible("ResultPanel_2", data.success == 0)

    if self.timerId then
        gf:Unschedule(self.timerId)
        self.timerId = nil
    end

    -- 如果最后一关闯关成功，需要显示 ResultPanel_2
    if data.success == 1 and data.stage == "stage_3" then
        self:setCtrlVisible("ResultPanel_1", false)
        self:setCtrlVisible("ResultPanel_2", true)
    end

    self:setResultData(data)

    local num = tonumber(string.match(data.stage, "stage_(%d+)"))
    for i = 1, 3 do
        local panel = self:getControl("StagePanel_" .. i)
        if num > i then
            self:setCtrlVisible("SuccImage", true, panel)
            self:setCtrlVisible("FailImage",  false, panel)
        elseif num == i then
            self:setCtrlVisible("SuccImage", data.success == 1, panel)
            self:setCtrlVisible("FailImage",  data.success == 0, panel)
        else
            self:setCtrlVisible("SuccImage", false, panel)
            self:setCtrlVisible("FailImage", false, panel)
        end
    end
end


return WenqxDlg
