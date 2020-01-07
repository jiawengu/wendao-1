-- UserAddPointDlg.lua
-- Created by cheny Dec/18/2014
-- 角色加点界面

local UserAddPointDlg = Singleton("UserAddPointDlg", Dialog)

local SLIDER_WIDTH = 248
local SLIDER_XPOS = 117
local TITLE_TYPE = {
    Con = "Con",
    Wiz = "Wiz",
    Str = "Str",
    Dex = "Dex",
}

local TOUCH_BEGAN  = 1
local TOUCH_END    = 2

function UserAddPointDlg:init()
    self:bindListener("AutoAddPointButton", self.onAutoAddPointButton)
    self:bindListener("ConReduceButton", self.onConReduceButton)
    self:bindListener("WizReduceButton", self.onWizReduceButton)
    self:bindListener("StrReduceButton", self.onStrReduceButton)
    self:bindListener("DexReduceButton", self.onDexReduceButton)
    self:bindListener("ResetButton", self.onResetButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("YijianXiDianButton", self.onYijianXiDianButton)
    self:bindListener("InfoButton", self.onInfoButton)

    -- 绑定4个slider事件
    self.conTouchPanel = self:getControl("ConTouchPanel", Const.UIPanel)
    self.wizTouchPanel = self:getControl("WizTouchPanel", Const.UIPanel)
    self.strTouchPanel = self:getControl("StrTouchPanel", Const.UIPanel)
    self.dexTouchPanel = self:getControl("DexTouchPanel", Const.UIPanel)

    -- 绑定4个panel
    self:bindSliderPanel(self.conTouchPanel, TITLE_TYPE.Con, self:getControl("ConSlider", Const.UISlider))
    self:bindSliderPanel(self.wizTouchPanel, TITLE_TYPE.Wiz, self:getControl("WizSlider", Const.UISlider))
    self:bindSliderPanel(self.strTouchPanel, TITLE_TYPE.Str, self:getControl("StrSlider", Const.UISlider))
    self:bindSliderPanel(self.dexTouchPanel, TITLE_TYPE.Dex, self:getControl("DexSlider", Const.UISlider))

    -- 绑定4个slider事件
    self:bindSliderListener("ConSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Con",sender)
            self.titleType = TITLE_TYPE.Con
            self.slider = sender
            self.isUpdateSlider = true
        end
    end)
    self:bindSliderListener("WizSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            self.titleType = TITLE_TYPE.Wiz
            self.slider = sender
            self.isUpdateSlider = true
        end
    end)
    self:bindSliderListener("StrSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            self.titleType = TITLE_TYPE.Str
            self.slider = sender
            self.isUpdateSlider = true
        end
    end)
    self:bindSliderListener("DexSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            self.titleType = TITLE_TYPE.Dex
            self.slider = sender
            self.isUpdateSlider = true
        end
    end)

    -- 绑定tip事件
    self:bindShowTip("ConAttribNameLabel")
    self:bindShowTip("ConAttribValueLabel")
    self:bindShowTip("WizAttribNameLabel")
    self:bindShowTip("WizAttribValueLabel")
    self:bindShowTip("StrAttribNameLabel")
    self:bindShowTip("StrAttribValueLabel")
    self:bindShowTip("DexAttribNameLabel")
    self:bindShowTip("DexAttribValueLabel")

    self.lastPointTable = {ConLastPoint = 0, WizLastPoint = 0, StrLastPoint = 0, DexLastPoint = 0,}
    self.lastPercentTable = {ConLastPercent = 0, WizLastPercent = 0, StrLastPercent = 0, DexLastPercent = 0,}
    self.curPointTable = {ConCurPoint = 0, WizCurPoint = 0, StrCurPoint = 0, DexCurPoint = 0,}

    self:blindPress("ConAddButton", "con", "ConAddpointLabel", 1)
    self:blindPress("WizAddButton", "wiz", "WizAddpointLabel", 1)
    self:blindPress("StrAddButton", "str", "StrAddpointLabel", 1)
    self:blindPress("DexAddButton", "dex", "DexAddpointLabel", 1)
    self:resetInfo()
    self:initSliderInfo("con")
    self:initSliderInfo("wiz")
    self:initSliderInfo("str")
    self:initSliderInfo("dex")

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg("MSG_SEND_RECOMMEND_ATTRIB")
    self:hookMsg("MSG_PRE_ASSIGN_ATTRIB")

    self.isShowCost = false
    self.isUpdateSlider = false
    self.slider = nil
    self.titleType = nil
    self.needRefreshFlag = false

    -- 当前需要消费的金额
    self.costNumber = 0

    --[[
    self:setCtrlVisible("CostInfoPanel", true)
    self:setCtrlVisible('FreeTipLabel', true)
    self:setCtrlVisible('CostPanel', false)
    --]]
    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_ATTRIB,
        para1 = 0,
        para2 = 0,
        para3 = 0,
        para4 = 0
    })
end

-- 为每一个slider父节点Panel 添加一个touched事件
function UserAddPointDlg:bindSliderPanel(node, type, slider)

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
    end

    local function onTouchEnd(touch, event)
        -- WDSY-23444 玩家长按，鼠标释放后，slider可能还在滑动，导致属性值不对，所以在鼠标抬起或取消后刷新slider
        if self.isUpdateSlider then
            self:onSliderChange(self.titleType, self.slider)
            self.isUpdateSlider = true
            self.slider = nil
            self.titleType = nil
        end

        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = 0,
            type = Const.ASSIGN_POINT_ATTRIB,
            para1 = self.conAdd,
            para2 = self.wizAdd,
            para3 = self.strAdd,
            para4 = self.dexAdd
        })

        self:setCtrlVisible("ConTipImage", false)
        self:setCtrlVisible("WizTipImage", false)
        self:setCtrlVisible("StrTipImage", false)
        self:setCtrlVisible("DexTipImage", false)
        self:updateCost()
        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    -- 添加监听
    local dispatcher = node:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

function UserAddPointDlg:onUpdate()
    if self.dirty == true then
        self:resetInfo()
        self:onResetButton()
        self.dirty = false
    end

    if self.isUpdateSlider then
        self.isUpdateSlider = false

        if self.slider and self.titleType then
            self:onSliderChange(self.titleType, self.slider)
            self.titleType = nil
            self.slider = nil
        end

    end
end

function UserAddPointDlg:resetInfo()
    self.yiJianXiDian = 0
    self.attribPoint = Me:queryInt("attrib_point")
    self.conAdd = 0
    self.wizAdd = 0
    self.strAdd = 0
    self.dexAdd = 0
    self:setLabelText("AttribPointValueLabel", self.attribPoint) -- 属性点数
    self.remainAttriPoint = self.attribPoint
    self:setAttribPoint("ConAttribValueLabel", "con") -- 体质
    self:setAttribPoint("WizAttribValueLabel", "wiz") -- 灵力
    self:setAttribPoint("StrAttribValueLabel", "str") -- 力量
    self:setAttribPoint("DexAttribValueLabel", "dex") -- 敏捷
    self:setLabelText("ConAddpointLabel", "")
    self:setLabelText("WizAddpointLabel", "")
    self:setLabelText("StrAddpointLabel", "")
    self:setLabelText("DexAddpointLabel", "")
    self:resetSliderImage("Con")
    self:resetSliderImage("Wiz")
    self:resetSliderImage("Str")
    self:resetSliderImage("Dex")
    self:setButtonGray()
    self:updateCost()
    DlgMgr:sendMsg("UserInfoChildDlg", "resetInfo")
end

function UserAddPointDlg:resetSliderImage(titleType)
    local slider = self:getControl(titleType.."Slider")
    local panel = self:getControl(titleType .. "ValuePanel", Const.Panel)
    slider:loadProgressBarTexture(ResMgr.ui.progress_green_bar)
    slider:loadSlidBallTextures(ResMgr.ui.progress_yellow_button,
        ResMgr.ui.progress_yellow_button,
        ResMgr.ui.progress_yellow_button)
    self:setImage("SliderImage", ResMgr.ui.progress_green_bar, panel)
end

function UserAddPointDlg:setAttribPoint(ctrlName, attrib)
    local value = Me:queryInt(attrib)
    local color = COLOR3.TEXT_DEFAULT
    if value > Me:queryBasicInt(attrib) then
        color = COLOR3.BLUE
    end

    self:setLabelText(ctrlName, tostring(value), nil, color)
end

-- 根据自动加点方案预分配属性值
function UserAddPointDlg:autoPreAssign(con, wiz, str, dex)
    local attribPoint = Me:queryInt("attrib_point")

    local value = math.floor(attribPoint / 4)

    self.attribPoint = attribPoint - 4 * value
    self.remainAttriPoint = self.attribPoint
    self:setLabelText("AttribPointValueLabel", tonumber(self.attribPoint)) -- 属性点数

    self.conAdd = value * con
    self.wizAdd = value * wiz
    self.strAdd = value * str
    self.dexAdd = value * dex

    self:setSliderPercent("Con", self.conAdd, false)
    self:setSliderPercent("Wiz", self.wizAdd, false)
    self:setSliderPercent("Str", self.strAdd, false)
    self:setSliderPercent("Dex", self.dexAdd, false)

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

    self:updateLayout("ConPanel")
    self:updateLayout("WizPanel")
    self:updateLayout("StrPanel")
    self:updateLayout("DexPanel")

    self:setButtonGray()
    self:updateCost()

    -- 发送预加点，计算数值变化
    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_ATTRIB,
        para1 = self.conAdd,
        para2 = self.wizAdd,
        para3 = self.strAdd,
        para4 = self.dexAdd
    })
end

function UserAddPointDlg:tryAddPoint(key, addLabel, delta, noGrayButton, isNotCmd, isShowTips)
    local level = Me:queryBasicInt("level")
    local value = self[key.."Add"]
    if value == nil then return false end
    local curValue = Me:queryBasicInt(key)

    Log:D(">>>> value : " .. value)
    Log:D(">>>> curValue : " .. curValue)

    -- 修正加点值
    if self.remainAttriPoint < delta then delta = self.remainAttriPoint end

    if curValue + value + delta < level then
        delta = level - Me:queryBasicInt(key) - value
    end

    if delta == 0 then
        return false
    end

    -- 显示加点
    value = value + delta
    self[key.."Add"] = value
    self.remainAttriPoint = self.remainAttriPoint - delta
    self:setLabelText("AttribPointValueLabel", self.remainAttriPoint)

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

    -- 设置slider
    if key == "con" then
        self:setSliderPercent("Con", value, isShowTips)
    elseif key == "wiz" then
        self:setSliderPercent("Wiz", value, isShowTips)
    elseif key == "str" then
        self:setSliderPercent("Str", value, isShowTips)
    elseif key == "dex" then
        self:setSliderPercent("Dex", value, isShowTips)
    end



    if not noGrayButton then
        self:setButtonGray()
    end

    self:updateCost()

    if not isNotCmd then
        gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
            id = 0,
            type = Const.ASSIGN_POINT_ATTRIB,
            para1 = self.conAdd,
            para2 = self.wizAdd,
            para3 = self.strAdd,
            para4 = self.dexAdd
        })
    end
    self.isShowCost = true
    return true
end

function UserAddPointDlg:updateCost()
    local point = 0
    if self.conAdd < 0 then point = point - self.conAdd end
    if self.wizAdd < 0 then point = point - self.wizAdd end
    if self.strAdd < 0 then point = point - self.strAdd end
    if self.dexAdd < 0 then point = point - self.dexAdd end

    local number = 0
    if SkillMgr:isLeardedSkill() then
        if point > 0 and not self.isFree then
            number = Formula:getAttribCost(Me:queryBasicInt("level"), point)
            self.costNumber = math.floor(number)
        else
            self.costNumber = 0
        end
    else
        if point > 0 then
            number = Formula:getAttribCost(Me:queryBasicInt("level"), point)
            self.costNumber = math.floor(number)
        else
            self.costNumber = 0
        end
    end

    self:setLabelText("CostLabel", math.floor(number))

    Log:D("The number is " .. number)

    if math.floor(number) == 0 then
        if SkillMgr:isLeardedSkill() then
            if self.isFree then
                self:setCtrlVisible("CostInfoPanel", true)
                self:setCtrlVisible("FreeTipLabel", true)
                self:setCtrlVisible("FreeTipLabel_1", false)
                self:setCtrlVisible('CostPanel', false)
            else
                self:setCtrlVisible("CostInfoPanel", true)
                self:setCtrlVisible("FreeTipLabel", false)
                self:setCtrlVisible("FreeTipLabel_1", false)
                self:setCtrlVisible('CostPanel', false)
            end
        else
            self:setCtrlVisible("CostInfoPanel", true)
            self:setCtrlVisible("FreeTipLabel", false)
            self:setCtrlVisible("FreeTipLabel_1", true)
            self:setCtrlVisible('CostPanel', false)
        end
    else
        self:setCtrlVisible("CostInfoPanel", true)
        self:setCtrlVisible('CostPanel', true)
        self:setCtrlVisible("FreeTipLabel", false)
        self:setCtrlVisible('FreeTipLabel_1', false)
    end

    self:setLabelText("CostLabel", math.floor(number))
    self:updateLayout("CostPanel")
    self:updateLayout("AddPointPanel")

end

function UserAddPointDlg:setButtonGray()
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

    local level = Me:queryBasicInt("level")

    local con =  Me:queryBasicInt("con")
    local wiz = Me:queryBasicInt("wiz")
    local str = Me:queryBasicInt("str")
    local dex = Me:queryBasicInt("dex")

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

    self:setCtrlEnabled("YijianXiDianButton", able)
end

function UserAddPointDlg:onAutoAddPointButton(sender, eventType)
    local level = Me:queryBasicInt("level")
    if level < 10 then
        gf:ShowSmallTips(CHS[3003758])
        return
    end

    -- 向服务器请求预加点方案
    gf:CmdToServer("CMD_GENERAL_NOTIFY", { type = NOTIFY.GET_RECOMMEND_ATTRIB })
    self.need_open = true
end

function UserAddPointDlg:onConReduceButton(sender, eventType)
    if not self:tryAddPoint("con", "ConAddpointLabel", -1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function UserAddPointDlg:onConAddButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", 1)
end

function UserAddPointDlg:onWizReduceButton(sender, eventType)
    if not self:tryAddPoint("wiz", "WizAddpointLabel", -1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function UserAddPointDlg:onWizAddButton(sender, eventType)
    self:tryAddPoint("wiz", "WizAddpointLabel", 1)
end

function UserAddPointDlg:onStrReduceButton(sender, eventType)
    if not self:tryAddPoint("str", "StrAddpointLabel", -1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function UserAddPointDlg:onStrAddButton(sender, eventType)
    self:tryAddPoint("str", "StrAddpointLabel", 1)
end

function UserAddPointDlg:onDexReduceButton(sender, eventType)
    if not self:tryAddPoint("dex", "DexAddpointLabel", -1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function UserAddPointDlg:onDexAddButton(sender, eventType)
    self:tryAddPoint("dex", "DexAddpointLabel", 1)
end

function UserAddPointDlg:onResetButton(sender, eventType)
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

    self:initSliderInfo("con")
    self:initSliderInfo("wiz")
    self:initSliderInfo("str")
    self:initSliderInfo("dex")
end

function UserAddPointDlg:resetPoint(cost)
    local level = Me:queryBasicInt("level")
    if level < 10 then
        gf:ShowSmallTips(CHS[3003758])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003759])
        return
    end

    -- 安全锁判断
    if not GameMgr:IsCrossDist() and self:checkSafeLockRelease("resetPoint", cost) then
        return
    end

    if self.conAdd == 0 and
        self.wizAdd == 0 and
        self.strAdd == 0 and
        self.dexAdd == 0
    then return end

    gf:CmdToServer("CMD_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_ATTRIB,
        para1 = self.conAdd,
        para2 = self.wizAdd,
        para3 = self.strAdd,
        para4 = self.dexAdd,
        para6 = 1,
    })

    -- 如果玩家钱不够，直接返回
    if cost > Me:getTotalCoin() then
        return
    end

    self:setCtrlVisible('CostPanel', false)
    self:setCtrlVisible('FreeTipLabel', false)
    self:setCtrlVisible("ConTipImage", false)
    self:setCtrlVisible("WizTipImage", false)
    self:setCtrlVisible("StrTipImage", false)
    self:setCtrlVisible("DexTipImage", false)
    self.curPointTable.ConCurPoint = self.curPointTable.ConCurPoint + self.conAdd
    self.curPointTable.WizCurPoint = self.curPointTable.WizCurPoint + self.wizAdd
    self.curPointTable.StrCurPoint = self.curPointTable.StrCurPoint + self.strAdd
    self.curPointTable.DexCurPoint = self.curPointTable.DexCurPoint + self.dexAdd

    -- 需要刷新界面，不能使用self.dirty，因为该标记会在onUpdate中下一帧自动刷新，导致界面闪一下
    -- 所以需要在此加标记，服务器数据回来后，再刷新
    self.needRefreshFlag = true

    gf:CmdToServer("CMD_PRE_ASSIGN_ATTRIB", {
        id = 0,
        type = Const.ASSIGN_POINT_ATTRIB,
        para1 = 0,
        para2 = 0,
        para3 = 0,
        para4 = 0
    })
end

function UserAddPointDlg:onConfirmButton(sender, eventType)
    local cost = self.costNumber
    if cost > 0 then
        -- 判断是否处于公示期
        if Me:isInTradingShowState() then
            gf:ShowSmallTips(CHS[4300227])
            return
        end

        gf:confirm(string.format(CHS[4300262], cost), function ()
            self:resetPoint(cost)
        end)
    else
        self:resetPoint(cost)
    end
end

function UserAddPointDlg:getTotalNum()
    -- 可加属性点最大值（基础属性点 + 元婴/血婴额外属性点 + 内丹修炼增加点数）
    local babyPoint = math.floor(Me:queryBasicInt("upgrade/level") / 10) * 2
    local innerPoint = Me:queryBasicInt("dan_data/attrib_point")
    local orginalPoint = (Me:queryBasicInt("level") - 1) * 4
    return babyPoint + orginalPoint + innerPoint
end

function UserAddPointDlg:onInfoButton(sender, eventType)
    local babyType = CHS[4100560]
    if Me:getChildName() == CHS[4100561] then babyType = CHS[4100561] end
    local retStr = string.format(CHS[4100586], babyType)

    local str2 = ""
    if Me:getChildType() ~= 0 then
        local level = Me:queryBasicInt("upgrade/level")
        local addPoint = math.floor(level / 10) * 2
        str2 = string.format(CHS[4100587], babyType, level, addPoint)
    else
        str2 = CHS[4100588]
    end
    retStr = retStr .. str2

    -- 内丹修炼增加属性点
    retStr = retStr .. CHS[7100155]

    -- 洗点折扣提示
    retStr = retStr .. CHS[5420321]

    gf:showTipInfo(retStr, sender)
end

function UserAddPointDlg:onYijianXiDianButton(sender, eventType)
    self:tryAddPoint("con", "ConAddpointLabel", -9999999)
    self:tryAddPoint("wiz", "WizAddpointLabel", -9999999)
    self:tryAddPoint("str", "StrAddpointLabel", -9999999)
    self:tryAddPoint("dex", "DexAddpointLabel", -9999999)
    self.yiJianXiDian = 1
end

function UserAddPointDlg:blindPress(name, key, addLabel, delta)
    local widget = self:getControl(name)

    if not widget then
        Log:W("UserAddPointDlg:bindListViewListener no control " .. name)
        return
    end

    local function updataValue()
        self.yiJianXiDian = 0
        if self.touchStatus == TOUCH_BEGAN  then
            self:tryAddPoint(key, addLabel, delta, true)
        elseif self.touchStatus == TOUCH_END then
        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , updataValue, 0.2)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataValue()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
            self:setButtonGray()
        end
    end

    widget:addTouchEventListener(listener)
end

-- 是否需要刷新界面(用于服务器刷新界面数据)
function UserAddPointDlg:needRefreshDlg()
    if self.remainAttriPoint + self.conAdd + self.wizAdd + self.strAdd + self.dexAdd ~= Me:queryInt("attrib_point")
        or self.needRefreshFlag then
        -- 剩余属性点数有变化

        self.needRefreshFlag = false
        return true
    end

    return false
end

function UserAddPointDlg:MSG_UPDATE(data)
    if data.id == Me:getId() then
        if self:needRefreshDlg() then
            self.dirty = true
        else
            DlgMgr:sendMsg("UserInfoChildDlg", "resetInfo", true)
        end
    end
end

function UserAddPointDlg:MSG_UPDATE_IMPROVEMENT(data)
    if self:needRefreshDlg() then
        self.dirty = true
    end
end

function UserAddPointDlg:MSG_SEND_RECOMMEND_ATTRIB(data)
    if data.id ~= 0 then return end
    if self.need_open == true then
        DlgMgr:openDlg("UserAutoAddPointDlg")
        DlgMgr:sendMsg('UserAutoAddPointDlg', 'MSG_SEND_RECOMMEND_ATTRIB', data)
        self.need_open = false
    end
end

function UserAddPointDlg:hideAllTips()
    self:setCtrlVisible("ConTipImage", false)
    self:setCtrlVisible("WizTipImage", false)
    self:setCtrlVisible("StrTipImage", false)
    self:setCtrlVisible("DexTipImage", false)
end

function UserAddPointDlg:MSG_PRE_ASSIGN_ATTRIB(data)
    self:hideAllTips()
    if data.id ~= 0 then return end -- 不是自己

    if data.type ~= Const.ASSIGN_POINT_ATTRIB then return end

    --if self.isShowCost then
    local free = (data.free == 1)
    self.isFree = free

        --self.isShowCost = false
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
    --end
end

-- 绑定悬浮窗
function UserAddPointDlg:bindShowTip(ctrlName)
    local onTouched = function(self, sender, type)
        local name = sender:getName()

        if name == "ConAttribNameLabel" or name == "ConAttribValueLabel" then
            gf:showTipInfo(CHS[3003760], sender)
        elseif name == "WizAttribNameLabel" or name == "WizAttribValueLabel" then
            gf:showTipInfo(CHS[3003761], sender)
        elseif name == "StrAttribNameLabel" or name == "StrAttribValueLabel" then
            gf:showTipInfo(CHS[3003762], sender)
        elseif name == "DexAttribNameLabel" or name == "DexAttribValueLabel" then
            gf:showTipInfo(CHS[3003763], sender)
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

-- slider逻辑处理
function UserAddPointDlg:onSliderChange(typeTitle, sender)
    if nil == typeTitle or nil == sender then return end

    self.isShowCost = true
    local totalNum = self:getTotalNum()
    local percent = sender:getPercent()
    local changePercent = percent - self.lastPercentTable[typeTitle.."LastPercent"]
    local changePoint = 0

    if changePercent >= 0 then
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05)
    else
        changePercent = changePercent * -1
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05) * -1
    end

    local slider = self:getControl(typeTitle.."Slider", Const.UISlider)

    if changePoint > 0 then
        if changePoint > self.remainAttriPoint then
            if self.remainAttriPoint > 0 then
                changePoint = self.remainAttriPoint
                percent = self.lastPercentTable[typeTitle.."LastPercent"] + changePoint * 100 / totalNum
                slider:setPercent(percent)
                self.lastPercentTable[typeTitle.."LastPercent"] = percent
            elseif self.remainAttriPoint == 0 then
                slider:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
            end
        end
    elseif changePoint == 0 then
        slider:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
        return
    elseif changePoint < 0 then
    end

    local key = ""
    local addLabel = ""
    local curValue = 0


    if typeTitle == "Con" then
        key = "con"
        addLabel = "ConAddpointLabel"
    elseif typeTitle == "Wiz" then
        key = "wiz"
        addLabel = "WizAddpointLabel"
    elseif typeTitle == "Str" then
        key = "str"
        addLabel = "StrAddpointLabel"
    elseif typeTitle == "Dex" then
        key = "dex"
        addLabel = "DexAddpointLabel"
    end

   self:tryAddPoint(key, addLabel, changePoint, false, true, true)

end

-- 初始化slider信息
function UserAddPointDlg:initSliderInfo(key)

    local level = Me:queryBasicInt("level")

    if key == "con" then
        local curConValue = Me:queryBasicInt(key)
        self:setSliderPercent("Con", 0, false)
        self.curPointTable.ConCurPoint = curConValue - level
    elseif key == "wiz" then
        local curWizValue = Me:queryBasicInt(key)
        self:setSliderPercent("Wiz", 0, false)
        self.curPointTable.WizCurPoint = curWizValue - level
    elseif key == "str" then
        local curStrValue = Me:queryBasicInt(key)
        self:setSliderPercent("Str", 0, false)
        self.curPointTable.StrCurPoint = curStrValue - level
    elseif key == "dex" then
        local curDexValue = Me:queryBasicInt(key)
        self:setSliderPercent("Dex", 0, false)
        self.curPointTable.DexCurPoint = curDexValue - level
    end

end

function UserAddPointDlg:setSliderPercent(typeTitle, value, isShowTip)
    local totalNum = self:getTotalNum()
    local level = Me:queryBasicInt("level")

    -- 换算成总值
    local curValue = 0
    local totalValue = 0
    if typeTitle == "Con" then
        curValue = Me:queryBasicInt("con") - level + value
        totalValue = Me:queryInt("con") + value
    elseif typeTitle == "Wiz" then
        curValue = Me:queryBasicInt("wiz") - level + value
        totalValue = Me:queryInt("wiz") + value
    elseif typeTitle == "Str" then
        curValue = Me:queryBasicInt("str") - level + value
        totalValue = Me:queryInt("str") + value
    elseif typeTitle == "Dex" then
        curValue = Me:queryBasicInt("dex") - level + value
        totalValue = Me:queryInt("dex") + value
    end

    local percent = 0

    if totalNum > 0 then
        percent = curValue / totalNum * 100
    end

    if percent > 100 then
        percent = 100
        return
    end

    local sliderTips = self:getControl(typeTitle .. "TipImage", Const.UIImage)
    if not isShowTip then
        sliderTips:setVisible(false)
    else
        sliderTips:setVisible(true)
    end

    sliderTips:setVisible(isShowTip)
    local sX, sY = sliderTips:getPosition()
    sX = (SLIDER_WIDTH / 100) * percent + SLIDER_XPOS
    sliderTips:setPosition(sX, sY)
    local slider = self:getControl(typeTitle.."Slider")

    if value >= 0 then
        self:setLabelText("TipLabel", "+"..value, sliderTips)
    else
        self:setLabelText("TipLabel", value, sliderTips)
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

    self:setButtonGray()

    self:setLabelText(typeTitle.."AttribValueLabel", totalValue)

    self.lastPointTable[typeTitle.."LastPoint"] = value
    self.lastPercentTable[typeTitle.."LastPercent"] = percent
end

return UserAddPointDlg
