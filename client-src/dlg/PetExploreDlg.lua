-- PetExploreDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索界面

local PetExploreDlg = Singleton("PetExploreDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

-- 难度中文
local DEGREE_CHS = PetExploreTeamMgr:getExploreDegreeCfg()

-- 探索状态
local EXPLORE_STATUS = PetExploreTeamMgr:getExploreStatusCfg()

-- 操作探索状态
local EXPLORE_STATUS_OPER = PetExploreTeamMgr:getExploreOperCfg()

function PetExploreDlg:init()
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindFloatPanelListener("RulePanel")

    self:bindListener("RefreshButton", self.onRefreshButton)

    self.leftPanel = self:getControl("LeftPanel")
    self.rightPanel = self:getControl("RightPanel")
    self.topPanel = self:getControl("TopPanel", nil, self.rightPanel)

    self:getControl("MapPanel1", nil, self.rightPanel):setVisible(false)
    self:getControl("MapPanel2", nil, self.rightPanel):setVisible(false)
    self:getControl("MapPanel3", nil, self.rightPanel):setVisible(false)
    self:bindListener("MapPanel1", self.onSelectMap, self.rightPanel)
    self:bindListener("MapPanel2", self.onSelectMap, self.rightPanel)
    self:bindListener("MapPanel3", self.onSelectMap, self.rightPanel)

    self:refreshBasicData()
    self:refreshAllMapData()
end

-- 刷新基础数据
function PetExploreDlg:refreshBasicData(data)
    self.basicData = data
    if not self.basicData then self.basicData = PetExploreTeamMgr:getBasicData() end
    if not self.basicData then return end

    -- 探索次数
    self:setLabelText("Label2", string.format(CHS[7190536], self.basicData.explore_time), self.topPanel)

    -- 刷新次数
    local refreshCountColor = COLOR3.GREEN
    if self.basicData.map_refresh_count <= 0 then
        refreshCountColor = COLOR3.RED
    end

    self:setLabelText("RefreshTimesLabel", self.basicData.map_refresh_count, self.rightPanel, refreshCountColor)

    -- 刷新花费
    local costMoney = 100 + (4 - self.basicData.map_refresh_count) * 50
    local silverText = gf:getArtFontMoneyDesc(costMoney)
    self:setNumImgForPanel("CostPanel", ART_FONT_COLOR.DEFAULT, silverText, false, LOCATE_POSITION.MID, 23, self.rightPanel)
end

function PetExploreDlg:refreshAllMapData()
    local allMapData = PetExploreTeamMgr:getAllMapData()
    if not allMapData then return end

    for k, v in pairs(allMapData) do
        self:refreshMapData(v)
    end
end

function PetExploreDlg:refreshMapData(data)
    self:refreshRightPanel(data)

    if (not self.curMapInfo and data.status ~= EXPLORE_STATUS.OVER)
        or (self.curMapInfo and data.map_index == self.curMapInfo.map_index) then
        -- 当前未选中任何地图，且data对应地图信息为非探索完成状态，则选中
        self.curMapInfo = data

        local panelName = self:getMapDataPanelName(self.curMapInfo.map_index)
        local panel = self:getControl(panelName, nil, self.rightPanel)

        if not panel then return end

        self:onSelectMap(panel,eventType)
    end
end

function PetExploreDlg:refreshRightPanel(data)
    local panelName = self:getMapDataPanelName(data.map_index)
    if not panelName then return end

    self.mapData[data.map_index] = data

    local root = self:getControl(panelName, nil, self.rightPanel)
    root.mapInfo = data
    root:setVisible(true)
    self:bindListener("BeginButton", self.onBeginButton, root)
    self:bindListener("StopButton", self.onStopButton, root)
    self:bindListener("GetButton", self.onGetButton, root)

    -- 难度
    self:setLabelText("LevelLabel", DEGREE_CHS[data.degree], root)

    -- 地图名称
    self:setLabelText("MapNameLabel", data.map_name, root)

    -- 探索时间
    self:setLabelText("TimeLabel", string.format(CHS[7190540], math.floor(data.need_ti / 3600)), root)

    -- 探索状态
    self:setCtrlVisible("BeginButton", false, root)
    self:setCtrlVisible("FinishedImage", false, root)
    self:setCtrlVisible("StopButton", false, root)
    self:setCtrlVisible("GetButton", false, root)
    self:setCtrlVisible("SurplusLabel", false, root)
    self:getControl("SurplusLabel", nil, root):stopAllActions()
    if data.status == EXPLORE_STATUS.NOT_START then
        -- 未探索
        self:setCtrlVisible("BeginButton", true, root)
    elseif data.status == EXPLORE_STATUS.IN_EXPLORE then
        if self:isExploreFinished(data) then
            -- 探索完成
            self:setCtrlVisible("GetButton", true, root)
        else
            -- 探索中
            self:setCtrlVisible("SurplusLabel", true, root)
            self:setCtrlVisible("StopButton", true, root)

            local label = self:getControl("SurplusLabel", nil, root)
            local str, leftTime = self:getLeftTimeStr(data)
            label:setString(str)
            schedule(label, function()
                str, leftTime = self:getLeftTimeStr(data)
                label:setString(str)
                if leftTime <= 0 then
                    self:getControl("SurplusLabel", nil, root):stopAllActions()
                    self:refreshRightPanel(data)
                end
            end, 1)
        end
    elseif data.status == EXPLORE_STATUS.OVER then
        -- 已探索
        self:setCtrlVisible("FinishedImage", true, root)
    end
end

-- 是否为探索完成状态
function PetExploreDlg:getLeftTimeStr(data)
    local leftTime = data.start_time + data.need_ti - gf:getServerTime()
    if leftTime > 3600 then
        return string.format(CHS[7190541], math.ceil(leftTime / 3600)), leftTime
    else
        if leftTime >= 0 then
            local minute = math.ceil(leftTime / 60)
            if minute == 60 then
                return string.format(CHS[7190541], 1), leftTime
            else
                if leftTime < 60 then
                    -- 小于60s时，显示具体秒数
                    return string.format(CHS[7120169], leftTime), leftTime
                else
                    return string.format(CHS[7190542], minute), leftTime
                end
            end
        else
            return string.format(CHS[7190541], 0), 0
        end
    end
end

-- 是否为探索完成状态
function PetExploreDlg:isExploreFinished(data)
    if data.status == EXPLORE_STATUS.IN_EXPLORE
        and data.start_time + data.need_ti < gf:getServerTime() then
        return true
    end
end

-- 获取mapIndex对应的控件名
function PetExploreDlg:getMapDataPanelName(mapIndex)
    if not self.mapData then self.mapData = {} end
    if not self.mapData[1] or self.mapData[1].map_index == mapIndex then return "MapPanel1" end
    if not self.mapData[2] or self.mapData[2].map_index == mapIndex then return "MapPanel2" end
    if not self.mapData[3] or self.mapData[3].map_index == mapIndex then return "MapPanel3" end
end

function PetExploreDlg:refreshLeftPanel(data)
    -- 地图名称
    self:setLabelText("MapNameLabel", data.map_name, self.leftPanel)

    -- 小地图背景
    self:setImage("MapImage", ResMgr:getSmallMapFile(data.map_icon), self.leftPanel)

    -- 奖励
    local rewardPanel = self:getControl("ItemRewardPanel", nil, self.leftPanel)
    rewardPanel:removeAllChildren()
    local rewardContainer = RewardContainer.new(data.bonus_desc, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)
end

function PetExploreDlg:cleanup()
    self.curMapInfo = nil
    self.basicData = nil
    self.mapData = nil
end

function PetExploreDlg:onSelectMap(sender, eventType)
    local mapInfo = sender.mapInfo
    if not mapInfo then return end

    for i = 1, 3 do
        self:setCtrlVisible("SelectEffect", false, "MapPanel" .. i)
    end

    self:setCtrlVisible("SelectEffect", true, sender)

    self.curMapInfo = mapInfo
    self:refreshLeftPanel(mapInfo)
end

function PetExploreDlg:onBeginButton(sender, eventType)
    local mapInfo = sender:getParent().mapInfo
    if not mapInfo then return end

    if not self.basicData or self.basicData.explore_time <= 0 then
        gf:ShowSmallTips(CHS[7190543])
        return
    end

    PetExploreTeamMgr:requestMapPetData(mapInfo.cookie, mapInfo.map_index)
end

function PetExploreDlg:onStopButton(sender, eventType)
    local mapInfo = sender:getParent().mapInfo
    if not mapInfo then return end

    PetExploreTeamMgr:requestMapPetData(mapInfo.cookie, mapInfo.map_index)
end

function PetExploreDlg:onGetButton(sender, eventType)
    local mapInfo = sender:getParent().mapInfo
    if not mapInfo then return end

    if Me:isInJail() then
        gf:ShowSmallTips(CHS[7190545])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[7190546])
        return
    end

    PetExploreTeamMgr:requestExploreOper(mapInfo.cookie, EXPLORE_STATUS_OPER.REWARD, mapInfo.map_index)
end

function PetExploreDlg:onRefreshButton(sender, eventType)
    if not self.basicData or self.basicData.map_refresh_count <= 0 then
        gf:ShowSmallTips(CHS[7190548])
        return
    end

    if not self.basicData or self.basicData.explore_time <= 0 then
        gf:ShowSmallTips(CHS[7190549])
        return
    end

    if not self.curMapInfo then
        gf:ShowSmallTips(CHS[7190550])
        return
    end

    if self.curMapInfo and self.curMapInfo.status ~= EXPLORE_STATUS.NOT_START then
        gf:ShowSmallTips(CHS[7190551])
        return
    end

    if self:checkSafeLockRelease("onRefreshButton") then
        return
    end

    PetExploreTeamMgr:requestExploreOper(self.curMapInfo.cookie, EXPLORE_STATUS_OPER.REFRESH, self.curMapInfo.map_index)
end

function PetExploreDlg:onRuleButton(sender, eventType)
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(not rulePanel:isVisible())
end

return PetExploreDlg
