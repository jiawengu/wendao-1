-- FirstChargeGiftDlg.lua
-- Created by songcw Jan/25/2016
-- 首充奖励界面

local DataObject = require("core/DataObject")
local FirstChargeGiftDlg = Singleton("FirstChargeGiftDlg", Dialog)

local REWARD_INFO = {
    [0] = CHS[7190018],  -- 宠物白果儿
    [1] = CHS[7190021],  -- 云霄长老元神
    [2] = CHS[7190022],  -- 玉柱长老元神
    [3] = CHS[7190023],  -- 斗阙长老元神
    [4] = CHS[7190024],  -- 白骨长老元神
    [5] = CHS[3001259],  -- 宠物强化丹
    [6] = CHS[3001147],  -- 超级仙风散
    [7] = CHS[3002595],  -- 血池
    [8] = CHS[3002598],  -- 灵池
    [9] = CHS[4000357], -- 驯兽决
}

local SPIRIT_TO_GUARD = {
    [CHS[7190021]] = CHS[3000523], --云霄长老
    [CHS[7190022]] = CHS[3000524], --玉柱长老
    [CHS[7190023]] = CHS[3000525], --斗阙长老
    [CHS[7190024]] = CHS[3000528], --白骨长老
}

function FirstChargeGiftDlg:init()
    self:bindListener("GotButton", self.onGotButton)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("ChargeButton", self.onChargeButton)
    
    -- 请求首充状态
--    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CAN_FETCH_SHOUCHONG_GIFT)
    local firstState = GiftMgr:getWelfareData()
    self:setFirstState(firstState.firstChargeState)
    
    self:initReward()
    
    self:hookMsg("MSG_SHOUCHONG_CARD_INFO")
    self:hookMsg("MSG_OPEN_WELFARE")
    GiftMgr.lastIndex = "WelfareButton4"
    GiftMgr:setLastTime()
end

function FirstChargeGiftDlg:initReward()
    -- 宠物白果儿
    local panel = self:getControl("ItemImagePanel")
    self:setImage("ItemImage", ResMgr:getSmallPortrait(06320), panel)
    self:setItemImageSize("ItemImage", panel)
    local itemImage = self:getControl("ItemImage", nil, panel)
    InventoryMgr:addLogoBinding(itemImage)
    self:bindTouchEndEventListener(panel, function()
        gf:CmdToServer("CMD_SHOUCHONG_CARD_INFO", {type = CHS[3001218], name = CHS[7190018]})
    end)

    -- 守护json文件中从1开始
    for i = 1, 4 do
        local guardIcon = GuardMgr:getGuardInfoByKey(SPIRIT_TO_GUARD[REWARD_INFO[i]], "icon")
        local imgPath = ResMgr:getSmallPortrait(guardIcon)
        local panel = self:getControl("ItemImagePanel" .. i)
        panel:setTag(i)
        self:setImage("ItemImage", imgPath, panel)
        self:setItemImageSize("ItemImage", panel)
        self:bindTouchEndEventListener(panel, self.onShowItemInfo)
    
        -- 限制交易
        local itemImage = self:getControl("ItemImage", nil, panel)
        InventoryMgr:addLogoBinding(itemImage)
    end
    
    -- 物品json文件中从5开始
    for i = 5, 9 do
        local panel = self:getControl("ItemImagePanel" .. i)
        panel:setTag(i)
        self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(REWARD_INFO[i])), panel)
        self:setItemImageSize("ItemImage", panel)
        self:bindTouchEndEventListener(panel, self.onShowItemInfo)
        
        -- 限制交易
        local itemImage = self:getControl("ItemImage", nil, panel)
        InventoryMgr:addLogoBinding(itemImage)
    end
    
    self:setCtrlEnabled("GotButton", false)
end

function FirstChargeGiftDlg:onShowItemInfo(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(REWARD_INFO[sender:getTag()], rect, true)
end

function FirstChargeGiftDlg:onGotButton(sender, eventType)
end

function FirstChargeGiftDlg:onGetButton(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_SHOUCHONG_GIFT)
end

function FirstChargeGiftDlg:onChargeButton(sender, eventType)    
    local dlg = DlgMgr:getDlgByName("OnlineRechargeDlg")
    if dlg then 
        dlg:reopen()
        DlgMgr:reopenRelativeDlg("OnlineRechargeDlg")
    else 
        OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
    end
end

function FirstChargeGiftDlg:setFirstState(state)
    -- 隐藏按钮
    self:setCtrlVisible("GotButton", false)
    self:setCtrlVisible("GetButton", false)
    self:setCtrlVisible("ChargeButton", false)    

    if state == 0 then
        -- 未充值
        self:setCtrlVisible("ChargeButton", true)
    elseif state == 1 then
        -- 已经充值未领取
        self:setCtrlVisible("GetButton", true)
    elseif state == 2 then
        -- 已经充值已经领取
        self:setCtrlVisible("GotButton", true)
    end
end

function FirstChargeGiftDlg:MSG_OPEN_WELFARE(data)
    self:setFirstState(data.firstChargeState)
end

-- 名片信息回来
function FirstChargeGiftDlg:MSG_SHOUCHONG_CARD_INFO(data)
    local cardInfo = data["cardInfo"]
    if data.type == CHS[6000079] then       -- 宠物
        local dlg =  DlgMgr:openDlg("PetCardDlg")
        local objcet = DataObject.new()
        objcet:absorbBasicFields(cardInfo)
        dlg:setPetInfo(objcet)
    end
end

return FirstChargeGiftDlg
