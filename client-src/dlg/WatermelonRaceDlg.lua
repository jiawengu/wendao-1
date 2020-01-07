-- WatermelonRaceDlg.lua
-- Created by huangzz Apr/16/2018
-- 暑假-谁能吃瓜 赛跑界面

local WatermelonRaceDlg = Singleton("WatermelonRaceDlg", Dialog)
local NumImg = require('ctrl/NumImg')

local row  -- 每行最多放几个加速图标
local col  -- 每列最多放几个加速图标
local total -- 主界面最多放置对多少个图标

local EDGE_DIS = 15 -- 加速图标距屏幕边缘 15像素
local SPEED_IMG_EDGE = 100  -- 加速度图标占用宽高

local MAX_SCALE = 2.2 -- 加速光效最大缩放

local DEFAULT_TIME_MAX = 3

function WatermelonRaceDlg:init(para)
    self:setFullScreen()

    self:bindListener("TouchButton", self.onTouchButton)

    -- 设置点击层的大小
    self:setCtrlFullClientEx("TouchPanelGroup")

    local winSize = self:getWinSize()
    local realHeight = winSize.height / Const.UI_SCALE
    local realWidth = winSize.width / Const.UI_SCALE
    row = math.floor((realHeight - EDGE_DIS * 2) / SPEED_IMG_EDGE)
    col = math.floor((realWidth - EDGE_DIS * 2) / SPEED_IMG_EDGE)
    total = row * col

    self.imgQue = {}

    if para and para.start_time then
        self:addTimeImage()
        self:startCountDown(para.start_time - gf:getServerTime())
    end

    self.speedImgs = {}
    self.speedImg = self:retainCtrl("TouchButton")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, {[self.name] = 1, ["LoadingDlg"] = 1})
end

function WatermelonRaceDlg:onTouchButton(sender)
    local data = sender.data
    if data then
        local magic = sender:getChildByTag(100)
        if magic then
            local rate = math.floor(((magic:getScale() - 1) / (MAX_SCALE - 1)) * 100) + 100
            if rate > 100 then
                SummerSncgMgr:cmdAccelerate(data.seq, data.pos, rate)
            end

            sender:removeFromParent()
            self.speedImgs[sender.w] = nil
        end
    end
end

function WatermelonRaceDlg:addTimeImage()
    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('NumPanel', nil, "TimePanel")
    if timePanel and not timePanel:getChildByName("numImg") then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', DEFAULT_TIME_MAX, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setName("numImg")
        timePanel:addChild(self.numImg, 100, 10)
    end
end

-- 开始计时
function WatermelonRaceDlg:startCountDown(time)
    if not self.numImg then
        return
    end

    if time <= 0 then
        self:setCtrlVisible("TimePanel", false)
        return
    end

    time = math.min(time, DEFAULT_TIME_MAX)

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("TimePanel", true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)
    end)
end

-- 移除该帧前的所有加速图标
function WatermelonRaceDlg:setCurSeq(seq)
    -- 移除所有在该帧前结束的帧
    for w, v in pairs(self.speedImgs) do
        if v and v.data and v.data.end_seq < seq then
            -- 加 1 放宽移除时间，此处为异常情况的移除，靠 setImgMagic 正常移除
            self.speedImgs[w]:removeFromParent()
            self.speedImgs[w] = nil
        end
    end
end

function WatermelonRaceDlg:addSpendImg(data)
    local curSeq = SummerSncgMgr:getCurFrameNum() or 0
    if curSeq < data.seq then
        -- 跑的帧数延后了两帧，而加速光效未延后，重新计算相对于奔跑帧数的开始帧和结束帧
        data.real_seq = curSeq
        data.end_seq = data.end_seq - (data.seq - curSeq)
    end

    if curSeq < data.end_seq then
        self:showSpendImg(data)
    end
end

function WatermelonRaceDlg:showSpendImg(data)
    local w = data.pos % total
    w = math.max(1, w)

    if self.speedImgs[w] then
        -- 该位置已有图标，找新的位置
        local newW = w
        repeat
            if self.speedImgs[newW] and self.speedImgs[newW].data.seq == data.seq then
                -- 该加速图标已添加过
                return
            end

            newW = newW % total + 1
            if not self.speedImgs[newW] then
                break
            end

            if newW == w then
                -- 没有位置可放、容错
                return
            end
        until false

        w = newW
    end

    local wx = w % col
    local wy = math.ceil(w / col)

    if wx == 0 then wx = col end

    local x = wx * SPEED_IMG_EDGE - SPEED_IMG_EDGE / 2 + EDGE_DIS
    local y = wy * SPEED_IMG_EDGE - SPEED_IMG_EDGE / 2 + EDGE_DIS

    local img = self.speedImg:clone()
    img:setPosition(x, y)

    self:setImgMagic(img, data, w)

    self:getControl("SpeedPanel"):addChild(img)

    img.data = data
    img.w = w
    self.speedImgs[w] = img
end

-- 添加光圈
function WatermelonRaceDlg:setImgMagic(img, data, w)
    local curSeq = data.real_seq or data.seq

    local size = img:getContentSize()
    local magic = cc.Sprite:create(ResMgr.ui.sncg_speed_circle)
    local time = (data.end_seq - curSeq) * SummerSncgMgr:getFrameInterval() / 1000

    magic:setScale(MAX_SCALE)
    local action = cc.Sequence:create(
        cc.Spawn:create(cc.ScaleTo:create(time, 1), cc.FadeOut:create(time)),
        cc.CallFunc:create(function()
            img:removeFromParent()
            self.speedImgs[w] = nil
        end)
    )

    magic:setBlendFunc(gl.ONE, gl.ONE)
    magic:setPosition(size.width / 2, size.height / 2)
    magic:setAnchorPoint(0.5, 0.5)
    magic:runAction(action)
    img:addChild(magic, 0, 100)
end

function WatermelonRaceDlg:cleanup()
    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    SummerSncgMgr:stopRunGame()
end

return WatermelonRaceDlg
