-- TeamEnlistDlg.lua
-- Created by huangzz Oct/16/2018
-- 固定招募平台

local TeamEnlistDlg = Singleton("TeamEnlistDlg", Dialog)

local ENLIST_TYPE = {
    PLAYER = "player",
    TEAM = "team",
}

-- 系别
local POLAR_TYPE = {
    [0] = CHS[4200046],  -- 任意系
    [1] = CHS[3000253],
    [2] = CHS[3000256],
    [3] = CHS[3000259],
    [4] = CHS[3000261],
    [5] = CHS[3000263],

    [CHS[4200046]] = 0, -- 不限
    [CHS[3000253]] = 1,
    [CHS[3000256]] = 2,
    [CHS[3000259]] = 3,
    [CHS[3000261]] = 4,
    [CHS[3000263]] = 5,
}

-- 加点偏向
local POINT_TYPE = {
    [0] = CHS[4200046], -- 任意型
    [1] = CHS[5410281], -- 灵力型
    [2] = CHS[5410282], -- 体质型
    [3] = CHS[5410283], -- 敏捷型
    [4] = CHS[5410280], -- 力量型


    [CHS[4200046]] = 0, -- 不限
    [CHS[5410281]] = 1, -- 灵力型
    [CHS[5410282]] = 2, -- 体质型
    [CHS[5410283]] = 3, -- 敏捷型
    [CHS[5410280]] = 4, -- 力量型

}

local POINT_TYPE_ICON = {
    [1] = ResMgr.ui.fixed_team_pt_type_lingli, -- 灵力型
    [2] = ResMgr.ui.fixed_team_pt_type_tizhi, -- 体质型
    [3] = ResMgr.ui.fixed_team_pt_type_minjie, -- 敏捷型
    [4] = ResMgr.ui.fixed_team_pt_type_liliang, -- 力量型
}

local ONE_LOAD_MESSAGE_NUM = 10

function TeamEnlistDlg:init()
    self:bindListener("PlayerEnlistButton", self.onPlayerEnlistButton)
    self:bindListener("TeamEnlistButton", self.onTeamEnlistButton)

    local panel = self:getControl("PlayerEnlistPanel")
    local cPanel1 = self:getControl("ChoosePanel1", nil, panel)
    self:bindListener("DownChangeButton", self.onPolarPanel, cPanel1)
    self:bindListener("ChoosePanel1", self.onPolarPanel)
    self:bindListener("UpChangeButton", self.onPolarPanel, cPanel1)

    local cPanel2 = self:getControl("ChoosePanel2", nil, panel)
    self:bindListener("DownChangeButton", self.onPointPanel, cPanel2)
    self:bindListener("ChoosePanel2", self.onPointPanel)
    self:bindListener("UpChangeButton", self.onPointPanel, cPanel2)

    self:bindListener("RefreshButton", self.onRefreshPlayerButton, panel)
    self:bindListener("EnlistButton", self.onEnlistPlayerButton, panel)
    self:bindListener("CancelButton", self.onCancelPlayerButton, panel)

    local panel = self:getControl("TeamEnlistPanel")
    self:setCheck("CheckBox", false, self:getControl("ChoosePanel1", nil, panel))
    self:setCheck("CheckBox", false, self:getControl("ChoosePanel2", nil, panel))
    self.needCheckPolar = 0
    self.needCheckPoint = 0

    self:bindListener("RefreshButton", self.onRefreshTeamButton, panel)
    self:bindListener("EnlistButton", self.onEnlistTeamButton, panel)
    self:bindListener("CancelButton", self.onCancelTeamButton, panel)

    self.listViews= {}
    self.listViews[ENLIST_TYPE.PLAYER] = self:getControl("ListView", nil, "PlayerEnlistPanel")
    self.listViews[ENLIST_TYPE.TEAM] = self:getControl("ListView", nil, "TeamEnlistPanel")
    self.ctrlClone = {}
    self.ctrlClone[ENLIST_TYPE.PLAYER] = self:retainCtrl("PlayerPanel", "PlayerEnlistPanel")
    self.ctrlClone[ENLIST_TYPE.TEAM] = self:retainCtrl("TeamPanel", "TeamEnlistPanel")

    self.enlistMsgList = {}
    self.curLoadIndex = {[ENLIST_TYPE.PLAYER] = -1, [ENLIST_TYPE.TEAM] = -1}
    self.isFinishLoad = {}
    self.lastRequestMessageIId = {}
    self.myInfo = {}
    self.requestDetailType = nil
    self.needOpenDlg = nil
    self.needCheckUserCard = nil
    self.curShowIndex = 0
    self.isRefresh = {}
    self.isRequest = {}

    self:doSelectPolar(CHS[4200046])
    self:doSelectPoint(CHS[4200046])

    if TeamMgr:checkHasFixedTeam() then
        self:onPlayerEnlistButton(self:getControl("PlayerEnlistButton"))
    else
        self:onTeamEnlistButton(self:getControl("TeamEnlistButton"))
    end

    self:initView("PlayerListPanel", ENLIST_TYPE.PLAYER)
    self:initView("TeamListPanel", ENLIST_TYPE.TEAM)

    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_SINGLE_DETAIL")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_MY_SINGLE")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST_EX")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_TEAM_LIST_EX")

    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_TEAM_DETAIL")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_TEAM_LIST")
    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_MY_TEAM")
    self:hookMsg("MSG_CARD_INFO")
    self:hookMsg("MSG_FIXED_TEAM_DATA")
end

-- 初始化列表
function TeamEnlistDlg:initView(panelName, type)
    self:setCtrlVisible("NoticePanel", false, panelName)
    self:setCtrlVisible("NoticePanel2", false, panelName)

    local size = self.ctrlClone[type]:getContentSize()
    local function onScrollView(sender, eventType)
        if self.notCallListView then
            return
        end
        
        if ccui.ScrollviewEventType.scrolling == eventType 
                or ccui.ScrollviewEventType.scrollToTop == eventType 
                or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件
            local listViewCtrl = sender
            local listInnerContent = listViewCtrl:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local scrollViewSize = listViewCtrl:getContentSize()
            
            local items = listViewCtrl:getItems()
            if #items <= 0 then
                return
            end

            -- 计算滚动的百分比
            local innerPosY = math.floor(listInnerContent:getPositionY() + 0.5)
            if innerPosY >= -(size.height * 3) then
                -- 向下加载
                local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM, type)
                if 0 == #moreData then
                    -- 没有数据了
                    return
                end

                self:refreshList(moreData, type)
            end
        end
    end
   
     
    self:getControl("ListView", nil, panelName):addScrollViewEventListener(onScrollView)
end

function TeamEnlistDlg:onPlayerEnlistButton(sender, eventType)
    self:setCtrlVisible("SelectedImage", false, "TeamEnlistButton")
    self:setCtrlVisible("SelectedImage", true, sender)

    self:setCtrlVisible("PlayerEnlistPanel", true)
    self:setCtrlVisible("TeamEnlistPanel", false)

    self.curShowType = ENLIST_TYPE.PLAYER

    if not self.enlistMsgList[ENLIST_TYPE.PLAYER] then
        self:requestMoreEnlist(ENLIST_TYPE.PLAYER)
    end

    self:setLabelText("InfoLabel", CHS[5410317], "UpperPanel")
end

function TeamEnlistDlg:onTeamEnlistButton(sender, eventType)
    self:setCtrlVisible("SelectedImage", false, "PlayerEnlistButton")
    self:setCtrlVisible("SelectedImage", true, sender)

    self:setCtrlVisible("PlayerEnlistPanel", false)
    self:setCtrlVisible("TeamEnlistPanel", true)

    self.curShowType = ENLIST_TYPE.TEAM

    if not self.enlistMsgList[ENLIST_TYPE.TEAM] then
        self:requestMoreEnlist(ENLIST_TYPE.TEAM)
    end

    self:setLabelText("InfoLabel", CHS[5410318], "UpperPanel")
end

-- 系别选项
function TeamEnlistDlg:onPolarPanel(sender, eventType)
    local choosePanel = self:getControl("ChoosePanel1", nil, "PlayerEnlistPanel")
    local btn = self:getControl("DownChangeButton", nil, choosePanel)
    if btn:isVisible() then
        btn:setVisible(false)
        self:setCtrlVisible("UpChangeButton", true, choosePanel)
    else
        btn:setVisible(true)
        self:setCtrlVisible("UpChangeButton", false, choosePanel)
        BlogMgr:showButtonList(self, choosePanel, "playerEnlistPolar", self.name, {excepts = {[POLAR_TYPE[self.selectPolar]] = true}})
    end
end

-- 加点偏向选项
function TeamEnlistDlg:onPointPanel(sender, eventType)
    local choosePanel = self:getControl("ChoosePanel2", nil, "PlayerEnlistPanel")
    local btn = self:getControl("DownChangeButton", nil, choosePanel)
    if btn:isVisible() then
        btn:setVisible(false)
        self:setCtrlVisible("UpChangeButton", true, choosePanel)
    else
        btn:setVisible(true)
        self:setCtrlVisible("UpChangeButton", false, choosePanel)
        BlogMgr:showButtonList(self, choosePanel, "playerEnlistPoint", self.name, {excepts = {[POINT_TYPE[self.selectPoint]] = true}})
    end
end

function TeamEnlistDlg:doCloseButtonListDlg()
    local choosePanel = self:getControl("ChoosePanel1", nil, "PlayerEnlistPanel")
    self:setCtrlVisible("DownChangeButton", false, choosePanel)
    self:setCtrlVisible("UpChangeButton", true, choosePanel)

    local choosePanel = self:getControl("ChoosePanel2", nil, "PlayerEnlistPanel")
    self:setCtrlVisible("DownChangeButton", false, choosePanel)
    self:setCtrlVisible("UpChangeButton", true, choosePanel)
end

function TeamEnlistDlg:doSelectPolar(name)
    self.selectPolar = POLAR_TYPE[name] or 0

    local choosePanel = self:getControl("ChoosePanel1", nil, "PlayerEnlistPanel")
    if self.selectPolar == 0 then
        self:setLabelText("TypeLabel", CHS[5410284], choosePanel)
    else
        self:setLabelText("TypeLabel", POLAR_TYPE[self.selectPolar], choosePanel)
    end
end

function TeamEnlistDlg:doSelectPoint(name)
    self.selectPoint = POINT_TYPE[name]

    local choosePanel = self:getControl("ChoosePanel2", nil, "PlayerEnlistPanel")
    if self.selectPoint == 0 then
        self:setLabelText("TypeLabel", CHS[5410285], choosePanel)
    else
        self:setLabelText("TypeLabel", POINT_TYPE[self.selectPoint], choosePanel)
    end
end

function TeamEnlistDlg:onRefreshTeamButton(sender, eventType)
    local hasPolar = self:isCheck("CheckBox", self:getControl("ChoosePanel1", nil, "TeamEnlistPanel"))
    local hasPoint = self:isCheck("CheckBox", self:getControl("ChoosePanel2", nil, "TeamEnlistPanel"))

    self.needCheckPolar = hasPolar and 1 or 0
    self.needCheckPoint = hasPoint and 1 or 0

    local curTime = gf:getServerTime()
    if self.lastRequestTeamTime and curTime - self.lastRequestTeamTime < 5 then
        gf:ShowSmallTips(string.format(CHS[5410306], math.max(1, 5 - curTime + self.lastRequestTeamTime)))
        return
    end

    self.lastRequestTeamTime = curTime
    self.isRefresh[ENLIST_TYPE.TEAM] = true

    self:requestMoreEnlist(ENLIST_TYPE.TEAM, true)
end

function TeamEnlistDlg:onRefreshPlayerButton(sender, eventType)
    local curTime = gf:getServerTime()
    if self.lastRequestPlayerTime and curTime - self.lastRequestPlayerTime < 5 then
        gf:ShowSmallTips(string.format(CHS[5410306], math.max(1, 5 - curTime + self.lastRequestPlayerTime)))
        return
    end

    self.lastRequestPlayerTime = curTime
    self.isRefresh[ENLIST_TYPE.PLAYER] = true

    self:requestMoreEnlist(ENLIST_TYPE.PLAYER, true)
end

-- 发布人物招募
function TeamEnlistDlg:onEnlistPlayerButton(sender, eventType)
    if not self.myInfo[ENLIST_TYPE.PLAYER] then return end

    self:requestOneDetailEnlist(self.myInfo[ENLIST_TYPE.PLAYER], ENLIST_TYPE.PLAYER)
end

-- 撤回发布
function TeamEnlistDlg:onCancelPlayerButton(sender, eventType)
    if not self.myInfo[ENLIST_TYPE.PLAYER] then return end

    self:requestOperEnlist(2, nil, ENLIST_TYPE.PLAYER)
end

function TeamEnlistDlg:onPlayerMatchPanel(sender, eventType)
    if not sender.data then return end

    self:requestOneDetailEnlist(sender.data, ENLIST_TYPE.PLAYER)
end

function TeamEnlistDlg:onPortraitPanel(sender, eventType)
    local data = sender:getParent().data
    self:requesrUserCard(data)
end

-- 发布/撤销队伍招募
function TeamEnlistDlg:onEnlistTeamButton(sender, eventType)
    if not self.myInfo[ENLIST_TYPE.TEAM] then return end

    self:requestOneDetailEnlist(self.myInfo[ENLIST_TYPE.TEAM], ENLIST_TYPE.TEAM)
end

function TeamEnlistDlg:onCancelTeamButton(sender, eventType)
    if not self.myInfo[ENLIST_TYPE.TEAM] then return end

    self:requestOperEnlist(2, nil, ENLIST_TYPE.TEAM)
end

function TeamEnlistDlg:onTeamMatchPanel(sender, eventType)
    if not sender.data then return end

    self:requestOneDetailEnlist(sender.data, ENLIST_TYPE.TEAM)
end

-- 设置组队条目
function TeamEnlistDlg:setTeamPanel(cell, data)
    if not data then
        cell:setVisible(false)
        return
    end

    if data.index == 0 then
        self:setImage("BKImage", ResMgr.ui.green_panel_back, cell)
    else
        self:setImage("BKImage", ResMgr.ui.normal_panel_back, cell)
    end

    self:setImage("TeamLvImage", ResMgr.ui["fixed_team_level" .. (data.team_level or "")], cell)

    self:setLabelText("NameLabel", data.team_name .. CHS[5410309], cell)

    self:setLabelText("LevelLabel", string.format(CHS[5410286], data.ave_level), cell)

    self:setLabelText("TaoLabel", string.format(CHS[5410287], gf:getTaoStr(data.ave_tao)), cell)

    self:setLabelText("PlayerNumLabel", data.team_num .. CHS[4200575], cell)

    self:setLabelText("ConditionLabel", string.format(CHS[5410288], data.req_str), cell)

    if data.short_msg then
        self:setLabelText("MessageLabel", data.short_msg, cell)
    elseif data.msg then
        local lenth, num = gf:getTextLength(data.msg)
        if num > 40 then
            self:setLabelText("MessageLabel", gf:getTextByNum(data.msg, 39), cell)
        else
            self:setLabelText("MessageLabel", data.msg, cell)
        end
    end

    cell.data = data
    cell:setVisible(true)

    self:bindTouchEndEventListener(cell, self.onTeamMatchPanel)

    local img = self:getControl("TeamLvBKImage", nil, cell)
    img.team_level = data.team_level
    self:bindTouchEndEventListener(img, self.onTeamLvBKImage)
end

function TeamEnlistDlg:onTeamLvBKImage(sender)
    gf:showTipInfo(string.format(CHS[5410314], sender.team_level), sender)
end

-- 设置个人条目
function TeamEnlistDlg:setPlayerPanel(cell, data)
    if not data then
        cell:setVisible(false)
        return
    end

    if data.index == 0 then
        self:setImage("BKImage", ResMgr.ui.green_panel_back, cell)
    else
        self:setImage("BKImage", ResMgr.ui.normal_panel_back, cell)
    end

    if POINT_TYPE_ICON[data.pt_type] then
        self:setImage("TypeImage", POINT_TYPE_ICON[data.pt_type], cell)
        self:setCtrlVisible("TypeImage", true, cell)
    else
        self:setCtrlVisible("TypeImage", false, cell)
    end

    --- self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)
    self:setImage("PortraitImage", ResMgr:getMatchPortrait(gf:getPolarAndGenderByIcon(data.icon)), cell)

    self:setLabelText("NameLabel", data.name, cell)

    self:setLabelText("LevelLabel", string.format(CHS[6000026], data.level), cell)

    self:setLabelText("TaoLabel", gf:getTaoStr(data.tao), cell)

    if data.short_msg then
        self:setLabelText("MessageLabel", data.short_msg, cell)
    elseif data.msg then
        local lenth, num = gf:getTextLength(data.msg)
        if num > 20 then
            self:setLabelText("MessageLabel", gf:getTextByNum(data.msg, 19), cell)
        else
            self:setLabelText("MessageLabel", data.msg, cell)
        end
    end

    cell.data = data
    cell:setVisible(true)

    self:bindTouchEndEventListener(self:getControl("PortraitPanel", nil, cell), self.onPortraitPanel)
    self:bindTouchEndEventListener(cell, self.onPlayerMatchPanel)

    local img = self:getControl("TypeImage", nil, cell)
    img.pointType = data.pt_type
    self:bindTouchEndEventListener(img, self.onTypeImage)
end

function TeamEnlistDlg:onTypeImage(sender)
    gf:showTipInfo(POINT_TYPE[sender.pointType], sender)
end

-- 刷新列表
function TeamEnlistDlg:refreshList(data, type, isReset)
    local panelName = type == ENLIST_TYPE.PLAYER and "PlayerEnlistPanel" or "TeamEnlistPanel"
    local listView = self.listViews[type]
    local count = #data
    if isReset then
        listView:removeAllItems()
        listView:setInnerContainerSize(cc.size(0, 0))
        if count == 0 then
            listView:setVisible(false)
            self:setCtrlVisible("NoticePanel" .. (data.isSearch and "2" or ""), true, panelName)
            self:setCtrlVisible("NoticePanel" .. (data.isSearch and "" or "2"), false, panelName)
            return
        else
            listView:setVisible(true)
            self:setCtrlVisible("NoticePanel", false, panelName)
            self:setCtrlVisible("NoticePanel2", false, panelName)
        end
    end

    if count == 0 then
        return
    end

    local items = listView:getItems()
    if #items > 0 then
        local cell = self:getControl("MatchPanel2", nil, items[#items])
        if not cell:isVisible() then
            if type == ENLIST_TYPE.PLAYER then
                self:setPlayerPanel(cell, data[1])
            else
                self:setTeamPanel(cell, data[1])
            end

            table.remove(data, 1)
        end
    end

    count = #data
    for i = 1, count, 2 do
        -- 创建一个Panel插入
        if i > count then return end

        local panel = self.ctrlClone[type]:clone()
        for j = 1, 2 do
            local cell = self:getControl("MatchPanel" .. j, nil, panel)
            if type == ENLIST_TYPE.PLAYER then
                self:setPlayerPanel(cell, data[i + j - 1])
            else
                self:setTeamPanel(cell, data[i + j - 1])
            end
        end

        listView:pushBackCustomItem(panel)
    end
    
    -- doLayout 中会调用回调函数，使用 self.notCallListView 标记不处理回调函数
    self.notCallListView = true
    listView:doLayout()
    listView:refreshView()
    self.notCallListView = false
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST(data)
    data.type = ENLIST_TYPE.PLAYER
    self:setPreMsgCommon(data)
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_TEAM_LIST(data)
    data.type = ENLIST_TYPE.TEAM
    self:setPreMsgCommon(data)
end

function TeamEnlistDlg:setPreMsgCommon(data)
    if self.lastRequestMessageIId[data.type] ~= data.request_iid then
        return
    end

    if data.request_iid == "" and self.isRefresh[data.type] then
        -- 刷新成功。
        gf:ShowSmallTips(CHS[5410315])
        self.isRefresh[data.type] = nil
    end

    if data.preData.count < 90 then
        -- 已获取全部数据
        self.isFinishLoad[data.type] = true
    else
        self.isFinishLoad[data.type] = false
    end

    self:addMessage(data)
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_TEAM_LIST_EX(data)
    data.type = ENLIST_TYPE.TEAM
    self:setRealMsgCommon(data)
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_SINGLE_LIST_EX(data)
    data.type = ENLIST_TYPE.PLAYER
    self:setRealMsgCommon(data)
end

function TeamEnlistDlg:setRealMsgCommon(data)
    self.isRequest[data.type] = false

    self:addMessage(data)

    if #self.enlistMsgList[data.type] <= ONE_LOAD_MESSAGE_NUM then
        -- 第一页数据
        self.curLoadIndex[data.type] = -1
        self.lastRequestMessageIId[data.type] = nil

        local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM, data.type, true)
        self:refreshList(moreData, data.type, true)
    elseif self.curLoadIndex[data.type] >= #self.enlistMsgList[data.type] then
        local  moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM, data.type, true)
        self:refreshList(moreData, data.type)
    end
end

function TeamEnlistDlg:requestMoreEnlist(type, new)
    local data = self.enlistMsgList[type] or {}
    local iid = ""
    local time = gf:getServerTime()
    if not new and data then
        if self.isRequest[type] then return end
        if data.preData and #data.preData > 0 then
            local info = {}
            local num = 10
            repeat
                if data.preData[1] and (type ~= ENLIST_TYPE.PLAYER or not FriendMgr:isBlackByGId(data.preData[1].iid)) then
                    table.insert(info, data.preData[1].iid)
                end

                table.remove(data.preData, 1)

                num = num - 1
                if num <= 0 then
                    break
                end

                if #data.preData <= 0 then
                    break
                end
            until false

            if #info > 0 then
                local str = table.concat(info, ",")
                if type == ENLIST_TYPE.TEAM then
                    gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM", {oper = 5, para = str})
                else
                    gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_SINGLE", {oper = 4, para = str})
                end
                
                self.isRequest[type] = true
                return
            end
        end

        if data.lastMsg then
            iid = data.lastMsg.iid
            time = data.lastMsg.create_time
        end
    end

    if (self.lastRequestMessageIId[type] == iid or self.isFinishLoad[type]) and not new then
        return
    end
    
    if type == ENLIST_TYPE.TEAM then
        gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM_QUERY_LIST", {
            iid = iid,
            time = time,
            polar = self.needCheckPolar,
            pt_type = self.needCheckPoint
        })
    else
        gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_SINGLE_QUERY_LIST", {
            iid = iid,
            time = time,
            polar = self.selectPolar,
            pt_type = self.selectPoint
        })
    end

    self.lastRequestMessageIId[type] = iid
end

-- 请求详细信息
function TeamEnlistDlg:requestOneDetailEnlist(data, type)
    self.curRequestIndex = data.index
    self.requestDetailType = type
    self.needOpenDlg = true
    if data.index == 0 then
        if Me:getLevel() < 50 then
            gf:ShowSmallTips(CHS[5410313])
            return
        end

        if type == ENLIST_TYPE.PLAYER then
            if TeamMgr:checkHasFixedTeam() then
                gf:ShowSmallTips(CHS[5410312])
                return
            end

            self:MSG_FIXED_TEAM_RECRUIT_SINGLE_DETAIL(data)
        else
            if not TeamMgr:checkHasFixedTeam() then
                gf:ShowSmallTips(CHS[5410311])
                return
            end

            if data[1] and data[1].icon and data[1].icon > 0 then
                gf:ShowSmallTips(CHS[5410305])
                return
            end

            self:MSG_FIXED_TEAM_RECRUIT_TEAM_DETAIL(data)
        end
    else
        if type == ENLIST_TYPE.PLAYER then
            gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_SINGLE", {oper = 3, para = data.iid})
        else
            gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM", {oper = 3, para = data.iid})
        end
    end
end

function TeamEnlistDlg:requestOperEnlist(oper, para, type, para2)
    if oper == 2 then
        gf:confirm(CHS[5410304], function()
            if type == ENLIST_TYPE.PLAYER then
                gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_SINGLE", {oper = oper, para = para})
            else
                gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM", {oper = oper, para = para})
            end
        end)
    else
        if type == ENLIST_TYPE.PLAYER then
            if gf:getTextLength(para) < 10 then
                gf:ShowSmallTips(CHS[5410307])
                return
            end

            gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_SINGLE", {oper = oper, para = para})
        else
            if gf:getTextLength(para) < 10 then
                gf:ShowSmallTips(CHS[5410308])
                return
            end

            gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM", {oper = oper, para = para, para2 = para2})
        end
    end
end

-- 获取更多的留言信息
function TeamEnlistDlg:getMoreMessage(num, type, notRequest)
    local moreData = {}
    local data = self.enlistMsgList[type] or {}
    local cou = #data
    local index = self.curLoadIndex[type]

    if index == -1 then
        if self.myInfo[type] and self.myInfo[type].has_publish == 1 then 
            table.insert(moreData, 1, self.myInfo[type])
            num = num - 1
        end

        index = index + 1
    end

    if index < cou then
        for i = index + 1, index + num do
            if data[i] then
                table.insert(moreData, data[i])
                index = index + 1
            else
                break
            end
        end
    end

    if data.polar then
        moreData.isSearch = data.polar > 0 or data.pt_type > 0
    end

    self.curLoadIndex[type] = index

    if not notRequest and cou <= index then
        -- 请求数据
        self:requestMoreEnlist(type)
    end

    return moreData
end

-- 留言列表
function TeamEnlistDlg:addMessage(data)
    if data.request_iid == "" or not self.enlistMsgList[data.type] then
        self.enlistMsgList[data.type] = {}
        self.enlistMsgList[data.type].polar = data.polar
        self.enlistMsgList[data.type].pt_type = data.pt_type
    end

    local list = self.enlistMsgList[data.type]
    local allCou = #list
    local flag = {}
    for i = 1, allCou do
        flag[list[i].iid] = true
    end

    if data.preData then
        list.preData = data.preData
    end

    if data.last_iid then
        list.lastMsg = {iid = data.last_iid, create_time = data.last_time}
    end

    local newCou = #data
    if newCou <= 0 then
        return
    end

    local index = allCou
    for i= 1, newCou do
        if not flag[data[i].iid] and (data.type ~= ENLIST_TYPE.PLAYER or not FriendMgr:isBlackByGId(data[i].iid)) then
            index = index + 1
            data[i].index = index
            table.insert(list, data[i])
        end
    end
end

function TeamEnlistDlg:hasNextMsg(type)
    local index = self.curShowIndex or 0
    local list = self.enlistMsgList[type]
    if not list[index + 1] and self.isFinishLoad[type] then
        return false
    end

    return true
end

function TeamEnlistDlg:hasLastMsg(type)
    local index = self.curShowIndex or 0
    local list = self.enlistMsgList[type]
    if index == 1 then
        if self.myInfo[type] and self.myInfo[type].has_publish == 1 then
            return true
        end

        return false
    end

    return index > 0
end

function TeamEnlistDlg:getNextMsg(type)
    local index = self.curShowIndex or 0
    local list = self.enlistMsgList[type]
    index = index + 1
    if list[index] then
        self:requestOneDetailEnlist(list[index], type)
    end

    if not list[index + 10] and not self.isFinishLoad[type] then
        -- 请求数据
        self:requestMoreEnlist(type)
    end
end

function TeamEnlistDlg:getLastMsg(type)
    local index = self.curShowIndex or 0
    local list = self.enlistMsgList[type]
    index = index - 1
    if index == 0 then
        if self.myInfo[type] and self.myInfo[type].has_publish == 1 then
            self:requestOneDetailEnlist(self.myInfo[type], type)
        end
    elseif list[index] then
        self:requestOneDetailEnlist(list[index], type)
    end
end

function TeamEnlistDlg:getNextUserCard()
    local index = self.curShowIndex
    local type = ENLIST_TYPE.PLAYER
    local list = self.enlistMsgList[type]
    index = index + 1
    if list[index] then
        self:requesrUserCard(list[index])
    end

    if not list[index + 10] and not self.isFinishLoad[type] then
        -- 请求数据
        self:requestMoreEnlist(type)
    end
end

function TeamEnlistDlg:getLastUserCard()
    local index = self.curShowIndex
    local type = ENLIST_TYPE.PLAYER
    local list = self.enlistMsgList[type]
    index = index - 1
    if index == 0 then
        if self.myInfo[type] and self.myInfo[type].has_publish == 1 then
            self:requesrUserCard(self.myInfo[type])
        end
    elseif list[index] then
        self:requesrUserCard(list[index])
    end
end

function TeamEnlistDlg:requesrUserCard(data)
    self.needCheckUserCard = true
    self.curRequestIndex = data.index
    ChatMgr:sendUserCardInfo(data.iid)
end

function TeamEnlistDlg:setMyInfoCommon(data, type, panelName)
    self.myInfo[type] = data

    -- 刷新招募列表
    if self.enlistMsgList[type] then
        self.curLoadIndex[type] = -1
        local moreData = self:getMoreMessage(ONE_LOAD_MESSAGE_NUM, type, true)
        self:refreshList(moreData, type, true)
    end

    -- 刷新招募详细界面
    if DlgMgr:isDlgOpened("TeamEnlistInfoDlg") then
        self.curShowIndex = 0
        if data.has_publish == 1 then
            DlgMgr:closeDlg("TeamEnlistInfoDlg")
        else
            self:requestOneDetailEnlist(self.myInfo[type], type)
        end
    end

    if data.has_publish == 1 then
        self:setCtrlVisible("CancelButton", true, panelName)
        self:setCtrlVisible("EnlistButton", false, panelName)
    else
        self:setCtrlVisible("CancelButton", false, panelName)
        self:setCtrlVisible("EnlistButton", true, panelName)
    end
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_MY_TEAM(data)
    data.index = 0
    self:setMyInfoCommon(data, ENLIST_TYPE.TEAM, "TeamEnlistPanel")
end

function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_MY_SINGLE(data)
    local info = {
        has_publish = data.has_publish,
        pt_type = data.pt_type,
        msg = data.msg,

        iid = Me:queryBasic("gid"),
        online = 1,
        icon = gf:getIconByGenderAndPolar(Me:queryBasicInt("gender"), Me:queryBasicInt("polar")),
        name = Me:getName(),
        tao = Me:queryBasicInt("tao"),
        level = Me:getLevel(),
        polar = Me:queryBasicInt("polar"),
        index = 0,
    }

    self:setMyInfoCommon(info, ENLIST_TYPE.PLAYER, "PlayerEnlistPanel")
end

-- 组队招募详细信息
function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_TEAM_DETAIL(data)
    if self.requestDetailType ~= ENLIST_TYPE.TEAM then
        return
    end

    data.index = self.curRequestIndex
    self.curShowIndex = self.curRequestIndex

    if self.needOpenDlg then
        local dlg = DlgMgr:openDlg("TeamEnlistInfoDlg")
        dlg:setTeamView(data, self.myInfo[ENLIST_TYPE.TEAM])
        self.needOpenDlg = nil
    else
        DlgMgr:sendMsg("TeamEnlistInfoDlg", "setTeamView", data, self.myInfo[ENLIST_TYPE.TEAM])
    end
end

-- 个人招募详细信息
function TeamEnlistDlg:MSG_FIXED_TEAM_RECRUIT_SINGLE_DETAIL(data)
    if self.requestDetailType ~= ENLIST_TYPE.PLAYER then
        return
    end

    data.index = self.curRequestIndex
    self.curShowIndex = self.curRequestIndex

    if self.needOpenDlg then
        local dlg = DlgMgr:openDlg("TeamEnlistInfoDlg")
        dlg:setPlayerView(data, self.myInfo[ENLIST_TYPE.PLAYER])
        self.needOpenDlg = nil
    else
        DlgMgr:sendMsg("TeamEnlistInfoDlg", "setPlayerView", data, self.myInfo[ENLIST_TYPE.PLAYER])
    end
end

function TeamEnlistDlg:MSG_FIXED_TEAM_DATA(data)
    if data and #data.members == 0 then
        -- 没有固定队
        TeamMgr:MSG_FIXED_TEAM_CHECK({has_fixed_team = 0})
        DlgMgr:closeDlg("TeamEnlistInfoDlg")

        if self.myInfo[ENLIST_TYPE.TEAM] and self.myInfo[ENLIST_TYPE.TEAM].has_publish == 1 then
            self.myInfo[ENLIST_TYPE.TEAM].has_publish = 0
            self:MSG_FIXED_TEAM_RECRUIT_MY_TEAM(self.myInfo[ENLIST_TYPE.TEAM])
        end
    else
        -- 有固定队
        TeamMgr:MSG_FIXED_TEAM_CHECK({has_fixed_team = 1})
        DlgMgr:closeDlg("TeamEnlistInfoDlg")
        self.myInfo[ENLIST_TYPE.TEAM] = nil
        gf:CmdToServer("CMD_FIXED_TEAM_RECRUIT_TEAM", {oper = 3, para = "my_data"})

        if self.myInfo[ENLIST_TYPE.PLAYER] and self.myInfo[ENLIST_TYPE.PLAYER].has_publish == 1 then
            self.myInfo[ENLIST_TYPE.PLAYER].has_publish = 0
            self:MSG_FIXED_TEAM_RECRUIT_MY_SINGLE(self.myInfo[ENLIST_TYPE.PLAYER])
        end
    end
end

function TeamEnlistDlg:MSG_CARD_INFO(data)
    --[[if data.type == CHS[3003936] and self.needCheckUserCard then
        self.curShowIndex = self.curRequestIndex
        DlgMgr:sendMsg("UserCardDlg", "setCtrlVisible", "RightButton", self:hasNextMsg(ENLIST_TYPE.PLAYER))
        DlgMgr:sendMsg("UserCardDlg", "setCtrlVisible", "LeftButton", self:hasLastMsg(ENLIST_TYPE.PLAYER))
    end

    self.needCheckUserCard = nil]]
end

function TeamEnlistDlg:cleanup()
    DlgMgr:closeDlg("TeamEnlistInfoDlg")
end

return TeamEnlistDlg
