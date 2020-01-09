-- CharPortraitDlg.lua
-- Created by Chang_back Jun/4/2015
-- 目标头像框

local CharPortraitDlg = Singleton("CharPortraitDlg", Dialog)
local MARGIN_TOP = 20

function CharPortraitDlg:init()
    if MapMgr:isInYuLuXianChi() then
        self:setFullScreen()
        local panel = self:getControl("PortraitPanel")
        local winSize = self:getWinSize()
        panel:setPosition(winSize.width / Const.UI_SCALE - 74, winSize.height / Const.UI_SCALE  - 160) 
    end

    self.portraitImage = self:getControl("PortraitImage")
    self.teamImage = self:getControl("TeamImage")
    self:bindListener("PortraitPanel", self.showTarget)
    self:bindListener("FightButton", self.onFightButton, "QuickFightPanel")
    local path = ResMgr:getSmallPortrait(Me.selectTarget:queryBasicInt("icon"))
    self.portraitImage:loadTexture(path)
    self:setItemImageSize("PortraitImage")
    self:setNumImgForPanel(
                            "LevelPanel",
                            ART_FONT_COLOR.NORMAL_TEXT,
                            Me.selectTarget:queryBasicInt("level"),
                            false,
                            LOCATE_POSITION.CENTER, 21
                           )

    if not Me.selectTarget:isTeamLeader() then
        self.teamImage:setVisible(false)
    else
        self.teamImage:setVisible(true)
    end

    self:showFightButton(Me.selectTarget)

    self.char = nil
end

function CharPortraitDlg:showFightButton(char)
    if not char then
        self:setCtrlVisible("QuickFightPanel", false);
        return
    end

    self:setCtrlVisible("QuickFightPanel", true)
    if MapMgr:isInMasquerade() and (not TeamMgr:inTeam(char:getId()) or not TeamMgr:inTeam(Me:getId())) then
        -- 化妆舞会
        self:setButtonText("FightButton", CHS[5400617], "QuickFightPanel")
    elseif MapMgr:isInOreWars() and char:queryBasic("title") ~= "" and char:queryBasic("title") ~= Me:queryBasic("title") then
        -- 矿石大战
        self:setButtonText("FightButton", CHS[5400618], "QuickFightPanel")
    elseif MapMgr:isInBeastsKing() and (not TeamMgr:inTeam(char:getId()) or not TeamMgr:inTeam(Me:getId())) then
        -- 百兽争霸
        self:setButtonText("FightButton", CHS[5400619], "QuickFightPanel")
    elseif DistMgr:isInKFZC2019Server() then
        self:setButtonText("FightButton", CHS[5400466], "QuickFightPanel")
    else
        self:setCtrlVisible("QuickFightPanel", false);
    end
end

function CharPortraitDlg:setChar(char)
    self.char = char
end

function CharPortraitDlg:showTarget(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        local charTargetGid = self.selectTargetId

        if not charTargetGid then DlgMgr:closeDlg(self.name) return end
        if DlgMgr:isDlgOpened("CharMenuContentDlg") then return end

        if MapMgr:isInMasquerade() and self.char and self.char:queryBasicInt("masquerade") == 1 then
            -- 化妆舞会的怪物，特殊处理
            local dlg = DlgMgr:openDlg("CharMenuContentDlg")
            dlg:setting(charTargetGid)
            dlg:setInfoByDataObject(self.char)
            dlg:setMuneType(CHAR_MUNE_TYPE.SCENE)
            dlg:setMonsterInMasqueradeInfo()
            self:onCloseButton()
            return
        end

        FriendMgr:requestCharMenuInfo(charTargetGid)
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        dlg:setting(charTargetGid)
        if self.char then
            dlg:setInfoByDataObject(self.char)
        end
        dlg:setMuneType(CHAR_MUNE_TYPE.SCENE)

        self:onCloseButton()
    end
end

function CharPortraitDlg:onFightButton(sender, eventType)
    if GameMgr:IsCrossDist() and not DistMgr:isInZBYLServer() and not DistMgr:isInQcldServer() and not QuanminPK2Mgr:isCanFightInQuanmpk() and not DistMgr:isInKFZC2019Server() then
        gf:ShowSmallTips(CHS[5000267])
        return
    end

    if Me:isInPrison() then
        gf:ShowSmallTips(CHS[7000070])
        return
    end

    if not self.char then return end
    gf:CmdToServer("CMD_KILL", {victim_id = self.char:getId(), flag = 0, gid = (self.char:queryBasic("gid") or "") })
end

function CharPortraitDlg:setSelectTarget(targetId)
    self.selectTargetId = targetId
end

-- 重载close
function CharPortraitDlg:close(now)
    self.selectTarge = nil
    Dialog.close(self, now)
    if Me.selectTarget then
        Me.selectTarget:removeFocusMagic()
    end

    FriendMgr:unrequestCharMenuInfo(self.name)
end

function CharPortraitDlg:onCharInfo(gid)
    local dlg = DlgMgr:openDlg("CharMenuContentDlg")
    if dlg then
        dlg:setting(gid)
        dlg:setMuneType(CHAR_MUNE_TYPE.SCENE)
    end
end

return CharPortraitDlg
