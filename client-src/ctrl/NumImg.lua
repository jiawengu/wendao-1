-- NumImg.lua
-- Created by chenyq Dec/2/2014
-- 数字图片控件，提供显示数字图片、倒计时、移动图片等功能

-- 正负号对应的文件名
local MINUS_KEY = 10
local PLUS_KEY = 11

local NOT_NUM =
{
    ["*"] = 13,
    [","] = 12,
    ["/"] = 14,
    ["$"] = 15,
    ["-"] = 10,
    ["."] = 16,
    [":"] = 17,
    -- 2018-03-10 ,当前只有 ART_FONT_COLOR.DEFAULT 的数字资源支持 ()
    ["("] = 18,
    [")"] = 19,
    ["%"] = 20,
}

local KEY_SUFFIX = '.png'

local NumImg = class('NumImg', function ()
	return cc.Sprite:create()
end)

function NumImg:ctor(group, num, showSign, gap, signScale)
    if num == nil then return end
    self.gap = gap or 0                 --gap的默认参数为0
    self:setCascadeOpacityEnabled(true) --将透明度对子节点生效
    self.showSign = false
    self.signScale = signScale or 1
    self:setGroup(group)
    if type(num) ~= "number" then
        self:setNumByString(num, showSign)
    else
        self:setNum(num, showSign)
    end

end

-- 设置使用哪组数字图片
function NumImg:setGroup(group)
    if self.group and self.group == group then
        return
    end

    self.group = group
end


-- 设置数字
function NumImg:setNum(num, showSign)
    if not self.group then
        -- 未设置使用哪组图片
        return
    end

    if showSign == nil then showSign = false end
    if self.num ~= nil and self.num == num and self.showSign == showSign then
        return
    end

    num = math.floor(num)
    self.num = num
    self.showSign = showSign

    -- 先清除已有图片
    self:removeAllChildren()

    -- 添加对应的帧图片
    local file = ResMgr:getNumImg(self.group)
    local prefix = file .. '/'
    gfAddFrames(file .. ".plist", prefix);

    local showPlus = (showSign and num >= 0)
    local showMinus = (num < 0)
    if showMinus then
        num = 0 - num
    end

    --设置每个数字精灵的锚点
    local key
    local keysArray = {}
    if num == 0 then
        key = self:getImageNmae(prefix, 0)
        table.insert(keysArray, key)
    end

    while num > 0 do
        key = self:getImageNmae(prefix, num % 10)
        num = math.floor(num / 10)
        table.insert(keysArray, key)
    end

    --逆序遍历计算每个数字的位置
    local w, h                       --记录每个数字的宽度
    local totalW = 0                 --总宽度
    local x = 0                      --每个数字的x位置                 --数字与数字之间的间隙

    -- 添加正负号图片
    if showPlus then
        key = self:getImageNmae(prefix, PLUS_KEY)
        w, h = self:addFrame(key, x, true)
        x = x + w + self.gap       --更新下一个数字的位置
    elseif showMinus then
        key = self:getImageNmae(prefix, MINUS_KEY)
        w, h = self:addFrame(key, x, true)
        x = x + w + self.gap       --更新下一个数字的位置
    end

    for i = #keysArray, 1, -1 do
        w, h = self:addFrame(keysArray[i], x)
        x = x + w + self.gap       --更新下一个数字的位置
        if i > 1 then              --更新总宽度
            totalW = totalW + w + self.gap
        else
            totalW = totalW + w
        end
    end

    if totalW == 0 then
        return
    end

    self:setContentSize(totalW, h)
end

-- 若num中带有NOT_NUM中的字符应使用这个方法
function NumImg:setNumByString(num, showSign)
    if not self.group then
        -- 未设置使用哪组图片
        return
    end
    if showSign == nil then showSign = false end
    if self.num ~= nil and self.num == num and self.showSign == showSign then
        return
    end

    self.num = num
    self.showSign = showSign

    -- 先清除已有图片
    self:removeAllChildren()

    -- 添加对应的帧图片
    local file = ResMgr:getNumImg(self.group)
    local prefix = file .. '/'
    gfAddFrames(file .. ".plist", prefix);

    --设置每个数字精灵的锚点
    local key
    local keysArray = {}

    local index = 1
    local len = string.len(num)

    while len >= index do
        local char = string.sub(num, index, index)

        local num = tonumber(char)
        if num  then
            key = self:getImageNmae(prefix, num)
        else
            if NOT_NUM[char] then
                key = self:getImageNmae(prefix, NOT_NUM[char])
            else
                gf:ShowSmallTips(CHS[3002139])
                return
            end
        end

        table.insert(keysArray, key)
        index = index + 1
    end

    --逆序遍历计算每个数字的位置
    local w, h                       --记录每个数字的宽度
    local totalW = 0                 --总宽度
    local x = 0                      --每个数字的x位置                 --数字与数字之间的间隙
    for i = 1, #keysArray do
        w, h = self:addFrame(keysArray[i], x)
        x = x + w + self.gap   --更新下一个数字的位置
        if i > 1 then          --更新总宽度
            totalW = totalW + w + self.gap
        else
            totalW = totalW + w
        end
    end

    if totalW == 0 then
        return
    end

    self:setContentSize(totalW, h)
end

function NumImg:getImageNmae(prefix, num)
    return prefix .. num .. KEY_SUFFIX
end

-- 开始倒计时
function NumImg:startCountDown(callback)
    self.totalTime = self.num * 1000
    self.startTime = gf:getTickCount()

    self.pauseTime = 0
    self.isPause = false

    self:scheduleUpdateWithPriorityLua(function()
        if self.isPause then return end

        local t = gf:getTickCount()
        local num = math.ceil((self.totalTime - (t - self.startTime)) / 1000 + self.pauseTime / 1000)
        if num <= 0 then
            self:setNum(0, false)
            self:stopCountDown()
            callback(self)
        elseif num ~= self.num then
            self:setNum(num, false)
        end
    end, 0)
end

-- 暂停
function NumImg:pauseCountDown()
    self.isPause = true
    self.pauseStartTime = gf:getTickCount()
end

function NumImg:continueCountDown()
    self.isPause = false
    self.pauseTime = self.pauseTime + gf:getTickCount() - self.pauseStartTime
end


-- 停止倒计时
function NumImg:stopCountDown()
    self:unscheduleUpdate()
end

function NumImg:setNumsColor(color)
    local childs = self:getChildren()
    for i = 1, #childs do
        if childs[i].setColor then
            childs[i]:setColor(color)
        end
    end
end

-- 移动图片到指定位置后消失
function NumImg:startMove(duration, pos)
    local action = cc.Spawn:create(cc.MoveTo:create(duration, pos), cc.FadeOut:create(duration))
    action = cc.Sequence:create(action, cc.RemoveSelf:create())
    self:runAction(action)
end

-- 通过精灵帧缓存来添加一个精灵
function NumImg:addFrame(key, x, isSigh)
    local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(key)
    local sp = cc.Sprite:createWithSpriteFrame(frame)
    if not sp then
        local sss
    end

    local sz = sp:getContentSize()
    if isSigh then
        sp:setAnchorPoint(0.5, 0.5)
        sp:setPosition(sz.width / 2, sz.height / 2)
        sp:setScale(self.sightScale)
    else
        sp:setAnchorPoint(0, 0)
        sp:setPosition(x, 0)
    end

    self:addChild(sp)
    return sz.width, sz.height
end

return NumImg
