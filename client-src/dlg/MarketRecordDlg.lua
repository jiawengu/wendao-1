-- MarketRecordDlg.lua
-- Created by liuhb Apr/22/2015
-- 记录界面

local MarketRecordDlg = Singleton("MarketRecordDlg", Dialog)
local DataObject = require('core/DataObject')

local listViewConfig =
{
    VerifyRecordButton = "VerifyListView",
    SellRecordButton =  "SellListView",
    BuyRecordButton = "BuyListView",
}

MarketRecordDlg.cardInfo = {}

function MarketRecordDlg:init()
    self:bindListener("VerifyRecordButton", self.swichListView)
    self:bindListener("SellRecordButton", self.swichListView)
    self:bindListener("BuyRecordButton", self.swichListView)

    self.defaultGid = nil
    self.selectType = nil
    -- 初始化界面
    self:initView()

    -- 请求历史数据
    MarketMgr:requestHistoryInfo(self:tradeType())
end

function MarketRecordDlg:initView()
    self.itemCtrl = self:getControl("ItemPanel")
    self.itemCtrl:retain()
    self.itemCtrl:removeFromParentAndCleanup()

    self:bindListener("IconPanel", self.onShowCard, self.itemCtrl)

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self.curSelectButton = "VerifyRecordButton"

    self:setTradeTypeUI()

    -- 设置所有hook消息
    self:setAllHookMsgs()
end

function MarketRecordDlg:viewItem(data)
    gf:CmdToServer("CMD_STALL_RECORD_DETAIL", data);
end

function MarketRecordDlg:onShowCard(sender, envetType)
    local parent = sender:getParent()
    local item = parent.item
    if not item then return end
    if item.stall_item_type == TRANSFER_ITEM_TYPE.CASH then
        local dlg = DlgMgr:openDlg("BonusInfoDlg")
        local rewardInfo = {["basicInfo"] = {CHS[3002690]},["desc"] = CHS[3002144],["imagePath"] = "Icon0072.png",["limted"] = false,["resType"] = 1,["time_limited"] = false}
        dlg:setRewardInfo(rewardInfo)
        dlg.root:setAnchorPoint(0, 0)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        dlg:setFloatingFramePos(rect)
        return
    end

    if item.record_id == "" then
        gf:ShowSmallTips(CHS[4400034])
        return
    end

    MarketMgr:setOpenType(MARKET_CARD_TYPE.FLOAT_DLG)
    if self.cardInfo[item.record_id] then
        self:MSG_STALL_RECORD_DETAIL(self.cardInfo[item.record_id])
    else
        self:viewItem({record_id = item.record_id})
    end
end

-- 设置所有hook消息
function MarketRecordDlg:setAllHookMsgs()
    self:hookMsg("MSG_STALL_RECORD")
    self:hookMsg("MSG_STALL_RECORD_DETAIL")
end

function MarketRecordDlg:setTradeTypeUI()
    -- 设置商品单元格为货币为金元宝
    self:setCtrlVisible("GoldImage", false, self.itemCtrl)
    self:setCtrlVisible("CoinImage", true, self.itemCtrl)
end

function MarketRecordDlg:cleanup()
    self:releaseCloneCtrl("itemCtrl")
    self:releaseCloneCtrl("itemSelectImg")
end

function MarketRecordDlg:swichListView(sender, envetType)
    local name = sender:getName()
    self.selectType = name
    local curlist = self:getControl(listViewConfig[name])
    local btn = self:getControl( self.curSelectButton)
    self:setCtrlVisible("Image", false, btn)
    self.curSelectButton = name
    self:setCtrlVisible("Image", true, sender)


    if curlist and #curlist:getItems() > 0 then
        self:changeView(name)
    else
        self:updateViewData()
    end
end

function MarketRecordDlg:updateViewData()
    self:changeView(self.curSelectButton)

    for k, v in pairs(listViewConfig) do
        local list = self:getControl(v)
        if self.curSelectButton == k then
            local data = self:getListViewData(v)

            if  data and  #data > 0 then
                list:setVisible(true)
                self:updateOneViewData(list, data)
            end
        else
            list:setVisible(false)
        end
    end

end

function MarketRecordDlg:getListViewData(key)
    local data = {}
    if key == "SellListView" then
        data = MarketMgr:getSellItemListRecord(self:tradeType())
    elseif key == "BuyListView" then
        data = MarketMgr:getBuyItemListRecord(self:tradeType())
    elseif key == "VerifyListView" then
        data = MarketMgr:getVerifyItemRecord(self:tradeType())
    end
    return data
end

function MarketRecordDlg:changeView(name)
    for k, v in pairs(listViewConfig) do
        local list = self:getControl(v)
        if name == k then
            local data = self:getListViewData(v)

            if not data or #data == 0 then
                self:setCtrlVisible("NoticePanel", true)
            else
                self:setCtrlVisible("NoticePanel", false)
                list:setVisible(true)
            end

            self:setTileInfo(v)
        else
            list:setVisible(false)
        end
    end
end

function MarketRecordDlg:setTileInfo(key)
    local infoPanel = self:getControl("InfoPanel")
    local listTitlePanel = self:getControl("ListTitlePanel")
    local leftTimelable = self:getControl("Label3", nil, listTitlePanel)
    local str = ""
    if key == "SellListView" then
        str = CHS[6000225]
        self:setCtrlVisible("InfoLabel1", false, infoPanel)
        self:setCtrlVisible("InfoLabel2", true, infoPanel)

        if MarketMgr.sellDataInfo then
            self:setLabelText("InfoLabel2", string.format( CHS[4400048], MarketMgr.sellDataInfo.record_count_max), infoPanel)
        end
    elseif key == "BuyListView" then
        str = CHS[6000226]
        self:setCtrlVisible("InfoLabel1", false, infoPanel)
        self:setCtrlVisible("InfoLabel2", true, infoPanel)

        if MarketMgr.sellDataInfo then
            self:setLabelText("InfoLabel2", string.format( CHS[4400045], MarketMgr.sellDataInfo.record_count_max), infoPanel)
        end
    elseif key == "VerifyListView" then
        str = CHS[6000227]
        self:setCtrlVisible("InfoLabel1", true, infoPanel)
        self:setCtrlVisible("InfoLabel2", false, infoPanel)
    end

    leftTimelable:setString(str)
end

-- 更新一个ListView
function MarketRecordDlg:updateOneViewData(listViewCtrl, items)
    listViewCtrl:removeAllItems()

    for i = 1, #items do
        listViewCtrl:pushBackCustomItem(self:createOneItem(items[i], listViewCtrl:getName(), i))
    end
end

function MarketRecordDlg:createOneItem(item, listViewName, index)
    local itemCtrl = self.itemCtrl:clone()

    itemCtrl.item = item

    local isMoneyGood = item.stall_item_type == TRANSFER_ITEM_TYPE.CASH

    -- 索引
    self:setLabelText("NumLabel", index, itemCtrl)

    -- 带属性超级黑水晶
    if string.match(item.name, CHS[3003018]) then
        local name = string.gsub(item.name, CHS[3003019],"")
        local list = gf:split(name, "|")
        self:setLabelText("NameLabel", list[1], itemCtrl)
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = item.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003020])[field] then bai = "%" end
        end

        local valueText = value .. bai .. "/" .. maxValue .. bai
        self:setLabelText("OneNameLabel", list[1] .. CHS[3003588] .. valueText, itemCtrl)
    elseif isMoneyGood then
        local sellMoney = tonumber(item.name)
        local cashText, fontColor = gf:getArtFontMoneyDesc(sellMoney)
        self:setNumImgForPanel("MoneyNamePanel", fontColor, cashText, false, LOCATE_POSITION.CENTER, 21, itemCtrl)
    else

        -- 名字
        self:setLabelText("OneNameLabel", PetMgr:trimPetRawName(item.name), itemCtrl)
    end


    MarketMgr:setSellBuyTypeFlag(item.buy_type, self, itemCtrl)
    --self:setLabelText("OneNameLabel", item.name, itemCtrl)

    if 0 == item.level then
        self:setLabelText("LevelLabel", "", itemCtrl)
    else
        self:setLabelText("LevelLabel", item.level, itemCtrl)
    end

    if item.req_level and item.req_level > 0 then
        self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21, itemCtrl)
    end

    if item.item_polar and item.item_polar >= 1 and item.item_polar <= 5 then
        if item.level and item.level > 0 then
            -- 如果是法宝，要在左上角显示法宝等级
            self:setNumImgForPanel("IconPanel", ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21, itemCtrl)
        end
    end

    if item.status == 5 and listViewName == "VerifyListView" then -- 审核中
        local leftTime = item.endTime - gf:getServerTime()
        local timeStr =  MarketMgr:getTimeStr(leftTime, 2)
        self:setLabelText("TimeLabel1",timeStr, itemCtrl)
        self:setCtrlVisible("TimeLabel2", false, itemCtrl)
    else
        self:setLabelText("TimeLabel1", gf:getServerDate(CHS[4300233], item.time), itemCtrl)
        self:setLabelText("TimeLabel2", gf:getServerDate("%H:%M", item.time), itemCtrl)
    end

    -- 设置角色身上的金钱

    local cashText, color = gf:getMoneyDesc(item.price, true)
    self:setLabelText("CoinLabel", cashText, itemCtrl, color)
    self:setLabelText("CoinLabel2", cashText, itemCtrl)

    -- 设置Icon
    local imgPath
    if PetMgr:getPetIcon(item.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(item.name))
    else
        local icon = InventoryMgr:getIconByName(item.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    if isMoneyGood then
        self:setImagePlist("IconImage", ResMgr.ui.big_cash, itemCtrl)
    else
        self:setImage("IconImage", imgPath, itemCtrl)
    end

    self:setItemImageSize("IconImage", itemCtrl)

    if item.item_polar then
        InventoryMgr:addArtifactPolarImage(self:getControl("IconImage", nil, itemCtrl), item.item_polar)
    end

    if listViewName == "SellListView" then
        if item.status == 4 then -- 冻结
            self:setCtrlVisible("TipImage", true, itemCtrl)
            self:setCtrlVisible("BackImage1", false, itemCtrl)
            self:setCtrlVisible("BackImage2", false, itemCtrl)
            self:setCtrlVisible("Label1", false, itemCtrl)
            self:setCtrlVisible("Label2", false, itemCtrl)
        elseif item.status == 5  then -- 审核中
            self:setCtrlVisible("BackImage1", false, itemCtrl)
            self:setCtrlVisible("Label1", false, itemCtrl)
            self:setCtrlVisible("BackImage2", true, itemCtrl)
            self:setCtrlVisible("Label2", true, itemCtrl)
        elseif item.status == 7 then -- 审核未通过
            self:setCtrlVisible("BackImage1", true, itemCtrl)
            self:setCtrlVisible("Label1", true, itemCtrl)
            self:setCtrlVisible("BackImage2", false, itemCtrl)
            self:setCtrlVisible("Label2", false, itemCtrl)
        end
    end

    --
    if self.selectType ~= "VerifyRecordButton" and self.defaultGid == item.record_id then
        self:addItemSelcelImage(itemCtrl)
    end


    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addItemSelcelImage(itemCtrl)
        end
    end
    itemCtrl:addTouchEventListener(listener)

    return itemCtrl
end


function MarketRecordDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end

function MarketRecordDlg:MSG_STALL_RECORD(data)
    self:updateViewData()

    -- 需要默认选中
    if self.defaultGid then
        local defType
        local index = 0
        for k, v in pairs(listViewConfig) do
            local listData = self:getListViewData(v)
            for _, uData in pairs(listData) do
                if uData.record_id == self.defaultGid and k ~= "VerifyRecordButton" then
                    defType = k
                    index = _
                end
            end
        end

        if defType then
            -- 找到了
            self:swichListView(self:getControl(defType))
            self.defaultGid = nil

            -- 策划说，找到了就要滚到那去
            performWithDelay(self.root, function ()
                self:setListInnerPosByIndex(listViewConfig[defType], index)
            end, 0)
        else
            -- 没有找到默认选择出售中
            self:swichListView(self:getControl("SellRecordButton"))
        end

        self.defaultGid = nil
    end
end

function MarketRecordDlg:MSG_STALL_RECORD_DETAIL(data)

    self.cardInfo[data.record_id] = data

    if data.goods_type == TRANSFER_ITEM_TYPE.OTHER then
    elseif data.goods_type == TRANSFER_ITEM_TYPE.CASH then

    elseif data.goods_type == TRANSFER_ITEM_TYPE.PET then
        local objcet = DataObject.new()
        data.raw_name = PetMgr:getShowNameByRawName(data.raw_name)
        data.icon =  PetMgr:getPetIcon(data.raw_name)
        data.id = 0
        objcet:absorbBasicFields(data)
        -- 显示名片
        MarketMgr:showPetFloatBox(objcet)
    elseif data.goods_type == TRANSFER_ITEM_TYPE.CHARGE then
        MarketMgr.pram = nil
        MarketMgr.selectItem = nil
        MarketMgr:showItemFloatBox({item = data})
    elseif data.goods_type == TRANSFER_ITEM_TYPE.NOT_COMBINE then
        MarketMgr.pram = nil
        MarketMgr.selectItem = nil
        MarketMgr:showItemFloatBox({item = data})
    elseif data.goods_type == TRANSFER_ITEM_TYPE.COMBINE then
        MarketMgr.pram = nil
        MarketMgr.selectItem = nil
        MarketMgr:showItemFloatBox({item = data})
    end
end

function MarketRecordDlg:tradeType()
    return MarketMgr.TradeType.marketType
end

function MarketRecordDlg:onDlgOpened(items)
    if not items then return end
    self.defaultGid = items[1]
end

return MarketRecordDlg
