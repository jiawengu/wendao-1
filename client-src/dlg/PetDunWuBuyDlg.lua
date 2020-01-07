-- PetDunWuBuyDlg.lua
-- Created by yangym Nov/24/2016
-- 元宝补充灵气

local PetDunWuBuyDlg = Singleton("PetDunWuBuyDlg", Dialog)
local PRICE = 164

function PetDunWuBuyDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)

    self:bindListener("GoldCheckBox", self.onGoldCheckBox)
    self:setCheck("GoldCheckBox", InventoryMgr.isUseGoldRefillNimbus)
    self:refreshCoinIcon()

    -- 设置价格
    local price = gf:getMoneyDesc(PRICE, true)
    self:setLabelText("Label1", price, "BuyButton")
    self:setLabelText("Label2", price, "BuyButton")
    self:setLabelText("Label1", price, "InfoPanel")
end

function PetDunWuBuyDlg:setInfo(pet, skillNo)
    self.pet = pet
    self.skillNo = skillNo
end

function PetDunWuBuyDlg:onGoldCheckBox(sender, envetType)
    if sender:getSelectedState() == true then
        InventoryMgr.isUseGoldRefillNimbus = true
    else
        InventoryMgr.isUseGoldRefillNimbus = false
    end
    self:refreshCoinIcon()
end

function PetDunWuBuyDlg:refreshCoinIcon()
    self:setCtrlVisible("GoldImage", InventoryMgr.isUseGoldRefillNimbus, "BuyButton")
    self:setCtrlVisible("SilverImage", not InventoryMgr.isUseGoldRefillNimbus, "BuyButton")

    self:setCtrlVisible("GoldImage", InventoryMgr.isUseGoldRefillNimbus, "InfoPanel")
    self:setCtrlVisible("SilverImage", not InventoryMgr.isUseGoldRefillNimbus, "InfoPanel")
end

function PetDunWuBuyDlg:onBuyButton(sender, eventType)
    local pet = self.pet
    local no = self.skillNo

    if not pet then
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return false
    end

    if pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(string.format(CHS[7000211], pet:getShowName()))
        return false
    end

    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(string.format(CHS[7000212], pet:getShowName()))
        return false
    end

    -- 灵气超过上限
    local skillWithPet = SkillMgr:getSkill(pet:getId(), no)
    if skillWithPet.skill_nimbus + 7500 >= 30000 then
        gf:ShowSmallTips(CHS[7000213])
        return false
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton", sender, eventType) then
        return
    end

    -- 元宝不足判断
    local isGold = self:isCheck("GoldCheckBox")
    local totalCoin
    if isGold then
        totalCoin = math.max(Me:queryInt("gold_coin"), 0)
    else
        totalCoin = math.max(Me:queryInt("silver_coin"), 0) + math.max(Me:queryInt("gold_coin"), 0)
    end

    if totalCoin < PRICE then
        gf:askUserWhetherBuyCoin()
        return
    end

    -- 限制交易相关
    local limitStr, day = gf:converToLimitedTimeDay(pet:query("gift"))
    local costType
    if isGold then
        costType = 0
    else
        costType = 1
    end

    local costSilver = 0
    if isGold then
        if Me:queryInt("gold_coin") < PRICE then
            costSilver = PRICE - math.max(Me:queryInt("gold_coin"), 0)
        end
    else
        if Me:queryInt("silver_coin") >= PRICE then
            costSilver = PRICE
        else
            costSilver = math.max(Me:queryInt("silver_coin"), 0)
        end
    end

    if costSilver ~= 0 and day < 60 then
        -- 增加的限制交易天数
        local willLimitDay = 0
        if day <= 50 then
            willLimitDay = 10
        else
            willLimitDay = 60 - day
        end

        gf:confirm(string.format(CHS[7000236], costSilver, willLimitDay), function ()
            gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
                id = pet:queryBasic("id"),
                skill_no = no,
                type = costType,
                pos = 0,
            })
        end)
        self:close()
        return
    end

    gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
        id = pet:queryBasic("id"),
        skill_no = no,
        type = costType,
        pos = 0,
    })
    self:close()
end

return PetDunWuBuyDlg
