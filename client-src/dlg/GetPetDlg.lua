-- GetPetDlg.lua
-- Created by zhengjh May/15/2015
-- 领取宠物

local GetPetDlg = Singleton("GetPetDlg", Dialog)

local PET_DESC =
{
    [CHS[3002647]] = CHS[3002648],
    [CHS[3002649]] = CHS[3002650],
}

function GetPetDlg:init()
    self:bindListener("GetButton", self.onGetButton)
end

function GetPetDlg:setInfo(param)  
    self.param = param
    local petName, petRank, level = string.match(param, "#I.*|(.+)%((.+)%).*$(%d+).*#I")
    local list = gf:split(param, "$")
    
    if #list > 2 then
        level = list[2]
    end
    
    if petName then
        local pet = PetMgr:getPetCfg(petName)
        self:setPortrait("PetShapPanel", pet["icon"], 0, self.root, true)
        self:setLabelText("PetNameLabel", string.format("%s(%s)", petName, petRank))
        self:setLabelText("LevelLabel", level .. CHS[3002651])
        self:setLabelText("PetPolarLabel", pet.polar)
        self:setLabelText("DescLabel", PET_DESC[petName])
    end
end

function GetPetDlg:onGetButton(sender, eventType)
    if PetMgr:getFreePetCapcity() <= 0  then
        gf:ShowSmallTips(CHS[3002652])
    else
        if self.param then
            gf:sendGeneralNotifyCmd(NOTIFY.NOTICE_FETCH_BONUS , self.param)  
            local petName, petRank = string.match(self.param, "#I.*|(.+)%((.+)%)(.*)#I")
            PromoteMgr:setRecordPet(petName) 
        end
    end
    
    DlgMgr:closeDlg(self.name)
end

return GetPetDlg
