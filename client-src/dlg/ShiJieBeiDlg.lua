-- ShiJieBeiDlg.lua
-- Created by songcw Jun/04/2018
-- 世界杯

local ShiJieBeiDlg = Singleton("ShiJieBeiDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 世界杯小组赛 32 强，按照对战顺序！客户端默认显示，收到服务器消息后会修改
local GROUP_COUNTRIES = {
    --[[
    CHS[4300377],    CHS[4300378],    CHS[4300379],    CHS[4300380],
    CHS[4300381],    CHS[4300382],    CHS[4300383],    CHS[4300384],
    CHS[4300385],    CHS[4300386],    CHS[4300387],    CHS[4300388],
    CHS[4300389],    CHS[4300390],    CHS[4300391],    CHS[4300392],
    CHS[4300393],    CHS[4300394],    CHS[4300395],    CHS[4300396],
    CHS[4300397],    CHS[4300398],    CHS[4300399],    CHS[4300400],
    CHS[4300401],    CHS[4300402],    CHS[4300403],    CHS[4300404],
    CHS[4300405],    CHS[4300406],    CHS[4300407],    CHS[4300408],
    ]]
}

-- 赛制类型
local SJB_GAME_STATE = {
    XIAOZU = 1,     -- 小组
    EIAGHT = 2,     -- 八强
    FOUR   = 3,     -- 四强
    TWO    = 4,     -- 半决赛
    ONE    = 5,     -- 决赛
}

-- 赛制对应的panel
local SJB_GAME_STATE_TO_PANEL = {
    "XiaozPanel", "EightPanel", "FourPanel", "OnePanel", "OnePanel"
}

function ShiJieBeiDlg:init()
    self:bindListener("NextPagePanel", self.onNextPageButton)
    self:bindListener("LastPagePanel", self.onLastPageButton)
    self:bindListener("FenXianButton", self.onFenXianButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:bindListener("CardImage", self.onCostImage, "NumPanel_1")
    self:bindListener("CardImage", self.onCostImage, "NumPanel_2")
    self:bindListener("NameImage_3", self.onShowNotSupTeam, "QiuDuiPanel")

    local effPanel1 = self:getControl("NextPagePanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_left, effPanel1, Const.ARMATURE_MAGIC_TAG, 8)

    local effPanel2 = self:getControl("LastPagePanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_right, effPanel2, Const.ARMATURE_MAGIC_TAG, 8)



    -- 下方主界面按钮
    self.isInitCheckBox = false
    self.support_team = ""
    self.selectName = nil

    self:bindFloatPanelListener("ShareImage")

    -- 有数据先显示（可能从别的标签页切过来）
    local data = ActivityMgr:getShijiebeiData()
    if data then
        if data.stage == CHS[4300415] then
            self:MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP(data)
        else
            self:MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT(data)
        end
    end

    self:MSG_INVENTORY()

    self:hookMsg("MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP")
    self:hookMsg("MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT")
    self:hookMsg("MSG_INVENTORY")
end

-- 初始化单选框
function ShiJieBeiDlg:initCheckBox(stage)
    -- 根据当前比赛类型初始化对应的单选框
    if self.isInitCheckBox == stage then return end
    self.isInitCheckBox = stage

    if stage == SJB_GAME_STATE.XIAOZU then
        -- 小组
        local XZ_CHECK_BOX = {}
        for i = 1, 32 do
            table.insert(XZ_CHECK_BOX, "XZCheckBox_" .. i)
        end
        self.xzRadioGroup = RadioGroup.new()
        self.xzRadioGroup:setItems(self, XZ_CHECK_BOX, self.onCheckBox)
    elseif stage == SJB_GAME_STATE.EIAGHT then
        -- 8强
        local EIGHT_CHECK_BOX = {}
        for i = 1, 16 do
            table.insert(EIGHT_CHECK_BOX, "EIGHTCheckBox_" .. i)
        end
        self.eightRadioGroup = RadioGroup.new()
        self.eightRadioGroup:setItems(self, EIGHT_CHECK_BOX, self.onCheckBox)
    elseif stage == SJB_GAME_STATE.FOUR then
        -- 4强
        local FOUR_CHECK_BOX = {}
        for i = 1, 8 do
            table.insert(FOUR_CHECK_BOX, "FourCheckBox_" .. i)
        end
        --
        for i = 1, 4 do

            self:setCtrlOnlyEnabled("WinFourCheckBox_" .. i, false)
        end

        self.fourRadioGroup = RadioGroup.new()
        self.fourRadioGroup:setItems(self, FOUR_CHECK_BOX, self.onCheckBox)
    elseif stage == SJB_GAME_STATE.TWO then
        local TWO_CHECK_BOX = {}
        for i = 1, 4 do
            table.insert(TWO_CHECK_BOX, "HouXuanCheckBox_" .. i)
        end

        for i = 1, 4 do
            self:setCtrlOnlyEnabled("JSHXCheckBox_" .. i, false)
        end

        self:setCtrlOnlyEnabled("GJCheckBox", false)
        self:setCtrlOnlyEnabled("YJCheckBox", false)
        self:setCtrlOnlyEnabled("JJCheckBox", false)

        self.fourRadioGroup = RadioGroup.new()
        self.fourRadioGroup:setItems(self, TWO_CHECK_BOX, self.onCheckBox)
    else
        local TWO_CHECK_BOX = {}
        for i = 1, 4 do
            table.insert(TWO_CHECK_BOX, "JSHXCheckBox_" .. i)
        end

        for i = 1, 4 do
            self:setCtrlOnlyEnabled("HouXuanCheckBox_" .. i, false)
        end

        self:setCtrlOnlyEnabled("GJCheckBox", false)
        self:setCtrlOnlyEnabled("YJCheckBox", false)
        self:setCtrlOnlyEnabled("JJCheckBox", false)

        self.fourRadioGroup = RadioGroup.new()
        self.fourRadioGroup:setItems(self, TWO_CHECK_BOX, self.onCheckBox)
    end
end

-- 点击某个单选框
function ShiJieBeiDlg:onCheckBox(sender, eventType)
    local data = ActivityMgr:getShijiebeiData()
    if data.support_team ~= "" and sender.name ~= data.support_team then
        gf:ShowSmallTips(string.format(CHS[4300416], data.support_team))
        return
    end

    self:setMySupport(sender.name)
end

-- 根据比赛类型显示对应界面
function ShiJieBeiDlg:setDlgDisplayByState(state)
    for _, panelName in pairs(SJB_GAME_STATE_TO_PANEL) do
        self:setCtrlVisible(panelName, panelName == SJB_GAME_STATE_TO_PANEL[state])
    end

    -- 如果是小组赛，需要默认显示
    if SJB_GAME_STATE_TO_PANEL[state] == "XiaozPanel" then
        self:onLastPageButton()
    end
end

-- 设置8强
function ShiJieBeiDlg:setEight(data)
    for i = 1, 8 do
        local num1 = i * 2 - 1
        local num2 = i * 2
        local check = self:getControl("EIGHTCheckBox_" .. num1)
        self:setUnitCheck(data.teams[i].one_name, check, data.teams[i].one_result)

        local check = self:getControl("EIGHTCheckBox_" .. num2)
        self:setUnitCheck(data.teams[i].two_name, check, data.teams[i].two_result)
    end
end

-- 设置单个国旗、球队名称
function ShiJieBeiDlg:setUnitCheck(name, check, result)
    if name == "" then
        self:setImage("FlagImage", ResMgr.ui.footBall, check)
    else
        self:setLabelText("NameLabel", name, check)
        self:setImage("FlagImage", ResMgr.ui[name], check)
    end

    if not result or result == 0 then
        self:setCtrlVisible("ResultImage", false, check)
    elseif result == 1 then
        self:setCtrlVisible("ResultImage", true, check)
        self:setImage("ResultImage", ResMgr.ui.mingrzb_jc_win, check)
    elseif result == 2 then
        self:setCtrlVisible("ResultImage", true, check)
        self:setImage("ResultImage", ResMgr.ui.mingrzb_jc_lose, check)
    end
    check.name = name
end

-- 设置32小组赛过期和名字
function ShiJieBeiDlg:setGroupData()
    local flagStep = 0

    local panelTag = {"A", "B", "C", "D", "E", "F", "G", "H"}
    for i = 1, 8 do
        local zuPanel = self:getControl(string.format("%szPanel", panelTag[i]))
        for j = 1, 4 do
            local key = j + flagStep
            local checkBox = self:getControl("XZCheckBox_" .. key, nil, zuPanel)
            if GROUP_COUNTRIES[key] == "" then
                -- 正常情况不可能走到这，容错把~
                self:setLabelText("NameLabel", "", checkBox)
                self:setImagePlist("FlagImage", ResMgr.ui.touming, checkBox)

            else
                self:setLabelText("NameLabel", GROUP_COUNTRIES[key], checkBox)
                self:setImage("FlagImage", ResMgr.ui[GROUP_COUNTRIES[key]], checkBox)

            end
            checkBox.name = GROUP_COUNTRIES[key]
        end
        flagStep = flagStep + 4
    end
end

-- 设置我支持的球队
function ShiJieBeiDlg:setMySupport(name)
    if self.support_team ~= "" then
        return
    end

    local panel = self:getControl("MainPanel")

    self.selectName = name

    -- 当前支持的球队国旗
    if name == "" then
        self:setImage("NameImage_3", ResMgr.ui.footBall, panel)
        self:setLabelText("NameLabel_2", CHS[4300417], panel) -- 暂无支持球队
        self:setLabelText("NameLabel_1", CHS[4300444], "QiuDuiPanel") -- 点击选择支持的球队
    else
        self:setImage("NameImage_3", ResMgr.ui[name], panel)
        self:setLabelText("NameLabel_2", name, panel)
        self:setLabelText("NameLabel_1", CHS[4300445], "QiuDuiPanel") -- 暂无支持球队
    end
end

function ShiJieBeiDlg:MSG_INVENTORY(data)
    -- 当前拥有的数量
    self:setLabelText("NowHaveLabel", InventoryMgr:getAmountByName(CHS[4300418])) -- 球队支持卡
end

    -- 下方主界面按钮
function ShiJieBeiDlg:setMainInfo(data)
    -- 不要问我这些控件名称为什么那么随意，我也很无奈
    -- 不要问我这些控件名称为什么那么随意，我也很无奈
    -- 不要问我这些控件名称为什么那么随意，我也很无奈

    self.support_team = ""
    self:setMySupport(data.support_team)
    self:setMyTeam(data)

    local panel = self:getControl("MainPanel")

    -- 目前已使用的数量
    self:setLabelText("UseValueLabel", data.support_num, panel)
    local numPanel = self:getControl("NumPanel_1")
    self:setImage("CardImage", ResMgr:getIconPathByName(CHS[4300432]), "NumPanel_1")
    self:setImage("CardImage", ResMgr:getIconPathByName(CHS[4300432]), "NumPanel_2")



    local timePanel = self:getControl("TimePanel", nil, panel)
    -- 可选择支持球队时间
    local timeStr = string.format( "%s-%s", os.date(CHS[4300409], data.select_time_start), os.date(CHS[4300409], data.select_time_end))
    self:setLabelText("TimeLabel_4", timeStr, timePanel)

    -- 可使用球队支持卡时间
    local timeStr = string.format( "%s-%s", os.date(CHS[4300409], data.support_time_start), os.date(CHS[4300409], data.support_time_end))
    self:setLabelText("TimeLabel_5", timeStr, timePanel)

    -- 可领取小组赛奖励时间

    local stageStr = data.stage == CHS[7100177] and CHS[7120072] or data.stage

    self:setLabelText("TimeLabel_3", string.format( CHS[4500000], stageStr ), timePanel)

    local timeStr = string.format( "%s-%s", os.date(CHS[4300409], data.bonus_time_start), os.date(CHS[4300409], data.bonus_time_end))
    self:setLabelText("TimeLabel_6", timeStr, timePanel)
end

-- 小组赛下一页
function ShiJieBeiDlg:onNextPageButton(sender, eventType)
    self:setCtrlVisible("XiaoZuPanel2", true)
    self:setCtrlVisible("XiaoZuPanel1", false)
end

-- 小组赛上一页
function ShiJieBeiDlg:onLastPageButton(sender, eventType)
    self:setCtrlVisible("XiaoZuPanel2", false)
    self:setCtrlVisible("XiaoZuPanel1", true)
end

function ShiJieBeiDlg:onFenXianButton(sender, eventType)

    local str = CHS[4300419] -- "我正在关注第21届世界杯赛况，大家一起为自己喜欢的球队加油助威吧。#G查看详情#n 点击查看详情则打开世界杯赛事界面",

    local data = ActivityMgr:getShijiebeiData()
    if data.support_team ~= "" then
        str = string.format(CHS[4300442], data.support_team)
    end

    local showInfo = string.format(string.format("{\29%s\29}", str))

    local data = ActivityMgr:getShijiebeiData()
    if not data then return end

    local para = string.format("worldCupInfo:%s", data.support_team)

    local sendInfo = string.format(string.format("{\t%s=%s=%s}", str, "worldCupInfo", para))

    local dlg = DlgMgr:openDlgEx("ShareChannelListExDlg", self.name)
    dlg:setShareText(showInfo, sendInfo)

    local rect = self:getBoundingBoxInWorldSpace(sender)
    rect.width = (rect.width - 210) / 2
    dlg:setFloatingFramePos(rect)

end

function ShiJieBeiDlg:onConfirmButton(sender, eventType)
    local sjbData = ActivityMgr:getShijiebeiData()
    if self.support_team ~= "" then

        if sjbData.support_time_start <= gf:getServerTime() and sjbData.support_time_end >= gf:getServerTime() then
        else
            gf:ShowSmallTips(CHS[4300420])
            return
        end
        --]]
        DlgMgr:openDlgEx("ShiJieBeiSupportDlg", sjbData)
        return
    end


    if not self.selectName or self.selectName == "" then
        gf:ShowSmallTips(CHS[4300421])
        return
    end

    local data = ActivityMgr:getShijiebeiData()

    if data.select_time_start <= gf:getServerTime() and data.select_time_end >= gf:getServerTime() then
    else
        gf:ShowSmallTips(CHS[4300422]) -- 不在选择支持的球队时间内无法进行操作。
        return
    end
    --]]

    -- 确认在#R%s#n阶段支持#R%s#n，支持后在本阶段无法修改支持球队，且球队支持卡只能给支持的球队使用,半决赛支持的球队也为决赛支持的球队，是否确认操作？
    local tips = string.format(CHS[4300439], sjbData.stage, self.selectName)

    if sjbData.stage == CHS[4300431] or sjbData.stage == CHS[4300440] then
        tips = string.format(CHS[4300423], sjbData.stage, self.selectName)
    end

    gf:confirm(tips, function()
        gf:CmdToServer("CMD_WORLD_CUP_2018_SELECT_TEAM", {name = self.selectName})
    end)
end


-- 设置4强界面
function ShiJieBeiDlg:setFour(data)
    local winTeam = {}
    for i = 1, 4 do
        local num1 = i * 2 - 1
        local num2 = i * 2
        local check = self:getControl("FourCheckBox_" .. num1)

        self:setUnitCheck(data.teams[i].one_name, check)

        local check = self:getControl("FourCheckBox_" .. num2)
        self:setUnitCheck(data.teams[i].two_name, check)

        --[[
            #define NO_RESULT       0   // 没结果
            #define WINNER          1   // 胜利
            #define LOSER           2   // 失败
        --]]


        local check = self:getControl("WinFourCheckBox_" .. i)
        if data.teams[i].one_result == 0 then
            -- 没结果
            self:setUnitCheck("", check)
        elseif data.teams[i].one_result == 1 then
            self:setUnitCheck(data.teams[i].one_name, check)
        else
            self:setUnitCheck(data.teams[i].two_name, check)
        end
    end
end

-- leftOrRight 左右，1左2右
-- topOrBottom 上下，1上2下
-- isGuanjun 是否是冠军赛  当为true时， leftOrRight 表示冠军赛左右   topOrBottom 表示及军事左右
function ShiJieBeiDlg:setJuesaiLine(leftOrRight, topOrBottom, isGuanjun)
    if isGuanjun then
        if leftOrRight == 1 then
            self:setCtrlVisible("GJLImage", true)
            self:setCtrlVisible("YJRImage", true)
        elseif leftOrRight == 2 then
            self:setCtrlVisible("GJRImage", true)
            self:setCtrlVisible("YJLImage", true)
        end

        if topOrBottom == 1 then
            self:setCtrlVisible("JJLImage", true)
        elseif topOrBottom == 2 then
            self:setCtrlVisible("JJRImage", true)
        end
        return
    end

    if leftOrRight == 1 then
        self:setCtrlVisible("42LImage", true)

        if topOrBottom == 1 then
            self:setCtrlVisible("42LTImage", true)
        else
            self:setCtrlVisible("42LBImage", true)
        end
    else
        self:setCtrlVisible("42RImage", true)

        if topOrBottom == 1 then
            self:setCtrlVisible("42RTImage", true)
        else
            self:setCtrlVisible("42RBImage", true)
        end
    end
end

-- 设置半决赛
function ShiJieBeiDlg:setBanJueSai(data)
    for i = 1, 2 do
        local num1 = i * 2 - 1
        local num2 = i * 2
        local check = self:getControl("HouXuanCheckBox_" .. num1)
        self:setUnitCheck(data.teams[i].one_name, check, data.teams[i].one_result)

        local check = self:getControl("HouXuanCheckBox_" .. num2)
        self:setUnitCheck(data.teams[i].two_name, check, data.teams[i].two_result)
--
        if data.teams[i].one_result == 0 then
            -- 没结果
        elseif data.teams[i].one_result == 1 then
            local check = self:getControl("JSHXCheckBox_" .. num1)
            self:setUnitCheck(data.teams[i].one_name, check)
            self:setJuesaiLine(i, 1)

            local check = self:getControl("JSHXCheckBox_" .. num2)
            self:setUnitCheck(data.teams[i].two_name, check)
        else
            local check = self:getControl("JSHXCheckBox_" .. num1)
            self:setUnitCheck(data.teams[i].two_name, check)

            local check = self:getControl("JSHXCheckBox_" .. num2)
            self:setUnitCheck(data.teams[i].one_name, check)
            self:setJuesaiLine(i, 2)
        end
    end
end

-- 设置决赛
function ShiJieBeiDlg:setJueSai(data)

    self:setLabelText("BanLabel", CHS[4300424]) -- 决赛阶段

    -- 决赛数据需要特殊处理，上一轮没有结果，要手动赋值
    local jsTeam = data.teams[3] -- 总决赛两个队伍确定冠军决赛
    for i = 1, 2 do
        if data.teams[i].one_name == jsTeam.one_name  then
            data.teams[i].one_result = 1
            data.teams[i].two_result = 2
        elseif data.teams[i].two_name == jsTeam.one_name then
            data.teams[i].one_result = 2
            data.teams[i].two_result = 1
        elseif data.teams[i].one_name == jsTeam.two_name  then
            data.teams[i].one_result = 1
            data.teams[i].two_result = 2
        elseif data.teams[i].two_name == jsTeam.two_name then
            data.teams[i].one_result = 2
            data.teams[i].two_result = 1
        end

        --[[
        if data.teams[i].one_name == jsTeam.one_name or data.teams[i].one_name == jsTeam.two_name then
            data.teams[i].one_result = 1
        else
            data.teams[i].one_result = 2
        end
        --]]
    end
    self:setBanJueSai(data)

    -- 冠军
    if jsTeam.one_result == 1 then
        self:setUnitCheck(jsTeam.one_name, self:getControl("GJCheckBox"))
        self:setUnitCheck(jsTeam.two_name, self:getControl("YJCheckBox"))

        if jsTeam.one_name == self:getLabelText("NameLabel", "JSHXCheckBox_1") then
            self:setJuesaiLine(1, -1, 1)
        else
            self:setJuesaiLine(2, -1, 1)
        end
    elseif jsTeam.one_result == 2 then
        self:setUnitCheck(jsTeam.two_name, self:getControl("GJCheckBox"))
        self:setUnitCheck(jsTeam.one_name, self:getControl("YJCheckBox"))
        if jsTeam.one_name == self:getLabelText("NameLabel", "JSHXCheckBox_1") then
            self:setJuesaiLine(2, -1, 1)
        else
            self:setJuesaiLine(1, -1, 1)
        end
    else
        self:setUnitCheck(CHS[4300425], self:getControl("GJCheckBox")) -- 冠军
        self:setUnitCheck(CHS[4300426], self:getControl("YJCheckBox"))
    end

    -- 三四名
    local jsTeam = data.teams[4]
    if jsTeam.one_result == 1 then
        if jsTeam.one_name == self:getLabelText("NameLabel", "JSHXCheckBox_2") then
            self:setJuesaiLine(-1, 1, 1)
        else
            self:setJuesaiLine(-1, 2, 1)
        end

        self:setUnitCheck(jsTeam.one_name, self:getControl("JJCheckBox"))
    elseif jsTeam.one_result == 2 then
        self:setUnitCheck(jsTeam.two_name, self:getControl("JJCheckBox"))
        if jsTeam.one_name == self:getLabelText("NameLabel", "JSHXCheckBox_2") then
            self:setJuesaiLine(-1, 1, 1)
        else
            self:setJuesaiLine(-1, 2, 1)
        end
    else
        self:setUnitCheck(CHS[4300427], self:getControl("JJCheckBox"))
    end
end

function ShiJieBeiDlg:setMyTeam(data)
    if data.support_team ~= "" then
        self:setLabelText("Label_1", CHS[4300428], "ConfirmButton") -- 支 持
        self:setLabelText("Label_2", CHS[4300428], "ConfirmButton")
    end

    self.support_team = data.support_team
end

function ShiJieBeiDlg:MSG_WORLD_CUP_2018_PLAY_TABLE_GROUP(data)
    GROUP_COUNTRIES = data.teams

    -- 设置小组赛国旗
    self:setGroupData()
    self:setDlgDisplayByState(SJB_GAME_STATE.XIAOZU)
    self:setMainInfo(data)
    self:initCheckBox(SJB_GAME_STATE.XIAOZU)
    self:setAllCheckBoxUntouch(data)
end

function ShiJieBeiDlg:MSG_WORLD_CUP_2018_PLAY_TABLE_KNOCKOUT(data)
    if data.stage == CHS[4300429] then
        self:setEight(data)
        self:setDlgDisplayByState(SJB_GAME_STATE.EIAGHT)
        self:initCheckBox(SJB_GAME_STATE.EIAGHT)
    elseif data.stage == CHS[4300430] then
        self:setFour(data)
        self:setDlgDisplayByState(SJB_GAME_STATE.FOUR)
        self:initCheckBox(SJB_GAME_STATE.FOUR)
    elseif data.stage == CHS[4300431] then
        self:setDlgDisplayByState(SJB_GAME_STATE.TWO)
        self:setBanJueSai(data)
        self:initCheckBox(SJB_GAME_STATE.TWO)
    else
        self:setDlgDisplayByState(SJB_GAME_STATE.ONE)
        self:initCheckBox(SJB_GAME_STATE.ONE)
        self:setJueSai(data)
    end
    self:setMainInfo(data)
    self:setAllCheckBoxUntouch(data)
end

-- 点击右下角足球图片，需要给予提示，如果选择了，就不需要
function ShiJieBeiDlg:onShowNotSupTeam(sender, eventType)
    local data = ActivityMgr:getShijiebeiData()
    if self.selectName == "" then
        gf:ShowSmallTips(CHS[4300447])  --  暂未选择支持的球队
    end
end

-- 点击球队支持卡图片
function ShiJieBeiDlg:onCostImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(CHS[4300418], rect)
end

-- 将所有checkBox设置为不可点击，和还原为非点击状态
-- 当玩家已经选择支持的球队时需要这样处理
function ShiJieBeiDlg:setAllCheckBoxUntouch(data)
    if data.support_team == "" then return end

    local allCheckBoxes = {}
    -- 小组赛的
    for i = 1, 32 do
        table.insert(allCheckBoxes, "XZCheckBox_" .. i)
    end

    -- 八强
    for i = 1, 16 do
        table.insert(allCheckBoxes, "EIGHTCheckBox_" .. i)
    end

    -- 四强的
    for i = 1, 8 do
        table.insert(allCheckBoxes, "FourCheckBox_" .. i)
    end

    for i = 1, 4 do
        table.insert(allCheckBoxes, "WinFourCheckBox_" .. i)
    end

    -- 决赛的
    for i = 1, 4 do
        table.insert(allCheckBoxes, "HouXuanCheckBox_" .. i)
    end

    for i = 1, 4 do
        table.insert(allCheckBoxes, "JSHXCheckBox_" .. i)
    end

    table.insert(allCheckBoxes, "GJCheckBox")
    table.insert(allCheckBoxes, "YJCheckBox")
    table.insert(allCheckBoxes, "JJCheckBox")

    for _, checkName in pairs(allCheckBoxes) do
        self:setCheck(checkName, false)
        self:setCtrlOnlyEnabled(checkName, false)
    end
end

return ShiJieBeiDlg
