-- PetFlyDoneDlg.lua
-- Created by yangym, May/06/2017
-- 宠物飞升成功界面

local PetFlyDoneDlg = Singleton("PetFlyDoneDlg", Dialog)

function PetFlyDoneDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel_1")

    self:bindListener("ConfrimPanel", self.onConfirmPanel)
    self:bindListener("ConfrimButton", self.onConfirmButton)

    if not data then return end
    local petId = data.id
    local pet = PetMgr:getPetById(petId)
    if not pet then
        return
    end

    local afterData = data.after
    local beforeData = data.before

    -- 左侧宠物头像
    self:setImage("PetImage", ResMgr:getBigPortrait(pet:queryBasicInt("portrait")), "MainPanel")

    -- 宠物名称
    self:setLabelText("NameLabel1", pet:getShowName(), "MainPanel")

    -- 右侧成长
    -- 飞升前
    local totalBefore = beforeData.pet_life_shape +
                        beforeData.pet_mana_shape +
                        beforeData.pet_speed_shape +
                        beforeData.pet_phy_shape +
                        beforeData.pet_mag_shape
    self:setLabelText("TotalGrowValueLabel1", totalBefore)
    self:setLabelText("LifeGrowValueLabel1", beforeData.pet_life_shape)
    self:setLabelText("ManaGrowValueLabel1", beforeData.pet_mana_shape)
    self:setLabelText("SpeedGrowValueLabel1", beforeData.pet_speed_shape)
    self:setLabelText("PhyGrowValueLabel1", beforeData.pet_phy_shape)
    self:setLabelText("MagGrowValueLabel1", beforeData.pet_mag_shape)

    -- 飞升后
    local totalAfter = afterData.pet_life_shape +
                       afterData.pet_mana_shape +
                       afterData.pet_speed_shape +
                       afterData.pet_phy_shape +
                       afterData.pet_mag_shape
    self:setLabelText("TotalGrowValueLabel2", totalAfter)
    self:setLabelText("LifeGrowValueLabel2", afterData.pet_life_shape)
    self:setLabelText("ManaGrowValueLabel2", afterData.pet_mana_shape)
    self:setLabelText("SpeedGrowValueLabel2", afterData.pet_speed_shape)
    self:setLabelText("PhyGrowValueLabel2", afterData.pet_phy_shape)
    self:setLabelText("MagGrowValueLabel2", afterData.pet_mag_shape)
end

function PetFlyDoneDlg:onConfirmPanel()
    self:close()
end

function PetFlyDoneDlg:onConfirmButton()
    self:close()
end

return PetFlyDoneDlg