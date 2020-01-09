-- VacationWhiteDlg.lua
-- Created by songcw Aug/31/2018
-- 踩雪块界面

-- 相关说明：
-- 该小游戏由横屏转为竖屏游戏，将 root 下相关游戏显示的 panel 设置对应的尺寸（由于竖屏，长宽调换）
-- 该游戏下，部分 panel 需要根据屏幕尺寸全屏（完美全屏，不能超出或者太短），游戏区域需要以高度适配，所以采用setContentSize将各个panel设置为屏幕尺寸大小

local VacationWhiteDlg = Singleton("VacationWhiteDlg", Dialog)

local SCORE_MAX = 1999
local NORMAL_SPEED = 300

local GAME_STATE = {
    READY           = 0,
    RUNNING         = 1,
    OVER            = 2,
    PAUSE           = 3,
}

function VacationWhiteDlg:init(data)

    CharMgr:doCharHideStatus(Me)

    -- 设置旋转
    self.root:setRotation(-90)

    SmallTipsMgr:setRotation(-90)

    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("StartButton", self.onStartButton)

    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_1")
    self:bindListener("CloseImage", self.onCloseImage, "ResultPanel_2")

    self.oneStepPanel = self:retainCtrl("WhitePanel")
    for i = 1, 4 do
        local image = self:getControl("SnowImage" .. i, nil, self.oneStepPanel)
        image:setOpacity(0)
        image:setVisible(true)
        self:bindTouchEventListener(image, self.onClickSnow)
        self:setCtrlVisible(string.format("Step%dPanel", i), false)
    end

    self.bkImage = self:retainCtrl("BKImage")

    self:setAllFullScreen()

    self:resetGame()

    self:setCtrlVisible("StartPanel", true)
    self:setCtrlVisible("GameResultPanel", false)

    self:hookMsg("MSG_CXK_START_GAME_2019")
    self:hookMsg("MSG_CXK_BONUS_INFO_2019")

    if data then
        self:MSG_CXK_START_GAME_2019(data)
    end
end

-- 全屏
function VacationWhiteDlg:setAllFullScreen()

  --  self:setFullScreen()
    -- 由于旋转了，所以宽高调换下
    local height = self.blank:getContentSize().height
    local width = self.blank:getContentSize().width
    local orgSie = self.root:getContentSize()
    self.scale = height / orgSie.width

    local function setFullAndCent(panelName)
        local mainPanel = self:getControl(panelName)
        mainPanel:setContentSize(height, width)
        mainPanel:requestDoLayout()
    end

    setFullAndCent("MainPanel")
    setFullAndCent("BKPanel")
    setFullAndCent("StartPanel")
    setFullAndCent("GameResultPanel")


    self.bkImage:setContentSize(orgSie.width * self.scale, orgSie.height * self.scale)
    self.root:setPosition(width * 0.5, height * 0.5)

    for i = 1, 4 do
        local image = self:getControl("SnowImage" .. i, nil, self.oneStepPanel)
        image:setContentSize(image:getContentSize().width * self.scale, image:getContentSize().height * self.scale)
    end
    self.oneStepPanel:setContentSize(self.oneStepPanel:getContentSize().width * self.scale, self.oneStepPanel:getContentSize().height * self.scale)
end


function VacationWhiteDlg:cleanup()
    SmallTipsMgr:setRotation()

    self.bonusData = nil
    gf:closeConfirmByType("VacationWhiteDlg")

    CharMgr:doCharHideStatus(Me)
    Me:setVisible(true)
end

function VacationWhiteDlg:resetGame()
    self.bkImageList = {}
    self.clickWithList = {}
    self.dirty = false
    self.score = 0
    self.gameState = GAME_STATE.READY
    self.pauseTickCount = 0

    self:initDisplay()
end

function VacationWhiteDlg:getSpeed()

    if self.score <= 20 then
        return NORMAL_SPEED + self.score * 8
    elseif self.score <= 100 then
        return NORMAL_SPEED + 20 * 8 + (self.score - 20) * 3
    elseif self.score <= 250 then
        return NORMAL_SPEED + 20 * 8 + 80 * 3 + math.floor( (self.score - 100) * 1 )
    elseif self.score <= 400 then
        return NORMAL_SPEED + 20 * 8 + 80 * 3 + 150  + math.floor( (self.score - 250) / 2 )
    else
        return NORMAL_SPEED + 20 * 8 + 80 * 3 + 150 + 75 + math.floor( (self.score - 400) / 3 )
    end

    return NORMAL_SPEED
end

function VacationWhiteDlg:onUpdate()
    if not self.dirty then return end
    if self.gameState ~= GAME_STATE.RUNNING then return end

    local speed = self:getSpeed()

    local curTi = gfGetTickCount()
    local disTime = curTi - self.lastMoveCount - self.pauseTickCount
    self.lastMoveCount = gfGetTickCount()
    self.pauseTickCount = 0

    local movePosY = disTime / 1000 * speed

    -- 雪块的移动
    local clickImageIsMoveOut = false
    for i = 1, #self.clickWithList do
        local image = self.clickWithList[i]
        local posY = image:getPositionY()
        image:setPositionY(posY - movePosY)

        if i == 1 and image:getPositionY() < -image:getContentSize().height then
            clickImageIsMoveOut = true
        end
    end

    -- 雪块超出屏幕了
    if clickImageIsMoveOut then

        -- 有未点击的，游戏结束
        if not self.clickWithList[1].isClick then
            self:gameOver()
            return
        end


        self.clickWithList[1]:removeFromParent()
        table.remove(self.clickWithList, 1)

        -- 增加一个雪块
        local max = #self.clickWithList
        local lastestPanel = self.clickWithList[max]
        if lastestPanel and lastestPanel:getTag() >= SCORE_MAX then
            -- 达到上限不要增加
        else
            local panel = self.oneStepPanel:clone()
            panel:setTag(lastestPanel:getTag() + 1)
            self:randomCanClick(panel)
            panel:setPositionY(self.clickWithList[max]:getPositionY() + panel:getContentSize().height + 2)
            local mainPanel = self:getControl("MainPanel")
            mainPanel:addChild(panel)
            table.insert(self.clickWithList, panel)
        end
    end

        local bkIsMoveOut = false
    -- 移动
    for i = 1, #self.bkImageList do
        local image = self.bkImageList[i]
        local posY = image:getPositionY()
        image:setPositionY(posY - movePosY)

        if i == 1 and image:getPositionY() < -image:getContentSize().height * 0.5 then
            bkIsMoveOut = true
        end
    end

    -- 如果有一个离开屏幕了，移除并且再加以个
    if bkIsMoveOut then
        self.bkImageList[1]:removeFromParent()
        table.remove(self.bkImageList, 1)
        local max = #self.bkImageList
        local image = self.bkImage:clone()
        image:setPositionY(self.bkImageList[max]:getPositionY() + image:getContentSize().height)
        image:setPosition(image:getContentSize().width * 0.5, self.bkImageList[max]:getPositionY() + image:getContentSize().height)


        local mainPanel = self:getControl("MainPanel")
        mainPanel:addChild(image)
        table.insert(self.bkImageList, image)
    end
end

function VacationWhiteDlg:initDisplay()
    local mainPanel = self:getControl("MainPanel")
    mainPanel:removeAllChildren()

    self:setCtrlVisible("CurScorePanel", true)
    self:setCurScore(0)

    for i = 1, 3 do
        local bkImage = self.bkImage:clone()

        bkImage:setPosition(bkImage:getContentSize().width * 0.5, bkImage:getContentSize().height * 0.5 + (i - 1) * bkImage:getContentSize().height)

        mainPanel:addChild(bkImage)
        table.insert(self.bkImageList, bkImage)
    end


--[[
    local bkImage2 = self.bkImage:clone()
    bkImage2:setPositionY(bkImage:getPositionY() + bkImage:getContentSize().height)
    mainPanel:addChild(bkImage2)
    table.insert(self.bkImageList, bkImage2)
    --]]
--
    for i = 1, 10 do
        local panel = self.oneStepPanel:clone()
        panel:setTag(i)
        self:randomCanClick(panel, i)
        panel:setPositionY((i - 1) * (panel:getContentSize().height + 2))
        mainPanel:addChild(panel)
        table.insert(self.clickWithList, panel)
    end

  --]]
end

function VacationWhiteDlg:randomCanClick(panel, step)

    local canClickNum = math.random(1, 4)
    self:setCtrlVisible("SnowImage" .. canClickNum, true, panel)

    local image = self:getControl("SnowImage" .. canClickNum, nil, panel)
    image:setOpacity(255)


    if step and step <= 3 then
        local panel = self:getControl(string.format( "Step%dPanel", step)):clone()
        panel:setVisible(true)
        image:addChild(panel)
    end
end

function VacationWhiteDlg:enterBackground()
    if self.gameState ~= GAME_STATE.RUNNING then return end

    self:onPauseButton()
end

function VacationWhiteDlg:onPauseButton(sender, eventType)
    if self.gameState ~= GAME_STATE.RUNNING then
        gf:confirmEx(CHS[4101198], CHS[4101190], function ()
            gf:CmdToServer("CMD_CXK_FINISH_GAME_2019", {des = "", isQuit = 1})
            self:onCloseButton()
        end, CHS[4101191], function ()

        end, nil, nil, nil, nil, nil , "VacationWhiteDlg")
    else

        if self.gameState == GAME_STATE.PAUSE then return end


        gf:CmdToServer("CMD_CXK_START_GAME_2019", {oper = 0})
        self.pauseTickCount = gfGetTickCount()
        self.gameState = GAME_STATE.PAUSE
        gf:confirmEx(CHS[4101199], CHS[4101190], function ()
            local str = gfEncrypt(tostring(self.score), self.cookie)
            gf:CmdToServer("CMD_CXK_FINISH_GAME_2019", {des = str, isQuit = 1})
            self:onCloseButton()
        end, CHS[4101191], function ()
            self.pauseTickCount = gfGetTickCount() - self.pauseTickCount
            self.gameState = GAME_STATE.RUNNING
            gf:CmdToServer("CMD_CXK_START_GAME_2019", {oper = 1})
        end, nil, nil, nil, nil, nil , "VacationWhiteDlg")
    end
end

function VacationWhiteDlg:onClickSnow(sender, eventType)
    if self.gameState == GAME_STATE.OVER then return end

    -- 效验是不是可以点击的
    local checkNum = sender:getParent():getTag()
    if checkNum ~= (self.score + 1) then
        return
    end

    -- 第一步并且是显示的，则开始
    if self.score == 0 and sender:getOpacity() == 255 then
        gf:CmdToServer("CMD_CXK_START_GAME_2019", {oper = 1})
    end

    -- 透明度为0的时不可点击的
    if sender:getOpacity() == 0 then
        if self.score ~= 0 then
            -- 点击到其他格子了，输了
            self:gameOver(sender)
            return
        else
            -- 还没开始不用管
            return
        end
    end

    -- 点击后透明度设置为一半一半
    --sender:setOpacity(127)
    sender:loadTexture(ResMgr.ui.VacationWhiteDlgClick)
    sender:removeAllChildren()

    -- 得分 + 1
    self.score = self.score + 1
    self:setCurScore(self.score)



    -- 标记点击过
    sender:getParent().isClick = true

    if self.score == SCORE_MAX then
        self:gameOver(nil, true)
    end
end

function VacationWhiteDlg:setCurScore(score)
    local numImg = self:setNumImgForPanel("CurScorePanel", ART_FONT_COLOR.B_FIGHT, score, false, LOCATE_POSITION.MID, 23)
    numImg:setScale(0.62)
end

-- 参数 sender 为nil 表示没有点击到输，如果有，则表示点击错误输了
function VacationWhiteDlg:gameOver(sender, isMax)
    self.dirty = false
    self.gameState = GAME_STATE.OVER

    --  达到最大不处理
    if isMax then
        local str = gfEncrypt(tostring(self.score), self.cookie)
        gf:CmdToServer("CMD_CXK_FINISH_GAME_2019", {des = str, isQuit = 0})
        return
    end

    -- 判断当前点击的是否已经超出屏幕（没有完全超出也算）
    local isOutScreen = false
    if sender then
        local panel = sender:getParent()
        if panel:getPositionY() < 0 then
            isOutScreen = panel:getPositionY()
        end
    else
        -- 寻找出该点击的，赋值给sender，需要播放一下效果
        for i = 1, #self.clickWithList do
            local panel = self.clickWithList[i]
            if panel:getTag() == (self.score + 1) and panel:getPositionY() < 0 then
                isOutScreen = panel:getPositionY()
                for j = 1, 4 do
                    local image = self:getControl("SnowImage" .. j, nil, panel)
                    if image:getOpacity() == 255 then
                        sender = image
                    end
                end
            end
        end
    end

    -- 如果没有sender 肯定有问题，容错
    if not sender then return end

    local function setActions(image)
        image:setOpacity(255)
        image:setColor(COLOR3.RED)
        local blinkAct = cc.Blink:create(0.5, 3)

        local callBackCmd = cc.CallFunc:create(function()
            image:setVisible(true)
            local str = gfEncrypt(tostring(self.score), self.cookie)
            gf:CmdToServer("CMD_CXK_FINISH_GAME_2019", {des = str, isQuit = 0})
        end)

        local action = cc.Sequence:create(blinkAct, callBackCmd)
        image:runAction(action)
    end

    if isOutScreen then
        for i = 1, #self.clickWithList do
            local panel = self.clickWithList[i]
            local moveAct = cc.MoveBy:create(0.2, cc.p(0, -isOutScreen))
            local callBack = cc.CallFunc:create(function()
                if sender:getParent():getTag() == panel:getTag() then
                    setActions(sender)
                end
            end)

            local action = cc.Sequence:create(moveAct, callBack)
            panel:runAction(action)
        end

        -- 移动
        for i = 1, #self.bkImageList do
            local image = self.bkImageList[i]
            local moveAct = cc.MoveBy:create(0.2, cc.p(0, -isOutScreen - 12))
            image:runAction(moveAct)
        end
    else
        setActions(sender)
    end
end

function VacationWhiteDlg:startGame()
    self.dirty = true
    self.gameState = GAME_STATE.RUNNING
    self.lastMoveCount = gfGetTickCount()
end


function VacationWhiteDlg:onCloseImage(sender, eventType)

    if self.bonusData and self.bonusData.flag == 1 then
        gf:CmdToServer("CMD_CXK_FINISH_GAME_2019", {des = "", isQuit = 1})
        self:onCloseButton()
    else
        self:resetGame()
        self:onStartButton()
    end
end

function VacationWhiteDlg:onStartButton(sender, eventType)
    self:setCtrlVisible("StartPanel", false)
    self:setCtrlVisible("GameResultPanel", false)
end

function VacationWhiteDlg:MSG_CXK_START_GAME_2019(data)
    self.cookie = data.cookie

    if data.flag == 1 then
        self:startGame()
    end
end

function VacationWhiteDlg:getStarLevelByScore(score)
    if score < 20 then return 0 end
    if score < 80 then return 1 end
    if score < 150 then return 2 end

    return 3
end

function VacationWhiteDlg:MSG_CXK_BONUS_INFO_2019(data)
    self:setCtrlVisible("GameResultPanel", true)
    self:setCtrlVisible("CurScorePanel", false)
    self:setCtrlVisible("ResultPanel_1", data.flag == 1, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", data.flag == 0, "GameResultPanel")

    local resultPanel
    if data.flag == 1 then
        local expPanel = self:getControl("ExpPanel", nil, "ResultPanel_1")
        self:setLabelText("NumLabel", data.exp, expPanel)

        local taoPanel = self:getControl("TaoPanel", nil, "ResultPanel_1")
        self:setLabelText("NumLabel", gf:getTaoStr(data.tao) .. CHS[4100702], taoPanel)

        local getItem = data.item ~= "" and data.item or CHS[5000059]
        local itemPanel = self:getControl("ItemPanel", nil, "ResultPanel_1")
        self:setLabelText("NumLabel_2", getItem, itemPanel)

        resultPanel = self:getControl("ResultPanel_1")

    else
        resultPanel = self:getControl("ResultPanel_2")

    end

    local sPanel = self:getControl("ScorePanel", nil, resultPanel)
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.B_FIGHT, data.score, false, LOCATE_POSITION.MID, 23, sPanel)

    self:setLabelText("HighestNumLabel", string.format(CHS[4101200],  data.highScore), resultPanel)

    local starLevel = self:getStarLevelByScore(data.score)
    for i = 1, 3 do
        self:setCtrlVisible("StarImage_" .. i, i <= starLevel, resultPanel)
    end


    self.bonusData = data
end


return VacationWhiteDlg
