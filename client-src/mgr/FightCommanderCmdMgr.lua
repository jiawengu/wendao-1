-- FightCommanderCmdMgr.lua
-- created by lixh2 Dec/11/2018
-- 战斗指挥管理器

FightCommanderCmdMgr = Singleton()

-- 敌方默认指令
local OPPONENT_DEFAULT_COMMAND = {
    CHS[7190403], -- 物攻
    CHS[7190404], -- 法攻
    CHS[7190405], -- 集火
    CHS[7190406], -- 障碍
    CHS[7190407], -- 守尸
}

-- 友方默认指令
local FRIEND_DEFAULT_COMMAND = {
    CHS[7190408], -- 加血
    CHS[7190409], -- 加蓝
    CHS[7190410], -- 拉人
    CHS[7190411], -- 防御
    CHS[7190412], -- 逃跑
}

-- 指令编辑类型
local COMMAND_EDIT_TYPE = {
    OPPONENT = 1, -- 敌方
    FRIEND = 2,   -- 友方
    RESET = 3,    -- 重置
}

-- 指令类型：敌方，友方
local COMMAND_TYPE = {
    ENEMY = 1,
    FRIENDS = 2,
}

-- 玩家编辑的指令表
FightCommanderCmdMgr.opponentCommandList = {}
FightCommanderCmdMgr.friendCommandList = {}

-- 战斗指挥功能是否开启
function FightCommanderCmdMgr:isCommanderFuncOpen()
    return true
end

-- 检查是否需要请求指令数据
function FightCommanderCmdMgr:checkRequestExtraCommand()
    if not self.requestCommanderData then
        gf:CmdToServer("CMD_TEAM_COMMANDER_GET_CMD_LIST", {type = 0})
        self.requestCommanderData = true
    end
end

-- 获取指令类型配置
function FightCommanderCmdMgr:getCommandTypeCfg()
    return COMMAND_TYPE
end

-- 获取默认指令
function FightCommanderCmdMgr:getDefaultCommand(isOpponent)
    if isOpponent then
        return gf:deepCopy(OPPONENT_DEFAULT_COMMAND)
    end

    return gf:deepCopy(FRIEND_DEFAULT_COMMAND)
end

-- 获取额外的指令，玩家自己编辑的需要从服务器获取
function FightCommanderCmdMgr:getExtraCommand(isOpponent)
    if isOpponent then
        return self.opponentCommandList
    end

    return self.friendCommandList
end

-- 获取可以获得指挥权限的队员信息，过滤gid为空的队员
function FightCommanderCmdMgr:getTeamMembers()
    if not TeamMgr.members.count then return {count = 0} end

    local teamMembers = {}
    for i = 1, TeamMgr.members.count do
        if not string.isNilOrEmpty(TeamMgr.members[i].gid) then
            table.insert(teamMembers, TeamMgr.members[i])
        end
    end

    teamMembers.count = #teamMembers
    return teamMembers
end

-- 请求指定类型的指令数据
function FightCommanderCmdMgr:requestExtraCommand(type)
    gf:CmdToServer("CMD_TEAM_COMMANDER_GET_CMD_LIST", {type = type})
end

-- 请求编辑指定类型的指令
function FightCommanderCmdMgr:requestEditExtraCommand(isOpponent, index, command, oper)
    local list
    local function getCurList()
        if isOpponent then
            -- 敌方
            list = gf:deepCopy(self.opponentCommandList)
        else
            -- 友方
            list = gf:deepCopy(self.friendCommandList)
        end
    end

    if oper == 'reset' then
        -- 重置
        if isOpponent and #self.opponentCommandList == 0 or not isOpponent and #self.friendCommandList == 0 then
            -- 无自定义指令信息，无需恢复
            gf:ShowSmallTips(CHS[7100398])
            return
        end

        list = {}
        list.isReset = 1
    else
        getCurList()
        list.isReset = 0

        if oper == 'add' then
            -- 新增
            table.insert(list, command)
        elseif oper == 'remove' then
            -- 移除
            table.remove(list, index)
        elseif oper == 'change' then
            -- 编辑替换
            list[index] = command
        else
            return
        end
    end

    -- 数量
    list.count = #list

    -- 类型
    if isOpponent then
        list.type = COMMAND_EDIT_TYPE.OPPONENT
    else
        list.type = COMMAND_EDIT_TYPE.FRIEND
    end

    gf:CmdToServer("CMD_TEAM_COMMANDER_SET_CMD_LIST", list)
end

-- 请求设置指定类型的指令数据
function FightCommanderCmdMgr:requestSetObjectCommand(type, id, command)
    gf:CmdToServer("CMD_TEAM_COMMANDER_COMBAT_COMMAND", {toAll = type, id = id, command = command})
end

-- 队长分配指挥权限
function FightCommanderCmdMgr:requestSetCommander(gid, flag)
    if string.isNilOrEmpty(gid) then return end
    gf:CmdToServer("CMD_TEAM_COMMANDER_ASSIGN", {gid = gid, flag = flag})
end

-- 创建对象指令控件
function FightCommanderCmdMgr:createObjCommandPanel()
    if not self.commandPanel then
        local size = cc.size(114, 40)
        self.commandPanel = ccui.Layout:create()
        self.commandPanel:setContentSize(size)
        self.commandPanel:setBackGroundImage(ResMgr.ui.fight_command_tag_bg, ccui.TextureResType.localType)

        local label = ccui.Text:create()
        label:setColor(cc.c3b(229, 46, 107))
        label:ignoreContentAdaptWithSize(false)
        label:setContentSize(cc.size(100, 25))
        label:setPosition(cc.p(size.width / 2 + 6, size.height / 2 + 2))
        label:setFontSize(21)
        label:setName("TextLabel")
        label:setTextHorizontalAlignment(1)

        self.commandPanel:addChild(label)
        self.commandPanel:retain()
    end

    return self.commandPanel:clone()
end

-- 检查指导对象长按是否可以显示指挥界面
function FightCommanderCmdMgr:checkCanShowCommanderDlg(obj)
    if not self:isCommanderFuncOpen() or Me:isLookOn() then return false end
    if not obj then return false end

    if (TeamMgr.members.count and TeamMgr.members.count > 1)
        and (Me:isTeamLeader() or Me:queryBasic('gid') == self.commanderGid) then
        -- 队伍人数大于1, Me队长或是指挥，显示指挥界面

        local objId = obj:getId()
        local objGid = ""
        local teamMember = TeamMgr:getMemberById(objId)
        if teamMember then objGid = teamMember.gid end

        local dlg = DlgMgr:openDlg("FightCommanderSetDlg")
        dlg:setData({objId = objId, type = obj:getType() == "FightOpponent"
            and COMMAND_EDIT_TYPE.OPPONENT or COMMAND_EDIT_TYPE.FRIEND, gid = objGid})

        -- 战斗指挥界面出现时，需要将战斗指挥界面与战斗状态界面两者合在一起，居中屏幕
        local statusDlg = DlgMgr.dlgs["CombatStatusDlg"]
        local statusDlgSz = statusDlg.root:getContentSize()
        statusDlgSz.width = statusDlgSz.width * Const.UI_SCALE
        statusDlgSz.height = statusDlgSz.height * Const.UI_SCALE
        local commanderDlgSz = dlg.root:getContentSize()
        commanderDlgSz.width = commanderDlgSz.width * Const.UI_SCALE
        commanderDlgSz.height = commanderDlgSz.height * Const.UI_SCALE

        local x1 = (Const.WINSIZE.width - commanderDlgSz.width) / 2
        local x2 = x1 + (statusDlgSz.width + commanderDlgSz.width) / 2
        local y2 = Const.WINSIZE.height / 2
        local y1 = y2 + (commanderDlgSz.height - statusDlgSz.height) / 2

        statusDlg.root:setPosition(cc.p(x1, y1))
        dlg.root:setPosition(cc.p(x2, y2))

        return true
    end

    return false
end

-- 指定位置玩家是否可以委托指挥
function FightCommanderCmdMgr:checkCanGiveCommander(index)
    if not TeamMgr.members[index] or string.isNilOrEmpty(TeamMgr.members[index].gid)
        or self:isCommander(TeamMgr.members[index].gid) then
        -- 该位置队友不存在，或已经是指挥了
        return false
    end

    return true
end

-- gid对应玩家是否是指挥
function FightCommanderCmdMgr:isCommander(gid)
    if not string.isNilOrEmpty(self.commanderGid) and gid == self.commanderGid then
        return true
    end

    return false
end

function FightCommanderCmdMgr:clearData()
    self.requestCommanderData = nil
    self.friendCommandList = {}
    self.opponentCommandList = {}
    self.commanderGid = nil

    if self.commandPanel then
        self.commandPanel:release()
        self.commandPanel = nil
    end
end

-- 战斗指挥指令数据
function FightCommanderCmdMgr:MSG_TEAM_COMMANDER_CMD_LIST(data)
    local refreshDlg = true
    if data.type == COMMAND_EDIT_TYPE.OPPONENT then
        if #self.opponentCommandList == data.count then
            -- 数量不变，不必刷新界面
            refreshDlg = false
        end

        self.opponentCommandList = data.list
    elseif data.type == COMMAND_EDIT_TYPE.FRIEND then
        if #self.friendCommandList == data.count then
            -- 数量不变，不必刷新界面
            refreshDlg = false
        end

        self.friendCommandList = data.list
    end

    if refreshDlg then
        DlgMgr:sendMsg("FightCommanderCmdEditDlg", "refreshCommandList", data.type)
        DlgMgr:sendMsg("FightCommanderSetDlg", "refreshCommandList", data.type)
    end
end

-- 战斗指挥gid
function FightCommanderCmdMgr:MSG_TEAM_COMMANDER_GID(data)
    self.commanderGid = data.gid
    DlgMgr:sendMsg("TeamDlg", "refreshCommanderIcon")
    DlgMgr:sendMsg("TeamDlg", "refreshCommanderSelectPanel")
end

MessageMgr:regist("MSG_TEAM_COMMANDER_CMD_LIST", FightCommanderCmdMgr)
MessageMgr:regist("MSG_TEAM_COMMANDER_GID", FightCommanderCmdMgr)
