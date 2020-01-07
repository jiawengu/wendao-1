-- DailySignDlg.lua
-- Created by zhengjh Apr/14/2015
-- 每日签到

local LINE_SPACE = 5
local COLUMN_SPACE = 10
local columnNum = 5
local OUTLINE_SIZE = 4
local TEXT_OUNTLINE_COLOR = cc.c4b(102, 77, 46, 255)
local DailySignDlg = Singleton("DailySignDlg", Dialog)
local NumImg = require('ctrl/NumImg')     --引入NumImg控件(Sprite)

DailySignDlg.TAG_NUM_IMG_NUM = 21

local CONST_DATA =
{
    columnNum = 5,
    lineSapce = 0,
    columnSpace = 0,
}

function DailySignDlg:init()
    self.itemPanel= self:getControl("ItemPanel", Const.UIPanel)
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()
    local signTimesLabel = self:getControl("LevelLabel", Const.UILabel, "MonthSignPanel")
    signTimesLabel:setVisible(false)
    self:hookMsg("MSG_DAILY_SIGN")
    GiftMgr:openDailySign()
    
    GiftMgr.lastIndex = "WelfareButton2"
    GiftMgr:setLastTime()
end

function DailySignDlg:MSG_DAILY_SIGN()
    self.dailySignData = GiftMgr:getDailySignData()
    self:initList(self.dailySignData["itemList"], self.dailySignData["signDays"])
    
    -- 本月已签到次数
    local signTimesLabel = self:getControl("LevelLabel", Const.UILabel, "MonthSignPanel")
    signTimesLabel:setVisible(true)
    self:setLabelText("LevelLabel", string.format(CHS[6000171], self.dailySignData["signDays"]), "MonthSignPanel")   

    -- 今日可补签次数
    local replenishSignTimesLabel = self:getControl("RetroactiveLabel", Const.UILabel, "MonthSignPanel")
    replenishSignTimesLabel:setVisible(true)
    self:setLabelText("RetroactiveLabel", string.format(CHS[7000195], self.dailySignData["isCanReplenishSign"]), "MonthSignPanel")
    
    --local time = gf:getServerTime()
   --  local monthLabel = self:getControl("TitleLabel")
   -- monthLabel:setString("本月签到奖励")
end

function DailySignDlg:initList(list, signDays)
    local scrollview = self:getControl("SignScrollView", Const.UIScrollView)
    scrollview:removeAllChildren()
    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local number = #list
    local line = math.floor(number / CONST_DATA.columnNum) + 1
    local left = number % CONST_DATA.columnNum
    local innerSizeheight = 0

    if left == 0 then
        innerSizeheight = (line - 1) * (self.itemPanel:getContentSize().height + CONST_DATA.lineSapce)
    else
        innerSizeheight = line * (self.itemPanel:getContentSize().height + CONST_DATA.lineSapce)
    end

    if innerSizeheight < scrollview:getContentSize().height then
        innerSizeheight = scrollview:getContentSize().height
    end

    for i = 1 , line do 
        local cloumnNumber = 0
        if i == line then
            cloumnNumber = left
        else
            cloumnNumber = columnNum
        end
        for j = 1 , cloumnNumber do
            local tag = (i - 1)* columnNum + j
            local cell = self.itemPanel:clone()
            cell:setTag(tag)
            cell:setAnchorPoint(0,1)
            local pox = (self.itemPanel:getContentSize().width + CONST_DATA.columnSpace + 1) * (j - 1)
            local poy = innerSizeheight - (self.itemPanel:getContentSize().height + CONST_DATA.lineSapce) * (i - 1)
            cell:setPosition(pox, poy)
            self:createCell(cell, list[tag], signDays)
            container:addChild(cell)
        end
    end
    
    scrollview:addChild(container)
    container:setContentSize(self.itemPanel:getContentSize().width, innerSizeheight)
    scrollview:setInnerContainerSize(container:getContentSize())   
    
    
    -- 找到第一行 含有未领取状态
    local scrollNumber  = math.floor(signDays / CONST_DATA.columnNum) - 1 
    
    if scrollNumber < 0 then
        scrollNumber = 0
    end
    
    local totoalOffset = scrollview:getInnerContainer():getContentSize().height - scrollview:getContentSize().height
    local posy =  scrollNumber * (self.itemPanel:getContentSize().height ) - totoalOffset
    if posy > 0 then
        posy = 0
    end

    scrollview:getInnerContainer():setPositionY(posy)
    
   --[[ performWithDelay(scrollview, function()
        local prencent = (scrollNumber * self.itemPanel:getContentSize().height) / (scrollview:getInnerContainer():getContentSize().height - scrollview:getContentSize().height)

        if prencent > 1 then
            prencent = 1
        end

        scrollview:scrollToPercentVertical(100 * prencent, 0.5, true)
    end, 0.01)]]
end


function DailySignDlg:createCell(cell, data, signDays)
    local tag = cell:getTag()
    local itemImage = self:getControl("ItemImage", Const.UIImage, cell)
    local itemIamgePanel = self:getControl("ItemImagePanel", Const.UIPanel, cell)

    local imgPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(data["name"]))
    local iconImg = itemImage:loadTexture(imgPath)
    gf:setItemImageSize(itemImage)
    
    local function ctrlTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            local item = {}
            
            -- 签到或补签
            if signDays + 1 == tag then
                if not DistMgr:checkCrossDist() then return end
                
                if self.dailySignData["isCanSgin"] == 1 then
                    -- 签到 
                    GiftMgr:dailySign()
                    return
                elseif self.dailySignData["isCanReplenishSign"] == 1 then
                    -- 补签
                    GiftMgr:replenishDailySign()
                    return
                end
            end
            
            local str = ""
            if tag <= signDays then
                str = CHS[6000169]
            else
                str = string.format(CHS[6000170], tag)   
            end
            
            if data["name"] == CHS[6000080] or data["name"] == CHS[6000042] then
                item["Icon"] = InventoryMgr:getIconByName(data["name"])
                item["name"] = data["name"]
                item["extra"] = nil
                item["desc"] = string.format(InventoryMgr:getDescript(data["name"]), data["number"])
                item["desc2"] = str 
            else
                item["Icon"] = InventoryMgr:getIconByName(data["name"])
                item["name"] = data["name"]
                item["extra"] = nil
                item["desc2"] = str
                item["limted"] = true
            end
            
            InventoryMgr:showBasicMessageByItem(item, rect)           
        end
    end
    
    itemIamgePanel:addTouchEventListener(ctrlTouch)
    
    -- 小于等于1 数量不显示
    if data["number"] > 1 and data["name"] ~= CHS[6000080] and data["name"] ~= CHS[6000042] then
        --数量适用艺术字NumImg
        self:setNumImgForPanel(itemIamgePanel, ART_FONT_COLOR.NORMAL_TEXT, data.number,
                               false, LOCATE_POSITION.RIGHT_BOTTOM, 21)       
    end
    
    if data["name"] ~= CHS[6000080] and data["name"] ~= CHS[6000042] then
        -- 限制交易
        InventoryMgr:addLogoBinding(itemImage)
    end
    
    -- 签到过置灰，打钩
    local getImage = self:getControl("GetImage", Const.UIImage, cell)
    if tag <= signDays then
       -- self:getControl("BackImage", Const.UIImage, cell):setVisible(false) 
       -- gf:grayImageView(itemImage)
        self:getControl("BlackImage", Const.UIImage, cell):setVisible(true)
        getImage:setVisible(true)
    elseif signDays + 1 == tag and self.dailySignData["isCanSgin"] == 1 then   
      --  self:getControl("BackImage", Const.UIImage, cell):setVisible(true)  
        getImage:setVisible(false)
        self:getControl("BlackImage", Const.UIImage, cell):setVisible(false)
        -- lixh2 WDSY-21401 帧光效修改为粒子光效：每日签到环绕光效
        gf:createArmatureMagic(ResMgr.ArmatureMagic.item_around, itemIamgePanel, Const.ARMATURE_MAGIC_TAG, 0, 2)
    else
        getImage:setVisible(false)
    end
    
    -- 今日可签到次数为0，且未补签过，则下一次签到icon显示补签状态
    local retroactiveImage = self:getControl("RetroactiveImage", Const.UIImage, cell)
    if signDays + 1 == tag and self.dailySignData["isCanSgin"] == 0 and self.dailySignData["isCanReplenishSign"] == 1 then
        retroactiveImage:setVisible(true)
    else
        retroactiveImage:setVisible(false)
    end
end

function DailySignDlg:cleanup()
    if self.itemPanel then
        self.itemPanel:release()
        self.itemPanel = nil
    end
end

function DailySignDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
    if nil == self.onlineData then return end

    GiftMgr:getReward(self.onlineData["type"], RewardStep["close"])
end
return DailySignDlg
