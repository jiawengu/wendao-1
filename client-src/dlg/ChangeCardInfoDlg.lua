-- ChangeCardInfoDlg.lua
-- Created by songcw Apr/22/2015
-- 变身卡悬浮框

local ChangeCardInfoDlg = Singleton("ChangeCardInfoDlg", Dialog)

function ChangeCardInfoDlg:init()
    self:bindListener("MoreOperateButton", self.onMoreOperateButton)
    self:bindListener("OperateButton", self.onOperateButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("ResourceButton", self.onDepositButton)
    self:bindListener("MainPanel", self.onCloseButton)

    self:bindListener("StoreButton", self.onStoreButton)

    self.button = self:getControl("DepositButton"):clone()
    self.button:setVisible(true)
    self.button:retain()

    self:setCtrlVisible("DepositButton", false)

    self.item = nil
    self.btnsShow = false
    self.btnLayer = nil

    self.dlgContentSize = self.dlgContentSize or self.root:getContentSize()
end

function ChangeCardInfoDlg:cleanup()
    self:releaseCloneCtrl("button")
end

function ChangeCardInfoDlg:setInfoFromPos(pos)
end

function ChangeCardInfoDlg:setInfoFromItem(item, isCard)
    self.item = item
    local rawName = string.match(item.name, CHS[4100079])
    local cardInfo = InventoryMgr:getCardInfoByName(item.name)

    -- 名字、等级，icon
    self:setLabelText("EquipmentNameLabel", item.name)
    self:setLabelText("LevelLabel", CHS[4100085] .. cardInfo.card_level)
    self:setImage("EquipmentImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)))
    self:setItemImageSize("EquipmentImage")

    if item and InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(self:getControl("EquipmentImage"))
    end

    -- 描述
    local desStr = InventoryMgr:getDescript(item.name)
    self:setLabelText("DescLabel", desStr)

    local image = self:getControl("EquipmentImage")
    image:removeAllChildren()
    InventoryMgr:addPolarChangeCard(image, item.name)


    --song
    local totalInfo = InventoryMgr:getChangeCardEff(item.name)

    -- 持续时间
    local keepTime = {str = string.format(CHS[4100086], InventoryMgr:getCardChangeTime(cardInfo.card_type)), color = COLOR3.EQUIP_NORMAL}
    table.insert(totalInfo, keepTime)

    local limitTab = InventoryMgr:getLimitAtt(item)
    if next(limitTab) then
        local limit = {str = limitTab[1]["str"], color = COLOR3.RED}
        table.insert(totalInfo, limit)
    end

    local missCount = 0
    for i = 1, 12 do
        local attInfo = totalInfo[i]
        if attInfo then
            self:setLabelText("BaseAttributeLabel" .. i, attInfo.str, nil, attInfo.color)
        else
            self:setLabelText("BaseAttributeLabel" .. i, "")
            missCount = missCount + 1
        end
    end

    local singelSize = self:getControl("BaseAttributeLabel1"):getContentSize()
    local missHeight = (singelSize.height + 3) * missCount

    self:getControl("MainPanel"):setContentSize(self.dlgContentSize.width, self.dlgContentSize.height - missHeight)
    self.root:setContentSize(self.dlgContentSize.width, self.dlgContentSize.height - missHeight)


    if isCard then
        self:setCtrlVisible("BttonPanel", false)
        self:setCtrlVisible("DepositButton", true)

        self:setLabelText("Label_16", CHS[3002816], "DepositButton")
    else
        self:setCtrlVisible("BttonPanel", true)
        self:setCtrlVisible("DepositButton", false)
    end

    self:updateLayout("MainPanel")
end

function ChangeCardInfoDlg:getCardTypeChs(cardType)
    if cardType == CARD_TYPE.MONSTER then
        return CHS[4100087]
    elseif cardType == CARD_TYPE.ELITE then
        return CHS[4100088]
    elseif cardType == CARD_TYPE.BOSS then
        return CHS[4100089]
    elseif cardType == CARD_TYPE.EPIC then
        return CHS[5450053]
    end
end

function ChangeCardInfoDlg:addMoreMenu(sender)
    local btnLayer = cc.Layer:create()

    local y = self.button:getContentSize().height + self.button:getContentSize().height * 0.5
    local x = self.button:getContentSize().width * 0.5
    local res = self.button:clone()
    self:setLabelText("Label_16", CHS[3002848], res)
    res:setPosition(x, y)
    btnLayer:addChild(res)

    y = self.button:getContentSize().height + y


    if self.item and not InventoryMgr:isLimitedItem(self.item) and MarketMgr:isItemCanSell(self.item) then
        -- 摆摊
        local maill = self.button:clone()
        maill:setPosition(x, y)
        btnLayer:addChild(maill)
        y = self.button:getContentSize().height + y
        self:setLabelText("Label_16", CHS[7000301], maill)
    end

    local sell = self.button:clone()
    sell:setPosition(x, y)
    self:setLabelText("Label_16", CHS[3002816], sell)
    btnLayer:addChild(sell)
    y = self.button:getContentSize().height + y

    local save = self.button:clone()
    save:setPosition(x, y)
    self:setLabelText("Label_16", CHS[4100001], save)
    btnLayer:addChild(save)

    btnLayer:setTag(1)
    sender:addChild(btnLayer)
end

function ChangeCardInfoDlg:onMoreOperateButton(sender, eventType)
    if self.btnsShow then
        sender:removeChildByTag(1)
    else
        self:addMoreMenu(sender)
    end

    self.btnsShow = (not self.btnsShow)
end

function ChangeCardInfoDlg:onOperateButton(sender, eventType)
    if not self.item then return end
    InventoryMgr:applyChangCard(Me:getId(), self.item.pos)
    self:onCloseButton()
end

-- 设置显示存入格式   该存入是仓库，不是卡套
function ChangeCardInfoDlg:setStoreDisplayType()
    if not self.item then return end
    if self.item.pos < 200 then
        self:setLabelText("Label_16", CHS[4300070], "StoreButton")
    else
        self:setLabelText("Label_16", CHS[4300071], "StoreButton")
    end
    self:setCtrlVisible("BttonPanel", false)
    self:setCtrlVisible("DepositButton", false)
    self:setCtrlVisible("StorePanel", true)
end

-- 存入仓库
function ChangeCardInfoDlg:onStoreButton(sender, eventType)
    if not self.item then return end
    local str = self:getLabelText("Label_16", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.item.pos)
    else
        StoreMgr:cmdStoreToBag(self.item.pos)
    end
    self:onCloseButton()
end


function ChangeCardInfoDlg:onDepositButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self.item then return end
    local content = self:getLabelText("Label_16", sender)
    if content == CHS[7000301] then
        -- 摆摊等级限制
        local meLevel = Me:getLevel()
        if meLevel < MarketMgr:getOnSellLevel() then
            gf:ShowSmallTips(string.format(CHS[3002830], MarketMgr:getOnSellLevel()))
            return
        end

        local dlg = DlgMgr:openDlg("MarketSellDlg")
        MarketMgr:openSellItemDlg(self.item, 3)

        self:onCloseButton()
    elseif content == CHS[3002848] then
        -- 安全锁判断
        if self:checkSafeLockRelease("onDepositButton", sender) then
            return
        end

        local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(self.item))
        local str = ""

        if InventoryMgr:isLimitedItem(self.item) then
            str = string.format(CHS[6400051], value, CHS[6400050], self.item.name)
        else
            str = string.format(CHS[6400051], value, CHS[6400049], self.item.name)
        end

        gf:confirm(str,
        	function ()
                InventoryMgr.sellAllTipsFlag = {}
            	gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.item.pos, 1)
                self:onCloseButton()
            end)
    elseif content == CHS[3002816] then
        -- 物品处理
        if #InventoryMgr:getRescourse(self.item.name) == 0 then
            gf:ShowSmallTips(CHS[4000321])
            return
        end
        local rect = self:getBoundingBoxInWorldSpace(self.root)
        InventoryMgr:openItemRescourse(self.item.name, rect)
    elseif content == CHS[4100090] then
        StoreMgr:cmdBagToStoreForCard(self.item.pos)
        self:onCloseButton()
    end

end

return ChangeCardInfoDlg
