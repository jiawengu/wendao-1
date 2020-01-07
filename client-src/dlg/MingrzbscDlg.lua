-- MingrzbscDlg.lua
-- Created by lixh Mar/27 2018
-- 名人争霸赛程表

local MingrzbscDlg = Singleton("MingrzbscDlg", Dialog)

local SC_SCHEDULE_TYPE = MingrzbjcMgr.SC_SCHEDULE_TYPE

-- 每页队伍信息的数量
local PAGE_CELL_NUM = 4

-- 比赛页码与比赛日、比赛名称的映射
local SC_TYPE_TO_DAY = {
    [MINGRZB_JC_BIG_TYPE.JC128]   = {first = {name = CHS[7120069], day = {2, 2, 3, 3, 4, 4, 5, 5}}, -- 128进32强
        second = {name = CHS[7120068], day= {6, 6, 6, 6, 7, 7, 7, 7}},
        third = {name = CHS[7120067], day = {8, 8, 8, 8, 8, 8, 8, 8}}},
    [MINGRZB_JC_BIG_TYPE.JC32]  = {first ={name = CHS[7120067], day = {8, 8}},    -- 32进8强
        second = {name = CHS[7120066], day = {9, 9}},
        third = {name = CHS[7120065], day = {10, 10}}},
    [MINGRZB_JC_BIG_TYPE.JC8] = {first = {name = CHS[7120065], day = {10}},    -- 8强至总冠军
        second = {name = CHS[7120064], day = {11}},
        third = {name = CHS[7120063], day = {12}}},
}

function MingrzbscDlg:init()
    self:bindListener("MatchTypeButton", self.onMatchTypeButton)
    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1, "MatchTypePanel1")
    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1, "MatchTypePanel2")
    self:bindListener("MatchTypeCheckBox_2", self.onMatchTypeCheckBox_2, "MatchTypePanel2")
    self:bindListener("MatchTypeCheckBox_1", self.onMatchTypeCheckBox_1, "MatchTypePanel3")
    self:bindListener("MatchTypeCheckBox_2", self.onMatchTypeCheckBox_2, "MatchTypePanel3")
    self:bindListener("MatchTypeCheckBox_3", self.onMatchTypeCheckBox_3, "MatchTypePanel3")
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindFloatPanelListener("MatchTypePanel1")
    self:bindFloatPanelListener("MatchTypePanel2")
    self:bindFloatPanelListener("MatchTypePanel3")
    
    self:setCtrlVisible("MatchTypePanel1", false)
    self:setCtrlVisible("MatchTypePanel2", false)
    self:setCtrlVisible("MatchTypePanel3", false)
    self:setCtrlVisible("MatchPanel", false)
    self:setCtrlVisible("FinalsPanel", false)

    self:hookMsg("MSG_LOOKON_COMBAT_RECORD_DATA")

    self.type = nil
    self.page = nil
end

-- 刷新赛程菜单与页码
function MingrzbscDlg:refreshMenuList()
    self:setButtonText("MatchTypeButton", SC_SCHEDULE_TYPE[self.type].name)
    self:setCtrlVisible("MatchTypePanel1", false)
    self:setCtrlVisible("MatchTypePanel2", false)
    self:setCtrlVisible("MatchTypePanel3", false)

    self:setColorText(string.format(CHS[7120062], self.page, SC_SCHEDULE_TYPE[self.type].pageNum),
        "PageInfoPanel", "PagePanel", nil, nil, nil, nil, true)
    self:setCtrlEnabled("LeftButton", self.page > 1)
    self:setCtrlEnabled("RightButton", self.page < SC_SCHEDULE_TYPE[self.type].pageNum)
end

-- 刷新赛程时间信息
function MingrzbscDlg:refreshScTime()
    local dayInfo = SC_TYPE_TO_DAY[self.type]
    local root = "MatchPanel"
    if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
        root = "FinalsPanel"
    end

    local info = dayInfo.first
    if info then
        local dayStr = gf:getServerDate(CHS[7120071], MingrzbjcMgr:getDayScTime(info.day[self.page], "start"))
        local textStr = string.format(CHS[7120070], info.name, dayStr)
        self:setLabelText("TimeLabel_1", textStr, root)
    end

    local info = dayInfo.second
    if info then
        local dayStr = gf:getServerDate(CHS[7120071], MingrzbjcMgr:getDayScTime(info.day[self.page], "start"))
        local textStr = string.format(CHS[7120070], info.name, dayStr)
        self:setLabelText("TimeLabel_2", textStr, root)
    end
    
    local info = dayInfo.third
    if info and root == "FinalsPanel" then
        local dayStr = gf:getServerDate(CHS[7120071], MingrzbjcMgr:getDayScTime(info.day[self.page], "start"))
        local textStr = string.format(CHS[7120070], info.name, dayStr)
        self:setLabelText("TimeLabel_3", textStr, root)
    end
end

-- 刷新界面信息
function MingrzbscDlg:refreshDlgInfo(type, page)
    self.type = type
    self.page = page

    self:setCtrlVisible("MatchPanel", true)

    local firstData
    local secondData
    local thirdData
    self.type, self.page, firstData, secondData, thirdData = MingrzbjcMgr:getSchedulePageData(self.type, self.page)

    -- 刷新菜单
    self:refreshMenuList()
    
    -- 刷比赛时间
    self:refreshScTime()

    if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
        for i = 1, PAGE_CELL_NUM / 2 do
            self:setCellInfo(firstData, secondData, thirdData, i, "FinalsPanel")
        end

        self:setFinalInfo(MingrzbjcMgr:getScheduleChampionData())

        self:setCtrlVisible("FinalsPanel", true)
        self:setCtrlVisible("MatchPanel", false)
    else
        for i = 1, PAGE_CELL_NUM do
            self:setCellInfo(firstData, secondData, thirdData, i, "MatchPanel")
        end

        self:setCtrlVisible("FinalsPanel", false)
        self:setCtrlVisible("MatchPanel", true)
    end
end

function MingrzbscDlg:setCellInfo(firstData, secondData, thirdData, index, root)
    local root = self:getControl("MatchPanel_" .. index, Const.UIPanel, root)
    local panel1 = self:getControl("Panel_1", Const.UIPanel, root)
    local panel2 = self:getControl("Panel_2", Const.UIPanel, root)
    self:clearRedLine(panel1)
    self:clearRedLine(panel2)

    -- 第1阶段数据
    local info1 = firstData[(index - 1) * PAGE_CELL_NUM + 1]
    local teamPanel1 = self:getControl("TeamPanel_1", Const.UIPanel, panel1)
    self:setPanelTeamInfo(info1, teamPanel1)

    local info2 = firstData[(index - 1) * PAGE_CELL_NUM + 2]
    local teamPanel2 = self:getControl("TeamPanel_2", Const.UIPanel, panel1)
    self:setPanelTeamInfo(info2, teamPanel2)

    local info3 = firstData[(index - 1) * PAGE_CELL_NUM + 3]
    local teamPanel3 = self:getControl("TeamPanel_1", Const.UIPanel, panel2)
    self:setPanelTeamInfo(info3, teamPanel3)

    local info4 = firstData[(index - 1) * PAGE_CELL_NUM + 4]
    local teamPanel4 = self:getControl("TeamPanel_2", Const.UIPanel, panel2)
    self:setPanelTeamInfo(info4, teamPanel4)

    -- 第2阶段数据
    local secondDay = SC_TYPE_TO_DAY[self.type].second.day[self.page]
    self:setCtrlVisible("VSImage", false, panel1)
    local parentPanel = self:getControl("ResultImage", nil, panel1)
    self:setLabelText("Label", "", parentPanel)
    if #secondData> 0 and secondData[(index -1) * 2 + 1] then
        local info5 = secondData[(index - 1) * 2 + 1]
        parentPanel:setVisible(true)
        local icon = MingrzbjcMgr:getScheduleTeamIcon(info5.teamId)
        self:setLabelText("Label", icon, parentPanel)

        -- 有结果设置红线
        self:setWinRedLine(teamPanel1, teamPanel2, icon)
    elseif gf:isSameDay(MingrzbjcMgr:getDayScTime(SC_TYPE_TO_DAY[self.type].first.day[self.page]), gf:getServerTime()) then
        -- 当日比赛显示vs
        self:setCtrlVisible("VSImage", true, panel1)
    else
        -- 可以投票，比赛还未开始
        self:setLabelText("Label", CHS[7120073], parentPanel)
    end

    self:setCtrlVisible("VSImage", false, panel2)
    local parentPanel = self:getControl("ResultImage", nil, panel2)
    self:setLabelText("Label", "", parentPanel)
    if #secondData > 0 and secondData[(index -1) * 2 + 2] then
        local info6 = secondData[(index -1) * 2 + 2]
        parentPanel:setVisible(true)
        local icon = MingrzbjcMgr:getScheduleTeamIcon(info6.teamId)
        self:setLabelText("Label", icon, parentPanel)

        -- 有结果设置红线
        self:setWinRedLine(teamPanel3, teamPanel4, icon)
    elseif gf:isSameDay(MingrzbjcMgr:getDayScTime(SC_TYPE_TO_DAY[self.type].first.day[self.page]), gf:getServerTime()) then
        -- 当日比赛显示vs
        self:setCtrlVisible("VSImage", true, panel2)
    else
        -- 可以投票，比赛还未开始
        self:setLabelText("Label", CHS[7120073], parentPanel)
    end

    -- 第3段数据
    local thirdDay = SC_TYPE_TO_DAY[self.type].third.day[self.page]
    local vsPanel = self:getControl("VSPanel", nil , root)
    self:setLabelText("Label", "", vsPanel)
    if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
        vsPanel = root
    else
        self:setCtrlVisible("VSImage", false, vsPanel)
    end

    if #thirdData > 0 and thirdData[index] then
        local info7 = thirdData[index]
        local icon = MingrzbjcMgr:getScheduleTeamIcon(info7.teamId)
        local resultImage = self:getControl("ResultImage", nil, vsPanel)
        if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
            resultImage = self:getControl("ResultImage_1", nil, vsPanel)
        end

        self:setLabelText("Label", icon, resultImage)

        -- 有结果设置红线
        local lineImage1
        local lineImage2
        local panelImage1 = self:getControl("ResultImage", nil, panel1)
        local panelImage2 = self:getControl("ResultImage", nil, panel2)
        if icon and tonumber(self:getLabelText("Label", panelImage1)) == icon then
            lineImage1 = self:getControl("TeamLineImage_1", nil, panel1)
            lineImage2 = self:getControl("TeamLineImage_2", nil, panel1)
        elseif icon and tonumber(self:getLabelText("Label", panelImage2)) == icon then
            lineImage1 = self:getControl("TeamLineImage_1", nil, panel2)
            lineImage2 = self:getControl("TeamLineImage_2", nil, panel2)
        end

        if lineImage1 then
            lineImage1:setColor(COLOR3.RED)
        end

        if lineImage2 then
            lineImage2:setColor(COLOR3.RED)
        end
    elseif gf:isSameDay(MingrzbjcMgr:getDayScTime(SC_TYPE_TO_DAY[self.type].second.day[self.page]), gf:getServerTime()) then
        -- 当日比赛
        if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
            -- 策划要求半决赛特殊显示
            local resultImage = self:getControl("ResultImage_1", nil, vsPanel)
            self:setLabelText("Label", CHS[7120072], resultImage)
        else
            self:setCtrlVisible("VSImage", true, vsPanel)
        end
    else
        -- 非当日比赛显示?
        if self.type == MINGRZB_JC_BIG_TYPE.JC8 then
            -- 策划要求半决赛特殊显示
            local resultImage = self:getControl("ResultImage_1", nil, vsPanel)
            self:setLabelText("Label", CHS[7120072], resultImage)
        else
            self:setLabelText("Label", "?", vsPanel)
        end
    end

    -- 刷新底座
    if self.type == MINGRZB_JC_BIG_TYPE.JC32 then
        self:setImage("BKImage_2", ResMgr.ui.mingrzb_jc_win_8, vsPanel)
    else
        self:setImage("BKImage_2", ResMgr.ui.mingrzb_jc_win_32, vsPanel)
    end
end

function MingrzbscDlg:setFinalInfo(data)
    local root = self:getControl("FinalsPanel")
    local panel1 = self:getControl("MatchPanel_1", nil, root)
    local panel2 = self:getControl("MatchPanel_2", nil, root)
    local line1 = self:getControl("TeamLineImage_1", nil, panel1)
    line1:setColor(COLOR3.WHITE)
    local line2 = self:getControl("TeamLineImage_1", nil, panel2)
    line2:setColor(COLOR3.WHITE)

    local finalPanel = self:getControl("FinalPanel", nil, root)
    if data then
        local icon = MingrzbjcMgr:getScheduleTeamIcon(data.teamId)
        self:setLabelText("Label", data.leaderName, finalPanel)

        -- 有结果设置红线
        local lineImage
        if icon and tonumber(self:getLabelText("Label", panel1)) == icon then
            lineImage = self:getControl("TeamLineImage_1", nil, panel1)
        elseif icon and tonumber(self:getLabelText("Label", panel2)) == icon then
            lineImage = self:getControl("TeamLineImage_1", nil, panel2)
        end

        if lineImage then
            lineImage:setColor(COLOR3.RED)
        end
    else
        self:setLabelText("Label", "?", finalPanel)
    end
end

-- 设置胜利方红线
function MingrzbscDlg:setWinRedLine(panel1, panel2, icon, notSetGray)
    if not notSetGray then
        self:resetPanelGray(panel1)
        self:resetPanelGray(panel2)
    end

    local lineImage1
    local lineImage2
    if icon and tonumber(self:getLabelText("Label", panel1)) == icon then
        lineImage1 = self:getControl("TeamLineImage_1", nil, panel1)
        lineImage2 = self:getControl("TeamLineImage_2", nil, panel1)
        if not notSetGray then
            self:setPanelGray(panel2)
        end
    elseif icon and tonumber(self:getLabelText("Label", panel2)) == icon then
        lineImage1 = self:getControl("TeamLineImage_1", nil, panel2)
        lineImage2 = self:getControl("TeamLineImage_2", nil, panel2)
        if not notSetGray then
            self:setPanelGray(panel1)
        end
    else
        -- 编号不存在、或找不到对应的，认为两只队伍都失败
        if not notSetGray then
            self:setPanelGray(panel2)
            self:setPanelGray(panel1)
        end
    end

    if lineImage1 then
        lineImage1:setColor(COLOR3.RED)
    end

    if lineImage2 then
        lineImage2:setColor(COLOR3.RED)
    end
end

-- 置灰地板
function MingrzbscDlg:setPanelGray(panel)
    local img = self:getControl("BKImage", nil, panel)
    gf:grayImageView(img)
end

-- 重置地板
function MingrzbscDlg:resetPanelGray(panel)
    local img = self:getControl("BKImage", nil, panel)
    gf:resetImageView(img)
end

-- 清除panel红线
function MingrzbscDlg:clearRedLine(panel)
    local line1 = self:getControl("TeamLineImage_1", nil, panel)
    line1:setColor(COLOR3.WHITE)
    
    local line2 = self:getControl("TeamLineImage_2", nil, panel)
    line2:setColor(COLOR3.WHITE)
    
    local teamPanel1 = self:getControl("TeamPanel_1", nil, panel)
    local line3 = self:getControl("TeamLineImage_1", nil, teamPanel1)
    line3:setColor(COLOR3.WHITE)

    local line4 = self:getControl("TeamLineImage_2", nil, teamPanel1)
    line4:setColor(COLOR3.WHITE)
    
    local teamPanel2 = self:getControl("TeamPanel_2", nil, panel)
    local line5 = self:getControl("TeamLineImage_1", nil, teamPanel2)
    line5:setColor(COLOR3.WHITE)

    local line6 = self:getControl("TeamLineImage_2", nil, teamPanel2)
    line6:setColor(COLOR3.WHITE)
end

-- 设置Panel上队伍名称与id
function MingrzbscDlg:setPanelTeamInfo(data, panel)
    self:resetPanelGray(panel)
    if data and data.isCanUse == 1 and data.teamId ~= "" then
        -- 名称
        self:setLabelText("TeamLabel", data.leaderName, panel)

        -- 编号
        self:setLabelText("Label", MingrzbjcMgr:getScheduleTeamIcon(data.teamId), panel)

        -- id
        panel.teamId = data.teamId

        self:bindTouchEndEventListener(panel, function()
            -- 打开队伍界面
            MingrzbjcMgr:fetchScTeamInfo(panel.teamId)
        end)
    else
        self:setLabelText("TeamLabel", CHS[7120061], panel)
        self:setLabelText("Label", "", panel)
        panel.teamId = nil
    end
end

function MingrzbscDlg:cleanup()
    self.type = nil
    self.page = nil
end

function MingrzbscDlg:onMatchTypeButton(sender, eventType)
    local menuPanel = "MatchTypePanel1"
    if #MingrzbjcMgr:getScheduleData()[MINGRZB_JC_BIG_TYPE.JC8] > 0 then
        menuPanel = "MatchTypePanel3"
    elseif #MingrzbjcMgr:getScheduleData()[MINGRZB_JC_BIG_TYPE.JC32] > 0 then
        menuPanel = "MatchTypePanel2"
    end

    self:setCtrlVisible(menuPanel, not self:getControl(menuPanel):isVisible())
end

function MingrzbscDlg:onMatchTypeCheckBox_1(sender, eventType)
    if self.type ~= MINGRZB_JC_BIG_TYPE.JC128 then
        self:refreshDlgInfo(MINGRZB_JC_BIG_TYPE.JC128)
    end
end

function MingrzbscDlg:onMatchTypeCheckBox_2(sender, eventType)
    if self.type ~= MINGRZB_JC_BIG_TYPE.JC32 then
        self:refreshDlgInfo(MINGRZB_JC_BIG_TYPE.JC32)
    end
end

function MingrzbscDlg:onMatchTypeCheckBox_3(sender, eventType)
    if self.type ~= MINGRZB_JC_BIG_TYPE.JC8 then
        self:refreshDlgInfo(MINGRZB_JC_BIG_TYPE.JC8)
    end
end

function MingrzbscDlg:onLeftButton(sender, eventType)
    self.page = math.max(self.page - 1, 1)
    self:refreshDlgInfo(self.type, self.page)
end

function MingrzbscDlg:onRightButton(sender, eventType)
    self.page = math.min(self.page + 1, SC_SCHEDULE_TYPE[self.type].pageNum)
    self:refreshDlgInfo(self.type, self.page)
end

-- 进入观战，关闭界面
function MingrzbscDlg:MSG_LOOKON_COMBAT_RECORD_DATA()
    self:onCloseButton()
end

return MingrzbscDlg
