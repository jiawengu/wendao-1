-- ShengSiSetDlg.lua
-- Created by huangzz Apr/27/2018
-- 生死状界面

local ShengSiSetDlg = Singleton("ShengSiSetDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

-- 赌注数值限制
local BET_LIMIT = {
    ["cash"] = {   -- 金钱
        min = 10000000,
        max = 1000000000,
    },
    
    ["coin"] = {   -- 元宝
        min = 100,
        max = 10000,
    }
}

local SHOW_TIME_MAX_NUM = 50 -- 最多加载的时间条目个数

function ShengSiSetDlg:init()
    self:bindListener("ExpendButton", self.onExpendButton)
    self:bindListener("NoteButton", self.onBetNoteButton, "SetBetPanel")
    self:bindListener("NoteButton1", self.onNoteButton1, "SendPanel")   -- 对决模式说明
    self:bindListener("NoteButton2", self.onNoteButton2, "SendPanel")   -- 对决时间说明
    self:bindListener("NoteButton3", self.onNoteButton3, "SendPanel")   -- 对决生死注说明
    self:bindListener("ShareButton", self.onShareButton)
    self:bindListener("LastButton", self.onLastButton)
    self:bindListener("NextButton", self.onNextButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("CombatButton", self.onCombatButton)
    self:bindListener("LookonButton", self.onLookonButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AcceptButton", self.onAcceptButton)
    self:bindListener("BackImage", self.onExpendButton, "SetTimePanel")
    self:bindListener("OnePanel", self.onOneTimePanel)

    self:bindNumInput("InputPanel", "SetBetPanel", self.onLimitNumInput, nil, nil, true)

    self:bindFloatPanelListener("TimeListPanel", "ExpendButton")
    
    self.betNum = 0 -- 赌注数值
    self.betType = "none" -- 赌注类型
    self.defInfo = nil 
    self.timeInfo = nil
    self.selectTimeTag = nil     -- 对决时间
    self.needShowTimeList = nil  -- 请求数据后是否需要显示时间列表
    self.combatData = nil
    self.attInfo = {
        icon = Me:queryBasicInt("icon"),
        level = Me:queryBasicInt("level"),
        name = Me:getShowName(),
    }
    
    -- 名字输入框
    self.nameEdit = self:initEditBox("NameInputPanel", "ReceivePortraitPanel", CHS[5450197], 6)
    
    -- 选择对战模式
    self.modeGroup = RadioGroup.new()
    self.modeGroup:setItems(self, {"CheckBox_1", "CheckBox_2", "CheckBox_3"}, nil, "SetTimePanel")

    -- 选择赌注类型
    self.betGroup = RadioGroup.new()
    self.betGroup:setItemsCanReClick(self, {"CheckBox_1", "CheckBox_2"}, self.onChooseBetType, "SetBetPanel")

    -- 对决时间
    self.oneTimePanel = self:retainCtrl("OnePanel")
    self.selectTimeImg = self:retainCtrl("ChoseImage", self.oneTimePanel)
    
    self:setViewState(1)

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_LD_RET_CHECK_CONDITION")
    self:hookMsg("MSG_LD_MATCH_DEFENSE_DATA")
    self:hookMsg("MSG_LD_LIFEDEATH_LIST")
    self:hookMsg("MSG_LD_MATCH_LIFEDEATH_COST")
    -- self:hookMsg("MSG_LD_MATCH_DATA")
end

function ShengSiSetDlg:cmdCheckCondition(type, para1, para2)
    gf:CmdToServer("CMD_LD_CHECK_CONDITION", {type = type, para1 = para1 or "", para2 = para2 or ""})
end

-- 分布生死状
function ShengSiSetDlg:cmdSendShengSi(name, time, mode, betType, num)
    gf:CmdToServer("CMD_LD_START_LIFEDEATH", {name = name, time = time, mode = mode, bet_type = betType or "none", bet_num = num})
end

-- 请求决斗时间列表
function ShengSiSetDlg:cmdCombatTimeList()
    gf:CmdToServer("CMD_LD_LIFEDEATH_LIST", {})
end

-- 请求发布的手续费
function ShengSiSetDlg:cmdSendCost(level)
    gf:CmdToServer("CMD_LD_MATCH_LIFEDEATH_COST", {level = level})
end

function ShengSiSetDlg:initTimeListView()
    if not self.timeInfo then
        self:setCtrlVisible("TimeListPanel", false)
        return
    end

    local listView = self:getControl("ListView")
    listView:removeAllItems()
    local curTime = gf:getServerTime()
    for i = 1, math.min(#self.timeInfo, SHOW_TIME_MAX_NUM) do
        local time = self.timeInfo[i].time
        if time > curTime then
            local cell = self.oneTimePanel:clone()
            cell:setTag(i)

            local timeStr = gf:getServerDate("%H:%M", time)
            self:setLabelText("Label", self.timeInfo[i].flag == 1 and "" or timeStr, cell)
            self:setLabelText("InvalidLabel", self.timeInfo[i].flag == 0 and "" or timeStr, cell)
            listView:pushBackCustomItem(cell)

            if self.selectTimeTag and self.selectTimeTag == i then
                self.selectTimeImg:removeFromParent()
                cell:addChild(self.selectTimeImg)
            end
        end
    end
end

function ShengSiSetDlg:initCharView()
    local function func(data, root) 
        if data.icon then
            self:setImage("PortraitImage", ResMgr:getCirclePortraitPathByIcon(data.icon), root)
        else
            self:setImage("PortraitImage", ResMgr.ui.quest_mark, root)
        end

        self:setLabelText("NameLabel", data.name or "", root)
        
        if data.level then
            self:setLabelText("LevelLabel", data.level .. CHS[5300006], root)
        else
            self:setLabelText("LevelLabel", "", root)
        end
    end
    
    if self.defInfo and self.curState ~= 1 then
        -- 对手为迎战方
        func(self.attInfo, "SendPortraitPanel")
        func(self.defInfo, "ReceivePortraitPanel")
        self:setCtrlVisible("NameInputPanel", false)
    else
        func(self.attInfo, "SendPortraitPanel")
        func({}, "ReceivePortraitPanel")

        if self.curState == 1 then
            self:setCtrlVisible("NameInputPanel", true)
        end
    end
end

function ShengSiSetDlg:initEditBox(panel, root, defStr, wordLimit)
    local newEdit
    newEdit = self:createEditBox(panel, root, nil, function(sender, type)
        if type == "end" then
        elseif type == "changed" then
            local newName = newEdit:getText()
            if gf:getTextLength(newName) > wordLimit * 2 then
                newName = gf:subString(newName, wordLimit * 2)
                newEdit:setText(newName)
                gf:ShowSmallTips(CHS[4000224])
            end
        end
    end)

    newEdit:setPlaceHolder(defStr)
    newEdit:setPlaceholderFontColor(COLOR3.GRAY)
    newEdit:setPlaceholderFont(CHS[3003597], 17)
    newEdit:setFont(CHS[3003597], 17)
    newEdit:setFontColor(COLOR3.TEXT_DEFAULT)
    newEdit:setText("")

    return newEdit
end

function ShengSiSetDlg:setViewState(state, status, result)
    self:setCtrlVisible("NotePanel", false)
    self:setCtrlVisible("NameInputPanel", false)
    self:setCtrlVisible("SetTimePanel", false)
    self:setCtrlVisible("SetBetPanel", false)
    self:setCtrlVisible("SendPanel", false)
    self:setCtrlVisible("CostPanel", false)
    self:setCtrlVisible("LastButton", false)
    self:setCtrlVisible("NextButton", false)
    self:setCtrlVisible("SendButton", false)
    self:setCtrlVisible("CombatButton", false)
    self:setCtrlVisible("ShareButton", false)
    self:setCtrlVisible("LookonButton", false)
    self:setCtrlVisible("RefuseButton", false)
    self:setCtrlVisible("AcceptButton", false)
    self:setCtrlVisible("VSImage2", true)
    if state == 1 then
        -- 设置名称
        self:setLabelText("TipsLabel", CHS[5450194])
        self:setCtrlVisible("NotePanel", true)
        self:setCtrlVisible("NextButton", true)
        self:setCtrlVisible("NameInputPanel", true)
    elseif state == 2 then
        -- 设置对决模式和时间
        self:setLabelText("TipsLabel", CHS[5450196])
        self:setCtrlVisible("SetTimePanel", true)
        self:setCtrlVisible("NextButton", true)
        self:setCtrlVisible("LastButton", true)
    elseif state == 3 then
        -- 设置生死注
        self:setLabelText("TipsLabel", CHS[5450198])
        self:setCtrlVisible("SetBetPanel", true)
        self:setCtrlVisible("NextButton", true)
        self:setCtrlVisible("LastButton", true)
    elseif state == 4 then
        -- 生死状发起
        self:setLabelText("TipsLabel", CHS[5450200])
        self:setCtrlVisible("SendPanel", true)
        self:setCtrlVisible("LastButton", true)
        self:setCtrlVisible("SendButton", true)
        self:setCtrlVisible("CostPanel", true)
        
        self:setCtrlVisible("NoteButton1", false, "SendPanel")
        self:setCtrlVisible("NoteButton2", false, "SendPanel")
        self:setCtrlVisible("NoteButton3", false, "SendPanel")
    elseif state == 5 then
        self:setCtrlVisible("SendPanel", true)
        self:setCtrlVisible("CombatButton", true)
        self:setCtrlVisible("ShareButton", true)
    elseif state == 6 then 
        -- 接受或拒绝
        self:setCtrlVisible("SendPanel", true)
        self:setCtrlVisible("RefuseButton", true)
        self:setCtrlVisible("AcceptButton", true)
        self:setCtrlVisible("VSImage2", false)
    else
        -- 观战
        self:setCtrlVisible("SendPanel", true)
        self:setCtrlVisible("LookonButton", true)
    end

    -- 参战
    self:setCtrlVisible("VSImage_2", true)

    if state > 4 then
        if status == "atk_raise" then
            self:setCtrlVisible("VSImage_2", false)
            self:setLabelText("TipsLabel", CHS[5450226])
        elseif status == "def_accept" then
            if result == "no_start" then
                self:setLabelText("TipsLabel", CHS[5450232])
            elseif result == "atk" then
                self:setLabelText("TipsLabel", CHS[5450230])
            elseif result == "def" or result == "draw" then
                self:setLabelText("TipsLabel", CHS[5450231])
            else
                self:setLabelText("TipsLabel", CHS[5450227])
            end
        elseif status == "def_refuse" then
            self:setLabelText("TipsLabel", CHS[5450228])
        elseif status == "over_time" then
            self:setCtrlVisible("VSImage_2", false)
            self:setLabelText("TipsLabel", CHS[5450229])
        end
    end
    
    self.curState = state
    
    -- 设置对决双方的信息
    self:initCharView()
end

-- 显示发起生死状最终对决数据
function ShengSiSetDlg:setCombetInfo(data)
        -- 模式
    self:setLabelText("InputTypeLabel", data.mode, "SendPanel")

    -- 对决是时间
    self:setLabelText("InputTimeLabel", gf:getServerDate("%H:%M", data.time), "SendPanel")

    -- 赌注
    self:setCtrlVisible("CoinImage", false, "SendPanel")
    self:setCtrlVisible("CashImage", false, "SendPanel")
    local num = data.bet_num
    if data.bet_type == "cash" then
        self:setCtrlVisible("CashImage", true, "SendPanel")
    elseif data.bet_type == "coin" then
        self:setCtrlVisible("CoinImage", true, "SendPanel")
    end

    self:setArtFontNumber(num, "SendPanel")
end

-- 选择生死注类型
function ShengSiSetDlg:onChooseBetType(sender, idx, eventType)
    self:setCtrlVisible("CoinImage", false, "SetPanel")
    self:setCtrlVisible("CashImage", false, "SetPanel")
    self:setCtrlVisible("CoinImage", false, "OwnPanel")
    self:setCtrlVisible("CashImage", false, "OwnPanel")

    if eventType == ccui.CheckBoxEventType.unselected then
        sender:setSelectedState(false)
        self.betType = "none"
        self.betNum = 0
        self:setArtFontNumber(nil, "OwnPanel")
        self:setArtFontNumber(nil, "SetPanel")
        return
    end

    if sender:getName() == "CheckBox_1" then
         --金钱
        self.betType = "cash"

        local myCash = Me:queryBasicInt("cash")
        self:setArtFontNumber(myCash, "OwnPanel")

        self:setCtrlVisible("CashImage", true, "SetPanel")
        self:setCtrlVisible("CashImage", true, "OwnPanel")
    else
        -- 元宝
        self.betType = "coin"

        local myCoin = Me:queryBasicInt("gold_coin")
        self:setArtFontNumber(myCoin, "OwnPanel", ART_FONT_COLOR.DEFAULT)

        self:setCtrlVisible("CoinImage", true, "SetPanel")
        self:setCtrlVisible("CoinImage", true, "OwnPanel")
    end
    
    self.betNum = 0
    self:setCostBet(0)
end

function ShengSiSetDlg:setCostBet(num)
    self.betNum = num
    self:setArtFontNumber(self.betNum, "SetPanel")
end

function ShengSiSetDlg:onExpendButton(sender, eventType)
    local panel = self:getControl("TimeListPanel")
    local visible = not panel:isVisible()
    if visible then
        local curH = tonumber(gf:getServerDate("%H", gf:getServerTime()))
        if curH >= 23 and curH < 7 then
            gf:ShowSmallTips(CHS[5450212])
            return
        end

        if not self.timeInfo then
            self:cmdCombatTimeList()
            self.needShowTimeList = true
            return
        else
            self.needShowTimeList = false
            self:initTimeListView()
        end
    end
    
    panel:setVisible(visible)
end

function ShengSiSetDlg:onOneTimePanel(sender, eventType)
    self.selectTimeImg:removeFromParent()
    sender:addChild(self.selectTimeImg)
    
    local curTime =  gf:getServerTime()
    local curH = tonumber(gf:getServerDate("%H", gf:getServerTime()))
    if curH >= 23 and curH < 7 then
        gf:ShowSmallTips(CHS[5450212])
        return
    end
    
    local tag = sender:getTag()
    if not self.timeInfo[tag] then
        return
    end

    local time = self.timeInfo[tag].time
    if self.timeInfo[tag].flag == 1 then
        gf:ShowSmallTips(gf:getServerDate(CHS[5450213], time))
        return
    end

    if time - curTime < self.timeInfo.time_space then
        gf:ShowSmallTips(gf:getServerDate(CHS[5450214], time))
        self.needShowTimeList = true
        self:cmdCombatTimeList()
        return
    end
    
    self.selectTimeTag = tag
    self.selectTime = time
    self:setLabelText("InputTimeLabel", gf:getServerDate("%H:%M", time), "SetTimePanel")
    self:setCtrlVisible("DefaultLabel", false, "SetTimePanel")
    self:setCtrlVisible("TimeListPanel", false, "SetTimePanel")
end

function ShengSiSetDlg:onBetNoteButton(sender, eventType)
    gf:showTipInfo(CHS[5450204], sender)
end

function ShengSiSetDlg:onNoteButton1(sender, eventType)
    if not self.combatData then
        return
    end

    if self.combatData.mode == "1V1" then
        gf:showTipInfo(CHS[5450201], sender)
    else
        if not self.attInfo or not self.defInfo then
            return
        end

        local maxLevel = math.max(self.attInfo.level, self.defInfo.level)
        local level = (math.floor(maxLevel / 10) + 1) * 10 + 9
        gf:showTipInfo(string.format(CHS[5450202], level, level), sender)
    end
end

function ShengSiSetDlg:onNoteButton2(sender, eventType)
    gf:showTipInfo(CHS[5450203], sender)
end

function ShengSiSetDlg:onNoteButton3(sender, eventType)
    gf:showTipInfo(CHS[5450204], sender)
end

function ShengSiSetDlg:onShareButton(sender, eventType)
    local str = string.format("%s %s VS %s", gf:getServerDate("%H:%M", self.combatData.time), self.attInfo.name, self.defInfo.name)
    local showInfo = string.format(string.format("{\29%s\29}", str))
    local sendInfo = string.format(string.format("{\t%s=%s=%s}", str, CHS[5450219], self.combatData.id))

    local dlg = DlgMgr:openDlg("ShareChannelListDlg")
    dlg:setShareText(showInfo, sendInfo, "shengsizhuang")

    local rect = self:getBoundingBoxInWorldSpace(sender)
    rect.width = (rect.width - dlg.root:getContentSize().width) / 2
    dlg:setFloatingFramePos(rect)
end

function ShengSiSetDlg:onLastButton(sender, eventType)

    self.curState = math.max(self.curState - 1, 1)

    self:setViewState(self.curState)
end

function ShengSiSetDlg:onNextButton(sender, eventType)
    if self.curState == 1 then
        -- 设置名称
        local str = self.nameEdit:getText()
        if string.isNilOrEmpty(str) then
            gf:ShowSmallTips(CHS[5450217])
            return
        end
        
        self:cmdCheckCondition("check_def_basic", str)
    elseif self.curState == 2 then
        -- 设置对决模式和时间
        local index = self.modeGroup:getSelectedRadioIndex()
        if not index then
            gf:ShowSmallTips(CHS[5450215])
            return
        end
        
        if not self.selectTimeTag then
            gf:ShowSmallTips(CHS[5450216])
            return
        end
        
        local combatNum = index * 2 - 1
        self.curMode = string.format("%dV%d", combatNum, combatNum)
        self:cmdCheckCondition("check_combat_info", self.curMode, tostring(self.timeInfo[self.selectTimeTag].time))
    elseif self.curState == 3 then
        -- 设置生死注
        if self.betType ~= "none" then
            local num = self.betNum 
            if num > BET_LIMIT[self.betType].max  then
                gf:ShowSmallTips(string.format(CHS[5450207], self:getBetNumStr(BET_LIMIT[self.betType].max), self:getBetUnit()))
                return
            end

            if num < BET_LIMIT[self.betType].min  then
                gf:ShowSmallTips(string.format(CHS[5450208], self:getBetNumStr(BET_LIMIT[self.betType].min), self:getBetUnit()))
                return
            end
            
            if self.betType == "cash" and not gf:checkEnough("cash", num) then
                return
            elseif self.betType == "coin" and not gf:checkEnough("gold", num) then
                return
            end
        end
        
        self:cmdCheckCondition("check_ld_bet", self.betType or "none", tostring(self.betNum))
    else
        -- 容错
        self:setViewState(self.curState)
    end
end

-- 生死状发起
function ShengSiSetDlg:onSendButton(sender, eventType)
    if not self.timeInfo or not self.timeInfo[self.selectTimeTag] then
        return
    end

    local moneyTip = ""
    if self.betType == "coin" then
        moneyTip = string.format(CHS[5400597], gf:getMoneyDesc(self.betNum))
        moneyTip = string.format(CHS[5400600], moneyTip)
    elseif self.betType == "cash" then
        moneyTip = string.format(CHS[5400598], gf:getMoneyDesc(self.betNum))
        moneyTip = string.format(CHS[5400600], moneyTip)
    end
    
    local timeStr = gf:getServerDate("%H:%M", self.timeInfo[self.selectTimeTag].time)
    gf:confirm(string.format(CHS[5400596], gf:getMoneyDesc(self.combatCost), moneyTip, timeStr,self.defInfo.name), function() 
        self:cmdSendShengSi(self.defInfo.name, self.timeInfo[self.selectTimeTag].time, self.curMode, self.betType, self.betNum)
    end)
end

function ShengSiSetDlg:onCombatButton(sender, eventType)
    if not self.combatData then
        return
    end

    gf:CmdToServer("CMD_LD_ENTER_ZHANC", {id = self.combatData.id})
end

function ShengSiSetDlg:onLookonButton(sender, eventType)
    if not self.combatData then
        return
    end

    gf:CmdToServer("CMD_LD_LOOKON_MATCH", {id = self.combatData.id})

    self:onCloseButton()
end

function ShengSiSetDlg:onRefuseButton(sender, eventType)
    if not self.combatData then
        return
    end

    gf:CmdToServer("CMD_LD_REFUSE_MATCH", {id = self.combatData.id})
end

function ShengSiSetDlg:onAcceptButton(sender, eventType)
    if not self.combatData then
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onAcceptButton") then
        return
    end

    gf:CmdToServer("CMD_LD_ACCEPT_MATCH", {id = self.combatData.id})
end

-- 根据赌注类型获取颜色字符串
function ShengSiSetDlg:getBetNumStr(num)
    if self.betType == "cash" then
        return  gf:getMoneyDesc(num) -- 文钱
    else
        return  "#R" .. num .. "#n" -- 元宝
    end
end

-- 获取赌注单位（元宝、文钱）
function ShengSiSetDlg:getBetUnit()
    if self.betType == "cash" then
        return CHS[5450205] -- 文钱
    else
        return CHS[5450206] -- 元宝
    end
end

function ShengSiSetDlg:onLimitNumInput()
    if self.betType == "none" then
        gf:ShowSmallTips(CHS[5450209])
        return true
    end
end

-- 关闭数字键盘的回调
function ShengSiSetDlg:closeNumInputDlg()
    if self.betType == "none" then
        return
    end

    if self.betNum > 0 and self.betNum < BET_LIMIT[self.betType].min then
        gf:ShowSmallTips(string.format(CHS[5450208], self:getBetNumStr(BET_LIMIT[self.betType].min), self:getBetUnit()))
        self:setArtFontNumber(0, "SetPanel")
        self.betNum = 0
    end

    if self.betNum > BET_LIMIT[self.betType].max  then
        self.betNum = BET_LIMIT[self.betType].max
        gf:ShowSmallTips(string.format(CHS[5450207], self:getBetNumStr(self.betNum), self:getBetUnit()))
    end
end

-- 数字键盘插入数字
function ShengSiSetDlg:insertNumber(num)
    if self.betType == "none" then
        return
    end

    if num > BET_LIMIT[self.betType].max  then
        num = BET_LIMIT[self.betType].max
        gf:ShowSmallTips(string.format(CHS[5450207], self:getBetNumStr(num), self:getBetUnit()))
    end
    
    self:setCostBet(num)

    return num
end

function ShengSiSetDlg:setArtFontNumber(num, root, defColor)
    if num then
        local text, fontColor = gf:getArtFontMoneyDesc(num)
        self:setNumImgForPanel("InputPanel", defColor or fontColor, text, false, LOCATE_POSITION.MID, 23, root)
    else
        self:removeNumImgForPanel("InputPanel", LOCATE_POSITION.MID, root)
    end
end

-- 对手信息
function ShengSiSetDlg:MSG_LD_MATCH_DEFENSE_DATA(data)
    self.defInfo = data

    self:initCharView()
    
    -- 请求对决手续费
    self:cmdSendCost(data.level)
end

-- 分布生死状的手续费
function ShengSiSetDlg:MSG_LD_MATCH_LIFEDEATH_COST(data)
    local str = gf:getMoneyDesc(data.cost)
    self:setColorText(str, "Panel", "CostPanel", nil, nil, nil, 17)

    self.combatCost = data.cost
end

-- 生死状时间列表
function ShengSiSetDlg:MSG_LD_LIFEDEATH_LIST(data)
    table.sort(data, function(l, r) 
        if l.time < r.time then return true end
    end)

    self.timeInfo = data

    if self.selectTimeTag and (not data[self.selectTimeTag] or data[self.selectTimeTag].time ~= self.selectTime) then
        self.selectTimeTag = nil
        self:setLabelText("InputTimeLabel", "", "SetTimePanel")
        self:setCtrlVisible("DefaultLabel", true, "SetTimePanel")
    end

    if self.needShowTimeList then
        self:initTimeListView()
    end

    self.needShowTimeList = nil
end

-- 返回检查生死状的条件
function ShengSiSetDlg:MSG_LD_RET_CHECK_CONDITION(data)
    if data.type == "check_def_basic" then
        -- 检查输入应战方是否合法
        if data.result == 1 then
            -- 设置下一页
            self:setViewState(2)
            
            -- 请求对决时间列表
            self:cmdCombatTimeList()
        end
    elseif data.type == "check_combat_info" then
        -- 检查选择的模式和时间是否合法
        if data.result == 1 then
            -- 设置下一页
            self:setViewState(3)
        elseif string.match(data.msg , CHS[5450221]) then
            -- 选择的对决时间无效，重新请求对决时间列表
            self:cmdCombatTimeList()
        end
    elseif data.type == "check_ld_bet" then
        -- 检查生死注是否合法
        if data.result == 1 then
            -- 设置下一页
            self:setViewState(4)

            -- 根据前面选择的数据设置总的对决信息
            self:setCombetInfo({
                mode = self.curMode,
                time = self.timeInfo[self.selectTimeTag].time,
                bet_type = self.betType,
                bet_num = self.betNum
            })
        end
    end

    if not string.isNilOrEmpty(data.msg) then
        gf:ShowSmallTips(data.msg)
    end
end

-- 最终的生死状数据
function ShengSiSetDlg:MSG_LD_MATCH_DATA(data)
    self.combatData = data
    self.attInfo = data.attInfo
    self.defInfo = data.defInfo

    self:setCombetInfo(data)
    
    local result = data.result
    local status = data.status
    if self.attInfo.gid == Me:queryBasic("gid") then
        -- 角色是挑战方
        self:setViewState(5, status, result)
    elseif self.defInfo.gid == Me:queryBasic("gid") then
        -- 角色是应战方
        if data.status == "atk_raise" then
            -- 未接受
            self:setViewState(6, status, result)
        else
            -- 已接受
            self:setViewState(5, status, result)
        end
    else
        -- 观众
        self:setViewState(7, status, result)
    end
end

-- 更新拥有的金钱
function ShengSiSetDlg:MSG_UPDATE(data)
    if self.betType == "cash" then
        local myCash = Me:queryBasicInt("cash")
        self:setArtFontNumber(myCash, "OwnPanel")
    elseif self.betType == "coin" then
        local myCoin = Me:queryBasicInt("gold_coin")
        self:setArtFontNumber(myCoin, "OwnPanel", ART_FONT_COLOR.DEFAULT)
    end
end

return ShengSiSetDlg
