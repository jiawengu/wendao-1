-- PetExploreSkillDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队技能界面

local PetExploreSkillDlg = Singleton("PetExploreSkillDlg", Dialog)

-- 探索技能配置
local EXPLORE_SKILL_CFG = PetExploreTeamMgr:getExploreSkillCfg()

function PetExploreSkillDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindFloatPanelListener("RulePanel")
    self:bindListener("BagButton", self.onBagButton)
    self:bindFloatPanelListener("BagPanel")
    self:bindListener("ChangeButton", self.onChangeButton)
    self:bindListener("UseButton", self.onUseButton)

    self:blindLongPress("ConAddButton", self.onLongpressAddOrReduce, self.onConAddButton)
    self:blindLongPress("ConReduceButton", self.onLongpressAddOrReduce, self.onConReduceButton)

    self.petListRoot = self:getControl("PetListPanel")
    self.selectPetEffect = self:retainCtrl("ChosenEffectImage", self.petListRoot)
    self.petItemPanel = self:retainCtrl("PetPanel", self.petListRoot)

    self.skillPanel = self:getControl("SkillPanel")
    self.skillListView = self:getControl("ListView", nil, self.skillPanel)
    self.selectSkillEffect = self:retainCtrl("ChoseImage", nil, self.skillPanel)
    self.skillItemPanel = self:retainCtrl("SkillItemPanel", nil, self.skillPanel)
    self.desPanel = self:getControl("SkillDesPanel")
    self.skillUpPanel = self:getControl("SkillUpPanel")
    self:setLabelText("DescLabel", "", self.desPanel)

    -- 清空技能面板
    self:onSelectSkill({})

    self:setData()

    self:hookMsg("MSG_PET_EXPLORE_ONE_PET_DATA")
end

-- 设置界面数据
function PetExploreSkillDlg:setData(data)
    if data then
        self.dlgData = data
    else
        self.dlgData = PetExploreTeamMgr:getAllPetData()
    end

    self:setPetList()
end

-- 设置宠物列表
function PetExploreSkillDlg:setPetList()
    local listView = self:getControl("PetListView", nil, self.petListRoot)
    listView:removeAllItems()

    if self.dlgData then
        for i = 1, self.dlgData.count do
            local item = self.petItemPanel:clone()
            self:setSinglePetInfo(item, self.dlgData.list[i])
            listView:pushBackCustomItem(item)
        end
    end

    self:setCtrlVisible("NoticePanel", false)
    self.skillPanel:setVisible(false)
    self.desPanel:setVisible(false)
    if not self.selectPetInfo then
        -- 显示莲花姑娘
        self:setCtrlVisible("NoticePanel", true)
    else
        -- 显示技能详情
        self.skillPanel:setVisible(true)
        self.desPanel:setVisible(true)
    end
end

-- 设置单个宠物信息
function PetExploreSkillDlg:setSinglePetInfo(item, info)
    local pet = info.pet

    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), item)

    -- 名字
    local nameLabel = self:getControl("NameLabel", nil, item)
    nameLabel:setString(pet:getShowName())

    -- 等级
    self:setLabelText("LevelLabel", string.format(CHS[7190601], pet:queryBasicInt("level")), item)

    -- 相性
    local polar = gf:getPolar(pet:queryBasicInt("polar"))
    self:setImagePlist("Image", ResMgr:getPolarImagePath(polar), item)

    -- 探索中
    if PetExploreTeamMgr:isPetInExplore(pet:getId()) then
        self:setCtrlVisible("DoingImage", true, item)
    else
        self:setCtrlVisible("DoingImage", false, item)
    end

    item.info = info

    local iconImage = self:getControl("GuardImage", nil, item)
    local backImage = self:getControl("BackImage", nil, item)
    if PetExploreTeamMgr:isPetCanExplore(pet) then
        gf:resetImageView(iconImage)
        gf:resetImageView(backImage)

        if not self.selectPetInfo then
            -- 默认选中第1个可以选中的宠物
            self:selectPet(item)
        elseif self.selectPetInfo and self.selectPetInfo.pet_id == info.pet_id then
            -- 刷新当前宠物，也选中宠物刷新信息
            self:selectPet(item, true)
        end
    else
        gf:grayImageView(iconImage)
        gf:grayImageView(backImage)
    end

    local function onSelectPet(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:selectPet(sender)
        end
    end

    item:addTouchEventListener(onSelectPet)

    -- 点击头像，打开宠物名片
    local shapePanel = self:getControl("ShapePanel", nil, item)
    local function onShapePanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local dlg =  DlgMgr:openDlg("PetCardDlg")
            dlg:setPetInfo(pet, true)
        end
    end

    shapePanel:addTouchEventListener(onShapePanel)
end

function PetExploreSkillDlg:selectPet(panel, refreshInfo)
    if not panel.info then return end

    -- 不可探索的宠物需要置灰，置灰宠物无法选中
    if not PetExploreTeamMgr:isPetCanExplore(panel.info.pet) then
        if panel.info.pet and PetMgr:isTimeLimitedPet(panel.info.pet) then
            gf:ShowSmallTips(CHS[7190509])
        else
            gf:ShowSmallTips(CHS[7190508])
        end

        return
    end

    -- 选中效果
    if self.selectPetEffect:getParent() then
        self.selectPetEffect:removeFromParent()
    end

    panel:addChild(self.selectPetEffect)

    -- 选中宠物
    self.selectPetInfo = panel.info

    if not refreshInfo then
        -- 非刷新信息的时候，默认选择第一个技能
        self.selectSkillIndex = 1
    end

    -- 设置右边技能信息
    self:refreshSkillInfo(panel.info)
end

function PetExploreSkillDlg:refreshSkillInfo(info)
    self.skillListView:removeAllItems()

    -- 默认选中为空
    self:onSelectSkill()

    self.skillListInfo = info
    if info.skill_count > 0 then

        for i = 1, info.skill_count do
            local item = self.skillItemPanel:clone()
            self:setSingleSkillInfo(item, info.skill_list[i])
            self.skillListView:pushBackCustomItem(item)

            self:setCtrlVisible("Image_1", i % 2 ~= 0, item)
            self:setCtrlVisible("Image_2", i % 2 == 0, item)
        end

        local needSelectItem = self.skillListView:getItems()[self.selectSkillIndex or 1]
        if needSelectItem then
            self:onSelectSkill(needSelectItem)
        end
    end

    -- 技能数量小于2时，增加一个空白信息
    if info.skill_count < 2 then
        local item = self.skillItemPanel:clone()
        self:setSingleSkillInfo(item, nil, true)
        self.skillListView:pushBackCustomItem(item)
    end
end

-- 设置单个技能信息
function PetExploreSkillDlg:setSingleSkillInfo(item, info, isEmpty, levelExpColor)
    if isEmpty then
        -- 提示
        self:setCtrlVisible("NoticeLabel", true, item)

        -- 增加技能
        local addPanel = self:getControl("AddPanel", nil, item)
        addPanel:setVisible(true)

        local function onAddSkillPanel(sender, eventType)
            self:onAddSkill(sender, eventType)
        end

        addPanel:addTouchEventListener(onAddSkillPanel)
        item:addTouchEventListener(onAddSkillPanel)
    else
        -- 图标
        self:setImage("GuardImage", EXPLORE_SKILL_CFG[info.skill_id].iconPath, item)

        -- 名称
        self:setLabelText("NameLabel", EXPLORE_SKILL_CFG[info.skill_id].name, item)

        -- 等级
        levelExpColor = levelExpColor or COLOR3.TEXT_DEFAULT
        self:setLabelText("LevelLabel", info.skill_level, item, levelExpColor)

        -- 升级经验
        self:setLabelText("ExpLabel", PetExploreTeamMgr:getUpSkillExp(info.skill_level, info.exp), item, levelExpColor)

        local function onSelectSkillPanel(sender, eventType)
            self:onSelectSkill(sender, eventType)
        end

        item.info = info
        item:addTouchEventListener(onSelectSkillPanel)
    end
end

-- 增加技能
function PetExploreSkillDlg:onAddSkill(sender, eventType)
    local dlg = DlgMgr:openDlg("PetExploreSkillLearnDlg")
    dlg:setData(self.selectPetInfo)
end

-- 更换技能
function PetExploreSkillDlg:onChangeButton(sender, eventType)
    local dlg = DlgMgr:openDlg("PetExploreSkillLearnDlg")
    dlg:setData(self.selectPetInfo, self.skillInfo)
end

-- 选择技能
function PetExploreSkillDlg:onSelectSkill(sender, eventType)
    if sender and sender.info then
        local info = sender.info

        if self.skillListInfo then
            if self.skillListInfo.skill_count == 2 then
                -- 当有2个技能时，选中其中一个，重置另外一个技能数据
                local items = self.skillListView:getItems()
                if info.skill_id == self.skillListInfo.skill_list[1].skill_id and items[2] then
                    self:setSingleSkillInfo(items[2], self.skillListInfo.skill_list[2])
                elseif info.skill_id == self.skillListInfo.skill_list[2].skill_id and items[1] then
                    self:setSingleSkillInfo(items[1], self.skillListInfo.skill_list[1])
                end
            end

            if info.skill_id == self.skillListInfo.skill_list[1].skill_id then
                self.selectSkillIndex = 1
            elseif self.skillListInfo.skill_list[2]
                and info.skill_id == self.skillListInfo.skill_list[2].skill_id then
                self.selectSkillIndex = 2
            end
        end

        self.skillUpPanel:setVisible(true)

        -- 选中效果
        if self.selectSkillEffect:getParent() then
            self.selectSkillEffect:removeFromParent()
        end

        sender:addChild(self.selectSkillEffect)

        self.skillInfo = info
        self.selectSkillItem = sender

        -- 技能描述
        self:setLabelText("DescLabel", EXPLORE_SKILL_CFG[info.skill_id].descrip, self.desPanel)

        -- 图标
        self:setImage("CostImage", EXPLORE_SKILL_CFG[info.skill_id].materailPath, self.skillUpPanel)

        -- 图标悬浮框
        self:getControl("CostImagePanel", nil, self.skillUpPanel).skill_index = self.skillInfo.skill_id
        self:bindListener("CostImagePanel", self.onMaterialPanel, self.skillUpPanel)

        -- 拥有材料数量
        self:refreshOwnNum()

        -- 使用数量
        self.useNum = 0
        self:refreshUseNum()

        -- 点击数字打开
        self:bindListener("AutoConPanel", self.onLongpressAddOrReduce, self.skillUpPanel)
    else
        self:setColorText("", "DescrPanel", self.desPanel)
        self.skillUpPanel:setVisible(false)
    end
end

-- 刷新拥有材料数量
function PetExploreSkillDlg:refreshOwnNum()
    if not self.skillInfo then return end
    local num = PetExploreTeamMgr:getMaterailNum(self.skillInfo.skill_id)
    self:setLabelText("ResidueLabel_2", string.format(":%d", num), self.skillUpPanel)
end

-- 刷新使用材料数量
function PetExploreSkillDlg:refreshUseNum()
    self:setLabelText("ConLabel", self.useNum, self.skillUpPanel)

    local addExp = 0
    if self.useNum <= 0 then
        self:setLabelText("GetExpLabel", "", self.skillUpPanel)
    else
        addExp = PetExploreTeamMgr:getAddExp(self.skillInfo.skill_id, self.useNum)
        self:setLabelText("GetExpLabel", string.format(CHS[7120168], addExp), self.skillUpPanel)
    end

    if self.useNum < 1 then
        self:setCtrlEnabled("ConReduceButton", false)
    else
        self:setCtrlEnabled("ConReduceButton", true)
    end

    if self.selectSkillItem then
        -- 模拟技能增加经验效果
        local oldLevel, oldExp = self.skillInfo.skill_level, self.skillInfo.exp
        local newLevel, newExp = PetExploreTeamMgr:getSimulateSkillLevelAndExp(oldLevel, oldExp, addExp)
        if addExp > 0 then
            local info = {skill_id = self.skillInfo.skill_id, skill_level = newLevel, exp = newExp}
            self:setSingleSkillInfo(self.selectSkillItem, info, nil, COLOR3.GREEN)
        else
            self:setSingleSkillInfo(self.selectSkillItem, self.skillInfo, nil, COLOR3.TEXT_DEFAULT)
        end
    end
end

-- 设置包裹材料信息
function PetExploreSkillDlg:setMaterialInfo()
    local root = self:getControl("BagPanel")
    for i = 1, 5 do
        local panel = self:getControl("CostImagePanel" .. i, nil, root)
        self:setImage("CostImage", EXPLORE_SKILL_CFG[i].materailPath, panel)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, PetExploreTeamMgr:getMaterailNum(i),
            nil, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)

        panel.skill_index = i
        self:bindListener("CostImagePanel" .. i, self.onMaterialPanel, root)
    end
end

-- 点击材料框
function PetExploreSkillDlg:onMaterialPanel(sender, eventType)
    local skill_index = sender.skill_index

    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = EXPLORE_SKILL_CFG[skill_index].materailPath,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = EXPLORE_SKILL_CFG[skill_index].materialName
        },

        desc = EXPLORE_SKILL_CFG[skill_index].materailDes
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function PetExploreSkillDlg:cleanup()
    self.dlgData = nil
    self.useNum = 0
    self.selectPetInfo = nil
    self.skillInfo = nil
    self.skillListInfo = nil
    self.tickAddTimes = nil
    self.tickReduceTimes = nil
    self.selectSkillItem = nil
end

-- 数字键盘，输入回调
function PetExploreSkillDlg:insertNumber(num, key)
    if not self.useNum then return end

    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if num < 1 then
        gf:ShowSmallTips(CHS[7190520])
        self.useNum = 1
        self:refreshUseNum()
        if dlg then dlg:setInputValue(self.useNum) end
        return
    end

    local getExp = PetExploreTeamMgr:getAddExp(self.skillInfo.skill_id, num)
    local maxNeedExp = PetExploreTeamMgr:getSkillMaxNeedExp(self.skillInfo.skill_level, self.skillInfo.exp)
    local fullExpCount = PetExploreTeamMgr:getFullExpForMaterialCount(self.skillInfo.skill_id, maxNeedExp)
    local ownNum = PetExploreTeamMgr:getMaterailNum(self.skillInfo.skill_id)

    if getExp > maxNeedExp then
        -- 经验上限
        gf:ShowSmallTips(CHS[7190528])
        self.useNum = math.min(fullExpCount, ownNum)
        self:refreshUseNum()
        if dlg then dlg:setInputValue(self.useNum) end
        return
    end

    if num > ownNum then
        -- 数量上限
        gf:ShowSmallTips(string.format(CHS[7190521], EXPLORE_SKILL_CFG[self.skillInfo.skill_id].materialName))
        self.useNum = ownNum
        self:refreshUseNum()
        if dlg then dlg:setInputValue(self.useNum) end
        return
    end

    self.useNum = num
    self:refreshUseNum()
end

-- 长按材料使用加减号打开小键盘
function PetExploreSkillDlg:onLongpressAddOrReduce(sender, eventType)
    local panel = self:getControl("GetExpLabel")
    if not panel then return end

    local rect = self:getBoundingBoxInWorldSpace(panel)
    local dlg = DlgMgr:openDlg("SmallNumInputDlg")
    dlg:setObj(self)
    dlg:updatePosition(rect)
end

function PetExploreSkillDlg:onConAddButton(sender, eventType)
    if not self.useNum then return end

    if self.useNum >= PetExploreTeamMgr:getMaterailNum(self.skillInfo.skill_id) then
        -- 数量上限
        gf:ShowSmallTips(string.format(CHS[7190521], EXPLORE_SKILL_CFG[self.skillInfo.skill_id].materialName))
        return
    end

    local getExp = PetExploreTeamMgr:getAddExp(self.skillInfo.skill_id, self.useNum + 1)
    local maxNeedExp = PetExploreTeamMgr:getSkillMaxNeedExp(self.skillInfo.skill_level, self.skillInfo.exp)
    if getExp > maxNeedExp then
        -- 经验上限
        gf:ShowSmallTips(CHS[7190528])
        return
    end

    self.tickReduceTimes = 0
    if not self.tickAddTimes then
        self.tickAddTimes = 1
    else
        self.tickAddTimes = self.tickAddTimes + 1
        if self.tickAddTimes >= 3 then
            gf:ShowSmallTips(CHS[7190522])
            self.tickAddTimes = 0
        end
    end

    self.useNum = self.useNum + 1
    self:refreshUseNum()
end

function PetExploreSkillDlg:onConReduceButton(sender, eventType)
    if not self.useNum then return end

    self.tickAddTimes = 0
    if not self.tickReduceTimes then
        self.tickReduceTimes = 1
    else
        self.tickReduceTimes = self.tickReduceTimes + 1
        if self.tickReduceTimes >= 3 then
            gf:ShowSmallTips(CHS[7190522])
            self.tickReduceTimes = 0
        end
    end

    self.useNum = self.useNum - 1
    self:refreshUseNum()
end

function PetExploreSkillDlg:onUseButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190529])
        return
    end

    if not self.useNum then return end

    if PetExploreTeamMgr:isPetInExplore(PetMgr:getPetById(self.selectPetInfo.pet_id)) then
        gf:ShowSmallTips(CHS[7190530])
        return
    end

    if self.useNum < 1 then
        gf:ShowSmallTips(CHS[7190531])
        return
    end

    if PetExploreTeamMgr:isSkillFullLevel(self.skillInfo.skill_level) then
        gf:ShowSmallTips(CHS[7190532])
        return
    end

    if self.useNum > PetExploreTeamMgr:getMaterailNum(self.skillInfo.skill_id) then
        gf:ShowSmallTips(CHS[7190533])
        return
    end

    PetExploreTeamMgr:requestUseItem(self.selectPetInfo.pet_id, self.skillInfo.skill_id, self.useNum)
end

function PetExploreSkillDlg:onBagButton(sender, eventType)
    local bagPanel = self:getControl("BagPanel")
    bagPanel:setVisible(not bagPanel:isVisible())

    if bagPanel:isVisible() then
        self:setMaterialInfo()
    end
end

function PetExploreSkillDlg:onRuleButton(sender, eventType)
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(not rulePanel:isVisible())
end

function PetExploreSkillDlg:MSG_PET_EXPLORE_ONE_PET_DATA(data)
    -- 更新panel上存储的宠物信息
    local items = self:getControl("PetListView", nil, self.petListRoot):getItems()
    for i = 1, #items do
        if items[i].info and items[i].info.pet_id == data.pet_id then
            self:setSinglePetInfo(items[i], PetExploreTeamMgr:getPetInfo(data.pet_id))
        end
    end
end

return PetExploreSkillDlg
