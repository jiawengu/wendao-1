-- RookieGiftDlg.lua
-- Created by songcw Nov/11/10
-- 新手礼包快捷领取框

local RookieGiftDlg = Singleton("RookieGiftDlg", Dialog)

function RookieGiftDlg:init()
    self:bindListener("UseButton", self.onUseButton)
    self.blank:setLocalZOrder(Const.FAST_GET_NEWGIFT_DLG_ZORDER)
    self:setImage("ItemImage", ResMgr.ui.newGuyGift)
    self:setLabelText("NameLabel", CHS[3003599])
    local button = self:getControl("UseButton")
    self:setLabelText("Label_1", CHS[3003600], button)
    self:setLabelText("Label_2", CHS[3003600], button)

    self.root:setAnchorPoint(0, 0)
    local dlgSize = self.root:getContentSize()
    self.root:setPosition(Const.WINSIZE.width, 0)

    local move = cc.MoveTo:create(0.5, cc.p(Const.WINSIZE.width / Const.UI_SCALE - dlgSize.width  - (Const.WINSIZE.width - self:getWinSize().width) / 2, 0))
    local moveAct = cc.EaseBounceOut:create(move)
    self.root:runAction(cc.Sequence:create(moveAct))
end

function RookieGiftDlg:onUseButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    GiftMgr:openGiftDlg("NoviceGiftDlg")
    self:onCloseButton()
end

return RookieGiftDlg
