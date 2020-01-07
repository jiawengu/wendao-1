-- GetTaoOfflineDlg.lua
-- Created by liuhb Jan/27/2016
-- 离线刷道设置界面

local GetTaoOfflineDlg = Singleton("GetTaoOfflineDlg", Dialog)

local curTask = nil -- 当前任务

function GetTaoOfflineDlg:init()
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("RewardButton", self.onRewardButton)
    self:bindListener("CheckButton", self.onCheckButton)
    self:bindListener("RuleButton", self.onRuleButton)

    self:bindListener("UpButton", self.onTaskUpButton)
    self:bindListener("TaskDownButton", self.onTaskDownButton)
    self:bindListener("OfflineTimeAddButton", self.onOfflineTimeAddButton)
    self:bindListener("DoublePointAddButton", self.onDoublePointAddButton)
    self:bindListener("JijiPointAddButton", self.onJijiPointAddButton)
    self:bindListener("ChongfengsanAddButton", self.onChongfengsanAddButton)
    self:bindListener("ZiqihongmengAddButton", self.onZiqihongmengAddButton)

    self:bindListener("FliterVoiceCheckBox", self.onDoubleEnble, "SetPanel4")
    self:bindListener("FliterVoiceCheckBox", self.onJJRLLEnble, "SetPanel5")
    self:bindListener("FliterVoiceCheckBox", self.onCFSEnble, "SetPanel6")
    self:bindListener("FliterVoiceCheckBox", self.onZQHMEnable, "SetPanel7")

    self:bindListener("Button1", self.onSelectXiangyao)
    self:bindListener("Button2", self.onSelectFumo)
    self:bindListener("Button3", self.onSelectFeix)

    -- 添加滑块响应
    self.tis = CHS[3002668]
    self.changeTip = 0
    curTask = nil
    self:createSwichButton(self:getControl("OpenStatePanel"), false, self.onOpenOfflineStatus, nil, self.openOfflineLimit)

    -- 添加数字键盘响应
    self:bindNumInput("MoneyValuePanel", self:getControl("SetPanel2"), function()
        local taskName = self:getCurTask()
        local taskSpeed = GetTaoMgr:getSpeed(taskName)
        if nil == taskSpeed or 0 == taskSpeed then
            -- 没有效率
            gf:ShowSmallTips(string.format(CHS[3002666], taskName, taskName))
            return true
        end
        return false
    end, "offlineInput")

    self:bindNumInput("MoneyValuePanel", self:getControl("SetPanel4"), nil, "doubleInput")
    self:bindNumInput("MoneyValuePanel", self:getControl("SetPanel5"), nil, "jijiInput")
    self:bindNumInput("MoneyValuePanel", self:getControl("SetPanel6"), nil, "chongFengSanInput")
    self:bindNumInput("MoneyValuePanel", self:getControl("SetPanel7"), nil, "ziQiHongMengInput")

    -- 添加下拉框响应
    local selectPanel = self:getControl("SelectPanel")
    gf:bindTouchListener(selectPanel, function(touch, event)
        local toPos = touch:getLocation()
        local eventCode = event:getEventCode()
        if eventCode == cc.EventCode.BEGAN then
            local rect = self:getBoundingBoxInWorldSpace(selectPanel)
            local btnRect = self:getBoundingBoxInWorldSpace(self:getControl("UpButton"))
            if not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(btnRect, toPos) then
                self:onTaskUpButton()
            end
        end
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    -- 更新界面数据
    self:updateViewData()
    self:updateAdditionalCheck()

    self:setInfoInit()

    GetTaoMgr:requestOfflineShuadao()

    OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")

    --[[
    local listView = self:getControl("ScrollView")
    local panel = self:getControl("SetPanel", nil, "ScrollView")
    panel:removeFromParent()
    listView:addChild(panel)
    listView:setInnerContainerSize(panel:getContentSize())
    --]]
    self:hookMsg("MSG_SHUADAO_REFRESH")
    self:hookMsg("MSG_SHUADAO_REFRESH_BUY_TIME")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_SHUADAO_USEPOINT_STATUS")
end

function GetTaoOfflineDlg:setInfoInit()
    local maxTurn = GetTaoMgr:getMyOfflineTurn()
    if 0 == maxTurn then
        self:setLabelText("InfoLabel", CHS[3002669], "SetPanel2")
    else
        self:setLabelText("InfoLabel", maxTurn, "SetPanel2")
    end

    local costTime = GetTaoMgr:getCostTime(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostOfflineTime(costTime)
    self:updateCostDoublePoint(GetTaoMgr:getMyDoublePoint())
    self:updateCostJijiPoint(GetTaoMgr:getMyJiji())
    self:updateCostChongFengSanPoint(GetTaoMgr:getMyChongFengSan())
    self:updateCostZiQiHongMengPoint(GetTaoMgr:getMyZiQiHongMeng())
end

-- 清除子对话框
function GetTaoOfflineDlg:cleanup()
    if 1 ~= GetTaoMgr:getOfflineStatus() then  -- 如果是关闭状态，则更新刷道任务
        -- 记住用户最后输入的信息
        self:closeOffline(true)
    end

    if GetTaoMgr:isHasOfflineBonus() then
        RedDotMgr:insertOneRedDot("GetTaoTabDlg", "OfflineGetTaoTabDlgCheckBox")
    end

    DlgMgr:closeDlg("SmallNumInputDlg")
end

-- 离线刷道状态设置
function GetTaoOfflineDlg:onOpenOfflineStatus(isOn, key)
    if isOn then
        self:openOffline(true)
    else
        self:closeOffline(true)
    end
    self.tis = CHS[3002668]
end

-- 打开离线刷道判断条件
function GetTaoOfflineDlg:openOfflineLimit()
    local saveStr = ""
    local offlineStatus = self:getButtonStatus(self:getControl("OpenStatePanel"))
    if offlineStatus then
        -- 当前是开启的状态
        return self:closeOffline(false)
    else
        -- 当前是关闭的状态
        return self:openOffline(false)
    end

    return true
end

-- 关闭离线刷道流程
function GetTaoOfflineDlg:closeOffline(isSend)
    local maxTurn = self:getLabelText("InfoLabel", self:getControl("SetPanel2"))
    if CHS[3002669] == maxTurn then
        -- 如果我要离线刷道轮次输入框没有输入数值
        maxTurn = 0
    end

    maxTurn = tonumber(maxTurn)
    local curTask = self:getCurTask()
    local maxDouble = tonumber(self:getLabelText("Label", self:getControl("SetPanel4")))
    local maxJiji = tonumber(self:getLabelText("Label", self:getControl("SetPanel5")))
    local maxChongFengSan = tonumber(self:getLabelText("Label", self:getControl("SetPanel6")))
    local maxZiQiHongMeng = tonumber(self:getLabelText("Label", self:getControl("SetPanel7")))

    if isSend then
        local saveStr = string.format("%d;%d;%s;%d;%d;%d;%d;%d", 0, maxTurn, curTask, maxDouble, maxJiji, maxChongFengSan, maxZiQiHongMeng, self.changeTip)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_OFFLINE, saveStr)
        self.changeTip = 0
    end
end

-- 打开离线刷道流程
function GetTaoOfflineDlg:openOffline(isSend)
    local maxTurn = self:getLabelText("InfoLabel", self:getControl("SetPanel2"))

    if CHS[3002669] == maxTurn then
        -- 如果我要离线刷道轮次输入框没有输入数值
        maxTurn = 0
        gf:ShowSmallTips(CHS[3002683])
        return true
    end

    if GetTaoMgr:isHasOfflineBonus() then
        gf:ShowSmallTips(CHS[4200171])
        return true
    end

    maxTurn = tonumber(maxTurn)
    local curTask = self:getCurTask()
    local maxDouble = tonumber(self:getLabelText("Label", self:getControl("SetPanel4")))
    local maxJiji = tonumber(self:getLabelText("Label", self:getControl("SetPanel5")))
    local maxChongFengSan = tonumber(self:getLabelText("Label", self:getControl("SetPanel6")))
    local maxZiQiHongMeng = tonumber(self:getLabelText("Label", self:getControl("SetPanel7")))

    if tonumber(Me:queryBasic("double_points")) < maxDouble and GetTaoMgr:getOffLineCostStatus(1) == 1 then
        -- 否则如果双倍输入框数值>玩家拥有双倍点数
        gf:ShowSmallTips(CHS[3002684])
        return true
    end

    if GetTaoMgr:getAllJijiPoint() < maxJiji and GetTaoMgr:getOffLineCostStatus(2) == 1 then
        -- 否则如果急急如律令输入框数值>玩家拥有双倍点数
        gf:ShowSmallTips(CHS[3002685])
        return true
    end

    if GetTaoMgr:getPetFengSanPoint() < maxChongFengSan and GetTaoMgr:getOffLineCostStatus(3) == 1 then
        -- 消耗宠风散超出当前拥有宠风散点数，请重新设置。
        gf:ShowSmallTips(CHS[6200030])
        return true
    end

    if GetTaoMgr:getAllZiQiHongMengPoint() < maxZiQiHongMeng and GetTaoMgr:getOffLineCostStatus(4) == 1 then
        -- 消耗紫气鸿蒙超出当前拥有紫气鸿蒙点数，请重新设置。
        gf:ShowSmallTips(CHS[7000289])
        return true
    end

    if isSend then
        local saveStr = string.format("%d;%d;%s;%d;%d;%d;%d;0", 1, maxTurn, curTask, maxDouble, maxJiji, maxChongFengSan, maxZiQiHongMeng)
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_OFFLINE, saveStr)
    end

    return false
end

-- 设置离线刷道为关闭
function GetTaoOfflineDlg:setOfflineClose()
    self.tis = CHS[4300074]
    self.changeTip = 1
    self:switchButtonStatusWithAction(self:getControl("OpenStatePanel"), false)
end

-- 更新界面数据
function GetTaoOfflineDlg:updateViewData()
    -- 离线刷道状态
    local offlineStatus = GetTaoMgr:getOfflineStatus()
    if 1 ~= offlineStatus then
        self:switchButtonStatus(self:getControl("OpenStatePanel"), false)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel"), true)
    end



    -- 设置任务信息
    self:setShowCurTask(curTask or GetTaoMgr:getMyLastTask())

    -- 设置下拉框数据
    self:setLabelText("Label", GetTaoMgr:getTaskSpeedStr(CHS[3002670]), self:getControl("Button1"))
    self:setLabelText("Label", GetTaoMgr:getTaskSpeedStr(CHS[3002671]), self:getControl("Button2"))
    self:setLabelText("Label", GetTaoMgr:getTaskSpeedStr(CHS[4000444]), self:getControl("Button3"))

    -- 设置领取奖励按钮状态
    if not GetTaoMgr:isHasOfflineBonus() and GetTaoMgr:isHasOfflineBonusInfo() then
        -- 查看奖励
        self:setCtrlVisible("CheckButton", true)
        self:setCtrlVisible("RewardButton", false)
    else
        -- 领取奖励
        self:setCtrlVisible("CheckButton", false)
        self:setCtrlVisible("RewardButton", true)
    end

    -- 更新拥有
    self:updateOwn()
end

function GetTaoOfflineDlg:updateAdditionalCheck()
    local data = GetTaoMgr:getAdditional()
    if data then
        self:setCheck("FliterVoiceCheckBox", data.doubleOffLineState == 1, "SetPanel4")
        self:setCheck("FliterVoiceCheckBox", data.jjrllOffLineState == 1, "SetPanel5")
        self:setCheck("FliterVoiceCheckBox", data.cfsOffLineState == 1, "SetPanel6")
        self:setCheck("FliterVoiceCheckBox", data.zqhmOffLineState == 1, "SetPanel7")
    end
end

-- 更新拥有的数据
function GetTaoOfflineDlg:updateOwn()
    local costTime = GetTaoMgr:getAllOfflineTime()
    local costTimeStr = self:convertToNormalTime(costTime)
    self:setLabelText("OwnTimeLabel", CHS[3002672] .. costTimeStr, self:getControl("SetPanel3"))

    self:setLabelText("OwnTimeLabel", CHS[3002672] .. GetTaoMgr:getAllDoublePoint(), self:getControl("SetPanel4"))
    self:setLabelText("OwnTimeLabel", CHS[3002672] .. GetTaoMgr:getAllJijiPoint(), self:getControl("SetPanel5"))
    self:setLabelText("OwnTimeLabel", CHS[3002672] .. GetTaoMgr:getPetFengSanPoint(), self:getControl("SetPanel6"))
    self:setLabelText("OwnTimeLabel", CHS[3002672] .. GetTaoMgr:getAllZiQiHongMengPoint(), self:getControl("SetPanel7"))
end

-- 更新own数据的颜色
function GetTaoOfflineDlg:updateCostColor()
    local costDoublePoint = tonumber(self:getLabelText("Label", self:getControl("SetPanel4")))
    self:updateCostDoublePoint(costDoublePoint)
    local costJijiPoint = tonumber(self:getLabelText("Label", self:getControl("SetPanel5")))
    self:updateCostJijiPoint(costJijiPoint)
    local chongfengsanPoint = tonumber(self:getLabelText("Label", self:getControl("SetPanel6")))
    self:updateCostChongFengSanPoint(chongfengsanPoint)
    local ziqihongmengPoint = tonumber(self:getLabelText("Label", self:getControl("SetPanel7")))
    self:updateCostZiQiHongMengPoint(ziqihongmengPoint)
end

-- 更新消耗的离线时间
function GetTaoOfflineDlg:updateCost()
    local maxTurn = self:getLabelText("InfoLabel", self:getControl("SetPanel2"))
    if CHS[3002669] == maxTurn or nil == maxTurn then
        maxTurn = 0
    end

    maxTurn = tonumber(maxTurn)

    local costTime = GetTaoMgr:getCostTime(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostOfflineTime(costTime)
    local costDoublePoint = GetTaoMgr:getCostDoublePoint(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostDoublePoint(costDoublePoint)
    local costJijiPoint = GetTaoMgr:getCostJijiPoint(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostJijiPoint(costJijiPoint)
    local costChongfengSanPoint = GetTaoMgr:getCostChongFengSan(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostChongFengSanPoint(costChongfengSanPoint)
    local costZiQiHongMengPoint = GetTaoMgr:getCostZiQiHongMeng(curTask or GetTaoMgr:getMyLastTask(), maxTurn)
    self:updateCostZiQiHongMengPoint(costZiQiHongMengPoint)
end

-- 设置消耗的离线时间
function GetTaoOfflineDlg:updateCostOfflineTime(costTime)
    local costTimeStr = self:convertToNormalTime(costTime)
    self:updateValuePointPanel("TimeLabel", costTimeStr, "SetPanel3")
end

-- 设置消耗的双倍点数
function GetTaoOfflineDlg:updateCostDoublePoint(costDoublePoint)
    self:updateValuePointPanel("Label", costDoublePoint, "SetPanel4", GetTaoMgr:getAllDoublePoint())
end

-- 设置消耗的急急如律令点数
function GetTaoOfflineDlg:updateCostJijiPoint(costJijiPoint)
    self:updateValuePointPanel("Label", costJijiPoint, "SetPanel5", GetTaoMgr:getAllJijiPoint())
end

-- 设置消耗宠风散
function GetTaoOfflineDlg:updateCostChongFengSanPoint(point)
    self:updateValuePointPanel("Label", point, "SetPanel6", GetTaoMgr:getPetFengSanPoint())
end

-- 设置消耗紫气鸿蒙
function GetTaoOfflineDlg:updateCostZiQiHongMengPoint(point)
    self:updateValuePointPanel("Label", point, "SetPanel7", GetTaoMgr:getAllZiQiHongMengPoint())
end


-- 设置对应的数值
function GetTaoOfflineDlg:updateValuePointPanel(labelName, value, panelName, normalValue)
    if nil == normalValue or value <= normalValue then
        self:setLabelText(labelName, value, self:getControl(panelName), COLOR3.TEXT_DEFAULT)
    else
        self:setLabelText(labelName, value, self:getControl(panelName), COLOR3.RED)
    end
end

-- 设置当前任务
function GetTaoOfflineDlg:setShowCurTask(taskName)
    local panel = self:getControl("SetPanel2")
    self:setLabelText("TypeLabel", GetTaoMgr:getTaskSpeedStr(taskName), panel)
    self:setCurTask(taskName)
end

-- 更新急急如律令
function GetTaoOfflineDlg:updateJijiNum(num)
    -- 如果输入框的数值超出2,000会置为2,000。并弹出不可选提示
    local realNum = num
    if num > GetTaoMgr:getMaxJiJiPoint() then
        realNum = GetTaoMgr:getMaxJiJiPoint()
        gf:ShowSmallTips(CHS[3002673])
    end

    self:updateCostJijiPoint(realNum)
    self:setOfflineClose()
    return realNum
end

-- 更新宠风散
function GetTaoOfflineDlg:updateChongFengSanNum(num)
    -- 如果输入框的数值超出5,000会置为5,000。并弹出不可选提示
    local realNum = num
    if num > GetTaoMgr:getMaxChongFengSanPoint() then
        realNum = GetTaoMgr:getMaxChongFengSanPoint()
        gf:ShowSmallTips(CHS[3002673])
    end

    self:updateCostChongFengSanPoint(realNum)
    self:setOfflineClose()
    return realNum
end

-- 更新紫气鸿蒙
function GetTaoOfflineDlg:updateZiQiHongMengNum(num)
    -- 如果输入框的数值超出5,000会置为5,000。并弹出不可选提示
    local realNum = num
    if num > GetTaoMgr:getMaxZiQiHongMengPoint() then
        realNum = GetTaoMgr:getMaxZiQiHongMengPoint()
        gf:ShowSmallTips(CHS[3002673])
    end

    self:updateCostZiQiHongMengPoint(realNum)
    self:setOfflineClose()
    return realNum
end

-- 更新双倍点数
function GetTaoOfflineDlg:updateDoubleNum(num)
    -- 如果输入框的数值超出4,000会置为4,000。并弹出不可选提示
    local realNum = num
    if num > PracticeMgr:getDoublePointLimit() then
        realNum = PracticeMgr:getDoublePointLimit()
        gf:ShowSmallTips(CHS[3002673])
    end

    self:updateCostDoublePoint(realNum)
    self:setOfflineClose()
    return realNum
end

-- 更新离线轮次
function GetTaoOfflineDlg:updateOfflineNum(num)
    local vip = Me:getVipType()
    local maxNum = GetTaoMgr:getCanMaxTurn(self:getCurTask())
    local maxLimitNum = GetTaoMgr:getLimitMaxTurn(self:getCurTask(), vip)
    local realNum = num
    repeat
        if maxLimitNum >= maxNum then
            -- 判断是否满足最大轮次条件
            if maxNum < realNum then
                -- 如果输入框的数值 > 玩家可进行的刷道轮次则将数值置为玩家可进行的刷道轮次，并弹出如下不可选提示
                gf:ShowSmallTips(string.format(CHS[3002674], maxNum))
                realNum = maxNum
                break
            end
        else
            -- 判定是否满足限制条件
            if realNum > maxLimitNum then
                if 3 ~= vip then
                    gf:ShowSmallTips(string.format(CHS[3002675], GetTaoMgr:getLevelOfflineTimeByVip(vip)))
                else
                    gf:ShowSmallTips(string.format(CHS[3002676], GetTaoMgr:getLevelOfflineTimeByVip(vip)))
                end

                realNum = maxLimitNum
                break
            end
        end

        if realNum > 2000000000 then
            gf:ShowSmallTips(CHS[3002673])
            realNum = 2000000000
            break
        end
    until true

    if 0 == realNum then
        self:setLabelText("InfoLabel", CHS[3002669], self:getControl("SetPanel2"))
    else
        self:setLabelText("InfoLabel", realNum, self:getControl("SetPanel2"))
    end

    -- 更新消耗
    self:updateCost()
    self:setOfflineClose()
    return realNum
end

-- 更新离线双倍点数
function GetTaoOfflineDlg:updateOfflineDoublePoint(num)

end

-- 更新急急如律令点数
function GetTaoOfflineDlg:updateOfflineJijiPoint(num)

end

-- 点击回调
function GetTaoOfflineDlg:insertNumber(num, key)
    -- 关闭刷道
    if "offlineInput" == key then
        return self:updateOfflineNum(num)
    elseif "doubleInput" == key then
        return self:updateDoubleNum(num)
    elseif "jijiInput" == key then
        return self:updateJijiNum(num)
    elseif "chongFengSanInput" == key then
        return self:updateChongFengSanNum(num)
    elseif "ziQiHongMengInput" == key then
        return self:updateZiQiHongMengNum(num)
    end
end

-- 设置当前选中的任务
function GetTaoOfflineDlg:setCurTask(taskName)
    curTask = taskName
end

-- 获取当前选中的任务
function GetTaoOfflineDlg:getCurTask()
    return curTask
end

-- 转换秒到 XX分XX秒
function GetTaoOfflineDlg:convertToNormalTime(secTi)
    local min = math.floor(secTi / 60)
    local sec = secTi % 60
    local timeStr = ""
    if 0 >= min then
        timeStr = string.format(CHS[3002677], sec)
    elseif 0 < sec then
        timeStr = string.format(CHS[3002678], min, sec)
    else
        timeStr = string.format(CHS[3002679], min)
    end

    return timeStr
end

function GetTaoOfflineDlg:onTaskDownButton(sender, eventType)
    self:setCtrlVisible("TaskDownButton", false)
    self:setCtrlVisible("UpButton", true)
    self:setCtrlVisible("SelectPanel", true)
end

function GetTaoOfflineDlg:onTaskUpButton(sender, eventType)
    self:setCtrlVisible("TaskDownButton", true)
    self:setCtrlVisible("UpButton", false)
    self:setCtrlVisible("SelectPanel", false)
end

function GetTaoOfflineDlg:onOfflineTimeAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    local data = GetTaoMgr:getData()
    if nil ~= data and next(data) then
        -- 如果数据存在
        local dlg = DlgMgr:openDlg("AddOfflineTimeDlg")
        dlg:setInfo(data)
    else
        gf:ShowSmallTips(CHS[3002680])
    end
end

function GetTaoOfflineDlg:onDoublePointAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if tonumber(Me:queryBasic("double_points")) > PracticeMgr:getDoublePointLimit() - 200 then
        gf:ShowSmallTips(CHS[3002681])
    else
        DlgMgr:openDlg("PracticeBuyDoubleDlg")
    end
end

function GetTaoOfflineDlg:onJijiPointAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if GetTaoMgr:getAllJijiPoint() > GetTaoMgr:getMaxJiJiPoint() - 200 then
        gf:ShowSmallTips(CHS[3002682])
    else
        local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
        dlg:setInfoByType("jiji")
    end
end

function GetTaoOfflineDlg:onDoubleEnble(sender, eventType)
    self:setOfflineClose()
    if sender:getSelectedState() then
        GetTaoMgr:setOffLineDouble(1)
    else
        GetTaoMgr:setOffLineDouble(0)
    end

end

function GetTaoOfflineDlg:onJJRLLEnble(sender, eventType)
    self:setOfflineClose()
    if sender:getSelectedState() then
        GetTaoMgr:setOffLineJJRLL(1)
    else
        GetTaoMgr:setOffLineJJRLL(0)
    end
end

function GetTaoOfflineDlg:onCFSEnble(sender, eventType)
    self:setOfflineClose()
    if sender:getSelectedState() then
        GetTaoMgr:setOffLineCFS(1)
    else
        GetTaoMgr:setOffLineCFS(0)
    end
end

function GetTaoOfflineDlg:onZQHMEnable(sender, eventType)
    self:setOfflineClose()
    if Me:getLevel() < GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL))
        self:setCheck("FliterVoiceCheckBox", false, "SetPanel7")
        return
    end

    if sender:getSelectedState() then
        GetTaoMgr:setOffLineZQHM(1)
    else
        GetTaoMgr:setOffLineZQHM(0)
    end
end

function GetTaoOfflineDlg:onChongfengsanAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if GetTaoMgr:getPetFengSanPoint() > GetTaoMgr:getMaxChongFengSanPoint() - 200 then
        gf:ShowSmallTips(CHS[6200029])
        return
    end

    local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
    dlg:setInfoByType("chongfengsan")
end

-- 紫气鸿蒙补充按钮
function GetTaoOfflineDlg:onZiqihongmengAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if  Me:getLevel() < GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL then
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL))
        return
    elseif GetTaoMgr:getAllZiQiHongMengPoint() > GetTaoMgr:getMaxZiQiHongMengPoint() - 200 then
        gf:ShowSmallTips(CHS[7000287])
        return
    end

    local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
    dlg:setInfoByType("ziqihongmeng")
end

function GetTaoOfflineDlg:onSelectXiangyao(sender, eventType)
    self:setShowCurTask(CHS[3002670])
    self:onTaskUpButton()
    self:updateOfflineNum(0)
    self:setOfflineClose()
end

function GetTaoOfflineDlg:onSelectFeix(sender, eventType)
    self:setShowCurTask(CHS[4000444])
    self:onTaskUpButton()
    self:updateOfflineNum(0)
    self:setOfflineClose()
end

function GetTaoOfflineDlg:onSelectFumo(sender, eventType)
    self:setShowCurTask(CHS[3002671])
    self:onTaskUpButton()
    self:updateOfflineNum(0)
    self:setOfflineClose()
end

function GetTaoOfflineDlg:onSaveButton(sender, eventType)
    local saveStr = ""
    local offlineStatus = self:getButtonStatus(self:getControl("OpenStatePanel"))
    if offlineStatus then
        offlineStatus = 1
    else
        offlineStatus = 0
    end

    local maxTurn = self:getLabelText("InfoLabel", self:getControl("SetPanel2"))
    if CHS[3002669] == maxTurn then
        -- 如果我要离线刷道轮次输入框没有输入数值
        maxTurn = 0
        gf:ShowSmallTips(CHS[3002683])
        return
    end

    maxTurn = tonumber(maxTurn)
    local curTask = self:getCurTask()
    local maxDouble = tonumber(self:getLabelText("Label", self:getControl("SetPanel4")))
    local maxJiji = tonumber(self:getLabelText("Label", self:getControl("SetPanel5")))
    local maxChongFengSan = tonumber(self:getLabelText("Label", self:getControl("SetPanel6")))
    local maxZiQiHongMeng = tonumber(self:getLabelText("Label", self:getControl("SetPanel7")))

    if tonumber(Me:queryBasic("double_points")) < maxDouble and GetTaoMgr:getOffLineCostStatus(1) == 1 then
        -- 否则如果双倍输入框数值>玩家拥有双倍点数
        gf:ShowSmallTips(CHS[3002684])
        return
    end

    if GetTaoMgr:getAllJijiPoint() < maxJiji and GetTaoMgr:getOffLineCostStatus(2) == 1  then
        -- 否则如果急急如律令输入框数值>玩家拥有双倍点数
        gf:ShowSmallTips(CHS[3002685])
        return
    end

    if GetTaoMgr:getPetFengSanPoint() < maxChongFengSan and GetTaoMgr:getOffLineCostStatus(3) == 1  then
        -- 消耗宠风散超出当前拥有宠风散点数，请重新设置。
        gf:ShowSmallTips(CHS[6200030])
        return
    end

    if GetTaoMgr:getAllZiQiHongMengPoint() < maxZiQiHongMeng and GetTaoMgr:getOffLineCostStatus(4) == 1 then
        -- 消耗紫气鸿蒙超出当前拥有紫气鸿蒙点数，请重新设置。
        gf:ShowSmallTips(CHS[7000289])
        return true
    end

    saveStr = string.format("%d;%d;%s;%d;%d;%d;%d;%d", offlineStatus, maxTurn, curTask, maxDouble, maxJiji, maxChongFengSan, maxZiQiHongMeng, self.changeTip)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_OFFLINE, saveStr)
end

function GetTaoOfflineDlg:onRewardButton(sender, eventType)
    -- 战斗判断
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000079])
        return
    end

    if not GetTaoMgr:isHasOfflineBonus() then
        gf:ShowSmallTips(CHS[3002686])
        return
    end

    if not PetMgr:getFightPet() then
        gf:ShowSmallTips(CHS[3002687])
        return
    end

    -- 如果有道法奖励，要判断玩家装备栏上是否装备了法宝
    if GetTaoMgr:isHasDaofaBonus() then
        local artifact = InventoryMgr:getItemByPos(EQUIP.ARTIFACT)
        local backArtifact = InventoryMgr:getItemByPos(EQUIP.BACK_ARTIFACT)
        if not artifact and not backArtifact then
            -- 俩个位置都没有法宝
            gf:confirm(CHS[7000293], function()
                if DlgMgr:isDlgOpened("GetTaoRewardDlg") then
                    return
                end

                gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_DO_BONUS)
            end)

            return
        else
            -- 以下情况给提示：1、主法宝限时，未开共通 2、副法宝限时，开共通  3、没有主法宝，有限时的副法宝
            local changeOn = 1 <= SystemSettingMgr:getSettingStatus("award_supply_artifact", 0)
            if (changeOn and InventoryMgr:isTimeLimitedItem(backArtifact))
                or (not changeOn and InventoryMgr:isTimeLimitedItem(artifact))
                or (not artifact and InventoryMgr:isTimeLimitedItem(backArtifact)) then

                -- 你当前装备的法宝为限时法宝，且离线奖励中包含道法奖励，是否确认领取？
                gf:confirm(CHS[7001017], function()
                    if DlgMgr:isDlgOpened("GetTaoRewardDlg") then
                        return
                    end

                    local dlg = DlgMgr:openDlg("GetTaoRewardDlg")
                    dlg:setData()
                end)

                return
            end
        end
    end

    if DlgMgr:isDlgOpened("GetTaoRewardDlg") then
        return
    end

    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_DO_BONUS)
end

function GetTaoOfflineDlg:onCheckButton(sender, eventType)
    if DlgMgr:isDlgOpened("GetTaoRewardDlg") then
        return
    end

    local dlg = DlgMgr:openDlg("GetTaoRewardDlg")
    dlg:setData(GetTaoMgr:getBonusData())
end

function GetTaoOfflineDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("OfflineRuleDlg")
end

function GetTaoOfflineDlg:MSG_SHUADAO_USEPOINT_STATUS()
    self:updateAdditionalCheck()
end

function GetTaoOfflineDlg:MSG_SHUADAO_REFRESH()
    self:updateViewData()

    if GetTaoMgr:getMyLastTask() == curTask then
        -- 数据相同才进行刷新
    self:setInfoInit()
    end
end

function GetTaoOfflineDlg:MSG_SHUADAO_REFRESH_BUY_TIME()
    self:updateOwn()
    self:updateCostColor()
end

function GetTaoOfflineDlg:MSG_UPDATE()
    self:updateOwn()
    self:updateCostColor()
end

return GetTaoOfflineDlg
