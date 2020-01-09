-- OnlyConfirmDlg.lua
-- Created by liuhb Oct/22/2015
-- 只有一个确认按钮的确认款框

local OnlyConfirmDlg = Singleton("OnlyConfirmDlg", Dialog)
local confirmFunc = nil

function OnlyConfirmDlg:init()
    self:bindListener("Button1", self.onButton1)
    confirmFunc = nil

    self.backInitSize = self.backInitSize or self:getControl("ContentPanel"):getContentSize()
    self.backPanelSize = self.backPanelSize or self:getControl("BackPanel"):getContentSize()
    self.bkPanelSize = self.bkPanelSize or self:getControl("BKPanel"):getContentSize()

    self.image_1Size = self.image_1Size or self:getControl("Image_1"):getContentSize()
    self.image_2Size = self.image_2Size or self:getControl("Image_2"):getContentSize()

    self.blank:setLocalZOrder(Const.ZORDER_TOPMOST)
end

function OnlyConfirmDlg:cleanup()


    confirmFunc = nil
end

function OnlyConfirmDlg:setTip(str)
    local panelCtrl = self:getControl("ContentPanel")
    panelCtrl:removeAllChildren()
    local tip = CGAColorTextList:create()
    tip:setFontSize(19)
    tip:setString(str)
    tip:setContentSize(panelCtrl:getContentSize().width, 0)
    tip:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
    tip:updateNow()
    local w, h = tip:getRealSize()
    tip:setContentSize(math.ceil(w), h)
    if panelCtrl then
        local colorLayer = tolua.cast(tip, "cc.LayerColor")
        panelCtrl:addChild(colorLayer)
        gf:align(colorLayer, panelCtrl:getContentSize(), ccui.RelativeAlign.centerInParent)
    end

    -- 如果高度大于原始高度，需要自适应
    if h > self.backInitSize.height then
        local disH = h - panelCtrl:getContentSize().height
        panelCtrl:setContentSize(self.backInitSize.width, h)

        self:setCtrlContentSize("BackPanel", nil, self.backPanelSize.height + disH)
        self:setCtrlContentSize("BKPanel", nil, self.bkPanelSize.height + disH)

        self:setCtrlContentSize("Image_1", nil, self.image_1Size.height + disH)
        self:setCtrlContentSize("Image_2", nil, self.image_2Size.height + disH)
    else
        panelCtrl:setContentSize(self.backInitSize)
        self:setCtrlContentSize("BackPanel", self.backPanelSize.width, self.backPanelSize.height)
        self:setCtrlContentSize("BKPanel", self.bkPanelSize.width, self.bkPanelSize.height)
        self:setCtrlContentSize("Image_1", nil, self.image_1Size.height)
        self:setCtrlContentSize("Image_2", nil, self.image_2Size.height)
    end

    tip:setPosition(panelCtrl:getContentSize().width * 0.5, panelCtrl:getContentSize().height * 0.5)

    panelCtrl:getParent():requestDoLayout()
    self.root:requestDoLayout()
end

function OnlyConfirmDlg:setCallFunc(func, isNotCallInClose)
    self.isNotCallInClose = isNotCallInClose
    confirmFunc = func
end

function OnlyConfirmDlg:onCloseButton()
    if "function" == type(confirmFunc) and not self.isNotCallInClose then
        confirmFunc()
    end

    Dialog.onCloseButton(self)
end

function OnlyConfirmDlg:onButton1(sender, eventType)
    if confirmFunc == nil then
        self:onCloseButton()
        return
    end

    if "function" == type(confirmFunc) then
        confirmFunc()
    end

    -- DlgMgr:closeDlg(self.name)
end

return OnlyConfirmDlg
