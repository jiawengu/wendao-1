-- MasterDlg.lua
-- Created by songcw June/1/2016
-- 师徒界面

local MasterDlg = Singleton("MasterDlg", Dialog)
local Bitset = require("core/Bitset")
local RadioGroup = require("ctrl/RadioGroup")

local DISPLAY_TYPE = {
    MASTER      = "MasterCheckBox",            -- 拜师
    STUDENT     = "StudentCheckBox",            -- 收徒
    APPLY       = "ApplyCheckBox",
}

local MASTER_CHECKBOS = {
    "MasterCheckBox",
    "StudentCheckBox",
    "ApplyCheckBox",
}

-- 拜师、收徒checkbox
local MASTER_INFO_CHECKBOS = {
    "WordCheckBox",         -- 留言
    "InfoCheckBox",         -- 信息
}

-- 申请界面的checkbox
local APPLY_INFO_CHECKBOS = {
    "AWordCheckBox",         -- 留言
    "AInfoCheckBox",         -- 信息
}

local PER_PAGE_COUNT = 15

function MasterDlg:init()
    self:bindListener("CommunionButton", self.onCommunionButton)
    self:bindListener("FriendButton", self.onFriendButton)
    self:bindListener("ApplyButton", self.onApplyButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("CheckButton", self.onCheckButton)
    self:bindListener("CheckButton_1", self.onCheckButton_1)
    self:bindListener("CommunionButton", self.onApplyCommunionButton, "ApplyPanel")
    self:bindListener("FriendButton", self.onApplyFriendButton, "ApplyPanel")
    --self:bindListener("ApplyButton", self.onIDoButton, "ApplyPanel")
    self:bindListener("ApplyInteractiveButton", self.onApplyInteractiveButton)
    self:bindListener("RefusedButton", self.onRefusedButton, "ApplyPanel")
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("RefreshButton", self.onRefreshButton, "ApplyPanel")

    -- 滚动加载
    self:bindListViewByPageLoad("MasterListView", "ListViewTouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            local listInfo = {}
            if self:getDisplayType() == DISPLAY_TYPE.MASTER then
                listInfo = MasterMgr:getMastersInfo()
            elseif self:getDisplayType() == DISPLAY_TYPE.STUDENT then
                listInfo = MasterMgr:getStudentInfo()
            end

            local memberList = self:getListByCount("MasterListView", listInfo, PER_PAGE_COUNT)
            self:pushMasterData(memberList)
        end
    end)

    self:bindListViewByPageLoad("ApplyListView", "ListViewTouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            local listInfo = MasterMgr:getApplyInfo()

            local memberList = self:getListByCount("ApplyListView", listInfo, PER_PAGE_COUNT)
            self:pushApplyData(memberList)
        end
    end)

    self.masterCharInfo = {}

    -- 收到MSG_CHAR_INFO后操作，若Gid一致，则加好友
    self.addFriendGid = nil

    self.chosenMasterInfo = nil
    self.applyListStart = 0

    -- 界面初始化，隐藏不该显示的控件
    self:dlgDataInit()

    -- listView和克隆Panel初始化
    self:listViewInit()

    -- 单选框初始化
    self:radioGroupInit()

    -- 设置初始化界面类型
    self:initSelect()

    -- 光效
    self:setLightEff()

    self:hookMsg("MSG_SEARCH_MASTER_INFO")
    self:hookMsg("MSG_SEARCH_APPRENTICE_INFO")
    self:hookMsg('MSG_REQUEST_APPENTICE_INFO')
    self:hookMsg('MSG_CHAR_INFO')
    self:hookMsg('MSG_REQUEST_APPRENTICE_SUCCESS')

    self:hookMsg('MSG_MY_SEARCH_MASTER_MESSAGE')
    self:hookMsg('MSG_MY_SEARCH_APPRENTICE_MESSAGE')
    self:hookMsg('MSG_NOTIFY_RECORD_APPRENTICE')
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")

    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_OFFLINE_CHAR_INFO")

    -- 查询我的师徒信息
    MasterMgr:cmdQueryMyMaster()
end

-- 光效
function MasterDlg:setLightEff()
    local task = TaskMgr:getTaskByName(CHS[4300040])
    if task and task.attrib:isSet(TASK.ATTRIB_LIGHT_SERCH_APPRENTICE) then
        -- lixh2 WDSY-21401 帧光效修改为粒子光效：寻师觅徒按钮环绕光效
        local btn = self:getControl("CheckButton_1")
        gf:createArmatureMagic(ResMgr.ArmatureMagic.find_master_btn, btn, Const.ARMATURE_MAGIC_TAG)
    end

    local task = TaskMgr:getTaskByName(CHS[4300041])
    if task and task.attrib:isSet(TASK.ATTRIB_LIGHT_SERCH_MASTER) then
        -- lixh2 WDSY-21401 帧光效修改为粒子光效：寻师觅徒按钮环绕光效
        local btn = self:getControl("CheckButton")
        gf:createArmatureMagic(ResMgr.ArmatureMagic.find_master_btn, btn, Const.ARMATURE_MAGIC_TAG)
    end
end

-- 单选框初始化
function MasterDlg:radioGroupInit()
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, MASTER_CHECKBOS, self.onMatserCheckBox)

    self.masterInfoRGroup = RadioGroup.new()
    self.masterInfoRGroup:setItems(self, MASTER_INFO_CHECKBOS, self.onMatserInfoCheckBox)

    self.applyInfoRGroup = RadioGroup.new()
    self.applyInfoRGroup:setItems(self, APPLY_INFO_CHECKBOS, self.onApplyInfoCheckBox)
end

-- 设置初始化界面类型
function MasterDlg:initSelect()
    local tip = ""
    if Me:queryBasicInt("level") < MasterMgr:getBeMasterLevel() then
        self.radioGroup:setSetlctByName(MASTER_CHECKBOS[1])
        self.masterInfoRGroup:setSetlctByName(MASTER_INFO_CHECKBOS[1])
        self:setDlgCtrlState(DISPLAY_TYPE.MASTER)
        -- [4100124] = "当前还没有想要收徒的师父，道友请稍后再来。",
        tip = CHS[4100124]
    else
        self.radioGroup:setSetlctByName(MASTER_CHECKBOS[2])
        self.masterInfoRGroup:setSetlctByName(MASTER_INFO_CHECKBOS[2])
        self:setDlgCtrlState(DISPLAY_TYPE.STUDENT)
        -- [4100125] = "当前还没有想要拜师的弟子，道友请稍后再来。",
        tip = CHS[4100125]
    end

    performWithDelay(self.root, function()
        -- 拜师或收徒时，没有收到服务器发来的消息，修改提示信息
        if #self.masterListView:getItems() == 0 and not self:getCtrlVisible("NoneImage") then
            -- 不调用setMasterListView方法是因为如果在调用该方法时，
            -- 点击了申请列表，则提示信息将不会被更新（服务器没有返回消息的情况下）
            self:setCtrlVisible("NoneImage", true)
            self:setLabelText("NoneLabel", tip)
        end
    end, 2) -- 设置为2秒是因为设置为1秒的话，自己寻师之后收徒不会马上显示自己的信息

    self.applyInfoRGroup:setSetlctByName(APPLY_INFO_CHECKBOS[1])
end

function MasterDlg:getDisplayType()
    if not self.radioGroup then return DISPLAY_TYPE.MASTER end
    return self.radioGroup:getSelectedRadio():getName()
end

function MasterDlg:setMatserInfoRGroupLabel()
    local type = self.radioGroup:getSelectedRadio():getName()
    if type == DISPLAY_TYPE.MASTER then
        -- [4100114] = "拜师留言",
        self:setLabelText("Label1", CHS[4100114], MASTER_INFO_CHECKBOS[1])
        self:setLabelText("Label2", CHS[4100114], MASTER_INFO_CHECKBOS[1])
        -- [4100115] = "师傅信息",
        self:setLabelText("Label1", CHS[4100115], MASTER_INFO_CHECKBOS[2])
        self:setLabelText("Label2", CHS[4100115], MASTER_INFO_CHECKBOS[2])
    elseif type == DISPLAY_TYPE.STUDENT then
        -- [4100116] = "收徒留言",
        self:setLabelText("Label1", CHS[4100116], MASTER_INFO_CHECKBOS[1])
        self:setLabelText("Label2", CHS[4100116], MASTER_INFO_CHECKBOS[1])
        -- [4100117] = "徒弟信息",
        self:setLabelText("Label1", CHS[4100117], MASTER_INFO_CHECKBOS[2])
        self:setLabelText("Label2", CHS[4100117], MASTER_INFO_CHECKBOS[2])
    end
end

-- listView初始化
function MasterDlg:listViewInit()
    -- 拜师收徒信息panel
    self.masterInfoPanel = self:getControl("MasterInfoPanel")
    self.masterInfoPanel:retain()
    self.masterInfoPanel:removeFromParent()

    self:bindTouchEndEventListener(self.masterInfoPanel, self.onChosenMasterPanel)
    self:bindListener("InteractiveButton", self.onInteractiveButton, self.masterInfoPanel)

    self.masterSelectImage = self:getControl("ChosenEffectImage", nil, self.masterInfoPanel)
    self.masterSelectImage:retain()
    self.masterSelectImage:removeFromParent()
    self.masterSelectImage:setVisible(true)

    -- 申请信息panel
    self.applyInfoPanel = self:getControl("ApplyInfoPanel")
    self.applyInfoPanel:retain()
    self.applyInfoPanel:removeFromParent()

    self:bindTouchEndEventListener(self.applyInfoPanel, self.onChosenApplyPanel)

    self:bindListener("ApplyButton", self.onIDoButton, self.applyInfoPanel)
    self:bindListener("CancelButton", self.onCancelButton, self.applyInfoPanel)

    self.masterListView = self:resetListView("MasterListView")
    self.applyListView = self:resetListView("ApplyListView")
end

function MasterDlg:cleanup()
    self:releaseCloneCtrl("masterInfoPanel")
    self:releaseCloneCtrl("masterSelectImage")
    self:releaseCloneCtrl("applyInfoPanel")

    FriendMgr:unrequestCharMenuInfo(self.name)
    self.onCharInfo = nil
end

-- 设置界面信息
function MasterDlg:setDlgCtrlState(display)
    if display == DISPLAY_TYPE.MASTER or display == DISPLAY_TYPE.STUDENT then
        -- 显示拜师相关界面
        self:setCtrlVisible("ChangePanel", true)
        self:setCtrlVisible("MasterPanel", true)
        self:setCtrlVisible("ApplyPanel", false)
    elseif display == DISPLAY_TYPE.APPLY then
        self:setCtrlVisible("ChangePanel", true)
        self:setCtrlVisible("ApplyPanel", true)
        self:setCtrlVisible("MasterPanel", false)
    end
end

-- 界面初始化，隐藏不该显示的控件
function MasterDlg:dlgDataInit()
    self:setRightMasterInfo()
    self:setCtrlVisible("ChangePanel", false)
    self:setCtrlVisible("MasterPanel", false)
    self:setCtrlVisible("ApplyPanel", false)
    self:setCtrlVisible("RelationPanel", false)

    self:MSG_MY_SEARCH_MASTER_MESSAGE()
    self:MSG_MY_SEARCH_APPRENTICE_MESSAGE()
end

-- 拜师、收徒、申请列表单选框响应
function MasterDlg:onMatserCheckBox(sender, eventType)
    self:setDlgCtrlState(sender:getName())
    self:setCtrlVisible("CheckButton", false)
    self:setCtrlVisible("CheckButton_1", false)

    self:setListViewTop("MasterListView", nil, 0, true)
    self:resetListView("MasterListView")

    local itemPanel = self:getControl("ItemPanel")
    if sender:getName() == DISPLAY_TYPE.MASTER then
        MasterMgr:searchTeacherList(true)
        self:setCtrlVisible("CheckButton", true)
        local btn = self:getControl("ApplyButton", nil, itemPanel)
        -- [4100118] = "申 请 拜 师",
        self:setLabelText("Label_86", CHS[4100118], btn)

        -- [4100119] = "寻徒留言",
        self:setLabelText("Label1", CHS[4100119], "WordCheckBox")
        self:setLabelText("Label2", CHS[4100119], "WordCheckBox")
        -- [4100120] = "师父信息",
        self:setLabelText("Label1", CHS[4100120], "InfoCheckBox")
        self:setLabelText("Label2", CHS[4100120], "InfoCheckBox")
    elseif sender:getName() == DISPLAY_TYPE.STUDENT then
        MasterMgr:searchStudentList(true)
        self:setCtrlVisible("CheckButton_1", true)
        local btn = self:getControl("ApplyButton", nil, itemPanel)
        -- [4100121] = "申 请 收 徒",
        self:setLabelText("Label_86", CHS[4100121], btn)

        -- [4100122] = "寻师留言",
        self:setLabelText("Label1", CHS[4100122], "WordCheckBox")
        self:setLabelText("Label2", CHS[4100122], "WordCheckBox")
        -- [4100123] = "徒弟信息",
        self:setLabelText("Label1", CHS[4100123], "InfoCheckBox")
        self:setLabelText("Label2", CHS[4100123], "InfoCheckBox")
    else
        self.applyListStart = 0
        MasterMgr:searchApplyList()
    end
end

-- 拜师、收徒、申请列表右边     留言or信息单选框
function MasterDlg:onMatserInfoCheckBox(sender, eventType)
    self:setCtrlVisible("ContentPanel", false, "MasterPanel")
    self:setCtrlVisible("FigurePanel", false, "MasterPanel")
    if sender:getName() == MASTER_INFO_CHECKBOS[1] then
        -- 留言
        self:setCtrlVisible("ContentPanel", true, "MasterPanel")
    elseif sender:getName() == MASTER_INFO_CHECKBOS[2] then
        -- 信息
        self:setCtrlVisible("FigurePanel", true, "MasterPanel")
    end
end

function MasterDlg:onApplyInfoCheckBox(sender, eventType)
    self:setCtrlVisible("ContentPanel", false, "ApplyPanel")
    self:setCtrlVisible("FigurePanel", false, "ApplyPanel")
    if sender:getName() == APPLY_INFO_CHECKBOS[1] then
        -- 留言
        self:setCtrlVisible("ContentPanel", true, "ApplyPanel")
    elseif sender:getName() == APPLY_INFO_CHECKBOS[2] then
        -- 信息
        self:setCtrlVisible("FigurePanel", true, "ApplyPanel")
    end
end

function MasterDlg:setStudentList()
    local listInfo = MasterMgr:getStudentInfo()
    self:setMasterListView(listInfo)
end

function MasterDlg:setTeacherList()
    local listInfo = MasterMgr:getMastersInfo()
    self:setMasterListView(listInfo)
end

function MasterDlg:setApplyList()
    local listInfo = MasterMgr:getApplyInfo()
    self:setApplyListView(listInfo)
end

function MasterDlg:setApplyListView(listInfo)
    if self.onCharInfo then
        FriendMgr:unrequestCharMenuInfo(self.name)
        self.onCharInfo = nil
    end
    self:setListViewTop("ApplyListView", nil, 0, true)
    self:resetListView("ApplyListView")
    self.applyListStart = 0
    if not next(listInfo) or listInfo.count == 0 then
        -- 如果没有列表
        self:setCtrlVisible("NoneImage", true)
        local type = self.radioGroup:getSelectedRadio():getName()
        if type == DISPLAY_TYPE.MASTER then
            -- [4100124] = "当前还没有想要收徒的师父，道友请稍后再来。",
            self:setLabelText("NoneLabel", CHS[4100124])
        elseif type == DISPLAY_TYPE.STUDENT then
            -- [4100125] = "当前还没有想要拜师的弟子，道友请稍后再来。",
            self:setLabelText("NoneLabel", CHS[4100125])
        end
        self:setRightMasterInfo(nil, "ApplyPanel")
        self:updateLayout("ListPanel")
        return
    end

    self:setCtrlVisible("NoneImage", false)
    self:setLabelText("NoneLabel", "")
    local memberList = self:getListByCount("ApplyListView", listInfo, PER_PAGE_COUNT)
    self:pushApplyData(memberList)

    self:onChosenApplyPanel()
end

function MasterDlg:setMasterListView(listInfo)
    if self.onCharInfo then
        FriendMgr:unrequestCharMenuInfo(self.name)
        self.onCharInfo = nil
    end
    self:resetListView("MasterListView")
    if not next(listInfo) or listInfo.count == 0 then
        -- 如果没有列表
        self.chosenMasterInfo = nil
        self:setCtrlVisible("NoneImage", true)
        local type = self.radioGroup:getSelectedRadio():getName()
        if type == DISPLAY_TYPE.MASTER then
            -- [4100124] = "当前还没有想要收徒的师父，道友请稍候再来。",
            self:setLabelText("NoneLabel", CHS[4100124])
        elseif type == DISPLAY_TYPE.STUDENT then
            -- [4100125] = "当前还没有想要拜师的弟子，道友请稍候再来。",
            self:setLabelText("NoneLabel", CHS[4100125])
        end
        self:setRightMasterInfo(nil, "MasterPanel")
        self:updateLayout("ListPanel")
        return
    end

    self:setCtrlVisible("NoneImage", false)
    self:setLabelText("NoneLabel", "")
    local memberList = self:getListByCount("MasterListView", listInfo, PER_PAGE_COUNT)
    self:pushMasterData(memberList)
    self:onChosenMasterPanel()
end

function MasterDlg:getListByCount(listCtrlName, listInfo, pageCount)
    local retValue = {}
    if not listInfo or not listInfo.userInfo or #listInfo.userInfo <= 0 then return retValue end
    local listCtrl = self:getControl(listCtrlName)
    local star = #listCtrl:getItems()

    if listCtrlName == "ApplyListView" then
        star = self.applyListStart
    end
    for i = star + 1, (star + pageCount) do
        if listInfo["userInfo"][i] then
            table.insert(retValue, listInfo["userInfo"][i])
        else
            return retValue
        end
    end

    return retValue
end

function MasterDlg:pushApplyData(memberList)
    local count = #memberList + #self.applyListView:getItems()
    local height = self.applyInfoPanel:getContentSize().height
    local contentSize = self.applyListView:getInnerContainerSize()
    contentSize.height = height * count
    self.applyListView:setInnerContainerSize(contentSize)
    for i = 1, #memberList do
        local panel = self.applyInfoPanel:clone()
        panel.charInfo = memberList[i]
        self:setApplyListSingelPanel(panel)
        self:setCtrlVisible("BackImage_2", (#self.applyListView:getItems() % 2 == 1), panel)
        self.applyListView:pushBackCustomItem(panel)
    end

    self.applyListStart = self.applyListStart + #memberList
end

function MasterDlg:pushMasterData(memberList)
    local count = #memberList + #self.masterListView:getItems()
    local height = self.applyInfoPanel:getContentSize().height
    local contentSize = self.masterListView:getInnerContainerSize()
    contentSize.height = height * count
    self.masterListView:setInnerContainerSize(contentSize)
    for i = 1, #memberList do
        local panel = self.masterInfoPanel:clone()
        panel.charInfo = memberList[i]
        self:setMasterListSingelPanel(panel)
        self:setCtrlVisible("BackImage_2", (#self.masterListView:getItems() % 2 == 1), panel)
        self.masterListView:pushBackCustomItem(panel)
    end
end

function MasterDlg:onChosenMasterPanel(sender, eventType)
    if #self.masterListView:getItems() == 0 then return end
    if not sender then
        sender = self.masterListView:getItems()[1]
    end
    self.chosenMasterInfo = sender.charInfo
    self:setRightMasterInfo(self.chosenMasterInfo, "MasterPanel")
    self:addSelectImageMaster(sender)
end

function MasterDlg:onChosenApplyPanel(sender, eventType)
    if #self.applyListView:getItems() == 0 then
        self.chosenApplyInfo = nil
        self:setRightMasterInfo(self.chosenApplyInfo, "ApplyPanel")
        return
    end
    if not sender then
        sender = self.applyListView:getItems()[1]
    end
    self.chosenApplyInfo = sender.charInfo
    self:setRightMasterInfo(self.chosenApplyInfo, "ApplyPanel")
    self:addSelectImageMaster(sender)
end

function MasterDlg:addSelectImageMaster(panel)
    self.masterSelectImage:removeFromParent()
    panel:addChild(self.masterSelectImage)
end

-- 设置右边师傅、徒弟信息
function MasterDlg:setRightMasterInfo(info, panel)
    local wordPanel = self:getControl("ContentPanel", nil, panel)
    local figurePanel = self:getControl("FigurePanel", nil, panel)
    if not info then
        self:setLabelText("NameLabel", "", wordPanel)
        self:setLeaveMessage("", wordPanel)
        self:setLabelText("NameLabel", "", figurePanel)
        self:setLabelText("PartyLabel", "", figurePanel)
        self:removePortrait("FigurePanel", panel)
        self:setLabelText("StudentLabel", "", figurePanel)

        self:setCtrlEnabled(MASTER_INFO_CHECKBOS[1], false)
        self:setCtrlEnabled(MASTER_INFO_CHECKBOS[2], false)
        self:setCtrlEnabled(APPLY_INFO_CHECKBOS[1], false)
        self:setCtrlEnabled(APPLY_INFO_CHECKBOS[2], false)

        self:removeUpgradeMagicToCtrl("FigurePanel", panel)
        return
    end

    self:setLabelText("NameLabel", info.name, wordPanel)

    local str = info.message
    self:setLeaveMessage(str, wordPanel)

    self:setLabelText("NameLabel", info.name, figurePanel)
    self:setLabelText("PartyLabel", info.party, figurePanel)
    if info.totalStudentCount and info.level >= MasterMgr:getBeMasterLevel() then
        self:setLabelText("StudentLabel", string.format(CHS[4200082], info.totalStudentCount), figurePanel)
    else
        self:setLabelText("StudentLabel", "", figurePanel)
    end
    if info.suitIcon == 0 then
        self:setPortrait("FigurePanel", info.icon, info.weaponIcon, panel, nil, nil, nil, nil, info.icon)
    else
        self:setPortrait("FigurePanel", info.suitIcon, info.weaponIcon, panel, nil, nil, nil, nil, info.icon)
    end

    -- 仙魔光效
    if info["upgrade/type"] then
        self:addUpgradeMagicToCtrl("FigurePanel", info["upgrade/type"], panel, true)
    end

    self:setCtrlEnabled(MASTER_INFO_CHECKBOS[1], true)
    self:setCtrlEnabled(MASTER_INFO_CHECKBOS[2], true)
    self:setCtrlEnabled(APPLY_INFO_CHECKBOS[1], true)
    self:setCtrlEnabled(APPLY_INFO_CHECKBOS[2], true)
end

-- 设置留言
function MasterDlg:setLeaveMessage(str, panel)
    -- 删除残留的留言
    local lastMessage = panel:getChildByName("ColorText")
    if lastMessage then lastMessage:removeFromParent() end

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(20)
    textCtrl:setString(gf:filterPlayerColorText(str))
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    textCtrl:updateNow()

    textCtrl:setPosition(0, size.height)

    local colorText = tolua.cast(textCtrl, "cc.LayerColor")
    colorText:setName("ColorText")
    panel:addChild(colorText)
end

function MasterDlg:setApplyListSingelPanel( panel)
    local info = panel.charInfo
    self:setMasterListSingelPanel(panel)
    self:setLabelText("NameLabel", info.name, panel)
    self:setLabelText("NameLabel_1", info.name, panel)
    if info.requestType == 4 then
        self:setLabelText("NumLabel", "", panel)
        self:setLabelText("NameLabel_1", "", panel)
    else
        self:setLabelText("NameLabel", "", panel)
    end
end

function MasterDlg:setMasterListSingelPanel(panel)
    local info = panel.charInfo
    -- 名字
    self:setLabelText("NameLabel", info.name, panel)
    self:setLabelText("NameLabel_1", info.name, panel)
    -- 出师数
    if info.oldStudent then
        -- [4100126] = "出师数：",
        self:setLabelText("NumLabel", CHS[4100126] .. info.oldStudent, panel)
        self:setLabelText("NameLabel_1", "", panel)
    else
        self:setLabelText("NameLabel", "", panel)
        self:setLabelText("NumLabel", "", panel)
    end
    -- 相性
    self:setLabelText("PolarLabel", gf:getPolar(info.polar), panel)
    -- 是否在线
    if info.isOnline == 1 then
        -- [4100127] = "在线",
        self:setLabelText("OlineLabel", CHS[4100127], panel)
    else
        -- [4100128] = "离线",
        self:setLabelText("OlineLabel", CHS[4100128], panel)
    end
    -- 头像
    self:setImage("UserImage", ResMgr:getSmallPortrait(info.icon), panel)
    self:setItemImageSize("UserImage", panel)
    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, info.level, false, LOCATE_POSITION.LEFT_TOP, 21, panel)

    self:setCtrlVisible("InteractiveButton", (Me:queryBasic("gid") ~= info.gid), panel)

    -- 是否申请过
    self:setCtrlVisible("ApplyEffectImage", (info.isApply == 1), panel)
end

function MasterDlg:onApplyFriendButton(sender, eventType)
    if not self.chosenApplyInfo then return end
    if self.chosenApplyInfo.name == Me:getName() then
        -- [4100129] = "你不能加自己为好友。",
        gf:ShowSmallTips(CHS[4100129])
        return
    end

    if FriendMgr:hasFriend(self.chosenApplyInfo.gid) then
        return
    end

    FriendMgr:requestCharMenuInfo(self.chosenApplyInfo.gid)
    self.addFriendGid = self.chosenApplyInfo.gid
end


function MasterDlg:onFriendButton(sender, eventType)
    if not self.chosenMasterInfo then return end
    if self.chosenMasterInfo.name == Me:getName() then
        -- [4100129] = "你不能加自己为好友。",
        gf:ShowSmallTips(CHS[4100129])
        return
    end

    if FriendMgr:hasFriend(self.chosenMasterInfo.gid) then
        gf:ShowSmallTips(string.format(CHS[4200437], self.chosenMasterInfo.name))
        return
    end

    FriendMgr:requestCharMenuInfo(self.chosenMasterInfo.gid)
    self.addFriendGid = self.chosenMasterInfo.gid
end

function MasterDlg:onIDoButton(sender, eventType)
    local panel = sender:getParent()
    if not panel.charInfo and not panel.charInfo.gid then return end

    local gid = panel.charInfo.gid
    if panel.charInfo.requestType == 4 then
        gf:confirm(string.format(CHS[4400005], panel.charInfo.name), function()
            MasterMgr:cmdIdoBecomeTeacher(gid, true)
        end)
    elseif panel.charInfo.requestType == 3 then
        gf:confirm(string.format(CHS[4400006], panel.charInfo.name), function()
            MasterMgr:cmdIdoBecomeStudent(gid, true)
        end)
    end
end

function MasterDlg:onRefusedButton(sender, eventType)
    local items = self.applyListView:getItems()
    if #items == 0 then return end

    for i = 1, #items do
        local panel = items[i]
        if panel.charInfo.requestType == 4 then
            MasterMgr:cmdIRefusedBecomeTeacher(panel.charInfo.gid)
        else
            MasterMgr:cmdIRefusedBecomeStudent(panel.charInfo.gid)
        end
    end

    self:setListViewTop("ApplyListView", nil, 0, true)
    self:resetListView("ApplyListView")
    local listInfo = MasterMgr:getApplyInfo()
    local memberList = self:getListByCount("ApplyListView", listInfo, PER_PAGE_COUNT)
    self:pushApplyData(memberList)

    self:onChosenApplyPanel()
end

function MasterDlg:onApplyButton(sender, eventType)
    if not self.chosenMasterInfo then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    if not self:generalCondition() then
        return
    end
    local dlg = DlgMgr:openDlg("MessageDlg")
    if self:getDisplayType() == DISPLAY_TYPE.MASTER then
        dlg:setDisplay(4, self.chosenMasterInfo)
    elseif self:getDisplayType() == DISPLAY_TYPE.STUDENT then
        dlg:setDisplay(3, self.chosenMasterInfo)
    end
end

function MasterDlg:onCancelButton(sender, eventType)
    --if not self.chosenApplyInfo then return end
    local panel = sender:getParent()
    if not panel.charInfo or not panel.charInfo.gid then return end
    if panel.charInfo.requestType == 4 then
        MasterMgr:cmdIRefusedBecomeTeacher(panel.charInfo.gid, true)
    else
        MasterMgr:cmdIRefusedBecomeStudent(panel.charInfo.gid, true)
    end

    -- 删除该项
    local requestInfo = FriendMgr.requestInfo
    if requestInfo and requestInfo.requestDlg == self.name and requestInfo.gid == panel.charInfo.gid then
        FriendMgr:unrequestCharMenuInfo(self.name)
        self.onCharInfo = nil
    end
    self.applyListView:removeChild(panel)

    -- 改变后面项颜色
    local items = self.applyListView:getItems()
    local height = self.applyInfoPanel:getContentSize().height
    local contentSize = self.applyListView:getInnerContainerSize()
    contentSize.height = height * #items
    self.applyListView:setInnerContainerSize(contentSize)
    for i = 1, #items do
        self:setCtrlVisible("BackImage_2", (i % 2 == 1), items[i])
    end

    -- 如果个数少于7，加载新项目
    items = self.applyListView:getItems()
    if #items < 7 then
        local listInfo = MasterMgr:getApplyInfo()
        local memberList = self:getListByCount("ApplyListView", listInfo, PER_PAGE_COUNT)
        self:pushApplyData(memberList)
    end
    self:onChosenApplyPanel()
end

function MasterDlg:onApplyInteractiveButton(sender, eventType)
    if not self.chosenApplyInfo then return end

    self.onCharInfo = function(self, gid)
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            dlg:setting(gid)
            local rect = self:getBoundingBoxInWorldSpace(sender)
            dlg:setFloatingFramePos(rect)
        end
    end

    FriendMgr:requestCharMenuInfo(self.chosenApplyInfo.gid, self.name)
end


function MasterDlg:onInteractiveButton(sender, eventType)
    if not self.chosenMasterInfo then return end
    local panel = sender:getParent()
    if not panel.charInfo or not panel.charInfo.gid then return end

    self.onCharInfo = function(self, gid)
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        if dlg then
            dlg:setting(gid)
            local rect = self:getBoundingBoxInWorldSpace(sender)
            dlg:setFloatingFramePos(rect)
        end
    end

    FriendMgr:requestCharMenuInfo(panel.charInfo.gid, self.name)
end

function MasterDlg:onRefreshButton(sender, eventType)
    local isCanRefreash = true
    if self:getDisplayType() == DISPLAY_TYPE.MASTER then
        isCanRefreash = MasterMgr:searchTeacherList()
    elseif self:getDisplayType() == DISPLAY_TYPE.STUDENT then
        isCanRefreash = MasterMgr:searchStudentList()
    elseif self:getDisplayType() == DISPLAY_TYPE.APPLY then
        isCanRefreash = MasterMgr:searchApplyList()
    end

    if not isCanRefreash then
        gf:ShowSmallTips(CHS[4100149])
        return
    end
    -- 如果时间间隔不到，没有发送刷新请求，则不刷新
    self:setListViewTop("ApplyListView", nil, 0, true)
    self:resetListView("ApplyListView")
    self:setListViewTop("MasterListView", nil, 0, true)
    self:resetListView("MasterListView")
    self.applyListStart = 0
end

function MasterDlg:generalConditionLooking(isLookingForTeacher)
    if isLookingForTeacher then
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        -- 战斗中
        if GameMgr.inCombat then
            gf:ShowSmallTips(CHS[3002257])
            return
        end

        -- 删除角色
        if 1 == Me:queryBasicInt("to_be_deleted") then
            -- [4100130] = "你正在删除角色过程中，无法拜师。",
            gf:ShowSmallTips(CHS[4100130])
            return
        end

        if MasterMgr:isMaster() then
            gf:ShowSmallTips(CHS[6000589])
            return
        end

        -- 玩家等级
        if Me:queryBasicInt("level") >= MasterMgr:getBeMasterLevel() then
            -- [4100131] = "当前角色等级大于等于%d级，无法拜师。",
            gf:ShowSmallTips(string.format(CHS[4100131], MasterMgr:getBeMasterLevel()))
            return
        end

        if Me:queryBasicInt("level") < MasterMgr:getMinMasterLevel() then
            gf:ShowSmallTips(string.format(CHS[5110002], MasterMgr:getMinMasterLevel()))
            return
        end

        --[[ 玩家已经有师傅
        if MasterMgr:meHasTeacher() then
            -- [4100132] = "你已经有师父了，不能再拜师了。",
            gf:ShowSmallTips(CHS[4100132])
            return
        end
        --]]

        if MasterMgr:meIsChuShi() then
            gf:ShowSmallTips(CHS[4200434])    -- 你已经出过师了，不能再拜师了。
            return
        end
    else
    end

    return true
end

-- 我要寻师
function MasterDlg:onCheckButton(sender, eventType)
    self:removeArmatureMagicFromCtrl("CheckButton", Const.ARMATURE_MAGIC_TAG, "MasterPanel")

    if MasterMgr.lookingForTMsg and MasterMgr.lookingForTMsg.isRegist == 1 then
        local dlg = DlgMgr:openDlg("MessageDlg")
        dlg:setDisplay(6)
        return
    end

    if not self:generalConditionLooking(true) then
        return
    end

    -- TMD终于可以了
    local dlg = DlgMgr:openDlg("MessageDlg")
    dlg:setDisplay(1)
end

function MasterDlg:generalCondition()

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 战斗中
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002257])
        return
    end

    -- 删除角色
    if 1 == Me:queryBasicInt("to_be_deleted") then
        gf:ShowSmallTips(CHS[4100130])
        return
    end

    if self:getDisplayType() == DISPLAY_TYPE.MASTER then
        if not self.chosenMasterInfo then return end
        if self.chosenMasterInfo.name == Me:getName() then
            -- [4100133] = "你不能拜自己为师。",
            gf:ShowSmallTips(CHS[4100133])
            return
        end

        if MasterMgr:isMaster() then
            gf:ShowSmallTips(CHS[6000589])
            return
        end

        if self.chosenMasterInfo.isApply == 1 then
            -- "你已向#Y%s#n提交过拜师申请了，请耐心等待。",
            gf:ShowSmallTips(string.format(CHS[4100134], self.chosenMasterInfo.name))
            return
        end

        --[[ 玩家已经有师傅
        if MasterMgr:meHasTeacher() then
            gf:ShowSmallTips(CHS[4100132])
            return
        end
        --]]

        if MasterMgr:meIsChuShi() then
            gf:ShowSmallTips(CHS[4200434])
            return
        end

        -- 玩家等级
        if Me:queryBasicInt("level") >= MasterMgr:getBeMasterLevel() then
            gf:ShowSmallTips(string.format(CHS[4100131], MasterMgr:getBeMasterLevel()))
            return
        end

        if Me:queryBasicInt("level") < MasterMgr:getMinMasterLevel() then
            gf:ShowSmallTips(string.format(CHS[5110001], MasterMgr:getMinMasterLevel()))
            return
        end

        -- 夫妻

        -- 黑名单
        if FriendMgr:isBlackByGId(self.chosenMasterInfo.gid) then
            gf:ShowSmallTips(string.format(CHS[4100135], self.chosenMasterInfo.name))
            return
        end
    else
        -- 玩家等级 写死72，不能用 MasterMgr:getBeMasterLevel()代替
        if Me:queryBasicInt("level") < 72 then
            -- [4100136] = "当前角色等级小于%d级，无法收徒。",
            gf:ShowSmallTips(string.format(CHS[4100136], 72))
            return
        end

        -- 对应玩家等级
        if self.chosenMasterInfo and self.chosenMasterInfo.level >= MasterMgr:getBeMasterLevel() then
            gf:ShowSmallTips(string.format(CHS[4200435], self.chosenMasterInfo.name))
            return
        end
    end

    return true
end

function MasterDlg:onCheckButton_1(sender, eventType)
    self:removeArmatureMagicFromCtrl("CheckButton_1", Const.ARMATURE_MAGIC_TAG, "MasterPanel")

    if MasterMgr.lookingForSMsg and MasterMgr.lookingForSMsg.isRegist == 1 then
        local dlg = DlgMgr:openDlg("MessageDlg")
        dlg:setDisplay(7)
        return
    end

    if not self:generalCondition() then return end
    local dlg = DlgMgr:openDlg("MessageDlg")
    if self:getDisplayType() == DISPLAY_TYPE.MASTER then
        dlg:setDisplay(1)
    elseif self:getDisplayType() == DISPLAY_TYPE.STUDENT then
        dlg:setDisplay(2)
    end
end

function MasterDlg:onApplyCommunionButton(sender, eventType)
    if not self.chosenApplyInfo then return end
    self:onCommunion(self.chosenApplyInfo)
end

function MasterDlg:onCommunionButton(sender, eventType)
    if not self.chosenMasterInfo then return end
    self:onCommunion(self.chosenMasterInfo)
end

function MasterDlg:onCommunion(data)
    if Me:getName() == data["name"] then
        gf:ShowSmallTips(CHS[4100148])
        return
    end

    local info = self.masterCharInfo[data["gid"]]
    if info  then
        FriendMgr:communicat(info.name, info.gid, info.icon, info.level)
    else
        FriendMgr:requestCharMenuInfo(data["gid"], nil, "MasterDlg", 1)
        self.communicatGid = data["gid"]
    end
end

function MasterDlg:MSG_CHAR_INFO_EX(data)
    if data.msg_type ~= "MasterDlg" or self.communicatGid ~= data.gid then
        return
    end

    self.masterCharInfo[data.gid] = data
    self.communicatGid = nil
    FriendMgr:communicat(data.name, data.gid, data.icon, data.level)
end

function MasterDlg:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

function MasterDlg:MSG_SEARCH_MASTER_INFO(data)
    if self:getDisplayType() ~= DISPLAY_TYPE.MASTER then return end
    self:setTeacherList()
end

function MasterDlg:MSG_SEARCH_APPRENTICE_INFO(data)
    if self:getDisplayType() ~= DISPLAY_TYPE.STUDENT then return end
    self:setStudentList()
end

function MasterDlg:MSG_REQUEST_APPENTICE_INFO(data)
    if self:getDisplayType() ~= DISPLAY_TYPE.APPLY then return end
    self:setApplyList()
end

function MasterDlg:MSG_CHAR_INFO(data)
    if not self.chosenMasterInfo then return end
    if self.addFriendGid == data.gid then
        -- 尝试加为好友
        FriendMgr:tryToAddFriend(data.name, data.gid, Bitset.new(data.setting_flag))
        self.addFriendGid = nil
    end
end

function MasterDlg:MSG_REQUEST_APPRENTICE_SUCCESS(data)
    if not self.chosenMasterInfo then return end
    local items = self.masterListView:getItems()
    for i, panel in pairs(items) do
        if panel.charInfo and panel.charInfo.gid == data.gid then
            self:setMasterListSingelPanel(panel)
        end
    end
end

function MasterDlg:MSG_MY_SEARCH_MASTER_MESSAGE(data)
    local panel = self:getControl("MasterPanel")
    local btn = self:getControl("CheckButton", nil, panel)
    if MasterMgr.lookingForTMsg and MasterMgr.lookingForTMsg.isRegist == 1 then
        -- [4100137] = "撤销留言",
        self:setLabelText("Label_1", CHS[4100137], btn)
        self:setLabelText("Label_2", CHS[4100137], btn)
    else
        -- [4200083] = "我要寻师",
        self:setLabelText("Label_1", CHS[4200083], btn)
        self:setLabelText("Label_2", CHS[4200083], btn)
    end
end

function MasterDlg:MSG_MY_SEARCH_APPRENTICE_MESSAGE(data)
    local panel = self:getControl("MasterPanel")
    local btn = self:getControl("CheckButton_1", nil, panel)
    if MasterMgr.lookingForSMsg and MasterMgr.lookingForSMsg.isRegist == 1 then
        -- [4100137] = "撤销留言",
        self:setLabelText("Label_1", CHS[4100137], btn)
        self:setLabelText("Label_2", CHS[4100137], btn)
    else
        -- [4200084] = "我要寻徒",
        self:setLabelText("Label_1", CHS[4200084], btn)
        self:setLabelText("Label_2", CHS[4200084], btn)
    end
end

function MasterDlg:MSG_NOTIFY_RECORD_APPRENTICE(data)
    if data.type == 0 then
        self.radioGroup:setSetlctByName(MASTER_CHECKBOS[2])
    else
        self.radioGroup:setSetlctByName(MASTER_CHECKBOS[1])
    end
end

function MasterDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    gf:ShowSmallTips(CHS[7002017])
end

return MasterDlg
