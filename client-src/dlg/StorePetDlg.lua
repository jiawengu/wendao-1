-- StorePetDlg.lua
-- Created by songcw Aug/26/2015
-- 宠物仓库界面

local StorePetBaseDlg = require("dlg/StorePetBaseDlg")
local StorePetDlg = Singleton("StorePetDlg", StorePetBaseDlg)
local DataObject = require("core/DataObject")

function StorePetDlg:init()
    StorePetBaseDlg.init(self)
    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_UPDATE_SKILLS")  -- 刷新天技个数
    self:hookMsg("MSG_INSIDER_INFO")

    if not StoreMgr:cmdStorePetsInfo() then
        self:MSG_STORE()
    end

    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function StorePetDlg:cleanup()
    StorePetBaseDlg.cleanup(self)

    StoreMgr:cmdCloseStoreItems()
    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function StorePetDlg:initOwnPet(isUpdate, petId)
    local petArray = PetMgr:getOrderPets()
    self:refreshOwnPet(petArray, isUpdate, petId)
end

function StorePetDlg:onOpenDlgRequestData(sender, eventType)
    -- 向服务器请求仓库宠物数据
    StoreMgr:cmdStorePetsInfo()
end

function StorePetDlg:getStorePetByPos(pos)
    return StoreMgr.storePets[pos]
end

function StorePetDlg:getPetFromStore(pos)
    StoreMgr:getPetFromStore(pos)
end

function StorePetDlg:cmdPetToStore(petId)
    StoreMgr:cmdPetToStore(petId)
end

function StorePetDlg:MSG_INSIDER_INFO()
    self:MSG_STORE()
end

-- 仓库
function StorePetDlg:MSG_STORE()
    local pets = StoreMgr.storePets
    self:setSelectClean()

    if self.longPress then
        -- 如果存在长按，取消长按处理
        self.root:stopAction(self.longPress)
        self.longPress = nil
    end

    if pets == nil or table.maxn(pets) == 0 then
        self.storeListCtrl:removeAllItems()
        self:setLabelText("StoreLabel", string.format(CHS[3003658], 0, StoreMgr:getPetStoreMax()))
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
        local pet = pets[StoreMgr:getStartPosByType("pet") - 1 + i]

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

    self:setLabelText("StoreLabel", string.format(CHS[3003658], count, StoreMgr:getPetStoreMax()))
end

function StorePetDlg:MSG_SET_OWNER()
    self:setSelectClean()
    self:initOwnPet()
end

function StorePetDlg:MSG_UPDATE_PETS()
    self:initOwnPet()
end

function StorePetDlg:MSG_UPDATE_SKILLS(data)
    self:initOwnPet(true, data.id)
end

return StorePetDlg
