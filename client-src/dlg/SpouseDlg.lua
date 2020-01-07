-- SpouseDlg.lua
-- Created by huangzz Aug/14/2018
-- 夫妻动作选择接界面

local SpouseDlg = Singleton("SpouseDlg", Dialog)


local BTN_CFG = {
    {text = CHS[5450324], score = 70000, icon = ResMgr.ui.spouse_action_jiaobei, status = Const.NS_A_JIAOBEI },
    {text = CHS[5450323], score = 150000, icon = ResMgr.ui.spouse_action_baobao,  status = Const.NS_A_BAOBAO },
    {text = CHS[5450322], score = 250000, icon = ResMgr.ui.spouse_action_qinqin,  status = Const.NS_A_QINQIN  },
}

function SpouseDlg:init()
    self:bindListener("Button", self.onButton, "SinglePanel")
    self.singlePanel = self:retainCtrl("SinglePanel")

    self.delayId = nil

    self.root:setAnchorPoint(0, 0)
end

function SpouseDlg:setData(char)
    self.char = char

    self:initButtons(char)
end

function SpouseDlg:initButtons(char)
    if not char then return end

    local x = 2
    local y = 1
    local height = 62
    local score = FriendMgr:getFriendScore(char.gid) or char.friend_score or 0
    local panel = self:getControl("OperatePanel")
    local cou = #BTN_CFG
    for i = cou, 1, -1 do
        local cell = self.singlePanel:clone()
        cell:setPosition(x, y)

        self:setLabelText("Label", BTN_CFG[i].text, cell)
        self:setImage("Image", BTN_CFG[i].icon, cell)

        if score < BTN_CFG[i].score then
            gf:grayImageView(self:getControl("Button", nil, cell))
        end

        cell.cfgInfo = BTN_CFG[i]
        panel:addChild(cell)

        y = y + height
    end

    local size = self.root:getContentSize()
    self.root:setContentSize(size.width, height * cou + 20)
end

function SpouseDlg:setFloatingFramePos(rect)
    local midX = rect.x / Const.UI_SCALE + rect.width * 0.5
    local size = self.root:getContentSize()
    if midX + size.width >= (Const.WINSIZE.width/ Const.UI_SCALE) - size.width - 10 then
        -- 显示在左边
        local pos = cc.p(rect.x / Const.UI_SCALE - size.width, (rect.y + rect.height) / Const.UI_SCALE - size.height)
        self.root:setPosition(pos)
    else
        -- 显示在右边
        local pos = cc.p((rect.x + rect.width) / Const.UI_SCALE, (rect.y + rect.height) / Const.UI_SCALE - size.height)
        self.root:setPosition(pos)
    end
end

function SpouseDlg:teamMemberHasMoves()
    local members = TeamMgr.members
    for i = 1, #members do
        local char = CharMgr:getCharById(members[i].id)
        if char then
            local queue = char.moveCmds
            local count = queue:size()
            if count > 0 then
                return true
            end
        end
    end
end

function SpouseDlg:onButton(sender, eventType)
    if not self.char then
        return
    end

    local info = sender:getParent().cfgInfo
    if not info then
        return
    end

    local char = self.char
    local actionName = string.gsub(info.text, " ", "")
    local score = FriendMgr:getFriendScore(char.gid) or char.friend_score or 0

    if not MarryMgr:isMarried() then
        gf:ShowSmallTips(CHS[5450325])
        return
    end

    if score < info.score then
        gf:ShowSmallTips(string.format(CHS[5450326], actionName, info.score))
        return
    end

    local lover = MarryMgr:getLoverInfo()
    if lover and (TeamMgr:getTeamTotalNum() ~= 2 or not TeamMgr:coupleIsInTeamEx()) then
        gf:ShowSmallTips(string.format(CHS[5450327], lover.relation))
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003663])
        return
    end

    if lover and not TeamMgr:coupleIsInTeam() and Me:isTeamLeader() then
        gf:ShowSmallTips(string.format(CHS[5450328], lover.name))
        return
    elseif not TeamMgr:inTeam(Me:getId()) then
        gf:ShowSmallTips(CHS[5450331])
        return
    end

    if self.delayId then
        self.root:stopAction(self.delayId)
    end

    if Me:isTeamLeader() then
        -- 队长需要确保所有角色都站立才可播动作
        local members = TeamMgr.members
        for i = 1, #members do
            local char = CharMgr:getCharById(members[i].id)
            if char then
                AutoWalkMgr:stopAutoWalk()
                if char:isWalkAction() then
                    char:setAct(Const.FA_STAND)
                else
                    char:resetGotoEndPos()
                end

                char:sendAllLeftMoves()
            end
        end

        local startTime = gfGetTickCount()
        local function func()
            if Me:isWalkAction() then
                -- 角色又走动了，不播动作
                self.root:stopAction(self.delayId)
                self.delayId = nil
                return
            end

            if not self:teamMemberHasMoves() then
                CharMgr:setActionStatus(info.status)
                self.root:stopAction(self.delayId)
                self.delayId = nil
            end

            local curTime = gfGetTickCount()
            if curTime - startTime > 3000 then
                self.root:stopAction(self.delayId)
                self.delayId = nil
            end
        end

        self.delayId = schedule(self.root, func, 0)

        func()
    elseif not Me:isWalkAction() then
        -- 队员播动作时，有走动会直接停掉。
        CharMgr:setActionStatus(info.status)
    else 
        DlgMgr:closeDlg("CharMenuContentDlg")
    end
end

return SpouseDlg
