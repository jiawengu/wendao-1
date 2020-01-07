-- TeamEnlistInfoDlg.lua
-- Created by huangzz Oct/17/2018
-- 招募信息详细界面

local TeamEnlistInfoDlg = Singleton("TeamEnlistInfoDlg", Dialog)

local TextView = require("ctrl/TextView")

local ENLIST_TYPE = {
    PLAYER = "player",
    TEAM = "team",
}

-- 系别
local POLAR_TYPE = {
    [0] = CHS[5410297] .. CHS[5410298],  -- 任意系
    [1] = CHS[3000253],
    [2] = CHS[3000256],
    [3] = CHS[3000259],
    [4] = CHS[3000261],
    [5] = CHS[3000263],

    [CHS[5410297] .. CHS[5410298]] = 0,
    [CHS[3000253]] = 1,
    [CHS[3000256]] = 2,
    [CHS[3000259]] = 3,
    [CHS[3000261]] = 4,
    [CHS[3000263]] = 5,
}

-- 加点偏向
local POINT_TYPE = {
    [0] = CHS[5410297] .. CHS[5410299], -- 任意型
    [1] = CHS[5410281], -- 灵力型
    [2] = CHS[5410282], -- 体质型
    [3] = CHS[5410283], -- 敏捷型
    [4] = CHS[5410280], -- 力量型


    [CHS[5410297] .. CHS[5410299]] = 0,  -- 任意型
    [CHS[5410281]] = 1, -- 灵力型
    [CHS[5410282]] = 2, -- 体质型
    [CHS[5410283]] = 3, -- 敏捷型
    [CHS[5410280]] = 4, -- 力量型

}

local POINT_ORDER = {
    [0] = CHS[5410297] .. CHS[5410299], -- 任意型
    [1] = CHS[5410280], -- 力量型
    [2] = CHS[5410281], -- 灵力型
    [3] = CHS[5410282], -- 体质型
    [4] = CHS[5410283], -- 敏捷型

    [CHS[5410297] .. CHS[5410299]] = 0,  -- 任意型
    [CHS[5410280]] = 1, -- 力量型
    [CHS[5410281]] = 2, -- 灵力型
    [CHS[5410282]] = 3, -- 体质型
    [CHS[5410283]] = 4, -- 敏捷型
}

function TeamEnlistInfoDlg:init()
    self:setFullScreen()
    self:bindListener("BlogButton", self.onBlogButton, "PlayerInfoPanel")
    self:bindListener("InfoButton", self.onInfoButton, "PlayerInfoPanel")
    self:bindListener("TalkButton", self.onTalkButton, "PlayerInfoPanel")
    self:bindListener("OtherButton", self.onOtherButton, "PlayerInfoPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton, "PlayerInfoPanel")
    self:bindListener("CancelButton", self.onCancelButton, "PlayerInfoPanel")
    self:bindListener("DelButton", self.onDelButton, "PlayerInfoPanel")
    self:bindListener("TalkButton", self.onTalkTeamButton, "TeamInfoPanel")
    self:bindListener("ConfirmButton", self.onConfirmButton, "TeamInfoPanel")
    self:bindListener("CancelButton", self.onCancelButton, "TeamInfoPanel")
    self:bindListener("DelButton", self.onDelButton, "TeamInfoPanel")
    self:bindListener("ConfirmButton", self.onTypeChooseConfirmButton, "TypeChoosePanel")
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("LeftButton", self.onLeftButton)

    -- self.ratain()
    self:bindFloatPanelListener("TypeChoosePanel", nil, nil, self.onTypeChoosePanel)

    self.playerCell = self:retainCtrl("PlayerUnitPanel", "PlayerListPanel")

    self.polarCell = self:retainCtrl("UnitNumPanel", "PolarPanel")
    self.typeCell = self:retainCtrl("UnitNumPanel", "TypePanel")
    self.selectPolar = POLAR_TYPE[1]
    self.selectPoint = POINT_TYPE[1]

    self.selectInfo = nil
    self.insertTao = nil

    self.textViews = {}

    self:hookMsg("MSG_FIXED_TEAM_RECRUIT_TALK")
end

function TeamEnlistInfoDlg:setViewCommon(data, myInfo, type, panelName)
    self.curShowType = type

    self.myInfo = myInfo
    self.curdata = data
    self.isMyEnlist = data.index == 0

    local panel = self:getControl(panelName)
    self:initEditBox(panelName, type == ENLIST_TYPE.PLAYER and 200 or 300, self.curShowType, myInfo and myInfo.has_publish, self.isMyEnlist)
    if self.isMyEnlist then
        -- 自己的招募
        self:setCtrlVisible("MyselfButtonPanel", true, panel)
        self:setCtrlVisible("OtherButtonPanel", false, panel)
        if not myInfo or myInfo.has_publish == 1 then
            -- 已发布
            self:setCtrlVisible("ConfirmButton", false, panel)
            self:setCtrlVisible("CancelButton", true, panel)

            self:setCtrlVisible("LeftButton",  false)
            self:setCtrlVisible("RightButton", DlgMgr:sendMsg("TeamEnlistDlg", "hasNextMsg", type))
        else
            -- 未发布
            self:setCtrlVisible("ConfirmButton", true, panel)
            self:setCtrlVisible("CancelButton", false, panel)
            self:setCtrlVisible("LeftButton",  false)
            self:setCtrlVisible("RightButton", false)
        end
    else
        self:setCtrlVisible("MyselfButtonPanel", false, panel)
        self:setCtrlVisible("OtherButtonPanel", true, panel)

        self:setCtrlVisible("LeftButton",  DlgMgr:sendMsg("TeamEnlistDlg", "hasLastMsg", type))
        self:setCtrlVisible("RightButton", DlgMgr:sendMsg("TeamEnlistDlg", "hasNextMsg", type))
    end
end

-- 个人招募
function TeamEnlistInfoDlg:setPlayerView(data, myInfo)
    self:setCtrlVisible("TeamInfoPanel", false)
    self:setCtrlVisible("PlayerInfoPanel", true)

    self:setViewCommon(data, myInfo, ENLIST_TYPE.PLAYER, "PlayerInfoPanel")

    self:setPlayerData(data)
end

function TeamEnlistInfoDlg:setPlayerData(data)
    local cell = self:getControl("PlayerInfoPanel")

    self:setImage("ShapeImage", ResMgr:getMatchPortrait(gf:getPolarAndGenderByIcon(data.icon)), cell)

    self:setLabelText("NameLabel", string.format(CHS[5410292], data.name), cell)

    self:setLabelText("LevelLabel", string.format(CHS[5410293], data.level) .. CHS[5300006], cell)

    self:setLabelText("TaoLabel", string.format(CHS[5410294], gf:getTaoStr(data.tao)), cell)

    self:setLabelText("PlayerLabel", string.format(CHS[5410295], gf:getIconNameByIcon(data.icon)), cell)

    self:setLabelText("TypeLabel", string.format(CHS[5410296], POINT_TYPE[data.pt_type]), cell)

    local text = data.msg
    if string.isNilOrEmpty(text) then
        text = TeamMgr:getTeamEnlistMsg(ENLIST_TYPE.PLAYER) or ""
    end

    self:setBoxText(cell, text, ENLIST_TYPE.PLAYER)
end

-- 组队招募
function TeamEnlistInfoDlg:setTeamView(data, myInfo)
    self:setCtrlVisible("PlayerInfoPanel", false)
    self:setCtrlVisible("TeamInfoPanel", true)

    self:setViewCommon(data, myInfo, ENLIST_TYPE.TEAM, "TeamInfoPanel")

    self:setTeamData(data)
end

function TeamEnlistInfoDlg:setTeamData(data)
    local panel = self:getControl("TeamInfoPanel")
    self.selectInfo = {}
    self.insertTao = {}
    local listView = self:getControl("PlayerListView")
    listView:removeAllItems()
    for i = 1, 5 do
        local cell = self.playerCell:clone()
        cell:setTag(i)
        self:setOneTeamMemberData(cell, data[i], i)
        listView:pushBackCustomItem(cell)
    end

    local text = data.msg
    if string.isNilOrEmpty(text) then
        text = TeamMgr:getTeamEnlistMsg(ENLIST_TYPE.TEAM) or ""
    end
    self:setBoxText(panel, text, ENLIST_TYPE.TEAM)

    self:setImage("TeamLvImage", ResMgr.ui["fixed_team_level" .. (data.team_level or 1)], panel)

    self:setLabelText("NameLabel",data.team_name .. CHS[5410309], panel)

    local img = self:getControl("TeamLvBKImage", nil, panel)
    img.team_level = data.team_level
    self:bindTouchEndEventListener(img, self.onTeamLvBKImage)
end

function TeamEnlistInfoDlg:onTeamLvBKImage(sender)
    gf:showTipInfo(string.format(CHS[5410314], sender.team_level), sender)
end

function TeamEnlistInfoDlg:getTypeStr(polar, point)
    if not polar or not point or not POLAR_TYPE[polar] or not POINT_TYPE[point] then
        return ""
    end

    if polar == 0 and point == 0 then
        return CHS[4200046]
    else
        return POLAR_TYPE[polar] .. POINT_TYPE[point]
    end
end

function TeamEnlistInfoDlg:getTaoStr(tao, isReal)
    if (not tao or tao == 0) and not isReal then
        return CHS[4200046]
    end

    tao = math.floor(tao / Const.ONE_YEAR_TAO) * Const.ONE_YEAR_TAO

    return gf:getTaoStr(tao)
end

-- 设置组队招募单个条目信息
function TeamEnlistInfoDlg:setOneTeamMemberData(cell, data, tag)
    if not next(data) or not data.icon then
        self:bindNumInput("BackImage1", cell, nil, tag)

        self:bindListener("BackImage2", self.onBackImage2, cell)

        self:setLabelText("NameLabel", CHS[5410301], cell)

        self:setLabelText("TaoLabel", self:getTaoStr(data.tao), cell)

        self:setLabelText("TypeLabel", self:getTypeStr(data.polar or 0, data.pt_type or 0), cell)

        self.selectInfo[tag] = {
            polar = data.polar or 0,
            point = data.pt_type or 0,
        }

        self.insertTao[tag] = data.tao or 0
    else
        self:setImage("PortraitImage", ResMgr:getSmallPortrait(data.icon), cell)

        self:setNumImgForPanel("PortraitPanel1", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 19, cell)

        self:setLabelText("NameLabel", data.name, cell)

        self:setLabelText("TaoLabel", self:getTaoStr(data.tao, true), cell)

        self:setLabelText("TypeLabel", self:getTypeStr(data.polar, data.pt_type), cell)

        cell.data = data

        self:bindTouchEndEventListener(cell, self.onPlayerPanel)
        self:bindTouchEndEventListener(self:getControl("PortraitPanel1", nil, cell), self.onPortraitPanel)
    end

    if not self.myInfo or self.myInfo.has_publish == 1 or not self.isMyEnlist or data.icon then
        self:setCtrlVisible("BackImage1", false, cell)
        self:setCtrlVisible("BackImage2", false, cell)
        self:setCtrlVisible("IconImage1", false, cell)
        self:setCtrlVisible("IconImage2", false, cell)
    end
end

function TeamEnlistInfoDlg:doWhenOpenNumInput(ctrlName, root)
    local img = self:getControl("IconImage1", nil, root)
    img:setFlippedY(true)
end

function TeamEnlistInfoDlg:closeNumInputDlg(key)
    local listView = self:getControl("PlayerListView")
    local cell = listView:getChildByTag(key)
    if cell then
        local img = self:getControl("IconImage1", nil, cell)
        img:setFlippedY(false)
    end
end

function TeamEnlistInfoDlg:insertNumber(num, key)
    if num < 0 then
        num = 0
    end

    if num > 99999 then
        num = 99999
    end

    self.insertTao[key] = num * Const.ONE_YEAR_TAO

    local listView = self:getControl("PlayerListView")
    local cell = listView:getChildByTag(key)
    if cell then
        self:setLabelText("TaoLabel", self:getTaoStr(self.insertTao[key]), cell)
    end

    DlgMgr:sendMsg('SmallNumInputDlg', 'setInputValue', num)
end

-- 选择
function TeamEnlistInfoDlg:onBackImage2(sender)
    local cell = sender:getParent()
    local tag = cell:getTag()
    if not self.selectInfo[tag] then
        return
    end

    self:setCtrlVisible("TypeChoosePanel", true)

    local img = self:getControl("IconImage2", nil, cell)
    img:setFlippedY(true)

    self:initTypeChoosePanel(tag)

    local panel = self:getControl("TypeChoosePanel")
    local x, y = sender:getPosition()
    local mPanel = self:getControl("MovePanel")
    local pos = sender:getParent():convertToWorldSpace(cc.p(x, y))
    pos = panel:getParent():convertToNodeSpace(pos)
    panel:setPositionY(pos.y - panel:getContentSize().height - 15)
end

function TeamEnlistInfoDlg:scrollToTag(panelName, cellClone, cfgInfo, selectTag)
    local cellSize = cellClone:getContentSize()
    local listView = self:getControl("ListView", nil, panelName)
    local minY = (#cfgInfo - selectTag) * cellSize.height
    listView:getInnerContainer():setPositionY(-minY)
end

function TeamEnlistInfoDlg:onTypeChoosePanel()
    local listView = self:getControl("PlayerListView")
    local cell = listView:getChildByTag(self.curSelectTag)
    if cell then
        local img = self:getControl("IconImage2", nil, cell)
        img:setFlippedY(false)
    end
end

function TeamEnlistInfoDlg:initTypeChoosePanel(tag)
    local panel = self:getControl("TypeChoosePanel")
    self.curSelectTag = tag
    self.perSelect = {}
    self:setListView(self:getControl("PolarPanel", nil, panel), self.polarCell, POLAR_TYPE, self.selectInfo[tag].polar, "polar")
    self:setListView(self:getControl("TypePanel", nil, panel), self.typeCell, POINT_ORDER, POINT_ORDER[POINT_TYPE[self.selectInfo[tag].point]], "point")
end

function TeamEnlistInfoDlg:setListView(panelName, cellClone, cfgInfo, selectTag, type)
    local listView = self:getControl("ListView", nil, panelName)
    listView:removeAllItems()

    -- 前后各加2个空位
    for i = - 2, #cfgInfo + 2  do
        local cell = cellClone:clone()
        self:setLabelText("InfoLabel", cfgInfo[i] or "", cell)
        listView:pushBackCustomItem(cell)
    end

    local cellSize = cellClone:getContentSize()

    local function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling
                or eventType == ccui.ScrollviewEventType.scrollToTop
                or eventType == ccui.ScrollviewEventType.scrollToBottom then
            local delay = cc.DelayTime:create(0.15)
            local func = cc.CallFunc:create(function()
                local scrollHeight = sender:getInnerContainer():getContentSize().height - sender:getContentSize().height
                local _, offY = sender:getInnerContainer():getPosition()
                local befPercent = offY / (scrollHeight) * 100 + 100
                local absOff = math.abs(offY)

                local numMax = #cfgInfo
                local numMin = 0
                local num = numMax - math.floor(absOff / cellSize.height + 0.5)
                local percent = ((num - numMin) * cellSize.height) / (scrollHeight) * 100
                if  num >= numMin and num <= numMax then
                    if befPercent ~= percent then
                        sender:scrollToPercentVertical(percent, 0.5, false)
                    end

                    self.perSelect[type] = num
                end
            end)

            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end

    listView:addScrollViewEventListener(scrollListener)

    listView:requestRefreshView()
    listView:doLayout()

    local minY = (#cfgInfo - selectTag) * cellSize.height
    listView:getInnerContainer():setPositionY(-minY)
end

function TeamEnlistInfoDlg:setBoxText(panel, text, type, isEditing)
    local len = gf:getTextLength(text)
    if not self.isMyEnlist then
        self:setCtrlVisible("DelButton", false, panel)
        self:setCtrlVisible("DefaultLabel", false, panel)
    elseif text and text ~= "" then
        self:setCtrlVisible("DelButton", true, panel)
        self:setCtrlVisible("DefaultLabel", false, panel)
    else
        self:setCtrlVisible("DelButton", false, panel)
        self:setCtrlVisible("DefaultLabel", not isEditing, panel)
    end

    self.textViews[type]:setText(text)
end

function TeamEnlistInfoDlg:initEditBox(panel, wordLimit, type)
    self:setCtrlVisible("EditPanel", true, panel)
    if self.textViews[type] then
        return
    end

    local textView = TextView.new(self, "MessagePanel", panel, 19, "ScrollView")
    local isEditing
    textView:bindListener(function(self, sender, event)
        if 'began' == event then
            isEditing = true
        elseif 'ended' == event then
            isEditing = nil
        end

        local text = textView:getText()
        local len = gf:getTextLength(text)

        if len > wordLimit * 2 then
            text = gf:subString(text, wordLimit * 2)
            gf:ShowSmallTips(CHS[5400041])
        end

        self:setBoxText(panel, text, type, isEditing)
    end)

    textView:setClickLimit(function()
        if not self.isMyEnlist then
            return false
        end

        if not self.myInfo or self.myInfo.has_publish ~= 0 then
            gf:ShowSmallTips(CHS[5410291])
            return false
        end

        return true
    end)

    self.textViews[type] = textView
end

-- 查看空间
function TeamEnlistInfoDlg:onBlogButton(sender, eventType)
    if not self.curdata then return end
    BlogMgr:openBlog(self.curdata.gid, nil, nil, self.curdata.dist_name)
end

-- 角色属性名片
function TeamEnlistInfoDlg:onInfoButton(sender, eventType)
    if not self.curdata then return end
    ChatMgr:sendUserCardInfo(self.curdata.gid)
end

function TeamEnlistInfoDlg:onPlayerPanel(sender, eventType)
    local data = sender.data
    if data and data.gid ~= Me:queryBasic("gid")  then
        local char = {}
        char.gid = data.gid
        char.name = data.name
        char.level = data.level
        char.icon = data.icon
        char.isOnline = 2
        local rect = self:getBoundingBoxInWorldSpace(sender)
        FriendMgr:openCharMenu(char, nil, rect)
    end
end

function TeamEnlistInfoDlg:onPortraitPanel(sender, eventType)
    local data = sender:getParent().data
    if not data then
        return
    end

    ChatMgr:sendUserCardInfo(data.gid)
end

-- 交流
function TeamEnlistInfoDlg:onTalkButton(sender, eventType)
    if not self.curdata then return end
    FriendMgr:communicat(self.curdata.name, self.curdata.gid, self.curdata.icon, self.curdata.level)
end

-- 其它
function TeamEnlistInfoDlg:onOtherButton(sender, eventType)
    if not self.curdata then return end
    local excepts = {}
    if FriendMgr:hasFriend(self.curdata.gid) then
        excepts[CHS[5000064]] = true
    else
        excepts[CHS[5000062]] = true
    end

    BlogMgr:showButtonList(self, sender, "TeamEnlistOther", self.name, {excepts = excepts})
end

-- 添加/删除好友
function TeamEnlistInfoDlg:doOperFriend()
    if not self.curdata then return end

    local name = self.curdata.name
    local gid = self.curdata.gid
    if not name or not gid then return end

    if FriendMgr:hasFriend(gid) then
        -- 如果已经是己方好友
        local str = string.format(CHS[5000060], name)

        gf:confirm(str, function()
            FriendMgr:deleteFriend(name, gid)
        end)

    else
        FriendMgr:addFriendCheck(self.curdata)
    end
end

-- 举报
function TeamEnlistInfoDlg:doReport()
    if not self.curdata then return end
    
    
    local para = "@spcial@;" .. self.curdata.msg .. CHS[4300503] ..  GameMgr:getDistName() .. ":" .. self.curdata.gid
    ChatMgr:questOpenReportDlg(self.curdata.gid, self.curdata.name, GameMgr:getDistName(), para)
    
end


-- 确认发布
function TeamEnlistInfoDlg:onConfirmButton(sender, eventType)
    local text = self.textViews[self.curShowType]:getText() or ""

    -- 屏蔽敏感字
    local filtTextStr, haveFilt = gf:filtText(text, nil, true)
    if haveFilt then
        local dlg = DlgMgr:openDlg("OnlyConfirmDlg")
        dlg:setTip(CHS[5420088])
        dlg:setCallFunc(function()
            DlgMgr:closeDlg("OnlyConfirmDlg")
            if DlgMgr:isDlgOpened("TeamEnlistInfoDlg") then
                self.textViews[self.curShowType]:setText(filtTextStr)
            end
        end, true)

        return
    end

    local para2 = ""
    if self.curShowType == ENLIST_TYPE.TEAM and self.selectInfo then
        local cou = #self.selectInfo
        for i = 1, cou do
            if self.insertTao[i] and self.selectInfo[i] then
                para2 = para2 .. self.selectInfo[i].polar .. ";"
                para2 = para2 .. self.selectInfo[i].point .. ";"
                para2 = para2 .. self.insertTao[i] .. (i == cou and "" or ";")
            end
        end
    end

    DlgMgr:sendMsg("TeamEnlistDlg", "requestOperEnlist", 1, text, self.curShowType, para2)
end

-- 撤销
function TeamEnlistInfoDlg:onCancelButton(sender, eventType)
    local text = self.textViews[self.curShowType]:getText() or ""
    DlgMgr:sendMsg("TeamEnlistDlg", "requestOperEnlist", 2, text, self.curShowType)
end

function TeamEnlistInfoDlg:onDelButton(sender, eventType)
    if not self.myInfo or not self.isMyEnlist then
        return
    end

    if self.myInfo.has_publish ~= 0 then
        gf:ShowSmallTips(CHS[5410291])
        return
    end

    local panelName = self.curShowType == ENLIST_TYPE.PLAYER and "PlayerInfoPanel" or "TeamInfoPanel"
    self:setBoxText(self:getControl(panelName), "", self.curShowType)
end

-- 快速联系
function TeamEnlistInfoDlg:onTalkTeamButton(sender, eventType)
    if not self.curdata then return end

    DlgMgr:sendMsg("TeamEnlistDlg", "requestOperEnlist", 4, self.curdata.iid)
end

-- 显示选择的加点偏向
function TeamEnlistInfoDlg:onTypeChooseConfirmButton(sender, eventType)
    local tag = self.curSelectTag
    if not self.selectInfo[tag] then self.selectInfo[tag] = {} end

    if self.perSelect.polar then
        self.perSelect.polar = math.min(math.max(0, self.perSelect.polar), #POLAR_TYPE)
        self.selectInfo[tag].polar = self.perSelect.polar
    end

    if self.perSelect.point then
        self.perSelect.point = math.min(math.max(0, self.perSelect.point), #POINT_TYPE)
        self.selectInfo[tag].point = POINT_TYPE[POINT_ORDER[self.perSelect.point]]
    end

    -- 隐藏加点偏向选择框
    self:setCtrlVisible("TypeChoosePanel", false)
    self:onTypeChoosePanel()

    -- 显示选择的加点偏向
    local listView = self:getControl("PlayerListView")
    local cell = listView:getChildByTag(self.curSelectTag)
    if cell then
        self:setLabelText("TypeLabel", self:getTypeStr(self.selectInfo[tag].polar, self.selectInfo[tag].point), cell)
    end
end

function TeamEnlistInfoDlg:onRightButton(sender, eventType)
    DlgMgr:sendMsg("TeamEnlistDlg", "getNextMsg", self.curShowType)
end

function TeamEnlistInfoDlg:onLeftButton(sender, eventType)
    DlgMgr:sendMsg("TeamEnlistDlg", "getLastMsg", self.curShowType)
end

function TeamEnlistInfoDlg:MSG_FIXED_TEAM_RECRUIT_TALK(data)
    if not self.curdata then return end
    for i = 1, #self.curdata do
        if self.curdata[i].gid == data.gid then
            FriendMgr:communicat(self.curdata[i].name, self.curdata[i].gid, self.curdata[i].icon, self.curdata[i].level)
        end
    end
end

function TeamEnlistInfoDlg:cleanup()
    if self.isMyEnlist then
        local str = self.textViews[self.curShowType]:getText()
        TeamMgr:setTeamEnlistMsg(self.curShowType, str)
    end
end

return TeamEnlistInfoDlg
