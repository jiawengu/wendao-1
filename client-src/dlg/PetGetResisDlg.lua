-- PetGetResisDlg.lua
-- Created by liuhb sep/24/2015
-- 宠物抗性加点

local PetGetResisDlg = Singleton("PetGetResisDlg", Dialog)

local RESIST_TYPE = {
    "resist_metal",
    "resist_wood",
    "resist_water",
    "resist_fire",
    "resist_earth",

    "resist_forgotten",
    "resist_poison",
    "resist_frozen",
    "resist_sleep",
    "resist_confusion",
}

local RESIST_PANEL = {
    "AddGoldPanel",
    "AddWoodPanel",
    "AddWaterPanel",
    "AddFirePanel",
    "AddSoilPanel",

    "AddForgetPanel",
    "AddPosinPanel",
    "AddColdPanel",
    "AddSleepPanel",
    "AddChaosPanel",
}

local RESIST_TIP = {
    CHS[3003378],
    CHS[3003379],
    CHS[3003380],
    CHS[3003381],
    CHS[3003382],

    CHS[3003383],
    CHS[3003384],
    CHS[3003385],
    CHS[3003386],
    CHS[3003387],
}

function PetGetResisDlg:ListenerEx(func)
    return function(self, sender, eventType)
        if sender:getParent():getName() == self.curParentBtn
        and sender:getName() == self.curBtn then
            if nil == self.curBtnClick then
                self.curBtnClick = 0
            end

            self.curBtnClick = self.curBtnClick + 1
        else
            self.curBtnClick = 1
            self.curBtn = sender:getName()
            self.curParentBtn = sender:getParent():getName()
        end

        if 5 == self.curBtnClick then
            gf:ShowSmallTips(CHS[3003388])
        end

        func(self, sender, eventType)
    end, func
end

function PetGetResisDlg:blindPress(widget, func, longFunc)
    if not widget then
        return
    end

    local i = 0
    local function updataCount()
        i = i + 1
        if 1 == i then return end
        longFunc(self, widget, self.touchStatus)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = eventType
            func(self, widget, self.touchStatus)
            i = 0
            schedule(widget, updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = eventType
            widget:stopAllActions()
            self:updateBtnState()
        end
    end

    widget:addTouchEventListener(listener)
end

function PetGetResisDlg:init()
    self:bindListener("RduceALLButton", self.onRduceALLButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)

    self:hookMsg("MSG_UPDATE_PETS")

    self:hookMsg("MSG_ASSIGN_RESIST")
end

function PetGetResisDlg:cleanup()
    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        self[attrib] = nil
    end

    self.selectPet = nil

    self.curBtnClick = nil
    self.curBtn = nil
    self.curParentBtn = nil
    self.lastSelectPetInfo = nil
end

function PetGetResisDlg:resetInfo(pet, notReservePointAdded)
    if nil == pet then return end

    -- 如果此次reset宠物时，宠物的抗性实际未分配点数不变，则保留当前加点
    local lastSelectPetInfo = self.lastSelectPetInfo
    self.lastSelectPetInfo =
    {
        ["resist_point"] = pet:queryBasicInt("resist_point"),
    }

    local needToReservePointAdded
    if lastSelectPetInfo and lastSelectPetInfo["resist_point"] == pet:queryBasicInt("resist_point") then
        needToReservePointAdded = true
    end

    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        self[attrib] = nil
    end

    self.selectPet = pet

    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel)
    self:setLabelText("levelLabel", string.format(CHS[3003390], pet:queryInt("level")))
    self:setLabelText("PetPolarLabel", gf:getPolar(pet:queryInt("polar")))
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, self.root, true, nil, nil, cc.p(0, -58))

    if notReservePointAdded or not needToReservePointAdded then
        for i = 1, #RESIST_PANEL do
            self:initResistCell("ReduceButton", "NumLabel", "AddButton", "Label_136", RESIST_PANEL[i], RESIST_TYPE[i], pet:queryInt(RESIST_TYPE[i]), RESIST_TIP[i])
        end

        -- 剩余点数
        self:setLabelText("NoAllotLabel", string.format(CHS[3003389], pet:queryBasicInt("resist_point")))

        -- 元宝
        self:setCtrlVisible("CostPanel", false)
        self:setLabelText("NoLabel", 0)

        self:updateBtnState()
    end
end

function PetGetResisDlg:setPetLogoPanel(pet)
    PetMgr:setPetLogo(self, pet)
end

-- 初始化每一个CELL
function PetGetResisDlg:initResistCell(reduceBtnStr, valueLbStr, addBtnStr, tipLbStr, panelStr, attrib, initValue, tipStr)
    local panel = self:getControl(panelStr)
    local reduceBtn = self:getControl(reduceBtnStr, nil, panel)
    local addBtn = self:getControl(addBtnStr, nil, panel)
    local valueLb = self:getControl(valueLbStr, nil, panel)
    local tipLb = self:getControl(tipLbStr, nil, panel)
    reduceBtn.attrib = attrib
    reduceBtn.label = valueLb
    addBtn.attrib = attrib
    addBtn.label = valueLb
    valueLb.attrib = attrib

    valueLb:setString(tostring(initValue))
    valueLb:setColor(COLOR3.TEXT_DEFAULT)

    -- 邦定增加减少按钮事件
    self:blindPress(addBtn, self:ListenerEx(self.onAddButton))
    self:blindPress(reduceBtn, self:ListenerEx(self.onReduceButton))

    tipLb:setTouchEnabled(true)
    self:bindTouchEndEventListener(tipLb, function(self, sender)
        gf:showTipInfo(tipStr, sender)
    end)
end

-- 添加每一个属性
function PetGetResisDlg:tryAddPoint(sender, count)
    if nil == sender then return end
    local attrib = sender.attrib
    if nil == attrib then return end

    if nil == self[attrib] then
        self[attrib] = 0
    end

    if (self.selectPet:queryInt(attrib) + self[attrib] + count > 30) then
        return
    end

    if (self.selectPet:queryInt(attrib) + self[attrib] + count < 0) then
        count = -(self.selectPet:queryInt(attrib) + self[attrib])
    end

    self[attrib] = self[attrib] + count
    local attribValue = self.selectPet:queryInt(attrib) + self[attrib]
    sender.label:setString(tostring(attribValue))

    if self[attrib] < 0 then
        sender.label:setColor(COLOR3.RED)
    elseif self[attrib] == 0 then
        sender.label:setColor(COLOR3.TEXT_DEFAULT)
    elseif self[attrib] > 0 then
        sender.label:setColor(COLOR3.GREEN)
    end

    self:updateNoPoint()

    -- 更新元宝消耗
    self:updateCost()

    -- 更新按钮状态
    self:updateBtnState()
end

-- 更新未分配点数
function PetGetResisDlg:updateNoPoint()
    local totle = self:getPreAddPoint()
    self:setLabelText("NoAllotLabel", string.format(CHS[3003389], self.selectPet:queryBasicInt("resist_point") - totle))
end

-- 更新按钮状态
function PetGetResisDlg:updateBtnState()
    -- 剩余点数到0, AddButton置灰
    local point = self.selectPet:queryBasicInt("resist_point")
    local totle = self:getPreAddPoint()
    local leftPoint = point - totle
    for i = 1, #RESIST_PANEL do
        local panel = self:getControl(RESIST_PANEL[i])
        self:setCtrlEnabled("AddButton", true, panel)
        self:setCtrlEnabled("ReduceButton", true, panel)

        local value = self:getLabelText("NumLabel", panel)
        value = tonumber(value)
        if leftPoint <= 0 then
            self:setCtrlEnabled("AddButton", false, panel)
        end

        -- 上限达到30，AddButton置灰
        if value == 30 then
            self:setCtrlEnabled("AddButton", false, panel)
        end

        -- 下限达到0，ReduceButton置灰
        if value == 0 then
            self:setCtrlEnabled("ReduceButton", false, panel)
        end
    end

    if self:getPreAddPoint() == 0 then
        self:setCtrlEnabled("ConfirmButton", false)
        self:setCtrlEnabled("CancelButton", false)
    else
        self:setCtrlEnabled("ConfirmButton", true)
        self:setCtrlEnabled("CancelButton", true)
    end

    if self:getAlreadyAddPoint() == 0 then
        self:setCtrlEnabled("RduceALLButton", false)
    else
        self:setCtrlEnabled("RduceALLButton", true)
    end

    -- 如果需要花费元宝，则可点击
    local calPoint = self:getNeedCostPoint()
    if calPoint > 0 then
        self:setCtrlEnabled("ConfirmButton", true)
        self:setCtrlEnabled("CancelButton", true)
    end

end

-- 获取总共加了多少点
function PetGetResisDlg:getPreAddPoint()
    local totle = 0
    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        if nil == self[attrib] then
            totle = totle + 0
        else
            totle = totle + self[attrib]
        end
    end

    return totle
end

-- 获取原本加了多少点
function PetGetResisDlg:getAlreadyAddPoint()
    if nil == self.selectPet then return 0 end

    local totle = 0
    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        totle = totle + self.selectPet:queryInt(attrib)
    end

    return totle
end

function PetGetResisDlg:getNeedCostPoint()
    local calPoint = 0
    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        if nil ~= self[attrib] then
            calPoint = calPoint + math.max( -self[attrib], 0)
        end
    end

    return calPoint
end

-- 更新元宝消耗
function PetGetResisDlg:updateCost()
    -- 需要计算元宝的点数
    local calPoint = self:getNeedCostPoint()
    if calPoint > 0 then
        self:setCtrlVisible("CostPanel", true)
        self:setLabelText("NoLabel", calPoint * 50)
    else
        self:setCtrlVisible("CostPanel", false)
    end
end

function PetGetResisDlg:onAddButton(sender, eventType)
    local leftPoint = self.selectPet:queryBasicInt("resist_point")
    local totle = self:getPreAddPoint()
    if leftPoint - totle <= 0 then return end
    self:tryAddPoint(sender, 1)
end

function PetGetResisDlg:onReduceButton(sender, eventType)
    self:tryAddPoint(sender, -1)
end

function PetGetResisDlg:onRduceALLButton(sender, eventType)
    for i = 1, #RESIST_PANEL do
        local panel = self:getControl(RESIST_PANEL[i])
        local btn = self:getControl("ReduceButton", nil, panel)
        self:tryAddPoint(btn, -99)
    end
end

function PetGetResisDlg:onCancelButton(sender, eventType)
    self:resetInfo(self.selectPet, true)
end

function PetGetResisDlg:resetPoint(cost)
    if nil == self.selectPet then return end

    local calPoint = self:getNeedCostPoint()
    if Me:getTotalCoin() < calPoint * 50 then
        gf:askUserWhetherBuyCoin("gold_coin")
        return
    end

    local addStr = ""
    for i = 1, #RESIST_TYPE do
        local attrib = RESIST_TYPE[i]
        if nil == self[attrib] then
            addStr = addStr .. "0;"
        else
            addStr = addStr .. tostring(self[attrib]) .. ";"
        end
    end

    gf:CmdToServer("CMD_ASSIGN_RESIST", {
        id = self.selectPet:getId(),
        attribValues = addStr,
    })
end

function PetGetResisDlg:onConfirmButton(sender, eventType)
    local cost = self:getNeedCostPoint() * 50
    if cost <= 0 then
        self:resetPoint()
    else
        -- 判断是否处于公示期
        if Me:isInTradingShowState() then
            gf:ShowSmallTips(CHS[4300227])
            return
        end

        gf:confirm(string.format(CHS[4300264], cost), function ()
            self:resetPoint()
        end)
    end
end

--
function PetGetResisDlg:refreshInfo(pet, notReservePointAdded)
    if nil == pet then return end

    -- 如果此次reset宠物时，宠物的抗性实际未分配点数不变，则保留当前加点
    local lastSelectPetInfo = self.lastSelectPetInfo
    self.lastSelectPetInfo =
        {
            ["resist_point"] = pet:queryBasicInt("resist_point"),
        }

    local needToReservePointAdded
    if lastSelectPetInfo and lastSelectPetInfo["resist_point"] == pet:queryBasicInt("resist_point") then
        needToReservePointAdded = true
    end



    self.selectPet = pet

    self:setPetLogoPanel(pet)

    -- 设置类型：野生、宝宝
    self:setImage("SuffixImage", ResMgr:getPetRankImagePath(pet))

    local nameLevel = string.format(CHS[4000391], pet:getShowName(), pet:queryBasicInt("level"))
    self:setLabelText("PetNameLabel", nameLevel)
    self:setLabelText("levelLabel", string.format(CHS[3003390], pet:queryInt("level")))
    self:setLabelText("PetPolarLabel", gf:getPolar(pet:queryInt("polar")))
    self:setPortrait("PetIconPanel", pet:getDlgIcon(nil, nil, true), 0, self.root, true, nil, nil, cc.p(0, -58))

    if notReservePointAdded or not needToReservePointAdded then
        for i = 1, #RESIST_PANEL do
            self:initResistCell("ReduceButton", "NumLabel", "AddButton", "Label_136", RESIST_PANEL[i], RESIST_TYPE[i], pet:queryInt(RESIST_TYPE[i]), RESIST_TIP[i])
        end

        -- 剩余点数
        self:setLabelText("NoAllotLabel", string.format(CHS[3003389], pet:queryBasicInt("resist_point")))

        -- 元宝
        self:setCtrlVisible("CostPanel", false)
        self:setLabelText("NoLabel", 0)

        self:updateBtnState()
    end
end

function PetGetResisDlg:MSG_ASSIGN_RESIST(data)
    if not self.selectPet or self.selectPet:getId() ~= data.id then
        return
    end

    local id = self.selectPet:getId()
    self.selectPet = PetMgr:getPetById(id)
    self:resetInfo(self.selectPet, true)
end

function PetGetResisDlg:MSG_UPDATE_PETS(data)
    if not self.selectPet then return end
    for i = 1, data.count do
        if data[i].no == self.selectPet:queryBasicInt("no") then
            self.selectPet = PetMgr:getPetByNo(data[i].no)
        end
    end

    if not self.selectPet or self.selectPet:getId() ~= data.id then
        return
    end

    local id = self.selectPet:getId()
    self.selectPet = PetMgr:getPetById(id)
    self:updateNoPoint()

    -- 更新按钮状态
    self:updateBtnState()
end

return PetGetResisDlg
