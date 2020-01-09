-- GroupInformationDlg.lua
-- Created by zhengjh Aug/04/2016
-- 群组信息

local GroupInformationDlg = Singleton("GroupInformationDlg", Dialog)

function GroupInformationDlg:init()
    self:bindListener("GroupDelButton", self.onGroupDelButton)
    self:bindListener("NameChangeButton", self.onNameChangeButton)
    self:bindListener("NoticeDelButton", self.onNoticeDelButton)
    self:bindListener("NoticeChangeButton", self.onNoticeChangeButton)
    self:bindListener("DissolutionButton", self.onDissolutionButton)
    self:bindListener("InvitationButton", self.onInvitationButton)
    self:bindCheckBoxListener("SelectedCheckBox", self.onCheckBox)

    self.playerPanel = self:getControl("PlayerInformationPanel")
    self.playerPanel:retain()
    self.playerPanel:removeFromParent()


    --self:bindEditField(self:getControl("NoticeWriteTextField"), 10, self:getControl("NoticeDelButton"))

    self:bindEditFieldForSafe("RenamePanel", 6, "GroupDelButton")
    self:getControl("GroupDelButton"):setVisible(true)
    self:bindEditFieldForSafe("WritePanel", 30, "NoticeDelButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP)

    self:hookMsg("MSG_REMOVE_CHAT_GROUP_MEMBER")
    self:hookMsg("MSG_CHAT_GROUP_MEMBERS")
    self:hookMsg("MSG_CHAT_GROUP_PARTIAL")
end

function GroupInformationDlg:setGroupData(group)
    self.group = group
    self.groupId = self.group.group_id
    -- 初值化群成员
    self:initSrollViewData(group)

    -- 设置群名字
    local panel = self:getControl("RenamePanel")
    self:setInputText("TextField", group.group_name, panel)

    -- 设置群公告
    local panel = self:getControl("WritePanel")

    if not group.announcement or group.announcement == "" then
        self:setCtrlVisible("DefaultLabel", true)
        self:setInputText("TextField", "", panel)
        self:getControl("NoticeDelButton"):setVisible(false)
    else
        self:setInputText("TextField", group.announcement, panel)
        self:setCtrlVisible("DefaultLabel", false)
        self:getControl("NoticeDelButton"):setVisible(true)
    end


    -- 设置在线信息
    self:setOnlineInfo()

    self:initCheckBox(self.groupId)
end

function GroupInformationDlg:setOnlineInfo()
    local group =  FriendMgr:getGroupByGroupId(self.groupId)
    local online, total = FriendMgr:getOnlinAndTotaleCounts(group)
    self:setLabelText("PlayerNumLabel", online)
    self:setLabelText("PlayerNumLabel1", "/" .. total)
    self:setLabelText("MaxNumLabel",  FriendMgr:getMaxMemberNum())
end

function GroupInformationDlg:initSrollViewData(group)
    local friends = FriendMgr:getMembersByGroupId(group.group_id)
    self:initScrollViewPanel(friends, self.playerPanel, self.setCellData, self:getControl("PlayerScrollView"), 2, 2, 6)
end

function GroupInformationDlg:setCellData(cell, data)
    -- 设置图标
    local icon = data.icon
    local iconPath = ResMgr:getSmallPortrait(icon)
    self:setImage("PortraitImage", iconPath, cell)

    -- 设置群主标志
    if data.gid == self.group.leader_gid then
        self:setCtrlVisible("MsterImage", true, cell)
        self:setCtrlVisible("DelButton", false, cell)
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

    -- 设置等级
    self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    local polar = gf:getPolar(gf:getPloarByIcon(icon))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, cell)

    -- 名字
    local realName, flagName = gf:getRealNameAndFlag(data.name)
    self:setLabelText("PlayerNameLabel", realName, cell)

    -- 帮派
    if flagName then
        self:setLabelText("PartyNameLabel", flagName, cell)
    else
        self:setLabelText("PartyNameLabel", data.party or "", cell)
    end

    self:bindTouchEndEventListener(self:getControl("DelButton", nil, cell), self.onDelButton, data)
    self:bindTouchEndEventListener(cell, self.showCharMenu, data)
end

function GroupInformationDlg:showCharMenu(sender, eventType, data)
    if Me:queryBasic("gid") == data.gid then return end
    local char = {}
    char.gid = data.gid
    char.name = data.name
    char.level = data.level
    char.icon = data.icon
    char.isOnline = 1
    local rect = self:getBoundingBoxInWorldSpace(sender)
    FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.GROUP_OWNER, rect, {groupId = self.groupId})
end

function GroupInformationDlg:onGroupDelButton(sender, eventType)
    local panel = self:getControl("RenamePanel")
    self:setInputText("TextField", "", panel)
    self:getControl("GroupDelButton"):setVisible(false)
end

function GroupInformationDlg:onNameChangeButton(sender, eventType)
    local panel = self:getControl("RenamePanel")
    local newName = self:getInputText("TextField", panel)

    if  gf:getTextLength(newName) == 0 then
        gf:ShowSmallTips(CHS[6000408])
        return
    end

    local newName, fitStr = gf:filtText(newName)
    if fitStr then
        return
    end

    FriendMgr:reNameGroup(self.groupId, newName)
end

function GroupInformationDlg:onNoticeDelButton(sender, eventType)
    local panel = self:getControl("WritePanel")
    self:setInputText("TextField", "", panel)
    self:getControl("NoticeDelButton"):setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, panel)
end

function GroupInformationDlg:onNoticeChangeButton(sender, eventType)
    local panel = self:getControl("WritePanel")
    local content = self:getInputText("TextField", panel)

    local content, fitStr = gf:filtText(content)
    if fitStr then
        return
    end

    FriendMgr:modifyGroupContent(self.groupId, content)
end

function GroupInformationDlg:onDelButton(sender, eventType, data)
    if self:checkSafeLockRelease("onDelButton", nil, nil, data) then
        return
    end

    gf:confirm(string.format(CHS[6000440], data.name) , function ()
        FriendMgr:removeMemberFromGroup(self.groupId, data.gid)
    end, nil)
end

function GroupInformationDlg:onDissolutionButton(sender, eventType)
    if self:checkSafeLockRelease("onDissolutionButton") then
        return
    end

    gf:confirm(CHS[6000431], function ()
        FriendMgr:removeChatGroup(self.groupId)
        DlgMgr:closeDlg(self.name)
    end, nil)
end

function GroupInformationDlg:onInvitationButton(sender, eventType)
    local dlg = DlgMgr:openDlg("GroupInviteDlg")
    dlg:setData(self.group)
end

-- 信息屏蔽
function GroupInformationDlg:initCheckBox(groupId)
    local isOn = FriendMgr:isNeedMsgTipByGroupId(groupId)
    self:setCheck("SelectedCheckBox", isOn)
end

function GroupInformationDlg:MSG_CHAT_GROUP_MEMBERS(data)
    if data.member_gid == Me:queryBasic("gid") then
        self:initCheckBox(data.group_id)
    end
end

function GroupInformationDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        FriendMgr:setGroupSetting(self.groupId, 1)
    else
        FriendMgr:setGroupSetting(self.groupId, 0)
    end
end

function GroupInformationDlg:MSG_REMOVE_CHAT_GROUP_MEMBER(data)
    self:initSrollViewData(self.group)
    self:setOnlineInfo()
end

function GroupInformationDlg:cleanup()
    self:releaseCloneCtrl("playerPanel")
end

-- 刷新群组信息
function GroupInformationDlg:MSG_CHAT_GROUP_PARTIAL(data)
    if self.groupId == data.info.group_id then
        if self.group.leader_gid ~= data.info.leader_gid and data.info.leader_gid ~= Me:queryBasic("gid")  then
            -- 群主发生变化，关闭界面
            self:onCloseButton()
        end
    end
end

return GroupInformationDlg
