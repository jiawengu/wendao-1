-- GMUserListDlg.lua
-- Created by songcw Feb/24/2016
-- GM玩家列表

local GMUserListDlg = Singleton("GMUserListDlg", Dialog)

-- list加载控件间隔
local ListMargin = 2
local PER_PAGE_COUNT = 20

function GMUserListDlg:init()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self:align(ccui.RelativeAlign.centerInParent)
    self.root:requestDoLayout()
    -- 事件监听
    self:bindTouchEndEventListener(self.root, self.onCloseButton)

    -- 一个玩家信息
    self.oneUserPanel = self:getControl("OneUserPanel")
    self.oneUserPanel:retain()
    self.oneUserPanel:removeFromParent()

    self.chosenEffectImage = self:getControl("ChosenEffectImage", nil, self.oneUserPanel)
    self.chosenEffectImage:retain()
    self.chosenEffectImage:removeFromParent()
    self.chosenEffectImage:setVisible(true)

    self.userList = {}
    self.start = 0

    -- 滚动加载
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            -- 加载
            local list = self:getUserList(self.start, PER_PAGE_COUNT)
            if list and #list > 0 then
                self:pushData(list)
            end
        end
    end)
end

function GMUserListDlg:cleanup()
    self:releaseCloneCtrl("oneUserPanel")
    self:releaseCloneCtrl("chosenEffectImage")
end

function GMUserListDlg:onChosenPanel(sender, eventType)
    self.chosenEffectImage:removeFromParent()
    sender:addChild(self.chosenEffectImage)

    local dlg = DlgMgr:openDlg("GMUserManageDlg")
    dlg:setUser(sender.userInfo)
end

function GMUserListDlg:setUnitPanel(userInfo, panel)
    local color = COLOR3.WHITE
    if userInfo.server == "离线" then
        color = COLOR3.GRAY
    end
    self:setLabelText("ServerLabel", userInfo.server, panel, color)
    self:setLabelText("NameLabel", gf:getRealName(userInfo.name), panel, color)
    self:setLabelText("LevelLabel", userInfo.level, panel, color)
    self:setLabelText("PolarLabel", gf:getPolar(userInfo.polar), panel, color)
    self:setLabelText("IPLabel", userInfo.ip, panel, color)

    -- 事件监听
    self:bindTouchEndEventListener(panel, self.onChosenPanel)
end

function GMUserListDlg:getUserList(start, limit)
    if not self.userList then
        return nil
    end

    local retValue = {}
    local count = 1
    for i = start + 1, start + limit do
        if self.userList[i] then
            table.insert(retValue, self.userList[i])
        end
    end

    return retValue
end

function GMUserListDlg:pushData(userList)
    local listCtrl = self:getControl("ListView")
    local unitHeight = self.oneUserPanel:getContentSize().height
    local innerContainer = listCtrl:getInnerContainerSize()
    innerContainer.height = (self.start + #userList) * (unitHeight + ListMargin)
    listCtrl:setInnerContainerSize(innerContainer)

    for i = 1, #userList do
        local panel = self.oneUserPanel:clone()
        panel.userInfo = userList[i]
        self:setUnitPanel(userList[i], panel)
        listCtrl:pushBackCustomItem(panel)
    end
    self.start = self.start + #userList
end

function GMUserListDlg:setUserList(userList)
    self.userList = userList
    self.start = 0
    local listCtrl = self:resetListView("ListView", ListMargin, ccui.ListViewGravity.centerVertical)
    local list = self:getUserList(self.start, PER_PAGE_COUNT)
    self:pushData(list)
    self:setLabelText("Label_2", #userList, "TotalPanel")
end

function GMUserListDlg:onSelectListView(sender, eventType)
end

return GMUserListDlg
