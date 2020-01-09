-- GetTaoDlg.lua
-- Created by liuhb Jan/27/2016
-- 刷道界面

local GetTaoDlg = Singleton("GetTaoDlg", Dialog)

local TASK_XIANGYAO    = CHS[3002654]
local TASK_FUMO        = CHS[3002655]
local TASK_FEIXIAN     = CHS[4000444]

-- 刷道等级限制
local SHUADAO_TASK = {
    [TASK_XIANGYAO]    = {level = 45, name = TASK_XIANGYAO, icon = 06042},
    [TASK_FUMO]        = {level = 80, name = TASK_FUMO, icon = 06086},
    [TASK_FEIXIAN]        = {level = 120, name = TASK_FEIXIAN, icon = 06032},
}

function GetTaoDlg:init()
    self:bindListener("XYGoButton", self.onXiangyaoGoButton, self:getControl("XiangYaoPanel"))
    self:bindListener("FMGoButton", self.onFuMoGoButton, self:getControl("FuMoPanel"))
    self:bindListener("FeixGoButton", self.onFeixGoButton)

    self:bindListener("MoneyPayButton", self.onMoneyPayButton)
    self:bindListener("AcerPayButton", self.onAcerPayButton)
    self:bindListener("ZqhmMoneyPayButton", self.onZqhmMoneyPayButton)
    self:bindListener("ZqhmAcerPayButton", self.onZqhmAcerPayButton)

    -- 初始化Panel
    self:initData()
    GetTaoMgr:requestOfflineShuadao()

    -- 绑定关闭悬浮框时间
    self:bindCloseTips()

    OnlineMallMgr:openOnlineMall(nil, "notOpenDlg")

    self:hookMsg("MSG_SHUADAO_REFRESH")
    self:hookMsg("MSG_REFRESH_RUYI_INFO")
    self:hookMsg("MSG_UPDATE")
end

function GetTaoDlg:initData()
    -- 设置降妖Panel
    local panel = self:getControl("XiangYaoPanel")
    self:setPortrait("ShapePanel", SHUADAO_TASK[TASK_XIANGYAO].icon, 0, panel, false, nil, nil, cc.p(0, -46))
    self:setLabelText("XiangySuggestLevelLabel", SHUADAO_TASK[TASK_XIANGYAO].level .. CHS[3002656])

    -- 设置伏魔Panel
    local panel = self:getControl("FuMoPanel")
    self:setPortrait("ShapePanel", SHUADAO_TASK[TASK_FUMO].icon, 0, panel, false, nil, nil, cc.p(0, -46))
    self:setLabelText("FumSuggestLevelLabel", SHUADAO_TASK[TASK_FUMO].level .. CHS[3002656])

    -- 设置飞Panel
    local panel = self:getControl("FeiXianPanel")
    self:setPortrait("ShapePanel", SHUADAO_TASK[TASK_FEIXIAN].icon, 0, panel, false, nil, nil, cc.p(0, -46))
    self:setLabelText("FeixSuggestLevelLabel", SHUADAO_TASK[TASK_FEIXIAN].level .. CHS[3002656])

    -- 绑定急急如律令
    local buttonPanel = self:getControl("ButtonPanel")
    self:createSwichButton(self:getControl("OpenStatePanel", nil, buttonPanel), false, self.onOpenJijiState, nil, self.canNotOpenJiJiRuLvLingState)

    -- 点击购买急急如律令
    self:bindListener("AddButton", self.onAddButton, buttonPanel)


    -- 绑定宠风散
    buttonPanel = self:getControl("ButtonPanel2")
    self:createSwichButton(self:getControl("OpenStatePanel", nil, buttonPanel), false, self.onOpenChongFengSnaState, nil, self.canNotOpenChongFengSanState)

    -- 点击购买宠风散
    self:bindListener("AddButton", self.onAddPetFengSanButton, buttonPanel)


    -- 绑定紫气鸿蒙
    buttonPanel = self:getControl("ButtonPanel3")
    self:createSwichButton(self:getControl("OpenStatePanel", nil, buttonPanel), false, self.onOpenZiQiHongMengState, nil, self.canNotOpenZiQiHongMengState)
    -- 点击购买紫气鸿蒙
    self:bindListener("AddButton", self.onAddZiQiHongMengButton, buttonPanel)

    -- 如意刷道令
    local buttonPanel4 = self:getControl("ButtonPanel4")
    self:createSwichButton(self:getControl("OpenStatePanel", nil, buttonPanel4), GetTaoMgr:getRuYiZHLState(), self.onOpenRuYiZHLState, nil, self.canNotOpenRuYiShuaDaoLingState)

    -- 点击购买如意刷道令
    self:bindListener("AddButton", self.onRuYZHLAddButton, buttonPanel4)

    -- 设置急急如律令点数
    self:setLabelText("NameLabel", string.format(CHS[3002657], GetTaoMgr:getAllJijiPoint()), self:getControl("ButtonPanel"))

    -- 设置宠风散点数
    self:setLabelText("NameLabel", string.format(CHS[6200028], GetTaoMgr:getPetFengSanPoint()), self:getControl("ButtonPanel2"))

    -- 设置紫气鸿蒙点数
    self:setLabelText("NameLabel", string.format(CHS[7000286], GetTaoMgr:getAllZiQiHongMengPoint()), self:getControl("ButtonPanel3"))

    -- 设置如意召唤令点数
    self:setLabelText("NameLabel", string.format(CHS[4200388], GetTaoMgr:getRuYiZHLPoint()), self:getControl("ButtonPanel4"))

    -- 更新最高效率
    self:updateFastSpeed()

    -- 刷新急急如律令状态
    self:updateJijiStatus()

    -- 刷新宠风散状态
    self:updateChongfengsanStatus()

    -- 刷新紫气鸿蒙状态
    self:updateZiQiHongMengStatus()
end

-- 刷新急急如律令状态
function GetTaoDlg:updateJijiStatus()
    -- 刷新急急如律令状态
    local buttonPanel = self:getControl("ButtonPanel")
    if 1 == GetTaoMgr:getJijiStatus() then
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), true)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel", buttonPanel), false)
    end
end

-- 刷新宠风散状态
function GetTaoDlg:updateChongfengsanStatus()
    -- 刷新宠风散状态
    local buttonPanel = self:getControl("ButtonPanel2")
    if 1 == GetTaoMgr:getChongfengsanStatus() then
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), true)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), false)
    end
end

-- 刷新紫气鸿蒙状态
function GetTaoDlg:updateZiQiHongMengStatus()
    local buttonPanel = self:getControl("ButtonPanel3")
    if 1 == GetTaoMgr:getZiQiHongMengStatus() then
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), true)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), false)
    end
end

-- 急急如律令的限制条件
function GetTaoDlg:OpenJijiStateLimit()
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002658])
        return true
    end

    return false
end

-- 设置急急如律令状态
function GetTaoDlg:onOpenJijiState(isOn, key)
    if isOn then
        -- 开启
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_JIJI, 1)
    else
        -- 关闭
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_JIJI, 0)
    end

    self:removeArmatureMagicFromCtrl("OpenStatePanel", Const.ARMATURE_MAGIC_TAG, "ButtonPanel")
end

-- 设置宠风散状态
function GetTaoDlg:onOpenChongFengSnaState(isOn, key)
    if isOn then
        -- 开启
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_CHONGFENGSAN, 1)
    else
        -- 关闭
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_CHONGFENGSAN, 0)
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("ChongfsOpenPanel", Const.ARMATURE_MAGIC_TAG)
end

function GetTaoDlg:canNotOpenJiJiRuLvLingState()
    if Me:getLevel() < GetTaoMgr.USE_JIJIRULVLING_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_JIJIRULVLING_MIN_LEVEL))
        return true
    end

    return false
end

function GetTaoDlg:canNotOpenChongFengSanState()
    if Me:getLevel() < GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL))
        return true
    end

    return false
end

function GetTaoDlg:canNotOpenZiQiHongMengState()
    if Me:getLevel() < GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL))
        return true
    end

    return false
end

function GetTaoDlg:canNotOpenRuYiShuaDaoLingState()
    if Me:getLevel() < GetTaoMgr.USE_RUYISHUADAOLING_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_RUYISHUADAOLING_MIN_LEVEL))
        return true
    end

    return false
end

-- 设置紫气鸿蒙状态
function GetTaoDlg:onOpenZiQiHongMengState(isOn, key)
    if isOn then
        -- 开启
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_ZIQIHONGMENG, 1)
    else
        -- 关闭
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_SET_ZIQIHONGMENG, 0)
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("OpenPanel", Const.ARMATURE_MAGIC_TAG, "ButtonPanel3")
end

-- 设置如意召唤令
function GetTaoDlg:onOpenRuYiZHLState(isOn, key)
    if isOn then
        -- 开启
        gf:CmdToServer("CMD_SET_SHUADAO_RUYI_STATE", {state = 1})
    else
        -- 关闭
        gf:CmdToServer("CMD_SET_SHUADAO_RUYI_STATE", {state = 0})
    end

    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl("OpenPanel", Const.ARMATURE_MAGIC_TAG, "ButtonPanel4")
end

function GetTaoDlg:isCanReciveTask(taskName)
    local myId = Me:getId()
    if TeamMgr:inTeam(myId) and TeamMgr:getLeaderId() ~= myId then
        -- 是队员
        gf:ShowSmallTips(CHS[3002659])
        return false
    end

    if Me:isInCombat() then
        -- 战斗中
        gf:ShowSmallTips(CHS[3002947])
        return false
    end

    if Me:isLookOn() then
        gf:ShowSmallTips(CHS[3003797])
        return
    end

    -- 任务等级需求判断
    local myLevel = Me:queryBasicInt("level")
    if myLevel < SHUADAO_TASK[taskName].level then
        gf:ShowSmallTips(string.format(CHS[3002661], SHUADAO_TASK[taskName].name, SHUADAO_TASK[taskName].level))
        return false
    end

    return true
end

-- 降妖按钮
function GetTaoDlg:onXiangyaoGoButton(sender, eventType)
    if not self:isCanReciveTask(TASK_XIANGYAO) then return end

    if TaskMgr:isExistTaskByName(TASK_XIANGYAO) then
        local task = TaskMgr:getTaskByName(TASK_XIANGYAO)
        local autoWalkInfo = gf:findDest(task.task_prompt)
        autoWalkInfo.curTaskWalkPath = {}
        autoWalkInfo.curTaskWalkPath.task_type = task.task_type
        autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

        -- 存在任务
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)

        StateShudMgr:tryChangeToShuad(TASK_XIANGYAO)
    else
        -- 不存在任务，寻路到NPC
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[3002662]))
    end

    -- 日志 changqsdjljc_1 刷道相关记录
    if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == 0 then
        RecordLogMgr:changqsdjljcStart()
    end

    if not RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.xiangy then
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.xiangy =  RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.xiangy + 1
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.xiangy = true
    end


    self:onCloseButton()
end


function GetTaoDlg:onFeixGoButton(sender, eventType)

    if not self:isCanReciveTask(TASK_FEIXIAN) then return end

    if TaskMgr:isExistTaskByName(TASK_FEIXIAN) == true then
        local task = TaskMgr:getTaskByName(TASK_FEIXIAN)
        local autoWalkInfo = gf:findDest(task.task_prompt)
        autoWalkInfo.curTaskWalkPath = {}
        autoWalkInfo.curTaskWalkPath.task_type = task.task_type
        autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

        -- 存在任务
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)

        StateShudMgr:tryChangeToShuad(TASK_FEIXIAN)
    else
        -- 不存在任务，寻路到NPC
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4000445]))
    end

    -- 日志 changqsdjljc_1 刷道相关记录
    if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == 0 then
        RecordLogMgr:changqsdjljcStart()
    end

    if not RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.feix then
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.feix =  RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.feix + 1
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.feix = true
    end


    self:onCloseButton()
end

-- 伏魔按钮
function GetTaoDlg:onFuMoGoButton(sender, eventType)

    -- CG外挂记录log
    RecordLogMgr:isMeetCGPluginCondition("GetTaoDlg")

    if not self:isCanReciveTask(TASK_FUMO) then return end

    if TaskMgr:isExistTaskByName(TASK_FUMO) == true then
        local task = TaskMgr:getTaskByName(TASK_FUMO)
        local autoWalkInfo = gf:findDest(task.task_prompt)
        autoWalkInfo.curTaskWalkPath = {}
        autoWalkInfo.curTaskWalkPath.task_type = task.task_type
        autoWalkInfo.curTaskWalkPath.task_prompt = task.task_prompt

        -- 存在任务
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)

        StateShudMgr:tryChangeToShuad(TASK_FUMO)
    else
        -- 不存在任务，寻路到NPC
        AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[3002663]))
    end

    -- 日志 changqsdjljc_1 刷道相关记录
    if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == 0 then
        RecordLogMgr:changqsdjljcStart()
    end

    if not RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.fum then
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.fum =  RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.fum + 1
        RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock.fum = true
    end


    self:onCloseButton()
end

-- 设置急急如律令
function GetTaoDlg:onAddButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if Me:getLevel() < GetTaoMgr.USE_JIJIRULVLING_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_JIJIRULVLING_MIN_LEVEL))
        return
    end

    if GetTaoMgr:getAllJijiPoint() > GetTaoMgr:getMaxJiJiPoint() - 200 then
        gf:ShowSmallTips(CHS[3002664])
    else
        local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
        dlg:setInfoByType("jiji")
    end
end

-- 购买如意召唤令
function GetTaoDlg:onRuYZHLAddButton(sender, eventType)
    if Me:queryBasicInt("level") < 45 then
        gf:ShowSmallTips(CHS[4200389])
        return
    end

    DlgMgr:openDlg("GetTaoCashBuyDlg")
end

-- 购买宠风散
function GetTaoDlg:onAddPetFengSanButton(sender, eventType)
    -- 如果有光效，删除
    self:removeArmatureMagicFromCtrl(sender:getName(), Const.ARMATURE_MAGIC_TAG, "ButtonPanel2")
    if not DistMgr:checkCrossDist() then return end

    if Me:getLevel() < GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_CHONGFENGSAN_MIN_LEVEL))
        return
    end

    if GetTaoMgr:getPetFengSanPoint() > GetTaoMgr:getMaxChongFengSanPoint() - 200 then
        gf:ShowSmallTips(CHS[6200029])
        return
    end

    local button = self:getControl("MoneyPayButton", nil, "ChongfsPayPanel")
    local image = self:getControl("Image_207", nil, "ChongfsPayPanel")
    if GetTaoMgr:getCashHaveBuyChongFengSanTimes() == GetTaoMgr:GetMaxCanBuyTimes() then
        gf:grayImageView(button)
        gf:grayImageView(image)
    else
        gf:resetImageView(button)
        gf:resetImageView(image)
    end

    local str = string.format(CHS[6200031], GetTaoMgr:getCashHaveBuyChongFengSanTimes(), GetTaoMgr:GetMaxCanBuyTimes())
    self:setLabelText("TitleLabel", str, "ChongfsPayPanel")

    self:setCtrlVisible("ChongfsPayPanel", true)
end

-- 购买紫气鸿蒙
function GetTaoDlg:onAddZiQiHongMengButton()
    if not DistMgr:checkCrossDist() then return end

    if Me:getLevel() < GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL))
        return
    end

    if GetTaoMgr:getAllZiQiHongMengPoint() > GetTaoMgr:getMaxZiQiHongMengPoint() - 200 then
        gf:ShowSmallTips(CHS[7000287])
        return
    end

    local button = self:getControl("ZqhmMoneyPayButton", nil, "ZqhmPayPanel")
    local image = self:getControl("Image_207", nil, "ZqhmPayPanel")
    if GetTaoMgr:getCashHaveBuyZiQiHongMengTimes() == GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes() then
        gf:grayImageView(button)
        gf:grayImageView(image)
    else
        gf:resetImageView(button)
        gf:resetImageView(image)
    end

    local str = string.format(CHS[6200031], GetTaoMgr:getCashHaveBuyZiQiHongMengTimes(), GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes())
    self:setLabelText("TitleLabel", str, "ZqhmPayPanel")

    self:setCtrlVisible("ZqhmPayPanel", true)
end

-- 金钱购买宠风散
function GetTaoDlg:onMoneyPayButton()
    self:setCtrlVisible("ChongfsPayPanel", false)

    if GetTaoMgr:getCashHaveBuyChongFengSanTimes() == GetTaoMgr:GetMaxCanBuyTimes() then
        gf:ShowSmallTips(CHS[6200036])
        return
    end

    local dlg = DlgMgr:openDlg("PetFengsBuyDlg")
    dlg:setType("chongfs")
end

-- 金钱购买紫气鸿蒙
function GetTaoDlg:onZqhmMoneyPayButton()
    self:setCtrlVisible("ZqhmPayPanel", false)

    if GetTaoMgr:getCashHaveBuyZiQiHongMengTimes() == GetTaoMgr:GetMaxCanBuyZiQiHongMengTimes() then
        gf:ShowSmallTips(CHS[6200036])
        return
    end

    local dlg = DlgMgr:openDlg("PetFengsBuyDlg")
    dlg:setType("zqhm")
end

-- 元宝购买宠风散
function GetTaoDlg:onAcerPayButton()
    local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
    dlg:setInfoByType("chongfengsan")
    self:setCtrlVisible("ChongfsPayPanel", false)
end

-- 元宝购买紫气鸿蒙
function GetTaoDlg:onZqhmAcerPayButton()
    if Me:getLevel() < GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL then
        -- 未达到等级要求无法操作
        gf:ShowSmallTips(string.format(CHS[3002380], GetTaoMgr.USE_ZIQI_HONGMENG_MIN_LEVEL))
    elseif GetTaoMgr:getAllZiQiHongMengPoint() > GetTaoMgr:getMaxZiQiHongMengPoint() - 200 then
        gf:ShowSmallTips(CHS[7000287])
    else
        local dlg = DlgMgr:openDlg("GetTaoBuyDlg")
        dlg:setInfoByType("ziqihongmeng")
    end

    self:setCtrlVisible("ZqhmPayPanel", false)
end

function GetTaoDlg:bindCloseTips()
    local panel = self:getControl("ChongfsPayPanel")
    local zqhmPayPanel = self:getControl("ZqhmPayPanel")
    local bkPanel = self:getControl("BKPanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(bkPanel:getContentSize())
    layout:setPosition(bkPanel:getPosition())
    layout:setAnchorPoint(bkPanel:getAnchorPoint())
    self:setCtrlVisible("ChongfsPayPanel", false)
    self:setCtrlVisible("ZqhmPayPanel", false)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local zqhmRect = self:getBoundingBoxInWorldSpace(zqhmPayPanel)
        local toPos = touch:getLocation()
        if not cc.rectContainsPoint(rect, toPos) and panel:isVisible() then
            self:setCtrlVisible("ChongfsPayPanel", false)
            return  true
        end

        if not cc.rectContainsPoint(zqhmRect, toPos) and zqhmPayPanel:isVisible() then
            self:setCtrlVisible("ZqhmPayPanel", false)
            return  true
        end
    end

    self.root:addChild(layout, 10, 1)
    gf:bindTouchListener(layout, touch)
end


-- 更新最高效率
function GetTaoDlg:updateFastSpeed()
    -- 设置降妖最高效率
    local xiangyaoSpeed = GetTaoMgr:getSpeed(TASK_XIANGYAO)
    if nil ~= xiangyaoSpeed and 0 ~= xiangyaoSpeed then
        local str = GetTaoMgr:getTaskSpeedStr(TASK_XIANGYAO)
        self:setLabelText("XiangySpeedLabel", str)
    else
        self:setLabelText("XiangySpeedLabel", CHS[3002665])
    end

    -- 设置伏魔最高效率
    local fumoSpeed = GetTaoMgr:getSpeed(TASK_FUMO)
    if nil ~= fumoSpeed and 0 ~= fumoSpeed then
        local str = GetTaoMgr:getTaskSpeedStr(TASK_FUMO)
        self:setLabelText("FumSpeedLabel", str)
    else
        self:setLabelText("FumSpeedLabel", CHS[3002665])
    end

    -- 设置飞仙最高效率
    local fumoSpeed = GetTaoMgr:getSpeed(TASK_FEIXIAN)
    if nil ~= fumoSpeed and 0 ~= fumoSpeed then
        local str = GetTaoMgr:getTaskSpeedStr(TASK_FEIXIAN)
        self:setLabelText("FeixSpeedLabel", str)
    else
        self:setLabelText("FeixSpeedLabel", CHS[3002665])
    end
end

function GetTaoDlg:MSG_SHUADAO_REFRESH()
    -- 更新最高效率
    self:updateFastSpeed()

    -- 刷新急急如律令状态
    self:updateJijiStatus()

    -- 刷新宠风散状态
    self:updateChongfengsanStatus()

    -- 刷新紫气鸿蒙状态
    self:updateZiQiHongMengStatus()
end

-- 刷新紫气鸿蒙状态
function GetTaoDlg:updateRuYiZHLStatus(data)
    local buttonPanel = self:getControl("ButtonPanel4")
    if GetTaoMgr:getRuYiZHLState() then
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), true)
    else
        self:switchButtonStatus(self:getControl("OpenStatePanel", nil, buttonPanel), false)
    end
end

-- 刷新如意刷道令的状态
function GetTaoDlg:MSG_REFRESH_RUYI_INFO(data)
    self:updateRuYiZHLStatus()
end

function GetTaoDlg:MSG_UPDATE()
    -- 设置急急如律令点数
    self:setLabelText("NameLabel", string.format(CHS[3002657], GetTaoMgr:getAllJijiPoint()), self:getControl("ButtonPanel"))

    -- 设置宠风散点数
    self:setLabelText("NameLabel", string.format(CHS[6200028], GetTaoMgr:getPetFengSanPoint()), self:getControl("ButtonPanel2"))

    -- 设置紫气鸿蒙点数
    self:setLabelText("NameLabel", string.format(CHS[7000286], GetTaoMgr:getAllZiQiHongMengPoint()), self:getControl("ButtonPanel3"))

    -- 设置如意召唤令点数
    self:setLabelText("NameLabel", string.format(CHS[4200388], GetTaoMgr:getRuYiZHLPoint()), self:getControl("ButtonPanel4"))

end

return GetTaoDlg
