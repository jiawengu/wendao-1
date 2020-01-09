-- SmallAttrTip.lua
-- Created by liuhb Jun/23/2015
-- 显示角色属性变化的悬浮提示框

local List = require "core/List"
local NumImg = require "ctrl/NumImg"
local SmallAttrTip = class("SmallAttrTip", function()
    return ccui.Layout:create()
end)

local OFFSET_Y = 120
local SHOW_OFFSET_Y = -50
local DELAY_TIME = 0.2
local numSize = {width = 25, height = 25}

local ADD_ATTR_IMG = {
    [CHS[3002180]] = "Label0004.png",  -- 物伤
    [CHS[3002181]] = "Label0002.png",  -- 法伤
    [CHS[3002182]] = "Label0003.png",  -- 速度
    [CHS[3002183]] = "Label0001.png",  -- 防御
    [CHS[3002422]] = "Label0011.png",  -- 气血
    [CHS[3002423]] = "Label0009.png",  -- 法力
}

local REDUCE_ATTR_IMG = {
    [CHS[3002180]] = "Label0008.png",  -- 物伤
    [CHS[3002181]] = "Label0006.png",  -- 法伤
    [CHS[3002182]] = "Label0007.png",  -- 速度
    [CHS[3002183]] = "Label0005.png",  -- 防御
    [CHS[3002422]] = "Label0012.png",  -- 气血
    [CHS[3002423]] = "Label0010.png",  -- 法力
}

--疲劳度(fatigue)，饱食度(satiation)，心情度(mood)，清洁度(cleanliness)
local SPECIAL_ATTRI_IMG = {
    ["fatigue"] = {res = "ui/Icon2515.png", valueRes = "red_29"},
    ["satiation"] = {res = "ui/Icon2513.png", valueRes = "green_29"},
    ["mood"] = {res = "ui/Icon2514.png", valueRes = "green_29"},
    ["cleanliness"] = {res = "ui/Icon2512.png", valueRes = "green_29"},
    ["health"] = {res = "ui/Icon2517.png", valueRes = "green_29"},
}

function SmallAttrTip:create()
    local root = gf:getUILayer():getChildByTag(Const.TAG_ATTR_TIP)
    if not root then
        self.root = cc.Layer:create()
        self.root:setLocalZOrder(Const.ZORDER_SMALLTIP - 1)
        self.root:setTag(Const.TAG_ATTR_TIP)
        gf:getUILayer():addChild(self.root)
        self.root:setContentSize({width = Const.WINSIZE.width / Const.UI_SCALE / 2, height = Const.WINSIZE.height / Const.UI_SCALE / 2})
        self.root.list = List.new()
        self.root.allow = true
    else
        self.root = root
    end

    return self
end

-- 清理工作
function SmallAttrTip:cleanup()
    self.root.allow = true
end

-- 添加一条提示
function SmallAttrTip:addTip(data)
    if nil == data then return end
    if nil == self.root.list then return end

    self.root.list:pushBack(data)

    if self.root.allow then
        self:doAction()
    end
end

-- 执行动作
function SmallAttrTip:doAction()
    if 0 >= self.root.list:size() then
        self.root:removeFromParent(true)
        return
    end

    self.root.allow = false
    local tipData = self.root.list:popFront()
    local tipCtrl = self:generateTip(tipData)
    if nil == tipCtrl then return self:doAction() end

    local endPos = cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2 + OFFSET_Y)
    local startPos = cc.p(Const.WINSIZE.width / Const.UI_SCALE / 2, Const.WINSIZE.height / Const.UI_SCALE / 2 - SHOW_OFFSET_Y)
    tipCtrl:setPosition(startPos)
    self.root:addChild(tipCtrl)

    local actMoveTo = cc.MoveTo:create(DELAY_TIME, endPos)
    local func = cc.CallFunc:create(function()
        self.root.allow = true
        self:doAction()
        tipCtrl:removeFromParent(true)
    end)

    tipCtrl:runAction(cc.Sequence:create(actMoveTo, cc.DelayTime:create(0.2), func))
end

function SmallAttrTip:generateTip(data)
    if nil == data then return end
    if nil == data.attrStr then return end
    if nil == data.value or 0 == data.value then return end

    local numCount = 1
    local num = data.value
    num = math.abs(num)
    while num > 0 do
        num = math.floor(num / 10)
        numCount = numCount + 1
    end

    local file = ResMgr:getAttrWordsPlistPath()
    gfAddFrames(file .. ".plist", file .. "/")

    -- 生成颜色字符串控件
    local label
    local pngFile = ""

    if SPECIAL_ATTRI_IMG[data.attrStr] then
        pngFile = SPECIAL_ATTRI_IMG[data.attrStr].valueRes
        --label = cc.Sprite:createWithSpriteFrameName(SPECIAL_ATTRI_IMG[data.attrStr].res)
        label = cc.Sprite:create(SPECIAL_ATTRI_IMG[data.attrStr].res)
    else
        if data.value >= 0 then
            pngFile = "green_29"
            label = cc.Sprite:createWithSpriteFrameName(ResMgr:getAttrWordsPlistPath() .. "/" .. ADD_ATTR_IMG[data.attrStr])
        else
            pngFile = "red_29"
            label = cc.Sprite:createWithSpriteFrameName(ResMgr:getAttrWordsPlistPath() .. "/" .. REDUCE_ATTR_IMG[data.attrStr])
        end
    end

    local numLabel = NumImg.new(pngFile, data.value, true)

    local layer = cc.Layer:create()
    layer:addChild(label)
    layer:addChild(numLabel)

    local labelContentSize = label:getContentSize()
    local numLabelContentSize = numLabel:getContentSize()

    -- 计算新的contentSize
    local width = labelContentSize.width + numCount * numSize.width
    local height = math.max(labelContentSize.height, numLabelContentSize.height)
    local newContentSize = cc.size(width, height)

    label:setAnchorPoint(0, 0)
    label:setPosition(0, 0)

    numLabel:setAnchorPoint(0.5, 0.5)
    numLabel:setPosition(labelContentSize.width + numCount * numSize.width / 2, height / 2)
    layer:setContentSize(newContentSize)
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0.5)

    return layer
end

return SmallAttrTip
