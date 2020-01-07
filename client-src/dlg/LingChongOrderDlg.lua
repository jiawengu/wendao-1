-- LingChongOrderDlg.lua
-- Created by lixh Api/08/2018
-- 灵宠环境布阵界面

local LingChongOrderDlg = Singleton("LingChongOrderDlg", Dialog)

-- 宠物站位数量
local PET_INFIGHT_POS_MAX = 10

-- 未上阵宠物位置标记
local NOT_INFIGHT_POS = 0

-- 上阵宠物标记
local INFIGHT_PET_TAG = 999

-- 天生技能
local INNATE_SKILLS = {
    CHS[3003416], CHS[3003417], CHS[3003418], CHS[3003420], CHS[3003421],
    CHS[3003422], CHS[3003425], CHS[3003426], CHS[3003427], CHS[3003428], CHS[3003429],
}

-- 宠物技能面板，单个技能类别控件高度
local SKILL_LIST_PANEL_HEIGHT = 82

function LingChongOrderDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("EnterButton", self.onEnterButton)
    self:bindFloatPanelListener("PetSkillPanel")
    self:bindFloatPanelListener("RulePanel")

    self.selectImg = self:retainCtrl("ChosenEffectImage", "PetListPanel")
    self.petListItem = self:retainCtrl("PetPanel", "PetListPanel")
    self.skillPanel1 = self:retainCtrl("SkillListPanel1", "PetSkillPanel")
    self.skillPanel2 = self:retainCtrl("SkillListPanel2", "PetSkillPanel")
    self.skillPanel3 = self:retainCtrl("SkillListPanel3", "PetSkillPanel")

    self.inFightPets = {}
    self.adjustPetPanel = nil

    self:cleanInFightPanel()
    self:bindFightPetListener()
    self:initPetList()
    self:refreshInFightPetCount()
end

-- 设置界面上阵数据
function LingChongOrderDlg:setData(data)
    -- 先清空已上阵宠物
    for i = 1, PET_INFIGHT_POS_MAX do
        local panel = self:getControl("PetPanel_" .. i, Const.UIPanel, "OrderPanel")
        self:setPetFightPanel(panel.listItem, nil, i, false)
    end

    -- 设置宠物
    local listView = self:getControl("PetListView", Const.UIListView)
    local items = listView:getItems()
    for i = 1, data.count do
        local petInfo = data.list[i]
        for j = 1, #items do
            local pet = items[j].pet
            if pet and pet:queryBasicInt('no') == petInfo.no then
                self:setPetFightPanel(items[j], pet, petInfo.pos, false)
            end
        end
    end

    -- 宠物上阵信息变化后，重新设置宠物列表排序
    self:initPetList()

    -- 设置怪物
    for i = 1, PET_INFIGHT_POS_MAX do
        local root = self:getControl("MonsterPanel" .. i)
        self:setCtrlVisible("ShapePanel", false, root)
        self:setCtrlVisible("NamePanel", false, root)
    end

    for i = 1, data.monsterCount do
        self:monsterInFight(data.monsterList[i])
    end
end

-- 怪物上阵
function LingChongOrderDlg:monsterInFight(monster)
    if not monster then return end
    local root = self:getControl("MonsterPanel" .. monster.pos)
    self:setCtrlVisible("ShapePanel", true, root)
    self:setCtrlVisible("NamePanel", true, root)
    local shapePanel = self:getControl("ShapePanel", nil, root)
    shapePanel:setLocalZOrder(1)
    self:setPortrait("ShapePanel", monster.icon, nil, root, false, nil, nil, cc.p(0, -36), nil, nil, 5)
    self:setColorTextEx(monster.name, "NamePanel", root, COLOR3.YELLOW, 20, true)
end

function LingChongOrderDlg:setColorTextEx(str, panelName, root, defColor, fontSize)
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
    local textW, textH = textCtrl:getRealSize()
    panel:setContentSize(textW + 8, textH)

    textCtrl:setPosition(4, textH)

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)

    panel:getParent():requestDoLayout()
end

-- 上阵区域点击事件
function LingChongOrderDlg:bindFightPetListener()
    local function onFightPetPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local clickPanel = sender:getParent()
            local clickPet = clickPanel.pet
            local adjustPet = nil
            if self.adjustPetPanel then
                adjustPet = self.adjustPetPanel.pet
            end

            if clickPet then
                if adjustPet then
                    if clickPet:getId() == adjustPet:getId() then
                        -- 待调整宠物，为当前宠物，取消选中，取消上阵
                        local cell = clickPanel.listItem
                        local pos = self:getPetInFightPos(clickPet)
                        self.inFightPets[pos] = nil
                        self.adjustPetPanel = nil
                        self:saveFightPetToServer()
                    else
                        -- 待调整宠物，非当前宠物，交换两只宠物
                        local oldCell = self.adjustPetPanel.listItem
                        local newCell = clickPanel.listItem
                        local oldPos = self:getPetInFightPos(adjustPet)
                        local newPos = self:getPetInFightPos(clickPet)
                        self.inFightPets[oldPos] = clickPet
                        self.inFightPets[newPos] = adjustPet
                        self.adjustPetPanel = nil
                        self:saveFightPetToServer()
                    end
                else
                    -- 没有待调整的宠物，设置当前宠物为待调整的宠物
                    self:setArrowAndLightCircle(clickPanel, true)
                    self.adjustPetPanel = clickPanel
                end
            else
                -- 点击空白，有待调整宠物时移动宠物，无待调整宠物时无响应
                if adjustPet then
                    local cell = self.adjustPetPanel.listItem
                    local oldPos = self:getPetInFightPos(adjustPet)
                    local newPos = clickPanel.pos
                    self.inFightPets[oldPos] = nil
                    self.inFightPets[newPos] = adjustPet
                    self.adjustPetPanel = nil
                    self:saveFightPetToServer()
                end
            end
        end
    end

    for i = 1, PET_INFIGHT_POS_MAX do
        local root = self:getControl("PetPanel_" .. i, Const.UIPanel, "OrderPanel")
        root.pos = i
        local panel = self:getControl("ShapePanel", Const.UIPanel, root)
        panel:addTouchEventListener(onFightPetPanel)
    end
end

-- 初始化宠物列表
function LingChongOrderDlg:initPetList()
    local listView = self:resetListView("PetListView", 6)
    local pets = PetMgr.pets
    local array = {}
    for k, v in pairs(pets) do
        table.insert(array,v)
    end

    -- 根据已上阵宠物列表给宠物打上上阵编号， 用于排序
    for i = 1, #array do
        array[i].fightNum = self:getPetInFightPos(array[i])
    end

    table.sort(array, function(l, r)
        if l.fightNum == 0 or r.fightNum == 0 then
            -- 两只宠物至少有一只未上阵，则需要比较上阵编号
            if l.fightNum > r.fightNum then return true end
            if l.fightNum < r.fightNum then return false end
        end

        if l:queryInt("intimacy") > r:queryInt("intimacy") then return true end
        if l:queryInt("intimacy") < r:queryInt("intimacy") then return false end
        if l:queryInt("level") > r:queryInt("level") then return true end
        if l:queryInt("level") < r:queryInt("level") then return false end
        if l:queryInt("shape") > r:queryInt("shape") then return true end
        if l:queryInt("shape") < r:queryInt("shape") then return false end
        if l:getName() < r:getName() then return true else return false end
    end)

    for i = 1, #array do
        listView:pushBackCustomItem(self:setCellItem(array[i]))
    end

    -- 当前宠物数量和上限值
    self:setLabelText("PetNumberValueLabel", string.format("%d/%d", #array, PetMgr:getPetMaxCount()))
end

-- 设置宠物控件内容
function LingChongOrderDlg:setCellItem(pet)
    local panel = self.petListItem:clone()
    panel.pet = pet

    -- 头像
    local petImage = self:getControl("GuardImage", Const.UIImage, panel)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    petImage:loadTexture(path)
    self:setItemImageSize("GuardImage", panel)

    -- 名称
    local petNameLabel = self:getControl("NameLabel", Const.UILabel, panel)
    petNameLabel:setString(pet:getShowName())

    -- 宠物类型：精怪，宝宝等
    local petLevelValueLabel = self:getControl("LevelLabel", Const.UILabel, panel)
    local petRankDesc = gf:getPetRankDesc(pet) or ""
    petLevelValueLabel:setString("(".. petRankDesc .. ")")

    -- 等级
    local petLevel = pet:queryBasicInt("level")
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, petLevel, false, LOCATE_POSITION.LEFT_TOP, 25, panel)

    -- 设置宠物相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, panel)

    -- 上阵位置
    local inFightPos = self:getPetInFightPos(pet)
    local inFightFlag = inFightPos ~= NOT_INFIGHT_POS
    self:setLabelText("NumLabel", inFightPos, panel)
    self:setCtrlVisible("NumLabel", inFightFlag, panel)
    self:setCtrlVisible("NumImage", inFightFlag, panel)

    -- 上阵标记
    self:setCtrlVisible("StatusImage", inFightFlag, panel)

    -- 点击头像，打开宠物名片
    local shapePanel = self:getControl("ShapePanel", Const.UIPanel, panel)
    local function onShapePanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local dlg =  DlgMgr:openDlg("PetCardDlg")
            dlg:setPetInfo(pet, true)
        end
    end

    shapePanel:addTouchEventListener(onShapePanel)

    -- 点击操作按钮，打开技能操作面板
    local setButton = self:getControl("SetButton", Const.UIButton, panel)
    local function onSetButton(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self:isAttackPet(pet) then
                gf:ShowSmallTips(CHS[7100248])
                return
            end

            self:setSkillInfo(pet)
            self:setCtrlVisible("PetSkillPanel", true)
        end
    end

    setButton:addTouchEventListener(onSetButton)

    -- 选中宠物
    local function selectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onSelectPet(sender, eventType)
        end
    end

    panel:addTouchEventListener(selectPet)

    return panel
end

-- 获取宠物上阵编号，未上阵返回0
function LingChongOrderDlg:getPetInFightPos(pet)
    if not pet then return NOT_INFIGHT_POS end

    for i = 1, PET_INFIGHT_POS_MAX do
        local fightPet = self.inFightPets[i]
        if fightPet and fightPet:getId() == pet:getId() then
            return i
        end
    end

    return NOT_INFIGHT_POS
end

-- 获取已上阵宠物数量
function LingChongOrderDlg:getPetInFightNum()
    local count = 0
    for i = 1, PET_INFIGHT_POS_MAX do
        local fightPet = self.inFightPets[i]
        if fightPet then
            count = count + 1
        end
    end

    return count
end

-- 获取宠物可上阵编号
function LingChongOrderDlg:getPetToFightPos()
    for i = 1, PET_INFIGHT_POS_MAX do
        local fightPet = self.inFightPets[i]
        if not fightPet then
            return i
        end
    end

    return NOT_INFIGHT_POS
end

-- 选中宠物
function LingChongOrderDlg:onSelectPet(sender, eventType)
    -- 选中
    self.selectImg:removeFromParent()
    sender:addChild(self.selectImg)

    local pet = sender.pet
    if pet then
        local inFightPos = self:getPetInFightPos(pet)
        if inFightPos == NOT_INFIGHT_POS then
            -- 尝试上阵宠物

            if pet:getLevel() - Me:getLevel() > 15 then
                gf:ShowSmallTips(CHS[7100245])
                return
            end

            local reqLevel = pet:queryInt("req_level")
            if reqLevel > Me:getLevel() then
                gf:ShowSmallTips(string.format(CHS[7100246], reqLevel))
                return
            end

            -- 最多上阵5只宠物
            if self:getPetInFightNum() >= 5 then
                gf:ShowSmallTips(CHS[7100247])
                return
            end

            -- 宠物上阵
            local pos = self:getPetToFightPos()
            self.inFightPets[pos] = sender.pet
            self:saveFightPetToServer()
        end
    end
end

-- 宠物上阵
function LingChongOrderDlg:setPetFightPanel(cell, pet, pos, isAdjust)
    if pos == NOT_INFIGHT_POS then return end

    local panel = self:getControl("PetPanel_" .. pos, Const.UIPanel, "OrderPanel")
    if not pet then
        -- 清空pos位置的宠物数据
        self.inFightPets[pos] = nil
        local shapePanel = self:getControl("ShapePanel", Const.UIPanel, panel)
        if shapePanel:getChildByTag(self.TAG_PORTRAIT) then
            shapePanel:removeChildByTag(self.TAG_PORTRAIT)
        end

        self:setCtrlVisible("OperateImage", false, panel)
        self:setCtrlVisible("ChosenImage", false, panel)
        self:setCtrlVisible("NamePanel", false, panel)
        self:setCtrlVisible("BKImage_1", true, panel)
        self:setCtrlVisible("NumImage", true, panel)
        self:setCtrlVisible("BKImage_2", false, panel)

        if cell then
            cell.fightPanel = nil
        end

        panel.listItem = nil
        panel.pet = nil
    else
        self.inFightPets[pos] = pet
        panel.pet = pet
        self:setCtrlVisible("OperateImage", true, panel)
        self:setCtrlVisible("NamePanel", true, panel)
        self:setCtrlVisible("BKImage_1", false, panel)
        self:setCtrlVisible("NumImage", false, panel)
        self:setCtrlVisible("BKImage_2", true, panel)

        -- 宠物形象
        local icon = pet:getDlgIcon()
        self:setPortrait("ShapePanel", icon, nil, panel, false, nil, nil, cc.p(0, -36), nil, nil, 1)
        local name = pet:getShowName()
        self:setColorTextEx(name, "NamePanel", panel, COLOR3.YELLOW, 20, true)

        -- 设置箭头与光圈
        self:setArrowAndLightCircle(panel, isAdjust)

        if cell then
            cell.fightPanel = panel
            panel.listItem = cell
        end
    end

    -- 刷新上阵宠物数量
    self:refreshInFightPetCount()
end

-- 刷新上阵宠物数量
function LingChongOrderDlg:refreshInFightPetCount()
    local count = self:getPetInFightNum()
    self:setLabelText("Label_2", string.format(CHS[7100250], count), "OrderPanel")
end

-- 设置头像上方箭头与光圈
function LingChongOrderDlg:setArrowAndLightCircle(panel, show)
    local chosenImage = self:getControl("ChosenImage", nil, panel)
    local shapePanel = self:getControl("ShapePanel", nil, panel)
    local char = shapePanel:getChildByTag(self.TAG_PORTRAIT)
    local x, y = char:getHeadOffset()
    chosenImage:setPositionY(y + shapePanel:getContentSize().height / 2 - 36 + chosenImage:getContentSize().height / 2)
    if show then
        chosenImage:setVisible(true)
        self:setImage("OperateImage", ResMgr.ui.dcdh_choose_pet, panel)
    else
        chosenImage:setVisible(false)
        self:setImage("OperateImage", ResMgr.ui.fight_sel_img, panel)
    end
end

-- 清空上阵Panel状态
function LingChongOrderDlg:cleanInFightPanel()
    for i = 1, PET_INFIGHT_POS_MAX do
        local panel = self:getControl("PetPanel_" .. i, Const.UIPanel, "OrderPanel")
        local shapePanel = self:getControl("ShapePanel", Const.UIPanel, panel)
        if shapePanel:getChildByTag(self.TAG_PORTRAIT) then
            shapePanel:removeChildByTag(self.TAG_PORTRAIT)
        end

        self:setCtrlVisible("ChosenImage", false, panel)
        self:setCtrlVisible("OperateImage", false, panel)
        self:setCtrlVisible("NamePanel", false, panel)
        self:setCtrlVisible("BKImage_1", true, panel)
        self:setCtrlVisible("NumImage", true, panel)
        self:setCtrlVisible("BKImage_2", false, panel)
        panel.listItem = nil
        panel.pet = nil
    end
end

function LingChongOrderDlg:cleanup()
    self.inFightPets = {}
    self.adjustPetPanel = nil
end

-- 重置宠物技能面板
function LingChongOrderDlg:resetCtrl()
    local listView = self:getControl("MainListView")
    listView:removeAllItems()
    local backImage = self:getControl("BackImage", Const.UIImage, "PetSkillPanel")
    local size = backImage:getContentSize()
    size.height = 285
    backImage:setContentSize(size)

    local mainPanel = self:getControl("PetSkillPanel", Const.UIPanel)
    mainPanel:setContentSize(size)
    self:updateLayout("PetSkillPanel")
end

-- 设置宠物技能面板
function LingChongOrderDlg:setSkillInfo(pet)
    self:resetCtrl()
    local listView = self:getControl("MainListView")
    listView.pet = pet

    -- 研发技能  (只处理    五色光环)
    local studyRoot = self.skillPanel1:clone()
    local panel = self:getControl("SkillPanel1", nil, studyRoot)
    self:setSkillPanel(pet, panel, CHS[3001595])
    listView:pushBackCustomItem(studyRoot)

    -- 天生技能
    local innateRoot = self.skillPanel2:clone()
    local innateSkills = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}
    local innerSkillIndex = 0

    for j = 1, #INNATE_SKILLS do
        local skillName = ""
        for k = 1, #innateSkills do
            if innateSkills[k] == INNATE_SKILLS[j] then
                skillName = innateSkills[k]
            end
        end

        if skillName ~= "" and SkillMgr:getPetSkillType(skillName) ~= SkillMgr.PET_SKILL_TYPE.JINJIE then
            -- 策划要求移除进阶技能
            innerSkillIndex = innerSkillIndex + 1
            local panel = self:getControl("SkillPanel" .. innerSkillIndex, nil, innateRoot)
            self:setSkillPanel(pet, panel, skillName)
        end
    end

    for i = innerSkillIndex + 1, 3 do
        self:setCtrlVisible("SkillPanel" .. i, false, innateRoot)
    end

    -- 有些宠物没有天生技能：如兔子
    if innerSkillIndex > 0 then
        listView:pushBackCustomItem(innateRoot)
    end

    -- 顿悟技能 (设置拥有的技能，清空多余控件隐藏)
    local dunwuRoot = self.skillPanel3:clone()
    local dunWuSkills = SkillMgr:getPetDunWuSkills(pet:getId()) or {}
    local usefulSkillCount = 0
    for i = 1, 2 do
        local panel = self:getControl("SkillPanel" .. i, nil, dunwuRoot)
        if dunWuSkills[i] and SkillMgr:getPetSkillType(dunWuSkills[i]) ~= SkillMgr.PET_SKILL_TYPE.JINJIE then
            -- 策划要求移除进阶技能
            self:setSkillPanel(pet, panel, dunWuSkills[i])
            usefulSkillCount = usefulSkillCount + 1
        else
            self:setCtrlVisible("SkillPanel" .. i, false, dunwuRoot)
        end
    end

    if usefulSkillCount > 0 then
        listView:pushBackCustomItem(dunwuRoot)
    end

    -- 没有天生技能，没有顿悟技能，需要重新计算技能面板高度
    local minusHeight = 0
    if innerSkillIndex == 0 and usefulSkillCount == 0 then
        minusHeight = 2 * SKILL_LIST_PANEL_HEIGHT
    elseif innerSkillIndex == 0 or usefulSkillCount == 0 then
        minusHeight = SKILL_LIST_PANEL_HEIGHT
    end

    local backImage = self:getControl("BackImage", Const.UIImage, "PetSkillPanel")
    local imageSize = backImage:getContentSize()
    imageSize.height = imageSize.height - minusHeight
    backImage:setContentSize(imageSize)

    local mainPanel = self:getControl("PetSkillPanel", Const.UIPanel)
    local size = mainPanel:getContentSize()
    size.height = imageSize.height
    mainPanel:setContentSize(size)
    self:updateLayout("PetSkillPanel")
end

-- 设置宠物技能信息
function LingChongOrderDlg:setSkillPanel(pet, panel, skillName)
    local skill = SkillMgr:getskillAttribByName(skillName)
    local haveSkillInfo = SkillMgr:getSkill(pet:getId(), skill.skill_no)
    local isHas = haveSkillInfo ~= nil

    -- 技能图标
    local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
    if nil == skillIconPath then return end
    self:setImage("SkillImage", skillIconPath, panel)
    self:setItemImageSize("SkillImage", panel)

    -- 置灰
    local image = self:getControl("SkillImage", Const.UIImage, panel)
    image:setVisible(true)
    if isHas then
        gf:resetImageView(image)
    else
        gf:grayImageView(image)
    end

    -- 技能名称
    local skillTextPath = ResMgr.SkillText[skillName]
    local ladderNode = self:getControl("DownImage", Const.UIImage, panel)
    ladderNode:loadTexture(skillTextPath, ccui.TextureResType.plistType)
    self:setCtrlVisible("DownImage", true, panel)

    -- 技能等级
    if isHas then
        self:setCtrlVisible("LevelPanel", true, panel)
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, haveSkillInfo.skill_level, false, LOCATE_POSITION.LEFT_TOP, 19, panel)
    else
        self:setCtrlVisible("LevelPanel", false, panel)
    end

    -- 如果是顿悟技能，要加上顿悟标记
    if SkillMgr:isPetDunWuSkill(pet:getId(), skillName) then
        SkillMgr:addDunWuSkillImage(image)
    end

    local inUse = LingChongHuanJingMgr:isSkillCanUse(pet:queryBasicInt('no'), skill.skill_no)

    panel.isHas = isHas;
    panel.skillNo = skill.skill_no
    panel.skillName = skillName
    panel.inUse = inUse
    self:setSkillPanelStatus(panel, inUse)

    self:blindLongPress(panel, self.onLongPressSkill, self.onClickSkill)
end

-- 长按宠物技能
function LingChongOrderDlg:onLongPressSkill(sender, eventType)
    if not sender.skillName then return end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
    dlg:setSKillByName(sender.skillName, rect, true)
end

-- 点击宠物技能
function LingChongOrderDlg:onClickSkill(sender, eventType)
    if not sender.skillName then return end

    if sender.isHas then
        self:setSkillPanelStatus(sender, not sender.inUse)
        local pet = sender:getParent():getParent():getParent().pet

        -- 保存技能禁用信息到服务器
        self:saveNotInUseSkillToServer(pet)
    else
        gf:ShowSmallTips(string.format(CHS[7100249], sender.skillName))
    end
end

-- 设置宠物技能，使用中，未使用的状态
function LingChongOrderDlg:setSkillPanelStatus(panel, inUse)
    self:setCtrlVisible("CloseImage", not inUse, panel)
    panel.inUse = inUse
end

-- 是否为进攻性宠物：力量或灵气，大于体力与敏捷，则为进攻型宠物
function LingChongOrderDlg:isAttackPet(pet)
    -- 力量
    local str = pet:queryInt("str")
    -- 体力
    local con = pet:queryInt("con")
    -- 灵力
    local wiz = pet:queryInt("wiz")
    -- 敏捷
    local dex = pet:queryInt("dex")

    if (str > con and str > dex) or (wiz > con and wiz > dex) then
        return true
    end

    return false
end

-- 保存阵容信息到服务器
function LingChongOrderDlg:saveFightPetToServer()
    local count = self:getPetInFightNum()
    local list = {}
    for i = 1, PET_INFIGHT_POS_MAX do
        local fightPet = self.inFightPets[i]
        if fightPet then
            local petInfo = {}
            petInfo.name = fightPet:getName()
            petInfo.no = fightPet:queryBasicInt('no')
            petInfo.pos = i
            table.insert(list, petInfo)
        end
    end

    gf:CmdToServer("CMD_LCHJ_CONFIRM_PETS_INFO", {count = count, list = list})
end

-- 保存宠物禁用技能信息到服务器
function LingChongOrderDlg:saveNotInUseSkillToServer(pet)
    local listView = self:getControl("MainListView")

    local list = {}

    -- 研发技能  (只处理    五色光环)
    local studyRoot = self:getControl("SkillListPanel1", nil, listView)
    local studyPanel = self:getControl("SkillPanel1", nil, studyRoot)
    if studyPanel.skillNo and not studyPanel.inUse then
        table.insert(list, studyPanel.skillNo)
    end

    -- 天生技能
    local innateRoot = self:getControl("SkillListPanel2", nil, listView)
    if innateRoot then
        for i = 1, 3 do
            local studyPanel = self:getControl("SkillPanel" .. i, nil, innateRoot)
            if studyPanel.skillNo and not studyPanel.inUse then
                table.insert(list, studyPanel.skillNo)
            end
        end
    end

    -- 顿悟技能
    local dunwuRoot = self:getControl("SkillListPanel3", nil, listView)
    if dunwuRoot then
        for i = 1, 2 do
            local studyPanel = self:getControl("SkillPanel" .. i, nil, dunwuRoot)
            if studyPanel.skillNo and not studyPanel.inUse then
                table.insert(list, studyPanel.skillNo)
            end
        end
    end

    gf:CmdToServer("CMD_LCHJ_SET_DISABLE_SKILLS", {no = pet:queryBasicInt('no'), count = #list, list = list})
end

function LingChongOrderDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

-- 进入战斗
function LingChongOrderDlg:onEnterButton(sender, eventType)
    if not PetMgr:getFightPet() then
        gf:ShowSmallTips(CHS[7100251])
        return
    end

    if self:getPetInFightNum() == 0 then
        gf:ShowSmallTips(CHS[7100252])
        return
    end

    gf:CmdToServer("CMD_LCHJ_CHALLENGE", {
        name = LingChongHuanJingMgr:getCurStage(),
        stage = LingChongHuanJingMgr:getCurStageIndex()}
    )
end

return LingChongOrderDlg
