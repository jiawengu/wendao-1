-- TeamAdjustmentDlg.lua
-- Created by liuhb Apr/28/2015
-- 自动组队调整

local TeamAdjustmentDlg = Singleton("TeamAdjustmentDlg", Dialog)
local NumImg = require('ctrl/NumImg')

local leftSelectCtrls = {}

local oneActiveAdjustList
local twoActiveAdjustListMap
local activeLevelMap


local minCtrlList = {}
local maxCtrlList = {}
local START_INDEX = 20

function TeamAdjustmentDlg:init()
    self:bindListener("StartButton", self.onStartButton)

    oneActiveAdjustList = TeamMgr:getOneActiveAdjustList()
    twoActiveAdjustListMap = TeamMgr:getTwoActiveAdjustListMap()
    activeLevelMap = TeamMgr:getActiveLevelMap()

    self:initLeftViewData()
    self:updateLeftViewData()

    self:setLabelText("InfoLabel1", "")
    self:setLabelText("InfoLabel2", "")
    self:setLabelText("InfoLabel3", "")
    local matchInfo = TeamMgr:getCurMatchInfo()
    if 2 == matchInfo.state then
        local oneName = self:getOneName(matchInfo.name)
        self:selectItemEx(oneName, matchInfo.name)
        self:scrollToItem(oneName, matchInfo.name)
    else
        self:selectItemEx(CHS[3003726], "")
    end

    local stButton = self:getControl("StartButton")
    self:setLabelText("Label1", CHS[3003727], stButton)
    self:setLabelText("Label2", CHS[3003727], stButton)
end

function TeamAdjustmentDlg:cleanup()
    for i = 1, #minCtrlList do
        minCtrlList[i]:release()
        maxCtrlList[i]:release()
    end

    minCtrlList = {}
    maxCtrlList = {}

    self.curSelectName = nil
    leftSelectCtrls = {}

    self:releaseCloneCtrl("bigCtrl")
    self:releaseCloneCtrl("smallCtrl")
    self:releaseCloneCtrl("label")
    self:releaseCloneCtrl("selectOneImg")
    self:releaseCloneCtrl("selectTwoImg")
    self:releaseCloneCtrl("selectOneAndSec")
end

-- 获取一级二菜单选中光效
function TeamAdjustmentDlg:getOneEffectImgbySecond()
    if nil == self.selectOneAndSec then
        -- 创建选择框
        local img = self:getControl("SelectedPanel", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectOneAndSec = img
    end

    self.selectOneAndSec:removeFromParent(false)

    return self.selectOneAndSec
end

-- 获取一级菜单选中光效
function TeamAdjustmentDlg:getOneEffectImg()
    if nil == self.selectOneImg then
        -- 创建选择框
        local img = self:getControl("BChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectOneImg = img
    end

    self.selectOneImg:removeFromParent(false)

    return self.selectOneImg
end

-- 获取二级菜单选中光效
function TeamAdjustmentDlg:getTwoEffectImg()
    if nil == self.selectTwoImg then
        -- 创建选择框
        local img = self:getControl("SChosenEffectImage", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectTwoImg = img
    end

    self.selectTwoImg:removeFromParent(false)

    return self.selectTwoImg
end

-- 创建等级项
function TeamAdjustmentDlg:createLevelItem(level)
    if not self.label then
        return
    end

    local itemContentSize = self.label:getContentSize()

    local ctrl = ccui.Layout:create()
    ctrl:setContentSize(itemContentSize)
    local img = NumImg.new('white_25_black', level)
    img:setPosition(itemContentSize.width / 2, itemContentSize.height / 2)
    ctrl:addChild(img)

    return ctrl
end

-- 初始化界面控件
function TeamAdjustmentDlg:initLeftViewData()
    self:getOneEffectImg()
    self:getTwoEffectImg()

    -- 获取一级控件
    self.bigCtrl = self:getControl("BigPanel")
    self:setCtrlVisible("DownArrowImage", false, self.bigCtrl)
    self:setCtrlVisible("UpArrowImage", false, self.bigCtrl)
    self.bigCtrl:retain()

    -- 获取二级控件
    self.smallCtrl = self:getControl("SPanel")
    self.smallCtrl:retain()

    -- 初始化列表控件
    self.leftListCtrl, self.leftListSize = self:resetListView("CategoryListView", 1)
    self.leftListCtrl:setGravity(ccui.ListViewGravity.centerVertical)

    self.label = self:getControl("OneLevelLabel"):clone()
    self.label:retain()
    self.label:removeFromParent()
    self.label:setVisible(true)
    self.label:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
    self.label:setTextVerticalAlignment(cc.TEXT_ALIGNMENT_CENTER)

    -- 创建120个控件缓存
    for i = 20, 80 do
        local item = self:createLevelItem(i)
        item:retain()
        table.insert(minCtrlList, item)

        item = self:createLevelItem(i)
        item:retain()
        table.insert(maxCtrlList, item)
    end

    self.rightMagin = self:getControl("SelectedImage1"):getContentSize().height - self.label:getContentSize().height

    self.minList, self.minSize = self:resetListView("MinListView", self.rightMagin)
    self.maxList, self.maxSize = self:resetListView("MaxListView", self.rightMagin)
end

-- 初始化界面
function TeamAdjustmentDlg:updateLeftViewData()
    if nil == oneActiveAdjustList then
        return
    end

    local isFirst = true
    local level = Me:queryBasicInt("level")
    for i = 1, #oneActiveAdjustList do
        local value = twoActiveAdjustListMap[oneActiveAdjustList[i]]
        local k = oneActiveAdjustList[i]

        -- key 为一级菜单
        if level >= activeLevelMap[k].level then
            local newOne = self.bigCtrl:clone()
            self:setLabelText("Label", k, newOne)
            newOne.isExpand = false
            newOne.value = value
            newOne.key = k

            if #value ~= 0 then
                self:setCtrlVisible("DownArrowImage", true, newOne)
                self:setCtrlVisible("UpArrowImage", false, newOne)
            end

            if isFirst then
                self.firstOneCtrl = newOne
                isFirst = false
            end

            self:bindTouchEndEventListener(newOne, self.oneClick)
            self.leftListCtrl:pushBackCustomItem(newOne)
            table.insert(leftSelectCtrls, newOne)
        end
    end
end

function TeamAdjustmentDlg:getActiveRank(actName)
    local min = TeamMgr:getMinLevelActive(actName)
    local max = TeamMgr:getMaxLevelActive(self.curSelectName)
    --[[
    if actName == CHS[5000159] then
        min = math.max(activeLevelMap[actName].level, Me:getLevel() - 15)
        max = math.min(Const.PLAYER_MAX_LEVEL, Me:getLevel() + 15)
    elseif actName == CHS[5000160] or actName == CHS[5000161] then
        min = math.max(activeLevelMap[actName].level, Me:getLevel() - 9)
        max = math.min(Const.PLAYER_MAX_LEVEL, Me:getLevel() + 9)
    end
    --]]
    return min, max
end

-- 一级菜单点击事件
function TeamAdjustmentDlg:oneClick(sender, eventType, isExpand)
    local value = sender.value

    -- 已经是展开状态了
    if isExpand then
        if sender.isExpand then
            return
        end
    end

    local level = Me:queryBasicInt("level")
    local isFirst = true
    if not sender.isExpand then
        -- 如果没有展开，插入
        -- value为二级菜单
        self:closeAllSelectItem()
        self.curTwoItemNum = 0
        if #value == 0 then
            sender:addChild(self:getOneEffectImg())
            self:getOneEffectImgbySecond()

            self:updateDescPanel(sender.key)
            self.curSelectName = sender.key
            local level = Me:queryBasicInt("level")
    --        self:updateRightList(activeLevelMap[sender.key].level, TeamMgr:getMaxLevelActive())
            self:updateRightList(self:getActiveRank(sender.key))
        else
            self:setCtrlVisible("DownArrowImage", false, sender)
            self:setCtrlVisible("UpArrowImage", true, sender)
        end

        local realIndex = 0
        for i = 1, #value do
            if level >= activeLevelMap[value[i]].level then
                realIndex = realIndex + 1
                self.curTwoItemNum = self.curTwoItemNum + 1
                local newTwo = self.smallCtrl:clone()

                -- 进行切割“其他”类别
                local name = string.match(value[i], ".*-(.*)")
                if nil ~= name then
                    self:setLabelText("Label", name, newTwo)
                else
                    self:setLabelText("Label", value[i], newTwo)
                end

                local index = self.leftListCtrl:getIndex(sender)
                newTwo.key = value[i]
                self:bindTouchEndEventListener(newTwo, self.twoClick)
                -- self:setCtrlVisible("ChosenEffectImage", false, newTwo)

                self.leftListCtrl:insertCustomItem(newTwo, index + realIndex)
                sender.isExpand = true

                if isFirst then
                    self.firstTwoCtrl = newTwo
                    isFirst = false
                end

                if self.curSelectName == value[i] then
                    self:twoClick(newTwo)
                end
            end
        end
    else
        for i = 1, self.curTwoItemNum do
            local index = self.leftListCtrl:getCurSelectedIndex()
            self.leftListCtrl:removeItem(index + 1)
            sender.isExpand = false
        end

        local isSelectSec = false
        for i, v in pairs(twoActiveAdjustListMap[sender.key]) do
            if v == self.curSelectName then
                isSelectSec = true
            end
        end

        if isSelectSec then
            local oneAndSecPanel = self:getOneEffectImgbySecond()
            self:setLabelText("BigLabel", sender.key, oneAndSecPanel)
            self:setLabelText("SLabel", self.curSelectName, oneAndSecPanel)
            sender:addChild(oneAndSecPanel)
        end

        self:setCtrlVisible("DownArrowImage", true, sender)
        self:setCtrlVisible("UpArrowImage", false, sender)
    end

end

-- 二级菜单点击事件
function TeamAdjustmentDlg:twoClick(sender, eventType, noSend)
    Log:D(">>>>>Click item : " .. sender.key)
    self.curSelectName = sender.key
    -- self:setCtrlVisible("ChosenEffectImage", true, sender)
    sender:addChild(self:getTwoEffectImg())
    self:getOneEffectImgbySecond()
    if self.selectOneImg then self.selectOneImg:removeFromParent(false) end
    -- 请求数据
    local level = Me:queryBasicInt("level")
--    self:updateRightList(activeLevelMap[sender.key].level, TeamMgr:getMaxLevelActive())
    self:updateRightList(self:getActiveRank(sender.key))
    self:updateDescPanel(sender.key)
end

function TeamAdjustmentDlg:updateDescPanel(name)
    local limitInfo1 = self:getControl("InfoLabel1")
    local limitInfo3 = self:getControl("InfoLabel3")
    local activeInfo
    if nil ~= activeLevelMap[name].parent then
        activeInfo = ActivityMgr:getActivityByName(activeLevelMap[name].parent)
    else
        activeInfo = ActivityMgr:getActivityByName(name)
    end
    self:setLabelText("InfoLabel2", CHS[3003728])
    if nil ~= activeInfo then
        local str = self:getActivityStr(activeInfo)
        limitInfo3:setString(str)
    else
        local str = self:getActivityStr(name)
        limitInfo3:setString(str)
    end

    local str = CHS[3003729] .. TeamMgr:getActiveLimit(name)-- self:getLimitStr(activeLevelMap[name].level)
    limitInfo1:setString(str)
end

-- 关闭左侧所有的菜单
function TeamAdjustmentDlg:closeAllSelectItem()
    for i = 1, #leftSelectCtrls do
        local ctrl = leftSelectCtrls[i]
        local value = ctrl.value
        self:setCtrlVisible("ChosenEffectImage", false, ctrl)
        if ctrl.isExpand then
            local isSelectSec = false
            for j = 1, self.curTwoItemNum do
                local index = self.leftListCtrl:getIndex(ctrl)
                local item = self.leftListCtrl:getItem(index + 1)
                if self:getLabelText("Label", item) == self.curSelectName then
                    isSelectSec = true
                end
                self.leftListCtrl:removeItem(index + 1)
                ctrl.isExpand = false
            end

            if isSelectSec then
                local oneAndSecPanel = self:getOneEffectImgbySecond()
                self:setLabelText("BigLabel", ctrl.key, oneAndSecPanel)
                self:setLabelText("SLabel", self.curSelectName, oneAndSecPanel)

                ctrl:addChild(oneAndSecPanel)
            end

            self:setCtrlVisible("DownArrowImage", true, ctrl)
            self:setCtrlVisible("UpArrowImage", false, ctrl)
        end
    end
end

-- 获取当前ListView滚动百分比
function TeamAdjustmentDlg:getCurScrollPercent(listView)
    local height = listView:getInnerContainer():getSize().height
    local curPosX = listView:getInnerContainer():getPositionY()
    return curPosX / height * (-100)
end

-- 更新右侧信息
function TeamAdjustmentDlg:updateRightList(min, max)
    self.minList, self.minSize = self:resetListView("MinListView", self.rightMagin)
    self.maxList, self.maxSize = self:resetListView("MaxListView", self.rightMagin)
    local lastPercent
    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then
        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
        elseif eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.1)
            local func = cc.CallFunc:create(function()
                local selectSize1 = self:getControl("SelectedImage1"):getContentSize()
                local _, offY = sender:getInnerContainer():getPosition()
                local beforPercent = offY / (sender:getInnerContainer():getContentSize().height - sender:getContentSize().height) * -100

                -- 当前相对与原先位置移动了很少的位置
                if lastPercent and math.abs(beforPercent - lastPercent) < 0.1 then

                    -- 还原到原先的位置，并不进行接下来的操作
                    local lastPosition = lastPercent * (sender:getInnerContainer():getContentSize().height - sender:getContentSize().height) / -100
                    sender:getInnerContainer():setPositionY(lastPosition)
                    return
                end

                local value = TeamMgr:getMaxLevelActive(self.curSelectName) - math.floor(math.abs(offY) / selectSize1.height)
                offY = -((TeamMgr:getMaxLevelActive(self.curSelectName) - math.max(value, min)) * selectSize1.height)
                local percent = offY / (sender:getInnerContainer():getContentSize().height - sender:getContentSize().height) * -100
                lastPercent = percent

                if beforPercent ~= percent then
                    sender:scrollToPercentVertical(100 - percent, 0.5, false)
                end
            end)

            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end

    self.minList:addScrollViewEventListener(scrollListener)
    self.maxList:addScrollViewEventListener(scrollListener)

    local minListPosX, minListPosY = self.minList:getPosition()
    local selectImg = self:getControl("SelectedImage1")
    local selectPosX, selectPosY = selectImg:getPosition()
    local selectSize = selectImg:getContentSize()

    local lowHeight = selectPosY - minListPosY
    local hightHeight = self.minSize.height - selectSize.height - lowHeight

    local lowNum = math.ceil(lowHeight / selectSize.height)
    local hightNum = math.ceil(hightHeight / selectSize.height)

    -- 记录总共多少个控件
    local ctrlCount = 0
    for i = 1, hightNum do
        local label = self.label:clone()
        label:setString(" ")
        self.minList:pushBackCustomItem(label)
        label = self.label:clone()
        label:setString(" ")
        self.maxList:pushBackCustomItem(label)
        ctrlCount = ctrlCount + 1
    end

    for i = min, max do
        local item = minCtrlList[i - START_INDEX + 1]
        if not item then
            if i < 10 then
                item = self:createLevelItem("0" .. i)
            else
                item = self:createLevelItem("" .. i)
            end
        end

        self.minList:pushBackCustomItem(item)

        item = maxCtrlList[i - START_INDEX + 1]
        if not item then
            if i < 10 then
                item = self:createLevelItem("0" .. i)
            else
                item = self:createLevelItem("" .. i)
            end
        end

        self.maxList:pushBackCustomItem(item)
        ctrlCount = ctrlCount + 1
    end

    for i = 1, lowNum do
        local label = self.label:clone()
        label:setString(" ")
        self.minList:pushBackCustomItem(label)
        label = self.label:clone()
        label:setString(" ")
        self.maxList:pushBackCustomItem(label)
        ctrlCount = ctrlCount + 1
    end

    local level = Me:queryBasicInt("level")
    --
    local minOffY = -((TeamMgr:getMaxLevelActive(self.curSelectName) - math.max(level - 5, min)) * selectSize.height)
    local maxOffY = -((TeamMgr:getMaxLevelActive(self.curSelectName) - math.min(level + 5, max)) * selectSize.height)
    --]]
    --[[
    local minOffY = -((max - min - math.max(level - 5, min)) * selectSize.height)
    local maxOffY = -((max - min - math.min(level + 5, max)) * selectSize.height)
    --]]
    if self.curSelectName == CHS[3003726] then
        minOffY = -((TeamMgr:getMaxLevelActive(self.curSelectName) - 1) * selectSize.height)
        maxOffY = -((TeamMgr:getMaxLevelActive(self.curSelectName) - TeamMgr:getMaxLevelActive(self.curSelectName)) * selectSize.height)
    end
    --]]
    local func = cc.CallFunc:create(function()
        if self.minList == nil or self.maxList == nil then
            return
        end

        self.minList:getInnerContainer():setPositionY(minOffY)
        self.maxList:getInnerContainer():setPositionY(maxOffY)
        self.minList:requestRefreshView()
        self.maxList:requestRefreshView()
    end)

    self.blank:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), func))
end

function TeamAdjustmentDlg:onStartButton(sender, eventType)
    if nil == self.minList or nil == self.maxList then
        return
    end

    if not TeamMgr:isAllowActive(self.curSelectName) then
        gf:ShowSmallTips(CHS[3003730])
        return
    end

    -- 有老君发怒时不能匹配刷道活动
    if TaskMgr:isExistTaskByName(CHS[6000562]) then
        if self.curSelectName == CHS[6000563] or self.curSelectName == CHS[6000564] then
            gf:ShowSmallTips(CHS[6000561])
            return
        end
    end

    local _, minOffY = self.minList:getInnerContainer():getPosition()
    local minValue = TeamMgr:getMaxLevelActive(self.curSelectName) - math.floor(math.abs(minOffY) / self.label:getContentSize().height)

    local _, maxOffY = self.maxList:getInnerContainer():getPosition()
    local maxValue = TeamMgr:getMaxLevelActive(self.curSelectName) - math.floor(math.abs(maxOffY) / self.label:getContentSize().height)

    if minValue >= activeLevelMap[self.curSelectName].level or maxValue <= TeamMgr:getMaxLevelActive(self.curSelectName) then
        TeamMgr:requestMatchMember(self.curSelectName, minValue, maxValue)
        if self.curSelectName ~= CHS[5000167] then
            -- 镖行万里活动不能立即刷新组队界面活动信息，需要等服务器消息回来再刷新
            DlgMgr:sendMsg("TeamDlg", "setMatchInfo", self.curSelectName, minValue, maxValue)
        end
    end

    DlgMgr:closeDlg(self.name)
end

function TeamAdjustmentDlg:getActivityStr(data)
    local str = ""
    if "string" == type(data) then
        str = str .. CHS[5000148]
    else
        -- 周几
  --      str = str .. ActivityMgr:getDayText(data)

        -- 时间段
        str = ActivityMgr:getDuringTime(data)
    end

    return str
end

function TeamAdjustmentDlg:getLimitStr(level)
    -- 等级
    local str = string.format(CHS[5000144], level)

    return str
end

-- 选择左边菜单,不响应菜单回调
function TeamAdjustmentDlg:selectItem(oneItem, twoItem)
    self:operItem(oneItem, twoItem, true, true)
end

-- 选择左边菜单，响应回调
function TeamAdjustmentDlg:selectItemEx(oneItem, twoItem)
    -- 如果已经选中
    if self.curSelectName == twoItem then
    	return
    end

    self:operItem(oneItem, twoItem)
end

function TeamAdjustmentDlg:operItem(oneItem, twoItem, one, two)
    if twoItem == oneItem then twoItem = nil end
    local children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if oneItem == str then
            self:oneClick(child, nil, one)
        end
    end

    children = self.leftListCtrl:getChildren()

    -- 需要分开响应
    for k, child in pairs(children) do
        local str = child.key
        if twoItem == str then
            self:twoClick(child, nil, two)
        end
    end
end

function TeamAdjustmentDlg:scrollToItem(oneItem, twoItem)
    if twoItem == oneItem then twoItem = nil end
    local children = self.leftListCtrl:getChildren()

    local operItem = nil
    if twoItem then
        operItem = twoItem
    else
        operItem = oneItem
    end

    local operCtrl = nil
    for k, child in pairs(children) do
        local str = child.key
        if twoItem == str then
            operCtrl = child
        end
    end

    if nil == operCtrl then return end

    local index = self.leftListCtrl:getIndex(operCtrl)
    local height = operCtrl:getContentSize().height
    local listHeight = self.leftListCtrl:getContentSize().height

    if height * (index + 1) > listHeight then
        self.leftListCtrl:scrollToPercentVertical(height * (index + 1) / listHeight * 100, 0.5, false)
    end
end

function TeamAdjustmentDlg:selectItemInit(activeName)
    if not activeName then return end
    local oneName, twoName = self:getOneName(activeName)
    self:selectItemEx(oneName, twoName)
end

-- 根据二级菜单获取一级菜单
function TeamAdjustmentDlg:getOneName(twoName)
    for k, v in pairs(twoActiveAdjustListMap) do
        if k == twoName then return k, "" end
        for i = 1, #v do
            if v[i] == twoName then
                return k, twoName
            end
        end
    end
end
return TeamAdjustmentDlg
