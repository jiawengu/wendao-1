-- PetExploreTeamDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队队伍界面

local PetExploreTeamDlg = Singleton("PetExploreTeamDlg", Dialog)
local CharAction = require ("animate/CharAction")

-- 探索技能配置
local EXPLORE_SKILL_CFG = PetExploreTeamMgr:getExploreSkillCfg()

-- 操作探索状态
local EXPLORE_STATUS_OPER = PetExploreTeamMgr:getExploreOperCfg()

-- 难度中文
local DEGREE_CHS = PetExploreTeamMgr:getExploreDegreeCfg()

local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))

-- 宠物行走起始坐标
local EFFECT_ACTION_POS = {
    cc.p(100, 50),
    cc.p(220, 120),
    cc.p(180, -40),
}

-- 宠物羽化阶段描述
local PET_YUHUA_DES = {
    [0] = CHS[7100335],
    [1] = CHS[7100336],
    [2] = CHS[7100337],
}

function PetExploreTeamDlg:init()
    self:bindListener("BeginButton", self.onBeginButton)
    self:bindListener("StopButton", self.onStopButton)

    self.leftPanel = self:getControl("LeftPanel")
    self.rightPanel = self:getControl("RightPanel")
    self.rightPet = {}

    self:setCtrlVisible("PolarImage", false, "PetPanel1")
    self:setCtrlVisible("PolarImage", false, "PetPanel2")
    self:setCtrlVisible("PolarImage", false, "PetPanel3")

    self.bigSuccessImage = self:getControl("PerfectConditionImage")
    self.bigSuccessImage:setVisible(false)
end

-- 左边信息
function PetExploreTeamDlg:refreshLeftPanel(data)
    self.leftData = data

    if data.is_stop == 1 then
        -- 终止探索的情况下，不刷新条件表现
        return
    end

    -- 普通条件
    local normalRoot = self:getControl("NormalConditionPanel", nil, self.leftPanel)
    for i = 1, data.succ_rule_count do
        local info = data.succ_rule_list[i]
        local des = PetExploreTeamMgr:getSuccessRuleDes(info.id)
        if des == CHS[7190571] then
            -- 羽化需要特殊处理
            self:setLabelText("ConditionLabel" .. i, string.format(CHS[7100332], PET_YUHUA_DES[info.para2]), normalRoot)
            if info.para1 < info.para2 then
                self:setLabelText("ConditionNumLabel" .. i, "0/1", normalRoot)
            else
                self:setLabelText("ConditionNumLabel" .. i, "1/1", normalRoot)
            end
        else
            self:setLabelText("ConditionLabel" .. i, des, normalRoot)
            self:setLabelText("ConditionNumLabel" .. i, string.format("%d/%d", info.para1, info.para2), normalRoot)
        end
    end

    -- 成功率
    self:setLabelText("RateNumLabel", string.format("%d%%", data.succ_rate), normalRoot)

    -- 大成功条件
    local bigRoot = self:getControl("PerfectConditionPanel", nil, self.leftPanel)
    for i = 1, data.big_succ_rule_count do
        local info = data.big_succ_rule_list[i]
        self:setLabelText("ConditionLabel" .. i, PetExploreTeamMgr:getBigSuccessRuleDes(info.id), bigRoot)
        self:setLabelText("ConditionNumLabel" .. i, string.format("%d/%d", info.para1, info.para2), bigRoot)
    end

    -- 大成功图片
    self.bigSuccessImage:setVisible(true)
    if data.big_succ_rate / data.max_big_succ_rate >= 0.5 then
        gf:resetImageView(self.bigSuccessImage)
    else
        gf:grayImageView(self.bigSuccessImage)
    end
end

-- 右边信息
function PetExploreTeamDlg:refreshRightPanel(data)
    self.rightData = data

    -- 左边的地图信息
    local mapInfo = PetExploreTeamMgr:getMapInfo(data.map_index)
    local levelPanel = self:getControl("LevelPanel", nil, self.leftPanel)
    self:setLabelText("LevelLabel", DEGREE_CHS[mapInfo.degree], levelPanel)
    self:setLabelText("MapNameLabel", mapInfo.map_name, self.leftPanel)

    if data.is_stop ~= 1 then
        -- 非终止的探索的情况下，刷新宠物数据
        for i = 1, 3 do
            local panel = self:getControl("PetPanel" .. i)
            self:setCtrlVisible("PolarImage", false, panel)

            panel.index = i
            self:setSinglePetInfo(panel, data.pet_list[i], i)
        end
    end

    -- 开始探索，停止探索
    self:setCtrlVisible("BeginButton", false)
    self:setCtrlVisible("StopButton", false)
    if PetExploreTeamMgr:isMapInNotExplore(self.rightData.map_index) then
        self:setCtrlVisible("BeginButton", true)
    else
        self:setCtrlVisible("StopButton", true)
    end
end

function PetExploreTeamDlg:setSinglePetInfo(item, info, index)
    if info then
        self.rightPet[index] = info

        self:setCtrlVisible("NoneImage", false, item)
        self:setCtrlVisible("AttribPanel", true, item)

        -- 头像
        local petCfg = PetMgr:getPetCfg(info.key_name)
        self:setImage("PetImage", ResMgr:getSmallPortrait(petCfg.icon), item)

        -- 名字
        self:setLabelText("PetLabel", info.name, item)

        -- 相性
        self:setCtrlVisible("PolarImage", true, item)
        self:setImagePlist("PolarImage", ResMgr:getPolarImagePath(petCfg.polar), item)

        -- 等级
        self:setLabelText("LevelLabel", info.level, item)

        -- 武学
        if info.martial > 10000 then
            local showMartial = math.floor(info.martial / 10000)
            self:setLabelText("WuXueLabel", string.format("%dW", showMartial), item)
        else
            self:setLabelText("WuXueLabel", info.martial, item)
        end

        -- 寿命
        self:setLabelText("LifeLabel", info.longevity, item)

        -- 亲密度
        if info.intimacy > 10000 then
            local showIntimacy = math.floor(info.intimacy / 10000)
            self:setLabelText("QinMiLabel", string.format("%dW", showIntimacy), item)
        else
            self:setLabelText("QinMiLabel", info.intimacy, item)
        end

        -- 探索技能
        self:setCtrlVisible("NoSkillTipsLabel", false, item)
        self:setCtrlVisible("SkillLabel1", false, item)
        self:setCtrlVisible("SkillLabel2", false, item)
        self:setCtrlVisible("SkillBKPanel1", false, item)
        self:setCtrlVisible("SkillBKPanel2", false, item)
        if info.skill_count == 1 then
            self:setCtrlVisible("SkillBKPanel1", true, item)
            self:setCtrlVisible("SkillLabel1", true, item)
            self:setImage("SkillImage1", EXPLORE_SKILL_CFG[info.skill_list[1].skill_id].iconPath, item)
            self:setLabelText("SkillLabel1", info.skill_list[1].skill_level, item)
        elseif info.skill_count == 2 then
            self:setCtrlVisible("SkillBKPanel1", true, item)
            self:setCtrlVisible("SkillLabel1", true, item)
            self:setImage("SkillImage1", EXPLORE_SKILL_CFG[info.skill_list[1].skill_id].iconPath, item)
            self:setLabelText("SkillLabel1", info.skill_list[1].skill_level, item)

            self:setCtrlVisible("SkillBKPanel2", true, item)
            self:setCtrlVisible("SkillLabel2", true, item)
            self:setImage("SkillImage2", EXPLORE_SKILL_CFG[info.skill_list[2].skill_id].iconPath, item)
            self:setLabelText("SkillLabel2", info.skill_list[2].skill_level, item)
        else
            self:setCtrlVisible("NoSkillTipsLabel", true, item)
        end
    else
        self:setCtrlVisible("NoneImage", true, item)
        self:setCtrlVisible("AttribPanel", false, item)
    end

    self:getControl("ImagePanel", nil, item).info = info
    self:bindListener("ImagePanel", self.onPetImagePanel, item)
end

function PetExploreTeamDlg:changePet(index, petId)
    local idList = {
        self.rightPet[1] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[1].pet_iid) or 0, 
        self.rightPet[2] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[2].pet_iid) or 0, 
        self.rightPet[3] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[3].pet_iid) or 0, 
    }

    idList[index] = petId
    PetExploreTeamMgr:requestPetInTeamData(self.rightData.cookie, self.rightData.map_index, idList[1], idList[2], idList[3])

    -- 刷新小队数据
    self:setSinglePetInfo(self:getControl("PetPanel" .. index), PetExploreTeamMgr:getPetTeamInfo(petId), index)
end

function PetExploreTeamDlg:cleanup()
    self.rightData = nil
    self.rightPet = nil
end

function PetExploreTeamDlg:doAnimate()
    gf:frozenScreen()

    local panel = self:getControl("AnimPanel")
    panel:setVisible(true)

    -- 开始探险特效
    local magic = panel:getChildByName(ResMgr.ArmatureMagic.pet_explore_start.name)
    if not magic then
        magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.pet_explore_start.name)
        local size = panel:getContentSize()
        magic:setPosition(size.width / 2, size.height + 130)
        panel:addChild(magic, 6)
    end

    local function func(sender, etype)
        if etype == ccs.MovementEventType.complete then
            magic:getAnimation():play("Top02")
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play("Top01")

    -- 宠物奔跑
    for k, v in pairs(self.rightPet) do
        local pet = PetMgr:getPetByIId(v.pet_iid)
        if pet then
            local char = CharAction.new()
            local petIcon = pet:getDlgIcon()
            if IconColorScheme[petIcon] then
                char:set(IconColorScheme[petIcon].org_icon, nil, Const.SA_WALK, 5, nil, nil, nil,
                    IconColorScheme[petIcon].part, IconColorScheme[petIcon].dye)
            else
                char:set(petIcon, nil, Const.SA_WALK, 5)
            end

            char:setPosition(EFFECT_ACTION_POS[k])
            panel:addChild(char, 7)

            local moveAction = cc.MoveTo:create(5, cc.p(EFFECT_ACTION_POS[k].x + 800, EFFECT_ACTION_POS[k].y))
            char:runAction(cc.Sequence:create(moveAction))
        end
    end

    performWithDelay(panel, function()
        local fadeOut = cc.FadeOut:create(1)
        local cb = cc.CallFunc:create(function()
            panel:setVisible(false)

            -- 关闭界面
            self:onCloseButton()

            gf:unfrozenScreen()
        end)
        panel:runAction(cc.Sequence:create(fadeOut, cb))
    end, 4)
end

function PetExploreTeamDlg:onPetImagePanel(sender, eventType)
    if not PetExploreTeamMgr:isMapInNotExplore(self.rightData.map_index) then
        return
    end

    local index = sender:getParent().index
    local expects = {}

    for k, v in pairs(self.rightPet) do
        local pet = PetMgr:getPetByIId(v.pet_iid)
        if pet then
            expects[pet:getId()] = true
        end
    end

    local petList = PetExploreTeamMgr:getPetsToExplore(expects)

    if #petList > 0 then
        local dlg = DlgMgr:openDlg("PetExploreChoseDlg")
        dlg:setData(petList, index)
    else
        gf:ShowSmallTips(CHS[7120173])
    end
end

function PetExploreTeamDlg:onBeginButton(sender, eventType)
    if not self.rightPet[1] or not self.rightPet[2] or not self.rightPet[3] then
        gf:ShowSmallTips(CHS[7190583])
        return
    end

    if not PetMgr:getPetByIId(self.rightPet[1].pet_iid)
        or not PetMgr:getPetByIId(self.rightPet[2].pet_iid)
        or not PetMgr:getPetByIId(self.rightPet[3].pet_iid) then
        -- 上阵宠物满足3只，但有宠物在PetMgr中找不到，则提示，并清空界面
        self.rightPet = {}

        self.rightData.is_stop = 0
        self:refreshRightPanel(self.rightData)

        self.leftData.is_stop = 0
        self:refreshLeftPanel(self.leftData)

        gf:ShowSmallTips(CHS[7120170])
        return
    end

    gf:confirm(CHS[7190584], function()
        local id1 = self.rightPet[1] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[1].pet_iid) or 0
        local id2 = self.rightPet[2] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[2].pet_iid) or 0
        local id3 = self.rightPet[3] and PetExploreTeamMgr:getPetIdByIId(self.rightPet[3].pet_iid) or 0
        PetExploreTeamMgr:requestStartExplore(self.rightData.cookie, self.rightData.map_index, id1, id2, id3)
    end)
end

function PetExploreTeamDlg:onStopButton(sender, eventType)
    PetExploreTeamMgr:requestExploreOper(self.rightData.cookie, EXPLORE_STATUS_OPER.STOP, self.rightData.map_index)
end

return PetExploreTeamDlg
