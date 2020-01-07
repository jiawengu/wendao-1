-- FriendOperationDlg.lua
-- Created by songcw Mar/31/2017
-- 好友添加成功

local FriendOperationDlg = Singleton("FriendOperationDlg", Dialog)

function FriendOperationDlg:init()
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton)
    self:bindListener("SingleFlockButton", self.onSingleFlockButton)
    self:bindListener("MenuButton", self.onMenuButton)
    self:bindListener("CancelButton", self.onCloseButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self.charData = nil

    -- 备注
    self:bindEditFieldForSafe("InputPanel", 20, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)
end

function FriendOperationDlg:setCharInfo(data)

    self.charData = data

    local ShapePanel = self:getControl("FramePanel")
    self:setImage("ShapeImage", ResMgr:getSmallPortrait(data.icon), ShapePanel)
    
    -- 人物等级使用带描边的数字图片显示
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, ShapePanel)

    -- 名称
    self:setLabelText("NameLabel", data.name)
    self:setLabelText("PartyLabel", data.party_name)
    
    -- 备注
    local memo = FriendMgr:getMemoByGid(data.gid)
    if memo and string.len(memo) > 0 then 
        self:setCtrlVisible("DefaultLabel", false)
        self:setInputText("TextField", memo)
        self:setCtrlVisible("CleanRemarksButton", true)
    else
        self:setCtrlVisible("DefaultLabel", true)
        self:setInputText("TextField", "")
        self:setCtrlVisible("CleanRemarksButton", false)
    end
end

function FriendOperationDlg:setGroup(data)
    self:setLabelText("FlockNameLabel", data.name)
end

function FriendOperationDlg:onCleanRemarksButton(sender, eventType)
    self:setInputText("TextField", "")
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true)
end

function FriendOperationDlg:onSingleFlockButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local data = FriendMgr:getFriendGroupData()
    
    local srcName = self:getLabelText("FlockNameLabel")
    local srcGroup = FriendMgr:getFriendGroupByName(srcName)
    local data2 = FriendMgr:getFriendGroupData(srcGroup.groupId)
    if #data2 == 0 then
        gf:ShowSmallTips(CHS[6000443])
        return
    end
    
    local dlg = DlgMgr:openDlg("SingleFlockMoveDlg")
    dlg:setMoveGidsString(srcGroup.groupId, self.charData.gid, self.charData.name)
    dlg.root:setPosition(rect.x + rect.width, rect.y)
end

function FriendOperationDlg:onConfirmButton(sender, eventType)
    local inputText = self:getInputText("TextField", self.rootPanel) or ""

    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(inputText, nil, false)
    if haveFilt then
        return
    end    

    gf:CmdToServer("CMD_MODIFY_FRIEND_MEMO", {gid = self.charData.gid, memo = inputText})
    
    self:onCloseButton()  
end


return FriendOperationDlg
