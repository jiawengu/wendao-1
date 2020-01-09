-- HomeSpaceDlg.lua
-- Created by sujl, Jun/12/2017
-- 居所空间分配界面

local HomeSpaceDlg = Singleton("HomeSpaceDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 居所类型对应名称
local HOME_TYPE = {
    -- 类型编号 = { 居所名称, 总空间 }
    [1] = { CHS[2000249],     12   },
    [2] = { CHS[2000250],     20   },
    [3] = { CHS[2000251],     30  },
}

-- 区域
local HOME_AREA = {
    -- key, 区域名称,家具描述,功能描述
    {"bed_room", CHS[2000252], CHS[2000253], CHS[2000254], {[1] = 2, [2] = 6, [3] = 12,}},      -- 卧室
    {"store_room", CHS[2000255], CHS[2000256], CHS[2000257], {[1] = 2, [2] = 6, [3] = 12,}},    -- 储物室
    {"practice_room", CHS[2000258], CHS[2000259], CHS[2000260], {[1] = 2, [2] = 6, [3] = 12,}}, -- 修炼室
    {"artifact_room", CHS[2000261], CHS[2000262], CHS[2000263], {[1] = 2, [2] = 6, [3] = 12,}},              -- 炼器室
         
}

-- 面板转空间类型
local PANEL_2_TYPE = {
    ["SmallChoosePanel"]    = 1,
    ["MiddleChoosePanel"]   = 2,
    ["LargeChoosePanel"]    = 3,
}

-- 初始化
function HomeSpaceDlg:init(args)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self.selects = {}
    self.radioGroups = {}

    -- 初始数据处理
    self.action = args.action
    self.curHomeType = self:getHomeTypeByName(args.cur_house)       -- 当前居所类型
    self.lastHomeType = self:getHomeTypeByName(args.last_house)
    self.price = args.price
    self.selects = args.selects

    if not self.selects or not next(self.selects) then
        -- 没有配置，先生成一份默认配置
        self.selects = {}
        for i = 1, #HOME_AREA do
            self.selects[HOME_AREA[i][1]] = 1
        end
    end

    -- 设置居所名称
    self:setLabelText("HomeNameLabel", HOME_TYPE[self.curHomeType][1], "SpaceProgressPanel")

    -- 缓存原始列表项
    self.panelItem = self:getControl("AreaPanel")
    self.panelItem:retain()
    self.panelItem:removeFromParent()

    -- 创建居所区域
    self:createItems()

    -- 刷新界面数据
    self:refreshData()

    self:hookMsg("MSG_GENERAL_NOTIFY")
end

-- 清理
function HomeSpaceDlg:cleanup()
    self:releaseCloneCtrl("panelItem")
    self.radioGroups = nil
end

-- 根据名称获取居所类型
function HomeSpaceDlg:getHomeTypeByName(name)
    if string.isNilOrEmpty(name) then return end
    for i = 1, #HOME_TYPE do
        if HOME_TYPE[i][1] == name then return i end
    end
end

-- 创建居所区域
function HomeSpaceDlg:createItems()
    local listView = self:resetListView("AreaListView")
    local item

    for i = 1, #HOME_AREA do
        item = self.panelItem:clone()
        item:setName(HOME_AREA[i][1])
        self:setLabelText("NameLabel", HOME_AREA[i][2], item)      -- 区域名称
        self:setLabelText("InfoLabel_2", HOME_AREA[i][3], item)    -- 家具描述
        self:setLabelText("InfoLabel_1", HOME_AREA[i][4], item)    -- 功能描述
        listView:pushBackCustomItem(item)

        self:bindPanel(item, self.selects[HOME_AREA[i][1]])
    end
end

-- 绑定面板时间
function HomeSpaceDlg:bindPanel(panel, selectRadio)
    if not self.radioGroups then self.radioGroups = {} end

    local panelName = panel:getName()
    self.radioGroups[panelName] = RadioGroup.new()
    local items = {}
    for k, _ in pairs(PANEL_2_TYPE) do
        table.insert(items, self:getControl("CheckBox", nil, self:getControl(k, nil, panel)))
    end

    table.sort(items, function(l, r)
        return PANEL_2_TYPE[l:getParent():getName()] < PANEL_2_TYPE[r:getParent():getName()]
    end)

    self.radioGroups[panelName]:setItems(self, items, self.onCheck)

    if selectRadio > 0 then
        self.radioGroups[panelName]:selectRadio(selectRadio or 1, true)
    end
end

-- 刷新界面数据
function HomeSpaceDlg:refreshData()
    -- 更新面板数据
    local val
    local has = 0
    local key
    for k, _ in ipairs(HOME_AREA) do
        key = HOME_AREA[k][1]
        if self.selects[key] and self.selects[key] > 0 then
            val = HOME_AREA[k][5][self.selects[key]]
        else
            val = 0
        end
        has = has + val
        self:setLabelText("SpaceNumLabel", string.format(CHS[2000264], val), key)
    end

    -- 更新进度数据
    local total = HOME_TYPE[self.curHomeType][2]
    local progress = self:getControl("ProgressBar", nil, "SpaceProgressPanel")
    if has > total then
        progress:loadTexture(PROGRESS_BAR.RED)
    else
        progress:loadTexture(PROGRESS_BAR.GREEN)
    end
    self:setProgressBar("ProgressBar", has, total, "SpaceProgressPanel")
    self:setLabelText("ProgressLabel_1", string.format("%d/%d", has, total), "SpaceProgressPanel")
    self:setLabelText("ProgressLabel_2", string.format("%d/%d", has, total), "SpaceProgressPanel")
    self.has = has
    self.total = total
end

-- 确认按钮
function HomeSpaceDlg:onConfirmButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[2000265])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000266])
        return
    end

    if Me:queryBasicInt("level") < 75 then
        gf:ShowSmallTips(CHS[2000267])
        return
    end

    if self.has > self.total then
        gf:ShowSmallTips(CHS[2000268])
        return
    end
    
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    -- 安全锁
    if self:checkSafeLockRelease("onConfirmButton") then
        return
    end

    local function toBuyHouse()
        local data2 = { action = self.action, house_name = HOME_TYPE[self.curHomeType][1], bedroom_level = self.selects["bed_room"] or 0, store_level = self.selects["store_room"] or 0 , lianqs_level = self.selects["artifact_room"] or 0, xiulians_level = self.selects["practice_room"] or 0}
        gf:CmdToServer('CMD_BUY_HOUSE', data2)
        self:onCloseButton()
    end

    -- 购买操作
    local function buyHouse()
        if gf:checkCurMoneyEnough(self.price, function()
            toBuyHouse()
        end, true) then
            toBuyHouse()
        end
    end

    if "upgrade" == self.action then
        -- 升级
        gf:confirm(string.format(CHS[2000269], gf:getMoneyDesc(self.price), HOME_TYPE[self.lastHomeType][1], HOME_TYPE[self.curHomeType][1]), function()
            buyHouse()
        end)
    elseif "modify" == self.action then
        -- 改造
        local mdfyAcount = InventoryMgr:getAmountByName(CHS[4200420])
        if mdfyAcount <= 0 then
            gf:confirm(string.format(CHS[2000270], gf:getMoneyDesc(self.price)), function()
                buyHouse()
            end)
        else
            gf:confirm(CHS[4200421], function()
                toBuyHouse()
            end)            
        end
    else
        -- 购买
        gf:confirm(string.format(CHS[2000271], gf:getMoneyDesc(self.price), HOME_TYPE[self.curHomeType][1]), function()
            buyHouse()
        end)
    end
end

-- 区域类型选择
function HomeSpaceDlg:onCheck(sender, eventType)
    local typePanel = sender:getParent()
    local typeName = typePanel:getName()
    local areaPanel = typePanel:getParent()
    local areaName = areaPanel:getName()

    -- 保存选择项
    self.selects[areaName] = PANEL_2_TYPE[typeName]

    -- 刷新界面数据
    self:refreshData()
end

-- 区域选择选中同一个
function HomeSpaceDlg:onCheckSame(sender, eventType)
    local typePanel = sender:getParent()
    local areaPanel = typePanel:getParent()
    local areaName = areaPanel:getName()
    self.radioGroups[areaName]:unSelectedRadio()
    self.selects[areaName] = 0

    -- 刷新界面数据
    self:refreshData()
end

function HomeSpaceDlg:MSG_GENERAL_NOTIFY(data)
    local notify = data.notify
    if NOTIFY.NOTIFY_BUY_HOUSE_RESULT == notify then
        self:onCloseButton()
    end
end

return HomeSpaceDlg