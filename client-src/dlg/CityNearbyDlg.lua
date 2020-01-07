-- CityNearbyDlg.lua
-- Created by huangzz Feb/28/2018
-- 附近的人界面

local CityNearbyDlg = Singleton("CityNearbyDlg", Dialog)

local ONE_PAGE_NUM = 10 -- 分页加载好友列表，每页 10 条

local userDefault
local smallId
function CityNearbyDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("RuleInfoButton", self.onRuleButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindCheckBoxListener("MaleCheckBox", self.onMaleCheckBox)
    self:bindCheckBoxListener("FemaleCheckBox", self.onFemaleCheckBox)
    self:bindCheckBoxListener("ShareCheckBox", self.onShareCheckBox)
    self:blindLongPress("PortraitPanel", self.onLongPortraitPanel, nil, "OneFriendPanel")

    userDefault = cc.UserDefault:getInstance()
    smallId = gf:getShowId(Me:queryBasic("gid"))

    local isOpen = DlgMgr:sendMsg("CityTabDlg", "getCheckBoxState", "MaleCheckBox")
    if isOpen == nil then isOpen = true end
    self:setCheck("MaleCheckBox", isOpen)

    local isOpen = DlgMgr:sendMsg("CityTabDlg", "getCheckBoxState", "FemaleCheckBox")
    if isOpen == nil then isOpen = true end
    self:setCheck("FemaleCheckBox", isOpen)

    self.friendPanel = self:retainCtrl("OneFriendPanel")
    self.friendPanels = {}
    self.showList = {}

    self.canTipRefresh = false

    self.scheduleId = nil

    self.hasRequest = false

    self.delayShare = nil

    self.playersInfo = CitySocialMgr:getNearPlayerInfo()

    -- 滚动加载
    self:bindListViewByPageLoad("FriendListView", "TouchPanel", function(dlg, percent)
        if percent > 100 and self:getCtrlVisible("FriendListView") then
            -- 加载
            self:setPlayerList()
        end
    end)

    local curTime = gf:getServerTime()
    self:setConfirmButton(curTime)

    self:checkShareState(curTime)

    self:setTipsView()

    self:hookMsg("MSG_LBS_SEARCH_NEAR")
    self:hookMsg("MSG_LBS_CHAR_INFO")
end

function CityNearbyDlg:setTipsView()
    self:setCtrlVisible("NoticePanel1", false)
    self:setCtrlVisible("NoticePanel2", false)
    self:setCtrlVisible("NoticePanel3", false)
    self:setCtrlVisible("FriendListView", false)
    self:setCtrlEnabled("ConfirmButton", false)
    if not CitySocialMgr:hasLocation() then
        self:setCtrlVisible("NoticePanel1", true)
    elseif not self:isCheck("ShareCheckBox") then
        self:setCtrlVisible("NoticePanel2", true)
    else
        self:setCtrlVisible("FriendListView", true)
        if not self.scheduleId then
            self:setCtrlEnabled("ConfirmButton", true)
        end

        if not self.playersInfo and not self.hasRequest then
            self:requestNearbyInfo()
        elseif self.playersInfo then
            self:setPlayerList(true)
        end
    end
end

function CityNearbyDlg:canShowListView()
    if CitySocialMgr:hasLocation() and self:isCheck("ShareCheckBox") then
        return true
    end
end

-- 刷新
function CityNearbyDlg:onConfirmButton(sender, eventType)
    if self:requestNearbyInfo(true) then
        local curTime = gf:getServerTime()
        CitySocialMgr:setRefreshNearbyTime(curTime)
        self:setConfirmButton(curTime)
    end
end

function CityNearbyDlg:requestNearbyInfo(fromRefresh)
    if not CitySocialMgr:hasLocation() or not self:isCheck("ShareCheckBox") then
        self:setTipsView()
        return
    end

    local maleCanShow = self:isCheck("MaleCheckBox")
    local femaleCanShow = self:isCheck("FemaleCheckBox")
    local sex
    if maleCanShow and not femaleCanShow then
        sex = 1
    elseif not maleCanShow and femaleCanShow then
        sex = 2
    elseif maleCanShow and femaleCanShow then
        sex = 0
    else
        return
    end

    self.canTipRefresh = fromRefresh
    CitySocialMgr:requestNearbyInfo(sex)
    self.hasRequest = true

    return true
end

-- 显示刷新倒计时
function CityNearbyDlg:setConfirmButton(curTime)
    local lastTime = CitySocialMgr:getLastRefreshNearbyTime()
    local function func(str)
        self:setLabelText("Label_1", str, "ConfirmButton")
        self:setLabelText("Label_2", str, "ConfirmButton")
    end

    self:stopSchedule()
    if curTime - lastTime < 10 then
        self:setCtrlEnabled("ConfirmButton", false)
        local delayTime = 10 - (curTime - lastTime)
        func(delayTime .. "s")
        self.scheduleId = self:startSchedule(function()
            delayTime = delayTime - 1
            if delayTime == 0 then
                self:stopSchedule()
                if self:canShowListView() then
                    self:setCtrlEnabled("ConfirmButton", true)
                end

                func(CHS[5400494])
            else
                func(delayTime .. "s")
            end
        end, 1)
    else
        func(CHS[5400494])
    end
end

function CityNearbyDlg:stopSchedule()
    if self.scheduleId then
        self.root:stopAction(self.scheduleId)
        self.scheduleId = nil
    end
end

function CityNearbyDlg:onRuleButton(sender, eventType)
    gf:showTipInfo(CHS[5400510], sender)
end

-- 角色信息对话框
function CityNearbyDlg:onInfoButton(sender, eventType)
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

-- 是否显示男玩家
function CityNearbyDlg:onMaleCheckBox(sender, eventType)
    if not self:isCheck("FemaleCheckBox") and not sender:getSelectedState() then
        gf:ShowSmallTips(CHS[5400515])
        sender:setSelectedState(true)
        return
    end

    self:setTipsView()
end

-- 是否显示女玩家
function CityNearbyDlg:onFemaleCheckBox(sender, eventType)
    if not self:isCheck("MaleCheckBox") and not sender:getSelectedState() then
        gf:ShowSmallTips(CHS[5400515])
        sender:setSelectedState(true)
        return
    end

    self:setTipsView()
end

-- 是否开启定位分享
function CityNearbyDlg:onShareCheckBox(sender, eventType)
    if not sender:getSelectedState() then
        -- 取消分享
        CitySocialMgr:requestDisShare()

        -- 服务端没通知修改，自己标记分享已关闭
        CitySocialMgr.userInfo.share_near_endtime = 0
    else
        if not CitySocialMgr:hasLocation() then
            gf:ShowSmallTips(CHS[5400487])
            return
        end

        -- 开启分享
        local lastTime = CitySocialMgr:getLastRefreshNearbyTime()
        local curTime = gf:getServerTime()
        local cTime = 10 - (curTime - lastTime)
        if cTime > 0 then
            gf:ShowSmallTips(string.format(CHS[5410233], cTime))
            sender:setSelectedState(false)
            return
        end

        if self:requestNearbyInfo() then
            local curTime = gf:getServerTime()
            CitySocialMgr:setRefreshNearbyTime(curTime)
            self:setConfirmButton(curTime)
        end
    end

    self:setTipsView()
end

-- 获取要显示的附近的玩家
function CityNearbyDlg:getShowPlayerList()
    if not self.playersInfo then
        return {}
    end

    local data = {}
    local maleCanShow = self:isCheck("MaleCheckBox")
    local femaleCanShow = self:isCheck("FemaleCheckBox")
    for i = 1, #self.playersInfo do
        if self.playersInfo[i].sex == 1 and maleCanShow then
            table.insert(data, self.playersInfo[i])
        elseif self.playersInfo[i].sex == 2 and femaleCanShow then
            table.insert(data, self.playersInfo[i])
        end
    end

    return data
end

-- 设置条目头像
function CityNearbyDlg:setPortrait(filePath, para)
    if para.cell and para.data and para.cell.data and para.cell.data.gid == para.data.gid then
        self:setImage("PortraitImage", filePath, para.cell)
    end
end

-- 长按头像
function CityNearbyDlg:onLongPortraitPanel(sender)
    local data = sender:getParent().data
    if not data or data.gid == Me:queryBasic("gid") then return end

    local dlg = BlogMgr:showButtonList(self, sender, "reportPortrait", self.name)
    dlg:setGid(data.gid)
end

-- 举报头像
function CityNearbyDlg:reportIcon(sender)
    local data = sender:getParent().data
    if data then
        CitySocialMgr:reportIcon(data.gid, data.icon_img, data.dist_name)
    end
end

-- 设置单个玩家的数据
function CityNearbyDlg:setOnePlayerPanel(data, cell)
    cell.data = data

    -- 玩家数据
    self:setPortrait(ResMgr:getSmallPortrait(data.icon), {cell = cell, data = data})

    if not string.isNilOrEmpty(data.icon_img) then
        BlogMgr:assureFile("setPortrait", self.name, data.icon_img, nil, {cell = cell, data = data})
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

    -- 距离
    local dist = data.distance or 0
    local panel = self:getControl("DistancePanel", nil, cell)
    if dist > 10000 then
        self:setLabelText("TextLabel", ">10km", panel)
    elseif dist >= 1000 then
        dist = math.floor(dist / 10) / 100
        self:setLabelText("TextLabel", string.format("%0.02f", dist) .. "km", panel)
    elseif dist < 10 then
        self:setLabelText("TextLabel", "<10m", panel)
    else
        self:setLabelText("TextLabel", dist .. "m", panel)
    end
end

function CityNearbyDlg:getPlayerPanel(index)
    if self.friendPanels[index] then
        return self.friendPanels[index]
    else
        local cell = self.friendPanel:clone()
        cell:retain()
        self.friendPanels[index] = cell
        return cell
    end
end

-- 显示附近的玩家列表
function CityNearbyDlg:setPlayerList(isReset)
    local list = self:getControl("FriendListView")
    if isReset then
        list:removeAllItems()
        list:setInnerContainerSize(cc.size(0, 0))
        self.loadNum = 1
        self.showList = self:getShowPlayerList()
    end

    local data = self.showList

    if #data <= 0 then
        self:setCtrlVisible("NoticePanel3", true)
        self:setCtrlVisible("FriendListView", false)
        return
    else
        self:setCtrlVisible("NoticePanel3", false)
        if CitySocialMgr:hasLocation() and self:isCheck("ShareCheckBox") then
            self:setCtrlVisible("FriendListView", true)
        end
    end

    if not data[self.loadNum] then
        return
    end

    local loadNum = self.loadNum
    for i = 1, ONE_PAGE_NUM do
        if data[loadNum] then
            local cell = self:getPlayerPanel(loadNum)
            cell:setName(data[loadNum].gid)
            self:setOnePlayerPanel(data[loadNum], cell)
            list:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    list:requestRefreshView()
    list:doLayout()
    self.loadNum = loadNum
end

function CityNearbyDlg:MSG_LBS_SEARCH_NEAR(data)
    self.playersInfo = CitySocialMgr:getNearPlayerInfo()

    if self.canTipRefresh then
        gf:ShowSmallTips(CHS[5400514])
    end

    if self:canShowListView() then
        self:setPlayerList(true)
    end

    self:checkShareState(gf:getServerTime())
end

-- 检查分享状态
function CityNearbyDlg:checkShareState(curTime)
    if self.delayShare then
        self.root:stopAction(self.delayShare)
    end

    local endTime = CitySocialMgr:getShareEndTime()
    if curTime >= endTime then
        self:setCheck("ShareCheckBox", false)
    else
        self:setCheck("ShareCheckBox", true)
        self.delayShare = performWithDelay(self.root, function()
            self:requestNearbyInfo()
            self.delayShare = nil
        end, endTime - curTime)
    end
end

function CityNearbyDlg:MSG_LBS_CHAR_INFO(data)
    self:setTipsView()
end

function CityNearbyDlg:cleanup()
    if self.friendPanels then
        for _, v in pairs(self.friendPanels) do
            v.data = nil
            v:release()
        end
    end

    self.friendPanels = nil
    self.playersInfo = nil

    DlgMgr:sendMsg("CityTabDlg", "setCheckBoxState", "MaleCheckBox", self:isCheck("MaleCheckBox"))
    DlgMgr:sendMsg("CityTabDlg", "setCheckBoxState", "FemaleCheckBox", self:isCheck("FemaleCheckBox"))
end

return CityNearbyDlg
