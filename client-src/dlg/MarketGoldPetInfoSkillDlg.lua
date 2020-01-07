-- MarketGoldPetInfoSkillDlg.lua
-- Created by songcw
-- 宠物技能信息界面

local MarketGoldPetInfoSkillDlg = Singleton("MarketGoldPetInfoSkillDlg", Dialog)

function MarketGoldPetInfoSkillDlg:init(pet)
    self:bindListener("SlipButton", self.onSlipButton)
    self:bindListViewListener("ListView", self.onSelectListView)

    if pet.getId and pet:getId() and PetMgr:getPetById(pet:getId()) then
        self.isMePet = true
    else
        self.isMePet = false
    end

        -- 宠物技能
    PetMgr:setSkillInfoForCard(pet, self)

    self.isInitListView = true

    local scrollview = self:getControl("ListView")
    scrollview:addScrollViewEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
end

-- 更新向下提示
function MarketGoldPetInfoSkillDlg:updateDownArrow(sender, eventType)

    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件
        local listViewCtrl = sender

        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height

        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)

        if not self.isInitListView then
            self:setCtrlVisible("SlipButton", persent < 93)-- 留一点空余部分
        end

        self.isInitListView = false
    end
end

function MarketGoldPetInfoSkillDlg:onSlipButton(sender, eventType)
end

function MarketGoldPetInfoSkillDlg:onSelectListView(sender, eventType)
end

return MarketGoldPetInfoSkillDlg
