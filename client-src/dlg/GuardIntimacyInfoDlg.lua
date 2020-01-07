-- GuardIntimacyInfoDlg.lua
-- Created by lixh Feb/02/2018
-- 守护亲密度加成信息界面

local GuardIntimacyInfoDlg = Singleton("GuardIntimacyInfoDlg", Dialog)

function GuardIntimacyInfoDlg:init(intimacy)
    self:bindListener("InfoButton", self.onInfoButton)    
    self:bindListener("IntimacyInfoPanel", self.onCloseButton)
    self:setData(intimacy)
end

-- 根据亲密度，设置加成信息
function GuardIntimacyInfoDlg:setData(intimacy)
    -- 当前亲密度
    self:setLabelText("Label1", string.format(CHS[7100162], intimacy), "RulePanel1")
    local nextIntimacy, currentEffect = self:getIntimacyEffect(intimacy)
    if nextIntimacy then
        self:setColorText(string.format(CHS[7100163], nextIntimacy), "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)
    else
        self:setColorText(CHS[7100164], "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)
    end

    -- 设置完下一阶段亲密度后,刷新界面高度
    self:refreshDlgHeight()

    -- 当前加成值
    self:setLabelText("DoubleHitLabel2", string.format(CHS[7100165], currentEffect.double_hit_rate), "RulePanel2")
    self:setLabelText("DoubleHitTimesLabel2", string.format(CHS[7100166], currentEffect.double_hit_time), "RulePanel2")
    self:setLabelText("CriticalHitLabel2", string.format(CHS[7100165], currentEffect.stunt_rate), "RulePanel2")
    self:setLabelText("MagCriticalHitLabel2", string.format(CHS[7100165], currentEffect.mstunt_rate), "RulePanel2")
end

-- 刷新界面高度
function GuardIntimacyInfoDlg:refreshDlgHeight()
    -- 亲密度部分Panel的高度
    local rulePanelSz = self:getCtrlContentSize("RulePanel1")
    local intimacyContentHeight = self:getCtrlContentSize("TitleLabel", "RulePanel1").height
        + self:getCtrlContentSize("Label1", "RulePanel1").height + self:getCtrlContentSize("Panel2", "RulePanel1").height + 10
    self:setCtrlContentSize("RulePanel1", rulePanelSz.width, intimacyContentHeight)

    -- 界面高度
    local dlgSz = self:getCtrlContentSize("IntimacyInfoPanel")
    local dlgContentHeight = self:getCtrlContentSize("RulePanel1").height
        + self:getCtrlContentSize("RulePanel2").height + self:getCtrlContentSize("RulePanel3").height
        + self:getCtrlContentSize("InfoButton").height + 15
    self:setCtrlContentSize("IntimacyInfoPanel", dlgSz.width, dlgContentHeight)
    self:setImageSize("BackImage", {width = dlgSz.width, height = dlgContentHeight})
end

-- 获取下一阶段需要的亲密度与当前界面加成效果
function GuardIntimacyInfoDlg:getIntimacyEffect(intimacy)
    local config = GuardMgr:getGuardIntimacyEffectCfg()
    local count = #config
    for i = 1, count - 1 do
        local left = config[i]
        local right = config[i + 1]
        if intimacy >= left.intimacy and intimacy < right.intimacy then
            return right.intimacy, left
        end
    end

    -- 到了这里，说明intimacy不在[0, max)区间内，是最终阶段
    return nil, config[count]
end

function GuardIntimacyInfoDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("GuardIntimacyRuleDlg")
    self:onCloseButton()
end

return GuardIntimacyInfoDlg
