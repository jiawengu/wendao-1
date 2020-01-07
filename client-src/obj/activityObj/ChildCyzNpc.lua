-- ChildCyzNpc.lua
-- Created by songcw, Jan/19/2018
-- 娃娃日常-踩影子

local Char = require("obj/Char")
local ChildCyzNpc = class("ChildCyzNpc", Char)

function ChildCyzNpc:onEnterScene(mapX, mapY)
    Char.onEnterScene(self, mapX, mapY)

  --  self:setVisible(false)

    if self:queryBasicInt("tag") == 2 then
        -- 我的影子
        self:setVisible(false)
    elseif self:queryBasicInt("tag") == 4 then
        self:setVisible(false)
    elseif self:queryBasicInt("tag") == 5 then
        self:setVisible(false)
    elseif self:queryBasicInt("tag") == 6 then
        self:setVisible(false)
    elseif self:queryBasicInt("tag") == 8 then
        self:setVisible(false)
    end

    self:setPos(mapX, mapY)
end


function ChildCyzNpc:showEffect(icon, isAdd)
    if isAdd then
        local magic = self.bottomLayer:getChildByName("showEffect")
        if magic then magic:removeFromParent() end

        local magic = gf:createLoopMagic(icon)
        magic:setName("showEffect")

        if icon == 4009 then

            if self:queryBasicInt("tag") == 3 then
                magic:setPosition(0, 85)
            else
                magic:setPosition(0, 120)
            end
        end
        self.topLayer:addChild(magic)


    else
        local magic = self.topLayer:getChildByName("showEffect")
        if magic then magic:removeFromParent() end
    end
end


function ChildCyzNpc:showSelectAction(visible)
    if not self.selectImg then
        self.selectImg = cc.Sprite:create(ResMgr.ui.select_arrows)
        self.selectImg:setPosition(0, 120)
        self.selectImg:setFlipY(true)
      --  self.selectImg:retain()

        local action = cc.Sequence:create(
            cc.MoveBy:create(0.45, cc.p(0, 10)),
            cc.MoveBy:create(0.45, cc.p(0, -10))
        )

        self.selectImg:runAction(cc.RepeatForever:create(action))
        self.topLayer:addChild(self.selectImg)
    end

    self.selectImg:setVisible(visible)

end


function ChildCyzNpc:setVisible(visible)
    if self.visible == visible then
        return
    end

    self.visible = visible
  --  self.bottomLayer:setVisible(visible)
    self.middleLayer:setVisible(visible)
   -- self.topLayer:setVisible(visible)
end


function ChildCyzNpc:addName(color, offsetX, offsetY, str, fontSize, tag)
    local nameLabel = ccui.Text:create()
    nameLabel:setFontSize(fontSize)
    nameLabel:setString(str)
    nameLabel:setColor(color)
    local size = nameLabel:getContentSize()

    if fontSize == NAME_FONT_SIZE then
        size.width = size.width + 8
        size.height = size.height + 8
    else
        size.width = size.width + 8
        size.height = size.height + 4
    end

    -- 创建一个底图
    local bgImage = ccui.ImageView:create(ResMgr.ui.chenwei_name_bgimg, ccui.TextureResType.plistType)
    self.nameBgImage = bgImage
    local bgImgSize = bgImage:getContentSize()
    bgImage:setScale9Enabled(true)
    size.height = bgImgSize.height
    bgImage:setContentSize(size)
    nameLabel:setPosition(size.width / 2, size.height / 2)

    local nameLabel2 = nameLabel:clone()
    nameLabel2:setPosition(size.width / 2 + 1, size.height / 2)
    nameLabel2:setColor(COLOR3.BLACK)
    bgImage:addChild(nameLabel2)
    bgImage:addChild(nameLabel)

    bgImage:setPosition(offsetX, offsetY)
    bgImage:setTag(tag)
    self:addToBottomLayer(bgImage)
    bgImage:setLocalZOrder(Const.NAME_ZORDER)
    return nameLabel, nameLabel2
end

function ChildCyzNpc:setDestPos(pos)
    self.destPos = pos
end


--
function ChildCyzNpc:addShadow()

    if self:queryBasicInt("tag") == 5 then
        local magic = self.bottomLayer:getChildByName(ResMgr.ArmatureMagic.magic02045.name)
        if magic then return end
        local icon = tonumber(ResMgr.ArmatureMagic.magic02045.name)
        local magic = ArmatureMgr:createCharArmature(icon)
        magic:setName(ResMgr.ArmatureMagic.magic02045.name)
        magic:getAnimation():play(ResMgr.ArmatureMagic.magic02045.action, -1, 1)
        self:addToBottomLayer(magic)
    elseif self:queryBasicInt("tag") == 6 then
        local magic = self.bottomLayer:getChildByName(ResMgr.ArmatureMagic.magic02046.name)
        if magic then return end
        local icon = tonumber(ResMgr.ArmatureMagic.magic02046.name)
        local magic = ArmatureMgr:createCharArmature(icon)
        magic:setName(ResMgr.ArmatureMagic.magic02046.name)
        magic:getAnimation():play(ResMgr.ArmatureMagic.magic02046.action, -1, 1)
        self:addToBottomLayer(magic)
    elseif self:queryBasicInt("tag") == 8 then
        local magic = self.bottomLayer:getChildByName(tostring(ResMgr.exit_default))
        if magic then return end
        local magic = gf:createLoopMagic(ResMgr.magic.exit_default)
        magic:setName(tostring(ResMgr.exit_default))
        self:addToBottomLayer(magic)
    else
        Char.addShadow(self)
    end
end


function ChildCyzNpc:setEndPos(mapX, mapY, endPosCallBack)

    -- 到达终点的回调
    if endPosCallBack then
        self.endPosCallBack = endPosCallBack
    else
        self.endPosCallBack = nil
    end

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

-- 更新人物位置
function ChildCyzNpc:updatePos()
    if (Me:isInCombat() or Me:isLookOn()) and Me:getId() == self:getId() then
        return
    end

    if not self:isFightObj() and Me:getId() ~= self:getId() then
        if MarryMgr:checkWeddingActionZone(self) then
            -- 在对应的婚礼动作区域，隐藏
            self:setNeedDelete()
        else
            -- 否则，按照正常的逻辑进行
            CharMgr:doCharHideStatus(self)
        end
    end

    -- 打雪仗任务不处理共乘，原因是，打雪仗会把任务位置强制设置为目的坐标，若 共乘， 乘客位置又会被强制拉回去导致显示异常
    if DlgMgr:getDlgByName("VacationSnowDlg") then

    else
    -- 共乘
    local driverId = self:queryBasicInt("share_mount_leader_id")
    if 0~= driverId and driverId ~= self:getId() and self:isShowRidePet() then
        local char = CharMgr:getChar(driverId)
        if char then
            self:setLastMapPos(gf:convertToMapSpace(self.curX, self.curY))
            self:setPos(char.curX, char.curY)
        end
        return
    end
    end

    -- 更新速度
    self:updateSpeed()

    -- 如果是非战斗对象，远离队长了，重新进行终点移动
    if self:getType() == "Player" then
        if self:inMeTeam() and gf:distance(Me.curX, Me.curY, self.curX, self.curY) >= MAX_FOLLOW_LEN * Const.PANE_WIDTH and self.faAct == Const.FA_STAND and not self.bReadyMove then
            if AutoWalkMgr:isAutoWalk() then
                self:setEndPos(gf:convertToMapSpace(Me.endX, Me.endY))
            end
        end
    end

    if not self.posCount or self.posCount <= 1 then
        return
    end

    local curLen = 0
    local len = self.lastLen
    local curTime = gfGetTickCount()
    if curTime <= self.startTime then
        -- 时间有误，不需要移动
        curLen = 0
    else
        local dist = (TeamMgr:getOrderById(self:getId()) - 1) * Const.CHAR_FOLLOW_DISTANCE
        if self:inMeTeam() and gf:inOffset(Me.curX, Me.curY, self.curX, self.curY, dist) then
            -- 玩家在 me 的队伍中，且离 me 的距离够近了
            curLen = self.lastLen
            if not self:canFollow() then
                self:setAct(Const.FA_STAND)
            end
        else
            self:setAct(Const.FA_WALK)

            -- 修正移动距离
            local _, _, _, _, ct = gf:getTickCount()
            local stepLen = self:getSpeed() * ct
            stepLen = self:reviseStepLen(stepLen)
            curLen = self.lastLen + stepLen
        end

        self.lastTime = curTime
    end

    if self.faAct ~= Const.FA_WALK then
        return
    end

    while len < curLen do
        -- 计算当前走了多少距离
        local d = 12
        len = len + d
        if len > curLen then
            d = d - (len - curLen)
            len = curLen
        end

        local i = 2
        while i <= self.posCount do
            if len < self:getPathValue("len", i) then
                break
            end

            i = i + 1
        end

        if i > self.posCount then
            -- 计步工具可以输入两个目标点，如果计步工具界面存在，考虑是否有第二目的地
            local dlg = DlgMgr:getDlgByName("PedometerDlg")
            if dlg and dlg.isNeedAutoNext then
                dlg:autoNextDest()
                return
            end

            -- 没有后续的寻路信息
            self:setPos(self:getPathValue("x", i - 1), self:getPathValue("y", i - 1))
            self:sendFollow()
            if not self:canFollow() then
                self:setAct(Const.FA_STAND)

                -- 到达终点的回调,调用完就清除
                if self.endPosCallBack and type(self.endPosCallBack.func) == 'function' then
                    self.endPosCallBack.func(self.endPosCallBack.para)
     --               self.endPosCallBack = nil
                end

                return
            end
        else
            -- 根据当前步的步长计算当前移动的位置及方向
            local dx = self:getPathValue("x", i) - self:getPathValue("x", i - 1)
            local dy = self:getPathValue("y", i) - self:getPathValue("y", i - 1)
            local ds = math.sqrt(dx * dx + dy * dy)
            local lastX, lastY = self.curX, self.curY

            local curX, curY
            if 0 == dx and 0 == dy then
                curX = self:getPathValue("x", i)
                curY = self:getPathValue("y", i)
            else
                curX = self:getPathValue("x", i - 1) + dx * (len - self:getPathValue("len", i - 1)) / ds
                curY = self:getPathValue("y", i - 1) + dy * (len - self:getPathValue("len", i - 1)) / ds
            end

            self:setPos(curX, curY)

            local dir = gf:defineDir(cc.p(0, 0), cc.p(dx, dy), self:getIcon())
            self:setDir(dir)
            self:sendFollow()

            -- 如果有外部手动设置停止动作，则直接跳过移动动作
            if self.faAct == Const.FA_STAND then
                break
            end
        end
    end

    self.lastLen = curLen
    self:updateToAddFocusMagic()
end

function ChildCyzNpc:cleanup()
    self:showEffect(nil, false)
    if self.selectImg then
        self.selectImg:stopAllActions()
        self.selectImg:removeFromParent()
        self.selectImg = nil
    end
    Char.cleanup(self)
end

return ChildCyzNpc
