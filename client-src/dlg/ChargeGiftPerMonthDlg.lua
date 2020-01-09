-- ChargeGiftPerMonthDlg.lua
-- Created by songcw Mar/17/2017
-- 月首充礼包

local ChargeGiftPerMonthDlg = Singleton("ChargeGiftPerMonthDlg", Dialog)

function ChargeGiftPerMonthDlg:init()
    self:bindListener("GetButton", self.onGetButton)

    -- 查询越首充的奖品
    GiftMgr:festivalLottery("month_charge_gift")

    self:hookMsg("MSG_MONTH_CHARGE_GIFT")
    self:hookMsg("MSG_FESTIVAL_LOTTERY")

    self:setData()
end

function ChargeGiftPerMonthDlg:setData()
    -- 王老板、
    self:setImage("WanglbImage", ResMgr:getBigPortrait(6011))

    self:setGiftInfo()
    self:setGetButtonState()

    self:setTimeInfo()
end

function ChargeGiftPerMonthDlg:setTimeInfo()
    if not self.rewardData then
        self:setLabelText("TimeLabel", "")

        self:setLabelText("TitleLabel", "")
    else
        self:setLabelText("TimeLabel", gf:getServerDate(CHS[5420147], self.rewardData.endTime))
        self:setLabelText("TitleLabel", string.format(CHS[4300240], gf:changeNumber(self.rewardData.month)))
    end
end

function ChargeGiftPerMonthDlg:setGiftInfo()
    if not self.rewardData then return end
    for i = 1, 4 do
        local panel = self:getControl("BonusPanel_" .. i)

        -- icon
        local img
        if self.rewardData[i].item_icon ~= "" then
            img = self:setImagePlist("BonusImage", self.rewardData[i].item_icon, panel)
        else
            img = self:setImage("BonusImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.rewardData[i].item_name)), panel)
        end
        self:setItemImageSize("BonusImage", panel)

        -- 限制交易
        if self.rewardData[i].item_gift == 1 then
            InventoryMgr:addLogoBinding(img)
        end

        -- 名称-数量
        self:setLabelText("BonusLabel", string.format("%s*%d", self.rewardData[i].item_name, self.rewardData[i].item_amount), panel)

        panel.data = self.rewardData[i]
        self:bindTouchEndEventListener(panel, self.onShowItemInfo)
    end
end

function ChargeGiftPerMonthDlg:onShowItemInfo(sender, eventType)
    local data = sender.data
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if InventoryMgr:getItemInfoByName(data.item_name) then
        InventoryMgr:showBasicMessageDlg(data.item_name, rect, true)
    else
        if data.item_name == CHS[6200003] then -- 随机变身卡
            local dlg = DlgMgr:openDlg("BonusInfo2Dlg")
            local rewardInfo = {
                basicInfo = {CHS[6200003]},
                imagePath = ResMgr.ui.big_change_card,
                limted = false,
                resType = 1,
                time_limited = false,
            }
            dlg:setRewardInfo(rewardInfo)
            dlg.root:setAnchorPoint(0, 0)
            dlg:setFloatingFramePos(rect)
        end
    end
end

function ChargeGiftPerMonthDlg:setGetButtonState()
    if not GiftMgr.month_charge_gift then return end
    if GiftMgr.month_charge_gift.amount == 0 then
        -- 未充值
        self:setCtrlEnabled("GetButton", true)
        self:setLabelText("NumLabel_1", CHS[4300241], "GetButton") -- 前往充值
        self:setLabelText("NumLabel_2",  CHS[4300241], "GetButton")
    elseif GiftMgr.month_charge_gift.amount == 1 then
        -- 充值未领取
        self:setCtrlEnabled("GetButton", true)
        self:setLabelText("NumLabel_1", CHS[4300242], "GetButton") -- 领取礼包
        self:setLabelText("NumLabel_2", CHS[4300242], "GetButton")
    elseif GiftMgr.month_charge_gift.amount == 2 then
        self:setLabelText("NumLabel_1", CHS[4300243], "GetButton") -- 已领取
        self:setLabelText("NumLabel_2", CHS[4300243], "GetButton")
        self:setCtrlEnabled("GetButton", false)
    end
end

function ChargeGiftPerMonthDlg:onGetButton(sender, eventType)
    if not self.rewardData then return end

    local keyStr = self:getLabelText("NumLabel_1", nil, sender)
    if keyStr == CHS[4300241] then
        if gf:getServerTime() > self.rewardData.endTime then
            gf:ShowSmallTips(CHS[4300249])
            self:onCloseButton()
            return
        else
            OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
        end
    elseif keyStr == CHS[4300242] then
        -- 处于禁闭状态
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        if InventoryMgr:getEmptyPosCount() == 0 then
            gf:ShowSmallTips(CHS[3002309])
            return
        end

        if gf:getServerTime() > self.rewardData.endTime then
            gf:ShowSmallTips(CHS[4300249])
            self:onCloseButton()
            return
        else
            GiftMgr:getMonthReward()
        end

  --      gf:confirm(tip,onConfirm,onCancel,needInput,hourglassTime,dlgTag,enterCombatNeedColse,onlyConfirm)
    elseif keyStr == CHS[4300243] then
    end
end

function ChargeGiftPerMonthDlg:MSG_MONTH_CHARGE_GIFT(data)
    self.rewardData = data
    self:setData()
end

function ChargeGiftPerMonthDlg:MSG_FESTIVAL_LOTTERY(data)
    self:setData()
end

return ChargeGiftPerMonthDlg
