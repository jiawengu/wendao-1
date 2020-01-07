-- SummerVacationDlg.lua
-- Created by songcw June/01/2017
-- 2017暑假送福

local SummerVacationDlg = Singleton("SummerVacationDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

local REWARD_PANEL = {
    [1] = "SignPanel1",
    [2] = "SignPanel2",
    [3] = "SignPanel3",
    [4] = "SignPanel4",
}

local REWARD_COUNT_BY_PANEL = {
    SignPanel1 = 1,
    SignPanel2 = 5,
    SignPanel3 = 6,
    SignPanel4 = 3,
}

-- #rNum 该格式表示数量的类型表
local DISPLAY_AMOUNT_TYPE = {
    [CHS[6000078]] = 1,             -- 物品
    [CHS[6200002]] = 1,             -- 变身卡
    [CHS[3001096]] = 1,             -- 超级黑水晶
    [CHS[3001114]] = 1,             -- 天书
    [CHS[3002169]] = 1,             -- 未鉴定
    [CHS[3002170]] = 1,             -- 装备
    [CHS[3002234]] = 1,             -- 首饰
    [CHS[4300255]] = 1,             -- 充值好礼
}


local REWARD_COUNT = {
    [1] = 1,
    [2] = 5,
    [3] = 6,
    [4] = 3,
}

local TAO_REWARD = {
    [1] = CHS[4200367],
    [2] = CHS[4200368],
    [3] = CHS[4200369],
}

-- 奖池
local m_jackpot_type = {count = 3, [1] = REWARD_PANEL[1], [2] = REWARD_PANEL[2], [3] = REWARD_PANEL[3]}
local m_jackpot_reward = {count = 6, [1] = REWARD_PANEL[1], [2] = REWARD_PANEL[2], [3] = REWARD_PANEL[3]}

local m_retType = 3
local m_retReward = 2

function SummerVacationDlg:init()
    self:bindListener("BeginButton", self.onBeginButton)
    self:bindListener("InfoButton", self.onInfoButton)
    
    self.selectTypeImage = self:toCloneCtrl("TypeSelectImage", "SignPanel1")
    self.selectItemImage = self:toCloneCtrl("BlackImage", "SignPanel1")
    
    self.openTime = gf:getServerTime()
    GiftMgr:questSD2017()
    
    self:hookMsg("MSG_SD_2017_LOTTERY_RESULT")
    self:hookMsg("MSG_SD_2017_LOTTERY_INFO")
    self:hookMsg("MSG_SD_2017_STOP_LOTTERY")    
end

function SummerVacationDlg:cleanup()
    self:releaseCloneCtrl("selectTypeImage")
    self:releaseCloneCtrl("selectItemImage")
    
    if self.isDraw then
        self.isDraw = false
        GiftMgr:fetchSummer2017(1)
    end
    
    self.isDraw = nil
    self.data = nil
end

-- 点击奖品
function SummerVacationDlg:onClickPanel(sender)
    if self.isNotDisplayReward then return end

    local classList = TaskMgr:getRewardList(sender.data)
    sender.reward = classList[1][1]
    RewardContainer:imagePanelTouch(sender, ccui.TouchEventType.ended)
end

function SummerVacationDlg:setUnitReward(data, panel)
    local classList = TaskMgr:getRewardList(data)
    local reward = classList[1][1]
    local imgPath,textureResType = RewardContainer:getRewardPath(reward)

    local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
    local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

    if textureResType == ccui.TextureResType.plistType then
        self:setImagePlist("ItemImage", imgPath, panel)
    else
        self:setImage("ItemImage", imgPath, panel)
    end
    
    if DISPLAY_AMOUNT_TYPE[reward[1]] and item.number and tonumber(item.number) > 1 and item.name ~= CHS[3002145] then
        self:setNumImgForPanel("BackImage1", ART_FONT_COLOR.NORMAL_TEXT, item.number, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel)
    end 
    
    -- 加上限时或者限制交易图标
    local iconImg = self:getControl("ItemImage", nil, panel)
    if item and item["time_limited"] then
        InventoryMgr:addLogoTimeLimit(iconImg)
    elseif item and item["limted"] then
        InventoryMgr:addLogoBinding(iconImg)
    end
end


function SummerVacationDlg:setData(data)
    self.isNotDisplayReward = false

    -- 时间
    local startTime = gf:getServerDate(CHS[4300158], data.startTime + 60 * 60 * 3)    
    local endTime = gf:getServerDate(CHS[4300158], data.endTime)
    local timeStr = string.format(CHS[4100620], startTime, endTime)
    self:setLabelText("TitleLabel", timeStr, "InfoPanel")
    
    -- 积分
    if data.score >= 300 then
        self:setLabelText("NumLabel1", data.score, "NumPanel", COLOR3.GREEN)
    else
        self:setLabelText("NumLabel1", data.score, "NumPanel", COLOR3.RED)
    end 

    if gf:getServerTime() - data.startTime < 60 * 60 * 3 then
        for _, panelName in pairs(REWARD_PANEL) do
            local panel = self:getControl(panelName)
            for i = 1, 6 do
                local unitPanel = self:getControl("ItemImagePanel" .. i, nil, panel)
                if unitPanel then
                    self:setCtrlVisible("ItemImage", true, unitPanel)
                    self:setImagePlist("ItemImage", ResMgr.ui.ask_symbol, unitPanel)                
                end
            end
        end

        self.isNotDisplayReward = true
        
        self:setLabelText("SurplusNumLabel1", "", "SignPanel1")
        self:setLabelText("SurplusNumLabel2", "", "SignPanel1")
        
        self:setLabelText("SurplusNumLabel1", "", "SignPanel2")
        self:setLabelText("SurplusNumLabel2", "", "SignPanel2")
        
        self:setLabelText("SurplusNumLabel1", "", "SignPanel3")
        self:setLabelText("SurplusNumLabel2", "", "SignPanel3")
     
        self:setLabelText("SurplusLabel", CHS[4200375], "SignPanel4")        
        return
    end
    
    -- 紫气
    local ziqiPanel = self:getControl("SignPanel1")
    for i = 1, data.ziqi_count do
        local unitPanel = self:getControl("ItemImagePanel" .. i, nil, ziqiPanel)
        self:setCtrlVisible("ItemImage", true, unitPanel)
        
        self:setUnitReward(data.ziqi_desc[i], unitPanel)        
        unitPanel.data = data.ziqi_desc[i]
        self:bindTouchEndEventListener(unitPanel, self.onClickPanel)
    end
    
    self:setCtrlVisible("SurplusNumLabel1", data.ziqi_quota < 1, ziqiPanel)
    self:setCtrlVisible("SurplusNumLabel2", data.ziqi_quota >= 1, ziqiPanel)
    self:setLabelText("SurplusNumLabel1", data.ziqi_quota, ziqiPanel)
    self:setLabelText("SurplusNumLabel2", data.ziqi_quota, ziqiPanel)
    
    
    -- 福盈
    local fuyPanel = self:getControl("SignPanel2")
    for i = 1, data.fuying_count do
        local unitPanel = self:getControl("ItemImagePanel" .. i, nil, fuyPanel)
        self:setCtrlVisible("ItemImage", true, unitPanel)
    
        self:setUnitReward(data.fuying_desc[i], unitPanel)
        unitPanel.data = data.fuying_desc[i]
        self:bindTouchEndEventListener(unitPanel, self.onClickPanel)
    end
    self:setCtrlVisible("SurplusNumLabel1", data.fuying_quota >= 1, fuyPanel)
    self:setCtrlVisible("SurplusNumLabel2", data.fuying_quota < 1, fuyPanel)
    self:setLabelText("SurplusNumLabel1", data.fuying_quota, fuyPanel)
    self:setLabelText("SurplusNumLabel2", data.fuying_quota, fuyPanel)
    
    -- 小喜
    local xiaoxPanel = self:getControl("SignPanel3")
    for i = 1, data.xiaoxi_count do
        local unitPanel = self:getControl("ItemImagePanel" .. i, nil, xiaoxPanel)
        self:setCtrlVisible("ItemImage", true, unitPanel)
        self:setUnitReward(data.xiaoxi_desc[i], unitPanel)
        
        unitPanel.data = data.xiaoxi_desc[i]
        self:bindTouchEndEventListener(unitPanel, self.onClickPanel)
    end
    self:setCtrlVisible("SurplusNumLabel1", data.xiaoxi_quota >= 1, xiaoxPanel)
    self:setCtrlVisible("SurplusNumLabel2", data.xiaoxi_quota < 1, xiaoxPanel)
    self:setLabelText("SurplusNumLabel1", data.xiaoxi_quota, xiaoxPanel)
    self:setLabelText("SurplusNumLabel2", data.xiaoxi_quota, xiaoxPanel)
    
    -- 道心
    local daoxPanel = self:getControl("SignPanel4")
    for i = 1, 3 do
        local unitPanel = self:getControl("ItemImagePanel" .. i, nil, daoxPanel)
        self:setCtrlVisible("ItemImage", true, unitPanel)
    
        self:setUnitReward(TAO_REWARD[i], unitPanel)
        unitPanel.data = TAO_REWARD[i]
        self:bindTouchEndEventListener(unitPanel, self.onClickPanel)
    end    

    local panel2 = self:getControl("ItemImagePanel2", nil, daoxPanel)
    self:setNumImgForPanel("BackImage1", ART_FONT_COLOR.NORMAL_TEXT, 3, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel2)
    local panel3 = self:getControl("ItemImagePanel3", nil, daoxPanel)
    self:setNumImgForPanel("BackImage1", ART_FONT_COLOR.NORMAL_TEXT, 10, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, panel3)
    self:setLabelText("SurplusLabel", CHS[4200376], "SignPanel4")

end

-- 设置单个类型抽奖选择状态
function SummerVacationDlg:setUnitLight(curType, dt)
    self.totalSteps = self.totalSteps + 1
    self.curType = curType
    local typeName = m_jackpot_type[curType]
    local panel = self:getControl(typeName)
    local typeImage = panel:getChildByName("TypeSelectImage")
    if typeImage then
        typeImage:stopAllActions()
        typeImage:setVisible(true)
    else
        typeImage = self.selectTypeImage:clone()
        panel:addChild(typeImage)
    end    
    
    if dt then
        local fadeOut = cc.FadeOut:create(dt * 2)
        local callBack = cc.CallFunc:create(function ()
            typeImage:removeFromParent()
        end)
        
        typeImage:runAction(cc.Sequence:create(fadeOut, callBack))
        
     
        performWithDelay(self.root, function ()
            --gf:ShowSmallTips("当前" .. self.totalSteps)
            local nextType, nextDt = self:getNextTypeAndDt(curType, dt)
            self:setUnitLight(nextType, nextDt)
        end, dt)
    else
        -- 类型抽奖完成，抽奖品
        if m_jackpot_reward.count == 1 then  
            self.curReward = 1          
            self:setUnitRewardLight(self.curReward)
        else
            self.totalSteps = 0
            self.curReward = math.random(1, m_jackpot_reward.count)
            self.curReward = 1
            self:setUnitRewardLight(self.curReward, 0.15)
        end        
    end
end

function SummerVacationDlg:setUnitRewardLight(curReward, dt)
    self.totalSteps = self.totalSteps + 1
    self.curReward = curReward
--    local typeName = m_jackpot_reward[curReward]
    local parentPanel = self:getControl(REWARD_PANEL[m_retType])
    local panel = self:getControl("ItemImagePanel" .. curReward, nil, parentPanel)
    if not panel then
        local sss
    end
    
    local typeImage = panel:getChildByName("BlackImage")
    if typeImage then
        typeImage:stopAllActions()
        typeImage:setVisible(true)
    else
        typeImage = self.selectItemImage:clone()
        panel:addChild(typeImage)
    end    

    if dt then
        local fadeOut = cc.FadeOut:create(dt * 2)
        local callBack = cc.CallFunc:create(function ()
            typeImage:removeFromParent()
        end)

        typeImage:runAction(cc.Sequence:create(fadeOut, callBack))


        performWithDelay(self.root, function ()
            --gf:ShowSmallTips("当前" .. self.totalSteps)
            local nextType, nextDt = self:getNextRewardAndDt(curReward, dt)
            self:setUnitRewardLight(nextType, nextDt)
        end, dt)
    else
        local fadeOut = cc.FadeOut:create(0.4)
        local fadeIn = cc.FadeIn:create(0.4)
        local callBack = cc.CallFunc:create(function ()
            typeImage:removeFromParent()
        end)
        
        local callBack = cc.CallFunc:create(function ()
            self.isDraw = false
            GiftMgr:fetchSummer2017(1)
        end)

        typeImage:runAction(cc.Sequence:create(fadeOut, fadeIn, callBack))
    end
end

function SummerVacationDlg:getNextTypeAndDt(cur, dt)
    local nextType = cur + 1
    if nextType > m_jackpot_type.count then nextType = 1 end

    
    local nextDt
    if self.totalSteps < 6 then
        nextDt = dt - 0.02
    elseif self.totalSteps <= 12 then
        nextDt = dt + 0.05
    elseif self.totalSteps > 12 then
        nextDt = dt + 0.05
        local panelName = m_jackpot_type[cur]
        if m_retType == m_jackpot_type[panelName] then
            nextDt = nil
            nextType = cur
        end
    end 
    
    return nextType, nextDt
end

function SummerVacationDlg:getNextRewardAndDt(cur, dt)
    local nextType = cur + 1
    if nextType > m_jackpot_reward.count then nextType = 1 end


    local nextDt
    if self.totalSteps < 6 then
        nextDt = dt - 0.02
    elseif self.totalSteps <= 12 then
        nextDt = dt + 0.05
    elseif self.totalSteps > 12 then
        nextDt = dt + 0.05
        if m_retReward == nextType then
            nextDt = nil
        end
    end 

    return nextType, nextDt
end

function SummerVacationDlg:onBeginButton(sender, eventType)
    
    if not self.data then return end
    
    -- 时间
    if gf:getServerTime() > self.data.endTime or gf:getServerTime() < self.data.startTime then
        gf:ShowSmallTips(CHS[4100611])
        return
    end

    -- 开始前3小时
    if gf:getServerTime() - self.data.startTime < 60 * 60 * 3 then
        gf:ShowSmallTips(CHS[4100612])
        return
    end
    
    if tonumber(gf:getServerDate("%H", self.openTime)) < 8 and tonumber(gf:getServerDate("%H", gf:getServerTime())) >= 8 then
        gf:ShowSmallTips(CHS[4200377])
        self.openTime = gf:getServerTime()
        GiftMgr:questSD2017()
        return
    end

    if not self:isOutLimitTime("lastTime", 5000) then
        gf:ShowSmallTips(CHS[4100613])
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())

    if self.isDraw then
        gf:ShowSmallTips(CHS[4100614])
        return
    end

    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(CHS[4100615])
        return
    end
    
    if self.data.score < 300 then
        gf:ShowSmallTips(CHS[4100616])
        return
    end

    -- 抽奖
    GiftMgr:fetchSummer2017(0)
end

function SummerVacationDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("SummerVacationRuleDlg")
end

function SummerVacationDlg:MSG_SD_2017_LOTTERY_RESULT(data)
    self.isDraw = true
    self.curType = 1
    self.totalSteps = 0
    m_retType = data.type
    m_retReward = data.reward
    
    for _, panelName in pairs(REWARD_PANEL) do
        local panel = self:getControl(panelName)
        local image = self:getControl("TypeSelectImage", nil, panel)
        if image then image:removeFromParent() end  
        
        for i = 1, 6 do
            local unitPanel = self:getControl("ItemImagePanel" .. i, nil, panel)
            if unitPanel then
                local image = unitPanel:getChildByName("BlackImage")
                if image then image:removeFromParent() end        
            end
        end
    end

    m_jackpot_reward = {}
    m_jackpot_reward.count = REWARD_COUNT[m_retType]
    if m_jackpot_type.count == 1 then
        self.curType = 1
        self:setUnitLight(self.curType)
    else        
        self:setUnitLight(self.curType, 0.15)
    end

    
    
    --[[    第二种效果
    -- 类型抽奖完成，抽奖品
    self.isDraw = true
    m_retType = data.type
    m_retReward = data.reward
    m_jackpot_reward = {}
    m_jackpot_reward.count = REWARD_COUNT[m_retType]
    local sss = gf:deepCopy(m_jackpot_type)
    for _, panelName in pairs(REWARD_PANEL) do
        local panel = self:getControl(panelName)
        local image = self:getControl("TypeSelectImage", nil, panel)
        if image then image:removeFromParent() end  
        
        for i = 1, 6 do
            local unitPanel = self:getControl("ItemImagePanel" .. i, nil, panel)
            if unitPanel then
                local image = unitPanel:getChildByName("BlackImage")
                if image then image:removeFromParent() end        
            end
        end
    end
    
    local typeName = REWARD_PANEL[m_retType]
    local panel = self:getControl(typeName)
    local typeImage = panel:getChildByName("TypeSelectImage")
    if typeImage then
        typeImage:stopAllActions()
        typeImage:setVisible(true)
    else
        typeImage = self.selectTypeImage:clone()
        panel:addChild(typeImage)
    end  
    
    self.totalSteps = 0
    self.curReward = math.random(1, m_jackpot_reward.count)
    self.curReward = 1
    self:setUnitRewardLight(self.curReward, 0.15)
    --]]
    
  --  self:newDrawMagic(data)第三中效果
    
end

function SummerVacationDlg:newDrawMagic(data)
    local sss = gf:deepCopy(m_jackpot_type)
    self.isDraw = true
    m_retType = data.type
    m_retReward = data.reward
    
    local curType = math.random(1, #self.new_pool)
    local curReward = math.random(1, REWARD_COUNT_BY_PANEL[self.new_pool[curType]])
    self.totalSteps = 0
    self:setUnitNewLight(curType,curReward, 0.2)
end

function SummerVacationDlg:setUnitNewLight(curType, curReward, dt)
    self.totalSteps = self.totalSteps + 1
    self.curType = curType
    self.curReward = curReward

    local parentPanel = self:getControl(self.new_pool[curType])
    local panel = self:getControl("ItemImagePanel" .. curReward, nil, parentPanel)
    if not panel then
        local sss
        return
    end

    local typeImage = panel:getChildByName("BlackImage")
    if typeImage then
        typeImage:stopAllActions()
        typeImage:setVisible(true)
    else
        typeImage = self.selectItemImage:clone()
        panel:addChild(typeImage)
    end    

    if dt then
        local fadeOut = cc.FadeOut:create(dt * 2)
        local callBack = cc.CallFunc:create(function ()
            typeImage:removeFromParent()
        end)

        typeImage:runAction(cc.Sequence:create(fadeOut, callBack))
      
        performWithDelay(self.root, function ()            
            local nextType, nextReward, nextDt = self:getNextNewRewardAndDt(curType, curReward, dt)
            self:setUnitNewLight(nextType, nextReward, nextDt)
        end, dt)
    else
        local fadeOut = cc.FadeOut:create(0.4)
        local fadeIn = cc.FadeIn:create(0.4)
        local callBack = cc.CallFunc:create(function ()
            typeImage:removeFromParent()
        end)

        local callBack = cc.CallFunc:create(function ()
            self.isDraw = false
            GiftMgr:fetchSummer2017(1)
        end)

        typeImage:runAction(cc.Sequence:create(fadeOut, fadeIn, callBack))
    end
end

function SummerVacationDlg:getNextNewRewardAndDt(curType, curReward, dt)
    local nextReward = curReward + 1
    local nextType = curType
    local panelName = self.new_pool[curType]    
    if nextReward > REWARD_COUNT_BY_PANEL[panelName] then
        nextType = curType + 1
        if nextType > #self.new_pool then nextType = 1 end
        
        nextReward = 1
    end


    local nextDt
    if self.totalSteps < 10 then
        nextDt = dt - 0.015
    elseif self.totalSteps <= 16 then
        nextDt = dt + 0.02
    elseif self.totalSteps <= 20 then
        nextDt = dt + 0.04
    elseif self.totalSteps > 20 then
        nextDt = dt + 0.05
        local panelName = self.new_pool[curType]
        if self.new_pool[curType] == REWARD_PANEL[m_retType] and curReward == m_retReward then
            nextDt = nil
            nextType = curType
            nextReward = curReward
        end
    end 

    return nextType, nextReward, nextDt
end

function SummerVacationDlg:MSG_SD_2017_LOTTERY_INFO(data)
    self.new_pool = {}
    self.data = data
    local count = 0
    if data.ziqi_quota > 0 then
        count = count + 1
        m_jackpot_type[count] = REWARD_PANEL[1]
        m_jackpot_type[REWARD_PANEL[1]] = 1
        
        table.insert(self.new_pool, REWARD_PANEL[1])
    end
    
    if data.fuying_quota > 0 then
        count = count + 1
        m_jackpot_type[count] = REWARD_PANEL[2]
        m_jackpot_type[REWARD_PANEL[2]] = 2
        
        
        table.insert(self.new_pool, REWARD_PANEL[2])
    end
    
    if data.xiaoxi_quota > 0 then
        count = count + 1
        m_jackpot_type[count] = REWARD_PANEL[3]
        m_jackpot_type[REWARD_PANEL[3]] = 3
        
        table.insert(self.new_pool, REWARD_PANEL[3])
    end
    
    count = count + 1
    m_jackpot_type[count] = REWARD_PANEL[4]
    m_jackpot_type[REWARD_PANEL[4]] = 4
    m_jackpot_type.count = count

    table.insert(self.new_pool, REWARD_PANEL[4])

    self:setData(data)
end

function SummerVacationDlg:MSG_SD_2017_STOP_LOTTERY(data)
    self.root:stopAllActions()
    for _, panelName in pairs(REWARD_PANEL) do
        local panel = self:getControl(panelName)
        local typeImage = panel:getChildByName("TypeSelectImage")
        if typeImage then typeImage:removeFromParent() end    
        
        for i = 1, 6 do
            local unitPanel = self:getControl("ItemImagePanel" .. i, nil, panel)
            if unitPanel then
                local image = unitPanel:getChildByName("BlackImage")
                if image then image:removeFromParent() end        
            end
        end
    end
    
    self.isDraw = false
end

return SummerVacationDlg
