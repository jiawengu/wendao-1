
-- ConvenientCallGuardDlg.lua
-- Created by Chang_back Jun/9/2015
-- 快捷使用守护界面

local ConvenientCallGuardDlg = Singleton("ConvenientCallGuardDlg", Dialog)

function ConvenientCallGuardDlg:init()
    self:bindListener("UseButton", self.onUseButton)
    self.itemImage = self:getControl("ItemImage", Const.UIImage)
    self.nameLabel = self:getControl("NameLabel", Const.UILabel)

    self.blank:setLocalZOrder(Const.FAST_CALL_GUARD_DLG_ZORDER)
    self.root:setAnchorPoint(0, 0)
    local dlgSize = self.root:getContentSize()
    self.root:setPosition(Const.WINSIZE.width, 0)

    local move = cc.MoveTo:create(0.5, cc.p(Const.WINSIZE.width / Const.UI_SCALE - dlgSize.width  - (Const.WINSIZE.width - self:getWinSize().width) / 2, 0))
    local moveAct = cc.EaseBounceOut:create(move)
    self.root:runAction(moveAct)
    self.curGuardName = ""
end

function ConvenientCallGuardDlg:MSG_CARD_INFO(data)
end

function ConvenientCallGuardDlg:setInfo(guardData)
    local imgPath = ResMgr:getSmallPortrait(guardData[2])          -- 设置守护图像
    self.itemImage:loadTexture(imgPath)
    gf:setItemImageSize(self.itemImage)
    self.nameLabel:setText(guardData[4])                           -- 设置守护名称（Label）
    self.curGuardName = guardData[4]                               -- 当前守护的名称

    -- 根据守卫的品质类型，设置守卫名字的颜色
    local rank = guardData[8]  -- 获取守卫品质
    local color = CharMgr:getNameColorByType(OBJECT_TYPE.GUARD, false, rank)  -- 获取与品质对应的颜色
    self.nameLabel:setColor(color)
end

function ConvenientCallGuardDlg:onUseButton(sender, eventType)
    if eventType == ccui.TouchEventType.ended then

        -- 打开守护界面并选中对应守护
        local callGuardDlg = DlgMgr:openDlg("GuardAttribDlg")

        if callGuardDlg then
            performWithDelay(callGuardDlg.root,function()
                DlgMgr:sendMsg("GuardListChildDlg", "selectGuardByName", self.curGuardName)
            end, 0.3)
        end

        DlgMgr:closeDlg(self.name)
    end
end

return ConvenientCallGuardDlg
