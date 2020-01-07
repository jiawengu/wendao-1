-- AddPetBookDlg.lua
-- Created by
--

local AddPetBookDlg = Singleton("AddPetBookDlg", Dialog)

function AddPetBookDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindCheckBoxListener("GoldCheckBox", self.onCheckBox)
    self.pet = nil

    self:onCheckBox(self:getControl("GoldCheckBox"))
end

function AddPetBookDlg:onCheckBox(sender, eventType)
    self:setCtrlVisible("SilverImage", not sender:getSelectedState(), "BuyButton")
    self:setCtrlVisible("GoldImage", sender:getSelectedState(), "BuyButton")
end

function AddPetBookDlg:setData(pet)
    self.pet = pet
end

function AddPetBookDlg:onBuyButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local pet = self.pet

    -- 野生
    if self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(string.format(CHS[4200215], self.pet:getName()))
        return
    end

    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    local dlg = DlgMgr:getDlgByName("PetSkillDlg")
    if not dlg then return end
    local skillNo = dlg.curSkillNo
    local skillName = SkillMgr:getSkillName(skillNo)
    local power = 0
    for i = 1, godBookCount do
        -- 获取当前天书技能的各个属性
        local nameKey = 'god_book_skill_name_' .. i
        local name = pet:queryBasic(nameKey)
        local skillAttr = SkillMgr:getskillAttribByName(name)
        if skillNo == skillAttr.skill_no then
            local levelKey = 'god_book_skill_level_' .. i
            local powerKey = 'god_book_skill_power_' .. i
            local level = pet:queryBasic(levelKey)
            local bookPower = pet:queryBasicInt(powerKey)
            power = bookPower
        end
    end

    -- 本次补充后天书灵气将超过上限，无法使用！
    if power + 3500 > 30000 then
        gf:ShowSmallTips(CHS[4200216])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onBuyButton") then
        return
    end

    -- 元宝不足判断
    if Me:getTotalCoin() < 100 then
        -- 总元宝不足
        gf:askUserWhetherBuyCoin()
        return
    end

    -- 限制交易先关判断
    local limitStr, day = gf:converToLimitedTimeDay(pet:query("gift"))
    local isGold = self:isCheck("GoldCheckBox")
    local coin_type = isGold and "gold_coin" or ""

    local costSilver = 0
    if isGold then
        if Me:getGoldCoin() < 100 then
            -- 金元宝不足
            gf:askUserWhetherBuyCoin()
            return
        end
    else
        if Me:getSilverCoin() >= 100 then
            costSilver = 100
        else
            costSilver = Me:getSilverCoin()
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

        gf:confirm(string.format(CHS[4200214], costSilver, willLimitDay), function ()
            PetMgr:buyGodBooknimbusByCoin(pet:queryBasicInt("no"), skillName, coin_type)
        end)

        return
    end

    PetMgr:buyGodBooknimbusByCoin(pet:queryBasicInt("no"), skillName, coin_type)
end

return AddPetBookDlg
