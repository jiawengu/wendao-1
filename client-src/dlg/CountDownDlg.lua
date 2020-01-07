-- CountDownDlg.lua
-- Created by songcw Dec/2018/21
-- 通用倒计时界面

local CountDownDlg = Singleton("CountDownDlg", Dialog)

local NumImg = require('ctrl/NumImg')

function CountDownDlg:init()
    self:setFullScreen()

    self.cdType = nil
    self.callBack = nil
    self.para = nil
    self.nextCdType = nil
    self.nextCallBack = nil
    self.nextPara = nil

    -- 隐藏开始图片
    self:setCtrlVisible("StartImage", false)

    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('TimePanel')
    if timePanel then
        local sz = timePanel:getContentSize()

        self.numImg = timePanel:getChildByTag(999)
        if not self.numImg then
            self.numImg = NumImg.new('bfight_num', 5, false, -5)
        end

        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(true)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg, 999)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
    end
end

function CountDownDlg:setNextData(cdType, callBack, para, endTime)
    self.nextCdType = cdType
    self.nextCallBack = callBack
    self.nextPara = para
    self.nextEndTime = endTime

    if self.schId then
        -- 说明第一个倒计时已经结束，定时回调关闭开始了
        self.root:stopAction(self.schId)
        self.schId = nil
        self:setData(cdType,callBack,para)
        self:setNextData(nil, nil, nil, nil)
        local leftTime = endTime - gf:getServerTime()
        self:startCountDown(leftTime)
    end
end

function CountDownDlg:setData(cdType, callBack, para)
    self.cdType = cdType
    self.callBack = callBack
    self.para = para

    if para == "scale80" and self.numImg then        
        self.numImg:setScale(0.4)
    end
end

function CountDownDlg:resetCountDown(time)
    if not self.numImg then
        return
    end

    if self.cdType == "start" or self.cdType == "end" then
        time = time - 1 -- 最后一秒要显示   开始 or 结束
    else

    end

    self:setCtrlVisible("StartImage", false)
    self.numImg:setVisible(true)
    self.numImg:startCountDown()
end

-- 开始计时
function CountDownDlg:startCountDown(time)
    if not self.numImg then
        local timePanel = self:getControl('TimePanel')
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', 5, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(true)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg, 999)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
    end

    if self.schId then
        self.root:stopAction(self.schId)
        self.schId = nil
    end

    self.numImg:unscheduleUpdate()

    if self.cdType == "start" or self.cdType == "end" then
        time = time - 1 -- 最后一秒要显示   开始 or 结束
    else
    end

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("TimePanel", true)
    self:setCtrlVisible("StartImage", false)

    self.numImg:startCountDown(function()
        -- 时间到
        self.numImg:setVisible(false)
        local delayTime = 0
        if self.cdType == "start" then
            self:setImage("StartImage", ResMgr.ui.start_icon)
            self:setCtrlVisible("StartImage", true)
            delayTime = 1
        elseif self.cdType == "end" then
            self:setImage("StartImage", ResMgr.ui.end_icon)
            self:setCtrlVisible("StartImage", true)
            delayTime = 1
        else

        end

        if delayTime > 0 and self.nextEndTime then

            -- 第一个倒计时结束后，字样显示结束后，开启第二个倒计时
            self.schId2 = performWithDelay(self.root, function()
                if self.callBack and type(self.callBack) == "function" then
                    self.callBack(self.para)
                end

                local leftTime = self.nextEndTime - gf:getServerTime()
                self:setData(self.nextCdType, self.callBack, self.para)
                self:setNextData(nil, nil, nil, nil)
                self:startCountDown(leftTime)
            end, delayTime)
        else
            -- WDSY-33813 修改，强更后可去除延时
            self.schId = performWithDelay(self.root, function()
                if self.callBack and type(self.callBack) == "function" then
                    self.callBack(self.para)
                end

                self:onCloseButton()
            end, delayTime)
        end
    end)
end

function CountDownDlg:cleanup()
    if self.schId then
        self.root:stopAction(self.schId)
        self.schId = nil
    end

    if self.schId2 then
        self.root:stopAction(self.schId2)
        self.schId2 = nil
    end
end

return CountDownDlg
