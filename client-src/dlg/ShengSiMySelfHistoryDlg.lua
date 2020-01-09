-- ShengSiMySelfHistoryDlg.lua
-- Created by huangzz Apr/28/2018
-- 生死状-个人历史数据界面

local ShengSiMySelfHistoryDlg = Singleton("ShengSiMySelfHistoryDlg", Dialog)

local REQUEST_SPACE = 1000

function ShengSiMySelfHistoryDlg:init(para)
    self:bindListener("RecordPanel", self.onRecordPanel)
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.SSZJJ, self.onShareButton)

    self.recordPanel = self:retainCtrl("RecordPanel")

    self.listView = self:getControl("ListView")
    self.loadingPanel = self:retainCtrl("LoadingPanel")
    
    self.furniturePos = para
    self.ownGid = nil

    self:requestHistoryList(nil)

    self:initListView()

    self:hookMsg("MSG_LD_HISTORY_PAGE")
    self:hookMsg("MSG_LD_GENERAL_INFO")
end

function ShengSiMySelfHistoryDlg:onRecordPanel(sender, eventType)
    local data = sender.data

   --[[ self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)]]
    
    if data then
        local dlg = DlgMgr:openDlg("ShengSiDetailsDlg")
        dlg:setData(data)
    end
end

function ShengSiMySelfHistoryDlg:onShareButton(sender, eventType)
    if not self.ownGid or self.ownGid ~= Me:queryBasic("gid") then
        gf:ShowSmallTips(CHS[2500054])
        return
    end

    -- 分享
    ShareMgr:share(SHARE_FLAG.SSZJJ)
end

function ShengSiMySelfHistoryDlg:setLabelValue(str, panelName)
    local panel = self:getControl(panelName, nil, "CombantInfoPanel")
    self:setLabelText("LeftLabel_2", str, panel)
end

function ShengSiMySelfHistoryDlg:setLeftInfo(data)
    self:setImage("Image", ResMgr:getCirclePortraitPathByIcon(data.own_icon), "PortraitPanel")

    self:setLabelText("NameLabel", gf:getRealName(data.own_name), "PortraitPanel")

    self:setLabelValue(string.format(CHS[5450210], data.total_num), "TotalPanel")

    self:setLabelValue(string.format(CHS[5450210], data.send_num), "SendPanel")

    self:setLabelValue(string.format(CHS[5450210], data.rec_num), "ReceivePanel")

    self:setLabelValue(string.format(CHS[5450210], data.win_num), "WinTimesPanel")
    
    local rate = math.floor((data.win_num / math.max(1, data.total_num)) * 10000) / 100
    self:setLabelValue(rate .. "%", "WinRatesPanel")

    if data.win_cash == 0 then
        self:setLabelValue(data.win_cash, "WinCashPanel")
    elseif data.win_cash >= 10000 then
        self:setLabelValue(string.format(CHS[5450225], math.floor(data.win_cash / 10000)), "WinCashPanel")
    else
        self:setLabelValue(string.format(CHS[5450211], math.floor(data.win_cash)), "WinCashPanel")
    end

    self:setLabelValue(data.win_coin, "WinCoinPanel")
end

function ShengSiMySelfHistoryDlg:onInfoPanel(sender, eventType)
    local data = sender.data

    self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)
    
    if data then
        local dlg = DlgMgr:openDlg("ShengSiDetailsDlg")
        dlg:setData(data)
    end
end


-- 请求生死状历史数据
function ShengSiMySelfHistoryDlg:requestHistoryList(time, needGenaral)
    self.lastRequestInfoTime = time or gf:getServerTime()
    self.lastRequestTime = gfGetTickCount()
    gf:CmdToServer("CMD_LD_MY_HISTORY_PAGE", {pos = self.furniturePos, last_time = self.lastRequestInfoTime, needGenaral = needGenaral or 0})
end

-- 初始化列表
function ShengSiMySelfHistoryDlg:initListView()
    self.isLoading = nil   -- 标记正在请求数据
    self.isLoadEnd = nil   -- 标记已加载完最后一页
    self.notCallListView = nil

    local function onScrollView(sender, eventType)
        if self.notCallListView or self.isLoadEnd or self.isLoading then
            return
        end

        if ccui.ScrollviewEventType.scrolling == eventType 
            or ccui.ScrollviewEventType.scrollToTop == eventType 
            or ccui.ScrollviewEventType.scrollToBottom == eventType then
            -- 获取控件
            local listInnerContent = sender:getInnerContainer()
            local lastData = self:getLoadedLastData()
            if not lastData then
                return
            end

            -- 计算滚动的百分比
            local innerPosY = listInnerContent:getPositionY()
            if innerPosY > 10 then
                -- 向下加载
                self:setLoadingVisible(true)
                
                local curTime = gfGetTickCount()
                local cTime = REQUEST_SPACE - (curTime - self.lastRequestTime)
                cTime = math.max(cTime, 0)
                performWithDelay(sender, function() 
                    self:requestHistoryList(lastData.time)
                end, cTime / 1000)
            end
        end
    end

    self.listView:addScrollViewEventListener(onScrollView)
    self.listView:setVisible(false)

        -- loading界面动起来
    local circleCtrl = self:getControl("LoadingImage", nil, self.loadingPanel)
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    circleCtrl:runAction(action)
end

-- 努力加载中
function ShengSiMySelfHistoryDlg:setLoadingVisible(visible)
    if self.isLoading == visible then
        return
    end

    local listView = self.listView
    self:setCtrlVisible("LoadingPanel", visible, "LoadPanel")
    self.isLoading = visible

    if visible then
        listView:pushBackCustomItem(self.loadingPanel)
    elseif self.loadingPanel:getParent() then
        listView:removeChild(self.loadingPanel, false)
    end

    self.notCallListView = true
    listView:refreshView()
    self.notCallListView = false
end

-- 获取已经显示的最后一条数据
function ShengSiMySelfHistoryDlg:getLoadedLastData()
    local list = self.listView
    local items = list:getItems()

    local count = #items
    if count ~= 0 then
        return items[count].data
    end
end

function ShengSiMySelfHistoryDlg:refreshList(data, isReset)
    if isReset then
        self.listView:removeAllItems()
        
        if #data == 0 then
            self.listView:setVisible(false)
            return
        else
            self.listView:setVisible(true)
        end
    end

    local lastHeight = self.listView:getInnerContainer():getContentSize().height
    for i = 1, #data do
        local panel = self.recordPanel:clone()
        self:setOneRecordPanel(panel, data[i])
        panel:setName(data[i].id)
        self.listView:pushBackCustomItem(panel)
    end

    if not isReset and #data > 0 then
        self.notCallListView = true
        self.listView:requestRefreshView()
        self.listView:doLayout()
        performWithDelay(self.root, function()
            -- 拉得太快会导致直接划到下一页的底部，此处重新拉回原来的位置
            self:jumpToItem(lastHeight)
            self.notCallListView = false
        end, 0)
    end
end

function ShengSiMySelfHistoryDlg:jumpToItem(offsetY)
    local contentSize = self.listView:getContentSize()
    local innerContainer = self.listView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end

    innerContainer:setPositionY(offsetY)
end

function ShengSiMySelfHistoryDlg:setOneRecordPanel(cell, data)
    local oppInfo, type
    if data.att_info.gid == self.ownGid then
        oppInfo = data.def_info
        type = "atk"
        self:setLabelText("CombatLabel", CHS[5450222], cell)
    else
        oppInfo = data.att_info
        type = "def"
        self:setLabelText("CombatLabel", CHS[5450223], cell)
    end

    self:setImage("PortraitImage", ResMgr:getSmallPortrait(oppInfo.icon), cell)

    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, oppInfo.level, false, LOCATE_POSITION.LEFT_TOP, 19, cell)
    
    self:setLabelText("NameLabel", oppInfo.name, cell)

    self:setLabelText("TypeLabel", data.mode, cell)

    if data.result == type then
        -- 赢
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_win, cell)
    else
        -- 除了赢，都是输
        self:setImagePlist("ResultImage", ResMgr.ui.party_war_lose, cell)
    end

    -- 赌注
    self:setCtrlVisible("CoinImage", false, cell)
    self:setCtrlVisible("CashImage", false, cell)
    if data.bet_type == "cash" then
        self:setCtrlVisible("CashImage", true, cell)
    elseif data.bet_type == "coin" then
        self:setCtrlVisible("CoinImage", true, cell)
    end

    local str
    local color
    if data.bet_num == 0 then
        str = CHS[5000059]
        color = COLOR3.TEXT_DEFAULT
    else
        str, color = gf:getMoneyDesc(data.bet_num, true)
    end
    
    self:setLabelText("NumLabel_1", str, cell, color)
    self:setLabelText("NumLabel_2", str, cell)

    cell.data = data
end

function ShengSiMySelfHistoryDlg:MSG_LD_HISTORY_PAGE(data)
    if data.type ~= 2 then return end

    if self.lastRequestInfoTime ~= data.last_time then return end

    self.lastRequestInfoTime = nil
    
    self:setLoadingVisible(false)

    -- 请求数据失败
    if data.count == -1 then
        return
    end

    local isFirst = false
    local info = self:getLoadedLastData()
    if not info or data.last_time > info.time  then
        -- 第一页
        isFirst = true
    end

    -- 已经是最后一页
    if data.count == 0 then
        self.isLoadEnd = true
        
        if not isFirst then
            -- gf:ShowSmallTips(CHS[5450120])
        end
    end

    if isFirst then
        -- 第一页
        self:refreshList(data, true)
    else
        self:refreshList(data)
    end
end

function ShengSiMySelfHistoryDlg:MSG_LD_GENERAL_INFO(data)
    self.ownGid = data.own_gid
    self:setLeftInfo(data)
end

return ShengSiMySelfHistoryDlg
