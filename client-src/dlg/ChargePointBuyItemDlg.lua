-- ChargePointBuyItemDlg.lua
-- Created by huangzz Mar/06/2017
-- 兑换奖品界面

local ChargePointBuyItemDlg = Singleton("ChargePointBuyItemDlg", Dialog)

local RewardContainer = require("ctrl/RewardContainer")

function ChargePointBuyItemDlg:init()
    self:bindListener("SellReduceButton", self.onSellReduceButton)
    self:bindListener("SellAddButton", self.onSellAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
   
    self:bindNumInput("NumPanel")
end

function ChargePointBuyItemDlg:setData(data, ownPoint, deadline)
    self.itemInfo = data
    self.ownPoint = ownPoint
    self.deadline = deadline
    
    -- 奖品图标
    if data.textureResType == ccui.TextureResType.plistType then
        self:setImagePlist("IconImage", data.imgPath)
    else
        self:setImage("IconImage", data.imgPath)
    end

    local num = data.num
    self:setLabelText("SellFloatLabel", CHS[5440000] .. " " .. num)
    
    -- 限制交易
    if data["limted"] then
        InventoryMgr:addLogoBinding(self:getControl("IconImage", nil))
    end

    -- 名字
    self:setLabelText("NameLabel", data.name)

    -- 兑换积分
    local pointDesc = gf:getArtFontMoneyDesc(data.point, true)
    self:setNumImgForPanel("PointPanel", ART_FONT_COLOR.DEFAULT, pointDesc, false, LOCATE_POSITION.CENTER, 23)

    -- 奖品名片
    local iconPanel = self:getControl("IconPanel") 
    iconPanel.reward = data.reward
    self:bindTouchEndEventListener(iconPanel, self.onShowItemInfo)
    
    self.inputNum = 1
    self:updateChargeNum(1)
    
    self.root:requestDoLayout()
end

function ChargePointBuyItemDlg:getItemUnit(type, name)
    if type == CHS[6000079] then -- 宠物
        return CHS[5420143]
    else
        return InventoryMgr:getUnit(name)
    end
end

function ChargePointBuyItemDlg:getShopLimit(type, name)
    if type == CHS[6000079] then         -- 宠物
        return PetMgr:getFreePetCapcity()
    elseif type == CHS[3002168] then     -- 首饰
        return InventoryMgr:getEmptyPosCount()
    else
        return InventoryMgr:getCountCanAddToBag(name, 99, self.itemInfo.limted)
    end
end

function ChargePointBuyItemDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
end

function ChargePointBuyItemDlg:onSellReduceButton(sender, eventType)
    if self.inputNum <= 1 then
        gf:ShowSmallTips(CHS[5420140])
        return
    end
    
    self.inputNum = self.inputNum - 1
    self:updateChargeNum(self.inputNum)
end

function ChargePointBuyItemDlg:onSellAddButton(sender, eventType)
    if self.inputNum >= self.itemInfo.num then
        gf:ShowSmallTips(string.format(CHS[5420139], self.itemInfo.num))
        return
    end
    
    self.inputNum = self.inputNum + 1
    self:updateChargeNum(self.inputNum)
end

function ChargePointBuyItemDlg:onBuyButton(sender, eventType)
    local curTime = gf:getServerTime()
    if curTime > self.deadline then
        gf:ShowSmallTips(CHS[5420148])
        ChatMgr:sendMiscMsg(CHS[5420148])
        DlgMgr:closeDlg("ChargePointBuyItemDlg")
        DlgMgr:closeDlg("ChargePointDlg")
        return
    end
    
    if self.inputNum < 1 then
        self.inputNum = 1
        self:updateChargeNum(1)
        gf:ShowSmallTips(CHS[5420140])
        return
    end
    
    if self.inputNum > self.itemInfo.num then
        self.inputNum = self.itemInfo.num
        self:updateChargeNum(self.inputNum)
        gf:ShowSmallTips(CHS[5420139], self.inputNum)
        return
    end
    
    local type = self.itemInfo.type
    local name = self.itemInfo.name
    local shopLimit = self:getShopLimit(type, name)
    
    
    if type ~= CHS[3002168] then
        if shopLimit < self.inputNum then
            if type == CHS[6000079] then
                gf:ShowSmallTips(CHS[5420145])
                return            
            else
                gf:ShowSmallTips(CHS[5420144])
                return
            end
        end
    else
        if self.inputNum <= 3 then
            if shopLimit < self.inputNum then
                gf:ShowSmallTips(CHS[5420144])
                return
            end
        else
            if math.floor((self.inputNum - 3) / 10) + 3 > shopLimit then
                gf:ShowSmallTips(CHS[5420144])
                return
            end
        end
    end
    
    local costPoint = self.inputNum * self.itemInfo.point
    if costPoint > self.ownPoint then
        gf:ShowSmallTips(CHS[5420141])
        return
    end
    
    local itemUnit = self:getItemUnit(type, name)
    gf:confirm(string.format(CHS[5420142], costPoint, self.inputNum, itemUnit, name), function ()
        local type = GiftMgr:getPointWelfareType()
        if type == "charge" then
            GiftMgr:buyChargePointGoods(self.itemInfo.no, self.inputNum)
        elseif type == "consume" then
            GiftMgr:buyConsumePointGoods(self.itemInfo.no, self.inputNum)
        end
        
        self:close()
    end)
end

-- 更新兑换数量级总消耗积分
function ChargePointBuyItemDlg:updateChargeNum(num)
    self:setColorText(tostring(num), "MoneyValuePanel", nil, 0, 0, COLOR3.WHITE, 21, true)
    
    local totalPoint = num * self.itemInfo.point
    local fontColor = ART_FONT_COLOR.DEFAULT
    if totalPoint > self.ownPoint then
        fontColor = ART_FONT_COLOR.RED
    end
    
    local pointDesc= gf:getArtFontMoneyDesc(totalPoint)
    self:setNumImgForPanel("PointValuePanel", fontColor, pointDesc, false, LOCATE_POSITION.MID, 23)
end

-- 绑定数字键盘
function ChargePointBuyItemDlg:bindNumInput(inputPanelName)
    local inputPanel = self:getControl(inputPanelName)

    local function openNumIuputDlg()
        local rect = self:getBoundingBoxInWorldSpace(inputPanel)
        local dlg = DlgMgr:openDlg("NumInputDlg")
        dlg:setObj(self)
        dlg.root:setPosition(rect.x + rect.width /2 , rect.y  + rect.height +  dlg.root:getContentSize().height /2 )
    end

    self:bindListener(inputPanelName, openNumIuputDlg)
end

-- 数字键盘删除数字
function ChargePointBuyItemDlg:deleteNumber()
    self.inputNum = math.floor((self.inputNum or 0) / 10)
    self:updateChargeNum(self.inputNum)
end

-- 数字键盘清空
function ChargePointBuyItemDlg:deleteAllNumber()
    self.inputNum = 0
    self:updateChargeNum(0)
end

-- 数字键盘插入数字
function ChargePointBuyItemDlg:insertNumber(num)
    local curNumber = self.inputNum or 0
    if num == "00" then
        curNumber = curNumber * 100
    elseif num == "0000" then
        curNumber = curNumber * 10000
    else
        curNumber = curNumber * 10 + num
    end

    if curNumber >= self.itemInfo.num then
        curNumber = self.itemInfo.num
        gf:ShowSmallTips(string.format(CHS[5420139], curNumber))
    end
    
    self.inputNum = curNumber
    self:updateChargeNum(curNumber)
end

function ChargePointBuyItemDlg:cleanup()
    self.itemInfo = {}
end

return ChargePointBuyItemDlg
