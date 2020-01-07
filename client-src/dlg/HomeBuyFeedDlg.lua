-- HomeBuyFeedDlg.lua
-- Created by huangzz July/11/2017
-- 补充食粮界面

local HomeBuyFeedDlg = Singleton("HomeBuyFeedDlg", Dialog)

local FOOD_VALUE = 50000

function HomeBuyFeedDlg:init()
    self:bindListener("SellReduceButton", self.onSellReduceButton)
    self:bindListener("SellAddButton", self.onSellAddButton)
    self:bindListener("BuyButton", self.onBuyButton)
    
    self:bindNumInput("MoneyValuePanel")
    
    self:bindListener("IconPanel", self.onShowItemInfo)
end

function HomeBuyFeedDlg:onDlgOpened(bowlId)
    if not bowlId or not next(bowlId) then
        return
    end
    
    bowlId = tonumber(bowlId[1])
    self.foodInfo = HomeMgr.petFoodInfo[bowlId]
    self.feedStatus = HomeMgr.bowlFeedStatus[bowlId]
    self.furniture = HomeMgr:getFurnitureById(bowlId)
    self.furnitureX, self.furnitureY = self.furniture.curX, self.furniture.curY
    
    if not self.foodInfo then
        self:close()
        return
    end
    
    self.bowlId = bowlId
    self.limitNum = self.foodInfo.max_num - self.foodInfo.num
    
    self:initView()
end

function HomeBuyFeedDlg:initView()
    self.inputNum = self.limitNum
   
    self:setImage("IconImage", ResMgr.ui.pet_food_buy, "IconPanel")
    
    -- 价值
    local priceDesc = gf:getArtFontMoneyDesc(FOOD_VALUE, true)
    local cashText, fontColor = gf:getArtFontMoneyDesc(FOOD_VALUE)
    self:setNumImgForPanel("PointPanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 23)
    
    self:updataNum()
end

function HomeBuyFeedDlg:updataNum()

    -- 购买数量
    self:setNumImgForPanel("MoneyValuePanel", ART_FONT_COLOR.DEFAULT, self.inputNum, false, LOCATE_POSITION.MID, 23)

    -- 总价
    local totalPrice = self.inputNum * FOOD_VALUE
    local totalPriceStr =  gf:getArtFontMoneyDesc(totalPrice)
    
    local cashText, fontColor = gf:getArtFontMoneyDesc(totalPrice)
    self:setNumImgForPanel("PointValuePanel", fontColor, totalPriceStr, false, LOCATE_POSITION.LEFT_TOP, 23)
end

function HomeBuyFeedDlg:onShowItemInfo(sender, eventType)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
         imagePath = ResMgr.ui.pet_food_buy,
         resType = ccui.TextureResType.localType,
         basicInfo = {
             [1] = CHS[5410068]
         },
         
         desc = CHS[5410069]
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 数字键盘插入数字
function HomeBuyFeedDlg:insertNumber(num)
    local count = num

    if self.limitNum < count then
        count = self.limitNum
        gf:ShowSmallTips(string.format(CHS[5410065], count))
    end

    self.inputNum = count
    self:updataNum()

    -- 更新键盘数据
    local dlg = DlgMgr:getDlgByName("SmallNumInputDlg")
    if dlg then
        dlg:setInputValue(count)
    end
end

function HomeBuyFeedDlg:onSellReduceButton(sender, eventType)
    self.inputNum = self.inputNum - 1
    if self.inputNum < 1 then
        self.inputNum = 1
        gf:ShowSmallTips(string.format(CHS[5410066]))
    end
    
    self:updataNum()
end

function HomeBuyFeedDlg:onSellAddButton(sender, eventType)
    self.inputNum = self.inputNum + 1
    if self.inputNum > self.limitNum then
        self.inputNum = self.limitNum
        gf:ShowSmallTips(string.format(CHS[5410067], self.limitNum))
    end
    
    self:updataNum()
end

function HomeBuyFeedDlg:onBuyButton(sender, eventType)
    self.foodInfo = HomeMgr.petFoodInfo[self.bowlId]
    self.limitNum = self.foodInfo.max_num - self.foodInfo.num
    
    local furn = HomeMgr:getFurnitureById(self.bowlId)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        ChatMgr:sendMiscMsg(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        self:onCloseButton()
        return
    end
    
    -- 若当前食粮剩余储量≥此家具可装的食粮上限，则给予如下弹出提示
    if self.foodInfo and self.foodInfo.num >= self.foodInfo.max_num then
        gf:ShowSmallTips(CHS[5410043])
        return
    end

    -- 若当前宠物食盆正在使用中，则给予如下弹出提示
    self.feedStatus = HomeMgr.bowlFeedStatus[self.bowlId] or {}
    if self.feedStatus.status == 1 then
        gf:ShowSmallTips(CHS[5410044])
        return
    end
    
    self.feedValue = HomeMgr.feedPetValue[self.bowlId]
    if self.feedValue and self.feedStatus.is_my == 1 and self.feedValue.bonus_value > 0 then
        gf:ShowSmallTips(string.format(CHS[5410094], self.limitNum))
        return
    end
    
    if self.inputNum == 0 then
        -- 至少购买1份
        self.inputNum = 1
        self:updataNum()
        gf:ShowSmallTips(string.format(CHS[5410066], self.limitNum))
        return
    end
    
    if self.inputNum > self.limitNum then
        -- 最多可购买数量
        self.inputNum = self.limitNum
        self:updataNum()
        gf:ShowSmallTips(string.format(CHS[5410067], self.limitNum))
        return
    end

    local money = self.inputNum * FOOD_VALUE
    local moneyDesc = gf:getMoneyDesc(money, false)
    if gf:checkEnough("cash", money) then
        gf:confirm(string.format(CHS[5410070], moneyDesc, self.inputNum), function ()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end
            
            HomeMgr:cmdHouseUseFurniture(self.bowlId, "feed_pet", "add_food", tostring(self.inputNum))
            DlgMgr:closeDlg("HomeBuyFeedDlg")
        end) 
    end
end

return HomeBuyFeedDlg
