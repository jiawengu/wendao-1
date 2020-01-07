-- BonusInfo2Dlg.lua
-- Created by zhengjh Nov/7/2015
-- 奖励悬浮框

local BonusInfo2Dlg = Singleton("BonusInfo2Dlg", Dialog)

function BonusInfo2Dlg:init()
    self.size = self.size or self.root:getContentSize()
    self:bindListener("MainPanel", self.onCloseButton)
end

function BonusInfo2Dlg:setRewardInfo(rewardInfo)
    -- 设置图片
    local image = self:getControl("ItemImage")
    image:loadTexture(rewardInfo["imagePath"], rewardInfo["resType"])
    
    -- 限制交易/限时
    if rewardInfo["time_limited"] then
        InventoryMgr:addLogoTimeLimit(image)
    elseif rewardInfo["limted"] then
        InventoryMgr:addLogoBinding(image)
    end

    -- 名字(名字需要进行容错，旧数据可能包括（削减前）)
    local rewardName = string.match(rewardInfo["basicInfo"][1], CHS[7100072])
    if not rewardName then
        rewardName = rewardInfo["basicInfo"][1]
    end

    self:setLabelText("NameLabel", rewardName)
    if rewardInfo["basicInfo"]["color"] then
        local nameLabel = self:getControl("NameLabel")
        nameLabel:setColor(rewardInfo["basicInfo"]["color"])
    end

    -- 额外信息，武学和道行需要加上：（削减前）。
    local str = rewardInfo["basicInfo"][2] or ""
    if str ~= "" and (rewardName == CHS[3002149] or rewardName == CHS[3002147]) then
        str = str .. CHS[7100071]
    end

    self:setLabelText("CommondLabel", str)
    
    local missPanelCount = 0
    
    if rewardInfo.limitedStr then
        self:setColorText(rewardInfo.limitedStr[1].str, "BindPanel", nil, 0, 0, rewardInfo.limitedStr[1].color, 20, true)
        self:setCtrlVisible("BindPanel", true)
    else
        self:setCtrlVisible("BindPanel", false)
        missPanelCount = missPanelCount + 1
    end
    
    if rewardInfo.time_limitedStr then
        self:setColorText(rewardInfo.time_limitedStr, "DeadLinePanel", nil, 0, 0, nil, 20, true)
        self:setCtrlVisible("DeadLinePanel", true)
    else
        self:setCtrlVisible("DeadLinePanel", false)
        missPanelCount = missPanelCount + 1
    end
    
    local mainPanel = self:getControl("MainPanel")
    mainPanel:setContentSize(self.size.width, self.size.height - missPanelCount * 31 + 5)
    self.root:setContentSize(self.size.width, self.size.height - missPanelCount * 31 + 5)
    mainPanel:requestDoLayout()
    self.root:requestDoLayout()
    
    
    
end

return BonusInfo2Dlg
