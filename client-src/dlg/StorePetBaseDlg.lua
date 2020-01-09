-- StorePetBaseDlg.lua
-- Created by sujl, Sept/3/2018
-- 宠物存取基类

local StorePetBaseDlg = Singleton("StorePetBaseDlg", Dialog)
local DataObject = require("core/DataObject")

function StorePetBaseDlg:init()
    self:bindListener("StorePanel", self.onStorePanel)
    self:bindListener("CatchPanel", self.onCatchPanel)

    self.petInfoPanel = self:retainCtrl("PetPanel")

    self:setSelectClean()
    self:setLabelText("StoreLabel", "")

    local ownListParent = self:getControl("CatchPetListPanel")
    self.ownListCtrl = self:resetListView("PetListView", 0, ccui.ListViewGravity.centerHorizontal, ownListParent)

    local storeListParent = self:getControl("StorePetListPanel")
    self.storeListCtrl = self:resetListView("PetListView", 0, ccui.ListViewGravity.centerHorizontal, storeListParent)

    self:initOwnPet()
end

function StorePetBaseDlg:cleanup()
end

function StorePetBaseDlg:initOwnPet(isUpdate, petId)
    local petArray = PetMgr:getOrderPets()
    self:refreshOwnPet(petArray, isUpdate, petId)
end

function StorePetBaseDlg:setSelectClean()
    self.storeSelectPos = nil
    self.ownSelectPetId = nil
end

function StorePetBaseDlg:setPetInfo(pet, panel)
    if self.longPress then
        -- 如果存在长按，取消长按处理
        self.root:stopAction(self.longPress)
        self.longPress = nil
    end

    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), panel)
    self:setItemImageSize("GuardImage", panel)
    if PetMgr:isTimeLimitedPet(pet) then  -- 限时宠物
        InventoryMgr:addLogoTimeLimit(self:getControl("GuardImage", nil, panel))
    elseif PetMgr:isLimitedPet(pet) then  -- 限制交易宠物
        InventoryMgr:addLogoBinding(self:getControl("GuardImage", nil, panel))
    end

    self:blindLongPress("ShapePanel", nil, self.onPetShape, panel)
    panel:setTag(pet:getId())
    local color = COLOR3.TEXT_DEFAULT
    local statusImg = self:getControl("StatusImage", Const.UIImage, panel)
    statusImg:setVisible(false)
    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        statusImg:setVisible(true)
        color = COLOR3.GREEN
        statusImg:loadTexture(ResMgr.ui.canzhan_flag)
    elseif pet_status == 2 then
        -- 掠阵
        color = COLOR3.YELLOW
        statusImg:loadTexture(ResMgr.ui.luezhen_flag)
        statusImg:setVisible(true)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        statusImg:loadTexture(ResMgr.ui.ride_flag)
        statusImg:setVisible(true)
    end
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel, color)
    if pet:getName() == CHS[3003653] then
        local sss
    end
    self:setLabelText("LevelValueLabel", #SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) .. CHS[3003654], panel, color)
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), panel, color)
    if PetMgr:isMountPet(pet) then
        self:setLabelText("HorseLevelLabel", string.format(CHS[6000532], PetMgr:getMountRankStr(pet)), panel, color)
    end
end

function StorePetBaseDlg:refreshOwnPet(petArray, isUpdate, petId)
    if isUpdate then
        local items = self.ownListCtrl:getItems()
        for i, panel in pairs(items) do
            if panel:getTag() == petId then
                self:setPetInfo(PetMgr:getPetById(petId), panel)
            end
        end
    else
        self.ownListCtrl:removeAllItems()
        if petArray then
            for i, v in pairs(petArray) do
                local panel = self.petInfoPanel:clone()
                if v:queryBasic("name") ~= "" then
                    self:setPetInfo(v, panel)
                    self:bindTouchEndEventListener(panel, self.onPickOwnPet)
                    self.ownListCtrl:pushBackCustomItem(panel)
                end
            end
        end
    end

    local count = 0
    if petArray then count = #petArray end
    self:setLabelText("CatchLabel", string.format(CHS[3003655], count))
end

function StorePetBaseDlg:getStorePetByPos(pos)
     return StoreMgr.storePets[pos]
end

function StorePetBaseDlg:onPet(sender, eventType)
    local parentPanel = sender:getParent()
    self:onPickOwnPet(parentPanel)
end

function StorePetBaseDlg:onPetShape(sender, eventType)
    local parentPanel = sender:getParent()
    local ownSelectPetId = parentPanel:getTag()

    local pet = PetMgr:getPetById(ownSelectPetId)
    if pet then
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end
end

function StorePetBaseDlg:onPetShapeStore(sender, eventType)
    local parentPanel = sender:getParent()
    local storeSelectPos = parentPanel:getTag()

    local dlg =  DlgMgr:openDlg("PetCardDlg")
    local objcet = DataObject.new()
    objcet:absorbBasicFields(self:getStorePetByPos(storeSelectPos))
    dlg:setPetInfo(objcet)
end

function StorePetBaseDlg:onPickOwnPet(sender, eventType)
    if sender:getTag() == 0 then return end
    if self.ownSelectPetId and self.ownSelectPetId == sender:getTag() and self.ownSelectPetId ~= 0 then
        -- 发送寄存信息
        local lastTime = sender.lastTime or 0
        local curTime =  gfGetTickCount()
        if curTime - lastTime > 500 and self:cmdPetToStore(self.ownSelectPetId) then
             gf:ShowSmallTips(CHS[3003656])
            sender.lastTime = gfGetTickCount()
        end
       --return
    end

    self.ownSelectPetId = sender:getTag()
    local items = self.ownListCtrl:getItems()
    for _, panel in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, panel)
    end

    self:setCtrlVisible("ChosenEffectImage", true, sender)
end

function StorePetBaseDlg:getPetFromStore(pos)
    StoreMgr:getPetFromStore(pos)
end

function StorePetBaseDlg:cmdPetToStore(petId)
     StoreMgr:cmdPetToStore(petId)
end

function StorePetBaseDlg:onPickStorePet(sender, eventType)
    if sender:getTag() == 0 then return end

    if self.storeSelectPos and self.storeSelectPos == sender:getTag() and self.storeSelectPos ~= 0 then
        -- 发送寄存信息
        local lastTime = sender.lastTime or 0
        local curTime =  gfGetTickCount()
        if curTime - lastTime > 500 and self:getPetFromStore(self.storeSelectPos) then
            sender.lastTime = gfGetTickCount()
        end

        --return
    end

    self.storeSelectPos = sender:getTag()
    local items = self.storeListCtrl:getItems()
    for _, panel in pairs(items) do
        self:setCtrlVisible("ChosenEffectImage", false, panel)
    end

    self:setCtrlVisible("ChosenEffectImage", true, sender)
end

function StorePetBaseDlg:onStorePanel(sender, eventType)
    local lastTime = sender.lastTime or 0
    local curTime =  gfGetTickCount()
    if curTime - lastTime > 500 and self:cmdPetToStore(self.ownSelectPetId) then
        sender.lastTime = curTime
    end
end

function StorePetBaseDlg:onCatchPanel(sender, eventType)
    local lastTime = sender.lastTime or 0
    local curTime =  gfGetTickCount()
    if curTime - lastTime > 500 and self:getPetFromStore(self.storeSelectPos) then
        sender.lastTime = curTime
    end
end

return StorePetBaseDlg
