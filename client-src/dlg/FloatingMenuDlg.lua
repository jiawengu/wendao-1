-- FloatingMenuDlg.lua
-- Created by liuhb Apr/29/2015
-- 组队界面弹出框

local Bitset = require("core/Bitset")
local FloatingMenuDlg = Singleton("FloatingMenuDlg", Dialog)

local RIGHT_CTRL = {
    [1] = "",
    [2] = "",
    [4] = ""
}

local Margin = 3

local btnStrTable =
{
        [1] = {title = CHS[3002632], key = "chat"},                 -- 交流
        [2] = {title = CHS[3002633], key = "addFriend"},                -- 加为好友
        [3] = {title = CHS[3002634], key = "seeEquip"},         --查看装备
        [4] = {title = CHS[5400270], key = "openBlog"},         --查看空间
        [5] = {title = CHS[4100069], key = "changeCard"},       -- 使用变身卡
        [6] = {title = CHS[4200378], key = "jiuqu"},            -- 九曲
        [7] = {title = CHS[3002635], key = "leadTeam"},         -- 申请带队
        [8] = {title = CHS[3002636], key = "callTeam"},         -- 召集队友
        [9] = {title = CHS[3002637], key = "changeLeader"},     -- 升为队长
        [10] = {title = CHS[3002638], key = "leaveTeam"},       -- 请离队伍
        [11] = {title = CHS[6400093], key = "sendNotify"},      -- 发送提醒
        [12] = {title = CHS[7003021], key = "callAll"},         -- 一键召集
        [13] = {title = CHS[7190423], key = "commander"},       -- 指挥
}
local BUTTON_STR_COUNT = #btnStrTable

-- 队长点击队员弹出的按钮的优先级
local MEMBER_ORDER= {
    ["chat"]          = 6,
    ["addFriend"]     = 8,
    ["seeEquip"]      = 5,
    ["openBlog"]      = 9,
    ["changeCard"]    = 4,
    ["jiuqu"]         = 7,
    ["leadTeam"]      = 100,
    ["callTeam"]      = 100,
    ["changeLeader"]  = 1,
    ["leaveTeam"]     = 2,
    ["sendNotify"]    = 3,
    ["callAll"]       = 100,
    ["cancelCommander"]  = 100,
    ["setCommander"]     = 100,
}

-- 队长点击暂离、跨线暂离队员弹出的按钮的优先级
local MEMBEREX_ORDER= {
    ["chat"]          = 4,
    ["addFriend"]     = 6,
    ["seeEquip"]      = 5,
    ["openBlog"]      = 7,
    ["changeCard"]    = 100,
    ["jiuqu"]         = 100,
    ["leadTeam"]      = 100,
    ["callTeam"]      = 1,
    ["changeLeader"]  = 100,
    ["leaveTeam"]     = 2,
    ["sendNotify"]    = 3,
    ["callAll"]       = 100,
    ["cancelCommander"]  = 100,
    ["setCommander"]     = 100,
}

-- 队员点击队员(包括队长)弹出的按钮的优先级
local LEADER_ORDER = {
    ["chat"]          = 3,
    ["addFriend"]     = 7,
    ["seeEquip"]      = 4,
    ["openBlog"]      = 8,
    ["changeCard"]    = 5,
    ["jiuqu"]         = 6,
    ["leadTeam"]      = 1,
    ["callTeam"]      = 100,
    ["changeLeader"]  = 100,
    ["leaveTeam"]     = 100,
    ["sendNotify"]    = 2,
    ["callAll"]       = 100,
    ["cancelCommander"]  = 100,
    ["setCommander"]     = 100,
}

local max_button_num = 10 -- 菜单最多的操作按钮
local firendTag = 998

-- WDSY-35001 调整此界面最多显示按钮数量为5，超过时放到ListView中
local MAX_SHOW_NUM = 5
local MAX_SHOW_HEIGHT = 360

-- 记录对话框大小，防止双击出现尺寸错误
FloatingMenuDlg.dlgSize = nil
FloatingMenuDlg.mainPanelSize = nil

function FloatingMenuDlg:init()
    self.dlgSize = self.dlgSize or self.root:getContentSize()
    local mainPanel = self:getControl("MainPanel")
    self.mainPanelSize = self.mainPanelSize or mainPanel:getContentSize()
    self.curChar = nil
    self.listView = self:getControl("ListView")

    for i = 1, max_button_num do
        self:bindListener("MenuButton" .. i, self.onMenuButton)
    end

    self:hookMsg("MSG_LOOK_PLAYER_EQUIP")
    self:hookMsg("MSG_CHAR_INFO")
end

function FloatingMenuDlg:setData(member)
    if nil == member then return end
    self.member = member

    local btnList = self:getBtnListStr(member)
    local btnCount = #btnList
    local menuCtrl = self:getControl("MenuButton1")
    if nil == menuCtrl then
        -- 如果找不到，说明名字已经被改了，取不到了
        return
    end

    local btnContentSize = self:getControl("MenuButton1"):getContentSize()
    local btnStr = "MenuButton"

    for i = 1, max_button_num do
        local btnCStr = btnStr .. i

        if i <= btnCount then
            local btn = self:getControl(btnCStr)
            btn:setTitleText(btnList[i].title)
            btn:setName(btnList[i].key)

            -- WDSY-35001 调整此界面按钮放到ListView中
            btn:retain()
            btn:removeFromParent()
            self.listView:pushBackCustomItem(btn)
            btn:release()
        else
            self:getControl(btnCStr):removeFromParent()
        end
    end

    -- 设置ContentSize
    local height = (btnContentSize.height + Margin) * (max_button_num - btnCount)
    local width = self.root:getContentSize().width
    local panel = self:getControl("MainPanel")
    panel:setContentSize({width = panel:getContentSize().width, height = math.min(self.mainPanelSize.height - height, MAX_SHOW_HEIGHT)})
    self.root:setContentSize({width = width, height = math.min(self.dlgSize.height - height, MAX_SHOW_HEIGHT)})

    if btnCount <= MAX_SHOW_NUM then
        self.listView:setBounceEnabled(false)
    end

    -- 发送数据请求
    FriendMgr:requestCharMenuInfo(member.gid)

    if FriendMgr:hasFriend(member.gid) then
        self:setButtonText("addFriend", CHS[5000062])
    else
        self:setButtonText("addFriend", CHS[5000064])
    end
end

function FloatingMenuDlg:getBtnListStr(member)
     -- 首先判断是否是队长
    local isLeader = TeamMgr:getLeaderId() == Me:queryBasicInt("id")
    local btnList = {}
    if isLeader and self.member.id == Me:getId() then
        -- 队长点击自己，仅有一键召集
        table.insert(btnList, btnStrTable[12])
        return btnList
    end

     for i = 1, BUTTON_STR_COUNT do
        if not isLeader then -- 队员的点击操作
            if i < 5 then -- 对象时队员的菜单
                table.insert(btnList, btnStrTable[i])
            elseif btnStrTable[i].title == CHS[4200378] or btnStrTable[i].title == CHS[4100069] then
                -- 点击暂离队员时或自己暂离时，不能使用九曲玲珑笔和变身卡
                if not TeamMgr:isLeaveTemp(self.member.id) and not TeamMgr:isOverlineLeaveTemp(self.member.id) and not TeamMgr:isLeaveTemp(Me:getId()) and not TeamMgr:isOverlineLeaveTemp(Me:getId()) then
                    table.insert(btnList, btnStrTable[i])
                end
            elseif btnStrTable[i].title == CHS[3002635] and self.member.id == TeamMgr:getLeaderId() then -- 点击队长添加申请带队
                table.insert(btnList, btnStrTable[i])
            elseif btnStrTable[i].title == CHS[6400093] and gf:gfIsFuncEnabled(FUNCTION_ID.VIBRATE) then -- 震动提示
                table.insert(btnList, btnStrTable[i])
            end
        else -- 队长操作菜单
            if btnStrTable[i].title == CHS[3002635] then
                -- 队长的操作菜单中没有申请带队
            elseif btnStrTable[i].title == CHS[6400093] then -- 震动提示
                -- 对于有else分支的项，应放在里面单独判断，否则可能出现在else分支中成立的情况（elseif分支也有可能）
                if gf:gfIsFuncEnabled(FUNCTION_ID.VIBRATE) then
                    table.insert(btnList, btnStrTable[i])
                end
            elseif TeamMgr:isLeaveTemp(self.member.id) or TeamMgr:isOverlineLeaveTemp(self.member.id ) then -- 操作的是暂离队员
                -- 没有提升队长、申请带队、九曲玲珑笔和使用变身卡、指挥、一键召集操作
                if btnStrTable[i].title ~= CHS[3002637] and btnStrTable[i].title ~= CHS[4200378]
                        and btnStrTable[i].title ~= CHS[4100069] and btnStrTable[i].title ~= CHS[7190423]
                        and btnStrTable[i].title ~= CHS[7003021] then
                    table.insert(btnList, btnStrTable[i])
                end
            elseif btnStrTable[i].title == CHS[7190423] then
                -- 指挥
                if FightCommanderCmdMgr:isCommanderFuncOpen() then
                    if FightCommanderCmdMgr:isCommander(self.member.gid) then
                        -- 当前选择队员是指挥，显示取消指挥
                        table.insert(btnList, {title = CHS[7190419], key = "cancelCommander"})
                    else
                        -- 当前选择队员不是指挥，显示委任指挥
                        table.insert(btnList, {title = CHS[7190422], key = "setCommander"})
                    end
                end
            elseif i ~= 12 then
                -- 一键召集不处理, 操作的不是暂离队员
                if btnStrTable[i].title ~= CHS[3002636] then -- 没有召集队友操作
                    table.insert(btnList, btnStrTable[i])
                end
            end
        end
     end

    local zorder
    if Me:isTeamLeader() then
        if TeamMgr:isLeaveTemp(self.member.id) or TeamMgr:isOverlineLeaveTemp(self.member.id ) then
            zorder = MEMBEREX_ORDER
        else
            zorder = MEMBER_ORDER
        end
    else
        zorder = LEADER_ORDER
    end

    if zorder then
        table.sort(btnList, function(l, r)
            if not zorder[l.key] then return false end
            if not zorder[r.key] then return true end
            if zorder[l.key] < zorder[r.key] then return true end
        end)
    end

    return btnList
end

function FloatingMenuDlg:setIndex(idx, boundingBox)
    self:setCtrlVisible("PointImage_0", false)
    local worldPos
    if idx < 3 then
        -- 在控件的右侧
        self.root:setAnchorPoint(0, 1)
        worldPos = cc.p(boundingBox.x + boundingBox.width, boundingBox.y + boundingBox.height / 2)
    else
        -- 在控件的左侧
        self.root:setAnchorPoint(1, 1)
        worldPos = cc.p(boundingBox.x, boundingBox.y + boundingBox.height / 2)
    end

    self.root:setPosition(self.root:getParent():convertToNodeSpace(worldPos))

    -- 统一用世界坐标换算
    local mainPanelBoundingBox = self:getBoundingBoxInWorldSpace(self:getControl("MainPanel"))
    local curPos = self.root:convertToWorldSpace(cc.p(0, 0))
    if curPos.y < mainPanelBoundingBox.height then
        local pos
        if mainPanelBoundingBox.height + 20 <= self:getWinSize().height then
            pos = self.root:getParent():convertToNodeSpace(cc.p(self.root:getPositionX(), mainPanelBoundingBox.height + 20))
        else
            pos = self.root:getParent():convertToNodeSpace(cc.p(self.root:getPositionX(), self:getWinSize().height))
        end

        self.root:setPositionY(pos.y)
    end
end

-- 从任务面板打开悬浮的位置，需要显示箭头
-- touchRect 是箭头的世界坐标位置
-- starRect 是第1个队友头像的世界坐标位置
function FloatingMenuDlg:adjustPos(touchRect, starRect)
    self:setCtrlVisible("PointImage_0", true)
    local pointImage = self:getControl("PointImage_0")
    local rootBoundingBox = self:getBoundingBoxInWorldSpace(self.root)
    local pointImgBoundingBox = self:getBoundingBoxInWorldSpace(pointImage)
    self.root:setAnchorPoint(0.5, 0.5)

    local ccp = {x = starRect.x - rootBoundingBox.width * 0.5 - pointImgBoundingBox.width,
        y = starRect.y - rootBoundingBox.height * 0.5 + starRect.height}
    if ccp.y < rootBoundingBox.height * 0.5 + self:getWinSize().oy then
        local targetY = rootBoundingBox.height / 2 + 25 + self:getWinSize().oy
        if rootBoundingBox.height + 25 + self:getWinSize().oy > self:getWinSize().height then
            -- +25像素后超框，则直接设置界面上边界为屏幕高度
            ccp.y = self:getWinSize().height - rootBoundingBox.height / 2
        else
            ccp.y = targetY
        end
    end

    ccp = self.root:getParent():convertToNodeSpace(ccp)
    self.root:setPosition(ccp)
    local pt = self.root:convertToNodeSpace(cc.p(touchRect.x, touchRect.y + touchRect.height / 2))
    pointImage:setPositionY(pt.y)
end

function FloatingMenuDlg:onMenuButton1(sender, eventType)
    FriendMgr:communicat(self.member.name, self.member.gid, self.member.icon, self.member.level)

    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:onMenuButton2(sender, eventType)
    if not self.curChar or not self.curChar.name then return end

    local name = self.curChar.name
    if FriendMgr:hasFriend(self.curChar.gid) then
        -- 如果已经是己方好友
        local str = string.format(CHS[5000060], name)
        gf:confirm(str, function()
            FriendMgr:deleteFriend(name, self.curChar.gid)
        end)
    else
        -- 如果都没有设置，则直接添加好友
        FriendMgr:addFriend(name)
    end

    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:onMenuButton3(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.member.gid)
end

function FloatingMenuDlg:onMenuButton4(sender, eventType)
    if not Me:isTeamLeader() or not TeamMgr.selectMember then return end

    local member = TeamMgr.selectMember
    gf:CmdToServer("CMD_OPER_TELEPORT_ITEM", {oper = Const.TRY_RECRUIT, id = member.id, para2 = member.gid})
    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:onMenuButton5(sender, eventType)
    if Me:isPassiveMode() or
        not Me:isTeamLeader() or
        self.member == nil then
        return
    end

    local member = self.member
    if member == nil then return end

    local name = member.name
    -- 自己是队长
    if name == Me:getName() then return end

    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002639])
        return
    elseif Me:isLookOn() then
        gf:ShowSmallTips(CHS[3002640])
        return
    end

    if TaskMgr:isInTaskBKTX(6) then
        gf:ShowSmallTips(CHS[4010228])
        return
    end

    local function onConfirm()
        -- 发送升为队长命令给服务器
        gf:CmdToServer("CMD_CHANGE_TEAM_LEADER", {
            new_leader_id = member.id,
        })
    end
    local tip = string.format(CHS[1003780], name)
    gf:confirm(tip,onConfirm)

    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:onMenuButton6(sender, eventType)
    if Me:isPassiveMode() or
        not Me:isTeamLeader() or
        self.member == nil then
        return
    end

    local member = self.member
    if member == nil then return end

    local name = member.name
    -- 自己是队长
    if name == Me:getName() then return end

    gf:confirm(string.format(CHS[6800001], name), function()
        -- 发送剔除命令给服务器
        gf:CmdToServer("CMD_KICKOUT", {
            peer_name = name,
        })
    end)

    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:requireTobeLeader(sender, eventType)
    local myId = Me:getId()
    if TeamMgr:inTeamEx(myId) and not TeamMgr:inTeam(myId)  then
        gf:ShowSmallTips(CHS[3002641])
        return
    elseif GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002639])
        return
    elseif Me:isLookOn() then
        gf:ShowSmallTips(CHS[3002640])
        return
    end

    gf:CmdToServer("CMD_REQUEST_JOIN", {
        peer_name = self.member.name,
        ask_type = Const.REQUEST_TEAM_LEADER,
    })

    DlgMgr:closeDlg(self.name)
end

function FloatingMenuDlg:onMenuButton(sender, eventType)
    local name = sender:getName()
    if name == "chat" then
        self:onMenuButton1(sender,eventType)
    elseif name == "addFriend" then
        self:onMenuButton2(sender,eventType)
    elseif name == "seeEquip" then
        self:onMenuButton3(sender,eventType)
    elseif name == "leadTeam" then
        self:requireTobeLeader(sender,eventType)
    elseif name == "callTeam" then
        self:onMenuButton4(sender,eventType)
    elseif name == "changeLeader" then
        self:onMenuButton5(sender,eventType)
    elseif name == "leaveTeam" then
        self:onMenuButton6(sender,eventType)
    elseif name == "changeCard" then
        self:onChangeCard(sender,eventType)
    elseif name == "sendNotify" then
        self:onSendNotify(sender,eventType)
    elseif name == "callAll" then
        self:onCallAll(sender, eventType)
    elseif name == "jiuqu" then
        self:onJiuqu(sender, eventType)
    elseif name == "openBlog" then
        self:onOpenBlog()
    elseif name == "cancelCommander" then
        FightCommanderCmdMgr:requestSetCommander(self.member.gid, 0)
        self:onCloseButton()
    elseif name == "setCommander" then
        FightCommanderCmdMgr:requestSetCommander(self.member.gid, 1)
        self:onCloseButton()
    end
end

function FloatingMenuDlg:onJiuqu(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003759])
        self:onCloseButton()
        return
    end

    if TeamMgr:isLeaveTemp(Me:getId()) then
        gf:ShowSmallTips(CHS[4000398])
        return
    end

    if TeamMgr:isLeaveTemp(self.member.id) then
        gf:ShowSmallTips(CHS[4000399])
        return
    end

    if TeamMgr:isOverlineLeaveTemp(Me:getId()) then
        gf:ShowSmallTips(CHS[4000398])
        return
    end

    if TeamMgr:isOverlineLeaveTemp(self.member.id) then
        gf:ShowSmallTips(CHS[4000399])
        return
    end

    local amount = InventoryMgr:getAmountByName(CHS[4200378])
    if amount <= 0 then
        gf:ShowSmallTips(CHS[4200379])
        return
    end

    local dlg = DlgMgr:openDlg("ShapePenDlg")
    dlg:setListData(self.member)
    local rect = self:getBoundingBoxInWorldSpace(self.root)
    dlg:setPositionByRect(rect)
end


function FloatingMenuDlg:onCallAll(sender, eventType)
    TeamMgr:callAll()
    self:close()
end

function FloatingMenuDlg:onChangeCard(sender, eventType)
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[5000079])
        return
    end

    if TeamMgr:isLeaveTemp(Me:getId()) then
        gf:ShowSmallTips(CHS[4000398])
        return
    end

    if TeamMgr:isLeaveTemp(self.member.id) then
        gf:ShowSmallTips(CHS[4000399])
        return
    end

    if TeamMgr:isOverlineLeaveTemp(Me:getId()) then
        gf:ShowSmallTips(CHS[4000398])
        return
    end

    if TeamMgr:isOverlineLeaveTemp(self.member.id) then
        gf:ShowSmallTips(CHS[4000399])
        return
    end

    -- 身上变身卡数量判断
    local cardTao = StoreMgr:getChangeCard()
    local cardBag = InventoryMgr:getChangeCard()
    if #cardTao + #cardBag == 0 then
        gf:ShowSmallTips(CHS[4200380])
        return
    end

    local dlg = DlgMgr:openDlg("TeamChangeCardMenuDlg")
    dlg:setPlayer(self.member)
end

-- 查看空间
function FloatingMenuDlg:onOpenBlog()
    BlogMgr:openBlog(self.member.gid)
    self:onCloseButton()
end


-- 查看界面返回数据
function FloatingMenuDlg:MSG_LOOK_PLAYER_EQUIP(data)
    self:onCloseButton()
end

function FloatingMenuDlg:onSendNotify()
    VibrateMgr:sendVibrate("team", self.member.gid)
end

function FloatingMenuDlg:MSG_CHAR_INFO(data)
    self.curChar = data
    self.curChar.settingFlag = Bitset.new(data.setting_flag)
    self.curChar.charStatus = Bitset.new(data.char_status)
end

return FloatingMenuDlg
