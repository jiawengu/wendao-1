-- MarketAuctionItemDlg.lua
-- Created by songcw Feb/25/2016
-- 拍卖行 竞价界面

local MarketAuctionItemDlg = Singleton("MarketAuctionItemDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function MarketAuctionItemDlg:init()
    self:bindListener("MinPriceButton", self.onMinPriceButton)
    self:bindListener("MyPriceButton", self.onMyPriceButton)
    self.firstInsertNum = true
    self.inputNum = 0
    self:bindNumInput()
end

-- 设置数字键盘输入
function MarketAuctionItemDlg:bindNumInput()
    local moneyPanel = self:getControl("MoneyValuePanel", nil, "MyPricePanel")
    local function openNumIuputDlg()
        self.firstInsertNum = true
        local rect = self:getBoundingBoxInWorldSpace(moneyPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2)
        self:setCtrlVisible("Label", false, moneyPanel)
    end
    self:bindListener("MoneyValuePanel", openNumIuputDlg, "MyPricePanel")
end

-- 数字键盘删除数字
function MarketAuctionItemDlg:deleteNumber()
    local moneyPanel = self:getControl('MoneyValuePanel', nil, "MyPricePanel")
    self.inputNum = math.floor(self.inputNum / 10)
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘清空
function MarketAuctionItemDlg:deleteAllNumber(key)
    local moneyPanel = self:getControl('MoneyValuePanel', nil, "MyPricePanel")
    self.inputNum = 0
    self:refreshPublicCash(self.inputNum )
end

-- 数字键盘插入数字
function MarketAuctionItemDlg:insertNumber(num)
    if self.firstInsertNum then
        self.firstInsertNum = false
        self.inputNum = 0
    end

    if num == "00" then
        self.inputNum = self.inputNum * 100
    elseif num == "0000" then
        self.inputNum = self.inputNum * 10000
    else
        self.inputNum = self.inputNum * 10 + num
    end

    if self.inputNum >= 2000000000 then
        self.inputNum = 2000000000
        gf:ShowSmallTips(CHS[3002954])
    end
    self:refreshPublicCash(self.inputNum )
end

-- 刷新公示的信息
function MarketAuctionItemDlg:refreshPublicCash(cash)
    local cashText,fonColor = gf:getArtFontMoneyDesc(cash)
    self:setNumImgForPanel("MoneyValuePanel", fonColor, cashText, false, LOCATE_POSITION.MID, 21, "MyPricePanel")
end

function MarketAuctionItemDlg:getItemName(orgName)
    local name = string.match(orgName, CHS[3002936])
    if name then
        return string.sub(orgName, 1, gf:findStrByByte(orgName, "|") - 1)
    end

    return orgName
end

function MarketAuctionItemDlg:setItemInfo(item)
    self.item = item
    self.inputNum = self:getPriceWillBe(item.price)
    self:setImage("IconImage", ResMgr:getIconPathByName(item.name))
    self:setItemImageSize("IconImage")
    self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, item.goodsLevel, false, LOCATE_POSITION.LEFT_TOP, 23)
    local imagePanel = self:getControl("IconPanel")
    self:bindTouchEndEventListener(imagePanel, function (self, sender)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local name = self:getItemName(self.item.name)
        local item = {}
        item["Icon"] = InventoryMgr:getIconByName(name)
        item.level = self.item.goodsLevel
        item["name"] = name
        item["extra"] = nil
        item["desc"] = InventoryMgr:getDescript(name)
        item["isGuard"] = InventoryMgr:getIsGuard(name)
        if string.match(self.item.name, CHS[3002936]) then
            item.upgrade_type = tonumber(gf:split(self.item.name,"|")[3])
            InventoryMgr:showBasicMessageByItem(item, rect)
        else
            local rewardList = TaskMgr:getRewardList(string.format(CHS[5200019], self.item.name))
            local rewardInfo = RewardContainer:getRewardInfo(rewardList[1][1])
            rewardInfo.basicInfo[1] = rewardInfo.basicInfo[1] .. CHS[4400049] 
            local dlg
            if rewardInfo.desc then
                dlg = DlgMgr:openDlg("BonusInfoDlg")
            else
                dlg = DlgMgr:openDlg("BonusInfo2Dlg")
            end
            dlg:setRewardInfo(rewardInfo)
            dlg.root:setAnchorPoint(0, 0)
            dlg:setFloatingFramePos(rect)
        end
    end)


    local name = string.match(item.name, CHS[3002955])
    if name then
        self:setLabelText("NameLabel", name)
    else
        self:setLabelText("NameLabel", item.name)
    end

    local extra = string.match(item.name, CHS[3002956])
    if extra then
        local list = gf:split(extra, "|")
        local att = list[1]
        local field = EquipmentMgr:getAttribChsOrEng(att)
        local bai = ""
        if EquipmentMgr:getAttribsTabByName(CHS[3002957])[field] then bai = "%" end

        self:setLabelText("NameLabel2", att .. " " .. list[2] .. bai .. "/" .. list[2] .. bai)
    end

    -- 当前最高出价
    local cashText, fontColor = gf:getArtFontMoneyDesc(item.price)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "MaxPricePanel")

    -- 最低竞价
    local willCost = self:getPriceWillBe(item.price)
    local cashText, fontColor = gf:getArtFontMoneyDesc(willCost)
    self:setNumImgForPanel("MoneyValuePanel", fontColor, cashText, false, LOCATE_POSITION.MID, 23, "MinPricePanel")
    self:refreshPublicCash(self.inputNum)
end

function MarketAuctionItemDlg:getPriceWillBe(price)
    return math.min(2000000000, math.floor(price * (1 + 0.05)))
end

function MarketAuctionItemDlg:bidGoods(price)
    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(CHS[3002959])  -- 等级达到#R30级#n后开放该功能。
        return
    end

    if self.item.price >= 2000000000 then
        gf:ShowSmallTips(CHS[3002960])  -- 该商品当前出价已达上限，无法继续竞价。
        return
    end

    if price < self:getPriceWillBe(self.item.price) then
        gf:ShowSmallTips(CHS[3002961])  -- 出价不得低于最低竞价。
        return
    end

    if self.item.price > Me:queryBasicInt("cash") then
        gf:askUserWhetherBuyCash()
        return
    end

    local costNumStr = gf:getMoneyDesc(price, false)

    local attStr = ""
    local name = ""
    if string.match(self.item.name, CHS[3002936]) then
        local org_name, att, value = string.match(self.item.name, "(.+)·(.+)|(.+)|")
        local field = EquipmentMgr:getAttribChsOrEng(att)
        local bai = ""
        if EquipmentMgr:getAttribsTabByName(CHS[3002957])[field] then bai = "%" end

        attStr = att .. " " .. value .. bai .. "/" .. value .. bai .. "的"
        name = org_name
    else
        attStr = ""
        name = self.item.name
    end

    if self.item.isBidder == 1 then
        gf:confirm(CHS[3002962], function()
            gf:confirm(string.format(CHS[4300217], costNumStr, attStr, name), function ()
                MarketMgr:cmdAuctionBidGoods(self.item.id, price, self.item.price)
                self:onCloseButton()
            end)
        end)
    else
        gf:confirm(string.format(CHS[4300217], costNumStr, attStr, name), function ()
            MarketMgr:cmdAuctionBidGoods(self.item.id, price, self.item.price)
            self:onCloseButton()
        end)
    end
end

function MarketAuctionItemDlg:onMinPriceButton(sender, eventType)
    local minPrice = self:getPriceWillBe(self.item.price)
    if self.inputNum == minPrice then
        gf:ShowSmallTips(CHS[4010079])
        return
    end

    self.inputNum = minPrice
    self:refreshPublicCash(self.inputNum )
--    self:bidGoods(self:getPriceWillBe(self.item.price))
end

function MarketAuctionItemDlg:onMyPriceButton(sender, eventType)
    self:bidGoods(self.inputNum)
end

return MarketAuctionItemDlg
