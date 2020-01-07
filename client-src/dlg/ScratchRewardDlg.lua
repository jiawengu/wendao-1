-- ScratchRewardDlg.lua
-- Created by huangzz Dec/09/2016
-- 寒假刮刮乐抽奖界面

local VariationPetList = require (ResMgr:getCfgPath("VariationPetList.lua"))

local ScratchRewardDlg = Singleton("ScratchRewardDlg", Dialog)

local eraseFinish -- 表示是否擦完毕
local isfirstStart  -- 是否打开界面后的第一次抽奖

function ScratchRewardDlg:init()
    self:bindListener("StartButton", self.onRewordButton)
    -- self:bindListener("StateButton", self.onStateButton)
    self:setCtrlEnabled("StateButton", false)
    self:setCtrlVisible("StateButton", false)
    self:bindListener("AgainButton", self.onRewordButton)
    self:setCtrlVisible("AgainButton", false)
    
    self.eraser = GiftMgr:getEraser("ScratchRewardDlg", 3, 50, 10)
    
    isfirstStart = true
    
    --[[ 先添加 3 张不可刮的图片，等开始刮奖后再添加对应的可刮奖的图片
    self.initImg1 = self:addInitImgForPanel('ScratchPanel1')
    self.initImg2 = self:addInitImgForPanel('ScratchPanel2')
    self.initImg3 = self:addInitImgForPanel('ScratchPanel3')]]

    self:bindListener("InfoButton", self.onInfoButton)

    self.scratchCount = InventoryMgr:getAmountByName(CHS[5410008]) or 0
    
    self:setData()
    
    self:hookMsg("MSG_FESTIVAL_LOTTERY_RESULT")
    self:hookMsg("MSG_WINTER_LOTTERY_MSG")
    
    -- 默认为 true 以确保能够只处理多点触碰中的第一个 Touch 事件
    self.canTouchFlag1 = true
    self.canTouchFlag2 = true
    self.canTouchFlag3 = true
    
    self.rText1 = GiftMgr:getScratchRTextbByName("ScratchPanel1")
    self.rText2 = GiftMgr:getScratchRTextbByName("ScratchPanel2")
    self.rText3 = GiftMgr:getScratchRTextbByName("ScratchPanel3")
    
    self:MSG_FESTIVAL_LOTTERY_RESULT(GiftMgr:getLotteryResult("winter_day_2017"))
end

-- 放 1 张不能刮的静态图片
function ScratchRewardDlg:addInitImgForPanel(panelName)
    local img = ccui.ImageView:create(ResMgr.ui.scratch_lottery, ccui.TextureResType.localType)
    local panel = self:getControl(panelName)
    panel:addChild(img)
    return img
end

function ScratchRewardDlg:initScratchPanel()
    if self.finishScratch then
        self.finishScratch = false
    end
   
    local path = ResMgr.ui.scratch_lottery
    
    -- 重新生成其它的画布前，先释放之前的画布
    if self.rText1 and self.rText1:getParent() then
        self.rText1:removeFromParent()
    end

    if self.rText2 and self.rText2:getParent() then
        self.rText2:removeFromParent()
    end

    if self.rText3 and self.rText3:getParent() then
        self.rText3:removeFromParent()
    end
    
    self.rText1 = GiftMgr:getScratchRTextbByName("ScratchPanel1")
    if not self.rText1 then
        self.rText1 = self:createScratch("ScratchPanel1", path, self.eraser[1], 0.60, self.onErased, 0.62, 'canTouchFlag1')
        GiftMgr:setScratchRText("ScratchPanel1", self.rText1)
    elseif not self.rText1:getParent() then
        local panel = self:getControl("ScratchPanel1")
        panel:addChild(self.rText1)
    end
    
    self.rText2 = GiftMgr:getScratchRTextbByName("ScratchPanel2")
    if not self.rText2 then
        self.rText2 = self:createScratch("ScratchPanel2", path, self.eraser[2], 0.60, self.onErased, 0.62, 'canTouchFlag2')
        GiftMgr:setScratchRText("ScratchPanel2", self.rText2)
    elseif not self.rText2:getParent() then
        local panel = self:getControl("ScratchPanel2")
        panel:addChild(self.rText2)
    end
    
    self.rText3 = GiftMgr:getScratchRTextbByName("ScratchPanel3")
    if not self.rText3 then
        self.rText3 = self:createScratch("ScratchPanel3", path, self.eraser[3], 0.60, self.onErased, 0.62, 'canTouchFlag3')
        GiftMgr:setScratchRText("ScratchPanel3", self.rText3)
    elseif not self.rText3:getParent() then
        local panel = self:getControl("ScratchPanel3")
        panel:addChild(self.rText3)
    end
    
    --[[ if self.initImg1 then
        self.initImg1:setVisible(false)
    end
    
    if self.initImg2 then
        self.initImg2:setVisible(false)
    end
    
    if self.initImg3 then
        self.initImg3:setVisible(false)
    end]]
end

-- 刮完后要回调函数
function ScratchRewardDlg:onErased(panelName)
    if not eraseFinish then eraseFinish = {} end
    eraseFinish[panelName] = true
    
    if eraseFinish["ScratchPanel1"] and eraseFinish["ScratchPanel2"] and eraseFinish["ScratchPanel3"] and not self.finishScratch then
        GiftMgr:drawScratchReward(1)
        self.finishScratch = true
        GiftMgr:releaseScratchRText()
    end
end

function ScratchRewardDlg:setData()
    local data = GiftMgr:getWelfareData()
    if not data or not data["lottery"] or not data["lottery"]["winter_day_2017"] then return end
    
    self:setLabelText("ItemNumLabel", CHS[5410011] .. self.scratchCount)
    
    self:setLabelText("TimeLabel", CHS[5410009] .. gf:getServerDate(CHS[5420147], tonumber(data["lottery"]["winter_day_2017"].startTime)) .. " - " .. gf:getServerDate(CHS[5420147], tonumber(data["lottery"]["winter_day_2017"].endTime)))
    
    self:setImage("PortraitImage", self:rewardRelation(0), "RewardPanel1")
    self:setImage("PortraitImage", self:rewardRelation(0), "RewardPanel2")
    self:setImage("PortraitImage", self:rewardRelation(0), "RewardPanel3")
end

function ScratchRewardDlg:onRewordButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if Me:queryInt("level") < 30 then
        gf:ShowSmallTips(CHS[5410012])
    elseif self.scratchCount == 0 then
        gf:ShowSmallTips(CHS[5410013])
    elseif InventoryMgr:getEmptyPosCount() < 1 then
        gf:ShowSmallTips(CHS[5410014])
    elseif PetMgr:getFreePetCapcity() < 1 then
        gf:ShowSmallTips(CHS[5410015])
    else
        eraseFinish = nil
        isfirstStart = false
        GiftMgr:drawScratchReward(0)
    end
end

function ScratchRewardDlg:onStateButton(sender, eventType)
end

function ScratchRewardDlg:onAgainButton(sender, eventType)
end

function ScratchRewardDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ScratchRewardInfoDlg")
end

function ScratchRewardDlg:rewardRelation(index)
    if index == 0 then
        return ResMgr.ui.dao_word
    end
    
    local icon
    if index == 1 then
        icon = VariationPetList[CHS[3001757]].icon
    elseif index == 2 then
        icon = VariationPetList[CHS[3001762]].icon
    elseif index == 3 then
        icon = VariationPetList[CHS[3001767]].icon
    elseif index == 4 then
        icon = VariationPetList[CHS[3001769]].icon
    elseif index == 5 then
        icon = VariationPetList[CHS[3001773]].icon
    elseif index == 6 then
        icon = VariationPetList[CHS[3001776]].icon
    elseif index == 7 then
        icon = VariationPetList[CHS[3001779]].icon
    elseif index == 8 then
        icon = VariationPetList[CHS[3001781]].icon
    elseif index == 9 then
        icon = VariationPetList[CHS[3001782]].icon
    elseif index == 10 then
        icon = VariationPetList[CHS[3001783]].icon
    elseif index == 11 then
        icon = VariationPetList[CHS[3001784]].icon
    elseif index == 12 then
        icon = VariationPetList[CHS[3001786]].icon
    end
    
    return ResMgr:getSmallPortrait(icon)
end

function ScratchRewardDlg:cleanup()
    -- 画布对象另保存下来，下次继续用（保存在GiftMgr的scratchRText中）
    self.rText1 = nil
    self.rText2 = nil
    self.rText3 = nil
    
    self.eraser = nil
    
    --[[self.initImg1 = nil
    self.initImg2 = nil
    self.initImg3 = nil]]
end

-- 
function ScratchRewardDlg:MSG_FESTIVAL_LOTTERY_RESULT(data)
    if not data or data.activeName ~= "winter_day_2017" then return end
    
    self.scratchCount = InventoryMgr:getAmountByName(CHS[5410008]) or 0
    -- 刮刮券用完后，更新数据
    if self.scratchCount == 0 and GiftMgr.welfareData["lottery"] and GiftMgr.welfareData["lottery"]["winter_day_2017"] then
        GiftMgr.welfareData["lottery"]["winter_day_2017"].amount = 0
    end
    
    if data.status == 0 then
        -- status为1表示抽奖开始，0表示结束
        self:setCtrlVisible("StateButton", false)
        if isfirstStart then
            self:setCtrlVisible("StartButton", true)
            self:setCtrlVisible("AgainButton", false)
        else
            self:setCtrlVisible("AgainButton", true)
            self:setCtrlVisible("StartButton", false)
        end
        
        eraseFinish = nil
        return
    end
    
    isfirstStart = false
    
    self:initScratchPanel()

    self:setLabelText("ItemNumLabel", CHS[5410011] .. self.scratchCount)
    self:setColorText(CHS[5410010], "ResultPanel")
    
    self:setCtrlVisible("StateButton", true)
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("AgainButton", false)
    
    self:setImage("PortraitImage", self:rewardRelation(data.rewardIndex), "RewardPanel1")
    self:setImage("PortraitImage", self:rewardRelation(data.rewardIndex2), "RewardPanel2")
    self:setImage("PortraitImage", self:rewardRelation(data.rewardIndex3), "RewardPanel3")
end

function ScratchRewardDlg:MSG_WINTER_LOTTERY_MSG(data)
    if not data then return end
    
    self:setColorText(data.rewardMsg, "ResultPanel", nil, nil, nil, nil, nil, true)
    local panel = self:getControl("ResultPanel")
    self:updateLayout("ResultPanel")
end

return ScratchRewardDlg
