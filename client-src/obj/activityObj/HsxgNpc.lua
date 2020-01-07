-- HsxgNpc.lua
-- Created by lixh Nov/22/2018
-- 2019儿童节护送小龟npc

local Npc = require("obj/Npc")
local HsxgNpc = class("HsxgNpc", Npc)

function HsxgNpc:init()
    Npc.init(self)
end

-- 绑定事件
function HsxgNpc:bindEvent()
    if self.charAction then
        local this = self
        local function onTouchBegan(touch, event)
            if event:getEventCode() == cc.EventCode.BEGAN then
                local function containsTouchPos()
                    if self.charAction.containsTouchPos then
                        return self.charAction:containsTouchPos(touch)
                    else
                        local pos = self.middleLayer:convertTouchToNodeSpace(touch)
                        local rect = self.charAction:getBoundingBox()
                        return cc.rectContainsPoint(rect, pos)
                    end
                end

                -- 可见时才处理 Touch 事件
                if containsTouchPos() and self.visible and self:isCanTouch() then
                    return true
                end

                return false
            elseif event:getEventCode() == cc.EventCode.ENDED then
                self:refreshClickEffect()
                return false
            end
        end

        gf:bindTouchListener(self.charAction, onTouchBegan, cc.Handler.EVENT_TOUCH_ENDED, false)
    end
end

-- 刷新点击效果
function HsxgNpc:refreshClickEffect()
    if not self.feedImage then
        local feedImage = self:getIconImage(ResMgr.ui.child_day_feed_pet)
        feedImage:setPosition(cc.p(-50, 50))
        self:addToTopLayer(feedImage)
        self.feedImage = feedImage
        self.feedImage:setTouchEnabled(true)
        self.feedImage:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                ChildDayHsxgMgr:childDatFeedNpc(1)
                self:refreshClickEffect()
            end
        end)
    end

    if not self.stoneImage then
        local stoneImage = self:getIconImage(ResMgr.ui.child_day_throw_stone)
        stoneImage:setPosition(cc.p(50, 50))
        self:addToTopLayer(stoneImage)
        self.stoneImage = stoneImage
        self.stoneImage:setTouchEnabled(true)
        self.stoneImage:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                ChildDayHsxgMgr:childDatFeedNpc(2)
                self:refreshClickEffect()
            end
        end)
    end

    self.feedImage:setVisible(not self.feedImage:isVisible() and not self.isDead)
    self.stoneImage:setVisible(not self.stoneImage:isVisible() and not self.isDead)
end

-- 获取图标图片精灵
function HsxgNpc:getIconImage(iconPath)
    return ccui.ImageView:create(iconPath, ccui.TextureResType.localType)
end

-- 播放死亡动作
function HsxgNpc:doDiedAction()
    self.isDead = true
    self:setActAndCB(Const.FA_DIE_NOW, function()
        if self.faAct == Const.FA_DIE_NOW then
            self:setAct(Const.FA_DIED)
        end
    end)
end

return HsxgNpc