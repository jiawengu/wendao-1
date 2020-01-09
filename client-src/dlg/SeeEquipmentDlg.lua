-- SeeEquipmentDlg.lua
-- Created by zhengjh Mar/25/2015
-- 查看他人装备

local SeeEquipmentDlg = Singleton("SeeEquipmentDlg", Dialog)
local GridPanel = require('ctrl/GridPanel')

local EQUIPMENT =
{
   [1] = EQUIP.HELMET,  -- 头盔
   [2] = EQUIP.ARMOR,   -- 衣服
   [3] = EQUIP.WEAPON,  -- 武器
   [4] = EQUIP.BOOT,    -- 鞋子
   [5] = EQUIP.BALDRIC, -- 玉佩
   [6] = EQUIP.NECKLACE,-- 项链
   [7] = EQUIP.LEFT_WRIST,-- 左手镯
   [8] = EQUIP.RIGHT_WRIST,-- 右手镯
   [9] = EQUIP.ARTIFACT, -- 法宝
   [10] = EQUIP.TALISMAN, -- 符具
}

-- 备用首饰
local BACK_JEWELRY =
    {
        [5] = EQUIP.BACK_BALDRIC, -- 玉佩
        [6] = EQUIP.BACK_NECKLACE,-- 项链
        [7] = EQUIP.BACK_LEFT_WRIST,-- 左手镯
        [8] = EQUIP.BACK_RIGHT_WRIST,-- 右手镯
    }

local BACK_ARTIFACT =
{
    [9] = EQUIP.BACK_ARTIFACT, -- 备用法宝
}

local EQUIP_ROW_SPACE = 15
local GRID_W = 74
local GRID_H = 74

function SeeEquipmentDlg:init()
    self:bindListener("FashionButton", self.onFashionButton)
    self:bindListener("SuitButton", self.onSuitButton)

    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)

    self:setCtrlVisible("FashionButton", false) -- 暂时屏蔽WDSY-29682

    self.data = nil
    self:onSuitButton()
end

function SeeEquipmentDlg:onFashionButton()
    self:setCtrlVisible("EquipmentPanel", false)
    self:setCtrlVisible("FashionPanel", true)
end

function SeeEquipmentDlg:onSuitButton()
    self:setCtrlVisible("EquipmentPanel", true)
    self:setCtrlVisible("FashionPanel", false)
end

function SeeEquipmentDlg:setData(data)
    self.data = data
    self.equipment = data["equipment"]

    local icon = data["suit_icon"]
    if nil == icon or 0 == icon then
        icon = data["icon"]
    end
    local weaponIcon = data["weapon_icon"]

    -- 设置形象
    self:setPortrait("UserPanel", icon, weaponIcon, nil, nil, nil, nil, cc.p(0, -50), data["icon"])
    -- 仙魔光效
    if data["upgrade/type"] then
        self:addUpgradeMagicToCtrl("UserPanel", data["upgrade/type"], nil, true)
    end

    -- 初值化面板
    self:initEquipment()

    -- 设置玩家基本信息
    self:initPalyerInfo(data)

    self:initFashionPanel(data)
end

function SeeEquipmentDlg:initFashionPanel(data)
    -- 设置时装形象
    self.dir = 5
    local fashionPanel = self:getControl("FashionPanel")
    if data.fashionIcon == 0 then
        local icon = data["suit_icon"]
        if nil == icon or 0 == icon then
            icon = data["icon"]
        end
        local weaponIcon = data["weapon_icon"]
        self:setPortrait("UserPanel", icon, weaponIcon, fashionPanel, nil, nil, nil, cc.p(0, -50), data["icon"])
    else
        self:setPortrait("UserPanel", data.fashionIcon, nil, fashionPanel)
    end

    self:setLabelText("FightingTypeLabel_1", gf:getRealName(data.name), fashionPanel)
    self:setLabelText("FightingTypeLabel_2", gf:getRealName(data.name), fashionPanel)

    self:setLabelText("LevelLabel", data.level .. CHS[3003612], fashionPanel)
    self:setLabelText("PartyLabel", data.partyName, fashionPanel)

    local fashionEquip = self:getFashionData(data)
    self:showEquipInfo('FashionEquipPanel', fashionEquip, function(idx, sender)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        local item = fashionEquip[idx].item
        if not item then return end
        InventoryMgr:showFashioEquip(item, rect, true)
    end)

    self:updateLayout("FashionPanel")
end

function SeeEquipmentDlg:getFashionData(data)
    local retData = {}
    local count = 0
    local item1 = data.equipment[EQUIP.FASHION_SUIT]
    local info1 = {}
    if item1 then
        info1.imgFile = ResMgr:getItemIconPath(item1.icon)
        info1.item = item1
    else
        local backImage = InventoryMgr:getEquipment_Backimage()
        info1.imgFile = backImage[EQUIP.FASHION_SUIT]
        info1.noItemImg = true
    end

    table.insert(retData, info1)

    local item2 = data.equipment[EQUIP.FASHION_JEWELRY]
    local info2 = {}
    if item2 then
        info2.imgFile = ResMgr:getItemIconPath(item2.icon)
        info2.item = item2
   else
        local backImage = InventoryMgr:getEquipment_Backimage()
        info2.imgFile = backImage[EQUIP.FASHION_JEWELRY]
        info2.noItemImg = true
    end
    table.insert(retData, info2)

    retData.count = 2
    return retData
end

-- 显示装备相关信息
function SeeEquipmentDlg:showEquipInfo(panelName, data, callback)
    local panel = self:getControl(panelName, Const.UIPanel)
    local size = panel:getContentSize()
    panel:removeAllChildren()
    local colunm = 2

    local rowNum = data.count / colunm
    local rowSpace = EQUIP_ROW_SPACE
    local colunmSpace = size.width - colunm * GRID_H

    local grids = GridPanel.new(
        size.width, size.height,
        rowNum, colunm,
        GRID_W, GRID_H,
        rowSpace, colunmSpace)

    -- grids:setGridTop(EQUIP_GRID_TOP)

    grids:setData(data, 1, function(idx, sender)
        callback(idx, sender)
       -- self:clearAllSelected()
    end)

    self.equipmentGrids = grids
    panel:addChild(grids)
end

function SeeEquipmentDlg:setGid(gid)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LOOK_PLAYER_EQUIP, gid)
end

function SeeEquipmentDlg:onTurnRightButton()
    local fashionPanel = self:getControl("FashionPanel")
    if self.data.fashionIcon == 0 then
        local icon = self.data["suit_icon"]
        if nil == icon or 0 == icon then
            icon = self.data["icon"]
        end

        local weaponIcon = self.data["weapon_icon"]
        self.dir = self.dir - 1
        if self.dir < 0 then
            self.dir = 7
        end

        self:setPortrait("UserPanel", icon, weaponIcon, fashionPanel, nil, nil, nil, cc.p(0, -50), icon, nil, self.dir)
    else
        self.dir = self.dir - 2
        if self.dir < 0 then
            self.dir = 7
        end

        self:setPortrait("UserPanel", self.data.fashionIcon, nil, fashionPanel, nil, nil, nil, nil, nil, nil, self.dir)
    end
end


function SeeEquipmentDlg:onTurnLeftButton()
    local fashionPanel = self:getControl("FashionPanel")

    if self.data.fashionIcon == 0 then
        local icon = self.data["suit_icon"]
        if nil == icon or 0 == icon then
            icon = self.data["icon"]
        end

        local weaponIcon = self.data["weapon_icon"]
        self.dir = self.dir + 1
        if self.dir > 7 then
            self.dir = 0
        end

        self:setPortrait("UserPanel", icon, weaponIcon, fashionPanel, nil, nil, nil, cc.p(0, -50), icon, nil, self.dir)
    else
        self.dir = self.dir + 2
        if self.dir > 7 then
            self.dir = 1
        end

        self:setPortrait("UserPanel", self.data.fashionIcon, nil, fashionPanel, nil, nil, nil, nil, nil, nil, self.dir)
    end
end

function SeeEquipmentDlg:equipmentTouch(sender, type)
    if type == ccui.TouchEventType.ended then
        if self.selcetImage  then
            self.selcetImage:removeFromParent()
            self.selcetImage = nil
        end

        self.selcetImage = ccui.ImageView:create(ResMgr.ui.bag_item_select_img, ccui.TextureResType.plistType)
        self.selcetImage:setPosition(sender:getContentSize().width / 2, sender:getContentSize().height / 2)
        self.selcetImage:setAnchorPoint(0.5, 0.5)
        local tag = sender:getTag()
        local rect = self:getBoundingBoxInWorldSpace(sender)

        if sender:getTag() >= 1 and sender:getTag() <= 4 then
            if nil ~= self.equipment[EQUIPMENT[tag]] then
                self.equipment[EQUIPMENT[tag]].pos = nil
                if InventoryMgr:isEquipFloat(self.equipment[EQUIPMENT[tag]]) then
                    InventoryMgr:showEquipByEquipment(self.equipment[EQUIPMENT[tag]], rect, true)
                else
                    local dlg = DlgMgr:openDlg("EquipmentInfoCampareDlg")
                    dlg:setFloatingCompareInfo(self.equipment[EQUIPMENT[tag]])
                end
            end
        elseif sender:getTag() > 4 and sender:getTag() <= 8 then
            if nil ~= self.equipment[EQUIPMENT[tag]] then
                self.equipment[EQUIPMENT[tag]].pos = nil
                InventoryMgr:showJewelryByJewelry(self.equipment[EQUIPMENT[tag]], rect, true)
            elseif self.equipment[BACK_JEWELRY[tag]] then
                self.equipment[BACK_JEWELRY[tag]].pos = nil
                InventoryMgr:showJewelryByJewelry(self.equipment[BACK_JEWELRY[tag]], rect, true)
            end
        elseif sender:getTag() == 9 then  -- 法宝
            if nil ~= self.equipment[EQUIPMENT[tag]] then
                self.equipment[EQUIPMENT[tag]].pos = nil
                InventoryMgr:showArtifactByArtifact(self.equipment[EQUIPMENT[tag]], rect, true)
            elseif self.equipment[BACK_ARTIFACT[tag]] then
                self.equipment[BACK_ARTIFACT[tag]].pos = nil
                InventoryMgr:showArtifactByArtifact(self.equipment[BACK_ARTIFACT[tag]], rect, true)
            end
        end

        sender:addChild(self.selcetImage)
    end
end

-- 初值化装备面板
function SeeEquipmentDlg:initEquipment()
    local equipmentPanel = self:getControl("WearEquipPanel", Const.UIPanel)

    local function lisner(sender , type)
        if type == ccui.TouchEventType.ended then
            self:equipmentTouch(sender, type)
        end
    end

    for i = 1, 4 do

        --WDSY-8161panel为nil~,改控件名获取
        local panel = self:getControl("Panel" .. i, nil, equipmentPanel)
        self:initCell(self.equipment[EQUIPMENT[i]], panel)
        panel:setTag(i)
        panel:addTouchEventListener(lisner)
    end

    local jewelryPanel = self:getControl("JewelryPanel", Const.UIPanel)
    for i = 5, 8 do
        local panel = self:getControl("Panel" .. (i - 4), nil, jewelryPanel)
        -- 首饰如果当前位置没有数据，需要显示备用的
        if self.equipment[EQUIPMENT[i]] then
            self:initCell(self.equipment[EQUIPMENT[i]], panel)
        else
            self:initCell(self.equipment[BACK_JEWELRY[i]], panel)
        end
        panel:setTag(i)
        panel:addTouchEventListener(lisner)
    end

    local unOpenPanel = self:getControl("UnOpenPanel")
    for i = 9, 10 do  -- 法宝/符具
        local panel = self:getControl("Panel" .. (i - 8), nil, unOpenPanel)
        if EQUIPMENT[i] and self.equipment[EQUIPMENT[i]] then
            self:initCell(self.equipment[EQUIPMENT[i]], panel)
        elseif BACK_ARTIFACT[i] and self.equipment[BACK_ARTIFACT[i]] then
            self:initCell(self.equipment[BACK_ARTIFACT[i]], panel)
        end

        panel:setTag(i)
        panel:addTouchEventListener(lisner)
    end
end

function SeeEquipmentDlg:initCell(data, panel)
    if data == nil then return end
    self:setCtrlVisible("UnEquipPanel", false, panel)
    self:setCtrlVisible("EquipPanel", true, panel)
    local magicPath = InventoryMgr:getEquipEffect(data)

    local lastMagic = panel:getChildByName("magic")

    if lastMagic then
        lastMagic:removeFromParent()
    end

    local equipPanel = self:getControl("EquipPanel", nil, panel)
    local equiptImg = self:getControl("Image", Const.UIImage, equipPanel)
    local imgPath = ResMgr:getItemIconPath(data["icon"])
    equiptImg:loadTexture(imgPath)

    --[[
    -- 如果是备用装备，增加备用装备效果
    if data.pos > 10 and data.pos < 20 then
        gf:addEffectForBackEquip(equiptImg)
    end
    --]]
    if data.req_level and data.item_type == ITEM_TYPE.EQUIPMENT then
        self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, data.req_level,
            false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    -- 法宝的等级
    if data.level and data.item_type == ITEM_TYPE.ARTIFACT then
        self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, data.level,
            false, LOCATE_POSITION.LEFT_TOP, 19)
    end

    if data.item_type == ITEM_TYPE.ARTIFACT and data.item_polar then
        InventoryMgr:addArtifactPolarImage(equiptImg, data.item_polar)
    end

    if magicPath then
        local magic = ccui.ImageView:create(magicPath, ccui.TextureResType.plistType)
        panel:addChild(magic)
        local size = equipPanel:getContentSize()
        magic:setPosition(size.width / 2, size.height / 2)
        magic:setName("magic")
    end

    -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(data) then
        InventoryMgr:removeLogoBinding(equiptImg)
        InventoryMgr:addLogoTimeLimit(equiptImg)
    elseif InventoryMgr:isLimitedItem(data) then
        InventoryMgr:removeLogoTimeLimit(equiptImg)
        InventoryMgr:addLogoBinding(equiptImg)
    else
        InventoryMgr:removeLogoTimeLimit(equiptImg)
        InventoryMgr:removeLogoBinding(equiptImg)
    end

end

-- 初值化玩家信息面板
function SeeEquipmentDlg:initPalyerInfo(data)

    -- 玩家名字
    self:setLabelText("NameLabel_1", gf:getRealName(data["name"]))
    self:setLabelText("NameLabel_2", gf:getRealName(data["name"]))

    -- 玩家等级

    if data["upgrade/type"] == 0 then
        self:setLabelText("LevelLabel", string.format(CHS[4100584], data.level))
    else
        self:setLabelText("LevelLabel", string.format(CHS[4100585], data.level, gf:getChildName(data["upgrade/type"]), data["upgrade/level"]))
    end


    -- 玩家帮派
    local partyLabel = self:getControl("PartyLabel", Const.UILabel)
    if data["partyName"] == "" then
        data["partyName"] = CHS[3003613]
    end
    partyLabel:setString(data["partyName"])

end

function SeeEquipmentDlg:cleanup()
    if self.selcetImage  then
        self.selcetImage:removeFromParent()
        self.selcetImage = nil
    end
end
return SeeEquipmentDlg
