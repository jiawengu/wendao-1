-- ShengSiHistoryDlg.lua
-- Created by huangzz Apr/28/2018
-- 生死状-历史数据

local ShengSiHistoryDlg = Singleton("ShengSiHistoryDlg", Dialog)

local REQUEST_SPACE = 1000

function ShengSiHistoryDlg:init()
    self:bindListener("InfoPanel", self.onInfoPanel)
    self.infoPanel = self:retainCtrl("InfoPanel")
    self.selectImg = self:retainCtrl("SelectedImage", self.infoPanel)

    self.listView = self:getControl("ListView")
    self.loadingPanel = self:retainCtrl("LoadingPanel")

    self:requestHistoryList()

    self:initListView()

    self:hookMsg("MSG_LD_HISTORY_PAGE")
end

-- 请求生死状历史数据
function ShengSiHistoryDlg:requestHistoryList(time)
    self.lastRequestInfoTime = time or gf:getServerTime()
    self.lastRequestTime = gfGetTickCount()
    gf:CmdToServer("CMD_LD_HISTORY_PAGE", {last_time = self.lastRequestInfoTime})
end

-- 初始化列表
function ShengSiHistoryDlg:initListView()
    self.isLoading = nil   -- 标记正在请求数据
    self.isLoadEnd = nil   -- 标记已加载完最后一页
    self.notCallListView = nil

    self:setCtrlVisible("NoticePanel", false)

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
function ShengSiHistoryDlg:setLoadingVisible(visible)
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
function ShengSiHistoryDlg:getLoadedLastData()
    local list = self.listView
    local items = list:getItems()

    local count = #items
    if count ~= 0 then
        return items[count].data
    end
end

function ShengSiHistoryDlg:refreshList(data, isReset)
    if isReset then
        self.listView:removeAllItems()
        
        if #data == 0 then
            self:setCtrlVisible("NoticePanel", true)
            self.listView:setVisible(false)
            return
        else
            self:setCtrlVisible("NoticePanel", false)
            self.listView:setVisible(true)
        end
    end
    
    local lastHeight = self.listView:getInnerContainer():getContentSize().height
    local items = self.listView:getItems()
    local index = #items
    for i = 1, #data do
        local panel = self.infoPanel:clone()
        self:setOneInfoPanel(data[i], panel, index + i)
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

function ShengSiHistoryDlg:jumpToItem(offsetY)
    local contentSize = self.listView:getContentSize()
    local innerContainer = self.listView:getInnerContainer()

    local minY = contentSize.height - innerContainer:getContentSize().height
    offsetY = minY + offsetY - contentSize.height
    if offsetY <= 0 then
        offsetY = math.max(offsetY, minY)
    end

    innerContainer:setPositionY(offsetY)
end


function ShengSiHistoryDlg:onInfoPanel(sender, eventType)
    local data = sender.data

    self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)
    
    if data then
        local dlg = DlgMgr:openDlg("ShengSiDetailsDlg")
        dlg:setData(data)
    end
end

function ShengSiHistoryDlg:setOneInfoPanel(data, cell, index)
    self:setCtrlVisible("BackImage_2", (index % 2) == 0, cell)

    -- 时间
    self:setLabelText("TimeLabel_1", gf:getServerDate("%m-%d %H:%M", data.time), cell)

    -- 挑战方
    self:setLabelText("ChallengerLabel", data.att_info.name, cell)

    -- 应战方
    self:setLabelText("CounterLabel", data.def_info.name, cell)

    if data.result == "atk" then
        -- 挑战方赢
        self:setImagePlist("ChallengerResultImage", ResMgr.ui.party_war_win, cell)
        self:setImagePlist("CounterResultImage", ResMgr.ui.party_war_lose, cell)
    elseif data.result == "def" or data.result == "draw" then
        -- 应战方赢
        self:setImagePlist("ChallengerResultImage", ResMgr.ui.party_war_lose, cell)
        self:setImagePlist("CounterResultImage", ResMgr.ui.party_war_win, cell)
    else
        -- 都输
        self:setImagePlist("ChallengerResultImage", ResMgr.ui.party_war_lose, cell)
        self:setImagePlist("CounterResultImage", ResMgr.ui.party_war_lose, cell)
    end

    -- 模式
    self:setLabelText("TypeLabel", data.mode, cell)

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

function ShengSiHistoryDlg:MSG_LD_HISTORY_PAGE(data)
    if data.type ~= 1 then return end

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

return ShengSiHistoryDlg
