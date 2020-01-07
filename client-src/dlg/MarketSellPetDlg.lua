-- MarketSellPetDlg.lua
-- Created by zhengjh Aug/20/2015
-- 宠物摆摊
local MarketSellBasicDlg = require('dlg/MarketSellBasicDlg')
local MarketSellPetDlg = Singleton("MarketSellPetDlg", MarketSellBasicDlg)

function MarketSellPetDlg:init()
    self:initBaisc()

    self.attribPanel = self:getControl("AttributePanel", Const.UIPanel)

    self.yfPanelSize = self.yfPanelSize or self:getControl("YanfaSkillPanel"):getContentSize()
    self.tsPanelSize = self.tsPanelSize or self:getControl("TianshuSkillPanel"):getContentSize()
    self.skillPanelSize = self.skillPanelSize or self:getControl("TianshengSkillPanel"):getContentSize()
end

function MarketSellPetDlg:setPetInfo(pet, vType, goodId, isMe)
    self.goodId = goodId
    self:initPublicInfo(pet, vType, true)

    local iconPanel = self:getControl("IconPanel")
    local level = pet:queryBasicInt("level")
    if nil == level or 0 == level then
        self:removeNumImgForPanel(iconPanel, LOCATE_POSITION.LEFT_TOP)
    else
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 头像
    local petImage = self:getControl("IconImage", Const.UIImage)
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("icon"))
    petImage:loadTexture(path)
    self:setItemImageSize("IconImage")

    local iconPanel = self:getControl("IconPanel")
    local function showFloatPanel(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if self.VIEW_TYPE.PRE_SELL == vType then
                local dlg =  DlgMgr:openDlg("PetCardDlg")
                dlg:setPetInfo(pet, true)
            else
                local item  = MarketMgr:getSelectGoodInfo()
                local rect = self:getBoundingBoxInWorldSpace(iconPanel)
                self:requireMarketGoodCard(goodId.."|"..(item.endTime or ""), MARKET_CARD_TYPE.FLOAT_DLG, rect, true)
            end
        end
    end

    iconPanel:addTouchEventListener(showFloatPanel)


    -- 名字
    local petNameLabel = self:getControl("NameLabel", Const.UILabel)
    petNameLabel:setString(gf:getPetName(pet.basic))

    -- 设置武学
    local martial = pet:queryInt("martial")
    self:setLabelText("MartialLabel", martial)

    -- 设置阶位
    local mount_type = pet:queryInt("mount_type")
    if 0  ~= mount_type then
        -- 阶位
        self:setLabelText("LevelLabel",  string.format(CHS[6000532], PetMgr:getMountRankStr(pet)))
    else
        -- 阶位
        self:setLabelText("LevelLabel", CHS[3001385])
    end

    local maxLife = pet:queryInt("max_life")
    local mana = pet:queryInt("mana")
    local maxMana = pet:queryInt("max_mana")
    local phyPower = pet:queryInt("phy_power_without_intimacy")
    local magPower = pet:queryInt("mag_power_without_intimacy")
    local speed = pet:queryInt("speed")
    local def = pet:queryInt("def_without_intimacy")

    -- 设置气血
    self:setLabelText("LifeLabel", maxLife)

    -- 设置法力
    self:setLabelText("ManaLabel", maxMana)

    -- 设置速度
    self:setLabelText("SpeedLabel", speed)

    -- 设置物伤
    self:setLabelText("PhyPowerLabel", phyPower)

    -- 设置法伤
    self:setLabelText("MagPowerLabel", magPower)

    -- 设置防御
    self:setLabelText("DefenceLabel", def)

    -- 设置天生技能信息
    local skills
    if isMe then
        skills = SkillMgr:getPetRawSkillNoAndLadder(pet:queryBasicInt("id"))
    else
        skills = self:getSaturalSkills(pet)
    end
    local skillPanel = self:getControl("TianshengSkillPanel")

    for i = 1, 3  do
        if i <= #skills then
            self:setLabelText(string.format("Label%d", i), string.format("%s (%s)", skills[i].name, skills[i].level), skillPanel)
        else
            --self:setCtrlVisible(string.format("Label%d", i), false, skillPanel)
            self:setLabelText(string.format("Label%d", i), "", skillPanel)
        end
    end

    if #skills == 0 then
        self:setLabelText("Label1", CHS[3003099], skillPanel)
    end

    skillPanel:setContentSize(self.skillPanelSize)
    if #skills < 3 then
        -- 小于3个，要缩短高度
        skillPanel:setContentSize(self.skillPanelSize.width, self.skillPanelSize.height / 3 * 2)
    end
    skillPanel:requestDoLayout()

    -- 研发技能
    local yfSkills = {}
    if isMe then
        yfSkills = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_E, SKILL.CLASS_PET)
    else
        local tempSkills = pet:queryBasic("skills")
        if type(tempSkills) ~= "table" then tempSkills = {} end
        local idx = 0
        for no, v in pairs(tempSkills) do
            if v.class == SKILL.CLASS_PET and v.subclass == SKILL.SUBCLASS_E then
                idx = idx + 1
                yfSkills[idx] = {no = v.skill_no, level = v.skill_level, name = SkillMgr:getskillAttrib(v.skill_no).name}
            end
        end
    end
    local yfPanel = self:getControl("YanfaSkillPanel")
    for i = 1, 4 do
        if yfSkills[i] then
            self:setLabelText("Label" .. i, string.format("%s (%s)", yfSkills[i].name, tostring(yfSkills[i].level)), yfPanel)
        else
            self:setLabelText("Label" .. i, "", yfPanel)
        end
    end

    yfPanel:setContentSize(self.yfPanelSize)
    if #yfSkills < 3 then
        if #yfSkills == 0 then
            self:setLabelText("Label" .. 1, CHS[5000059], yfPanel)
        end

        yfPanel:setContentSize(self.yfPanelSize.width, self.yfPanelSize.height / 3 * 2)
    end
    yfPanel:requestDoLayout()

    -- 顿悟
    local dwSkills = SkillMgr:getPetDunWuSkillsByPet(pet)
    local dwPanel = self:getControl("DunwuSkillPanel")
    for i = 1, 2 do
        if dwSkills[i] then
            local name = dwSkills[i].name or dwSkills[i].skill_name
            local level = dwSkills[i].level or dwSkills[i].skill_level
            self:setLabelText("Label" .. i, string.format("%s (%s)", name, tostring(level)), dwPanel)
        else
            self:setLabelText("Label" .. i, "", dwPanel)
        end
    end
    if #dwSkills == 0 then
        self:setLabelText("Label" .. 1, CHS[5000059], dwPanel)
    end

    -- 天书
    local godBook = PetMgr:getGodBookByPet(pet)
    local tsPanel = self:getControl("TianshuSkillPanel")
    for i = 1, 3 do
        if godBook[i] then
            local color = COLOR3.TEXT_DEFAULT
            if godBook[i].skill_disabled == 1 or godBook[i].skill_nimbus == 0 then
                color = COLOR3.GRAY
            end
            self:setLabelText("Label" .. i, string.format("%s", godBook[i].skill_name), tsPanel, color)

        else
            self:setLabelText("Label" .. i, "", tsPanel, COLOR3.TEXT_DEFAULT)
        end
    end

    tsPanel:setContentSize(self.tsPanelSize)
    if #godBook < 3 then
        if #godBook == 0 then
            self:setLabelText("Label" .. 1, CHS[5000059], tsPanel)
        end

        tsPanel:setContentSize(self.tsPanelSize.width, self.tsPanelSize.height / 3 * 2)
    end
    tsPanel:requestDoLayout()

    local listCtrl = self:getControl("ListView")
    listCtrl:refreshView()
end

function MarketSellPetDlg:getSaturalSkills(pet)
    if not pet then
        return
    end

    local skills = pet:queryBasic("skills")
    local dSkill = self:getSkillNoAndLadder(skills, SKILL.SUBCLASS_D)
    local eSkill = self:getSkillNoAndLadder(skills, SKILL.SUBCLASS_E,  SKILL.CLASS_PUBLIC)

    for i = 1, #eSkill do
        table.insert(dSkill, eSkill[i])
    end

    local result = {}
    for i = 1, #dSkill do
        if PetMgr:mayPetHaveRawSkill(pet:queryBasic("raw_name"), dSkill[i].name) then
            -- 宠物顿悟的本身没有的天生技能，不显示在界面上
            table.insert(result, dSkill[i])
        end
    end

    return result
end

function MarketSellPetDlg:getSkillNoAndLadder(skills, subclass, skillClass)
    if type(subclass) ~= 'table' then
        subclass = {subclass}
    end

    local len = #subclass

    local result = {}
    for no, info in pairs(skills) do
        for i = 1, len do
            info.subclass = SkillMgr:getskillAttrib(info.skill_no).skill_subclass
            info.class = SkillMgr:getskillAttrib(info.skill_no).skill_class
            if info.subclass == subclass[i] and (not skillClass or skillClass == info.class) then
                table.insert(result, {no = info.skill_no, level = info.skill_level, name = SkillMgr:getSkillName(info.skill_no)})
            end
        end
    end

    return result
end

function MarketSellPetDlg:setCtrlValue(panelName, LabelName, value)
    local panel = self:getControl(panelName, Const.UIPanel)
    self:setLabelText(LabelName, value, panel)
end


return MarketSellPetDlg
