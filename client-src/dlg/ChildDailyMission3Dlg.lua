-- ChildDailyMission3Dlg.lua
-- Created by songcw April/10/2019
-- 娃娃日常-动物的偏移

local ChildDailyMission3Dlg = Singleton("ChildDailyMission3Dlg", Dialog)

local WALK_START_POINT = cc.p(32, 28)

-- 初始化时设置
local WALK_POINT = {

}

local SNAKE_POINT = {

}

local CHILD_POS = cc.p(42, 30)
local CHAR_POS = cc.p(30, 22)

local DIR = {
    LU  = 1,    -- 左上 left up
    LD  = 2,    -- 左下 left down
    RU  = 3,    -- 右上
    RD  = 4,    -- 右下
}

local MAX_COUNT = 12

local TALKS = {CHS[4101557], CHS[4101556], CHS[4101555], CHS[4101554]}

function ChildDailyMission3Dlg:init(data)
    self:setFullScreen()
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("QuiteButton", self.onQuiteButton)

    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("LeftButton", false)
    self:setCtrlVisible("RightButton", false)

    self.objectList = {}
    self.bodyList = {}
    self.data = data
    self.isOver = false

    self:updateScore()

    self:addFightBg()

    self:initSnakies()

    self:initWalkPoint()

    self:initChar()


    -- 隐藏主界面相关操作
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1 })

    self:hookMsg("MSG_CHILD_GAME_SCORE")
end



function ChildDailyMission3Dlg:onQuiteButton()
        DlgMgr:closeDlg(self.name)

        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
end

function ChildDailyMission3Dlg:onCloseButton()

    if self:getCtrlVisible("ResultPanel") then
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
        return
    end

    gf:confirm(CHS[4101499], function ()
      --  self:onCloseButton()
        DlgMgr:closeDlg(self.name)

        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    end)
end

function ChildDailyMission3Dlg:initChar()
    local info = {icon = self.data.child_icon, name = self.data.child_name, dir = 1}
    self.child = self:createChar(info, CHILD_POS)
    self.child.noX = CHILD_POS.x
    self.child.noY = CHILD_POS.y
    table.insert( self.bodyList, self.child)

    local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), dir = 5}
    self.char = self:createChar(info, CHAR_POS)
end

function ChildDailyMission3Dlg:getNextPosByDir(dir, pos)
    local curX = pos and pos.x or self.child.noX
    local curY = pos and pos.y or self.child.noY

    dir = dir or self.dir

    if dir == DIR.LD then
        curX = curX - 2
        curY = curY + 2
    elseif dir == DIR.RU then
        curX = curX + 2
        curY = curY - 2
    elseif dir == DIR.LU then
        curX = curX - 2
        curY = curY - 2
    elseif dir == DIR.RD then
        curX = curX + 2
        curY = curY + 2
    end

    return cc.p(curX, curY)
end

function ChildDailyMission3Dlg:onUpdate()
    if self.objectList then
        for _, char in pairs(self.objectList) do
            char:update()
        end
    end

    if self.child then
        self.child:update()
    end
end

function ChildDailyMission3Dlg:initWalkPoint()
    WALK_POINT = {}

    if not self.grass then self.grass = {} end
    local function createPoint(startPos, paraX, paraY)
        for i = 1, 6 do
            local pos = cc.p(startPos.x + (i - 1) * paraX, startPos.y + (i - 1) * paraY)
            table.insert( WALK_POINT, pos)

            local npcSprite = cc.Sprite:create(ResMgr.ui.gress)
            local x, y = gf:convertToClientSpace(pos.x, pos.y)
            npcSprite:setPosition(x, y)
            gf:getMapLayer():addChild(npcSprite)

            table.insert( self.grass, npcSprite )
        end
    end

    createPoint(WALK_START_POINT, 2, -2)

    local pos = cc.p(WALK_START_POINT.x + 2, WALK_START_POINT.y + 2)
    createPoint(pos, 2, -2)

    pos = cc.p(pos.x + 2, pos.y + 2)
    createPoint(pos, 2, -2)

    pos = cc.p(pos.x + 2, pos.y + 2)
    createPoint(pos, 2, -2)

    pos = cc.p(pos.x + 2, pos.y + 2)
    createPoint(pos, 2, -2)

    pos = cc.p(pos.x + 2, pos.y + 2)
    createPoint(pos, 2, -2)


    --[[
    for i = 1, #WALK_POINT do
        local ran = math.random( 1, 2 )
        local info
        if ran == 1 then
            info = {icon = 6166, name = ""}
        else
            info = {icon = 6165, name = ""}
        end
        local snake = self:createChar(info, WALK_POINT[i])
        table.insert(self.objectList, snake)
    end
    --]]
end

-- 创建角色
function ChildDailyMission3Dlg:createChar(info, pos)
    local char = require("obj/activityObj/ChildDwdpyNpc").new()
    char:absorbBasicFields({
        icon = info.icon,
        name = info.name or "",
        dir = info.dir or 5,
    })

    char:onEnterScene(pos.x, pos.y)
    char:setAct(Const.FA_STAND)
    return char
end

-- 初始化蛇
function ChildDailyMission3Dlg:initSnakies()
    SNAKE_POINT = {}
    if not self.bigGrass then self.bigGrass = {} end
    local function createSnakies(startPos, paraX, paraY, dir)
        for i = 1, 6 do
            local pos = cc.p(startPos.x + (i - 1) * paraX, startPos.y + (i - 1) * paraY)
            local info = {icon = 6102, name = "", dir = dir}
            local snake = self:createChar(info, pos)
            snake.pos_no = #SNAKE_POINT
            table.insert(self.objectList, snake)

            table.insert(SNAKE_POINT, pos)
            snake:setVisible(false)

--[[
            local npcSprite = cc.Sprite:create(ResMgr.ui.gress)
            local x, y = gf:convertToClientSpace(pos.x, pos.y)
            npcSprite:setPosition(x, y)
            gf:getMapLayer():addChild(npcSprite)

            npcSprite:setScale(1.4)

            table.insert( self.bigGrass, npcSprite )
--]]
        end
    end

    createSnakies(cc.p(30, 26), 2, -2, 5)--
    createSnakies(cc.p(44, 16), 2, 2, 7)
    createSnakies(cc.p(54, 30), -2, 2, 1)
    createSnakies(cc.p(40, 40), -2, -2, 3)--
--[[
    Log:D("   ")
    Log:D("   ")
    gf:PrintMap(SNAKE_POINT)
    --]]
end


function ChildDailyMission3Dlg:onStartButton(sender, eventType)
    sender:setVisible(false)
    self:setCtrlVisible("ControlPanel", true)

    self:setCtrlVisible("LeftButton", true)
    self:setCtrlVisible("RightButton", true)

    self.dir = DIR.LU
    self.tobeDir = nil
    performWithDelay(self.root, function ( )
        self:startRun()
        self:bornAnimal()
    end,0.5)
end

-- 检测是否输了
function ChildDailyMission3Dlg:isLoseGame()
    local isLose = false
    for _, pos in pairs(SNAKE_POINT) do
        if pos.x == self.child.noX and pos.y == self.child.noY then
            isLose = true


            --
            local char = self.objectList[_]
            char:setVisible(true)
            char.charAction:playActionOnce(function ( )

            end)

                    --animal:setAct(Const.FA_ACTION_PHYSICAL_ATTACK)
        end
    end

    local dir = nil
    if self.dir == DIR.LD then
        dir = 3
    elseif self.dir == DIR.LU then
        dir = 5
    elseif self.dir == DIR.RD then
        dir = 1
    elseif self.dir == DIR.RU then
        dir = 7
    end

    if self.snake1 and self.snake1.noX == self.child.noX and self.snake1.noY == self.child.noY then
        isLose = true


        self.snake1:setDir(dir)
        self.snake1.charAction:playActionOnce(function ( )

        end)
    end

    if self.snake2 and self.snake2.noX == self.child.noX and self.snake2.noY == self.child.noY then
        isLose = true
        self.snake2:setDir(dir)
        self.snake2.charAction:playActionOnce(function ( )

        end)
    end

    for i = 2, #self.bodyList do
        local pos = self.bodyList[i]
        if pos.noX == self.child.noX and pos.noY == self.child.noY then
            isLose = true
        end
    end

    if isLose then
        self.child:setAct(Const.FA_STAND)
        self.child:setActAndCB(Const.FA_DIE_NOW)
    end

    return isLose
end

function ChildDailyMission3Dlg:allsnakeDie()
    for _, pos in pairs(SNAKE_POINT) do
        self.objectList[_]:doDiedAction()
    end

    if self.snake1 then
        self.snake1:doDiedAction()
    end

    if self.snake2 then
        self.snake2:doDiedAction()
    end


    if self.bigGrass then
        for _, sp in pairs(self.bigGrass) do
            sp:removeFromParent()
        end

        self.bigGrass = nil
    end
end

-- 检测是否吃到小动物
function ChildDailyMission3Dlg:getAnimal()
    local animal = self.objectList[#self.objectList]
    if animal.noX == self.child.noX and animal.noY == self.child.noY then

        animal:addMagicOnWaist(ResMgr.magic.grey_fog, false)

        table.insert( self.bodyList, animal )
        animal.charAction:setScale(0.7)

        local x, y = gf:convertToClientSpace(self.lastPos.x, self.lastPos.y)
        animal:setPos(x, y)

        if MAX_COUNT == #self.bodyList - 1 then
            self.dir = nil
            self.tobeDir = nil
               -- 魔法攻击
               self.child:setAct(Const.FA_STAND)
                self.child:setAct(Const.FA_ACTION_CAST_MAGIC, function()
                    self.child:setAct(Const.FA_ACTION_CAST_MAGIC_END, function()
                        self.child:setAct(Const.FA_STAND)
                        self.child:playYanhua()
                     --   self:allsnakeDie()

                        performWithDelay(self.root, function ( )
                            self:gameOver()
                        end, 1)
                    end)
                end)
            return
        end

        self:bornAnimal()

        for _, char in pairs(self.bodyList) do
            char:addSpeed()
        end

        self:updateScore()

    end
end

function ChildDailyMission3Dlg:startRun()
    if not self.dir then
        return
    end

    local nextPos = self:getNextPosByDir()

    local function gotoNext(nextPos)
        if not self.dir then
            return
        end

        -- 最后一个位置
        local lastBody = self.bodyList[#self.bodyList]
        self.lastPos = cc.p(lastBody.noX, lastBody.noY)

        -- 更新位置
        for i = #self.bodyList, 2, -1 do
            self.bodyList[i].noX = self.bodyList[i - 1].noX
            self.bodyList[i].noY = self.bodyList[i - 1].noY
        end

        -- 到达了一个行走点
        self.child.noX = nextPos.x
        self.child.noY = nextPos.y


        -- 检测是否输了
        if self:isLoseGame() then
            performWithDelay(self.root, function ( )
                self:gameOver()
            end, 2)

            return
        end

        self:getAnimal()

        self.dir = self.tobeDir or self.dir
        self:startRun()
    end

    local funData = {func = gotoNext, para = nextPos}
    self.child:setEndPos(nextPos.x, nextPos.y, funData)
    for i = #self.bodyList, 2, -1 do
        self.bodyList[i]:setEndPos(self.bodyList[i - 1].noX, self.bodyList[i - 1].noY)
    end
end

function ChildDailyMission3Dlg:gameOver()
    if self.isOver then return end
    self.isOver = true
    local score = #self.bodyList - 1
    gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt("succ", self.data.pwd), socre = gfEncrypt(tostring(score), self.data.pwd)})
end

function ChildDailyMission3Dlg:updateScore()
    local score = #self.bodyList - 1
    score = math.max( 0, score )
    self:setNumImgForPanel("Panel_179", ART_FONT_COLOR.NORMAL_TEXT, score, false, LOCATE_POSITION.MID, 25)


end

function ChildDailyMission3Dlg:onLeftButton(sender, eventType)

    if self.dir == DIR.LD then
        self.tobeDir = DIR.RD
    elseif self.dir == DIR.LU then
        self.tobeDir = DIR.LD
    elseif self.dir == DIR.RD then
        self.tobeDir = DIR.RU
    elseif self.dir == DIR.RU then
        self.tobeDir = DIR.LU
    end

    self:setCtrlVisible("LeftTextPanel", true)
    performWithDelay(sender, function ( )
        -- body
        self:setCtrlVisible("LeftTextPanel", false)
    end, 1)

    self:addDestPosMagic()

    if math.random( 1, 3 ) == 1 then
        local ran = math.random( 1, #TALKS )
        self.char:setChat({msg = TALKS[1], show_time = 3}, nil, true)
    end
end

function ChildDailyMission3Dlg:addDestPosMagic()
    local magic = gf:getCharTopLayer():getChildByName(ResMgr.magic.exit_house_houyuan)
    if magic then magic:removeFromParent() end

    magic = gf:createSelfRemoveMagic(ResMgr.magic.exit_house_houyuan)
    magic:setName(ResMgr.magic.exit_house_houyuan)

    local pos1 = self:getNextPosByDir()

    local pos = self:getNextPosByDir(self.tobeDir, pos1)

    local x, y = gf:convertToClientSpace(pos.x, pos.y)
    magic:setPosition(x, y)
    magic.noX = pos.x
    magic.noY = pos.y

    if self.tobeDir == DIR.RU then
        magic:setRotation(0)
    elseif self.tobeDir == DIR.RD then
        magic:setRotation(90)
    elseif self.tobeDir == DIR.LD then
        magic:setRotation(180)
    elseif self.tobeDir == DIR.LU then
        magic:setRotation(270)
    end

    gf:getCharTopLayer():addChild(magic)
end

function ChildDailyMission3Dlg:bornAnimal()
    local bornPos = gf:deepCopy(WALK_POINT)

   -- 去除外围一圈
    for i = #bornPos, 30, -1 do
        table.remove( bornPos, i )
    end

    for i = 6, 1, -1 do
        table.remove( bornPos, i )
    end

    for i = #bornPos, 1, -1 do
        if i % 6 == 0 or i % 6 == 1 then
            table.remove( bornPos, i )
        end
    end

    for _, char in pairs(self.bodyList) do
        for i, pos in pairs(bornPos) do
            if char.noX == pos.x and char.noY == pos.y then
                table.remove( bornPos, i )
                break
            end
        end
    end

    -- 排除游走的蛇
    local pos1, pos2
    if self.snake1 then
        for i, pos in pairs(bornPos) do
            if self.snake1 and self.snake1.noX == pos.x and self.snake1.noY == pos.y then
                pos1 = i
            end

            if self.snake2 and self.snake2.noX == pos.x and self.snake2.noY == pos.y then
                pos2 = i
            end
        end
        if pos1 and pos2 then
            if pos1 > pos2 then
                table.remove( bornPos, pos1 )
                table.remove( bornPos, pos2 )
            else
                table.remove( bornPos, pos2 )
                table.remove( bornPos, pos1 )
            end
        end
    end

    local ran = math.random( 1, #bornPos )
    local pos = bornPos[ran]
    table.remove( bornPos, ran )
    local info
    if gfGetTickCount() % 2 == 1 then
        info = {icon = 6166, name = ""}
    else
        info = {icon = 6165, name = ""}
    end
    local snake = self:createChar(info, pos)
    snake.noX = pos.x
    snake.noY = pos.y
    table.insert(self.objectList, snake)

    -- 3个时候刷新蛇，去除娃娃周围4个位置
    local animalsCount = #self.bodyList - 1
    if animalsCount > 0 and animalsCount % 3 == 0 then
        local pos1 = cc.p(self.child.noX + 2, self.child.noY + 2)
        local pos2 = cc.p(self.child.noX + 2, self.child.noY - 2)
        local pos3 = cc.p(self.child.noX - 2, self.child.noY - 2)
        local pos4 = cc.p(self.child.noX - 2, self.child.noY + 2)

        local around = {}

        for i, pos in pairs(bornPos) do
            if pos.x == pos1.x and pos.y == pos1.y then
                table.insert( around, i )
            end

            if pos.x == pos2.x and pos.y == pos2.y then
                table.insert( around, i )
            end

            if pos.x == pos3.x and pos.y == pos3.y then
                table.insert( around, i )
            end

            if pos.x == pos4.x and pos.y == pos4.y then
                table.insert( around, i )
            end
        end

        table.sort(around, function(l, r)
            if l > r then return true end
            if l < r then return false end
        end)

        for _, idx in pairs(around) do
            table.remove( bornPos, idx )
        end

        if #bornPos > 2 then
            if self.snake1 then
                local r1 = math.random( 1, #bornPos )
                local pos1 = bornPos[r1]
                local x, y = gf:convertToClientSpace(pos1.x, pos1.y)
                self.snake1:setPos(x, y)
                self.snake1.noX = pos1.x
                self.snake1.noY = pos1.y
                table.remove( bornPos, r1 )

                local r2 = math.random( 1, #bornPos )
                local pos2 = bornPos[r2]
                local x, y = gf:convertToClientSpace(pos2.x, pos2.y)
                self.snake2:setPos(x, y)
                self.snake2.noX = pos2.x
                self.snake2.noY = pos2.y
                table.remove( bornPos, r2 )
            else
                local r1 = math.random( 1, #bornPos )
                local info = {icon = 6102, name = "", dir = 5}
                self.snake1 = self:createChar(info, bornPos[r1])
                self.snake1.noX = bornPos[r1].x
                self.snake1.noY = bornPos[r1].y
                table.remove( bornPos, r1 )

                local r1 = math.random( 1, #bornPos )
                local info = {icon = 6102, name = "", dir = 5}
                self.snake2 = self:createChar(info, bornPos[r1])
                self.snake2.noX = bornPos[r1].x
                self.snake2.noY = bornPos[r1].y
                table.remove( bornPos, r1 )
            end
        end
    end
end

function ChildDailyMission3Dlg:onRightButton(sender, eventType)
    if self.dir == DIR.LD then
        self.tobeDir = DIR.LU
    elseif self.dir == DIR.LU then
        self.tobeDir = DIR.RU
    elseif self.dir == DIR.RD then
        self.tobeDir = DIR.LD
    elseif self.dir == DIR.RU then
        self.tobeDir = DIR.RD
    end

    self:setCtrlVisible("RightTextPanel", true)
    performWithDelay(sender, function ( )
        -- body
        self:setCtrlVisible("RightTextPanel", false)
    end, 1)

    self:addDestPosMagic()

    if math.random( 1, 3 ) == 1 then
        local ran = math.random( 1, #TALKS )
        self.char:setChat({msg = TALKS[ran], show_time = 3}, nil, true)
    end

end

function ChildDailyMission3Dlg:onGetButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 1})
    DlgMgr:closeDlg(self.name)
end

function ChildDailyMission3Dlg:onRestartButton(sender, eventType)
    self.isOver = false
    self:cleanAllObject()

    self:setCtrlVisible("ResultPanel", false)

    self:initSnakies()

    self:initWalkPoint()

    self:initChar()

    self:updateScore()

    self:onStartButton(self:getControl("StartButton"))
end

function ChildDailyMission3Dlg:cleanAllObject()

    self.bodyList = {}
    for _, info in pairs(self.objectList) do
        info:cleanup()
    end
    self.objectList = {}

    if self.child then
        self.child:cleanup()
        self.child = nil
    end

    if self.char then
        self.char:cleanup()
        self.char = nil
    end

    if self.snake1 then
        self.snake1:cleanup()
        self.snake1 = nil
    end

    if self.snake2 then
        self.snake2:cleanup()
        self.snake2 = nil
    end


    if self.bigGrass then
        for _, sp in pairs(self.bigGrass) do
            sp:removeFromParent()
        end

        self.bigGrass = nil
    end


    if self.grass then
        for _, sp in pairs(self.grass) do
            sp:removeFromParent()
        end

        self.grass = nil
    end


end

function ChildDailyMission3Dlg:cleanup()

    self:cleanAllObject()

    performWithDelay(gf:getUILayer(), function ()
        DlgMgr:showAllOpenedDlg(true)
    end)

    Me:setVisible(true)

    if self.bgImage then
        self.bgImage:removeFromParent()
        self.bgImage = nil
    end

    if self.bgImage2 then
   --     self.bgImage2:removeFromParent()
        self.bgImage2 = nil
    end

    if self.croplandLayer then
        self.croplandLayer:removeFromParent()
        self.croplandLayer = nil
    end

    local magic = gf:getCharTopLayer():getChildByName(ResMgr.magic.exit_house_houyuan)
    if magic then magic:removeFromParent() end
end

function ChildDailyMission3Dlg:addFightBg()
    -- 背景地图
    if not self.bgImage then
        self.bgImage = ccui.ImageView:create(ResMgr.ui.fight_bg_img)
        self.bgImage:setAnchorPoint(0.5, 0.5)

        -- 背景黑色进行缩放
        local destScale = math.max((Const.WINSIZE.width + 40) / self.bgImage:getContentSize().width, (Const.WINSIZE.height + 40) / self.bgImage:getContentSize().height)

        self.bgImage:setScale(destScale)
        self.bgImage:setOpacity(204)
    end

    if not self.bgImage2 then
        self.bgImage2 = ccui.ImageView:create(ResMgr.ui.fight_bg_img_center)
        self.bgImage2:setAnchorPoint(0.5, 0.5)
    end

    self.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())

    self.bgImage2:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY() - 74)

    if not self.bgImage:getParent() then
    gf:getMapLayer():addChild(self.bgImage)
    end

    if not self.bgImage2:getParent() then
  --  gf:getMapLayer():addChild(self.bgImage2)
    end

    -- 创建层，隔绝地板点击事件
    self.croplandLayer = cc.Layer:create()
 --   self.croplandLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    self.croplandLayer:setPosition(-gf:getMapLayer():getPositionX(), -gf:getMapLayer():getPositionY())

    gf:getMapLayer():addChild(self.croplandLayer)

    local function clickCropLand(sender, event)
        return true
    end

    gf:bindTouchListener(self.croplandLayer, clickCropLand, {
    cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
end

function ChildDailyMission3Dlg:MSG_CHILD_GAME_SCORE(data)


    self:updateScore()

    self:setCtrlVisible("ResultPanel", true)

    self:setCtrlVisible("LeftButton", false)
    self:setCtrlVisible("RightButton", false)

    local numImg = self:setNumImgForPanel("ScorePanel", ART_FONT_COLOR.B_FIGHT, data.thisScore, false, LOCATE_POSITION.MID, 23)

    self:setLabelText("HighestNumLabel", CHS[4101551] .. data.hightestScore)
--[[
        -- 道法
    local daoPanel = self:getControl("Item1Panel")
    self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[4101495]), daoPanel)
    self:setLabelText("NumLabel_2", CHS[4101495] .. " * " .. data.daofa, daoPanel)
--]]
    local xinPanel = self:getControl("Item1Panel")
    self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[4101496]), xinPanel)
    self:setLabelText("NumLabel_2", CHS[4101496].. "：" .. data.xinfa, xinPanel)

    local daoPanel = self:getControl("Item2Panel")
    self:setImagePlist("RewardImage", ResMgr.ui["small_child_qinmidu"], daoPanel)
    self:setLabelText("NumLabel_2",CHS[7190534] .. "：" .. data.qinmi, daoPanel)

    self:setCtrlVisible("Item3Panel", false)
    self:setCtrlVisible("QuiteButton", false)


    if data.totalSore == data.hightestScore then
        self:setLabelText("ScoreTipsLabel", string.format( CHS[4200772], data.totalSore), "ResultPanel")
    elseif data.hightestScore >= 6 then
        self:setLabelText("ScoreTipsLabel", string.format( CHS[4101553], data.totalSore, (data.totalSore - data.hightestScore) ), "ResultPanel")
    else
        self:setCtrlVisible("QuiteButton", true)
        self:setLabelText("ScoreTipsLabel", CHS[4200776], "ResultPanel")
    end
end


return ChildDailyMission3Dlg
