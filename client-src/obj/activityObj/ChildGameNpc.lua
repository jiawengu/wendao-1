-- SxdjNpc.lua
-- Created by songcw, Jan/19/2018
-- 2019 生肖对决

local Char = require("obj/Char")
local ChildGameNpc = class("ChildGameNpc", Char)
local Progress = require('ctrl/Progress')
local NumImg = require('ctrl/NumImg')
local LIFE_OFFSET_Y = 30
local FLAG_OFFSET_Y = 60

local TIP_SHOW_TIME = 1.5  -- 扣血血量提示显示时间
local TIP_SHOW_DIS = 10    -- 扣血血量提示飘动距离

local FLY_NUM_IMG_INTERVAL = 30

local FACTS_POS = {
    cc.p(0, 0), cc.p(37.5, 20), cc.p(75, 30), cc.p(112.5, 20), cc.p(150, 0)
}

function ChildGameNpc:startRandomWalk(time, max, fun)
    if time == max then
        local x = self:queryBasicInt("org_x")
        local y = self:queryBasicInt("org_y")
        self:setAct(Const.FA_WALK)
        local function getMoveAct( )
            return cc.MoveTo:create(1, cc.p(x, y))
        end

        local srcX, srcY = self.bottomLayer:getPosition()
        local dir = gf:defineDir(cc.p(srcX, srcY), cc.p(x, y), self:getIcon())
        self:setDir(dir)

        self.bottomLayer:runAction(getMoveAct())
        self.middleLayer:runAction(getMoveAct())
        self.topLayer:runAction(cc.Sequence:create(getMoveAct(), cc.CallFunc:create(function()
            self:setAct(Const.FA_STAND)
            self:setDir(self:queryBasicInt("org_dir"))
            if fun then
                fun()
            end
        end)))
        return
    end

    local function getPos( )
        -- body
        local x = self:queryBasicInt("org_x") + math.random( -150, 150 )
        local y = self:queryBasicInt("org_y") + math.random( -30, 80 )
        return x, y
    end

    local x, y = getPos()

    local srcX, srcY = self.bottomLayer:getPosition()
    local dir = gf:defineDir(cc.p(srcX, srcY), cc.p(x, y), self:getIcon())
    self:setDir(dir)
    self:setAct(Const.FA_WALK)

    local function getMoveAct( )
        return cc.MoveTo:create(1, cc.p(x, y))
    end

    self.bottomLayer:runAction(getMoveAct())
    self.middleLayer:runAction(getMoveAct())
    self.topLayer:runAction(cc.Sequence:create(getMoveAct(), cc.CallFunc:create(function()
        self:startRandomWalk(time + 1, max, fun)
    end)))

end

function ChildGameNpc:generateTip(num)
    -- 生成颜色字符串控件
    local info = ATLAS_FONT_INFO["AtlasLabel0001"]
    local label = ccui.TextAtlas:create(tostring(num), ResMgr.ui.atlasLabel0001, info.width, info.height, info.startCharMap)

   local img = ccui.ImageView:create(ResMgr.ui.atlasLabel0001_add, ccui.TextureResType.localType)
    local imgSize = img:getContentSize()

    local layer = ccui.Layout:create()
    layer:setContentSize(cc.size(imgSize.width + info.width, info.height))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(0.5, 0)

    img:setPosition(imgSize.width / 2, info.height / 2)
    label:setPosition(imgSize.width + (info.width / 2), info.height / 2)

    layer:addChild(label)
    layer:addChild(img)

    return layer
end

-- 显示被扣的血量
function ChildGameNpc:showAddPoint(num)
    if not self.charAction then
        return
    end

    local tip = self:generateTip(num)

    local headX, headY = self.charAction:getHeadOffset()

    tip:setPosition(headX, headY)

    local moveAction = cc.MoveBy:create(TIP_SHOW_TIME, cc.p(0, TIP_SHOW_DIS))

    local action = cc.Sequence:create(
        cc.MoveBy:create(TIP_SHOW_TIME, cc.p(0, TIP_SHOW_DIS)),
        cc.RemoveSelf:create()
    )

    self:addToTopLayer(tip)

    tip:runAction(action)
end

-- 更新标记
function ChildGameNpc:updateFlag()
    if not self.flagPanel then
        --self.flagPanel = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
        self.flagPanel = cc.Layer:create()
        self.flagPanel:setContentSize(150, 30)

        self.flagPanel:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)
        self:addToMiddleLayer(self.flagPanel)

        local headX, headY = self.charAction:getHeadOffset()
        self.flagPanel:setPosition(-75, headY + FLAG_OFFSET_Y)

        for i = 1, 5 do
            local image = ccui.ImageView:create("ui/Icon2601.png")
            image:setName("Fact" .. i)
            image:setPosition(FACTS_POS[i])
            self.flagPanel:addChild(image)
        end
    end


    for i = 1, 5 do
        local image = self.flagPanel:getChildByName("Fact" .. i)
        if i <= self:queryBasicInt("fact") then
            image:loadTexture("ui/Icon2602.png")
        else
            image:loadTexture("ui/Icon2601.png")
        end
    end
end

-- 更新血条
function ChildGameNpc:updateLifeProgress()

    if not self.lifeProgress then
        self.lifeProgress = Progress.new(ResMgr.ui.fight_progress_back, ResMgr.ui.fight_progress_life)
        self.lifeProgress:setLocalZOrder(Const.CHAR_PROGRESS_ZORDER)
        self:addToMiddleLayer(self.lifeProgress)
    end

    -- 变身卡变幻后调整高度
    local headX, headY = self.charAction:getHeadOffset()
    self.lifeProgress:setPosition(0, headY + LIFE_OFFSET_Y)
    self.lifeProgress:setVisible(true)
    local max = self:queryInt('max_life')

    local percent = 0
    if max > 0 then
        percent = self:queryInt('life') * 100 / max
    end

    if percent == 0 then
        DlgMgr:sendMsg("ChildDailyMission1Dlg", "gameOver", self, true)
        self:setChat({msg = CHS[4101539], show_time = 3}, nil, true)
        self:setDieAction()
    end

    self.lifeProgress:setPercent(percent)
end

-- 对象进入场景
function ChildGameNpc:onEnterScene(x, y, layer)
    -- 将对象的 3 层分别添加到角色层对应的子层中
    if self.bottomLayer:getParent() == nil then
        layer:addChild(self.bottomLayer)
    end

    if self.middleLayer:getParent() == nil then
        layer:addChild(self.middleLayer)
    end

    if self.topLayer:getParent() == nil then
        layer:addChild(self.topLayer)
    end

    self:setPos(x, y)

--    gf:ShowSmallTips(x .. "    " .. y)

    -- 更新名字
    self:updateName()

    -- 更新血条
    self:updateLifeProgress()

    -- 更新flag
    self:updateFlag()

    -- 添加阴影
    self:addShadow()
--[[
    local image = ccui.ImageView:create(ResMgr.ui.fish_background)
   -- image:setPosition(x, y)
    layer:addChild(image)
    --]]
end

function ChildGameNpc:setDieAction()
    self:setActAndCB(Const.FA_DIE_NOW, function()
        if self.faAct ~= Const.FA_DIE_NOW then return end

        self:setActAndCB(Const.FA_DIED, function()

        end)
    end)
end

function ChildGameNpc:showLifeDeltaNumber(lifeDelta)
    local x, y = -15, 100

    local group = 'red_s'

    local numImg = NumImg.new(group, lifeDelta, true)
    numImg:setPosition(x, y + LIFE_OFFSET_Y)
    self:addToTopLayer(numImg)

    numImg:startMove(1.0, cc.p(x, y + LIFE_OFFSET_Y + 80))
end

-- 点击对象时添加选中特效
function ChildGameNpc:addFocusMagic()


end

return ChildGameNpc
