-- ItemInfoDlg.lua
-- Created by songcw Jan/9/2015
-- 物品悬浮对话框

local ItemInfoDlg = Singleton("ItemInfoDlg", Dialog)

local FONTSIZE = 20

local MORE_BTN = {
    CHS[5000201],
    CHS[7000301],
    CHS[5000203],
    CHS[6200078],
}

local BTN_FUNC = {
    [CHS[3002816]] = { normalClick = "onResourceButton" },
    [CHS[5000203]] = { normalClick = "onLianhua" },
    [CHS[7000301]] = { normalClick = "onBaitan" },
    [CHS[7000302]] = { normalClick = "onTreasureBaitan" },
    [CHS[5000201]] = { normalClick = "onSell", oneSecClick = "onSellAll" },
    [CHS[6200078]] = { normalClick = "onMail"}
}

local ALl_LIANZHI_ITEM_LIST =       -- 所有可炼化
    {
        [CHS[5000204]] = "",
        [CHS[5000205]] = "",
        [CHS[5000206]] = "",
        [CHS[5000207]] = "",
        [CHS[5000208]] = "",
        [CHS[5000209]] = "",
        [CHS[5000210]] = "",
        [CHS[5000211]] = "",
        [CHS[5000212]] = "",
        [CHS[5000213]] = "",
        [CHS[3004454]] = "",

        -- 如果值不为""，代表点击合成按钮链接到对应物品上，而非自己身上
        -- （eg 点击蓝松石的合成，打开合成界面默认选中芙蓉石）
        [CHS[4100421]] = CHS[4100422],
        [CHS[4100422]] = CHS[4100423],
        [CHS[4100423]] = CHS[4100424],

        [CHS[5410239]] = "", -- 火眼金睛·融合
        [CHS[5410240]] = "", -- 通天令牌·融合
        [CHS[5410241]] = "", -- 血玲珑·融合
        [CHS[5410242]] = "", -- 法玲珑·融合
        [CHS[5410243]] = "", -- 中级血玲珑·融合
        [CHS[5410244]] = "", -- 中级法玲珑·融合
        [CHS[3001144]] = CHS[5410239], -- 火眼金睛
        [CHS[7000081]] = CHS[5410240], -- 通天令牌
        [CHS[3001136]] = CHS[5410241], -- 血玲珑
        [CHS[3001139]] = CHS[5410242], -- 法玲珑
        [CHS[3001140]] = CHS[5410243], -- 中级血玲珑
        [CHS[3001141]] = CHS[5410244], -- 中级法玲珑
        [CHS[7120236]] = CHS[7120193], -- 竹马
        [CHS[7120237]] = CHS[7120194], -- 毽子
        [CHS[7120238]] = CHS[7120195], -- 蹴球
        [CHS[7120239]] = CHS[7120196], -- 弹弓
        [CHS[7120240]] = CHS[7120197], -- 陀螺
        [CHS[7120241]] = CHS[7120198], -- 风筝
        [CHS[7120242]] = CHS[7120193], -- 竹马
        [CHS[7120243]] = CHS[7120194], -- 毽子
        [CHS[7120244]] = CHS[7120195], -- 蹴球
        [CHS[7120245]] = CHS[7120196], -- 弹弓
        [CHS[7120246]] = CHS[7120197], -- 陀螺
        [CHS[7120247]] = CHS[7120198], -- 风筝
}

local NEED_CLOSE_BAG_ITEM = {
    [CHS[4010024]] = 1,
    [CHS[5400771]] = 1,
    [CHS[5400772]] = 1,
    [CHS[5400773]] = 1,
}

local SHOW_SELLALL_TIPS = 60

-- 不在包裹中的道具
local NOT_IN_BAG_ITEM = {
    [CHS[7190289]] = {useCmd = "CMD_MXAZ_USE_EXHIBIT"},  -- 小童叔叔的证词
    [CHS[7190290]] = {useCmd = "CMD_MXAZ_USE_EXHIBIT"},  -- 常舌馥的证词
    [CHS[7190291]] = {useCmd = "CMD_MXAZ_USE_EXHIBIT"},  -- 小童魂魄的证词
    [CHS[7190292]] = {useCmd = "CMD_MXAZ_USE_EXHIBIT"},  -- 迷仙镇训
    [CHS[7190293]] = {useCmd = "CMD_MXAZ_USE_EXHIBIT"},  -- 小童爷爷的证词
    [CHS[7190288]] = {tips = CHS[3000067]},  -- 尸检报告
    [CHS[7190296]] = {tips = CHS[3000067]},  -- 打铁的锤子
    [CHS[7190297]] = {tips = CHS[3000067]},  -- 信石药包
    [CHS[7190298]] = {tips = CHS[3000067]},  -- “父子草”药包
    [CHS[7190299]] = {tips = CHS[3000067]},  -- 叔叔家的肚兜
    [CHS[7190300]] = {tips = CHS[3000067]},  -- 带药粉的糖葫芦
}

function ItemInfoDlg:init()
    self.rootSize = self.rootSize or self.root:getContentSize()
    self.descPanelSize = self.descPanelSize or self:getControl("DescPanel"):getContentSize()
    self.funPanelSize = self.funPanelSize or self:getControl("FunPanel"):getContentSize()
    self.pricePanelSize = self.pricePanelSize or self:getControl("PricePanel"):getContentSize()
    self.limitPanelSize = self.limitPanelSize or self:getControl("LimitPanel"):getContentSize()
    self.mailPanelSize = self.mailPanelSize or self:getControl("MailPanel"):getContentSize()
    self.timeLimitPanelSize = self.timeLimitPanelSize or self:getControl("TimeLimitPanel"):getContentSize()

    self:bindListener("MoreButton", self.onSellButton)
    self:getControl("MoreButton"):setLocalZOrder(10)
    self:bindListener("ResourceButton", self.onResourceButton)
    self:bindListener("DepositButton", self.onDepositButton)
    self:bindListener("ResourceButton", self.onResourceButton, "StorePanel")
    --    self:bindListener("ApplyButton", self.onApplyButton)
    self:blindLongPress("ApplyButton", self.onApplyButtonOneSecondLater, self.onApplyButton)
    self:bindListener("ItemInfoDlg", self.onCloseButton)
    self:bindListener("PutInButton", self.onPutInButton)
    self:bindListener("PutOutButton", self.onPutOutButton)
    self:bindListener("ShareButton", self.onShareButton)
    self:bindListener("DressButton", self.onDressButton)  -- 自定义服装穿戴按钮

    -- 除描述信息之外的信息所占的高度
    local rootSize = self.root:getContentSize()
    local descSize = self:getControl("DescPanel"):getContentSize()
    self.elseContentHeight = rootSize.height - descSize.height
    self.contentWidth = rootSize.width

    -- 隐藏
    self:getControl("ApplyButton"):setVisible(false)
    self:setCtrlVisible("PutInButton", false)
    self:setCtrlVisible("PutOutButton", false)
    self:setCtrlVisible("StorePanel", false)
    self:setCtrlVisible("ShareButton", false)
    self.root:setAnchorPoint(0,0)


    self.btnTmp = self:getControl("MoreButton"):clone()
    self.btnTmp:retain()

    self.isShowSell = true
    self.isShowMore = true
    self.isShowUse = true
    self.isShowResource = true
    self.applyMedicineTime = 0

    self:hookMsg("MSG_INVENTORY")
end

function ItemInfoDlg:cleanup()
    self.isMore = false
    self:releaseCloneCtrl("btnTmp")
    self:releaseCloneCtrl("btnLayer")
    self.itemPos = nil
    self.item = nil
    self.itemName = nil
end

-- 配置道具名片上的按钮的显示
-- argTable.sell
-- argTable.use
-- argTable.resource
-- argTable.more
function ItemInfoDlg:setShowButtons(argTable)
    if argTable.sell == true then
        self.isShowSell = true
    else
        self.isShowSell = false
    end

    if argTable.use == true then
        self.isShowUse = true
    else
        self.isShowUse = false
    end

    if argTable.resource == true then
        self.isShowResource = true
    else
        self.isShowResource = false
    end

    if argTable.more then
        self.isShowMore = true
    else
        self.isShowMore = false
    end

    self:setCtrlVisible("ApplyButton", self.isShowUse)
    self:setCtrlVisible("MoreButton", self.isShowMore)
    --self:setCtrlVisible("ResourceButton", self.isShowResource)
    --self:getControl("ApplyButton"):setVisible(self.isShowSell)
    --self:getControl("ResourceButton"):setVisible(self.isShowResource)

end

function ItemInfoDlg:setInfoFormMe(pos)
    local item = InventoryMgr.inventory[pos]
    if not item then item = StoreMgr:getItemByPos(pos) end
    self.item = item
    self.itemPos = pos
    self.itemName = item.name

    local btn = self:getControl("ApplyButton")
    btn:setVisible(true)

    -- ItemInfo.lua中有配置cardUseButtonName的道具，需要显示为配置项
    local itemInfo = InventoryMgr:getItemInfoByName(item.name)
    if itemInfo.cardUseButtonName then
        self:setLabelText("Label_16", itemInfo.cardUseButtonName, btn)
    end

    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        self:setLabelText("Label_16", CHS[3002817], btn)
    elseif item.item_type == ITEM_TYPE.FOLLOW_ELF then
        self:setLabelText("Label_16", CHS[2000505], btn)
    elseif item.item_type == ITEM_TYPE.EFFECT or item.item_type == ITEM_TYPE.CUSTOM then
        self:setLabelText("Label_16", CHS[2100212], btn)
    elseif item.name == CHS[2500085] then
        self:setLabelText("Label_16", CHS[2500086], btn)
    end

    return self:setItemInfo(item)
end

-- 根据名片弹出道具悬浮框   item包含字段
-- Icon：图标
-- name：道具名
-- durability,  max_durability: 耐久度  ,最大耐久度
-- life_1，mana_1： 气血，法力
-- desc： 描述
-- price：出售价格
-- isShowDesc: 有这个字段表示不要显示描述
function ItemInfoDlg:setInfoFormCard(item)
    self.item = item
    self.itemPos = item.pos
    self.itemName = item.name

    local pet = PetMgr:getPetById(item.petId)
    if item.name == CHS[2500067] and pet then
        self:setCtrlVisible("ApplyButton", false)
        self:setCtrlVisible("MoreButton", false)
        self:setCtrlVisible("ResourceButton", false)

        local ride_attrib = pet:queryBasic("group_" .. GROUP_NO.FIELDS_MOUNT_ATTRIB)
        self:setCtrlVisible("PutInButton", not PetMgr:isCFZHStatus(pet))
        self:setCtrlVisible("PutOutButton", PetMgr:isCFZHStatus(pet))
    else
        self:setCtrlVisible("ApplyButton", false)
        self:setCtrlVisible("MoreButton", false)
        self:setCtrlVisible("ResourceButton", true)
        self:setCtrlVisible("PutInButton", false)
        self:setCtrlVisible("PutOutButton", false)
    end

    if item.time_limited then
        InventoryMgr:addLogoTimeLimit(self:getControl("ItemImage"))
    elseif item.limted then
        InventoryMgr:addLogoBinding(self:getControl("ItemImage"))
    end

    return self:setItemInfo(item, true)
end

-- 通过自定义服装界面打开
function ItemInfoDlg:setInfoFormCustom(item)
    self.item = item
    self.itemPos = item.pos
    self.itemName = item.name

    self:setCtrlVisible("ApplyButton", false)
    self:setCtrlVisible("MoreButton", false)
    self:setCtrlVisible("ResourceButton", false)
    self:setCtrlVisible("PutInButton", false)
    self:setCtrlVisible("PutOutButton", false)
    self:setCtrlVisible("DressButton", true)

    if self.itemPos and self.itemPos <= EQUIP.FASIONG_END then
        self:setLabelText("Label_16", CHS[5420303], "DressButton")
    else
        self:setLabelText("Label_16", CHS[5420302], "DressButton")
    end

    return self:setItemInfo(item, true)
end

function ItemInfoDlg:setInfoFormStore(item)
    self:setInfoFormCard(item)
    if item.pos < 200 then
        self:setLabelText("Label_16", CHS[4300070], "DepositButton")
    else
        self:setLabelText("Label_16", CHS[4300071], "DepositButton")
    end
    self:setCtrlVisible("ResourceButton", false)
    self:setCtrlVisible("StorePanel", true)
end


-- 设置物品悬浮框
function ItemInfoDlg:setItemInfo(item, isCard)
    if item.amount then
        self.amount = item.amount
    end

    self.applyMedicineTime = 0
    self.item = item

    if nil == InventoryMgr:getIconByName(item.name) then
        self:onCloseButton()
        gf:ShowSmallTips(string.format(CHS[3000111], item.name))
        return false
    end

    if not item.extra then
        item.extra = {}
    end

    self:setIcon(item)

    -- 将名称，等级信息保存在basicInfo中显示，第一个位置为名称，第二个位置优先是  "·" 后面内容，第三个等级
    local basicInfo = {}
    local pos = gf:findStrByByte(item.name, CHS[3002818])
    local name
    if pos then
        name = string.sub(item.name, 1, pos - 1)
    end

    if name == CHS[3002967] then --超级黑水晶
        table.insert(basicInfo, {content = name})
        table.insert(basicInfo, {content = string.sub(item.name, pos + 2, -1)})
    elseif item.alias and item.alias ~= "" then
        table.insert(basicInfo, {content = item.alias})
    else

        -- 部分礼包有  【xxxx】yyyy格式，也需要转化
        local pos = gf:findStrByByte(item.name, "】")
        if pos then
            name = string.sub(item.name, 1, pos + 2)
            table.insert(basicInfo, {content = string.sub(item.name, pos + 3, -1)})
            table.insert(basicInfo, {content = name})
        else
            local strName = item.alias ~= "" and item.alias or item.name
            table.insert(basicInfo, {content = strName})
        end
    end

    -- 等级
    if item.item_type == ITEM_TYPE.EQUIPMENT then
        -- 装备的话，显示req_level
        table.insert(basicInfo, {content = CHS[3002819] .. item.req_level})
    else
        if tonumber(item.level) and item.level and item.level > 0 then
            table.insert(basicInfo, {content = CHS[3002819] .. item.level})
        end
    end


    for i = 1, 3 do
        if basicInfo[i] then
            self:setLabelText("NameLabel" .. i, basicInfo[i].content)
            if i == 1 then
                local nameColor = item.color
                if not nameColor or nameColor == "" then
                    nameColor = InventoryMgr:getLocalConfigColor(basicInfo[i].content)
                end

                if nameColor then
                    local color = InventoryMgr:getItemColor({color = nameColor})
                    self:setLabelText("NameLabel" .. i, basicInfo[i].content, nil, color)
                end
            end
        else
            self:setLabelText("NameLabel" .. i, "")
        end
    end

    local panel = self:getControl("DescPanel")
    local statX, startY = panel:getPosition()
    panel:removeAllChildren()
    local oldSize = panel:getContentSize()

    -- 物品描述
    local descriptStr = ""

    if  not item["isShowDesc"] then
        descriptStr = InventoryMgr:getDescriptByItem(item)
        	end

    --[[
    if descriptStr ~= nil and descriptStr ~= "" then
    	descriptStr = descriptStr .. "\n \n"
    else
    	descriptStr = ""
    end
    --]]
    -- 其他描述（从外面自己传进来的描述）
    local descriptStr2 = ""

    if item["desc2"] then
        descriptStr2 = item["desc2"]
    end

    -- func
    local funStr  = ""
    local blackSpHeight = 0
    -- 黑水晶特殊处理
    if gf:findStrByByte(item.name, CHS[3002823]) then
        local funStr1 = CHS[3002824] .. EquipmentMgr:getEquipChs(item.upgrade_type)
        local funStr2 = ""
        for i,field in pairs(EquipmentMgr:getAllAttField()) do
            local str = field .. "_2"
            local bai = ""
            if EquipmentMgr:getAttribsTabByName(CHS[3002825])[field] then bai = "%" end
            local equip = {req_level = item.level, equip_type = item.upgrade_type}
            local maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if item.extra[str] then
                funStr2 = funStr2 .. EquipmentMgr:getAttribChsOrEng(field) .. " " .. item.extra[str] .. bai .. "/" .. maxValue .. bai .. " \n"
            end
        end

        local panel1 = self:getControl("FunPanel_1")
        local height1 = self:setDescript(funStr1 , panel1)
        panel1:setContentSize(self.funPanelSize.width, height1)

        local panel2 = self:getControl("FunPanel_2")
        local height2 = self:setDescript(funStr2 , panel2)
        panel2:setContentSize(self.funPanelSize.width, height2)

        blackSpHeight = height1 + height2 + 8
    elseif item.name == CHS[7000044] or item.name == CHS[7000045] then
        -- 经验心得/道武心得特殊处理

        -- 适用等级Panel
        local funcStr1 = InventoryMgr:getTryLevelTip(item)
        local panel1 = self:getControl("FunPanel_1")
        local height1 = self:setDescript(funcStr1 , panel1)
        panel1:setContentSize(self.funPanelSize.width, height1)

        -- 经验/道行与武学Panel
        local panel2 = self:getControl("FunPanel_2")
        local funcStr2 = InventoryMgr:getFuncStr(item)
        panel2:removeAllChildren()
        local textHSum = 0
        local textCtrls = gf:split(funcStr2, "\n")
        local funcStr2List = {}
        for i = 1, #textCtrls do
            if textCtrls[i] ~= "" then
                funcStr2List[i] = textCtrls[i]
            end
        end
        for i = 1, #funcStr2List do
            if textCtrls[i] == "" then
                break
            end

            local textCtrl = CGAColorTextList:create()
            textCtrl:setFontSize(FONTSIZE)
            textCtrl:setString(funcStr2List[i])
            textCtrl:setContentSize(panel2:getContentSize().width, 0)
            textCtrl:updateNow()

            -- 垂直方向居中显示
            local textW, textH = textCtrl:getRealSize()
            textCtrl:setPosition((panel2:getContentSize().width - textW) * 0.5,textH * (#funcStr2List - i + 1))

            panel2:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
            textHSum = textHSum + textH
        end
        panel2:setContentSize(self.funPanelSize.width, textHSum)

        blackSpHeight = height1 + textHSum + 8
    else
        funStr  = InventoryMgr:getFuncStr(item)

        -- 策划要求，名片界面，功能型描述行末的换行去掉(放在panel上，会导致panel增加一行的高度，名片显示异常)
        funStr = string.match(funStr, "(.+)\n$") or funStr

        if funStr ~= "" then
            funStr = funStr .. InventoryMgr:getTryLevelTip(item)
        else
            funStr = InventoryMgr:getTryLevelTip(item)
        end
        --if funStr ~= "" then funStr = funStr .. " \n"end
    end

    -- 出售价格
    local priceStr = InventoryMgr:getSellPriceStr(item)

    -- 界面设置
    -- 描述
    local panelDesc = self:getControl("DescPanel")
    local height1 = self:setDescript(descriptStr , panelDesc)
    panelDesc:setContentSize(self.descPanelSize.width, height1)

    local height2 = blackSpHeight
    -- 功能，要显示两个不同的功能时，另外处理
    if string.len(funStr) > 0 and string.len(descriptStr2) > 0 then
        local panel1 = self:getControl("FunPanel_1")
        local heightd = self:setDescript(descriptStr2 , panel1)
        panel1:setContentSize(self.funPanelSize.width, heightd)

        local panel2 = self:getControl("FunPanel_2")
        local heightf = self:setDescript(funStr , panel2)
        panel2:setContentSize(self.funPanelSize.width, heightf)

        height2 = height2 + heightd + heightf
    else
    local panelFun = self:getControl("FunPanel")
        local height1 = self:setDescript(descriptStr2 .. funStr, panelFun)
        height2 = height2 + height1
    panelFun:setContentSize(self.funPanelSize.width, height2)
    end

    -- 邮寄
    local mailPanel = self:getControl("MailPanel")
    local height5 = 0

--
    -- 加上"table"判断原因，item.attrib有可能时数字，（如为鉴定名片）
    if item.attrib and type(item.attrib) == "table" and item.attrib:isSet(ITEM_ATTRIB.ITEM_CAN_MAIL) then
         height5 = self:setDescript(CHS[6200092], mailPanel)
    end
    mailPanel:setContentSize(self.mailPanelSize.width, height5)
--]]

    -- 价格
    local panelPrice = self:getControl("PricePanel")
    local height3 = self:setDescript(priceStr, panelPrice)
    panelPrice:setContentSize(self.pricePanelSize.width, height3)
    -- 限制交易
    local limitTab = InventoryMgr:getLimitAtt(item, self:getControl("LimitTradeLabel"))
    local panelLimit = self:getControl("LimitPanel")
    local height4 = 0
    if next(limitTab) then
        height4 = self:setDescript(limitTab[1].str, panelLimit, limitTab[1].color)
        panelLimit:setContentSize(self.limitPanelSize.width, height4)
    end

    -- 限时道具
    local height6 = 0
    local panelTimeLimit = self:getControl("TimeLimitPanel")
    if InventoryMgr:isTimeLimitedItem(item) then
        local timeLimitStr
        if item.isTimeLimitedReward then
            timeLimitStr = CHS[7000100]
        else
            timeLimitStr = string.format(CHS[7000077], gf:getServerDate(CHS[4200022], item.deadline))
        end

        height6 = self:setDescript(timeLimitStr, panelTimeLimit)
        panelTimeLimit:setContentSize(self.timeLimitPanelSize.width, height6)
    end

    local height = self.rootSize.height - (self.descPanelSize.height - height1) - (self.pricePanelSize.height - height3)  -
        (self.funPanelSize.height - height2) - (self.limitPanelSize.height - height4) - (self.mailPanelSize.height - height5)
        - (self.timeLimitPanelSize.height - height6)
    self.root:setContentSize(self.contentWidth, height)
    self.itemName = item.name

    self.moreBtns = {}
    if self.btnLayer then
        self.btnLayer:removeFromParent(true)
        self.btnLayer = nil
    end

    -- 来  源
    table.insert(self.moreBtns, CHS[3002816])
    if ALl_LIANZHI_ITEM_LIST[item.name] then
        -- 炼制
        table.insert(self.moreBtns, CHS[5000203])
    end

    if item and gf:isExpensive(item) and MarketMgr:isShowGoldMarket() then
        -- 珍宝摆摊
        table.insert(self.moreBtns, CHS[7000302])
    end

    if not InventoryMgr:isLimitedItem(item) and MarketMgr:isItemCanSell(item) then
        -- 摆摊
        table.insert(self.moreBtns, CHS[7000301])
    end

    -- 邮寄
    if item.attrib and type(item.attrib) == "table" and item.attrib:isSet(ITEM_ATTRIB.ITEM_CAN_MAIL) and not item.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_SHOW_MAIL) then
        table.insert(self.moreBtns, CHS[6200078])
    end
    --]]

    -- 出售
    table.insert(self.moreBtns, CHS[5000201])

    -- 如果选项多于1个
    if #self.moreBtns > 1 then
        local btn = self:getControl("MoreButton")
        --btn:setTitleText(CHS[5000214])
        self:setLabelText("Label_19", CHS[5000214], btn)
        btn.isExpand = false
        --]]
    elseif 1 == #self.moreBtns then

    else
        self:setCtrlVisible("SellButton", false)
    end

    -- 邦定
    self:setCtrlVisible("BindStateLabel", false)
--
    -- 如果物品是邮寄属性，需要将使用按钮改成邮寄
    local itemInfo = InventoryMgr:getItemInfoByName(item.name)
    if not itemInfo.cardUseButtonName and item.attrib and type(item.attrib) == "table" and item.attrib:isSet(ITEM_ATTRIB.ITEM_APPLY_SHOW_MAIL) then
        self:setLabelText("Label_16", CHS[6200078], "ApplyButton")
    end
--]]
    local itemInfo = InventoryMgr:getItemInfoByName(item.name)
    self:setCtrlVisible("ShareButton", itemInfo.isShowShare and not isCard)
    return true
end

-- 设置物品Image
function ItemInfoDlg:setIcon(item)
    if item.name == CHS[7000014] then
        -- 针对活跃度宝箱，为其设置图标
        local image = self:getControl("ItemImage")
        image:loadTexture(ResMgr.ui.item_common, ccui.TextureResType.plistType)
        return
    end

    if InventoryMgr:getIsGuard(item.name) then
        local icon = InventoryMgr:getIconByName(item.name)
        self:setImage("ItemImage", ResMgr:getSmallPortrait(item.Icon or item.icon or icon))
        self:setItemImageSize("ItemImage")
    else
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(item.name)))
        self:setItemImageSize("ItemImage")
    end

    local img = self:getControl("ItemImage")
    if item and InventoryMgr:isTimeLimitedItem(item) then
        InventoryMgr:addLogoTimeLimit(img)
    elseif item and InventoryMgr:isLimitedItem(item) then
        InventoryMgr:addLogoBinding(img)
    end

    -- 融合标识
    if InventoryMgr:isFuseItem(item.name) then
        InventoryMgr:addLogoFuse(img)
    else
        InventoryMgr:removeLogoFuse(img)
    end
end

-- 设置物品function
function ItemInfoDlg:setItemFunc(itemFunc)
    self:setLabelText("FuntionLabel", itemFunc)
end

-- 设置物品出售价格
function ItemInfoDlg:setItemPrice(itemPrice)
    self:setLabelText("PriceLabel", itemPrice)
end

-- 设置物品描绘信息
function ItemInfoDlg:setDescript(descript, panel, defaultColor)
    panel:removeAllChildren()
    local textCtrl = CGAColorTextList:create()
    if defaultColor then textCtrl:setDefaultColor(defaultColor.r, defaultColor.g, defaultColor.b) end
    textCtrl:setFontSize(FONTSIZE)
    textCtrl:setString(descript)
    textCtrl:setContentSize(panel:getContentSize().width, 0)
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    textCtrl:setPosition((panel:getContentSize().width - textW) * 0.5,textH)

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            -- 处理类型点击
            gf:onCGAColorText(textCtrl)
            self:onCloseButton()
        end
    end
    panel:setTouchEnabled(true)
    panel:addTouchEventListener(ctrlTouch)
    return textH
end

function ItemInfoDlg:onSellButton(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    self.isMore = true
    if not self.isMore then
        local title = self:getLabelText("Label_19", sender)
        if BTN_FUNC[title] and "function" == type(self[BTN_FUNC[title].normalClick]) then
            self[BTN_FUNC[title].normalClick](self, sender, eventType)
        end
    else
        if sender.isExpand then
            self:getMoreLayer(self.moreBtns):removeFromParent(false)
            sender.isExpand = false
        else
            local contentSize = sender:getContentSize()
            self:getMoreLayer(self.moreBtns):setPosition(0, contentSize.height)
            sender:addChild(self:getMoreLayer(self.moreBtns))
            sender.isExpand = true
        end
    end

    self.applyMedicineTime = 0
end

-- 获取更多列表
function ItemInfoDlg:getMoreLayer(btn_list)
    if nil == self.btnLayer then
        local more_btn = {}
        if nil ~= btn_list then
            more_btn = btn_list
        else
            more_btn = MORE_BTN
        end

        self.btnLayer = cc.Layer:create()
        for i = 1, #more_btn do
            local sellBtn = self.btnTmp:clone()
            local contentSize = sellBtn:getContentSize()
            self:setLabelText("Label_19", more_btn[#more_btn - i + 1], sellBtn)
            -- sellBtn:setAnchorPoint(0, 0)
            sellBtn:setPosition(0 + contentSize.width / 2, contentSize.height * (i - 1) + contentSize.height / 2)
            self:blindLongPressWithCtrl(sellBtn, function(self, sender, eventType)
                local title = self:getLabelText("Label_19", sender)
                if BTN_FUNC[title].oneSecClick and "function" == type(self[BTN_FUNC[title].oneSecClick]) then
                    self[BTN_FUNC[title].oneSecClick](self, sender, eventType)
                end
            end
            , function(self, sender, eventType)
                --     local title = sender:getTitleText()
                local title = self:getLabelText("Label_19", sender)
                if BTN_FUNC[title].normalClick and "function" == type(self[BTN_FUNC[title].normalClick]) then
                    self[BTN_FUNC[title].normalClick](self, sender, eventType)
                end
            end, true)

            self.btnLayer:addChild(sellBtn)
        end

        self.btnLayer:retain()
    end

    return self.btnLayer
end

function ItemInfoDlg:onSell(sender, eventType)
    local item = InventoryMgr:getItemByPos(self.itemPos)

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(item)
        self:close()
        return
    end

    if not item then
        -- 从人物身上找不到物品
        self:onCloseButton()
        return
    end

    if gf:isExpensive(self.item) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    if self.item and self.item.name == CHS[2100149] and self.item.book_id ~= "" and self.item.book_id ~= Me:queryBasic("marriage/book_id") then
        gf:ShowSmallTips(CHS[4300459])
        ChatMgr:sendMiscMsg(CHS[4300459])
        return
    end

    local item = self.item
    if item.attrib and item.attrib:isSet(ITEM_ATTRIB.CANT_SELL) == true then
        gf:ShowSmallTips(CHS[3002828])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSell") then
        return
    end

    -- 未鉴定装备处理
    if item.item_type == ITEM_TYPE.EQUIPMENT and item.unidentified == 1 then
        local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item))
        local str = ""

        if InventoryMgr:isLimitedItem(item) then
            str = string.format(CHS[6400047], value, CHS[6400050], item.name)
        else
            str = string.format(CHS[6400047], value, CHS[6400049], item.name)
        end

        gf:confirm(str,
            function ()
                gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, item.pos, 1)
                InventoryMgr.sellAllTipsFlag = {}
                self:onCloseButton()
            end)
        return
    end

    -- 可堆叠的 带iid的道具
    if ITEM_COMBINED.ITEM_COMBINED_EX == item.combined then
        local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item))
        local str = ""

        if InventoryMgr:isLimitedItem(item) then
            str = string.format(CHS[6400048], value, CHS[6400050], InventoryMgr:getItemInfoByName(item.name).unit, item.name)
        else
            str = string.format(CHS[6400048], value, CHS[6400049], InventoryMgr:getItemInfoByName(item.name).unit, item.name)
        end

        gf:confirm(str,
            function ()
                gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, item.pos, 1)
                InventoryMgr.sellAllTipsFlag = {}
                self:onCloseButton()
            end)
        return
    end

    -- 对普通道具进行处理
    local value = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item))
    local str = ""

    if InventoryMgr:isLimitedItem(item) then
        str = string.format(CHS[6400047], value, CHS[6400050], item.name)
    else
        str = string.format(CHS[6400047], value, CHS[6400049], item.name)
    end

    gf:confirm(str,
        function ()
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, item.pos, 1)
            local nowTime = gf:getServerTime()

            -- 判断在一分钟之内是否连续（其间出售过其他物品不算作连续）进行了3次同物品的出售操作
            if  InventoryMgr.sellAllTipsFlag[item.name] == nil then
                InventoryMgr.sellAllTipsFlag = {}
                InventoryMgr.sellAllTipsFlag[item.name] = {}
                InventoryMgr.sellAllTipsFlag[item.name][1] = nowTime
            elseif InventoryMgr.sellAllTipsFlag[item.name][2] == nil then
                InventoryMgr.sellAllTipsFlag[item.name][2] = nowTime
            else
                local smaller = InventoryMgr.sellAllTipsFlag[item.name][1]
                local bigger = InventoryMgr.sellAllTipsFlag[item.name][2]
                local flag = nowTime - SHOW_SELLALL_TIPS

                if smaller >= flag and bigger >= flag then
                    if item.amount > 1 then
                        gf:ShowSmallTips(CHS[3002827])
                    end

                    InventoryMgr.sellAllTipsFlag[item.name] = nil
                elseif smaller < flag and bigger > flag then
                    InventoryMgr.sellAllTipsFlag[item.name][1] = bigger
                    InventoryMgr.sellAllTipsFlag[item.name][2] = nowTime
                elseif bigger <= flag then
                    InventoryMgr.sellAllTipsFlag[item.name][1] = nowTime
                    InventoryMgr.sellAllTipsFlag[item.name][2] = nil
                end
            end

            self:onCloseButton()
        end)

    self.applyMedicineTime = 0

end

function ItemInfoDlg:onSellAll(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if gf:isExpensive(self.item) then
        gf:ShowSmallTips(CHS[5420155])
        ChatMgr:sendMiscMsg(CHS[5420155])
        return
    end

    if nil == self.amount or type(self.amount) ~= "number" then
        return
    end

    if self.item and self.item.name == CHS[2100149] and self.item.book_id ~= "" and self.item.book_id ~= Me:queryBasic("marriage/book_id") then
        gf:ShowSmallTips(CHS[4300459])
        ChatMgr:sendMiscMsg(CHS[4300459])
        return
    end

    local item = self.item
    if item.attrib and item.attrib:isSet(ITEM_ATTRIB.CANT_SELL) == true then
        gf:ShowSmallTips(CHS[3002828])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSellAll") then
        return
    end

    local item = InventoryMgr:getItemByPos(self.itemPos)
    local pos = self.itemPos
    local amount = self.amount
    if ITEM_COMBINED.ITEM_COMBINED_EX == item.combined then
        amount = math.min(1, amount)
    end

    local moneyCount = gf:getMoneyDesc(InventoryMgr:getSellPriceValue(item) * amount)
    local moneyUnit = InventoryMgr:isLimitedItem(item) and CHS[6400050] or CHS[6400049]
    gf:confirm(string.format(CHS[3002829], moneyCount, moneyUnit, amount, InventoryMgr:getUnit(self.itemName), item.name),
        function()
            gf:sendGeneralNotifyCmd(NOTIFY.SELL_ITEM, pos, amount)
            self:onCloseButton()
        end)

    self.applyMedicineTime = 0
end

function ItemInfoDlg:onLianhua(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    local str = self.item.name
    if ALl_LIANZHI_ITEM_LIST[str] and ALl_LIANZHI_ITEM_LIST[str] ~= "" then
        str = ALl_LIANZHI_ITEM_LIST[str]
    end

    local level = tonumber(self.item.level)
    if level and level > 0 then
        str = str .. ":" .. tostring(level + 1)
    end

    if self.item and self.item.item_type == ITEM_TYPE.TOY then
        -- 娃娃玩家需要传入颜色
        str = str .. ":" .. self.item.color
    end

    DlgMgr:openDlgWithParam({"AlchemyDlg", str})
    self:onCloseButton()

    self.applyMedicineTime = 0
end

function ItemInfoDlg:onBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    if InventoryMgr:isLimitedItem(self.item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002830], MarketMgr:getOnSellLevel()))
        return
    end

    -- 耐久度检测
    if InventoryMgr:isUsedItem(self.item) then
        gf:ShowSmallTips(CHS[4200365])
        return
    end

    local item = {name = self.item.name, bagPos = self.item.pos, icon = self.item.icon, amount = self.item.amount, level = self.item.level, detail = self.item}
    local dlg = DlgMgr:openDlg("MarketSellDlg")
    dlg:setSelectItem(item.detail.pos)
    MarketMgr:openSellItemDlg(item.detail, 3)
    self:onCloseButton()

    self.applyMedicineTime = 0
end

function ItemInfoDlg:onTreasureBaitan(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    if InventoryMgr:isLimitedItem(self.item) then
        gf:ShowSmallTips(CHS[5000215])
        return
    end


    -- 摆摊等级限制
    local meLevel = Me:getLevel()
    if meLevel < MarketMgr:getGoldOnSellLevel() then
        gf:ShowSmallTips(string.format(CHS[3002830], MarketMgr:getGoldOnSellLevel()))
        return
    end

    local item = {name = self.item.name, bagPos = self.item.pos, icon = self.item.icon, amount = self.item.amount, level = self.item.level, detail = self.item}
    local dlg = DlgMgr:openDlg("MarketGoldSellDlg")
    dlg:setSelectItem(item.detail.pos)
    MarketMgr:openSellItemDlg(item.detail, 3, MarketMgr.TradeType.goldType)
    self:onCloseButton()
end

function ItemInfoDlg:onDepositButton(sender, eventType)
    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    local str = self:getLabelText("Label_16", sender)
    if str == CHS[4300070] then
        StoreMgr:cmdBagToStore(self.item.pos)
    else
        StoreMgr:cmdStoreToBag(self.item.pos)
    end
    self:onCloseButton()
end


function ItemInfoDlg:onResourceButton(sender, eventType)

    -- 如果是文曲星道具
    if DlgMgr:getDlgByName("WenqxDlg") then
        DlgMgr:sendMsg("WenqxDlg", "useItem")
        self:onCloseButton()
        return
    end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    local item = self.item
    local rect = self:getBoundingBoxInWorldSpace(self.root)

    -- 物品处理
    if #InventoryMgr:getRescourse(item.name) == 0 then
        gf:ShowSmallTips(CHS[4000321])
        return
    end

    local dlg
    if not string.match(item.name, CHS[3001225]) then
        dlg = InventoryMgr:openItemRescourse(item.name, rect, nil, item)
    else
        dlg = InventoryMgr:openItemRescourseByBlackCrystal(item, rect)
    end

    -- 保证道具来源界面层级高于本界面，点击道具来源界面本界面不会关闭
    if dlg then dlg:setDlgZOrder(self:getDlgZOrder() + 1) end

    self.applyMedicineTime = 0
end

function ItemInfoDlg:onApplyButtonOneSecondLater(sender, eventType)

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    local item = InventoryMgr:getItemByPos(self.itemPos)
    if not item then return end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local str = self:getLabelText("Label_16", sender)
    if str == CHS[6200078] then
        self:onMail()
        return
    end

    if self:checkItemCanApplyAll() then
        local amount = InventoryMgr:getAmountByPos(self.itemPos)
        local pos = self.itemPos
        gf:confirm(string.format(CHS[3002832], amount, InventoryMgr:getUnit(self.itemName), item.name), function()
            self:applyItem(item.name, pos, amount)  -- 使用该道具
            self:onCloseButton()
        end)
    end
end

function ItemInfoDlg:onPutInButton(sender, eventType)
    -- 可以注入
    local list = InventoryMgr:getItemByName(CHS[2500067])
    if not list or #list <= 0 then
        gf:ShowSmallTips(CHS[2500068])
        return
    end
    local pet = PetMgr:getPetById(self.item.petId)
    local mountType = pet:queryInt("mount_type")
    if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mountType then
        gf:ShowSmallTips(CHS[2000467])
        return
    end

    local capactityLevel = pet:queryInt("capacity_level")
    if capactityLevel < 5 then
        gf:ShowSmallTips(CHS[2500069])
        return
    end

    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[2000468])
        return
    end

    gf:CmdToServer('CMD_FEED_PET', { no = pet:queryBasicInt("no"), pos = list[1].pos })
    self:onCloseButton()
end

function ItemInfoDlg:onPutOutButton(sender, eventType)
    local pet = PetMgr:getPetById(self.item.petId)
    gf:CmdToServer('CMD_PET_DELETE_SOUL', { no = pet:queryBasicInt("no") })
    self:onCloseButton()
end

-- 自定义服装的穿戴、卸下
function ItemInfoDlg:onDressButton(sender, eventType)
    if self.itemPos and self.itemPos <= EQUIP.FASIONG_END then
        -- 卸下
        gf:CmdToServer("CMD_FASION_CUSTOM_UNEQUIP", { pos = self.itemPos })
        DlgMgr:sendMsg("CustomDressDlg", "cancleChooseItem", self.itemName)
    else
        -- 穿戴
        if not self.item or not self.item.amount or self.item.amount <= 0 then
            -- 没有获得该道具，无法穿戴
            gf:ShowSmallTips(string.format(CHS[2100195], self.itemName))
            return
        end

        local itemInfo = InventoryMgr:getItemInfoByName(self.itemName)
        if not itemInfo or (itemInfo.gender and itemInfo.gender ~= Me:queryBasicInt("gender")) then
            -- 当前形象与性别不符，无法换装
            gf:ShowSmallTips(CHS[2100196])
            return
        end

        gf:CmdToServer("CMD_FASION_CUSTOM_EQUIP", {equip_str = self.itemName})
    end

    self:onCloseButton()
end

function ItemInfoDlg:onShareButton(sender, eventType)
    if not self.item then return end
    if self.item.name == CHS[2100149] then
        local bookId = self.item.book_id
        local showInfo = string.format(string.format("{\29%s%s\29}", Me:getName(), CHS[2100156]))
        local sendInfo = string.format(string.format("{\t%s=%s=%s}", Me:queryBasic("gid"), CHS[2100149], bookId))

        local dlg = DlgMgr:openDlgEx("ShareChannelListExDlg", "JiNianCeDlg" .. self.item.name, nil, true)
        dlg:setShareText(showInfo, sendInfo)
        dlg:setPosWithDlg(self)
    elseif self.item.name == CHS[4300436] then
        local team = string.match(self.item.real_desc, "#R(.+)#n")
        local str = string.format(CHS[4300442], team)
        local showInfo = string.format(string.format("{\29%s\29}", str))
        local para = string.format("worldCupInfo:%s", team)
        local sendInfo = string.format(string.format("{\t%s=%s=%s}", str, "worldCupInfo", para))

        local dlg = DlgMgr:openDlgEx("ShareChannelListExDlg", "ShiJieBeiDlg" .. self.item.name, nil, true)
        dlg:setShareText(showInfo, sendInfo)
        dlg:setPosWithDlg(self)
    end
end

function ItemInfoDlg:checkItemCanApplyAll()
    -- 药品类，血池类，灵池类，驯兽诀类，鱼，菜肴
    local item = InventoryMgr:getItemByPos(self.itemPos)

    if item.item_type == ITEM_TYPE.MEDICINE
        or item.name == CHS[3002835]
        or gf:findStrByByte(item.name, CHS[3002834])
        or gf:findStrByByte(item.name, CHS[3002833])
        or item.item_type == ITEM_TYPE.FISH
        -- 菜肴特殊处理：人参鱼丸、灵芝鱼丸不能批量使用
        or (item.item_type == ITEM_TYPE.DISH and not string.match(item.name, CHS[2000378]) and  not string.match(item.name, CHS[2000379])) then
        	return true
    end

    return false
end

function ItemInfoDlg:onApplyButton(sender, eventType)
    if not self.item then return end

    if NOT_IN_BAG_ITEM[self.item.name] then
        -- 不在包裹中的道具，直接走通知服务器流程
        local cmd = NOT_IN_BAG_ITEM[self.item.name].useCmd
        if "CMD_MXAZ_USE_EXHIBIT" == cmd then
            gf:CmdToServer(cmd, { npcId = 0, name = self.item.name })
        end

        local tips = NOT_IN_BAG_ITEM[self.item.name].tips
        if tips then
            gf:ShowSmallTips(tips)
        end

        return
    end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    local item = InventoryMgr:getItemByPos(self.itemPos)
    if not item then return end

    -- ItemInfo.lua中有配置cmd的道具，直接走服务器判断流程
    local itemInfo = InventoryMgr:getItemInfoByName(item.name)
    if itemInfo.cmd then
        gf:CmdToServer(itemInfo.cmd, {taskName = itemInfo.taskName})
        self:onCloseButton()
        DlgMgr:closeDlg("BagDlg")
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local str = self:getLabelText("Label_16", sender)
    if str == CHS[6200078] then
        self:onMail()
        return
    end

    if item.name == CHS[4200378] then
       self:applyItemForJiuQu(item)
       return
    end

    -- 获取道具数量
    local count = InventoryMgr:getAmountByPos(self.itemPos)
    if self.itemPos then
        if self:checkItemCanApplyAll() then
            self.applyMedicineTime = self.applyMedicineTime + 1
            if self.applyMedicineTime == 3 then
                gf:ShowSmallTips(CHS[3002836])
                self.applyMedicineTime = 0
            end
        end
        self:applyItem(item.name, self.itemPos)  -- 使用该道具
    end

    if self.item and NEED_CLOSE_BAG_ITEM[self.item.name] then
        DlgMgr:closeDlg("BagDlg")
        DlgMgr:closeDlg(self.name)
        return
    end

    -- 获取所在位置的数量
    if item.amount == 1 then
        DlgMgr:closeDlg(self.name)
    end


end

-- 使用九曲玲珑笔，该表现和其他不一样！所特殊处理
-- 使用打开九曲玲珑笔界面（但是点击使用：界面不能关闭；走通用逻辑的话，未打开界面就提示战斗中不能使用。一些小的表现和其他不一样，所以在此单独抽出来特殊处理）
function ItemInfoDlg:applyItemForJiuQu(item)
    local dlg = DlgMgr:openDlg("ShapePenDlg", nil, true)
    dlg:setItem(item)

    local itemInfoDlg = DlgMgr:getDlgByName("ItemInfoDlg")
    if itemInfoDlg then
        local rect = self:getBoundingBoxInWorldSpace(self.root)
        dlg:setPositionByRect(rect)
    end
end

function ItemInfoDlg:applyItem(name, pos, amount)
    InventoryMgr:applyItem(pos, amount)  -- 使用该道具
end

function ItemInfoDlg:onMail()
    if not DistMgr:checkCrossDist() then return end

    -- 判断物品是否已经超时
    if InventoryMgr:isItemTimeout(self.item) then
        InventoryMgr:notifyItemTimeout(self.item)
        self:close()
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002958])
        return
    end

    local limitLevel = 30
    if Me:queryInt("level") < limitLevel then
        gf:ShowSmallTips(string.format(CHS[3004067], limitLevel))
        return
    end

    if InventoryMgr:isLimitedItem(self.item) and self.item and self.item.name ~= CHS[7100102] then
        gf:ShowSmallTips(CHS[6200083])
        return
    end

    local friends = FriendMgr:getFriends()
    if not friends or #friends == 0 then
        gf:ShowSmallTips(CHS[6200084])
        return
    end

    local name = self.item.name
    local dlg = DlgMgr:openDlg("SendMailDlg")
    dlg:initList(name)
end

function ItemInfoDlg:MSG_INVENTORY(data)
    for i = 1, data.count do
        if data[i].pos == self.itemPos and (not data[i].amount) then
            self:onCloseButton()
            return
        end
    end
end

function ItemInfoDlg:checkCloseDlg(param)
    if param[1] == self.itemName then
        return true
    end
end

return ItemInfoDlg
