-- ArtifactAddDlg.lua
-- Created by songcw 
-- 紫气兑换炼器灵气

local ArtifactAddDlg = Singleton("ArtifactAddDlg", Dialog)
local TOUCH_BEGAN  = 1
local TOUCH_END     = 2

function ArtifactAddDlg:init(data)
    self:bindListener("SliderButton", self.onSliderButton)
    self:blindPress("AddButton")
    self:blindPress("ReduceButton")
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    self:setLabelText("NumberLabel", GetTaoMgr:getAllZiQiHongMengPoint())
    
    self:setLabelText("ReduceLabel", "")
 
    self.furnitureId = data.furnitureId
    self.furnitureX, self.furnitureY = data.pX, data.pY
    
    self:bindSliderListener("AddSlider", function(self, sender, type)
        if type == ccui.SliderEventType.percentChanged then            
            self.isUpdateSlider = true
        end
            
    end)
    
    self.isUpdateSlider = false
    self.sliderFloat = self:getControl("SliderBKImage")
    self.sliderFloatX = self.sliderFloatX or self.sliderFloat:getPositionX()
    --[[
    self.sliderBtn = self:getControl("SliderButton")
    self:setCtrlVisible("BKImage", false, self.sliderBtn)
    self.sliderButtonX = self.sliderBtn:getPositionX()
    
    self:bindDragListener(self.sliderBtn, function (x, y)
        if not self.data then return end
        local posX, posY = self.sliderBtn:getPosition()
        local destX = posX + x

        local barSize = self:getControl("ProgressBar"):getContentSize()
        if destX < self.sliderButtonX then
            self.cur = self.data.nimbus
            
        elseif destX > self.sliderButtonX + barSize.width then
            self.cur = self.data.max_nimbus
            self:setCtrlEnabled("AddButton", false)
        elseif destX > self.sliderButtonX + math.floor(GetTaoMgr:getAllZiQiHongMengPoint() / self.data.max_nimbus * barSize.width) then
            self.cur = GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus
            gf:ShowSmallTips(CHS[4100673]) -- "当前紫气鸿蒙点数已不足，无法继续补充。"
        else
            self.cur = math.floor((destX - self.sliderButtonX) / barSize.width * self.data.max_nimbus)
        end

        self:updataProgressBat()
    end)--]]
end


function ArtifactAddDlg:bindDragListener(widget, func, click)
    if type(widget) ~= "userdata" then
        return
    end

    if not widget then
        Log:W("Dialog:ScreenRecordingDlg no control " .. self.name)
        return
    end
    
    local lastTouchPos
    local isMoving = false
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            lastTouchPos = GameMgr.curTouchPos
            isMoving = false
        elseif eventType == ccui.TouchEventType.ended then

        elseif eventType == ccui.TouchEventType.moved then
            local touchPos = GameMgr.curTouchPos
            local offsetX, offsetY = touchPos.x - lastTouchPos.x, touchPos.y - lastTouchPos.y 
            if func and (math.abs(offsetX) > 5 or math.abs(offsetY) > 5) then func(offsetX, offsetY) isMoving = true end
            lastTouchPos = touchPos
        end
    end

    widget:addTouchEventListener(listener)
end

function ArtifactAddDlg:blindPress(name)
    local widget = self:getControl(name)

    if not widget then
        Log:W("Dialog:bindListViewListener no control " .. name)
        return
    end

    local function updataCount()
        if self.touchStatus == TOUCH_BEGAN  then
            if self.clickBtn == "AddButton" then
                self:onAddButton()
            elseif self.clickBtn == "ReduceButton" then
                self:onReduceButton()
            end
        elseif self.touchStatus == TOUCH_END then

        end
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            self.clickBtn = sender:getName()
            self.touchStatus = TOUCH_BEGAN
            schedule(widget , updataCount, 0.1)
        elseif eventType == ccui.TouchEventType.moved then
        else
            updataCount()
            self.touchStatus = TOUCH_END
            widget:stopAllActions()
        end
    end

    widget:addTouchEventListener(listener)
end

function ArtifactAddDlg:onUpdate()
    if self.isUpdateSlider then
        self.isUpdateSlider = false
        self:onSliderChange()
    end
end

-- 获取可分配的点数最大值
function ArtifactAddDlg:getMaxPoint()
    local num1 = GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus
    local num2 = self.data.max_nimbus
    
    return math.min(num1, num2)
end

function ArtifactAddDlg:onSliderChange()
    if not self.data then return end
    
    local slider = self:getControl("AddSlider")

    local totalNum = self:getMaxPoint()
    local percent = slider:getPercent()


    if percent * 0.01 * self.data.max_nimbus >= GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus then
        self.cur = GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus
    elseif percent * 0.01 * self.data.max_nimbus <= self.data.nimbus then
        self.cur = self.data.nimbus
    else
        self.cur = math.ceil(percent * 0.01 * self.data.max_nimbus)
    end
    self:updataProgressBat()
--[[

    elseif self.cur > self.data.max_nimbus then
        self.cur = self.data.max_nimbus
        self:setCtrlEnabled("AddButton", false)
    elseif self.cur > GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus then

--]]

end


function ArtifactAddDlg:setData(data, id)
    self.cur = data.nimbus
    self.data = data
    self:updataProgressBat()
end


function ArtifactAddDlg:onReduceButton(sender, eventType)
    self.cur = self.cur - 1
    self:updataProgressBat()
end

function ArtifactAddDlg:onAddButton(sender, eventType)
    self.cur = self.cur + 1
    self:updataProgressBat()
end

function ArtifactAddDlg:updataProgressBat()
    self:setCtrlEnabled("AddButton", true)
    self:setCtrlEnabled("ReduceButton", true)
    
    if self.cur > GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus then
        self.cur = GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus
        gf:ShowSmallTips(CHS[4100673])  -- 当前紫气鸿蒙点数已不足，无法继续补充。
    end
    
    if self.cur == GetTaoMgr:getAllZiQiHongMengPoint() + self.data.nimbus then
        self:setCtrlEnabled("AddButton", false)
    end
    
    if self.cur >= self.data.max_nimbus then
        self.cur = self.data.max_nimbus
        self:setCtrlEnabled("AddButton", false)
    end
    
    if self.cur <= self.data.nimbus then
        self.cur = self.data.nimbus
        self:setCtrlEnabled("ReduceButton", false)
    end
    
    self:setProgressBar("ProgressBar", self.cur, self.data.max_nimbus)
    self:setLabelText("NumberLabel", string.format("%d/%d", self.cur, self.data.max_nimbus), "AttribPanel")
    
    
    if self.cur - self.data.nimbus ~= 0 then
        self:setLabelText("ReduceLabel", string.format("-%d", self.cur - self.data.nimbus))
        self:setLabelText("AddLabel", string.format("+%d", self.cur - self.data.nimbus))
        self:setCtrlVisible("SliderBKImage", true)
    else
        self:setCtrlVisible("SliderBKImage", false)
        self:setLabelText("AddLabel", "")
        self:setLabelText("ReduceLabel", "")
    end
    
    local slider = self:getControl("AddSlider")
    slider:setPercent(self.cur / self.data.max_nimbus * 100)
    
    
    local dis = self.cur / self.data.max_nimbus * self:getControl("AddSlider"):getContentSize().width
    self.sliderFloat:setPositionX(self.sliderFloatX + dis)
    
    --[[
    local barSize = self:getControl("ProgressBar"):getContentSize()
    local disX = math.floor(self.cur / self.data.max_nimbus * barSize.width)
    self:getControl("SliderButton"):setPositionX(self.sliderButtonX + disX)
    
    
    if self.cur - self.data.nimbus ~= 0 then
        self:setLabelText("ReduceLabel", string.format("-%d", self.cur - self.data.nimbus))
        self:setLabelText("AddLabel", string.format("+%d", self.cur - self.data.nimbus))
        self:setCtrlVisible("BKImage", true, self.sliderBtn)
    else
        self:setCtrlVisible("BKImage", false, self.sliderBtn)
        self:setLabelText("AddLabel", "")
        self:setLabelText("ReduceLabel", "")
    end
    self:updateLayout("AttribPanel")
    --]]
end


function ArtifactAddDlg:onConfirmButton(sender, eventType)
    local number = self.cur - self.data.nimbus
    if number <= 0 then
        gf:ShowSmallTips(CHS[4200432])
        return
    end
    
    local furn = HomeMgr:getFurnitureById(self.furnitureId)
    -- 目标家具已消失
    if not furn then
        gf:ShowSmallTips(CHS[5410041])
        ChatMgr:sendMiscMsg(CHS[5410041])
        self:onCloseButton()
        return
    end

    -- 对应家具位置已发生改变
    if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        self:onCloseButton()
        return
    end
    
    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "add_nimbus_by_zqhm", number)
    self:onCloseButton()
end

return ArtifactAddDlg
