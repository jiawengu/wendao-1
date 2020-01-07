-- DossierDlg.lua
-- Created by lixh May/25/2018
-- 探案-探案卷宗界面

local DossierDlg = Singleton("DossierDlg", Dialog)

-- ListView子控件名称
local SUB_PANEL_NAME = "JUAN"

-- 提示颜色
local TIPS_COLOR = cc.c3b(168, 133, 94)

local TITLE_IMAGE_RES = {
    [CHS[4101149]] = ResMgr.ui.tanan_bjfy,    -- 【探案】镖局风云
}

-- 证物道具配置
local EVIDENCE_CFG = {num = 10, emptyPath = ResMgr.ui.bag_no_item_bg_img, itemPath = ResMgr.ui.bag_item_bg_img}

-- 迷仙镇案线索列表偏移
local MXZA_LIST_VIEW_OFFSETY = 38

function DossierDlg:init()
    self:bindListViewListener("ClueListView", self.onSelectClueListView)
    self.orgTipsPos = cc.p(self:getControl("PromptTextPanel", Const.UIPanel, "SingleCluePanel"):getPosition())
    self.itemCtrl = self:retainCtrl("SingleCluePanel")

    self:refreshTitle()

    self:bindFloatPanelListener("MXZRulePanel")
end

-- 刷新界面标题: 不同探案任务自己在这里处理
function DossierDlg:refreshTitle()
    local image = self:getControl("NameImage", Const.UIImage, "TitlePanel1")
    if TaskMgr:getTaskByName(CHS[7190256]) then
        image:loadTexture(ResMgr.ui.tanan_jhll_dossier_title)
    elseif TaskMgr:getTaskByName(CHS[5400611]) then
        image:loadTexture(ResMgr.ui.tanan_tw_dossier_title)
    elseif TaskMgr:getTaskByName(CHS[7190287]) then
        image:loadTexture(ResMgr.ui.tanan_mxza_dossier_title)
    end
end

-- 刷新界面
function DossierDlg:setData(data)
    if not data then return end

    self.data = data

    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("MXZAMainPanel", false)

    local isInMxzaTask = TaskMgr:getTaskByName(CHS[7190287])
    self.mainPanel = nil
    if isInMxzaTask then
        self.mainPanel = self:getControl("MXZAMainPanel")
        self:initMxzaItem()
    else
        self.mainPanel = self:getControl("MainPanel")
    end

    self.mainPanel:setVisible(true)
    local progressPanel = self:getControl("ProgressPanel", nil, self.mainPanel)
    if isInMxzaTask then
        -- 迷仙镇案不显示进度条，显示线索条数
        self:setLabelText("TextLabel", string.format(CHS[7190294], data.count), progressPanel)
        self:bindListener("InfoButton", self.onMxInfoButton, progressPanel)
    else
        -- 进度条
        if data.percent >= 0 then
            progressPanel:setVisible(true)
            self:setProgressBar("ConsumeProgressBar", data.percent, 100, progressPanel)
            self:setLabelText("NumLabel", data.percent .. "%", progressPanel)
        else
            progressPanel:setVisible(false)
        end
    end

    -- 停止倒计时
    self:clearSchedule()

    -- 倒计时结束请求数据，则只刷新对应任务的提示
    if self.showLeftInfo and self.showLeftPanel and data.list[self.showLeftInfo.index] then
        self.showLeftPanel:setPosition(self.orgTipsPos)
        self:setColorText(string.format(CHS[7190239], data.list[self.showLeftInfo.index].tips), self.showLeftPanel, nil, nil, nil, COLOR3.TIPS_COLOR, 17, false, true)
        self.showLeftInfo = nil
        self.showLeftPanel = nil
        return
    end

    local listView = self:resetListView("ClueListView", 10, nil, self.mainPanel)
    for i = 1, data.count do
        local singleInfo = data.list[i]
        if not singleInfo then return end

        local item = self:setSingleItem(self.itemCtrl:clone(), singleInfo, i == data.count)
        item:setName(SUB_PANEL_NAME .. i)
        listView:pushBackCustomItem(item)
    end

    if data.hasNext then
        -- 如果还有下一条线索，再增加一条未开启线索
        local nextInfo = {}
        nextInfo.index = data.count + 1
        nextInfo.des = CHS[7190240]
        nextInfo.tips = CHS[7190241]
        if TaskMgr:getTaskByName(CHS[7190287]) then
            -- 迷仙镇案特殊处理
            nextInfo.tips = CHS[7100363]
        end

        nextInfo.showLeftTime = 0
        local item = self:setSingleItem(self.itemCtrl:clone(), nextInfo)

        -- 未开启线索不显示备注
        self:setCtrlVisible("RemarksButton", false, item)
        listView:pushBackCustomItem(item)
    end

    listView:refreshView()

    self:setListInnerPosByIndex("ClueListView", data.hasNext and (data.count + 1) or data.count, self.mainPanel)
    if isInMxzaTask then
        local innerContainer = self:getControl("ClueListView", nil, self.mainPanel):getInnerContainer()
        innerContainer:setPositionY(innerContainer:getPositionY() - MXZA_LIST_VIEW_OFFSETY)
    end

    -- 开启定时器，线索倒计时
    self:startSchedule()

    -- 标题
    if TITLE_IMAGE_RES[data.taskName] then
        self:setImage("NameImage", ResMgr.ui.tanan_bjfy, "TitlePanel1")
    else
        -- 显示json默认的即可，不处理
    end
end

function DossierDlg:setSingleItem(panel, info, isLast)
    self:setLabelText("TitleLabel", string.format(CHS[7190238], gf:numberToChs(info.index)), panel)
    self:setColorText(string.format(CHS[7190243], info.des), "ClueTextPanel", panel, nil, nil, COLOR3.ORANGE, 19, false, true)
    if info.showLeftTime and info.showLeftTime > 0 then
        local tips = gf:getServerDate(CHS[7190242], info.showLeftTime)
        self:setColorText(string.format(CHS[7190239], tips), "PromptTextPanel", panel, nil, nil, COLOR3.TIPS_COLOR, 17, false, true)
    else
        self:setColorText(string.format(CHS[7190239], info.tips), "PromptTextPanel", panel, nil, nil, COLOR3.TIPS_COLOR, 17, false, true)
    end

    local remarkButton = self:getControl("RemarksButton", Const.UIButton, panel)
    remarkButton.info = info
    self:bindTouchEndEventListener(remarkButton, self.onRemarkButton)

    panel.info = info
    return panel
end

-- 刷新备注
function DossierDlg:refreshRemarks(index, text)
    if not self.data or not self.data.list[index] then return end
    self.data.list[index].remarks = text

    local innarContainer = self:getControl("ClueListView", nil, self.mainPanel):getInnerContainer()
    local remarksButton = self:getControl("RemarksButton", Const.UIButton, innarContainer:getChildByName(SUB_PANEL_NAME .. index))
    if remarksButton then
        remarksButton.info = self.data.list[index]
    end
end

function DossierDlg:onRemarkButton(sender, eventType)
    local info = sender.info
    if not info or not self.data then return end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("DossierTipsDlg")
    info.taskName = self.data.taskName
    dlg:setData(info)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function DossierDlg:onSelectClueListView(sender, eventType)
end

function DossierDlg:startSchedule()
    if self.scheduleId then return end
    self.scheduleId = gf:Schedule(function()
        local listView = self:getControl("ClueListView", nil, self.mainPanel)
        local items = listView:getItems()
        for i = 1, #items do
            local item = items[i]
            if item and item.info and item.info.showLeftTime > 0 then
                item.info.showLeftTime = item.info.showLeftTime - 1
                local tips = gf:getServerDate(CHS[7190242], item.info.showLeftTime)
                local leftPanel = self:getControl("PromptTextPanel", Const.UIPanel, item)
                self:setColorText(string.format(CHS[7190239], tips), leftPanel, nil, nil, nil, COLOR3.TIPS_COLOR, 17, false, true)

                if item.info.showLeftTime <= 0 then
                    local task = TaskMgr:getTaskByShowName(CHS[7190224])
                    if not task then return end

                    gf:CmdToServer("CMD_DETECTIVE_TASK_CLUE", {taskName = task.task_type})
                    self.showLeftInfo = item.info
                    self.showLeftPanel = leftPanel
                end
            end
        end
    end, 1)
end

function DossierDlg:clearSchedule()
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId  = nil
    end
end

function DossierDlg:cleanup()
    self:clearSchedule()
    self.showLeftInfo = nil
    self.showLeftPanel = nil
    self.data = nil
end

-- 初始化迷仙镇案道具
function DossierDlg:initMxzaItem()
    local root = self:getControl("EvidencePanel", nil, "MXZAMainPanel")
    local items = TanAnMgr:getEvidenceItems()
    local lenth = #items
    self:setCtrlVisible("NextButton", lenth > EVIDENCE_CFG.num, root)
    self:bindListener("NextButton", self.onNextEvidenceItem, root)
    self:setMxzaItemList(1)
    for i = 1, EVIDENCE_CFG.num do
        local panel = self:getControl("ItemShapePanel" .. i, nil, root)
        self:bindListener("ItemImage", self.onMxzaItem, panel)
    end
end

-- 设置迷仙镇案道具列表
function DossierDlg:setMxzaItemList(startIndex)
    local root = self:getControl("EvidencePanel", nil, "MXZAMainPanel")
    local items = TanAnMgr:getEvidenceItems()
    local lenth = #items
    for i = 1, EVIDENCE_CFG.num do
        local itemRoot = self:getControl("ItemShapePanel" .. i, nil, root)
        local img = self:getControl("ItemImage", nil, itemRoot)
        img:setVisible(false)
        local itemIndex = i + startIndex - 1
        if items[itemIndex] then
            itemRoot:setBackGroundImage(EVIDENCE_CFG.itemPath, ccui.TextureResType.plistType)
            img:setVisible(true)
            img:loadTexture(ResMgr:getIconPathByName(items[itemIndex].name))
            img.item = items[itemIndex]
        else
            itemRoot:setBackGroundImage(EVIDENCE_CFG.emptyPath, ccui.TextureResType.plistType)
            img.item = nil
        end
    end
    
    self:getControl("NextButton", nil, root).startIndex = startIndex
end

function DossierDlg:onMxzaItem(sender, eventType)
    local item = sender.item
    if not item then return end
    local dlg = InventoryMgr:showBasicMessageByItem(item, self:getBoundingBoxInWorldSpace(sender))
    if dlg then
        -- 只显示一个水平居中的使用按钮
        dlg:setShowButtons({use = true, more = false})
        dlg:setCtrlVisible("ResourceButton", false)
        dlg:getControl("ApplyButton"):getLayoutParameter():setAlign(ccui.RelativeAlign.alignParentBottomCenterHorizontal)
    end
end

function DossierDlg:onNextEvidenceItem(sender, eventType)
    local items = TanAnMgr:getEvidenceItems()
    local lenth = #items
    local nextIndex = sender.startIndex + EVIDENCE_CFG.num
    if nextIndex <= lenth then
        -- 下一页
        self:setMxzaItemList(nextIndex)
    else
        -- 回到第一页
        self:setMxzaItemList(1)
    end
end

function DossierDlg:onMxInfoButton(sender, eventType)
    self:setCtrlVisible("MXZRulePanel", true)
end

return DossierDlg
