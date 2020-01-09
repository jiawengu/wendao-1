-- ChunjieNianyefanDlg.lua
-- Created by huangzz Dec/23/2016
-- 守岁年夜饭界面

local ChunjieNianyefanDlg = Singleton("ChunjieNianyefanDlg", Dialog)

local RewardContainer = require("ctrl/RewardContainer")

local REWAR_DESC =
{
    [CHS[3002147]] = CHS[3002148],
}

-- 下边奖品信息
local GIFT_REWARD_INFO = {
    {icon = ResMgr.ui.caiyao1, startTime = 19, name = CHS[5420030], reward = CHS[5420036], num = 0},
    {icon = ResMgr.ui.caiyao2, startTime = 20, name = CHS[5420031], reward = CHS[5420037], num = 1},
    {icon = ResMgr.ui.caiyao3, startTime = 21, name = CHS[5420032], reward = CHS[5420038], num = 1},
    {icon = ResMgr.ui.caiyao4, startTime = 22, name = CHS[5420033], reward = CHS[5420039], num = 1},
    {icon = ResMgr.ui.caiyao5, startTime = 23, name = CHS[5420034], reward = CHS[5420040], num = 2},
    {icon = ResMgr.ui.caiyao6, startTime = 0, name = CHS[5420035], reward = CHS[5420041], num = 2},
}

-- 上边大奖信息
local BIG_REWARD_INFO = {
    {startTime = 20, name = CHS[5420043], reward = CHS[5420050], desc1 = string.format(CHS[5420048], "20:00"), desc2 = string.format(CHS[5420042], 5, string.format(CHS[5420049], 10))},
    {startTime = 21, name = CHS[5420044], reward = CHS[5420051], desc1 = string.format(CHS[5420048], "21:00"), desc2 = string.format(CHS[5420042], 10, string.format(CHS[5420049], 5))},
    {startTime = 22, name = CHS[5420045], reward = CHS[5420052], desc1 = string.format(CHS[5420048], "22:00"), desc2 = string.format(CHS[5420042], 1, CHS[4300125])},
    {startTime = 23, name = CHS[5420046], reward = CHS[5420053], desc1 = string.format(CHS[5420048], "23:00"), desc2 = string.format(CHS[5420042], 1, string.format(CHS[5420055], 6))},
    {startTime = 0, name = CHS[5420047], reward = CHS[5420054], desc1 = string.format(CHS[5420048], "00:00"), desc2 = string.format(CHS[5420042], 1, CHS[5420056])},
}

local STATUS = {
    GOT = "1",
    CAN_GET = "2",
    KNOCK = "3",  -- 敲钟状态
}

local FOOD_PANEL_SPACE = 3

function ChunjieNianyefanDlg:init()
    self:setCtrlFullClient("BlackPanel")

    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("RewardPanel_1", self.onShowItemInfo, "FoodPanel")
    self:bindListener("RewardPanel", self.onShowItemInfo, "InfoPanel")
    self:bindListener("LuckyPanel", self.onLuckyPanel)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("TipsButton", self.onTipsButton)
    self:bindListener("KnockButton", self.onKnockButton)
    
    self:setCtrlVisible("RewardPanel_2", false)
    
    self.foodPanel = self:retainCtrl("FoodPanel_1")
    
    self.rewardPanel = self:retainCtrl("RewardPanel_1",  self.foodPanel)
    
    self.listView = self:resetListView("ListView", FOOD_PANEL_SPACE)

    self.nianyefanInfo = {}
    
    self.isFirstScroll = true
    
    self.curBigReward = 1
    self:creatListView()

    self:setCtrlVisible("BlackPanel", false)

    self:createArmature()

    self:hookMsg("MSG_SPRING_2019_ZSQF_START_GAME")
    self:hookMsg("MSG_SPRING_2019_ZSQF_QUIT_GAME")
end

function ChunjieNianyefanDlg:createArmature()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.zhongsqf_knock.name)
    local showPanel = self:getControl("ShowPanel", nil, "BlackPanel")
    magic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setVisible(false)
    showPanel:addChild(magic)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            self:setCtrlVisible("BlackPanel", false)
            gf:ShowSmallTips(CHS[5400703])
            self.clock:setVisible(false)
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)

    self.clock = magic
end

function ChunjieNianyefanDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
end

function ChunjieNianyefanDlg:onLuckyPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = ResMgr.ui.nyf_lucky,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = CHS[5400327]
        },

        desc = CHS[5420060]
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function ChunjieNianyefanDlg:onLeftButton(sender, eventType)
    if self.curBigReward <= 1 then
        return
    end

    self.curBigReward = self.curBigReward - 1
    self:setBigRewardItemPanel()
end

function ChunjieNianyefanDlg:onRightButton(sender, eventType)
    if self.curBigReward >= #BIG_REWARD_INFO then
        return
    end

    self.curBigReward = self.curBigReward + 1
    self:setBigRewardItemPanel()
end

function ChunjieNianyefanDlg:onTipsButton(sender, eventType)
    DlgMgr:openDlgEx("NianyefanRuleDlg", BIG_REWARD_INFO)
end

function ChunjieNianyefanDlg:checkButton()
    if self.curBigReward <= 1 then
        self:setCtrlEnabled("LeftButton", false)
    else
        self:setCtrlEnabled("LeftButton", true)
    end
    
    if self.curBigReward >= #BIG_REWARD_INFO then
        self:setCtrlEnabled("RightButton", false)
    else
        self:setCtrlEnabled("RightButton", true)
    end
end

-- 将指定的菜肴条目滑到显示列表第二位
function ChunjieNianyefanDlg:scrollToOne(index)
    self.listView:doLayout()
    index = math.max(index - 2, 0)
    
    local scrollHeight = (self.foodPanel:getContentSize().height + FOOD_PANEL_SPACE) * index

    local totoalOffset = self.listView:getInnerContainer():getContentSize().height - self.listView:getContentSize().height
    local percent = math.min(scrollHeight / totoalOffset * 100, 100)

    self.listView:jumpToPercentVertical(percent)
end

function ChunjieNianyefanDlg:creatListView()
    for i = 1, #GIFT_REWARD_INFO do
        local cell = self.foodPanel:clone()
        self:setfoodPanel(cell, GIFT_REWARD_INFO[i])
        self.listView:pushBackCustomItem(cell)
    end
end

function ChunjieNianyefanDlg:setOneReward(cell, reward)
    local imgPath, textureResType = RewardContainer:getRewardPath(reward)
    local img = self:getControl("RewardImage", nil, cell)
    img:loadTexture(imgPath, textureResType)
    
    local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
    local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
    
    -- 加上限时或者限制交易图标
    if item and item["time_limited"] then
        InventoryMgr:addLogoTimeLimit(img)
    elseif item and item["limted"] then
        InventoryMgr:addLogoBinding(img)
    end
    
    if item.number and tonumber(item.number) > 1 and item.name ~= CHS[3002145] then
        self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, item.number, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    else
        img:removeChildByTag(LOCATE_POSITION.RIGHT_BOTTOM * 999)
    end
    
    cell.reward = reward
end

function ChunjieNianyefanDlg:setfoodPanel(cell, data)
    self:setLabelText("NameLabel", string.format(CHS[5420062], data.name), cell)
    self:setImage("FoodImage", data.icon, cell)

    -- 设置奖品信息
    local reward = TaskMgr:getRewardList(data.reward)
    if #reward < 0 then
        return
    end

    local size = self.rewardPanel:getContentSize()
    local x, y = self.rewardPanel:getPosition()
    local space = -2
    local cou = #reward[1]
    for i = 1, cou do
        local panel = self.rewardPanel:clone()
        panel:setPositionX(x + (size.width + space) * (i - 1))
        self:setOneReward(panel, reward[1][i])
        cell:addChild(panel)
    end
    
    -- 幸运值图标
    local luckyPanel = self:getControl("LuckyPanel", nil, cell)
    luckyPanel:setPositionX(x + (size.width + space) * cou)
    
    -- 幸运值图标的扇形倒计时
    local luckyPanel = self:getControl("LuckyPanel", nil, cell)
    local progressImage = self:getControl("RateImage", nil, luckyPanel)
    progressImage:setVisible(false)
    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create(ResMgr.ui.grid_progressTimer))
    progressTimer:setReverseDirection(false)
    progressTimer:setName("ProgressTimer")
    luckyPanel:addChild(progressTimer)

    progressTimer:setPosition(progressImage:getPosition())
    progressTimer:setScale(progressImage:getScale())
    progressTimer:setLocalZOrder(15)
    progressTimer:setPercentage(0)
    
    self:setCtrlEnabled("NoReachButton", false, cell)
    self:setCtrlVisible("GotImage", false, cell)
    
    cell.cfgData = data
end

function ChunjieNianyefanDlg:setRewardLabel(str, ctrlName, root)
    local panel = self:getControl(ctrlName, nil, root)
    self:setLabelText("Label_1", str, panel)
    self:setLabelText("Label_2", str, panel)
end

function ChunjieNianyefanDlg:setBigRewardItemPanel()
    local infoPanel = self:getControl("InfoPanel")
    local introPanel = self:getControl("IntroducePanel", nil, infoPanel)
    local tag = self.curBigReward
    local data = BIG_REWARD_INFO[tag]
    
    -- 大奖描述
    self:setRewardLabel(data.name, "RewardPanel_1", introPanel)
    self:setRewardLabel(data.desc1, "RewardPanel_2", introPanel)
    self:setRewardLabel(data.desc2, "RewardPanel_3", introPanel)

    local reward = TaskMgr:getRewardList(data.reward)
    local panel = self:getControl("RewardPanel", nil, infoPanel)
    self:setOneReward(panel, reward[1][1])
    
    -- 已发放图标
    local curTime = gf:getServerTime()
    local interval = self.nianyefanInfo.interval
    local getTime = self.nianyefanInfo.start_time + interval * tag
    if curTime >= getTime then
        self:setCtrlVisible("IssuedImage", true, panel)
    else
        self:setCtrlVisible("IssuedImage", false, panel)
    end
    
    -- 检测左右按钮
    self:checkButton()
end

function ChunjieNianyefanDlg:onGetButton(sender, eventType)
    local panel = sender:getParent()
    local tag = panel:getTag()
    local data = panel.cfgData


    if InventoryMgr:getEmptyPosCount() < data.num then
        -- 包裹格子数
        gf:ShowSmallTips(string.format(CHS[5420061], data.num))
        return
    end

    gf:CmdToServer("CMD_SPRING_2019_ZSQF_FETCH", {index = tag})
end

-- 敲钟
function ChunjieNianyefanDlg:onKnockButton(sender, eventType)
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[4000223])
        return
    end
    
    if Me:queryInt("level") < 30 then
        gf:ShowSmallTips(CHS[5420058])
        return
    end
    
    if self.nianyefanInfo.activeValue < self.nianyefanInfo.needActiveValue then
        -- 活跃度
        gf:ShowSmallTips(CHS[5420059])
        return
    end

    self.selectPanel = sender:getParent()
    gf:CmdToServer("CMD_SPRING_2019_ZSQF_START_GAME", {index = self.selectPanel:getTag()})
end

function ChunjieNianyefanDlg:compareTime(time1, time2)
    if time1 == time2 then
        return 0
    elseif time1 == 0 then
        return 1
    elseif time2 == 0 then
        return -1
    elseif time1 < time2 then
        return -1
    else
        return 1
    end
end

function ChunjieNianyefanDlg:setOneFoodStatus(cell, status, tag, curTime, luckNum)
    local interval = self.nianyefanInfo.interval
    local getTime = self.nianyefanInfo.start_time + interval * (tag - 1)
    local totalCou = #GIFT_REWARD_INFO
    cell.info = {status = status, time = getTime, interval = interval}
    if status == STATUS.CAN_GET or status == STATUS.KNOCK then
        -- 待领取
        if curTime >= getTime then
            -- 可领取
            local canGet = status ~= STATUS.KNOCK 
                            or (curTime - self.nianyefanInfo.start_time >= interval * 5 and tag ~= totalCou)
                            or (curTime - getTime >= interval and tag == totalCou)
            self:setCtrlVisible("KnockButton", not canGet, cell)
            self:setCtrlVisible("GetButton", canGet, cell)
            self:setCtrlVisible("NoReachButton", false, cell)
        else
            -- 请稍等
            self:setCtrlVisible("GetButton", false, cell)
            self:setCtrlVisible("NoReachButton", true, cell)
        end
        
        if self.isFirstScroll then
            self:scrollToOne(tag)
            self.isFirstScroll = false
        end

        self:setCtrlVisible("GotImage", false, cell)
    elseif status == STATUS.GOT then
        -- 已领取
        self:setCtrlVisible("GetButton", false, cell)
        self:setCtrlVisible("NoReachButton", false, cell)
        self:setCtrlVisible("GotImage", true, cell)
    end
    
    -- 幸运值倒计时
    local luckyPanel = self:getControl("LuckyPanel", nil, cell)
    local rewardImage = self:getControl("RewardImage", nil, luckyPanel)
    local timer = luckyPanel:getChildByName("ProgressTimer")
    if curTime >= getTime and curTime - getTime < interval then
        self:setDownTime(getTime, timer)

        -- 设置当前时间段的大奖
        if tag <= #BIG_REWARD_INFO then
            self.curBigReward = tag
        end
    end
    
    if tag == totalCou or curTime - self.nianyefanInfo.start_time >= interval * 5 or status == STATUS.GOT then
        luckyPanel:setVisible(false)
    else
        luckyPanel:setVisible(true)
    end
    
    -- 开启时间
    local startTime = os.date(CHS[5420057], getTime)
    self:setLabelText("TimeLabel", startTime, cell)

    -- 幸运值数量
    if luckNum > 1 then
        self:setNumImgForPanel(rewardImage, ART_FONT_COLOR.NORMAL_TEXT, luckNum, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end
end

-- 设置每个整点年夜饭状态
function ChunjieNianyefanDlg:setStatus(data)
    if data.activeValue then
        self.nianyefanInfo = data
    else
        self.nianyefanInfo.status = data.status
    end
   
    self.curBigReward = #BIG_REWARD_INFO
    
    -- 设置各个菜肴的状态
    local curTime = gf:getServerTime()
    local foodPanels = self.listView:getItems()
    for i = 1, string.len(data.status) do
        local c = string.sub(data.status, i, i)
        local num = tonumber(string.sub(data.lucks_num, i, i)) or 0
        local panel = foodPanels[i]
        panel:setTag(i)
        self:setOneFoodStatus(panel, c, i, curTime, num)
    end
    
    -- 未到 19:00，开启定时器 19:00 时刷新一下
    if not self.schedulId and curTime <= self.nianyefanInfo.start_time then
        if self.schedulId19 then
            self:stopSchedule(self.schedulId19)
            self.schedulId19 = nil
        end
        
        self.schedulId19 = self:startSchedule(function() 
            local time = gf:getServerTime()
            if time > self.nianyefanInfo.start_time then
                self:setStatus(self.nianyefanInfo)
                self:stopSchedule(self.schedulId19)
                self.schedulId19 = nil
            end
        end, 1) 
        
        self.curBigReward = 1
    end

    -- 设置大奖信息
    self:setBigRewardItemPanel()
    
    -- 设置当前幸运值
    if data.lucky_num then
        self:setRewardLabel(CHS[5400327] .. "  " .. data.lucky_num, "LuckyPanel", "InfoPanel")
    end
end

-- 可品尝的剩余时间倒计时
function ChunjieNianyefanDlg:setDownTime(getTime, timer)
    local interval = self.nianyefanInfo.interval
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end

    local function func()
        local curTime = gf:getServerTime()
        local timeC = curTime - getTime
        if timeC >= interval then
            self:stopSchedule(self.schedulId)
            self.schedulId = nil
            self:setStatus(self.nianyefanInfo)
        end
    end
    
	func()
    self.schedulId = self:startSchedule(func, 1)
end

function ChunjieNianyefanDlg:MSG_SPRING_2019_ZSQF_START_GAME(map)
    if not self.selectPanel then return end
    local data = self.selectPanel.cfgData
    local info = self.selectPanel.info
    if info and info.status == STATUS.KNOCK then
        local index = self.selectPanel:getTag()
        if index == 6 then
            self:setCtrlVisible("BlackPanel", true)
            self.clock:setVisible(true)
            self.clock:getAnimation():play("Top", -1, 0)

            local str = gfEncrypt(tostring(0) .. "_" .. "0_1", map.encrypt_id)
            gf:CmdToServer("CMD_SPRING_2019_ZSQF_COMMIT_GAME", {result = str, index = 6})
        else
            DlgMgr:openDlgEx("ZhongsqfDlg", {
                index = index,
                hour = data.startTime,
                time = self.nianyefanInfo.start_time, 
                interval = info.interval,
                encryptId = map.encrypt_id
            })
        end
    end
end

function ChunjieNianyefanDlg:MSG_SPRING_2019_ZSQF_QUIT_GAME(map)
    DlgMgr:closeDlg("ZhongsqfDlg")
end

function ChunjieNianyefanDlg:cleanup()
    self.schedulId = nil
    self.schedulId19 = nil

    DlgMgr:closeDlg("ZhongsqfDlg")

    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.zhaocaishu, "armatureName")
end

return ChunjieNianyefanDlg
