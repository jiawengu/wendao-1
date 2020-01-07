-- EquipmentOneClickUpgradeDlg.lua
-- Created by Jul/27/2015
-- 一键改造

local EquipmentOneClickUpgradeDlg = Singleton("EquipmentOneClickUpgradeDlg", Dialog)

local MAX_REBUILD = 12

function EquipmentOneClickUpgradeDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("GoldBackImage", self.onGoldCoinAddButton)
    self:bindCheckBoxListener("BindCheckBox", self.onCheckBox)

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_INVENTORY")
    self.start = false

    self:updateCoin()
end

function EquipmentOneClickUpgradeDlg:setData(pos)
    self.pos = pos
    local equip = InventoryMgr:getItemByPos(self.pos)
    self.rebuild_level = equip.rebuild_level + 1
    if self.rebuild_level >= 12 then
        self.rebuild_level = 12
    end
    self.wanted_rebuild_level = self.rebuild_level
    if EQUIP_TYPE.WEAPON == equip.equip_type then
        self:setCtrlVisible("Label4", true)
        self:setCtrlVisible("Label5", false)
        self.useItemName = CHS[4000103]
        self.itemPrice = 2388
    else
        self:setCtrlVisible("Label4", false)
        self:setCtrlVisible("Label5", true)
        self.useItemName = CHS[4000104]
        self.itemPrice = 648
    end
    self:setUseItmeInfo()

    -- 武器显示超级灵石、防具显示超级晶石,json中默认显示灵石
    if equip.equip_type ~= EQUIP_TYPE.WEAPON then
        self:setLabelText("Label4", CHS[4200479])
    end
end

function EquipmentOneClickUpgradeDlg:startUpgrade()
    self.lastTime = gfGetTickCount()

    local equip = InventoryMgr:getItemByPos(self.pos)

    if not equip or not equip.rebuild_level or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end


    if equip.rebuild_level >= self.wanted_rebuild_level then
        gf:ShowSmallTips(string.format(CHS[3002476], self.wanted_rebuild_level) )
        self:setStopInfo()
        return false
    end

    if EquipmentMgr:getUpgradeCost(equip.req_level) > Me:queryBasicInt('cash') then
        self:setBtnVisible(false)
        gf:askUserWhetherBuyCash(EquipmentMgr:getUpgradeCost(equip.req_level) - Me:queryBasicInt('cash') )
        return false
    end

    local para
    local totalMoney = 0
    if self:isCheck("BindCheckBox") then
        para = "1"
        totalMoney = Me:getTotalCoin()
    else
        para = "0"
        totalMoney = Me:queryBasicInt("gold_coin")
    end
--[[ -- 由服务器给不足提示，因为可能99%不需要消耗6个，但是客户端不知道消耗几个
    if totalMoney < self.itemPrice then
        self:setBtnVisible(false)
        gf:askUserWhetherBuyCoin()
        return false
    end
--]]
    EquipmentMgr:cmdUpgradeEquip(self.pos, para)
    return true
end

function EquipmentOneClickUpgradeDlg:isFightNeedClose()
    if self.start and self.pos and self.pos <= 10 then
        return true
    end
end

function EquipmentOneClickUpgradeDlg:cleanup()
    if self:isFightNeedClose() and Me:isInCombat() then
        gf:ShowSmallTips(CHS[4300326])
    end
end

function EquipmentOneClickUpgradeDlg:onReduceButton(sender, eventType)
    if not self.pos or not InventoryMgr:getItemByPos(self.pos) then return end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end

    local curLevel = equip.rebuild_level

    if self.wanted_rebuild_level > curLevel + 1 then
        self.wanted_rebuild_level = self.wanted_rebuild_level - 1
        self:setUseItmeInfo()
    else
        gf:ShowSmallTips(string.format(CHS[3002477], curLevel))
    end
end

function EquipmentOneClickUpgradeDlg:onAddButton(sender, eventType)
    if self.wanted_rebuild_level < MAX_REBUILD then
        self.wanted_rebuild_level = self.wanted_rebuild_level + 1
        self:setUseItmeInfo()
    else
        gf:ShowSmallTips(CHS[3002478])
    end
end

function EquipmentOneClickUpgradeDlg:setUseItmeInfo()
    local reduceButton = self:getControl("ReduceButton")
    local addButton = self:getControl("AddButton")

    if not self.pos or not InventoryMgr:getItemByPos(self.pos) then return end
    local equip = InventoryMgr:getItemByPos(self.pos)
    if equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end
    local curLevel = equip.rebuild_level

    if self.wanted_rebuild_level <= curLevel + 1 then
        gf:grayImageView(reduceButton)
    else
        gf:resetImageView(reduceButton)
    end

    if self.wanted_rebuild_level >= MAX_REBUILD then
        gf:grayImageView(addButton)
    else
        gf:resetImageView(addButton)
    end

    -- 数量
    local numberPanel = self:getControl("NumPanel")
    local numLabel = self:getControl("NumLabel", Const.UILabel, numberPanel)
    numLabel:setString(self.wanted_rebuild_level..CHS[3002479])
    local numLabel1 = self:getControl("NumLabel_1", Const.UILabel, numberPanel)
    numLabel1:setString(self.wanted_rebuild_level..CHS[3002479])
end

-- 开始、停止按钮显示，isOneClick为是否一键改造状态
function EquipmentOneClickUpgradeDlg:setBtnVisible(isOneClick)
    local stopBtn = self:getControl("StopButton")
    local startBtn = self:getControl("StartButton")
    stopBtn:setVisible(true)
    startBtn:setVisible(false)

    self:setCtrlVisible("StartButton", not isOneClick)
    self:setCtrlVisible("StopButton", isOneClick)
end

function EquipmentOneClickUpgradeDlg:onStartButton(sender, eventType)
    local equip = InventoryMgr:getItemByPos(self.pos)


    if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end

    if equip.rebuild_level >= MAX_REBUILD then
        gf:ShowSmallTips(CHS[4300018])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onStartButton") then
        return
    end

    self.start = true
    local canstart = self:startUpgrade()

    if canstart and equip.rebuild_level < self.wanted_rebuild_level then
        self:setBtnVisible(true)
    end
end

-- 金元宝按钮
function EquipmentOneClickUpgradeDlg:onGoldCoinAddButton(sender, eventType)
    DlgMgr:openDlg("OnlineRechargeDlg")
end

function EquipmentOneClickUpgradeDlg:onStopButton(sender, eventType)
    self.start = false
    self:setBtnVisible(false)
end

function EquipmentOneClickUpgradeDlg:onCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        gf:ShowSmallTips(CHS[3002480])
    end

end

function EquipmentOneClickUpgradeDlg:setStopInfo()
    local equip = InventoryMgr:getItemByPos(self.pos)

    if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end

    self.rebuild_level = equip.rebuild_level + 1
    if self.rebuild_level >= MAX_REBUILD then
        self.rebuild_level = MAX_REBUILD
    end
    self.wanted_rebuild_level = self.rebuild_level
    self:onStopButton()
    self:setUseItmeInfo()
end

function EquipmentOneClickUpgradeDlg:updateCoin()
    local gold_coin = Me:queryBasicInt('gold_coin')
    local goldText = gf:getArtFontMoneyDesc(tonumber(gold_coin))
    self:setNumImgForPanel("GoldValuePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.MID, 23)

    local silver_coin = Me:queryBasicInt('silver_coin')
    local silverText = gf:getArtFontMoneyDesc(tonumber(silver_coin))
    self:setNumImgForPanel("SilverValuePanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23)
end

function EquipmentOneClickUpgradeDlg:MSG_INVENTORY(data)
    if data.count == 0 then return end
    local equip = InventoryMgr:getItemByPos(self.pos)

    if not equip or equip.item_type ~= ITEM_TYPE.EQUIPMENT then
        self:onCloseButton()
        return
    end

end

function EquipmentOneClickUpgradeDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_EQUIP_UPGRADE_OK == data.notify  then
        local data_table = gf:split(data.para, "_")
        if data_table[2] and data_table[2] == "-1" then
            -- 服务器繁忙
            self:setStopInfo()
            return
        end

        self:setUseItmeInfo()
        if self.start then
            if gfGetTickCount() - (self.lastTime or 0) > 1000 then
                self:startUpgrade()
            else
                local stopBtn = self:getControl("StopButton")
                local function delayAction()
                    stopBtn:stopAllActions()
                    self:startUpgrade()
                end

                schedule(stopBtn , delayAction, (1000 - (gfGetTickCount() - self.lastTime)) / 1000)
            end
        end

        self:updateCoin()
    end

end

return EquipmentOneClickUpgradeDlg
