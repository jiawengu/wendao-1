-- ActivitiesInfoFFDlg.lua
-- Created by songcw Sep/16/2015
-- 活动描述悬浮框

local ActivitiesInfoFFDlg = Singleton("ActivitiesInfoFFDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")
local json = require('json')

local SPACE = 10 -- 悬浮框 图片和文字的间隔
local WordWidth = 200 -- 最大文本宽度

function ActivitiesInfoFFDlg:init()
    self:bindListener("ActivitiesInfoFFPanel", self.onCloseButton)
end

function ActivitiesInfoFFDlg:getStartTimeByMainType(mainType)
    local activityTime = ActivityMgr:getActivityStartTimeByMainType(mainType)
    return activityTime.startTime
end

function ActivitiesInfoFFDlg:setData(data, isReward)
    local name = data["name"]
    if data["showName"] then
        name = data["showName"]
    end

    if string.match(name, "Month") then
        local activityStartTime = self:getStartTimeByMainType(data.mainType)
        local m = tonumber(gf:getServerDate("%m", activityStartTime - Const.FIVE_HOURS))
        local newActName = string.gsub(name, "Month", gf:changeNumber(m))
        self:setLabelText("NameLabel", newActName)
    else
        self:setLabelText("NameLabel", name)
    end

    local timeStr = ""
    for i = 1, #data.activityTime do
        if timeStr == "" then
            timeStr = data.activityTime[i][1]
        else
            timeStr = timeStr .. CHS[3002231] .. data.activityTime[i][1]
        end
    end

    if name == CHS[4200511] then
        self:setLabelText("TimeLabel2", CHS[4300370])
    else
        self:setLabelText("TimeLabel2", timeStr)
    end

    self:setLabelText("TeamLabel2", data.team)

    local descStr = data.desc

    if DistMgr:curIsTestDist() and data.testDistDesc then
        descStr = data.testDistDesc
    else
        if data.name == CHS[6400081] then -- 升级狂欢
            descStr = string.format(data.desc, ActivityMgr:get_level_add_exp_precent())
        elseif data.name == CHS[6200075] then -- 全服红包
            local lineNumStr = ActivityMgr:getActivityExtraInfo("quanfu_hongbao")
            if GameMgr:getTotalLieNum() and GameMgr:getTotalLieNum() > 6 and not string.isNilOrEmpty(lineNumStr) then
                descStr = string.format(CHS[7150129], tonumber(lineNumStr))
            else
                descStr = CHS[6200093]
            end
        elseif data.name == CHS[4100285] then
            local taskName = ""
            local acts = ActivityMgr.doubleActvies[data.name]
            if not next(acts) then
                taskName = CHS[3004424]
            else
                taskName = CHS[4200180]
                local i = 1
                for name, _ in pairs(acts) do
                    if i == 1 then
                        taskName = taskName .. name
                    else
                        taskName = taskName .. "、" .. name
                    end
                    i = i + 1
                end
            end

            descStr = string.format(data.desc, taskName)
        elseif data.name == CHS[4100704] then
            local info = json.decode(ActivityMgr.activityInfoEx["activityList"]["cs_league_100"].para)
            descStr = string.format(descStr, math.floor(info.tao_rate / 100))
        end
    end

    if data.name == CHS[7002150] then -- 冲榜大赛
        local endTime = string.match(data.activityTime[1][1], ".*-(.*)")
        descStr = string.format(data.desc, GameMgr:getDistName(), endTime)
    end


    -- 设置描述
    if data.name == CHS[4300236] then
        -- 月首充
        local activityStartTime = self:getStartTimeByMainType(data.mainType)
        local m = tonumber(gf:getServerDate("%m", activityStartTime - Const.FIVE_HOURS))
        descStr = string.gsub(descStr, "Month", gf:changeNumber(m))
    elseif data.name == CHS[4300244] then
        local endTime = string.match(data.activityTime[1][1], ".*-(.*)")
        descStr = string.format(descStr, endTime)
    end

    local reward = data.reward
    local level = data.level
    if DistMgr:curIsTestDist() and data.testLevel then
        level = data.testLevel
    end

    if data.name == CHS[5420168] then
        -- 迎新抽奖
        if ActivityMgr.activityInfoEx
                and ActivityMgr.activityInfoEx["activityList"]
                and ActivityMgr.activityInfoEx["activityList"]["welcome_draw"]
                and ActivityMgr.activityInfoEx["activityList"]["welcome_draw"].para ~= "" then
            local info = json.decode(ActivityMgr.activityInfoEx["activityList"]["welcome_draw"].para)
            reward = info.reward
            descStr = string.format(descStr, info.condition)
            if info.condition == CHS[5420198] then
                level = 50
            end
        end
    elseif data.name == CHS[3000713] then
        -- 镖行万里 ,描述中需要显示周活动完成天数
        descStr = string.format(descStr, math.min(ActivityMgr:getActivityCurDayTimes(data.name), ActivityMgr:getActivityWeekCanRewardDays(data.name)))
    end

    self:setColorText(descStr, "InfoPanel2", nil, 0, 0, COLOR3.WHITE)

    self:setLabelText("LevelLabel2", string.format(CHS[7004001], level))

    -- 如果是内测区
    if DistMgr:isTestDist(GameMgr:getDistName()) and data.testDistReward then
        reward = data.testDistReward
    end

    -- 奖励 add by zhengjh
    local rewardPanel = self:getControl("RewardItemsPanel")
    rewardPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(reward, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)
end

-- 通过完整的数据设置，不需要处理
function ActivitiesInfoFFDlg:setFullData(data, isReward)
    self:setLabelText("NameLabel", data.name)

    self:setLabelText("TimeLabel2", data.time)

    self:setLabelText("LevelLabel2", data.level)

    self:setLabelText("TeamLabel2", data.team)

    self:setColorText(data.desc, "InfoPanel2", nil, 0, 0, COLOR3.WHITE)

    -- 奖励 add by zhengjh
    local rewardPanel = self:getControl("RewardItemsPanel")
    rewardPanel:removeAllChildren(true)

    local reward
    -- 如果是内测区
    if DistMgr:isTestDist(GameMgr:getDistName()) and data.testDistReward then
        reward = data.testDistReward
    else
        reward = data.reward
    end


    local rewardContainer  = RewardContainer.new(reward, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)
end

function ActivitiesInfoFFDlg:setRewardPanel(reward, panel)
    -- 目前没有其他资源，全部用这个代替
    local imageCtl = self:getControl("ItemImage", nil, panel)
    -- 设置图片、未鉴定、限制交易等
    imageCtl:loadTexture(self:getRewardPath(reward), ccui.TextureResType.plistType)
    if reward[1] == CHS[3002233] or reward[1] == CHS[3002234] or  reward[1] == CHS[3002235]  or reward[1] == CHS[3002236] then
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)

        -- 加绑定图片
        if item["limted"] == true then
            InventoryMgr:addLogoBinding(imageCtl)
        end
    end

    if reward[1] == CHS[3002236] then
        if string.match(reward[2], "%%bind") then
            InventoryMgr:addLogoBinding(imageCtl)
        end
    end

    --[[if reward[1] == "未鉴定" then
        InventoryMgr:addLogoUnidentified(imageCtl)
    end  ]]

    -- 绑定点击事件
    local function imagePanelTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            if reward[1] == CHS[6000078] then       -- 道具
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local item = TaskMgr:spliteItemInfo(itemInfoList)
                local rect = self:getBoundingBoxInWorldSpace(panel)
                local dlg = DlgMgr:openDlg("ItemInfoDlg")
                dlg:setInfoFormCard(item)
                dlg:setFloatingFramePos(rect)

            elseif reward[1] == CHS[3002235] then
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local itemInfo = TaskMgr:spliteItemInfo(itemInfoList)
                local rect = self:getBoundingBoxInWorldSpace(panel)

                if string.match(itemInfo["name"], ".+=(T)") then
                    local item = {}
                    item.item_type = ITEM_TYPE.EQUIPMENT
                    item.unidentified = 1
                    item.name = string.gsub(itemInfo["name"],"=T","")
                    item.level = itemInfo["level"] or 0
                    item.req_level = itemInfo["level"] or 0
                    item.limted = itemInfo.limted

                    -- InventoryMgr:showBasicMessageDlg(item, rect)
                    local dlg = DlgMgr:openDlg("ItemInfoDlg")
                    dlg:setInfoFormCard(item)
                    dlg:setFloatingFramePos(rect)
                else
                    self:setRewardInfoDlg(panel, reward)
                end

            else
                self:setRewardInfoDlg(panel, reward)
            end
        end
    end

    panel:addTouchEventListener(imagePanelTouch)
end

function ActivitiesInfoFFDlg:setRewardInfoDlg(panel, reward)
    local rect = self:getBoundingBoxInWorldSpace(panel)
    local dlg = DlgMgr:openDlg("RewardShowInfoDlg")
    local showContainer = self:createRewardCell(reward)
    dlg.root:addChild(showContainer)
    dlg.root:setContentSize(showContainer:getContentSize().width + SPACE * 2, showContainer:getContentSize().height + SPACE * 2)
    showContainer:setPosition(dlg.root:getContentSize().width / 2, dlg.root:getContentSize().height / 2)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function ActivitiesInfoFFDlg:createRewardCell(reward)
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5, 0.5)

    -- 加载奖励图标
    local imgPath = self:getRewardPath(reward)
    local iconImg = ccui.ImageView:create(imgPath, ccui.TextureResType.plistType)
    iconImg:setAnchorPoint(0, 1)
    layout:addChild(iconImg)


    if reward[1] == CHS[3002233] or reward[1] == CHS[3002234] or  reward[1] == CHS[3002235]  or reward[1] == CHS[3002236] then
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)

        -- 加绑定图片
        if item["limted"] == true then
            InventoryMgr:addLogoBinding(iconImg)
        end
    end

    if  reward[1] == CHS[3002236] then
        if  string.match(reward[2], "$Valid") then
            InventoryMgr:addLogoTimeLimit(iconImg)
        elseif string.match(reward[2], "%%bind") then
            InventoryMgr:addLogoBinding(iconImg)
        end
    end


    -- 加载文字
    local textList = self:getTextList(reward)
    local textLayout = ccui.Layout:create()
    local textMaxWidth = 0
    local innerHeight = 0
    local colorListTable = {}

    for i = #textList, 1, -1  do
        if reward[1] == CHS[6000080] and  i == 2 then -- 金钱
            textList[i] = gf:getMoneyDesc(tonumber(textList[i]))
        end

        local lableText = CGAColorTextList:create()
        lableText:setFontSize(18)
        lableText:setString(textList[i])
        lableText:setContentSize(WordWidth, 0)
        lableText:updateNow()
        local labelW, labelH = lableText:getRealSize()
        local colorLayer = tolua.cast(lableText, "cc.LayerColor")
        colorLayer:setAnchorPoint(0, 0)
        colorLayer:setPosition(0, innerHeight)
        textLayout:addChild(colorLayer)
        innerHeight = innerHeight + labelH
        table.insert(colorListTable, colorLayer)

        if textMaxWidth < labelW then
            textMaxWidth = labelW
        end

        if reward[1] == CHS[3002233] then
            lableText:setDefaultColor(textList["color"].r, textList["color"].g, textList["color"].b)
        else
            lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
        end
    end

    textLayout:setContentSize(textMaxWidth, innerHeight)
    textLayout:setAnchorPoint(0, 0.5)
    layout:addChild(textLayout)

    for i = 1,#colorListTable do
        local lableText = tolua.cast(colorListTable[i], "CGAColorTextList")
        local x,y = colorListTable[i]:getPosition()
        local labelW, labelH = lableText:getRealSize()
        colorListTable[i]:setPosition((textMaxWidth-labelW) / 2, y)
    end

    local height = 0

    if iconImg:getContentSize().height > innerHeight then
        height = iconImg:getContentSize().height
    else
        height = innerHeight
    end

    iconImg:setPosition(0, height)
    textLayout:setPosition(iconImg:getContentSize().width + SPACE, height / 2)
    layout:setContentSize(iconImg:getContentSize().width + textMaxWidth + SPACE, height)

    return layout
end

-- 获取奖励图片路径
function ActivitiesInfoFFDlg:getRewardPath(reward)
    local imgPath = ""

    if reward[1] == CHS[6000079] then       -- 宠物
        imgPath = ResMgr.ui["pet_common"]
    elseif reward[1] == CHS[6000078] then   -- 道具
        --  local content = gf:split(reward[2], "#r")
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)
        imgPath = ResMgr.ui["item_common"]

    elseif reward[1] == CHS[6000041]  then  -- 金元宝
        imgPath = ResMgr.ui["big_gold"]
    elseif reward[1] == CHS[6000042] then   -- 银元宝
        imgPath = ResMgr.ui["big_yinyuanbao"]
    elseif reward[1] == CHS[6000080] then   -- 金钱
        imgPath = ResMgr.ui["big_cash"]
    elseif reward[1] == CHS[3002237] then -- 代金券
        imgPath = ResMgr.ui["big_cash"]
    elseif reward[1] == CHS[6000081] then   -- 经验
        imgPath = ResMgr.ui["experience"]
    elseif reward[1] == CHS[3000049] then   -- 道行
        imgPath = ResMgr.ui["daohang"]
    elseif reward[1] == CHS[3000050] then   -- 武学
        imgPath = ResMgr.ui["wuxue"]
    elseif reward[1] == CHS[3002238] then
        imgPath = ResMgr.ui["pot_icon"]
    elseif reward[1] == CHS[3002235] then
        imgPath = ResMgr.ui["big_identify_equip"]
    elseif reward[1] == CHS[3002239] then
        imgPath = ResMgr.ui["title"]
    elseif reward[1] == CHS[3002240] then
        imgPath = ResMgr.ui["big_banggong"]
    elseif reward[1] == CHS[3002233] then
        imgPath = ResMgr.ui["big_equip"]
    elseif reward[1] == CHS[7100257] then
        imgPath = ResMgr.ui["big_inn_coin"]
    elseif reward[1] == CHS[7190229] then
        imgPath = ResMgr.ui["big_tan_an_score"]
    elseif reward[1] == CHS[7190534] then
        imgPath = ResMgr.ui["big_qinmidu"]
    elseif reward[1] == CHS[7120211] then
        imgPath = ResMgr.ui["big_wawazizhi"]
    else
        imgPath = ResMgr.ui["others_icon"]  -- 没有匹配类型(其他)
    end

    return imgPath
end

-- 获取通用文本行数
function ActivitiesInfoFFDlg:getTextList(reward)
    local textList = {}

    if reward[1] == CHS[6000079] then   --宠物
        local petName, petRank = string.match(reward[2], "(.+)%((.+)%)(.*)")
        textList[1] = petName
        textList[2] = string.format("(%s)", petRank)
    elseif reward[1] == CHS[6000082] then  -- 其他
        textList[1] = reward[2]
    elseif reward[1] == CHS[3002233] then
        textList[1] =  gf:splitBydelims(reward[2], {"%", "$", "#r"})[1]
        local color = string.match(reward[2], ".+$color=%((.+)%).*")
        local colorList = gf:split(color, "&")

        if #colorList > 1 then
            textList["color"] = COLOR3.TEXT_DEFAULT
        else
            textList["color"] = TaskMgr:getEquipColor(color)
        end
    elseif reward[1] == CHS[3002234] or reward[1] == CHS[3002235] then
        local itemInfoList =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)
        textList[1] = item["name"]
        --textList[2] = item["number"]
    elseif reward[1] == CHS[3002239] then
        textList = gf:split(reward[2], "#r")
        local content = gf:split(textList[1], "$")
        textList[1] = content[1]
    else
        textList = gf:split(reward[2], "#r")
    end
    return textList
end

return ActivitiesInfoFFDlg
