-- FightCommanderSetDlg.lua
-- Created by lixh Des/11/2018
-- 战斗指挥指令设置界面

local FightCommanderSetDlg = Singleton("FightCommanderSetDlg", Dialog)

-- 指令类型：敌方，友方
local COMMAND_TYPE = FightCommanderCmdMgr:getCommandTypeCfg()

-- 操作类型：全部，指定目标
local OPER_TYPE = {
    ALL = 1,
    TARGET = 0,
}

function FightCommanderSetDlg:init()
    self:bindListener("DeleteAllButton", self.onDeleteAllButton)
    self:bindListener("DeleteButton", self.onDeleteButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("CommandButton", self.onCommandButton)

    self:setCtrlVisible("CommandButton", false)

    self.listView = self:getControl("ListView")
    self.itemPanel = self:retainCtrl("ItemPanel")

    FightCommanderCmdMgr:checkRequestExtraCommand()
end

-- 设置界面数据
function FightCommanderSetDlg:setData(data)
    self.objId = data.objId
    self.commandType = data.type
    self:refreshCommandList()

    local showCommandBtn = true
    if self.objId == Me:getId() or string.isNilOrEmpty(data.gid) then
        -- gid 为空的角色是npc或守护
        showCommandBtn = false
    end

    if showCommandBtn and Me:isTeamLeader() and TeamMgr:inTeam(self.objId) then
        -- 队长，点击队友时，需要根据当前队友是否是指挥显示，取消指挥、赋予指挥
        self:setCtrlVisible("CommandButton", true)
        local obj = TeamMgr:getMemberById(self.objId)
        if obj and obj.gid == FightCommanderCmdMgr.commanderGid then
            self:getControl("CommandButton"):setTitleText(CHS[7190419])
        else
            self:getControl("CommandButton"):setTitleText(CHS[7190418])
        end
    end
end

-- 刷新当前listView列表
function FightCommanderSetDlg:refreshCommandList(type)
    if type and type ~= self.commandType then return end

    local isOpponent = self.commandType == COMMAND_TYPE.ENEMY
    local commandList = FightCommanderCmdMgr:getDefaultCommand(isOpponent)
    local extraList = FightCommanderCmdMgr:getExtraCommand(isOpponent)

    -- 先合并两张表，与策划确认，无需做去重操作
    for i = 1, #extraList do
        table.insert(commandList, extraList[i])
    end

    self.listView:removeAllItems()
    local commandCount = #commandList
    local itemCount = math.ceil(commandCount / 2)
    for i = 1, itemCount do
        local itemPanel = self.itemPanel:clone()

        local index1 = (2 * i - 1)
        local itemButton1 = itemPanel:getChildByName("ItemButton1")
        itemButton1:setTitleText(commandList[index1])
        self:bindTouchEventListener(itemButton1, self.onSelectCommandButton)

        local index2 = 2 * i
        local itemButton2 = itemPanel:getChildByName("ItemButton2")
        if commandList[index2] then
            itemButton2:setTitleText(commandList[index2])
            self:bindTouchEventListener(itemButton2, self.onSelectCommandButton)
        else
            itemButton2:setVisible(false)
        end

        self.listView:pushBackCustomItem(itemPanel)
    end
end

-- 选择指挥指令
function FightCommanderSetDlg:onSelectCommandButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        if not self.objId then return end
        FightCommanderCmdMgr:requestSetObjectCommand(OPER_TYPE.TARGET, self.objId, sender:getTitleText())
        self:onCloseButton()
    end
end

-- 删除所有指挥指令
function FightCommanderSetDlg:onDeleteAllButton(sender, eventType)
    FightCommanderCmdMgr:requestSetObjectCommand(OPER_TYPE.ALL, self.commandType, "")
    self:onCloseButton()
end

-- 删除指定指令
function FightCommanderSetDlg:onDeleteButton(sender, eventType)
    if not self.objId then return end
    FightCommanderCmdMgr:requestSetObjectCommand(OPER_TYPE.TARGET, self.objId, "")
    self:onCloseButton()
end

-- 新增指令
function FightCommanderSetDlg:onAddButton(sender, eventType)
    local dlg = DlgMgr:openDlg("FightCommanderCmdEditDlg")
    dlg:setDlgByType(self.commandType)
end

function FightCommanderSetDlg:onCommandButton(sender, eventType)
    -- 队长，需要根据当前对象是否是指挥显示，取消指挥、赋予指挥
    local obj = TeamMgr:getMemberById(self.objId)
    if not obj then
        -- 对象已经不存在，关闭界面不处理
        self:onCloseButton()
        return
    end

    if obj.gid == FightCommanderCmdMgr.commanderGid then
        -- 已经是指挥，取消权限
        FightCommanderCmdMgr:requestSetCommander(obj.gid, 0)
    else
        -- 不是指挥，赋予权限
        FightCommanderCmdMgr:requestSetCommander(obj.gid, 1)
    end

    self:onCloseButton()
end

function FightCommanderSetDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg("CombatStatusDlg")
    DlgMgr:closeDlg(self.name)
end

function FightCommanderSetDlg:cleanup()
    self.objId = nil
    self.commandType = nil
end

return FightCommanderSetDlg
