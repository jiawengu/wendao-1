-- RemarksDlg.lua
-- Created by huangzz Feb/06/2017
-- 备注

local RemarksDlg = Singleton("RemarksDlg", Dialog)

local BLACK_GROUP = 5
local FRIEND_GROUP = 1

function RemarksDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton, "BlackListPanel")
    self:bindListener("CleanRemarksButton", self.onCleanRemarksButton, "FriendPanel")

    self:bindEditFieldForSafe("BlackListPanel", 20, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)
    self:bindEditFieldForSafe("FriendPanel", 20, "CleanRemarksButton", cc.VERTICAL_TEXT_ALIGNMENT_TOP, nil, true)
end

function RemarksDlg:onDlgOpened(value)
    local gid = value
    if type(value) == "table" then
        -- 服务端通知客户端打开，传过来的是一张表
        gid = value[1]
    end
    
    local info = FriendMgr:getFriendByGroupAndGid(BLACK_GROUP, gid)
    if not info then
        info = FriendMgr:getFriendByGroupAndGid(FRIEND_GROUP, gid)
    end
    
    if not info then
        info = CitySocialMgr:getCityFriend(gid)
    end
    
    if not info then
        self:onCloseButton()
        return
    end
    
    self.remarksInfo = {
        group = info:queryInt("group"),
        name = info:queryBasic("char"),
        gid = gid
    }
    
    self:setUiInfo(self.remarksInfo)
end

function RemarksDlg:setUiInfo(data)
    if tonumber(data.group) == BLACK_GROUP then -- 黑名单
        self:setCtrlVisible("BlackListPanel", true)
        self:setCtrlVisible("BlackListLabel", true)
        self:setCtrlVisible("FriendPanel", false)
        self:setCtrlVisible("FriendLabel",false)
        self.rootPanel = "BlackListPanel"
        -- self:setLabelText("NameLabel", gf:getRealName(data.name), self.rootPanel)
    else -- 好友（也可能是区域好友）
        self:setCtrlVisible("BlackListPanel", false)
        self:setCtrlVisible("BlackListLabel", false)
        self:setCtrlVisible("FriendPanel", true)
        self:setCtrlVisible("FriendLabel",true)
        self.rootPanel = "FriendPanel"
    end
    
    if FriendMgr:getKuafObjDist(data.gid) then
        self:setColorText(gf:getRealName(data.name) .. string.format(CHS[5400511], CHS[5400512]), "NamePanel", self.rootPanel)
    else
        self:setColorText(gf:getRealName(data.name), "NamePanel", self.rootPanel)
    end
    
    local remark = FriendMgr:getMemoByGid(data.gid)
    if remark and string.len(remark) > 0 then 
        self:setCtrlVisible("DefaultLabel", false, self.rootPanel)
        self:setInputText("TextField", remark, self.rootPanel)
        self:setCtrlVisible("CleanRemarksButton", true, self.rootPanel)
    else
        self:setCtrlVisible("DefaultLabel", true, self.rootPanel)
        self:setInputText("TextField", "", self.rootPanel)
        self:setCtrlVisible("CleanRemarksButton", false, self.rootPanel)
    end
end

function RemarksDlg:onCancelButton(sender, eventType)
    self:close()
end

function RemarksDlg:onConfirmButton(sender, eventType)
    local inputText = self:getInputText("TextField", self.rootPanel) or ""
    
    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(inputText, nil, false)
    if haveFilt then
        return
    end
    
    self:close()
    
    gf:CmdToServer("CMD_MODIFY_FRIEND_MEMO", {gid = self.remarksInfo.gid, memo = inputText})  
end

function RemarksDlg:onCleanRemarksButton(sender, eventType)
    self:setInputText("TextField", "", self.rootPanel)
    self.inputText = ""
    sender:setVisible(false)
    self:setCtrlVisible("DefaultLabel", true, self.rootPanel)
end

return RemarksDlg
