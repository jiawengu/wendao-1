-- DebugDlg.lua
-- created by cheny Oct/14/2014
-- 战斗对话框

require "mgr/FightMgr"

local DebugDlg = Singleton("DebugDlg", Dialog)

function DebugDlg:init()
    self:setFullScreen()
    self:bindListener("ObstacleButton", self.onObstacleButton)
    self:bindListener("LaojunButton", self.onLaojunButton)
    self:bindListener("ShowErrButton", self.onShowErrButton)
    self:bindListener("ExitButton", self.onExitButton)
    self:bindListener("CharButton", self.onCharButton)
    self:bindListener("AddNewOneButton", self.onAddNewButton)
    self:bindListener("UpdateMeButton", self.onUpdateMeButton)
    self:bindListener("TestSkillButton", self.onTestSkillButton)
end

function DebugDlg:onLaojunButton()
    gf:CmdToServer("CMD_CHAT_EX", {
        channel = 1,
        compress = 0,
        orgLength = 0,
        msg = "//"
    })
end

function DebugDlg:onObstacleButton()
    GameMgr.scene:showObstacle()
end

function DebugDlg:onShowErrButton()
    local err = Log.emsg
    if string.len(err) == 0 then
        gf:ShowSmallTips(CHS[3002381])
        local localRightPanel = self:getControl("RightPanel", Const.UIPanel)
        localRightPanel:setVisible(false)
    else
        local localRightPanel = self:getControl("RightPanel", Const.UIPanel)
        localRightPanel:setVisible(true)

        local localContentLabel = self:getControl("ContentLabel", Const.UILabel)
        localContentLabel:setVisible(true)
        self:setLabelText("ContentLabel", err)

        local localCharControlPanel = self:getControl("CharControlPanel", Const.UIPanel)
        localCharControlPanel:setVisible(false)
    end
end

function DebugDlg:onAddNewButton()
    local localIcon = self:getInputText("InputTextField")
    if string.len(localIcon) == 0 then
        return

    end

    local x, y = gf:convertToMapSpace(Me.curX, Me.curY)
    local dir = Me.dir
    local id = math.random(1,9999)
    -- Me:
    --self:checkPos(map.x, map.y)
    --self:checkDir(map.dir)

    --local char = self:getChar(map.id)

    --CharMgr:MSG_APPEAR({})

    CharMgr:MSG_APPEAR({x = x, y = y, dir = dir, id = id, icon = localIcon, type = OBJECT_TYPE.CHAR, name = id})
end

function DebugDlg:onUpdateMeButton()
    --Me:getIcon()
    --Me:setBasic('icon', 6005)

    local localIcon = self:getInputText("InputTextField")
    if string.len(localIcon) == 0 then
        return
    end

    Me:MSG_UPDATE({icon = localIcon})
    --Me:setIcon(6005)
end

function DebugDlg:onExitButton()
    gf:EndGame()
end

function DebugDlg:onCharButton()
    local localRightPanel = self:getControl("RightPanel", Const.UIPanel)
    localRightPanel:setVisible(true)

    local localContentLabel = self:getControl("ContentLabel", Const.UILabel)
    localContentLabel:setVisible(false)
    --self:setLabelText("ContentLabel", err)

    local localCharControlPanel = self:getControl("CharControlPanel", Const.UIPanel)
    localCharControlPanel:setVisible(true)
end

function DebugDlg:onTestSkillButton()
    DlgMgr:openDlg('TestSkillDlg')
end

return DebugDlg