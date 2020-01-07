-- WoodSoldierDlg.lua
-- Created by sujl, Sept/8/2017
-- 演武木桩

local WoodSoldierDlg = Singleton("WoodSoldierDlg", Dialog)

local ATTRS = {
    "level",
    "life",
    "tactics",
    "num",

    "tao",
    "phy_power",
    "mag_power",
    "speed",
    "polar",
    "def",
    
    -- 忽视抗异常
    "ignore_resist_except",
    "ignore_resist_except_value",

    -- 忽视抗性
    "ignore_resist_polar",
    "ignore_resist_polar_value",

    -- 抗异常
    "resist_except",
    "resist_except_value",

    -- 抗性
    "resist_polar",
    "resist_polar_value",
}

local POLARS = { CHS[2500001], CHS[2500002], CHS[2500003], CHS[2500004], CHS[2500005], CHS[2500006] }
local TACTICS = { CHS[2500007], CHS[2500008], CHS[2500009], CHS[2500010] }
local IGNORE_RESIST_EXCEPTS = { CHS[2500011], CHS[2500012], CHS[2500013], CHS[2500014], CHS[2500015], CHS[2500016] }
local IGNORE_RESIST_POLARS = { CHS[2500017], CHS[2500018], CHS[2500019], CHS[2500020], CHS[2500021], CHS[2500022] }
local RESIST_EXCEPTS = { CHS[2500023], CHS[2500024], CHS[2500025], CHS[2500026], CHS[2500027], CHS[2500028] }
local RESIST_POLARS = { CHS[2500029], CHS[2500030], CHS[2500031], CHS[2500032], CHS[2500033], CHS[2500034] }
local NUMS = { CHS[2500035], CHS[2500036], CHS[2500037], CHS[2500038], CHS[2500039], CHS[2500040], CHS[2500041], CHS[2500042], CHS[2500043], CHS[2500044] }

function WoodSoldierDlg:init(data)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("FightButton", self.onFightButton)
    self:bindListener("ResetAllButton", self.onResetAllButton)
    self:bindListener("UnitPanel", self.onSelectItem, "TipPanel")

    self.vars = HomeMgr:getWoodSoldierValue()
    self.varsIsFirst = {}
    self.furnitureId = data[1]
    self.furnitureX, self.furnitureY = data[2], data[3]
    local root

    root = self:getControl("LevelPanel", nil, "EffectPanel_1")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 180, name = "level", default = CHS[2500045] })

    root = self:getControl("TaoPanel", nil, "EffectPanel_1")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 100000, name = "tao", default = CHS[2500045] })

    root = self:getControl("LifePanel", nil, "EffectPanel_2")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 2000000000, name = "life", default = CHS[2500045] })

    root = self:getControl("SpeedPanel", nil, "EffectPanel_2")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 100000, name = "speed", default = CHS[2500045] })

    root = self:getControl("PhyPanel", nil, "EffectPanel_3")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 1000000, name = "phy_power", default = CHS[2500045] })

    root = self:getControl("SpeedPanel", nil, "EffectPanel_3")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 1000000, name = "mag_power", default = CHS[2500045] })
    
    root = self:getControl("DecencePanel", nil, "EffectPanel_5")
    self:bindNumInput("BKImage", root, nil, { root = root, limit = 100000, name = "def", default = CHS[2500045] })

    -- 悬浮面板
    self.unitPanel = self:retainCtrl("UnitPanel", "TipPanel")
    self:bindTipPanelTouchEvent()

    -- 数量
    self:bindPopup("NumPanel", "EffectPanel_4", nil, "num", NUMS)

    -- 相性
    self:bindPopup("PolarPanel", "EffectPanel_4", nil, "polar", POLARS)

    -- 策略
    self:bindPopup("StrategyPanel", "EffectPanel_5", nil, "tactics", TACTICS)

    -- 忽视抗异常
    self:bindPopup("HuShiPanel_1", "EffectPanel_6", "ChoseButton_1", "ignore_resist_except", IGNORE_RESIST_EXCEPTS)

    root = self:getControl("HuShiPanel_1", nil, "EffectPanel_6")
    self:bindNumInput("BKImage_2", root, function()
        if not self.vars["ignore_resist_except"] then
            gf:ShowSmallTips(CHS[2500046])
            return true
        end
    end, { root = root, limit = 100, name = "ignore_resist_except_value", default = CHS[2500045] })

    -- 忽视抗性
    self:bindPopup("KangPanel_1", "EffectPanel_7", "ChoseButton_1", "ignore_resist_polar", IGNORE_RESIST_POLARS)

    root = self:getControl("KangPanel_1", nil, "EffectPanel_7")
    self:bindNumInput("BKImage_2", root, function()
        if not self.vars["ignore_resist_polar"] then
            gf:ShowSmallTips(CHS[2500047])
            return true
        end
    end, { root = root, limit = 100, name = "ignore_resist_polar_value", default = CHS[2500045] })

    -- 抗异常
    self:bindPopup("HuShiPanel_2", "EffectPanel_8", "ChoseButton_1", "resist_except", RESIST_EXCEPTS)

    root = self:getControl("HuShiPanel_2", nil, "EffectPanel_8")
    self:bindNumInput("BKImage_2", root, function()
        if not self.vars["resist_except"] then
            gf:ShowSmallTips(CHS[2500048])
            return true
        end
    end, { root = root, limit = 100, name = "resist_except_value", default = CHS[2500045] })

    -- 抗性
    self:bindPopup("HuShiPanel_2", "EffectPanel_9", "ChoseButton_1", "resist_polar", RESIST_POLARS)

    root = self:getControl("HuShiPanel_2", nil, "EffectPanel_9")
    self:bindNumInput("BKImage_2", root, function()
        if not self.vars["resist_polar"] then
            gf:ShowSmallTips(CHS[2500049])
            return true
        end
    end, { root = root, limit = 100, name = "resist_polar_value", default = CHS[2500045] })

    self:initAll()
end

function WoodSoldierDlg:cleanup()
    HomeMgr:saveWoodSoldierValue(self.vars)
end

function WoodSoldierDlg:bindNumInput(ctrlName, root, limitCallBack, key)
    local panel = self:getControl(ctrlName, nil, root)
    local function openNumIuputDlg()
        if limitCallBack and "function" == type(limitCallBack) then
            if limitCallBack(self) then
                return
            end
        end

        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg:setKey(key)
        dlg:updatePosition(rect)

        if self.doWhenOpenNumInput then
            self:doWhenOpenNumInput(ctrlName, root)
        end
        
        -- 标记第一次对新打开的数字键盘进行操作
        self.varsIsFirst[key.name] = true
    end

    self:bindListener(ctrlName, openNumIuputDlg, root)
end

-- 数字确认
function WoodSoldierDlg:closeNumInputDlg(keys)
    if self.vars[keys.name] and self.vars[keys.name] <= 0 and keys.name ~= "def" then
        gf:ShowSmallTips(CHS[2500050])
        self.vars[keys.name] = nil
        self:setLabelText("InputLabel_1", "", keys.root)
        self:setCtrlVisible("InputLabel_2", true, keys.root)
    end
end

function WoodSoldierDlg:refreshNumber(num, keys)
    if num and keys.limit and num > keys.limit then
        gf:ShowSmallTips(CHS[2500051])
        num = keys.limit
    end

    self.vars[keys.name] = num

    self:setLabelText("InputLabel_1", num or "", keys.root)
    self:setCtrlVisible("InputLabel_2", num == nil, keys.root)
end

-- 数字插入
function WoodSoldierDlg:insertNumber(num, keys)
    if self.varsIsFirst[keys.name] then
        -- 重新打开数字键盘时，要删除原有数值，重新获取数值，并取消标记第一次操作。
        self.varsIsFirst[keys.name] = false
        self.vars[keys.name] = 0
    end
    
    local curNum = self.vars[keys.name]
    if not curNum or 0 == curNum then
        curNum = tonumber(num) or 0
    elseif "00" == num then
        curNum = curNum * 100
    elseif "0000" == num then
        curNum = curNum * 10000
    else
        curNum = curNum * 10 + tonumber(num) or 0
    end

    self:refreshNumber(curNum, keys)
end

function WoodSoldierDlg:deleteNumber(keys)
    if self.varsIsFirst[keys.name] then
        -- 重新打开数字键盘时，第一次删除数字，直接从原有内容删除一位数，并取消标记第一次操作。
        self.varsIsFirst[keys.name] = false
    end
    
    local curNum = self.vars[keys.name]
    if curNum then
        curNum = math.floor(curNum / 10)
    end

    self:refreshNumber(curNum, keys)
end

function WoodSoldierDlg:deleteAllNumber(keys)
    local curNum = self.vars[keys.name]
    if curNum then
        curNum = 0
    end

    self:refreshNumber(curNum, keys)
end

function WoodSoldierDlg:bindPopup(name, root, btnName, key, datas)
    self:bindListener(btnName or "ChoseButton", function(dlg, sender, eventType)
        self:showPopup({ name = name, root = root, key = key }, datas)
    end, self:getControl(name, nil, root))

end

-- 绑定搜索框关闭时间
function WoodSoldierDlg:bindTipPanelTouchEvent()
    local tipPanel = self:getControl("TipPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(tipPanel:getContentSize())
    layout:setPosition(tipPanel:getPosition())
    layout:setAnchorPoint(tipPanel:getAnchorPoint())

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(tipPanel)
        local toPos = touch:getLocation()

        if not cc.rectContainsPoint(rect, toPos) and  tipPanel:isVisible() then
            tipPanel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

-- 弹出框
function WoodSoldierDlg:showPopup(keys, data)
    local panel = self:getControl("SearchListPanel", nil, "TipPanel")
    panel:removeAllChildren()

    local colunm = 3
    local contentLayer = ccui.Layout:create()
    local line = math.floor((#data + 2) / 3)
    local left = #data % colunm

    local curColunm = 0
    local totalHeight = line * self.unitPanel:getContentSize().height

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * colunm
            local cell = self.unitPanel:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * self.unitPanel:getContentSize().width
            local y = totalHeight - (i - 1) * self.unitPanel:getContentSize().height
            cell:setPosition(x, y)
            self:setLabelText("Label", data[tag], cell)
            cell.value = data[tag]
            cell.key = keys
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(panel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(panel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(true)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY(scroview:getContentSize().height  - totalHeight)
    end

    panel:addChild(scroview)
    self:setCtrlVisible("TipPanel", true)
end

function WoodSoldierDlg:resetInput(name, root, value)
    self:setLabelText("InputLabel_1", value or "", self:getControl(name, nil, root))
    self:setCtrlVisible("InputLabel_2", string.isNilOrEmpty(value), self:getControl(name, nil, root))
end

function WoodSoldierDlg:resetPopup(name, root, value)
    self:setLabelText("InputLabel", value or "", self:getControl(name, nil, root))
end

function WoodSoldierDlg:initAll()
    if not self.vars then return end

    -- 等级
    self:resetInput("LevelPanel", "EffectPanel_1", self.vars["level"])

    -- 道行
    self:resetInput("TaoPanel", "EffectPanel_1", self.vars["tao"])

    -- 气血
    self:resetInput("LifePanel", "EffectPanel_2", self.vars["life"])

    -- 速度
    self:resetInput("SpeedPanel", "EffectPanel_2", self.vars["speed"])

    -- 物攻
    self:resetInput("PhyPanel", "EffectPanel_3", self.vars["phy_power"])

    -- 法攻
    self:resetInput("SpeedPanel", "EffectPanel_3", self.vars["mag_power"])
    
    -- 防御
    self:resetInput("DecencePanel", "EffectPanel_5", self.vars["def"] or CHS[5410159])
    
    -- 数量
    self:resetPopup("NumPanel", "EffectPanel_4", self.vars["num"])

    -- 相性
    self:resetPopup("PolarPanel", "EffectPanel_4", self.vars["polar"] or CHS[2500006])

    -- 策略
    self:resetPopup("StrategyPanel", "EffectPanel_5", self.vars["tactics"])

    -- 忽视抗异常
    self:resetPopup("HuShiPanel_1", "EffectPanel_6", self.vars["ignore_resist_except"])
    self:resetInput("HuShiPanel_1", "EffectPanel_6", self.vars["ignore_resist_except_value"])

    -- 忽视抗性
    self:resetPopup("KangPanel_1", "EffectPanel_7", self.vars["ignore_resist_polar"])
    self:resetInput("KangPanel_1", "EffectPanel_7", self.vars["ignore_resist_polar_value"])

    -- 抗异常
    self:resetPopup("HuShiPanel_2", "EffectPanel_8", self.vars["resist_except"])
    self:resetInput("HuShiPanel_2", "EffectPanel_8", self.vars["resist_except_value"])

    -- 抗性
    self:resetPopup("HuShiPanel_2", "EffectPanel_9", self.vars["resist_polar"])
    self:resetInput("HuShiPanel_2", "EffectPanel_9", self.vars["resist_polar_value"])
end

function WoodSoldierDlg:resetAll()
    self.vars = {}

    -- 等级
    self:resetInput("LevelPanel", "EffectPanel_1")

    -- 道行
    self:resetInput("TaoPanel", "EffectPanel_1")

    -- 气血
    self:resetInput("LifePanel", "EffectPanel_2")

    -- 速度
    self:resetInput("SpeedPanel", "EffectPanel_2")

    -- 物攻
    self:resetInput("PhyPanel", "EffectPanel_3")

    -- 法攻
    self:resetInput("SpeedPanel", "EffectPanel_3")
    
    -- 防御
    self:resetInput("DecencePanel", "EffectPanel_5", CHS[5410159])

    -- 数量
    self:resetPopup("NumPanel", "EffectPanel_4")

    -- 相性
    self:resetPopup("PolarPanel", "EffectPanel_4", CHS[2500052])

    -- 策略
    self:resetPopup("StrategyPanel", "EffectPanel_5")

    -- 忽视抗异常
    self:resetPopup("HuShiPanel_1", "EffectPanel_6")
    self:resetInput("HuShiPanel_1", "EffectPanel_6")

    -- 忽视抗性
    self:resetPopup("KangPanel_1", "EffectPanel_7")
    self:resetInput("KangPanel_1", "EffectPanel_7")

    -- 抗异常
    self:resetPopup("HuShiPanel_2", "EffectPanel_8")
    self:resetInput("HuShiPanel_2", "EffectPanel_8")

    -- 抗性
    self:resetPopup("HuShiPanel_2", "EffectPanel_9")
    self:resetInput("HuShiPanel_2", "EffectPanel_9")
end

-- 获取属性值
function WoodSoldierDlg:getPropValue(prop)
    if 'tactics' == prop then
        for i = 1, #TACTICS do
            if TACTICS[i] == self.vars[prop] then return i end
        end
    elseif 'polar' == prop then
        for i = 1, #POLARS do
            if POLARS[i] == self.vars[prop] then return i end
        end
        return 6 -- 随机相性
    elseif 'ignore_resist_except' == prop then
        for i = 1, #IGNORE_RESIST_EXCEPTS do
            if IGNORE_RESIST_EXCEPTS[i] == self.vars[prop] then return i end
        end
    elseif 'ignore_resist_polar' == prop then
        for i = 1, #IGNORE_RESIST_POLARS do
            if IGNORE_RESIST_POLARS[i] == self.vars[prop] then return i end
        end
    elseif 'resist_except' == prop then
        for i = 1, #RESIST_EXCEPTS do
            if RESIST_EXCEPTS[i] == self.vars[prop] then return i end
        end
    elseif 'resist_polar' == prop then
        for i = 1, #RESIST_POLARS do
            if RESIST_POLARS[i] == self.vars[prop] then return i end
        end
    elseif 'num' == prop then
        for i = 1, #NUMS do
            if NUMS[i] == self.vars[prop] then return i end
        end
    elseif 'def' == prop and not self.vars[prop] then
        return -1
    else
        return self.vars[prop]
    end
end

-- 规则按钮
function WoodSoldierDlg:onRuleButton(sender, eventType)
   DlgMgr:openDlg("WoodSoldierRuleDlg")
end

-- 进入战斗按钮
function WoodSoldierDlg:onFightButton(sender, eventType)

    local function check()
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[2000280])
            return false
        end

        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[2000281])
            return false
        end

        local furniture = HomeMgr:getFurnitureById(self.furnitureId)
        if not furniture or furniture:queryBasicInt("durability") <= 0 then
            gf:ShowSmallTips(CHS[2500053])
            return false
        end

        local curX, curY = gf:convertToMapSpace(furniture.curX, furniture.curY)
        if curX ~= self.furnitureX or curY ~= self.furnitureY then
            -- 家具位置移动
            gf:ShowSmallTips(CHS[2000391])
            return false
        end

        if HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
            gf:ShowSmallTips(CHS[2500054])
            return false
        end

        if not self.vars["level"] or self.vars["level"] == 0 then
            gf:ShowSmallTips(CHS[2500055])
            return false
        end

        if not self.vars["life"] or self.vars["life"] == 0 then
            gf:ShowSmallTips(CHS[2500056])
            return false
        end

        if not self.vars["num"] or self.vars["num"] == 0 then
            gf:ShowSmallTips(CHS[2500057])
            return false
        end

        if not self.vars["tactics"] or self.vars["tactics"] == 0 then
            gf:ShowSmallTips(CHS[2500058])
            return false
        end

        return true
    end

    if not check() then return end

    local t = {}
    for i = 1, #ATTRS do
        table.insert(t, self:getPropValue(ATTRS[i]) or 0)
    end

    local furniture = HomeMgr:getFurnitureById(self.furnitureId)
    gf:confirm(string.format(CHS[2500059], furniture:queryBasicInt("durability")), function()
        if check() then
            gf:CmdToServer('CMD_HOUSE_USE_FURNITURE', {furniture_pos = self.furnitureId, action='puppet', para1 = table.concat(t, ','), para2 = ''})
        end
    end)
end

-- 重置按钮
function WoodSoldierDlg:onResetAllButton(sender, eventType)
    gf:confirm(CHS[2500060], function()
        self:resetAll()
    end)
end

function WoodSoldierDlg:onSelectItem(sender, eventType)
    local key = sender.key
    local val = sender.value

    self:setLabelText("InputLabel", val, self:getControl(key.name, nil, key.root))
    self.vars[key.key] = val

    self:setCtrlVisible("TipPanel", false)
end

return WoodSoldierDlg