-- TabDlg.lua
-- Created by cheny Jan/04/2015
-- 标签页对话框基类

local Group = require('ctrl/RadioGroup')
local TabDlg = Singleton("TabDlg", Dialog)

-- 按钮名称与对话框名称的映射表
TabDlg.dlgs = { }

-- 子 Tab 对话框默认要打开的对话框，如果包含子 Tab 对话框则需要配置该内容，例如：EquipmentTabDlg
TabDlg.subTabDlgs = { }

-- 外层 Tab 对话框，如果是子 Tab 对话框则需要配置该内容，例如：EquipmentRefiningTabDlg
TabDlg.outerTabDlg = nil

-- 排序队列，如果需要进行排序则，需要配置这个东西
TabDlg.orderList = nil

function TabDlg:init()
    self.allRadio = {}
    for radio, dlgName in pairs(self.dlgs) do
        -- 过滤下,如果标签未开启，则跳过
        if GuideMgr:isTabVisible(radio) then
            table.insert(self.allRadio, radio)
        else
            self:setCtrlVisible(radio, false)
        end
    end

    self.group = Group.new()
    self.group:setItems(self, self.allRadio, self.onSelected)

    if self.orderList then
        self:refreshView(self.allRadio)
    end
end

function TabDlg:refreshView(radios)
    if nil == self.orderList then return end

    local allRadio = gf:deepCopy(radios)

    -- 进行计算tab个数，重新排序计算位置
    local tabCount = #allRadio

    -- 对控件进行排序
    table.sort(allRadio, function(l, r)
        if self.orderList[l] < self.orderList[r] then
            return true
        end

        return false
    end)

    -- 找到第一个标签的位置
    local firstTabCtrl = self:getControl(allRadio[1])
    local maxY = self:getTopTabPosY()
    if not firstTabCtrl then
        return
    end

    firstTabCtrl:setPositionY(maxY)

    -- 剔出第一个标签
    allRadio[1] = nil
    local contentSize = firstTabCtrl:getContentSize()

    -- 将剩余的标签进行对第一个标签的相对位置
    local curIndex = 1
    for i = 1, tabCount do
        if allRadio[i] then
            -- 如果标签存在
            local ctrl = self:getControl(allRadio[i])
            local curY = maxY - (contentSize.height + (self.tabMargin or 0)) * curIndex
            ctrl:setPositionY(curY)
            curIndex = curIndex + 1
        end
    end
end


-- 获取所有已开启的标签列表第一个对话的名字 addby zhengjh
function TabDlg:getFirtTabList()
    local dlgName
    local radios = {}
     for radio, dlgName in pairs(self.dlgs) do
        -- 过滤下,如果标签未开启，则跳过
        if GuideMgr:isTabVisible(radio) then
            table.insert(radios, radio)
        end
     end

    if self.orderList then
        table.sort(radios, function(l, r)
            if self.orderList[l] < self.orderList[r] then
                return true
            end

            return false
        end)
    end

    return  self.dlgs[radios[1]]
end

function TabDlg:getTopTabPosY()
    local topY = 0
    for radio, dlgName in pairs(self.dlgs) do
        -- 过滤下,如果标签未开启，则跳过
        local ctrl = self:getControl(radio)
        if topY < ctrl:getPositionY() then
            topY = ctrl:getPositionY()
        end
    end

    return topY
end

-- 是否为标签页界面
function TabDlg:isTabDlg()
    return true
end

-- 设置要选中的界面
function TabDlg:setSelectDlg(dlgName, notCheckPreCallBack)
    for i = 1, #self.allRadio do
        local dlgOrSubTabDlg = self.dlgs[self.allRadio[i]]
        if dlgOrSubTabDlg == dlgName or self:isInSubTabDlgs(dlgOrSubTabDlg, dlgName) then
            self.group:selectRadio(i, true)
            self.lastDlg = dlgOrSubTabDlg

            local ctl = self:getControl(self.allRadio[i])
            self:onSelected(ctl, nil, nil, notCheckPreCallBack)
            return
        end
    end

    -- 选中开启的最上面一个选项
    if self.allRadio[1] then
        self.group:selectRadio(1, true)
        local ctl = self:getControl(self.allRadio[1])
        self:onSelected(ctl, nil, nil, notCheckPreCallBack)
    end
end

-- 判断dlg是否在子tab可以选择的界面中
function TabDlg:isInSubTabDlgs(subTabDlgName, dlgName)
    local subDlgs = self.subTabDlgs[subTabDlgName]
    if subDlgs then
        for i = 1, #subDlgs do
            if subDlgs[i] == dlgName then
                return true
            end
        end
    end

    return false
end

-- 获取子tab默认选择的界面
function TabDlg:getSubTabDefaultDlg(subTabDlgName)
    local subDlgs = self.subTabDlgs[subTabDlgName]
    if subDlgs then
        return subDlgs[1]
    end
end

function TabDlg:onSelected(sender, idx, isRedDot, notCheckPreCallBack)
    if not notCheckPreCallBack and self.onPreCallBack then
        if not self.onPreCallBack(self, sender, idx) then
            -- 恢复点击到原先的CheckBox
            self:setSelectDlg(self.lastDlg, true)
            return
        end
    end

    -- 打开对应的对话框
    local ctrlName = sender:getName()
    local dlgName = self.dlgs[ctrlName]

    -- 已打开 tab 的情况下，直接 open 有小红点的标签对应的界面，会导致标签选中且小红点未移除
    RedDotMgr:removeOneRedDot(self.name, ctrlName)

    -- 切换标签并且显示选中文字和非选中的文字
    for k , v  in pairs(self.dlgs) do
        local sender = self:getControl(k)
        if dlgName == v then
            self:setCtrlVisible("ChosenLabel_1", true, sender)
            self:setCtrlVisible("ChosenLabel_2", true, sender)
            self:setCtrlVisible("UnChosenLabel_1", false, sender)
            self:setCtrlVisible("UnChosenLabel_2", false, sender)

            self:setCtrlVisible("ChosenPanel", true, sender)
            self:setCtrlVisible("UnChosenPanel", false, sender)
        else
            self:setCtrlVisible("ChosenLabel_1", false, sender)
            self:setCtrlVisible("ChosenLabel_2", false, sender)
            self:setCtrlVisible("UnChosenLabel_1", true, sender)
            self:setCtrlVisible("UnChosenLabel_2", true, sender)

            self:setCtrlVisible("ChosenPanel", false, sender)
            self:setCtrlVisible("UnChosenPanel", true, sender)
        end
    end

    if dlgName == self.lastDlg then return end
    -- 关闭当前显示的对话框
    self:closeCurShowDlg()

    local subDefaultDlg = self:getSubTabDefaultDlg(dlgName)
    if subDefaultDlg then
        -- 是子 Tab 界面，获取其上一次打开的界面
        self.lastDlg = dlgName
        dlgName = DlgMgr:getLastDlgByTabDlg(dlgName) or subDefaultDlg
        DlgMgr:openDlg(dlgName)
        return
    end

    if dlgName == "" then return end
    DlgMgr:openDlg(dlgName)
    self.lastDlg = dlgName

    -- 移出小红点
    self:removeRedDot(sender)

    if self.onCallBack then
        self.onCallBack(self, sender, idx)
    end
end

-- 设置点击回调函数
function TabDlg:setCallBack(func)
    if "function" == type(func) then
        self.onCallBack = func
    end
end

-- 设置点击之前的回调
function TabDlg:setPreCallBack(func)
    if "function" == type(func) then
        self.onPreCallBack = func
    end
end

-- 关闭当前显示的对话框
function TabDlg:closeCurShowDlg()
    for radio, dlgName in pairs(self.dlgs) do
        if DlgMgr:isDlgOpened(dlgName) then
            local dlg = DlgMgr:getDlgByName(dlgName)
            if dlg:isTabDlg() then
                -- 是子 Tab 对话框，需要关闭该 Tab 显示的对话框
                DlgMgr:closeDlg(dlg.lastDlg, nil, true)
            end

            DlgMgr:closeDlg(dlgName, self.getIgnoreDlgWhenCloseCurShowDlg and self:getIgnoreDlgWhenCloseCurShowDlg() or self.name, true)
        end
    end
end

function TabDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
    self:closeCurShowDlg()
end

-- 获取当前选中
function TabDlg:getCurSelect()
    for radio, dlgName in pairs(self.dlgs) do
        if self:isCheck(radio) then
            return dlgName
        end
    end
end

--获取当前选中控件名字
function TabDlg:getCurSelectCtrlName()
    for radio, dlgName in pairs(self.dlgs) do
        if self:isCheck(radio) then
            return radio
        end
    end
end

-- 如果需要获取某个tabdlg要打开界面，要重载该函数
function TabDlg:getOpenDefaultDlg()
    return self.lastDlg or DlgMgr:getLastDlgByTabDlg(self.name)
end

-- 关闭当前显示的对话框
function TabDlg:closeRadioDlgExclude(name)
    local selectDlgName = self:getCurSelect()

    for radio, dlgName in pairs(self.dlgs) do
        if dlgName ~= selectDlgName then
            DlgMgr:closeThisDlgOnly(dlgName)
        end
    end
end

return TabDlg
