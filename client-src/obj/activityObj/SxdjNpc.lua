-- SxdjNpc.lua
-- Created by songcw, Jan/19/2018
-- 2019 生肖对决

local Char = require("obj/Char")
local SxdjNpc = class("SxdjNpc", Char)

local TIP_SHOW_TIME = 1.5  -- 扣血血量提示显示时间
local TIP_SHOW_DIS = 10    -- 扣血血量提示飘动距离

local SHOW_TIME = 3

local TITLE_MAGIC_MAP = {}
TITLE_MAGIC_MAP[Const.TITLE_IN_COMBAT]          = {'fighting',      'head'}

function SxdjNpc:init()
    Char.init(self)
end

function SxdjNpc:update()
    Char.update(self)
end
--
function SxdjNpc:updateNameColor()
    if not DlgMgr:getDlgByName("ShengxdjDlg") then return end
    if self:queryBasicInt("isPet") == 0 then return end

    if self:queryBasicInt("corp") == 1 then
        return COLOR3.RED
    end

    return COLOR3.BLUE
end

function SxdjNpc:updateName()
    if self:queryBasicInt("isPet") == 1 then
    else
        Char.updateName(self)
    end
end

function SxdjNpc:setDestPos(pos)
    self.destPos = pos
end

-- 更新 title 效果
function SxdjNpc:addSelectFlag(type, title)
--[[
    local info = TITLE_MAGIC_MAP[title]
    if not info then
        Log:W('Not set TITLE_MAGIC_MAP for title:' .. title)
        return
    end
--]]
  --  local magicType = info[1]

    if self:queryBasicInt("isPet") ~= 1 and self:queryBasic("gid") ~= Me:queryBasic("gid") then return end

    if type == "add" then

        local selectImg = self.topLayer:getChildByName(ResMgr.ui.select_arrows)
        if not selectImg then
            selectImg = cc.Sprite:create(ResMgr.ui.select_arrows)




            selectImg:setFlipY(true)
            selectImg:setName(ResMgr.ui.select_arrows)
            local action = cc.Sequence:create(
                cc.MoveBy:create(0.45, cc.p(0, 10)),
                cc.MoveBy:create(0.45, cc.p(0, -10))
            )

            if self:queryBasicInt("isPet") == 1 then
                selectImg:setPosition(0, 70)
            else
                if self:queryBasic("gid") == Me:queryBasic("gid") then
                    selectImg:setPosition(0, 120)
                    selectImg:setScale(1.2)
                end
            end

            selectImg:runAction(cc.RepeatForever:create(action))
            self:addToTopLayer(selectImg)
        end
        return
        -- 增加标志
        --[[
        local pos = info[2]
        if pos == 'head' then
            self:addMagicOnHead(ResMgr.magic[magicType], false, magicType)
        elseif pos == 'waist' then
            self:addMagicOnWaist(ResMgr.magic[magicType], false, magicType)
        elseif pos == foot then
            self:addMagicOnFoot(ResMgr.magic[magicType], false, magicType)
        else
            Log:W('Invalid pos:' .. pos .. ' in TITLE_MAGIC_MAP for title:' .. title)
        end
        return
        --]]
    end

    local selectImg = self.topLayer:getChildByName(ResMgr.ui.select_arrows)
    if selectImg then
        selectImg:removeFromParent()
    end

--    self:deleteMagic(magicType)
end

function SxdjNpc:setAct(act, callBack, notCheck)
    if act == Const.SA_STAND and self.faAct == Const.FA_WALK then
        DlgMgr:sendMsg("ShengxdjDlg", "endWorkCallBack", self)
    end

    Char.setAct(self, act, callBack)
end

-- 被攻击
function SxdjNpc:doBeAttacked(forceKill)
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
function SxdjNpc:doDeathAction()
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

function SxdjNpc:onEnterScene(mapX, mapY)
    Char.onEnterScene(self, mapX, mapY)

    self:setPos(mapX, mapY)

    local icon = 02046
    if self:queryBasicInt("corp") == 1 then
        icon = 02045
    end

    local actionName = "Bottom"
    local armatureType = 4 -- LightEffect.lua
    local magic = ArmatureMgr:createArmatureByType(armatureType, icon, actionName)
    magic:setName(icon)
    magic:setLocalZOrder(-1)
    -- 需要循环播放骨骼动画
    magic:getAnimation():play(actionName, -1, 1)

    self:addToBottomLayer(magic)
end

-- 显示被扣的血量
function SxdjNpc:showAddPoint(num)
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

function SxdjNpc:generateTip(num)
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

function SxdjNpc:isCanTouch()
    return false
end

-- 设置方向
function SxdjNpc:setDir(dir, noUpdateNow)
    -- 如果当前是死亡动作则不转向
    if not self:isCanChangeDir() then return end

    self.dir = self.toDir or dir
    self:setBasic('dir', self.dir)
    if self.charAction then
        self.charAction:setDirection(self.dir)
    end

    -- 更新一些需要改变方向的特效
    self:updateMagicDir()
end


function SxdjNpc:setEndPos(mapX, mapY, endPosCallBack)

   -- self.endX, self.endY = gf:convertToClientSpace(mapX, mapY)
    self.endX = mapX
    self.endY = mapY

    if not self:getCanMove() then
        return
    end

    local curX, curY = self.curX, self.curY


    -- GObstacle:Instance():FindPath 中是以原始大小进行计算的，所以需要进行换算
    local sceneH = GameMgr:getSceneHeight()
    local rawBeginX = math.floor(curX / Const.MAP_SCALE)
    local rawBeginY = math.floor((sceneH - curY) / Const.MAP_SCALE)
    local rawEndX = math.floor(self.endX / Const.MAP_SCALE)
    local rawEndY = math.floor((sceneH - self.endY) / Const.MAP_SCALE)

    local badpath = false
    local paths = GObstacle:Instance():FindPath(rawBeginX, rawBeginY, rawEndX, rawEndY)
    local count = paths:QueryInt("count")
    if count > 1 then
        if MapMgr:isInMiGong() and (not MiGongMapMgr:checkCanMove(self.endX, self.endY) or paths:QueryInt(string.format("len%d", count)) * Const.MAP_SCALE > 960) then
            return
        end

        -- 复制路径
        self.paths = {}
        self.posCount = count
        for i = 1, count do
            self.paths[string.format("x%d", i)] = paths:QueryInt(string.format("x%d", i)) * Const.MAP_SCALE
            self.paths[string.format("y%d", i)] = sceneH - paths:QueryInt(string.format("y%d", i)) * Const.MAP_SCALE
            self.paths[string.format("len%d", i)] = paths:QueryInt(string.format("len%d", i)) * Const.MAP_SCALE
        end
--[[
        count = count + 1
        self.posCount = count
        self.paths[string.format("x%d", count)] = mapX
        self.paths[string.format("y%d", count)] = mapY
        self.paths[string.format("len%d", count)] = 90 * Const.MAP_SCALE --约
--]]

        local x = paths:QueryInt(string.format("x%d", (count - 1))) - mapX / Const.MAP_SCALE
        local y = paths:QueryInt(string.format("y%d", (count - 1))) - (sceneH - mapY) / Const.MAP_SCALE

        local len = math.floor( math.sqrt( x * x + y * y ) ) * Const.MAP_SCALE

        self.paths[string.format("x%d", count)] = mapX --* Const.MAP_SCALE
        self.paths[string.format("y%d", count)] = mapY --* Const.MAP_SCALE
        self.paths[string.format("len%d", count)] = len --约



        -- 有路可走，队员的动作切换在 updatePos 中依据与队长的距离设置
        if not self:inMeTeam() then
            self:setAct(Const.FA_WALK)
        end

        local distX = math.abs(self.endX - self:getPathValue("x", count))
        local distY = math.abs(self.endY - self:getPathValue("y", count))
        if distX + distY > (Const.PANE_WIDTH + Const.PANE_HEIGHT) * 3 then
            -- 目标点与寻路点距离太远了，标记为寻路失败
            badpath = true
        end
    else
        -- 无路可走
        self:setAct(Const.FA_STAND)

        -- 标记为寻路失败
        badpath = true
    end

    if badpath then
        if Me:isPassiveMode() or (not TeamMgr:inTeam(Me:getId()) and TeamMgr:getLeaderId() == Me:getId()) then
            -- 被动模式或者 me 是队长，寻路失败，直接移动目标到目的地
            self:setLastMapPos(mapX, mapY)
            self:setPos(self.endX, self.endY)
            self:setAct(Const.FA_STAND)
        end
    end

    self.startTime = GameMgr.lastUpdateTime
    self.lastTime = self.startTime
    self.lastLen = 0
end


return SxdjNpc
