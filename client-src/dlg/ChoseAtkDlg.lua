-- ChoseAtkDlg.lua
-- Created by songcw Oct/19/2015
-- 力法选择界面

local ChoseAtkDlg = Singleton("ChoseAtkDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")
local FAMIFY_BOY_INFO = require(ResMgr:getCfgPath('GuardInfo.lua'))

local CHECKBOXS = {
    "PhyCheckBox",
    "MagCheckBox",
}

local MAGIC_POLAR_ADD =
{
    [POLAR.METAL] = {ploarAdd = CHS[3002324], desc = CHS[3002325]},
    [POLAR.WOOD] = {ploarAdd = CHS[3002326], desc = CHS[3002327]},
    [POLAR.WATER] = {ploarAdd = CHS[3002328], desc = CHS[3002329]},
    [POLAR.FIRE] = {ploarAdd = CHS[3002324], desc = CHS[3002325]},
    [POLAR.EARTH] = {ploarAdd = CHS[3002330], desc = CHS[3002331]},
}

function ChoseAtkDlg:init()
   --[[ local contentSize = self.root:getContentSize()
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    --
    local lockPanel = self:getControl("LockScreenPanel")
    lockPanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    local lockUpImage = self:getControl("LockScreenUpImage")
    local lockDownImage = self:getControl("LockScreenDownImage")
    lockUpImage:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, lockUpImage:getContentSize().height)
    lockDownImage:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, lockDownImage:getContentSize().height)

    local dramaPanel = self:getControl("DramaPanel")
    dramaPanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, dramaPanel:getContentSize().height)
    dramaPanel:setPositionY(0)
    local bkPanel = self:getControl("BKPanel")
    bkPanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, bkPanel:getContentSize().height)
    bkPanel:setPositionY(Const.WINSIZE.height / Const.UI_SCALE - bkPanel:getContentSize().height)
    local chosePanel = self:getControl("ChosePanel")
    chosePanel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, chosePanel:getContentSize().height)

    local BKImage = self:getControl("BKImage")
    BKImage:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    dramaPanel:requestDoLayout()
    --


    self:setProgressBar("NumProgressBar", 0, 100)
    self:setProgressBar("SingleProgressBar", 0, 100)
    self:setProgressBar("RangeProgressBar", 0, 100)

    --

    -- 创建互斥按钮
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOXS, self.onCheckBoxClick)

    self:setDlgInfo()]]

    self.select = nil
    self:bindListener("ChoseButton", self.onChoseButton)
    self:bindListener("PhyButtonPanel", self.onChosePanel)
    self:bindListener("MagButtonPanel", self.onChosePanel)
    self:bindListener("CustomButtonPanel", self.onChosePanel)

    self:updateLayout("NoneChosePanel")

    -- 形象
    self:setPortrait("PlayerShapPanel", Me:queryBasicInt("icon"), Me:getDlgWeaponIcon(true), self.root, false, Const.SA_STAND, nil, cc.p(-5, -55))

    -- 洗髓丹
    self:setItemInfo()

    self:playAction()

    self.autoIndex = 0
end


function ChoseAtkDlg:onChosePanel(sender, eventType)

    if sender:getTag() == self.selectIndex then
        return
    end

    local name = sender:getName()
    self.select = sender:getTag()
    self:addSelcetImage(sender)
    self:setCtrlVisible("ChoseButton", true)
    self:setCtrlVisible("NoneChosePanel", false)

    if name == "PhyButtonPanel" then
        self:setCtrlVisible("PhyPanel", true)
        self:setCtrlVisible("PhyChoseImage", true)
        self:setCtrlVisible("MagPanel", false)
        self:setCtrlVisible("MagChoseImage", false)
        self:setCtrlVisible("CustomPanel", false)
    elseif name == "MagButtonPanel" then
        self:setCtrlVisible("PhyPanel", false)
        self:setCtrlVisible("PhyChoseImage", false)
        self:setCtrlVisible("MagPanel", true)
        self:setCtrlVisible("MagChoseImage", true)
        self:setMagInfoPanel()
        self:setCtrlVisible("CustomPanel", false)
    elseif name == "CustomButtonPanel" then
        self:setCtrlVisible("PhyPanel", false)
        self:setCtrlVisible("PhyChoseImage", false)
        self:setCtrlVisible("MagPanel", false)
        self:setCtrlVisible("MagChoseImage", false)
        self:setCtrlVisible("CustomPanel", true)
    end

    self.autoIndex = 0
    self:playAction()
end

function ChoseAtkDlg:setMagInfoPanel()
    local magPanel = self:getControl("MagPanel")
    local polar = Me:queryBasicInt("polar")
    self:setLabelText("ChoseLabel_2", MAGIC_POLAR_ADD[polar].ploarAdd, magPanel)
    self:setLabelText("ChoseLabel_3", MAGIC_POLAR_ADD[polar].desc, magPanel)
end

function ChoseAtkDlg:addSelcetImage(sender)
    local selectImg = self:getControl("ChoseImage", Const.UIImage, sender)

    if self.selectImg == nil then
        self.selectImg = selectImg
        selectImg:setVisible(true)
    else
        self.selectImg:setVisible(false)
        self.selectImg = selectImg
        selectImg:setVisible(true)
    end
end


function ChoseAtkDlg:setItemInfo()
    local itemName = CHS[3002332]
    local icon = InventoryMgr:getIconByName(itemName)
    self:setImage("ItemImage", ResMgr:getItemIconPath(icon))
    self:setItemImageSize("ItemImage")
end


function ChoseAtkDlg:playAction()
    local panel = self:getControl("PlayerShapPanel")
    if not panel then return end
    local char = panel:getChildByTag(Dialog.TAG_PORTRAIT)


    if not char then return end

    char.char:setCallback(function()
        char.char:setCallback(nil)
        char.char:setLoopTimes(0)
        char:setAction(Const.SA_STAND)
        self.autoIndex = self.autoIndex + 1
    end)

    if self.select == nil then
        char:setAction(Const.SA_WALK)
    elseif self.select == 1 then
        char:setAction(Const.SA_ATTACK)
    elseif self.select == 2 then
        char:setAction(Const.SA_CAST)
    elseif self.select == 3 then
        if self.autoIndex % 2 == 0 then
            char:setAction(Const.SA_CAST)
        else
            char:setAction(Const.SA_ATTACK)
        end
    end

    local actPanel = self:getControl("PlayerShapPanel")
    actPanel:stopAllActions()

    schedule(actPanel, function() self:playAction() end, 5)
end

function ChoseAtkDlg:onChoseButton(sender, eventType)
    if not self.select then
        gf:ShowSmallTips(CHS[3002333])
        return
    end

    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = self.select})
    self:onCloseButton()
end

function ChoseAtkDlg:onCloseButton()
    gf:CmdToServer("CMD_CONFIRM_RESULT", {select = 0})
    Dialog.close(self)
end

function ChoseAtkDlg:cleanup()
    self.selectImg = nil
    self.select = nil
    self.autoIndex = 0
end

return ChoseAtkDlg
