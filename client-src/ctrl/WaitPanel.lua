-- WaitPanel.lua
-- Created by huangzz, Nov/06/2018
-- 等待刷新控件

local WaitPanel = class("WaitPanel", function()
    return ccui.Layout:create()
end)

function WaitPanel:ctor(icon)
    self:setBackGroundImage(ResMgr.ui.wait_back, ccui.TextureResType.plistType)
    self:setContentSize({width = 130, height = 130})
    self:setBackGroundImageCapInsets(cc.rect(10, 10, 1, 1))
    self:setBackGroundImageScale9Enabled(true)

    local size = self:getContentSize()

    local image = ccui.ImageView:create(icon or ResMgr.ui.wait_circle)
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    image:runAction(action)
    image:setAnchorPoint(0.5, 0.5)
    image:setScale(0.8)
    image:setPosition(size.width / 2, size.height / 2)
    self.image = image

    self:addChild(image, 10, 10)
end

function WaitPanel:setTouchPanel(size)
    local panel = ccui.Layout:create()
    panel:setContentSize(size)
    panel:setTouchEnabled(true)

    local size = self:getContentSize()
    panel:setPosition(size.width / 2, size.height / 2)
    panel:setAnchorPoint(0.5, 0.5)
    self:addChild(panel)
end

function WaitPanel:setPos(x, y)
    self.image:setPosition(x, y)
end

return WaitPanel