-- RebuyDlg.lua
-- Created by zhengjh Feb/17/2016
-- 回购界面

local RebuyDlg = Singleton("RebuyDlg", Dialog)

function RebuyDlg:init()
    self:bindListener("RebuyButton", self.onRebuyButton)
    self:bindListViewListener("SellListView", self.onSelectSellListView)

    self.itemCtrl = self:getControl("ItemPanel")
    self.itemCtrl:retain()
    self.itemCtrl:removeFromParentAndCleanup()

    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, self.itemCtrl)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()

    self.selcetTag = nil
end

-- 更新一个ListView
function RebuyDlg:intData(items)
    self.selcetTag = nil
    self.items = items
    local listViewCtrl = self:getControl("SellListView")
    listViewCtrl:removeAllItems()

    if #items == 0 then
        self:setCtrlVisible("NoticePanel", true)
    else
        for i = 1, #items do
            listViewCtrl:pushBackCustomItem(self:createOneItem(items[i], i))
        end

        self:setCtrlVisible("NoticePanel", false)
    end
end

function RebuyDlg:createOneItem(item, tag)
    local itemCtrl = self.itemCtrl:clone()

    -- 产品序号
    self:setLabelText("NumLabel", tag, itemCtrl)

    -- 带属性超级黑水晶
    if string.match(item.name, CHS[3003585]) then
        local name = string.gsub(item.name, CHS[3003586],"")
        local list = gf:split(name, "|")
        local field = EquipmentMgr:getAttribChsOrEng(list[1])
        local str = field .. "_" .. Const.FIELDS_EXTRA1
        local value = 0
        local maxValue = 0
        local bai = ""
        if list[2] then
            value =  tonumber(list[2])
            local equip = {req_level = item.level, equip_type = list[3]}
            maxValue = EquipmentMgr:getAttribMaxValueByField(equip, field) or ""
            if EquipmentMgr:getAttribsTabByName(CHS[3003587])[field] then bai = "%" end
        end

        local valueText = value .. bai .. "/" .. maxValue .. bai

        self:setLabelText("OneNameLabel", list[1] .. CHS[3003588] .. valueText, itemCtrl)
    else

        -- 名字
        self:setLabelText("OneNameLabel", PetMgr:trimPetRawName(item.name), itemCtrl)
    end

    self:setLabelText("TimeLabel1", gf:getServerDate("%H:%M:%S", item.time), itemCtrl)

    -- 设置的价格
    local label = self:getControl("CoinLabel", Const.UILabel, itemCtrl)
    local label2 = self:getControl("CoinLabel2", Const.UILabel, itemCtrl)
    local cashText, color = gf:getMoneyDesc(item.price, true)
    label:setString(cashText)
    label:setColor(color)
    label2:setString(cashText)
    --label2:setColor(color)

    -- 设置Icon
    local imgPath
    if PetMgr:getPetIcon(item.name) then
        imgPath =   ResMgr:getSmallPortrait(PetMgr:getPetIcon(item.name))
    else
        local icon = InventoryMgr:getIconByName(item.name)
        imgPath = ResMgr:getItemIconPath(icon)
    end

    self:setImage("IconImage", imgPath, itemCtrl)
    self:setItemImageSize("IconImage", itemCtrl)

    local iconPanel = self:getControl("IconPanel", nil, itemCtrl)

    -- 等级
    if item.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 这里的type == 2 才是装备！！！！！！
    if item.type == 2 and item.req_level > 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    -- 名片悬浮框
    local function showCardInfo(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(iconPanel)
            RebuyMgr:requireCardInfo(item.id, rect, item.type)
        end
    end

    iconPanel:addTouchEventListener(showCardInfo)

    -- 限制交易
    local iconImage = self:getControl("IconImage", nil, itemCtrl)

    if item.deadline and item.deadline ~= 0 then
        InventoryMgr:removeLogoBinding(iconImage)
        InventoryMgr:addLogoTimeLimit(iconImage)
    elseif item.islimit == 1 then
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:addLogoBinding(iconImage)
    else
        InventoryMgr:removeLogoTimeLimit(iconImage)
        InventoryMgr:removeLogoBinding(iconImage)
    end

    -- 小于等于1 数量不显示
    if item["count"] > 1 then
        --数量适用艺术字NumImg
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, item["count"],
            false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end


    -- 法宝相性
    if item.item_polar then
        InventoryMgr:addArtifactPolarImage(iconImage, item.item_polar)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addItemSelcelImage(itemCtrl)
            self.selcetTag = tag
        end
    end

    itemCtrl:addTouchEventListener(listener)

    return itemCtrl
end


function RebuyDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end


function RebuyDlg:onRebuyButton(sender, eventType)
    if not self.items or #self.items == 0 then
        gf:ShowSmallTips(CHS[3003589])  -- 当前没有可回购的项目
        return
    elseif not self.selcetTag then
        gf:ShowSmallTips(CHS[3003590])  -- 当前没有可回购的项目
        return
    end

    local item = self.items[self.selcetTag]

    if item.type == 1 then
        if PetMgr:getFreePetCapcity() == 0 then
            gf:ShowSmallTips(CHS[3003591])  -- 你的携带宠物已满，去整理下再来吧。
            return
        end
    else
        if not InventoryMgr:getFirstEmptyPos() then
            gf:ShowSmallTips(CHS[3003592])  -- 你的包裹已满，去整理下再来吧。
            return
        end
    end

    if Me:queryBasicInt("cash") < item["price"] then
        gf:askUserWhetherBuyCash()
    else
        local str = ""
        local priceStr = gf:getMoneyDesc(item.price)
        if item.type == 1 then -- 宠物
            if item.skills > 0 then -- 有天技
                str = string.format(CHS[3003593], priceStr, item.skills, item.name)
            else
                str = string.format(CHS[3003594], priceStr, item.name)
            end
        elseif item.type == 2   then -- 装备
            str = string.format(CHS[3003594], priceStr, item.name)
        else

            if HomeMgr:isFurniture(item.name) then
                str = string.format(CHS[4300266], priceStr, item.count, InventoryMgr:getUnit(item.name), item.name)
            else
                -- 带属性超级黑水晶
                if string.match(item.name, CHS[3003585]) then
                    local list = gf:split(item.name, "|")
                    str = string.format(CHS[3003595], priceStr, item.count, InventoryMgr:getUnit(CHS[3003596]), list[1])
                else
                    str = string.format(CHS[3003595], priceStr, item.count, InventoryMgr:getUnit(item.name), item.name)
                end
            end
        end

        gf:confirm(str, function()
            RebuyMgr:rebuyGood(item.id)
        end)

    end
end

function RebuyDlg:onSelectSellListView(sender, eventType)
end

function RebuyDlg:cleanup()
    self:releaseCloneCtrl("itemCtrl")
    self:releaseCloneCtrl("itemSelectImg")
end

return RebuyDlg
