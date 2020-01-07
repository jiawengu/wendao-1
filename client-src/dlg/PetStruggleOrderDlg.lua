-- PetStruggleOrderDlg.lua
-- Created by huangzz Sep/20/2017
-- 斗宠大会宠物布阵界面

local PetStruggleOrderDlg = Singleton("PetStruggleOrderDlg", Dialog)

local COMBAT_PLACE_NUM = 6

local CAN_COMBAT_MAX_NUM = 5

function PetStruggleOrderDlg:init()
    self:bindListener("PetPanel", self.onPetPanel)
    self.petPanel = self:retainCtrl("PetPanel")
    self.selectImage = self:retainCtrl("ChosenEffectImage", self.petPanel)

    self.pets = PetMgr:getOrderPets()
    -- self:initPetsListView(self.pets)
    self.petPanels = {}
    -- self:showPetsList({})

    self.combatOrder = {}

    self.petShapePanels = {}
    for i = 1, COMBAT_PLACE_NUM do
        local cell = self:getControl("PetPanel_" .. i)
        cell.isEmpty = true
        cell:setTag(i)

        self:setCtrlVisible("ChosenImage", false, cell)
        self:bindListener("OperateImage", self.onPetShapePanel, cell)

        table.insert(self.petShapePanels, cell)
    end

    self:hookMsg("MSG_DC_PETS")

    self:MSG_DC_PETS(ArenaMgr.combatPetsOrder or {})
end

function PetStruggleOrderDlg:setOnePanel(pet, cell)
    -- 头像
    local icon = pet:queryBasicInt("icon")
    self:setImage("GuardImage", ResMgr:getSmallPortrait(icon), cell)

    -- 名片
    self:bindListener("ShapePanel", function()
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        dlg:setPetInfo(pet, true)
    end, cell)

    -- 宠物等级
    local level = pet:queryBasicInt("level")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 25, cell)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, cell)

    -- 名字
    local name = pet:getShowName()
    self:setLabelText("NameLabel", name, cell)

    -- 类型
    local petRankDesc = gf:getPetRankDesc(pet) or ""
    self:setLabelText("LevelLabel", "(".. petRankDesc .. ")" , cell)

    -- 出阵相关
    self:setCtrlVisible("NumImage", false, cell)
    self:setCtrlVisible("StatusImage", false, cell)
    self:setLabelText("NumLabel", "", cell)
end

function PetStruggleOrderDlg:initPetsListView(data)
    local list = self:resetListView("PetListView", 2, nil)
    local cou = #data
    for i = 1, cou do
        local cell
        local id = data[i]:queryBasicInt("id")
        if not self.petPanels[id] then
            cell = self.petPanel:clone()
            cell:retain()
            self.petPanels[id] = cell
        else
            cell = self.petPanels[id]
        end

        cell:setTag(i)
        self:setOnePanel(data[i], cell)
        list:pushBackCustomItem(cell)
    end

    -- 当前宠物数量和上限值
    self:setLabelText("PetNumberValueLabel", string.format("%d/%d", cou, PetMgr:getPetMaxCount()))
end

function PetStruggleOrderDlg:showPetsList(data)
    local isCombat = {}
    for _, id in pairs(data) do
        isCombat[id] = true
    end

    local function sortFunc(l, r)
        local lIsCombat = isCombat[l:queryBasicInt("id")]
        local rIsCombat = isCombat[r:queryBasicInt("id")]
        if lIsCombat and not rIsCombat then return true end
        if not lIsCombat and rIsCombat then return false end

        local lIntimacy = l:queryInt("intimacy")
        local rIntimacy = r:queryInt("intimacy")
        if lIntimacy > rIntimacy then return true end
        if lIntimacy < rIntimacy then return false end

        local lLevel = l:queryInt("level")
        local rLevel = r:queryInt("level")
        if lLevel > rLevel then return true end
        if lLevel < rLevel then return false end

        local lShape = l:queryInt("shape")
        local rShape = r:queryInt("shape")
        if lShape > rShape then return true end
        if lShape < rShape then return false end

        local lName = l:getName()
        local rName =  r:getName()
        if lName < rName then return true end
        if lName > rName then return false end
    end


    table.sort(self.pets, sortFunc)

    self:initPetsListView(self.pets)
end

function PetStruggleOrderDlg:onPetPanel(sender, eventType)
    if self.selectPetPenel == sender then
        -- 已选中，取消参战
        sender.isCombat = false

        local shapePanel = sender.shapePanel
        local combatNo = shapePanel:getTag()

        self:setChooseStatus(sender, shapePanel, false)

        self.combatOrder[combatNo] = nil
    else
        -- 未选中，判断是否已参战，是则选中参战宠物的形象，否则增加新的参战宠物

        if sender.isCombat then
            -- 已参战
            local shapePanel = sender.shapePanel
            local combatNo = shapePanel:getTag()

            self:setChooseStatus(sender, shapePanel, true)
            return
        end

        local no = sender:getTag()
        local pet = self.pets[no]

        -- 若该宠物等级超过玩家等级15级，给予弹出提示
        local meLevel = Me:queryBasicInt("level")
        if  pet:queryBasicInt("level") - meLevel > 15 then
            gf:ShowSmallTips(CHS[5410167])
            return
        end

        -- 若宠物携带等级超过玩家等级，给予弹出提示
        local reqLevel = pet:queryBasicInt("req_level")
        if reqLevel > meLevel then
            gf:ShowSmallTips(string.format(CHS[5410168], reqLevel))
            return
        end

        -- 若当前出阵的宠物已达5只，无法选中，给予弹出提示
        if self.battleCount >= CAN_COMBAT_MAX_NUM then
            gf:ShowSmallTips(CHS[5450038])
            return
        end

        sender.isCombat = true
        local shapePanel = self:getFirstEmptyShapePanel()
        local combatNo = shapePanel:getTag()

        self:setChooseStatus(sender, shapePanel, true)

        self.combatOrder[combatNo] = pet:queryBasicInt("id")
    end

    -- gf:CmdToServer("CMD_DC_CONFIRM_PETS", self.combatOrder)

    self:MSG_DC_PETS(self.combatOrder)
end

function PetStruggleOrderDlg:setChooseStatus(petPanel, shapePanel, isChoose)
    -- 宠物条目
    self.selectImage:removeFromParent()
    if isChoose then
        petPanel:addChild(self.selectImage)
    end

    self.selectPetPenel = isChoose and petPanel or nil

    -- 出阵宠物形象（取消上次选中状态）
    if self.selectShapePenel then
        self:setCtrlVisible("ChosenImage", false, self.selectShapePenel)
        self:setImage("OperateImage", ResMgr.ui.fight_sel_img, self.selectShapePenel)
    end

    if isChoose then
        self:setImage("OperateImage", ResMgr.ui.dcdh_choose_pet, shapePanel)
        self:setCtrlVisible("ChosenImage", true, shapePanel)
    end

    self.selectShapePenel = isChoose and shapePanel or nil
end

function PetStruggleOrderDlg:onPetShapePanel(sender, eventType)
    local panel = sender:getParent()
    local combatNo = panel:getTag()

    if not self.selectShapePenel then
        if panel.isEmpty then
            return
        end

        local petPanel = panel.petPanel
        self:setChooseStatus(petPanel, panel, true)
        return
    end

    if self.selectShapePenel == panel then
        -- 移除已选中的宠物
        self.combatOrder[combatNo] = nil

        local petPanel = panel.petPanel
        self:setChooseStatus(panel, panel, false)
    else
        -- 交换宠物
        local lastSelectNo = self.selectShapePenel:getTag()
        local temp = self.combatOrder[combatNo]
        self.combatOrder[combatNo] = self.combatOrder[lastSelectNo]
        self.combatOrder[lastSelectNo] = temp

        local petPanel = panel.petPanel
        self:setChooseStatus(petPanel, self.selectShapePenel, false)
    end

    self.selectShapePenel = nil
    -- gf:CmdToServer("CMD_DC_CONFIRM_PETS", self.combatOrder)

    self:MSG_DC_PETS(self.combatOrder)
end

function PetStruggleOrderDlg:getPetById(id)
    for no, v in pairs(self.pets) do
        if id == v:queryBasicInt("id") then
            return v, no
        end
    end
end

-- 获取阵容中编号最小的未放置宠物的位置
function PetStruggleOrderDlg:getFirstEmptyShapePanel()
    for i = 1, #self.petShapePanels do
        if self.petShapePanels[i].isEmpty then
            return self.petShapePanels[i]
        end
    end
end

-- 获取出战宠物数量
function PetStruggleOrderDlg:getChuZhanCount()
    local cou = 0
    for i = 1, #self.petShapePanels do
        if self.petShapePanels[i].isEmpty then
            cou = cou + 1
        end
    end

    return cou
end

-- sortNo 左边列表宠物顺序
-- combatNo 宠物出战顺序
function PetStruggleOrderDlg:setSelectPet(pet, cell, sortNo, combatNo)
    -- 宠物形象
    local icon = pet:getDlgIcon()
    self:setPortrait("ShapePanel", icon, nil, cell, false, nil, nil, cc.p(0, -36), nil, nil, 1)
    local name = pet:getShowName()
    self:setColorTextEx(name, "NamePanel", cell, COLOR3.YELLOW, 20)

    cell.isEmpty = false

    self:setCtrlVisible("BKImage_1", false, cell)
    self:setCtrlVisible("NumImage", false, cell)
    self:setCtrlVisible("BKImage_2", true, cell)
    self:setCtrlVisible("NamePanel", true, cell)
    self:setCtrlVisible("ShapePanel", true, cell)

    -- 调整箭头位置
    local chosenImage = self:getControl("ChosenImage", nil, cell)
    local shapePanel = self:getControl("ShapePanel", nil, cell)
    local char = shapePanel:getChildByTag(self.TAG_PORTRAIT)
    local x, y = char:getHeadOffset()
    chosenImage:setPositionY(y + shapePanel:getContentSize().height / 2 - 36 + chosenImage:getContentSize().height / 2)

    -- 对应的宠物条目
    local list = self:getControl("PetListView")
    local panel = list:getItem(sortNo - 1)
    panel.isCombat = true
    self:setCtrlVisible("NumImage", true, panel)
    self:setCtrlVisible("StatusImage", true, panel)
    self:setLabelText("NumLabel", combatNo, panel)

    cell.petPanel = panel
    panel.shapePanel = cell
end

function PetStruggleOrderDlg:setColorTextEx(str, panelName, root, defColor, fontSize)
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT
    local panel = self:getControl(panelName, Const.UIPanel, root)
    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str, true)
    textCtrl:setContentSize(200, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    panel:setContentSize(textW + 8, textH)

    textCtrl:setPosition(4, textH)

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)

    panel:getParent():requestDoLayout()
end

function PetStruggleOrderDlg:setUnSelectPet(cell)
    -- 宠物形象
    cell.isEmpty = true

    self:setCtrlVisible("BKImage_1", true, cell)
    self:setCtrlVisible("NumImage", true, cell)
    self:setCtrlVisible("BKImage_2", false, cell)
    self:setCtrlVisible("NamePanel", false, cell)
    self:setCtrlVisible("ShapePanel", false, cell)

    -- 对应的宠物条目
    local panel = cell.petPanel
    cell.petPanel = nil
    if panel then
        panel.isCombat = false
        self:setCtrlVisible("NumImage", false, panel)
        self:setCtrlVisible("StatusImage", false, panel)
        self:setLabelText("NumLabel", "", panel)
        panel.shapePanel = nil
    end
end

function PetStruggleOrderDlg:MSG_DC_PETS(data)
    -- 左边宠物条目
    self:showPetsList(data)

    -- 右边宠物形象
    self.battleCount = 0
    self.combatOrder = {}
    for i = 1, COMBAT_PLACE_NUM do
        local cell = self.petShapePanels[i]
        if not data[i] then
            self:setUnSelectPet(cell, i)
        end
    end

    for i = 1, COMBAT_PLACE_NUM do
        local cell = self.petShapePanels[i]
        if data[i] then
            local pet, sortNo = self:getPetById(data[i])

            if pet then
                self:setSelectPet(pet, cell, sortNo, i)
                self.battleCount = self.battleCount + 1
                self.combatOrder[i] = pet:queryBasicInt("id")
            else
                self:setUnSelectPet(cell, i)
            end
        end
    end

    self:setLabelText("Label_2",  self.battleCount .. "/" .. CAN_COMBAT_MAX_NUM, "OrderPanel")
end

function PetStruggleOrderDlg:cleanup()
    if self.battleCount == 0 then
        gf:ShowSmallTips(CHS[5450039])
    else
        gf:CmdToServer("CMD_DC_CONFIRM_PETS", self.combatOrder)
    end

    if self.petPanels then
        for key, v in pairs(self.petPanels) do
            if v then
                v:release()
            end
        end

        self.petPanels = nil
    end

    self.combatOrder = {}
    self.petShapePanels = nil
    self.selectShapePenel = nil
end

return PetStruggleOrderDlg
