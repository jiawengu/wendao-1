-- HousePetStoreDlg.lua
-- Created by sujl, Sept/5/2018
-- 宠物小屋仓库

local StorePetBaseDlg = require("dlg/StorePetBaseDlg")
local HousePetStoreDlg = Singleton("HousePetStoreDlg", StorePetBaseDlg)

local PUTIN_HOUSE_STORE_PET = 1
local GETOUT_HOUSE_STORE_PET = 2

function HousePetStoreDlg:init(param)
    self.id = param
    if self.id then
        local furniture = HomeMgr:getFurnitureById(self.id)
        self.curX, self.curY = furniture.curX, furniture.curY
    end

    StorePetBaseDlg.init(self)

    if not StoreMgr:cmdHouseStorePetsInfo() then
        self:MSG_STORE()
    end

    self:setCtrlVisible("NoteImage_0_0", false)
    self:setCtrlVisible("Label_146_0", false)

    self:setLabelText("TitleLabel_1", CHS[2100214], "TitlePanel")
    self:setLabelText("TitleLabel_2", CHS[2100214], "TitlePanel")

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_UPDATE_SKILLS")  -- 刷新天技个数
    self:hookMsg("MSG_INSIDER_INFO")

    EventDispatcher:addEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function HousePetStoreDlg:cleanup()
    StorePetBaseDlg.cleanup(self)
    StoreMgr:cmdCloseHouseStorePets()

    EventDispatcher:removeEventListener("EVENT_JOIN_TEAM", self.onJoinTeam, self)
end

function HousePetStoreDlg:getCfgFileName()
    return ResMgr:getDlgCfg("StorePetDlg")
end

function HousePetStoreDlg:getStorePetByPos(pos)
    return StoreMgr.storeHousePets[pos]
end

function HousePetStoreDlg:getPetFromStore(pos)
    if self.id then
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
    end

    StoreMgr:getPetFromHousePetStore(pos)
end

function HousePetStoreDlg:cmdPetToStore(petId)
    if self.id then
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
    end

    StoreMgr:cmdPetToHousePetStore(petId)
end

function HousePetStoreDlg:MSG_INSIDER_INFO()
    self:MSG_STORE()
end

-- 仓库
function HousePetStoreDlg:MSG_STORE()
    local pets = StoreMgr.storeHousePets
    self:setSelectClean()

    if self.longPress then
        -- 如果存在长按，取消长按处理
        self.root:stopAction(self.longPress)
        self.longPress = nil
    end

    local storeData = HomeMgr:getHousePetStoreData()
    local curValue = storeData and storeData.cur_size or 0

    if pets == nil or table.maxn(pets) == 0 then
        self.storeListCtrl:removeAllItems()
        self:setLabelText("StoreLabel", string.format(CHS[3003658], 0, curValue))
        return
    end

    local array = {}
    local selectId = 0
    local selectName = nil
    for k, v in pairs(pets) do
        v.pos = k
        table.insert(array,v)
    end

    local function comparePet(left, right)
        if left.intimacy > right.intimacy then return true
        elseif left.intimacy < right.intimacy then return false
        end

        if left.level > right.level then return true
        elseif left.level < right.level then return false
        end

        if left.shape > right.shape then return true
        elseif left.shape < right.shape then return false
        end

        if left.name < right.name then
            return true
        else
            return false
        end
    end

    table.sort(array, function(l,r) return comparePet(l,r) end)


    local count = 0
    self.storeListCtrl:removeAllItems()
    for i, pet in pairs(array) do
        local panel = self.petInfoPanel:clone()
        panel:setTag(pet.pos)
 --       local pet = pets[StoreMgr:getStartPosByType("pet") - 1 + i]

        local boonSkillNum = 0
        for i = 1,#pet.skills do
            local skillName = SkillMgr:getSkillName(pet.skills[i].skill_no)
            if PartyMgr:getSkillTypeBySkillName(skillName) == CHS[3003659]
                and PetMgr:mayPetHaveRawSkill(pet.raw_name, skillName) then
                boonSkillNum = boonSkillNum + 1
            end
        end

        self:setLabelText("LevelValueLabel", boonSkillNum .. CHS[3003654], panel)
        self:setImage("GuardImage", ResMgr:getSmallPortrait(pet.icon), panel)
        self:setItemImageSize("GuardImage", panel)

        if pet.deadline ~= 0 then  -- 限时宠物
            InventoryMgr:addLogoTimeLimit(self:getControl("GuardImage", nil, panel))
        elseif PetMgr:isLimitedPetWithoutQuery(pet) then  -- 限制交易宠物
            InventoryMgr:addLogoBinding(self:getControl("GuardImage", nil, panel))
        end

        self:setLabelText("NameLabel", gf:getPetName(pet), panel)
        self:setLabelText("LevelLabel", "LV." .. pet.level, panel)

        -- 阶位
        if pet.mount_type and pet.mount_type ~= 0 then
            self:setLabelText("HorseLevelLabel", string.format(CHS[6000532], PetMgr:getMountRankStrWithoutQuery(pet)), panel)
        end

        self:setCtrlVisible("StatusImage", false, panel)
        self:bindTouchEndEventListener(panel, self.onPickStorePet)
        self:blindLongPress("ShapePanel", nil, self.onPetShapeStore, panel)
        self.storeListCtrl:pushBackCustomItem(panel)
        count = count + 1
    end

    self:setLabelText("StoreLabel", string.format(CHS[3003658], count, curValue))
end

function HousePetStoreDlg:MSG_SET_OWNER()
    self:setSelectClean()
    self:initOwnPet()
end

function HousePetStoreDlg:MSG_UPDATE_PETS()
    self:initOwnPet()
end

function HousePetStoreDlg:MSG_UPDATE_SKILLS(data)
    self:initOwnPet(true, data.id)
end

function HousePetStoreDlg:onJoinTeam()
    self:onCloseButton()
end

return HousePetStoreDlg