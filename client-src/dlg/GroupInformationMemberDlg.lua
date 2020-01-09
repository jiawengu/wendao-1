-- GroupInformationMemberDlg.lua
-- Created by Aug/12/2016
-- 群成员（群组信息）

local GroupInformationMemberDlg = Singleton("GroupInformationMemberDlg", Dialog)

function GroupInformationMemberDlg:init()
    self:bindListener("QuitButton", self.onQuitButton)
    self:bindCheckBoxListener("SelectedCheckBox", self.onCheckBox)
    self:bindListener("InvitationButton", self.onInvitationButton)

    self.playerPanel = self:getControl("PlayerInformationPanel")
    self.playerPanel:retain()
    self.playerPanel:removeFromParent()

    self:hookMsg("MSG_CHAT_GROUP_PARTIAL")
end

function GroupInformationMemberDlg:setGroupData(group)
    self.group = group
    self.groupId = self.group.group_id
    -- 初值化群成员
    self:initSrollViewData(group)

    -- 设置群名字
    local panel = self:getControl("GrouNamePanel")
    self:setLabelText("WriteLabel", group.group_name, panel)

    -- 设置群公告
    local panel = self:getControl("GroupNoticePanel")

    if not group.announcement or group.announcement == "" then
        self:setLabelText("WriteLabel", CHS[6000439], panel)
    else
        self:setLabelText("WriteLabel", group.announcement, panel)
    end


    -- 设置在线信息
    self:setOnlineInfo()
    self:initCheckBox(self.groupId)

    self:hookMsg("MSG_CHAT_GROUP_MEMBERS")
end

function GroupInformationMemberDlg:setOnlineInfo()
    local group =  FriendMgr:getGroupByGroupId(self.groupId)
    local online, total = FriendMgr:getOnlinAndTotaleCounts(group)
    self:setLabelText("PlayerNumLabel", online)
    self:setLabelText("PlayerNumLabel1", "/" .. total)
    self:setLabelText("MaxNumLabel",  FriendMgr:getMaxMemberNum())
end

function GroupInformationMemberDlg:initSrollViewData(group)
    local friends = FriendMgr:getMembersByGroupId(group.group_id)
    self:initScrollViewPanel(friends, self.playerPanel, self.setCellData, self:getControl("PlayerScrollView"), 2, 2, 6)
end

function GroupInformationMemberDlg:setCellData(cell, data)
    -- 设置图标
    local icon = data.icon
    local iconPath = ResMgr:getSmallPortrait(icon)
    self:setImage("PortraitImage", iconPath, cell)

    -- 设置群主标志
    if data.gid == self.group.leader_gid then
        self:setCtrlVisible("MsterImage", true, cell)
    else
        self:setCtrlVisible("MsterImage", false, cell)
    end

    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    if 1 ~= data.isOnline then
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end

    local polar = gf:getPolar(gf:getPloarByIcon(icon))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, cell)

    -- 设置等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 名字
    local realName, flagName = gf:getRealNameAndFlag(data.name)
    self:setLabelText("PlayerNameLabel", realName, cell)

    -- 帮派
    if flagName then
        self:setLabelText("PartyNameLabel", flagName, cell)
    else
        self:setLabelText("PartyNameLabel", data.party or "", cell)
    end

    self:bindTouchEndEventListener(cell, self.showCharMenu, data)
end

function GroupInformationMemberDlg:showCharMenu(sender, eventType, data)
    if Me:queryBasic("gid") == data.gid then return end
    local char = {}
    char.gid = data.gid
    char.name = data.name
    char.level = data.level
    char.icon = data.icon
    char.isOnline = 1
    local rect = self:getBoundingBoxInWorldSpace(sender)
    FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.GROUP_MEMBER, rect)
end


-- 信息屏蔽
function GroupInformationMemberDlg:initCheckBox(groupId)
    local isOn = FriendMgr:isNeedMsgTipByGroupId(groupId)
    self:setCheck("SelectedCheckBox", isOn)
end

function GroupInformationMemberDlg:MSG_CHAT_GROUP_MEMBERS(data)
    if data.member_gid == Me:queryBasic("gid") then
        self:initCheckBox(data.group_id)
    end
end


function GroupInformationMemberDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        FriendMgr:setGroupSetting(self.groupId, 1)
    else
        FriendMgr:setGroupSetting(self.groupId, 0)
    end
end

function GroupInformationMemberDlg:onInvitationButton(sender, eventType)
    local dlg = DlgMgr:openDlg("GroupInviteDlg")
    dlg:setData(self.group)
end

function GroupInformationMemberDlg:onQuitButton(sender, eventType)
    if self:checkSafeLockRelease("onQuitButton") then
        return
    end

    gf:confirm(CHS[6000432], function ()
	    FriendMgr:quitChatGroup(self.groupId)
        DlgMgr:closeDlg(self.name)
    end, nil)
end

-- 刷新群组信息
function GroupInformationMemberDlg:MSG_CHAT_GROUP_PARTIAL(data)
    if self.groupId == data.info.group_id then
        if self.group.leader_gid ~= data.info.leader_gid and data.info.leader_gid == Me:queryBasic("gid") then
            -- 群主发生变化，关闭界面
            self:onCloseButton()
        end
    end
end


function GroupInformationMemberDlg:cleanup()
    self:releaseCloneCtrl("playerPanel")
end

return GroupInformationMemberDlg
