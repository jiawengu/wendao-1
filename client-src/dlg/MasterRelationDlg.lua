-- MasterRelationDlg.lua
-- Created by songcw June/3/2016
-- 师徒关系界面

local MasterRelationDlg = Singleton("MasterRelationDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local TEACHER_CHECKBOS = {
    "TRelationCheckBox",
    "StudentCheckBox_1",
    "StudentCheckBox_2",
    "StudentCheckBox_3",
}

local STUDENT_CHECKBOS = {
    "SRelationCheckBox",
    "TaskCheckBox",
}

local DISPLAY_TYPE = {
    TEACHER = 1,
    STUDENT = 2,
}

function MasterRelationDlg:init()
    self:bindListener("CommunionButton", self.onCommunionButton)
    self:bindListener("InteractiveButton", self.onInteractiveButton)
    self:bindListener("LeaveButton", self.onLeaveButton)
    self:bindListener("WordsButton", self.onWordsButton)
    self:bindListener("InteractiveButton", self.onInteractiveButton, "ItemPanel")
    for i = 1, 3 do
        local panel = self:getControl("InfoPanel" .. i)
        panel:setTag(i)
        self:bindListener("TaskButton", self.onTaskButton, panel)
        self:bindListener("FoundButton", self.onFoundButton, panel)
        self:bindListener("InteractiveButton", self.onInteractiveButton, panel)
        self:bindListener("SInteractiveButton", self.onInteractiveButton, panel)
    end

    local myMaterInfo = MasterMgr:getMyMasterInfo()
    MasterMgr:cmdQueryMyMaster()

    self:bindListener("GotoButton", self.onGotoButton)
    self:bindListener("TaskButton", self.onShiTuTaskButton, "TaskPanel")
    self:bindListener("TaskButton", self.onGraduateTaskButton, "GraduationPanel")
    self:bindListener("TaskPanel", self.onTaskInfoButton)
    self:bindListener("GraduationPanel", self.onTaskInfoButton)
    self:bindListener("WorkInfoPanel", self.onWorkInfoPanel, "HomeworkPanel")
    self:bindListViewListener("ListView", self.onSelectListView)

    -- 界面初始化，隐藏不该显示的控件
    self:dlgDataInit()

    -- 单选框初始化
    self:radioGroupInit()

    -- 设置初始化界面类型
    self:initSelect()

    if MasterMgr.myTeacherMsg then
        self:MSG_MY_MASTER_MESSAGE({message = MasterMgr.myTeacherMsg})
    end
    self:hookMsg('MSG_MY_APPENTICE_INFO')
    self:hookMsg('MSG_MY_MASTER_MESSAGE')
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
end

function MasterRelationDlg:cleanup()
    FriendMgr:unrequestCharMenuInfo(self.name)
    MasterRelationDlg.onCharInfo = nil
end

-- 界面初始化，隐藏不该显示的控件
function MasterRelationDlg:dlgDataInit()
    self:setLeftShapeInfo()
    self:setCtrlVisible("StudentPanel", false)
    self:setCtrlVisible("TeacherPanel", false)
    self:setCtrlVisible("TaskPanel", false)
    self:setCtrlVisible("HomeworkPanel", false)
    self:setCtrlVisible("GraduationPanel", false)

    for i = 1, 3 do
        local panel = self:getControl("InfoPanel" .. i)
        self:setCtrlVisible("FoundButton", false, panel)
        self:setCtrlVisible("ShapePanel", false, panel)
        self:setCtrlVisible("InteractiveButton", false, panel)
        self:setCtrlVisible("TaskButton", false, panel)
        self:setCtrlVisible("SInteractiveButton", false, panel)
    end
end

function MasterRelationDlg:setLeftShapeInfo(info)
    local panel = self:getControl("ItemPanel")
    if not info then
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("LevelLabel", "", panel)
        self:setLabelText("OlineLabel", "", panel)
        self:setLabelText("GraduateLabel", "", panel)
        self:setLabelText("FriendlyLabel", "", panel)
        self:removePortrait("FigurePanel")
    end
end

-- 单选框初始化
function MasterRelationDlg:radioGroupInit()
    self.teacherGroup = RadioGroup.new()
    self.teacherGroup:setItems(self, TEACHER_CHECKBOS, self.onTeacherCheckBox)

    self.studentGroup = RadioGroup.new()
    self.studentGroup:setItems(self, STUDENT_CHECKBOS, self.onStudentCheckBox)
end

function MasterRelationDlg:onTeacherCheckBox(sender, eventType)
    local charInfo = sender.charInfo
    if charInfo == 1 then
        DlgMgr:openDlg("MasterDlg")
        return
    end
    self:setLeftInfo(charInfo)
    Log:D("==============点击了：" .. self:getLabelText("Label1", sender) .. "================")
    if sender:getName() == "TRelationCheckBox" then
        self:setCtrlVisible("StudentPanel", true)
        self:setCtrlVisible("WordsPanel", true)
        self:setCtrlVisible("TaskPanel", false)
        self:setCtrlVisible("GraduationPanel", false)
        self:setCtrlVisible("HomeworkPanel", false)
        self:setCtrlVisible("BackImage_1", false)
        self:setCtrlVisible("BackImage_2", false)
        self:setCtrlVisible("GraduateTipsPanel", false)
    else
        self:setCtrlVisible("TaskPanel", true)
        self:setCtrlVisible("GraduationPanel", true)
        self:setCtrlVisible("StudentPanel", false)
        self:setCtrlVisible("WordsPanel", false)
        self:setTask(charInfo)
    end
end

-- 设置出师、师徒任务
function MasterRelationDlg:setMasterTask(charInfo)
    local taskInfo = {}
    self:setCtrlVisible("HomeworkPanel", false)

    local function setTaskPanel(data, taskPanel)
        local taskFloatCtrl = self:getControl("StudentPanel", nil, taskPanel)
        taskFloatCtrl.charInfo = charInfo

        local btn = self:getControl("TaskButton", nil, taskPanel)
        btn.charInfo = charInfo
        local namePanel = self:getControl("NamePanel", nil, taskPanel)
        self:setLabelText("NameLabel", taskInfo.taskName, namePanel)
        self:setLabelText("ContentLabel", taskInfo.content, taskPanel)

        -- 奖励图标
        self:setImagePlist("ActiveImage", taskInfo.icon, taskPanel)
        local btn = self:getControl("TaskButton", nil, taskPanel)
        self:setLabelText("Label1", taskInfo.btnText, btn)
        self:setLabelText("Label2", taskInfo.btnText, btn)


        self:setLabelText("TimeLabel_1", taskInfo.times, taskPanel)

        taskPanel:requestDoLayout()
    end


    -- 出师任务数据
    taskInfo.taskName = CHS[4200075] -- [4200075] = "出师任务",
    taskInfo.content = CHS[4200076]  -- [4200076] = "展翅高飞，不忘恩师。",
    taskInfo.btnText = CHS[4200077]  -- [4200077] = "领取任务",
    if MasterMgr:isTeacher() then
        taskInfo.tips = CHS[4200078]
    else
        taskInfo.tips = CHS[4200079]
    end
    taskInfo.icon = ResMgr.ui["item_common"]
    taskInfo.times = "0/1"
    self:setCtrlVisible("GraduateTipsPanel", charInfo.level >= MasterMgr:getBeMasterLevel() and not self:getCtrlVisible("StudentPanel"))
    self:setLabelText("ItemLabel", taskInfo.tips, "GraduateTipsPanel")
    local taskPanel = self:getControl("GraduationPanel")
    setTaskPanel(taskInfo, taskPanel)
    -----------------------------------------------
    -- 师徒任务
    taskInfo.taskName = CHS[4200086]
    taskInfo.content = CHS[4200096] -- "师徒组队，完成可获得丰厚奖励。"
    taskInfo.btnText = CHS[4200077]  -- [4200077] = "领取任务",
    if MasterMgr:isTeacher() then
        taskInfo.icon = ResMgr.ui["daohang"]
    else
        taskInfo.icon = ResMgr.ui["experience"]
    end
    taskInfo.tips = ""
    taskInfo.times = string.format("%d/1", charInfo.taskTimes)

    local taskPanel = self:getControl("TaskPanel")
    setTaskPanel(taskInfo, taskPanel)

    -- 领取任务按钮
    if charInfo.taskTimes >= 1 then
        self:setCtrlVisible("TaskButton", false, taskPanel)
    else
        self:setCtrlVisible("TaskButton", true, taskPanel)
        self:setCtrlEnabled("TaskButton", charInfo.isMaster == 0 and charInfo.level < MasterMgr:getBeMasterLevel(), taskPanel)
    end
end

-- 设置传道授业任务
function MasterRelationDlg:setHomeworkTask(charInfo)
    local homePanel = self:getControl("HomeworkPanel")
    if charInfo.level >= MasterMgr:getBeMasterLevel() and charInfo.shouyeCount == 0 then
        homePanel:setVisible(false)
        return
    end
    self:setCtrlVisible("GraduateTipsPanel", false)

    if MasterMgr:isTeacher() then
        homePanel:setVisible(not self:isCheck("TRelationCheckBox"))
    else
        homePanel:setVisible(not self:isCheck("SRelationCheckBox"))
    end

    local studentPanel = self:getControl("StudentPanel", nil, homePanel)
    local data = {}
    if MasterMgr:isTeacher() then
        data.iconPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(CHS[4200097]))
        data.content = CHS[4200098]
    else
        data.iconPath = ResMgr.ui["reward_big_daohang_exp"]
        data.iconIsPlist = true
        data.content = CHS[4200099]
    end
    data.time = 0
    data.taskInfo = {}


    -- =========授业任务=========
    -- 任务名
    self:setLabelText("NameLabel", CHS[4200099], studentPanel)
    -- 图标
    if data.iconIsPlist then
        self:setImagePlist("ActiveImage", data.iconPath, studentPanel)
    else
        self:setImage("ActiveImage", data.iconPath, studentPanel)
    end

    self:setItemImageSize("ActiveImage", studentPanel)
    -- 说明
    self:setLabelText("ContentLabel", data.content, studentPanel)

    -- 设置发布按钮和说明不显示
    self:setCtrlVisible("TaskButton", charInfo.shouyeCount == 0, homePanel)      -- 按钮
    self:setCtrlVisible("ItemImage", charInfo.shouyeCount == 0, homePanel)       -- 说明前的图标
    self:setLabelText("ItemLabel_1", "", homePanel)

    self:setCtrlVisible("ItemLabel_2", true, homePanel)
    self:setCtrlVisible("TaskListView", true)
    if charInfo.shouyeCount == 0 then
        -- 未发布
        self:setLabelText("NoCompleteLabel", CHS[4200100], "WorkInfoPanel")
        local btn = self:getControl("TaskButton", nil, homePanel)
        if MasterMgr:isTeacher() then
            -- 4200100 "发布任务"
            self:setLabelText("Label1", CHS[4200101], btn)
            self:setLabelText("Label2", CHS[4200101], btn)
            self:setLabelText("ItemLabel_1", CHS[4200102], homePanel)
        else
            self:setLabelText("Label1", CHS[4200103], btn)
            self:setLabelText("Label2", CHS[4200103], btn)
            self:setLabelText("ItemLabel_1", CHS[4200104], homePanel)
        end
        self:setCtrlVisible("ItemLabel_2", false, homePanel)
        btn.info = charInfo
        self:bindTouchEndEventListener(btn, self.onIssueTaskButton)

        self:setCtrlVisible("TaskListView", false)
     --
    elseif charInfo.shouyeCount <= charInfo.shouyeCompleteCount then
        -- 已完成所有
        self:setLabelText("NoCompleteLabel", "", "WorkInfoPanel")
    else
        -- 完成部分     已完成:%d/%d
        self:setLabelText("NoCompleteLabel", string.format(CHS[4200105], charInfo.shouyeCompleteCount, charInfo.shouyeCount), "WorkInfoPanel")
    end
    self:setCtrlVisible("CompleteImage", (charInfo.shouyeCount <= charInfo.shouyeCompleteCount and charInfo.shouyeCount ~= 0), "WorkInfoPanel")


    -- 授业各个任务具体情况
    for i = 1, 3 do
        local info = charInfo.shouyeInfo[i]
        local panel = self:getControl("WorkPanel_" .. i)
        if info then
            panel:setVisible(true)
            self:setLabelText("NameLabel", info.intro, panel)
            self:setLabelText("TimeLabel", string.format("（%d/%d）", info.completeTimes, info.timeMax), panel)
            local goBtn = self:getControl("GotoButton", nil, panel)
            goBtn.info = info
            if MasterMgr:isTeacher() then
                goBtn:setVisible(false)
            else
                goBtn:setVisible(not info.isComplete)
            end

            self:bindTouchEndEventListener(goBtn, self.onTaskGotoButton)
            self:setCtrlVisible("CompleteImage", info.isComplete, panel)
        else
            panel:setVisible(false)
        end
        panel:requestDoLayout()
    end

    homePanel:requestDoLayout()
end

function MasterRelationDlg:onIssueTaskButton(sender)
    if not sender.info then return end
    if not self:conditionsChuuanDao(sender.info) then return end

    if MasterMgr:isTeacher() then
        -- 发布任务
        local dlg = DlgMgr:openDlg("HomeworkDlg")
        dlg:setStudent(sender.info)
    else
        if not self:isOutLimitTime("lastIsseTime", 60000) then
            gf:ShowSmallTips(CHS[4101002])     -- 60秒内只能催促一次。
            return
        end

        local myMasterInfo = MasterMgr:getMyMasterInfo()
        if (myMasterInfo.alreadyCompleteCdsyTask == 1) then
            gf:ShowSmallTips(CHS[5000296])
            return
        end

        -- 催促师父
        self:setLastOperTime("lastIsseTime", gfGetTickCount())
        local info = MasterMgr:getTeacherInfoInMaster()
        FriendMgr:communicat(info.name, info.gid, info.icon, info.level)
        local dlg = DlgMgr:getDlgByName("FriendDlg")
        -- [4200106] 师父，你今天还没有给我布置传道授业任务，前往#R辛仁皑#n处发布传道授业任务，师徒都可以获得奖励哦!
        if dlg then dlg:sendMsg(CHS[4200106]) end
    end
end

function MasterRelationDlg:onTaskGotoButton(sender)
    if not sender.info then return end
    local decStr = ""
    if sender.info.taskName == CHS[6000106] then    -- 师门任务
        if TaskMgr:getSMTask() then
            decStr = TaskMgr:getSMTask()
        else
            local npcName = gf:getPolarNPC(tonumber(Me:queryBasic("polar")))
            decStr = string.format(CHS[3002200],npcName)
        end

        local dest = gf:findDest(decStr)

        if dest then
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            -- 解析打开对话框
            local tempStr = string.match(decStr, "#@.+#@")
            if tempStr then
                -- 解析#@道具名|FastUseItemDlg=道具名
                tempStr = string.match(decStr, "|.+=.+")
            end
            if tempStr then
                tempStr = string.sub(tempStr,2)
                tempStr = string.sub(tempStr, 1, -3)
                DlgMgr:openDlgWithParam(tempStr)
            end
        end
    elseif sender.info.taskName == CHS[3002219] then    -- 除暴任务
        if TaskMgr:getCBTask() then
            decStr = TaskMgr:getCBTask()
        else
            decStr = CHS[3002221]
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3000279] then    -- 竞技场
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[3000280]))
    elseif sender.info.taskName == CHS[3001735] then    -- 帮派任务
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
        else
            if TaskMgr:getPartyTask() then
                decStr = TaskMgr:getPartyTask()
            else
                decStr = CHS[3002215]
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3002192] then    -- 仙界神捕
        if TaskMgr:getXuanShangTask() then
            decStr = TaskMgr:getXuanShangTask()
        else
            decStr = CHS[3002228]     -- 仙界神捕
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3002205] then    -- 助人为乐
        if TaskMgr:getZhuRenWeiLeTask() then
            decStr = TaskMgr:getZhuRenWeiLeTask()
        elseif Me:queryBasicInt("level") >= 70 and Me:isVip() then
            decStr = CHS[2200067]
        else
            decStr = CHS[3002207]
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3002210] then    -- 帮派日常挑战
        if Me:queryBasic("party/name") == "" then
            gf:ShowSmallTips(CHS[3002211])
        else
            if TaskMgr:getPartyChallengeTask() then
                decStr = TaskMgr:getPartyChallengeTask()
            elseif Me:queryBasicInt("level") >= 70 and Me:isVip() then
                decStr = CHS[2200068]
            else
                decStr = CHS[3002213]
            end
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3002203] then    -- 通天塔
        if TaskMgr:getTongtianTowerTask() then
            decStr = TaskMgr:getTongtianTowerTask()
        else
            decStr = CHS[3002204]
        end

        AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    elseif sender.info.taskName == CHS[3002227] then    -- 八仙梦境
        if TaskMgr:getTaskByName(CHS[3002227]) then
            decStr = TaskMgr:getTaskByName(CHS[3002227]).task_prompt
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
        else
            -- #P蓬莱使者|E=我要进入八仙梦境#P
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[3000311]))
        end
    end
    self:onCloseButton()
end


-- 设置玩家任务
function MasterRelationDlg:setTask(charInfo)
    if not charInfo then return end
    -- 出师、师徒任务
    self:setMasterTask(charInfo)

    -- 传道授业任务
    self:setHomeworkTask(charInfo)
end

function MasterRelationDlg:onStudentCheckBox(sender, eventType)
    Log:D("==============点击了：" .. self:getLabelText("Label1", sender) .. "================")
    if sender:getName() ~= "TaskCheckBox" then
        self:setCtrlVisible("StudentPanel", true)
        self:setCtrlVisible("WordsPanel", true)
        self:setCtrlVisible("TaskPanel", false)
        self:setCtrlVisible("GraduationPanel", false)
        self:setCtrlVisible("HomeworkPanel", false)
        self:setCtrlVisible("GraduateTipsPanel", false)
        self:setCtrlVisible("BackImage_1", false)
        self:setCtrlVisible("BackImage_2", false)
    else
        if sender.charInfo == 1 then
            DlgMgr:openDlg("MasterDlg")
            return
        end
        self:setCtrlVisible("BackImage_1", true)
        self:setCtrlVisible("BackImage_2", true)
        self:setCtrlVisible("TaskPanel", true)
        self:setCtrlVisible("GraduationPanel", true)
        self:setCtrlVisible("GraduateTipsPanel", true)
        self:setCtrlVisible("StudentPanel", false)
        self:setCtrlVisible("WordsPanel", false)
        self:setTask(MasterMgr:getMeInfoInMaster())
    end
end

-- 设置对话框
function MasterRelationDlg:initSelect()
    if not MasterMgr:isTeacher() then
        self.studentGroup:setSetlctByName(STUDENT_CHECKBOS[1])
        self:setDlgDisplayType(DISPLAY_TYPE.STUDENT)
        self:setCtrlVisible("StudentPanel", true)

        -- 徒弟视角
        self:setStudentType()
    else
        self.teacherGroup:setSetlctByName(TEACHER_CHECKBOS[1])
        self:setDlgDisplayType(DISPLAY_TYPE.TEACHER)
        self:setCtrlVisible("TeacherPanel", true)

        -- 师父视角-设置徒弟信息
        self:setTeacherType()
    end
end

function MasterRelationDlg:setSingelStudent(index, info)
    local panel = self:getControl("InfoPanel" .. (index - 1))
    local isTeacher = MasterMgr:isTeacher()
    if not info then
        -- 信息
        self:setCtrlVisible("ShapePanel", false, panel)
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("TimeLabel", "", panel)
        self:setLabelText("FriendlyLabel", "", panel)
        self:setLabelText("ContentLabel", "", panel)

        self:setCtrlVisible("InteractiveButton", false, panel)
        self:setCtrlVisible("TaskButton", false, panel)
        self:setCtrlVisible("SInteractiveButton", false, panel)
        if isTeacher then
            self:setCtrlVisible("FoundButton", true, panel)
        else
            self:setCtrlVisible("FoundButton", false, panel)
        end
        return
    end

    panel.charInfo = info
    self:setCtrlVisible("ShapePanel", true, panel)
    self:setImage("ActiveImage", ResMgr:getSmallPortrait(info.icon), panel)
    self:setItemImageSize("ActiveImage", panel)
    self:setLabelText("NameLabel", info.name, panel)
    -- [4100138] = "%Y-%m-%d拜师",
    self:setLabelText("TimeLabel", gf:getServerDate(CHS[4100138], info.masterTime), panel)
    -- [4100139] = "友好度："
    self:setLabelText("FriendlyLabel", CHS[4100139] .. info.friend, panel)
    self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 离线时间
    if info.unOnlineTime >= 60 * 60 * 24 then
        -- [4100140] = "离线%d 天",
        self:setLabelText("ContentLabel", string.format(CHS[4100140], math.floor(info.unOnlineTime / (60 * 60 * 24))), panel)
    elseif info.unOnlineTime > 0 then
        -- [4100141] = "离线%d 小时",
        self:setLabelText("ContentLabel", string.format(CHS[4100141], math.floor(info.unOnlineTime / (60 * 60))), panel)
    else
        self:setLabelText("ContentLabel", CHS[4100127], panel)
    end
    self:setCtrlVisible("InteractiveButton", true, panel)

    self:setCtrlVisible("FoundButton", false, panel)

    local taskBtn = self:getControl("TaskButton", nil, panel)
    if isTeacher then
        self:setCtrlVisible("InteractiveButton", true, panel)
        self:setCtrlVisible("TaskButton", true, panel)
        self:setCtrlVisible("SInteractiveButton", false, panel)
        --      [4100142] = "发布任务",
        self:setLabelText("Label1", CHS[4100142], taskBtn)
        self:setLabelText("Label2", CHS[4100142], taskBtn)
    else
        self:setCtrlVisible("SInteractiveButton", Me:getName() ~= info.name, panel)
        self:setCtrlVisible("InteractiveButton", false, panel)
        self:setCtrlVisible("TaskButton", Me:getName() == info.name, panel)
        --      [4100143] = "查看任务",
        self:setLabelText("Label1", CHS[4100143], taskBtn)
        self:setLabelText("Label2", CHS[4100143], taskBtn)

        self:setLabelText("FriendlyLabel", "", panel)
    end
end

-- 设置师兄弟信息  -- 徒弟视角
function MasterRelationDlg:setStudentType()
    local masterInfo = MasterMgr:getMyMasterInfo()
    local studentsPanel = self:getControl("StudentPanel")
    if not next(masterInfo) or masterInfo.count == 0 then
        -- 徒弟视角，无师徒关系
        for i = 1, 3 do
            self:setCtrlVisible("InfoPanel" .. i, false, studentsPanel)
        end

        local checkBox = self:getControl(STUDENT_CHECKBOS[2])
        checkBox.charInfo = 1 -- 打开师门对话框
        self:setLabelText("Label1", CHS[4200092], checkBox)
        self:setLabelText("Label2", CHS[4200092], checkBox)

        self:setCtrlVisible("NonePanel", true, studentsPanel)

        -- 无师傅，尝试移除仙魔光效（解除关系，状态刷新）
        self:removeUpgradeMagicToCtrl("FigurePanel")
        return
    end
    for i = 1, 3 do
        self:setCtrlVisible("InfoPanel" .. i, true, studentsPanel)
    end
    self:setCtrlVisible("NonePanel", false, studentsPanel)
    local checkBox = self:getControl(STUDENT_CHECKBOS[2])
    self:setLabelText("Label1", CHS[4200086], checkBox)
    self:setLabelText("Label2", CHS[4200086], checkBox)


    for i = 2,#STUDENT_CHECKBOS do
        local info = masterInfo.userInfo[i]
        local checkBox = self:getControl(STUDENT_CHECKBOS[i])
        if info then
            -- checkBox
            self:setLabelText("Label1", info.name, checkBox)
            self:setLabelText("Label2", info.name, checkBox)
            checkBox.charInfo = info
            self:setCtrlVisible(STUDENT_CHECKBOS[i], true)
        else
            self:setCtrlVisible(STUDENT_CHECKBOS[i], false)
        end

        -- 设置徒弟信息
        self:setSingelStudent(i, info)
    end

    self:setLeftInfo(masterInfo.userInfo[1])
end

-- 设置徒弟信息  -- 师父视角
function MasterRelationDlg:setTeacherType()
    local masterInfo = MasterMgr:getMyMasterInfo()
    local studentsPanel = self:getControl("StudentPanel")
    if not next(masterInfo) or masterInfo.count == 0 then
        -- 师父视角 没有徒弟
        for i = 1, 3 do
            self:setCtrlVisible("InfoPanel" .. i, false, studentsPanel)
        end

        for i = 2,#TEACHER_CHECKBOS do
            local checkBox = self:getControl(TEACHER_CHECKBOS[i])
            self:setCtrlVisible(TEACHER_CHECKBOS[i], i == 2 )
            checkBox.charInfo = 1 -- 打开师门对话框
            --
            self:setLabelText("Label1", CHS[4200093], checkBox)
            self:setLabelText("Label2", CHS[4200093], checkBox)
            --]]
        end

        self:setCtrlVisible("NonePanel", true, studentsPanel)

        -- 无徒弟，尝试移除仙魔光效（解除关系，状态刷新）
        self:removeUpgradeMagicToCtrl("FigurePanel")
        return
    end
    self:setCtrlVisible("NonePanel", false, studentsPanel)
    local meCheckBox = self:getControl(TEACHER_CHECKBOS[1])
    meCheckBox.charInfo = masterInfo.userInfo[1]

    for i = 2,#TEACHER_CHECKBOS do
        local info = masterInfo.userInfo[i]
        local checkBox = self:getControl(TEACHER_CHECKBOS[i])
        checkBox:setVisible(true)
        if info then
            -- checkBox
            self:setLabelText("Label1", info.name, checkBox)
            self:setLabelText("Label2", info.name, checkBox)
            checkBox.charInfo = info
        else
            self:setCtrlVisible(TEACHER_CHECKBOS[i], false)
            checkBox.charInfo = 1 -- 打开师门对话框
            --[[
            self:setLabelText("Label1", CHS[4200093], checkBox)
            self:setLabelText("Label2", CHS[4200093], checkBox)
            --]]
        end

        -- 设置徒弟信息
        self:setSingelStudent(i, info)
    end

    local ctrl = self.teacherGroup:getSelectedRadio()
    if ctrl and ctrl.charInfo then self:setLeftInfo(ctrl.charInfo) end
end

-- 设置我信息
function MasterRelationDlg:setLeftInfo(info)
    if not info or info == 1 then return end    -- info == 1 表示点击该选项打开对话框
    local panel = self:getControl("ItemPanel")
    panel.charInfo = info
    self:setLabelText("NameLabel", info.name, panel)
    self:setLabelText("LevelLabel", info.level .. CHS[5300006], panel)
    --  self:setPortrait("FigurePanel", Me:queryBasicInt("icon"))
    if info.suitIcon == 0 then
        self:setPortrait("FigurePanel", info.icon, info.weaponIcon, panel, nil, nil, nil, cc.p(0 , -20), info.icon)
    else
        self:setPortrait("FigurePanel", info.suitIcon, info.weaponIcon, panel, nil, nil, nil, cc.p(0 , -20), info.icon)
    end

    -- 仙魔光效
    if info["upgrade/type"] then
        self:addUpgradeMagicToCtrl("FigurePanel", info["upgrade/type"], panel, true)
    end

    if info.isMaster == 1 then
        -- 显示的是师父    [4100144] = "师  父",
        self:setLabelText("Label_214", CHS[4100144], "TitleImage")
        self:setLabelText("Label_214_0", CHS[4100144], "TitleImage")
        self:setLabelText("GraduateLabel", CHS[4100126] .. info.oldStudent, panel)

        local isMe = (info.gid == Me:queryBasic("gid"))
        self:setCtrlVisible("CommunionButton", not isMe, panel)
        self:setCtrlVisible("InteractiveButton", not isMe, panel)
        if not isMe then
            self:setLabelText("FriendlyLabel", CHS[4100139] .. info.friend, panel)

            -- 离线时间
            if info.unOnlineTime >= 60 * 60 * 24 then
                -- [4100140] = "离线%d 天",
                self:setLabelText("OlineLabel", string.format(CHS[4100140], math.floor(info.unOnlineTime / (60 * 60 * 24))), panel)
            elseif info.unOnlineTime > 0 then
                -- [4100141] = "离线%d 小时",
                self:setLabelText("OlineLabel", string.format(CHS[4100141], math.floor(info.unOnlineTime / (60 * 60))), panel)
            else
                self:setLabelText("OlineLabel", CHS[4100127], panel)
            end


            self:setLabelText("GraduateLabel", "", panel)
        else
            self:setLabelText("FriendlyLabel", "", panel)
            self:setLabelText("OlineLabel", "", panel)
        end
    else
        -- 显示的是徒弟  [4100145] = "徒  弟",
        self:setLabelText("Label_214", CHS[4100145], "TitleImage")
        self:setLabelText("Label_214_0", CHS[4100145], "TitleImage")
        self:setLabelText("GraduateLabel", "", panel)
        self:setCtrlVisible("CommunionButton", true, panel)
        self:setCtrlVisible("InteractiveButton", true, panel)
        self:setLabelText("FriendlyLabel", CHS[4100139] .. info.friend, panel)

        local childPanel = self:getControl("GraduationPanel");
        self:getControl("TaskButton", nil, childPanel).gid = info.gid

        if info.unOnlineTime == 0 then
            self:setLabelText("OlineLabel", CHS[4200080], panel)
        else
            self:setLabelText("OlineLabel", CHS[4200081], panel)
        end
    end

    self:setCtrlVisible("WordsButton", Me:getName() == info.name, panel)
    self:setCtrlVisible("LeaveButton", Me:getName() ~= info.name, panel)
    self:getControl("LeaveButton", nil, panel).gid = info.gid
end

function MasterRelationDlg:setDlgDisplayType(type)
    self:setCtrlVisible("TeacherCheckPanel", false)
    self:setCtrlVisible("StudentCheckPanel", false)
    if type == DISPLAY_TYPE.STUDENT then
        self:setCtrlVisible("StudentCheckPanel", true)
    else
        self:setCtrlVisible("TeacherCheckPanel", true)
        self:setCtrlVisible("StudentPanel", true)
        self:setCtrlVisible("WordPanel", true)
    end
end

function MasterRelationDlg:setTeacherMessage(str, panel)
    -- 删除残留的留言
    local destPanel = self:getControl("TWordsPanel", nil, panel)
    local lastMessage = destPanel:getChildByName("ColorText")
    if lastMessage then lastMessage:removeFromParent() end

    local size = destPanel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setString(gf:filterPlayerColorText(str))
    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    textCtrl:updateNow()
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition(0, size.height)

    local colorText = tolua.cast(textCtrl, "cc.LayerColor")
    colorText:setName("ColorText")
    destPanel:addChild(colorText)
end

function MasterRelationDlg:onCommunionButton(sender, eventType)
    if not next(MasterMgr.myMasterInfo) or MasterMgr.myMasterInfo.count == 0 then return end
    local panel = sender:getParent()
    local info = panel.charInfo
    if not info then return end
    FriendMgr:communicat(info.name, info.gid, info.icon, info.level)
end

function MasterRelationDlg:onLeaveButton(sender, eventType)
    if not sender.gid then return end
    if not next(MasterMgr.myMasterInfo) or MasterMgr.myMasterInfo.count == 0 then return end
    MasterMgr:releaseRelation(sender.gid)
end

function MasterRelationDlg:onWordsButton(sender, eventType)
    if not next(MasterMgr.myMasterInfo) or MasterMgr.myMasterInfo.count == 0 then return end
    local dlg = DlgMgr:openDlg("MessageDlg")
    dlg:setDisplay(5)
end

function MasterRelationDlg:onWorkInfoPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("HomeworkInfoDlg")
    dlg:setData(MasterMgr:getRewardChuandao())
end

function MasterRelationDlg:onTaskInfoButton(sender, eventType)
    local panel = self:getControl("StudentPanel", nil, sender)
    if not panel.charInfo then return end
    if sender:getName() == "GraduationPanel" then
        local dlg = DlgMgr:openDlg("ActivitiesInfoFFDlg")
        dlg:setFullData(MasterMgr:getRewardGraduate())
    else
        local dlg = DlgMgr:openDlg("MentorTaskInfoDlg")
        dlg:setData(MasterMgr:getRewardMaster())
    end
end

function MasterRelationDlg:onShiTuTaskButton(sender, eventType)
    local decStr = CHS[4200085]

    AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
    self:onCloseButton()
end

function MasterRelationDlg:onGraduateTaskButton(sender, eventType)
    if MasterMgr:isTeacher() then
        if not sender.gid then return end
        gf:CmdToServer("CMD_FETCH_CHUSHI_TASK", { gid = sender.gid })
    else
        gf:CmdToServer("CMD_FETCH_CHUSHI_TASK", { gid = "" })
    end
    self:onCloseButton()
end

function MasterRelationDlg:onTaskButton(sender, eventType)
    local tag = sender:getParent():getTag()

    if MasterMgr:isTeacher() then
        self.teacherGroup:setSetlctByName(TEACHER_CHECKBOS[tag + 1])
    else
        self.studentGroup:setSetlctByName(STUDENT_CHECKBOS[2])
    end
end

function MasterRelationDlg:onFoundButton(sender, eventType)
    DlgMgr:openDlg("MasterDlg")
    self:onCloseButton()
end

function MasterRelationDlg:onInteractiveButton(sender, eventType)
    local panel = sender:getParent()
    local info = panel.charInfo
    if not info then return end
    MasterRelationDlg.onCharInfo = function(self, gid)
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            dlg:setting(gid)
            dlg:setFloatingFramePos(rect)
        end
    end
    FriendMgr:requestCharMenuInfo(info.gid, self.name)
end

function MasterRelationDlg:onGotoButton(sender, eventType)
end

function MasterRelationDlg:onSelectListView(sender, eventType)
end

-- 发布传道授业任务条件
function MasterRelationDlg:conditionsChuuanDao(charInfo)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if charInfo.level >= MasterMgr:getBeMasterLevel() then
        if MasterMgr:isTeacher() then
            gf:ShowSmallTips(CHS[4200107])
        else
            gf:ShowSmallTips(CHS[4200108])
        end
        return false
    end

    return true
end

function MasterRelationDlg:onDlgOpened(list, param)
    if param == CHS[4200086] then
        local checkBox = self:getControl(STUDENT_CHECKBOS[2])
        if self:getLabelText("Label1", checkBox) == CHS[4200086] then
            self.studentGroup:setSetlctByName(STUDENT_CHECKBOS[2])
        end
    end
end

function MasterRelationDlg:MSG_MY_APPENTICE_INFO(data)
    if data.count == 0 then
        self:initSelect()
        self:setLeftShapeInfo()
        self:setCtrlVisible("WordsPanel", false)
        self:setCtrlVisible("BackImage_1", false)
        self:setCtrlVisible("TitleImage", false, "StudentPanel")
        self:setCtrlVisible("BackImage_2", false)

        self:setCtrlVisible("CommunionButton", false)
        self:setCtrlVisible("InteractiveButton", false)

        self:setCtrlVisible("GraduateTipsPanel", false)
        self:setCtrlVisible("TaskPanel", false)
        self:setCtrlVisible("GraduationPanel", false)
    else
        local index = 1
        if MasterMgr:isTeacher() then
            repeat
                index = self.teacherGroup:getSelectedRadioIndex()
                if not index then self:initSelect() end
            until index ~= nil
        else
            repeat
                index = self.studentGroup:getSelectedRadioIndex()
                if not index then self:initSelect() end
            until index ~= nil
            self.studentGroup:setSetlctByName(STUDENT_CHECKBOS[index])
        end

        if not data.userInfo[index] and MasterMgr:isTeacher() then
            self.teacherGroup:setSetlctByName(TEACHER_CHECKBOS[1])
        end

        -- 徒弟视角
        self:setStudentType()

        -- 师父视角-设置徒弟信息
        self:setTeacherType()

        self:setTask(data.userInfo[index])
    end
end

function MasterRelationDlg:MSG_MY_MASTER_MESSAGE(data)
    self:setTeacherMessage(data.message, self:getControl("WordsPanel"))
end

function MasterRelationDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    gf:ShowSmallTips(CHS[7002017])
end

return MasterRelationDlg
