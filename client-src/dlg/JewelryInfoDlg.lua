-- JewelryInfoDlg.lua
-- Created by songcw Feb/7/2015
-- 首饰悬浮框

local JewelryInfoDlg = Singleton("JewelryInfoDlg", Dialog)

--  CHS[4000090]:气血   CHS[4000110]:法力    CHS[4000032]:伤害
local MaterialAtt = {
    [EQUIP.BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},

    [EQUIP.BACK_BALDRIC] = {att = CHS[4000090], field = "max_life"},
    [EQUIP.BACK_NECKLACE] = {att =  CHS[4000110], field = "max_mana"},
    [EQUIP.BACK_LEFT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
    [EQUIP.BACK_RIGHT_WRIST] = {att =  CHS[4000032], field = "phy_power"},
}

--     [4000116] = "纹龙佩",    [4000117] = "青珑挂珠",    [4000118] = "金刚手镯"
local JewelryInit = {
    [EQUIP.BALDRIC] = CHS[4000116],
    [EQUIP.NECKLACE] = CHS[4000117],
    [EQUIP.LEFT_WRIST] = CHS[4000118],
    [EQUIP.RIGHT_WRIST] = CHS[4000118],
}

local MORE_BTN = {
    CHS[3002869],
    CHS[3002870],
    CHS[3002871],
    CHS[3002872]
}

local BTN_FUNC = {
    [CHS[3002869]] = { normalClick = "onSell" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[7000302]] = { normalClick = "onTreasureBaitan" },
    [CHS[3002871]] = { normalClick = "onCompound" },
    [CHS[3002872]] = { normalClick = "onSource" },
}


local BTN_EQUIP = {
     { name = CHS[3002873], normalClick = "onEquipRight" },
     { name = CHS[3002874], normalClick = "onEquipLeft" },
}

function JewelryInfoDlg:init()
    self:bindListener("MoreOperateButton", self.onMoreOperateButton)
    self:bindListener("OperateButton", self.onOperateButton)
    self:bindListener("MainPanel", self.onCloseButton)
    self:bindListener("SourceButton", self.onSource)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("ResourceButton", self.onSource)

    self.bodySize = self.bodySize or self:getControl("MainPanel"):getContentSize()

    self:setCtrlVisible("SourceButton", false)
    self:setCtrlVisible("StorePanel", false)

    self.btn = self:getControl("MoreOperateButton"):clone()
    self.btn:setVisible(true)
    -- self.btn:setAnchorPoint(0, 0)
    self.btn:retain()

    self.btnLayer = cc.Layer:create()
    self.btnLayer:setAnchorPoint(0, 0)
    self.btnLayer:retain()

    self.menuMore = {}
    self.root:setAnchorPoint(0,0)
    self.blank:setLocalZOrder(Const.ZORDER_FLOATING)

    self:hookMsg("MSG_INVENTORY")
end

function JewelryInfoDlg:cleanup()
    if self.btnLayer then
        self.btnLayer:release()
        self.btnLayer = nil
    end

    if self.btn then
        self.btn:release()
        self.btn = nil
    end

    self.isMore = nil

    DlgMgr:closeDlg("ItemRecourseDlg")
end

function JewelryInfoDlg:getInitJewelry(pos, name)
    local jewelry =  EquipmentMgr:getComposeJewelryInfoByName(name)
    local equip = {
            name = name,
            req_level = jewelry.req_level,
            equip_type = pos,
            extra = jewelry.extra,
            color = CHS[3002402],
        }

    return equip
end

-- 从自己身上获取，若没有首饰，则setJewelryInfo(nil, pos)，传入位子会自己构造初级装备
function JewelryInfoDlg:setJewelryInfo(equip, pos, isCard)
    if equip == nil then
        local attValueStr = string.format("%s_%d", MaterialAtt[pos].field, Const.FIELDS_NORMAL)
        equip = {
            name = JewelryInit[pos],
            req_level = 20,
            pos = pos,
            extra = {
                max_life_1 = 396,
                max_mana_1 = 264,
                phy_power_1 = 76,
                phy_power_1 = 76,
            }
        }
    end

    self.equip = equip

    self:setCtrlVisible("OperateButton", not isCard)
    self:setCtrlVisible("WearImage", not isCard)
    self:setCtrlVisible("SourceButton", isCard)
    self:setCtrlVisible("MoreOperateButton", not isCard)

    if equip.pos then
        if (equip.pos <= EQUIP.BACK_RIGHT_WRIST) then
            self:setButtonText("OperateButton", CHS[3002875])
        else
            self:setButtonText("OperateButton", CHS[3002876])
        end
        self:setCtrlVisible("WearImage", (equip.pos <= 10))
    end

    self.menuMore = self:setMenuMore(isCard, equip)
    if #self.menuMore == 1 and self.menuMore[1] == CHS[3002872] then
        self:setButtonText("MoreOperateButton", CHS[3002872])
    end

    -- 图片
    self:setImage("ItemImage", InventoryMgr:getIconFileByName(equip.name))
    self:setItemImageSize("ItemImage")
    self:setNumImgForPanel("JewelryShapePanel", ART_FONT_COLOR.NORMAL_TEXT, equip.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 是否可以交易标志， 暂时隐藏
    self:setCtrlVisible("ExChangeImage", false, self:getControl("JewelryShapePanel"))
    if equip and InventoryMgr:isLimitedItem(equip) then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"))
    end

    -- 贵重物品
    if gf:isExpensive(equip, false) then
        self:setCtrlVisible("PreciousImage", true)
    else
        self:setCtrlVisible("PreciousImage", false)
    end

    -- 名称
    local color = InventoryMgr:getItemColor(equip)
    self:setLabelText("NameLabel", equip.name, nil, color)
    -- 描述
    self:setLabelText("DescLabel", InventoryMgr:getDescript(equip.name))
    -- 等级
    self:setLabelText("LevelValueLabel", equip.req_level)
    -- 属性

    if pos == nil then
        pos = equip.pos
    end

    local totalAtt = {}
    local _1, _2, funStr = EquipmentMgr:getJewelryAttributeInfo(equip)
    table.insert(totalAtt, {str = funStr, color = COLOR3.LIGHT_WHITE})

    -- 部位和强化等级
    --- 如果没有强化的，原强化label需要显示部位
    local developStr, devLevel, devCom = EquipmentMgr:getJewelryDevelopInfo(equip)
    if devLevel == 0 and devCom == 0 then
                    -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            self:setLabelText("DevelopLevelLabel", CHS[3002877], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            self:setLabelText("DevelopLevelLabel", CHS[3002878], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            self:setLabelText("DevelopLevelLabel", CHS[3002879], nil, COLOR3.LIGHT_WHITE)
        end

        self:setLabelText("CommondLabel", "", nil, COLOR3.LIGHT_WHITE)
    else
        -- 强化
        self:setLabelText("DevelopLevelLabel", developStr, nil, COLOR3.BLUE)

            -- 部位
        if equip.equip_type == EQUIP.BALDRIC then
            self:setLabelText("CommondLabel", CHS[3002877], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.NECKLACE then
            self:setLabelText("CommondLabel", CHS[3002878], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.LEFT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], nil, COLOR3.LIGHT_WHITE)
        elseif equip.equip_type == EQUIP.RIGHT_WRIST then
            self:setLabelText("CommondLabel", CHS[3002879], nil, COLOR3.LIGHT_WHITE)
        end
    end



    local blueAtt = EquipmentMgr:getJewelryBule(equip)
    for i = 1,#blueAtt do
        table.insert(totalAtt, {str = blueAtt[i], color = COLOR3.BLUE})
    end

    -- 转换次数
    if equip.transform_num and equip.transform_num > 0 then
        table.insert(totalAtt, {str = string.format(CHS[4010062], equip.transform_num), color = COLOR3.LIGHT_WHITE})
    end

    -- 冷却时间
    if EquipmentMgr:isCoolTimed(equip) then
        table.insert(totalAtt, {str = string.format(CHS[4010063], EquipmentMgr:getCoolTimedByDay(equip)), color = COLOR3.LIGHT_WHITE})
    end


    -- 限定交易
    local limitTab = InventoryMgr:getLimitAtt(equip, self:getControl("ExChangeLabel"))
    if next(limitTab) then
        table.insert(totalAtt, {str = limitTab[1].str, color = COLOR3.RED})
    end

    for i = 1, Const.JEWELRY_ATTRIB_MAX do
        self:setLabelText("AttribLabel" .. i, "", "DescPanel")
    end

    for i = 1, #totalAtt do

        local panel = self:getControl("AttribPanel" .. i, nil, "DescPanel")
        if panel then
            self:setColorTextEx(totalAtt[i].str, panel, totalAtt[i].color)
        else
            self:setLabelText("AttribLabel" .. i, totalAtt[i].str, "DescPanel", totalAtt[i].color)
        end
    end

    local cutHeight = (Const.JEWELRY_ATTRIB_MAX - #totalAtt) * 32
    self:getControl("MainPanel"):setContentSize(self.bodySize.width, self.bodySize.height - cutHeight)
    self.root:setContentSize(self.bodySize.width, self.bodySize.height - cutHeight)
    self:updateLayout("MainPanel")
end

-- 从名片中获取，传入名字，等级，属性值，分数
function JewelryInfoDlg:setJewelryInfoFromCard(name, level, pos, attValue, score)
    local attValueStr = string.format("%s_%d", MaterialAtt[pos].field, Const.FIELDS_NORMAL)
    local equip = {name = name, req_level = level, pos = pos, fromCardValue = attValue, score = score, extra = {}}
    self:setJewelryInfo(equip)
end

-- 设置显示存入格式
function JewelryInfoDlg:setStoreDisplayType()
    if not self.equip then return end
    if self.equip.pos < 200 then
        self:setLabelText("Label_16", CHS[4300070], "DepositButton")
    else
        self:setLabelText("Label_16", CHS[4300071], "DepositButton")
    end
    self:setCtrlVisible("SourceButton", false)
    self:setCtrlVisible("MoreOperateButton", false)
    self:setCtrlVisible("OperateButton", false)
    self:setCtrlVisible("StorePanel", true)
end

function JewelryInfoDlg:onResourceButton(sender, eventType)
    self:onCloseButton()
    local level = Me:queryBasicInt("level")
    if level < 35 then
        gf:ShowSmallTips(CHS[3002880])
        return
    end

    DlgMgr:openDlg("JewelryMakeDlg")
    DlgMgr:sendMsg("EquipmentChildDlg", "setEquipmentSelected", sender:getTag())
end

function JewelryInfoDlg:onOperateButton(sender, eventType)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002881])
        return
    end

    local str = sender:getTitleText()
    if str == CHS[3002882] or str == CHS[3002876] then
        -- 添加左右手镯
        if self.equip.equip_type == EQUIP_TYPE.WRIST then
            local layer = ccui.Layout:create()
            local btnSize = self.btn:getContentSize()
            for i = 1, #BTN_EQUIP do
                local btn = self.btn:clone()
                btn:setTitleText(tostring(BTN_EQUIP[i].name))
                btn:setPosition(btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
                layer:addChild(btn)

                self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                    local title = sender:getTitleText()
                    if BTN_EQUIP[i].normalClick and "function" == type(self[BTN_EQUIP[i].normalClick]) then
                        self[BTN_EQUIP[i].normalClick](self, sender, eventType)
                    end
                end)
            end

            layer:setAnchorPoint(0, 0)
            layer:setPosition(0, 0)
            sender:addChild(layer)
            return
        else
            EquipmentMgr:getGuideNextEquip(self.equip)
            EquipmentMgr:CMD_EQUIP(self.equip.pos)
        end

    else
        EquipmentMgr:CMD_UNEQUIP(self.equip.pos)
    end

    self:onCloseButton()
end

function JewelryInfoDlg:onEquipLeft()
    EquipmentMgr:getGuideNextEquip(self.equip)

    EquipmentMgr:CMD_EQUIP(self.equip.pos, EQUIP.LEFT_WRIST)
    self:onCloseButton()
end

function JewelryInfoDlg:onEquipRight()
    EquipmentMgr:getGuideNextEquip(self.equip)

    EquipmentMgr:CMD_EQUIP(self.equip.pos, EQUIP.RIGHT_WRIST)
    self:onCloseButton()
end

function JewelryInfoDlg:setMenuMore(isCard, equip)
    local menuTab = {}
    local isInBag = equip.pos and InventoryMgr:isInBagByPos(equip.pos)
    if not isCard then
        if isInBag then
        table.insert(menuTab, CHS[3002869])
        table.insert(menuTab, CHS[7000301])

            if self.equip and gf:isExpensive(self.equip) and MarketMgr:isShowGoldMarket() then
            table.insert(menuTab, CHS[7000302])
        end

        if self.equip and self.equip.pos > EQUIP.BACK_RIGHT_WRIST and Me:queryBasicInt("level") >= EquipmentMgr:getJewelryLevel() then
            table.insert(menuTab, CHS[3002871])
        end
        end

        -- 创建分享按钮
        self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.EQUIPATTRIB)
    else
        self:setCtrlVisible("ShareButton", false)
    end

    table.insert(menuTab, CHS[3002872])

    return menuTab
end

function JewelryInfoDlg:onMoreOperateButton(sender, eventType)
    if CHS[3002872] == sender:getTitleText() then
        self:onSource()
        return
    end

    local tag = sender:getTag()
    if not self.isMore or self.btnLayer:getTag() ~= tag then
        self.isMore = true
        local btnSize = self.btn:getContentSize()
        for i,v in pairs(self.menuMore) do
            local btn = self.btn:clone()
            btn:setTitleText(tostring(v))
            btn:setPosition(0 + btnSize.width / 2, btnSize.height * i + btnSize.height / 2)
            self.btnLayer:addChild(btn)

            self:bindTouchEndEventListener(btn, function(self, sender, eventType)
                local title = sender:getTitleText()
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end)
        end
        self.btnLayer:setPosition(0, 0)
        self.btnLayer:removeFromParent()
        self.btnLayer:setTag(tag)
        sender:addChild(self.btnLayer)
    else
        self.isMore = false
        self.btnLayer:removeFromParent()
    end
end

-- 出售
function JewelryInfoDlg:onSell(sender, eventType)
    -- 判断是否处于公示期
    if Me:isInTradingShowState() then
        gf:ShowSmallTips(CHS[4300227])
        return
    end


    local tag = self.btnLayer:getTag()
    if self.equip.pos <= EQUIP.BACK_RIGHT_WRIST then
        gf:ShowSmallTips(CHS[3002883])
        return
    end

    if gf:isExpensive(self.equip) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(self.equip))
    local str = ""

    if InventoryMgr:isLimitedItem(self.equip) then
        str = string.format(CHS[6400047], value, CHS[6400050], self.equip.name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], self.equip.name)
    end

    gf:confirm(str,
        function ()
            InventoryMgr.sellAllTipsFlag = {}
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, self.equip.pos, 1)
            self:onCloseButton()
        end)
end

-- 摆摊
function JewelryInfoDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local tag = self.btnLayer:getTag()
    if self.equip.pos <= EQUIP.BACK_RIGHT_WRIST then
        gf:ShowSmallTips(CHS[3002885])
        return
    end

    if InventoryMgr:isLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002886], MarketMgr:getOnSellLevel()))
        return
    end

    local item = {name = self.equip.name, bagPos = self.equip.pos, icon = self.equip.icon, amount = self.equip.amount, level = self.equip.level, detail = self.equip}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.pos)
    MarketMgr:openSellItemDlg(item.detail, 3)

    self:onCloseButton()
end

-- 珍宝摆摊
function JewelryInfoDlg:onTreasureBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    local tag = self.btnLayer:getTag()
    if self.equip.pos <= EQUIP.BACK_RIGHT_WRIST then
        gf:ShowSmallTips(CHS[3002885])
        return
    end

    if InventoryMgr:isLimitedItem(self.equip) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002886], MarketMgr:getGoldOnSellLevel()))
        return
    end

    local item = {name = self.equip.name, bagPos = self.equip.pos, icon = self.equip.icon, amount = self.equip.amount, level = self.equip.level, detail = self.equip}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(item.pos)

    MarketMgr:openZhenbaoSellDlg(self.equip)
    self:onCloseButton()
end

-- 合成
function JewelryInfoDlg:onCompound(sender, eventType)
    local dlg = DlgMgr:openDlg("JewelryUpgradeDlg")
    dlg:setJewelry(self.equip)
    self:onCloseButton()
end

-- 存入
function JewelryInfoDlg:onDepositButton(sender, eventType)
    if not self.equip then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local str = self:getLabelText("Label_16", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.equip.pos)
    else
        StoreMgr:cmdStoreToBag(self.equip.pos)
    end
    self:onCloseButton()
end

-- 来源
function JewelryInfoDlg:onSource(sender, eventType)

    if not self.equip then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    -- 物品处理
    if #InventoryMgr:getRescourse(self.equip.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(self.root)
    InventoryMgr:openItemRescourse(self.equip.name, rect)

end

function JewelryInfoDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        if not self.equip or data[i].pos == self.equip.pos then
            self:onCloseButton()
            return
        end
    end
end

return JewelryInfoDlg
