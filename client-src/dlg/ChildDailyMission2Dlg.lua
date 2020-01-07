-- ChildDailyMission2Dlg.lua
-- Created by songcw Apir/14/2019
-- 娃娃日常-【养育】踩影子

local ChildDailyMission2Dlg = Singleton("ChildDailyMission2Dlg", Dialog)
local NumImg = require('ctrl/NumImg')

local DEFAULT_TIME_MAX = 25

-- 编号对应的位置
local NO_TO_POS = {
    [1]  = {x = 408 + 72, y = 298 + 36}
}


local SHADOW_LOCK_COUNT = 2         -- 影子锁个数
local STONE_COUNT = 3               -- 石头个数
local CHAR_LOCK_COUNT = 2           -- 人之锁个数
local DOOR_COUNT = 2                -- 传送门个数
--]]


local MY_CHAR = 1
local MY_SHADOW = 2
local CHILD_CHAR = 3
local CHILD_SHADOW = 4
local SHADOW_LOCK = 5
local CHAR_LOCK = 6
local STONE = 7
local DOOR = 8

local DIR = {
    LEFT_DOWN = 1,
    RIGHT_DOWN = 2,
    RIGHT_UP = 3,
    LEFT_UP = 4,
}

local DELAY_1 = 1

local MAX_ROUND = 31

function ChildDailyMission2Dlg:init(data)
    self:setFullScreen()
    self:bindListener("DownButton", self.onDownButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("UpButton", self.onUpButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("LostButton", self.onLostButton)
    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("StartButton", self.onStartButton)
    --self:bindFloatPanelListener("RulePanel")
    self:setCtrlVisible("StartButton", true)
    self:setCtrlVisible("RuleForReadyPanel", true)
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("GameResultPanel", false)

    self:bindFloatPanelListener("RulePanel", nil, nil, function ()
        self.numImg:continueCountDown()
    end)

    self:bindListener("RulePanel", function ()
        self:setCtrlVisible("RulePanel", false)
        self.numImg:continueCountDown()
    end)

    self.data = data
    self.isOver = false

    -- 隐藏主界面相关操作
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1, })

    -- 初始化倒计时panel
    self:initTimePanel()

    self.myShadowlimit = {}             -- 我的影子移动限制
    self.childShadowlimit = {}          -- 娃娃影子移动限制

    self.myCharlimit = {}             -- 我的移动限制
    self.childCharlimit = {}          -- 娃娃移动限制

    self.myRandomMove = {}                -- 我中了人之所，随机移动的位置（影子移动时要用）
    self.childRandomMove = {}                -- 娃娃中了人之所，随机移动的位置（影子移动时要用）

    -- 格子
    local icon = ResMgr.ui.sxdj_grid_white
    local img = ccui.ImageView:create(icon)
    self.gridSize = self.gridSize or img:getContentSize()
    self:initPos()


    -- 创建角色和娃娃
    self:initChar()

    self:hookMsg("MSG_CHILD_GAME_RESULT")
end

function ChildDailyMission2Dlg:addShaowName(name)
    local label = ccui.Text:create()
    label:setFontSize(21)
    label:setString(name)
    label:setColor(COLOR3.CHAR_GREEN)
    local size = label:getContentSize()
    size.width = size.width + 8
    size.height = size.height + 8

    local nameLabel2 = label:clone()

    nameLabel2:setColor(COLOR3.BLACK)

    local bgImage = ccui.ImageView:create(ResMgr.ui.chenwei_name_bgimg, ccui.TextureResType.plistType)
    local bgImgSize = bgImage:getContentSize()
    size.height = bgImgSize.height

    label:setPosition(size.width / 2, size.height / 2)
    nameLabel2:setPosition(size.width / 2 + 1, size.height / 2)

    bgImage:setScale9Enabled(true)
    bgImage:setContentSize(size)

    bgImage:addChild(nameLabel2)
    bgImage:addChild(label)

    return bgImage
end

function ChildDailyMission2Dlg:noToArr(no)
    local x,y
    x = math.floor( (no - 1) / 6 ) + 1
    y = no % 6
    if y == 0 then y = 6 end
    return x, y
end

function ChildDailyMission2Dlg:initChar()

    local posIdxs = {}
    for i = 1, 36 do
        table.insert( posIdxs, i )
    end

    self.objectList = {}

    -- 随机位置出现我的角色
    local myCharIdx = math.random( 25, 30 )




    table.remove( posIdxs, myCharIdx )

    local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), tag = 1}
    local char = self:createChar(info, NO_TO_POS[myCharIdx])
    char.no = myCharIdx
    table.insert( self.objectList, char )
    local info = {icon = 1, name = (Me:queryBasic("name") .. CHS[4101540]), tag = 2}
    local char = self:createChar(info, NO_TO_POS[myCharIdx])
    char.no = myCharIdx
    table.insert( self.objectList, char )

--[[
    local random = math.random( 25, 29 )
    local myShadowIdx = posIdxs[random]
    table.remove( posIdxs, random )
    local info = {icon = 1, name = (Me:queryBasic("name") .. CHS[4101540]), tag = 2}
    local char = self:createChar(info, NO_TO_POS[myShadowIdx])
    char.no = myShadowIdx
    table.insert( self.objectList, char )
--]]

    -- 随机出现娃娃角色
    local childCharIdx = math.random( 7, 12 )
    table.remove( posIdxs, childCharIdx )
    local info = {icon = self.data.child_icon, name = self.data.child_name, tag = 3}
    local char = self:createChar(info, NO_TO_POS[childCharIdx])
    char.no = childCharIdx
    table.insert( self.objectList, char )

    local info = {icon = 1, name = self.data.child_name .. CHS[4101540], tag = 4}
    local char = self:createChar(info, NO_TO_POS[childCharIdx])
    char.no = childCharIdx
    table.insert( self.objectList, char )

    -- 娃娃影子
    --[[
    local random = math.random( 7, 11 )
    local childShadowIdx = posIdxs[random]
    table.remove( posIdxs, random )
    local info = {icon = 1, name = self.data.child_name .. CHS[4101540], tag = 4}
    local char = self:createChar(info, NO_TO_POS[childShadowIdx])
    char.no = childShadowIdx
    table.insert( self.objectList, char )
--]]

    -- 石头个数
    self.stonePos = {}
    for i = 1, STONE_COUNT do
        local random = math.random( 1, #posIdxs )
        local idx = posIdxs[random]
        table.remove( posIdxs, random )

        local info = {icon = 6142, name = CHS[4101541], tag = 7}
        local char = self:createChar(info, NO_TO_POS[idx])
        char.no = idx
        table.insert( self.objectList, char )
        self.stonePos[idx] = 1
    end

    -- 影子锁
    self.shadowLockPos = {}
    for i = 1, SHADOW_LOCK_COUNT do
        local random = math.random( 1, #posIdxs )

        local idx = posIdxs[random]
        table.remove( posIdxs, random )

        local info = {icon = 1, name = CHS[4101542], tag = 5}
        local char = self:createChar(info, NO_TO_POS[idx])
        char.no = idx
        table.insert( self.objectList, char )

        self.shadowLockPos[idx] = 1
    end

    -- 人之锁
    self.charLockPos = {}
    for i = 1, CHAR_LOCK_COUNT do
        local random = math.random( 1, #posIdxs )

        local idx = posIdxs[random]
        table.remove( posIdxs, random )
        local info = {icon = 1, name = CHS[4101543], tag = 6}
        local char = self:createChar(info, NO_TO_POS[idx])
        char.no = idx
        table.insert( self.objectList, char )
        self.charLockPos[idx] = 1
    end



    -- 过图点
    self.doorPos = {}
    for i = 1, DOOR_COUNT do
        local random = math.random( 1, #posIdxs )
        local idx = posIdxs[random]
        table.remove( posIdxs, random )
        local info = {icon = 1, name = "", tag = 8}
        local char = self:createChar(info, NO_TO_POS[idx])
        char.no = idx
        table.insert( self.objectList, char )
        self.doorPos[idx] = 1
    end
end


-- 创建角色
function ChildDailyMission2Dlg:createChar(info, pos)
    local char = require("obj/activityObj/ChildCyzNpc").new()
    char:absorbBasicFields({
        icon = info.icon,
        name = info.name or "",
        dir = info.dir or 5,
        tag = info.tag,
    })

    char:onEnterScene(pos.x, pos.y)
    char:setAct(Const.FA_STAND)
    return char
end

function ChildDailyMission2Dlg:getSelectImg()
    if not self.selectImg then
        self.selectImg = cc.Sprite:create(ResMgr.ui.select_arrows)
        self.selectImg:setPosition(0, 70)
        self.selectImg:setFlipY(true)
        self.selectImg:retain()

        local action = cc.Sequence:create(
            cc.MoveBy:create(0.45, cc.p(0, 10)),
            cc.MoveBy:create(0.45, cc.p(0, -10))
        )

        self.selectImg:runAction(cc.RepeatForever:create(action))
    end

    return self.selectImg
end

function ChildDailyMission2Dlg:onClickGezi(sender)
    if not sender then return end
    local no = tonumber(string.match(sender:getName(), "ShengxdjDlgGrids(%d+)"))
    if no then

    end
end

function ChildDailyMission2Dlg:onUpdate()
    if self.objectList then
        for _, char in pairs(self.objectList) do
            char:update()
        end
    end
end


function ChildDailyMission2Dlg:getCharByType(type)
    for _, char in pairs(self.objectList) do
        if char:queryBasicInt("tag") == type then
            return char
        end
    end
end

function ChildDailyMission2Dlg:getNPCByType(type)
    local npcs = {}
    for _, char in pairs(self.objectList) do
        if char:queryBasicInt("tag") == type then
            table.insert( npcs, char )
        end
    end

    return npcs
end

function ChildDailyMission2Dlg:gotoByDir(char, dir)
    local no = char.no
    local destNo = 0
    local retNo = 0 -- 如果走出棋盘，返回最后的no
    local outPos = cc.p(0, 0)
    if dir == DIR.LEFT_DOWN then
        if math.floor( (no - 1) / 6 ) ~= math.floor( (no - 2) / 6 ) then
            -- 行走后超出了
            retNo = no - 1 + 6
            outPos = cc.p(NO_TO_POS[no].x - 76, NO_TO_POS[no].y - 36)
        else
            destNo = no - 1
        end
    elseif dir == DIR.RIGHT_UP then
        if math.floor( (no - 1) / 6 ) ~= math.floor( (no) / 6 ) then
            -- 行走后超出了
            retNo = no - 6 + 1
            outPos = cc.p(NO_TO_POS[no].x + 76, NO_TO_POS[no].y + 36)
        else
            destNo = no + 1
        end
    elseif dir == DIR.LEFT_UP then
        if no <= 6 then
            retNo = no + 30
            outPos = cc.p(NO_TO_POS[no].x - 76, NO_TO_POS[no].y + 36)
        else
            destNo = no - 6
        end
    else
        if no >= 31 then
            retNo = no - 30
            outPos = cc.p(NO_TO_POS[no].x + 76, NO_TO_POS[no].y - 36)
        else
            destNo = no + 6
        end
    end

    return destNo, retNo, outPos
end

function ChildDailyMission2Dlg:onDownButton(sender, eventType)
    self:myCharMove(DIR.LEFT_DOWN)
end

function ChildDailyMission2Dlg:getOppositeDir(dir)
    if dir == DIR.LEFT_DOWN then
        return DIR.RIGHT_UP
    elseif dir == DIR.RIGHT_UP then
        return DIR.LEFT_DOWN
    elseif dir == DIR.LEFT_UP then
        return DIR.RIGHT_DOWN
    elseif dir == DIR.RIGHT_DOWN then
        return DIR.LEFT_UP
    end
end

function ChildDailyMission2Dlg:checkNpcEvent(char)
    if self.isOver then return end

    local no = char.no
    local npcTag
    local charTag = char:queryBasicInt("tag")
    for _, npc in pairs(self.objectList) do
        if npc:queryBasicInt("tag") ~= charTag and no == npc.no then
            npcTag = npc:queryBasicInt("tag")
        end
    end

    if npcTag == SHADOW_LOCK then
        -- 踩到影之锁
        if charTag == MY_SHADOW then
            self.myShadowlimit[self.round + 1] = "stand"
            char:showEffect(4001, true)
        elseif charTag == CHILD_SHADOW then
            self.childShadowlimit[self.round + 1] = "stand"

            char:showEffect(4001, true)
        end
    elseif npcTag == CHAR_LOCK then
        if charTag == MY_CHAR then
            self.myCharlimit[self.round + 1] = "random"

            char:showEffect(4009, true)
        elseif charTag == CHILD_CHAR then
            self.childCharlimit[self.round + 1] = "random"

            char:showEffect(4009, true)
        end

    elseif npcTag == DOOR then
        local doors = self:getNPCByType(DOOR)

        for i = 1, #doors do
            if doors[i].no == no then
                table.remove( doors, i)
                break
            end
        end
        if #doors >= 1 then
            local r = math.random( 1, #doors )
            local destNpc = doors[r]
            char.no = destNpc.no
            char:setPos(NO_TO_POS[char.no].x, NO_TO_POS[char.no].y)
        end
    end

    local myChar = self:getCharByType(MY_CHAR)
    local childShadow = self:getCharByType(CHILD_SHADOW)
    if myChar.no == childShadow.no then
        myChar:setChat({msg = CHS[4101544], show_time = 3}, nil, true)
        myChar:addMagicOnWaist(ResMgr.magic.grey_fog, false)
        self:gameOver(myChar)
        return
    end

    local child = self:getCharByType(CHILD_CHAR)
    local myShadow = self:getCharByType(MY_SHADOW)
    if child.no == myShadow.no then
        child:setChat({msg = CHS[4101544], show_time = 3}, nil, true)
        child:addMagicOnWaist(ResMgr.magic.grey_fog, false)
        self:gameOver(child)
        return
    end
end

function ChildDailyMission2Dlg:gameOver(char)
    self:showPleaseWait(false)
    self.isOver = true

    self.root:stopAllActions()

    performWithDelay(self.root, function ( )
        -- body
        local result = char:queryBasicInt("tag") == MY_CHAR and "succ" or "fail"
        gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt(result, self.data.pwd)})
    end, 2)


end

function ChildDailyMission2Dlg:shadowMoveTwice(char, isCheck)
    if self.isOver then return end

    local dir = math.random( 1, 4 )
    local destNo, retNo, outPos = self:gotoByDir(char, dir)
    if self:isStoneByNo(retNo) then
        self:shadowMoveTwice(char, isCheck)
        return
    end

    -- 记录混乱移动位置，影子移动时用
    if char == self:getCharByType(MY_CHAR) then
        if not self.myRandomMove[self.round] then
            self.myRandomMove[self.round] = {}
        end

        table.insert( self.myRandomMove[self.round], dir )
    elseif char == self:getCharByType(CHILD_CHAR) then
        if not self.childRandomMove[self.round] then
            self.childRandomMove[self.round] = {}
        end

        table.insert( self.childRandomMove[self.round], dir )
    elseif char == self:getCharByType(MY_SHADOW) then
        -- 影子移动两次

        dir = self.myRandomMove[self.round][1]
        dir = self:getOppositeDir(dir)
        table.remove( self.myRandomMove[self.round], 1 )
        destNo, retNo, outPos = self:gotoByDir(char, dir)
    elseif char == self:getCharByType(CHILD_SHADOW) then
        -- 影子移动两次

        dir = self.childRandomMove[self.round][1]
        dir = self:getOppositeDir(dir)
        table.remove( self.childRandomMove[self.round], 1 )
        destNo, retNo, outPos = self:gotoByDir(char, dir)
    end

    if destNo ~= 0 then
        char.no = destNo
        char:setDestPos(NO_TO_POS[destNo])

        local function callBack(para )
            if isCheck then
                char:showEffect(nil, false)
                self:checkNpcEvent(para)

                if self.isOver then return end

                if char == self:getCharByType(MY_CHAR) then
                    self:myShadowMove(math.random(1, 4))
                elseif char == self:getCharByType(MY_SHADOW) then
                    performWithDelay(self.root, function ()
                        self:childAction()
                    end, 1.5)
                elseif char == self:getCharByType(CHILD_CHAR) then
                    childShadow = self:getCharByType(CHILD_SHADOW)
                    if self.childShadowlimit[self.round] == "stand" then
                        childShadow:showEffect(nil, false)
                        self:beginRound(self.round + 1)
                    elseif self.childRandomMove[self.round] then
                        self:shadowMoveTwice(childShadow)
                    end
                elseif char == self:getCharByType(CHILD_SHADOW) then
                    self:beginRound(self.round + 1)
                end
            else
                self:shadowMoveTwice(char, true)
            end
        end

        local funData = {func = callBack, para = char}
        char:setEndPos(NO_TO_POS[destNo].x, NO_TO_POS[destNo].y, funData)

    else
        local no = char.no

        char:setDestPos(outPos)

        local function callBack(para )
            char:setPos(NO_TO_POS[retNo].x, NO_TO_POS[retNo].y)
            char.no = retNo
            if isCheck then
                char:showEffect(nil, false)
                self:checkNpcEvent(para)
                if self.isOver then return end
                if char == self:getCharByType(MY_CHAR) then
                    self:myShadowMove(math.random(1, 4))
                elseif char == self:getCharByType(MY_SHADOW) then
                    performWithDelay(self.root, function ()
                        self:childAction()
                    end, 1.5)
                elseif char == self:getCharByType(CHILD_CHAR) then
                    childShadow = self:getCharByType(CHILD_SHADOW)
                    if self.childShadowlimit[self.round] == "stand" then
                        childShadow:showEffect(nil, false)
                        self:beginRound(self.round + 1)
                    elseif self.childRandomMove[self.round] then
                        self:shadowMoveTwice(childShadow)
                    end
                elseif char == self:getCharByType(CHILD_SHADOW) then
                    self:beginRound(self.round + 1)
                end
            else
                self:shadowMoveTwice(char, true)
            end
        end

        local funData = {func = callBack, para = char}
        char:setEndPos(outPos.x, outPos.y, funData)
    end

end

function ChildDailyMission2Dlg:moveToByDir(char, dir, fun)
    if not dir or dir == 0 then return end

    if char == self:getCharByType(MY_SHADOW) or char == self:getCharByType(CHILD_SHADOW) then
        char:showEffect(nil, false)
    elseif char == self:getCharByType(MY_CHAR) and self.myCharlimit[self.round] ~= "random" then
        char:showEffect(nil, false)
    elseif char == self:getCharByType(CHILD_SHADOW) and self.childCharlimit[self.round] ~= "random" then
        char:showEffect(nil, false)
    end


    local destNo, retNo, outPos = self:gotoByDir(char, dir)
    if destNo ~= 0 then
        char.no = destNo
        char:setDestPos(NO_TO_POS[destNo])

        local function callBack(para )
            self:checkNpcEvent(para)
            if self.isOver then return end
            if fun then fun() end
        end

        local funData = {func = callBack, para = char}
        char:setEndPos(NO_TO_POS[destNo].x, NO_TO_POS[destNo].y, funData)

    else
        local no = char.no

        char:setDestPos(outPos)

        local function callBack(para )
            char:setPos(NO_TO_POS[retNo].x, NO_TO_POS[retNo].y)
            char.no = retNo
            self:checkNpcEvent(char)
            if self.isOver then return end
            if fun then fun() end
        end

        local funData = {func = callBack, para = char}
        char:setEndPos(outPos.x, outPos.y, funData)
    end

end

function ChildDailyMission2Dlg:onRightButton(sender, eventType)
    self:myCharMove(DIR.RIGHT_DOWN)
end

function ChildDailyMission2Dlg:onUpButton(sender, eventType)
    self:myCharMove(DIR.RIGHT_UP)
end

function ChildDailyMission2Dlg:isStoneByNo(no)
    local stones = self:getNPCByType(STONE)
    for _, char in pairs(stones) do
        if no == char.no then
            return true
        end
    end

    return false
end

function ChildDailyMission2Dlg:checkContidion(dir)
    if self.isOver then return end

    if not self.isMyTurn then
        gf:ShowSmallTips(CHS[4101545])
        return
    end

    if dir then
        local myChar = self:getCharByType(MY_CHAR)
        local destNo, retNo, outPos = self:gotoByDir(myChar, dir)

        if destNo ~= 0 then
            if self:isStoneByNo(destNo) then
                gf:ShowSmallTips(CHS[4101546])
                return
            end
        else
            if self:isStoneByNo(retNo) then
                gf:ShowSmallTips(CHS[4101546])
                return
            end
        end
    end

    return true
end


function ChildDailyMission2Dlg:myCharMove(dir)
    if self:getCtrlVisible("StartButton") then return end

    if not self:checkContidion(dir) then
        return
    end

    self.numImg:stopCountDown()

    self.isMyTurn = false
    self:showPleaseWait(false)
    local myChar = self:getCharByType(MY_CHAR)
    myChar:showSelectAction(false)

    if self.myCharlimit[self.round] == "random" then
        self:shadowMoveTwice(myChar)
        return
    end

    self:moveToByDir(myChar, dir, function ( )
        self:myShadowMove(dir)
    end)
end

function ChildDailyMission2Dlg:myShadowMove(dir)
    performWithDelay(self.root, function ()
        local myShadow = self:getCharByType(MY_SHADOW)


        local oppDir = self:getOppositeDir(dir)
        if self.myShadowlimit[self.round] == "stand" then
            oppDir = 0
            myShadow:showEffect(nil, false)
        else
            if self.myRandomMove[self.round] then
                self:shadowMoveTwice(myShadow)
                return
            end
        end

        if oppDir ~= 0 then
            self:moveToByDir(myShadow, oppDir, function ( )
                -- body
                if self.isOver then return end
                self:childAction()
            end)
        else
            self:childAction()
        end

   --     performWithDelay(self.root, function ()

 --       end, 1.5)
    end, DELAY_1)
end

function ChildDailyMission2Dlg:onLeftButton(sender, eventType)
    self:myCharMove(DIR.LEFT_UP)
end

function ChildDailyMission2Dlg:childAction()
    if self.isOver then return end

    local child = self:getCharByType(CHILD_CHAR)
    child:setChat({msg = CHS[4101547], show_time = 3}, nil, true)
    performWithDelay(self.root, function ()
        local dir = self:getChildNextDir()
        local delatTi = DELAY_1


        if self.childCharlimit[self.round] == "random" then
            self:shadowMoveTwice(child)
        else
            self:moveToByDir(child, dir, function ( )
                local oppDir = self:getOppositeDir(dir)
                local childShadow = self:getCharByType(CHILD_SHADOW)

                if self.childShadowlimit[self.round] == "stand" then
                    oppDir = 0
                    childShadow:showEffect(nil, false)
                    self:beginRound(self.round + 1)
                elseif self.childRandomMove[self.round] then
                    self:shadowMoveTwice(childShadow)
                    oppDir = 0
                end


                if oppDir ~= 0 then
                    self:moveToByDir(childShadow, oppDir, function ( )
                        self:beginRound(self.round + 1)
                    end)
                end
            end)
        end
    end, 3)
end

function ChildDailyMission2Dlg:getChildNextDir(isForceRand)
    local myShadow = self:getCharByType(MY_SHADOW)
    local mySx, mySy = self:noToArr(myShadow.no)

    local child = self:getCharByType(CHILD_CHAR)
    local cSx, cSy = self:noToArr(child.no)

    local function getDir( )
        if gfGetTickCount() % 2 == 1 then
            if mySx == cSx then
                if mySy > cSy then
                    return DIR.RIGHT_UP
                else
                    return DIR.LEFT_DOWN
                end
            else
                if mySx > cSx then
                    return DIR.RIGHT_DOWN
                else
                    return DIR.LEFT_UP
                end
            end
        else
            if mySy == cSy then
                if mySx > cSx then
                    return DIR.RIGHT_DOWN
                else
                    return DIR.LEFT_UP
                end
            else
                if mySy > cSy then
                    return DIR.RIGHT_UP
                else
                    return DIR.LEFT_DOWN
                end
            end
        end
    end

    local nextDir = getDir()
    if isForceRand then
        nextDir = math.random( 1, 4)
    end

    local destNo, retNo, outPos = self:gotoByDir(child, nextDir)
    if destNo ~= 0 then
        if self:isStoneByNo(destNo) then


            return self:getChildNextDir(true)
        end
    else
        if self:isStoneByNo(retNo) then


            return self:getChildNextDir(true)
        end
    end

    return nextDir
end

function ChildDailyMission2Dlg:onCloseButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    DlgMgr:closeDlg(self.name)
end

function ChildDailyMission2Dlg:onLostButton(sender, eventType)
--
    gf:confirm(CHS[4101499], function ()
      --  self:onCloseButton()
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    end)
    --]]

  --  self:onCloseButton()
end

function ChildDailyMission2Dlg:beginRound(round)
    if not self.myShadowlimit[round] and not self.myCharlimit[round] then
        self:getCharByType(MY_SHADOW):showEffect(nil, false)
    end

    if not self.childShadowlimit[round] and not self.childCharlimit[round] then
        self:getCharByType(CHILD_SHADOW):showEffect(nil, false)
    end


    if self.isOver then return end

    if round == MAX_ROUND then
        local child = self:getCharByType(CHILD_CHAR)
        child:setChat({msg = CHS[4101548], show_time = 3}, nil, true)
        local myShadow = self:getCharByType(MY_SHADOW)

        local function callBack(para )
                           -- 魔法攻击
            child:setAct(Const.FA_STAND)
            child:setAct(Const.FA_ACTION_CAST_MAGIC, function()
                child:setAct(Const.FA_ACTION_CAST_MAGIC_END, function()
                child:setAct(Const.FA_STAND)
                child:setChat({msg = CHS[4200775], show_time = 3}, nil, true)
                gf:ShowSmallTips(CHS[4101549])  -- 你未能在30回合内战胜自己的娃娃！
                self.isOver = true
                performWithDelay(self.root, function ( )
                    self:gameOver(child)
                end, 1)
                end)
            end)
        end

        local funData = {func = callBack, para = char}
        child:setEndPos(NO_TO_POS[myShadow.no].x, NO_TO_POS[myShadow.no].y, funData)
        return
    end



    self.round = round
    self.isMyTurn = true

    self:setLabelText("Label_45", string.format( CHS[4101550], round))
    self:startCountDown(DEFAULT_TIME_MAX)
end

function ChildDailyMission2Dlg:onRuleButton(sender, eventType)
    if self:getCtrlVisible("StartButton") then return end

    self:setCtrlVisible("RulePanel", true)
    self.numImg:pauseCountDown()


    --gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt("succ", self.data.pwd)})
end

function ChildDailyMission2Dlg:onStartButton(sender, eventType)
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("RuleForReadyPanel", false)



    self:beginRound(1)
end

function ChildDailyMission2Dlg:initTimePanel()
    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('TimePanel')
    if timePanel then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', DEFAULT_TIME_MAX, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg)
        self.waitImg = self:getControl("WaitImage", Const.UIImage)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.waitImg:setVisible(false)
    end
end

-- 开始计时
function ChildDailyMission2Dlg:startCountDown(time)
    if not self.numImg then
        return
    end

    if BattleSimulatorMgr:isRunning() and not BattleSimulatorMgr:getCurCombatData().hasWaitTime then
        -- 如果存在战斗模拟器，并且有不需要显示
        return
    end

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self.waitImg:setVisible(false)
    self:setCtrlVisible("TimePanel", true)

    local myChar = self:getCharByType(MY_CHAR)
    myChar:showSelectAction(true)

    --self.myChar:showSelectAction(true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)

        myChar:showSelectAction(false)
        if self.myCharlimit[self.round] == "random" then
            self:shadowMoveTwice(myChar)
        else
            myChar:showSelectAction(false)

            if self.isMyTurn then
                self:childAction()
            end
        end
        self.isMyTurn = false
    end)

    if self:getCtrlVisible("RulePanel") then
        self.numImg:pauseCountDown()
    end
end

-- 设置是否显示等待提示
function ChildDailyMission2Dlg:showPleaseWait(show)
    if show then
        self.numImg:stopCountDown()
        self.numImg:setVisible(false)
        self.waitImg:setVisible(true)
        self:setCtrlVisible("TimePanel", true)

        FightMgr:hideOperateDlgs()
    else
        self.waitImg:setVisible(false)
        self:setCtrlVisible("TimePanel", false)
    end
end

-- 返回剩余倒计时
function ChildDailyMission2Dlg:getLeftTime()
    if self.numImg then
        return self.numImg.num
    else
        return 0
    end
end

function ChildDailyMission2Dlg:initPos()
    for i = 2, 6 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[1].x + (i - 1) * 76, NO_TO_POS[1].y + (i - 1) * 38)
    end

    NO_TO_POS[7] = cc.p(NO_TO_POS[1].x + 76, NO_TO_POS[1].y - 38)
    NO_TO_POS[13] = cc.p(NO_TO_POS[7].x + 76, NO_TO_POS[7].y - 38)
    NO_TO_POS[19] = cc.p(NO_TO_POS[13].x + 76, NO_TO_POS[13].y - 38)
    NO_TO_POS[25] = cc.p(NO_TO_POS[19].x + 76, NO_TO_POS[19].y - 38)
    NO_TO_POS[31] = cc.p(NO_TO_POS[25].x + 76, NO_TO_POS[25].y - 38)

    for i = 7, 12 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[7].x + (i - 7) * 76, NO_TO_POS[7].y + (i - 7) * 38)
    end

    for i = 13, 18 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[13].x + (i - 13) * 76, NO_TO_POS[13].y + (i - 13) * 38)
    end

    for i = 19, 24 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[19].x + (i - 19) * 76, NO_TO_POS[19].y + (i - 19) * 38)
    end

    for i = 25, 30 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[25].x + (i - 25) * 76, NO_TO_POS[25].y + (i - 25) * 38)
    end

    for i = 31, 36 do
        NO_TO_POS[i] = cc.p(NO_TO_POS[31].x + (i - 31) * 76, NO_TO_POS[31].y + (i - 31) * 38)
    end
end

function ChildDailyMission2Dlg:creatAllGrid()
    self.grids = {}
    for i = 1, #NO_TO_POS do
        self:creatUnitGrid(i, true)
    end
end

-- 创建格子
function ChildDailyMission2Dlg:creatUnitGrid(no, hasAction)
    if self.grids[no] then
        return
    end

    local pos = NO_TO_POS[no]
    local icon = ResMgr.ui.sxdj_grid_white
    if no % 2 == 0 then
        -- 深色格子
        icon = ResMgr.ui.sxdj_grid_black
    end

    local img = ccui.ImageView:create(icon)
    img:setName("ShengxdjDlgGrids" .. no)

    local x = pos.x
    local y = pos.y


    img:setPosition(x, y)
    img:setEnabled(true)


    self.grids[no] = img

    self:creatCropland(img)

    -- 0.3s 淡入效果
    if hasAction then
        img:setOpacity(0)
        local action = cc.FadeIn:create(0.3)
        img:runAction(action)
    end
end

function ChildDailyMission2Dlg:cleanup()
    performWithDelay(gf:getUILayer(), function ()
        DlgMgr:showAllOpenedDlg(true)
    end)
    Me:setVisible(true)

    if self.grids then
        for _, v in pairs(self.grids) do
            v:removeFromParent()
        end
        self.grids = nil
    end

    if self.croplandLayer then
        self.croplandLayer:removeFromParent()
        self.croplandLayer = nil
    end

    if self.objectList then
        for _, info in pairs(self.objectList) do
            info:cleanup()
        end
        self.objectList = {}
    end

end

-- 创建农田
function ChildDailyMission2Dlg:creatCropland(image)
    gf:getMapObjLayer():addChild(image, Const.ZORDER_CROPLAND)

    -- 点击农田的响应判断
    local function clickCroplandJudge(image)
        self:onClickGezi(image)

        return true
    end


    if self.croplandLayer then
        return image
    end

    self.croplandLayer = cc.Layer:create()

    gf:getCharTopLayer():addChild(self.croplandLayer)

    local function containsTouchPos(touch)
        local grids = self.grids
        for _, v in ipairs(grids) do
            local pos = v:convertTouchToNodeSpace(touch)
            local rect = {["height"] = 60,["width"] = 94,["x"] = 11,["y"] = 10}
            if cc.rectContainsPoint(rect, pos) then
                return v
            end
        end
    end

    local clickObj
    local function clickCropLand(sender, event)
        if event:getEventCode() == cc.EventCode.BEGAN then
            if self.isClickCropland then
                return
            end

            clickObj = containsTouchPos(sender)
            self.isClickCropland = true
        elseif event:getEventCode() == cc.EventCode.ENDED then
            clickCroplandJudge(clickObj)
            self.isClickCropland = false
        elseif event:getEventCode() == cc.EventCode.CANCELLED then
            self.isClickCropland = false
        end

        return true
    end

    gf:bindTouchListener(self.croplandLayer, clickCropLand, {
    cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
    return image
end

function ChildDailyMission2Dlg:MSG_CHILD_GAME_RESULT(data)
    self:setCtrlVisible("GameResultPanel", true)
    local childResultPanel = self:getControl("WinOrLosePanel_1")
    self:setCtrlVisible("WinBkImage", data.result ~= 1, childResultPanel)
    self:setCtrlVisible("WinImage", data.result ~= 1, childResultPanel)
    self:setCtrlVisible("FailImage", data.result == 1, childResultPanel)

    local myResultPanel = self:getControl("WinOrLosePanel_2")
    self:setCtrlVisible("WinBkImage", data.result == 1, myResultPanel)
    self:setCtrlVisible("WinImage", data.result == 1, myResultPanel)
    self:setCtrlVisible("FailImage", data.result ~= 1, myResultPanel)

    -- 道法
    local daoPanel = self:getControl("Reward1Panel")
    self:setImage("BubbleImage", ResMgr:getIconPathByName(CHS[4101495]), daoPanel)
    self:setLabelText("NumLabel_1", CHS[4101495] .. "：" .. data.daofa, daoPanel)

    local daoPanel = self:getControl("Reward2Panel")
    self:setImage("BubbleImage", ResMgr:getIconPathByName(CHS[4101496]), daoPanel)
    self:setLabelText("NumLabel_1",CHS[4101496] .. "：" .. data.xinfa, daoPanel)

    local daoPanel = self:getControl("Reward3Panel")
    self:setImagePlist("BubbleImage", ResMgr.ui["small_child_qinmidu"], daoPanel)
    self:setLabelText("NumLabel_1",CHS[7190534] .. "：" .. data.qinmi, daoPanel)
    self:setLabelText("Label_44", string.format( CHS[4101538], self.data.child_name))

    self:creatCharDragonBones(Me:queryBasicInt("org_icon"), "PortraitImagePanel", "PortraitBonesPanel_Right")
    self:creatCharDragonBones(self.data.child_icon, "PortraitImagePanel", "PortraitBonesPanel_Left")
end

function ChildDailyMission2Dlg:creatCharDragonBones(icon, panelName, root)
    local panel = self:getControl(panelName, nil, root)
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return magic
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            magic:removeFromParent()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, -13)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    magic:setRotationSkewY(180)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)

    return magic
end

return ChildDailyMission2Dlg
