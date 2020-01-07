-- OnlineRechargeGiftDlg.lua
-- Created by huangzz Sep/07/2018
-- 充值权益领取界面

local OnlineRechargeGiftDlg = Singleton("OnlineRechargeGiftDlg", Dialog)

local CFG_INFO = {
    {type = "lottery_times", name = CHS[5400658], icon = ResMgr.ui.welfare_recharge_gift, unit = CHS[5400676]}, -- 充值好礼
    {type = "recharge_score", name = CHS[5400659], icon = ResMgr.ui.welfare_recharge_score, unit = CHS[5400677]}, -- 充值积分
    {type = "consume_score", name = CHS[5400660], icon = ResMgr.ui.welfare_consume_score, unit = CHS[5400677]}, -- 消费积分
    {type = "insider_sliver_coin", name = CHS[5400673], icon = ResMgr.ui.welfare_first_recharge, unit = CHS[5400678]}, -- 仙班打折返还元宝
    {type = "recharge_sliver_coin", name = CHS[5400674], icon = ResMgr.ui.welfare_first_recharge, unit = CHS[5400678]}, -- 充值积分返还元宝
    {type = "consume_sliver_coin", name = CHS[5400675], icon = ResMgr.ui.welfare_first_recharge, unit = CHS[5400678]}, -- 消费积分返还元宝
}

function OnlineRechargeGiftDlg:init()
    self:bindListener("CommunityButton", self.onCommunityButton)
    self:bindListener("GiftPanel", self.onGiftPanel)

    self.giftPanel = self:retainCtrl("GiftPanel")
end

function OnlineRechargeGiftDlg:setData(data)
    local listView = self:getControl("ListView")
    listView:removeAllItems()
    for i = 1, #CFG_INFO do
        if data[CFG_INFO[i].type] and data[CFG_INFO[i].type].num > 0 then
            local cell = self.giftPanel:clone()
            CFG_INFO[i].num = data[CFG_INFO[i].type].num
            self:setCellData(cell, CFG_INFO[i], i)
            listView:pushBackCustomItem(cell)
        end
    end

    -- 截止时间
    self:setLabelText("Label_2", gf:getServerDate(CHS[4100331], data.end_time), "NotePanel")
end

function OnlineRechargeGiftDlg:setCellData(cell, data, index)
    self:setCtrlVisible("BKImage_2", index % 2 == 0, cell)

    self:setImage("GoodsImage", data.icon, cell)
    self:setItemImageSize("GoodsImage", cell)
    self:setLabelText("NameLabel", data.name, cell)
    self:setLabelText("ValidTimeLabel", data.num .. data.unit, cell)
end

-- 领取奖励
function OnlineRechargeGiftDlg:onCommunityButton(sender, eventType)
    gf:confirm(string.format(CHS[5400680], Me:getName()), function()
        gf:CmdToServer("CMD_GET_AAA_CHARGE_BONUS", {})
    end)
end

return OnlineRechargeGiftDlg
