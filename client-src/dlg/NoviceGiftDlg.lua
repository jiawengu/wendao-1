-- NoviceGiftDlg.lua
-- Created by zhengjh Apr/13/2015
-- 新手礼包

local NoviceGiftDlg = Singleton("NoviceGiftDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local LINE_SPACE  = 0
local OUTLINE_SIZE = 4
local TEXT_OUNTLINE_COLOR = cc.c4b(102, 77, 46, 255)
local NumImg = require('ctrl/NumImg')     --引入NumImg控件(Sprite)
local itemCfg = require (ResMgr:getCfgPath("NoviceGiftItem.lua"))

NoviceGiftDlg.TAG_NUM_IMG_NUM = 21
local SCROLLVIEW_CONTAINNER = 766

local weaponType    = { CHS[3003144], CHS[3003145], CHS[3003146], CHS[3003147], CHS[3003148] }
local hatType       = { CHS[3003149], CHS[3003150] }
local clothType     = { CHS[3003151], CHS[3003152] }
local bootType      = { CHS[3003153] }
local rawCount      = 7

function NoviceGiftDlg:init()
    self:bindListener("GotButton", self.onGotButton)

    self.giftPanel = self:getControl("ItemPanel", Const.UIPanel)
    self.giftPanel:retain()
    self.itemCell = self:getControl("ItemImagePanel", Const.UIPanel)
    self.itemCell:retain()
    self.itemCell:removeFromParent()
    self.giftPanel:removeFromParent()

    self:hookMsg("MSG_NEWBIE_GIFT")
    self:hookMsg("MSG_OPEN_TO_TIP_MOUNT")

    self.isInitData = false
    if GiftMgr:getNewPlayerGift() then
        -- 如果有数据，设置数据信息。
        self.isInitData = true
        self:initGiftList(GiftMgr:getNewPlayerGift())
    end

    -- 请求礼包，更新数据信息
    GiftMgr:openNewPlayerGift()

    GiftMgr.lastIndex = "WelfareButton3"
    GiftMgr:setLastTime()
end

function NoviceGiftDlg:MSG_NEWBIE_GIFT()
    if self.isInitData then
        self:upDataListButton(GiftMgr:getNewPlayerGift())
    else
        self:initGiftList(GiftMgr:getNewPlayerGift())
        self.isInitData = true
    end
end

function NoviceGiftDlg:upDataListButton(list)
    local panel = self:getControl("GiftListScrollView"):getChildByTag(SCROLLVIEW_CONTAINNER)
    for i = 1, #list do
        local btnPanel = panel:getChildByTag(i)

        self:setBtnState(btnPanel, list[i])
    end
end

function NoviceGiftDlg:initGiftList(list)
    local totalHight = 0

    -- local totalHight = #list * (self.giftPanel:getContentSize().height  + LINE_SPACE) + 50
    local scrollView = self:getControl("GiftListScrollView")
    scrollView:removeAllChildren()
    local container = ccui.Layout:create()
    scrollView:addChild(container,1, SCROLLVIEW_CONTAINNER)
    container:setPosition(4, 0)

    local panelList = {}
    for i = 1, #list do
        local panel = self.giftPanel:clone()
        panel:setTag(i)
        self:createGiftPanel(panel, list[i])
        self:getControl("GetButton", Const.UIButton, panel):setTag(i)
        container:addChild(panel)
        totalHight = totalHight + panel:getContentSize().height  + LINE_SPACE
        table.insert(panelList, panel)
    end

    container:setContentSize(scrollView:getContentSize().width, totalHight)
    scrollView:setInnerContainerSize(container:getContentSize())

    local curHeight = totalHight
    for i = 1, #panelList do
        local panel = panelList[i]
        panel:setAnchorPoint(0, 1)
        panel:setPosition(0, curHeight)
        curHeight = curHeight - panel:getContentSize().height - LINE_SPACE
    end

    -- 找到第一个 不是已领取状态
    local scrollNumber  = self:getScrollToNumber(list)
    local scrollHeight = 0
    for i = 1, scrollNumber do
        scrollHeight = scrollHeight + panelList[i]:getContentSize().height
    end


    local totoalOffset = scrollView:getInnerContainer():getContentSize().height - scrollView:getContentSize().height
    local posy =  scrollHeight - totoalOffset
    if posy > 0 then
        posy = 0
    end

    scrollView:getInnerContainer():setPositionY(posy)
end

function NoviceGiftDlg:getScrollToNumber(rewardList)
    local scrollToNumber = 1

    for i = 1,#rewardList do
        if rewardList[i]["isGot"] ~= 1 then  -- 第一个不是已领取
            scrollToNumber = i
            break
        end
    end

    if scrollToNumber - 1 < 0 then  -- 要滑动到第一个不是已领取的前一个
        return 0
    else
        return scrollToNumber - 1
    end
end

function NoviceGiftDlg:setBtnState(panel, data)
    local level = Me:queryBasic("level")
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, panel)
    local getBtn = self:getControl("GetButton", Const.UIButton, panel)
    local gotBtn = self:getControl("GotButton", Const.UIButton, panel)
    local canNotGetBnt = self:getControl("NoReachButton", Const.UIButton, panel)
    self:bindListener("GetButton", self.onGetButton, panel)
    levelLabel:setVisible(true)
    levelLabel:setString(string.format(CHS[6000168], data["limitLevel"]))

    if tonumber(level) < data["limitLevel"] then
        canNotGetBnt:setVisible(true)
        gf:grayImageView(canNotGetBnt)
        getBtn:setVisible(false)
        gotBtn:setVisible(false)
    elseif  data["isGot"]  == 1 then
        getBtn:setVisible(false)
        gotBtn:setVisible(true)
        gotBtn:setTouchEnabled(false)
        gf:grayImageView(gotBtn)
        canNotGetBnt:setVisible(false)
    elseif data["isGot"]  == 0 then
        getBtn:setVisible(true)
        gotBtn:setVisible(false)
        canNotGetBnt:setVisible(false)
    end
end

function NoviceGiftDlg:createGiftPanel(panel, data)
    self:setBtnState(panel, data)

    local itemListPanel = self:getControl("ItemListPanel", Const.UIPanel, panel)
    for i = 1, data["count"] do
        local itemCell = self.itemCell:clone()
        local index = math.floor((i - 1) / rawCount)
        itemCell:setAnchorPoint(0, 0)
        itemCell:setPosition((i - 1) % rawCount * self.itemCell:getContentSize().width + 8, - (self.itemCell:getContentSize().height + 5) * index)
        self:createItemCell(itemCell, data[i], data["limitLevel"])
        itemListPanel:addChild(itemCell)
    end

    local count = math.floor((data["count"] - 1) / rawCount)
    local cellHeight = (self.itemCell:getContentSize().height + rawCount) * count
    if (data["count"] - 1) % rawCount >= 5 then
        count = math.max(count + 1, 0)
        local getBtn = self:getControl("GetButton", Const.UIButton, panel)
        cellHeight = cellHeight + count * (getBtn:getContentSize().height + 5)
    end

    panel:setContentSize(panel:getContentSize().width, panel:getContentSize().height + cellHeight)

    panel:requestFocus()
end

function NoviceGiftDlg:createItemCell(itemCell, data, level)
    local itemImage = self:getControl("ItemImage", Const.UIImage, itemCell)
    local itemIamgePanel = self:getControl("ItemImagePanel", Const.UIPanel, itemCell)

    local iconImg
    if data["name"] == CHS[3004433] then -- 代金券资源在plist
        local imgPath = ResMgr.ui["voucher"]
        iconImg = itemImage:loadTexture(imgPath, ccui.TextureResType.plistType)
    else
        local imgPath = ResMgr:getIconPathByName(data["name"])
        iconImg = itemImage:loadTexture(imgPath)
        self:setItemImageSize("ItemImage", itemCell)
        
        local item = InventoryMgr:getItemInfoByName(data["name"])
        if item and item.equipType and item.req_level then
            -- 如果是装备，有req_level则显示等级
           self:setNumImgForPanel(itemIamgePanel, ART_FONT_COLOR.NORMAL_TEXT, item.req_level, false,
                LOCATE_POSITION.LEFT_TOP, 21)
        end
    end

    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local rect = self:getBoundingBoxInWorldSpace(sender)

            if data["name"] == CHS[6000080] or data["name"] == CHS[6000042] then -- 金钱\银元宝
                local item = {}
                item["Icon"] = InventoryMgr:getIconByName(data["name"])
                item["name"] = data["name"]
                item["extra"] = nil
                item["desc2"] = string.format(InventoryMgr:getDescript(data["name"]), data["number"])
                item["isShowDesc"] = 0
                InventoryMgr:showBasicMessageByItem(item, rect)
            elseif data["name"] == CHS[3004433] then
                local rewardInfo = {}
                rewardInfo.imagePath =  ResMgr.ui["voucher"]
                rewardInfo.resType= ccui.TextureResType.plistType
                rewardInfo.desc = CHS[3004434]
                rewardInfo.basicInfo = {}
                rewardInfo.basicInfo[1] = data["name"]
                rewardInfo.basicInfo[2] = data["number"]

                local dlg = DlgMgr:openDlg("BonusInfoDlg")
                dlg:setRewardInfo(rewardInfo)
                dlg.root:setAnchorPoint(0, 0)
                dlg:setFloatingFramePos(rect)
            elseif data["name"] == CHS[7120177] then
                -- 40礼包中宠物特殊处理
                local dlg = DlgMgr:openDlg("BonusInfo2Dlg")
                local iconPath, isPlist = ResMgr:getIconPathByName(CHS[7120177])
                local rewardList = TaskMgr:getRewardList(CHS[7120178])
                local rewardInfo = RewardContainer:getRewardInfo(rewardList[1][1])
                dlg:setRewardInfo(rewardInfo)
                dlg.root:setAnchorPoint(0, 0)
                dlg:setFloatingFramePos(rect)
            else
                local item = gf:deepCopy(InventoryMgr:getItemInfoByName(data["name"]))
                local equipType = self:getEquipParentType(item.equipType)
                if equipType then
                    item["name"] = data["name"]
                    item["number"] = data["number"]
                    item.equip_type = equipType
                    local equipBasicAttr = EquipmentMgr:getBasicAttriByLevel(equipType, level)
                    local equipAttr = itemCfg[equipType]
                    item.extra = {}
                    item.color = CHS[3003154]
                    item.req_level = level
                    item.locked = 1
                    item.gift = 1
                    item.rebuild_level = 3
                    if level == 40 then
                        item.rebuild_level = 2
                    end

                    if level == 50 and equipType == EQUIP.WEAPON then
                        item.rebuild_level = 0
                    end

                    item.degree_32 = 0
                    item.extra = EquipmentMgr:caculateAttribOneKey(equipType, level, item.rebuild_level)
                    item.gift = 2

                    -- 基础属性
                    for k, v in pairs(equipBasicAttr) do
                        item.extra[k .. "_1"] = v
                    end
                    
                    -- 蓝属性
                    for k, v in pairs(equipAttr) do
                        item.extra[k] = v[math.floor(level / 10)]
                    end

                    -- 粉属性和黄属性
                    if level == 70 then
                        item.color = CHS[3003155]
                        item.extra.str_3 = 10
                        item.extra.wiz_4 = 10
                    end

                    InventoryMgr:showEquipByEquipment(item, rect, true)
                else
                    local item = gf:deepCopy(InventoryMgr:getItemInfoByName(data["name"]))

                    if item.equipType == CHS[3003156] then
                        local dlg = DlgMgr:openDlg("JewelryInfoDlg")
                        local item = dlg:getInitJewelry(item.pos, data["name"])
                        item.gift = 2
                        dlg:setJewelryInfo(item, item.equip_type, true)
                        dlg:setFloatingFramePos(rect)
                    else
                        --InventoryMgr:showBasicMessageDlg(data["name"], rect)
                        data["limted"] = true
                        local dlg = DlgMgr:openDlg("ItemInfoDlg")
                        dlg:setInfoFormCard(data)
                        dlg:setFloatingFramePos(rect)
                    end
                end
            end

        end
    end

    itemIamgePanel:addTouchEventListener(ctrlTouch)

  --[[  local itemNumLabel = self:getControl("NumLabel", Const.UILabel, itemCell)
    if data["number"] > 1 and data["name"] ~= CHS[6000080] and data["name"] ~= CHS[6000042] then
        itemNumLabel:setString(data["number"])
    else
        itemNumLabel:setVisible(false)
    end]]--

    if data["number"] > 1 and data["name"] ~= CHS[6000080] and data["name"] ~= CHS[6000042] and data["name"] ~= CHS[3004433] then
        -- 设置道具数量
        local image = self:getControl("ItemBackImage", nil, itemIamgePanel)
        self:setNumImgForPanel(image, ART_FONT_COLOR.NORMAL_TEXT, data.number, false,
            LOCATE_POSITION.RIGHT_BOTTOM, 21)
    end

    if data["name"] ~= CHS[6000080] and data["name"] ~= CHS[6000042] and data["name"] ~= CHS[3004433] then
        -- 限制交易
        InventoryMgr:addLogoBinding(itemImage)
    end
end

function NoviceGiftDlg:getEquipParentType(equipType)
    if nil == equipType then return end

    for i = 1, 5 do
        if weaponType[i] and equipType == weaponType[i] then
            return EQUIP.WEAPON
        end

        if hatType[i] and equipType == hatType[i] then
            return EQUIP.HELMET
        end

        if clothType[i] and equipType == clothType[i] then
            return EQUIP.ARMOR
        end

        if bootType[i] and equipType == bootType[i] then
            return EQUIP.BOOT
        end
    end
end

function NoviceGiftDlg:onGetButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    
    local tag = sender:getTag()
    GiftMgr:getGift(tag - 1)
end

function NoviceGiftDlg:onGotButton(sender, eventType)
end

function NoviceGiftDlg:cleanup()
    self:releaseCloneCtrl("giftPanel")
    self:releaseCloneCtrl("itemCell")
end

function NoviceGiftDlg:MSG_OPEN_TO_TIP_MOUNT(data)
    local dlg = DlgMgr:getDlgByName("PetHorseDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("PetHorseDlg")
    end

    DlgMgr:sendMsg("PetListChildDlg", "selectPetId", data.pet_id)
    DlgMgr:sendMsg("PetHorseDlg", "addTameButtonMagic")
end

return NoviceGiftDlg
