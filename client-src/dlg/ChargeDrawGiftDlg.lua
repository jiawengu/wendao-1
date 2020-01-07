-- ChargeDrawGiftDlg.lua
-- Created by songcw Jan/27/2016
-- 充值抽奖界面

local ChargeDrawGiftDlg = Singleton("ChargeDrawGiftDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local cardInScreenNum = 7       -- 一个屏幕正常状态卡片个数
local minScale  = 0.7           -- 最小缩放
local minOpacity = 51           -- 最小透明度
local cardRoundCount    = 14    -- 每次增加的卡片
local durTime           = 1.5     -- 抽奖动画时间

function ChargeDrawGiftDlg:init()
    self:bindListener("MoreButton", self.onMoreButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("OneButton", self.onOneButton)
    self:bindListener("TenButton", self.onTenButton)
    self:bindListener("InfoButton", self.onInfoButton)
    
    -- 克隆单个奖项
    self.singelGiftPanel = self:getControl("MiddlePanel")
    self.singelGiftPanel:retain()
    self.singelGiftPanel:setAnchorPoint(cc.p(0.5, 0.5))  
    self.singelGiftPanel:setVisible(false)
    
    -- 抽奖动画播放标志
    self.isCartooning = false
    
    -- 新增的奖励牌起始位置
    self.startX = 0
    
    -- 奖励牌的总数
    self.cardCount = 0
    
    -- 抽奖动画init
    self:cartoonInit() 
    
    -- 设置本地数据，如果本地有缓存则设置
    self:setData()
    
    -- 设置次数
    self:MSG_UPDATE()
    
    -- 请求相关数据
    GiftMgr:requestReward()
    
    GiftMgr.lastIndex = "WelfareButton5"
    GiftMgr:setLastTime()
    
    self:hookMsg("MSG_LOTTERY_INFO")
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_UPDATE")
    
    self:updateLayout("MainPanel")
end

function ChargeDrawGiftDlg:setRewardCard(panel)
    if not panel then return end
    local width = self:getControl("DrawItemPanel"):getContentSize().width * 0.5    
    local destX = self:getBoundingBoxInWorldSpace(self.singelGiftPanel).x + self.singelGiftPanel:getContentSize().width * 0.5 
    local x = self:getBoundingBoxInWorldSpace(panel).x    
    local disX = math.abs(destX - x)
    local percent = 0   -- 偏离中心的百分比
    
    if disX < width then
        percent = 1 - disX / width        
    end
    
    if percent > 0.85 then
        panel:setLocalZOrder(10)
    elseif percent > 0.6 then
        panel:setLocalZOrder(8)
    elseif percent > 0.35 then
        panel:setLocalZOrder(6)
    else
        panel:setLocalZOrder(1)
    end    
    panel:setScale(minScale + (1 - minScale) * percent)
    local op = minOpacity + (255 - minOpacity) * percent    
    panel:setOpacity(op)
end

function ChargeDrawGiftDlg:onUpdate()
    if not self.isCartooning then return end

    for i = 1,self.cardCount do
        local panel = self.stagePanel:getChildByTag(i)
        if panel then
            self:setRewardCard(panel)
        end
    end
end

-- 获取每张牌间距
function ChargeDrawGiftDlg:getCardMargin()   
    local stagePanel = self:getControl("DrawItemPanel")
    local stagePanelSize = stagePanel:getContentSize()    
    local magin = (stagePanelSize.width - self.singelGiftPanel:getContentSize().width) / (cardInScreenNum - 1)
    return  magin
end

function ChargeDrawGiftDlg:cartoonInit() 
    -- 创建移动面板
    if not self.stagePanel then
        self.stagePanel = self:getControl("DrawItemPanel"):clone()
        self:getControl("DrawItemPanel"):addChild(self.stagePanel)
    end
   
    self.stagePanel:removeAllChildren()
    self.stagePanel:setAnchorPoint(cc.p(0, 0))
    self.stagePanel:setPosition(cc.p(0, 0))

    local singelSize = self.singelGiftPanel:getContentSize()
    local margin = self:getCardMargin()
    for i = 1, cardInScreenNum do
        self.cardCount = self.cardCount + 1
        local panel = self.singelGiftPanel:clone()
        panel:setVisible(true)
        panel:setTag(self.cardCount)
        panel:setPosition(cc.p(singelSize.width * 0.5 + margin * (i - 1), self.stagePanel:getContentSize().height * 0.5))        
        self.stagePanel:addChild(panel)
        self:setRewardCard(panel)     
        self:setCtrlVisible("ItemBackImage", false, panel)   
    end
    
    self.startX = singelSize.width * 0.5 + margin * (cardInScreenNum - 1)
end

function ChargeDrawGiftDlg:setRewardIcon(name, panel)
    if gf:findStrByByte(name, CHS[3000089]) then
        -- 妖石
        self:setImagePlist("ItemImage", ResMgr.ui["item_common"], panel)
        self:setItemImageSize("ItemImage", panel)
    elseif gf:findStrByByte(name, CHS[3000782]) then            
        self:setImagePlist("ItemImage", ResMgr.ui["big_equip"], panel)
    elseif gf:findStrByByte(name, CHS[3002147]) then            
        self:setImagePlist("ItemImage", ResMgr.ui["daohang"], panel)
    elseif gf:findStrByByte(name, CHS[6200003]) then  
        self:setImagePlist("ItemImage", ResMgr.ui["big_change_card"], panel)   
    else
        local iconPath , isPlist = ResMgr:getIconPathByName(name)
        if isPlist then
            self:setImagePlist("ItemImage", iconPath, panel)
        else
            self:setImage("ItemImage", iconPath, panel)
            self:setItemImageSize("IconImage", panel)
        end
    end
end

function ChargeDrawGiftDlg:addCard(addCount) 
    if addCount < 4 then return end
    for i = 1, addCount do
        self.cardCount = self.cardCount + 1
        local panel = self.singelGiftPanel:clone()
        panel:setVisible(true)
        panel:setTag(self.cardCount)
        panel:setPosition(cc.p(self.startX + self:getCardMargin() * i, self.stagePanel:getContentSize().height * 0.5))        
        self.stagePanel:addChild(panel)
        self:setRewardCard(panel)
        local nameTab = GiftMgr.chargeDrawGiftDlgData.allReward
        local name = nameTab[math.random(1,#nameTab)]       
        self:setRewardIcon(name, panel)
        
        if i == addCount - 3 and GiftMgr.chargeDrawGiftDlgReward then
            -- 停留的
            local pickName = GiftMgr.chargeDrawGiftDlgReward
            self:setRewardIcon(pickName, panel)         
        end
    end
    
    self.startX = self.startX + self:getCardMargin() * addCount
end

function ChargeDrawGiftDlg:cleanup()
    self:releaseCloneCtrl("singelGiftPanel")
    if self.stagePanel then
        self.stagePanel:removeFromParent()
        self.stagePanel = nil
    end
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CANCEL_LOTTERY)
end

function ChargeDrawGiftDlg:endCartoon()
    self.isCartooning = false    

    self:setCtrlEnabled("OneButton", true)
    self:setCtrlEnabled("TenButton", true)
    
    -- 通知领取奖励
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FETCH_LOTTERY)        
    
    -- 防止每次一直加载，所以超过3次则每次删除部分panel
    if self.cardCount > cardRoundCount * 3 then
        local removeCount = 0
        for i = 1,self.cardCount do
            local panel = self.stagePanel:getChildByTag(i)
            if panel then
                if removeCount < cardRoundCount then
                    panel:removeFromParent()
                    removeCount = removeCount + 1
                else
                    panel:setPositionX(panel:getPositionX() - removeCount * self:getCardMargin())              
                end
            end
        end
        self.stagePanel:setPositionX(self.stagePanel:getPositionX() + removeCount * self:getCardMargin())
        self.startX = self.startX - removeCount * self:getCardMargin()
    end    
end

function ChargeDrawGiftDlg:onMoreButton(sender, eventType)
    if not GiftMgr.chargeDrawGiftDlgData then return end
    DlgMgr:openDlg("AllDrawGiftDlg")
end

function ChargeDrawGiftDlg:onAddButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("OnlineRechargeDlg")
    if dlg then 
        dlg:reopen()
        DlgMgr:reopenRelativeDlg("OnlineRechargeDlg")
    else 
        OnlineMallMgr:openOnlineMall("OnlineRechargeDlg")
    end
end

function ChargeDrawGiftDlg:beginCartoon()
    self:addCard(cardRoundCount)
    local margin = self:getCardMargin()
    local moveAct1 = cc.MoveBy:create(durTime * 0.5, cc.p(-(margin * (cardRoundCount )) * 0.5, 0))
    local actUp = cc.EaseSineIn:create(moveAct1)

    local moveAct2 = cc.MoveBy:create(durTime * 0.5, cc.p(-(margin * (cardRoundCount)) * 0.5, 0))
    local actSlow = cc.EaseSineOut:create(moveAct2)    

    local endCallBackfunc = cc.CallFunc:create(function()  self:endCartoon() end)
    self.stagePanel:runAction(cc.Sequence:create(actUp, actSlow, endCallBackfunc))
end

function ChargeDrawGiftDlg:isCanDraw(times)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return false
    end
    
    if GameMgr.inCombat then
        gf:ShowSmallTips(CHS[3002307])
        return false
    end
    
    if Me:queryBasicInt("lottery_times") < times then
        gf:ShowSmallTips(CHS[3002308])
        return false
    end
    
    if InventoryMgr:getEmptyPosCount() == 0 then
        gf:ShowSmallTips(CHS[3002309])
        return false
    end
    
    if PetMgr:getFreePetCapcity() <= 0  then
        gf:ShowSmallTips(CHS[3002310])
        return false
    end
    
    return true
end

function ChargeDrawGiftDlg:onOneButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end
    
    if self:checkSafeLockRelease("onOneButton", sender, eventType) then
        return
    end
    
    if self.isCartooning or not GiftMgr.chargeDrawGiftDlgData then return end
    if not self:isCanDraw(1) then
        self:setCtrlEnabled("OneButton", true)
        self:setCtrlEnabled("TenButton", true)
        return
    end
    
    self.isCartooning = true
    self:setCtrlEnabled("OneButton", false)
    self:setCtrlEnabled("TenButton", false)
    
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DRAW_LOTTERY, 1)
end

function ChargeDrawGiftDlg:onTenButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if self:checkSafeLockRelease("onTenButton", sender, eventType) then
        return
    end
    
    if self.isCartooning or not GiftMgr.chargeDrawGiftDlgData then return end
    if not self:isCanDraw(10) then
        self:setCtrlEnabled("OneButton", true)
        self:setCtrlEnabled("TenButton", true)
        return
    end    
    
    self.isCartooning = true
    self:setCtrlEnabled("OneButton", false)
    self:setCtrlEnabled("TenButton", false)
  
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_DRAW_LOTTERY, 2)
end

function ChargeDrawGiftDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ChargeDrawGiftRuleDlg")
end


function ChargeDrawGiftDlg:getRewardType(rewardData)
    local rewardList = {}
    local rewardStr = ""
    for i, name in pairs(rewardData) do
        rewardStr = rewardStr .. name
    end
    
    return rewardStr
end

function ChargeDrawGiftDlg:setData()
    local data = GiftMgr.chargeDrawGiftDlgData
    if not data then return end
    local rewardList = self:getRewardType(data.curReward)
    local listPanel = self:getControl("ItemListPanel")
    listPanel:removeAllChildren()
    local rewardContainer  = RewardContainer.new(rewardList, listPanel:getContentSize(), nil, nil, true, 20)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(10, listPanel:getContentSize().height / 2)
    listPanel:addChild(rewardContainer)
    
    local panel = self:getControl("InfoPanel")
    self:setLabelText("TitleLabel", CHS[3002311] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.startTime)) .. CHS[3002312] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.endTime)), panel)
    
end

function ChargeDrawGiftDlg:MSG_UPDATE(data)
    local timePanel = self:getControl("DrawTimesPanel")
    self:setLabelText("TitleLabel", CHS[3002313] .. Me:queryBasicInt("lottery_times") .. CHS[3002314], timePanel)
end

function ChargeDrawGiftDlg:MSG_LOTTERY_INFO(data)
    self:setData()
end

function ChargeDrawGiftDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_DRAW_LOTTERY == data.notify then
        performWithDelay(self.root,function ()
            self:beginCartoon() 
        end, 0)              
    elseif NOTIFY.NOTIFY_FETCH_DONE == data.notify then

    end
end

return ChargeDrawGiftDlg
