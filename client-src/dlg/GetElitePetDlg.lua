-- GetElitePetDlg.lua
-- Created by songcw Mar/26/2015
-- 获得变异宠物界面   秘笈

local GetElitePetDlg = Singleton("GetElitePetDlg", Dialog)

-- 变异宠物列表信息
local VariationPetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

function GetElitePetDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton", Const.UIButton, "NormalPanel"), SHARE_FLAG.GETELITEPET, nil, function()
        self:setCtrlVisible("ShareButton", false, "NormalPanel")
        self:setCtrlVisible("ContinueButton", false, "NormalPanel")
    end, function()
        self:setCtrlVisible("ShareButton", true, "NormalPanel")
        self:setCtrlVisible("ContinueButton", true, "NormalPanel")
    end)
    self:bindListener("ContinueButton", self.onContinueButton, "NormalPanel")

    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton", Const.UIButton, "PetCallButtonPanel"), SHARE_FLAG.GETELITEPET, nil, function()
        self:setCtrlVisible("ShareButton", false, "PetCallButtonPanel")
        self:setCtrlVisible("ContinueButton", false, "PetCallButtonPanel")
        self:setCtrlVisible("InfoButton", false, "PetCallButtonPanel")
    end, function()
        self:setCtrlVisible("ShareButton", true, "PetCallButtonPanel")
        self:setCtrlVisible("ContinueButton", true, "PetCallButtonPanel")
        self:setCtrlVisible("InfoButton", true, "PetCallButtonPanel")
    end)
    self:bindListener("ContinueButton", self.onContinueButton, "PetCallButtonPanel")
    self:bindListener("ChangeButton", self.onChangeButton, "PetCallButtonPanel")
    self:bindListener("InfoButton", self.onInfoButton, "PetCallButtonPanel")

    self:setCtrlVisible("PetImage", false)
    self:setCtrlVisible("BookPanel", false)

    self:setCtrlVisible("NormalPanel", true)
    self:setCtrlVisible("PetCallButtonPanel", false)

    self.angel = 0

    self.rotationImage = self:getControl("RotationImage")

    -- 设置层次（要比确认框层级高，因为有可能，藏宝图挖到宠物，然后要继续挖宝，确认框会盖在上面）
    self.root:setLocalZOrder(Const.ZORDER_DIALOG + 1)
end

function GetElitePetDlg:onContinueButton()
    if not GiftMgr:doShowGetItemAction() then
        self:onCloseButton()
    end
end

function GetElitePetDlg:cleanup()
    self.curPet = nil
    if self.dlgName then
        DlgMgr:sendMsg(self.dlgName, "onDlgClose", self.name)
        self.dlgName = nil
    end

    GiftMgr:clearGetItemInfo()
end

function GetElitePetDlg:onUpdate()
    self.angel = self.angel + 0.8
    self.rotationImage:setRotation(self.angel)
end

function GetElitePetDlg:setNotifyDlg(dlgName)
    self.dlgName = dlgName
end

function GetElitePetDlg:setDlgInfo(name, type)
    if type == NOTIFY.NOTICE_BUY_ELITE_PET then
        self:setPetName(name)
    else
        self:setBook(name)
    end
end

function GetElitePetDlg:setBook(name)
    self:setCtrlVisible("BookPanel", true)

    -- 设置名字
    self:setImage("NameImage1", InventoryMgr:getItemInfoByName(name).artName)
    -- 设置形象
    local icon = InventoryMgr:getIconByName(name)
    self:setImage("BookImage",  ResMgr:getItemIconPath(icon))
    self:setItemImageSize("BookImage")

    self:setCtrlVisible("NormalPanel", true)
    self:setCtrlVisible("PetCallButtonPanel", false)

    self.curPet = nil
end

function GetElitePetDlg:setPetName(name)
    self:setCtrlVisible("PetImage", true)

    local info = PetMgr:getPetCfg(name)

    -- 设置名字
    if info.artName then
        self:setImage("NameImage1", info.artName)
    end

    -- 设置形象
    if info.icon then
        self:setImage("PetImage", ResMgr:getBigPortrait(info.icon))
    end

    self:setCtrlVisible("NormalPanel", true)
    self:setCtrlVisible("PetCallButtonPanel", false)

    self.curPet = nil
end

function GetElitePetDlg:setPet(pet)
    self:setCtrlVisible("PetImage", true)

    if not pet then return end

    local info = PetMgr:getPetCfg(pet:getName())

    -- 设置名字
    if info.artName then
        self:setImage("NameImage1", info.artName)
    end

    -- 设置形象
    if info.icon then
        self:setImage("PetImage", ResMgr:getBigPortrait(info.icon))
    end

    self:setCtrlVisible("ChangeButton", PetMgr:isMountPet(pet) and info.capacity_level <= 4, "PetCallButtonPanel")
    self:setCtrlVisible("ShareButton", not PetMgr:isMountPet(pet) or info.capacity_level >4, "PetCallButtonPanel")

    self:setCtrlVisible("NormalPanel", false)
    self:setCtrlVisible("PetCallButtonPanel", true)

    self.curPet = pet
end

function GetElitePetDlg:getPetIconByName(name)
    for _,pet in pairs(VariationPetList) do
        if name == pet.name then
            return pet.icon
        end
    end
end

function GetElitePetDlg:onChangeButton(sender, eventType)
    PetMgr:changeMount(self.curPet)
    self:onCloseButton()
end

function GetElitePetDlg:onInfoButton(sender, eventType)
    if not self.curPet then return end

    DlgMgr:openDlg("PetHorseDlg")
    performWithDelay(self.root,function ()
        DlgMgr:sendMsg("PetListChildDlg", "selectPetId", self.curPet:getId())
        self:onCloseButton()
    end, 0)
end

function GetElitePetDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

return GetElitePetDlg
