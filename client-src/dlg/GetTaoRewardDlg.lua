-- GetTaoRewardDlg.lua
-- Created by songcw Mar/19/2015
-- 刷道领取离线奖励界面

local GetTaoRewardDlg = Singleton("GetTaoRewardDlg", Dialog)

local time_year = 60 * 60 * 24 * 360
local time_day = 60 * 60 * 24

GetTaoRewardDlg.rewardData = nil

function GetTaoRewardDlg:init()
    self:bindListViewListener("GetTaoInformationListView", self.onSelectGetTaoInformationListView)
    self:bindListener("TotalBonusCheckBox", self.onTotalBonusCheckBox)
    self:bindListener("BonusInfoCheckBox", self.onBonusInfoCheckBox)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self:setCheck("TotalBonusCheckBox", true)
    self:setCheck("BonusInfoCheckBox", false)

    self:setCtrlVisible("TotalBonusPanel", true)
    self:setCtrlVisible("GetTaoPanel", false)

    -- 克隆
    local singelInfo = self:getControl("GetTaoInformationPanel", Const.UIPanel)
    self:setCtrlVisible("DoubleFlagImage", false, singelInfo)
    self.singelInfo = singelInfo:clone()
    self.singelInfo:retain()
    singelInfo:removeFromParent()

    -- 添加监听
    local listViewCtrl = self:getControl("GetTaoInformationListView")
    listViewCtrl.sliderName = "GetTaoInformationSlider"
    --listViewCtrl:addScrollViewEventListener(function(sender, eventType) self:updateSlider(sender, eventType) end)

    self:hookMsg("MSG_SHUADAO_REFRESH_BONUS")
end

function GetTaoRewardDlg:cleanup()
    self:releaseCloneCtrl("singelInfo")
end

function GetTaoRewardDlg:setData(data)
    self.root:setVisible(false)
    if not data then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SHUADAO_DO_BONUS)
    else
        self:MSG_SHUADAO_REFRESH_BONUS(data)
    end
end

function GetTaoRewardDlg:close(now)
    self:unhookMsg()
    Dialog.close(self, now)
end

function GetTaoRewardDlg:onTotalBonusCheckBox(sender, eventType)
    if not self:isCheck("TotalBonusCheckBox") then self:setCheck("TotalBonusCheckBox", true) return end

    self:setCheck("BonusInfoCheckBox", false)
    self:setCtrlVisible("TotalBonusPanel", true)
    self:setCtrlVisible("GetTaoPanel", false)
end

function GetTaoRewardDlg:onBonusInfoCheckBox(sender, eventType)
    if not self:isCheck("BonusInfoCheckBox") then self:setCheck("BonusInfoCheckBox", true) return end

    self:setCheck("TotalBonusCheckBox", false)
    self:setCtrlVisible("TotalBonusPanel", false)
    self:setCtrlVisible("GetTaoPanel", true)
end

function GetTaoRewardDlg:onConfrimButton(sender, eventType)
    self:onCloseButton()
end

-- 更新滚动条
function GetTaoRewardDlg:updateSlider(sender, eventType, panel)
    if ccui.ScrollviewEventType.scrolling == eventType then
        -- 获取控件

        local listViewCtrl = sender
        local sliderCtrl = self:getControl(listViewCtrl.sliderName, Const.UISlider, panel)

        -- 获取ListView内部的Layout，及其ContentSize
        local listInnerContent = listViewCtrl:getInnerContainer()
        local innerSize = listInnerContent:getContentSize()
        local listViewSize = listViewCtrl:getContentSize()

        -- 计算滚动的百分比
        local totalHeight = innerSize.height - listViewSize.height
        local innerPosY = listInnerContent:getPositionY()
        local persent = 1 - (-innerPosY) / totalHeight
        persent = math.floor(persent * 100)
        sliderCtrl:setPercent(persent)

        -- 设置显示状态，如果滚动的话，就让他显示，在滚动1s之后消失
        local fadeOut = cc.FadeOut:create(1)
        local func = cc.CallFunc:create(function() sliderCtrl:setVisible(false) end)
        local action = cc.Sequence:create(fadeOut, func)
        sliderCtrl:setVisible(true)
        sliderCtrl:setOpacity(100)
        sliderCtrl:stopAllActions()
        sliderCtrl:runAction(action)
    end
end

function GetTaoRewardDlg:setTotalInfo(data)
    -- 上次离线刷道%d分钟%d秒
    local min = math.floor(data.lastTime / 60)
    local sec = data.lastTime % 60
    self:setLabelText("OffLineTimeLabel", string.format(CHS[4000278], min, sec))

    -- 离线刷道%d轮 打败强盗%d次
    local total = self:getTotalLun(data)
    self:setLabelText("GetTaoNumberLabel", string.format(CHS[4000279], total))

    -- 消耗双倍点数
    self:setLabelText("RobberLabel", string.format(CHS[4000280], data.doublePoint))

    -- 其中%d场战斗受双倍加成
    self:setLabelText("DoubleLabel", string.format(CHS[4000281], data.doubleTime))
    
    -- 宠风散收益%d轮
    self:setLabelText("ChongfsLabel", string.format(CHS[6200034], data.ChongfengsanTimes))
    
    -- 消耗宠风散%d点
    self:setLabelText("ChongfsPointsLabel", string.format(CHS[6200035], data.ChongfengsanPoint))
    
    -- 道行
    local tao = gf:getTaoStr(data.totalTao, data.totalTaoPoint)

    self:setLabelText("TotalTaoLabel2", tao)

    -- 武学
    self:setLabelText("TotalMartialLabel2", string.format(CHS[4000285], data.totalMartial))
    
    -- 道法
    self:setLabelText("TotalDaofaLabel2", string.format(CHS[4000285], data.totalDaofa))
    
    -- 潜能
    self:setLabelText("TotalPotLabel2", string.format(CHS[4000285], data.totalPotential))

    -- 急急如律令
    self:setLabelText("FullMonsterLabel", string.format(CHS[3002688], data.jjrllPoint))
    
    -- 紫气鸿蒙
    self:setLabelText("ZqhmLabel", string.format(CHS[7000294], data.ziqihongmengPoint))
    
    -- 金钱
    local money, color = gf:getMoneyDesc(data.totalMoney, true)
    self:setLabelText("TotalMoneyLabel2", money, nil, color)

    if data.moneyType == 0 then -- 代金券
        self:setLabelText("TotalMoneyLabel1", CHS[3002689])
    elseif data.moneyType == 1 then -- 金钱
        self:setLabelText("TotalMoneyLabel1", CHS[3002690])
    end

    self:updateLayout("TotalBonusPanel")
end

function GetTaoRewardDlg:getTotalLun(data)
    local fightTotal = 0
    for i = 1, data.totalFight do
        if data.tasks[i].rounds ~= 0 then
            fightTotal = data.tasks[i].rounds - data.tasks[i].fightTime + 1 + fightTotal
        end
    end

    return fightTotal
end

function GetTaoRewardDlg:setFightList(data)
    local listView = self:resetListView("GetTaoInformationListView")
    if nil == listView then return end
    for i = 1, data.totalFight do
        local singelInfo = self.singelInfo:clone()
        singelInfo:setEnabled(false)
        self:setSingelFight(data, singelInfo, i)
        listView:pushBackCustomItem(singelInfo)

        --[[
        local displayAction = cc.CallFunc:create(function()
            local singelInfo = self.singelInfo:clone()
            singelInfo:setEnabled(false)
            self:setSingelFight(data, singelInfo, i)
            listView:pushBackCustomItem(singelInfo)

--          performWithDelay(self.root, function()
--              listView:scrollToBottom(0.5, true)
--          end, 0)

        end)

        listView:runAction(cc.Sequence:create(cc.DelayTime:create(0.5 * i), displayAction))
        --]]
    end

    self:updateLayout("GetTaoPanel")
end

function GetTaoRewardDlg:getLastTaskName()
    return GetTaoMgr:getMyLastTask()
end

function GetTaoRewardDlg:setSingelFight(data, panel, i)

    if data.tasks[i].fightTime == 0 and data.tasks[i].rounds == 0 then
        self:setLabelText("TaskNameLabel1", CHS[4000287], panel)
        self:setCtrlVisible("TaskNameLabel2", false, panel)
    else
        self:setLabelText("TaskNameLabel1", self:getLastTaskName() .. ":", panel)
        self:setLabelText("TaskNameLabel2", string.format(CHS[3002691],data.tasks[i].fightTime, data.tasks[i].rounds), panel)
    end
    -- 道行

    local tao = gf:getTaoStr(data.tasks[i].tao, data.tasks[i].taoPoint)
    self:setLabelText("GetTaoLabel2", tao, panel)

    -- 武学
    self:setLabelText("GetMartialLabel2", string.format(CHS[4000285], data.tasks[i].martial), panel)

    -- 潜能
    self:setLabelText("GetPotLabel2", string.format(CHS[4000285], data.tasks[i].potential), panel)
    
    -- 道法
    self:setLabelText("GetDaofaLabel2", string.format(CHS[4000285], data.tasks[i].daofa), panel)
    
    -- 金钱
    local money, color = gf:getMoneyDesc(data.tasks[i].money, true)
    self:setLabelText("GetMoneyLabel2", money, panel, color)

    if data.moneyType == 0 then -- 代金券
        self:setLabelText("GetMoneyLabel1", CHS[3002692], panel)
    elseif data.moneyType == 1 then -- 金钱
        self:setLabelText("GetMoneyLabel1", CHS[3002693], panel)
    end

    -- 双倍标记
    if data.tasks[i].isDouble > 0 then
        self:setCtrlVisible("DoubleImage", true, panel)
    else
        self:setCtrlVisible("DoubleImage", false, panel)
    end
    
    self:setCtrlVisible("BackImage_2", (i % 2) == 0, panel)

    panel:requestDoLayout()
end

function GetTaoRewardDlg:MSG_SHUADAO_REFRESH_BONUS(data)
    self.rewardData = data
    self:setTotalInfo(data)
    self:setFightList(data)
    if self.root then
        self.root:setVisible(true)
    end
end

return GetTaoRewardDlg
