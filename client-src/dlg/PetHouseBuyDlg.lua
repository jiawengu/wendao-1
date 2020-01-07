-- PetHouseBuyDlg.lua
-- Created by sujl, May/30/2018
-- 自定义换装界面

local PetHouseBuyDlg = Singleton("PetHouseBuyDlg", Dialog)

function PetHouseBuyDlg:init(param)
    self:bindListener("ReduceButton", self.onReduceButton, "BuyNumberPanel")
    self:bindListener("AddButton", self.onAddButton, "BuyNumberPanel")
    self:bindListener("BuyButton", self.onBuyButton)

    self.id = param
    local furniture = HomeMgr:getFurnitureById(self.id)
    self.curX, self.curY = furniture.curX, furniture.curY

    self:refreshNum(1)

    EventDispatcher:addEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function PetHouseBuyDlg:cleanup()
    EventDispatcher:removeEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function PetHouseBuyDlg:refreshNum(num)
    local storeData = HomeMgr:getHousePetStoreData()
    local curValue = storeData and storeData.cur_size or 0
    local maxValue = storeData and storeData.max_size or 0
    num = math.max(1, math.min(num, maxValue - curValue))
    self:setLabelText("NumberLabel", num, "BuyNumberPanel")

    self:refreshButton()
end

function PetHouseBuyDlg:getShowNum()
    return tonumber(self:getLabelText("NumberLabel", "BuyNumberPanel")) or 1
end

function PetHouseBuyDlg:refreshButton()
    local num = self:getShowNum()
    local stroeData = HomeMgr:getHousePetStoreData()
    local curValue = stroeData and stroeData.cur_size or 0
    local maxValue = stroeData and stroeData.max_size or 0
    self:setCtrlEnabled("ReduceButton", num > 1, "BuyNumberPanel")
    self:setCtrlEnabled("AddButton", num < maxValue - curValue, "BuyNumberPanel")
    self:setCtrlEnabled("BuyButton", num <= maxValue - curValue)

    local cashText = gf:getArtFontMoneyDesc(num * 2000)
    self:setNumImgForPanel("CostPanel", ART_FONT_COLOR.DEFAULT, cashText, false, LOCATE_POSITION.MID, 21)
    self:setCtrlVisible("CostImage_Silver", true)
    self:setCtrlVisible("CostImage_Gold", false)
end

function PetHouseBuyDlg:doBuy()
    local num = self:getShowNum()
    local price = num * 2000

    local totalMoney
    totalMoney = Me:getTotalCoin()
    if totalMoney < num * 2000 then
        -- 元宝不足
        gf:askUserWhetherBuyCoin()
    else
        gf:confirm(string.format(CHS[2100237], price, num), function()
            gf:CmdToServer("CMD_HOUSE_PET_STORE_ADD_SIZE", { furniture_pos = self.id, count = num })
            self:onCloseButton()
        end)
    end
end

function PetHouseBuyDlg:onReduceButton()
    local num = self:getShowNum()
    self:refreshNum(num - 1)
end

function PetHouseBuyDlg:onAddButton()
    local num = self:getShowNum()
    self:refreshNum(num + 1)
end

function PetHouseBuyDlg:onBuyButton()
    local furn = HomeMgr:getFurnitureById(self.id)
    if not furn then
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    elseif furn.curX ~= self.curX or furn.curY ~= self.curY then
        gf:ShowSmallTips(CHS[4200418])
        self:onCloseButton()
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("doBuy") then
        return
    end

    self:doBuy()
end

function PetHouseBuyDlg:onJoinTeam()
    self:onCloseButton()
end

return PetHouseBuyDlg