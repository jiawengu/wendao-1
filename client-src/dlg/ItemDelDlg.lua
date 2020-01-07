-- ItemDelDlg.lua
-- Created by 
-- 

local ItemDelDlg = Singleton("ItemDelDlg", Dialog)

function ItemDelDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("1Button", self.onNumberlButton)
    self:bindListener("2Button", self.onNumberlButton)
    self:bindListener("3Button", self.onNumberlButton)
    self:bindListener("4Button", self.onNumberlButton)
    self:bindListener("5Button", self.onNumberlButton)
    self:bindListener("6Button", self.onNumberlButton)
    self:bindListener("7Button", self.onNumberlButton)
    self:bindListener("8Button", self.onNumberlButton)
    self:bindListener("9Button", self.onNumberlButton)
    self:bindListener("0Button", self.onNumberlButton)
    self:bindListener("DeleteButton", self.onDeleteButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)
    
    self:setCtrlVisible("DelButton", false)
    self.inputNumber = ""
end

function ItemDelDlg:setData(data)
    if data.type == Const.BUYBACK_TYPE_PET then
        -- 销毁贵重宠物
        local pet = PetMgr:getPetById(data.id)  
        self:setPetInfoView(pet, data.life)
    elseif data.type == Const.BUYBACK_TYPE_EQUIPMENT then
        -- 销毁贵重装备、首饰、法宝
        local item = InventoryMgr:getItemByPos(data.id)
        self:setEquipInfoView(item, data.life)
    end
    
    self.life = data.life
end

function ItemDelDlg:setEquipInfoView(item, life)
    self:setImage("ItemImage", ResMgr:getItemIconPath(item.icon), "ItemPanel")
    self:setLabelText("NameLabel", item.name)
    self:setLabelText("NoteLabel", string.format(CHS[5420162], item.name))
    self:setLabelText("ValueLabel", life)
end

function ItemDelDlg:setPetInfoView(pet, life)
    local name = pet.name or pet:queryBasic("name")
    self:setImage("ItemImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), "ItemPanel")
    self:setLabelText("NameLabel", name)
    self:setLabelText("NoteLabel", string.format(CHS[5420162], name))
    self:setLabelText("ValueLabel", life)
end

function ItemDelDlg:onDelButton(sender, eventType)
    self.inputNumber = ""
    self:setInputText()
end

function ItemDelDlg:onNumberlButton(sender, eventType)
    local number = sender:getTag() or ""
    if string.len(self.inputNumber) >= 8 then
        gf:ShowSmallTips(CHS[5400041])
        return
    end

    self.inputNumber = self.inputNumber .. number
    self:setInputText()
end

function ItemDelDlg:onDeleteButton(sender, eventType)
    local lenth = string.len(self.inputNumber)

    if lenth > 0 then
        self.inputNumber = string.sub(self.inputNumber, 1, lenth - 1)
    else
        self.inputNumber = ""
    end

    self:setInputText()
end

function ItemDelDlg:onConfrimButton(sender, eventType)
    local inputNumber = self.inputNumber 

    if tonumber(inputNumber) ~= self.life then 
        gf:ShowSmallTips(CHS[5420163])
        return
    end
    
    gf:CmdToServer("CMD_DESTROY_VALUABLE_CONFIRM", {life = self.life})
    DlgMgr:closeDlg(self.name)
end

function ItemDelDlg:setInputText()
    if self.inputNumber == "" then
        self:setLabelText("DefaultLabel", CHS[3002306], nil, COLOR3.GRAY)
        self:setCtrlVisible("DelButton", false)
    else
        self:setLabelText("DefaultLabel", self.inputNumber, nil, COLOR3.WHITE)
        self:setCtrlVisible("DelButton", true)
    end
end

return ItemDelDlg
