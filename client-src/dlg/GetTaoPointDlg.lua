-- GetTaoPointDlg.lua
-- Created by songcw Aug/17/2016
-- 刷到积分界面

local GetTaoPointDlg = Singleton("GetTaoPointDlg", Dialog)
local Bitset = require("core/Bitset")
local RadioGroup = require("ctrl/RadioGroup")
local POINT_PER_ZIQI_HONGMENG = 70
local POINT_PER_CHONGFENGSAN = 50

local RewardContainer = require("ctrl/RewardContainer")

function GetTaoPointDlg:init()
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("RuleButton", self.onRuleButton)

    self.unitPanel = self:retainCtrl("RewardsPanel1")

    self.firstIndex = nil

    GetTaoMgr:requestOfflineShuadao()

    self:setListInfo()

    self:updataScoreData()

    self:hookMsg("MSG_SHUADAO_SCORE_ITEMS")
end

function GetTaoPointDlg:cleanup()
end

-- 获取当前选择项（强盗领赏令/紫气鸿蒙）的奖励相关信息
function GetTaoPointDlg:getCurRewardData()
    return GetTaoMgr:getScoreReward()
end

-- 获取当前选择项（强盗领赏令/紫气鸿蒙）的积分信息
function GetTaoPointDlg:getCurScoreData()
    return GetTaoMgr.scoreData
end

function GetTaoPointDlg:getFetchState()
    local data = self:getCurScoreData()
    if not data then return end

    return Bitset.new(data.fetchState)
end

function GetTaoPointDlg:updataScoreData()
    local data = self:getCurScoreData()
    if not data then         
        return 
    end    
    
    -- 积分
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT,
        data.score, false, LOCATE_POSITION.MID, 21, "PointPanel")
        
    -- 按钮状态
    local list = self:getControl("RewardsListView")
    local items = list:getItems()
    local stateBit = self:getFetchState()
    local rewardData = self:getCurRewardData()
    for i, panel in pairs(items) do
        self:setCtrlVisible("GetButton", false, panel)
        self:setCtrlVisible("GotImage", false, panel)
        self:setCtrlVisible("NoneImage", false, panel)

        if Me:getLevel() >= GetTaoMgr.ZIQI_HONGMENG_REWARD_MIN_LEVEL and panel.isGray then
            if panel.rewardCtrl and panel.rewardCtrl.resetAllReward then
                panel.rewardCtrl:resetAllReward()
                panel.isGray = false
            end
        end
        
        if stateBit:isSet(i) then
            self:setCtrlVisible("GotImage", true, panel)
        else
            if data.score >= rewardData[i].score then
                self:setCtrlVisible("GetButton", true, panel)
            else
                self:setCtrlVisible("NoneImage", true, panel)
            end
        end
    end
end

function GetTaoPointDlg:setListInfo()
    local list = self:resetListView("RewardsListView")
    
    local rewardData = self:getCurRewardData()
    
    for i = 1, # rewardData do
        local panel = self.unitPanel:clone()
        self:setUnitPanel(panel, i, rewardData[i])
        list:pushBackCustomItem(panel)
    end
    
    local firstIndex = self.firstIndex
    performWithDelay(self.root, function ()
        if firstIndex then
        	self:setPisitionByIndex(firstIndex - 1)
    	end
    end, 0)
end

function GetTaoPointDlg:setUnitPanel(panel, index, info)
    panel:setTag(index)
    self:setLabelText("NumLabel", index, panel)

    local iconPanel = self:getControl("IconPanel1", nil, panel)
    local size = iconPanel:getContentSize()
    local rewardContainer = RewardContainer.new(
        CHS[5420305] .. string.format(CHS[5420309], POINT_PER_CHONGFENGSAN) .. string.format(CHS[5420310], POINT_PER_ZIQI_HONGMENG), 
        {width = size.width * 4, height = size.height}, 
        nil, nil, true, 30, true, 
        iconPanel:getScale())

    rewardContainer:setAnchorPoint(0, 0)
    rewardContainer:setPosition(0, 0)
    iconPanel:addChild(rewardContainer, 0, 100)

    panel.rewardCtrl = rewardContainer

    if Me:getLevel() < GetTaoMgr.ZIQI_HONGMENG_REWARD_MIN_LEVEL then
        rewardContainer:grayOneReward(CHS[7000284])
        panel.isGray = true
    end

    self:setLabelText("TargetLabel", string.format(info.introduce, info.score), panel)

    self:setCtrlVisible("BackImage2", (index % 2) == 0, panel)
    
    local getBtn = self:getControl("GetButton", nil, panel)
    getBtn:setTag(index)
    self:setCtrlVisible("GetButton", false, panel)
    self:setCtrlVisible("GotImage", false, panel)
    self:setCtrlVisible("NoneImage", false, panel)
    
    local stateBit = self:getFetchState()
    if not stateBit:isSet(index) and not self.firstIndex then
        self.firstIndex = self.firstIndex or index
    end
end

function GetTaoPointDlg:setPisitionByIndex(index)
    local list = self:getControl("RewardsListView")
    local items = list:getItems()
    local realInnerSizeHeight = #items * self.unitPanel:getContentSize().height
    local height = list:getContentSize().height - realInnerSizeHeight
    local y = height + index * self.unitPanel:getContentSize().height
    if y >= 0 then y = 0 end
    list:getInnerContainer():setPositionY(y)
end

-- 点击获取相关奖励（强盗领赏令/紫气鸿蒙）
function GetTaoPointDlg:onGetButton(sender, eventType)
    local index = sender:getTag()
    if not InventoryMgr:getFirstEmptyPos() then
        gf:ShowSmallTips(CHS[5420307])
        return
    end

    local outNumZQHM = GetTaoMgr:getAllZiQiHongMengPoint() + POINT_PER_ZIQI_HONGMENG - GetTaoMgr:getMaxZiQiHongMengPoint()
    local outNumCFS = GetTaoMgr:getPetFengSanPoint() + POINT_PER_CHONGFENGSAN - GetTaoMgr:getMaxChongFengSanPoint()
    if outNumZQHM > 0 and Me:getLevel() >= GetTaoMgr.ZIQI_HONGMENG_REWARD_MIN_LEVEL then
        local tip = string.format(CHS[7000298], CHS[7000284], outNumZQHM)
        gf:confirm(tip, function()
            if outNumCFS > 0 then
                local tip = string.format(CHS[7000298], CHS[5420304], outNumCFS)
                gf:confirm(tip, function()
                    GetTaoMgr:fetchScoreItem(GetTaoMgr.SHUADAO_SCORE_ITEM_TYPE, index - 1)
                end)
                return
            end

            GetTaoMgr:fetchScoreItem(GetTaoMgr.SHUADAO_SCORE_ITEM_TYPE, index - 1)
        end)
        return
    end

    if outNumCFS > 0 then
        local tip = string.format(CHS[7000298], CHS[5420304], outNumCFS)
        gf:confirm(tip, function()
            GetTaoMgr:fetchScoreItem(GetTaoMgr.SHUADAO_SCORE_ITEM_TYPE, index - 1)
        end)
        return
    end

    GetTaoMgr:fetchScoreItem(GetTaoMgr.SHUADAO_SCORE_ITEM_TYPE, index - 1)
end

-- 刷新强盗领赏令/紫气鸿蒙相关信息
function GetTaoPointDlg:MSG_SHUADAO_SCORE_ITEMS(sender, eventType)
    self:updataScoreData()
end

function GetTaoPointDlg:onRuleButton()
    DlgMgr:openDlg("GetTaoPointRuleDlg")
end

return GetTaoPointDlg
