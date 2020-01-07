-- MidAutumnCakeDlg.lua
-- Created by huangzz July/11/2018
-- 真假月饼界面

local MidAutumnCakeDlg = Singleton("MidAutumnCakeDlg", Dialog)

local CAKE_POS = {
    cc.p(64,132) ,
    cc.p(264,132),
    cc.p(464,132),
    cc.p(134,217),
    cc.p(394,217),
    cc.p(134,47) ,
    cc.p(394,47) ,
    cc.p(94,217) ,
    cc.p(434,217),
    cc.p(94,47)  ,
    cc.p(434,47) ,
    cc.p(64,217) ,
    cc.p(264,217),
    cc.p(464,217),
    cc.p(64,47)  ,
    cc.p(264,47) ,
    cc.p(464,47) ,
}

-- 月饼每个关卡的初始位置
local CAKE_FIRST_INDEX = {
    {1, 2, 3},
    {4, 5, 6, 7},
    {2, 8, 9, 10, 11},
    {12, 13, 14, 15, 16, 17},
}

-- 月饼每个关卡移动次数
local MOVE_TIMES = {
    5, 7, 8, 8
}

-- 月饼每个关卡每次移动的时间间隔
local MOVE_INTERVAL = {
    1 / 3, 1 / 3.5, 1 / 3.5, 1 / 3.5
}

local MAX_STEP = 4

local MIN_SPACE = 100 -- 两个月饼间的最小间距


function MidAutumnCakeDlg:init()
    self:setCtrlFullClientEx("BackPanel", "ResultPanel")
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("CakeButton", self.onCakeButton)
    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("QuitButton", self.onCloseButton)
    self:bindListener("QuitButton2", self.onCloseButton)

    self.gamePanel = self:getControl("GamingPanel")
    self.gameSize = self.gamePanel:getContentSize()
    self.cakeButton = self:retainCtrl("CakeButton")

    self.step = 1
    self.cakes = {}
    self.canClickCake = false
    self.delayCloseDlg = nil

    self:setCtrlVisible("ResultPanel", false)

    self:hookMsg("MSG_AUTUMN_2018_GAME_START")
    self:hookMsg("MSG_AUTUMN_2018_GAME_FINISH")
end

function MidAutumnCakeDlg:cmdResult(result)
    local md5 = gfGetMd5(Me:queryBasic("gid") .. self.iid .. result)
    md5 = string.lower(md5)
    gf:CmdToServer("CMD_AUTUMN_2018_GAME_FINISH", {result = md5})
end

function MidAutumnCakeDlg:onStartButton(sender, eventType)
    gf:CmdToServer("CMD_AUTUMN_2018_GAME_START", {step = self.step})
end

function MidAutumnCakeDlg:onCakeButton(sender, eventType)
    if not self.canClickCake then
        return
    end

    self.canClickCake = false
    self:setCakeButtonEnabled(false)
    if sender.isReal then
        gf:ShowSmallTips(CHS[5450288])
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.midautumn_real_cake.name, "Top", sender, function()
            self:setCakesFadeOut(function()
                self:cmdResult("succ")
                if self.step < MAX_STEP then
                    gf:CmdToServer("CMD_AUTUMN_2018_GAME_START", {step = self.step + 1})
                end
            end)
        end)
    else
        self:shakeCake(sender, function()
            self:setCakesFadeOut(function()
                self:cmdResult("fail")
                self:showResult(false)
            end)
        end)
    end
end

function MidAutumnCakeDlg:setCakesFadeOut(callbcak)
    for i = 1, #self.cakes do
        local action
        if callbcak and i == 1 then
            action = cc.Sequence:create(
                cc.FadeOut:create(0.5),
                cc.CallFunc:create(function()
                    callbcak()
                end)
            )
        else
            action = cc.FadeOut:create(0.5)
        end

        self.cakes[i]:runAction(action)
    end
end

-- 月饼抖动效果
function MidAutumnCakeDlg:shakeCake(cake, callbcak)
    local x, y = cake:getPosition()
    local action = cc.Sequence:create(
        cc.MoveTo:create(0.04, {x = x + 5, y = y + 7}),
        cc.MoveTo:create(0.04, {x = x, y = y}),
        cc.MoveTo:create(0.04, {x = x - 7, y = y - 5}),
        cc.MoveTo:create(0.04, {x = x, y = y}),
        cc.MoveTo:create(0.04, {x = x + 5, y = y + 9}),
        cc.MoveTo:create(0.04, {x = x, y = y}),
        cc.CallFunc:create(function()
            callbcak()
        end)
    )

    cake:runAction(action)
end

function MidAutumnCakeDlg:onRestartButton(sender, eventType)
    gf:CmdToServer("CMD_AUTUMN_2018_GAME_START", {step = self.step})
end

function MidAutumnCakeDlg:initGame(data)
    self.step = data.step
    self.iid = data.iid

    -- 移除上一关的月饼
    for i = 1, #self.cakes do
        self.cakes[i]:removeFromParent()
    end

    self.cakes = {}

    local indexs = CAKE_FIRST_INDEX[self.step]
    for i = 1, #indexs do
        local pos = CAKE_POS[indexs[i]]
        local cake = self.cakeButton:clone()
        cake:setOpacity(0)
        cake:setPosition(pos.x, pos.y)

        self.gamePanel:addChild(cake)

        cake:runAction(cc.FadeIn:create(0.5))
        table.insert(self.cakes, cake)
    end

    self:setCakeButtonEnabled(false)

    performWithDelay(self.cakes[1], function()
        self:showRealCake()
    end, 0.5)

    self:setCtrlVisible("StartPanel", false)
    self:setCtrlVisible("ResultPanel", false)

    self:setLabelText("TimeLabel", string.format(CHS[5450283], self.step - 1), "GamingPanel")

    if not self.delayCloseDlg then
        local lastTime = math.max(data.end_time - gf:getServerTime(), 0)
        self.delayCloseDlg = performWithDelay(self.root, function()
            -- 活动结束
            gf:ShowSmallTips(CHS[5400612])
            self:onCloseButton()
        end, lastTime)
    end
end

function MidAutumnCakeDlg:showRealCake()
    local num = math.random(1, #self.cakes)
    self.cakes[num].isReal = true

    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.midautumn_real_cake.name, "Top", self.cakes[num], function()
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.midautumn_real_cake.name, "Top", self.cakes[num], function()
            self:doMoveAction(MOVE_TIMES[self.step])
        end)
    end)
end

function MidAutumnCakeDlg:setCakeButtonEnabled(enabled)
    for i = 1, #self.cakes do
        self.cakes[i]:setTouchEnabled(enabled)
    end
end

function MidAutumnCakeDlg:doMoveAction(times)
    if times == 0 then
        self:setCakeButtonEnabled(true)
        self.canClickCake = true
        return
    end

    local destPos = {}
    local count = #self.cakes
    local size = self.gameSize
    if times == 1 then
        -- 最后一次移动要回到配置位置
        local indexs = CAKE_FIRST_INDEX[self.step]
        for i = 1, count do
            local pos = CAKE_POS[indexs[i]]
            repeat
                local index = math.random(1, count)
                if not destPos[index] then
                    destPos[index] = pos
                    break
                end
            until false
        end
    else
        -- 随机取下一次移动位置
        for i = 1, count do
            local curCake = self.cakes[i]
            local count = 0
            local x, y = self.cakes[i]:getPosition()
            local isFaild
            repeat
                x = math.random(0, size.width)
                y = math.random(0, size.height)
                isFaild = false
                for j = 1, i - 1 do
                    local x2, y2 = destPos
                    if gf:distance(x, y, destPos[j].x, destPos[j].y) < MIN_SPACE then
                        isFaild = true
                    end
                end

                count = count + 1
            until count >= 50 or not isFaild

            if isFaild then
                -- 随机取不到，尽量取一点较空旷的点
                local info = gf:deepCopy(destPos)
                table.insert(info, {x = 0, y = 0})
                table.insert(info, {x = size.width, y = size.height})

                local cou = #info
                table.sort(info, function(l, r) return l.x < r.x end)

                local maxDis = 0
                for j = 2, cou do
                    local dis = info[j].x - info[j - 1].x
                    if maxDis < dis then
                        maxDis = dis
                        x = dis / 2 + info[j - 1].x
                    end
                end

                y = math.random(0, size.height)
            end

            table.insert(destPos, {x = x, y = y})
        end
    end

    local interval = MOVE_INTERVAL[self.step]
    for i = 1, count do
        local curCake = self.cakes[i]
        local action
        if i == count then
            action = cc.Sequence:create(
                cc.MoveTo:create(interval, destPos[i]),
                cc.CallFunc:create(function()
                    self:doMoveAction(times - 1)
                end)
            )
        else
            action = cc.MoveTo:create(interval, destPos[i])
        end

        curCake:stopAllActions()
        curCake:runAction(action)
    end
end

function MidAutumnCakeDlg:onDlgOpened(param)
    if not param or not param[1] then
        return
    end

    self.step = tonumber(param[1])
end

function MidAutumnCakeDlg:MSG_AUTUMN_2018_GAME_START(data)
    self:initGame(data)
end

function MidAutumnCakeDlg:showResult(isSucc, data)
    self:setCtrlVisible("ResultPanel", true)
    self:setCtrlVisible("SuccPanel", isSucc, "ResultPanel_1")
    self:setCtrlVisible("QuitButton", isSucc, "ResultPanel")

    self:setCtrlVisible("FailPanel", not isSucc, "ResultPanel_1")
    self:setCtrlVisible("RestartButton", not isSucc, "ResultPanel")
    self:setCtrlVisible("QuitButton2", not isSucc, "ResultPanel")

    if data then
        self:setLabelText("NumLabel", data.exp, self:getControl("ExpPanel", nil, "ResultPanel_1"))
        self:setLabelText("NumLabel", string.format(CHS[2100079], gf:getTaoStr(data.tao, 0)), self:getControl("TaoPanel", nil, "ResultPanel_1"))
        self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[2000120]), self:getControl("ItemPanel", nil, "ResultPanel_1"))
    end
end

function MidAutumnCakeDlg:MSG_AUTUMN_2018_GAME_FINISH(data)
    self:setLabelText("TimeLabel", string.format(CHS[5450283], self.step), "GamingPanel")
    self:showResult(true, data)
end

function MidAutumnCakeDlg:cleanup()
    gf:CmdToServer("CMD_AUTUMN_2018_GAME_FINISH", {result = ""})
end

return MidAutumnCakeDlg
