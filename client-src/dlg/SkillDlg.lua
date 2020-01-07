-- SkillDlg.lua
-- Created by chenyq Dec/23/2014
-- 技能界面

local PageTag = require ("ctrl/RadioPageTag")
local SkillDlg = Singleton("SkillDlg", Dialog)

-- 标签页标题、标签页名称
local TOTAL_PAGES = 4
local PAGE_TITLES = {CHS[3003638], CHS[3003639], CHS[3000019], CHS[3000020],CHS[5400005]}
local PAGE_NAMES = {'APAttackSkillListView', 'ADAttackSkillListView', 'CTypeSkillListView', 'DTypeSkillListView'}
local CHECK_TABLE = {["Phy"] = 'ADAttackCheckBox',
                     ["Mag"] = 'APAttackCheckBox',
                     ["DType"] = 'DTypeSkillCheckBox',
                     ["CType"] = 'CTypeSkillCheckBox',
                     ["Passive"] = 'PassiveSkillCheckBox',
                     ["Couple"] = 'CoupleSkillCheckBox', }

local LEVELDOWN_LIMITS = {           -- 降低某一技能等级，若已学下一阶技能，该技能最低可降等级。
    [SKILL.SUBCLASS_B] = {[SKILL.LADDER_1] = 30,
                          [SKILL.LADDER_2] = 50,
                          [SKILL.LADDER_3] = 80,
                          [SKILL.LADDER_4] = 100,
    },
    [SKILL.SUBCLASS_C] = {[SKILL.LADDER_1] = 40,
                          [SKILL.LADDER_2] = 60,
                          [SKILL.LADDER_3] = 80,
                          [SKILL.LADDER_4] = 100,
    },
    [SKILL.SUBCLASS_D] = {[SKILL.LADDER_1] = 30,
                          [SKILL.LADDER_2] = 50,
                          [SKILL.LADDER_3] = 80,
                          [SKILL.LADDER_4] = 100,
    },
}

local LEVELDOWN_COSTMONEY = 500000 -- 降级所需花费的金钱

-- 每个标签页中上次选中的技能索引
local pageLastSelectedSkill = {}

-- 上次查看的标签页
local lastPageIdx = 0

local CHECK_BOX_CTRL_NAME = {'PageTagCheckBox1', 'PageTagCheckBox2', 'PageTagCheckBox3', 'PageTagCheckBox4'}


-- 经验技能显示的check
local JINGYAN_DISPLAY = {
    ["ADAttackCheckBox"] = 1,
    ["APAttackCheckBox"] = 1,
    ["DTypeSkillCheckBox"] = 1,
    ["CTypeSkillCheckBox"] = 1,
}

function SkillDlg:init()
    self:bindListener("Learn1Button", self.onLearn1Button)
    self:bindListener("Learn5Button", self.onLearn5Button)
    self:bindListener("Study1Button", self.onStudy1Button)
    self:bindListener("Study10Button", self.onStudy10Button)
    self:bindListener("LevelDownButton", self.onLevelDownButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self.listView = self:getControl("SkillListView", Const.UIListView)
    self.cloneItem = self:getControl("SkillPanel1", Const.UIPanel)
    self.cloneItem:retain()
    self.cloneItem:removeFromParent()

    -- 绑定checkBox事件
    for k, v in pairs(CHECK_TABLE) do
        self:bindCheckBox(v)
    end

    self.curSkillNo = nil

    if Me:queryInt("str") > Me:queryInt("wiz") then
        self:setSkillInfo(CHECK_TABLE["Phy"])
    else
        self:setSkillInfo(CHECK_TABLE["Mag"])
    end

    if Me:queryBasicInt("level") >= 100 and TaskMgr.baijiTaskStatus == nil then
        TaskMgr:requestBaijiTask()
    end


    -- 获取结拜相关信息
    JiebaiMgr:queryJiebaiInfo()

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_SKILLS")
    self:hookMsg("MSG_TASK_STATUS_INFO")
    self:hookMsg("MSG_REQUEST_BROTHER_INFO")
    self:hookMsg("MSG_LEARN_UPPER_STD_SKILL_COST")
end

function SkillDlg:clearSelected()
    for k, v in pairs(CHECK_TABLE) do
        self:getControl(v, Const.UICheckBox):setSelectedState(false)
    end

    self.listView:removeAllItems()
    self:setCtrlVisible("DescribePanel", false)
    self:setCtrlVisible("CouplePanel", false)
end

function SkillDlg:cleanup()
    self:releaseCloneCtrl("cloneItem")
    self.jySkill = nil
end

function SkillDlg:bindCheckBox(name)
    self:bindListener(name, function(dlg, sender, eventType)
        self.curSkillNo = nil
        self:setSkillInfo(name)
    end)
end

function SkillDlg:setSkillInfo(name)
    self:clearSelected()
    self:setCheck(name, true)

    self.curCheckBox = name
    if name == "ADAttackCheckBox" then
        self:setPhySkilInfo()
    elseif name == "APAttackCheckBox" then
        self:setMagSkillInfo()
    elseif name == "DTypeSkillCheckBox" then
        self:setDTypeSkillInfo()
    elseif name == "CTypeSkillCheckBox" then
        self:setCTypeSkillInfo()
    elseif name == "PassiveSkillCheckBox" then
        self:setPassiveSkillInfo()
    elseif name == "CoupleSkillCheckBox" then
        self:setCoupleSKillInfo()
    end


end

function SkillDlg:setPhySkilInfo()
    local polar = Me:queryBasicInt('polar')
    local phySkill = {}
    local magSkill = {}


    --[[
    local skill = SkillMgr:getSkill(Me:getId(), -1)
    skill.no = skill.skill_no
    table.insert(phySkill, skill)
    --]]

    local skills = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end

    skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_B)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end

    for k, v in pairs(phySkill) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end
        self:setPanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onPanelTouched(panel, v)
        end
    end

end

function SkillDlg:setMagSkillInfo()
    local polar = Me:queryBasicInt('polar')
    local phySkill = {}
    local magSkill = {}
    local skills = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end

    skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_B)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end

    for k, v in pairs(magSkill) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end
        self:setPanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onPanelTouched(panel, v)
        end
    end
end

function SkillDlg:setDTypeSkillInfo()
    local polar = Me:queryBasicInt('polar')

    -- 添加辅助技能列表
    local skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_D)

    for k, v in pairs(skills) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end
        self:setPanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onPanelTouched(panel, v)
        end
    end
end

function SkillDlg:setCTypeSkillInfo()
    local polar = Me:queryBasicInt('polar')
    -- 添加辅助技能列表
    local skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_C)

    for k, v in pairs(skills) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end
        self:setPanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onPanelTouched(panel, v)
        end
    end
end

function SkillDlg:setPassiveSkillInfo()
    -- 添加被动技能列表
    local skills = SkillMgr:getSkillsByClass(SKILL.CLASS_PUBLIC, SKILL.SUBCLASS_F)

    for k, v in pairs(skills) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end

        self:setPanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onPanelTouched(panel, v)
        end
    end
end

function SkillDlg:setCoupleSKillInfo()
    -- 夫妻技能/结拜技能
    local skills = {}
    local coupleSkills = SkillMgr:getCoupleSkill()
    for i = 1, #coupleSkills do
        table.insert(skills, coupleSkills[i])
    end

    local jiebaiSkills = SkillMgr:getJiebaiSkill()
    for i = 1, #jiebaiSkills do
        table.insert(skills, jiebaiSkills[i])
    end

    for k, v in pairs(skills) do
        local panel = self.cloneItem:clone()
        if k % 2 == 0 then
            self:setCtrlVisible("BackImage2", true, panel)
            self:setCtrlVisible("BackImage1", false, panel)
        else
            self:setCtrlVisible("BackImage2", false, panel)
            self:setCtrlVisible("BackImage1", true, panel)
        end
        self:setCouplePanelData(v, panel)
        self.listView:pushBackCustomItem(panel)

        local firstItem = self.listView:getItem(0)
        if k == 1 and firstItem and not self.curSkillNo then
            self:onCouplePanelTouched(panel, v)
        end
    end
end

-- 刷新界面信息
function SkillDlg:refreshContent()
    local listView = self:getControl("SkillListView", Const.UIListView)
    listView:removeAllItems()

    -- 记录当前各 ListView 中选中的项
    self.curSelect = {}

    -- 添加攻击技能列表
    local polar = Me:queryBasicInt('polar')
    local phySkill = {}
    local magSkill = {}
    local skills = SkillMgr:getSkillsByClass(SKILL.CLASS_PHY, SKILL.SUBCLASS_J)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end
    skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_B)
    for i = 1, #skills do
        local skillType = ''
        local skillDesc = SkillMgr:getSkillDesc(skills[i].name)
        if skillDesc then
            skillType = skillDesc.type
        end
        if gf:findStrByByte(skillType, CHS[3003639]) then
            table.insert(magSkill, skills[i])
        else
            table.insert(phySkill, skills[i])
        end
    end

    local selectedItem = self:addSkillItem("APAttackSkillListView", phySkill, true)
    self.curSelect.APAttackSkillListView = selectedItem
    self.listView:pushBackCustomItem(self.attackPhyPanel)

    selectedItem = self:addSkillItem("ADAttackSkillListView", magSkill, true)
    self.curSelect.ADAttackSkillListView = selectedItem
    self.listView:pushBackCustomItem(self.attackMagPanel)

    -- 添加障碍技能列表
    skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_C)
    selectedItem = self:addSkillItem("CTypeSkillListView", skills, true)
    self.curSelect.CTypeSkillListView = selectedItem
    self.listView:pushBackCustomItem(self.cTypeSkillPanel)

    -- 添加辅助技能列表
    skills = SkillMgr:getSkillsByPolarAndSubclass(polar, SKILL.SUBCLASS_D)
    selectedItem = self:addSkillItem("DTypeSkillListView", skills, true)
    self.curSelect.DTypeSkillListView = selectedItem
    self.listView:pushBackCustomItem(self.dTypeSkillPanel)

    self:setSelectedSkillInfo(self.curSelect[PAGE_NAMES[lastPageIdx + 1]])

    -- 显示上一次显示的标签页，listView 索引从 0 开始，故要减 1
    -- 在初始化中执行切换标签页，表现异常，古需要放在下一帧做
    local scrollAction = cc.CallFunc:create(function()
        --listView:scrollToPage(lastPageIdx - 1)
        if lastPageIdx  == 0 then
            gf:grayImageView(self.leftButton)
            self.leftButton:setTouchEnabled(false)
            gf:resetImageView(self.rightButton)
            self.rightButton:setTouchEnabled(true)
        elseif lastPageIdx == TOTAL_PAGES - 1 then
            gf:grayImageView(self.rightButton)
            self.rightButton:setTouchEnabled(false)
            gf:resetImageView(self.leftButton)
            self.leftButton:setTouchEnabled(true)
        else
            gf:resetImageView(self.leftButton)
            self.leftButton:setTouchEnabled(true)
            gf:resetImageView(self.rightButton)
            self.rightButton:setTouchEnabled(true)
        end

        -- 设置技能类型标签
        self:setLabelText("SkillTypeLabel", PAGE_TITLES[lastPageIdx + 1])

        local percent = lastPageIdx * 33.3
        self.listView:scrollToPercentHorizontal(percent, 0.2, false)
        self.curSelectIdx = lastPageIdx
        self.pageTag:setPage(self.curSelectIdx + 1)
    end)
    local action = cc.Sequence:create(cc.DelayTime:create(0.01), scrollAction)
    listView:runAction(action)
end

function SkillDlg:setCouplePanelData(skillData, item)
    self:setImage("SkillImage", ResMgr:getSkillIconPath(skillData['icon']), item)
    self:setItemImageSize("SkillImage", item)

    local ladderDesc = CHS[5400006]
    local mana_cost = 0
    local level = "0/1"

    if SkillMgr:isHaveCoupleSkill() and SkillMgr:isCoupleSkill(skillData.no) then
        -- 夫妻技能
        self:setLabelText('SkillNameLabel', skillData.name, item)
        self:setLabelText('SkillLVLabel', "1/1", item)
        self:setLabelText('SkillTypeLabel', ladderDesc, item)
        self:setLabelText("ManaCostLabel", tonumber(mana_cost), item)
        self:setLabelText("TargetNumLabel", 2, item)
    elseif SkillMgr:isHaveJiebaiSkill() and SkillMgr:isJiebaiSkill(skillData.no) then
        -- 结拜技能
        self:setLabelText('SkillNameLabel', skillData.name, item)
        self:setLabelText('SkillLVLabel', "1/1", item)
        self:setLabelText('SkillTypeLabel', ladderDesc, item)
        self:setLabelText("ManaCostLabel", tonumber(mana_cost), item)
        self:setLabelText("TargetNumLabel", SkillMgr:getJiebaiSkillRange(), item)
    else
        gf:grayImageView(self:getControl("SkillImage", Const.UIImage, item))
        self:setLabelText('SkillNameLabel', skillData.name, item, COLOR3.GRAY)
        self:setLabelText('SkillLVLabel', level, item, COLOR3.GRAY)
        self:setLabelText('SkillTypeLabel', ladderDesc, item, COLOR3.GRAY)
        self:setLabelText("ManaCostLabel", tonumber(mana_cost), item, COLOR3.GRAY)
        self:setLabelText("TargetNumLabel", 0, item, COLOR3.GRAY)
    end

    -- 绑定pannel事件
    item:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onCouplePanelTouched(sender, skillData)
        end
    end)


end

function SkillDlg:onCouplePanelTouched(sender, skillData)
    local items = self.listView:getItems()
    for k, v in pairs(items) do
        self:setCtrlVisible("SChosenEffectImage", false, v)
    end

    self:setCtrlVisible("CouplePanel", true)
    self:setCtrlVisible("SChosenEffectImage", true, sender)
    local skillDesc = SkillMgr:getSkillDesc(skillData.name)
    if not skillDesc then return end
    self:setLabelText("CoupleDescribeLabel", CHS[3003643] .. skillDesc.desc)
    self:setLabelText("CoupleConditionLabel", CHS[3003642] .. skillDesc.req_tips[1])

end

function SkillDlg:getSkillLowCost()
    local skillLowCost = {}
    if Me:queryExtraInt("B_skill_low_cost") > 0 then skillLowCost[SKILL.SUBCLASS_B] = true end
    if Me:queryExtraInt("C_skill_low_cost") > 0 then skillLowCost[SKILL.SUBCLASS_C] = true end
    if Me:queryExtraInt("D_skill_low_cost") > 0 then skillLowCost[SKILL.SUBCLASS_D] = true end
    return skillLowCost
end

function SkillDlg:setPanelData(skillData, item)
    local skillNo = skillData.no
    -- 获取技能等级
    local level = 0
    local mana_cost = 0
    local range = 0
    local ladderDesc = CHS[3003640]
    local mySkill = SkillMgr:getSkill(Me:getId(), skillNo)
    local levelColor = COLOR3.TEXT_DEFAULT
    local levelString = nil

    -- 仙魔技能目标1
    if SkillMgr:isXianMoSkill(skillNo) then
        range = 1
    end

    if mySkill then
        level = mySkill.skill_level
        range = mySkill.range
        mana_cost = mySkill.skill_mana_cost

        if mySkill.level_improved > 0 then
            levelString = "#G" .. tostring(level) .. "#n" .."/"..math.floor(1.6 * Me:queryBasicInt("level"))
        end

        -- 仙魔技能等级显示 x/1
        if mySkill.level_improved > 0 and SkillMgr:isXianMoSkill(skillNo) then
            levelString = "#G" .. tostring(level) .. "#n" .."/1"
        end
    end

    local skillAttrib = SkillMgr:getskillAttrib(skillNo)
    ladderDesc = SkillMgr:getLadderDescr(skillAttrib.skill_ladder)

    if skillAttrib.skill_subclass == SKILL.SUBCLASS_J then
        ladderDesc = CHS[3003641]
    end

    if skillAttrib.skill_subclass == SKILL.SUBCLASS_F then
        ladderDesc = CHS[5400006]
    end

    self:setImage("SkillImage", SkillMgr:getSkillIconPath(skillNo), item)
    self:setItemImageSize("SkillImage", item)

    self:setLabelText("SkillLVLabel", "", item)

    if SkillMgr:haveLevelLimit(skillNo) or
        SkillMgr:haveSkillLimit(skillNo)  then

        -- 等级未达到要求或者未技能未达到要求或者为 5 阶节能，需要置灰图片
        gf:grayImageView(self:getControl("SkillImage", Const.UIImage, item))
        self:setLabelText('SkillNameLabel', skillData.name, item, COLOR3.GRAY)
        --self:setLabelText('SkillLVLabel', tostring(level).."/"..math.floor(1.6 * Me:queryBasicInt("level")), item, COLOR3.GRAY)
        local levelText = CGAColorTextList:create()
        levelText:setFontSize(19)
        levelText:setContentSize(130, 30)
        self:getControl("SkillLVLabel", Const.UILabel, item):addChild(tolua.cast(levelText, "cc.LayerColor"))
        levelString = tostring(level) .."/"..math.floor(1.6 * Me:queryBasicInt("level"))

        -- 仙魔技能等级显示 x/1
        if SkillMgr:isXianMoSkill(skillNo) then
            levelString = tostring(level) .."/1"
        end

        levelText:setString(levelString)
        levelText:setDefaultColor(COLOR3.GRAY.r, COLOR3.GRAY.g, COLOR3.GRAY.b)
        levelText:updateNow()
        local labelW, labelH = levelText:getRealSize()
        local ctrlSize = self:getControl("SkillLVLabel", Const.UILabel, item):getContentSize()
        levelText:setPosition((ctrlSize.width - labelW) * 0.5, (ctrlSize.height - labelH) * 0.5 + labelH)
        self:setLabelText('SkillTypeLabel', ladderDesc, item, COLOR3.GRAY)
        self:setLabelText("ManaCostLabel", tonumber(mana_cost), item, COLOR3.GRAY)
        self:setLabelText("TargetNumLabel", range, item, COLOR3.GRAY)
    else
        self:setLabelText('SkillNameLabel', skillData.name, item)
        --self:setLabelText('SkillLVLabel', tostring(level).."/"..math.floor(1.6 * Me:queryBasicInt("level")), item, levelColor)
        local levelText = CGAColorTextList:create()
        levelText:setFontSize(19)
        levelText:setContentSize(130, 30)
        self:getControl("SkillLVLabel", Const.UILabel, item):addChild(tolua.cast(levelText, "cc.LayerColor"))
        if not levelString then
            levelString = tostring(level) .."/"..math.floor(1.6 * Me:queryBasicInt("level"))

            -- 仙魔技能等级显示 x/1
            if SkillMgr:isXianMoSkill(skillNo) then
                levelString = tostring(level) .."/1"
            end
        end

        levelText:setString(levelString)
        levelText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
        levelText:updateNow()
        local labelW, labelH = levelText:getRealSize()
        local ctrlSize = self:getControl("SkillLVLabel", Const.UILabel, item):getContentSize()
        levelText:setPosition((ctrlSize.width - labelW) * 0.5, (ctrlSize.height - labelH) * 0.5 + labelH)
        self:setLabelText('SkillTypeLabel', ladderDesc, item)
        -- 如果技能消耗有降低，就显示为绿色，否则显示为默认颜色
        local skillLowCost = self:getSkillLowCost()
        if mySkill and mySkill.subclass and skillLowCost[mySkill.subclass] and mana_cost > 0 then
            self:setLabelText("ManaCostLabel", tonumber(mana_cost), item, COLOR3.GREEN)
        else
            self:setLabelText("ManaCostLabel", tonumber(mana_cost), item, COLOR3.TEXT_DEFAULT)
        end
        self:setLabelText("TargetNumLabel", range, item)
    end

    -- 如果是被动技能-仙魔技能
    if SkillMgr:isXianMoSkill(skillNo) then
        if mySkill then
            gf:resetImageView(self:getControl("SkillImage", Const.UIImage, item))
        else
            gf:grayImageView(self:getControl("SkillImage", Const.UIImage, item))
        end
    end

    -- 绑定pannel事件
    item:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:onPanelTouched(sender, skillData, mySkill)
        end
    end)

    if skillNo == self.curSkillNo then
        self:onPanelTouched(item, skillData, mySkill)
    end
end


function SkillDlg:onPanelTouched(sender, skillData, mySkill)
    local skillNo = skillData.no
    self.curSkillNo = skillNo

    if not mySkill then
        mySkill = SkillMgr:getSkill(Me:getId(), skillNo)
    end

    local items = self.listView:getItems()
    for k, v in pairs(items) do
        self:setCtrlVisible("SChosenEffectImage", false, v)
    end

    self:setCtrlVisible("SChosenEffectImage", true, sender)
    self:setCtrlVisible("CouplePanel", false)
    local skillDesc = SkillMgr:getSkillDesc(skillData.name)

    if skillDesc then
        self:setCtrlVisible("DescribePanel", true)
        local req_tips = SkillMgr:getSkillReqDescBId(skillNo)
        if req_tips then
            self:setLabelText("ConditionLabel", CHS[3003642].. req_tips)
        else
            self:setLabelText("ConditionLabel", "")
        end

        self:setLabelText("DescribeLabel", CHS[3003643] .. skillDesc.desc)

        -- 拥有的潜能或金钱
        local skill = SkillMgr:getskillAttrib(skillNo)

        self:setLabelText("ConsumeLabel2", CHS[4200552])
        self:setLabelText("ConsumeLabel3", CHS[4200553])
        self:setCtrlVisible("ConsumeLabel2", true)

        if skill.skill_subclass == SKILL.SUBCLASS_F then  -- 被动技能
            local ownMoney = Me:queryInt("cash")
            local moneyDesc, fontColor= gf:getArtFontMoneyDesc(ownMoney, true)
            self:setNumImgForPanel("MoneyPanel1", fontColor, moneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)

            self:setCtrlVisible("CashImage1", false)    -- 潜能
            self:setCtrlVisible("CashImage2", false)
            self:setCtrlVisible("OwnConsumeLabel", false)
            self:setCtrlVisible("CostConsumeLabel", false)

            self:setCtrlVisible("MoneyImage1", true)   -- 金钱
            self:setCtrlVisible("MoneyImage2", true)
            self:setCtrlVisible("MoneyPanel1", true)
            self:setCtrlVisible("MoneyPanel2", true)
        else
            local ownPot = Me:queryInt("pot")
            local potDesc = gf:getMoneyDesc(ownPot, true)
            self:setLabelText("OwnConsumeLabel", potDesc)

            self:setCtrlVisible("CashImage1", true)
            self:setCtrlVisible("CashImage2", true)
            self:setCtrlVisible("OwnConsumeLabel", true)
            self:setCtrlVisible("CostConsumeLabel", true)

            self:setCtrlVisible("MoneyImage1", false)
            self:setCtrlVisible("MoneyImage2", false)
            self:setCtrlVisible("MoneyPanel1", false)
            self:setCtrlVisible("MoneyPanel2", false)
        end

        -- 需要消耗的潜能或金钱
        if mySkill then
            if skill.skill_subclass == SKILL.SUBCLASS_F then
                local costMoney = mySkill.cost_voucher_or_cash
                local costMoneyDesc, fontColor = gf:getArtFontMoneyDesc(costMoney, true)
                self:setNumImgForPanel("MoneyPanel2", fontColor, costMoneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
            else
                local costPot = mySkill.cost_pot
                local costPotDesc = gf:getMoneyDesc(costPot, true)
                self:setLabelText("CostConsumeLabel", costPotDesc)
            end
        else
            if SkillMgr:haveLevelLimit(skillNo) or
                SkillMgr:haveSkillLimit(skillNo) then
                if skill.skill_subclass == SKILL.SUBCLASS_F then
                    local costMoneyDesc, fontColor = gf:getArtFontMoneyDesc(200000, true)
                    self:setNumImgForPanel("MoneyPanel2", fontColor, costMoneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
                else
                    self:setLabelText("CostConsumeLabel", 1)
                end
            else
                if skill.skill_subclass == SKILL.SUBCLASS_F then
                    local costMoneyDesc, fontColor = gf:getArtFontMoneyDesc(200000, true)
                    self:setNumImgForPanel("MoneyPanel2", fontColor, costMoneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
                else
                    self:setLabelText("CostConsumeLabel", 1)
                end
            end
        end

        if SkillMgr:isXianMoSkill(skillNo) then
            self:setStudyButtonVisible(mySkill, false)
            self:setCtrlVisible("LevelDownButton", false)
        else
            self:setStudyButtonVisible(mySkill, true)
            self:setCtrlVisible("LevelDownButton", skill.skill_subclass ~= SKILL.SUBCLASS_F)
        end
    end

	self:updateLayout("ConsumePanel")
    self:updateLayout("DescribePanel")
end

-- 设置学习按钮，达到一定程度显示精研按钮
function SkillDlg:setStudyButtonVisible(mySkill, isVisible)
    self:setCtrlVisible("ConsumePanel", isVisible)
    -- self:setCtrlVisible("LevelDownButton", isVisible)
    self:setCtrlVisible("Learn1Button", isVisible)
    self:setCtrlVisible("Learn5Button", isVisible)


    if Me:getLevel() >= 90 and isVisible and mySkill
      and (mySkill.skill_level - mySkill.level_improved) >= SkillMgr:getLearnLevelMax() and JINGYAN_DISPLAY[self.curCheckBox] then
        self:setCtrlVisible("Study1Button", isVisible)
        self:setCtrlVisible("Study10Button", isVisible)

        self:setCtrlVisible("InfoButton", isVisible)
        self:setLabelText("ConditionLabel", CHS[4010134])

        self:setCtrlVisible("Learn1Button", false)
        self:setCtrlVisible("Learn5Button", false)

        local ownPot = Me:queryInt("pot")
        local potDesc = gf:getMoneyDesc(ownPot, true)
        self:setLabelText("CostConsumeLabel", potDesc)

        self:setCtrlVisible("CashImage1", false)
        self:setCtrlVisible("CashImage2", true)
        self:setCtrlVisible("OwnConsumeLabel", false)
        self:setCtrlVisible("CostConsumeLabel", true)

        self:setCtrlVisible("MoneyImage1", false)
        self:setCtrlVisible("MoneyImage2", false)
        self:setCtrlVisible("MoneyPanel1", false)
        self:setCtrlVisible("MoneyPanel2", false)

        self:setCtrlVisible("ConsumeLabel2", false)
        self:setLabelText("ConsumeLabel3", CHS[4200552])

    else
        self:setCtrlVisible("Study1Button", false)
        self:setCtrlVisible("Study10Button", false)
        self:setCtrlVisible("InfoButton", false)

    end
end

-- 发送升级技能的命令
function SkillDlg:sendLevelupCmd(upLevel)
    local skill = SkillMgr:getskillAttrib(self.curSkillNo)
    if SkillMgr:haveLevelLimit(self.curSkillNo) or SkillMgr:haveSkillLimit(self.curSkillNo) then
        gf:ShowSmallTips(CHS[3000022])
        return
    end

    local maxLevel = math.floor(Me:queryBasicInt("level") * 1.6)
    local mySkill = SkillMgr:getSkill(Me:getId(), self.curSkillNo)
    if mySkill and  mySkill.skill_level - mySkill.level_improved >= maxLevel then
        -- 已达到最高等级
        gf:ShowSmallTips(CHS[3000023])
        return
    end

    local costpot = 1
    local costMoney = 200000

    if mySkill then
        costpot = mySkill["cost_pot"]
        costMoney = mySkill["cost_voucher_or_cash"]
    end

    if skill.skill_subclass == SKILL.SUBCLASS_F then
        if not gf:checkHasEnoughMoney(costMoney) then
            return
        end

        if upLevel == 10 then
            local level = 0
            if mySkill then
                level = mySkill.skill_level
            end

            local ownMoney = Me:queryBasicInt("cash") + Me:queryBasicInt("voucher")
            local totalCostMoney = 0
            for i = 1, 11 do
                local cost = 200000 + (level - 1 + i) * 70000
                if totalCostMoney + cost > ownMoney or level + i - 1 == maxLevel or i == 11 then
                    local moneyDesc = gf:getMoneyDesc(totalCostMoney, false)
                    gf:confirm(string.format(CHS[5420064], moneyDesc, skill.name, i - 1), function ()
                        gf:CmdToServer("CMD_LEARN_SKILL", {
                            id = Me:getId(),
                            skill_no = self.curSkillNo,
                            up_level = upLevel
                        })
                    end)

                    return
                end

                totalCostMoney = totalCostMoney + cost
            end
        end
    else
        if costpot > tonumber(Me:query('pot')) then
            gf:ShowSmallTips(CHS[3003645])
            return
        end
    end

    gf:CmdToServer("CMD_LEARN_SKILL", {
        id = Me:getId(),
        skill_no = self.curSkillNo,
        up_level = upLevel
    })
end


function SkillDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("SkillRuleDlg")
end

function SkillDlg:onStudy1Button(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.curSkillNo then return end
    local mySkill = SkillMgr:getSkill(Me:getId(), self.curSkillNo)
    if not self:conditionJY(mySkill) then
        return
    end
    self.jySkill = {}
    self.jySkill.skill_no = self.curSkillNo
    self.jySkill.up_level = 1
    gf:CmdToServer("CMD_LEARN_UPPER_STD_SKILL_COST", {
        skill_no = self.curSkillNo,
        up_level = self.jySkill.up_level
    })
end

-- 精研技能判断
function SkillDlg:conditionJY(mySkill)

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    if Me:queryBasicInt("level") < 100 then
        gf:ShowSmallTips(CHS[4010135])
        return
    end

    if not TaskMgr:isCompleteBaijiTask() then
        gf:ShowSmallTips(CHS[4010136])
        return
    end

    if (mySkill.skill_level - mySkill.level_improved) < SkillMgr:getLearnLevelMax() then
        gf:ShowSmallTips(CHS[4010137])  -- "先把当前技能等级学习到上限才可进行精研。",
        return
    end

    if (mySkill.skill_level - mySkill.level_improved) >= SkillMgr:getStudyLevelMax() then
        gf:ShowSmallTips(CHS[4010138]) -- 该技能已经精研到等级上限了。
        return
    end

    return true
end

function SkillDlg:onStudy10Button(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.curSkillNo then return end
    local mySkill = SkillMgr:getSkill(Me:getId(), self.curSkillNo)
    if not self:conditionJY(mySkill) then
        return
    end

    local retTimes = math.min(SkillMgr:getStudyLevelMax() - (mySkill.skill_level - mySkill.level_improved), 10)
    self.jySkill = {}
    self.jySkill.skill_no = self.curSkillNo
    self.jySkill.up_level = retTimes
    gf:CmdToServer("CMD_LEARN_UPPER_STD_SKILL_COST", {
        skill_no = self.curSkillNo,
        up_level = self.jySkill.up_level
    })
end

function SkillDlg:onLearn1Button(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003646])
        return
    end

    self:sendLevelupCmd(1)
end

function SkillDlg:onLearn5Button(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003646])
        return
    end

    self:sendLevelupCmd(10)

    GuideMgr:needCallBack("Learn5Button")
end

function SkillDlg:onLevelDownButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end

    local mySkill = SkillMgr:getSkill(Me:getId(), self.curSkillNo)

    local nextSkill = nil
    if mySkill
        and mySkill.skill_level > 1
        and LEVELDOWN_LIMITS[mySkill.subclass]
        and LEVELDOWN_LIMITS[mySkill.subclass][mySkill.ladder] then

        local skillAttrib = SkillMgr:getSkillsByClass(mySkill.class, mySkill.subclass)
        for no, v in pairs(skillAttrib) do
            if mySkill.ladder < v.ladder then
                nextSkill = v
                break
            end
        end
    end

    -- 若在战斗中直接返回
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    elseif Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003646])
        return
    elseif not mySkill or mySkill.skill_level <= 1 then
        gf:ShowSmallTips(CHS[5400019])
        return
    elseif nextSkill
        and SkillMgr:getSkill(Me:getId(), nextSkill.no)
        and mySkill.skill_level <= LEVELDOWN_LIMITS[mySkill.subclass][mySkill.ladder] then
        gf:ShowSmallTips(string.format(CHS[5400020], nextSkill.name, mySkill.skill_name, LEVELDOWN_LIMITS[mySkill.subclass][mySkill.ladder]))
        return
    end

    local moneyDesc = gf:getMoneyDesc(LEVELDOWN_COSTMONEY, false)
    gf:confirm(string.format(CHS[5400021], moneyDesc, mySkill.skill_name), function ()
        if not gf:checkHasEnoughMoney(LEVELDOWN_COSTMONEY) then
            return
        end

        gf:CmdToServer("CMD_DOWNGRADE_SKILL", {
            id = Me:getId(),
            skill_no = self.curSkillNo,
        })
    end)
end

-- 选中了某个技能
function SkillDlg:onSelectSkillListView(sender, eventType)
    local imgText = self:getListViewSelectedItem(sender)

    -- 设置技能信息
    self:setSelectedSkillInfo(imgText)
end

function SkillDlg:MSG_UPDATE_SKILLS(data)
    self:setSkillInfo(self.curCheckBox)
end

function SkillDlg:MSG_TASK_STATUS_INFO(data)
    self:setSkillInfo(self.curCheckBox)
end

function SkillDlg:MSG_REQUEST_BROTHER_INFO(data)
    self:setSkillInfo(self.curCheckBox)
end

function SkillDlg:MSG_UPDATE(data)
    if not self.curSkillNo then return end
    local skill = SkillMgr:getskillAttrib(self.curSkillNo)
    if skill and skill.skill_subclass == SKILL.SUBCLASS_F then
        local ownMoney = Me:queryInt("cash")
        local moneyDesc, fontColor = gf:getArtFontMoneyDesc(ownMoney, true)
        self:setNumImgForPanel("MoneyPanel1", fontColor, moneyDesc, false, LOCATE_POSITION.LEFT_BOTTOM, 23)
    end

end

-- 如果需要使用指引通知类型，需要重载这个函数
function SkillDlg:youMustGiveMeOneNotify(param)
    if "learnCSkill" == param then
        performWithDelay(self.root, function()
            GuideMgr:youCanDoIt(self.name, param)
        end, 0.1)
    elseif "setAutoFightDefaultParam" == param then
        AutoFightMgr:getDefaultFigthAction(Me)
        local autoSkillType, autoSkiillParam = AutoFightMgr:getMeLastActionInfo()

        if autoSkillType and autoSkiillParam then
            AutoFightMgr:setMeAutoFightAction(autoSkillType, autoSkiillParam)
        end

        GuideMgr:youCanDoIt(self.name, param)
    end
end

-- 打开某个子界面
function SkillDlg:onDlgOpened(list)
    if list[1] == "c1" then
        self.curSkillNo = nil
        self:setSkillInfo(CHECK_TABLE["CType"])
    end
end

function SkillDlg:MSG_LEARN_UPPER_STD_SKILL_COST(data)
    if not self.curSkillNo then return end
    if not self.jySkill then return end
    if self.jySkill.skill_no ~= self.curSkillNo then return end


    DlgMgr:openDlgEx("Confirm3Dlg", data)
end

return SkillDlg
