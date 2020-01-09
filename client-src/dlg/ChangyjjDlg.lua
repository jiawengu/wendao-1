-- ChangyjjDlg.lua
-- Created by huangzz July/17/2018
-- 重阳节-畅饮菊酒界面

local ChangyjjDlg = Singleton("ChangyjjDlg", Dialog)

local GAME_STATUS = {
    WAIT = 1,
    PLAYING = 2,
    STOP = 3,
}

local ROUND = {
    PLAYER = 0, 
    OTHER = 1,
}

local NPC_CONFIG = {
    [CHS[3000795]] = {succ = 75 , succ_round = 1, reduce_round = 1, min_succ = 0 , reduce_succ = 9, speed = 100, add_speed = {min = 20, max = 25}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 多闻道人
    [CHS[3000798]] = {succ = 80 , succ_round = 2, reduce_round = 1, min_succ = 0 , reduce_succ = 8, speed = 150, add_speed = {min = 21, max = 26}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 赵老板
    [CHS[3000803]] = {succ = 80 , succ_round = 3, reduce_round = 2, min_succ = 0 , reduce_succ = 8, speed = 170, add_speed = {min = 22, max = 27}, width = 120, reduce_width = {min = 5, max = 10}, gender = 2}, -- 卜老板
    [CHS[3000802]] = {succ = 85 , succ_round = 3, reduce_round = 2, min_succ = 0 , reduce_succ = 7, speed = 185, add_speed = {min = 23, max = 28}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 钱老板
    [CHS[3000799]] = {succ = 85 , succ_round = 3, reduce_round = 3, min_succ = 0 , reduce_succ = 7, speed = 200, add_speed = {min = 24, max = 29}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 张老板
    [CHS[3000800]] = {succ = 90 , succ_round = 3, reduce_round = 3, min_succ = 0 , reduce_succ = 6, speed = 205, add_speed = {min = 25, max = 30}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 王老板
    [CHS[3000801]] = {succ = 90 , succ_round = 3, reduce_round = 3, min_succ = 0 , reduce_succ = 6, speed = 210, add_speed = {min = 26, max = 31}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 贾老板
    [CHS[3000804]] = {succ = 95 , succ_round = 3, reduce_round = 3, min_succ = 0 , reduce_succ = 5, speed = 215, add_speed = {min = 27, max = 32}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 乐善施
    [CHS[3000805]] = {succ = 95 , succ_round = 3, reduce_round = 3, min_succ = 50, reduce_succ = 5, speed = 220, add_speed = {min = 28, max = 33}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 清静散人
    [CHS[3000806]] = {succ = 100, succ_round = 3, reduce_round = 3, min_succ = 60, reduce_succ = 4, speed = 225, add_speed = {min = 29, max = 34}, width = 120, reduce_width = {min = 5, max = 10}, gender = 1}, -- 一叶知秋
    [CHS[3000797]] = {succ = 100, succ_round = 4, reduce_round = 4, min_succ = 70, reduce_succ = 4, speed = 230, add_speed = {min = 30, max = 35}, width = 120, reduce_width = {min = 5, max = 10}, gender = 2}, -- 莲花姑娘
    ["fool"] = {succ = 100, succ_round = 1, reduce_round = 1, min_succ = 0, reduce_succ = 25, speed = 230, add_speed = {min = 35, max = 40}, width = 120, reduce_width = {min = 10, max = 15}, gender = 1},
}
-- 喊话内容
local TALK = {
    CHS[5450299],
    CHS[5450300],
    CHS[5450301],
    CHS[5450302],
    CHS[5450303],
}

local ROUND_SPACE = 3  -- 回合间停顿间隔

local MIN_WIDTH = 45   -- 黄色区域最小宽度

local curNpcConfig
local DOWN_TIME = 30

function ChangyjjDlg:init(param)
    self:setFullScreen()

    CharMgr:setVisible(false)

    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("LeaveButton", self.onLeaveButton)
    self:bindListener("TouchPanel", self.onTouchPanel, nil, true)

    self.gameStatus = GAME_STATUS.WAIT

    self.greenImg = self:getControl("GreenImage")
    self.canMoveSize = self:getControl("CanMovePanel"):getContentSize()

    self.npcName = param.npc_name
    self.npcIcon = param.npc_icon
    self.iid = param.iid
    self.gameType = param.type

    if param.type == "fool" then
        curNpcConfig = NPC_CONFIG["fool"]
        curNpcConfig.gender = tonumber(gf:getGenderByIcon(param.npc_icon))
    else
        curNpcConfig = NPC_CONFIG[self.npcName]
    end

    self:setStartData()

    performWithDelay(self.root, function()
        gf:ShowSmallTips(CHS[5450310])
        self.result = ""
        self:onCloseButton()
    end, math.max(0, param.end_time - gf:getServerTime()))

    self:createCountDown(DOWN_TIME)

    DlgMgr:closeDlg("DramaDlg")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })
end

function ChangyjjDlg:setStartData()
    self.curRound = 0
    self.npcDrinkNum = 0
    self.playerDrinkNum = 0
    self.showResultTime = 0
    self.roundData = {}

    self.result = ""

    self.gameStatus = GAME_STATUS.WAIT

    self:initView()
end

function ChangyjjDlg:cmdResult(result)
    if self.gameType == "fool" then
        local md5 = result == "" and result or string.lower(gfGetMd5(Me:queryBasic("gid") .. self.iid .. result))
        gf:CmdToServer("CMD_FOOLS_DAY_2019_FINISH_GAME", {result = md5})
    else
        local md5 = result == "" and result or string.lower(gfGetMd5(Me:queryBasic("gid") .. self.iid .. result))
        gf:CmdToServer("CMD_CHONGYANG_2018_GAME_FINISH", {result = md5})
    end
end

-- 创建倒计时
function ChangyjjDlg:createCountDown(time)
    self:setCtrlVisible("CountDownPanel", false)
    local numImg = Dialog.createCountDown(self, time, "CountDownPanel")
    numImg:setScale(0.5, 0.5)
end


-- 设置开局倒计时数字
function ChangyjjDlg:startCountDown(time)
    self:setCtrlVisible("CountDownPanel", true)
    Dialog.startCountDown(self, time, "CountDownPanel", nil, function(numImg) 
        self:setCtrlVisible("CountDownPanel", false)
        self:setResult(0)
    end)
end

function ChangyjjDlg:stopCountDown()
    Dialog.stopCountDown(self, "CountDownPanel")
    self:setCtrlVisible("CountDownPanel", false)
end

function ChangyjjDlg:initView()
    -- 设置头像及名字
    self:creatCharDragonBones(self.npcIcon, "NpcBonesPanel", false)
    self:setLabelText("NameLabel", self.npcName, "NpcNamePanel")

    self:creatCharDragonBones(Me:queryBasicInt("icon"), "PlayerBonesPanel", true)
    self:setLabelText("NameLabel", Me:getShowName(), "PlayerNamePanel")

    self:setCtrlVisible("MovePanel", false)
    self:setCtrlVisible("StartButton", true)
    self:setCtrlVisible("LeaveButton", false)
    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("SayPanel", false, "PlayerBonesPanel")
    self:setCtrlVisible("SayPanel", false, "NpcBonesPanel")
    self:setCtrlVisible("TitlePanel", false)
    self:setCtrlVisible("ChoseNpcImage", false)
    self:setCtrlVisible("ChosePlayerImage", false)

    self:showSuccJiuNum()
end

-- 调整游戏难度
function ChangyjjDlg:adjustDifficulty()
    if self.roundData and self.roundData.curRound == self.curRound then
        return
    end

    local lastData = self.roundData
    self.roundData = {}

    if not lastData or self.curRound == 1 then
        self.roundData.curRound = self.curRound
        self.roundData.speed = curNpcConfig.speed
        self.roundData.width = curNpcConfig.width

        if self.curRound >= curNpcConfig.succ_round then
            self.roundData.succ = curNpcConfig.succ
        else
            self.roundData.succ = 100
        end
    else
        self.roundData.curRound = self.curRound

        if self.curRound >= curNpcConfig.succ_round then
            self.roundData.succ = math.max(curNpcConfig.min_succ, curNpcConfig.succ - (self.curRound - curNpcConfig.reduce_round) * curNpcConfig.reduce_succ)
        else
            self.roundData.succ = 100
        end

        self.roundData.speed = lastData.speed + math.random(curNpcConfig.add_speed.min, curNpcConfig.add_speed.max)
        self.roundData.width = math.max(MIN_WIDTH, lastData.width - math.random(curNpcConfig.reduce_width.min, curNpcConfig.reduce_width.max))
    end

    local min = self.roundData.width / 2 + 50
    local max = self.canMoveSize.width - self.roundData.width / 2
    self.roundData.yellowX = math.random(min, max)
end

-- 进行下一回合
function ChangyjjDlg:setNextRoundView()
    self:setCtrlVisible("MovePanel", false)
    self:setCtrlVisible("StartButton", false)
    self:setCtrlVisible("LeaveButton", false)
    self:setCtrlVisible("ResultPanel", false)
    self:setCtrlVisible("TitlePanel", false)
    self:setCtrlVisible("ChoseNpcImage", false)
    self:setCtrlVisible("ChosePlayerImage", false)

    if self.gameStatus == GAME_STATUS.STOP then
        -- 游戏结束
        self:setCtrlVisible("ResultPanel", true)
        self:setCtrlVisible("LeaveButton", true)
        self:setCtrlVisible("WinImage", false, "ResultPanel")
        self:setCtrlVisible("WinBKImage", false, "ResultPanel")
        self:setCtrlVisible("LoseImage", false, "ResultPanel")
        self:setCtrlVisible("LoseBKImage", false, "ResultPanel")
        self:setCtrlVisible("DrawImage", false, "ResultPanel")

        if self.playerDrinkNum > self.npcDrinkNum then
            self:setCtrlVisible("WinImage", true, "ResultPanel")
            self:setCtrlVisible("WinBKImage", true, "ResultPanel")

            self:setLabelText("Label_1", CHS[5450320], "LeaveButton")
            self:setLabelText("Label_2", CHS[5450320], "LeaveButton")

            self.result = "succ"
        elseif self.playerDrinkNum < self.npcDrinkNum then
            self:setCtrlVisible("LoseImage", true, "ResultPanel")
            self:setCtrlVisible("LoseBKImage", true, "ResultPanel")
            self:setLabelText("Label_1", CHS[5450319], "LeaveButton")
            self:setLabelText("Label_2", CHS[5450319], "LeaveButton")
            self.result = "fail"
        else
            self:setCtrlVisible("DrawImage", true, "ResultPanel")
            self:setCtrlVisible("WinBKImage", true, "ResultPanel")
            self:setLabelText("Label_1", CHS[5450319], "LeaveButton")
            self:setLabelText("Label_2", CHS[5450319], "LeaveButton")
            self.result = "draw"
        end

        if self.gameType == "fool" then
            -- 愚人节不显示再来一次
            self:setLabelText("Label_1", CHS[5450320], "LeaveButton")
            self:setLabelText("Label_2", CHS[5450320], "LeaveButton")
        end
    elseif self.gameStatus == GAME_STATUS.PLAYING then
        self:setCtrlVisible("MovePanel", true)
        self:startCountDown(DOWN_TIME)

        self.whoRound = (self.whoRound + 1) % 2

        local yImg = self:getControl("YellowImage")
        if self.whoRound == ROUND.PLAYER then
            -- 玩家回合
            self.curRound = self.curRound + 1
            self:adjustDifficulty()

            local size = yImg:getContentSize()
            yImg:setContentSize(self.roundData.width, size.height)
            yImg:setPositionX(self.roundData.yellowX)

            self:setChat(TALK[1], "PlayerBonesPanel")

            gf:ShowSmallTips(CHS[5450308])

            self:setCtrlVisible("TitlePanel", true)
            self:setCtrlVisible("ChosePlayerImage", true)

            self:playCharDragonBones("PlayerBonesPanel")
            self:stopCharDragonBones("NpcBonesPanel")

            self.greenImg:loadTexture(ResMgr.ui.changyjj_green_circle)
            yImg:loadTexture(ResMgr.ui.changyjj_yellow_block)
        else
            -- npc 回合
            self.npcIsSucc = self.roundData.succ >= math.random(1, 100)
            self.showResultTime = math.random(1, 5)

            self:setChat(TALK[1], "NpcBonesPanel")

            gf:ShowSmallTips(string.format(CHS[5450307], self.npcName))

            self:setCtrlVisible("ChoseNpcImage", true)

            self:playCharDragonBones("NpcBonesPanel")
            self:stopCharDragonBones("PlayerBonesPanel")

            self.greenImg:loadTexture(ResMgr.ui.changyjj_gray_circle)
            yImg:loadTexture(ResMgr.ui.changyjj_red_block)
        end

        self.greenImgDir = 1
        self.greenImg:setPositionX(0)
    end
end

function ChangyjjDlg:showResult()
    self:setCtrlVisible("CountDownPanel", false)
end

function ChangyjjDlg:creatCharDragonBones(icon, panelName, isFilp)
    local portraitsPanel = self:getControl(panelName)

    local panel = self:getControl("ShapeChildPanel", nil, portraitsPanel)

    local magic = panel:getChildByName("charPortrait")
    
    if magic then 
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end

    panel:removeAllChildren()
    
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")   
    magic:setPosition(panel:getContentSize().width * 0.5 + 16, 26)
    magic:setName("charPortrait")
    magic:setTag(icon)
    magic:setRotationSkewY(isFilp and 180 or 0)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    self[panelName] = dbMagic
    return magic
end

function ChangyjjDlg:stopCharDragonBones(panelName)
    if self[panelName] then
        DragonBonesMgr:toStop(self[panelName], "stand", 1)
    end
end


function ChangyjjDlg:playCharDragonBones(panelName)
    if self[panelName] then
        DragonBonesMgr:toPlay( self[panelName] , "stand", 0)
    end
end

function ChangyjjDlg:showSuccJiuNum()
    local panel = self:getControl("NpcCountPanel")
    for i = 1, 8 do
        self:setCtrlVisible("GlassImage" .. i, i <= self.npcDrinkNum, panel)
    end

    local numImg = self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.B_FIGHT, self.npcDrinkNum, false, LOCATE_POSITION.CENTER, 25, "NpcCountPanel")
    numImg:setScale(0.35, 0.35)


    panel:setVisible(self.npcDrinkNum ~= 0)

    local panel = self:getControl("PlayerCountPanel")
    for i = 1, 8 do
        self:setCtrlVisible("GlassImage" .. i, i <= self.playerDrinkNum, panel)
    end

    local numImg = self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.B_FIGHT, self.playerDrinkNum, false, LOCATE_POSITION.CENTER, 23, "PlayerCountPanel")
    numImg:setScale(0.35, 0.35)

    panel:setVisible(self.playerDrinkNum ~= 0)
end

function ChangyjjDlg:onStartButton(sender, eventType)
    self.gameStatus = GAME_STATUS.PLAYING
    self.whoRound = ROUND.OTHER
    self.curRound = 0
    self.npcDrinkNum = 0
    self.playerDrinkNum = 0
    self.roundData = {}

    self:showSuccJiuNum()
    self:setNextRoundView()
end

function ChangyjjDlg:onLeaveButton(sender, eventType)
    if self.result == "succ" or self.gameType == "fool" then
        self:onCloseButton()
    else
        self.result = ""
        self:onStartButton()
    end
end

function ChangyjjDlg:onTouchPanel(sender, eventType)
    if self.gameStatus ~= GAME_STATUS.PLAYING or self.whoRound ~= ROUND.PLAYER then
        return
    end

    if eventType == ccui.TouchEventType.began then
        self:setResult()
    end
end

function ChangyjjDlg:setResult(result)
    self.gameStatus = GAME_STATUS.WAIT
    self:stopCountDown()
    local curX = self.greenImg:getPositionX()
    if result ~= 0 and (result == 1 or self:isInYellowPanel(curX)) then
        -- 踩在黄色板上, 成功
        if self.whoRound == ROUND.PLAYER then
            self:setChat(TALK[2], "PlayerBonesPanel")
            self.playerDrinkNum = self.playerDrinkNum + 1
        else
            self:setChat(TALK[2], "NpcBonesPanel")
            self.npcDrinkNum = self.npcDrinkNum + 1

            if self.npcDrinkNum > self.playerDrinkNum then
                self:setChat(TALK[4] .. "#15" .. BrowMgr:getGenderSign(), "PlayerBonesPanel")
                self.gameStatus = GAME_STATUS.STOP
            end
        end

        self:showSuccJiuNum()
    else
        -- 失败
        if self.whoRound == ROUND.PLAYER then
            self:setChat(TALK[3], "PlayerBonesPanel")
        else
            if self.npcDrinkNum == self.playerDrinkNum then
                self:setChat(TALK[5], "NpcBonesPanel")
                self:setChat(TALK[5], "PlayerBonesPanel")
                self.gameStatus = GAME_STATUS.STOP
            elseif self.npcDrinkNum < self.playerDrinkNum then
                self:setChat(TALK[4]  .. "#15" .. BrowMgr:getGenderSign(curNpcConfig.gender), "NpcBonesPanel")
                self.gameStatus = GAME_STATUS.STOP
            end
        end
    end
    
    if self.gameStatus == GAME_STATUS.STOP then
        if self.whoRound == ROUND.PLAYER then
            self:playCharDragonBones("NpcBonesPanel")
        else
            self:playCharDragonBones("PlayerBonesPanel")
        end

        self:setCtrlVisible("ChoseNpcImage", false)
        self:setCtrlVisible("ChosePlayerImage", false)
    end
    
    performWithDelay(self.root, function()
        if self.gameStatus ~= GAME_STATUS.STOP then
            self.gameStatus = GAME_STATUS.PLAYING
        end

        self:setNextRoundView()
    end, ROUND_SPACE)
end

function ChangyjjDlg:setChat(str, ctrlName)
    local panel = self:getControl(ctrlName)
    local labelPanel = self:getControl("LabelPanel", nil, panel)
    local locate = ctrlName == "PlayerBonesPanel" and LOCATE_POSITION.RIGHT_BOTTOM or nil
    self:setColorText(str, labelPanel, nil, 0, 0, nil, 21, locate, nil, nil)

    local textNode = labelPanel:getChildByTag(Dialog.TAG_COLORTEXT_CTRL)
    local textCtrl = tolua.cast(textNode, "CGAColorTextList")
    local textW, textH = textCtrl:getRealSize()
    
    -- labelPanel:setContentSize(textW , textH)

    local backImage = self:getControl("InfoBackImage1", nil, panel)
    backImage:setContentSize(textW + 18, textH + 34)

    local sayPanel = self:getControl("SayPanel", nil, panel)
    sayPanel:requestDoLayout()

    sayPanel:setVisible(true)
    sayPanel:stopAllActions()
    performWithDelay(sayPanel, function() 
        sayPanel:setVisible(false)
    end, 3)
end

function ChangyjjDlg:onUpdate(delayTime)
    if self.gameStatus ~= GAME_STATUS.PLAYING then
        return
    end

    self:moveGreenImg(delayTime)
end

function ChangyjjDlg:moveGreenImg(delayTime)
    local curX = self.greenImg:getPositionX()

    if self.greenImgDir == 1 then
        -- 向右移
        curX = math.floor(curX + self.roundData.speed * delayTime)
        if curX >= self.canMoveSize.width then
            curX = self.canMoveSize.width
            self.greenImgDir = 0
        end
    else
        -- 向左移
        curX = math.floor(curX - self.roundData.speed * delayTime)
        if curX <= 0 then
            curX = 0
            self.greenImgDir = 1
        end
    end

    self.greenImg:setPositionX(curX)

    self.showResultTime = self.showResultTime - delayTime
    if self.whoRound == ROUND.OTHER and self.showResultTime <= 0 then
        if self.npcIsSucc then
            -- 踩在黄色板上，再判赢
            if self:isInYellowPanel(curX) then
                self:setResult(1)
            end
        elseif not self:isInYellowPanel(curX, 20)
                and self:isInYellowPanel(curX, 60) then
            -- 未踩在黄色板上，再判输
            self:setResult(0)
        end
    end
end

function ChangyjjDlg:isInYellowPanel(curX, offset)
    offset = offset or 0
    if math.abs(curX - self.roundData.yellowX) <= self.roundData.width / 2 - 15 + offset then
        return true
    end
end

function ChangyjjDlg:cleanup()
    self:cmdResult(self.result)

    self:releaseBones("NpcBonesPanel")
    self:releaseBones("PlayerBonesPanel")

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    if not Me:isInCombat() and not Me:isLookOn() then
        CharMgr:setVisible(true)
    end
end

function ChangyjjDlg:releaseBones(root)
    -- 如果有骨骼动画时，释放相关资源 
    local panel = self:getControl("ShapeChildPanel", nil, root)
    local magic = panel:getChildByName("charPortrait")

    if magic then 
        DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))  
    end
end



return ChangyjjDlg
