-- GMAccountListDlg.lua
-- Created by songcw Feb/24/2016
-- GM角色账号列表

local GMAccountListDlg = Singleton("GMAccountListDlg", Dialog)
-- list加载控件间隔
local ListMargin = 2

function GMAccountListDlg:init()
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
end

function GMAccountListDlg:cleanup()
    self:releaseCloneCtrl("oneUserPanel")
    self:releaseCloneCtrl("chosenEffectImage")
end

function GMAccountListDlg:setUnitPanel(userInfo, panel)
    self:setLabelText("ServerLabel", userInfo.account, panel)
    self:setLabelText("NameLabel", gf:getRealName(userInfo.name), panel)
    self:setLabelText("IPLabel", userInfo.ip, panel)

    -- 事件监听
    self:bindTouchEndEventListener(panel, self.onChosenPanel)
end

function GMAccountListDlg:setUserList(userList)
    local listCtrl = self:resetListView("ListView", ListMargin, ccui.ListViewGravity.centerVertical)
    for i = 1, #userList do
        local panel = self.oneUserPanel:clone()
        panel.userInfo = userList[i]
        self:setUnitPanel(userList[i], panel)
        listCtrl:pushBackCustomItem(panel)
    end

    self:setLabelText("Label_2", #userList, "TotalPanel")
end

function GMAccountListDlg:onChosenPanel(sender, eventType)
    self.chosenEffectImage:removeFromParent()
    sender:addChild(self.chosenEffectImage)

    local dlg = DlgMgr:openDlg("GMAccountManageDlg")
    dlg:setUser(sender.userInfo)
end

function GMAccountListDlg:onSelectListView(sender, eventType)
end

return GMAccountListDlg
