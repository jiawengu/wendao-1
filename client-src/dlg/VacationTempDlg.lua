-- VacationTempDlg.lua
-- Created by huangzz Apr/11/2018
-- 暑假元神归位

local VacationTempDlg = Singleton("VacationTempDlg", Dialog)
local NumImg = require('ctrl/NumImg')

local DEFAULT_TIME_MAX = 25

-- 时钟水平方向偏移
local CLOCK_OFFSET_X = 4

-- 时钟相对于头顶基准点的偏移
local CLOCK_OFFESET_Y = 20

local SKILL_KEY = {
    {CHS[5450143], CHS[5450144], CHS[5450145], CHS[5450149]}, -- 升温者
    {CHS[5450146], CHS[5450147], CHS[5450148], CHS[5450149]}, -- 降温者
}

local SKILL_NO = {
    [1] = 161,
    [2] = 162,
    [3] = 163,
    [4] = 110,
    [5] = 112,
    [6] = 113,
}

local skillPanelName = "ASkillPanel"

function VacationTempDlg:init()
    self:setFullScreen()
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("RuleButton", self.onRuleButton)
    
    DlgMgr:reorderDlgByName("ChatDlg")
    
    self:bindFloatPanelListener("RulePanel", "RuleButton")
    
    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, {[self.name] = 1, ["ChatDlg"] = 1, ["LoadingDlg"] = 1})
    
    Me:setAct(Const.FA_STAND)
    Me:setCanMove(false)
    
    self.needCheckDis = false  -- 合体时需要检测两个修道者的距离
    self.fitState = 0
    self.circleImgs = {}
    self.oppInfo = {}     -- 队友的信息
    self.myInfo = {}      -- 自己的信息
    self.otherInfo = {}   -- 队友信息

    -- 增加倒计时
    self:addTimeImage()
        
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, 1, false, LOCATE_POSITION.MID, 25, "RoundPanel")

    self:setGameState(0)
    
    self:hookMsg("MSG_MESSAGE_EX")
    self:hookMsg("MSG_YUANSGW_CUR_ROUND")
    self:hookMsg("MSG_YUANSGW_CHAR_INFO")
    self:hookMsg("MSG_YUANSGW_SANDGLASS")
    self:hookMsg("MSG_YUANSGW_ACTION_SEQUENCE")
    
    self:bindListener("SignalTouchPanel", self.onSignalButton)
    
    self.signalImages =  {
        self:getControl("SignalImage_1", nil, "SignalPanel_0"),
        self:getControl("SignalImage_2", nil, "SignalPanel"),
        self:getControl("SignalImage_3", nil, "SignalPanel"),
        self:getControl("SignalImage_4", nil, "SignalPanel"),
    }
    self:refreshSignalColor()

    self:onRefresh()
    schedule(self.root, function() self:onRefresh() end, 1)
end

function VacationTempDlg:onUpdate()
    if not self.needCheckDis then
        return
    end
    
    -- NPC元神转身面向本体，执行walk动作并移动至NPC本体处。
    local char1 = CharMgr:getCharById(self.oppInfo[1].id)
    local char2 = CharMgr:getCharById(self.oppInfo[2].id)
    if char1 and char2 and gf:distance(char1.curX, char1.curY, char2.curX, char2.curY) <= Const.PANE_WIDTH * 1.5 then
        self:doEndAction(2)
        self.needCheckDis = false
    end
end

function VacationTempDlg:cmdEndAction()
    gf:CmdToServer("CMD_YUANSGW_END_ANIMATE", {id = Me:getId()})
end

function VacationTempDlg:cmdCommand(id, action, para)
    gf:CmdToServer("CMD_YUANSGW_ACCEPTED_COMMAND", {victim_id = id, action = action, para = para})
    self.curSelectAction = nil
end

function VacationTempDlg:initSkills(type)
    if type == 1 then
        -- 升温者
        skillPanelName = "ASkillPanel"
        self:setCtrlVisible("BSkillPanel", false)
        self:setCtrlVisible("ASkillPanel", true)
    else
        -- 降温者
        skillPanelName = "BSkillPanel"
        self:setCtrlVisible("BSkillPanel", true)
        self:setCtrlVisible("ASkillPanel", false)
    end
    
    self.skills = SKILL_KEY[type]

    -- 技能点击
    for i = 1, 4 do
        local skillPanel = self:getControl("SkillPanel_" .. i, nil, skillPanelName)
        local panel = self:getControl("ItemPanel", nil, skillPanel)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onSkillButton)
    end
end

function VacationTempDlg:setGameState(state)
    self:setCtrlVisible("NoticeImage", false, skillPanelName)
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("WaitImage", false, "TimePanel")
    self:setCtrlVisible("NumPanel", false, "TimePanel")
    self:setCtrlVisible("ChoosingTaregetPanel", false)
    self:setCtrlVisible(skillPanelName, false)
    self:showClickCircle(1, false)
    self:showClickCircle(2, false)
    if state == 0 then
        
    elseif state == 1 then
        -- 选择技能
        self:setCtrlVisible("TimePanel", true)
        self:setCtrlVisible("NumPanel", true, "TimePanel")
        self:setCtrlVisible("NoticeImage", true, skillPanelName)
        self:setCtrlVisible(skillPanelName, true)
    elseif state == 2 then
        -- 选择目标
        self:setCtrlVisible("TimePanel", true)
        self:setCtrlVisible("NumPanel", true, "TimePanel")
        self:setCtrlVisible("ChoosingTaregetPanel", true)
        
        -- 显示光圈
        self:showClickCircle(1, true)
        self:showClickCircle(2, true)
        
        -- 显示选中的技能名称
        if self.curSelectAction then
            local key = math.floor(self.curSelectAction / 4)
            local skills = SKILL_KEY[key + 1]
            if skills then
                local index = self.curSelectAction
                if key == 1 then
                    index = self.curSelectAction - 3
                end
                
                self:setLabelText("SkillNameLabel", skills[index] or "", "ChoosingTaregetPanel")
            end
        end
    elseif state == 3 then
        -- 已使用技能
        self:setCtrlVisible("TimePanel", true)
        self:setCtrlVisible("WaitImage", true, "TimePanel")
    else
        -- 播放动作
        
        self:removeHeadEffect(1)
        self:removeHeadEffect(2)
    end
    
    self.curState = state
end

function VacationTempDlg:creatOneSelectImg(id)
    local char = CharMgr:getCharById(id)
    if not char or not char.charAction then
        return
    end
    
    local img = ccui.ImageView:create(ResMgr.ui.fight_sel_img, ccui.TextureResType.localType)
    local hasClick
    local function clickImg(touch, event)
        local pos = touch:getLocation()
        local evenCode = event:getEventCode()
        local rect = self:getBoundingBoxInWorldSpace(img)
        if evenCode == cc.EventCode.BEGAN then
            if not img:isVisible() then
                return false
            end

            if cc.rectContainsPoint(rect, pos) then
                img:loadTexture(ResMgr.ui.fight_sel_down_img)
                hasClick = true
                return true
            end

            return false
        elseif evenCode == cc.EventCode.MOVED then
            if not cc.rectContainsPoint(rect, pos) then
                img:loadTexture(ResMgr.ui.fight_sel_img)
                hasClick = false
            end
        elseif evenCode == cc.EventCode.ENDED then
            if cc.rectContainsPoint(rect, pos)
                and img:isVisible()
                and hasClick then
                
                if self.curSelectAction then
                    -- 通知要播放的技能
                    self:cmdCommand(id, self.curSelectAction)
					self:setGameState(3)
                end
            end
            
            img:loadTexture(ResMgr.ui.fight_sel_img)
        elseif evenCode == cc.EventCode.CANCELLED then
            img:loadTexture(ResMgr.ui.fight_sel_img)
        end
    end
    
    local panel = ccui.Layout:create()
    self.root:addChild(panel, 100, 0)
    
    gf:bindTouchListener(panel, clickImg, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
    
    local x, y = char.charAction:getWaistOffset()
    img:setPosition(x, y)
    char:addToTopLayer(img)
    
    return img
end

-- 显示光圈用于点击敌人时使用
function VacationTempDlg:showClickCircle(tag, visible)
    if self.circleImgs[tag] then
        self.circleImgs[tag]:setVisible(visible)
        return
    end

    if self.oppInfo[tag] then
        local img = self:creatOneSelectImg(self.oppInfo[tag].id)
        if img then
            img:setVisible(visible)
            self.circleImgs[tag] = img
        end
    end
end

function VacationTempDlg:addTimeImage()
    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('NumPanel', nil, "TimePanel")
    if timePanel and not timePanel:getChildByName("numImg") then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', DEFAULT_TIME_MAX, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setName("numImg")
        timePanel:addChild(self.numImg, 100, 10)
    end
end

-- 开始计时
function VacationTempDlg:startCountDown(time)
    if not self.numImg then
        return
    end
    
    time = math.min(time, 25)

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self:setCtrlVisible("TimePanel", true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)
    end)
end

function VacationTempDlg:onReturnButton(sender, eventType)
    self:setGameState(1)
end

-- 点击技能
function VacationTempDlg:onSkillButton(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local tag = sender:getTag()
    local dlg = DlgMgr:openDlg("VacationSnowSkillDlg")
    dlg:setSkill(self.skills[tag], self)
    dlg:setFloatingFramePos(rect)
    

    -- 技能出来后，隐藏
    self:setCtrlVisible("NoticeImage", false, skillPanelName)
end

function VacationTempDlg:skillCloseCallBack()
    if self.curState == 1 then
        self:setCtrlVisible("NoticeImage", true, skillPanelName)
    end
end

function VacationTempDlg:cmdOper(oper)
    if self.curState > 3 then
        gf:ShowSmallTips(CHS[4100887])
        return
    end
    
    if oper < 7 then
        -- 需要选择目标
        self.curSelectAction = oper
        self:setGameState(2)
    else
        -- 不用选择目标
        self:cmdCommand(Me:getId(), oper)
        self:setGameState(3)
    end
end

function VacationTempDlg:onRuleButton(sender, eventType)
    local ctrl = self:getControl("RulePanel")
    if ctrl:isVisible() then
        ctrl:setVisible(false)
    else
        ctrl:setVisible(true)
    end
end

function VacationTempDlg:onCloseButton(sender, eventType)
    gf:CmdToServer("CMD_YUANSGW_QUIT_GAME", {})
end

function VacationTempDlg:setChat(char, str)
    ChatMgr:sendCurChannelMsgOnlyClient({
        id = char:getId(),
        gid = char:queryBasic("gid"),
        icon = char:queryBasicInt("icon"),
        name = char:getName(),
        msg =  str,
    })
end

function VacationTempDlg:doFightAction(data)
    if not data or not data[1] then
        performWithDelay(self.root, function() 
            self:cmdEndAction()
        end, 2)
        return
    end
    
    local info = data[1]
    table.remove(data, 1)
    
    local id = 1
    if info.caster_id ~= Me:getId() then
        id = 2
    end

    local char = CharMgr:getCharById(id)
	if not char then
	    self:doFightAction(data)
		return
	end
	
    if info.action < 7 then
    
        local function castCallBack()
            if char.faAct == Const.FA_ACTION_CAST_MAGIC then
                local victimChar = CharMgr:getCharById(info.victim_id)
                if victimChar and victimChar.charAction then
                    -- 法攻技能光效
                    local skill = SkillMgr:getskillAttrib(SKILL_NO[info.action])
                    local effect = skill.skill_effect
                    local magic
                    magic = victimChar:addMagic(0, 0, effect.icon, false, false, nil, nil, function() 
                        --冰冻或昏睡
                        self:checkTempMagic(victimChar, info.temp_aft)
                        
                        -- 被攻击后的喊话
                        if info.action < 4 then
                            self:setChat(victimChar, CHS[5450169])
                        else
                            self:setChat(victimChar, CHS[5450170])
                        end
                        
                        -- 播下一个动作
                        self:doFightAction(data)

                        magic:removeFromParent()
                    end)
                            
                    -- 成功播放技能光效，播放技能音效
                    SoundMgr:playSkillEffect(effect.icon)

                    -- 播放受击
                    local function parrayCallBack()
                        if victimChar.faAct == Const.FA_DEFENSE_START then
                            performWithDelay(victimChar.charAction, function() 
                                victimChar:setAct(Const.FA_DEFENSE_END, parrayCallBack)
                            end, 0.1)
                        else
                            victimChar:setAct(Const.FA_STAND)
                        end
                    end
                    
                    if not victimChar:isFrozen() then
                        victimChar:setAct(Const.FA_DEFENSE_START, parrayCallBack)
                    end
                else
                    -- 播下一个动作
                    self:doFightAction(data)
                end

                char:setAct(Const.FA_ACTION_CAST_MAGIC_END, castCallBack)
            else
                char:setAct(Const.FA_STAND)
            end
        end

        -- 法攻
        char:setAct(Const.FA_ACTION_CAST_MAGIC, castCallBack)
    elseif info.action == 7 then
	    -- 休息
        if char.faAct ~= Const.FA_DIED then
            char:setAct(Const.FA_DIED)
        end
        
        -- 播下一个动作
        self:doFightAction(data)
    else
	    -- 合体
        self:doEndAction(1)
    end
end

function VacationTempDlg:doEndAction(state)
    local char1 = CharMgr:getCharById(self.oppInfo[1].id) -- 本体
    local char2 = CharMgr:getCharById(self.oppInfo[2].id) -- 元神

    if not char1 or not char2 then return end
    if state == 1 then
        -- NPC元神转身面向本体，执行walk动作并移动至NPC本体处。
        char2:setPos(gf:convertToClientSpace(29, 50))
        char2:setOpacity(255)
        char2:setSeepPrecent(-70)
        self.needCheckDis = true
        char2:setEndPos(23, 53)
    elseif state == 2 then
        -- 元神移动到距离本体处1单位时，二者的透明度同时在1s内变为完全透明。
        char1:fadeOut(1)
        char2:fadeOut(1)
        
        local action = cc.Sequence:create(
            cc.DelayTime:create(0.75),
            
            -- 透明度开始变化0.5s后，NPC“修道者”出现，1s内透明度由0变为完全不透明。
            cc.CallFunc:create(function()
                local char = CharMgr:getCharById(self.oppInfo[1].id) -- 本体
                if char then
                    char:fadeIn(0.75)
                    char:absorbBasicFields({name = CHS[5450141]})
                end
            end),
            
            cc.DelayTime:create(1),
            
            -- 随后NPC“修道者”喊话：“多谢道友相助，我的元神已经成功归位。”
            cc.CallFunc:create(function()
                local char = CharMgr:getCharById(self.oppInfo[1].id) -- 本体
                if char then
                    char:setOpacity(255)
                    self:setChat(char, CHS[5450162])
                end
            end),
            
            cc.DelayTime:create(1),
            
            -- 喊话后1s退出界面。
            cc.CallFunc:create(function()
                -- gf:ShowSmallTips("Close")
                self:cmdEndAction()
            end)
        )
        
        self.root:runAction(action)
    end
end

-- 人物头顶增加闹钟动画
function VacationTempDlg:addHeadEffect(id)
    local char = CharMgr:getCharById(id)
    if char and char.charAction then
        if char.readyToFight then
            return
        end

        local headX, headY = char.charAction:getHeadOffset()
        char.readyToFight = gf:createLoopMagic(ResMgr.magic.ready_to_fight)
        char.readyToFight:setAnchorPoint(0.5, 0.5)
        char.readyToFight:setLocalZOrder(Const.CHARACTION_ZORDER)
        if char:queryBasic('gid') == Me:queryBasic('gid') then
            char.readyToFight:setPosition(CLOCK_OFFSET_X, headY + CLOCK_OFFESET_Y)
        else
            char.readyToFight:setPosition(-CLOCK_OFFSET_X, headY + CLOCK_OFFESET_Y)
        end

        char:addToMiddleLayer(char.readyToFight)
    end
end

-- 人物头顶移除闹钟动画
function VacationTempDlg:removeHeadEffect(id)
    local char = CharMgr:getCharById(id)
    if char and char.readyToFight then
        char.readyToFight:removeFromParent()
        char.readyToFight = nil
    end
end

function VacationTempDlg:MSG_YUANSGW_ACTION_SEQUENCE(data)
    DlgMgr:closeDlg("VacationSnowSkillDlg")
    self:doFightAction(data)
    
    self:setGameState(4)
end

-- 角色数据
function VacationTempDlg:MSG_YUANSGW_CHAR_INFO(data)
    if data.type == 1 then
        -- 降温者
        if data.player.id == 1 then
		    self.myInfo = data.player
            self.myType = 1
			self:initSkills(2)
        else
		    self.otherInfo = data.player
		end
    elseif data.type == 2 then
        -- 升温者
        if data.player.id == 1 then
			self:initSkills(1)
            self.myType = 2
		    self.myInfo = data.player
        else
		    self.otherInfo = data.player
		end
    elseif data.type == 3 then
        -- 修道者本体
		self.oppInfo[1] = data.player
    else
        -- 修道者的元神
        self.oppInfo[2] = data.player
    end
end

function VacationTempDlg:checkTempMagic(char, temp)
    if not char then return end
    -- 昏睡及冰冻光效
    if temp < 35 then
        if not char:isFrozen() then
            char:addMagicOnWaist(ResMgr.magic.frozen, false, ResMgr.magic.frozen)
        end

        char:deleteMagic(ResMgr.magic.sleep)
    elseif temp > 65 then
        if not char:isFrozen() then
            char:addMagicOnWaist(ResMgr.magic.sleep, false, ResMgr.magic.sleep)
        end

        char:deleteMagic(ResMgr.magic.frozen)
    else
        char:deleteMagic(ResMgr.magic.frozen)
        char:deleteMagic(ResMgr.magic.sleep)
    end
end

function VacationTempDlg:checkOneTempTalk(char, temp)
    if temp < 35 then
        self:setChat(char, CHS[5450164])
    elseif temp > 65 then
        self:setChat(char, CHS[5450163])
    end
end

-- 检测喊话
function VacationTempDlg:checkTwoTempTalk(char1, char2, temp1, temp2)
    if not char1 or not char2 then return end
    if temp1 >= 35 and temp1 <= 65 and temp2 >= 35 and temp2 <= 65 then
        local cTemp = temp2 - temp1
        local str
        if cTemp <= -10 then
            str = CHS[5450168]
        elseif cTemp <= 0 then
            str = CHS[5450167]
        elseif cTemp <= 10 then
            str = CHS[5450166]
        else
            str = CHS[5450165]
        end

        self:setChat(char2, str)
    else
        self:checkOneTempTalk(char1, temp1)
        self:checkOneTempTalk(char2, temp2)
    end
end

function VacationTempDlg:MSG_YUANSGW_CUR_ROUND(data)
    DlgMgr:closeDlg("VacationSnowSkillDlg")
    
    self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.S_FIGHT, data.round, false, LOCATE_POSITION.MID, 25, "RoundPanel")
    
    local curTime = gf:getServerTime()
    if curTime >= data.nxet_round_time then
        self:setGameState(4)
        return
    end
    
    -- 开启倒计时
    self:startCountDown(data.nxet_round_time - curTime)

    self:setGameState(1)
    
    -- 时钟
    self:addHeadEffect(1)
    self:addHeadEffect(2)
    
    for i = 1, data.count do
        if data[i].flag == 1 then
            self:MSG_YUANSGW_SANDGLASS(data[i])
        end
    end
    
    if not self.oppInfo[1] then
        return
    end
    
    -- 
    local char1 = CharMgr:getCharById(self.oppInfo[1].id)  -- 本体
    local char2 = CharMgr:getCharById(self.oppInfo[2].id)  -- 元神
    if char1 and char2 then
        self:checkTempMagic(char1, data.temp1)
        self:checkTempMagic(char2, data.temp2)
        
        if data.round > 1 then
            self:checkTwoTempTalk(char1, char2, data.temp1, data.temp2)
        else
            self:setChat(char2, CHS[5450193])

            -- 升温者喊话
            local char = CharMgr:getCharById(self:getCharId(2))
            if char then
                self:setChat(char, CHS[5450191])
            end

            -- 降温者喊话
            local char = CharMgr:getCharById(self:getCharId(1))
            if char then
                self:setChat(char, CHS[5450192])
            end
        end
    end
end

function VacationTempDlg:getCharId(type)
    if self.myType == type then
        return self.myInfo.id
    elseif type <= 2 then
        return self.otherInfo.id
    elseif type > 2 and type < 5 then
        return self.oppInfo[type].id
    end
end

-- 设置指令成功后，清除角色身上的沙漏
function VacationTempDlg:MSG_YUANSGW_SANDGLASS(data)
    if data.flag == 1 then
        if data.id == Me:getId() then
            self:removeHeadEffect(1)
            self:setGameState(3)
        else
            self:removeHeadEffect(2)
        end
    else
        -- 技能使用失败，重新选择技能
        self:setGameState(1)
    end
end

function VacationTempDlg:MSG_MESSAGE_EX(data)
    if data.name == self.myInfo.name then
        local char = CharMgr:getCharById(1)
        if char then
            char:setChat(data)
        end
    elseif data.name == self.otherInfo.name then
        local char = CharMgr:getCharById(2)
        if char then
            char:setChat(data)
        end
    end
end

function VacationTempDlg:cleanup()
    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil
    
    Me:setCanMove(true)
    Me:setFixedView(false)
    Me.canShiftFlag = true
end

function VacationTempDlg:onRefresh()
    self:updateTime()

    -- 更新电池状态
    local batteryInfo = BatteryAndWifiMgr:getBatteryInfo()

    if batteryInfo then
        self:updateBattery(batteryInfo.rawlevel, batteryInfo.scale, batteryInfo.status, batteryInfo.health)
    end

    -- 更新网络状态
    local networkState = BatteryAndWifiMgr:getNetworkState()

    if networkState then
        self:updateNetwork(networkState)

        -- 是wifi,更新wifi强度
        local wifiInfo = BatteryAndWifiMgr:getWifiInfo()
        if NET_TYPE.WIFI == networkState and wifiInfo then
            self:updateWifiStatus(wifiInfo.wifiState, wifiInfo.level)
        end
    end

    self:refreshSignalColor()
end

-- 更新电池状态
function VacationTempDlg:updateBattery(rawlevel, scale, status, health)
    local level;
    if rawlevel >= 0 and scale > 0 then
        level = (rawlevel * 100) / scale;
    end

    local batterProcessBar = self:getControl("ProgressBar")
    local chargeImage = self:getControl("ChargeImage")

    if BATTERY_STATE.OVERHEAT == health then
    -- gf:ShowSmallTips("电池过热！")
    else
        if BATTERY_STATE.UNKNOWN == status then
            -- gf:ShowSmallTips("这神器没有电池！")
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.CHARGING == status then
            -- 充电状态
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        elseif BATTERY_STATE.DISCHARGING == status
            or BATTERY_STATE.NOT_DISCHARGING == status then
            -- 更新电池状态即可
            batterProcessBar:setVisible(true)
            chargeImage:setVisible(false)
        elseif BATTERY_STATE.FULL == status then
            -- 充满了
            batterProcessBar:setVisible(false)
            chargeImage:setVisible(true)
        end
    end

    -- 更新电池状态
    batterProcessBar:setPercent(level)
end

-- 更新网络状态
function VacationTempDlg:updateNetwork(networkState)

    if not networkState then return end

    if NET_TYPE.WIFI ~= networkState then
        self:setCtrlVisible("SignalPanel", false)
        self:setCtrlVisible("SignalPanel_0", true)
        return
    end

    self:setCtrlVisible("SignalPanel", true)
    self:setCtrlVisible("SignalPanel_0", false)
end

-- 更新wifi状态
-- 0 - -50信号最好， -50 - -70信号差点， 小于 -70 的信号最差
function VacationTempDlg:updateWifiStatus(wifiState, level)
    local levelStatus
    if level < -70 then
        levelStatus = 1
    elseif level < -50 then
        levelStatus = 2
    else
        levelStatus = 3
    end

    self:updateWifiUI(levelStatus)
end

function VacationTempDlg:updateWifiUI(levelStatus)
    local wifiLevelImg = {
        [1] = "SignalImage_2",
        [2] = "SignalImage_3",
        [3] = "SignalImage_4",
    }

    for k, v in pairs(wifiLevelImg) do
        self:setCtrlVisible(v, false)
    end

    self:setCtrlVisible(wifiLevelImg[levelStatus], true)
end


function VacationTempDlg:updateTime()
    local curTime = os.date("%H:%M")
    self:setLabelText("TimeLabel_1", curTime)
    self:setLabelText("TimeLabel_2", curTime)
end

function VacationTempDlg:refreshSignalColor()
    if not self.signalImages or #self.signalImages <= 0 then return end

    local delay = Client:getLastDelayTime()
    local color
    if delay < 500 then
        color = SIGNAL_COLOR.WHITE
    else
        color = SIGNAL_COLOR.RED
    end

    local singleImage
    for i = 1, #self.signalImages do
        singleImage = self.signalImages[i]
        singleImage:setColor(color)
    end
end

-- 显示延时
function VacationTempDlg:onSignalButton(sender, eventType)
    self:refreshSignalColor()
    local delay = Client:getLastDelayTime()
    if delay > 5000 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", "5000+"), sender)
    elseif delay < 200 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#c30E50B", tostring(delay)), sender)
    elseif delay >= 200 and delay <= 500 then
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF2DF0C", tostring(delay)), sender)
    else
        gf:showTipInfo(string.format("%s%s%sms#n", CHS[2000125], "#cF22800", tostring(delay)), sender)
    end
end

return VacationTempDlg
