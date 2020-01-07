-- ChildIntimacyInfoDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃亲密度界面

local ChildIntimacyInfoDlg = Singleton("ChildIntimacyInfoDlg", Dialog)

function ChildIntimacyInfoDlg:init(intimacy)
    self:bindListener("InfoButton", self.onInfoButton)

    -- 暂时屏蔽规则按钮
    self:setCtrlVisible("InfoButton", false)

    self:bindListener("IntimacyInfoPanel", self.onCloseButton)
  
    self:setData(intimacy)
end

function ChildIntimacyInfoDlg:setData(intimacy)
    local curIntimacy = intimacy
    self:setLabelText("Label1", string.format(CHS[7100436], curIntimacy), "RulePanel1")      

    local nextLv, curInfo = self:getIntimacyInfo(curIntimacy)
    if not nextLv then
        self:setColorText(CHS[4200448], "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)     
    else        
        self:setColorText(string.format(CHS[4100866], nextLv), "Panel2", "RulePanel1", nil, nil, COLOR3.WHITE, 19)
    end    

    -- 设置完下一阶段亲密度后,刷新界面高度
    self:refreshDlgHeight()

    local panel = self:getControl("RulePanel2")
    
    -- 物伤
    self:setLabelText("PhyLabel2", string.format("+ %d%%", curInfo.pow), panel)
    -- 法伤
    self:setLabelText("MagLabel2", string.format("+ %d%%", curInfo.pow), panel)
    -- 防御
    self:setLabelText("DefLabel2", string.format("+ %d%%", curInfo.def), panel)
    -- 复活率
    self:setLabelText("ReviveLabel2", string.format("+ %d%%", curInfo.revivification_rate), panel)
    -- 复活次数
    self:setLabelText("ReviveTimesLabel2", string.format("+ %d", curInfo.revivification_time), panel)
    -- 物理必杀率
    self:setLabelText("CriticalHitLabel2", string.format("+ %d%%", curInfo.stunt_rate), panel)
    -- 物理连击率
    self:setLabelText("DoubleHitLabel2", string.format("+ %d%%", curInfo.double_hit_rate), panel)
    -- 物理连击数
    self:setLabelText("DoubleHitTimesLabel2", string.format("+ %d", curInfo.double_hit_time), panel)
end

-- 刷新界面高度
function ChildIntimacyInfoDlg:refreshDlgHeight()
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

function ChildIntimacyInfoDlg:getIntimacyInfo(intimacy)
    local intimacyCfg = HomeChildMgr:getIntimacyCfg()
    local nextLevel
    local curLevel = 0
    for lv, info in pairs(intimacyCfg) do
        if intimacy < lv then
            nextLevel = nextLevel or lv
            nextLevel = math.min(lv, nextLevel)
        end

        if intimacy >= lv and curLevel < lv then
            curLevel = lv
        end
    end

    return nextLevel, intimacyCfg[curLevel]
end

function ChildIntimacyInfoDlg:onInfoButton(sender, eventType)
end

return ChildIntimacyInfoDlg
