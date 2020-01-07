-- PetSkillDlg.lua
-- Created by chenyq Apr/30/2015
-- 宠物技能界面

local PetSkillDlg = Singleton("PetSkillDlg", Dialog)

local DEFAULT_SKILL_NUM = 4 -- 宠物技能默认格子个数
local IDX_POWER = 1000000
local MIN_CASH_COST = 1600
local ART_FONT_TAG_FACTOR = 999 -- 美术字tag对应的因子
local PRICE = 164 -- 补充灵气所需元宝数量
local DELAY_TIME = 0.5
local JINJIE_SKILL_MAX_LEVEL = 160 -- 进阶技能最大等级
local LEVELDOWN_COSTMONEY = 500000  -- 降低一级技能所花费的金钱\代金券

local UPLEVEL_NEED_INTIMACY = 30000 -- 升级技能的亲密度条件
local YANFA_UPLEVEL_NEED_INTIMACY = 100000 -- 研发技能升级的亲密度条件

local INNATE_SKILLS = {
    CHS[3003416], CHS[3003417], CHS[3003418], CHS[3003419], CHS[3003420], CHS[3003421], CHS[3003422],
    CHS[3003423], CHS[3003424], CHS[3003425], CHS[3003426], CHS[3003427], CHS[3003428], CHS[3003429],
}

function PetSkillDlg:init()
    self:hookMsg("MSG_REFRESH_PET_GODBOOK_SKILLS")
    self:hookMsg("MSG_UPDATE_SKILLS")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_PETS")
    self:hookMsg("MSG_DUNWU_SKILL")
    self:hookMsg("MSG_INVENTORY")

    local pet = DlgMgr:sendMsg("PetListChildDlg","getCurrentPet")

    self.petName = ''
    if pet then
        self.petName = pet:queryBasic('name')
        self.pet = pet
        self:setCtrlVisible("SkillIllustratePanel", true)
    else
        self:setCtrlVisible("SkillIllustratePanel", false)
        self:setCtrlVisible("SkillIllustratePanel_1", false)
    end

    -- 初始化下帮派信息
    PartyMgr:queryPartyInfo()

    self:bindListener("LevelUpButton", self.onLearnButton, "BornScreenPanel_2")
    self:bindListener("LevelUp10Button", self.onLearFiveTimesButton, "BornScreenPanel_2")
    self:bindListener("StudyButton", self.onLearnInnateSkillButton, "BornScreenPanel_1")
    self:bindListener("StudyButton", self.onLearnDevelopSkillButton, "MadeScreenPanel_2")
    self:bindListener("LevelUpButton", self.onLearnDevelopSkillButton, "MadeScreenPanel_1")
    self:bindListener("LevelUp10Button", self.onLearFiveTimesButton, "MadeScreenPanel_1")
    self:bindListener("LevelDownButton", self.onLevelDownButton, "BornScreenPanel_2")
    self:bindListener("LevelDownButton", self.onLevelDownButton, "MadeScreenPanel_1")
    self:bindCheckBoxListener("BindCheckBox", self.onCheckBox)

    self:bindListener("DunwuButton", self.onDunwuButton)
    self:bindListener("UseCoinPanel", self.onUseCoinPanel)
    self:bindPanelEvent("RefillNimbusPanel")
    self:bindListener("AddButton", function(dlg, sender, eventType)
        if not self.pet then return end
        self:updateSelectPet()
        self:showFastUsePanel("RefillNimbusPanel")
    end, "AddNimbusPanel")

    -- 天书技能启用状态
    self:setCtrlOnlyEnabled("ChoseCheckBox", false, "BookScreenPanel_1")
    self:bindListener("UseSkillPanel", self.onGodBookEnable, "BookScreenPanel_1")

    -- 顿悟技能启用状态
    self:setCtrlOnlyEnabled("ChoseCheckBox", false, "AddNimbusPanel")
    self:bindListener("UseSkillPanel", self.onDunWuEnable, "AddNimbusPanel")

    -- 补充灵气所需元宝数量
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, PRICE, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "UseCoinPanel")
    self:getControl("NumPanel", nil, "UseCoinPanel"):setVisible(true)

    -- 顿悟丹是否使用永久限制交易checkbox
    self:bindListener("LimitedCheckBox", self.onLimitedCheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name .. "_DunWu"] == 1 then
        self:setCheck("LimitedCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name .. "_DunWu"] == 0 then
        self:setCheck("LimitedCheckBox", false)
    end

    self:bindTitleButton("AtkPanel")
    self:bindTitleButton("BornPanel")
    self:bindTitleButton("MadePanel")
    self:bindTitleButton("BookPanel")
    self:bindTitleButton("DunWuPanel")

    self:setCtrlVisible("NoneSkillImage", false)

    -- 取出天书
    self:bindListener("OutButton", self.onForgetButton, "BookScreenPanel_1")
    self:bindListener("AddButton", self.onApplyGodbookButton, "BookScreenPanel_1")

    self.otherListView = self:getControl("ListView", Const.UIListView)
    self.dunwuListView = self:getControl("ListViewDunwu", Const.UIListView)
    self.listView = nil

    self.cloneItem = self:getControl("SkillPanel_1", Const.UIPanel)
    self:setCtrlVisible("CanLevelImage", false, self.cloneItem)
    self.cloneItem:retain()
    self.cloneItem:removeFromParent()

    local node = self:getControl("BindCheckBox", Const.UICheckBox)
    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end
    self:onCheckBox(node, 2)

    self:setShowSkill("AtkPanel", CHS[3003430])

    -- 刷新宠物列表
    DlgMgr:sendMsg("PetListChildDlg", "refreshList")
end

function PetSkillDlg:cleanup()
    self:closeAllChildDlg()
    DlgMgr:closeDlg('SubmitGodBookDlg')
    self:releaseCloneCtrl("cloneItem")
end

function PetSkillDlg:onLimitedCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name .. "_DunWu", 1)
        gf:ShowSmallTips(CHS[6000525])
    else
        InventoryMgr:setLimitItemDlgs(self.name .. "_DunWu", 0)
    end

    self:showFastUsePanel("RefillNimbusPanel")
end

function PetSkillDlg:onGodBookEnable(sender, eventType)
    -- 天书技能启用/禁用
    local checkCtl = self:getControl("ChoseCheckBox", nil, sender)

    local state = checkCtl:getSelectedState()



    local disabled = state and 1 or 0


    local pet = self.pet
    local skillName = self.curSkillName
    if not pet or not skillName then
        return
    end

    local pos = pet:queryBasicInt("no")
  	gf:CmdToServer("CMD_SET_GODBOOK_SKILL_STATE",{pos = pos, godbook = skillName, disabled = disabled})
end

function PetSkillDlg:onDunWuEnable(sender, eventType)
    -- 顿悟技能启用/禁用
    local checkCtl = self:getControl("ChoseCheckBox", nil, sender)
    local state = checkCtl:getSelectedState()


    local disabled = state and 1 or 0

    local pet = self.pet
    local skillNo = self.curSkillNo
    if not pet or not skillNo then
        return
    end

    local pos = pet:queryBasicInt("no")
    gf:CmdToServer("CMD_SET_DUNWU_SKILL_STATE",{pos = pos, dunwu = skillNo, disabled = disabled})
end

function PetSkillDlg:bindTitleButton(panelName, root)
    self:bindListener(panelName, function(dlg, sender, eventType)
        self:setShowSkill(panelName)
    end, root)
end

function PetSkillDlg:bindPanelEvent(name)
    local panel = self:getControl(name, Const.UIPanel)
    if not panel then return end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d, name:%s", touchPos.x, touchPos.y, event:getCurrentTarget():getName())

        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        if cc.rectContainsPoint(box, touchPos) then
            return true
        end

        self:closeFastUsePanel()
        return false
    end

    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

function PetSkillDlg:closeFastUsePanel()
    self:setCtrlVisible("RefillNimbusPanel", false)
end

function PetSkillDlg:updateFastUsePanel()
    self:updateOneFastUsePanel("RefillNimbusPanel", CHS[7000210], "UseItemPanel")
end

-- 更新单条悬浮框
function PetSkillDlg:updateOneFastUsePanel(panel, itemName, key)
    if not self.pet then
        return
    end

    local isUseLimited = false
    if self:isCheck("LimitedCheckBox", panel) then
        isUseLimited = true
    else
        isUseLimited = false
    end

    local tempPanel = self:getControl(key, Const.UIPanel, panel)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
    self:setCtrlVisible("NumPanel", true, tempPanel)

    if amount >= 0 and amount <= 99 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount .. "/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    elseif amount > 99 then
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, "*/1", false, LOCATE_POSITION.RIGHT_BOTTOM, 19, tempPanel)
    end

    return isUseLimited
end

function PetSkillDlg:initFastUsePanel(itemNames, addPanelName)
    if not self.pet then return end
    self:updateSelectPet()
    local panel = self:getControl(addPanelName, Const.UIPanel)
    local items = {}
    local isUseLimited = false

    for key, itemName in pairs(itemNames) do
        isUseLimited = self:updateOneFastUsePanel(panel, itemName, key)

        -- 设置img
        local tempPanel = self:getControl(key, Const.UIPanel, panel)
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(itemName), tempPanel)
        self:setItemImageSize("GuardImage", tempPanel)
        self:setLabelText("NameLabel", itemName, tempPanel)
        self:setCtrlVisible("ChosenEffectImage", false, tempPanel)

        self:blindLongPress(key,
            function(dlg, sender, eventTye)

                self.curDelay = 0
                self.isLongPress = true
                self.curItemName = itemName
                self.curIsUseLimited = isUseLimited
                self.curTempPanel = tempPanel
                self:setCtrlVisible("ChosenEffectImage", true, self.curTempPanel)
            end,

            function(dlg, sender, eventType)
                if self.isLongPress then
                    self.isLongPress = false
                    return
                end

                if not sender:getParent():isVisible() then
                    return
                end

                if self:checkCanUseItem(itemName) then
                    local isUseLimited = false
                    if self:isCheck("LimitedCheckBox", panel) then
                        isUseLimited = true
                    else
                        isUseLimited = false
                    end

                    local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
                    if amount < 1 then
                        gf:askUserWhetherBuyItem(itemName)
                        return
                    end

                    local item = InventoryMgr:getPriorityUseInventoryByName(itemName, isUseLimited)
                    local str, day = gf:converToLimitedTimeDay(self.pet:queryInt("gift"))
                    local skillName = self.curSkillName
                    local skillNo = self.curSkillNo
                    local pet = self.pet
                    if not skillName then
                        return
                    end

                    local type = 3
                    if isUseLimited then type = 2 end
                    if isUseLimited and InventoryMgr:getAmountByNameForeverBind(itemName) > 0 and day <= Const.LIMIT_TIPS_DAY then
                        gf:confirm(string.format(CHS[7000237], 10, skillName), function()
                            gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
                                id = pet:queryBasic("id"),
                                skill_no = skillNo,
                                type = type,
                                pos = item.pos,
                            })
                        end)
                    else
                        gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
                            id = pet:queryBasic("id"),
                            skill_no = skillNo,
                            type = type,
                            pos = item.pos,
                        })
                    end

                    self:setCtrlVisible("ChosenEffectImage", true, tempPanel)
                else
                    self:closeFastUsePanel()
                    self.isLongPress = false
                end
            end,
            panel, true, function ()
                self.isLongPress = false
            end)
    end
end

function PetSkillDlg:onUpdate(dt)
    if self.isLongPress then
        if not self.curDelay then
            self.curDelay = 0
        end

        self.curDelay = self.curDelay + (1 / Const.FPS)

        if self.curDelay >= DELAY_TIME then
            self.curDelay = self.curDelay - DELAY_TIME
            if self:checkCanUseItem(self.curItemName) then
                local isUseLimited = false
                local panel = "RefillNimbusPanel"
                local itemName = CHS[7000210]
                if self:isCheck("LimitedCheckBox", panel) then
                    isUseLimited = true
                else
                    isUseLimited = false
                end

                local amount = InventoryMgr:getAmountByNameIsForeverBind(itemName, isUseLimited)
                if amount < 1 then
                    gf:askUserWhetherBuyItem(itemName)
                    return
                end

                local item = InventoryMgr:getPriorityUseInventoryByName(itemName, isUseLimited)
                local str, day = gf:converToLimitedTimeDay(self.pet:queryInt("gift"))
                local skillName = self.curSkillName
                local skillNo = self.curSkillNo
                local pet = self.pet
                if not skillName then
                    return
                end

                local type = 3
                if isUseLimited then type = 2 end
                if isUseLimited and InventoryMgr:getAmountByNameForeverBind(itemName) > 0 and day <= Const.LIMIT_TIPS_DAY then
                    gf:confirm(string.format(CHS[7000237], 10, skillName), function()
                        gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
                            id = pet:queryBasic("id"),
                            skill_no = skillNo,
                            type = type,
                            pos = item.pos,
                        })
                    end)
                else
                    gf:CmdToServer("CMD_ADD_DUNWU_NIMBUS", {
                        id = pet:queryBasic("id"),
                        skill_no = skillNo,
                        type = type,
                        pos = item.pos,
                    })
                end
            else
                self:closeFastUsePanel()
                self.isLongPress = false
            end

        end

    end
end

function PetSkillDlg:showFastUsePanel(name)
    self:setCtrlVisible("RefillNimbusPanel", true)

    self:initFastUsePanel({["UseItemPanel"]= CHS[7000210]}, "RefillNimbusPanel")
end

function PetSkillDlg:checkCanUseItem(name)
    if not self.pet then
        return false
    end

    if name == CHS[7000210] then  -- 宠物顿悟丹
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return false
        end

        if self.pet:queryInt("rank") == Const.PET_RANK_WILD then
            gf:ShowSmallTips(string.format(CHS[7000211], self.pet:getShowName()))
            return false
        end

        if PetMgr:isTimeLimitedPet(self.pet) then
            gf:ShowSmallTips(string.format(CHS[7000212], self.pet:getShowName()))
            return false
        end

        local skillWithPet = SkillMgr:getSkill(self.pet:getId(), self.curSkillNo)
        if skillWithPet.skill_nimbus >= 15000 then
            gf:ShowSmallTips(CHS[7000213])
            return false
        end

        return true
    end

    return false
end

-- 元宝补充
function PetSkillDlg:onUseCoinPanel(sender, eventType)
    if not self.pet then return end
    self:updateSelectPet()
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local dlg = DlgMgr:openDlg("PetDunWuBuyDlg")
    dlg:setInfo(self.pet, self.curSkillNo)
end

function PetSkillDlg:onDunwuButton(sender, eventType)
    local dlg = DlgMgr:openDlg("PetDunWuDlg")
    if self:getCtrlVisible("DunwuLabel", "DunwuButton") then
        dlg:setInfo(self.pet)
    else
        dlg:setInfo(self.pet, self.curSkillName)
    end
end

function PetSkillDlg:setShowSkill(panelName, skillName)
    self.curPanelName = panelName
    if skillName then
       self.curSkillName = skillName
    end
    self:showSkill(panelName, skillName)
end

function PetSkillDlg:showSkill(panelName, skillName)
    self:hideAllOperatePanel()
    self:clearTitleSelectEffect()
    self:setCtrlVisible("ChoseImage", true, panelName)

    self:setCtrlVisible("NoneSkillImage", false)
    -- 设置当没有宠物时隐藏列表和描述
    self:setCtrlVisible("ListView", true)

    -- 顿悟技能的排版格式与其他类别不同
    self:setCtrlVisible("SkillIllustratePanel", panelName ~= "DunWuPanel")
    self:setCtrlVisible("SkillIllustratePanel_1", panelName == "DunWuPanel")
    self:setCtrlVisible("AddNimbusPanel", false)
    if panelName == "DunWuPanel" then
        self.listView = self.dunwuListView
        self.otherListView:setVisible(false)
        self.dunwuListView:setVisible(true)
        self:setCtrlVisible("Image_13", false, "SkillPanel")
        self:setCtrlVisible("Image_14", true, "SkillPanel")
        self:setCtrlVisible("SkillIllustratePanel", false)
        self:setCtrlVisible("SkillIllustratePanel_1", true)
    else
        self.listView = self.otherListView
        self.otherListView:setVisible(true)
        self.dunwuListView:setVisible(false)
        self:setCtrlVisible("Image_13", true, "SkillPanel")
        self:setCtrlVisible("Image_14", false, "SkillPanel")
        self:setCtrlVisible("SkillIllustratePanel", true)
        self:setCtrlVisible("SkillIllustratePanel_1", false)
    end

    -- 顿悟技能/天书技能/法攻、天生、研发技能的TITLE
    self:setCtrlVisible("TitlePanel", false, "SkillPanel")
    self:setCtrlVisible("TitlePanel_1", false, "SkillPanel")
    self:setCtrlVisible("TitlePanel_2", false, "SkillPanel")
    if panelName == "BookPanel" then
        self:setCtrlVisible("TitlePanel_1", true, "SkillPanel")
    elseif panelName == "DunWuPanel" then
        self:setCtrlVisible("TitlePanel_2", true, "SkillPanel")
    else
        self:setCtrlVisible("TitlePanel", true, "SkillPanel")
    end

    -- 顿悟技能/天书技能/法攻、天生、研发技能的技能信息
    if panelName == "BookPanel" then
        self:setCtrlVisible("TargetValueLabel", false, "SkillPanel_1")
        self:setCtrlVisible("CostLabel", false, "SkillPanel_1")
        self:setCtrlVisible("GodBookLabel", true, "SkillPanel_1")
        self:setCtrlVisible("CostLabel_2", false, "SkillPanel_1")
    elseif panelName == "DunWuPanel" then
        self:setCtrlVisible("TargetValueLabel", false, "SkillPanel_1")
        self:setCtrlVisible("CostLabel", false, "SkillPanel_1")
        self:setCtrlVisible("GodBookLabel", false, "SkillPanel_1")
        self:setCtrlVisible("CostLabel_2", true, "SkillPanel_1")
    else
        self:setCtrlVisible("TargetValueLabel", true, "SkillPanel_1")
        self:setCtrlVisible("CostLabel", true, "SkillPanel_1")
        self:setCtrlVisible("GodBookLabel", false, "SkillPanel_1")
        self:setCtrlVisible("CostLabel_2", false, "SkillPanel_1")
    end

    if not self.pet then
        self:setCtrlVisible("ListView", false)
        self:setCtrlVisible("SkillIllustratePanel", false)
        self:setCtrlVisible("SkillIllustratePanel_1", false)
        return
    end

    if panelName == "AtkPanel" then
        if PetMgr:isPhyPet(self.pet:queryBasic('raw_name')) then
            self:setPhySkill(self.pet)
        else
            self:setMagicSkill(self.pet)
        end
        if #self.listView:getItems() == 0 then
            self:setCtrlVisible("NoneSkillImage", true)
            self:setLabelText("NoneSkillLabel", CHS[3003431])
        end
        self:hideAllOperatePanel()
    elseif panelName == "BornPanel" then
        self:setInnateSkill(self.pet, skillName)
        if #self.listView:getItems() == 0 then
            self:setCtrlVisible("NoneSkillImage", true)
            self:setLabelText("NoneSkillLabel", CHS[3003432])
        end
    elseif panelName == "MadePanel" then
        self:setDevelopSkill(self.pet, skillName)
    elseif panelName == "BookPanel" then
        self:setGodBookSkill(self.pet)
    elseif panelName == "DunWuPanel" then
        self:setDunWuSkill(self.pet)
    end

    -- 重置帮贡/潜能消耗标识
    -- 在setDunWuSkill中已经对顿悟标签页的“帮贡/潜能图标的显示/隐藏”进行了相关处理，并与其他标签页对之进行的处理不同
    -- 目前仅有顿悟技能标签页可能出现潜能标识
    if panelName ~= "DunWuPanel" then
        self:setCtrlVisible("Image_204", true, "BornScreenPanel_2")
        self:setCtrlVisible("Image_206", true, "BornScreenPanel_2")
        self:setCtrlVisible("Image_207", false, "BornScreenPanel_2")
        self:setCtrlVisible("Image_208", false, "BornScreenPanel_2")
    end

    -- 设置详细信息
    local skillDescr = SkillMgr:getSkillDesc(skillName)
    if skillDescr then
        self:setColorText(skillDescr.pet_desc or skillDescr.desc or "", "DescrPanel", "SkillIllustratePanel", nil, nil, nil, 19)
        local listView = self:getControl("DescrListView", Const.UIListView, "SkillIllustratePanel")
        listView:requestRefreshView()
    end
end

function PetSkillDlg:onLearnButton(sender, eventType)
    if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then  --进阶技能
        self:onLearnJinjieButton(sender, eventType)
        return
    end


    if not self.pet then return end

    self:updateSelectPet()

    -- 获取宠物信息
    local pet = self.pet

    -- 宠物是否是限时宠物
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[4300151])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    local partyName = Me:queryBasic("party/name")
    if partyName == "" then
        gf:ShowSmallTips(CHS[3000123])
        return
    end

    if not PartyMgr:getPartyInfo() then return end

    local skillWithPet = SkillMgr:getSkill(pet:getId(), self.curSkillNo)
    local skillLv = skillWithPet.skill_level
    local petLv = pet:queryBasicInt("level")
    local skillName = SkillMgr:getSkillName(self.curSkillNo)
    local dLv = PartyMgr:getPartySkill(skillName).level
    local toLevel = skillLv + math.min(math.max(math.min(dLv, 80 * 1.6) - skillLv, 0), 1)

    if self.pet and self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips('#Y' .. self.pet:queryBasic('name') .. CHS[3003434])
        return
    end

    if self.pet:queryInt("origin_intimacy") < UPLEVEL_NEED_INTIMACY then
        gf:ShowSmallTips(string.format(CHS[7000248], UPLEVEL_NEED_INTIMACY))
        return
    end

    -- 获取帮贡跟金钱信息
    local skillWithPet = SkillMgr:getSkill(pet:getId(), self.curSkillNo)
    local costCash = skillWithPet.cost_cash or 0
    local costContrib = skillWithPet["cost_party/contrib"] or 0
    local meCash = Me:queryInt("cash") or 0
    local meContrib = Me:queryInt("party/contrib") or 0

    if costCash <= meCash and costContrib <= meContrib then
        -- 进行计算消耗
        PetMgr:studyInnateSkill( pet:getId(), self.curSkillNo)
    elseif costContrib > meContrib then
        -- 提示条件不足
        gf:ShowSmallTips(CHS[3003435])
    elseif costCash > meCash then
        -- 记得到时候修改
        gf:askUserWhetherBuyCash(costCash)
    end
end

function PetSkillDlg:onLearnJinjieButton(sender, eventType)
    if not self.pet or not self.curSkillNo then
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.pet:queryInt("origin_intimacy") < UPLEVEL_NEED_INTIMACY then
        gf:ShowSmallTips(string.format(CHS[7000248], UPLEVEL_NEED_INTIMACY))
        return
    end

    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), self.curSkillNo)
    local level = skillWithPet.skill_level
    local costCash = Formula:getCostCashPetJinjieSkill(level, 1)
    local costPot = Formula:getCostPotPetJinjieSkill(level, 1)
    local meCash = Me:queryInt("cash")
    local mePot = Me:queryInt("pot")
    local petId = self.pet:queryBasicInt("id")
    local skillNo = self.curSkillNo

    if level >= JINJIE_SKILL_MAX_LEVEL then
        gf:ShowSmallTips(CHS[7000249])
        return
    end

    if mePot < costPot then
        gf:ShowSmallTips(CHS[7000250])
        return
    end

    if meCash < costCash then
        gf:askUserWhetherBuyCash()
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onLearnJinjieButton", sender, eventType) then
        return
    end

    local data = {id  = petId, skill_no = skillNo, up_level = 1}
    gf:CmdToServer("CMD_LEARN_SKILL", data)
end

function PetSkillDlg:onLearnInnateSkillButton(sender, eventType)
    if not self.pet then return end
    self:updateSelectPet()
    -- 获取宠物信息
    local pet = self.pet

    -- 宠物是否是限时宠物
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[4300151])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    if pet:queryInt('rank') == Const.PET_RANK_WILD then
        -- 存在非野生的宠物
        gf:ShowSmallTips(string.format(CHS[4200040], pet:getShowName()))
        return true
    end

    if self.pet:queryInt("origin_intimacy") < UPLEVEL_NEED_INTIMACY then
        gf:ShowSmallTips(string.format(CHS[7000248], UPLEVEL_NEED_INTIMACY))
        return
    end

    -- 获取技能秘籍数量
    local skillBookName = self.skillName..CHS[3000087]
    local skillBookCount = InventoryMgr:getAmountByNameIsForeverBind(skillBookName, self:isCheck("BindCheckBox")) or 0

    if 0 >= skillBookCount then
        gf:ShowSmallTips(string.format(CHS[5000001], self.skillName))
    else
        local SkillItemStr = self.skillName .. CHS[3000087]
        InventoryMgr:feedPetByIsLimitItem(SkillItemStr, pet, "", self:isCheck("BindCheckBox"))
    end
end

function PetSkillDlg:sendSkillTouchEvent(skillName)

end

function PetSkillDlg:onLearFiveTimesButton(sender, eventType)
    if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then  --进阶技能
        self:onLearnJinjie10TimesButton(sender, eventType)
        return
    end

    if not self.pet then return end
    self:updateSelectPet()
    -- 获取宠物信息
    local pet = self.pet

    -- 宠物是否是限时宠物
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[4300151])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    local partyName = Me:queryBasic("party/name")
    if partyName == "" then
        gf:ShowSmallTips(CHS[3000123])
        return
    end

    if not PartyMgr:getPartyInfo() then return end

    if self.pet and self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips('#Y' .. self.pet:queryBasic('name') .. CHS[3003434])
        return
    end

    local needNum
    if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.INNATE then  --天生技能
        needNum = UPLEVEL_NEED_INTIMACY
    elseif SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.STUDY then  --研发技能
        needNum = YANFA_UPLEVEL_NEED_INTIMACY
    end

    if needNum and self.pet:queryInt("origin_intimacy") < needNum then
        gf:ShowSmallTips(string.format(CHS[7000248], needNum))
        return
    end

    -- 获取帮贡跟金钱信息
    local skillWithPet = SkillMgr:getSkill(pet:getId(), self.curSkillNo)
    local skillLv = skillWithPet.skill_level
    local petLv = pet:queryBasicInt("level")
    local skillName = SkillMgr:getSkillName(self.curSkillNo)
    local dLv = PartyMgr:getPartySkill(skillName).level
    local toLevel = skillLv + math.min(math.max(math.min(dLv, PartyMgr:getPartyLevelMax()) - skillLv, 0), 10)

    local costCash = 0
    local costContrib = 0

    local addLevel = toLevel - skillLv

    -- 为了保证提示消息一致，当无法升级时，将提升等级设置为1。
    if addLevel == 0 then
        addLevel = 1
    end

    local skillType = SkillMgr:getPetSkillType(self.curSkillName)
    local meCash = Me:queryInt("cash") or 0
    local meContrib = Me:queryInt("party/contrib") or 0

    while addLevel > 0 do
        if skillType == SkillMgr.PET_SKILL_TYPE.INNATE then
            costCash = Formula:getCostCashPetInnateSkill(skillLv, addLevel)
            costContrib = Formula:getCostConribPetInnateSkill(skillLv, addLevel)
        elseif skillType == SkillMgr.PET_SKILL_TYPE.STUDY then
            costCash = Formula:getCostCashPetDevelopSkill(skillLv, addLevel)
            costContrib = Formula:getCostConribPetDevelopSkill(skillLv, addLevel)
        end

        if costCash <= meCash and costContrib <= meContrib then
            PetMgr:studyInnateSkill( pet:getId(), self.curSkillNo, addLevel)
            return
        end

        addLevel = addLevel - 1
    end

    if costContrib > meContrib then
        -- 提示条件不足
        gf:ShowSmallTips(CHS[3003435])
    elseif costCash > meCash then
        -- 记得到时候修改
        gf:askUserWhetherBuyCash(costCash)
    end
end

function PetSkillDlg:onLevelDownButton(sender, eventType)
    if not self.pet then return end
    self:updateSelectPet()

    -- 获取宠物信息
    local pet = self.pet
    local petId = self.pet:queryBasicInt("id")

    -- 宠物是否是限时宠物
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[4300151])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[5000228])
        return
    end

    local skillWithPet = SkillMgr:getSkill(pet:getId(), self.curSkillNo)
    if not skillWithPet or skillWithPet.skill_level <= 1 then
        gf:ShowSmallTips(CHS[5400019])
        return
    end

    local meCash = Me:queryInt("cash")
    local moneyDesc = gf:getMoneyDesc(LEVELDOWN_COSTMONEY, false)
    gf:confirm(string.format(CHS[5400022], moneyDesc, pet:queryBasic('name'), skillWithPet.skill_name), function ()
        if meCash < LEVELDOWN_COSTMONEY then
            gf:askUserWhetherBuyCash()
            return
        end

        gf:CmdToServer("CMD_DOWNGRADE_SKILL", {
            id = petId,
            skill_no = self.curSkillNo,
        })
    end)
end

function PetSkillDlg:onLearnJinjie10TimesButton(sender, eventType)
    if not self.pet or not self.curSkillNo then
        return
    end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003333])
        return
    end

    if self.pet:queryInt("origin_intimacy") < UPLEVEL_NEED_INTIMACY then
        gf:ShowSmallTips(string.format(CHS[7000248], UPLEVEL_NEED_INTIMACY))
        return
    end

    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), self.curSkillNo)
    local level = skillWithPet.skill_level
    local addLevel = math.min(math.max(JINJIE_SKILL_MAX_LEVEL - level, 0), 10)
    local costCash = Formula:getCostCashPetJinjieSkill(level, addLevel)
    local costPot = Formula:getCostPotPetJinjieSkill(level, addLevel)
    local meCash = Me:queryInt("cash")
    local mePot = Me:queryInt("pot")
    local petId = self.pet:queryBasicInt("id")
    local skillNo = self.curSkillNo

    while (costCash > meCash or costPot > mePot) and addLevel > 1 do
        addLevel = addLevel - 1
        costCash = Formula:getCostCashPetJinjieSkill(level, addLevel)
        costPot = Formula:getCostPotPetJinjieSkill(level, addLevel)
    end

    if level >= JINJIE_SKILL_MAX_LEVEL then
        gf:ShowSmallTips(CHS[7000249])
        return
    end

    if mePot < costPot then
        gf:ShowSmallTips(CHS[7000250])
        return
    end

    if meCash < costCash then
        gf:askUserWhetherBuyCash()
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onLearnJinjie10TimesButton", sender, eventType) then
        return
    end

    local data = {id  = petId, skill_no = skillNo, up_level = addLevel}
    gf:CmdToServer("CMD_LEARN_SKILL", data)
end

function PetSkillDlg:onForgetButton(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onForgetButton", sender, eventType) then
        return
    end

    -- 获取宠物信息
    local pet = self.pet
    gf:confirm(string.format(CHS[3003436], self.curSkillName),
        function(str)
            gf:sendGeneralNotifyCmd(NOTIFY.DELETE_GODBOOK_SKILL, pet:queryBasicInt("no"), self.curSkillName)
            SkillMgr.selectGodbookSkillName = nil
        end)
end

function PetSkillDlg:onApplyGodbookButton(sender, eventType)
    local pet = self.pet
    local petNo = pet:queryBasicInt("no")
    local dlg = DlgMgr:openDlg("SubmitGodBookDlg")
    dlg:setPetId(pet:getId())
    dlg:intSubmitInfo(true)
end

function PetSkillDlg:onLearnDevelopSkillButton(sender, eventType)
    if not self.pet then return end
    self:updateSelectPet()

    -- 获取宠物信息
    local pet = self.pet

    -- 宠物是否是限时宠物
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[4300151])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003433])
        return
    end

    if self.pet and self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[3003437])
        return
    end

    if self.pet:queryInt("origin_intimacy") < YANFA_UPLEVEL_NEED_INTIMACY then
        gf:ShowSmallTips(string.format(CHS[7000248], YANFA_UPLEVEL_NEED_INTIMACY))
        return
    end

    -- 获取帮贡跟金钱信息
    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), self.curSkillNo)
    local skillLv = 0
    if skillWithPet then
        skillLv = skillWithPet.skill_level
    end
    local addLevel = 1

    -- 获取金钱
    local costCash = 0
    local costContrib = 0
    local meCash = Me:queryInt("cash") or 0
    local meContrib = Me:queryInt("party/contrib") or 0

    local skillType = SkillMgr:getPetSkillType(self.curSkillName)
    if skillType == SkillMgr.PET_SKILL_TYPE.INNATE then
        costCash = Formula:getCostCashPetInnateSkill(skillLv, addLevel)
        costContrib = Formula:getCostConribPetInnateSkill(skillLv, addLevel)
    elseif skillType == SkillMgr.PET_SKILL_TYPE.STUDY then
        costCash = Formula:getCostCashPetDevelopSkill(skillLv, addLevel)
        costContrib = Formula:getCostConribPetDevelopSkill(skillLv, addLevel)
    end

    if costContrib > meContrib then
        gf:ShowSmallTips(CHS[3003435])
        return
    end

    if costCash > meCash then
        gf:askUserWhetherBuyCash(costCash)
        return
    end

    if nil == skillWithPet then
        -- 说明尚未学习这个技能
        PetMgr:studyDevelopSkill(self.pet:getId(), self.curSkillNo)
        return
    end

    PetMgr:studyDevelopSkill(self.pet:getId(), self.curSkillNo)
end

function PetSkillDlg:updateSelectPet()
    if not self.pet then return end
    self.pet = PetMgr:getPetByNo(self.pet:queryBasicInt("no"))
end

-- 选中默认技能
function PetSkillDlg:selectDefaultSkill()
    if not self.pet then return end
    self:updateSelectPet()

    local magicSkillImgStr = "MagicSkillImage_1"
    local imgViewCtrl = self:getControl(magicSkillImgStr, Const.UIImage)
    if PetMgr:isPhyPet(self.pet:queryBasic('raw_name')) then
        self:onPetPhySkillDetil(imgViewCtrl, ccui.TouchEventType.ended)
    else
        self:onPetMagicSkillDetil(imgViewCtrl, ccui.TouchEventType.ended)
    end

    --self:showChosenImg('MagicChosenImage_1')
end

-- 设置宠物信息
function PetSkillDlg:setPetInfo(pet)
    -- 记录上一次选择宠物的ID
    local lastSelectPetId
    if self.pet then
        lastSelectPetId = self.pet:getId()
    end

    self.pet = pet
    self:showSkill(self.curPanelName)
    self:updateFastUsePanel()

    if not pet or not lastSelectPetId or lastSelectPetId ~= pet:getId() then
        -- 如果当前选择的宠物与上一次选择的宠物不同，则关闭快捷补充灵气界面
        self:closeFastUsePanel()
    end
end


-- 显示选中的图片
function PetSkillDlg:showChosenImg(imgName)
    if self.curChosenImg then
        self:setCtrlVisible(self.curChosenImg, false)
    end

    self:setCtrlVisible(imgName, true)
    self.curChosenImg = imgName
end

function PetSkillDlg:setOpenSmallDlg(isOpen)
    self.isOpenSmallDlg = isOpen;
end

function PetSkillDlg:controlSmallDlg()
    self:closeAllChildDlg()

    self.isOpenSmallDlg = true
    return true
end

function PetSkillDlg:closeAllChildDlg()
    DlgMgr:closeDlg('PetMagicSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetGodbookSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetUpGodbookSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetUpRawSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetDevelopSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetRawSkillChildDlg', nil, true)
    DlgMgr:closeDlg('PetPhySkillChildDlg', nil, true)
end

-- 设置技能
function PetSkillDlg:setSkills(pet, isNotReset)
    self:hideAllOperatePanel()
    self.pet = pet

    if not pet then return end
    local isPhyPet = false
    if PetMgr:isPhyPet(pet:queryBasic('raw_name')) then
        self:setPhySkill(pet)
        isPhyPet = true
    else
        self:setMagicSkill(pet)
    end
    self:setCtrlVisible("SkillIllustratePanel", true)
end

function PetSkillDlg:onItemTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:clearSelectEffect()
        self:setCtrlVisible("ChoseImage", true, sender)
        local skillType = SkillMgr:getPetSkillType(self.curSkillName)

        -- 设置详细信息
        local skillDescr = SkillMgr:getSkillDesc(self.curSkillName)
        self:setColorText(skillDescr.pet_desc or skillDescr.desc or "", "DescrPanel", "SkillIllustratePanel", nil, nil, nil, 19)
        local listView = self:getControl("DescrListView", Const.UIListView, "SkillIllustratePanel")
        listView:requestRefreshView()

        if skillType == SkillMgr.PET_SKILL_TYPE.INNATE then
            self:showLevelUpInnateSkill(sender, eventType)
        elseif skillType == SkillMgr.PET_SKILL_TYPE.STUDY then
            self:showLevelUpDevelopSkill(sender, eventType)
        elseif skillType == SkillMgr.PET_SKILL_TYPE.GODBOOK then
            self:showLevelUpGodbookSkill(sender, eventType)
        end
    end
end

function PetSkillDlg:onDunWuSkillTouch(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:clearSelectEffect()
        self:setCtrlVisible("ChoseImage", true, sender)
        self:hideAllOperatePanel()

        if not self.curSkillName then
            self:setCtrlVisible("SkillIllustratePanel_1", false)
            self:setCtrlVisible("AddNimbusPanel", false)
            self:setCtrlVisible("DunwuLabel", true, "AddNimbusPanel")
            self:setCtrlVisible("ForgetLabel", false, "AddNimbusPanel")
            self:setCtrlVisible("BornScreenPanel_2", false)
        else
            self:setCtrlVisible("SkillIllustratePanel_1", true)
            self:setCtrlVisible("AddNimbusPanel", true)
            self:setCtrlVisible("DunwuLabel", false, "AddNimbusPanel")
            self:setCtrlVisible("ForgetLabel", true, "AddNimbusPanel")
            self:setCtrlVisible("BornScreenPanel_2", true)

            -- 技能图标、技能灵气值、技能描述
            local skillName = self.curSkillName
            local skillDescr = SkillMgr:getSkillDesc(skillName)
            local skill = SkillMgr:getskillAttribByName(skillName)
            local skillWithPet = SkillMgr:getSkill(self.pet:queryBasicInt("id"), skill.skill_no)
            if not skillWithPet then
                return
            end

            local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
            local skillNimbus = skillWithPet.skill_nimbus
            local skillDisabled = skillWithPet.skill_disabled
            self:setImage("CostImage", skillIconPath, "AddNimbusPanel")
            self:setItemImageSize("CostImage", "AddNimbusPanel")
            if skillNimbus == 0 then
                self:setLabelText("CostLabel_1", skillNimbus, "AddNimbusPanel", COLOR3.RED)
            else
                self:setLabelText("CostLabel_1", skillNimbus, "AddNimbusPanel", COLOR3.TEXT_DEFAULT)
            end
            self:setLabelText("DescrLabel", skillDescr.pet_desc or skillDescr.desc, "SkillIllustratePanel_1")
            self:showLevelUpDunWuSkill(sender,eventType)

            -- 顿悟技能启用状态
            self:setCheck("ChoseCheckBox", skillDisabled == 0, "AddNimbusPanel")

            self:updateLayout("AddNimbusPanel")
        end
    end
end

function PetSkillDlg:clearSelectEffect()
    if not self.listView then return end

    local items = self.listView:getItems()

    for k, item in pairs(items) do
        self:setCtrlVisible("ChoseImage", false, item)
    end
end

function PetSkillDlg:clearTitleSelectEffect()
    self:setCtrlVisible("NormalImage", true, "AtkPanel")
    self:setCtrlVisible("ChoseImage", false, "AtkPanel")
    self:setCtrlVisible("NormalImage", true, "BornPanel")
    self:setCtrlVisible("ChoseImage", false, "BornPanel")
    self:setCtrlVisible("NormalImage", true, "MadePanel")
    self:setCtrlVisible("ChoseImage", false, "MadePanel")
    self:setCtrlVisible("NormalImage", true, "BookPanel")
    self:setCtrlVisible("ChoseImage", false, "BookPanel")
    self:setCtrlVisible("NormalImage", true, "DunWuPanel")
    self:setCtrlVisible("ChoseImage", false, "DunWuPanel")
end

-- 设置力宠物理攻击技能
function  PetSkillDlg:setPhySkill(pet)
    self.listView:removeAllItems()
    self:setCtrlVisible("SkillIllustratePanel", false)

    if 1 then return end

    -- 获取当前选择的宠物
    if pet == nil then return end

    -- 清空listview
    local item = self.cloneItem
    self:setImage("GuardImage", ResMgr.ui.pet_phy_skill_icon, item)
    self:setLabelText("LevelLabel", CHS[3003438], item)
    self:setLabelText("NameLevel", CHS[3003430], item)
    self:setCtrlVisible("ChoseImage", false, item)
    self.listView:pushBackCustomItem(item)
    item:addTouchEventListener(function(sender, eventType)
        self.curSkillName = CHS[3003430]
        self.curSkillNode = sender
        self:onItemTouch(sender, eventType)
    end)
    self:setCtrlVisible("SkillIllustratePanel", true)
    self:onItemTouch(item, 2)

end

-- 设置宠物的法攻技能
function PetSkillDlg:setMagicSkill(pet)
    self.listView:removeAllItems()
    self:setCtrlVisible("SkillIllustratePanel", false)
    -- 获取当前选择的宠物
    if pet == nil then return end

    self:setPhySkill(pet)

    -- 获取 法攻技能
    -- 获取宠物相性技能
    local normalSkills = SkillMgr:getSkillsByPolarAndSubclass(pet:queryBasicInt("polar"), SKILL.SUBCLASS_B)
    if nil == normalSkills then return end

    -- 获取宠物已经拥有的技能
    local petSkills = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_B)
    local normalSkillsCount = #normalSkills
    local petSkillsCount = 0
    if nil ~= petSkills then
        petSkillsCount = #petSkills
    end

    -- 在技能列表框 中设置技能图标
    local k  = 1
    local isDefault = false
    self:setCtrlVisible("SkillIllustratePanel", true)
    for i = 1, normalSkillsCount do
        if (SKILL.LADDER_1 == normalSkills[i].ladder or
            SKILL.LADDER_2 == normalSkills[i].ladder or
            SKILL.LADDER_4 == normalSkills[i].ladder) then

            -- 获取技能图标
            local skillIconPath = SkillMgr:getSkillIconPath(normalSkills[i].no)
            if nil == skillIconPath then return end

            -- 设置技能图标
            local idx = 1
            if SKILL.LADDER_2 == normalSkills[i].ladder then
                idx = 2
            elseif SKILL.LADDER_4 == normalSkills[i].ladder then
                idx = 3
            end

            local item = self.cloneItem:clone()

            if k % 2 ~= 0 then
                self:setCtrlVisible("Image_1", false, item)
                self:setCtrlVisible("Image_2", true, item)
            else
                self:setCtrlVisible("Image_1", true, item)
                self:setCtrlVisible("Image_2", false, item)
            end

            k = k + 1

            self:setCtrlVisible("ChoseImage", false, item)
            self:setImage("GuardImage", skillIconPath, item)
            self:setItemImageSize("GuardImage", item)

            -- 判断宠物是否已经拥有这个技能
            local isHas = false;
            for j = 1, petSkillsCount do
                if normalSkills[i].no == petSkills[j].no then
                    -- 标志已经拥有
                    isHas = true
                end
            end

            -- 如果宠物未拥有这个技能
            if not isHas then
                -- 进行图标置灰操作
                self:setCtrlEnabled("GuardImage", false, item)
                self:setLabelText("LevelLabel", 0, item)
                self:setLabelText("TargetValueLabel", 0, item)
                self:setLabelText("CostLabel", 0, item)
            else
                -- 进行设置等级
                self:setCtrlEnabled("GuardImage", true, item)
                local skillWithPet = SkillMgr:getSkill(pet:getId(), normalSkills[i].no)
                self:setLabelText("LevelLabel", skillWithPet.skill_level, item)
                self:setLabelText("TargetValueLabel", skillWithPet.range, item)
                self:setLabelText("CostLabel", skillWithPet.skill_mana_cost, item)
            end
            self:setLabelText("NameLabel", normalSkills[i].name, item)
            item:addTouchEventListener(function(sender, eventType)
                self.curSkillName = normalSkills[i].name
                self.curSkillNode = sender
                self:onItemTouch(sender, eventType)
            end)
            self.listView:pushBackCustomItem(item)

            if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.ATTACK then
                if self.curSkillName == normalSkills[i].name then
                    isDefault = true
                    self:onItemTouch(item, 2)
                end
            else
                if i == 1 then
                    local firstItem = self.listView:getItem(0)
                    self.curSkillName = firstItem:getChildByName("NameLabel"):getString()
                    self:onItemTouch(firstItem, 2)
                    isDefault = true
                end
            end
        end
    end

    if not isDefault then
        -- 没有默认选中的话
        local item = self.listView:getItem(0)
        if item then
            local textLabel = item:getChildByName("NameLabel")

            if textLabel then
                local skillName = textLabel:getString()
                self.curSkillName = skillName
                local skill = SkillMgr:getskillAttribByName(skillName)
                self.curSkillNode = item
                self.curSkillNo = skill.skill_no
                self:onItemTouch(item, 2)
            else
                self:hideAllOperatePanel()
            end
        end
    end
end

-- 设置宠物的天生技能
function PetSkillDlg:setInnateSkill(pet, selectSkillName)
    self.listView:removeAllItems()
    self:setCtrlVisible("SkillIllustratePanel", false)
    if nil == pet then return end
    -- 获取宠物的类型
    local petRank = pet:queryInt('rank')

    -- 获取技能
    local inateSkill = PetMgr:petHaveRawSkill(pet:queryBasic("raw_name")) or {}
    local hasInnateSkill = SkillMgr:getPetRawSkillNoAndLadder(pet:getId()) or {}
    local inateSkillCount = #inateSkill
    local hasInnateSkillCount = #hasInnateSkill

    -- 在技能列表框 中设置技能图标
    local i = 0
    local index = 1
    local isDefault = false
    self:setCtrlVisible("SkillIllustratePanel", true)

    for j = 1, #INNATE_SKILLS do
        local skillName = false
        for k = 1, #inateSkill do
            if inateSkill[k] == INNATE_SKILLS[j] then
                skillName = inateSkill[k]
            end
        end

        if skillName then
            i = i + 1

            -- 获取技能图标
            local skill = SkillMgr:getskillAttribByName(skillName)
            local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
            if nil == skillIconPath then return end

            local item = self.cloneItem:clone()
            self:setImage("GuardImage", skillIconPath, item)
            self:setItemImageSize("GuardImage", item)
            self:setCtrlVisible("ChoseImage", false, item)

            if index % 2 == 0 then
                self:setCtrlVisible("Image_1", false, item)
                self:setCtrlVisible("Image_2", true, item)
            else
                self:setCtrlVisible("Image_1", true, item)
                self:setCtrlVisible("Image_2", false, item)
            end

            index = index + 1

            -- 判断宠物是否已经拥有这个技能
            local isHas = false;
            for j = 1, hasInnateSkillCount do
                if skill.skill_no == hasInnateSkill[j].no then
                    -- 标志已经拥有
                    isHas = true
                end
            end

            -- 如果宠物未拥有这个技能
            if not isHas then
                -- 进行图标置灰操作
                self:setCtrlEnabled("GuardImage", false, item)
                self:setLabelText("NameLabel", skillName, item)
                self:setLabelText("LevelLabel", 0, item)
                self:setLabelText("TargetValueLabel", 0, item)
                self:setLabelText("CostLabel", 0, item)
            else
                self:setCtrlEnabled("GuardImage", true, item)
                -- 进行设置等级
                self:setLabelText("NameLabel", skillName, item)
                local skillWithPet = SkillMgr:getSkill(pet:getId(), skill.skill_no)
                self:setLabelText("LevelLabel", skillWithPet.skill_level, item)
                self:setLabelText("TargetValueLabel", skillWithPet.range, item)
                self:setLabelText("CostLabel", skillWithPet.skill_mana_cost, item)

                if self:getSkillIsPromote(skillWithPet) then
                    self:setCtrlVisible("CanLevelImage", true, item)
                end
            end

            item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.curSkillName = skillName
                    self.curSkillNode = sender
                    self.curSkillNo = skill.skill_no
                    self:onItemTouch(sender, eventType)
                end
            end)

            self.listView:pushBackCustomItem(item)

            if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.INNATE then
                if self.curSkillName == skillName then
                    self.curSkillNo = skill.skill_no
                    self:onItemTouch(item, 2)
                    isDefault = true
                end
            else
                if i == 1 then
                    self.curSkillName = skillName
                    self.curSkillNode = item
                    self.curSkillNo = skill.skill_no
                    self:onItemTouch(item, 2)
                    isDefault = true
                end
            end

            if selectSkillName == skillName then
                self.curSkillNo = skill.skill_no
                self:onItemTouch(item, 2)
                isDefault = true
            end
        end
    end

    if not isDefault then
        -- 没有默认选中的话
        local item = self.listView:getItem(0)
        if item then
            local textLabel = item:getChildByName("NameLabel")

            if textLabel then
                local skillName = textLabel:getString()
                self.curSkillName = skillName
                local skill = SkillMgr:getskillAttribByName(skillName)
                self.curSkillNode = item
                self.curSkillNo = skill.skill_no
                self:onItemTouch(item, 2)
            else
                self:hideAllOperatePanel()
            end
        else
            self:setCtrlVisible("SkillIllustratePanel", false)
        end
    end
end

-- 设置宠物的研发技能
function PetSkillDlg:setDevelopSkill(pet, selectSkillName)
    self.listView:removeAllItems()
    self:setCtrlVisible("SkillIllustratePanel", false)

    -- 获取当前选择的宠物
    if pet == nil then return end

    -- 获取 研发技能
    local skillsName = PetMgr:getDevelopSkillList()
    local normalSkills = {}
    for i = 1, #skillsName do
        table.insert(normalSkills, SkillMgr:getskillAttribByName(skillsName[i]))
    end

    if nil == normalSkills then return end

    -- 获取宠物已经拥有的技能
    local petSkills = SkillMgr:getSkillNoAndLadder(pet:getId(), SKILL.SUBCLASS_E, SKILL.CLASS_PET)
    local normalSkillsCount = #normalSkills
    local petSkillsCount = 0
    if nil ~= petSkills then
        petSkillsCount = #petSkills
    end

    -- 在技能列表框 中设置技能图标
    local index = 1
    local isDefault = false
    self:setCtrlVisible("SkillIllustratePanel", true)
    for i = 1, normalSkillsCount do

        -- 获取技能图标
        local skillIconPath = SkillMgr:getSkillIconPath(normalSkills[i].skill_no)
        if nil == skillIconPath then return end

        local item = self.cloneItem:clone()
        self:setImage("GuardImage", skillIconPath, item)
        self:setItemImageSize("GuardImage", item)
        self:setLabelText("NameLabel", normalSkills[i].name, item)
        self:setCtrlVisible("ChoseImage", false, item)

        if index % 2 == 0 then
            self:setCtrlVisible("Image_1", false, item)
            self:setCtrlVisible("Image_2", true, item)
        else
            self:setCtrlVisible("Image_1", true, item)
            self:setCtrlVisible("Image_2", false, item)
        end

        index = index + 1

        -- 判断宠物是否已经拥有这个技能
        local isHas = false;
        for j = 1, petSkillsCount do
            if normalSkills[i].skill_no == petSkills[j].no then
                -- 标志已经拥有
                isHas = true
            end
        end

        if isHas then
            self:setCtrlEnabled("GuardImage", true, item)
            local skillWithPet = SkillMgr:getSkill(pet:getId(), normalSkills[i].skill_no)
            self:setLabelText("LevelLabel", skillWithPet.skill_level, item)
            self:setLabelText("TargetValueLabel", skillWithPet.range, item)
            self:setLabelText("CostLabel", skillWithPet.skill_mana_cost, item)
            if self:getSkillIsPromote(skillWithPet, YANFA_UPLEVEL_NEED_INTIMACY) then
                self:setCtrlVisible("CanLevelImage", true, item)
            end
        else
            self:setCtrlEnabled("GuardImage", false, item)
            self:setLabelText("LevelLabel", 0, item)
            self:setLabelText("TargetValueLabel", 0, item)
            self:setLabelText("CostLabel", 0, item)
        end

        item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.curSkillName = normalSkills[i].name
                self.curSkillNode = sender
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(sender, eventType)
            end
        end)

        self.listView:pushBackCustomItem(item)

        if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.STUDY then
            if self.curSkillName == normalSkills[i].name then
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(item, 2)
                isDefault = true
            end
        else
            if i == 1 then
                self.curSkillName = normalSkills[i].name
                self.curSkillNode = item
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(item, 2)
                isDefault = true
            end
        end

        if selectSkillName == normalSkills[i].name then
            self.curSkillNo = normalSkills[i].skill_no
            self:onItemTouch(item, 2)
            isDefault = true
        end
    end

    if not isDefault then
        -- 没有默认选中的话
        local item = self.listView:getItem(0)
        if item then
            local textLabel = item:getChildByName("NameLabel")

            if textLabel then
                local skillName = textLabel:getString()
                self.curSkillName = skillName
                local skill = SkillMgr:getskillAttribByName(skillName)
                self.curSkillNode = item
                self.curSkillNo = skill.skill_no
                self:onItemTouch(item, 2)
            else
                self:hideAllOperatePanel()
            end
        else
            self:setCtrlVisible("SkillIllustratePanel", false)
        end
    end

end

-- 设置宠物的顿悟技能
function PetSkillDlg:setDunWuSkill(pet)
    self.listView:removeAllItems()
    if nil == pet then return end
    -- 获取宠物的类型
    local petRank = pet:queryInt('rank')

    -- 获取顿悟技能，一般宠物最多可以有一个顿悟技能，变异，神兽宠物最多有两个
    local dunWuSkills = SkillMgr:getPetDunWuSkills(pet:getId()) or {}
    local dunWuSkillCount = #dunWuSkills

    local dunWuSkillNameList = {}
    if petRank == Const.PET_RANK_ELITE or petRank == Const.PET_RANK_EPIC then
        table.insert(dunWuSkillNameList, dunWuSkills[1] or "")
        table.insert(dunWuSkillNameList, dunWuSkills[2] or "")
    else
        table.insert(dunWuSkillNameList, dunWuSkills[1] or "")
    end

    -- 在技能列表框 中设置技能图标
    local index = 1

    for i = 1, #dunWuSkillNameList do
        local skillName = dunWuSkillNameList[i]
        local item = self.cloneItem:clone()

        if index % 2 == 0 then
            self:setCtrlVisible("Image_1", false, item)
            self:setCtrlVisible("Image_2", true, item)
        else
            self:setCtrlVisible("Image_1", true, item)
            self:setCtrlVisible("Image_2", false, item)
        end
        index = index + 1

        if skillName and skillName ~= "" then
            -- 获取技能图标
            local skill = SkillMgr:getskillAttribByName(skillName)
            local skillIconPath = SkillMgr:getSkillIconPath(skill.skill_no)
            if nil == skillIconPath then return end
            self:setImage("GuardImage", skillIconPath, item)
            self:setItemImageSize("GuardImage", item)
            self:setCtrlVisible("ChoseImage", false, item)

            -- 设置名称、等级
            local skillWithPet = SkillMgr:getSkill(pet:getId(), skill.skill_no)

            -- 若顿悟技能未启用，则技能图标置灰
            local skillDisabled = skillWithPet.skill_disabled
            self:setCtrlEnabled("GuardImage", (skillDisabled == 0), item)

            self:setLabelText("NameLabel", skillWithPet.skill_name, item)
            self:setLabelText("LevelLabel", skillWithPet.skill_level, item)

            -- 顿悟技能消耗
            local skillCostStr
            if SkillMgr:getPetSkillType(skillName) == SkillMgr.PET_SKILL_TYPE.JINJIE then
                skillCostStr = string.format(CHS[7000247], Formula:getCostAnger(skillWithPet.skill_level))
            else
                skillCostStr = string.format(CHS[7000246], skillWithPet.skill_mana_cost)
            end
            self:setCtrlVisible("CostLabel_2", true, item)
            self:setLabelText("CostLabel_2", skillCostStr, item)

            -- 是否可升级
            local isPromote = false
            if SkillMgr:getPetSkillType(skillName) ~= SkillMgr.PET_SKILL_TYPE.JINJIE then
                isPromote = self:getSkillIsPromote(skillWithPet)
            else
                isPromote = self:getJinjieSkillIsPromote(skillWithPet)
            end
            self:setCtrlVisible("CanLevelImage", isPromote, item)

            item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.curSkillName = skillName
                    self.curSkillNode = sender
                    self.curSkillNo = skill.skill_no
                    self:onDunWuSkillTouch(sender, eventType)
                end
            end)

            if self.curSkillName
                and skillName == self.curSkillName
                and SkillMgr:isPetDunWuSkill(pet:getId(), self.curSkillName) then
               -- 之前选择的是此项
               self.curSkillNode = item
               self:onDunWuSkillTouch(item, 2)
            end
        elseif skillName and skillName == "" then
            -- 如果没有顿悟技能，则给出提示文字，并使技能栏可点击进入顿悟界面

            -- 技能图标显示为+
            self:setCtrlVisible("AddPanel", true, item)

            -- 提示文字显示
            self:setCtrlVisible("DunwuLabel", true, item)

            item:addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    self.curSkillName = nil
                    self.curSkillNode = sender
                    self.curSkillNo = nil

                    self:onDunWuSkillTouch(sender, eventType)
                    local dlg = DlgMgr:openDlg("PetDunWuDlg")
                    dlg:setInfo(self.pet)
                end
            end)

            self:getControl("AddPanel", nil, item):addTouchEventListener(function(sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    local dlg = DlgMgr:openDlg("PetDunWuDlg")
                    dlg:setInfo(self.pet)
                end
            end)
        end

        self.listView:pushBackCustomItem(item)
    end

    -- 如果之前没有选择项，则默认选择第一项
    if not self.curSkillName or not SkillMgr:isPetDunWuSkill(pet:getId(), self.curSkillName) then
        local item = self.listView:getItem(0)
        if item then
            local textLabel = item:getChildByName("NameLabel")
            local skillName = textLabel:getString()
            if skillName ~= "" then
                self.curSkillName = skillName
                local skill = SkillMgr:getskillAttribByName(skillName)
                self.curSkillNode = item
                self.curSkillNo = skill.skill_no
                self:onDunWuSkillTouch(item, 2)
            else
                self.curSkillName = nil
                self.curSkillNode = item
                self.curSkillNo = nil
                self:onDunWuSkillTouch(item, 2)
            end
        end
    end
end

-- 设置宠物的天书技能
function PetSkillDlg:setGodBookSkill(pet)
    self.listView:removeAllItems()
    self:setCtrlVisible("SkillIllustratePanel", false)
    -- 获取当前选择的宠物
    if pet == nil then return end
    local node = nil
    -- 获取 天书技能
    -- 首先获取天书技能个数
    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    local skills = {}

    for i = 1, godBookCount do

        -- 获取天书技能的各个属性
        local nameKey = 'god_book_skill_name_' .. i
        local levelKey = 'god_book_skill_level_' .. i
        local powerKey = 'god_book_skill_power_' .. i
        local disableKey = 'god_book_skill_disabled_' .. i
        local name = pet:queryBasic(nameKey)
        local level = pet:queryBasic(levelKey)
        local power = pet:queryBasic(powerKey)
        local disabled = pet:queryBasicInt(disableKey)
        table.insert(skills, {name = name, level = level, power = power, disabled = disabled})
    end

    local normalSkills = {}
    local linQiPower = {}
    local skillDisabled = {}
    for i = 1, #skills do
        table.insert(normalSkills, SkillMgr:getskillAttribByName(skills[i].name))
        table.insert(linQiPower, skills[i].power)
        table.insert(skillDisabled, skills[i].disabled)
    end

    local normalSkillsCount = #normalSkills
    local skillLevel = math.floor(pet:queryInt("level") * 1.6)
    local index = 1
    local isDefault = false
    self:setCtrlVisible("SkillIllustratePanel", true)

    -- 在技能列表框 中设置技能图标
    for i = 1, normalSkillsCount do

        -- 获取技能图标
        local skillIconPath = SkillMgr:getSkillIconPath(normalSkills[i].skill_no)
        if nil == skillIconPath then return end

        local item = self.cloneItem:clone()
        self:setCtrlVisible("ChoseImage", false, item)
        if index % 2 == 0 then
            self:setCtrlVisible("Image_1", false, item)
            self:setCtrlVisible("Image_2", true, item)
        else
            self:setCtrlVisible("Image_1", true, item)
            self:setCtrlVisible("Image_2", false, item)
        end

        index = index + 1
        self:setImage("GuardImage", skillIconPath, item)
        self:setItemImageSize("GuardImage", item)

        -- 当前天书技能未启用，则技能图标置灰
        self:setCtrlEnabled("GuardImage", (skillDisabled[i] and (skillDisabled[i] == 0)), item)

        self:setLabelText("NameLabel", normalSkills[i].name, item)
        self:setLabelText("LevelLabel", skillLevel, item)
        --self:setLabelText("TargetValueLabel", linQiPower[i], item)
        self:setLabelText("GodBookLabel", linQiPower[i], item)
        self:setLabelText("CostLabel", "", item)
        self.listView:pushBackCustomItem(item)

        item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self.curSkillName = normalSkills[i].name
                self.curSkillNode = sender
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(sender, eventType)
            end
        end)

        if SkillMgr:getPetSkillType(self.curSkillName) == SkillMgr.PET_SKILL_TYPE.GODBOOK then
            if self.curSkillName == normalSkills[i].name then
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(item, 2)
                isDefault = true
            end
        else
            if i == 1 then
                self.curSkillName = normalSkills[i].name
                self.curSkillNode = item
                self.curSkillNo = normalSkills[i].skill_no
                self:onItemTouch(item, 2)
                isDefault = true
            end
        end
    end

    if not isDefault then
        -- 没有默认选中的话
        local item = self.listView:getItem(0)
        if item then
            local textLabel = item:getChildByName("NameLabel")

            if textLabel then
                local skillName = textLabel:getString()
                self.curSkillName = skillName
                local skill = SkillMgr:getskillAttribByName(skillName)
                self.curSkillNode = item
                self.curSkillNo = skill.skill_no
                self:onItemTouch(item, 2)
            else
                self:hideAllOperatePanel()
            end
        else
            self:setCtrlVisible("SkillIllustratePanel", false)
        end
    end


    local isWild = (pet:queryInt('rank') == Const.PET_RANK_WILD)

    if normalSkillsCount < 3 then
        local item = self.cloneItem:clone()
        if index % 2 == 0 then
            self:setCtrlVisible("Image_1", false, item)
            self:setCtrlVisible("Image_2", true, item)
        else
            self:setCtrlVisible("Image_1", true, item)
            self:setCtrlVisible("Image_2", false, item)
        end
        self:setCtrlVisible("ChoseImage", false, item)
        self:setLabelText("NameLabel", "", item)
        self:setLabelText("LevelLabel", "", item)
        self:setLabelText("TargetValueLabel", "", item)
        self:setLabelText("CostLabel", "", item)
        self.listView:pushBackCustomItem(item)

        local addPanel = self:getControl("AddPanel", nil, item)
        addPanel:setTouchEnabled(false)
        addPanel:setVisible(true)
        item:addTouchEventListener(function(sender, eventType)
            -- todo
            if eventType == ccui.TouchEventType.ended then
                self:onTouchEmptySkill(sender, eventType)
            end
        end)

        if self.listView:getIndex(item) == 0 then
            self:onTouchEmptySkill(item, 2, true)
        end
    end
end

function PetSkillDlg:onTouchEmptySkill(sender, eventType, isNotShowSubmitDlg)
    self:clearSelectEffect()
    self:setCtrlVisible("ChoseImage", true, sender)

    local skillDescr = SkillMgr:getSkillDesc(self.curSkillName)
    self:setLabelText("DescrLabel", "", "SkillIllustratePanel")
    self:hideAllOperatePanel()
    self:setCtrlVisible("BookScreenPanel_1", true)
    local isWild = (self.pet:queryInt('rank') == Const.PET_RANK_WILD)

    self:setCtrlVisible("CostPanel", false, "BookScreenPanel_1")
    self:setCtrlVisible("UseSkillPanel", false, "BookScreenPanel_1")
    self:setCtrlEnabled("OutButton", false, "BookScreenPanel_1")
    self:setCtrlEnabled("AddButton", false, "BookScreenPanel_1")
    if not isNotShowSubmitDlg then
        if isWild then
            gf:ShowSmallTips('#Y' .. self.pet:queryBasic('name') .. CHS[3003443])
            return
        end
        local dlg = DlgMgr:openDlg("SubmitGodBookDlg")
        dlg:setPetId(self.pet:getId())
        dlg:intSubmitInfo()
    end
end

-- 置空技能栏图标
function PetSkillDlg:cleanupAllSkill()

    -- 将技能图标标志为未显示
    local skillImage = {"MagicSkillImage_",
        "InnateSkillImage_",
        "DevelopSkillImage_",
        "GodbookSkillImage_"}
    local skillLevel = {"MagicSkillLevelLabel_",
        "InnateSkillLevelLabel_",
        "DevelopSkillLevelLabel_",
        "GodbookSkillLevelLabel_"}
    local chooseImg = {"MagicChosenImage_",
        "InnateChosenImage_",
        "DevelopChosenImage_",
        "GodbookChosenImage_"}

    local skillPanels = {"DevelopSkillPanel_",
    "InnateSkillPanel_",
    "MagicSkillPanel_",
    "GodbookSkillPanel_",}


    for j = 1, #skillImage do
        for i = 1, DEFAULT_SKILL_NUM do

            -- 重置图标
            local magicSkillImgStr = skillImage[j] .. i
            local imgViewCtrl = self:getControl(magicSkillImgStr, Const.UIImage)

            if imgViewCtrl then
                self:setCtrlEnabled(magicSkillImgStr, false)
                self:setImage(magicSkillImgStr, ResMgr.ui["pet_skill_list_none"])
                self:setCtrlVisible(magicSkillImgStr, false)

                -- 重置技能等级
                local color  = imgViewCtrl:setColor(cc.c4b(255, 255, 255, 255))
            end

            local skillLevelStr = skillLevel[j] .. i
            self:setLabelText(skillLevelStr, "")
            self:setCtrlVisible(chooseImg[j] .. i, false)
        end
    end

    for _, v in pairs(skillPanels) do
        if v ~= "GodbookSkillPanel_" then
            for i = 1, DEFAULT_SKILL_NUM do
                local skillPanel = self:getControl(v .. i, Const.UIPanel)

                if skillPanel then
                    skillPanel:setVisible(false)
                end

            end
        end
    end

    -- 移除panel美术字
    for _, v in pairs(skillPanels) do
        for i = 1, DEFAULT_SKILL_NUM do
            self:cleanArtFont(v .. i)
        end
    end
end

-- 宠物的物攻技能弹出框
function PetSkillDlg:onPetPhySkillDetil(sender, eventType)

    -- 邊框控制
    if not self:controlSmallDlg() then
        return
    end

    if nil == sender then return end

    self:showChosenImg('MagicChosenImage_1')

    local skillCard = DlgMgr:openDlg("SkillFloatingFrameDlg")

    if skillCard then
        local rect = sender:getBoundingBox()
        local pt = sender:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        skillCard:setInfo(CHS[3003430], 0, false, rect, 1)
    end

    self:onSelectSkill("normalSkill", sender)
end

-- 宠物的法攻技能弹出框
function PetSkillDlg:onPetMagicSkillDetil(sender, eventType)

    -- 邊框控制
    if not self:controlSmallDlg() then
        return
    end

    if nil == sender then return end


    local tag = sender:getTag()
    local skillNo = tag % IDX_POWER
    local skillName = SkillMgr:getSkillName(skillNo)
    local skillDis = SkillMgr:getSkillDesc(skillName)

    local skillCard = DlgMgr:openDlg("SkillFloatingFrameDlg")

    if skillCard then
        local rect = sender:getBoundingBox()
        local pt = sender:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE
        local pet = DlgMgr:sendMsg("PetListChildDlg", "getCurrentPet")
        skillCard:setInfo(skillName, pet:queryBasicInt("id"), false, rect)
    end

    local idx = math.floor(tag / IDX_POWER + 0.5)
    self:showChosenImg('MagicChosenImage_' .. idx)

    self:onSelectSkill("normalSkill", sender)
end

function PetSkillDlg:getSkillIsPromote(skillWithPet, intimacyLimit)
    local skillNo = skillWithPet.skill_no
    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), skillNo)
    local skillName = skillWithPet.skill_name
    if skillWithPet then
        local costCash = skillWithPet.cost_cash or 0
        local costContrib = skillWithPet["cost_party/contrib"] or 0

        local meCash = Me:queryInt("cash") or 0
        local meContrib = Me:queryInt("party/contrib") or 0
        local intimacy = self.pet:queryInt("origin_intimacy") or 0
        intimacyLimit = intimacyLimit or UPLEVEL_NEED_INTIMACY
        if meCash >= costCash
                and meContrib >= costContrib and PartyMgr.partyInfo
                and intimacy >= intimacyLimit
                and skillWithPet.skill_level < PartyMgr:getPartySkill(skillName).level
                and skillWithPet.skill_level < math.floor(self.pet:queryInt("level") * 1.6) then
            return true
        end
    end

    return false
end

function PetSkillDlg:getJinjieSkillIsPromote(skillWithPet)
    local skillNo = skillWithPet.skill_no
    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), skillNo)
    local skillName = skillWithPet.skill_name
    if skillWithPet then
        local costCash = skillWithPet.cost_cash or 0
        local costPot = skillWithPet["cost_pot"] or 0

        local meCash = Me:queryInt("cash") or 0
        local mePot = Me:queryInt("pot") or 0
        local intimacy = self.pet:queryInt("origin_intimacy") or 0
        if meCash >= costCash and mePot >= costPot
                and intimacy >= UPLEVEL_NEED_INTIMACY
                and skillWithPet.skill_level < JINJIE_SKILL_MAX_LEVEL
                and skillWithPet.skill_level < math.floor(self.pet:queryInt("level") * 1.6) then
            return true
        end
    end
    return false
end

function PetSkillDlg:showLevelUpInnateSkill(sender, eventType)

    if not self.curSkillNo then return end

    local skillNo = self.curSkillNo
    local pet = self.pet
    local skillWithPet = SkillMgr:getSkill(pet:getId(), skillNo)
    local skillName = SkillMgr:getSkillName(skillNo)

    self.skillNo = skillNo
    self.skillName = skillName

    if skillWithPet then
        -- 获取帮贡跟金钱信息
        local skillPanel = self:getControl("UpRawSkillPanel", Const.UIPanel)
        local costCash = skillWithPet.cost_cash or 0
        local costContrib = skillWithPet["cost_party/contrib"] or 0

        local meCash = Me:queryInt("cash") or 0
        local meContrib = Me:queryInt("party/contrib") or 0

        -- 金币格式
        local meCashText, meCashColor = gf:getArtFontMoneyDesc(meCash)
        local costCashText, costCashColor = gf:getArtFontMoneyDesc(costCash)
        self:hideAllOperatePanel()
        self:setCtrlVisible("BornScreenPanel_2", true)
        self:setCtrlVisible("LevelDownButton", true, "BornScreenPanel_2")
        local fontColor = ART_FONT_COLOR.NORMAL_TEXT

        self:setNumImgForPanel("NowMoneyPanel", meCashColor, meCashText, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")

        if meContrib < costContrib then
            fontColor = ART_FONT_COLOR.RED
        else
            fontColor = ART_FONT_COLOR.NORMAL_TEXT
        end
        self:setNumImgForPanel("NowContributePanel", fontColor, meContrib, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        self:setNumImgForPanel("UseMoneyPanel", costCashColor, costCashText, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        self:setNumImgForPanel("UseContributePanel", ART_FONT_COLOR.NORMAL_TEXT, costContrib, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        self:updateLayout("BornScreenPanel_2")
        self:updateLayout("CostPanel", "BornScreenPanel_2")
    else
        -- 获取技能秘籍
        self:hideAllOperatePanel()
        self:setCtrlVisible("BornScreenPanel_1", true)

        local skillBookName = skillName..CHS[3000087]
        local skillBookIcon = InventoryMgr:getIconFileByName(skillBookName)
        local skillBookCount = InventoryMgr:getAmountByNameIsForeverBind(skillBookName, self:isCheck("BindCheckBox"))
        self:setImage("CostImage", skillBookIcon, "BornScreenPanel_1")
        self:setItemImageSize("CostImage", "BornScreenPanel_1")
        self:setLabelText("BookNameLabel", skillBookName, "BornScreenPanel_1")

        if 0 == skillBookCount then
            self:setLabelText("CostLabel", "0", "BornScreenPanel_1", COLOR3.RED)
        elseif 999 < skillBookCount then
            self:setLabelText("CostLabel", "*", "BornScreenPanel_1", COLOR3.TEXT_DEFAULT)
        elseif 999 >= skillBookCount then
            self:setLabelText("CostLabel", skillBookCount, "BornScreenPanel_1", COLOR3.TEXT_DEFAULT)
        end
        self:updateLayout("BornScreenPanel_1")
        self:updateLayout("CostPanel", "BornScreenPanel_1")
    end
end

function PetSkillDlg:hideAllOperatePanel()
    self:setCtrlVisible("BornScreenPanel_1", false)
    self:setCtrlVisible("BornScreenPanel_2", false)
    self:setCtrlVisible("BookScreenPanel_1", false)
    self:setCtrlVisible("MadeScreenPanel_1", false)
    self:setCtrlVisible("MadeScreenPanel_2", false)
end

-- 宠物的研发技能弹出框
function PetSkillDlg:showLevelUpDevelopSkill(sender, eventType)

    -- 邊框控制
    if not self:controlSmallDlg() then return end

    if nil == sender then return end

    local skillNo = self.curSkillNo
    local pet = self.pet
    local skillWithPet = SkillMgr:getSkill(pet:getId(), skillNo)
    local skillName = SkillMgr:getSkillName(skillNo)

    if skillWithPet then
        -- 获取帮贡跟金钱信息
        local costCash = skillWithPet.cost_cash or 0
        local costContrib = skillWithPet["cost_party/contrib"] or 0

        local meCash = Me:queryInt("cash") or 0
        local meContrib = Me:queryInt("party/contrib") or 0
        self:hideAllOperatePanel()
        self:setCtrlVisible("MadeScreenPanel_1", true)
        local meCashText, meCashColor = gf:getArtFontMoneyDesc(meCash)
        local costCashText, costCashColor = gf:getArtFontMoneyDesc(costCash)
        local fontColor = ART_FONT_COLOR.NORMAL_TEXT

        self:setNumImgForPanel("NowMoneyPanel", meCashColor, meCashText, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_1")

        if meContrib < costContrib then
            fontColor = ART_FONT_COLOR.RED
        else
            fontColor = ART_FONT_COLOR.NORMAL_TEXT
        end
        self:setNumImgForPanel("NowContributePanel", fontColor, meContrib, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_1")

        self:setNumImgForPanel("UseMoneyPanel", costCashColor, costCashText, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_1")
        self:setNumImgForPanel("UseContributePanel", ART_FONT_COLOR.NORMAL_TEXT, costContrib, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_1")
        self:updateLayout("MadeScreenPanel_2")
        self:updateLayout("CostPanel", "MadeScreenPanel_1")

    else
        local costCash = MIN_CASH_COST
        local costContrib = 0
        local meCash = Me:queryInt("cash") or 0
        local meContrib = Me:queryInt("party/contrib") or 0

        self:hideAllOperatePanel()
        self:setCtrlVisible("MadeScreenPanel_2", true)
        local meCashText, meCashColor = gf:getArtFontMoneyDesc(meCash)
        local costCashText, costCashColor = gf:getArtFontMoneyDesc(costCash)
        local fontColor = ART_FONT_COLOR.NORMAL_TEXT

        self:setNumImgForPanel("NowMoneyPanel", meCashColor, meCashText, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_2")

        if meContrib < costContrib then
            fontColor = ART_FONT_COLOR.RED
        else
            fontColor = ART_FONT_COLOR.NORMAL_TEXT
        end
        self:setNumImgForPanel("NowContributePanel", fontColor, meContrib, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_2")

        self:setNumImgForPanel("UseMoneyPanel", costCashColor, costCashText, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_2")
        self:setNumImgForPanel("UseContributePanel", ART_FONT_COLOR.NORMAL_TEXT, costContrib, false, LOCATE_POSITION.CENTER, 21, "MadeScreenPanel_2")
        self:updateLayout("MadeScreenPanel_2")
        self:updateLayout("CostPanel", "MadeScreenPanel_2")
    end

end

function PetSkillDlg:showLevelUpGodbookSkill(sender, eventType)
    -- 邊框控制
    if not self:controlSmallDlg() then return end

    if nil == sender then return end

    local skillNo = self.curSkillNo
    local skillInfo = SkillMgr:getSkill(self.pet:queryBasicInt("id"), skillNo)

    local skillWithPet = SkillMgr:getSkill(self.pet:getId(), skillNo)
    local skillName = SkillMgr:getSkillName(skillNo)
    SkillMgr.selectGodbookSkillName = skillName

    -- 获取相应天书技能的等级 和 灵气
    local godBookCount = self.pet:queryBasicInt('god_book_skill_count')
    local skill = {}

    local isIn = false

    for i = 1, godBookCount do
        -- 获取当前天书技能的各个属性
        local nameKey = 'god_book_skill_name_' .. i
        local name = self.pet:queryBasic(nameKey)
        local skillAttr = SkillMgr:getskillAttribByName(name)
        if skillNo == skillAttr.skill_no then
            local levelKey = 'god_book_skill_level_' .. i
            local powerKey = 'god_book_skill_power_' .. i
            local disableKey = 'god_book_skill_disabled_' .. i
            local level = self.pet:queryBasic(levelKey)
            local power = self.pet:queryBasicInt(powerKey)
            local disabled = self.pet:queryBasicInt(disableKey)
            skill = {name = name, level = level, power = power, disabled = disabled}
            isIn = true
            break
        end
    end

    local skillDesc = SkillMgr:getSkillDesc(self.curSkillName)
    self:setColorText(skillDesc.desc or skillDesc.pet_desc, "DescrPanel", "SkillIllustratePanel", nil, nil, nil, 19)
    local listView = self:getControl("DescrListView", Const.UIListView, "SkillIllustratePanel")
    listView:requestRefreshView()

    self:hideAllOperatePanel()
    self:setCtrlVisible("BookScreenPanel_1", true)

    self:setCtrlVisible("CostPanel", true, "BookScreenPanel_1")
    self:setCtrlVisible("UseSkillPanel", true, "BookScreenPanel_1")
    self:setCtrlEnabled("OutButton", true, "BookScreenPanel_1")
    self:setCtrlEnabled("AddButton", true, "BookScreenPanel_1")

    if godBookCount > 0 and skill.power then
        local skillPath = SkillMgr:getSkillIconPath(skillNo)
        self:setImage("CostImage", skillPath, "BookScreenPanel_1")
        self:setItemImageSize("CostImage", "BookScreenPanel_1")

        if 0 == skill.power then
            self:setLabelText("ResidueLabel_2", skill.power .. "/30000", "BookScreenPanel_1", COLOR3.RED)
        else
            self:setLabelText("ResidueLabel_2", skill.power .. "/30000", "BookScreenPanel_1", COLOR3.TEXT_DEFAULT)
        end

        -- 当前天书是否可用
        self:setCheck("ChoseCheckBox", (skill.disabled == 0), "BookScreenPanel_1")

        self:updateLayout("CostPanel", "BookScreenPanel_1")
    end

end

function PetSkillDlg:showLevelUpDunWuSkill(sender, eventType)
    if not self.curSkillNo then return end

    local skillNo = self.curSkillNo
    local skillName = self.curSkillName
    local pet = self.pet
    local skillWithPet = SkillMgr:getSkill(pet:getId(), skillNo)

    if skillWithPet then
        -- 获取帮贡、金钱、潜能信息
        local costCash = skillWithPet.cost_cash or 0
        local costContrib = skillWithPet["cost_party/contrib"] or 0
        local costPot = skillWithPet["cost_pot"] or 0
        local meCash = Me:queryInt("cash") or 0
        local meContrib = Me:queryInt("party/contrib") or 0
        local mePot = Me:queryInt("pot") or 0

        -- 拥有金钱与消耗金钱
        local meCashText, meCashColor = gf:getArtFontMoneyDesc(meCash)
        local costCashText, costCashColor = gf:getArtFontMoneyDesc(costCash)

        self:setNumImgForPanel("NowMoneyPanel", meCashColor, meCashText, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        self:setNumImgForPanel("UseMoneyPanel", costCashColor, costCashText, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")

        if SkillMgr:getPetSkillType(skillName) ~= SkillMgr.PET_SKILL_TYPE.JINJIE then  -- 非进阶顿悟技能
            self:setCtrlVisible("Image_204", true, "BornScreenPanel_2")
            self:setCtrlVisible("Image_206", true, "BornScreenPanel_2")
            self:setCtrlVisible("Image_207", false, "BornScreenPanel_2")
            self:setCtrlVisible("Image_208", false, "BornScreenPanel_2")
            self:setCtrlVisible("LevelDownButton", true, "BornScreenPanel_2")

            -- 拥有帮贡与消耗帮贡
            local meContribColor = ART_FONT_COLOR.NORMAL_TEXT
            local costContribColor = ART_FONT_COLOR.NORMAL_TEXT
            if meContrib < costContrib then
                meContribColor = ART_FONT_COLOR.RED
            end

            self:setNumImgForPanel("NowContributePanel", meContribColor, meContrib, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
            self:setNumImgForPanel("UseContributePanel", costContribColor, costContrib, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        else  -- 进阶顿悟技能
            self:setCtrlVisible("Image_204", false, "BornScreenPanel_2")
            self:setCtrlVisible("Image_206", false, "BornScreenPanel_2")
            self:setCtrlVisible("Image_207", true, "BornScreenPanel_2")
            self:setCtrlVisible("Image_208", true, "BornScreenPanel_2")
            self:setCtrlVisible("LevelDownButton", false, "BornScreenPanel_2")

            -- 拥有潜能与消耗潜能
            local mePotColor = ART_FONT_COLOR.NORMAL_TEXT
            local costPotColor = ART_FONT_COLOR.NORMAL_TEXT
            if mePot < costPot then
                mePotColor = ART_FONT_COLOR.RED
            end

            self:setNumImgForPanel("NowContributePanel", mePotColor, mePot, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
            self:setNumImgForPanel("UseContributePanel", costPotColor, costPot, false, LOCATE_POSITION.CENTER, 21, "BornScreenPanel_2")
        end
    end
end

function PetSkillDlg:MSG_REFRESH_PET_GODBOOK_SKILLS(data)

    self:showSkill(self.curPanelName)
end

function PetSkillDlg:MSG_UPDATE_SKILLS(data)
    SkillMgr.selectGodbookSkillName = nil
    self:showSkill(self.curPanelName)
    self:updateFastUsePanel()
end

function PetSkillDlg:MSG_DUNWU_SKILL(data)
    self:showSkill(self.curPanelName)
end

function PetSkillDlg:MSG_UPDATE(data)

end

function PetSkillDlg:MSG_UPDATE_PETS(data)
    if not self.pet then
        return
    end
    self:updateFastUsePanel()
end

function PetSkillDlg:MSG_INVENTORY(data)
    if not self.pet then
        return
    end

    self:updateFastUsePanel()
end

-- 宠物的天书技能学习框
function PetSkillDlg:onPetStudyGodBookSkill(sender, eventType)
    if self.pet and self.pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips('#Y' .. self.pet:queryBasic('name') .. CHS[3003443])
        return
    end

    -- 邊框控制
    if not self:controlSmallDlg() then return end

    -- 隐藏连花姑娘
    self:setCtrlVisible("ShowPanel", false, self.root)

    local pet = self.pet
    local points = {}
    points[1] = pet:queryInt("str")
    points[2] = pet:queryInt("wiz")
    points[3] = pet:queryInt("con")
    points[4] = pet:queryInt("dex")

    -- 找到最大的属性
    local suggestSkill = 1
    for i = 1, 4 do
        if points[suggestSkill] < points[i] then
            suggestSkill = i
        end
    end

    table.sort(points, function(l, r) return l > r end)

    if points[1] == points[2] then
        suggestSkill = 5
    end

    local tag = sender:getTag()
    local idx = math.floor(tag / IDX_POWER + 0.5)
    self:showChosenImg('GodbookChosenImage_' .. idx)
    local dlg = DlgMgr:openDlg("SubmitGodBookDlg")
    dlg:setPetId(self.pet:getId())
    dlg:intSubmitInfo()
    self:onSelectSkill("godbookSkill", sender)
    self:updateCost("")
end

-- 显示消耗面板
function PetSkillDlg:updateCost(costPanelName)
    self:setCtrlVisible(costPanelName, true)
    self:updateLayout(costPanelName)
end

-- 保存当前选择的节点
function PetSkillDlg:onSelectSkill(skillNodeType, sender)
    for k, v in pairs(self.selectSkillNode) do
        self.selectSkillNode[k] = nil
    end

    self.selectSkillNode[skillNodeType] = sender
end

-- 清空技能图标中的美术字
function PetSkillDlg:cleanArtFont(panelName)
    local panel = self:getControl(panelName, Const.UIPanel)
    local levelPanel = self:getControl("LevelPanel", Const.UIPanel, panel)
    if panel and levelPanel then
        local numImg = levelPanel:getChildByTag(LOCATE_POSITION.LEFT_TOP * ART_FONT_TAG_FACTOR)

        if numImg then
            numImg:removeFromParent()
        end
    end

end

function PetSkillDlg:onButtonClose()
    Dialog.onCloseButton(self)
    self.cloneItem:release()
    self.cloneItem = nil
end

function PetSkillDlg:onCheckBox(sender, type)

	self:showSkill(self.curPanelName)

    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end
end

-- 打开界面需要某些参数需要重载这个函数
function PetSkillDlg:onDlgOpened(param)
    DlgMgr:sendMsg("PetListChildDlg", "initPetList","notWildFirst")
end

return PetSkillDlg
