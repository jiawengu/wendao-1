-- MapGuardianDlg.lua
-- Created by zhengjh Jan/21/2016
-- 地图守护神

local MapGuardianDlg = Singleton("MapGuardianDlg", Dialog)
local mapInfo =
{
    {name = CHS[3002923], minLevel = 45, maxLevel = 55},
    {name = CHS[3002924], minLevel = 45, maxLevel = 56},
    {name = CHS[3002925], minLevel = 45, maxLevel = 58},
    {name = CHS[3002926], minLevel = 48, maxLevel = 62},
    {name = CHS[3002927], minLevel = 53, maxLevel = 67},
    {name = CHS[3002928], minLevel = 56, maxLevel = 70},
    {name = CHS[3002929], minLevel = 59, maxLevel = 73},
    {name = CHS[3002930], minLevel = 62, maxLevel = 76},
    {name = CHS[3002931], minLevel = 65, maxLevel = 79},
    {name = CHS[3002932], minLevel = 68, maxLevel = 82},
    {name = CHS[3002933], minLevel = 71, maxLevel = 85},
    {name = CHS[4100244], minLevel = 73, maxLevel = 87},
    {name = CHS[4100245], minLevel = 73, maxLevel = 87},
    {name = CHS[4100246], minLevel = 78, maxLevel = 92},
    {name = CHS[4100247], minLevel = 83, maxLevel = 97},
    {name = CHS[4100248], minLevel = 88, maxLevel = 102},
    {name = CHS[4100249], minLevel = 93, maxLevel = 107},
    {name = CHS[4100250], minLevel = 97, maxLevel = 112}, 
    {name = CHS[7002263], minLevel = 102, maxLevel = 117},
    {name = CHS[7002264], minLevel = 107, maxLevel = 122},
    {name = CHS[7002265], minLevel = 112, maxLevel = 127},
    {name = CHS[7190107], minLevel = 117, maxLevel = 132},
}

function MapGuardianDlg:init()
    self.cell = self:retainCtrl("SalaryPanel")
    self.mapInfo = mapInfo
    self.firstRecommendIndex = 0 -- 第一个推荐的索引 
    self:initListView()
end

function MapGuardianDlg:initListView()
    local listView = self:getControl("ListView")
    for i = 1, #self.mapInfo do
        local cell = self.cell:clone()
        self:setCellInfo(self.mapInfo[i], cell, i)
        listView:pushBackCustomItem(cell)
    end
    
    performWithDelay(self.root,function ()
        if self.firstRecommendIndex == 0 then return end
        self:setPisitionByIndex(self.firstRecommendIndex - 1)
    end, 0)
end

function MapGuardianDlg:setPisitionByIndex(index)
    local list = self:getControl("ListView")    
    local items = list:getItems()
    local margin = list:getItemsMargin()
    local realInnerSizeHeight = #items * self.cell:getContentSize().height + (#items - 1) * margin
    local height = list:getContentSize().height - realInnerSizeHeight
    local y = height + index * self.cell:getContentSize().height + index * margin
    if y >= 0 then y = 0 end
    list:getInnerContainer():setPositionY(y)
end

function MapGuardianDlg:setCellInfo(data, cell, index)
    -- 地图名
    self:setLabelText("MapNameLabel", data.name, cell)
    
    -- 挑战等级
    self:setLabelText("LevelLabel", string.format(CHS[3002934], data.minLevel, data.maxLevel), cell)
    
    -- 显示推荐图片
    if self:isRecommend(data) then
        self:setCtrlVisible("RecommendImage", true, cell)
        
        -- 记录第一个推荐的位置
        if self.firstRecommendIndex == 0 then self.firstRecommendIndex = index end
    else
        self:setCtrlVisible("RecommendImage", false, cell)
    end
    
    -- 前往按钮
    local gotoBtn = self:getControl("GoButton", Const.UIButton, cell)
    
    local function gotoFunc(sender, type)
        if ccui.TouchEventType.ended == type then            
            -- 如果地图守护神挑战次数用完，则给出提示
            local activityDataList = ActivityMgr:getDailyActivity()
            local activityData = nil
            for i = 1, #activityDataList do
                if activityDataList[i].name == CHS[3000310] then
                    activityData = activityDataList[i]
                    break
                end
            end

            if activityData and ActivityMgr:isFinishActivity(activityData) then
                gf:ShowSmallTips(CHS[7000020])
                return
            end

            local decStr = string.format(CHS[3002935], data.name)
            AutoWalkMgr:beginAutoWalk(gf:findDest(decStr))
            DlgMgr:closeDlg(self.name)
            DlgMgr:closeDlg("ActivitiesDlg")
        end
    end

    gotoBtn:addTouchEventListener(gotoFunc)
end

function MapGuardianDlg:isRecommend(data)
    local myLevel = Me:queryBasicInt("level")
    
    if myLevel >= data.minLevel and myLevel <= data.maxLevel then
        return true
    else
        return false    
    end
end

return MapGuardianDlg
