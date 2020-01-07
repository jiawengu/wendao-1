-- AnniversaryLingMaoRuleDlg.lua
-- Created by huangzz Feb/08/2018
-- 驯养灵猫规则界面

local AnniversaryLingMaoRuleDlg = Singleton("AnniversaryLingMaoRuleDlg", Dialog)

function AnniversaryLingMaoRuleDlg:init()
    self:getControl("ListView"):addScrollViewEventListener(function(sender, eventType) self:updateDownArrow(sender, eventType) end)

    performWithDelay(self.root, function() 
        self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon()) 
    end, 0)
end

-- 更新向下提示
function AnniversaryLingMaoRuleDlg:updateDownArrow(sender, eventType)
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

        if persent < 97 then
            self:addMagicAndSee("MagicPanel", ResMgr:getMagicDownIcon())
        else
            self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon())
        end
    elseif ccui.ScrollviewEventType.scrollToBottom == eventType then
        self:removeMagicAndNoSee("MagicPanel", ResMgr:getMagicDownIcon())
    end
end

function AnniversaryLingMaoRuleDlg:addMagicAndSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:addMagic(ctrl, icon)
    ctrl:setVisible(true)
end

function AnniversaryLingMaoRuleDlg:removeMagicAndNoSee(panelName, icon)
    local ctrl = self:getControl(panelName)
    self:removeMagic(ctrl, icon)
    ctrl:setVisible(false)
end

return AnniversaryLingMaoRuleDlg
