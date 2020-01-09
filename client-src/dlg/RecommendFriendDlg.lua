-- RecommendFriendDlg.lua
-- Created by huangzz Sep/13/2018
-- 推荐加好友界面

local RecommendFriendDlg = Singleton("RecommendFriendDlg", Dialog)

function RecommendFriendDlg:init()
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("ConfirmButton", self.onCloseButton)
    self:bindCheckBoxListener("OpenCheckBox", self.onOpenCheckBox)

    for i = 1, 4 do
        self:bindListener("AddButton", self.onAddButton, "RolePanel_" .. i)
        self:bindListener("PortraitPanel", self.onPortraitPanel, "RolePanel_" .. i)
    end

    if FriendMgr.notRecommendfInThisLogin then
        self:setCheck("OpenCheckBox", true)
    else
        self:setCheck("OpenCheckBox", false)
    end

    self:hookMsg("MSG_FRIEND_ADD_CHAR")
end

function RecommendFriendDlg:setData(data)
    if not data then return end

    for i = 1, 4 do
        local panel = self:getControl("RolePanel_" .. i)
        if data[i] then
            panel:setVisible(true)

            self:setImage("PortraitImage", ResMgr:getSmallPortrait(data[i].icon), panel)

            self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT, data[i].level or 1, false, LOCATE_POSITION.LEFT_TOP, 19, panel)

            local nameColor = COLOR3.GREEN
            if 0 ~= data[i].is_vip then
                nameColor = COLOR3.CHAR_VIP_BLUE_EX
            end
            
            self:setLabelText("NameLabel", data[i].name, panel, nameColor)
            self:setLabelText("GangLabel", data[i].party_name, panel)

            panel.data = data[i]
        else
            panel:setVisible(false)
        end
    end
end

-- 添加好友
function RecommendFriendDlg:onAddButton(sender, eventType)
    local data = sender:getParent().data
    if data then
        FriendMgr:addFriend(data.name)
    end
end

function RecommendFriendDlg:onOpenCheckBox(sender, eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        -- 选中
        FriendMgr.notRecommendfInThisLogin = true
    else
        -- 取消选中
        FriendMgr.notRecommendfInThisLogin = false
    end
end

function RecommendFriendDlg:MSG_FRIEND_ADD_CHAR(data)
    for i = 1, 4 do
        local panel = self:getControl("RolePanel_" .. i)
        if panel.data then
            if FriendMgr:hasFriend(panel.data.gid) then
                self:setCtrlEnabled("AddButton", false, panel)
                self:setLabelText("Label_1", CHS[5400679], panel)
                self:setLabelText("Label_2", CHS[5400679], panel)
            end
        end
    end
end

return RecommendFriendDlg
