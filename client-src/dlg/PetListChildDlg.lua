-- PetListChildDlg.lua
-- Created by cheny Dec/23/2014
-- 宠物列表对话框

local ITEM_HEIGHT = 80

local PetListChildDlg = Singleton("PetListChildDlg", Dialog)

local MARGIN = 6

function PetListChildDlg:init()
    self.selectId = 0
    self.selectPet = nil
    self.selectImg = nil
    self.dirty = true
    self.selectPetNo = nil

    self.addPanel = self:getControl("PetEmptyPanel", Const.UIPanel)
    self.addPanel:retain()
    self.addPanel:removeFromParent()

    self.selectImgModle = self:getControl("ChosenEffectImage", Const.UIImage)
    self.selectImgModle:retain()
    self.selectImgModle:removeFromParent()

    self.petPanel = self:getControl("PetPanel", Const.UIPanel)
    self.petPanel:retain()
    self.petPanel:removeFromParent()

    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_SET_CURRENT_PET")
    self:hookMsg("MSG_SET_CURRENT_MOUNT")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SET_SETTING")

    self:hookMsg("MSG_SWITCH_SERVER")


    EventDispatcher:addEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function PetListChildDlg:getSelectImg()
    if nil == self.selectImg then
        local img = self.selectImgModle:clone()
        img:retain()
        img:setVisible(true)
        img:setPosition(0,0)
        img:setAnchorPoint(0,0)
        self.selectImg = img
    end
    return self.selectImg
end

function PetListChildDlg:updateSelectPet()
    if not DlgMgr:getDlgByName("PetHorseDlg") then
        if self.selectPet then
            self.selectPetNo = self.selectPet:queryBasicInt("no")   -- 换线需要记住no，有可能刷新时，宠物都还没有下发
            if PetMgr:getPetByNo(self.selectPetNo) then
                self.selectPet = PetMgr:getPetByNo(self.selectPetNo)
                self.selectId = self.selectPet:getId()
            else
                self.selectPet = nil
                self.selectId = 0
            end
        end

        -- 换线后，有可能刷的时候，PetMgr里面还没有宠物，所以在检测一下
        if self.selectPetNo and PetMgr:getPetByNo(self.selectPetNo) then
            self.selectPet = PetMgr:getPetByNo(self.selectPetNo)
            self.selectId = self.selectPet:getId()
        else
            self.selectPet = nil
            self.selectId = 0
        end
    end
end

function PetListChildDlg:onUpdate()
    if self.dirty == true then

        self:updateSelectPet()

        self:initPetList()
    end
end

function PetListChildDlg:getCurrentPet()
    if self.selectId == nil or self.selectId == 0 then return end
    return PetMgr:getPetById(self.selectId)
end

function PetListChildDlg:getSelectpet()
    return self.selectPet
end

function PetListChildDlg:cleanSelectPetNo()
    self.selectPetNo = nil
end

-- 骑乘界面是否打开
function PetListChildDlg:isInPetHorseDlg()
    return DlgMgr:getDlgByName("PetHorseDlg")
end

-- defaultSpecailPet 是否默认选中非野生宠物
function PetListChildDlg:initPetList(showFlag, para)
	-- 换线过程中，不重复刷新
    if DistMgr:getIsSwichServer() then return end

    self.dirty = false

    self:getSelectImg():removeFromParent(false)

    local list, size = self:resetListView("PetListView", 0)
    list:setItemsMargin(6)
    self.petListSize = size

    local pets = PetMgr.pets
    if pets == nil or table.maxn(pets) == 0 then
        DlgMgr:sendMsg("PetAttribDlg", "setPetInfo", nil)
        DlgMgr:sendMsg("PetEffectDlg", "setPetInfo", nil)
        DlgMgr:sendMsg("PetStoneDlg",  "setPetInfo", nil)
        DlgMgr:sendMsg("PetSkillDlg",  "setPetInfo", nil)
        DlgMgr:sendMsg("PetHorseDlg",  "setPetInfo", nil)
        list:pushBackCustomItem(self:createAddPet())

        self:setLabelText("PetNumberValueLabel", "")
        self:updateLayout("PetNumberPanel")
        return
    end

    local array = {}
    local selectId = 0
    local selectName = nil
    for k, v in pairs(pets) do
        table.insert(array,v)
        if v:queryBasicInt("pet_status") == 1 then
            selectId = v:getId() -- 默认选择参战宠物
        end
    end

    if self:isInPetHorseDlg() then
        table.sort(array, function(l,r) return PetMgr:compareMountPet(l,r) end)
        selectId = PetMgr:getRideId() or 0
    else
        table.sort(array, function(l,r) return PetMgr:comparePet(l,r) end)
    end

    if selectId == 0 and #array > 0 then
        if (self:isInPetHorseDlg() and 0 ~= array[1]:queryInt("mount_type")) or not self:isInPetHorseDlg() then
            selectId = array[1]:getId()
        end
    end
    if self.selectId > 0 then selectId = self.selectId end

    local notWildPetIdCanLearn = false
    if showFlag == 'tianji' then
        -- 学习天技
        notWildPetIdCanLearn = PetMgr:haveNotWildPetCanLearnRawSkill(para)
    end

    local index = 0
    self.selectPet = nil
    for i, v in pairs(array) do
        local rank = v:queryInt('rank')
        if showFlag == 'notWildFirst' and selectName == nil and rank ~= Const.PET_RANK_WILD then
            --  需要选中第一个非野生的宠物
            selectId = v:getId()
            selectName = v:getName()
        end

        if showFlag == 'babyFirst' and selectName == nil and rank == Const.PET_RANK_BABY then
            --  需要选中第一个宝宝宠物
            selectId = v:getId()
            selectName = v:getName()
        end

        if showFlag == 'wildFirst' and selectName == nil and rank == Const.PET_RANK_WILD then
            --  需要选中第一个野生宠物
            selectId = v:getId()
            selectName = v:getName()
        end

        if showFlag == 'tianji' and selectName == nil then
            -- 学习天技
            -- 如果有非野生宠物可学习，则需要选中该宠物
            -- 如果有野生宠物可学习，则需要选中该宠物
            if PetMgr:mayPetHaveRawSkill(v:queryBasic('raw_name'), para) then
                if notWildPetIdCanLearn and v:getId() == notWildPetIdCanLearn or
                    not notWildPetIdCanLearn and rank == Const.PET_RANK_WILD then
                    selectId = v:getId()
                    selectName = v:getName()
                end
            end
        end

        if v:getId() == selectId then
            local oneHeight = self.petPanel:getContentSize().height
            local curHeight = i * oneHeight + (i - 1) * MARGIN
            if curHeight > size.height then
                if i < #array then curHeight = curHeight + oneHeight + MARGIN end
                list:getInnerContainer():setPositionY(math.max(curHeight - size.height))
            end
        end

        -- 增加项
        if self.selectPetNo and PetMgr:getPetByNo(self.selectPetNo) then
            list:pushBackCustomItem(self:createPetItem(v, v:queryBasicInt("no") == self.selectPetNo))
        else
        list:pushBackCustomItem(self:createPetItem(v, v:getId() == selectId))
    end
    end

    if PetMgr:getFreePetCapcity() > 0 then
        list:pushBackCustomItem(self:createAddPet())
    end

    -- 设置当前宠物和宠物上限值
    self:setLabelText("PetNumberValueLabel", string.format("%d/%d", #array, PetMgr:getPetMaxCount()))
    self:updateLayout("PetNumberPanel")

    if not self.selectPet and self:isInPetHorseDlg() then
        DlgMgr:sendMsg("PetHorseDlg",  "setPetInfo", nil)
    end

    return selectName
end

function PetListChildDlg:selectPetId(petId)
    if petId == nil then return end
    if not PetMgr:getPetById(petId) then return end
    self:setSelectPet(petId)
    local list = self:getControl("PetListView")
    local items = list:getItems()
    for i, panel in pairs(items) do
        if panel.pet then
            if panel.pet:getId() == petId then
                self:onselectPet(panel)
            end
        end
    end
end

function PetListChildDlg:onselectPet(sender, eventType)
    if not sender.pet then return end

    if DlgMgr:getDlgByName("PetHorseDlg") and sender.pet then
        local mount_type = sender.pet:queryInt("mount_type")
        if mount_type == 0 then -- 非精怪御灵
            gf:ShowSmallTips(CHS[2000160])
            return
        end
    end

    local img = self:getSelectImg()
    img:removeFromParent(false)
    sender:addChild(img)
    DlgMgr:sendMsg("PetAttribDlg", "setPetInfo", sender.pet)
    DlgMgr:sendMsg("PetEffectDlg", "setPetInfo", sender.pet)
    DlgMgr:sendMsg("PetStoneDlg",  "setPetInfo", sender.pet)
    DlgMgr:sendMsg("PetSkillDlg", "setPetInfo", sender.pet)
    DlgMgr:sendMsg("PetGetAttribDlg", "setPetInfo", sender.pet)
    DlgMgr:sendMsg("PetHorseDlg", "setPetInfo", sender.pet)
    self.selectId = sender.pet:getId()
    self.selectPet = sender.pet
    self.selectPetNo = sender.pet:queryBasicInt("no")

    if sender.pet then
        DlgMgr:sendMsg("PetTabDlg", "setLastSelectItemId", sender.pet:getId())
        PetMgr:setLastSelectPet(sender.pet)
    end
end

function PetListChildDlg:createPetItem(pet, select)
    local pet_status = pet:queryInt("pet_status")
    local petPanel = self.petPanel:clone()
    petPanel:setTag(pet:queryBasicInt("id"))
    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onselectPet(sender, eventType)
        end
    end
    petPanel:addTouchEventListener(selectPet)
    petPanel.pet = pet
    local petImage = self:getControl("GuardImage", Const.UIImage, petPanel)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", petPanel)

    local petNameLabel = self:getControl("NameLabel", Const.UILabel, petPanel)
 --   petNameLabel:setString(gf:getPetName(pet.basic))
    petNameLabel:setString(pet:getShowName())

    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, petPanel)
    local petRankDesc = gf:getPetRankDesc(pet) or ""
    petLevelValueLabel:setString("(".. petRankDesc .. ")")

    -- 宠物等级
    local petLevel = pet:queryBasicInt("level")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, petLevel, false, LOCATE_POSITION.LEFT_TOP, 25, petPanel)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, petPanel)

    local statusImg = self:getControl("StatusImage", Const.UIImage, petPanel)
    statusImg:setVisible(false)

    if pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        petNameLabel:setColor(COLOR3.GREEN)
        petLevelValueLabel:setColor(COLOR3.GREEN)
   --     polarValueLabel:setColor(COLOR3.GREEN)
        statusImg:loadTexture(ResMgr.ui.canzhan_flag_new)

    elseif pet_status == 2 then
        -- 掠阵
        petNameLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
        petLevelValueLabel:setColor(COLOR3.YELLOW)
    --    polarValueLabel:setColor(COLOR3.YELLOW)
        if 1 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        else
            statusImg:loadTexture(ResMgr.ui.luezhen_flag_new)
        end
        statusImg:setVisible(true)
    elseif PetMgr:isRidePet(pet:getId()) then -- 骑乘状态
        statusImg:loadTexture(ResMgr.ui.ride_flag_new)
        if 2 == SystemSettingMgr:getSettingStatus("award_supply_pet", 0) then
            statusImg:loadTexture(ResMgr.ui.gongtong_flag_new)
        end
        statusImg:setVisible(true)
    end


    -- 默认选择
    if select then
        selectPet(petPanel, ccui.TouchEventType.ended)
    end

    local mount_type = pet:queryInt("mount_type")
    local backImage = self:getControl("BackImage", nil, petPanel)
    if self:isInPetHorseDlg() and mount_type == 0 then
        gf:grayImageView(backImage)
        gf:grayImageView(petImage)
    else
        gf:resetImageView(backImage)
        gf:resetImageView(petImage)
    end

    return petPanel
end

function PetListChildDlg:createAddPet()
    local addPanel= self.addPanel:clone()
    local tip = ""
    local isHorseList = self:isInPetHorseDlg()

    if isHorseList then
        self:setLabelText("GetPetsLabel", CHS[6000552], addPanel)
        tip = CHS[6000554]
    else
        self:setLabelText("GetPetsLabel", CHS[6000551], addPanel)
        tip = CHS[3003408]
    end

    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local img = self:getSelectImg()
            img:removeFromParent(false)
            addPanel:addChild(img)
        end
    end

    local function gotoPetBook(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            gf:confirm(tip,function()
                local petTabDlg = DlgMgr:getDlgByName("PetTabDlg")

                if petTabDlg then
                    petTabDlg.group:setSetlctByName("PetHandbookDlgCheckBox")
                else
                    DlgMgr:openDlg("PetHandbookDlg")
                    DlgMgr.dlgs["PetTabDlg"].group:setSetlctByName("PetHandbookDlgCheckBox")
                end

                local dlg = DlgMgr:getDlgByName("PetHandbookDlg")
                if dlg and isHorseList then
                    dlg:selectType("mount")
                end

            end)
        end
    end

    addPanel:addTouchEventListener(gotoPetBook)

    return addPanel
end


function PetListChildDlg:setSelectPet(petId)
    if not petId then return end
    self.selectId = petId or 0
    self.selectPet = PetMgr:getPetById(petId)
end

function PetListChildDlg:MSG_SET_OWNER(data)
    self.dirty = true
    if data.owner_id == 0 and data.id == self.selectId then
        self.selectId = 0
        self.selectPet = nil
    end
end

function PetListChildDlg:MSG_UPDATE(data)
    self.dirty = true
end

function PetListChildDlg:MSG_UPDATE_PETS(data)
    self.dirty = true
end

function PetListChildDlg:MSG_SET_CURRENT_PET(data)
    self.dirty = true
end

function PetListChildDlg:MSG_UPDATE_IMPROVEMENT(data)
    self.dirty = true
end

function PetListChildDlg:MSG_SET_SETTING(data)
    self.dirty = true
end

-- 换线后ID会发生变化，所以先把panel的pet设置为nil，防止还没有刷新的时候就通过id获取错误（若刚好id和旧的其他宠物一只，则选择的宠物会发生变化）
-- 不直接remove所有panel，是为了表现上好一些
function PetListChildDlg:MSG_SWITCH_SERVER(data)
    local list = self:getControl("PetListView")
    local items = list:getItems()
    for i, panel in pairs(items) do
        panel.pet = nil
    end
end


function PetListChildDlg:refreshList()
    self.dirty = true

    if self:isInPetHorseDlg() then
        self.selectId = 0
    end
end

function PetListChildDlg:cleanup()
    self:releaseCloneCtrl("addPanel")
    self:releaseCloneCtrl("selectImgModle")
    self:releaseCloneCtrl("petPanel")
    self:releaseCloneCtrl("selectImg")
    self.selectId = 0

    EventDispatcher:removeEventListener("doOpenDlgRequestData", self.onOpenDlgRequestData, self)
end

function PetListChildDlg:onOpenDlgRequestData(sender, eventType)
    local pet = self:getSelectpet()
    if pet then
        local no = pet:queryInt("no")
        pet = PetMgr:getPetByNo(no)

        if pet then
            self:selectPetId(pet:getId())
        end
    end
end

function PetListChildDlg:getSelectItemBox(clickItem)
    if clickItem == "petStone" then
        local list = self:getControl("PetListView")
        local size = list:getContentSize()
        local items = list:getItems()
        local cou = #items
        for i = 1, cou do
            local pet = items[i].pet
            if pet and self.selectId ~= pet:getId() and pet:getLevel() >= 30 and pet:queryBasicInt("stone_num") == 0 and pet:queryInt('rank') ~= Const.PET_RANK_WILD then
                local oneHeight = self.petPanel:getContentSize().height
                local curHeight = i * oneHeight + (i - 1) * MARGIN
                local totalHieght = cou * oneHeight + (cou - 1) * MARGIN
                if curHeight > size.height then
                    if i < cou then curHeight = curHeight + oneHeight + MARGIN end
                    list:getInnerContainer():setPositionY(curHeight - totalHieght)
                end

                return self:getBoundingBoxInWorldSpace(items[i])
            end
        end
    end
end

-- 打开界面需要某些参数需要重载这个函数
function PetListChildDlg:onDlgOpened(param)
    self.selectId = tonumber(param) or 0
    self:initPetList()
end

return PetListChildDlg
