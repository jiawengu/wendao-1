-- SpeclalRoomEatDlg.lua
-- Created by songcw Dec/2018/21
-- 通天塔-神秘房间-超级大胃王

local SpeclalRoomEatDlg = Singleton("SpeclalRoomEatDlg", Dialog)
local NumImg = require('ctrl/NumImg')

-- 比赛玩家
local PLAYER_CFG = {
    {id = 2000, x = 32, y = 20, xx = 780, yy = 304, dir = 3},
    {id = 3000, x = 37, y = 20, xx = 903, yy = 360, dir = 7},
}
-- 865 324

local NPC_CHOOSE_CFG = {
    {icon = 06018, name = CHS[7190306], mhOffsetX3 = 10, mhOffsetY3 = -40, mhOffsetX7 =   5, mhOffsetY7 = -30},  -- 调皮孩子王
    {icon = 06035, name = CHS[7190309], mhOffsetX3 = 15, mhOffsetY3 = -30, mhOffsetX7 = -20, mhOffsetY7 = -38},  -- 硬朗董老头
}

-- 刷新最后一道菜的百分比
local FINAL_SCORE_PERCENT = 97
local MID_SCORE_PERCENT = 60

function SpeclalRoomEatDlg:init(data)

    self:setFullScreen()
    self:setCtrlFullClientEx("BKBlackPanelGP", "RulePanel")
    self:setCtrlFullClientEx("BKBlackPanelGP", "ChoicePanel")

    self:bindListener("EatButton_1", self.onEatButton)
    self:bindListener("EatButton_2", self.onEatButton)

    -- 隐藏界面、角色
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self:setCtrlVisible("PlayerPanel", false)
    self:setCtrlVisible("EatButton_1", false)
    self:setCtrlVisible("EatButton_2", false)

    self:createTable()

    self:bornTablePlayer()
    self:refreshBarprogress()

    self:hookMsg("MSG_SMFJ_CJDWW_PROGRESS")
    self:hookMsg("MSG_SMFJ_CJDWW_OPER_USER")

    self.clickScore = 0

    self.schedulId = self:startSchedule(function ( )
        -- body
        self:sendCmd()
    end, 0.5)

    if data and data.end_time > gf:getServerTime() then
        gf:startCountDowm(data.end_time, "start")
    end
end


-- 创建倒计时
function SpeclalRoomEatDlg:createCountDown(panel)
    local timePanel = self:getControl("NumPanel", nil, panel)
    local numImage = timePanel:getChildByName("NumImg")
    if not numImage then
        local sz = timePanel:getContentSize()
        numImage = NumImg.new("bfight_num", 1, false, -5)
        numImage:setPosition(sz.width / 2, sz.height / 2)
        numImage:setName("NumImg")
        timePanel:addChild(numImage)
    end

    return numImage
end


function SpeclalRoomEatDlg:sendCmd()
    if not self.stateData or self.stateData.status ~= 2 then return end
    local str = tostring(self.clickScore)
    gf:CmdToServer("CMD_SMFJ_CJDWW_ADD_PROGRESS", {str = gfEncrypt(TttSmfjMgr:getEncrypt(str), tostring(Me:getId()))})
    self.clickScore = 0
end


function SpeclalRoomEatDlg:bornTablePlayer()
end


-- 生成地图上2位比赛的角色
function SpeclalRoomEatDlg:bornTablePlayer()
    CharMgr:MSG_APPEAR({x = PLAYER_CFG[1].x, y = PLAYER_CFG[1].y, dir = PLAYER_CFG[1].dir, id = PLAYER_CFG[1].id,
        icon = NPC_CHOOSE_CFG[1].icon, type = OBJECT_TYPE.NPC, name = CHS[4010295], opacity = 0,
        light_effect_count = 0, isNowLoad = true, sub_type = OBJECT_NPC_TYPE.DWW_NPC})


    CharMgr:MSG_APPEAR({x = PLAYER_CFG[2].x, y = PLAYER_CFG[2].y, dir = PLAYER_CFG[2].dir, id = PLAYER_CFG[2].id,
        icon = NPC_CHOOSE_CFG[2].icon, type = OBJECT_TYPE.NPC, name = CHS[4010295], opacity = 0,
        light_effect_count = 0, isNowLoad = true, sub_type = OBJECT_NPC_TYPE.DWW_NPC})

    for i = 1, #PLAYER_CFG do
        local char = CharMgr:getCharById(PLAYER_CFG[i].id)
            char:setPos(PLAYER_CFG[i].xx, PLAYER_CFG[i].yy)
            char.mhOffsetX = NPC_CHOOSE_CFG[i]["mhOffsetX" .. PLAYER_CFG[i].dir]
            char.mhOffsetY = NPC_CHOOSE_CFG[i]["mhOffsetY" .. PLAYER_CFG[i].dir]

        -- eat动作播放完回调
        local function endActCallBack()
            self:refreshTablePlayer(char)
        end

        char:setAct(Const.FA_EAT, endActCallBack)
    end
end

-- 计算百分比
function SpeclalRoomEatDlg:getPercent(score, maxScore)
    if not score then
        score = self.progressData.progress
    end

    if not maxScore then
        maxScore = self.progressData.total_progress
    end

    local percent = score * 100.0 / maxScore
    percent = math.min(math.floor(percent), 100)
    return percent
end

-- 刷新地图桌子上的菜肴
function SpeclalRoomEatDlg:refreshTableFood(curScore)
    curScore = curScore or 0
    local iconPath = ResMgr.ui.inn_food_bubber_one

    if self.progressData then
        local curPercent = self:getPercent(curScore, self.progressData.total_progress)
        if curPercent >= FINAL_SCORE_PERCENT then

            iconPath = ResMgr.ui.dww_food_two
        elseif curPercent > MID_SCORE_PERCENT then

            iconPath = ResMgr.ui.dww_food_one
        end
    end

    local image = gf:getMapObjLayer():getChildByName("DwwFood")
    if not image then
        image = ccui.ImageView:create(iconPath)
        image.iconPath = iconPath
        image:setAnchorPoint(0.5, 0.5)
        image:setPosition(cc.p(950, 730))
        image:setName("DwwFood")
        gf:getMapObjLayer():addChild(image, 1000)
    else
        if iconPath ~= image.iconPath then
            image:loadTexture(iconPath)
            image.iconPath = iconPath
        end
    end
end


-- 刷新角色eat动作速度
function SpeclalRoomEatDlg:refreshTablePlayer(char)
    if not char then return end

    char:setActSpeed(char.eatSpeed or 1)
end

function SpeclalRoomEatDlg:createTable()
    -- 创建桌子(过图后自动移除)
    local image = ccui.ImageView:create(ResMgr:getFurniturePath(15002))
    image:setAnchorPoint(0.5, 0.5)
    image:setPosition(cc.p(845, 324))
    image:setName("DwwTable")
    gf:getMapObjLayer():addChild(image, 1000)
end

function SpeclalRoomEatDlg:cleanup()
    self.root:stopAllActions()
    -- 创建桌子(过图后自动移除)
    local image = gf:getMapObjLayer():getChildByName("DwwTable")
    if image then
        image:removeFromParent()
    end

    local image = gf:getMapObjLayer():getChildByName("DwwFood")
    if image then
        image:removeFromParent()
    end

    CharMgr:deleteChar(PLAYER_CFG[1].id)
    CharMgr:deleteChar(PLAYER_CFG[2].id)

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    Me:setVisible(true)

    self:stopSchedule(self.scheduleId)
    self.scheduleId = nil
    self.stateData = nil
    self.curOpData = nil
    self.progressData = nil
    self.clickScore = nil

   gf:closeCountDown()
end

-- 计算eat动作速度倍率, 最高正常速度5倍
function SpeclalRoomEatDlg:getEatActSpeed(score)
    return math.min(math.max(1, score / 1.5), 5)
end

-- 是否需要播放飘汗效果
function SpeclalRoomEatDlg:needPlayMagic(score)
    return score >= 6
end

function SpeclalRoomEatDlg:onEatButton(sender, eventType)
    if not self.stateData or self.stateData.status ~= 2 then return end
    gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.midautumn_eat_btn.name, ResMgr.ArmatureMagic.midautumn_eat_btn.action, sender)

    if self.curOpData.name ~= Me:queryBasic("name") then
        self.clickScore = self.clickScore - 0.5
    else
        self.clickScore = self.clickScore + 3
    end
end

function SpeclalRoomEatDlg:MSG_SMFJ_GAME_STATE(data)
    self.stateData = data

    if data.status == 2 then
        self:setCtrlVisible("StartImage", false, root)

        self:setCtrlVisible("EatButton_1", true)
        self:setCtrlVisible("EatButton_2", true)

        gf:startCountDowm(data.end_time, "end")
    elseif data.status == 3 then
        performWithDelay(self.root, function ()
            self:onCloseButton()
        end, 2)
    end
end

function SpeclalRoomEatDlg:MSG_SMFJ_CJDWW_PROGRESS(data)

    self:refreshBarprogress(data.progress, data.total_progress)

    local ret
    local speed
    if self.progressData then
        ret = data.progress - self.progressData.progress
        if ret <= 0 then
            speed = 0
        else
            speed = math.max( 1, ret / 1.5)
            speed = math.min( speed, 5)
        end
    end

    if speed then
        for i = 1, 2 do
            local char = CharMgr:getCharById(PLAYER_CFG[i].id)
            if speed <= 0 then
                char.charAction:pausePlay()
            else

                local function endActCallBack()
                    char.eatSpeed = speed
                    self:refreshTablePlayer(char)
                    char:setAct(Const.FA_EAT, endActCallBack)
                end

                if char.charAction.isPausePlay then
                    -- 若角色动作被停止还应该开启

                    char.charAction:continuePlay()
                    char:setAct(Const.FA_EAT, endActCallBack)
                end
             end

            if ret >= 12 then
                self:addPiaohanMagic(char)
            end
        end
    end

    self.progressData = data
end

-- 增加飘汗效果
function SpeclalRoomEatDlg:addPiaohanMagic(char)
    if not char then return end
    local headX, headY = char.charAction:getHeadOffset()
    local magic = gf:createSelfRemoveMagic(ResMgr.magic.dww_piaohan)
    magic:setAnchorPoint(0.5, 0.5)
    magic:setLocalZOrder(Const.CHARACTION_ZORDER)
    magic:setPosition(char.mhOffsetX, headY + char.mhOffsetY)
    char:addToMiddleLayer(magic)
end

function SpeclalRoomEatDlg:MSG_SMFJ_CJDWW_OPER_USER(data)
    self:setCtrlVisible("PlayerPanel", true)
    self:setImage("PlayerImage", ResMgr:getCirclePortraitPathByIcon(data.icon), "PlayerPanel")
    self:setLabelText("Label_81", data.name)
    self.curOpData = data
end

-- 刷新计分进度条
function SpeclalRoomEatDlg:refreshBarprogress(curScore, maxScore)
    if not curScore then
        curScore = 0
        maxScore = 100
    elseif curScore ~= 0 then
    end

    -- 设置进度
    local barprogress = self:getControl("ExpProgressBar", nil, "GamingPanel")
    local percent = self:getPercent(curScore, maxScore)
    barprogress:setPercent(percent)

    -- 设置数字图片进度
    local nowPanel = self:getControl("Now%Panel", nil, "GamingPanel")
    local numImg = nowPanel:getChildByName("NumImg")
    if not numImg then
        numImg = NumImg.new('sfight_num', percent, false, -2)
        numImg:setAnchorPoint(0.5, 0.5)
        numImg:setName("NumImg")
        local sz = nowPanel:getContentSize()
        numImg:setPosition(sz.width / 2, sz.height / 2)
        nowPanel:addChild(numImg)
    end

    local newNum = percent .. "%"
    if numImg.num and numImg.num ~= newNum then
        numImg:setNumByString(newNum, true)
        numImg:stopAllActions()
        numImg:setScale(1.7)
        numImg:runAction(cc.ScaleTo:create(0.1, 1))
    end

    -- 刷新桌子上的食物图片
    self:refreshTableFood(curScore)
end

return SpeclalRoomEatDlg
