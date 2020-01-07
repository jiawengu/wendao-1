-- PetFollowRuleDlg.lua
-- Created by songcw Mar/31/2019
-- 娃娃参战悬浮框

local PetFollowRuleDlg = Singleton("PetFollowRuleDlg", Dialog)

function PetFollowRuleDlg:init(tempPetId)
    self:bindListener("CheckButton", self.onCheckButton)

    local pet = PetMgr:getPetById(tempPetId)
    self.pet = pet
    if pet then
        self:setLabelText("TitleLabel", CHS[4200801])
        self:setLabelText("NameLabel", pet:queryBasic("name"))
        self:setLabelText("LifetLabel", string.format( CHS[4200802], pet:queryInt("longevity")))
        self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), "ShapePanel")
         self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP,21)
    else
        self:setLabelText("TitleLabel", CHS[4200803])
        self:setLabelText("NameLabel", CHS[5000059], nil, COLOR3.EQUIP_NORMAL)
        self:setLabelText("LifetLabel", string.format( CHS[4200802], 0))
        self:setImage("GuardImage", ResMgr.ui.button_pet, "ShapePanel")
        self:removeNumImgForPanel("LevelPanel", LOCATE_POSITION.LEFT_TOP)
    end
end

function PetFollowRuleDlg:onCheckButton(sender, eventType)
    local dlg = DlgMgr:openDlg("PetAttribDlg")
    if self.pet then
        DlgMgr:sendMsg("PetListChildDlg", "selectPetId", self.pet:getId())
    end

    self:onCloseButton()
end

return PetFollowRuleDlg
