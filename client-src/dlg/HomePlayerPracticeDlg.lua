-- HomePlayerPracticeDlg.lua
-- Created by songcw July/19/2017
-- 居所-人物修炼界面

local HomePlayerPracticeDlg = Singleton("HomePlayerPracticeDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_CHECKBOS = {
    "PracticePanelCheckBox",        -- 修炼
    "HelpPanelCheckBox",            -- 协助
}

local DISPLAY_PANEL = {
    ["PracticePanelCheckBox"]     = "PracticePanel",
    ["HelpPanelCheckBox"]         = "HelpPanel",
}

local PRACTICE_TYPR =
{
    PRACTICE_STATUS_NONE          = 0,    -- 入阵前
    PRACTICE_STATUS_RUNNING           = 2,    -- 修炼中
    PRACTICE_STATUS_SELECT           = 1,    -- 入阵后
}

local MAGIC_DIS = 188

local TIME_MAGIN = 20           -- 如果发生异常，请求的事件间隔

local MAGIC_MAP = {
    [CHS[4200425]] = "Top01",   -- 入阵
    [CHS[4200426]] = "Top03",   -- 出阵
    [CHS[4200427]] = "Top02",   -- 在阵中
    [CHS[4200428]] = {                  -- "心魔"
        [1] =  "Top04",     -- 金系
        [2] =  "Top05",     -- 木系
        [3] =  "Top06",     -- 水系
        [4] =  "Top07",     -- 火系
        [5] =  "Top08",     -- tu系
    },
    [CHS[4200429]] = {              -- 修炼中
        [1] =  "Top09",     -- 金系
        [2] =  "Top10",     -- 木系
        [3] =  "Top11",     -- 水系
        [4] =  "Top12",     -- 火系
        [5] =  "Top13",     -- tu系
    },
    [CHS[4200430]] = {
        [1] =  "Bottom01",     -- 金系
        [2] =  "Bottom02",     -- 木系
        [3] =  "Bottom03",     -- 水系
        [4] =  "Bottom04",     -- 火系
        [5] =  "Bottom05",     -- tu系
    },
}

function HomePlayerPracticeDlg:init(data)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("InButton", self.onInButton)
    self:bindListener("OutButton", self.onOutButton)
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("AddButton", self.onAddCleanButton, "CleanPanel")
    self:bindListener("AddButton", self.onAddNaijiuButton, "DurabilityPanel")
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("HelpButton", self.onHelpButton)

    -- 由于资源问题，不能用checkBox
    self:bindListener("FriendButton_1", self.onFriendButton_1)
    self:bindListener("FriendButton_2", self.onFriendButton_2)
    self:bindListener("HistoryButton_1", self.onHistoryButton_1)
    self:bindListener("HistoryButton_2", self.onHistoryButton_2)

    self:bindListener("RefreshButton", self.onRefreshButton, "FriendlistPanel")

    -- 好友列表的list项
    self.friendPanel = self:toCloneCtrl("SingleFriendPanel")
    self:bindTouchEndEventListener(self.friendPanel, self.onChosenFriendPanel)
    self.friendSelectImage = self:toCloneCtrl("BChosenEffectImage", self.friendPanel)

    -- 历史列表的list项
    self.historyPanel = self:toCloneCtrl("SingleHistoryPanel")
    self:bindTouchEndEventListener(self.historyPanel, self.onChosenHistoryPanel)
    self.historySelectImage = self:toCloneCtrl("BChosenEffectImage", self.historyPanel)

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) and data then
        self.furnitureId = data.furnitureId
        self.furnitureX, self.furnitureY = data.pX, data.pY
    end

    self.getBtnPos = self.getBtnPos or self:getControl("GetButton"):getPosition()
    self.data = nil
    self.display = nil
    self.helpData = nil
    self.forOnceTag = TIME_MAGIN

    -- 无数据时请求，有数据时只有点击刷新按钮才请求数据
    self.friendData = HomeMgr.practiceHelpTargets
    self.isRefreshData = false
    self.hasRequestFriendData = nil

    -- 右侧tab
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, DISPLAY_CHECKBOS, self.onCheckBox)
    self.radioGroup:setSetlctByName(DISPLAY_CHECKBOS[1])

    self:hookMsg("MSG_PLAYER_PRACTICE_XINMO_UPDATED")
    self:hookMsg("MSG_PLAYER_PRACTICE_FRIEND_DATA")
    self:hookMsg("MSG_PLAYER_PRACTICE_HELP_TARGETS")
    self:hookMsg("MSG_PLAYER_PRACTICE_HELP_ME_RECORDS")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")    -- 用于更新耐久
    self:hookMsg("MSG_FRIEND_UPDATE_PARTIAL")    -- 用于更新好友度
    self:hookMsg("MSG_HOUSE_DATA")
end

function HomePlayerPracticeDlg:cleanup()
    self:releaseCloneCtrl("friendPanel")
    self:releaseCloneCtrl("historyPanel")

    self:releaseCloneCtrl("friendSelectImage")
    self:releaseCloneCtrl("historySelectImage")

    -- 关闭该界面时，同时关闭各个子界面
    DlgMgr:closeDlg("HomePracticeRuleDlg")
end

-- 设置好友列表
function HomePlayerPracticeDlg:setHelpedList(data)
    local panel = self:getControl("HistorylistPanel")
    local list = self:resetListView("HistoryListView")
    if not data or not next(data) then
        self:setCtrlVisible("NoticePanel", true, panel)
        self:setCtrlVisible("NoticePanel1", false)
        self:setCtrlVisible("NoticePanel2", false)
        self:setCtrlVisible("FurniturePanel", false, "HelpPanel")
        self:setCtrlVisible("HelpButton", false, "HelpPanel")
        return
    end
    self:setCtrlVisible("NoticePanel", false, panel)

    for i = 1, #data do
        local unitPanel = self.historyPanel:clone()
        self:setUnitRecordPanel(data[i], unitPanel, i)
        list:pushBackCustomItem(unitPanel)

        if i == 1 then
            self:onChosenHistoryPanel(unitPanel)
        end
    end
end

-- 设置单个协助记录
function HomePlayerPracticeDlg:setUnitRecordPanel(data, panel, i)
    panel.data = data
    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)

    -- 姓名
    self:setLabelText("NamePatyLabel", data.name, panel)

    -- 友好度
    self:setLabelText("InfoLabel",string.format( CHS[4100701], data.clear_xinmo), panel)

    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 是否互助
    self:setCtrlVisible("HelpImage", data.flag == 1, panel)

    -- 时间
    self:setLabelText("TimeLabel", self:getTimeStr(data.op_time), panel)

    self:setCtrlVisible("BackImage_2", i % 2 == 0, panel)
end

function HomePlayerPracticeDlg:getTimeStr(opTime)
    local overTime = gf:getServerTime() - opTime
    if overTime > 3600 then
        return string.format(CHS[4100775], math.floor(overTime / 3600))  -- "%d小时前"
    else
        return string.format(CHS[4100700], math.ceil(overTime / 60))
    end
end

-- 设置单个好友
function HomePlayerPracticeDlg:setUnitFriendPanel(data, panel)
    panel.data = data
    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), panel)


    self:setCtrlEnabled("PortraitImage", data.isOnline == 1, panel)

    -- 姓名
    -- isVip
    local color = COLOR3.CHAR_VIP_BLUE
    if data.isOnline == 1 then
        if data.isVip >= 1 then
            color = COLOR3.CHAR_VIP_BLUE_EX
        else
            color = COLOR3.GREEN
        end
    else
        color = COLOR3.TEXT_DEFAULT
    end
    self:setLabelText("NamePatyLabel", data.name, panel, color)

    -- 友好度
    self:setLabelText("FriendlyDegreeLabel",string.format(  CHS[4100690], data.friend), panel)

    -- 等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    -- 是否已经协助过
    self:setCtrlVisible("HelpImage_1", data.flag == 0, panel)
    self:setCtrlVisible("HelpImage_2", data.flag == 1, panel)
end

-- 设置好友列表
function HomePlayerPracticeDlg:setFriendList(data)
    local panel = self:getControl("FriendlistPanel")
    local list = self:resetListView("FriendListView", 3)
    if not data or not next(data) then
        self:setCtrlVisible("NoticePanel", true, panel)
        self:setCtrlVisible("NoticePanel1", false)
        self:setCtrlVisible("NoticePanel2", false)
        self:setCtrlVisible("FurniturePanel", false, "HelpPanel")
        self:setCtrlVisible("HelpButton", false, "HelpPanel")
        return
    end
    self:setCtrlVisible("NoticePanel", false, panel)

    for i = 1, #data do
        local unitPanel = self.friendPanel:clone()
        self:setUnitFriendPanel(data[i], unitPanel)
        list:pushBackCustomItem(unitPanel)

        if i == 1 then
            self:onChosenFriendPanel(unitPanel)
        end
    end
end

function HomePlayerPracticeDlg:onUpdate()
    if not self.data then return end
    -- local fur = HomeMgr:getFurnitureById(self.data.furniture_pos)
    -- if not fur then return end

    if self.data.status == PRACTICE_TYPR.PRACTICE_STATUS_RUNNING then
        if self:isRestTime() then
            self:setLabelText("NextTimeLabel", CHS[4200416])
            return
        end

        if gf:getServerTime() > self.data.next_bonus_time then
            -- 当前产出奖励时间结束了
            if self.forOnceTag >= TIME_MAGIN then       -- TIME_MAGIN 时间间隔，防止频繁刷新
                local fur = HomeMgr:getFurnitureById(self.data.furniture_pos)

                if fur and HomeMgr:getHouseId() == Me:queryBasic("house/id") then
                    -- 如果能根据pos找到，并且是我的居所
                    HomeMgr:queryHourPlayerPractice("use", fur:queryBasicInt("id"))
                else
                    HomeMgr:queryHourPlayerPractice("my_data", self.data.furniture_pos)
                end

                self.forOnceTag = 0
                self:setLabelText("NextTimeLabel", "")
            else
                self.forOnceTag = self.forOnceTag + 1
            end
        else
            self.forOnceTag = TIME_MAGIN

            -- 预计产出奖励时间
            local disTime = math.max(0, self.data.next_bonus_time - gf:getServerTime())
            -- 如果大于28800则中间有静心时间，需要减掉 8 * 60 * 60 = 28800
            if disTime > 28800 then
                disTime = disTime - 28800
            end
            disTime = math.min(disTime, 60 * 10)
            local min = math.floor(disTime / 60)
            local s = disTime % 60
            self:setLabelText("NextTimeLabel", string.format(CHS[4100691], min, s))
        end
    end
end

-- 设置点击好友右侧信息
function HomePlayerPracticeDlg:setFriendRightInfo(data)
    local panelTotal = self:getControl("HelpPanel")
    local panelRight = self:getControl("FurniturePanel", nil, panelTotal)

    local magicPanel = self:getControl("Panel01", nil, panelTotal)
    local backPanel = self:getControl("Panel02", nil, panelTotal)
    local polar = data.polar
    if data.status == PRACTICE_TYPR.PRACTICE_STATUS_RUNNING then
        -- 不同Gid则删除
        if not panelTotal.data or panelTotal.data.gid ~= data.gid then
            magicPanel:removeAllChildren()
        end

        -- 有在阵中的光效，要删除
        if magicPanel:getChildByName(MAGIC_MAP[CHS[4200427]]) then
            magicPanel:removeAllChildren()
        end

        -- 修炼中
        if not magicPanel:getChildByName(MAGIC_MAP[CHS[4200429]][polar]) then
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200429]][polar], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 3)
        end

        backPanel:removeAllChildren()
        local qi = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200430]][polar], backPanel, nil, nil, nil, nil, backPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 3)
        qi:setScale((100 - data.xinmo) * 0.01)
    elseif data.status == PRACTICE_TYPR.PRACTICE_STATUS_SELECT then
        magicPanel:removeAllChildren()
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200427]], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 3)

        backPanel:removeAllChildren()
    else
        backPanel:removeAllChildren()
        magicPanel:removeAllChildren()
    end

    self:setCtrlVisible("FurnitureImage_1", data.furniture_id == HomeMgr:getFurnitureIcon(CHS[4100681]), panelRight)
    self:setCtrlVisible("FurnitureImage_2", data.furniture_id == HomeMgr:getFurnitureIcon(CHS[4100682]), panelRight)


    panelTotal.data = data
    panelRight:setVisible(data.status ~= PRACTICE_TYPR.PRACTICE_STATUS_NONE)
    self:setCtrlVisible("HelpButton", data.status ~= PRACTICE_TYPR.PRACTICE_STATUS_NONE, panelTotal)
    self:setCtrlVisible("NoticePanel1", data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE, panelTotal)
--    self:setCtrlVisible("BKImage", data.status ~= PRACTICE_TYPR.PRACTICE_STATUS_NONE, panelTotal)
    self:setCtrlVisible("BKImage", true, panelTotal)
    self:setCtrlVisible("NoticePanel2", false)

    self:setLabelText("NameLabel", self.selectChar.name, panelRight)

    -- 维持时间
    local timeStr = string.format(CHS[4200415], math.ceil(data.furniture_durability / 2) * 10)
    self:setLabelText("HoldTimeNumLabel", timeStr, panelRight)

    self:setLabelText("EvilNumLabel", string.format(CHS[4200433], data.xinmo), panelRight)
end

-- 点击好友列表
function HomePlayerPracticeDlg:onChosenFriendPanel(sender, eventType)
    self.friendSelectImage:removeFromParent()
    sender:addChild(self.friendSelectImage)

    self.selectChar = sender.data

    -- 请求好友列表
    HomeMgr:queryHourPlayerPractice("friend_data", sender.data.gid)
end

-- 点击历史列表
function HomePlayerPracticeDlg:onChosenHistoryPanel(sender, eventType)
    self.historySelectImage:removeFromParent()
    sender:addChild(self.historySelectImage)

    self.selectChar = sender.data

    -- 请求好友列表
    HomeMgr:queryHourPlayerPractice("friend_data", sender.data.gid)
end

-- 修炼 、协助 checkBox
function HomePlayerPracticeDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panelName, false)
    end

    self:setCtrlVisible(DISPLAY_PANEL[sender:getName()], true)

    -- 请求好友列表
    if not self.display then
        self:onFriendButton_1()
    end
end

-- 修炼界面，右侧居所信息
function HomePlayerPracticeDlg:setHomeInfo(data)
    local myData = HomeMgr:getMyHomeData()

    -- 房屋修炼空间等级
    self:setLabelText("ValueLabel", HomeMgr:getLevelStr(data.xiuls_level), "SpacePanel")

    -- 居所舒适度
    self:setLabelText("ValueLabel", string.format("%d/%d", myData.comfort, HomeMgr:getMaxComfort()), "SuitPanel")

    -- 居所清洁度
    local color = COLOR3.TEXT_DEFAULT
    if data.cleanliness <= 20 then
        color = COLOR3.RED
    end
    self:setLabelText("ValueLabel", string.format("%d/%d", data.cleanliness, HomeMgr:getMaxClean()), "CleanPanel", color)

    -- 家具耐久度
    self:setLabelText("ValueLabel", string.format("%d/%d", data.furniture_durability, HomeMgr:getMaxDur(data.name)), "DurabilityPanel")


    local colorXinmo = COLOR3.TEXT_DEFAULT
    if data.xinmo >= 20 then
        colorXinmo = COLOR3.RED
    end
    if data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE then
        -- 修炼效率
        self:setLabelText("ValueLabel", CHS[4100692], "BornPanel")

        -- 角色真身等级
        self:setLabelText("ValueLabel", CHS[4100692], "LevelPanel")

        -- 心魔干扰度
        self:setLabelText("ValueLabel", CHS[4100692], "EvilPanel", COLOR3.TEXT_DEFAULT)
    else
        -- 修炼效率
        local color = COLOR3.TEXT_DEFAULT
        if data.rate > 0 then
            color = COLOR3.BLUE
        end

        self:setLabelText("ValueLabel", string.format(CHS[4100693], gf:getTaoStr(data.bonus_tao, 0)), "BornPanel", color)

        -- 角色真身等级
        self:setLabelText("ValueLabel", string.format(CHS[6000179], Me:queryInt("level")), "LevelPanel")

        -- 心魔干扰度
        self:setLabelText("ValueLabel", string.format("%d%%", data.xinmo), "EvilPanel", colorXinmo)
    end

    -- 积累奖励
    if data.total_bonus_tao ~= 0 then
        self:setLabelText("ValueLabel", gf:getTaoStr(data.total_bonus_tao, 0) .. CHS[4100702], "StoragePanel")
    else
        self:setLabelText("ValueLabel", "0 " .. CHS[4100702], "StoragePanel")
    end
end

-- 设置 入阵前 界面
function HomePlayerPracticeDlg:setPraticeData(data)
    self.data = data
    local parentPanel = self:getControl("PracticePanel")

    -- 右侧信息
    self:setHomeInfo(data)

    -- 家具名称
    self:setLabelText("FurnitureNameLabel", data.name, parentPanel)


    -- 维持时间
    local timeStr = string.format(CHS[4200415], math.ceil(data.furniture_durability / 2) * 10)
    self:setLabelText("HoldTimeTextLabel", timeStr, parentPanel)

    -- 家具图
    self:setCtrlVisible("FurnitureImage_1", false, parentPanel)
    self:setCtrlVisible("FurnitureImage_2", false, parentPanel)
    if data.name == CHS[4100681] then
        -- 阴阳修炼阵
        self:setCtrlVisible("FurnitureImage_1", true, parentPanel)
    elseif data.name == CHS[4100682] then
        -- 八卦太极阵
        self:setCtrlVisible("FurnitureImage_2", true, parentPanel)
    end

    -- 如果没有可领取的奖励，需要置灰
    if data.total_bonus_tao ~= 0 then
        self:setCtrlEnabled("GetButton", true)
    else
        self:setCtrlEnabled("GetButton", false)
    end

    -- 预计产出奖励时间
    local disTime = math.max(0, data.next_bonus_time - gf:getServerTime())
    local min = math.floor(disTime / 60)
    local s = disTime % 60
    self:setLabelText("NextTimeLabel", string.format(CHS[4100689], min, s))

    -- 按钮显示
    self:setDisplayByType(data)

    -- 光效
    self:setMagic(data)
end

function HomePlayerPracticeDlg:isRestTime()
    local h = tonumber(gf:getServerDate("%H", gf:getServerTime()))

    if h >= 0 and h < 8 then
        return true
    end

    return false
end

function HomePlayerPracticeDlg:setMagic(data)
    local magicPanel = self:getControl("Panel01")
    local backPanel = self:getControl("Panel02")
    if data.status == PRACTICE_TYPR.PRACTICE_STATUS_SELECT then
        if not next(magicPanel:getChildren()) then
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200425]], magicPanel, function ()
                gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200427]], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)
            end, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)
        else
            magicPanel:removeAllChildren()
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200427]], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)
        end

        backPanel:removeAllChildren()
    elseif data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE then
        if not next(magicPanel:getChildren()) then
        else
            magicPanel:removeAllChildren()
            gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200426]], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)
        end

        backPanel:removeAllChildren()
    elseif data.status == PRACTICE_TYPR.PRACTICE_STATUS_RUNNING then
        backPanel:removeAllChildren()
        magicPanel:removeAllChildren()
        local polar = Me:queryInt("polar")
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200429]][polar], magicPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)

        local qi = gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200430]][polar], backPanel, nil, nil, nil, magicPanel:getContentSize().width * 0.5 + 1, MAGIC_DIS - 5)
        qi:setScale((100 - data.xinmo) * 0.01)
    end
end

function HomePlayerPracticeDlg:setDisplayByType(data)
    self:setCtrlVisible("StopButton", false)
    self:setCtrlVisible("GetButton", false)
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("ReturnButton", false)
    self:setCtrlVisible("InButton", false)
    self:setCtrlVisible("OutButton", false)

    -- 预计产出奖励时间
    self:setCtrlVisible("NextTimeLabel", true)

    -- 隐藏打坐图
    self:setCtrlVisible("PersonPanel", false)

    local magicPanel = self:getControl("Panel01")
    if data.status == PRACTICE_TYPR.PRACTICE_STATUS_SELECT then
        -- 打坐图和光效
        self:setCtrlVisible("PersonPanel", true)
        self:setCtrlVisible("ReturnButton", true)
        self:setCtrlVisible("OutButton", true)

        -- 开始按钮
        self:setCtrlVisible("StartButton", data.total_bonus_tao == 0)
        self:setCtrlEnabled("StartButton", true)

        if self:isRestTime() then
            self:setLabelText("NextTimeLabel", CHS[4200416])
        else
            self:setLabelText("NextTimeLabel", CHS[4200417])
        end

        local getBtn = self:getControl("GetButton")
        getBtn:setVisible(data.total_bonus_tao ~= 0)
        if data.total_bonus_tao ~= 0 then
            -- 领取奖励按钮居中
            local parent = getBtn:getParent()
            getBtn:setPositionX(parent:getContentSize().width * 0.5)
        else
            getBtn:setPositionX(self.getBtnPos)
        end
    elseif data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE then

        self:setCtrlVisible("StartButton", true)

        -- 入阵按钮
        self:setCtrlVisible("InButton", true)

        self:setCtrlEnabled("StartButton", false)

        if self:isRestTime() then
            self:setLabelText("NextTimeLabel", CHS[4200416])
        else
            self:setLabelText("NextTimeLabel", CHS[4200417])
        end

    elseif data.status == PRACTICE_TYPR.PRACTICE_STATUS_RUNNING then
        -- 打坐图和光效
        self:setCtrlVisible("PersonPanel", true)

        -- 预计产出奖励时间
        self:setCtrlVisible("NextTimeLabel", true)

        self:setCtrlVisible("ReturnButton", true)
        self:setCtrlVisible("StopButton", true)
        self:setCtrlVisible("GetButton", true)
        self:setCtrlEnabled("StartButton", true)
    end
end

function HomePlayerPracticeDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("HomePracticeRuleDlg")
end

function HomePlayerPracticeDlg:onOutButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end



    HomeMgr:queryHourPlayerPractice("leave", self.data.furniture_pos)
end

function HomePlayerPracticeDlg:onInButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    if Me:queryBasicInt("level") < 50 then
        gf:ShowSmallTips(CHS[4100695])
        return
    end

    HomeMgr:queryHourPlayerPractice("enter", self.data.furniture_pos)
end

function HomePlayerPracticeDlg:onReturnButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    if not self.data then return end
    if self.data.xinmo <= 0 then
        gf:ShowSmallTips(CHS[4100696])
        return
    end

    local fur = HomeMgr:getFurnitureById(self.data.furniture_pos)
    HomeMgr:queryHourPlayerPractice("clear_xinmo", "")
end

function HomePlayerPracticeDlg:onAddCleanButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    HomeMgr:requestData("HomeCleanDlg")
    --DlgMgr:openDlg("HomeTakeCareDlg")
end


function HomePlayerPracticeDlg:onAddNaijiuButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.data then
        return
    end

    local fur = HomeMgr:getFurnitureById(self.data.furniture_pos)
    if fur then
        local nowDur, maxDur = HomeMgr:getDurInfo(fur)
        local cosrCash = HomeMgr:getFixCost(nowDur, maxDur)
        HomeMgr:repairItem(fur, cosrCash)
    end
end

function HomePlayerPracticeDlg:onGetButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    HomeMgr:queryHourPlayerPractice("bonus", self.data.furniture_pos)
end

function HomePlayerPracticeDlg:onStopButton(sender, eventType)
    if HomeMgr:isInMyHouse() and string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    gf:confirm(CHS[4100698], function ()
        HomeMgr:queryHourPlayerPractice("stop", self.data.furniture_pos)
    end)
end

function HomePlayerPracticeDlg:onStartButton(sender, eventType)
    if HomeMgr:isInMyHouse() and string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end

        if not self.data then return end
        if self.data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE then
            gf:ShowSmallTips(CHS[4100699])
            return
        end
    end

    HomeMgr:queryHourPlayerPractice("start", self.data.furniture_pos)
end

function HomePlayerPracticeDlg:onHelpButton(sender, eventType)
    if not self.selectChar then return end
    HomeMgr:queryHourPlayerPractice("friend_clear_xinmo", self.selectChar.gid)
end

function HomePlayerPracticeDlg:onFriendButton_1(sender, eventType)
    self:setCtrlVisible("FriendButton_2", true)
    self:setCtrlVisible("HistoryButton_2", false)

    self:setCtrlVisible("FriendlistPanel", true)
    self:setCtrlVisible("HistorylistPanel", false)

    self:setCtrlVisible("HelpButton", false, "HelpPanel")
    self.display = "haoyou"


    if not self.hasRequestFriendData then
        gf:CmdToServer("CMD_HOUSE_PLAYER_PRACTICE_HELP_TARGETS", {})
        self.hasRequestFriendData = true
    end

    self:setFriendList(self.friendData)
end

function HomePlayerPracticeDlg:onRefreshButton(sender, eventType)
    if not self.lastRequestTargersTime then
        self.lastRequestTargersTime = 0
    end

    local curTime = gf:getServerTime()
    local cTime = math.max(curTime - self.lastRequestTargersTime, 0)
    if cTime < 3 then
        gf:ShowSmallTips(string.format(CHS[5420300], 3 - cTime))
        return
    end

    self.lastRequestTargersTime = curTime
    self.isRefreshData = true

    gf:CmdToServer("CMD_HOUSE_PLAYER_PRACTICE_HELP_TARGETS", {})
end

function HomePlayerPracticeDlg:onFriendButton_2(sender, eventType)
    self:setCtrlVisible("HistoryButton_2", false)
end

function HomePlayerPracticeDlg:onHistoryButton_1(sender, eventType)
    self:setCtrlVisible("FriendButton_2", false)
    self:setCtrlVisible("HistoryButton_2", true)

    self:setCtrlVisible("FriendlistPanel", false)
    self:setCtrlVisible("HistorylistPanel", true)


    self.display = "xiezhu"
    if not self.helpData then
        HomeMgr:queryHourPlayerPractice("help_me_records","")
    else
        self:setHelpedList(self.helpData)
    end
end

function HomePlayerPracticeDlg:onHistoryButton_2(sender, eventType)
    self:setCtrlVisible("FriendButton_2", false)
end

function HomePlayerPracticeDlg:MSG_PLAYER_PRACTICE_XINMO_UPDATED(data)
    if not self.data then return end
    local colorXinmo = COLOR3.TEXT_DEFAULT
    if data.xinmo >= 20 then
        colorXinmo = COLOR3.RED
    end
    if self.data.status == PRACTICE_TYPR.PRACTICE_STATUS_NONE then
        -- 心魔干扰度
        self:setLabelText("ValueLabel", CHS[4100692], "EvilPanel", COLOR3.TEXT_DEFAULT)
    else
        -- 心魔干扰度
        self:setLabelText("ValueLabel", string.format("%d%%", data.xinmo), "EvilPanel", colorXinmo)
    end
end

function HomePlayerPracticeDlg:MSG_PLAYER_PRACTICE_FRIEND_DATA(data)
    if not self.selectChar then return end
    if self.selectChar.gid ~= data.gid then return end
    self:setFriendRightInfo(data)

     -- 更新好友
    if self.friendData then
        for _, value in pairs(self.friendData) do
            if data.gid == value.gid then
                value.xinmo = data.xinmo
            end
        end
    end
end

function HomePlayerPracticeDlg:sortFriend(ret)
    table.sort(ret, function(l, r)
        if l.flag < r.flag then return true end
        if l.flag > r.flag then return false end
        if l.isOnline < r.isOnline then return true end
        if l.isOnline > r.isOnline then return false end
        if l.xinmo > r.xinmo then return true end
        if l.xinmo < r.xinmo then return false end
        if l.isVip > r.isVip then return true end
        if l.isVip < r.isVip then return false end
        if l.friend > r.friend then return true end
        if l.friend < r.friend then return false end
        return false
    end)

    return ret
end

function HomePlayerPracticeDlg:MSG_PLAYER_PRACTICE_HELP_TARGETS(data)
    if self.isRefreshData then
        gf:ShowSmallTips(CHS[5400514])
        self.isRefreshData = nil
    end

    local ret = {}
    for i = 1, data.count do
        local gid = data.members[i].gid
        local friend = FriendMgr:getFriendByGid(gid)
        if friend then
            local onceData = {xinmo = data.members[i].xinmo, gid = gid,isVip = friend:queryInt("insider_level"), isOnline = friend:queryInt("online"),flag = data.members[i].flag, friend = data.members[i].friend,name = friend:queryBasic("char"), level = friend:queryBasicInt("level"), icon = friend:queryBasicInt("icon")}
            table.insert(ret, onceData)
        end
    end

    self.friendData = self:sortFriend(ret)
    HomeMgr:setPracticeHelpTargets(self.friendData)
    if self.display ~= "haoyou" then return end -- 如果不是好友，则返回
    self:setFriendList(ret)
end

function HomePlayerPracticeDlg:MSG_PLAYER_PRACTICE_HELP_ME_RECORDS(data)
    if self.display ~= "xiezhu" then return end -- 如果不是好友，则返回
    if not self.data then return end

    self.helpData = data.members
    self:setHelpedList(data.members)
end

function HomePlayerPracticeDlg:MSG_GENERAL_NOTIFY(data)
    if not self.friendData then return end
    if data.notify ~= NOTIFY.NOTIFY_FRIEND_CLEAR_XINMO then return end

    local panelTotal = self:getControl("HelpPanel")
    if panelTotal.data and data.para == panelTotal.data.gid then
        local magicPanel = self:getControl("Panel01", nil, panelTotal)
        local polar = panelTotal.data.polar
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.house_renwuxiulian.name, MAGIC_MAP[CHS[4200428]][polar], magicPanel, nil, nil, nil, nil, MAGIC_DIS)
    end

    -- 更新好友
    if self.friendData then
        for _, value in pairs(self.friendData) do
            if data.para == value.gid then
                value.flag = 1
            end
        end
        if self.display == "haoyou" then
            local list = self:getControl("FriendListView")
            local panels = list:getItems()
            for _, panel in pairs(panels) do
                if panel.data.gid == data.para then
                    self:setUnitFriendPanel(self.friendData[_], panel)
                end
            end
        end
    end

    -- 更新协助
    if self.helpData then
        for _, value in pairs(self.helpData) do
            if data.para == value.gid then
                value.flag = 1
            end
        end
        if self.display == "xiezhu" then
            local list = self:getControl("HistoryListView")
            local panels = list:getItems()
            for _, panel in pairs(panels) do
                if panel.data.gid == data.para then
                    self:setUnitRecordPanel(self.helpData[_], panel, _)
                end
            end
        end
    end
end

function HomePlayerPracticeDlg:MSG_HOUSE_FURNITURE_OPER(data)
    if self.data.furniture_pos == data.furniture_pos then
        -- 家具耐久度
        self:setLabelText("ValueLabel", string.format("%d/%d", data.durability, HomeMgr:getMaxDur(self.data.name)), "DurabilityPanel")
    end
end

function HomePlayerPracticeDlg:MSG_FRIEND_UPDATE_PARTIAL(data)
    if not self.friendData then return end
    for _, value in pairs(self.friendData) do
        if data.gid == value.gid and data.friend then
            value.friend = data.friend
        end
    end

    if self.display == "haoyou" then
        local list = self:getControl("FriendListView")
        local panels = list:getItems()
        for _, panel in pairs(panels) do
            if panel.data.gid == data.gid then
                self:setUnitFriendPanel(self.friendData[_], panel)
            end
        end
    end
end

function HomePlayerPracticeDlg:MSG_HOUSE_DATA(data)

    -- 居所舒适度
    local comf = HomeMgr:getComfort()
    local max_comf = HomeMgr:getMaxComfort()
    self:setLabelText("ValueLabel", string.format("%d/%d", comf, max_comf), "SuitPanel")

    -- 居所清洁度
    local color = COLOR3.TEXT_DEFAULT
    if HomeMgr:getClean() <= 20 then
        color = COLOR3.RED
    end
    self:setLabelText("ValueLabel", string.format("%d/%d", HomeMgr:getClean(), HomeMgr:getMaxClean()), "CleanPanel", color)
end

return HomePlayerPracticeDlg
