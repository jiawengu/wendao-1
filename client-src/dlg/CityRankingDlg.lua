-- CityRankingDlg.lua
-- Created by huangzz Feb/28/2018
-- 区域排行榜界面

local CityRankingDlg = Singleton("CityRankingDlg", Dialog)

local StringBuilder = require "core/StringBuilder"

local TYPE_LIST = {
    CHS[3003531],  -- 等级
    CHS[3000049],  -- 道行
    CHS[3000051],  -- 物伤
    CHS[3000052],  -- 法伤
    CHS[3000053],  -- 速度
    CHS[3000054],  -- 防御
}

local TYPE_STR = {
    [RANK_TYPE.CHAR_LEVEL]            = CHS[3003531],    -- 等级排行
    [RANK_TYPE.CHAR_TAO]              = CHS[3000049],    -- 道行排行
    [RANK_TYPE.CHAR_PHY_POWER]        = CHS[3000051],    -- 物伤排行
    [RANK_TYPE.CHAR_MAG_POWER]        = CHS[3000052],    -- 法伤排行
    [RANK_TYPE.CHAR_SPEED]            = CHS[3000053],    -- 速度排行
    [RANK_TYPE.CHAR_DEF]              = CHS[3000054],    -- 防御排行
}

local TYPE_NUM = {
    [CHS[3003531]] = RANK_TYPE.CHAR_LEVEL,        -- 等级排行
    [CHS[3000049]] = RANK_TYPE.CHAR_TAO,          -- 道行排行
    [CHS[3000051]] = RANK_TYPE.CHAR_PHY_POWER,    -- 物伤排行
    [CHS[3000052]] = RANK_TYPE.CHAR_MAG_POWER,    -- 法伤排行
    [CHS[3000053]] = RANK_TYPE.CHAR_SPEED,        -- 速度排行
    [CHS[3000054]] = RANK_TYPE.CHAR_DEF,          -- 防御排行
}

local RANK_TYPE_FIELD_INFO = {
    [RANK_TYPE.CHAR_LEVEL]            = {[4] = "level"},    -- 等级排行
    [RANK_TYPE.CHAR_TAO]              = {[4] = "tao"},    -- 道行排行
    [RANK_TYPE.CHAR_PHY_POWER]        = {[4] = "phy_power"},    -- 物伤排行
    [RANK_TYPE.CHAR_MAG_POWER]        = {[4] = "mag_power"},    -- 法伤排行
    [RANK_TYPE.CHAR_SPEED]            = {[4] = "speed"},    -- 速度排行
    [RANK_TYPE.CHAR_DEF]              = {[4] = "def"},    -- 防御排行
}


local ONE_PAGE_NUM = 10

function CityRankingDlg:init()
    self:bindListener("ChangeTypeButton", self.onChangeTypeButton)           -- 显示排行榜类别
    self:bindListener("TypeButton", self.onTypeButton)                       -- 排行榜类别条目
    self:bindListener("OneRankingPanel", self.onOneRankingPanel)             -- 排行条目
    self:bindCheckBoxListener("SameServerCheckBox", self.onSameServerCheckBox) -- 是否仅显示同区组
    self:bindFloatPanelListener("TypeChoosePanel", "ChangeTypeButton", nil, self.onTypeCallBack)
    
    local isOpen = DlgMgr:sendMsg("CityTabDlg", "getCheckBoxState", "SameServerCheckBox") or false
    self:setCheck("SameServerCheckBox", isOpen)
    
    self.typeButton = self:retainCtrl("TypeButton")
    
    self.rankPanel = self:retainCtrl("OneRankingPanel")
    self.selectedImg = self:retainCtrl("SelectedImage", self.rankPanel)
    self.rankPanels = {}
    self.rankingData = {}
    self.myData = {}
    self.showList = {}
    
    -- 滚动加载
    self:bindListViewByPageLoad("RankingListView", "TouchPanel", function(dlg, percent)
        if percent > 100 and self:getCtrlVisible("RankingListView") then
            -- 加载
            self:setRankingList()
        end
    end)
    
    self:resetMyRankPanel(self:getControl("MyRankingPanel"))
    
    self.curType = RANK_TYPE.CHAR_LEVEL
    self:initTypePanel()
    
    self:setTipsView()
    
    self:hookMsg("MSG_LBS_RANK_INFO")
    self:hookMsg("MSG_MY_RANK_INFO")
    self:hookMsg("MSG_TEMP_FRIEND_STATE")
    self:hookMsg("MSG_CHAR_INFO")
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
end

function CityRankingDlg:setTipsView()
    self:setCtrlVisible("NoticePanel1", false)
    self:setCtrlVisible("RankingListView", false)
    if not CitySocialMgr:hasLocation() then
        self:setCtrlVisible("NoticePanel1", true)
    else
        self:setCtrlVisible("RankingListView", true)
    end
end

function CityRankingDlg:getTypeShowName(type)
    local str = ""
    return string.sub(type, 1, 3) .. "       " .. string.sub(type, 4, 6)
end

function CityRankingDlg:getTitleShowName(type)
    local str = ""
    return string.sub(type, 1, 3) .. " " .. string.sub(type, 4, 6)
end

-- 创建排行类别列表
function CityRankingDlg:initTypePanel()
    local panel = self:getControl("TypeChoosePanel")
    local x, y = self.typeButton:getPosition()
    local size = self.typeButton:getContentSize()
    local lineSpace = 5
    local totalH = (#TYPE_LIST) * (size.height + lineSpace) + 15
    
    -- 调整背景大小
    local backImg = self:getControl("BackImage", nil, "TypeChoosePanel")
    backImg:setContentSize(backImg:getContentSize().width, totalH)
    backImg:retain()
    panel:removeAllChildren()
    panel:addChild(backImg)
    backImg:release()
    panel:setContentSize(backImg:getContentSize())
    panel:requestDoLayout()
    
    totalH = totalH - 10 - size.height / 2
    for i = 1, #TYPE_LIST do
        local cell = self.typeButton:clone()
        self:setLabelText("TextLabel", self:getTypeShowName(TYPE_LIST[i]), cell)
        cell:setName(TYPE_LIST[i])
        cell:setPosition(x, totalH)
        totalH = totalH - size.height - lineSpace
        panel:addChild(cell)
    end
    
    -- 默认选中等级
    self:setSelectType(TYPE_LIST[1])
end

-- 打开排行榜类别列表
function CityRankingDlg:onChangeTypeButton(sender, eventType)
    local panel = self:getControl("TypeChoosePanel")
    local isVisible = not panel:isVisible()
    panel:setVisible(isVisible)
    local img = self:getControl("IconImage", nil, "ChangeTypeButton")
    img:setFlippedY(isVisible)
end

function CityRankingDlg:onTypeCallBack()
    local img = self:getControl("IconImage", nil, "ChangeTypeButton")
    img:setFlippedY(false)
end

function CityRankingDlg:onTypeButton(sender, eventType)
    local name = sender:getName()
    self:setSelectType(name)
end

function CityRankingDlg:setSelectType(name)
    self:setCtrlVisible("TypeChoosePanel", false)
    self:onTypeCallBack()
    
    if self.nextToType == TYPE_NUM[name] then
        return
    end
    
    self.nextToType = TYPE_NUM[name]
    
    self:setLabelText("TextLabel", string.format(CHS[5400499], name), "ChangeTypeButton")
    
    if not CitySocialMgr:hasLocation() then
        -- 未设置定位信息，不请求数据
        self.curType = self.nextToType
        self:setLabelText("AttributeNameLabel4", self:getTitleShowName(TYPE_STR[self.curType]), "RankingTitlePanel")
        return
    end

    if self.rankingData[self.nextToType] then
        self:MSG_LBS_RANK_INFO(self.rankingData[self.nextToType])
    else
        CitySocialMgr:requestRankInfo(self.nextToType)
    end
end

-- 仅显示同区组
function CityRankingDlg:onSameServerCheckBox(sender, eventType)
    if CitySocialMgr:hasLocation() then
        self:setRankingList(true)
    end
end

-- 选中单条排行条目
function CityRankingDlg:onOneRankingPanel(sender, eventType)
    local data = sender.data
    
    self.selectedImg:removeFromParent()
    sender:addChild(self.selectedImg)
    
    if not data then
        return
    end
    
    if data.gid == Me:queryBasic("gid") then
        return
    end
    
    local myDist = GameMgr:getDistName()
    self.menuInfo = {CHS[3000057]} -- 交流
    if myDist == data.dist_name then
        table.insert(self.menuInfo, 1, CHS[3000056]) -- 查看装备
        
        if not FriendMgr:hasFriend(data.gid) then
            table.insert(self.menuInfo, CHS[3000058]) -- 添加好友
        end
        
        if not CitySocialMgr:hasCityFriendByGid(data.gid) then
            table.insert(self.menuInfo, CHS[5400500]) -- 添加区域好友
        end
        
        table.insert(self.menuInfo, CHS[5400270]) -- 查看空间
    else
        -- 跨服
        FriendMgr:setKuafObj(data.gid, data.dist_name)
        if not CitySocialMgr:hasCityFriendByGid(data.gid) then
            table.insert(self.menuInfo, CHS[5400500]) -- 添加区域好友
        end
        
        table.insert(self.menuInfo, CHS[5400270]) -- 查看空间
    end

    self.menuInfo.char = data.name
    self.menuInfo.gid = data.gid
    self.menuInfo.icon = data.icon
    self.menuInfo.level = data.level or 0
    self.menuInfo.dist_name = data.dist_name

    -- 弹出菜单
    self:popupMenus(self.menuInfo)
end

-- 设置点击排行榜列表项中的菜单的响应事件
function CityRankingDlg:onClickMenu(idx)
    if not self.menuInfo then return end

    local menu = self.menuInfo[idx]
    if menu == CHS[3000056] then 
        -- 查看装备
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, self.menuInfo.gid)
    elseif menu == CHS[3000057] then
        -- 交流
        FriendMgr:communicat(self.menuInfo.char, self.menuInfo.gid, self.menuInfo.icon, self.menuInfo.level)
        self.menuInfo = nil
    elseif menu == CHS[3000058] then
        -- 发送数据请求
        FriendMgr:requestCharMenuInfo(self.menuInfo.gid)
        return
    elseif menu == CHS[5400500] then
        -- 请求数据查看是否在线，再添加好友
        FriendMgr:requestFriendOnlineState(self.menuInfo.gid, self.menuInfo.dist_name)
        return
    elseif menu == CHS[5400270] then
        -- 查看空间
        BlogMgr:openBlog(self.menuInfo.gid, nil, nil, self.menuInfo.dist_name)
        self.menuInfo = nil
    end
  
    self:closeMenuDlg()
end

function CityRankingDlg:MSG_CHAR_INFO(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.gid then return end

    self:closeMenuDlg()

    -- 尝试加为好友
    FriendMgr:tryToAddFriend(data.name, data.gid)
    self.menuInfo = nil
end

function CityRankingDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.char_id then return end
    
    self:closeMenuDlg()

    gf:ShowSmallTips(string.format(CHS[5400576], self.menuInfo.char))
    self.menuInfo = nil
end

function CityRankingDlg:MSG_TEMP_FRIEND_STATE(data)
    if not self.menuInfo then return end
    if self.menuInfo.gid ~= data.gid then return end

    self:closeMenuDlg()

    -- 尝试加为区域好友
    CitySocialMgr:tryToAddCityFriend(self.menuInfo.char, self.menuInfo.gid, data.online)
    self.menuInfo = nil
end

-- 获取排行条目
function CityRankingDlg:getRankingPanel(index)
    if self.rankPanels[index] then
        return self.rankPanels[index]
    else
        local cell = self.rankPanel:clone()
        cell:retain()
        self.rankPanels[index] = cell
        return cell
    end
end

-- 设置排行榜单条条目
function CityRankingDlg:setOneRankPanel(data, cell, index)
    self:setCtrlVisible("BackImage2", index % 2 == 0, cell)
    self:setLabelText("AttributeLabel1", data.rank, cell)
    self:setLabelText("AttributeLabel2", data["name"], cell)
    self:setLabelText("AttributeLabel3", gf:getPolar(data["polar"]), cell)
    self:setLabelText("AttributeLabel5", data["dist_name"], cell)
   
    if self.curType == RANK_TYPE.CHAR_TAO then
        self:setLabelText("AttributeLabel4", self:getTaoStr(data.tao, data.tao_ex), cell)
    else
        self:setLabelText("AttributeLabel4", data[RANK_TYPE_FIELD_INFO[self.curType][4]], cell)
    end
   
    cell.data = data 
end

-- 道行字符串
function CityRankingDlg:getTaoStr(tao, taoPoint)
    if tao <= 0 and taoPoint <= 0 then
        -- 无道行
        return CHS[34048]
    end

    local year = math.floor(tao / Const.ONE_YEAR_TAO)
    local day = tao % Const.ONE_YEAR_TAO

    local sb = StringBuilder.new()
    local hasYear = false
    if year ~= 0 then
        -- 年
        sb:add(string.format(CHS[34049], year))
        hasYear = true
    end

    if day ~= 0 then
        -- 天
        sb:add(string.format(CHS[34050], day))
    end

    if taoPoint ~= 0 and not hasYear then
        -- 点
        -- 有年的话就不显示点了
        sb:add(taoPoint .. CHS[3000017])
    end

    return sb:toString()
end


-- 获取可显示的排行榜数据
function CityRankingDlg:getRankingData()
    local data = self.rankingData[self.curType] or {}
    local showData = {}
    local onlyShwoSameServer = self:isCheck("SameServerCheckBox")
    local myDist = GameMgr:getDistName()
    for i = 1, #data do
        if not onlyShwoSameServer or data[i].dist_name == myDist then
            table.insert(showData, data[i])
        end
    end
    
    return showData
end

function CityRankingDlg:setRankingList(isReset)
    local list = self:getControl("RankingListView")
    if isReset then
        list:removeAllItems()
        list:setInnerContainerSize(cc.size(0, 0))
        self.loadNum = 1
        self.showList = self:getRankingData()
    end
    
    local data = self.showList
    
    -- 设置标题
    self:setLabelText("AttributeNameLabel4", self:getTitleShowName(TYPE_STR[self.curType]), "RankingTitlePanel")
    self:setLabelText("TextLabel", string.format(CHS[5400499], TYPE_STR[self.curType]), "ChangeTypeButton")
    
    if #data <= 0 then
        self:setCtrlVisible("RankingListView", false)
        self:setCtrlVisible("NoticePanel2", true)
        return
    else
        self:setCtrlVisible("RankingListView", true)
        self:setCtrlVisible("NoticePanel2", false)
    end
    
    if not data[self.loadNum] then
        -- 已加载完
        gf:ShowSmallTips(CHS[3003548])
        return
    end

    local loadNum = self.loadNum
    for i = 1, ONE_PAGE_NUM do
        if data[loadNum] then
            local cell = self:getRankingPanel(loadNum)
            self:setOneRankPanel(data[loadNum], cell, loadNum)
            list:pushBackCustomItem(cell)

            loadNum = loadNum + 1
        end
    end

    list:requestRefreshView()
    list:doLayout()
    self.loadNum = loadNum
end

-- 定位成功后要重新请求数据
function CityRankingDlg:resetAllData()
    self.rankingData = {}
    CitySocialMgr:requestRankInfo(self.nextToType or self.curType or RANK_TYPE.CHAR_LEVEL)
end

function CityRankingDlg:MSG_LBS_RANK_INFO(data)
    self.rankingData[data.type] = data
    
    if self.nextToType ~= data.type then
        return
    end
    
    self.curType = self.nextToType
    
    if CitySocialMgr:hasLocation() then
        self:setRankingList(true)
    end
    
    local rank = 0
    for i = 1, #data do
        if data[i].gid == Me:queryBasic("gid") then
            rank = i
            break
        end
    end

    self:setMyRankPanel(self:getControl("MyRankingPanel"), rank)
end

function CityRankingDlg:MSG_MY_RANK_INFO(data)
    self.myData[RANK_TYPE_FIELD_INFO[data.rankNo][4]] = data.value
end

function CityRankingDlg:resetMyRankPanel(cell)
    self:setLabelText("AttributeLabel1", "", cell)
    self:setLabelText("AttributeLabel2", "", cell)
    self:setLabelText("AttributeLabel3", "", cell)
    self:setLabelText("AttributeLabel4", "", cell)
    self:setLabelText("AttributeLabel5", "", cell)
end

function CityRankingDlg:setMyRankPanel(cell, index)
    if index > 0 then
        self:setLabelText("AttributeLabel1", index, cell)
    else
        self:setLabelText("AttributeLabel1", CHS[5400435], cell)
    end
    
    self:setLabelText("AttributeLabel2", Me:queryBasic("name"), cell)
    self:setLabelText("AttributeLabel3", gf:getPolar(Me:queryBasicInt("polar")), cell)
    self:setLabelText("AttributeLabel5", GameMgr:getDistName(), cell)

    if self.curType == RANK_TYPE.CHAR_TAO then
        self:setLabelText("AttributeLabel4", self:getTaoStr(Me:queryInt("tao"), Me:queryInt("tao_ex")), cell)
    elseif self.curType == RANK_TYPE.CHAR_LEVEL then
        self:setLabelText("AttributeLabel4", Me:getLevel(), cell)
    else
        self:setLabelText("AttributeLabel4", self.myData[RANK_TYPE_FIELD_INFO[self.curType][4]], cell)
    end
end

function CityRankingDlg:cleanup()
    if self.rankPanels then
        for _, v in pairs(self.rankPanels) do
            v:release()
        end
    end

    self.rankPanels = nil
    self.curType = nil
    self.nextToType = nil
    self.rankingData = nil
    self.menuInfo = nil
    
    DlgMgr:sendMsg("CityTabDlg", "setCheckBoxState", "SameServerCheckBox", self:isCheck("SameServerCheckBox"))
end

return CityRankingDlg
