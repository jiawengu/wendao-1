-- BwswzNpc.lua
-- Created by haungzz, July/23/2018
-- 宝物守卫战怪物

local Char = require("obj/Char")
local BwswzNpc = class("BwswzNpc", Char)

local TIP_SHOW_TIME = 1.5  -- 扣血血量提示显示时间
local TIP_SHOW_DIS = 10    -- 扣血血量提示飘动距离

local TALK_TEXT = {
    CHS[5400632],
    CHS[5400633],
    CHS[5400634],
    CHS[5400635],
}

local SHOW_TIME = 3

function BwswzNpc:init()
    Char.init(self)
end

function BwswzNpc:update()
    Char.update(self)
end

function BwswzNpc:setDestPos(pos)
    self.destPos = pos
end

function BwswzNpc:setAct(act, callBack, notCheck)
    Char.setAct(self, act, callBack)

    if act == Const.SA_STAND and not notCheck then
        local x, y = gf:convertToClientSpace(self.destPos.x, self.destPos.y)
        if math.abs(self.curX - x) <= 1 and math.abs(self.curY - y) <= 1 then
            -- 自动寻路到达目的地
            NewYearGuardMgr:monsterGetTreasure(self)

            -- 喊话
            self:setChat({msg = TALK_TEXT[math.random(1, 4)], show_time = SHOW_TIME}, nil, true)

            -- 播放攻击动作
            self:setActAndCB(Const.FA_ACTION_PHYSICAL_ATTACK, function()
                self:setActAndCB(Const.FA_ACTION_ATTACK_FINISH, function() 
                    self:setAct(Const.SA_STAND, nil, true)
                end)
            end)
        end
    end
end

-- 被攻击
function BwswzNpc:doBeAttacked(forceKill)
    if forceKill then
        self:setBasic("life", 0)
    else
        local life = self:queryBasicInt("life")
        self:setBasic("life", life - 1)
    end

    -- 清走路数据
    self:setAct(Const.SA_STAND, nil, true)

    self:setActAndCB(Const.FA_DEFENSE_START, function()
        if self.faAct == Const.FA_DEFENSE_START and self.charAction then
            performWithDelay(self.charAction, function()
                self:setActAndCB(Const.FA_DEFENSE_END, function()
                    if self:queryBasicInt("life") == 0 then
                        self:doDeathAction()
                    else
                        -- 继续走
                        self:setEndPos(self.destPos.x, self.destPos.y)
                    end
                end)
            end, 0.1)
        elseif self:queryBasicInt("life") == 0 then
            self:doDeathAction()
        end
    end)
end

-- 死亡
function BwswzNpc:doDeathAction()
    self:setActAndCB(Const.FA_DIE_NOW, function()
        self:setActAndCB(Const.FA_DIED, function() 
            if self.middleLayer then
                local action = cc.Sequence:create(
                    cc.Blink:create(0.5, 3),
                    cc.CallFunc:create(function() 
                        NewYearGuardMgr:deleteChar(self:getId())
                    end)
                )

                self.middleLayer:runAction(action)
            end
        end)
    end)
end

-- 显示被扣的血量
function BwswzNpc:showAddPoint(num)
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

function BwswzNpc:generateTip(num)
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

function BwswzNpc:isCanTouch()
    return false
end

return BwswzNpc
