-- FightRecordDlg.lua
-- Created by lixh Aug/16/2018
-- 战斗记录界面

local FightRecordDlg = Singleton("FightRecordDlg", Dialog)

-- 信息类型
local INFO_TYPE = FightCmdRecordMgr:getShowInfoType()

-- 战斗记录最大显示条数
local MAX_RECORD_SHOW_NUM = 50

-- 单次滑动加载战斗记录条数
local PAGE_ADD_RECORD_NUM = 10

-- ListView 单页最多显示数量
local PAGE_MAX_RECORD_NUM = 12

function FightRecordDlg:init()
    self:bindListViewListener("ListView", self.onSelectListView)
    self:bindListener("SwitchCheckBox", self.onCheckBox)

    self:setCheck("SwitchCheckBox", FightCmdRecordMgr:getFightCmdMagicFlag())

    self.listView = self:getControl("ListView")

    self.itemPanel = self:retainCtrl("FightPanel")
    
    self:bindTouchPanel()

    self:initData()
end

-- 初始化listView界面内容
function FightRecordDlg:initData()
    self.listView = self:resetListView("ListView")

    -- 战斗记录的Panel大小比较特殊，ListView不勾选裁剪才能显示完整，ListView父控件已勾选裁剪
    self.listView:setClippingEnabled(false)
    local data = FightCmdRecordMgr:getRecordShowInfo()
    self.startIndex = math.max(1, #data - MAX_RECORD_SHOW_NUM + 1)
    for i = self.startIndex, #data do
        local item = self:setSingleItem(self.itemPanel:clone(), data[i])
        self.listView:pushBackCustomItem(item)
    end

    self.listView:refreshView()
    self.listView:jumpToBottom()
end

-- 增加listView内容
function FightRecordDlg:addData(data)
    if not data then return end
    local needJumpToBottom = self:getCurScrollPercent("ListView", true) == 100
        or #self.listView:getItems() <= PAGE_MAX_RECORD_NUM
    local item = self:setSingleItem(self.itemPanel:clone(), data)
    self.listView:pushBackCustomItem(item)

    self.listView:refreshView()
    self:adjustRecordCount()

    if needJumpToBottom then
        self.listView:jumpToBottom()
    end
end

-- 检查当前ListView中战斗记录显示的条数数量
function FightRecordDlg:adjustRecordCount()
    local items = self.listView:getItems()
    local notShowCount = #items - MAX_RECORD_SHOW_NUM
    if notShowCount <= 0 then return end
    for i = 1, notShowCount do
        self.listView:removeItem(0)

        -- 战斗记录起始下标往后移
        self.startIndex = self.startIndex + 1
    end

    self.listView:refreshView()
end

-- 设置控件内容
function FightRecordDlg:setSingleItem(panel, data)
    local function onInfoPanel(sender, eventType)
        if eventType ~= ccui.TouchEventType.ended then return end
        local rect = {
            x = GameMgr.curTouchPos.x,
            y = GameMgr.curTouchPos.y,
            width = 5,
            height = 5,
        }

        if sender.type == INFO_TYPE.ITEM then
            InventoryMgr:showBasicMessageDlg(sender.name, rect)
        elseif sender.type == INFO_TYPE.SKILL then
            local skillName = sender.name
            if not skillName then return end
            local skillAttrib = SkillMgr:getskillAttribByName(skillName)

            -- 一些怪物技能：雷霆万钧，妖皇天怒，没有技能图标，暂时不用展示
            if not skillAttrib or not skillAttrib.skill_icon then return end

            local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
            dlg:setInfo(skillName, 1, false, rect, nil, nil, true)
        end 
    end

    local infoPanel = self:getControl("InfoPanel", Const.UIPanel, panel)
    local panelHeight, _ = self:setColorText(data.str, infoPanel, nil, 0, 0, COLOR3.TEXT_DEFAULT, 80, nil, true)
    infoPanel:setScale(0.25)
    local sz = infoPanel:getContentSize()
    sz = cc.size(sz.width * 0.25, sz.height * 0.25)
    infoPanel:setContentSize(sz)
    panel:setContentSize(panel:getContentSize().width, sz.height)
    panel:requestDoLayout()

    if data.type == INFO_TYPE.ITEM or data.type == INFO_TYPE.SKILL then
        panel:addTouchEventListener(onInfoPanel)
        panel.name = data.action
        panel.type = data.type
    end

    return panel
end

function FightRecordDlg:onCheckBox(sender, eventType)
    local state = sender:getSelectedState()
    FightCmdRecordMgr:setFightCmdMagicFlag(state)
    if state then
        gf:ShowSmallTips(CHS[7100390])
    else
        gf:ShowSmallTips(CHS[7100391])
    end
end

function FightRecordDlg:onSelectListView(sender, eventType)
end

function FightRecordDlg:bindTouchPanel()
    local panel = self:getControl("TouchPanel")
    local function onTouchBegan(touch, event)
        local touchPos = touch:getLocation()
        touchPos = panel:getParent():convertToNodeSpace(touchPos)

        local box = panel:getBoundingBox()
        if nil == box then return false end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchEnd(touch, event)
        local touchPos = touch:getLocation()
        local box = panel:getBoundingBox()
        if nil == box then return false end

        local percent = self:getCurScrollPercent("ListView", true)
        Log:D("The percent is %d%%", percent)

        if percent <= 0 then
            if self.startIndex <= 1 then return end

            -- 向前加载战斗记录
            local data = FightCmdRecordMgr:getRecordShowInfo()
            local refreshed = false
            local lastIndex = self.startIndex - 1
            local needAddCount = (lastIndex - PAGE_ADD_RECORD_NUM) >= 0 and PAGE_ADD_RECORD_NUM or lastIndex
            self.startIndex = self.startIndex - needAddCount
            for i = lastIndex, lastIndex - needAddCount + 1, -1 do
                if data[i] then
                    local item = self:setSingleItem(self.itemPanel:clone(), data[i])
                    self.listView:insertCustomItem(item, 0)
                    refreshed = true
                end
            end

            if refreshed then
                self.listView:refreshView()
            end
        end
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

return FightRecordDlg
