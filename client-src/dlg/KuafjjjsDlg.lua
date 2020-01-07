-- KuafjjjsDlg.lua
-- Created by huangzz Jan/04/2018
-- 跨服竞技胜利界面

local KuafjjjsDlg = Singleton("KuafjjjsDlg", Dialog)

function KuafjjjsDlg:init()
    self:setCtrlFullClientEx("BKPanel")
    self:bindListener("ContrimButton", self.onContrimButton)

    self.members = {}

    local protectTime = KuafjjMgr.protectTime or 0
    local curTime = gf:getServerTime()
    if protectTime == 0 or protectTime < curTime then
        protectTime = gf:getServerTime() + 30
    end

    self:startSchedule(function()
        local curTime = gf:getServerTime()
        if protectTime - curTime <= 0 then
            self:onCloseButton()
        end
    end, 1)

    self:hookMsg("MSG_FRIEND_ADD_CHAR")
    self:hookMsg("MSG_ENTER_ROOM")
end

function KuafjjjsDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

function KuafjjjsDlg:MSG_FRIEND_ADD_CHAR(data)
    if data.count <= 0 then return end

    for i = 1, data.count do
        if self.members[data[i].gid] then
            KuafjjjsDlg:setOneMemberPanel(self.members[data[i].gid].data, self.members[data[i].gid])
        end
    end
end

function KuafjjjsDlg:onAddButton(sender, eventType)
    local data = sender:getParent():getParent().data
    if data then
        if not FriendMgr:hasFriend(data.gid) then
            FriendMgr:addFriendCheck(data)
        end
    end
end

function KuafjjjsDlg:onContrimButton(sender, eventType)
    self:onCloseButton()
end

function KuafjjjsDlg:setData(data)
    self.members = {}
    local cou = #data
    for i = 1, 5 do
        local cell = self:getControl("MembersPanel_" .. i)
        if data[i] then
            self:setOneMemberPanel(data[i], cell)
            self.members[data[i].gid] = cell
            cell:setVisible(true)

            self:bindListener("AddButton", self.onAddButton, cell)
        else
            cell:setVisible(false)
        end
    end

    -- 战斗结果标识
    if data.is_win == 1 then
        self:setCtrlVisible("WinPanel", true)
        self:setCtrlVisible("LostPanel", false)
    else
        self:setCtrlVisible("WinPanel", false)
        self:setCtrlVisible("LostPanel", true)
    end
end

function KuafjjjsDlg:setOneMemberPanel(data, cell)
    if not data then
        return
    end

    cell.data = data

    local panel
    if Me:queryBasic("gid") == data.gid then
        panel = self:getControl("SelfInfoPanel", nil, cell)
        self:setCtrlVisible("OtherInfoPanel", false, cell)
        self:setCtrlVisible("SelfInfoPanel", true, cell)
    else
        panel = self:getControl("OtherInfoPanel", nil, cell)
        self:setCtrlVisible("OtherInfoPanel", true, cell)
        self:setCtrlVisible("SelfInfoPanel", false, cell)

        if FriendMgr:getFriendByGid(data.gid) then
            self:setCtrlVisible("AddButton", false, panel)
        else
            self:setCtrlVisible("AddButton", true, panel)
        end
    end

    -- 头像
    self:setImage("Image", ResMgr:getSmallPortrait(gf:getIconByGenderAndPolar(data.gender, data.polar)), cell)

    -- 等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 名字
    local realName = gf:getRealName(data.name)
    self:setLabelText("NameLabel", realName, panel)

    -- 积分
    local str, str2
    local totalScore = data.old_score
    if data.change_score < 0 then
        str = string.format(CHS[5400402], totalScore, "#R" .. (- data.change_score) .. "↓#n")
    else
        str = string.format(CHS[5400402], totalScore, "#G" .. data.change_score .. "↑#n")
    end

    self:setColorText(str, "ScorePanel", panel, nil, nil, COLOR3.WHITE, 20, true)

    -- 称谓
    self:setLabelText("TitleLabel", data.stage_desc, panel)
end

return KuafjjjsDlg
