-- QuanmPKRuleDlg.lua
-- Created by yangym Apr/18/2017
-- 全民PK规则界面

local QuanmPKRuleDlg = Singleton("QuanmPKRuleDlg", Dialog)

function QuanmPKRuleDlg:init()
    -- 隐藏状态所有panel
    self:setCtrlVisible("QuanmPKrsRulePanel", false)
    self:setCtrlVisible("QuanmPKjfRulePanel", false)
    self:setCtrlVisible("QuanmPKtaotaiRulePanel", false)
    self:setCtrlVisible("QuanmPKNfinalRulePanel", false)
    self:setCtrlVisible("QuanmPKGfinalRulePanel", false)
    self:setCtrlVisible("QuanmPKCityWarRulePanel", false)
end

-- 当前处于什么阶段/是否确认了参赛阵容
function QuanmPKRuleDlg:displayStage()
    if MapMgr:getCurrentMapName() == CHS[7120148] then
        -- 城市赛场直接显示默认规则
        self:setCtrlVisible("QuanmPKCityWarRulePanel", true)
        return
    end

    local qmpkInfo = QuanminPK2Mgr:getFubenData()
    if not qmpkInfo then
        return
    end

    local retStr = CHS[7120131]
    local leaderStr = ""
    local memberStr = ""
    if not (QuanminPKMgr:isQMJournalist() or GMMgr:isGM() or GMMgr:isWarAdmin(CHS[4300464])) then
        for i = 1, qmpkInfo.memberCount do
            local info = qmpkInfo.teamlist[i]
            if info then
                if info.isLeader == 1 then
                    leaderStr = self:getShowName(info)
                else
                    if memberStr == "" then
                        memberStr = memberStr .. self:getShowName(info)
                    else
                        memberStr = memberStr .. "、" .. self:getShowName(info)
                    end
                end
            end
        end

        retStr = string.format(CHS[7120132], leaderStr, memberStr)
    end

    self:setLabelPanelText("QuanmPKjfRulePanel", retStr)
    self:setLabelPanelText("QuanmPKtaotaiRulePanel", retStr)
    self:setLabelPanelText("QuanmPKNfinalRulePanel", retStr)
    self:setLabelPanelText("QuanmPKGfinalRulePanel", retStr)

    if string.match(qmpkInfo.status, "score") then -- 积分赛
        self:setCtrlVisible("QuanmPKjfRulePanel", true)
    elseif string.match(qmpkInfo.status, "kickout") then -- 淘汰赛
        self:setCtrlVisible("QuanmPKtaotaiRulePanel", true)

        -- 淘汰赛需要单独设置一下标题
        local rulePanel = self:getControl("RulePanel1", nil, "QuanmPKtaotaiRulePanel")
        local title = QuanminPK2Mgr:getMatchNameBySign(qmpkInfo.status, qmpkInfo.matchId)
        self:setLabelText("TitleLabel", title, rulePanel)
    elseif string.match(qmpkInfo.status, "final") then -- 总决赛
        if DistMgr:curIsTestDist() then
            self:setCtrlVisible("QuanmPKNfinalRulePanel", true)
        else
            self:setCtrlVisible("QuanmPKGfinalRulePanel", true)
        end
    else -- 热身赛
        self:setCtrlVisible("QuanmPKrsRulePanel", true)

        -- 热身赛需要显示报名截止时间
        local timeStr = gf:getServerDate(CHS[7120134], qmpkInfo.endSignTime)
        self:setLabelText("Label2", string.format(CHS[7120133], timeStr))

        self:setCtrlVisible("LeftPanel_1", false, "QuanmPKrsRulePanel")
        self:setCtrlVisible("LeftPanel_2", false, "QuanmPKrsRulePanel")
        if retStr == string.format(CHS[7120132], "", "") then
            -- 未确认参赛阵容
            self:setLabelPanelText("QuanmPKrsRulePanel", "")
            self:setCtrlVisible("LeftPanel_1", true, "QuanmPKrsRulePanel")
        else
            if QuanminPKMgr:isQMJournalist() or GMMgr:isGM() or GMMgr:isWarAdmin(CHS[4300464]) then
                -- 热身赛记者、GM显示内容与其他阶段不一样
                retStr = CHS[7120139]
            else
                -- 热身赛玩家显示内容与其他阶段不一样
                retStr = string.format(CHS[7120140], leaderStr, memberStr)
            end

            self:setLabelPanelText("QuanmPKrsRulePanel", retStr)
            self:setCtrlVisible("LeftPanel_2", true, "QuanmPKrsRulePanel")
        end

        self:getControl("QuanmPKrsRulePanel"):requestDoLayout()
    end
end

function QuanmPKRuleDlg:setLabelPanelText(panelName, str)
    local mainPanel = self:getControl(panelName)
    local heightBefore = self:getControl("LabelPanel", nil, panelName):getContentSize().height
    local heightAfter = self:setColorText(str, "LabelPanel", mainPanel, 0, 0, COLOR3.WHITE, 21)

    local bkImage = self:getControl("BackImage", nil, mainPanel)
    local bkContentSize = bkImage:getContentSize()
    bkImage:setContentSize(bkContentSize.width, bkContentSize.height + heightAfter - heightBefore)
    mainPanel:requestDoLayout()
end

function QuanmPKRuleDlg:getShowName(info)
    return "#Y" .. info.dist .. "-" .. gf:getRealName(info.name) .. "#n"
end

return QuanmPKRuleDlg
