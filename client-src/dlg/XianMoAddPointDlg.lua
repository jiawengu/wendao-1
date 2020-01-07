-- XianMoAddPointDlg.lua
-- Created by songcw Nov/15/2017
-- 仙魔加点界面

local XianMoAddPointDlg = Singleton("XianMoAddPointDlg", Dialog)

local SLIDER_WIDTH = 248
local SLIDER_XPOS = 117

local TITLE_TYPE = {
    Xian = "Xian",
    Mo = "Mo",
}

function XianMoAddPointDlg:init()
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("AutoAddPointButton", self.onAutoAddPointButton)
    self:bindListener("ReduceButton", self.onXianReduceButton, "XianValuePanel")
    self:bindListener("AddButton", self.onXianAddButton, "XianValuePanel")
    self:bindListener("ReduceButton", self.onMoReduceButton, "MoValuePanel")
    self:bindListener("AddButton", self.onMoAddButton, "MoValuePanel")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("ResetButton", self.onResetButton)

    self.openAutoFlag = false

    self:initSliderPanel()
    self:onResetButton()

    local babyStr = CHS[4100560]
    if Me:getChildType() == 2 then babyStr = CHS[4100561] end
    self:setLabelText("Label1", string.format(CHS[4100901], babyStr), "RulePanel")
    self:bindFloatPanelListener("XianMoAddPointRulePanel")
    self:bindSliderPanel(self:getControl("XianPanel"))
    self:bindSliderPanel(self:getControl("MoPanel"))

    self:bindSliderListener("Slider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Con",sender)
            self.titleType = TITLE_TYPE.Xian
            self.slider = sender
            self.isUpdateSlider = true
        end
    end, "XianValuePanel")

    self:bindSliderListener("Slider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then
            --self:onSliderChange("Con",sender)
            self.titleType = TITLE_TYPE.Mo
            self.slider = sender
            self.isUpdateSlider = true
        end
    end, "MoValuePanel")

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_RECOMMEND_XMD")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
end

function XianMoAddPointDlg:initSliderPanel()
    self.XianAdd = 0
    self.MoAdd = 0

    -- 提示的旗帜初始位置需要准确
    local xianTipsImage = self:getControl("TipImage", nil, "XianValuePanel")
    xianTipsImage:setVisible(false)

    self.tipsImageInitPosX = self.tipsImageInitPosX or xianTipsImage:getPositionX()

    self:setCtrlVisible("TipImage", false, "XianValuePanel")
    self:setCtrlVisible("TipImage", false, "MoValuePanel")

    self.lastPercentTable = {XianLastPercent = 0, MoLastPercent = 0}
end

function XianMoAddPointDlg:onUpdate()
    if self.isUpdateSlider then
        self.isUpdateSlider = false

        if self.slider and self.titleType then
            self:onSliderChange(self.titleType, self.slider)
            self.titleType = nil
            self.slider = nil
        end

    end
end

-- 为每一个slider父节点Panel 添加一个touched事件
function XianMoAddPointDlg:bindSliderPanel(node)

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
        -- WDSY-23444 玩家长按，鼠标释放后，slider可能还在滑动，导致属性值不对，所以在鼠标释放后应停止slider变化
        if self.titleType and self.slider then
            self.isUpdateSlider = false
            self:onSliderChange(self.titleType, self.slider)
            self.titleType = nil
            self.slider = nil
        end

        self:setCtrlVisible("TipImage", false, "XianValuePanel")
        self:setCtrlVisible("TipImage", false, "MoValuePanel")

        return true
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)

    -- 添加监听
    local dispatcher = node:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, node)

end

function XianMoAddPointDlg:getXianMoPointStart()
    local charPoint = math.max(Me:getLevel() - 119, 0)

    -- 骑宠
    local petPoint = PetMgr:getRidePetXianMoBuff()

    return charPoint + petPoint
end

function XianMoAddPointDlg:setInitData()
    -- 剩余属性点
    self:setLabelText("PolarLimitValueLabel", self.remainAttriPoint)

 --   self:setLabelText("AttribValueLabel", self:getXianCurPoint(), "XianValuePanel")
    self:setSliderPercent(TITLE_TYPE.Xian, 0)

  --  self:setLabelText("AttribValueLabel", self:getMoCurPoint(), "MoValuePanel")
    self:setSliderPercent(TITLE_TYPE.Mo, 0)
    self:setButtonGray()

    self:updateCost()

    self:setCtrlVisible("TipImage", false, "XianValuePanel")
    self:setCtrlVisible("TipImage", false, "MoValuePanel")
end

function XianMoAddPointDlg:setXianMoCurValue(typeTitle, value)
    local color = (PetMgr:getRidePetXianMoBuff() > 0) and COLOR3.BLUE or COLOR3.TEXT_DEFAULT

    if typeTitle == TITLE_TYPE.Xian then
        self:setLabelText("AttribValueLabel", value, "XianValuePanel", color)
    elseif typeTitle == TITLE_TYPE.Mo then
        self:setLabelText("AttribValueLabel", value, "MoValuePanel", color)
    end
end

function XianMoAddPointDlg:setSliderPercent(typeTitle, value, isShowTip)
    local totalNum = self:getTotalPoint()
    local level = Me:queryBasicInt("level")

    -- 换算成总值
    local curValue = 0
    local totalValue = 0
    local slider
    if typeTitle == TITLE_TYPE.Xian then
        slider = self:getControl("Slider", nil, "XianValuePanel")
        curValue = self:getXianCurPoint() - self:getXianMoPointStart() + value
        totalValue = self:getXianCurPoint() + value

    elseif typeTitle == TITLE_TYPE.Mo then
        slider = self:getControl("Slider", nil, "MoValuePanel")
        curValue = self:getMoCurPoint() - self:getXianMoPointStart() + value
        totalValue = self:getMoCurPoint() + value
    end

    self:setXianMoCurValue(typeTitle, totalValue)

    local percent = 0

    if totalNum > 0 then
        percent = curValue / totalNum * 100
    end

    if percent > 100 then
        percent = 100
        return
    end

    local tipImage = self:getControl("TipImage", nil, slider:getParent())
    if isShowTip then
        tipImage:setVisible(true)
        tipImage:setPositionX(self.tipsImageInitPosX + percent * 0.01 * slider:getContentSize().width)
    end

    if value > 0 then
        self:setLabelText("TipLabel", "+"..value, tipImage)
        self:setLabelText("AddpointLabel", "+"..value, slider:getParent(), COLOR3.GREEN)
    elseif value == 0 then
        self:setLabelText("TipLabel", value, tipImage)
        self:setLabelText("AddpointLabel", "", slider:getParent(), COLOR3.GREEN)
    else
        self:setLabelText("TipLabel", value, tipImage)
        self:setLabelText("AddpointLabel", value, slider:getParent(), COLOR3.RED)
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

    self.lastPointTable[typeTitle.."LastPoint"] = value
    self.lastPercentTable[typeTitle.."LastPercent"] = percent

    -- 刷新左侧
    self:updateLeftBuff()
end

function XianMoAddPointDlg:getXianCurPoint()
    return Me:queryInt("upgrade_immortal")
end

function XianMoAddPointDlg:getMoCurPoint()
    return Me:queryInt("upgrade_magic")
end

function XianMoAddPointDlg:getXianBasicPoint()

    local std = math.max(Me:getLevel() - 119, 0) * 2
    local max =  Me:queryBasicInt("upgrade_immortal") + Me:queryBasicInt("upgrade_magic") + Me:queryBasicInt("upgrade/total") - std

    return max

end

function XianMoAddPointDlg:getMoBasicPoint()
    return self:getXianBasicPoint()
end

function XianMoAddPointDlg:getTotalPoint()
    return self:getXianBasicPoint()
end

-- slider逻辑处理
function XianMoAddPointDlg:onSliderChange(typeTitle, sender)
    self.isShowCost = true
    local totalNum = self:getTotalPoint()
    local percent = sender:getPercent()
    local changePercent = percent - self.lastPercentTable[typeTitle.."LastPercent"]
    local changePoint = 0

    if changePercent >= 0 then
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05)
    else
        changePercent = changePercent * -1
        changePoint = math.floor(changePercent * totalNum / 100 + 0.05) * -1
    end

    if changePoint > 0 then
        if changePoint > self.remainAttriPoint then
            if self.remainAttriPoint > 0 then
                changePoint = self.remainAttriPoint
                percent = self.lastPercentTable[typeTitle.."LastPercent"] + changePoint * 100 / totalNum
                sender:setPercent(percent)
                self.lastPercentTable[typeTitle.."LastPercent"] = percent
            elseif self.remainAttriPoint == 0 then
                sender:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
            end
        end
    elseif changePoint == 0 then
        sender:setPercent(self.lastPercentTable[typeTitle.."LastPercent"])
    elseif changePoint < 0 then
    end

    self:tryAddPoint(typeTitle, changePoint, sender, true)
end


function XianMoAddPointDlg:tryAddPoint(typeTitle, delta, sender, isShowTip)
    if not sender then
        if typeTitle == TITLE_TYPE.Xian then
            sender = self:getControl("Slider", nil, "XianValuePanel")
        elseif typeTitle == TITLE_TYPE.Mo then
            sender = self:getControl("Slider", nil, "MoValuePanel")
        end
    end


    local curValue, level
    local value = self[typeTitle.."Add"]
    if value == nil then return false end
    level = self:getXianMoPointStart()
    if typeTitle == TITLE_TYPE.Xian then
        curValue = self:getXianCurPoint()
    elseif typeTitle == TITLE_TYPE.Mo then
        curValue = self:getMoCurPoint()
    end

    -- 修正加点值
    if self.remainAttriPoint < delta then delta = self.remainAttriPoint end
--
    if curValue + value + delta < level then
        delta = level - curValue - value
    end
--]]
    if delta == 0 then
        return false
    end


    -- 显示加点
    value = value + delta
    self[typeTitle.."Add"] = value

    self.remainAttriPoint = self.remainAttriPoint - delta
    self:setLabelText("PolarLimitValueLabel", self.remainAttriPoint)

    self:setSliderPercent(typeTitle, value, isShowTip)

    self:setButtonGray()

    self:updateCost()

    return true
end


function XianMoAddPointDlg:setButtonGray()
    if self.lastPointTable.XianLastPoint == 0 and self.lastPointTable.MoLastPoint == 0 then
        self:setCtrlEnabled("ResetButton", false)
        self:setCtrlEnabled("ConfirmButton", false)
    else
        self:setCtrlEnabled("ResetButton", true)
        self:setCtrlEnabled("ConfirmButton", true)
    end

    if self.remainAttriPoint <= 0 then
        self:setCtrlEnabled("AddButton", false, "XianValuePanel")
        self:setCtrlEnabled("AddButton", false, "MoValuePanel")
    else
        self:setCtrlEnabled("AddButton", true, "XianValuePanel")
        self:setCtrlEnabled("AddButton", true, "MoValuePanel")
    end
end

function XianMoAddPointDlg:getCostValue()
    local num = 0
    if self.lastPointTable.XianLastPoint < 0 then
        num = num - self.lastPointTable.XianLastPoint
    end

    if self.lastPointTable.MoLastPoint < 0 then
        num = num - self.lastPointTable.MoLastPoint
    end

    return num
end

function XianMoAddPointDlg:updateCost()

    local num = self:getCostValue()
    if num > 0 then
        self:setCtrlVisible("CostPanel", true)
        self:setLabelText("CostLabel", num * 328, "CostPanel")
    else
        self:setCtrlVisible("CostPanel", false)
    end
end

function XianMoAddPointDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("XianMoAddPointRulePanel", true)
end

function XianMoAddPointDlg:onAutoAddPointButton(sender, eventType)
    gf:CmdToServer("CMD_REQUEST_RECOMMEND_XMD")
    self.openAutoFlag = true
end

function XianMoAddPointDlg:onXianReduceButton(sender, eventType)
    if not self:tryAddPoint(TITLE_TYPE.Xian, -1) then
        gf:ShowSmallTips(CHS[4100902])
    end
end

function XianMoAddPointDlg:onXianAddButton(sender, eventType)
    if not self:tryAddPoint(TITLE_TYPE.Xian, 1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function XianMoAddPointDlg:onMoReduceButton(sender, eventType)
    if not self:tryAddPoint(TITLE_TYPE.Mo, -1) then
        gf:ShowSmallTips(CHS[4100902])
    end
end

function XianMoAddPointDlg:onMoAddButton(sender, eventType)
    if not self:tryAddPoint(TITLE_TYPE.Mo, 1) then
        gf:ShowSmallTips(CHS[2000020])
    end
end

function XianMoAddPointDlg:onConfirmButton(sender, eventType)
    local costPoint = self:getCostValue()
    if costPoint > 0 then

        if Me:getTotalCoin() < costPoint * 328 then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end

        gf:confirm(string.format(CHS[4100880], costPoint * 328), function ()
            gf:CmdToServer("CMD_ASSIGN_XMD", {xian = self.lastPointTable.XianLastPoint, mo = self.lastPointTable.MoLastPoint})
        end)
    else
        gf:CmdToServer("CMD_ASSIGN_XMD", {xian = self.lastPointTable.XianLastPoint, mo = self.lastPointTable.MoLastPoint})
    end
end

function XianMoAddPointDlg:onResetButton(sender, eventType)
    self.lastPointTable = {[TITLE_TYPE.Xian] = 0, [TITLE_TYPE.Mo] = 0, XianLastPoint = 0, MoLastPoint = 0}

    self.remainAttriPoint = Me:queryInt("upgrade/total")
    self.XianAdd = 0
    self.MoAdd = 0

    self.lastPercentTable = {XianLastPercent = 0, MoLastPercent = 0}
    self:setInitData()
end

function XianMoAddPointDlg:updateLeftBuff()

    local function setValue(value, color, panel, ab)
        local phyPanel = self:getControl("AttriValuePanel1", nil, panel)
        self:setLabelText("AttriValueLabel", ab .. value .. "%", phyPanel, color)

        local phyPanel = self:getControl("AttriValuePanel2", nil, panel)
        self:setLabelText("AttriValueLabel", ab .. value .. "%", phyPanel, color)
    end

    -- 仙道
    local xianPanel = self:getControl("XianPanel", nil, "LeftPanel")
    self.lastPointTable.XianLastPoint = self.lastPointTable.XianLastPoint or 0
    local value = (self:getXianCurPoint() + self.lastPointTable.XianLastPoint) * 0.4
    if self.lastPointTable.XianLastPoint > 0 then
        setValue(value, COLOR3.GREEN, xianPanel, "- ")
    elseif self.lastPointTable.XianLastPoint == 0 then
        setValue(value, COLOR3.TEXT_DEFAULT, xianPanel, "- ")
    else
        setValue(value, COLOR3.RED, xianPanel, "- ")
    end

    -- 魔道
    local xianPanel = self:getControl("MoPanel", nil, "LeftPanel")
    if not self.lastPointTable.MoLastPoint then self.lastPointTable.MoLastPoint = 0 end
    local value = (self:getMoCurPoint() + self.lastPointTable.MoLastPoint or 0) * 0.4
    if self.lastPointTable.MoLastPoint > 0 then
        setValue(value, COLOR3.GREEN, xianPanel, "+ ")
    elseif self.lastPointTable.MoLastPoint == 0 then
        setValue(value, COLOR3.TEXT_DEFAULT, xianPanel, "+ ")
    else
        setValue(value, COLOR3.RED, xianPanel, "+ ")
    end

end

function XianMoAddPointDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_ASSIGN_XMD == data.notify then
        self:onResetButton()
    end
end

function XianMoAddPointDlg:MSG_RECOMMEND_XMD(data)
    if self.openAutoFlag then
        DlgMgr:openDlgEx("XianMoAutoAddPointDlg", data)
        self.openAutoFlag = false
    end
end

function XianMoAddPointDlg:MSG_UPDATE(data)
    if data.id == Me:getId() and self:needRefreshDlg() then
        -- 仙魔剩余点数有变化时，才重置
        self:onResetButton()
    end
end

function XianMoAddPointDlg:MSG_UPDATE_IMPROVEMENT(data)
    if data.id == Me:getId() and self:needRefreshDlg() then
        -- 仙魔剩余点数有变化时，才重置
        self:onResetButton()
    end
end

function XianMoAddPointDlg:aotuAssign(addType)
    if addType == 0 then return end
    self:onResetButton()
    if addType == 1 then
        self:tryAddPoint(TITLE_TYPE.Xian, self.remainAttriPoint)
    else
        self:tryAddPoint(TITLE_TYPE.Mo, self.remainAttriPoint)
    end
end

-- 是否需要刷新界面(用于服务器刷新界面数据)
function XianMoAddPointDlg:needRefreshDlg()
    if self.remainAttriPoint and self.remainAttriPoint + self.XianAdd + self.MoAdd ~= Me:queryInt("upgrade/total") then
        -- 仙魔剩余点数有变化
        return true
    end

    return false
end

return XianMoAddPointDlg
