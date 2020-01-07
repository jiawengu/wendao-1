-- BridgeTaskDlg.lua
-- Created by huangzz Nov/24/2017
-- 水岚之缘剧情剧情界面

local BridgeTaskDlg = Singleton("BridgeTaskDlg", Dialog)

local STORY_INFO = {  -- 剧情简介
    [1] = {desc = CHS[5410185], numIcon = ResMgr.ui.shuilan_no1, yingIcon = ResMgr.ui.shuilan_jiangying1, offPos = cc.p(0, -40), icon = 51526,},
    [2] = {desc = CHS[5410186], numIcon = ResMgr.ui.shuilan_no2, yingIcon = ResMgr.ui.shuilan_jiangying2, offPos = cc.p(0, -25), icon = 06177,},
    [3] = {desc = CHS[5410187], numIcon = ResMgr.ui.shuilan_no3, yingIcon = ResMgr.ui.shuilan_jiangying3, offPos = cc.p(0, -40), },
    [4] = {desc = CHS[5410188], numIcon = ResMgr.ui.shuilan_no4, yingIcon = ResMgr.ui.shuilan_jiangying4, offPos = cc.p(0, -40), icon = 06011,},
    [5] = {desc = CHS[5410189], numIcon = ResMgr.ui.shuilan_no5, yingIcon = ResMgr.ui.shuilan_jiangying5, offPos = cc.p(0, -40), icon = 06213,},
    [6] = {desc = CHS[5410190], numIcon = ResMgr.ui.shuilan_no6, yingIcon = ResMgr.ui.shuilan_jiangying6, offPos = cc.p(0, -46), icon = 51525,},
    [7] = {desc = CHS[5410191], numIcon = ResMgr.ui.shuilan_no7, yingIcon = ResMgr.ui.shuilan_jiangying7, offPos = cc.p(0, -40), icon = 870703,  org_icon = 07003, weapon_icon = 01130},
    [8] = {desc = CHS[5410192], numIcon = ResMgr.ui.shuilan_no8, yingIcon = ResMgr.ui.shuilan_jiangying8, offPos = cc.p(0, -46), icon = 51527,}
}

local CELL_SPACE = 18

function BridgeTaskDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    self.oneTaskPanel = self:retainCtrl("OneTaskPanel")
    
    self.listView = self:getControl("ListView")
    
    self:bindListView()
    
    gf:CmdToServer("CMD_TASK_SHUILZY_DIALOG", {})
    
    self:hookMsg("MSG_TASK_SHUILZY_DIALOG")
    
    self.selectNum = 1
end

function BridgeTaskDlg:bindListView()
    local function onScrollView(sender, eventType)
        if ccui.ScrollviewEventType.scrolling == eventType 
            or ccui.ScrollviewEventType.scrollToLeft == eventType 
            or ccui.ScrollviewEventType.scrollToRight == eventType then
            -- 获取控件
            local listInnerContent = sender:getInnerContainer()
            local innerSize = listInnerContent:getContentSize()
            local scrollViewSize = sender:getContentSize()

            -- 计算滚动的百分比
            local totalWidth = innerSize.width - scrollViewSize.width
            local innerPosX = listInnerContent:getPositionX()
            local persent = (-innerPosX) / totalWidth
            persent = math.floor(persent * 100)

            self:setCtrlVisible("LeftButton", persent > 2)
            self:setCtrlVisible("RightButton", persent < 98)
        end
    end
    
    self:setCtrlVisible("LeftButton", false)
    self:setCtrlVisible("RightButton", true)
    self.listView:addScrollViewEventListener(onScrollView)
end

function BridgeTaskDlg:initListView(data)
    local listView = self.listView
    listView:setItemsMargin(CELL_SPACE)
    for i = 1, 8 do
        local cell = self.oneTaskPanel:clone()
        self:setOneTask(data[i], cell, i)
        listView:pushBackCustomItem(cell)
    end
     
    self.listView:doLayout()

    -- 将当前正在做的任务显示在中间
    local toNum = math.min(math.max(self.selectNum - 2, 0), 5)
    local posX = toNum * (self.oneTaskPanel:getContentSize().width + CELL_SPACE)
    local listInnerContent = self.listView:getInnerContainer()
    local innerSize = listInnerContent:getContentSize()
    local scrollViewSize = self.listView:getContentSize()
    local totalWidth = innerSize.width - scrollViewSize.width

    listInnerContent:setPositionX(math.max(-posX, -totalWidth))
    self:setCtrlVisible("LeftButton", posX > 10)
    self:setCtrlVisible("RightButton", posX - totalWidth < -10)
end

function BridgeTaskDlg:setOneTask(data, cell, num)
    -- 序号
    self:setImage("NumImage", STORY_INFO[num].numIcon, cell)
    
    -- 任务名
    self:setLabelText("NameLabel", string.match(data.task_name, CHS[5410179] .. "(.+)"), cell)
    
    local curTime = gf:getServerTime()
    local task = TaskMgr:getTaskByShowName(data["task_name"])
    if Me:queryBasicInt("level") >= data.level
        and curTime >= data.start_time
        and (data.status == 1 or (data.status == 0 and task)) then
        -- 已开启
        self:setCtrlVisible("ConditionPanel", false, cell)
        self:setCtrlVisible("StoryPanel", true, cell)
        self:setCtrlVisible("UpBKImage", false, cell)
        local ctrl = self:getControl("ModelPanel", nil, cell)
        ctrl:removeBackGroundImage()
        
        -- 形象
        if num == 3 then
            local icon = Me:queryBasicInt("suit_icon")
            if icon == 0 then
                icon = Me:queryBasicInt("icon")
            end
            
            local wIcon = Me:queryBasicInt('weapon_icon')
            if wIcon == 0 then
                -- 变身情况下获取不到武器，从包裹中获取装备的武器道具
                local item = InventoryMgr:getItemsByPosArray({EQUIP.WEAPON})
                if item[1] then
                    wIcon = tonumber(string.match(item[1].imgFile, ".*/(.+)_50"))
                end
            end
        
            self:setPortrait("ModelPanel", icon, wIcon, cell, false, nil, nil, cc.p(0, -36), Me:queryBasicInt("org_icon"))
        else
            local char = self:setPortrait("ModelPanel", STORY_INFO[num].icon, STORY_INFO[num].weapon_icon, cell, false, nil, nil, STORY_INFO[num].offPos, STORY_INFO[num].org_icon)
        end
        
        -- 简介
        local storyPanel= self:getControl("StoryPanel", nil, cell)
        self:setLabelText("TextLabel", STORY_INFO[num].desc, storyPanel)
        
        if data.status == 1 then
            self:setLabelText("NoneLabel", CHS[4300000], cell)
        end
        
        -- 前往
        if task then
            self:setCtrlVisible("ConfirmButton", true, cell)
        else
            self:setCtrlVisible("ConfirmButton", false, cell)
        end
    else
        --未开启
        self:setCtrlVisible("ConditionPanel", true, cell)
        self:setCtrlVisible("StoryPanel", false, cell)
        self:setCtrlVisible("ConfirmButton", false, cell)
        self:setCtrlVisible("UpBKImage", true, cell)
        
        local ctrl = self:getControl("ModelPanel", nil, cell)
        ctrl:setBackGroundImage(STORY_INFO[num].yingIcon, ccui.TextureResType.localType)
        
        -- 开启时间
        local color = COLOR3.WHITE
        if curTime < data.start_time then
            color = COLOR3.RED
        end
        
        local timePanel= self:getControl("TimePanel", nil, cell)
        self:setLabelText("NumLabel", gf:getServerDate(CHS[5410193], data.start_time), timePanel,color)
        
        -- 开启等级
        local color = COLOR3.WHITE
        if Me:queryBasicInt("level") < data.level then
            color = COLOR3.RED
        end
        
        -- 需先完成上一任务
        if Me:queryBasicInt("level") >= data.level
            and curTime >= data.start_time then
            self:setLabelText("NoneLabel", CHS[5410205], cell)
        end

        local levelPanel= self:getControl("LevelPanel", nil, cell)
        self:setLabelText("NumLabel", string.format(CHS[6000179], data.level), levelPanel, color)
    end
   
     
    if task then
        self.selectNum = num
    end

    cell.data = data
end

function BridgeTaskDlg:onConfirmButton(sender, eventType)
    local cell = sender:getParent()
    if cell.data then
        local task = TaskMgr:getTaskByName(cell.data["task_name"])
        if task then
            local textCtrl = CGAColorTextList:create()
            textCtrl:setString(task.task_prompt)
            gf:onCGAColorText(textCtrl, nil, {task_type = task.task_type, task_prompt = task.task_prompt})
        end
    end
    
    self:close()
end

function BridgeTaskDlg:MSG_TASK_SHUILZY_DIALOG(data)
    table.sort(data, function(l, r) 
        if l.level < r.level then return true end
    end)
    self:initListView(data)
end

return BridgeTaskDlg
