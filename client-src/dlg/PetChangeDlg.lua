-- PetChangeDlg.lua
-- Created by sujl Aug/12/2016
-- 宠物元神共通界面

local PetChangeDlg = Singleton("PetChangeDlg", Dialog)

function PetChangeDlg:init()
    self.matAddImage1 = self:getControl("AddImage", Const.UIImage, "MaterialPanel")
    self.matPetImage1 = self:getControl("ItemImage", Const.UIImage, "MaterialPanel")
    self.matAddImage2 = self:getControl("AddImage", Const.UIImage, "MaterialPanel_0")
    self.matPetImage2 = self:getControl("ItemImage", Const.UIImage, "MaterialPanel_0")

    self.matPetImage1:setVisible(true)
    self.matPetImage2:setVisible(true)

    self.pet = nil

    local path

    -- 初始化参战宠物
    local fightPet = PetMgr:getFightPet()
    path = ResMgr:getSmallPortrait(fightPet:queryBasicInt("portrait"))
    self.matPetImage1:loadTexture(path)
    gf:setItemImageSize(self.matPetImage1)
    PetMgr:setPetLogo(self, fightPet, "MaterialPanel")


end

function PetChangeDlg:setChangePet(robPet)
 
    self.pet = robPet
    local isRide = PetMgr:isRidePet(robPet:getId())
    if not isRide then
        self:setLabelText("PetLabel", CHS[4200197], "MaterialPanel_0")
    else
        self:setLabelText("PetLabel", CHS[4200198], "MaterialPanel_0")
    end
    
    local path = ResMgr:getSmallPortrait(robPet:queryBasicInt("portrait"))
    self.matPetImage2:loadTexture(path)
    gf:setItemImageSize(self.matAddImage2)
    PetMgr:setPetLogo(self, robPet, "MaterialPanel_0")

    local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_pet", 0)
    local changeStatePanel = self:getControl("OpenStatePanel")
    self:createSwichButton(changeStatePanel, changeOn, self.onPetChange)
end

function PetChangeDlg:onPetChange(isOn, key)
    if not self.pet then return end
    
    local changType = PetMgr:isRidePet(self.pet:getId()) and 2 or 1
    if isOn then
        SystemSettingMgr:sendSeting("award_supply_pet", changType)        
    else
        SystemSettingMgr:sendSeting("award_supply_pet", 0)
    end
    
end

return PetChangeDlg
