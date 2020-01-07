-- PetOneClickYuhuaDlg.lua
-- Created by songcw Jan/19/2018
-- 宠物一键羽化

local PetOneClickYuhuaDlg = Singleton("PetOneClickYuhuaDlg", Dialog)

-- 每次花费3108
local COUNT_TIMES = 3108

local ECLOSION_STAGE = {
    CHS[4200494], CHS[4200495], CHS[4200496],
}

local ECLOSION_STAGE_STR = {
    CHS[4200497], CHS[4200498], CHS[4200499]
}

function PetOneClickYuhuaDlg:init(pet)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("GoldImage", self.onGoldCoinAddButton)
    self:bindListener("BindCheckBox", self.onCheckBox)
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    
    self.isAuto = false
    self.pet = pet
    self:setCheck("BindCheckBox", false)

    self:updateCoin()
    self:initDest(pet)

    self:hookMsg("MSG_PET_ECLOSION_RESULT")
end

function PetOneClickYuhuaDlg:initDest(pet)
  --  if pet:queryBasicInt("eclosion_stage") == 1
    
    
    self:updateButtons(pet:queryBasicInt("eclosion_stage") + 1, pet)
end

function PetOneClickYuhuaDlg:updateButtons(dest, pet)
    self:setLabelText("StageLabel", ECLOSION_STAGE[dest])
    self.destStage = dest   
    
    
    
    if  dest > pet:queryBasicInt("eclosion_stage") + 1 then
        gf:resetImageView(self:getControl("ReduceButton"))
    else
        gf:grayImageView(self:getControl("ReduceButton"))
    end
 
    if dest < 3 then
        gf:resetImageView(self:getControl("AddButton"))
    else
        gf:grayImageView(self:getControl("AddButton"))
    end
end

function PetOneClickYuhuaDlg:onReduceButton(sender, eventType)
    if self.destStage <= self.pet:queryBasicInt("eclosion_stage") + 1 then
        gf:ShowSmallTips(string.format(CHS[4200502], PetMgr:getYuhuaStageChs(self.pet)))
        self.destStage = self.pet:queryBasicInt("eclosion_stage") + 1
        return
    end
    self:updateButtons(self.destStage - 1, self.pet)
end

function PetOneClickYuhuaDlg:onAddButton(sender, eventType)
    if self.destStage >= 3 then
        self.destStage = 3
        gf:ShowSmallTips(CHS[4200503])
        return
    end
    self:updateButtons(self.destStage + 1, self.pet)
end

function PetOneClickYuhuaDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        gf:ShowSmallTips(CHS[4101003])
    end
end

-- 金元宝按钮
function PetOneClickYuhuaDlg:onGoldCoinAddButton(sender, eventType)
    DlgMgr:openDlg("OnlineRechargeDlg")
end

function PetOneClickYuhuaDlg:onStartButton(sender, eventType)
    -- 限时宠物无法羽化
    if PetMgr:isTimeLimitedPet(self.pet) then
        gf:ShowSmallTips(CHS[4100996])
        return
    end

    -- 角色处于禁闭状态，当前无法进行此操作
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    -- 战斗中
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000229])
        return
    end

    -- 野生宠物
    if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[4100992])
        return
    end
    
        -- 安全锁判断
    if self:checkSafeLockRelease("onStartButton") then
        return
    end
    
    
    local para
    local totalMoney = 0
    if self:isCheck("BindCheckBox") then
        para = "1"
        totalMoney = Me:getTotalCoin()
    else
        para = "0"
        totalMoney = Me:queryBasicInt("gold_coin")
    end
    --[[ -- 由服务器给不足提示
    if totalMoney < COUNT_TIMES then
        gf:askUserWhetherBuyCoin()
        return 
    end
    --]]


    self.isAuto = true
    
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("StopButton", true)

    local costType = self:isCheck("BindCheckBox") and "" or "gold_coin"
    PetMgr:upgradePet(self.pet, {}, "pet_eclosion", costType)
end

function PetOneClickYuhuaDlg:onStopButton(sender, eventType)
    self.isAuto = false
    
    self:setCtrlVisible("StartButton", true)
    self:setCtrlVisible("StopButton", false)
end

function PetOneClickYuhuaDlg:MSG_PET_ECLOSION_RESULT(data)
    self:updateCoin()
    
    self.pet = PetMgr:getPetByNo(self.pet:queryBasicInt("no"))
    
    if PetMgr:isYuhuaCompleted(self.pet) then self:onCloseButton() return end
    if data.result == 1 and self.isAuto then
    
        if self.destStage == self.pet:queryBasicInt("eclosion_stage") then
            self:onCloseButton()
        else
    
            performWithDelay(self.root, function ()
                local costType = self:isCheck("BindCheckBox") and "" or "gold_coin"
                PetMgr:upgradePet(self.pet, {}, "pet_eclosion", costType)
            end, 0.7)
        end
    elseif data.result == 0 then
        self:onStopButton()
    end
end

function PetOneClickYuhuaDlg:updateCoin()
    local gold_coin = Me:queryBasicInt('gold_coin')
    local goldText = gf:getArtFontMoneyDesc(tonumber(gold_coin))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)
    
    local silver_coin = Me:queryBasicInt('silver_coin')
    local silverText = gf:getArtFontMoneyDesc(tonumber(silver_coin))
    self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23)    
end

return PetOneClickYuhuaDlg
