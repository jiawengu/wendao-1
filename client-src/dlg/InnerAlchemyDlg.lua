-- InnerAlchemyDlg.lua
-- Created by lixh2 Dec/26/2017
-- 内丹界面

local InnerAlchemyDlg = Singleton("InnerAlchemyDlg", Dialog)

-- 标题
local INNER_ALCHEMY_TITLE_STATE = {
    CHS[7100119], -- 筑 基 炼 气
    CHS[7100120], -- 凝 气 化 神
    CHS[7100121], -- 还 虚 合 道
    CHS[7100122], -- 内 丹 初 成
    CHS[7100123], -- 金 丹 大 成
}

local MAGIC_DIS = 200

-- 精气值颜色
local SPIRIT_TEXT_COLOR = {red = cc.c3b(200, 0, 0), default = cc.c3b(76, 32, 0)}

-- 内丹境界特效
local STATE_MAGIC = ResMgr.ArmatureMagic.innerAlchemy_state.name

-- 内丹阶段特效
local STAGE_MAGIC = ResMgr.ArmatureMagic.innerAlchemy_stage.name

-- 内丹境界动作
local state_magic_action = {
    [1] = "Bottom1",
    [2] = "Bottom2",
    [3] = "Bottom3",
    [4] = "Bottom4",
    [5] = "Bottom5",
    changeOne = "Bottom6",  -- 切换境界时：前半段
    changeTwo = "Bottom7",  -- 切换境界时：后半段
}

-- 内丹阶段动作
local stage_magic_action = {
    [1] = {start = "",         finish = "",         midMagic = {"Bottom12", "Bottom13", "Bottom14", "Bottom15"}}, -- 筑 基 炼 气
    [2] = {start = "Bottom07", finish = "Bottom03", midMagic = {"Bottom16", "Bottom17", "Bottom18", "Bottom19"}}, -- 凝 气 化 神
    [3] = {start = "Bottom08", finish = "Bottom04", midMagic = {"Bottom20", "Bottom21", "Bottom22", "Bottom23"}}, -- 还 虚 合 道
    [4] = {start = "Bottom09", finish = "Bottom05", midMagic = {"Bottom24", "Bottom25", "Bottom26", "Bottom27"}}, -- 内 丹 初 成
    [5] = {start = "Bottom10", finish = "Bottom06", midMagic = {"Bottom28", "Bottom29", "Bottom30", "Bottom31"}}, -- 金 丹 大 成
    firstPoint = "Bottom01",  -- 第一个黄点待机
    stageLight = "Bottom02",  -- 小阶段突破点亮
    lastAction = "Bottom11",  -- 大阶段突破，终极特效
}

function InnerAlchemyDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("BreakButton", self.onBreakButton)
    self:bindListener("BeBreakButton", self.onFinishBreakButton)
    self:bindFloatPanelListener("RulePanel")
    self:bindListener("TaskTextPanel", self.onTaskPanel)

    -- 请求当前界面数据
    gf:CmdToServer("CMD_REFRESH_NEIDAN_DATA")

    -- 刷新界面信息(服务器数据回来，部分数据可能会被修改)
    self:MSG_REFRESH_NEIDAN_DATA()

    self:playAlchemyMagic()

    self:hookMsg("MSG_REFRESH_NEIDAN_DATA")
    self:hookMsg("MSG_NEIDAN_BREAK_TASK_SUCC")
    self:hookMsg("MSG_TASK_PROMPT")
    self:hookMsg("MSG_UPDATE")
end

-- 标题
function InnerAlchemyDlg:setTitle(state)
    if state and type(state) == "number" then
        self:setLabelText("TitleLabel_1", INNER_ALCHEMY_TITLE_STATE[state], "BKPanel")
        self:setLabelText("TitleLabel_2", INNER_ALCHEMY_TITLE_STATE[state], "BKPanel")
    end
end

-- 左侧当前阶段属性
function InnerAlchemyDlg:setCurrentStageInfo(state, stage, attribNum, polarNum)
    local panel = self:getControl("BeforeValuePanel")

    -- 境界
    local stageName = string.format(CHS[7100134], InnerAlchemyMgr:getAlchemyState(state), InnerAlchemyMgr:getAlchemyStage(stage))
    local stagePanel = self:getControl("StagePanel", nil, panel)
    self:setLabelText("ValueLabel", stageName, stagePanel)

    -- 属性点
    local attribPanel = self:getControl("TotalAttribPointPanel", nil, panel)
    self:setLabelText("TitleLabel", string.format(CHS[7100148], attribNum), attribPanel)

    -- 相性点
    local polarPanel = self:getControl("TotalPolarPointPanel", nil, panel)
    self:setLabelText("TitleLabel", string.format(CHS[7100149], polarNum), polarPanel)
end

-- 左侧下一阶段属性
function InnerAlchemyDlg:setNextStageInfo(state, stage, attribNum, polarNum, isTop)
    local panel = self:getControl("AfterValuePanel")

    -- 最高境界，最高阶段
    local isMaxStateStage = isTop

    self:setCtrlVisible("MaxImage", isMaxStateStage, panel)
    self:setCtrlVisible("StagePanel", not isMaxStateStage, panel)
    self:setCtrlVisible("AddAttribPointPanel", not isMaxStateStage, panel)
    self:setCtrlVisible("AddPolarPointPanel", not isMaxStateStage, panel)

    -- 最高境界，最高阶段后不需要设置一下内容
    if isMaxStateStage then return end

    -- 境界
    local stageName = string.format(CHS[7100134], InnerAlchemyMgr:getAlchemyState(state), InnerAlchemyMgr:getAlchemyStage(stage))
    local stagePanel = self:getControl("StagePanel", nil, panel)
    self:setLabelText("ValueLabel", stageName, stagePanel)

    -- 属性点,相性点
    if attribNum == 0 then
        self:setCtrlVisible("AddAttribPointPanel", polarNum ~= 0, panel)
        self:setCtrlVisible("AddPolarPointPanel", false, panel)

        local attribPanel = self:getControl("AddAttribPointPanel", nil, panel)
        self:setLabelText("TitleLabel", CHS[7100136] .. "+" .. polarNum, attribPanel)
    else
        self:setCtrlVisible("AddAttribPointPanel", true, panel)
        self:setCtrlVisible("AddPolarPointPanel", polarNum ~= 0, panel)

        local attribPanel = self:getControl("AddAttribPointPanel", nil, panel)
        self:setLabelText("TitleLabel", CHS[7100135] .. "+" .. attribNum, attribPanel)

        local polarPanel = self:getControl("AddPolarPointPanel", nil, panel)
        self:setLabelText("TitleLabel", CHS[7100136] .. "+" .. polarNum, polarPanel)
    end
end

-- 设置境界图片
function InnerAlchemyDlg:setStatePhoto(state)
    local panel = self:getControl("StatePanel", nil, "AlchemyPanel")
    self:setImage("TextImage", InnerAlchemyMgr:getAlchemyStateUiByState(state), panel)
end

-- 设置突破区域相关
function InnerAlchemyDlg:setBreakPanelInfo(state, stage, breakStatus, isTop)
    -- 最高境界，最高阶段
    local isMaxStateStage = isTop
    self:setCtrlVisible("BestImage", isMaxStateStage, "AlchemyPanel")
    self:setCtrlVisible("BreakPanel", not isMaxStateStage, "AlchemyPanel")
    self:setCtrlVisible("InfoButton", not isMaxStateStage, "AlchemyPanel")

    if INNER_ALCHEMY_BREAK_STATUS.NOT_IN_BREAK == breakStatus then
        self:setLabelText("Label1", stage < INNER_ALCHEMY_STAGE.FIVE and CHS[7100138] or CHS[7100139], "BreakButton")
        self:setLabelText("Label2", stage < INNER_ALCHEMY_STAGE.FIVE and CHS[7100138] or CHS[7100139], "BreakButton")
    elseif INNER_ALCHEMY_BREAK_STATUS.IN_BREAK == breakStatus then
        self:setLabelText("Label1", CHS[7100144], "BreakButton")
        self:setLabelText("Label2", CHS[7100144], "BreakButton")
    end

    self:setBreakPanelByStatus(breakStatus)
end

-- 设置精气值
function InnerAlchemyDlg:setSpiritNum(curNum, maxNum)
    self:setLabelText("NumLabel", curNum, "SpiritPanel", curNum < maxNum and SPIRIT_TEXT_COLOR.red or SPIRIT_TEXT_COLOR.default)
    self:setLabelText("LimitNumLabel", "/" .. maxNum, "SpiritPanel")
end

-- 设置突破panel状态
function InnerAlchemyDlg:setBreakPanelByStatus(breakStatus)
    self:setCtrlVisible("BeBreakButton", false)
    self:setCtrlVisible("BreakButton", false)
    self:setCtrlVisible("TaskPanel", false)
    self:setCtrlVisible("SpiritPanel", false)
    self:setCtrlVisible("FinishPanel", false)

    -- 在没有内丹数据前，突破按钮信息先不显示
    if not self.alchemyData then return end

    if INNER_ALCHEMY_BREAK_STATUS.NOT_IN_BREAK == breakStatus then
        self:setCtrlVisible("BreakButton", true)
        self:setCtrlEnabled("BreakButton", true)
        self:setCtrlVisible("SpiritPanel", true)
    elseif INNER_ALCHEMY_BREAK_STATUS.IN_BREAK == breakStatus then
        self:setCtrlVisible("BreakButton", true)
        self:setCtrlEnabled("BreakButton", false)
        self:setBreakTask()
    else
        self:setCtrlVisible("BeBreakButton", true)
        self:setCtrlVisible("FinishPanel", true)
    end
end

-- 设置突破任务相关
function InnerAlchemyDlg:setBreakTask()
    local task = TaskMgr:getTaskByName(CHS[7100118])
    if task then
        local taskPanel = self:getControl("TaskPanel")

        -- TaskTextPanel上设置字符串，根据字符串长度设置该Panel与底板Panel的宽度(Panel大小必须在调用setColorText固定，否则会显示异常)
        local bkImage = self:getControl("BKImage", nil, "TaskPanel")
        local str1, str2 = string.match(task.task_prompt, "(.+)#@(.+)") or string.match(task.task_prompt, "(.+)#C(.+)")
        bkImage:setContentSize(10.6 * gf:getTextLength(str1), bkImage:getContentSize().height)
        taskPanel:setVisible(true)

        local taskTextPanel = self:getControl("TaskTextPanel", nil, "TaskPanel")
        local textHeight = taskTextPanel:getContentSize().height
        taskTextPanel:setContentSize(10.6 * gf:getTextLength(str1), textHeight)

        self:setColorText(task.task_prompt, "TaskTextPanel", "TaskPanel", nil, nil, cc.c3b(76, 32, 0), 21, true)
        taskPanel:requestDoLayout()

        if string.match(task.task_prompt, CHS[7100145]) then
            self:setCtrlVisible("ClickImage", true, "TaskPanel")
        else
            self:setCtrlVisible("ClickImage", false, "TaskPanel")
        end
    end
end

-- 播放人物剪影与内丹特效
function InnerAlchemyDlg:playAlchemyMagic()
    local magicPanel = self:getControl("Panel01", nil, "PersonPanel")
    local backPanel = self:getControl("Panel02", nil, "PersonPanel")
    magicPanel:removeAllChildren()
    backPanel:removeAllChildren()
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, "Top02", magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 3)
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, "Bottom01", backPanel, nil, nil, nil, backPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 3)
end

-- 设置阶段进度
function InnerAlchemyDlg:setStageProgress(state, stage)
    if stage < INNER_ALCHEMY_STAGE.ONE then stage = INNER_ALCHEMY_STAGE.ONE end
    if stage > INNER_ALCHEMY_STAGE.FIVE then stage = INNER_ALCHEMY_STAGE.FIVE end
    if state < INNER_ALCHEMY_STAGE.ONE then state = INNER_ALCHEMY_STAGE.ONE end
    if state > INNER_ALCHEMY_STAGE.FIVE then state = INNER_ALCHEMY_STAGE.FIVE end

    -- 境界特效
    local mainMagicpanel = self:getControl("MagicPanel", nil, "AlchemyPanel")
    if not mainMagicpanel:getChildByName(state_magic_action[state]) then
        for i = 1, INNER_ALCHEMY_STAGE.FIVE do
            mainMagicpanel:removeChildByName(state_magic_action[i])
        end

        gf:createArmatureOnceMagic(STATE_MAGIC, state_magic_action[state], mainMagicpanel)
    end

    -- 阶段特效(第一个小黄点)
    local ballPanel1 = self:getControl("BallPanel1", nil, "BallPanel")
    if not ballPanel1:getChildByName(stage_magic_action.firstPoint) then
        local sz = ballPanel1:getContentSize()
        gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action.firstPoint, ballPanel1, nil, nil, nil, sz.width - 7, sz.height + 15)
    end

    -- 阶段特效(后续圆环与小黄点)
    for i = 2, stage do
        local ballPanel = self:getControl("BallPanel" .. i, nil, "BallPanel")
        if not mainMagicpanel:getChildByName(stage_magic_action[i].finish) then
            gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action[i].finish, mainMagicpanel)
        end
    end
end

-- 服务器通知打开界面，也许有任务相关行为
function InnerAlchemyDlg:onDlgOpened(para)
    if para and para[1] == "commit_pet" then
        gf:CmdToServer("CMD_NEIDAN_SUBMIT_PET")
    end
end

function InnerAlchemyDlg:onTaskPanel(sender, eventType)
    local taskStatus = InnerAlchemyMgr:getBreakTaskType()
    if taskStatus == INNER_ALCHEMY_BREAK_STATUS.IN_BREAK then
        local task = TaskMgr:getTaskByName(CHS[7100118])
        if string.match(task.task_prompt, CHS[7100145]) then
            gf:CmdToServer("CMD_NEIDAN_SUBMIT_PET")
        else
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, { task_type = task.task_type, task_prompt = task.task_prompt })
        end
    end
end

function InnerAlchemyDlg:onInfoButton(sender, eventType)
    local curDayLeftSpiritNum = math.max(0, InnerAlchemyMgr:getCurrentDayMaxSpirit() - InnerAlchemyMgr:getCurrentDaySpirit())
    self:setLabelText("Label3_2", curDayLeftSpiritNum, "RulePanel")
    self:setCtrlVisible("RulePanel", true)
end

function InnerAlchemyDlg:onBreakButton(sender, eventType)
    if InnerAlchemyMgr:getCurrentSpirit() < InnerAlchemyMgr:getCurrentMaxSpirit() then
        -- 精气不足
        gf:ShowSmallTips(CHS[7100140])
        return
    end

    if Me:queryBasicInt("dan_data/state") == INNER_ALCHEMY_STATE.FIVE and Me:queryBasicInt("dan_data/stage") == INNER_ALCHEMY_STAGE.FIVE then
        -- 已达最高境界最高阶段
        gf:ShowSmallTips(CHS[7100141])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 请求获取突破任务
    gf:CmdToServer("CMD_GET_NEIDAN_BREAK_TASK")
end

function InnerAlchemyDlg:onFinishBreakButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 策划要求：特效在发消息之前播放
    if self.alchemyData and self.alchemyData.isTop == 0 then
        self:playBreakMagic(self.alchemyData.nxState, self.alchemyData.nxStage)
    else
        -- 请求完成突破任务
        gf:CmdToServer("CMD_NEIDAN_BREAK_TASK")
    end
end

-- 播放突破特效
function InnerAlchemyDlg:playBreakMagic(state, stage)
    if stage < INNER_ALCHEMY_STAGE.ONE then stage = INNER_ALCHEMY_STAGE.ONE end
    if stage > INNER_ALCHEMY_STAGE.FIVE then stage = INNER_ALCHEMY_STAGE.FIVE end
    if state < INNER_ALCHEMY_STAGE.ONE then state = INNER_ALCHEMY_STAGE.ONE end
    if state > INNER_ALCHEMY_STAGE.FIVE then state = INNER_ALCHEMY_STAGE.FIVE end

    -- 根据突破类型播特效
    local mainMagicpanel = self:getControl("MagicPanel", nil, "AlchemyPanel")
    if stage == INNER_ALCHEMY_STAGE.ONE then
        -- 播放境界图片前半段特效
        gf:createArmatureOnceMagic(STATE_MAGIC, state_magic_action.changeOne, mainMagicpanel, function()
            -- 策划要求在还没有完成与服务器通信前，就播成功后的特效
            self:setStageProgress(state, stage)

            -- 播放境界图片后半段特效
            gf:createArmatureOnceMagic(STATE_MAGIC, state_magic_action.changeTwo, mainMagicpanel)

            -- 播放终极特效前先移除进度特效
            for i = 2, INNER_ALCHEMY_STAGE.FIVE do
                local ballPanel = self:getControl("BallPanel" .. i, nil, "BallPanel")
                ballPanel:removeChildByName(stage_magic_action[i])
                mainMagicpanel:removeChildByName(stage_magic_action[i].finish)
            end

            -- 播放终极特效
            gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action.lastAction, mainMagicpanel, function()
                -- 请求完成突破任务
                gf:CmdToServer("CMD_NEIDAN_BREAK_TASK")
            end, self)

        end, self)
    else
        -- 播放该境界对应的阶段颜色粒子特效
        gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action[state].midMagic[stage - 1], mainMagicpanel, function()
            -- 播放该阶段对应的圆环进度特效
            gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action[stage].start, mainMagicpanel, function()
                -- 策划要求在还没有完成与服务器通信前，就播成功后的特效
                self:setStageProgress(state, stage)

                -- 播放点亮特效
                local lightPanel = self:getControl("BallPanel" .. stage, nil, "BallPanel")
                local sz = lightPanel:getContentSize()
                gf:createArmatureOnceMagic(STAGE_MAGIC, stage_magic_action.stageLight, lightPanel)

                -- 请求完成突破任务
                gf:CmdToServer("CMD_NEIDAN_BREAK_TASK")
            end, self)
        end, self)
    end
end

function InnerAlchemyDlg:MSG_REFRESH_NEIDAN_DATA()
    local state = math.max(Me:queryBasicInt("dan_data/state"), INNER_ALCHEMY_STATE.ONE)
    local stage = math.max(Me:queryBasicInt("dan_data/stage"), INNER_ALCHEMY_STAGE.ONE)
    self:setTitle(state)
    self:setStatePhoto(state)
    self:setSpiritNum(InnerAlchemyMgr:getCurrentSpirit(), InnerAlchemyMgr:getCurrentMaxSpirit())
    self:setCurrentStageInfo(state, stage,
        Me:queryBasicInt("dan_data/attrib_point"), Me:queryBasicInt("dan_data/polar_point"))
    self:setStageProgress(state, stage)

    self.alchemyData = InnerAlchemyMgr:getAlchemyData()

    local showNextPanel = self.alchemyData ~= nil
    self:setCtrlVisible("StagePanel", showNextPanel, "AfterValuePanel")
    self:setCtrlVisible("AddAttribPointPanel", showNextPanel, "AfterValuePanel")
    self:setCtrlVisible("AddPolarPointPanel", showNextPanel, "AfterValuePanel")
    if self.alchemyData then
        if self.alchemyData.isTop == 0 then
            self:setNextStageInfo(self.alchemyData.nxState, self.alchemyData.nxStage, self.alchemyData.nxAttribPoint, self.alchemyData.nxPolarPoint, false)
        else
            self:setNextStageInfo(state, stage, 0, 0, true)
        end
    end

    self:setBreakPanelInfo(state, stage, InnerAlchemyMgr:getBreakTaskType(), InnerAlchemyMgr:isMaxStateAndStage())
end

function InnerAlchemyDlg:MSG_NEIDAN_BREAK_TASK_SUCC()
end

function InnerAlchemyDlg:MSG_TASK_PROMPT(data)
    if data and data[1] and data[1].task_type == CHS[7100118] then
        self:setBreakPanelInfo(Me:queryBasicInt("dan_data/state"), Me:queryBasicInt("dan_data/stage"),
            InnerAlchemyMgr:getBreakTaskType(), InnerAlchemyMgr:isMaxStateAndStage())
    end
end

function InnerAlchemyDlg:MSG_UPDATE()
    local nowSpiritNum = Me:queryInt("dan_data/exp")
    local dlgSpiritNum = self:getLabelText("NumLabel", "SpiritPanel")
    if nowSpiritNum ~= tonumber(dlgSpiritNum) then
        InnerAlchemyDlg:setSpiritNum(nowSpiritNum, Me:queryInt("dan_data/exp_to_next_level"))
    end
end

return InnerAlchemyDlg
