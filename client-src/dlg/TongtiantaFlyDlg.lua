-- TongtiantaFlyDlg.lua
-- Created by songcw Aug/14/2015
-- 通天塔飞升界面

local TongtiantaFlyDlg = Singleton("TongtiantaFlyDlg", Dialog)

local Fly_Max = 10
local Fly_Min = 2
local Fly_Count = Fly_Max - Fly_Min + 1

function TongtiantaFlyDlg:init()
    self:bindListener("CashFlyButton", self.onCashFlyButton)
    self:bindListener("GoldFlyButton", self.onGoldFlyButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListViewListener("MaxListView", self.onSelectMaxListView)

    self.data = nil
    self.isScrolling = false
    self:updateCost(Fly_Max)

    self.numPanel = self:getControl("SingelNumPanel")
    self.compareBox = self:getBoundingBoxInWorldSpace(self.numPanel)
    self.numPanel:retain()
    self.numPanel:removeFromParent()

    self.flyList = self:resetListView("MaxListView", 0, ccui.ListViewGravity.centerHorizontal)
    self:initFlyNumList()
	
	if Me:isInTradingShowState() then
        self:setImagePlist("GoldImage", ResMgr.ui.small_reward_glod, "GoldFlyButton")
        self:setImagePlist("CashImage", ResMgr.ui.small_reward_glod, "LabelPanel2")
    end
end

function TongtiantaFlyDlg:onUpdate()
    if not self.isScrolling then return end
    
    for i = 1,Fly_Max + 4 do
        local panel = self.flyList:getChildByTag(i)
        if panel then
            local panelBox = self:getBoundingBoxInWorldSpace(panel)
            local colorVlaue = 102
            local colorDis = 255 - 102
            if math.abs(panelBox.y - self.compareBox.y) >= self.compareBox.height then
                self:getControl("NumberPanel", nil, panel):setScale(1)
                self:getControl("MiddleLabel", nil, panel):setColor(cc.c3b(colorVlaue, colorVlaue, colorVlaue))
       
            else
                local bufScale = (self.compareBox.height - math.abs(panelBox.y - self.compareBox.y)) / self.compareBox.height
                self:getControl("NumberPanel", nil, panel):setScale(1 + 0.4 * bufScale)
                self:getControl("MiddleLabel", nil, panel):setColor(cc.c3b(colorVlaue + colorDis * bufScale, colorVlaue + colorDis * bufScale, colorVlaue + colorDis * bufScale))
                
            end
        end
    end
end

function TongtiantaFlyDlg:cleanup()
    self:releaseCloneCtrl("numPanel")
end

function TongtiantaFlyDlg:setData(data)
    -- 类型and层数
    self.data = data
    local towerType = self:getTowerType(data)
    local towerLevelStr = towerType .. " " .. data.curLayer .. "/" .. data.breakLayer
    if towerType == CHS[3003752] then
        towerLevelStr = towerType .. " " .. data.curLayer .. "/" .. data.topLayer
    end
    self:setLabelText("BreachLevelLabel", towerLevelStr)
end

-- 获取通天塔类型  修炼，突破、挑战
function TongtiantaFlyDlg:getTowerType(data)
    if data.curLayer < data.breakLayer then
        return CHS[3003753]
    elseif data.curLayer == data.breakLayer then
        if data.curType == 2 then
            return CHS[3003752]
        else
            return CHS[3003753]
        end
    else
        return CHS[3003752]
    end
end


function TongtiantaFlyDlg:initFlyNumList()
    -- 前后各加2个空位
    for i = 1, Fly_Count + 4 do
        local label = self.numPanel:clone()
        label:setTag(i)
        label:setVisible(true)
        if i <= 2 or i >= Fly_Count + 3 then
            self:setLabelText("MiddleLabel", "", label)
        else
            self:setLabelText("MiddleLabel", tostring(Fly_Min + i - 3), label)
        end

        self.flyList:pushBackCustomItem(label)
    end

    local function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            self.isScrolling = true
            local delay = cc.DelayTime:create(0.15)
            local func = cc.CallFunc:create(function()
                local _, offY = sender:getInnerContainer():getPosition()
                local befPercent = offY / (self.flyList:getInnerContainer():getContentSize().height - self.flyList:getContentSize().height) * 100 + 100
                local labelSize = self.numPanel:getContentSize()
                local absOff = math.abs(offY)
                local num = Fly_Max - math.floor(absOff / labelSize.height)
                if absOff % labelSize.height > labelSize.height * 0.5 then num = num - 1 end
                local percent = ((num - 2) * labelSize.height)/ (self.flyList:getInnerContainer():getContentSize().height - self.flyList:getContentSize().height) * 100
                if befPercent ~= percent or num ~= self.flyNum then
                    sender:scrollToPercentVertical(percent, 0.5, false)
                    performWithDelay(sender, function ()
                        self.isScrolling = false
                    end,0.5)
                    self:updateCost(num)
                end
            end)
            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end
    self.flyList:addScrollViewEventListener(scrollListener)

    performWithDelay(self.root,function ()
        self.flyList:getInnerContainer():setPositionY(0)
    end, 0)
end

function TongtiantaFlyDlg:updateCost(num)
    self.flyNum = num
    self:updateCostCash()
    self:updateCostCoin()
end

function TongtiantaFlyDlg:getCostByField(str)
    if str == "cash" then    
        if self.flyNum <= 5 then
            return (self.flyNum - 1) * 800000
        else
            return (5 - 1) * 800000
        end
        return (self.flyNum - 1) * 800000
    elseif str == "coin" then
        if self.flyNum <= 5 then
            return 90
        else
            return 180
        end
    end
end

function TongtiantaFlyDlg:updateCostCoin()
    if self.flyNum < Fly_Min then self.flyNum = Fly_Min end
    if self.flyNum > Fly_Max then self.flyNum = Fly_Max end
    local coin = self:getCostByField("coin")
    local cashText, fontColor = gf:getArtFontMoneyDesc(coin)
    self:setNumImgForPanel("GoldCostPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end

function TongtiantaFlyDlg:updateCostCash()
    -- 金钱飞升数值大于5时，隐藏
    if self.flyNum > 5 then
        self:setCtrlVisible("CashPanel", false)
        gf:grayImageView(self:getControl("CashFlyButton"))
    else    
        self:setCtrlVisible("CashPanel", true)
        gf:resetImageView(self:getControl("CashFlyButton"))
    end


    if self.flyNum < Fly_Min then self.flyNum = Fly_Min end
    if self.flyNum > Fly_Max then self.flyNum = Fly_Max end
	local cash = self:getCostByField("cash")
    local cashText, fontColor = gf:getArtFontMoneyDesc(cash)
    self:setNumImgForPanel("CashCostPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 21)
end

function TongtiantaFlyDlg:onCashFlyButton(sender, eventType)
    if not self.data then return end
    if TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[3003754])
        return
    end

    if self.flyNum > 5 then
        gf:ShowSmallTips(CHS[3003755])
        return
    end

    if self.data.curType ~= 2 then
        gf:ShowSmallTips(CHS[3003756])
        return
    end

    if self:getTowerType(self.data) == CHS[3003753] then
        if self.data.breakLayer - self.data.curLayer < self.flyNum then
            gf:ShowSmallTips(string.format(CHS[3003757], self.flyNum))
            return
        end
    else
        if self.data.topLayer - self.data.curLayer < self.flyNum then
            gf:ShowSmallTips(string.format(CHS[3003757], self.flyNum))
            return
        end
    end

    if self:getCostByField("cash") > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_KUAISU_FEISHENG, self.flyNum)
    self:onCloseButton()
end

function TongtiantaFlyDlg:onGoldFlyButton(sender, eventType)
    if not self.data then return end
    if TeamMgr:isTeamMeber(Me) then
        gf:ShowSmallTips(CHS[3003754])
        return
    end

    if self.data.curType ~= 2 then
        gf:ShowSmallTips(CHS[3003756])
        return
    end

    if self:getTowerType(self.data) == CHS[3003753] then
        if self.data.breakLayer - self.data.curLayer < self.flyNum then
            gf:ShowSmallTips(string.format(CHS[3003757], self.flyNum))
            return
        end
    else
        if self.data.topLayer - self.data.curLayer < self.flyNum then
            gf:ShowSmallTips(string.format(CHS[3003757], self.flyNum))
            return
        end
    end

    if self:getCostByField("coin") > Me:getTotalCoin() then
        gf:askUserWhetherBuyCoin()
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_TTT_JISU_FEISHENG, self.flyNum)
    self:onCloseButton()
end

function TongtiantaFlyDlg:onInfoButton(sender, eventType)
    local dlg = DlgMgr:openDlg("TongtiantaRuleDlg")
    dlg:setRuleType("TongtiantaFlyDlg")
end

function TongtiantaFlyDlg:onSelectMaxListView(sender, eventType)
end

return TongtiantaFlyDlg
