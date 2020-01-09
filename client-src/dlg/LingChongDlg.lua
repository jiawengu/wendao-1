-- LingChongDlg.lua
-- Created by lixh Api/08/2018
-- 灵宠环境关卡界面

local LingChongDlg = Singleton("LingChongDlg", Dialog)

local LCHJ_STATE = LingChongHuanJingMgr:getHuanJingStateCfg()

function LingChongDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindFloatPanelListener("RulePanel")
    self:bindListener("EnterButton", self.onEnterButton)
end

-- 刷新界面关卡状态
function LingChongDlg:refreshDlgInfo(data)
    self.data = data

    self.state = nil
    local curIndex = LingChongHuanJingMgr:getCurStageIndex()
    for i = 1, data.count do
        local state = LCHJ_STATE.NOT_DO
        if i < curIndex then
            state = LCHJ_STATE.PASS
        elseif i == curIndex then
            state = data.list[i].state
            self.state = state
        end

        local cfg = LingChongHuanJingMgr:getHuanJingCfg(data.list[i].name)
        local panel = self:getControl("CheckPointPanel_" .. i, Const.UIPanel, "CheckPointPanel")
        self:setImage("PersonImage", cfg.icon, panel)
        self:setImage("NameImage_1", cfg.nameIcon, panel)
        local choseImagex, choseImagey = self:getControl("ChoseImage", nil, panel):getPosition()
        panel.choseImagex = choseImagex
        panel.choseImagey = choseImagey
        self:setTaskByState(state, panel, state == LCHJ_STATE.SELECT_NOT_DO or state == LCHJ_STATE.DOING)
    end

    -- 进入布阵 或 观战
    self:setLabelText("Label", self.state == LCHJ_STATE.DOING and CHS[7100228] or CHS[7100224], "EnterButton")
    self:setLabelText("Label_1", self.state == LCHJ_STATE.DOING and CHS[7100228] or CHS[7100224], "EnterButton")
end

-- 设置关卡开启状态
function LingChongDlg:setTaskByState(state, panel, needMagic)
    if not panel  then return end

    local personImage = self:getControl("PersonImage", nil, panel)
    gf:resetImageView(personImage)
    self:setCtrlVisible("NameImage_1", true, panel)
    self:setCtrlVisible("NameImage", true, panel)

    if state == LCHJ_STATE.PASS then
        -- 已通过
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("FightImage", false, panel)
        self:setCtrlVisible("SuccessImage", true, panel)
    elseif state == LCHJ_STATE.SELECT_NOT_DO then
        -- 已选中，但未进入战斗
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("FightImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    elseif state == LCHJ_STATE.DOING then 
        -- 已选中，已进入战斗
        self:setCtrlVisible("ChoseImage", true, panel)
        self:setCtrlVisible("FightImage", true, panel)
        self:setCtrlVisible("SuccessImage", false, panel)
    else
        -- 还未进行
        self:setCtrlVisible("ChoseImage", false, panel)
        self:setCtrlVisible("FightImage", false, panel)
        self:setCtrlVisible("SuccessImage", false, panel)

        gf:grayImageView(personImage)
        self:setCtrlVisible("NameImage_1", false, panel)
        self:setCtrlVisible("NameImage", false, panel)
    end

    if needMagic then
        local pickImage = self:getControl("ChoseImage", nil, panel)  
        pickImage:stopAllActions()
        pickImage:setPosition(panel.choseImagex, panel.choseImagey)        
        local time = 0.6
        local high = 8
        local moveUp = cc.MoveBy:create(time, cc.p(0, high))
        local moveDown = cc.MoveBy:create(time, cc.p(0, -high))         
        pickImage:runAction(cc.RepeatForever:create(cc.Sequence:create(moveUp, moveDown)))
    end
end

function LingChongDlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function LingChongDlg:onEnterButton(sender, eventType)
    local levelRequest = LingChongHuanJingMgr:getHuanJingLevelRequest()
    if Me:getLevel() < levelRequest then
        gf:ShowSmallTips(string.format(CHS[7100242], levelRequest))
        return
    end

    if self.state == LCHJ_STATE.DOING then
        -- 进入观战
        gf:CmdToServer("CMD_LCHJ_LOOKON", {})
    elseif self.state == LCHJ_STATE.SELECT_NOT_DO then
        -- 进入布阵
        if not PetMgr:getFightPet() then
            gf:ShowSmallTips(CHS[7100244])
            return
        end

        gf:CmdToServer("CMD_LCHJ_REQUEST_PETS_INFO", {
            name = LingChongHuanJingMgr:getCurStage(),
            stage = LingChongHuanJingMgr:getCurStageIndex()}
        )
    else
        gf:ShowSmallTips(CHS[7100243])
    end
end

return LingChongDlg
