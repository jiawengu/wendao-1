-- DugeonCreateDlg.lua
-- Created by Mar/11/2015
-- 副本创建界面

local DugeonCreateDlg = Singleton("DugeonCreateDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local MAX_DUGEON = 4

function DugeonCreateDlg:init()
    for i = 1, MAX_DUGEON do
        local buttonPanel = self:getControl("DungeonPanel_" .. i)

        if buttonPanel then
            local button = self:getControl("CreateButton", nil, buttonPanel)
            button:setTag(i)
            self:bindListener("CreateButton", self.onCreateButton, buttonPanel)
        end
    end

    self:bindListener("CreateButton", self.onCreateHardButton, "HardMainBodyPanel")

    self.checkBoxs = {"NomalCheckBox", "HardCheckBox"}
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, self.checkBoxs, self.onCheckBox)
    self.radioGroup:selectRadio(1)

    local scrollView = self:getControl("ScrollView")
    local inner = self:getControl("DungeonPanel")
    scrollView:setInnerContainerSize(inner:getContentSize())
    inner:requestDoLayout()
    scrollView:requestDoLayout()

    self:bindListener("NoteButton", self.onNoteButton, "MainBodyPanel")
    self:bindListener("NoteButton", self.onNoteButton, "HardMainBodyPanel")
    MessageMgr:regist("MSG_DUNGEON_LIST", DugeonCreateDlg)
    self:setDugeonInfo()
end

function DugeonCreateDlg:setDugeonInfo()
    -- 设置副本信息
    for i = 1, MAX_DUGEON do
        local dugeonInfo = DugeonMgr:getDugeonInfoByIndex(i)
        local dugeonPanel = self:getControl("DungeonPanel_" .. i)
        if dugeonPanel then
            self:setPortrait("MonsterPanel", dugeonInfo.icon, 0, dugeonPanel, true, nil, nil, cc.p(0, -65))
            self:setLabelText("NameLabel", dugeonInfo.name, dugeonPanel)
            self:setLabelText("ValueLabel", dugeonInfo.limitLevel .. CHS[3002384], dugeonPanel)
            self:setLabelText("DescLabel", dugeonInfo.introduce, dugeonPanel)
        end
    end

    -- tips
    local desPanel = self:getControl("DesPanel")
    self:setLabelText("NumLabel", DugeonMgr:getDugeonTips(), desPanel)

    if Me:queryInt("level") >= 110 then
        local scrCrl = self:getControl("ScrollView")
        local scrCrlInnSize = scrCrl:getInnerContainer():getContentSize()
        local scrCrlSize = scrCrl:getContentSize()
        local x = math.min(scrCrlSize.width - scrCrlInnSize.width, 0)
        scrCrl:getInnerContainer():setPositionX(x)
        scrCrl:requestDoLayout()
    end
end

-- 设置剩余奖励次数
function DugeonCreateDlg:setDugeonTime(times, root)
    local bonusPanel = self:getControl("BonusTimesPanel", nil, root)
    if times == 0 then
        self:setLabelText("ValueLabel", times, bonusPanel, COLOR3.RED)
    else
        self:setLabelText("ValueLabel", times, bonusPanel, COLOR3.TEXT_DEFAULT)
    end

end

function DugeonCreateDlg:setTitleText(str)
    self:setLabelText("TitleLabel_1", str, "BKPanel")
    self:setLabelText("TitleLabel_2", str, "BKPanel")
end

function DugeonCreateDlg:onCheckBox(sender)
    if sender:getName() == "NomalCheckBox" then
        self:setCtrlVisible("HardMainBodyPanel", false)
        self:setCtrlVisible("MainBodyPanel", true)

        self:setTitleText(CHS[5450311])
    else
        self:setCtrlVisible("HardMainBodyPanel", true)
        self:setCtrlVisible("MainBodyPanel", false)

        self:setTitleText(CHS[5450312])
    end

        -- 切换标签并且显示选中文字和非选中的文字
    for k , v  in pairs(self.checkBoxs) do
        local checkBox = self:getControl(v)
        if dlgName == v then
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
end

function DugeonCreateDlg:onCreateButton(sender, eventType)
    local index = sender:getTag()
    local name = DugeonMgr:getDugeonInfoByIndex(index).name
    DugeonMgr:createDugeon(name)
end

function DugeonCreateDlg:onCreateHardButton(sender, eventType)
    DugeonMgr:createDugeon(self.hardName)
end

function DugeonCreateDlg:onNoteButton(sender, eventType)
    local dlg = DlgMgr:openDlg("DugeonRuleDlg")
    dlg:setType("fuben")
end

function DugeonCreateDlg:MSG_DUNGEON_LIST(data)
    self:setDugeonTime(data.bonus, "MainBodyPanel")
    self:setDugeonTime(data.bonus, "HardMainBodyPanel")

    self:setLabelText("NameLabel", string.match(data.hard_name, CHS[5450309]), "HardMainBodyPanel")

    self.hardName = data.hard_name
end

return DugeonCreateDlg
