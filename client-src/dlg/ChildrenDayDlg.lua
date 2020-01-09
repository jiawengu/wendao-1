-- ChildrenDayDlg.lua
-- Created by sujl, May/3/2017
-- 儿童节泡泡界面

local ChildrenDayDlg = Singleton("ChildrenDayDlg", Dialog)
local NumImg = require('ctrl/NumImg')

-- 点击事件间隔
local CLICK_INTERVAL = 50 -- 单位:ms
local BUBBLE_ICON = ResMgr.ArmatureMagic.childday_bubble.name
local BUBBLE_COLOR_ACTION = {
    "Bottom02", -- 黄
    "Bottom03", -- 紫
    "Bottom01", -- 彩色
}

-- 气泡破碎效果
local BUBBLE_COLOR_EFFECT = {
    ResMgr.magic.poke_bubble_effect1,   -- 蓝
    ResMgr.magic.poke_bubble_effect2,   -- 紫
    ResMgr.magic.poke_bubble_effect3,   -- 黄
}

-- x轴速度
local x_speed = { -80, 80 }

-- y轴速度
local y_speed = 80

-- 缩放区间 * 10
local b_scale = { 6, 15 }

-- 生成间距
local b_dis = 40

-- 出生位置区间
local b_born = { -20, 0 }

-- 有效半径
local radius = 65

-- 速度变换时间间隔
local speed_scale_time = 10

-- 速度提升比例
local speed_scale_up = 0.125

function ChildrenDayDlg:init(param)
    self:setFullScreen()
    self:setCtrlFullClient("BlackPanel", "BackPanel")

    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_1")
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_2")

    self:bindListener("CloseImagePanel", self.onResultPanel, "ResultPanel_1")
    self:bindListener("CloseImagePanel", self.onResultPanel, "ResultPanel_2")

    self:setCtrlVisible("GameResultPanel", true)
    self:setCtrlVisible("ResultPanel_1", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_3", false, "GameResultPanel")
    self:setCtrlVisible("BackPanel", false)

    local resultPanel = self:getControl("ResultPanel_1", nil, "GameResultPanel")
    -- self:bindListener("RewardImage", self.onRewardImage, self:getControl("GoldenPanel", nil, resultPanel))

    -- 当前手机角度
    self.baseX = 0
    self.baseY = 0

    -- 获取屏幕尺寸
    local winSize = cc.Director:getInstance():getWinSize()
    self.rootHeight = winSize.height / Const.UI_SCALE
    self.rootWidth = winSize.width / Const.UI_SCALE

    -- 加载背景图
    local dlgBack = ccui.ImageView:create(ResMgr.loadingPic.qipao)
    dlgBack:setPosition(self.rootWidth / 2, self.rootHeight / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    dlgBack:setTouchEnabled(true)
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)

    self.root:requestDoLayout()

    self.bubblePanel = self:getControl("BubblePanel")
    --self:setCtrlFullClient("BubblePanel")
    --self:setCtrlFullClient("BlackPanel", "StarPanel")
    --self:setCtrlFullClient("BlackPanel", "ResultPanel_1")
    --self:setCtrlFullClient("BlackPanel", "ResultPanel_2")
    --self:setCtrlFullClient("BlackPanel", "ResultPanel_3")
    self:setCtrlVisible("StarPanel", false)
    self.root:scheduleUpdateWithPriorityLua(function(deltaTime) if self.running then self:updateBubble(deltaTime) end end, 0)

    -- 创建气泡
    self.bubbles = {}
    local datas = param.bubbles
    for i = 1, #datas do
        self.bubbles[datas[i].gid] = self:createBubble(datas[i].gid, datas[i].type)
    end

    -- 倒计时
    local readyId
    local readyTime = param.ready_time - 1
    self:createCountDown(readyTime)
    self:startCountDown(readyTime, function()
        -- 开始计时
        self:showGameTime(true, param.game_time)
        self.running = true
    end)
    local numPanel = self:getControl("NumPanel", nil, "TimePanel")
    self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, param.game_time, false, LOCATE_POSITION.LEFT_TOP, 23)

    -- 初始化分数
    self:setBubbleNum("BluePanel", 0, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("PurplePanel", 0, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("GoldenPanel", 0, ART_FONT_COLOR.DEFAULT)
    local totalNumLabel = self:getControl("TotalNumLabel", Const.UIAtlasLabel)
    totalNumLabel:setString(tostring(0))

    self.lastClickTime = 0
    self.speedScale = 1
    self.costTime = 0

    -- 注册事件
    self:hookMsg("MSG_CHILD_DAY_2017_POKE")
    self:hookMsg("MSG_CHILD_DAY_2017_END")
    self:hookMsg("MSG_CHILD_DAY_2017_START")
    self:hookMsg("MSG_CHILD_DAY_2017_QUIT")
    self:hookMsg("MSG_CHILD_DAY_2017_REMOVE")
end

function ChildrenDayDlg:cleanup()
    self.running = nil
    self.bubbles = nil
    self.itemName = nil
    self.speedScale = nil
    self.lastClickTime = nil
    self.costTime = nil
    self.numImg = nil
end

-- 倒计时
function ChildrenDayDlg:showGameTime(isShow, value)
    local panel = self:getControl("TimePanel")
    panel:stopAllActions()

    if isShow and value then
        local startTime = gf:getTickCount()
        local totalTime = value;
        local numPanel = self:getControl("NumPanel", nil, panel)
        self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, value, false, LOCATE_POSITION.LEFT_TOP, 23)
        schedule(panel, function()
            local t = gf:getTickCount()
            value = math.max(totalTime - (t - startTime) / 1000, 0)
            if value <= 0 then panel:stopAllActions() end
            self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, value, false, LOCATE_POSITION.LEFT_TOP, 23)
        end, 1)
    end
end

-- 创建倒计时
function ChildrenDayDlg:createCountDown(time)
    local timePanel = self:getControl('NumPanel', nil, 'StarPanel')
    if timePanel then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', time, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        timePanel:addChild(self.numImg)
        self:setCtrlVisible('StarImage', false, 'StarPanel')
    end
end

-- 设置倒计时数字
function ChildrenDayDlg:startCountDown(time, callback)
    if not self.numImg then return end
    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("StarPanel", true)
    self.numImg:startCountDown(function()
        self:setCtrlVisible('StarImage', true, 'StarPanel')
        self.numImg:setVisible(false)
        performWithDelay(self.root, function()
            -- 1s后隐藏开始
            self:setCtrlVisible("StarPanel", false)
            if callback then callback() end
        end, 1)
    end)
end

-- 设置泡泡数量
function ChildrenDayDlg:setBubbleNum(name, num, col)
    local panel = self:getControl("NumPanel", nil, self:getControl(name, nil, "MainPanel"))
    self:setNumImgForPanel(panel, col, num, false, LOCATE_POSITION.LEFT_TOP, 23)
end

-- 生成泡泡
function ChildrenDayDlg:createBubble(gid, type)
    local scale = math.random(b_scale[1], b_scale[2]) / 10
    local bubble = self:createArmature(BUBBLE_ICON, BUBBLE_COLOR_ACTION[type])
    bubble.speed = cc.p(math.random(x_speed[1], x_speed[2]), scale * y_speed)
    bubble:setScale(scale, scale)
    bubble.scale = scale
    bubble.gid = tostring(gid)
    bubble.color = type
    self.bubblePanel:addChild(bubble)
    local function onTouch(touch, event)
        local rect = bubble:getBoundingBox()
        rect.width = radius * 2 * bubble.scale
        rect.height = radius * 2 * bubble.scale
        if event:getEventCode() == cc.EventCode.BEGAN then
            local pos = self.bubblePanel:convertTouchToNodeSpace(touch)
            return cc.rectContainsPoint(rect, pos)
        elseif event:getEventCode() == cc.EventCode.ENDED then
            local pos = self.bubblePanel:convertTouchToNodeSpace(touch)
            if cc.rectContainsPoint(rect, pos) then
                self:onClickBubble(bubble)
            end
            return false
        end
    end
    gf:bindTouchListener(bubble, onTouch, cc.Handler.EVENT_TOUCH_ENDED, false)

    -- 计算气泡位置
    local x
    local y
    local bb
    local fail
    local rect = bubble:getBoundingBox()
    repeat
        fail = nil
        x = math.random(rect.width / 2, self.rootWidth - rect.width / 2)
        y = math.random(0, self.rootHeight * 2 / 3)
        for j = 1, #self.bubbles do
            bb = self.bubbles[j]
            local bx, by = bb:getPosition()
            if (bx - x) * (bx - x) + (by - y) * (by - y) < b_dis * b_dis then
                fail = true
                break
            end
        end
    until fail == nil
    bubble:setPosition(x, y)

    return bubble
end

function ChildrenDayDlg:createArmature(icon, action)
    -- 先加载资源
    local path = string.format("animate/ui/%s.ExportJson", icon)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(path)
    local ob = ccs.Armature:create(icon)
    ob:getAnimation():play(action)
    return ob
end

-- 移除泡泡
function ChildrenDayDlg:removeBubble(bubble)
    bubble.speed = nil
    gf:CmdToServer("CMD_CHILD_DAY_2017_REMOVE", { gid = bubble.gid })
end

-- 重置泡泡数据
function ChildrenDayDlg:resetBubble(bubble, gid, type)
    if not bubble then return end
    bubble:setVisible(false)

    local x
    local y
    local bb
    local fail
    local retry
    local rect = bubble:getBoundingBox()
    local scale = math.random(b_scale[1], b_scale[2]) / 10

    local function calcPos()
        retry = 10
        repeat
            fail = nil
            x = math.random(math.max(rect.width / 2, radius) * scale, self.rootWidth - math.max(rect.width / 2, radius) * scale)
            -- x = self.rootWidth - math.max(rect.width / 2, radius) * scale
            y = math.random(b_born[1], b_born[2])
            for j = 1, #self.bubbles do
                bb = self.bubbles[j]
                if bb ~= bubble then
                    local bx, by = bb:getPosition()
                    if (bx - x) * (bx - x) + (by - y) * (by - y) < b_dis * b_dis then
                        fail = true
                        break
                    end
                end
            end
            retry = retry - 1
        until fail == nil or retry <= 0

        if fail then
            performWithDelay(self.root, function()
                self:resetBubble(bubble, gid, type)
            end, 0.1)
            return true
        end
    end

    if calcPos() then return end

    gid = gid or bubble.gid
    type = type or bubble.color

    bubble:setVisible(true)
    bubble.gid = tostring(gid)
    bubble.color = type
    bubble:getAnimation():play(BUBBLE_COLOR_ACTION[type])
    bubble.speed = cc.p(math.random(x_speed[1], x_speed[2]), y_speed * scale)
    bubble:setScale(scale, scale)
    bubble.scale = scale
    bubble:setPosition(x, y - scale * bubble:getContentSize().height / 2)
end

-- 更新气泡位置
function ChildrenDayDlg:updateBubble(deltaTime)
    self.costTime = self.costTime + deltaTime
    if self.costTime > speed_scale_time then
        self.costTime = self.costTime - speed_scale_time
        self.speedScale = self.speedScale + speed_scale_up
    end

    local bubble
    local x
    local y
    local sz
    local scale
    for _, v in pairs(self.bubbles) do
        bubble = v
        if bubble.speed then
            sz = bubble:getContentSize()
            scale = bubble.scale

            x, y = bubble:getPosition()
            x = x + bubble.speed.x * deltaTime
            y = y + bubble.speed.y * self.speedScale * deltaTime
            if y > self.rootHeight + sz.height * scale / 2 then
                -- self:resetBubble(bubble)
                self:removeBubble(bubble)
            elseif x < radius * scale or x > self.rootWidth - radius * scale then
                bubble.speed = cc.p(-bubble.speed.x, bubble.speed.y)
                x = math.min(math.max(x, radius * scale), self.rootWidth - radius * scale / 2)
                bubble:setPosition(x, y)
            else
                bubble:setPosition(x, y)
            end
        end
    end
end

-- 检查点击间隔
function ChildrenDayDlg:checkClickTime()
    local lastClickTime = self.lastClickTime or 0
    local curTime = gf:getTickCount()
    if curTime - lastClickTime < CLICK_INTERVAL then
        return false
    end

    return true
end

-- 气泡效果
function ChildrenDayDlg:playBubbleBreak(gid)
    local bubble = self.bubbles[gid]
    if not bubble then return end

    local x, y = bubble:getPosition()
    local magic
    magic = gf:createCallbackMagic(BUBBLE_COLOR_EFFECT[bubble.color], function(node)
        if magic then magic:removeFromParent(true) end
    end)
    magic:setScale(bubble.scale, bubble.scale)

    if magic then
        magic:setPosition(x, y)
        bubble:getParent():addChild(magic)
    end
    bubble:setVisible(false)
    bubble.speed = nil
end

-- 显示连击
function ChildrenDayDlg:showBattleCount(value)
    local hitPanel = self:getControl("HitPanel")
    if not hitPanel then return end
    hitPanel:setVisible(value > 0)
    hitPanel:stopAllActions()

    if value > 0 then
        local numPanel = self:getControl("NumPanel", nil, hitPanel)
        local numImg = self:setNumImgForPanel(numPanel, "bfight_num", value, false, LOCATE_POSITION.RIGHT_TOP, 25)
        numImg:setScale(0.64, 0.64)
        hitPanel:setScale(0.1, 0.1)
        hitPanel:setOpacity(255)
        local scale = cc.ScaleTo:create(0.1, 1)
        local dis = cc.FadeOut:create(1)
        local seq = cc.Sequence:create(scale, dis)
        hitPanel:runAction(seq)
    end
end

-- 点击泡泡
function ChildrenDayDlg:onClickBubble(bubble)
    if not self:checkClickTime() or not bubble:isVisible() then return end

    local gid = bubble.gid
    gf:CmdToServer('CMD_CHILD_DAY_2017_POKE', { gid = gid })


    -- 气泡破碎效果
    self:playBubbleBreak(gid)

    self.lastClickTime = gf:getTickCount()
end

-- 设置奖励(times<=3)
function ChildrenDayDlg:setBonus1(data)
    self:setCtrlVisible("BackPanel", true)
    self:setCtrlVisible("ResultPanel_1", true, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", false, "GameResultPanel")

    local resultPanel = self:getControl("ResultPanel_1", nil, "GameResultPanel")

    -- 设置星星
    for i = 1, 3 do
        if i <= data.star then
            self:setCtrlVisible(string.format("StarImage_%d", i), true, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        else
            self:setCtrlVisible(string.format("StarImage_%d", i), false, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        end
    end

    -- 历史最高分
    self:setLabelText("HighestNumLabel", string.format(CHS[2100077], data.highest_score), resultPanel)

    -- 当前分数
    local numPanel = self:getControl("NumPanel", nil, resultPanel)
    self:setNumImgForPanel(numPanel, "bfight_num", data.blue_score + data.gold_score + data.purple_score, false, LOCATE_POSITION.MID, 25)

    -- 蓝
    self:setLabelText("NumLabel_1", data.blue_score, self:getControl("BluePanel", nil, resultPanel))
    self:setLabelText("NumLabel_2", data.exp > 0 and data.exp or CHS[2100078], self:getControl("BluePanel", nil, resultPanel))

    -- 紫
    self:setLabelText("NumLabel_1", data.purple_score, self:getControl("PurplePanel", nil, resultPanel))
    self:setLabelText("NumLabel_2", data.tao > 0 and string.format(CHS[2100079], gf:getTaoStr(data.tao, 0)) or "无", self:getControl("PurplePanel", nil, resultPanel))

    -- 金
    self:setLabelText("NumLabel_1", data.gold_score, self:getControl("GoldenPanel", nil, resultPanel))
    if data.item and "" ~= data.item then
        self:setLabelText("NumLabel_2", string.format("%s*1", data.item), self:getControl("GoldenPanel", nil, resultPanel))
    else
        self:setLabelText("NumLabel_2", CHS[2100078], self:getControl("GoldenPanel", nil, resultPanel))
    end
    self.itemName = data.item
end

-- 设置奖励(times>3)
function ChildrenDayDlg:setBonus2(data)
    self:setCtrlVisible("BackPanel", true)
    self:setCtrlVisible("ResultPanel_1", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", true, "GameResultPanel")
    local resultPanel = self:getControl("ResultPanel_2", nil, "GameResultPanel")

    -- 设置星星
    for i = 1, 3 do
        if i <= data.star then
            self:setCtrlVisible(string.format("StarImage_%d", i), true, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        else
            self:setCtrlVisible(string.format("StarImage_%d", i), false, resultPanel)
            self:setCtrlVisible(string.format("NoStarImage_%d", i), true, resultPanel)
        end
    end

    -- 历史最高分
    self:setLabelText("HighestNumLabel", string.format(CHS[2100077], data.highest_score), resultPanel)

    -- 当前分数
    local numPanel = self:getControl("NumPanel", nil, resultPanel)
    self:setNumImgForPanel(numPanel, "bfight_num", data.blue_score + data.gold_score + data.purple_score, false, LOCATE_POSITION.MID, 25)

    -- 蓝
    self:setLabelText("NumLabel_1", data.blue_score, self:getControl("BluePanel", nil, resultPanel))

    -- 紫
    self:setLabelText("NumLabel_1", data.purple_score, self:getControl("PurplePanel", nil, resultPanel))

    -- 金
    self:setLabelText("NumLabel_1", data.gold_score, self:getControl("GoldenPanel", nil, resultPanel))
end

-- 暂停按钮
function ChildrenDayDlg:onPauseButton(sender, eventType)
    gf:CmdToServer('CMD_CHILD_DAY_2017_QUIT', { type = "request" })
end

-- 继续游戏
function ChildrenDayDlg:onResultPanel(sender, eventType)
    self:onCloseButton()
end

-- 道具
function ChildrenDayDlg:onRewardImage(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    if self.itemName and "" ~= self.itemName then
        InventoryMgr:showBasicMessageDlg(self.itemName, rect, true)
    else
        local dlg = DlgMgr:openDlg("BonusInfo2Dlg")
        dlg:setRewardInfo({["basicInfo"] = {CHS[2100080]}, ["imagePath"] = ResMgr.ui.item_common,["limted"] = false,["resType"] = 1,["time_limited"] = false})
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
    end
end

function ChildrenDayDlg:MSG_CHILD_DAY_2017_QUIT(data)
    self.running = data.type ~= "request"
    self:showGameTime(data.type ~= "request", data.left_time)

    if "request" == data.type then
        gf:confirmEx(CHS[2100081], CHS[2100082], function()
            -- 退出
            gf:CmdToServer('CMD_CHILD_DAY_2017_QUIT', { type = "confirm" })
        end, CHS[2100083], function()
            -- 继续
            gf:CmdToServer('CMD_CHILD_DAY_2017_QUIT', { type = "cancel" })
        end)
    end
end

function ChildrenDayDlg:MSG_CHILD_DAY_2017_START(data)
end

function ChildrenDayDlg:MSG_CHILD_DAY_2017_END(data)
    self.running = false
    self:showGameTime(false)

    if -1 == data.star then
        self:onCloseButton()
        return
    end

    if 1 == data.no_bonus then
        self:setBonus2(data)
    else
        self:setBonus1(data)
    end

    local numPanel = self:getControl("NumPanel", nil, "TimePanel")
    self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, 0, false, LOCATE_POSITION.LEFT_TOP, 23)
end

function ChildrenDayDlg:MSG_CHILD_DAY_2017_POKE(data)
    -- 设置分数
    self:setBubbleNum("BluePanel", data.blue_score, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("PurplePanel", data.purple_score, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("GoldenPanel", data.gold_score, ART_FONT_COLOR.DEFAULT)
    -- self:setNumImgForPanel("TotalNumPanel", "bfight_num", data.blue_score + data.gold_score + data.purple_score, false, LOCATE_POSITION.MID, 23, "MainPanel")
    local totalNumLabel = self:getControl("TotalNumLabel", Const.UIAtlasLabel)
    totalNumLabel:setString(tostring(data.blue_score + data.gold_score + data.purple_score))

    -- 设置连击
    if data.batter_count > 1 then
        self:showBattleCount(data.batter_count)
    end

    -- 重新生成气泡
    local bubble = self.bubbles[data.gid]
    if bubble then
        self:resetBubble(bubble, data.new_gid, data.new_type)
        self.bubbles[data.new_gid] = bubble
        self.bubbles[data.gid] = nil
    end
end

function ChildrenDayDlg:MSG_CHILD_DAY_2017_REMOVE(data)
    local bubble = self.bubbles[data.gid]
    if not bubble then return end
    self:resetBubble(bubble, data.new_gid, data.type)
    self.bubbles[data.new_gid] = bubble
    self.bubbles[data.gid] = nil
end

return ChildrenDayDlg