-- KidInfoDlg.lua
-- Created by songcw Feb/02/2019
-- 居所娃娃信息界面

local KidInfoDlg = Singleton("KidInfoDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 2分30秒记住选中的
local REMEMBER_TIME = 150000

-- （1表示散步，2表示音乐，3表示按摩，4表示使用安胎药，5表示注入能量）
local CARE_TYPE = {
    [CHS[4010389]] = 1,     -- 散步
    [CHS[4010390]] = 2,     -- 音乐
    [CHS[4010391]] = 3,     -- 按摩
}

-- 婴儿期CheckBox
local YE_CHECKBOS = {
    "CheckBox_1",         -- 状态
    "CheckBox_2",         -- 资质
}

-- 婴儿期按钮操作类型
local YE_BUTTON = {
    FUYANG = 1,     -- 抚养
    BAISHI = 2,     -- 拜师
}

-- 家务类型配置
local HOMEWORK_TYPE_CFG = {
    DIAOYU = 1,
    BOZHONG = 2,
    SHOUHUO = 3,
}

-- 家务数据配置
local HOMEWORK_CFG = {
    [HOMEWORK_TYPE_CFG.DIAOYU] = {name = CHS[7100414], iconPath = ResMgr.ui.kid_diaoyu_image, btnChs = CHS[7100422], desc = CHS[7100419]}, -- 钓鱼
    [HOMEWORK_TYPE_CFG.BOZHONG] = {name = CHS[7100415], iconPath = ResMgr.ui.kid_bozhong_image, btnChs = CHS[7100423], desc = CHS[7100420]}, -- 播种
    [HOMEWORK_TYPE_CFG.SHOUHUO] = {name = CHS[7100416], iconPath = ResMgr.ui.kid_shouhuo_image, btnChs = CHS[7100424], desc = CHS[7100421]}, -- 收获
}

-- 右侧页签
local RIGHT_MENU_CHECKBOX = {"AttributeCheckBox", "HouseworkPanelCheckBox"}

-- 儿童期属性CheckBox
local ETQ_CHECKBOS = {
    "CheckBox_1",         -- 基础属性
    "CheckBox_2",         -- 资质技能
}

local DAILY_TASK_INFO = {
    [CHS[4101490]] = {name = CHS[4200715], desc = CHS[4200716], mainReward = CHS[4200717], littleReward = CHS[4200718]},
    [CHS[4101491]] = {name = CHS[4200719], desc = CHS[4200720], mainReward = CHS[4200717], littleReward = CHS[4200718]},
    [CHS[4101492]] = {name = CHS[4200721], desc = CHS[4200722], mainReward = CHS[4200723], littleReward = CHS[4200724]},
    [CHS[4101497]] = {name = CHS[4200725], desc = CHS[4200726], mainReward = CHS[4200724], littleReward = CHS[4200727]},
    [CHS[4101493]] = {name = CHS[4200728], desc = CHS[4200729], mainReward = CHS[4200730], littleReward = CHS[5000059]},
}

local PAGE_MAX_COUNT = 10

function KidInfoDlg:init(data)
    self:bindListener("RenameButton", self.onRenameButton)

    self:bindListener("MoneyPanel", self.onMoneyButton, "YEKidInfoPanel")
    self:bindListener("MoneyPanel", self.onMoneyButton, "ETQJWKidInfoPanel")
    self:bindListener("MoneyPanel", self.onMoneyButton, "ETQKidInfoPanel")
    self:bindListener("TakeCareButton", self.onTakeCareButton)
    self:bindListener("FeedButton", self.onFeed1Button, "TEKidInfoPanel")
    self:bindListener("MedicineButton", self.onMedicineButton)
    self:bindListener("FeedButton", self.onFeed2Button, "LSKidInfoPanel")

    self:bindListener("InfoButton", self.onTERulePanel, "TEKidInfoPanel")
    self:bindListener("InfoButton", self.onLSRulePanel, "LSKidInfoPanel")
    self:bindListener("InfoButton", self.onYERulePanel, "YEKidInfoPanel")

    self:bindListener("BronButton", self.onBronButton, "TEKidInfoPanel")
    self:bindListener("BronButton", self.onBronButton, "LSKidInfoPanel")

    self:bindListener("SeeButton", self.onSeeOrHideButton, "KidShapePanel")
    self:bindListener("HideButton", self.onSeeOrHideButton, "KidShapePanel")

    self:bindListener("BagButton", self.onBagButton)
    self:bindListener("MissionButton", self.onMissionButton)
    self:bindListener("CloseNoMissionButton", self.onCloseNoMissionButton)
    self:bindListener("UnclaimedMissionButton", self.onUnMissionButton)
    self:bindListener("GetButton", self.onDailyGetButton, "MissionPanel")
    self:bindListener("GoButton", self.onDailyGoButton, "MissionPanel")
    self:bindListener("GrowButton", self.onGrowButton, "MissionPanel")

    self:setCtrlVisible("KidPanel", true)

    self:bindListener("BagPanel", function ()
        self:setCtrlVisible("BagPanel", false)
    end)

    self:bindListener("ClosePanel", function ()
        self:setCtrlVisible("MissionPanel", false)
    end, "MissionPanel")

    self:bindListener("ClosePanel", function ()
        self:setCtrlVisible("NoMissionPanel", false)
    end, "NoMissionPanel")

    self:bindFloatPanelListener("TERulePanel")
    self:bindFloatPanelListener("LSRulePanel")
    self:bindFloatPanelListener("YERulePanel")
    self:bindFloatPanelListener("ETQRulePanel1")
    self:bindFloatPanelListener("ETQRulePanel2")
    self:bindFloatPanelListener("BagPanel")
    self:bindFloatingEvent("NoMissionPanel")
    self:bindFloatingEvent("MissionPanel")

    self:setCtrlVisible("SeeButton", false)
    self:setCtrlVisible("HideButton", false)

    self:setCtrlVisible("BagButton", false)
    self:setCtrlVisible("MissionButton", false)
    self:setCtrlVisible("UnclaimedMissionButton", false)

    -- 婴儿期CheckBox
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, YE_CHECKBOS, self.onYECheckBox, "YEKidInfoPanel")
    --self:onYECheckBox(self:getControl(YE_CHECKBOS[1], nil, panel))
    self.radioGroup:setSetlctByName(YE_CHECKBOS[1])

    for i = 1, 6 do
        local panel = self:getControl("IconPanel" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onClickChild)
    end

    if not self.lastCloseTime or gfGetTickCount() - self.lastCloseTime >= REMEMBER_TIME then
        self.lastSelectTag = nil
    end

    self.selectImage = self:retainCtrl("ChosenImage")
    self.unitLogPanel = self:retainCtrl("TextPanel")

    self.homeworkListView = self:getControl("HomeWorkListView")
    self.homeworkPanel = self:retainCtrl("OneCasePanel", "ETQJWKidInfoPanel")

    -- 选中属性、家务页签
    self.switchRadioGroup = RadioGroup.new()
    self.switchRadioGroup:setItems(self, RIGHT_MENU_CHECKBOX, self.onSwitchCheckBox)
    self.switchRadioGroup:selectRadio(1)

    -- 儿童期娃娃基础属性、资质技能菜单
    self.kidsRadioGroup = RadioGroup.new()
    self.kidsRadioGroup:setItems(self, ETQ_CHECKBOS, self.onSwitchKidCheckBox, "ETQKidInfoPanel")
    self.kidsRadioGroup:selectRadio(1)

    -- 设置胎儿列表
    self:setKidList(data)

    self:hookMsg("MSG_CHILD_INFO")
    self:hookMsg("MSG_CHILD_JOIN_FAMILY")
    self:hookMsg("MSG_SET_COMBAT_CHILD")
    self:hookMsg("MSG_SET_VISIBLE_CHILD")
    self:hookMsg("MSG_COUPLE_INFO")
    self:hookMsg("MSG_UPDATE_CHILDS")
    self:hookMsg("MSG_UPDATE_SKILLS")
    self:hookMsg("MSG_CHILD_CULTIVATE_INFO")

    -- 分页加载日志
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 下拉获取下一页
            performWithDelay(self.root, function ()
                self:pushPregnancyLog()
            end, 0.2)
        end
    end)

    self:requestData()
end

function KidInfoDlg:requestData()
    -- 更新数据
    gf:CmdToServer("CMD_CHILD_REQUEST_INFO")
end


function KidInfoDlg:onSwitchCheckBox(sender, eventType)
    self:setCtrlVisible("NoMissionPanel", false)
    self:setCtrlVisible("MissionPanel", false)

    if self.selectChild and self.selectChild.data
        and self.selectChild.data.stage ~= HomeChildMgr.CHILD_TYPE.KID
        and sender:getName() == "HouseworkPanelCheckBox" then
        gf:ShowSmallTips(CHS[7100412])
    end

    for k , v in pairs(RIGHT_MENU_CHECKBOX) do
        local checkBox = self:getControl(v)
        if sender:getName() == v then
            self:setCtrlVisible("ChosenLabel_1", true, checkBox)
            self:setCtrlVisible("ChosenLabel_2", true, checkBox)
            self:setCtrlVisible("UnChosenLabel_1", false, checkBox)
            self:setCtrlVisible("UnChosenLabel_2", false, checkBox)
        else
            self:setCtrlVisible("ChosenLabel_1", false, checkBox)
            self:setCtrlVisible("ChosenLabel_2", false, checkBox)
            self:setCtrlVisible("UnChosenLabel_1", true, checkBox)
            self:setCtrlVisible("UnChosenLabel_2", true, checkBox)
        end
    end

    self:updateChildData()
end

function KidInfoDlg:onYECheckBox(sender, eventType)
    local panel = self:getControl("YEKidInfoPanel")
    self:setCtrlVisible("KidInfoPanel", sender:getName() == "CheckBox_1", panel)
    self:setCtrlVisible("KidEffectPanel", sender:getName() == "CheckBox_2", panel)


end

function KidInfoDlg:cleanup()
    self.lastCloseTime = gfGetTickCount()
    self.selectChild = nil
    self.childData = nil
end

-- 点击胎儿
function KidInfoDlg:onClickChild(sender, eventType, notTips, isRefresh)
    if not sender.data then return end
    if self.selectChild == sender and not isRefresh then
        return
    end

    if self.selectChild ~= sender and not notTips then
        if sender.data.destroyTime > 0 then
            gf:ShowSmallTips(CHS[4101449])
        end
    end

    -- 选中的tag，用于下次打开默认选择
    self.lastSelectTag = sender.data.id

    if self.selectChild and self.selectChild.data and self.selectChild.data.stage ~= HomeChildMgr.CHILD_TYPE.KID
        and sender.stage == HomeChildMgr.CHILD_TYPE.KID then
        -- 由非儿童期的娃娃切换到儿童期的娃娃时，默认选择家务
        self.selectChild = sender
        self.switchRadioGroup:selectRadio(2)
    else
        -- 当前选择的胎儿panel
        self.selectChild = sender

        -- 更新胎儿数据
        self:updateChildData()
    end

    -- 选中光效
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)

    -- 更新名字形象
    self:updateNameAndShape()

    self:updateDailyInfo()
end

function KidInfoDlg:runActionDailyTask(isRun)
    local btn = self:getControl("MissionButton")
    local btnBkImage = self:getControl("MissionButtonBKImage")

    local delaytime = 0.23
    if isRun then

        if not btn.isRun then
        --btnBkImage:setOpacity
            local func1 = cc.CallFunc:create(function()
                btnBkImage:setOpacity(51)
                btn:setRotation(0)
            end)

            local func2 = cc.CallFunc:create(function()
                btnBkImage:setOpacity(153)
                btn:setRotation(15)
            end)

            local func3 = cc.CallFunc:create(function()
                btnBkImage:setOpacity(255)
                btn:setRotation(0)
            end)

            local func4 = cc.CallFunc:create(function()
                btnBkImage:setOpacity(153)
                btn:setRotation(345)
            end)

            local act = cc.Sequence:create(func1, cc.DelayTime:create(delaytime), func2, cc.DelayTime:create(delaytime), func3, cc.DelayTime:create(delaytime), func4, cc.DelayTime:create(delaytime))
            btn:runAction(cc.RepeatForever:create(act))
        end
    else
        btn:stopAllActions()
        btnBkImage:setOpacity(255)
        btn:setRotation(0)
    end

    btn.isRun = isRun
end

function KidInfoDlg:updateDailyInfo()
    -- 按钮

    self:setCtrlVisible("BagButton", self.selectChild.data.stage == HomeChildMgr.CHILD_TYPE.KID)
    if self.selectChild.data.stage == HomeChildMgr.CHILD_TYPE.KID then
        self:setCtrlVisible("MissionButton", self.selectChild.data.task_stage ~= 2)
        self:setCtrlVisible("UnclaimedMissionButton", self.selectChild.data.task_stage == 2)

        if self.selectChild.data.task_stage == 0 then
            self:runActionDailyTask(true)
        else
            self:runActionDailyTask(false)
        end
    else
        self:setCtrlVisible("MissionButton", false)
        self:setCtrlVisible("UnclaimedMissionButton", false)
    end



    if self.selectChild.data.stage ~= HomeChildMgr.CHILD_TYPE.KID then return end

    local taskInfo = DAILY_TASK_INFO[self.selectChild.data.task_name]

    -- 任务名称
    self:setLabelText("MissionNameLabel", taskInfo.name)

    -- 描述
    self:setLabelText("MissionDescLabel", taskInfo.desc)

    -- 主要奖励
    self:setLabelText("MissionRewardLabel_1", taskInfo.mainReward)



    ---- 书包

    -- 道法残卷
    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[4101495]), "SingleItemPanel")
    self:setLabelText("Label_2", self.selectChild.data.daofa, "SingleItemPanel")

    -- 心法
    self:setImage("ItemImage", ResMgr:getIconPathByName(CHS[4101496]), "SingleItemPanel2")
    self:setLabelText("Label_2", self.selectChild.data.xinfa, "SingleItemPanel2")


    self:setCtrlVisible("GoButton", self.selectChild.data.task_owner == Me:queryBasic("gid"))
    self:setCtrlVisible("GetButton", self.selectChild.data.task_owner ~= Me:queryBasic("gid"))

end

function KidInfoDlg:getChildGenderChs(gender)
    if gender == GENDER_TYPE.FEMALE then return CHS[4101380] end    -- 女孩
    if gender == GENDER_TYPE.MALE then return CHS[4101381] end      -- 男孩
end

function KidInfoDlg:updateNameAndShape()
    if not self.selectChild then return end

    if self.selectChild.data.stage <= HomeChildMgr.CHILD_TYPE.STONE then
        -- 胎儿和灵石状态显示未出生
        self:setLabelText("NameLabel", CHS[4010395], "KidShapePanel")

    else
        self:setLabelText("NameLabel", self.selectChild.data.name, "KidShapePanel")
    end

   -- self:setPortrait("KidIconPanel", 7001)
    local shapePanel = self:getControl("KidIconPanel")
    HomeChildMgr:setPortrait(self.selectChild.data.id, shapePanel, self, cc.p(2, -20))

    HomeChildMgr:setChildLogo(self, HomeChildMgr:getKidByCid(self.selectChild.data.id), "KidShapePanel")

    -- 阶段描述
    self:setLabelText("StageLabel", HomeChildMgr:getStageChild(self.selectChild.data), "KidShapePanel")

    -- 是否销毁
    if self.selectChild.data.destroyTime > 0 then
        local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", self.selectChild.data.destroyTime)
        local retStr = string.format( CHS[4101447], timeStr)
        self:setLabelText("Label_0", retStr, "DestroyTipsPanel")
    else
        self:setLabelText("Label_0", "", "DestroyTipsPanel")
    end

    -- 刷新显示与隐藏按钮
    self:updateVisibleBtnStatus()
end

-- 跟随的显示与隐藏按钮
function KidInfoDlg:updateVisibleBtnStatus()
    self:setCtrlVisible("SeeButton", false)
    self:setCtrlVisible("HideButton", false)
    if self.selectChild then
        if self.selectChild.data.stage == HomeChildMgr.CHILD_TYPE.KID and HomeChildMgr:isFollowKidByCid(self.selectChild.data.id) then
            -- 儿童期，跟随状态的孩子
            if HomeChildMgr:isVisibleKidByCid(self.selectChild.data.id) then
                self:setCtrlVisible("HideButton", true)
            else
                self:setCtrlVisible("SeeButton", true)
            end
        end
    end
end

function KidInfoDlg:setTEData()
    local data = self.selectChild.data
    local panel = self:getControl("TEKidInfoPanel")
    -- 成熟度
    local csdPanel = self:getControl("KidProgressPanel", nil, panel)
    self:setProgressBar("ProgressBar", data.mature, 100, csdPanel)
    self:setLabelText("ValueLabel", string.format( "%d/100", data.mature), csdPanel)
    self:setLabelText("ValueLabel2", string.format( "%d/100", data.mature), csdPanel)


    local jkdPanel = self:getControl("HealthyProgressPanel", nil, panel)
    local bar = self:getControl("ProgressBar", nil, jkdPanel)
        bar:loadTexture(ResMgr.ui.progressbar_green)
    if data.health < 80 and data.health >= 40 then
        bar:loadTexture(ResMgr.ui.progressbar43, ccui.TextureResType.plistType)
    elseif data.health < 40 then
        bar:loadTexture(ResMgr.ui.progressbar44, ccui.TextureResType.plistType)
    end
    self:setProgressBar("ProgressBar", data.health, 100, jkdPanel)

    self:setLabelText("ValueLabel", string.format( "%d/100", data.health), jkdPanel)
    self:setLabelText("ValueLabel2", string.format( "%d/100", data.health), jkdPanel)

    -- 亲密
    self:setLabelText("IntimacyNumLabel", data.intimacy, panel)

    -- 日志
    self.startIndex = 1
    self:setPregnancyLog(panel)

    -- 按钮状态显示
    self:setCtrlVisible("FeedButton", data.mature < 100, panel)
    self:setCtrlVisible("MedicineButton", data.mature < 100, panel)
    self:setCtrlVisible("BronButton", data.mature >= 100, panel)
end

function KidInfoDlg:setLSData()
    local data = self.selectChild.data
    local panel = self:getControl("LSKidInfoPanel")
    -- 成熟度
    local csdPanel = self:getControl("KidInfoPanel", nil, panel)
    local bar = self:setProgressBar("ProgressBar", data.mature, 200, csdPanel)
    self:setLabelText("ValueLabel", string.format( "%d/200", data.mature), csdPanel)
    self:setLabelText("ValueLabel2", string.format( "%d/200", data.mature), csdPanel)

    -- 阶段
    self:setLabelText("StageLabel", HomeChildMgr:getStageChsByMature(data.mature), panel)

    -- 亲密
    self:setLabelText("IntimacyNumLabel", data.intimacy, panel)

    -- 日志
    self.startIndex = 1
    self:setPregnancyLog(panel)

    -- 按钮状态显示
    self:setCtrlVisible("FeedButton", data.mature < 200, panel)
    self:setCtrlVisible("BronButton", data.mature >= 200, panel)
end

function KidInfoDlg:updateChildData()
    if not self.selectChild or not self.selectChild.data then
        return
    end

    local data = self.selectChild.data

    self:setCtrlVisible("TEKidInfoPanel", false)
    self:setCtrlVisible("LSKidInfoPanel", false)
    self:setCtrlVisible("YEKidInfoPanel", false)
    self:setCtrlVisible("ETQJWKidInfoPanel", false)
    self:setCtrlVisible("ETQKidInfoPanel", false)

    self:resetListView("ListView", 10, ccui.ListViewGravity.centerHorizontal)
    local diaryPanel = self:setCtrlVisible("MainDiaryPanel", data.stage <= HomeChildMgr.CHILD_TYPE.BABY)


    if data.stage == HomeChildMgr.CHILD_TYPE.FETUS then
        -- 设置胎儿期
        self:setCtrlVisible("TEKidInfoPanel", true)
        self:setTEData()
    elseif data.stage == HomeChildMgr.CHILD_TYPE.STONE then
        -- 设置灵石期
        self:setCtrlVisible("LSKidInfoPanel", true)
        self:setLSData()
    elseif data.stage == HomeChildMgr.CHILD_TYPE.BABY then
        -- 设置婴儿期
        self:setCtrlVisible("YEKidInfoPanel", true)
        self:setYEData()
    elseif data.stage == HomeChildMgr.CHILD_TYPE.KID then
        if self.switchRadioGroup:getSelectedRadioName() == "AttributeCheckBox" then
            -- 设置儿童期属性
            self:setCtrlVisible("ETQKidInfoPanel", true)
            self:setETQData()
        else
            -- 设置儿童期家务
            self:setCtrlVisible("ETQJWKidInfoPanel", true)
            self:setETQJWData()
        end
    end

    if data.stage ~= HomeChildMgr.CHILD_TYPE.KID then
        if self.switchRadioGroup:getSelectedRadioName() == "HouseworkPanelCheckBox" then
            -- 切换到婴儿期的孩子时，若右侧页签选的是家务，需要切换成属性
            self.switchRadioGroup:selectRadio(1)
        end
    end
end

function KidInfoDlg:setYEData()
    local data = self.selectChild.data
    local parentPanel = self:getControl("YEKidInfoPanel")

    local ztPanel = self:getControl("KidInfoPanel", nil, parentPanel)       -- 状态Panel
    HomeChildMgr:setChildZT(data, ztPanel, self)

    ------------------------下面是资质checkBox
    local zzPanel = self:getControl("KidEffectPanel", nil, parentPanel)     -- 资质Panel
    HomeChildMgr:setChildZZ(data, zzPanel, self)

    -- 抚养按钮操作类型
    local takeCareBtn = self:getControl("TakeCareButton", nil, parentPanel)
    if data.stage == HomeChildMgr.CHILD_TYPE.BABY and data.mature >= 1000 then
        -- 婴儿期成长度满了时，显示拜师按钮
        takeCareBtn.type = YE_BUTTON.BAISHI
        self:setLabelText("TextLabel_1", CHS[7100411], takeCareBtn)
        self:setLabelText("TextLabel_2", CHS[7100411], takeCareBtn)
    else
        takeCareBtn.type = YE_BUTTON.FUYANG
        self:setLabelText("TextLabel_1", CHS[7100410], takeCareBtn)
        self:setLabelText("TextLabel_2", CHS[7100410], takeCareBtn)
    end

    -- 成长日志
    self.startIndex = 1
    self:setPregnancyLog(parentPanel)

    -- 成长金库
    self:updateBabyMoney()
end

-- 设置儿童期家务数据
function KidInfoDlg:setETQJWData()
    local data = self.selectChild.data
    local parentPanel = self:getControl("ETQJWKidInfoPanel")

    local function setSingleHomeworkInfo(panel, info)
        local homeworkInfo = HOMEWORK_CFG[info.type]
        if homeworkInfo then
            -- 图标
            self:setImage("IconImage", homeworkInfo.iconPath, panel)

            -- 名字
            self:setLabelText("NameLable", homeworkInfo.name, panel)

            -- 剩余次数名称
            if info.type == HOMEWORK_TYPE_CFG.DIAOYU then
                self:setLabelText("CostNameLable", CHS[7120203], panel)
            elseif info.type == HOMEWORK_TYPE_CFG.BOZHONG then
                self:setLabelText("CostNameLable", CHS[7120204], panel)
            elseif info.type == HOMEWORK_TYPE_CFG.SHOUHUO then
                self:setLabelText("CostNameLable", CHS[7120205], panel)
            end

            -- 剩余次数
            self:setLabelText("CostNumLabel", info.leftTimes, panel)

            -- 操作按钮文字
            self:setLabelText("Label1", homeworkInfo.btnChs, panel)
            self:setLabelText("Label2", homeworkInfo.btnChs, panel)

            -- 操作按钮事件
            self:getControl("DoButton", nil, panel).info = info
            self:bindListener("DoButton", self.onDoHomeworkButton, panel)

            -- 家务描述事件
            self:getControl("InfoButton", nil, panel).type = info.type
            self:bindListener("InfoButton", self.onHomeworkInfoButton, panel)
        end
    end

    -- 家务列表
    local homeworkList = HomeChildMgr:getChildHomeworkList()
    table.sort(homeworkList, function(l, r)
        if l.type < r.type then return true end
        if l.type > r.type then return false end
    end)

    self.homeworkListView:removeAllChildren()
    for i = 1, #homeworkList do
        local itemPanel = self.homeworkPanel:clone()
        setSingleHomeworkInfo(itemPanel, homeworkList[i])
        self.homeworkListView:pushBackCustomItem(itemPanel)
    end

    -- 体力
    local strengthPanel = self:getControl("StrengthPanel", nil, parentPanel)
    self:setLabelText("NumLabel", string.format("%d/100", data.vitality), strengthPanel)

    self:bindListener("PlusButton", self.onAddVitalityButton, strengthPanel)

    -- 成长金库
    self:updateBabyMoney()
end

-- 设置儿童期属性数据
function KidInfoDlg:setETQData()
    local kid = HomeChildMgr:getKidByCid(self.selectChild.data.id)
    if not kid then
        return
    end

    -- 基础属性
    local basicPanel = self:getControl("AttributePanel", nil, "ETQKidInfoPanel")

    --等级
    self:setLabelText("LevelvalueLabel", kid:getLevel(), basicPanel)

    -- 道行
    local taoDesc = gf:getTaoStr(Me:queryInt("tao"), Me:queryInt("tao_ex"))
    self:setLabelText("TaovalueLabel", taoDesc, basicPanel)

    -- 规则说明
    self:bindListener("InfoButton", self.onKidBasicPropInfoButton, basicPanel)
    self:setLabelText("Label1", string.format(CHS[7100430], Const.PLAYER_MAX_LEVEL - 15), "ETQRulePanel1")

    -- 气血, 法力, 物伤，法伤，速度，防御
    self:updatePropsShow(kid)

    local function setTouchEffect(panelName, tips)
        local panel = self:getControl(panelName, Const.UIPanel, basicPanel)
        panel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.began then
                self:setCtrlVisible("TouchImage", true, panel)
            elseif eventType == ccui.TouchEventType.ended then
                self:setCtrlVisible("TouchImage", false, panel)
                if panelName == "TaoPanel" then
                    -- 道行
                    gf:showTipInfo(string.format(CHS[7100445], gf:getTaoStr(Formula:getStdTao(Me:queryInt("level")), 0)), sender)
                else
                    gf:showTipInfo(tips, sender)
                end
            elseif eventType == ccui.TouchEventType.canceled then
                self:setCtrlVisible("TouchImage", false, panel)
            end
        end)
    end

    setTouchEffect("TaoPanel")

    -- 亲密
    self:setLabelText("IntimacyValueLabel", kid:queryInt("intimacy"), basicPanel)
    self:bindListener("IntimacyPanel", self.onOpenIntimacyPanel, basicPanel, true)

    -- 体力
    self:setLabelText("StrengthValueLabel", kid:queryInt("energy"), basicPanel)
    self:bindListener("PlusButton", self.onAddVitalityButton, basicPanel)

    -- 属性分配
    self:refreshAttribPointPlan()

    -- 属性分配按钮
    self:bindListener("SetButton", self.onSetAttribButton, basicPanel)

    -- 跟随按钮事件
    self:bindListener("FollowButton", self.onSetFollowButton, basicPanel)
    if HomeChildMgr:isFollowKidByCid(kid:queryBasic("cid")) then
        self:setLabelText("TextLabel_1", CHS[7100434], "FollowButton")
        self:setLabelText("TextLabel_2", CHS[7100434], "FollowButton")
    else
        self:setLabelText("TextLabel_1", CHS[7100433], "FollowButton")
        self:setLabelText("TextLabel_2", CHS[7100433], "FollowButton")
    end

    -- 资质技能
    local skillPanel = self:getControl("KidInfoPanel", nil, "ETQKidInfoPanel")

    local lifeShape = kid:queryInt("life_shape")
    local manaShape = kid:queryInt("mana_shape")
    local speedShape = kid:queryInt("speed_shape")
    local phyShape = kid:queryInt("phy_shape")
    local magShape = kid:queryInt("mag_shape")
    local allShape = lifeShape + manaShape + speedShape + phyShape + magShape

    -- 总资质
    local allShapePanel = self:getControl("TotalEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", allShape, allShapePanel)

    -- 气血资质
    local lifeShapePanel = self:getControl("LifeEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", lifeShape, lifeShapePanel)

    -- 法力资质
    local manaShapePanel = self:getControl("ManaEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", manaShape, manaShapePanel)

    -- 速度资质
    local speedShapePanel = self:getControl("SpeedEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", speedShape, speedShapePanel)

    -- 物攻资质
    local phyShapePanel = self:getControl("PhyEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", phyShape, phyShapePanel)

    -- 法攻资质
    local magEffectPanel = self:getControl("MagEffectPanel", nil, skillPanel)
    self:setLabelText("NumLabel", magShape, magEffectPanel)

    -- 悟性
    local talentPanel = self:getControl("TalentPanel", nil, skillPanel)
    self:setLabelText("TypeLabel", HomeChildMgr:getWuXinChs(self.selectChild.data.wuxing), talentPanel)

    -- 性格
    local dispositionPanel = self:getControl("DispositionPanel", nil, skillPanel)
    self:setLabelText("TypeLabel", HomeChildMgr:getXinggeChs(self.selectChild.data.xingge), dispositionPanel)

    -- 资质规则按钮
    self:bindListener("InfoButton", self.onKidSkillInfoButton, skillPanel)

    -- 技能按钮
    self:bindListener("CheckPanel", self.onOpenSkillButton, skillPanel)

    -- 技能列表
    self:setKidSkillList(kid)

    -- 培养按钮
    self:bindListener("CultureButton", self.onCultureButton, skillPanel)

    -- 成长金库
    self:updateBabyMoney()
end

-- 刷新技能列表
function KidInfoDlg:setKidSkillList(kid)
    local skillPanel = self:getControl("KidInfoPanel", nil, "ETQKidInfoPanel")
    local skillCfg = HomeChildMgr:getSkillCfgByFamily(kid:queryBasicInt("polar"))
    if skillCfg then
        local function setSkillInfo(panelName, skillNo)
            local panel = self:getControl(panelName, nil, skillPanel)
            self:setImage("SkillImage", SkillMgr:getSkillIconPath(skillNo), panel)
            self:setItemImageSize("SkillImage", panel)

            -- 技能悬浮框
            panel:addTouchEventListener(function(sender, eventType)
                local skill = SkillMgr:getskillAttrib(skillNo)
                if skill then
                    local rect = self:getBoundingBoxInWorldSpace(sender)
                    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
                    local haveSkill = SkillMgr:getSkill(kid:getId(), skillNo)
                    if haveSkill then
                        dlg:setSkillBySKill(haveSkill, SkillMgr:getSkillName(skillNo), 1, false, sender:getBoundingBox())
                    else
                        dlg:setSKillByName(skill.name, rect, nil, HomeChildMgr:getSkillDesc(skill.name))
                    end
                end
            end)

            local skill = SkillMgr:getSkill(kid:getId(), skillNo)
            if skill then
                -- 已拥有显示等级
                gf:resetImageView(self:getControl("SkillImage", nil, panel))
                self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, skill.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
            else
                -- 未拥有置灰图标
                gf:grayImageView(self:getControl("SkillImage", nil, panel))
            end
        end

        -- 物理
        setSkillInfo("SkillPanel1", skillCfg["PhyType"][1])

        -- B3,B4
        setSkillInfo("SkillPanel2", skillCfg["BType"][1])
        setSkillInfo("SkillPanel3", skillCfg["BType"][2])

        -- D3,D4
        setSkillInfo("SkillPanel4", skillCfg["DType"][1])
        setSkillInfo("SkillPanel5", skillCfg["DType"][2])

        -- C3,C4
        setSkillInfo("SkillPanel6", skillCfg["CType"][1])
        setSkillInfo("SkillPanel7", skillCfg["CType"][2])
    end
end

-- 刷新属性点分配
function KidInfoDlg:refreshAttribPointPlan()
    if not self.selectChild then
        return
    end

    local kid = HomeChildMgr:getKidByCid(self.selectChild.data.id)
    local panel = self:getControl("AttributePanel", nil, "ETQKidInfoPanel")

    -- 属性分配
    if kid:getLeftAttribPoint() == 4 then
        self:setLabelText("PointProportionLabel", CHS[7100431], panel)
    else
        local con = kid:queryInt("attrib_assign/con")
        local wiz = kid:queryInt("attrib_assign/wiz")
        local str = kid:queryInt("attrib_assign/str")
        local dex = kid:queryInt("attrib_assign/dex")
        local addPointDes = string.format(CHS[7100432], str, wiz, dex, con)
        self:setLabelText("PointProportionLabel", addPointDes, panel)
    end
end

-- 更新跟随按钮
function KidInfoDlg:updateFollowButton()
    if not self.selectChild then
        return
    end

    -- 跟随按钮
    if HomeChildMgr:isFollowKidByCid(self.selectChild.data.id) then
        self:setLabelText("TextLabel_1", CHS[7100434], "FollowButton")
        self:setLabelText("TextLabel_2", CHS[7100434], "FollowButton")
    else
        self:setLabelText("TextLabel_1", CHS[7100433], "FollowButton")
        self:setLabelText("TextLabel_2", CHS[7100433], "FollowButton")
    end

    -- 跟随图标
    for i = 1, 6 do
        local panel = self:getControl("IconPanel" .. i)
        if panel.data and HomeChildMgr:isFollowKidByCid(panel.data.id) then
            self:setCtrlVisible("FollowImage", true, panel)
        else
            self:setCtrlVisible("FollowImage", false, panel)
        end
    end
end

-- 孩子更新气血等属性显示
function KidInfoDlg:updatePropsShow(kid)
    if kid and self.selectChild and kid:queryBasic("cid") == self.selectChild.data.id then
        -- 基础属性
        local basicPanel = self:getControl("AttributePanel", nil, "ETQKidInfoPanel")

        -- 气血
        local isFightKid = HomeChildMgr:isFollowKidByCid(kid:queryBasic("cid"))
        local curLife = kid:queryInt("life")
        local maxLife = kid:queryInt("max_life")
        local extraLife = Me:queryInt("extra_life")
        if not Me:isInCombat() or not isFightKid then
            if curLife + extraLife >= maxLife then
                curLife = maxLife
            else
                curLife = curLife + extraLife
            end
        end

        if curLife == maxLife then
            self:setLabelText("LifeValueLabel", curLife, basicPanel, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("LifeValueLabel", curLife, basicPanel, COLOR3.RED)
        end
        self:setLabelText("LifeMaxLabel", "/" .. maxLife, basicPanel, COLOR3.TEXT_DEFAULT)

        self:updateLayout("LifePanel")

        -- 法力
        local curMana = kid:queryInt("mana")
        local maxMana = kid:queryInt("max_mana")
        local extraMana = Me:queryInt("extra_mana")
        if not Me:isInCombat() or not isFightKid then
            if curMana + extraMana >= maxMana then
                curMana = maxMana
            else
                curMana = curMana + extraMana
            end
        end

        if curMana == maxMana then
            self:setLabelText("MagicValueLabel", curMana, basicPanel, COLOR3.TEXT_DEFAULT)
        else
            self:setLabelText("MagicValueLabel", curMana, basicPanel, COLOR3.RED)
        end
        self:setLabelText("MagicMaxLabel", "/" .. maxMana, basicPanel, COLOR3.TEXT_DEFAULT)

        self:updateLayout("MagicPanel")

        local function setColorProp(labelName, propName)
            local propValue = kid:queryInt(propName)
            local basicPropValue = kid:queryBasicInt(propName)
            if propValue ~= basicPropValue then
                self:setLabelText(labelName, propValue, basicPanel, COLOR3.BLUE)
            else
                self:setLabelText(labelName, propValue, basicPanel, COLOR3.TEXT_DEFAULT)
            end
        end

        setColorProp("PhyPowerValueLabel", "phy_power")
        setColorProp("MagPowerValueLabel", "mag_power")
        setColorProp("SpeedValueLabel", "speed")
        setColorProp("DefenceValueLabel", "def")
    end
end

-- 孩子打开培养界面
function KidInfoDlg:onCultureButton(sender, eventType)
    --
    if not self.selectChild then return end
    local magic = sender:getChildByName(ResMgr.ArmatureMagic.magic02074.name)
    if magic then
        magic:removeFromParent()
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_OPEN_CHILD_DLG_BY_TOY)
    end
    gf:CmdToServer("CMD_CHILD_REQUEST_CULTIVATE_INFO", {child_id = self.selectChild.data.id})
end

-- 孩子打开技能界面
function KidInfoDlg:onOpenSkillButton(sender, eventType)
    DlgMgr:openDlgEx("ChildSkillDlg", self.selectChild.data.id)
end

-- 孩子跟随按钮事件
function KidInfoDlg:onSetFollowButton(sender, eventType)
    if not self.selectChild then
        return
    end

    if HomeChildMgr:isFollowKidByCid(self.selectChild.data.id) then
        gf:CmdToServer("CMD_CHILD_FOLLOW_ME", { cid = self.selectChild.data.id, flag = 0 })
    else
        gf:CmdToServer("CMD_CHILD_FOLLOW_ME", { cid = self.selectChild.data.id, flag = 1 })
    end
end

-- 孩子打开亲密度详情界面
function KidInfoDlg:onOpenIntimacyPanel(sender, eventType)
    if self.selectChild then
        if eventType == ccui.TouchEventType.began then
            self:setCtrlVisible("TouchImage", true, sender)
        elseif eventType == ccui.TouchEventType.ended then
            self:setCtrlVisible("TouchImage", false, sender)

            local kid = HomeChildMgr:getKidByCid(self.selectChild.data.id)
            DlgMgr:openDlgEx("ChildIntimacyInfoDlg", kid:queryInt("intimacy"))
        elseif eventType == ccui.TouchEventType.canceled then
            self:setCtrlVisible("TouchImage", false, sender)
        end
    end
end

-- 孩子基础属性分配按钮
function KidInfoDlg:onSetAttribButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_PRE_ASSIGN_ATTRIB", { cid = self.selectChild.data.id, plan = "" })
end

-- 孩子基础属性规则
function KidInfoDlg:onKidBasicPropInfoButton(sender, eventType)
    self:setCtrlVisible("ETQRulePanel1", true)
end

-- 孩子技能属性规则
function KidInfoDlg:onKidSkillInfoButton(sender, eventType)
    self:setCtrlVisible("ETQRulePanel2", true)
end

-- 切换属性菜单
function KidInfoDlg:onSwitchKidCheckBox(sender, eventType)
    if sender:getName() == "CheckBox_1" then
        self:setCtrlVisible("AttributePanel", true, "ETQKidInfoPanel")
        self:setCtrlVisible("KidInfoPanel", false, "ETQKidInfoPanel")
    else
        self:setCtrlVisible("AttributePanel", false, "ETQKidInfoPanel")
        self:setCtrlVisible("KidInfoPanel", true, "ETQKidInfoPanel")
    end
end

function KidInfoDlg:onSeeOrHideButton(sender, eventType)
    if not self.selectChild then
        return
    end

    if HomeChildMgr:isVisibleKidByCid(self.selectChild.data.id) then
        gf:CmdToServer("CMD_CHILD_VISIBLE", { cid = self.selectChild.data.id, flag = 0 })
    else
        gf:CmdToServer("CMD_CHILD_VISIBLE", { cid = self.selectChild.data.id, flag = 1 })
    end
end

function KidInfoDlg:onDoHomeworkButton(sender, eventType)
    local info = sender.info
    if info and HOMEWORK_CFG[info.type] and self.selectChild then
        gf:CmdToServer("CMD_CHILD_HOUSEWORK", {id = self.selectChild.data.id, type = info.type})
    end
end

function KidInfoDlg:onHomeworkInfoButton(sender, eventType)
    local type = sender.type
    if HOMEWORK_CFG[type] then
        gf:showTipInfo(HOMEWORK_CFG[type].desc, sender)
    end
end

function KidInfoDlg:onAddVitalityButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selectChild then
        return
    end

    if self:checkSafeLockRelease("onAddVitalityButton") then
        return
    end

    gf:CmdToServer("CMD_CHILD_SUPPLY_ENERGY", {id = self.selectChild.data.id})
end

function KidInfoDlg:updateBabyMoney()
    local money = self.selectChild.data.money
    local cash, color = gf:getArtFontMoneyDesc(money)
    local gender = self.selectChild.data.gender
    local rootPanelList = {"YEKidInfoPanel", "ETQJWKidInfoPanel", "ETQKidInfoPanel"}
    for i = 1, #rootPanelList do
        local rootPanel = self:getControl("ChildMoneyPanel", nil, rootPanelList[i])
        self:setNumImgForPanel("MoneyValuePanel", color, cash, false, LOCATE_POSITION.MID, 23, rootPanel)
        self:setLabelText("InfoLabel", gender == GENDER_TYPE.MALE and CHS[4101362] or CHS[4101363], rootPanel)
    end
end

function KidInfoDlg:updateMoney(data)
    if data.id == self.selectChild.data.id then
        self.selectChild.data.money = data.money
        self:updateBabyMoney()
    end
end

-- 设置进度条
function KidInfoDlg:setProgressBarForSelf(name, cur, max, root)
    local bar = self:setProgressBar(name, cur, max, root)
    self:setLabelText("ValueLabel", string.format( "%d/%d", cur, max), root)
    self:setLabelText("ValueLabel2", string.format( "%d/%d", cur, max), root)

    self:setLabelText("ProgressLabel_1", string.format( "%d/%d", cur, max), root)
    self:setLabelText("ProgressLabel_2", string.format( "%d/%d", cur, max), root)
end

-- 设置日志
function KidInfoDlg:setPregnancyLog(parentPanel)
    if not self.selectChild then return end

    local id = self.selectChild.data.id
    local data = HomeChildMgr:getPregnancyLogById(id)

    local list = self:resetListView("ListView", 10, ccui.ListViewGravity.centerHorizontal)--, parentPanel)
    local count = math.min( PAGE_MAX_COUNT, #data)
    for i = 1, count do
        local panel = self.unitLogPanel:clone()
        local color = i == 1 and COLOR3.GREEN or nil
        self:setColorText(data[i], panel, nil, 0, 0, color, 17)
        list:pushBackCustomItem(panel)
        self.startIndex = self.startIndex + 1
    end
end

-- 滚动加载时进入的日志
function KidInfoDlg:pushPregnancyLog(parentPanel)
    if not self.selectChild then return end

    local id = self.selectChild.data.id
    local data = HomeChildMgr:getPregnancyLogById(id)

    local list = self:getControl("ListView")--, parentPanel)
    local count = math.min( self.startIndex + PAGE_MAX_COUNT - 1, #data)
    local addCount = 0
    for i = self.startIndex, count do
        local panel = self.unitLogPanel:clone()
        local color = i == 1 and COLOR3.GREEN or nil
        self:setColorText(data[i], panel, nil, 0, 0, color, 17)
        list:pushBackCustomItem(panel)
        addCount = addCount + 1
    end

    self.startIndex = self.startIndex + addCount
end



function KidInfoDlg:setKidList(srcData, isRefresh)
    local data = HomeChildMgr:getChildByOrder()
    self.childData = data

    for i = 1, 6 do
        local panel = self:getControl("IconPanel" .. i)

        self:setCtrlVisible("FollowImage", false, panel)
        self:setCtrlVisible("DestroyImage", false, panel)
        self:setCtrlEnabled("GuardImage", true, panel)
        self:setCtrlEnabled("LvPanel", false, panel)

        panel.data = data[i]
        if data[i] then
            self:setImage("GuardImage", HomeChildMgr:getChildSmallPortraitById(data[i].id), panel)
            self:setImageSize("GuardImage", {width = 64, height = 64}, panel)

            local healthStr = HomeChildMgr:getHealthChs(data[i].healthStage)

            if data[i].isSleep == 1 then
                healthStr = healthStr ~= "" and (healthStr .. " " .. CHS[4101322]) or CHS[4101322]
            end

            if healthStr == "" then
                self:setCtrlVisible("LevelPanel", false, panel)
            else
                self:setCtrlVisible("LevelPanel", true, panel)
                self:setLabelText("ChildStageLabel", healthStr, panel)
            end

            if data[i].destroyTime > 0 then
                self:setCtrlVisible("DestroyImage", true, panel)
                self:setCtrlEnabled("GuardImage", false, panel)
            end

            self:setCtrlVisible("FollowImage", false, panel)
            if data[i].stage == HomeChildMgr.CHILD_TYPE.KID then
                -- -- 儿童期的孩子显示等级
                -- local kid = HomeChildMgr:getKidByCid(data[i].id)
                -- self:setCtrlEnabled("LvPanel", true, panel)
                -- self:setNumImgForPanel("LvPanel", ART_FONT_COLOR.NORMAL_TEXT, kid:getLevel(),
                --     false, LOCATE_POSITION.LEFT_TOP, 21, panel)

                -- 跟随图标
                if HomeChildMgr:isFollowKidByCid(data[i].id) then
                    self:setCtrlVisible("FollowImage", true, panel)
                end
            end

            if not self.lastSelectTag or self.lastSelectTag == data[i].id then
                self:onClickChild(panel, nil, true)
            end

        else
            self:setImagePlist("GuardImage", ResMgr.ui.bag_no_item_bg_img, panel)
            self:setImageSize("GuardImage", {width = 74, height = 74}, panel)

            self:setCtrlVisible("LevelPanel", false, panel)
        end


    end

    if srcData and srcData.selectId ~= "" then
        for i = 1, 6 do
            local panel = self:getControl("IconPanel" .. i)

            if panel.data and panel.data.id == srcData.selectId then
                self:onClickChild(panel, nil, true, isRefresh)
            end
        end
    end

    if not self.selectChild then
        self:onClickChild(self:getControl("IconPanel1"), nil, true, isRefresh)
    end

    if isRefresh then
        self:onClickChild(self.selectChild, nil, true, isRefresh)
    end
end


function KidInfoDlg:onBagButton(sender, eventType)
    self:setCtrlVisible("BagPanel", true)
end


function KidInfoDlg:onUnMissionButton(sender, eventType)

    self:setCtrlVisible("NoMissionPanel", true)
end


function KidInfoDlg:onCloseNoMissionButton(sender, eventType)

    self:setCtrlVisible("NoMissionPanel", false)
end

function KidInfoDlg:onMissionButton(sender, eventType)

    self:setCtrlVisible("MissionPanel", true)
end

function KidInfoDlg:onDailyGetButton(sender, eventType)
    if not self.selectChild then return end
    gf:CmdToServer("CMD_CHILD_FETCH_TASK", {id = self.selectChild.data.id, task_name = self.selectChild.data.task_name})
end

function KidInfoDlg:onDailyGoButton(sender, eventType)

    if self.selectChild.data.task_name == CHS[4101497] then
        local task = TaskMgr:getTaskByName(self.selectChild.data.task_name)
        if task then
            local task_prompt = task.task_prompt
            if task_prompt then
                AutoWalkMgr:beginAutoWalk(gf:findDest(task_prompt))
                self:onCloseButton()
                return
            end
        end
    end

    local task = TaskMgr:getTaskByName(self.selectChild.data.task_name)
    if task then
        AutoWalkMgr:stopAutoWalk()
        gf:CmdToServer('CMD_CHILD_CLICK_TASK_LOG', { task_name = task.show_name })
        self:onCloseButton()
    end
end


function KidInfoDlg:onGrowButton(sender, eventType)

end

function KidInfoDlg:onBronButton(sender, eventType)
    if not self.selectChild then return end
    gf:CmdToServer("CMD_CHILD_BIRTH", {id = self.selectChild.data.id})
 --   self:onCloseButton()
end

function KidInfoDlg:onTERulePanel(sender, eventType)
    self:setCtrlVisible("TERulePanel", true)
end

function KidInfoDlg:onLSRulePanel(sender, eventType)
    self:setCtrlVisible("LSRulePanel", true)
end

function KidInfoDlg:onYERulePanel(sender, eventType)
    self:setCtrlVisible("YERulePanel", true)
end

function KidInfoDlg:onTakeCareButton(sender, eventType)
    if not self.selectChild or not self.selectChild.data then return end

    if self.selectChild.data.stage == HomeChildMgr.CHILD_TYPE.BABY and self.selectChild.data.mature >= 1000 then
        -- 婴儿期的娃娃满成长度了，走拜师流程
        gf:CmdToServer("CMD_CHILD_JOIN_FAMILY", {id = self.selectChild.data.id, type = 0})
    else
        if self.selectChild.data.destroyTime > 0 then
            gf:ShowSmallTips(CHS[4101448])
            return
        end

        gf:CmdToServer("CMD_CHILD_REQUEST_RAISE_INFO", {child_id = self.selectChild.data.id, type = 0})
     --   self:onCloseButton()
    end
end

function KidInfoDlg:onMoneyButton(sender, eventType)
    if not self.selectChild then return end
    if self.selectChild.data.destroyTime > 0 then
        gf:ShowSmallTips(CHS[4101448])
        return
    end
    DlgMgr:openDlgEx("ChildStoreMoneyDlg", self.selectChild.data)
end


function KidInfoDlg:onRenameButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not self.selectChild then
        return
    end

    if self.selectChild.data.stage <= HomeChildMgr.CHILD_TYPE.STONE then
        gf:ShowSmallTips(CHS[4010396])
        return
    end

    if self.selectChild.data.destroyTime > 0 then
        gf:ShowSmallTips(CHS[4101448])
        return
    end

    DlgMgr:openDlgEx("RenameKidDlg", self.selectChild.data)
end

function KidInfoDlg:onFeed1Button(sender, eventType)
    local dlg = BlogMgr:showButtonList(self, sender, "taier1")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local x = dlg.root:getPositionX() + rect.width * 0.5 + dlg.root:getContentSize().width * 0.5
    dlg.root:setPositionX(x)
end

function KidInfoDlg:onMedicineButton(sender, eventType)
    if not self.selectChild then return end
    gf:CmdToServer("CMD_CHILD_CARE", {id = self.selectChild.data.id, type = 4})
   -- self:onCloseButton()
end

function KidInfoDlg:onFeed2Button(sender, eventType)
    if not self.selectChild then return end
    gf:CmdToServer("CMD_CHILD_CARE", {id = self.selectChild.data.id, type = 5})
  --  self:onCloseButton()
end

function KidInfoDlg:onKidInfoDlgCare(text)
    if not self.selectChild then return end
    gf:CmdToServer("CMD_CHILD_CARE", {id = self.selectChild.data.id, type = CARE_TYPE[text]})
  --  self:onCloseButton()
end

function KidInfoDlg:MSG_CHILD_INFO(data)
    if self.childData and #self.childData > 0 and #self.childData ~= data.count then
        -- 娃娃数量有变化，关闭本界面
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 设置胎儿列表，强制刷新
    self:setKidList(nil, true)

    local hasBaby = false

    for i = 1, data.count do
        local id = data.childInfo[i].id
        if data.childInfo[i].stage == HomeChildMgr.CHILD_TYPE.KID then
            hasBaby = true
        end
    end

    if not hasBaby and HomeChildMgr.kidInfoDlgTips then
        gf:ShowSmallTips(HomeChildMgr.kidInfoDlgTips)
    end
    HomeChildMgr:setKidInfoDlgOpenTips()
end

function KidInfoDlg:MSG_CHILD_JOIN_FAMILY(data)
    local dlg = DlgMgr:getDlgByName("KidApprenticeDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("KidApprenticeDlg")
    end

    dlg:setData(HomeChildMgr:getChildenInfoById(data.id))
end

function KidInfoDlg:MSG_SET_COMBAT_CHILD(data)
    self:updateVisibleBtnStatus()
end

function KidInfoDlg:MSG_SET_VISIBLE_CHILD(data)
    self:updateVisibleBtnStatus()
end

function KidInfoDlg:MSG_UPDATE_CHILDS(data)
    if not self.selectChild or not self.selectChild.data then return end

    for i = 1, data.count do
        if data[i].stage == HomeChildMgr.CHILD_TYPE.KID and data[i].cid == self.selectChild.data.id then
            self:setETQData()
        end
    end
end

function KidInfoDlg:MSG_UPDATE_SKILLS(data)
    if self.selectChild then
        local kid = HomeChildMgr:getKidByCid(self.selectChild.data.id)
        if kid and kid:getId() == data.id then
            self:setKidSkillList(kid)
        end
    end
end

function KidInfoDlg:MSG_COUPLE_INFO(data)
    -- 结婚状态发生变化，则关闭娃娃界面
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("ChildSkillDlg")
end

function KidInfoDlg:MSG_CHILD_CULTIVATE_INFO(data)

    if self.selectChild then
        local childData = HomeChildMgr:getChildenInfoById(data.id)
        if childData then
            self.selectChild.data = childData
            self:onClickChild(self.selectChild, nil, true, true)
        end
    end
end


return KidInfoDlg
