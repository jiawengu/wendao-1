-- AnniversaryLingMaoCombatDlg.lua
-- Created by huangzz Feb/08/2018
-- 灵猫切磋界面

local AnniversaryLingMaoCombatDlg = Singleton("AnniversaryLingMaoCombatDlg", Dialog)

local ONE_PAGE_NUM = 6 -- 分页加载好友列表，每页 6 条

function AnniversaryLingMaoCombatDlg:init(data)
    self:bindListener("MyLingMaoButton", self.onMyLingMaoButton)
    self:bindListener("CombatRecordButton", self.onCombatRecordButton)
    self:bindListener("ChallengeButton", self.onChallengeButton)
    self:bindListener("ChallengerImagePanel", self.onChallengerImagePanel)
    
    -- 好友列表
    self.lingmaoInfo = {}  -- 好友的灵猫数据
    self.friends = {}      -- 好友数据
    self.isFirstPage = true
    self.friendPanel = self:retainCtrl("FriendInfoPanel", "FriendPanel")
    self:initFriends()
    
    self.needLoadNum = 0
    self:requestLingMaoInfo(1)
    
    -- 我的灵猫
    self.lingmao = {}
    self:MSG_ZNQ_2018_MY_LINGMAO_INFO(data)
    
    -- 战报
    self.recordPanels = {}
    self.recordPanel = self:retainCtrl("RecordPanel", "CombatResultPanel")
    self:setRecordList()
    
    self:hookMsg("MSG_ZNQ_2018_FRIEND_LINGMAO_INFO")
    self:hookMsg("MSG_ZNQ_2018_MY_LINGMAO_INFO")
end

-- 创建灵猫对象
function AnniversaryLingMaoCombatDlg:createLimgmao(level, status, num)
    self:setCtrlVisible("Panel_1", false, "LingMaoMagicPanel")
    self:setCtrlVisible("Panel_2", false, "LingMaoMagicPanel")
    self:setCtrlVisible("Panel_3", false, "LingMaoMagicPanel")
    
    if status ~= 1 then
        return
    end
    
    local icon, tag = AnniversaryMgr:getCatCurShapeIcon(level)
    local panel = self:getControl("Panel_" .. tag, nil, "LingMaoMagicPanel")
    panel:setVisible(true)
    
    if self.lingmao[icon] then
        local mao = self.lingmao[icon]
        if num < 20 then
            if mao.curAction ~= "sick" then
                DragonBonesMgr:toPlay(mao, "sick", 0)
                mao.curAction = "sick"
            end
        else
            if mao.curAction ~= "stand" then
                DragonBonesMgr:toPlay(mao, "stand", 0)
                mao.curAction = "stand"
            end
        end
        return
    end

    local mao = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    local node = tolua.cast(mao, "cc.Node")
    local size = panel:getContentSize()
    node:setRotationSkewY(180)
    panel:addChild(node, 0)

    if num < 20 then
        DragonBonesMgr:toPlay(mao, "sick", 0)
        mao.curAction = "sick"
    else
        DragonBonesMgr:toPlay(mao, "stand", 0)
        mao.curAction = "stand"
    end
    
    self.lingmao[icon] = mao
end

function AnniversaryLingMaoCombatDlg:onMyLingMaoButton(sender, eventType)
    self:setCtrlVisible("MyLingMaoImage", true)
    self:setCtrlVisible("MyLingMaoPanel", true)
    self:setCtrlVisible("CombatRecordImage", false)
    self:setCtrlVisible("CombatResultPanel", false)
end

function AnniversaryLingMaoCombatDlg:onCombatRecordButton(sender, eventType)
    self:setCtrlVisible("MyLingMaoImage", false)
    self:setCtrlVisible("MyLingMaoPanel", false)
    self:setCtrlVisible("CombatRecordImage", true)
    self:setCtrlVisible("CombatResultPanel", true)
end

function AnniversaryLingMaoCombatDlg:setTwoLabelText(text, panel, index, color)
    self:setLabelText("Label" .. index, text, panel, color)
    self:setLabelText("Label" .. (index + 1), text, panel)
    self:setLabelText("Label" .. (index + 2), text, panel)
end

-- 设置我的灵猫数据
function AnniversaryLingMaoCombatDlg:setMyLingMaoView(data)
    if data.status == 1 then
        AnniversaryMgr:setLingMaoDataView(self, data, "OperatePanel")
        self:createLimgmao(data.level, data.status, math.min(data.food, data.mood))
    else
        AnniversaryMgr:setLingMaoDataView(self, {}, "OperatePanel")
        self:onCloseButton()
    end
    
    -- 可获得奖励的灵猫次数
    self:setLabelText("BonusTimeLabel_2", data.combat_num .. "/3")
end

function AnniversaryLingMaoCombatDlg:initFriends(data)
    self.friends = FriendMgr:getFriends({minlevel = 30})
    
    table.sort(self.friends, function(l, r) 
        if l.isOnline > r.isOnline then return false end
        if l.isOnline < r.isOnline then return true end

        if l.friendShip > r.friendShip then
            return true
        else
            return false
        end
    end)
    
    -- 滚动加载
    self:bindListViewByPageLoad("ListView", "TouchPanel", function(dlg, percent)
        if percent > 100 and not self.isFirstPage then
            -- 加载
            self:setFriendList()
        end
    end, "FriendPanel")
    
    -- self:setFriendList(true)
    if #self.friends <= 0 then
        self:setCtrlVisible("ListView", false, "FriendPanel")
        self:setCtrlVisible("NoticePanel", true, "FriendPanel")
        return
    else
        self:setCtrlVisible("ListView", true, "FriendPanel")
        self:setCtrlVisible("NoticePanel", false, "FriendPanel")
    end
end

-- 请求 index 起往后的 6 条好友的灵猫信息
function AnniversaryLingMaoCombatDlg:requestLingMaoInfo(index)
    local gidsStr = ""
    for i = index, index + ONE_PAGE_NUM - 1 do
        if self.friends[i] then
            if gidsStr == "" then
                gidsStr = self.friends[i].gid
            else
                gidsStr = gidsStr .. "|" .. self.friends[i].gid
            end
            
            self.needLoadNum = self.needLoadNum + 1
        end
    end
    
    if gidsStr ~= "" then
        AnniversaryMgr:requestFriendsLingMaoInfo(gidsStr)
    end
end

function AnniversaryLingMaoCombatDlg:setOneFriendPanel(data, cell)
    -- 头像
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)
    self:setItemImageSize("PortraitImage", cell)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.lev or 1, false, LOCATE_POSITION.LEFT_TOP, 23, cell)

    -- 名字
    self:setLabelText("NameLabel", data.name, cell)
    
    -- 灵猫信息
    local info = self.lingmaoInfo[data.gid]
    if data.isOnline ~= 1 or not info then
        self:setCtrlVisible("LingMaoInfoPanel", false, cell)
        self:setCtrlVisible("LingMaoErrorPanel", true, cell)
        self:setLabelText("ErrorLabel", CHS[5400491], cell)
        
        -- 置灰头像
        local img = self:getControl("PortraitImage", nil, cell)
        gf:grayImageView(img)
    elseif info.level >= 0 then
        self:setCtrlVisible("LingMaoErrorPanel", false, cell)
        self:setCtrlVisible("LingMaoInfoPanel", true, cell)
        
        self:setLabelText("LevelLabel", info.level .. CHS[7002280], cell)
        
        local foodStatus = AnniversaryMgr:getCatFoodStatus(info.food)
        self:setLabelText("FoodLabel", foodStatus.status, cell)
        self:setImage("FoodImage", foodStatus.icon, cell)
        
        local moodStatus = AnniversaryMgr:getCatMoodStatus(info.mood)
        self:setLabelText("MoodLabel", moodStatus.status, cell)
        self:setImage("MoodImage", moodStatus.icon, cell)
        self:setLabelText("TipLabel", "", cell)
    else
        -- 好友离线没有灵猫数据
        self:setCtrlVisible("LingMaoInfoPanel", false, cell)
        self:setCtrlVisible("LingMaoErrorPanel", true, cell)
        if info.level == -2 or info.level == -4 then
            self:setLabelText("ErrorLabel", CHS[5400491], cell)
        elseif info.level == -1 then
            self:setLabelText("ErrorLabel", CHS[5400492], cell)
        else
            self:setLabelText("ErrorLabel", CHS[5400493], cell)
        end
    end
    
    -- 战斗相关
    self:setCtrlVisible("CombatImage", false, cell)
    self:setCtrlVisible("CombatFinishImage", false, cell)
    self:setCtrlVisible("ChallengeButton", false, cell)
    if info and info.combat_status == 1 then
        self:setCtrlVisible("CombatImage", true, cell)
        self:setCtrlVisible("ChallengeButton", true, cell)
        self:setTwoLabelText(CHS[5400467], self:getControl("ChallengeButton", nil, cell), 1)
    elseif info and info.combat_status == 2 then
        self:setCtrlVisible("CombatFinishImage", true, cell)
    else
        self:setCtrlVisible("ChallengeButton", true, cell)
        self:setTwoLabelText(CHS[5400466], self:getControl("ChallengeButton", nil, cell), 1)
    end
    
    cell.data = data
end

-- 创建化好友列表
function AnniversaryLingMaoCombatDlg:setFriendList(isReset)
    local data = self.friends or {}

    if #data <= 0 then
        return
    end
    
    local list = self:getControl("ListView", nil, "FriendPanel")
    if isReset then
        list:removeAllItems()
        self.loadNum = 1
    end
    
    if not data[self.loadNum] then
        return
    end

    local loadNum = self.loadNum
    for i = 1, ONE_PAGE_NUM do
        if data[loadNum] then
            local cell = self.friendPanel:clone()
            cell:setName(data[loadNum].gid)
            self:setOneFriendPanel(data[loadNum], cell)
            list:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end
    
    if loadNum > self.loadNum and data[loadNum] then
        -- 请求下一页的 6 条好友的灵猫信息
        self:requestLingMaoInfo(loadNum)
    end

    list:doLayout()
    list:refreshView()
    self.loadNum = loadNum
end

function AnniversaryLingMaoCombatDlg:setOneRecord(data, cell, tag)
    -- 胜负
    if data.vectory_status == 0 then
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, cell)
    elseif data.vectory_status == 1 then
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, cell)
    else
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_draw, cell)
    end

    -- 对方信息
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.player_icon), cell)
    self:setItemImageSize("PortraitImage", cell)
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, data.player_level or 1, false, LOCATE_POSITION.LEFT_TOP, 23, cell)
    self:setLabelText("NameLabel", data.player_name, cell)

    -- 挑战时间
    local combatStr = ArenaMgr:getRecordTimestr(data.record_time)
    if data.challenge_staus == 0 then
        combatStr = combatStr .. CHS[5400292]
    else
        combatStr = combatStr .. CHS[5400293]
    end

    self:setLabelText("CombatLabel", combatStr, cell)
    
    self:setCtrlVisible("BKImage_2", tag % 2 == 1, cell)

    cell.data = data
end

function AnniversaryLingMaoCombatDlg:onChallengerImagePanel(sender, eventType)
    local data = sender:getParent().data
    if data then
        local dlg = DlgMgr:openDlg("CharMenuContentDlg")
        FriendMgr:requestCharMenuInfo(data.gid)
        if FriendMgr:getCharMenuInfoByGid(data.gid) then
            dlg:setting(data.gid)
        else
            local char = {}
            char.gid = data.gid
            char.name = data.player_name
            char.level = data.player_level or 1
            char.icon = data.player_icon or 06002
            char.isOnline = 2
            dlg:setInfo(char)
        end

        local rect = self:getBoundingBoxInWorldSpace(sender)
        dlg:setFloatingFramePos(rect)
    end
end

-- 初值化战报
function AnniversaryLingMaoCombatDlg:setRecordList()
    local recordTable = ArenaMgr:getRecordData("znq_2018_xylm")
    local listView = self:resetListView("ListView", nil, nil, "CombatResultPanel")
    local cou = #recordTable

    if cou == 0 then
        self:setCtrlVisible("NoticePanel", true, "CombatResultPanel")
        return
    end

    self:setCtrlVisible("NoticePanel", false, "CombatResultPanel")

    for i = cou, 1, -1 do
        local cell = self:getRecordPanel(i)
        self:setOneRecord(recordTable[i], cell, cou - i + 1)
        listView:pushBackCustomItem(cell)
    end
end

function AnniversaryLingMaoCombatDlg:getRecordPanel(i)
    if self.recordPanels[i] then
        return self.recordPanels[i]
    else
        self.recordPanels[i] = self.recordPanel:clone()
        self.recordPanels[i]:retain()
        return self.recordPanels[i]
    end
end

function AnniversaryLingMaoCombatDlg:onChallengeButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5400573])
        return
    end

    if Me:isLookOn() then
        gf:ShowSmallTips(CHS[5400574])
        return
    end

    local data = sender:getParent().data
    if data then
        local info = self.lingmaoInfo[data.gid] or {}
        if info.combat_status == 0 then
            gf:CmdToServer("CMD_ZNQ_2018_LINGMAO_FIGHT", {gid = data.gid})
        elseif info.combat_status == 1 then
            gf:CmdToServer("CMD_ZNQ_2018_LOOKON", {gid = data.gid})
        end
        
        DlgMgr:sendMsg("AnniversaryLingMaoDlg", "setNeedCloseWhenLookon")
    end
end

function AnniversaryLingMaoCombatDlg:MSG_ZNQ_2018_FRIEND_LINGMAO_INFO(data)
    self.lingmaoInfo[data.gid] = data
    if self.isFirstPage then
        -- 第一页数据要等收到所有消息后再加载
        self.needLoadNum = self.needLoadNum - 1
        if self.needLoadNum == 0 then
            self.isFirstPage = false
            self:setFriendList(true)
        end
    else
        local list = self:getControl("ListView", nil, "FriendPanel")
        if not string.isNilOrEmpty(data.gid) then
            local cell = list:getChildByName(data.gid)
            if cell then
                self:setOneFriendPanel(cell.data, cell)
            end
        end
    end
end

function AnniversaryLingMaoCombatDlg:MSG_ZNQ_2018_MY_LINGMAO_INFO(data)
    self:setMyLingMaoView(data)
end

function AnniversaryLingMaoCombatDlg:cleanup()
    if self.recordPanels then
        for _, v in pairs(self.recordPanels) do
            v:release()
        end
    end
    
    for icon, mao in pairs(self.lingmao) do
        DragonBonesMgr:removeCharDragonBonesResoure(icon,  string.format("%05d", icon))
    end
    
    self.recordPanels = nil
    self.lingmaoInfo = nil
    self.lingmao = {}
end

return AnniversaryLingMaoCombatDlg
