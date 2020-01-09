-- WaitDlg.lua
-- Created by zhengjh Sep/25/2015
-- 服务连接等待界面

local WaitDlg = Singleton("WaitDlg", Dialog)

function WaitDlg:init(data)
    local image = ccui.ImageView:create(ResMgr.ui.wait_circle)
    local rotate = cc.RotateBy:create(1, 360)
    local action = cc.RepeatForever:create(rotate)
    local winSize = self:getWinSize()
    image:runAction(action)
    image:setAnchorPoint(0.5, 0.5)
    image:setScale(0.8)
    local size = self.root:getContentSize()
    image:setPosition(size.width / 2, size.height / 2)
    self.root:addChild(image, 10, 10)
    self.blank:setTouchEnabled(true)
    if 'table' == type(data) and data.order then
        self.blank:setLocalZOrder(data.order)
    end

    DlgMgr:setVisible("ScreenRecordingDlg", false)
end

function WaitDlg:cleanup()
    performWithDelay(gf:getUILayer(), function()
        -- ScreenRecordingDlg 中重写了 setVisible 接口，WaitDlg 未关闭时不显示
        DlgMgr:setVisible("ScreenRecordingDlg", true)
    end, 0)
end

return WaitDlg
