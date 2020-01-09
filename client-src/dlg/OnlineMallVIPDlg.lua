-- OnlineMallVIPDlg.lua
-- Created by zhengjh Apr/27/2015
-- vip

local VIP_INFO =
{
     [1] = CHS[6000202], --"位列仙班·月卡",
     [2] = CHS[6000203], --"位列仙班·季卡",
     [3] = CHS[6000204], --"位列仙班·年卡",
}

local VIP_INDEX =
{
    [CHS[6000202]] = 1,
    [CHS[6000203]] = 2,
    [CHS[6000204]] = 3,
}
local OnlineMallVIPDlg = Singleton("OnlineMallVIPDlg", Dialog)

local VIP_COST =
{
    [1] = 3000,
    [2] = 9000,
    [3] = 36000,
}

function OnlineMallVIPDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("GoldCoinPanel", self.onAddGoldButton)
    self:bindListener("GotButton", function()
        gf:ShowSmallTips(CHS[3003184])
    end)
    --[[
    self.vipRightCell = self:getControl("OneRowVIPDetailPanel")
    self.vipRightCell:retain()

    self.vipRightCell2 = self:getControl("OneRowVIPDetailPanel2")
    self.vipRightCell2:retain()

    self.vipDetailListView = self:getControl("VIPDetailListView", Const.UIPanel)
    self.vipDetailListViewSize = self.vipDetailListView:getContentSize()
--]]

    -- 珍宝需要特殊处理一下
    local panel = self:getControl("OneRowVIPDetailPanel15", nil, "VIPDetailListView1")
    self:setCtrlVisible("DetailLabel2", DistMgr:isOfficalDist(), panel)
    self:setCtrlVisible("DetailLabel1", not DistMgr:isOfficalDist(), panel)

    self.vipDetailListView = self:getControl("VIPDetailListView1", Const.UIPanel)
    self.vipDetailListViewSize = self.vipDetailListViewSize or self.vipDetailListView:getContentSize()
    gf:CmdToServer("CMD_GET_INSIDER_DISCOUNT_INFO")
    self:checkDiscount()

    -- 为IOS评审
    self:forIOSReview()

    self:hookMsg("MSG_INSIDER_INFO")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_INSIDER_DISCOUNT_INFO")
    self:MSG_INSIDER_INFO()
    self:MSG_UPDATE()
end

-- 将分别显示三个等级的位列仙班listView设置大小
function OnlineMallVIPDlg:setListViewContentSize(w, h)
    for i = 1, 3 do
       local list = self:getControl("VIPDetailListView" .. i)
       list:setContentSize(w, h)
    end
end

-- 检查是否有打折
function OnlineMallVIPDlg:checkDiscount()
    local enableDiscount
    if OnlineMallMgr.vipDiscount then
        local startTime = OnlineMallMgr.vipDiscount.startTime
        local endTime = OnlineMallMgr.vipDiscount.endTime
        local curServerTime = gf:getServerTime()
        enableDiscount = curServerTime >= startTime and curServerTime <= endTime
    end

    if enableDiscount then
        self:setListViewContentSize(self.vipDetailListViewSize.width, self.vipDetailListViewSize.height - 33)
      --  self.vipDetailListView:setContentSize(self.vipDetailListViewSize.width, self.vipDetailListViewSize.height - 33)
        self:setCtrlVisible("DiscountPanel", VIP_COST[1] ~= OnlineMallMgr.vipDiscount.dsicountMonthPrice, "CardPanel1")
        self:setLabelText("DiscountLabel", tostring(VIP_COST[1] - OnlineMallMgr.vipDiscount.dsicountMonthPrice), "CardPanel1")
        self:setPrice("CardPanel1", tostring(OnlineMallMgr.vipDiscount.dsicountMonthPrice))
        self:setCtrlVisible("DiscountPanel", VIP_COST[2] ~= OnlineMallMgr.vipDiscount.dsicountQuaterPrice, "CardPanel2")
        self:setLabelText("DiscountLabel", tostring(VIP_COST[2] - OnlineMallMgr.vipDiscount.dsicountQuaterPrice), "CardPanel2")
        self:setPrice("CardPanel2", tostring(OnlineMallMgr.vipDiscount.dsicountQuaterPrice))
        self:setCtrlVisible("DiscountPanel", VIP_COST[3] ~= OnlineMallMgr.vipDiscount.dsicountYearPrice, "CardPanel3")
        self:setLabelText("DiscountLabel", tostring(VIP_COST[3] - OnlineMallMgr.vipDiscount.dsicountYearPrice), "CardPanel3")
        self:setPrice("CardPanel3", tostring(OnlineMallMgr.vipDiscount.dsicountYearPrice))
        self:setCtrlVisible("DiscountPanel", true, "InfoPanel")
        self:setLabelText("NoteLabel", string.format(CHS[2000116], gf:getServerDate("%Y-%m-%d %H:%M",
            OnlineMallMgr.vipDiscount.startTime),
            gf:getServerDate("%Y-%m-%d %H:%M", OnlineMallMgr.vipDiscount.endTime)))

        self.vipCost = {
            OnlineMallMgr.vipDiscount.dsicountMonthPrice,
            OnlineMallMgr.vipDiscount.dsicountQuaterPrice,
            OnlineMallMgr.vipDiscount.dsicountYearPrice,
        }
    else
        self:setListViewContentSize(self.vipDetailListViewSize.width, self.vipDetailListViewSize.height)
    --    self.vipDetailListView:setContentSize(self.vipDetailListViewSize.width, self.vipDetailListViewSize.height)
        self:setCtrlVisible("DiscountPanel", false, "CardPanel1")
        self:setCtrlVisible("DiscountPanel", false, "CardPanel2")
        self:setCtrlVisible("DiscountPanel", false, "CardPanel3")
        self:setCtrlVisible("DiscountPanel", false, "InfoPanel")
        self:setPrice("CardPanel1", tostring(VIP_COST[1]))
        self:setPrice("CardPanel2", tostring(VIP_COST[2]))
        self:setPrice("CardPanel3", tostring(VIP_COST[3]))
        self.vipCost = VIP_COST

    end

    self:getControl("InfoPanel", Const.UIPanel):requestDoLayout()
end

function OnlineMallVIPDlg:setPrice(root, value)
    self:setLabelText("PriceLabel_1", tostring(value), root)
    self:setLabelText("PriceLabel_2", tostring(value), root)
end

function OnlineMallVIPDlg:forIOSReview()
    for i = 1,3 do
        self:setCtrlVisible("CardImage2", GameMgr.isIOSReview, "CardPanel" .. i)
    end

    self:setCtrlVisible("ReturnPanel", not GameMgr.isIOSReview)
    self:setCtrlVisible("iOSReturnPanel", GameMgr.isIOSReview)
--[[
    if GameMgr.isIOSReview then
        for i = 1,3 do
            local panel = self:getControl("CardPanel" .. i)
            self:setCtrlVisible("CardImage2", true, panel)
        end
    else
        for i = 1,3 do
            local panel = self:getControl("CardPanel" .. i)
            self:setCtrlVisible("CardImage2", false, panel)
        end
    end
    --]]
end

function OnlineMallVIPDlg:onAddGoldButton(sender, eventType)
    local onlineTabDlg = DlgMgr.dlgs["OnlineMallTabDlg"]

    -- 需要延迟一帧，释放按钮
    performWithDelay(self.root, function()
        if onlineTabDlg then
            onlineTabDlg.group:setSetlctByName("RechargeCheckBox")
        else
            DlgMgr:openDlg("OnlineRechargeDlg")
            DlgMgr.dlgs["OnlineMallTabDlg"].group:setSetlctByName("RechargeCheckBox")
        end
    end, 0)
end

function OnlineMallVIPDlg:MSG_UPDATE()
    local cashText = gf:getArtFontMoneyDesc(Me:queryBasicInt('gold_coin'))
    self:setNumImgForPanel("GoldCoinValuePanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 23)
end

function OnlineMallVIPDlg:MSG_INSIDER_INFO(data)
    local vipInfo = OnlineMallMgr:getVipInfo()
    local vipRight = OnlineMallMgr:getVipInfoRight()

    -- 设置默认
    self.vipLevel = Me:getVipType() or 0

    if self.vipLevel == 0 then
        self.selcetVipLevelIndex = VIP_INDEX[CHS[6000202]]
    else
        self.selcetVipLevelIndex = self.vipLevel
    end

    for i = 1, 3 do
        local cardImage = self:getControl(string.format("CardPanel%d", i), Const.UIImage)

        local function touch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                self.selcetVipLevelIndex = i
                self:addSelcelImage(sender)
                self:initInfoPanel(vipInfo[VIP_INFO[i]])
                self:initRightPanel(i)
            end
        end

        -- 设置默认选中
        if i == self.selcetVipLevelIndex then
            self:addSelcelImage(cardImage)
        end

        -- 设置拥有图片
        local gotImg = self:getControl("GotImage", Const.UIImage, cardImage)
        if i == self.selcetVipLevelIndex and  self.vipLevel ~= 0 then
            gotImg:setVisible(true)
        else
            gotImg:setVisible(false)
        end


        cardImage:addTouchEventListener(touch)
    end

    self:initInfoPanel(vipInfo[VIP_INFO[self.selcetVipLevelIndex]])
    self:initRightPanel(self.selcetVipLevelIndex)

    local timePanel = self:getControl("TimeInfoPanel")

    -- 位列仙帮等级
    local lable1 = self:getControl("LabelValue_1", Const.UILabel, timePanel)
    local str = vipInfo[VIP_INFO[self.selcetVipLevelIndex]]["level"]
    if Me:isTempInsider() then
        str = CHS[5000295] .. str
    end

    lable1:setString(str)

    -- 剩余时间
    local leftDays = Me:getVipLeftDays()
    local lable2 = self:getControl("LabelValue_2", Const.UILabel, timePanel)
    lable2:setString(leftDays..CHS[3003185])

     if self.vipLevel == 0 or tostring(leftDays) == "-0" then
        lable1:setString(CHS[3003186])
        lable2:setString(CHS[3003186])
     end

     -- iOS评审版本
    if GameMgr.isIOSReview then
        if self.vipLevel == 0 or tostring(leftDays) == "-0" then
            lable1:setString(CHS[3003186])
        else
            lable1:setString(vipInfo[VIP_INFO[self.selcetVipLevelIndex]]["iosReviewLevel"])
        end

        lable2:setString("")
        self:setLabelText("Label2", "", timePanel)
    end

    self:updateLayout("TimeInfoPanel")
end


function OnlineMallVIPDlg:addSelcelImage(sender)
    local gotButton = self:getControl("GotButton", Const.UIButton)
    for i = 1, 3 do
        local panel = self:getControl(string.format("CardPanel%d", i), Const.UIPanel)
        local backImg = self:getControl("BackImage", Const.UIImage, panel)

        if sender:getName() == panel:getName() then
            if Me:isGetCoin() and self.vipLevel == i then
                gotButton:setVisible(true)
                self:setCtrlVisible("GetButton", false)
                gf:grayImageView(gotButton)
            else
                self:setCtrlVisible("GetButton", true)
                gf:resetImageView(gotButton)
                gotButton:setVisible(false)
            end

            backImg:setVisible(false)
        else
            backImg:setVisible(true)
        end

    end
end

function OnlineMallVIPDlg:initInfoPanel(data)
    -- 特权时间
  --  local timeText = self:getControl("TimeTextLabel", Const.UILabel)
 --   timeText:setString(string.format(CHS[6000194], data["days"]))

    -- 购买立即返还
 --   local returnLabel = self:getControl("ReturnLabel", Const.UILabel)
    self:setLabelText("ReturnLabel", string.format(CHS[3003189], data["rebateEveryDay"]))
    self:setLabelText("ReturnLabel", string.format(CHS[3003189], data["rebateEveryDay"]), "iOSReturnPanel")

    -- 总共返还
    local totalStr = string.format(CHS[3003188], data["days"], data["totalRebate"])
    if GameMgr.isIOSReview then
        totalStr = string.format(CHS[3003189], data["rebateEveryDay"])
    end

    -- 总共返还元宝
    self:setLabelText("AllReturnNumLabel", totalStr, "ReturnPanel")

    -- 每天领取元宝
    local  moneyGetLabel = self:getControl("MoneyGetLabel", Const.UILabel)
    moneyGetLabel:setString(data["rebateEveryDay"])
    local  moneyGetLabel1 = self:getControl("MoneyGetLabel_0", Const.UILabel)
    moneyGetLabel1:setString(data["rebateEveryDay"])
    self:getControl("InfoPanel", Const.UIPanel):requestDoLayout()
end

function OnlineMallVIPDlg:initRightPanel(vip_level)

    for i = 1, 3 do
        self:setCtrlVisible("VIPDetailListView" .. i, i == vip_level)
    end


    --[[
    local listView = self:getControl("VIPDetailListView", Const.UIPanel)
    listView:removeAllChildren()

    local rightStrTable = self:createRightStr(data)

    for i = 1, #rightStrTable do
        if type( rightStrTable[i]) == "table" then
            local cell = self.vipRightCell2:clone()
            self:setData(cell, rightStrTable[i][1])
            listView:pushBackCustomItem(cell)
        else
            local cell = self.vipRightCell:clone()
            self:setData(cell, rightStrTable[i])
            listView:pushBackCustomItem(cell)
        end

    end
    --]]
end

function OnlineMallVIPDlg:createRightStr(data)
    local str = ""
    local vipInfoTable = {}


    -- 每天领取的元宝
    str = string.format(CHS[3003190], data["money"])
    table.insert(vipInfoTable, str)

    -- vip表情
    if data["vipExpression"] == 1 then
        str = CHS[6000185]
        table.insert(vipInfoTable, str)
    end

    -- 练功扫荡功能
   --[[ if data["sweep"] == 1 then
        str = CHS[6000186]
        table.insert(vipInfoTable, str)
    end]]

    -- 额外买竞技场挑战次数
   --[[ str = string.format(CHS[6000187], data["extraChallengeTimes"])
    table.insert(vipInfoTable, str)]]

    -- 刷道时间延长
    str = string.format(CHS[6000189], data["shuadaoLimitTime"])
    table.insert(vipInfoTable, str)

    -- 可额外购买%d次离线刷道时间
    str = string.format(CHS[3003191], data["buyShuadaoTimes"])
    table.insert(vipInfoTable, str)

    -- 单次刷道托管时间上限延长至%d分钟
    str = string.format(CHS[4100391], data["getTaoTru"])
    table.insert(vipInfoTable, str)

    --
    table.insert(vipInfoTable, CHS[3003192])

    str = string.format(CHS[3003193], data["marketCount"])
    table.insert(vipInfoTable, str)

    -- 锁定角色、宠物经验
    table.insert(vipInfoTable, CHS[3003194])

    -- 开启包裹、钱庄
    if self.selcetVipLevelIndex == 3 then
        table.insert(vipInfoTable, CHS[6000549])
    else
        table.insert(vipInfoTable, CHS[6000548])
    end
    -- 所获得的代金券为金钱
    str = {CHS[3003196]}
    table.insert(vipInfoTable, str)

    -- 爆满优先登录
    str = CHS[3003197]
    table.insert(vipInfoTable, str)

    -- 开启包裹、钱庄
   --[[ if self.selcetVipLevelIndex == 3 then
        table.insert(vipInfoTable, CHS[3003198])
    end]]


    -- 购买更高等级的位列仙班后剩余位列仙班天数会按比例折算后累加
    if data["precentAdd"] > 0 and not GameMgr.isIOSReview then
        str = CHS[6000193]
        table.insert(vipInfoTable, str)
    end

    return vipInfoTable
 end

function OnlineMallVIPDlg:setData(cell, str)
 	local lable = self:getControl("DetailLabel", nil, cell)
 	lable:setString(str)
end

function OnlineMallVIPDlg:onBuyButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local gold = Me:queryBasicInt("gold_coin")
    local rate = 1
    if InventoryMgr:getItemByName(CHS[5200006]) then
        rate = 0.85
    end

    if gold < self.vipCost[self.selcetVipLevelIndex] * rate then
        gf:askUserWhetherBuyCoin("gold_coin")
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton", sender, eventType) then
        return
    end

    OnlineMallMgr:buyVip(self.selcetVipLevelIndex)

  --[[  if self.vipLevel == 0 then     -- 还没购买过
        gf:confirm(string.format(CHS[6000201], VIP_INFO[self.selcetVipLevelIndex] ), function()
            OnlineMallMgr:buyVip(self.selcetVipLevelIndex)
            end)
    elseif self.selcetVipLevelIndex and self.selcetVipLevelIndex > self.vipLevel then    -- 高于当前位列仙帮
        local leftDays = OnlineMallMgr:getVipLeftDays()
        local showMessage = string.format(CHS[6000198], VIP_INFO[self.selcetVipLevelIndex], VIP_INFO[self.vipLevel], self:getCardCovertDays(leftDays), VIP_INFO[self.selcetVipLevelIndex])
        gf:confirm(showMessage, function()
            OnlineMallMgr:buyVip(self.selcetVipLevelIndex)
        end)
    elseif self.selcetVipLevelIndex < self.vipLevel then
        gf:ShowSmallTips(CHS[6000199])
    elseif self.selcetVipLevelIndex == self.vipLevel then
        gf:confirm(string.format(CHS[6000200], VIP_INFO[self.selcetVipLevelIndex] ), function()
            OnlineMallMgr:buyVip(self.selcetVipLevelIndex)
        end)
    end]]
end

function OnlineMallVIPDlg:onGetButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if self.vipLevel == 0 then
        gf:ShowSmallTips(CHS[6000205])
    elseif self.selcetVipLevelIndex ~= self.vipLevel then
        gf:ShowSmallTips(CHS[6000206])
    else
        OnlineMallMgr:getMoney(self.selcetVipLevelIndex)
    end
end

function OnlineMallVIPDlg:getCardCovertDays(leftDays)
    local days = 0

    if VIP_INDEX[self.vipLevel] == 1 and self.selcetVipLevelIndex == 2 then  -- 月卡转季卡
        days = math.floor(leftDays / 1.5)

    elseif VIP_INDEX[self.vipLevel] == 1 and self.selcetVipLevelIndex == 3 then  -- 月卡转年卡
        days = math.floor(leftDays / 2)
    elseif VIP_INDEX[self.vipLevel] == 2 and self.selcetVipLevelIndex == 3 then  -- 季卡转年卡
        days = math.floor(leftDays * 0.75)
    end

    if days > 0 and days < 1 then
        days = 1
    end

    return days
end

function OnlineMallVIPDlg:cleanup()
    self:releaseCloneCtrl("chosenImgModle")
    --[[
    self:releaseCloneCtrl("vipRightCell")
    self:releaseCloneCtrl("vipRightCell2")
    --]]

    if not Me:isGetCoin() and Me:getVipType() > 0 then
        performWithDelay(gf:getUILayer(), function ()
            RedDotMgr:insertOneRedDot("OnlineMallTabDlg", "VIPCheckBox")
        end, 0)
    end

end

function OnlineMallVIPDlg:initVipInfoByLevel(level)
    local vipInfo = OnlineMallMgr:getVipInfo()
    local vipRight = OnlineMallMgr:getVipInfoRight()
    local cardImage = self:getControl(string.format("CardPanel%d", level), Const.UIImage)
    self.selcetVipLevelIndex = level
    self:addSelcelImage(cardImage)
    self:initInfoPanel(vipInfo[VIP_INFO[level]])
    self:initRightPanel(level)
end

function OnlineMallVIPDlg:onDlgOpened(list, para)
    local level = tonumber(para)
    if not level then
        return
    end

    self:initVipInfoByLevel(level)
end

function OnlineMallVIPDlg:selectVipType(vipinfo)
   -- self.vipLevel = vipType
    self:initVipInfoByLevel(vipinfo["vip"])
end

function OnlineMallVIPDlg:MSG_INSIDER_DISCOUNT_INFO(data)
    self:checkDiscount()
end

return OnlineMallVIPDlg
