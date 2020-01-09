-- FightCommanderCmdEditDlg.lua
-- Created by lixh Des/11/2018
-- 战斗指挥指令编辑界面

local FightCommanderCmdEditDlg = Singleton("FightCommanderCmdEditDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local RADIO_BUTTON = {"EnemyButton", "MeButton"}

-- 指令类型：敌方，友方
local COMMAND_TYPE = FightCommanderCmdMgr:getCommandTypeCfg()

-- 指令最大数量
local MAX_COMMAND_COUNT = 10

function FightCommanderCmdEditDlg:init()
    self.listView = self:getControl("ListView")

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItemsByButton(self, RADIO_BUTTON, self.onRadioButton)

    self.itemPanel = self:retainCtrl("ItemPanel")
    self.selectImage = self:retainCtrl("SelectImage")

    self:bindListener("ConfrimButton", self.onConfrimButton)

    FightCommanderCmdMgr:checkRequestExtraCommand()

    self:setDlgByType(COMMAND_TYPE.ENEMY)
end

-- 设置界面内容
function FightCommanderCmdEditDlg:setDlgByType(type)
    self.radioGroup:setSetlctButtonByName(RADIO_BUTTON[type])
    self:onRadioButton(self:getControl(RADIO_BUTTON[type]))
end

-- 刷新当前listView列表
function FightCommanderCmdEditDlg:refreshCommandList(type)
    if type and type ~= self.commandType then return end

    local isOpponent = self.commandType == COMMAND_TYPE.ENEMY
    local commandList = FightCommanderCmdMgr:getDefaultCommand(isOpponent)
    local extraList = FightCommanderCmdMgr:getExtraCommand(isOpponent)
    local defaultCommandCount = #commandList

    -- 先合并两张表，与策划确认，无需做去重操作
    for i = 1, #extraList do
        table.insert(commandList, extraList[i])
    end

    if #commandList < MAX_COMMAND_COUNT then
        -- 数量小于最大数量时，增加一个用来提示玩家新增
        table.insert(commandList, "")
    end

    self.listView:removeAllItems()
    local commandCount = #commandList
    local itemCount = math.ceil(commandCount / 2)
    for i = 1, itemCount do
        local itemPanel = self.itemPanel:clone()

        local index1 = (2 * i - 1)
        local itemPanel1 = itemPanel:getChildByName("ItemPanel1")
        self:setSingleItemInfo(itemPanel1, commandList[index1], index1 > defaultCommandCount, index1 - defaultCommandCount)

        local index2 = 2 * i
        local itemPanel2 = itemPanel:getChildByName("ItemPanel2")
        if commandList[index2] then
            self:setSingleItemInfo(itemPanel2, commandList[index2], index2 > defaultCommandCount, index2 - defaultCommandCount)
        else
            itemPanel2:setVisible(false)
        end

        self.listView:pushBackCustomItem(itemPanel)
    end
end

-- 设置单个控件内容
function FightCommanderCmdEditDlg:setSingleItemInfo(item, str, showChange, index)
    self:setLabelText("Label", str, item)
    if str == "" then
        self:setCtrlVisible("AddButton", true, item)
        self:setCtrlVisible("ChangeButton", false, item)

        self:bindTouchEventListener(self:getControl("AddButton", nil, item), self.onAddButton)
        self:bindTouchEventListener(item, self.onAddButton)
    else
        self:setCtrlVisible("AddButton", false, item)
        self:setCtrlVisible("ChangeButton", showChange, item)
        if showChange then
            local btn = self:getControl("ChangeButton", nil, item)
            btn.index = index
            item.index = index
            self:bindTouchEventListener(btn, self.onChangeButton)
            self:bindTouchEventListener(item, self.onChangeButton)
        end
    end
end

-- 修改某条指令
function FightCommanderCmdEditDlg:onChangeButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local label = sender:getChildByName("Label") or sender:getParent():getChildByName("Label")
        if label then
            local dlg = DlgMgr:openDlg("FightCommanderCmdInputDlg")
            local curText = label:getString()
            dlg:setData(curText, function(newText)
                if string.isNilOrEmpty(newText) then
                    if not string.isNilOrEmpty(curText) then
                        -- 移除指令类型列表index对应的指令
                        FightCommanderCmdMgr:requestEditExtraCommand(self.commandType == COMMAND_TYPE.ENEMY, sender.index, nil, "remove")
                    end
                elseif newText ~= curText then
                    -- 修改指令
                    label:setText(newText)
                    FightCommanderCmdMgr:requestEditExtraCommand(self.commandType == COMMAND_TYPE.ENEMY, sender.index, newText, "change")
                end
            end)
        end
    end
end

-- 新增指令
function FightCommanderCmdEditDlg:onAddButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local dlg = DlgMgr:openDlg("FightCommanderCmdInputDlg")
        dlg:setData(nil, function(para)
            -- 新增当前类型指令
            if not string.isNilOrEmpty(para) then
                FightCommanderCmdMgr:requestEditExtraCommand(self.commandType == COMMAND_TYPE.ENEMY, nil, para, "add")
            end
        end)
    end
end

function FightCommanderCmdEditDlg:onRadioButton(sender, eventType)
    local type
    if sender:getName() == "EnemyButton" then
        type = COMMAND_TYPE.ENEMY
        self:setCtrlVisible("EnemySelectImage", true)
        self:setCtrlVisible("MeImage", false)
    else
        type = COMMAND_TYPE.FRIENDS
        self:setCtrlVisible("EnemySelectImage", false)
        self:setCtrlVisible("MeImage", true)
    end

    if not self.commandType or self.commandType ~= type then
        self.commandType = type
        self:refreshCommandList()
    end
end

-- 重置默认指令
function FightCommanderCmdEditDlg:onConfrimButton(sender, eventType)
    FightCommanderCmdMgr:requestEditExtraCommand(self.commandType == COMMAND_TYPE.ENEMY, nil, nil, 'reset')
end

function FightCommanderCmdEditDlg:cleanup()
    self.commandType = nil
end

return FightCommanderCmdEditDlg
