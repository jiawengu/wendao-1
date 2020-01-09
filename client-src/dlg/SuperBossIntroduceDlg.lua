-- SuperBossIntroduceDlg.lua
-- Created by songcw Nov/23/2016
-- 超级大BOSS图鉴

local SuperBossIntroduceDlg = Singleton("SuperBossIntroduceDlg", Dialog)

local BOSS_SHOW_PANEL = {
    [CHS[4300156]] = {"BearIntroducePanel", "BearTipsPanel"},
    [CHS[4300157]] = {"PigIntroducePanel", "PigTipsPanel"},
    [CHS[7002094]] = {"MonkeyIntroducePanel", "MonkeyTipsPanel"},
    [CHS[7002306]] = {"ScorpionIntroducePanel", "ScorpionTipsPanel"},
}

function SuperBossIntroduceDlg:init()
    local bearScroll = self:getControl("BearScrollView")
    local bearPanel = self:getControl("BearInnerPanel")
    bearScroll:setInnerContainerSize(bearPanel:getContentSize())
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), bearScroll:getParent())
    bearScroll:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
    
    local pigScroll = self:getControl("PigScrollView")
    local pigPanel = self:getControl("PigInnerPanel")
    pigScroll:setInnerContainerSize(pigPanel:getContentSize())
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), pigScroll:getParent())
    pigScroll:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
    
    local monkeyScroll = self:getControl("MonkeyScrollView")
    local monkeyPanel = self:getControl("MonkeyInnerPanel")
    monkeyScroll:setInnerContainerSize(monkeyPanel:getContentSize())
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), monkeyScroll:getParent())
    monkeyScroll:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
    
    local scorpionScroll = self:getControl("ScorpionScrollView")
    local scorpionPanel = self:getControl("ScorpionInnerPanel")
    scorpionScroll:setInnerContainerSize(scorpionPanel:getContentSize())
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), scorpionScroll:getParent())
    scorpionScroll:addEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)
end

-- 增加向下光效
function SuperBossIntroduceDlg:addMagicAndSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

-- 删除向下光效
function SuperBossIntroduceDlg:removeMagicAndNoSee(panelName, icon, root)
    local ctrl = self:getControl(panelName, nil, root)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

-- 更新向下提示
function SuperBossIntroduceDlg:updateDownArrow(sender, eventType)
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

        if persent < 90 then
            self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        else
            self:removeMagicAndNoSee("DownPanel", ResMgr:getMagicDownIcon(), listViewCtrl:getParent())
        end
    end
end

-- 将界面不该显示的隐藏 
function SuperBossIntroduceDlg:defHidePanel()
    for _, panelTab in pairs(BOSS_SHOW_PANEL) do
        for i, panelName in pairs(panelTab) do
            self:setCtrlVisible(panelName, false)
        end
    end
end

-- 设置数据 
function SuperBossIntroduceDlg:setDlgData(bossInfo)
    self:defHidePanel()
    
    for i, panelName in pairs(BOSS_SHOW_PANEL[bossInfo.name]) do
        self:setCtrlVisible(panelName, true)
    end
    
    local bearScroll = self:getControl("BearScrollView")
    bearScroll:getInnerContainer():setPositionY(bearScroll:getContentSize().height - bearScroll:getInnerContainer():getContentSize().height)
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), bearScroll:getParent())

    local pigScroll = self:getControl("PigScrollView")
    pigScroll:getInnerContainer():setPositionY(pigScroll:getContentSize().height - pigScroll:getInnerContainer():getContentSize().height)
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), pigScroll:getParent())
    
    local monkeyScroll = self:getControl("MonkeyScrollView")
    monkeyScroll:getInnerContainer():setPositionY(monkeyScroll:getContentSize().height - monkeyScroll:getInnerContainer():getContentSize().height)
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), monkeyScroll:getParent())
    
    local scorpionScroll = self:getControl("ScorpionScrollView")
    scorpionScroll:getInnerContainer():setPositionY(scorpionScroll:getContentSize().height - scorpionScroll:getInnerContainer():getContentSize().height)
    self:addMagicAndSee("DownPanel", ResMgr:getMagicDownIcon(), scorpionScroll:getParent())
end

return SuperBossIntroduceDlg
