-- AnniversaryLingMaoDlg.lua
-- Created by huangzz Feb/08/2018
-- 驯养灵猫主界面

local AnniversaryLingMaoDlg = Singleton("AnniversaryLingMaoDlg", Dialog)

local TOUCH_INTERVAL_TIME = 30 * 60 -- 抚摸灵猫的时间间隔

-- 灵猫提示
local LINGMAO_TIPS = {
    [1] = {
        num = 20,
        {
            {tip = CHS[5400525]},
            {tip = CHS[5400526]},
            {tip = CHS[5400527]},
            {tip = CHS[5400528]},
            {tip = CHS[5400529]},
            {tip = CHS[5400530]},
            {tip = CHS[5400531]},
            {tip = CHS[5400532]},
        },
        {
            {tip = CHS[5400537]},
            {tip = CHS[5400538]},
            {tip = CHS[5400539]},
            {tip = CHS[5400540]},
            {tip = CHS[5400541]},
            {tip = CHS[5400542]},
            {tip = CHS[5400543]},
            {tip = CHS[5400544]},
        }
    },

    [2] = {
        num = 40,
        {
            {tip = CHS[5400533]},
            {tip = CHS[5400534]},
            {tip = CHS[5400535]},
            {tip = CHS[5400536]},
        },
        {
            {tip = CHS[5400545]},
            {tip = CHS[5400546]},
            {tip = CHS[5400547]},
            {tip = CHS[5400548]},
        }
    },

    [3] = {
        num = 101,
        {
            {tip = CHS[5400550]},
            {tip = CHS[5400551]},
            {tip = CHS[5400552]},
            {tip = CHS[5400553]},
            {tip = CHS[5400554]},
            {tip = CHS[5400555]},
            {tip = CHS[5400556]},
            {tip = CHS[5400557]},
            {tip = CHS[5400558]},
            {tip = CHS[5400559]},
            {tip = CHS[5400560]},
            {tip = CHS[5400561]},
            {tip = CHS[5400562], sexFlag = true},
            {tip = CHS[5400563]},
            {tip = CHS[5400564]},
            {tip = CHS[5400565]},
            {tip = CHS[5400567]},
            {tip = CHS[5400568]},
        }
    }
}

function AnniversaryLingMaoDlg:init(data)
    self:bindListener("CombatButton", self.onCombatButton)
    self:bindListener("LearnButton", self.onLearnButton)
    self:bindListener("FoodButton", self.onFoodButton)
    self:bindListener("MoodButton", self.onMoodButton)
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("FindButton", self.onFindButton)
    self:bindListener("EnvelopeButton", self.onEnvelopeButton)
    self:bindListener("Panel_4", self.onChat, "LingMaoMagicPanel_1")
    self:bindListener("Panel_4", self.onChat, "LingMaoMagicPanel_2")
    self:bindListener("Panel_4", self.onChat, "LingMaoMagicPanel_3")
    
    self.lingMaoStatus = 2   -- 1 活跃， 2 未配置， 3 睡觉
    self.letterMagic = nil   -- 信封骨骼动画
    self.lingmao = {}        -- 灵猫龙骨动画
    self.myLingMaoInfo = nil -- 存储灵猫数据
    self.needWait = false    -- 标记灵猫形象是否等动作播放完在刷新
    
    self.chatContent = {}

    self:startSchedule(function()
        local curTime = gf:getServerTime()
        self:setCanTouchTime(curTime)
        self:showCurStatus(curTime)
        self:ckeckRefreshData(curTime)
    end, 1)
    
    self:hookMsg("MSG_ZNQ_2018_MY_LINGMAO_INFO")
    self:hookMsg("MSG_ZNQ_2018_LINGMAO_SKILLS")
    self:hookMsg("MSG_ZNQ_2018_LINGMAO_FRIENDS")
    self:hookMsg("MSG_ZNQ_2018_OPER_LINGMAO")
    self:hookMsg("MSG_LC_START_LOOKON")
end

function AnniversaryLingMaoDlg:onChat()
    self:ckeckTip()
end

-- 打开界面的随机提示
function AnniversaryLingMaoDlg:ckeckTip()
    if not self.myLingMaoInfo then
        return
    end
    
    local food = self.myLingMaoInfo.food
    local mood = self.myLingMaoInfo.mood

    local minNum = math.min(food, mood)
    local num = 101
    local tips = LINGMAO_TIPS[num]
    for i = 1, #LINGMAO_TIPS do
        if minNum < LINGMAO_TIPS[i].num then
            num = LINGMAO_TIPS[i].num
            tips = LINGMAO_TIPS[i]
            break
        end
    end
    
    local msg
    if food < num and  mood < num then
        local type = math.random(1, 2)
        if not tips[type] then type = 1 end
        
        local index = math.random(1, #tips[type])
        
        if tips[type][index].sexFlag then
            local gender = Me:queryBasicInt("gender")
            if gender == 1 then
                msg = string.format(tips[type][index].tip, CHS[5400569])
            else
                msg = string.format(tips[type][index].tip, CHS[5400570])
            end
        else
            msg = tips[type][index].tip
        end
    elseif food < num and tips[2] then
        local index = math.random(1, #tips[2])
        msg = tips[2][index].tip
    elseif mood < num and tips[1] then
        local index = math.random(1, #tips[1])
        msg = tips[1][index].tip
    end
    
    if msg then
        self:setChat(msg)
    end
end

function AnniversaryLingMaoDlg:setChat(msg)
   --[[ if #self.chatContent then
        return
    end]]
    
    local _, tag = AnniversaryMgr:getCatCurShapeIcon(self.myLingMaoInfo.level)
    local panel = self:getControl("Panel_4", nil, "LingMaoMagicPanel_" .. tag)
    
    local dlg = DlgMgr:openDlg("PopUpDlg")
    local bg = dlg:addTip(msg, nil, true)
    local size = panel:getContentSize()
    bg:setPosition(size.width / 2, size.height + 20)
    bg:setAnchorPoint(0.5, 0)
    panel:addChild(bg)
    
    local cb = function()
        for k, v in pairs(self.chatContent) do
            if v == bg then
                table.remove(self.chatContent, k)
            end
        end
    end

    -- 显示一定时间后删除
    local action = cc.Sequence:create(
        cc.DelayTime:create(5),
        cc.CallFunc:create(cb),
        cc.RemoveSelf:create()
    )

    if #self.chatContent == 1 then
        -- 当消息不足2条时加入之前要将队头的消息向上移动
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        local node = self.chatContent[1]
        node:runAction(newAction)
    elseif #self.chatContent > 1 then
        -- 消息到达2条时，移除对头消息, 并拿出新的队头继续向上移动
        local node = table.remove(self.chatContent, 1)
        node:stopAllActions()
        node:removeFromParent()
        local newAction = cc.MoveBy:create(0.2, cc.p(0, bg:getContentSize().height + 5))
        node = self.chatContent[1]
        node:runAction(newAction)
    end

    bg:runAction(action)
    table.insert(self.chatContent, bg)
end

-- 检测当前是否需要刷新灵猫数据
function AnniversaryLingMaoDlg:ckeckRefreshData(curTime)
    if not self.myLingMaoInfo or self.myLingMaoInfo.refreshTime <= 0 then
        return
    end
    
    if self.myLingMaoInfo.refreshTime <= curTime then
        self.myLingMaoInfo.refreshTime = 0
        AnniversaryMgr:requestMyLingMaoInfo()
    end
end

-- 获取播放不同阶段灵猫动画的 panel
function AnniversaryLingMaoDlg:getCurMagicPanel(level, status)
    self:setCtrlVisible("LingMaoMagicPanel_1", false)
    self:setCtrlVisible("LingMaoMagicPanel_2", false)
    self:setCtrlVisible("LingMaoMagicPanel_3", false)
    
    if status ~= 1 then
        return
    end
    
    local icon, panelName
    local icon, tag = AnniversaryMgr:getCatCurShapeIcon(level)
    local panelName = "LingMaoMagicPanel_" .. tag
    
    self:setCtrlVisible(panelName, true)
    return panelName, icon, tag
end

-- 创建灵猫对象
function AnniversaryLingMaoDlg:createLimgmao(level, status, num)
    local panelName, icon = self:getCurMagicPanel(level, status)
    
    if not panelName then
        return
    end

    local panel = self:getControl("Panel_1", nil, panelName)
    if self.lingmao[icon] then
        self.curLingmao = self.lingmao[icon]
        if num < 20 then
            if self.curLingmao.curAction ~= "sick" then
                DragonBonesMgr:toPlay(self.curLingmao, "sick", 0)
                self.curLingmao.curAction = "sick"
            end
        else
            if self.curLingmao.curAction ~= "stand" then
                DragonBonesMgr:toPlay(self.curLingmao, "stand", 0)
                self.curLingmao.curAction = "stand"
            end
        end
        return 
    end

    local mao = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    local node = tolua.cast(mao, "cc.Node")
    local size = panel:getContentSize()
    node:setRotationSkewY(180)
    panel:addChild(node)

    if num < 20 then
        DragonBonesMgr:toPlay(mao, "sick", 0)
        mao.curAction = "sick"
    else
        DragonBonesMgr:toPlay(mao, "stand", 0)
        mao.curAction = "stand"
    end
    
    self.lingmao[icon] = mao
    self.curLingmao = mao
    
    DragonBonesMgr:bindEventListener(mao, "complete", function()
        -- 在回调中直接播下一个动作会崩溃，延迟一帧
        performWithDelay(node, function() 
            if not DragonBonesMgr:isPlaying(mao) and self.myLingMaoInfo then
                -- 如果已经开始播放动作了，该逻辑就不用执行了
                local data = self.myLingMaoInfo
                local minNum = math.min(data.food, data.mood)
                self.needWait = false
                self:createLimgmao(data.level, data.status, minNum)
            end
        end, 0)
    end)
end

-- 显示灵猫的活跃或休息时间
function AnniversaryLingMaoDlg:showCurStatus(curTime)
    local panel = self:getControl("NotePanel", nil, "StatePanel")
    local hour = tonumber(gf:getServerDate("%H", curTime))
    if hour >= 8 then
        self:setTwoLabelText(CHS[5400475], panel, 1)
    else
        self:setTwoLabelText(CHS[5400476], panel, 1)
    end
end

-- 显示下次可爱抚时间
function AnniversaryLingMaoDlg:setCanTouchTime(curTime)
    if not self.myLingMaoInfo then
        return
    end
    
    local leftTime = TOUCH_INTERVAL_TIME - (curTime - self.myLingMaoInfo.last_time_tickle)
    local panel = self:getControl("MoodPanel", nil, "OperatePanel")
    if leftTime <= 0 then
        self:setTwoLabelText(CHS[5400486], panel, 1)
        self:setCtrlVisible("BKImage", false, panel)
        return
    end
    
    if leftTime > TOUCH_INTERVAL_TIME then
        leftTime = TOUCH_INTERVAL_TIME
    end
    
    local m = math.floor(leftTime / 60)
    local s = math.floor(leftTime % 60)
    local timeStr = string.format("%02d:%02d", m, s)
    self:setTwoLabelText(timeStr, panel, 1)
    self:setCtrlVisible("BKImage", true, panel)
end

function AnniversaryLingMaoDlg:onCombatButton(sender, eventType)
    if not self.myLingMaoInfo then
        return
    end

    AnniversaryMgr:requestFriendsLingMaoInfo("")
end

function AnniversaryLingMaoDlg:onLearnButton(sender, eventType)
    if not self.myLingMaoInfo then
        return
    end
    
    gf:CmdToServer("CMD_ZNQ_2018_REQ_LINGMAO_SKILLS", {})
end

function AnniversaryLingMaoDlg:checkMagic()
    if self.curMagicType == "Touch" then
        gf:ShowSmallTips(CHS[5400572])
        return true
    elseif self.curMagicType == "Food" then
        gf:ShowSmallTips(CHS[5400571])
        return true
    end
end

-- 喂食
function AnniversaryLingMaoDlg:onFoodButton(sender, eventType)
    if not self.myLingMaoInfo then
        return
    end
    
    -- 检查动画是否播完
    if self:checkMagic() then
        return
    end
    
    AnniversaryMgr:requestOperateLingMao("feed")
end

-- 爱抚
function AnniversaryLingMaoDlg:onMoodButton(sender, eventType)
    if not self.myLingMaoInfo then
        return
    end

    -- 检查动画是否播完
    if self:checkMagic() then
        return
    end
    
    -- 若距离上次补充时间不足30分钟，给予弹出提示
    local curTime = gf:getServerTime()
    if curTime - self.myLingMaoInfo.last_time_tickle < TOUCH_INTERVAL_TIME then
        self.needWait = true
        DragonBonesMgr:toPlay(self.curLingmao, "touch", 1)
        self.curLingmao.curAction = "touch"
        self:createArmature(ResMgr.ArmatureMagic.lingmao_touch.name, "Panel_3", "Panel_2")
        return
    end
    
    AnniversaryMgr:requestOperateLingMao("scratch")
end

-- 播放信封的骨骼动画
function AnniversaryLingMaoDlg:createLetterArmature()
    if self.letterMagic then
        return
    end
    
    self.letterMagic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.lingmao_leave_letter.name)
    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            if id == "Bottom01" then
                self:setCtrlVisible("EnvelopeButton", true, "MailmagicPanel")
            elseif id == "Bottom02" then
                self.letterMagic:getAnimation():play("Bottom03", -1, 0)

                local userDefaultKey = "hasLingMaoTip" .. gf:getShowId(Me:queryBasic("gid"))
                cc.UserDefault:getInstance():setBoolForKey(userDefaultKey, true)
            elseif id == "Bottom03" then
                self:setCtrlVisible("MailmagicPanel", false)
                self:setCtrlVisible("FinalMailPanel", true)
            end
        end
    end

    local showPanel = self:getControl("Panel", nil, "MailmagicPanel")
    self.letterMagic:setAnchorPoint(0.5, 0.5)
    local size = showPanel:getContentSize()
    self.letterMagic:setPosition(size.width / 2, size.height / 2)
    showPanel:addChild(self.letterMagic)

    self.letterMagic:getAnimation():setMovementEventCallFunc(func)
end

-- 创建抚摸、喂食动画
function AnniversaryLingMaoDlg:createArmature(icon, showPanelName, hidePanelName)
    if not self.myLingMaoInfo then
        return
    end
    
    local panelName, _, index = self:getCurMagicPanel(self.myLingMaoInfo.level, self.myLingMaoInfo.status)

    if not panelName then
        return
    end

    local hidePanel = self:getControl(hidePanelName, nil, panelName)
    hidePanel:removeAllChildren()
    local showPanel = self:getControl(showPanelName, nil, panelName)
    showPanel:removeAllChildren()
    local size = showPanel:getContentSize()
    local magic = ArmatureMgr:createArmature(icon)
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2, size.height / 2)
    showPanel:addChild(magic)
    
    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent()
            self.curMagicType = nil
        end
    end

    magic:getAnimation():setMovementEventCallFunc(func)
    
    if showPanelName == "Panel_3" then
        magic:getAnimation():play("Top0" .. index, -1, 0)
        self.curMagicType = "Touch"
    else
        magic:getAnimation():play("Top01", -1, 0)
        self.curMagicType = "Food"
    end
end

function AnniversaryLingMaoDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("AnniversaryLingMaoRuleDlg")
end

-- 找回灵猫
function AnniversaryLingMaoDlg:onFindButton(sender, eventType)
    if not self.myLingMaoInfo then
        return
    end
    
    local curTime = gf:getServerTime()
    if curTime >= self.myLingMaoInfo.end_time then
        gf:ShowSmallTips(CHS[5400489])
    else
        gf:ShowSmallTips(CHS[5400490])
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5400478]))
    end
    
    self:onCloseButton()
end

-- 打开信封
function AnniversaryLingMaoDlg:onEnvelopeButton(sender, eventType)
    sender:setVisible(false)
    self.letterMagic:getAnimation():play("Bottom02", -1, 0)
end

function AnniversaryLingMaoDlg:setTwoLabelText(text, panel, index, color)
    self:setLabelText("Label" .. index, text, panel, color)
    self:setLabelText("Label" .. (index + 1), text, panel)
    self:setLabelText("Label" .. (index + 2), text, panel)
end

function AnniversaryLingMaoDlg:setDataView(data)
    local curTime = gf:getServerTime()
    self:showCurStatus(curTime)
    self:setCanTouchTime(curTime)
    
    if data.status == 1 then
        AnniversaryMgr:setLingMaoDataView(self, data, "StatePanel")
        if not self.needWait then
            -- 等喂食、爱抚动画播完后再刷新灵猫数据
            self:createLimgmao(data.level, data.status, math.min(data.food, data.mood))
        end
        
        self:setCtrlVisible("OperatePanel", true)
        self:setCtrlVisible("StatePanel", true)
        
        local bkPanel = self:getControl("BKPanel", nil, "MainPanel")
        self:setCtrlVisible("BKImage_2", false, bkPanel)
        
        if AnniversaryMgr.needLingmaoTips then
            self:ckeckTip()
        end
    else
        self:createLimgmao(data.level, data.status)

        self:setCtrlVisible("OperatePanel", false)
        self:setCtrlVisible("StatePanel", false)
        
        local bkPanel = self:getControl("BKPanel", nil, "MainPanel")
        self:setCtrlVisible("BKImage_2", true, bkPanel)
        return
    end
    
    -- 切磋次数
    local panel = self:getControl("CombatPanel", nil, "OperatePanel")
    if data.combat_num > 0 then
        self:setTwoLabelText(data.combat_num .. "/3", panel, 1)
        self:setCtrlVisible("BKImage", true, panel)
    else
        self:setTwoLabelText(CHS[5400484], panel, 1)
        self:setCtrlVisible("BKImage", false, panel)
    end
    
    -- 顿悟次数
    local panel = self:getControl("LearnPanel", nil, "OperatePanel")
    if data.learn_num > 0 then
        self:setTwoLabelText(data.learn_num .. CHS[5400201], panel, 1)
        self:setCtrlVisible("BKImage", true, panel)
    else
        self:setTwoLabelText(CHS[5400485], panel, 1)
        self:setCtrlVisible("BKImage", false, panel)
    end
    
    -- 喂食次数
    local panel = self:getControl("FoodPanel", nil, "OperatePanel")
    self:setTwoLabelText(data.liveness .. "/20", panel, 1)
end

function AnniversaryLingMaoDlg:MSG_ZNQ_2018_LINGMAO_SKILLS(data)
    if not self.myLingMaoInfo then
        return
    end
    
    if not DlgMgr:isDlgOpened("AnniversaryLingMaoSkillDlg") then
        local dlg = DlgMgr:openDlgEx("AnniversaryLingMaoSkillDlg", self.myLingMaoInfo)
        dlg:MSG_ZNQ_2018_LINGMAO_SKILLS(data)
    end
end

-- 通知客户端成功获取好友信息
function AnniversaryLingMaoDlg:MSG_ZNQ_2018_LINGMAO_FRIENDS(data)
    if not self.myLingMaoInfo then
        return
    end
    
    DlgMgr:openDlgEx("AnniversaryLingMaoCombatDlg", self.myLingMaoInfo)
end

-- 通知客户端我的灵猫信息
function AnniversaryLingMaoDlg:MSG_ZNQ_2018_MY_LINGMAO_INFO(data)
    self.myLingMaoInfo = data
    self:setDataView(data)
    
    AnniversaryMgr.needLingmaoTips = nil
    
    local userDefault = cc.UserDefault:getInstance()
    local userDefaultKey = "hasLingMaoTip" .. gf:getShowId(Me:queryBasic("gid"))
    if data.status == 2 then
        -- 灵猫离家
        local flag = userDefault:getBoolForKey(userDefaultKey, false)
        if not flag then
            self:createLetterArmature()
            self.letterMagic:getAnimation():play("Bottom01", -1, 0)
            -- self:setCtrlVisible("EnvelopeButton", false, "MailmagicPanel")
            self:setCtrlVisible("MailmagicPanel", true)
            self:setCtrlVisible("FinalMailPanel", false)
        else
            self:setCtrlVisible("FinalMailPanel", true)
            self:setCtrlVisible("MailmagicPanel", false)
        end
    else
        userDefault:setBoolForKey(userDefaultKey, false)
    end
end

-- 通知客户端操作灵猫成功（forget_skill:遗忘技能，dunwu_skill:顿悟技能，scratch:抚摸，feed:喂食）
function AnniversaryLingMaoDlg:MSG_ZNQ_2018_OPER_LINGMAO(data)
    if data.oper == "scratch" then
        self.needWait = true
        DragonBonesMgr:toPlay(self.curLingmao, "touch", 1)
        self.curLingmao.curAction = "touch"
        self:createArmature(ResMgr.ArmatureMagic.lingmao_touch.name, "Panel_3", "Panel_2")
    elseif data.oper == "feed" then
        self.needWait = true
        DragonBonesMgr:toPlay(self.curLingmao, "eat", 1)
        self.curLingmao.curAction = "eat"
        self:createArmature(ResMgr.ArmatureMagic.lingmao_feed.name, "Panel_2", "Panel_3")
    end
end

function AnniversaryLingMaoDlg:MSG_LC_START_LOOKON(data)
    if self.needCloseWhenLookon then
        self:onCloseButton()
    end
end

function AnniversaryLingMaoDlg:setNeedCloseWhenLookon()
    self.needCloseWhenLookon = true
end

function AnniversaryLingMaoDlg:cleanup()
    DlgMgr:closeDlg("AnniversaryLingMaoRuleDlg")
    DlgMgr:closeDlg("AnniversaryLingMaoCombatDlg")
    DlgMgr:closeDlg("AnniversaryLingMaoSkillDlg")
    
    for icon, mao in pairs(self.lingmao) do
        DragonBonesMgr:removeCharDragonBonesResoure(icon,  string.format("%05d", icon))
    end
    
    self.lingmao = {}
    self.myLingMaoInfo = nil
    self.letterMagic = nil
    self.needCloseWhenLookon = nil
    self.curMagicType = nil
end

return AnniversaryLingMaoDlg
