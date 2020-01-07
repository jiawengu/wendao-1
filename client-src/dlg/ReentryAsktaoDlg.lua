-- ReentryAsktaoDlg.lua
-- Created by songcw Aug/5/2016
-- 再续前缘界面

local ReentryAsktaoDlg = Singleton("ReentryAsktaoDlg", Dialog)


local REWARD_MAX = 8

ReentryAsktaoDlg.needCount = 0
ReentryAsktaoDlg.startPos = 1
ReentryAsktaoDlg.curPos = 1
ReentryAsktaoDlg.delay = 1
ReentryAsktaoDlg.updateTime = 1

local BonusInfo = {
    [1] = {icon = ResMgr.ui.daohang,    chs = CHS[3000049]},
    [2] = {icon = ResMgr.ui.experience, chs = CHS[3002167]},
    [3] = {icon = ResMgr.ui.pot_icon,   chs = CHS[3002238]},
    [4] = {chs = CHS[4000383]},
    [5] = {chs = CHS[3001147]},
    [6] = {chs = CHS[3001146]},
    [7] = {chs = CHS[6200026]},
    [8] = {chs = CHS[3001100]},
}

function ReentryAsktaoDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
    GiftMgr.lastIndex = "WelfareButton8"
    self:resetRewards()
    
    self.isRotating = false
    
    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_REENTRY_ASKTAO_RESULT")
    self:hookMsg("MSG_OPEN_WELFARE")
    
    local data = GiftMgr:getWelfareData() or {}
    if next(data) then
        self:MSG_OPEN_WELFARE(data)
    end
end

function ReentryAsktaoDlg:resetRewards()
    for i = 1, REWARD_MAX do
        local panel = self:getControl("BonusPanel_" .. i)
        self:setCtrlVisible("ChosenImage", false, panel)
        
        if BonusInfo[i].icon then
            self:setImagePlist("BonusImage", BonusInfo[i].icon, panel)
        else
            local path = ResMgr:getItemIconPath(InventoryMgr:getIconByName(BonusInfo[i].chs))
            self:setImage("BonusImage", path, panel)
            self:setItemImageSize("BonusImage", panel)
        end
    end
end

-- 开始转圈
function ReentryAsktaoDlg:onUpdate()
    if not self.isRotating then return end
    
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
        GiftMgr:drawReentryReward(1) -- 领奖 
    end
end

-- 计算转圈间隔
function ReentryAsktaoDlg:calcSpeed(curPos, count)
    if count - curPos < 14 then
        local speed = 6 + (14 - (count - curPos)) * (14 - (count - curPos)) * 0.6
        return math.floor(speed)
    end

    return 6
end

function ReentryAsktaoDlg:onDrawButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if self.isRotating then
        return 
    end
    
    GiftMgr:drawReentryReward(0)
end

function ReentryAsktaoDlg:MSG_REENTRY_ASKTAO_RESULT(data)    
    local ret = 1
    for i = 1, REWARD_MAX do
        if BonusInfo[i].chs == data.reward then ret = i + 1 end
    end

    self.needCount = ret - self.startPos + math.random(4,5) * REWARD_MAX
    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1
    self.isRotating = true
    self:resetRewards()
end

function ReentryAsktaoDlg:MSG_OPEN_WELFARE(data)
    self:setLabelText("NoteLabel_1", CHS[4400002] .. data.reentryCount)
    self:updateLayout("SignPanel")
end

return ReentryAsktaoDlg
