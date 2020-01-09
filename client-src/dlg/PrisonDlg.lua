-- PrisonDlg.lua
-- Created by yangym sep/29/2016
-- 监狱界面

local PrisonDlg = Singleton("PrisonDlg", Dialog)        
local PER_PAGE_COUNT                 = 12
local PANEL_HEIGHT                   = 50

function PrisonDlg:init()

    -- 绑定控件
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("CleanButton", self.onCleanButton)
    self:bindListener("IntercedeButton", self.onIntercedeButton)
    self:bindListener("BailButton", self.onBailButton)
    
    -- 初始化变量
    self.listView = self:getControl("PrisonMemberListView")
    local size = self.listView:getInnerContainerSize()
    size.height = 1000
    self.listView:setInnerContainerSize(size)
    
    self.curPrisoner = nil
    self.panelList = {}
    self.prisonerInfo = {}
    self.start = 1  --代表当前下一个位置从哪里开始
    
    -- 下拉加载
    self:bindListViewByPageLoad("PrisonMemberListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then        
            -- 每次下拉多加载PER_PAGE_COUNT个条目，
            local prisonerList = PrisonMgr:getPrisonerList(self.start, self.start + PER_PAGE_COUNT - 1, self.prisonerInfo)
            if not prisonerList then
                return 
            end
            
            self:pushData(prisonerList)
        end
    end)
    
    -- 克隆条目信息
    local prisonerPanel = self:getControl("OneRowPrisonMemberPanel", Const.UIPanel)
    self.prisonerPanel = prisonerPanel
    self.prisonerPanel:retain()
    self:getControl("OneRowPrisonMemberPanel"):removeFromParent()
    
    -- 输入框初始化
    self.nameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type)
        if type == "end" then

        elseif type == "changed" then
            local name = self.nameEdit:getText()

            if gf:getTextLength(name) > 12 then
                name = gf:subString(name, 12)
                self.nameEdit:setText(name)
                gf:ShowSmallTips(CHS[5400041])
            end
        end
    end)
    self.nameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.nameEdit:setFont(CHS[3003794], 23)
    self.nameEdit:setPlaceHolder(CHS[7000065])
    self.nameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    
    self:hookMsg("MSG_ZUOLAO_INFO_FINISH")
    self:hookMsg("MSG_RELEASE_SUCC")
    
    DlgMgr:openDlg("WaitDlg")
    
    -- 等待服务器发送数据完毕，若超时则直接显示当前数据
    self.delayPushData = performWithDelay(self.root, function ()
        DlgMgr:closeDlg("WaitDlg")
        -- 如果未收到服务器发送的数据，则使用PrisonMgr中的缓存数据
        if #self.prisonerInfo == 0 and #PrisonMgr:getPrisonerInfo() ~= 0 then
            self.prisonerInfo = PrisonMgr:getPrisonerInfo()
            self:pushData()
        end

        self.delayPushData = nil
    end, 2)

end

function PrisonDlg:MSG_ZUOLAO_INFO_FINISH(data)
    self.listView:removeAllChildren()
    self.start = 1
    self.prisonerInfo = PrisonMgr:getPrisonerInfo()
    
    local prisonerList = PrisonMgr:getPrisonerList(1, PER_PAGE_COUNT, self.prisonerInfo)
    self:pushData(prisonerList)

    if self.delayPushData then
        self.root:stopAction(self.delayPushData)
        self.delayPushData = nil
    end
    
    -- 告知管理器此轮数据已经接收完毕
    PrisonMgr:setPushFinished()
    
    DlgMgr:closeDlg("WaitDlg")
end

function PrisonDlg:refreshLayout()
    if not self.listView then
        return
    end
    
    local items = self.listView:getItems()
    for k, panel in pairs(items) do
        if k % 2 == 1 then
            self:setCtrlVisible("BackImage_2", true, panel)
            self:setCtrlVisible("BackImage_1", false, panel)
        else
            self:setCtrlVisible("BackImage_1", true, panel)
            self:setCtrlVisible("BackImage_2", false, panel)
        end
    end
        
end

-- 保释成功通知更新列表
function PrisonDlg:MSG_RELEASE_SUCC(data)
    local gid = data.gid
    if not self.panelList[gid] then
        return
    end
    
    -- 将已被保释的项从列表中删除
    self.listView:removeItem(self.listView:getIndex(self.panelList[gid]))
    self.listView:requestDoLayout()
    self.listView:requestRefreshView()
    self:refreshLayout()
    
    -- 从panelList中清除数据
    self.panelList[gid] = nil
    
    -- 从prisonerInfo中清除数据
    for i = #self.prisonerInfo, 1, -1 do
        if self.prisonerInfo[i].gid == data.gid then
            table.remove(self.prisonerInfo, i)
        end
    end
    
    self.start = self.start - 1
end

function PrisonDlg:pushData(prisonerList)
    if #self.prisonerInfo == 0 then
        gf:ShowSmallTips(CHS[7000066])
        return
    end
    
    if not prisonerList then
        prisonerList = PrisonMgr:getPrisonerList(1, PER_PAGE_COUNT, self.prisonerInfo)
        if not prisonerList then
            return
        end
    end
    
    self.start = self.start + #prisonerList
    
    local prisonerListView = self.listView   
    local innerContainer = prisonerListView:getInnerContainerSize()
    innerContainer.height = self.start * PANEL_HEIGHT
    prisonerListView:setInnerContainerSize(innerContainer)
    
    for i = 1, #prisonerList do
        local prisonerPanel = self.prisonerPanel:clone()
        --self:setCtrlVisible("ChosenEffectImage", false, prisonerPanel)
        
        local prisoner = prisonerList[i]   
        if self.start == 1 + #prisonerList and i == 1 then
            self.curPrisoner = prisoner
        end
        
        self:setLabelText("NameLabel", gf:getRealName(prisoner.name), prisonerPanel)
        self:setLabelText("LevelLabel", prisoner.level, prisonerPanel)
        self:setLabelText("FamilyLabel", gf:getPolar(prisoner.polar), prisonerPanel)
        local distName, serverId = DistMgr:getServerShowName(prisoner.server_name)
        self:setLabelText("LineLabel", string.format(CHS[7000119], serverId), prisonerPanel)
        
        local lastTime = prisoner.last_ti
        local timeStr = ""
        local hours = math.floor(lastTime / 3600)
        local minutes = math.floor((lastTime % 3600) / 60)
        timeStr = timeStr .. tostring(hours) .. CHS[3003115]
        timeStr = timeStr .. tostring(minutes) .. CHS[3003116]
        self:setLabelText("TimesLabel", timeStr, prisonerPanel)
        
        local prisonerIndex = self.start - #prisonerList + i - 1
        if prisonerIndex % 2 == 0 then
            self:setCtrlVisible("BackImage_2", true, prisonerPanel)
            self:setCtrlVisible("BackImage_1", false, prisonerPanel)
        else
            self:setCtrlVisible("BackImage_1", true, prisonerPanel)
            self:setCtrlVisible("BackImage_2", false, prisonerPanel)
        end
        
        -- 每添加一个panel，将其记录在panelList列表中，以gid为键
        self.panelList[prisoner.gid] = prisonerPanel
        
        self:bindTouchEndEventListener(prisonerPanel, self.choosePrisoner, prisoner)
        prisonerListView:pushBackCustomItem(prisonerPanel)
    end
    
    self:choosePrisoner(self.panelList[self.curPrisoner.gid], ccui.TouchEventType.ended, self.curPrisoner)
    prisonerListView:requestRefreshView()
end

function PrisonDlg:choosePrisoner(sender, eventType, prisoner)

    local prisonerListView = self:getControl("PrisonMemberListView")
    -- 找上一个选择项，取消选择效果
    local lastPanel 
    if self.curPrisoner then
        lastPanel = self.panelList[self.curPrisoner.gid]
    end
    
    if lastPanel ~= nil then
        self:setCtrlVisible("ChosenEffectImage", false, lastPanel)
    end

    -- 设置当前选择项的选择效果
    local panel = sender
    self:setCtrlVisible("ChosenEffectImage", true, panel)

    self.curPrisoner = prisoner
end

function PrisonDlg:onSearchButton()
    local name = self.nameEdit:getText()
    if name == "" then
        gf:ShowSmallTips(CHS[7000074])
        return
    end
    
    local tmp = {}
    for i = 1, #self.prisonerInfo do
        if gf:getShowId(self.prisonerInfo[i].gid) == name or self.prisonerInfo[i].name == name then
            table.insert(tmp, self.prisonerInfo[i])
        end
    end
    
    if #tmp == 0 then
        gf:ShowSmallTips(CHS[7000068])
    else
        -- 若搜索到结果，列表中仅显示此结果，搜索按钮变为清空按钮
        self.listView:removeAllChildren()
        self.start = 1
        self:pushData(tmp)        
        self:getControl("CleanButton"):setVisible(true)
        self:getControl("SearchButton"):setVisible(false)
    end

end

function PrisonDlg:onCleanButton()
    self:getControl("CleanButton"):setVisible(false)
    self:getControl("SearchButton"):setVisible(true)
    
    -- 重置输入框内容
    self.nameEdit:setText("")
    
    -- 重置囚犯列表数据
    self.listView:removeAllChildren()
    self.start = 1
    self:pushData()
end

function PrisonDlg:onIntercedeButton()

    -- 当前没有任何被关押的玩家
    if #self.prisonerInfo == 0 then
        gf:ShowSmallTips(CHS[7000067])
        return
    end
    
    gf:CmdToServer("CMD_ZUOLAO_PLEAD",
        {gid = self.curPrisoner.gid, name = self.curPrisoner.name})
end

function PrisonDlg:onBailButton()

    -- 当前没有任何被关押的玩家
    if #self.prisonerInfo == 0 then
        gf:ShowSmallTips(CHS[7000067])
        return
    end
    
    gf:CmdToServer("CMD_ZUOLAO_RELEASE",
        {gid = self.curPrisoner.gid, name = self.curPrisoner.name})
end

function PrisonDlg:cleanup()
    self:releaseCloneCtrl("prisonerPanel")
    self.curPrisoner = nil
    self.prisonerInfo = {}
    self.panelList = {}
    self.start = 1
end

return PrisonDlg
