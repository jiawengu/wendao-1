-- ActiveDrawDlg.lua
-- Created by songcw Oct/14/2016
-- 光棍节抽奖

local BachelorDrawDlg = Singleton("BachelorDrawDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local REWARD_MAX = 8

BachelorDrawDlg.needCount = 0
BachelorDrawDlg.startPos = 1
BachelorDrawDlg.curPos = 1
BachelorDrawDlg.delay = 1
BachelorDrawDlg.updateTime = 1   

BachelorDrawDlg.activeValue = nil

BachelorDrawDlg.BONUS_INFO = {
    [1] = {chs = CHS[4300125], petPortrait = 06177}, -- 随机变异宠物
    [2] = {icon = ResMgr.ui.item_common, chs = CHS[4300126], isPlist = 1}, -- 商城道具
    [3] = {icon = ResMgr.ui.no_bachelor_pick, chs = CHS[4300127]}, -- 未中奖
    [4] = {chs = CHS[4300128], itemIcon = 01309},
    [5] = {chs = CHS[4300129], itemIcon = 01310},
    [6] = {chs = CHS[4300130], icon = ResMgr.ui.big_silver, isPlist = 1},
    [7] = {icon = ResMgr.ui.no_bachelor_pick, chs = CHS[4300127]}, -- 未中奖
    [8] = {icon = ResMgr.ui.big_change_card, chs = CHS[6200003], isPlist = 1},
}

function BachelorDrawDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ReentryAsktaoDlg")
end

function BachelorDrawDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
    GiftMgr.lastIndex = "WelfareButton10"
    self:resetRewards()
    
    self.isRotating = false
    
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_FESTIVAL_LOTTERY_RESULT")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_OPEN_LIVENESS_LOTTERY")    
    
    self:setLabelText("NoteLabel_2", CHS[4300131])
    self:setDrawCount()
    self:updateLayout("WelfarePanel")
    
    for i = 1, REWARD_MAX do
        local panel = self:getControl("BonusPanel_" .. i)        
        self:bindListener("BonusImage", self.onRewardIconButton, panel)
    end
end

function BachelorDrawDlg:onRewardIconButton(sender, eventType)
    local reward = sender.data.reward
    local rect = self:getBoundingBoxInWorldSpace(sender)

    -- 奖励格式
    if reward then    
        local rewardInfo = RewardContainer:getRewardInfo(reward)        
        local dlg
        if rewardInfo.desc then
            dlg = DlgMgr:openDlg("BonusInfoDlg")
        else
            dlg = DlgMgr:openDlg("BonusInfo2Dlg")
        end
        dlg:setRewardInfo(rewardInfo)
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
    end

    -- 道具
    local item = sender.data.item
    if item then
        local dlg = DlgMgr:openDlg("ItemInfoDlg")
        item["isGuard"] = InventoryMgr:getIsGuard(item.name)    
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
    end
end

function BachelorDrawDlg:setDrawCount()
    local count = InventoryMgr:getAmountByName(CHS[4300132])
    self:setLabelText("NoteLabel_1", string.format(CHS[4300134], count))
    self:updateLayout("SignPanel")
end

function BachelorDrawDlg:resetRewards()
    for i = 1, REWARD_MAX do
        local panel = self:getControl("BonusPanel_" .. i)
        self:setCtrlVisible("ChosenImage", false, panel)
        
        if self.BONUS_INFO[i].icon then
            if self.BONUS_INFO[i].isPlist == 1 then
                self:setImagePlist("BonusImage", self.BONUS_INFO[i].icon, panel)
            else
                self:setImage("BonusImage", self.BONUS_INFO[i].icon, panel)
            end
            
            local image = self:getControl("BonusImage", nil, panel)
            if self.BONUS_INFO[i].icon == ResMgr.ui.no_bachelor_pick then
                local sss = image:getPositionY() - 31
                image:setPositionY(sss) 
                
                panel:requestDoLayout()
            end
        elseif self.BONUS_INFO[i].petPortrait then
            self:setImage("BonusImage", ResMgr:getSmallPortrait(self.BONUS_INFO[i].petPortrait), panel)
        elseif self.BONUS_INFO[i].itemIcon then
            self:setImage("BonusImage", ResMgr:getItemIconPath(self.BONUS_INFO[i].itemIcon), panel)
        else
            local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.BONUS_INFO[i].chs))
            self:setImage("BonusImage", path, panel)
        end

        self:setItemImageSize("BonusImage", panel)
        
        local image = self:getControl("BonusImage", nil, panel)
        image.data = self.BONUS_INFO[i]
        self:setLabelText("NameLabel", self.BONUS_INFO[i].chs, panel)
    end
end

-- 开始转圈
function BachelorDrawDlg:onUpdate()
    if not self.isRotating then return end
    
    if self.isRotating and Me:isInCombat() and self.name == "AnniversaryDrawDlg" then
        self.isRotating = false
        gf:ShowSmallTips(CHS[7003041])
        return
    end
    
    if self.updateTime % self.delay ~= 0 then
        self.updateTime = self.updateTime + 1
        return
    end
    
    if self.curPos < self.needCount then
        -- 转五行
        self.delay = self:calcSpeed(self.curPos, self.needCount)
        local wuxPos = (self.curPos) % REWARD_MAX + 1
        local rollCtrl = self:getControl("ChosenImage", nil, "BonusPanel_" .. wuxPos)
        rollCtrl:setVisible(true)
        rollCtrl:setOpacity(255)
        self.curPos = self.curPos + 1
        if self.curPos ~= self.needCount then
            local timeT = self.delay * 0.03
            if timeT > 1 then timeT = 1 end
            rollCtrl:runAction(cc.FadeOut:create(timeT))
        else            
            rollCtrl:stopAllActions()
        end
    else
        self.isRotating = false
        self:setLastOperTime("lastTime", 0)
        --GiftMgr:drawBachelorReward(1) -- 领奖 
        self:draw(1)
    end
end

-- 1领奖    0抽奖
function BachelorDrawDlg:draw(flag)
    GiftMgr:drawBachelorReward(flag) 
end

-- 计算转圈间隔
function BachelorDrawDlg:calcSpeed(curPos, count)
    if count - curPos < 14 then
        local speed = 6 + (14 - (count - curPos)) * (14 - (count - curPos)) * 0.6
        return math.floor(speed)
    end

    return 6
end

function BachelorDrawDlg:onDrawButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self:isOutLimitTime("lastTime", 1000 * 10) then
        gf:ShowSmallTips(CHS[4300098])
        return
    end


    if self.isRotating then
        return 
    end
    
    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(string.format(CHS[4300135], 30))
        return
    end
    
    self:setLastOperTime("lastTime", gfGetTickCount())
    
    local count = InventoryMgr:getAmountByName(CHS[4300132])
    if count <= 0 then
        gf:ShowSmallTips(CHS[4300133])
        return
    end
     
    GiftMgr:drawBachelorReward(0)
end

function BachelorDrawDlg:MSG_FESTIVAL_LOTTERY_RESULT(data)
    if data.activeName ~= "singles_day_2016" or data.status == 0 then 
        -- status为1表示抽奖开始，0表示结束
        return
    end
    
    local ret = data.rewardIndex

    self.needCount = ret + 1 - self.startPos + math.random(4,5) * REWARD_MAX
    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1
    self.isRotating = true
    self:resetRewards()
end

function BachelorDrawDlg:MSG_INVENTORY(data)
    self:setDrawCount()
end

function BachelorDrawDlg:MSG_OPEN_LIVENESS_LOTTERY(data)
    self.activeValue = data.activeValue
    if self.activeValue then
        self:setLabelText("NoteLabel_2", string.format(CHS[4400009], self.activeValue))
    end
    
    self:updateLayout("WelfarePanel")
end

return BachelorDrawDlg
