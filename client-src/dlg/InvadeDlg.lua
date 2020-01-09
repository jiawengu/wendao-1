-- InvadeDlg.lua
-- Created by sujl, Apr/6/2017
-- 异族入侵界面

local InvadeDlg = Singleton("InvadeDlg", Dialog)

function InvadeDlg:init()
    self:setLabelText("NowLabel_1", 0, "JungongPanel")

    local scrollview = self:getControl("ScrollView")
    local walkPanel = self:getControl("WalkPanel")
    self:showBossPanel()
    scrollview:setClippingEnabled(true)

    self:bindButtonEvent(walkPanel)

    self:hookMsg("MSG_YISHI_SEARCH_RESULT")
end

function InvadeDlg:cleanup()
    self.curMonster = nil
end

function InvadeDlg:onDlgOpened(param)
    if param and #param > 0 then
        self:setLabelText("NowLabel_1", param[1], "JungongPanel")
    end
end

function InvadeDlg:bindButtonEvent(walkPanel)
    self:bindListener("GotoButton", self.onGotoButton0, "InfoPanel")
    self:bindListener("GotoButton", self.onGotoButton1, "InfoPanel_1")
    self:bindListener("GotoButton", self.onGotoButton2, "InfoPanel_2")
    self:bindListener("GotoButton", self.onGotoButton3, "InfoPanel_3")
    self:bindListener("GotoButton", self.onGotoButton4, "InfoPanel_4")
    self:bindListener("GotoButton", self.onGotoButton5, "InfoPanel_5")
    self:bindListener("GotoButton", self.onGotoButton6, "InfoPanel_6")
end

function InvadeDlg:showBossPanel()
    local taskInfo = TaskMgr:getYzrqTimeInfo()
    local born_time = (taskInfo and taskInfo.born_time) or 0
    local visible  = 0 ~= born_time and born_time < gf:getServerTime()

    self:setCtrlVisible("TitleLabel_3", visible, "WalkPanel")
    self:setCtrlVisible("InfoPanel_5", visible, "WalkPanel")
    self:setCtrlVisible("InfoPanel_6", visible, "WalkPanel")

    local scrollview = self:getControl("ScrollView")
    local walkPanel = self:getControl("WalkPanel")
    if visible then
        scrollview:setInnerContainerSize(walkPanel:getContentSize())
    else
        local cs = walkPanel:getContentSize()
        local sz1 = self:getControl("TitleLabel_3", nil, "WalkPanel"):getContentSize()
        local sz2 = self:getControl("InfoPanel_5", nil, "WalkPanel"):getContentSize()
        local sz3 = self:getControl("InfoPanel_6", nil, "WalkPanel"):getContentSize()
        scrollview:setInnerContainerSize({width = cs.width, height = cs.height - sz1.height - sz2.height - sz3.height})
        local delay = born_time - gf:getServerTime()
        if delay > 0 then
            performWithDelay(scrollview, function()
                self:showBossPanel()
            end, delay)
        end
    end
end

function InvadeDlg:onGotoButton0(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000218]))
    DlgMgr:closeDlg(self.name)
end

function InvadeDlg:onGotoButton1(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000219]))
    DlgMgr:closeDlg(self.name)
end

function InvadeDlg:onGotoButton2(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000220]))
    DlgMgr:closeDlg(self.name)
end

function InvadeDlg:onGotoButton3(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000221]))
    DlgMgr:closeDlg(self.name)
end

function InvadeDlg:onGotoButton4(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000222]))
    DlgMgr:closeDlg(self.name)
end

function InvadeDlg:onGotoButton5(sender, eventType)
    if self.curMonster then return end
    self.curMonster = CHS[2100064]
    gf:CmdToServer('CMD_YISHI_SEARCH_MONSTER', { monster_name = self.curMonster })
end

function InvadeDlg:onGotoButton6(sender, eventType)
    if self.curMonster then return end
    self.curMonster = CHS[2100065]
    gf:CmdToServer('CMD_YISHI_SEARCH_MONSTER', { monster_name = self.curMonster })
end

function InvadeDlg:MSG_YISHI_SEARCH_RESULT(data)
    if 0 == data.result then
        if CHS[2100064] == self.curMonster then
            gf:ShowSmallTips(CHS[2100066])
        elseif CHS[2100065] == self.curMonster then
            gf:ShowSmallTips(CHS[2100072])
        end
        self.curMonster = nil
        return
    end

    if CHS[2100064] == self.curMonster then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000223]))
    elseif CHS[2100065] == self.curMonster then
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2000224]))
    end

    DlgMgr:closeDlg(self.name)
end

return InvadeDlg