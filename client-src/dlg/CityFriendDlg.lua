-- CityFriendDlg.lua
-- Created by huangzz Feb/28/2018
-- 区域好友界面

local CityFriendDlg = Singleton("CityFriendDlg", Dialog)

local LOCATION_LIMIT_WORD = 8

local panelList = {}
local panleCount = 0

local ONE_WORD17_WIDTH = 17

function CityFriendDlg:init()
    self:bindListener("CityFriendButton", self.onCityFriendButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("RuleInfoButton", self.onRuleButton)
    self:bindCheckBoxListener("SameCityCheckBox", self.onSameCityCheckBox)
    self:bindCheckBoxListener("SameServerCheckBox", self.onSameServerCheckBox)
    self:blindLongPress("PortraitPanel", self.onLongPortraitPanel, nil, "OneFriendPanel")
    -- self:bindListViewListener("FriendListView", self.onSelectFriendListView)

    local isOpen = DlgMgr:sendMsg("CityTabDlg", "getCheckBoxState", "FriendCity") or false
    self:setCheck("SameCityCheckBox", isOpen)

    local isOpen = DlgMgr:sendMsg("CityTabDlg", "getCheckBoxState", "FriendServer") or false
    self:setCheck("SameServerCheckBox", isOpen)

    self.friendPanel = self:retainCtrl("OneFriendPanel")
    self.friendListView = self:getControl("FriendListView")
    local cityPanel = self:getControl("CityPanel", nil, self.friendPanel)
    self.backSize = self:getControl("BKImage", nil, cityPanel):getContentSize()
    self.friendPanels = {}

    self.needRefresh = {}

    self:setFriendList()

    self:hookMsg("MSG_LBS_FRIEND_LIST")
    self:hookMsg("MSG_LBS_REMOVE_FRIEND")
    EventDispatcher:addEventListener('ENTER_FOREGROUND', self.onResume, self)
end

function CityFriendDlg:onCityFriendButton(sender, eventType)
    DlgMgr:openDlg("CityFriendVerifyOperateDlg")
end

function CityFriendDlg:onInfoButton(sender, eventType)
    local data = sender:getParent().data
    if data and data.gid ~= Me:queryBasic("gid") then
        local char = {}
        char.gid = data.gid
        char.name = data.name
        char.level = data.level
        char.icon = data.icon
        char.dist_name = data.dist_name
        local rect = self:getBoundingBoxInWorldSpace(sender)
        FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.CITY, rect)
    end
end

function CityFriendDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[5400509], sender)
end

function CityFriendDlg:onSameCityCheckBox(sender, eventType)
    self:setFriendList()
end

function CityFriendDlg:onSameServerCheckBox(sender, eventType)
    self:setFriendList()
end

local function sortFunc(l, r)
    local lTime = l.lastChatTime or 0
    local rTime = r.lastChatTime or 0
    if lTime > rTime then return true end
    if lTime < rTime then return false end

    if l.gid <= r.gid then return true end
    if l.gid > r.gid then return false end
end

-- 获取要显示的区域好友
function CityFriendDlg:getShowCityFriendList()
    local allFriend = CitySocialMgr:getCityFriends()

    local data = {}
    local onlyShwoSameCity = self:isCheck("SameCityCheckBox")
    local onlyShwoSameServer = self:isCheck("SameServerCheckBox")
    local myLocation = CitySocialMgr:getLocation()
    local myDist = GameMgr:getDistName()
    for i = 1, #allFriend do
        if onlyShwoSameCity and not onlyShwoSameServer and myLocation == allFriend[i].location then
            table.insert(data, allFriend[i])
        elseif not onlyShwoSameCity and onlyShwoSameServer and myDist == allFriend[i].dist_name then
            table.insert(data, allFriend[i])
        elseif onlyShwoSameCity and onlyShwoSameServer and myDist == allFriend[i].dist_name and myLocation == allFriend[i].location then
            table.insert(data, allFriend[i])
        elseif not onlyShwoSameCity and not onlyShwoSameServer then
            table.insert(data, allFriend[i])
        end
    end

    table.sort(data, sortFunc)

    return data, #allFriend
end

function CityFriendDlg:setPortrait(filePath, gid)
    if not self.friendPanels then return end

    local cell = self.friendPanels[gid]
    if cell then
        self:setImage("PortraitImage", filePath, cell)
    end
end

function CityFriendDlg:onLongPortraitPanel(sender)
    local data = sender:getParent().data
    if not data or data.gid == Me:queryBasic("gid")  then return end

    local dlg = BlogMgr:showButtonList(self, sender, "reportPortrait", self.name)
    dlg:setGid(data.gid)
end

function CityFriendDlg:reportIcon(sender)
    local data = sender:getParent().data
    if data then
        CitySocialMgr:reportIcon(data.gid, data.icon_img, data.dist_name)
    end
end

-- 设置单个玩家的数据
function CityFriendDlg:setOneFriendPanel(data, cell)
    -- 玩家数据
    self:setPortrait(ResMgr:getSmallPortrait(data.icon), data.gid)

    if not string.isNilOrEmpty(data.icon_img) then
        BlogMgr:assureFile("setPortrait", self.name, data.icon_img, nil, data.gid)
    end

    self:setLabelText("PlayerNameLabel", data.name, cell)

    if not data.age or data.age < 0 then
        self:setLabelText("AgeLabel", CHS[5400495] .. CHS[5400496], cell)
    else
        self:setLabelText("AgeLabel", CHS[5400495] .. data.age, cell)
    end

    local polar = gf:getPloarByIcon(data.icon)
    self:setImagePlist("PolarImage", ResMgr:getSuitPolarImagePath(polar), cell)

    self:setImage("SexImage", ResMgr:getGenderSignByGender(data.sex), cell)

    local panel = self:getControl("PortraitPanel", nil, cell)
    -- self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, data.level or 1, false, LOCATE_POSITION.LEFT_TOP, 19, cell)

    if GameMgr:getDistName() ~= data.dist_name then
        gf:addKuafLogo(panel)
    else
        gf:removeKuafLogo(panel)
    end

    -- 区组
    local panel = self:getControl("ServerPanel", nil, cell)
    self:setLabelText("TextLabel", data.dist_name, panel)

    -- 地区
    local str = CitySocialMgr:getLocationShowStr(data.location)
    local panel = self:getControl("CityPanel", nil, cell)
    self:setLabelText("TextLabel", str, panel)
    -- local width = self:getLocationSize(str)
    -- if self.backSize.width < width then
    local len = gf:getTextLength(str)
    if len > 10 then
        self:setCtrlContentSize("BKImage", math.floor(len / 2) * ONE_WORD17_WIDTH, self.backSize.height, panel)
    else
        self:setCtrlContentSize("BKImage", self.backSize.width, self.backSize.height, panel)
    end

    cell.data = data
end

function CityFriendDlg:getLocationSize(str)
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(17)
    textCtrl:setString(str)
    textCtrl:setContentSize(180, 0)
    textCtrl:updateNow()
    return textCtrl:getRealSize()
end

function CityFriendDlg:getFriendPanel(gid)
    if self.friendPanels[gid] then
        return self.friendPanels[gid]
    else
        local cell = self.friendPanel:clone()
        cell:retain()
        self.friendPanels[gid] = cell
        return cell
    end
end

function CityFriendDlg:updateUI()
    local items = self.friendListView:getItems()
    if #items <= 0 then
        self:setCtrlVisible("FriendListView", false)
        local friendList = CitySocialMgr:getCityFriendList()
        if next(friendList) then
            self:setCtrlVisible("NoticePanel2", true)
            self:setCtrlVisible("NoticePanel", false)
        else
            self:setCtrlVisible("NoticePanel", true)
            self:setCtrlVisible("NoticePanel2", false)
        end
    else
        self:setCtrlVisible("FriendListView", true)
        self:setCtrlVisible("NoticePanel", false)
        self:setCtrlVisible("NoticePanel2", false)
    end
end

-- 创建好友列表
function CityFriendDlg:setFriendList()
    local data, allCou = self:getShowCityFriendList()

    local list = self.friendListView
    list:removeAllItems()
    list:setInnerContainerSize(cc.size(0, 0))
    self:stopSchedule()

    if #data <= 0 then
        self:updateUI()
        return
    end

    local curNum = 1
    local oneLoadNum = 10
    local cou = #data
    local function func()
        for i = curNum, curNum + oneLoadNum - 1 do
            if i > cou then
                self:stopSchedule()
                return
            end

            repeat
                self:updaetOneFriend(data[i].gid, true)
            until true
        end

        curNum = curNum + oneLoadNum
    end

    panelList = {}
    panleCount = 0
    self.friendSch = self:startSchedule(func, 0.4)

    func()
    oneLoadNum = 5
end

function CityFriendDlg:stopSchedule()
    if self.friendSch then
        Dialog.stopSchedule(self, self.friendSch)
        self.friendSch = nil
    end
end

function CityFriendDlg:removeOneFriend(gid)
    local list = self.friendListView
    local cell = self.friendPanels[gid]
    if cell then
        list:removeChild(cell)
        list:requestRefreshView()
        cell:release()
        self.friendPanels[gid] = nil

        self:updateUI()
    end
end

function CityFriendDlg:updaetOneFriend(gid, notRefresh)
    if GameMgr:isInBackground() then
        -- 收到聊天数据时，如果在后台不能刷新好友列表，保存数据等切回前台再做处理
        table.insert(self.needRefresh, {gid, notRefresh})
        return
    end


    local data = CitySocialMgr:getCityFriendInfo(gid)
    if not data then
        -- 缓存中已不存在该好友
        return
    end

    local list = self.friendListView
    local cell = self:getFriendPanel(gid)
    self:setOneFriendPanel(data, cell)

    if not cell:getParent() then
        list:pushBackCustomItem(cell)
        self:updateUI()
    end

    if not notRefresh then
        self:refreshList(gid)
    end
end

function CityFriendDlg:refreshList(gid)
    if not self.friendPanels[gid] then return end
    local list = self.friendListView
    local cell = self.friendPanels[gid]
    local no = list:getIndex(cell)
    local items = list:getItems()
    local index = #items

    for i = 1, #items do
        local l = cell.data
        local r = items[i].data
        if sortFunc(l, r) then
            -- 查询最佳位置
            -- 表中已经是一个有序的队列，所以，只要根据规则查询到相应的位置即可
            index = i
            break
        end
    end

    index = index - 1
    if index < 0 then
        -- 容错
        index = 0
    end

    -- 删除原来的条目
    if no ~= index then
        list:removeItem(no)
        list:insertCustomItem(cell, index)
    end

    return index
end

function CityFriendDlg:MSG_LBS_FRIEND_LIST(data)
    self:setFriendList()
end

function CityFriendDlg:MSG_LBS_REMOVE_FRIEND(data)
    self:removeOneFriend(data.gid)
end

function CityFriendDlg:MSG_LBS_ADD_FRIEND(data)
     -- setCityFriendLastChatTime 中已调用  updaetOneFriend 添加好友了
end

-- 从后台激活做的处理
function CityFriendDlg:onEnterForeground()
    for i = 1, #self.needRefresh do
        self:updaetOneFriend(self.needRefresh[i], self.needRefresh[i])
    end

    self.needRefresh = {}
end

function CityFriendDlg:cleanup()
    EventDispatcher:removeEventListener('ENTER_FOREGROUND', self.onEnterForeground, self)

    if self.friendPanels then
        for _, v in pairs(self.friendPanels) do
            v:release()
        end
    end

    self.friendPanels = nil

    self.needRefresh = nil

    DlgMgr:sendMsg("CityTabDlg", "setCheckBoxState", "FriendCity", self:isCheck("SameCityCheckBox"))
    DlgMgr:sendMsg("CityTabDlg", "setCheckBoxState", "FriendServer", self:isCheck("SameServerCheckBox"))
end

return CityFriendDlg
