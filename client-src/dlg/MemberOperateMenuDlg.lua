-- MemberOperateMenuDlg.lua
-- Created by Chang_back Jun/17/2015
-- 帮派成员菜单界面
local Bitset = require("core/Bitset")

local MemberOperateMenuDlg = Singleton("MemberOperateMenuDlg", Dialog)

local OPERATE_ACTION = {
    DO_NOTHING = 0,
    ADD_FRIEND = 1,
    ADD_TEAM   = 2,
    FIRE_OBJ   = 3,
    MUTE_OBJ   = 4,
}

function MemberOperateMenuDlg:init()
    self:bindListener("OperateButton", self.onOperateButton)
    self.tempButton = self:getControl("OperateButton", Const.UIButton)
    self.tempButton:retain()
    self.tempButton:removeFromParent()
    self.menuPanel = self:getControl("MenuPanel", Const.UIPanel)
    self.curOperate = OPERATE_ACTION.DO_NOTHING
    self.isMute = false
    self.root:setVisible(false)

    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
    self:hookMsg("MSG_PARTY_QUERY_MEMBER")
    self:hookMsg("MSG_PARTY_CHANNEL_DENY_LIST")
end

function MemberOperateMenuDlg:cleanup()
    self:releaseCloneCtrl("tempButton")
    self.comunicateButton = nil
    self.friendButton = nil
    self.addTeamButton = nil
    self.fireButton = nil
    self.muteButton = nil
    self.orderButton = nil
end

function MemberOperateMenuDlg:onOperateButton(sender, eventType)
end

-- 设置要显示的菜单信息
function MemberOperateMenuDlg:setInfo(charData)
    local unSilencePanel = self:getControl("UnSilencedPanel", Const.UIPanel)
    local path = ResMgr:getSmallPortrait(charData.icon)
    self:setImage("ShapeImage", path)
    self:setItemImageSize("ShapeImage")

    -- 帮派成员等级
    if charData.level then
        self:setNumImgForPanel("UserPanel", ART_FONT_COLOR.NORMAL_TEXT,
                               charData.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 设置ID
    self:setLabelText("IDTypeLabel", CHS[3003101] .. string.sub(charData.gid, 5, 14))

    if charData.online == 0 then
        self:setLabelText("NameLabel", charData.name, nil, COLOR3.WHITE)
        self:setLabelText("LineLabel", "")
        self:setCtrlVisible("LineImage", false)
    else
        -- 为了查询线名和vip
        self:setLabelText("NameLabel", charData.name, nil, COLOR3.GREEN)
        PartyMgr:queryPartyMemberByNameAndGid(charData.name, charData.gid)
    end

    self:setLabelText("JobNameLabel", CHS[3003102] .. self:getJobName(charData.job))
    self.queryMember = charData
    self:initMenuButton()
    self:updateLayout("MenuPanel")
    PartyMgr:getProhibitSpeakingList()
end

function MemberOperateMenuDlg:initMenuButton()
    -- 开除按钮
    -- 是我自己不能开除
    local pos = {}
    pos.x, pos.y = self.tempButton:getPosition()
    local i = 0
    -- 交流
    local comunicateButton = self.tempButton:clone()
    self.comunicateButton = comunicateButton
    local contentSize = comunicateButton:getContentSize()
    comunicateButton:setPosition(pos.x, pos.y - contentSize.height * i)
    self.menuPanel:addChild(comunicateButton)
    comunicateButton:setTitleText(CHS[3003103])
    self:bindTouchEndEventListener(comunicateButton, self.onCommunicationButton)
    i = i + 1

    -- 查看
    local lookEquipBtn = self.tempButton:clone()
    lookEquipBtn:setPosition(pos.x, pos.y - contentSize.height * i)
    self.menuPanel:addChild(lookEquipBtn)
    lookEquipBtn:setTitleText(CHS[4300139])
    self:bindTouchEndEventListener(lookEquipBtn, self.onlookEquipBtn)
    i = i + 1

    -- 加为好友
    local friendButton = self.tempButton:clone()
    self.friendButton = friendButton
    local contentSize = friendButton:getContentSize()
    friendButton:setPosition(pos.x, pos.y - contentSize.height * i)
    self.menuPanel:addChild(friendButton)

    self:getControl("RelationshipImage"):setTouchEnabled(true)
    -- 判断对方是否为好友
    if not FriendMgr:hasFriend(self.queryMember.gid) then
        friendButton:setTitleText(CHS[3003104])
        self:bindTouchEndEventListener(friendButton, self.onAddFriendButton)
        self:setImage("RelationshipImage", ResMgr.ui.friend_heart_empty)
        self:bindListener("RelationshipImage", function(dlg, sender, eventType)
            gf:confirm(CHS[3003105], function()
            	self:onAddFriendButton()
            end)
        end)
    else
        friendButton:setTitleText(CHS[3003106])
        self:bindTouchEndEventListener(friendButton, self.onDeleteFirendButton)
        self:setImage("RelationshipImage", ResMgr.ui.friend_heart_filled)
        self:bindListener("RelationshipImage", function(dlg, sender, eventType)
            local score = FriendMgr:getFriendScore(self.queryMember.gid) or 0
            gf:showTipInfo(CHS[3003107] .. score, sender)
        end)
    end



    if self:checkCanAddTeam() then
        i = i + 1
        -- 组队
        local addTeamButton = self.tempButton:clone()
        self.addTeamButton = addTeamButton
        local contentSize = addTeamButton:getContentSize()
        addTeamButton:setPosition(pos.x, pos.y - contentSize.height * i)
        self.menuPanel:addChild(addTeamButton)
        addTeamButton:setTitleText(CHS[3003108])
        self:bindTouchEndEventListener(addTeamButton, self.onInviteTeamButton)
    end

    if PartyMgr:canApplyAndPro() then
        i = i + 1

        -- 开除
        local fireButton = self.tempButton:clone()
        self.fireButton = fireButton
        local contentSize = fireButton:getContentSize()
        fireButton:setPosition(pos.x, pos.y - contentSize.height * i)
        self.menuPanel:addChild(fireButton)
        fireButton:setTitleText(CHS[3003109])
        self:bindTouchEndEventListener(fireButton, self.onFireButton)
        i = i + 1

        -- 禁言
        local muteButton = self.tempButton:clone()
        self.muteButton = muteButton
        local contentSize = muteButton:getContentSize()
        muteButton:setPosition(pos.x, pos.y - contentSize.height * i)
        self.menuPanel:addChild(muteButton)
        muteButton:setTitleText(CHS[3003110])
        self:bindTouchEndEventListener(muteButton, self.onProhibitSpeakingButton)
        i = i + 1

        -- 任命
        local orderButton = self.tempButton:clone()
        self.orderButton = orderButton
        local contentSize = orderButton:getContentSize()
        orderButton:setPosition(pos.x, pos.y - contentSize.height * i)
        self.menuPanel:addChild(orderButton)
        orderButton:setTitleText(CHS[3003111])
        self:bindTouchEndEventListener(orderButton, self.onAppointButton)
    end

    local menuSize = self.menuPanel:getContentSize()
    menuSize.height = menuSize.height + i * contentSize.height
    self.menuPanel:setContentSize(menuSize)


    -- 设置下偏移
    local allItem = self.menuPanel:getChildren()

    for k, v in pairs(allItem) do
        local posX,posY = v:getPosition()
        posY = posY + menuSize.height
        v:setPosition(posX, posY)
    end

    self:updateLayout("MenuPanel")

end

-- 开除
function MemberOperateMenuDlg:onFireButton(sender, eventType)
    -- 不可开除自己
    if self.queryMember.name == Me:queryBasic("name") then
        gf:ShowSmallTips(CHS[4000218])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onFireButton", sender, eventType) then
        return
    end

    local function fireMember()
        PartyMgr:fireMember(self.queryMember.name, self.queryMember.gid)

        -- 发送信息刷新界面
        PartyMgr:queryPartyInfo()
        PartyMgr:queryPartyMembers()
        DlgMgr:closeDlg(self.name)
    end

    local tips = string.format(CHS[4000152], self.queryMember.name)
    gf:confirm(tips, fireMember)
    DlgMgr:closeDlg(self.name)
end

-- 查看
function MemberOperateMenuDlg:onlookEquipBtn(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.queryMember.gid)
    self:onCloseButton()
end

function MemberOperateMenuDlg:onCommunicationButton(sender, eventType)
    FriendMgr:communicat(self.queryMember.name, self.queryMember.gid, self.queryMember.icon, self.queryMember.level)
    DlgMgr:closeDlg(self.name)
end

-- 禁言
function MemberOperateMenuDlg:onProhibitSpeakingButton(sender, eventType)
    if self.queryMember.name == Me:queryBasic("name") then
        gf:ShowSmallTips(CHS[4000201])
        return
    end

    local pos = gf:findStrByByte(self.queryMember.job, ":")
    local jobStr = ""
    if pos then
        jobStr = string.sub(self.queryMember.job, 1, pos - 1)
    else
        jobStr = self.queryMember.job
    end

    if jobStr == CHS[4000153] then
        gf:ShowSmallTips(CHS[4000202])
        return
    end

    -- 判断自身是否有权限
    if PartyMgr:canApplyAndPro() == false then
        gf:ShowSmallTips(CHS[4000219])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onProhibitSpeakingButton") then
        return
    end

    if self.isMute then
        PartyMgr:prohibitSpeaking(self.queryMember, 2, 0)
    else
        PartyMgr:prohibitSpeaking(self.queryMember, 1, 24)
    end

    DlgMgr:closeDlg(self.name)
end

function MemberOperateMenuDlg:onAddFriendButton(sender, eventType)
    if nil == self.queryMember then return end
    FriendMgr:requestCharMenuInfo(self.queryMember.gid)
    self.curOperate = OPERATE_ACTION.ADD_FRIEND
end

function MemberOperateMenuDlg:onDeleteFirendButton(sender, eventType)

    -- 如果已经是己方好友
    local str = string.format(CHS[5000060], self.queryMember.name)
    gf:confirm(str, function()
        FriendMgr:deleteFriend(self.queryMember.name, self.queryMember.gid)
    end)
    DlgMgr:closeDlg(self.name)
end

function MemberOperateMenuDlg:checkAddFriend(char)
    local name = self.queryMember.name
    -- 如果都没有设置，则直接添加好友
    FriendMgr:addFriend(name)
    DlgMgr:closeDlg(self.name)
end

function MemberOperateMenuDlg:checkAddTeam(char)
    if TeamMgr:inTeamEx(Me:getId()) == false and char.charStatus and char.charStatus:isSet(CHAR_STATUS.IN_TEAM) == true then
        -- Me为单人，对方为队伍中  申请组队
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.queryMember.name,
            ask_type = Const.REQUEST_JOIN_TEAM,
        })
        return true
    end

    if TeamMgr:getLeaderId() == Me:getId() and char.charStatus and char.charStatus:isSet(CHAR_STATUS.IN_TEAM) == false then
        -- Me为队长，对方单人 邀请
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.queryMember.name,
            ask_type = Const.INVITE_JOIN_TEAM,
        })

        return true
    end

    if not TeamMgr:inTeamEx(Me:getId()) and char.charStatus and not char.charStatus:isSet(CHAR_STATUS.IN_TEAM) then
        -- 双方都是单人 邀请
        gf:CmdToServer("CMD_REQUEST_JOIN", {
            peer_name = self.queryMember.name,
            ask_type = Const.INVITE_JOIN_TEAM,
        })
        return true
    end

    gf:CmdToServer("CMD_REQUEST_JOIN", {
        peer_name = self.queryMember.name,
        ask_type = Const.INVITE_JOIN_TEAM,
    })

end

-- 组队
function MemberOperateMenuDlg:onInviteTeamButton(sender, eventType)
    if self.queryMember.online == 0 then
        gf:ShowSmallTips(CHS[3003112])
        DlgMgr:closeDlg(self.name)
        return
    end
    self.curOperate = OPERATE_ACTION.ADD_TEAM

    FriendMgr:requestCharMenuInfo(self.queryMember.gid)
end

-- 任命
function MemberOperateMenuDlg:onAppointButton(sender, eventType)
    if self.queryMember.name == Me:queryBasic("name") then
        gf:ShowSmallTips(CHS[4000261])
        return
    end


    if self:getJobName(self.queryMember.job) == CHS[4000153] then
        gf:ShowSmallTips(CHS[4000262])
        return
    end

    -- 判断自身是否有权限
    if PartyMgr:canApplyAndPro() == false then
        gf:ShowSmallTips(CHS[4000219])
        return
    end

    --
    if self:haveJob() == false then
        gf:ShowSmallTips(CHS[4000274])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onAppointButton") then
        return
    end

    local dlg = DlgMgr:openDlg("PartyAppointDlg")
    local partyInfo = PartyMgr:getPartyInfo()
    dlg:setInfo(self.queryMember, partyInfo.heir)
    DlgMgr:closeDlg(self.name)
end

function MemberOperateMenuDlg:haveJob()
    if PartyMgr:isPartyLeader() == true then return true end

    local str = self.queryMember.job
    local pos = gf:findStrByByte(str, ":")

    while(pos ~= nil) do
        local jobName = string.sub(str, 1, pos - 1)
        local cutPos = gf:findStrByByte(str, ",") or 0
        local enable = string.sub(str, pos + 1, cutPos - 1)
        str = string.sub(str, cutPos + 1, -1)
        pos = gf:findStrByByte(str, ":")
        if cutPos == 0 then pos = nil end

        if enable ~= "-1" then
            return true
        end
    end

    return false
end

function MemberOperateMenuDlg:getJobName(job)
    if job == nil or job == "" then return end
    local pos = gf:findStrByByte(job, ":")
    if pos == nil then
        return job
    end

    return string.sub(job, 0, pos - 1)
end

function MemberOperateMenuDlg:MSG_PARTY_QUERY_MEMBER(data)
    local nameColor = CharMgr:getNameColorByType(OBJECT_TYPE.CHAR, data.vipType, nil, true)
    if data.online ~= 1 then
        nameColor = COLOR3.WHITE
    end

    self.queryMember.name = data.name
    self:setLabelText("NameLabel", data.name, nil, nameColor)

    if data.serverId and not string.match(data.serverId, "undefined") then
        self:setLabelText("LineLabel", data.serverId)
        self:setCtrlVisible("LineImage", true)
    else
        self:setLabelText("LineLabel", "")
        self:setCtrlVisible("LineImage", false)
    end

    if self.addTeamButton then
        if not TeamMgr:inTeamEx(Me:getId()) and data.inTeam == 1 then
            self.addTeamButton:setTitleText(CHS[4000276])
        end
    end

    self:updateLayout("UserPanel")
end

function MemberOperateMenuDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if not self.queryMember or self.queryMember.gid ~= data.char_id then return end

    if self.curOperate == OPERATE_ACTION.ADD_FRIEND then
        self.curOperate = OPERATE_ACTION.DO_NOTHING
        gf:ShowSmallTips(string.format(CHS[5400576], self.queryMember.name))
    elseif self.curOperate == OPERATE_ACTION.ADD_TEAM then
        self.curOperate = OPERATE_ACTION.DO_NOTHING
        if self.addTeamButton then
            if self.addTeamButton:getTitleText() == CHS[4000276] then
                gf:ShowSmallTips(CHS[5410252])
            else
                gf:ShowSmallTips(CHS[5410251])
            end
        end
    end
end

function MemberOperateMenuDlg:MSG_CHAR_INFO(data)
    if not self.queryMember or self.queryMember.gid ~= data.gid then return end

    local char = {}
    char.level = data.level
    char.icon = data.icon
    char.gid = data.gid
    char.id = data.id
    char.name = data.name
    char.party = data.party
    char.friendScore = data.friend_score
    char.settingFlag = Bitset.new(data.setting_flag)
    char.charStatus = Bitset.new(data.char_status)

    self.queryMember.name = char.name

    if self.curOperate == OPERATE_ACTION.ADD_FRIEND then
        self.curOperate = OPERATE_ACTION.DO_NOTHING
        self:checkAddFriend(char)
        DlgMgr:closeDlg(self.name)
    elseif self.curOperate == OPERATE_ACTION.ADD_TEAM then
        self.curOperate = OPERATE_ACTION.DO_NOTHING
        self:checkAddTeam(char)
        DlgMgr:closeDlg(self.name)
    end
end

-- 禁言名单
function MemberOperateMenuDlg:MSG_PARTY_CHANNEL_DENY_LIST(data)
    self.denyList = data.speakList
    self.isMute = false
    local denyInfo = self.denyList[self.queryMember.gid]
    if denyInfo and denyInfo.endTime and gf:getServerTime() < denyInfo.endTime then
        self:setCtrlVisible("UnSilencedPanel", false)
        self:setCtrlVisible("SilencedPanel", true)
        local silencePanel = self:getControl("SilencedPanel", Const.UIPanel)
--           self:setLabelText("LevelLabel", self.queryMember.level)
        self:setLabelText("NameLabel", self.queryMember.name, silencePanel)
        self:setLabelText("JobNameLabel", CHS[3003102] .. self:getJobName(self.queryMember.job), silencePanel)
        --local endStamp = gf:getServerDate(v.startTime) + v.hours * 60 * 60

        local deltaTime = denyInfo.endTime - gf:getServerTime()

        if deltaTime >= 3600 then
            self:setLabelText("NoSpeakingLabel", CHS[3003114] .. math.floor(deltaTime / 3600) .. CHS[3003115])
        else
            self:setLabelText("NoSpeakingLabel", CHS[3003114] .. math.floor(deltaTime / 60) .. CHS[3003116])
        end


        if self.muteButton then
            self.muteButton:setTitleText(CHS[3003117])
        end

        self.isMute = true
    end

    if not self.isMute then
        self:setCtrlVisible("NoSpeakingLabel", false)

        if self.muteButton then
            self.muteButton:setTitleText(CHS[3003110])
        end
    end

    self.root:setVisible(true)
end

function MemberOperateMenuDlg:checkCanAddTeam()
    if self.queryMember.online == 1 then
        if TeamMgr:inTeamEx(Me:getId()) and TeamMgr:getLeaderId() ~= Me:getId() then
            return false
        end
    else
        return false
    end

    return true
end

return MemberOperateMenuDlg
