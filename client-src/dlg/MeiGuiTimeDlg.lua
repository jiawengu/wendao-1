-- MeiGuiTimeDlg.lua
-- Created by songcw Oct/2018/13
-- 倒计时

local MeiGuiTimeDlg = Singleton("MeiGuiTimeDlg", Dialog)
local NumImg = require('ctrl/NumImg')

function MeiGuiTimeDlg:init(data)

    self:setFullScreen()

    self.obj = nil
    self.objPara = para

    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('TimePanel')
    if timePanel then
        local sz = timePanel:getContentSize()

        self.numImg = timePanel:getChildByTag(999)
        if not self.numImg then
            self.numImg = NumImg.new('bfight_num', 5, false, -5)

          --  self.numImg:setNum(time, false)
        end

        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg, 999)
     --   self.waitImg = self:getControl("WaitImage", Const.UIImage)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
   --     self.waitImg:setVisible(false)
    end

    local ti = data.end_time - gf:getServerTime()
    self:startCountDown(ti)
end


-- 回调对象
function MeiGuiTimeDlg:setObj(obj, para)
    self.obj = obj
    self.objPara = para
end

-- 开始计时
function MeiGuiTimeDlg:startCountDown(time)
    if not self.numImg then
        return
    end

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
 --   self.waitImg:setVisible(false)
    self:setCtrlVisible("TimePanel", true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)

        if self.obj and self.obj.cutDown then
            self.obj:cutDown(self.objPara)
        end

        -- WDSY-33813 修改，强更后可去除延时
        performWithDelay(self.root, function()
            self:onCloseButton()
        end, 0)
    end)
end
return MeiGuiTimeDlg
