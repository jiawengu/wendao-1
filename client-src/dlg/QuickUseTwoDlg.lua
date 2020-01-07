-- QuickUseTwoDlg.lua
-- Created by lixh Mar/05/2018
-- 快捷使用界面(设置2种点数)

local QuickUseTwoDlg = Singleton("QuickUseTwoDlg", Dialog)

function QuickUseTwoDlg:init(data)
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("AddButton", self.onAddDoubleButton, "SetPanel")
    self:bindListener("AddButton", self.onAddChongfsButton, "Set2Panel")
    self:bindListener("MoneyPayButton", self.onMoneyPayButton)
    self:bindListener("AcerPayButton", self.onAcerPayButton)
    self:bindFloatPanelListener("ChongfsPayPanel")
    self.pos = data.pos

    -- 物品信息
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        self:setLabelText("ItemNameLabel", item.name)
        self:updateItemNum()
        local img = self:setImage("ItemImage", InventoryMgr:getIconFileByName(item.name))
        self:setItemImageSize("ItemImage")
        if item and InventoryMgr:isTimeLimitedItem(item) then
            InventoryMgr:removeLogoBinding(img)
            InventoryMgr:addLogoTimeLimit(img)
        elseif item and InventoryMgr:isLimitedItem(item) then
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:addLogoBinding(img)
        else
            InventoryMgr:removeLogoTimeLimit(img)
            InventoryMgr:removeLogoBinding(img)
        end

        if item.level and item.level > 0 then
            self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.CENTER, 21)
        end

        self:bindListener("ItemImage", self.onItemPanel)
    end

    -- 双倍选项
    self:setCheck("DoublePointCheckBox", data.doubleEnable == 1, "SetPanel")

    -- 双倍点数
    self:updateDoubelPointNum()

    -- 宠风散选项
    self:setCheck("DoublePointCheckBox", data.chongfsEnable == 1, "Set2Panel")

    -- 宠风散点数
    self:updateChongfsPointNum()

    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SHUADAO_REFRESH")

    OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")

    GetTaoMgr:requestOfflineShuadao()
end

-- 悬浮框
function QuickUseTwoDlg:onItemPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        InventoryMgr:showBasicMessageDlg(item.name, rect)
    end
end

-- 购买双倍点数
function QuickUseTwoDlg:onAddDoubleButton(sender, envetType)
    if not DistMgr:checkCrossDist() then return end

    if Me:queryBasicInt("double_points") > PracticeMgr:getDoublePointLimit() - 200 then
        gf:ShowSmallTips(CHS[3003496])

    else
        DlgMgr:openDlg("PracticeBuyDoubleDlg")
    end
end

-- 购买宠风散
function QuickUseTwoDlg:onAddChongfsButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if GetTaoMgr:getPetFengSanPoint() > GetTaoMgr:getMaxChongFengSanPoint() - 200 then
        gf:ShowSmallTips(CHS[6200029])
        return
    end

    local button = self:getControl("MoneyPayButton", nil, "ChongfsPayPanel")
    local image = self:getControl("Image_207", nil, "ChongfsPayPanel")
    if GetTaoMgr:getCashHaveBuyChongFengSanTimes() == GetTaoMgr:GetMaxCanBuyTimes() then
        gf:grayImageView(button)
        gf:grayImageView(image)
    else
        gf:resetImageView(button)
        gf:resetImageView(image)
    end

    local str = string.format(CHS[6200031], GetTaoMgr:getCashHaveBuyChongFengSanTimes(), GetTaoMgr:GetMaxCanBuyTimes())
    self:setLabelText("TitleLabel", str, "ChongfsPayPanel")

    self:setCtrlVisible("ChongfsPayPanel", true)
end

-- 金钱购买宠风散
function QuickUseTwoDlg:onMoneyPayButton()
    self:setCtrlVisible("ChongfsPayPanel", false)

    if GetTaoMgr:getCashHaveBuyChongFengSanTimes() == GetTaoMgr:GetMaxCanBuyTimes() then
        gf:ShowSmallTips(CHS[6200036])
        return
    end

    local dlg = DlgMgr:openDlg("PetFengsBuyDlg")
    dlg:setType("chongfs")
end

-- 元宝购买宠风散
function QuickUseTwoDlg:onAcerPayButton()
    local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
    dlg:setInfoByType("chongfengsan")
    self:setCtrlVisible("ChongfsPayPanel", false)
end

-- 刷新物品数量
function QuickUseTwoDlg:updateItemNum()
    local item = InventoryMgr:getItemByPos(self.pos)
    if item then
        self:setLabelText("ItemNumLabel", string.format(CHS[7120049], item.amount))
    else
        -- 物品数量变未0时，关闭界面
        self:onCloseButton()
    end
end

-- 刷新双倍点数
function QuickUseTwoDlg:updateDoubelPointNum()
    local item = InventoryMgr:getItemByPos(self.pos)
    local num = GetTaoMgr:getAllDoublePoint()
    local quickUseItemCfg = InventoryMgr:getQuickUseItemCfg()
    if item and quickUseItemCfg[item.name] and quickUseItemCfg[item.name].needDoublePoint
        and num < quickUseItemCfg[item.name].needDoublePoint then
        -- 小于该物品最低点数要求，显示红色
        self:setLabelText("NumLabel2", num, "SetPanel", COLOR3.RED)
    else
        self:setLabelText("NumLabel2", num, "SetPanel", COLOR3.TEXT_DEFAULT)
    end
end

-- 刷新宠风散点数
function QuickUseTwoDlg:updateChongfsPointNum()
    local item = InventoryMgr:getItemByPos(self.pos)
    local num = GetTaoMgr:getPetFengSanPoint()
    local quickUseItemCfg = InventoryMgr:getQuickUseItemCfg()
    if item and quickUseItemCfg[item.name] and quickUseItemCfg[item.name].needChongfsPoint
        and num < quickUseItemCfg[item.name].needChongfsPoint then
        -- 小于该物品最低点数要求，显示红色
        self:setLabelText("NumLabel2", num, "Set2Panel", COLOR3.RED)
    else
        self:setLabelText("NumLabel2", num, "Set2Panel", COLOR3.TEXT_DEFAULT)
    end
end

function QuickUseTwoDlg:onUseButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003462])
        return
    end

    local doubleTag = self:isCheck("DoublePointCheckBox", "SetPanel") and 1 or 0
    local chongfsTag = self:isCheck("DoublePointCheckBox", "Set2Panel") and 1 or 0
    gf:CmdToServer("CMD_QUICK_USE_ITEM", {pos = self.pos, doubleEnabel = doubleTag, chongfsEnable = chongfsTag})
end



function QuickUseTwoDlg:MSG_SHUADAO_REFRESH()
    local button = self:getControl("MoneyPayButton", nil, "ChongfsPayPanel")
    local image = self:getControl("Image_207", nil, "ChongfsPayPanel")
    if GetTaoMgr:getCashHaveBuyChongFengSanTimes() == GetTaoMgr:GetMaxCanBuyTimes() then
        gf:grayImageView(button)
        gf:grayImageView(image)
    else
        gf:resetImageView(button)
        gf:resetImageView(image)
    end

    local str = string.format(CHS[6200031], GetTaoMgr:getCashHaveBuyChongFengSanTimes(), GetTaoMgr:GetMaxCanBuyTimes())
    self:setLabelText("TitleLabel", str, "ChongfsPayPanel")
end

function QuickUseTwoDlg:MSG_INVENTORY()
    self:updateItemNum()
end

function QuickUseTwoDlg:MSG_UPDATE()
    self:updateDoubelPointNum()
    self:updateChongfsPointNum()
end

return QuickUseTwoDlg
