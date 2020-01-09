-- HeadPlayerRuleDlg.lua
-- Created by lixh Mar/05/2018
-- 点击角色头像弹出的状态信息界面

local HeadPlayerRuleDlg = Singleton("HeadPlayerRuleDlg", Dialog)

function HeadPlayerRuleDlg:init(data)
    local personRulePanel = self:getControl("PersonRulePanel")
    self.personRuleOriSz = personRulePanel:getContentSize()
    _, self.personRuleOriPosY = personRulePanel:getPosition()
    self.innerPanelHeight = self:getCtrlContentSize("InnerPanel", "PersonRulePanel").height

    self:setPlayerInfo(data)
end

function HeadPlayerRuleDlg:setPlayerInfo(data)
    local exp, exp_to_next_level = 0, 0
    if Me:isRealBody() then
        exp, exp_to_next_level = Me:queryInt("exp"), Me:queryInt("exp_to_next_level")
    else
        exp, exp_to_next_level = Me:queryInt("upgrade/exp"), Me:queryInt("upgrade/exp_to_next_level")
    end    

    self:setLabelText("LifeLabel", string.format(CHS[2000006], data.curPlayerLife, Me:queryInt("max_life")), "PersonRulePanel")
    self:setLabelText("ManaLabel", string.format(CHS[2000007], data.curPlayerMana, Me:queryInt("max_mana")), "PersonRulePanel")
    self:setLabelText("ExpLabel", string.format(CHS[2000008], exp, exp_to_next_level, math.floor(100 * exp / exp_to_next_level)), "PersonRulePanel")
    local width = self.personRuleOriSz.width
    local numLength = string.len(tostring(exp) .. tostring(exp_to_next_level))
    if numLength >= 20 then
        -- 界面宽度需要放大0.15倍，不然ExpLabel的值会超出界面
        width = self.personRuleOriSz.width * 1.20
    elseif numLength >= 18 then
        -- 界面宽度需要放大0.15倍，不然ExpLabel的值会超出界面
        width = self.personRuleOriSz.width * 1.15
    elseif numLength >= 16 then
        -- 界面宽度需要放大0.1倍，不然ExpLabel的值会超出界面
        width = self.personRuleOriSz.width * 1.1
    end

    self:setLabelText("LifeReserveLabel", string.format(CHS[2000009], Me:queryInt("extra_life")), "PersonRulePanel")
    self:setLabelText("ManaReserveLabel", string.format(CHS[2000010], Me:queryInt("extra_mana")), "PersonRulePanel")
    self:setLabelText("LoyaltyReserveLabel", string.format(CHS[2000011], Me:queryInt("backup_loyalty")), "PersonRulePanel")

    local height = self.personRuleOriSz.height
    if InnerAlchemyMgr:isInnerAlchemyOpen(Me:queryInt("upgrade/level"), Me:queryInt("upgrade/type")) then
        self:setLabelText("StateLabel",  string.format(CHS[7150045], InnerAlchemyMgr:getAlchemyState(Me:queryBasicInt("dan_data/state")),
            InnerAlchemyMgr:getAlchemyStage(Me:queryBasicInt("dan_data/stage"))), "PersonRulePanel")
        local currentExp = InnerAlchemyMgr:getCurrentSpirit()
        local currentMaxExp = InnerAlchemyMgr:getCurrentMaxSpirit()
        local todayExp = InnerAlchemyMgr:getCurrentDaySpirit()
        local todayMaxExp = InnerAlchemyMgr:getCurrentDayMaxSpirit()
        self:setLabelText("InnerExpLabel", string.format(CHS[7150046], currentExp, currentMaxExp,  math.floor(currentExp * 100 / currentMaxExp)), "PersonRulePanel")
        self:setLabelText("LimitEXpLabel", string.format(CHS[7150047], todayMaxExp - todayExp), "PersonRulePanel")
        if InnerAlchemyMgr:isMaxStateAndStage() then
            -- 内丹达到最高境界后，策划要求 EXpLabel 不显示，且刷新界面高度
            self:setLabelText("InnerExpLabel", CHS[7150062], "PersonRulePanel")
            self:setCtrlVisible("LimitEXpLabel", false, "PersonRulePanel")
            height = self.personRuleOriSz.height - self:getCtrlContentSize("LimitEXpLabel", "PersonRulePanel").height
        else
            self:setCtrlVisible("LimitEXpLabel", true, "PersonRulePanel")
        end

        self:setCtrlVisible("InnerPanel", true)
    else
        self:setCtrlVisible("InnerPanel", false)
        height = self.personRuleOriSz.height - self.innerPanelHeight
    end

    self.root:setContentSize(width, height)
    self:setCtrlContentSize("PersonRulePanel", width, height)
    self:setCtrlContentSize("BackImage", width, height, "PersonRulePanel")
    local personRulePanel = self:getControl("PersonRulePanel")
    personRulePanel:setPositionY(self.personRuleOriPosY - (height - self.personRuleOriSz.height))

    local rect = data.node:getBoundingBox()
    local pt = data.node:convertToWorldSpace(cc.p(0, 0))
    self.root:setAnchorPoint(0, 0)
    self:setPosition(cc.p(pt.x - width + data.node:getContentSize().width + 5, pt.y - height))
end

return HeadPlayerRuleDlg
