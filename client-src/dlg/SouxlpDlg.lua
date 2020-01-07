-- SouxlpDlg.lua
-- Created by lixh Nov/02/2017
-- 2018元旦节：搜邪罗盘界面

local SouxlpDlg = Singleton("SouxlpDlg", Dialog)

-- 罗盘上珠子名称
local STONE_PANEL_NAME = {"UpStoneImage", "RightStoneImage", "DownStoneImage", "LeftStoneImage"}

-- 珠子名称到光效动作名的映射
local STONE_NAME_TO_ACTION_NAME = {
    ["UpStoneImage"] = {action = "Bottom01", offsetX = 0, offsetY = -112},
    ["RightStoneImage"] = {action = "Bottom04", offsetX = -137, offsetY = 26},
    ["DownStoneImage"] = {action = "Bottom03", offsetX = 0, offsetY = 162},
    ["LeftStoneImage"] = {action = "Bottom02", offsetX = 137, offsetY = 26},
}

-- 提示图片
local TIPS_STR_TO_IMAGE = {
    ["init"] = ResMgr.ui.souxlp_init_tip,
    ["correct"] = ResMgr.ui.souxlp_correct_tip,
    ["toMiddle"] = ResMgr.ui.souxlp_toMiddle_tip,
    ["mistake"] = ResMgr.ui.souxlp_mistake_tip,
    ["toNeedle"] = ResMgr.ui.souxlp_toNeedle_tip,
    ["finish"] = ResMgr.ui.souxlp_finish_tip,
}

-- 珠子上光效标记
local MAGIC_TAG = 999

-- 珠子上光效名称
local MAGIC_NAME = ResMgr.ArmatureMagic.souxlp_stone.name

-- 罗盘指针旋转速度
local NEEDLE_SPEED = 0.5

-- 罗盘指针旋转加速度
local NEEDLE_ACC_SPEED = 0.01

-- 颜色珠子半径
local COLOR_STONE_RADIUS = 21

-- 重力珠子半径
local CENTER_STONE_RADIUS = 22

-- 罗盘半径
local COMPASS_RADIUS = 239

-- 重力珠子滚动速度
local CENTER_STONE_SPEED = 16
local CENTER_STONE_ORI_SPEED = CENTER_STONE_SPEED

-- 罗盘中心位置
local COMPASS_CENTER_X = 251
local COMPASS_CENTER_Y = 251

-- 拨动指针倒计时最大时间
local TO_NEEDLE_MAX_TIME = 3

-- 提示内容动作放大倍数
local TIPS_ACTION_SCALE = 1.5

-- 提示内容动作播放时间
local TIPS_ACTION_TIME = 0.5

-- 指针相对响应区域位置
local NEEDLE_POS_TO_TOUCH_AREA = {leftDown = {x = 237, y = 144}, rightTop = {x = 266, y = 471}}

function SouxlpDlg:init()
    local platform = cc.Application:getInstance():getTargetPlatform()
    -- ipad屏幕宽高相对一般手机大很多，速度需要减小
    if platform == cc.PLATFORM_OS_IPAD then
        CENTER_STONE_SPEED = CENTER_STONE_ORI_SPEED / 2
    end

    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")
    self:bindListener("ClosePanel", self.onCloseButton)
    self:bindListener("InfoButton", self.onRuleButton)

    self.needleTouchPanel = self:getControl("CenterNeedleTouchPanel", nil, "LuoPPanel")

    -- 监听触摸事件
    self:bindNeedleListener()

    self.lightImage = self:getControl("LightImage", nil, "LuoPPanel")
    self.centerStoneShadowImage = self:getControl("CenterStoneShadowImage", nil, "LuoPPanel")
    self.centerStone = self:getControl("CenterStoneImage", nil, "LuoPPanel")
    self.redStone = self:getControl("UpStoneImage", nil, "LuoPPanel")
    self.yellowStone = self:getControl("LeftStoneImage", nil, "LuoPPanel")
    self.greenStone = self:getControl("RightStoneImage", nil, "LuoPPanel")
    self.blueStone = self:getControl("DownStoneImage", nil, "LuoPPanel")

    self.redStonePosX, self.redStonePosY = self.redStone:getPosition()
    self.yellowStonePosX, self.yellowStonePosY = self.yellowStone:getPosition()
    self.greenStonePosX, self.greenStonePosY = self.greenStone:getPosition()
    self.blueStonePosX, self.blueStonePosY = self.blueStone:getPosition()
    self.compassPosX, self.compassPosY = self:getControl("LPBKImage_1", nil, "LuoPPanel"):getPosition()

    self.tipImage = self:getControl("Image", nil, "TitlePanel")
    self:setTipsByType("init", true)

    self.needleStatus = false
    self.lastKnockStone = nil

    self.hadPressNeedle = nil
    self.knockOrder = self:getInitStoneSeq()
    self:resetStoneStatus()

    gf:CmdToServer("CMD_NEWYEAR_2018_LPXZ", {status = "start"})

    -- 开启重力感应
    self:addAccToDlg()

    self:hookMsg("MSG_ENTER_ROOM")
    self:hookMsg("MSG_C_START_COMBAT")
end

-- 绑定指针响应区域事件
function SouxlpDlg:bindNeedleListener()
    self.needleTouchPanel:addTouchEventListener(function(sender, eventType)
        -- 捕获到begin, move, ended, cancel事件都需要检测当前有没有触摸到指针区域
        local touchPos = GameMgr.curTouchPos
        touchPos = self.needleTouchPanel:getParent():convertToNodeSpace(touchPos)
        if self:isInNeedleArea(touchPos.x, touchPos.y) then
            self.hadPressNeedle = true
        end
    end)
end

-- 判断当前点是否在指针范围内
function SouxlpDlg:isInNeedleArea(x, y)
    if x >= NEEDLE_POS_TO_TOUCH_AREA.leftDown.x and x <= NEEDLE_POS_TO_TOUCH_AREA.rightTop.x and
        y >= NEEDLE_POS_TO_TOUCH_AREA.leftDown.y and y <= NEEDLE_POS_TO_TOUCH_AREA.rightTop.y then
        return true
    end

    return false
end

-- 是否碰撞到罗盘
function SouxlpDlg:isKnockCompass(x1, y1)
    if gf:distance(x1, y1, self.compassPosX, self.compassPosY) < COMPASS_RADIUS - CENTER_STONE_RADIUS then
        return false
    end

    return true
end

-- 是否碰撞到珠子，碰撞到珠子返回珠子index
function SouxlpDlg:isKnockStones(x1, y1)
    if gf:distance(x1, y1, self.redStonePosX, self.redStonePosY) < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
        return "UpStoneImage", self.redStonePosX, self.redStonePosY
    end

    if gf:distance(x1, y1, self.greenStonePosX, self.greenStonePosY) < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
        return "RightStoneImage", self.greenStonePosX, self.greenStonePosY
    end

    if gf:distance(x1, y1, self.blueStonePosX, self.blueStonePosY) < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
        return "DownStoneImage", self.blueStonePosX, self.blueStonePosY
    end

    if gf:distance(x1, y1, self.yellowStonePosX, self.yellowStonePosY) < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
        return "LeftStoneImage", self.yellowStonePosX, self.yellowStonePosY
    end

    return false
end

-- 计算碰撞到罗盘调整后的位置
function SouxlpDlg:getKnockCompassAdjustXY(furX, furY)
    local adjX, adjY
    if furX == COMPASS_CENTER_X then
        -- 滚动珠子在罗盘中心X轴垂直方向，此时没有斜率
        adjX = furX
        adjY = furY
        if furY - CENTER_STONE_RADIUS < COMPASS_CENTER_Y - COMPASS_RADIUS then
            adjY = CENTER_STONE_RADIUS + COMPASS_CENTER_Y - COMPASS_RADIUS
        elseif furY + CENTER_STONE_RADIUS > COMPASS_CENTER_Y + COMPASS_RADIUS then
            adjY = COMPASS_CENTER_Y + COMPASS_RADIUS - CENTER_STONE_RADIUS
        end

        return adjX, adjY
    end

    local k = (furX - COMPASS_CENTER_X) / (furY - COMPASS_CENTER_Y)
    local v = math.sqrt((COMPASS_RADIUS - CENTER_STONE_RADIUS) * (COMPASS_RADIUS - CENTER_STONE_RADIUS) / (1 + k * k))
    if furY < COMPASS_CENTER_Y then
        adjY = - v + COMPASS_CENTER_Y
    else
        adjY = v + COMPASS_CENTER_Y
    end

    adjX = COMPASS_CENTER_X + k * (adjY - COMPASS_CENTER_Y)
    return adjX, adjY
end

-- 计算碰撞到颜色珠子调整后的位置
function SouxlpDlg:getKnockStoneAdjustXY(furX, furY, centerX, centerY)
    local adjX, adjY
    if furX == centerX then
        -- 滚动珠子在颜色珠子中心X轴垂直方向，此时没有斜率
        adjX = furX
        adjY = furY
        if centerY - furY < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
            adjY = centerY + COLOR_STONE_RADIUS + CENTER_STONE_RADIUS
        elseif furY - centerY < COLOR_STONE_RADIUS + CENTER_STONE_RADIUS then
            adjY = centerY - COLOR_STONE_RADIUS - CENTER_STONE_RADIUS
        end

        return adjX, adjY
    end

    local k = (furX - centerX) / (furY - centerY)
    local v = math.sqrt((COLOR_STONE_RADIUS + CENTER_STONE_RADIUS) * (COLOR_STONE_RADIUS + CENTER_STONE_RADIUS) / (1 + k * k))
    if furY < centerY then
        adjY = - v + centerY
    else
        adjY = v + centerY
    end

    adjX = centerX + k * (adjY - centerY)
    return adjX, adjY
end


-- 界面增加重力感应
function SouxlpDlg:addAccToDlg()
    self.layer = cc.Layer:create()
    self.layer:setAccelerometerEnabled(true)

    -- 重力感应回调函数: x > 0：右， x < 0：左，y > 0：下， y < 0：上
    local function accelerometerListener(event, x, y, z, timestamp)
        -- 指针状态不需要重力回调响应
        if self.needleStatus then
            return
        end

        local origX, origY = self.centerStone:getPosition()
        if self:isStoneMagicFinish() and self:isStoneInMiddle() then
            self:toNeedleStatus()
        end

        local moveX = x * CENTER_STONE_SPEED
        local moveY = y * CENTER_STONE_SPEED
        local tarX = origX + moveX
        local tarY = origY + moveY

        -- 撞到罗盘
        if self:isKnockCompass(tarX, tarY) then
            tarX,tarY = self:getKnockCompassAdjustXY(tarX, tarY)
        end

        local knockStone, centerStoneX, centerStoneY = self:isKnockStones(tarX, tarY)

        -- 撞到颜色珠子
        if knockStone then
            tarX, tarY = self:getKnockStoneAdjustXY(tarX, tarY, centerStoneX, centerStoneY)

            if not self.lastKnockStone then
                -- 首次撞击珠子，直接认为撞击成功
                self.lastKnockStone = knockStone

                if self:isKnockStoneCorrect(knockStone) then
                    self:addStoneMagic(knockStone)
                    self:setStoneStatus(knockStone, true)
                    self:setTipsByType("correct", true)
                else
                    self:setTipsByType("mistake", true)
                end
            else
                -- 本次撞击与上次撞击不是同一个珠子
                if self.lastKnockStone ~= knockStone then
                    if self:isKnockStoneCorrect(knockStone) then
                        -- 撞击了正确顺序的珠子
                        self:addStoneMagic(knockStone)
                        self:setStoneStatus(knockStone, true)

                        if self:isStoneMagicFinish() then
                            self:setTipsByType("toMiddle", true)

                            -- 打开罗盘中心特效
                            self:setCtrlVisible("LightPanel", true, "LuoPPanel")
                        else
                            self:setTipsByType("correct", true)
                        end
                    else
                        self:resetStoneStatus()
                        self:setTipsByType("mistake", true)
                    end
                end

                self.lastKnockStone = knockStone
            end
        end

        self.centerStone:setPosition(cc.p(tarX, tarY))

        -- 影子层级比滚珠小，需要跟着球走
        self.centerStoneShadowImage:setPosition(cc.p(tarX, tarY))

        -- 光效图片位置延迟0.2秒移动，达到拖尾效果
        performWithDelay(self.root, function()
            self.lightImage:setPosition(cc.p(tarX, tarY))
        end, 0.2)
    end

    local listener = cc.EventListenerAcceleration:create(accelerometerListener)
    self.layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, self.layer)
    self.root:addChild(self.layer)
end

-- 设置提示内容
-- type 提示内容类型   needAction 是否需要播放动作
function SouxlpDlg:setTipsByType(type, needAction)
    self.tipImage = self:getControl("Image", nil, "TitlePanel")
    self.tipImage:loadTexture(TIPS_STR_TO_IMAGE[type], ccui.TextureResType.localType)

    if needAction then
        self.tipImage:setScale(TIPS_ACTION_SCALE)
        local scaleTo = cc.ScaleTo:create(TIPS_ACTION_TIME, 1.0, 1.0)
        local action = cc.Sequence:create(scaleTo)
        self.tipImage:runAction(action)
    end
end

-- 判断重力珠是否归位
function SouxlpDlg:isStoneInMiddle()
    local x1, y1 = self.centerStone:getPosition()
    if gf:distance(x1, y1, COMPASS_CENTER_X, COMPASS_CENTER_Y) <= CENTER_STONE_RADIUS / 2 then
        return true
    end

    return false
end

-- 设置为拨动指针状态
function SouxlpDlg:toNeedleStatus()
    self.needleStatus = true
    self.hadPressNeedle = false

    -- 隐藏重力珠
    self:setCtrlVisible("CenterStoneImage", false, "LuoPPanel")
    self.centerStone:setPosition(cc.p(COMPASS_CENTER_X, COMPASS_CENTER_Y + COMPASS_RADIUS - CENTER_STONE_RADIUS))

    -- 隐藏重力珠影子
    self.centerStoneShadowImage:setVisible(false)

    -- 隐藏颜色珠子
    self:setColorStoneVisible(false)

    -- 隐藏罗盘中心特效
    self:setCtrlVisible("LightPanel", false, "LuoPPanel")

    -- 显示指针
    self:setCtrlVisible("CenterNeedleImage", true, "LuoPPanel")

    -- 设置提示内容
    self:setTipsByType("toNeedle", true)

    local leftTime = TO_NEEDLE_MAX_TIME
    if not self.schedulId then
        self.schedulId = self:startSchedule(function()
            if leftTime > 0 then
                leftTime = leftTime - 0.1
                if self.hadPressNeedle then
                    self:clearSchedule()
                    self:needleStartRotateSelf()
                end
            else
                self:clearSchedule()
                self:resetStoneStatus()
                self:setCtrlVisible("CenterNeedleImage", false, "LuoPPanel")
                self:setTipsByType("init", true)
                self.lastKnockStone = nil

                -- 显示颜色珠子
                self:setColorStoneVisible(true)

                -- 显示重力珠并归位
                self:setCtrlVisible("CenterStoneImage", true, "LuoPPanel")
                self.centerStone:setPosition(cc.p(COMPASS_CENTER_X, COMPASS_CENTER_Y))

                -- 显示重力珠影子
                self.centerStoneShadowImage:setVisible(true)
                self.centerStoneShadowImage:setPosition(cc.p(COMPASS_CENTER_X, COMPASS_CENTER_Y))

                gf:ShowSmallTips(CHS[7120019])
                ChatMgr:sendMiscMsg(CHS[7120019])
                self.needleStatus = false
            end
        end, 0.1)
    end
end

-- 停止倒计时
function SouxlpDlg:clearSchedule()
    if self.schedulId then
        self:stopSchedule(self.schedulId)
        self.schedulId = nil
    end
end

function SouxlpDlg:cleanup()
    self:clearSchedule()
end

-- 重载关闭界面函数
function SouxlpDlg:onCloseButton()
    gf:CmdToServer("CMD_NEWYEAR_2018_LPXZ", {status = "close"})
    Dialog.onCloseButton(self)
end

-- 打开规则界面
function SouxlpDlg:onRuleButton()
    DlgMgr:openDlg("SouxlpRuleDlg")
end

-- 罗盘指针旋转
function SouxlpDlg:needleStartRotateSelf()
    -- 罗盘上指针旋转次数
    self.rotateTimes = math.random(30, 40)
    local needle = self:getControl("CenterNeedleImage", nil, "LuoPPanel")
    local startIndex = 1
    local endIndex = self.rotateTimes
    local speed = NEEDLE_SPEED
    local maxSpeedIndex = endIndex / 4

    local function rotateFunc()
        if startIndex > endIndex then -- 停止转动
            needle:stopAllActions()

            self:setTipsByType("finish", true)
            gf:CmdToServer("CMD_NEWYEAR_2018_LPXZ", {status = "finish"})
            self:onCloseButton()
            return
        end

        if startIndex <= maxSpeedIndex then
            speed = speed - NEEDLE_ACC_SPEED * startIndex
        else
            speed = speed + NEEDLE_ACC_SPEED * (startIndex - maxSpeedIndex)
        end

        local rotate = cc.RotateBy:create(speed, 360)
        local action = cc.RepeatForever:create(rotate)
        needle:runAction(action)

        startIndex = startIndex + 1
    end

    schedule(needle, rotateFunc, 0.1)
end

-- 设置四个颜色珠子状态
-- status(true:可见     false 隐藏)
function SouxlpDlg:setColorStoneVisible(status)
    self.redStone:setVisible(status)
    self.yellowStone:setVisible(status)
    self.greenStone:setVisible(status)
    self.blueStone:setVisible(status)
end

-- 添加index珠子上光效
function SouxlpDlg:addStoneMagic(stoneName)
    if stoneName then
        local panel = self:getControl(stoneName, nil, "LuoPPanel")
        if panel then
            local magicInfo = {name = MAGIC_NAME, action = STONE_NAME_TO_ACTION_NAME[stoneName].action}
            gf:createArmatureMagic(magicInfo, panel, MAGIC_TAG,
                STONE_NAME_TO_ACTION_NAME[stoneName].offsetX, STONE_NAME_TO_ACTION_NAME[stoneName].offsetY)
        end
    end
end

-- 移除index珠子上光效
function SouxlpDlg:removeStoneMagic(stoneName)
    if stoneName then
        local panel = self:getControl(stoneName, nil, "LuoPPanel")
        if panel then
            panel:removeChildByTag(MAGIC_TAG)
        end
    end
end

-- 获得初始撞击珠子的顺序
function SouxlpDlg:getInitStoneSeq()
    local initStoneArray = gf:deepCopy(STONE_PANEL_NAME)
    local ret = {}
    local startIndex = 1
    local maxNum = #initStoneArray
    for i = 1, maxNum do
        if #initStoneArray > 0 then
            local index = math.random(1, #initStoneArray)
            ret[startIndex] = {["name"] = initStoneArray[index], ["status"] = false}
            startIndex = startIndex + 1
            table.remove(initStoneArray, index)
        end
    end

    return ret
end

-- 判断是否把珠子全点亮
function SouxlpDlg:isStoneMagicFinish()
    if not self.knockOrder then
        return false
    end

    for i = 1, #self.knockOrder do
        if not self.knockOrder[i].status then
            return false
        end
    end

    return true
end

-- 判断撞击顺序是否正确
function SouxlpDlg:isKnockStoneCorrect(stoneName)
    if not self.knockOrder then
        return false
    end

    for i = 1, #self.knockOrder do
        if self.knockOrder[i].name ~= stoneName then
            if not self.knockOrder[i].status then
                return false
            end
        else
            return true
        end
    end

    return true
end

-- 设置stoneName为撞击状态
function SouxlpDlg:setStoneStatus(stoneName, status)
    if not self.knockOrder then
        return
    end

    for i = 1, #self.knockOrder do
        if self.knockOrder[i].name == stoneName then
            self.knockOrder[i].status = status
        end
    end
end

-- 重置撞击状态
function SouxlpDlg:resetStoneStatus()
    if not self.knockOrder then
        return
    end

    for i = 1, #self.knockOrder do
        self.knockOrder[i].status = false
        self:removeStoneMagic(self.knockOrder[i].name)
    end

    self:setCtrlVisible("LightPanel", false, "LuoPPanel")
end

function SouxlpDlg:MSG_ENTER_ROOM()
    gf:ShowSmallTips(CHS[7120020])
    self:onCloseButton()
end

function SouxlpDlg:MSG_C_START_COMBAT()
    self:MSG_ENTER_ROOM()
end

return SouxlpDlg
