-- ChildDailyMission1Dlg.lua
-- Created by songcw Apir/14/2019
-- 娃娃日常-【养育】论道


local ChildDailyMission1Dlg = Singleton("ChildDailyMission1Dlg", Dialog)
local NumImg = require('ctrl/NumImg')
local RadioGroup = require("ctrl/RadioGroup")

local DEFAULT_TIME_MAX = 25
local TIME_MAGIN = 2
local ROUND_MAX = 16

local CONFIG = {
    [CHS[4101506]] = {desc = CHS[4101507],     cost_desc = CHS[4101508], value = 1, power = 5},
    [CHS[4101509]] = {desc = CHS[4101510],     cost_desc = CHS[4101511], value = 2, power = 40},
    [CHS[4101512]] = {desc = CHS[4101513],     cost_desc = CHS[4101511], value = 1},
    [CHS[4101514]] = {desc = CHS[4101515],     cost_desc = CHS[4101516], power = 10},
}

local SHOW_CONFIG = {
    [CHS[4101506]] = {
        SUCC_TALK = {CHS[4101517], CHS[4101518], CHS[4101519], CHS[4101520]},
        SUCC_ACT = CHS[4101521],
    },
    [CHS[4101509]] = {
        SUCC_TALK = {CHS[4101522], CHS[4101523]},

        FAIL_TALK = {CHS[4101524], CHS[4101525]},
    },
    [CHS[4101512]] = {
        SUCC_TALK = {CHS[4101526]},

    },
    [CHS[4101514]] = {
        SUCC_TALK = {CHS[4101527], CHS[4101528], CHS[4101529], CHS[4101530]},
        FAIL_TALK = {CHS[4101531]},
    },
}

--              摆事实             讲道理     曲解          空谈
local OP_MAP = {CHS[4101506], CHS[4101509], CHS[4101512], CHS[4101514]}

local CHECKBOS = {
    "CheckBox_1", "CheckBox_2", "CheckBox_3", "CheckBox_4",
}



function ChildDailyMission1Dlg:init(data)
    self:setFullScreen()
    self:setImage("Image_75", ResMgr.ui.fight_bg_img)
    self:setCtrlFullClient("Image_75", "BKPanel")

    self:bindListener("RuleButton", self.onRuleButton)
    self:bindListener("Button_1", self.onButton_1)
    self:bindListener("Button_2", self.onButton_2)
    self:bindListener("Button_3", self.onButton_3)
    self:bindListener("Button_4", self.onButton_4)
    self:bindListener("UseButton", self.onSelectButton)
    self:bindListener("GoButton", self.onGoButton)
    self:bindListener("RulePanel", self.onRulePanel)
    self:bindListener("ContinueButton", self.onContinueButton)
    self:bindFloatPanelListener("RulePanel", nil, nil, function ()
        self.numImg:continueCountDown()
    end)
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("GameResultPanel", false)

    for i = 1, 4 do
        self:setCtrlVisible("LocationImage" .. i, false)
    end

    -- 隐藏居所家具及农作物
    HomeMgr:setFurnitureAndCropsVisible(false)

    -- 初始化倒计时panel
    self:initTimePanel()

    -- 添加战斗背景
    --self:addFightBg()

    -- 隐藏主界面相关操作
    -- 隐藏主界面相关操作
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1, })

    self.myLimit = {}   -- 被封印的
    self.childLimit = {}    -- 娃娃被封印的
    self.isOver = false

    self.data = data

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOS, self.onCheckBox)

    -- 创建游戏角色
    self:initGameChar()

    self:beginRound(1)

    self:hookMsg("MSG_CHILD_GAME_RESULT")

    --self:onButton_1()
end

-- 设置向下图标
function ChildDailyMission1Dlg:setDownImage(tag)
    for i = 1, 4 do
        self:setCtrlVisible("LocationImage" .. i, tag == i)

        self:setCtrlVisible("Image", tag == i, "Button_" .. i)
    end
end

function ChildDailyMission1Dlg:initGameChar()
    -- 自己
    local info = {icon = Me:queryBasicInt("org_icon"), name = Me:getName(), vip_type = Me:isVip() and 1 or 0, dir = 1}
    local x, y = self:getControl("TestPanel1"):getPosition()
    self.myChar = self:createChar(info, cc.p(x, y), self:getControl("TestPanel1"))


    -- 娃娃
    local info = {icon = self.data.child_icon ,name = self.data.child_name, vip_type = Me:isVip() and 1 or 0, dir = 5}
    local x, y = self:getControl("TestPanel2"):getPosition()
    self.child =  self:createChar(info, cc.p(x, y), self:getControl("TestPanel2"))
end

function ChildDailyMission1Dlg:onCloseButton(sender, eventType)

    if self:getCtrlVisible("GameResultPanel") then
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
        return
    end

    gf:confirm(CHS[4101499], function ( )
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    end)
end

function ChildDailyMission1Dlg:onContinueButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
end


function ChildDailyMission1Dlg:onRuleButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
    self.numImg:pauseCountDown()
end

function ChildDailyMission1Dlg:playJdlWinAction(char, actInfo)
    local ran = math.random(1, #SHOW_CONFIG[actInfo.op]["SUCC_TALK"])
    local msg = SHOW_CONFIG[actInfo.op]["SUCC_TALK"][ran]
    local addValue = CONFIG[actInfo.op].value

    local fact = char:queryBasicInt("fact")
    char:setBasic("fact", fact - addValue)
    char:setChat({msg = msg, show_time = 3}, nil, true)

    char.charAction:playActionOnce(function ( )
        -- body
        char:updateFlag()
    end)
end

function ChildDailyMission1Dlg:playBssWinAction(char, actInfo)
    local ran = math.random(1, #SHOW_CONFIG[actInfo.op]["SUCC_TALK"])
    local msg = SHOW_CONFIG[actInfo.op]["SUCC_TALK"][ran]
    local addValue = CONFIG[actInfo.op].value

    local fact = char:queryBasicInt("fact")
    char:setBasic("fact", math.min(5, fact + addValue))
    char:setChat({msg = msg, show_time = 3}, nil, true)
    magic = char:addMagicOnFoot(8383, true, nil, nil, nil, function ( )
        char:updateFlag()
        magic:removeFromParent()
    end)
end

function ChildDailyMission1Dlg:playDefenseAction(char, power)

    -- 播放受击
    local function parrayCallBack()
        if char.faAct == Const.FA_DEFENSE_START then
            performWithDelay(char.charAction, function()
                char:setAct(Const.FA_DEFENSE_END, parrayCallBack)

                if power then
                    local life = char:queryBasicInt("life")
                    local curLife = math.max( 0, life - power)
           --         gf:ShowSmallTips("剩余#R" .. curLife .. "#n血量")
                    char:setBasic("life", curLife)
                    char:updateLifeProgress()
                    char:showLifeDeltaNumber(-power)
                end

            end, 0.2)
        else
            char:setAct(Const.FA_STAND)
        end
    end

    performWithDelay(self.root, function ( )
        char:setAct(Const.FA_DEFENSE_START, parrayCallBack)
    end, 1)

end

function ChildDailyMission1Dlg:gameOver(char, isDelay)

    self.isOver = true

    if isDelay then
        performWithDelay(self.root, function ()
            local result = char ~= self.myChar and "succ" or "fail"
            gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt(result, self.data.pwd)})
        end, 2)
    else
        local result = char ~= self.myChar and "succ" or "fail"
        gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt(result, self.data.pwd)})
    end
end


function ChildDailyMission1Dlg:beginRound(round)
    -- 同步数据
    --gf:CmdToServer("CMD_CHILD_SYNC_GAME_DATA", {is_get_reward = 0})


    if round >= ROUND_MAX then
        if self.myChar:queryBasicInt("life") > self.child:queryBasicInt("life") then
            self.child:setChat({msg = CHS[4101532], show_time = 3}, nil, true)
            self.child:setDieAction()
            self:gameOver(self.child, true)
        else
            self.myChar:setChat({msg = CHS[4101532], show_time = 3}, nil, true)
            self.myChar:setDieAction()
            self:gameOver(self.myChar, true)
        end


        return
    end

    self.round = round
    self:setLabelText("Label_45", string.format(CHS[4101533], round))
    self:setCtrlVisible("SelectPanel", true)

    self:checkButtonState()
    self:onCheckBox(self:getControl(CHECKBOS[1]), 1)
    self.radioGroup:setSetlctByName(CHECKBOS[1])

    self:startCountDown(DEFAULT_TIME_MAX)
end


function ChildDailyMission1Dlg:onCheckBox(sender, idx)
    self:setOper(OP_MAP[idx])

    if idx == 2 then
        if sender.isGray and not self.myLimit[self.round] then
            gf:ShowSmallTips(CHS[4101534])
            return
        end

        if self.myLimit[self.round] then
            gf:ShowSmallTips(CHS[4101535])
            return
        end
    end

    if idx == 3 then
        if sender.isGray then
            gf:ShowSmallTips(CHS[4101536])
            return
        end
    end

    return true
end

--[[
function ChildDailyMission1Dlg:onButton_1(sender, eventType)
    self:setDownImage(1)
    self:setOper(CHS[4101506])


end

function ChildDailyMission1Dlg:onButton_2(sender, eventType)
    self:setDownImage(2)
    self:setOper(CHS[4101509])
    if sender.isGray and not self.myLimit[self.round] then
        gf:ShowSmallTips(CHS[4101534])
        return
    end

    if self.myLimit[self.round] then
        gf:ShowSmallTips(CHS[4101535])
        return
    end

    return true
end

function ChildDailyMission1Dlg:onButton_3(sender, eventType)
    self:setDownImage(3)
    self:setOper(CHS[4101512])
    if sender.isGray then
        gf:ShowSmallTips(CHS[4101536])
        return
    end

    return true
end

function ChildDailyMission1Dlg:onButton_4(sender, eventType)
    self:setDownImage(4)
    self:setOper(CHS[4101514])
end
--]]
function ChildDailyMission1Dlg:checkButtonState()
    local btn2 = self:getControl("CheckBox_2")

    if self.myChar:queryBasicInt("fact") < 2 then
        gf:grayImageView(btn2)
        self:getControl("Label_163", nil, btn2):setColor(COLOR3.GRAY)
    else
        gf:resetImageView(btn2)
        self:getControl("Label_163", nil, btn2):setColor(COLOR3.TEXT_DEFAULT)
    end

    local btn3 = self:getControl("CheckBox_3")
    if self.myChar:queryBasicInt("fact") < 1 then
        gf:grayImageView(btn3)
        self:getControl("Label_163", nil, btn3):setColor(COLOR3.GRAY)
    else
        gf:resetImageView(btn3)
        self:getControl("Label_163", nil, btn3):setColor(COLOR3.TEXT_DEFAULT)
    end

    if not btn2.isGray and self.myLimit[self.round] then
        self:getControl("Label_163", nil, btn2):setColor(COLOR3.GRAY)
        gf:grayImageView(btn2)
    end
end

function ChildDailyMission1Dlg:setOper(op)

    local panel = self:getControl("DescPanel")
    self:setLabelText("NameLabel", op, panel)
    self:setLabelText("NumLabel", CONFIG[op].cost_desc, panel)
    self:setLabelText("DescLabel", CONFIG[op].desc or "", panel)

    self.myOp = op

    local color = COLOR3.EQUIP_NORMAL
    if self.myChar:queryBasicInt("fact") < 2 and op == CHS[4101509] then
        color = COLOR3.RED
    end

    if self.myChar:queryBasicInt("fact") < 1 and op == CHS[4101512] then
        color = COLOR3.RED
    end
    self:setLabelText("NumLabel_1", CONFIG[op].value or "", panel, color)

    self:checkButtonState()
    --self:onButton_1()

    -- 判断是否被限制了
    if self.myChar:queryBasicInt("fact") >= 2 and op == CHS[4101509] and self.myLimit[self.round] then
        self:setLabelText("CostLabel", "", panel)
        self:setLabelText("ActValueLabel", CHS[4101537], panel, COLOR3.RED)
    end
end

function ChildDailyMission1Dlg:onSelectButton(sender, eventType)

    if self.myOp == CHS[4101509] then
        if not self:onCheckBox(self:getControl(CHECKBOS[2]), 2) then
            return
        end
    end

    if self.myOp == CHS[4101512] then
        if not self:onCheckBox(self:getControl(CHECKBOS[3]), 3) then
            return
        end
    end

    self:setCtrlVisible("SelectPanel", false)
    self.actions = self:dealWithOp()
    self.actStep = 1
    self:showActions(self.actStep)
    self:showPleaseWait(false)
end

function ChildDailyMission1Dlg:showActions(step)
    if self.isOver then
        return
    end

    if step > #self.actions then
        -- 这回合播放结束了
        self:beginRound(self.round + 1)
        return
    end

    local actInfo = self.actions[step]

    local power = CONFIG[actInfo.op].power
    if actInfo.op == CHS[4101506] then  -- 摆事实

        if actInfo.isSucc then
            if actInfo.isMe then
                -- 赢方动作
                self:playBssWinAction(self.myChar, actInfo)
                -- 输方
                self:playDefenseAction(self.child, power)
            else
                self:playBssWinAction(self.child, actInfo)
                self:playDefenseAction(self.myChar, power)
            end
        else
            -- 失败无表现
        end
        performWithDelay(self.root, function ( )
            self:showActions(step + 1)
        end, TIME_MAGIN)
    elseif actInfo.op == CHS[4101509] or actInfo.op == CHS[4101512] then    -- 讲道理  曲解
        if actInfo.isSucc then
            if actInfo.isMe then
                self:playJdlWinAction(self.myChar, actInfo)
                self:playDefenseAction(self.child, power)
            else
                self:playJdlWinAction(self.child, actInfo)
                self:playDefenseAction(self.myChar, power)
            end
        else
            local ran = math.random(1, #SHOW_CONFIG[actInfo.op]["FAIL_TALK"])
            local msg = SHOW_CONFIG[actInfo.op]["FAIL_TALK"][ran]
            if actInfo.isMe then
                self.myChar:setChat({msg = msg, show_time = 3}, nil, true)
                local fact = self.myChar:queryBasicInt("fact")
                self.myChar:setBasic("fact", fact - 2)
                self.myChar:updateFlag()
            else
                self.child:setChat({msg = msg, show_time = 3}, nil, true)
                local fact = self.child:queryBasicInt("fact")
                self.child:setBasic("fact", fact - 2)
                self.child:updateFlag()
            end
        end

        performWithDelay(self.root, function ( )
            self:showActions(step + 1)
        end, TIME_MAGIN)
    elseif actInfo.op == CHS[4101514] then
        if actInfo.isSucc then
            if actInfo.isMe then
                self:playKtWinAction(self.myChar, actInfo, self.child, step)
            else
                self:playKtWinAction(self.child, actInfo, self.myChar, step)
            end
        else
            if actInfo.isMe then
                self:playKtLoseAction(self.myChar, actInfo, step)
            else
                self:playKtLoseAction(self.child, actInfo, step)
            end
        end
    end
end

function ChildDailyMission1Dlg:playKtLoseAction(char, actInfo, step)
    local ran = math.random(1, #SHOW_CONFIG[actInfo.op]["FAIL_TALK"])
    local msg = SHOW_CONFIG[actInfo.op]["FAIL_TALK"][ran]
    char:setChat({msg = msg, show_time = 3}, nil, true)
    char:startRandomWalk(0, math.random(2, 3), function ( )
        local addValue = CONFIG[actInfo.op].value

        performWithDelay(self.root, function ( )
            self:showActions(step + 1)
        end, 2)
    end)
end

function ChildDailyMission1Dlg:playKtWinAction(char, actInfo, failChar, step)
    local ran = math.random(1, #SHOW_CONFIG[actInfo.op]["SUCC_TALK"])
    local msg = SHOW_CONFIG[actInfo.op]["SUCC_TALK"][ran]
    char:setChat({msg = msg, show_time = 3}, nil, true)
    char:startRandomWalk(0, math.random(2, 3), function ( )
        local addValue = CONFIG[actInfo.op].value

        performWithDelay(self.root, function ( )
            self:showActions(step + 1)
        end, 2)

        char.charAction:playActionOnce()
        local power = CONFIG[actInfo.op].power
        self:playDefenseAction(failChar, power)
    end)
end

-- 处理双方操作
function ChildDailyMission1Dlg:dealWithOp()
    local actionTab = {}
    --[[
    table.insert( actionTab, {isMe = false, op = CHS[4101514], isSucc = true} )
    table.insert( actionTab, {isMe = true, op = CHS[4101514], isSucc = true} )
    if 1 then return actionTab end

    local actionTab = {}
    --]]
    local childOp = self:getChildOp()

--[[

    曲解  赢 讲道理
    讲道理 赢 空谈
]]


    -- 看看有没有克制关系
    if self.myOp == CHS[4101512] and childOp == CHS[4101509] then
        -- 我曲解对方讲道理，我赢对方失效
        table.insert( actionTab, {isMe = false, op = CHS[4101509], isSucc = false} )
        table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
        self.childLimit[self.round + 1] = true
    elseif self.myOp == CHS[4101509] and childOp == CHS[4101512] then
        -- 对方曲解我讲道理，
        table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = false} )
        table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )

        self.myLimit[self.round + 1] = true
    elseif self.myOp == CHS[4101509] and childOp == CHS[4101514] then
        -- 我讲道理对方空谈，我赢
        table.insert( actionTab, {isMe = false, op = childOp, isSucc = false} )
        table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
    elseif self.myOp == CHS[4101514] and childOp == CHS[4101509] then
        -- 我空谈对方讲道理，对方赢
        table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = false} )
        table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )
    else
        if self.myChar:queryBasicInt("life") == self.child:queryBasicInt("life") then
            if gfGetTickCount() % 2 == 1 then
                table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
                table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )
            else
                table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )
                table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
            end
        else
            if self.myChar:queryBasicInt("life") < self.child:queryBasicInt("life") then
                table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
                table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )
            else
                table.insert( actionTab, {isMe = false, op = childOp, isSucc = true} )
                table.insert( actionTab, {isMe = true, op = self.myOp, isSucc = true} )
            end
        end

        if self.myOp == CHS[4101512] then   -- 曲解
            self.childLimit[self.round + 1] = true
        end

        if childOp == CHS[4101512] then   -- 曲解
            self.myLimit[self.round + 1] = true
        end
    end



--[[

    for i = 1, 10 do
        Log:D(" ")
    end

    for _, info in pairs(actionTab) do
        local str = ""
        if info.isMe then
            str = "#R我#n使用"
        else
            str = "#R娃娃#n使用"
        end

        str = str .. "#R" .. info.op .. "#n"
        if info.isSucc then
            str = str .. "，#R成功#n了"
        else
            str = str .. "，#R失败了#n了"
        end
        gf:ShowSmallTips(str)
        Log:D(str)
    end
--]]
    return actionTab
end

function ChildDailyMission1Dlg:getChildOp()
    local opMap = gf:deepCopy(OP_MAP)

--    OP_MAP = {CHS[4101506], CHS[4101509], CHS[4101512], CHS[4101514]}
    -- 被限制了重写选
    if self.childLimit[self.round] then
        table.remove( opMap, 2 )
    end

    for i, op in pairs(opMap) do
        if op == CHS[4101509] and self.child:queryBasicInt("fact") < 2 then
            table.remove( opMap, i )
        end
    end

    for i, op in pairs(opMap) do
        if op == CHS[4101512] and self.child:queryBasicInt("fact") < 1 then
            table.remove( opMap, i )
        end
    end

    local op = math.random(1, #opMap)
    return opMap[op]
end


function ChildDailyMission1Dlg:onRulePanel(sender, eventType)
    self:setCtrlVisible("RulePanel", false)
    self.numImg:continueCountDown()
end

function ChildDailyMission1Dlg:onGoButton(sender, eventType)
end

-- 创建角色
function ChildDailyMission1Dlg:createChar(info, pos, layer)
    local char = require("obj/activityObj/ChildGameNpc").new()
    char:absorbBasicFields({
        icon = info.icon,
        name = info.name or "",
        dir = info.dir or 5,
        vip_type = info.vip_type,
        max_life = 150,
        life = 150,
        fact = 0,
        org_x = 0,
        org_y = 0,
        org_dir = info.dir or 5,
    })

    char:setAct(Const.FA_STAND)

    char:onEnterScene(0, 0, layer)

    return char
end

function ChildDailyMission1Dlg:addFightBg()
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
    self.root:addChild(self.bgImage)
    end

    if not self.bgImage2:getParent() then
    --gf:getMapLayer():addChild(self.bgImage2)
    end


end

function ChildDailyMission1Dlg:initTimePanel()
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
function ChildDailyMission1Dlg:startCountDown(time)
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

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)
        self.myOp = OP_MAP[1]
        self:onSelectButton()
    end)

    if self:getCtrlVisible("RulePanel") then
        self.numImg:pauseCountDown()
    end
end

-- 设置是否显示等待提示
function ChildDailyMission1Dlg:showPleaseWait(show)
    if show then
        self.numImg:stopCountDown()
        self.numImg:setVisible(false)
        self.waitImg:setVisible(true)
        self:setCtrlVisible("TimePanel", true)

      --  FightMgr:hideOperateDlgs()
    else
        self.waitImg:setVisible(false)
        self:setCtrlVisible("TimePanel", false)
    end
end

-- 返回剩余倒计时
function ChildDailyMission1Dlg:getLeftTime()
    if self.numImg then
        return self.numImg.num
    else
        return 0
    end
end

function ChildDailyMission1Dlg:cleanup()
--[[
    if self.bgImage then
        self.bgImage:removeFromParent()
        self.bgImage = nil
    end

    if self.bgImage2 then
  --      self.bgImage2:removeFromParent()
        self.bgImage2 = nil
    end
]]
    performWithDelay(gf:getUILayer(), function ()
        DlgMgr:showAllOpenedDlg(true)
    end)
    Me:setVisible(true)

    -- 显示居所家具及农作物
    HomeMgr:setFurnitureAndCropsVisible(true)

    if self.myChar then
        self.myChar:cleanup()
        self.myChar = nil
    end

    if self.child then
        self.child:cleanup()
        self.child = nil
    end
end

function ChildDailyMission1Dlg:MSG_CHILD_GAME_RESULT(data)
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
    self:setImage("BubbleImage", ResMgr:getIconPathByName(CHS[4101504]), daoPanel)
    self:setLabelText("NumLabel_1", CHS[4101504] .. "：" .. data.daofa, daoPanel)

    local daoPanel = self:getControl("Reward2Panel")
    self:setImage("BubbleImage", ResMgr:getIconPathByName(CHS[4101505]), daoPanel)
    self:setLabelText("NumLabel_1", CHS[4101505] .. "：" .. data.xinfa, daoPanel)

    local daoPanel = self:getControl("Reward3Panel")
    self:setImagePlist("BubbleImage", ResMgr.ui["small_child_qinmidu"], daoPanel)
    self:setLabelText("NumLabel_1", CHS[7190534] .. "：" .. data.qinmi, daoPanel)

    self:setLabelText("Label_44", string.format( CHS[4101538], self.data.child_name))

    self:creatCharDragonBones(Me:queryBasicInt("org_icon"), "PortraitImagePanel", "PortraitBonesPanel_Right")

    self:creatCharDragonBones(self.data.child_icon, "PortraitImagePanel", "PortraitBonesPanel_Left")
    --self:setCtrlVisible("Reward3Panel", false)
end

function ChildDailyMission1Dlg:creatCharDragonBones(icon, panelName, root)
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


return ChildDailyMission1Dlg
