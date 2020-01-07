-- GuanggdbDlg.lua
-- Created by songcw Sep/8/2017
-- 光棍夺宝

local GuanggdbDlg = Singleton("GuanggdbDlg", Dialog)

local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

local lastClick -- 代表表示上一次点击的按钮，用于判断按不同按钮

function GuanggdbDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:bindListener("BuyButton", self.onBuyButton)

    self:bindListViewListener("GoodsListView", self.onSelectGoodsListView)    
    
    self:blindPress("ReduceButton")
    self:blindPress("AddButton")
    
    self.oneRowPanel = self:retainCtrl("OneRowPanel")
    self:bindListener("GoodPanel_1", self.onGoodsButton, self.oneRowPanel)
    self:bindListener("GoodPanel_2", self.onGoodsButton, self.oneRowPanel)
    self:bindListener("PetPanel", self.onGoodsButton)
    
    self.selectImage = self:retainCtrl("ChosenEffectImage", self.oneRowPanel)
    
    self:bindListener("DuoBRulePanel", function ()
        self:setCtrlVisible("DuoBRulePanel", false)
    end)
    self:bindFloatPanelListener("DuoBRulePanel")
    
    self:setLabelText("RefreshTimeLabel", "")
    
    self.selectItem = nil
    self.data = nil
    self.selectNum = 0
    self.autoRefresh5 = 0 
    self.isLoad = false
    
    -- 打开数字键盘
    self:bindNumInput("NumberValuePanel", nil, function()
        if not self.selectItem then
            gf:ShowSmallTips(CHS[4000424])
            return true
        end
    end)   
    
    self:hookMsg("MSG_SINGLES_2017_GOODS_LIST")
end

function GuanggdbDlg:onUpdate()
    if not self.data then return end
    
    if self.data.update_ti <= gf:getServerTime() and self.sendTime ~= self.data.update_ti then
        -- 向服务器发送消息
        self.sendTime = self.data.update_ti
        gf:CmdToServer("CMD_SINGLES_2017_GOODS_REFRESH", { auto = 1})
    end
    
    local left = math.max(0, self.data.update_ti - gf:getServerTime())
    local m = math.floor(left / 60)
    local s = math.floor(left % 60)
    
    
    if self.data.update_ti >= self.data.end_ti then
        self:setLabelText("RefreshTimeLabel", CHS[4100816])
    else
        self:setLabelText("RefreshTimeLabel", string.format(CHS[4000437], m, s))
    end
    
    if self.data.pet["now_step"] >= 5000 then
        self:setCtrlVisible("ConditionLabel_2", false)        
        local left = math.max(0, self.data.end_ti - gf:getServerTime())
        local d = math.floor(left / (60 * 60 * 24))
        local h = math.floor(left % (60 * 60 * 24) / (60 * 60))
        local m = math.floor(left % (60 * 60 * 24) % (60 * 60) / 60)
        local s = math.floor(left % (60 * 60 * 24) % (60 * 60) % 60)
        
        if d >= 1 then
            self:setLabelText("ConditionLabel_3", string.format(CHS[4000436], d, h))
        elseif h >= 1 then
            self:setLabelText("ConditionLabel_3", string.format(CHS[4000435], h, m))
        else
            self:setLabelText("ConditionLabel_3", string.format(CHS[4000434], m, s))
        end       
    end
    
    local h = tonumber(os.date("%H", gf:getServerTime()))
    if h < 5 then
        -- 5点前
        self.autoRefresh5 = 1
    end

    if self.autoRefresh5 == 1 and h >= 5 then
        -- 5点后刷新一次        
        self.autoRefresh5 = 2
        
        gf:CmdToServer("CMD_SINGLES_2017_GOODS_REFRESH", { auto = 1})
    end    
end

function GuanggdbDlg:setData(data)
    self.data = data
    self:setGoodsList(data)
    self:setItemInfo(self.selectItem)
    self:setShopPanel()
    
    self:setLabelText("LeftBuyTimesLabel", string.format(CHS[4000433], data.buy_count))
    
    local petPanel = self:getControl("PetPanel")
    self:setProgressBar("ProgressBar", data.pet["now_step"], data.pet["req_step"], petPanel)
    self:setLabelText("DevelopProcessLabel_1", string.format(CHS[4000432], data.pet["now_step"]), petPanel)
    self:setLabelText("DevelopProcessLabel_2", string.format(CHS[4000432], data.pet["now_step"]), petPanel)    
    petPanel.item = data.pet
    
    if data.pet["buy_step"] == 0 then
        self:setLabelText("HaveBuyLabel", "", petPanel)
    else
        self:setLabelText("HaveBuyLabel", string.format(CHS[4000431], data.pet["buy_step"]), petPanel)
    end
    self:setCtrlVisible("TipImage", data.pet["buy_step"] > 0, petPanel)
    
    
    if data.pet["quota"] <= 0 or self.data.start_ti + 3 * 60 * 60 > gf:getServerTime() then        
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.DEFAULT, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, petPanel)
    else        
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.DEFAULT, 1, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, petPanel)
    end   
end

-- 数字键盘插入数字
function GuanggdbDlg:insertNumber(num)
    self.selectNum = num

    if self.selectNum < 0 then
        self.selectNum = 0
    end

    local isOk, limit = self:isMeetCondition()
    if not isOk then
        self.selectNum = limit
    end

    self:setShopPanel()

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self.selectNum)
    end
end

function GuanggdbDlg:blindPress(name)
    local widget = self:getControl(name,nil,self.root)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end
    -- longClick为长按的标志位
    local function updataCount(longClick)
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton(longClick)
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton(longClick)
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , function() updataCount(true) end, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end


function GuanggdbDlg:setGoodsList(data)    
    local function getDataByName(name)
    	for _, info in pairs(data.goodsInfo) do
    	   if info.name == name then
                return info
    	   end
    	end
    end    
    
    if not self.isLoad then
        self.isLoad = true
        local listCtrl = self:resetListView("GoodsListView")
        -- 没有则加载    
        local row = math.ceil(data.count / 2)
        for i = 1, row do
            local parentPanel = self.oneRowPanel:clone()
            
            local lPanel = self:getControl("GoodPanel_1", nil, parentPanel)
            self:setUnitGoodsPanel(data.goodsInfo[(i - 1) * 2 + 1], lPanel)
            
            local rPanel = self:getControl("GoodPanel_2", nil, parentPanel)
            self:setUnitGoodsPanel(data.goodsInfo[(i - 1) * 2 + 2], rPanel)
            listCtrl:pushBackCustomItem(parentPanel)
        end
    else
        local listCtrl = self:getControl("GoodsListView")
        -- 有则刷新
        local items = listCtrl:getItems()    
        for _, parentPanel in pairs(items) do
            local lPanel = self:getControl("GoodPanel_1", nil, parentPanel)
            local info = getDataByName(lPanel.item.name)
            self:setUnitGoodsPanel(info, lPanel) 
            
            local rPanel = self:getControl("GoodPanel_2", nil, parentPanel)
            if rPanel.item then
                local info = getDataByName(rPanel.item.name)
                self:setUnitGoodsPanel(info, rPanel)
            end 
        end
    end
end

function GuanggdbDlg:setUnitGoodsPanel(data, panel)
    if not data then
        panel:setVisible(false)
        return
    end
    
    panel.item = data
    
    -- 名字
    self:setLabelText("GoodsNameLabel", data.name, panel)
    
    if data.buy_step == 0 then
        self:setLabelText("HaveBuyLabel", "", panel)
    else
        self:setLabelText("HaveBuyLabel", string.format(CHS[4000431], data.buy_step), panel)
    end
    
    -- 图标
    self:setImage("GoodsImage", ResMgr:getIconPathByName(data.name), panel)
    

    if data["quota"] <= 0 then
        gf:grayImageView(self:getControl("GoodsImage", nil, panel))        
    else
        gf:resetImageView(self:getControl("GoodsImage", nil, panel))        
    end    
    
    if data["quota"] <= 0 or self.data.start_ti + 3 * 60 * 60 > gf:getServerTime() then        
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.DEFAULT, 0, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)
    else        
        self:setNumImgForPanel("LimitNumPanel", ART_FONT_COLOR.DEFAULT, 1, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)
    end
    
    self:setCtrlVisible("SoldoutImage", data["quota"] <= 0, panel)
    self:setCtrlVisible("TipImage", data["buy_step"] > 0, panel)
    
    self:setProgressBar("ProgressBar", data["now_step"], data["req_step"], panel)
    self:setLabelText("DevelopProcessLabel_1", string.format("%d/%d", data["now_step"], data["req_step"]), panel)
    self:setLabelText("DevelopProcessLabel_2", string.format("%d/%d", data["now_step"], data["req_step"]), panel)
end

function GuanggdbDlg:onGoodsButton(sender, eventType)

    if self.selectItem and self.selectItem.name == sender.item.name then
        self:onAddButton()
        return
    end

    self.selectImage:removeFromParent()
    if sender:getName() ~= "PetPanel" then        
        sender:addChild(self.selectImage)
    end
    
    self:setCtrlVisible("ChosenEffectImage", sender:getName() == "PetPanel")
    
    self.selectItem = sender.item
    
    self:setItemInfo(sender.item)
end

function GuanggdbDlg:setItemInfo(item)
    local panel = self:getControl("BuyPanel")
    local desPanel = self:getControl("ItemDescPanel", nil, panel)
    desPanel:removeAllChildren()
    if not item then
        self:setCtrlVisible("EmptyPanel", true, panel)
        self:setLabelText("GoodsNameLabel", "", panel)
        return
    end
    
    self:setCtrlVisible("EmptyPanel", false, panel)    
    self:setLabelText("GoodsNameLabel", item.name, panel)    
    
    local desText = CGAColorTextList:create()
    desText:setFontSize(19)
    desText:setString(InventoryMgr:getDescript(item["name"]))
    desText:setContentSize(desPanel:getContentSize().width, 0)
    desText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    desText:updateNow()
    local labelW, labelH = desText:getRealSize()
    desText:setPosition(0, desPanel:getContentSize().height)
    desPanel:addChild(tolua.cast(desText, "cc.LayerColor"))
  
    self.selectNum = 1
    if item.quota <= 0 or self.data.buy_count <= 0 then
        self.selectNum = 0
    end
    
    --if self.data.
    
    self:setShopPanel()
end

function GuanggdbDlg:onNoteButton(sender, eventType)
    self:setCtrlVisible("DuoBRulePanel", true)
end

-- 刷新
function GuanggdbDlg:onRefreshButton(sender, eventType)
    if not self.data then return end
    
    if gf:getServerTime() >= self.data.end_ti then
        gf:ShowSmallTips(CHS[4000430])
        return
    end
    
    if not self:isOutLimitTime("lastTime", 3 * 1000) then
        gf:ShowSmallTips(CHS[4000429])
        return
    end
     
    self:setLastOperTime("lastTime", gfGetTickCount())
    gf:CmdToServer("CMD_SINGLES_2017_GOODS_REFRESH", { auto = 0})
end

-- 商城点击减号按钮，参数longClick为判断是否长按的标志位
function GuanggdbDlg:onReduceButton(longClick)
    if lastClick ~= "reduceButton" then self.clickButtonTime = 0 end
    if not self.selectItem then
        gf:ShowSmallTips(CHS[4000424]) 
        return 
    end

    if self.selectNum <= 1 then
        gf:ShowSmallTips(CHS[4000428])
    else
        self.selectNum = self.selectNum - 1
        if longClick then
            self.clickButtonTime = -1
        else
            self.clickButtonTime = self.clickButtonTime + 1
            if self.clickButtonTime == 3 then
                gf:ShowSmallTips(CHS[4000427])
            end
        end
    end
    self:setShopPanel()
    lastClick = "reduceButton"
end

-- 满足增加条件
function GuanggdbDlg:isMeetCondition()
    if not self.data then return end
    
    if self.selectItem.name == CHS[4100817] then
        if self.selectNum >= self.data.buy_count then    
            gf:ShowSmallTips(string.format(CHS[4000423], self.data.buy_count))
            return false, self.data.buy_count
        end
    else 
        if self.selectItem.quota <= 0 then
            gf:ShowSmallTips(CHS[4200458])
            return false, 0
        end
    
        local limit = math.min(self.data.buy_count, math.ceil(self.selectItem.req_step / 2) - self.selectItem.buy_step, self.selectItem.req_step - self.selectItem.now_step)
        if self.selectNum >= limit then    
            if limit == self.data.buy_count then    
                gf:ShowSmallTips(string.format(CHS[4000423], limit))
            else
                gf:ShowSmallTips(string.format(CHS[4000422], limit))
            end
            return false, limit
        end
    end
    
    return true 
end

-- 商城点击加号按钮，参数longClick为判断是否长按的标志位
function GuanggdbDlg:onAddButton(longClick)
    if lastClick ~= "addButton" then self.clickButtonTime = 0 end
    if not self.selectItem then 
        gf:ShowSmallTips(CHS[4000424])
        return 
    end

    if self:isMeetCondition() then
        self.selectNum = self.selectNum + 1
        if longClick then
            self.clickButtonTime = -1
        else
            self.clickButtonTime = self.clickButtonTime + 1
            if self.clickButtonTime == 3 then
                gf:ShowSmallTips(CHS[4000427])
            end
        end
    end
    self:setShopPanel()
    lastClick = "addButton"
end

-- 购买物品信息
function GuanggdbDlg:setShopPanel()
    self:setLabelText("NumberValueLabel", self.selectNum, "NumberLabelImage")    
    
    self:setLabelText("HaveValueLabel", "", "HavePanel")
    
    local cashText, fontColor = gf:getArtFontMoneyDesc(Me:queryBasicInt('cash'))
    self:setNumImgForPanel("HaveTextPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
    
    if not self.selectItem or self.selectNum == 0 then
        self:setLabelText("Label_1", CHS[4100851], "CostCashPanel", COLOR3.WHITE)
        self:setLabelText("Label_2", CHS[4100851], "CostCashPanel")
        
        self:removeNumImgForPanel("CostTextPanel", LOCATE_POSITION.MID)
    else
        self:setLabelText("Label_1", "", "CostCashPanel")
        self:setLabelText("Label_2", "", "CostCashPanel")
        
        local cashText, fontColor = gf:getArtFontMoneyDesc(self.selectNum * self.data.cost_cash)
        self:setNumImgForPanel("CostTextPanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23)
    end

end

-- 点击购买按钮
function GuanggdbDlg:onBuyButton(sender, eventType)
    if not self.data then return end
    
    -- 开始时间前3小时判断
    if gf:getServerTime() < self.data.start_ti + 60 * 60 * 3 then
        gf:ShowSmallTips(CHS[4000426])
        return
    end
    
    -- 无物品
    if not self.selectItem then
        gf:ShowSmallTips(CHS[4000424])
        return true
    end
    
    -- 结束时间
    if gf:getServerTime() >= self.data.end_ti then
        gf:ShowSmallTips(CHS[4000425])
        return
    end
    
    if self.selectItem.quota <= 0 then
        gf:ShowSmallTips(CHS[4200458])
        return
    end
    
    if self.data.buy_count <= 0 then
        gf:ShowSmallTips(string.format(CHS[4200469], 0))
        return
    end
    
    
    if self.selectNum <= 0 then
        gf:ShowSmallTips(string.format(CHS[4200463]))
        return
    end

    -- 最大购买数量
    if self.selectItem.name == CHS[4100817] then
        if self.selectNum > self.data.buy_count then    
            gf:ShowSmallTips(string.format(CHS[4000423], self.data.buy_count))
            return
        end
    else    
        local limit = math.min(self.data.buy_count, math.ceil(self.selectItem.req_step / 2) - self.selectItem.buy_step, self.selectItem.req_step - self.selectItem.now_step)
        if self.selectNum > limit then    
            if limit == self.data.buy_count then    
                gf:ShowSmallTips(string.format(CHS[4000423], limit))
            else
                gf:ShowSmallTips(string.format(CHS[4000422], limit))
            end
            return
        end
    end
    
    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end
    
    if self.selectNum * self.data.cost_cash > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    gf:CmdToServer("CMD_SINGLES_2017_GOODS_BUY", {
        name = self.selectItem.name,
        amount = self.selectNum,
        quota = self.selectItem.quota
    })
end


function GuanggdbDlg:MSG_SINGLES_2017_GOODS_LIST(data)
    -- 刷新选中的物品
    if self.selectItem then
        if self.selectItem.name == data.pet.name then
            self.selectItem = data.pet
        else
            for i = 1, data.count do
                if self.selectItem.name == data.goodsInfo[i].name then
                    self.selectItem = data.goodsInfo[i]
                end
            end
        end
    end
    
    -- 3表示已经开奖，购买失败
    if data.buy_flag == 1 or data.buy_flag == 3 then
        self.selectItem = nil
        self.selectImage:removeFromParent()

        self:setCtrlVisible("ChosenEffectImage", false, "PetPanel")
    end

    -- 设置界面
    self:setData(data)
end

function GuanggdbDlg:onSelectGoodsListView(sender, eventType)
end

return GuanggdbDlg
