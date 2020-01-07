-- ExchangeByDlg.lua
-- Created by sujl, Sept/7/2018
-- 提交变异宠物兑换神兽

local ExchangeByDlg = Singleton("ExchangeByDlg", Dialog)

local Pet = require('obj/Pet')

-- 变异宠物列表信息
local VariationPetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

function ExchangeByDlg:init(param)
    self:bindListener("ExchangeButton", self.onExchangeButton)
    self:bindListener("GuardImage", self.onClickItem, "SingleArtifactPanel")
    self:bindCheckBoxListener("ChoiceCheckBox", self.onCheck, "SingleArtifactPanel")

    self.target = param
    self:setLabelText("NameLabel", string.format(CHS[2100229], self.target), "ArtifactInfoPanel")
    self.singleArtifactPanel = self:retainCtrl("SingleArtifactPanel", "ArtifactView")

    self:initPetList()
    self:initSelectPetList()
    self.selects = {}
    self:refreshButton()
end

function ExchangeByDlg:cleanup()
    self.selects = {}
end

-- 初始化已选择列表
function ExchangeByDlg:initSelectPetList()
    local array = {}
    for k, v in pairs(VariationPetList) do
        table.insert(array, v)
    end

    table.sort(array, function(l, r)
        return l.order < r.order
    end)

    local item
    local root = "ArtifactInfoPanel"
    local ctlName
    for i, v in ipairs(array) do
        ctlName = string.format("MainArtifactPanel%d", i)
        item = self:getControl(ctlName, nil, root)
        local petImage = self:getControl("ArtifactIconImage", Const.UIImage, item)
        local path = ResMgr:getSmallPortrait(v.icon)
        petImage:loadTexture(path)
        gf:grayImageView(petImage)
        self:setItemImageSize("ArtifactIconImage", item)
        self:setLabelText("NameLabel", v.name, item)
        self:bindListener(ctlName, self.onClickMainArtifactPanel, root)
    end
end

-- 初始化宠物列表
function ExchangeByDlg:initPetList()
    local list, size = self:resetListView("ArtifactView", 0)
    list:setItemsMargin(6)

    local array = {}
    self:addPets(array, PetMgr.pets)
    self:addStorePets(array, StoreMgr.storePets)
    self:addStorePets(array, StoreMgr.storeHousePets)

    for _, v in ipairs(array) do
        list:pushBackCustomItem(self:createPetItem(v.data, v.pos))
    end
end

-- 增加宠物栏宠
function ExchangeByDlg:addPets(array, pets)
    local pet
    for k, v in pairs(pets) do
        if VariationPetList[v:queryBasic("raw_name")] then
            table.insert(array, { data = v.basic.data, pos = v.basic.data.no })
        end
    end
end

-- 增加仓库宠物数据
function ExchangeByDlg:addStorePets(array, pets)
    for k, v in pairs(pets) do
        if VariationPetList[v.raw_name] then
            table.insert(array, { data = v, pos = k })
        end
    end
end

-- 创建宠物列表项
function ExchangeByDlg:createPetItem(pet, pos)
    local item = self.singleArtifactPanel:clone()
    self:setLabelText("NameLabel", pet.name, item)
    local petLevel = pet.level
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, petLevel, false, LOCATE_POSITION.LEFT_TOP, 21, item)

    local petImage = self:getControl("GuardImage", Const.UIImage, item)
    local path = ResMgr:getSmallPortrait(pet.portrait)
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", item)

    if pos >= 801 then
        self:setLabelText("PositionLabel", CHS[2100230], item)
    elseif pos >= 351 then
        self:setLabelText("PositionLabel", CHS[2100231], item)
    else
        self:setLabelText("PositionLabel", CHS[2100232], item)
    end

    item.pet = pet
    item.pos = pos

    return item
end

-- 限时宠物悬浮框
function ExchangeByDlg:showFloatingCard(data)
    local dlg =  DlgMgr:openDlg("PetCardDlg")
    local pet = Pet.new()
    pet:absorbBasicFields(data)
    dlg:setPetInfo(pet, true)
end

-- 刷新按钮状态
function ExchangeByDlg:refreshButton()
    local count = 0
    for k, v in pairs(self.selects) do
        if v then count = count + 1 end
    end

    self:setCtrlEnabled("ExchangeButton", count >= 12) -- 已选择12只
end

-- 选取宠物
function ExchangeByDlg:onCheck(sender, eventType)
    local pet = sender:getParent().pet
    if not pet then return end
    local pos = sender:getParent().pos
    if not pos then return end
    local status = pet.pet_status
    if 1 == status then
        -- 参战状态
        gf:ShowSmallTips(CHS[2100233])
        sender:setSelectedState(false)
        return
    elseif 2 == status then
        -- 掠阵状态
        gf:ShowSmallTips(CHS[2100234])
        sender:setSelectedState(false)
        return
    elseif PetMgr:isFeedStatus(pet.iid_str) then
        -- 元神状态
        gf:ShowSmallTips(CHS[2100235])
        sender:setSelectedState(false)
        return
    elseif pet.deadline ~= 0 then
        -- 限时
        gf:ShowSmallTips(CHS[2100236])
        sender:setSelectedState(false)
        return
    end

    local rawname = pet.raw_name
    if VariationPetList[rawname] then
        local itemName = string.format("MainArtifactPanel%d", VariationPetList[rawname].order)
        local item = self:getControl(itemName, nil, root)
        local petImage = self:getControl("ArtifactIconImage", Const.UIImage, item)
        if sender:getSelectedState() then
            gf:resetImageView(petImage)
            if self.selects[VariationPetList[rawname].order] then
                -- 已经选择该类宠物，进行替换
                local ls = self.selects[VariationPetList[rawname].order][2]
                if ls ~= sendr then
                    self:setCheck("ChoiceCheckBox", false, ls)
                end
            end
            self.selects[VariationPetList[rawname].order] = { pos, sender:getParent() }
        else
            gf:grayImageView(petImage)
            self.selects[VariationPetList[rawname].order] = nil
        end
    end

    self:refreshButton()
end

-- 兑换宠物
function ExchangeByDlg:onExchangeButton(sender)
    local array = {}
    for _, v in pairs(self.selects) do
        table.insert(array, v[1])
    end

    gf:CmdToServer("CMD_EXCHANGE_EPIC_PET_EXCHANGE", { target = self.target, pos = array })
end

-- 点击宠物图标
function ExchangeByDlg:onClickItem(sender)
    local pet = sender:getParent():getParent().pet
    if not pet then return end
    self:showFloatingCard(pet)
end

function ExchangeByDlg:onClickMainArtifactPanel(sender)
    local order = tonumber(string.match(sender:getName(), "MainArtifactPanel(%d+)"))
    if not order or not self.selects or not self.selects[order] then return end
    local ctrl = self.selects[order][2]
    if not ctrl or not ctrl.pet then return end
    self:showFloatingCard(ctrl.pet)
end

return ExchangeByDlg