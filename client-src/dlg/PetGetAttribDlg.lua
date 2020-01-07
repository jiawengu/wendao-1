-- PetGetAttribDlg.lua
-- Created by liuhb Sep/23/2015
-- 宠物属性加点
local PetGetAttribDlg = Singleton("PetGetAttribDlg", Dialog)

function PetGetAttribDlg:init()
    self:blindLongPress("ConReduceButton", self.onAttribLongPress, self:ListenerExt(self.onConReduceButton))
    self:blindLongPress("ConAddButton",    self.onAttribLongPress, self:ListenerExt(self.onConAddButton))
    self:blindLongPress("WizReduceButton", self.onAttribLongPress, self:ListenerExt(self.onWizReduceButton))
    self:blindLongPress("WizAddButton",    self.onAttribLongPress, self:ListenerExt(self.onWizAddButton))
    self:blindLongPress("StrReduceButton", self.onAttribLongPress, self:ListenerExt(self.onStrReduceButton))
    self:blindLongPress("StrAddButton",    self.onAttribLongPress, self:ListenerExt(self.onStrAddButton))
    self:blindLongPress("DexReduceButton", self.onAttribLongPress, self:ListenerExt(self.onDexReduceButton))
    self:blindLongPress("DexAddButton",    self.onAttribLongPress, self:ListenerExt(self.onDexAddButton))

    self:bindListener("AutoAddPointButton", self.onAutoAddPointButton)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("ConfirmButton", self.onConfrimButton)
    self:bindListener("RduceALLButton", self.onReduceALLButton)
    self:bindListener("ResisButton", self.onResisButton)

    self:bindListener("ConLabel", self.onConLabel, nil, true)
    self:bindListener("StrLabel", self.onStrLabel, nil, true)
    self:bindListener("DexLabel", self.onDexLabel, nil, true)
    self:bindListener("WizLabel", self.onWizLabel, nil, true)


    self.lastPointTable = {ConLastPoint = 0, WizLastPoint = 0, StrLastPoint = 0, DexLastPoint = 0,}
    self.lastPercentTable = {ConLastPercent = 0, WizLastPercent = 0, StrLastPercent = 0, DexLastPercent = 0,}
    self.curPointTable = {ConCurPoint = 0, WizCurPoint = 0, StrCurPoint = 0, DexCurPoint = 0,}

    self.slider = nil
    self.isUpdateSlider = false
    self.titleType = nil

    self.pointLabel = nil
    self.addOrReduce = nil
    self.lastSelectPetInfo = {}

    self:updateAllPetInfo()

    MessageMgr:regist("MSG_PRE_ASSIGN_ATTRIB", PetGetAttribDlg)
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_SAFE_LOCK_OPEN_UNLOCK")

    -- 刷新宠物列表
    DlgMgr:sendMsg("PetListChildDlg", "refreshList")
end

function PetGetAttribDlg:updateAllPetInfo()
    local pet = DlgMgr:sendMsg("PetListChildDlg", "getCurrentPet")
    if self:checkCanReservePointAdded(self.lastSelectPetInfo, pet) then
        -- 如果可以保留宠物加点，则不重置界面
        self:setPetInfo(pet)
    else
        self:initPetInfo()
        self:setPetInfo()
        self:setCtrlVisible("CostPanel", false)
    end
end

function PetGetAttribDlg:initPetInfo()
    self:setLabelText("LifeValueLabel", 0)
    self:setLabelText("ManaValueLabel", 0)
    self:setLabelText("SpeedValueLabel", 0)

    self:setLabelText("PhyPowerValueLabel", 0)
    self:setLabelText("MagPowerValueLabel", 0)
    self:setLabelText("DefenceValueLabel", 0)

    self:setLabelText("ConAttribValueLabel", 0)
    self:setLabelText("WizAttribValueLabel", 0)
    self:setLabelText("StrAttribValueLabel", 0)
    self:setLabelText("DexAttribValueLabel", 0)

    -- 更新布局
    self:updateLayout("LifePanel")
    self:updateLayout("ManaPanel")
    self:updateLayout("SpeedPanel")

    self:updateLayout("PhyPanel")
    self:updateLayout("MagPanel")
    self:updateLayout("DefPanel")

    self:updateLayout("GetConPanel")
    self:updateLayout("GetWizPanel")
    self:updateLayout("GetStrPanel")
    self:updateLayout("GetDexPanel")

    self:setCtrlEnabled("ConReduceButton", false)
    self:setCtrlEnabled("WizReduceButton", false)
    self:setCtrlEnabled("StrReduceButton", false)
    self:setCtrlEnabled("DexReduceButton", false)

    self:setCtrlEnabled("ConAddButton", false)
    self:setCtrlEnabled("WizAddButton", false)
    self:setCtrlEnabled("StrAddButton", false)
    self:setCtrlEnabled("DexAddButton", false)


    self:setCtrlEnabled("RduceALLButton", false)
    self:setCtrlEnabled("ResetButton", false)
    self:setCtrlEnabled("ConfirmButton", false)
    self:setCtrlEnabled("ResisButton", false)
    self:setCtrlEnabled("AutoAddPointButton", false)

    self:setLabelText("AttribPointValueLabel", 0)
    self:setLabelText("LifeAddValueLabel", "")
    self:setLabelText("ManaAddValueLabel", "")
    self:setLabelText("PhyPowerAddValueLabel", "")
    self:setLabelText("MagPowerAddValueLabel", "")
    self:setLabelText("SpeedAddValueLabel", "")
    self:setLabelText("DefenceAddValueLabel", "")

    self:setLabelText("ConAddpointLabel", "")
    self:setLabelText("WizAddpointLabel", "")
    self:setLabelText("StrAddpointLabel", "")
    self:setLabelText("DexAddpointLabel", "")
end

function PetGetAttribDlg:setPetInfo(pet)
    if nil == pet then return end
    self.selectPet = pet

    -- 记录一下上一次选择宠物的相关信息，如果此次选中宠物不变，且各属性值也没有变化，则保留当前加点，不重置界面
    local lastSelectPetInfo = self.lastSelectPetInfo
    self.lastSelectPetInfo = {
        ["id"] = pet:getId(),
        ["con"] = pet:queryInt("con"),
        ["wiz"] = pet:queryInt("wiz"),
        ["str"] = pet:queryInt("str"),
        ["dex"] = pet:queryInt("dex"),
        ["attrib_point"] = pet:queryInt("attrib_point")
    }

    if self:checkCanReservePointAdded(lastSelectPetInfo, pet) then
        self:setAttrLabelWithColor("max_life", pet, "LifeValueLabel")
        self:setAttrLabelWithColor("max_mana", pet, "ManaValueLabel")
        self:setAttrLabelWithColor("speed", pet, "SpeedValueLabel")

        self:setAttrLabelWithColor("phy_power", pet, "PhyPowerValueLabel")
        self:setAttrLabelWithColor("mag_power", pet, "MagPowerValueLabel")
        self:setAttrLabelWithColor("def", pet, "DefenceValueLabel")

        self:updateLayout("LifePanel")
        self:updateLayout("ManaPanel")
        self:updateLayout("SpeedPanel")

        self:updateLayout("PhyPanel")
        self:updateLayout("MagPanel")
        self:updateLayout("DefPanel")
        return
    end

    self.attribPoint = 0
    self.conAdd = 0
    self.wizAdd = 0
    self.strAdd = 0
    self.dexAdd = 0

    -- 设置基本信息
    self:setAttrLabelWithColor("max_life", pet, "LifeValueLabel")
    self:setAttrLabelWithColor("max_mana", pet, "ManaValueLabel")
    self:setAttrLabelWithColor("speed", pet, "SpeedValueLabel")

    self:setAttrLabelWithColor("phy_power", pet, "PhyPowerValueLabel")
    self:setAttrLabelWithColor("mag_power", pet, "MagPowerValueLabel")
    self:setAttrLabelWithColor("def", pet, "DefenceValueLabel")

    self:setAttrLabelWithColor("con", pet, "ConAttribValueLabel") -- 体质
    self:setAttrLabelWithColor("wiz", pet, "WizAttribValueLabel") -- 灵力
    self:setAttrLabelWithColor("str", pet, "StrAttribValueLabel") -- 力量
    self:setAttrLabelWithColor("dex", pet, "DexAttribValueLabel") -- 敏捷

    -- 更新布局
    self:updateLayout("LifePanel")
    self:updateLayout("ManaPanel")
    self:updateLayout("SpeedPanel")

    self:updateLayout("PhyPanel")
    self:updateLayout("MagPanel")
    self:updateLayout("DefPanel")

    self:updateLayout("GetConPanel")
    self:updateLayout("GetWizPanel")
    self:updateLayout("GetStrPanel")
    self:updateLayout("GetDexPanel")

    -- 重置加点
    self:resetInfo()

    -- 重置属性点
    self:initAttriInfo("con")
    self:initAttriInfo("wiz")
    self:initAttriInfo("str")
    self:initAttriInfo("dex")

    self:setCtrlEnabled("ResisButton", true)
    self:setCtrlEnabled("AutoAddPointButton", true)

    -- 获取推荐加点
    self.recommendAttrib = nil
    if nil ~= pet then
        gf:CmdToServer("CMD_GENERAL_NOTIFY", {
            type = NOTIFY.GET_RECOMMEND_ATTRIB,
            para1 = tostring(pet:getId()),
        })
    end
end

function PetGetAttribDlg:checkCanReservePointAdded(lastSelectPetInfo, pet)
    -- 检查是否可以保留宠物属性加点
    if lastSelectPetInfo and pet
          and lastSelectPetInfo["id"] == pet:getId()
          and lastSelectPetInfo["con"] == pet:queryInt("con")
          and lastSelectPetInfo["wiz"] == pet:queryInt("wiz")
          and lastSelectPetInfo["str"] == pet:queryInt("str")
          and lastSelectPetInfo["dex"] == pet:queryInt("dex")
          and lastSelectPetInfo["attrib_point"] == pet:queryInt("attrib_point") then
        return true
    else
        return false
    end
end

function PetGetAttribDlg:cleanup()
    self.lastSelectPetInfo = {}
    self.curBtnClick = nil
    self.curBtn = nil
end

function PetGetAttribDlg:setAttrLabelWithColor(key, pet, label)
    local totle = pet:queryInt(key) or 0
    self:setLabelText(label, totle, nil, COLOR3.TEXT_DEFAULT)
end

function PetGetAttribDlg:ListenerExt(func)
    return function(self, sender, eventType)
        if sender:getName() == self.curBtn then
            if nil == self.curBtnClick then
                self.curBtnClick = 0
            end

            self.curBtnClick = self.curBtnClick + 1
        else
            self.curBtnClick = 1
            self.curBtn = sender:getName()
        end

        if 5 == self.curBtnClick then
            gf:ShowSmallTips(CHS[7000017])
        end

        func(self, sender, eventType)
    end
end

function PetGetAttribDlg:onAttribLongPress(sender, eventType) -- 长按加减属性点响应函数
    local senderName = sender:getName()
    local labelName = nil
    self.addOrReduce = 1

    if senderName == "ConReduceButton" or senderName == "ConAddButton" then labelName = "ConAddpointLabel" end
    if senderName == "WizReduceButton" or senderName == "WizAddButton" then labelName = "WizAddpointLabel" end
    if senderName == "StrReduceButton" or senderName == "StrAddButton" then labelName = "StrAddpointLabel" end
    if senderName == "DexReduceButton" or senderName == "DexAddButton" then labelName = "DexAddpointLabel" end

    if senderName == "ConReduceButton" then self.addOrReduce = -1 end
    if senderName == "WizReduceButton" then self.addOrReduce = -1 end
    if senderName == "StrReduceButton" then self.addOrReduce = -1 end
    if senderName == "DexReduceButton" then self.addOrReduce = -1 end

    self.pointLabel = self:getControl(labelName)
    local rect = self:getBoundingBoxInWorldSpace(self.pointLabel)
    local dlg = DlgMgr:openDlg("SmallNumInputDlg")
    dlg:setObj(self)

    dlg:updatePosition(rect)
end

function PetGetAttribDlg:insertNumber(num)
    local labelName = self.pointLabel:getName()
    local pet = self.selectPet
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]

    local key = nil
    if labelName == "ConAddpointLabel" then key = "con" end
    if labelName == "WizAddpointLabel" then key = "wiz" end
    if labelName == "StrAddpointLabel" then key = "str" end
    if labelName == "DexAddpointLabel" then key = "dex" end

    -- 判断意图增加的点数是否超过当前属性所能够分配的最大点数
    if self.addOrReduce == 1 and num > self.remainAttriPoint + self[key .. "Add"] then

        -- 若越界，则先将此属性的点数“还原"到宠物原本属性值，之后将此属性点数加到尽可能大（分配所有可分配点数）
        self:tryAddPoint(key, labelName, -self[key .. "Add"])
        num = self.remainAttriPoint
        dlg:setInputValue(num)
        gf:ShowSmallTips(CHS[7000018])

    -- 判断该属性减少num点后是否会越界（小于宠物等级）
    elseif self.addOrReduce == -1 and
        pet:queryBasicInt(key) - num < pet:queryBasicInt("level") then

        -- 若越界，则先将此属性的点数“还原”到宠物原本属性值，之后将此属性点数减到尽可能小（宠物等级）
        self:tryAddPoint(key, labelName, -self[key .. "Add"])
        num = pet:queryBasicInt(key) - pet:queryBasicInt("level")
        dlg:setInputValue(num)
        gf:ShowSmallTips(CHS[7000019])
    end

    -- 属性点统一分配操作
    self:tryAddPoint(key, labelName, -self[key .. "Add"] + num * self.addOrReduce)
end

-- 计算洗点元宝
function PetGetAttribDlg:updateCost()
    if self.selectPet == nil then
        self:setLabelText("CostLabel", 0)
        return
    end

    local point = 0
    if self.conAdd < 0 then point = point - self.conAdd end
    if self.wizAdd < 0 then point = point - self.wizAdd end
    if self.strAdd < 0 then point = point - self.strAdd end
    if self.dexAdd < 0 then point = point - self.dexAdd end

    local number = 0
    number = Formula:getAttribCost(self.selectPet:queryBasicInt("level"), point)
    self.number = math.floor(number)

    if self.number == 0 then
        self:setCtrlVisible("CostPanel", false)
    else
        self:setLabelText("CostLabel", math.floor(number))
        self:setCtrlVisible("CostPanel", true)
    end

    self:updateLayout("GetConPanel")
    self:updateLayout("GetWizPanel")
    self:updateLayout("GetStrPanel")
    self:updateLayout("GetDexPanel")
end

-- 属性加点相关按钮置灰
function PetGetAttribDlg:setAttribButtonGray()
    local able = self.remainAttriPoint > 0
    self:setCtrlEnabled("ConAddButton", able)
    self:setCtrlEnabled("WizAddButton", able)
    self:setCtrlEnabled("StrAddButton", able)
    self:setCtrlEnabled("DexAddButton", able)

    able =  self.conAdd ~= 0 or
        self.wizAdd ~= 0 or
        self.strAdd ~= 0 or
        self.dexAdd ~= 0
    self:setCtrlEnabled("ResetButton", able)
    self:setCtrlEnabled("ConfirmButton", able)

    local con, wiz, str, dex, level = 0,0,0,0,0
    local pet = self.selectPet
    if pet ~= nil then
        con = pet:queryBasicInt("con")
        wiz = pet:queryBasicInt("wiz")
        str = pet:queryBasicInt("str")
        dex = pet:queryBasicInt("dex")
        level = pet:queryBasicInt("level")
    end

    self:setCtrlEnabled("ConReduceButton", con + self.conAdd > level)
    self:setCtrlEnabled("WizReduceButton", wiz + self.wizAdd > level)
    self:setCtrlEnabled("StrReduceButton", str + self.strAdd > level)
    self:setCtrlEnabled("DexReduceButton", dex + self.dexAdd > level)

    if self.conAdd < 0 then
        able = con + self.conAdd > level
    else
        able = con > level
    end

    if self.wizAdd < 0 then
        able = able or wiz + self.wizAdd > level
    else
        able = able or wiz > level
    end

    if self.strAdd < 0 then
        able = able or str + self.strAdd > level
    else
        able = able or str > level
    end

    if self.dexAdd < 0 then
        able = able or dex + self.dexAdd > level
    else
        able = able or dex > level
    end

    self:setCtrlEnabled("RduceALLButton", able)
end

-- 重置加点信息
function PetGetAttribDlg:resetInfo()
    local pet = self.selectPet

    self.attribPoint = 0
    self.remainAttriPoint = 0
    if pet ~= nil then
        self.attribPoint = pet:queryInt("attrib_point")
        self.remainAttriPoint = self.attribPoint
    end

    self.conAdd = 0
    self.wizAdd = 0
    self.strAdd = 0
    self.dexAdd = 0

    self:setLabelText("AttribPointValueLabel", self.remainAttriPoint) -- 属性点数
    self:setLabelText("LifeAddValueLabel", "")
    self:setLabelText("ManaAddValueLabel", "")
    self:setLabelText("PhyPowerAddValueLabel", "")
    self:setLabelText("MagPowerAddValueLabel", "")
    self:setLabelText("SpeedAddValueLabel", "")
    self:setLabelText("DefenceAddValueLabel", "")

    self:setLabelText("ConAddpointLabel", "")
    self:setLabelText("WizAddpointLabel", "")
    self:setLabelText("StrAddpointLabel", "")
    self:setLabelText("DexAddpointLabel", "")

    self:setAttribButtonGray()
    self:updateCost()
end

-- 根据自动加点方案预分配属性值
function PetGetAttribDlg:autoPreAssign(con, wiz, str, dex)
    local pet = self.selectPet
    if not pet then return end

    local attribPoint = pet:queryInt("attrib_point")

    local value = math.floor(attribPoint / 4)

    self.attribPoint = attribPoint - 4 * value
    self.remainAttriPoint = self.attribPoint
    self:setLabelText("AttribPointValueLabel", tonumber(self.attribPoint)) -- 属性点数

    self.conAdd = value * con
    self.wizAdd = value * wiz
    self.strAdd = value * str
    self.dexAdd = value * dex

    self:setAttribValue("Con", self.conAdd, false)
    self:setAttribValue("Wiz", self.wizAdd, false)
    self:setAttribValue("Str", self.strAdd, false)
    self:setAttribValue("Dex", self.dexAdd, false)

    local text = ""
    local color = COLOR3.GREEN
    if self.conAdd > 0 then text = '+' .. self.conAdd end
    self:setLabelText("ConAddpointLabel", text, nil, color)

    text = ""
    if self.wizAdd > 0 then text = '+' .. self.wizAdd end
    self:setLabelText("WizAddpointLabel", text, nil, color)

    text = ""
    if self.strAdd > 0 then text = '+' .. self.strAdd end
    self:setLabelText("StrAddpointLabel", text, nil, color)

    text = ""
    if self.dexAdd > 0 then text = '+' .. self.dexAdd end
    self:setLabelText("DexAddpointLabel", text, nil, color)

    self:updateLayout("GetConPanel")
    self:updateLayout("GetWizPanel")
    self:updateLayout("GetStrPanel")
    self:updateLayout("GetDexPanel")

    self:setAttribButtonGray()
    self:updateCost()

    -- 发送预加点，计算数值变化
    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = pet:getId(),
        type = Const.ASSIGN_POINT_ATTRIB,
        para1 = self.conAdd,
        para2 = self.wizAdd,
        para3 = self.strAdd,
        para4 = self.dexAdd
    })
end

-- 尝试加点
function PetGetAttribDlg:tryAddPoint(key, addLabel, delta, isNotCmd)
    local pet = self.selectPet
    if pet == nil then return false end

    local level = pet:queryBasicInt("level")
    local value = self[key .. "Add"]
    if value == nil then return false end

    -- 修正加点值
    if self.remainAttriPoint < delta then delta = self.remainAttriPoint end
    if pet:queryBasicInt(key) + value + delta < level then
        delta = level - pet:queryInt(key) - value
    end
    if delta == 0 then return false end

    -- 显示加点
    value = value + delta
    self[key .. "Add"] = value
    self.remainAttriPoint = self.remainAttriPoint - delta
    self:setLabelText("AttribPointValueLabel", self.remainAttriPoint)

    -- 设置颜色
    local ctl = self:getControl(addLabel)
    if ctl ~= nil then
        if value > 0 then
            ctl:setColor(COLOR3.GREEN)
            ctl:setString("+" .. value)
        elseif value < 0 then
            ctl:setColor(COLOR3.RED)
            ctl:setString(tostring(value))
        else
            ctl:setString("")
        end
    end

    -- 设置
    if key == "con" then
        self:setAttribValue("Con", value)
    elseif key == "wiz" then
        self:setAttribValue("Wiz", value)
    elseif key == "str" then
        self:setAttribValue("Str", value)
    elseif key == "dex" then
        self:setAttribValue("Dex", value)
    end

    self:setAttribButtonGray()
    self:updateCost()

    -- 发送预加点，计算数值变化
    if not isNotCmd then
        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = pet:getId(),
            type = Const.ASSIGN_POINT_ATTRIB,
            para1 = self.conAdd,
            para2 = self.wizAdd,
            para3 = self.strAdd,
            para4 = self.dexAdd
        })
    end
    self.isShowCost = true
    -- self:setCtrlVisible("CostPanel", true)
    return true
end

-- 设置自定义加点
function PetGetAttribDlg:setRecommendAttrib(con,wiz,str,dex,autoAdd)
    local r = self.recommendAttrib
    if r == nil then return end
    r.con = con
    r.wiz = wiz
    r.str = str
    r.dex = dex
    r.auto_add = autoAdd
end

-- 按照推荐加点方案尝试加点
function PetGetAttribDlg:addRecommendAttrib(con, wiz, str, dex)
    if  con < 0 or wiz < 0 or str < 0 or dex < 0 or
        con + wiz + str + dex ~= 4 then return end

    -- 计算加点方案
    local attrib = {con,wiz,str,dex}
    local add = {0,0,0,0}
    local total = self.attribPoint
    while total > 0 do
        for i = 1, 4 do
            if total >= attrib[i] then
                add[i] = add[i] + attrib[i]
                total = total - attrib[i]
            else
                add[i] = add[i] + total
                total = 0
                break
            end
        end
    end
    -- 尝试加点
    self:tryAddPoint("con", "ConAddpointLabel", add[1])
    self:tryAddPoint("wiz", "WizAddpointLabel", add[2])
    self:tryAddPoint("str", "StrAddpointLabel", add[3])
    self:tryAddPoint("dex", "DexAddpointLabel", add[4])
end

-- 设置自定义加点
function PetGetAttribDlg:onCustomOperateButton(sender, eventType)
    local r = self.recommendAttrib
    if r ~= nil then
        DlgMgr:openDlg("PetCustomAssignAttribDlg")
        DlgMgr:sendMsg("PetCustomAssignAttribDlg","resetInfo", r.con, r.wiz, r.str, r.dex)
    end
end

-- 设置属性变化
function PetGetAttribDlg:setDelta(name, value)
    local ctl = self:getControl(name)
    if ctl == nil then return end

    if value > 0 then
        ctl:setString("+" .. value)
        ctl:setColor(COLOR3.GREEN)
    elseif value < 0 then
        ctl:setString(tostring(value))
        ctl:setColor(COLOR3.RED)
    else
        ctl:setString("")
    end
end

-- 重置加点
function PetGetAttribDlg:onResetButton(sender, eventType)
    self:resetInfo()
    self:setCtrlVisible('CostPanel', false)
    self:setCtrlVisible('FreeTipLabel', false)
    self:initAttriInfo("con")
    self:initAttriInfo("wiz")
    self:initAttriInfo("str")
    self:initAttriInfo("dex")
end

function PetGetAttribDlg:resetPoint(cost)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[8000005])
        return
    end

    if self.selectPet == nil then return end
    -- 有加点，发送加点命令
    local id = self.selectPet:getId()
    if self.conAdd ~= 0 or
        self.wizAdd ~= 0 or
        self.strAdd ~= 0 or
        self.dexAdd ~= 0
    then

        -- 安全锁判断
        if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("resetPoint", cost) then
            return
        end

        gf:CmdToServer("CMD_ASSIGN_ATTRIB", {
            id = id,
            type = Const.ASSIGN_POINT_ATTRIB,
            para1 = self.conAdd,
            para2 = self.wizAdd,
            para3 = self.strAdd,
            para4 = self.dexAdd
        })

        self:setCtrlEnabled("ConfirmButton", false)
    end
end

-- 确定加点
function PetGetAttribDlg:onConfrimButton(sender, eventType)
    local cost = self.number

    if cost <= 0 then
        self:resetPoint(cost)
    else
        -- 判断是否处于公示期
        if Me:isInTradingShowState() then
            gf:ShowSmallTips(CHS[4300227])
            return
        end

        gf:confirm(string.format(CHS[4300261], cost), function ()
            self:resetPoint(cost)
        end)
    end
end

-- 一键洗点
function PetGetAttribDlg:onReimburseButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", -9999999)
    self:tryAddPoint("wiz", "WizAddpointLabel", -9999999)
    self:tryAddPoint("str", "StrAddpointLabel", -9999999)
    self:tryAddPoint("dex", "DexAddpointLabel", -9999999)
end

function PetGetAttribDlg:onAutoAddPointButton(sender, eventType)
    local id = self.selectPet:getId()
    local dlg = DlgMgr:openDlg("PetAutoAttribDlg")
    dlg:setAutoAddObject(id)
    gf:sendGeneralNotifyCmd(NOTIFY.GET_RECOMMEND_ATTRIB, id)
end
function PetGetAttribDlg:onConReduceButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", -1)
end

function PetGetAttribDlg:onConAddButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", 1)
end

function PetGetAttribDlg:onConAttribValueButton(sender, eventType)
    gf:showTipInfo(CHS[2000033], sender)
end

function PetGetAttribDlg:onWizReduceButton(sender, eventType)
    self:tryAddPoint("wiz", "WizAddpointLabel", -1)
end

function PetGetAttribDlg:onWizAddButton(sender, eventType)
    self:tryAddPoint("wiz", "WizAddpointLabel", 1)
end

function PetGetAttribDlg:onWizAttribValueButton(sender, eventType)
    gf:showTipInfo(CHS[2000034], sender)
end

function PetGetAttribDlg:onStrReduceButton(sender, eventType)
    self:tryAddPoint("str", "StrAddpointLabel", -1)
end

function PetGetAttribDlg:onStrAddButton(sender, eventType)
    self:tryAddPoint("str", "StrAddpointLabel", 1)
end

function PetGetAttribDlg:onStrAttribValueButton(sender, eventType)
    gf:showTipInfo(CHS[2000035], sender)
end

function PetGetAttribDlg:onDexReduceButton(sender, eventType)
    self:tryAddPoint("dex", "DexAddpointLabel", -1)
end

function PetGetAttribDlg:onDexAddButton(sender, eventType)
    self:tryAddPoint("dex", "DexAddpointLabel", 1)
end

function PetGetAttribDlg:onDexAttribValueButton(sender, eventType)
    gf:showTipInfo(CHS[2000036], sender)
end

function PetGetAttribDlg:onReduceALLButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", -9999999, true)
    self:tryAddPoint("wiz", "WizAddpointLabel", -9999999, true)
    self:tryAddPoint("str", "StrAddpointLabel", -9999999, true)
    self:tryAddPoint("dex", "DexAddpointLabel", -9999999, true)

    local pet = self.selectPet
    if pet then
        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = pet:getId(),
            type = Const.ASSIGN_POINT_ATTRIB,
            para1 = self.conAdd,
            para2 = self.wizAdd,
            para3 = self.strAdd,
            para4 = self.dexAdd
        })
    end
end

function PetGetAttribDlg:onResisButton(sender, eventType)
 --[[
    local dlg = DlgMgr:openDlg("PetAutoAttribDlg")
    dlg:setAutoAddObject(id)
    gf:sendGeneralNotifyCmd(NOTIFY.GET_RECOMMEND_ATTRIB, id)
    ]]
    local id = self.selectPet:getId()
    local pet = PetMgr:getPetById(id)
    if not pet then return end
    local dlg = DlgMgr:openDlg("PetGetResisDlg")
    dlg:resetInfo(pet)
end

function PetGetAttribDlg:MSG_PRE_ASSIGN_ATTRIB(data)
    local pet = self.selectPet
    if pet == nil or data.id ~= pet:getId() then return end -- 不是这只宠物

    self:setDelta("LifeAddValueLabel", data.max_life_plus)
    self:setDelta("ManaAddValueLabel", data.max_mana_plus)
    self:setDelta("PhyPowerAddValueLabel", data.phy_power_plus)
    self:setDelta("MagPowerAddValueLabel", data.mag_power_plus)
    self:setDelta("SpeedAddValueLabel", data.speed_plus)
    self:setDelta("DefenceAddValueLabel", data.def_plus)
end

-- 初始化slider信息
function PetGetAttribDlg:initAttriInfo(key)
    local level = self.selectPet:queryBasicInt("level")

    if key == "con" then
        local curConValue = self.selectPet:queryBasicInt(key)
        self:setAttribValue("Con", 0, false)
        self.curPointTable.ConCurPoint = curConValue - level
    elseif key == "wiz" then
        local curWizValue = self.selectPet:queryBasicInt(key)
        self:setAttribValue("Wiz", 0, false)
        self.curPointTable.WizCurPoint = curWizValue - level
    elseif key == "str" then
        local curStrValue = self.selectPet:queryBasicInt(key)
        self:setAttribValue("Str", 0, false)
        self.curPointTable.StrCurPoint = curStrValue - level
    elseif key == "dex" then
        local curDexValue = self.selectPet:queryBasicInt(key)
        self:setAttribValue("Dex", 0, false)
        self.curPointTable.DexCurPoint = curDexValue - level
    end
end

function PetGetAttribDlg:setAttribValue(typeTitle, value, isShowTip)


    if isShowTip == nil then isShowTip = true end

    local totalNum = (self.selectPet:queryBasicInt("level")) * 4
    local level = self.selectPet:queryBasicInt("level")

    -- 换算成总值
    local curValue = 0
    local totalValue = 0
    if typeTitle == "Con" then
        curValue = self.selectPet:queryBasicInt("con") - level + value
        totalValue = self.selectPet:queryInt("con") + value
    elseif typeTitle == "Wiz" then
        curValue = self.selectPet:queryBasicInt("wiz") - level + value
        totalValue = self.selectPet:queryInt("wiz") + value
    elseif typeTitle == "Str" then
        curValue = self.selectPet:queryBasicInt("str") - level + value
        totalValue = self.selectPet:queryInt("str") + value
    elseif typeTitle == "Dex" then
        curValue = self.selectPet:queryBasicInt("dex") - level + value
        totalValue = self.selectPet:queryInt("dex") + value
    end

    self:setAttribButtonGray()

    if value > 0 then
        self:setLabelText(typeTitle .. "AttribValueLabel", totalValue, nil, COLOR3.GREEN)
    elseif value < 0 then
        self:setLabelText(typeTitle .. "AttribValueLabel", totalValue, nil, COLOR3.RED)
    else
        self:setLabelText(typeTitle .. "AttribValueLabel", totalValue, nil, COLOR3.TEXT_DEFAULT)
    end


    self.lastPointTable[typeTitle .. "LastPoint"] = value
    self.lastPercentTable[typeTitle .. "LastPercent"] = percent
end

function PetGetAttribDlg:onConLabel(sender, eventType)
    local panel = sender:getParent()
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("Image", true, panel)
    elseif eventType == ccui.TouchEventType.ended then
        gf:showTipInfo(CHS[2000033], sender)
        self:setCtrlVisible("Image", false, panel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("Image", false, panel)
    end
end

function PetGetAttribDlg:onWizLabel(sender, eventType)
    local panel = sender:getParent()
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("Image", true, panel)
    elseif eventType == ccui.TouchEventType.ended then
        gf:showTipInfo(CHS[2000034], sender)
        self:setCtrlVisible("Image", false, panel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("Image", false, panel)
    end
end

function PetGetAttribDlg:onStrLabel(sender, eventType)
    local panel = sender:getParent()
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("Image", true, panel)
    elseif eventType == ccui.TouchEventType.ended then
        gf:showTipInfo(CHS[2000035], sender)
        self:setCtrlVisible("Image", false, panel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("Image", false, panel)
    end
end

function PetGetAttribDlg:onDexLabel(sender, eventType)
    local panel = sender:getParent()
    if eventType == ccui.TouchEventType.began then
        self:setCtrlVisible("Image", true, panel)
    elseif eventType == ccui.TouchEventType.ended then
        gf:showTipInfo(CHS[2000036], sender)
        self:setCtrlVisible("Image", false, panel)
    elseif eventType == ccui.TouchEventType.canceled then
        self:setCtrlVisible("Image", false, panel)
    end
end

function PetGetAttribDlg:MSG_UPDATE(data)
    if self.selectPet then
        local id = self.selectPet:getId()
        self:setPetInfo(PetMgr:getPetById(id))
    end
end

function PetGetAttribDlg:MSG_SET_OWNER()
    self:updateAllPetInfo()
end

function PetGetAttribDlg:MSG_UPDATE_PETS()
    self:updateAllPetInfo()
end

function PetGetAttribDlg:MSG_SAFE_LOCK_OPEN_UNLOCK()
    -- 若需要验证安全锁，则应该把被置灰的确认按钮重新置为可点击
    self:setCtrlEnabled("ConfirmButton", true)
end

return PetGetAttribDlg
