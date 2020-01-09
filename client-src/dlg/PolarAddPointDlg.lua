-- PolarAddPointDlg.lua
-- Created by cheny Jan/05/2015
-- 相性加点界面

local MAX_POLAR_POINT = 30 -- 初始30，地劫任务影响，通过getDefMaxPoint()
local SLIDER_WIDTH = 248
local SLIDER_XPOS = 176

-- para参数映射表
local PARA_POLAR_LIST = {"metal", "wood", "water", "fire", "earth"}

local PolarAddPointDlg = Singleton("PolarAddPointDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

function PolarAddPointDlg:init()
    self:bindListener("AutoAddPointButton", self.onAutoAddPointButton)
    self:bindListener("MetalReduceButton", self.onMetalReduceButton)
    self:bindListener("MetalAddButton", self.onMetalAddButton)
    self:bindListener("WoodReduceButton", self.onWoodReduceButton)
    self:bindListener("WoodAddButton", self.onWoodAddButton)
    self:bindListener("WaterReduceButton", self.onWaterReduceButton)
    self:bindListener("WaterAddButton", self.onWaterAddButton)
    self:bindListener("FireReduceButton", self.onFireReduceButton)
    self:bindListener("FireAddButton", self.onFireAddButton)
    self:bindListener("EarthReduceButton", self.onEarthReduceButton)
    self:bindListener("EarthAddButton", self.onEarthAddButton)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("YijianXiDianButton", self.onYijianXiDianButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("InfoButton_0", self.onLeftInfoButton)

    --[[
    self:bindPress('MetalAddButton', "metal", "MetalAddpointLabel", 1, string.format(CHS[2000047], MAX_POLAR_POINT))
    self:bindPress('WoodAddButton',  "wood",  "WoodAddpointLabel",  1, string.format(CHS[2000047], MAX_POLAR_POINT))
    self:bindPress('WaterAddButton', "water", "WaterAddpointLabel", 1, string.format(CHS[2000047], MAX_POLAR_POINT))
    self:bindPress('FireAddButton',  "fire",  "FireAddpointLabel",  1, string.format(CHS[2000047], MAX_POLAR_POINT))
    self:bindPress('EarthAddButton', "earth", "EarthAddpointLabel", 1, string.format(CHS[2000047], MAX_POLAR_POINT))
    --]]

    -- 绑定panel事件
    self:bindSliderPanel(self:getControl("MetalPanel", Const.UIPanel), "Metal", self:getControl("MetalSlider", Const.UISlider))
    self:bindSliderPanel(self:getControl("WoodPanel", Const.UIPanel), "Wood", self:getControl("WoodSlider", Const.UISlider))
    self:bindSliderPanel(self:getControl("WaterPanel", Const.UIPanel), "Water", self:getControl("WaterSlider", Const.UISlider))
    self:bindSliderPanel(self:getControl("FirePanel", Const.UIPanel), "Fire", self:getControl("FireSlider", Const.UISlider))
    self:bindSliderPanel(self:getControl("EarthPanel", Const.UIPanel), "Earth", self:getControl("EarthSlider", Const.UISlider))

    -- 绑定slider事件
    self:bindSliderListener("MetalSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Metal",sender)
            self.isUpdateSlider = true
            self.slider = sender
            self.titleType = "Metal"
        end
    end)
    self:bindSliderListener("WoodSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Wood",sender)
            self.isUpdateSlider = true
            self.slider = sender
            self.titleType = "Wood"
        end
    end)
    self:bindSliderListener("WaterSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Water",sender)
            self.isUpdateSlider = true
            self.slider = sender
            self.titleType = "Water"
        end
    end)
    self:bindSliderListener("FireSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Fire",sender)
            self.isUpdateSlider = true
            self.slider = sender
            self.titleType = "Fire"
        end
    end)
    self:bindSliderListener("EarthSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Earth",sender)
            self.isUpdateSlider = true
            self.slider = sender
            self.titleType = "Earth"
        end
    end)

    -- 绑定tip事件
    self:bindShowTip("MetalPolarNameLabel")
    self:bindShowTip("MetalAttribValueLabel")
    self:bindShowTip("WoodPolarNameLabel")
    self:bindShowTip("WoodAttribValueLabel")
    self:bindShowTip("WaterPolarNameLabel")
    self:bindShowTip("WaterAttribValueLabel")
    self:bindShowTip("FirePolarNameLabel")
    self:bindShowTip("FireAttribValueLabel")
    self:bindShowTip("EarthPolarNameLabel")
    self:bindShowTip("EarthAttribValueLabel")

    self.lastPercentTable = {
                            MetalLastPercent = 0,
                            WoodLastPercent = 0,
                            WaterLastPercent = 0,
                            FireLastPercent = 0,
                            EarthLastPercent = 0,
                            }
    self.curPointTable = {
                            MetalCurPoint = 0,
                            WoodCurPoint = 0,
                            WaterCurPoint = 0,
                            FireCurPoint = 0,
                            EarthCurPoint = 0,
                         }

    self.slider = nil
    self.titleType = nil
    self.isUpdateSlider = false
    self.needRefreshFlag = false

    self:initSlider()

    self:setCtrlVisible('CostInfoPanel', false)
    self:setCtrlVisible('FreeTipLabel', false)
    self:resetInfo()
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg('MSG_PRE_ASSIGN_ATTRIB')
    self:hookMsg("MSG_SEND_RECOMMEND_POLAR")

    self.costNumber = 0

    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_POLAR,
        para1 = 0,
        para2 = 0,
        para3 = 0,
        para4 = 0
    })
end



-- 初始化slider的位置
function PolarAddPointDlg:initSlider()
    self:setSliderPercent("Metal", 0, false)
    self:setSliderPercent("Wood", 0, false)
    self:setSliderPercent("Water", 0, false)
    self:setSliderPercent("Fire", 0, false)
    self:setSliderPercent("Earth", 0, false)
end

function PolarAddPointDlg:onUpdate()
    if self.dirty == true then
        self:resetInfo()
        self:onResetButton()
        self.dirty = false
    end

    if self.isUpdateSlider then
        self.isUpdateSlider = false

        if self.titleType and self.slider then
            self:onSliderChange(self.titleType, self.slider)
            self.titleType = nil
            self.slider = nil
        end

    end
end

-- 获取单个最大加点（飞升额外相性点 + 最大相性点）
function PolarAddPointDlg:getDefMaxPoint()
    return Me:queryBasicInt("upgrade/max_polar_extra") + MAX_POLAR_POINT
end

-- 获取可分配的点数最大值
function PolarAddPointDlg:getMaxPoint()
    local level = Me:queryBasicInt("level")
    local maxNum = math.floor((level - 1) / 2) + Me:queryBasicInt("dan_data/attrib_point")
    return math.min(self:getDefMaxPoint(), maxNum)
end

function PolarAddPointDlg:setAttribPoint(ctrlName, attrib, isNotSetTable)
    local value = Me:queryInt(attrib)
    local color = COLOR3.TEXT_DEFAULT
    if value > Me:queryBasicInt(attrib) then
        color = COLOR3.BLUE
    end

    self:setLabelText(ctrlName, tostring(value), nil, color)

    if not isNotSetTable then
        if attrib == "metal" then
            self.curPointTable.MetalCurPoint = value
            self:setSliderPercent("Metal", 0, false)
        elseif attrib == "wood" then
            self.curPointTable.WoodCurPoint = value
            self:setSliderPercent("Wood", 0, false)
        elseif attrib == "water" then
            self.curPointTable.WaterCurPoint = value
            self:setSliderPercent("Water", 0, false)
        elseif attrib == "fire" then
            self.curPointTable.FireCurPoint = value
            self:setSliderPercent("Fire", 0, false)
        elseif attrib == "earth" then
            self.curPointTable.EarthCurPoint = value
            self:setSliderPercent("Earth", 0, false)
        end
    end
end

function PolarAddPointDlg:resetInfo()
    self.yiJianXiDian = 0
    self.polarPoint = Me:queryInt("polar_point")
    self.metalAdd = 0
    self.woodAdd = 0
    self.waterAdd = 0
    self.fireAdd = 0
    self.earthAdd = 0

    self:setLabelText("PolarPointValueLabel", self.polarPoint) -- 相性点数

    -- 单属性上限
    self:setLabelText("PolarLimitLabel", CHS[4100583])
    self:setLabelText("PolarLimitValueLabel", self:getDefMaxPoint())

    self:setAttribPoint("MetalAttribValueLabel", "metal", true)
    self:setAttribPoint("WoodAttribValueLabel", "wood", true)
    self:setAttribPoint("WaterAttribValueLabel", "water", true)
    self:setAttribPoint("FireAttribValueLabel", "fire", true)
    self:setAttribPoint("EarthAttribValueLabel", "earth", true)

    self:setLabelText("MetalAddpointLabel", "")
    self:setLabelText("WoodAddpointLabel", "")
    self:setLabelText("WaterAddpointLabel", "")
    self:setLabelText("FireAddpointLabel", "")
    self:setLabelText("EarthAddpointLabel", "")
    self:setButtonGray()
    self:updateCost()

    local metalValuePanel = self:getControl("MetalValuePanel", Const.UIPanel)
    local woodValuePanel = self:getControl("WoodValuePanel", Const.UIPanel)
    local waterlValuePanel = self:getControl("WaterValuePanel", Const.UIPanel)
    local fireValuePanel = self:getControl("FireValuePanel", Const.UIPanel)
    local earthValuePanel = self:getControl("EarthValuePanel", Const.UIPanel)

    self:setCtrlVisible("TipImage", false, metalValuePanel)
    self:setCtrlVisible("TipImage", false, woodValuePanel)
    self:setCtrlVisible("TipImage", false, waterlValuePanel)
    self:setCtrlVisible("TipImage", false, fireValuePanel)
    self:setCtrlVisible("TipImage", false, earthValuePanel)

    self:resetSliderImage("Metal")
    self:resetSliderImage("Wood")
    self:resetSliderImage("Water")
    self:resetSliderImage("Fire")
    self:resetSliderImage("Earth")

    DlgMgr:sendMsg("UserInfoChildDlg", "resetInfo")
end

function PolarAddPointDlg:updateCost()
    local point = 0
    if self.metalAdd < 0 then point = point - self.metalAdd end
    if self.woodAdd  < 0 then point = point - self.woodAdd  end
    if self.waterAdd < 0 then point = point - self.waterAdd end
    if self.fireAdd  < 0 then point = point - self.fireAdd  end
    if self.earthAdd < 0 then point = point - self.earthAdd end

    local number = 0
    if SkillMgr:isLeardedSkill() then
        if point > 0 and not self.isFree then
            number = Formula:getPolarCost(point)
            self.costNumber = math.floor(number)
        else
            self.costNumber = 0
        end
    else
        if point > 0 then
            number = Formula:getPolarCost(point)
            self.costNumber = math.floor(number)
        else
            self.costNumber = 0
        end
    end

    self:setLabelText("CostLabel", math.floor(number))

    self:updateLayout("CostPanel")
    self:updateLayout("MetalValuePanel")
    self:updateLayout("WoodValuePanel")
    self:updateLayout("WaterValuePanel")
    self:updateLayout("FireValuePanel")
    self:updateLayout("EarthValuePanel")
end

function PolarAddPointDlg:setButtonGray()
    local able = self.polarPoint > 0
    self:setCtrlEnabled("MetalAddButton", able)
    self:setCtrlEnabled("WoodAddButton", able)
    self:setCtrlEnabled("WaterAddButton", able)
    self:setCtrlEnabled("FireAddButton", able)
    self:setCtrlEnabled("EarthAddButton", able)

    able =  self.metalAdd ~= 0 or
        self.woodAdd  ~= 0 or
        self.waterAdd ~= 0 or
        self.fireAdd  ~= 0 or
        self.earthAdd ~= 0
    self:setCtrlEnabled("ResetButton", able)
    self:setCtrlEnabled("ConfirmButton", able)

    local min = 0 -- 最小可以洗到0
    able =  Me:queryBasicInt("metal") + self.metalAdd > min or
        Me:queryBasicInt("wood")  + self.woodAdd  > min or
        Me:queryBasicInt("water") + self.waterAdd > min or
        Me:queryBasicInt("fire")  + self.fireAdd  > min or
        Me:queryBasicInt("earth") + self.earthAdd > min
    self:setCtrlEnabled("YijianXiDianButton", able)
end

function PolarAddPointDlg:tryAddPoint(key, addLabel, delta, noGrayButton, isNotCmd, isShowTips)
    local min = 0
    local value = self[key.."Add"]
    if value == nil then return false end

    -- 修正加点值
    if self.polarPoint < delta then delta = self.polarPoint end
    if Me:queryBasicInt(key) + value + delta < min then
        delta = min - Me:queryBasicInt(key) - value
    elseif Me:queryBasicInt(key) + value + delta > self:getDefMaxPoint() then
        delta = self:getDefMaxPoint() - (Me:queryBasicInt(key) + value)
    end

    if delta == 0 then return false end

    -- 显示加点
    value = value + delta
    if value + Me:queryBasicInt(key) > self:getDefMaxPoint() then return false end

    self[key.."Add"] = value
    self.polarPoint = self.polarPoint - delta
    self:setLabelText("PolarPointValueLabel", self.polarPoint)

    -- 设置颜色
    local ctl = self:getControl(addLabel)
    if ctl ~= nil then
        if value > 0 then
            ctl:setColor(COLOR3.GREEN)
            ctl:setString("+"..value)
        elseif value < 0 then
            ctl:setColor(COLOR3.RED)
            ctl:setString(tostring(value))
        else
            ctl:setString("")
        end
    end

    if key == "metal" then
        self:setSliderPercent("Metal", value, isShowTips)
    elseif key == "wood" then
        self:setSliderPercent("Wood", value, isShowTips)
    elseif key == "water" then
        self:setSliderPercent("Water", value, isShowTips)
    elseif key == "fire" then
        self:setSliderPercent("Fire", value, isShowTips)
    elseif key == "earth" then
        self:setSliderPercent("Earth", value, isShowTips)
    end



    if not noGrayButton then
        self:setButtonGray()
    end

    self:updateCost()

    if not isNotCmd then
        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = 0,
            type = Const.ASSIGN_POINT_POLAR,
            para1 = self.metalAdd,
            para2 = self.woodAdd ,
            para3 = self.waterAdd,
            para4 = self.fireAdd ,
            para5 = self.earthAdd,
        })
    end

    return true
end

-- 绑定悬浮窗
function PolarAddPointDlg:bindShowTip(ctrlName)
    local onTouched = function(self, sender, type)
        local name = sender:getName()

        if name == "MetalPolarNameLabel" or name == "MetalAttribValueLabel" then
            gf:showTipInfo(CHS[3003477], sender)
        elseif name == "WoodPolarNameLabel" or name == "WoodAttribValueLabel" then
            gf:showTipInfo(CHS[3003478], sender)
        elseif name == "WaterPolarNameLabel" or name == "WaterAttribValueLabel" then
            gf:showTipInfo(CHS[3003479], sender)
        elseif name == "FirePolarNameLabel" or name == "FireAttribValueLabel" then
            gf:showTipInfo(CHS[3003480], sender)
        elseif name == "EarthPolarNameLabel" or name == "EarthAttribValueLabel" then
            gf:showTipInfo(CHS[3003481], sender)
        end

    end

    local ctrl = self:getControl(ctrlName)
    local parent = ctrl:getParent()
    ctrl:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self:setCtrlVisible("TouchImage", true, parent)
        elseif eventType == ccui.TouchEventType.moved then
        elseif eventType == ccui.TouchEventType.ended then
            self:setCtrlVisible("TouchImage", false, parent)
            onTouched(self, sender, ccui.TouchEventType.ended)
        elseif eventType == ccui.TouchEventType.canceled then
            self:setCtrlVisible("TouchImage", false, parent)
        end
    end)
    self:setCtrlVisible("TouchImage", false, parent)
end

function PolarAddPointDlg:onAutoAddPointButton(sender, eventType)
    local level = Me:queryBasicInt("level")
    if level < 10 then
        gf:ShowSmallTips(CHS[3003758])
        return
    end

    -- 向服务器请求预加点方案
    gf:CmdToServer("CMD_GENERAL_NOTIFY", { type = NOTIFY.GET_RECOMMEND_POLAR })
    self.need_open = true
end

function PolarAddPointDlg:onMetalReduceButton(sender, eventType)
    if not self:tryAddPoint("metal", "MetalAddpointLabel", -1, false, false) then
        gf:ShowSmallTips(CHS[2000041])
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onMetalAddButton(sender, eventType)
    if not self:tryAddPoint("metal", "MetalAddpointLabel", 1, false, false) then
        gf:ShowSmallTips(string.format(CHS[2000047], self:getDefMaxPoint()))
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onWoodReduceButton(sender, eventType)
    if not self:tryAddPoint("wood", "WoodAddpointLabel", -1, false, false) then
        gf:ShowSmallTips(CHS[2000041])
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onWoodAddButton(sender, eventType)
    if not self:tryAddPoint("wood", "WoodAddpointLabel", 1, false, false) then
        gf:ShowSmallTips(string.format(CHS[2000047], self:getDefMaxPoint()))
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onWaterReduceButton(sender, eventType)
    if not self:tryAddPoint("water", "WaterAddpointLabel", -1, false, false) then
        gf:ShowSmallTips(CHS[2000041])
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onWaterAddButton(sender, eventType)
    if not self:tryAddPoint("water", "WaterAddpointLabel", 1, false, false) then
        gf:ShowSmallTips(string.format(CHS[2000047], self:getDefMaxPoint()))
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onFireReduceButton(sender, eventType)
    if not self:tryAddPoint("fire", "FireAddpointLabel", -1, false, false) then
        gf:ShowSmallTips(CHS[2000041])
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onFireAddButton(sender, eventType)
    if not self:tryAddPoint("fire", "FireAddpointLabel", 1, false, false) then
        gf:ShowSmallTips(string.format(CHS[2000047], self:getDefMaxPoint()))
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onEarthReduceButton(sender, eventType)
    if not self:tryAddPoint("earth", "EarthAddpointLabel", -1, false, false) then
        gf:ShowSmallTips(CHS[2000041])
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onEarthAddButton(sender, eventType)
    if not self:tryAddPoint("earth", "EarthAddpointLabel", 1, false, false) then
        gf:ShowSmallTips(string.format(CHS[2000047], self:getDefMaxPoint()))
        return
    end
    self:updateCost()
end

function PolarAddPointDlg:onResetButton(sender, eventType)
    self:resetInfo()

    if SkillMgr:isLeardedSkill() then
        if self.isFree then
            self:setCtrlVisible('CostInfoPanel', true)
            self:setCtrlVisible('CostPanel', false)
            self:setCtrlVisible('FreeTipLabel', true)
        else
            self:setCtrlVisible('CostPanel', false)
            self:setCtrlVisible('FreeTipLabel', false)
        end
    else
        self:setCtrlVisible('CostInfoPanel', true)
        self:setCtrlVisible('CostPanel', false)
        self:setCtrlVisible('FreeTipLabel_1', true)
        self:setCtrlVisible('FreeTipLabel', false)
    end

    self:setSliderPercent("Metal", 0, false)
    self:setSliderPercent("Wood", 0, false)
    self:setSliderPercent("Water", 0, false)
    self:setSliderPercent("Fire", 0, false)
    self:setSliderPercent("Earth", 0, false)
end

function PolarAddPointDlg:resetPoint(cost)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local level = Me:queryBasicInt("level")
    if level < 10 then
        gf:ShowSmallTips(CHS[3003758])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003483])
        return
    end

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("resetPoint", cost) then
        return
    end

    if  self.metalAdd == 0 and
        self.woodAdd  == 0 and
        self.waterAdd == 0 and
        self.fireAdd  == 0 and
        self.earthAdd == 0
    then return end

    gf:CmdToServer("CMD_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_POLAR,
        para1 = self.metalAdd,
        para2 = self.woodAdd ,
        para3 = self.waterAdd,
        para4 = self.fireAdd ,
        para5 = self.earthAdd,
        para6 = 1,
    })

    -- 如果玩家钱不够，直接返回
    if cost > Me:getTotalCoin() then
        return
    end

    self:setCtrlVisible('CostInfoPanel', false)
    self:setCtrlVisible('FreeTipLabel', false)

    -- 需要刷新界面，不能使用self.dirty，因为该标记会在onUpdate中下一帧自动刷新，导致界面闪一下
    -- 所以需要在此加标记，服务器数据回来后，再刷新
    self.needRefreshFlag = true

    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_POLAR,
        para1 = 0,
        para2 = 0,
        para3 = 0,
        para4 = 0
    })
end

function PolarAddPointDlg:onConfirmButton(sender, eventType)
    local cost = self.costNumber
    if cost > 0 then
        -- 判断是否处于公示期
        if Me:isInTradingShowState() then
            gf:ShowSmallTips(CHS[4300227])
            return
        end

        gf:confirm(string.format(CHS[4300263], cost), function ()
            self:resetPoint(cost)
        end)
    else
        self:resetPoint(cost)
    end
end

function PolarAddPointDlg:onLeftInfoButton(sender, eventType)
    DlgMgr:openDlg("XiangXinDlg")
end

function PolarAddPointDlg:onInfoButton(sender, eventType)
    local babyType = CHS[4100560]
    if Me:getChildName() == CHS[4100561] then babyType = CHS[4100561] end
    local retStr = string.format(CHS[4100579], self:getDefMaxPoint(), babyType)

    local str2 = ""
    if Me:getChildType() ~= 0 then

        if Me:getDijieCompletedTimes() >= Const.DIJIE_TASK_MAX then   -- 地劫任务全部完成
            local tianjieTimes = Me:getTianjieCompletedTimes()
            if tianjieTimes >= 0 and Me:hasBreakLevelLimit() then
                if tianjieTimes >= Const.TIANJIE_TASK_MAX  then
                    str2 = string.format(CHS[5400474], babyType)
                else
                    str2 = string.format(CHS[5400473], babyType, TIANJIE_TASK_LEVEL[tianjieTimes + 1].min, gf:changeNumber(tianjieTimes + 1))
                end
            else
                str2 = string.format(CHS[4100580], babyType)
            end
        else
            str2 = string.format(CHS[4100581], babyType, DIJIE_TASK_LEVEL[Me:getDijieCompletedTimes() + 1].min, gf:changeNumber(Me:getDijieCompletedTimes() + 1))
        end
    else
        str2 = CHS[4100582]
    end
    retStr = retStr .. str2

    -- 内丹修炼增加相性点
        retStr = retStr .. CHS[7100154]

    gf:showTipInfo(retStr, sender)
end

function PolarAddPointDlg:onYijianXiDianButton(sender, eventType)

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003483])
        return
    end

    self:tryAddPoint("metal", "MetalAddpointLabel", -9999999)
    self:tryAddPoint("wood", "WoodAddpointLabel", -9999999)
    self:tryAddPoint("water", "WaterAddpointLabel", -9999999)
    self:tryAddPoint("fire", "FireAddpointLabel", -9999999)
    self:tryAddPoint("earth", "EarthAddpointLabel", -9999999)
    self.yiJianXiDian = 1
end

function PolarAddPointDlg:bindPress(name, key, addLabel, delta, tips)
    local widget = self:getControl(name)

    if not widget then
        Log:W("UserAddPointDlg:bindListViewListener no control " .. name)
        return
    end

    local function updataValue()
        self.yiJianXiDian = 0
        if self.touchStatus == TOUCH_BEGAN  then
            if not self:tryAddPoint(key, addLabel, delta, true) then
                if self.needShowTips then
                    self.needShowTips = false
                    local v = Me:queryBasicInt(key) + self[key .. 'Add']
                    if v >= self:getDefMaxPoint() then
                        gf:ShowSmallTips(tips)
                    end
                end
            end
        elseif self.touchStatus == TOUCH_END then
        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.needShowTips = true
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , updataValue, 0.2)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataValue()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
            self:setButtonGray()
            self.needShowTips = false
        end
    end

    widget:addTouchEventListener(listener)
end

-- 是否需要刷新界面(用于服务器刷新界面数据)
function PolarAddPointDlg:needRefreshDlg()
    if self.polarPoint + self.metalAdd + self.woodAdd + self.waterAdd
        + self.fireAdd + self.earthAdd ~= Me:queryInt("polar_point")
        or self.needRefreshFlag then
        -- 剩余相性点数有变化

        self.needRefreshFlag = false
        return true
    end

    return false
end

function PolarAddPointDlg:MSG_UPDATE(data)
    if data.id == Me:getId() then
        if self:needRefreshDlg() then
            self.dirty = true
        else
            DlgMgr:sendMsg("UserInfoChildDlg", "resetInfo", true)
        end
    end
end

function PolarAddPointDlg:MSG_UPDATE_IMPROVEMENT(data)
    if self:needRefreshDlg() then
        self.dirty = true
    end
end

function PolarAddPointDlg:MSG_SEND_RECOMMEND_POLAR(data)
    if data.id ~= 0 then return end

    if self.need_open == true then
        DlgMgr:openDlg("PolarAutoAddPointDlg")
        DlgMgr:sendMsg("PolarAutoAddPointDlg", 'MSG_SEND_RECOMMEND_POLAR', data)
        self.need_open = false
    else
        if data.auto_add == 1 then
            self:setSliderPercent("Metal", 0, false)
            self:setSliderPercent("Wood", 0, false)
            self:setSliderPercent("Water", 0, false)
            self:setSliderPercent("Fire", 0, false)
            self:setSliderPercent("Earth", 0, false)
            self:resetInfo()
            self:preAutoAddPoint(data)
        end

    end

end

-- 自动分配点数
function PolarAddPointDlg:preAutoAddPoint(data)

    local polarList = self:getAutoAssignPolorList(data)
    self.polarPoint = Me:queryInt("polar_point")

    self:setLabelText("MetalAddpointLabel", "")
    self:setLabelText("WoodAddpointLabel", "")
    self:setLabelText("WaterAddpointLabel", "")
    self:setLabelText("FireAddpointLabel", "")
    self:setLabelText("EarthAddpointLabel", "")

    self.metalAdd = 0
    self.woodAdd = 0
    self.waterAdd = 0
    self.fireAdd = 0
    self.earthAdd = 0

    for k, v in pairs(polarList) do
        local changePoint = self.polarPoint

        if changePoint > self:getDefMaxPoint() then
            changePoint = self:getDefMaxPoint()
        end

        if v == "metal" then
            self:tryAddPoint("metal", "MetalAddpointLabel", changePoint, false, true)
        elseif v == "wood" then
            self:tryAddPoint("wood", "WoodAddpointLabel", changePoint, false, true)
        elseif v == "water" then
            self:tryAddPoint("water", "WaterAddpointLabel", changePoint, false, true)
        elseif v == "fire" then
            self:tryAddPoint("fire", "FireAddpointLabel", changePoint, false, true)
        elseif v == "earth" then
            self:tryAddPoint("earth", "EarthAddpointLabel", changePoint, false, true)
        end
    end
    self:setLabelText("PolarPointValueLabel", self.polarPoint)

    -- 单属性上限
    self:setLabelText("PolarLimitLabel", CHS[4100583])
    self:setLabelText("PolarLimitValueLabel", self:getDefMaxPoint())

    self:updateCost()

    -- 发送预加点，计算数值变化
    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_POLAR,
        para1 = self.metalAdd,
        para2 = self.woodAdd ,
        para3 = self.waterAdd,
        para4 = self.fireAdd ,
        para5 = self.earthAdd,
    })
end

function PolarAddPointDlg:getAutoAssignPolorList(data)
    local polarList = {}

    for i = 1, 5 do
        table.insert(polarList, i, PARA_POLAR_LIST[data["para"..i]])
    end

    return polarList
end

function PolarAddPointDlg:hideAllTips()
    self:setCtrlVisible("TipImage", false, "MetalValuePanel")
    self:setCtrlVisible("TipImage", false, "WoodValuePanel")
    self:setCtrlVisible("TipImage", false, "WaterValuePanel")
    self:setCtrlVisible("TipImage", false, "FireValuePanel")
    self:setCtrlVisible("TipImage", false, "EarthValuePanel")
end

function PolarAddPointDlg:MSG_PRE_ASSIGN_ATTRIB(data)
    self:hideAllTips()
    if data.id ~= 0 then return end -- 不是自己

    if data.type ~= Const.ASSIGN_POINT_POLAR then return end

    local free = (data.free == 1)
    self.free = free

    if SkillMgr:isLeardedSkill() then
        self:setCtrlVisible('CostInfoPanel', true)
        self:setCtrlVisible('CostPanel', not free)
        self:setCtrlVisible('FreeTipLabel', free)
        self:setCtrlVisible('FreeTipLabel_1', false)

        if not free then
            if self.costNumber == 0 then
                self:setCtrlVisible('CostPanel', false)
                self:setCtrlVisible('FreeTipLabel', false)
            end
        end
    else
        self:setCtrlVisible('CostInfoPanel', true)
        self:setCtrlVisible('CostPanel', true)
        self:setCtrlVisible('FreeTipLabel', false)
        self:setCtrlVisible('FreeTipLabel_1', false)

        if self.costNumber == 0 then
            self:setCtrlVisible('CostPanel', false)
            self:setCtrlVisible('FreeTipLabel', false)
            self:setCtrlVisible('FreeTipLabel_1', true)
        end
    end

end


function PolarAddPointDlg:setSliderPercent(typeTitle, value, isShowTip)
    local valuePanel = self:getControl(typeTitle.."ValuePanel", Const.UIPanel)
    local slider = self:getControl(typeTitle.."Slider", Const.UISlider)
    local tipImage = self:getControl("TipImage", Const.UIImage, valuePanel)
    local tipLabel = self:getControl("TipLabel", Const.UILabel, tipImage)

    local percent = slider:getPercent()
    if not isShowTip then
        tipImage:setVisible(false)
    else
        tipImage:setVisible(true)
    end

    local totalNum = self:getMaxPoint()

    -- 换算成总值
    local curValue = 0
    local perValue = 0

    if typeTitle == "Metal" then
        curValue = Me:queryInt("metal") + value
        perValue = Me:queryBasicInt("metal") + value
    elseif typeTitle == "Wood" then
        curValue = Me:queryInt("wood") + value
        perValue = Me:queryBasicInt("wood") + value
    elseif typeTitle == "Water" then
        curValue = Me:queryInt("water") + value
        perValue = Me:queryBasicInt("water") + value
    elseif typeTitle == "Fire" then
        curValue = Me:queryInt("fire") + value
        perValue = Me:queryBasicInt("fire") + value
    elseif typeTitle == "Earth" then
        curValue = Me:queryInt("earth") + value
        perValue = Me:queryBasicInt("earth") + value
    end

    local percent = 0
    if totalNum > 0 then
        percent = perValue / totalNum * 100
    end

    if percent > 100 then
        percent = 100
        return
    end

    local sX, sY = tipImage:getPosition()
    sX = (SLIDER_WIDTH / 100) * percent + SLIDER_XPOS
    tipImage:setPosition(sX, sY)

    if value >= 0 then
        self:setLabelText("TipLabel", "+"..value, tipImage)
    else
        self:setLabelText("TipLabel", value, tipImage)
    end
    slider:setPercent(percent)

    local panel = self:getControl(typeTitle .. "ValuePanel", Const.Panel)

    if value >= 0 then
        slider:loadProgressBarTexture(ResMgr.ui.progress_green_bar)
        slider:loadSlidBallTextures(ResMgr.ui.progress_yellow_button,
            ResMgr.ui.progress_yellow_button,
            ResMgr.ui.progress_yellow_button)
        self:setImage("SliderImage", ResMgr.ui.progress_green_bar, panel)
    else
        slider:loadProgressBarTexture(ResMgr.ui.progress_red_bar)
        slider:loadSlidBallTextures(ResMgr.ui.progress_red_button,
            ResMgr.ui.progress_red_button,
            ResMgr.ui.progress_red_button)
        self:setImage("SliderImage", ResMgr.ui.progress_red_bar, panel)
    end

    self:setLabelText(typeTitle.."AttribValueLabel", curValue)
    self.lastPercentTable[typeTitle.."LastPercent"] = percent
end


function PolarAddPointDlg:resetSliderImage(titleType)
    local slider = self:getControl(titleType.."Slider")
    local panel = self:getControl(titleType .. "ValuePanel", Const.Panel)
    slider:loadProgressBarTexture(ResMgr.ui.progress_green_bar)
    slider:loadSlidBallTextures(ResMgr.ui.progress_yellow_button,
        ResMgr.ui.progress_yellow_button,
        ResMgr.ui.progress_yellow_button)
    self:setImage("SliderImage", ResMgr.ui.progress_green_bar, panel)
end


-- slider逻辑处理
function PolarAddPointDlg:onSliderChange(typeTitle, sender)
    if nil == typeTitle or nil == sender then return end

    local totalNum = self:getMaxPoint()
    local percent = sender:getPercent()
    local changePercent = percent - self.lastPercentTable[typeTitle.."LastPercent"]

    local changePoint = 0
    if changePercent >= 0 then
        -- 增加容错量(0.05)，避免“滑动到无法再向左/右滑动时有可能changePoint不足一点”的情况发生
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05)
    else
        changePercent = changePercent * -1
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05) * -1
    end

    local slider = self:getControl(typeTitle.."Slider")

    if changePoint > 0 then
        if changePoint > self.polarPoint then
            if self.polarPoint > 0 then
                changePoint = self.polarPoint
                percent = self.lastPercentTable[typeTitle.."LastPercent"] + changePoint * 100 / totalNum
                slider:setPercent(percent)
                self.lastPercentTable[typeTitle.."LastPercent"] = percent
            elseif self.polarPoint == 0 then
                slider:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
            end
        end
    elseif changePoint == 0 then
        slider:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
        return
    end

    local key = ""
    local addLabel = ""
    local curValue = 0


    if typeTitle == "Metal" then
        key = "metal"
        addLabel = "MetalAddpointLabel"
    elseif typeTitle == "Wood" then
        key = "wood"
        addLabel = "WoodAddpointLabel"
    elseif typeTitle == "Water" then
        key = "water"
        addLabel = "WaterAddpointLabel"
    elseif typeTitle == "Fire" then
        key = "fire"
        addLabel = "FireAddpointLabel"
    elseif typeTitle == "Earth" then
        key = "earth"
        addLabel = "EarthAddpointLabel"
    end

    self:tryAddPoint(key, addLabel, changePoint, false, true, true)

end

-- 为每一个slider父节点Panel 添加一个touched事件
function PolarAddPointDlg:bindSliderPanel(node, type, slider)

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = node:getParent():convertToNodeSpace(touch:getLocation())

        if not node:isVisible() then
            return false
        end

        local box = node:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        return false
    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

        return true

    end

    local function onTouchEnd(touch, event)
        local metalValuePanel = self:getControl("MetalValuePanel", Const.UIPanel)
        local woodValuePanel = self:getControl("WoodValuePanel", Const.UIPanel)
        local waterlValuePanel = self:getControl("WaterValuePanel", Const.UIPanel)
        local fireValuePanel = self:getControl("FireValuePanel", Const.UIPanel)
        local earthValuePanel = self:getControl("EarthValuePanel", Const.UIPanel)

        self:setCtrlVisible("TipImage", false, metalValuePanel)
        self:setCtrlVisible("TipImage", false, woodValuePanel)
        self:setCtrlVisible("TipImage", false, waterlValuePanel)
        self:setCtrlVisible("TipImage", false, fireValuePanel)
        self:setCtrlVisible("TipImage", false, earthValuePanel)

        -- WDSY-23444 玩家长按，鼠标释放后，slider可能还在滑动，导致属性值不对，所以在鼠标释放后应停止slider变化
        if self.isUpdateSlider then
            self:onSliderChange(self.titleType, self.slider)
            self.isUpdateSlider = true
            self.slider = nil
            self.titleType = nil
        end

        self:updateCost()

        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = 0,
            type = Const.ASSIGN_POINT_POLAR,
            para1 = self.metalAdd,
            para2 = self.woodAdd ,
            para3 = self.waterAdd,
            para4 = self.fireAdd ,
            para5 = self.earthAdd,
        })
        return true
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = node:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

return PolarAddPointDlg
