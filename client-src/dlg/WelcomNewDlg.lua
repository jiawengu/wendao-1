-- WelcomNewDlg.lua
-- Created by huangzz July/26/2017
-- 迎新抽奖界面

local WelcomNewDlg = Singleton("WelcomNewDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function WelcomNewDlg:init()
    self:bindListener("GetBonusButton", self.onGetBonusButton, "8BonusPanel")
    self:bindListener("GetBonusButton", self.onGetBonusButton, "10BonusPanel")
    
    self.isRotating = false
    
    -- 请求数据
    gf:CmdToServer("CMD_WELCOME_DRAW_REQUEST", {flag = 0})
    
    
    self:MSG_WELCOME_DRAW_OPEN()
    
    self:hookMsg("MSG_WELCOME_DRAW_PREVIEW")
    self:hookMsg("MSG_WELCOME_DRAW_OPEN")
    self:hookMsg("MSG_OPEN_WELFARE")
end

-- 抽奖
function WelcomNewDlg:onGetBonusButton(sender, eventType)
    if not self.drawInfo or self.isRotating then
        return
    end
    
    -- 当前不在活动时间内，给予弹出提示
    if self.drawInfo.end_time < gf:getServerTime() then
        gf:ShowSmallTips(CHS[5420187])
        return
    end
    
    local welfareData = GiftMgr:getWelfareData()
    if welfareData["welcomeDrawStatue"] == 2 then
        gf:ShowSmallTips(CHS[5420197])
        return
    end
    
    gf:CmdToServer("CMD_WELCOME_DRAW_REQUEST", {flag = 1})
end

-- 开始转圈
function WelcomNewDlg:onUpdate()
    if not self.isRotating then
        return
    end

    if self.updateTime % self.delay ~= 0 then
        self.updateTime = self.updateTime + 1
        return
    end

    if self.curPos < self.needCount then
        -- 转圈
        self.delay = self:calcSpeed(self.curPos, self.needCount)
        local wuxPos = (self.curPos) % self.rewardCount + 1
        local rollCtrl = self:getControl("BonusChosenImage_" .. wuxPos, nil,self.rewardCount .. "BonusPanel")
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

        -- 领取奖励
        gf:CmdToServer("CMD_WELCOME_DRAW_REQUEST", {flag = 2})
    end
end

-- 计算转圈间隔
function WelcomNewDlg:calcSpeed(curPos, count)
    if count - curPos < 16 then
        local speed = 6 + (16 - (count - curPos)) * (16 - (count - curPos)) * 0.6
        return math.floor(speed)
    end

    return 6
end

function WelcomNewDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
end

function WelcomNewDlg:setRewards(data)
    self.rewardInfo = {}
    
    for i, reward in pairs(data) do
        local cell = self:getControl(self.rewardCount .. "BonusPanel")
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
        reward.name = RewardContainer:getTextList(reward)[1]
        reward.level = item.level
        reward.limted = item.limted
        
        self:setCtrlVisible("BonusChosenImage_" .. i, false,self.rewardCount .. "BonusPanel")

        -- 奖品图标
        local imgPath, textureResType = RewardContainer:getRewardPath(reward)
        if textureResType == ccui.TextureResType.plistType then
            self:setImagePlist("BonusImage_" .. i, imgPath, cell)
        else
            self:setImage("BonusImage_" .. i, imgPath, cell)
        end
        
        local img = self:getControl("BonusImage_" .. i, nil, cell)
        gf:setItemImageSize(img)
        if reward["limted"] then
            InventoryMgr:addLogoBinding(img)
        end

        if reward.level and tonumber(reward.level) > 1 then
            self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, tonumber(reward.level), false, LOCATE_POSITION.LEFT_TOP, 19, cell)
        end

        self.rewardInfo[i] = reward
        
        img.reward = reward
        img:setTouchEnabled(true)
        self:bindTouchEndEventListener(img, self.onShowItemInfo)
    end
end

function WelcomNewDlg:setData(data)
    -- 活动时间
    local startTimeStr = gf:getServerDate(CHS[5420147], tonumber(data.start_time))
    local endTimeStr = gf:getServerDate(CHS[5420147], tonumber(data.end_time))
    self:setLabelText("TitleLabel", CHS[5420137] .. startTimeStr .. " - " .. endTimeStr)
    
    -- 抽奖转盘
    if self.rewardCount == 10 then
        self:setCtrlVisible("10BonusPanel", true)
        self:setCtrlVisible("8BonusPanel", false)
    else
        self:setCtrlVisible("8BonusPanel", true)
        self:setCtrlVisible("10BonusPanel", false)
    end
    
    
    -- 抽奖按钮与抽奖条件
    local welfareData = GiftMgr:getWelfareData()
    local isSameDay =  gf:isSameDay5(data.start_time, data.server_time)
    if welfareData["welcomeDrawStatue"] > 0
        or (not isSameDay and not DistMgr:curIsTestDist() and data.create_time < data.start_time) then
        -- 非活动期间创建的角色或已满足抽奖条件
        -- 显示抽奖按钮
        self:setCtrlVisible("BonusConditionPanel", false, self.rewardCount .. "BonusPanel")
        self:setCtrlVisible("GetBonusButton", true, self.rewardCount .. "BonusPanel")
    else
        -- 显示抽奖条件
        self:setCtrlVisible("GetBonusButton", false, self.rewardCount .. "BonusPanel")
        self:setCtrlVisible("BonusConditionPanel", true, self.rewardCount .. "BonusPanel")
        
        if DistMgr:curIsTestDist() or isSameDay then
            self:setLabelText("Label_2", "", self.rewardCount .. "BonusPanel")
            self:setLabelText("Label_3", "", self.rewardCount .. "BonusPanel")
            self:setLabelText("Label_4", CHS[5420195] .. data.condition, self.rewardCount .. "BonusPanel")
        else
            self:setLabelText("Label_2", CHS[5420194], self.rewardCount .. "BonusPanel")
            self:setLabelText("Label_3", CHS[5420195] .. data.condition, self.rewardCount .. "BonusPanel")
            self:setLabelText("Label_4", "", self.rewardCount .. "BonusPanel")
        end
    end
end

function WelcomNewDlg:MSG_WELCOME_DRAW_PREVIEW(data)
    if not self.rewardInfo then
        return
    end

    local ret = -1
    for i = 1, self.rewardCount do
        if self.rewardInfo[i].name == data.name then 
            ret = i + 1 
            break
        end
    end

    for i = 1, 10 do
        local rollCtrl = self:getControl("BonusChosenImage_" .. i, nil, self.rewardCount .. "BonusPanel")
        rollCtrl:setVisible(false)
    end

    if ret == -1 then
        -- 找不到奖励直接领取奖励
        self.isRotating = false

        -- 领取奖励
        gf:CmdToServer("CMD_WELCOME_DRAW_REQUEST", {flag = 2})
        return
    end

    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1
    self.needCount = ret - self.startPos + math.random(4,5) * self.rewardCount
    
    self.isRotating = true
end

function WelcomNewDlg:MSG_WELCOME_DRAW_OPEN()
    self.drawInfo = GiftMgr.welcomeDrawInfo

    if not self.drawInfo then
        return
    end

    -- 分割奖品
    local classList = TaskMgr:getRewardList(self.drawInfo.goods_desc)
    if not classList[1] or not next(classList[1]) then
        return
    end

    self.rewards = classList[1]
    self.rewardCount = #classList[1]

    self:setRewards(self.rewards)
    self:setData(self.drawInfo)
end

function WelcomNewDlg:MSG_OPEN_WELFARE(data)
    if not self.drawInfo then
        return
    end
    
    self:setData(self.drawInfo)
end


return WelcomNewDlg
