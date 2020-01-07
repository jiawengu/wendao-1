-- NewServiceExpDlg.lua
-- Created by huangzz Aug/30/2018
-- 新服助力界面

local NewServiceExpDlg = Singleton("NewServiceExpDlg", Dialog)

function NewServiceExpDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)

    local data = GiftMgr:getWelfareData()
    local num = data and data.newServeAddNum or 0
    if num < 0 then num = 0 end

    local str = string.format("%.1f%%", num / 10)
    local numImg = self:setNumImgForPanel("AdditionPanel", ART_FONT_COLOR.B_FIGHT, str, false, LOCATE_POSITION.MID, 25)

    local activityTime = ActivityMgr:getActivityStartTimeByMainType("newdisthelp")
    local curTime = gf:getServerTime()
    if activityTime and activityTime["startTime"] and activityTime["endTime"] then
        self:setLabelText("TimeLabel", 
            string.format(CHS[4200311], 
                gf:getServerDate(CHS[5420147], activityTime["startTime"]),
                gf:getServerDate(CHS[5420147], activityTime["endTime"])
            )
        )
    end

    if num == 0 then
        gf:ShowSmallTips(CHS[5400518])
        performWithDelay(self.root, function()
            self:onCloseButton()
        end, 0)
    end
end

function NewServiceExpDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("NewServiceExpRuleDlg")
end

return NewServiceExpDlg
